OWAssistant = OWAssistant or {}
OWAssistant.name = "OWAssistant"

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

        research = false,
        researchMode = "all",
    }
end

OWAssistant.defaults = {
    language = "en",
    accountWide = true,

    repairEnabled = true,
    deconstructEnabled = true,
    merchantEnabled = true,
    bankingEnabled = true,

    deconstructProfiles = {
        weapon = CreateDeconstructProfile(),
        clothing = CreateDeconstructProfile(),
        jewelry = CreateDeconstructProfile(),
        enchanting = CreateDeconstructProfile(),
    },
}

function OWA_Assistant_Initialize()
    OWA_SavedVariables = ZO_SavedVars:NewAccountWide(
        "OWAssistantSavedVariables",
        1,
        nil,
        OWA_AccountDefaults()
    )

    OWA_LoadModules()
    OWA_CreateSettings()
end

function OWA_AccountDefaults()
    return {
        language = "en",
        accountWide = true,

        repairEnabled = false,
        deconstructEnabled = true,
        merchantEnabled = false,
        bankingEnabled = false,

        deconstructProfiles = {
            weapon = CreateDeconstructProfile(),
            clothing = CreateDeconstructProfile(),
            jewelry = CreateDeconstructProfile(),
            enchanting = CreateDeconstructProfile(),
        },
    }
end

function OWA_LoadModules()

    if OWA_SavedVariables.deconstructEnabled then
        OWDeconstruct_Initialize()
        OWDeconstruct_CreateSettings()
    end

    OWA_SavedVariables.repairEnabled = false
    OWA_SavedVariables.merchantEnabled = false
    OWA_SavedVariables.bankingEnabled = false

    -- if OWA_SavedVariables.repairEnabled then
    --     OWRepair_Initialize()
    --     OWRepair_CreateSettings()
    -- end

    -- if OWA_SavedVariables.merchantEnabled then
    --     OWMerchant_Initialize()
    --     OWMerchant_CreateSettings()
    -- end

    -- if OWA_SavedVariables.bankingEnabled then
    --     OWBanking_Initialize()
    --     OWBanking_CreateSettings()
    -- end
end