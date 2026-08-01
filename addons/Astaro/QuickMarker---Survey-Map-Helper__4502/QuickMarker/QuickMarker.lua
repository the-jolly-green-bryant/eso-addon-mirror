local NAME = "QuickMarker"

local QuickMarker = {
    savedVars = nil,
    texturePool = nil,
    activeWorldPins = {},
    camera = {},
    distanceLabel = nil,
}

-- Survey node keywords for detection
local SURVEY_KEYWORDS = {
    ["Lush"] = true,      -- Alchemy, Clothier
    ["Rich"] = true,      -- Blacksmith, Jewelry
    ["Protean"] = true,   -- Enchanting
    ["Pristine"] = true,  -- Woodworking
}

ZO_CreateStringId("SI_BINDING_NAME_QUICK_MARKER_BASE", "Place Base (red)")
ZO_CreateStringId("SI_BINDING_NAME_QUICK_MARKER_RANGE", "Place Range (yellow)")
ZO_CreateStringId("SI_BINDING_NAME_QUICK_MARKER_DELETE", "Delete nearest marker")
ZO_CreateStringId("SI_BINDING_NAME_QUICK_MARKER_SURVEY", "Open Survey Containers")
ZO_CreateStringId("SI_BINDING_NAME_QUICK_MARKER_STATS", "Show Statistics Window")

-- ==========================================
-- MARKER ATLAS
-- ==========================================
-- Texture atlas definitions for marker.dds
-- Atlas structure: 8 columns × 2 rows
-- Row 0: digits 1-8
-- Row 1: digits 9, 0, letter 'm', base marker, range marker

local MarkerAtlas = {
    file = "QuickMarker/marker.dds",
    columns = 8,
    rows = 2,
    digits = {}
}

-- Digit textures (1-8)
for i = 1, 8 do
    MarkerAtlas.digits[i] = {
        file = MarkerAtlas.file,
        left = (i - 1) / MarkerAtlas.columns,
        right = i / MarkerAtlas.columns,
        top = 0,
        bottom = 0.5,
    }
end

-- Digit 9 (first in row 1)
MarkerAtlas.digits[9] = {
    file = MarkerAtlas.file,
    left = 0 / MarkerAtlas.columns,
    right = 1 / MarkerAtlas.columns,
    top = 0.5,
    bottom = 1.0,
}

-- Digit 0 (second in row 1)
MarkerAtlas.digits[0] = {
    file = MarkerAtlas.file,
    left = 1 / MarkerAtlas.columns,
    right = 2 / MarkerAtlas.columns,
    top = 0.5,
    bottom = 1.0,
}

-- Letter 'm' for meters
MarkerAtlas.letterM = {
    file = MarkerAtlas.file,
    left = 2 / MarkerAtlas.columns,
    right = 3 / MarkerAtlas.columns,
    top = 0.5,
    bottom = 1.0,
}

-- Base marker (red)
MarkerAtlas.base = {
    file = MarkerAtlas.file,
    left = 3 / MarkerAtlas.columns,
    right = 4 / MarkerAtlas.columns,
    top = 0.5,
    bottom = 1.0,
}

-- Range marker (yellow)
MarkerAtlas.range = {
    file = MarkerAtlas.file,
    left = 4 / MarkerAtlas.columns,
    right = 5 / MarkerAtlas.columns,
    top = 0.5,
    bottom = 1.0,
}

function MarkerAtlas:GetDigit(digit)
    return self.digits[digit]
end

function MarkerAtlas:GetMarker(markerType)
    if markerType == "base" then
        return self.base
    elseif markerType == "range" then
        return self.range
    end
    return nil
end

QuickMarker.Atlas = MarkerAtlas

-- ==========================================
-- NODE COUNTER
-- ==========================================

-- Survey report names by craft type (for inventory check)
local SURVEY_REPORT_NAMES = {
    alchemist = "Alchemist Survey:",
    blacksmith = "Blacksmith Survey:",
    clothier = "Clothier Survey:",
    enchanting = "Enchanter Survey:",
    jewelry = "Jewelry Crafting Survey:",
    woodworking = "Woodworker Survey:",
}

-- Check if player has survey report for given survey name
function QuickMarker:HasSurveyReport(surveyName)
    if not surveyName then return false end

    local bagId = BAG_BACKPACK
    local slotCount = GetBagSize(bagId)

    for slotIndex = 0, slotCount - 1 do
        local itemName = GetItemName(bagId, slotIndex)
        -- Match exact survey name (e.g. "Alchemist Survey: Craglorn I")
        if itemName == surveyName then
            local stackCount = GetSlotStackSize(bagId, slotIndex)
            if stackCount > 0 then
                return true
            end
        end
    end

    return false
end

-- Count survey reports for given survey name
function QuickMarker:CountSurveyReports(surveyName)
    if not surveyName then return 0 end

    local bagId = BAG_BACKPACK
    local slotCount = GetBagSize(bagId)
    local totalCount = 0

    for slotIndex = 0, slotCount - 1 do
        local itemName = GetItemName(bagId, slotIndex)
        -- Match exact survey name (e.g. "Alchemist Survey: Craglorn I")
        if itemName == surveyName then
            local stackCount = GetSlotStackSize(bagId, slotIndex)
            totalCount = totalCount + stackCount
        end
    end

    return totalCount
end

-- Survey node item IDs by craft type
local SURVEY_ITEMS = {
    alchemist = {
        [30158] = true, -- Lady's Smock
        [30159] = true, -- Wormwood
        [30160] = true, -- Bugloss
        [30161] = true, -- Corn Flower
        [30162] = true, -- Dragonthorn
        [30163] = true, -- Mountain Flower
        [30164] = true, -- Columbine
		[30157] = true, -- Blessed Thistle
    },
    blacksmith = {
        [71198] = true, -- Rubedite Ore
        [56862] = true, -- Fortified Nirncrux (Craglorn)
        [56863] = true, -- Potent Nirncrux (Craglorn)
    },
    clothier = {
        [71200] = true, -- Raw Ancestor Silk
        [71239] = true, -- Rubedo Leather
        [56862] = true, -- Fortified Nirncrux (Craglorn)
        [56863] = true, -- Potent Nirncrux (Craglorn)
    },
    jewelry = {
        [135145] = true, -- Platinum Dust
        [56862] = true, -- Fortified Nirncrux (Craglorn)
        [56863] = true, -- Potent Nirncrux (Craglorn)
    },
    woodworking = {
        [71199] = true, -- Ruby Ash Wood
        [56862] = true, -- Fortified Nirncrux (Craglorn)
        [56863] = true, -- Potent Nirncrux (Craglorn)
    },
    enchanting = {
        [45831] = true, -- Oko
        [45832] = true, -- Makko
        [45833] = true, -- Deni
        [45834] = true, -- Okoma
        [45837] = true, -- Kuoko
        [45838] = true, -- Rakeipa
        [45839] = true, -- Dekeipa
        [45840] = true, -- Meip
        [45841] = true, -- Haoko
        [45842] = true, -- Deteri
        [45843] = true, -- Okori
        [45846] = true, -- Oru
        [45847] = true, -- Taderi
        [45848] = true, -- Makderi
        [45849] = true, -- Kaderi
        [45850] = true, -- Ta
        [45851] = true, -- Jejota
        [45852] = true, -- Denata
        [45853] = true, -- Rekuta
        [45854] = true, -- Kuta
        [45855] = true, -- Jora
        [45856] = true, -- Porade
        [45857] = true, -- Jera
        [64508] = true, -- Jehade
        [64509] = true, -- Rejera
        [68340] = true, -- Itade
        [68341] = true, -- Repora
    },
}

-- Minimum quantity to count as survey node (not regular node)
local MIN_SURVEY_QUANTITY = {
    alchemist = 4,
    blacksmith = 18,
    clothier = 18,
    jewelry = 18,
    woodworking = 18,
    enchanting = 5, -- 5+ unique rune types (not quantity!)
}

-- Track last decrement time per base marker
local lastDecrementTime = {}

-- Track unique runes collected for enchanting (per base marker)
local enchantingRuneCollection = {}

-- Buffer for enchanting debug messages (per base marker)
local enchantingDebugBuffer = {}

