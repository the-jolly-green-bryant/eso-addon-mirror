------------------------------------------------------------------
--NotACraftsman.lua
--Author: Martype
----------------------------------------------------------
--Check filename NOC_API.lua for global API functions!
----------------------------------------------------------
--[[
	
]]
------------------------------------------------------------------
--Global array with all data of this addon
if NOC == nil then NOC = {} end
local NOC = NOC

--===================== ADDON Info =============================================
--Addon variables
NOC.addonVars = {}
NOC.addonVars.addonVersionOptions 		= '0.0.1' -- version shown in the settings panel
NOC.addonVars.addonVersionOptionsNumber	= 0.01
NOC.addonVars.gAddonName				= "NotACraftsman"
NOC.addonVars.addonNameMenu				= "Not a Craftsman"
NOC.addonVars.addonNameMenuDisplay		= "|c00FF00NotACraftsman|r"
NOC.addonVars.addonAuthor 				= '|cFFFF00Martype|r'
NOC.addonVars.website 					= ""
NOC.addonVars.savedVarVersion		   	= 0.01 -- Changing this will reset all SavedVariables!
NOC.addonVars.gAddonLoaded				= false
NOC.addonVars.gPlayerActivated			= false
NOC.addonVars.gSettingsLoaded			= false


--==============================================================================
--===================== FUNCTIONS ==============================================
--==============================================================================



-- =====================================================================================================================
--  Addon initialization
-- =====================================================================================================================

-- Register the event "addon loaded" for this addon
local function NOC_Initialized()
    --Set the event callback functions
    NOC.setEventCallbackFunctions()
end

--------------------------------------------------------------------------------
--- Call the start function for this addon, so the initialization is done
--------------------------------------------------------------------------------
NOC_Initialized()
