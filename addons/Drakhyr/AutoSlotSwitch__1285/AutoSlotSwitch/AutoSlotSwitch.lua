AutoSlotSwitch = AutoSlotSwitch or {}
local ASS = AutoSlotSwitch
local EM = EVENT_MANAGER
local LAM = LibAddonMenu2

ASS.name = "AutoSlotSwitch"
--ASS.version = "0.6"
--ASS.versionNum = tonumber(ASS.version)
ASS.initialised = false

-- Set-up the defaults options for saved variables.
ASS.defaults = {
	Enabled = true,
	DungeonEnabled = false,
	PVPEnabled = false,
	InCombat = false,
	UnderAttackEnabled = false,
	UnderAttack = false,
	SlotPos = 12,
	PVPSlotPos = 12,
	DungeonSlotPos = 12,
	Slot_previous = 12,
	DesiredPotionType = "Health",
	DungeonDesiredPotionType = "Health",
	PVPDesiredPotionType = "Health",
	SearchEnabled = true,
	DungeonSearchEnabled = true,
	PVPSearchEnabled = true,
	DungeonIgnore = false,
	TempLock = false,
	SlotChangedManually = true,
	LockNotification = false,
	Debug = false,
	TempDuration = 6,
	RestartTempLock = false,
	HealthThresholdEnabled = false,
	HealthThreshold = 0.5,
}

--///////////////////////////////////////////////////////////////////////////////
local currentHealthPercentage = 1
local belowThreshold = false


--search quickslots. does item name contain e.g. "health"? 
local function findSlot(searchstring, currentTargetSlotPos) --provide the preset target slot to fall back to
	-- local first = ACTION_BAR_FIRST_UTILITY_BAR_SLOT + 1
	local first = 1
	-- local last = ACTION_BAR_FIRST_UTILITY_BAR_SLOT+ACTION_BAR_UTILITY_BAR_SIZE
	local last = ACTION_BAR_UTILITY_BAR_SIZE
	for i=first,last do
		if (GetSlotItemCount(i,HOTBAR_CATEGORY_QUICKSLOT_WHEEL) ~= nil) then 
			if (GetSlotItemCount(i,HOTBAR_CATEGORY_QUICKSLOT_WHEEL) > 0) then 
				if (string.find(GetSlotName(i,HOTBAR_CATEGORY_QUICKSLOT_WHEEL), tostring(searchstring))) then
					--d(GetSlotName(i).." found one at position "..i)
					return i
				end
			end
			if (i == last) then
				--d("No spare consumable found. Going to the empty slot anyway.") --better UX in my opinion than staying at a stone treb slot resulting in a yellow circle on the ground when hitting the key
				return currentTargetSlotPos
			end
		end
    end
end

local function setSlot(v)
	if (ASS.UnderAttackEnabled) then
		if ASS.UnderAttack and not ASS.HealthThresholdEnabled then
			SetCurrentQuickslot(v)
		elseif ASS.UnderAttack and ASS.HealthThresholdEnabled then
			if not belowThreshold then
				SetCurrentQuickslot(ASS.Slot_previous)
			else
				SetCurrentQuickslot(v)
			end
		end
	else
		SetCurrentQuickslot(v)
	end
end

--remap source code numbering to user friendly '1 to ACTION_BAR_UTILITY_BAR_SIZE'
--startDiff might need to be changed in future versions of the game but it can't be helped. Starting a 'clock' at 4 o'clock is not user friendly. I will update this when it changes.
function ASS.remapGET(slotpos)
	local startDiff = -3
	slotpos = slotpos - ACTION_BAR_UTILITY_BAR_SIZE + startDiff
	if slotpos < 1 then
		slotpos = slotpos + ACTION_BAR_UTILITY_BAR_SIZE
	end
	return slotpos
end

function ASS.remapSET(slotpos, value)
	--remap user friendly '1 to ACTION_BAR_UTILITY_BAR_SIZE' to source code numbering
	local startDiff = -3
	value = ACTION_BAR_UTILITY_BAR_SIZE + startDiff - value
	if value < 1 then
		value = value + ACTION_BAR_UTILITY_BAR_SIZE
	end
	if (slotpos == "SlotPos") then
		ASS.savedVariables.SlotPos = value
		ASS.SlotPos = value
	elseif (slotpos == "DungeonSlotPos") then
		ASS.savedVariables.DungeonSlotPos = value
		ASS.DungeonSlotPos = value
	elseif (slotpos == "PVPSlotPos") then
		ASS.savedVariables.PVPSlotPos = value
		ASS.PVPSlotPos = value
	end
