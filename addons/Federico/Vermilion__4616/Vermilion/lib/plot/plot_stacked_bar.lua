Vermilion = Vermilion or {}
Vermilion.lib = Vermilion.lib or {}
Vermilion.lib.plot = Vermilion.lib.plot or {}

local M = {}
M.__index = M
Vermilion.lib.plot.StackedBar = M

local Pool = Vermilion.lib.plot.Pool

local zc = Vermilion.zenimax.constants
local CT_TEXTURE = zc.CT_TEXTURE
local BOTTOMLEFT = zc.BOTTOMLEFT

local math_max   = math.max
local math_min   = math.min
local math_floor = math.floor

function M.new(parent, name_prefix, opts)
  opts = opts or {}
  local texture = opts.texture
  local tc      = opts.texture_coords

  local self = setmetatable({}, M)
  self._pool = Pool.new(name_prefix, parent, CT_TEXTURE, function(c)
    if texture then c:SetTexture(texture) end
    if tc then c:SetTextureCoords(tc[1], tc[2], tc[3], tc[4]) end
  end)
  return self
end

function M:render(area, segments, area_w, area_h, total_frac)
  self._pool:ReleaseAllObjects()
  local total_h = (total_frac > 0.005) and math_max(2, area_h * math_min(1, total_frac)) or 0
  local cum_h   = 0
  for i = 1, #segments do
    local seg   = segments[i]
    local seg_h = math_max(1, math_floor(total_h * seg.share + 0.5))
    local t     = self._pool:AcquireObject()
    t:ClearAnchors()
    t:SetAnchor(BOTTOMLEFT, area, BOTTOMLEFT, 0, -cum_h)
    t:SetWidth(area_w)
    t:SetHeight(seg_h)
    t:SetColor(seg.r, seg.g, seg.b, seg.a)
    t:SetHidden(false)
    cum_h = cum_h + seg_h
  end
end

function M:release()
  self._pool:ReleaseAllObjects()
end
