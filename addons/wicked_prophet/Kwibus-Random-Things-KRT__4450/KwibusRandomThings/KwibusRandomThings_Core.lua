local ADDON_NAME = "KwibusRandomThings"
local ADDON_VERSION = "1.2.6"

local EM = EVENT_MANAGER

-- Global umbrella table (modules attach to this)
KwibusRandomThings = KwibusRandomThings or {
    name = ADDON_NAME,
    version = ADDON_VERSION,
    sv = nil,
    modules = {},
}
local KRT = KwibusRandomThings

-- Helpers (shared)
function KRT.Clamp01(x) return zo_clamp(tonumber(x) or 0, 0, 1) end

function KRT.RGBToHex(r, g, b)
    r = KRT.Clamp01(r); g = KRT.Clamp01(g); b = KRT.Clamp01(b)
    local R = zo_floor(r * 255 + 0.5)
    local G = zo_floor(g * 255 + 0.5)
    local B = zo_floor(b * 255 + 0.5)
    return string.format("|c%02X%02X%02X", R, G, B)
end

function KRT.IsNonEmptyString(s) return type(s) == "string" and s ~= "" end
function KRT.EnsureTable(v) return (type(v) == "table") and v or {} end

function KRT.DeepMergeDefaults(target, source)
    for k, v in pairs(source) do
        if type(v) == "table" then
            if type(target[k]) == "table" then
                KRT.DeepMergeDefaults(target[k], v)
            elseif target[k] == nil then
                target[k] = ZO_DeepTableCopy(v)
            end
        else
            if target[k] == nil then target[k] = v end
        end
    end
end

-- PERFORMANCE FIX: Static executor prevents inline closure allocations
local _debounce = {}
local function ExecuteDebounce(key)
    local fn = _debounce[key]
    _debounce[key] = nil
    if type(fn) == "function" then
        fn()
    end
end

function KRT.DebounceNextFrame(key, fn)
    if _debounce[key] ~= nil then return end
    _debounce[key] = fn
    zo_callLater(function() ExecuteDebounce(key) end, 0)
end

-- Module registry
function KRT:RegisterModule(moduleTable)
    if type(moduleTable) ~= "table" then return end
    if not moduleTable.id then return end
    table.insert(self.modules, moduleTable)
end

local function BuildUnifiedSettings()
    local LAM = LibAddonMenu2

    local panelData = {
        type = "panel",
        name = "kwibus random things",
        displayName = "kwibus random things |caaaaaav" .. ADDON_VERSION .. "|r",
        author = "|ce6202dKwiebe-Kwibus|r",
        version = ADDON_VERSION,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local options = {}

    -- Keep your existing order by module registration order
    for _, mod in ipairs(KRT.modules) do
        if mod.GetLAMSubmenu then
            local submenu = mod:GetLAMSubmenu()
            if submenu then table.insert(options, submenu) end
        end
    end

    LAM:RegisterAddonPanel(ADDON_NAME .. "_Panel", panelData)
    LAM:RegisterOptionControls(ADDON_NAME .. "_Panel", options)
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end
    EM:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    -- IMPORTANT: pass empty defaults so ZO_SavedVars doesn't do nested merging for us
    KRT.sv = ZO_SavedVars:NewAccountWide("KwibusRandomThingsSV", 1, nil, {}, GetWorldName())

    -- Create/merge SV per module, then init module
    for _, mod in ipairs(KRT.modules) do
        local id = mod.id
        local defaults = mod.defaults
        if id and type(defaults) == "table" then
            if type(KRT.sv[id]) ~= "table" then
                KRT.sv[id] = ZO_DeepTableCopy(defaults)
            end
            KRT.DeepMergeDefaults(KRT.sv[id], defaults)
        end

        if mod.Initialize then
            mod:Initialize()
        end
    end

    BuildUnifiedSettings()
end

EM:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
