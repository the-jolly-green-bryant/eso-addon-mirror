RadiantDuration = {
    -- Main info
    name = "RadiantDuration",
    version = "1.2.1",
    author = "@Aaxc",
    language = "en",
    variableVersion = 1,
    started = 0,
    beamCasts = 0,
    length = 1800,

    -- Default settings
    Default = {
        location = CENTER,
        offsetX = 0,
        offsetY = 0,
        color = { r = 255, g = 182, b = 22 },
        lockBar = true,
        bar1Show = false,
        bar2Show = true,
        height = 20,
        width = 500,
    },
}

RadiantDuration.Id = {}
-- Radiant Opression
RadiantDuration.Id[63046] = true
RadiantDuration.Id[63069] = true
RadiantDuration.Id[63072] = true
RadiantDuration.Id[63075] = true
RadiantDuration.Id[63961] = true
RadiantDuration.Id[99335] = true
-- Radiant Glory
RadiantDuration.Id[63044] = true
RadiantDuration.Id[63060] = true
RadiantDuration.Id[63063] = true
RadiantDuration.Id[63066] = true
RadiantDuration.Id[63956] = true
RadiantDuration.Id[69118] = true
RadiantDuration.Id[99324] = true
RadiantDuration.Id[63956] = true
RadiantDuration.Id[99324] = true
RadiantDuration.Id[63066] = true
-- Radiant Destruction
RadiantDuration.Id[54993] = true
RadiantDuration.Id[63029] = true
RadiantDuration.Id[63054] = true
RadiantDuration.Id[63056] = true
RadiantDuration.Id[63058] = true
RadiantDuration.Id[63952] = true
RadiantDuration.Id[91276] = true
RadiantDuration.Id[91277] = true
RadiantDuration.Id[91278] = true
RadiantDuration.Id[99314] = true
RadiantDuration.Id[108271] = true
RadiantDuration.Id[114478] = true
RadiantDuration.Id[114479] = true
RadiantDuration.Id[114480] = true

-------------------------------------------------------------------------------------------------
-- Libraries --
-------------------------------------------------------------------------------------------------
local LAM = LibAddonMenu2

-------------------------------------------------------------------------------------------------
-- Initialize RadiantDuration --
-------------------------------------------------------------------------------------------------
function RadiantDuration:Initialize()
    -- Set combat state
    RadiantDuration.inCombat = IsUnitInCombat("player")

    -- Load langauge strings
    RadiantDuration.Language = RadiantDuration.GetLanguage()

    -- Load saved savedVariables
    RadiantDuration.savedVariables = ZO_SavedVars:NewAccountWide("RadiantDurationVars", RadiantDuration.variableVersion, nil, RadiantDuration.Default)
    RadiantDuration.savedVariables.lockBar = true

    -- Adds settings menu
    RadiantDuration.CreateSettingsWindow()

    -- Position Break Bar and hide for now
    RadiantDurationWindow:ClearAnchors()
    RadiantDurationWindow:SetAnchor(TOPLEFT, GuiRoot, RadiantDuration.savedVariables.location, RadiantDuration.savedVariables.offsetX, RadiantDuration.savedVariables.offsetY)
    RadiantDurationWindowStatusBar:SetColor(unpack(RadiantDuration.savedVariables.color))
    RadiantDuration.SetBarSize(RadiantDuration.savedVariables.width, RadiantDuration.savedVariables.height)
    RadiantDurationWindowStatusBar:SetMinMax(0, 1)
    RadiantDurationWindowStatusBar:SetValue(1)
    RadiantDurationWindow:SetHidden(true)

    -- Unregister, to prevent future unnecessary calls
    RadiantDurationTimeWindow:ClearAnchors()
    RadiantDurationTimeWindow:SetAnchor(CENTER, GuiRoot, RadiantDuration.savedVariables.location1, RadiantDuration.savedVariables.offset1X, RadiantDuration.savedVariables.offset1Y)
    RadiantDurationTimeWindow:SetHidden(true)
    RadiantDurationTimeWindowTime:SetColor(unpack(RadiantDuration.savedVariables.color))
    RadiantDurationTimeWindowTime:SetText("0.0")
    EVENT_MANAGER:UnregisterForEvent(RadiantDuration.name, EVENT_ADD_ON_LOADED)
end

-------------------------------------------------------------------------------------------------
-- OnAddOnLoaded  --
-------------------------------------------------------------------------------------------------
function RadiantDuration.OnAddOnLoaded(event, addonName)
    if addonName ~= RadiantDuration.name then
        return
    end

    RadiantDuration:Initialize(0, "")
end

