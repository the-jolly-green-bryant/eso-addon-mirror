KayzarUI = KayzarUI or {}
local KayzarUI = KayzarUI

KayzarUI.ActionBar = {}
local AB = KayzarUI.ActionBar
local EM = EVENT_MANAGER
local WM = WINDOW_MANAGER

local SLOT_FIRST = 3
local SLOT_ULT   = 8

local function GOC(name, parent, ct)
    local c = _G[name]
    if c then
        c:SetHidden(false)
        c:ClearAnchors()
        if parent then c:SetParent(parent) end
        return c
    end
    return WM:CreateControl(name, parent, ct)
end

local function GOTLW(name)
    local c = _G[name]
    if c then
        c:SetHidden(false)
        c:ClearAnchors()
        return c
    end
    return WM:CreateTopLevelWindow(name)
end

function AB:Initialize()
    self.sv = KayzarUI.sv.actionBar
    self.slots = {}
    zo_callLater(function() self:Setup() end, 500)
end

function AB:Setup()
    local sv = self.sv
    for i = SLOT_FIRST, SLOT_ULT do
        local sc = ZO_ActionBar1 and ZO_ActionBar1:GetNamedChild("Button" .. i)
        if sc then
            if sv.showCooldownText then
                local cd = GOC("KayzarUI_CD" .. i, sc, CT_LABEL)
                cd:SetAnchorFill()
                cd:SetFont("ZoFontGameBold")
                cd:SetColor(1, 1, 1, 1)
                cd:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
                cd:SetVerticalAlignment(TEXT_ALIGN_CENTER)
                cd:SetDrawLayer(DL_OVERLAY)
                cd:SetHidden(true)
                self.slots[i] = {cd = cd}
            end
            if i == SLOT_ULT and sv.showUltimateCost then
                local uc = KayzarUI.sv.ultimateColor
                local cost = GOC("KayzarUI_UltC", sc, CT_LABEL)
                cost:SetDimensions(sc:GetWidth(), 14)
                cost:SetAnchor(BOTTOM, sc, BOTTOM, 0, -1)
                cost:SetFont("ZoFontGameSmall")
                cost:SetColor(uc.r, uc.g, uc.b, 1)
                cost:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
                cost:SetDrawLayer(DL_OVERLAY)
                self.ultCost = cost
            end
        end
    end
    if sv.showBarIndicator then self:CreateBarIndicator() end
    self:RegisterEvents()
end

------------------------------------------------------------------------
-- BAR INDICATOR
------------------------------------------------------------------------
function AB:CreateBarIndicator()
    local sv = self.sv
    local biW = sv.barIndicatorWidth or 44
    local biH = sv.barIndicatorHeight or 26

    local ind = GOTLW("KayzarUI_BarIndicator")
    ind:SetDimensions(biW, biH)
    ind:SetAnchor(CENTER, GuiRoot, CENTER, sv.barIndicatorOffsetX or 0, sv.barIndicatorOffsetY or 300)
    if sv.barIndicatorPosX ~= nil and sv.barIndicatorPosY ~= nil then
        ind:ClearAnchors()
        ind:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.barIndicatorPosX, sv.barIndicatorPosY)
    end
    ind:SetMovable(not KayzarUI.sv.lockFrames)
    ind:SetMouseEnabled(true)
    ind:SetClampedToScreen(true)

    local bg = GOC("KayzarUI_BarIndBG", ind, CT_TEXTURE)
    bg:SetAnchorFill()
    bg:SetTexture("KayzarUI/textures/bg_dark.dds")
    bg:SetColor(0.05, 0.02, 0.04, 0.8)

    local brd = GOC("KayzarUI_BarIndBrd", ind, CT_TEXTURE)
    brd:SetAnchorFill()
    brd:SetTexture("KayzarUI/textures/border_thin.dds")
    local ac = KayzarUI.sv.accentColor
    brd:SetColor(ac.r, ac.g, ac.b, 0.5)

    local iconSize = math.min(biH - 6, 16)
    local icon = GOC("KayzarUI_BarIndIcon", ind, CT_TEXTURE)
    icon:SetDimensions(iconSize, iconSize)
    icon:SetAnchor(LEFT, ind, LEFT, 4, 0)
    icon:SetTexture("EsoUI/Art/Inventory/inventory_tabIcon_weapons_up.dds")
    icon:SetColor(ac.r, ac.g, ac.b, 1)

    local lbl = GOC("KayzarUI_BarIndLbl", ind, CT_LABEL)
    lbl:SetDimensions(biW - iconSize - 8, biH)
    lbl:SetAnchor(LEFT, icon, RIGHT, 2, 0)
    lbl:SetFont("ZoFontGameBold")
    lbl:SetColor(ac.r, ac.g, ac.b, 1)
    lbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    lbl:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    ind:SetHandler("OnMoveStop", function(c)
        sv.barIndicatorPosX = c:GetLeft()
        sv.barIndicatorPosY = c:GetTop()
    end)

    self.barIndicator      = ind
    self.barIndicatorLabel = lbl
    self.barIndicatorIcon  = icon
    self.barIndicatorBorder = brd
    self:RefreshBarIndicator()
end

function AB:RefreshBarIndicator()
    if not self.barIndicatorLabel then return end
    local pair = GetActiveWeaponPairInfo()
    self.barIndicatorLabel:SetText(pair == ACTIVE_WEAPON_PAIR_BACKUP and "2" or "1")
    local ac = KayzarUI.sv.accentColor
    self.barIndicatorLabel:SetColor(ac.r, ac.g, ac.b, 1)
    if self.barIndicatorIcon then self.barIndicatorIcon:SetColor(ac.r, ac.g, ac.b, 1) end
    if self.barIndicatorBorder then self.barIndicatorBorder:SetColor(ac.r, ac.g, ac.b, 0.5) end
    local el = KayzarUI.sv.elements or {}
    if self.barIndicator then self.barIndicator:SetHidden(el.barIndicator == false) end
end

function AB:Refresh()
    if self.ultCost then
        local uc = KayzarUI.sv.ultimateColor
        self.ultCost:SetColor(uc.r, uc.g, uc.b, 1)
    end
    self:RefreshBarIndicator()
end

function AB:RefreshCooldowns()
    for i, slot in pairs(self.slots) do
        local remain = GetSlotCooldownInfo(i)
        if remain and remain > 0 then
            slot.cd:SetHidden(false)
            slot.cd:SetText(string.format("%.1f", remain / 1000))
        else
            slot.cd:SetHidden(true)
        end
    end
end

function AB:RefreshUltCost()
    if not self.ultCost then return end
    local cost = GetSlotAbilityCost(SLOT_ULT, COMBAT_MECHANIC_FLAGS_ULTIMATE)
    self.ultCost:SetText((cost and cost > 0) and tostring(cost) or "")
end

function AB:RegisterEvents()
    local ns = "KayzarUI_AB"
    EM:RegisterForUpdate(ns .. "_Tick", 100, function() self:RefreshCooldowns() end)
    EM:RegisterForEvent(ns .. "_SU", EVENT_ACTION_SLOT_UPDATED, function() self:RefreshUltCost() end)
    EM:RegisterForEvent(ns .. "_SW", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, function()
        zo_callLater(function()
            self:RefreshUltCost()
            self:RefreshBarIndicator()
        end, 100)
    end)
    self:RefreshUltCost()
end
