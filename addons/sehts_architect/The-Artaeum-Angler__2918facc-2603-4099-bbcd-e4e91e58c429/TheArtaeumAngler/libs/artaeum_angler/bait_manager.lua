(function()
    return function(Addon)
        Addon.BaitManager = Addon.BaitManager or {}
    
        local BaitManager = Addon.BaitManager
        local MAX_SELECTOR_ROWS = 6
    
        local WATER_TYPE_PRIORITIES = {
            foul = { "crawlers", "fish_roe", "simple" },
            lake = { "guts", "minnows", "simple" },
            mystic = { "worms", "chub", "simple" },
            ocean = { "worms", "chub", "simple" },
            oily = { "crawlers", "fish_roe", "simple" },
            river = { "insect_parts", "shad", "simple" },
            unknown = { "simple" },
        }
    
        local function contains(value, needle)
            return string.find(value, needle, 1, true) ~= nil
        end
    
        local function normalizeWaterType(rawWaterType)
            if type(rawWaterType) ~= "string" then
                return "unknown"
            end
    
            local lowered = string.lower(rawWaterType)
    
            if contains(lowered, "foul") then
                return "foul"
            end
    
            if contains(lowered, "lake") then
                return "lake"
            end
    
            if contains(lowered, "mystic") or contains(lowered, "artaeum") then
                return "mystic"
            end
    
            if contains(lowered, "oily") or contains(lowered, "clockwork") then
                return "oily"
            end
    
            if contains(lowered, "salt") or contains(lowered, "ocean") then
                return "ocean"
            end
    
            if contains(lowered, "river") then
                return "river"
            end
    
            return "unknown"
        end
    
        BaitManager.NormalizeWaterType = normalizeWaterType
    
        local function classifyLure(name, icon)
            local loweredName = string.lower(name or "")
            local loweredIcon = string.lower(icon or "")
    
            if contains(loweredName, "insect") or contains(loweredIcon, "insect") then
                return "insect_parts"
            end
    
            if contains(loweredName, "shad") or contains(loweredIcon, "shad") then
                return "shad"
            end
    
            if contains(loweredName, "gut") or contains(loweredIcon, "gut") then
                return "guts"
            end
    
            if contains(loweredName, "minnow") or contains(loweredIcon, "minnow") then
                return "minnows"
            end
    
            if contains(loweredName, "worm") or contains(loweredIcon, "worm") then
                return "worms"
            end
    
            if contains(loweredName, "chub") or contains(loweredIcon, "chub") then
                return "chub"
            end
    
            if contains(loweredName, "crawler") or contains(loweredIcon, "crawler") then
                return "crawlers"
            end
    
            if contains(loweredName, "roe") or contains(loweredIcon, "roe") then
                return "fish_roe"
            end
    
            if contains(loweredName, "simple") or contains(loweredIcon, "simple") then
                return "simple"
            end
    
            return nil
        end
    
        local function collectLures()
            local entries = {}
    
            if type(GetNumFishingLures) ~= "function" or type(GetFishingLureInfo) ~= "function" then
                return entries
            end
    
            local currentLureIndex = type(GetFishingLure) == "function" and GetFishingLure() or 0
    
            for lureIndex = 1, GetNumFishingLures() do
                local name, icon, stackCount = GetFishingLureInfo(lureIndex)
                local baitKey = classifyLure(name, icon)
    
                if baitKey then
                    entries[#entries + 1] = {
                        baitKey = baitKey,
                        count = stackCount or 0,
                        icon = icon or Addon.Textures.emptyBait,
                        isEquipped = lureIndex == currentLureIndex,
                        lureIndex = lureIndex,
                        name = name or Addon.Strings.noBait,
                    }
                end
            end
    
            return entries
        end
    
        local function sortEntries(entries, waterType)
            local orderedRows = {}
            local seen = {}
            local priorities = WATER_TYPE_PRIORITIES[waterType] or WATER_TYPE_PRIORITIES.unknown
    
            for _, baitKey in ipairs(priorities) do
                for _, entry in ipairs(entries) do
                    if entry.baitKey == baitKey and entry.count > 0 then
                        orderedRows[#orderedRows + 1] = entry
                        seen[entry.lureIndex] = true
                    end
                end
            end
    
            for _, entry in ipairs(entries) do
                if entry.count > 0 and not seen[entry.lureIndex] then
                    orderedRows[#orderedRows + 1] = entry
                end
            end
    
            return orderedRows
        end
    
        local function buildRecommendedModel(entries, waterType)
            local orderedRows = sortEntries(entries, waterType)
            local currentItemId = type(GetNextBaitItemId) == "function" and GetNextBaitItemId() or nil
            local recommended = orderedRows[1]
            local state = waterType == "unknown" and "unknown" or "ready"
    
            if not recommended then
                state = "empty"
            end
    
            while #orderedRows > MAX_SELECTOR_ROWS do
                orderedRows[#orderedRows] = nil
            end
    
            return {
                currentItemId = currentItemId,
                currentLureIndex = type(GetFishingLure) == "function" and GetFishingLure() or 0,
                recommendedCount = recommended and recommended.count or 0,
                recommendedIcon = recommended and recommended.icon or Addon.Textures.emptyBait,
                recommendedItemId = recommended and recommended.itemId or nil,
                recommendedLureIndex = recommended and recommended.lureIndex or nil,
                recommendedName = recommended and recommended.name or Addon.Strings.noBait,
                rows = orderedRows,
                state = state,
                stateColor = Addon.StateColors[state] or Addon.StateColors.ready,
                waterType = waterType,
                waterTypeLabel = Addon.WaterTypeLabels[waterType] or Addon.WaterTypeLabels.unknown,
            }
        end
    
        function BaitManager.BuildModel(rawWaterType)
            return buildRecommendedModel(collectLures(), normalizeWaterType(rawWaterType))
        end
    
        function BaitManager.ApplyChoice(rowData)
            if not rowData or rowData.count <= 0 or not rowData.lureIndex then
                return false
            end
    
            local currentLureIndex = type(GetFishingLure) == "function" and GetFishingLure() or 0
    
            if currentLureIndex == rowData.lureIndex then
                return false
            end
    
            -- Fishing lures are exposed as indexed choices by the game, so use the
            -- native lure selector path instead of duplicating inventory equip logic.
            if type(SetFishingLure) == "function" then
                SetFishingLure(rowData.lureIndex)
                return true
            end
    
            return false
        end
    end
    
end)()(_G["TheArtaeumAngler"])
