local TT = TargetTaunt

---------------------------------------------------------------------------
-- INITIALIZE ADDON
---------------------------------------------------------------------------
function TT.Initialize()
    TT.isConsole = IsConsoleUI()
    TT.SV = ZO_SavedVars:NewAccountWide(TT.SVName, TT.SVVersion, GetWorldName(), TT.default)
    TT.SilentMigration() -- ONLY FOR OLD VERSIONS.. TO DO: CALL ONLY IF NEEDED?

    TT.RegisterHooks()

    TT.CreateReticleElements()
    TT.CreateTrackerElements()

    TT.UpdateFonts()
    TT.UpdateTrackerDimensions()

    TT.CreateSettings()
    TT.UpdateNameplates()

    -- RESTORE SAVED POSITION OR SET DEFAULT (ONLY RETICLE)
    if TT.SV.reticleOffsetX ~= TT.default.reticleOffsetX or TT.SV.reticleOffsetY ~= TT.default.reticleOffsetY then
        TT.RETICLE:ClearAnchors()
        TT.RETICLE:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TT.SV.reticleOffsetX, TT.SV.reticleOffsetY)
    else
        TT.ResetReticlePosition()
    end

    -- RESTORE TRACKER POSITION
    if TT.TRACKER then
        TT.TRACKER:ClearAnchors()
        local ANCHOR = TT.SV.trackerGrowUpwards and BOTTOMLEFT or TOPLEFT
        TT.TRACKER:SetAnchor(ANCHOR, GuiRoot, TOPLEFT, TT.SV.trackerOffsetX, TT.SV.trackerOffsetY)
    end

    if TT.SV.isEnabledAddon then
        TT.Enable()
    end

    -- SLASH COMMAND
    SLASH_COMMANDS["/targettaunt"] = function() TT.ToggleBothPreviews() end
end

---------------------------------------------------------------------------
-- SILENT MIGRATION OF THE NEW SAVED VARIABLES
---------------------------------------------------------------------------
function TT.SilentMigration()
    local function IsValid(array, value)
        if not array then return false end
        for i = 1, #array do
            if array[i] == value then return true end
        end
        return false
    end

    -- CHECK/CORRECT FONT STYLES
    if not IsValid(TT.FONT_STYLE_VALUES, TT.SV.reticleFontStyle) then TT.SV.reticleFontStyle = TT.default.reticleFontStyle end
    if not IsValid(TT.FONT_STYLE_VALUES, TT.SV.trackerFontStyle) then TT.SV.trackerFontStyle = TT.default.trackerFontStyle end
    if not IsValid(TT.FONT_STYLE_VALUES, TT.SV.nameplateFontStyle) then TT.SV.nameplateFontStyle = TT.default.nameplateFontStyle end

    -- CHECK/CORRECT FONT WEIGHTS
    if not IsValid(TT.FONT_WEIGHT_VALUES, TT.SV.reticleFontWeight) then TT.SV.reticleFontWeight = TT.default.reticleFontWeight end
    if not IsValid(TT.FONT_WEIGHT_VALUES, TT.SV.trackerFontWeight) then TT.SV.trackerFontWeight = TT.default.trackerFontWeight end

    -- CHECK/CORRECT FONT STYLE ENUMS
    if not IsValid(TT.FONT_ENUM_VALUES, TT.SV.nameplateFontEnum) then
        TT.SV.nameplateFontEnum = TT.default.nameplateFontEnum
    end

    -- MIGRATE OLD ROLE FILTERS TO THE NEW DROP DOWN MENU.. IF NOT NIL THEN SETTINGS NEED MIGRATION
    if TT.SV.isEnabledTank ~= nil or TT.SV.isEnabledHeal ~= nil or TT.SV.isEnabledDPS ~= nil or TT.SV.isEnabledSolo ~= nil then
        -- CLEANUP OBSOLETE VARIABLES
        TT.SV.isEnabledTank = nil
        TT.SV.isEnabledHeal = nil
        TT.SV.isEnabledDPS = nil
        TT.SV.isEnabledSolo = nil
        TT.SV.isEnabledReticleUI = nil
        TT.SV.isEnabledTrackerUI = nil

        zo_callLater(function()
            d("|cFF7F00[Target Taunt]|r |cFFAA55ROLE FILTERS have been changed.|r")
            d("|cFF7F00[Target Taunt]|r |cFFFFFFPlease choose your preferences|r")
            d("|cFF7F00[Target Taunt]|r |cFFFFFFin the addon settings. Enjoy! :-)|r")
        end, 10000)
    end
end

---------------------------------------------------------------------------
-- EVENT REGISTRATION
---------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(TT.NAME, EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName == TT.NAME then
        TT.Initialize()
        EVENT_MANAGER:UnregisterForEvent(TT.NAME, EVENT_ADD_ON_LOADED)
    end
end)