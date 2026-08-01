TeamShadowsManager = TeamShadowsManager or {}

local PBT = TeamShadowsManager

local UI = {}
PBT.UI = UI

local WINDOW_NAME = "TeamShadowsManagerWindow"
local MENU_BUTTON_NAME = "TeamShadowsManagerMenuButton"
local MANAGER_WINDOW_NAME = "TeamShadowsManagerPanel"
local CURSOR_PLACEMENT_UPDATE_NAME = "TeamShadowsManagerCursorPlacement"
local LEFT_MOUSE_BUTTON = MOUSE_BUTTON_INDEX_LEFT or 1
local RIGHT_MOUSE_BUTTON = MOUSE_BUTTON_INDEX_RIGHT or 2
local MENU_BUTTON_TEXTURE = "TeamShadowsManager/TeamShadowsManagerIcon.dds"

local function TextureHasNativeText(textureId)
    textureId = tonumber(textureId) or 0
    return textureId >= 8
end


local function Clamp(value, minValue, maxValue)
    value = tonumber(value) or minValue
    if value < minValue then return minValue end
    if value > maxValue then return maxValue end
    return value
end

local function CreateLabel(parent, text, font, r, g, b, a)
    local label = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
    label:SetFont(font or "ZoFontGame")
    label:SetColor(r or 1, g or 1, b or 1, a or 1)
    label:SetText(text or "")
    return label
end

function UI:EnsureCursorPlacementControls()
    if self.cursorPlacementOverlay and self.cursorPlacementTexture then return end
    local wm = WINDOW_MANAGER

    self.cursorPlacementOverlay = wm:CreateTopLevelWindow("TeamShadowsManagerCursorPlacementOverlay")
    self.cursorPlacementOverlay:SetAnchorFill(GuiRoot)
    self.cursorPlacementOverlay:SetMouseEnabled(true)
    self.cursorPlacementOverlay:SetMovable(false)
    self.cursorPlacementOverlay:SetClampedToScreen(true)
    self.cursorPlacementOverlay:SetDrawTier(DT_MEDIUM)
    self.cursorPlacementOverlay:SetHidden(true)
    self.cursorPlacementOverlay:SetHandler("OnMouseUp", function(_, button)
        if button == LEFT_MOUSE_BUTTON then
            if PBT.PlaceMarkerFromReticle then
                PBT.PlaceMarkerFromReticle()
            end
            self:StopCursorPlacement()
            if self.managerWindow then
                self.managerWindow:SetHidden(false)
            end
            return true
        elseif button == RIGHT_MOUSE_BUTTON then
            self:StopCursorPlacement()
            return true
        end
    end)

    self.cursorPlacementTexture = wm:CreateTopLevelWindow("TeamShadowsManagerCursorPlacementPreview")
    self.cursorPlacementTexture:SetDimensions(54, 54)
    self.cursorPlacementTexture:SetMouseEnabled(false)
    self.cursorPlacementTexture:SetMovable(false)
    self.cursorPlacementTexture:SetClampedToScreen(false)
    self.cursorPlacementTexture:SetDrawTier(DT_HIGH)
    self.cursorPlacementTexture:SetDrawLayer(DL_OVERLAY)
    self.cursorPlacementTexture:SetDrawLevel(10)
    self.cursorPlacementTexture:SetHidden(true)

    local bg = wm:CreateControl(nil, self.cursorPlacementTexture, CT_BACKDROP)
    bg:SetAnchorFill(self.cursorPlacementTexture)
    bg:SetCenterColor(0, 0, 0, 0.55)
    bg:SetEdgeColor(0.42, 0.76, 1, 0.85)
    bg:SetEdgeTexture("", 1, 1, 1)
    bg:SetMouseEnabled(false)
    self.cursorPlacementTexture.bg = bg

    local texture = wm:CreateControl(nil, self.cursorPlacementTexture, CT_TEXTURE)
    texture:SetAnchor(CENTER, self.cursorPlacementTexture, CENTER, 0, 0)
    texture:SetDimensions(42, 42)
    texture:SetMouseEnabled(false)
    self.cursorPlacementTexture.icon = texture

    local label = CreateLabel(self.cursorPlacementTexture, "", "ZoFontGameBold", 1, 1, 1, 1)
    label:SetAnchor(CENTER, self.cursorPlacementTexture, CENTER, 0, 0)
    label:SetDimensions(54, 36)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetMouseEnabled(false)
    self.cursorPlacementTexture.label = label
end

function UI:UpdateCursorPlacementPreview()
    if not self.cursorPlacementActive or not self.cursorPlacementTexture then return end

    local mouseX, mouseY
    if GetUIMousePosition then
        mouseX, mouseY = GetUIMousePosition()
    end
    if not mouseX or not mouseY then
        mouseX = GuiRoot:GetWidth() / 2
        mouseY = GuiRoot:GetHeight() / 2
    end

    self.cursorPlacementTexture:ClearAnchors()
    self.cursorPlacementTexture:SetAnchor(CENTER, GuiRoot, TOPLEFT, mouseX, mouseY)
end

function UI:StopCursorPlacement()
    self.cursorPlacementActive = false
    self.cursorPlacementChoiceKey = nil
    EVENT_MANAGER:UnregisterForUpdate(CURSOR_PLACEMENT_UPDATE_NAME)

    if self.cursorPlacementOverlay then
        self.cursorPlacementOverlay:SetHidden(true)
    end
    if self.cursorPlacementTexture then
        self.cursorPlacementTexture:SetHidden(true)
    end
    self:RefreshManagerWindow()
end

function UI:StartCursorPlacement(choice)
    if not choice then return end
    self:EnsureCursorPlacementControls()

    self.cursorPlacementActive = true
    self.cursorPlacementChoiceKey = tostring(choice.textureId or "") .. ":" .. tostring(choice.label or "")

    local texturePath = LibTeamShadows and LibTeamShadows.GetMarkerTexture and LibTeamShadows.GetMarkerTexture(choice.textureId) or "TeamShadowsManager/icons/markers/square_red.dds"
    self.cursorPlacementTexture.icon:SetTexture(texturePath)
    self.cursorPlacementTexture.icon:SetDimensions(choice.textureId >= 12 and 46 or 40, choice.textureId >= 12 and 46 or 40)
    self.cursorPlacementTexture.label:SetText((choice.label and not TextureHasNativeText(choice.textureId)) and choice.label or "")
    self.cursorPlacementTexture.label:SetColor(0, 0, 0, 1)
    self.cursorPlacementOverlay:SetHidden(false)
    self.cursorPlacementTexture:SetHidden(false)
    self:UpdateCursorPlacementPreview()

    EVENT_MANAGER:RegisterForUpdate(CURSOR_PLACEMENT_UPDATE_NAME, 16, function()
        self:UpdateCursorPlacementPreview()
    end)
    self:RefreshManagerWindow()
