-- ESO Adventurer Suite
-- Dual Action Bar HUD
-- Displays both weapon bars at once with active-bar marking, Skill Style icons,
-- effect timers, stack counters, hotkeys, Ultimate charge, and Smart Combat
-- Advisor highlighting. UI-only: never casts abilities or sends combat input.

local EPC = ESOProgressionCoach
EPC.DualActionBar = EPC.DualActionBar or {}
local D = EPC.DualActionBar
local WM = WINDOW_MANAGER

-- ESO can expose some slotted abilities through runtime variants that are not
-- the progression ability id used by Skill Style collectibles. Normalize the
-- known elemental Destruction Staff variants and Arcanist resource variants
-- before asking the progression/collectible APIs for the selected style.
local SKILL_STYLE_ABILITY_ALIAS_029189 = {
    [28807]=28858, [28849]=28858, [28854]=28858,
    [39012]=39011, [39028]=39011, [39018]=39011,
    [39053]=39052, [39067]=39052, [39073]=39052,
    [29073]=29091, [29078]=29091, [29089]=29091,
    [38944]=38937, [38970]=38937, [38978]=38937,
    [38985]=38984, [38989]=38984, [38993]=38984,
    [28794]=28800, [28798]=28800, [28799]=28800,
    [39145]=39143, [39146]=39143, [39147]=39143,
    [39162]=39161, [39163]=39161, [39167]=39161,
    [83625]=83619, [83628]=83619, [83630]=83619,
    [83682]=83642, [83684]=83642, [83686]=83642,
    [85126]=84434, [85128]=84434, [85130]=84434,
    [193331]=185805, [193398]=186366, [193397]=183122,
    [198282]=183261, [198288]=186189, [198292]=186191,
    [188658]=185794, [188780]=182977, [188787]=185803,
}

local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a,b,c,d,e,f = pcall(fn, ...)
    if not ok or a == nil then return fallback end
    return a,b,c,d,e,f
end

local function clamp(v, lo, hi)
    v = tonumber(v) or lo
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

local function nowMS()
    return tonumber(safe(GetFrameTimeMilliseconds, 0)) or tonumber(safe(GetGameTimeMilliseconds, 0)) or 0
end

local function formatMS(ms)
    ms = tonumber(ms) or 0
    if ms <= 0 then return "" end
    local s = ms / 1000
    if s >= 10 then return tostring(math.ceil(s)) end
    return string.format("%.1f", s)
end

