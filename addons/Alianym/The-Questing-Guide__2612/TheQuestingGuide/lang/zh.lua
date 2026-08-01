--Translated by AK@shijian452
local strfmt = string.format
local zStrFmt = zo_strformat
local overviewGroupTabDescFmt = "%s %s|t26:26:%s|t %s|t26:26:%s|t %s|t26:26:%s|t / |t26:26:%s|t\n\n%s\n\n%s"
local overviewGroupTabDungIcon = "/esoui/art/icons/poi/poi_groupinstance_complete.dds"
local overviewGroupTabTrialIcon = "/esoui/art/icons/poi/poi_raiddungeon_complete.dds"
local overviewGroupTabArenaIconOne = "/esoui/art/icons/poi/poi_groupinstance_complete.dds"
local overviewGroupTabArenaIconTwo = "/esoui/art/icons/poi/poi_raiddungeon_complete.dds"

local stringsZH = {
	--TQG_CONFIRM_QUEST_ZONE_STORY = "Zone Story",
	--TQG_CONFIRM_QUEST_POI = "Points of Interest",

	SI_BINDING_NAME_TQG_INTERACT_KEY = "Toggle Quest Guide",
	SI_BINDING_NAME_TQG_INTERACT_GAMEPAD_KEY = zStrFmt("<<1>> – <<2>>", "Toggle Quest Guide", GetString(SI_GAMEPAD_SECTION_HEADER)),
	TQG_MENU_JOURNAL = "The Questing Guide",

	TQG_OVERVIEW_TAB = GetString(SI_CUSTOMER_SERVICE_OVERVIEW), --"Overview"
	TQG_OVERVIEW_CLASSIC_DESC = "关于位面融合……这是上古卷轴Online中关于奥比斯的初始剧情线，随着你的进展，故事将在《主线剧情》、《联盟》、《公会》故事线中交织在一起。\n\n各联盟的故事是并行发生的——例如 (各阵营初学者的岛), 然后是奥瑞敦/格伦姆布拉/石落……等。 但是，您不必觉得到达冷港之前必须完成所有联盟故事。\n\n最初的联盟故事途径是；\n – 你的角色所在联盟的故事; 然后是卡德威尔的银牌/(卡德威尔的金牌代表其他两个联盟故事),按顺时针顺序作为“主线任务之后”的体验.",
	TQG_OVERVIEW_DLC_DESC = "DLC和章节部分 涵盖了DLC地牢、DLC区域的所有主要故事情节. 呈现的顺序默认按照DLC发布顺序的先后.\n\n主要活动包括：\n – 崇高计划 <The Sublime Plot>\n – 重塑奥辛纽姆 <Reforging Orsinium>\n – 盗贼公会 <Thieves Guild> / 黑暗兄弟会 <Dark Brotherhood>\n – 魔神战争<Daedric War>\n – 失落的遗产 <A Lost Legacy>\n – 龙之季节 <Season of the Dragon>\n – 天际的黑暗之心 <Dark Heart of Skyrim>\n – 湮灭之门 <Gates of Oblivion>\n – 布莱顿人不朽神话 <Legacy of the Bretons>\n – 森罗万象的阴影 <Shadow of Morrowind>",
	TQG_OVERVIEW_GROUP_DESC = strfmt(overviewGroupTabDescFmt, "组队内容包含 迄今为止大多数的组队副本.",  "\n地牢: ", overviewGroupTabDungIcon, "试炼: ", overviewGroupTabTrialIcon, "竞技场: ", overviewGroupTabArenaIconOne, overviewGroupTabArenaIconTwo, "模式有普通、精英 和 困难精英（HM）, 但大漩涡竞技场除外 (做任务只需要完成普通模式), 任务发布者并不关心您完成任务的难度.", "这些任务仍然与他们发布的内容相关联。 例如： 洛克汗的巨口 在 瑞驰的马卡斯 中，但与 盗贼工会 一起发布，因此将列在后者之下。"),

	TQG_OVERVIEW_DLC_TITLE = "DLC + 章节",
	TQG_OVERVIEW_GROUP_TITLE = "组队内容",

	TQG_CLASSIC_TAB = GetString(SI_HOUSECATEGORYTYPE2), --"Classic"
	TQG_DLC_TAB = GetString(SI_COLLECTIBLECATEGORYTYPE1), --"DLC"
	TQG_GROUP_TAB = GetString(SI_INSTANCETYPE2), --"Group"

	TQG_QUEST_BTN = "经典：任务地图",
	TQG_CRAGLORN_BTN = zStrFmt("<<1>>: <<2>>", GetString(SI_HOUSECATEGORYTYPE2), GetZoneNameById(888)),
	TQG_IC_BTN = "DLC: 崇高计划",
	TQG_ORSINIUM_BTN = "DLC: 重塑奥辛纽姆",

	TQG_OVERVIEW_LINKS_TITLE = "有用的链接",
	TQG_OVERVIEW_LINKS_TEXT = "由于链接的性质，您越深入研究越有可能会有剧透风险。 这是前提警告...",
	TQG_OVERVIEW_OBJECTIVE_TITLE = GetString(SI_GAMEPAD_CONTACTS_NOTES_TITLE), --"Notes"
	TQG_OVERVIEW_OBJECTIVE_TEXT = "不同的地下城/试炼/竞技场将有不同人数要求。 大漩涡竞技场是一个单人的竞技场——你将独自面对它的恐怖。\n\n(一般情况下, 地下城任务是不可重复的, 而试炼任务每周可重复. 您只需要完成一次即可登记它们的成就。)",
	TQG_DEFAULT_QUEST_COMPLETE = GetString(SI_QUEST_TYPE_COMPLETE), --"Complete"
	TQG_DEFAULT_QUEST_INCOMPLETE = GetString(SI_ACHIEVEMENTS_INCOMPLETE), --"Incomplete"

	TQG_PROLOGUE = "序幕",
	TQG_EPILOGUE = "后记",
	TQG_PREREQ = "先决条件",

	TQG_DUNGEON = GetString(SI_INSTANCEDISPLAYTYPE2), --"Dungeon"
	TQG_ARENA = "竞技场",
	TQG_TRIAL = GetString(SI_INSTANCETYPE3), --"Trial"

	TQG_ENTER = "进入",
	TQG_SEEK = "寻找",
	
	TQG_PLANEMELD = "位面融合",

	TQG_DOMINION = GetAllianceName(ALLIANCE_ALDMERI_DOMINION), --"Aldmeri Dominion"
	TQG_COVENANT = GetAllianceName(ALLIANCE_DAGGERFALL_COVENANT), --"Daggerfall Covenant"
	TQG_PACT = GetAllianceName(ALLIANCE_EBONHEART_PACT), --"Ebonheart Pact"
	TQG_COLDHARBOUR = GetZoneNameById(347), --"Coldharbour"
	TQG_CRAGLORN = GetZoneNameById(888), --"Craglorn"
	TQG_GUILDS_AND_GLORY = "公会荣耀",
	TQG_DAEDRIC_WAR = "魔族战争",
	TQG_MURKMIRE = zStrFmt("<<1>>: <<2>>", GetZoneNameById(726), "插曲"),
	TQG_CHAPTER_ELSWEYR = "龙之季节",
	TQG_CHAPTER_SKYRIM = "天际的黑暗之心",
	TQG_CHAPTER_BLACKWOOD = "湮灭之门",
	TQG_CHAPTER_HIGH_ISLE = "布莱顿人不朽神话",
	TQG_CHAPTER_SHADOW_MORROWIND = "森罗万象的阴影",
	TQG_CHAPTER_RECOLLECTION_ITHELIA = "回忆伊特里亚",
	TQG_CHAPTER_SEASON_WORM_CULT = "蠕虫教的四季",

	TQG_DUNGEON_DLC_OLD = zStrFmt("<<1>> <<2>> <<3>>", GetString(SI_PLAYER_MENU_MISC), GetString(SI_INSTANCEDISPLAYTYPE2), GetString(SI_COLLECTIBLECATEGORYTYPE1)),

	TQG_INVITATION = "一个邀请",
	TQG_FIGHTERS_NAME = "斗士工会",
	TQG_FIGHTERS_DESC = '斗士公会是根据《公会法》第4条成立的，该章程在第二纪元321年第一任在君主瓦努斯·加里昂下得到确认。',
	TQG_MAGES_NAME = "法师公会",
	TQG_MAGES_DESC = '法师公会于第二纪元230年由 瓦努斯·加里昂 和 利里斯十二世 在夏暮岛建立。 它后来被 首席谋士威尔西德·谢 的“公会法案”确认。',
	TQG_DOSHIA_LAIR = "多西娅的巢穴",
	TQG_BONUS_BALMORA = "巴莫拉",
	TQG_BONUS_BALMORA_DESC = '早在第一纪元时，晨风政府就对莫拉格帮进行了制裁，直到今天，他们仍在使用一种被称为“荣誉处决令”的契约制度进行默许合法的暗杀。',
}

