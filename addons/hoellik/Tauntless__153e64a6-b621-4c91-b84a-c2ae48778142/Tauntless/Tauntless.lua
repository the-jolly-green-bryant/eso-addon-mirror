local em                  = GetEventManager()
local _
local uiScale = 1 /GetSetting(SETTING_TYPE_UI, UI_SETTING_CUSTOM_SCALE)              --Get UI Scale to draw thin lines correctly
TAUNTLESS_UI_SCALE        = uiScale
local TIMER_UPDATE_RATE   = 200
local ActiveAbilityIdList = {}
local AbilityCopies       = {}

-- Addon Namespace
Tauntless                 = Tauntless or {}
Tauntless.Settings        = Tauntless.Settings or {}

local Tauntless           = Tauntless
Tauntless.name            = "Tauntless"
Tauntless.version         = "0.0.6"

local function Print(message, ...)
	if Tauntless.debug == false then return end
	df("[%s] %s", Tauntless.name, message:format(...))
end

local function SetBarAnimation(control, duration, sourceType, startWidth, startHeight) --This creates the bar animation (moving and color change)
	duration = duration or 15000

	local timeline = ANIMATION_MANAGER:CreateTimeline()

	timeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)

	local _, _, rel, _, x, y = control:GetAnchor()
	local anchor = { TOPLEFT, control:GetParent():GetNamedChild("Icon"), TOPRIGHT, TAUNTLESS_UI_SCALE, TAUNTLESS_UI_SCALE }

	if Tauntless.Settings.bardirection == true then anchor = { TOPRIGHT, control:GetParent():GetNamedChild("Bg"), TOPRIGHT,
	                                                 TAUNTLESS_UI_SCALE, TAUNTLESS_UI_SCALE } end

	-- Ensure control has the correct start dimensions before creating the timeline
	local sw = startWidth or control:GetWidth()
	local sh = startHeight or control:GetHeight()
	control:SetDimensions(sw, sh)

	control:ClearAnchors()
	control:SetAnchor(unpack(anchor))

	local move = timeline:InsertAnimation(ANIMATION_SIZE, control)

	move:SetStartAndEndWidth(sw, 0)
	move:SetStartAndEndHeight(sh, sh)
	move:SetDuration(duration)

	local color1 = timeline:InsertAnimation(ANIMATION_COLOR, control)

	local gradient1 = sourceType == 1 and { 0, 0.8, 0, 1, 0.7, 0.7, 0, 1 } or { 0.3, 0.5, 0.3, 1, 0.5, 0.5, 0.2, 1 }

	color1:SetColorValues(unpack(gradient1))
	color1:SetDuration(duration / 2)

	local color2 = timeline:InsertAnimation(ANIMATION_COLOR, control, duration / 2)

	local gradient2 = sourceType == 1 and { 0.7, 0.7, 0, 1, 0.8, 0, 0, 1 } or { 0.5, 0.5, 0.2, 1, 0.5, 0.3, 0.3, 1 }

	color2:SetColorValues(unpack(gradient2))
	color2:SetDuration(duration / 2)

	return timeline
end

Tauntless.SetBarAnimation = SetBarAnimation

local function OnTauntStart(key, endTime, abilityId, sourceType) -- Prepare Animation, start it and set off the timer.
	if key == nil or endTime == nil then return end
	Tauntless_TLW:SetHidden(false)

	local duration = (endTime - GetGameTimeMilliseconds())
	local item = Tauntless.Widget.pool:GetActiveObject(key)
	local unitId = item.id

	item.endTime = endTime
	item.abilityId = abilityId

	local bar = item:GetNamedChild("Bar")

	if bar.timeline then bar.timeline:PlayInstantlyToStart() end
	-- compute expected start width for the bar control (width minus icon)
	local offset = zo_round(2 / uiScale) * uiScale
	local barStartWidth = Tauntless.Settings.window.width - Tauntless.Settings.window.height - offset
	local barStartHeight = Tauntless.Settings.window.height - offset
	bar.timeline = SetBarAnimation(bar, duration, sourceType, barStartWidth, barStartHeight) -- setup with explicit start width/height
	bar.timeline:PlayFromStart()

	local timer = item:GetNamedChild("Timer")

	local function TimerUpdate() --update the timer text
		local duration = math.floor((endTime - GetGameTimeMilliseconds()) / TIMER_UPDATE_RATE) / 5

		if duration < -1 then
			Tauntless.Widget.pool:ReleaseObject(key)
			return
		end

		timer:SetText(string.format("%.1f", duration))
	end

	TimerUpdate()                                                             -- update the timer text once now

	em:RegisterForUpdate("Undaunted_Timer" .. key, TIMER_UPDATE_RATE, TimerUpdate) -- keep updating the timer text

	return key
