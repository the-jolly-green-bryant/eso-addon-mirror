local RPR = RewardPopupsReworked

RPR.Settings = {}

local Settings = RPR.Settings
local PANEL_NAME = "RewardPopupsReworkedSettings"

-------------------------------------------------
-- Shared helpers
-------------------------------------------------

local function Refresh()
    if RPR.ActionWidget and RPR.ActionWidget.RefreshLock then
        RPR.ActionWidget:RefreshLock()
    end

    if RPR.RewardManager and RPR.RewardManager.RefreshLater then
        RPR.RewardManager:RefreshLater("settings changed")
    end
end

local function Notify(message)
    if RPR.Notify then
        RPR:Notify(message, true)
    end
end

local function SetWidgetPreview(enabled)
    if not RPR.ActionWidget then
        Notify("The Action Widget is not available.")
        return
    end

    if enabled then
        if RPR.ActionWidget.EnableMenuPreview then
            RPR.ActionWidget:EnableMenuPreview()
        end
    else
        if RPR.ActionWidget.DisableMenuPreview then
            RPR.ActionWidget:DisableMenuPreview()
        end
    end
end

local function ResetWidgetPosition()
    local widgetSettings = RPR.savedVars and RPR.savedVars.widget
    if not widgetSettings then return end

    widgetSettings.x = 0
    widgetSettings.y = 0

    if RPR.ActionWidget and RPR.ActionWidget.RestorePosition then
        RPR.ActionWidget:RestorePosition()
    end

    Notify("Action Widget position reset.")
end

local function SetAutomaticClaiming(enabled)
    local sv = RPR.savedVars
    if not sv then return end

    sv.general.enabled = true

    sv.tamrielTomes.replacePopup = true
    sv.tamrielTomes.autoClaimRewards = enabled

    sv.goldenPursuits.replacePopup = true
    sv.goldenPursuits.autoClaimSafeRewards = enabled
    sv.goldenPursuits.enableActionWidget = true
    sv.goldenPursuits.preventAutomaticActivityPinning = true

    sv.veterancyRewards.replaceNotification = true
    sv.veterancyRewards.autoClaimRewards = enabled

    if sv.general.showWelcome ~= nil then
        sv.general.showWelcome = false
    end

    Refresh()
end

-------------------------------------------------
-- Initialization
-------------------------------------------------

function Settings:Initialize()
    self:RegisterLibAddonMenu()
    self:RegisterSlashCommands()
end

-------------------------------------------------
-- LibAddonMenu
-------------------------------------------------

