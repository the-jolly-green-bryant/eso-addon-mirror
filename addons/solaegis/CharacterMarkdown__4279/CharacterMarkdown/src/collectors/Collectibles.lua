-- CharacterMarkdown - Collectibles Data Collector
-- Composition logic moved from API layer

local CM = CharacterMarkdown

-- =====================================================
-- COLLECTIBLES DATA
-- =====================================================

local function CollectCollectiblesData()
    -- Use API layer granular functions (composition at collector level)
    local esoPlus = CM.api.collectibles.IsESOPlus()

    local data = {}

    -- ESO Plus status
    data.esoPlus = esoPlus or false

    -- Collections
    -- Map simple keys to category constants
    local catMap = {
        mounts = COLLECTIBLE_CATEGORY_TYPE_MOUNT,
        pets = COLLECTIBLE_CATEGORY_TYPE_VANITY_PET,
        costumes = COLLECTIBLE_CATEGORY_TYPE_COSTUME,
        skins = COLLECTIBLE_CATEGORY_TYPE_SKIN,
        polymorphs = COLLECTIBLE_CATEGORY_TYPE_POLYMORPH,
        emotes = COLLECTIBLE_CATEGORY_TYPE_EMOTE,
        mementos = COLLECTIBLE_CATEGORY_TYPE_MEMENTO,
        personalities = COLLECTIBLE_CATEGORY_TYPE_PERSONALITY,
        hats = COLLECTIBLE_CATEGORY_TYPE_HAT,
        hair = COLLECTIBLE_CATEGORY_TYPE_HAIR,
        headMarkings = COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING,
        bodyMarkings = COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING,
        facialAccessories = COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY,
        piercings = COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY,
        assistants = COLLECTIBLE_CATEGORY_TYPE_ASSISTANT,
    }

    data.collections = {}
    local totalCollectibles = 0
    local unlockedCollectibles = 0

    for key, typeConst in pairs(catMap) do
        local collection = CM.api.collectibles.GetUnlockedCollectibles(typeConst)
        data.collections[key] = collection

        -- Calculate summary statistics
        if collection then
            totalCollectibles = totalCollectibles + (collection.total or 0)
            unlockedCollectibles = unlockedCollectibles + (collection.count or 0)
        end
    end

    -- Add summary statistics
    data.summary = {
        total = totalCollectibles,
        unlocked = unlockedCollectibles,
        completionPercent = totalCollectibles > 0 and math.floor((unlockedCollectibles / totalCollectibles) * 100) or 0,
    }

    -- Housing
    data.housing = CM.api.collectibles.GetHousingInfo()

    return data
end

CM.collectors.CollectCollectiblesData = CollectCollectiblesData

-- =====================================================
-- DLC ACCESS
-- =====================================================

local function CollectDLCAccess()
    -- Use API layer granular functions (composition at collector level)
    local esoPlus = CM.api.collectibles.IsESOPlus()

    local data = {
        hasESOPlus = esoPlus or false,
        accessible = {},
        locked = {},
    }

    -- If ESO Plus is active, all DLCs are accessible
    if data.hasESOPlus then
        -- Still check zones to populate the accessible list
        -- Common DLC/Chapter zone IDs (these are representative - may need expansion)
        local dlcZones = {
            -- Major DLCs and Chapters
            { id = 181, name = "Orsinium" }, -- Wrothgar
            { id = 382, name = "Hew's Bane" }, -- Thieves Guild
            { id = 383, name = "Gold Coast" }, -- Dark Brotherhood
            { id = 534, name = "Vvardenfell" }, -- Morrowind Chapter
            { id = 980, name = "Summerset" }, -- Summerset Chapter
            { id = 1086, name = "Northern Elsweyr" }, -- Elsweyr Chapter
            { id = 1207, name = "Southern Elsweyr" }, -- Dragonhold DLC
            { id = 1283, name = "Western Skyrim" }, -- Greymoor Chapter
            { id = 1383, name = "The Reach" }, -- Markarth DLC
            { id = 1451, name = "Blackwood" }, -- Blackwood Chapter
            { id = 1537, name = "The Deadlands" }, -- Deadlands DLC
            { id = 1591, name = "High Isle" }, -- High Isle Chapter
            { id = 1657, name = "Galen" }, -- Firesong DLC
            { id = 1718, name = "Necrom" }, -- Necrom Chapter
            { id = 1803, name = "Apocrypha" }, -- Scribes of Fate DLC
        }

        for _, zone in ipairs(dlcZones) do
            local zoneName = CM.SafeCall(GetZoneNameById, zone.id)
            if zoneName and zoneName ~= "" then
                table.insert(data.accessible, zoneName)
            elseif zone.name then
                table.insert(data.accessible, zone.name)
            end
        end
    else
        -- Check each zone for access
        local dlcZones = {
            { id = 181, name = "Orsinium" },
            { id = 382, name = "Hew's Bane" },
            { id = 383, name = "Gold Coast" },
            { id = 534, name = "Vvardenfell" },
            { id = 980, name = "Summerset" },
            { id = 1086, name = "Northern Elsweyr" },
            { id = 1207, name = "Southern Elsweyr" },
            { id = 1283, name = "Western Skyrim" },
            { id = 1383, name = "The Reach" },
            { id = 1451, name = "Blackwood" },
            { id = 1537, name = "The Deadlands" },
            { id = 1591, name = "High Isle" },
            { id = 1657, name = "Galen" },
            { id = 1718, name = "Necrom" },
            { id = 1803, name = "Apocrypha" },
        }

        for _, zone in ipairs(dlcZones) do
            local hasAccess = CM.api.collectibles.CheckDLCAccess(zone.id)
            local zoneName = CM.SafeCall(GetZoneNameById, zone.id)
            local displayName = (zoneName and zoneName ~= "") and zoneName or zone.name

            if hasAccess then
                table.insert(data.accessible, displayName)
            else
                table.insert(data.locked, displayName)
            end
        end

        -- Sort lists alphabetically
        table.sort(data.accessible)
        table.sort(data.locked)
    end

    return data
end

CM.collectors.CollectDLCAccess = CollectDLCAccess

-- =====================================================
-- HOUSING DATA
-- =====================================================

local function CollectHousingData()
    -- Use API layer granular functions (composition at collector level)
    local housingInfo = CM.api.collectibles.GetHousingInfo()

    local data = {
        primary = nil,
        owned = {},
        summary = {
            totalOwned = 0,
            totalAvailable = (housingInfo.owned and housingInfo.owned.total) or 0,
            hasPrimary = false,
        },
    }

    if housingInfo then
        -- Primary house
        if housingInfo.primary and housingInfo.primary.id and housingInfo.primary.id > 0 then
            data.primary = {
                id = housingInfo.primary.id,
                name = housingInfo.primary.name or "Unknown",
            }
            data.summary.hasPrimary = true
        end

        -- Owned houses
        if housingInfo.owned and housingInfo.owned.list then
            for _, house in ipairs(housingInfo.owned.list) do
                table.insert(data.owned, {
                    id = house.id,
                    name = house.name or "Unknown",
                    nickname = house.nickname,
                })
            end
            data.summary.totalOwned = #data.owned
        end
    end

    return data
end

CM.collectors.CollectHousingData = CollectHousingData

CM.DebugPrint("COLLECTOR", "Collectibles collector module loaded")
