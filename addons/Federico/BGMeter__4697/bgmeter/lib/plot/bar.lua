
BGMeter = BGMeter or {}
local BGMeter = BGMeter
BGMeter.Plot = BGMeter.Plot or {}

local Bar = {}

local TRACK_COLOR = { 1, 1, 1, 0.07 }

function Bar.create(parent)
    local P = BGMeter.Plot.primitives
    local ui = BGMeter.zenimax.ui
    local container = ui.create_control(nil, parent, CT_CONTROL)

    local track = P.rect(container, TRACK_COLOR)
    track:SetAnchorFill(container)

    local fill = P.rect(container, BGMeter.Constants.COLOR.accent)
    fill:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
    fill:SetAnchor(BOTTOMLEFT, container, BOTTOMLEFT, 0, 0)
    fill:SetWidth(0)

    local sheen = P.rect(container, { 1, 1, 1, 0.18 })
    sheen:SetAnchor(TOPLEFT, fill, TOPLEFT, 0, 0)
    sheen:SetHeight(2)
    sheen:SetWidth(0)

    return { container = container, track = track, fill = fill, sheen = sheen }
end

local function lighten(c)
    return { c[1] + (1 - c[1]) * 0.45, c[2] + (1 - c[2]) * 0.45, c[3] + (1 - c[3]) * 0.45, 0.55 }
end

function Bar.set(bar, pct, color, width)
    if not bar then return end
    pct = math.max(0, math.min(1, pct or 0))
    local col = color or BGMeter.Constants.COLOR.accent
    local px = math.floor((width or 0) * pct + 0.5)
    BGMeter.Plot.primitives.set_rect_color(bar.fill, col)
    bar.fill:SetWidth(px)
    if bar.sheen then
        BGMeter.Plot.primitives.set_rect_color(bar.sheen, lighten(col))
        bar.sheen:SetWidth(px)
        bar.sheen:SetHidden(px <= 0)
    end
end

function Bar.set_hidden(bar, hidden)
    if bar and bar.container then bar.container:SetHidden(hidden) end
end

BGMeter.Plot.bar = Bar
