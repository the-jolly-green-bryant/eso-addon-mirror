QuickBankSettings = {}

function QuickBankSettings.Init()
    local LAM = LibAddonMenu2
    local panelData = {
        type = "panel",
        name = "Quick Bank",
        displayName = "Quick Bank",
        author = "Ranckor90",
        version = "1.0.1",
        registerForRefresh = true,
        registerForDefaults = true
    }

    local optionsData = {
        {
            type = "checkbox",
            name = "Deposit Gold",
            getFunc = function() return QuickBank.savedVars.depositGold end,
            setFunc = function(value) QuickBank.savedVars.depositGold = value end,
        },
        {
            type = "checkbox",
            name = "Deposit Alliance Points",
            getFunc = function() return QuickBank.savedVars.depositAP end,
            setFunc = function(value) QuickBank.savedVars.depositAP = value end,
        },
        {
            type = "checkbox",
            name = "Deposit Writ Vouchers",
            getFunc = function() return QuickBank.savedVars.depositWrits end,
            setFunc = function(value) QuickBank.savedVars.depositWrits = value end,
        },
        {
            type = "checkbox",
            name = "Deposit Tel Var",
            getFunc = function() return QuickBank.savedVars.depositTelVar end,
            setFunc = function(value) QuickBank.savedVars.depositTelVar = value end,
        },
    }

    LAM:RegisterAddonPanel("QuickBankOptions", panelData)
    LAM:RegisterOptionControls("QuickBankOptions", optionsData)
end