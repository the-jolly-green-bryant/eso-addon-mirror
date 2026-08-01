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
	local referenceResetTime = os.time({year=2018, month=11, day=4,
		hour=6, minute=0, second=0})
	
	-- this is the next reset time now
	local resetTime = DQT.Utils:getResetTime()
	
	-- how many days have elapsed since the reference day
	local daysSinceReference = os.difftime(resetTime, referenceResetTime) / 86400
	
	-- using 0 based index until doing lookup
	local index = (pledgeOrder.startIndex + daysSinceReference) % #pledgeOrder.pledgeNames
	local pledgeName = GetString(pledgeOrder.pledgeNames[index + 1])
	return DQT.Utils:stripPrefixes(pledgeName, {GetString(SI_DQT_PLEDGE_PREFIX)})
end

-- pledges from Maj al-Ragath
Pledges.majPledgeOrder = {
	startIndex = 0,
	pledgeNames = {
		SI_DQT_UNDAUNTED_PLEDGES_MAJ_AL_RAGATH_S_PLEDGES_01, -- Darkshade I
		SI_DQT_UNDAUNTED_PLEDGES_MAJ_AL_RAGATH_S_PLEDGES_04, -- Elden II
		SI_DQT_UNDAUNTED_PLEDGES_MAJ_AL_RAGATH_S_PLEDGES_11, -- Wayrest I
		SI_DQT_UNDAUNTED_PLEDGES_MAJ_AL_RAGATH_S_PLEDGES_08, -- Spindleclutch II
		SI_DQT_UNDAUNTED_PLEDGES_MAJ_AL_RAGATH_S_PLEDGES_09, -- Banished I
		SI_DQT_UNDAUNTED_PLEDGES_MAJ_AL_RAGATH_S_PLEDGES_06, -- Fungal II
		SI_DQT_UNDAUNTED_PLEDGES_MAJ_AL_RAGATH_S_PLEDGES_07, -- Spindleclutch I
		SI_DQT_UNDAUNTED_PLEDGES_MAJ_AL_RAGATH_S_PLEDGES_02, -- Darkshade II
		SI_DQT_UNDAUNTED_PLEDGES_MAJ_AL_RAGATH_S_PLEDGES_03, -- Elden I
		SI_DQT_UNDAUNTED_PLEDGES_MAJ_AL_RAGATH_S_PLEDGES_12, -- Wayrest II
		SI_DQT_UNDAUNTED_PLEDGES_MAJ_AL_RAGATH_S_PLEDGES_05, -- Fungal I
		SI_DQT_UNDAUNTED_PLEDGES_MAJ_AL_RAGATH_S_PLEDGES_10  -- Banished II
	}
}

-- pledges from Glirion
Pledges.glirionPledgeOrder = {
	startIndex = 0,
	pledgeNames = {
		SI_DQT_UNDAUNTED_PLEDGES_GLIRION_THE_REDBEARD_S_PLEDGES_06, -- Crypt of Hearts I
		SI_DQT_UNDAUNTED_PLEDGES_GLIRION_THE_REDBEARD_S_PLEDGES_12, -- Volenfell
		SI_DQT_UNDAUNTED_PLEDGES_GLIRION_THE_REDBEARD_S_PLEDGES_03, -- Blessed Crucible I
		SI_DQT_UNDAUNTED_PLEDGES_GLIRION_THE_REDBEARD_S_PLEDGES_08, -- Direfrost Keep I
		SI_DQT_UNDAUNTED_PLEDGES_GLIRION_THE_REDBEARD_S_PLEDGES_11, -- Vaults of Madness
		SI_DQT_UNDAUNTED_PLEDGES_GLIRION_THE_REDBEARD_S_PLEDGES_07, -- Crypt of Hearts II
		SI_DQT_UNDAUNTED_PLEDGES_GLIRION_THE_REDBEARD_S_PLEDGES_04, -- City of Ash I
		SI_DQT_UNDAUNTED_PLEDGES_GLIRION_THE_REDBEARD_S_PLEDGES_10, -- Tempest Island
		SI_DQT_UNDAUNTED_PLEDGES_GLIRION_THE_REDBEARD_S_PLEDGES_02, -- Blackheart Haven I
		SI_DQT_UNDAUNTED_PLEDGES_GLIRION_THE_REDBEARD_S_PLEDGES_01, -- Arx Corinium
		SI_DQT_UNDAUNTED_PLEDGES_GLIRION_THE_REDBEARD_S_PLEDGES_09, -- Selene's Web
		SI_DQT_UNDAUNTED_PLEDGES_GLIRION_THE_REDBEARD_S_PLEDGES_05  -- City of Ash II
	}
}

-- pledges from Urgarlag
Pledges.urgarlagPledgeOrder = {
	startIndex = 0,
	pledgeNames = {
		SI_DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_10, -- White-Gold Tower
		SI_DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_02, -- Cradle of Shadows
		SI_DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_01, -- Bloodroot Forge
		SI_DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_03, -- Falkreath Hold
		SI_DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_04, -- Fang Lair
		SI_DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_09, -- Scalecaller Peak
		SI_DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_07, -- Moon Hunter Keep
		SI_DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_06, -- March of Sacrifices
		SI_DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_12, -- Depths of Malatar
		SI_DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_11, -- Frostvault
		SI_DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_14, -- Moongrave Fane
		SI_DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_13, -- Lair of Maarselok
		SI_DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_05, -- Imperial City Prison
		SI_DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_08, -- Ruins of Mazzatun
		SI_DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_15, -- Icereach
		SI_DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_16, -- Unhallowed Grave
		SI_DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_17, -- Castle Thorn
		SI_DQT_UNDAUNTED_PLEDGES_URGARLAG_CHIEF_BANE_S_PLEDGES_18, -- Stone Garden
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
	quests = {}
	
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
	return DQT.Quest.QuestSection:new(GetString(SI_DQT_UNDAUNTED_PLEDGE), {
		Pledge:new("Maj al-Ragath", Pledges.majPledgeOrder),
		Pledge:new("Glirion", Pledges.glirionPledgeOrder),
		Pledge:new("Urgarlag", Pledges.urgarlagPledgeOrder)
	})
end
