StealthTextMove = {}
local stm = StealthTextMove
stm.name = "StealthTextMove"
stm.version = 1
stm.author = "Baertram"
stm.website = "https://www.esoui.com/downloads/author-2028.html"
stm.feedback = "https://www.esoui.com/portal.php?id=136&a=listbugs"
stm.donation = "https://www.esoui.com/portal.php?id=136&a=faq&faqid=131"

stm.svName = "StealthTextMove_Settings"
stm.svVersion = 1
stm.defaultSettings = {
    xOffset = 0,
    yOffset = 250,
}
stm.settings = {}

local PLAYER = "player"
local STEALTH_TEXT_CONTROL_NAME         = "ZO_ReticleContainerStealthIconStealthText"
local STEALTH_TEXT_PARENT_CONTROL_NAME  = "ZO_ReticleContainerStealthIcon"

local function BuildAddonMenu()
    stm.LAM = LibAddonMenu2

    local settings = stm.settings
    if not settings or not stm.LAM then return false end
    local defaults = stm.defaultSettings

    local panelData = {
        type 				= 'panel',
        name 				= stm.name,
        displayName 		= stm.name,
        author 				= stm.author,
        version 			= tostring(stm.version),
        registerForRefresh 	= true,
        registerForDefaults = true,
        slashCommand        = "/stms",
        website             = stm.website,
        feedback            = stm.feedback,
        donation            = stm.donation,
    }
    stm.LAMSettingsPanel = stm.LAM:RegisterAddonPanel(stm.name .. "_LAM", panelData)
    local savedVariablesOptions = {
        [1] = 'Each character',
        [2] = 'Account wide'
    }
    local optionsTable = {    -- BEGIN OF OPTIONS TABLE
        --==============================================================================
        {
            type = 'header',
            name = 'Stealth text',
        },
        {
            type = "slider",
            name = "Offset x",
            tooltip = "Set the x axis offset of the stealth text.\nIf the text was moved to the invisible area (outside of screen boundaries) reset it to 0 please!",
            min = -2048,
            max = 2048,
            decimals = 0,
            autoSelect = true,
            getFunc = function() return settings.xOffset end,
            setFunc = function(value)
                settings.xOffset = value
                stm.check()
            end,
            default = defaults.xOffset,
            width="full",
        },
        {
            type = "slider",
            name = "Offset y",
            tooltip = "Set the y axis offset of the stealth text.\nIf the text was moved to the invisible area (outside of screen boundaries) reset it to 0 please!",
            min = -2048,
            max = 2048,
            decimals = 0,
            autoSelect = true,
            getFunc = function() return settings.yOffset end,
            setFunc = function(value)
                settings.yOffset = value
                stm.check()
            end,
            default = defaults.yOffset,
            width="full",
        },
    } -- END OF OPTIONS TABLE
    stm.LAM:RegisterOptionControls(stm.name .. "_LAM", optionsTable)

end

local function LoadSavedVariables()
    stm.settings = ZO_SavedVars:NewCharacterIdSettings(stm.svName, stm.svVersion, "Settings", stm.defaultSettings, GetWorldName())
end

function stm.moveText(eventCode, unitTag, stealthState)
--d(">UnitTag: " ..tostring(unitTag) .. ", stealthState: " ..tostring(stealthState))
    if not stealthState then return end
    local stealthTextControl = WINDOW_MANAGER:GetControlByName(STEALTH_TEXT_CONTROL_NAME)
    if not stealthTextControl then return end
    local stealthTextParentControl = WINDOW_MANAGER:GetControlByName(STEALTH_TEXT_PARENT_CONTROL_NAME)
    if not stealthTextParentControl then return end
    local settings = stm.settings
    stealthTextControl:ClearAnchors()
    stealthTextControl:SetAnchor(CENTER, stealthTextParentControl, CENTER, settings.xOffset, settings.yOffset)
end

function stm.check(eventCode)
    local stealthState = GetUnitStealthState(PLAYER)
--d(">!StealthState: " ..tostring(stealthState))
    stm.moveText(eventCode, PLAYER, stealthState)
end

function stm.loaded(eventCode, addonName)
    if addonName ~= stm.name then return end
    EVENT_MANAGER:RegisterForEvent(stm.name .. "_EVENT_STEALTH_STATE_CHANGED", EVENT_STEALTH_STATE_CHANGED, stm.moveText)
    EVENT_MANAGER:AddFilterForEvent(stm.name .. "_EVENT_STEALTH_STATE_CHANGED", EVENT_STEALTH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, PLAYER)

    EVENT_MANAGER:RegisterForEvent(stm.name .. "_EVENT_RETICLE_HIDDEN_UPDATE", EVENT_RETICLE_HIDDEN_UPDATE, stm.check)
    EVENT_MANAGER:RegisterForEvent(stm.name .. "_EVENT_RETICLE_TARGET_CHANGED", EVENT_RETICLE_TARGET_CHANGED, stm.check)
    --Check once after login
    EVENT_MANAGER:RegisterForEvent(stm.name .. "_EVENT_PLAYER_ACTIVATED", EVENT_PLAYER_ACTIVATED, stm.check)

    LoadSavedVariables()
    BuildAddonMenu()
end

EVENT_MANAGER:RegisterForEvent(stm.name .. "_EVENT_ADD_ON_LOADED", EVENT_ADD_ON_LOADED, stm.loaded)
