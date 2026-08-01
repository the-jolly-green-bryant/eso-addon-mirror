-- RdK Group Tool Util Group
-- By @s0rdrak (PC / EU)

--local lib3d = LibStub("Lib3D2")
local lib3d = Lib3D
local libPB = LibPotionBuff
--local libFDB = LibStub("LibFoodDrinkBuff")
local libFDB = LIB_FOOD_DRINK_BUFF

RdKGTool = RdKGTool or {}

RdKGTool.util = RdKGTool.util or {}
RdKGTool.util.group = RdKGTool.util.group or {}
RdKGTool.util.ui = RdKGTool.util.ui or {}
RdKGTool.util.networking = RdKGTool.util.networking or {}
RdKGTool.util.ultimates = RdKGTool.util.ultimates or {}
RdKGTool.util.equipment = RdKGTool.util.equipment  or {}
RdKGTool.util.cp = RdKGTool.util.cp  or {}
RdKGTool.util.sb = RdKGTool.util.sb  or {}
RdKGTool.util.math = RdKGTool.util.math or {}
RdKGTool.util.playerLink = RdKGTool.util.playerLink or {}
RdKGTool.util.chatSystem = RdKGTool.util.chatSystem or {}
RdKGTool.util.versioning = RdKGTool.util.versioning or {}
RdKGTool.util.roster = RdKGTool.util.roster or {}
RdKGTool.menu = RdKGTool.menu or {}


local RdKGToolUtil = RdKGTool.util
local RdKGToolGroup = RdKGToolUtil.group
local RdKGToolUI = RdKGToolUtil.ui
local RdKGToolUltimates = RdKGToolUtil.ultimates
local RdKGToolNetworking = RdKGToolUtil.networking
local RdKGToolEquip = RdKGToolUtil.equipment
local RdKGToolCP = RdKGToolUtil.cp
local RdKGToolSB = RdKGToolUtil.sb
local RdKGToolMath = RdKGToolUtil.math
local RdKGToolPL = RdKGToolUtil.playerLink
local RdKGToolChat = RdKGToolUtil.chatSystem
local RdKGToolVersioning = RdKGToolUtil.versioning
local RdKGToolMenu = RdKGTool.menu
local RdKGToolRoster = RdKGToolUtil.roster

RdKGToolGroup.features = {}
RdKGToolGroup.features.FEATURE_GROUP_LEADER_DISTANCE = 1
RdKGToolGroup.features.FEATURE_GROUP_PLAYER_TO_MEMBER_DISTANCE = 2
RdKGToolGroup.features.FEATURE_GROUP_LEADER_TO_MEMBER_DISTANCE = 3
RdKGToolGroup.features.FEATURE_GROUP_BUFFS = 4
RdKGToolGroup.features.FEATURE_GROUP_RESOURCES = 5
RdKGToolGroup.features.FEATURE_GROUP_HP_DMG = 6
RdKGToolGroup.features.FEATURE_GROUP_VERSIONING = 7
RdKGToolGroup.features.FEATURE_GROUP_COORDINATES = 8
RdKGToolGroup.features.FEATURE_GROUP_DEAD_STATE = 9
RdKGToolGroup.features.FEATURE_GROUP_NONE = 10
RdKGToolGroup.features.FEATURE_GROUP_SYNERGY = 11

RdKGToolGroup.features.state = {}
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_LEADER_DISTANCE] = {}
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_LEADER_DISTANCE].consumers = {}
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_LEADER_DISTANCE].callbackName = RdKGTool.addonName .. "UtilGroupLeaderUpdate"
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_LEADER_DISTANCE].activeCallback = false
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_PLAYER_TO_MEMBER_DISTANCE] = {}
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_PLAYER_TO_MEMBER_DISTANCE].consumers = {}
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_PLAYER_TO_MEMBER_DISTANCE].callbackName = RdKGTool.addonName .. "UtilGroupPlayerToMemberDistance"
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_PLAYER_TO_MEMBER_DISTANCE].activeCallback = false
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_LEADER_TO_MEMBER_DISTANCE] = {}
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_LEADER_TO_MEMBER_DISTANCE].consumers = {}
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_LEADER_TO_MEMBER_DISTANCE].callbackName = RdKGTool.addonName .. "UtilGroupLeaderToPlayerDistance"
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_LEADER_TO_MEMBER_DISTANCE].activeCallback = false
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_BUFFS] = {}
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_BUFFS].consumers = {}
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_BUFFS].callbackName = RdKGTool.addonName .. "UtilGroupBuffs"
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_BUFFS].activeCallback = false
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_RESOURCES] = {}
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_RESOURCES].consumers = {}
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_RESOURCES].callbackName = RdKGTool.addonName .. "UtilGroupResources"
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_RESOURCES].activeCallback = false
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_RESOURCES].activeCustomFeature = false
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_HP_DMG] = {}
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_HP_DMG].consumers = {}
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_HP_DMG].callbackName = RdKGTool.addonName .. "UtilGroupHpDmg"
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_HP_DMG].activeCallback = false
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_HP_DMG].activeCustomFeature = false
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_VERSIONING] = {}
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_VERSIONING].consumers = {}
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_VERSIONING].callbackName = RdKGTool.addonName .. "UtilGroupVersioning"
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_VERSIONING].activeCallback = false
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_VERSIONING].activeCustomFeature = false
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_COORDINATES] = {}
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_COORDINATES].consumers = {}
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_COORDINATES].callbackName = RdKGTool.addonName .. "UtilGroupCoordinates"
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_COORDINATES].activeCallback = false
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_DEAD_STATE] = {}
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_DEAD_STATE].consumers = {}
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_DEAD_STATE].callbackName = RdKGTool.addonName .. "UtilGroupDeadState"
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_DEAD_STATE].activeCallback = false
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_NONE] = {}
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_NONE].consumers = {}
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_NONE].callbackName = RdKGTool.addonName .. "UtilGroupNone"
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_NONE].activeCallback = false
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_SYNERGY] = {}
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_SYNERGY].consumers = {}
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_SYNERGY].callbackName = RdKGTool.addonName .. "UtilGroupSynergy"
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_SYNERGY].activeCallback = false
RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_SYNERGY].activeCustomFeature = false


RdKGToolGroup.features.stackCount = 0

RdKGToolGroup.constants = {}
RdKGToolGroup.constants.BY_CHAR_NAME = 1
RdKGToolGroup.constants.BY_DISPLAY_NAME = 2
RdKGToolGroup.constants.displayTypes = {}
RdKGToolGroup.constants.COMBAT_TIMEOUT = 30000
RdKGToolGroup.constants.PREFIX = "Group"
RdKGToolGroup.constants.potionTypes = {}
RdKGToolGroup.constants.potionTypes.CRAFTED = 1
RdKGToolGroup.constants.potionTypes.CROWN = 2
RdKGToolGroup.constants.potionTypes.NON_CRAFTED = 3
RdKGToolGroup.constants.potionTypes.ALLIANCE = 4

RdKGToolGroup.constants.roles = {}
RdKGToolGroup.constants.roles.ROLE_RAPID = 1
RdKGToolGroup.constants.roles.ROLE_PURGE = 2
RdKGToolGroup.constants.roles.ROLE_HEAL = 3
RdKGToolGroup.constants.roles.ROLE_DD = 4
RdKGToolGroup.constants.roles.ROLE_SYNERGY = 5
RdKGToolGroup.constants.roles.ROLE_CC = 6
RdKGToolGroup.constants.roles.ROLE_SUPPORT = 7
RdKGToolGroup.constants.roles.ROLE_PLACEHOLDER = 8
RdKGToolGroup.constants.roles.ROLE_APPLICANT = 9

RdKGToolGroup.state = {}
RdKGToolGroup.state.leader = {}
RdKGToolGroup.state.lastCombatTimestamp = 0
RdKGToolGroup.state.versionCheckCallback = nil
RdKGToolGroup.state.groupChangedConsumers = {}
RdKGToolGroup.state.ultimatesChangedConsumers = {}
RdKGToolGroup.state.adminInformationChangedConsumers = {}
RdKGToolGroup.state.lastLeader = nil
RdKGToolGroup.state.crBgTpHealBuffs = nil
RdKGToolGroup.state.hdmAutoClear = true

RdKGToolGroup.callbackName = RdKGTool.addonName .. "UtilGroup"

RdKGToolGroup.config = RdKGToolGroup.config or {}
RdKGToolGroup.config.combatUpdateInterval = 250


--abilities
RdKGToolGroup.abilityIds = {}
--[[
RdKGToolGroup.abilityIds.rapidManeuver = {
	[1] = 61736-- 101161,
}
RdKGToolGroup.abilityIds.chargingManeuverMajor = {
	[1] = 61736 -- 101178
}
RdKGToolGroup.abilityIds.chargingManeuverMinor = {
	[1] = 61735 -- 40219
}
RdKGToolGroup.abilityIds.retreatingManeuver = {
	[1] = 61736 -- 101169,--/script d(GetAbilityDescription(101169))
}
]]
RdKGToolGroup.abilityIds.majorExpedition = {
	[1] = 61736
}
RdKGToolGroup.abilityIds.minorExpedition = {
	[1] = 61735
}
--Likely not woking anymore due to ZOS changing IDs (~U30, adjusted in 2.0.33)
RdKGToolGroup.abilityIds.immovablePot = {
	[1] = 45239, -- U30+, should not work anymore
	[2] = 72930, -- U30+, should not work anymore
	[3] = 86698, -- U30+, should not work anymore
	[4] = 72930  -- U30+, Only on alliance pots - wtf
}
-- Not working anymore due to ZOS changing IDs (~U30, adjusted in 2.0.33)
RdKGToolGroup.abilityIds.alliancePot = {
	[72935] = true,
	[72936] = true,
	[72928] = true,
	[72930] = true,
	[72932] = true,
	[72933] = true
}
-- Temporary (2.0.33) Fix for broken LibPotionBuff library (ZOS fault: Changing IDs)
RdKGToolGroup.abilityIds.isPotion = {
--Positive
	[61698] = true, --"Major Fortitude",
	[61707] = true, --"Major Intellect",
	[61705] = true, --"Major Endurance",
	[45236] = true, --"Increase Detection",
	[45237] = true, --"Invisibility", INFO: Still has a different ID on alliance Potions 136002 (wtf?)
	[72930] = true, --"Unstoppable", INFO: Does not exist on crafted Potions anymore (wtf?)

	[61665] = true, --"Major Brutality",
	[61687] = true, --"Major Sorcery",
	[61736] = true, --"Major Expedition",
	[61667] = true, --"Major Savagery",
	[61689] = true, --"Major Prophecy",

	[79705] = true, --"Lingering Restore Health",
	[61721] = true, --"Minor Protection",
	[61713] = true, --"Major Vitality",
	
	[64564] = true, -- "Physical Resistance Potion",
	[64562] = true, -- "Spell Resistance Potion",
	[61708] = true, -- "Minor Heroism",
	
	-- Negative
	[46113] = true, --"Ravage Health",
	[46193] = true, --"Ravage Magicka",
	[46199] = true, --"Ravage Stamina",
	[79867] = true, --"Minor Cowardice",
	[61723] = true, --"Minor Maim",
	[46206] = true, --"Spell Resistance Reduction",
	[46208] = true, --"Physical Resistance Reduction",
	[46210] = true, --"Hindrance",
	
	[79907] = true, -- "Minor Enervation",
	[140699] = true, -- "Minor Timidity",
	[61726] = true, -- "Minor Defile",
	[79895] = true, -- "Minor Uncertainty",
	[79709] = true, -- "Creeping Ravage Health",
	[79717] = true, -- "Minor Vulnerability",
}

RdKGToolGroup.abilityIds.proximityDetonation = {
	[61500] = true
}

-- 146919
RdKGToolGroup.abilityIds.subterraneanAssault = {
	[86019] = true
	
}

RdKGToolGroup.abilityIds.subterraneanAssaultWaveTwo = {
	[146919] = true
}

RdKGToolGroup.abilityIds.deepFissure = {
	[86015] = true
}

RdKGToolGroup.abilityIds.deepFissureWaveTwo = {
	[178028] = true
}

RdKGToolGroup.abilityIds.soulOfFlame = {
	[32792] = true
}
--public functions

function RdKGToolGroup.Initialize()	
	RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_LEADER_DISTANCE].callback = RdKGToolGroup.OnUpdateLeader
	RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_PLAYER_TO_MEMBER_DISTANCE].callback = RdKGToolGroup.OnUpdatePlayerDistance
	RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_LEADER_TO_MEMBER_DISTANCE].callback = RdKGToolGroup.OnUpdateLeaderDistance
	RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_BUFFS].callback = RdKGToolGroup.OnUpdateBuff
	RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_RESOURCES].callback = nil
	RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_HP_DMG].callback = nil
	RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_VERSIONING].callback = nil
	RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_COORDINATES].callback = RdKGToolGroup.OnUpdateCoordinates
	RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_DEAD_STATE].callback = RdKGToolGroup.OnUpdateDeadState
	RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_NONE].callback = nil
	RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_SYNERGY].callback = nil
	
	RdKGTool.profile.AddProfileChangeListener(RdKGToolGroup.callbackName, RdKGToolGroup.OnProfileChanged)
end

function RdKGToolGroup.GetDefaults()
	local defaults = {}
	defaults.displayType = RdKGToolGroup.constants.BY_CHAR_NAME
	return defaults
end

function RdKGToolGroup.GetDisplayType()
	return RdKGToolGroup.groupVars.displayType
end

function RdKGToolGroup.AddFeature(consumerName, featureName, interval)
	if consumerName ~= nil and featureName ~= nil then
		if RdKGToolGroup.IsValidFeature(featureName) == true then
			local feature = RdKGToolGroup.features.state[featureName]
			local consumers = feature.consumers
			local callbackName = feature.callbackName
			local callbackFunction = feature.callback
			
			local entryExists = false
			for i = 1, #consumers do
				if consumers[i].name == consumerName then
					entryExists = true
					break
				end
			end
			if entryExists == false then
				RdKGToolGroup.features.stackCount = RdKGToolGroup.features.stackCount + 1
				if RdKGToolGroup.features.stackCount == 1 then
					RdKGToolGroup.EnableGroup()
				end
				
				local entry = {}
				entry.name = consumerName
				entry.interval = interval
				--d("reached entry creation")
				if callbackFunction ~= nil and callbackName ~= nil then
					local isMainConsumer = true
					local oldConsumer = 0
					for i = 1, #consumers do
						if consumers[i].isMainConsumer == true then
							if consumers[i].interval <= interval then
								isMainConsumer = false
							end
							oldConsumer = i
						end
					end
					entry.isMainConsumer = isMainConsumer
					if oldConsumer > 0 and isMainConsumer == true then
						consumers[oldConsumer].isMainConsumer = false
					end
					--d("reached this part")
					if isMainConsumer == true then
						if feature.activeCallback == true then
							EVENT_MANAGER:UnregisterForUpdate(callbackName)
							EVENT_MANAGER:RegisterForUpdate(callbackName, interval, callbackFunction)
						else
							EVENT_MANAGER:RegisterForUpdate(callbackName, interval, callbackFunction)
						end
						--d("reached this part 2")
						feature.activeCallback = true
					end
				end
				--d("reached this part 3")
				table.insert(consumers, entry)
				RdKGToolGroup.AddCustomFeature(featureName)
			end
				
			
		end
	end
