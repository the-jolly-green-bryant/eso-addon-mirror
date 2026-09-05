local owa = OWAssistant

local function CreateDeconstructProfile()
    return {
        enabled = false,
        maxQuality = ITEM_QUALITY_NORMAL,

        noTrait = false,
        crafted = false,
        ornate = false,
        intricate = false,
        reconstructed = false,
        tradable = false,
        fromBank = false,
        nirnhoned = false,

        researchMode = "none",
    }
end

local function GetSavedVariableDefaults()
    local defaults = owa.GetAccountDefaults()
    local savedRoot = _G["OWAssistantSavedVariables"]

    if not savedRoot then
        return defaults
    end

    local displayName = GetDisplayName()
    local worldName = GetWorldName()
    local worldData = savedRoot[worldName]
    local currentSettings = worldData
        and worldData[displayName]
        and worldData[displayName]["$AccountWide"]

    if currentSettings then
        return defaults
    end

    local oldData = savedRoot["Default"]
    local oldSettings = oldData
        and oldData[displayName]
        and oldData[displayName]["$AccountWide"]

    if not oldSettings then
        return defaults
    end

    local migratedDefaults = ZO_ShallowTableCopy(oldSettings)
    return migratedDefaults
end

function owa.Initialize()
    owa.savedVariables = ZO_SavedVars:NewAccountWide(
        "OWAssistantSavedVariables",
        1,
        GetWorldName(),
        GetSavedVariableDefaults()
    )

    if not owa.savedVariables.language then
        owa.savedVariables.language = owa.GetLanguageCode()
    end

    SafeAddString(
        SI_OWA_ADDON_NAME,
        owa.GetString("ADDON_NAME"),
        1
    )
    SafeAddString(
        SI_BINDING_NAME_OWA_DECONSTRUCT,
        owa.GetString("MASS_DECONSTRUCT"),
        1
    )

    owa.LoadModules()
    owa.CreateSettings()
end

function owa.GetAccountDefaults()
    return {
        language = owa.GetLanguageCode(),
        accountWide = true,

        repairEnabled = false,
        deconstructEnabled = true,
        deconstructChatMessages = true,

        repairAndRecharge = {
            autoRepair = false,
            repairThreshold = 10,
            useCrownRepairKitsFirst = false,
            repairInCombat = false,
            repairResourceTracking = true,
            repairResourceThreshold = 10,
            repairChatMessages = true,

            autoRecharge = false,
            rechargeThreshold = 10,
            useCrownSoulGemsFirst = false,
            rechargeInCombat = false,
            rechargeResourceTracking = true,
            rechargeResourceThreshold = 10,
            rechargeChatMessages = true,
        },

        deconstructProfiles = {
            weapon = CreateDeconstructProfile(),
            clothing = CreateDeconstructProfile(),
            jewelry = CreateDeconstructProfile(),
            enchanting = CreateDeconstructProfile(),
        },
    }
end

function owa.LoadModules()
    local savedVariables = owa.savedVariables

    if savedVariables.repairEnabled then
        owa.Repair.Initialize()
        owa.Repair.CreateSettings()
    end

    if savedVariables.deconstructEnabled then
        owa.Deconstruct.Initialize()
        owa.Deconstruct.CreateSettings()
    end
end
