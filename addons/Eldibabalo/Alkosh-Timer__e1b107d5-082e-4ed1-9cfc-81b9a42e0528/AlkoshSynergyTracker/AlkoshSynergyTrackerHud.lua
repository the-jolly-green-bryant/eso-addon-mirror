-- Alkosh HUD — built in Lua (PS5 console cannot reposition XML top-level controls reliably).

AlkoshSynergyTracker = AlkoshSynergyTracker or {}
local AST = AlkoshSynergyTracker
local HUD_W, HUD_H = 420, 96
local BAR_W = 396

local function MakeLabel(name, parent, font, width, height)
    local label = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
    label:SetFont(font)
    label:SetDimensions(width or BAR_W, height or 24)
    label:SetColor(1, 1, 1, 1)
    label:SetMouseEnabled(false)
    return label
end

function AST:CreateHud()
    if self.hudReady and AST_Hud then
        return true
    end

    local wm = WINDOW_MANAGER
    if not wm then
        return false
    end

    local hud = wm:CreateTopLevelWindow("AST_Hud")
    hud:SetDimensions(HUD_W, HUD_H)
    hud:SetMouseEnabled(false)
    hud:SetMovable(false)
    hud:SetClampedToScreen(true)
    hud:SetHidden(true)

    if DL_OVERLAY then
        hud:SetDrawLayer(DL_OVERLAY)
    end
    if DT_HIGH then
        hud:SetDrawTier(DT_HIGH)
    end
    hud:SetDrawLevel(10)

    local bg = wm:CreateControl("AST_HudBg", hud, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.05, 0.05, 0.05, 0.88)
    bg:SetEdgeColor(0.35, 0.35, 0.35, 1)
    bg:SetEdgeTexture("", 1, 1, 1)

    local title = MakeLabel("AST_HudTitle", hud, "$(BOLD_FONT)|18|soft-shadow-thick", 120, 24)
    title:SetAnchor(TOPLEFT, hud, TOPLEFT, 12, 8)
    title:SetText("ALKOSH")
    title:SetColor(0.8, 0.8, 0.8, 1)

    local status = MakeLabel("AST_HudStatus", hud, "$(BOLD_FONT)|20|soft-shadow-thick", 160, 24)
    status:SetAnchor(TOPRIGHT, hud, TOPRIGHT, -12, 6)
    status:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    status:SetText("READY")

    local barBg = wm:CreateControl("AST_HudBarBg", hud, CT_TEXTURE)
    barBg:SetDimensions(BAR_W, 14)
    barBg:SetAnchor(TOPLEFT, hud, TOPLEFT, 12, 34)
    barBg:SetTexture("EsoUI/Art/Miscellaneous/horizontalProgBarBG.dds")
    barBg:SetTextureCoords(0, 1, 0, 0.625)

    local barFill = wm:CreateControl("AST_HudBarFill", hud, CT_TEXTURE)
    barFill:SetDimensions(BAR_W, 14)
    barFill:SetAnchor(TOPLEFT, barBg, TOPLEFT, 0, 0)
    barFill:SetTexture("EsoUI/Art/Miscellaneous/horizontalProgBar.dds")
    barFill:SetTextureCoords(0, 1, 0, 0.625)

    local timer = MakeLabel("AST_HudTimer", hud, "$(MEDIUM_FONT)|16|soft-shadow-thick", BAR_W, 14)
    timer:SetAnchor(CENTER, barBg, CENTER, 0, 0)
    timer:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    timer:SetText("--")

    local prompt = MakeLabel("AST_HudPrompt", hud, "$(BOLD_FONT)|18|soft-shadow-thick", BAR_W, 24)
    prompt:SetAnchor(TOP, barBg, BOTTOM, 0, 6)
    prompt:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    prompt:SetText("")

    local cooldowns = MakeLabel("AST_HudCooldowns", hud, "$(MEDIUM_FONT)|14|soft-shadow-thick", BAR_W, 20)
    cooldowns:SetAnchor(TOPLEFT, prompt, BOTTOMLEFT, 0, 2)
    cooldowns:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    cooldowns:SetText("")

    self.hudReady = true
    self.lastTransformKey = nil
    return true
end

function AST:GetHudBaseXY()
    local hud = AST_Hud
    local root = GuiRoot
    if not hud or not root or type(root.GetDimensions) ~= "function" then
        return 750, 620
    end
    local rootW, rootH = root:GetDimensions()
    if rootW <= 0 then rootW = 1920 end
    if rootH <= 0 then rootH = 1080 end
    local baseX = math.floor((rootW - HUD_W) / 2)
    local baseY = math.floor(rootH - self.HUD_MARGIN_BOTTOM - HUD_H)
    return baseX, baseY
end

function AST:ApplyHudTransform()
    if not self.hudReady then
        self:CreateHud()
    end
    local hud = AST_Hud
    if not hud or not self.sv then
        return
    end
    if type(hud.ClearAnchors) ~= "function" or type(hud.SetAnchor) ~= "function" then
        return
    end
    local root = GuiRoot
    if not root then
        return
    end

    local ox = math.floor(tonumber(self.sv.offsetX) or 0)
    local oy = math.floor(tonumber(self.sv.offsetY) or 0)
    local scale = tonumber(self.sv.scale) or 1.0
    if type(zo_clamp) == "function" then
        scale = zo_clamp(scale, 0.5, 2.5)
    else
        scale = math.max(0.5, math.min(2.5, scale))
    end
    scale = math.floor((scale * 100) + 0.5) / 100
    self.sv.scale = scale

    local transformKey = string.format("%d:%d:%.2f", ox, oy, scale)
    local baseX, baseY = self:GetHudBaseXY()
    local x = baseX + ox
    local y = baseY + oy

    if transformKey ~= self.lastTransformKey then
        hud:ClearAnchors()
        hud:SetAnchor(TOPLEFT, root, TOPLEFT, x, y)
        if type(hud.SetScale) == "function" then
            hud:SetScale(scale)
        end
        self.lastTransformKey = transformKey
        if self.sv.debug then
            d(string.format("[AST] HUD anchor %d,%d scale %.2f", x, y, scale))
        end
    end
end

AST.ApplyHudPosition = AST.ApplyHudTransform
