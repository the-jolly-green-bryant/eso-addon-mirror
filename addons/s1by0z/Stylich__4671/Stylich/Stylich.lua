--------------------------------------------------------------------------------
-- Stylich
-- Save and instantly swap complete looks (appearance, weapons, title, outfit)
-- with a signature entrance memento and assignable hotkeys.
--
-- Author: @s1by0z - Menikus Noctesco [EU]
-- A modernized, largely rewritten continuation of the abandoned addon
-- "AlphaStyle" by mesota. Credit to the original author.
--------------------------------------------------------------------------------

-- Globals
local EM = EVENT_MANAGER

-- addon namespace (single global table, defined in STLConstants.lua)
local STLApp = Stylich.App
local STLUI = Stylich.UI
local STLModel = Stylich.Model
local STLLang = Stylich.Lang

--- Writes trace messages to the console
-- fmt with %d, %s,
local function trace(fmt, ...)
	if STLModel.isDebug then
		d(string.format(fmt, ...))
    end
end


function STLApp:Initialize()
	SLASH_COMMANDS["/stylich"] = STLUI.ToggleMain
	SLASH_COMMANDS["/styldbg"] = STLUI.ToggleDebug
	SLASH_COMMANDS["/stylstore"] = STLUI.StoreStyle
	SLASH_COMMANDS["/stylload"] = STLUI.LoadStyle
	SLASH_COMMANDS["/styldelay"] = STLUI.SetRevealDelay

    -- Create Key Binding Labels (localized)
    ZO_CreateStringId('SI_BINDING_NAME_SHOW_STL_WINDOW', STLLang.msg.BIND_SHOW)
    for n = 1, 15 do
        ZO_CreateStringId('SI_BINDING_NAME_APPLY_STL_SLOT_'..n, STLLang.msg.BIND_SLOT.." "..n)
    end

	-- initialize Stylich settings
    STLModel.Settings = ZO_SavedVars:NewAccountWide(STLModel.SavedSettings.Name, STLModel.SavedSettings.Version, GetWorldName(), STLModel.SavedSettings.Defaults)
	
	-- initialize character styles
    STLModel.StyleData = ZO_SavedVars:NewCharacterIdSettings(STLModel.SavedStyles.Name, STLModel.SavedStyles.Version, nil, STLModel.SavedStyles.Defaults)

    -- ONE-TIME MIGRATION so existing users keep their data after the SV structure change
    -- (styles: character NAME -> characterId; settings: added per-server scope). We only
    -- COPY (the old data is left intact until it's confirmed working), each runs once via a flag.
    if not STLModel.StyleData.migratedFromName then
        local oldStyles = ZO_SavedVars:New(STLModel.SavedStyles.Name, STLModel.SavedStyles.Version, nil, STLModel.SavedStyles.Defaults)
        local newHasStyles = STLModel.StyleData.Styles and next(STLModel.StyleData.Styles) ~= nil
        if oldStyles and oldStyles.Styles and next(oldStyles.Styles) ~= nil and not newHasStyles then
            STLModel.StyleData.Styles = ZO_DeepTableCopy(oldStyles.Styles)
            STLModel.StyleData.LastId = oldStyles.LastId or STLModel.StyleData.LastId
        end
        STLModel.StyleData.migratedFromName = true
    end
    if not STLModel.Settings.migratedToServer then
        local oldSettings = ZO_SavedVars:NewAccountWide(STLModel.SavedSettings.Name, STLModel.SavedSettings.Version, nil, STLModel.SavedSettings.Defaults)
        if oldSettings then
            for k, v in pairs(oldSettings) do
                -- skip ZO_SavedVars internals ("version", "$LastCharacterName", ...)
                if type(k) == "string" and k ~= "version" and k:sub(1, 1) ~= "$" then
                    STLModel.Settings[k] = v
                end
            end
        end
        STLModel.Settings.migratedToServer = true
    end

    -- check Model for Consistency
    STLModel.CheckConsistency()

    -- floating quick-access bar (draggable icon + quick style dropdown)
    STLUI.InitQuickBar()

    -- options window (checkbox labels + help text)
    STLUI.InitOptions()

    -- localize the hardcoded XML labels
    STLUI.LocalizeUI()
end

function STLApp.OnAddOnLoaded(event, addonName)
    if addonName ~= STLApp.name then return end

    EM:UnregisterForEvent('Stylich_Load', EVENT_ADD_ON_LOADED)
  
    STLApp:Initialize()
end


EM:RegisterForEvent('Stylich_Load', EVENT_ADD_ON_LOADED, STLApp.OnAddOnLoaded)

