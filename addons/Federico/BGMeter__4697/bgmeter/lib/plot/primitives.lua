
BGMeter = BGMeter or {}
local BGMeter = BGMeter
BGMeter.Plot = BGMeter.Plot or {}

local P = {}

local function ui() return BGMeter.zenimax.ui end

local _id = 0
local function uniq(prefix)
    _id = _id + 1
    return (prefix or "BGMeterC") .. _id
end

function P.label(parent, font, color, name)
    local c = ui().create_control(name or uniq("BGMeterLbl"), parent, CT_LABEL)
    c:SetFont(font or BGMeter.Plot.style.FONT.row)
    if color then BGMeter.Plot.style.color(c, color) end
    c:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    return c
end

local FILL = "EsoUI/Art/UnitAttributeVisualizer/attributeBar_dynamic_fill.dds"

function P.rect(parent, color, name)
    local c = ui().create_control(name or uniq("BGMeterRect"), parent, CT_TEXTURE)
    c:SetTexture(FILL)
    c:SetTextureCoords(0, 1, 0, 0.05)
    if c.SetPixelRoundingEnabled then c:SetPixelRoundingEnabled(false) end
    local col = color or { 1, 1, 1, 1 }
    c:SetColor(col[1], col[2], col[3], col[4] or 1)
    return c
end

function P.set_rect_color(c, color)
    if not c or not color then return end
    c:SetColor(color[1], color[2], color[3], color[4] or 1)
end

function P.backdrop(parent, name)
    return P.rect(parent, BGMeter.Constants.COLOR.panel, name or uniq("BGMeterBd"))
end

function P.frame(parent, name)
    local c = ui().create_control(name or uniq("BGMeterFrame"), parent, CT_BACKDROP)
    c:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16, 8)
    c:SetCenterColor(0, 0, 0, 0)
    c:SetInsets(0, 0, 0, 0)
    return c
end

function P.button(parent, normal, pressed, over, name)
    local b = ui().create_control(name or uniq("BGMeterBtn"), parent, CT_BUTTON)
    b:SetNormalTexture(normal)
    if pressed then b:SetPressedTexture(pressed) end
    if over then b:SetMouseOverTexture(over) end
    b:SetMouseEnabled(true)
    return b
end

function P.icon(parent, texturePath, name)
    local c = ui().create_control(name or uniq("BGMeterIcon"), parent, CT_TEXTURE)
    if texturePath then c:SetTexture(texturePath) end
    return c
end

function P.line(parent, color, thickness)
    local ok, c = pcall(function()
        return ui().create_from_virtual(uniq("BGMeterLine"), parent, "BGMeterLineTemplate")
    end)
    if not ok or not c then return nil end
    if c.SetPixelRoundingEnabled then c:SetPixelRoundingEnabled(false) end
    if c.SetThickness then c:SetThickness(thickness or 2) end
    local col = color or { 1, 1, 1, 1 }
    c:SetColor(col[1], col[2], col[3], col[4] or 1)
    return c
end

BGMeter.Plot.primitives = P