-------------------------------------------------------------------------------------------------
-- OnPlayerCombatState  --
-------------------------------------------------------------------------------------------------
function RadiantDuration.OnPlayerCombatState(event, inCombat)
    -- The ~= operator is "not equal to" in Lua.
    if inCombat ~= RadiantDuration.inCombat then
        -- The player's state has changed. Update the stored state...
        RadiantDuration.inCombat = inCombat
    end

    -- Check location and make action
    if inCombat then
        EVENT_MANAGER:RegisterForEvent("RadiantDurationCombat", EVENT_COMBAT_EVENT, RadiantDuration.RadiantDurationCombatCallbacks)
    else
        RadiantDuration.exitCombat = tonumber(GetTimeStamp())
        EVENT_MANAGER:UnregisterForUpdate("RadiantDurationCombat")
        RadiantDuration.beamCasts = 0
    end
end

-------------------------------------------------------------------------------------------------
-- Load language strings --
-------------------------------------------------------------------------------------------------
function RadiantDuration.GetLanguage()
    local langCode = GetCVar('language.2')
    if langCode == "de" then
        return RadiantDuration.LangDe
    elseif langCode == "fr" then
        return RadiantDuration.LangFr
    end

    return RadiantDuration.LangEn
end

-------------------------------------------------------------------------------------------------
-- Combat callbacks --
-------------------------------------------------------------------------------------------------
function RadiantDuration.RadiantDurationCombatCallbacks(_, result, isError, aName, aGraphic, aActionSlotType, sName, sType, tName, tType, hitValue, pType, dType, log, sUnitId, tUnitId, abilityId)
    if (sType == 1) then
        if (RadiantDuration.Id[abilityId] and (result == 2240 or (RadiantDuration.beamCasts == 0 and result == 1) )) then
            RadiantDuration.beamCasts = RadiantDuration.beamCasts + 1
            if RadiantDuration.started == 0 then
                RadiantDuration.started = GetGameTimeMilliseconds() + RadiantDuration.length

                -- Show timer
                if RadiantDuration.savedVariables.bar1Show then
                    EVENT_MANAGER:RegisterForUpdate("RadiantDurationBar1", 1, RadiantDuration.RadiantDurationBar1Show)
                end

                -- Show bar
                if RadiantDuration.savedVariables.bar2Show then
                    EVENT_MANAGER:RegisterForUpdate("RadiantDurationBar2", 1, RadiantDuration.RadiantDurationBar2Show)
                end
            end
        end
    end
end

-------------------------------------------------------------------------------------------------
-- Save graphical location --
-------------------------------------------------------------------------------------------------
function RadiantDuration.WindowSaveLoc()
    RadiantDuration.savedVariables.offsetX = RadiantDurationWindow:GetLeft()
    RadiantDuration.savedVariables.offsetY = RadiantDurationWindow:GetTop()
    RadiantDuration.savedVariables.location = TOPLEFT
end

-------------------------------------------------------------------------------------------------
-- Save timer location --
-------------------------------------------------------------------------------------------------
function RadiantDuration.WindowTimeSaveLoc()
    RadiantDuration.savedVariables.offset1X = RadiantDurationTimeWindow:GetLeft()
    RadiantDuration.savedVariables.offset1Y = RadiantDurationTimeWindow:GetTop()
    RadiantDuration.savedVariables.location1 = TOPLEFT
end

-------------------------------------------------------------------------------------------------
-- Show timer bar --
-------------------------------------------------------------------------------------------------
function RadiantDuration.RadiantDurationBar1Show()
    local remaining = RadiantDuration.started - GetGameTimeMilliseconds()
    local seconds = math.floor(remaining / 1000)
    local deciseconds = math.floor((remaining - (seconds * 1000)) / 100)

    -- Activate bar
    RadiantDurationTimeWindowTime:SetColor(unpack(RadiantDuration.savedVariables.color))
    RadiantDurationTimeWindowTime:SetText(seconds .. "." .. deciseconds)
    RadiantDurationTimeWindow:SetHidden(false)

    -- Exit and stop, when timer runs out
    if remaining < 1 then
        RadiantDuration.started = 0
        RadiantDurationTimeWindowTime:SetText("0.0")
        RadiantDurationTimeWindow:SetHidden(true)
        EVENT_MANAGER:UnregisterForUpdate("RadiantDurationBar1")
    end
end

-------------------------------------------------------------------------------------------------
-- Show graphical bar --
-------------------------------------------------------------------------------------------------
function RadiantDuration.RadiantDurationBar2Show()
    local remaining = RadiantDuration.started - GetGameTimeMilliseconds()

    -- Activate bar
    RadiantDurationWindowStatusBar:SetColor(unpack(RadiantDuration.savedVariables.color))
    RadiantDurationWindowStatusBar:SetMinMax(0, RadiantDuration.length)
    RadiantDurationWindowStatusBar:SetValue(remaining)
    RadiantDurationWindow:SetHidden(false)

    -- Exit and stop, when timer runs out
    if remaining < 1 then
        RadiantDuration.started = 0
        RadiantDurationWindowStatusBar:SetMinMax(0, 1)
        RadiantDurationWindowStatusBar:SetValue(1)
        RadiantDurationWindow:SetHidden(true)
        EVENT_MANAGER:UnregisterForUpdate("RadiantDurationBar2")
    end
end

