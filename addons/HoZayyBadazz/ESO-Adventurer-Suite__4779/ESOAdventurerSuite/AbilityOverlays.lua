-- ESO Adventurer Suite
-- Copyright (c) 2026 HoZayyBadazz. All Rights Reserved.
-- Proprietary source. Unauthorized redistribution, republication, rebranding,
-- or public distribution of modified/derivative versions is prohibited.
-- Private personal-use modifications are permitted. See LICENSE.txt.

local EPC = ESOProgressionCoach
EPC.AbilityOverlays = EPC.AbilityOverlays or {}
local A = EPC.AbilityOverlays
local wm = WINDOW_MANAGER

local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok,a,b,c,d,e = pcall(fn,...)
    if not ok then return fallback end
    return a,b,c,d,e
end

local function nowMS()
    if type(GetFrameTimeMilliseconds) == "function" then return GetFrameTimeMilliseconds() end
    if type(GetGameTimeMilliseconds) == "function" then return GetGameTimeMilliseconds() end
    return 0
end

local function formatMS(ms)
    ms = tonumber(ms) or 0
    if ms <= 0 then return "" end
    local s = ms / 1000
    if s >= 10 then return tostring(math.ceil(s)) end
    return string.format("%.1f", s)
end

function A:GetSlots()
    -- ESO's exported action-bar constants are base indices; the live ZOS
    -- action bar addresses the five normal ability buttons and Ultimate at
    -- constant + 1. Keep the same physical-slot convention here so the
    -- overlays match skills 1-5 in order and the actual Ultimate slot.
    local firstBase = tonumber(ACTION_BAR_FIRST_NORMAL_SLOT_INDEX)
    local ultimateBase = tonumber(ACTION_BAR_ULTIMATE_SLOT_INDEX)
    local first = firstBase and (firstBase + 1) or 3
    local ultimate = ultimateBase and (ultimateBase + 1) or (first + 5)
    local slots = {}
    for offset = 0, 4 do
        slots[#slots + 1] = first + offset
    end
    slots[#slots + 1] = ultimate
    return slots
end

function A:GetPositionKeys(slot)
    return "abilitySlot" .. tostring(slot) .. "Left", "abilitySlot" .. tostring(slot) .. "Top"
end

function A:AnchorWidget(widget, ordinal)
    if not widget then return end
    widget:ClearAnchors()
    local leftKey,topKey = self:GetPositionKeys(widget.epcSlot)
    local left = tonumber(EPC.saved and EPC.saved[leftKey]) or -1
    local top = tonumber(EPC.saved and EPC.saved[topKey]) or -1
    if left >= 0 and top >= 0 then
        widget:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    else
        local offset = (ordinal - 3.5) * 68
        widget:SetAnchor(BOTTOM, GuiRoot, BOTTOM, offset, -118)
    end
end

function A:CreateWidget(slot, ordinal)
    local size = tonumber(EPC.saved and EPC.saved.abilityOverlaySize) or 56
    local name = "EAS_AbilityOverlay_" .. tostring(slot)
    local frame = wm:CreateTopLevelWindow(name)
    frame:SetDimensions(size,size)
    frame:SetClampedToScreen(true)
    frame:SetMouseEnabled(false)
    frame:SetMovable(false)
    frame.epcSlot = slot
    frame.epcOrdinal = ordinal

    local bg = wm:CreateControl(name .. "BG", frame, CT_BACKDROP)
    bg:SetAnchorFill(frame)
    bg:SetCenterColor(0.012,0.015,0.022,0.78)
    bg:SetEdgeColor(0.67,0.51,0.24,0.95)
    bg:SetEdgeTexture(nil,1,1,1)

    local icon = wm:CreateControl(name .. "Icon", frame, CT_TEXTURE)
    icon:SetAnchor(TOPLEFT, frame, TOPLEFT, 3,3)
    icon:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, -3,-3)

    local shade = wm:CreateControl(name .. "Shade", frame, CT_BACKDROP)
    shade:SetAnchorFill(icon)
    shade:SetCenterColor(0,0,0,0)
    shade:SetEdgeColor(0,0,0,0)

    local cooldown = wm:CreateControl(name .. "Cooldown", frame, CT_LABEL)
    cooldown:SetAnchorFill(frame)
    cooldown:SetFont("ZoFontWinH2")
    cooldown:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    cooldown:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    cooldown:SetColor(1,1,1,1)

    local effect = wm:CreateControl(name .. "Effect", frame, CT_LABEL)
    effect:SetAnchor(BOTTOMLEFT, frame, BOTTOMLEFT, 2,-1)
    effect:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, -2,-1)
    effect:SetHeight(14)
    effect:SetFont("ZoFontGameSmall")
    effect:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    effect:SetColor(0.95,0.82,0.42,1)

    local slotLabel = wm:CreateControl(name .. "Slot", frame, CT_LABEL)
    slotLabel:SetAnchor(TOPLEFT, frame, TOPLEFT, 3,1)
    slotLabel:SetDimensions(18,14)
    slotLabel:SetFont("ZoFontGameSmall")
    slotLabel:SetColor(0.95,0.82,0.42,1)
    slotLabel:SetText(tostring(ordinal))

    local ultimatePct = wm:CreateControl(name .. "UltimatePct", frame, CT_LABEL)
    -- Keep Ultimate charge readable without covering the ability artwork.
    -- A compact lower-right label leaves the center of the icon unobstructed.
    ultimatePct:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, -3, -2)
    ultimatePct:SetDimensions(34, 14)
    ultimatePct:SetFont("ZoFontGameSmall")
    ultimatePct:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    ultimatePct:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    ultimatePct:SetColor(1.00,0.86,0.36,1)
    ultimatePct:SetText("")
    ultimatePct:SetHidden(true)

    local hint = wm:CreateControl(name .. "Hint", frame, CT_LABEL)
    hint:SetAnchor(TOP, frame, BOTTOM, 0, 2)
    hint:SetDimensions(90,18)
    hint:SetFont("ZoFontGameSmall")
    hint:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    hint:SetColor(0.95,0.82,0.42,1)
    hint:SetText("DRAG")
    hint:SetHidden(true)

    frame:SetHandler("OnMoveStop", function(control)
        if EPC.saved then
            local lk,tk = A:GetPositionKeys(control.epcSlot)
            EPC.saved[lk] = control:GetLeft()
            EPC.saved[tk] = control:GetTop()
        end
    end)

    frame.epcBG,frame.epcIcon,frame.epcShade = bg,icon,shade
    frame.epcCooldown,frame.epcEffect,frame.epcSlotLabel,frame.epcHint,frame.epcUltimatePct = cooldown,effect,slotLabel,hint,ultimatePct
    self:AnchorWidget(frame, ordinal)
    return frame
