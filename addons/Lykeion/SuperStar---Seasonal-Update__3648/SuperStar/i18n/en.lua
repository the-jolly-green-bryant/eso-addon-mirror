--[[
Author: Ayantir
Updated by Armodeniz, Lykeion
Filename: en.lua
Version: 6.0.0
]]--

local strings = {

	SI_BINDING_NAME_SUPERSTAR_SHOW_PANEL			= "Toggle SuperStar",
-- Scene Titles:
	SUPERSTAR_IMPORT_MENU_TITLE				= "Import",
	SUPERSTAR_FAVORITES_MENU_TITLE				= "Favorites",
	SUPERSTAR_RESPEC_MENU_TITLE				= "Respec",
	SUPERSTAR_SCRIBING_MENU_TITLE				= "Scribing Simulator",

-- Main Scene:
	SUPERSTAR_XML_SKILLPOINTS				= "Skill Points",
	SUPERSTAR_XML_CHAMPIONPOINTS				= "Champion Points",

	SUPERSTAR_XML_BUTTON_SHARE				= "Share SuperStar (/sss)",
	SUPERSTAR_XML_BUTTON_SHARE_LINK				= "Share with In-game Links (/ssl)",

	SUPERSTAR_XML_DMG					= "Dmg",
	SUPERSTAR_XML_CRIT					= "Crit / %",
	SUPERSTAR_XML_PENE					= "Penetration",
	SUPERSTAR_XML_RESIST					= "Resist / %",

	SUPERSTAR_EQUIP_SET_BONUS			        = "Set",

-- Skills Scene:
	SUPERSTAR_XML_SKILL_BUILD				= "Skill Builder",
	SUPERSTAR_XML_SKILL_BUILD_EXPLAIN				= "Choose your race here to start your skill build. You can save the build as a Template for future respecs.\n\nFully supports Subclassing! You can freely add any class skill lines to your Skill Build, and SuperStar will automatically detect and apply all available class skills during respec.",

	SUPERSTAR_SCENE_SKILL_RACE_LABEL			= "Race",

	SUPERSTAR_XML_BUTTON_START				= "Start",

	SUPERSTAR_XML_BUTTON_FAV				= "Favorite",
	SUPERSTAR_XML_BUTTON_FAV_WITH_CP				= "Save with CP",
	SUPERSTAR_XML_BUTTON_REINIT				= "Reset",

-- Import Scene:
	SUPERSTAR_XML_IMPORT_EXPLAIN				= "Import others builds with this form.\n\nBuilds can contain Champion points, Skill points and Attributes.",

	SUPERSTAR_IMPORT_MYBUILD				= "My Build",

	SUPERSTAR_IMPORT_ATTR_DISABLED				= "Incl. Attributes",
	SUPERSTAR_IMPORT_ATTR_ENABLED				= "Rem. Attributes",
	SUPERSTAR_IMPORT_SP_DISABLED				= "Incl. Skill Points",
	SUPERSTAR_IMPORT_SP_ENABLED				= "Rem. Skill Points",
	SUPERSTAR_IMPORT_CP_DISABLED				= "Incl. Champion Points",
	SUPERSTAR_IMPORT_CP_ENABLED				= "Rem. Champion Points",
	SUPERSTAR_IMPORT_BUILD_OK				= "See Skills of this Build",
	SUPERSTAR_IMPORT_BUILD_NO_SKILLS			= "This Build don't have skills set",
	SUPERSTAR_IMPORT_BUILD_NOK				= "Build Incorrect, Check your Hash",
	SUPERSTAR_IMPORT_BUILD_LABEL				= "Import a build : paste the hash",

-- Favorite Scene:
	SUPERSTAR_XML_FAVORITES_EXPLAIN				= "You can use saved templates to respec automatically. It is recommended to save a base build in the Armory in advance so you can apply different templates as needed. \n\nPlease note that if the respec includes Champion Points it will cost gold",

	SUPERSTAR_XML_FAVORITES_HEADER_NAME			= "Name",
	SUPERSTAR_XML_FAVORITES_HEADER_CP			= "CP",
	SUPERSTAR_XML_FAVORITES_HEADER_SP				= "SP",
	SUPERSTAR_XML_FAVORITES_HEADER_ATTR			= "Attr",

	SUPERSTAR_VIEWFAV					= "View Skills",
	SUPERSTAR_RESPECFAV_SP					= "Respec Skills",
	SUPERSTAR_RESPECFAV_CP					= "Respec Champion Points",
	SUPERSTAR_VIEWHASH					= "View Favorite",
	SUPERSTAR_REMFAV					= "Delete Favorite",
	SUPERSTAR_UPDATEHASH					= "Update Favorite",

-- Respec Scene:
	SUPERSTAR_RESPEC_SPTITLE				= "You are about to Respec your |cFF0000skills|r with the template :\n\n <<1>>",
	SUPERSTAR_RESPEC_CPTITLE				= "You are about to Respec your |cFF0000champion points|r with the template :\n\n <<1>>",

	SUPERSTAR_RESPEC_SKILLLINES_MISSING			= "Warning: Following Skill Lines are not unlocked so they can't be set",
	SUPERSTAR_RESPEC_CPREQUIRED				= "This template will set <<1>> Champions Points",

	SUPERSTAR_XML_BUTTON_RESPEC				= "Respec",

	SUPERSTAR_RESPEC_ERROR1					= "Cannot respec skill points, Invalid Class",
	SUPERSTAR_RESPEC_ERROR2					= "Warning: Current skill points are less than template's requirements. Respec may be incomplete",
	SUPERSTAR_RESPEC_ERROR3					= "Warning: The defined race in this build isn't yours, racial points won't be set",
	SUPERSTAR_RESPEC_ERROR5					= "Cannot respec Champion Points, You're not a Champion",
	SUPERSTAR_RESPEC_ERROR6					= "Cannot respec Champion Points, Not enought Champion Points",

	SUPERSTAR_RESPEC_INPROGRESS1				= "Class skills set",
	SUPERSTAR_RESPEC_INPROGRESS2				= "Weapon skills set",
	SUPERSTAR_RESPEC_INPROGRESS3				= "Armor skills set",
	SUPERSTAR_RESPEC_INPROGRESS4				= "World skills set",
	SUPERSTAR_RESPEC_INPROGRESS5				= "Guilds skills set",
	SUPERSTAR_RESPEC_INPROGRESS6				= "Alliance War skills set",
	SUPERSTAR_RESPEC_INPROGRESS7				= "Racial skills set",
	SUPERSTAR_RESPEC_INPROGRESS8				= "Tradeskills set",

	SUPERSTAR_CSA_RESPECDONE_TITLE				= "Respec Completed",
	SUPERSTAR_CSA_RESPECDONE_POINTS				= "<<1>> skills set",
	SUPERSTAR_CSA_RESPEC_INPROGRESS				= "Respec in Progress",
	SUPERSTAR_CSA_RESPEC_TIME				= "This operation should take approximately <<1>> <<1[minutes/minute/minutes]>>",

-- Companion Scene:
    SUPERSTAR_XML_NO_COMPANION                              = "No Active Companion",
-- Scribing Scene:
-- Dialogs:
	SUPERSTAR_SAVEFAV					= "Save Favorite",
	SUPERSTAR_FAVNAME					= "Favorite Name",

	SUPERSTAR_DIALOG_SPRESPEC_TITLE				= "Set skill points",
	SUPERSTAR_DIALOG_SPRESPEC_TEXT				= "Set skill points according to the template selected ?",

	SUPERSTAR_DIALOG_REINIT_SKB_ATTR_CP_TITLE		= "Reset SkillBuilder",
	SUPERSTAR_DIALOG_REINIT_SKB_ATTR_CP_TEXT		= "You are about to reset Skill Builder which contains Attributes and/or Champion Points.\n\nIt will also reset those values.\n\nIf you want to reset a skill, simply right-click on its icon",

	SUPERSTAR_DIALOG_CPRESPEC_NOCOST_TEXT			= "You are about to respec your Champion Points.\n\nThis change will be free of charge",

	
	SUPERSTAR_QUEUE_SCRIBING						= "Queue for Scribing",
	SUPERSTAR_CLEAR_QUEUE							= "Clear Queue",

	SUPERSTAR_DIALOG_QUEUE_REJECTED_TITLE			= "Queue Rejected",
	SUPERSTAR_DIALOG_QUEUE_REJECTED_TEXT			= "Queued skill will be auto crafted the next time you use Scribing Altar\nOlder skills queued would be overwritten by newer skills using the same Grimoire\n\nSome of current picked skills are not yet unlocked, you can't add them to the Scribing queue",
	SUPERSTAR_DIALOG_QUEUE_FOR_SCRIBING_TEXT		= "Queued skill will be auto crafted the next time you use Scribing Altar\nOlder skills queued would be overwritten by newer skills using the same Grimoire\n\nYou are about to queue your current picked skills to be crafted",
	SUPERSTAR_DIALOG_CLEAR_QUEUE_TEXT		        = "You are about to clear the skills that have been added to the Scribing queue\n\nNo skill will be auto crafted the next time you use Scribing Altar",
	SUPERSTAR_DIALOG_MAJOR_UPDATE_TEXT              = "SuperStar has been updated for Update 50!\n\nThe addon now supports <<1>> display.\nThe SuperStar share link feature has also been rewritten. It is now more stable and ready for the upcoming class reworks.",

-- Chatbox Info:
	SUPERSTAR_CHATBOX_PRINT			        		= "Click to view",
	SUPERSTAR_CHATBOX_QUEUE_INFO			        = "|c215895[Super|cCC922FStar]|r <<1>> skills in the queue, <<2>> Ink expected to be consumed, owning <<3>>",
	SUPERSTAR_CHATBOX_QUEUE_WARN			        = "|c215895[Super|cCC922FStar]|r <<1>> skills in the queue, <<2>> Ink expected to be consumed, owning <<3>>",
	SUPERSTAR_CHATBOX_QUEUE_ABORTED		            = "|c215895[Super|cCC922FStar]|r Auto Scribing was aborted due to interruption. The queue has been emptied",
	SUPERSTAR_CHATBOX_QUEUE_CANCELED		        = "|c215895[Super|cCC922FStar]|r Auto Scribing has been canceled due to lack of Ink. Need <<1>>, owning <<2>>",
	SUPERSTAR_CHATBOX_TEMPLATE_OUTDATED		        = "|c215895[Super|cCC922FStar]|r Template is outdated, please recreate it",
	SUPERSTAR_CHATBOX_SUPERSTAR_OUTDATED		    = "|c215895[Super|cCC922FStar]|r Failed to parse the SuperStar link. You or the other party may not be using the latest version of SuperStar, or some characters in the link have been blocked by the chat censor system",

--[[
	SUPERSTAR_XML_CUSTOMIZABLE				= "Customizable",
	SUPERSTAR_XML_GRANTED							= "Granted",
	SUPERSTAR_XML_TOTAL									= "Total",
	SUPERSTAR_XML_BUTTON_EXPORT						= "Export",
	SUPERSTAR_XML_NEWBUILD								= "New build :",
        ]]

	SUPERSTAR_DESC_ENCHANT_MAX							= " Maximum",

	SUPERSTAR_DESC_ENCHANT_SEC							= " seconds",
	SUPERSTAR_DESC_ENCHANT_SEC_SHORT					= " secs",

	SUPERSTAR_DESC_ENCHANT_MAGICKA_DMG				= "Magic Damage",
	SUPERSTAR_DESC_ENCHANT_MAGICKA_DMG_SHORT		= "Magic Dmg",

	SUPERSTAR_DESC_ENCHANT_BASH						= "bash",
	SUPERSTAR_DESC_ENCHANT_BASH_SHORT				= "bash",

	SUPERSTAR_DESC_ENCHANT_REDUCE						= " and reduce",
	SUPERSTAR_DESC_ENCHANT_REDUCE_SHORT				= " and",

}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
