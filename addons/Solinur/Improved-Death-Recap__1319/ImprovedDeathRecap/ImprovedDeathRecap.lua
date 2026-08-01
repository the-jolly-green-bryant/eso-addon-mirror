-- define local variables as much as possible, so scope is local
-- see http://lua-users.org/wiki/ScopeTutorial
local em       = GetEventManager()
local _, tlw
local dx       = 1 / GetSetting(SETTING_TYPE_UI, UI_SETTING_CUSTOM_SCALE)

IDR            = IDR or {}
local IDR      = IDR
IDR.name       = "ImprovedDeathRecap"
IDR.version    = "1.0.2"

local settings
local defaults =
{
	MaxEvents = 30,
	MaxDeaths = 10,
	WinWidth = 700,
	WinHeight = 300,
	WinPos = { TOPLEFT, GuiRoot, TOPLEFT, 100, 200 },
	WinLock = false,
	WinOpacity = 90,
	ShowOnDeath = true,
	HideOnRevive = true,
	HideWinDelay = 2,
	HideOnCombat = true,
	ShowAfterCombat = false,
	Winfontsize = 18,
	stamthreshold = 5000,
	deathhistory = {}
}

local function HideTLW()
	em:UnregisterForUpdate("IDR_Hide")
	tlw:SetHidden(true)
end

IDR.Hide = HideTLW

function IDR.Toggle()
	em:UnregisterForUpdate("IDR_Hide")
	tlw:SetHidden(not tlw:IsControlHidden())
end

local function ShowTLW()
	em:UnregisterForUpdate("IDR_Hide")
	tlw:SetHidden(false)
end

function IDR.MoveWin()
	-- Get the new position and dimensions
	local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = tlw:GetAnchor()
	local width, height = tlw:GetDimensions()

	-- Save the new settings
	if (isValidAnchor) then settings.WinPos = { point, relativeTo, relativePoint, offsetX, offsetY } end
	settings.WinWidth = width
	settings.WinHeight = height
	IDR.AdjustSlider()
end

function IDR.OnSliderValueChanged(slider, value, eventReason) -- self should be slider
	local buffer = slider:GetParent():GetNamedChild("Buffer")
	local numHistoryLines = buffer:GetNumHistoryLines()
	local sliderValue = math.max(slider:GetValue(), math.floor((buffer:GetNumVisibleLines() + 1) / dx)) -- correct for ui scale
	if eventReason == EVENT_REASON_HARDWARE then
		buffer:SetScrollPosition(numHistoryLines - sliderValue)
	end
end

function IDR.OnScrollButton(self, delta) -- self should be one of the slider buttons
	local slider = self:GetParent()
	local buffer = slider:GetParent():GetNamedChild("Buffer")
	if delta ~= nil and delta ~= 0 then
		buffer:SetScrollPosition(math.min(buffer:GetScrollPosition() + delta, math.floor(buffer:GetNumHistoryLines()))) -- correct for ui scale
		slider:SetValue(slider:GetValue() - delta)
	else
		buffer:SetScrollPosition(0)
		slider:SetValue(buffer:GetNumHistoryLines())
	end
end

function IDR.OnScrollMouse(buffer, delta, ctrl, alt, shift) -- self should be buffer
	local slider = buffer:GetParent():GetNamedChild("Slider")
	if shift then
		delta = delta * math.floor((buffer:GetNumVisibleLines()) / dx) -- correct for ui scale
	elseif ctrl then
		delta = delta * buffer:GetNumHistoryLines()
	end
	buffer:SetScrollPosition(math.min(buffer:GetScrollPosition() + delta, math.floor(buffer:GetNumHistoryLines()))) -- correct for ui scale
	slider:SetValue(slider:GetValue() - delta)
end

