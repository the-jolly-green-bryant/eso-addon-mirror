-- ESO Adventurer Suite
-- v0.29.497 - 3D resource pin map-layer and duplicate-location hotfix.
-- Keep community records scoped to the player's active map when ESO exposes a
-- trustworthy current-map identity, and merge stale learned/community doubles.

local EPC = ESOProgressionCoach
if not EPC or not EPC.ResourcePins then return end
local R = EPC.ResourcePins

local ORIGINAL_BUILD_COMMUNITY_CACHE = R.BuildCommunityZoneCache
local ORIGINAL_INITIALIZE = R.Initialize

local COMMUNITY_MODULES_029497 = { "AD", "DC", "DLC", "EP", "NF" }
local COMMUNITY_KIND_BY_PIN_029497 = {
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

local NORMAL_DEDUPE_CM_029497 = 500
local FISHING_DEDUPE_CM_029497 = 1400
local VERTICAL_DEDUPE_CM_029497 = 2500

local function SafeCall029497(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a, b, c, d = pcall(fn, ...)
    if not ok then return nil end
    return a, b, c, d
end

local function Distance2D029497(ax, az, bx, bz)
    local dx = (tonumber(ax) or 0) - (tonumber(bx) or 0)
    local dz = (tonumber(az) or 0) - (tonumber(bz) or 0)
    return math.sqrt((dx * dx) + (dz * dz))
end

local function DedupeRadius029497(kind)
    return tostring(kind or "") == "FISHING" and FISHING_DEDUPE_CM_029497 or NORMAL_DEDUPE_CM_029497
end

local function CompatibleKinds029497(a, b)
    a, b = tostring(a or "RESOURCE"), tostring(b or "RESOURCE")
    return a == b or a == "RESOURCE" or b == "RESOURCE"
end

local function NormalizeMapKey029497(value)
    local s = string.lower(tostring(value or ""))
    s = s:gsub("\\", "/")
    s = s:gsub("^/?esoui/art/maps/", "")
    s = s:gsub("^/?art/maps/", "")
    s = s:gsub("%.dds$", "")
    s = s:gsub("_[0-9]+$", "")
    s = s:gsub("^/+", ""):gsub("/+$", "")
    return s
end

local function CurrentTrustedMapKey029497()
    -- Do not force/set the map here. Only trust ESO's existing current map when
    -- its zone index agrees with the player's actual zone index.
    local playerZoneIndex = tonumber(SafeCall029497(GetUnitZoneIndex, "player"))
    local mapZoneIndex = type(GetCurrentMapZoneIndex) == "function" and tonumber(SafeCall029497(GetCurrentMapZoneIndex)) or nil
    if playerZoneIndex and mapZoneIndex and playerZoneIndex ~= mapZoneIndex then
        return nil
    end

    if type(GetCurrentMapId) ~= "function" or type(GetMapTileTextureForMapId) ~= "function" then
        return nil
    end
    local mapId = tonumber(SafeCall029497(GetCurrentMapId))
    if not mapId or mapId <= 0 then return nil end

    local texture = SafeCall029497(GetMapTileTextureForMapId, mapId, 1)
    if type(texture) ~= "string" or texture == "" then
        texture = SafeCall029497(GetMapTileTextureForMapId, mapId, 0)
    end
    local key = NormalizeMapKey029497(texture)
    return key ~= "" and key or nil
end

function R:BuildCommunityZoneCache(zoneId, forceForExplicitHunt)
    if not EPC.saved then return nil end
    if EPC.saved.resourcePinsCommunityEnabled == false and forceForExplicitHunt ~= true then return nil end
    zoneId = tonumber(zoneId)
    if not zoneId then return nil end

    local mapKey = CurrentTrustedMapKey029497()
    if self.communityZoneId == zoneId
        and self.communityZoneMapKey029497 == mapKey
        and type(self.communityZoneCache) == "table" then
        return self.communityZoneCache
    end

    local root = EPC.CommunityResourceData
    if type(root) ~= "table" then
        self.lastCommunityError = "Suite Community Resource Data is not loaded"
        return nil
    end

    -- If ESO cannot prove which map the player is on, retain the original safe
    -- behavior rather than guessing from a stale world-map state.
    if not mapKey then
        self.communityZoneMapKey029497 = nil
        self.communityZoneId = nil
        self.communityZoneCache = nil
        return ORIGINAL_BUILD_COMMUNITY_CACHE and ORIGINAL_BUILD_COMMUNITY_CACHE(self, zoneId, forceForExplicitHunt) or nil
    end

    local matchingMapData = {}
    for m = 1, #COMMUNITY_MODULES_029497 do
        local module = root[COMMUNITY_MODULES_029497[m]]
        local zoneData = type(module) == "table" and module[zoneId] or nil
        if type(zoneData) == "table" then
            for storedMapKey, mapData in pairs(zoneData) do
                if type(mapData) == "table" and NormalizeMapKey029497(storedMapKey) == mapKey then
                    matchingMapData[#matchingMapData + 1] = mapData
                end
            end
        end
    end

    -- A missing exact map key is safer as a fallback to the original decoder;
    -- do not silently make all community pins disappear on unusual maps.
    if #matchingMapData == 0 then
        self.communityZoneMapKey029497 = nil
        self.communityZoneId = nil
        self.communityZoneCache = nil
        return ORIGINAL_BUILD_COMMUNITY_CACHE and ORIGINAL_BUILD_COMMUNITY_CACHE(self, zoneId, forceForExplicitHunt) or nil
    end

    local cache = {
        zoneId = zoneId,
        mapKey = mapKey,
        cells = {}, count = 0, rawCount = 0, byKind = {}, corruptRecords = 0,
    }
    local dedupe = {}
    for i = 1, #matchingMapData do
        local mapData = matchingMapData[i]
        for pinTypeId, packed in pairs(mapData) do
            local kind = COMMUNITY_KIND_BY_PIN_029497[tonumber(pinTypeId)]
            if kind and type(packed) == "string" then
                self:DecodeCommunityPacked(cache, dedupe, kind, packed)
            end
        end
    end

    self.communityZoneId = zoneId
    self.communityZoneMapKey029497 = mapKey
    self.communityZoneCache = cache
    self.lastCommunityZoneCount = cache.count
    self.lastCommunityRawZoneCount = cache.rawCount
    self.lastCommunityMapKey029497 = mapKey
    self.lastCommunityError = nil
    return cache
end

function R:IsCommunityShadowed(entry, shadow)
    if type(entry) ~= "table" or type(shadow) ~= "table" then return false end
    local x, y, z = tonumber(entry.x), tonumber(entry.y), tonumber(entry.z)
    if not x or not y or not z then return false end

    local radius = DedupeRadius029497(entry.kind)
    local gx = math.floor(x / radius)
    local gz = math.floor(z / radius)
    -- BuildLearnedShadowGrid uses the older 3.75m cells, so direct scan the
    -- nearby shadow buckets and apply the wider final distance check.
    for _, nearby in pairs(shadow) do
        if type(nearby) == "table" then
            for i = 1, #nearby do
                local learned = nearby[i]
                if type(learned) == "table"
                    and CompatibleKinds029497(learned.kind, entry.kind)
                    and math.abs((tonumber(learned.y) or y) - y) <= VERTICAL_DEDUPE_CM_029497
                    and Distance2D029497(learned.x, learned.z, x, z) <= math.max(radius, DedupeRadius029497(learned.kind)) then
                    return true
                end
            end
        end
    end
    return false
end

function R:DeduplicateVisibleCandidates(visible)
    if type(visible) ~= "table" or #visible < 2 then return visible, 0 end

    table.sort(visible, function(a, b)
        if a.debug ~= b.debug then return a.debug == true end
        if a.focusedMissing ~= b.focusedMissing then return a.focusedMissing == true end
        if a.skyshard ~= b.skyshard then return a.skyshard == true end
        if a.learned ~= b.learned then return a.learned == true end
        return (tonumber(a.distanceM) or 999999) < (tonumber(b.distanceM) or 999999)
    end)

    local out, removed = {}, 0
    for i = 1, #visible do
        local candidate = visible[i]
        local entry = candidate and candidate.entry
        local duplicate = false
        if candidate.debug ~= true and candidate.skyshard ~= true and type(entry) == "table" then
            local x, y, z = tonumber(entry.x), tonumber(entry.y), tonumber(entry.z)
            if x and y and z then
                for j = 1, #out do
                    local prior = out[j]
                    local other = prior and prior.entry
                    if prior.debug ~= true and prior.skyshard ~= true and type(other) == "table"
                        and CompatibleKinds029497(other.kind, entry.kind)
                        and math.abs((tonumber(other.y) or y) - y) <= VERTICAL_DEDUPE_CM_029497
                        and Distance2D029497(other.x, other.z, x, z) <= math.max(DedupeRadius029497(entry.kind), DedupeRadius029497(other.kind)) then
                        duplicate = true
                        break
                    end
                end
            end
        end
        if duplicate then
            removed = removed + 1
        else
            out[#out + 1] = candidate
        end
    end
    self.lastVisibleDuplicatesRemoved = removed
    return out, removed
end

function R:CompactLearnedLocationData029497()
    if not EPC.saved or type(EPC.saved.resourcePinLocations) ~= "table" then return 0 end
    local removed = 0
    for zoneKey, bucket in pairs(EPC.saved.resourcePinLocations) do
        if type(bucket) == "table" then
            local compact = {}
            for i = 1, #bucket do
                local entry = bucket[i]
                local duplicate = nil
                if type(entry) == "table" and tonumber(entry.x) and tonumber(entry.y) and tonumber(entry.z) then
                    for j = 1, #compact do
                        local other = compact[j]
                        if CompatibleKinds029497(other.kind, entry.kind)
                            and math.abs((tonumber(other.y) or 0) - (tonumber(entry.y) or 0)) <= VERTICAL_DEDUPE_CM_029497
                            and Distance2D029497(other.x, other.z, entry.x, entry.z) <= math.max(DedupeRadius029497(other.kind), DedupeRadius029497(entry.kind)) then
                            duplicate = other
                            break
                        end
                    end
                    if duplicate then
                        if tostring(duplicate.kind or "RESOURCE") == "RESOURCE" and tostring(entry.kind or "RESOURCE") ~= "RESOURCE" then
                            duplicate.kind = entry.kind
                        end
                        duplicate.lastSeenAt = math.max(tonumber(duplicate.lastSeenAt) or 0, tonumber(entry.lastSeenAt) or 0)
                        removed = removed + 1
                    else
                        compact[#compact + 1] = entry
                    end
                else
                    removed = removed + 1
                end
            end
            EPC.saved.resourcePinLocations[zoneKey] = compact
        end
    end
    self.lastLearnedCompactionRemoved029497 = removed
    return removed
end

if type(ORIGINAL_INITIALIZE) == "function" then
    function R:Initialize(...)
        ORIGINAL_INITIALIZE(self, ...)
        if EPC.saved and (tonumber(EPC.saved.resourcePinsDataCompactionVersion) or 0) < 3 then
            local removed = self:CompactLearnedLocationData029497()
            EPC.saved.resourcePinsDataCompactionVersion = 3
            self.lastLearnedCompactionRemoved029497 = removed
            self:RefreshMarkers()
        end
    end
end