end

local function slotChange()
	if ASS.InCombat then
		local isPVPdungeon = false
		if (GetMapType() == MAPTYPE_SUBZONE and IsPlayerInAvAWorld()) then
			isPVPdungeon = true
		end
		local ignoreDungeon = false
		if (isPVPdungeon and ASS.DungeonIgnore) then
			ignoreDungeon = true
		end
		if (ASS.DungeonEnabled and GetMapType() == MAPTYPE_SUBZONE and not ignoreDungeon) then 
			if (GetSlotItemCount(ASS.DungeonSlotPos,HOTBAR_CATEGORY_QUICKSLOT_WHEEL) ~= nil and GetSlotItemCount(ASS.DungeonSlotPos,HOTBAR_CATEGORY_QUICKSLOT_WHEEL) < 1 and ASS.DungeonSearchEnabled) then 
				--d("Empty. Searching in other slots for: "..ASS.DungeonDesiredPotionType)
				setSlot(findSlot(ASS.DungeonDesiredPotionType, ASS.DungeonSlotPos))
			else
				setSlot(ASS.DungeonSlotPos)
			end
		elseif (ASS.PVPEnabled and IsPlayerInAvAWorld()) then
			if (GetSlotItemCount(ASS.PVPSlotPos,HOTBAR_CATEGORY_QUICKSLOT_WHEEL) ~= nil and GetSlotItemCount(ASS.PVPSlotPos,HOTBAR_CATEGORY_QUICKSLOT_WHEEL) < 1 and ASS.PVPSearchEnabled) then 
				--d("Empty. Searching in other slots for: "..ASS.PVPDesiredPotionType)
				setSlot(findSlot(ASS.PVPDesiredPotionType, PVPSlotPos))
			else
				setSlot(ASS.PVPSlotPos)
			end
		else --if both are not set just use the general target slot for everything
			if (GetSlotItemCount(ASS.SlotPos,HOTBAR_CATEGORY_QUICKSLOT_WHEEL) ~= nil and GetSlotItemCount(ASS.SlotPos,HOTBAR_CATEGORY_QUICKSLOT_WHEEL) < 1 and ASS.SearchEnabled) then 
				--d("Empty. Searching in other slots for: "..ASS.DesiredPotionType)
				setSlot(findSlot(ASS.DesiredPotionType, ASS.SlotPos))
			else
				setSlot(ASS.SlotPos)
			end
		end
	else
		--reset to previous slot if UA is disabled
		setSlot(ASS.Slot_previous)
		--d("not in combat. slot now: "..GetCurrentQuickslot())
	end
end

--Temporary slot lock
--////////////////////////////////////////////////////

local tempLockId = "ASS_TempSlotLock"

local function tempLock()
	EVENT_MANAGER:UnregisterForUpdate(tempLockId)
	ASS.TempLock = false
	slotChange()
	if (ASS.LockNotification) then PlaySound(SOUNDS.VOICE_CHAT_MENU_CHANNEL_JOINED) end
end

--if a siege weapon is chosen the player has a few seconds to deploy it (ignoring all triggers to switch slots)
local function TemporarySlotLock() 
	EVENT_MANAGER:UnregisterForUpdate(tempLockId)
	ASS.TempLock = true
	EVENT_MANAGER:RegisterForUpdate(tempLockId, ASS.TempDuration*1000, tempLock)
end


--///////////////////////////////////////////////////////////////////////////////
--Event handler

local function OnPlayerCombatState(event, inCombat)
	if inCombat then
		if (not ASS.TempLock) then
			ASS.Slot_previous = GetCurrentQuickslot()
		end
	else
		ASS.UnderAttack = false
	end
	if inCombat ~= ASS.InCombat then
		ASS.InCombat = inCombat
		if (not ASS.TempLock) then
			slotChange()
		end
	end
end

-- will be called on both manual changes and calls via script
local function OnSlotChanged (event, slotId)
	if ASS.InCombat then
		--was it an automatic or a manual change?
		--if the current slot is what was set as the combat slot then it was automatic
		local currentSlot = GetCurrentQuickslot()
		if (ASS.DungeonEnabled and GetMapType() == MAPTYPE_SUBZONE and not ignoreDungeon) then 
			if currentSlot == ASS.DungeonSlotPos then
				SlotChangedManually = false
			else
				SlotChangedManually = true
			end
		elseif (ASS.PVPEnabled and IsPlayerInAvAWorld()) then
			if currentSlot == ASS.PVPSlotPos then
				SlotChangedManually = false
			else
				SlotChangedManually = true
			end
		else
			if currentSlot == ASS.SlotPos or currentSlot == ASS.Slot_previous then
				SlotChangedManually = false
			else
				SlotChangedManually = true
			end
		end
		if (SlotChangedManually) then
			TemporarySlotLock()
		else
			--manually changing back to default position aborts templock
			ASS.TempLock = false
			EVENT_MANAGER:UnregisterForUpdate(tempLockId)
		end
	end
