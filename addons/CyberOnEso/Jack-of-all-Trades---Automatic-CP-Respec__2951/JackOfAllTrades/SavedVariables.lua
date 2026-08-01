-------------------------------------------------------------------------------------------------
-- Variable Version, update if we need to overwrite the users files --
-------------------------------------------------------------------------------------------------
JackOfAllTrades.variableVersion = 2
-------------------------------------------------------------------------------------------------
-- Default Data --
-------------------------------------------------------------------------------------------------
local defaultData = {
	debug = false,
	showCooldownError = true,
	homemakerCorpses = false,
	slotSkillsAfterCooldownEnds = true,
	slotMdWhilstDoingWrits = true,
	slotLeTrashPots = true,
	slotThInDungeon = false,
	altertedAfterCooldownOver = false,
	alertNotification = false,
	alertWarning = false,
	textureNotification = true,
	slotRationerInGrindSpot = true,
	automaticallyAllocatePoints = false,
	colour = {
		warnings = "|cba6a1a",
		notifications = "|c638C29"
	},
	warnings = {
		meticulousDisassembly = true,
		treasureHunter = true,
		professionalUpkeep = true,
		reelTechnique = false,
		anglersInstinct = false,
		masterGatherer = false,
		plentifulHarvest = true,
		cutpursesArt = true,
		infamous = true,
		homemaker = true,
		rationer = true,
		liquidEfficiency = true,
		giftedRider = false,
		warMount = false,
		sustainingShadows = false
	},
	enable = {
		reelTechnique = true,
		anglersInstinct = true,
		masterGatherer = true,
		giftedRider = false,
		warMount = false,
		sustainingShadows = true
	},
	notification = {
		reelTechnique = true,
		anglersInstinct = true,
		masterGatherer = true,
		giftedRider = true,
		warMount = true,
		sustainingShadows = true
	},
	slotIndex = {
		reelTechnique = 4,
		anglersInstinct = 3,
		masterGatherer = 4,
		giftedRider = 4,
		warMount = 3,
		sustainingShadows = 3
	},
}

-------------------------------------------------------------------------------------------------
-- Load in the saved variables  --
-------------------------------------------------------------------------------------------------
function JackOfAllTrades.InitSavedVariables()
	-------------------------------------------------------------------------------------------------
	-- Load in the savedVariables --
	-------------------------------------------------------------------------------------------------
	JackOfAllTrades.savedVariables = ZO_SavedVars:NewAccountWide("JackOfAllTradesData", JackOfAllTrades.variableVersion, nil, defaultData)

	-- Post-U45: delete the now-passive stars from savedvars to save space, and also to hopefully not break things
	local nowPassive = {"meticulousDisassembly", "treasureHunter", "professionalUpkeep", "plentifulHarvest", "cutpursesArt", "infamous", "homemaker", "rationer", "liquidEfficiency"}
	for _, name in ipairs(nowPassive) do
		JackOfAllTrades.savedVariables.enable[name] = nil
		JackOfAllTrades.savedVariables.notification[name] = nil
		JackOfAllTrades.savedVariables.slotIndex[name] = nil
	end
	JackOfAllTrades.savedVariables.thHmPair = nil

	-------------------------------------------------------------------------------------------------
	-- If we reloadui whilst in combat, we still need to return the skill after combat ends --
	-------------------------------------------------------------------------------------------------
	if JackOfAllTrades.savedVariables.inCombatDuringReloadUI then
		EVENT_MANAGER:RegisterForEvent(JackOfAllTrades.name, EVENT_PLAYER_COMBAT_STATE, JackOfAllTrades.whenCombatEndsSlotSkill)
	end
end

function JackOfAllTrades.ResetSavedVariables()
	JackOfAllTrades.savedVariables = defaultData
end

function JackOfAllTrades.resetSkillSlots()
	JackOfAllTrades.savedVariables.slotIndex = defaultData.slotIndex
end