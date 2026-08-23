-- ESO Adventurer Suite
-- Live equipment paper-doll overlay for the Gear & Sets workspace.

local EPC = ESOProgressionCoach
EPC.GearLoadoutOverlay = EPC.GearLoadoutOverlay or {}
local G = EPC.GearLoadoutOverlay
local wm = WINDOW_MANAGER

local BASE_W, BASE_H = 620, 660
local MIN_W, MIN_H = 465, 495
local MAX_W, MAX_H = 900, 960

local SLOT_ROWS_LEFT = {
    {key="HEAD", label="HEAD", slot=EQUIP_SLOT_HEAD},
    {key="SHOULDERS", label="SHOULDERS", slot=EQUIP_SLOT_SHOULDERS},
    {key="CHEST", label="CHEST", slot=EQUIP_SLOT_CHEST},
    {key="HANDS", label="HANDS", slot=EQUIP_SLOT_HAND},
    {key="WAIST", label="WAIST", slot=EQUIP_SLOT_WAIST},
    {key="LEGS", label="LEGS", slot=EQUIP_SLOT_LEGS},
    {key="FEET", label="FEET", slot=EQUIP_SLOT_FEET},
}

local SLOT_ROWS_RIGHT = {
    {key="NECK", label="NECK", slot=EQUIP_SLOT_NECK},
    {key="RING1", label="RING 1", slot=EQUIP_SLOT_RING1},
    {key="RING2", label="RING 2", slot=EQUIP_SLOT_RING2},
    {key="FRONT_MAIN", label="FRONT MAIN", slot=EQUIP_SLOT_MAIN_HAND, bar="FRONT"},
    {key="FRONT_OFF", label="FRONT OFF", slot=EQUIP_SLOT_OFF_HAND, bar="FRONT"},
    {key="BACK_MAIN", label="BACK MAIN", slot=EQUIP_SLOT_BACKUP_MAIN, bar="BACK"},
    {key="BACK_OFF", label="BACK OFF", slot=EQUIP_SLOT_BACKUP_OFF, bar="BACK"},
}

local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a,b,c,d,e,f,g,h,i = pcall(fn, ...)
    if not ok then return fallback end
    return a,b,c,d,e,f,g,h,i
end

local function makeBackdrop(name, parent)
    local b = wm:CreateControl(name, parent, CT_BACKDROP)
    b:SetEdgeTexture(nil, 1, 1, 1)
    return b
end

-- Keep visible strokes slightly inside their parent. Thin backdrop edges can be
-- partially clipped or land on sub-pixels when the Live Equipment canvas is
-- scaled down, so important panels get a second fully-contained border.
local function makeInsetBorder(name, parent, inset)
    local b = wm:CreateControl(name, parent, CT_BACKDROP)
    b:SetEdgeTexture(nil, 1, 1, 2)
    inset = tonumber(inset) or 2
    b:SetAnchor(TOPLEFT, parent, TOPLEFT, inset, inset)
    b:SetAnchor(BOTTOMRIGHT, parent, BOTTOMRIGHT, -inset, -inset)
    b:SetCenterColor(0, 0, 0, 0)
    b:SetEdgeColor(0.20, 0.27, 0.36, 0.72)
    if b.SetMouseEnabled then b:SetMouseEnabled(false) end
    if b.SetDrawLevel then b:SetDrawLevel(2) end
    return b
end

local function makeLabel(name, parent, text, font)
    local l = wm:CreateControl(name, parent, CT_LABEL)
    l:SetFont(font or "ZoFontGame")
    l:SetText(text or "")
    l:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    return l
end

local function makeButton(name, parent, text, handler)
    local b = wm:CreateControl(name, parent, CT_BUTTON)
    b:SetFont("ZoFontGameBold")
    b:SetText(text)
    if handler then b:SetHandler("OnClicked", handler) end
    return b
end

local function qualityColor(link)
    if not link or link == "" then return 0.30, 0.34, 0.42 end
    local q = safe(GetItemLinkDisplayQuality, nil, link)
    if q ~= nil and type(GetItemQualityColor) == "function" then
        local c = safe(GetItemQualityColor, nil, q)
        if c and type(c.UnpackRGB) == "function" then
            local ok, r,g,b = pcall(c.UnpackRGB, c)
            if ok and r and g and b then return r,g,b end
        end
    end
    return 0.30, 0.34, 0.42
end

local function cleanName(value)
    local text = tostring(value or "")
    if type(zo_strformat) == "function" and text ~= "" then
        local ok, formatted = pcall(zo_strformat, "<<1>>", text)
        if ok and formatted then text = formatted end
    end
    return text
end

function G:GetTheme()
    local journal = EPC and EPC.Journal
    if journal and type(journal.GetTheme) == "function" then
        local theme = safe(journal.GetTheme, nil, journal)
        if type(theme) == "table" then return theme end
    end
    return {
        text={0.88,0.92,0.98,1},
        edge={0.24,0.36,0.54,1},
        accent={0.43,0.68,0.96,1},
    }
