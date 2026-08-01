-- ----------------------------------------------
-- TTMP: Merge Asset Files
-- Author:			SirAndy
-- Last Updated:	2021/06/03
-- Contact:			http://thesidekickorder.com/bbs2/index.php
--
-- NOTE:
-- Best viewed with TABs set to 4
-- TODO items are marked with $$$
-- ----------------------------------------------

TTMPMerge = {}
TTMPMerge.DisplayVersion	= "3.5.0"
TTMPMerge.Author			= "SirAndy"
TTMPMerge.SaveVersion		= 1
TTMPMerge.SavedVars			= {}
TTMPMerge.isActive			= false
TTMPMerge.isLoading			= true
TTMPMerge.sCurChar			= "Player"


-- ----------------------------------------------
-- GLOBAL constants
-- ----------------------------------------------
TTMPM_COL_WHITE			= ZO_ColorDef:New("FFFFFF")
TTMPM_COL_RED			= ZO_ColorDef:New("FF0000")
TTMPM_COL_GREEN			= ZO_ColorDef:New("00FF00")
TTMPM_COL_BLUE			= ZO_ColorDef:New("0000FF")
TTMPM_COL_LIGHT_BLUE	= ZO_ColorDef:New("828EFD")
TTMPM_COL_MAGENTA		= ZO_ColorDef:New("FF0088")
TTMPM_COL_YELLOW		= ZO_ColorDef:New("F0C300")

-- ----------------------------------------------
-- GLOBAL variables, declared local for speed
-- ----------------------------------------------
local TTMPM_CHAT_PREFIX = "|cF0C300TTMPMerge: |r"


-- ----------------------------------------------
-- Print an info String to the console
-- ----------------------------------------------
local function TTMPM_InfPrint(s)

	-- $$$ Check for the pChat AddOn
	-- If present, do *NOT* use nested chat color coding, otherwise ESO will crash and burn!
	if (not pChat) then
		d(TTMPM_COL_LIGHT_BLUE:Colorize(s))
	else
		d(s)
	end
end

-- ----------------------------------------------
-- OnLoad()
-- ----------------------------------------------
function TTMPMerge.OnLoad(eventCode, addOnName)

	if addOnName ~= "TTMPMerge" then return end
	EVENT_MANAGER:UnregisterForEvent("TTMPMerge_StartUp", EVENT_ADD_ON_LOADED)
	TTMPMerge.isLoading = true

	local defaults = {}

	-- This ensures that our SavedVariables data tree is created if it doesn't already exists.
	TTMPMerge.SavedVars["merge_info"] = ZO_SavedVars:NewAccountWide("TTMPMerge_Vars", TTMPMerge.SaveVersion, "merge_info", defaults)

	TTMPMerge.sCurChar = GetUnitName("player")
	
	EVENT_MANAGER:RegisterForEvent("TMMPM_PlayerActivated", EVENT_PLAYER_ACTIVATED, TTMPMerge.OnPlayerActivated)
	
	TTMPMerge.isLoading = false
end

-- ----------------------------------------------
-- OnPlayerActivated()
-- ----------------------------------------------
function TTMPMerge.OnPlayerActivated(eventCode)

	if (TTMPMerge.isLoading or TTMPMerge.isActive) then return end
	TTMPMerge.isActive = true

	-- Say hello ...
	TTMPM_InfPrint(string.format(
		"%sAddOn loaded for |cFF0088%s|r",
		TTMPM_CHAT_PREFIX,
		TTMPMerge.sCurChar
	))
end

-- ----------------------------------------------
-- Initial Event Manager Hooks
-- ----------------------------------------------
EVENT_MANAGER:RegisterForEvent("TTMPMerge_StartUp", EVENT_ADD_ON_LOADED, TTMPMerge.OnLoad)
