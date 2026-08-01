local CE = CustomEmotes
local internal = CE.internal

local CONS = {}
internal.constants = CONS

-- Menu names
CONS.SUBMENU_SETTINGS_NAME = "Settings"
CONS.SUBMENU_EMOTES_NAME = "Emote list"
CONS.SUBMENU_EDITOR_NAME = "Emote editor"
CONS.SUBMENU_IMPORT_NAME = "Import"

-- Command settings
CONS.COMMAND_NAME = "Command"
CONS.COMMAND_TOOLTIP = "Set the command to use the addon."
CONS.COMMAND_WARNING = "Will need to reload the UI."

-- Create commands settings
CONS.CREATE_COMMANDS_NAME = "Create commands"
CONS.CREATE_COMMANDS_TOOLTIP = "Make CustomEmotes create a command per emote: /[CustomEmoteName]."
CONS.CREATE_COMMANDS_WARNING = "Will need to reload the UI to take effect."

-- Validate logic settings
CONS.VALIDATE_LOGIC_NAME = "Validate logic"
CONS.VALIDATE_LOGIC_TOOLTIP = "Prevent infinite loops or simultaneous emote commands."
CONS.VALIDATE_LOGIC_WARNING = "Disabling this will allow emotes with bad logic (e.g., infinite loops) and crash the game."

-- Delete all emotes button
CONS.DELETE_ALL_EMOTES_NAME = "Delete all emotes"
CONS.DELETE_ALL_EMOTES_WARNING = "Delete all emotes, this action cannot be undone."

-- Delete confirmation dialog
CONS.DELETE_CONFIRMATION_TITLE = "Confirmation"
CONS.DELETE_CONFIRMATION_TEXT = "Are you sure you want to delete <<1>>?"

-- Emote list description text
CONS.EMOTE_LIST_DESCRIPTION = "Here you can see all the emotes created."

-- Emote editor description text
CONS.EMOTE_LIST_EXPORT_TOOLTIP = "Export"
CONS.EMOTE_LIST_EDIT_TOOLTIP = "Edit"
CONS.EMOTE_LIST_DELETE_TOOLTIP = "Delete"

-- Interpreter error messages
CONS.INTERPRETER_CONSECUTIVE_EMOTES_ERROR = "Action <<1>>: Consecutive emotes without delay."
CONS.INTERPRETER_LOOP_DETECTED_ERROR = "Action <<1>>: Loop detected without delay."
CONS.INTERPRETER_INDEX_PERSONALITY_NOT_FOUND_ERROR = "Action <<1>>: Personality not found."
CONS.INTERPRETER_EMOTE_NOT_FOUND_ERROR = "[CustomEmotes] Emote <<1>> not found."
CONS.INTERPRETER_PERSONALITY_NOT_FOUND_ERROR = "[CustomEmotes] Personality <<1>> not found."
CONS.INTERPRETER_EMOTE_NO_NAME_ERROR = "The emote has no name."
CONS.INTERPRETER_EMOTE_NAME_INVALID_ERROR = "The emote name must contain only letters and numbers."
CONS.INTERPRETER_EMOTE_NO_DESCRIPTION_ERROR = "The emote has no description."
CONS.INTERPRETER_EMOTE_NO_ACTIONS_ERROR = "The emote has no actions."
CONS.INTERPRETER_EMOTE_ACTION_NOT_EXIST_ERROR = "Action <<1>>: Action #<<2>> doesn't exist."
CONS.INTERPRETER_EMOTE_ACTION_INVALID_ERROR = "Action <<1>>: Invalid action."
CONS.INTERPRETER_EMOTE_ACTION_TIME_ERROR = "Action <<1>>: Time must be greater than zero."
CONS.INTERPRETER_EMOTE_ACTION_LOCKED_ERROR = "Action <<1>>: Emote <<2>> locked."
CONS.INTERPRETER_EMOTE_ACTION_RESTART_ERROR = "The Restart action must be the last action."
CONS.INTERPRETER_EMOTE_ACTION_DATA_ERROR = "Action <<1>>: Error accessing the data."
CONS.INTERPRETER_EMOTE_ACTION_TIMES_ERROR = "Action <<1>>: Times must be greater than zero."
CONS.INTERPRETER_EMOTE_ACTION_INVALID_TYPE_ERROR = "Action <<1>>: Invalid action type."

-- Import messages
CONS.IMPORT_RESET_BUTTON_NAME = "Reset"
CONS.IMPORT_RESET_BUTTON_TOOLTIP = "Discard all changes."
CONS.IMPORT_RESET_BUTTON_WARNING = "Are you sure you want to discard all changes?"

CONS.IMPORT_DESCRIPTION_TEXT = "This tool allows you to import emotes from a text format,\n" ..
                               "it will add the emote to the list of emotes.\n" ..
                               "To export an emote, use the export button in the emote list."

CONS.IMPORT_EMOTE_NAME = "Emote name"
CONS.IMPORT_EMOTE_NAME_TOOLTIP = "Set the name of the emote, command:\n%s [name], or /[name]."

CONS.IMPORT_DESCRIPTION_NAME = "Description"
CONS.IMPORT_DESCRIPTION_TOOLTIP = "Set the description of the emote."