end

function G:GetCompanionDefId()
    return math.max(0, tonumber(safe(GetActiveCompanionDefId, 0)) or 0)
end

function G:EnsureSaved()
    EPC.saved = EPC.saved or {}
    EPC.saved.gearLoadoutOverlay = EPC.saved.gearLoadoutOverlay or {}
    local s = EPC.saved.gearLoadoutOverlay
    -- v0.24.91: the paper-doll is intentionally player-only.
    s.actor = "PLAYER"
    return s
end

function G:IsCompanionAvailable()
    if safe(HasActiveCompanion, false) == true then return true end
    if self:GetCompanionDefId() > 0 then return true end
    if type(DoesUnitExist) == "function" and safe(DoesUnitExist, false, "companion") == true then return true end
    return false
end

function G:IsCompanionGearSupported()
    return BAG_COMPANION_WORN ~= nil and (type(GetActiveCompanionDefId) == "function" or type(HasActiveCompanion) == "function")
end

function G:GetActorBag()
    return BAG_WORN, "player"
end

function G:SetButtonState(button, selected, enabled)
    if not button then return end
    local t = self:GetTheme()
    local a = t.accent or t.edge or {0.43,0.68,0.96,1}
    enabled = enabled ~= false
    if button.SetEnabled then button:SetEnabled(enabled) end
    if selected then
        button:SetNormalFontColor(a[1], a[2], a[3], 1)
        button:SetMouseOverFontColor(math.min(1,a[1]+0.18), math.min(1,a[2]+0.18), math.min(1,a[3]+0.18), 1)
    elseif enabled then
        button:SetNormalFontColor(0.84, 0.88, 0.94, 1)
        button:SetMouseOverFontColor(1,1,1,1)
    else
        button:SetNormalFontColor(0.38, 0.42, 0.50, 1)
        button:SetMouseOverFontColor(0.38, 0.42, 0.50, 1)
    end
    if button.bg then
        if selected then
            button.bg:SetCenterColor(a[1], a[2], a[3], 0.20)
            button.bg:SetEdgeColor(a[1], a[2], a[3], 0.72)
        elseif enabled then
            button.bg:SetCenterColor(0.055, 0.070, 0.095, 0.72)
            button.bg:SetEdgeColor(0.24, 0.31, 0.42, 0.55)
        else
            button.bg:SetCenterColor(0.03, 0.04, 0.05, 0.48)
            button.bg:SetEdgeColor(0.14, 0.16, 0.20, 0.35)
        end
    end
end

function G:CreateActorButton(name, text, x, y, w, handler)
    local b = makeButton(name, self.canvas, text, handler)
    b:SetAnchor(TOPLEFT, self.canvas, TOPLEFT, x, y)
    b:SetDimensions(w, 30)
    local bg = makeBackdrop(name .. "_BG", b)
    bg:SetAnchor(TOPLEFT, b, TOPLEFT, 1, 1)
    bg:SetAnchor(BOTTOMRIGHT, b, BOTTOMRIGHT, -1, -1)
    bg:SetDrawLevel(0)
    b.bg = bg
    return b
end

function G:CreateSlotCard(def, x, y)
    if def.slot == nil then return nil end
    local name = "EAS_GearPreviewSlot_" .. def.key
    local card = makeBackdrop(name, self.canvas)
    card:SetAnchor(TOPLEFT, self.canvas, TOPLEFT, x, y)
    card:SetDimensions(190, 62)
    card:SetCenterColor(0.032, 0.043, 0.060, 0.80)
    card:SetEdgeColor(0.20, 0.27, 0.36, 0.40)
    local insetBorder = makeInsetBorder(name .. "_InsetBorder", card, 2)
    insetBorder:SetEdgeColor(0.20, 0.27, 0.36, 0.78)

    local iconBG = makeBackdrop(name .. "_IconBG", card)
    iconBG:SetAnchor(LEFT, card, LEFT, 8, 0)
    iconBG:SetDimensions(44, 44)
    iconBG:SetCenterColor(0.02, 0.025, 0.035, 0.88)
    iconBG:SetEdgeColor(0.30, 0.34, 0.42, 0.75)

    local icon = wm:CreateControl(name .. "_Icon", iconBG, CT_TEXTURE)
    icon:SetAnchor(CENTER, iconBG, CENTER, 0, 0)
    icon:SetDimensions(38, 38)
    icon:SetHidden(true)

    local slotLabel = makeLabel(name .. "_SlotLabel", card, def.label, "ZoFontGameSmall")
    slotLabel:SetAnchor(TOPLEFT, card, TOPLEFT, 60, 7)
    slotLabel:SetDimensions(122, 15)
    slotLabel:SetColor(0.52, 0.62, 0.75, 1)
    slotLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)

    local itemLabel = makeLabel(name .. "_ItemLabel", card, "EMPTY", "ZoFontGame")
    itemLabel:SetAnchor(TOPLEFT, card, TOPLEFT, 60, 23)
    itemLabel:SetDimensions(122, 20)
    itemLabel:SetColor(0.72, 0.76, 0.82, 1)
    itemLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)
    if itemLabel.SetMaxLineCount then itemLabel:SetMaxLineCount(1) end

    local setLabel = makeLabel(name .. "_SetLabel", card, "", "ZoFontGameSmall")
    setLabel:SetAnchor(TOPLEFT, card, TOPLEFT, 60, 43)
    setLabel:SetDimensions(122, 14)
    setLabel:SetColor(0.48, 0.58, 0.68, 1)
    setLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)
    if setLabel.SetMaxLineCount then setLabel:SetMaxLineCount(1) end

    card.insetBorder = insetBorder
    card.iconBG = iconBG
    card.icon = icon
    card.slotLabel = slotLabel
    card.itemLabel = itemLabel
    card.setLabel = setLabel
    card.def = def
    return card
