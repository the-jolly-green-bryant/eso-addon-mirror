local SK = SwissKnife
local SKDE = SK.Data.equipmentData
local SKDA = SK.Data.abilities
local SKH = SK.HelperFunctions

local function DeepCopy(origin, copy)
    for key, value in pairs(SK.defaultSavedVars) do
        if type(value) == "table" then
            SKH.objectsDeepCopy(origin[key], copy[key], false)
        else
            copy[key] = origin[key]
        end
    end
end

local function CopyLists(origin, copy)
    SKH.objectsDeepCopy(
        origin["permanentUnwantedItemIds"],
        copy["permanentUnwantedItemIds"], false
    )
    SKH.objectsDeepCopy(
        origin["permanentUnwantedSetIds"],
        copy["permanentUnwantedSetIds"], false
    )
end

local function InitSavedVariables()
    -- Across accounts and global saved variables
    SK.accountsWideSV = ZO_SavedVars:NewAccountWide(
        SK.savedVarsTable,
        1,
        nil,
        SK.defaultSavedVars,
        nil,
        SK.accountsWideName
    )
    SK.globalSV = SK.accountsWideSV
    if SK.globalSV.permanentUnwantedSetIds == nil then SK.globalSV.permanentUnwantedSetIds = {} end
    if SK.globalSV.trackedSetsItems == nil then SK.globalSV.trackedSetsItems = {} end
    if SK.globalSV.permanentUnwantedItemIds == nil then SK.globalSV.permanentUnwantedItemIds = {} end
    if SK.globalSV.automationBlockAbilities == nil then SK.globalSV.automationBlockAbilities = {} end

    -- Set needed not global saved variables as current
    if SK.accountsWideSV.accountsWide then
        SK.accountsWideSV.accountWide = false
        SK.savedVars = SK.accountsWideSV
    else
        -- Account wide saved variables
        SK.accountWideSV = ZO_SavedVars:NewAccountWide(
            SK.savedVarsTable,
            1,
            nil,
            SK.defaultSavedVars
        )
        if SK.accountWideSV.accountWide then
            SK.accountWideSV.accountsWide = false
            SK.savedVars = SK.accountWideSV
        else
            -- Character saved variables
            SK.characterSV = ZO_SavedVars:New(
                SK.savedVarsTable,
                1,
                nil,
                SK.defaultSavedVars
            )
            SK.characterSV.accountsWide = false
            SK.characterSV.accountWide = false
            SK.savedVars = SK.characterSV
        end
    end
end

local function initDataSets()
    SK.FilterItemTypeNames = {GetString(SI_SK_ALL_ITEMS_TYPES_TEXT),}
    SK.SET_PARTS_DATA = {[ITEMTYPE_ARMOR] = {}, [ITEMTYPE_WEAPON] = {}}
    for _, data in ipairs(SKDE.SETS_DEFAULTS) do
	    local itemType, equipType, name, checked, icon, offsets = unpack(data)
        SK.SET_PARTS_DATA[itemType][equipType] = {}
	    SK.SET_PARTS_DATA[itemType][equipType].name = name
        SK.SET_PARTS_DATA[itemType][equipType].checked = checked
        SK.SET_PARTS_DATA[itemType][equipType].icon = icon
        SK.SET_PARTS_DATA[itemType][equipType].offsets = offsets
        table.insert(SK.FilterItemTypeNames, name)
        for preset, presetData in pairs(SKDE.ITEM_PRESETS) do
            if itemType == presetData.itemType and SKH.isValueInList(presetData.equipTypes, equipType) then
                SK.SET_PARTS_DATA[itemType][equipType].preset = preset
                break
            end
        end
	end
end

local function initQualityData()
    SK.QUALITY_MAP = {}
    for i = ITEM_FUNCTIONAL_QUALITY_MIN_VALUE, ITEM_FUNCTIONAL_QUALITY_MAX_VALUE do
        SK.QUALITY_MAP[i] = ZO_ColorDef:New(SKH.getQualityByValue(i, 1))
    end
    SK.QUALITY_CHOOSES = {}
    for i = ITEM_FUNCTIONAL_QUALITY_NORMAL, ITEM_FUNCTIONAL_QUALITY_MAX_VALUE do
        SK.QUALITY_CHOOSES[i] = SK.QUALITY_MAP[i]:Colorize(GetString("SI_ITEMQUALITY", i))
    end
end

