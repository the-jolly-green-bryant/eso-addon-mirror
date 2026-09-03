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

local function bindingKeyText(keyCode)
    keyCode = tonumber(keyCode)
    if not keyCode or (KEY_INVALID ~= nil and keyCode == KEY_INVALID) then return "" end
    local text = ""
    if type(ZO_Keybindings_GetKeyText) == "function" then
        text = tostring(safe(ZO_Keybindings_GetKeyText, "", keyCode) or "")
    end
    if text == "" and type(GetKeyName) == "function" then
        text = tostring(safe(GetKeyName, "", keyCode) or "")
    end
    return text
end

local function compactBindingText(text)
    text = tostring(text or "")
    if text == "" then return text end
    -- Keep the overlay readable for uncommon mouse/numpad bindings without
    -- changing what key the player actually configured.
    text = text:gsub("MOUSE BUTTON ", "M")
    text = text:gsub("MOUSEBUTTON", "M")
    text = text:gsub("NUMPAD ", "N")
    text = text:gsub("NUMPAD", "N")
    text = text:gsub("CONTROL", "CTRL")
    text = text:gsub("COMMAND", "CMD")
    return text
end

function A:GetActionBindingName(slot)
    slot = tonumber(slot)
    if not slot then return nil end
    if slot >= 3 and slot <= 8 then
        return "ACTION_BUTTON_" .. tostring(slot)
    end
    return nil
end

