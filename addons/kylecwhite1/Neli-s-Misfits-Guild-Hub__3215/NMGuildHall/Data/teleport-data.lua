-- Teleport Data Module - Version 1.0
-- Provides validated zone teleport data with categories, fallbacks, and extensibility

local TELEPORT_DATA_VERSION = "1.0"
local TELEPORT_DATA_DATE = "2025-01-14"

-- Teleport registry with validation and categories
local TeleportRegistry = {
    version = TELEPORT_DATA_VERSION,
    date = TELEPORT_DATA_DATE,
    zones = {},
    categories = {},
    userDefined = {},
    loaded = false,
    validated = false,
    validationErrors = {},
    allowDuplicateIds = true
}

-- Zone data definitions
-- Optional text color override.
-- Example: textColor = "IconRegistry.Ccolor3"
-- Default behavior: white text is used if not specified.
local ZONE_DEFINITIONS = {
        -- Ebonheart Pact Zones
    {
        id = 280,
        nameKey = "NMGH_ZONE_BLEAKROCK",
        icon = "Ebon",
        sortOrder = 1
    },
    {
        id = 57,
        nameKey = "NMGH_ZONE_DESHAAN",
        icon = "Ebon",
        sortOrder = 2
    },
    {
        id = 101,
        nameKey = "NMGH_ZONE_EASTMARCH",
        icon = "Ebon",
        sortOrder = 3
    },
        {
        id = 117,
        nameKey = "NMGH_ZONE_SHADOWFEN",
        icon = "Ebon",
        sortOrder = 4
    },
    {
        id = 41,
        nameKey = "NMGH_ZONE_STONEFALLS",
        icon = "Ebon",
        sortOrder =  5
    },
    {
        id = 103,
        nameKey = "NMGH_ZONE_THE_RIFT",
        icon = "Ebon",
        sortOrder = 6
    },
        -- Daggerfall Covenant Zones
    {
        id = 104,
        nameKey = "NMGH_ZONE_ALIKR_DESERT",
        icon = "Dag",
        sortOrder = 7
    },
    {
        id = 92,
        nameKey = "NMGH_ZONE_BANGKORAI",
        icon = "Dag",
        sortOrder = 8
    },
    {
        id = 3,
        nameKey = "NMGH_ZONE_GLENUMBRA",
        icon = "Dag",
        sortOrder = 9
    },
    {
        id = 20,
        nameKey = "NMGH_ZONE_RIVENSPIRE",
        icon = "Dag",
        sortOrder = 10
    },
    {
        id = 19,
        nameKey = "NMGH_ZONE_STORMHAVEN",
        icon = "Dag",
        sortOrder = 11
    },
    {
        id = 534,
        nameKey = "NMGH_ZONE_STROS",
        icon = "Dag",
        sortOrder = 12
    },
        -- Aldmeri Dominion Zones
    {
        id = 381,
        nameKey = "NMGH_ZONE_AURIDON",
        icon = "Ald",
        sortOrder = 13
    },
    {
        id = 383,
        nameKey = "NMGH_ZONE_GRAHTWOOD",
        icon = "Ald",
        sortOrder = 14
    },
    {
        id = 108,
        nameKey = "NMGH_ZONE_GREENSHADE",
        icon = "Ald",
        sortOrder = 15
    },
        {
        id = 537,
        nameKey = "NMGH_ZONE_KHENARTHI",
        icon = "Ald",
        sortOrder = 16
    },
    {
        id = 58,
        nameKey = "NMGH_ZONE_MALABAL_TOR",
        icon = "Ald",
        sortOrder = 17
    },
    {
        id = 382,
        nameKey = "NMGH_ZONE_REAPERS_MARCH",
        icon = "Ald",
        sortOrder = 18
    },
        -- Neutral Base Game Zones
    {
        id = 347,
        nameKey = "NMGH_ZONE_COLDHARBOUR",
        icon = "Neu",
        sortOrder = 19
    },
    {
        id = 888,
        nameKey = "NMGH_ZONE_CRAGLORN",
        icon = "Neu",
        sortOrder = 20
    },
    {
        nameKey = "NMGH_ZONE_CYRODIIL",
        icon = "Neu",
        sortOrder = 21,
        redirect = "Campaign"
    },
    {
        nameKey = "NMGH_ZONE_IMPERIAL_CITY",
        icon = "Neu",
        sortOrder = 22,
        redirect = "Campaign"
    },
            -- Chapter & DLC
    {
        id = 1413,
        nameKey = "NMGH_ZONE_APOCRYPHA",
        icon = "Crown",
        collectibleId = 10475,
        sortOrder = 23
    },
    {
        id = 1027,
        nameKey = "NMGH_ZONE_ARTAEUM",
        icon = "Crown",
        collectibleId = 5107,
        sortOrder = 24
    },
    {
        id = 1208,
        nameKey = "NMGH_ZONE_BLACKREACH_ARKTHZAND",
        icon = "Crown",
        collectibleId = 8388,
        sortOrder = 25
    },
    {
        id = 1161,
        nameKey = "NMGH_ZONE_BLACKREACH_GREYMOOR",
        icon = "Crown",
        collectibleId = 7466,
        sortOrder = 26
    },
    {
        id = 1261,
        nameKey = "NMGH_ZONE_BLACKWOOD",
        icon = "Crown",
        collectibleId = 8659,
        sortOrder = 27
    },
    {
        id = 980,
        nameKey = "NMGH_ZONE_CLOCKWORK_CITY",
        icon = "Crown",
        collectibleId = 1240,
        sortOrder = 28
    },
    {
        id = 1282,
        nameKey = "NMGH_ZONE_FARGRAVE",
        icon = "Crown",
        collectibleId = 9365,
        sortOrder = 29
    },
    {
        id = 1383,
        nameKey = "NMGH_ZONE_GALEN",
        icon = "Crown",
        collectibleId = 10660,
        sortOrder = 30
    },
    {
        id = 823,
        nameKey = "NMGH_ZONE_GOLD_COAST",
        icon = "Crown",
        collectibleId = 306,
        sortOrder = 31
    },
    {
        id = 816,
        nameKey = "NMGH_ZONE_HEWS_BANE",
        icon = "Crown",
        collectibleId = 254,
        sortOrder = 32
    },
    {
        id = 1318,
        nameKey = "NMGH_ZONE_HIGH_ISLE",
        icon = "Crown",
        collectibleId = 10053,
        sortOrder = 33
    },
    {
        id = 726,
        nameKey = "NMGH_ZONE_MURKMIRE",
        icon = "Crown",
        collectibleId = 5755,
        sortOrder = 34
    },
    {
        id = 1086,
        nameKey = "NMGH_ZONE_NORTHERN_ELSWEYR",
        icon = "Crown",
        collectibleId = 5843,
        sortOrder = 35
    },
    {
        id = 1502,
        nameKey = "NMGH_ZONE_SOLSTICE",
        icon = "Crown",
        collectibleId = 13439,
        sortOrder = 36
    },
    {
        id = 1133,
        nameKey = "NMGH_ZONE_SOUTHERN_ELSWEYR",
        icon = "Crown",
        collectibleId = 6920,
        sortOrder = 37
    },
    {
        id = 1011,
        nameKey = "NMGH_ZONE_SUMMERSET",
        icon = "Crown",
        collectibleId = 5107,
        sortOrder = 38
    },
    {
        id = 1414,
        nameKey = "NMGH_ZONE_TELVANNI_PENINSULA",
        icon = "Crown",
        collectibleId = 10475,
        sortOrder = 39
    },
    {
        id = 1286,
        nameKey = "NMGH_ZONE_THE_DEADLANDS",
        icon = "Crown",
        collectibleId = 9365,
        sortOrder = 40
    },
    {
        id = 1207,
        nameKey = "NMGH_ZONE_THE_REACH",
        icon = "Crown",
        collectibleId = 8388,
        sortOrder = 41
    },
    {
        id = 849,
        nameKey = "NMGH_ZONE_VVARDENFELL",
        icon = "Crown",
        collectibleId = 593,
        sortOrder = 42
    },
    {
        id =1443,
        nameKey = "NMGH_ZONE_WEST_WEALD",
        icon = "Crown",
        collectibleId = 11111,
        sortOrder = 43
    },
    {
        id = 1160,
        nameKey = "NMGH_ZONE_WESTERN_SKYRIM",
        icon = "Crown",
        collectibleId = 7466,
        sortOrder = 44
    },
    {
        id = 684,
        nameKey = "NMGH_ZONE_WROTHGAR",
        icon = "Crown",
        collectibleId = 215,
        sortOrder = 45
    },
}

