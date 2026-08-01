-- global namspacing
PITHKA = PITHKA or {} 
PITHKA.ui = PITHKA.ui or {}
PITHKA.ui.button = {}

-- convenient namespacing
local api = PITHKA.common.api
local constants = PITHKA.common.constants
local utils = PITHKA.common.utils
local ui = PITHKA.ui
local savedVars = PITHKA.data.savedVars

-- debug printing
local debugEnabled = false
local function debug(msg)
    if debugEnabled then
        d('|cF0A5B0[ui.button]|r ' .. msg )
    end
end

-- define the button states
local BSTATE_NORMAL = 1
local BSTATE_PRESSED = 2
local BSTATE_DISABLED = 3
local BSTATE_DISABLED_PRESSED = 4


---------------------------------------------------------------------------------------------------------
-- Generic Callback Button
---------------------------------------------------------------------------------------------------------
function ui.button.basic(settings)
    -- required settings
    local textureBundle = settings.textureBundle
    local clickFn = settings.clickFn
    local parent = settings.parent or PITHKA_GUI

    -- optional settings
    local size = settings.size or 30
    local ttt = settings.tooltipText -- no default, existence is used to conditionally add
    local tta = settings.tooltipAnchor or constants.icon.tooltipAnchor
    local ttc = settings.tooltipColor  or constants.icon.tooltipColor
    local ttf = settings.tooltipFont   or constants.icon.tooltipFont

    -- create the control
    local control = api.control.newButton()
    control:SetDimensions(size, size) 
    control:SetState(BSTATE_NORMAL)  
    control:SetMouseOverBlendMode(0)    
    control:SetHidden(false)
    control:SetEnabled(true) 
    control:SetParent(parent)

    -- Set all button states
    control:SetPressedTexture(textureBundle.pressed)
    control:SetMouseOverTexture(textureBundle.over)
    control:SetDisabledTexture(textureBundle.disabled)
    

    -- set tooltip if defined
    if ttt then
        debug('Setting up tooltip with text: ' .. ttt)
        local ttOpenFn  = api.control.tooltipOpenFn(control, ttt, tta, ttc, ttf)
        local ttCloseFn = api.control.tooltipCloseFn(control)
        control:SetMouseEnabled(true)            
		control:SetHandler("OnMouseEnter", ttOpenFn)
		control:SetHandler( "OnMouseExit", ttCloseFn)
    end

    -- Handle click event if callbackFn is provided
    if clickFn then        
        control:SetHandler("OnClicked", function() clickFn() end)
    end

    return control
end


---------------------------------------------------------------------------------------------------------
-- Toggle Button
---------------------------------------------------------------------------------------------------------
function ui.button.toggleButton(settings)
    local control = ui.button.basic(settings)

    local stateKey = settings.stateKey
    local textureBundle = settings.textureBundle    

    -- if stateKey is provided, ensure it's initialized in savedVars
    if savedVars.get(stateKey) == nil then
        savedVars.set(stateKey, true)
    end

    -- update the appearance of the button
    local function UpdateAppearance()
        if savedVars.get(stateKey) then
            control:SetNormalTexture(textureBundle.down)
            control:SetAlpha(1)
        else
            control:SetNormalTexture(textureBundle.up)
            control:SetAlpha(0.5)
        end
    end

    -- run updateAppearance on initialization to set the initial appearance
    UpdateAppearance()

    -- register callback to update the appearance when the saved variable changes
    savedVars.registerCallback(UpdateAppearance)


    -- Handle click events
    control:SetHandler("OnClicked", function()
        -- flip the value and update the saved variable
        local value = savedVars.get(stateKey)
        savedVars.set(stateKey, not value)
        debug('Button ' .. stateKey .. ' clicked, set to: ' .. tostring(not value))

        -- do callbacks
        UpdateAppearance()
        if settings.callbackFn then
            settings.callbackFn()
        end
    end)

    return control
end

---------------------------------------------------------------------------------------------------------
-- Enum Toggle Button (for mutually exclusive tray/enum toggles)
---------------------------------------------------------------------------------------------------------
function ui.button.enumToggleButton(settings)
    -- required settings
    local savedVarKey = settings.savedVarKey -- e.g. 'currentTray'
    local enumValue = settings.enumValue     -- e.g. 'groupFinder'

    -- create the control
    local control = ui.button.basic(settings)
    -- update the appearance of the button
    local function UpdateAppearance(var, value)
        local current = savedVars.get(savedVarKey)
        if current == enumValue then
            control:SetNormalTexture(settings.textureBundle.down)
            control:SetAlpha(1)
        else
            control:SetNormalTexture(settings.textureBundle.up)
            control:SetAlpha(0.5)
        end
    end

    -- run updateAppearance on initialization to set the initial appearance
    UpdateAppearance()

    -- register callback to update the appearance when the saved variable changes
    savedVars.registerCallback(UpdateAppearance)

    -- Handle click events
    control:SetHandler("OnClicked", function()
        local current = savedVars.get(savedVarKey)
        if current == enumValue then
            -- button is enabled, flip to disabled
            savedVars.set(savedVarKey, "NONE")
        else
            -- button is disabled, flip to enabled
            savedVars.set(savedVarKey, enumValue)
        end
        debug('EnumToggleButton ' .. savedVarKey .. ' set to: ' .. tostring(savedVars.get(savedVarKey)))
        UpdateAppearance()
    end)

    return control
end