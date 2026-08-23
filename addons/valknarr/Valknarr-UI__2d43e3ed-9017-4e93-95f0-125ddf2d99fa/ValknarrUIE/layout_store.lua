ValknarrUIELayoutStore = ValknarrUIELayoutStore or {}

local Store = ValknarrUIELayoutStore
local Log = ValknarrUIELog
local SAVED_VARS_NAME = "ValknarrUIElementsEditor_SavedVariables"

-- Fallback positions if live centers cannot be read. Not written to SavedVars
-- until the player actually saves, so first /uiedit starts from the real HUD.
-- Chat defaults match native LoadSettings: 490x280, BOTTOMRIGHT y=-215
-- on a 1920x1080 HUD (center ≈ 0.872, 0.671).
local DEFAULT_ELEMENTS = {
    health = { x = 0.50, y = 0.86 },
    magicka = { x = 0.38, y = 0.82 },
    stamina = { x = 0.62, y = 0.82 },
    chat = { x = 0.872, y = 0.671, w = 490 / 1920, h = 280 / 1080 },
}

local defaults = {
    version = 2,
    -- Read by Grid:Settings() via Store:GetGrid().
    grid = { divisionsX = 40, divisionsY = 22, margin = 0.03 },
    userLayout = false,
    settings = {
        schema = 2,
        invertStickY = true,
        invertStickX = false,
        showDebugLog = false,
    },
}

local GRID_DEFAULTS = defaults.grid

-- Catalog ids we used to move and must never reapply. Experience/Level is
-- the native progress bar; leftover SavedVars would keep teleporting it.
local RETIRED_ELEMENT_IDS = {
    exp = true,
}

local MAX_DEBUG_LOG_LINES = 80

local function NormalizeGrid(source)
    local grid = type(source) == "table" and source or GRID_DEFAULTS
    local divisionsX = tonumber(grid.divisionsX) or GRID_DEFAULTS.divisionsX
    local divisionsY = tonumber(grid.divisionsY) or GRID_DEFAULTS.divisionsY
    local margin = tonumber(grid.margin) or GRID_DEFAULTS.margin
    if divisionsX < 4 then
        divisionsX = GRID_DEFAULTS.divisionsX
    end
    if divisionsY < 4 then
        divisionsY = GRID_DEFAULTS.divisionsY
    end
    if margin < 0 then
        margin = 0
    elseif margin > 0.2 then
        margin = GRID_DEFAULTS.margin
    end
    return {
        divisionsX = math.floor(divisionsX + 0.5),
        divisionsY = math.floor(divisionsY + 0.5),
        margin = margin,
        lineAlpha = tonumber(grid.lineAlpha) or 0.22,
    }
end

local function CopyOne(position, fallback)
    local result = {
        x = tonumber(position and position.x) or (fallback and fallback.x) or 0.5,
        y = tonumber(position and position.y) or (fallback and fallback.y) or 0.5,
    }
    local w = tonumber(position and position.w) or (fallback and fallback.w)
    local h = tonumber(position and position.h) or (fallback and fallback.h)
    if w then
        result.w = w
    end
    if h then
        result.h = h
    end
    return result
end

local function SanitizePosition(position, fallback)
    local result = CopyOne(position, fallback)
    local x = tonumber(result.x)
    local y = tonumber(result.y)
    if not x or x ~= x or x < -0.5 or x > 1.5 then
        result.x = (fallback and fallback.x) or 0.5
    end
    if not y or y ~= y or y < -0.5 or y > 1.5 then
        result.y = (fallback and fallback.y) or 0.5
    end
    if result.w ~= nil then
        local w = tonumber(result.w)
        if not w or w ~= w or w <= 0 or w > 1 then
            if fallback and fallback.w then
                result.w = fallback.w
            else
                result.w = nil
            end
        end
    end
    if result.h ~= nil then
        local h = tonumber(result.h)
        if not h or h ~= h or h <= 0 or h > 1 then
            if fallback and fallback.h then
                result.h = fallback.h
            else
                result.h = nil
            end
        end
    end
    return result
end