end

function RdKGToolGroup.RemoveFeature(consumerName, featureName)
	if consumerName ~= nil and featureName ~= nil then
		if RdKGToolGroup.IsValidFeature(featureName) == true then
			local feature = RdKGToolGroup.features.state[featureName]
			local consumers = feature.consumers
			local callbackName = feature.callbackName
			local callbackFunction = feature.callback
			--if callbackFunction != nil and callbackName ~= nil then
				
			for i = 1, #consumers do
				if consumers[i].name == consumerName then
					local isMainConsumer = consumers[i].isMainConsumer
					local interval = consumers[i].interval
					table.remove(consumers, i)
					RdKGToolGroup.features.stackCount = RdKGToolGroup.features.stackCount - 1
					if callbackName ~= nil and callbackFunction ~= nil then
						local isListening = true
						if #consumers == 0 then
							isListening, feature.activeCallback = false, false
							EVENT_MANAGER:UnregisterForUpdate(callbackName)
						end
						if isListening == true and isMainConsumer == true then
							local lowestInterval = consumers[1].interval
							local lowestIndex = 1
							if #consumers > 2 then
								for j = 2, #consumers do
									if consumers[j].interval < lowestInterval then
										lowestInterval = consumers[j].interval
										lowestIndex = j
									end
								end
							end
							consumers[lowestIndex].isMainConsumer = true
							if lowestInterval ~= interval then
								EVENT_MANAGER:UnregisterForUpdate(callbackName)
								EVENT_MANAGER:RegisterForUpdate(callbackName, lowestInterval, callbackFunction)
							end
						end
					end
					RdKGToolGroup.RemoveCustomFeature(featureName)
					break
				end
			end

			if RdKGToolGroup.features.stackCount == 0 then
				RdKGToolGroup.DisableGroup()
			end
		end
	end
end

function RdKGToolGroup.AddCustomFeature(featureName)
	--d("AddCustomFeature: " .. featureName)
	if RdKGToolGroup.features.state[featureName].activeCustomFeature == false then
		if featureName == RdKGToolGroup.features.FEATURE_GROUP_RESOURCES then 
			RdKGToolNetworking.AddRawMessageHandler(RdKGToolGroup.features.state[featureName].callbackName, RdKGToolGroup.HandleRawResourceNetworkMessage)
		elseif featureName == RdKGToolGroup.features.FEATURE_GROUP_HP_DMG then 
			RdKGToolNetworking.AddRawMessageHandler(RdKGToolGroup.features.state[featureName].callbackName, RdKGToolGroup.HandleRawHpDmgNetworkMessage)
			--EVENT_MANAGER:RegisterForEvent(RdKGToolGroup.features.state[featureName].callbackName, EVENT_POWER_UPDATE, RdKGToolGroup.OnPowerUpdate)
		elseif featureName == RdKGToolGroup.features.FEATURE_GROUP_VERSIONING then 
			RdKGToolNetworking.AddRawMessageHandler(RdKGToolGroup.features.state[featureName].callbackName, RdKGToolGroup.HandleRawVersionNetworkMessage)
		elseif featureName == RdKGToolGroup.features.FEATURE_GROUP_SYNERGY then
			RdKGToolNetworking.AddRawMessageHandler(RdKGToolGroup.features.state[featureName].callbackName, RdKGToolGroup.HandleRawSynergyNetworkMessage)
		end
		RdKGToolGroup.features.state[featureName].activeCustomFeature = true
	end
end

function RdKGToolGroup.RemoveCustomFeature(featureName)
	--d("RemoveCustomFeature: " .. featureName)
	if RdKGToolGroup.features.state[featureName].activeCustomFeature == true then
		if featureName == RdKGToolGroup.features.FEATURE_GROUP_RESOURCES or
		   featureName == RdKGToolGroup.features.FEATURE_GROUP_HP_DMG or
		   featureName == RdKGToolGroup.features.FEATURE_GROUP_VERSIONING or 
		   featureName == RdKGToolGroup.features.FEATURE_GROUP_SYNERGY then
			RdKGToolNetworking.RemoveRawMessageHandler(RdKGToolGroup.features.state[featureName].callbackName)
		end
		if featureName == RdKGToolGroup.features.FEATURE_GROUP_HP_DMG then
			--EVENT_MANAGER:UnregisterForEvent(RdKGToolGroup.features.state[featureName].callbackName, EVENT_POWER_UPDATE)
		end
		RdKGToolGroup.features.state[featureName].activeCustomFeature = false
	end
end

function RdKGToolGroup.IsValidFeature(featureName)
	local status = false
	if RdKGToolGroup.features.state[featureName] ~= nil then
		status = true
	end
	return status
end

function RdKGToolGroup.GetLeaderDistance()
	if RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_LEADER_DISTANCE].activeCallback == true then
		return RdKGToolGroup.state.leader.leaderDistance
	else
		return nil
	end
end

function RdKGToolGroup.GetLeaderRotation()
	if RdKGToolGroup.features.state[RdKGToolGroup.features.FEATURE_GROUP_LEADER_DISTANCE].activeCallback == true then
		return RdKGToolGroup.state.leader.leaderRotation
	else
		return nil
	end
end


function RdKGToolGroup.GetGroupInformation()
	if RdKGToolGroup.features.stackCount > 0 then
		return RdKGToolGroup.state.players
	else
		return nil
	end
end

function RdKGToolGroup.IsGroupInCombat()
	local inCombat = IsUnitInCombat("player")
	if RdKGToolGroup.features.stackCount > 0 and inCombat == false then
		local players = RdKGToolGroup.state.players
		if players ~= nil then
			for i = 1, #players do
				if IsUnitInCombat(players[i].unitTag) == true then
					inCombat = true
					break
				end
			end
		else
			inCombat = false
		end
	end
	return inCombat
end

function RdKGToolGroup.IsUnitGroupLeader(unitTag)
	if unitTag == "player" then
		return RdKGToolGroup.IsPlayerGroupLeader()
	else
		local isLeader = false
		local players = RdKGToolGroup.state.players
		if players ~= nil then
			for i = 1, #players do
				if players[i].unitTag == unitTag and players[i].isLeader == true then
					isLeader = true
					break
				end
			end
		end
		return isLeader
	end
end

function RdKGToolGroup.IsPlayerGroupLeader()
	local isLeader = false
	local players = RdKGToolGroup.state.players
	if players ~= nil and #players > 1 then
		for i = 1, #players do
			if players[i].charName == GetUnitName("player") and players[i].displayName == GetUnitDisplayName("player") and players[i].isLeader == true then
				isLeader = true
			end
		end
	end
	return isLeader
end

function RdKGToolGroup.GetPlayerUnitTag()
	local playerTag = "player"
	local players = RdKGToolGroup.state.players
	if players ~= nil then
		for i = 1, #players do
			if players[i].charName == GetUnitName("player") and players[i].displayName == GetUnitDisplayName("player") then
				playerTag = players[i].unitTag
				break
			end
		end
	end
	return playerTag
end

function RdKGToolGroup.GetGroupLeaderUnitTag()
	local leaderTag = nil
	local players = RdKGToolGroup.state.players
	if players ~= nil then
		for i = 1, #players do
			if players[i].isLeader == true then
				leaderTag = players[i].unitTag
				break
			end
		end
	end
	return leaderTag
end

function RdKGToolGroup.UpdateMemberResources(unitTag, ultiId, ultiPercent, magickaPercent, stamPercent)
	local players = RdKGToolGroup.state.players

	if players ~= nil then
		for i = 1, #players do
			--d(unitTag .. " vs " .. players[i].unitTag)
			if players[i].unitTag == unitTag then
				local debuffs = {}
				
				local ultimate = RdKGToolMath.DecodeBitArrayHelper(ultiPercent)
				local magicka = RdKGToolMath.DecodeBitArrayHelper(magickaPercent)
				local stamina = RdKGToolMath.DecodeBitArrayHelper(stamPercent)
				debuffs[1] = ultimate[8]
				debuffs[2] = magicka[8]
				debuffs[3] = stamina[8]
				ultimate[8] = 0
				magicka[8] = 0
				stamina[8] = 0
				ultimate = RdKGToolMath.EncodeBitArrayHelper(ultimate, 0)
				magicka = RdKGToolMath.EncodeBitArrayHelper(magicka, 0)
				stamina = RdKGToolMath.EncodeBitArrayHelper(stamina, 0)
				debuffs = RdKGToolMath.EncodeBitArrayHelper(debuffs, 0)
				--d("debuffs ulti: " .. debuffs)
				--d("Group")
				--d(debuffs)
				if players[i].buffs ~= nil and players[i].isPlayer == false then
					--d(debuffs)
					players[i].buffs.numPurgableBuffs = debuffs
				end
				players[i].resources = players[i].resources or {}
				players[i].resources.ultimateId = ultiId
				if ultiId ~= players[i].resources.previousUltimateId then
					RdKGToolGroup.NotifyUltimatesChangedCallbacks()
				end
				players[i].resources.previousUltimateId = ultiId
				players[i].resources.ultimatePercent = ultimate
				players[i].resources.magickaPercent = magicka
				players[i].resources.staminaPercent = stamina
				players[i].resources.lastPing = GetGameTimeMilliseconds()
				break
			end
		end
	end
end

function RdKGToolGroup.UpdateMemberDamage(unitTag, damage)
	if unitTag ~= nil and damage ~= nil then
		local players = RdKGToolGroup.state.players
		if players ~= nil then
			for i = 1, #players do
				if players[i].unitTag == unitTag then
					local temp = RdKGToolMath.Int24ToArray(damage)
					local debuffs = {}
					debuffs[1] = temp[22]
					debuffs[2] = temp[23]
					debuffs[3] = temp[24]
					debuffs = RdKGToolMath.EncodeBitArrayHelper(debuffs, 0)
					--d("debuffs damage: " .. debuffs)
					if players[i].buffs ~= nil and players[i].isPlayer == false then
						--d(debuffs)
						players[i].buffs.numPurgableBuffs = debuffs
					end
					temp[22] = 0
					temp[23] = 0
					temp[24] = 0
					temp = RdKGToolMath.ArrayToInt24(temp)
					players[i].meter.damage = players[i].meter.damage + temp
					break
				end
			end
		end
	end
end

function RdKGToolGroup.UpdateMemberHealing(unitTag, healing)
	if unitTag ~= nil and healing ~= nil then
		local players = RdKGToolGroup.state.players
		if players ~= nil then
			for i = 1, #players do
				if players[i].unitTag == unitTag then
					local temp = RdKGToolMath.Int24ToArray(healing)
					local debuffs = {}
					debuffs[1] = temp[22]
					debuffs[2] = temp[23]
					debuffs[3] = temp[24]
					debuffs = RdKGToolMath.EncodeBitArrayHelper(debuffs, 0)
					--d("debuffs healing: " .. debuffs)
					if players[i].buffs ~= nil and players[i].isPlayer == false then
						--d(debuffs)
						players[i].buffs.numPurgableBuffs = debuffs
					end
					temp[22] = 0
					temp[23] = 0
					temp[24] = 0
					temp = RdKGToolMath.ArrayToInt24(temp)
					players[i].meter.healing = players[i].meter.healing + temp
					break
				end
			end
		end
	end
end

function RdKGToolGroup.UpdateMemberVersionInformation(unitTag, versionInformation)
	if unitTag ~= nil and versionInformation ~= nil then
		local players = RdKGToolGroup.state.players
		if players ~= nil then
			for i = 1, #players do
				if players[i].unitTag == unitTag then
					players[i].clientVersion.major = versionInformation.major
					players[i].clientVersion.minor = versionInformation.minor
					players[i].clientVersion.revision = versionInformation.revision
					if RdKGToolGroup.state.versionCheckCallback ~= nil and type(RdKGToolGroup.state.versionCheckCallback) == "function" then
						RdKGToolGroup.state.versionCheckCallback(players[i])
					end
					break
				end
			end
		end
	end
end

function RdKGToolGroup.UpdateMemberSynergy(unitTag, synergyId, delay)
	if unitTag ~= nil and synergyId ~= nil and delay ~= nil then
		local players = RdKGToolGroup.state.players
		if players ~= nil then
			for i = 1, #players do
				if players[i].unitTag == unitTag then
					players[i].synergies[synergyId] = GetGameTimeMilliseconds() - delay * 100
					break
				end
			end
		end
	end
end

function RdKGToolGroup.UpdateDebuffs(unitTag, numDebuffs)
	if unitTag ~= nil and numDebuffs ~= nil then
		local players = RdKGToolGroup.state.players
		if players ~= nil then
			for i = 1, #players do
				if players[i].unitTag == unitTag then
					if players[i].buffs ~= nil and players[i].isPlayer == false then
						--d(numDebuffs)
						players[i].buffs.numPurgableBuffs = numDebuffs
						--d(numDebuffs)
					end
					break
				end
			end
		end
	end
end

function RdKGToolGroup.GetAdjustedNameFromUnitTag(unitTag)
	local name = nil
	if unitTag ~= nil then
		if RdKGToolGroup.groupVars.displayType == RdKGToolGroup.constants.BY_CHAR_NAME then
			name = GetUnitName(unitTag)
		elseif RdKGToolGroup.groupVars.displayType == RdKGToolGroup.constants.BY_DISPLAY_NAME then
			name = string.sub(GetUnitDisplayName(unitTag), 2)
		end
	end
	return name
end