local function initAccountsData()
    SK.AccName = GetDisplayName()
    SK.ServerCode = zo_strsplit(" ", GetWorldName())
    SK.ServerName = "["..SK.ServerCode.."]"
    if #SK.savedVars.playerServerCodes == 0 then
        SK.savedVars.playerServerCodes = {SK.ServerCode,}
    elseif not SKH.isValueInList(SK.savedVars.playerServerCodes, SK.ServerCode) then
        table.insert(SK.savedVars.playerServerCodes, SK.ServerCode)
        if #SK.savedVars.playerServerCodes == 2 then
    		SK.globalSV.trackItemsAccountsNames = {}
            SK.globalSV.trackedAccountsCollectionsItems = {}
            SK.globalSV.trackedSetsItems = {}
            SKH.showWarningDialogue(
                SK.COLOR.YELLOW:Colorize(GetString(SI_SK_AUT_NEED_UPDATE_TEXT))
            )
        end
    end
    SK.HasOneServer = #SK.savedVars.playerServerCodes <= 1
    if not SK.HasOneServer then
        SK.AccName = SK.AccName.." "..SK.ServerName
    end
    SK.PlayerName = GetUnitName("player")
    if SK.savedVars.trackItemsAccountsNames == nil then SK.savedVars.trackItemsAccountsNames = {} end
    if SK.savedVars.trackItemsAccountsNames[SK.AccName] == nil then SK.savedVars.trackItemsAccountsNames[SK.AccName] = SK.TRUE end
    SK.FilterServersNames = {GetString(SI_SK_AUT_ALL_TEXT),}
    for _, v in ipairs(SK.savedVars.playerServerCodes) do
        table.insert(SK.FilterServersNames, "["..v.."]")
    end
    SK.AllAccountsExcludeSelf = {}
    SK.FilterAccountsNames = {GetString(SI_SK_AUT_ALL_ACCOUNTS_TEXT),}
    for accName, _ in pairs(SK.savedVars.trackItemsAccountsNames) do
        local a = string.gsub(accName, "@", "", 1)
        table.insert(SK.FilterAccountsNames, a)
        if accName ~= SK.AccName then table.insert(SK.AllAccountsExcludeSelf, accName) end
    end
    SK.AccountsCharacters = {}
    local numChars = GetNumCharacters()
    for i = 1, numChars do
        SKH.setTableChild(SK.AccountsCharacters,
            {SK.AccName, zo_strformat("<<1>>", GetCharacterInfo(i))}, SK.TRUE
        )
    end
end

local function initAbilityData()
    if SK.savedVars.firstLoad then
        SKH.objectsDeepCopy(SKDA.DEFAULT_TRACKED_ABILITIES, SK.globalSV.automationBlockAbilities)
    end
    SK.FilterAbilityModes = {GetString("SI_SK_AUT_ABILITY_LIST_MODE_NAME", 0),}
    for _, value in pairs(SKDA.CAST_MODES) do
        table.insert(SK.FilterAbilityModes, GetString("SI_SK_AUT_ABILITY_LIST_MODE_NAME", value))
    end
    SK.automationBlockAbilitiesCache = {}
    SK.FilterAbilitySkillLines = {}
    table.insert(SK.FilterAbilitySkillLines, GetString(SI_SK_AUT_ABILITY_LIST_SKILL_LINE_NAME))
    for id, data in pairs(SK.globalSV.automationBlockAbilities) do
        local abilityId = id
        if data.ability ~= nil then abilityId = data.ability end
        local skillType, skillLineIndex, skillIndex, morphChoice = GetSpecificSkillAbilityKeysByAbilityId(abilityId)
        local modeName = GetString("SI_SK_AUT_ABILITY_LIST_MODE_NAME", data.mode)
        if data.hp ~= nil and data.mode ~= SKDA.CAST_MODES.PHASE then
            modeName = modeName .. " " .. GetString("SI_SK_AUT_ABILITY_LIST_MODE_NAME", SKDA.CAST_MODES.PHASE)
        end
        local abilityType
        if data.mode ~= SKDA.CAST_MODES.PHASE then
            if data.debuff == nil and data.allDebuffs == nil then
                if data.effect == nil then abilityType = SKDA.EFFECT.BUFF end
            else
                if data.effect == nil then abilityType = SKDA.EFFECT.CURSE end
            end
            if data.effect ~= nil then
                abilityType = data.effect
            end
            if data.hp ~= nil then abilityType = nil end
        end
        local castByPlayer = data.castByPlayer
        if castByPlayer == nil then castByPlayer = SK.FALSE end
        local abilityIcon = GetAbilityIcon(abilityId)
        local abilityName = GetAbilityName(abilityId)
        local skillLineId = GetSkillLineId(skillType, skillLineIndex)
        local skillLineName = GetSkillLineNameById(skillLineId)
        SK.automationBlockAbilitiesCache[id] = {
            abilityId = abilityId,
            abilityIcon = abilityIcon,
            abilityName = abilityName,
            skillType = skillType,
            skillLineIndex = skillLineIndex,
            skillIndex = skillIndex,
            morphChoice = morphChoice,
            skillLineName = skillLineName,
            abilityType = abilityType,
            castByPlayer = castByPlayer,
            modeName = modeName
        }
        if not SKH.isValueInList(SK.FilterAbilitySkillLines, skillLineName) then
            table.insert(SK.FilterAbilitySkillLines, skillLineName)
        end
    end
