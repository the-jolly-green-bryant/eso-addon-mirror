-----------------------------------------------------------------------------------
-- Addon Name: Rulebased Inventory
-- Creator: TaxTalis, demawi
-- Addon Ideal: user-defined rule-based actions for inventory application
-- Addon Creation Date: September 11, 2018
--
-- File Name: AccountSetting.lua
-- File Description: This file contains the functions to edit account settings
-- Load Order Requirements: after RulebaseInventory
--
-----------------------------------------------------------------------------------

-- imports
local RbI = RulebasedInventory

-- statics
local accountSettings -- loaded account settings

RbI.class.AccountSetting = {

    -- constructor
    New = function(settingTable)
        local self = {}

        self.GetRaw = function()
            return settingTable
        end

        return self
    end,

    Get = function()
        return accountSettings
    end,

    -- static
    Load = function()
        -- default savedVariable
        local accountDefault = {
            settings = {
                safetyrule = true,
                fcois = (FCOIS ~= nil),
                taskStartOutput = true,
                taskActionOutput = true,
                taskSummaryOutput = true,
                taskFinishOutput = true,
                actionDelay = 1,
                taskDelay = 100,
                maxDeconstruct = 100,
                contextMenu = true,
                immediateExecutionAtCraftStation = true,
                casesensitiverules = false,
                startupitemcheck = false,
                outputcolor = "dbcd8a",
                -- usingRuleSets = _ -- will be set below
                -- usingProfiles = _ -- will be set below
                usingCurrencies = true,
				autoOpenBank = "Never",
				autoOpenShop = "Never",
				autoOpenAssistants = false,
				autoCloseBank = "Never",
				autoCloseShop = "Never",
				autoCloseFence = "Never",
				autoCloseCraft = "Never",
				despawnAssistants = false,
				autoClosePreventionKey = "NOT SET",
				autoOpenPreventionKey = "NOT SET",
                homebankingMode = "Off",
                identifyHomebank = false,
            },
            rules = {},
            constants = {},
            profiles = {},
            ruleSets = {},
            tasks = {},
        }
        accountSettings = RbI.class.AccountSetting.New(ZO_SavedVars:NewAccountWide("RbIAccount", RbI.savedGlobalVariableVersion, nil, accountDefault))
        local settings = accountSettings.GetRaw().settings
        if (settings.usingRuleSets == nil) then
            settings.usingRuleSets = RbI.utils.count(accountSettings.GetRaw().ruleSets) > 0
        end
        if (settings.usingProfiles == nil) then
            settings.usingProfiles = RbI.utils.count(accountSettings.GetRaw().profiles) > 0
        end
		-- NoQuest removed as it proved to be unreliable as quest return chatter options weren't labeled correctly
		if (settings.autoOpenShop == "NoQuest") then settings.autoOpenShop = "NoDialog"	end

        return accountSettings
    end
}