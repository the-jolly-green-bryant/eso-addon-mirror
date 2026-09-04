local St = Chorus.Settings
St.defaults = {
    locked = true,
    position = { x = nil, y = nil },
    lines = 7,
    font = "univers-bold",
    sizeMin = 15, sizeMax = 30,
    dwell = 900,
    includePets = true,
    showHealing = false,
    showNames = true,
    critMark = true,
    summary = true,
    colors = {
        text = { 0.91, 0.93, 0.94 },
        crit = { 0.98, 0.86, 0.62 },
        heal = { 0.62, 0.84, 0.66 },
        dim  = { 0.62, 0.65, 0.68 },
    },
}
local function deepcopy(t) if type(t) ~= "table" then return t end local o = {} for k, v in pairs(t) do o[k] = deepcopy(v) end return o end
function St.Init()
    local defaults = deepcopy(St.defaults)
    St.sv = ZO_SavedVars:NewAccountWide("ChorusSV", Chorus.svVersion, nil, defaults)
    for k, v in pairs(defaults) do if St.sv[k] == nil then St.sv[k] = deepcopy(v) end end
    St.sv.position = St.sv.position or {}
    St.sv.colors = St.sv.colors or {}
    for k, v in pairs(defaults.colors) do St.sv.colors[k] = St.sv.colors[k] or deepcopy(v) end
    return St.sv
end
function St.EngineOptions()
    return { dwell = St.sv.dwell, maxVisible = St.sv.lines, nameThreshold = St.sv.showNames and 0.9 or 2 }
end