CONS.IMPORT_EMOTE_CODE_NAME = "Emote code"

CONS.IMPORT_BUTTON_NAME = "Import"
CONS.IMPORT_SUCCESS_MESSAGE = "Emote saved successfully!"
CONS.IMPORT_FAILURE_MESSAGE = "Invalid emote code."

-- Action captions
CONS.ACTION_PLAY_CAPTION = "Start emote:"
CONS.ACTION_WAIT_CAPTION = "Wait for:"
CONS.ACTION_JUMP_CAPTION = "Jump to:"
CONS.ACTION_JUMP_FIRST_CAPTION = "Restart"
CONS.ACTION_REPEAT_FROM_CAPTION = "Repeat from:"
CONS.ACTION_INTERRUPT_CAPTION = "Interrupt"
CONS.ACTION_PERSONALITY_CAPTION = "Personality:"
CONS.ACTION_EMPTY_LINE_CAPTION = "---------------------"
CONS.ACTION_MOVE_UP_CAPTION = "Move up"
CONS.ACTION_MOVE_DOWN_CAPTION = "Move down"
CONS.ACTION_DUPLICATE_CAPTION = "Duplicate action"
CONS.ACTION_DELETE_CAPTION = "Delete action"

-- No personality caption
CONS.NO_PERSONALITY = "No personality"

-- Editor error dialog messages
CONS.EDITOR_ERROR_DIALOG_TITLE = "Error(s) Detected"
CONS.EDITOR_ERROR_DIALOG_MAIN_TEXT = "The current emote has the following errors:\n"
CONS.EDITOR_ERROR_DIALOG_MORE_ERRORS = "and more... (%d)"

-- Editor duplicate dialog messages
CONS.EDITOR_DUPLICATE_DIALOG_TITLE = "Confirmation"
CONS.EDITOR_DUPLICATE_DIALOG_MAIN_TEXT = "An emote with the name <<1>> already exists. Do you want to overwrite it?"

-- Editor messages
CONS.EDITOR_PREVIEW_EMOTE_MESSAGE = "Previewing emote <<1>>..."
CONS.EDITOR_SAVE_EMOTE_SUCCESS_MESSAGE = "Emote saved successfully!"

-- Editor label texts
CONS.EDITOR_WAIT_LABEL_TEXT = "Milliseconds."
CONS.EDITOR_JUMP_LABEL_TEXT = "#) Action."
CONS.EDITOR_JUMP_FIRST_LABEL_TEXT = "Jump to first action."
CONS.EDITOR_REPEAT_FROM_LABEL_TEXT = "#) Action, do"
CONS.EDITOR_REPEAT_FROM_TIMES_LABEL_TEXT = "repetitions."
CONS.EDITOR_INTERRUPT_LABEL_TEXT = "Force:"
CONS.EDITOR_NO_ACTIONS_LABEL_TEXT = "No actions"

-- Editor UI elements
CONS.EDITOR_RESET_BUTTON_NAME = "Reset"
CONS.EDITOR_RESET_BUTTON_TOOLTIP = "Discard all changes."
CONS.EDITOR_RESET_BUTTON_WARNING = "Are you sure you want to discard all changes?"

CONS.EDITOR_EMOTE_NAME = "Emote name"
CONS.EDITOR_EMOTE_NAME_TOOLTIP = "Set the name of the emote, command:\n%s [name], or /[name]."

CONS.EDITOR_DESCRIPTION_NAME = "Description"
CONS.EDITOR_DESCRIPTION_TOOLTIP = "Set the description of the emote."

CONS.EDITOR_ADD_ACTION_BUTTON_NAME = "Add action"
CONS.EDITOR_ADD_ACTION_BUTTON_TOOLTIP = "Add a new action to the emote."

CONS.EDITOR_PREVIEW_BUTTON_NAME = "Preview"
CONS.EDITOR_PREVIEW_BUTTON_TOOLTIP = "Preview the emote."

CONS.EDITOR_SAVE_BUTTON_NAME = "Save"
CONS.EDITOR_SAVE_BUTTON_TOOLTIP = "Save the emote."

-- Reset saved vars button
CONS.RESET_SAVED_VARS_NAME = "Reset addon"
CONS.RESET_SAVED_VARS_WARNING = "This action will delete all emotes, preload default emotes, reset all settings, and reload the UI. Are you sure you want to proceed?"

-- Danger zone settings
CONS.DANGER_ZONE_TEXT = "These options are used to reset the addon to its default state."
CONS.DANGER_ZONE_CHECKBOX_NAME = "Activate buttons"
CONS.DANGER_ZONE_WARNING_CHECKBOX = "Do not activate this unless you know what you are doing."

-- Server kick prevention
CONS.PREVENT_SERVER_KICK_WARNING = "Turning this off may cause the server to kick you when using emotes too fast."
CONS.PREVENT_SERVER_KICK_NAME = "Server kick prevention"
CONS.PREVENT_SERVER_KICK_TOOLTIP = "Prevent the server from kicking you when using emotes too fast."
CONS.EMOTE_PREVENT_SERVER_KICK = "Too fast, stopping emote to prevent server kick."