-- Validation functions
local function ValidateZoneEntry(entry, index)
    local errors = {}
    
    -- Required fields
    -- Redirect zones intentionally have no id
    if not entry.redirect and (not entry.id or type(entry.id) ~= "number") then
        table.insert(errors, string.format("Zone #%d: Missing or invalid 'id' field", index))
    end
    
    if not entry.nameKey or type(entry.nameKey) ~= "string" then
        table.insert(errors, string.format("Zone #%d (ID: %s): Missing or invalid 'nameKey' field", index, tostring(entry.id)))
    end
    
    if entry.collectibleId and type(entry.collectibleId) ~= "number" then
        table.insert(errors, string.format("Zone #%d (ID: %s): Invalid 'collectibleId' type", index, tostring(entry.id)))
    end
    
    -- Optional field type validation
    if entry.sortOrder and type(entry.sortOrder) ~= "number" then
        table.insert(errors, string.format("Zone #%d (ID: %s): Invalid 'sortOrder' type", index, tostring(entry.id)))
    end
    
    return errors
end

local function ValidateAllZones()
    local allErrors = {}
    local idMap = {}
    local nameKeyMap = {}
    
    -- Validate each entry and check for duplicates
    for index, entry in ipairs(ZONE_DEFINITIONS) do
        -- Validate structure
        local errors = ValidateZoneEntry(entry, index)
        for _, error in ipairs(errors) do
            table.insert(allErrors, error)
        end
        
        -- Check for duplicate IDs
        if entry.id then
            if not TeleportRegistry.allowDuplicateIds then
                if idMap[entry.id] then
                    table.insert(allErrors, string.format("Duplicate zone ID %d found at indices %d and %d", entry.id, idMap[entry.id], index))
                else
                    idMap[entry.id] = index
                end
            end
        end
        
        -- Check for duplicate nameKeys
        if entry.nameKey then
            if nameKeyMap[entry.nameKey] then
                table.insert(allErrors, string.format("Duplicate nameKey '%s' found at indices %d and %d", entry.nameKey, nameKeyMap[entry.nameKey], index))
            else
                nameKeyMap[entry.nameKey] = index
            end
        end
    end
    
    TeleportRegistry.validationErrors = allErrors
    TeleportRegistry.validated = true
    
    return #allErrors == 0, allErrors
