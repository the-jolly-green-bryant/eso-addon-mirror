
local ADDON_NAME = "Descent"

-- Logging facilities
local logger
if LibDebugLogger then
	logger = LibDebugLogger(ADDON_NAME)
end

function LogError(msg)
	if logger then
		logger:Error(msg)
	else
		d(msg)
	end
end
--

local MAX_TRACKABLE_ACHIEVEMENTS

local COLOR_PLEDGE_ACTIVE = ZO_ColorDef:New(1, 1, 0, 1)
local COLOR_PLEDGE_DONE = ZO_ColorDef:New(0, 1, 0, 1)

local DungeonDef = ZO_Object:Subclass()

function DungeonDef:New(normalId, veteranId, pledgeId, questId, achievements)
	local obj = ZO_Object.New(self)
	obj.normalId = normalId
	obj.veteranId = veteranId
	obj.questId = questId
	obj.pledgeId = pledgeId
	obj.achievements = achievements
	return obj
end
function DungeonDef:GetId()
	return self:GetNormalId()
end
function DungeonDef:GetNormalId()
	return self.normalId
end
function DungeonDef:GetVeteranId()
	return self.veteranId
end
function DungeonDef:GetQuestId()
	return self.questId
end
function DungeonDef:GetPledgeQuestId()
	return self.pledgeId
end
function DungeonDef:CheckIntegrity()
	local result = true
	if not self.normalId then
		return false
	end
	if not self.veteranId then
		return false
	end
	if not self.pledgeId then
		return false
	end
	return result
end
function DungeonDef:IsRelevantAchievment(achievementId)
	for _, ownAchievementId in pairs(self.achievements) do
		if ownAchievementId == achievementId then
			return true
		end
	end
	return false
end