end

local function initPreloadParams()
    SK.isTrackedSetsItemsDataLoad = false
    SK.timeoutTrackedSetsItemsDataLoad = 10000
    SK.isAccountsCollectionsItemsDataLoad = false
    SK.timeoutAccountsCollectionsItemsDataLoad = 60000
    SK.companionsItemSetId = 0
    SK.companionsItemSetName = GetString(SI_ITEM_FORMAT_STR_COMPANION)
    SK.companionOwnerNamePrefix = "$Companion"
    SK.isWarningShowed = false
    SK.WHO_MUST_RECEIPT_DATA = {
        NO_ONE = "_no_one_character_",
        ANYONE = "_any_one_character_"
    }
    SK.clientAPIVersion = GetAPIVersion()
    SK.trackedSetsItemsCache = {}
    SK.CurrentTimedAbility = {}
    SK.dailyQuestDataCache = {}
    SK.destroyAction = 1
    SK.junkAction = 2
    for npcName, data in pairs(SK.savedVars.dailyQuestData) do
        SK.dailyQuestDataCache[data.questName] = npcName
        if data.anotherQuestsNames ~= nil then
            for _, questName in ipairs(data.anotherQuestsNames) do
                SK.dailyQuestDataCache[questName] = npcName
            end
        end
    end
    local inDarkBrotherhoodQuestZone = SKH.isDarkBrotherhoodQuestZone()
    if inDarkBrotherhoodQuestZone and SK.savedVars.hideDangerInteraction then
        SK.savedVars.previousHideDangerInteraction = true
        SK.savedVars.hideDangerInteraction = false
    else
        SK.savedVars.previousHideDangerInteraction = SK.savedVars.hideDangerInteraction
    end
    SK.INSECT_NAMES = {}
    for i = 1, 18 do table.insert(SK.INSECT_NAMES, GetString("SI_SK_I_INSECT", i)) end
    SKH.setPreventAttackingInnocents()
end

