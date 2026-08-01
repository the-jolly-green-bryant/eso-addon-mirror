
local addonName = 'SkyrimStyleVibration'

local addon = {

	defaults =
	{
		swings = true,
		bows = true,
		staves = true,
		abilities = true,
		blocking = true,
		sprinting = true,
		mountsprinting = true,
		dealingHits = true,
		takingHits = true,
	}
}


-- VARIABLES

local previousHP = 0
local SprintTimer = 0
local currentTimeSpace = 0
local callCount = 0
local mountSprintOn = false
local lastBowLightAttackTime = 0
local lastBowHeavyAttackTime = 0
-- SPECIAL

local function AbilityVibration()
	SetGamepadVibration(750, 0.1, 0.1, 1, 1, "AbilityVibration")
end

local function SubtleVibration()
	SetGamepadVibration(250, 0.1, 0.1, 0.5, 0.5, "SubtleVibration")
end

local function ShieldBashVibration()
	SetGamepadVibration(250, 0.2, 0.1, 0.5, 0.5,  "ShieldBashVibration")
end

local function ShieldHitVibration()
	SetGamepadVibration(250, 0.5, 0.1, 0.5, 1,  "ShieldHitVibration")
end

local function GenericBashVibration()
	SetGamepadVibration(250, 0.2, 0.2, 0.5, 0.5,  "GenericBashVibration")
end

local function HitVibration()
	SetGamepadVibration(250, 0.4, 0.4, 0.5, 0.5, "HitVibration")
end


-- BOW 

local function BowLightAttackVibration()
	SetGamepadVibration(250, 0.2, 0.6, 0.3, 0.7,"BowLightAttackVibration")
end

local function WeakBowLightAttackVibration()
	SetGamepadVibration(250, 0.1, 0.3, 0.3, 0.7,"WeakBowLightAttackVibration")
end

local function PullBackBowVibration()
	SetGamepadVibration(400, 0, 0.1, 0.7, 0.7, "PullBackBowVibration")
end

local function BowHeavyAttackVibration()
	SetGamepadVibration(1000, 0, 0.1, 0, 0, "BowHeavyAttackVibration")
end


-- STAFF


local function DestructionStaffLightAttackVibration()
	SetGamepadVibration(300, 0, 0.5, 0.7, 0.5, "DestructionStaffLightAttackVibration")
end

local function DestructionStaffHeavyAttackVibration()
	SetGamepadVibration(5000, 0, 0.1, 0.7, 0.7, "DestructionStaffHeavyAttackVibration")
end

local function RestorationStaffLightAttackVibration()
	SetGamepadVibration(300, 0.00, 0.3, 0.7, 0.5, "RestorationStaffLightAttackVibration")
end


-- ONE HANDED

local function OneHandedLightAttackVibration()
	SetGamepadVibration(500, 0.0, 0.1, 1, 1, "OneHandedLightAttackVibration")
end

local function OneHandedHeavyAttackVibration()
	SetGamepadVibration(500, 0.1, 0.3, 1, 1, "OneHandedHeavyAttackVibration")
end


-- TWO HANDED 

local function TwoHandedLightAttackVibration()
	SetGamepadVibration(500, 0.1, 0.1, 1, 1, "TwoHandedLightAttackVibration")
end

local function TwoHandedHeavyAttackVibration()
	SetGamepadVibration(600, 0.1, 0.1, 0.3, 0.3,  "TwoHandedHeavyAttackVibration")
end


-- DUAL WIELDED

local function DualWieldedLightAttackVibration()
	SetGamepadVibration(500, 0.1, 0.1, 0.3, 0.5, "DualWieldedLightAttackVibration")
end

local function DualWieldedHeavyAttackVibration()
	SetGamepadVibration(1000, 0.1, 0.1, 0.3, 0.3,  "DualWieldedHeavyAttackVibration")
end


-- SPRINTING

local function SprintRightVibration()
	SetGamepadVibration(100, 0, 0.1, 0, 0, "SprintRightVibration")
end

local function SprintLeftVibration()
	SetGamepadVibration(100, 0.1, 0, 0, 0,"SprintLeftVibration")