local DungeonDefinitions = {
	-- Banished Cells I
	DungeonDef:New(DESCENT_DUNGEON_NAME_BC1, DESCENT_DUNGEON_NAME_VET_BC1, DESCENT_PLEDGE_NAME_BC1, 4107, {1554, 1553, 1552}),
	-- Banished Cells II
	DungeonDef:New(DESCENT_DUNGEON_NAME_BC2, DESCENT_DUNGEON_NAME_VET_BC2, DESCENT_PLEDGE_NAME_BC2, 4597, {451, 1564, 449}),
	-- Fungal Grotto I
	DungeonDef:New(DESCENT_DUNGEON_NAME_FG1, DESCENT_DUNGEON_NAME_VET_FG1, DESCENT_PLEDGE_NAME_FG1, 3993, {1561, 1560, 1559}),
	-- Fungal Grotto II
	DungeonDef:New(DESCENT_DUNGEON_NAME_FG2, DESCENT_DUNGEON_NAME_VET_FG2, DESCENT_PLEDGE_NAME_FG2, 4303, {342, 1563, 340}),
	-- Spindleclutch I
	DungeonDef:New(DESCENT_DUNGEON_NAME_SC1, DESCENT_DUNGEON_NAME_VET_SC1, DESCENT_PLEDGE_NAME_SC1, 4054, {1570, 1569, 1568}),
	-- Spindleclutch II
	DungeonDef:New(DESCENT_DUNGEON_NAME_SC2, DESCENT_DUNGEON_NAME_VET_SC2, DESCENT_PLEDGE_NAME_SC2, 4555, {448, 1572, 446}),
	-- Darkshade Caverns I
	DungeonDef:New(DESCENT_DUNGEON_NAME_DC1, DESCENT_DUNGEON_NAME_VET_DC1, DESCENT_PLEDGE_NAME_DC1, 4145, {1586, 1585, 1584}),
	-- Darkshade II
	DungeonDef:New(DESCENT_DUNGEON_NAME_DC2, DESCENT_DUNGEON_NAME_VET_DC2, DESCENT_PLEDGE_NAME_DC2, 4641, {467, 1588, 465}),
	-- Elden Hollow I
	DungeonDef:New(DESCENT_DUNGEON_NAME_EH1, DESCENT_DUNGEON_NAME_VET_EH1, DESCENT_PLEDGE_NAME_EH1, 4336, {1578, 1577, 1576}),
	-- Elden Hollow II
	DungeonDef:New(DESCENT_DUNGEON_NAME_EH2, DESCENT_DUNGEON_NAME_VET_EH2, DESCENT_PLEDGE_NAME_EH2, 4675, {463, 1580, 461}),
	-- Wayrest Sewers I
	DungeonDef:New(DESCENT_DUNGEON_NAME_WS1, DESCENT_DUNGEON_NAME_VET_WS1, DESCENT_PLEDGE_NAME_WS1, 4246, {1594, 1593, 1592}),
	-- Wayrest Sewers II
	DungeonDef:New(DESCENT_DUNGEON_NAME_WS2, DESCENT_DUNGEON_NAME_VET_WS2, DESCENT_PLEDGE_NAME_WS2, 4813, {681, 1596, 679}),
	-- Crypt of Hearts I
	DungeonDef:New(DESCENT_DUNGEON_NAME_COH1, DESCENT_DUNGEON_NAME_VET_COH1, DESCENT_PLEDGE_NAME_COH1, 4379, {1615, 1614, 1613}),
	-- Crypt of Hearts II
	DungeonDef:New(DESCENT_DUNGEON_NAME_COH2, DESCENT_DUNGEON_NAME_VET_COH2, DESCENT_PLEDGE_NAME_COH2, 5113, {1084, 942, 941}),
	-- Arx Corinium
	DungeonDef:New(DESCENT_DUNGEON_NAME_AC, DESCENT_DUNGEON_NAME_VET_AC, DESCENT_PLEDGE_NAME_AC, 4202, {1609, 1608, 1607}),
	-- City of Ash I
	DungeonDef:New(DESCENT_DUNGEON_NAME_COA1, DESCENT_DUNGEON_NAME_VET_COA1, DESCENT_PLEDGE_NAME_COA1, 4778, {1602, 1601, 1600}),
	-- City of Ash II
	DungeonDef:New(DESCENT_DUNGEON_NAME_COA2, DESCENT_DUNGEON_NAME_VET_COA2, DESCENT_PLEDGE_NAME_COA2, 5120, {1114, 1107, 1108}),
	-- Direfrost Keep
	DungeonDef:New(DESCENT_DUNGEON_NAME_DK, DESCENT_DUNGEON_NAME_VET_DK, DESCENT_PLEDGE_NAME_DK, 4346, {1628, 1627, 1626}),
	-- Tempest Island
	DungeonDef:New(DESCENT_DUNGEON_NAME_TI, DESCENT_DUNGEON_NAME_VET_TI, DESCENT_PLEDGE_NAME_TI, 4538, {1622, 1621, 1620}),
	-- Volenfell
	DungeonDef:New(DESCENT_DUNGEON_NAME_VF, DESCENT_DUNGEON_NAME_VET_VF, DESCENT_PLEDGE_NAME_VF, 4432, {1634, 1633, 1632}),
	-- Blackheart Haven
	DungeonDef:New(DESCENT_DUNGEON_NAME_BH, DESCENT_DUNGEON_NAME_VET_BH, DESCENT_PLEDGE_NAME_BH, 4589, {1652, 1651, 1650}),
	-- Blessed Crucible
	DungeonDef:New(DESCENT_DUNGEON_NAME_BC, DESCENT_DUNGEON_NAME_VET_BC, DESCENT_PLEDGE_NAME_BC, 4469, {1646, 1645, 1644}),
	-- Selene's Web
	DungeonDef:New(DESCENT_DUNGEON_NAME_SW, DESCENT_DUNGEON_NAME_VET_SW, DESCENT_PLEDGE_NAME_SW, 4733, {1640, 1639, 1638}),
	-- Vaults of Madness
	DungeonDef:New(DESCENT_DUNGEON_NAME_VM, DESCENT_DUNGEON_NAME_VET_VM, DESCENT_PLEDGE_NAME_VOM, 4822, {1658, 1657, 1656}),
	-- Imperial City Prison
	DungeonDef:New(DESCENT_DUNGEON_NAME_ICP, DESCENT_DUNGEON_NAME_VET_ICP, DESCENT_PLEDGE_NAME_ICP, 5136, {1303, 1129, 1128}),
	-- White-Gold Tower
	DungeonDef:New(DESCENT_DUNGEON_NAME_WGT, DESCENT_DUNGEON_NAME_VET_WGT, DESCENT_PLEDGE_NAME_WGT, 5342, {1279, 1276, 1275}),
	-- Ruins of Mazzatun
	DungeonDef:New(DESCENT_DUNGEON_NAME_ROM, DESCENT_DUNGEON_NAME_VET_ROM, DESCENT_PLEDGE_NAME_ROM, 5403, {1506, 1508, 1507}),
	-- Cradle of Shadows
	DungeonDef:New(DESCENT_DUNGEON_NAME_COS, DESCENT_DUNGEON_NAME_VET_COS, DESCENT_PLEDGE_NAME_COS, 5702, {1524, 1526, 1525}),
	-- Bloodroot Forge
	DungeonDef:New(DESCENT_DUNGEON_NAME_BF, DESCENT_DUNGEON_NAME_VET_BF, DESCENT_PLEDGE_NAME_BF, 5889, {1696, 1695, 1694}),
	-- Falkreath Hold
	DungeonDef:New(DESCENT_DUNGEON_NAME_FH, DESCENT_DUNGEON_NAME_VET_FH, DESCENT_PLEDGE_NAME_FH, 5891, {1704, 1703, 1702}),
	-- Scalecaller Peak
	DungeonDef:New(DESCENT_DUNGEON_NAME_SCP, DESCENT_DUNGEON_NAME_VET_SCP, DESCENT_PLEDGE_NAME_SCP, 6065, {1981, 1980, 1979}),
	-- Fang Lair
	DungeonDef:New(DESCENT_DUNGEON_NAME_FL, DESCENT_DUNGEON_NAME_VET_FL, DESCENT_PLEDGE_NAME_FL, 6064, {1965, 1964, 1963}),
	-- Moon Hunter Keep
	DungeonDef:New(DESCENT_DUNGEON_NAME_MHK, DESCENT_DUNGEON_NAME_VET_MHK, DESCENT_PLEDGE_NAME_MHK, 6186, {2154, 2156, 2155}),
	-- March of Sacrifices
	DungeonDef:New(DESCENT_DUNGEON_NAME_MOS, DESCENT_DUNGEON_NAME_VET_MOS, DESCENT_PLEDGE_NAME_MOS, 6188, {2164, 2166, 2165}),
	-- Frostvault
	DungeonDef:New(DESCENT_DUNGEON_NAME_FV, DESCENT_DUNGEON_NAME_VET_FV, DESCENT_PLEDGE_NAME_FV, 6249, {2262, 2264, 2263}),
	-- Depths of Malatar
	DungeonDef:New(DESCENT_DUNGEON_NAME_DOM, DESCENT_DUNGEON_NAME_VET_DOM, DESCENT_PLEDGE_NAME_DOM, 6251, {2272, 2274, 2273}),
	-- Moongrave Fane
	DungeonDef:New(DESCENT_DUNGEON_NAME_MGF, DESCENT_DUNGEON_NAME_VET_MGF, DESCENT_PLEDGE_NAME_MGF, 6349, {2417, 2419, 2418}),
	-- Lair of Maarselok
	DungeonDef:New(DESCENT_DUNGEON_NAME_LOM, DESCENT_DUNGEON_NAME_VET_LOM, DESCENT_PLEDGE_NAME_LOM, 6351, {2427, 2429, 2428}),
	-- Icereach
	DungeonDef:New(DESCENT_DUNGEON_NAME_IR, DESCENT_DUNGEON_NAME_VET_IR, DESCENT_PLEDGE_NAME_IR, 6414, {2541, 2543, 2542}),
	-- Unhallowed Grave
	DungeonDef:New(DESCENT_DUNGEON_NAME_UG, DESCENT_DUNGEON_NAME_VET_UG, DESCENT_PLEDGE_NAME_UG, 6416, {2551, 2553, 2552}),
	-- Stone Garden
	DungeonDef:New(DESCENT_DUNGEON_NAME_SG, DESCENT_DUNGEON_NAME_VET_SG, DESCENT_PLEDGE_NAME_SG, 6505, {2755, 2698, 2697}),
	-- Castle Thorn
	DungeonDef:New(DESCENT_DUNGEON_NAME_CT, DESCENT_DUNGEON_NAME_VET_CT, DESCENT_PLEDGE_NAME_CT, 6507, {2706, 2708, 2707}),
	-- Black Drake Villa
	DungeonDef:New(DESCENT_DUNGEON_NAME_BDV, DESCENT_DUNGEON_NAME_VET_BDV, DESCENT_PLEDGE_NAME_BDV, 6576, {2833, 2835, 2834}),
	-- The Cauldron
	DungeonDef:New(DESCENT_DUNGEON_NAME_CD, DESCENT_DUNGEON_NAME_VET_CD, DESCENT_PLEDGE_NAME_CD, 6578, {2843, 2845, 2844}),
	-- Red Petal Bastion
	DungeonDef:New(DESCENT_DUNGEON_NAME_RPB, DESCENT_DUNGEON_NAME_VET_RPB, DESCENT_PLEDGE_NAME_RPB, 6683, {3018, 3020, 3019}),
	-- The Dread Cellar
	DungeonDef:New(DESCENT_DUNGEON_NAME_TDC, DESCENT_DUNGEON_NAME_VET_TDC, DESCENT_PLEDGE_NAME_TDC, 6685, {3028, 3030, 3029}),
	-- Coral Aerie
	DungeonDef:New(DESCENT_DUNGEON_NAME_CA, DESCENT_DUNGEON_NAME_VET_CA, DESCENT_PLEDGE_NAME_CA, 6740, {3153, 3108, 3107}),
	-- Shipwright's Regret
	DungeonDef:New(DESCENT_DUNGEON_NAME_SWR, DESCENT_DUNGEON_NAME_VET_SWR, DESCENT_PLEDGE_NAME_SWR, 6742, {3154, 3118, 3117}),
}