function IDR.AdjustSlider()
	local slider = tlw:GetNamedChild("Slider")
	local buffer = tlw:GetNamedChild("Buffer")
	local numHistoryLines = buffer:GetNumHistoryLines()
	local numVisHistoryLines = math.floor((buffer:GetNumVisibleLines() + 1) / dx) --it seems numVisHistoryLines is getting screwed by UI Scale
	local sliderMin, sliderMax = slider:GetMinMax()
	local sliderValue = slider:GetValue()

	slider:SetMinMax(0, numHistoryLines)

	-- If the sliders at the bottom, stay at the bottom to show new text
	if sliderValue == sliderMax then
		slider:SetValue(numHistoryLines)
		-- If the buffer is full start moving the slider up
	elseif numHistoryLines == buffer:GetMaxHistoryLines() then
		slider:SetValue(sliderValue - 1)
	end -- Else the slider does not move

	-- If there are more history lines than visible lines show the slider
	if numHistoryLines > numVisHistoryLines then
		slider:SetHidden(false)
		slider:SetThumbTextureHeight(math.max(20, math.floor(numVisHistoryLines / numHistoryLines * slider:GetHeight())))
	else
		-- else hide the slider
		slider:SetHidden(true)
	end
end

function IDR.UpdateDeathList() --similar to ZO_ComboBox_Base:AddItems(items) but with ipairs
	local deathHistory = settings.deathhistory
	if deathHistory == nil or #deathHistory == 0 then return end

	local menu = IDR.dropdown
	menu:ClearItems()

	for _, deathData in ipairs(deathHistory) do -- use ipairs instead of pairs -> no need for sorting
		local item = ZO_ShallowTableCopy(deathData)
		item.callback = IDR.OnMenuSelect
		menu:AddItem(item, ZO_COMBOBOX_SUPRESS_UPDATE)
	end

	menu:UpdateItems()
end

function IDR.OnMenuSelect(_, _, item, selectionChanged)
	if selectionChanged then
		IDR.PostRecap(item)
	end
end

function IDR.showclipboard()
	IDR.currenttext = IDR.currenttext:gsub("|c......(.-)|r", "%1"):gsub("|t.-|t", "")
	IDR.clipboardbox:SetText(IDR.currenttext)
	IDR.clipboard:SetHidden(false)
	IDR.clipboardbox:TakeFocus()
end

local validResults = {
	[ACTION_RESULT_DAMAGE] = true,
	[ACTION_RESULT_CRITICAL_DAMAGE] = true,
	[ACTION_RESULT_DOT_TICK] = true,
	[ACTION_RESULT_DOT_TICK_CRITICAL] = true,
	[ACTION_RESULT_BLOCKED] = true,
	[ACTION_RESULT_BLOCKED_DAMAGE] = true,
	[ACTION_RESULT_ABSORBED] = true,
	[ACTION_RESULT_DAMAGE_SHIELDED] = true,
	[ACTION_RESULT_HEAL] = true,
	[ACTION_RESULT_CRITICAL_HEAL] = true,
	[ACTION_RESULT_HOT_TICK] = true,
	[ACTION_RESULT_HOT_TICK_CRITICAL] = true,
	[ACTION_RESULT_FALL_DAMAGE] = true,
}

-- pool events which are similar and happen within 100ms
local function isDoubleHitEvent(lastEvent, source, abilityId, timems)
	if lastEvent == nil then return end
	return lastEvent.source == source and lastEvent.ability == abilityId and timems - lastEvent.timems < 100
end