function Settings:RegisterLibAddonMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = RPR.displayName,
        displayName = RPR.displayName,
        author = RPR.author,
        version = RPR.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    self.panel = LAM:RegisterAddonPanel(PANEL_NAME, panelData)

    local sv = RPR.savedVars

    local options = {
        -------------------------------------------------
        -- Introduction
        -------------------------------------------------

        {
            type = "description",
            text =
                "Removes intrusive reward prompts, optionally claims supported "
                .. "rewards automatically, and displays one non-blocking Action "
                .. "Widget whenever player attention is required.",
        },

        -------------------------------------------------
        -- General
        -------------------------------------------------

        {
            type = "header",
            name = "General",
        },
        {
            type = "checkbox",
            name = "Enable Reward Popups Reworked",
            tooltip =
                "Enables popup suppression, reward detection, automatic claiming, "
                .. "and the Action Widget according to the settings below.",
            getFunc = function()
                return sv.general.enabled
            end,
            setFunc = function(value)
                sv.general.enabled = value
                Refresh()
            end,
            default = RPR.defaults.general.enabled,
        },
        {
            type = "checkbox",
            name = "Show Reward Messages",
            tooltip =
                "Displays short chat messages when rewards are claimed or require attention.",
            getFunc = function()
                return sv.general.notificationMessages
            end,
            setFunc = function(value)
                sv.general.notificationMessages = value
            end,
            default = RPR.defaults.general.notificationMessages,
        },
        {
            type = "checkbox",
            name = "Show Startup Message",
            tooltip = "Displays a short confirmation message when the addon loads.",
            getFunc = function()
                return sv.general.showWelcome
            end,
            setFunc = function(value)
                sv.general.showWelcome = value
            end,
            default = RPR.defaults.general.showWelcome,
        },

        -------------------------------------------------
        -- Quick setup
        -------------------------------------------------

        {
            type = "header",
            name = "Quick Setup",
        },
        {
            type = "description",
            text =
                "Use one of these presets for a quick setup. Individual options "
                .. "can still be changed afterward.",
        },
        {
            type = "button",
            name = "Enable Manual Mode",
            tooltip =
                "Suppresses supported popups and displays the Action Widget when "
                .. "rewards are waiting. Automatic claiming remains disabled.",
            func = function()
                SetAutomaticClaiming(false)
                Notify(
                    "Manual Mode enabled. Supported popups are replaced and "
                    .. "automatic claiming is off."
                )
            end,
        },
        {
            type = "button",
            name = "Enable Automatic Mode",
            tooltip =
                "Suppresses supported popups and automatically claims supported "
                .. "rewards. Golden Pursuits rewards are only claimed when the "
                .. "addon identifies them as safe.",
            warning =
                "Unknown or choice-based Golden Pursuits rewards will remain "
                .. "available for manual review.",
            func = function()
                SetAutomaticClaiming(true)
                Notify(
                    "Automatic Mode enabled. Supported rewards will be claimed "
                    .. "when the addon determines it is safe."
                )
            end,
        },

        -------------------------------------------------
        -- Action Widget
        -------------------------------------------------

        {
            type = "header",
            name = "Action Widget",
        },
        {
            type = "description",
            text =
                "The Action Widget appears only when a reward is waiting for "
                .. "player attention. Its icon, frame, and glow change to match "
                .. "the highest-priority pending reward source. It automatically "
                .. "hides while maps, inventory screens, and other major menus are open.",
        },
        {
            type = "checkbox",
            name = "Lock Widget Position",
            tooltip =
                "Prevents the Action Widget from being dragged. Unlock it to reposition it.",
            getFunc = function()
                return sv.general.lockActionWidget
            end,
            setFunc = function(value)
                sv.general.lockActionWidget = value
                Refresh()
            end,
            default = RPR.defaults.general.lockActionWidget,
        },
        {
            type = "checkbox",
            name = "Enable Glow Effect",
            tooltip =
                "Enables the inner and outer source-colored glow around the Action Widget.",
            getFunc = function()
                return sv.general.glowAnimation
            end,
            setFunc = function(value)
                sv.general.glowAnimation = value
                Refresh()
            end,
            default = RPR.defaults.general.glowAnimation,
        },
        {
            type = "checkbox",
            name = "Enable Pulse Effect",
            tooltip =
                "Enables the widget's subtle attention animation, if supported by the current widget code.",
            getFunc = function()
                return sv.general.pulseAnimation
            end,
            setFunc = function(value)
                sv.general.pulseAnimation = value
                Refresh()
            end,
            default = RPR.defaults.general.pulseAnimation,
        },
        {
            type = "checkbox",
            name = "Enable Widget Tooltips",
            tooltip =
                "Shows all reward sources currently waiting for attention when hovering over the widget.",
            getFunc = function()
                return sv.general.tooltips
            end,
            setFunc = function(value)
                sv.general.tooltips = value
                Refresh()
            end,
            default = RPR.defaults.general.tooltips,
        },
        {
            type = "button",
            name = "Preview Action Widget",
            tooltip =
                "Displays the Action Widget while the settings menu remains open.",
            func = function()
                SetWidgetPreview(true)
            end,
        },
        {
            type = "button",
            name = "Hide Widget Preview",
            tooltip = "Hides the Action Widget preview.",
            func = function()
                SetWidgetPreview(false)
            end,
        },
        {
            type = "button",
            name = "Reset Widget Position",
            tooltip = "Moves the Action Widget back to the center of the screen.",
            warning = "This will replace the currently saved widget position.",
            func = ResetWidgetPosition,
        },

        -------------------------------------------------
        -- Tamriel Tomes
        -------------------------------------------------

        {
            type = "header",
            name = "Tamriel Tomes",
        },
        {
            type = "description",
            text =
                "Suppresses both Seasonal and Weekly Tome reward prompts. "
                .. "When automatic claiming is disabled, the blue Tome Action "
                .. "Widget remains visible until the rewards are handled.",
        },
        {
            type = "checkbox",
            name = "Replace Tome Reward Prompts",
            tooltip =
                "Suppresses the original Seasonal and Weekly Tamriel Tome reward prompts.",
            getFunc = function()
                return sv.tamrielTomes.replacePopup
            end,
            setFunc = function(value)
                sv.tamrielTomes.replacePopup = value
                Refresh()
            end,
            default = RPR.defaults.tamrielTomes.replacePopup,
        },
        {
            type = "checkbox",
            name = "Automatically Claim Tome Rewards",
            tooltip =
                "Claims available Tamriel Tome rewards automatically. When disabled, "
                .. "the Action Widget becomes the reminder.",
            getFunc = function()
                return sv.tamrielTomes.autoClaimRewards
            end,
            setFunc = function(value)
                sv.tamrielTomes.autoClaimRewards = value
                Refresh()
            end,
            default = RPR.defaults.tamrielTomes.autoClaimRewards,
        },

        -------------------------------------------------
        -- Golden Pursuits
        -------------------------------------------------

        {
            type = "header",
            name = "Golden Pursuits",
        },
        {
            type = "description",
            text =
                "Suppresses the original Golden Pursuits reward prompt. Safe rewards "
                .. "may be claimed automatically, while choice-based or unknown rewards "
                .. "remain available through the gold Action Widget for manual review.",
        },
        {
            type = "checkbox",
            name = "Replace Golden Pursuits Prompt",
            tooltip = "Suppresses the original Golden Pursuits claimable-reward prompt.",
            getFunc = function()
                return sv.goldenPursuits.replacePopup
            end,
            setFunc = function(value)
                sv.goldenPursuits.replacePopup = value
                Refresh()
            end,
            default = RPR.defaults.goldenPursuits.replacePopup,
        },
        {
            type = "checkbox",
            name = "Automatically Claim Safe Rewards",
            tooltip =
                "Claims only Golden Pursuits rewards identified as safe. "
                .. "Choice rewards and unknown reward types are left for manual review.",
            warning =
                "Unknown rewards are never automatically claimed and will remain "
                .. "available through the Action Widget.",
            getFunc = function()
                return sv.goldenPursuits.autoClaimSafeRewards
            end,
            setFunc = function(value)
                sv.goldenPursuits.autoClaimSafeRewards = value
                Refresh()
            end,
            default = RPR.defaults.goldenPursuits.autoClaimSafeRewards,
        },
        {
            type = "checkbox",
            name = "Show Action Widget for Manual Rewards",
            tooltip =
                "Displays the Golden Pursuits Action Widget when a reward requires player review.",
            getFunc = function()
                return sv.goldenPursuits.enableActionWidget
            end,
            setFunc = function(value)
                sv.goldenPursuits.enableActionWidget = value
                Refresh()
            end,
            default = RPR.defaults.goldenPursuits.enableActionWidget,
        },
        {
            type = "checkbox",
            name = "Prevent Automatic Activity Pinning",
            tooltip =
                "Stops Golden Pursuits activities from being pinned automatically. "
                .. "Activities can still be pinned manually.",
            getFunc = function()
                return sv.goldenPursuits.preventAutomaticActivityPinning
            end,
            setFunc = function(value)
                sv.goldenPursuits.preventAutomaticActivityPinning = value
                Refresh()
            end,
            default = RPR.defaults.goldenPursuits.preventAutomaticActivityPinning,
        },

        -------------------------------------------------
        -- Veterancy
        -------------------------------------------------

        {
            type = "header",
            name = "Veterancy Rewards",
        },
        {
            type = "description",
            text =
                "Veterancy rewards currently require no reward choice. They can "
                .. "be claimed automatically and do not use the Action Widget.",
        },
        {
            type = "checkbox",
            name = "Replace Veterancy Notification",
            tooltip =
                "Enables Reward Popups Reworked handling for available Veterancy rewards.",
            getFunc = function()
                return sv.veterancyRewards.replaceNotification
            end,
            setFunc = function(value)
                sv.veterancyRewards.replaceNotification = value
                Refresh()
            end,
            default = RPR.defaults.veterancyRewards.replaceNotification,
        },
        {
            type = "checkbox",
            name = "Automatically Claim Veterancy Rewards",
            tooltip = "Claims available Veterancy rewards automatically.",
            getFunc = function()
                return sv.veterancyRewards.autoClaimRewards
            end,
            setFunc = function(value)
                sv.veterancyRewards.autoClaimRewards = value
                Refresh()
            end,
            default = RPR.defaults.veterancyRewards.autoClaimRewards,
        },

        -------------------------------------------------
        -- Advanced
        -------------------------------------------------

        {
            type = "header",
            name = "Advanced",
        },
        {
            type = "checkbox",
            name = "Enable Debug Logging",
            tooltip =
                "Prints reward detection, suppression, claim attempts, and widget "
                .. "state changes to chat. Leave this disabled during normal gameplay.",
            getFunc = function()
                return sv.general.debug
            end,
            setFunc = function(value)
                sv.general.debug = value
            end,
            default = RPR.defaults.general.debug,
        },

        -------------------------------------------------
        -- About
        -------------------------------------------------

        {
            type = "header",
            name = "About",
        },
        {
            type = "description",
            text =
                "Reward Popups Reworked removes intrusive reward prompts, quietly "
                .. "handles safe reward claims, and uses one source-aware Action "
                .. "Widget whenever player attention is required."
                .. "\n\nVersion: " .. tostring(RPR.version)
                .. "\nAuthor: " .. tostring(RPR.author),
        },
    }

    LAM:RegisterOptionControls(PANEL_NAME, options)
