-- Settings menu.
function ArcanistJobGauge.LoadSettings()
    local LAM = LibAddonMenu2

    local panelData = {
        type = "panel",
        name = ArcanistJobGauge.menuName,
        displayName = ArcanistJobGauge.Colorize(ArcanistJobGauge.menuName),
        author = ArcanistJobGauge.Colorize(ArcanistJobGauge.author, "92e721"),
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LAM:RegisterAddonPanel(ArcanistJobGauge.menuName, panelData)

    local optionsTable = {}

    table.insert(
        optionsTable,
        {
            type = "checkbox",
            name = "Account Wide",
            tooltip = "Use the same settings throughout the entire account - instead of per character",
            getFunc = function()
                return ArcanistJobGauge.savedVars.accountWide
            end,
            setFunc = function(v)
                ArcanistJobGauge.characterSavedVars.accountWide = v
                ArcanistJobGauge.accountSavedVars.accountWide = v
            end,
            width = "full",
            requiresReload = true,
        }
    )

    -- Category. --
    table.insert(optionsTable, {
        type = "header",
        name = ZO_HIGHLIGHT_TEXT:Colorize("Settings"),
        width = "full",
    })

    table.insert(optionsTable, {
        type = "description",
        title = nil,
        text = "Pretty way to display how many crux you have in UI",
        width = "full",
    })

    table.insert(
        optionsTable,
        {
            type = "checkbox",
            name = "Enabled",
            tooltip =
            "Use the same settings throughout the entire account - instead of per character. Visible only on the Arcanist class",
            getFunc = function()
                return ArcanistJobGauge.savedVars.enabled
            end,
            setFunc = function(isEnabled)
                ArcanistJobGauge.savedVars.enabled = isEnabled
                ArcanistJobGauge.updateVisibility()
            end,
            width = "full", --or "half",
            requiresReload = false,
        }
    )

    table.insert(
        optionsTable,
        {
            type = "checkbox",
            name = "Lock",
            tooltip = "Locks ability to drag the job gauge",
            getFunc = function() return ArcanistJobGauge.savedVars.isLocked end,
            setFunc = function(isLocked)
                ArcanistJobGauge.savedVars.isLocked = isLocked
                ArcanistJobGaugeWindowLabelBG:SetMouseEnabled(not isLocked)
            end,
            default = true,
            width = "full",
        }
    )

    table.insert(
        optionsTable,
        {
            type = "checkbox",
            name = "Simplified",
            tooltip = "Displays the simplified version of the gauge",
            getFunc = function() return ArcanistJobGauge.savedVars.simplified end,
            setFunc = function(simplified)
                ArcanistJobGauge.savedVars.simplified = simplified
                ArcanistJobGauge.updateSimplified()
            end,
            default = true,
            width = "full",
        }
    )

    table.insert(
        optionsTable,
        {
            type = "checkbox",
            name = "Hide out of combat",
            tooltip = "Displays only during combat",
            getFunc = function() return ArcanistJobGauge.savedVars.hideCombat end,
            setFunc = function(hideCombat)
                ArcanistJobGauge.savedVars.hideCombat = hideCombat
                ArcanistJobGauge.updateCombat()
            end,
            default = true,
            width = "full",
        }
    )

    LAM:RegisterOptionControls(ArcanistJobGauge.menuName, optionsTable)
end
