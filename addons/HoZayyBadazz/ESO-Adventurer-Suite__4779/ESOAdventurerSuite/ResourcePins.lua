-- ESO Adventurer Suite - Resource 3D Pins
-- Automatically learns resource-node locations when the player gathers them and
-- renders remembered locations as Suite-owned 3D world markers.
--
-- ESO does not expose a live list of resource-node world positions. A node is
-- therefore learned from the player's raw world position at interaction range,
-- with a small camera-heading offset toward the object.

ESOProgressionCoach = ESOProgressionCoach or {}
local EPC = ESOProgressionCoach

EPC.ResourcePins = EPC.ResourcePins or {}
local R = EPC.ResourcePins
local wm = WINDOW_MANAGER

local INTERACTION_UPDATE_MS = 100
local RENDER_UPDATE_MS = 450
local DEFAULT_VISIBLE_MARKERS = 72
local MIN_VISIBLE_MARKERS = 24
local MAX_VISIBLE_MARKERS = 120
local DEDUPE_DISTANCE_CM = 375
local INTERACT_FORWARD_OFFSET_CM = 145
local GLOW_VERTICAL_OFFSET_CM = 65
local RESOURCE_WINDOW_MS = 5000
local FISHING_RESOURCE_WINDOW_MS = 120000
local CHEST_RESOURCE_WINDOW_MS = 120000
local DEPLETED_PROBE_DISTANCE_M = 4.00
local DEPLETED_PROBE_HOLD_MS = 650
local DEPLETED_AUTO_LOCK_MS = 900
local POST_HARVEST_PROBE_GUARD_MS = 2200
local DEPLETED_PROBE_MOVE_CM = 450
local LIVE_COMMUNITY_VANISH_MS = 450
local LIVE_COMMUNITY_MEMORY_MS = 4500
local LIVE_COMMUNITY_FACING_DOT = 0.90
local MISSING_PIN_FACING_DOT = 0.72
local MISSING_PIN_MATCH_CM = 90
local DEPLETED_CELL_CM = 350
local DEPLETED_MATCH_CM = 475
local FISHING_DEPLETED_CLUSTER_CM = 1000
local FISHING_COMMUNITY_CLUSTER_SCAN_CM = 2200
local FISHING_COMMUNITY_CLUSTER_VERTICAL_CM = 650
local BASE_GLOW_WIDTH_M = 1.15
local BASE_GLOW_HEIGHT_M = 1.15
local GLOW_TEXTURE = "EsoUI/Art/Miscellaneous/lensflare_star_256.dds"
local GLOW_U1, GLOW_U2, GLOW_V1, GLOW_V2 = 0.22, 0.78, 0.22, 0.78

local WORLD_GLOW_HIDE_SCENES = {
    "gameMenuInGame", "inventory", "character", "skills", "championPerks",
    "journal", "collectionsBook", "groupMenu", "contacts", "guildHome",
    "mailInbox", "bank", "store", "tradingHouse", "crafting", "settings",
    "worldMap", "gamepad_worldMap", "gamepad_inventory_root",
    "gamepad_character_root", "gamepad_skills_root", "gamepad_journal_root",
    "gamepad_collections_book", "gamepad_group_root", "gamepad_options_root",
    "gamepad_player_menu", "gamepad_main_menu", "gamepad_championPerks_root",
    "gamepad_store", "gamepad_banking", "gamepad_trading_house",
    "gamepad_mail_manager", "gamepad_guild_hub", "gamepad_contacts_root",
}

local COLORS = {
    ORE = { 1.00, 0.68, 0.18 },
    WOOD = { 0.82, 0.56, 0.30 },
    CLOTH = { 0.55, 0.78, 1.00 },
    ALCHEMY = { 0.42, 1.00, 0.46 },
    MUSHROOM = { 0.50, 0.90, 0.48 },
    FLOWER = { 0.48, 1.00, 0.58 },
    WATERPLANT = { 0.32, 0.92, 0.68 },
    RUNE = { 0.78, 0.48, 1.00 },
    WATER = { 0.32, 0.84, 1.00 },
    FISHING = { 0.25, 0.94, 0.87 },
    CHEST = { 0.30, 0.92, 0.92 },
    HEAVYSACK = { 0.62, 0.92, 0.52 },
    CLAM = { 0.62, 0.92, 0.52 },
    TROVE = { 0.72, 0.48, 1.00 },
    JUSTICE = { 0.94, 0.46, 0.94 },
    STASH = { 0.94, 0.46, 0.94 },
    RESOURCE = { 1.00, 0.92, 0.45 },
}

local TYPE_LABELS = {
    ORE = "Ore / Jewelry Seam",
    WOOD = "Wood",
    CLOTH = "Cloth",
    ALCHEMY = "Alchemy",
    MUSHROOM = "Mushroom",
    FLOWER = "Flower / Herb",
    WATERPLANT = "Water Plant",
    RUNE = "Runestone",
    WATER = "Water / Solvent",
    FISHING = "Fishing Hole",
    CHEST = "Chest",
    HEAVYSACK = "Heavy Sack",
    CLAM = "Giant Clam",
    TROVE = "Thieves Trove",
    JUSTICE = "Justice Container",
    STASH = "Hidden Stash",
    RESOURCE = "Resource",
}


local GLOW_TIERS = {
    -- Rarity changes color/intensity, not icon footprint. Keeping the halo size
    -- stable prevents higher tiers from looking physically larger in-world.
    COMMON = { color = { 0.95, 0.95, 0.95 }, alpha = 0.34, size = 1.00 },
    UNCOMMON = { color = { 0.28, 0.86, 1.00 }, alpha = 0.46, size = 1.00 },
    RARE = { color = { 0.82, 0.40, 1.00 }, alpha = 0.58, size = 1.00 },
    EPIC = { color = { 1.00, 0.78, 0.22 }, alpha = 0.70, size = 1.00 },
}

local ICON_TEXTURES = {
    SUITE_GLOW = GLOW_TEXTURE,
    WORLD = "ESOAdventurerSuite/Art/ResourcePins/world_marker.dds",
    MINING = "ESOAdventurerSuite/Art/ResourcePins/mining.dds",
    WOOD = "ESOAdventurerSuite/Art/ResourcePins/wood.dds",
    CLOTHING = "ESOAdventurerSuite/Art/ResourcePins/clothing.dds",
    ALCHEMY = "ESOAdventurerSuite/Art/ResourcePins/alchemy.dds",
    ENCHANTING = "ESOAdventurerSuite/Art/ResourcePins/enchanting.dds",
    MUSHROOM = "ESOAdventurerSuite/Art/ResourcePins/mushroom.dds",
    FLOWER = "ESOAdventurerSuite/Art/ResourcePins/flower.dds",
    WATERPLANT = "ESOAdventurerSuite/Art/ResourcePins/waterplant.dds",
    SOLVENT = "ESOAdventurerSuite/Art/ResourcePins/solvent.dds",
    FISH = "ESOAdventurerSuite/Art/ResourcePins/fish.dds",
    CHEST = "ESOAdventurerSuite/Art/ResourcePins/chest.dds",
    HEAVYSACK = "ESOAdventurerSuite/Art/ResourcePins/heavysack.dds",
    CLAM = "ESOAdventurerSuite/Art/ResourcePins/clam.dds",
    TROVE = "ESOAdventurerSuite/Art/ResourcePins/trove.dds",
    JUSTICE = "ESOAdventurerSuite/Art/ResourcePins/justice.dds",
    STASH = "ESOAdventurerSuite/Art/ResourcePins/stash.dds",
}


local NATIVE_ICON_TEXTURES = {
    -- Resource-style ESO textures. Avoid master-writ/Zone Story artwork here:
    -- those read visually as books/pages when used as 3D world markers.
    WORLD = "/esoui/art/icons/poi/poi_crafting_complete.dds",
    MINING = "/esoui/art/crafting/smithing_tabicon_refine_down.dds",
    WOOD = "/esoui/art/icons/mapkey/mapkey_lumbermill.dds",
    CLOTHING = "/esoui/art/icons/servicemappins/servicepin_clothier.dds",
    ALCHEMY = "/esoui/art/crafting/alchemy_tabicon_reagent_down.dds",
    ENCHANTING = "/esoui/art/crafting/enchantment_tabicon_essence_down.dds",
    MUSHROOM = "/esoui/art/crafting/alchemy_tabicon_reagent_down.dds",
    FLOWER = "/esoui/art/crafting/alchemy_tabicon_reagent_down.dds",
    WATERPLANT = "/esoui/art/crafting/alchemy_tabicon_solvent_up.dds",
    SOLVENT = "/esoui/art/crafting/alchemy_tabicon_solvent_up.dds",
    FISH = "/esoui/art/icons/crafting_fishing_perch.dds",
    CHEST = "/esoui/art/icons/mapkey/mapkey_areaofinterest.dds",
    HEAVYSACK = "/esoui/art/treeicons/store_indexicon_consumables_down.dds",
    CLAM = "/esoui/art/icons/crafting_fishing_perch.dds",
    TROVE = "/esoui/art/icons/mapkey/mapkey_areaofinterest.dds",
    JUSTICE = "/esoui/art/icons/servicemappins/servicepin_fence.dds",
    STASH = "/esoui/art/icons/servicemappins/servicepin_fence.dds",
}

local NATIVE_ICON_SCALE = {
    WORLD = 0.78,
    MINING = 0.82,
    WOOD = 0.86,
    CLOTHING = 0.80,
    ALCHEMY = 1.18,
    ENCHANTING = 0.66,
    MUSHROOM = 1.18,
    FLOWER = 1.18,
    WATERPLANT = 1.08,
    SOLVENT = 1.08,
    FISH = 0.88,
    CHEST = 0.82,
    HEAVYSACK = 0.84,
    CLAM = 0.88,
    TROVE = 0.82,
    JUSTICE = 0.82,
    STASH = 0.82,
}

local AUTO_ICON = {
    ORE = "MINING", WOOD = "WOOD", CLOTH = "CLOTHING", ALCHEMY = "ALCHEMY",
    MUSHROOM = "MUSHROOM", FLOWER = "FLOWER", WATERPLANT = "WATERPLANT",
    RUNE = "ENCHANTING", WATER = "SOLVENT", FISHING = "FISH", CHEST = "CHEST",
    HEAVYSACK = "HEAVYSACK", CLAM = "CLAM", TROVE = "TROVE", JUSTICE = "JUSTICE",
    STASH = "STASH", RESOURCE = "WORLD",
}

local CUSTOM_ICON_SETTING = {
    ORE = "resourcePinsIconOre", WOOD = "resourcePinsIconWood", CLOTH = "resourcePinsIconCloth",
    ALCHEMY = "resourcePinsIconAlchemy", MUSHROOM = "resourcePinsIconAlchemy", FLOWER = "resourcePinsIconAlchemy",
    WATERPLANT = "resourcePinsIconAlchemy", RUNE = "resourcePinsIconRunes", WATER = "resourcePinsIconWater",
    FISHING = "resourcePinsIconFishing", CHEST = "resourcePinsIconSpecial", HEAVYSACK = "resourcePinsIconSpecial",
    CLAM = "resourcePinsIconSpecial", TROVE = "resourcePinsIconSpecial", JUSTICE = "resourcePinsIconSpecial",
    STASH = "resourcePinsIconSpecial", RESOURCE = "resourcePinsIconOther",
}

