local W = Chorus.Widgets
local counter = 0
local function nextName(prefix) counter = counter + 1; return "Chorus_" .. prefix .. counter end
W.NextName = nextName

local fontCache = {}
W.face, W.secondary = "$(BOLD_FONT)", "$(MEDIUM_FONT)"

function W.SetFace(key)
    W.face, W.secondary = Chorus.Fonts.Resolve(key)
    fontCache = {}
    W.SMALL_FONT = W.secondary .. "|12|soft-shadow-thin"
    W.SUMMARY_FONT = W.secondary .. "|13|soft-shadow-thin"
end

function W.Font(size)
    size = math.floor(size + 0.5)
    local f = fontCache[size]
    if not f then f = ("%s|%d|soft-shadow-thick"):format(W.face, size); fontCache[size] = f end
    return f
end
W.SMALL_FONT = "$(MEDIUM_FONT)|12|soft-shadow-thin"
W.SUMMARY_FONT = "$(MEDIUM_FONT)|13|soft-shadow-thin"

function W.Rect(parent, rgb, alpha)
    local c = WINDOW_MANAGER:CreateControl(nextName("Rect"), parent, CT_BACKDROP)
    c:SetCenterColor(rgb[1], rgb[2], rgb[3], alpha or 1)
    c:SetEdgeColor(0, 0, 0, 0)
    c:SetEdgeTexture("", 8, 1, 1)
    c:SetInsets(0, 0, 0, 0)
    c:SetMouseEnabled(false)
    return c
end
function W.Label(parent, font, rgb, align)
    local l = WINDOW_MANAGER:CreateControl(nextName("Label"), parent, CT_LABEL)
    l:SetFont(font)
    l:SetColor(rgb[1], rgb[2], rgb[3], 1)
    l:SetHorizontalAlignment(align or TEXT_ALIGN_LEFT)
    l:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    l:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
    l:SetMouseEnabled(false)
    return l
end
function W.SetLabelColor(l, rgb, alpha) l:SetColor(rgb[1], rgb[2], rgb[3], alpha or 1) end
