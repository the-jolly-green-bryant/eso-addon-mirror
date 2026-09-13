Vermilion = Vermilion or {}
local Vermilion = Vermilion

Vermilion.Heat = {}
local M = Vermilion.Heat

local math_floor = math.floor

M.N = 128
M.FADE_IN = 0.22

local RAMP = {
  { 0.05, 0.03, 0.53 },
  { 0.49, 0.01, 0.66 },
  { 0.80, 0.23, 0.48 },
  { 0.97, 0.53, 0.19 },
  { 0.94, 0.98, 0.13 },
}

local LUT = {}
for i = 0, M.N - 1 do
  local t = i / (M.N - 1) * (#RAMP - 1)
  local k = math_floor(t)
  if k >= #RAMP - 1 then k = #RAMP - 2 end
  local f = t - k
  local a, b = RAMP[k + 1], RAMP[k + 2]
  LUT[i] = { a[1] + (b[1] - a[1]) * f, a[2] + (b[2] - a[2]) * f, a[3] + (b[3] - a[3]) * f }
end

local VIRIDIS = {
  { 0.267, 0.005, 0.329 },
  { 0.283, 0.141, 0.458 },
  { 0.254, 0.265, 0.530 },
  { 0.207, 0.372, 0.553 },
  { 0.164, 0.471, 0.558 },
  { 0.128, 0.567, 0.551 },
  { 0.135, 0.659, 0.518 },
  { 0.267, 0.749, 0.441 },
  { 0.478, 0.821, 0.318 },
  { 0.741, 0.873, 0.150 },
  { 0.993, 0.906, 0.144 },
}

local LUT2 = {}
for i = 0, M.N - 1 do
  local t = i / (M.N - 1) * (#VIRIDIS - 1)
  local k = math_floor(t)
  if k >= #VIRIDIS - 1 then k = #VIRIDIS - 2 end
  local f = t - k
  local a, b = VIRIDIS[k + 1], VIRIDIS[k + 2]
  LUT2[i] = { a[1] + (b[1] - a[1]) * f, a[2] + (b[2] - a[2]) * f, a[3] + (b[3] - a[3]) * f }
end

function M.lut2(i)
  if i < 0 then i = 0 end
  if i > M.N - 1 then i = M.N - 1 end
  return LUT2[i]
end

function M.lut(i)
  if i < 0 then i = 0 end
  if i > M.N - 1 then i = M.N - 1 end
  return LUT[i]
end

function M.level(frac)
  if frac <= 0 then return 0 end
  if frac >= 1 then return M.N - 1 end
  local lv = math_floor(frac * (M.N - 1) + 0.5)
  if lv < 1 then lv = 1 end
  return lv
end

function M.alpha(level)
  local a = level / ((M.N - 1) * M.FADE_IN)
  if a > 1 then a = 1 end
  return 0.30 + 0.70 * a
end
