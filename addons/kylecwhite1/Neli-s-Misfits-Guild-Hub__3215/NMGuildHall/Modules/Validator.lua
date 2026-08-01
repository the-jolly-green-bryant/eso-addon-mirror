-- Validator Module
-- Input sanitization and validation for NMGuildHall
-- Dependencies: Message (optional)
-- Provides data validation, sanitization, and caching for performance

local Addon = NMGuildHall

local Validator = {
    -- Validation patterns
    patterns = {
        playerName = "^[%w%s]+$",
        zoneName = "^[%w%s%-%']+$",
        guildName = "^[%w%s%-%']+$",
        numeric = "^%d+$",
        alphanumeric = "^[%w]+$"
    },
    
    -- Maximum lengths
    maxLengths = {
        playerName = 64,
        zoneName = 128,
        guildName = 64,
        searchText = 100,
        customMessage = 256
    },
    
    -- Validation cache for performance
    validationCache = {},
    cacheSize = 100,
    cacheHits = 0,
    cacheMisses = 0
}

-- Initialize the validator
function Validator:Initialize()
    self.validationCache = {}
    self.cacheOrder = {} -- Track access order for LRU eviction
    self._cacheCount = 0
    self.cacheHits = 0
    self.cacheMisses = 0
    
    if Addon and Addon.Message then
        Addon.Message:For("Validator"):Debug(GetString(NMGH_DEBUG_VALIDATOR_INIT))
    end
end

-- Create validation result object
local function CreateResult(success, value, errors, warnings)
    return {
        success = success,
        value = value,
        errors = errors or {},
        warnings = warnings or {},
        hasErrors = function(self) return #self.errors > 0 end,
        hasWarnings = function(self) return #self.warnings > 0 end,
        getFirstError = function(self) return self.errors[1] end,
        getAllErrors = function(self) return table.concat(self.errors, "; ") end
    }
end

