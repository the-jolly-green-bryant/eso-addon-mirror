-- Can return to English client text by;
-- /script SetCVar("language.2", "pt")

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

		[GetQuestName(4692)] = { -- "A Pinch of Sugar"				-- OneSkyGod
			["Talk to Cinder-Tail"] = 
				{appendText=""},
			["Steal Thunderbug Eggs"] = 
				{appendText=". Which are laid in the Thunderbug's Mounds, closely guarded by the Thunderbugs infesting the plantation."},
			["Destroy Rat Nests"] = 
				{appendText="\nThey have a lingering green stench and are scattered across the fields."},
			["Talk to Juranda-ra 1"] = 
				{appendText="", stepTextKey="Juranda-ra will want to know the Rat Nests have been dealt with."},
			["Talk to Juranda-ra 2"] = 
				{appendText="", stepTextKey="Juranda-ra was thankful for my aid. Perhaps there's a reward for my help."},
		},

[GetQuestName(4255)] = { --"Ensuring Security"
        ["Talk to Watch Captain Astanya"] =
            {appendText=". Watchman Vinenondil told me that they are by the top of the docks."},--D --K
        ["Talk to Advisor Norion 1"] =
            {appendText=", awaiting assistance at the east warehouse.", stepTextKey="I should speak to Advisor Norion in the west warehouse."},--A
        ["Find the Deployment Plans 1"] =
            {appendText=".", stepTextKey="I should look for the plans inside the warehouse."},--B--C
        ["Talk to Advisor Norion 2"] =
            {appendText=" outside.", stepTextKey="I found the plans Advisor Norion spoke of. I should report back to him outside of the warehouse."},--C
        ["Talk to Steward Eminwe 1"] =
            {appendText=" in Audrion.", stepTextKey="I need to seek out Steward Eminwe at a warehouse on the north end of the docks."},--G
        ["Search for Evidence of Poison"] =
            {appendText=" in the food supplies. Eminwe suspects sabotage."},--B--C
        ["Talk to Steward Eminwe 2"] =
            {appendText=".", stepTextKey="I discovered some suspicious salted meats, possibly poisoned. I should return to Steward Eminwe back at the warehouse."},--G
        ["Talk to Watchman Heldil 1"] =
            {appendText=". Once you've had a conversation with Watch Captain Astanya, position yourself to face the stairs behind her. Ascend the stairs, which are situated on the docks. As you reach the top, you will spot the Watchman infront of the second house on your right.", stepTextKey="Watch Captain Astanya has, somewhat rudely, directed me to speak with Watchman Heldil."},--I		
        ["Talk to the Suspect at the Door"] =
            {appendText=""},--C--B
        ["Talk to the Suspect"] =
            {appendText=" in Skywatch."},--A
	["Witness Confrontation"] =
            {appendText="."},
        ["Talk to Watchman Heldil 2"] =
            {appendText=".", stepTextKey="Looks like my work here is done. I should speak to the watchman one more time."},--C--B
        ["Talk to Watchman Heldil 3"] =
            {appendText=" in the house north of the stables.", stepTextKey="I should speak to Watchman Heldil."},--A
        ["Talk to Steward Eminwe 3"] =
            {appendText=".", stepTextKey="I should speak to Steward Eminwe in one of the warehouses to the east."},--C--H
        ["Examine the Supplies For Tampering"] =
            {appendText=" next to the warehouse near the eastern docks. I really like Eminwe's dress."},--J
        ["Talk to Advisor Norion 3"] =
            {appendText=".", stepTextKey="I need to seek out Advisor Norion by the south end of the docks."},
        ["Find the Deployment Plans 2"] =
            {appendText=" just behind Norion.", stepTextKey="I should enter the warehouse and search for the stolen plans."},--C
    },




    [GetQuestName(4410)] = { --"Assisting the Assistant"--Playtesters test
        ["Collect Dwemer Ring"] =
            {appendText=". Jindra Frostbrow, Ambarel’s rival, may be seen damaging Ambarel’s favorite cherry blossom that she visited every day right next to her house, under the guise of entertaining the crowds. Jidra is furious that Ambarel just got the promotion to the the Lillandril branch of the Mages Guild in Summerset instead of her.\nEXAMPLE OF PUZZLE CLUE\n"},
        ["Collect Dwemer Gear"] =
            {appendText=". The house can be seen by looking northwest from the center of the only bridge in town. Ingamircil House, which contains the tube, is located southeast of the Skywatch Coinhouse bank.\nEXAMPLE OF HANDHOLDY CLUE\n"},
        ["Collect Dwemer Tube"] =
            {appendText=". From the house near a tavern. \nEXAMPLE OF VAGUE CLUE\n"},
        ["Talk to Neetra"] =
            {appendText=". Back at the Mages Guild.\nERROR, PLAYTESTERs TABLE LETTER B, GIVE FEEDBACK "},
    },





	[GetQuestName(5058)] = { --"All the Fuss"--Playtesters test
       		 ["Report to a Watchman at Vulkhel Guard"] =
          		  {appendText=". He can be found guarding a gate north of the Fighters Guild Hall on a beaten path on the western side of the city. \nERROR, NO DIRECTION TO A KNOWN CITY LETTER B, GIVE FEEDBACK \n"},
	},

	[GetQuestName(5073)] = { --"Aicessar's Invitation"--Playtesters test
		["Talk to Aicessar 1"] =
			{appendText=". I should talk the envoy of the guild in the Vulkhel Guard Fighter's Guild which is the westernmost building in the city, right next to the seashore. \nERROR, NO ZONE NAME, GIVE FEEDBACK\n", stepTextKey="I should find out what I can about the Fighters Guild, and decide if the Guild is for me."},
		["Talk to Aicessar 2"] =
			{appendText=". Right besides me.\nERROR, PLAYTESTERs TABLE LETTER C\n", stepTextKey="I should speak to Aicessar to confirm my interest in joining the Fighters Guild."},
},



}