for id, stringVar in pairs(stringsZH) do
	stringVar = zStrFmt("<<1>>", stringVar)
	ZO_CreateStringId(id, stringVar)
	SafeAddVersion(id, 1)
end

local DLCTooltipFmt = "<<1>>, <<2>>: <<3>>\n(<<4>> <<5>>)"
local function SetupDLCTooltip(str1, str2, zoneId, str4, str5)
	return zStrFmt(DLCTooltipFmt, str1, str2, GetZoneNameById(zoneId), str4, str5)
end

TQG.DLCQuestIdToTooltip = {
	[5935] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "1/1", 849, GetString(TQG_SEEK), "'瑞亚·奥帕卡利斯'"),
	[6023] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "1/1", 980, GetString(TQG_SEEK), "'先眼教团快信'"),
	[6097] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "1/1", 1011, GetString(TQG_SEEK), "'瓦努斯·加里昂'"),
	[6226] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "1/2", 726, GetString(TQG_SEEK), "'西罗帝尔文保协会需要你!'"),
	[6242] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "2/2", 726, GetString(TQG_SEEK), "'康科迪亚·梅西乌斯'"),
	[6299] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "1/2", 1086, GetString(TQG_SEEK), "'阿内丝·德沃克斯'"),
	[6306] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "2/2", 1086, GetString(TQG_SEEK), "'阿布努尔·萨恩'"),
	[6395] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "1/2", 1133, GetString(TQG_SEEK), "'辛祖尔'"),
	[6398] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "2/2", 1133, "'造访'", "'刀锋谷'"),
}

