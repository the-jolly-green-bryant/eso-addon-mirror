FCOCO = FCOCO or  {}
local FCOCompanion = FCOCO
if not FCOCompanion.isCompanionUnlocked then return end
------------------------------------------------------------------------------------------------------------------------

local tins = table.insert
local strfor = string.format
local addonVars = FCOCompanion.addonVars

------------------------------------------------------------------------------------------------------------------------
-- SETTINGS
------------------------------------------------------------------------------------------------------------------------
--Read the SavedVariables
function FCOCompanion.getSettings()
    local serverName    = GetWorldName()
    local svName        = addonVars.addonSavedVariablesName
    local svPerToonName = addonVars.addonSavedVariablesNamePerToon
    local svVersion     = addonVars.addonSavedVarsVersion
    local svVersionPerToon = addonVars.addonSavedVarsVersionPerToon
    local svForAllTable = addonVars.addonSavedVarsForAllTable
    local svNormalTable = addonVars.addonSavedVarsNormalTable

    --The default values for the language and save mode
    local defaultsSettings = {
        language 	 		    = 1, --Standard: English
        saveMode     		    = 2, --Standard: Account wide settings
    }

    --Pre-set the deafult values
    local defaults = {
        alwaysUseClientLanguage			    = true,

        companionIsSummoned                 = false,
        lastCompanionId                     = 1, --Bastian Helix, companionDefId 1
        unSummonAtCraftingTables            = true,
        reSummonAfterCraftingTables         = true,
        unSummonAtBanks                     = false,
        reSummonAfterBanks                  = false,
        unSummonAtVendors                   = false,
        reSummonAfterVendors                = false,
        unSummonAtFishing                   = false,
        reSummonAfterFishing                = false,
        reSummonAfterFishingDelay           = 5000,
        disableCompanionAtCompass           = false,
        unSummonAtCrouching                 = false,
        unSummonAtCrouchingNoCombat         = false,
        reSummonAfterCrouching              = false,
        reSummonAfterCrouchingDelay         = 5000,

        --Companion Junk
        useAccountWideCompanionJunk         = false,
        enableCompanionItemJunk             = false,
        autoJunkMarkSameCompanionItemsInBags = false,
        companionItemsJunked    = {},
    }
    FCOCompanion.settingsVars.defaults = defaults

    --Explicity per toon saved settings, e.g. junk items of companions
    local defaultsPerToon = {
        enableCompanionItemJunk = false,
        autoJunkMarkSameCompanionItemsInBags = false,
        companionItemsJunked    = {},
    }
    FCOCompanion.settingsVars.defaultsPerToon = defaultsPerToon

    --=============================================================================================================
    --	LOAD USER SETTINGS
    --=============================================================================================================
    --Load the user's settings from SavedVariables file -> Account wide of basic version 999 at first
    FCOCompanion.settingsVars.defaultSettings = ZO_SavedVars:NewAccountWide( svName, 999, svForAllTable, defaultsSettings, serverName )

    --Check, by help of basic version 999 settings, if the settings should be loaded for each character or account wide
    --Use the current addon version to read the settings now
    if (FCOCompanion.settingsVars.defaultSettings.saveMode == 1) then
        FCOCompanion.settingsVars.settings = ZO_SavedVars:NewCharacterIdSettings( svName, svVersion , svNormalTable, defaults, serverName )
    else
        FCOCompanion.settingsVars.settings = ZO_SavedVars:NewAccountWide( svName, svVersion, svNormalTable, defaults, serverName )
    end
    FCOCompanion.settingsVars.settingsPerToon = ZO_SavedVars:NewCharacterIdSettings( svPerToonName, svVersionPerToon , svNormalTable, defaultsPerToon, serverName )

    --=============================================================================================================
end

local outputToChatMigrateOptionsTexts = {
    ["companionItemsJunked"] = FCOCO_LAM_JUNK_MIGRATE_TO_ACC_STR,
}

--[[ Does not work with itemInstanceId, only works with itemId!
local function outputTransferedItemToChat(value, svOptionName)
    if value == nil then return end
    local valueForString = value

    local textConstant = outputToChatMigrateOptionsTexts[svOptionName]
    if textConstant == nil then return end

    if svOptionName == "companionItemsJunked" then
        local itemLink = (LibSets ~= nil and LibSets.buildItemLink(value)) or strfor("|H1:item:%d:%d:50:0:0:0:0:0:0:0:0:0:0:0:0:%d:%d:0:0:%d:0|h|h", value, 366, ITEMSTYLE_NONE, 0, 10000)
        if itemLink and itemLink ~= "" then
            valueForString = itemLink
        end
    end

    d(string.format(GetString(textConstant), valueForString))
end
]]

