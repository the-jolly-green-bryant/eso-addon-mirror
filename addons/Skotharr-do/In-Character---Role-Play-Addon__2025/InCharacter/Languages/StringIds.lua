--[[
Title:   StringID Registration, Default Translation
Info:    Default implementation; English
         Do not change or take as template!
         To translate for other languages, use en.lua as template file.
         Options for formatting <<n>> entries, see http://wiki.esoui.com/How_to_format_strings_with_zo_strformat
Version: 1.1.3
Author:  @Skotharr-do [PC/EU]
--]]

local function RegisterLocalizedStrings()
	local Strings = {
		-- Keybindings
		SI_BINDING_NAME_INCHARACTER_EDIT_WINDOW_TOGGLE =			"Toggle Edit Window",
		SI_BINDING_NAME_INCHARACTER_RETICLE_WINDOW_TOGGLE =			"Toggle Character Popup",
		SI_BINDING_NAME_INCHARACTER_CURRENT_DESCRIPTION_TO_CHAT =	"Current Description to Chat",
		SI_BINDING_NAME_INCHARACTER_DESCRIPTION_0_TO_CHAT =			"Description 'Key 1' to Chat",
		SI_BINDING_NAME_INCHARACTER_DESCRIPTION_1_TO_CHAT =			"Description 'Key 2' to Chat",
		SI_BINDING_NAME_INCHARACTER_DESCRIPTION_2_TO_CHAT =			"Description 'Key 3' to Chat",
		SI_BINDING_NAME_INCHARACTER_DESCRIPTION_3_TO_CHAT =			"Description 'Key 4' to Chat",
		SI_BINDING_NAME_INCHARACTER_DESCRIPTION_4_TO_CHAT =			"Description 'Key 5' to Chat",
		SI_BINDING_NAME_INCHARACTER_DESCRIPTION_5_TO_CHAT =			"Description 'Key 6' to Chat",
		SI_BINDING_NAME_INCHARACTER_DESCRIPTION_6_TO_CHAT =			"Description 'Key 7' to Chat",
		SI_BINDING_NAME_INCHARACTER_DESCRIPTION_7_TO_CHAT =			"Description 'Key 8' to Chat",
		SI_BINDING_NAME_INCHARACTER_DESCRIPTION_8_TO_CHAT =			"Description 'Key 9' to Chat",
		SI_BINDING_NAME_INCHARACTER_DESCRIPTION_9_TO_CHAT =			"Description 'Key 10' to Chat",

		-- UI Texts
		SI_INCHARACTER_UI_ADDON_MENU_NAME =									"In-Character",
		SI_INCHARACTER_UI_ADDON_MENU_TITLE =								"In-Character - Role Play Addon",
		SI_INCHARACTER_UI_ADDON_MENU_BINDINGS_TITLE =						"Keybindings",
		SI_INCHARACTER_UI_ADDON_MENU_BINDINGS_TEXT =						"Keybindings for easy access of core functionality are provided in CONTROLS.",
		SI_INCHARACTER_UI_ADDON_MENU_RETICLE_TITLE =						"Character Popup",
		SI_INCHARACTER_UI_ADDON_MENU_RETICLE_AVAILABILITY =					"Enabled",
		SI_INCHARACTER_UI_ADDON_MENU_RETICLE_AVAILABILITY_TOOLTIP =			"When off, the character popup will never be displayed.",
		SI_INCHARACTER_UI_ADDON_MENU_RETICLE_VISIBILITY =					"Always visible",
		SI_INCHARACTER_UI_ADDON_MENU_RETICLE_VISIBILITY_TOOLTIP =			"When on, always display character popup. Else only displays if information is available.",
		SI_INCHARACTER_UI_ADDON_MENU_RETICLE_POSITIONING =					"Relative positioning",
		SI_INCHARACTER_UI_ADDON_MENU_RETICLE_POSITIONING_TOOLTIP =			"When the character popup content changes, the popup will keep its distance relative to the given screen border.",
		SI_INCHARACTER_UI_ADDON_MENU_RETICLE_POSITIONING_TOP =				"Top",
		SI_INCHARACTER_UI_ADDON_MENU_RETICLE_POSITIONING_BOTTOM =			"Bottom",
		SI_INCHARACTER_UI_ADDON_MENU_RETICLE_WIDTH =						"Width",
		SI_INCHARACTER_UI_ADDON_MENU_RETICLE_WIDTH_TOOLTIP =				"The width of the character popup. The height is automatically adjusted by the content size.",
		SI_INCHARACTER_UI_ADDON_MENU_RETICLE_ALPHA =						"Transparency in %",
		SI_INCHARACTER_UI_ADDON_MENU_RETICLE_ALPHA_TOOLTIP =				"Percentage of how transparent the character popup is being displayed.",
		SI_INCHARACTER_UI_ADDON_MENU_RETICLE_BACKGROUND_ALPHA =				"Background transparency in %",
		SI_INCHARACTER_UI_ADDON_MENU_RETICLE_BACKGROUND_ALPHA_TOOLTIP =		"Percentage of how transparent the character popup background is being displayed.",
		SI_INCHARACTER_UI_ADDON_MENU_RETICLE_TIMESTAMP_VISIBILITY =			"Timestamp visible",
		SI_INCHARACTER_UI_ADDON_MENU_RETICLE_TIMESTAMP_VISIBILITY_TOOLTIP =	"When on, displays the timestamp of when the character description was received.",
		SI_INCHARACTER_UI_ADDON_MENU_EDIT_TITLE =							"Edit Window",
		SI_INCHARACTER_UI_ADDON_MENU_EDIT_WIDTH =							"Width",
		SI_INCHARACTER_UI_ADDON_MENU_EDIT_WIDTH_TOOLTIP =					"The width of the edit window.",
		SI_INCHARACTER_UI_ADDON_MENU_EDIT_HEIGHT =							"Height",
		SI_INCHARACTER_UI_ADDON_MENU_EDIT_HEIGHT_TOOLTIP =					"The height of the edit window.",
		
		SI_INCHARACTER_UI_EDIT_WINDOW_TITLE =					"Character Description<<1>>", -- 1: Hints
		SI_INCHARACTER_UI_EDIT_WINDOW_TITLE_UNSAVED =			", unsaved changes",
		SI_INCHARACTER_UI_EDIT_WINDOW_TITLE_TOO_LONG =			", too long",
		SI_INCHARACTER_UI_EDIT_WINDOW_BUTTON_SAVE =				"Save",
		SI_INCHARACTER_UI_EDIT_WINDOW_BUTTON_SAVE_AND_COPY =	"Save & to Chat",
		SI_INCHARACTER_UI_EDIT_WINDOW_BUTTON_RESET =			"Reset",
		SI_INCHARACTER_UI_EDIT_WINDOW_BUTTON_ADD =				"Add...",
		SI_INCHARACTER_UI_EDIT_WINDOW_BUTTON_DELETE =			"Delete...",
		SI_INCHARACTER_UI_EDIT_WINDOW_BUTTON_RENAME =			"Rename...",
		SI_INCHARACTER_UI_EDIT_WINDOW_LABEL_ADD =				"Add new:",
		SI_INCHARACTER_UI_EDIT_WINDOW_LABEL_DELETE =			"Delete entry and its contents?",
		SI_INCHARACTER_UI_EDIT_WINDOW_LABEL_RENAME =			"Rename to:",
		SI_INCHARACTER_UI_EDIT_WINDOW_OUTFIT_LABEL =			"Bind to Outfit:",
		SI_INCHARACTER_UI_EDIT_WINDOW_OUTFIT_NOT_ASSIGNED =		"Not Assigned",
		SI_INCHARACTER_UI_EDIT_WINDOW_OUTFIT_SLOT_NO_OUTFIT =	"'No Outfit' Slot",
		SI_INCHARACTER_UI_EDIT_WINDOW_KEY_SLOT =				"Key <<1>>", -- 1: Key number
		SI_INCHARACTER_UI_EDIT_WINDOW_NO_KEY_SLOT =				"No Key",
		
		SI_INCHARACTER_UI_RETICLE_WINDOW_TITLE =		"<<1>>", -- 1: Character Name
		SI_INCHARACTER_UI_RETICLE_WINDOW_TEXT =			"<<1>>", -- 1: Character Description
		SI_INCHARACTER_UI_RETICLE_WINDOW_TIMESTAMP =	"[<<1>>]", -- 1: Timestamp of Character Description
		
		-- Command Messages
		SI_INCHARACTER_COMMAND_RETICLE_WINDOW_ENABLED =			"IC: Character Popup on",
		SI_INCHARACTER_COMMAND_RETICLE_WINDOW_DISABLED =		"IC: Character Popup off",
		SI_INCHARACTER_COMMAND_RETICLE_WINDOW_VISIBLE_ALWAYS =	"IC: Character Popup always visible",
		SI_INCHARACTER_COMMAND_RETICLE_WINDOW_VISIBLE_NORMAL =	"IC: Character Popup normal visible",
		SI_INCHARACTER_COMMAND_RETICLE_TIMESTAMP_VISIBLE =		"IC: Character Popup timestamp visible",
		SI_INCHARACTER_COMMAND_RETICLE_TIMESTAMP_HIDDEN =		"IC: Character Popup timestamp hidden",
		SI_INCHARACTER_COMMAND_RETICLE_WINDOW_ANCHOR_TOP =		"IC: Character Popup position relative to top",
		SI_INCHARACTER_COMMAND_RETICLE_WINDOW_ANCHOR_BOTTOM =	"IC: Character Popup position relative to bottom",
		SI_INCHARACTER_COMMAND_RETICLE_WINDOW_STATUS =			"IC: Character Popup status:\n - enabled: <<1>>\n - always visible: <<2>>", -- 1: Enabled, 2: Always Visible
		
		SI_INCHARACTER_COMMAND_LIST_NONE =				"none",
		SI_INCHARACTER_COMMAND_LIST_KNOWN_CHARACTERS =	"Known characters of <<1>>: <<2>>", -- 1: Account Name, 2: Character Names of Account
		SI_INCHARACTER_COMMAND_LIST_UNKNOWN_ACCOUNT =	"<<1>> belongs to an unknown account.", -- 1: Character Name
		SI_INCHARACTER_COMMAND_LIST_PARAMETER_EMPTY =	"<<1>> parameter must be a character or account name!", -- 1: Command Name
		
		SI_INCHARACTER_COMMAND_PRINT_CHARACTER_DESCRIPTION =	"<<1>>: <<2>> [<<3>>]",  -- 1: Character Name, 2: Character Description, 3: Timestamp of Character Description
		
		SI_INCHARACTER_COMMAND_HELP =	"In-Character - Role Play Addon: Command List".. -- Command Names
										"\n%s : print this list"..
										"\n%s : open addon settings"..
										"\n%s : open character description edit window"..
										"\n%s : enable or disable character popup"..
										"\n%s : only when available or always display character popup"..
										"\n%s : show or hide timestamp in character popup"..
										"\n%s : position character popup relative to top or bottom"..
										"\n%s : output if character popup is enabled and always visible"..
										"\n%s <Name> : list all characters of given Character Name or Account Name"..
										"\n%s <Character Name> : print character description of given Character Name to chat"..
										"\n%s (Optional: <Name/Key Number>) : insert either current character's description, or of given Name/Key Number to chat input",
		
		SI_INCHARACTER_COMMAND_UNKNOWN =	"Unknown command: <<1>>", -- 1: Command Name
		
		-- Read from Chat Messages
		SI_INCHARACTER_CHAT_GET_CHARACTER_NAME_FAILED =	"IC: Cannot obtain character name of sender <<1>>. Information will not be saved!", -- 1: Account Name
		
		-- General
		SI_INCHARACTER_GENERAL_DATE_FORMAT =	"%c", -- see https://www.lua.org/pil/22.1.html
		SI_INCHARACTER_GENERAL_YES =	"yes",
		SI_INCHARACTER_GENERAL_NO =		"no"
	}

	for stringId, stringValue in pairs(Strings) do
		ZO_CreateStringId(stringId, stringValue)
		SafeAddVersion(stringId, 1)
	end
end

-- Internationalization; registering string constants
RegisterLocalizedStrings()