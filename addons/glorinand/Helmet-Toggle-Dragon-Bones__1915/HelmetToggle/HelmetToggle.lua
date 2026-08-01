--[[

Helmet Toggle
by CaptainBlagbird
https://github.com/CaptainBlagbird

--]]

-- Addon info
HelmetToggle = {}
local AddonName = "HelmetToggle"
local UIName = "HelmetToggleUI"
HelmetToggle.SavedVariables_defaults = {
    ["position"] = {},
    ["autoEnabled"] = false,
    ["uiEnabled"] = true,
    ["delayShow"] = 0,
    ["delayHide"] = 0,
    ["slashEnabled"] = false,
}
ZO_CreateStringId("SI_BINDING_NAME_HELMET_TOGGLE", "Helmet Toggle")

-- Constants
local HELMET_SHOW  = "0"
local HELMET_HIDE = "1"

-- Local variables
local savedVariables = {}
local tlw
local label
local button

-- Change helmet setting
function HelmetToggle:ToggleHelmet(showHelmet, delay)
    local newSettingValue
    
    -- Handle invalid argument
    if type(showHelmet) ~= "boolean" then
        -- Get current setting and convert to boolean (inverted because we want to toggle it)
	if GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_POLYMORPH) then
        	showHelmet = GetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_POLYMORPH_HELM) == HELMET_HIDE
	else
		showHelmet = IsCollectibleActive(5002)
	end
        -- Disable auto mode
        if savedVariables.autoEnabled then HelmetToggle:ToggleAutoMode(false) end
    end
    
    -- Convert to string
    newSettingValue = showHelmet and HELMET_SHOW or HELMET_HIDE
    
    if type(delay) == "number" and delay > 0 then
        zo_callLater(function()
                HelmetToggle:ChangeSetting(newSettingValue, showHelmet)
            end, delay)
    else
        HelmetToggle:ChangeSetting(newSettingValue, showHelmet)
    end
end

function HelmetToggle:ChangeSetting(newSettingValue, showHelmet)
    SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_POLYMORPH_HELM, newSettingValue, 1)
    colActive = IsCollectibleActive(5002)

    if not(colActive) then
	savedVariables.lastHat = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_HAT)
    end

    if colActive == showHelmet then
	if showHelmet and savedVariables.lastHat then
	    UseCollectible(savedVariables.lastHat)
	else
            UseCollectible(5002)
        end
    end
end

-- Event handler function for EVENT_PLAYER_COMBAT_STATE
local function OnCombatStateChange(eventCode, inCombat)
    local delay = inCombat and savedVariables.delayShow or savedVariables.delayHide
    HelmetToggle:ToggleHelmet(inCombat, delay)
end

-- Toggle auto mode
function HelmetToggle:ToggleAutoMode(enabled)
    if enabled == nil then
        enabled = not savedVariables.autoEnabled
    elseif type(enabled) ~= "boolean" then
        return
    end
    
    savedVariables.autoEnabled = enabled
    
    -- Start of output string
    local str = "|c70C0DE[HelmetToggle]|r Auto mode "
    -- (Un)Register event
    if savedVariables.autoEnabled then
        HelmetToggle:ToggleHelmet(false)
        EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_PLAYER_COMBAT_STATE, OnCombatStateChange)
        str = str .. "|c00FF00enabled|r"
    else
        EVENT_MANAGER:UnregisterForEvent(AddonName, EVENT_PLAYER_COMBAT_STATE)
        str = str .. "|cFF0000disabled|r"
    end
    -- Finally display output string with changed mode
    d(str)
end

