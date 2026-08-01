
BGMeter = BGMeter or {}
local BGMeter = BGMeter
BGMeter.zenimax = BGMeter.zenimax or {}

local M = {}

local DEFAULTS = {
    version  = 1,
    matches  = {},
    standing = { rank = 0, score = 0 },
    records  = {
        damage = 0, healing = 0, kills = 0, ap = 0, bestRank = 0,
    },
    window   = { x = 0, y = 0, w = 0, h = 0, hidden = true, scale = 1.0 },
    launcher = { x = 0, y = 0 },
    menu     = { x = 0, y = 0, w = 0, h = 0 },
    prefs    = {
        max_history    = 50,
        auto_open_mode = "exit",
        sounds         = true,
        animate        = true,
        show_haul      = true,
        show_veterancy = true,
        show_standing  = true,
        show_awards    = true,
        show_timeline  = true,
        show_launcher  = true,
        opacity        = 0.97,
        sort_key       = "damage",
        sort_desc      = true,
    },
}

function M.init(saved_var_name, version)
    local sv = ZO_SavedVars:NewAccountWide(saved_var_name, version, nil, DEFAULTS, GetWorldName())
    sv.vanguard = nil
    M.data = sv
    return sv
end

function M.get() return M.data end

BGMeter.zenimax.savedvars = M