end

function Tauntless.OnTauntEnd(key)
	if key == nil then return end

	em:UnregisterForUpdate("Undaunted_Timer" .. key)

	if Tauntless.Widget.pool ~= nil then
		local item = Tauntless.Widget.pool:GetActiveObject(key)

		if item == nil then return end

		local bar = item:GetNamedChild("Bar")
		if bar and bar.timeline then
			-- Move timeline to its end state (empty bar) so the bar isn't shown filled when taunt ends
			if bar.timeline.PlayInstantlyToEnd then
				bar.timeline:PlayInstantlyToEnd()
			elseif bar.timeline.Stop then
				bar.timeline:Stop()
				-- fallback: set control width to zero so it appears empty
				bar:SetWidth(0)
			else
				bar:SetWidth(0)
			end
			-- keep the timeline reference so future OnTauntStart can PlayInstantlyToStart() to restore full width
		end

		item:GetNamedChild("Bg"):SetEdgeColor(1, 1, 0, 0)
		item:GetNamedChild("Timer"):SetText("")
	end
end

local activeitems

local function OnTargetChange()
	if activeitems then
		for k, v in pairs(activeitems) do
			local olditem = Tauntless.Widget.pool:GetActiveObject(v)
			if olditem ~= nil then Tauntless.Widget.pool:GetActiveObject(v):GetNamedChild("Bg"):SetEdgeColor(1, 1, 0, 0) end
		end
	end

	if not DoesUnitExist("reticleover") then return end

	local endTime, abilityId

	activeitems = {}

	for i = 1, GetNumBuffs("reticleover") do
		_, _, endTime, _, _, _, _, _, _, _, abilityId, _ = GetUnitBuffInfo("reticleover", i)

		if Tauntless.Widget.endTimes[endTime] ~= nil and ActiveAbilityIdList[abilityId] then
			local key = Tauntless.Widget.endTimes[endTime]

			table.insert(activeitems, key)

			-- Print("Found buff: %s, Key: %s",GetAbilityName(abilityId),key)

			local item = Tauntless.Widget.pool:GetActiveObject(key)

			if item ~= nil then item:GetNamedChild("Bg"):SetEdgeColor(1, 1, 0, 1) end
		end
	end
end

