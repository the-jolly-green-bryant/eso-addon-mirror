
BGMeter = BGMeter or {}
local BGMeter = BGMeter
BGMeter.Plot = BGMeter.Plot or {}

local M = {}
BGMeter.Plot.donut = M

local RING_TEXTURE = "bgmeter/assets/ring.dds"

local Donut = {}
Donut.__index = Donut

function M.new(name, parent, size, opts)
    opts = opts or {}
    local ui = BGMeter.zenimax.ui
    local self = setmetatable({}, Donut)
    self.name = name
    self.size = size
    self.clockwise = opts.clockwise ~= false
    self.texture = opts.texture or RING_TEXTURE
    self.root = ui.create_control(name, parent, CT_CONTROL)
    self.root:SetDimensions(size, size)
    if opts.track then
        local t = ui.create_control(name .. "Track", self.root, CT_TEXTURE)
        t:SetAnchorFill(self.root)
        t:SetTexture(self.texture)
        t:SetColor(opts.track[1], opts.track[2], opts.track[3], opts.track[4] or 1)
        t:SetDrawLevel(0)
        self.track = t
    end
    self.slices = {}
    self.n = 0
    return self
end

local function slice(self, i)
    local c = self.slices[i]
    if c then return c end
    c = BGMeter.zenimax.ui.create_control(self.name .. "Slice" .. i, self.root, CT_COOLDOWN)
    c:SetAnchorFill(self.root)
    c:SetTexture(self.texture)
    c:SetRadialCooldownClockwise(self.clockwise)
    self.slices[i] = c
    return c
end

function Donut:set(values, colors, total)
    if not total then
        total = 0
        for i = 1, #values do
            local v = values[i] or 0
            if v > 0 then total = total + v end
        end
    end
    local start = 0
    local n = 0
    local count = #values
    for i = 1, count do
        local v = values[i] or 0
        local share = (total > 0 and v > 0) and math.min(1, v / total) or 0
        if share > 0 then
            n = n + 1
            local c = slice(self, n)
            local col = colors[i] or colors[#colors]
            c:SetFillColor(col[1], col[2], col[3], col[4] or 1)
            c:SetDrawLevel(count - i + 1)
            c:StartFixedCooldown(start + share, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING, false)
            c:SetFillColor(col[1], col[2], col[3], col[4] or 1)
            c:SetHidden(false)
            start = start + share
        end
    end
    for i = n + 1, #self.slices do
        self.slices[i]:SetHidden(true)
    end
    self.n = n
    return n
end

function Donut:control() return self.root end
function Donut:count() return self.n end
function Donut:set_hidden(h) self.root:SetHidden(h) end