-- Bundled Suite Community Resource Data. The supplied database stores coordinates
-- in 0.2 meter increments using horizontal X/Y and vertical Z. ESO raw world
-- positions use centimeters and X/Y(vertical)/Z(horizontal), so the decoder
-- remaps axes while converting to centimeters.
local COMMUNITY_GRID_CM = 5000
local COMMUNITY_DEDUPE_CM = DEDUPE_DISTANCE_CM
local COMMUNITY_DATASET_RECORDS = 124625
local COMMUNITY_MODULES = { "AD", "DC", "DLC", "EP", "NF" }
local COMMUNITY_KIND_BY_PIN = {
    [1] = "ORE", [17] = "ORE",
    [2] = "CLOTH",
    [3] = "RUNE", [16] = "RUNE",
    [4] = "MUSHROOM",
    [5] = "WOOD",
    [6] = "CHEST",
    [7] = "WATER",
    [8] = "FISHING",
    [9] = "HEAVYSACK",
    [10] = "TROVE",
    [11] = "JUSTICE",
    [12] = "STASH",
    [13] = "FLOWER",
    [14] = "WATERPLANT",
    [15] = "CLAM",
    [18] = "RESOURCE",
    [19] = "FLOWER",
    [20] = "ALCHEMY",
}

local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a, b, c, d, e, f, g, h = pcall(fn, ...)
    if not ok then return fallback end
    return a, b, c, d, e, f, g, h
end

local function lower(value)
    value = tostring(value or "")
    if type(zo_strlower) == "function" then
        local ok, result = pcall(zo_strlower, value)
        if ok and type(result) == "string" then return result end
    end
    return string.lower(value)
end

local function nowMs()
    if type(GetFrameTimeMilliseconds) == "function" then return tonumber(GetFrameTimeMilliseconds()) or 0 end
    return 0
end

local function nowStamp()
    if type(GetTimeStamp) == "function" then return tonumber(GetTimeStamp()) or 0 end
    return 0
end

local function distance2Dcm(ax, az, bx, bz)
    local dx = (tonumber(ax) or 0) - (tonumber(bx) or 0)
    local dz = (tonumber(az) or 0) - (tonumber(bz) or 0)
    return math.sqrt((dx * dx) + (dz * dz))
end

local function distance3Dcm(ax, ay, az, bx, by, bz)
    local dx = (tonumber(ax) or 0) - (tonumber(bx) or 0)
    local dy = (tonumber(ay) or 0) - (tonumber(by) or 0)
    local dz = (tonumber(az) or 0) - (tonumber(bz) or 0)
    return math.sqrt((dx * dx) + (dy * dy) + (dz * dz))
end

local function gridKey(x, z, cellSize)
    cellSize = tonumber(cellSize) or COMMUNITY_GRID_CM
    local gx = math.floor((tonumber(x) or 0) / cellSize)
    local gz = math.floor((tonumber(z) or 0) / cellSize)
    return tostring(gx) .. ":" .. tostring(gz), gx, gz
end

local function addType(map, globalName, kind)
    local value = rawget(_G, globalName)
    if value ~= nil then map[value] = kind end
end

local ITEM_KIND = {}
addType(ITEM_KIND, "ITEMTYPE_BLACKSMITHING_RAW_MATERIAL", "ORE")
addType(ITEM_KIND, "ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL", "ORE")
addType(ITEM_KIND, "ITEMTYPE_WOODWORKING_RAW_MATERIAL", "WOOD")
addType(ITEM_KIND, "ITEMTYPE_CLOTHIER_RAW_MATERIAL", "CLOTH")
addType(ITEM_KIND, "ITEMTYPE_REAGENT", "ALCHEMY")
addType(ITEM_KIND, "ITEMTYPE_ENCHANTING_RUNE_ASPECT", "RUNE")
addType(ITEM_KIND, "ITEMTYPE_ENCHANTING_RUNE_ESSENCE", "RUNE")
addType(ITEM_KIND, "ITEMTYPE_ENCHANTING_RUNE_POTENCY", "RUNE")
addType(ITEM_KIND, "ITEMTYPE_POTION_BASE", "WATER")
addType(ITEM_KIND, "ITEMTYPE_POISON_BASE", "WATER")


local ITEM_ID_KIND = {
    [30148]="MUSHROOM", [30149]="MUSHROOM", [30151]="MUSHROOM", [30152]="MUSHROOM",
    [30153]="MUSHROOM", [30154]="MUSHROOM", [30155]="MUSHROOM", [30156]="MUSHROOM",
    [30157]="FLOWER", [30158]="FLOWER", [30159]="FLOWER", [30160]="FLOWER",
    [30161]="FLOWER", [30162]="FLOWER", [30163]="FLOWER", [30164]="FLOWER",
    [30165]="WATERPLANT", [30166]="WATERPLANT", [77590]="FLOWER",
}

local SPECIAL_NAME_KIND = {
    ["heavy sack"]="HEAVYSACK", ["heavy crate"]="HEAVYSACK", ["thieves trove"]="TROVE",
    ["loose panel"]="STASH", ["loose tile"]="STASH", ["loose stone"]="STASH",
    ["giant clam"]="CLAM", ["herbalist's satchel"]="ALCHEMY", ["psijic portal"]="RUNE",
}

local function clamp01(v)
    v = tonumber(v) or 0
    if v < 0 then return 0 end
    if v > 1 then return 1 end
    return v
end

function R:GetGlowTierForKind(kind)
    kind = tostring(kind or "RESOURCE")
    if kind == "CHEST" or kind == "TROVE" then return "EPIC" end
    if kind == "HEAVYSACK" or kind == "CLAM" or kind == "JUSTICE" or kind == "STASH" then return "RARE" end
    if kind == "RUNE" or kind == "ALCHEMY" or kind == "MUSHROOM" or kind == "FLOWER" or kind == "WATERPLANT" or kind == "FISHING" then return "UNCOMMON" end
    return "COMMON"
end

function R:GetGlowVisualForEntry(entry, alphaBase)
    local saved = EPC.saved or {}
    local strength = clamp01((tonumber(saved.resourcePinsGlowStrength) or 78) / 100)
    local tierName = (saved.resourcePinsValueGlow == false) and "COMMON" or self:GetGlowTierForKind(entry and entry.kind)
    local tier = GLOW_TIERS[tierName] or GLOW_TIERS.COMMON
    local color = tier.color or { 1, 1, 1 }
    local alpha = math.max(0.20, math.min(0.95, (tonumber(alphaBase) or 0.72) * (tonumber(tier.alpha) or 0.42) * (0.55 + (strength * 0.75))))
    -- Keep the halo footprint tight so every icon gets the same rune-like glow ring.
    local size = 0.98 + (0.08 * strength)
    return color, alpha, size, tierName
end

function R:GetDepletedCooldownSeconds()
    local saved = EPC.saved or {}
    local minutes = math.max(1, math.min(30, tonumber(saved.resourcePinsDepletedCooldownMinutes) or 5))
    return math.floor(minutes * 60)
end

function R:GetDepletedCellKey(x, z)
    local gx = math.floor(((tonumber(x) or 0) / DEPLETED_CELL_CM) + 0.5)
    local gz = math.floor(((tonumber(z) or 0) / DEPLETED_CELL_CM) + 0.5)
    return tostring(gx) .. ":" .. tostring(gz), gx, gz
end

function R:GetDepletedZoneBucket(zoneId, create)
    if not EPC.saved then return nil end
    EPC.saved.resourcePinsDepleted = EPC.saved.resourcePinsDepleted or {}
    zoneId = tostring(tonumber(zoneId) or zoneId or "0")
    local bucket = EPC.saved.resourcePinsDepleted[zoneId]
    if type(bucket) ~= "table" and create then
        bucket = {}
        EPC.saved.resourcePinsDepleted[zoneId] = bucket
    end
    return bucket
end

function R:PruneDepleted(zoneId)
    local bucket = self:GetDepletedZoneBucket(zoneId, false)
    if type(bucket) ~= "table" then return 0 end
    local now = nowStamp()
    local count = 0
    for key, record in pairs(bucket) do
        local untilStamp = type(record) == "table" and tonumber(record.untilStamp) or tonumber(record)
        if not untilStamp or untilStamp <= now then
            bucket[key] = nil
        else
            count = count + 1
        end
    end
    return count
end

function R:IsPositionDepleted(zoneId, x, z, kind)
    if not EPC.saved or EPC.saved.resourcePinsHideDepleted == false then return false end
    local bucket = self:GetDepletedZoneBucket(zoneId, false)
    if type(bucket) ~= "table" then return false end

    local now = nowStamp()
    local entryKind = tostring(kind or "")
    x, z = tonumber(x), tonumber(z)
    if not x or not z then return false end

    -- Depleted records are intentionally scanned directly. The active depleted
    -- list is small and short-lived, while direct scanning lets exact-pin records
    -- use unique coordinate keys instead of colliding in the 3.5m grid cell.
    for key, record in pairs(bucket) do
        local untilStamp = type(record) == "table" and tonumber(record.untilStamp) or tonumber(record)
        if not untilStamp or untilStamp <= now then
            bucket[key] = nil
        else
            local rx = type(record) == "table" and tonumber(record.x) or nil
            local rz = type(record) == "table" and tonumber(record.z) or nil
            if rx and rz then
                local recordKind = type(record) == "table" and tostring(record.kind or "") or ""
                local sameKindOnly = type(record) == "table" and record.sameKindOnly == true
                local exactPinOnly = type(record) == "table" and record.exactPinOnly == true
                local radiusCm = type(record) == "table" and tonumber(record.radiusCm) or DEPLETED_MATCH_CM
                if exactPinOnly then
                    radiusCm = math.max(75, radiusCm or MISSING_PIN_MATCH_CM)
                else
                    radiusCm = math.max(DEPLETED_MATCH_CM, radiusCm or DEPLETED_MATCH_CM)
                end
                local kindMatches = not sameKindOnly or entryKind == "" or recordKind == "" or entryKind == recordKind
                if kindMatches and distance2Dcm(x, z, rx, rz) <= radiusCm then return true end
            end
        end
    end
    return false
end

function R:MarkPositionDepleted(zoneId, x, z, reason, kind, radiusCm, sameKindOnly, exactPinOnly)
    if not EPC.saved or EPC.saved.resourcePinsHideDepleted == false then return false end
    zoneId, x, z = tonumber(zoneId), tonumber(x), tonumber(z)
    if not zoneId or not x or not z then return false end
    local bucket = self:GetDepletedZoneBucket(zoneId, true)
    if not bucket then return false end

    local kindText = tostring(kind or "RESOURCE")
    local key
    if exactPinOnly == true then
        -- Exact empty-pin records need their own identity. Using only the broad
        -- depletion grid cell caused adjacent pins in the same cell to overwrite
        -- each other, which could leave the intended marker visible.
        key = string.format("pin:%d:%d:%s", math.floor(x + 0.5), math.floor(z + 0.5), kindText)
    else
        key = self:GetDepletedCellKey(x, z)
    end

    bucket[key] = {
        x = x, z = z,
        untilStamp = nowStamp() + self:GetDepletedCooldownSeconds(),
        reason = tostring(reason or "depleted"),
        kind = kindText,
        radiusCm = exactPinOnly == true and math.max(75, tonumber(radiusCm) or MISSING_PIN_MATCH_CM) or math.max(DEPLETED_MATCH_CM, tonumber(radiusCm) or DEPLETED_MATCH_CM),
        sameKindOnly = sameKindOnly == true,
        exactPinOnly = exactPinOnly == true,
    }
    self.lastDepletedReason = tostring(reason or "depleted")
    self.lastDepletedKind = kindText
    self.lastDepletedAt = nowStamp()
    return true
end

