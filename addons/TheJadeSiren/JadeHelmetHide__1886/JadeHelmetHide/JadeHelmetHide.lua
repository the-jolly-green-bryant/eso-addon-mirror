JadeHelmetHide = {}
JadeHelmetHide.name = "JadeHelmetHide"
JadeHelmetHide.majorVersion = 1
JadeHelmetHide.minorVersion = 0
JadeHelmetHide.bugVersion = 0
JadeHelmetHide.version = JadeHelmetHide.majorVersion .. "." .. JadeHelmetHide.minorVersion .. "." .. JadeHelmetHide.bugVersion

JadeHelmetHide.uiEnabled = false

JadeHelmetHide.vars = {}
JadeHelmetHide.vars_defaults = {
    ["uiAutoHide"] = true,
    ["uiShowText"] = false,
    ["position"] = { },
}

-- Constants
local FALSE = "0"
local TRUE = "1"
local TEXT_SHOWN = "HIDE"
local TEXT_HIDDEN = "SHOW"


-- [[ GLOBAL FUNCTIONS ]]

-- Simple function to convert boolean to integer
function JadeHelmetHide.ToInt(val)
    return val and 1 or 0
end

-- Save the UI position
function JadeHelmetHide.SaveUIPosition()
    JadeHelmetHide.vars.position.left = JadeHelmetHideUI:GetLeft()
    JadeHelmetHide.vars.position.top = JadeHelmetHideUI:GetTop()
end

-- Set the UI position to saved values
function JadeHelmetHide.RestorePosition()
    JadeHelmetHideUI:ClearAnchors()

    if next(JadeHelmetHide.vars.position) == nil then
        -- Start in the center of the screen by default
        JadeHelmetHideUI:SetAnchor(CENTER, GuiRoot, CENTER, JadeHelmetHide.vars.position.left, JadeHelmetHide.vars.position.top)
    else
        -- Set the top, left offsets if they already exist
        JadeHelmetHideUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, JadeHelmetHide.vars.position.left, JadeHelmetHide.vars.position.top)
    end
end

-- Refresh UI so it's only visible when camera is in UI mode, compass is shown, and loot window is hidden
function JadeHelmetHide.RefreshUI()
    local UIMode = IsGameCameraUIModeActive()
    local CompassHidden = ZO_Compass:IsHidden()
    local LootHidden = ZO_Loot:IsHidden()

    JadeHelmetHide.uiEnabled = (not JadeHelmetHide.vars.uiAutoHide) or (UIMode and not CompassHidden and LootHidden)

    JadeHelmetHideUI:SetHidden(not JadeHelmetHide.uiEnabled)
    JadeHelmetHide.UpdateUIText()
end

-- Update the text on the button
function JadeHelmetHide.UpdateUIText()
    local hidden = GetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM) == TRUE

    if (hidden) then
        JadeHelmetHideUIBG:SetAlpha(0.1)
        JadeHelmetHideUIButton:SetAlpha(0.7)
        if (JadeHelmetHide.vars.uiShowText) then
            JadeHelmetHideUIButton:SetText(TEXT_HIDDEN)
        else 
            JadeHelmetHideUIButton:SetText("")
        end
    else
        JadeHelmetHideUIBG:SetAlpha(0.3)
        JadeHelmetHideUIButton:SetAlpha(1)
        if (JadeHelmetHide.vars.uiShowText) then
            JadeHelmetHideUIButton:SetText(TEXT_SHOWN)
    else 
            JadeHelmetHideUIButton:SetText("")
        end
    end
end

-- Toggle helmet visibility
function JadeHelmetHide.ToggleHelmet()
    local hide = not (GetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM) == TRUE)
    SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM, JadeHelmetHide.ToInt(hide), 1)
    JadeHelmetHide.RefreshUI()
end

-- Toggle the auto-hide feature to always show the icon or hide it when not in UI mode
function JadeHelmetHide.ToggleUIAutoHide()
    JadeHelmetHide.vars.uiAutoHide = not JadeHelmetHide.vars.uiAutoHide
    if (JadeHelmetHide.vars.uiAutoHide) then
        d(JadeHelmetHide.name .. " icon will auto hide.")
    else 
        d(JadeHelmetHide.name .. " icon will always show.")
    end
    JadeHelmetHide.RefreshUI()
end

-- Toggle the text on the icon on and off
function JadeHelmetHide.ToggleUIText()
    JadeHelmetHide.vars.uiShowText = not JadeHelmetHide.vars.uiShowText
    JadeHelmetHide.RefreshUI()
end


-- [[ EVENT HANDLERS ]]

-- Mouse up on UI movement event handler
function JadeHelmetHide.OnMoveStop()
  JadeHelmetHide.SaveUIPosition()
end

-- Mouse clicked on button event handler
function JadeHelmetHide.OnButtonClicked()
    JadeHelmetHide.ToggleHelmet()
end

-- Toggle button visibility based on game camera change
function JadeHelmetHide.OnEventGameCameraUIModeChanged(eventCode)
  JadeHelmetHide.RefreshUI()
end

function JadeHelmetHide.OnPlayerActivated(self, initial)
  df("Using %s %s! Use /helmet, /helm, or /hh to toggle.", JadeHelmetHide.name, JadeHelmetHide.version)
  df("Use /jhh to hide/show icon and /jhhtext to hide/show text")
  JadeHelmetHide.RefreshUI()
  EVENT_MANAGER:UnregisterForEvent(JadeHelmetHide.name, EVENT_PLAYER_ACTIVATED)
end
  
-- Initial event handler to fire when loaded
function JadeHelmetHide.OnAddOnLoaded(eventCode, addonName)
    if addonName ~= JadeHelmetHide.name then
        return
    end

    ZO_CreateStringId("SI_BINDING_NAME_JADEHELMETHIDE", "JadeHelmetHide")
    
    JadeHelmetHide.vars =
        ZO_SavedVars:New(JadeHelmetHide.name .. "SavedVariables", JadeHelmetHide.majorVersion, nil, JadeHelmetHide.vars_defaults)

    -- Add slash command shortcuts
    SLASH_COMMANDS["/hh"] = JadeHelmetHide.ToggleHelmet
    SLASH_COMMANDS["/helm"] = JadeHelmetHide.ToggleHelmet
    SLASH_COMMANDS["/helmet"] = JadeHelmetHide.ToggleHelmet
    SLASH_COMMANDS["/jhh"] = JadeHelmetHide.ToggleUIAutoHide
    SLASH_COMMANDS["/jhhtext"] = JadeHelmetHide.ToggleUIText
    
    JadeHelmetHide.RestorePosition()

    -- [[ REGISTER EVENTS ]]
    -- Unregister from add on once loaded
    EVENT_MANAGER:UnregisterForEvent(JadeHelmetHide.name, EVENT_ADD_ON_LOADED)

    -- Register subsequent events
    EVENT_MANAGER:RegisterForEvent(JadeHelmetHide.name, EVENT_PLAYER_ACTIVATED, JadeHelmetHide.OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(JadeHelmetHide.name, EVENT_GAME_CAMERA_UI_MODE_CHANGED, JadeHelmetHide.OnEventGameCameraUIModeChanged)
end


-- [[ REGISTER INITIAL EVENTS ]]

-- Register the OnAddOnLoaded Event
EVENT_MANAGER:RegisterForEvent(JadeHelmetHide.name, EVENT_ADD_ON_LOADED, JadeHelmetHide.OnAddOnLoaded)

