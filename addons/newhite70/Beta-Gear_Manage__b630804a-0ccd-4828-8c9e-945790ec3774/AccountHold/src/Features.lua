-- AccountHold/src/Features.lua
-- Per-feature access gates (Epic 0001). Small, type-safe-by-Lua-guards API that
-- composes the maintainer data in config/FeatureAccess.lua with the code
-- registry below and the user's SavedVariables toggles.
--
-- Layering (each layer can only make access MORE restrictive):
--   1. addon gate          — whole-add-on allowlist (legacy: empty = open).
--   2. registry.available  — is the feature's module implemented / wired?
--   3. per-feature gate     — config mode/allowlist (empty = deny; safe rollout).
--   4. user setting         — a user may turn an allowed feature OFF, never ON.
--
-- Nothing here is a security boundary: the allowlists ship as readable source
-- (see config/FeatureAccess.lua). These gates control ROLLOUT, not entitlement.

AccountHold = AccountHold or {}
AccountHold.Features = AccountHold.Features or {}

local Features = AccountHold.Features

-- The add-on namespace is a global; every method resolves it lazily so the
-- gate logic works during AccountHold:Initialize BEFORE any per-module
-- :Initialize has run (avoids an impossible init-ordering dependency).
local function addon()
    return AccountHold
end

-- ---------------------------------------------------------------------------
-- Feature registry (code-owned). A feature is only ever enabled / shown when
-- `available == true`, which a future implementation flips ON in code once its
-- runtime module ships. `default` is the fallback mode used when the maintainer
-- config has no (or a malformed) entry for the feature.
--
-- `ORDER` fixes a deterministic presentation order for UserFacingList and the
-- settings panel (never rely on `pairs()` ordering).
-- ---------------------------------------------------------------------------
Features.REGISTRY = {
    -- Epic 0002 — Armory build creator. Model (src/BuildCreator.lua) AND the
    -- gamepad dialog UI (ui/ArmoryScreen_Gamepad.lua) both ship, so this is
    -- genuinely operable and rolls out per-account via the allowlist in
    -- config/FeatureAccess.lua.
    buildCreator      = { available = true,  default = "off" },
    -- Epic 0005 — Priorities tracker. Model + gamepad UI both ship, so this is
    -- genuinely usable and can be rolled out per-account via the allowlist in
    -- config/FeatureAccess.lua.
    priorities        = { available = true,  default = "off" },
    -- Epic 0003 — Guild store indexer.
    guildStoreIndexer = { available = false, default = "off" },
    -- Epic 0004 — Tip menu (deferred behind a ToS/API spike).
    tipMenu           = { available = false, default = "off" },
    -- Quality-of-life conveniences layered onto base-game screens. Small,
    -- independent actions with no model of their own, gated together so a
    -- player can turn the whole class off without losing a real feature.
    qol               = { available = true,  default = "off" },
}

Features.ORDER = { "buildCreator", "priorities", "guildStoreIndexer", "tipMenu", "qol" }

-- SI_* localization ids for the user-facing feature labels. Looked up lazily so
-- a missing string degrades to the raw key instead of erroring.
local LABEL_STRING_ID = {
    buildCreator      = "SI_ACCOUNTHOLD_FEATURE_BUILDCREATOR",
    priorities        = "SI_ACCOUNTHOLD_FEATURE_PRIORITIES",
    guildStoreIndexer = "SI_ACCOUNTHOLD_FEATURE_GUILDSTOREINDEXER",
    tipMenu           = "SI_ACCOUNTHOLD_FEATURE_TIPMENU",
    qol               = "SI_ACCOUNTHOLD_FEATURE_QOL",
}

local VALID_MODES = { on = true, off = true, allowlist = true }

-- ---------------------------------------------------------------------------
-- Normalization
-- ---------------------------------------------------------------------------

