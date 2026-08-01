--[[----------------------------------------------------------------------
    Dynamic Encounters : settings (LibAddonMenu-2.0, optional)
    If LAM is not installed everything still works via /denc commands.
----------------------------------------------------------------------]]--

local HE = DynamicEncounters

function HE.Settings_Initialize()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local S = HE.GetString

    local panelData = {
        type = "panel",
        name = HE.displayName,
        displayName = "|c66CCFF" .. HE.displayName .. "|r",
        author = "WayshrineWalker",
        version = HE.version,
        slashCommand = "/dencsettings",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LAM:RegisterAddonPanel(HE.name .. "Options", panelData)

    local soundChoices, soundValues = {}, {}
    for _, entry in ipairs(HE.SOUND_CHOICES) do
        local label = (entry.id == "NONE") and S("SET_ALERT_SOUND_NONE") or entry.id
        soundChoices[#soundChoices + 1] = label
        soundValues[#soundValues + 1]  = entry.id
    end

    local options = {
        {
            type = "checkbox", name = S("SET_PANEL_SHOW"),
            getFunc = function() return HE.sv.shown end,
            setFunc = function(v) HE.sv.shown = v; HE.UI_ApplyVisibility() end,
        },
        {
            type = "checkbox", name = S("SET_PANEL_LOCK"),
            getFunc = function() return HE.sv.locked end,
            setFunc = function(v) HE.sv.locked = v; HE.UI_ApplyLock() end,
        },
        {
            type = "button", name = S("SET_RESET_POSITION"),
            tooltip = S("SET_RESET_POSITION_TIP"),
            func = function()
                HE.sv.left, HE.sv.top = nil, nil
                HE.UI_ResetPosition()
                d(HE.GetString("CMD_RESET_POS"))
            end,
        },
        {
            type = "slider", name = S("SET_SCALE"),
            min = 0.6, max = 1.6, step = 0.05, decimals = 2,
            getFunc = function() return HE.sv.scale end,
            setFunc = function(v) HE.sv.scale = v; HE.UI_ApplyStyle() end,
            default = HE.defaults.scale,
        },
        {
            type = "slider", name = S("SET_OPACITY"),
            min = 0, max = 1, step = 0.05, decimals = 2,
            getFunc = function() return HE.sv.opacity end,
            setFunc = function(v) HE.sv.opacity = v; HE.UI_ApplyStyle() end,
            default = HE.defaults.opacity,
        },
        {
            type = "dropdown", name = S("SET_THEME"),
            choices = { S("SET_THEME_DARK"), S("SET_THEME_LIGHT"), S("SET_THEME_CUSTOM") },
            choicesValues = { "dark", "light", "custom" },
            getFunc = function() return HE.sv.theme end,
            setFunc = function(v)
                HE.sv.theme = v
                if v == "custom" and not HE.sv.customColors then
                    HE.sv.customColors = HE.GetDefaultCustomColors()
                end
                HE.UI_ApplyStyle()
            end,
            default = HE.defaults.theme,
        },
        (function()
            local controls = {
                { type = "description", text = S("SET_COLORS_HINT") },
            }
            local function EnsureCustom()
                HE.sv.customColors = HE.sv.customColors or HE.GetDefaultCustomColors()
                return HE.sv.customColors
            end
            for _, slot in ipairs(HE.THEME_SLOTS) do
                local key = slot.key
                controls[#controls + 1] = {
                    type = "colorpicker",
                    name = S("COLOR_" .. key),
                    getFunc = function()
                        local c2 = EnsureCustom()[key]
                        return c2[1], c2[2], c2[3], c2[4] or 1
                    end,
                    setFunc = function(r, g, b, a)
                        local colors = EnsureCustom()
                        colors[key] = slot.alpha and { r, g, b, a } or { r, g, b }
                        if HE.sv.theme == "custom" then HE.UI_ApplyStyle() end
                    end,
                }
            end
            controls[#controls + 1] = {
                type = "button",
                name = S("SET_COLORS_RESET"),
                func = function()
                    HE.sv.customColors = HE.GetDefaultCustomColors()
                    if HE.sv.theme == "custom" then HE.UI_ApplyStyle() end
                end,
            }
            return { type = "submenu", name = S("SET_HEADER_COLORS"), controls = controls }
        end)(),
        {
            type = "checkbox", name = S("SET_COMPACT"),
            getFunc = function() return HE.sv.compact end,
            setFunc = function(v) HE.sv.compact = v; HE.UI_RequestRefresh() end,
        },
        {
            type = "checkbox", name = S("SET_COLLAPSED"),
            getFunc = function() return HE.sv.collapsed end,
            setFunc = function(v)
                HE.sv.collapsed = v
                if panel and panel.collapseBtn then
                    panel.collapseBtn:SetText(v and "+" or "-")
                end
                HE.UI_RequestRefresh()
            end,
        },
        {
            type = "dropdown",
            name = S("SET_COLLAPSE_MODE"),
            tooltip = "Controls how much info is shown when the panel is collapsed.",
            choices = { S("COLLAPSE_MODE_NAME"), S("COLLAPSE_MODE_STATUS"), S("COLLAPSE_MODE_FULL") },
            choicesValues = { "name", "status", "full" },
            getFunc = function() return HE.sv.collapseMode or "status" end,
            setFunc = function(v) HE.sv.collapseMode = v; HE.UI_RequestRefresh() end,
            default = HE.defaults.collapseMode,
        },
        {
            type = "checkbox", name = S("SET_DELUXE"),
            tooltip = S("SET_DELUXE_TIP"),
            getFunc = function() return HE.sv.deluxeMode end,
            setFunc = function(v) HE.sv.deluxeMode = v; HE.UI_RequestRefresh() end,
            default = HE.defaults.deluxeMode,
        },
        {
            type = "checkbox", name = S("SET_SHOW_TRAVEL"),
            getFunc = function() return HE.sv.showTravel end,
            setFunc = function(v) HE.sv.showTravel = v; HE.UI_RequestRefresh() end,
        },
        {
            type = "checkbox", name = S("SET_SHOW_HEADER_WS"),
            tooltip = S("SET_SHOW_HEADER_WS_TIP"),
            getFunc = function() return HE.sv.headerWayshrine.enabled end,
            setFunc = function(v) HE.sv.headerWayshrine.enabled = v; HE.UI_RequestRefresh() end,
        },
        {
            type = "checkbox", name = S("SET_HOVER_TOOLTIPS"),
            tooltip = S("SET_HOVER_TOOLTIPS_TIP"),
            getFunc = function() return HE.sv.showHoverTooltips end,
            setFunc = function(v) HE.sv.showHoverTooltips = v end,
            default = HE.defaults.showHoverTooltips,
        },
        {
            type = "checkbox", name = S("SET_SHOW_DISCLAIMER"),
            getFunc = function() return HE.sv.showDisclaimer end,
            setFunc = function(v) HE.sv.showDisclaimer = v; HE.UI_RequestRefresh() end,
        },
        {
            type = "checkbox", name = S("SET_ONLY_CURRENT"),
            getFunc = function() return HE.sv.onlyCurrent end,
            setFunc = function(v) HE.sv.onlyCurrent = v; HE.UI_RequestRefresh() end,
        },
        {
            type = "checkbox", name = S("SET_HIDE_IN_COMBAT"),
            getFunc = function() return HE.sv.hideInCombat end,
            setFunc = function(v)
                HE.sv.hideInCombat = v
                if v then
                    HE.RegisterCombatVisibility()
                else
                    HE.UI_SetCombatHidden(false)
                end
            end,
        },
        {
            type = "checkbox", name = S("SET_SHOW_SECONDS"),
            getFunc = function() return HE.sv.showSeconds end,
            setFunc = function(v) HE.sv.showSeconds = v; HE.UI_RequestRefresh() end,
        },
        {
            type = "checkbox", name = S("SET_SHOW_MAP_PINS"),
            tooltip = "When active, the encounter's location is shown as a pin on the world map (M key).",
            getFunc = function() return HE.sv.showMapPins end,
            setFunc = function(v) HE.sv.showMapPins = v; HE.RefreshAllMapPins() end,
            default = HE.defaults.showMapPins,
        },
        { type = "header", name = S("SET_HEADER_ENCOUNTERS") },
    }

    for _, zoneId in ipairs(HE.GetSortedZoneIds()) do
        local id = zoneId
        options[#options + 1] = {
            type = "checkbox",
            name = zo_strformat(S("SET_TRACK_FMT"), HE.GetEncounterName(id) .. " (" .. HE.GetZoneName(id) .. ")"),
            getFunc = function() return HE.IsTracked(id) end,
            setFunc = function(v) HE.sv.track[id] = v; HE.UI_RequestRefresh() end,
        }
    end

    local alertOptions = {
        { type = "header", name = S("SET_HEADER_ALERTS") },
        {
            type = "checkbox", name = S("SET_ALERT_CSA"),
            getFunc = function() return HE.sv.alertCSA end,
            setFunc = function(v) HE.sv.alertCSA = v end,
        },
        {
            type = "checkbox", name = S("SET_ALERT_CHAT"),
            getFunc = function() return HE.sv.alertChat end,
            setFunc = function(v) HE.sv.alertChat = v end,
        },
        {
            type = "dropdown", name = S("SET_ALERT_SOUND"),
            choices = soundChoices, choicesValues = soundValues,
            getFunc = function() return HE.sv.alertSound end,
            setFunc = function(v)
                HE.sv.alertSound = v
                if v ~= "NONE" and SOUNDS[v] then PlaySound(SOUNDS[v]) end
            end,
            default = HE.defaults.alertSound,
        },
        {
            type = "slider", name = S("SET_PREALERT"),
            tooltip = S("SET_PREALERT_WARN"),
            min = 0, max = 300, step = 15,
            getFunc = function() return HE.sv.preAlertSecs end,
            setFunc = function(v) HE.sv.preAlertSecs = v end,
            default = HE.defaults.preAlertSecs,
        },
                {
            type = "button", name = S("SET_RESET_TIMINGS"),
            tooltip = S("SET_RESET_TIMINGS_TOOLTIP"),
            func = function()
                HE.sv.zones, HE.sv.log, HE.sv.activeSnapshots = {}, {}, {}
                d(HE.GetString("CMD_RESET_DONE"))
            end,
            warning = S("SET_RESET_TIMINGS_TOOLTIP"),
        },
        { type = "description", text = S("NOTE_INSTANCE") },
    }

    for _, opt in ipairs(alertOptions) do
        options[#options + 1] = opt
    end

    LAM:RegisterOptionControls(HE.name .. "Options", options)
end
