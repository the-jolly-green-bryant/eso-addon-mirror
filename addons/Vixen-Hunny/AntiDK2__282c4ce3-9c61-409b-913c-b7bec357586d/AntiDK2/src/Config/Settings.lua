local ADK = AntiDK2
local M   = {}
ADK.Config.Settings = M

-- Font presets: inlined strings, no load-time function call
local FONT_MAP = {
    Small  = "$(BOLD_FONT)|28|soft-shadow-thick",
    Medium = "$(BOLD_FONT)|38|soft-shadow-thick",
    Large  = "$(BOLD_FONT)|48|soft-shadow-thick",
    XLarge = "$(BOLD_FONT)|60|soft-shadow-thick",
}
local FONT_CHOICES = { "Small", "Medium", "Large", "XLarge" }

-- Apply a font preset to a single named control
local function SetLabelFont(ctrlName, presetName)
    local ctrl = WINDOW_MANAGER:GetControlByName(ctrlName)
    if not ctrl then return end
    ctrl:SetFont(FONT_MAP[presetName] or FONT_MAP.Large)
end

-- Reposition + rescale a window using saved vars
local function ApplyWindow(ctrlName, anchorPt, xKey, yKey, scaleKey)
    local ctrl = WINDOW_MANAGER:GetControlByName(ctrlName)
    if not ctrl then return end
    local sv = ADK.savedVars
    ctrl:ClearAnchors()
    ctrl:SetAnchor(anchorPt, GuiRoot, anchorPt, sv[xKey], sv[yKey])
    if scaleKey then ctrl:SetScale(sv[scaleKey]) end
end

-- Apply corrosive popup font preset to its labels
local function ApplyCorrosiveFont(preset)
    SetLabelFont("AntiDK2CorrosiveTitle",  preset)
    SetLabelFont("AntiDK2CorrosiveStatus", preset)
    SetLabelFont("AntiDK2CorrosiveTimer",  preset)
    SetLabelFont("AntiDK2CorrosiveStack",  preset)
end

-- Apply avoid popup font preset to its slot labels
local function ApplyAvoidFont(preset)
    for i = 1, 4 do
        SetLabelFont("AntiDK2StunLbl" .. i, preset)
    end
end

-- Test buttons: show normally-hidden popups with dummy data
local function TestCorrosive()
    if ADK.UI and ADK.UI.Corrosive then
        ADK.UI.Corrosive.Show(2, false)
        ADK.UI.Corrosive.UpdateTimer("0:05")
    end
end

local function TestAvoid()
    if ADK.UI and ADK.UI.Stuns then
        ADK.UI.Stuns.ShowAvoid("Shifting Standard")
        ADK.UI.Stuns.ShowAvoid("Fossilize")
        ADK.UI.Stuns.ShowAvoid("Shattering Rocks")
    end
end

