-- StashAndDash.lua
-- A humble banking assistant for Elder Scrolls Online
-- Author: @Downehr
local ADDON_NAME = "StashAndDash"

local defaults = {
    goldThreshold = 5000,
    enableAutoPrompt = true
}

local function OnBankOpen()
    if not _G["StashAndDash_SavedVars"].enableAutoPrompt then
        return
    end

    local gold = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
    local excess = gold - _G["StashAndDash_SavedVars"].goldThreshold

    if excess > 0 then
        zo_callLater(function()
            if SCENE_MANAGER:IsShowing("bank") then
                ZO_Dialogs_ShowDialog("STASHANDDASH_CONFIRM", {
                    depositAmount = excess
                })
            else
                d("Bank scene not showing. Cannot show deposit dialog.")
            end
        end, 200)
    end
end

local function CreateSettingsMenu()
    local LAM = LibAddonMenu2
    local panelName = ADDON_NAME .. "_SettingsPanel"
    local panelData = {
        type = "panel",
        name = "Stash 'n Dash",
        author = "@Downehr",
        version = "1.0",
        registerForRefresh = true,
        registerForDefaults = true
    }

    LAM:RegisterAddonPanel(panelName, panelData)

    local optionsTable = {{
        type = "slider",
        name = "Gold Threshold",
        tooltip = "Gold to keep on your character. Excess will be prompted for deposit.",
        min = 0,
        max = 100000,
        step = 1000,
        getFunc = function()
            return _G["StashAndDash_SavedVars"].goldThreshold
        end,
        setFunc = function(value)
            _G["StashAndDash_SavedVars"].goldThreshold = value
        end
    }, {
        type = "checkbox",
        name = "Enable Auto Prompt",
        tooltip = "Enable or disable the gold deposit prompt.",
        getFunc = function()
            return _G["StashAndDash_SavedVars"].enableAutoPrompt
        end,
        setFunc = function(value)
            _G["StashAndDash_SavedVars"].enableAutoPrompt = value
        end
    }}

    LAM:RegisterOptionControls(panelName, optionsTable)
end

local function OnAddOnLoaded(event, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    _G["StashAndDash_SavedVars"] = ZO_SavedVars:NewAccountWide("StashAndDashSavedVars", 1, "Settings", defaults)
    CreateSettingsMenu()

    ZO_Dialogs_RegisterCustomDialog("STASHANDDASH_CONFIRM", {
        title = {
            text = "Deposit Gold?"
        },
        mainText = {
            text = function(dialog)
                return string.format(
                    "This one sees you carry more than %s gold.\nShall this one deposit %s in the bank?",
                    ZO_CurrencyControl_FormatCurrency(_G["StashAndDash_SavedVars"].goldThreshold),
                    ZO_CurrencyControl_FormatCurrency(dialog.data.depositAmount))
            end
        },
        buttons = {{
            text = "Yes",
            callback = function(dialog)
                local amount = dialog.data.depositAmount
                if IsBankOpen() then
                    DepositCurrencyIntoBank(CURT_MONEY, amount)
                    d("Deposited " .. ZO_CurrencyControl_FormatCurrency(amount) .. " gold.")
                else
                    d("Bank not open, cannot deposit.")
                end
            end
        }, {
            text = "No"
        }},
        mustChoose = true,
        canQueue = true,
        blockDialogReleaseOnPress = true,
        setup = function(dialog)
            SCENE_MANAGER:Show("bank")
        end
    })

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_OPEN_BANK, OnBankOpen)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