end
function UI:Initialize()
    local wm = WINDOW_MANAGER

    self.window = wm:CreateTopLevelWindow(WINDOW_NAME)
    self.window:SetDimensions(280, 108)
    self.window:SetClampedToScreen(true)
    self.window:SetMouseEnabled(true)
    self.window:SetMovable(false)
    self.window:SetHidden(true)
    self.window:SetDrawTier(DT_HIGH)

    self.backdrop = wm:CreateControl(nil, self.window, CT_BACKDROP)
    self.backdrop:SetAnchorFill(self.window)
    self.backdrop:SetCenterColor(0, 0, 0, 0)
    self.backdrop:SetEdgeColor(1, 1, 1, 0)
    self.backdrop:SetEdgeTexture("", 1, 1, 1)

    self.bossLabel = wm:CreateControl(nil, self.window, CT_LABEL)
    self.bossLabel:SetAnchor(TOP, self.window, TOP, 0, 8)
    self.bossLabel:SetDimensions(260, 24)
    self.bossLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.bossLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.bossLabel:SetFont("ZoFontGameBold")
    self.bossLabel:SetColor(1, 1, 1, 0.95)
    self.bossLabel:SetText("Prebuff")

    self.timerLabel = wm:CreateControl(nil, self.window, CT_LABEL)
    self.timerLabel:SetAnchor(TOP, self.bossLabel, BOTTOM, 0, 0)
    self.timerLabel:SetDimensions(260, 44)
    self.timerLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.timerLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.timerLabel:SetFont("ZoFontWinH1")
    self.timerLabel:SetText("")

    self.portalLabel = wm:CreateControl(nil, self.window, CT_LABEL)
    self.portalLabel:SetAnchor(TOP, self.timerLabel, BOTTOM, 0, -2)
    self.portalLabel:SetDimensions(270, 28)
    self.portalLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.portalLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.portalLabel:SetFont("ZoFontGameBold")
    self.portalLabel:SetColor(1, 1, 1, 0.95)
    self.portalLabel:SetText("")

    self.window:SetHandler("OnMoveStop", function(control)
        if not PBT.savedVars then return end
        PBT.savedVars.x = control:GetLeft() + (control:GetWidth() / 2) - GuiRoot:GetWidth() / 2
        PBT.savedVars.y = control:GetTop() + (control:GetHeight() / 2) - GuiRoot:GetHeight() / 2
    end)

    self.menuButton = wm:CreateTopLevelWindow(MENU_BUTTON_NAME)
    self.menuButton:SetClampedToScreen(true)
    self.menuButton:SetMouseEnabled(true)
    self.menuButton:SetMovable(false)
    self.menuButton:SetHidden(true)
    self.menuButton:SetDrawTier(DT_HIGH)

    self.menuButtonBackdrop = wm:CreateControl(nil, self.menuButton, CT_BACKDROP)
    self.menuButtonBackdrop:SetAnchorFill(self.menuButton)
    self.menuButtonBackdrop:SetCenterColor(0, 0, 0, 0.82)
    self.menuButtonBackdrop:SetEdgeColor(1, 1, 1, 0.55)
    self.menuButtonBackdrop:SetEdgeTexture("", 1, 1, 1)

    self.menuButtonTexture = wm:CreateControl(nil, self.menuButton, CT_TEXTURE)
    self.menuButtonTexture:SetAnchorFill(self.menuButton)
    self.menuButtonTexture:SetTexture(MENU_BUTTON_TEXTURE)
    self.menuButtonTexture:SetAlpha(1)
    self.menuButtonTexture:SetMouseEnabled(false)

    self.menuButtonFallbackLabel = wm:CreateControl(nil, self.menuButton, CT_LABEL)
    self.menuButtonFallbackLabel:SetAnchor(CENTER, self.menuButton, CENTER, 0, 0)
    self.menuButtonFallbackLabel:SetDimensions(64, 24)
    self.menuButtonFallbackLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.menuButtonFallbackLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.menuButtonFallbackLabel:SetFont("ZoFontGameBold")
    self.menuButtonFallbackLabel:SetColor(1, 1, 1, 0.9)
    self.menuButtonFallbackLabel:SetText("")
    self.menuButtonFallbackLabel:SetMouseEnabled(false)

    self.menuButtonHighlight = wm:CreateControl(nil, self.menuButton, CT_TEXTURE)
    self.menuButtonHighlight:SetAnchorFill(self.menuButton)
    self.menuButtonHighlight:SetTexture("/esoui/art/actionbar/actionslot_toggledon.dds")
    self.menuButtonHighlight:SetAlpha(0)
    self.menuButtonHighlight:SetMouseEnabled(false)

    self.menuButton:SetHandler("OnMouseEnter", function(control)
        if self.menuButtonHighlight then
            self.menuButtonHighlight:SetAlpha(0.45)
        end
        if InitializeTooltip and SetTooltipText then
            InitializeTooltip(InformationTooltip, control, TOP, 0, -6)
            SetTooltipText(InformationTooltip, "Team Shadows Manager")
        end
    end)

    self.menuButton:SetHandler("OnMouseExit", function()
        if self.menuButtonHighlight then
            self.menuButtonHighlight:SetAlpha(0)
        end
        if ClearTooltip then
            ClearTooltip(InformationTooltip)
        end
    end)

    self.menuButton:SetHandler("OnMouseUp", function(_, button, upInside)
        if upInside == false then return end
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:ToggleManagerWindow()
        end
    end)

    self.menuButton:SetHandler("OnMoveStop", function(control)
        if not PBT.savedVars then return end
        PBT.savedVars.menuButtonX = control:GetLeft() + (control:GetWidth() / 2) - GuiRoot:GetWidth() / 2
        PBT.savedVars.menuButtonY = control:GetTop() + (control:GetHeight() / 2) - GuiRoot:GetHeight() / 2
    end)

    self:CreateManagerWindow()
end
function UI:SetBackdropVisible(visible)
    if not self.backdrop then return end

    if visible then
        self.backdrop:SetCenterColor(0, 0, 0, 0.45)
        self.backdrop:SetEdgeColor(1, 1, 1, 0.18)
    else
        self.backdrop:SetCenterColor(0, 0, 0, 0)
        self.backdrop:SetEdgeColor(1, 1, 1, 0)
    end
end

function UI:ApplySettings()
    if not self.window or not PBT.savedVars then return end

    local saved = PBT.savedVars
    local color = saved.color or PBT.defaults.color

    self.window:ClearAnchors()
    self.window:SetAnchor(CENTER, GuiRoot, CENTER, saved.x or 0, saved.y or -220)
    self.window:SetScale(Clamp(saved.scale, 0.5, 2.5))
    self.window:SetMovable(saved.unlocked == true)

    self.timerLabel:SetColor(
        Clamp(color.r, 0, 1),
        Clamp(color.g, 0, 1),
        Clamp(color.b, 0, 1),
        Clamp(color.a or 1, 0, 1)
    )

    if saved.unlocked and self.window:IsHidden() then
        self:ShowIdle()
    end

    self:ApplyMenuButtonSettings()

end

function UI:ApplyMenuButtonSettings()
    if not self.menuButton or not PBT.savedVars then return end

    local saved = PBT.savedVars
    local size = Clamp(saved.menuButtonSize, 28, 96)

    self.menuButton:SetDimensions(size, size)
    self.menuButton:ClearAnchors()
    self.menuButton:SetAnchor(CENTER, GuiRoot, CENTER, saved.menuButtonX or 0, saved.menuButtonY or 0)
    self.menuButton:SetMovable(saved.unlocked == true)
    self.menuButton:SetHidden(saved.menuButtonEnabled == false)
end

function UI:SetUnlocked(unlocked)
    if not PBT.savedVars then return end

    PBT.savedVars.unlocked = unlocked == true
    self:ApplySettings()

    if PBT.savedVars.unlocked then
        self:ShowIdle()
    elseif not PBT.isRunning and not PBT.portalStatusActive then
        self:Hide()
    end
end

function UI:ShowIdle()
    if not self.window then return end
    self:SetBackdropVisible(true)
    self.bossLabel:SetText("Team Shadows Manager")
    self.timerLabel:SetText("MOVE")
    if self.portalLabel then
        self.portalLabel:SetText("")
    end
    self.window:SetHidden(false)
end

function UI:ShowCountdown(bossName, secondsRemaining)
    if not self.window then return end

    local color = (PBT.savedVars and PBT.savedVars.color) or (PBT.defaults and PBT.defaults.color) or { r = 1, g = 0.12, b = 0.08, a = 1 }
    self:SetBackdropVisible(false)
    self.bossLabel:SetText(bossName or "Prebuff")
    self.timerLabel:SetColor(Clamp(color.r, 0, 1), Clamp(color.g, 0, 1), Clamp(color.b, 0, 1), Clamp(color.a or 1, 0, 1))
    self.timerLabel:SetText(tostring(secondsRemaining or ""))
    if self.portalLabel and not PBT.portalStatusActive then
        self.portalLabel:SetText("")
    end
    self.window:SetHidden(false)
end

function UI:ShowGo(bossName)
    if not self.window then return end

    local color = (PBT.savedVars and PBT.savedVars.goColor) or (PBT.defaults and PBT.defaults.goColor) or { r = 0.2, g = 1, b = 0.2, a = 1 }
    self:SetBackdropVisible(false)
    self.bossLabel:SetText(bossName or "Prebuff")
    self.timerLabel:SetColor(Clamp(color.r, 0, 1), Clamp(color.g, 0, 1), Clamp(color.b, 0, 1), Clamp(color.a or 1, 0, 1))
    self.timerLabel:SetText("GO")
    if self.portalLabel and not PBT.portalStatusActive then
        self.portalLabel:SetText("")
    end
    self.window:SetHidden(false)
end

function UI:ShowPortalStatus(text, r, g, b)
    if not self.window or not self.portalLabel then return end

    PBT.portalStatusActive = true
    self:SetBackdropVisible(false)
    self.portalLabel:SetText(text or "")
    self.portalLabel:SetColor(Clamp(r, 0, 1), Clamp(g, 0, 1), Clamp(b, 0, 1), 1)

    if not PBT.isRunning then
        self.bossLabel:SetText("Nahviintaas")
        self.timerLabel:SetText("PORTAIL")
        self.timerLabel:SetColor(1, 1, 1, 0.95)
    end

    self.window:SetHidden(false)
end