function M.Init()
    local LAM = LibAddonMenu2
    if not LAM then
        d("[AntiDK2] LibAddonMenu-2.0 not found.")
        return
    end

    local panelData = {
        type                = "panel",
        name                = "Anti DK 2.0",
        displayName         = "|c5BCEFAAnti|r |cF5A9B8DK|r |cFFFFFF2.0|r",
        author              = "|cF5A9B8Vixen Hunny|r",
        version             = ADK.version,
        slashCommand        = "/antidk",
        registerForRefresh  = true,
        registerForDefaults = true,
    }

    local opts = {

        -----------------------------------------------------------------------
        -- TRACKING
        -----------------------------------------------------------------------
        { type = "header", name = "Tracking", width = "full" },

        {
            type    = "checkbox",
            name    = "Corrosive Armor (center popup)",
            tooltip = "Show popup when Corrosive Armor DoT hits you.",
            getFunc = function() return ADK.savedVars.trackCorrosive end,
            setFunc = function(v) ADK.savedVars.trackCorrosive = v end,
            default = ADK.defaults.trackCorrosive,
        },
        {
            type    = "checkbox",
            name    = "Wing Buffet",
            tooltip = "Track enemy players that Wing Buffet you.",
            getFunc = function() return ADK.savedVars.trackWings end,
            setFunc = function(v) ADK.savedVars.trackWings = v end,
            default = ADK.defaults.trackWings,
        },
        {
            type    = "checkbox",
            name    = "Molten Whip stacks",
            tooltip = "Count Molten Whip hits on you.",
            getFunc = function() return ADK.savedVars.trackMoltenWhip end,
            setFunc = function(v) ADK.savedVars.trackMoltenWhip = v end,
            default = ADK.defaults.trackMoltenWhip,
        },
        {
            type    = "checkbox",
            name    = "Power Lash stacks",
            tooltip = "Count Power Lash hits on you.",
            getFunc = function() return ADK.savedVars.trackPowerLash end,
            setFunc = function(v) ADK.savedVars.trackPowerLash = v end,
            default = ADK.defaults.trackPowerLash,
        },
        {
            type    = "checkbox",
            name    = "Shattering Rocks - AVOID",
            getFunc = function() return ADK.savedVars.trackShatteringRocks end,
            setFunc = function(v) ADK.savedVars.trackShatteringRocks = v end,
            default = ADK.defaults.trackShatteringRocks,
        },
        {
            type    = "checkbox",
            name    = "Fossilize - AVOID",
            getFunc = function() return ADK.savedVars.trackFossilize end,
            setFunc = function(v) ADK.savedVars.trackFossilize = v end,
            default = ADK.defaults.trackFossilize,
        },
        {
            type    = "checkbox",
            name    = "Shifting Standard - AVOID",
            getFunc = function() return ADK.savedVars.trackShiftingStandard end,
            setFunc = function(v) ADK.savedVars.trackShiftingStandard = v end,
            default = ADK.defaults.trackShiftingStandard,
        },

        -----------------------------------------------------------------------
        -- TIMING
        -----------------------------------------------------------------------
        { type = "header", name = "Timing", width = "full" },

        {
            type     = "slider",
            name     = "Corrosive popup fade (seconds)",
            tooltip  = "Seconds after the last DoT tick before the popup hides.",
            min      = 1,
            max      = 8,
            step     = 1,
            getFunc  = function() return math.floor(ADK.savedVars.corrosiveFadeDelay) end,
            setFunc  = function(v) ADK.savedVars.corrosiveFadeDelay = v end,
            default  = ADK.defaults.corrosiveFadeDelay,
        },
        {
            type     = "slider",
            name     = "AVOID popup duration (seconds)",
            min      = 1,
            max      = 5,
            step     = 1,
            getFunc  = function() return math.floor(ADK.savedVars.avoidFadeDelay) end,
            setFunc  = function(v) ADK.savedVars.avoidFadeDelay = v end,
            default  = ADK.defaults.avoidFadeDelay,
        },
        {
            type     = "slider",
            name     = "Wing Buffet target timeout (seconds)",
            tooltip  = "Remove a target from the list after this many seconds.",
            min      = 2,
            max      = 30,
            step     = 1,
            getFunc  = function() return ADK.savedVars.wingsCombatTimeout end,
            setFunc  = function(v) ADK.savedVars.wingsCombatTimeout = v end,
            default  = ADK.defaults.wingsCombatTimeout,
        },

        -----------------------------------------------------------------------
        -- MAIN PANEL  (wing buffet list + whip stacks)
        -----------------------------------------------------------------------
        { type = "header", name = "Main Panel", width = "full" },

        {
            type    = "slider",
            name    = "Position X",
            tooltip = "Pixels from the left edge of the screen.",
            min     = 0,
            max     = 2560,
            step    = 1,
            getFunc = function() return ADK.savedVars.mainPanelX end,
            setFunc = function(v)
                ADK.savedVars.mainPanelX = v
                ApplyWindow("AntiDK2MainPanel", TOPLEFT, "mainPanelX", "mainPanelY", "mainPanelScale")
            end,
            default = ADK.defaults.mainPanelX,
        },
        {
            type    = "slider",
            name    = "Position Y",
            tooltip = "Pixels from the top edge of the screen.",
            min     = 0,
            max     = 1440,
            step    = 1,
            getFunc = function() return ADK.savedVars.mainPanelY end,
            setFunc = function(v)
                ADK.savedVars.mainPanelY = v
                ApplyWindow("AntiDK2MainPanel", TOPLEFT, "mainPanelX", "mainPanelY", "mainPanelScale")
            end,
            default = ADK.defaults.mainPanelY,
        },
        {
            type    = "slider",
            name    = "Scale",
            tooltip = "Resize the main panel (0.5 = half size, 2.0 = double).",
            min     = 5,
            max     = 30,
            step    = 1,
            getFunc = function() return math.floor(ADK.savedVars.mainPanelScale * 10 + 0.5) end,
            setFunc = function(v)
                ADK.savedVars.mainPanelScale = v / 10
                ApplyWindow("AntiDK2MainPanel", TOPLEFT, "mainPanelX", "mainPanelY", "mainPanelScale")
            end,
            default = 10,
        },

        -----------------------------------------------------------------------
        -- CORROSIVE ARMOR POPUP
        -----------------------------------------------------------------------
        { type = "header", name = "Corrosive Armor Popup", width = "full" },

        {
            type    = "slider",
            name    = "Position X (from screen center)",
            tooltip = "Negative = left of center, positive = right of center.",
            min     = -960,
            max     = 960,
            step    = 1,
            getFunc = function() return ADK.savedVars.corrosivePopupX end,
            setFunc = function(v)
                ADK.savedVars.corrosivePopupX = v
                ApplyWindow("AntiDK2CorrosivePanel", CENTER, "corrosivePopupX", "corrosivePopupY", "corrosiveScale")
            end,
            default = ADK.defaults.corrosivePopupX,
        },
        {
            type    = "slider",
            name    = "Position Y (from screen center)",
            tooltip = "Negative = above center, positive = below center.",
            min     = -540,
            max     = 540,
            step    = 1,
            getFunc = function() return ADK.savedVars.corrosivePopupY end,
            setFunc = function(v)
                ADK.savedVars.corrosivePopupY = v
                ApplyWindow("AntiDK2CorrosivePanel", CENTER, "corrosivePopupX", "corrosivePopupY", "corrosiveScale")
            end,
            default = ADK.defaults.corrosivePopupY,
        },
        {
            type    = "slider",
            name    = "Scale (x10)",
            tooltip = "10 = 1.0x, 20 = 2.0x, 5 = 0.5x",
            min     = 5,
            max     = 30,
            step    = 1,
            getFunc = function() return math.floor(ADK.savedVars.corrosiveScale * 10 + 0.5) end,
            setFunc = function(v)
                ADK.savedVars.corrosiveScale = v / 10
                ApplyWindow("AntiDK2CorrosivePanel", CENTER, "corrosivePopupX", "corrosivePopupY", "corrosiveScale")
            end,
            default = 10,
        },
        {
            type    = "dropdown",
            name    = "Font Size",
            tooltip = "Font size for the Corrosive Armor popup text.",
            choices = FONT_CHOICES,
            getFunc = function() return ADK.savedVars.corrosiveFontPreset end,
            setFunc = function(v)
                ADK.savedVars.corrosiveFontPreset = v
                ApplyCorrosiveFont(v)
            end,
            default = ADK.defaults.corrosiveFontPreset,
        },
        {
            type    = "button",
            name    = "Test: Show Corrosive Popup",
            tooltip = "Preview the Corrosive Armor popup.",
            width   = "full",
            func    = TestCorrosive,
        },

        -----------------------------------------------------------------------
        -- AVOID POPUPS
        -----------------------------------------------------------------------
        { type = "header", name = "AVOID Popups (Stuns + Standard)", width = "full" },

        {
            type    = "slider",
            name    = "Position X (from screen center)",
            min     = -960,
            max     = 960,
            step    = 1,
            getFunc = function() return ADK.savedVars.avoidPopupX end,
            setFunc = function(v)
                ADK.savedVars.avoidPopupX = v
                ApplyWindow("AntiDK2StunPanel", CENTER, "avoidPopupX", "avoidPopupY", "avoidScale")
            end,
            default = ADK.defaults.avoidPopupX,
        },
        {
            type    = "slider",
            name    = "Position Y (from screen center)",
            min     = -540,
            max     = 540,
            step    = 1,
            getFunc = function() return ADK.savedVars.avoidPopupY end,
            setFunc = function(v)
                ADK.savedVars.avoidPopupY = v
                ApplyWindow("AntiDK2StunPanel", CENTER, "avoidPopupX", "avoidPopupY", "avoidScale")
            end,
            default = ADK.defaults.avoidPopupY,
        },
        {
            type    = "slider",
            name    = "Scale (x10)",
            tooltip = "10 = 1.0x, 20 = 2.0x, 5 = 0.5x",
            min     = 5,
            max     = 30,
            step    = 1,
            getFunc = function() return math.floor(ADK.savedVars.avoidScale * 10 + 0.5) end,
            setFunc = function(v)
                ADK.savedVars.avoidScale = v / 10
                ApplyWindow("AntiDK2StunPanel", CENTER, "avoidPopupX", "avoidPopupY", "avoidScale")
            end,
            default = 10,
        },
        {
            type    = "dropdown",
            name    = "Font Size",
            tooltip = "Font size for the AVOID popup text.",
            choices = FONT_CHOICES,
            getFunc = function() return ADK.savedVars.avoidFontPreset end,
            setFunc = function(v)
                ADK.savedVars.avoidFontPreset = v
                ApplyAvoidFont(v)
            end,
            default = ADK.defaults.avoidFontPreset,
        },
        {
            type    = "button",
            name    = "Test: Show AVOID Popups",
            tooltip = "Preview all three AVOID messages at once.",
            width   = "full",
            func    = TestAvoid,
        },

        -----------------------------------------------------------------------
        -- RESET
        -----------------------------------------------------------------------
        { type = "header", name = "Reset", width = "full" },

        {
            type    = "button",
            name    = "Reset All Positions and Scales",
            tooltip = "Move all windows to default positions and reset scale to 1.0.",
            width   = "full",
            func    = function()
                local sv  = ADK.savedVars
                local def = ADK.defaults
                sv.mainPanelX       = def.mainPanelX
                sv.mainPanelY       = def.mainPanelY
                sv.mainPanelScale   = def.mainPanelScale
                sv.corrosivePopupX  = def.corrosivePopupX
                sv.corrosivePopupY  = def.corrosivePopupY
                sv.corrosiveScale   = def.corrosiveScale
                sv.avoidPopupX      = def.avoidPopupX
                sv.avoidPopupY      = def.avoidPopupY
                sv.avoidScale       = def.avoidScale
                ApplyWindow("AntiDK2MainPanel",     TOPLEFT, "mainPanelX",      "mainPanelY",      "mainPanelScale")
                ApplyWindow("AntiDK2CorrosivePanel", CENTER,  "corrosivePopupX", "corrosivePopupY", "corrosiveScale")
                ApplyWindow("AntiDK2StunPanel",      CENTER,  "avoidPopupX",     "avoidPopupY",     "avoidScale")
                d("|c5BCEFAAnti DK 2.0|r: All positions and scales reset.")
            end,
        },
    }

    LAM:RegisterAddonPanel("AntiDK2_Panel", panelData)
    LAM:RegisterOptionControls("AntiDK2_Panel", opts)
end