-- Node counter function
function QuickMarker:OnLootReceived(eventCode, receivedBy, itemName, quantity, soundCategory, lootType, lootedBySelf, isPickpocketLoot, questItemIcon, itemId, isStolen)
    if not lootedBySelf then return end
    if lootType ~= LOOT_TYPE_ITEM then return end

    -- Get player position
    local zoneId, playerX, playerY, playerZ = GetUnitRawWorldPosition("player")
    if not playerX then return end

    -- Find nearest base marker within 50m
    local nearestBase = nil
    local nearestDistance = 5000 -- 50m in cm
    local nearestIndex = nil

    for i, marker in ipairs(self.savedVars.markerList) do
        if marker.type == "base" and marker.worldX and marker.zoneId == zoneId then
            local dx = playerX - marker.worldX
            local dy = playerY - marker.worldY
            local dz = playerZ - marker.worldZ
            local distance = math.sqrt(dx * dx + dy * dy + dz * dz)

            if distance < nearestDistance then
                nearestDistance = distance
                nearestBase = marker
                nearestIndex = i
            end
        end
    end

    -- Check if this is an enchanting rune (for debug purposes)
    local isEnchantingRune = SURVEY_ITEMS.enchanting and SURVEY_ITEMS.enchanting[itemId]

    -- Only process if there's a base marker nearby
    if not nearestBase or not nearestBase.surveyInfo then
        -- DEBUG: Buffer enchanting rune info (DISABLED)
        --[[
        if isEnchantingRune then
            if not enchantingDebugBuffer[0] then
                enchantingDebugBuffer[0] = {
                    runes = {},
                    reason = nil,
                    distance = nil,
                    lastRuneTime = GetGameTimeMilliseconds()
                }
            end

            local buffer = enchantingDebugBuffer[0]
            local now = GetGameTimeMilliseconds()

            -- Check if this is a new node (more than 1 second since last rune)
            if now - buffer.lastRuneTime > 1000 then
                -- Print previous buffer if exists
                if #buffer.runes > 0 then
                    for _, runeInfo in ipairs(buffer.runes) do
                        d("|c00FFFF[Enchanting Debug]|r " .. runeInfo.name .. " x" .. runeInfo.quantity)
                    end
                    d("|cFF0000NOT TRACKED.|r Reason: " .. buffer.reason)
                end

                -- Reset buffer for new node
                buffer.runes = {}
                buffer.reason = nil
                buffer.distance = nil
            end

            buffer.lastRuneTime = now
            table.insert(buffer.runes, {name = itemName, quantity = quantity})

            if not nearestBase then
                buffer.reason = "No base marker within 50m"
            elseif not nearestBase.surveyInfo then
                buffer.reason = "Base marker has no survey info"
            end

            -- Schedule output after 200ms delay
            EVENT_MANAGER:UnregisterForUpdate("QuickMarker_EnchantingDebug_0")
            EVENT_MANAGER:RegisterForUpdate("QuickMarker_EnchantingDebug_0", 200, function()
                EVENT_MANAGER:UnregisterForUpdate("QuickMarker_EnchantingDebug_0")
                if #buffer.runes > 0 then
                    for _, runeInfo in ipairs(buffer.runes) do
                        d("|c00FFFF[Enchanting Debug]|r " .. runeInfo.name .. " x" .. runeInfo.quantity)
                    end
                    d("|cFF0000NOT TRACKED.|r Reason: " .. buffer.reason)
                    buffer.runes = {}
                end
            end)
        end
        --]]
        return
    end

    local craft = nearestBase.surveyInfo.craft

    -- Check if this item belongs to this craft type
    if not SURVEY_ITEMS[craft] or not SURVEY_ITEMS[craft][itemId] then
        -- DEBUG: Buffer enchanting rune info (DISABLED)
        --[[
        if isEnchantingRune then
            if not enchantingDebugBuffer[0] then
                enchantingDebugBuffer[0] = {
                    runes = {},
                    reason = nil,
                    distance = nil,
                    lastRuneTime = GetGameTimeMilliseconds()
                }
            end

            local buffer = enchantingDebugBuffer[0]
            local now = GetGameTimeMilliseconds()

            -- Check if this is a new node (more than 1 second since last rune)
            if now - buffer.lastRuneTime > 1000 then
                -- Print previous buffer if exists
                if #buffer.runes > 0 then
                    for _, runeInfo in ipairs(buffer.runes) do
                        d("|c00FFFF[Enchanting Debug]|r " .. runeInfo.name .. " x" .. runeInfo.quantity)
                    end
                    d("|cFF0000NOT TRACKED.|r Reason: " .. buffer.reason)
                end

                -- Reset buffer for new node
                buffer.runes = {}
                buffer.reason = nil
                buffer.distance = nil
            end

            buffer.lastRuneTime = now
            table.insert(buffer.runes, {name = itemName, quantity = quantity})
            buffer.reason = "Base marker craft is '" .. craft .. "', not 'enchanting'"

            -- Schedule output after 200ms delay
            EVENT_MANAGER:UnregisterForUpdate("QuickMarker_EnchantingDebug_0")
            EVENT_MANAGER:RegisterForUpdate("QuickMarker_EnchantingDebug_0", 200, function()
                EVENT_MANAGER:UnregisterForUpdate("QuickMarker_EnchantingDebug_0")
                if #buffer.runes > 0 then
                    for _, runeInfo in ipairs(buffer.runes) do
                        d("|c00FFFF[Enchanting Debug]|r " .. runeInfo.name .. " x" .. runeInfo.quantity)
                    end
                    d("|cFF0000NOT TRACKED.|r Reason: " .. buffer.reason)
                    buffer.runes = {}
                end
            end)
        end
        --]]
        return
    end

    -- Special handling for enchanting (count unique rune types)
    if craft == "enchanting" then
        -- Initialize collection for this base marker
        if not enchantingRuneCollection[nearestIndex] then
            enchantingRuneCollection[nearestIndex] = {
                runes = {},
                runeData = {}, -- Store itemName and quantity for each rune
                lastRuneTime = GetGameTimeMilliseconds(),
                tracked = false -- Flag to track only once per node
            }
        end

        local collection = enchantingRuneCollection[nearestIndex]
        local now = GetGameTimeMilliseconds()

        -- Check if this is a new node (more than 1 second since last rune)
        if now - collection.lastRuneTime > 1000 then
            -- Reset collection for new node
            collection.runes = {}
            collection.runeData = {}
            collection.tracked = false
        end

        -- Update last rune time (this rune was just collected)
        collection.lastRuneTime = now

        -- Add this rune to collection
        collection.runes[itemId] = true

        -- Store rune data (accumulate quantity if same rune collected multiple times)
        if not collection.runeData[itemId] then
            collection.runeData[itemId] = {name = itemName, quantity = 0}
        end
        collection.runeData[itemId].quantity = collection.runeData[itemId].quantity + quantity

        -- DEBUG: Removed individual rune output - will show all at once after 200ms

        -- Count unique runes
        local uniqueRuneCount = 0
        for _ in pairs(collection.runes) do
            uniqueRuneCount = uniqueRuneCount + 1
        end

        -- If we have 5+ unique runes and haven't tracked yet, schedule delayed tracking
        if uniqueRuneCount >= MIN_SURVEY_QUANTITY[craft] and not collection.tracked then
            -- Cancel previous timer if exists
            if collection.trackTimer then
                EVENT_MANAGER:UnregisterForUpdate("QuickMarker_EnchantingTrack_" .. nearestIndex)
            end

            -- Schedule tracking after 200ms to allow all runes to arrive
            collection.trackTimer = true
            collection.distanceToBase = nearestDistance -- Store distance for debug output
            EVENT_MANAGER:RegisterForUpdate("QuickMarker_EnchantingTrack_" .. nearestIndex, 200, function()
                EVENT_MANAGER:UnregisterForUpdate("QuickMarker_EnchantingTrack_" .. nearestIndex)
                collection.trackTimer = nil

                if collection.tracked then return end -- Already tracked

                -- Count final unique runes
                local finalUniqueCount = 0
                local totalRuneCount = 0
                for _ in pairs(collection.runes) do
                    finalUniqueCount = finalUniqueCount + 1
                end
                for _, runeInfo in pairs(collection.runeData) do
                    totalRuneCount = totalRuneCount + runeInfo.quantity
                end

                -- DEBUG: Show all collected runes (DISABLED)
                --[[
                d("|cFFFF00[Enchanting Node Complete]|r")
                d("Collected runes:")
                for runeId, runeInfo in pairs(collection.runeData) do
                    d("  " .. runeInfo.name .. " x" .. runeInfo.quantity)
                end
                d("Total unique runes: " .. finalUniqueCount .. ", total runes: " .. totalRuneCount)
                d("Distance to base: " .. string.format("%.1f", collection.distanceToBase / 100) .. "m")
                --]]

                -- Track all runes
                local zoneName = nearestBase.surveyInfo.zone or GetPlayerLocationName()
                for runeId, runeInfo in pairs(collection.runeData) do
                    self:TrackItemCollected(runeId, runeInfo.name, runeInfo.quantity, zoneName, craft)
                    -- d("|c00FF00[Stats Tracked]|r " .. runeInfo.name .. " x" .. runeInfo.quantity .. " (" .. craft .. " survey node)")
                end

                -- d("|cFFFF00[Node Complete]|r Unique rune types: " .. finalUniqueCount)

                -- Decrement node counter
                if not nearestBase.nodesRemaining then
                    nearestBase.nodesRemaining = 6
                end

                local counterDecremented = false
                local decrementReason = ""

                if nearestBase.nodesRemaining > 0 then
                    nearestBase.nodesRemaining = nearestBase.nodesRemaining - 1
                    counterDecremented = true
                    decrementReason = "Node counter: " .. (nearestBase.nodesRemaining + 1) .. " -> " .. nearestBase.nodesRemaining
                elseif nearestBase.nodesRemaining == 0 then
                    nearestBase.nodesRemaining = 5
                    counterDecremented = true
                    decrementReason = "Nodes respawned! Counter reset: 0 -> 5"
                end

                -- DEBUG: Show counter status (DISABLED)
                --[[
                if counterDecremented then
                    d("|c00FF00[Counter Updated]|r " .. decrementReason)
                else
                    d("|cFF0000[Counter NOT Updated]|r Reason: nodesRemaining = " .. tostring(nearestBase.nodesRemaining))
                end
                --]]

                collection.tracked = true
            end)
        end

        -- Just collect runes, actual tracking happens in delayed callback
        return

    else
        -- For other crafts - check minimum quantity
        -- Exception: Nirncrux items (56862, 56863) are always tracked regardless of quantity
        local isNirncrux = (itemId == 56862 or itemId == 56863)
        if not isNirncrux and quantity < MIN_SURVEY_QUANTITY[craft] then return end

        -- Cooldown check (1 second per base marker)
        local now = GetGameTimeMilliseconds()
        local lastTime = lastDecrementTime[nearestIndex] or 0
        if now - lastTime < 1000 then return end

        -- Track collected item for statistics (AFTER all validation checks)
        local zoneName = nearestBase.surveyInfo.zone or GetPlayerLocationName()
        self:TrackItemCollected(itemId, itemName, quantity, zoneName, craft)

        -- d("|c00FF00[Stats Tracked]|r " .. itemName .. " x" .. quantity .. " (" .. craft .. " survey node)")

        -- Decrement node counter (for non-enchanting crafts)
        if not nearestBase.nodesRemaining then
            nearestBase.nodesRemaining = 6
        end
        if nearestBase.nodesRemaining > 0 then
            nearestBase.nodesRemaining = nearestBase.nodesRemaining - 1
            lastDecrementTime[nearestIndex] = now
        elseif nearestBase.nodesRemaining == 0 then
            -- Nodes respawned! Reset to 5 (one already collected)
            nearestBase.nodesRemaining = 5
            lastDecrementTime[nearestIndex] = now
        end
    end
end

-- ==========================================
-- STATISTICS TRACKING
-- ==========================================

-- Track when a survey is used
function QuickMarker:TrackSurveyUsage(surveyName, zoneName, craftType)
    if not self.savedVars or not self.savedVars.statistics then return end

    local stats = self.savedVars.statistics.surveyStats

    -- Initialize craft type if needed
    if not stats[craftType] then
        stats[craftType] = {
            surveysUsed = 0,
            itemsCollected = {}
        }
    end

    -- Increment survey counter
    stats[craftType].surveysUsed = stats[craftType].surveysUsed + 1
end

-- Track collected items from survey nodes
function QuickMarker:TrackItemCollected(itemId, itemName, quantity, zoneName, craftType)
    if not self.savedVars or not self.savedVars.statistics then return end
    if not craftType then return end

    local stats = self.savedVars.statistics.surveyStats

    -- Initialize if needed
    if not stats[craftType] then
        stats[craftType] = {
            surveysUsed = 0,
            itemsCollected = {}
        }
    end

    local items = stats[craftType].itemsCollected

    -- Get clean item name (remove item link formatting if present)
    local cleanName = itemName
    if itemName and itemName:match("|H") then
        -- Extract name from item link: |H0:item:...|h[Name]|h
        cleanName = itemName:match("|H.-|h%[(.-)%]|h") or itemName:match("|H.-|h(.-)|h") or itemName
    end

    -- If name is still empty or just whitespace, get it from GetItemLinkName
    if not cleanName or cleanName == "" or cleanName:match("^%s*$") then
        local itemLink = string.format("|H1:item:%d:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId)
        cleanName = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(itemLink))
    end

    -- Remove any remaining formatting codes (^ns, ^p, etc)
    if cleanName then
        cleanName = cleanName:gsub("%^%w+", "")
    end

    -- Initialize item if needed
    if not items[itemId] then
        items[itemId] = {
            name = cleanName,
            quantity = 0
        }
    else
        -- Update name if current one is better (not empty)
        if cleanName and cleanName ~= "" and not cleanName:match("^%s*$") then
            items[itemId].name = cleanName
        end
    end

    -- Add quantity
    items[itemId].quantity = items[itemId].quantity + quantity
end

-- Get statistics for display (with optional craft filter)
function QuickMarker:GetStatistics(craftFilter)
    if not self.savedVars or not self.savedVars.statistics then return {} end

    local stats = self.savedVars.statistics.surveyStats
    local result = {}

    -- Data is already aggregated by craft type (no zones)
    for craftType, craftData in pairs(stats) do
        -- Apply filter if specified
        if not craftFilter or craftFilter[craftType] then
            result[craftType] = craftData
        end
    end

    return result
end

-- Clear all statistics
function QuickMarker:ClearStatistics()
    if not self.savedVars or not self.savedVars.statistics then return end
    self.savedVars.statistics.surveyStats = {}
    d("|c00FF00[QuickMarker]|r Statistics cleared")
end

-- ==========================================
-- ARKADIUS TRADE TOOLS INTEGRATION
-- ==========================================