end

local function SprintFunction()

	if SprintTimer % 2 == 0  then
		zo_callLater(SprintRightVibration, 50)
	else
		zo_callLater(SprintLeftVibration, 50)
	end

	if SprintTimer == 0 then
		EVENT_MANAGER:UnregisterForUpdate("SprintUpdate")
	else
		SprintTimer = SprintTimer - 1
	end
end


local function MountSprintVibration()
	SetGamepadVibration(250, 0.1, 0.1, 1, 1, "MountSprintVibration")
end

local function MountSprintFunction()
	zo_callLater(MountSprintVibration, 1)
end

local function startMountSprint()
	MountSprintVibration()
	EVENT_MANAGER:RegisterForUpdate("MountSprintUpdate", 421, MountSprintFunction) 
end

-- FUNCTIONS

local function HeavyAttackCheck() 

	local timeFrame = 1000

	local timeRange = currentTimeSpace + 1000

	if os.rawclock() < timeRange then
		callCount = callCount + 1

		if callCount < 2 then
			return true

		else
			callCount = 0
		end
	end
end


function isCurrentOffhandShield()

	if GetActiveWeaponPairInfo() == ACTIVE_WEAPON_PAIR_MAIN then
		return isOffHandShield(EQUIP_SLOT_OFF_HAND)
	else 
		return isOffHandShield(EQUIP_SLOT_BACKUP_OFF)
	end
end

function isOffHandShield(wornSlot)
	local type = GetItemWeaponType(BAG_WORN, wornSlot)
	if type == WEAPONTYPE_SHIELD then
		return true
	else
		return false
	end
end

function isCurrentWeaponRanged()

	if GetActiveWeaponPairInfo() == ACTIVE_WEAPON_PAIR_MAIN then
		return isWeaponRanged(EQUIP_SLOT_MAIN_HAND)
	else 
		return isWeaponRanged(EQUIP_SLOT_BACKUP_MAIN)
	end
end

function isWeaponRanged(wornSlot)
	local type = GetItemWeaponType(BAG_WORN, wornSlot)
	if type == WEAPONTYPE_BOW or type == WEAPONTYPE_FIRE_STAFF or type == WEAPONTYPE_FROST_STAFF or type == WEAPONTYPE_HEALING_STAFF or type == WEAPONTYPE_LIGHTNING_STAFF then
		return true
	else
		return false
	end
end


function isCurrentWeaponBow()

	if GetActiveWeaponPairInfo() == ACTIVE_WEAPON_PAIR_MAIN then
		return isWeaponBow(EQUIP_SLOT_MAIN_HAND)
	else 
		return isWeaponBow(EQUIP_SLOT_BACKUP_MAIN)
	end
end

function isWeaponBow(wornSlot)
	local type = GetItemWeaponType(BAG_WORN, wornSlot)
	if type == WEAPONTYPE_BOW then
		return true
	else
		return false
	end
end


function isCurrentWeaponDestructionStaff()
	if GetActiveWeaponPairInfo() == ACTIVE_WEAPON_PAIR_MAIN then
		return isWeaponDestructionStaff(EQUIP_SLOT_MAIN_HAND)
	else 
		return isWeaponDestructionStaff(EQUIP_SLOT_BACKUP_MAIN)
	end
end

function isWeaponDestructionStaff(wornSlot)
	local type = GetItemWeaponType(BAG_WORN, wornSlot)
	if type == WEAPONTYPE_FIRE_STAFF or type == WEAPONTYPE_FROST_STAFF or type == WEAPONTYPE_LIGHTNING_STAFF then
		return true
	else
		return false
	end
end


function isCurrentWeaponRestorationStaff()
	if GetActiveWeaponPairInfo() == ACTIVE_WEAPON_PAIR_MAIN then
		return isWeaponRestorationStaff(EQUIP_SLOT_MAIN_HAND)
	else 
		return isWeaponRestorationStaff(EQUIP_SLOT_BACKUP_MAIN)
	end
end

function isWeaponRestorationStaff(wornSlot)
	local type = GetItemWeaponType(BAG_WORN, wornSlot)
	if type == WEAPONTYPE_HEALING_STAFF then
		return true
	else
		return false
	end