function IDR.CombatEvent(_, result, _, _, _, _, sourceName, _, targetName, _, hitValue, _, damageType, _, _, _, abilityId, overFlow)
	local totalHitValue = overFlow + hitValue

	if totalHitValue <= 0 or validResults[result] == nil then return end

	local source = ZO_CachedStrFormat("<<!aC:1>>", sourceName)
	local timems = GetGameTimeMilliseconds()

	local currenthp, maxhp = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_HEALTH)
	local currentstam, maxstam = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_STAMINA)

	local currentQueue = IDR.currenthistory
	local lastEvent = currentQueue.lastItem

	if isDoubleHitEvent(lastEvent, source, abilityId, timems) then
		lastEvent.value = lastEvent.value + totalHitValue
		lastEvent.hits = lastEvent.hits + 1
		lastEvent.currenthp = currenthp
		lastEvent.maxhp = maxhp
		lastEvent.currentstam = currentstam
		lastEvent.maxstam = maxstam
		return
	end

	local data
	if currentQueue.last - currentQueue.first >= settings.MaxEvents then
		data = currentQueue:Pop()
	else
		data = {}
	end

	data.source = source
	data.ability = abilityId
	data.timems = timems
	data.dmgtype = damageType
	data.value = hitValue
	data.hits = 1
	data.result = result
	data.currenthp = currenthp
	data.maxhp = maxhp
	data.currentstam = currentstam
	data.maxstam = maxstam

	currentQueue:Push(data)
end

local Queue = ZO_InitializingObject:Subclass()  -- from https://www.lua.org/pil/11.4.html

function Queue:Initialize()
	self.first = 0
	self.last = -1
end

function Queue:Pop()
	local first = self.first
	if first > self.last then error("list is empty") end
	local value = self[first]
	self[first] = nil
	self.first = first + 1
	return value
end

function Queue:Push(data)
	local last = self.last + 1
	self.last = last
	self[last] = data
	self.lastItem = data
end

local function ProcessDeath()
	em:UnregisterForUpdate("IDR_ProcessDeath")
	local deathTimems = GetGameTimeMilliseconds()
	local deathTimestamp = string.format("%s, %s", GetDateStringFromTimestamp(GetTimeStamp()), GetTimeString())
	local deathHistory = settings.deathhistory
	table.insert(deathHistory, 1, {events = IDR.currenthistory, name = deathTimestamp, deathtimems = deathTimems})
	IDR.currenthistory = Queue:New()
	if #deathHistory > settings.MaxDeaths then table.remove(deathHistory, #deathHistory) end
	
	IDR.UpdateDeathList()
	if settings.ShowOnDeath == true then
		IDR.dropdown:SelectItemByIndex(1, true)
		IDR.PostRecap(deathHistory[1])
		ShowTLW()
	end
end

local function OnDeath()
	em:RegisterForUpdate("IDR_ProcessDeath", 100, ProcessDeath)
end

local function OnRevive()
	if settings.HideOnRevive == true then
		em:UnregisterForUpdate("IDR_Hide")
		em:RegisterForUpdate("IDR_Hide", settings.HideWinDelay * 1000, HideTLW)
	end
end

local function OnPlayerCombatState(event, inCombat)
	local wasopen = tlw:IsControlHidden()
	if (inCombat == true) then
		IDR.currenthistory = Queue:New()
		if settings.HideOnCombat == true then HideTLW() end
	elseif (inCombat == false) then
		if (settings.ShowAfterCombat == true and wasopen == true) then ShowTLW() end
	end
end

function IDR.Write(message, color)
	if message == nil then return end
	local color = color or { 0.6, 0.6, 0.6 }

	tlw:GetNamedChild("Buffer"):AddMessage(message, unpack(color))
	IDR.AdjustSlider()
end

local critResults = {
	[ACTION_RESULT_CRITICAL_DAMAGE] = true,
	[ACTION_RESULT_DOT_TICK_CRITICAL] = true,
	[ACTION_RESULT_CRITICAL_HEAL] = true,
	[ACTION_RESULT_HOT_TICK_CRITICAL] = true,
}

local RESULT_MESSAGE_NORMAL = " hits with "
local RESULT_MESSAGE_BLOCKED = " hits the |cEEEEEEblock|r with "
local RESULT_MESSAGE_ABSORBED = " gets absorbed by "
local RESULT_MESSAGE_HEAL = " heals with "
local RESULT_MESSAGE_FALL = "You got hurt by  "

