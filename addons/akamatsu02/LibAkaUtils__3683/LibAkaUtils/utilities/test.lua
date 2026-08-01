LibAkaUtils = LibAkaUtils or {}
LibAkaUtils.test = {}

local function rgbToHex(r,g,b)
	r = math.round(math.clamp(r, 0, 255))
	g = math.round(math.clamp(g, 0, 255))
	b = math.round(math.clamp(b, 0, 255))
    return string.format("%02x", r)..string.format("%02x", g)..string.format("%02x", b)
end

local function rgbToHsv(r, g, b)
  r, g, b = r / 255, g / 255, b / 255
  local max, min = math.max(r, g, b), math.min(r, g, b)
  local h, s, v
  v = max

  local d = max - min
  if max == 0 then s = 0 else s = d / max end

  if max == min then
    h = 0
  else
    if max == r then
    h = (g - b) / d
    if g < b then h = h + 6 end
    elseif max == g then h = (b - r) / d + 2
    elseif max == b then h = (r - g) / d + 4
    end
    h = h / 6
  end

  return h, s, v
end

local function hsvToRgb(h, s, v)
  local r, g, b

  local i = math.floor(h * 6);
  local f = h * 6 - i;
  local p = v * (1 - s);
  local q = v * (1 - f * s);
  local t = v * (1 - (1 - f) * s);

  i = i % 6

  if i == 0 then r, g, b = v, t, p
  elseif i == 1 then r, g, b = q, v, p
  elseif i == 2 then r, g, b = p, v, t
  elseif i == 3 then r, g, b = p, q, v
  elseif i == 4 then r, g, b = t, p, v
  elseif i == 5 then r, g, b = v, p, q
  end

  return r * 255, g * 255, b * 255
end

function LibAkaUtils.test.gradient( r1,g1,b1,r2,g2,b2,steps )
	local h1,s1,v1 = rgbToHsv(r1, g1, b1)
	local h2,s2,v2 = rgbToHsv(r2, g2, b2)
    local dh = (h2-h1)/(steps-1)
    local ds = (s2-s1)/(steps-1)
    local dv = (v2-v1)/(steps-1)
    local values = {}
    for i=0,steps-1,1 do
        local h,s,v = h1+i*dh,s1+i*ds,v1+i*dv
        local r,g,b = hsvToRgb(h, s, v)
        table.insert(values, rgbToHex(r,g,b))
    end
    d(#values)
    return values
end

function LibAkaUtils.test.gradientChat( r1,g1,b1,r2,g2,b2,steps )
    local values = LibAkaUtils.test.gradient( r1,g1,b1,r2,g2,b2,steps )
    for _,v in ipairs(values) do
        d(ScriptTracker.ColorMessage("ooooooooooooo", v))
    end
end