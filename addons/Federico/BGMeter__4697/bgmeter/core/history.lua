
BGMeter = BGMeter or {}
local BGMeter = BGMeter

local History = {}

local function sv()
    return BGMeter.zenimax.savedvars.get()
end

local HEAVY_KEEP = 10

function History.push(match)
    local data = sv()
    if not data then return end
    data.matches = data.matches or {}
    table.insert(data.matches, 1, match)
    local cap = (data.prefs and data.prefs.max_history) or 50
    while #data.matches > cap do
        table.remove(data.matches)
    end
    for i = HEAVY_KEEP + 1, #data.matches do
        data.matches[i].timeline = nil
        data.matches[i].killfeed = nil
        data.matches[i].objectives = nil
        data.matches[i].relics = nil
    end
    BGMeter.Log.debug("history push -> %d stored", #data.matches)
end

function History.count()
    local data = sv()
    return (data and data.matches) and #data.matches or 0
end

function History.get(index)
    local data = sv()
    if not data or not data.matches then return nil end
    return data.matches[index]
end

function History.most_recent()
    return History.get(1)
end

function History.delete(index)
    local data = sv()
    if not data or not data.matches or not data.matches[index] then return false end
    table.remove(data.matches, index)
    return true
end

function History.clear()
    local data = sv()
    if data then data.matches = {} end
end

BGMeter.History = History