end

function A:ApplySize()
    local size = math.max(40, math.min(90, tonumber(EPC.saved and EPC.saved.abilityOverlaySize) or 56))
    for _,widget in ipairs(self.widgets or {}) do
        widget:SetDimensions(size,size)
    end
end

function A:RefreshWidget(widget)
    if not widget then return end
    local category = safe(GetActiveHotbarCategory, nil)
    local slot = widget.epcSlot
    local used = safe(IsSlotUsed, false, slot, category) == true
    local texture = safe(GetSlotTexture, "", slot, category)
    local abilityName = safe(GetSlotName, "", slot, category)
    local show = EPC.saved and EPC.saved.showAbilityOverlays ~= false
    if not self.layoutMode and EPC.OverlayModeAllows then show = show and EPC:OverlayModeAllows("abilityOverlayVisibility") end
    if not self.layoutMode and EPC.IsGameplayHudSuppressed and EPC:IsGameplayHudSuppressed() then show = false end
    if not self.layoutMode and not used then show = false end
    widget:SetHidden(not show)
    if not show then return end

    if texture and texture ~= "" then
        widget.epcIcon:SetTexture(texture)
        widget.epcIcon:SetHidden(false)
    else
        widget.epcIcon:SetHidden(true)
    end

    local usable = safe(IsSlotUsable, true, slot, category) ~= false
    widget.epcShade:SetCenterColor(0,0,0,usable and 0 or 0.48)

    local remain,duration,isGlobal = safe(GetSlotCooldownInfo, 0, slot, category)
    remain,duration = tonumber(remain) or 0, tonumber(duration) or 0
    -- Do not spam the normal global cooldown. Only show a real slot cooldown.
    if remain > 0 and duration > 0 and not isGlobal then
        widget.epcCooldown:SetText(formatMS(remain))
    else
        widget.epcCooldown:SetText("")
    end

    local effectRemaining = tonumber(safe(GetActionSlotEffectTimeRemaining, 0, slot, category)) or 0
    widget.epcEffect:SetText(effectRemaining > 0 and formatMS(effectRemaining) or "")
    widget:SetScale(tonumber(EPC.saved.abilityOverlayScale) or 1.0)
    local isUltimate = widget.epcOrdinal == #self.widgets
    widget.epcSlotLabel:SetText(isUltimate and "U" or tostring(widget.epcOrdinal))
    if widget.epcUltimatePct then
        if isUltimate and used and COMBAT_MECHANIC_FLAGS_ULTIMATE then
            local current, maximum = safe(GetUnitPower, 0, "player", COMBAT_MECHANIC_FLAGS_ULTIMATE)
            current, maximum = tonumber(current) or 0, tonumber(maximum) or 0
            local cost = tonumber(safe(GetSlotAbilityCost, 0, slot, COMBAT_MECHANIC_FLAGS_ULTIMATE, category)) or 0
            local target = cost > 0 and cost or maximum
            local pct = target > 0 and math.floor(math.min(1, current / target) * 100 + 0.5) or 0
            widget.epcUltimatePct:SetText(tostring(pct) .. "%")
            widget.epcUltimatePct:SetColor(pct >= 100 and 1.00 or 0.93, pct >= 100 and 0.76 or 0.86, pct >= 100 and 0.18 or 0.36, 1)
            widget.epcUltimatePct:SetHidden(false)
        else
            widget.epcUltimatePct:SetHidden(true)
        end
    end

    if self.layoutMode and (not abilityName or abilityName == "") then
        widget.epcCooldown:SetText(widget.epcOrdinal == #self.widgets and "ULT" or tostring(widget.epcOrdinal))
    end
end

function A:Refresh()
    self:ApplySize()
    for _,widget in ipairs(self.widgets or {}) do self:RefreshWidget(widget) end
end

function A:SetLayoutMode(active)
    self.layoutMode = active == true
    for _,widget in ipairs(self.widgets or {}) do
        widget:SetMouseEnabled(self.layoutMode)
        widget:SetMovable(self.layoutMode)
        widget.epcHint:SetHidden(not self.layoutMode)
    end
    self:Refresh()
end

function A:ResetPositions()
    if not EPC.saved then return end
    for i,widget in ipairs(self.widgets or {}) do
        local lk,tk = self:GetPositionKeys(widget.epcSlot)
        EPC.saved[lk],EPC.saved[tk] = -1,-1
        self:AnchorWidget(widget,i)
    end
end

function A:Initialize()
    self.layoutMode = false
    self.widgets = {}
    local slots = self:GetSlots()
    for i,slot in ipairs(slots) do self.widgets[i] = self:CreateWidget(slot,i) end
    local prefix = EPC.name .. "_AbilityOverlays"
    if EVENT_ACTION_SLOT_UPDATED then EVENT_MANAGER:RegisterForEvent(prefix .. "_Slot", EVENT_ACTION_SLOT_UPDATED, function() self:Refresh() end) end
    if EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED then EVENT_MANAGER:RegisterForEvent(prefix .. "_Bar", EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, function() self:Refresh() end) end
    if EVENT_ACTIVE_WEAPON_PAIR_CHANGED then EVENT_MANAGER:RegisterForEvent(prefix .. "_Weapon", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, function() self:Refresh() end) end
    if EVENT_PLAYER_COMBAT_STATE then EVENT_MANAGER:RegisterForEvent(prefix .. "_Combat", EVENT_PLAYER_COMBAT_STATE, function() self:Refresh() end) end
    if EVENT_PLAYER_ACTIVATED then EVENT_MANAGER:RegisterForEvent(prefix .. "_Activated", EVENT_PLAYER_ACTIVATED, function() self:Refresh() end) end
    EVENT_MANAGER:RegisterForUpdate(prefix .. "_Tick", 150, function() self:Refresh() end)
    self:Refresh()
end
