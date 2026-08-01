
BGMeter = BGMeter or {}
local BGMeter = BGMeter

local Records = {}

local function store()
    local sv = BGMeter.zenimax.savedvars.get()
    if not sv then return nil end
    sv.records = sv.records or { damage = 0, healing = 0, kills = 0, ap = 0, bestRank = 0 }
    return sv.records
end

function Records.evaluate(m)
    local R = store()
    if not R then return end
    m.records = m.records or {}
    local lr = BGMeter.Match.local_row(m)
    if lr then
        if (lr.damage or 0)  > (R.damage or 0)  then m.records.damage  = true; R.damage  = lr.damage end
        if (lr.healing or 0) > (R.healing or 0) then m.records.healing = true; R.healing = lr.healing end
        if (lr.kills or 0)   > (R.kills or 0)   then m.records.kills   = true; R.kills   = lr.kills end
    end
    if (m.haul.apGained or 0) > (R.ap or 0) then m.records.ap = true; R.ap = m.haul.apGained end
end

function Records.note_rank(m, rank)
    if not rank or rank <= 0 then return end
    local R = store()
    if not R then return end
    if (R.bestRank or 0) == 0 or rank < R.bestRank then
        m.records = m.records or {}
        m.records.rank = true
        R.bestRank = rank
    end
end

BGMeter.Records = Records
