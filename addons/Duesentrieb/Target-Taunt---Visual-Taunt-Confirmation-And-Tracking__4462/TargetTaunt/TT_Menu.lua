local TT = TargetTaunt

---------------------------------------------------------------------------
-- CREATE LAM2 SETTINGS MENU
---------------------------------------------------------------------------
function TT.CreateSettings()
    local LAM2 = LibAddonMenu2

    -- RETURN IF LAM IS NOT INSTALLED
    if not LAM2 then return end

    local iconBoss = "|t20:20:/esoui/art/icons/mapkey/mapkey_groupboss.dds|t"
    local iconTank	 = "|t20:20:/esoui/art/lfg/lfg_icon_tank.dds|t"
    local iconHealer	= "|t20:20:/esoui/art/lfg/lfg_icon_healer.dds|t"
    local iconDPS	  = "|t20:20:/esoui/art/lfg/lfg_icon_dps.dds|t"
    local iconScroll = "|t20:20:/esoui/art/journal/journal_tabicon_cadwell_up.dds|t"

    local panelName = "Target Taunt " .. iconTank
    local user = GetUnitDisplayName("player")
    if user == TT.AUTHOR then panelName = "[Dev] " .. panelName end

    local panelData = {
        type = "panel",
        name = panelName,
        displayName = "|cFF7F00Target|r |cFFFFFFTaunt|r",
        author = "|cFF7F00" .. TT.AUTHOR .. "|r |cFFFFFF[EU]|r",
        version = TT.VERSION,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    ---------------------------------------------------------------------------
    -- HELPER: GET COLOR DEFAULT
    ---------------------------------------------------------------------------
    local function GetColorDefault(colorArray)
        return { r = colorArray[1], g = colorArray[2], b = colorArray[3], a = colorArray[4] }
    end

    local optionsData = {
        ---------------------------------------------------------------------------
        -- ROOT: GENERAL SETTINGS
        ---------------------------------------------------------------------------
        {
            type = "checkbox",
            name = "|cFF7F00MASTERSWITCH|r (AddOn ON/OFF)",
            tooltip = "Enables or disables all addon functionalities. Great for quickly pausing the tracker without having to reload the UI.",
            getFunc = function() return TT.SV.isEnabledAddon end,
            setFunc = function(value)
                TT.SV.isEnabledAddon = value
                if value then
                    TT.Enable()
                else
                    TT.Disable()
                end
            end,
            default = TT.default.isEnabledAddon,
        },
        {
            type = "description",
            text = "Type |cFF7F00/targettaunt|r to lock/unlock and reposition the ui elements.",
            width = "full",
        },
        {
            type = "divider",
        },

        ---------------------------------------------------------------------------
        -- ROLE FILTERS & UI PREFERENCES
        ---------------------------------------------------------------------------
        {
            type = "header",
            name = "|cFF7F00AUTOMATION & FILTERING|r",
        },
        {
            type = "submenu",
            name = "|cFFAA55ROLE FILTERS & UI PREFERENCES|r",
            controls = {
                {
                    type = "description",
                    text = "Select which UI elements should be active based on your group role.",
                    width = "full",
                },
                {
                    type = "dropdown", name = "Active on Tank Role " .. iconTank,
                    tooltip = "Select the UI layout when your selected group role is Tank.",
                    choices = TT.UI_MODE_CHOICES,
                    choicesValues = TT.UI_MODE_VALUES,
                    getFunc = function() return TT.SV.modeTank end,
                    setFunc = function(value)
                        TT.SV.modeTank = value
                        TT.UpdateReticleTarget()
                        TT.UpdatePreview()
                    end,
                    default = TT.default.modeTank,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                    width = "full",
                },
                {
                    type = "dropdown", name = "Active on Healer Role " .. iconHealer,
                    tooltip = "Select the UI layout when your selected group role is Healer.",
                    choices = TT.UI_MODE_CHOICES,
                    choicesValues = TT.UI_MODE_VALUES,
                    getFunc = function() return TT.SV.modeHeal end,
                    setFunc = function(value)
                        TT.SV.modeHeal = value
                        TT.UpdateReticleTarget()
                        TT.UpdatePreview()
                    end,
                    default = TT.default.modeHeal,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                    width = "full",
                },
                {
                    type = "dropdown", name = "Active on DPS Role " .. iconDPS,
                    tooltip = "Select the UI layout when your selected group role is Damage Dealer.",
                    choices = TT.UI_MODE_CHOICES,
                    choicesValues = TT.UI_MODE_VALUES,
                    getFunc = function() return TT.SV.modeDPS end,
                    setFunc = function(value)
                        TT.SV.modeDPS = value
                        TT.UpdateReticleTarget()
                        TT.UpdatePreview()
                    end,
                    default = TT.default.modeDPS,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                    width = "full",
                },
                {
                    type = "dropdown", name = "Active while Solo " .. iconScroll,
                    tooltip = "Select the UI layout when you are currently not in a group.",
                    choices = TT.UI_MODE_CHOICES,
                    choicesValues = TT.UI_MODE_VALUES,
                    getFunc = function() return TT.SV.modeSolo end,
                    setFunc = function(value)
                        TT.SV.modeSolo = value
                        TT.UpdateReticleTarget()
                        TT.UpdatePreview()
                    end,
                    default = TT.default.modeSolo,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                    width = "full",
                },
            },
        },

        ---------------------------------------------------------------------------
        -- TARGET FILTERS & SCANNING
        ---------------------------------------------------------------------------
        {
            type = "submenu",
            name = "|cFFAA55TARGET FILTERS & SCANNING|r",
            controls = {
                {
                    type = "checkbox",
                    name = "Enable Target Scanning",
                    tooltip = "If enabled, looking at important enemies automatically adds them to the tracker before you even taunt them. If disabled, enemies only appear in the tracker AFTER a successful taunt.",
                    getFunc = function() return TT.SV.isEnabledScanning end,
                    setFunc = function(value) TT.SV.isEnabledScanning = value end,
                    default = TT.default.isEnabledScanning,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                },
                {
                    type = "checkbox",
                    name = "Track Group Member Taunts",
                    tooltip = "If enabled, taunts from other group members will add new targets to your tracker list. If disabled, other player taunts will only update targets that are ALREADY in your list (e.g., a boss you just lost aggro on), keeping your tracker free of their trash mobs.",
                    getFunc = function() return TT.SV.isEnabledOtherTaunts end,
                    setFunc = function(value)
                        TT.SV.isEnabledOtherTaunts = value
                    end,
                    default = TT.default.isEnabledOtherTaunts,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                },
                { type = "header", name = "|cFFD4AAImportant Targets|r" },
                {
                    type = "description",
                    text = "Filter targets by threat level to focus on high-priority elites while ignoring harmless trash mobs. Ensure your settings meet the specific requirements of each encounter.\n\n|cFF7F00[Normal]|r is recommended for raids and dungeons.\n|cFF7F00[Everything]|r also includes Target Dummies.",
                    width = "full",
                },
                {
                    type = "dropdown",
                    name = "Minimum Target Difficulty",
                    tooltip = "Select the minimum difficulty an enemy must have to be considered an important target and tracked by the addon.",
                    choices = {"Boss Only", "Deadly", "Hard", "Normal", "Easy", "Everything"},
                    choicesValues = {5, 4, 3, 2, 1, 0},
                    getFunc = function() return TT.SV.thresholdDifficulty end,
                    setFunc = function(value)
                        TT.SV.thresholdDifficulty = value
                        TT.UpdateReticleTarget()
                    end,
                    default = TT.default.thresholdDifficulty,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                    width = "full",
                },
                {
                    type = "slider", name = "Max-Health Threshold (Millions)",
                    tooltip = "Any enemy with maximum health equal to or above this value will automatically be treated as an important target, regardless of their difficulty setting. Set to 0 to disable.",
                    min = 0, max = 10, step = 0.5, decimals = 1,
                    getFunc = function() return TT.SV.thresholdMaxHealth / 1000000 end,
                    setFunc = function(value)
                        TT.SV.thresholdMaxHealth = value * 1000000
                        TT.UpdateReticleTarget()
                    end,
                    default = TT.default.thresholdMaxHealth / 1000000,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                    width = "full",
                },
                { type = "header", name = "|cFFD4AAHarmless / Non-Important Targets|r" },
                {
                    type = "checkbox", name = "Ignore Harmless Targets",
                    tooltip = "If enabled, harmless enemies (trash) will be completely ignored by the addon and will not trigger the crosshair or the tracker table.",
                    getFunc = function() return TT.SV.isEnabledIgnoreHarmless end,
                    setFunc = function(value) TT.SV.isEnabledIgnoreHarmless = value end,
                    default = TT.default.isEnabledIgnoreHarmless,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                    width = "full",
                },
                {
                    type = "checkbox", name = "Promote Harmless to Important",
                    tooltip = "If enabled, a harmless target will be permanently promoted to an important target from the moment you taunt it until it dies. It will adopt the same colors and longer expire times.",
                    getFunc = function() return TT.SV.isEnabledFlagHarmlessImportant end,
                    setFunc = function(value) TT.SV.isEnabledFlagHarmlessImportant = value end,
                    default = TT.default.isEnabledFlagHarmlessImportant,
                    disabled = function() return not TT.SV.isEnabledAddon or TT.SV.isEnabledIgnoreHarmless end,
                    width = "full",
                },
            },
        },

        ---------------------------------------------------------------------------
        -- CROSSHAIR (CENTER OF SCREEN)
        ---------------------------------------------------------------------------
        {
            type = "header",
            name = "|cFF7F00INTERFACE & POSITIONING|r",
        },
        {
            type = "submenu",
            name = "|cFFAA55CROSSHAIR (CENTER OF SCREEN)|r",
            controls = {
                {
                    type = "button",
                    name = function() return TT.isReticleUnlocked and "|cFF0000Hide / Lock|r" or "|c00FF00Show / Unlock|r" end,
                    tooltip = "Unlocks the crosshair so you can freely move it around. Forces it to stay visible.",
                    func = function(value)
                        TT.isReticleUnlocked = not TT.isReticleUnlocked
                        if TT.isReticleUnlocked then
                            value:SetText("|cFF0000Hide / Lock|r")
                        else
                            value:SetText("|c00FF00Show / Unlock|r")
                        end
                        TT.UpdatePreview()
                    end,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                    width = "half",
                },
                {
                    type = "button",
                    name = "Reset Position",
                    tooltip = "Resets the crosshairs position to the center of the screen (default location).",
                    func = function() TT.ResetReticlePosition() end,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                    width = "half",
                },
                {
                    type = "description",
                    text = "Unlock the crosshair to drag it across your screen.\nShortcut: Type |cFF7F00/targettaunt|r into chat.",
                    width = "full",
                },
                { type = "header", name = "|cFFD4AALayout & Sizing|r" },
                {
                    type = "slider", name = "Font Size Crosshair",
                    tooltip = "Adjusts the font size of the tracker in the center of the screen.",
                    min = 12, max = 36, step = 1,
                    getFunc = function() return TT.SV.reticleFontSize end,
                    setFunc = function(value)
                        TT.SV.reticleFontSize = value
                        TT.UpdateFonts()
                    end,
                    default = TT.default.reticleFontSize,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                },
                {
                    type = "dropdown", name = "Crosshair Font Style",
                    tooltip = "Select the font style for the crosshair text.",
                    choices = TT.FONT_STYLE_CHOICES,
                    choicesValues = TT.FONT_STYLE_VALUES,
                    getFunc = function() return TT.SV.reticleFontStyle end,
                    setFunc = function(value)
                        TT.SV.reticleFontStyle = value
                        TT.UpdateFonts()
                        TT.UpdatePreview()
                    end,
                    default = TT.default.reticleFontStyle,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                },
                {
                    type = "dropdown", name = "Crosshair Font Weight",
                    tooltip = "Select the outline style for the crosshair text.",
                    choices = TT.FONT_WEIGHT_CHOICES,
                    choicesValues = TT.FONT_WEIGHT_VALUES,
                    getFunc = function() return TT.SV.reticleFontWeight end,
                    setFunc = function(value)
                        TT.SV.reticleFontWeight = value
                        TT.UpdateFonts()
                        TT.UpdatePreview()
                    end,
                    default = TT.default.reticleFontWeight,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                },
                {
                    type = "slider", name = "Crosshair Name Max Length",
                    tooltip = "Sets the maximum character limit for the target name displayed at your crosshair. Prevents long names from cluttering your screen. Set to 0 to always show full name.",
                    min = 0, max = 48, step = 1,
                    getFunc = function() return TT.SV.reticleMaxLengthName end,
                    setFunc = function(value)
                        TT.SV.reticleMaxLengthName = value
                        TT.UpdatePreview()
                    end,
                    default = TT.default.reticleMaxLengthName,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                },
                {
                    type = "checkbox", name = "Show Target Name",
                    tooltip = "Shows/Hides the targets name. This only affects the center tracker.",
                    getFunc = function() return TT.SV.isEnabledReticleName end,
                    setFunc = function(value)
                        TT.SV.isEnabledReticleName = value
                        TT.UpdateReticleAnchors()
                        TT.UpdatePreview()
                    end,
                    default = TT.default.isEnabledReticleName,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                },
                {
                    type = "checkbox", name = "Show Taunt Timer",
                    tooltip = "Displays the remaining taunt duration in seconds below the target's name.",
                    getFunc = function() return TT.SV.isEnabledTimer end,
                    setFunc = function(value)
                        TT.SV.isEnabledTimer = value
                        TT.UpdatePreview()
                    end,
                    default = TT.default.isEnabledTimer,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                },

                { type = "header", name = "|cFFD4AADraw Tier & Layer|r" },
                {
                    type = "description",
                    text = "Only change this settings if you know what you're doing.\nMore info: https://wiki.esoui.com/Drawing_Order",
                    width = "full",
                },
                {
                    type = "dropdown",
                    name = "Crosshair Draw Tier",
                    tooltip = "Only change this settings if you know what you're doing. More info: https://wiki.esoui.com/Drawing_Order",
                    choices = TT.DRAW_TIER_CHOICES,
                    choicesValues = TT.DRAW_TIER_VALUES,
                    getFunc = function() return TT.SV.reticleDrawTier end,
                    setFunc = function(value)
                        TT.SV.reticleDrawTier = value
                    end,
                    default = TT.default.reticleDrawTier,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                    requiresReload = true,
                },
                {
                    type = "dropdown",
                    name = "Crosshair Draw Layer",
                    tooltip = "Only change this settings if you know what you're doing. More info: https://wiki.esoui.com/Drawing_Order",
                    choices = TT.DRAW_LAYER_CHOICES,
                    choicesValues = TT.DRAW_LAYER_VALUES,
                    getFunc = function() return TT.SV.reticleDrawLayer end,
                    setFunc = function(value)
                        TT.SV.reticleDrawLayer = value
                    end,
                    default = TT.default.reticleDrawLayer,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                    requiresReload = true,
                },
            },
        },

        ---------------------------------------------------------------------------
        -- TRACKER TABLE (TARGET & TAUNT LIST)
        ---------------------------------------------------------------------------
        {
            type = "submenu",
            name = "|cFFAA55TRACKER TABLE (TARGET & TAUNT LIST)|r",
            controls = {
                {
                    type = "button",
                    name = function() return TT.isTrackerUnlocked and "|cFF0000Hide / Lock|r" or "|c00FF00Show / Unlock|r" end,
                    tooltip = "Unlocks the tracker table so you can freely move it around. Forces it to stay visible.",
                    func = function(value)
                        TT.isTrackerUnlocked = not TT.isTrackerUnlocked
                        if TT.isTrackerUnlocked then
                            value:SetText("|cFF0000Hide / Lock|r")
                        else
                            value:SetText("|c00FF00Show / Unlock|r")
                        end
                        TT.UpdatePreview()
                    end,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                    width = "half",
                },
                {
                    type = "button", name = "Reset Position",
                    tooltip = "Resets the tracker table back to its default location.",
                    func = function() TT.ResetTrackerPosition() end,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                    width = "half",
                },
                {
                    type = "description",
                    text = "Unlock the tracker table to drag it across your screen.\nShortcut: Type |cFF7F00/targettaunt|r into chat.",
                    width = "full",
                },
                { type = "header", name = "|cFFD4AATracker Table Background|r" },
                {
                    type = "description",
                    text = "Dynamic background colors intensify as taunts expire, naturally catching your attention.\n\n|cFF7F00[Important Targets]|r Applies to all tracked priority enemies.\n|cFF7F00[Current Target]|r Only the important enemy in your crosshair.\n|cFF7F00[Disabled]|r Removes background colors.",                    width = "full",
                },
                {
                    type = "dropdown",
                    name = "Background Color Mode (Style)",
                    tooltip = "Defines which rows in the tracker table should display a colored background.\n\nAll Rows: Every target receives a dynamic background color based on its remaining taunt time.\nCurrent Target Only: Only your currently aimed-at target gets a background highlight.\nDisabled: Removes all background colors (text and edge only).",
                    choices = TT.TRACKER_BACKGROUND_STYLE_CHOICES,
                    choicesValues = TT.TRACKER_BACKGROUND_STYLE_VALUES,
                    getFunc = function() return TT.SV.trackerBackgroundStyle end,
                    setFunc = function(value)
                        TT.SV.trackerBackgroundStyle = value
                        TT.UpdatePreview()
                    end,
                    default = TT.default.trackerBackgroundStyle,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                },
                {
                    type = "slider", name = "Tracker Table Background Alpha",
                    tooltip = "Adjusts transparency of the background (incl. edge) of the tracker.",
                    min = 0, max = 1.0, step = 0.05, decimals = 2,
                    getFunc = function() return TT.SV.trackerBackgroundAlpha end,
                    setFunc = function(value)
                        TT.SV.trackerBackgroundAlpha = value
                        TT.UpdatePreview()
                    end,
                    default = TT.default.trackerBackgroundAlpha,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                },
                {
                    type = "slider", name = "Tracker Table Edge Thickness",
                    tooltip = "Adjusts the thickness of the frame border for your current target.",
                    min = 0, max = 4, step = 1,
                    getFunc = function() return TT.SV.trackerEdgeThickness end,
                    setFunc = function(value)
                        TT.SV.trackerEdgeThickness = value
                        TT.UpdateTrackerDimensions()
                        TT.UpdatePreview()
                    end,
                    default = TT.default.trackerEdgeThickness,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                },
                { type = "header", name = "|cFFD4AADimensions & Scaling|r" },
                {
                    type = "checkbox", name = "Tracker Table Grows Upwards",
                    tooltip = "Reverses the list order. New targets stack upwards.",
                    getFunc = function() return TT.SV.trackerGrowUpwards end,
                    setFunc = function(value)
                        if value ~= TT.SV.trackerGrowUpwards then
                            if value then
                                TT.SV.trackerOffsetY = TT.TRACKER:GetBottom()
                            else
                                TT.SV.trackerOffsetY = TT.TRACKER:GetTop()
                            end
                        end

                        TT.SV.trackerGrowUpwards = value
                        TT.ResetTrackerPosition()
                        TT.UpdateTrackerDimensions()
                        TT.UpdatePreview()
                    end,
                    default = TT.default.trackerGrowUpwards,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                },
                {
                    type = "slider", name = "Tracker Table Width",
                    tooltip = "Adjusts the width of the tracker table.",
                    min = 100, max = 500, step = 10,
                    getFunc = function() return TT.SV.trackerWidth end,
                    setFunc = function(value)
                        TT.SV.trackerWidth = value
                        TT.UpdateTrackerDimensions()
                        TT.UpdatePreview()
                    end,
                    default = TT.default.trackerWidth,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                },
                {
                    type = "slider", name = "Tracker Table Padding X (Horizontal)",
                    tooltip = "Adjusts the horizontal distance between the text and the left/right edge of the tracker table.",
                    min = 0, max = 8, step = 1,
                    getFunc = function() return TT.SV.trackerEdgeX end,
                    setFunc = function(value)
                        TT.SV.trackerEdgeX = value
                        TT.UpdateTrackerDimensions()
                        TT.UpdatePreview()
                    end,
                    default = TT.default.trackerEdgeX,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                },
                {
                    type = "slider", name = "Tracker Table Padding Y (Vertical)",
                    tooltip = "Adjusts the vertical padding inside the tracker table rows. This directly affects the total height of each row.",
                    min = 0, max = 8, step = 1,
                    getFunc = function() return TT.SV.trackerEdgeY end,
                    setFunc = function(value)
                        TT.SV.trackerEdgeY = value
                        TT.UpdateTrackerDimensions()
                        TT.UpdatePreview()
                    end,
                    default = TT.default.trackerEdgeY,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                },
                {
                    type = "slider", name = "Tracker Table Row Distance (Vertical)",
                    tooltip = "Adjusts the vertical gap between each tracker table row.",
                    min = 0, max = 4, step = 1,
                    getFunc = function() return TT.SV.trackerDistanceY end,
                    setFunc = function(value)
                        TT.SV.trackerDistanceY = value
                        TT.UpdateTrackerDimensions()
                        TT.UpdatePreview()
                    end,
                    default = TT.default.trackerDistanceY,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                },
                {
                    type = "slider", name = "Max Tracker Table Rows",
                    tooltip = "Sets the maximum number of targets the tracker table will display. Changing this value requires a UI Reload to generate the UI elements.",
                    min = 5, max = 25, step = 1,
                    getFunc = function() return TT.SV.trackerMaxRows end,
                    setFunc = function(value) TT.SV.trackerMaxRows = value end,
                    default = TT.default.trackerMaxRows,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                    requiresReload = true,
                },
                {
                    type = "slider", name = "Font Size Tracker Table",
                    tooltip = "Adjusts the font size of the tracker table.",
                    min = 12, max = 24, step = 1,
                    getFunc = function() return TT.SV.trackerFontSize end,
                    setFunc = function(value)
                        TT.SV.trackerFontSize = value
                        TT.UpdateTrackerDimensions()
                        TT.UpdateFonts()
                        TT.UpdatePreview()
                    end,
                    default = TT.default.trackerFontSize,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                },
                {
                    type = "dropdown", name = "Tracker Table Font Style",
                    tooltip = "Select the font style for the tracker table text.",
                    choices = TT.FONT_STYLE_CHOICES,
                    choicesValues = TT.FONT_STYLE_VALUES,
                    getFunc = function() return TT.SV.trackerFontStyle end,
                    setFunc = function(value)
                        TT.SV.trackerFontStyle = value
                        TT.UpdateFonts()
                        TT.UpdatePreview()
                    end,
                    default = TT.default.trackerFontStyle,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                },
                {
                    type = "dropdown", name = "Tracker Table Font Weight",
                    tooltip = "Select the outline style for the tracker table text.",
                    choices = TT.FONT_WEIGHT_CHOICES,
                    choicesValues = TT.FONT_WEIGHT_VALUES,
                    getFunc = function() return TT.SV.trackerFontWeight end,
                    setFunc = function(value)
                        TT.SV.trackerFontWeight = value
                        TT.UpdateFonts()
                        TT.UpdatePreview()
                    end,
                    default = TT.default.trackerFontWeight,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                },
                {
                    type = "slider", name = "Tracker Table Name Max Length",
                    tooltip = "Sets the maximum character limit for target names inside the tracker table. Set to 0 to always show full names.",
                    min = 0, max = 48, step = 1,
                    getFunc = function() return TT.SV.trackerMaxLengthName end,
                    setFunc = function(value)
                        TT.SV.trackerMaxLengthName = value
                        TT.UpdatePreview()
                    end,
                    default = TT.default.trackerMaxLengthName,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                },

                { type = "header", name = "|cFFD4AADraw Tier & Layer|r" },
                {
                    type = "description",
                    text = "Only change this settings if you know what you're doing.\nMore info: https://wiki.esoui.com/Drawing_Order",
                    width = "full",
                },
                {
                    type = "dropdown",
                    name = "Tracker Table Draw Tier",
                    tooltip = "Only change this settings if you know what you're doing. More info: https://wiki.esoui.com/Drawing_Order",
                    choices = TT.DRAW_TIER_CHOICES,
                    choicesValues = TT.DRAW_TIER_VALUES,
                    getFunc = function() return TT.SV.trackerDrawTier end,
                    setFunc = function(value)
                        TT.SV.trackerDrawTier = value
                    end,
                    default = TT.default.trackerDrawTier,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                    requiresReload = true,
                },
                {
                    type = "dropdown",
                    name = "Tracker Table Draw Layer",
                    tooltip = "Only change this settings if you know what you're doing. More info: https://wiki.esoui.com/Drawing_Order",
                    choices = TT.DRAW_LAYER_CHOICES,
                    choicesValues = TT.DRAW_LAYER_VALUES,
                    getFunc = function() return TT.SV.trackerDrawLayer end,
                    setFunc = function(value)
                        TT.SV.trackerDrawLayer = value
                    end,
                    default = TT.default.trackerDrawLayer,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                    requiresReload = true,
                },
            },
        },

        ---------------------------------------------------------------------------
        -- COLORS & GLOBAL FORMATTING
        ---------------------------------------------------------------------------
        {
            type = "header",
            name = "|cFF7F00FEEDBACK & VISUALS|r",
        },
        {
            type = "submenu",
            name = "|cFFAA55COLORS & GLOBAL FORMATTING|r",
            controls = {
                { type = "header", name = "|cFFD4AAGlobal Text Style|r" },
                {
                    type = "checkbox", name = "[BOSS NAME] Uppercase & Brackets",
                    tooltip = "Automatically formats boss names with uppercase letters and brackets (e.g., [BOSS NAME]) so they instantly stand out. Applies to both Center Tracker and Tracker Table.",
                    getFunc = function() return TT.SV.isEnabledBossBrackets end,
                    setFunc = function(value)
                        TT.SV.isEnabledBossBrackets = value
                        TT.UpdatePreview()
                    end,
                    default = TT.default.isEnabledBossBrackets,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                },
                { type = "header", name = "|cFFD4AAYour Taunt (Important Targets)|r" },
                {
                    type = "colorpicker", name = "Start Color (100%)",
                    tooltip = "The text color when your taunt is freshly applied.",
                    getFunc = function() return unpack(TT.SV.colorPlayer100) end,
                    setFunc = function(r, g, b, a)
                        TT.SV.colorPlayer100 = {r, g, b, a}
                        TT.UpdatePreview()
                    end,
                    default = GetColorDefault(TT.default.colorPlayer100),
                    disabled = function() return not TT.SV.isEnabledAddon end,
                },
                {
                    type = "colorpicker", name = "Mid Color (50%)",
                    tooltip = "The text color when your taunt reaches half duration.",
                    getFunc = function() return unpack(TT.SV.colorPlayer50) end,
                    setFunc = function(r, g, b, a)
                        TT.SV.colorPlayer50 = {r, g, b, a}
                        TT.UpdatePreview()
                    end,
                    default = GetColorDefault(TT.default.colorPlayer50),
                    disabled = function() return not TT.SV.isEnabledAddon end,
                },
                {
                    type = "colorpicker", name = "End Color (0%)",
                    tooltip = "The text color when your taunt is about to expire (time to re-taunt!). The UI will transition between your Start, Mid, and End colors.",
                    getFunc = function() return unpack(TT.SV.colorPlayer0) end,
                    setFunc = function(r, g, b, a)
                        TT.SV.colorPlayer0 = {r, g, b, a}
                        TT.UpdatePreview()
                    end,
                    default = GetColorDefault(TT.default.colorPlayer0),
                    disabled = function() return not TT.SV.isEnabledAddon end,
                },
                { type = "header", name = "|cFFD4AAYour Taunt (Harmless / Non-Important)|r" },
                {
                    type = "colorpicker", name = "Harmless Target Color",
                    tooltip = "The color used when you taunt a harmless or non-important target that falls outside your difficulty filters.",
                    getFunc = function() return unpack(TT.SV.colorHarmless) end,
                    setFunc = function(r, g, b, a)
                        TT.SV.colorHarmless = {r, g, b, a}
                        TT.UpdatePreview()
                    end,
                    default = GetColorDefault(TT.default.colorHarmless),
                    disabled = function() return not TT.SV.isEnabledAddon end,
                },

                { type = "header", name = "|cFFD4AAOther Taunt States|r" },
                {
                    type = "colorpicker", name = "Other Player Taunt Color",
                    tooltip = "The text color when another player taunt is active on the target.",
                    getFunc = function() return unpack(TT.SV.colorOther) end,
                    setFunc = function(r, g, b, a)
                        TT.SV.colorOther = {r, g, b, a}
                        TT.UpdatePreview()
                    end,
                    default = GetColorDefault(TT.default.colorOther),
                    disabled = function() return not TT.SV.isEnabledAddon end,
                },
                {
                    type = "colorpicker", name = "No Taunt Color / Boss Warning",
                    tooltip = "The text color when a target in your crosshair is currently not taunted, or when a boss loses taunt.",
                    getFunc = function() return unpack(TT.SV.colorNone) end,
                    setFunc = function(r, g, b, a)
                        TT.SV.colorNone = {r, g, b, a}
                        TT.UpdatePreview()
                    end,
                    default = GetColorDefault(TT.default.colorNone),
                    disabled = function() return not TT.SV.isEnabledAddon end,
                },

                { type = "header", name = "|cFFD4AATaunt Immunity|r" },
                {
                    type = "description",
                    text = "The old overtaunt mechanics were replaced by taunt immunity. If multiple players attempt to taunt an enemy too often within a short window, the enemy becomes briefly immune to taunts. (Usually triggers after 5 taunts within 12 seconds).",
                    width = "full",
                },
                {
                    type = "colorpicker", name = "Taunt Immunity Color",
                    tooltip = "The text color when the target becomes immune to taunts.",
                    getFunc = function() return unpack(TT.SV.colorImmune) end,
                    setFunc = function(r, g, b, a)
                        TT.SV.colorImmune = {r, g, b, a}
                        TT.UpdatePreview()
                    end,
                    default = GetColorDefault(TT.default.colorImmune),
                    disabled = function() return not TT.SV.isEnabledAddon end,
                },
            },
        },

        ---------------------------------------------------------------------------
        -- FLOATING MARKERS (3D)
        ---------------------------------------------------------------------------
        {
            type = "submenu",
            name = "|cFFAA55FLOATING MARKERS (3D)|r",
            controls = {
                {
                    type = "description",
                    text = function()
                        local conflictName = TT.GetConflictingAddon()
                        local solution = "\n\n|cFF7F00SOLUTION:|r Please disable the 3D marker feature in the conflicting addon, or disable the addon entirely.\n" ..
                                         "Reload-UI is required to reset this lock."

                        if conflictName then
                            return "|cFF0000[WARNING]|r Conflict with " .. conflictName .. " detected.\n" ..
                                   "To prevent the game from crashing, 3D markers have been disabled." ..
                                   solution

                        elseif TT.isExternalFloatingMarker then
                            return "|cFF0000[WARNING]|r Conflict with another addon detected.\n" ..
                                   "To prevent the game from crashing, 3D markers have been disabled." ..
                                   solution

                        else
                            return "|c00FF00[CONFLICT CHECK]|r No compatibility issues detected.\n\n" ..
                                   "|cFF7F00IMPORTANT:|r The game only allows one addon to modify 3D markers at a time. " ..
                                   "Concurrent use causes the game to crash.\n" ..
                                   "If a conflict with another addon (e.g. Untaunted) is detected, " ..
                                   "Target Taunt's markers will |cFF7F00auto-disable|r."
                        end
                    end,
                    width = "full",
                },
                {
                    type = "checkbox", name = "Enable Floating Markers",
                    tooltip = "Shows a floating 3D marker above the heads of enemies you are in combat with.",
                    getFunc = function() return TT.SV.isEnabledFloatingMarker end,
                    setFunc = function(value)
                        TT.SV.isEnabledFloatingMarker = value
                        TT.UpdatePreview()
                    end,
                    disabled = function()
                        return not TT.SV.isEnabledAddon or TT.GetConflictingAddon() ~= nil or TT.isExternalFloatingMarker
                    end,
                    default = TT.default.isEnabledFloatingMarker,
                    requiresReload = true,
                },
                {
                    type = "checkbox", name = "Enable Marker Pulse",
                    tooltip = "Adds a subtle pulsing animation to the 3D marker above the enemy's head.",
                    getFunc = function() return TT.SV.isEnabledFloatingMarkerPulse end,
                    setFunc = function(value)
                        TT.SV.isEnabledFloatingMarkerPulse = value
                        TT.UpdatePreview()
                        TT.SetFloatingMarker()
                    end,
                    default = TT.default.isEnabledFloatingMarkerPulse,
                    disabled = function() 
                        return not TT.SV.isEnabledAddon or not TT.SV.isEnabledFloatingMarker or TT.GetConflictingAddon() ~= nil or TT.isExternalFloatingMarker
                    end,
                },
                {
                    type = "slider", name = "Floating Marker Size",
                    tooltip = "Adjusts the scale of the 3D marker above the enemy's head.",
                    min = 0, max = 64, step = 1,
                    getFunc = function() return TT.SV.floatingMarkerSize end,
                    setFunc = function(val)
                        TT.SV.floatingMarkerSize = val
                        TT.UpdatePreview()
                        TT.SetFloatingMarker()
                    end,
                    default = TT.default.floatingMarkerSize,
                    disabled = function()
                        return not TT.SV.isEnabledAddon or not TT.SV.isEnabledFloatingMarker or TT.GetConflictingAddon() ~= nil or TT.isExternalFloatingMarker
                    end,
                },
                {
                    type = "dropdown", name = "Floating Marker Texture",
                    tooltip = "Choose the design/shape of the floating 3D marker.",
                    choices = TT.MARKER_TEXTURE_CHOICES,
                    choicesValues = TT.MARKER_TEXTURE_VALUES,
                    getFunc = function() return TT.SV.floatingMarkerTexture end,
                    setFunc = function(value)
                        TT.SV.floatingMarkerTexture = value
                        TT.UpdatePreview()
                        TT.SetFloatingMarker()
                    end,
                    default = TT.default.floatingMarkerTexture,
                    disabled = function()
                        return not TT.SV.isEnabledAddon or not TT.SV.isEnabledFloatingMarker or TT.GetConflictingAddon() ~= nil or TT.isExternalFloatingMarker
                    end,
                }
            },
        },

        ---------------------------------------------------------------------------
        -- ENEMY NAMEPLATES
        ---------------------------------------------------------------------------
        {
            type = "submenu",
            name = "|cFFAA55NAMEPLATE SETTINGS|r",
            controls = {
                {
                    type = "description",
                    text = "These settings adjust the appearance of the floating nameplates above enemies in the game world. Default: Size 20",
                    width = "full",
                },
                {
                    type = "dropdown",
                    name = "Nameplate Font Style",
                    tooltip = "Select the base font style for the enemy nameplates.",
                    choices = TT.FONT_STYLE_CHOICES,
                    choicesValues = TT.FONT_STYLE_VALUES,
                    getFunc = function() return TT.SV.nameplateFontStyle end,
                    setFunc = function(value)
                        TT.SV.nameplateFontStyle = value
                        TT.UpdateNameplates()
                    end,
                    default = TT.default.nameplateFontStyle,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                },
                {
                    type = "dropdown",
                    name = "Nameplate Font Weight",
                    tooltip = "Select the outline or shadow style for the enemy nameplates.",
                    choices = TT.FONT_ENUM_CHOICES,
                    choicesValues = TT.FONT_ENUM_VALUES,
                    getFunc = function() return TT.SV.nameplateFontEnum end,
                    setFunc = function(value)
                        TT.SV.nameplateFontEnum = value
                        TT.UpdateNameplates()
                    end,
                    default = TT.default.nameplateFontEnum,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                },
                {
                    type = "slider",
                    name = "Nameplate Font Size",
                    tooltip = "Adjusts the size of the text on the enemy nameplates.",
                    min = 20, max = 28, step = 1,
                    getFunc = function() return TT.SV.nameplateFontSize end,
                    setFunc = function(value)
                        TT.SV.nameplateFontSize = value
                        TT.UpdateNameplates()
                    end,
                    default = TT.default.nameplateFontSize,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                },
            },
        },

        ---------------------------------------------------------------------------
        -- WARNINGS, ANIMATION & AUDIO
        ---------------------------------------------------------------------------
        {
            type = "submenu",
            name = "|cFFAA55WARNINGS, ANIMATION & AUDIO|r",
            controls = {
                { type = "header", name = "|cFFD4AAAudio Feedback|r" },
                {
                    type = "checkbox", name = "Enable Taunt Sound",
                    tooltip = "Plays a short, customizable audio cue when a taunt is successfully applied.",
                    getFunc = function() return TT.SV.isEnabledSoundTauntImportant end,
                    setFunc = function(value) TT.SV.isEnabledSoundTauntImportant = value end,
                    default = TT.default.isEnabledSoundTauntImportant,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                },
                {
                    type = "checkbox", name = "Play Sound on Harmless Targets",
                    tooltip = "If enabled, the taunt sound will also play for harmless enemies. If disabled, it only plays for important targets.",
                    getFunc = function() return TT.SV.isEnabledSoundTauntHarmless end,
                    setFunc = function(value) TT.SV.isEnabledSoundTauntHarmless = value end,
                    default = TT.default.isEnabledSoundTauntHarmless,
                    disabled = function() return not TT.SV.isEnabledAddon or not TT.SV.isEnabledSoundTauntImportant end,
                },
                {
                    type = "slider", name = "Taunt Sound Volume",
                    tooltip = "Adjusts how loud the taunt confirmation sound plays.",
                    min = 0, max = 10, step =  1,
                    getFunc = function() return TT.SV.soundTauntVolume end,
                    setFunc = function(val) TT.SV.soundTauntVolume = val end,
                    default = TT.default.soundTauntVolume,
                    disabled = function() return not TT.SV.isEnabledAddon or not TT.SV.isEnabledSoundTauntImportant end,
                },
                {
                    type = "dropdown", name = "Selected Taunt Sound",
                    tooltip = "Selects which sound effect plays when you successfully taunt an enemy.",
                    choices = TT.SOUND_CHOICES,
                    choicesValues = TT.SOUND_VALUES,
                    getFunc = function() return TT.SV.soundTauntSelected end,
                    setFunc = function(value) TT.SV.soundTauntSelected = value end,
                    default = TT.default.soundTauntSelected,
                    disabled = function() return not TT.SV.isEnabledAddon or not TT.SV.isEnabledSoundTauntImportant end,
                },
                {
                    type = "button", name = "Test Sound",
                    tooltip = "Plays the selected sound to preview your volume and audio choice.",
                    func = function() TT.PlaySoundTaunt() end,
                    disabled = function() return not TT.SV.isEnabledAddon or not TT.SV.isEnabledSoundTauntImportant end,
                    width = "half",
                },

                { type = "header", name = "|cFFD4AAVisual Animations (Pulse)|r" },

                -- RETICLE ANIMATION
                {
                    type = "checkbox", name = "Enable Crosshair Animation",
                    tooltip = "Plays a short visual pulse animation on the UI when a taunt is freshly applied.",
                    getFunc = function() return TT.SV.isEnabledReticleAnimation end,
                    setFunc = function(value) TT.SV.isEnabledReticleAnimation = value end,
                    default = TT.default.isEnabledReticleAnimation,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                },
                {
                    type = "slider", name = "Crosshair Animation Scale (%)",
                    tooltip = "How large the text in the center of the screen grows during the pulse animation (100% = no size change).",
                    min = 100, max = 300, step =  10,
                    getFunc = function() return TT.SV.reticleAnimationScale end,
                    setFunc = function(val) TT.SV.reticleAnimationScale = val end,
                    default = TT.default.reticleAnimationScale,
                    disabled = function() return not TT.SV.isEnabledAddon or not TT.SV.isEnabledReticleAnimation end,
                },
                {
                    type = "slider", name = "Crosshair Animation Duration (ms)",
                    tooltip = "The total speed of the crosshair pulse animation in milliseconds.",
                    min = 250, max = 750, step = 10,
                    getFunc = function() return TT.SV.reticleAnimationDuration end,
                    setFunc = function(val) TT.SV.reticleAnimationDuration = val end,
                    default = TT.default.reticleAnimationDuration,
                    disabled = function() return not TT.SV.isEnabledAddon or not TT.SV.isEnabledReticleAnimation end,
                },
                {
                    type = "button", name = "Test Crosshair Animation",
                    tooltip = "Plays the animation to preview your current scale and duration settings.",
                    func = function()
                        local isReticleUnlocked = TT.isReticleUnlocked
                        if not isReticleUnlocked then
                            TT.isReticleUnlocked = true
                            TT.UpdatePreview()
                        end
                        TT.PlayAnimationReticle()

                        zo_callLater(function()
                            TT.isReticleUnlocked = isReticleUnlocked
                            if not isReticleUnlocked then TT.UpdatePreview() end
                        end, TT.SV.reticleAnimationDuration + 500)
                    end,
                    disabled = function() return not TT.SV.isEnabledAddon or not TT.SV.isEnabledReticleAnimation end,
                    width = "half",
                },

                -- TRACKER ANIMATION
                {
                    type = "checkbox", name = "Enable Tracker Table Animation",
                    tooltip = "Plays a short visual pulse animation on the targets inside the tracker list when a taunt is freshly applied.",
                    getFunc = function() return TT.SV.isEnabledTrackerAnimation end,
                    setFunc = function(value) TT.SV.isEnabledTrackerAnimation = value end,
                    default = TT.default.isEnabledTrackerAnimation,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                },
                {
                    type = "slider", name = "Tracker Table Animation Scale (%)",
                    tooltip = "How large the text in the tracker list grows during the pulse animation (100% = no size change).",
                    min = 100, max = 150, step = 5,
                    getFunc = function() return TT.SV.trackerAnimationScale end,
                    setFunc = function(val) TT.SV.trackerAnimationScale = val end,
                    default = TT.default.trackerAnimationScale,
                    disabled = function() return not TT.SV.isEnabledAddon or not TT.SV.isEnabledTrackerAnimation end,
                },
                {
                    type = "slider", name = "Tracker Table Animation Duration (ms)",
                    tooltip = "The total speed of the tracker pulse animation in milliseconds.",
                    min = 250, max = 750, step = 10,
                    getFunc = function() return TT.SV.trackerAnimationDuration end,
                    setFunc = function(val) TT.SV.trackerAnimationDuration = val end,
                    default = TT.default.trackerAnimationDuration,
                    disabled = function() return not TT.SV.isEnabledAddon or not TT.SV.isEnabledTrackerAnimation end,
                },
                {
                    type = "button", name = "Test Tracker Animation",
                    tooltip = "Plays the animation on the first row of the tracker list to preview your settings.",
                    func = function()
                        local isTrackerUnlocked = TT.isTrackerUnlocked
                        if not isTrackerUnlocked then
                            TT.isTrackerUnlocked = true
                            TT.UpdatePreview()
                        end
                        TT.PlayAnimationTracker(1)
                        zo_callLater(function()
                            TT.isTrackerUnlocked = isTrackerUnlocked
                            if not isTrackerUnlocked then TT.UpdatePreview() end
                        end, TT.SV.trackerAnimationDuration + 500)
                    end,
                    disabled = function() return not TT.SV.isEnabledAddon or not TT.SV.isEnabledTrackerAnimation end,
                    width = "half",
                },

                { type = "header", name = "|cFFD4AABoss Warnings|r" },
                {
                    type = "checkbox", name = "Warning: Boss Taunt Immunity",
                    tooltip = "Flashes a warning on your screen if a boss unit becomes immune to taunts.",
                    getFunc = function() return TT.SV.isEnabledWarningTauntImmunity end,
                    setFunc = function(value) TT.SV.isEnabledWarningTauntImmunity = value end,
                    default = TT.default.isEnabledWarningTauntImmunity,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                },
                {
                    type = "checkbox", name = "Warning: Boss Lost Taunt",
                    tooltip = "Flashes a critical warning if YOUR taunt expires on a boss unit.",
                    getFunc = function() return TT.SV.isEnabledWarningTauntFaded end,
                    setFunc = function(value) TT.SV.isEnabledWarningTauntFaded = value end,
                    default = TT.default.isEnabledWarningTauntFaded,
                    disabled = function() return not TT.SV.isEnabledAddon end,
                },
                {
                    type = "slider", name = "Boss Warning Duration (ms)",
                    tooltip = "How long the immunity or lost taunt warning stays on your screen.",
                    min = 1000, max = 5000, step = 100,
                    getFunc = function() return TT.SV.warningTauntDuration end,
                    setFunc = function(val) TT.SV.warningTauntDuration = val end,
                    default = TT.default.warningTauntDuration,
                    disabled = function() return not TT.SV.isEnabledAddon or (not TT.SV.isEnabledWarningTauntFaded and not TT.SV.isEnabledWarningTauntImmunity) end,
                },
            },
        },

        ---------------------------------------------------------------------------
        -- FEEDBACK (ROOT)
        ---------------------------------------------------------------------------
        {
            type = "description",
            text = "If you enjoy |cFF7F00Target Taunt|r, consider sharing your feedback or supporting its development. Your input and contributions are greatly appreciated!",
            width = "full"
        },
        {
            type = "button",
            name = "Feedback / Donate",
            tooltip = "Opens a mail to send feedback or donate to the author. <3",
            func = function()
                if TT.isConsole then
                    d(string.format("%s |cFFFFFFFeedback via Mail is currently only supported on PC.|r", TT.CHAT))
                    return
                end
                SCENE_MANAGER:Show("mailSend")
                zo_callLater(function()
                    ZO_MailSendToField:SetText(TT.AUTHOR)
                    ZO_MailSendSubjectField:SetText("Target Taunt")
                    ZO_MailSendBodyField:TakeFocus()
                end, 250)
            end,
            width = "half"
        }
    }

    TT.MENU_PANEL = LAM2:RegisterAddonPanel(TT.NAME .. "_MENU", panelData)
    LAM2:RegisterOptionControls(TT.NAME .. "_MENU", optionsData)

    ---------------------------------------------------------------------------
    -- CALLBACK: ON PANEL OPENED
    ---------------------------------------------------------------------------
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
        if panel == TT.MENU_PANEL then
            TT.isMenuPreview = true
            TT.UpdatePreview()
        end
    end)

    ---------------------------------------------------------------------------
    -- CALLBACK: ON PANEL CLOSED
    ---------------------------------------------------------------------------
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(panel)
        if panel == TT.MENU_PANEL then
            TT.isMenuPreview = false
            TT.UpdatePreview()
        end
    end)
end