local dungeonByName = {}
local dungeonByPledgeName = {}
local pledgedDungeons = nil

-- Normally should be empty
local unresolvedDungeonNames = {}

local function UpdateJournalEntry(journalIndex)
	if not pledgedDungeons then
		LogError("Called in incorrect state")
		return
	end
	local pledgeQuestName, _, _, stepType, _, isCompleted, _, _, _, questType = GetJournalQuestInfo(journalIndex)
	if questType == QUEST_TYPE_UNDAUNTED_PLEDGE then
		local dungeon = dungeonByPledgeName[pledgeQuestName]
		if not dungeon then
			LogError('Unresolved pledge quest: ' .. pledgeQuestName)
		else
			pledgedDungeons[GetString(dungeon:GetId())] = stepType
		end
	end
end

function ScanJournalEntries()
	pledgedDungeons = {}
	for i = 1, MAX_JOURNAL_QUESTS do
		UpdateJournalEntry(i)
	end
end

local function RenderAchievements(def, achievementContainer)
	if not MAX_TRACKABLE_ACHIEVEMENTS then
		MAX_TRACKABLE_ACHIEVEMENTS = 0
		while achievementContainer:GetNamedChild(string.format("Slot%d", MAX_TRACKABLE_ACHIEVEMENTS + 1)) do
			MAX_TRACKABLE_ACHIEVEMENTS = MAX_TRACKABLE_ACHIEVEMENTS + 1
		end
	end
	for i = MAX_TRACKABLE_ACHIEVEMENTS, 1, - 1 do
		local control = achievementContainer:GetNamedChild(string.format("Slot%d", i))
		local achievementId = def.achievements[MAX_TRACKABLE_ACHIEVEMENTS - i + 1]
		local _, _, _, icon, completed, _, _ = GetAchievementInfo(achievementId)
		control:SetHidden(completed)
		control.achievementId = achievementId
		if not completed then
			control:SetTexture(icon)
			control:SetDesaturation(ZO_ACHIEVEMENT_DISABLED_DESATURATION)
		end
	end
