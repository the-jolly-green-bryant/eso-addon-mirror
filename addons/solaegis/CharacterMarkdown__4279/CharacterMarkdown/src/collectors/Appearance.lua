-- CharacterMarkdown - Appearance Data Collector

local CM = CharacterMarkdown

local function CollectAppearanceData()
    local appearanceApi = CM.api and CM.api.appearance
    if not appearanceApi then
        return nil
    end

    return {
        outfit = appearanceApi.GetEquippedOutfit(),
        slots = appearanceApi.GetOutfitSlots(),
        dyes = appearanceApi.GetDyeCollectionSummary(),
        mount = appearanceApi.GetActiveMount(),
        active = appearanceApi.GetActiveCollectibles(),
    }
end

CM.collectors.CollectAppearanceData = CollectAppearanceData

CM.DebugPrint("COLLECTOR", "Appearance collector module loaded")