end

-- Zone builder - creates zone entry with proper structure
local function BuildZoneEntry(zoneDef)
    if not zoneDef then
        return nil
    end
    -- Redirect zones intentionally have no id
    if not zoneDef.id and not zoneDef.redirect then
        return nil
    end
    
    -- Defer GetString call - will be called when actually needed
    local entry = {
        id = zoneDef.id,
        nameKey = zoneDef.nameKey,
        name = nil, -- Will be populated on first access
        collectibleId = zoneDef.collectibleId,
        sortOrder = zoneDef.sortOrder or 999,
        year = zoneDef.year,
        notes = zoneDef.notes,
        icon = zoneDef.icon, -- ADDED: Copy icon field
        textColor = zoneDef.textColor, -- ADDED: Copy textColor field
        redirect = zoneDef.redirect, -- UI page to open instead of teleporting
        
        -- Lazy loading for name and label
        _nameLoaded = false,
        _labelLoaded = false
    }
    
    return entry
end

-- Get zone name (lazy loaded)
local function GetZoneName(entry)
    if not entry._nameLoaded and entry.nameKey then
        -- Safe GetString call with fallback
        local success, result = pcall(GetString, _G[entry.nameKey])
        if success and result then
            entry.name = result
        else
            entry.name = entry.nameKey -- Fallback to key name
        end
        entry._nameLoaded = true
    end
    return entry.name or entry.nameKey
end

-- Get zone label (uses icon/textColor if available)
local function GetZoneLabel(entry)
    if not entry._labelLoaded then
        local color = entry.textColor or "|cF5F5F5"
        local name = GetZoneName(entry) or ""
        entry.label = color .. name .. "|r"
        entry._labelLoaded = true
    end
    return entry.label
end

-- Initialize the teleport registry
local function InitializeTeleportRegistry()
    -- Validate all zone data
    local isValid, errors = ValidateAllZones()
    
    if not isValid then
        -- Log validation errors if available
        if NMGuildHall and NMGuildHall.Message then
            for _, error in ipairs(errors) do
                NMGuildHall.Message:For("TeleportData"):Error(error)
            end
        end
    end
    
    -- Build zone entries
    TeleportRegistry.zones = {}
    for _, zoneDef in ipairs(ZONE_DEFINITIONS) do
        local entry = BuildZoneEntry(zoneDef)
        if entry then
            table.insert(TeleportRegistry.zones, entry)
        end
    end
    
    -- Sort zones by sortOrder
    table.sort(TeleportRegistry.zones, function(a, b)
        return a.sortOrder < b.sortOrder
    end)
    
    TeleportRegistry.loaded = true
