BetterBuffs = BetterBuffs or {}
local BB = BetterBuffs

BB.name = "BetterBuffs"
BB.displayName = "Better Buffs"
BB.version = "0.3.05"
BB.savedVariableVersion = 2

local displayDefaults = {
    enabled = true,
    opacity = 0.42,
    scale = 1.0,
    offsetX = 0,
    offsetY = -80,
    style = "COMPACT",
    compactLayout = "GRID",
    crescentSide = "RIGHT",
    curveDepth = 54,
    verticalSpread = 66,
    iconsPerRow = 4,
    tileSize = 58,
    tileSpacing = 10,
    sortOrder = "PRIORITY",
}

local accountDefaults = {
    enabled = true,
    uptime = { enabled=true, minimumCombatSeconds=5, showAdvanced=true },
    advanced = { readyAnimation=true },
}

local characterDefaults = {
    tracked = {},
    ui = {
        buffs = {},
        debuffs = {},
        slayerMissAlert = {
            enabled = false,
            scale = 1.0,
            offsetX = 0,
            offsetY = -180,
            durationMs = 2500,
        },
    },
    _profileInitialized = false,
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

local function DeepCopy(source)
    if type(source) ~= "table" then return source end
    local copy = {}
    for key, value in pairs(source) do copy[key] = DeepCopy(value) end
    return copy
end

local function HasValues(value)
    return type(value) == "table" and next(value) ~= nil
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
    self.accountSaved.enabled = value == true
    self.saved.enabled = self.accountSaved.enabled
    if self.Runtime then self.Runtime:SetEnabled(self.saved.enabled) end
    if self.UI then self.UI:RefreshAll(true) end
end

function BB:Initialize()
    -- General behavior remains account-wide. Effect selections and the complete
    -- HUD layout are character-specific and keyed by ESO's stable character ID.
    self.accountSaved = ZO_SavedVars:NewAccountWide("BetterBuffsSavedVariables", self.savedVariableVersion, nil, accountDefaults)
    self.characterSaved = ZO_SavedVars:NewCharacterIdSettings("BetterBuffsSavedVariables", self.savedVariableVersion, nil, characterDefaults)
    DeepDefaults(self.accountSaved, accountDefaults)
    DeepDefaults(self.characterSaved, characterDefaults)

    -- One-time, per-character migration. Existing v0.2.x users keep their
    -- account-wide setup as the seed for each character the first time it logs in.
    if self.characterSaved._profileInitialized ~= true then
        if HasValues(self.accountSaved.tracked) then self.characterSaved.tracked = DeepCopy(self.accountSaved.tracked) end
        if HasValues(self.accountSaved.ui) then self.characterSaved.ui = DeepCopy(self.accountSaved.ui) end
        self.characterSaved._profileInitialized = true
    end

    self.characterSaved.tracked = type(self.characterSaved.tracked) == "table" and self.characterSaved.tracked or {}
    self.characterSaved.ui = type(self.characterSaved.ui) == "table" and self.characterSaved.ui or {}
    self.characterSaved.ui.buffs = type(self.characterSaved.ui.buffs) == "table" and self.characterSaved.ui.buffs or {}
    self.characterSaved.ui.debuffs = type(self.characterSaved.ui.debuffs) == "table" and self.characterSaved.ui.debuffs or {}
    self.characterSaved.ui.slayerMissAlert = type(self.characterSaved.ui.slayerMissAlert) == "table" and self.characterSaved.ui.slayerMissAlert or {}
    DeepDefaults(self.characterSaved.ui.buffs, displayDefaults)
    DeepDefaults(self.characterSaved.ui.debuffs, displayDefaults)
    DeepDefaults(self.characterSaved.ui.slayerMissAlert, characterDefaults.ui.slayerMissAlert)

    -- Compatibility facade for the existing runtime/settings code. Nested tables
    -- are direct references to their authoritative SavedVariables owners.
    self.saved = {
        enabled = self.accountSaved.enabled,
        uptime = self.accountSaved.uptime,
        advanced = self.accountSaved.advanced,
        tracked = self.characterSaved.tracked,
        ui = self.characterSaved.ui,
    }

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
