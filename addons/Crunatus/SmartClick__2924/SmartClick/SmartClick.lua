local addon = {
	name = "SmartClick",
	displayName = "Smart Click",
	author = "Crunatus",
	version = "3.0",
	settings = {
		blacklist = {},
		onetimeaction = {},
		onlyinpvp = {},
		onlyincombat = {},
		enabledoubleclick = false,
		keyboardsensitivity = 250,
	},
	abilityDuration = {},		-- abilityDuration[number abilityIndex]
	lastClicked = {},		-- lastClicked[number abilityIndex]
	actionButtonUp = {},		-- actionButtonUp[number slotNum]
}

-- local checkedTexture = "/esoui/art/buttons/checkbox_checked.dds"
-- local uncheckedTexture = "/esoui/art/buttons/checkbox_unchecked.dds"

-- Settings menu
function addon.CreateSettingsMenu()
    local LAM = LibAddonMenu2
	
    local panelData = {
        type = "panel",
        name = addon.displayName,
        displayName = addon.displayName,
        author = addon.author,
		version = addon.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }
	
	local optionsData = {
		[1] = {
			type = "checkbox",
			name = GetString(SI_SMARTCLICK_DOUBLECLICK),
			getFunc = function() return addon.settings.enabledoubleclick end,
			setFunc = function(value) addon.settings.enabledoubleclick = value end,
			default = false,
		},
		[2] =  {
			type = "slider",
			name = GetString(SI_SMARTCLICK_KEYBOARD_SENSITIVITY),
			getFunc = function() return addon.settings.keyboardsensitivity end,
			setFunc = function(value) addon.settings.keyboardsensitivity = value end,
			min = 100,
			max = 500,
			step = 10,
			readOnly = true,
			default = 250,
			disabled = function() return addon.settings.enabledoubleclick == false end
		},
	}
	
	LAM:RegisterAddonPanel("SmartClick_LAM", panelData)
	LAM:RegisterOptionControls("SmartClick_LAM", optionsData)
end

-- Matching buffs to specified abilities
local ABILITY_BUFF_INDEX = {
	[24584] = 114903,	-- Dark Exchange
	[24595] = 114908,	-- Dark Deal
	[108840] = 108843,	-- Summon Unstable Familiar
	[77182] = 88933,		-- Volatile Pulse
	[77140] = 88937,		-- Twilight Tormentor Enrage
}

function addon.CanUseAbility(abilityId)
	local result = true
	
	-- Double-click ignores the behavior
	if addon.settings.enabledoubleclick then
		local gameTimeInMilliseconds = GetGameTimeMilliseconds()
		addon.lastClicked[abilityId] = addon.lastClicked[abilityId] or 0
		
		if gameTimeInMilliseconds - addon.lastClicked[abilityId] > addon.settings.keyboardsensitivity then
			addon.lastClicked[abilityId] = gameTimeInMilliseconds
		else
			return true		-- A double-click found
		end
	end

	-- Locked
	if addon.settings.blacklist[abilityId] then
		result = false
	end
		
	-- Only in combat
	if result and addon.settings.onlyincombat[abilityId] then
		result = IsUnitInCombat("player")
	end
	
	-- Only in PvP zone
	if result and addon.settings.onlyinpvp[abilityId] then
		local zoneType = GetMapContentType()
		result = (zoneType == MAP_CONTENT_AVA or zoneType == MAP_CONTENT_BATTLEGROUND)
	end
	
	-- Once per rotation loop
	if result and addon.settings.onetimeaction[abilityId] then
		if IsUnitInCombat("player") then
			-- Ground and Channeled abilities
			if addon.abilityDuration[abilityId] then
				result = addon.abilityDuration[abilityId] == 0
			else
				-- Buff-giving abilities
				local buffId = ABILITY_BUFF_INDEX[abilityId] and ABILITY_BUFF_INDEX[abilityId] or abilityId
				for buffIndex = 1, GetNumBuffs("player") do
					local _,_,_,_,_,_,_,_,_,_,id = GetUnitBuffInfo("player", buffIndex)
					if buffId == id then
						result = false
						break
					end
				end
			end
		end
	end
	
	return result
end