-- Survey container item IDs (sealed surveys)
local SURVEY_CONTAINER_IDS = {
    [219849] = "blacksmith",   -- Unidentified Blacksmith Survey Report
    [219850] = "clothier",      -- Unidentified Clothier Survey Report
    [219851] = "woodworking",   -- Unidentified Woodworker Survey Report
    [219852] = "enchanting",    -- Unidentified Enchanter Survey Report
    [219853] = "alchemist",     -- Unidentified Alchemist Survey Report
    [219854] = "jewelry",       -- Unidentified Jewelry Crafter Survey Report
}

-- Fallback prices (used when ATT is not available)
-- Last updated: 2026-05-10 (use /qmprices to refresh before each release)
local FALLBACK_PRICES = {
    -- Survey containers (sealed)
    [219849] = 2989, -- Blacksmith Survey
    [219850] = 8217, -- Clothier Survey
    [219851] = 1914, -- Woodworking Survey
    [219852] = 2065, -- Enchanting Survey
    [219853] = 3103, -- Alchemy Survey
    [219854] = 12056, -- Jewelry Survey

    -- Alchemy materials
    [30158] = 47, -- Lady's Smock
    [30159] = 48, -- Wormwood
    [30160] = 115, -- Bugloss
    [30161] = 46, -- Corn Flower
    [30162] = 45, -- Dragonthorn
    [30163] = 104, -- Mountain Flower
    [30164] = 472, -- Columbine
    [30157] = 53, -- Blessed Thistle

    -- Blacksmith materials
    [71198] = 22, -- Rubedite Ore

    -- Clothier materials
    [71200] = 64, -- Raw Ancestor Silk
    [71239] = 61, -- Rubedo Leather

    -- Jewelry materials
    [135145] = 99, -- Platinum Dust

    -- Woodworking materials
    [71199] = 11, -- Ruby Ash Wood

    -- Nirncrux (Craglorn - drops from all craft nodes)
    [56862] = 9000, -- Fortified Nirncrux
    [56863] = 14000, -- Potent Nirncrux

    -- Enchanting materials (runes)
    [45831] = 203, -- Oko
    [45832] = 19, -- Makko
    [45833] = 24, -- Deni
    [45834] = 12, -- Okoma
    [45837] = 12, -- Kuoko
    [45838] = 164, -- Rakeipa
    [45839] = 14, -- Dekeipa
    [45840] = 12, -- Meip
    [45841] = 23, -- Haoko
    [45842] = 10, -- Deteri
    [45843] = 28, -- Okori
    [45846] = 13, -- Oru
    [45847] = 52, -- Taderi
    [45848] = 25, -- Makderi
    [45849] = 26, -- Kaderi
    [45850] = 16, -- Ta
    [45851] = 3, -- Jejota
    [45852] = 8, -- Denata
    [45853] = 13, -- Rekuta
    [45854] = 1915, -- Kuta (most expensive)
    [45855] = 48, -- Jora
    [45856] = 116, -- Porade
    [45857] = 102, -- Jera
    [64508] = 6, -- Jehade
    [64509] = 6, -- Rejera
    [68340] = 20, -- Itade
    [68341] = 17, -- Repora
}

-- Check if ATT is available
function QuickMarker:IsATTAvailable()
    return ArkadiusTradeTools and ArkadiusTradeTools.Modules and ArkadiusTradeTools.Modules.Sales ~= nil
end