end

local function OnCombatEvent (event, resultInt, isError, abilityName, abilityGraphicInt, abilityActionSlotTypeInt, sourceName, sourceTypeInt, targetName, targetTypeInt, hitValueInt, powerTypeInt, damageTypeInt, isLogged, sourceUnitId, targetUnitId, abilityId)
	-- 	d("ResultInt: "..resultInt..", SourceType: "..sourceTypeInt..", Hitvalue: "..hitValueInt..", PowerType: "..powerTypeInt..", DamageType: "..damageTypeInt)
	-- end
	if (not ASS.TempLock) then
		-- if (ASS.InCombat and not ASS.UnderAttack) then
		if ASS.InCombat then
			if hitValueInt > 10 and hitValueInt < 100000 and sourceName ~= "" and sourceName ~= nil and sourceName ~= GetRawUnitName("player") then
				--d("SourceName: "..sourceName..", SourceType: "..sourceTypeInt..", Hitvalue: "..hitValueInt)
				ASS.UnderAttack = true
				slotChange()
			end
		end
	end
end

local function onItemUsed(eventCode, itemSoundCategory)
	--if itemSoundCategory == ITEM_SOUND_CATEGORY_POTION then
		--d("Potion used")
	--end
	if itemSoundCategory == ITEM_SOUND_CATEGORY_SIEGE then
		TemporarySlotLock()
	end
	if itemSoundCategory == ITEM_SOUND_CATEGORY_REPAIR_KIT then
		TemporarySlotLock()
	end
end