function RdKGToolGroup.GetNameLinkFromDisplayCharName(fromName, fromDisplayName)
	local displayType = RdKGToolGroup.GetDisplayType()
	local link = ""
	if displayType == RdKGToolGroup.constants.BY_CHAR_NAME and fromName:sub(1,1) ~= "@" then
		fromName = zo_strformat("<<1>>", fromName)
		link = RdKGToolPL.CreateCharNameLink(fromName, fromName, false)
	else
		link = RdKGToolPL.CreateDisplayNameLink(fromDisplayName, fromDisplayName, false)
	end
	if link == "" then
		RdKGToolChat.SendChatMessage("Invalid FromName in GetNameLinkFromDisplayCharName", RdKGToolGroup.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
	end
	return link
end

function RdKGToolGroup.GetNameFromDisplayCharName(fromName, fromDisplayName)
	local displayType = RdKGToolGroup.GetDisplayType()
	local name = ""
	if fromName == nil then
		return fromDisplayName
	elseif fromDisplayName == nil then
		return fromName
	end
	if displayType == RdKGToolGroup.constants.BY_CHAR_NAME and fromName:sub(1,1) ~= "@" then
		name = fromName
	else
		name = fromDisplayName
	end
	return name
end

function RdKGToolGroup.IsCharNameInGroup(charName)
	local inGroup = false
	if charName ~= nil then
		local players = RdKGToolGroup.state.players
		if players ~= nil then
			for i = 1, #players do
				if players[i].charName == charName then
					inGroup = true
					break
				end
			end
		end
	end
	return inGroup
end

function RdKGToolGroup.GetUnitTagFromCharName(charName)
	local unitTag = nil
	if charName ~= nil then
		local players = RdKGToolGroup.state.players
		if players ~= nil then
			for i = 1, #players do
				if players[i].charName == charName then
					unitTag = players[i].unitTag
					break
				end
			end
		end
	end
	return unitTag
end

function RdKGToolGroup.GetUnitTagFromRawCharName(charName)
	local unitTag = nil
	if charName ~= nil then
		local players = RdKGToolGroup.state.players
		if players ~= nil then
			for i = 1, #players do
				if players[i].rawName == charName then
					unitTag = players[i].unitTag
					break
				end
			end
		end
	end
	return unitTag
end

function RdKGToolGroup.GetUnitFromRawCharName(charName)
	local player = nil
	if charName ~= nil then
		local players = RdKGToolGroup.state.players
		if players ~= nil then
			for i = 1, #players do
				if players[i].rawName == charName then
					player = players[i]
					break
				end
			end
		end
	end
	return player
end

function RdKGToolGroup.AdjustBgGroup()
	if IsActiveWorldBattleground() and RdKGToolGroup.state.lastLeader ~= nil then
		local players = RdKGToolGroup.state.players
		if players ~= nil then
			for i = 1, #players do
				if players[i].name == RdKGToolGroup.state.lastLeader.name and players[i].displayName == RdKGToolGroup.state.lastLeader.displayName then
					players[i].isLeader = true
				else
					players[i].isLeader = false
				end
			end
		end
	end
end

function RdKGToolGroup.SetBgCrown(charName, displayName)
	if IsActiveWorldBattleground() then
		local players = RdKGToolGroup.state.players
		if players ~= nil then
			for i = 1, #players do
				if players[i].charName == charName and players[i].displayName == displayName then
					players[i].isLeader = true
				else
					players[i].isLeader = false
				end
			end
		end
	end
end

function RdKGToolGroup.RemoveBgCrown(charName, displayName)
	if IsActiveWorldBattleground() then
		local players = RdKGToolGroup.state.players
		if players ~= nil then
			for i = 1, #players do
				if players[i].charName == charName and players[i].displayName == displayName then
					players[i].isLeader = false
				end
			end
		end
	end
end

function RdKGToolGroup.SetRole(charName, displayName, role)
	local players = RdKGToolGroup.state.players
	if players ~= nil then
		for i = 1, #players do
			if players[i].charName == charName and players[i].displayName == displayName then
				players[i].role = role
				break
			end
		end
	end
end

function RdKGToolGroup.SetVersionCheckCallback(checkFunction)
	RdKGToolGroup.state.versionCheckCallback = checkFunction
end


function RdKGToolGroup.AddAdminInformationChangedCallback(name, callback)
	if name ~= nil and callback ~= nil then
		local entryPresent = false
		for i = 1, #RdKGToolGroup.state.adminInformationChangedConsumers do
			if RdKGToolGroup.state.adminInformationChangedConsumers[i] ~= nil and RdKGToolGroup.state.adminInformationChangedConsumers[i].name == name then
				entryPresent = true
				break
			end
		end
		if entryPresent == false then
			local entry = {}
			entry.callback = callback
			entry.name = name
			table.insert(RdKGToolGroup.state.adminInformationChangedConsumers, entry)
		end
	end
end

function RdKGToolGroup.RemoveAdminInformationChangedCallback(name)
	if name ~= nil then
		for i = 1, #RdKGToolGroup.state.adminInformationChangedConsumers do
			if RdKGToolGroup.state.adminInformationChangedConsumers[i] ~= nil and RdKGToolGroup.state.adminInformationChangedConsumers[i].name == name then
				table.remove(RdKGToolGroup.state.adminInformationChangedConsumers, i)
				break
			end
		end
	end
end

function RdKGToolGroup.NotifyAdminInformationChangedCallbacks(unitTag)
	for i = 1, #RdKGToolGroup.state.adminInformationChangedConsumers do
		if RdKGToolGroup.state.adminInformationChangedConsumers[i] ~= nil and RdKGToolGroup.state.adminInformationChangedConsumers[i].callback ~= nil and type(RdKGToolGroup.state.adminInformationChangedConsumers[i].callback) == "function" then
			RdKGToolGroup.state.adminInformationChangedConsumers[i].callback(unitTag)
		end
	end
end

function RdKGToolGroup.AddUltimatesChangedCallback(name, callback)
	if name ~= nil and callback ~= nil then
		local entryPresent = false
		for i = 1, #RdKGToolGroup.state.ultimatesChangedConsumers do
			if RdKGToolGroup.state.ultimatesChangedConsumers[i] ~= nil and RdKGToolGroup.state.ultimatesChangedConsumers[i].name == name then
				entryPresent = true
				break
			end
		end
		if entryPresent == false then
			local entry = {}
			entry.callback = callback
			entry.name = name
			table.insert(RdKGToolGroup.state.ultimatesChangedConsumers, entry)
		end
	end
end

function RdKGToolGroup.RemoveUltimatesChangedCallback(name)
	if name ~= nil then
		for i = 1, #RdKGToolGroup.state.ultimatesChangedConsumers do
			if RdKGToolGroup.state.ultimatesChangedConsumers[i] ~= nil and RdKGToolGroup.state.ultimatesChangedConsumers[i].name == name then
				table.remove(RdKGToolGroup.state.ultimatesChangedConsumers, i)
				break
			end
		end
	end
end

function RdKGToolGroup.NotifyUltimatesChangedCallbacks()
	for i = 1, #RdKGToolGroup.state.ultimatesChangedConsumers do
		if RdKGToolGroup.state.ultimatesChangedConsumers[i] ~= nil and RdKGToolGroup.state.ultimatesChangedConsumers[i].callback ~= nil and type(RdKGToolGroup.state.groupChangedConsumers[i].callback) == "function" then
			RdKGToolGroup.state.ultimatesChangedConsumers[i].callback()
		end
	end
end

function RdKGToolGroup.AddGroupChangedCallback(name, callback)
	if name ~= nil and callback ~= nil then
		local entryPresent = false
		for i = 1, #RdKGToolGroup.state.groupChangedConsumers do
			if RdKGToolGroup.state.groupChangedConsumers[i] ~= nil and RdKGToolGroup.state.groupChangedConsumers[i].name == name then
				entryPresent = true
				break
			end
		end
		if entryPresent == false then
			local entry = {}
			entry.callback = callback
			entry.name = name
			table.insert(RdKGToolGroup.state.groupChangedConsumers, entry)
		end
	end
end

function RdKGToolGroup.RemoveGroupChangedCallback(name)
	if name ~= nil then
		for i = 1, #RdKGToolGroup.state.groupChangedConsumers do
			if RdKGToolGroup.state.groupChangedConsumers[i] ~= nil and RdKGToolGroup.state.groupChangedConsumers[i].name == name then
				table.remove(RdKGToolGroup.state.groupChangedConsumers, i)
				break
			end
		end
	end
end

function RdKGToolGroup.NotifyGroupChangedCallbacks()
	for i = 1, #RdKGToolGroup.state.groupChangedConsumers do
		if RdKGToolGroup.state.groupChangedConsumers[i] ~= nil and RdKGToolGroup.state.groupChangedConsumers[i].callback ~= nil and type(RdKGToolGroup.state.groupChangedConsumers[i].callback) == "function" then
			RdKGToolGroup.state.groupChangedConsumers[i].callback()
		end
	end
end

--internal functions
function RdKGToolGroup.GetCurrentPlainGroup()
	local players = {}
	local unitTags = RdKGToolGroup.GetUnitTags()
	for i = 1, #unitTags do
		players[i] = {}
		players[i].unitTag = unitTags[i]
		players[i].name = RdKGToolGroup.GetAdjustedNameFromUnitTag(unitTags[i])
		players[i].charName = GetUnitName(unitTags[i])
		players[i].rawName = GetRawUnitName(unitTags[i])
		players[i].displayName = GetUnitDisplayName(unitTags[i])
		if GetUnitDisplayName(unitTags[i]) == GetUnitDisplayName("player") and GetUnitName(unitTags[i]) == GetUnitName("player") then
			players[i].isPlayer = true
			players[i].clientVersion = RdKGToolVersioning.GetVersionArray(RdKGTool.versionString)
		else
			players[i].isPlayer = false
			players[i].clientVersion = {}
			players[i].clientVersion.major = 0
			players[i].clientVersion.minor = 0
			players[i].clientVersion.revision = 0
		end
		players[i].isLeader = IsUnitGroupLeader(unitTags[i])
		players[i].isOnline = IsUnitOnline(unitTags[i])
		players[i].buffs = {}
		players[i].buffs.numPurgableBuffs = 0
		players[i].distances = {}
		players[i].distances.fromPlayer = 0
		players[i].distances.fromLeader = 0
		players[i].coordinates = {}
		players[i].coordinates.x = 0
		players[i].coordinates.y = 0
		players[i].coordinates.height = 0
		players[i].coordinates.worldX = 0
		players[i].coordinates.worldY = 0
		players[i].coordinates.worldHeight = 0
		players[i].resources = {}
		players[i].resources.lastPing = 0
		players[i].meter = {}
		players[i].meter.damage = 0
		players[i].meter.healing = 0

		players[i].clientVersion.versionAlertSent = false
		players[i].admin = {}
		players[i].synergies = {}
		players[i].isDead = IsUnitDead(unitTag)
		players[i].isReincarnating = IsUnitReincarnating(unitTag)
		players[i].isBeingResurrected = IsUnitBeingResurrected(unitTag)
		players[i].role = nil
		players[i].isInCombat = false
		players[i].isInStealth = 0
		players[i].lastKnownHealth = GetUnitPower(players[i].unitTag, POWERTYPE_HEALTH)
	end
	return players
end

function RdKGToolGroup.InitializeGroup()
	RdKGToolGroup.state.players = {}
	RdKGToolGroup.state.players = RdKGToolGroup.GetCurrentPlainGroup()
	
	
end

function RdKGToolGroup.ClearGroup()
	local players = RdKGToolGroup.state.players
	if players ~= nil then
		for i = 1, #players do
			players[i].unitTag = nil
			players[i].name = nil
			players[i].charName = nil
			players[i].rawName = nil
			players[i].displayName = nil
			players[i].isPlayer = nil
			players[i].isLeader = nil
			players[i].isOnline = nil
			players[i].buffs = nil
			players[i].buffs.numPurgableBuffs = nil
			players[i].distances = nil
			players[i].distances.fromPlayer = nil
			players[i].distances.fromLeader = nil
			players[i].coordinates.x = nil
			players[i].coordinates.y = nil
			players[i].coordinates.height = nil
			players[i].coordinates.worldX = nil
			players[i].coordinates.worldY = nil
			players[i].coordinates.worldHeight = nil
			players[i].coordinates = nil
			players[i].resources.lastPing = nil
			players[i].resources = nil
			players[i].meter.damage = nil
			players[i].meter.healing = nil
			players[i].meter = nil
			players[i].isInCombat = nil
			players[i].isInStealth = nil
			players[i].clientVersion.major = nil
			players[i].clientVersion.minor = nil
			players[i].clientVersion.revision = nil
			players[i].clientVersion.versionAlertSent = nil
			players[i].clientVersion = nil
			players[i].admin = nil
			players[i].synergies = nil
			players[i].isDead = nil
			players[i].isReincarnating = nil
			players[i].isBeingResurrected = nil
			players[i].role = nil
			players[i].lastKnownHealth = nil
			players[i] = nil
			
		end
	end
end

function RdKGToolGroup.UpdateGroup()
	local oldPlayers = RdKGToolGroup.state.players
	local newPlayers = RdKGToolGroup.GetCurrentPlainGroup()
	for i = 1, #newPlayers do
		local newPlayer = newPlayers[i]
		for j = 1, #oldPlayers do
			
			local oldPlayer = oldPlayers[j]
			if newPlayer.displayName == oldPlayer.displayName and newPlayer.charName == oldPlayer.charName then
				newPlayer.buffs = oldPlayer.buffs
				newPlayer.distances = oldPlayer.distances
				newPlayer.resources = oldPlayer.resources
				newPlayer.meter = oldPlayer.meter
				newPlayer.admin = oldPlayer.admin
				newPlayer.synergies = oldPlayer.synergies
				newPlayer.clientVersion = oldPlayer.clientVersion
				newPlayer.role = oldPlayer.role
			end
		end
	end
	RdKGToolGroup.state.players = newPlayers
	RdKGToolGroup.NotifyGroupChangedCallbacks()
end

function RdKGToolGroup.EnableGroup()
	RdKGToolGroup.ClearGroup()
	RdKGToolGroup.InitializeGroup()
	EVENT_MANAGER:RegisterForEvent(RdKGToolGroup.callbackName, EVENT_GROUP_MEMBER_CONNECTED_STATUS, RdKGToolGroup.GroupMemberOnConnectedStatus)
	EVENT_MANAGER:RegisterForEvent(RdKGToolGroup.callbackName, EVENT_GROUP_MEMBER_JOINED, RdKGToolGroup.GroupMemberOnJoined)
	EVENT_MANAGER:RegisterForEvent(RdKGToolGroup.callbackName, EVENT_GROUP_MEMBER_LEFT, RdKGToolGroup.GroupMemberOnLeft)
	EVENT_MANAGER:RegisterForEvent(RdKGToolGroup.callbackName, EVENT_GROUP_UPDATE, RdKGToolGroup.GroupMemberOnUpdate)
	EVENT_MANAGER:RegisterForEvent(RdKGToolGroup.callbackName, EVENT_LEADER_UPDATE, RdKGToolGroup.GroupMemberOnLeaderUpdate)
	EVENT_MANAGER:RegisterForEvent(RdKGToolGroup.callbackName, EVENT_PLAYER_ACTIVATED, RdKGToolGroup.GroupMemberOnPlayerActivated)
	EVENT_MANAGER:RegisterForEvent(RdKGToolGroup.callbackName, EVENT_PLAYER_DEACTIVATED, RdKGToolGroup.GroupMemberOnPlayerDeactivated)
	EVENT_MANAGER:RegisterForUpdate(RdKGToolGroup.callbackName, RdKGToolGroup.config.combatUpdateInterval, RdKGToolGroup.UpdateStatusLoop)
end

function RdKGToolGroup.DisableGroup()
	EVENT_MANAGER:UnregisterForEvent(RdKGToolGroup.callbackName, EVENT_GROUP_MEMBER_CONNECTED_STATUS)
	EVENT_MANAGER:UnregisterForEvent(RdKGToolGroup.callbackName, EVENT_GROUP_MEMBER_JOINED)
	EVENT_MANAGER:UnregisterForEvent(RdKGToolGroup.callbackName, EVENT_GROUP_MEMBER_LEFT)
	EVENT_MANAGER:UnregisterForEvent(RdKGToolGroup.callbackName, EVENT_GROUP_UPDATE)
	EVENT_MANAGER:UnregisterForEvent(RdKGToolGroup.callbackName, EVENT_LEADER_UPDATE)
	EVENT_MANAGER:UnregisterForEvent(RdKGToolGroup.callbackName, EVENT_PLAYER_ACTIVATED)
	EVENT_MANAGER:UnregisterForEvent(RdKGToolGroup.callbackName, EVENT_PLAYER_DEACTIVATED)
	EVENT_MANAGER:UnregisterForUpdate(RdKGToolGroup.callbackName)
	RdKGToolGroup.ClearGroup()
end



function RdKGToolGroup.GetUnitTags()
	local unitTags = {}
	local groupSize = GetGroupSize()
	if groupSize > 0 then
		for i = 1, groupSize do
			unitTags[i] = GetGroupUnitTagByIndex(i)
		end
	else
		unitTags[1] = "player"
	end
	return unitTags
end

function RdKGToolGroup.GetUnitTagForPlayer()
	local unitTag = "player"
	local players = RdKGToolGroup.state.players
	if players ~= nil then
		for i = 1, #players do
			if players[i].displayName == GetUnitDisplayName("player") and players[i].charName == GetUnitName("player") then
				unitTag = players[i].unitTag
				break
			end
		end
	end
	return unitTag
end

function RdKGToolGroup.SortBuffLists(list)
	if list ~= nil then
		
		local itemCount = #list
		repeat
			local hasChanged = false
			itemCount=itemCount - 1
			for i = 1, itemCount do
				--d("sort loop")
				if list[i].name > list[i + 1].name then
					list[i], list[i + 1] = list[i + 1], list[i]
					hasChanged = true
				end
			end
		until hasChanged == false
		return list
	end
	return nil
end

function RdKGToolGroup.CheckForAbilityActive(buffs, buff, abilityIds, alreadyUp)
	if alreadyUp == nil then
		alreadyUp = false
	end
	local abilityPresent = alreadyUp
	if abilityPresent == false then
		for i = 1, #abilityIds do
			if buff.abilityId == abilityIds[i] then
				abilityPresent = true
				--d("identified")
				break
			end
		end
	end
	return abilityPresent
end

function RdKGToolGroup.CheckForAbility(buffs, buff, abilityIds, alreadyUp)
	if alreadyUp == nil then
		alreadyUp = false
	end
	local abilityPresent = alreadyUp
	local identified = false
	for i = 1, #abilityIds do
		if buff.abilityId == abilityIds[i] then
			abilityPresent = true
			identified = true
			--d("identified")
			break
		end
	end
	return abilityPresent, identified
end

function RdKGToolGroup.CheckForPotions(buffs, buff)
	local isImmovable = RdKGToolGroup.CheckForAbilityActive(buffs, buff, RdKGToolGroup.abilityIds.immovablePot, buffs.specialInformation.potion.immovablePot)
	if buffs.specialInformation.potion.immovablePot == false then
		buffs.specialInformation.potion.immovablePot = isImmovable
		if isImmovable == true then
			buffs.specialInformation.potion.immovableStart = buff.started
			buffs.specialInformation.potion.immovableEnd = buff.ending
			buffs.specialInformation.potion.started = buff.started
		else
			buffs.specialInformation.potion.immovableStart = nil
			buffs.specialInformation.potion.immovableEnd = nil
			
			-- U30+ Change (Temporary Fix)
			--[[
			if libPB.IS_CRAFTED_POTION_BUFF[buff.abilityId] == true or libPB.IS_NON_CRAFTED_POTION_BUFF[buff.abilityId] == true or libPB.IS_CROWNSTORE_POTION_BUFF[buff.abilityId] == true then
				buffs.specialInformation.potion.started = buff.started
			end
			]]
			if RdKGToolGroup.abilityIds.isPotion[buff.abilityId] == true then
				buffs.specialInformation.potion.started = buff.started
			end
		end
		--d(buff.abilityId)
		-- U30+ Change (Temporary Fix)
		--[[
		if libPB.IS_CRAFTED_POTION_BUFF[buff.abilityId] == true then
			buffs.specialInformation.potion.type = RdKGToolGroup.constants.potionTypes.CRAFTED
		elseif libPB.IS_NON_CRAFTED_POTION_BUFF[buff.abilityId] == true then
			buffs.specialInformation.potion.type = RdKGToolGroup.constants.potionTypes.NON_CRAFTED
		elseif libPB.IS_CROWNSTORE_POTION_BUFF[buff.abilityId] == true then
			buffs.specialInformation.potion.type = RdKGToolGroup.constants.potionTypes.CROWN
		end
		if RdKGToolGroup.abilityIds.alliancePot[buff.abilityId] == true then
			buffs.specialInformation.potion.type = RdKGToolGroup.constants.potionTypes.ALLIANCE
		end
		]]
		if RdKGToolGroup.abilityIds.isPotion[buff.abilityId] == true then
			buffs.specialInformation.potion.type = RdKGToolGroup.constants.potionTypes.CRAFTED
		end
	end
	
end

function RdKGToolGroup.CheckForFoodDrinks(buffs, buff)
	buffs.specialInformation.foodDrink = buffs.specialInformation.foodDrink or {}
	--d(buff.abilityId)
	--d(libFDB)
	--d(libFDB.IS_FOOD_BUFF[buff.abilityId])
	--d("------")
	--d(libFDB:IsAbilityADrinkBuff(buff.abilityId))
	if libFDB:IsAbilityADrinkBuff(buff.abilityId) ~= nil then
		--d("Food identified")
		buffs.specialInformation.foodDrink.started = buff.started
		buffs.specialInformation.foodDrink.ending = buff.ending
		buffs.specialInformation.foodDrink.active = true
		--d(buff.abilityId)
	end
end

function RdKGToolGroup.AdjustRapidValues(buffs, buff, abilityIds, rapidMorph)
	local active, identified = RdKGToolGroup.CheckForAbility(buffs, buff, abilityIds, rapidMorph.active)
	if rapidMorph.active == false and identified == true then
		--d(buff.abilityId)
		rapidMorph.active = active
		rapidMorph.started = buff.started
		rapidMorph.ending = buff.started + 8 -- buff.ending -- result of ending = 30 secs instead of 8
		rapidMorph.uptime = rapidMorph.ending - buff.started
		--d(buff.ending)
	end
end

function RdKGToolGroup.CheckForRapid(buffs, buff)
	--[[
	RdKGToolGroup.AdjustRapidValues(buffs, buff, RdKGToolGroup.abilityIds.rapidManeuver, buffs.specialInformation.rapidManeuverOn)
	RdKGToolGroup.AdjustRapidValues(buffs, buff, RdKGToolGroup.abilityIds.chargingManeuverMajor, buffs.specialInformation.chargingManeuverMajorOn)
	RdKGToolGroup.AdjustRapidValues(buffs, buff, RdKGToolGroup.abilityIds.chargingManeuverMinor, buffs.specialInformation.chargingManeuverMinorOn)
	RdKGToolGroup.AdjustRapidValues(buffs, buff, RdKGToolGroup.abilityIds.retreatingManeuver, buffs.specialInformation.retreatingManeuverOn)
	]]
	RdKGToolGroup.AdjustRapidValues(buffs, buff, RdKGToolGroup.abilityIds.majorExpedition, buffs.specialInformation.majorExpeditionOn)
	RdKGToolGroup.AdjustRapidValues(buffs, buff, RdKGToolGroup.abilityIds.minorExpedition, buffs.specialInformation.minorExpeditionOn)
end

function RdKGToolGroup.CheckForShalk(buffs, buff)
	if RdKGToolGroup.abilityIds.subterraneanAssault[buff.abilityId] == true then
		buffs.specialInformation.subterraneanAssault.active = true
		buffs.specialInformation.subterraneanAssault.started = buff.started
		buffs.specialInformation.subterraneanAssault.ending = buff.ending
		buffs.specialInformation.subterraneanAssault.waveTwo = false
		--d(buff.started)
	elseif RdKGToolGroup.abilityIds.subterraneanAssaultWaveTwo[buff.abilityId] == true then
		buffs.specialInformation.subterraneanAssault.active = true
		buffs.specialInformation.subterraneanAssault.started = buff.started
		buffs.specialInformation.subterraneanAssault.ending = buff.ending
		buffs.specialInformation.subterraneanAssault.waveTwo = true
	elseif RdKGToolGroup.abilityIds.deepFissure[buff.abilityId] == true then
		buffs.specialInformation.deepFissure.active = true
		buffs.specialInformation.deepFissure.started = buff.started
		buffs.specialInformation.deepFissure.ending = buff.ending
		buffs.specialInformation.deepFissure.waveTwo = false
	elseif RdKGToolGroup.abilityIds.deepFissureWaveTwo[buff.abilityId] == true then
		buffs.specialInformation.deepFissure.active = true
		buffs.specialInformation.deepFissure.started = buff.started
		buffs.specialInformation.deepFissure.ending = buff.ending
		buffs.specialInformation.deepFissure.waveTwo = true
	end
	
end

function RdKGToolGroup.CheckForProximityDetonation(buffs, buff)
	if RdKGToolGroup.abilityIds.proximityDetonation[buff.abilityId] == true then
		buffs.specialInformation.proximityDetonation.active = true
		buffs.specialInformation.proximityDetonation.started = buff.started
		buffs.specialInformation.proximityDetonation.ending = buff.ending
	end
end

function RdKGToolGroup.CheckForSoulOfFlame(buffs, buff)
	if RdKGToolGroup.abilityIds.soulOfFlame[buff.abilityId] == true then
		buffs.specialInformation.soulOfFlame.active = true
		buffs.specialInformation.soulOfFlame.started = buff.started
		buffs.specialInformation.soulOfFlame.ending = buff.ending
	end
end

function RdKGToolGroup.RunSpecialChecks(buffs, buff)
	RdKGToolGroup.CheckForRapid(buffs, buff)
	RdKGToolGroup.CheckForPotions(buffs, buff)
	RdKGToolGroup.CheckForFoodDrinks(buffs, buff)
	RdKGToolGroup.CheckForProximityDetonation(buffs, buff)
	RdKGToolGroup.CheckForShalk(buffs, buff)
	RdKGToolGroup.CheckForSoulOfFlame(buffs, buff)
end

function RdKGToolGroup.GetLeaderUnitTag()
	local players = RdKGToolGroup.state.players
	local unitTag = "player"
	if players ~= nil then
		for i = 1, #players do
			if players[i].isLeader == true then
				unitTag = players[i].unitTag
				break
			end
		end
	end
	return unitTag
end

function RdKGToolGroup.GetLeaderUnit()
	local entry = nil
	local players = RdKGToolGroup.state.players
	if players ~= nil then
		for i = 1, #players do
			if players[i].isLeader == true then
				entry = players[i]
				break
			end
		end
	end
	return entry
end

function RdKGToolGroup.CalculateGroupDistances(unitTag, field)
	if unitTag ~= nil and field ~= nil then
		local players = RdKGToolGroup.state.players
		local x, y = nil, nil
		local playerX, playerY = nil, nil
		if lib3d:IsValidZone() then
			x, y = GetMapPlayerPosition(unitTag)
			if x ~= nil and x ~= 0 and y ~= nil and y ~= 0 then
				playerX, playerY = lib3d:LocalToWorld(x, y)
			end
		end
		for i = 1, #players do
			if lib3d:IsValidZone() then
				if IsUnitGrouped("player") == true then
					local x, y = GetMapPlayerPosition(players[i].unitTag)
					if x ~= nil and y ~= nil and x ~= 0 and y ~= 0 then
						local memberX, memberY = lib3d:LocalToWorld(x, y)
						if playerX ~= nil and playerY ~= nil and memberX ~= nil and memberY ~= nil then
							local distanceX = playerX - memberX
							local distanceY = playerY - memberY
							players[i].distances[field] = math.sqrt((distanceX * distanceX) + (distanceY * distanceY))
						else
							players[i].distances[field] = nil
						end
					end
				else
					players[i].distances[field] = 0
				end
			else
				players[i].distances[field] = nil
			end
		end
	end
end

function RdKGToolGroup.UpdateDisplayNames()
	local players = RdKGToolGroup.state.players
	if players ~= nil then
		for i = 1, #players do
			players[i].name = RdKGToolGroup.GetAdjustedNameFromUnitTag(players[i].unitTag)
		end
	end
	RdKGToolGroup.NotifyGroupChangedCallbacks()
end

function RdKGToolGroup.ClearDamageHealingMeter()
	local players = RdKGToolGroup.state.players
	if players ~= nil then
		for i = 1, #players do
			players[i].meter.damage = 0
			players[i].meter.healing = 0
		end
	end
end

function RdKGToolGroup.GetPlayerByUnitTag(unitTag)
	local player = nil
	local players = RdKGToolGroup.state.players
	if players ~= nil then
		for i = 1, #players do
			if players[i].unitTag == unitTag then
				player = players[i]
				break
			end
		end
	end
	return player
end

function RdKGToolGroup.SetCrBgTpHealBuffs(buffs)
	local newBuffs = {}
	if buffs ~= nil then
		for i = 1, #buffs do
			for j = 1, #buffs[i].ids do
				newBuffs[buffs[i].ids[j]] = buffs[i].name
			end
		end
	end
	RdKGToolGroup.state.crBgTpHealBuffs = newBuffs
end

function RdKGToolGroup.CheckCrBgTpHealBuff(buffs, buff)
	--buff.name, buff.started, buff.ending, buff.slot, buff.stackCount, buff.iconFilename, buff.buffType, buff.effectType, buff.abilityType, buff.statusEffectType, buff.abilityId, buff.canClickOff, buff.castByPlayer
	local item = RdKGToolGroup.state.crBgTpHealBuffs[buff.abilityId]
	if item ~= nil then
		
		buffs.specialInformation.crBgTpHealBuffs[item] = buffs.specialInformation.crBgTpHealBuffs[item] or {}
		buffs.specialInformation.crBgTpHealBuffs[item].started = buff.started
		buffs.specialInformation.crBgTpHealBuffs[item].ending = buff.ending
		--buffs.specialInformation.crBgTpHealBuffs[item].remaining = buff.ending - (GetGameTimeMilliseconds() / 1000)
		--if buffs.specialInformation.crBgTpHealBuffs[item].remaining < 0 then
		--	buffs.specialInformation.crBgTpHealBuffs[item].remaining = 0
		--end
		--buffs.specialInformation.crBgTpHealBuffs[item].active = true
	end
end

--Admin Functionality
function RdKGToolGroup.SetAdminMundusInformation(index)
	local player = RdKGToolGroup.state.players[index]
	if player ~= nil then
		player.admin = player.admin or {}
		player.admin.mundus = player.admin.mundus or {}
		local filter = RdKGTool.admin.constants.config.MUNDUS_FILTER
		local buffs = GetNumBuffs(player.unitTag)
		local stoneIndex = 1
		player.admin.mundus.stone1 = "-"
		player.admin.mundus.stone2 = "-"
		for i = 1, buffs do
			local name, _, _, _, _, _, _, _, _, _, _, _, _ = GetUnitBuffInfo(player.unitTag, i)
			if string.match(name, filter) then
				player.admin.mundus["stone" .. stoneIndex] = zo_strformat("<<1>>", string.gsub(name, filter, ""))
				stoneIndex = stoneIndex + 1
			end
		end
	end
end

function RdKGToolGroup.RetrieveAdminMundusInformation(index)
	--d(index)
	if index ~= nil and index >= 1 and index <= 24 and #RdKGToolGroup.state.players >= index then
		RdKGToolGroup.SetAdminMundusInformation(index)
	elseif index ~= nil and (index == 25 or index == 0) then
		for i = 1, #RdKGToolGroup.state.players do
			RdKGToolGroup.SetAdminMundusInformation(i)
		end
	end
	if RdKGToolGroup.state.players[index] ~= nil then
		RdKGToolGroup.NotifyAdminInformationChangedCallbacks(RdKGToolGroup.state.players[index].unitTag)
	end
end

--Admin Networking
function RdKGToolGroup.HandleAdminAoeResponse(message)
	local player = RdKGToolGroup.GetPlayerByUnitTag(message.pingTag)
	if player ~= nil then
		local bitfield = RdKGToolMath.DecodeBitArrayHelper(message.b3)
		player.admin = player.admin or {}
		player.admin.client = player.admin.client or {}
		player.admin.client.aoe = {}
		player.admin.client.aoe.tellsEnabled = RdKGToolMath.BitToBoolean(bitfield[7])
		player.admin.client.aoe.customColorEnabled = RdKGToolMath.BitToBoolean(bitfield[8])
		bitfield[7] = 0
		bitfield[8] = 0
		player.admin.client.aoe.friendlyBrightness = RdKGToolMath.EncodeBitArrayHelper(bitfield, 0)
		player.admin.client.aoe.enemyBrightness = message.b2
		
		RdKGToolGroup.NotifyAdminInformationChangedCallbacks(message.pingTag)
	end
end

function RdKGToolGroup.HandleAdminSoundResponse(message)
	local player = RdKGToolGroup.GetPlayerByUnitTag(message.pingTag)
	if player ~= nil then
		local bitfield = RdKGToolMath.DecodeBitArrayHelper(message.b1)
		player.admin = player.admin or {}
		player.admin.client = player.admin.client or {}
		player.admin.client.sound = {}
		player.admin.client.sound.soundEnabled = RdKGToolMath.BitToBoolean(bitfield[8])
		bitfield[8] = 0
		player.admin.client.sound.audioVolume = RdKGToolMath.EncodeBitArrayHelper(bitfield, 0)
		player.admin.client.sound.uiVolume = message.b2
		player.admin.client.sound.sfxVolume = message.b3
		
		RdKGToolGroup.NotifyAdminInformationChangedCallbacks(message.pingTag)
	end
end

function RdKGToolGroup.HandleAdminGraphicsResponse(message)
	local player = RdKGToolGroup.GetPlayerByUnitTag(message.pingTag)
	if player ~= nil then
		local bitfield = RdKGToolNetworking.DecodeMessageFromBitArray(message.b1, message.b2, message.b3)
		local messageIdentifier = RdKGToolMath.EncodeBitArrayHelper(RdKGToolMath.CopyBitfieldRange(bitfield, RdKGToolMath.CreateEmptyBitfield(3), 3, 22, 1),0)
		player.admin = player.admin or {}
		player.admin.client = player.admin.client or {}
		player.admin.client.graphics = player.admin.client.graphics or {}
		--d(message)
		if messageIdentifier == RdKGToolNetworking.messageIdentifiers.adminResponse.graphics.MESSAGE_1 then
			RdKGToolGroup.HandleAdminGraphicsMessage1(player, message, bitfield)
		elseif messageIdentifier == RdKGToolNetworking.messageIdentifiers.adminResponse.graphics.MESSAGE_2 then
			RdKGToolGroup.HandleAdminGraphicsMessage2(player, message, bitfield)
		elseif messageIdentifier == RdKGToolNetworking.messageIdentifiers.adminResponse.graphics.MESSAGE_3 then
			RdKGToolGroup.HandleAdminGraphicsMessage3(player, message, bitfield)
		elseif messageIdentifier == RdKGToolNetworking.messageIdentifiers.adminResponse.graphics.MESSAGE_4 then
			RdKGToolGroup.HandleAdminGraphicsMessage4(player, message, bitfield)
		end
		RdKGToolGroup.NotifyAdminInformationChangedCallbacks(message.pingTag)
	end
end

function RdKGToolGroup.HandleAdminGraphicsMessage1(player, message, bitfield)
	local graphics = player.admin.client.graphics
	
	graphics.windowMode = RdKGToolMath.EncodeBitArrayHelper(RdKGToolMath.CopyBitfieldRange(bitfield, RdKGToolMath.CreateEmptyBitfield(2), 2, 19, 1), 0)
	graphics.vsync = RdKGToolMath.BitToBoolean(bitfield[21])
	
	graphics.resWidth = RdKGToolMath.ArrayToInt24(RdKGToolMath.CopyBitfieldRange(bitfield, RdKGToolMath.CreateEmptyBitfield(24), 18, 1, 1))
	--d("-----")
	--d(bitfield)
end

function RdKGToolGroup.HandleAdminGraphicsMessage2(player, message, bitfield)
	local graphics = player.admin.client.graphics
	
	graphics.antiAliasing = RdKGToolMath.BitToBoolean(bitfield[19])
	graphics.ambient = RdKGToolMath.BitToBoolean(bitfield[20])
	graphics.bloom = RdKGToolMath.BitToBoolean(bitfield[21])
	
	graphics.resHeight = RdKGToolMath.ArrayToInt24(RdKGToolMath.CopyBitfieldRange(bitfield, RdKGToolMath.CreateEmptyBitfield(24), 18, 1, 1))

end

function RdKGToolGroup.HandleAdminGraphicsMessage3(player, message, bitfield)
	local graphics = player.admin.client.graphics
	
	graphics.depthOfField = RdKGToolMath.BitToBoolean(bitfield[19])
	graphics.distortion = RdKGToolMath.BitToBoolean(bitfield[20])
	graphics.sunlight = RdKGToolMath.BitToBoolean(bitfield[21])
	
	graphics.particleMaximum = RdKGToolMath.ArrayToInt24(RdKGToolMath.CopyBitfieldRange(bitfield, RdKGToolMath.CreateEmptyBitfield(24), 11, 1, 1)) + 768
	graphics.particleSupressDistance = RdKGToolMath.ArrayToInt24(RdKGToolMath.CopyBitfieldRange(bitfield, RdKGToolMath.CreateEmptyBitfield(24), 7, 12, 1))

end

function RdKGToolGroup.HandleAdminGraphicsMessage4(player, message, bitfield)
	local graphics = player.admin.client.graphics
	
	graphics.allyEffects = RdKGToolMath.BitToBoolean(bitfield[18])
	
	graphics.viewDistance = RdKGToolMath.ArrayToInt24(RdKGToolMath.CopyBitfieldRange(bitfield, RdKGToolMath.CreateEmptyBitfield(24), 7, 1, 1))
	graphics.reflectionQuality = RdKGToolMath.ArrayToInt24(RdKGToolMath.CopyBitfieldRange(bitfield, RdKGToolMath.CreateEmptyBitfield(24), 2, 8, 1))
	graphics.shadowQuality = RdKGToolMath.ArrayToInt24(RdKGToolMath.CopyBitfieldRange(bitfield, RdKGToolMath.CreateEmptyBitfield(24), 3, 10, 1))
	graphics.reflectionQuality = RdKGToolMath.ArrayToInt24(RdKGToolMath.CopyBitfieldRange(bitfield, RdKGToolMath.CreateEmptyBitfield(24), 2, 13, 1))
	graphics.graphicPresets = RdKGToolMath.ArrayToInt24(RdKGToolMath.CopyBitfieldRange(bitfield, RdKGToolMath.CreateEmptyBitfield(24), 3, 15, 1))
	graphics.subsamplingQuality = RdKGToolMath.ArrayToInt24(RdKGToolMath.CopyBitfieldRange(bitfield, RdKGToolMath.CreateEmptyBitfield(24), 2, 19, 1))
end

function RdKGToolGroup.HandleAdminAddonResponse(message)
	local player = RdKGToolGroup.GetPlayerByUnitTag(message.pingTag)
	if player ~= nil then
		if message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_ADDON_CONFIGURATION_1 then
			RdKGToolGroup.HandleAdminAddon1Response(player, message)
		elseif message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_ADDON_CONFIGURATION_2 then
			RdKGToolGroup.HandleAdminAddon2Response(player, message)
		elseif message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_ADDON_CONFIGURATION_3 then
			RdKGToolGroup.HandleAdminAddon3Response(player, message)
		elseif message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_ADDON_CONFIGURATION_4 then
			RdKGToolGroup.HandleAdminAddon4Response(player, message)
		elseif message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_ADDON_CONFIGURATION_5 then
			RdKGToolGroup.HandleAdminAddon5Response(player, message)
		elseif message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_ADDON_CONFIGURATION_6 then
			RdKGToolGroup.HandleAdminAddon6Response(player, message)
		elseif message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_ADDON_CONFIGURATION_7 then
			RdKGToolGroup.HandleAdminAddon7Response(player, message)
		elseif message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_ADDON_CONFIGURATION_8 then
			RdKGToolGroup.HandleAdminAddon8Response(player, message)
		elseif message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_ADDON_CONFIGURATION_9 then
			RdKGToolGroup.HandleAdminAddon9Response(player, message)
		end
		RdKGToolGroup.NotifyAdminInformationChangedCallbacks(message.pingTag)
	end
end

function RdKGToolGroup.HandleAdminAddon1Response(player, message)
	--Crown / debuff overview / rapid tracker / health, damage overview / potion overview
	local bitfield = RdKGToolNetworking.DecodeMessageFromBitArray(message.b1, message.b2, message.b3)
	--d(bitfield)
	player.admin = player.admin or {}
	player.admin.addon = player.admin.addon or {}
	player.admin.addon.crown = {}
	player.admin.addon.dbo = {}
	player.admin.addon.rt = {}
	player.admin.addon.hdm = {}
	player.admin.addon.po = {}
	
	--crown
	player.admin.addon.crown.enabled = RdKGToolMath.BitToBoolean(bitfield[24])
	
	local tempField = RdKGToolMath.CreateEmptyBitfield(24)
	tempField = RdKGToolMath.CopyBitfieldRange(bitfield, tempField, 10, 9, 1)
	player.admin.addon.crown.size = RdKGToolMath.ArrayToInt24(tempField)
	
	tempField = RdKGToolMath.CreateEmptyBitfield(24)
	tempField = RdKGToolMath.CopyBitfieldRange(bitfield, tempField, 5, 19, 1)
	player.admin.addon.crown.selectedCrown = RdKGToolMath.ArrayToInt24(tempField)
	
	--hdm
	player.admin.addon.hdm.windowEnabled = RdKGToolMath.BitToBoolean(bitfield[3])
	player.admin.addon.hdm.enabled = RdKGToolMath.BitToBoolean(bitfield[4])
	
	tempField = RdKGToolMath.CreateEmptyBitfield(24)
	tempField = RdKGToolMath.CopyBitfieldRange(bitfield, tempField, 2, 1, 1)
	player.admin.addon.hdm.viewMode = RdKGToolMath.EncodeBitArrayHelper(tempField, 0)
	
	--dbo, rt, po
	player.admin.addon.dbo.enabled = RdKGToolMath.BitToBoolean(bitfield[5])
	player.admin.addon.rt.enabled = RdKGToolMath.BitToBoolean(bitfield[6])
	player.admin.addon.po.soundEnabled = RdKGToolMath.BitToBoolean(bitfield[7])
	player.admin.addon.po.enabled = RdKGToolMath.BitToBoolean(bitfield[8])
	
	
end

function RdKGToolGroup.HandleAdminAddon2Response(player, message)
	--ftcv [pt.1]
	local bitfield = RdKGToolNetworking.DecodeMessageFromBitArray(message.b1, message.b2, message.b3)
	player.admin = player.admin or {}
	player.admin.addon = player.admin.addon or {}
	player.admin.addon.ftcv = player.admin.addon.ftcv or {}
	
	player.admin.addon.ftcv.enabled = RdKGToolMath.BitToBoolean(bitfield[8])
	
	local tempField = RdKGToolMath.CreateEmptyBitfield(24)
	tempField = RdKGToolMath.CopyBitfieldRange(bitfield, tempField, 7, 9, 1)
	player.admin.addon.ftcv.sizeClose = RdKGToolMath.EncodeBitArrayHelper(tempField, 0)
	
	tempField = RdKGToolMath.CreateEmptyBitfield(24)
	tempField = RdKGToolMath.CopyBitfieldRange(bitfield, tempField, 7, 1, 1)
	player.admin.addon.ftcv.sizeFar = RdKGToolMath.EncodeBitArrayHelper(tempField, 0)
	
	tempField = RdKGToolMath.CreateEmptyBitfield(24)
	tempField = RdKGToolMath.CopyBitfieldRange(bitfield, tempField, 3, 22, 1)
	player.admin.addon.ftcv.minDistance = RdKGToolMath.EncodeBitArrayHelper(tempField, 0)
	
	tempField = RdKGToolMath.CreateEmptyBitfield(24)
	tempField = RdKGToolMath.CopyBitfieldRange(bitfield, tempField, 5, 17, 1)
	player.admin.addon.ftcv.maxDistance = RdKGToolMath.EncodeBitArrayHelper(tempField, 0)
	
end

function RdKGToolGroup.HandleAdminAddon3Response(player, message)
	--ftcv [pt.2] / ftcw
	local bitfield = RdKGToolNetworking.DecodeMessageFromBitArray(message.b3, message.b2, message.b1)
	player.admin = player.admin or {}
	player.admin.addon = player.admin.addon or {}
	player.admin.addon.ftcv = player.admin.addon.ftcv or {}
	
	player.admin.addon.ftcv.opacityFar = message.b1
	player.admin.addon.ftcv.opacityClose = message.b2
	
	player.admin.addon.ftcw = {}
	player.admin.addon.ftcw.enabled = RdKGToolMath.BitToBoolean(bitfield[8])
	player.admin.addon.ftcw.distanceEnabled = RdKGToolMath.BitToBoolean(bitfield[7])
	player.admin.addon.ftcw.warningsEnabled = RdKGToolMath.BitToBoolean(bitfield[6])
	
	bitfield[6] = 0
	bitfield[7] = 0
	bitfield[8] = 0
	
	player.admin.addon.ftcw.maxDistance = RdKGToolMath.EncodeBitArrayHelper(bitfield, 0)	
end

function RdKGToolGroup.HandleAdminAddon4Response(player, message)
	--ftca
	local bitfield = RdKGToolNetworking.DecodeMessageFromBitArray(message.b3, message.b2, message.b1)
	player.admin = player.admin or {}
	player.admin.addon = player.admin.addon or {}
	player.admin.addon.ftca = {}
	
	player.admin.addon.ftca.maxDistance = message.b1
	player.admin.addon.ftca.threshold = message.b2
	player.admin.addon.ftca.enabled = RdKGToolMath.BitToBoolean(bitfield[8])
	
	bitfield[8] = 0
	player.admin.addon.ftca.interval = RdKGToolMath.EncodeBitArrayHelper(bitfield, 0)
end

function RdKGToolGroup.HandleAdminAddon5Response(player, message)
	--ressource overview pt.1
	local bitfield = RdKGToolNetworking.DecodeMessageFromBitArray(message.b3, message.b2, message.b1)
	player.admin = player.admin or {}
	player.admin.addon = player.admin.addon or {}
	player.admin.addon.ro = player.admin.addon.ro or {}
	
	player.admin.addon.ro.enabled = RdKGToolMath.BitToBoolean(bitfield[1])
	player.admin.addon.ro.ultimateOverviewEnabled = RdKGToolMath.BitToBoolean(bitfield[2])
	player.admin.addon.ro.clientUltimateEnabled = RdKGToolMath.BitToBoolean(bitfield[3])
	player.admin.addon.ro.groupUltimatesEnabled = RdKGToolMath.BitToBoolean(bitfield[4])
	player.admin.addon.ro.showSoftResources = RdKGToolMath.BitToBoolean(bitfield[5])
	player.admin.addon.ro.soundEnabled = RdKGToolMath.BitToBoolean(bitfield[6])

	player.admin.addon.ro.groupSizeDestro = message.b1
	player.admin.addon.ro.groupSizeStorm = message.b2
end

function RdKGToolGroup.HandleAdminAddon6Response(player, message)
	--ressource overview pt.2
	player.admin = player.admin or {}
	player.admin.addon = player.admin.addon or {}
	player.admin.addon.ro = player.admin.addon.ro or {}
	
	player.admin.addon.ro.groupSizeNegate = message.b1
	player.admin.addon.ro.groupSizeNova = message.b2
	player.admin.addon.ro.maxDistance = message.b3
end

function RdKGToolGroup.HandleAdminAddon7Response(player, message)
	--yacs, bft, kc, recharger, sm
	local bitfield = RdKGToolNetworking.DecodeMessageFromBitArray(message.b1, message.b2, message.b3)
	player.admin = player.admin or {}
	player.admin.addon = player.admin.addon or {}
	player.admin.addon.yacs = {}
	player.admin.addon.kc = {}
	player.admin.addon.sm = {}
	player.admin.addon.recharger = {}
	player.admin.addon.bft = {}
	player.admin.addon.dt = {}
	player.admin.addon.cl = {}
	player.admin.addon.cs = {}
	player.admin.addon.gb = {}
	player.admin.addon.isdp = {}
	player.admin.addon.respawner = {}
	player.admin.addon.camp = {}
	player.admin.addon.sp = {}
	player.admin.addon.so = {}
	
	player.admin.addon.bft.soundEnabled = RdKGToolMath.BitToBoolean(bitfield[7])
	player.admin.addon.bft.enabled = RdKGToolMath.BitToBoolean(bitfield[8])
	
	bitfield[7] = 0
	bitfield[8] = 0
	player.admin.addon.bft.size = RdKGToolMath.EncodeBitArrayHelper(bitfield, 0)
	
	player.admin.addon.yacs.enabled = RdKGToolMath.BitToBoolean(bitfield[9])
	player.admin.addon.yacs.pvpEnabled = RdKGToolMath.BitToBoolean(bitfield[10])
	player.admin.addon.yacs.combatEnabled = RdKGToolMath.BitToBoolean(bitfield[11])
	player.admin.addon.kc.enabled = RdKGToolMath.BitToBoolean(bitfield[12])
	player.admin.addon.recharger.enabled = RdKGToolMath.BitToBoolean(bitfield[13])
	player.admin.addon.sm.enabled = RdKGToolMath.BitToBoolean(bitfield[14])
	player.admin.addon.dt.enabled = RdKGToolMath.BitToBoolean(bitfield[15])
	player.admin.addon.cl.enabled = RdKGToolMath.BitToBoolean(bitfield[16])
	player.admin.addon.cs.enabled = RdKGToolMath.BitToBoolean(bitfield[17])
	player.admin.addon.gb.enabled = RdKGToolMath.BitToBoolean(bitfield[18])
	player.admin.addon.isdp.enabled = RdKGToolMath.BitToBoolean(bitfield[19])
	player.admin.addon.respawner.enabled = RdKGToolMath.BitToBoolean(bitfield[20])
	player.admin.addon.camp.enabled = RdKGToolMath.BitToBoolean(bitfield[21])
	player.admin.addon.sp.enabled = RdKGToolMath.BitToBoolean(bitfield[22])
	player.admin.addon.sp.mode = bitfield[23] + 1
	player.admin.addon.so.enabled = RdKGToolMath.BitToBoolean(bitfield[24])
end

function RdKGToolGroup.HandleAdminAddon8Response(player, message)
	local messagePrefix = message.b1
	--d(messagePrefix)
	if messagePrefix == RdKGToolNetworking.messageIdentifiers.adminResponse.admin.MESSAGE_1 then
		--MESSAGE_1: ftcb / ra /caj
		local bitfield = RdKGToolMath.DecodeBitArrayHelper(message.b3)
		player.admin = player.admin or {}
		player.admin.addon = player.admin.addon or {}
		player.admin.addon.ftcb = {}
		player.admin.addon.ra = {}
		player.admin.addon.caj = {}
		
		player.admin.addon.ftcb.alpha = message.b2
		player.admin.addon.ftcb.enabled = RdKGToolMath.BitToBoolean(bitfield[8])
		player.admin.addon.caj.enabled = RdKGToolMath.BitToBoolean(bitfield[7])
		player.admin.addon.ra.allowOverride = RdKGToolMath.BitToBoolean(bitfield[6])
		player.admin.addon.ra.enabled = RdKGToolMath.BitToBoolean(bitfield[5])
		bitfield[8] = 0
		bitfield[7] = 0
		bitfield[6] = 0
		bitfield[5] = 0
		player.admin.addon.ftcb.selectedBeam = RdKGToolMath.EncodeBitArrayHelper(bitfield, 0)
	elseif messagePrefix == RdKGToolNetworking.messageIdentifiers.adminResponse.admin.MESSAGE_2 then
		--MESSAGE_2: crBgTp, sc, ro
		player.admin = player.admin or {}
		player.admin.addon = player.admin.addon or {}
		player.admin.addon.crBgTp = {}
		player.admin.addon.sc = {}
		player.admin.addon.ro = player.admin.addon.ro or {}
		
		local bitfield = RdKGToolMath.DecodeBitArrayHelper(message.b2)
		
		player.admin.addon.crBgTp.enabled = RdKGToolMath.BitToBoolean(bitfield[1])
		player.admin.addon.sc.enabled = RdKGToolMath.BitToBoolean(bitfield[2])
		player.admin.addon.ro.groupsEnabled = RdKGToolMath.BitToBoolean(bitfield[8])
		bitfield[1] = bitfield[3]
		bitfield[2] = bitfield[4]
		bitfield[3] = bitfield[5]
		bitfield[4] = bitfield[6]
		bitfield[5] = bitfield[7]
		bitfield[6] = 0
		bitfield[7] = 0
		bitfield[8] = 0
		player.admin.addon.ro.groupSizeNegateOffensive = RdKGToolMath.EncodeBitArrayHelper(bitfield, 0)
		
		bitfield = RdKGToolMath.DecodeBitArrayHelper(message.b3)
		bitfield[6] = 0
		bitfield[7] = 0
		bitfield[8] = 0
		player.admin.addon.ro.groupSizeNegateCounter = RdKGToolMath.EncodeBitArrayHelper(bitfield, 0)
		
	elseif messagePrefix == RdKGToolNetworking.messageIdentifiers.adminResponse.admin.MESSAGE_3 then
		--MESSAGE_3: ro
		player.admin = player.admin or {}
		player.admin.addon = player.admin.addon or {}
		player.admin.addon.ro = player.admin.addon.ro or {}
		player.admin.addon.so = player.admin.addon.so or {}
		
		local bitfield = RdKGToolMath.DecodeBitArrayHelper(message.b2)
		local bitfield2 = RdKGToolMath.DecodeBitArrayHelper(message.b2)
		bitfield2[1] = bitfield2[6]
		bitfield2[2] = bitfield2[7]
		bitfield2[3] = bitfield2[8]
		bitfield2[4] = 0
		bitfield2[5] = 0
		bitfield2[6] = 0
		bitfield2[7] = 0
		bitfield2[8] = 0
		bitfield[6] = 0
		bitfield[7] = 0
		bitfield[8] = 0
		player.admin.addon.ro.groupSizeNorthernStorm = RdKGToolMath.EncodeBitArrayHelper(bitfield, 0)
		player.admin.addon.so.displayMode = RdKGToolMath.EncodeBitArrayHelper(bitfield2, 0) + 1
		
		bitfield = RdKGToolMath.DecodeBitArrayHelper(message.b3)
		bitfield2 = RdKGToolMath.DecodeBitArrayHelper(message.b3)
		bitfield2[1] = bitfield2[6]
		bitfield2[2] = bitfield2[7]
		bitfield2[3] = bitfield2[8]
		bitfield2[4] = 0
		bitfield2[5] = 0
		bitfield2[6] = 0
		bitfield2[7] = 0
		bitfield2[8] = 0
		bitfield[6] = 0
		bitfield[7] = 0
		bitfield[8] = 0
		player.admin.addon.ro.groupSizePermafrost = RdKGToolMath.EncodeBitArrayHelper(bitfield, 0)
		player.admin.addon.so.tableMode = RdKGToolMath.EncodeBitArrayHelper(bitfield2, 0) + 1
	elseif messagePrefix == RdKGToolNetworking.messageIdentifiers.adminResponse.admin.MESSAGE_4 then
		--MESSAGE_4: sp
		player.admin = player.admin or {}
		player.admin.addon = player.admin.addon or {}
		player.admin.addon.sp = player.admin.addon.sp or {}
	
	
		local bitfield = RdKGToolMath.DecodeBitArrayHelper(message.b2)
		player.admin.addon.sp.preventCombustionShards = RdKGToolMath.BitToBoolean(bitfield[1])
		player.admin.addon.sp.preventTalons = RdKGToolMath.BitToBoolean(bitfield[2])
		player.admin.addon.sp.preventNova = RdKGToolMath.BitToBoolean(bitfield[3])
		player.admin.addon.sp.preventAltar = RdKGToolMath.BitToBoolean(bitfield[4])
		player.admin.addon.sp.preventStandard = RdKGToolMath.BitToBoolean(bitfield[5])
		player.admin.addon.sp.preventRitual = RdKGToolMath.BitToBoolean(bitfield[6])
		player.admin.addon.sp.preventBoneShield = RdKGToolMath.BitToBoolean(bitfield[7])
		player.admin.addon.sp.preventConduit = RdKGToolMath.BitToBoolean(bitfield[8])		
		
		bitfield = RdKGToolMath.DecodeBitArrayHelper(message.b3)
		player.admin.addon.sp.preventAtronach = RdKGToolMath.BitToBoolean(bitfield[1])
		player.admin.addon.sp.preventTrappingWebs = RdKGToolMath.BitToBoolean(bitfield[2])
		player.admin.addon.sp.preventRadiate = RdKGToolMath.BitToBoolean(bitfield[3])
		player.admin.addon.sp.preventConsumingDarkness = RdKGToolMath.BitToBoolean(bitfield[4])
		player.admin.addon.sp.preventSoulLeech = RdKGToolMath.BitToBoolean(bitfield[5])
		player.admin.addon.sp.preventHealingSeed = RdKGToolMath.BitToBoolean(bitfield[6])
		player.admin.addon.sp.preventGraveRobber = RdKGToolMath.BitToBoolean(bitfield[7])
		player.admin.addon.sp.preventPureAgony = RdKGToolMath.BitToBoolean(bitfield[8])
		
	end
end

function RdKGToolGroup.HandleAdminAddon9Response(player, message)
	--
end

function RdKGToolGroup.HandleAdminChampionInformationResponse(message)
	local player = RdKGToolGroup.GetPlayerByUnitTag(message.pingTag)
	if player ~= nil then
		player.admin = player.admin or {}
		player.admin.cp = player.admin.cp or {}
		--d(message)
		player.admin.cp[RdKGToolCP.GetCPNameFromMessagePrefix(message.b1, 1)] = message.b2
		player.admin.cp[RdKGToolCP.GetCPNameFromMessagePrefix(message.b1, 2)] = message.b3
		RdKGToolGroup.NotifyAdminInformationChangedCallbacks(message.pingTag)
	end
end

function RdKGToolGroup.HandleAdminStatsResponse(message)
	local player = RdKGToolGroup.GetPlayerByUnitTag(message.pingTag)
	--d("received")
	--d(message)
	if player ~= nil then
		player.admin = player.admin or {}
		player.admin.stats = player.admin.stats or {}
		
		local bitfield = RdKGToolNetworking.DecodeMessageFromBitArray(message.b1, message.b2, message.b3)
		local messagePrefix = RdKGToolMath.EncodeBitArrayHelper(RdKGToolMath.CopyBitfieldRange(bitfield, RdKGToolMath.CreateEmptyBitfield(4), 4, 21, 1), 0)
		local value = RdKGToolMath.ArrayToInt24(RdKGToolMath.CopyBitfieldRange(bitfield, RdKGToolMath.CreateEmptyBitfield(20), 20, 1, 1))
		
		if messagePrefix == RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_MAGICKA then
			player.admin.stats.magicka = value
		elseif messagePrefix == RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_HEALTH then
			player.admin.stats.health = value
		elseif messagePrefix == RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_STAMINA then
			player.admin.stats.stamina = value
		elseif messagePrefix == RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_MAGICKA_RECOVERY then
			player.admin.stats.magickaRecovery = value
		elseif messagePrefix == RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_HEALTH_RECOVERY then
			player.admin.stats.healthRecovery = value
		elseif messagePrefix == RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_STAMINA_RECOVERY then
			player.admin.stats.staminaRecovery = value
		elseif messagePrefix == RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_SPELL_DAMAGE then
			player.admin.stats.spellDamage = value
		elseif messagePrefix == RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_WEAPON_DAMAGE then
			player.admin.stats.weaponDamage = value
		elseif messagePrefix == RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_SPELL_PENETRATION then
			player.admin.stats.spellPenetration = value
		elseif messagePrefix == RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_WEAPON_PENETRATION then
			player.admin.stats.weaponPenetration = value
		elseif messagePrefix == RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_CRITICAL then
			player.admin.stats.spellCritical = RdKGToolMath.ArrayToInt24(RdKGToolMath.CopyBitfieldRange(bitfield, RdKGToolMath.CreateEmptyBitfield(10), 10, 1, 1)) / 10
			player.admin.stats.weaponCritical = RdKGToolMath.ArrayToInt24(RdKGToolMath.CopyBitfieldRange(bitfield, RdKGToolMath.CreateEmptyBitfield(10), 10, 11, 1)) / 10
		elseif messagePrefix == RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_SPELL_RESISTANCE then
			player.admin.stats.spellResistance = value
		elseif messagePrefix == RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_PHYSICAL_RESISTANCE then
			player.admin.stats.physicalResistance = value
		elseif messagePrefix == RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_CRITICAL_RESISTANCE then
			player.admin.stats.criticalResistance = value
		end
		RdKGToolGroup.NotifyAdminInformationChangedCallbacks(message.pingTag)
	end
end

function RdKGToolGroup.HandleAdminSkillsResponse(message)
	local player = RdKGToolGroup.GetPlayerByUnitTag(message.pingTag)
	if player ~= nil then
		local bitfield = RdKGToolNetworking.DecodeMessageFromBitArray(message.b1, message.b2, message.b3)
		local messagePrefix = RdKGToolMath.EncodeBitArrayHelper(RdKGToolMath.CopyBitfieldRange(bitfield, RdKGToolMath.CreateEmptyBitfield(4), 4, 21, 1), 0)
		local value = RdKGToolMath.ArrayToInt24(RdKGToolMath.CopyBitfieldRange(bitfield, RdKGToolMath.CreateEmptyBitfield(20), 20, 1, 1))
		
		--d(message)
		
		player.admin = player.admin or {}
		player.admin.skills = player.admin.skills or {}
		player.admin.skills.bars = player.admin.skills.bars or {}
		player.admin.skills.bars[1] = player.admin.skills.bars[1] or {}
		player.admin.skills.bars[2] = player.admin.skills.bars[2] or {}
		
		if messagePrefix == RdKGToolSB.constants.networking.messagePrefix.BAR_1_SKILL_1 then
			player.admin.skills.bars[1][1] = value
		elseif messagePrefix == RdKGToolSB.constants.networking.messagePrefix.BAR_1_SKILL_2 then
			player.admin.skills.bars[1][2] = value
		elseif messagePrefix == RdKGToolSB.constants.networking.messagePrefix.BAR_1_SKILL_3 then
			player.admin.skills.bars[1][3] = value
		elseif messagePrefix == RdKGToolSB.constants.networking.messagePrefix.BAR_1_SKILL_4 then
			player.admin.skills.bars[1][4] = value
		elseif messagePrefix == RdKGToolSB.constants.networking.messagePrefix.BAR_1_SKILL_5 then
			player.admin.skills.bars[1][5] = value
		elseif messagePrefix == RdKGToolSB.constants.networking.messagePrefix.BAR_1_ULTIMATE then
			player.admin.skills.bars[1][6] = value
		elseif messagePrefix == RdKGToolSB.constants.networking.messagePrefix.BAR_2_SKILL_1 then
			player.admin.skills.bars[2][1] = value
		elseif messagePrefix == RdKGToolSB.constants.networking.messagePrefix.BAR_2_SKILL_2 then
			player.admin.skills.bars[2][2] = value
		elseif messagePrefix == RdKGToolSB.constants.networking.messagePrefix.BAR_2_SKILL_3 then
			player.admin.skills.bars[2][3] = value
		elseif messagePrefix == RdKGToolSB.constants.networking.messagePrefix.BAR_2_SKILL_4 then
			player.admin.skills.bars[2][4] = value
		elseif messagePrefix == RdKGToolSB.constants.networking.messagePrefix.BAR_2_SKILL_5 then
			player.admin.skills.bars[2][5] = value
		elseif messagePrefix == RdKGToolSB.constants.networking.messagePrefix.BAR_2_ULTIMATE then
			player.admin.skills.bars[2][6] = value
		end
		RdKGToolGroup.NotifyAdminInformationChangedCallbacks(message.pingTag)
	end
end

function RdKGToolGroup.HandleAdminEquipmentInformationResponse(message)
	local player = RdKGToolGroup.GetPlayerByUnitTag(message.pingTag)
	if player ~= nil then
		if message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_EQUIPMENT_INFORMATION_1 then
			RdKGToolGroup.HandleAdminEquipment1Response(player, message)
		elseif message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_EQUIPMENT_INFORMATION_2 then
			RdKGToolGroup.HandleAdminEquipment2Response(player, message)
		elseif message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_EQUIPMENT_INFORMATION_3 then
			RdKGToolGroup.HandleAdminEquipment3Response(player, message)
		elseif message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_EQUIPMENT_INFORMATION_4 then
			RdKGToolGroup.HandleAdminEquipment4Response(player, message)
		elseif message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_EQUIPMENT_INFORMATION_5 then
			RdKGToolGroup.HandleAdminEquipment5Response(player, message)
			RdKGToolGroup.NotifyAdminInformationChangedCallbacks(message.pingTag)
		end
	end
end

function RdKGToolGroup.CreateItemLink(messagePrefix, player)
	local item = player.admin.equipment[messagePrefix]
	if item ~= nil and item.itemId ~= nil and item.itemId ~= 0 then
		--d("everthing is fine so far")
		if item.message1received == true and
		   item.message2received == true and
		   item.message3received == true and
		   item.message4received == true and
		   item.message5received == true then
			--d("okay, let's create the link")
			item.link = RdKGToolEquip.CreateItemLink(item.itemId, item.itemQuality, item.itemLevel, item.enchantmentId, item.enchantmentQuality, item.enchantmentLevel, item.transmutationId, nil, item.styleId, nil, nil, nil, 0)
		end
	end
end

function RdKGToolGroup.HandleAdminEquipment1Response(player, message)
	--Equipment 1: itemId
	local bitfield = RdKGToolNetworking.DecodeMessageFromBitArray(message.b1, message.b2, message.b3)
	local messagePrefix = RdKGToolMath.ArrayToInt24(RdKGToolMath.CopyBitfieldRange(bitfield, RdKGToolMath.CreateEmptyBitfield(24), 4, 21, 1))
	--d(messagePrefix)
	--d(type(messagePrefix))
	local equipmentName = RdKGToolEquip.GetEquipmentNameFromMessagePrefix(messagePrefix)
	--d(equipmentName)
	bitfield[24] = 0
	bitfield[23] = 0
	bitfield[22] = 0
	bitfield[21] = 0
	local value = RdKGToolMath.ArrayToInt24(bitfield)
	player.admin = player.admin or {}
	player.admin.equipment = player.admin.equipment or {}
	if equipmentName ~= nil then
		player.admin.equipment[equipmentName] = player.admin.equipment[equipmentName] or {}
		player.admin.equipment[equipmentName].itemId = value
		player.admin.equipment[equipmentName].message1received = true
		player.admin.equipment[equipmentName].message2received = false
		player.admin.equipment[equipmentName].message3received = false
		player.admin.equipment[equipmentName].message4received = false
		player.admin.equipment[equipmentName].message5received = false
	end
	RdKGToolGroup.CreateItemLink(equipmentName, player)
end

function RdKGToolGroup.HandleAdminEquipment2Response(player, message)
	local bitfield = RdKGToolNetworking.DecodeMessageFromBitArray(message.b1, message.b2, message.b3)
	local messagePrefix = RdKGToolMath.ArrayToInt24(RdKGToolMath.CopyBitfieldRange(bitfield, RdKGToolMath.CreateEmptyBitfield(24), 4, 21, 1))
	local equipmentName = RdKGToolEquip.GetEquipmentNameFromMessagePrefix(messagePrefix)
	bitfield[24] = 0
	bitfield[23] = 0
	bitfield[22] = 0
	bitfield[21] = 0
	local value = RdKGToolMath.ArrayToInt24(bitfield)
	player.admin = player.admin or {}
	player.admin.equipment = player.admin.equipment or {}
	if equipmentName ~= nil then
		player.admin.equipment[equipmentName] = player.admin.equipment[equipmentName] or {}
		player.admin.equipment[equipmentName].enchantmentId = value
		player.admin.equipment[equipmentName].message2received = true
	end
	RdKGToolGroup.CreateItemLink(equipmentName, player)
end

function RdKGToolGroup.HandleAdminEquipment3Response(player, message)
	local bitfield = RdKGToolNetworking.DecodeMessageFromBitArray(message.b1, message.b2, message.b3)
	local messagePrefix = RdKGToolMath.ArrayToInt24(RdKGToolMath.CopyBitfieldRange(bitfield, RdKGToolMath.CreateEmptyBitfield(24), 4, 21, 1))
	local equipmentName = RdKGToolEquip.GetEquipmentNameFromMessagePrefix(messagePrefix)
	bitfield[24] = 0
	bitfield[23] = 0
	bitfield[22] = 0
	bitfield[21] = 0
	local value1 = RdKGToolMath.ArrayToInt24(RdKGToolMath.CopyBitfieldRange(bitfield, RdKGToolMath.CreateEmptyBitfield(24), 10, 1, 1))
	local value2 = RdKGToolMath.ArrayToInt24(RdKGToolMath.CopyBitfieldRange(bitfield, RdKGToolMath.CreateEmptyBitfield(24), 10, 11, 1))
	player.admin = player.admin or {}
	player.admin.equipment = player.admin.equipment or {}
	if equipmentName ~= nil then
		player.admin.equipment[equipmentName] = player.admin.equipment[equipmentName] or {}
		player.admin.equipment[equipmentName].itemQuality = value1
		player.admin.equipment[equipmentName].enchantmentQuality = value2
		player.admin.equipment[equipmentName].message3received = true
	end
	RdKGToolGroup.CreateItemLink(equipmentName, player)
end

function RdKGToolGroup.HandleAdminEquipment4Response(player, message)
	local bitfield = RdKGToolNetworking.DecodeMessageFromBitArray(message.b1, message.b2, message.b3)
	local messagePrefix = RdKGToolMath.ArrayToInt24(RdKGToolMath.CopyBitfieldRange(bitfield, RdKGToolMath.CreateEmptyBitfield(24), 4, 21, 1))
	local equipmentName = RdKGToolEquip.GetEquipmentNameFromMessagePrefix(messagePrefix)
	bitfield[24] = 0
	bitfield[23] = 0
	bitfield[22] = 0
	bitfield[21] = 0
	local value1 = RdKGToolMath.ArrayToInt24(RdKGToolMath.CopyBitfieldRange(bitfield, RdKGToolMath.CreateEmptyBitfield(24), 10, 1, 1))
	local value2 = RdKGToolMath.ArrayToInt24(RdKGToolMath.CopyBitfieldRange(bitfield, RdKGToolMath.CreateEmptyBitfield(24), 10, 11, 1))
	player.admin = player.admin or {}
	player.admin.equipment = player.admin.equipment or {}
	if equipmentName ~= nil then
		player.admin.equipment[equipmentName] = player.admin.equipment[equipmentName] or {}
		player.admin.equipment[equipmentName].itemLevel = value1
		player.admin.equipment[equipmentName].enchantmentLevel = value2
		player.admin.equipment[equipmentName].message4received = true
	end
	RdKGToolGroup.CreateItemLink(equipmentName, player)
end

function RdKGToolGroup.HandleAdminEquipment5Response(player, message)
	local bitfield = RdKGToolNetworking.DecodeMessageFromBitArray(message.b1, message.b2, message.b3)
	local messagePrefix = RdKGToolMath.ArrayToInt24(RdKGToolMath.CopyBitfieldRange(bitfield, RdKGToolMath.CreateEmptyBitfield(24), 4, 21, 1))
	local equipmentName = RdKGToolEquip.GetEquipmentNameFromMessagePrefix(messagePrefix)
	bitfield[24] = 0
	bitfield[23] = 0
	bitfield[22] = 0
	bitfield[21] = 0
	local value1 = RdKGToolMath.ArrayToInt24(RdKGToolMath.CopyBitfieldRange(bitfield, RdKGToolMath.CreateEmptyBitfield(24), 10, 1, 1))
	local value2 = RdKGToolMath.ArrayToInt24(RdKGToolMath.CopyBitfieldRange(bitfield, RdKGToolMath.CreateEmptyBitfield(24), 10, 11, 1))
	player.admin = player.admin or {}
	player.admin.equipment = player.admin.equipment or {}
	if equipmentName ~= nil then
		player.admin.equipment[equipmentName] = player.admin.equipment[equipmentName] or {}
		player.admin.equipment[equipmentName].transmutationId = value1
		player.admin.equipment[equipmentName].styleId = value2
		player.admin.equipment[equipmentName].message5received = true
	end
	RdKGToolGroup.CreateItemLink(equipmentName, player)
end

--callbacks (group)
function RdKGToolGroup.OnProfileChanged(currentProfile)
	if currentProfile ~= nil then
		RdKGToolGroup.groupVars = currentProfile.util.group
		RdKGToolGroup.UpdateDisplayNames()
	end
end

function RdKGToolGroup.GroupMemberOnConnectedStatus(eventCode, unitTag, isOnline)
	local players = RdKGToolGroup.state.players
	if players ~= nil then
		for i = 1, #players do
			if players[i].unitTag == unitTag then
				players[i].isOnline = isOnline
			end
		end
	end
end

function RdKGToolGroup.GroupMemberOnJoined(eventCode, memberName)
	RdKGToolGroup.UpdateGroup()
	RdKGToolGroup.AdjustBgGroup()
end

function RdKGToolGroup.GroupMemberOnLeft(eventCode, memberCharacterName, reason, isLocalPlayer, isLeader, memberDisplayName, actionRequiredVote)
	RdKGToolGroup.UpdateGroup()
	RdKGToolGroup.AdjustBgGroup()
end

function RdKGToolGroup.GroupMemberOnUpdate(eventCode)
	RdKGToolGroup.UpdateGroup()
	RdKGToolGroup.AdjustBgGroup()
end

function RdKGToolGroup.GroupMemberOnLeaderUpdate(eventCode, leaderTag)
	local players = RdKGToolGroup.state.players
	if players ~= nil then
		for i = 1, #players do
			players[i].isLeader = false
			if players[i].unitTag == leaderTag then
				players[i].isLeader = true
			end
		end
	end
	RdKGToolGroup.AdjustBgGroup()
end

function RdKGToolGroup.GroupMemberOnPlayerActivated(eventCode, initial)
	RdKGToolGroup.UpdateGroup()
	RdKGToolGroup.AdjustBgGroup()
end

function RdKGToolGroup.GroupMemberOnPlayerDeactivated(eventCode)
	if GetGroupSize() > 1 then
		RdKGToolGroup.state.lastLeader = RdKGToolGroup.GetLeaderUnit()
	else
		RdKGToolGroup.state.lastLeader = nil
	end
end

function RdKGToolGroup.UpdateStatusLoop()
	local players =  RdKGToolGroup.state.players
	local isInCombat = false
	if players ~= nil then
		for i = 1, #players do
			players[i].isInCombat = IsUnitInCombat(players[i].unitTag)
			if players[i].isInCombat == true then
				isInCombat = true
			end
			players[i].isInStealth = GetUnitStealthState(players[i].unitTag)
		end
	end
	if isInCombat == true then
		RdKGToolGroup.state.lastCombatTimestamp = GetGameTimeMilliseconds()
	else
		if RdKGToolGroup.IsHdmAutoClearEnabled() == true and GetGameTimeMilliseconds() > RdKGToolGroup.state.lastCombatTimestamp + RdKGToolGroup.constants.COMBAT_TIMEOUT then
			RdKGToolGroup.ClearDamageHealingMeter()
		end
	end
end

function RdKGToolGroup.IsHdmAutoClearEnabled()
	return RdKGToolGroup.state.hdmAutoClear
end

function RdKGToolGroup.SetHdmAutoClearEnabled(value)
	RdKGToolGroup.state.hdmAutoClear = value
end

--callbacks
function RdKGToolGroup.OnUpdatePlayerDistance()
	RdKGToolGroup.CalculateGroupDistances("player", "fromPlayer")
end

function RdKGToolGroup.OnUpdateLeaderDistance()
	RdKGToolGroup.CalculateGroupDistances(RdKGToolGroup.GetLeaderUnitTag(), "fromLeader")
end

function RdKGToolGroup.OnUpdateBuff()
	local players = RdKGToolGroup.state.players
	local currentTime = GetGameTimeMilliseconds() / 1000
	for i = 1, #players do
		local buffs = players[i].buffs
		buffs.specialInformation = buffs.specialInformation or {}
		--[[
		buffs.specialInformation.rapidManeuverOn = {}
		buffs.specialInformation.rapidManeuverOn.active = false
		buffs.specialInformation.chargingManeuverMajorOn = {}
		buffs.specialInformation.chargingManeuverMajorOn.active = false
		buffs.specialInformation.chargingManeuverMinorOn = {}
		buffs.specialInformation.chargingManeuverMinorOn.active = false
		buffs.specialInformation.retreatingManeuverOn = {}
		buffs.specialInformation.retreatingManeuverOn.active = false
		]]
		buffs.specialInformation.minorExpeditionOn = {}
		buffs.specialInformation.minorExpeditionOn.active = false
		buffs.specialInformation.majorExpeditionOn = {}
		buffs.specialInformation.majorExpeditionOn.active = false
		buffs.specialInformation.potion = buffs.specialInformation.potion or {}
		buffs.specialInformation.potion.immovablePot = false
		buffs.specialInformation.foodDrink = buffs.specialInformation.foodDrink or {}
		buffs.specialInformation.foodDrink.started = 0
		buffs.specialInformation.foodDrink.ending = 0
		buffs.specialInformation.foodDrink.active = false
		buffs.specialInformation.proximityDetonation = buffs.specialInformation.proximityDetonation or {}
		buffs.specialInformation.proximityDetonation.active = false
		buffs.specialInformation.proximityDetonation.started = 0
		buffs.specialInformation.proximityDetonation.ending = 0
		buffs.specialInformation.subterraneanAssault = buffs.specialInformation.subterraneanAssault or {}
		buffs.specialInformation.subterraneanAssault.active = false
		buffs.specialInformation.subterraneanAssault.started = 0
		buffs.specialInformation.subterraneanAssault.ending = 0
		buffs.specialInformation.deepFissure = buffs.specialInformation.deepFissure or {}
		buffs.specialInformation.deepFissure.active = false
		buffs.specialInformation.deepFissure.started = 0
		buffs.specialInformation.deepFissure.ending = 0
		buffs.specialInformation.soulOfFlame = buffs.specialInformation.soulOfFlame or {}
		buffs.specialInformation.soulOfFlame.active = false
		buffs.specialInformation.soulOfFlame.started = 0
		buffs.specialInformation.soulOfFlame.ending = 0
		buffs.specialInformation.crBgTpHealBuffs = {}
				
				
		buffs.numBuffs = GetNumBuffs(players[i].unitTag)
		buffs.all = buffs.all or {}
		buffs.buffs = buffs.buffs or {}
		buffs.debuffs = buffs.debuffs or {}
		buffs.debuffsPurgable = buffs.debuffsPurgable or {}
		--clear old data
		for j = 1, #buffs.all do
			buffs.all[j] = nil
		end
		for j = 1, #buffs.buffs do
			buffs.buffs[j] = nil
		end
		for j = 1, #buffs.debuffs do
			buffs.debuffs[j] = nil
		end
		for j = 1, #buffs.debuffsPurgable do
			buffs.debuffsPurgable[j] = nil
		end
		local numPlayerDebuffs = 0
		if buffs.numBuffs ~= nil then
			for buffIndex = 1, buffs.numBuffs do
				local buff = {}
				buff.name, buff.started, buff.ending, buff.slot, buff.stackCount, buff.iconFilename, buff.buffType, buff.effectType, buff.abilityType, buff.statusEffectType, buff.abilityId, buff.canClickOff, buff.castByPlayer = GetUnitBuffInfo(players[i].unitTag, buffIndex)
				--d(buff.iconFilename)
				table.insert(buffs.all, buff)
				if buff.effectType == BUFF_EFFECT_TYPE_BUFF then
					table.insert(buffs.buffs, buff)
					RdKGToolGroup.RunSpecialChecks(buffs, buff)
				elseif buff.effectType == BUFF_EFFECT_TYPE_DEBUFF then
					if --[[buff.statusEffectType ~= STATUS_EFFECT_TYPE_ENVIRONMENT and]] buff.statusEffectType ~= STATUS_EFFECT_TYPE_SILENCE then
						table.insert(buffs.debuffsPurgable, buff)
						if players[i].isPlayer == true then
							--d("debuff 1")
							if buff.ending ~= nil and buff.started ~= nil and buff.ending > currentTime then
								numPlayerDebuffs = numPlayerDebuffs + 1
								--d("debuff 2")
							end
						end
					end
					table.insert(buffs.debuffs, buff)
				end
				if RdKGToolGroup.state.crBgTpHealBuffs ~= nil and players[i].isPlayer == true then
					RdKGToolGroup.CheckCrBgTpHealBuff(buffs, buff)
				end
			end
		end
		if players[i].isPlayer == true then
			--d(numPlayerDebuffs)
			buffs.numPurgableBuffs = numPlayerDebuffs
		end
	end
end

function RdKGToolGroup.OnUpdateDeadState()
	local players = RdKGToolGroup.state.players
	if players ~= nil then
		for i = 1, #players do
			local player = players[i]
			local unitTag = player.unitTag
			player.isDead = IsUnitDead(unitTag)
			player.isResurrected = DoesUnitHaveResurrectPending(unitTag)
			player.isBeingResurrected = IsUnitBeingResurrected(unitTag)
		end
	end
end

function RdKGToolGroup.OnUpdateCoordinates()
	if lib3d:IsValidZone() then
		local players = RdKGToolGroup.state.players
		if players ~= nil then
			for i = 1, #players do
				local playerX, playerY = GetMapPlayerPosition(players[i].unitTag)
				players[i].coordinates.localX = playerX
				players[i].coordinates.localY = playerY
				if playerX ~= nil and playerY ~= nil and playerX ~= 0 and playerY ~= 0 then
					players[i].coordinates.x, players[i].coordinates.y = lib3d:LocalToWorld(playerX, playerY)
					local _, height = nil, nil
					_, players[i].coordinates.worldX, height, players[i].coordinates.worldY = GetUnitWorldPosition(players[i].unitTag)
					players[i].coordinates.worldX, players[i].coordinates.worldHeight, players[i].coordinates.worldY = WorldPositionToGuiRender3DPosition(players[i].coordinates.worldX, height, players[i].coordinates.worldY)
					if players[i].coordinates.x ~= nil and players[i].coordinates.y ~= nil then
						
						players[i].coordinates.x, players[i].coordinates.height, players[i].coordinates.y = WorldPositionToGuiRender3DPosition(players[i].coordinates.x * 100, height, players[i].coordinates.y * 100)
					end
					
				end
			end
		end
	end
end

function RdKGToolGroup.OnUpdateLeader()
	if lib3d:IsValidZone() and IsUnitGrouped("player") == true and RdKGToolGroup.IsPlayerGroupLeader() == false then
		local leaderLocX, leaderLocY = GetMapPlayerPosition(RdKGToolGroup.GetGroupLeaderUnitTag())
		local playerLocX, playerLocY = GetMapPlayerPosition("player")
		if leaderLocX ~= nil and leaderLocY ~= nil and leaderLocX ~= 0 and leaderLocY ~= 0 and 
		   playerLocX ~= nil and playerLocY ~= nil and playerLocX ~= 0 and playerLocY ~= 0 then
			local leaderX, leaderY = lib3d:LocalToWorld(leaderLocX, leaderLocY)
			local playerX, playerY = lib3d:LocalToWorld(playerLocX, playerLocY)
			--d("a")
			if leaderX ~= nil and leaderY ~= nil and playerX ~= nil and playerY ~= nil then
				local distanceLocX = playerLocX - leaderLocX
				local distanceLocY = playerLocY - leaderLocY
				local distanceX = playerX - leaderX
				local distanceY = playerY - leaderY
				RdKGToolGroup.state.leader.leaderDistance = math.sqrt((distanceX * distanceX) + (distanceY * distanceY))
				local cameraHeading = RdKGToolUI.NormalizeAngle(GetPlayerCameraHeading())
				RdKGToolGroup.state.leader.leaderRotation = (math.pi * 2) - RdKGToolUI.NormalizeAngle(cameraHeading - math.atan2( distanceLocX, distanceLocY ))
			end
		else
			RdKGToolGroup.state.leader.leaderDistance = nil
			RdKGToolGroup.state.leader.leaderRotation = nil
		end
	end
end

function RdKGToolGroup.HandleRawAdminNetworkMessage(message)
	if message ~= nil and RdKGToolRoster.IsGuildOfficerOf(GetUnitDisplayName(message.pingTag), GetUnitDisplayName("player")) then
		
		--d("received: " .. message.b0)
		if message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_CLIENT_CONFIGURATION_AOE then
			RdKGToolGroup.HandleAdminAoeResponse(message)
		elseif message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_CLIENT_CONFIGURATION_SOUND then
			RdKGToolGroup.HandleAdminSoundResponse(message)
		elseif message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_CLIENT_CONFIGURATION_GRAPHICS then
			RdKGToolGroup.HandleAdminGraphicsResponse(message)
		elseif message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_ADDON_CONFIGURATION_1 or 
			   message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_ADDON_CONFIGURATION_2 or 
			   message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_ADDON_CONFIGURATION_3 or 
			   message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_ADDON_CONFIGURATION_4 or 
			   message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_ADDON_CONFIGURATION_5 or 
			   message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_ADDON_CONFIGURATION_6 or 
			   message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_ADDON_CONFIGURATION_7 or 
			   message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_ADDON_CONFIGURATION_8 or 
			   message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_ADDON_CONFIGURATION_9 then
			RdKGToolGroup.HandleAdminAddonResponse(message)
		elseif message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_CHAMPION_INFORMATION then
			RdKGToolGroup.HandleAdminChampionInformationResponse(message)
		elseif message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_STATS_INFORMATION then
			RdKGToolGroup.HandleAdminStatsResponse(message)
		elseif message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_SKILLS_INFORMATION then
			RdKGToolGroup.HandleAdminSkillsResponse(message)
		elseif message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_EQUIPMENT_INFORMATION_1 or
		       message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_EQUIPMENT_INFORMATION_2 or
		       message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_EQUIPMENT_INFORMATION_3 or
		       message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_EQUIPMENT_INFORMATION_4 or
		       message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_EQUIPMENT_INFORMATION_5 then
			RdKGToolGroup.HandleAdminEquipmentInformationResponse(message)
		end		
	end
end

function RdKGToolGroup.HandleRawResourceNetworkMessage(message)
	--d(message)
	if message ~= nil and message.b0 ~= nil and message.b0 >= 1 and message.b0 <= #RdKGToolUltimates.ultimates then
		--d("ulti message received")
		RdKGToolGroup.UpdateMemberResources(message.pingTag, message.b0, message.b1, message.b2, message.b3)
	end
end

function RdKGToolGroup.HandleRawHpDmgNetworkMessage(message)
	--d(message)
	if message ~= nil and message.b0 ~= nil and (message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_HP or message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_DMG) then
		if message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_DMG then
			RdKGToolGroup.UpdateMemberDamage(message.pingTag, RdKGToolNetworking.DecodeInt24(message.b1, message.b2, message.b3))
		elseif message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_HP then
			RdKGToolGroup.UpdateMemberHealing(message.pingTag, RdKGToolNetworking.DecodeInt24(message.b1, message.b2, message.b3))
		end
	end
end

function RdKGToolGroup.HandleRawVersionNetworkMessage(message)
	--d(message)
	if message ~= nil and message.b0 ~= nil and message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_VERSION_INFORMATION then
		--d(message)
		local unitTag = message.pingTag
		if unitTag == "player" then
			unitTag = RdKGToolGroup.GetUnitTagForPlayer()
		end
		--d(unitTag)
		RdKGToolGroup.UpdateMemberVersionInformation(unitTag, {major = message.b1, minor = message.b2, revision = message.b3})
		RdKGToolGroup.NotifyAdminInformationChangedCallbacks(message.pingTag)
	end
end

function RdKGToolGroup.HandleRawSynergyNetworkMessage(message)
	if message ~= nil and message.b0 ~= nil and message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_SYNERGY then
		RdKGToolChat.SendChatMessage("Synergy Message Received: " .. message.b1 .. " - " .. message.b2, RdKGToolGroup.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
		RdKGToolGroup.UpdateMemberSynergy(message.pingTag, message.b1, message.b2)
		RdKGToolGroup.UpdateDebuffs(message.pingTag, message.b3)
	end
end

function RdKGToolGroup.OnPowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
	if eventCode == EVENT_POWER_UPDATE and unitTag ~= nil and powerType == POWERTYPE_HEALTH then
		local players = RdKGToolGroup.state.players
		if players ~= nil then
			for i = 1, #players do
				if players[i].unitTag == unitTag then
					players[i].lastKnownHealth = powerValue
					--if i == 3 then
					--	d("health: " .. powerValue)
					--end
				end
			end
		end
	end
end

--menu interaction
function RdKGToolGroup.GetMenu()
	local menu = {
		[1] = {
			type = "submenu",
			name = RdKGToolMenu.constants.UTIL_GROUP_HEADER,
			controls = {
				[1] = {
					type = "dropdown",
					name = RdKGToolMenu.constants.UTIL_GROUP_DISPLAY_TYPE,
					choices = RdKGToolGroup.GetUtilGroupDisplayTypes(),
					getFunc = RdKGToolGroup.GetUtilGroupDisplayType,
					setFunc = RdKGToolGroup.SetUtilGroupDisplayType
				},
			}
		},
	}
	return menu
end

function RdKGToolGroup.GetUtilGroupDisplayTypes()
	return RdKGToolGroup.constants.displayTypes
end

function RdKGToolGroup.GetUtilGroupDisplayType()
	return RdKGToolGroup.constants.displayTypes[RdKGToolGroup.groupVars.displayType]
end
	
function RdKGToolGroup.SetUtilGroupDisplayType(value)
	if value ~= nil then
		for i = 1, #RdKGToolGroup.constants.displayTypes do
			if RdKGToolGroup.constants.displayTypes[i] == value then
				RdKGToolGroup.groupVars.displayType = i
				RdKGToolGroup.UpdateDisplayNames()
				break
			end
		end
	end
end