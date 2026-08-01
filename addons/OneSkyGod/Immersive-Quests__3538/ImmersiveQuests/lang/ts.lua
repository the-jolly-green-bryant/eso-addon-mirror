-- Can return to English client text by;
-- /script SetCVar("language.2", "ts")

-- Keybind String
-- Placeholder? Should add to Keybinds when Journal is open, or keep accessible from any UI?
ZO_CreateStringId("SI_BINDING_NAME_IMMQUESTS_OPEN_POPUP", "Open Popup")

-- Localized Strings unrelated to Quest Objectives
local stringsEN = {
	-- These use ZOS localization
	IMMERSIVE_QUESTS_QUEST_NAME = GetString(SI_CUSTOMER_SERVICE_QUEST_NAME),
	IMMERSIVE_QUESTS_UNKNOWN_QUEST = zo_strformat("<<<1>>>", GetString(SI_QUEST_JOURNAL_UNKNOWN_QUEST_NAME)),
	IMMERSIVE_QUESTS_OBJECTIVES = zo_strformat("<<1>>", GetString(SI_QUEST_JOURNAL_QUEST_TASKS)),

	-- Custom Strings
	IMMERSIVE_QUESTS_NAME = "Immersive Quests",
	
	IMMERSIVE_QUESTS_QUEST_PANEL = "Writing Mode",
	IMMERSIVE_QUESTS_QUEST_ID = "Quest ID:",
	IMMERSIVE_QUESTS_STEP_TEXT = "Step Text",

    IMMERSIVE_QUESTS_DEFAULT_STEP_TXT = "\n\n-CLICK HERE TO WRITE STEP TEXT-",
	IMMERSIVE_QUESTS_DEFAULT_OBJ_TXT = "\n\n-CLICK HERE TO WRITE-\n\nOpen the quest journal of your current quest task & READ the quest journal and determine which information is missing from the following: 1-ZONE NAME 2-LOCATION 3-CLUE  \n\n- Zone Name: Can you travel to a different Zone and Still know in which Zone this quest takes part in? \n\n- Location on the Map: Do I know which Part of the Zone map to explore in order to solve the Task?  \n\n- HIERARCHY of CLUES TYPES:\n- Interactive Clues: We invite the player to interact with an NPC or Item in game. Talk again with the NPC to see if they have a clue before adding directions.\n-Known Landmark clues: Name of the Icon on the map.\n-Visual Clues: A scenery, locations or objects that a player may distinguish visually. \n-Guiding Clues: Guides a player step by step from a Location on the map.\n-Cardinal Directions: Use of north, east, south,west, southeast, southwest, etc with a Location.",

	IMMERSIVE_QUESTS_BLOCKED_QUEST = "<'Writer' checkbox unchecked in Settings>",

	IMMERSIVE_QUESTS_QUEST_ID_HELP_LINK_BUTTON = "ESO Data Log",
	IMMERSIVE_QUESTS_QUEST_ID_HELP_LINK = "https://esoitem.uesp.net/viewlog.php?search=&searchtype=uniqueQuest",
	IMMERSIVE_QUESTS_QUEST_ID_HELP_TOOLTIP = "To Get [Quest ID]:\n\n(1) Click ESO Data Log\n(2) Type in the Username:esolog Password:esolog\n(3)  Type in the quest name in the search box and filter it to 'Quests (Unique)' using the drop-down menu just below the search bar\n(4) In the 'Note' column should be a number, this is the [Quest ID]",

    IMMERSIVE_QUESTS_ABANDON_WRITING = "Delete Writing Progress",
    IMMERSIVE_QUESTS_ABANDON_WRITING_BUTTON = "Delete Writing Progress",
    IMMERSIVE_QUESTS_ABANDON_WRITING_ERROR = "Not currently writing for this quest.",

    IMMERSIVE_QUESTS_STEP_TXT_BTN = "Edit Step Text",

	IMMERSIVE_QUESTS_SPELLCHECK = "Text Output",
	IMMERSIVE_QUESTS_CREATE_CODE = "Code Output",

	IMMERSIVE_QUESTS_BACKSTEP = "Previous Step",
	IMMERSIVE_QUESTS_FORWARDSTEP = "Next Step",

	IMMERSIVE_QUESTS_DESCRIPTION_TITLE = "Example Description Title",
	IMMERSIVE_QUESTS_DESCRIPTION = "Example Description",
	IMMERSIVE_QUESTS_BUTTON_NAME = "Example Button Name",
	IMMERSIVE_QUESTS_BUTTON_TOOLTIP = "Provide feedback on the accuracy and effectiveness of the quest directions. If you find any misleading information, you may be eligible for a bounty of up to 250,000 Gold. Please send the name of the quest and the task at hand, along with a description of the issue, to report inaccuracies. On the other hand, if you loved a quest and would like to give praise to the writer, let us know which quest so we can pass on the good news!",
	IMMERSIVE_QUESTS_DISCORD_TOOLTIP = "Link To Our Discord If You Wish To Become A Creative Writer, Playtester Or Proofreader For The Unfinished Zones And Quests.",
	IMMERSIVE_QUESTS_YOUTUBE_TOOLTIP = "Link To A Youtube Tutorial For The Creative Writers, Playtesters And Proofreaders.",
	IMMERSIVE_QUESTS_ADDONS_TOOLTIP = "Link To An Useful List Of Immersion Addons And Settings.",
	IMMERSIVE_QUESTS_FLOWCHART = "Link To The Directions Flow Chart.",
}

for id, stringVar in pairs(stringsEN) do
   ZO_CreateStringId(id, stringVar)
   SafeAddVersion(id, 1)
end

-- Define AddOn namespace/table
ImmersiveQuests = {}

-- These are the numerical constants used by ZOS to note Alliance as returned by GetUnitAlliance("player")
-- Use these according to the below format if you want to append different text dependent on player Alliance
--[[
	ALLIANCE_ALDMERI_DOMINION
	ALLIANCE_DAGGERFALL_COVENANT
	ALLIANCE_EBONHEART_PACT
]]

-- Since we're using Ids to get the game to translate quest names for us, it's handy to put the quest name as a comment (via --) at the end of that line
-- If an objective is repeated, add a unique number to the end (this can be an incremented one, e.g. ["Objective 1"], ["Objective 2"]). These will need a stepTextKey field to assign the appendText to the correct version of the objective

ImmersiveQuests.localization = {


-- \/ PASTE CODE UNDER THIS LINE \/ -- -- \/ PASTE CODE UNDER THIS LINE \/ -- -- \/ PASTE CODE UNDER THIS LINE \/ -- 

-- /\ PASTE CODE ABOVE THIS LINE /\ ---- /\ PASTE CODE ABOVE THIS LINE /\ ---- /\ PASTE CODE ABOVE THIS LINE /\ --



}