end


function isCurrentWeaponTwoHanded()
	if GetActiveWeaponPairInfo() == ACTIVE_WEAPON_PAIR_MAIN then
		return isWeaponTwoHanded(EQUIP_SLOT_MAIN_HAND, EQUIP_SLOT_OFF_HAND)
	else 
		return isWeaponTwoHanded(EQUIP_SLOT_BACKUP_MAIN, EQUIP_SLOT_BACKUP_OFF)
	end
end


function isWeaponTwoHanded(wornSlot, offSlot)
	local type = GetItemWeaponType(BAG_WORN, wornSlot)
	local typeOff = GetItemWeaponType(BAG_WORN, offSlot)
	if type == WEAPONTYPE_TWO_HANDED_AXE or type == WEAPONTYPE_TWO_HANDED_HAMMER or type == WEAPONTYPE_TWO_HANDED_SWORD or typeOff == WEAPONTYPE_SWORD then
		return true
	else
		return false
	end
end

function isCurrentWeaponDualWielded()
	if GetActiveWeaponPairInfo() == ACTIVE_WEAPON_PAIR_MAIN then
		return isWeaponDualWielded(EQUIP_SLOT_OFF_HAND)
	else 
		return isWeaponDualWielded(EQUIP_SLOT_BACKUP_OFF)
	end
end

function isWeaponDualWielded(offSlot)
	local type = GetItemWeaponType(BAG_WORN, offSlot)
	if type == WEAPONTYPE_SWORD then
		return true
	else
		return false
	end
end

function isCurrentWeaponOneHanded()
	if GetActiveWeaponPairInfo() == ACTIVE_WEAPON_PAIR_MAIN then
		return isWeaponTwoHanded(EQUIP_SLOT_MAIN_HAND)
	else 
		return isWeaponTwoHanded(EQUIP_SLOT_BACKUP_MAIN)
	end
end

function isWeaponOneHanded(wornSlot)
	local type = GetItemWeaponType(BAG_WORN, wornSlot)
	if type == WEAPONTYPE_AXE or type == WEAPONTYPE_DAGGER or type == WEAPONTYPE_HAMMER or type == WEAPONTYPE_SWORD then
		return true
	else
		return false
	end
end


-- EVENTS 

function OnPowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)

	if unitTag == 'player' and addon.settings.takingHits then
		if powerValue < previousHP then
			local vibrationAmount = ((previousHP - powerValue) / powerEffectiveMax) * 2
			SetGamepadVibration(250, vibrationAmount, vibrationAmount, vibrationAmount, vibrationAmount,"BeenHitVibration")
		end
		previousHP = powerValue

	end
end