local function getSlots()
    local firstBase = tonumber(ACTION_BAR_FIRST_NORMAL_SLOT_INDEX)
    local ultBase = tonumber(ACTION_BAR_ULTIMATE_SLOT_INDEX)
    local first = firstBase and (firstBase + 1) or 3
    local ult = ultBase and (ultBase + 1) or (first + 5)
    local out = {}
    for i = 0, 4 do out[#out + 1] = first + i end
    out[#out + 1] = ult
    return out
end

function D:GetCategories()
    local primary = rawget(_G, "HOTBAR_CATEGORY_PRIMARY")
    local backup = rawget(_G, "HOTBAR_CATEGORY_BACKUP")
    if primary == nil then primary = 0 end
    if backup == nil then backup = 1 end
    return primary, backup
end

function D:GetBoundAbilityId(slot, category)
    local id = tonumber(safe(GetSlotBoundId, 0, slot, category)) or 0
    local actionType = safe(GetSlotType, nil, slot, category)
    if actionType == rawget(_G, "ACTION_TYPE_CRAFTED_ABILITY") and type(GetAbilityIdForCraftedAbilityId) == "function" then
        id = tonumber(safe(GetAbilityIdForCraftedAbilityId, id, id)) or id
    end
    return id
end

-- Get the selected Skill Style artwork without changing ESO's native action bar.
-- If another installed addon exposes the common GetSkillStyleIconForAbilityId
-- helper, use it first for maximum compatibility with special-case abilities.
function D:GetSkillStyleIcon(abilityId, fallbackIcon)
    if not EPC.saved or EPC.saved.dualActionBarSkillStyles029189 == false then
        return fallbackIcon or ""
    end
    abilityId = tonumber(abilityId) or 0
    if abilityId <= 0 then return fallbackIcon or "" end
    self.styleIconCache029189 = self.styleIconCache029189 or {}
    local cached = self.styleIconCache029189[abilityId]
    if cached ~= nil then
        return cached ~= false and cached or (fallbackIcon or "")
    end

    local external = rawget(_G, "GetSkillStyleIconForAbilityId")
    if type(external) == "function" then
        local icon = safe(external, nil, abilityId)
        if icon and icon ~= "" then
            self.styleIconCache029189[abilityId] = icon
            return icon
        end
    end

    abilityId = SKILL_STYLE_ABILITY_ALIAS_029189[abilityId] or abilityId

    if type(GetSpecificSkillAbilityKeysByAbilityId) == "function"
        and type(GetProgressionSkillProgressionId) == "function"
        and type(GetActiveProgressionSkillAbilityFxOverrideCollectibleId) == "function"
        and type(GetCollectibleIcon) == "function" then
        local skillType, skillLineIndex, skillIndex = safe(GetSpecificSkillAbilityKeysByAbilityId, nil, abilityId)
        if skillType ~= nil and skillLineIndex ~= nil and skillIndex ~= nil then
            local progressionId = tonumber(safe(GetProgressionSkillProgressionId, 0, skillType, skillLineIndex, skillIndex)) or 0
            if progressionId > 0 then
                local collectibleId = tonumber(safe(GetActiveProgressionSkillAbilityFxOverrideCollectibleId, 0, progressionId)) or 0
                if collectibleId > 0 then
                    local icon = tostring(safe(GetCollectibleIcon, "", collectibleId) or "")
                    if icon ~= "" then
                        self.styleIconCache029189[abilityId] = icon
                        return icon
                    end
                end
            end
        end
    end
    self.styleIconCache029189[abilityId] = false
    return fallbackIcon or ""
end

function D:InvalidateStyleCache029189()
    self.styleIconCache029189 = {}
end

function D:GetBindingMarkup(slot)
    if not EPC.saved or EPC.saved.dualActionBarShowHotkeys029189 == false then return "" end
    local overlays = EPC.AbilityOverlays
    if overlays and type(overlays.GetBindingTextForSlot) == "function" then
        return tostring(overlays:GetBindingTextForSlot(slot) or "")
    end
    return ""
end

function D:GetAbilityData(category)
    local rotation = EPC.RotationAssistant
    if rotation and type(rotation.GetBarAbilities029161) == "function" then
        local ok, data = pcall(rotation.GetBarAbilities029161, rotation, category)
        if ok and type(data) == "table" then return data end
    end

    local out = {}
    local slots = self.slots or getSlots()
    for ordinal, slot in ipairs(slots) do
        local remain, duration, global = safe(GetSlotCooldownInfo, 0, slot, category)
        out[#out + 1] = {
            slot = slot,
            ordinal = ordinal,
            category = category,
            abilityId = self:GetBoundAbilityId(slot, category),
            name = tostring(safe(GetSlotName, "", slot, category) or ""),
            icon = tostring(safe(GetSlotTexture, "", slot, category) or ""),
            used = safe(IsSlotUsed, false, slot, category) == true,
            remain = tonumber(remain) or 0,
            duration = tonumber(duration) or 0,
            global = global == true,
            effect = tonumber(safe(GetActionSlotEffectTimeRemaining, 0, slot, category)) or 0,
            isUltimate = ordinal == #slots,
        }
    end
    return out
end

function D:GetTrackedState(ability)
    local remaining = math.max(0, tonumber(ability and ability.effect) or 0)
    local stacks = 0
    local threshold = 0
    local rotation = EPC.RotationAssistant
    if rotation and ability and type(rotation.ClassifyAbility029161) == "function"
        and type(rotation.GetAbilityEffectState029170) == "function" then
        local okClass, cls = pcall(rotation.ClassifyAbility029161, rotation, ability)
        if okClass and cls then
            local okState, state = pcall(rotation.GetAbilityEffectState029170, rotation, ability, cls)
            if okState and type(state) == "table" then
                remaining = math.max(remaining, tonumber(state.remaining) or 0)
                stacks = math.max(0, tonumber(state.stacks) or 0)
                threshold = math.max(0, tonumber(state.stackThreshold) or 0)
            end
        end
    end
    return remaining, stacks, threshold
end

function D:CreateSlot(parent, rowIndex, ordinal)
    local size = clamp(EPC.saved and EPC.saved.dualActionBarIconSize029189, 42, 78)
    local name = "EAS_DualActionBar_R" .. tostring(rowIndex) .. "_S" .. tostring(ordinal)
    local frame = WM:CreateControl(name, parent, CT_CONTROL)
    frame:SetDimensions(size, size)

    local bg = WM:CreateControl(name .. "BG", frame, CT_BACKDROP)
    bg:SetAnchorFill(frame)
    bg:SetCenterColor(0.01, 0.015, 0.025, 0.82)
    bg:SetEdgeColor(0.18, 0.20, 0.26, 0.95)
    bg:SetEdgeTexture(nil, 2, 2, 2)

    local icon = WM:CreateControl(name .. "Icon", frame, CT_TEXTURE)
    icon:SetAnchor(TOPLEFT, frame, TOPLEFT, 3, 3)
    icon:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, -3, -3)

    local shade = WM:CreateControl(name .. "Shade", frame, CT_BACKDROP)
    shade:SetAnchorFill(icon)
    shade:SetCenterColor(0,0,0,0)
    shade:SetEdgeColor(0,0,0,0)

    local timer = WM:CreateControl(name .. "Timer", frame, CT_LABEL)
    timer:SetAnchor(CENTER, frame, CENTER, 0, 4)
    timer:SetDimensions(size - 4, 24)
    timer:SetFont("$(BOLD_FONT)|18|soft-shadow-thick")
    timer:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    timer:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    timer:SetColor(1.00, 0.78, 0.20, 1)

    local stack = WM:CreateControl(name .. "Stack", frame, CT_LABEL)
    stack:SetAnchor(TOPRIGHT, frame, TOPRIGHT, -3, 1)
    stack:SetDimensions(32, 20)
    stack:SetFont("$(BOLD_FONT)|16|soft-shadow-thick")
    stack:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    stack:SetColor(0.98, 0.95, 0.76, 1)

    local hotkey = WM:CreateControl(name .. "Hotkey", frame, CT_LABEL)
    hotkey:SetAnchor(TOPLEFT, frame, TOPLEFT, 3, 1)
    hotkey:SetDimensions(size - 6, 20)
    hotkey:SetFont("$(BOLD_FONT)|13|soft-shadow-thick")
    hotkey:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    hotkey:SetColor(0.96, 0.88, 0.60, 1)

    local ultimate = WM:CreateControl(name .. "Ultimate", frame, CT_LABEL)
    ultimate:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, -3, -1)
    ultimate:SetDimensions(40, 18)
    ultimate:SetFont("ZoFontGameSmall")
    ultimate:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    ultimate:SetColor(1.00, 0.84, 0.30, 1)

    local smart = WM:CreateControl(name .. "Smart", frame, CT_BACKDROP)
    smart:SetAnchor(TOPLEFT, frame, TOPLEFT, -4, -4)
    smart:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, 4, 4)
    smart:SetCenterColor(1.00, 0.66, 0.05, 0.06)
    smart:SetEdgeColor(1.00, 0.86, 0.16, 1)
    smart:SetEdgeTexture(nil, 4, 4, 4)
    smart:SetHidden(true)
    smart:SetMouseEnabled(false)
    if smart.SetDrawLayer and DL_OVERLAY then smart:SetDrawLayer(DL_OVERLAY) end
    if smart.SetDrawLevel then smart:SetDrawLevel(1500) end

    local swap = WM:CreateControl(name .. "Swap", frame, CT_LABEL)
    swap:SetAnchor(BOTTOM, frame, TOP, 0, -1)
    swap:SetDimensions(size + 20, 18)
    swap:SetFont("$(BOLD_FONT)|12|soft-shadow-thick")
    swap:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    swap:SetColor(1.00, 0.74, 0.12, 1)
    swap:SetText("SWAP")
    swap:SetHidden(true)

    frame.epcBG = bg
    frame.epcIcon = icon
    frame.epcShade = shade
    frame.epcTimer = timer
    frame.epcStack = stack
    frame.epcHotkey = hotkey
    frame.epcUltimate = ultimate
    frame.epcSmart = smart
    frame.epcSwap = swap
    frame.epcOrdinal = ordinal
    return frame
end

