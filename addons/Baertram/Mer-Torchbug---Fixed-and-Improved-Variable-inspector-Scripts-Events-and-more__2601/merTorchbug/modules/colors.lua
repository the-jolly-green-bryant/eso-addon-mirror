local tbug = TBUG or SYSTEMS:GetSystem("merTorchbug")
local cm = CALLBACK_MANAGER
local abs = math.abs
local floor = math.floor
local strmatch = string.match
local tonumber = tonumber

local types = tbug.types
local stringType = types.string
local numberType = types.number
local functionType = types.func
local tableType = types.table
local userDataType = types.userdata
local structType = types.struct

tbug.interfaceColorChanges = ZO_CallbackObject:New()
tbug.makeColorDef = {}

function tbug.makeColorDef.hsl(h, s, l)
    return tbug.makeColorDef.hsla(h, s, l, 1)
end

function tbug.makeColorDef.hsla(h, s, l, a)
    -- https://en.wikipedia.org/wiki/HSL_and_HSV
    -- formulas adjusted to reduce the number of calculations

    h = tonumber(h) / 30 -- equals 2*H' from wiki
    s = tonumber(s) / 100
    l = tonumber(l) / 100
    local c = s * (0.5 - abs(l - 0.5)) -- equals C/2 from wiki
    local r, g, b

    if h < 2 then
        r = l + c
        g = l + c * (h - 1)
        b = l - c
    elseif h < 4 then
        r = l + c * (3 - h)
        g = l + c
        b = l - c
    elseif h < 6 then
        r = l - c
        g = l + c
        b = l + c * (h - 5)
    elseif h < 8 then
        r = l - c
        g = l + c * (7 - h)
        b = l + c
    elseif h < 10 then
        r = l + c * (h - 9)
        g = l - c
        b = l + c
    else
        r = l + c
        g = l - c
        b = l + c * (11 - h)
    end

    return ZO_ColorDef:New(r, g, b, tonumber(a))
end


function tbug.makeColorDef.hsv(h, s, v)
    return tbug.makeColorDef.hsva(h, s, v, 1)
end


function tbug.makeColorDef.hsva(h, s, v, a)
    -- https://en.wikipedia.org/wiki/HSL_and_HSV

    h = tonumber(h) / 60
    s = tonumber(s) / 100
    v = tonumber(v) / 100
    local r, g, b

    if h < 1 then
        r = v
        g = v * (1 - s * (1 - h))
        b = v * (1 - s)
    elseif h < 2 then
        r = v * (1 - s * (h - 1))
        g = v
        b = v * (1 - s)
    elseif h < 3 then
        r = v * (1 - s)
        g = v
        b = v * (1 - s * (3 - h))
    elseif h < 4 then
        r = v * (1 - s)
        g = v * (1 - s * (h - 3))
        b = v
    elseif h < 5 then
        r = v * (1 - s * (5 - h))
        g = v * (1 - s)
        b = v
    else
        r = v
        g = v * (1 - s)
        b = v * (1 - s * (h - 5))
    end

    return ZO_ColorDef:New(r, g, b, tonumber(a))
end


function tbug.makeColorDef.rgb(r, g, b)
    r = tonumber(r) / 255
    g = tonumber(g) / 255
    b = tonumber(b) / 255
    return ZO_ColorDef:New(r, g, b)
end


function tbug.makeColorDef.rgba(r, g, b, a)
    r = tonumber(r) / 255
    g = tonumber(g) / 255
    b = tonumber(b) / 255
    return ZO_ColorDef:New(r, g, b, tonumber(a))
end

