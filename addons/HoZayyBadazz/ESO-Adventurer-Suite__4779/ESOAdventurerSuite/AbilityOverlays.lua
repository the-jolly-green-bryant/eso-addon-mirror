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

function A:GetActionBindingName(slot, preferGamepad)
    slot = tonumber(slot)
    if not slot then return nil end
    if slot >= 3 and slot <= 8 then
        -- The player-facing binding lives on ACTION_BUTTON_n for both input
        -- devices. Gamepad selection is handled by the explicit binding query,
        -- not by swapping to the hidden GAMEPAD_ACTION_BUTTON_n helper action.
        return "ACTION_BUTTON_" .. tostring(slot)
    end
    return nil
end

function A:GetBindingTextForAction(actionName, preferGamepad)
    if not actionName or actionName == "" then return "" end

    -- v0.29.201: controller glyphs must bypass the visual keyboard mode and
    -- explicitly query/render the gamepad binding set.
    if preferGamepad == true then
        -- Never fall through to the keyboard formatter while controller prompts
        -- are requested. The central renderer explicitly selects the gamepad
        -- binding device and returns ESO gamepad texture markup. An empty result
        -- is safer than showing a misleading keyboard key.
        if EPC.GetActionBindingMarkup029199 then
            return EPC:GetActionBindingMarkup029199(actionName, 22) or ""
        end
        return ""
    end

    local key, mod1, mod2, mod3, mod4
    if type(GetHighestPriorityActionBindingInfoFromName) == "function" then
        key, mod1, mod2, mod3, mod4 = safe(GetHighestPriorityActionBindingInfoFromName, nil, actionName, false)
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
    if result == "" and type(ZO_Keybindings_GetBindingStringFromAction) == "function" then
        local textOptions = KEYBIND_TEXT_OPTIONS_ABBREVIATED_NAME or 1
        local textureOptions = KEYBIND_TEXTURE_OPTIONS_NONE or 1
        local maxBindings = tonumber(safe(GetMaxBindingsPerAction, 2)) or 2
        for bindingIndex = 1, math.max(1, math.min(4, maxBindings)) do
            local candidate = tostring(safe(ZO_Keybindings_GetBindingStringFromAction, "", actionName, textOptions, textureOptions, bindingIndex) or "")
            if candidate ~= "" then result = compactBindingText(candidate); break end
        end
    end
    return result
end

