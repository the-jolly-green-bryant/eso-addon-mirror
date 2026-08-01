local strings = {
	SPT_GUI_CHAR_LEVEL	= "Character Level",
	SPT_GUI_MAIN_QUEST	= "Main Quest",
	SPT_GUI_FOLIUM		= "Folium Discognitum",
	SPT_GUI_TUTORIAL	= "Tutorial",
	SPT_GUI_AVA_RANK	= "Alliance War Rank",
	SPT_GUI_MAEL_ARENA	= "Maelstrom Arena",


	SPT_GUI_TITLE		= "What's missing? - Skill Point Tracker",
	SPT_GUI_PANEL_HEADER	= "SKILL POINT TRACKER",
	SPT_GUI_INFO_HEADER	= "Quest lists",

	SPT_GUI_GSP		= "General Skill Points",
	SPT_GUI_SQS		= "Storyline Quests & Skyshards",
	SPT_GUI_GDQ		= "Group Dungeon Quests",
	SPT_GUI_PDB		= "Public Dungeon Group Boss Events",
	SPT_GUI_SOURCE		= "Source",
	SPT_GUI_PROGRESS	= "Progress",
	SPT_GUI_ZONE		= "Zone",
	SPT_GUI_STORYLINE	= "Storyline",
	SPT_GUI_SKYSHARDS	= "Skyshards",
	SPT_GUI_GROUP_DUNGEON = "Group Dungeon",
	SPT_GUI_PUBLIC_DUNGEON = "Public Dungeon",
	SPT_GUI_DUNGEON_NAME = "Dungeon Name",

	SPT_GUI_TOTAL		= "Total",
	SPT_GUI_CHAR_TOTAL	= "Character Total",
	SPT_GUI_UNASSIGNED	= "unassigned",


	SI_BINDING_NAME_SPT_TOGGLE      = "Skill Point Tracker",
	SI_BINDING_NAME_SPT_TAB_PREV    = "Prev Tab",
	SI_BINDING_NAME_SPT_TAB_NEXT    = "Next Tab",

	SPT_GUI_TAB_GSP  = "General",
	SPT_GUI_TAB_SQS  = "Zones",
	SPT_GUI_TAB_GDQ  = "Dungeons",
	SPT_GUI_TAB_PD   = "Public",
	SPT_GUI_SCANNING = "Scanning...",

	SPT_GUI_ZN_MQ		= "Main Quest",

	SPT_MSG_SHOW_GUI	= "SPT displayed.",
	SPT_MSG_HIDE_GUI	= "SPT hidden.",

	SPT_MSG_INIT		= "Running SPT for the first time!",
	SPT_MSG_HELP		= "SPT Activated!",

	SPT_QUEST_NA		= "These skill points are not quest based.",
	SPT_QUEST_NONE		= "There are no skill point quests in this zone.",

	SPT_GUI_NOT_SCANNED	= "Not yet scanned - play this character once",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