function R:MarkFishingCommunityClusterDepleted(zoneId, x, y, z)
    zoneId, x, y, z = tonumber(zoneId), tonumber(x), tonumber(y), tonumber(z)
    if not zoneId or not x or not z then return 0 end

    local cache = self:BuildCommunityZoneCache(zoneId)
    if type(cache) ~= "table" or type(cache.cells) ~= "table" then
        self:MarkPositionDepleted(zoneId, x, z, "fishing catch", "FISHING", FISHING_DEPLETED_CLUSTER_CM, true)
        return 1
    end

    local marked = 0
    local seen = {}
    local _, gx, gz = gridKey(x, z, COMMUNITY_GRID_CM)
    local cellRange = math.max(1, math.ceil(FISHING_COMMUNITY_CLUSTER_SCAN_CM / COMMUNITY_GRID_CM))
    for dx = -cellRange, cellRange do
        for dz = -cellRange, cellRange do
            local cell = tostring(gx + dx) .. ":" .. tostring(gz + dz)
            local entries = cache.cells[cell]
            if type(entries) == "table" then
                for i = 1, #entries do
                    local entry = entries[i]
                    if type(entry) == "table" and tostring(entry.kind or "") == "FISHING" then
                        local ex, ey, ez = tonumber(entry.x), tonumber(entry.y), tonumber(entry.z)
                        local horizontal = ex and ez and distance2Dcm(x, z, ex, ez) or nil
                        local verticalOk = not y or not ey or math.abs(ey - y) <= FISHING_COMMUNITY_CLUSTER_VERTICAL_CM
                        if horizontal and horizontal <= FISHING_COMMUNITY_CLUSTER_SCAN_CM and verticalOk then
                            local exactKey = tostring(math.floor((ex or 0) + 0.5)) .. ":" .. tostring(math.floor((ez or 0) + 0.5))
                            if not seen[exactKey] then
                                seen[exactKey] = true
                                if self:MarkPositionDepleted(zoneId, ex, ez, "fishing cluster", "FISHING", DEPLETED_MATCH_CM, true) then
                                    marked = marked + 1
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- Always cover the actual interaction point too, including learned-only holes.
    if self:MarkPositionDepleted(zoneId, x, z, "fishing catch", "FISHING", FISHING_DEPLETED_CLUSTER_CM, true) then
        marked = marked + 1
    end
    self.lastFishingClusterMarked = marked
    return marked
end

function R:ClearDepletedLocations()
    if EPC.saved then EPC.saved.resourcePinsDepleted = {} end
    self.depletionProbeKey = nil
    self.depletionProbeSince = 0
    self.depletionProbePlayerX = nil
    self.depletionProbePlayerZ = nil
    self.lastDepletedReason = nil
    self.lastDepletedKind = nil
    self.lastDepletionProbeDistanceM = nil
    self.lastDepletionProbeState = "idle"
    self:RefreshMarkers()
end

function R:IsSupportedResourceInteraction(interactionType, targetName)
    if INTERACTION_HARVEST ~= nil and interactionType == INTERACTION_HARVEST then return true end
    if INTERACTION_FISH ~= nil and interactionType == INTERACTION_FISH then return true end
    local specialKind = SPECIAL_NAME_KIND[lower(targetName)]
    if specialKind ~= nil then return true end
    return self:ClassifyByName(targetName) == "CHEST"
end

function R:IsFacingWorldPosition(x, z, minDot)
    local _, px, _, pz = self:GetPlayerRawPosition()
    px, pz, x, z = tonumber(px), tonumber(pz), tonumber(x), tonumber(z)
    if not px or not pz or not x or not z then return false end
    local dx, dz = x - px, z - pz
    local len = math.sqrt((dx * dx) + (dz * dz))
    if len < 1 then return true end
    dx, dz = dx / len, dz / len
    local heading = tonumber(safe(GetPlayerCameraHeading, 0)) or 0
    local fx, fz = math.sin(heading), math.cos(heading)
    return ((fx * dx) + (fz * dz)) >= (tonumber(minDot) or LIVE_COMMUNITY_FACING_DOT)
end

function R:UpdateNearbyDepletedProbe(interactionType, targetName)
    if not EPC.saved or EPC.saved.resourcePinsHideDepleted == false then
        self.liveCommunityNode = nil
        self.liveCommunityVanishedAt = 0
        self.depletionProbeKey = nil
        self.depletionProbeSince = 0
        self.lastDepletionProbeState = "disabled"
        return
    end

    local now = nowMs()
    targetName = tostring(targetName or "")
    local candidate = self.nearestDepletionCandidate
    local probeDistanceM = type(candidate) == "table" and (tonumber(candidate.horizontalDistanceM) or tonumber(candidate.distanceM)) or nil
    self.lastDepletionProbeDistanceM = probeDistanceM

    -- After the player successfully collects a node, ESO briefly drops the
    -- interaction prompt. Do not let the proximity fallback interpret a
    -- neighboring, still-live resource as missing during that transition.
    local lastOwnCollectionAt = tonumber(self.lastOwnCollectionAt) or 0
    if lastOwnCollectionAt > 0 and (now - lastOwnCollectionAt) < POST_HARVEST_PROBE_GUARD_MS then
        self.depletionProbeKey = nil
        self.depletionProbeSince = 0
        self.depletionProbePlayerX = nil
        self.depletionProbePlayerZ = nil
        self.liveCommunityNode = nil
        self.liveCommunityVanishedAt = 0
        self.lastDepletionProbeState = "post-harvest protection"
        return
    end

    -- Any real resource interaction cancels the proximity fallback immediately.
    if self:IsSupportedResourceInteraction(interactionType, targetName) then
        self.depletionProbeKey = nil
        self.depletionProbeSince = 0
        self.depletionProbePlayerX = nil
        self.depletionProbePlayerZ = nil

        -- Keep the positive-evidence path too: if a community node was visibly
        -- harvestable and then vanishes, another player's collection can still
        -- deplete it without relying on the proximity fallback.
        if type(candidate) == "table" and candidate.debug ~= true and probeDistanceM and probeDistanceM <= 5.0 then
            local entry = candidate.entry
            local zoneId = select(1, self:GetPlayerRawPosition())
            if type(entry) == "table" and zoneId then
                self.liveCommunityNode = {
                    zoneId = zoneId,
                    x = tonumber(entry.x), z = tonumber(entry.z),
                    kind = tostring(entry.kind or "RESOURCE"),
                    name = targetName,
                    seenAt = now,
                }
                self.liveCommunityVanishedAt = 0
                self.lastDepletionProbeState = "community node confirmed live"
            end
        else
            self.lastDepletionProbeState = "live resource detected"
        end
        return
    end

    if self.pendingResource and self.pendingResource.ownInteraction == true then
        self.depletionProbeKey = nil
        self.depletionProbeSince = 0
        self.lastDepletionProbeState = "your harvest pending"
        return
    end

    -- First preserve the safer positive-evidence path for a node that was
    -- actually seen alive and then disappeared while still nearby/facing it.
    local live = self.liveCommunityNode
    if type(live) == "table" then
        if (now - (tonumber(live.seenAt) or 0)) > LIVE_COMMUNITY_MEMORY_MS then
            self.liveCommunityNode = nil
            self.liveCommunityVanishedAt = 0
        else
            local zoneId, px, _, pz = self:GetPlayerRawPosition()
            if zoneId and tonumber(zoneId) == tonumber(live.zoneId) then
                local liveDistanceM = distance2Dcm(px, pz, live.x, live.z) / 100
                if liveDistanceM <= 5.0 and self:IsFacingWorldPosition(live.x, live.z) and targetName == "" then
                    if (tonumber(self.liveCommunityVanishedAt) or 0) <= 0 then
                        self.liveCommunityVanishedAt = now
                    elseif (now - (tonumber(self.liveCommunityVanishedAt) or now)) >= LIVE_COMMUNITY_VANISH_MS then
                        if self:MarkPositionDepleted(live.zoneId, live.x, live.z, "other player harvested", live.kind, DEPLETED_MATCH_CM, true) then
                            self.lastDepletionProbeState = "other-player harvest confirmed"
                            self.liveCommunityNode = nil
                            self.liveCommunityVanishedAt = 0
                            self:RefreshMarkers()
                            return
                        end
                    end
                else
                    self.liveCommunityVanishedAt = 0
                end
            end
        end
    end

    -- User-requested fallback: when the player walks right up to the nearest
    -- resource icon and ESO still exposes no interaction, treat the spot as
    -- probably already depleted after a short confirmation hold. This applies
    -- to both bundled community pins and learned pins; learned pins can shadow
    -- the bundled record after a previous gather and must not remain forever.
    if type(candidate) ~= "table" or candidate.debug == true
        or not probeDistanceM or probeDistanceM > DEPLETED_PROBE_DISTANCE_M then
        self.depletionProbeKey = nil
        self.depletionProbeSince = 0
        self.depletionProbePlayerX = nil
        self.depletionProbePlayerZ = nil
        self.lastDepletionProbeState = "proximity idle"
        return
    end

    -- A harmless world/interactable name can remain under the reticle even when
    -- the resource itself is absent. Do not let that block an exact-pin check
    -- when the player is already very close. Farther than 2.25m, keep the guard
    -- to avoid timing out a resource while intentionally looking at something else.
    if targetName ~= "" and probeDistanceM > 2.25 then
        self.depletionProbeKey = nil
        self.depletionProbeSince = 0
        self.depletionProbePlayerX = nil
        self.depletionProbePlayerZ = nil
        self.lastDepletionProbeState = "other target under reticle"
        return
    end

    local entry = candidate.entry
    local zoneId, px, _, pz = self:GetPlayerRawPosition()
    if type(entry) ~= "table" or not zoneId or not px or not pz then return end

    if probeDistanceM > 1.75 and not self:IsFacingWorldPosition(entry.x, entry.z, MISSING_PIN_FACING_DOT) then
        self.depletionProbeKey = nil
        self.depletionProbeSince = 0
        self.depletionProbePlayerX = nil
        self.depletionProbePlayerZ = nil
        self.lastDepletionProbeState = "near pin; not approaching it"
        return
    end

    local key = tostring(zoneId) .. ":" .. self:GetDepletedCellKey(entry.x, entry.z)
    if self.depletionProbeKey ~= key then
        self.depletionProbeKey = key
        self.depletionProbeSince = now
        self.depletionProbePlayerX = px
        self.depletionProbePlayerZ = pz
        self.lastDepletionProbeState = "checking nearby resource pin"
        return
    end

    -- Keep the timer running while the player approaches the same pin. The
    -- candidate key, facing check, interaction check, and 4m range are the
    -- safeguards; forcing a stationary hold made players stand inside the icon.
    self.depletionProbePlayerX = px
    self.depletionProbePlayerZ = pz

    local heldMs = now - (tonumber(self.depletionProbeSince) or now)
    self.lastDepletionProbeState = string.format("checking nearby resource pin %.1fs", math.max(0, heldMs) / 1000)
    if heldMs >= DEPLETED_PROBE_HOLD_MS then
        if self:MarkPositionDepleted(zoneId, entry.x, entry.z, "no interaction nearby", entry.kind, MISSING_PIN_MATCH_CM, true, true) then
            self.depletionAutoLockUntil = now + DEPLETED_AUTO_LOCK_MS
            self.lastDepletionProbeState = "nearby resource pin depleted"
            self.depletionProbeKey = nil
            self.depletionProbeSince = 0
            self:RefreshMarkers()
        end
    end
end

function R:GetPlayerRawPosition()
    if type(GetUnitRawWorldPosition) ~= "function" then return nil end
    local zoneId, x, y, z = safe(GetUnitRawWorldPosition, nil, "player")
    zoneId, x, y, z = tonumber(zoneId), tonumber(x), tonumber(y), tonumber(z)
    if not zoneId or not x or not y or not z then return nil end
    if x == 0 and y == 0 and z == 0 then return nil end
    return zoneId, x, y, z
end