function D:CreateRow(parent, rowIndex, category, barNumber)
    local row = WM:CreateControl("EAS_DualActionBar_Row" .. tostring(rowIndex), parent, CT_CONTROL)
    row.epcCategory = category
    row.epcBarNumber = barNumber
    row.slots = {}

    local marker = WM:CreateControl("EAS_DualActionBar_Row" .. tostring(rowIndex) .. "Marker", row, CT_BACKDROP)
    marker:SetDimensions(54, 34)
    marker:SetCenterColor(0.02, 0.025, 0.04, 0.90)
    marker:SetEdgeColor(0.30, 0.32, 0.38, 0.95)
    marker:SetEdgeTexture(nil, 2, 2, 2)

    -- Texture-only ESO weapons icon. Do NOT inherit the weapon-swap button
    -- virtual here: that control also renders the player's weapon-swap keybind
    -- (for example G), which is not wanted as an active-bar indicator.
    local markerIcon = WM:CreateControl("EAS_DualActionBar_Row" .. tostring(rowIndex) .. "MarkerIcon", marker, CT_TEXTURE)
    markerIcon:SetDimensions(28, 28)
    markerIcon:SetMouseEnabled(false)
    markerIcon:SetHidden(true)
    local markerTexture = ""
    local itemFilterUtils = rawget(_G, "ZO_ItemFilterUtils")
    local weaponsCategory = rawget(_G, "ITEM_TYPE_DISPLAY_CATEGORY_WEAPONS")
    if itemFilterUtils and type(itemFilterUtils.GetItemTypeDisplayCategoryFilterDisplayInfo) == "function" and weaponsCategory ~= nil then
        local ok, filterData = pcall(itemFilterUtils.GetItemTypeDisplayCategoryFilterDisplayInfo, weaponsCategory)
        if ok and type(filterData) == "table" and type(filterData.icons) == "table" then
            markerTexture = tostring(filterData.icons.up or filterData.icons.down or filterData.icons.over or "")
        end
    end
    -- Defensive fallback to ESO's stock inventory weapons-tab artwork path.
    if markerTexture == "" then markerTexture = "EsoUI/Art/Inventory/inventory_tabIcon_weapons_up.dds" end
    markerIcon:SetTexture(markerTexture)

    local markerText = WM:CreateControl("EAS_DualActionBar_Row" .. tostring(rowIndex) .. "MarkerText", marker, CT_LABEL)
    markerText:SetAnchorFill(marker)
    markerText:SetFont("$(BOLD_FONT)|16|soft-shadow-thick")
    markerText:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    markerText:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    markerText:SetColor(0.75, 0.77, 0.82, 1)

    row.marker = marker
    row.markerIcon = markerIcon
    row.markerText = markerText
    return row
end

function D:GetBarOrder()
    local primary, backup = self:GetCategories()
    if EPC.saved and EPC.saved.dualActionBarPrimaryOnTop029189 == true then
        return {
            { category = primary, number = 1 },
            { category = backup, number = 2 },
        }
    end
    return {
        { category = backup, number = 2 },
        { category = primary, number = 1 },
    }
end