-- Get price from ATT for an item (by itemId)
-- Returns: price, isFromATT (true if from ATT, false if fallback)
function QuickMarker:GetPriceFromATT(itemId, days)
    days = days or 30 -- Default to 30 days

    -- Try to get price from ATT first
    if self:IsATTAvailable() then
        local itemLink = string.format("|H1:item:%d:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId)
        local newerThanTimeStamp = GetTimeStamp() - (days * 24 * 60 * 60)
        local price = ArkadiusTradeTools.Modules.Sales:GetAveragePricePerItem(itemLink, newerThanTimeStamp)

        if price and price > 0 then
            return price, true -- From ATT
        end
    end

    -- Fallback to hardcoded prices
    if FALLBACK_PRICES[itemId] then
        return FALLBACK_PRICES[itemId], false -- Fallback price
    end

    return nil, false
end

-- Get price for survey container (sealed)
-- Returns: price, isFromATT
function QuickMarker:GetSurveyContainerPrice(craftType, days)
    -- Find item ID for this craft type
    for itemId, craft in pairs(SURVEY_CONTAINER_IDS) do
        if craft == craftType then
            return self:GetPriceFromATT(itemId, days)
        end
    end
    return nil, false
end

-- Format price as gold string
function QuickMarker:FormatPrice(price)
    if not price or price == 0 then return "-" end

    -- Format with thousands separator
    local formatted = tostring(math.floor(price))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end

    return formatted .. "g"
end

-- ==========================================
-- SURVEY OPENER
-- ==========================================
local SurveyOpener = {
    isOpening = false,
    surveyItemIds = {
        219849, -- Unidentified Blacksmith Survey Report
        219850, -- Unidentified Clothier Survey Report
        219851, -- Unidentified Woodworker Survey Report
        219852, -- Unidentified Enchanter Survey Report
        219853, -- Unidentified Alchemist Survey Report
        219854, -- Unidentified Jewelry Crafter Survey Report
    },
    openDelay = 1000,
}

function SurveyOpener:FindSurveyContainers()
    local containers = {}
    local bagId = BAG_BACKPACK
    local slotCount = GetBagSize(bagId)

    for slotIndex = 0, slotCount - 1 do
        local itemId = GetItemId(bagId, slotIndex)
        for _, surveyId in ipairs(self.surveyItemIds) do
            if itemId == surveyId then
                local stackCount = GetSlotStackSize(bagId, slotIndex)
                if stackCount > 0 then
                    local itemLink = GetItemLink(bagId, slotIndex)
                    local itemName = GetItemName(bagId, slotIndex)
                    for i = 1, stackCount do
                        table.insert(containers, {
                            bagId = bagId,
                            slotIndex = slotIndex,
                            itemId = itemId,
                            itemName = itemName,
                            itemLink = itemLink,
                            stackNumber = i,
                            totalStack = stackCount
                        })
                    end
                end
                break
            end
        end
    end
    return containers
end

function SurveyOpener:FindSlotByItemId(itemId)
    local bagId = BAG_BACKPACK
    local slotCount = GetBagSize(bagId)
    for slotIndex = 0, slotCount - 1 do
        if GetItemId(bagId, slotIndex) == itemId then
            return slotIndex
        end
    end
    return nil
end

function SurveyOpener:OpenNextContainer(containers, index)
    if not self.isOpening then
        return
    end

    if index > #containers then
        self.isOpening = false
        return
    end

    local container = containers[index]
    local currentSlotIndex = self:FindSlotByItemId(container.itemId)

    if currentSlotIndex then
        CallSecureProtected("UseItem", container.bagId, currentSlotIndex)
    end

    zo_callLater(function()
        self:OpenNextContainer(containers, index + 1)
    end, self.openDelay)
end

function SurveyOpener:StartOpening()
    if self.isOpening then
        d("|cFFFF00[QuickMarker]|r Survey opening already in progress")
        return
    end

    local containers = self:FindSurveyContainers()
    if #containers == 0 then
        d("|cFF0000[QuickMarker]|r No survey containers found in backpack")
        return
    end

    d("|c00FF00[QuickMarker]|r Found " .. #containers .. " survey containers. Starting to open...")
    self.isOpening = true
    self:OpenNextContainer(containers, 1)
end

function SurveyOpener:StopOpening()
    self.isOpening = false
    d("|cFF0000[QuickMarker]|r Survey opening stopped")
end

QuickMarker.SurveyOpener = SurveyOpener

-- ==========================================
-- 3D VISUALIZATION
-- ==========================================
function QuickMarker:CreateTexture()
    local control, key = self.texturePool:AcquireObject()
    control:Create3DRenderSpace()
    return control, key
end

function QuickMarker:CreateTextureWithAtlas(atlasData)
    local control, key = self.texturePool:AcquireObject()
    if not control then
        return nil, nil
    end

    control:Create3DRenderSpace()

    if atlasData then
        control:SetTexture(atlasData.file)
        control:SetTextureCoords(atlasData.left, atlasData.right, atlasData.top, atlasData.bottom)
    end

    return control, key
end

function QuickMarker:DestroyTexture(control, key)
    control:SetHidden(true)
    control:Destroy3DRenderSpace()
    self.texturePool:ReleaseObject(key)
end

function QuickMarker:DestroyPin(pin)
    -- Destroy main marker
    self:DestroyTexture(pin.control, pin.key)

    -- Destroy distance display if any
    self:ClearDistanceDisplay(pin)

    -- Destroy node count display if any
    self:ClearNodeCountDisplay(pin)

    -- Destroy survey count display if any
    self:ClearSurveyCountDisplay(pin)
end

function QuickMarker:FindNearestBase(fromX, fromY, fromZ)
    if not self.savedVars or not self.savedVars.markerList then return nil end

    local currentZoneId = GetUnitRawWorldPosition("player")
    if not currentZoneId then return nil end

    local maxDistance = 30000 -- 300 meters = 30000 cm
    local maxDistance2 = maxDistance * maxDistance
    local nearestDistance = nil
    local nearestBase = nil

    for i, data in ipairs(self.savedVars.markerList) do
        -- Check zone
        if data.type == "base" and data.worldX and data.worldY and data.worldZ and (not data.zoneId or data.zoneId == currentZoneId) then
            local dx = fromX - data.worldX
            local dy = fromY - data.worldY
            local dz = fromZ - data.worldZ
            local distance2 = dx * dx + dy * dy + dz * dz

            if distance2 <= maxDistance2 then
                local distance = math.sqrt(distance2) / 100 -- convert to meters
                if not nearestDistance or distance < nearestDistance then
                    nearestDistance = distance
                    nearestBase = data
                end
            end
        end
    end

    return nearestDistance, nearestBase
end

function QuickMarker:UpdateCamera()
    local c = self.camera
    Set3DRenderSpaceToCurrentCamera(c.name)
    c.xf, c.yf, c.zf = c.control:Get3DRenderSpaceForward()
    c.xr, c.yr, c.zr = c.control:Get3DRenderSpaceRight()
    c.xu, c.yu, c.zu = c.control:Get3DRenderSpaceUp()
    c.xo, c.yo, c.zo = GuiRender3DPositionToWorldPosition(c.control:Get3DRenderSpaceOrigin())
end

-- Clear distance display for a pin
function QuickMarker:ClearDistanceDisplay(pin)
    if pin.distanceControls then
        for _, ctrl in ipairs(pin.distanceControls) do
            self:DestroyTexture(ctrl.control, ctrl.key)
        end
        pin.distanceControls = {}
    end
end

-- Clear node count display for a pin
function QuickMarker:ClearNodeCountDisplay(pin)
    if pin.nodeCountControl then
        self:DestroyTexture(pin.nodeCountControl.control, pin.nodeCountControl.key)
        pin.nodeCountControl = nil
    end
end

-- Clear survey count display for a pin
function QuickMarker:ClearSurveyCountDisplay(pin)
    if pin.surveyCountControls then
        for _, ctrl in ipairs(pin.surveyCountControls) do
            self:DestroyTexture(ctrl.control, ctrl.key)
        end
        pin.surveyCountControls = {}
    end
end

-- Update node count display for base marker
function QuickMarker:UpdateNodeCountDisplay(pin, count, worldX, worldY, worldZ, scale, r, g, b)
    -- Check if count changed
    if pin.lastNodeCount == count and pin.nodeCountControl then
        -- Just update position and color
        self:PositionNodeCountControl(pin, count, worldX, worldY, worldZ, scale, r, g, b)
        return
    end

    -- Clear old display
    self:ClearNodeCountDisplay(pin)
    pin.lastNodeCount = count

    -- Create digit texture
    local atlasData = QuickMarker.Atlas:GetDigit(count)
    if not atlasData then return end

    local control, key = self:CreateTextureWithAtlas(atlasData)
    if control and key then
        control:Set3DRenderSpaceUsesDepthBuffer(false)
        pin.nodeCountControl = {
            control = control,
            key = key
        }
    end

    -- Position the control
    self:PositionNodeCountControl(pin, count, worldX, worldY, worldZ, scale, r, g, b)
end

-- Position node count control texture
function QuickMarker:PositionNodeCountControl(pin, count, worldX, worldY, worldZ, scale, r, g, b)
    if not pin.nodeCountControl then return end

    -- Digit scaling: x2 at close range, x6 at 200m
    local digitScale = 2.0 + (scale - 1.0) * 1.5
    local charSize = 0.5 * digitScale

    -- Position BELOW marker but closer (10cm base instead of 50cm)
    local heightBelow = -10 - (scale * 25) -- Much closer to marker

    -- Get camera vectors
    local c = self.camera

    -- Convert to GUI coordinates
    local guiX, guiY, guiZ = WorldPositionToGuiRender3DPosition(worldX, worldY + heightBelow, worldZ)

    local ctrl = pin.nodeCountControl
    ctrl.control:Set3DRenderSpaceOrigin(guiX, guiY, guiZ)
    ctrl.control:Set3DLocalDimensions(charSize, charSize)

    -- Billboard orientation
    ctrl.control:Set3DRenderSpaceForward(c.xf, c.yf, c.zf)
    ctrl.control:Set3DRenderSpaceRight(c.xr, c.yr, c.zr)
    ctrl.control:Set3DRenderSpaceUp(c.xu, c.yu, c.zu)

    -- Set color same as marker
    ctrl.control:SetColor(r, g, b, 1)
    ctrl.control:SetHidden(false)
end

-- Update survey count display for base marker
function QuickMarker:UpdateSurveyCountDisplay(pin, count, worldX, worldY, worldZ, scale, r, g, b)
    -- Check if count changed
    if pin.lastSurveyCount == count and pin.surveyCountControls and #pin.surveyCountControls > 0 then
        -- Just update position and color
        self:PositionSurveyCountControls(pin, worldX, worldY, worldZ, scale, r, g, b)
        return
    end

    -- Clear old display
    self:ClearSurveyCountDisplay(pin)
    pin.lastSurveyCount = count

    -- Don't show if count is 0
    if count == 0 then return end

    -- Initialize controls array
    if not pin.surveyCountControls then
        pin.surveyCountControls = {}
    end

    -- Create display for each digit
    local countStr = tostring(count)

    for i = 1, #countStr do
        local char = string.sub(countStr, i, i)
        local atlasData = QuickMarker.Atlas:GetDigit(tonumber(char))

        if atlasData then
            local control, key = self:CreateTextureWithAtlas(atlasData)
            if control and key then
                control:Set3DRenderSpaceUsesDepthBuffer(false)
                table.insert(pin.surveyCountControls, {
                    control = control,
                    key = key,
                    index = i
                })
            end
        end
    end

    -- Position all controls
    self:PositionSurveyCountControls(pin, worldX, worldY, worldZ, scale, r, g, b)
end

-- Position survey count control textures
function QuickMarker:PositionSurveyCountControls(pin, worldX, worldY, worldZ, scale, r, g, b)
    if not pin.surveyCountControls or #pin.surveyCountControls == 0 then return end

    local numChars = #pin.surveyCountControls

    -- Digit scaling: x2 at close range, x6 at 200m
    local digitScale = 2.0 + (scale - 1.0) * 1.5
    local charSize = 0.5 * digitScale

    -- Spacing: 30cm at close range, 120cm at max distance
    local spacing = 30 + ((scale - 1.0) / 3.0) * 90 -- 30cm to 120cm

    -- Calculate center index
    local centerIndex = math.ceil(numChars / 2)

    -- Get camera vectors
    local c = self.camera

    for i, ctrl in ipairs(pin.surveyCountControls) do
        -- Calculate offset from center character in world units (cm)
        local offsetFromCenter = (i - centerIndex) * spacing

        -- Position ABOVE marker - same height as distance display on range markers
        local heightAbove = 200 + (scale * 100) -- 200cm base + 100cm per scale unit

        -- Apply offset in world space using camera right vector (horizontal only)
        local offsetWorldX = worldX + (c.xr * offsetFromCenter)
        local offsetWorldY = worldY + heightAbove
        local offsetWorldZ = worldZ + (c.zr * offsetFromCenter)

        -- Convert to GUI coordinates
        local guiX, guiY, guiZ = WorldPositionToGuiRender3DPosition(offsetWorldX, offsetWorldY, offsetWorldZ)

        ctrl.control:Set3DRenderSpaceOrigin(guiX, guiY, guiZ)
        ctrl.control:Set3DLocalDimensions(charSize, charSize)

        -- Billboard orientation
        ctrl.control:Set3DRenderSpaceForward(c.xf, c.yf, c.zf)
        ctrl.control:Set3DRenderSpaceRight(c.xr, c.yr, c.zr)
        ctrl.control:Set3DRenderSpaceUp(c.xu, c.yu, c.zu)

        -- Set color same as marker
        ctrl.control:SetColor(r, g, b, 1)
        ctrl.control:SetHidden(false)
    end
end

-- Update distance display for range marker
function QuickMarker:UpdateDistanceDisplay(pin, distance, worldX, worldY, worldZ, scale, r, g, b)
    local distanceInt = zo_floor(distance)

    -- Check if distance changed
    if pin.lastDistance == distanceInt and #pin.distanceControls > 0 then
        -- Just update positions and color
        self:PositionDistanceControls(pin, worldX, worldY, worldZ, scale, r, g, b)
        return
    end

    -- Clear old display
    self:ClearDistanceDisplay(pin)
    pin.lastDistance = distanceInt

    -- Create new display
    local distanceStr = tostring(distanceInt) .. "m"

    for i = 1, #distanceStr do
        local char = string.sub(distanceStr, i, i)
        local atlasData

        if char == "m" then
            atlasData = QuickMarker.Atlas.letterM
        else
            atlasData = QuickMarker.Atlas:GetDigit(tonumber(char))
        end

        if atlasData then
            local control, key = self:CreateTextureWithAtlas(atlasData)
            if control and key then
                control:Set3DRenderSpaceUsesDepthBuffer(false)
                table.insert(pin.distanceControls, {
                    control = control,
                    key = key,
                    index = i
                })
            end
        end
    end

    -- Position all controls
    self:PositionDistanceControls(pin, worldX, worldY, worldZ, scale, r, g, b)
end

-- Position distance control textures
function QuickMarker:PositionDistanceControls(pin, worldX, worldY, worldZ, scale, r, g, b)
    if not pin.distanceControls or #pin.distanceControls == 0 then return end

    local numChars = #pin.distanceControls

    -- Separate scaling for digits - more aggressive than marker
    -- 0m = x2, 200m = x8
    local digitScale = 2.0 + (scale - 1.0) * 2.0 -- When marker is x4, digits are x8
    local charSize = 0.5 * digitScale

    -- Spacing: 30cm at close range, 120cm at max distance
    -- scale goes from 1.0 to 4.0, so we interpolate spacing
    local spacing = 30 + ((scale - 1.0) / 3.0) * 90 -- 30cm to 120cm

    -- Calculate center index
    local centerIndex = math.ceil(numChars / 2)

    -- Get camera vectors
    local c = self.camera

    for i, ctrl in ipairs(pin.distanceControls) do
        -- Calculate offset from center character in world units (cm)
        local offsetFromCenter = (i - centerIndex) * spacing

        -- Dynamic height above marker - scales with marker size
        local heightAbove = 200 + (scale * 100) -- 200cm base + 100cm per scale unit

        -- Apply offset in world space using camera right vector (horizontal only)
        local offsetWorldX = worldX + (c.xr * offsetFromCenter)
        local offsetWorldY = worldY + heightAbove -- Dynamic height
        local offsetWorldZ = worldZ + (c.zr * offsetFromCenter)

        -- Convert to GUI coordinates
        local guiX, guiY, guiZ = WorldPositionToGuiRender3DPosition(offsetWorldX, offsetWorldY, offsetWorldZ)

        ctrl.control:Set3DRenderSpaceOrigin(guiX, guiY, guiZ)
        ctrl.control:Set3DLocalDimensions(charSize, charSize)

        -- Billboard orientation
        ctrl.control:Set3DRenderSpaceForward(c.xf, c.yf, c.zf)
        ctrl.control:Set3DRenderSpaceRight(c.xr, c.yr, c.zr)
        ctrl.control:Set3DRenderSpaceUp(c.xu, c.yu, c.zu)

        -- Set color same as marker
        ctrl.control:SetColor(r, g, b, 1)
        ctrl.control:SetHidden(false)
    end
end

function QuickMarker:UpdateWorldPins()
    if not self.savedVars or not self.savedVars.markerList then return end

    local zoneId, playerX, playerY, playerZ = GetUnitRawWorldPosition("player")
    if not playerX then return end

    -- Update camera
    self:UpdateCamera()

    local maxDistance = 20000 -- 200 meters (coordinates in cm)
    local maxDistance2 = maxDistance * maxDistance

    -- Find distance to nearest base
    local distanceToNearestBase, nearestBase = self:FindNearestBase(playerX, playerY, playerZ)

    for i, data in ipairs(self.savedVars.markerList) do
        if data.worldX and data.worldY and data.worldZ then
            -- Skip markers from other zones
            if data.zoneId and data.zoneId ~= zoneId then
                -- Remove pin if it was active
                if self.activeWorldPins[i] then
                    self:DestroyPin(self.activeWorldPins[i])
                    self.activeWorldPins[i] = nil
                end
            else
                -- Set default type for old markers
                if not data.type then
                    data.type = "range"
                end

            local dx = playerX - data.worldX
            local dy = playerY - data.worldY
            local dz = playerZ - data.worldZ
            local distance2 = dx * dx + dy * dy + dz * dz

            if distance2 <= maxDistance2 then
                -- Check if player has survey report for this marker
                local hasSurvey = true -- Default true for markers without surveyInfo
                if data.type == "base" and data.surveyInfo then
                    -- Base marker is visible if:
                    -- 1. Player has survey reports, OR
                    -- 2. There are still nodes remaining to collect (nodesRemaining > 0)
                    local hasReport = self:HasSurveyReport(data.surveyInfo.name)
                    local hasNodes = (data.nodesRemaining and data.nodesRemaining > 0)
                    hasSurvey = hasReport or hasNodes
                elseif data.type == "range" and data.linkedBaseInfo then
                    -- Range marker visibility depends on its linked base
                    hasSurvey = self:HasSurveyReport(data.linkedBaseInfo.surveyName)
                end

                -- Hide marker if no survey in inventory and no nodes remaining
                if not hasSurvey then
                    if self.activeWorldPins[i] then
                        self:DestroyPin(self.activeWorldPins[i])
                        self.activeWorldPins[i] = nil
                    end
                else
                    -- Show marker (existing code continues)
                local pinData = self.activeWorldPins[i]

                -- Create pin if it doesn't exist
                if not pinData then
                    local atlasData
                    if data.type == "base" then
                        atlasData = QuickMarker.Atlas:GetMarker("base")
                    else
                        atlasData = QuickMarker.Atlas:GetMarker("range")
                    end

                    local control, key = self:CreateTextureWithAtlas(atlasData)
                    if control and key then
                        -- Size in meters (100 cm = 1 meter)
                        local size = 2.0 -- 2 meters
                        control:Set3DLocalDimensions(size, size)

                        -- Disable depth buffer to see through walls
                        control:Set3DRenderSpaceUsesDepthBuffer(false)

                        -- DrawLevel for proper rendering
                        control:SetDrawLevel(-10 - zo_floor(distance2))

                        self.activeWorldPins[i] = {
                            control = control,
                            key = key,
                            worldX = data.worldX,
                            worldY = data.worldY,
                            worldZ = data.worldZ,
                            markerType = data.type,
                            distanceControls = {} -- For range marker distance display
                        }
                    end
                end

                -- Update position and orientation
                if self.activeWorldPins[i] then
                    local pin = self.activeWorldPins[i]
                    local x, y, z = pin.worldX, pin.worldY, pin.worldZ

                    -- Calculate distance to player in meters
                    local distanceToPlayer = math.sqrt(distance2) / 100

                    -- Smooth scaling: 0m = x1, 200m = x4
                    local scale
                    if distanceToPlayer >= 200 then
                        scale = 4.0
                    else
                        -- Linear interpolation: scale = 1 + (distance / 200) * 3
                        scale = 1.0 + (distanceToPlayer / 200.0) * 3.0
                    end

                    local size = 2.0 * scale -- base size 2m * scale
                    pin.control:Set3DLocalDimensions(size, size)

                    -- Convert world coordinates to GUI coordinates
                    local guiX, guiY, guiZ = WorldPositionToGuiRender3DPosition(x, y + 200, z)
                    pin.control:Set3DRenderSpaceOrigin(guiX, guiY, guiZ)

                    -- Billboard orientation (always faces player)
                    local c = self.camera
                    pin.control:Set3DRenderSpaceForward(c.xf, c.yf, c.zf)
                    pin.control:Set3DRenderSpaceRight(c.xr, c.yr, c.zr)
                    pin.control:Set3DRenderSpaceUp(c.xu, c.yu, c.zu)

                    -- For range markers - change color based on distance to base
                    if pin.markerType == "range" then
                        local distanceToBase = self:FindNearestBase(x, y, z)
                        if distanceToBase then
                            -- 0-35m = green, 35-70m = yellow, 70-100m = red, 100m+ = purple
                            local r, g, b
                            if distanceToBase < 35 then
                                r, g, b = 0, 1, 0 -- green
                            elseif distanceToBase < 70 then
                                r, g, b = 1, 1, 0 -- yellow
                            elseif distanceToBase < 100 then
                                r, g, b = 1, 0, 0 -- red
                            else
                                r, g, b = 0.5, 0, 1 -- purple
                            end
                            pin.control:SetColor(r, g, b, 1)

                            -- Update distance display with same color
                            self:UpdateDistanceDisplay(pin, distanceToBase, x, y, z, scale, r, g, b)
                        else
                            pin.control:SetColor(0.5, 0.5, 0.5, 1) -- gray if no base
                            self:ClearDistanceDisplay(pin)
                        end
                    else
                        -- Base marker color depends on nodes remaining
                        local nodesRemaining = data.nodesRemaining or 6
                        local r, g, b, a

                        if nodesRemaining > 0 then
                            -- White semi-transparent (nodes remain)
                            r, g, b, a = 1, 1, 1, 0.5
                        else
                            -- Blue semi-transparent (all collected)
                            r, g, b, a = 0, 0.5, 1, 0.5
                        end

                        pin.control:SetColor(r, g, b, a)

                        -- Display node count below base marker (1-6 only)
                        if nodesRemaining > 0 and nodesRemaining <= 6 then
                            self:UpdateNodeCountDisplay(pin, nodesRemaining, x, y, z, scale, r, g, b)
                        else
                            self:ClearNodeCountDisplay(pin)
                        end

                        -- Display survey count above base marker
                        if data.surveyInfo then
                            local surveyCount = self:CountSurveyReports(data.surveyInfo.name)

                            -- Track survey usage when count decreases
                            if not data.lastSurveyCount then
                                data.lastSurveyCount = surveyCount
                            elseif surveyCount < data.lastSurveyCount then
                                -- Survey was used! Track it
                                local surveysUsed = data.lastSurveyCount - surveyCount
                                for j = 1, surveysUsed do
                                    self:TrackSurveyUsage(data.surveyInfo.name, data.surveyInfo.zone, data.surveyInfo.craft)
                                end
                                data.lastSurveyCount = surveyCount
                            elseif surveyCount > data.lastSurveyCount then
                                -- Survey count increased (picked up more)
                                data.lastSurveyCount = surveyCount
                            end

                            if surveyCount > 0 then
                                self:UpdateSurveyCountDisplay(pin, surveyCount, x, y, z, scale, r, g, b)
                            else
                                self:ClearSurveyCountDisplay(pin)
                            end
                        else
                            self:ClearSurveyCountDisplay(pin)
                        end
                    end
                end
                end -- close else for hasSurvey check
            else
                -- Remove pin if too far
                if self.activeWorldPins[i] then
                    self:DestroyPin(self.activeWorldPins[i])
                    self.activeWorldPins[i] = nil
                end
            end
            end -- close else for zoneId check
        end
    end

    -- Update label with current distance to base
    -- Hide label if nearest base is hidden (no survey and no nodes remaining)
    -- Also hide if stats window is open
    local isStatsWindowOpen = QuickMarkerStatsWindow and not QuickMarkerStatsWindow:IsHidden()

    -- Check if HUD scene is active (hide distance label when inventory, map, etc. are open)
    local isHudActive = (SCENE_MANAGER:IsShowing("hud") or SCENE_MANAGER:IsShowing("hudui") or SCENE_MANAGER:IsShowing("loot"))

    if distanceToNearestBase and distanceToNearestBase < 200 and nearestBase and not isStatsWindowOpen and isHudActive then
        local shouldShowBase = true
        if nearestBase.surveyInfo then
            local hasReport = self:HasSurveyReport(nearestBase.surveyInfo.name)
            local hasNodes = (nearestBase.nodesRemaining and nearestBase.nodesRemaining > 0)
            shouldShowBase = hasReport or hasNodes
        end

        if shouldShowBase then
            self.distanceLabel:SetText(string.format("%dm", zo_floor(distanceToNearestBase)))
            self.distanceLabel:GetParent():SetHidden(false)
        else
            self.distanceLabel:GetParent():SetHidden(true)
        end
    else
        self.distanceLabel:GetParent():SetHidden(true)
    end
end

-- ==========================================
-- MARKER SAVING
-- ==========================================
function QuickMarker.SaveMarker(markerType)
    if not QuickMarker.savedVars then return end

    local zoneId, worldX, worldY, worldZ = GetUnitRawWorldPosition("player")
    if not worldX then return end

    -- For range markers - calculate and store distance to base
    local distanceToBase = nil
    local linkedBaseInfo = nil
    if markerType == "range" then
        local distance, nearestBase = QuickMarker:FindNearestBase(worldX, worldY, worldZ)
        if distance and nearestBase then
            distanceToBase = zo_floor(distance) -- round to integer
            -- Store info about linked base marker
            linkedBaseInfo = {
                surveyName = nearestBase.surveyInfo and nearestBase.surveyInfo.name or nil,
                craft = nearestBase.surveyInfo and nearestBase.surveyInfo.craft or nil,
                distance = distanceToBase
            }
        else
            -- No base within 300m - cannot create range marker
            return
        end
    end

    -- For base markers - check if near a survey location
    local surveyInfo = nil
    if markerType == "base" and QuickMarker_SurveyDatabase then
        local nearby = QuickMarker_SurveyDatabase:FindNearby(zoneId, worldX, worldY, worldZ)
        if #nearby > 0 then
            surveyInfo = {
                name = nearby[1].survey.name,
                craft = nearby[1].survey.craft,
                zone = nearby[1].survey.zone,
                distance = nearby[1].distance
            }

            -- Remove any existing base marker at this survey location
            for i = #QuickMarker.savedVars.markerList, 1, -1 do
                local marker = QuickMarker.savedVars.markerList[i]
                if marker.type == "base" and marker.surveyInfo and
                   marker.surveyInfo.name == surveyInfo.name then
                    -- Clear active pin if exists
                    if QuickMarker.activeWorldPins[i] then
                        QuickMarker:DestroyPin(QuickMarker.activeWorldPins[i])
                        QuickMarker.activeWorldPins[i] = nil
                    end
                    -- Remove from list
                    table.remove(QuickMarker.savedVars.markerList, i)
                    break
                end
            end
        end
    end

    table.insert(QuickMarker.savedVars.markerList, {
        type = markerType,
        zoneId = zoneId,
        worldX = worldX,
        worldY = worldY,
        worldZ = worldZ,
        distanceToBase = distanceToBase,
        surveyInfo = surveyInfo,
        linkedBaseInfo = linkedBaseInfo,  -- Info about linked base marker (for range markers)
        nodesRemaining = markerType == "base" and 6 or nil  -- Initialize base markers with 6 nodes
    })

    -- Chat message
    if markerType == "base" then
        if surveyInfo then
            d("|c00FF00[QuickMarker]|r |cFF0000Base|r marker saved at |cFFFF00" .. surveyInfo.name .. "|r (" .. string.format("%.1f", surveyInfo.distance) .. "m)")
        else
            d("|c00FF00[QuickMarker]|r |cFF0000Base|r marker saved!")
        end
    else
        -- For range - show distance to base
        if distanceToBase then
            d("|c00FF00[QuickMarker]|r |cFFFF00Range|r marker saved, distance to base: " .. string.format("%.0f", distanceToBase) .. " meters")
        end
    end
end

function QuickMarker.DeleteNearestMarker()
    if not QuickMarker.savedVars or not QuickMarker.savedVars.markerList then return end

    local zoneId, playerX, playerY, playerZ = GetUnitRawWorldPosition("player")
    if not playerX then return end

    local maxDistance = 1000 -- 10 meters = 1000 cm
    local maxDistance2 = maxDistance * maxDistance
    local nearestIndex = nil
    local nearestDistance2 = maxDistance2

    -- Find nearest marker within 10 meters
    for i, data in ipairs(QuickMarker.savedVars.markerList) do
        if data.worldX and data.worldY and data.worldZ then
            local dx = playerX - data.worldX
            local dy = playerY - data.worldY
            local dz = playerZ - data.worldZ
            local distance2 = dx * dx + dy * dy + dz * dz

            if distance2 <= nearestDistance2 then
                nearestDistance2 = distance2
                nearestIndex = i
            end
        end
    end

    -- Delete nearest marker
    if nearestIndex then
        local marker = QuickMarker.savedVars.markerList[nearestIndex]
        local typeName = marker.type == "base" and "Base" or "Range"
        local color = marker.type == "base" and "|cFF0000" or "|cFFFF00"

        -- Remove from array first
        table.remove(QuickMarker.savedVars.markerList, nearestIndex)

        -- Clear all active pins and let UpdateWorldPins recreate them
        for i, pin in pairs(QuickMarker.activeWorldPins) do
            QuickMarker:DestroyPin(pin)
        end
        QuickMarker.activeWorldPins = {}

        local distance = math.sqrt(nearestDistance2) / 100 -- convert to meters
        d("|c00FF00[QuickMarker]|r Deleted " .. color .. typeName .. "|r marker (distance: " .. string.format("%.1f", distance) .. "m)")
    else
        d("|cFF0000[QuickMarker]|r No markers within 10 meters")
    end
end

-- ==========================================
-- INITIALIZATION AND SCENES
-- ==========================================
function QuickMarker.OnAddOnLoaded(eventCode, addonName)
    if addonName ~= NAME then return end

    QuickMarker.savedVars = ZO_SavedVars:NewAccountWide("QuickMarkerSV", 1, nil, {
        markerList = {},
        statistics = {
            surveyStats = {},  -- { [zoneName] = { [craftType] = { surveysUsed = 0, itemsCollected = {} } } }
            filters = {
                alchemist = true,
                blacksmith = true,
                clothier = true,
                enchanting = true,
                jewelry = true,
                woodworking = true,
            },
            expanded = {
                alchemist = false,
                blacksmith = false,
                clothier = false,
                enchanting = false,
                jewelry = false,
                woodworking = false,
            }
        }
    })

    -- Create texture pool
    local root = QuickMarker3DContainer
    QuickMarker.texturePool = ZO_ControlPool:New("QuickMarker_WorldPin", root)

    -- Initialize distance label
    QuickMarker.distanceLabel = QuickMarkerDistanceLabelText

    -- Initialize camera
    QuickMarker.camera.control = root:GetNamedChild("Camera")
    QuickMarker.camera.control:Create3DRenderSpace()
    QuickMarker.camera.name = QuickMarker.camera.control:GetName()

    -- Add to scenes
    local fragment = ZO_SimpleSceneFragment:New(root)
    HUD_SCENE:AddFragment(fragment)
    HUD_UI_SCENE:AddFragment(fragment)
    LOOT_SCENE:AddFragment(fragment)

    -- Add distance label to HUD and LOOT scenes only (hide when UI is open)
    local distanceLabelFragment = ZO_SimpleSceneFragment:New(QuickMarkerDistanceLabel)
    HUD_SCENE:AddFragment(distanceLabelFragment)
    LOOT_SCENE:AddFragment(distanceLabelFragment)

    -- Update every frame (interval 0)
    EVENT_MANAGER:RegisterForUpdate(NAME .. "_Update", 0, function()
        QuickMarker:UpdateWorldPins()
    end)

    -- Register loot event for node collection detection
    EVENT_MANAGER:RegisterForEvent(NAME .. "_Loot", EVENT_LOOT_RECEIVED, function(...)
        QuickMarker:OnLootReceived(...)
    end)

    -- Register update for statistics window (refresh every 2 seconds when visible)
    EVENT_MANAGER:RegisterForUpdate(NAME .. "_StatsUpdate", 2000, function()
        if QuickMarkerStatsWindow and not QuickMarkerStatsWindow:IsHidden() then
            QuickMarker_UpdateStatsDisplay()
        end
    end)

    EVENT_MANAGER:UnregisterForEvent(NAME, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, QuickMarker.OnAddOnLoaded)
_G[NAME] = QuickMarker

-- Debug command
SLASH_COMMANDS["/qmdebug"] = function()
    d("|cFFFF00[QuickMarker]|r === DEBUG INFO ===")
    d("Container exists: " .. tostring(QuickMarker3DContainer ~= nil))
    d("Camera exists: " .. tostring(QuickMarker.camera.control ~= nil))
    d("Active pins: " .. QuickMarker.texturePool:GetActiveObjectCount())
    d("Saved markers: " .. #QuickMarker.savedVars.markerList)

    local zoneId, px, py, pz = GetUnitRawWorldPosition("player")
    if px then
        d("Player position: X=" .. px .. " Y=" .. py .. " Z=" .. pz)
    end

    for i, data in ipairs(QuickMarker.savedVars.markerList) do
        if data.worldX then
            local dx = px - data.worldX
            local dy = py - data.worldY
            local dist = math.sqrt(dx * dx + dy * dy)
            local typeName = data.type == "base" and "Base" or "Range"
            d("Marker #" .. i .. " (" .. typeName .. ") distance: " .. zo_floor(dist) .. "m, active: " .. tostring(QuickMarker.activeWorldPins[i] ~= nil))
            if data.type == "base" then
                d("  Nodes remaining: " .. tostring(data.nodesRemaining or "nil"))
            end
        end
    end
end

-- Test command - create marker at current position (DEVELOPER ONLY)
--[[
SLASH_COMMANDS["/qmtest"] = function(args)
    local markerType = args == "range" and "range" or "base"
    QuickMarker.SaveMarker(markerType)
    d("|cFFFF00[QuickMarker]|r Usage: /qmtest [base|range]")
end
--]]

-- Command to get current coordinates for survey database (DEVELOPER ONLY)
--[[
SLASH_COMMANDS["/qmcoords"] = function()
    local zoneId, x, y, z = GetUnitRawWorldPosition("player")
    if x then
        local zoneName = GetPlayerLocationName()
        d("|cFFFF00[QuickMarker]|r Current coordinates:")
        d("Zone: " .. zoneName .. " (ID: " .. zoneId .. ")")
        d("X: " .. x .. ", Y: " .. y .. ", Z: " .. z)
        d("Copy this for survey database:")
        d('{ zoneId = ' .. zoneId .. ', x = ' .. x .. ', y = ' .. y .. ', z = ' .. z .. ', name = "Survey Name", craft = "craft", zone = "' .. zoneName .. '" },')
    end
end
--]]

-- Survey opener commands
SLASH_COMMANDS["/qmsurvey"] = function()
    QuickMarker.SurveyOpener:StartOpening()
end

SLASH_COMMANDS["/qmstop"] = function()
    QuickMarker.SurveyOpener:StopOpening()
end

-- Keybind function for survey opener
function QuickMarker_OpenSurveys()
    QuickMarker.SurveyOpener:StartOpening()
end

-- ==========================================
-- STATISTICS UI FUNCTIONS
-- ==========================================

-- Show statistics window
function QuickMarker_ShowStatsWindow()
    if not QuickMarkerStatsWindow then return end

    -- Restore window position if saved
    if QuickMarker.savedVars and QuickMarker.savedVars.statistics and QuickMarker.savedVars.statistics.windowPosition then
        local pos = QuickMarker.savedVars.statistics.windowPosition
        QuickMarkerStatsWindow:ClearAnchors()
        QuickMarkerStatsWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, pos[1], pos[2])
    end

    QuickMarkerStatsWindow:SetHidden(false)
    QuickMarker_UpdateStatsDisplay()

    -- Hide distance label when stats window is open
    if QuickMarker.distanceLabel then
        QuickMarker.distanceLabel:GetParent():SetHidden(true)
    end
end

-- Hide statistics window
function QuickMarker_HideStatsWindow()
    if QuickMarkerStatsWindow then
        QuickMarkerStatsWindow:SetHidden(true)
    end

    -- Distance label visibility will be restored by UpdateWorldPins on next frame
end

-- Toggle statistics window (for keybinding)
function QuickMarker_ToggleStatsWindow()
    if not QuickMarkerStatsWindow then return end

    if QuickMarkerStatsWindow:IsHidden() then
        QuickMarker_ShowStatsWindow()
    else
        QuickMarker_HideStatsWindow()
    end
end

-- Toggle filter
function QuickMarker_ToggleFilter(craftType)
    if not QuickMarker.savedVars or not QuickMarker.savedVars.statistics then return end

    local filters = QuickMarker.savedVars.statistics.filters
    filters[craftType] = not filters[craftType]

    -- Update checkbox texture
    local checkbox = WINDOW_MANAGER:GetControlByName("QuickMarkerStatsWindowFilters" .. craftType:gsub("^%l", string.upper) .. "Checkbox")
    if checkbox then
        if filters[craftType] then
            checkbox:SetNormalTexture("esoui/art/buttons/checkbox_checked.dds")
            checkbox:SetPressedTexture("esoui/art/buttons/checkbox_checked_down.dds")
            checkbox:SetMouseOverTexture("esoui/art/buttons/checkbox_checked_over.dds")
        else
            checkbox:SetNormalTexture("esoui/art/buttons/checkbox_unchecked.dds")
            checkbox:SetPressedTexture("esoui/art/buttons/checkbox_unchecked_down.dds")
            checkbox:SetMouseOverTexture("esoui/art/buttons/checkbox_unchecked_over.dds")
        end
    end

    QuickMarker_UpdateStatsDisplay()
end

-- Toggle craft expansion (show/hide resources)
function QuickMarker_ToggleExpanded(craftType)
    if not QuickMarker.savedVars or not QuickMarker.savedVars.statistics then return end

    local expanded = QuickMarker.savedVars.statistics.expanded
    expanded[craftType] = not expanded[craftType]

    QuickMarker_UpdateStatsDisplay()
end

-- Update statistics display
function QuickMarker_UpdateStatsDisplay()
    if not QuickMarkerStatsWindow or QuickMarkerStatsWindow:IsHidden() then return end
    if not QuickMarker.savedVars or not QuickMarker.savedVars.statistics then return end

    local scrollChild = QuickMarkerStatsWindowContentScrollChild
    local headersContainer = QuickMarkerStatsWindowHeaders
    if not scrollChild or not headersContainer then return end

    -- Clear existing content - use a pool or unique names
    -- Store counter to make unique names
    if not QuickMarker.statsControlCounter then
        QuickMarker.statsControlCounter = 0
    end
    QuickMarker.statsControlCounter = QuickMarker.statsControlCounter + 1
    local uniqueId = QuickMarker.statsControlCounter

    -- Hide all existing children in scroll area
    for i = 1, scrollChild:GetNumChildren() do
        local child = scrollChild:GetChild(i)
        if child then
            child:SetHidden(true)
        end
    end

    -- Hide all existing children in headers
    for i = 1, headersContainer:GetNumChildren() do
        local child = headersContainer:GetChild(i)
        if child then
            child:SetHidden(true)
        end
    end

    -- Get filtered statistics
    local stats = QuickMarker:GetStatistics(QuickMarker.savedVars.statistics.filters)

    -- Build display
    local yOffset = 10
    local lineHeight = 25
    local sectionGap = 15

    -- Craft type names
    local craftNames = {
        alchemist = "Alchemy",
        blacksmith = "Blacksmith",
        clothier = "Clothier",
        enchanting = "Enchanting",
        jewelry = "Jewelry Crafting",
        woodworking = "Woodworking"
    }

    -- Check if there's any data
    local hasData = false
    for _ in pairs(stats) do
        hasData = true
        break
    end

    -- Table column widths
    local col1Width = 140  -- Profession
    local col2Width = 80   -- Surveys count
    local col3Width = 245  -- Survey price (total + per unit)
    local col4Width = 210  -- Resource name
    local col5Width = 80   -- Resource quantity
    local col6Width = 245  -- Resource price (total + per unit)
    local col7Width = 130  -- Profit

    -- ==========================================
    -- TABLE HEADERS (Fixed in separate container)
    -- ==========================================
    local headerY = 5
    local headerLabels = {
        {text = "Profession", x = 10, width = col1Width, lines = 1},
        {text = "Surveys", x = 10 + col1Width, width = col2Width, lines = 1},
        {text = "Survey Price", x = 10 + col1Width + col2Width, width = col3Width, lines = 1},
        {text = "Resources", x = 10 + col1Width + col2Width + col3Width, width = col4Width, lines = 1},
        {text = "Quantity", x = 10 + col1Width + col2Width + col3Width + col4Width, width = col5Width, lines = 1},
        {text = "Resource Price", x = 10 + col1Width + col2Width + col3Width + col4Width + col5Width, width = col6Width, lines = 1},
        {text = "Profit", x = 10 + col1Width + col2Width + col3Width + col4Width + col5Width + col6Width, width = col7Width, lines = 1},
    }

    for i, header in ipairs(headerLabels) do
        local headerLabel = WINDOW_MANAGER:CreateControl("QuickMarkerStatsHeader_" .. uniqueId .. "_" .. i, headersContainer, CT_LABEL)
        headerLabel:SetFont("ZoFontWinH3")
        headerLabel:SetColor(1, 0.67, 0.2, 1) -- Orange
        headerLabel:SetText(header.text)
        headerLabel:SetAnchor(TOPLEFT, headersContainer, TOPLEFT, header.x, headerY)
        headerLabel:SetDimensions(header.width, 20)
        -- First column (Profession) and Resources are left-aligned, all others are center-aligned
        if i == 1 or i == 4 then
            headerLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        else
            headerLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        end
        headerLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        headerLabel:SetHidden(false)

        -- Add "(per unit)" subtitle for columns 3 and 6
        if i == 3 or i == 6 then
            local subLabel = WINDOW_MANAGER:CreateControl("QuickMarkerStatsHeaderSub_" .. uniqueId .. "_" .. i, headersContainer, CT_LABEL)
            subLabel:SetFont("ZoFontGame")
            subLabel:SetColor(1, 0.67, 0.2, 1) -- Orange
            subLabel:SetText("(per unit)")
            subLabel:SetAnchor(TOPLEFT, headersContainer, TOPLEFT, header.x, headerY + 20)
            subLabel:SetDimensions(header.width, 20)
            subLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            subLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
            subLabel:SetHidden(false)
        end
    end

    -- ==========================================
    -- TABLE DATA (Scrollable content)
    -- ==========================================
    if not hasData then
        -- Show "No data" message
        local label = WINDOW_MANAGER:CreateControl("QuickMarkerStatsNoData_" .. uniqueId, scrollChild, CT_LABEL)
        label:SetFont("ZoFontWinH3")
        label:SetColor(0.7, 0.7, 0.7, 1)
        label:SetText("No statistics collected yet. Use surveys to start tracking!")
        label:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, 10, yOffset)
        label:SetHidden(false)
        scrollChild:SetHeight(100)
        return
    end

    yOffset = 10

    -- Display statistics by craft type (aggregated, no zones)
    local totalSurveys = 0
    local totalSurveyPrice = 0
    local totalResourceValue = 0
    local totalProfit = 0
    local hasPriceData = false

    -- Sort craft types alphabetically by display name
    local sortedCraftTypes = {}
    for craftType in pairs(stats) do
        table.insert(sortedCraftTypes, craftType)
    end
    table.sort(sortedCraftTypes, function(a, b)
        return craftNames[a] < craftNames[b]
    end)

    for _, craftType in ipairs(sortedCraftTypes) do
        local craftData = stats[craftType]
        local rowStartY = yOffset
        local maxRowHeight = lineHeight

        -- Column 1: Profession name (clickable button to expand/collapse)
        local isExpanded = QuickMarker.savedVars.statistics.expanded[craftType]
        local expandIcon = isExpanded and "[-] " or "[+] "

        local profButton = WINDOW_MANAGER:CreateControl("QuickMarkerStatsProf_" .. uniqueId .. "_" .. craftType, scrollChild, CT_BUTTON)
        profButton:SetFont("ZoFontGame")
        profButton:SetNormalFontColor(0.91, 0.87, 0.69, 1)
        profButton:SetMouseOverFontColor(1, 1, 1, 1)
        profButton:SetText(expandIcon .. craftNames[craftType])
        profButton:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, 10, rowStartY)
        profButton:SetDimensions(col1Width, lineHeight)
        profButton:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        profButton:SetHandler("OnClicked", function()
            QuickMarker_ToggleExpanded(craftType)
        end)
        profButton:SetHidden(false)

        -- Column 2: Surveys count
        local surveyLabel = WINDOW_MANAGER:CreateControl("QuickMarkerStatsSurveys_" .. uniqueId .. "_" .. craftType, scrollChild, CT_LABEL)
        surveyLabel:SetFont("ZoFontGame")
        surveyLabel:SetColor(0.91, 0.87, 0.69, 1)
        surveyLabel:SetText(tostring(craftData.surveysUsed))
        surveyLabel:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, 10 + col1Width, rowStartY)
        surveyLabel:SetDimensions(col2Width, lineHeight)
        surveyLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        surveyLabel:SetHidden(false)

        -- Column 3: Survey price (from ATT if available) - total and per unit
        local surveyPrice, isFromATT = QuickMarker:GetSurveyContainerPrice(craftType, 30)
        local surveyPriceText
        if surveyPrice then
            local totalSurveyPrice = surveyPrice * craftData.surveysUsed
            surveyPriceText = QuickMarker:FormatPrice(totalSurveyPrice) .. " (" .. QuickMarker:FormatPrice(surveyPrice) .. ")"
        else
            surveyPriceText = "-"
        end
        local surveyPriceLabel = WINDOW_MANAGER:CreateControl("QuickMarkerStatsSurveyPrice_" .. uniqueId .. "_" .. craftType, scrollChild, CT_LABEL)
        surveyPriceLabel:SetFont("ZoFontGame")
        -- Yellow if from ATT, gray if fallback or no price
        if surveyPrice then
            if isFromATT then
                surveyPriceLabel:SetColor(1, 0.84, 0, 1) -- Yellow (ATT price)
            else
                surveyPriceLabel:SetColor(0.7, 0.7, 0.7, 1) -- Gray (fallback price)
            end
        else
            surveyPriceLabel:SetColor(0.7, 0.7, 0.7, 1) -- Gray (no price)
        end
        surveyPriceLabel:SetText(surveyPriceText)
        surveyPriceLabel:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, 10 + col1Width + col2Width, rowStartY)
        surveyPriceLabel:SetDimensions(col3Width, lineHeight)
        surveyPriceLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        surveyPriceLabel:SetHidden(false)

        -- Calculate total resource value for profit calculation
        local craftResourceValue = 0
        for itemId, itemData in pairs(craftData.itemsCollected) do
            local resourcePrice, _ = QuickMarker:GetPriceFromATT(itemId, 30)
            if resourcePrice then
                craftResourceValue = craftResourceValue + (resourcePrice * itemData.quantity)
            end
        end

        -- Accumulate totals
        totalSurveys = totalSurveys + craftData.surveysUsed
        if surveyPrice then
            totalSurveyPrice = totalSurveyPrice + (surveyPrice * craftData.surveysUsed)
            hasPriceData = true
        end
        totalResourceValue = totalResourceValue + craftResourceValue

        -- Column 7: Profit (total resources - total surveys)
        local profitValue = nil
        local profitText = "-"
        if surveyPrice and craftResourceValue > 0 then
            profitValue = craftResourceValue - (surveyPrice * craftData.surveysUsed)
            totalProfit = totalProfit + profitValue
            profitText = QuickMarker:FormatPrice(math.abs(profitValue))
        end
        local profitLabel = WINDOW_MANAGER:CreateControl("QuickMarkerStatsProfit_" .. uniqueId .. "_" .. craftType, scrollChild, CT_LABEL)
        profitLabel:SetFont("ZoFontGame")
        -- Color: green if positive, red if negative, gray if no data
        if profitValue then
            if profitValue >= 0 then
                profitLabel:SetColor(0.4, 0.8, 0.4, 1) -- Green
            else
                profitLabel:SetColor(0.8, 0.4, 0.4, 1) -- Red
                profitText = "-" .. profitText -- Add minus sign for negative
            end
        else
            profitLabel:SetColor(0.7, 0.7, 0.7, 1) -- Gray
        end
        profitLabel:SetText(profitText)
        profitLabel:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, 10 + col1Width + col2Width + col3Width + col4Width + col5Width + col6Width, rowStartY)
        profitLabel:SetDimensions(col7Width, lineHeight)
        profitLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        profitLabel:SetHidden(false)

        -- Columns 4-6: Resources (can be multiple rows) OR total value when collapsed
        local resourceY = rowStartY
        local resourceCount = 0

        -- Check if this craft is expanded
        local isExpanded = QuickMarker.savedVars.statistics.expanded[craftType]

        if isExpanded then
            -- Show detailed resources list
            -- Sort resources alphabetically by name
            local sortedResources = {}
            for itemId, itemData in pairs(craftData.itemsCollected) do
                local itemNameClean = itemData.name:gsub("|H.-|h(.-)|h", "%1") -- Remove item link formatting
                table.insert(sortedResources, {id = itemId, data = itemData, cleanName = itemNameClean})
            end
            table.sort(sortedResources, function(a, b)
                return a.cleanName < b.cleanName
            end)

            for _, resource in ipairs(sortedResources) do
                local itemId = resource.id
                local itemData = resource.data
                local itemNameClean = resource.cleanName
                resourceCount = resourceCount + 1

                -- Column 4: Resource name
                local resLabel = WINDOW_MANAGER:CreateControl("QuickMarkerStatsRes_" .. uniqueId .. "_" .. craftType .. "_" .. itemId, scrollChild, CT_LABEL)
                resLabel:SetFont("ZoFontGame")
                resLabel:SetColor(0.7, 0.7, 0.7, 1)
                resLabel:SetText(itemNameClean)
                resLabel:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, 10 + col1Width + col2Width + col3Width, resourceY)
                resLabel:SetDimensions(col4Width, lineHeight)
                resLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
                resLabel:SetHidden(false)

                -- Column 5: Resource quantity
                local qtyLabel = WINDOW_MANAGER:CreateControl("QuickMarkerStatsQty_" .. uniqueId .. "_" .. craftType .. "_" .. itemId, scrollChild, CT_LABEL)
                qtyLabel:SetFont("ZoFontGame")
                qtyLabel:SetColor(0.7, 0.7, 0.7, 1)
                qtyLabel:SetText(tostring(itemData.quantity))
                qtyLabel:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, 10 + col1Width + col2Width + col3Width + col4Width, resourceY)
                qtyLabel:SetDimensions(col5Width, lineHeight)
                qtyLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
                qtyLabel:SetHidden(false)

                -- Column 6: Resource price (from ATT if available)
                local resourcePrice, isResourceFromATT = QuickMarker:GetPriceFromATT(itemId, 30)
                local resourcePriceText
                if resourcePrice then
                    local totalPrice = resourcePrice * itemData.quantity
                    resourcePriceText = QuickMarker:FormatPrice(totalPrice) .. " (" .. QuickMarker:FormatPrice(resourcePrice) .. ")"
                else
                    resourcePriceText = "-"
                end
                local resPriceLabel = WINDOW_MANAGER:CreateControl("QuickMarkerStatsResPrice_" .. uniqueId .. "_" .. craftType .. "_" .. itemId, scrollChild, CT_LABEL)
                resPriceLabel:SetFont("ZoFontGame")
                -- Yellow if from ATT, gray if fallback or no price
                if resourcePrice then
                    if isResourceFromATT then
                        resPriceLabel:SetColor(1, 0.84, 0, 1) -- Yellow (ATT price)
                    else
                        resPriceLabel:SetColor(0.7, 0.7, 0.7, 1) -- Gray (fallback price)
                    end
                else
                    resPriceLabel:SetColor(0.7, 0.7, 0.7, 1) -- Gray (no price)
                end
                resPriceLabel:SetText(resourcePriceText)
                resPriceLabel:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, 10 + col1Width + col2Width + col3Width + col4Width + col5Width, resourceY)
                resPriceLabel:SetDimensions(col6Width, lineHeight)
                resPriceLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
                resPriceLabel:SetHidden(false)

                resourceY = resourceY + lineHeight
            end
        else
            -- Show only total resource value (collapsed view)
            -- Column 6: Total resource value
            local totalResValueLabel = WINDOW_MANAGER:CreateControl("QuickMarkerStatsResTotal_" .. uniqueId .. "_" .. craftType, scrollChild, CT_LABEL)
            totalResValueLabel:SetFont("ZoFontGame")
            if craftResourceValue > 0 then
                totalResValueLabel:SetColor(0.91, 0.87, 0.69, 1)
            else
                totalResValueLabel:SetColor(0.7, 0.7, 0.7, 1)
            end
            totalResValueLabel:SetText(craftResourceValue > 0 and QuickMarker:FormatPrice(craftResourceValue) or "-")
            totalResValueLabel:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, 10 + col1Width + col2Width + col3Width + col4Width + col5Width, rowStartY)
            totalResValueLabel:SetDimensions(col6Width, lineHeight)
            totalResValueLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            totalResValueLabel:SetHidden(false)

            resourceCount = 1 -- Count as 1 row for collapsed view
        end

        -- Calculate row height (at least one line, or number of resources)
        maxRowHeight = math.max(lineHeight, resourceCount * lineHeight)
        yOffset = rowStartY + maxRowHeight + 5
    end

    scrollChild:SetHeight(yOffset + 20)

    -- ==========================================
    -- TOTAL ROW (Fixed at bottom, not in scroll)
    -- ==========================================
    local totalRow = QuickMarkerStatsWindowTotalRow
    if not totalRow then return end

    -- Clear existing children
    for i = totalRow:GetNumChildren(), 1, -1 do
        local child = totalRow:GetChild(i)
        if child then
            child:SetHidden(true)
        end
    end

    local totalY = 10

    -- Column 1: "Total" label
    local totalLabel = WINDOW_MANAGER:CreateControl("QuickMarkerStatsTotalLabel_" .. uniqueId, totalRow, CT_LABEL)
    totalLabel:SetFont("ZoFontWinH3")
    totalLabel:SetColor(1, 0.67, 0.2, 1) -- Orange
    totalLabel:SetText("Total")
    totalLabel:SetAnchor(TOPLEFT, totalRow, TOPLEFT, 10, totalY)
    totalLabel:SetDimensions(col1Width, lineHeight)
    totalLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    totalLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    totalLabel:SetHidden(false)

    -- Column 2: Total surveys
    local totalSurveysLabel = WINDOW_MANAGER:CreateControl("QuickMarkerStatsTotalSurveys_" .. uniqueId, totalRow, CT_LABEL)
    totalSurveysLabel:SetFont("ZoFontWinH3")
    totalSurveysLabel:SetColor(1, 0.67, 0.2, 1) -- Orange
    totalSurveysLabel:SetText(tostring(totalSurveys))
    totalSurveysLabel:SetAnchor(TOPLEFT, totalRow, TOPLEFT, 10 + col1Width, totalY)
    totalSurveysLabel:SetDimensions(col2Width, lineHeight)
    totalSurveysLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    totalSurveysLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    totalSurveysLabel:SetHidden(false)

    -- Column 3: Total survey price
    local totalSurveyPriceLabel = WINDOW_MANAGER:CreateControl("QuickMarkerStatsTotalSurveyPrice_" .. uniqueId, totalRow, CT_LABEL)
    totalSurveyPriceLabel:SetFont("ZoFontWinH3")
    totalSurveyPriceLabel:SetColor(hasPriceData and 1 or 0.7, hasPriceData and 0.67 or 0.7, hasPriceData and 0.2 or 0.7, 1) -- Orange if has data
    totalSurveyPriceLabel:SetText(hasPriceData and QuickMarker:FormatPrice(totalSurveyPrice) or "-")
    totalSurveyPriceLabel:SetAnchor(TOPLEFT, totalRow, TOPLEFT, 10 + col1Width + col2Width, totalY)
    totalSurveyPriceLabel:SetDimensions(col3Width, lineHeight)
    totalSurveyPriceLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    totalSurveyPriceLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    totalSurveyPriceLabel:SetHidden(false)

    -- Column 4-5: Empty (resources are per-craft)

    -- Column 6: Total resource value
    local totalResourceLabel = WINDOW_MANAGER:CreateControl("QuickMarkerStatsTotalResource_" .. uniqueId, totalRow, CT_LABEL)
    totalResourceLabel:SetFont("ZoFontWinH3")
    totalResourceLabel:SetColor(totalResourceValue > 0 and 1 or 0.7, totalResourceValue > 0 and 0.67 or 0.7, totalResourceValue > 0 and 0.2 or 0.7, 1) -- Orange if has data
    totalResourceLabel:SetText(totalResourceValue > 0 and QuickMarker:FormatPrice(totalResourceValue) or "-")
    totalResourceLabel:SetAnchor(TOPLEFT, totalRow, TOPLEFT, 10 + col1Width + col2Width + col3Width + col4Width + col5Width, totalY)
    totalResourceLabel:SetDimensions(col6Width, lineHeight)
    totalResourceLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    totalResourceLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    totalResourceLabel:SetHidden(false)

    -- Column 7: Total profit
    local totalProfitLabel = WINDOW_MANAGER:CreateControl("QuickMarkerStatsTotalProfit_" .. uniqueId, totalRow, CT_LABEL)
    totalProfitLabel:SetFont("ZoFontWinH3")
    if hasPriceData and totalResourceValue > 0 then
        if totalProfit >= 0 then
            totalProfitLabel:SetColor(0.4, 0.8, 0.4, 1) -- Green
            totalProfitLabel:SetText(QuickMarker:FormatPrice(totalProfit))
        else
            totalProfitLabel:SetColor(0.8, 0.4, 0.4, 1) -- Red
            totalProfitLabel:SetText("-" .. QuickMarker:FormatPrice(math.abs(totalProfit)))
        end
    else
        totalProfitLabel:SetColor(1, 0.67, 0.2, 1) -- Orange
        totalProfitLabel:SetText("-")
    end
    totalProfitLabel:SetAnchor(TOPLEFT, totalRow, TOPLEFT, 10 + col1Width + col2Width + col3Width + col4Width + col5Width + col6Width, totalY)
    totalProfitLabel:SetDimensions(col7Width, lineHeight)
    totalProfitLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    totalProfitLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    totalProfitLabel:SetHidden(false)
