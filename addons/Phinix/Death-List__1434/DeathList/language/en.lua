local DLAddon = _G['DLAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- English
------------------------------------------------------------------------------------------------------------------

-- General strings
	L.DLAddon_UnitAdded			= "added to the Death List."
	L.DLAddon_ToAddPlayers		= "Must enable option to add players to the Death List."
	L.DLAddon_NotAttackable		= "Target not attackable."
	L.DLAddon_NoGuards			= "Cannot add invulnerable guards to the Death List."
	L.DLAddon_ListCleared		= "All Death List targets cleared."
	L.DLAddon_ListEmpty			= "There are no names on your Death List."
	L.DLAddon_Removed			= "was removed from your Death List."
	L.DLAddon_NoExist			= "Target does not exist in your Death List."

-- Settings panel
	L.DLAddon_ShowMarker		= "Show Marking Character"
	L.DLAddon_ShowMarkerTip		= "Display the name of the character which added the target to the Death List."
	L.DLAddon_MarkPlayers		= "Allow Marking Players"
	L.DLAddon_MarkPlayersTip	= "Allows you to add other players to the Death List."
	L.DLAddon_ShowDebug			= "Show Debug"
	L.DLAddon_ShowDebugTip		= "Shows chat notifications when performing Death List functions."
	L.DLAddon_MarkColor			= "Choose Icon Color"
	L.DLAddon_MarkColorTip		= "Set the color for the Death List marked target icon."
	L.DLAddon_TextColor			= "Choose Text Color"
	L.DLAddon_TextColorTip		= "Set the color for the name of the character that added target to the Death List."
	L.DLAddon_MarkSize			= "Choose Icon Size"
	L.DLAddon_MarkSizeTip		= "Set the size of the Death List marked target icon."
	L.DLAddon_ChatCommants		= "Chat Commands"
	L.DLAddon_PrintList			= "Prints the contents of your Death List."
	L.DLAddon_RemoveName		= "Remove specified name from the Death List (no quotes)."
	L.DLAddon_ClearList			= "Clear all targets from your Death List."
	L.DLAddon_Name				= "Name"


------------------------------------------------------------------------------------------------------------------

function DLAddon:GetLanguage() -- default locale, will be the return unless overwritten
	return L
end
