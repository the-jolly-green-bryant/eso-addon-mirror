local Pledges = {}
DQT.Pledges = Pledges

local QuestType = DQT.Quest.QuestType
local Quest = DQT.Quest.Quest

-------- Pledges orders --------

--[[
	Calculates the current pledges based on a reference day when the pledges were known.
	If new pledges are added, reference day must be updated.

	The pledge order tables contain:
		startIndex (0-based, not 1 based) index indicating pledge on reference day.
		pledgeNames: pledges in order they are given, with SI strings that will get fed into GetString
--]]
function Pledges.getPledges(pledgeOrder)
	-- this is the next reset time on the day when the below pledges were active
	local resetHour = GetWorldName() == "NA Megaserver" and 10 or 3
	local referenceResetTime = os.time({
		year = 2024,
		month = 3,
		day = 11,
		hour = resetHour,
		minute = 0,
		second = 0
	})

	-- this is the next reset time now
	local resetTime = DQT.Utils:getResetTime()

	-- how many days have elapsed since the reference day
	local daysSinceReference = os.difftime(resetTime, referenceResetTime) / 86400

	-- using 0 based index until doing lookup
	local index = math.floor((pledgeOrder.startIndex + daysSinceReference) % #pledgeOrder.pledgeNames)
	local pledgeName = GetString(pledgeOrder.pledgeNames[index + 1])
	return DQT.Utils:stripPrefixes(pledgeName, { GetString(DQT_PLEDGE_PREFIX) })
end

-- pledges from Maj al-Ragath
Pledges.majPledgeOrder = {
	startIndex = 0,
	pledgeNames = {
		DQT_UNDAUNTED_PLEDGES_MAJ_AL_RAGATH_S_PLEDGES_05, -- Fungal I
		DQT_UNDAUNTED_PLEDGES_MAJ_AL_RAGATH_S_PLEDGES_10, -- Banished II
		DQT_UNDAUNTED_PLEDGES_MAJ_AL_RAGATH_S_PLEDGES_01, -- Darkshade I
		DQT_UNDAUNTED_PLEDGES_MAJ_AL_RAGATH_S_PLEDGES_04, -- Elden II
		DQT_UNDAUNTED_PLEDGES_MAJ_AL_RAGATH_S_PLEDGES_11, -- Wayrest I
		DQT_UNDAUNTED_PLEDGES_MAJ_AL_RAGATH_S_PLEDGES_08, -- Spindleclutch II
		DQT_UNDAUNTED_PLEDGES_MAJ_AL_RAGATH_S_PLEDGES_09, -- Banished I
		DQT_UNDAUNTED_PLEDGES_MAJ_AL_RAGATH_S_PLEDGES_06, -- Fungal II
		DQT_UNDAUNTED_PLEDGES_MAJ_AL_RAGATH_S_PLEDGES_07, -- Spindleclutch I
		DQT_UNDAUNTED_PLEDGES_MAJ_AL_RAGATH_S_PLEDGES_02, -- Darkshade II
		DQT_UNDAUNTED_PLEDGES_MAJ_AL_RAGATH_S_PLEDGES_03, -- Elden I
		DQT_UNDAUNTED_PLEDGES_MAJ_AL_RAGATH_S_PLEDGES_12, -- Wayrest II
	}
}

-- pledges from Glirion
Pledges.glirionPledgeOrder = {
	startIndex = 0,
	pledgeNames = {
		DQT_UNDAUNTED_PLEDGES_GLIRION_THE_REDBEARD_S_PLEDGES_09, -- Selene's Web
		DQT_UNDAUNTED_PLEDGES_GLIRION_THE_REDBEARD_S_PLEDGES_05, -- City of Ash II
		DQT_UNDAUNTED_PLEDGES_GLIRION_THE_REDBEARD_S_PLEDGES_06, -- Crypt of Hearts I
		DQT_UNDAUNTED_PLEDGES_GLIRION_THE_REDBEARD_S_PLEDGES_12, -- Volenfell
		DQT_UNDAUNTED_PLEDGES_GLIRION_THE_REDBEARD_S_PLEDGES_03, -- Blessed Crucible I
		DQT_UNDAUNTED_PLEDGES_GLIRION_THE_REDBEARD_S_PLEDGES_08, -- Direfrost Keep I
		DQT_UNDAUNTED_PLEDGES_GLIRION_THE_REDBEARD_S_PLEDGES_11, -- Vaults of Madness
		DQT_UNDAUNTED_PLEDGES_GLIRION_THE_REDBEARD_S_PLEDGES_07, -- Crypt of Hearts II
		DQT_UNDAUNTED_PLEDGES_GLIRION_THE_REDBEARD_S_PLEDGES_04, -- City of Ash I
		DQT_UNDAUNTED_PLEDGES_GLIRION_THE_REDBEARD_S_PLEDGES_10, -- Tempest Island
		DQT_UNDAUNTED_PLEDGES_GLIRION_THE_REDBEARD_S_PLEDGES_02, -- Blackheart Haven I
		DQT_UNDAUNTED_PLEDGES_GLIRION_THE_REDBEARD_S_PLEDGES_01, -- Arx Corinium
	}
}

-- pledges from Urgarlag
Pledges.urgarlagPledgeOrder = {
	startIndex = 0,
	pledgeNames = {
		DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_01, -- Bloodroot Forge
		DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_03, -- Falkreath Hold
		DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_04, -- Fang Lair
		DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_09, -- Scalecaller Peak
		DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_07, -- Moon Hunter Keep
		DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_06, -- March of Sacrifices
		DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_12, -- Depths of Malatar
		DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_11, -- Frostvault
		DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_14, -- Moongrave Fane
		DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_13, -- Lair of Maarselok
		DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_15, -- Icereach
		DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_16, -- Unhallowed Grave
		DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_18, -- Stone Garden
		DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_17, -- Castle Thorn
		DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_19, -- Black Drake Villa
		DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_20, -- The Cauldron
		DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_21, -- Red Petal Bastion
		DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_22, -- The Dread Cellar
		DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_23, -- Coral Aerie
		DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_24, -- Shipwright's Regret
		DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_25, -- Earthen Root Enclave
		DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_26, -- Graven Deep
		DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_27, -- Bal Sunnar
		DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_28, -- Scrivener's Hall
		DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_29, -- Oathsworn Pit
		DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_30, -- Bedlam Veil
		DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_31, -- Exiled Redoubt
		DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_32, -- Lep Seclusa
		DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_33, -- Naj-Caldeesh
		DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_34, -- Black Gem Foundry
		DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_05, -- Imperial City Prison
		DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_08, -- Ruins of Mazzatun
		DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_10, -- White-Gold Tower
		DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_02, -- Cradle of Shadows
	}
}

-------- Pledge --------
local Pledge = ZO_Object.MultiSubclass(QuestType)
Pledges.Pledge = Pledge

function Pledge:new(...)
	local object = ZO_Object.New(self)
	object:initPledge(...)
	return object
end

--[[
	Pledge is an implementation of QuestType

	@param name a unique identifer to distinguish this from other QuestType objects
	@param pledgeOrder one of the pledgeOrder tables from above, e.g. Pledges.majPledgeOrder
--]]
function Pledge:initPledge(name, pledgeOrder)
	local quests = {}

	for _, pledgeName in ipairs(pledgeOrder.pledgeNames) do
		quests[#quests + 1] = DQT.Quest.Quest:new(GetString(pledgeName))
	end

	self:init(name, DQT.Quest.QUEST_TYPE_ENUM.PLEDGE, quests, false)
	self._pledgeOrder = pledgeOrder
end

-- instead of returning the name, return the name of today's pledge
function Pledge:getName()
	return Pledges.getPledges(self._pledgeOrder)
end

function Pledges.getPledgeSection()
	return DQT.Quest.QuestSection:new(GetString(DQT_UNDAUNTED_PLEDGE), {
		Pledge:new("Maj al-Ragath", Pledges.majPledgeOrder),
		Pledge:new("Glirion", Pledges.glirionPledgeOrder),
		Pledge:new("Urgarlag", Pledges.urgarlagPledgeOrder)
	})
end