end

-- Clear statistics with confirmation
function QuickMarker_ClearStats()
    if not QuickMarker.savedVars or not QuickMarker.savedVars.statistics then return end

    -- Simple confirmation via chat
    d("|cFFFF00[QuickMarker]|r Type |cFF0000/qmclearstats confirm|r to clear all statistics")
end

-- Slash command to show stats window
SLASH_COMMANDS["/qmstats"] = function()
    QuickMarker_ShowStatsWindow()
end

-- Slash command to clear stats (with confirmation)
SLASH_COMMANDS["/qmclearstats"] = function(args)
    if args == "confirm" then
        QuickMarker:ClearStatistics()
        QuickMarker_UpdateStatsDisplay()
    else
        QuickMarker_ClearStats()
    end
end

-- Slash command to extract ATT prices for fallback table (DEVELOPER ONLY)
--[[
SLASH_COMMANDS["/qmprices"] = function()
    d("|cFFAA33[QuickMarker]|r Extracting prices from ATT...")
    d("Copy the output below and paste into FALLBACK_PRICES table:")
    d("----------------------------------------")

    local items = {
        -- Surveys
        {219849, "Blacksmith Survey"},
        {219850, "Clothier Survey"},
        {219851, "Woodworking Survey"},
        {219852, "Enchanting Survey"},
        {219853, "Alchemy Survey"},
        {219854, "Jewelry Survey"},
        -- Alchemy
        {30158, "Lady's Smock"},
        {30159, "Wormwood"},
        {30160, "Bugloss"},
        {30161, "Corn Flower"},
        {30162, "Dragonthorn"},
        {30163, "Mountain Flower"},
        {30164, "Columbine"},
        {30157, "Blessed Thistle"},
        -- Blacksmith
        {71198, "Rubedite Ore"},
        -- Clothier
        {71200, "Raw Ancestor Silk"},
        {71239, "Rubedo Leather"},
        -- Jewelry
        {135145, "Platinum Dust"},
        -- Woodworking
        {71199, "Ruby Ash Wood"},
        -- Enchanting
        {45831, "Oko"},
        {45832, "Makko"},
        {45833, "Deni"},
        {45834, "Okoma"},
        {45837, "Kuoko"},
        {45839, "Dekeipa"},
        {45840, "Meip"},
        {45841, "Haoko"},
        {45842, "Deteri"},
        {45843, "Okori"},
        {45846, "Oru"},
        {45847, "Taderi"},
        {45848, "Makderi"},
        {45849, "Kaderi"},
        {45850, "Ta"},
        {45851, "Jejota"},
        {45852, "Denata"},
        {45853, "Rekuta"},
        {45854, "Kuta"},
        {45855, "Jora"},
        {45856, "Porade"},
        {45857, "Jera"},
    }

    for _, item in ipairs(items) do
        local itemId = item[1]
        local itemName = item[2]
        local price, isFromATT = QuickMarker:GetPriceFromATT(itemId, 30)

        if price and price > 0 then
            d(string.format("    [%d] = %d, -- %s", itemId, math.floor(price), itemName))
        else
            d(string.format("    -- [%d] = 0, -- %s (no ATT data)", itemId, itemName))
        end
    end

    d("----------------------------------------")
    d("|cFFAA33[QuickMarker]|r Done! Copy the lines above.")
end
--]]