function UI:ShowMarkerReadyAlert()
    if not self.window then return end

    self:SetBackdropVisible(false)
    self.bossLabel:SetText("TEAM SHADOWS")
    self.timerLabel:SetColor(0.2, 0.9, 1, 1)
    self.timerLabel:SetText("PLACER ICON")
    if self.portalLabel then
        self.portalLabel:SetText("PRET")
        self.portalLabel:SetColor(0.3, 1, 0.3, 1)
    end
    self.window:SetHidden(false)
end

function UI:HidePortalStatus()
    PBT.portalStatusActive = false

    if self.portalLabel then
        self.portalLabel:SetText("")
    end

    if self.window and not PBT.isRunning and not (PBT.savedVars and PBT.savedVars.unlocked) then
        self.window:SetHidden(true)
    end
end

function UI:Hide()
    if not self.window then return end

    if PBT.portalStatusActive then
        self.window:SetHidden(false)
        return
    end

    self.window:SetHidden(true)
end

function PBT.SetScale(value)
    if not PBT.savedVars then return false end

    local scale = Clamp(value, 0.5, 2.5)
    PBT.savedVars.scale = scale
    UI:ApplySettings()
    return true, scale
end

function PBT.SetColor(r, g, b)
    if not PBT.savedVars then return false end

    PBT.savedVars.color = {
        r = Clamp(r, 0, 1),
        g = Clamp(g, 0, 1),
        b = Clamp(b, 0, 1),
        a = 1,
    }

    UI:ApplySettings()
    return true, PBT.savedVars.color
end


-- =====================================================================
--  FENETRE DE GESTION MODERNE (style BuffsManager)
--  Reutilise les noms de methodes existants (CreateManagerWindow,
--  ShowManagerWindow, ToggleManagerWindow, RefreshManagerWindow) et le
--  champ self.managerWindow : tous les appels existants (logo, /shadows,
--  placement) ouvrent donc directement cette fenetre.
-- =====================================================================
local WM = WINDOW_MANAGER

local MC = {
    panel    = { 0.05, 0.06, 0.08, 0.97 }, card    = { 0.09, 0.10, 0.13, 0.95 },
    cardEdge = { 0.16, 0.18, 0.22, 1.0 },  gold    = { 0.79, 0.63, 0.18, 1.0 },
    cyan     = { 0.28, 0.68, 0.90, 1.0 },  blue    = { 0.18, 0.50, 0.93, 1.0 },
    text     = { 0.86, 0.88, 0.92, 1.0 },  textDim = { 0.55, 0.58, 0.64, 1.0 },
    track    = { 0.18, 0.20, 0.24, 1.0 },
}
local MF_TITLE, MF_HEADER, MF_LABEL, MF_SMALL = "ZoFontWinH2", "ZoFontWinH4", "ZoFontGameBold", "ZoFontGameSmall"

local MTABS = {
    { id = "markers", label = "MARKERS" },
    { id = "pull",    label = "DÉCOMPTE & ANNONCE" },
    { id = "timers",  label = "TIMERS & MANNEQUIN" },
}
local activeManagerTab = "markers"

local QUICK_ICONS = {
    { name = "F", id = 10 }, { name = "FV", id = 11 }, { name = "MT", id = 8 }, { name = "OT", id = 9 },
    { name = "H1", id = 1, label = "H1" }, { name = "H2", id = 1, label = "H2" },
    { name = "1", id = 1, label = "1" }, { name = "2", id = 1, label = "2" }, { name = "3", id = 1, label = "3" },
    { name = "4", id = 1, label = "4" }, { name = "5", id = 1, label = "5" }, { name = "6", id = 1, label = "6" },
    { name = "7", id = 1, label = "7" }, { name = "8", id = 1, label = "8" }, { name = "9", id = 1, label = "9" },
    { name = "10", id = 1, label = "10" }, { name = "S", id = 12 }, { name = "Buche", id = 13 }, { name = "Fish", id = 14 },
    { name = "Hyxtra", id = 15 }, { name = "Lexi", id = 16 }, { name = "Og", id = 17 }, { name = "Ogu", id = 18 },
    { name = "Ray", id = 19 }, { name = "Ronce", id = 20 }, { name = "Sel", id = 21 }, { name = "Sla", id = 22 }, { name = "Tim", id = 23 },
}
local ICON_COLORS = {
    [1] = { r = 0.85, g = 0.05, b = 0.04 }, [2] = { r = 0.05, g = 0.28, b = 0.95 },
    [3] = { r = 1.0, g = 0.86, b = 0.05 },  [4] = { r = 0.05, g = 0.75, b = 0.15 },
    [5] = { r = 1.0, g = 0.5, b = 0.05 },   [6] = { r = 1.0, g = 0.15, b = 0.75 },
    [7] = { r = 0.45, g = 0.85, b = 1.0 },
}
local MLABEL_ORDER = { "auto", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "H1", "H2", "MT", "OT" }
local MARKER_ROWS = 6
local M_FALLBACK_TEX = "TeamShadowsManager/icons/markers/square_red.dds"

local function unpack4(c) return c[1], c[2], c[3], c[4] end
local function SV() return PBT.savedVars or {} end
local function mclamp(v, lo, hi) v = tonumber(v) or lo; if v < lo then return lo elseif v > hi then return hi else return v end end
local function MarkerTexture(id) return (LibTeamShadows and LibTeamShadows.GetMarkerTexture and LibTeamShadows.GetMarkerTexture(id)) or M_FALLBACK_TEX end
local function MLabelText(labelId) return (LibTeamShadows and LibTeamShadows.GetMarkerLabel and LibTeamShadows.GetMarkerLabel(labelId)) or tostring(labelId) end
local function RefreshWorld() if PBT.RefreshSavedMarkers then PBT.RefreshSavedMarkers() end end

local function Backdrop(parent, color, edge)
    local b = WM:CreateControl(nil, parent, CT_BACKDROP)
    b:SetCenterColor(unpack4(color))
    b:SetEdgeColor(edge and edge[1] or 0, edge and edge[2] or 0, edge and edge[3] or 0, edge and edge[4] or 0)
    b:SetEdgeTexture("", 1, 1, 1)
    return b
end
local function MLabel(parent, font, color, text, align)
    local l = WM:CreateControl(nil, parent, CT_LABEL)
    l:SetFont(font); l:SetColor(unpack4(color))
    if text then l:SetText(text) end
    if align then l:SetHorizontalAlignment(align) end
    return l
end
local function FlatButton(parent, text, w, h, onClick, bgColor, txtColor)
    local btn = WM:CreateControl(nil, parent, CT_CONTROL)
    btn:SetDimensions(w, h); btn:SetMouseEnabled(true)
    btn.bg = Backdrop(btn, bgColor or MC.card, MC.cardEdge); btn.bg:SetAnchorFill(btn)
    btn.label = MLabel(btn, MF_LABEL, txtColor or MC.text, text, TEXT_ALIGN_CENTER)
    btn.label:SetAnchor(CENTER, btn, CENTER, 0, 0)
    btn.baseColor = bgColor or MC.card
    btn:SetHandler("OnMouseEnter", function() btn.bg:SetCenterColor(unpack4(MC.cardEdge)) end)
    btn:SetHandler("OnMouseExit",  function() btn.bg:SetCenterColor(unpack4(btn.baseColor)) end)
    btn:SetHandler("OnMouseUp", function(_, _, upInside) if upInside and onClick then onClick() end end)
    return btn
end
local function MakeCard(parent, title)
    local card = WM:CreateControl(nil, parent, CT_CONTROL)
    card.bg = Backdrop(card, MC.card, MC.cardEdge); card.bg:SetAnchorFill(card)
    card.title = MLabel(card, MF_HEADER, MC.cyan, title)
    card.title:SetAnchor(TOPLEFT, card, TOPLEFT, 18, 12)
    card.content = WM:CreateControl(nil, card, CT_CONTROL)
    card.content:SetAnchor(TOPLEFT, card, TOPLEFT, 18, 42)
    card.content:SetAnchor(BOTTOMRIGHT, card, BOTTOMRIGHT, -18, -12)
    return card
end
local function MakeToggle(parent, getFunc, setFunc)
    local W, H = 44, 22
    local tg = WM:CreateControl(nil, parent, CT_CONTROL)
    tg:SetDimensions(W, H); tg:SetMouseEnabled(true)
    tg.track = Backdrop(tg, MC.track); tg.track:SetAnchorFill(tg)
    tg.knob  = Backdrop(tg, { 0.95, 0.96, 0.98, 1 }); tg.knob:SetDimensions(H - 6, H - 6)
    local function redraw()
        local on = getFunc() == true
        tg.track:SetCenterColor(on and MC.blue[1] or MC.track[1], on and MC.blue[2] or MC.track[2], on and MC.blue[3] or MC.track[3], 1)
        tg.knob:ClearAnchors()
        if on then tg.knob:SetAnchor(RIGHT, tg, RIGHT, -3, 0) else tg.knob:SetAnchor(LEFT, tg, LEFT, 3, 0) end
    end
    tg:SetHandler("OnMouseUp", function(_, _, upInside) if upInside then setFunc(getFunc() ~= true); redraw() end end)
    tg.Redraw = redraw; redraw()
    return tg