end

-- Add user-defined teleport location
function TeleportRegistry:AddUserLocation(locationData)
    if not locationData or not locationData.id or not locationData.name then
        return false, "Invalid location data - 'id' and 'name' are required"
    end
    
    -- Check for duplicate ID
    for _, zone in ipairs(self.zones) do
        if zone.id == locationData.id then
            return false, "Zone ID already exists"
        end
    end
    
    for _, userZone in ipairs(self.userDefined) do
        if userZone.id == locationData.id then
            return false, "User-defined zone ID already exists"
        end
    end
    
    -- Create user zone entry
    local userZone = {
        id = locationData.id,
        name = locationData.name,
        nameKey = locationData.nameKey or "USER_DEFINED",
        collectibleId = locationData.collectibleId,
        sortOrder = locationData.sortOrder or 999,
        isUserDefined = true,
        label = "|cF5F5F5",
        _nameLoaded = true,
        _labelLoaded = true
    }
    
    table.insert(self.userDefined, userZone)
    
    return true, "User-defined location added successfully"
end

-- Remove user-defined location
function TeleportRegistry:RemoveUserLocation(zoneId)
    for i, userZone in ipairs(self.userDefined) do
        if userZone.id == zoneId then
            table.remove(self.userDefined, i)
            return true, "User-defined location removed"
        end
    end
    return false, "User-defined location not found"
end

-- Get all zones (including user-defined)
function TeleportRegistry:GetAllZones()
    local allZones = {}
    
    -- Add built-in zones
    for _, zone in ipairs(self.zones) do
        table.insert(allZones, zone)
    end
    
    -- Add user-defined zones
    for _, userZone in ipairs(self.userDefined) do
        table.insert(allZones, userZone)
    end
    
    return allZones
end

-- Get zones by category
function TeleportRegistry:GetZonesByCategory(categoryName)
    local filtered = {}
    
    for _, zone in ipairs(self.zones) do
        if zone.category == categoryName then
            table.insert(filtered, zone)
        end
    end
    
    return filtered
end

-- Get zones by alliance
function TeleportRegistry:GetZonesByAlliance(allianceId)
    local filtered = {}
    
    for _, zone in ipairs(self.zones) do
        if zone.alliance == allianceId then
            table.insert(filtered, zone)
        end
    end
    
    return filtered
end

-- Validate collectible ID is still valid
function TeleportRegistry:ValidateCollectibleId(collectibleId)
    if not collectibleId then
        return false, "No collectible ID provided"
    end
    
    -- Use ESO API to check if collectible exists
    local success, result = pcall(function()
        local name = GetCollectibleName(collectibleId)
        return name and name ~= ""
    end)
    
    if success and result then
        return true, "Collectible ID is valid"
    else
        return false, "Collectible ID may be invalid or inaccessible"
    end
end

-- Get registry info
function TeleportRegistry:GetInfo()
    return {
        version = self.version,
        date = self.date,
        loaded = self.loaded,
        validated = self.validated,
        zoneCount = #self.zones,
        userDefinedCount = #self.userDefined,
        categoryCount = 0,
        validationErrors = self.validationErrors
    }
end

-- Initialize the registry
InitializeTeleportRegistry()

-- Create legacy compatible structure
local legacyTeleportList = {}
for _, zone in ipairs(TeleportRegistry.zones) do
    table.insert(legacyTeleportList, {
        id = zone.id,
        nameKey = zone.nameKey,
        name = GetZoneName(zone),
        label = GetZoneLabel(zone),
        collectibleId = zone.collectibleId,
        icon = zone.icon, -- ADDED: Include icon field
        textColor = zone.textColor, -- ADDED: Include textColor field
        redirect = zone.redirect, -- UI page to open instead of teleporting
        -- Store reference to enhanced entry
        _enhanced = zone
    })
end

-- Export both enhanced registry and legacy structure
NMGuildHallTeleportData = {
    version = TELEPORT_DATA_VERSION,
    date = TELEPORT_DATA_DATE,
    TeleportList = legacyTeleportList,
    Registry = TeleportRegistry
}
NMGuildHallTeleportData = NMGuildHallTeleportData