local hitMessage = {
	[ACTION_RESULT_DAMAGE] = RESULT_MESSAGE_NORMAL,
	[ACTION_RESULT_CRITICAL_DAMAGE] = RESULT_MESSAGE_NORMAL,
	[ACTION_RESULT_DOT_TICK] = RESULT_MESSAGE_NORMAL,
	[ACTION_RESULT_DOT_TICK_CRITICAL] = RESULT_MESSAGE_NORMAL,
	[ACTION_RESULT_BLOCKED] = RESULT_MESSAGE_BLOCKED,
	[ACTION_RESULT_BLOCKED_DAMAGE] = RESULT_MESSAGE_BLOCKED,
	[ACTION_RESULT_ABSORBED] = RESULT_MESSAGE_ABSORBED,
	[ACTION_RESULT_DAMAGE_SHIELDED] = RESULT_MESSAGE_ABSORBED,
	[ACTION_RESULT_HEAL] = RESULT_MESSAGE_HEAL,
	[ACTION_RESULT_CRITICAL_HEAL] = RESULT_MESSAGE_HEAL,
	[ACTION_RESULT_HOT_TICK] = RESULT_MESSAGE_HEAL,
	[ACTION_RESULT_HOT_TICK_CRITICAL] = RESULT_MESSAGE_HEAL,
	[ACTION_RESULT_FALL_DAMAGE] = RESULT_MESSAGE_FALL,
}

local RESULT_COLOR_NORMAL = { 0.9, 0.5, 0.5 }
local RESULT_COLOR_BLOCKED = { 1.0, 0.7, 0.4 }
local RESULT_COLOR_ABSORBED = { 0.7, 0.5, 0.7 }
local RESULT_COLOR_HEAL = { 0.5, 0.9, 0.5 }
local RESULT_COLOR_FALL = { 0.5, 0.5, 0.8 }


local resultColor = {
	[ACTION_RESULT_DAMAGE] = RESULT_COLOR_NORMAL,
	[ACTION_RESULT_CRITICAL_DAMAGE] = RESULT_COLOR_NORMAL,
	[ACTION_RESULT_DOT_TICK] = RESULT_COLOR_NORMAL,
	[ACTION_RESULT_DOT_TICK_CRITICAL] = RESULT_COLOR_NORMAL,
	[ACTION_RESULT_BLOCKED] = RESULT_COLOR_BLOCKED,
	[ACTION_RESULT_BLOCKED_DAMAGE] = RESULT_COLOR_BLOCKED,
	[ACTION_RESULT_ABSORBED] = RESULT_COLOR_ABSORBED,
	[ACTION_RESULT_DAMAGE_SHIELDED] = RESULT_COLOR_ABSORBED,
	[ACTION_RESULT_HEAL] = RESULT_COLOR_HEAL,
	[ACTION_RESULT_CRITICAL_HEAL] = RESULT_COLOR_HEAL,
	[ACTION_RESULT_HOT_TICK] = RESULT_COLOR_HEAL,
	[ACTION_RESULT_HOT_TICK_CRITICAL] = RESULT_COLOR_HEAL,
	[ACTION_RESULT_FALL_DAMAGE] = RESULT_COLOR_FALL,
}

local function GetHealthColor(index)
	if index <= 16 then
		local char = string.sub("0123456789ABCDEF", index, index)
		return string.format("%s%s%s%s", "FF", char, char, "00")
	end

	index = 33 - index
	local char = string.sub("0123456789ABCDEF", index, index)
	return string.format("%s%s%s", char, char, "FF00")
end

local healthColors = {}
for index = 1, 32 do
	healthColors[index] = GetHealthColor(index)
end