-- normalizeAccount — canonical key for an @handle / gamertag.
--   * non-strings -> nil
--   * trims surrounding whitespace (NOT internal spaces)
--   * strips one optional leading "@"
--   * lower-cases (case-insensitive matching)
--   * empty result -> nil
-- Examples: "@Gamer Tag" -> "gamer tag"; "  @Noobuddy " -> "noobuddy";
--           "@" -> nil; "a  b" -> "a  b" (internal double space preserved).
local function normalizeAccount(name)
    if type(name) ~= "string" then return nil end
    name = name:gsub("^%s+", ""):gsub("%s+$", "")   -- trim ends only
    name = name:gsub("^@", "")                        -- optional single leading @
    name = name:lower()
    if name == "" then return nil end
    return name
end

function Features:NormalizeAccount(name)
    return normalizeAccount(name)
end

local function normalizeMode(mode)
    if type(mode) ~= "string" then return nil end
    local m = mode:lower()
    if VALID_MODES[m] then return m end
    return nil
end

-- Build a normalized allow-set from a raw list; returns (set, count). A
-- non-table (malformed) list yields an empty set.
local function buildAllowSet(list)
    local set, n = {}, 0
    if type(list) == "table" then
        for _, v in ipairs(list) do
            local norm = normalizeAccount(v)
            if norm and not set[norm] then
                set[norm] = true
                n = n + 1
            end
        end
    end
    return set, n
end

-- allowlistGrants — allowlist evaluation shared by both gate kinds.
--   emptyOpen = true  -> empty list means OPEN   (whole-add-on legacy gate)
--   emptyOpen = false -> empty list means DENY    (per-feature safe rollout)
-- A non-empty list with an unresolved identity FAILS CLOSED.
local function allowlistGrants(allowList, identity, emptyOpen)
    local set, count = buildAllowSet(allowList)
    if count == 0 then
        return emptyOpen and true or false
    end
    if not identity then
        return false
    end
    return set[identity] == true
end

-- ---------------------------------------------------------------------------
-- Diagnostics (concise, de-duplicated, never throwing)
-- ---------------------------------------------------------------------------

-- _Warn routes to AccountHold:Diagnostic("warn", ...) but suppresses duplicate
-- messages so a repeatedly-evaluated bad config can't spam the ring buffer.
function Features:_Warn(fmt, ...)
    local msg = (select("#", ...) > 0) and string.format(fmt, ...) or tostring(fmt)
    self._warned = self._warned or {}
    if self._warned[msg] then return end
    self._warned[msg] = true
    local a = addon()
    if a and a.Diagnostic then
        a:Diagnostic("warn", "Features: %s", msg)
    end
end

-- ---------------------------------------------------------------------------
-- Identity
-- ---------------------------------------------------------------------------

-- CurrentIdentity — normalized local account handle, or nil when unresolved
-- (e.g. test harness with no ESO globals, or GetDisplayName returns "").
function Features:CurrentIdentity()
    local a = addon()
    local raw = nil
    if a and a.CurrentAccountName then
        raw = a:CurrentAccountName()
    end
    return normalizeAccount(raw)
end

-- ---------------------------------------------------------------------------
-- Config accessors
-- ---------------------------------------------------------------------------

local function rootConfig()
    local a = addon()
    local cfg = a and a.FeatureAccessConfig
    if type(cfg) == "table" then return cfg end
    return nil
end

-- _FeatureConfig(key) -> (entry, malformed)
--   entry     : the config table for the feature, or nil if absent
--   malformed : true when an entry exists but is not a table
function Features:_FeatureConfig(key)
    local cfg = rootConfig()
    if not cfg then return nil, false end
    local feats = cfg.features
    if type(feats) ~= "table" then return nil, false end
    local entry = feats[key]
    if entry == nil then return nil, false end
    if type(entry) ~= "table" then return nil, true end
    return entry, false
end