end

function G:UpdateScale()
    if not self.window or not self.canvas then return end
    local w,h = self.window:GetDimensions()
    w = tonumber(w) or BASE_W
    h = tonumber(h) or BASE_H
    local scale = math.min(w / BASE_W, h / BASE_H)
    scale = math.max(0.74, math.min(1.35, scale))
    self.canvas:SetScale(scale)
    self.canvas:ClearAnchors()
    self.canvas:SetAnchor(CENTER, self.window, CENTER, 0, 0)
end

function G:Create()
    if self.window then return end
    local s = self:EnsureSaved()

    local window = wm:CreateTopLevelWindow("EAS_GearLoadoutOverlay")
    window:SetDimensions(tonumber(s.width) or BASE_W, tonumber(s.height) or BASE_H)
    if window.SetDimensionConstraints then window:SetDimensionConstraints(MIN_W, MIN_H, MAX_W, MAX_H) end
    if window.SetResizeHandleSize then window:SetResizeHandleSize(24) end
    window:SetClampedToScreen(true)
    window:SetMovable(true)
    window:SetMouseEnabled(true)
    window:SetHidden(true)
    window:SetDrawLayer(DL_OVERLAY)
    window:SetDrawTier(DT_HIGH)
    self.window = window

    if tonumber(s.left) and tonumber(s.top) then
        window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, s.left, s.top)
    else
        window:SetAnchor(RIGHT, GuiRoot, RIGHT, -24, 0)
    end

    local canvas = wm:CreateControl("EAS_GearLoadoutCanvas", window, CT_CONTROL)
    canvas:SetDimensions(BASE_W, BASE_H)
    canvas:SetAnchor(CENTER, window, CENTER, 0, 0)
    self.canvas = canvas

    local bg = makeBackdrop("EAS_GearLoadoutBG", canvas)
    bg:SetAnchorFill(canvas)
    bg:SetCenterColor(0.012, 0.018, 0.028, 0.91)
    bg:SetEdgeColor(0.30, 0.56, 0.82, 0.78)
    self.bg = bg
    local frameBorder = makeInsetBorder("EAS_GearLoadoutFrameInsetBorder", bg, 3)
    frameBorder:SetEdgeColor(0.30, 0.56, 0.82, 0.86)
    self.frameBorder = frameBorder

    local top = makeBackdrop("EAS_GearLoadoutTop", canvas)
    top:SetAnchor(TOPLEFT, canvas, TOPLEFT, 0, 0)
    top:SetAnchor(TOPRIGHT, canvas, TOPRIGHT, 0, 0)
    top:SetHeight(92)
    top:SetCenterColor(0.024, 0.034, 0.050, 0.92)
    top:SetEdgeColor(0.18, 0.28, 0.40, 0.54)
    self.top = top

    local accent = makeBackdrop("EAS_GearLoadoutAccent", canvas)
    accent:SetAnchor(TOPLEFT, canvas, TOPLEFT, 0, 0)
    accent:SetDimensions(4, BASE_H)
    accent:SetCenterColor(0.34, 0.68, 1.00, 0.96)
    accent:SetEdgeColor(0,0,0,0)
    self.accent = accent

    local title = makeLabel("EAS_GearLoadoutTitle", canvas, "LIVE EQUIPMENT", "ZoFontWinH2")
    title:SetAnchor(TOPLEFT, canvas, TOPLEFT, 18, 12)
    title:SetDimensions(230, 26)
    title:SetColor(0.94, 0.97, 1.00, 1)
    self.title = title

    local subtitle = makeLabel("EAS_GearLoadoutSubtitle", canvas, "Gear & Sets  /  updates as equipment changes", "ZoFontGameSmall")
    subtitle:SetAnchor(TOPLEFT, canvas, TOPLEFT, 19, 40)
    subtitle:SetDimensions(310, 18)
    subtitle:SetColor(0.55, 0.64, 0.75, 1)
    self.subtitle = subtitle

    self.playerButton = self:CreateActorButton("EAS_GearPreviewPlayer", "PLAYER", 446, 18, 112, function() self:SetActor("PLAYER") end)
    self.companionButton = nil
    self.closeButton = self:CreateActorButton("EAS_GearPreviewClose", "X", 574, 18, 30, function()
        self.manualClosed = true
        self:UpdateVisibility()
    end)

    local live = makeLabel("EAS_GearLoadoutLive", canvas, "LIVE", "ZoFontGameBold")
    live:SetAnchor(TOPLEFT, canvas, TOPLEFT, 356, 57)
    live:SetDimensions(46, 18)
    live:SetColor(0.40, 0.92, 0.66, 1)
    self.live = live
    local liveText = makeLabel("EAS_GearLoadoutLiveText", canvas, "equipment changes refresh automatically", "ZoFontGameSmall")
    liveText:SetAnchor(TOPLEFT, canvas, TOPLEFT, 407, 57)
    liveText:SetDimensions(196, 18)
    liveText:SetColor(0.52, 0.61, 0.72, 1)
    self.liveText = liveText

    self.slotCards = {}
    for i,def in ipairs(SLOT_ROWS_LEFT) do
        local card = self:CreateSlotCard(def, 14, 104 + (i-1)*71)
        if card then self.slotCards[#self.slotCards+1] = card end
    end
    for i,def in ipairs(SLOT_ROWS_RIGHT) do
        local card = self:CreateSlotCard(def, 416, 104 + (i-1)*71)
        if card then self.slotCards[#self.slotCards+1] = card end
    end

    -- Center character stage. ESO does not expose a true custom 3D paper-doll
    -- to addons, so this uses the game-provided player silhouette with a
    -- layered accent treatment and the live character identity underneath.
    local portraitBG = makeBackdrop("EAS_GearPreviewPortraitBG", canvas)
    portraitBG:SetAnchor(TOPLEFT, canvas, TOPLEFT, 216, 104)
    portraitBG:SetDimensions(188, 358)
    portraitBG:SetCenterColor(0.022, 0.030, 0.044, 0.84)
    portraitBG:SetEdgeColor(0.22, 0.34, 0.48, 0.38)
    local portraitBorder = makeInsetBorder("EAS_GearPreviewPortraitInsetBorder", portraitBG, 2)
    portraitBorder:SetEdgeColor(0.22, 0.34, 0.48, 0.78)
    self.portraitBG = portraitBG
    self.portraitBorder = portraitBorder

    local modelHeader = makeLabel("EAS_GearPreviewModelHeader", portraitBG, "CURRENT CHARACTER", "ZoFontGameBold")
    modelHeader:SetAnchor(TOPLEFT, portraitBG, TOPLEFT, 8, 8)
    modelHeader:SetDimensions(172, 18)
    modelHeader:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    modelHeader:SetColor(0.62, 0.72, 0.84, 1)
    self.modelHeader = modelHeader

    local portraitGlow = wm:CreateControl("EAS_GearPreviewPortraitGlow", portraitBG, CT_TEXTURE)
    portraitGlow:SetAnchor(CENTER, portraitBG, CENTER, 4, 9)
    portraitGlow:SetDimensions(180, 304)
    portraitGlow:SetColor(0.34, 0.68, 1.00, 0.16)
    portraitGlow:SetHidden(true)
    self.portraitGlow = portraitGlow

    local portrait = wm:CreateControl("EAS_GearPreviewPortrait", portraitBG, CT_TEXTURE)
    portrait:SetAnchor(CENTER, portraitBG, CENTER, 0, 5)
    portrait:SetDimensions(172, 296)
    portrait:SetColor(0.88, 0.93, 0.98, 0.92)
    portrait:SetHidden(true)
    self.portrait = portrait

    local portraitFallback = makeLabel("EAS_GearPreviewPortraitFallback", portraitBG, "CHARACTER PREVIEW\nUNAVAILABLE", "ZoFontGameBold")
    portraitFallback:SetAnchor(CENTER, portraitBG, CENTER, 0, 8)
    portraitFallback:SetDimensions(172, 44)
    portraitFallback:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    portraitFallback:SetColor(0.58, 0.65, 0.74, 1)
    portraitFallback:SetHidden(true)
    self.portraitFallback = portraitFallback

    local stageLine = makeBackdrop("EAS_GearPreviewStageLine", portraitBG)
    stageLine:SetAnchor(BOTTOMLEFT, portraitBG, BOTTOMLEFT, 18, -14)
    stageLine:SetDimensions(152, 1)
    stageLine:SetCenterColor(0.34, 0.68, 1.00, 0.42)
    stageLine:SetEdgeColor(0,0,0,0)
    self.stageLine = stageLine

    local actorName = makeLabel("EAS_GearPreviewActorName", canvas, "", "ZoFontWinH3")
    actorName:SetAnchor(TOPLEFT, canvas, TOPLEFT, 212, 472)
    actorName:SetDimensions(196, 28)
    actorName:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    actorName:SetColor(0.94, 0.97, 1.00, 1)
    self.actorName = actorName

    local actorMeta = makeLabel("EAS_GearPreviewActorMeta", canvas, "", "ZoFontGameSmall")
    actorMeta:SetAnchor(TOPLEFT, canvas, TOPLEFT, 212, 503)
    actorMeta:SetDimensions(196, 38)
    actorMeta:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    actorMeta:SetVerticalAlignment(TEXT_ALIGN_TOP)
    actorMeta:SetColor(0.56, 0.66, 0.78, 1)
    self.actorMeta = actorMeta

    local barPanel = makeBackdrop("EAS_GearPreviewBarPanel", canvas)
    barPanel:SetAnchor(TOPLEFT, canvas, TOPLEFT, 212, 548)
    barPanel:SetDimensions(196, 78)
    barPanel:SetCenterColor(0.030, 0.040, 0.056, 0.80)
    barPanel:SetEdgeColor(0.20, 0.28, 0.39, 0.34)
    local barBorder = makeInsetBorder("EAS_GearPreviewBarInsetBorder", barPanel, 2)
    barBorder:SetEdgeColor(0.20, 0.28, 0.39, 0.74)
    self.barPanel = barPanel
    self.barBorder = barBorder

    local barTitle = makeLabel("EAS_GearPreviewBarTitle", barPanel, "ACTIVE WEAPON BAR", "ZoFontGameSmall")
    barTitle:SetAnchor(TOPLEFT, barPanel, TOPLEFT, 8, 8)
    barTitle:SetDimensions(180, 16)
    barTitle:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    barTitle:SetColor(0.52, 0.62, 0.74, 1)
    self.barTitle = barTitle

    local barValue = makeLabel("EAS_GearPreviewBarValue", barPanel, "FRONT", "ZoFontGameBold")
    barValue:SetAnchor(TOPLEFT, barPanel, TOPLEFT, 8, 29)
    barValue:SetDimensions(180, 20)
    barValue:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    barValue:SetColor(0.44, 0.78, 1.00, 1)
    self.barValue = barValue

    local countLabel = makeLabel("EAS_GearPreviewCount", barPanel, "", "ZoFontGameSmall")
    countLabel:SetAnchor(TOPLEFT, barPanel, TOPLEFT, 8, 54)
    countLabel:SetDimensions(180, 16)
    countLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    countLabel:SetColor(0.50, 0.58, 0.68, 1)
    self.countLabel = countLabel

    local footer = makeLabel("EAS_GearPreviewFooter", canvas, "Hover your Gear & Sets workspace while this panel tracks the equipped loadout.", "ZoFontGameSmall")
    footer:SetAnchor(BOTTOMLEFT, canvas, BOTTOMLEFT, 18, -2)
    footer:SetDimensions(BASE_W-36, 18)
    footer:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    footer:SetColor(0.44, 0.52, 0.62, 1)
    self.footer = footer

    window:SetHandler("OnMoveStop", function(control)
        local sv = self:EnsureSaved()
        sv.left, sv.top = control:GetLeft(), control:GetTop()
    end)
    window:SetHandler("OnResizeStop", function(control)
        local sv = self:EnsureSaved()
        local w,h = control:GetDimensions()
        sv.width, sv.height = math.floor(w+0.5), math.floor(h+0.5)
        self:UpdateScale()
    end)
    window:SetHandler("OnUpdate", function(_, timeMs)
        if not self.window or self.window:IsHidden() then return end
        local now = tonumber(timeMs) or 0
        if not self.lastScaleUpdate or now - self.lastScaleUpdate > 70 then
            self.lastScaleUpdate = now
            self:UpdateScale()
        end
    end)

    self.actor = "PLAYER"
    self:UpdateScale()
    self:ApplyTheme()
end

function G:SetActor(actor)
    self.actor = "PLAYER"
    self:EnsureSaved().actor = "PLAYER"
    self:Refresh()
end

function G:RefreshSlot(card, bagId, activePair)
    if not card or not card.def or bagId == nil then return false end
    local slot = card.def.slot
    local link = safe(GetItemLink, "", bagId, slot, LINK_STYLE_DEFAULT or 0) or ""
    local hasItem = link ~= ""

    if hasItem then
        local icon = safe(GetItemLinkIcon, "", link) or ""
        if icon == "" then icon = safe(GetItemInfo, "", bagId, slot) or "" end
        if icon ~= "" then
            card.icon:SetTexture(icon)
            card.icon:SetHidden(false)
        else
            card.icon:SetHidden(true)
        end

        local itemName = safe(GetItemLinkName, "", link) or ""
        if itemName == "" then itemName = "Equipped Item" end
        card.itemLabel:SetText(itemName)
        card.itemLabel:SetColor(0.92, 0.95, 0.99, 1)

        local hasSet, setName = safe(GetItemLinkSetInfo, false, link, true)
        if hasSet and setName and setName ~= "" then card.setLabel:SetText(setName) else card.setLabel:SetText("") end

        local r,g,b = qualityColor(link)
        card.iconBG:SetEdgeColor(r,g,b,0.92)
    else
        card.icon:SetHidden(true)
        card.itemLabel:SetText("EMPTY")
        card.itemLabel:SetColor(0.48, 0.53, 0.61, 1)
        card.setLabel:SetText("")
        card.iconBG:SetEdgeColor(0.23, 0.28, 0.35, 0.55)
    end

    if self.actor == "PLAYER" and card.def.bar then
        local active = (card.def.bar == "FRONT" and activePair == (ACTIVE_WEAPON_PAIR_MAIN or 1)) or
                       (card.def.bar == "BACK" and activePair == (ACTIVE_WEAPON_PAIR_BACKUP or 2))
        if active then
            card:SetEdgeColor(0.38, 0.76, 1.00, 0.42)
            if card.insetBorder then card.insetBorder:SetEdgeColor(0.38, 0.76, 1.00, 0.96) end
            card.slotLabel:SetColor(0.45, 0.82, 1.00, 1)
        else
            card:SetEdgeColor(0.20, 0.27, 0.36, 0.36)
            if card.insetBorder then card.insetBorder:SetEdgeColor(0.20, 0.27, 0.36, 0.78) end
            card.slotLabel:SetColor(0.52, 0.62, 0.75, 1)
        end
    else
        card:SetEdgeColor(0.20, 0.27, 0.36, 0.36)
        if card.insetBorder then card.insetBorder:SetEdgeColor(0.20, 0.27, 0.36, 0.78) end
        card.slotLabel:SetColor(0.52, 0.62, 0.75, 1)
    end

    return hasItem
end

function G:ClearSlots(message)
    for _,card in ipairs(self.slotCards or {}) do
        if card.icon then card.icon:SetHidden(true) end
        if card.itemLabel then
            card.itemLabel:SetText(message or "EMPTY")
            card.itemLabel:SetColor(0.48, 0.53, 0.61, 1)
        end
        if card.setLabel then card.setLabel:SetText("") end
        if card.iconBG then card.iconBG:SetEdgeColor(0.23, 0.28, 0.35, 0.55) end
        card:SetEdgeColor(0.20, 0.27, 0.36, 0.36)
        if card.insetBorder then card.insetBorder:SetEdgeColor(0.20, 0.27, 0.36, 0.78) end
    end
end

function G:ApplyTheme()
    if not self.window then return end
    local t = self:GetTheme()
    local a = t.accent or t.edge or {0.43,0.68,0.96,1}

    if self.bg then self.bg:SetCenterColor(0.014,0.018,0.028,0.88) self.bg:SetEdgeColor(a[1],a[2],a[3],0.30) end
    if self.frameBorder then self.frameBorder:SetEdgeColor(a[1],a[2],a[3],0.86) end
    if self.top then self.top:SetCenterColor(0.024,0.028,0.040,0.92) self.top:SetEdgeColor(0.16,0.20,0.28,0.48) end
    if self.accent then self.accent:SetCenterColor(a[1],a[2],a[3],0.98) self.accent:SetEdgeColor(0,0,0,0) end
    if self.title then self.title:SetColor(0.94,0.97,1.00,1) end
    if self.subtitle then self.subtitle:SetColor(0.62,0.70,0.80,1) end
    if self.live then self.live:SetColor(a[1],a[2],a[3],1) end
    if self.liveText then self.liveText:SetColor(0.62,0.70,0.80,1) end
    if self.portraitBG then self.portraitBG:SetCenterColor(0.042,0.052,0.070,0.86) self.portraitBG:SetEdgeColor(a[1],a[2],a[3],0.28) end
    if self.portraitBorder then self.portraitBorder:SetEdgeColor(a[1],a[2],a[3],0.82) end
    if self.modelHeader then self.modelHeader:SetColor(a[1],a[2],a[3],0.95) end
    if self.portraitGlow then self.portraitGlow:SetColor(a[1],a[2],a[3],0.16) end
    if self.stageLine then self.stageLine:SetCenterColor(a[1],a[2],a[3],0.48) end
    if self.portraitFallback then self.portraitFallback:SetColor(0.58,0.65,0.74,1) end
    if self.barPanel then self.barPanel:SetCenterColor(0.042,0.052,0.070,0.82) self.barPanel:SetEdgeColor(a[1],a[2],a[3],0.18) end
    if self.barBorder then self.barBorder:SetEdgeColor(a[1],a[2],a[3],0.72) end
    if self.barTitle then self.barTitle:SetColor(0.62,0.70,0.80,1) end
    if self.barValue then self.barValue:SetColor(a[1],a[2],a[3],1) end
    if self.actorName then self.actorName:SetColor(0.94,0.97,1.00,1) end
    if self.actorMeta then self.actorMeta:SetColor(0.62,0.70,0.80,1) end
    if self.footer then self.footer:SetColor(0.52,0.60,0.70,1) end

    for _,card in ipairs(self.slotCards or {}) do
        card:SetCenterColor(0.042,0.052,0.070,0.80)
        if card.insetBorder then card.insetBorder:SetEdgeColor(0.24,0.32,0.43,0.80) end
        if card.slotLabel then card.slotLabel:SetColor(0.62,0.70,0.80,1) end
    end

    self:SetButtonState(self.playerButton, self.actor == "PLAYER", true)
    self:SetButtonState(self.companionButton, self.actor == "COMPANION", self:IsCompanionGearSupported())
    self:SetButtonState(self.closeButton, false, true)
end

function G:Refresh()
    if not self.window then return end
    self:ApplyTheme()

    local companionAvailable = self:IsCompanionAvailable()
    local companionSupported = self:IsCompanionGearSupported()
    local bagId, unitTag = self:GetActorBag()

    self:SetButtonState(self.playerButton, self.actor == "PLAYER", true)
    self:SetButtonState(self.companionButton, self.actor == "COMPANION", companionSupported)
    self:SetButtonState(self.closeButton, false, true)

    if self.actor == "COMPANION" then
        local companionId = self:GetCompanionDefId()
        local name = ""
        if companionId > 0 and type(GetCompanionName) == "function" then
            name = cleanName(safe(GetCompanionName, "", companionId))
        end
        if name == "" and type(GetUnitName) == "function" then
            name = cleanName(safe(GetUnitName, "", "companion"))
        end

        if not companionAvailable then
            self.actorName:SetText("NO ACTIVE COMPANION")
            self.actorMeta:SetText("Summon a companion to view\nits currently equipped gear.")
            self.portrait:SetHidden(true)
            if self.portraitGlow then self.portraitGlow:SetHidden(true) end
            if self.portraitFallback then self.portraitFallback:SetHidden(false) end
            self:ClearSlots("--")
            if self.countLabel then self.countLabel:SetText("No active companion") end
            if self.barValue then self.barValue:SetText("COMPANION") end
            return
        end

        if name == "" then name = "Companion" end
        self.actorName:SetText(name)

        local level = 0
        if type(GetActiveCompanionLevelInfo) == "function" then
            level = tonumber(safe(GetActiveCompanionLevelInfo, 0)) or 0
        end
        local raceName = ""
        local raceId = companionId > 0 and (tonumber(safe(GetCompanionRace, 0, companionId)) or 0) or 0
        local gender = companionId > 0 and safe(GetCompanionGender, GENDER_NEUTER or 0, companionId) or (GENDER_NEUTER or 0)
        if raceId > 0 and type(GetRaceName) == "function" then
            raceName = cleanName(safe(GetRaceName, "", gender, raceId))
        end
        local identityLine = raceName
        if level > 0 then
            identityLine = identityLine ~= "" and (identityLine .. "  /  Level " .. tostring(level)) or ("Level " .. tostring(level))
        end
        self.actorMeta:SetText((identityLine ~= "" and (identityLine .. "\n") or "") .. "Companion equipment")

        local silhouette = ""
        if type(DoesUnitExist) == "function" and safe(DoesUnitExist, false, "companion") == true then
            silhouette = safe(GetUnitSilhouetteTexture, "", "companion") or ""
        end
        if silhouette == "" and raceId > 0 and type(GetRaceAndGenderSilhouetteTexture) == "function" then
            silhouette = safe(GetRaceAndGenderSilhouetteTexture, "", raceId, gender) or ""
        end
        if silhouette ~= "" then
            self.portrait:SetTexture(silhouette)
            self.portrait:SetHidden(false)
            if self.portraitGlow then
                self.portraitGlow:SetTexture(silhouette)
                self.portraitGlow:SetHidden(false)
            end
            if self.portraitFallback then self.portraitFallback:SetHidden(true) end
        else
            self.portrait:SetHidden(true)
            if self.portraitGlow then self.portraitGlow:SetHidden(true) end
            if self.portraitFallback then self.portraitFallback:SetHidden(false) end
        end
    else
        local name = cleanName(safe(GetUnitName, "", "player"))
        if name == "" then name = "Player" end
        self.actorName:SetText(name)

        local level = tonumber(safe(GetUnitLevel, 0, "player")) or 0
        local cp = tonumber(safe(GetUnitChampionPoints, 0, "player")) or 0
        local race = cleanName(safe(GetUnitRace, "", "player"))
        local className = cleanName(safe(GetUnitClass, "", "player"))
        local identityLine = ""
        if race ~= "" and className ~= "" then identityLine = race .. " " .. className
        elseif race ~= "" then identityLine = race
        elseif className ~= "" then identityLine = className end
        local progressLine = ""
        if cp > 0 then progressLine = "Champion " .. tostring(cp)
        elseif level > 0 then progressLine = "Level " .. tostring(level) end
        if identityLine ~= "" and progressLine ~= "" then
            self.actorMeta:SetText(identityLine .. "\n" .. progressLine)
        elseif identityLine ~= "" then
            self.actorMeta:SetText(identityLine)
        else
            self.actorMeta:SetText(progressLine ~= "" and progressLine or "Player equipment")
        end

        local silhouette = safe(GetUnitSilhouetteTexture, "", "player") or ""
        if silhouette == "" and type(GetRaceAndGenderSilhouetteTexture) == "function" then
            local raceId = tonumber(safe(GetUnitRaceId, 0, "player")) or 0
            local gender = safe(GetUnitGender, GENDER_NEUTER or 0, "player")
            if raceId > 0 then silhouette = safe(GetRaceAndGenderSilhouetteTexture, "", raceId, gender) or "" end
        end
        if silhouette ~= "" then
            self.portrait:SetTexture(silhouette)
            self.portrait:SetHidden(false)
            if self.portraitGlow then
                self.portraitGlow:SetTexture(silhouette)
                self.portraitGlow:SetHidden(false)
            end
            if self.portraitFallback then self.portraitFallback:SetHidden(true) end
        else
            self.portrait:SetHidden(true)
            if self.portraitGlow then self.portraitGlow:SetHidden(true) end
            if self.portraitFallback then self.portraitFallback:SetHidden(false) end
        end
    end

    local activePair = ACTIVE_WEAPON_PAIR_MAIN or 1
    if self.actor == "PLAYER" and type(GetActiveWeaponPairInfo) == "function" then
        activePair = safe(GetActiveWeaponPairInfo, ACTIVE_WEAPON_PAIR_MAIN or 1)
    end

    local equipped = 0
    if bagId ~= nil then
        for _,card in ipairs(self.slotCards or {}) do
            if self:RefreshSlot(card, bagId, activePair) then equipped = equipped + 1 end
        end
    else
        self:ClearSlots("--")
    end
    if self.countLabel then self.countLabel:SetText(string.format("%d equipped slots", equipped)) end

    if self.barValue then
        if self.actor == "COMPANION" then
            self.barValue:SetText("COMPANION")
        elseif activePair == (ACTIVE_WEAPON_PAIR_BACKUP or 2) then
            self.barValue:SetText("BACK BAR")
        else
            self.barValue:SetText("FRONT BAR")
        end
    end
end

function G:ScheduleRefresh(delay)
    delay = tonumber(delay) or 35
    if self.refreshPending then return end
    self.refreshPending = true
    if type(zo_callLater) == "function" then
        zo_callLater(function()
            self.refreshPending = false
            self:Refresh()
        end, delay)
    else
        self.refreshPending = false
        self:Refresh()
    end
end

function G:UpdateVisibility()
    if not self.window then return end
    local shouldShow = self.gearTabActive == true and self.journalVisible == true and self.manualClosed ~= true
    self.window:SetHidden(not shouldShow)
    if shouldShow then self:Refresh() end
end

function G:OnGearTabChanged(isGear)
    isGear = isGear == true
    if isGear and self.gearTabActive ~= true then self.manualClosed = false end
    self.gearTabActive = isGear
    self:UpdateVisibility()
end

function G:SetJournalVisible(visible)
    self.journalVisible = visible == true
    if not self.journalVisible then self.manualClosed = false end
    self:UpdateVisibility()
end

function G:RegisterEvents()
    if EVENT_INVENTORY_SINGLE_SLOT_UPDATE then
        local wornName = EPC.name .. "_GearPreviewPlayerWorn"
        EVENT_MANAGER:RegisterForEvent(wornName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function()
            if self.actor == "PLAYER" then self:ScheduleRefresh(30) end
        end)
        if REGISTER_FILTER_BAG_ID and BAG_WORN ~= nil then
            EVENT_MANAGER:AddFilterForEvent(wornName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
        end

        if BAG_COMPANION_WORN ~= nil then
            local companionName = EPC.name .. "_GearPreviewCompanionWorn"
            EVENT_MANAGER:RegisterForEvent(companionName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function()
                if self.actor == "COMPANION" then self:ScheduleRefresh(30) end
            end)
            if REGISTER_FILTER_BAG_ID then
                EVENT_MANAGER:AddFilterForEvent(companionName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_COMPANION_WORN)
            end
        end
    end

    if EVENT_INVENTORY_FULL_UPDATE then
        EVENT_MANAGER:RegisterForEvent(EPC.name .. "_GearPreviewFullInventory", EVENT_INVENTORY_FULL_UPDATE, function() self:ScheduleRefresh(50) end)
    end
    if EVENT_ACTIVE_WEAPON_PAIR_CHANGED then
        EVENT_MANAGER:RegisterForEvent(EPC.name .. "_GearPreviewWeaponPair", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, function() self:ScheduleRefresh(20) end)
    end
    if EVENT_ACTIVE_COMPANION_STATE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(EPC.name .. "_GearPreviewCompanionState", EVENT_ACTIVE_COMPANION_STATE_CHANGED, function()
            self:ScheduleRefresh(40)
        end)
    end
    if EVENT_PLAYER_ACTIVATED then
        EVENT_MANAGER:RegisterForEvent(EPC.name .. "_GearPreviewActivated", EVENT_PLAYER_ACTIVATED, function() self:ScheduleRefresh(80) end)
    end
end

function G:Initialize()
    self:EnsureSaved()
    self:Create()
    self:RegisterEvents()
    self.gearTabActive = false
    self.journalVisible = false
    self:Refresh()
end
