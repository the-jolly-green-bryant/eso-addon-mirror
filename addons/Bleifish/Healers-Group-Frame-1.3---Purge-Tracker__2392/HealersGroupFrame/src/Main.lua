--[[--------------------------------------------------------
	HealersGroupFrame
------------------------------------------------------------
	* AddOn to help identify who needs help
	*
	* Author: @ShaiT
	* Modified by @Bleifish  (EU)
	*
]]----------------------------------------------------------

HGF = {}
HGF.name = "HealersGroupFrame"
HGF.version = "1.3"
HGF.savedVarsVersion = 1.0

HGF.savedVars = {}
HGF.activeVars = {}

HGF.unitTags = {}
HGF.moveModeEnabled = false
HGF.firstUnit = nil

HGF.textNone = 0
HGF.textName = 1
HGF.textHPPerc = 2
HGF.textHPLeft = 3
HGF.textHPLost = 4
HGF.textHPLeftMax = 5
HGF.textShield = 6

function deepcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[deepcopy(orig_key)] = deepcopy(orig_value)
		end
		setmetatable(copy, deepcopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

function HGF.PrintUnitList(initString)
	local iterator = HGF.firstUnit
	local unitString = "" .. initString .. " : "
	while iterator ~= nil do
		unitString = unitString .. iterator.unitTag .. "->"
		iterator = iterator.next
	end
	d(unitString)
end

function HGF.PrintNameList(initString)
	local iterator = HGF.firstUnit
	local nameString = "" .. initString .. " : "
	while iterator ~= nil do
		nameString = nameString .. GetRawUnitName(iterator.unitTag) .. "->"
		iterator = iterator.next
	end
	d(nameString)
end

function HGF.CommandHandler(text)
	if text == "list_unittags" then
		HGF.PrintUnitList("")
	elseif text == "list_names" then
		HGF.PrintNameList("")
	elseif text == "presets" then
		d("NbrPresets: " .. HGF.savedVars["nbrPresets"])
	end
end

function HGF.ToggleMoveMode()
	HGF.moveModeEnabled = not HGF.moveModeEnabled
	if HGF.moveModeEnabled then
		-- Enable move mode
		HGF.UI.HideAnchor(false)
		HGF.UI.HideFrames(true)
	else
		-- Disable move mode
		HGF.UI.HideAnchor(true)
		HGF.UI.HideFrames(IsReticleHidden())
	end
end

function HGF.UpdateVolatileUnitInfo(unitTag)
	if HGF.unitTags[unitTag] == nil then
		return end

	if IsUnitOnline(unitTag) then
		if IsUnitDead(unitTag) then
			HGF.UI.SetUnitDead(unitTag)
		else
			local currentHp, maxHp, effectiveMaxHp, value, maxValue, healthRegen, shield

			currentHp, maxHp, effectiveMaxHp = GetUnitPower(unitTag, POWERTYPE_HEALTH)
			value, maxValue = GetUnitAttributeVisualizerEffectInfo(unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH)
			healthRegen = value or 0
			value, maxValue = GetUnitAttributeVisualizerEffectInfo(unitTag, ATTRIBUTE_VISUAL_POWER_SHIELDING, STAT_MITIGATION, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH)
			shield = value or 0
			
			HGF.UI.UpdateUnitHealth(unitTag, currentHp, maxHp, shield)
			HGF.UI.SetHealthRegen(unitTag, healthRegen)			
			HGF.UI.SetUnitStealth(unitTag, GetUnitStealthState(unitTag))
			HGF.UI.SetPurge(unitTag)
		end
		HGF.UI.UpdateUnitWithinRange(unitTag, IsUnitInGroupSupportRange(unitTag))
	else
		HGF.UI.UpdateUnitWithinRange(unitTag, false)
		HGF.UI.SetUnitOffline(unitTag)
	end
end

function HGF.MoveUnitSwap(unitTag, x, y)
	if HGF.firstUnit == nil then
		return end

	local toUnit = nil
	local fromUnit = nil
	local iterator = HGF.firstUnit

	while iterator ~= nil do
		if iterator.unitTag == unitTag then
			fromUnit = iterator
		elseif HGF.UI.DoesContain(iterator.unitTag, x, y) then
			toUnit = iterator
		end
		iterator = iterator.next
	end
	if toUnit ~= nil and fromUnit ~= nil then
		tempTag = toUnit.unitTag
		tempName = toUnit.unitTag
		toUnit.unitTag = fromUnit.unitTag
		toUnit.rawName = fromUnit.rawName
		fromUnit.unitTag = tempTag
		fromUnit.rawName = tempName
	elseif unitTag == HGF.firstUnit.unitTag then
		HGF.UI.SetMainAnchorPosToUnit(unitTag)
	end
end

function HGF.MoveUnitBeforeAfter(unitTag, x, y)
	if HGF.firstUnit == nil then
		return end

	local toUnit = nil
	local fromUnit = nil
	local iterator = HGF.firstUnit

	while iterator ~= nil do
		if iterator.unitTag == unitTag then
			fromUnit = iterator
		elseif HGF.UI.DoesContain(iterator.unitTag, x, y) then
			toUnit = iterator
		end
		iterator = iterator.next
	end

	if toUnit ~= nil and fromUnit ~= nil and toUnit.unitTag ~= fromUnit.unitTag then
		local insertBefore
		if HGF.UI.IsAboveCenter(toUnit.unitTag, y) then
			insertBefore = (HGF.activeVars["growDirV"] == "down")
		else
			insertBefore = (HGF.activeVars["growDirV"] == "up")
		end
		-- Remove fromUnit from list
		iterator = HGF.firstUnit
		if fromUnit.unitTag == iterator.unitTag then
			HGF.firstUnit = iterator.next
		else
			while iterator.next ~= nil do
				if iterator.next.unitTag == fromUnit.unitTag then
					iterator.next = iterator.next.next
					break
				end
				iterator = iterator.next
			end
		end
		-- Add fromUnit to list
		iterator = HGF.firstUnit
		if insertBefore then
			if iterator.unitTag == toUnit.unitTag then
				fromUnit.next = iterator
				HGF.firstUnit = fromUnit
			else
				while iterator.next ~= nil do
					if iterator.next.unitTag == toUnit.unitTag then
						fromUnit.next = iterator.next
						iterator.next = fromUnit
						break
					end
					iterator = iterator.next
				end
			end
		else
			while iterator ~= nil do
				if iterator.unitTag == toUnit.unitTag then
					fromUnit.next = iterator.next
					iterator.next = fromUnit
					break
				end
				iterator = iterator.next
			end
		end
	elseif unitTag == HGF.firstUnit.unitTag then
		HGF.UI.SetMainAnchorPosToUnit(unitTag)
	end
end

function HGF.UnitDropped(unitTag, x, y)
	--HGF.MoveUnitSwap(unitTag, x, y)
	HGF.MoveUnitBeforeAfter(unitTag, x, y)
	HGF.UI.LayoutFrames(HGF.firstUnit)
end

function HGF.RemoveFromList(unitTag)
	if HGF.firstUnit == nil then
		return false
	end

	if HGF.firstUnit.unitTag == unitTag then
		HGF.firstUnit = HGF.firstUnit.next
		return true
	else
		local iterator = HGF.firstUnit
		while iterator.next ~= nil and iterator.next.unitTag ~= unitTag do
			iterator = iterator.next
		end
		if iterator.next ~= nil then
			iterator.next = iterator.next.next
			return true
		end
	end

	return false
end

function HGF.AddToList(unitTag)
	unit = {}
	unit.rawName = GetRawUnitName(unitTag)
	unit.unitTag = unitTag
	unit.next = nil
	if HGF.firstUnit == nil then
		HGF.firstUnit = unit
		return true
	else
		iterator = HGF.firstUnit
		while iterator.unitTag ~= unit.unitTag and iterator.next ~= nil do
			iterator = iterator.next
		end
		if iterator.unitTag ~= unit.unitTag then
			iterator.next = unit
			return true
		end
	end

	return false
end

function HGF.SyncUnitList(forceLayout)
	local iterator
	local nameTable
	local changed = false

	-- Create unitName -> unitTag table
	nameTable = {}
	for unitTag in pairs(HGF.unitTags) do
		if DoesUnitExist(unitTag) then
			nameTable[GetRawUnitName(unitTag)] = unitTag
		end
	end

	-- Update unitTag to correspond to correct unitName
	iterator = HGF.firstUnit
	while iterator ~= nil do
		if iterator.unitTag ~= nameTable[iterator.rawName] then
			iterator.unitTag = nameTable[iterator.rawName]
			changed = true
		end
		iterator = iterator.next
	end

	for unitTag in pairs(HGF.unitTags) do
		local ret
		if DoesUnitExist(unitTag) then
			ret = HGF.AddToList(unitTag)
			HGF.UI.EnableUnitFrame(unitTag)
			HGF.UI.UpdateUnitName(unitTag, GetUnitName(unitTag))
			HGF.UpdateVolatileUnitInfo(unitTag)
			HGF.UI.SetUnitStealth(unitTag, GetUnitStealthState(unitTag))
		else
			ret = HGF.RemoveFromList(unitTag)
			HGF.UI.DisableUnitFrame(unitTag)
		end
		if ret then
			changed = true
		end
	end

	HGF.UI.SetUnitLeader(GetGroupLeaderUnitTag())
	if changed or forceLayout then
		HGF.UI.LayoutFrames(HGF.firstUnit)
	end
end

function HGF.SetActivePreset(preset)
	if preset < 0 or preset > HGF.savedVars["nbrPresets"] then
		d("Tried setting an invalid preset!")
		return
	end
	HGF.savedVars["activePreset"] = preset
	HGF.activeVars = HGF.savedVars["presets"][preset]
	HGF.UI.ApplySettings()
	HGF.SyncUnitList(true)
end

function HGF.ChangePreset()
	if HGF.savedVars["activePreset"] == HGF.savedVars["nbrPresets"] then
		HGF.SetActivePreset(1)
	else
		HGF.SetActivePreset(HGF.savedVars["activePreset"] + 1)
	end
end

function HGF.CreatePreset()
	local newPresetNbr = HGF.savedVars["nbrPresets"] + 1
	local copyFrom = HGF.savedVars["presets"][HGF.savedVars["activePreset"]]
	local newPresetData

	newPresetData = deepcopy(copyFrom)
	newPresetData["presetName"] = "New Preset"
	HGF.savedVars["presets"][newPresetNbr] = newPresetData
	HGF.savedVars["nbrPresets"] = newPresetNbr
	return newPresetNbr
end

function HGF.RemovePreset(preset)
	if HGF.savedVars["nbrPresets"] == 1 or preset < 0 or preset > HGF.savedVars["nbrPresets"] then
		return
	end
	table.remove(HGF.savedVars["presets"], preset)
	HGF.savedVars["nbrPresets"] = HGF.savedVars["nbrPresets"] - 1
	if preset == HGF.savedVars["activePreset"] and preset > 1 then
		HGF.SetActivePreset(HGF.savedVars["activePreset"] - 1)
	end
end

--integer eventCode, string leaderTag
function HGF.OnLeaderUpdate(eventCode, leaderTag)
	HGF.UI.SetUnitLeader(leaderTag)
end

--integer eventCode, string unitTag, bool status
function HGF.OnGroupSupportRangeUpdate(eventCode, unitTag, status)
	HGF.UI.UpdateUnitWithinRange(unitTag, status)
end

--integer eventCode
function HGF.OnGroupUpdate(eventCode)
	HGF.SyncUnitList(false)
end

--integer eventCode, string unitTag, bool isOnline
function HGF.OnGroupMemberConnectedStatus(eventCode, unitTag, isOnline)
	HGF.UpdateVolatileUnitInfo(unitTag)
end

--integer eventCode, string unitTag, integer powerIndex, integer powerType, integer powerValue, integer powerMax, integer powerEffectiveMax
function HGF.OnPowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
	HGF.UpdateVolatileUnitInfo(unitTag)
end

--integer eventCode, string unitTag
function HGF.OnUnitCreated(eventCode, unitTag)
	HGF.SyncUnitList(false)
end

--integer eventCode, string unitTag
function HGF.OnUnitDestroyed(eventCode, unitTag)
	-- Check if unit was actually removed or if this was just due to zoning
	HGF.SyncUnitList(false)
end

--integer eventCode, string unitTag, bool isDead
function HGF.OnDeathStateChanged(eventCode, unitTag, isDead)
	HGF.UpdateVolatileUnitInfo(unitTag)
end

--integer eventCode, string zoneName, string subZoneName, bool newSubzone
function HGF.OnZoneChanged(eventCode, zoneName, subZoneName, newSubzone)
	HGF.SyncUnitList(false)
end

--integer eventCode, string unitTag, string newZoneName
function HGF.OnZoneUpdate(eventCode, unitTag, newZoneName)
	-- I assume this means that the zone of unitTag is updated, so they might now be in range but also online
	HGF.UpdateVolatileUnitInfo(unitTag)
end

--integer eventCode, string unitTag
function HGF.OnUnitFrameUpdate(eventCode, unitTag)
	-- What does this event mean? Seems related to unitTag so update that one.
	HGF.UpdateVolatileUnitInfo(unitTag)
end

--integer eventCode, string unitTag, integer unitAttributeVisual, integer statType, integer attributeType, integer powerType, number value, number maxValue
function HGF.OnVisualAttributeAdded(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue)
	if powerType == POWERTYPE_HEALTH then
		HGF.UpdateVolatileUnitInfo(unitTag)
	end
end

--integer eventCode, string unitTag, integer unitAttributeVisual, integer statType, integer attributeType, integer powerType, number value, number maxValue
function HGF.OnVisualAttributeRemoved(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue)
	if powerType == POWERTYPE_HEALTH then
		HGF.UpdateVolatileUnitInfo(unitTag)
	end
end

--integer eventCode, string unitTag, integer unitAttributeVisual, integer statType, integer attributeType, integer powerType, number oldValue, number newValue, number oldMaxValue, number newMaxValue
function HGF.OnVisualAttributeUpdated(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, oldValue, newValue, oldMaxValue, newMaxValue)
	if powerType == POWERTYPE_HEALTH then
		HGF.UpdateVolatileUnitInfo(unitTag)
	end
end

function HGF.OnUpdate(eventCode)
	for unitTag in pairs(HGF.unitTags) do
		if DoesUnitExist(unitTag) then
			HGF.UpdateVolatileUnitInfo(unitTag)
		end
	end
end

--integer eventCode, integer layerIndex, integer activeLayerIndex
function HGF.OnActionLayerPopped(eventCode, layerIndex, activeLayerIndex)
	local hidden = activeLayerIndex > 2
	if not HGF.moveModeEnabled then
		HGF.UI.HideFrames(hidden)
	end
end

--integer eventCode, integer layerIndex, integer activeLayerIndex
function HGF.OnActionLayerPushed(eventCode, layerIndex, activeLayerIndex)
	local hidden = activeLayerIndex > 2
	if not HGF.moveModeEnabled then
		HGF.UI.HideFrames(hidden)
	end
end

--integer eventCode, string unitTag, integer stealthState
function HGF.OnStealthStateChanged(eventCode, unitTag, stealthState)
	HGF.UI.SetUnitStealth(unitTag, stealthState)
end

function HGF.RegisterEvents()
	EVENT_MANAGER:RegisterForEvent(HGF.name, EVENT_UNIT_CREATED, HGF.OnUnitCreated)
	EVENT_MANAGER:RegisterForEvent(HGF.name, EVENT_UNIT_DESTROYED, HGF.OnUnitDestroyed)
	EVENT_MANAGER:RegisterForEvent(HGF.name, EVENT_LEADER_UPDATE, HGF.OnLeaderUpdate)
	EVENT_MANAGER:RegisterForEvent(HGF.name, EVENT_GROUP_UPDATE, HGF.OnGroupUpdate)
	EVENT_MANAGER:RegisterForEvent(HGF.name, EVENT_ZONE_CHANGED, HGF.OnZoneChanged)

	EVENT_MANAGER:RegisterForEvent(HGF.name, EVENT_UNIT_DEATH_STATE_CHANGED, HGF.OnDeathStateChanged)
	EVENT_MANAGER:RegisterForEvent(HGF.name, EVENT_GROUP_MEMBER_CONNECTED_STATUS, HGF.OnGroupMemberConnectedStatus)
	EVENT_MANAGER:RegisterForEvent(HGF.name, EVENT_GROUP_SUPPORT_RANGE_UPDATE, HGF.OnGroupSupportRangeUpdate)
	EVENT_MANAGER:RegisterForEvent(HGF.name, EVENT_POWER_UPDATE, HGF.OnPowerUpdate)
	EVENT_MANAGER:RegisterForEvent(HGF.name, EVENT_ZONE_UPDATE, HGF.OnZoneUpdate)
	EVENT_MANAGER:RegisterForEvent(HGF.name, EVENT_UNIT_FRAME_UPDATE, HGF.OnUnitFrameUpdate)

	EVENT_MANAGER:RegisterForEvent(HGF.name, EVENT_STEALTH_STATE_CHANGED, HGF.OnStealthStateChanged)

	EVENT_MANAGER:RegisterForEvent(HGF.name, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, HGF.OnVisualAttributeAdded)
	EVENT_MANAGER:RegisterForEvent(HGF.name, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, HGF.OnVisualAttributeRemoved)
	EVENT_MANAGER:RegisterForEvent(HGF.name, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, HGF.OnVisualAttributeUpdated)

	EVENT_MANAGER:RegisterForEvent(HGF.name, EVENT_ACTION_LAYER_POPPED, HGF.OnActionLayerPopped)
	EVENT_MANAGER:RegisterForEvent(HGF.name, EVENT_ACTION_LAYER_PUSHED, HGF.OnActionLayerPushed)

	-- Use this as a fail safe
	EVENT_MANAGER:RegisterForUpdate(HGF.name, 1000, HGF.OnUpdate)
end

function HGF.CreateUnit(unitTag)
	HGF.UI.AddUnitFrame(unitTag)
	HGF.unitTags[unitTag] = true
end

function HGF.CreateAllUnits()
	-- Add player for testing, will cause issues when in group
	--HGF.CreateUnit("player")

	for i = 1, 24, 1 do
		HGF.CreateUnit("group"..i)
	end
	HGF.UI.ApplySettings()
	HGF.UI.LayoutFrames(HGF.firstUnit)
end

function HGF.Initialize()
	local defaultVars = {
		["Language"] = "English",
		["nbrPresets"] = 1,
		["activePreset"] = 1,
		["presets"] = {
			[1] = {
				["presetName"] = "Main Preset",
				["MW_Pos"] = {20, 20},
				["maxPerCol"] = 4,
				["growDirV"] = "down",
				["growDirH"] = "right",
				["textType"] = { HGF.textName, HGF.textNone, HGF.textHPLeft, HGF.textHPPerc },
				["frameDistance"] = 1,
				["frameWidth"] = 140,
				["frameHeight"] = 45,
				["inRangeAlpha"] = 1,
				["outOfRangeAlpha"] = 0.5,
				["showLeaderIcon"] = true,
				["showStealthIndicator"] = false,
				["showShieldIndicator"] = true,
				["showHealthRegen"] = true,
				["healthBarColor"] = {1, 0, 0},
				["incHealthRegenColor"] = {1, 0.9, 0},
				["decHealthRegenColor"] = {0.5, 0.1, 0.1},
				["shieldColor"] = {0, 0.5, 1},
				["textColor"] = {0.9, 0.9, 0.9},
				["font"] = "ZoFontGame",
				["frame_texture"] = "/HealersGroupFrame/art/unit_frame.dds",
				["truncateValues"] = false,
				["shieldAsHp"] = false,
				["thousandSeparator"] = "",
				["truncateDecimals"] = 1
			}
		}
	}

	SLASH_COMMANDS["/hgf_debug"] = HGF.CommandHandler

	-- Load saved variables
	HGF.savedVars = ZO_SavedVars:NewAccountWide("HealersGroupFrameSave", HGF.savedVarsVersion, nil, defaultVars)
	HGF.activeVars = HGF.savedVars["presets"][HGF.savedVars["activePreset"]]

	HGF.UI.Initialize()
	HGF.Menu.Initialize()
	HGF.CreateAllUnits()
	HGF.SyncUnitList(true)
	HGF.RegisterEvents()
	HGF.UI.HideAnchor(true)
	HGF.UI.HideFrames(false)

	EVENT_MANAGER:UnregisterForEvent(HGF.name, EVENT_ADD_ON_LOADED)
end

function OnAddOnLoaded(eventCode, addOnName)
	if(addOnName == HGF.name) then
		HGF.Initialize()
	end
end

EVENT_MANAGER:RegisterForEvent(HGF.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
