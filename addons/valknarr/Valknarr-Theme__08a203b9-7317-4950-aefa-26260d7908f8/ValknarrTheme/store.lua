ValknarrThemeStore = ValknarrThemeStore or {}

local Store = ValknarrThemeStore
local Format = ValknarrThemeFormat
local Log = ValknarrThemeLog
local SAVED_VARS_NAME = "ValknarrTheme_SavedVariables"
local MAX_DEBUG_LOG_LINES = 160

local defaults = {
    version = 2,
    themeId = "clean",
    wolfId = "clean",
    showDebugLog = false,
}

function Store:Initialize()
    if self.saved then
        return self.saved
    end
    if type(ZO_SavedVars) ~= "table" or type(ZO_SavedVars.NewAccountWide) ~= "function" then
        if Log then
            Log:Warn("ZO_SavedVars unavailable; theme will not persist")
        end
        self.saved = {
            version = defaults.version,
            themeId = defaults.themeId,
            wolfId = defaults.wolfId,
            showDebugLog = false,
            debugLog = {},
        }
        self:Migrate()
        return self.saved
    end
    local ok, saved = pcall(
        ZO_SavedVars.NewAccountWide,
        ZO_SavedVars,
        SAVED_VARS_NAME,
        1,
        nil,
        defaults
    )
    if ok and type(saved) == "table" then
        self.saved = saved
    else
        if Log then
            Log:Warn("SavedVars init failed")
        end
        self.saved = {
            version = defaults.version,
            themeId = defaults.themeId,
            wolfId = defaults.wolfId,
            showDebugLog = false,
            debugLog = {},
        }
    end
    self:Migrate()
    return self.saved
end

function Store:Migrate()
    local saved = self.saved
    if type(saved) ~= "table" then
        return
    end
    local previous = saved.themeId
    saved.themeId = Format.NormalizeThemeId(saved.themeId)
    if saved.wolfId == nil or saved.wolfId == "" then
        if previous == "default" then
            saved.wolfId = Format.WOLF_VANILLA
        else
            saved.wolfId = Format.WOLF_CLEAN
        end
    end
    saved.wolfId = Format.NormalizeWolfId(saved.wolfId)
    saved.version = 2
    if saved.showDebugLog == nil then
        saved.showDebugLog = false
    end
end

function Store:ThemeId()
    local saved = self.saved
    if not saved then
        return defaults.themeId
    end
    return Format.NormalizeThemeId(saved.themeId)
end

function Store:IsValknarr()
    return Format.ResourcesThemed(self:ThemeId())
end

function Store:WolfId()
    local saved = self.saved
    if not saved then
        return defaults.wolfId
    end
    return Format.NormalizeWolfId(saved.wolfId)
end

function Store:SetThemeId(themeId)
    self:Initialize()
    local nextId = Format.NormalizeThemeId(themeId)
    self.saved.themeId = nextId
    if Log then
        Log:Always("hud skin = " .. nextId)
    end
    return nextId
end

function Store:SetWolfId(wolfId)
    self:Initialize()
    local nextId = Format.NormalizeWolfId(wolfId)
    self.saved.wolfId = nextId
    if Log then
        Log:Always("wolf skin = " .. nextId)
    end
    return nextId
end

function Store:Toggle()
    if Format.ResourcesThemed(self:ThemeId()) then
        return self:SetThemeId(Format.THEME_DEFAULT)
    end
    return self:SetThemeId(Format.THEME_CLEAN)
end

function Store:GetSetting(key)
    self:Initialize()
    if key == "showDebugLog" then
        return self.saved.showDebugLog and true or false
    end
    return nil
end

function Store:SetSetting(key, value)
    self:Initialize()
    if key == "showDebugLog" then
        self.saved.showDebugLog = value and true or false
        return self.saved.showDebugLog
    end
    return nil
end

function Store:AppendDebugLog(line)
    self:Initialize()
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

return Store