function onCombatEvent(_, _, _, abilityName, abilityGraphic, abilityActionSlotType, sourceName,sourceType, targetName, targetType, hitValue, powerType,damageType)

	if not isCurrentWeaponRanged() and not (powerType == -1) and abilityName == "Light Attack" or abilityName == "Heavy Attack Damage Bonus" then -- we use abilityActionSlotType rather than abilityName to avoid some duplicate events 
		if addon.settings.dealingHits then
			zo_callLater(HitVibration,200)
		end


	elseif abilityName == "Mount Up" or abilityName == "Dismount" or abilityName == "Sprint" then
			if addon.settings.mountsprinting then
				zo_callLater(SubtleVibration, 100)
			end
			SprintTimer = 0
			mountSprintOn = false
			EVENT_MANAGER:UnregisterForUpdate("MountSprintUpdate")
			EVENT_MANAGER:UnregisterForUpdate("SprintUpdate")



	elseif abilityName == "Sprint Drain" or abilityName == "Mount Sprint (Generic)" then


		if IsMounted() then
			if addon.settings.mountsprinting then

				if not mountSprintOn then
					mountSprintOn = true
					zo_callLater(startMountSprint, 50) -- this should really change depending on mount speed tbh						

				end
			end

		elseif SprintTimer == 0 then
			if addon.settings.sprinting then
				SprintTimer = 3
				EVENT_MANAGER:RegisterForUpdate("SprintUpdate", 200, SprintFunction)

			else
				SprintTimer = 3
			end

		end


	elseif abilityName == "Heavy Attack (Bow)" then
		if addon.settings.bows then
			if os.rawclock() < lastBowHeavyAttackTime + 3000 then
				zo_callLater(PullBackBowVibration, 1000)
			else
				zo_callLater(PullBackBowVibration, 750)
			end
			lastBowHeavyAttackTime = os.rawclock()
		end
	elseif abilityName == "Heavy Attack (Frost)" or abilityName == "Heavy Attack (Flame)" then -- shock charges up differently so doesn't work for this, but it has vibration in vanilla anyway
		if addon.settings.staves then
			callCount = 0
			currentTimeSpace = os.rawclock()
			zo_callLater(DestructionStaffHeavyAttackVibration, 100)
		end

	elseif abilityName == "Heavy Attack (2H)" then
		if addon.settings.swings then
			callCount = 0
			currentTimeSpace = os.rawclock()
			zo_callLater(TwoHandedLightAttackVibration, 200)
		end

	elseif  abilityName == "Heavy Attack (Dual Wield)"  then
		if addon.settings.swings then
			callCount = 0
			currentTimeSpace = os.rawclock()
			zo_callLater(DualWieldedLightAttackVibration, 200)
		end

	elseif abilityName == "Heavy Attack (1H)" then
		if addon.settings.swings then
			callCount = 0
			currentTimeSpace = os.rawclock()
			zo_callLater(OneHandedLightAttackVibration, 100)
		end

	elseif abilityName == "Interrupt Bonus" then
		if addon.settings.blocking then
			if isCurrentOffhandShield() then
				zo_callLater(ShieldBashVibration, 1)
			else
				zo_callLater(GenericBashVibration, 1)
			end
		end

	elseif abilityName == "Block" then
		if addon.settings.blocking then
			zo_callLater(SubtleVibration, 50)
		end

	elseif abilityName == "Brace Cost" then
		if addon.settings.dealingHits then
			if isCurrentOffhandShield() then
				zo_callLater(ShieldHitVibration, 100)
			else
				zo_callLater(HitVibration, 100)
			end
		end
	end
end



function onActionSlotAbilityUsed(eventCode, slotNum)

	if slotNum == 1 then

		if isCurrentWeaponBow() then
			if addon.settings.bows then
				if os.rawclock() < lastBowLightAttackTime + 1000 then
					zo_callLater(WeakBowLightAttackVibration, 50)
					zo_callLater(PullBackBowVibration, 500)
				else
					zo_callLater(BowLightAttackVibration, 50)
					zo_callLater(PullBackBowVibration, 500)
				end
				lastBowLightAttackTime = os.rawclock()
			end

		elseif isCurrentWeaponDestructionStaff() then
			if addon.settings.staves then
				DestructionStaffLightAttackVibration()
			end

		elseif isCurrentWeaponRestorationStaff() then
			if addon.settings.staves then
				RestorationStaffLightAttackVibration()
			end

		elseif isCurrentWeaponTwoHanded() then
			if addon.settings.swings then
				zo_callLater(TwoHandedLightAttackVibration, 300)
			end

		elseif isCurrentWeaponDualWielded() then
			if addon.settings.swings then
				zo_callLater(DualWieldedLightAttackVibration, 200)
			end

		else
			if addon.settings.swings then
				zo_callLater(OneHandedLightAttackVibration, 200)

			end
		end


	elseif slotNum == 2 then
		if not isCurrentWeaponRanged() then
			if HeavyAttackCheck() and addon.settings.swings then
				if isCurrentWeaponTwoHanded() then
					zo_callLater(TwoHandedHeavyAttackVibration, 300)
				else
					zo_callLater(OneHandedHeavyAttackVibration, 100)
				end
			end

		end
	elseif addon.settings.abilities then
		zo_callLater(AbilityVibration, 200)
	end	
end


-- SETUP