local function CopyElements(source)
    local result = {}
    for name, position in pairs(DEFAULT_ELEMENTS) do
        result[name] = SanitizePosition(source and source[name], position)
    end
    if type(source) == "table" then
        for name, position in pairs(source) do
            if result[name] == nil and type(position) == "table" and not RETIRED_ELEMENT_IDS[name] then
                result[name] = SanitizePosition(position, nil)
            end
        end
    end
    return result
end

local function PositionsEqual(a, b)
    if type(a) ~= "table" or type(b) ~= "table" then
        return false
    end
    local dx = math.abs((tonumber(a.x) or 0) - (tonumber(b.x) or 0))
    local dy = math.abs((tonumber(a.y) or 0) - (tonumber(b.y) or 0))
    if dx >= 0.0005 or dy >= 0.0005 then
        return false
    end
    local aw, bw = tonumber(a.w), tonumber(b.w)
    local ah, bh = tonumber(a.h), tonumber(b.h)
    if aw or bw then
        if math.abs((aw or 0) - (bw or 0)) >= 0.0005 then
            return false
        end
    end
    if ah or bh then
        if math.abs((ah or 0) - (bh or 0)) >= 0.0005 then
            return false
        end
    end
    return true
end

function Store:DefaultFor(name)
    local lib = LibValknarrUIE
    if lib and lib.DefaultFor then
        local registered = lib:DefaultFor(name)
        if registered then
            return SanitizePosition(registered, nil)
        end
    end
    local position = DEFAULT_ELEMENTS[name]
    if not position then
        return { x = 0.5, y = 0.5 }
    end
    return CopyOne(position, nil)
end

function Store:GetGrid()
    if self.saved and type(self.saved.grid) == "table" then
        local normalized = NormalizeGrid(self.saved.grid)
        self.saved.grid = normalized
        return normalized
    end
    return NormalizeGrid(GRID_DEFAULTS)
end

function Store:EnsureGrid()
    if not self.saved then
        return false
    end
    self.saved.grid = NormalizeGrid(self.saved.grid)
    return true
end

function Store:Initialize()
    if type(ZO_SavedVars) ~= "table" or type(ZO_SavedVars.NewAccountWide) ~= "function" then
        if Log then
            Log:Warn("ZO_SavedVars unavailable; layout will not persist")
        end
        return false
    end

    -- Keep SavedVars schema version 1 so 0.2.0 account data is not wiped.
    local ok, saved = pcall(
        ZO_SavedVars.NewAccountWide,
        ZO_SavedVars,
        SAVED_VARS_NAME,
        1,
        nil,
        defaults
    )
    self.saved = ok and saved or nil
    if self.saved and self.saved.version ~= 2 then
        self.saved.version = 2
    end
    self:EnsureGrid()
    self:EnsureSettings()
    self:DropRetiredElements()
    if Log then
        if self.saved then
            Log:Info("SavedVars ready (" .. SAVED_VARS_NAME .. ")")
            if self:HasUserLayout() then
                Log:Dump("Existing saved elements", self.saved.elements)
            else
                Log:Debug("No user layout yet — editor will start from live bars")
            end
        else
            Log:Warn("SavedVars init failed")
        end
    end
    return self.saved ~= nil
end

function Store:EnsureSettings()
    if not self.saved then
        return false
    end
    if type(self.saved.settings) ~= "table" then
        self.saved.settings = {}
    end
    -- 0.7.2: right-stick up/down felt inverted on console. Flip the default
    -- once for existing 0.7.x saves that still have schema 1 / unset.
    if (tonumber(self.saved.settings.schema) or 1) < 2 then
        self.saved.settings.invertStickY = true
        self.saved.settings.schema = 2
    end
    if self.saved.settings.invertStickY == nil then
        self.saved.settings.invertStickY = true
    end
    if self.saved.settings.invertStickX == nil then
        self.saved.settings.invertStickX = false
    end
    if self.saved.settings.showDebugLog == nil then
        self.saved.settings.showDebugLog = false
    end
    return true
end

function Store:GetSetting(key)
    self:EnsureSettings()
    if not self.saved or type(self.saved.settings) ~= "table" then
        return defaults.settings[key] and true or false
    end
    local value = self.saved.settings[key]
    if value == nil then
        return defaults.settings[key] and true or false
    end
    return value and true or false
