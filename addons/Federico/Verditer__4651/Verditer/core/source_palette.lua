
Verditer = Verditer or {}
local Verditer = Verditer

local SP = {}
Verditer.SourcePalette = SP

local math_floor = math.floor

local function hsv(h, s, v)
  h = h - math_floor(h)
  local i = math_floor(h * 6)
  local f = h * 6 - i
  local p, q, t = v * (1 - s), v * (1 - f * s), v * (1 - (1 - f) * s)
  i = i % 6
  if     i == 0 then return v, t, p
  elseif i == 1 then return q, v, p
  elseif i == 2 then return p, v, t
  elseif i == 3 then return p, q, v
  elseif i == 4 then return t, p, v
  else               return v, p, q end
end

local N = 12
local PALETTE = {}
for i = 1, N do
  local r, g, b = hsv(i * 0.61803398875, 0.82, 0.98)
  PALETTE[i] = { r = r, g = g, b = b, a = 0.92 }
end

SP.ENV   = { r = 0.55, g = 0.55, b = 0.58, a = 0.85 }
SP.OTHER = { r = 0.40, g = 0.42, b = 0.48, a = 0.80 }

function SP.lookup(uid)
  if not uid or uid == 0 then return SP.ENV end
  if uid < 0 then return SP.OTHER end
  return PALETTE[(uid % N) + 1]
end