-- UI initialisation
local function InitUI()
    -- Top level window
    tlw = WINDOW_MANAGER:CreateTopLevelWindow(UIName)
    tlw:SetDimensions(170, 24)
    tlw:SetMouseEnabled(true)
    tlw:SetMovable(true)
    tlw:SetHandler("OnMoveStop", function()
            savedVariables.position.left = tlw:GetLeft()
            savedVariables.position.top = tlw:GetTop()
        end)
    -- Label
    label = WINDOW_MANAGER:CreateControl(UIName.."_Label", tlw, CT_LABEL)
    label:SetFont("ZoFontGameLargeBoldShadow")
    label:SetColor(0.77, 0.76, 0.62) --> #C5C29E --> ESO gold
    label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    label:SetVerticalAlignment(CENTER)
    label:SetText("Helmet:")
    label:ClearAnchors()
    label:SetAnchor(LEFT, tlw, LEFT, 15, 0)
    -- Button
    button = WINDOW_MANAGER:CreateControlFromVirtual(UIName.."_Button", tlw, "ZO_DefaultButton")
    button:SetText("Toggle")
    button:SetDimensions(100, 24)
    button:ClearAnchors()
    button:SetAnchor(RIGHT, tlw, RIGHT, 0, 0)
    button:SetHandler("OnClicked", function()
            HelmetToggle:ToggleHelmet()
            if savedVariables.autoEnabled then
                SlashCommand("false")
            end
        end)
    tlw:SetHidden(true)
    
    -- Show/hide UI, but depending on current UI state
    function tlw:SetShown(show)
        -- Always hide, but only show when cursor shown, compass shown and loot window hidden
        local isCursorShown = IsReticleHidden()
        local isCompassShown = not ZO_Compass:IsHidden()
        local isLootHidden = ZO_Loot:IsHidden()
        show = show and (isCursorShown and isCompassShown and isLootHidden)
        -- Show/hide
        self:SetHidden(not show)
    end
end

-- UI position restore
function HelmetToggle:RestoreUIPosition()
    HelmetToggleUI:ClearAnchors()
    -- Check if table empty
    if next(savedVariables.position) == nil then
        HelmetToggleUI:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    else
        HelmetToggleUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, savedVariables.position.left, savedVariables.position.top)
    end
end

-- Event handler function for EVENT_ACTION_LAYER_POPPED and EVENT_ACTION_LAYER_PUSHED
local function OnActionLayerPoppedPushed(eventCode, layerIndex, activeLayerIndex)
    -- Handle UI hide/show
    if eventCode == EVENT_ACTION_LAYER_POPPED then
        HelmetToggleUI:SetShown(false)
    elseif eventCode == EVENT_ACTION_LAYER_PUSHED then
        HelmetToggleUI:SetShown(true)
    else
        -- Ignore
    end
end

-- Handle UI toggling
function HelmetToggle:ShowUI(value)
    if type(value) ~= "boolean" then return end
    -- If the argument isn't the current saved variable value, save the new value and show/hide UI
    if value ~= savedVariables.uiEnabled then
        savedVariables.uiEnabled = value
        HelmetToggleUI:SetShown(value)
    end
    if value then
        EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_ACTION_LAYER_POPPED, OnActionLayerPoppedPushed)
        EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_ACTION_LAYER_PUSHED, OnActionLayerPoppedPushed)
    else
        EVENT_MANAGER:UnregisterForEvent(AddonName, EVENT_ACTION_LAYER_POPPED)
        EVENT_MANAGER:UnregisterForEvent(AddonName, EVENT_ACTION_LAYER_PUSHED)
    end
end

-- Event handler function for EVENT_PLAYER_ACTIVATED
local function OnPlayerActivated(event, addonName)
    -- Set up SavedVariables object
    savedVariables = ZO_SavedVars:New("HelmetToggleSavedVariables", 1, nil, HelmetToggle.SavedVariables_defaults)
    
    -- Get saved variables table for current user/char directly (without metatable), so it is possible to use pairs()
    local sv = HelmetToggleSavedVariables.Default[GetDisplayName()][GetUnitName("player")]
    -- Clean up saved variables (from previous versions)
    for key, val in pairs(sv) do
        -- Delete key-value pair if the key can't also be found in the default settings (except for version)
        if key ~= "version" and HelmetToggle.SavedVariables_defaults[key] == nil then
            sv[key] = nil
        end
    end
    
    if savedVariables.slashEnabled then
        -- Register slash command and link function
        SLASH_COMMANDS["/ht"] = HelmetToggle.ToggleHelmet
    end
    
    -- Make sure the event is registered if auto mode is on
    if savedVariables.autoEnabled then
        EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_PLAYER_COMBAT_STATE, OnCombatStateChange)
    end
    
    -- Create UI and restore position
    InitUI()
    HelmetToggle:RestoreUIPosition()
    HelmetToggle:ShowUI(savedVariables.uiEnabled)
    
    EVENT_MANAGER:UnregisterForEvent(AddonName, EVENT_PLAYER_ACTIVATED)
end
EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)