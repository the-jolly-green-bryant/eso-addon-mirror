local EZReport = _G['EZReport']
local L = {}

------------------------------------------------------------------------------------------------------------------------------------
-- English
------------------------------------------------------------------------------------------------------------------------------------

-- Addon Setting Labels
L.EZReport_GOpts				= "Global Options"L.EZReport_TIcon				= "Show Target Reported Icon"L.EZReport_DTime				= "Show Target Reported Time"L.EZReport_RCooldown			= "Reporting Cooldown"L.EZReport_RCooldownM			= "EZReport already reported today: Reporting Cooldown is enabled."L.EZReport_OutputChat			= "Show Chat Messages"L.EZReport_12HourFormat			= "12 Hour Time Format"L.EZReport_IncPrev				= "Include Previous Report Data"L.EZReport_DCategory			= "Default Category"L.EZReport_DReason				= "Default Reason"L.EZReport_Reset				= "Reset Report History"L.EZReport_Clear				= "CLEAR"

-- Target Reported Colors
L.EZReport_RColorS				= "Target Reported Colors"L.EZReport_RColor1				= "Generic Color"L.EZReport_RColor2				= "Bad Name Color"L.EZReport_RColor3				= "Toxic Color"L.EZReport_RColor4				= "Cheating Color"L.EZReport_RColor5				= "Alt Reported Color"

-- Addon Setting Tooltips
L.EZReport_TIconT				= "Show an icon indicating targets you have previously reported. Matches the icons seen when choosing a category at the report window."L.EZReport_DTimeT				= "Show the time a target was last reported next to the Target Reported Icon. If the current character was never reported, shows the most recent time any character on their account was reported."L.EZReport_RCooldownT			= "When enabled, prevents hotkey reporting if you have already reported the target today. Helpful when reporting large groups of bots so you can spam the keybind and the report system will only activate when you have a target you haven't reported yet."L.EZReport_OutputChatT			= "Displays informative messages related to various addon functions in chat."L.EZReport_12HourFormatT		= "When enabled, generated timestamps will use 12 hour time format (hour plus AM or PM). Turning this off will display 'military time' 24 hour format."L.EZReport_IncPrevT				= "Includes date, time, and name data about previous reports of this character or known alts when sending a report."L.EZReport_DCategoryT			= "Choose the default subcategory to automatically select when opening the report window."L.EZReport_DReasonT				= "Include the selected reason in the custom details section of the reporting window. Manual(default) option is to leave this blank for you to type it manually."L.EZReport_ResetT				= "Clear the entire database of previously reported characters & accounts."L.EZReport_ResetM				= "EZReport database has been reset."

-- Category List
L.EZReport_CatList1				= "Bad Name"L.EZReport_CatList2				= "Harassment"L.EZReport_CatList3				= "Cheating"L.EZReport_CatList4				= "Other"L.EZReport_CatList5				= "None (default)"

-- Reason List
L.EZReport_ReasonList1			= "Botting"L.EZReport_ReasonList2			= "Exploiting"L.EZReport_ReasonList3			= "Harassment"L.EZReport_ReasonList4			= "Manual (default)"

-- Chat List
L.EZReport_CReason1				= "Generic Report"L.EZReport_CReason2				= "Bad Name"L.EZReport_CReason3				= "Toxic Behavior"L.EZReport_CReason4				= "Cheating"

-- Chat Strings
L.EZReport_RepT					= "Reported:"L.EZReport_RepC					= "Reported character:"L.EZReport_Unkn					= "unknown account"L.EZReport_Now					= "now:"L.EZReport_Char					= "character:"L.EZReport_For					= "for:"L.EZReport_NoMatch				= "No matches found."

-- Info Panel
L.EZReport_RAcct				= "Report Account: "L.EZReport_RAlts				= "Previously Reported Alts: "

-- General Strings
L.EZReport_RLast				= "Report Last Player Target"L.EZReport_RHistory				= "Target Report History"L.EZReport_ROpen				= "Open Main Window"L.EZReport_Reason				= "Reason (optional):"L.EZReport_CName				= "Character Name:"L.EZReport_AName				= "Account Name:"L.EZReport_MLoc					= "Map:"L.EZReport_Coords				= "Coords:"L.EZReport_Time					= "Date/Time:"L.EZReport_CButton				= "Clear"L.EZReport_Today				= "Today"L.EZReport_Updated				= "EZReport database has been updated."L.EZReport_AccUnavail			= "Account Unavailable"L.EZReport_LocUnavail			= "Location Unavailable"L.EZReport_Wayshrine			= "Wayshrine"L.EZReport_Accounts				= "Reports by Account"L.EZReport_Characters			= "Reports by Character"L.EZReport_Locations			= "Reports by Location"L.EZReport_Generated			= "Generated: EZReport by Phinix"L.EZReport_Previous				= "Previously Reported:"L.EZReport_Confirm				= "Confirm Delete"L.EZReport_Cancel				= "Cancel"L.EZReport_Delete				= "Delete"

-- Tooltip strings
L.EZReport_TTShow				= "Click to show report summary."L.EZReport_TTClick				= "Click in result field and press:"L.EZReport_TTSelect1			= "Ctrl+A"L.EZReport_TTSelect2			= " to select all."L.EZReport_TTCopy1				= "Ctrl+C"L.EZReport_TTCopy2				= " to copy."L.EZReport_TTPaste1				= "Ctrl+V"L.EZReport_TTPaste2				= " to paste elsewhere."L.EZReport_TTAccounts			= "Switch to showing accounts."L.EZReport_TTCharacters			= "Switch to showing characters."L.EZReport_TTEMode				= "Switch to database edit mode."L.EZReport_TTRMode				= "Switch to text report mode."L.EZReport_TTCEntry1			= "Left-click"L.EZReport_TTCEntry2			= " to show character entries."L.EZReport_TTAEntry1			= "Shift+Left-click"L.EZReport_TTAEntry2			= " to show account entries."L.EZReport_TTDEntry1			= "Right-click"L.EZReport_TTDEntry2			= " to delete selected entry."


------------------------------------------------------------------------------------------------------------------------------------

function EZReport:GetLanguage() -- default locale, will be the return unless overwritten
	return L
end