local groupTooltipFmt = "<<1>>: (<<2>> <<3>>)"
local function SetupGroupTooltip(str1, str2, zoneIdOrName)
	local str3

	if type(zoneIdOrName) == "number" then str3 = GetZoneNameById(zoneId)
	elseif type(zoneIdOrName) == "string" then str3 = zoneIdOrName end

	return zStrFmt(groupTooltipFmt, str1, str2, str3)
end

TQG.GroupQuestIdToTooltip = {
	[5554] = SetupGroupTooltip(GetString(TQG_TRIAL), GetString(TQG_SEEK), "巴洪"),

	[6000] = SetupGroupTooltip(GetString(TQG_TRIAL), GetString(TQG_SEEK), "戴尼罗·雷瑟尔"),
	[6193] = SetupGroupTooltip(GetString(TQG_TRIAL), GetString(TQG_SEEK), "范多里尔"),

	[6354] = SetupGroupTooltip(GetString(TQG_TRIAL), GetString(TQG_SEEK), "纳特雷达"),

	[6504] = SetupGroupTooltip(GetString(TQG_TRIAL), GetString(TQG_SEEK), "泰尔维拉"),

	[6597] = SetupGroupTooltip(GetString(TQG_ARENA), GetString(TQG_SEEK), "安格尔"),

	[6655] = SetupGroupTooltip(GetString(TQG_TRIAL), GetString(TQG_SEEK), "马洛桑"),

	[6784] = SetupGroupTooltip(GetString(TQG_TRIAL), GetString(TQG_SEEK), "约曼·吉勒恩"),

	[7032] = SetupGroupTooltip(GetString(TQG_TRIAL), GetString(TQG_SEEK), "研究员安塞"),
}