-- Slash command to verify item names by ID (DEVELOPER ONLY)
--[[
SLASH_COMMANDS["/qmnames"] = function()
    d("|cFFAA33[QuickMarker]|r Verifying item names from game data...")
    d("----------------------------------------")

    local categories = {
        {name = "=== SURVEY CONTAINERS ===", items = {219849, 219850, 219851, 219852, 219853, 219854}},
        {name = "=== ALCHEMY ===", items = {30158, 30159, 30160, 30161, 30162, 30163, 30164, 30157}},
        {name = "=== BLACKSMITH ===", items = {71198}},
        {name = "=== CLOTHIER ===", items = {71200, 71239}},
        {name = "=== JEWELRY ===", items = {135145}},
        {name = "=== WOODWORKING ===", items = {71199}},
        {name = "=== ENCHANTING RUNES (in SURVEY_ITEMS) ===", items = {45831, 45832, 45833, 45834, 45837, 45838, 45839, 45840, 45841, 45842, 45843, 45846, 45848, 45849, 45850, 45851, 45852, 45853, 45854, 64508, 64509, 68340, 68341}},
        {name = "=== MISSING FROM SURVEY_ITEMS ===", items = {45847, 45855, 45856, 45857}},
    }

    for _, category in ipairs(categories) do
        d(category.name)

        for _, itemId in ipairs(category.items) do
            local itemLink = string.format("|H1:item:%d:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId)
            local itemName = GetItemLinkName(itemLink)

            -- Get price to show alongside
            local price, isFromATT = QuickMarker:GetPriceFromATT(itemId, 30)
            local priceStr = price and string.format("%dg", math.floor(price)) or "no data"
            local source = isFromATT and "(ATT)" or "(fallback)"

            if itemName and itemName ~= "" then
                d(string.format("  [%d] %s - %s %s", itemId, zo_strformat(SI_TOOLTIP_ITEM_NAME, itemName), priceStr, source))
            else
                d(string.format("  [%d] UNKNOWN ITEM", itemId))
            end
        end
        d("")
    end

    d("----------------------------------------")
    d("|cFFAA33[QuickMarker]|r Done! Check if SURVEY_ITEMS matches FALLBACK_PRICES.")
end
--]]