function D:ApplyDimensions(force)
    if not self.window then return end
    local size = clamp(EPC.saved and EPC.saved.dualActionBarIconSize029189, 42, 78)
    local gap = clamp(EPC.saved and EPC.saved.dualActionBarButtonGap029189, 0, 18)
    local rowGap = clamp(EPC.saved and EPC.saved.dualActionBarRowGap029189, 0, 24)
    local scale = clamp(EPC.saved and EPC.saved.dualActionBarScale029189, 0.65, 1.80)
    local primaryOnTop = EPC.saved and EPC.saved.dualActionBarPrimaryOnTop029189 == true
    local signature = table.concat({ tostring(size), tostring(gap), tostring(rowGap), tostring(scale), tostring(primaryOnTop) }, ":")
    if force ~= true and self.dimensionSignature029189 == signature then return end
    self.dimensionSignature029189 = signature
    local markerWidth = 58
    local width = markerWidth + (#self.slots * size) + ((#self.slots - 1) * gap) + 8
    local height = (size * 2) + rowGap + 8
    self.window:SetDimensions(width, height)

    local order = self:GetBarOrder()
    for rowIndex, row in ipairs(self.rows or {}) do
        local entry = order[rowIndex]
        row.epcCategory = entry.category
        row.epcBarNumber = entry.number
        row:ClearAnchors()
        row:SetAnchor(TOPLEFT, self.window, TOPLEFT, 0, (rowIndex - 1) * (size + rowGap))
        row:SetDimensions(width, size)
        row.marker:ClearAnchors()
        row.marker:SetAnchor(LEFT, row, LEFT, 0, 0)
        for ordinal, frame in ipairs(row.slots) do
            frame:SetDimensions(size, size)
            frame:ClearAnchors()
            local x = markerWidth + (ordinal - 1) * (size + gap)
            frame:SetAnchor(LEFT, row, LEFT, x, 0)
            frame.epcTimer:SetDimensions(size - 4, 24)
            frame.epcHotkey:SetDimensions(size - 6, 20)
            frame.epcSwap:SetDimensions(size + 20, 18)
        end
    end
    self.window:SetScale(scale)
end

function D:AnchorWindow()
    if not self.window then return end
    self.window:ClearAnchors()
    local left = tonumber(EPC.saved and EPC.saved.dualActionBarLeft029189) or -1
    local top = tonumber(EPC.saved and EPC.saved.dualActionBarTop029189) or -1
    if left >= 0 and top >= 0 then
        self.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    else
        self.window:SetAnchor(BOTTOM, GuiRoot, BOTTOM, 0, -150)
    end
end

function D:CreateUI()
    if self.window then return end
    self.slots = getSlots()
    local window = WM:CreateTopLevelWindow("EAS_DualActionBarHUD029189")
    window:SetClampedToScreen(true)
    window:SetMouseEnabled(false)
    window:SetMovable(false)
    window:SetHidden(true)
    if window.SetDrawLayer and DL_OVERLAY then window:SetDrawLayer(DL_OVERLAY) end
    if window.SetDrawTier and DT_HIGH then window:SetDrawTier(DT_HIGH) end
    if window.SetDrawLevel then window:SetDrawLevel(920) end

    window:SetHandler("OnMoveStop", function(control)
        if EPC.saved then
            EPC.saved.dualActionBarLeft029189 = control:GetLeft()
            EPC.saved.dualActionBarTop029189 = control:GetTop()
        end
    end)

    self.window = window
    self.rows = {}
    local order = self:GetBarOrder()
    for rowIndex = 1, 2 do
        local entry = order[rowIndex]
        local row = self:CreateRow(window, rowIndex, entry.category, entry.number)
        for ordinal = 1, #self.slots do
            row.slots[ordinal] = self:CreateSlot(row, rowIndex, ordinal)
        end
        self.rows[rowIndex] = row
    end
    self:ApplyDimensions(true)
    self:AnchorWindow()
end

function D:GetMarkerMode029191()
    local mode = tostring(EPC.saved and EPC.saved.dualActionBarMarkerStyle029189 or "ICON_GLOW")
    -- Migrate older styles without forcing users to reset saved vars.
    if mode == "ARROW_NUMBER" then mode = "ICON_GLOW" end
    if mode == "ARROW" then mode = "ICON" end
    if mode == "ICON_NUMBER" then mode = "ICON_GLOW" end
    return mode
end

function D:RefreshMarker029191(row, active)
    local mode = self:GetMarkerMode029191()
    local icon = row.markerIcon
    local text = row.markerText
    if icon then
        icon:ClearAnchors()
        icon:SetHidden(not active or mode == "NUMBER")
        if active and mode ~= "NUMBER" then
            icon:SetAnchor(CENTER, row.marker, CENTER, 0, 0)
            icon:SetAlpha(1)
        end
    end

    text:ClearAnchors()
    if mode == "NUMBER" then
        text:SetText(tostring(row.epcBarNumber))
        text:SetAnchorFill(row.marker)
        text:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    else
        text:SetText("")
        text:SetAnchorFill(row.marker)
        text:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    end
end

function D:RefreshRow(row, activeCategory)
    local category = row.epcCategory
    local active = category == activeCategory
    local inactiveAlpha = clamp((EPC.saved and EPC.saved.dualActionBarInactiveAlpha029189 or 45) / 100, 0.10, 1.0)
    local inactiveDesaturation = clamp((EPC.saved and EPC.saved.dualActionBarInactiveDesaturation029189 or 45) / 100, 0, 1)

    local recommendedOnRow = self.smartCategory029189 == category and self.smartSlot029189 ~= nil
    row:SetAlpha(active and 1.0 or (recommendedOnRow and math.max(inactiveAlpha, 0.78) or inactiveAlpha))
    self:RefreshMarker029191(row, active)
    local markerMode = self:GetMarkerMode029191()
    if active then
        if markerMode == "ICON_GLOW" then
            row.marker:SetCenterColor(0.20, 0.14, 0.03, 0.20)
            row.marker:SetEdgeColor(1.00, 0.74, 0.18, 0.72)
        else
            row.marker:SetCenterColor(0.05, 0.055, 0.08, 0.16)
            row.marker:SetEdgeColor(0.86, 0.72, 0.30, 0.46)
        end
        row.markerText:SetColor(1.00, 0.86, 0.36, 1)
    else
        if markerMode == "NUMBER" then
            row.marker:SetCenterColor(0.02, 0.025, 0.04, 0.88)
            row.marker:SetEdgeColor(0.30, 0.32, 0.38, 0.90)
        else
            row.marker:SetCenterColor(0, 0, 0, 0)
            row.marker:SetEdgeColor(0, 0, 0, 0)
        end
        row.markerText:SetColor(0.72, 0.74, 0.80, 1)
    end

    local bySlot = {}
    for _, ability in ipairs(self:GetAbilityData(category)) do
        bySlot[tonumber(ability.slot)] = ability
    end

    for ordinal, frame in ipairs(row.slots) do
        local slot = self.slots[ordinal]
        local ability = bySlot[slot] or {
            slot = slot, ordinal = ordinal, category = category,
            abilityId = self:GetBoundAbilityId(slot, category),
            name = tostring(safe(GetSlotName, "", slot, category) or ""),
            icon = tostring(safe(GetSlotTexture, "", slot, category) or ""),
            used = safe(IsSlotUsed, false, slot, category) == true,
            effect = tonumber(safe(GetActionSlotEffectTimeRemaining, 0, slot, category)) or 0,
            isUltimate = ordinal == #self.slots,
        }
        local used = ability.used == true
        local fallbackIcon = tostring(ability.icon or "")
        local abilityId = self:GetBoundAbilityId(slot, category)
        if abilityId <= 0 then abilityId = tonumber(ability.abilityId) or 0 end
        local icon = self:GetSkillStyleIcon(abilityId, fallbackIcon)
        frame.epcIcon:SetTexture(icon or "")
        frame.epcIcon:SetHidden(not used or icon == "")
        frame.epcShade:SetHidden(not used)
        if frame.epcIcon.SetDesaturation then
            frame.epcIcon:SetDesaturation(active and 0 or inactiveDesaturation)
        end

        if active then
            frame.epcBG:SetEdgeColor(0.38, 0.30, 0.12, 0.98)
        else
            frame.epcBG:SetEdgeColor(0.16, 0.18, 0.22, 0.90)
        end

        local remaining, stacks, threshold = self:GetTrackedState(ability)
        local showTimers = EPC.saved and EPC.saved.dualActionBarShowTimers029189 ~= false
        local timerText = ""
        if used and showTimers then
            if remaining > 0 then
                timerText = formatMS(remaining)
            else
                local remain = tonumber(ability.remain) or 0
                local duration = tonumber(ability.duration) or 0
                if remain > 0 and duration > 0 and ability.global ~= true then timerText = formatMS(remain) end
            end
        end
        frame.epcTimer:SetText(timerText)

        local showStacks = EPC.saved and EPC.saved.dualActionBarShowStacks029189 ~= false
        if used and showStacks and stacks > 0 then
            if threshold > 0 then
                frame.epcStack:SetText(tostring(math.floor(stacks + 0.5)) .. "/" .. tostring(math.floor(threshold + 0.5)))
            else
                frame.epcStack:SetText(tostring(math.floor(stacks + 0.5)))
            end
        else
            frame.epcStack:SetText("")
        end

        local bind = used and self:GetBindingMarkup(slot) or ""
        frame.epcHotkey:SetText(bind)
        local usesMarkup = bind:find("|t", 1, true) ~= nil
        frame.epcHotkey:SetFont(usesMarkup and "$(BOLD_FONT)|14|soft-shadow-thick" or "$(BOLD_FONT)|13|soft-shadow-thick")

        local isUltimate = ordinal == #self.slots
        if used and isUltimate and COMBAT_MECHANIC_FLAGS_ULTIMATE then
            local current = tonumber((safe(GetUnitPower, 0, "player", COMBAT_MECHANIC_FLAGS_ULTIMATE))) or 0
            frame.epcUltimate:SetText(tostring(math.max(0, math.floor(current + 0.5))) .. "%")
        else
            frame.epcUltimate:SetText("")
        end

        local smartMatch = self.smartSlot029189 ~= nil
            and tonumber(self.smartSlot029189) == tonumber(slot)
            and self.smartCategory029189 == category
        frame.epcSmart:SetHidden(not smartMatch)
        frame.epcSwap:SetHidden(not (smartMatch and self.smartNeedsSwap029189 == true))
        if smartMatch then
            frame.epcSmart:SetAlpha(0.92)
        end

        if self.layoutMode and not used then
            frame.epcIcon:SetHidden(true)
            frame.epcTimer:SetText(isUltimate and "ULT" or tostring(ordinal))
            frame.epcHotkey:SetText("")
            frame.epcBG:SetCenterColor(0.02, 0.025, 0.04, 0.88)
        end
    end
end

-- v0.29.341: obsolete pre-0.29.311 full Refresh implementation removed.

function D:SetSmartRecommendation029189(slot, category, pulse, needsSwap)
    self.smartSlot029189 = tonumber(slot)
    self.smartCategory029189 = category
    self.smartPulse029189 = tonumber(pulse)
    self.smartNeedsSwap029189 = needsSwap == true
    return self.smartSlot029189 ~= nil
end

function D:ClearSmartRecommendation029189()
    self.smartSlot029189 = nil
    self.smartCategory029189 = nil
    self.smartPulse029189 = nil
    self.smartNeedsSwap029189 = false
end

function D:SetLayoutMode(active)
    self:CreateUI()
    self.layoutMode = active == true
    self.window:SetMouseEnabled(self.layoutMode)
    self.window:SetMovable(self.layoutMode)
    if self.layoutMode and self.window.SetDrawLevel then self.window:SetDrawLevel(1200) end
    self:Refresh()
end

function D:RaiseForLayout()
    if not self.window or not self.layoutMode then return end
    if self.window.SetTopLevel then self.window:SetTopLevel(true) end
    if self.window.SetDrawLayer and DL_OVERLAY then self.window:SetDrawLayer(DL_OVERLAY) end
    if self.window.SetDrawTier and DT_HIGH then self.window:SetDrawTier(DT_HIGH) end
    if self.window.SetDrawLevel then self.window:SetDrawLevel(1200) end
    if self.window.BringWindowToTop then self.window:BringWindowToTop() end
end

function D:ResetPosition()
    if EPC.saved then
        EPC.saved.dualActionBarLeft029189 = -1
        EPC.saved.dualActionBarTop029189 = -1
    end
    self:AnchorWindow()
end

-- v0.29.341: obsolete 200 ms Dual Action Bar initializer removed; the optimized initializer below is authoritative.

-- ============================================================================
-- v0.29.311 - Dual Action Bar frame-time hotfix
-- The previous 200 ms tick called the Rotation Assistant's full two-bar ability
-- model, which resolves descriptions, runtime metadata, buff types, effective
-- ids, effect classification and tracked-state matching for every slot. That is
-- appropriate for recommendation scoring, not for a HUD renderer. Keep stable
-- slot presentation event-driven and restrict the gameplay tick to cheap live
-- values only.
-- ============================================================================

local function EAS_DAB_Normalize029311(value)
    local text = string.lower(tostring(value or ""))
    text = text:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
    text = text:gsub("[^%w%s%%'%-]", " ")
    text = text:gsub("%s+", " ")
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    return text
end

local function EAS_DAB_SetText029311(control, owner, key, value)
    if not control or not owner then return end
    value = tostring(value or "")
    if owner[key] ~= value then
        owner[key] = value
        control:SetText(value)
    end
end

local function EAS_DAB_SetHidden029311(control, owner, key, hidden)
    if not control or not owner then return end
    hidden = hidden == true
    if owner[key] ~= hidden then
        owner[key] = hidden
        control:SetHidden(hidden)
    end
end

local function EAS_DAB_SetTexture029311(control, owner, key, texture)
    if not control or not owner then return end
    texture = tostring(texture or "")
    if owner[key] ~= texture then
        owner[key] = texture
        control:SetTexture(texture)
    end
end

function D:GetLightAbilityData029311(category)
    local out = {}
    local slots = self.slots or getSlots()
    for ordinal, slot in ipairs(slots) do
        local used = safe(IsSlotUsed, false, slot, category) == true
        local abilityId = self:GetBoundAbilityId(slot, category)
        local effectiveId = 0
        if abilityId > 0 and type(GetEffectiveAbilityIdForAbilityOnHotbar) == "function" then
            effectiveId = tonumber(safe(GetEffectiveAbilityIdForAbilityOnHotbar, 0, abilityId, category)) or 0
        end
        out[#out + 1] = {
            slot = slot,
            ordinal = ordinal,
            category = category,
            abilityId = abilityId,
            effectiveAbilityId029311 = effectiveId,
            name = tostring(safe(GetSlotName, "", slot, category) or ""),
            icon = tostring(safe(GetSlotTexture, "", slot, category) or ""),
            used = used,
            isUltimate = ordinal == #slots,
        }
    end
    return out
end

function D:BuildLightEffectIndex029311()
    local rotation = EPC.RotationAssistant
    local snapshot = rotation and rotation.smartEffects029169
    if type(snapshot) ~= "table" then return nil end
    local age = math.max(0, nowMS() - (tonumber(snapshot.at) or 0))
    if age > 900 then return nil end

    local index = { byId = {}, byName = {} }
    local function absorb(list)
        for _, effect in ipairs(list or {}) do
            local state = {
                remaining = math.max(0, (tonumber(effect.remaining) or 0) - age),
                stacks = math.max(0, tonumber(effect.stacks) or 0),
            }
            local effectId = tonumber(effect.abilityId) or 0
            if effectId > 0 then
                local previous = index.byId[effectId]
                if not previous or state.remaining > previous.remaining or state.stacks > previous.stacks then
                    index.byId[effectId] = state
                end
            end
            local effectName = tostring(effect.normalizedName or "")
            if effectName == "" then effectName = EAS_DAB_Normalize029311(effect.name) end
            if effectName ~= "" then
                local previous = index.byName[effectName]
                if not previous or state.remaining > previous.remaining or state.stacks > previous.stacks then
                    index.byName[effectName] = state
                end
            end
        end
    end
    absorb(snapshot.player)
    absorb(snapshot.target)
    return index
end

function D:GetLightTrackedState029311(ability, slotEffect, effectIndex)
    local remaining = math.max(0, tonumber(slotEffect) or 0)
    local stacks, threshold = 0, 0
    local name = EAS_DAB_Normalize029311(ability and ability.name or "")
    if name:find("bound armaments", 1, true) then threshold = 4
    elseif name:find("merciless resolve", 1, true) or name:find("relentless focus", 1, true) or name:find("grim focus", 1, true) then threshold = 5
    elseif name:find("molten whip", 1, true) then threshold = 3 end
    if type(effectIndex) ~= "table" then return remaining, stacks, threshold end

    local abilityId = tonumber(ability and ability.abilityId) or 0
    local effectiveId = tonumber(ability and ability.effectiveAbilityId029311) or 0
    local function consider(state)
        if state then
            remaining = math.max(remaining, tonumber(state.remaining) or 0)
            stacks = math.max(stacks, tonumber(state.stacks) or 0)
        end
    end
    if abilityId > 0 then consider(effectIndex.byId[abilityId]) end
    if effectiveId > 0 then consider(effectIndex.byId[effectiveId]) end
    if name ~= "" then consider(effectIndex.byName[name]) end
    return remaining, stacks, threshold
end

function D:IsVisibleNow029311()
    self:CreateUI()
    if not self.window or not EPC.saved then return false end
    local show = EPC.saved.showDualActionBar029189 == true
    if self.layoutMode then show = true end
    if show and not self.layoutMode and EPC.OverlayModeAllows then
        show = EPC:OverlayModeAllows(EPC.saved.dualActionBarVisibility029189 or "ALWAYS")
    end
    if show and not self.layoutMode and EPC.IsGameplayHudSuppressed and EPC:IsGameplayHudSuppressed() then
        show = false
    end
    EAS_DAB_SetHidden029311(self.window, self, "windowHidden029311", not show)
    return show
end

function D:RefreshStatic029311()
    self:CreateUI()
    if not self.window then return end
    self:ApplyDimensions()
    -- Keep the event-driven slot cache current even while a visibility mode has
    -- the bar hidden, so entering combat never needs a surprise metadata rebuild.
    self:IsVisibleNow029311()

    self.staticAbilityData029311 = self.staticAbilityData029311 or {}
    local activeCategory = safe(GetActiveHotbarCategory, nil)
    self.lastActiveCategory029311 = activeCategory
    local inactiveAlpha = clamp((EPC.saved and EPC.saved.dualActionBarInactiveAlpha029189 or 45) / 100, 0.10, 1.0)
    local inactiveDesaturation = clamp((EPC.saved and EPC.saved.dualActionBarInactiveDesaturation029189 or 45) / 100, 0, 1)

    for _, row in ipairs(self.rows or {}) do
        local category = row.epcCategory
        local active = category == activeCategory
        local recommendedOnRow = self.smartCategory029189 == category and self.smartSlot029189 ~= nil
        row:SetAlpha(active and 1.0 or (recommendedOnRow and math.max(inactiveAlpha, 0.78) or inactiveAlpha))
        self:RefreshMarker029191(row, active)
        local markerMode = self:GetMarkerMode029191()
        if active then
            if markerMode == "ICON_GLOW" then
                row.marker:SetCenterColor(0.20, 0.14, 0.03, 0.20)
                row.marker:SetEdgeColor(1.00, 0.74, 0.18, 0.72)
            else
                row.marker:SetCenterColor(0.05, 0.055, 0.08, 0.16)
                row.marker:SetEdgeColor(0.86, 0.72, 0.30, 0.46)
            end
            row.markerText:SetColor(1.00, 0.86, 0.36, 1)
        else
            if markerMode == "NUMBER" then
                row.marker:SetCenterColor(0.02, 0.025, 0.04, 0.88)
                row.marker:SetEdgeColor(0.30, 0.32, 0.38, 0.90)
            else
                row.marker:SetCenterColor(0, 0, 0, 0)
                row.marker:SetEdgeColor(0, 0, 0, 0)
            end
            row.markerText:SetColor(0.72, 0.74, 0.80, 1)
        end

        local data = self:GetLightAbilityData029311(category)
        self.staticAbilityData029311[category] = data
        for ordinal, frame in ipairs(row.slots or {}) do
            local ability = data[ordinal]
            frame.epcAbility029311 = ability
            local used = ability and ability.used == true
            local fallbackIcon = ability and ability.icon or ""
            local icon = used and self:GetSkillStyleIcon(ability.abilityId, fallbackIcon) or ""
            EAS_DAB_SetTexture029311(frame.epcIcon, frame, "iconTexture029311", icon)
            EAS_DAB_SetHidden029311(frame.epcIcon, frame, "iconHidden029311", not used or icon == "")
            EAS_DAB_SetHidden029311(frame.epcShade, frame, "shadeHidden029311", not used)
            if frame.epcIcon.SetDesaturation then frame.epcIcon:SetDesaturation(active and 0 or inactiveDesaturation) end
            if active then frame.epcBG:SetEdgeColor(0.38, 0.30, 0.12, 0.98)
            else frame.epcBG:SetEdgeColor(0.16, 0.18, 0.22, 0.90) end

            local bind = used and self:GetBindingMarkup(ability.slot) or ""
            EAS_DAB_SetText029311(frame.epcHotkey, frame, "hotkeyText029311", bind)
            local usesMarkup = bind:find("|t", 1, true) ~= nil
            local fontKey = usesMarkup and "markup" or "text"
            if frame.hotkeyFont029311 ~= fontKey then
                frame.hotkeyFont029311 = fontKey
                frame.epcHotkey:SetFont(usesMarkup and "$(BOLD_FONT)|14|soft-shadow-thick" or "$(BOLD_FONT)|13|soft-shadow-thick")
            end

            if self.layoutMode and not used then
                EAS_DAB_SetHidden029311(frame.epcIcon, frame, "iconHidden029311", true)
                EAS_DAB_SetText029311(frame.epcTimer, frame, "timerText029311", ability and ability.isUltimate and "ULT" or tostring(ordinal))
                EAS_DAB_SetText029311(frame.epcHotkey, frame, "hotkeyText029311", "")
                frame.epcBG:SetCenterColor(0.02, 0.025, 0.04, 0.88)
            end
        end
    end
end

function D:RefreshDynamic029311(force)
    if not self:IsVisibleNow029311() then return end
    local nowValue = nowMS()
    local inCombat = type(IsUnitInCombat) == "function" and safe(IsUnitInCombat, false, "player") == true
    local minGap = (inCombat or self.layoutMode or self.smartSlot029189 ~= nil) and 250 or 1250
    if force ~= true and self.lastDynamicAt029311 and nowValue - self.lastDynamicAt029311 < minGap then return end
    self.lastDynamicAt029311 = nowValue

    local activeCategory = safe(GetActiveHotbarCategory, nil)
    if activeCategory ~= self.lastActiveCategory029311 then
        self:RefreshStatic029311()
        activeCategory = safe(GetActiveHotbarCategory, nil)
    end

    local ultimatePower = 0
    if COMBAT_MECHANIC_FLAGS_ULTIMATE then
        ultimatePower = tonumber((safe(GetUnitPower, 0, "player", COMBAT_MECHANIC_FLAGS_ULTIMATE))) or 0
    end
    local effectIndex = self:BuildLightEffectIndex029311()

    for _, row in ipairs(self.rows or {}) do
        local category = row.epcCategory
        local active = category == activeCategory
        local recommendedOnRow = self.smartCategory029189 == category and self.smartSlot029189 ~= nil
        local inactiveAlpha = clamp((EPC.saved and EPC.saved.dualActionBarInactiveAlpha029189 or 45) / 100, 0.10, 1.0)
        row:SetAlpha(active and 1.0 or (recommendedOnRow and math.max(inactiveAlpha, 0.78) or inactiveAlpha))

        for ordinal, frame in ipairs(row.slots or {}) do
            local ability = frame.epcAbility029311
            local used = ability and ability.used == true
            if used then
                local remain, duration, global = safe(GetSlotCooldownInfo, 0, ability.slot, category)
                local slotEffect = tonumber(safe(GetActionSlotEffectTimeRemaining, 0, ability.slot, category)) or 0
                local remaining, stacks, threshold = self:GetLightTrackedState029311(ability, slotEffect, effectIndex)
                local timerText = ""
                if EPC.saved.dualActionBarShowTimers029189 ~= false then
                    if remaining > 0 then
                        timerText = formatMS(remaining)
                    else
                        remain, duration = tonumber(remain) or 0, tonumber(duration) or 0
                        if remain > 0 and duration > 0 and global ~= true then timerText = formatMS(remain) end
                    end
                end
                EAS_DAB_SetText029311(frame.epcTimer, frame, "timerText029311", timerText)

                local stackText = ""
                if EPC.saved.dualActionBarShowStacks029189 ~= false and stacks > 0 then
                    if threshold > 0 then stackText = tostring(math.floor(stacks + 0.5)) .. "/" .. tostring(math.floor(threshold + 0.5))
                    else stackText = tostring(math.floor(stacks + 0.5)) end
                end
                EAS_DAB_SetText029311(frame.epcStack, frame, "stackText029311", stackText)

                if ability.isUltimate and COMBAT_MECHANIC_FLAGS_ULTIMATE then
                    EAS_DAB_SetText029311(frame.epcUltimate, frame, "ultimateText029311", tostring(math.max(0, math.floor(ultimatePower + 0.5))) .. "%")
                else
                    EAS_DAB_SetText029311(frame.epcUltimate, frame, "ultimateText029311", "")
                end
            elseif not self.layoutMode then
                EAS_DAB_SetText029311(frame.epcTimer, frame, "timerText029311", "")
                EAS_DAB_SetText029311(frame.epcStack, frame, "stackText029311", "")
                EAS_DAB_SetText029311(frame.epcUltimate, frame, "ultimateText029311", "")
            end

            local smartMatch = self.smartSlot029189 ~= nil
                and ability ~= nil
                and tonumber(self.smartSlot029189) == tonumber(ability.slot)
                and self.smartCategory029189 == category
            EAS_DAB_SetHidden029311(frame.epcSmart, frame, "smartHidden029311", not smartMatch)
            EAS_DAB_SetHidden029311(frame.epcSwap, frame, "swapHidden029311", not (smartMatch and self.smartNeedsSwap029189 == true))
            if smartMatch then
                frame.epcSmart:SetAlpha(0.92)
            end
        end
    end
end

function D:Refresh()
    self:RefreshStatic029311()
    self:RefreshDynamic029311(true)
end

local EAS_DAB_SetSmartBase029311 = D.SetSmartRecommendation029189
function D:SetSmartRecommendation029189(slot, category, pulse, needsSwap)
    local result = EAS_DAB_SetSmartBase029311(self, slot, category, pulse, needsSwap)
    return result
end

local EAS_DAB_ClearSmartBase029311 = D.ClearSmartRecommendation029189
function D:ClearSmartRecommendation029189()
    EAS_DAB_ClearSmartBase029311(self)
    -- Clear stale glow immediately without rebuilding any ability data.
    if self.rows then
        for _, row in ipairs(self.rows) do
            for _, frame in ipairs(row.slots or {}) do
                EAS_DAB_SetHidden029311(frame.epcSmart, frame, "smartHidden029311", true)
                EAS_DAB_SetHidden029311(frame.epcSwap, frame, "swapHidden029311", true)
            end
        end
    end
end

function D:Initialize()
    self:CreateUI()
    local prefix = EPC.name .. "_DualActionBar029189"
    if EVENT_PLAYER_ACTIVATED then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_Activated", EVENT_PLAYER_ACTIVATED, function() self:Refresh() end)
    end
    if EVENT_ACTION_SLOT_UPDATED then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_Slot", EVENT_ACTION_SLOT_UPDATED, function()
            self:InvalidateStyleCache029189()
            self:Refresh()
        end)
    end
    if EVENT_ACTIVE_WEAPON_PAIR_CHANGED then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_Bar", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, function() self:Refresh() end)
    end
    if EVENT_COLLECTIBLE_UPDATED then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_Collectible", EVENT_COLLECTIBLE_UPDATED, function()
            self:InvalidateStyleCache029189()
            self:Refresh()
        end)
    end
    if EVENT_GAMEPAD_PREFERRED_MODE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_Input", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function()
            if EPC.AbilityOverlays and EPC.AbilityOverlays.InvalidateBindingText then EPC.AbilityOverlays:InvalidateBindingText() end
            self:Refresh()
        end)
    end
    if EVENT_PLAYER_COMBAT_STATE then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_Combat", EVENT_PLAYER_COMBAT_STATE, function()
            self:RefreshDynamic029311(true)
        end)
    end
    if EVENT_POWER_UPDATE then
        local powerRegistration = prefix .. "_Power"
        EVENT_MANAGER:RegisterForEvent(powerRegistration, EVENT_POWER_UPDATE, function(_, unitTag, powerIndex, powerType)
            if unitTag == "player" and (powerType == COMBAT_MECHANIC_FLAGS_ULTIMATE or powerType == POWERTYPE_ULTIMATE) then
                self:RefreshDynamic029311(false)
            end
        end)
        -- v0.29.341: without native filters this callback received every Player,
        -- target, group and companion power change even though the Dual Bar only
        -- cares about Player Ultimate. Let ESO discard unrelated power events
        -- before they enter Lua.
        if REGISTER_FILTER_UNIT_TAG then
            EVENT_MANAGER:AddFilterForEvent(powerRegistration, EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
        end
        if REGISTER_FILTER_POWER_TYPE and POWERTYPE_ULTIMATE ~= nil then
            EVENT_MANAGER:AddFilterForEvent(powerRegistration, EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, POWERTYPE_ULTIMATE)
        end
    end

    EVENT_MANAGER:UnregisterForUpdate(prefix .. "_Tick")
    EVENT_MANAGER:RegisterForUpdate(prefix .. "_Tick", 125, function()
        if not EPC.saved or EPC.saved.showDualActionBar029189 ~= true then return end
        local nowValue = type(GetFrameTimeMilliseconds) == "function" and (tonumber(GetFrameTimeMilliseconds()) or 0) or 0
        local inCombat = type(IsUnitInCombat) == "function" and safe(IsUnitInCombat, false, "player") == true
        local gap = inCombat and 125 or 1000
        if not self.lastDynamicTick029315 or (nowValue - self.lastDynamicTick029315) >= gap then
            self.lastDynamicTick029315 = nowValue
            self:RefreshDynamic029311(false)
        end
    end)
    self:Refresh()
end


-- v0.29.321 - Keep the Dual Weapon Bar recommendation visually stable.
-- RotationAssistant intentionally clears generic guidance before selecting the
-- current render target.  Because the Dual Bar is then selected again in the
-- same recommendation pass, the old immediate clear caused the gold border to
-- be hidden and re-shown every scoring refresh.  That looks like a flash even
-- though the highlight alpha itself is no longer animated.
--
-- Defer a real clear for a very short grace window. A same-pass Set cancels the
-- pending clear, so an unchanged recommendation remains continuously visible.
-- A genuine HideActionGuidance still clears normally after the grace window.
local EAS_DAB_ClearSmartImmediate029321 = D.ClearSmartRecommendation029189
local EAS_DAB_SetSmartImmediate029321 = D.SetSmartRecommendation029189

function D:ApplySmartHighlightOnly029321()
    if not self.rows then return end
    local activeCategory = safe(GetActiveHotbarCategory, nil)
    local inactiveAlpha = clamp((EPC.saved and EPC.saved.dualActionBarInactiveAlpha029189 or 45) / 100, 0.10, 1.0)

    for _, row in ipairs(self.rows) do
        local category = row.epcCategory
        local recommendedOnRow = self.smartCategory029189 == category and self.smartSlot029189 ~= nil
        local active = category == activeCategory
        row:SetAlpha(active and 1.0 or (recommendedOnRow and math.max(inactiveAlpha, 0.78) or inactiveAlpha))

        for ordinal, frame in ipairs(row.slots or {}) do
            local ability = frame.epcAbility029311
            local slot = ability and ability.slot or self.slots[ordinal]
            local smartMatch = self.smartSlot029189 ~= nil
                and tonumber(self.smartSlot029189) == tonumber(slot)
                and self.smartCategory029189 == category

            if EAS_DAB_SetHidden029311 then
                EAS_DAB_SetHidden029311(frame.epcSmart, frame, "smartHidden029311", not smartMatch)
                EAS_DAB_SetHidden029311(frame.epcSwap, frame, "swapHidden029311", not (smartMatch and self.smartNeedsSwap029189 == true))
            else
                frame.epcSmart:SetHidden(not smartMatch)
                frame.epcSwap:SetHidden(not (smartMatch and self.smartNeedsSwap029189 == true))
            end
            if smartMatch then frame.epcSmart:SetAlpha(0.92) end
        end
    end
end

function D:SetSmartRecommendation029189(slot, category, pulse, needsSwap)
    -- Cancel any clear queued by the beginning of this same advisor pass.
    self.smartClearGeneration029321 = (tonumber(self.smartClearGeneration029321) or 0) + 1

    local newSlot = tonumber(slot)
    local newNeedsSwap = needsSwap == true
    local unchanged = self.smartSlot029189 == newSlot
        and self.smartCategory029189 == category
        and self.smartNeedsSwap029189 == newNeedsSwap

    local result = EAS_DAB_SetSmartImmediate029321(self, slot, category, 1.00, needsSwap)

    -- No animation and no metadata rebuild: just keep the 12 lightweight visual
    -- states correct. Reapplying an unchanged recommendation does not hide it.
    self:ApplySmartHighlightOnly029321()
    if unchanged then return result end
    return result
end

function D:ClearSmartRecommendation029189()
    self.smartClearGeneration029321 = (tonumber(self.smartClearGeneration029321) or 0) + 1
    local generation = self.smartClearGeneration029321

    local function reallyClear()
        if self.smartClearGeneration029321 ~= generation then return end
        EAS_DAB_ClearSmartImmediate029321(self)
        self:ApplySmartHighlightOnly029321()
    end

    -- The advisor's ShowActionHighlight clears then sets synchronously. A small
    -- deferred clear prevents that internal handoff from becoming visible.
    if type(zo_callLater) == "function" then
        zo_callLater(reallyClear, 90)
    else
        reallyClear()
    end
end