function R:GetApproximateInteractablePosition()
    local zoneId, x, y, z = self:GetPlayerRawPosition()
    if not zoneId then return nil end
    local heading = tonumber(safe(GetPlayerCameraHeading, nil))
    if heading then
        x = x + (math.sin(heading) * INTERACT_FORWARD_OFFSET_CM)
        z = z + (math.cos(heading) * INTERACT_FORWARD_OFFSET_CM)
    end
    return zoneId, x, y, z
end

function R:IsWorldGlowSuppressed()
    if EPC.saved and EPC.saved.hudHideInMenus == false then return false end

    -- The 3D marker root is attached to the HUD/HUD UI/Loot scenes through a
    -- ZO_SimpleSceneFragment. Let that fragment decide whether world markers
    -- are currently allowed to render. SCENE_MANAGER:IsShowing(name) can remain
    -- true for parent/menu scenes after returning to gameplay, which previously
    -- left every resource pin permanently stuck in the queued/menu state.
    if self.worldFragment and type(self.worldFragment.IsHidden) == "function" then
        local ok, hidden = pcall(self.worldFragment.IsHidden, self.worldFragment)
        if ok then return hidden == true end
    end

    -- If fragment state is unavailable, fail open rather than hiding all pins.
    -- The fragment itself still controls the visibility of the 3D root.
    return false
end

function R:GetZoneBucket(zoneId, create)
    if not EPC.saved then return nil end
    EPC.saved.resourcePinLocations = EPC.saved.resourcePinLocations or {}
    local key = tostring(tonumber(zoneId) or zoneId or "")
    if key == "" then return nil end
    local bucket = EPC.saved.resourcePinLocations[key]
    if create and type(bucket) ~= "table" then
        bucket = {}
        EPC.saved.resourcePinLocations[key] = bucket
    end
    return bucket, key
end

function R:EntryKey(zoneId, index)
    return tostring(zoneId or "") .. ":" .. tostring(index or 0)
end