-- ---------------------------------------------------------------------------
-- Whole-add-on gate (outer gate; used by AccountHold:IsAuthorized)
-- Legacy semantics preserved: absent / malformed / empty-allowlist => OPEN.
-- ---------------------------------------------------------------------------
function Features:IsAddonEnabled()
    local a = addon()
    local cfg = a and a.FeatureAccessConfig
    if cfg == nil then
        return true                              -- absent config -> open
    end
    if type(cfg) ~= "table" then
        self:_Warn("FeatureAccessConfig is malformed; add-on gate open.")
        return true
    end
    local gate = cfg.addon
    if gate == nil then
        return true                              -- no add-on gate -> open
    end
    if type(gate) ~= "table" then
        self:_Warn("addon gate config is malformed; failing open.")
        return true
    end
    local mode = normalizeMode(gate.mode)
    if mode == nil then
        self:_Warn("addon gate: invalid mode %q; failing open.", tostring(gate.mode))
        return true
    end
    if mode == "on"  then return true  end
    if mode == "off" then return false end       -- explicit global kill-switch
    -- allowlist: empty list stays OPEN (author never locked out).
    return allowlistGrants(gate.allow, self:CurrentIdentity(), true)
end

-- ---------------------------------------------------------------------------
-- Per-feature allow gate (config layer only; ignores availability + user)
-- ---------------------------------------------------------------------------

-- Apply the registry default mode for a feature that has no usable config.
local function registryAllows(reg, identity)
    local mode = normalizeMode(reg and reg.default) or "off"
    if mode == "on"  then return true  end
    if mode == "off" then return false end
    return allowlistGrants(reg.allow, identity, false)
end

-- IsAllowed(key[, account]) — does the ROLLOUT config permit `account` (default
-- current identity) to use the feature? This is the PURE per-feature result: it
-- does NOT consider the whole-add-on gate, availability, or the user's own
-- toggle (those are composed by IsEnabled). Unknown keys deny + warn.
function Features:IsAllowed(key, account)
    local reg = self.REGISTRY[key]
    if not reg then
        self:_Warn("unknown feature key %q denied.", tostring(key))
        return false
    end

    local identity
    if account == nil then
        identity = self:CurrentIdentity()
    else
        identity = normalizeAccount(account)
    end

    local entry, malformed = self:_FeatureConfig(key)
    if malformed then
        self:_Warn("feature %q config is malformed; using registry default.", tostring(key))
        return registryAllows(reg, identity)
    end
    if entry == nil then
        return registryAllows(reg, identity)     -- absent -> registry default (off)
    end

    local mode = normalizeMode(entry.mode)
    if mode == nil then
        self:_Warn("feature %q: invalid mode %q; using registry default.",
            tostring(key), tostring(entry.mode))
        return registryAllows(reg, identity)
    end
    if mode == "on"  then return true  end
    if mode == "off" then return false end
    -- Per-feature allowlist: empty list DENIES everyone (safe rollout).
    return allowlistGrants(entry.allow, identity, false)
end

-- ---------------------------------------------------------------------------
-- User setting layer (SavedVariables; may only NARROW access)
-- ---------------------------------------------------------------------------

-- GetUserEnabled(key) — the user's effective preference. Defaults to true
-- (enabled) when unset, so an allowed+implemented feature is on by default; a
-- stored `false` narrows it off. The value never bypasses a gate (see
-- IsEnabled).
function Features:GetUserEnabled(key)
    local a = addon()
    local sv = a and a.sv
    local feats = sv and sv.settings and sv.settings.features
    local v = feats and feats[key]
    if v == nil then return true end
    return v and true or false
end

-- SetUserEnabled(key, value) — persist a user narrowing. Unknown keys warn and
-- do nothing. Returns true when the value was written.
function Features:SetUserEnabled(key, value)
    if not self.REGISTRY[key] then
        self:_Warn("unknown feature key %q cannot be toggled.", tostring(key))
        return false
    end
    local a = addon()
    local sv = a and a.sv
    if not (sv and sv.settings) then return false end
    sv.settings.features = sv.settings.features or {}
    sv.settings.features[key] = value and true or false
    return true
end