end

-------------------------------------------------
-- Slash commands
-------------------------------------------------

function Settings:RegisterSlashCommands()
    SLASH_COMMANDS["/rpr"] = function(text)
        self:HandleSlash(text)
    end

    SLASH_COMMANDS["/rewardpopupsreworked"] = function(text)
        self:HandleSlash(text)
    end
end

function Settings:HandleSlash(text)
    text = string.lower(text or "")
    text = string.match(text, "^%s*(.-)%s*$") or ""

    if text == "" or text == "settings" then
        self:OpenPanel()

    elseif text == "claim" then
        if RPR.RewardManager
            and RPR.RewardManager.ClaimVisibleSafeRewards then

            RPR.RewardManager:ClaimVisibleSafeRewards()
        end

    elseif text == "tomes" or text == "tome" then
        if RPR.RewardManager
            and RPR.RewardManager.OpenSourceById then

            RPR.RewardManager:OpenSourceById("tamrielTomes")
        end

    elseif text == "golden" or text == "pursuits" then
        if RPR.RewardManager
            and RPR.RewardManager.OpenSourceById then

            RPR.RewardManager:OpenSourceById("goldenPursuits")
        end

    elseif text == "widget"
        or text == "preview"
        or text == "testwidget" then

        SetWidgetPreview(true)

    elseif text == "hidewidget"
        or text == "hidepreview" then

        SetWidgetPreview(false)

    elseif text == "resetwidget" then
        ResetWidgetPosition()

    elseif text == "lock" then
        if RPR.savedVars and RPR.savedVars.general then
            RPR.savedVars.general.lockActionWidget = true
            Refresh()
            Notify("Action Widget locked.")
        end

    elseif text == "unlock" then
        if RPR.savedVars and RPR.savedVars.general then
            RPR.savedVars.general.lockActionWidget = false
            Refresh()
            Notify("Action Widget unlocked.")
        end

    elseif text == "manual" then
        SetAutomaticClaiming(false)
        Notify("Manual Mode enabled.")

    elseif text == "automatic"
        or text == "auto" then

        SetAutomaticClaiming(true)
        Notify("Automatic Mode enabled.")

    elseif text == "welcome" then
        if RPR.savedVars and RPR.savedVars.general then
            RPR.savedVars.general.showWelcome = true

            Notify("Welcome dialog reset. Reloading UI...")

            zo_callLater(function()
                ReloadUI()
            end, 300)
        end

    else
        Notify(
            "Reward Popups Reworked v" .. tostring(RPR.version)
            .. "\n/rpr settings"
            .. "\n/rpr manual"
            .. "\n/rpr automatic"
            .. "\n/rpr widget"
            .. "\n/rpr hidewidget"
            .. "\n/rpr resetwidget"
            .. "\n/rpr lock"
            .. "\n/rpr unlock"
            .. "\n/rpr claim"
            .. "\n/rpr tomes"
            .. "\n/rpr golden"
            .. "\n/rpr welcome"
        )
    end
end

-------------------------------------------------
-- Open settings
-------------------------------------------------

function Settings:OpenPanel()
    if LibAddonMenu2
        and self.panel
        and LibAddonMenu2.OpenToPanel then

        LibAddonMenu2:OpenToPanel(self.panel)
        return
    end

    Notify(
        "Settings require LibAddonMenu-2.0. "
        .. "Slash commands are available through /rpr."
    )
end