local dmgColors = {
	[DAMAGE_TYPE_NONE]     = " |cE6E6E6",
	[DAMAGE_TYPE_GENERIC]  = " |cE6E6E6",
	[DAMAGE_TYPE_PHYSICAL] = " |cf4f2e8",
	[DAMAGE_TYPE_FIRE]     = " |cff6600",
	[DAMAGE_TYPE_SHOCK]    = " |cffff66",
	[DAMAGE_TYPE_OBLIVION] = " |cd580ff",
	[DAMAGE_TYPE_COLD]     = " |cb3daff",
	[DAMAGE_TYPE_EARTH]    = " |cbfa57d",
	[DAMAGE_TYPE_MAGIC]    = " |c9999ff",
	[DAMAGE_TYPE_DROWN]    = " |ccccccc",
	[DAMAGE_TYPE_DISEASE]  = " |cc48a9f",
	[DAMAGE_TYPE_POISON]   = " |c9fb121",
	[DAMAGE_TYPE_BLEED]    = " |cc20a38",
}


local message_items = {}
local function GetLine(event, deathtime)
	local result = event.result

	message_items[1] = string.format("|cEEEEEE[%.3fs]|r ", (event.timems - deathtime) / 1000)

	local healtColorIndex = math.floor(event.currenthp / event.maxhp * 31) + 1
	message_items[2] = string.format("|c%sHP:%d/%d|r ", healthColors[healtColorIndex], event.currenthp, event.maxhp)
	message_items[3] = event.source
	message_items[4] = critResults[result] and " |cEEEEEEcritically|r" or ""
	message_items[5] = hitMessage[result] or ("unknown event: " .. result)
	message_items[6] = zo_iconFormat(GetAbilityIcon(event.ability), settings.Winfontsize, settings.Winfontsize)
	message_items[7] = dmgColors[event.dmgtype] or dmgColors[DAMAGE_TYPE_NONE]
	message_items[8] = result == ACTION_RESULT_FALL_DAMAGE and " falling down" or ZO_CachedStrFormat("<<!aC:1>>", GetAbilityName(event.ability))
	message_items[9] = "|r for |cEEEEEE"
	message_items[10] = event.value
	message_items[11] = event.hits > 1 and string.format("|r (%dx)", event.hits) or "|r "

	if event.currentstam < settings.stamthreshold or settings.stamthreshold == 0 then
		message_items[12] = string.format(" |c00BB00[Stam:%d/%d] |r", event.currentstam, event.maxstam)
	end

	local message = table.concat(message_items, "")
	local color = resultColor[result] or { 0.9, 0.9, 0.7 }

	return message, color
end

