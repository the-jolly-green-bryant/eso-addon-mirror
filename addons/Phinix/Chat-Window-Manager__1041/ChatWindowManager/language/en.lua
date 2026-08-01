local CWMAddon = _G['CWMAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- English
------------------------------------------------------------------------------------------------------------------

-- General strings
	L.CWMAddon_Reload			= "Reload UI"
	L.CWMAddon_Clear			= "Clear Chat"
	L.CWMAddon_ClearT			= "Clear current chat window."
	L.CWMAddon_Toggle			= "Toggle Chat Window"
	L.CWMAddon_Online			= "Toggle Online Status"
	L.CWMAddon_RBox				= "Do you want to reload the UI?"

-- Settings panel
	L.CWMAddon_Title			= "Chat Window Manager"
	L.CWMAddon_AutoHide			= "Auto-Hide Chat Window"
	L.CWMAddon_AutoHideT		= "Minimizes the chat window when logging in, changing zones, or reloading the UI."
	L.CWMAddon_RemState			= "Remember Chat State"
	L.CWMAddon_RemStateT		= "Overrides next option by maintaining the previous chat state between loading screens."
	L.CWMAddon_RButton			= "Add Reload/Clear Button"
	L.CWMAddon_RButtonT			= "Adds a button to the chat window to reload the UI, or shift-click to clear the current chat."
	L.CWMAddon_ROffset			= "Reload Button Offset"
	L.CWMAddon_ROffsetT			= "Change the horizontal position of the reload button when chat is maximized (for compatibility with other addons)."
	L.CWMAddon_RConfirm			= "Confirm Reload UI"
	L.CWMAddon_RConfirmT		= "Adds a confirmation box when clicking the Reload UI button to avoid accidental reloads."
	L.CWMAddon_SButton			= "Add Player Status Menu"
	L.CWMAddon_SButtonT			= "Adds the player online status selection menu to the chat window."
	L.CWMAddon_SChat			= "Status Toggle in Chat"
	L.CWMAddon_SChatT			= "Show player online status in chat when changed by keybind or other method."
	L.CWMAddon_SOffset			= "Status Offset"
	L.CWMAddon_SOffsetT			= "Change the horizontal position of the online status indicator when chat is maximized (for compatibility with other addons)."
	L.CWMAddon_Extras			= "Extra Options"
	L.CWMAddon_DConfirm			= "Simple Delete Confirm"
	L.CWMAddon_DConfirmT		= "Eliminates needing to type 'DELETE' when deleting certain things. You will instead get a box to click Yes or No."
	L.CWMAddon_HideFriend		= "Hide Friend Login & Logout"
	L.CWMAddon_HideFriendT		= "Prevent friend login & logout status messages from appearing in chat."
	L.CWMAddon_TutorialOff		= "Disable Tutorials"
	L.CWMAddon_TutorialOffT		= "Automatically disable popup tutorials on login (and when enabling this option). Can be re-enabled from Gameplay settings."

------------------------------------------------------------------------------------------------------------------

function CWMAddon:GetLanguage() -- default locale, will be the return unless overwritten
	return L
end
