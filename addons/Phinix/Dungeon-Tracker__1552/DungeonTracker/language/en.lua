local DTAddon = _G['DTAddon']
local L = {}

--------------------------------------------------------------------------------------------------------------------
-- English
--------------------------------------------------------------------------------------------------------------------

-- General Strings
	L.DTAddon_Title			= "Dungeon Tracker"
	L.DTAddon_CNorm			= "Completed Normal: "
	L.DTAddon_CVet			= "Completed Veteran: "
	L.DTAddon_CNormI		= "Completed Normal I: "
	L.DTAddon_CNormII		= "Completed Normal II: "
	L.DTAddon_CVetI			= "Completed Veteran I: "
	L.DTAddon_CVetII		= "Completed Veteran II: "
	L.DTAddon_CGChal		= "Group Challenge Skillpoint"
	L.DTAddon_CDBoss		= "All Bosses Defeated: "
	L.DTAddon_Unlock		= "Unlocks at Level: "
	L.DTAddon_True			= "True"
	L.DTAddon_False			= "False"
	L.DTAddon_None			= "None"
	L.DTAddon_MQOPT1		= "All Characters"
	L.DTAddon_MQOPT2		= "Current Character"
	L.DTAddon_MQOPT3		= "Do Not Display"
	L.DTAddon_CTOPT1		= "Show both"
	L.DTAddon_CTOPT2		= "Only completed"
	L.DTAddon_CTOPT3		= "Only incomplete"
	L.DTAddon_QComp			= "Quest Complete: "
	L.DTAddon_QCompI		= "Quest I Complete: "
	L.DTAddon_QCompII		= "Quest II Complete: "
	L.DTAddon_AWide			= " (Account-Wide)"
	L.DTAddon_QMQ			= "Select Incomplete Quests"
	L.DTAddon_QMQTip		= "Select dungeons for which the current character has not yet completed the skill point quest."
	L.DTAddon_QMQVTip		= "If checked, the veteran version of dungeons is selected to complete skill point quests (not recommended).\n\n|cffffffNOTE|r: The skill point quest is the same in Normal and Veteran mode and can only be completed once."

-- Account Options
	L.DTAddon_SHMComp		= "Show Hard Mode Completion"
	L.DTAddon_SHMCompD		= "Show an icon if you have completed the selected veteran dungeon or trial Hard Mode achievement."
	L.DTAddon_STTComp		= "Show Time Trial Completion"
	L.DTAddon_STTCompD		= "Show an icon if you have completed the selected veteran dungeon or trial Timed achievement."
	L.DTAddon_SNDComp		= "Show No Death Completion"
	L.DTAddon_SNDCompD		= "Show an icon if you have completed the selected veteran dungeon or trial No Death achievement."
	L.DTAddon_SGFComp		= "Group Dungeon Faction Completion"
	L.DTAddon_SGFCompD		= "Show current progress towards completing all group dungeons in the Faction of the highlighted dungeon."
	L.DTAddon_SLFGt			= "LFG: Show Dungeon Completion"
	L.DTAddon_SLFGtD		= "Show achievement information in the Group Finder tooltip."
	L.DTAddon_SLFGd			= "LFG: Show Dungeon Description"
	L.DTAddon_SLFGdD		= "Display the game's description of the dungeon on the LFG tooltips. This is normally hidden."
	L.DTAddon_SNComp		= "MAP: Normal Group Dungeon Completion"
	L.DTAddon_SNCompD		= "Show if you have completed the dungeon or trial on Normal mode in the tooltip."
	L.DTAddon_SVComp		= "MAP: Veteran Group Dungeon Completion"
	L.DTAddon_SVCompD		= "Show if you have completed the dungeon or trial on Veteran mode in the tooltip."
	L.DTAddon_SGCCompM		= "MAP: "
	L.DTAddon_SGCComp		= "Public Dungeon Skillpoint"
	L.DTAddon_SGCCompD		= "Show if your current character has completed the public dungeon skillpoint Group Challenge in the tooltip."
	L.DTAddon_SDBComp		= "MAP: Public Dungeon Boss Completion"
	L.DTAddon_SDBCompD		= "Show if you have defeated all a public dungeon's Bosses in the tooltip."
	L.DTAddon_SDFComp		= "MAP: Public Dungeon Faction Completion"
	L.DTAddon_SDFCompD		= "Show current progress towards completing all public dungeons in the faction achievement."
	L.DTAddon_CNColor		= "Completed Color:"
	L.DTAddon_CNColorD		= "Select color for completion status or the names of characters that have completed the dungeon skillpoint quest."
	L.DTAddon_NNColor		= "Incomplete Color:"
	L.DTAddon_NNColorD		= "Select color for completion status or the names of characters that have NOT completed the dungeon skillpoint quest."
	L.DTAddon_QCompHead		= "Dungeon Quest Completion"
	L.DTAddon_QCompS		= "Show Dungeon Quests"
	L.DTAddon_QCompSD		= "Choose whether to show dungeon quest completion status. Select whether to show all character status or only current.\n\nNOTE: You will need to log in to each character at least once for them to show in the list of all characters."
	L.DTAddon_CTDROPDOWN	= "Format for completion text"
	L.DTAddon_CTDROPDOWND	= "If showing all characters, choose whether to display only those who have completed the dungeon skillpoint quest, only those who have not, or both (default)."
	L.DTAddon_ALPHAN		= "Alphabetize Name List"
	L.DTAddon_ALPHAND		= "When enabled the tooltip completion lists will be alphabetized. Otherwise the list order matches the order of your characters' creation."
	L.DTAddon_CHighlight	= "Highlight Current Character"
	L.DTAddon_CHighlightD	= "Show an asterisk (*) and use the current character achievement color to highlight dungeon quest completion for your current logged in character when showing the list."
	L.DTAddon_HColor		= "Current Character Color"
	L.DTAddon_HColorD		= "Change the color for highlighting your current character in the list of names for dungeon quest completion."

-- Character Tracking
	L.DTAddon_CharTracking	= "Character Tracking"
	L.DTAddon_TrackChar		= "Track Current Character"
	L.DTAddon_TrackCharD	= "Include the current logged in character in Quest Completion summary when "..L.DTAddon_QCompS.." is set to "..L.DTAddon_MQOPT1..". Re-enable while logged in to re-add them."
	L.DTAddon_TrackWarn		= "WARNING: Will automatically reload the UI!"


------------------------------------------------------------------------------------------------------------------

function DTAddon:GetLanguage() -- default locale, will be the return unless overwritten
	return L
end
