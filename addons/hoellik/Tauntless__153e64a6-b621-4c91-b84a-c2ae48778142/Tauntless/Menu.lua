Tauntless                 = Tauntless or {}
Tauntless.Menu = Tauntless.Menu or {}
Tauntless.Menu.Panel = Tauntless.Menu.Panel or {}

local Tauntless           = Tauntless

function Tauntless.Menu.create(defaults, uiScale)
    local menu = LibAddonMenu2
    if not LibAddonMenu2 then return end

    -- the panel for the addons menu
    local panel = {
        type = "panel",
        name = "Tauntless",
        displayName = "Tauntless",
        author = "hoellik",
        version = Tauntless.version or "",
        registerForRefresh = false,
    }

    Tauntless.Menu.Panel = menu:RegisterAddonPanel("Tauntless_Options", panel)

    --this adds entries in the addon menu
    local settingsEntries = {
        {
            type = "checkbox",
            name = GetString(SI_TAUNTLESS_MENU_AW_NAME),
            tooltip = GetString(SI_TAUNTLESS_MENU_AW_TOOLTIP),
            default = defaults.accountwide,
            getFunc = function() return Tauntless_Save.Default[GetDisplayName()]['$AccountWide']["accountwide"] end,
            setFunc = function(value) Tauntless_Save.Default[GetDisplayName()]['$AccountWide']["accountwide"] = value end,
            requiresReload = true,
        },
        {
            type = "checkbox",
            name = GetString(SI_TAUNTLESS_MENU_SHOWWINDOW),
            tooltip = GetString(SI_TAUNTLESS_MENU_SHOWWINDOW_TOOLTIP),
            default = defaults.showwindow,
            getFunc = function() return Tauntless.Settings.showwindow end,
            setFunc = function(value)
                Tauntless.Settings.showwindow = value
                if value then
                    if Tauntless_TLW then Tauntless_TLW:SetHidden(false) end
                    Tauntless.Widget.ShowItems(Tauntless.Menu.Panel)
                else
                    if Tauntless.Widget.ForceClear then
                        Tauntless.Widget.ForceClear()
                    else
                        Tauntless.Widget.ClearItems()
                        if Tauntless_TLW then Tauntless_TLW:SetHidden(true) end
                    end
                end
            end,
        },
        {
            type = "slider",
            name = GetString(SI_TAUNTLESS_MENU_WINDOW_X),
            tooltip = GetString(SI_TAUNTLESS_MENU_WINDOW_X_TOOLTIP),
            min = 0,
            max = GuiRoot:GetWidth(),
            step = 5,
            default = defaults.window.x / uiScale,
            getFunc = function() return zo_round(Tauntless.Settings.window.x / uiScale) end,
            setFunc = function(value)
                Tauntless.Settings.window.x = zo_round(value * uiScale)
                local window = Tauntless_TLW
                local anchorside = Tauntless.Settings.growthdirection and BOTTOMLEFT or TOPLEFT
                window:ClearAnchors()
                window:SetAnchor(anchorside, GuiRoot, anchorside, Tauntless.Settings.window.x, Tauntless.Settings.window.y)
                Tauntless.Widget.lastAnchor = { anchorside, window, anchorside, zo_round(4 / uiScale) * uiScale, zo_round(4 / uiScale) * uiScale }
                if Tauntless.Settings.showwindow then Tauntless.Widget.ShowItems(Tauntless.Menu.Panel) end
            end,
        },
        {
            type = "slider",
            name = GetString(SI_TAUNTLESS_MENU_WINDOW_Y),
            tooltip = GetString(SI_TAUNTLESS_MENU_WINDOW_Y_TOOLTIP),
            min = 0,
            max = GuiRoot:GetHeight(),
            step = 5,
            default = defaults.window.y / uiScale,
            getFunc = function() return zo_round(Tauntless.Settings.window.y / uiScale) end,
            setFunc = function(value)
                Tauntless.Settings.window.y = zo_round(value * uiScale)
                local window = Tauntless_TLW
                local anchorside = Tauntless.Settings.growthdirection and BOTTOMLEFT or TOPLEFT
                window:ClearAnchors()
                window:SetAnchor(anchorside, GuiRoot, anchorside, Tauntless.Settings.window.x, Tauntless.Settings.window.y)
                Tauntless.Widget.lastAnchor = { anchorside, window, anchorside, zo_round(4 / uiScale) * uiScale, zo_round(4 / uiScale) * uiScale }
                if Tauntless.Settings.showwindow then Tauntless.Widget.ShowItems(Tauntless.Menu.Panel) end
            end,
        },
        {
            type = "slider",
            name = GetString(SI_TAUNTLESS_MENU_WINDOW_WIDTH),
            tooltip = GetString(SI_TAUNTLESS_MENU_WINDOW_WIDTH_TOOLTIP),
            min = 100,
            max = 500,
            step = 10,
            default = defaults.window.width,
            getFunc = function() return zo_round(Tauntless.Settings.window.width) end,
            setFunc = function(value)
                Tauntless.Settings.window.width = zo_round(value / uiScale) * uiScale
                if Tauntless.Settings.showwindow then
                    Tauntless.Widget.RefreshActiveItemSizes()
                    Tauntless.Widget.ShowItems(Tauntless.Menu.Panel)
                end
            end,
        },
        {
            type = "slider",
            name = GetString(SI_TAUNTLESS_MENU_WINDOW_HEIGHT),
            tooltip = GetString(SI_TAUNTLESS_MENU_WINDOW_HEIGHT_TOOLTIP),
            min = 15,
            max = 40,
            step = 1,
            default = defaults.window.height,
            getFunc = function() return zo_round(Tauntless.Settings.window.height) end,
            setFunc = function(value)
                Tauntless.Settings.window.height = zo_round(value / uiScale) * uiScale
                if Tauntless.Settings.showwindow then
                    Tauntless.Widget.RefreshActiveItemSizes()
                    Tauntless.Widget.ShowItems(Tauntless.Menu.Panel)
                end
            end,
        },
        {
            type = "slider",
            name = GetString(SI_TAUNTLESS_MENU_MAX_BARS),
            tooltip = GetString(SI_TAUNTLESS_MENU_MAX_BARS_TOOLTIP),
            min = 5,
            max = 25,
            step = 1,
            default = defaults.maxbars,
            getFunc = function() return zo_round(Tauntless.Settings.maxbars) end,
            setFunc = function(value)
                Tauntless.Settings.maxbars = value
                if Tauntless.Settings.showwindow then Tauntless.Widget.ShowItems(Tauntless.Menu.Panel) end
            end,
        },
        {
            type = "checkbox",
            name = GetString(SI_TAUNTLESS_MENU_GROWTH_DIRECTION),
            tooltip = GetString(SI_TAUNTLESS_MENU_GROWTH_DIRECTION_TOOLTIP),
            default = defaults.growthdirection,
            getFunc = function() return Tauntless.Settings.growthdirection end,
            setFunc = function(value)
                Tauntless.Settings.growthdirection = value;
                Tauntless.Widget.GetGrowthAnchor()

                if Tauntless.Settings.showwindow then
                    Tauntless.Widget.RefreshActiveItemSizes()
                    Tauntless.Widget.ShowItems(Tauntless.Menu.Panel)
                end

                local anchorside = Tauntless.Settings.growthdirection and BOTTOMLEFT or TOPLEFT
                Tauntless.Widget.lastAnchor = { anchorside, Tauntless_TLW, anchorside, zo_round(4 / uiScale) * uiScale, zo_round(4 / uiScale) * uiScale }
            end,
        },
        {
            type = "checkbox",
            name = GetString(SI_TAUNTLESS_MENU_BAR_DIRECTION),
            tooltip = GetString(SI_TAUNTLESS_MENU_BAR_DIRECTION_TOOLTIP),
            default = defaults.bardirection,
            getFunc = function() return Tauntless.Settings.bardirection end,
            setFunc = function(value)
                Tauntless.Settings.bardirection = value
                if Tauntless.Settings.showwindow then Tauntless.Widget.RefreshActiveItemSizes() end
            end,
        },
        {
            type = "checkbox",
            name = GetString(SI_TAUNTLESS_MENU_TRACKONLYPLAYER),
            tooltip = GetString(SI_TAUNTLESS_MENU_TRACKONLYPLAYER_TOOLTIP),
            default = defaults.trackonlyplayer,
            getFunc = function() return Tauntless.Settings.trackonlyplayer end,
            setFunc = function(value)
                Tauntless.Settings.trackonlyplayer = value
                Tauntless.RegisterAbilities()
            end,
        },
    }

    for i, data in ipairs(Tauntless.Settings.trackedabilities) do
        local id = data[1]

        local name = GetAbilityName(id)

        local entry = {

            type = "checkbox",
            name = string.format(GetString(SI_TAUNTLESS_MENU_TRACK), zo_strformat(SI_ABILITY_NAME, name)),
            tooltip = string.format(GetString(SI_TAUNTLESS_MENU_TRACK_TOOLTIP), zo_strformat(SI_ABILITY_NAME, name)),
            default = defaults.trackedabilities[i][2],
            getFunc = function() return data[2] end,
            setFunc = function(value)
                data[2] = value
                Tauntless.RegisterAbilities()
            end,

        }

        table.insert(settingsEntries, entry)
    end

    menu:RegisterOptionControls("Tauntless_Options", settingsEntries)

    local function onPanelOpened(panel)
        if panel ~= Tauntless.Menu.Panel then return end
        if Tauntless.Settings.showwindow then
            if Tauntless_TLW then Tauntless_TLW:SetHidden(false) end
            Tauntless.Widget.ShowItems(Tauntless.Menu.Panel)
        end
    end

    local function onPanelClosed(panel)
        if panel ~= Tauntless.Menu.Panel then return end
        if Tauntless.Widget.ForceClear then
            Tauntless.Widget.ForceClear()
        else
            Tauntless.Widget.ClearItems()
            if Tauntless_TLW then Tauntless_TLW:SetHidden(true) end
        end
    end

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", onPanelOpened)
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", onPanelClosed)

    return menu
end