local function IsValidColorCode(colorCode)
    if type(colorCode) ~= "string" or string.sub(colorCode, 1, 2) ~= "|c" then
        return false
    end

    local hexPart = string.sub(colorCode, 3)
    return (#hexPart == 6 or #hexPart == 8) and hexPart:match("^[0-9A-Fa-f]+$") ~= nil
end

-- Generate cache key
function Validator:_GenerateCacheKey(input, fieldType, options)
    local key = tostring(input) .. "|" .. tostring(fieldType) .. "|"
    if options.required then key = key .. "R" end
    if options.strict then key = key .. "S" end
    if options.maxLength then key = key .. "L" .. tostring(options.maxLength) end
    return key
end

-- Get from cache with LRU refresh
function Validator:_GetFromCache(cacheKey)
    local cached = self.validationCache[cacheKey]
    if cached then
        self.cacheHits = self.cacheHits + 1
        
        -- Move key to end of cacheOrder (most recent)
        for i, key in ipairs(self.cacheOrder) do
            if key == cacheKey then
                table.remove(self.cacheOrder, i)
                table.insert(self.cacheOrder, cacheKey)
                break
            end
        end
        
        return cached
    end
    self.cacheMisses = self.cacheMisses + 1
    return nil
end

-- Store in cache with LRU size management
function Validator:_StoreInCache(cacheKey, result)
    if not self.validationCache[cacheKey] then
        self._cacheCount = (self._cacheCount or 0) + 1
        table.insert(self.cacheOrder, cacheKey) -- Add new key to most recent position
    else
        -- If key already exists, update its position to most recent
        for i, key in ipairs(self.cacheOrder) do
            if key == cacheKey then
                table.remove(self.cacheOrder, i)
                table.insert(self.cacheOrder, cacheKey)
                break
            end
        end
    end
    self.validationCache[cacheKey] = result

    -- Evict least recently used entry if over capacity
    if (self._cacheCount or 0) > self.cacheSize then
        local evictKey = table.remove(self.cacheOrder, 1) -- Remove the oldest key (LRU)
        if evictKey then
            self.validationCache[evictKey] = nil
            self._cacheCount = (self._cacheCount or 1) - 1
        end
    end
end

-- Validate and sanitize string input
function Validator:ValidateString(input, fieldType, options)
    options = options or {}
    
    -- Generate cache key
    local cacheKey = self:_GenerateCacheKey(input, fieldType, options)
    
    -- Check cache first
    local cached = self:_GetFromCache(cacheKey)
    if cached then
        return cached.value, cached:getFirstError()
    end
    
    local errors = {}
    local warnings = {}
    
    -- Check for nil or non-string input
    if not input then
        if options.required then
            local result = CreateResult(false, nil, {"Required field missing"})
            self:_StoreInCache(cacheKey, result)
            return nil, result:getFirstError()
        end
        local result = CreateResult(true, options.default or "", {}, {"Using default value"})
        self:_StoreInCache(cacheKey, result)
        return result.value, nil
    end
    
    if type(input) ~= "string" then
        local result = CreateResult(false, nil, {"Input must be a string"})
        self:_StoreInCache(cacheKey, result)
        return nil, result:getFirstError()
    end
    
    -- ESO-safe sanitization - preserve game formatting codes
    local sanitized = input
    
    -- Only remove null bytes and harmful control characters
    -- KEEP: |, [, ], {, }, %, ' - ESO uses these for formatting
    sanitized = string.gsub(sanitized, "[%z]", "")  -- Remove null bytes only
    
    -- Remove non-printable control characters except whitespace
    sanitized = string.gsub(sanitized, "[%c]", function(char)
        local byte = string.byte(char)
        -- Keep: tab(9), newline(10), carriage return(13), space(32)
        if byte == 9 or byte == 10 or byte == 13 or byte == 32 then
            return char
        end
        return ""
    end)
    
    -- Trim whitespace (but preserve intentional spacing between words)
    local trimmed = string.gsub(sanitized, "^%s*(.-)%s*$", "%1")
    
    -- Check maximum length
    local maxLength = options.maxLength or self.maxLengths[fieldType] or 255
    if #trimmed > maxLength then
        if options.strict then
            local result = CreateResult(false, nil, {"Input exceeds maximum length of " .. tostring(maxLength)})
            self:_StoreInCache(cacheKey, result)
            return nil, result:getFirstError()
        else
            table.insert(warnings, "Input truncated to maximum length")
            trimmed = string.sub(trimmed, 1, maxLength)
        end
    end
    
    -- Check pattern if specified
    local pattern = self.patterns[fieldType]
    if pattern then
        if not string.match(trimmed, pattern) then
            if options.strict then
                local result = CreateResult(false, nil, {"Input contains invalid characters"})
                self:_StoreInCache(cacheKey, result)
                return nil, result:getFirstError()
            else
                table.insert(warnings, "Invalid characters removed")
                -- Remove invalid characters more safely
                trimmed = string.gsub(trimmed, "[^%w%s%-%']", "")
            end
        end
    end
    
    -- Create result and cache it
    local result = CreateResult(true, trimmed, {}, warnings)
    self:_StoreInCache(cacheKey, result)
    
    return result.value, nil
end

-- Validate numeric input
function Validator:ValidateNumber(input, options)
    options = options or {}
    
    if not input then
        if options.required then
            return nil, "Required number field missing"
        end
        return options.default or 0, nil
    end
    
    local num = tonumber(input)
    if not num then
        return nil, "Input is not a valid number"
    end
    
    -- Check range
    if options.min and num < options.min then
        return nil, "Number is below minimum value of " .. tostring(options.min)
    end
    
    if options.max and num > options.max then
        return nil, "Number is above maximum value of " .. tostring(options.max)
    end
    
    -- Check if integer required
    if options.integer and num ~= math.floor(num) then
        return nil, "Number must be an integer"
    end
    
    return num, nil
end

-- Validate boolean input
function Validator:ValidateBoolean(input, options)
    options = options or {}
    
    if input == nil then
        if options.required then
            return nil, "Required boolean field missing"
        end
        return options.default or false, nil
    end
    
    if type(input) == "boolean" then
        return input, nil
    end
    
    if type(input) == "string" then
        local lower = string.lower(input)
        if lower == "true" or lower == "1" or lower == "yes" then
            return true, nil
        elseif lower == "false" or lower == "0" or lower == "no" then
            return false, nil
        end
    end
    
    if type(input) == "number" then
        return input ~= 0, nil
    end
    
    return nil, "Input is not a valid boolean"
end

-- Validate table input
function Validator:ValidateTable(input, options)
    options = options or {}
    
    if not input then
        if options.required then
            return nil, "Required table field missing"
        end
        return options.default or {}, nil
    end
    
    if type(input) ~= "table" then
        return nil, "Input must be a table"
    end
    
    -- Check minimum size
    if options.minSize and #input < options.minSize then
        return nil, "Table must have at least " .. tostring(options.minSize) .. " elements"
    end
    
    -- Check maximum size
    if options.maxSize and #input > options.maxSize then
        return nil, "Table must have at most " .. tostring(options.maxSize) .. " elements"
    end
    
    return input, nil
end

-- Validate function input
function Validator:ValidateFunction(input, options)
    options = options or {}
    
    if not input then
        if options.required then
            return nil, "Required function field missing"
        end
        return options.default or function() end, nil
    end
    
    if type(input) ~= "function" then
        return nil, "Input must be a function"
    end
    
    return input, nil
end

-- Validate zone data structure
function Validator:ValidateZoneData(zoneData)
    if not zoneData or type(zoneData) ~= "table" then
        return nil, "Zone data must be a table"
    end
    
    local errors = {}
    
    -- Validate required fields
    -- Note: redirect zones intentionally have no id, so only validate if id is present
    if zoneData.id ~= nil then
        if not self:ValidateNumber(zoneData.id, {required = true, integer = true}) then
            table.insert(errors, "Invalid zone ID")
        end
    elseif not zoneData.redirect then
        table.insert(errors, "Missing zone ID")
    end
    
    -- Handle both nameKey and name field (name can be a function)
    if not zoneData.nameKey and not zoneData.name then
        table.insert(errors, "Missing zone name or nameKey")
    else
        -- Check nameKey if it exists
        if zoneData.nameKey then
            local nameKey, err = self:ValidateString(zoneData.nameKey, "zoneName", {required = true})
            if err then
                table.insert(errors, "Invalid zone nameKey: " .. err)
            end
        end
        
        -- Check name field if it exists and is a string
        if zoneData.name and type(zoneData.name) == "string" then
            local name, err = self:ValidateString(zoneData.name, "zoneName", {required = true})
            if err then
                table.insert(errors, "Invalid zone name: " .. err)
            end
        end
        -- If name is a function, that's valid for teleport data
    end
    
    if zoneData.icon ~= nil then
        if type(zoneData.icon) ~= "string" or zoneData.icon == "" then
            table.insert(errors, "Invalid zone icon")
        elseif string.find(zoneData.icon, "Ccolor", 1, true) then
            table.insert(errors, "Zone icon appears to use a color key; use textColor instead")
        end
    end
    
    if zoneData.textColor ~= nil then
        if type(zoneData.textColor) ~= "string" or zoneData.textColor == "" then
            table.insert(errors, "Invalid zone textColor")
        else
            local colorCode = zoneData.textColor
            if string.sub(colorCode, 1, 2) ~= "|c" then
                table.insert(errors, "Zone textColor must start with |c")
            elseif not IsValidColorCode(colorCode) then
                table.insert(errors, "Zone textColor must be |cRRGGBB or |cRRGGBBAA")
            end
        end
    end

    if #errors > 0 then
        return nil, table.concat(errors, "; ")
    end
    
    return zoneData, nil
end

-- Validate teleport entry
function Validator:ValidateTeleportEntry(entry)
    if not entry or type(entry) ~= "table" then
        return nil, "Teleport entry must be a table"
    end
    
    local errors = {}
    
    -- Validate label (can be a string or function)
    if not entry.label then
        table.insert(errors, "Missing entry label")
    else
        -- If label is a string, validate it
        if type(entry.label) == "string" then
            local label, err = self:ValidateString(entry.label, "zoneName", {required = true})
            if err then
                table.insert(errors, "Invalid entry label: " .. err)
            end
        -- If label is a function, that's valid for teleport data
        elseif type(entry.label) ~= "function" then
            table.insert(errors, "Entry label must be a string or function")
        end
    end
    
    if entry.icon ~= nil then
        if type(entry.icon) ~= "string" or entry.icon == "" then
            table.insert(errors, "Invalid entry icon")
        elseif string.find(entry.icon, "Ccolor", 1, true) then
            table.insert(errors, "Entry icon appears to use a color key; use textColor instead")
        end
    end
    
    if entry.textColor ~= nil then
        if type(entry.textColor) ~= "string" or entry.textColor == "" then
            table.insert(errors, "Invalid entry textColor")
        else
            local colorCode = entry.textColor
            if string.sub(colorCode, 1, 2) ~= "|c" then
                table.insert(errors, "Entry textColor must start with |c")
            elseif not IsValidColorCode(colorCode) then
                table.insert(errors, "Entry textColor must be |cRRGGBB or |cRRGGBBAA")
            end
        end
    end
    
    -- Validate callback
    if not entry.callback then
        table.insert(errors, "Missing entry callback")
    else
        local callback, err = self:ValidateFunction(entry.callback, {required = true})
        if err then
            table.insert(errors, "Invalid entry callback: " .. err)
        end
    end
    
    -- Validate available field (optional)
    if entry.available ~= nil then
        local available, err = self:ValidateBoolean(entry.available)
        if err then
            table.insert(errors, "Invalid available flag: " .. err)
        end
    end
    
    if #errors > 0 then
        return nil, table.concat(errors, "; ")
    end
    
    return entry, nil
end

-- Sanitize search text
function Validator:SanitizeSearchText(text)
    if not text then return "" end
    
    local sanitized, err = self:ValidateString(text, "searchText", {
        maxLength = self.maxLengths.searchText
    })
    
    if err then
        if Addon and Addon.Message then
            Addon.Message:For("Validator"):Warn(GetString(NMGH_ERR_API_CALL_FAILED), {error = err})
        end
        return ""
    end
    
    return sanitized
end

-- Validate player name
function Validator:ValidatePlayerName(name)
    if not name then return nil, "Player name is required" end
    
    local sanitized, err = self:ValidateString(name, "playerName", {
        required = true,
        strict = true
    })
    
    if err then
        return nil, "Invalid player name: " .. err
    end
    
    return sanitized, nil
end

-- Validate ESO display name format
function Validator:ValidateDisplayName(name)
    if not name then
        return nil, "Display name required"
    end
    
    -- ESO display names start with @
    if string.sub(name, 1, 1) ~= "@" then
        name = "@" .. name
    end
    
    -- Validate format: @username
    if not string.match(name, "^@[%w_%-]+$") then
        return nil, "Invalid display name format"
    end
    
    return name, nil
end

-- Validate ESO item link
function Validator:ValidateItemLink(link)
    if not link then
        return nil, "Item link required"
    end
    
    -- ESO item links: |H1:item:...|h[Name]|h
    if not string.match(link, "^|H%d+:item:.*|h%[.+%]|h$") then
        return nil, "Invalid item link format"
    end
    
    return link, nil
end

-- Get cache statistics
function Validator:GetCacheStats()
    local total = self.cacheHits + self.cacheMisses
    local hitRate = total > 0 and (self.cacheHits / total * 100) or 0
    return {
        hits = self.cacheHits,
        misses = self.cacheMisses,
        total = total,
        hitRate = hitRate,
        cacheSize = self._cacheCount or 0
    }
end

-- Clear validation cache
function Validator:ClearCache()
    self.validationCache = {}
    self.cacheOrder = {}
    self._cacheCount = 0
    self.cacheHits = 0
    self.cacheMisses = 0
    
    if Addon and Addon.Message then
        Addon.Message:For("Validator"):Debug(GetString(NMGH_DEBUG_ZONE_CACHE_INVALID))
    end
end

-- Export validator
NMGuildHall = NMGuildHall or {}
NMGuildHall.Validator = Validator

return Validator