function FCOCompanion.AnyCompanionJunkItemsToMigrate(toAccount)
--d("[FCOCompanion.AnyCompanionJunkItemsToMigrate - toAccount: " ..tostring(toAccount))
    if toAccount == nil then return false end
    --Character SavedVars
    local settingsPerToon = FCOCompanion.settingsVars.settingsPerToon
    --Account SavedVars
    local settingsAccount = FCOCompanion.settingsVars.settings

    if settingsAccount == nil then return false end
    if settingsPerToon == nil then return false end


    --Migrate to the account wide
    if toAccount == true then
        for itemInstanceId, isJunked  in pairs(settingsPerToon.companionItemsJunked) do
            if isJunked then
                if not settingsAccount.companionItemsJunked[itemInstanceId] then
--d(">found missing itemInstanceId: " ..tostring(itemInstanceId))
                    return true
                end
            end
        end
        return false

    else
        for itemInstanceId, isJunked in pairs(settingsAccount.companionItemsJunked) do
            if isJunked then
                if not settingsPerToon.companionItemsJunked[itemInstanceId] then
                    return true
                end
            end
        end
        return false
    end
end

function FCOCompanion.MigrateSVData(characterId, toAccount, mergeOrOverwrite, svOptionName)
--d("[FCOCompanion.MigrateSVData - toAccount: " ..tostring(toAccount) .. ", mergeOrOverwrite: " ..tostring(mergeOrOverwrite) .. ", svOptionName: " ..tostring(svOptionName))
    if characterId == nil or toAccount == nil or mergeOrOverwrite == nil or svOptionName == nil then return nil, nil end

    --Character SavedVars
    local settingsPerToon = FCOCompanion.settingsVars.settingsPerToon
    --Account SavedVars
    local settingsAccount = FCOCompanion.settingsVars.settings

    if settingsAccount == nil then return nil, nil end
    if settingsPerToon == nil then return nil, nil end

    local svOption = settingsAccount[svOptionName]
    local svOptionType = type(svOption)
    if svOptionType == "nil" then return nil, nil end
    local svOptionChar = settingsPerToon[svOptionName]
    local svOptionTypeChar = type(svOptionChar)
    if svOptionTypeChar == "nil" or svOptionTypeChar ~= svOptionType then return nil, nil end

    local tableResetDone = false
    --------------------------------------------------------------------------------------------------------------------
    --From character to account
    if toAccount == true then
        if svOptionType == "table" then
            local optionsTransferred = 0
            for itemInstanceId, isJunked in pairs(settingsPerToon[svOptionName]) do
--d(">itemInstanceId: " ..tostring(itemInstanceId) .. ", isJunked: " ..tostring(isJunked))
                if isJunked and (not mergeOrOverwrite or (mergeOrOverwrite  == true and not settingsAccount[svOptionName][itemInstanceId])) then
                    if mergeOrOverwrite == false and not tableResetDone then
                        tableResetDone = true
                        settingsAccount[svOptionName] = {}
                    end

                    settingsAccount[svOptionName][itemInstanceId] = true
                    --outputTransferedItemToChat(itemInstanceId, svOptionName)
                    optionsTransferred = optionsTransferred + 1
                end
            end
            return optionsTransferred > 0, optionsTransferred
        else
            if mergeOrOverwrite == true then
                --Merge
                --> 1 entry cannot be merged, just overwritten
                return false, 0
            else
                --Overwrite
                settingsAccount[svOptionName] = settingsPerToon[svOptionName]
                --outputTransferedItemToChat(settingsAccount[svOptionName] , svOptionName)
                return true, 1
            end
        end

    --------------------------------------------------------------------------------------------------------------------
    --From account to character
    else
        if svOptionType == "table" then
            local optionsTransferred = 0
            for itemInstanceId, isJunked in pairs(settingsAccount[svOptionName]) do
                if isJunked and (not mergeOrOverwrite or (mergeOrOverwrite  == true and not settingsPerToon[svOptionName][itemInstanceId])) then
                    if mergeOrOverwrite == false and not tableResetDone then
                        tableResetDone = true
                        settingsPerToon[svOptionName] = {}
                    end
                    settingsPerToon[svOptionName][itemInstanceId] = true
                    --outputTransferedItemToChat(itemInstanceId, svOptionName)
                    optionsTransferred = optionsTransferred + 1
                end
            end
            return optionsTransferred > 0, optionsTransferred
        else
            if mergeOrOverwrite == true then
                --Merge
                --> 1 entry cannot be merged, just overwritten
                return false, 0
            else
                --Overwrite
                settingsPerToon[svOptionName] = settingsAccount[svOptionName]
                --outputTransferedItemToChat(settingsPerToon[svOptionName] , svOptionName)
                return true, 1
            end
        end
    end
    return false, 0
end