function IDR.PostRecap(deathdata)
	local events = deathdata.events or deathdata.data or {}
	local deathtime = deathdata.deathtimems
	local datatext = {}
	tlw:GetNamedChild("Buffer"):Clear()

	for i = events.first or 1, events.last or #events do
		local event = events[i]
		if event.timems > (deathdata.deathtimems + 1000) then break end
		local message, color = GetLine(event, deathtime)

		datatext[#datatext + 1] = message
		IDR.Write(message, color)
	end

	IDR.currenttext = table.concat(datatext, " | ")
end

-- Slash Commands

function IDR.Slash(extra)
	local extra = extra or "help"
	if extra == "show" then
		IDR.forceopen = true
		ShowTLW()
	elseif extra == "hide" then
		IDR.forceopen = false
		HideTLW()
	else
		d(GetString(SI_IMPROVED_DEATH_RECAP_HELPTEXT))
	end
end

SLASH_COMMANDS["/idr"] = IDR.Slash

local function GetbufferFont(size)
	return string.format("%s|%d",GetString(SI_IMPROVED_DEATH_RECAP_FONT), size)
end

-- API

function IDR.GetLatestDeath()
	if settings and settings.deathhistory and settings.deathhistory[1] then
		return settings.deathhistory[1]
	end
end

function IDR.GetDeathHistory()
	if settings then
		return settings.deathhistory
	end
end

-- LAM Stuff
function IDR.MakeMenu()
	-- load the settings->addons menu library
	local menu = LibAddonMenu2

	-- the panel for the addons menu
	local panel = {
		type = "panel",
		name = "Improved Death Recap",
		displayName = "Improved Death Recap",
		author = "Solinur",
		version = IDR.version,
		registerForRefresh = true,
		registerForDefaults = true,
	}

	--this addons entries in the addon menu
	local options = {
		{
			type = "header",
			name = SI_IMPROVED_DEATH_RECAP_MENU_HEADER
		},
		{
			type = "slider",
			name = SI_IMPROVED_DEATH_RECAP_MENU_SAVEDEVENTS,
			tooltip = SI_IMPROVED_DEATH_RECAP_MENU_SAVEDEVENTS_TT,
			min = 5,
			max = 100,
			step = 1,
			getFunc = function() return settings.MaxEvents end,
			setFunc = function(value)
				settings.MaxEvents = value
			end,
		},
		{
			type = "slider",
			name = SI_IMPROVED_DEATH_RECAP_MENU_SAVEDDEATHS,
			tooltip = SI_IMPROVED_DEATH_RECAP_MENU_SAVEDDEATHS_TT,
			min = 1,
			max = 30,
			step = 1,
			getFunc = function() return settings.MaxDeaths end,
			setFunc = function(value)
				settings.MaxDeaths = value
			end,
		},
		{
			type = "checkbox",
			name = SI_IMPROVED_DEATH_RECAP_MENU_LOCKWINDOW,
			tooltip = SI_IMPROVED_DEATH_RECAP_MENU_LOCKWINDOW_TT,
			getFunc = function() return tlw:IsMouseEnabled() end,
			setFunc = function(value)
				settings.WinLock = value
				tlw:SetMouseEnabled(not value)
			end,
		},
		{
			type = "slider",
			name = SI_IMPROVED_DEATH_RECAP_MENU_OPACITY,
			tooltip = SI_IMPROVED_DEATH_RECAP_MENU_OPACITY_TT,
			min = 0,
			max = 100,
			step = 5,
			getFunc = function() return settings.WinOpacity end,
			setFunc = function(value)
				settings.WinOpacity = value
				tlw:GetNamedChild("Bg"):SetAlpha(value / 100)
			end,
		},
		{
			type = "slider",
			name = SI_IMPROVED_DEATH_RECAP_MENU_FONTSIZE,
			tooltip = SI_IMPROVED_DEATH_RECAP_MENU_FONTSIZE_TT,
			min = 8,
			max = 24,
			step = 1,
			getFunc = function() return settings.Winfontsize end,
			setFunc = function(value)
				settings.Winfontsize = value
				tlw:GetNamedChild("Buffer"):SetFont(GetbufferFont(value))
			end,
		},
		{
			type = "checkbox",
			name = SI_IMPROVED_DEATH_RECAP_MENU_SHOWONDEATH,
			tooltip = SI_IMPROVED_DEATH_RECAP_MENU_SHOWONDEATH_TT,
			getFunc = function() return settings.ShowOnDeath end,
			setFunc = function(value)
				settings.ShowOnDeath = value
			end,
		},
		{
			type = "checkbox",
			name = SI_IMPROVED_DEATH_RECAP_MENU_HIDEONREVIVE,
			tooltip = SI_IMPROVED_DEATH_RECAP_MENU_HIDEONREVIVE_TT,
			getFunc = function() return settings.HideOnRevive end,
			setFunc = function(value)
				settings.HideOnRevive = value
			end,
		},
		{
			type = "slider",
			name = SI_IMPROVED_DEATH_RECAP_MENU_HIDEONREVIVE_DELAY,
			tooltip = SI_IMPROVED_DEATH_RECAP_MENU_HIDEONREVIVE_DELAY_TT,
			min = 0,
			max = 30,
			step = 1,
			getFunc = function() return settings.HideWinDelay end,
			setFunc = function(value)
				settings.HideWinDelay = value
			end,
			disabled = function() return (not settings.HideOnRevive) end,
		},
		{
			type = "checkbox",
			name = SI_IMPROVED_DEATH_RECAP_MENU_HIDEINCOMBAT,
			tooltip = SI_IMPROVED_DEATH_RECAP_MENU_HIDEINCOMBAT_TT,
			getFunc = function() return settings.HideOnCombat end,
			setFunc = function(value)
				settings.HideOnCombat = value
			end,
		},
		{
			type = "checkbox",
			name = SI_IMPROVED_DEATH_RECAP_MENU_SHOWAFTERCOMBAT,
			tooltip = SI_IMPROVED_DEATH_RECAP_MENU_SHOWAFTERCOMBAT_TT,
			getFunc = function() return settings.ShowAfterCombat end,
			setFunc = function(value)
				settings.ShowAfterCombat = value
			end,
		},
		{
			type = "slider",
			name = SI_IMPROVED_DEATH_RECAP_MENU_STAMINATHRESHOLD,
			tooltip = SI_IMPROVED_DEATH_RECAP_MENU_STAMINATHRESHOLD_TT,
			min = 0,
			max = 80000,
			step = 1000,
			getFunc = function() return settings.stamthreshold end,
			setFunc = function(value)
				settings.stamthreshold = value
			end,
		},
	}

	menu:RegisterAddonPanel("IDROptions", panel)
	menu:RegisterOptionControls("IDROptions", options)
end
-- Initialization
function IDR:Initialize(event, addon)
	if addon ~= IDR.name then return end
	em:UnregisterForEvent( "IDR_load", EVENT_ADD_ON_LOADED)

	-- load saved variables
	settings = ZO_SavedVars:NewCharacterIdSettings("ImprovedDeathRecapSavedVariables", 3, nil, defaults)

	tlw = IDR_TLW2

	IDR.currenthistory = Queue:New()
	IDR.Groupnames = {}

	-- Register Events and filter them for specific types. Should be more efficient then getting them all and throwing most of them away
	-- The filter will limit the events to the group members / the player only.

	em:RegisterForEvent("IDR_combat", EVENT_COMBAT_EVENT, IDR.CombatEvent)
	em:AddFilterForEvent("IDR_combat", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE,
		COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_IS_ERROR, false)

	em:RegisterForEvent("IDR_death", EVENT_PLAYER_DEAD, OnDeath)
	em:RegisterForEvent("IDR_revive", EVENT_PLAYER_ALIVE, OnRevive)

	em:RegisterForEvent("IDR_incombat", EVENT_PLAYER_COMBAT_STATE, OnPlayerCombatState)

	ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_DEATH_RECAP", "Toggle Improved Death Recap")

	IDR.delayinprogress = false

	IDR.MakeMenu()

	IDR.forceopen = false

	tlw:ClearAnchors()
	tlw:SetAnchor(unpack(settings.WinPos))
	tlw:SetDimensions(settings.WinWidth, settings.WinHeight)
	tlw:GetNamedChild("Title"):SetFont(GetString(SI_IMPROVED_DEATH_TITLE_FONT))
	tlw:GetNamedChild("Buffer"):SetFont(GetbufferFont(settings.Winfontsize))
	tlw:GetNamedChild("Bg"):SetAlpha(settings.WinOpacity / 100)
	tlw:SetMouseEnabled(not settings.WinLock)

	IDR.dropdown = ZO_ComboBox_ObjectFromContainer(tlw:GetNamedChild("ComboBox"))
	IDR.dropdown:SetSortsItems(false)
	IDR.UpdateDeathList()

	IDR.clipboard = tlw:GetNamedChild("Clipboard")
	IDR.clipboardbox = IDR.clipboard:GetNamedChild("Container"):GetNamedChild("Box")

	IDR.clipboardbox:SetMaxInputChars(100000)
	IDR.clipboardbox:SetFont(GetbufferFont(settings.Winfontsize))
	IDR.clipboardbox:SetHandler("OnTextChanged", function(control)
		control:SelectAll()
	end)
	IDR.clipboardbox:SetHandler("OnFocusLost", function()
		IDR.clipboard:SetHidden(true)
	end)
end

-- Finally, we'll register our event handler function to be called when the proper event occurs.
em:RegisterForEvent("IDR_load", EVENT_ADD_ON_LOADED, function(...) IDR:Initialize(...) end)