local function InitSettings()
	local LibHarvensAddonSettings = LibStub("LibHarvensAddonSettings-1.0")

	local options = {
		allowDefaults = true, 
	}

	local settings = LibHarvensAddonSettings:AddAddon("Skyrim Style Vibration", options)
	if not settings then
		return
	end


	settings:AddSetting {
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Swing Vibration", 
		tooltip = "Vibrations for all weapon swings. Different weapon types feel different.", 
		default = addon.defaults.swings,
		getFunction = function() return addon.settings.swings end,
		setFunction = function(state) addon.settings.swings = state end,
	}

	settings:AddSetting {
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Bow Vibration", 
		tooltip = "Vibrations for pulling bowstrings and firing. Continuous bow fire feels weaker.", 
		default = addon.defaults.bows,
		getFunction = function() return addon.settings.bows end,
		setFunction = function(state) addon.settings.bows = state end,
	}

	settings:AddSetting {
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Staff Vibration", 
		tooltip = "Vibrations for firing of staves. Destruction and Restoration staffs feel different.", 
		default = addon.defaults.staves,
		getFunction = function() return addon.settings.staves end,
		setFunction = function(state) addon.settings.staves = state end,
	}

	settings:AddSetting {
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Block Vibration", 
		tooltip = "Vibrations for blocking, bashing, and shields.", 
		default = addon.defaults.blocking,
		getFunction = function() return addon.settings.blocking end,
		setFunction = function(state) addon.settings.blocking = state end,
	}

	settings:AddSetting {
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Ability Vibration", 
		tooltip = "Vibrations for all abilities. (Mod could be extended to have specific vibrations for specified abilities if you have the time and want to add it. If you have questions feel free to PM me.)", 
		default = addon.defaults.abilities,
		getFunction = function() return addon.settings.abilities end,
		setFunction = function(state) addon.settings.abilities = state end,
	}

	settings:AddSetting {
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Player Sprint Vibration", 
		tooltip = "Vibrations for player sprinting.", 
		default = addon.defaults.sprinting,
		getFunction = function() return addon.settings.sprinting end,
		setFunction = function(state) addon.settings.sprinting = state end,
	}

	settings:AddSetting {
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Mount Sprint Vibration", 
		tooltip = "Vibrations for mount sprinting.", 
		default = addon.defaults.mountsprinting,
		getFunction = function() return addon.settings.mountsprinting end,
		setFunction = function(state) addon.settings.mountsprinting = state end,
	}

	settings:AddSetting {
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Dealing Hits Vibration", 
		tooltip = "Vibrations for hitting enemies.", 
		default = addon.defaults.dealingHits,
		getFunction = function() return addon.settings.dealingHits end,
		setFunction = function(state) addon.settings.dealingHits = state end,
	}

	settings:AddSetting {
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Taking Hits Vibration", 
		tooltip = "Vibrations for taking hits from enemies. Strength is affected by amount of health lost propertional to effective max health", 
		default = addon.defaults.takingHits,
		getFunction = function() return addon.settings.takingHits end,
		setFunction = function(state) addon.settings.takingHits = state end,
	} 
end


local function eventRegister()
	EVENT_MANAGER:RegisterForEvent(addonName, EVENT_COMBAT_EVENT, onCombatEvent)
	EVENT_MANAGER:AddFilterForEvent(addonName, EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
	EVENT_MANAGER:AddFilterForEvent(addonName, EVENT_COMBAT_EVENT, REGISTER_FILTER_IS_ERROR, false)

	EVENT_MANAGER:RegisterForEvent(addonName, EVENT_ACTION_SLOT_ABILITY_USED, onActionSlotAbilityUsed)

	EVENT_MANAGER:RegisterForEvent(addonName, EVENT_POWER_UPDATE, OnPowerUpdate)
	EVENT_MANAGER:AddFilterForEvent(addonName, EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, POWERTYPE_HEALTH)
end


local function onLoaded(event, loadedAddon )
	if (loadedAddon ~= addonName) then return end
	EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)
	addon.settings = ZO_SavedVars:NewAccountWide("SkyrimStyleVibration_SavedVariables", 1, nil, addon.defaults)
	InitSettings()
	eventRegister()
end

EVENT_MANAGER:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED,onLoaded)