local function SavedVariablesPatcher()
    local versionSV = string.gsub(SK.savedVars.versionSV, "[.]", "")
    -- todo: patch guild data. next time delete
    local availableGuildsNames = SKH.getGuilds().Choices
    if not SKH.hasTableChild(SK.savedVars.defaultGuildData, {SK.AccName, "BankId"}) then
        local guildName = GetGuildName(SK.savedVars.defaultGuildBankId)
        if SKH.isValueInList(availableGuildsNames, guildName) then
            SKH.setTableChild(SK.savedVars.defaultGuildData, {SK.AccName, "BankId"}, SK.savedVars.defaultGuildBankId)
        end
    end
    if not SKH.hasTableChild(SK.savedVars.defaultGuildData, {SK.AccName, "ShopId"}) then
        local guildName = GetGuildName(SK.savedVars.defaultGuildShopId)
        if SKH.isValueInList(availableGuildsNames, guildName) then
            SKH.setTableChild(SK.savedVars.defaultGuildData, {SK.AccName, "ShopId"}, SK.savedVars.defaultGuildShopId)
        end
    end
    local function patchAutomationBlockAbilities()
        local automationBlockAbilities = {}
        SKH.objectsDeepCopy(SKDA.DEFAULT_TRACKED_ABILITIES, automationBlockAbilities)
        local safeParams = {"disabled", "correctionInterval", "isFT", "hp"}
        for id, data in pairs(SK.globalSV.automationBlockAbilities) do
            if automationBlockAbilities[id] ~= nil then
                for _, key in ipairs(safeParams) do
                    if data[key] ~= nil then automationBlockAbilities[id][key] = data[key] end
                end
                if tonumber(automationBlockAbilities[id]["correctionInterval"]) == tonumber(SK.savedVars.abilityEndCorrectionInterval) then
                    automationBlockAbilities[id]["correctionInterval"] = nil
                end
                if automationBlockAbilities[id]["newHP"] ~= nil then
                    automationBlockAbilities[id]["hp"] = automationBlockAbilities[id]["newHP"]
                    automationBlockAbilities[id]["newHP"] = nil
                end
            end
        end
        SK.globalSV.automationBlockAbilities = {}
        SKH.objectsDeepCopy(automationBlockAbilities, SK.globalSV.automationBlockAbilities)
        -- for recache abilities
        initAbilityData()
    end

    if tonumber(versionSV) < 940 then
        SK.savedVars.transferButtonGuildBankEnabled = nil
        SK.savedVars.transferStylishButtonGuildBankEnabled = nil
        SK.savedVars.versionSV = "0.94.0"
        SKH.sendMessageToChat(
            SK.COLORED_PREFIXES.SKO,
            SK.COLOR.WHITE:Colorize(GetString(SI_SK_OPT_PATCH_MESSAGE)),
            SK.COLOR.ORANGE:Colorize(SK.savedVars.versionSV)
        )
        versionSV = 940
    end
    if tonumber(versionSV) < 942 then
        patchAutomationBlockAbilities()
        SK.savedVars.versionSV = "0.94.2"
        SKH.sendMessageToChat(
            SK.COLORED_PREFIXES.SKO,
            SK.COLOR.WHITE:Colorize(GetString(SI_SK_OPT_PATCH_MESSAGE)),
            SK.COLOR.ORANGE:Colorize(SK.savedVars.versionSV)
        )
        versionSV = 942
    end
    if tonumber(versionSV) < 943 then
        SK.savedVars.versionSV = "0.94.3"
        patchAutomationBlockAbilities()
        SK.globalSV.automationBlockAbilities[35441] = nil
        SK.globalSV.automationBlockAbilities[33211].buff = nil
        SK.globalSV.automationBlockAbilities[35434].buff = nil
        SKH.sendMessageToChat(
            SK.COLORED_PREFIXES.SKO,
            SK.COLOR.WHITE:Colorize(GetString(SI_SK_OPT_PATCH_MESSAGE)),
            SK.COLOR.ORANGE:Colorize(SK.savedVars.versionSV)
        )
        versionSV = 943
    end
    if tonumber(versionSV) < 945 then
        SK.savedVars.versionSV = "0.94.5"
        SKH.sendMessageToChat(
            SK.COLORED_PREFIXES.SKO,
            SK.COLOR.WHITE:Colorize(GetString(SI_SK_OPT_PATCH_MESSAGE)),
            SK.COLOR.ORANGE:Colorize(SK.savedVars.versionSV)
        )
        versionSV = 945
    end
    if tonumber(versionSV) < 950 then
        SK.savedVars.versionSV = "0.95.0"
        patchAutomationBlockAbilities()
        if SK.savedVars.preventAccidentalInteractionInterval == 4000 or
            SK.savedVars.preventAccidentalInteractionInterval == 3000
        then
            SK.savedVars.preventAccidentalInteractionInterval = 2500
        end
        SKH.sendMessageToChat(
            SK.COLORED_PREFIXES.SKO,
            SK.COLOR.WHITE:Colorize(GetString(SI_SK_OPT_PATCH_MESSAGE)),
            SK.COLOR.ORANGE:Colorize(SK.savedVars.versionSV)
        )
        versionSV = 950
    end
    if tonumber(versionSV) < 952 then
        SK.savedVars.versionSV = "0.95.2"
        patchAutomationBlockAbilities()
        SKH.sendMessageToChat(
            SK.COLORED_PREFIXES.SKO,
            SK.COLOR.WHITE:Colorize(GetString(SI_SK_OPT_PATCH_MESSAGE)),
            SK.COLOR.ORANGE:Colorize(SK.savedVars.versionSV)
        )
        versionSV = 952
    end
    if tonumber(versionSV) < 957 then
        SK.savedVars.versionSV = "0.95.7"
        patchAutomationBlockAbilities()
        SKH.sendMessageToChat(
            SK.COLORED_PREFIXES.SKO,
            SK.COLOR.WHITE:Colorize(GetString(SI_SK_OPT_PATCH_MESSAGE)),
            SK.COLOR.ORANGE:Colorize(SK.savedVars.versionSV)
        )
        versionSV = 957
    end
    if tonumber(versionSV) < 986 then
        SK.savedVars.versionSV = "0.98.6"
        if SK.savedVars.trackCompanionItems and SK.globalSV.trackedSetsItems[SK.companionsItemSetId] ~= nil then
            for accName, accData in pairs(SK.globalSV.trackedSetsItems[SK.companionsItemSetId]) do
                for ownerName, ownerData in pairs(accData) do
                    if ownerData[BAG_COMPANION_WORN] ~= nil then
                        SK.globalSV.trackedSetsItems[SK.companionsItemSetId][accName][ownerName] = nil
                    end
                end
            end
            SKH.showWarningDialogue(
                SK.COLOR.YELLOW:Colorize(GetString(SI_SK_AUT_NEED_UPDATE_986_TEXT))
            )
        end
        SKH.sendMessageToChat(
            SK.COLORED_PREFIXES.SKO,
            SK.COLOR.WHITE:Colorize(GetString(SI_SK_OPT_PATCH_MESSAGE)),
            SK.COLOR.ORANGE:Colorize(SK.savedVars.versionSV)
        )
        versionSV = 986
    end
    if tonumber(versionSV) < 992 then
        SK.savedVars.versionSV = "0.99.2"
        patchAutomationBlockAbilities()
        SK.savedVars.previousHideDangerInteraction = SK.savedVars.hideDangerInteraction
        SKH.sendMessageToChat(
            SK.COLORED_PREFIXES.SKO,
            SK.COLOR.WHITE:Colorize(GetString(SI_SK_OPT_PATCH_MESSAGE)),
            SK.COLOR.ORANGE:Colorize(SK.savedVars.versionSV)
        )
        versionSV = 992
    end
    if tonumber(versionSV) < 994 then
        SK.savedVars.versionSV = "0.99.4"
        patchAutomationBlockAbilities()
        SK.savedVars.trackedAccountsCollectionsStyles = nil
        SKH.sendMessageToChat(
            SK.COLORED_PREFIXES.SKO,
            SK.COLOR.WHITE:Colorize(GetString(SI_SK_OPT_PATCH_MESSAGE)),
            SK.COLOR.ORANGE:Colorize(SK.savedVars.versionSV)
        )
        versionSV = 994
    end
    if tonumber(versionSV) < 996 then
        SK.savedVars.versionSV = "0.99.6"
        patchAutomationBlockAbilities()
        SKH.sendMessageToChat(
            SK.COLORED_PREFIXES.SKO,
            SK.COLOR.WHITE:Colorize(GetString(SI_SK_OPT_PATCH_MESSAGE)),
            SK.COLOR.ORANGE:Colorize(SK.savedVars.versionSV)
        )
        versionSV = 996
    end
    if tonumber(versionSV) < 1001 then
        SK.savedVars.versionSV = "1.00.1"
        SK.savedVars.filterUnwantedItemAfterLoot = SK.savedVars.destroyUnwantedItemAfterLoot
        SK.savedVars.destroyUnwantedItemAfterLoot = nil
        SK.savedVars.destroyNewOnlyUnwantedItem = nil
        SK.savedVars.enableLogoutOrQuitConfirmation = nil
        SKH.sendMessageToChat(
            SK.COLORED_PREFIXES.SKO,
            SK.COLOR.WHITE:Colorize(GetString(SI_SK_OPT_PATCH_MESSAGE)),
            SK.COLOR.ORANGE:Colorize(SK.savedVars.versionSV)
        )
        versionSV = 1001
    end
    if tonumber(versionSV) < 1002 then
        patchAutomationBlockAbilities()
        SK.savedVars.versionSV = "1.00.2"
        versionSV = 1002
        SKH.sendMessageToChat(
            SK.COLORED_PREFIXES.SKO,
            SK.COLOR.WHITE:Colorize(GetString(SI_SK_OPT_PATCH_MESSAGE)),
            SK.COLOR.ORANGE:Colorize(SK.savedVars.versionSV)
        )
    end
    if tonumber(versionSV) < 1010 then
        SK.savedVars.bankTransferOptions[0] = nil
        SK.savedVars.bankTransferOptions[1] = nil
        SK.savedVars.versionSV = "1.01.0"
        versionSV = 1010
        SKH.sendMessageToChat(
            SK.COLORED_PREFIXES.SKO,
            SK.COLOR.WHITE:Colorize(GetString(SI_SK_OPT_PATCH_MESSAGE)),
            SK.COLOR.ORANGE:Colorize(SK.savedVars.versionSV)
        )
    end
    if tonumber(versionSV) < 1020 then
        SK.savedVars.versionSV = "1.02.0"
        patchAutomationBlockAbilities()
        SK.globalSV.automationBlockAbilities[183241].isFT = SK.TRUE
        SKH.sendMessageToChat(
            SK.COLORED_PREFIXES.SKO,
            SK.COLOR.WHITE:Colorize(GetString(SI_SK_OPT_PATCH_MESSAGE)),
            SK.COLOR.ORANGE:Colorize(SK.savedVars.versionSV)
        )
        versionSV = 1020
    end
    if tonumber(versionSV) < 1030 then
        SK.savedVars.versionSV = "1.03.0"
        patchAutomationBlockAbilities()
        SK.globalSV.automationBlockAbilities[183555].disabled = SK.TRUE
        SK.globalSV.automationBlockAbilities[186229].disabled = SK.TRUE
        SK.globalSV.automationBlockAbilities[186234].disabled = SK.TRUE
        SKH.sendMessageToChat(
            SK.COLORED_PREFIXES.SKO,
            SK.COLOR.WHITE:Colorize(GetString(SI_SK_OPT_PATCH_MESSAGE)),
            SK.COLOR.ORANGE:Colorize(SK.savedVars.versionSV)
        )
        versionSV = 1030
    end
    if tonumber(versionSV) < 1041 then
        SK.savedVars.versionSV = "1.04.1"
        if SK.savedVars.companionUnsafeEntryMode == nil then
            SK.savedVars.companionUnsafeEntryMode = SK.COMPANION_PREVENT_MODE.WARNING
        end
        SKH.sendMessageToChat(
            SK.COLORED_PREFIXES.SKO,
            SK.COLOR.WHITE:Colorize(GetString(SI_SK_OPT_PATCH_MESSAGE)),
            SK.COLOR.ORANGE:Colorize(SK.savedVars.versionSV)
        )
        versionSV = 1041
    end
    if tonumber(versionSV) < 1060 then
        SK.savedVars.versionSV = "1.06.0"
        SKH.sendMessageToChat(
            SK.COLORED_PREFIXES.SKO,
            SK.COLOR.WHITE:Colorize(GetString(SI_SK_OPT_PATCH_MESSAGE)),
            SK.COLOR.ORANGE:Colorize(SK.savedVars.versionSV)
        )
        versionSV = 1060
        SKH.showWarningDialogue(GetString(SI_SK_UPDATE_MESSAGE_1060), SK.savedVars.versionSV)
    end
    if tonumber(versionSV) < 1061 then
        SK.savedVars.versionSV = "1.06.1"
        SK.globalSV.mainDialogueData.point = SK.globalSV.mainDialogueData.relativeTo
        SK.globalSV.mainDialogueData.relativeTo = nil
        SKH.sendMessageToChat(
            SK.COLORED_PREFIXES.SKO,
            SK.COLOR.WHITE:Colorize(GetString(SI_SK_OPT_PATCH_MESSAGE)),
            SK.COLOR.ORANGE:Colorize(SK.savedVars.versionSV)
        )
        versionSV = 1061
        SKH.showWarningDialogue(GetString(SI_SK_UPDATE_MESSAGE), SK.savedVars.versionSV)
    end