local function OnPowerEvent(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
		--d("Index: "..tostring(powerIndex)..", type: "..tostring(powerType)..", val: "..tostring(powerValue)..", max: "..tostring(powerMax)..", effmax: "..tostring(powerEffectiveMax))
	if not ASS.UnderAttackEnabled then return end
	if (powerValue ~= nil and powerMax ~= nil and powerMax > 0) then
			currentHealthPercentage = powerValue / powerMax
			if currentHealthPercentage < ASS.HealthThreshold then
				belowThreshold = true
			else
				belowThreshold = false
				if not ASS.TempLock and ASS.InCombat then
					slotChange()
				end
			end
	end
end

--////////////////////////////////////////////////////

function ASS.DungeonToggle()
	if (ASS.DungeonEnabled) then
		ASS.DungeonEnabled = false
		ASS.savedVariables.DungeonEnabled = false
	else
		ASS.DungeonEnabled = true
		ASS.savedVariables.DungeonEnabled = true
	end
end

function ASS.PVPToggle()
	if (ASS.PVPEnabled) then
		ASS.PVPEnabled = false
		ASS.savedVariables.PVPEnabled = false
	else
		ASS.PVPEnabled = true
		ASS.savedVariables.PVPEnabled = true
	end
end

function ASS.toggleUnderAttack(value)
	if value then
		ASS.UnderAttackEnabled = true
		ASS.savedVariables.UnderAttackEnabled = true
		EM:RegisterForEvent(ASS.name, EVENT_COMBAT_EVENT, OnCombatEvent)
		EM:AddFilterForEvent(ASS.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
	else
		ASS.UnderAttackEnabled = false
		ASS.savedVariables.UnderAttackEnabled = false
		EM:UnregisterForEvent(ASS.name, EVENT_COMBAT_EVENT)
		ASS.toggleHealthThreshold(value)
	end
end

function ASS.toggleRestartTempLock(value)
	if value then
		ASS.RestartTempLock = true
		ASS.savedVariables.RestartTempLock = true
		EM:RegisterForEvent(ASS.name, EVENT_INVENTORY_ITEM_USED, onItemUsed)
	else
		ASS.RestartTempLock = false
		ASS.savedVariables.RestartTempLock = false
		EM:UnregisterForEvent(ASS.name, EVENT_INVENTORY_ITEM_USED)
	end
end

function ASS.toggleHealthThreshold(value)
	if not ASS.savedVariables.UnderAttackEnabled then value = false end
	if value then
		ASS.HealthThresholdEnabled = true
		ASS.savedVariables.HealthThresholdEnabled = true
		EM:RegisterForEvent(ASS.name, EVENT_POWER_UPDATE, OnPowerEvent)
		EM:AddFilterForEvent(ASS.name, EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
		EM:AddFilterForEvent(ASS.name, EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, POWERTYPE_HEALTH)
	else
		ASS.HealthThresholdEnabled = false
		ASS.savedVariables.HealthThresholdEnabled = false
		EM:UnregisterForEvent(ASS.name, EVENT_POWER_UPDATE)
	end
end

function ASS.setHealthThreshold(value)
	ASS.HealthThreshold = value / 100
	ASS.savedVariables.HealthThreshold = value /100
end

function ASS.setTempDuration(value)
	ASS.TempDuration = value
	ASS.savedVariables.TempDuration = value
end
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
local function Initialise(eventCode, addOnName)

    -- Only initialize our own addon
    if (ASS.name ~= addOnName) then return end

    -- Load the saved variables
    --ASS.savedVariables = ZO_SavedVars:NewAccountWide("ASS_SavedVariables", 1, nil, ASS.defaults)
	ASS.savedVariables = ZO_SavedVars:NewCharacterIdSettings("ASS_SavedVariables", 1, nil, ASS.defaults)
	
	--read saved vars
	ASS.Enabled = ASS.savedVariables.Enabled
	ASS.DungeonEnabled = ASS.savedVariables.DungeonEnabled
	ASS.PVPEnabled = ASS.savedVariables.PVPEnabled
	ASS.Debug = ASS.savedVariables.Debug
	ASS.SlotPos = ASS.savedVariables.SlotPos
	ASS.DungeonSlotPos = ASS.savedVariables.DungeonSlotPos
	ASS.PVPSlotPos = ASS.savedVariables.PVPSlotPos
	ASS.DesiredPotionType = ASS.savedVariables.DesiredPotionType
	ASS.DungeonDesiredPotionType = ASS.savedVariables.DungeonDesiredPotionType
	ASS.PVPDesiredPotionType = ASS.savedVariables.PVPDesiredPotionType
	ASS.SearchEnabled = ASS.savedVariables.SearchEnabled
	ASS.DungeonSearchEnabled = ASS.savedVariables.DungeonSearchEnabled
	ASS.PVPSearchEnabled = ASS.savedVariables.PVPSearchEnabled
	ASS.DungeonIgnore = ASS.savedVariables.DungeonIgnore
	ASS.UnderAttackEnabled = ASS.savedVariables.UnderAttackEnabled
	ASS.LockNotification = ASS.savedVariables.LockNotification
	ASS.TempDuration = ASS.savedVariables.TempDuration
	ASS.RestartTempLock = ASS.savedVariables.RestartTempLock
	ASS.HealthThresholdEnabled = ASS.savedVariables.HealthThresholdEnabled
	ASS.HealthThreshold = ASS.savedVariables.HealthThreshold
	
	--Register Settings Menu
	LAM:RegisterAddonPanel("ASS_Settings", ASS_panelData)
	LAM:RegisterOptionControls("ASS_Settings", ASS_optionsTable)
	
	
    ASS.initialised = true
	EM:UnregisterForEvent(ASS.name, EVENT_ADD_ON_LOADED)

	--register for Events
	EM:RegisterForEvent(ASS.name, EVENT_PLAYER_COMBAT_STATE, OnPlayerCombatState)
	EM:RegisterForEvent(ASS.name, EVENT_ACTIVE_QUICKSLOT_CHANGED, OnSlotChanged)
	if ASS.UnderAttackEnabled then
		EM:RegisterForEvent(ASS.name, EVENT_COMBAT_EVENT, OnCombatEvent)
		EM:AddFilterForEvent(ASS.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
	end
	if ASS.RestartTempLock then
		EM:RegisterForEvent(ASS.name, EVENT_INVENTORY_ITEM_USED, onItemUsed)
	end
	if ASS.HealthThresholdEnabled then
		EM:RegisterForEvent(ASS.name, EVENT_POWER_UPDATE, OnPowerEvent)
		EM:AddFilterForEvent(ASS.name, EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
		EM:AddFilterForEvent(ASS.name, EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, POWERTYPE_HEALTH)
	end
	-- Register Keybinding
	--ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_ADDON", "Toggle Addon")
	
end -- ASS.Initialise

EM:RegisterForEvent(ASS.name, EVENT_ADD_ON_LOADED, Initialise)