function A:GetBindingTextForSlot(slot)
    self.bindingTextCache = self.bindingTextCache or {}
    local cached = self.bindingTextCache[slot]
    if cached ~= nil then return cached end

    local preferGamepad = EPC.ShouldUseGamepadPrompts029199 and EPC:ShouldUseGamepadPrompts029199() or (EPC.IsNativeGamepadPreferredMode029197 and EPC:IsNativeGamepadPreferredMode029197()) or (type(IsInGamepadPreferredMode) == "function" and safe(IsInGamepadPreferredMode, false) == true)
    local actionName = self:GetActionBindingName(slot, preferGamepad)
    if not actionName and preferGamepad then
        actionName = self:GetActionBindingName(slot, false)
    end
    if not actionName then return "" end

    local result = self:GetBindingTextForAction(actionName, preferGamepad)
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

    -- Smart Combat Advisor recommendation highlight. Keep every layer parented
    -- to the exact Suite ability frame so it can never drift away from the
    -- visible ability box. v0.29.320 uses a steady soft-gold highlight instead
    -- of a pulsing/flashing animation.
    local smartGlowOuter = wm:CreateControl(name .. "SmartGlowOuter029168", frame, CT_BACKDROP)
    smartGlowOuter:SetAnchor(TOPLEFT, frame, TOPLEFT, -8, -8)
    smartGlowOuter:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, 8, 8)
    smartGlowOuter:SetMouseEnabled(false)
    smartGlowOuter:SetCenterColor(1.00, 0.62, 0.02, 0.018)
    smartGlowOuter:SetEdgeColor(1.00, 0.62, 0.08, 0.42)
    smartGlowOuter:SetEdgeTexture(nil, 8, 8, 8)
    if smartGlowOuter.SetDrawLayer and DL_OVERLAY then smartGlowOuter:SetDrawLayer(DL_OVERLAY) end
    if smartGlowOuter.SetDrawLevel then smartGlowOuter:SetDrawLevel(2498) end
    smartGlowOuter:SetHidden(true)

    local smartGlowMid = wm:CreateControl(name .. "SmartGlowMid029168", frame, CT_BACKDROP)
    smartGlowMid:SetAnchor(TOPLEFT, frame, TOPLEFT, -4, -4)
    smartGlowMid:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, 4, 4)
    smartGlowMid:SetMouseEnabled(false)
    smartGlowMid:SetCenterColor(1.00, 0.72, 0.05, 0.035)
    smartGlowMid:SetEdgeColor(1.00, 0.78, 0.12, 0.72)
    smartGlowMid:SetEdgeTexture(nil, 4, 4, 4)
    if smartGlowMid.SetDrawLayer and DL_OVERLAY then smartGlowMid:SetDrawLayer(DL_OVERLAY) end
    if smartGlowMid.SetDrawLevel then smartGlowMid:SetDrawLevel(2499) end
    smartGlowMid:SetHidden(true)

    local smartHighlight = wm:CreateControl(name .. "SmartHighlight029167", frame, CT_BACKDROP)
    smartHighlight:SetAnchorFill(frame)
    smartHighlight:SetMouseEnabled(false)
    smartHighlight:SetCenterColor(1.00, 0.82, 0.10, 0.08)
    smartHighlight:SetEdgeColor(1.00, 0.96, 0.32, 1.00)
    smartHighlight:SetEdgeTexture(nil, 4, 4, 4)
    if smartHighlight.SetDrawLayer and DL_OVERLAY then smartHighlight:SetDrawLayer(DL_OVERLAY) end
    if smartHighlight.SetDrawLevel then smartHighlight:SetDrawLevel(2500) end
    smartHighlight:SetHidden(true)

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
    slotLabel:SetHeight(24)
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
    frame.epcSmartGlowOuter029168 = smartGlowOuter
    frame.epcSmartGlowMid029168 = smartGlowMid
    frame.epcSmartHighlight029167 = smartHighlight
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
    if widget.epcBindingText ~= bindingText or widget.epcBindingWasUltimate029182 ~= isUltimate then
        widget.epcBindingText = bindingText
        widget.epcBindingWasUltimate029182 = isUltimate
        widget.epcSlotLabel:ClearAnchors()
        if isUltimate then
            -- Ultimate commonly uses a two-button chord (L1+R1). Give that wide
            -- glyph the full top edge and center it instead of squeezing it into
            -- the single-button top-left treatment used by skills 1-5.
            widget.epcSlotLabel:SetAnchor(TOPLEFT, widget, TOPLEFT, 2, 0)
            widget.epcSlotLabel:SetAnchor(TOPRIGHT, widget, TOPRIGHT, -2, 0)
            widget.epcSlotLabel:SetHeight(24)
            widget.epcSlotLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        else
            widget.epcSlotLabel:SetAnchor(TOPLEFT, widget, TOPLEFT, 3, 1)
            widget.epcSlotLabel:SetAnchor(TOPRIGHT, widget, TOPRIGHT, -3, 1)
            widget.epcSlotLabel:SetHeight(24)
            widget.epcSlotLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        end
        widget.epcSlotLabel:SetText(bindingText)
        local usesMarkup = bindingText:find("|t", 1, true) ~= nil
        local chars = #bindingText
        local fontSize = usesMarkup and 14 or (chars <= 4 and 14 or (chars <= 7 and 12 or 10))
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

-- v0.29.167 - Smart Combat Advisor highlight on Suite ability overlays.
function A:SetSmartRecommendation029167(slot, category, pulseAlpha)
    self.smartRecommendedSlot029161 = tonumber(slot)
    self.smartRecommendedCategory029161 = category
    local activeCategory = safe(GetActiveHotbarCategory, nil)
    local shown = false
    -- pulseAlpha is retained for API compatibility, but intentionally ignored.
    for _, widget in ipairs(self.widgets or {}) do
        local highlight = widget and widget.epcSmartHighlight029167
        local mid = widget and widget.epcSmartGlowMid029168
        local outer = widget and widget.epcSmartGlowOuter029168
        if highlight then
            local match = self.smartRecommendedSlot029161 ~= nil
                and tonumber(widget.epcSlot) == self.smartRecommendedSlot029161
                and (category == nil or category == activeCategory)
                and not widget:IsHidden()
            highlight:SetHidden(not match)
            if mid then mid:SetHidden(not match) end
            if outer then outer:SetHidden(not match) end
            if match then
                -- Steady recommendation: readable at a glance without flashing.
                highlight:SetAlpha(1.00)
                if mid then mid:SetAlpha(0.72) end
                if outer then outer:SetAlpha(0.42) end
                shown = true
            end
        end
    end
    return shown