end

local function keybindPatcher()
    for _, data in ipairs(PLAYER_INVENTORY.guildBankWithdrawTabKeybindButtonGroup) do
        if data.keybind == "UI_SHORTCUT_TERTIARY" then
            data.visible =  function()
                if not SK.savedVars.showGuildBankChooser then
                    return GetSelectedGuildBankId() ~= nil
                else
                    return false
                end
            end
        end
    end
    for _, data in ipairs(PLAYER_INVENTORY.guildBankDepositTabKeybindButtonGroup) do
        if data.keybind == "UI_SHORTCUT_TERTIARY" then
            data.visible =  function()
                if not SK.savedVars.showGuildBankChooser then
                    return GetSelectedGuildBankId() ~= nil
                else
                    return false
                end
            end
        end
    end
end

local function otherPatcher()
end

local function InitGlobalsData()
    initAccountsData()
    initQualityData()
    initAbilityData()
    initDataSets()
    initPreloadParams()
    keybindPatcher()
    otherPatcher()
end


-- Export
SK.Variables = {
	InitSavedVariables = InitSavedVariables,
	SavedVariablesPatcher = SavedVariablesPatcher,
	InitGlobalsData = InitGlobalsData,
    DeepCopy = DeepCopy,
    CopyLists = CopyLists
}