end

function Descent_TemplateNavigationEntry_Keyboard_Achievement_OnMouseEnter(control)
	if control.achievementId then
		InitializeTooltip(AchievementTooltip, control:GetParent():GetParent(), TOPRIGHT, - 70, 0, TOPLEFT)
		AchievementTooltip:SetAchievement(control.achievementId)
	end
end
function Descent_TemplateNavigationEntry_Keyboard_Achievement_OnMouseExit(control)
	ClearTooltip(AchievementTooltip)
end

local function OnAddonLoaded(eventCode, addOnName)
	if addOnName ~= ADDON_NAME then return end

	-- Prepare the working data
	local integrityCheckPassed = true
	for i, def in ipairs(DungeonDefinitions) do
		if not def:CheckIntegrity() then
			integrityCheckPassed = false
			LogError(string.format("Dungeon definition check failed, bailing out. (index: %d)", i))
			break
		end

		local normalName = GetString(def:GetNormalId())
		local veteranName = GetString(def:GetVeteranId())
		local pledgeQuestName = GetString(def:GetPledgeQuestId())

		if not normalName then
			LogError(string.format("Unresolved dungeon name: %s", def:GetNormalId()))
		end
		if not veteranName then
			LogError(string.format("Unresolved dungeon name: %s", def:GetVeteranId()))
		end
		if not pledgeQuestName then
			LogError(string.format("Unresolved dungeon name: %s", def:GetPledgeQuestId()))
		end

		dungeonByName[normalName] = def
		dungeonByName[veteranName] = def
		dungeonByPledgeName[pledgeQuestName] = def
	end

	if not integrityCheckPassed then
		return
	end

	-- Swap the dungeon entry
	local TEMPLATE_TREE_ENTRY = "ZO_ActivityFinderTemplateNavigationEntry_Keyboard"

	local tree = DUNGEON_FINDER_MANAGER:GetKeyboardObject().navigationTree
	local templateInfo = tree.templateInfo[TEMPLATE_TREE_ENTRY]

	templateInfo.objectPool:ReleaseAllObjects()
	templateInfo.objectPool = ZO_ControlPool:New("Descent_TemplateNavigationEntry_Keyboard", tree.control)

	local oldSetupFunction = tree.templateInfo[TEMPLATE_TREE_ENTRY].setupFunction

	tree.templateInfo[TEMPLATE_TREE_ENTRY].setupFunction = function (node, control, data, open)
		local def = dungeonByName[data.rawName]
		if def then
			if def:GetQuestId() ~= 0 then 
				local _, questType = GetCompletedQuestInfo(def:GetQuestId())
				control:GetNamedChild("IconQuest"):SetHidden(questType ~= 0)
			end
			if node.data.activityType == 3 then
				RenderAchievements(def, control:GetNamedChild("Achievements"))
			end
		else
			if not unresolvedDungeonNames[data.rawName] then
				unresolvedDungeonNames[data.rawName] = true
				LogError(string.format("Can't resolve the dungeon definition by name: \"%s\". Addon \"%s\" probably needs to be updated.", data.rawName, ADDON_NAME))
			end
		end
		local oldGetTextColor = control.text.GetTextColor
		control.text.GetTextColor = function(self)
			if not pledgedDungeons then
				ScanJournalEntries()
			end
			local status = pledgedDungeons[data.rawName]
			if status then
				if status == 1 then
					return COLOR_PLEDGE_ACTIVE:UnpackRGBA()
				elseif status == 2 or status == 3 then
					return COLOR_PLEDGE_DONE:UnpackRGBA()
				end
			else
				return oldGetTextColor(self)
			end
		end
		oldSetupFunction(node, control, data, open)
	end
end

local function OnQuestUpdated(_, journalIndex)
	if not pledgedDungeons then
		ScanJournalEntries()
	else
		UpdateJournalEntry(journalIndex)
	end
end
local function OnQuestRemoved()
	ScanJournalEntries()
end
local function OnQuestListUpdated()
	ScanJournalEntries()
end

function OnAchievementAwarded(event, name, points, id)
	local processed = false
	for _, def in ipairs(DungeonDefinitions) do
		if def:IsRelevantAchievment(id) then
			processed = true
			DUNGEON_FINDER_MANAGER:GetKeyboardObject().navigationTree:RefreshVisible()
			break
		end
	end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_QUEST_ADDED, OnQuestUpdated)
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_QUEST_ADVANCED, OnQuestUpdated)
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_QUEST_REMOVED, OnQuestRemoved)
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_QUEST_LIST_UPDATED, OnQuestListUpdated)

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ACHIEVEMENT_AWARDED, OnAchievementAwarded)