end

function Store:SetSetting(key, value)
    if not self:EnsureSettings() then
        if Log then
            Log:Warn("SetSetting skipped: SavedVars not ready")
        end
        return false
    end
    self.saved.settings[key] = value and true or false
    if Log then
        Log:Info("Setting " .. tostring(key) .. " = " .. tostring(self.saved.settings[key]))
    end
    return true
end

function Store:ToggleSetting(key)
    local nextValue = not self:GetSetting(key)
    self:SetSetting(key, nextValue)
    return nextValue
end

function Store:DropRetiredElements()
    if not self.saved or type(self.saved.elements) ~= "table" then
        return false
    end
    local dropped = false
    for id in pairs(RETIRED_ELEMENT_IDS) do
        if self.saved.elements[id] ~= nil then
            self.saved.elements[id] = nil
            dropped = true
        end
    end
    return dropped
end

-- Ring buffer of chat debug lines. Addon Lua cannot write the engine Logs
-- folder; this is flushed to SavedVariables on /reloadui or logout.
function Store:AppendDebugLog(line)
    if not self.saved then
        return false
    end
    if type(line) ~= "string" or line == "" then
        return false
    end
    local log = self.saved.debugLog
    if type(log) ~= "table" then
        log = {}
        self.saved.debugLog = log
    end
    log[#log + 1] = line
    while #log > MAX_DEBUG_LOG_LINES do
        table.remove(log, 1)
    end
    return true
end

function Store:GetDebugLog()
    if not self.saved or type(self.saved.debugLog) ~= "table" then
        return {}
    end
    local copy = {}
    for index = 1, #self.saved.debugLog do
        copy[index] = self.saved.debugLog[index]
    end
    return copy
end

function Store:DescribeSettings()
    return {
        invertStickY = self:GetSetting("invertStickY"),
        invertStickX = self:GetSetting("invertStickX"),
        showDebugLog = self:GetSetting("showDebugLog"),
    }
end

function Store:HasUserLayout()
    if not self.saved then
        return false
    end
    if self.saved.userLayout == true then
        return type(self.saved.elements) == "table"
    end
    if self.saved.userLayout == false then
        return false
    end
    -- 0.2.0 / 0.3.0 wrote default elements into SavedVars on first load.
    -- Treat that as "never saved" unless a position differs from defaults.
    if type(self.saved.elements) ~= "table" then
        return false
    end
    for name, defaultPos in pairs(DEFAULT_ELEMENTS) do
        local saved = self.saved.elements[name]
        if saved and not PositionsEqual(saved, defaultPos) then
            return true
        end
    end
    return false
end

function Store:HasSavedLayout()
    return self:HasUserLayout()
end

function Store:Load()
    return CopyElements(self.saved and self.saved.elements)
end

function Store:Save(elements)
    if not self.saved then
        if Log then
            Log:Warn("Save skipped: SavedVars not initialized")
        end
        return false
    end
    self.saved.version = 2
    self.saved.grid = self:GetGrid()
    self.saved.userLayout = true
    self.saved.elements = CopyElements(elements)
    if type(GetTimeStamp) == "function" then
        local ok, stamp = pcall(GetTimeStamp)
        if ok then
            self.saved.savedAt = stamp
        end
    end
    if Log then
        Log:Info("Layout saved")
        Log:Dump("Saved elements", self.saved.elements)
    end
    return true
end

function Store:Reset()
    local result = CopyElements(DEFAULT_ELEMENTS)
    local lib = LibValknarrUIE
    if lib and type(lib.Ids) == "function" then
        local ids = lib:Ids()
        for index = 1, #ids do
            local id = ids[index]
            if result[id] == nil then
                result[id] = self:DefaultFor(id)
            end
        end
    end
    return result
end

function Store:Clear()
    if self.saved then
        self.saved.elements = nil
        self.saved.userLayout = false
        self.saved.savedAt = nil
        if Log then
            Log:Info("Cleared saved layout")
        end
        return true
    end
    return false
end

return Store
