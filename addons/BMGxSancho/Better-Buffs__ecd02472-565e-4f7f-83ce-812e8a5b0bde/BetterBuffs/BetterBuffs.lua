BetterBuffs = BetterBuffs or {}
local BB = BetterBuffs

BB.name = "BetterBuffs"
BB.displayName = "Better Buffs"
BB.version = "0.3.14"
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
    enabled = true, -- legacy migration source; live master enable is character-specific
    uptime = { enabled=true, minimumCombatSeconds=5, showAdvanced=true },
    advanced = { readyAnimation=true },
    _characterProfileMigrationComplete = false,
}

local characterDefaults = {
    tracked = {},
    visibility = {},
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
        stats = {
            visibility = "SELF",
            scale = 1.0,
            opacity = 0.34,
            offsetX = 0,
            offsetY = 120,
        },
        damageStats = {
            enabled = false,
            scale = 1.0,
            opacity = 0.34,
            offsetX = 0,
            offsetY = 230,
        },
        resistanceStats = {
            enabled = false,
            scale = 1.0,
            opacity = 0.34,
            offsetX = 0,
            offsetY = 310,
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

local VISIBILITY_AUTO = "AUTO"
local VISIBILITY_ALWAYS = "ALWAYS"
local VISIBILITY_HIDDEN = "HIDDEN"

local function IsVisibilityMode(value)
    return value == VISIBILITY_AUTO or value == VISIBILITY_ALWAYS or value == VISIBILITY_HIDDEN
end

function BB:GetEffectVisibilityMode(key)
    if not self.saved then return VISIBILITY_AUTO end
    local mode = self.saved.visibility and self.saved.visibility[key]
    if IsVisibilityMode(mode) then return mode end

    -- Backward-compatible interpretation of the old checkbox. ON becomes ALWAYS
    -- and OFF becomes AUTO. Untouched defaults keep their previous visible state.
    local legacy = self.saved.tracked and self.saved.tracked[key]
    if legacy ~= nil then return legacy == true and VISIBILITY_ALWAYS or VISIBILITY_AUTO end
    local effect = self.Registry and self.Registry.byKey[key]
    return effect and effect.defaultTracked == true and VISIBILITY_ALWAYS or VISIBILITY_AUTO
end

function BB:SetEffectVisibilityMode(key, mode)
    if not IsVisibilityMode(mode) then return end
    self.saved.visibility[key] = mode

    -- Keep the legacy boolean synchronized for downgrade/compatibility safety.
    -- AUTO and HIDDEN both correspond to the old unchecked state.
    self.saved.tracked[key] = mode == VISIBILITY_ALWAYS

    if self.Runtime then self.Runtime:OnTrackingChanged(key) end
    if self.UI then self.UI:RefreshAll(true) end
end

-- Compatibility helpers for older call sites/API consumers. In the new model,
-- "enabled" means the user explicitly requested ALWAYS visibility.
function BB:IsEffectEnabled(key)
    return self.saved and self.saved.enabled and self:GetEffectVisibilityMode(key) == VISIBILITY_ALWAYS or false
end

function BB:SetEffectEnabled(key, value)
    self:SetEffectVisibilityMode(key, value == true and VISIBILITY_ALWAYS or VISIBILITY_AUTO)
end

-- Automatic relevance is registry-owned and event-driven. The runtime maintains a
-- lightweight capability snapshot from worn gear and slotted skills, while live
-- group-effect relevance comes from the existing canonical effect state. No
-- periodic gear/skill scanner or second effect cache is used.
function BB:IsEffectAutoTracked(key)
    if not self.saved or not self.saved.enabled then return false end
    local effect = self.Registry and self.Registry.byKey[key]
    if not effect or not self.Runtime then return false end
    return self.Runtime:HasLocalProviderCapability(effect)
end

function BB:IsEffectAutoRelevant(key)
    if not self.saved or not self.saved.enabled then return false end
    local effect = self.Registry and self.Registry.byKey[key]
    if not effect then return false end
    if self:IsEffectAutoTracked(key) then return true end
    return effect.autoGroupEffect == true and self.Runtime and self.Runtime:HasAutoGroupState(key) or false
end

-- Observation is broader than presentation. AUTO group-awareness effects must be
-- observed even before the first application so the application itself can make
-- the tile relevant. HIDDEN remains an absolute HUD override but may still be
-- observed internally for analytics/intelligence.
function BB:ShouldObserveEffect(key)
    if not self.saved or not self.saved.enabled then return false end
    local mode = self:GetEffectVisibilityMode(key)
    if mode == VISIBILITY_ALWAYS then return true end
    local effect = self.Registry and self.Registry.byKey[key]
    if not effect then return false end
    if effect.autoGroupEffect == true then return true end
    return self:IsEffectAutoTracked(key)
end

-- Presentation preference and runtime observation are deliberately separate.
-- HIDDEN is absolute for the HUD, while the runtime may still observe an
-- automatically relevant provider so analytics/intelligence can remain correct.
function BB:IsEffectVisible(key)
    if not self.saved or not self.saved.enabled then return false end
    local mode = self:GetEffectVisibilityMode(key)
    if mode == VISIBILITY_HIDDEN then return false end
    if mode == VISIBILITY_ALWAYS then return true end
    return self:IsEffectAutoRelevant(key)
end

function BB:IsEffectTracked(key)
    if not self.saved or not self.saved.enabled then return false end
    local mode = self:GetEffectVisibilityMode(key)
    if mode == VISIBILITY_ALWAYS then return true end
    return self:IsEffectAutoRelevant(key)
end

-- Compatibility alias: "relevant" remains presentation relevance for UI and
-- analytics call sites that historically consumed this function.
function BB:IsEffectRelevant(key)
    return self:IsEffectVisible(key)
end

function BB:SetEnabled(value)
    -- The user-facing master enable state is character-specific. This preserves
    -- independent character HUD profiles while allowing every genuinely new
    -- character to start enabled. accountSaved.enabled remains legacy migration
    -- data only and is no longer the live visibility owner.
    self.characterSaved.enabled = value == true
    self.saved.enabled = self.characterSaved.enabled
    if self.Runtime then self.Runtime:SetEnabled(self.saved.enabled) end
    if self.UI then self.UI:RefreshAll(true) end
    if self.Stats then self.Stats:RefreshAll() end
end

function BB:Initialize()
    -- General behavior remains account-wide. Effect selections and the complete
    -- HUD layout are character-specific and keyed by ESO's stable character ID.
    self.accountSaved = ZO_SavedVars:NewAccountWide("BetterBuffsSavedVariables", self.savedVariableVersion, nil, accountDefaults)
    self.characterSaved = ZO_SavedVars:NewCharacterIdSettings("BetterBuffsSavedVariables", self.savedVariableVersion, nil, characterDefaults)
    DeepDefaults(self.accountSaved, accountDefaults)
    DeepDefaults(self.characterSaved, characterDefaults)

    -- One-time, per-character migration. Existing characters keep their previous
    -- account-wide enable state and legacy v0.2.x setup. A genuinely new character
    -- starts enabled and receives the curated first-use visibility defaults below.
    local profileWasInitialized = self.characterSaved._profileInitialized == true
    local legacyProfileSeedAvailable = self.accountSaved._characterProfileMigrationComplete ~= true
    local seededLegacyProfile = false
    if not profileWasInitialized then
        -- Only the first character encountered during a direct upgrade from the old
        -- account-wide profile model inherits that legacy layout. Once character
        -- profiles have been established, genuinely new characters use clean
        -- first-use defaults instead of cloning stale account-wide selections.
        if legacyProfileSeedAvailable and HasValues(self.accountSaved.tracked) then
            self.characterSaved.tracked = DeepCopy(self.accountSaved.tracked)
            seededLegacyProfile = true
        end
        if legacyProfileSeedAvailable and HasValues(self.accountSaved.ui) then
            self.characterSaved.ui = DeepCopy(self.accountSaved.ui)
            seededLegacyProfile = true
        end
        self.characterSaved.enabled = true
        self.characterSaved._profileInitialized = true
    elseif self.characterSaved.enabled == nil then
        -- v0.3.07 and earlier stored the master switch account-wide. Preserve the
        -- established state once for already-initialized character profiles.
        self.characterSaved.enabled = self.accountSaved.enabled ~= false
    end
    self.accountSaved._characterProfileMigrationComplete = true

    self.characterSaved.tracked = type(self.characterSaved.tracked) == "table" and self.characterSaved.tracked or {}
    self.characterSaved.visibility = type(self.characterSaved.visibility) == "table" and self.characterSaved.visibility or {}
    -- Migrate explicit legacy checkbox choices once without altering their behavior:
    -- ON -> ALWAYS, OFF -> AUTO. Nil/default choices are resolved lazily so newly
    -- added registry effects inherit the correct default semantics.
    for key, value in pairs(self.characterSaved.tracked) do
        if self.characterSaved.visibility[key] == nil then
            self.characterSaved.visibility[key] = value == true and VISIBILITY_ALWAYS or VISIBILITY_AUTO
        end
    end
    if not profileWasInitialized and not seededLegacyProfile then
        local firstUseAlways = {
            MAJOR_BERSERK=true,
            MAJOR_FORCE=true,
            MAJOR_SLAYER=true,
            POWERFUL_ASSAULT=true,
            OFF_BALANCE=true,
            ALKOSH_RESISTANCE_REDUCTION=true,
            ZEN_DAMAGE_TAKEN=true,
        }
        for key in pairs(firstUseAlways) do
            self.characterSaved.visibility[key] = VISIBILITY_ALWAYS
            self.characterSaved.tracked[key] = true
        end
    end
    self.characterSaved.ui = type(self.characterSaved.ui) == "table" and self.characterSaved.ui or {}
    self.characterSaved.ui.buffs = type(self.characterSaved.ui.buffs) == "table" and self.characterSaved.ui.buffs or {}
    self.characterSaved.ui.debuffs = type(self.characterSaved.ui.debuffs) == "table" and self.characterSaved.ui.debuffs or {}
    self.characterSaved.ui.slayerMissAlert = type(self.characterSaved.ui.slayerMissAlert) == "table" and self.characterSaved.ui.slayerMissAlert or {}
    self.characterSaved.ui.stats = type(self.characterSaved.ui.stats) == "table" and self.characterSaved.ui.stats or {}
    self.characterSaved.ui.damageStats = type(self.characterSaved.ui.damageStats) == "table" and self.characterSaved.ui.damageStats or {}
    self.characterSaved.ui.resistanceStats = type(self.characterSaved.ui.resistanceStats) == "table" and self.characterSaved.ui.resistanceStats or {}
    DeepDefaults(self.characterSaved.ui.buffs, displayDefaults)
    DeepDefaults(self.characterSaved.ui.debuffs, displayDefaults)
    DeepDefaults(self.characterSaved.ui.slayerMissAlert, characterDefaults.ui.slayerMissAlert)
    DeepDefaults(self.characterSaved.ui.stats, characterDefaults.ui.stats)
    DeepDefaults(self.characterSaved.ui.damageStats, characterDefaults.ui.damageStats)
    DeepDefaults(self.characterSaved.ui.resistanceStats, characterDefaults.ui.resistanceStats)

    -- Compatibility facade for the existing runtime/settings code. Nested tables
    -- are direct references to their authoritative SavedVariables owners.
    self.saved = {
        enabled = self.characterSaved.enabled ~= false,
        uptime = self.accountSaved.uptime,
        advanced = self.accountSaved.advanced,
        tracked = self.characterSaved.tracked,
        visibility = self.characterSaved.visibility,
        ui = self.characterSaved.ui,
    }

    if self.saved.ui.buffs.offsetX == 0 then self.saved.ui.buffs.offsetX = -330 end
    if self.saved.ui.debuffs.offsetX == 0 then self.saved.ui.debuffs.offsetX = 330 end
    if not self.saved.ui.buffs._crescentInitialized then self.saved.ui.buffs.crescentSide = "LEFT"; self.saved.ui.buffs._crescentInitialized = true end
    if not self.saved.ui.debuffs._crescentInitialized then self.saved.ui.debuffs.crescentSide = "RIGHT"; self.saved.ui.debuffs._crescentInitialized = true end

    self.Registry:Initialize()
    self.Context:Initialize()
    self.Analytics:Initialize()
    -- Runtime owns canonical effect and Auto-relevance state. Initialize it before
    -- the UI, because dashboard construction may query Auto group relevance.
    self.Runtime:Initialize()
    self.UI:Initialize()
    self.Stats:Initialize()
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