-- EVENT_EFFECT_CHANGED (eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
local function onTaunt(_, changeType, _, _, _, beginTime, endTime, _, _, _, effectType, _, _, unitName, unitId, abilityId,
					   sourceType)
	--Print("Changetype: %s, Effecttype: %s, Times: %.3f - %.3f Ability: %s (%s)", changeType, effectType, beginTime, endTime, GetAbilityName(abilityId), unitName)
	--Print("Eval: %s and %s",tostring(changeType~=1 and changeType~=2 and changeType~=3),tostring(effectType~=2 and effectType~=1))

	if (changeType ~= EFFECT_RESULT_GAINED and changeType ~= EFFECT_RESULT_FADED and changeType ~= EFFECT_RESULT_UPDATED and effectType ~= BUFF_EFFECT_TYPE_DEBUFF and effectType ~= BUFF_EFFECT_TYPE_BUFF) or (sourceType ~= COMBAT_UNIT_TYPE_PLAYER and sourceType ~= COMBAT_UNIT_TYPE_PLAYER_PET and sourceType ~= COMBAT_UNIT_TYPE_GROUP and abilityId ~= 134599 and abilityId ~= 120014 and abilityId ~= 88401) then return end
	if changeType == 1 and abilityId == 88401 then return end

	local idkey = ZO_CachedStrFormat("<<1>>,<<2>>", unitId, abilityId)

	local key = Tauntless.Widget.tauntList[idkey]

	if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
		if Tauntless.Widget.pool:GetActiveObjectCount() >= Tauntless.Settings.maxbars then return end

		Print("Key: %s, ID: %s", tostring(key), idkey)

		if key == nil then
			key = Tauntless.Widget.NewItem(unitName, unitId, abilityId)
			Tauntless.Widget.tauntList[idkey] = key
		end

		Tauntless.Widget.endTimes[endTime] = key

		endTime = math.floor(endTime * 1000)

		OnTauntStart(key, endTime, abilityId, sourceType)

		OnTargetChange()
	elseif changeType == EFFECT_RESULT_FADED and key ~= nil then
		Tauntless.Widget.endTimes[endTime] = nil

		if Tauntless.inCombat == false then
			Tauntless.Widget.pool:ReleaseObject(key)
		else
			Tauntless.OnTauntEnd(key)
		end
	end
end

--(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

local function OnUnitDeath(_, result, _, _, _, _, _, _, targetName, targetType, _, _, _, _, _, targetUnitId, _)
	-- When a unit dies, immediately remove any active bars belonging to that unit.
	if Tauntless.Widget.pool == nil then return end

	local ActiveObjects = Tauntless.Widget.pool:GetActiveObjects()
	for key, item in pairs(ActiveObjects) do
		if item and item.id == targetUnitId then
			Tauntless.Widget.pool:ReleaseObject(key)
		end
	end
end

local function Cleanup()
	if Tauntless.inCombat == false then
		Tauntless.Widget.ClearItems()
		em:UnregisterForUpdate("Tauntless_Cleanup")
		return
	end

	local validIds = {}

	local ActiveObjects = Tauntless.Widget.pool:GetActiveObjects()

	for key, item in pairs(ActiveObjects) do
		local unitId = item.id or 0
		local endTime = item.endTime or 0

		local now = GetGameTimeMilliseconds()

		if endTime - now > -5000 then validIds[unitId] = true end
	end

	for key, item in pairs(ActiveObjects) do
		local unitId = item.id
		local abilityId = item.abilityId

		if not validIds[unitId] then
			Tauntless.Widget.pool:ReleaseObject(key)
		end
	end
end

local function OnCombatState(event, inCombat) -- called by Event
	if inCombat ~= Tauntless.inCombat then    -- Check if player state changed
		Tauntless.inCombat = inCombat

		if inCombat == true then em:RegisterForUpdate("Tauntless_Cleanup", 500, Cleanup) end
	end
end


function Tauntless.RegisterAbilities()
	local name = Tauntless.name

	for i, data in pairs(Tauntless.Settings.trackedabilities) do
		local id = data[1]

		em:UnregisterForEvent(name .. "_ability_" .. id)

		if AbilityCopies[id] then
			for _, id2 in pairs(AbilityCopies[id]) do
				local idstring = name .. "_ability_" .. id2

				em:UnregisterForEvent(name .. "_ability_" .. id2)
			end
		end
	end

	ActiveAbilityIdList = {}

	for i, data in pairs(Tauntless.Settings.trackedabilities) do
		local id, active = unpack(data)

		if active == true then
			local idstring = name .. "_ability_" .. id

			em:RegisterForEvent(idstring, EVENT_EFFECT_CHANGED, onTaunt)

			ActiveAbilityIdList[id] = true

			local addfilter = {}

			if Tauntless.Settings.trackonlyplayer and id ~= 134599 and id ~= 39100 and id ~= 52788 then -- Off Balance Immunity / Minor Magickasteal / Taunt Immune
				table.insert(addfilter, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE)
				table.insert(addfilter, COMBAT_UNIT_TYPE_PLAYER)
			end

			if id == 40224 then
				table.insert(addfilter, REGISTER_FILTER_UNIT_TAG)
				table.insert(addfilter, "player")
			end

			em:AddFilterForEvent(idstring, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, id, REGISTER_FILTER_IS_ERROR,
				false, unpack(addfilter))

			if AbilityCopies[id] then
				for _, id2 in pairs(AbilityCopies[id]) do
					local idstring = name .. "_ability_" .. id2

					ActiveAbilityIdList[id2] = true

					if id2 == 120014 or id2 == 88401 then addfilter = {} end --  Off Balance of Trial Dummy

					em:RegisterForEvent(idstring, EVENT_EFFECT_CHANGED, onTaunt)
					em:AddFilterForEvent(idstring, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, id2,
						REGISTER_FILTER_IS_ERROR, false, unpack(addfilter))
				end
			end
		end
	end

	Tauntless.activeIds = ActiveAbilityIdList -- debug exposure
end

local defaults = {
	["window"]           = { x = 150 * uiScale, y = 150 * uiScale, height = zo_round(25 / uiScale) * uiScale, width = zo_round(300 / uiScale) * uiScale },
	["showwindow"]       = false,
	["growthdirection"]  = false, --false=down
	["maxbars"]          = 15, --false=down
	["bardirection"]     = false, --false=to the left
	["accountwide"]      = true,
	["trackonlyplayer"]  = true,
	["trackedabilities"] = {
		{ 38541,  true }, -- Taunt
		{ 52788,  true }, -- Taunt Immunity
		}
}

AbilityCopies = {
	-- Taunt
	[38541] = { 38254 },

}


-- Initialization
function Tauntless:Initialize(event, addon)
	local name = self.name

	if addon ~= name then return end --Only run if this addon has been loaded

	-- load saved variables

	local SaveIdString = self.name .. "_Save"

	Tauntless.Settings = ZO_SavedVars:NewAccountWide(SaveIdString, 7, nil, defaults)

	if Tauntless.Settings.accountwide == false then
		Tauntless.Settings = ZO_SavedVars:NewCharacterIdSettings(SaveIdString, 7, nil, defaults)
		Tauntless.Settings.accountwide = false
	end


	self.debug = false
	self.db = Tauntless.Settings

	Tauntless.RegisterAbilities()

	--register Events
	em:UnregisterForEvent(name .. "_load", EVENT_ADD_ON_LOADED)

	em:RegisterForEvent(name .. "_unit", EVENT_COMBAT_EVENT, OnUnitDeath)
	em:AddFilterForEvent(name .. "_unit", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, 2260,
		REGISTER_FILTER_IS_ERROR, false)                                                                                       -- not needed?

	em:RegisterForEvent(name .. "_unit2", EVENT_COMBAT_EVENT, OnUnitDeath)
	em:AddFilterForEvent(name .. "_unit2", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, 2262,
		REGISTER_FILTER_IS_ERROR, false)

	em:RegisterForEvent(name .. "_combat", EVENT_PLAYER_COMBAT_STATE, OnCombatState)
	em:RegisterForEvent(name .. "_target", EVENT_RETICLE_TARGET_CHANGED, OnTargetChange)


	self.playername = zo_strformat("<<!aC:1>>", GetUnitName("player"))
	self.inCombat = IsUnitInCombat("player")

	Tauntless.Menu.create(defaults, uiScale, Tauntless.Settings)

	local window = Tauntless_TLW

	local anchorside = Tauntless.Settings.growthdirection and BOTTOMLEFT or TOPLEFT

	if (Tauntless.Settings.window) then
		window:ClearAnchors()
		window:SetAnchor(anchorside, GuiRoot, anchorside, Tauntless.Settings.window.x, Tauntless.Settings.window.y)
	end

	-- Drag-and-drop not supported on console; no move handler

	Tauntless.Widget.lastAnchor = { anchorside, window, anchorside, zo_round(4 / uiScale) * uiScale, zo_round(4 / uiScale) * uiScale }

	if Tauntless.Settings.showwindow then
		Tauntless_TLW:SetHidden(false)
		Tauntless.Widget.ShowItems(Tauntless.Menu.Panel)
	else
		if Tauntless_TLW then Tauntless_TLW:SetHidden(true) end
	end

	zo_callLater(Tauntless.Widget.ClearItems, 1)
end

-- Finally, we'll register our event handler function to be called when the proper event occurs.
em:RegisterForEvent(Tauntless.name .. "_load", EVENT_ADD_ON_LOADED, function(...) Tauntless:Initialize(...) end)