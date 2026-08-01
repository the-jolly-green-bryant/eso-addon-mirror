
BGMeter = BGMeter or {}
local BGMeter = BGMeter
BGMeter.Plot = BGMeter.Plot or {}

local S = {}

S.FONT = {
    row     = "ZoFontGame",
    header  = "ZoFontWinH4",
    big     = "ZoFontWinT1",
    small   = "ZoFontGameSmall",
    title   = "ZoFontWinH2",
    banner  = "ZoFontWinH1",
}

function S.color(control, rgba)
    if not control or not rgba then return end
    control:SetColor(rgba[1], rgba[2], rgba[3], rgba[4] or 1)
end

function S.named(key)
    return BGMeter.Constants.COLOR[key]
end

function S.team_color(team)
    local C = BGMeter.zenimax.constants
    local COL = BGMeter.Constants.COLOR.team
    if team == C.BATTLEGROUND_TEAM_FIRE_DRAKES then return COL.fire end
    if team == C.BATTLEGROUND_TEAM_PIT_DAEMONS then return COL.pit end
    if team == C.BATTLEGROUND_TEAM_STORM_LORDS then return COL.storm end
    return BGMeter.Constants.COLOR.text_dim
end

function S.team_art_key(team)
    local C = BGMeter.zenimax.constants
    if team == C.BATTLEGROUND_TEAM_FIRE_DRAKES then return "orange" end
    if team == C.BATTLEGROUND_TEAM_PIT_DAEMONS then return "green" end
    if team == C.BATTLEGROUND_TEAM_STORM_LORDS then return "purple" end
    return "neutral"
end

BGMeter.Plot.style = S
