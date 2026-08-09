BetterBuffs = BetterBuffs or {}
local BB = BetterBuffs

BB.name = "BetterBuffs"
BB.displayName = "Better Buffs"
BB.version = "0.2.01"
BB.savedVariableVersion = 2

local displayDefaults = {
    enabled = true,
    opacity = 0.42,
    scale = 1.0,
    offsetX = 0,
    offsetY = -80,
    style = "DETAILED",
    compactLayout = "CRESCENT",
    crescentSide = "RIGHT",
    curveDepth = 54,
    verticalSpread = 66,
    iconsPerRow = 4,
    tileSize = 58,
    tileSpacing = 10,
    sortOrder = "PRIORITY",
}

local defaults = {
    enabled = true,
    tracked = {},
    uptime = { enabled=true, minimumCombatSeconds=5, showAdvanced=true },
    advanced = { readyAnimation=true },
    ui = {
        buffs = {},
        debuffs = {},
    },
}

local function DeepDefaults(target, source)
    for key, value in pairs(source) do
        if type(value) == "table" then
            target[key] = type(target[key]) == "table" and target[key] or {}
            DeepDefaults(target[key], value)
        elseif target[key] == nil then
            target[key] = value
        end
    end
end

function BB:FormatUnitName(value)
    return zo_strtrim(zo_strformat("<<1>>", tostring(value or "")))
end

function BB:NormalizeText(value)
    return zo_strlower(self:FormatUnitName(value))
end

function BB:NormalizeAccount(value)
    local text = zo_strtrim(tostring(value or ""))
    if text == "" then return "" end
    if string.sub(text, 1, 1) ~= "@" then text = "@" .. text end
    return zo_strlower(text)
end

function BB:GetGroupTargetCount()
    return math.max(1, tonumber(GetGroupSize()) or 0)
end

function BB:IsEffectEnabled(key)
    if not self.saved or not self.saved.enabled then return false end
    local value = self.saved.tracked[key]
    if value == nil then
        local effect = self.Registry and self.Registry.byKey[key]
        return effect and effect.defaultTracked == true or false
    end
    return value == true
end

function BB:SetEffectEnabled(key, value)
    self.saved.tracked[key] = value == true
    if self.Runtime then self.Runtime:OnTrackingChanged(key) end
    if self.UI then self.UI:RefreshAll(true) end
end

function BB:SetEnabled(value)
    self.saved.enabled = value == true
    if self.Runtime then self.Runtime:SetEnabled(self.saved.enabled) end
    if self.UI then self.UI:RefreshAll(true) end
end

function BB:Initialize()
    self.saved = ZO_SavedVars:NewAccountWide("BetterBuffsSavedVariables", self.savedVariableVersion, nil, defaults)
    DeepDefaults(self.saved, defaults)
    DeepDefaults(self.saved.ui.buffs, displayDefaults)
    DeepDefaults(self.saved.ui.debuffs, displayDefaults)
    if self.saved.ui.buffs.offsetX == 0 then self.saved.ui.buffs.offsetX = -330 end
    if self.saved.ui.debuffs.offsetX == 0 then self.saved.ui.debuffs.offsetX = 330 end
    if not self.saved.ui.buffs._crescentInitialized then self.saved.ui.buffs.crescentSide = "LEFT"; self.saved.ui.buffs._crescentInitialized = true end
    if not self.saved.ui.debuffs._crescentInitialized then self.saved.ui.debuffs.crescentSide = "RIGHT"; self.saved.ui.debuffs._crescentInitialized = true end

    self.Registry:Initialize()
    self.Context:Initialize()
    self.Analytics:Initialize()
    self.UI:Initialize()
    self.Runtime:Initialize()
    self.API:Initialize()
    self.Settings:Initialize()
    self:SetEnabled(self.saved.enabled)
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= BB.name then return end
    EVENT_MANAGER:UnregisterForEvent(BB.name, EVENT_ADD_ON_LOADED)
    BB:Initialize()
end

EVENT_MANAGER:RegisterForEvent(BB.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