function tbug.initColorTable(tableName, callbackName)
    -- this ensures that the first lookup of any not-yet-cached color
    -- creates a ZO_ColorDef object from saved color value and stores
    -- it in the cache for future lookups
    setmetatable(tbug.cache[tableName],
    {
        __index = function(tab, key)
            local val = tbug.savedVars[tableName][key]
            local color = tbug.parseColorDef(val)
            if not color then
                val = tbug.svDefaults[tableName][key]
                color = tbug.parseColorDef(val) or ZO_ColorDef:New(val)
            end
            rawset(tab, key, color)
            return color
        end,
    })
    -- this ensures that when the user edits a color value through
    -- the TableInspector, a new ZO_ColorDef object will be stored
    -- in the cache and callbacks fired to notify listeners
    setmetatable(tbug.savedVars[tableName],
    {
        _tbug_gettype = function(tab, key)
            return "color"
        end,
        _tbug_setindex = function(tab, key, val)
            if val == nil then
                -- restore the default value instead
                val = tbug.svDefaults[tableName][key]
            end
            local color = tbug.parseColorDef(val)
            if not color then
                error("unable to parse color: " .. tostring(val), 0)
            end
            rawset(tab, key, val)
            rawset(tbug.cache[tableName], key, color)
            cm:FireCallbacks(callbackName, key, color)
        end,
    })
end


do
    local function setControlColor(control, color)
        control:SetColor(color:UnpackRGBA())
    end

    local setVertexColorFuncs =
    {
        ["_BOTTOMLEFT"] = function(control, color)
            control:SetVertexColors(VERTEX_POINTS_BOTTOMLEFT, color:UnpackRGBA())
        end,
        ["_BOTTOMRIGHT"] = function(control, color)
            control:SetVertexColors(VERTEX_POINTS_BOTTOMRIGHT, color:UnpackRGBA())
        end,
        ["_TOPLEFT"] = function(control, color)
            control:SetVertexColors(VERTEX_POINTS_TOPLEFT, color:UnpackRGBA())
        end,
        ["_TOPRIGHT"] = function(control, color)
            control:SetVertexColors(VERTEX_POINTS_TOPRIGHT, color:UnpackRGBA())
        end,
    }

    local cacheInterfaceColors = tbug.cache.interfaceColors
    function tbug.confControlColor(control, childName--[[optional]], colorName)
        if colorName then
            control = control:GetNamedChild(childName)
        else
            colorName = childName
        end
        setControlColor(control, cacheInterfaceColors[colorName])
        tbug.interfaceColorChanges:RegisterCallback(colorName, setControlColor, control)
    end

    function tbug.confControlVertexColors(control, childName--[[optional]], colorPrefix)
        if colorPrefix then
            control = control:GetNamedChild(childName)
        else
            colorPrefix = childName
        end
        for suffix, setter in zo_insecureNext , setVertexColorFuncs do
            local colorName = colorPrefix .. suffix
            setter(control, cacheInterfaceColors[colorName])
            tbug.interfaceColorChanges:RegisterCallback(colorName, setter, control)
        end
    end
end

function tbug.parseColorDef(...)
--d("[tbug]parseColorDef " .. tostring(...))
    if type(...) ~= stringType then
--d("<type ~= string")
        return ZO_ColorDef:New(...)
    end

    -- syntax inspired by CSS color specification
    -- http://www.w3.org/TR/css3-color/#numerical

    local scheme, args = strmatch(..., "^ *(%l+) *%((.*)%) *$")
    if scheme then
        local ctor = tbug.makeColorDef[scheme]
        local ok, color = pcall(ctor, zo_strsplit(",", args))
        if ok then
            return color
        end
    else
        local hex = strmatch(..., "^ *#(%x+) *$")
        if hex then
            local val = tonumber(hex, 16)
            local a, r, g, b = 1, 1, 1, 1
            if #hex <= 4 then
                b = 17 * (val % 16) / 255
                g = 17 * (floor(val / 16) % 16) / 255
                r = 17 * (floor(val / 256) % 16) / 255
                if #hex == 4 then
                    a = 17 * (floor(val / 4096) % 16) / 255
                end
            else
                b = (val % 256) / 255
                g = (floor(val / 256) % 256) / 255
                r = (floor(val / 65536) % 256) / 255
                if #hex >= 8 then
                    a = (floor(val / 2^24) % 256) / 255
                end
            end
            return ZO_ColorDef:New(r, g, b, a)
        end
    end
end