function R:AddCommunityNode(cache, dedupe, kind, x, y, z)
    if type(cache) ~= "table" or type(dedupe) ~= "table" then return false end
    if not kind then return false end

    -- Mirror the Suite's learned-node merge radius so aliased community records
    -- (for example ore/jewelry and rune/portal records) do not create double pins.
    local _, gx, gz = gridKey(x, z, COMMUNITY_DEDUPE_CM)
    for dx = -1, 1 do
        for dz = -1, 1 do
            local key = tostring(kind) .. ":" .. tostring(gx + dx) .. ":" .. tostring(gz + dz)
            local nearby = dedupe[key]
            if type(nearby) == "table" then
                for i = 1, #nearby do
                    local other = nearby[i]
                    if type(other) == "table"
                        and math.abs((tonumber(other.y) or 0) - (tonumber(y) or 0)) <= 600
                        and distance2Dcm(other.x, other.z, x, z) <= COMMUNITY_DEDUPE_CM then
                        return false
                    end
                end
            end
        end
    end

    local entry = {
        kind = tostring(kind),
        name = TYPE_LABELS[kind] or "Community Resource",
        x = tonumber(x), y = tonumber(y), z = tonumber(z),
        source = "community",
    }
    if not entry.x or not entry.y or not entry.z then return false end

    local cell = gridKey(entry.x, entry.z, COMMUNITY_GRID_CM)
    cache.cells[cell] = cache.cells[cell] or {}
    cache.cells[cell][#cache.cells[cell] + 1] = entry
    cache.count = (tonumber(cache.count) or 0) + 1
    cache.byKind[kind] = (tonumber(cache.byKind[kind]) or 0) + 1

    local ownKey = tostring(kind) .. ":" .. tostring(gx) .. ":" .. tostring(gz)
    dedupe[ownKey] = dedupe[ownKey] or {}
    dedupe[ownKey][#dedupe[ownKey] + 1] = entry
    return true
end

function R:DecodeCommunityPacked(cache, dedupe, kind, packed)
    if type(packed) ~= "string" or packed == "" then return 0 end
    if (#packed % 8) ~= 0 then
        cache.corruptRecords = (tonumber(cache.corruptRecords) or 0) + 1
        return 0
    end

    local added = 0
    cache.rawCount = (tonumber(cache.rawCount) or 0) + (#packed / 8)
    for offset = 1, #packed, 8 do
        local x1, x2, h1, h2, v1, v2 = string.byte(packed, offset, offset + 5)
        if x1 and x2 and h1 and h2 and v1 and v2 then
            -- Database X/Y are horizontal meters; database Z is vertical meters.
            -- Each unsigned 16-bit value is stored in 0.2m units. Convert directly
            -- to raw-world centimeters (0.2m == 20cm) and remap to ESO X/Y/Z.
            local x = ((x1 * 256) + x2) * 20
            local z = ((h1 * 256) + h2) * 20
            local y = ((v1 * 256) + v2) * 20
            if self:AddCommunityNode(cache, dedupe, kind, x, y, z) then added = added + 1 end
        end
    end
    return added
end

function R:BuildCommunityZoneCache(zoneId)
    if not EPC.saved or EPC.saved.resourcePinsCommunityEnabled == false then return nil end
    zoneId = tonumber(zoneId)
    if not zoneId then return nil end
    if self.communityZoneId == zoneId and type(self.communityZoneCache) == "table" then
        return self.communityZoneCache
    end

    local root = EPC.CommunityResourceData
    if type(root) ~= "table" then
        self.lastCommunityError = "Suite Community Resource Data is not loaded"
        return nil
    end

    -- Keep only one decoded zone at a time. The packed 124k-node dataset stays
    -- compact in memory while the current zone gets a fast 50m spatial index.
    local cache = { zoneId = zoneId, cells = {}, count = 0, rawCount = 0, byKind = {}, corruptRecords = 0 }
    local dedupe = {}
    for m = 1, #COMMUNITY_MODULES do
        local module = root[COMMUNITY_MODULES[m]]
        local zoneData = type(module) == "table" and module[zoneId] or nil
        if type(zoneData) == "table" then
            for _, mapData in pairs(zoneData) do
                if type(mapData) == "table" then
                    for pinTypeId, packed in pairs(mapData) do
                        local kind = COMMUNITY_KIND_BY_PIN[tonumber(pinTypeId)]
                        if kind and type(packed) == "string" then
                            self:DecodeCommunityPacked(cache, dedupe, kind, packed)
                        end
                    end
                end
            end
        end
    end

    self.communityZoneId = zoneId
    self.communityZoneCache = cache
    self.lastCommunityZoneCount = cache.count
    self.lastCommunityRawZoneCount = cache.rawCount
    self.lastCommunityError = nil
    return cache
end

function R:BuildLearnedShadowGrid(bucket)
    local shadow = {}
    if type(bucket) ~= "table" then return shadow end
    for i = 1, #bucket do
        local entry = bucket[i]
        if type(entry) == "table" and tonumber(entry.x) and tonumber(entry.z) then
            local key = gridKey(entry.x, entry.z, DEDUPE_DISTANCE_CM)
            shadow[key] = shadow[key] or {}
            shadow[key][#shadow[key] + 1] = entry
        end
    end
    return shadow
end

function R:IsCommunityShadowed(entry, shadow)
    if type(entry) ~= "table" or type(shadow) ~= "table" then return false end
    local _, gx, gz = gridKey(entry.x, entry.z, DEDUPE_DISTANCE_CM)
    for dx = -1, 1 do
        for dz = -1, 1 do
            local key = tostring(gx + dx) .. ":" .. tostring(gz + dz)
            local nearby = shadow[key]
            if type(nearby) == "table" then
                for i = 1, #nearby do
                    local learned = nearby[i]
                    if math.abs((tonumber(learned.y) or 0) - (tonumber(entry.y) or 0)) <= 600
                        and distance2Dcm(learned.x, learned.z, entry.x, entry.z) <= DEDUPE_DISTANCE_CM then
                        return true
                    end
                end
            end
        end
    end
    return false
end

function R:AppendAllCommunity(zoneId, px, py, pz, visible, learnedShadow)
    if not EPC.saved or EPC.saved.resourcePinsCommunityEnabled == false then
        self.lastCommunityZoneCount = 0
        return 0
    end
    local cache = self:BuildCommunityZoneCache(zoneId)
    if type(cache) ~= "table" then return 0 end

    local added = 0
    for _, list in pairs(cache.cells or {}) do
        if type(list) == "table" then
            for i = 1, #list do
                local entry = list[i]
                if type(entry) == "table" and self:IsKindEnabled(entry.kind)
                    and not self:IsPositionDepleted(zoneId, entry.x, entry.z, entry.kind)
                    and not self:IsCommunityShadowed(entry, learnedShadow) then
                    local distanceM = distance3Dcm(px, py, pz, entry.x, entry.y, entry.z) / 100
                    visible[#visible + 1] = { entry = entry, distanceM = distanceM, community = true }
                    added = added + 1
                end
            end
        end
    end
    return added
end

function R:AppendNearbyCommunity(zoneId, px, py, pz, maxDistanceM, visible, learnedShadow)
    if not EPC.saved or EPC.saved.resourcePinsCommunityEnabled == false then
        self.lastCommunityZoneCount = 0
        return 0
    end
    local cache = self:BuildCommunityZoneCache(zoneId)
    if type(cache) ~= "table" then return 0 end

    local maxDistanceCm = (tonumber(maxDistanceM) or 125) * 100
    local _, centerX, centerZ = gridKey(px, pz, COMMUNITY_GRID_CM)
    local radius = math.max(1, math.ceil(maxDistanceCm / COMMUNITY_GRID_CM))
    local added = 0
    for gx = centerX - radius, centerX + radius do
        for gz = centerZ - radius, centerZ + radius do
            local list = cache.cells[tostring(gx) .. ":" .. tostring(gz)]
            if type(list) == "table" then
                for i = 1, #list do
                    local entry = list[i]
                    if type(entry) == "table" and self:IsKindEnabled(entry.kind)
                        and not self:IsPositionDepleted(zoneId, entry.x, entry.z, entry.kind)
                        and not self:IsCommunityShadowed(entry, learnedShadow) then
                        local distanceM = distance3Dcm(px, py, pz, entry.x, entry.y, entry.z) / 100
                        local horizontalDistanceM = distance2Dcm(px, pz, entry.x, entry.z) / 100
                        if distanceM <= maxDistanceM then
                            visible[#visible + 1] = { entry = entry, distanceM = distanceM, horizontalDistanceM = horizontalDistanceM, community = true }
                            added = added + 1
                        end
                    end
                end
            end
        end
    end
    return added
end

function R:ClassifyByName(name)
    local value = lower(name)
    if value == "" then return nil end
    if SPECIAL_NAME_KIND[value] then return SPECIAL_NAME_KIND[value] end
    local checks = {
        { "mushroom", "MUSHROOM" }, { "fungus", "MUSHROOM" },
        { "flower", "FLOWER" }, { "herb", "FLOWER" },
        { "water hyacinth", "WATERPLANT" }, { "nirnroot", "WATERPLANT" },
        { "runestone", "RUNE" }, { "rune stone", "RUNE" }, { "runenstein", "RUNE" },
        { "ore", "ORE" }, { "seam", "ORE" }, { "erz", "ORE" },
        { "wood", "WOOD" }, { "log", "WOOD" }, { "holz", "WOOD" },
        { "cloth", "CLOTH" }, { "silk", "CLOTH" }, { "fiber", "CLOTH" }, { "faser", "CLOTH" },
        { "water", "WATER" }, { "wasser", "WATER" },
        { "fishing", "FISHING" }, { "fish", "FISHING" },
        { "chest", "CHEST" }, { "safebox", "CHEST" }, { "safe box", "CHEST" },
    }
    for i = 1, #checks do
        if string.find(value, checks[i][1], 1, true) then return checks[i][2] end
    end
    return nil
end

function R:GetItemId(itemLink, fallbackItemId)
    local id = tonumber(fallbackItemId)
    if id and id > 0 then return id end
    if type(itemLink) == "string" and itemLink ~= "" and type(GetItemLinkItemId) == "function" then
        id = tonumber(safe(GetItemLinkItemId, 0, itemLink))
        if id and id > 0 then return id end
    end
    return nil
end

function R:ClassifyLoot(itemLink, pendingName, fallbackItemId, pendingKind)
    if pendingKind and pendingKind ~= "RESOURCE" then return pendingKind end
    local itemId = self:GetItemId(itemLink, fallbackItemId)
    if itemId and ITEM_ID_KIND[itemId] then return ITEM_ID_KIND[itemId] end
    if type(itemLink) == "string" and itemLink ~= "" and type(GetItemLinkItemType) == "function" then
        local itemType = safe(GetItemLinkItemType, nil, itemLink)
        if itemType ~= nil and ITEM_KIND[itemType] then return ITEM_KIND[itemType] end
    end
    return self:ClassifyByName(pendingName) or "RESOURCE"
end

function R:IsKindEnabled(kind)
    if not EPC.saved then return false end

    -- Farm Focus deliberately uses its own target set. This lets the player
    -- switch back to the normal all-purpose filters without rebuilding them.
    if EPC.saved.resourcePinsFarmFocusEnabled == true then
        local farmKey = {
            ORE = "resourcePinsFarmOre", WOOD = "resourcePinsFarmWood", CLOTH = "resourcePinsFarmCloth",
            ALCHEMY = "resourcePinsFarmAlchemy", MUSHROOM = "resourcePinsFarmAlchemy", FLOWER = "resourcePinsFarmAlchemy",
            WATERPLANT = "resourcePinsFarmAlchemy", RUNE = "resourcePinsFarmRunes", WATER = "resourcePinsFarmWater",
            FISHING = "resourcePinsFarmFishing", CHEST = "resourcePinsFarmSpecial", HEAVYSACK = "resourcePinsFarmSpecial",
            CLAM = "resourcePinsFarmSpecial", TROVE = "resourcePinsFarmSpecial", JUSTICE = "resourcePinsFarmSpecial",
            STASH = "resourcePinsFarmSpecial", RESOURCE = "resourcePinsFarmOther",
        }
        local focusKey = farmKey[kind] or "resourcePinsFarmOther"
        return EPC.saved[focusKey] == true
    end

    local key = {
        ORE = "resourcePinsShowOre", WOOD = "resourcePinsShowWood", CLOTH = "resourcePinsShowCloth",
        ALCHEMY = "resourcePinsShowAlchemy", MUSHROOM = "resourcePinsShowAlchemy", FLOWER = "resourcePinsShowAlchemy",
        WATERPLANT = "resourcePinsShowAlchemy", RUNE = "resourcePinsShowRunes", WATER = "resourcePinsShowWater",
        FISHING = "resourcePinsShowFishing", CHEST = "resourcePinsShowSpecial", HEAVYSACK = "resourcePinsShowSpecial",
        CLAM = "resourcePinsShowSpecial", TROVE = "resourcePinsShowSpecial", JUSTICE = "resourcePinsShowSpecial",
        STASH = "resourcePinsShowSpecial", RESOURCE = "resourcePinsShowOther",
    }
    local savedKey = key[kind] or "resourcePinsShowOther"
    return EPC.saved[savedKey] ~= false
end

function R:SetAllFarmTargets(enabled)
    if not EPC.saved then return end
    enabled = enabled == true
    EPC.saved.resourcePinsFarmOre = enabled
    EPC.saved.resourcePinsFarmWood = enabled
    EPC.saved.resourcePinsFarmCloth = enabled
    EPC.saved.resourcePinsFarmAlchemy = enabled
    EPC.saved.resourcePinsFarmRunes = enabled
    EPC.saved.resourcePinsFarmWater = enabled
    EPC.saved.resourcePinsFarmFishing = enabled
    EPC.saved.resourcePinsFarmSpecial = enabled
    EPC.saved.resourcePinsFarmOther = enabled
    self:RefreshSettings()
end

function R:GetFarmTargetSummary()
    if not EPC.saved or EPC.saved.resourcePinsFarmFocusEnabled ~= true then return "OFF" end
    local selected = {}
    local values = {
        {"resourcePinsFarmOre","Ore"}, {"resourcePinsFarmWood","Wood"}, {"resourcePinsFarmCloth","Cloth"},
        {"resourcePinsFarmAlchemy","Alchemy"}, {"resourcePinsFarmRunes","Runes"}, {"resourcePinsFarmWater","Water"},
        {"resourcePinsFarmFishing","Fishing"}, {"resourcePinsFarmSpecial","Special"}, {"resourcePinsFarmOther","Other"},
    }
    for _,v in ipairs(values) do if EPC.saved[v[1]] == true then selected[#selected+1] = v[2] end end
    return #selected > 0 and table.concat(selected, ", ") or "NONE SELECTED"
end
function R:FindNearbyEntry(zoneId, x, z, maxDistanceCm)
    local bucket = self:GetZoneBucket(zoneId, false)
    if type(bucket) ~= "table" then return nil end
    local bestIndex, bestDistance
    for i = 1, #bucket do
        local entry = bucket[i]
        if type(entry) == "table" then
            local d = distance2Dcm(x, z, entry.x, entry.z)
            if d <= (maxDistanceCm or DEDUPE_DISTANCE_CM) and (not bestDistance or d < bestDistance) then
                bestIndex, bestDistance = i, d
            end
        end
    end
    return bestIndex, bestDistance
end

function R:SaveNode(kind, name, zoneId, x, y, z, source)
    if not EPC.saved or EPC.saved.resourcePinsLearn == false then return nil end
    zoneId, x, y, z = tonumber(zoneId), tonumber(x), tonumber(y), tonumber(z)
    if not zoneId or not x or not y or not z then return nil end
    kind = tostring(kind or "RESOURCE")
    local bucket = self:GetZoneBucket(zoneId, true)
    if not bucket then return nil end

    local nearby = self:FindNearbyEntry(zoneId, x, z, DEDUPE_DISTANCE_CM)
    if nearby then
        local entry = bucket[nearby]
        if entry then
            if entry.kind == "RESOURCE" and kind ~= "RESOURCE" then entry.kind = kind end
            if (not entry.name or entry.name == "") and name and name ~= "" then entry.name = tostring(name) end
            entry.lastSeenAt = nowStamp()
            entry.source = entry.source or tostring(source or "player")
        end
        return nearby
    end

    bucket[#bucket + 1] = {
        kind = kind,
        name = tostring(name or TYPE_LABELS[kind] or "Resource"),
        x = x, y = y, z = z,
        learnedAt = nowStamp(),
        lastSeenAt = nowStamp(),
        source = tostring(source or "player"),
    }
    return #bucket
end

function R:GetInteractableName()
    if type(GetGameCameraInteractableActionInfo) ~= "function" then return "" end
    local _, name = safe(GetGameCameraInteractableActionInfo, nil)
    return tostring(name or "")
end

function R:GetPendingResourceWindowMs(pending)
    local kind = type(pending) == "table" and tostring(pending.kind or "RESOURCE") or "RESOURCE"
    if kind == "FISHING" then return FISHING_RESOURCE_WINDOW_MS end
    if kind == "CHEST" then return CHEST_RESOURCE_WINDOW_MS end
    return RESOURCE_WINDOW_MS
end

function R:CapturePendingSpecialTarget(targetName, kind, now, ownInteraction)
    if not kind then return false end
    local zoneId, x, y, z = self:GetApproximateInteractablePosition()
    if not zoneId then return false end
    self.pendingResource = {
        name = tostring(targetName or ""),
        kind = tostring(kind),
        zoneId = zoneId, x = x, y = y, z = z,
        capturedAt = tonumber(now) or nowMs(),
        ownInteraction = ownInteraction == true,
        ownInteractionAt = ownInteraction == true and (tonumber(now) or nowMs()) or nil,
    }
    self.lastResourceInteractionAt = tonumber(now) or nowMs()
    return true
end

function R:CaptureResourceInteraction()
    if not EPC.saved or EPC.saved.enabled == false or EPC.saved.resourcePinsEnabled == false then return end
    if type(GetInteractionType) ~= "function" then return end

    local interactionType = safe(GetInteractionType, nil)
    local now = nowMs()
    local targetName = self:GetInteractableName()
    local targetKind = self:ClassifyByName(targetName)
    if targetName ~= "" then self.lastInteractableName = targetName end

    if INTERACTION_HARVEST ~= nil and interactionType == INTERACTION_HARVEST then
        if not self.pendingResource or (now - (tonumber(self.pendingResource.capturedAt) or 0)) > 800
            or (targetName ~= "" and targetName ~= tostring(self.pendingResource.name or "")) then
            local zoneId, x, y, z = self:GetApproximateInteractablePosition()
            if zoneId then
                self.pendingResource = { name = targetName, kind = targetKind, zoneId = zoneId, x = x, y = y, z = z, capturedAt = now }
            end
        end
        self.lastResourceInteractionAt = now
        self.lastInteractableName = targetName ~= "" and targetName or self.lastInteractableName

    elseif INTERACTION_FISH ~= nil and interactionType == INTERACTION_FISH then
        -- Fishing can take far longer than a normal harvest animation. Keep the
        -- fishing-hole position alive until the eventual catch/loot event.
        local pending = self.pendingResource
        local stale = not pending or tostring(pending.kind or "") ~= "FISHING"
            or (now - (tonumber(pending.capturedAt) or 0)) > FISHING_RESOURCE_WINDOW_MS
            or (targetName ~= "" and tostring(pending.name or "") ~= "" and targetName ~= tostring(pending.name or ""))
        if stale then
            if self:CapturePendingSpecialTarget(targetName ~= "" and targetName or "Fishing Hole", "FISHING", now, false) then
                if EPC.saved.resourcePinsLearn ~= false then
                    local pnd = self.pendingResource
                    local index = self:SaveNode("FISHING", pnd.name ~= "" and pnd.name or "Fishing Hole", pnd.zoneId, pnd.x, pnd.y, pnd.z, "player")
                    if index then self.lastLearnedKind, self.lastLearnedName = "FISHING", pnd.name end
                end
            end
        else
            self.lastResourceInteractionAt = now
        end
        self.lastFishingSeenAt = now

    else
        -- Chests and several special containers can report INTERACTION_TYPE_NONE,
        -- so target-name detection must run even when interactionType is zero.
        local specialKind = SPECIAL_NAME_KIND[lower(targetName)] or targetKind
        if specialKind == "CHEST" or SPECIAL_NAME_KIND[lower(targetName)] ~= nil then
            local pending = self.pendingResource
            local stale = not pending or tostring(pending.kind or "") ~= tostring(specialKind)
                or (now - (tonumber(pending.capturedAt) or 0)) > 1200
                or (targetName ~= "" and targetName ~= tostring(pending.name or ""))
            if stale then
                self:CapturePendingSpecialTarget(targetName, specialKind, now, false)
            else
                self.lastResourceInteractionAt = now
            end
        end
    end

    self:UpdateNearbyDepletedProbe(interactionType, targetName)
end

function R:HandleInteractResult(result, targetName)
    if not EPC.saved or EPC.saved.resourcePinsEnabled == false then return end
    local now = nowMs()
    targetName = tostring(targetName or "")
    local targetKind = self:ClassifyByName(targetName)

    if not self.pendingResource and targetKind == "CHEST" then
        self:CapturePendingSpecialTarget(targetName, "CHEST", now, true)
    end

    if self.pendingResource then
        if targetName ~= "" then self.pendingResource.name = targetName end
        self.pendingResource.ownInteraction = true
        self.pendingResource.ownInteractionAt = now
        -- Refresh the timestamp when the player actually interacts. This is
        -- especially important before a long lockpick minigame or fishing wait.
        self.pendingResource.capturedAt = now
    end
    self.lastResourceInteractionAt = math.max(tonumber(self.lastResourceInteractionAt) or 0, now - 250)
end

function R:HandleLockpickSuccess()
    if not EPC.saved or EPC.saved.resourcePinsEnabled == false then return end
    local now = nowMs()
    local pending = self.pendingResource
    if pending and tostring(pending.kind or "") == "CHEST" then
        pending.ownInteraction = true
        pending.lockpickSucceeded = true
        pending.ownInteractionAt = now
        pending.capturedAt = now
        self.lastResourceInteractionAt = now
        return
    end

    -- Be conservative: lockpick success can also belong to doors. Only create a
    -- chest pending state when the last positively observed interactable was a chest.
    if self:ClassifyByName(self.lastInteractableName) == "CHEST" then
        if self:CapturePendingSpecialTarget(self.lastInteractableName, "CHEST", now, true) then
            self.pendingResource.lockpickSucceeded = true
        end
    end
end

function R:HandleLootReceived(receivedBy, itemLink, quantity, itemSound, lootType, lootedBySelf, isPickpocketLoot, questItemIcon, itemId, isStolen)
    if not EPC.saved or EPC.saved.resourcePinsEnabled == false then return end
    if lootedBySelf ~= true then return end

    local now = nowMs()
    local pending = self.pendingResource
    local resourceWindowMs = self:GetPendingResourceWindowMs(pending)
    if not pending or (now - (tonumber(pending.capturedAt) or 0)) > resourceWindowMs then return end
    if (now - (tonumber(self.lastResourceInteractionAt) or 0)) > resourceWindowMs then return end

    local kind = self:ClassifyLoot(itemLink, pending.name, itemId, pending.kind)
    local index = nil
    if EPC.saved.resourcePinsLearn ~= false then
        index = self:SaveNode(kind, pending.name, pending.zoneId, pending.x, pending.y, pending.z, "player")
    end
    self.lastLearnedKind = kind
    self.lastLearnedName = tostring(pending.name or TYPE_LABELS[kind] or "Resource")
    self.lastLearnedAt = now
    local depletedReason = "harvested"
    local depletedKind = kind
    local depletedRadiusCm = nil
    local sameKindOnly = false
    if tostring(pending.kind or "") == "FISHING" then
        self:MarkFishingCommunityClusterDepleted(pending.zoneId, pending.x, pending.y, pending.z)
    else
        if tostring(pending.kind or "") == "CHEST" then
            depletedReason = "chest looted"
            depletedKind = "CHEST"
        end
        -- A depletion record must never hide a different resource type that
        -- happens to be beside the harvested node. The generous position radius
        -- is retained only to absorb community-coordinate drift for the SAME type.
        sameKindOnly = true
        self:MarkPositionDepleted(pending.zoneId, pending.x, pending.z, depletedReason, depletedKind, depletedRadiusCm, sameKindOnly)
    end
    self.lastOwnCollectionAt = now
    self.pendingResource = nil
    self.liveCommunityNode = nil
    self.liveCommunityVanishedAt = 0
    self:RefreshMarkers()
end

function R:EnsureWindow()
    if self.window then return end

    -- Resource Pins deliberately use the exact same world-pin control pattern
    -- as the Suite's working LoreBooks 3D pins: a top-level render-space root
    -- plus one pooled Texture control per marker. No child beam/icon render
    -- spaces are used here.
    local win = EAS_ResourceWorldPins
    if not win then
        win = wm:CreateTopLevelWindow("EAS_ResourceWorldPinsFallback")
    end
    self.window = win
    win:SetHidden(false)
    if type(win.SetMouseEnabled) == "function" then win:SetMouseEnabled(false) end
    if type(win.Create3DRenderSpace) == "function" then
        local hasSpace = type(win.Has3DRenderSpace) == "function" and win:Has3DRenderSpace()
        if not hasSpace then win:Create3DRenderSpace() end
    end

    if ZO_ControlPool then
        self.worldControlPool = ZO_ControlPool:New("EAS_ResourceWorldPin", win, "EAS_ResourceWorldPin")
    end

    if ZO_SimpleSceneFragment and type(ZO_SimpleSceneFragment.New) == "function" then
        local ok, fragment = pcall(ZO_SimpleSceneFragment.New, ZO_SimpleSceneFragment, win)
        if ok and fragment then
            self.worldFragment = fragment
            local scenes = { HUD_UI_SCENE, HUD_SCENE, LOOT_SCENE }
            for i = 1, #scenes do
                local scene = scenes[i]
                if scene and type(scene.AddFragment) == "function" then
                    pcall(scene.AddFragment, scene, fragment)
                end
            end
        end
    end

    self.worldRenderOriginReady = false
    self:UpdateWorldRenderOrigin()
end


function R:UpdateWorldRenderOrigin()
    if not self.window or type(WorldPositionToGuiRender3DPosition) ~= "function" then
        self.worldRenderOriginReady = false
        return false
    end

    -- The working resource-world renderer anchors the root at the GUI-space
    -- representation of raw world origin, then places each marker using normal
    -- world meters relative to that root. Do not convert each child a second
    -- time; doing so was the main difference between the working source
    -- renderer and the earlier Suite port.
    local gx, gz, gy = safe(WorldPositionToGuiRender3DPosition, nil, 0, 0, 0)
    gx, gz, gy = tonumber(gx), tonumber(gz), tonumber(gy)
    if not gx or not gz or not gy or type(self.window.Set3DRenderSpaceOrigin) ~= "function" then
        self.worldRenderOriginReady = false
        return false
    end

    self.renderOriginX, self.renderOriginZ, self.renderOriginY = gx, gz, gy
    self.window:Set3DRenderSpaceOrigin(gx, gz, gy)
    self.worldRenderOriginReady = true
    return true
end


function R:ResetRenderSpace()
    self:EnsureWindow()
    self:HideAll("render space refresh")
    -- Do not destroy/recreate pooled marker render spaces on zone changes.
    -- LoreBooks keeps the controls alive and only refreshes the root origin.
    self.worldRenderOriginReady = false
    self:UpdateWorldRenderOrigin()
end


function R:GetIconKeyForKind(kind)
    local saved = EPC.saved or {}
    local mode = tostring(saved.resourcePinsIconMode or "SUITE_GLOW")
    if mode == "SUITE_GLOW" then return "SUITE_GLOW" end
    -- World Marker mode must still use a distinct symbol per resource type.
    -- Color is secondary; shape identifies the node at a glance.
    if mode == "WORLD" then return AUTO_ICON[kind] or "WORLD" end
    if mode == "CATEGORY" then return AUTO_ICON[kind] or "WORLD" end
    if mode == "CUSTOM" then
        local settingKey = CUSTOM_ICON_SETTING[kind] or "resourcePinsIconOther"
        local selected = tostring(saved[settingKey] or "AUTO")
        if selected == "AUTO" then return AUTO_ICON[kind] or "WORLD" end
        if ICON_TEXTURES[selected] then return selected end
    end
    return "SUITE_GLOW"
end

function R:GetTextureForEntry(entry)
    local kind = type(entry) == "table" and tostring(entry.kind or "RESOURCE") or "RESOURCE"
    local key = self:GetIconKeyForKind(kind)
    return ICON_TEXTURES[key] or GLOW_TEXTURE, key
end

function R:ApplyTexture(tex, entry)
    if not tex then return nil end
    local source, key = self:GetTextureForEntry(entry)
    tex:SetTexture(source)
    tex.easTextureSource = source
    if type(tex.SetTextureCoords) == "function" then
        if key == "SUITE_GLOW" then
            tex:SetTextureCoords(GLOW_U1, GLOW_U2, GLOW_V1, GLOW_V2)
        else
            tex:SetTextureCoords(0, 1, 0, 1)
        end
    end
    return key
end

function R:EnsureMarker(index)
    self:EnsureWindow()
    self.markers = self.markers or {}
    if self.markers[index] then return self.markers[index] end

    -- Keep the proven parent world-position control, then render the native ESO
    -- Glow and the supplied resource artwork in independent child 3D spaces.
    -- This mirrors the original resource-pin control hierarchy while retaining
    -- the raw-axis/world-position path that is visibly working in 0.28.86.
    local pin
    if self.worldControlPool then
        pin = self.worldControlPool:AcquireObject(index)
    end
    if not pin then
        pin = wm:CreateControl(nil, self.window, CT_CONTROL)
        pin.beam = wm:CreateControl(nil, pin, CT_TEXTURE)
        pin.icon = wm:CreateControl(nil, pin, CT_TEXTURE)
    else
        pin.beam = pin:GetNamedChild("Beam")
        pin.icon = pin:GetNamedChild("Icon")
    end

    local beam, icon = pin.beam, pin.icon
    if not beam or not icon then return nil end

    pin:SetHidden(true)
    if type(pin.SetMouseEnabled) == "function" then pin:SetMouseEnabled(false) end

    local controls = { pin, beam, icon }
    for i = 1, #controls do
        local control = controls[i]
        if control and type(control.Create3DRenderSpace) == "function" then
            local hasSpace = type(control.Has3DRenderSpace) == "function" and control:Has3DRenderSpace()
            if not hasSpace then control:Create3DRenderSpace() end
        end
        if control and type(control.SetMouseEnabled) == "function" then control:SetMouseEnabled(false) end
    end

    beam:SetHidden(true)
    icon:SetHidden(true)
    self.markers[index] = pin
    return pin
end

function R:HideAll(reason)
    if self.markers then for _, tex in ipairs(self.markers) do if tex then tex:SetHidden(true) end end end
    self.lastVisibleCount = 0
    self.lastCandidateCount = 0
    self.lastPositionFailures = 0
    if reason then self.lastHiddenReason = tostring(reason) end
end

function R:PositionMarker(pin, entry, distanceM)
    if not pin or type(entry) ~= "table" then return false end
    local x, y, z = tonumber(entry.x), tonumber(entry.y), tonumber(entry.z)
    if not x or not y or not z then return false end
    if not self.worldRenderOriginReady and not self:UpdateWorldRenderOrigin() then return false end
    if type(WorldPositionToGuiRender3DPosition) ~= "function" then return false end

    local beam = pin.beam or (type(pin.GetNamedChild) == "function" and pin:GetNamedChild("Beam"))
    local icon = pin.icon or (type(pin.GetNamedChild) == "function" and pin:GetNamedChild("Icon"))
    if not beam or not icon then return false end

    local guiX, guiZ, guiY = safe(WorldPositionToGuiRender3DPosition, nil, x, y, z)
    guiX, guiZ, guiY = tonumber(guiX), tonumber(guiZ), tonumber(guiY)
    if not guiX or not guiZ or not guiY then return false end
    guiX = guiX - (tonumber(self.renderOriginX) or 0)
    guiZ = guiZ - (tonumber(self.renderOriginZ) or 0)
    guiY = guiY - (tonumber(self.renderOriginY) or 0)

    local saved = EPC.saved or {}
    local scale = math.max(0.45, math.min(2.50, tonumber(saved.resourcePinsScale) or 1.0))
    local sharpIcons = saved.resourcePinsSharpIcons ~= false
    local iconSizeMult = math.max(0.70, math.min(1.80, (tonumber(saved.resourcePinsIconSize) or 100) / 100))
    local tintStrength = clamp01((tonumber(saved.resourcePinsIconTintStrength) or 85) / 100)
    local farScale = distanceM > 35 and math.min(sharpIcons and 1.12 or 1.28, 1 + ((distanceM - 35) / (sharpIcons and 420 or 260))) or 1
    local size = scale * farScale
    local alphaBase = math.max(0.15, math.min(1.0, tonumber(saved.resourcePinsOpacity) or 0.72))
    local useDepth = saved.resourcePinsThroughWalls == false
    local iconKey = self:GetIconKeyForKind(entry.kind)
    local baseColor = COLORS[entry.kind] or COLORS.RESOURCE
    local glowColor, glowAlpha, glowSize, glowTier = self:GetGlowVisualForEntry(entry, alphaBase)

    pin:Set3DRenderSpaceOrigin(guiX, guiZ, guiY)
    pin:Set3DRenderSpaceUsesDepthBuffer(useDepth)
    pin:Set3DRenderSpaceOrientation(0, tonumber(safe(GetPlayerCameraHeading, 0)) or 0, 0)
    beam:Set3DRenderSpaceUsesDepthBuffer(useDepth)
    icon:Set3DRenderSpaceUsesDepthBuffer(useDepth)
    beam:SetHidden(true)
    icon:SetHidden(true)
    if type(beam.SetDrawLevel) == "function" then beam:SetDrawLevel(6) end
    if type(icon.SetDrawLevel) == "function" then icon:SetDrawLevel(5) end

    local requestedMode = tostring(saved.resourcePinsIconMode or "SUITE_GLOW")
    local source = GLOW_TEXTURE
    local usingNative = false
    local usingFallback = false

    if iconKey == "SUITE_GLOW" then
        source = GLOW_TEXTURE
        beam:SetTexture(source)
        if type(beam.SetTextureCoords) == "function" then beam:SetTextureCoords(GLOW_U1, GLOW_U2, GLOW_V1, GLOW_V2) end
        if type(beam.SetBlendMode) == "function" and TEX_BLEND_MODE_ADD ~= nil then beam:SetBlendMode(TEX_BLEND_MODE_ADD) end
        beam:Set3DRenderSpaceOrigin(0, GLOW_VERTICAL_OFFSET_CM / 100, 0)
        beam:Set3DLocalDimensions((BASE_GLOW_WIDTH_M * glowSize) * size, (BASE_GLOW_HEIGHT_M * glowSize) * size)
        beam:SetColor(baseColor[1], baseColor[2], baseColor[3], math.max(alphaBase, glowAlpha))
        beam:SetAlpha(math.max(alphaBase, glowAlpha))
        icon:SetHidden(true)
    else
        if requestedMode == "CATEGORY" then
            source = NATIVE_ICON_TEXTURES[iconKey] or NATIVE_ICON_TEXTURES.WORLD
            usingNative = true
        else
            source = ICON_TEXTURES[iconKey] or ICON_TEXTURES.WORLD
        end

        beam:SetTexture(source)
        if type(beam.SetTextureCoords) == "function" then beam:SetTextureCoords(0, 1, 0, 1) end
        if type(beam.SetBlendMode) == "function" and TEX_BLEND_MODE_ALPHA ~= nil then beam:SetBlendMode(TEX_BLEND_MODE_ALPHA) end

        if not usingNative and type(beam.IsTextureLoaded) == "function" then
            local ok, loaded = pcall(beam.IsTextureLoaded, beam)
            if ok and loaded == false then
                source = NATIVE_ICON_TEXTURES[iconKey] or NATIVE_ICON_TEXTURES.WORLD
                beam:SetTexture(source)
                usingNative = true
                usingFallback = true
            end
        end

        local iconBaseSize = sharpIcons and 1.72 or 1.52
        local normalize = usingNative and (NATIVE_ICON_SCALE[iconKey] or 0.82) or 0.86
        local finalIconSize = iconBaseSize * normalize * iconSizeMult
        local tintR = 1 + ((baseColor[1] or 1) - 1) * tintStrength
        local tintG = 1 + ((baseColor[2] or 1) - 1) * tintStrength
        local tintB = 1 + ((baseColor[3] or 1) - 1) * tintStrength
        beam:Set3DRenderSpaceOrigin(0, 1.05 * size, 0)
        beam:Set3DLocalDimensions(finalIconSize * size, finalIconSize * size)
        beam:SetColor(tintR, tintG, tintB, 1)
        beam:SetAlpha(1)

        icon:SetTexture(GLOW_TEXTURE)
        if type(icon.SetTextureCoords) == "function" then icon:SetTextureCoords(GLOW_U1, GLOW_U2, GLOW_V1, GLOW_V2) end
        if type(icon.SetBlendMode) == "function" and TEX_BLEND_MODE_ADD ~= nil then icon:SetBlendMode(TEX_BLEND_MODE_ADD) end
        icon:Set3DRenderSpaceOrigin(0, 1.03 * size, 0)
        icon:Set3DLocalDimensions((finalIconSize * 1.08 * glowSize) * size, (finalIconSize * 1.08 * glowSize) * size)
        icon:SetColor(glowColor[1], glowColor[2], glowColor[3], glowAlpha)
        icon:SetAlpha(glowAlpha)
        icon:SetHidden(false)
    end

    self.lastIconTexture = source
    self.lastIconUsedNative = usingNative
    self.lastIconFallback = usingFallback
    self.lastIconLoaded = nil
    self.lastIconWidth = nil
    self.lastIconHeight = nil
    self.lastGlowTier = glowTier
    self.lastSharpMode = sharpIcons and true or false
    self.lastIconNormalization = iconKey
    if type(beam.IsTextureLoaded) == "function" then
        local ok, loaded = pcall(beam.IsTextureLoaded, beam)
        if ok then self.lastIconLoaded = loaded and true or false end
    end
    if type(beam.GetTextureFileDimensions) == "function" then
        local ok, w, h = pcall(beam.GetTextureFileDimensions, beam)
        if ok then
            self.lastIconWidth = tonumber(w)
            self.lastIconHeight = tonumber(h)
        end
    end

    beam:SetHidden(false)

    if type(pin.SetDrawLevel) == "function" then pin:SetDrawLevel(5) end
    pin:SetHidden(false)
    return true
end

function R:RefreshMarkers()
    if not EPC.saved or EPC.saved.enabled == false or EPC.saved.resourcePinsEnabled == false or EPC.saved.resourcePinsShow3D == false then
        self:HideAll("disabled")
        return
    end

    local now = nowMs()
    if self.debugEntry and now > (tonumber(self.debugUntil) or 0) then
        self.debugEntry = nil
        self.debugUntil = 0
    end

    local hudFragmentHidden = self:IsWorldGlowSuppressed()
    if hudFragmentHidden and self.debugEntry then
        self.debugUntil = now + 10000
    end

    local zoneId, px, py, pz = self:GetPlayerRawPosition()
    if not zoneId then self:HideAll("no player position") return end
    local bucket = self:GetZoneBucket(zoneId, false)
    if type(bucket) ~= "table" then bucket = {} end

    if self.lastRenderZoneId ~= zoneId then
        self.lastRenderZoneId = zoneId
        self.lastAllZoneRefreshAt = 0
    end

    -- The full bundled database stays available for the current zone, but 3D
    -- controls are created only for a bounded nearest set. Creating thousands of
    -- 3D controls at once causes severe FPS loss even when a texture fails to draw.
    local maxDistanceM = math.max(15, math.min(500, tonumber(EPC.saved.resourcePinsDistance) or 200))
    local markerLimit = math.floor(math.max(MIN_VISIBLE_MARKERS, math.min(MAX_VISIBLE_MARKERS,
        tonumber(EPC.saved.resourcePinsMaxVisible) or DEFAULT_VISIBLE_MARKERS)))
    local visible = {}
    self:PruneDepleted(zoneId)

    local learnedShadow = self:BuildLearnedShadowGrid(bucket)
    for i = 1, #bucket do
        local entry = bucket[i]
        if type(entry) == "table" and self:IsKindEnabled(entry.kind)
            and not self:IsPositionDepleted(zoneId, entry.x, entry.z, entry.kind) then
            local distanceM = distance3Dcm(px, py, pz, entry.x, entry.y, entry.z) / 100
            local horizontalDistanceM = distance2Dcm(px, pz, entry.x, entry.z) / 100
            if distanceM <= maxDistanceM then
                visible[#visible + 1] = { entry = entry, distanceM = distanceM, horizontalDistanceM = horizontalDistanceM, learned = true }
            end
        end
    end

    -- Query the spatial index around the player instead of scanning/instantiating
    -- every record in a dense zone. Every bundled record is still available and
    -- becomes eligible automatically as the player moves into range.
    self:AppendNearbyCommunity(zoneId, px, py, pz, maxDistanceM, visible, learnedShadow)

    if self.debugEntry and now <= (tonumber(self.debugUntil) or 0) then
        visible[#visible + 1] = { entry = self.debugEntry, distanceM = 4, horizontalDistanceM = 4, debug = true }
    elseif self.debugEntry then
        self.debugEntry = nil
        self.debugUntil = 0
    end

    self.nearestDepletionCandidate = nil
    for i = 1, #visible do
        local candidate = visible[i]
        local candidateProbeDistance = tonumber(candidate.horizontalDistanceM) or tonumber(candidate.distanceM) or 999999
        local currentProbeDistance = self.nearestDepletionCandidate and (tonumber(self.nearestDepletionCandidate.horizontalDistanceM) or tonumber(self.nearestDepletionCandidate.distanceM) or 999999) or 999999
        if candidate.debug ~= true and (not self.nearestDepletionCandidate or candidateProbeDistance < currentProbeDistance) then
            self.nearestDepletionCandidate = candidate
        end
    end

    table.sort(visible, function(a, b)
        -- Always keep the test marker first, then learned pins, then nearest data.
        if a.debug ~= b.debug then return a.debug == true end
        if a.learned ~= b.learned then return a.learned == true end
        return (tonumber(a.distanceM) or 999999) < (tonumber(b.distanceM) or 999999)
    end)

    local candidateCount = math.min(#visible, markerLimit)
    self.lastRequestedVisibleCount = #visible
    self.lastTargetCount = candidateCount
    self.lastMarkerLimit = markerLimit
    self.lastAllZoneCapped = #visible > markerLimit
    self.allZoneBuildComplete = true

    local renderedCount = 0
    local failedCount = 0
    for i = 1, candidateCount do
        local tex = self:EnsureMarker(i)
        if self:PositionMarker(tex, visible[i].entry, visible[i].distanceM) then
            renderedCount = renderedCount + 1
        else
            tex:SetHidden(true)
            failedCount = failedCount + 1
        end
    end
    if self.markers then
        for i = candidateCount + 1, #self.markers do self.markers[i]:SetHidden(true) end
    end

    self.lastCandidateCount = candidateCount
    self.lastPositionFailures = failedCount
    self.lastVisibleCount = renderedCount
    local communityCount = tonumber(self.lastCommunityZoneCount) or 0
    if renderedCount > 0 then
        self.lastHiddenReason = hudFragmentHidden and "prepared; HUD fragment hidden" or "visible"
    else
        self.lastHiddenReason = (#bucket == 0 and communityCount == 0) and "no resource nodes here" or "no nodes passed range/filter"
    end
end

function R:ClearLearnedLocations()
    if EPC.saved then EPC.saved.resourcePinLocations = {} end
    self.pendingResource = nil
    self:HideAll("cleared")
end

function R:GetLearnedCount()
    local total = 0
    local all = EPC.saved and EPC.saved.resourcePinLocations
    if type(all) == "table" then
        for _, bucket in pairs(all) do if type(bucket) == "table" then total = total + #bucket end end
    end
    return total
end

function R:GetCurrentZoneCount()
    local zoneId = select(1, self:GetPlayerRawPosition())
    local bucket = zoneId and self:GetZoneBucket(zoneId, false)
    return type(bucket) == "table" and #bucket or 0
end

function R:GetCommunityCurrentZoneCount()
    if not EPC.saved or EPC.saved.resourcePinsCommunityEnabled == false then return 0 end
    local zoneId = select(1, self:GetPlayerRawPosition())
    local cache = zoneId and self:BuildCommunityZoneCache(zoneId) or nil
    return type(cache) == "table" and (tonumber(cache.count) or 0) or 0
end

function R:GetRenderFragmentState()
    if self.worldFragment and type(self.worldFragment.IsHidden) == "function" then
        local ok, hidden = pcall(self.worldFragment.IsHidden, self.worldFragment)
        if ok then return hidden and "HIDDEN" or "VISIBLE" end
    end
    return "UNKNOWN"
end

function R:GetStatusText()
    local last = self.lastLearnedName or "none"
    local kind = self.lastLearnedKind and (TYPE_LABELS[self.lastLearnedKind] or self.lastLearnedKind) or "none"
    local communityOn = EPC.saved and EPC.saved.resourcePinsCommunityEnabled ~= false
    local communityHere = communityOn and self:GetCommunityCurrentZoneCount() or 0
    local zoneId = select(1, self:GetPlayerRawPosition()) or 0
    local requestedMode = EPC.saved and tostring(EPC.saved.resourcePinsIconMode or "SUITE_GLOW") or "SUITE_GLOW"
    local sourceMode = requestedMode == "CATEGORY" and "native ESO / proven control" or (requestedMode == "SUITE_GLOW" and "native Glow / proven control" or "custom DDS / proven control")
    if self.lastIconFallback then sourceMode = sourceMode .. " -> native fallback" end
    local loadState = self.lastIconLoaded == nil and "unknown" or (self.lastIconLoaded and "loaded" or "NOT loaded")
    local dims = (self.lastIconWidth and self.lastIconHeight) and string.format(" %dx%d", self.lastIconWidth, self.lastIconHeight) or ""
    local sharpText = (self.lastSharpMode == false) and "soft" or "sharp"
    local tintText = tostring(math.floor(tonumber(EPC.saved and EPC.saved.resourcePinsIconTintStrength or 85) or 85)) .. "% tint"
    local sizeText = tostring(math.floor(tonumber(EPC.saved and EPC.saved.resourcePinsIconSize or 100) or 100)) .. "% size"
    local glowText = (EPC.saved and EPC.saved.resourcePinsValueGlow == false) and "single glow" or ("value glow " .. tostring(self.lastGlowTier or "COMMON"))
    local iconMode = requestedMode .. " (" .. sourceMode .. "; " .. loadState .. dims .. "; " .. sharpText .. "; " .. sizeText .. "; " .. tintText .. "; " .. glowText .. ")"
    local maxDistanceM = EPC.saved and tonumber(EPC.saved.resourcePinsDistance) or 200
    local capText = self.lastAllZoneCapped and string.format("; nearest %d shown", tonumber(self.lastMarkerLimit) or DEFAULT_VISIBLE_MARKERS) or ""
    local depletedCount = self:PruneDepleted(zoneId)
    local farmFocusText = self:GetFarmTargetSummary()
    local cooldownMinutes = EPC.saved and tonumber(EPC.saved.resourcePinsDepletedCooldownMinutes) or 5
    local probeDistanceText = self.lastDepletionProbeDistanceM and string.format("%.1fm", tonumber(self.lastDepletionProbeDistanceM) or 0) or "n/a"
    local probeState = tostring(self.lastDepletionProbeState or "idle")
    return string.format("Resource Pins: zone %s, %d learned total, %d learned here, %d community here, %d temporarily depleted, %d in range, %d candidates, %d rendered, %d render failures. Farm Focus: %s. Depletion mode: SAME-TYPE HARVESTED + MISSING COMMUNITY; cooldown %dm. Depletion probe: %s / %s. Community display: FULL DATA / DYNAMIC NEAREST%s; range %dm. Community data: %s (%d bundled records). Renderer: %s. HUD fragment: %s. Icon mode: %s. Last state: %s. Last learned: %s (%s).",
        tostring(zoneId), self:GetLearnedCount(), self:GetCurrentZoneCount(), communityHere, depletedCount,
        tonumber(self.lastRequestedVisibleCount) or 0, tonumber(self.lastCandidateCount) or 0, tonumber(self.lastVisibleCount) or 0, tonumber(self.lastPositionFailures) or 0,
        farmFocusText, math.floor(cooldownMinutes), probeDistanceText, probeState, capText, math.floor(maxDistanceM), communityOn and "ON" or "OFF", COMMUNITY_DATASET_RECORDS,
        self.worldRenderOriginReady and "READY" or "NOT READY", self:GetRenderFragmentState(), iconMode, tostring(self.lastHiddenReason or "unknown"),
        tostring(last), tostring(kind))
end

function R:StartDebugTestGlow()
    local zoneId, x, y, z = self:GetPlayerRawPosition()
    if not zoneId then return false end
    local heading = tonumber(safe(GetPlayerCameraHeading, 0)) or 0
    self.debugEntry = {
        kind = "ORE", name = "Resource Pin Test", x = x + (math.sin(heading) * 400), y = y, z = z + (math.cos(heading) * 400),
    }
    self.debugUntil = nowMs() + 10000
    self:RefreshMarkers()
    return true
end

function R:RefreshSettings()
    self.allZoneBuildComplete = true
    self.lastAllZoneRefreshAt = 0
    if EPC.saved and EPC.saved.resourcePinsCommunityEnabled == false then
        self.communityZoneId = nil
        self.communityZoneCache = nil
        self.lastCommunityZoneCount = 0
    end
    self:RefreshMarkers()
end

function R:HandleSlash(text)
    local arg = string.lower(tostring(text or ""))
    arg = string.match(arg, "^%s*(.-)%s*$") or ""
    if arg == "clear" then
        self:ClearLearnedLocations()
        if EPC.Print then EPC:Print("Resource Pins learned locations cleared.") end
    elseif arg == "resetdepleted" then
        self:ClearDepletedLocations()
        if EPC.Print then EPC:Print("Resource Pins temporary depleted states reset.") end
    elseif arg == "test" then
        if self:StartDebugTestGlow() then EPC:Print("Resource Pins: test pin queued about 4m ahead. Close Settings/menus to view it for 10 seconds.")
        else EPC:Print("Resource Pins: could not get your world position for the test glow.") end
    else
        if EPC.Print then EPC:Print(self:GetStatusText() .. " Commands: /easresources test, /easresources clear, /easresources resetdepleted") end
    end
end

function R:Initialize()
    self.markers = {}
    self.pendingResource = nil
    self.depletionProbeKey = nil
    self.depletionProbeSince = 0
    self.depletionProbePlayerX = nil
    self.depletionProbePlayerZ = nil
    self.depletionAutoLockUntil = 0
    self.lastDepletionProbeDistanceM = nil
    self.lastDepletionProbeState = "idle"
    self.nearestDepletionCandidate = nil
    self.liveCommunityNode = nil
    self.liveCommunityVanishedAt = 0
    self.lastOwnCollectionAt = 0
    self.lastResourceInteractionAt = 0
    self.lastFishingSeenAt = 0
    self.lastVisibleCount = 0
    self.lastCandidateCount = 0
    self.lastPositionFailures = 0
    self.lastHiddenReason = "not rendered yet"
    self.worldRenderOriginReady = false
    self.communityZoneId = nil
    self.communityZoneCache = nil
    self.lastCommunityZoneCount = 0
    self.lastCommunityRawZoneCount = 0
    self.lastCommunityError = nil
    self.lastRenderZoneId = nil
    self.lastAllZoneRefreshAt = 0
    self.allZoneBuildComplete = false
    self.lastTargetCount = 0
    self.lastRequestedVisibleCount = 0

    if EPC.saved then
        EPC.saved.resourcePinLocations = EPC.saved.resourcePinLocations or {}
        EPC.saved.resourcePinsDepleted = EPC.saved.resourcePinsDepleted or {}

        -- 0.29.00 removed the Suite World Marker presentation option. Migrate
        -- old saved selections so users do not keep an invisible/invalid mode.
        if EPC.saved.resourcePinsIconMode == "WORLD" then
            EPC.saved.resourcePinsIconMode = "CATEGORY"
        end
        local removedWorldMarkerKeys = {
            "resourcePinsIconOre", "resourcePinsIconWood", "resourcePinsIconCloth",
            "resourcePinsIconAlchemy", "resourcePinsIconRunes", "resourcePinsIconWater",
            "resourcePinsIconFishing", "resourcePinsIconSpecial", "resourcePinsIconOther",
        }
        for i = 1, #removedWorldMarkerKeys do
            local key = removedWorldMarkerKeys[i]
            if EPC.saved[key] == "WORLD" then EPC.saved[key] = "AUTO" end
        end
        -- 0.28.85 renderer migration: keep the safe dynamic-nearest performance
        -- cap, but use the exact single-Texture 3D path proven by LoreBooks.
        if (tonumber(EPC.saved.resourcePinsPerformanceVersion) or 0) < 4 then
            EPC.saved.resourcePinsCommunityShowAll = true
            EPC.saved.resourcePinsMaxVisible = 72
            EPC.saved.resourcePinsSafeGlowFallback = false
            if not tonumber(EPC.saved.resourcePinsDistance) or tonumber(EPC.saved.resourcePinsDistance) < 200 then
                EPC.saved.resourcePinsDistance = 200
            end
            EPC.saved.resourcePinsPerformanceVersion = 4
        end
    end

    self:EnsureWindow()
    local prefix = (EPC.name or "EAS") .. "_ResourcePins"
    EVENT_MANAGER:RegisterForUpdate(prefix .. "_Interact", INTERACTION_UPDATE_MS, function() self:CaptureResourceInteraction() end)
    EVENT_MANAGER:RegisterForUpdate(prefix .. "_Render", RENDER_UPDATE_MS, function() self:RefreshMarkers() end)

    if EVENT_LOOT_RECEIVED ~= nil then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_Loot", EVENT_LOOT_RECEIVED, function(_, receivedBy, itemLink, quantity, itemSound, lootType, lootedBySelf, isPickpocketLoot, questItemIcon, itemId, isStolen)
            self:HandleLootReceived(receivedBy, itemLink, quantity, itemSound, lootType, lootedBySelf, isPickpocketLoot, questItemIcon, itemId, isStolen)
        end)
    end
    if EVENT_CLIENT_INTERACT_RESULT ~= nil then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_InteractResult", EVENT_CLIENT_INTERACT_RESULT, function(_, result, targetName)
            self:HandleInteractResult(result, targetName)
        end)
    end
    if EVENT_LOCKPICK_SUCCESS ~= nil then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_LockpickSuccess", EVENT_LOCKPICK_SUCCESS, function()
            self:HandleLockpickSuccess()
        end)
    end
    if EVENT_PLAYER_ACTIVATED ~= nil then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_Activated", EVENT_PLAYER_ACTIVATED, function()
            self.pendingResource = nil
            self.lastOwnCollectionAt = 0
            self.depletionProbeKey = nil
            self.depletionProbeSince = 0
            self.depletionProbePlayerX = nil
            self.depletionProbePlayerZ = nil
            self.lastDepletionProbeDistanceM = nil
            self.lastDepletionProbeState = "zone change"
            self.liveCommunityNode = nil
            self.liveCommunityVanishedAt = 0
            self:HideAll("zone change")
            zo_callLater(function() self:ResetRenderSpace() self:RefreshMarkers() end, 400)
        end)
    end

    SLASH_COMMANDS["/easresources"] = function(text) self:HandleSlash(text) end
end
