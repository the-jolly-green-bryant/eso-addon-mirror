--------------------------------------------------------------
-- BBTMenu.lua
-- Console Settings for BackBarTimer (Harven’s Addon Settings)
-- Version: 1.5-harven
-- Author: SugaComa (Rik Sprint)
--------------------------------------------------------------

local BBTMenu = {}
BBTMenu.name    = "BBTMenu"
BBTMenu.version = "1.5-harven"

local LHA = LibHarvensAddonSettings
if not LHA then
    CHAT_ROUTER:AddSystemMessage("[BBTMenu] LibHarvensAddonSettings not found. Please install or enable it.")
    return
end

-- ensure saved vars exist
local function coalesce(addon)
    addon.saved             = addon.saved or {}
    addon.saved.mode        = addon.saved.mode        or addon.mode        or "pvp"
    addon.saved.leadSeconds = addon.saved.leadSeconds or addon.leadSeconds or 2
    addon.saved.debug       = addon.saved.debug       or addon.debug       or false
    addon.saved.suppressZeroDuration = addon.saved.suppressZeroDuration or addon.suppressZeroDuration or false
    addon.mode              = addon.saved.mode
    addon.leadSeconds       = addon.saved.leadSeconds
    addon.debug             = addon.saved.debug
    addon.suppressZeroDuration = addon.saved.suppressZeroDuration
end

--------------------------------------------------------------
-- Setup menu
--------------------------------------------------------------
function BBTMenu.Setup(addon)
    coalesce(addon)

    local options = {
        allowDefaults = true,
        allowRefresh  = true,
        defaultsFunction = function()
            addon.mode               = "pvp"
            addon.leadSeconds        = 2
            addon.debug              = false
            addon.suppressZeroDuration = false
            addon.saved.mode         = addon.mode
            addon.saved.leadSeconds  = addon.leadSeconds
            addon.saved.debug        = addon.debug
            addon.saved.suppressZeroDuration = addon.suppressZeroDuration
            CHAT_ROUTER:AddSystemMessage("[BBT] Defaults restored (pvp, 2s, debug off).")
        end,
    }

    local settings = LHA:AddAddon("BackBarTimer", options)
    if not settings then return end

    ----------------------------------------------------------
    -- Section Header
    ----------------------------------------------------------
    settings:AddSetting({
        type  = LHA.ST_SECTION,
        label = "BackBarTimer Settings",
    })

    ----------------------------------------------------------
    -- Dropdown: Mode
    ----------------------------------------------------------
    settings:AddSetting({
        type        = LHA.ST_DROPDOWN,
        label       = "Mode",
        tooltip     = "Select PvP (average buff time) or PvE (per-skill timers).",
        items       = {
            { name = "PvE (Per-Skill)", data = "pve" },
            { name = "PvP (Average)",  data = "pvp" },
        },
        default     = "PvP (Average)",
        getFunction = function()
            return (addon.mode == "pvp") and "PvP (Average)" or "PvE (Per-Skill)"
        end,
        setFunction = function(_, name, item)
            local val = item.data or (name == "PvE (Per-Skill)" and "pve" or "pvp")
            addon.mode       = val
            addon.saved.mode = val
            CHAT_ROUTER:AddSystemMessage(string.format("[BBT] Mode set to %s", val))
        end,
    })

    ----------------------------------------------------------
    -- Slider: Lead Seconds
    ----------------------------------------------------------
    settings:AddSetting({
        type        = LHA.ST_SLIDER,
        label       = "Lead Time (seconds)",
        tooltip     = "Seconds before expiry to alert.",
        min         = 1,
        max         = 10,
        step        = 1,
        unit        = "s",
        format      = "%d",
        default     = 2,
        getFunction = function() return tonumber(addon.leadSeconds) or 2 end,
        setFunction = function(value)
            addon.leadSeconds        = value
            addon.saved.leadSeconds  = value
            CHAT_ROUTER:AddSystemMessage(string.format("[BBT] Lead time set to %d s", value))
        end,
    })

    ----------------------------------------------------------
    -- Checkbox: Debug Mode
    ----------------------------------------------------------
    settings:AddSetting({
        type        = LHA.ST_CHECKBOX,
        label       = "Debug Mode",
        tooltip     = "Show detailed event logs in chat.",
        default     = false,
        getFunction = function() return addon.debug or false end,
        setFunction = function(state)
            addon.debug       = state
            addon.saved.debug = state
            CHAT_ROUTER:AddSystemMessage(string.format("[BBT] Debug mode %s", state and "ON" or "OFF"))
        end,
    })

    settings:AddSetting({
        type        = LHA.ST_CHECKBOX,
        label       = "Hide Zero-Duration Warnings",
        tooltip     = "Suppresses chat warnings for abilities with no duration.",
        default     = false,
        getFunction = function() return addon.suppressZeroDuration or false end,
        setFunction = function(state)
            addon.suppressZeroDuration = state
            addon.saved.suppressZeroDuration = state
            CHAT_ROUTER:AddSystemMessage(string.format("[BBT] Zero-duration warnings %s", state and "OFF" or "ON"))
        end,
    })

    ----------------------------------------------------------
    -- Button: Manual Cache Rebuild
    ----------------------------------------------------------
    settings:AddSetting({
        type        = LHA.ST_BUTTON,
        label       = "Rebuild Cache",
        tooltip     = "Manually rebuilds tracked skill cache.",
        buttonText  = "Rebuild",
        clickHandler = function()
            if addon.BuildCache then
                addon:BuildCache()
            end
            CHAT_ROUTER:AddSystemMessage("[BBT] Cache rebuild triggered manually.")
        end,
    })

    CHAT_ROUTER:AddSystemMessage("[BBTMenu] Settings menu registered.")
end

_G["BBTMenu"] = BBTMenu