-- Add Context Menu Options
function addon.AddContextMenuOption(control, abilityId)
	if control and abilityId then
		-- Locked
		if addon.settings.blacklist[abilityId] then
			local conditionText = GetString(SI_GAMEPAD_ACTIVITY_FINDER_LOCATION_LOCKED_TOOLTIP_TITLE)
			AddMenuItem(conditionText, function()
				addon.settings.blacklist[abilityId] = nil
			end)
		else
			local conditionText = ZO_DISABLED_TEXT:Colorize(GetString(SI_GAMEPAD_ACTIVITY_FINDER_LOCATION_LOCKED_TOOLTIP_TITLE))
			AddMenuItem(conditionText, function()
				addon.settings.blacklist[abilityId] = GetAbilityName(abilityId)
			end)
		end
		
		-- Once per rotation loop
		if addon.settings.onetimeaction[abilityId] then
			local conditionText = GetString(SI_SMARTCLICK_ONCE_PER_ROTATION)
			AddMenuItem(conditionText, function()
				addon.settings.onetimeaction[abilityId] = nil
			end)
		else
			local conditionText = ZO_DISABLED_TEXT:Colorize(GetString(SI_SMARTCLICK_ONCE_PER_ROTATION))
			AddMenuItem(conditionText, function()
				addon.settings.onetimeaction[abilityId] = GetAbilityName(abilityId)
			end)
		end
		
		-- Only in PvP zone
		if addon.settings.onlyinpvp[abilityId] then
			local conditionText = GetString(SI_SMARTCLICK_PVP_ONLY)
			AddMenuItem(conditionText, function()
				addon.settings.onlyinpvp[abilityId] = nil
			end)
		else
			local conditionText = ZO_DISABLED_TEXT:Colorize(GetString(SI_SMARTCLICK_PVP_ONLY))
			AddMenuItem(conditionText, function()
				addon.settings.onlyinpvp[abilityId] = GetAbilityName(abilityId)
			end)
		end		
		
		-- Only in combat
		if addon.settings.onlyincombat[abilityId] then
			local conditionText = GetString(SI_SMARTCLICK_COMBAT_ONLY)
			AddMenuItem(conditionText, function()
				addon.settings.onlyincombat[abilityId] = nil
			end)
		else
			local conditionText = ZO_DISABLED_TEXT:Colorize(GetString(SI_SMARTCLICK_COMBAT_ONLY))
			AddMenuItem(conditionText, function()
				addon.settings.onlyincombat[abilityId] = GetAbilityName(abilityId)
			end)
		end
		
		ShowMenu(control)
	end
end

local function OnEffectChanged(_, _, _, _, _, beginTimeSec, endTimeSec, _, _, _, _, _, _, _, _,abilityId)
	local startTime =  math.floor(beginTimeSec * 1000)
	local endTime =  math.floor(endTimeSec * 1000)
	addon.abilityDuration[abilityId] = endTime - startTime
end

function addon.Initialize()
	-- Hook interact controls
	ZO_PreHook("ZO_ActionBar_CanUseActionSlots", function()
		local slotNum = tonumber(debug.traceback():match('ACTION_BUTTON_(%d)'))
		local abilityId = GetSlotBoundId(slotNum)
		
		if addon.actionButtonUp[slotNum] == nil then addon.actionButtonUp[slotNum] = false
			else addon.actionButtonUp[slotNum] = not addon.actionButtonUp[slotNum]
		end
		
		if addon.actionButtonUp[slotNum] then		-- Only when button up
			if not addon.CanUseAbility(abilityId) then
				PlaySound(SOUNDS.NEGATIVE_CLICK)
				ZO_ActionBar_OnActionButtonUp(slotNum)
				return true
			end
		end
	end)
	
	-- Hook Action bar
	ZO_PreHook("ZO_AbilitySlot_OnSlotClicked", function(control, buttonId)
		if buttonId == MOUSE_BUTTON_INDEX_RIGHT then
			local button = ZO_ActionBar_GetButton(control.slotNum)
			if button then
				local slotNum = button:GetSlot()
				local slotType = GetSlotType(slotNum)
				if (slotType == ACTION_TYPE_ABILITY) and IsSlotUsed(slotNum) and not IsSlotLocked(slotNum) then
					local abilityId = GetSlotBoundId(slotNum)
					zo_callLater(function() addon.AddContextMenuOption(control, abilityId) end, 0)
				end
			end
		end
	end)
	
	-- Hook Skills manager
	ZO_PreHook("ZO_Skills_AbilitySlot_OnClick", function(control)
		local skillData = control.skillProgressionData:GetSkillData()
		if not skillData:IsPassive() and skillData:GetPointAllocator():IsPurchased() then
			local abilityId = control.skillProgressionData:GetAbilityId()
			zo_callLater(function() addon.AddContextMenuOption(control, abilityId) end, 0)
		end
	end)
	
	-- Hook Action bar assignment manager
	ZO_PreHook("ZO_KeyboardAssignableActionBarButton_OnMouseClicked", function(control, buttonId)
		if buttonId == MOUSE_BUTTON_INDEX_RIGHT then
			local hotbar = ACTION_BAR_ASSIGNMENT_MANAGER:GetCurrentHotbar()
			local slotData = hotbar:GetSlotData(control.owner.slotId)

			if slotData and not slotData:IsEmpty() then
				local abilityId = GetSlotBoundId(control.owner.slotId)
				zo_callLater(function() addon.AddContextMenuOption(control.owner.button, abilityId) end, 0)
			end
		end
	end)
	
	EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_EFFECT_CHANGED, OnEffectChanged)
end

local function OnActivated()
	addon.Initialize()
	addon.CreateSettingsMenu()
	EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_PLAYER_ACTIVATED)
end
	
-- When player is ready, after everything has been loaded
EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_PLAYER_ACTIVATED, OnActivated)

local function OnAddonLoaded(_, addonName)
	if addonName == addon.name then
		EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)
	
		-- Load saved variables
		addon.settings = ZO_SavedVars:NewAccountWide("SmartClick_Data", 1, nil, addon.settings)
	end
end		

-- When any addon is loaded
EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
