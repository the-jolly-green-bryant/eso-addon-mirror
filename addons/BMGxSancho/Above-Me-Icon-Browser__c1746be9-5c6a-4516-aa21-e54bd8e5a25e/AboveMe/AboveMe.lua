AboveMe = AboveMe or {}
local AM = AboveMe

AM.name = "AboveMe"
AM.version = "0.0.02"

local CURRENT_SETTINGS_VERSION = 10
local defaults = {
    settingsVersion = CURRENT_SETTINGS_VERSION,
    enabled = true,
    iconId = 101,
    selectedCategory = "classic",
    showOwnIcon = true,
    showGroupIcons = true,
    combatOnly = false,
    size = 48,
    opacity = 1,
    maxDistance = 55,
    distanceScaling = false,
    fadeWithDistance = false,
    updateRate = 33,
    favorites = {},
    recentIcons = {},
    randomFavoriteOnLogin = false,
}

local characterDefaults = {
    placementOffset = 0,
    placementRevision = 1,
}

local LEGACY_ICON_MAP = {
    [1] = 1,
    [101] = 101,
    [102] = 102,
    [103] = 103,
    [104] = 104,
    [105] = 105,
    [106] = 106,
    [107] = 107,
    [108] = 108,
}

local function MigrateIconId(id)
    id = tonumber(id) or 1
    if AM.ICONS_BY_ID[id] then return id end
    return LEGACY_ICON_MAP[id] or 101
end

function AM:MigrateSavedVariables()
    self.saved.iconId = MigrateIconId(self.saved.iconId)
    self.saved.favorites = self.saved.favorites or {}
    self.saved.recentIcons = self.saved.recentIcons or {}
    self.saved.selectedPlayer = nil
    self.saved.playerIcons = nil
    self.saved.playerOverrides = nil
    self.saved.selectedOverrideMode = nil
    self.saved.height = nil
    self.saved.distanceScaling = false

    if not self.saved.selectedCategory or not self.PACKS_BY_ID[self.saved.selectedCategory] then
        self.saved.selectedCategory = self:GetIcon(self.saved.iconId).pack or "classic"
    end

    self.saved.settingsVersion = CURRENT_SETTINGS_VERSION

    self.characterSaved.placementOffset = zo_clamp(tonumber(self.characterSaved.placementOffset) or 0, -0.75, 0.50)
    self.characterSaved.placementRevision = tonumber(self.characterSaved.placementRevision) or 1
end

function AM:GetPlacementOffset()
    return self.characterSaved and (tonumber(self.characterSaved.placementOffset) or 0) or 0
end

function AM:SetPlacementOffset(value)
    if not self.characterSaved then return end

    local clamped = zo_clamp(tonumber(value) or 0, -0.75, 0.50)
    local rounded = math.floor((clamped / 0.05) + 0.5) * 0.05
    if math.abs(rounded - (self.characterSaved.placementOffset or 0)) < 0.001 then return end

    self.characterSaved.placementOffset = rounded
    self.characterSaved.placementRevision = ((tonumber(self.characterSaved.placementRevision) or 0) + 1) % 256

    if self.BroadcastSelection then
        self:BroadcastSelection(true)
    end
end

function AM:Initialize()
    self.saved = ZO_SavedVars:NewAccountWide("AboveMeSavedVariables", 1, nil, defaults)
    self.characterSaved = ZO_SavedVars:NewCharacterIdSettings("AboveMeCharacterSavedVariables", 1, nil, characterDefaults)
    self:MigrateSavedVariables()

    if self.saved.randomFavoriteOnLogin then
        self:ChooseRandomFavorite()
    end

    -- Register the settings panel first so an optional networking or renderer
    -- failure can never remove Above Me from the ESO settings menu.
    self:CreateSettings()

    -- Initialize optional runtime systems independently. A failure in one
    -- subsystem must not prevent the remaining addon UI from loading.
    local function SafeInitialize(label, callback)
        local ok, err = pcall(callback)
        if not ok and d then
            d(string.format("Above Me: %s failed: %s", label, tostring(err)))
        end
        return ok
    end

    SafeInitialize("network initialization", function() self:InitializeNetwork() end)
    SafeInitialize("renderer creation", function() self:CreateRenderer() end)
    SafeInitialize("icon browser creation", function() self:CreateIconBrowser() end)
    SafeInitialize("renderer startup", function() self:StartRenderer() end)
end

local function OnAddonLoaded(eventCode, addonName)
    if addonName ~= AM.name then return end
    EVENT_MANAGER:UnregisterForEvent(AM.name, EVENT_ADD_ON_LOADED)
    AM:Initialize()
end

EVENT_MANAGER:RegisterForEvent(AM.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