end
local function MakeSwatch(parent, getFunc, setFunc)
    local sw = WM:CreateControl(nil, parent, CT_CONTROL)
    sw:SetDimensions(48, 26); sw:SetMouseEnabled(true)
    sw.bg = Backdrop(sw, { 1, 1, 1, 1 }, MC.cardEdge); sw.bg:SetAnchorFill(sw)
    local function redraw()
        local c = getFunc() or {}
        sw.bg:SetCenterColor(c.r or c[1] or 1, c.g or c[2] or 1, c.b or c[3] or 1, 1)
    end
    sw:SetHandler("OnMouseUp", function(_, _, upInside)
        if not upInside or not COLOR_PICKER then return end
        local c = getFunc() or {}
        COLOR_PICKER:Show(function(r, g, b, a) setFunc(r, g, b, a or 1); redraw() end,
            c.r or c[1] or 1, c.g or c[2] or 1, c.b or c[3] or 1, c.a or 1, "Couleur")
    end)
    sw.Redraw = redraw; redraw()
    return sw
end
local function MakeSlider(parent, width, minV, maxV, step, getFunc, setFunc, suffix)
    local sl = WM:CreateControl(nil, parent, CT_CONTROL)
    sl:SetDimensions(width, 22); sl:SetMouseEnabled(true)
    local trackW = width - 44
    sl.track = Backdrop(sl, MC.track); sl.track:SetDimensions(trackW, 6); sl.track:SetAnchor(LEFT, sl, LEFT, 0, 0)
    sl.fill  = Backdrop(sl.track, MC.blue); sl.fill:SetAnchor(LEFT, sl.track, LEFT, 0, 0); sl.fill:SetHeight(6)
    sl.knob  = Backdrop(sl.track, { 0.95, 0.96, 0.98, 1 }); sl.knob:SetDimensions(13, 13)
    sl.value = MLabel(sl, MF_SMALL, MC.text, "", TEXT_ALIGN_RIGHT); sl.value:SetAnchor(RIGHT, sl, RIGHT, 0, 0); sl.value:SetDimensions(40, 22)
    local function ratioToVal(r) local v = minV + (maxV - minV) * r; if step and step > 0 then v = zo_round(v / step) * step end; return mclamp(v, minV, maxV) end
    local function redraw()
        local v = getFunc() or minV
        local ratio = (maxV > minV) and mclamp((v - minV) / (maxV - minV), 0, 1) or 0
        sl.fill:SetWidth(zo_max(1, trackW * ratio))
        sl.knob:ClearAnchors(); sl.knob:SetAnchor(CENTER, sl.track, LEFT, trackW * ratio, 0)
        sl.value:SetText(((step and step < 1) and string.format("%.2f", v) or tostring(zo_round(v))) .. (suffix or ""))
    end
    local function setFromCursor()
        local mx = GetUIMousePosition and GetUIMousePosition() or 0
        local left = sl.track:GetLeft() or 0
        local w = sl.track:GetWidth() or trackW
        if w <= 0 then w = trackW end
        setFunc(ratioToVal(mclamp((mx - left) / w, 0, 1))); redraw()
    end
    sl:SetHandler("OnMouseDown", function() sl.dragging = true; setFromCursor() end)
    sl:SetHandler("OnMouseUp",   function() sl.dragging = false end)
    sl:SetHandler("OnUpdate",    function() if sl.dragging then setFromCursor() end end)
    sl.Redraw = redraw; redraw()
    return sl
end
local function MakeEditbox(parent, width, getFunc, setFunc, maxChars)
    local box = WM:CreateControl(nil, parent, CT_CONTROL)
    box:SetDimensions(width, 30); box:SetMouseEnabled(true)
    box.bg = Backdrop(box, { 0.04, 0.05, 0.07, 1 }, MC.cardEdge); box.bg:SetAnchorFill(box)
    box.edit = WM:CreateControl(nil, box, CT_EDITBOX)
    box.edit:SetAnchor(TOPLEFT, box, TOPLEFT, 10, 0); box.edit:SetAnchor(BOTTOMRIGHT, box, BOTTOMRIGHT, -10, 0)
    box.edit:SetFont(MF_LABEL); box.edit:SetColor(unpack4(MC.text))
    box.edit:SetMaxInputChars(maxChars or 40); box.edit:SetMouseEnabled(true)
    if box.edit.SetEditEnabled then box.edit:SetEditEnabled(true) end
    box.edit:SetText(getFunc() or "")
    local function focus() box.edit:TakeFocus() end
    box.edit:SetHandler("OnMouseUp", focus); box:SetHandler("OnMouseUp", focus)
    box.edit:SetHandler("OnTextChanged", function(self) if setFunc then setFunc(self:GetText() or "") end end)
    box.edit:SetHandler("OnEnter",  function(self) self:LoseFocus() end)
    box.edit:SetHandler("OnEscape", function(self) self:LoseFocus() end)
    box.Redraw = function()
        if box.edit.HasFocus and box.edit:HasFocus() then return end
        box.edit:SetText(getFunc() or "")
    end
    return box
end

-- etat marker edite (nil = valeurs par defaut)
local editIndex, selectedIndex, markerPage = nil, nil, 1
local function EditingMarker()
    local list = SV().groupBeaconSavedMarkers or {}
    if editIndex and list[editIndex] then return list[editIndex] end
    editIndex = nil; return nil
end
local function GetTexId() local m = EditingMarker(); return mclamp((m and m.textureId) or SV().groupBeaconTextureId, 1, 23) end
local function GetCurLabel() local m = EditingMarker(); if m and m.labelId then return MLabelText(m.labelId) end; return SV().groupBeaconLabel or "auto" end
local function GetColor() local m = EditingMarker(); return (m and m.color) or SV().groupBeaconColor or ICON_COLORS[1] end
local function GetSize() local m = EditingMarker(); return (m and m.size) or SV().groupBeaconSize or 112 end
local function GetDuration() local m = EditingMarker(); return (m and m.durationMs and m.durationMs / 1000) or SV().groupBeaconDuration or 8 end
local function GetHeight() local m = EditingMarker(); return (m and m.heightOffset) or SV().groupBeaconHeight or 0 end

local function ApplyQuickIcon(choice)
    if not PBT.savedVars then return end
    local m = EditingMarker()
    local labelId = choice.label and PBT.beaconLabelIds and PBT.beaconLabelIds[choice.label] or nil
    if m and PBT.UpdateSavedMarker then
        PBT.UpdateSavedMarker(editIndex, { textureId = choice.id })
        if labelId then PBT.UpdateSavedMarker(editIndex, { labelId = labelId }) end
        if choice.id >= 12 then PBT.UpdateSavedMarker(editIndex, { size = (PBT.defaults and PBT.defaults.groupBeaconSize) or 112 }) end
    else
        SV().groupBeaconTextureId = choice.id
        SV().groupBeaconLabel = choice.label or "auto"
        if ICON_COLORS[choice.id] then SV().groupBeaconColor = ICON_COLORS[choice.id] end
        if choice.id >= 12 then SV().groupBeaconSize = (PBT.defaults and PBT.defaults.groupBeaconSize) or 112 end
    end
    UI:RefreshManagerWindow()
