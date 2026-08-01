
BGMeter = BGMeter or {}
local BGMeter = BGMeter

local Prefs = {}

local FALLBACK = {
    max_history = 50, auto_open_mode = "exit", sounds = true, animate = true,
    show_haul = true, show_veterancy = true, show_standing = true,
    show_awards = true, show_timeline = true, show_launcher = true,
    opacity = 0.97,
    sort_key = "damage", sort_desc = true,
}

local function migrate(p)
    if p.auto_open ~= nil and p.auto_open_mode == nil then
        p.auto_open_mode = p.auto_open and "exit" or "off"
        p.auto_open = nil
    end
    p.show_vanguard, p.vanguard_dock, p.vanguard_fade = nil, nil, nil
    return p
end

local function tbl()
    local sv = BGMeter.zenimax.savedvars.get()
    if sv then
        sv.prefs = sv.prefs or {}
        return migrate(sv.prefs)
    end
    return FALLBACK
end

function Prefs.get(key)
    local p = tbl()
    local v = p[key]
    if v == nil then v = FALLBACK[key] end
    return v
end

function Prefs.set(key, value)
    tbl()[key] = value
end

function Prefs.toggle(key)
    local v = not Prefs.get(key)
    Prefs.set(key, v)
    return v
end

BGMeter.Prefs = Prefs