end

function A:ClearSmartRecommendation029167()
    self.smartRecommendedSlot029161 = nil
    self.smartRecommendedCategory029161 = nil
    for _, widget in ipairs(self.widgets or {}) do
        if widget and widget.epcSmartHighlight029167 then
            widget.epcSmartHighlight029167:SetHidden(true)
        end
        if widget and widget.epcSmartGlowMid029168 then
            widget.epcSmartGlowMid029168:SetHidden(true)
        end
        if widget and widget.epcSmartGlowOuter029168 then
            widget.epcSmartGlowOuter029168:SetHidden(true)
        end
    end
end

function A:Refresh()
    self:ApplySize()
    for _,widget in ipairs(self.widgets or {}) do self:RefreshWidget(widget) end
    if self.smartRecommendedSlot029161 then
        self:SetSmartRecommendation029167(self.smartRecommendedSlot029161, self.smartRecommendedCategory029161, 1.0)
    else
        self:ClearSmartRecommendation029167()
    end
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
    EVENT_MANAGER:RegisterForUpdate(prefix .. "_Tick", 125, function()
        local nowValue = GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or 0
        local inCombat = type(IsUnitInCombat) == "function" and safe(IsUnitInCombat, false, "player") == true
        local gap = inCombat and 125 or 1000
        if self.layoutMode or not self.lastTickRefresh029312 or (nowValue - self.lastTickRefresh029312) >= gap then
            self.lastTickRefresh029312 = nowValue
            self:Refresh()
        end
    end)
    self:InvalidateBindingText()
    self:Refresh()
end

-- v0.29.171 - Make the moment-to-moment recommendation unmistakable on the
-- Suite ability row. The existing three-layer glow remains unchanged; this
-- adds a small NEXT badge above only the recommended visible slot.
function A:EnsureSmartNextBadges029171()
    for _, widget in ipairs(self.widgets or {}) do
        if widget and not widget.epcSmartNext029171 then
            local badge = wm:CreateControl(nil, widget, CT_LABEL)
            badge:SetAnchor(BOTTOM, widget, TOP, 0, -5)
            badge:SetDimensions(84, 20)
            badge:SetFont("$(BOLD_FONT)|15|soft-shadow-thick")
            badge:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            badge:SetVerticalAlignment(TEXT_ALIGN_CENTER)
            badge:SetColor(1.00, 0.92, 0.30, 1.00)
            badge:SetText("NEXT")
            if badge.SetDrawLayer and DL_OVERLAY then badge:SetDrawLayer(DL_OVERLAY) end
            if badge.SetDrawLevel then badge:SetDrawLevel(2600) end
            badge:SetHidden(true)
            widget.epcSmartNext029171 = badge
        end
    end
end

local EAS_SetSmartRecommendationBase029171 = A.SetSmartRecommendation029167
function A:SetSmartRecommendation029167(slot, category, pulseAlpha)
    self:EnsureSmartNextBadges029171()
    local shown = EAS_SetSmartRecommendationBase029171(self, slot, category, pulseAlpha)
    local activeCategory = safe(GetActiveHotbarCategory, nil)
    for _, widget in ipairs(self.widgets or {}) do
        local badge = widget and widget.epcSmartNext029171
        if badge then
            local match = shown
                and tonumber(widget.epcSlot) == tonumber(slot)
                and (category == nil or category == activeCategory)
                and not widget:IsHidden()
            badge:SetHidden(not match)
            if match then
                badge:SetAlpha(1.00)
            end
        end
    end
    return shown
end

local EAS_ClearSmartRecommendationBase029171 = A.ClearSmartRecommendation029167
function A:ClearSmartRecommendation029167()
    EAS_ClearSmartRecommendationBase029171(self)
    for _, widget in ipairs(self.widgets or {}) do
        if widget and widget.epcSmartNext029171 then widget.epcSmartNext029171:SetHidden(true) end
    end
end