end
local function CycleLabel()
    local cur, nxt = GetCurLabel(), nil
    for i, v in ipairs(MLABEL_ORDER) do if v == cur then nxt = MLABEL_ORDER[(i % #MLABEL_ORDER) + 1] break end end
    nxt = nxt or "auto"
    local m = EditingMarker()
    if m and PBT.UpdateSavedMarker then
        local labelId = PBT.beaconLabelIds and PBT.beaconLabelIds[nxt] or nil
        if labelId then PBT.UpdateSavedMarker(editIndex, { labelId = labelId }) end
    else
        SV().groupBeaconLabel = nxt
    end
    UI:RefreshManagerWindow()
end
local function SetColorVal(r, g, b)
    local m = EditingMarker()
    if m and PBT.UpdateSavedMarker then PBT.UpdateSavedMarker(editIndex, { color = { r = r, g = g, b = b } })
    else SV().groupBeaconColor = { r = r, g = g, b = b }; RefreshWorld() end
end
local function SetSizeVal(v)
    local m = EditingMarker()
    if m and PBT.UpdateSavedMarker then PBT.UpdateSavedMarker(editIndex, { size = v }) else SV().groupBeaconSize = v; RefreshWorld() end
end
local function SetDurationVal(v)
    local m = EditingMarker()
    if m and PBT.UpdateSavedMarker then PBT.UpdateSavedMarker(editIndex, { durationMs = v * 1000 }) else SV().groupBeaconDuration = v; RefreshWorld() end
end
local function SetHeightVal(v)
    local m = EditingMarker()
    if m and PBT.UpdateSavedMarker then PBT.UpdateSavedMarker(editIndex, { heightOffset = v })
    else SV().groupBeaconHeight = v; for _, mk in ipairs(SV().groupBeaconSavedMarkers or {}) do mk.heightOffset = v end; RefreshWorld() end
end

-- ---------------- onglet MARKERS ----------------
local function BuildMarkersTab(pane)
    pane.widgets = {}
    local function track(w) table.insert(pane.widgets, w); return w end

    local cfg = MakeCard(pane, "MARKER ACTIF")
    cfg:SetAnchor(TOPLEFT, pane, TOPLEFT, 0, 0); cfg:SetDimensions(416, 300)
    local c = cfg.content

    pane.previewBg = Backdrop(c, { 0.015, 0.018, 0.022, 1 }, MC.cardEdge)
    pane.previewBg:SetDimensions(86, 86); pane.previewBg:SetAnchor(TOPLEFT, c, TOPLEFT, 0, 4)
    pane.previewTex = WM:CreateControl(nil, c, CT_TEXTURE)
    pane.previewTex:SetDimensions(70, 70); pane.previewTex:SetAnchor(CENTER, pane.previewBg, CENTER, 0, 0)
    pane.previewLbl = MLabel(c, "ZoFontWinH1", { 1, 1, 1, 1 }, "1", TEXT_ALIGN_CENTER)
    pane.previewLbl:SetAnchor(CENTER, pane.previewTex, CENTER, 0, 0); pane.previewLbl:SetDimensions(80, 50)
    pane.previewLbl:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    pane.editBanner = MLabel(c, MF_SMALL, MC.gold, "")
    pane.editBanner:SetAnchor(TOPLEFT, pane.previewBg, BOTTOMLEFT, 0, 8); pane.editBanner:SetWidth(120)

    local rx = 110
    MLabel(c, MF_SMALL, MC.textDim, "Texte / rôle"):SetAnchor(TOPLEFT, c, TOPLEFT, rx, 0)
    pane.labelBtn = track(FlatButton(c, "Auto 1-10", 160, 26, CycleLabel)); pane.labelBtn:SetAnchor(TOPLEFT, c, TOPLEFT, rx, 16)
    MLabel(c, MF_SMALL, MC.textDim, "Couleur"):SetAnchor(TOPLEFT, c, TOPLEFT, rx + 180, 0)
    track(MakeSwatch(c, GetColor, SetColorVal)):SetAnchor(TOPLEFT, c, TOPLEFT, rx + 180, 16)
    MLabel(c, MF_SMALL, MC.textDim, "Taille"):SetAnchor(TOPLEFT, c, TOPLEFT, rx, 50)
    track(MakeSlider(c, 260, 24, 160, 2, GetSize, SetSizeVal)):SetAnchor(TOPLEFT, c, TOPLEFT, rx, 66)
    MLabel(c, MF_SMALL, MC.textDim, "Durée"):SetAnchor(TOPLEFT, c, TOPLEFT, rx, 92)
    track(MakeSlider(c, 260, 1, 60, 1, GetDuration, SetDurationVal, "s")):SetAnchor(TOPLEFT, c, TOPLEFT, rx, 108)
    MLabel(c, MF_SMALL, MC.textDim, "Hauteur"):SetAnchor(TOPLEFT, c, TOPLEFT, rx, 134)
    track(MakeSlider(c, 260, -30, 40, 0.5, GetHeight, SetHeightVal)):SetAnchor(TOPLEFT, c, TOPLEFT, rx, 150)

    MLabel(c, MF_SMALL, MC.text, "Placement activé"):SetAnchor(TOPLEFT, c, TOPLEFT, 0, 180)
    track(MakeToggle(c, function() return SV().groupBeaconPlacementEnabled == true end,
        function(v) SV().groupBeaconPlacementEnabled = v end)):SetAnchor(TOPLEFT, c, TOPLEFT, 150, 178)
    track(FlatButton(c, "PLACER (visée réticule)", 195, 30, function()
        SV().groupBeaconPlacementEnabled = true
        if PBT.PlaceMarkerFromReticle then PBT.PlaceMarkerFromReticle() end
        editIndex = nil; selectedIndex = nil; UI:RefreshManagerWindow()
    end, { 0.12, 0.30, 0.55, 1 }, MC.text)):SetAnchor(TOPLEFT, c, TOPLEFT, 0, 210)
    track(FlatButton(c, "VIDER L'ÉCRAN", 165, 30, function()
        if PBT.ClearSavedMarkers then PBT.ClearSavedMarkers() end
        editIndex = nil; selectedIndex = nil; UI:RefreshManagerWindow()
    end, { 0.30, 0.12, 0.12, 1 }, MC.text)):SetAnchor(TOPLEFT, c, TOPLEFT, 205, 210)

    local grid = MakeCard(pane, "ICÔNES")
    grid:SetAnchor(TOPLEFT, cfg, TOPRIGHT, 14, 0); grid:SetDimensions(532, 300)
    local g = grid.content
    pane.iconCells = {}
    local cols, cw, ch, gap = 9, 52, 50, 3
    for i, choice in ipairs(QUICK_ICONS) do
        local col, rowi = (i - 1) % cols, math.floor((i - 1) / cols)
        local cell = WM:CreateControl(nil, g, CT_CONTROL)
        cell:SetDimensions(cw, ch); cell:SetAnchor(TOPLEFT, g, TOPLEFT, col * (cw + gap), rowi * (ch + gap)); cell:SetMouseEnabled(true)
        cell.bg = Backdrop(cell, { 0.04, 0.05, 0.07, 1 }, MC.cardEdge); cell.bg:SetAnchorFill(cell)
        cell.tex = WM:CreateControl(nil, cell, CT_TEXTURE)
        cell.tex:SetDimensions(28, 28); cell.tex:SetAnchor(TOP, cell, TOP, 0, 4); cell.tex:SetTexture(MarkerTexture(choice.id))
        cell.lbl = MLabel(cell, MF_SMALL, MC.textDim, choice.name, TEXT_ALIGN_CENTER)
        cell.lbl:SetAnchor(BOTTOM, cell, BOTTOM, 0, -3); cell.lbl:SetWidth(cw)
        cell.choice = choice
        cell:SetHandler("OnMouseEnter", function() if not cell.selected then cell.bg:SetEdgeColor(unpack4(MC.cyan)) end end)
        cell:SetHandler("OnMouseExit",  function() if not cell.selected then cell.bg:SetEdgeColor(unpack4(MC.cardEdge)) end end)
        cell:SetHandler("OnMouseUp", function(_, _, upInside) if upInside then ApplyQuickIcon(choice) end end)
        pane.iconCells[i] = cell
    end

    local listCard = MakeCard(pane, "MARKERS ENREGISTRÉS")
    listCard:SetAnchor(TOPLEFT, cfg, BOTTOMLEFT, 0, 14); listCard:SetDimensions(416, 282)
    local lc = listCard.content
    pane.listInfo = MLabel(lc, MF_SMALL, MC.textDim, "0 marker"); pane.listInfo:SetAnchor(TOPLEFT, lc, TOPLEFT, 0, 0)
    -- pagination en haut a droite (comme l'ancienne fenetre)
    pane.nextBtn = FlatButton(lc, ">", 30, 22, function() markerPage = markerPage + 1; UI:RefreshList() end)
    pane.nextBtn:SetAnchor(TOPRIGHT, lc, TOPRIGHT, 0, -2)
    pane.prevBtn = FlatButton(lc, "<", 30, 22, function() markerPage = math.max(1, markerPage - 1); UI:RefreshList() end)
    pane.prevBtn:SetAnchor(RIGHT, pane.nextBtn, LEFT, -6, 0)
    pane.rows = {}
    for i = 1, MARKER_ROWS do
        local row = WM:CreateControl(nil, lc, CT_CONTROL)
        row:SetDimensions(380, 26); row:SetAnchor(TOPLEFT, lc, TOPLEFT, 0, 20 + (i - 1) * 30); row:SetMouseEnabled(true)
        row.bg = Backdrop(row, { 0.04, 0.05, 0.07, 1 }, MC.cardEdge); row.bg:SetAnchorFill(row)
        row.badge = WM:CreateControl(nil, row, CT_TEXTURE); row.badge:SetDimensions(20, 20); row.badge:SetAnchor(LEFT, row, LEFT, 8, 0)
        row.txt = MLabel(row, MF_SMALL, MC.text, ""); row.txt:SetAnchor(LEFT, row.badge, RIGHT, 8, 0); row.txt:SetWidth(328)
        row:SetHandler("OnMouseUp", function(_, _, upInside)
            if not upInside then return end
            local idx = ((markerPage - 1) * MARKER_ROWS) + i
            local list = SV().groupBeaconSavedMarkers or {}
            selectedIndex = list[idx] and idx or nil   -- clic = selection seule
            UI:RefreshList()
        end)
        row:SetHandler("OnMouseWheel", function(_, delta)
            local list = SV().groupBeaconSavedMarkers or {}
            local maxPage = math.max(1, math.ceil(#list / MARKER_ROWS))
            markerPage = mclamp(markerPage - delta, 1, maxPage); UI:RefreshList()
        end)
        pane.rows[i] = row
    end
    -- barre d'actions : MODIFIER / FIN MODIF / SUPPRIMER
    pane.editBtn = FlatButton(lc, "MODIFIER", 120, 26, function()
        local list = SV().groupBeaconSavedMarkers or {}
        if selectedIndex and list[selectedIndex] then editIndex = selectedIndex; UI:RefreshManagerWindow() end
    end, { 0.12, 0.30, 0.55, 1 }, MC.text)
    pane.editBtn:SetAnchor(BOTTOMLEFT, lc, BOTTOMLEFT, 0, 0)
    pane.doneBtn = FlatButton(lc, "FIN MODIF", 120, 26, function()
        editIndex = nil; selectedIndex = nil; UI:RefreshManagerWindow()
    end)
    pane.doneBtn:SetAnchor(LEFT, pane.editBtn, RIGHT, 8, 0)
    pane.delBtn = FlatButton(lc, "SUPPRIMER", 120, 26, function()
        if selectedIndex and PBT.DeleteSavedMarker then PBT.DeleteSavedMarker(selectedIndex) end
        selectedIndex = nil; editIndex = nil; UI:RefreshManagerWindow()
    end, { 0.30, 0.12, 0.12, 1 }, MC.text)
    pane.delBtn:SetAnchor(LEFT, pane.doneBtn, RIGHT, 8, 0)

    local packCard = MakeCard(pane, "PACKS & PARTAGE")
    packCard:SetAnchor(TOPLEFT, grid, BOTTOMLEFT, 0, 14); packCard:SetDimensions(532, 282)
    local pc = packCard.content
    pane.packCells = {}
    for slot = 1, 3 do
        local cell = FlatButton(pc, "Pack " .. slot, 110, 28, function()
            editIndex = nil
            if PBT.ActivateCurrentMarkerSet then PBT.ActivateCurrentMarkerSet(slot) else SV().groupBeaconMarkerSetSlot = slot end
            UI:RefreshManagerWindow()
        end)
        cell:SetAnchor(TOPLEFT, pc, TOPLEFT, (slot - 1) * 120, 0); cell.slot = slot
        pane.packCells[slot] = cell
        local nameBox = track(MakeEditbox(pc, 110, function() return PBT.GetMarkerPackName and PBT.GetMarkerPackName(slot) or ("Pack " .. slot) end, nil, 24))
        nameBox:SetAnchor(TOPLEFT, pc, TOPLEFT, (slot - 1) * 120, 32)
        nameBox.edit:SetHandler("OnFocusLost", function(self)
            if PBT.RenameMarkerPack then PBT.RenameMarkerPack(slot, self:GetText()) end
            UI:RefreshManagerWindow()
        end)
    end
    pane.shareBox = MakeEditbox(pc, 470, function() return "" end, nil, 6000)
    pane.shareBox:SetAnchor(TOPLEFT, pc, TOPLEFT, 0, 72); pane.shareBox:SetHeight(96)
    if pane.shareBox.edit.SetMultiLine then pane.shareBox.edit:SetMultiLine(true) end
    FlatButton(pc, "EXPORTER", 118, 30, function()
        local slot = SV().groupBeaconMarkerSetSlot
        local code = (PBT.ExportCurrentMarkerSet and PBT.ExportCurrentMarkerSet(slot)) or (PBT.ExportSavedMarkers and PBT.ExportSavedMarkers()) or ""
        pane.shareBox.edit:SetText(code); pane.shareBox.edit:TakeFocus()
        if pane.shareBox.edit.SelectAll then pane.shareBox.edit:SelectAll() end
    end, { 0.12, 0.30, 0.55, 1 }, MC.text):SetAnchor(TOPLEFT, pc, TOPLEFT, 0, 180)
    FlatButton(pc, "IMPORTER", 118, 30, function()
        local txt = pane.shareBox.edit:GetText()
        if PBT.ImportCurrentMarkerSet then PBT.ImportCurrentMarkerSet(txt) elseif PBT.ImportSavedMarkers then PBT.ImportSavedMarkers(txt) end
        editIndex = nil; selectedIndex = nil; UI:RefreshManagerWindow()
    end, { 0.12, 0.40, 0.20, 1 }, MC.text):SetAnchor(TOPLEFT, pc, TOPLEFT, 126, 180)
    FlatButton(pc, "SAUVER PACK", 118, 30, function()
        editIndex = nil
        if PBT.SaveCurrentMarkerSet then
            local _, msg = PBT.SaveCurrentMarkerSet()
            if msg then d("|c88ff88TSM:|r " .. tostring(msg)) end
        end
        UI:RefreshManagerWindow()
    end, { 0.12, 0.40, 0.20, 1 }, MC.text):SetAnchor(TOPLEFT, pc, TOPLEFT, 252, 180)
    local delPackBtn
    local delPackPending = false
    local function ResetDelPackBtn()
        delPackPending = false
        if delPackBtn then
            delPackBtn.label:SetText("SUPPR. PACK")
            delPackBtn.bg:SetCenterColor(unpack4(delPackBtn.baseColor))
        end
    end
    delPackBtn = FlatButton(pc, "SUPPR. PACK", 118, 30, function()
        if not delPackPending then
            -- premiere pression: demande de confirmation pendant 3 s
            delPackPending = true
            delPackBtn.label:SetText("CONFIRMER ?")
            delPackBtn.bg:SetCenterColor(0.55, 0.10, 0.10, 1)
            zo_callLater(function() if delPackPending then ResetDelPackBtn() end end, 3000)
            return
        end
        ResetDelPackBtn()
        editIndex = nil; selectedIndex = nil
        if PBT.DeleteCurrentMarkerSet then
            local _, msg = PBT.DeleteCurrentMarkerSet()
            if msg then d("|cff8888TSM:|r " .. tostring(msg)) end
        end
        UI:RefreshManagerWindow()
    end, { 0.30, 0.12, 0.12, 1 }, MC.text)
    delPackBtn:SetAnchor(TOPLEFT, pc, TOPLEFT, 378, 180)
end

-- ---------------- onglet DECOMPTE & ANNONCE ----------------
local function BuildPullTab(pane)
    pane.widgets = {}
    local function track(w) table.insert(pane.widgets, w); return w end
    local function toggleRow(parent, label, x, y, getF, setF)
        local t = track(MakeToggle(parent, getF, setF)); t:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
        MLabel(parent, MF_SMALL, MC.text, label):SetAnchor(LEFT, t, RIGHT, 8, 0)
    end
    local function sliderRow(parent, label, x, y, w, minV, maxV, step, key, suffix)
        MLabel(parent, MF_SMALL, MC.textDim, label):SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
        track(MakeSlider(parent, w, minV, maxV, step, function() return tonumber(SV()[key]) or minV end,
            function(v) SV()[key] = v end, suffix)):SetAnchor(TOPLEFT, parent, TOPLEFT, x, y + 18)
    end

    local pull = MakeCard(pane, "DÉCOMPTE GROUPE")
    pull:SetAnchor(TOPLEFT, pane, TOPLEFT, 0, 0); pull:SetDimensions(470, 230)
    local p = pull.content
    toggleRow(p, "Décompte activé", 0, 4, function() return SV().groupCountdownEnabled ~= false end, function(v) SV().groupCountdownEnabled = v end)
    toggleRow(p, "Diffuser au groupe", 240, 4, function() return SV().groupCountdownBroadcast ~= false end, function(v) SV().groupCountdownBroadcast = v end)
    sliderRow(p, "Durée du décompte", 0, 40, 200, 0, 20, 1, "groupCountdownSeconds", "s")
    sliderRow(p, "Mon délai (local)", 240, 40, 200, -10, 10, 0.1, "groupCountdownDpsDelay", "s")
    track(FlatButton(p, "LANCER LE DÉCOMPTE", 220, 34, function()
        if PBT.StartGroupCountdownFromKeybind then PBT.StartGroupCountdownFromKeybind() end
    end, { 0.12, 0.40, 0.20, 1 }, MC.text)):SetAnchor(TOPLEFT, p, TOPLEFT, 0, 96)
    track(FlatButton(p, "TEST 3s", 130, 34, function()
        if PBT.StartNamedCountdown then PBT.StartNamedCountdown("TEST", 3, "uiTest") end
    end)):SetAnchor(TOPLEFT, p, TOPLEFT, 232, 96)
    MLabel(p, MF_SMALL, MC.textDim, "Le décompte est commun au groupe. \"Mon délai\" ne change que ton écran."):SetAnchor(TOPLEFT, p, TOPLEFT, 0, 142)

    local ann = MakeCard(pane, "ANNONCE VISUELLE")
    ann:SetAnchor(TOPLEFT, pull, TOPRIGHT, 16, 0); ann:SetDimensions(470, 230)
    local a = ann.content
    MLabel(a, MF_SMALL, MC.textDim, "Couleur décompte"):SetAnchor(TOPLEFT, a, TOPLEFT, 0, 4)
    track(MakeSwatch(a, function() return SV().color end, function(r, g, b) if PBT.SetColor then PBT.SetColor(r, g, b) end end)):SetAnchor(TOPLEFT, a, TOPLEFT, 0, 22)
    MLabel(a, MF_SMALL, MC.textDim, "Couleur GO"):SetAnchor(TOPLEFT, a, TOPLEFT, 120, 4)
    track(MakeSwatch(a, function() return SV().goColor end, function(r, g, b, al) SV().goColor = { r = r, g = g, b = b, a = al or 1 }; UI:ApplySettings() end)):SetAnchor(TOPLEFT, a, TOPLEFT, 120, 22)
    MLabel(a, MF_SMALL, MC.textDim, "Sons"):SetAnchor(TOPLEFT, a, TOPLEFT, 240, 4)
    track(MakeToggle(a, function() return SV().soundEnabled ~= false end, function(v) SV().soundEnabled = v end)):SetAnchor(TOPLEFT, a, TOPLEFT, 240, 22)
    MLabel(a, MF_SMALL, MC.textDim, "Échelle de l'annonce"):SetAnchor(TOPLEFT, a, TOPLEFT, 0, 64)
    track(MakeSlider(a, 430, 0.5, 2.5, 0.05, function() return tonumber(SV().scale) or 1 end,
        function(v) if PBT.SetScale then PBT.SetScale(v) end end, "x")):SetAnchor(TOPLEFT, a, TOPLEFT, 0, 82)
    toggleRow(a, "Déverrouiller (déplacer)", 0, 120, function() return SV().unlocked == true end,
        function(v) if UI.SetUnlocked then UI:SetUnlocked(v) else SV().unlocked = v; UI:ApplySettings() end end)
    toggleRow(a, "Logo à l'écran", 240, 120, function() return SV().menuButtonEnabled ~= false end,
        function(v) SV().menuButtonEnabled = v; UI:ApplyMenuButtonSettings() end)
    MLabel(a, MF_SMALL, MC.textDim, "Taille du logo"):SetAnchor(TOPLEFT, a, TOPLEFT, 0, 152)
    track(MakeSlider(a, 430, 28, 96, 2, function() return tonumber(SV().menuButtonSize) or 46 end,
        function(v) SV().menuButtonSize = v; UI:ApplyMenuButtonSettings() end)):SetAnchor(TOPLEFT, a, TOPLEFT, 0, 170)
end

-- ---------------- onglet TIMERS & MANNEQUIN ----------------
local function BuildTimersTab(pane)
    pane.widgets = {}
    local function track(w) table.insert(pane.widgets, w); return w end
    local boss = MakeCard(pane, "TIMERS BOSS")
    boss:SetAnchor(TOPLEFT, pane, TOPLEFT, 0, 0); boss:SetDimensions(470, 230)
    local b = boss.content
    local t = track(MakeToggle(b, function() return SV().bossSpawnTimers ~= false end,
        function(v) SV().bossSpawnTimers = v; SV().useSamuraiTimers = v end)); t:SetAnchor(TOPLEFT, b, TOPLEFT, 0, 4)
    MLabel(b, MF_SMALL, MC.text, "Timers boss automatiques"):SetAnchor(LEFT, t, RIGHT, 8, 0)
    pane.instanceLbl = MLabel(b, MF_LABEL, MC.cyan, "Instance non reconnue"); pane.instanceLbl:SetAnchor(TOPLEFT, b, TOPLEFT, 0, 44); pane.instanceLbl:SetWidth(430)
    pane.casesLbl = MLabel(b, MF_SMALL, MC.textDim, ""); pane.casesLbl:SetAnchor(TOPLEFT, b, TOPLEFT, 0, 68); pane.casesLbl:SetWidth(430)
    track(FlatButton(b, "OUVRIR LES RÉGLAGES ESO (détails)", 300, 32, function() if PBT.OpenSettings then PBT.OpenSettings() end end)):SetAnchor(TOPLEFT, b, TOPLEFT, 0, 150)

    local dummy = MakeCard(pane, "MANNEQUIN")
    dummy:SetAnchor(TOPLEFT, boss, TOPRIGHT, 16, 0); dummy:SetDimensions(470, 230)
    local d = dummy.content
    MLabel(d, MF_SMALL, MC.textDim, "Durée du timer mannequin"):SetAnchor(TOPLEFT, d, TOPLEFT, 0, 4)
    track(MakeSlider(d, 430, 1, 60, 1, function() return tonumber(SV().practiceSeconds) or 10 end, function(v) SV().practiceSeconds = v end, "s")):SetAnchor(TOPLEFT, d, TOPLEFT, 0, 22)
    local at = track(MakeToggle(d, function() return SV().autoPracticeOnDummyReset ~= false end, function(v) SV().autoPracticeOnDummyReset = v end)); at:SetAnchor(TOPLEFT, d, TOPLEFT, 0, 64)
    MLabel(d, MF_SMALL, MC.text, "Auto-timer après reset mannequin"):SetAnchor(LEFT, at, RIGHT, 8, 0)
end

-- ---------------- refresh ----------------
function UI:RefreshForm()
    local pane = self.managerPanes and self.managerPanes.markers
    if not pane then return end
    if pane.widgets then for _, w in ipairs(pane.widgets) do if w.Redraw then w.Redraw() end end end
    local texId, label, col = GetTexId(), GetCurLabel(), GetColor()
    if pane.previewTex then pane.previewTex:SetTexture(MarkerTexture(texId)) end
    if pane.previewLbl then
        local list = SV().groupBeaconSavedMarkers or {}
        local preview = (label == "auto") and tostring((#list % 10) + 1) or label
        pane.previewLbl:SetText(TextureHasNativeText(texId) and "" or preview)
        local r, gg, bl = col.r or col[1] or 1, col.g or col[2] or 1, col.b or col[3] or 1
        local lum = r * 0.299 + gg * 0.587 + bl * 0.114
        pane.previewLbl:SetColor(lum > 0.5 and 0 or 1, lum > 0.5 and 0 or 1, lum > 0.5 and 0 or 1, 1)
    end
    if pane.labelBtn then pane.labelBtn.label:SetText("Texte : " .. (label == "auto" and "Auto 1-10" or label)) end
    if pane.editBanner then pane.editBanner:SetText(editIndex and ("MODIF #" .. editIndex) or "Valeurs par défaut") end
    if pane.iconCells then
        for _, cell in ipairs(pane.iconCells) do
            local ch = cell.choice
            local sel = (ch.id == texId) and ((ch.label == nil and (label == "auto")) or ch.label == label)
            cell.selected = sel
            cell.bg:SetEdgeColor(unpack4(sel and MC.cyan or MC.cardEdge))
            cell.bg:SetCenterColor(sel and 0.05 or 0.04, sel and 0.13 or 0.05, sel and 0.19 or 0.07, 1)
        end
    end
    local tp = self.managerPanes and self.managerPanes.timers
    if tp and tp.instanceLbl then
        local raids = PBT.GetNativeRaidTimersForCurrentInstance and PBT.GetNativeRaidTimersForCurrentInstance() or {}
        local raid = raids[1]
        if raid then tp.instanceLbl:SetText(raid.name or "Instance"); tp.casesLbl:SetText("Pris en compte : " .. (raid.cases or ""))
        else tp.instanceLbl:SetText("Instance non reconnue"); tp.casesLbl:SetText("Aucun timer boss appelé ici.") end
    end
end

function UI:RefreshList()
    local pane = self.managerPanes and self.managerPanes.markers
    if not pane or not pane.rows then return end
    local list = SV().groupBeaconSavedMarkers or {}
    local total = #list
    -- valider les index courants
    if editIndex and not list[editIndex] then editIndex = nil end
    if selectedIndex and not list[selectedIndex] then selectedIndex = nil end
    local maxPage = math.max(1, math.ceil(total / MARKER_ROWS))
    markerPage = mclamp(markerPage, 1, maxPage)
    local start = (markerPage - 1) * MARKER_ROWS
    if pane.listInfo then pane.listInfo:SetText(string.format("%d marker%s — page %d/%d", total, total > 1 and "s" or "", markerPage, maxPage)) end
    if pane.prevBtn then pane.prevBtn.label:SetColor(unpack4(markerPage > 1 and MC.text or MC.textDim)) end
    if pane.nextBtn then pane.nextBtn.label:SetColor(unpack4(markerPage < maxPage and MC.text or MC.textDim)) end
    if pane.editBtn then pane.editBtn.label:SetColor(unpack4(selectedIndex and MC.text or MC.textDim)) end
    if pane.doneBtn then pane.doneBtn.label:SetColor(unpack4(editIndex and MC.text or MC.textDim)) end
    if pane.delBtn then pane.delBtn.label:SetColor(unpack4(selectedIndex and MC.text or MC.textDim)) end
    for i, row in ipairs(pane.rows) do
        local idx = start + i
        local m = list[idx]
        if m then
            row:SetHidden(false)
            row.badge:SetTexture(MarkerTexture(m.textureId or 1))
            local lab = m.labelId and MLabelText(m.labelId) or "auto"
            local mark = (idx == editIndex) and "MODIF " or ((idx == selectedIndex) and "> " or "")
            row.txt:SetText(string.format("%s#%d  %s  •  zone %s  •  h%s", mark, idx, lab, tostring(m.zone or "?"), tostring(m.heightOffset or 0)))
            if idx == editIndex then
                row.bg:SetEdgeColor(unpack4(MC.gold)); row.bg:SetCenterColor(0.12, 0.09, 0.02, 1)
            elseif idx == selectedIndex then
                row.bg:SetEdgeColor(unpack4(MC.cyan)); row.bg:SetCenterColor(0.05, 0.11, 0.16, 1)
            else
                row.bg:SetEdgeColor(unpack4(MC.cardEdge)); row.bg:SetCenterColor(0.04, 0.05, 0.07, 1)
            end
        else
            row:SetHidden(true)
        end
    end
    if pane.packCells then
        local active = mclamp(SV().groupBeaconMarkerSetSlot, 1, 3)
        for slot, cell in ipairs(pane.packCells) do
            local info = PBT.GetCurrentMarkerSetInfo and PBT.GetCurrentMarkerSetInfo(slot)
            local count = info and info.markers and #info.markers or 0
            local nm = PBT.GetMarkerPackName and PBT.GetMarkerPackName(slot) or ("Pack " .. slot)
            cell.label:SetText(nm .. (count > 0 and (" (" .. count .. ")") or ""))
            cell.baseColor = (slot == active) and { 0.05, 0.13, 0.19, 1 } or MC.card
            cell.bg:SetCenterColor(unpack4(cell.baseColor))
            cell.bg:SetEdgeColor(unpack4(slot == active and MC.cyan or MC.cardEdge))
        end
    end
end

function UI:SetTab(id)
    activeManagerTab = id
    for _, t in ipairs(self.managerTabs or {}) do
        local on = (t.id == id)
        t.bg:SetCenterColor(on and 0.12 or 0.07, on and 0.16 or 0.08, on and 0.20 or 0.10, 1)
        t.bg:SetEdgeColor(unpack4(on and MC.cyan or MC.cardEdge))
        t.label:SetColor(unpack4(on and MC.cyan or MC.textDim))
    end
    for name, pane in pairs(self.managerPanes or {}) do pane:SetHidden(name ~= id) end
    self:RefreshForm(); self:RefreshList()
end

-- ---------------- construction / affichage ----------------
function UI:CreateManagerWindow()
    if self.managerWindow then return self.managerWindow end
    local M = WM:CreateTopLevelWindow(MANAGER_WINDOW_NAME)
    M:SetDimensions(1010, 712); M:SetAnchor(CENTER, GuiRoot, CENTER, 0, -10)
    M:SetMovable(true); M:SetMouseEnabled(true); M:SetClampedToScreen(true); M:SetHidden(true); M:SetDrawTier(DT_HIGH)
    M.bg = Backdrop(M, MC.panel, MC.gold); M.bg:SetAnchorFill(M)
    self.managerWindow = M

    M.titleBar = WM:CreateControl(nil, M, CT_CONTROL)
    M.titleBar:SetAnchor(TOPLEFT, M, TOPLEFT, 0, 0); M.titleBar:SetAnchor(TOPRIGHT, M, TOPRIGHT, 0, 0); M.titleBar:SetHeight(50); M.titleBar:SetMouseEnabled(true)
    M.titleBar:SetHandler("OnMouseDown", function() M:StartMoving() end)
    M.titleBar:SetHandler("OnMouseUp", function()
        M:StopMovingOrResizing()
        if PBT.savedVars then
            PBT.savedVars.managerWindowX = M:GetLeft() + (M:GetWidth() / 2) - GuiRoot:GetWidth() / 2
            PBT.savedVars.managerWindowY = M:GetTop() + (M:GetHeight() / 2) - GuiRoot:GetHeight() / 2
        end
    end)
    M.title = MLabel(M, MF_TITLE, MC.cyan, "TEAM SHADOWS MANAGER", TEXT_ALIGN_CENTER); M.title:SetAnchor(TOP, M, TOP, 0, 12); M.title:SetWidth(1010)
    MLabel(M, MF_SMALL, MC.textDim, "TeamFky - EyrOn"):SetAnchor(TOPLEFT, M, TOPLEFT, 22, 18)
    local close = FlatButton(M, "X", 30, 30, function() self.managerWindow:SetHidden(true) end, MC.panel, MC.gold)
    close:SetAnchor(TOPRIGHT, M, TOPRIGHT, -14, 12)

    self.managerTabs = {}
    local tabW = 312
    for i, t in ipairs(MTABS) do
        local tab = WM:CreateControl(nil, M, CT_CONTROL)
        tab:SetDimensions(tabW, 32); tab:SetAnchor(TOPLEFT, M, TOPLEFT, 24 + (i - 1) * (tabW + 8), 54); tab:SetMouseEnabled(true)
        tab.bg = Backdrop(tab, { 0.07, 0.08, 0.10, 1 }, MC.cardEdge); tab.bg:SetAnchorFill(tab)
        tab.label = MLabel(tab, MF_LABEL, MC.textDim, t.label, TEXT_ALIGN_CENTER); tab.label:SetAnchor(CENTER, tab, CENTER, 0, 0)
        tab.id = t.id
        tab:SetHandler("OnMouseUp", function(_, _, upInside) if upInside then self:SetTab(t.id) end end)
        self.managerTabs[i] = tab
    end

    self.managerPanes = {}
    self.managerContent = WM:CreateControl(nil, M, CT_CONTROL)
    self.managerContent:SetAnchor(TOPLEFT, M, TOPLEFT, 24, 100); self.managerContent:SetDimensions(962, 596)
    for _, t in ipairs(MTABS) do
        local pane = WM:CreateControl(nil, self.managerContent, CT_CONTROL)
        pane:SetAnchorFill(self.managerContent); pane:SetHidden(true)
        self.managerPanes[t.id] = pane
    end
    BuildMarkersTab(self.managerPanes.markers)
    BuildPullTab(self.managerPanes.pull)
    BuildTimersTab(self.managerPanes.timers)
    return M
end

function UI:ShowManagerWindow()
    if not self.managerWindow then self:CreateManagerWindow() end
    local saved = PBT.savedVars or {}
    self.managerWindow:ClearAnchors()
    self.managerWindow:SetAnchor(CENTER, GuiRoot, CENTER, saved.managerWindowX or 0, saved.managerWindowY or -10)
    self.managerWindow:SetHidden(false)
    self:SetTab(activeManagerTab)
end

function UI:ToggleManagerWindow()
    if self.managerWindow and not self.managerWindow:IsHidden() then
        self.managerWindow:SetHidden(true)
    else
        self:ShowManagerWindow()
    end
end

function UI:RefreshManagerWindow()
    if not self.managerWindow then return end
    self:RefreshForm(); self:RefreshList()
end

SLASH_COMMANDS["/shadowsui"] = function() UI:ToggleManagerWindow() end