-- ---------------------------------------------------------------------------
-- Runtime gate — the one runtime feature modules call.
-- Enabled == whole-add-on gate open AND implemented(available) AND
-- allowed-by-config AND user-not-disabled. Evaluated outermost-first so the
-- layered gate is genuine defense-in-depth: a feature can never be enabled
-- while the add-on itself is gated off, even for a future load-time callback
-- that only checks IsEnabled. Unknown keys deny + warn; unavailable
-- (unimplemented) features are never enabled, regardless of config.
-- ---------------------------------------------------------------------------
function Features:IsEnabled(key)
    local reg = self.REGISTRY[key]
    if not reg then
        self:_Warn("unknown feature key %q is not enabled.", tostring(key))
        return false
    end
    -- Outer gate first: the whole-add-on allowlist. If the add-on is gated off
    -- for this account, no per-feature gate can turn a feature on.
    if not self:IsAddonEnabled() then
        return false
    end
    if not reg.available then
        return false
    end
    if not self:IsAllowed(key) then
        return false
    end
    return self:GetUserEnabled(key)
end

-- ---------------------------------------------------------------------------
-- Settings-panel data
-- ---------------------------------------------------------------------------

local function featureLabel(key)
    local sid = LABEL_STRING_ID[key]
    if sid and GetString then
        local idValue = rawget(_G, sid)
        if idValue ~= nil then
            local text = GetString(idValue)
            if type(text) == "string" and text ~= "" then
                return text
            end
        end
    end
    return key
end

-- UserFacingList — deterministic (REGISTRY ORDER) list of features to surface
-- in the settings panel: only those that are IMPLEMENTED (available) AND that
-- the current account is allowed to use. Each entry:
--   { key = <string>, label = <string>, enabled = <bool user preference> }
function Features:UserFacingList()
    local out = {}
    for _, key in ipairs(self.ORDER) do
        local reg = self.REGISTRY[key]
        if reg and reg.available and self:IsAllowed(key) then
            out[#out + 1] = {
                key     = key,
                label   = featureLabel(key),
                enabled = self:GetUserEnabled(key),
            }
        end
    end
    return out
end

-- ---------------------------------------------------------------------------
-- Validate — sanity-check the maintainer config and emit concise diagnostics.
-- Non-throwing; does NOT require SavedVariables. Returns a summary table:
--   { ok = <bool>, issues = { <string>, ... }, addonConfigPresent = <bool> }
-- ---------------------------------------------------------------------------
function Features:Validate()
    local issues = {}
    local function note(fmt, ...)
        issues[#issues + 1] = (select("#", ...) > 0) and string.format(fmt, ...) or fmt
    end

    local a = addon()
    local cfg = a and a.FeatureAccessConfig
    if cfg == nil then
        return { ok = true, issues = issues, addonConfigPresent = false }
    end
    if type(cfg) ~= "table" then
        note("FeatureAccessConfig is not a table; ignoring (add-on open).")
        for _, m in ipairs(issues) do self:_Warn("%s", m) end
        return { ok = false, issues = issues, addonConfigPresent = false }
    end

    local gate = cfg.addon
    if gate ~= nil then
        if type(gate) ~= "table" then
            note("addon config is not a table; add-on gate fails open.")
        else
            if gate.mode ~= nil and normalizeMode(gate.mode) == nil then
                note("addon.mode %q is invalid; add-on gate fails open.", tostring(gate.mode))
            end
            if gate.allow ~= nil and type(gate.allow) ~= "table" then
                note("addon.allow is not a list; treated as empty (open).")
            end
        end
    end

    local feats = cfg.features
    if feats ~= nil and type(feats) ~= "table" then
        note("features config is not a table; all features use registry defaults.")
    elseif type(feats) == "table" then
        for key, entry in pairs(feats) do
            if not self.REGISTRY[key] then
                note("features.%s is not a known feature; ignored.", tostring(key))
            elseif type(entry) ~= "table" then
                note("features.%s is not a table; using registry default.", tostring(key))
            else
                if entry.mode ~= nil and normalizeMode(entry.mode) == nil then
                    note("features.%s.mode %q is invalid; using registry default.",
                        tostring(key), tostring(entry.mode))
                end
                if entry.allow ~= nil and type(entry.allow) ~= "table" then
                    note("features.%s.allow is not a list; treated as empty (deny).", tostring(key))
                end
            end
        end
    end

    for _, m in ipairs(issues) do self:_Warn("%s", m) end
    return { ok = (#issues == 0), issues = issues, addonConfigPresent = (gate ~= nil) }
end