function A:GetBindingTextForSlot(slot)
    self.bindingTextCache = self.bindingTextCache or {}
    local cached = self.bindingTextCache[slot]
    if cached ~= nil then return cached end

    local actionName = self:GetActionBindingName(slot)
    if not actionName then return "" end
    local preferGamepad = type(IsInGamepadPreferredMode) == "function" and safe(IsInGamepadPreferredMode, false) == true
    local key, mod1, mod2, mod3, mod4
    if type(GetHighestPriorityActionBindingInfoFromName) == "function" then
        key, mod1, mod2, mod3, mod4 = safe(GetHighestPriorityActionBindingInfoFromName, nil, actionName, preferGamepad)
    end

    local parts = {}
    local seen = {}
    for _, code in ipairs({mod1, mod2, mod3, mod4}) do
        local n = tonumber(code)
        if n and (KEY_INVALID == nil or n ~= KEY_INVALID) and not seen[n] then
            local t = compactBindingText(bindingKeyText(n))
            if t ~= "" then parts[#parts + 1] = t; seen[n] = true end
        end
    end
    local keyText = compactBindingText(bindingKeyText(key))
    if keyText ~= "" then parts[#parts + 1] = keyText end

    local result = table.concat(parts, "+")
    -- Fallback to ZOS's formatter if the direct binding API did not produce text.
    if result == "" and type(ZO_Keybindings_GetBindingStringFromAction) == "function" then
        local textOptions = KEYBIND_TEXT_OPTIONS_ABBREVIATED_NAME or 1
        local textureOptions = KEYBIND_TEXTURE_OPTIONS_NONE or 1
        local maxBindings = tonumber(safe(GetMaxBindingsPerAction, 2)) or 2
        for bindingIndex = 1, math.max(1, math.min(4, maxBindings)) do
            local candidate = tostring(safe(ZO_Keybindings_GetBindingStringFromAction, "", actionName, textOptions, textureOptions, bindingIndex) or "")
            if candidate ~= "" then result = compactBindingText(candidate); break end
        end
    end

    self.bindingTextCache[slot] = result
    return result
end

function A:InvalidateBindingText()
    self.bindingTextCache = {}
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
    -- Keep editable overlays above the LibAddonMenu settings window while HUD
    -- layout mode is active. LAM opens a high-tier window, so normal TopLevel
    -- ordering can otherwise put these controls behind the settings panel.
    if frame.SetDrawLayer and DL_OVERLAY then frame:SetDrawLayer(DL_OVERLAY) end
    if frame.SetDrawTier and DT_HIGH then frame:SetDrawTier(DT_HIGH) end
    if frame.SetDrawLevel then frame:SetDrawLevel(1000) end
    if frame.SetTopLevel then frame:SetTopLevel(true) end
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

    -- High-contrast timer plate keeps countdowns readable over bright ability artwork.
    local timerBack = wm:CreateControl(name .. "TimerBack", frame, CT_BACKDROP)
    timerBack:SetAnchor(CENTER, frame, CENTER, 0, 0)
    timerBack:SetDimensions(54, 34)
    timerBack:SetCenterColor(0, 0, 0, 0.94)
    timerBack:SetEdgeColor(0, 0, 0, 1.00)
    timerBack:SetEdgeTexture(nil, 1, 1, 1)
    timerBack:SetHidden(true)

    local cooldown = wm:CreateControl(name .. "Cooldown", frame, CT_LABEL)
    cooldown:SetAnchorFill(frame)
    cooldown:SetFont("$(BOLD_FONT)|24|soft-shadow-thick")
    cooldown:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    cooldown:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    -- Red cooldown timer for stronger separation from active-duration timers and skill art.
    cooldown:SetColor(1.00, 0.20, 0.20, 1)

    local effect = wm:CreateControl(name .. "Effect", frame, CT_LABEL)
    -- Active ability duration: centered, larger, and high contrast.
    effect:SetAnchorFill(frame)
    effect:SetFont("$(BOLD_FONT)|24|soft-shadow-thick")
    effect:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    effect:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    -- Use the same bright orange as cooldowns: one consistent, high-contrast timer color.
    effect:SetColor(1.00, 0.64, 0.16, 1)

    local slotLabel = wm:CreateControl(name .. "Slot", frame, CT_LABEL)
    slotLabel:SetAnchor(TOPLEFT, frame, TOPLEFT, 3,1)
    slotLabel:SetAnchor(TOPRIGHT, frame, TOPRIGHT, -3,1)
    slotLabel:SetHeight(16)
    slotLabel:SetFont("$(BOLD_FONT)|14|soft-shadow-thick")
    slotLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    slotLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    slotLabel:SetColor(0.95,0.82,0.42,1)
    slotLabel:SetText("")

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

    frame.epcBG,frame.epcIcon,frame.epcShade,frame.epcTimerBack = bg,icon,shade,timerBack
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
    -- Avoid stacking two countdowns in the center. Active effect duration takes priority;
    -- once it ends, the normal slot cooldown can use the same central area.
    if effectRemaining > 0 then
        widget.epcCooldown:SetText("")
    end
    if widget.epcTimerBack then
        local timerVisible = effectRemaining > 0 or (remain > 0 and duration > 0 and not isGlobal)
        widget.epcTimerBack:SetHidden(not timerVisible)
        if timerVisible then
            local timerLabel = effectRemaining > 0 and widget.epcEffect or widget.epcCooldown
            local textWidth, textHeight = 0, 0
            if timerLabel and type(timerLabel.GetTextDimensions) == "function" then
                textWidth, textHeight = timerLabel:GetTextDimensions()
            end
            textWidth = tonumber(textWidth) or 0
            textHeight = tonumber(textHeight) or 0
            widget.epcTimerBack:SetDimensions(math.max(32, textWidth + 18), math.max(28, textHeight + 10))
        end
    end
    widget:SetScale(tonumber(EPC.saved.abilityOverlayScale) or 1.0)
    local isUltimate = widget.epcOrdinal == #self.widgets
    -- Display the player's real ESO Controls binding for this action slot.
    -- Skills 1-5 are ACTION_BUTTON_3..7 and Ultimate is ACTION_BUTTON_8;
    -- never hardcode 1-5/U because every player may rebind these controls.
    local bindingText = self:GetBindingTextForSlot(slot)
    if bindingText == "" then bindingText = "—" end
    if widget.epcBindingText ~= bindingText then
        widget.epcBindingText = bindingText
        widget.epcSlotLabel:SetText(bindingText)
        local chars = #bindingText
        local fontSize = chars <= 4 and 14 or (chars <= 7 and 12 or 10)
        widget.epcSlotLabel:SetFont("$(BOLD_FONT)|" .. tostring(fontSize) .. "|soft-shadow-thick")
    end
    if widget.epcUltimatePct then
        if isUltimate and used and COMBAT_MECHANIC_FLAGS_ULTIMATE then
            local current = safe(GetUnitPower, 0, "player", COMBAT_MECHANIC_FLAGS_ULTIMATE)
            current = tonumber(current) or 0
            -- ESO stores Ultimate as a 0..500 point pool. Show that stored
            -- pool directly as 0%..500% instead of converting the equipped
            -- Ultimate's cost into a 0..100 readiness percentage. Readiness is
            -- still determined from the real slotted Ultimate cost below, so
            -- the meter can continue charging after the ability is usable.
            local cost = tonumber(safe(GetSlotAbilityCost, 0, slot)) or 0
            -- Current ESO Ultimate storage is capped at 500. Keep a defensive
            -- upper bound here so a transient/bad API value cannot overflow UI.
            local pct = math.max(0, math.min(500, math.floor(current + 0.5)))
            local ready = cost > 0 and current >= cost
            widget.epcUltimatePct:SetText(tostring(pct) .. "%")
            widget.epcUltimatePct:SetColor(ready and 1.00 or 0.93, ready and 0.76 or 0.86, ready and 0.18 or 0.36, 1)
            widget.epcUltimatePct:SetHidden(false)
        else
            widget.epcUltimatePct:SetHidden(true)
        end
    end

    if self.layoutMode and (not abilityName or abilityName == "") then
        widget.epcCooldown:SetText(widget.epcOrdinal == #self.widgets and "ULT" or tostring(widget.epcOrdinal))
        if widget.epcTimerBack then widget.epcTimerBack:SetHidden(false) end
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
    if EVENT_PLAYER_ACTIVATED then EVENT_MANAGER:RegisterForEvent(prefix .. "_Activated", EVENT_PLAYER_ACTIVATED, function() self:InvalidateBindingText() self:Refresh() end) end
    if EVENT_KEYBINDINGS_LOADED then EVENT_MANAGER:RegisterForEvent(prefix .. "_BindingsLoaded", EVENT_KEYBINDINGS_LOADED, function() self:InvalidateBindingText() self:Refresh() end) end
    if EVENT_KEYBINDING_SET then EVENT_MANAGER:RegisterForEvent(prefix .. "_BindingSet", EVENT_KEYBINDING_SET, function() self:InvalidateBindingText() self:Refresh() end) end
    if EVENT_KEYBINDING_CLEARED then EVENT_MANAGER:RegisterForEvent(prefix .. "_BindingCleared", EVENT_KEYBINDING_CLEARED, function() self:InvalidateBindingText() self:Refresh() end) end
    if EVENT_GAMEPAD_PREFERRED_MODE_CHANGED then EVENT_MANAGER:RegisterForEvent(prefix .. "_InputMode", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function() self:InvalidateBindingText() self:Refresh() end) end
    EVENT_MANAGER:RegisterForUpdate(prefix .. "_Tick", 150, function() self:Refresh() end)
    self:InvalidateBindingText()
    self:Refresh()
end