-------------------------------------------------------------------------------------------------
-- Toggle Lock --
-------------------------------------------------------------------------------------------------
function RadiantDuration.ToggleLock(_show)
    RadiantDurationWindow:SetHidden(not _show)
    RadiantDurationWindow:SetMovable(_show)
    RadiantDurationTimeWindow:SetHidden(not _show)
    RadiantDurationTimeWindow:SetMovable(_show)
    RadiantDurationTimeWindow:SetMouseEnabled(_show)
end

-------------------------------------------------------------------------------------------------
-- Adjust sizes  --
-------------------------------------------------------------------------------------------------
function RadiantDuration.SetBarSize(_width, _height)
    RadiantDurationWindow:SetDimensions(_width, _height)
    RadiantDurationWindowBackdrop:SetDimensions(_width, _height)
    RadiantDurationWindowStatusBar:SetDimensions(_width, _height)
end

-------------------------------------------------------------------------------------------------
-- Manage slash commands --
-------------------------------------------------------------------------------------------------
function RadiantDuration.CreateSettingsWindow()
    local panelData = {
        type = "panel",
        name = "Radiant Duration",
        displayName = "Radiant skill duration timer",
        author = "|c277ecdAaxc|r",
        version = RadiantDuration.version,
        slashCommand = "/rdsettings",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    local cntrlOptionsPanel = LAM:RegisterAddonPanel("Aaxc_RadiantDuration", panelData)

    -- @TODO Move this into settins LUA for easier reading

    local optionsData = {
        {
            type = "header",
            name = RadiantDuration.Language.Settings_General_Header,
        },
        {
            type = "checkbox",
            name = RadiantDuration.Language.Settings_General_LockBar,
            tooltip = RadiantDuration.Language.Settings_General_LockBar_Tooltip,
            getFunc = function() return RadiantDuration.savedVariables.lockBar end,
            setFunc = function(newValue)
                RadiantDuration.savedVariables.lockBar = newValue
                RadiantDuration.ToggleLock(not newValue)
            end,
        },
        {
            type = "header",
            name = RadiantDuration.Language.Settings_Bar,
        },
        {
            type = "checkbox",
            name = RadiantDuration.Language.Settings_General_Bar1_Show,
            tooltip = RadiantDuration.Language.Settings_General_Bar1_Show_Tooltip,
            default = true,
            getFunc = function() return RadiantDuration.savedVariables.bar1Show end,
            setFunc = function(newValue) RadiantDuration.savedVariables.bar1Show = newValue end,
        },
        {
            type = "checkbox",
            name = RadiantDuration.Language.Settings_General_Bar2_Show,
            tooltip = RadiantDuration.Language.Settings_General_Bar2_Show_Tooltip,
            default = true,
            getFunc = function() return RadiantDuration.savedVariables.bar2Show end,
            setFunc = function(newValue) RadiantDuration.savedVariables.bar2Show = newValue end,
        },
        {
            type = "slider",
            name = RadiantDuration.Language.Settings_General_Width,
            tooltip = RadiantDuration.Language.Settings_General_Width_Tooltip,
            min = 150,
            max = 500,
            step = 1,
            default = 350,
            getFunc = function() return RadiantDuration.savedVariables.width end,
            setFunc = function(newValue)
                RadiantDuration.savedVariables.width = newValue
                RadiantDuration.SetBarSize(newValue, RadiantDuration.savedVariables.height)
            end,
        },
        {
            type = "slider",
            name = RadiantDuration.Language.Settings_General_Height,
            tooltip = RadiantDuration.Language.Settings_General_Height_Tooltip,
            min = 5,
            max = 50,
            step = 1,
            default = 10,
            getFunc = function() return RadiantDuration.savedVariables.height end,
            setFunc = function(newValue)
                RadiantDuration.savedVariables.height = newValue
                RadiantDuration.SetBarSize(RadiantDuration.savedVariables.width, newValue)
            end,
        },
        {
            type = "colorpicker",
            name = RadiantDuration.Language.Settings_General_Color,
            tooltip = RadiantDuration.Language.Settings_General_Color_Tooltip,
            getFunc = function() return unpack(RadiantDuration.savedVariables.color) end,
            setFunc = function(r, g, b, a)
                local alpha = RadiantDurationWindowStatusBar:GetAlpha()
                RadiantDuration.savedVariables.color = { r, g, b, a }
                RadiantDurationWindowStatusBar:SetColor(r, g, b, a)
                RadiantDurationWindowStatusBar:SetMinMax(0, 1)
                RadiantDurationWindowStatusBar:SetValue(1)
            end,
        },
    }
    LAM:RegisterOptionControls("Aaxc_RadiantDuration", optionsData)
end

-------------------------------------------------------------------------------------------------
-- General events and commands --
-------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent("RadiantDuration", EVENT_PLAYER_COMBAT_STATE, RadiantDuration.OnPlayerCombatState)
EVENT_MANAGER:RegisterForEvent("RadiantDuration", EVENT_ADD_ON_LOADED, RadiantDuration.OnAddOnLoaded)
