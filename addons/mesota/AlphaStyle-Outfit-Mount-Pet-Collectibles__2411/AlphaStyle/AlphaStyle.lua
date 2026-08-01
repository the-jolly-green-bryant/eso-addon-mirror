-- Globals
local EM = EVENT_MANAGER

--- Writes trace messages to the console
-- fmt with %d, %s,
local function trace(fmt, ...)
	if ASModel.isDebug then
		d(string.format(fmt, ...))
    end
end


function ASApp:Initialize()
	SLASH_COMMANDS["/alphastyle"] = ASUI.ToggleMain
	SLASH_COMMANDS["/asdbg"] = ASUI.ToggleDebug
	SLASH_COMMANDS["/asstore"] = ASUI.StoreStyle
	SLASH_COMMANDS["/asload"] = ASUI.LoadStyle
	
    -- Create Key Binding Labels
    ZO_CreateStringId('SI_BINDING_NAME_SHOW_AS_WINDOW', "Toggle Main Window")

	-- initialize AlphaStyle settings
    ASModel.Settings = ZO_SavedVars:NewAccountWide(ASModel.SavedSettings.Name, ASModel.SavedSettings.Version, nil, ASModel.SavedSettings.Defaults)
	
	-- initialize character styles
    ASModel.StyleData = ZO_SavedVars:New(ASModel.SavedStyles.Name, ASModel.SavedStyles.Version, nil, ASModel.SavedStyles.Defaults)

    -- check Model for Consistency 
    ASModel.CheckConsistency()
end

function ASApp.OnAddOnLoaded(event, addonName)
    if addonName ~= ASApp.name then return end

    EM:UnregisterForEvent('AlphaStyle_Load', EVENT_ADD_ON_LOADED)
  
    ASApp:Initialize()
end


EM:RegisterForEvent('AlphaStyle_Load', EVENT_ADD_ON_LOADED, ASApp.OnAddOnLoaded)

