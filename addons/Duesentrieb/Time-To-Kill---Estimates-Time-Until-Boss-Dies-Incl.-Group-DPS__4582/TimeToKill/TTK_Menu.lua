local TTK = TimeToKill

---------------------------------------------------------------------------
-- CREATE SETTINGS MENU
---------------------------------------------------------------------------
function TTK.CreateSettings()
    local LAM2 = LibAddonMenu2

    -- RETURN IF LAM IS NOT INSTALLED
    if not LAM2 then return end

    local iconBoss = "|t20:20:/esoui/art/icons/mapkey/mapkey_groupboss.dds|t"
    local panelName = "Time To Kill " .. iconBoss

    local user = GetUnitDisplayName("player")
    if user == TTK.author then panelName = "[Dev] " .. panelName end

    local panelData = {
        type = "panel",
        name = panelName,
        displayName = "|cFF7F00Time To|r |cFFFFFFKill|r",
        author = "|cFF7F00" .. TTK.author .. "|r",
        version = TTK.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local function GetColorDefault(colorArray)
        return { r = colorArray[1], g = colorArray[2], b = colorArray[3], a = colorArray[4] }
    end

    local optionsData = {
        {
            type = "checkbox",
            name = "|cFF7F00MASTERSWITCH|r",
            tooltip = "Enables or disables the entire tracker.",
            getFunc = function() return TTK.SV.isEnabledAddon end,
            setFunc = function(value)
                TTK.SV.isEnabledAddon = value
                if value then TTK.Enable() else TTK.Disable() end
            end,
            default = TTK.default.isEnabledAddon,
        },
        {
            type = "description",
            text = "Type |cFF7F00/timetokill|r to lock/unlock and reposition the ui element.",
            width = "full",
        },
        {
            type = "button",
            name = "Toggle Preview",
            func = function() TTK.TogglePreview() end,
            width = "half",
            disabled = function() return not TTK.SV.isEnabledAddon end,
        },
        {
            type = "button",
            name = "Reset Position",
            func = function()
                TTK.SV.offsetX, TTK.SV.offsetY = TTK.default.offsetX, TTK.default.offsetY
                TTK.PARENT:ClearAnchors()
                TTK.PARENT:SetAnchor(CENTER, GuiRoot, CENTER, TTK.SV.offsetX, TTK.SV.offsetY)
            end,
            width = "half",
            disabled = function() return not TTK.SV.isEnabledAddon end,
        },

        ---------------------------------------------------------------------------
        -- SUBMENU: CALCULATION FACTORS
        ---------------------------------------------------------------------------
        {
            type = "submenu",
            name = "|cFF7F00CALCULATION FACTORS|r",
            controls = {
                {
                    type = "slider",
                    name = "Smoothing Multiplier",
                    tooltip = "Smaller = stronger smoothing.",
                    min = 0.05, max = 0.25, step = 0.05, decimals = 2,
                    getFunc = function() return TTK.SV.smoothingMultiplier end,
                    setFunc = function(value) TTK.SV.smoothingMultiplier = value end,
                    default = TTK.default.smoothingMultiplier,
                    disabled = function() return not TTK.SV.isEnabledAddon end,
                },
                {
                    type = "slider",
                    name = "Update Intervall (ms)",
                    tooltip = "Update Intervall (ms)",
                    min = 100, max = 1000, step = 50,
                    getFunc = function() return TTK.SV.updateIntervalMs end,
                    setFunc = function(value)
                        TTK.SV.updateIntervalMs = value
                        TTK.ApplyUpdateInterval()
                    end,
                    default = TTK.default.updateIntervalMs,
                    disabled = function() return not TTK.SV.isEnabledAddon end,
                },
                {
                    type = "slider",
                    name = "Average Time Windows (sec)",
                    tooltip = "Average Time Windows (sec)",
                    min = 5, max = 15, step = 1,
                    getFunc = function() return TTK.SV.averageTimeSec end,
                    setFunc = function(value) TTK.SV.averageTimeSec = value end,
                    default = TTK.default.averageTimeSec,
                    disabled = function() return not TTK.SV.isEnabledAddon end,
                },
                {
                    type = "slider",
                    name = "Initial Phase Modifier",
                    tooltip = "Correction factor for initial burst damage.",
                    min = 1.0, max = 2.0, step = 0.05, decimals = 2,
                    getFunc = function() return TTK.SV.factorInitial end,
                    setFunc = function(value) TTK.SV.factorInitial = value end,
                    default = TTK.default.factorInitial,
                    disabled = function() return not TTK.SV.isEnabledAddon end,
                },
                {
                    type = "slider",
                    name = "Execute Phase Modifier",
                    tooltip = "Correction factor for execute damage.",
                    min = 1.0, max = 2.0, step = 0.05, decimals = 2,
                    getFunc = function() return TTK.SV.factorExecute end,
                    setFunc = function(value) TTK.SV.factorExecute = value end,
                    default = TTK.default.factorExecute,
                    disabled = function() return not TTK.SV.isEnabledAddon end,
                },
            },
        },

        ---------------------------------------------------------------------------
        -- SUBMENU: DESIGN & SCALING
        ---------------------------------------------------------------------------
        {
            type = "submenu",
            name = "|cFF7F00DESIGN & SCALING|r",
            controls = {
                {
                    type = "checkbox",
                    name = "Lock UI",
                    getFunc = function() return TTK.SV.isLocked end,
                    setFunc = function(value)
                        TTK.SV.isLocked = value
                        if not TTK.isPreview then
                            TTK.PARENT:SetMovable(not value)
                            TTK.PARENT:SetMouseEnabled(not value)
                        end
                    end,
                    default = TTK.default.isLocked,
                    disabled = function() return not TTK.SV.isEnabledAddon end,
                },
                {
                    type = "slider",
                    name = "Display Threshold (sec)",
                    tooltip = "Remaining time (TTK) for the tracker to appear / hide.",
                    min = 0, max = 120, step = 15,
                    getFunc = function() return TTK.SV.thresholdSec end,
                    setFunc = function(value) TTK.SV.thresholdSec = value end,
                    default = TTK.default.thresholdSec,
                    disabled = function() return not TTK.SV.isEnabledAddon end,
                },

                { type = "header", name = "Global Design" },
                {
                    type = "slider", name = "Icon Size",
                    min = 40, max = 100, step = 1,
                    getFunc = function() return TTK.SV.iconSize end,
                    setFunc = function(value)
                        TTK.SV.iconSize = value
                        TTK.PARENT:SetDimensions(value, value)
                        TTK.BG:SetDimensions(value, value)
                        local inner = math.max(1, value - (TTK.SV.borderThickness * 2))
                        TTK.ICON:SetDimensions(inner, inner)
                    end,
                    default = TTK.default.iconSize,
                    disabled = function() return not TTK.SV.isEnabledAddon end,
                },
                {
                    type = "slider", name = "Border Thickness",
                    tooltip = "Adjusts the thickness of the border.",
                    min = 0, max = 10, step = 1,
                    getFunc = function() return TTK.SV.borderThickness end,
                    setFunc = function(value)
                        TTK.SV.borderThickness = value
                        local innerSize = math.max(1, TTK.SV.iconSize - (TTK.SV.borderThickness * 2))
                        TTK.ICON:SetDimensions(innerSize, innerSize)
                    end,
                    default = TTK.default.borderThickness,
                    disabled = function() return not TTK.SV.isEnabledAddon end,
                },
                {
                    type = "slider", name = "Edge Thickness",
                    tooltip = "Adjusts the thickness of the edge.",
                    min = 0, max = 2, step = 1,
                    getFunc = function() return TTK.SV.edgeThickness end,
                    setFunc = function(value)
                        TTK.SV.edgeThickness = value
                        TTK.BG:SetEdgeTexture("", 1, 1, TTK.SV.edgeThickness, 0)
                        if TTK.SV.edgeThickness == 0 then TTK.BG:SetEdgeColor(0, 0, 0, 0)
                        else TTK.BG:SetEdgeColor(0, 0, 0, 1) end
                    end,
                    default = TTK.default.edgeThickness,
                    disabled = function() return not TTK.SV.isEnabledAddon end,
                },
                {
                    type = "checkbox", name = "Thick Outline Font",
                    getFunc = function() return TTK.SV.isThickOutline end,
                    setFunc = function(value)
                        TTK.SV.isThickOutline = value
                        TTK.UpdateFonts()
                    end,
                    default = TTK.default.isThickOutline,
                    disabled = function() return not TTK.SV.isEnabledAddon end,
                },

                { type = "header", name = "Timer & Labels" },
                {
                    type = "checkbox", name = "Colored Timer",
                    getFunc = function() return TTK.SV.isColoredTimer end,
                    setFunc = function(value) TTK.SV.isColoredTimer = value end,
                    default = TTK.default.isColoredTimer,
                    disabled = function() return not TTK.SV.isEnabledAddon end,
                },
                {
                    type = "slider", name = "Timer Font Size",
                    min = 26, max = 54, step = 1,
                    getFunc = function() return TTK.SV.fontSizeTimer end,
                    setFunc = function(value)
                        TTK.SV.fontSizeTimer = value
                        TTK.UpdateFonts()
                    end,
                    default = TTK.default.fontSizeTimer,
                    disabled = function() return not TTK.SV.isEnabledAddon end,
                },
                {
                    type = "slider", name = "DPS Font Size",
                    min = 12, max = 32, step = 1,
                    getFunc = function() return TTK.SV.fontSizeDPS end,
                    setFunc = function(value)
                        TTK.SV.fontSizeDPS = value
                        TTK.UpdateFonts()
                    end,
                    default = TTK.default.fontSizeDPS,
                    disabled = function() return not TTK.SV.isEnabledAddon end,
                },
            },
        },

        ---------------------------------------------------------------------------
        -- SUBMENU: COLORS
        ---------------------------------------------------------------------------
        {
            type = "submenu",
            name = "|cFF7F00COLORS (GRADIENT)|r",
            controls = {
                {
                    type = "colorpicker",
                    name = "TTK > 30sec",
                    getFunc = function() return unpack(TTK.SV.colorHigh) end,
                    setFunc = function(r, g, b, a) TTK.SV.colorHigh = {r, g, b, a} end,
                    default = GetColorDefault(TTK.default.colorHigh),
                    disabled = function() return not TTK.SV.isEnabledAddon end,
                },
                {
                    type = "colorpicker",
                    name = "TTK < 15sec",
                    getFunc = function() return unpack(TTK.SV.colorMid) end,
                    setFunc = function(r, g, b, a) TTK.SV.colorMid = {r, g, b, a} end,
                    default = GetColorDefault(TTK.default.colorMid),
                    disabled = function() return not TTK.SV.isEnabledAddon end,
                },
                {
                    type = "colorpicker",
                    name = "TTK = 0sec",
                    getFunc = function() return unpack(TTK.SV.colorLow) end,
                    setFunc = function(r, g, b, a) TTK.SV.colorLow = {r, g, b, a} end,
                    default = GetColorDefault(TTK.default.colorLow),
                    disabled = function() return not TTK.SV.isEnabledAddon end,
                },
            },
        },
    }

    local settingsPanel = LAM2:RegisterAddonPanel(TTK.name .. "Menu", panelData)
    LAM2:RegisterOptionControls(TTK.name .. "Menu", optionsData)
end