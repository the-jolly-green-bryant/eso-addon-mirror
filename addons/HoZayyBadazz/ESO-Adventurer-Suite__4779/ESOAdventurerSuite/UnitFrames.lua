-- ESO Adventurer Suite
-- Copyright (c) 2026 HoZayyBadazz. All Rights Reserved.
-- Proprietary source. Unauthorized redistribution, republication, rebranding,
-- or public distribution of modified/derivative versions is prohibited.
-- Private personal-use modifications are permitted. See LICENSE.txt.

local EPC = ESOProgressionCoach
EPC.UnitFrames = EPC.UnitFrames or {}
local F = EPC.UnitFrames

local wm = WINDOW_MANAGER

local C = {
    bg = {0.018, 0.022, 0.030, 0.94},
    panel = {0.035, 0.042, 0.055, 0.96},
    edge = {0.16, 0.19, 0.25, 0.95},
    edgeSoft = {0.10, 0.12, 0.16, 0.95},
    white = {0.95, 0.96, 0.98, 1},
    text = {0.76, 0.80, 0.86, 1},
    muted = {0.48, 0.53, 0.61, 1},
    gold = {0.91, 0.70, 0.28, 1},
    red = {0.83, 0.22, 0.22, 1},
    green = {0.25, 0.72, 0.40, 1},
    blue = {0.22, 0.49, 0.88, 1},
    orange = {0.91, 0.51, 0.20, 1},
    purple = {0.58, 0.37, 0.86, 1},
    health = {0.68, 0.12, 0.14, 1},
    magicka = {0.15, 0.32, 0.76, 1},
    stamina = {0.16, 0.58, 0.27, 1},
}

-- GetUnitPower() and EVENT_POWER_UPDATE both use POWERTYPE_* values for the
-- resource type. ESO's own unit-frame handlers register
-- REGISTER_FILTER_POWER_TYPE with POWERTYPE_HEALTH/MAGICKA/STAMINA. Using the
-- COMBAT_MECHANIC_FLAGS_* family here can silently filter out the live power
-- events, leaving custom health bars stale until some unrelated refresh occurs.
local POWER_HEALTH = POWERTYPE_HEALTH
local POWER_MAGICKA = POWERTYPE_MAGICKA
local POWER_STAMINA = POWERTYPE_STAMINA

local FILTER_POWER_HEALTH = POWERTYPE_HEALTH
local FILTER_POWER_MAGICKA = POWERTYPE_MAGICKA
local FILTER_POWER_STAMINA = POWERTYPE_STAMINA

local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a, b, c, d, e, f, g, h = pcall(fn, ...)
    if not ok then return fallback end
    return a, b, c, d, e, f, g, h
end

-- Collapse multi-return ESO APIs before numeric conversion. Calling tonumber()
-- directly on safe(...) can accidentally pass an API's second return value as
-- tonumber's optional numeric base (for example GetActiveCompanionLevelInfo).
local function safeNumber(fn, fallback, ...)
    local value = safe(fn, fallback, ...)
    local number = tonumber(value)
    if number ~= nil then return number end
    return tonumber(fallback) or 0
end

local function makeBackdrop(parent, name, centerColor, edgeColor)
    local control = wm:CreateControl(name, parent, CT_BACKDROP)
    control:SetCenterColor(unpack(centerColor or C.panel))
    control:SetEdgeColor(unpack(edgeColor or C.edge))
    control:SetEdgeTexture(nil, 1, 1, 1)
    return control
end

local function makeLabel(parent, name, font, color, align)
    local label = wm:CreateControl(name, parent, CT_LABEL)
    label:SetFont(font or "ZoFontGame")
    label:SetColor(unpack(color or C.white))
    if label.SetHorizontalAlignment then label:SetHorizontalAlignment(align or TEXT_ALIGN_LEFT) end
    if label.SetVerticalAlignment then label:SetVerticalAlignment(TEXT_ALIGN_CENTER) end
    local wrapMode = TEXT_WRAP_MODE_ELLIPSIS or TEXT_WRAP_MODE_TRUNCATE
    if label.SetWrapMode and wrapMode then label:SetWrapMode(wrapMode) end
    if label.SetMaxLineCount then label:SetMaxLineCount(1) end
    return label
end

local function cleanName(name)
    name = tostring(name or "")
    name = string.gsub(name, "%^%a+$", "")
    return name
end

local function compactNumber(value)
    local n = tonumber(value) or 0
    local sign = n < 0 and "-" or ""
    n = math.abs(n)
    if n >= 1000000 then return sign .. string.format("%.2fm", n / 1000000) end
    if n >= 100000 then return sign .. string.format("%.0fk", n / 1000) end
    if n >= 10000 then return sign .. string.format("%.1fk", n / 1000) end
    return sign .. tostring(math.floor(n + 0.5))
end

local function percentText(current, maximum)
    current = tonumber(current) or 0
    maximum = tonumber(maximum) or 0
    if maximum <= 0 then return "--" end
    return tostring(math.floor((current / maximum) * 100 + 0.5)) .. "%"
end

local function nowSeconds()
    if type(GetFrameTimeSeconds) == "function" then return GetFrameTimeSeconds() end
    if type(GetGameTimeMilliseconds) == "function" then return GetGameTimeMilliseconds() / 1000 end
    return 0
end

local function formatAuraTime(endTime)
    endTime = tonumber(endTime) or 0
    if endTime <= 0 then return "" end
    local remaining = math.max(0, endTime - nowSeconds())
    if remaining >= 3600 then return string.format("%dh", math.floor(remaining / 3600)) end
    if remaining >= 60 then return string.format("%dm", math.floor(remaining / 60)) end
    if remaining >= 10 then return string.format("%d", math.floor(remaining + 0.5)) end
    if remaining > 0 then return string.format("%.1f", remaining) end
    return ""
end

local function readPower(unitTag, powerType)
    if not powerType or type(GetUnitPower) ~= "function" then return 0, 0, 0 end
    local ok, current, maximum, effectiveMaximum = pcall(GetUnitPower, unitTag, powerType)
    if not ok then return 0, 0, 0 end
    return tonumber(current) or 0, tonumber(maximum) or 0, tonumber(effectiveMaximum) or tonumber(maximum) or 0
end

local function createFillBar(parent, name, x, y, width, height, color, labelText, textMode)
    local bar = makeBackdrop(parent, name .. "_BG", {0.018, 0.020, 0.026, 0.62}, {0.10, 0.12, 0.16, 0.72})
    bar:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    bar:SetDimensions(width, height)

    local fill = wm:CreateControl(name .. "_Fill", bar, CT_BACKDROP)
    fill:SetAnchor(TOPLEFT, bar, TOPLEFT, 1, 1)
    fill:SetHeight(math.max(1, height - 2))
    fill:SetWidth(math.max(1, width - 2))
    fill:SetCenterColor(unpack(color))
    fill:SetEdgeColor(0, 0, 0, 0)

    local label = makeLabel(bar, name .. "_Label", height >= 18 and "ZoFontGameSmall" or "ZoFontGameSmall", C.white, TEXT_ALIGN_CENTER)
    label:SetAnchorFill(bar)
    label:SetText(labelText or "")

    bar.epcFill = fill
    bar.epcLabel = label
    bar.epcWidth = math.max(1, width - 2)
    bar.epcPrefix = labelText or ""
    bar.epcTextMode = textMode or "FULL"
    return bar
end

local function updateFillBar(bar, current, maximum, prefix)
    if not bar then return end
    current = tonumber(current) or 0
    maximum = tonumber(maximum) or 0
    local ratio = maximum > 0 and math.max(0, math.min(1, current / maximum)) or 0
    if ratio <= 0 then
        bar.epcFill:SetHidden(true)
    else
        bar.epcFill:SetHidden(false)
        bar.epcFill:SetWidth(math.max(1, bar.epcWidth * ratio))
    end

    prefix = prefix or bar.epcPrefix or ""
    local function withPrefix(body)
        if prefix == "" then return body end
        return prefix .. "  " .. body
    end
    if bar.epcTextMode == "PERCENT" then
        bar.epcLabel:SetText(withPrefix(percentText(current, maximum)))
    elseif bar.epcTextMode == "NONE" then
        bar.epcLabel:SetText("")
    elseif maximum > 0 then
        bar.epcLabel:SetText(withPrefix(string.format("%s / %s  (%s)", compactNumber(current), compactNumber(maximum), percentText(current, maximum))))
    else
        bar.epcLabel:SetText(withPrefix("--"))
    end
end

local DEFAULT_LAYOUT = {
    player = { point = BOTTOMRIGHT, relativePoint = CENTER, x = -34, y = 282 },
    target = { point = BOTTOMLEFT, relativePoint = CENTER, x = 34, y = 282 },
    group = { point = TOPLEFT, relativePoint = TOPLEFT, x = 38, y = 245 },
    raid = { point = TOPLEFT, relativePoint = TOPLEFT, x = 38, y = 205 },
    stats = { point = TOPRIGHT, relativePoint = TOPRIGHT, x = -42, y = 12 },
    effects = { point = BOTTOMRIGHT, relativePoint = CENTER, x = -34, y = 184 },
}

local POSITION_KEYS = {
    player = { "playerFrameLeft", "playerFrameTop" },
    target = { "targetFrameLeft", "targetFrameTop" },
    group = { "groupFrameLeft", "groupFrameTop" },
    raid = { "raidFrameLeft", "raidFrameTop" },
    stats = { "statsFrameLeft", "statsFrameTop" },
    effects = { "playerEffectsLeft", "playerEffectsTop" },
}

function F:AnchorWindow(frame, kind)
    if not frame or not EPC.saved then return end
    frame:ClearAnchors()
    local keys = POSITION_KEYS[kind]
    local left = keys and tonumber(EPC.saved[keys[1]]) or nil
    local top = keys and tonumber(EPC.saved[keys[2]]) or nil
    if left and left >= 0 and top and top >= 0 then
        frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
        return
    end
    local d = DEFAULT_LAYOUT[kind]
    frame:SetAnchor(d.point, GuiRoot, d.relativePoint, d.x, d.y)
end

function F:SaveWindowPosition(frame, kind)
    if not frame or not EPC.saved then return end
    local keys = POSITION_KEYS[kind]
    if not keys then return end
    EPC.saved[keys[1]] = frame:GetLeft()
    EPC.saved[keys[2]] = frame:GetTop()
end

function F:CreateShell(name, kind, width, height)
    local frame = wm:CreateTopLevelWindow(name)
    frame:SetDimensions(width, height)
    frame:SetClampedToScreen(true)
    frame:SetMouseEnabled(false)
    frame:SetMovable(false)
    self:AnchorWindow(frame, kind)
    frame:SetHandler("OnMoveStop", function(control) self:SaveWindowPosition(control, kind) end)

    local shadow = makeBackdrop(frame, name .. "_Shadow", {0, 0, 0, 0.35}, {0, 0, 0, 0})
    shadow:SetAnchor(TOPLEFT, frame, TOPLEFT, 4, 5)
    shadow:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, 4, 5)

    local bg = makeBackdrop(frame, name .. "_BG", C.bg, C.edge)
    bg:SetAnchorFill(frame)

    local accent = wm:CreateControl(name .. "_Accent", frame, CT_BACKDROP)
    accent:SetAnchor(TOPLEFT, frame, TOPLEFT, 1, 1)
    accent:SetAnchor(TOPRIGHT, frame, TOPRIGHT, -1, 1)
    accent:SetHeight(3)
    accent:SetCenterColor(unpack(C.gold))
    accent:SetEdgeColor(0, 0, 0, 0)

    local moveHint = makeLabel(frame, name .. "_MoveHint", "ZoFontGameSmall", C.gold, TEXT_ALIGN_RIGHT)
    moveHint:SetAnchor(TOPRIGHT, frame, TOPRIGHT, -8, 7)
    moveHint:SetDimensions(width - 16, 18)
    moveHint:SetText("DRAG TO MOVE")
    moveHint:SetHidden(true)

    frame.epcKind = kind
    frame.epcShadow = shadow
    frame.epcBackground = bg
    frame.epcAccent = accent
    frame.epcMoveHint = moveHint
    return frame
end

function F:CreateUnitFrame(name, kind, width, height, includeAuras)
    local frame = self:CreateShell(name, kind, width, height)

    local title = makeLabel(frame, name .. "_Name", "ZoFontGameBold", C.white)
    title:SetAnchor(TOPLEFT, frame, TOPLEFT, 12, 6)
    title:SetDimensions(width - 215, 22)

    local info = makeLabel(frame, name .. "_Info", "ZoFontGameSmall", C.muted, TEXT_ALIGN_RIGHT)
    info:SetAnchor(TOPRIGHT, frame, TOPRIGHT, -10, 6)
    info:SetDimensions(180, 22)

    local companionInfo = nil
    local barY = 34
    if kind == "player" then
        -- v0.8.5: the persistent Player frame is pure resources only.
        -- No name, level, companion, or resource-name text is rendered.
        title:SetHidden(true)
        info:SetHidden(true)
        barY = 8
    end

    local barWidth = kind == "player" and 264 or (width - 24)
    local healthPrefix = kind == "player" and "" or "HEALTH"
    local health = createFillBar(frame, name .. "_Health", 12, barY, barWidth, 24, C.health, healthPrefix, "FULL")
    local magicka = nil
    local stamina = nil

    -- The player frame keeps all three resources. Targets intentionally show
    -- Health only so the frame stays compact and focused on combat-relevant
    -- target information.
    if kind ~= "target" then
        local magickaPrefix = kind == "player" and "" or "MAGICKA"
        local staminaPrefix = kind == "player" and "" or "STAMINA"
        magicka = createFillBar(frame, name .. "_Magicka", 12, barY + 30, barWidth, 18, C.magicka, magickaPrefix, "FULL")
        stamina = createFillBar(frame, name .. "_Stamina", 12, barY + 54, barWidth, 18, C.stamina, staminaPrefix, "FULL")
    end

    frame.epcTitle = title
    frame.epcInfo = info
    frame.epcCompanionInfo = companionInfo or false
    frame.epcBars = { health = health, magicka = magicka, stamina = stamina }

    if includeAuras then
        frame.epcBuffSlots = {}
        frame.epcDebuffSlots = {}

        local function createAuraSlot(prefix, index, x, y, slotSize, slotStep, edgeColor)
            local slot = makeBackdrop(frame, name .. "_" .. prefix .. tostring(index), {0, 0, 0, 0}, edgeColor)
            slot:SetAnchor(TOPLEFT, frame, TOPLEFT, x + ((index - 1) * slotStep), y)
            slot:SetDimensions(slotSize, slotSize)

            local icon = wm:CreateControl(name .. "_" .. prefix .. tostring(index) .. "_Icon", slot, CT_TEXTURE)
            icon:SetAnchor(TOPLEFT, slot, TOPLEFT, 1, 1)
            icon:SetAnchor(BOTTOMRIGHT, slot, BOTTOMRIGHT, -1, -1)

            local timer = makeLabel(slot, name .. "_" .. prefix .. tostring(index) .. "_Timer", "ZoFontGameSmall", C.white, TEXT_ALIGN_CENTER)
            timer:SetAnchor(BOTTOMLEFT, slot, BOTTOMLEFT, 0, 0)
            timer:SetAnchor(BOTTOMRIGHT, slot, BOTTOMRIGHT, 0, 0)
            timer:SetHeight(11)

            local stack = makeLabel(slot, name .. "_" .. prefix .. tostring(index) .. "_Stack", "ZoFontGameSmall", C.gold, TEXT_ALIGN_RIGHT)
            stack:SetAnchor(TOPRIGHT, slot, TOPRIGHT, -1, -1)
            stack:SetDimensions(13, 11)

            slot.epcIcon = icon
            slot.epcTimer = timer
            slot.epcStack = stack
            slot.epcName = ""
            slot:SetHidden(true)
            return slot
        end

        if kind == "player" then
            -- Player effects use a wrapping icon grid. The grid grows as needed so
            -- every current buff and debuff can be shown instead of collapsing the
            -- remainder into a +N counter.
            local auraX = 292
            local columnWidth = width - auraX - 8
            local slotSize = 22
            local slotStep = 25
            local buffHeader = makeLabel(frame, name .. "_BuffHeader", "ZoFontGameSmall", C.green)
            buffHeader:SetAnchor(TOPLEFT, frame, TOPLEFT, auraX, 1)
            buffHeader:SetDimensions(columnWidth, 14)
            buffHeader:SetText("BUFFS")

            local debuffHeader = makeLabel(frame, name .. "_DebuffHeader", "ZoFontGameSmall", C.red)
            debuffHeader:SetAnchor(TOPLEFT, frame, TOPLEFT, auraX, 43)
            debuffHeader:SetDimensions(columnWidth, 14)
            debuffHeader:SetText("DEBUFFS")

            frame.epcBuffHeader = buffHeader
            frame.epcDebuffHeader = debuffHeader
            frame.epcAuraX = auraX
            frame.epcAuraColumnWidth = columnWidth
            frame.epcAuraSlotSize = slotSize
            frame.epcAuraSlotStep = slotStep
            frame.epcAuraFactory = function(prefix, index, edgeColor)
                return createAuraSlot(prefix, index, auraX, 16, slotSize, slotStep, edgeColor)
            end
            for i = 1, 5 do
                frame.epcBuffSlots[i] = frame.epcAuraFactory("Buff", i, C.green)
                frame.epcDebuffSlots[i] = frame.epcAuraFactory("Debuff", i, C.red)
            end
        else
            -- Target buffs/debuffs stay in one compact horizontal band.
            local columnWidth = math.floor((width - 36) / 2)
            local buffX = 12
            local debuffX = width - 12 - columnWidth
            local headerY = 66
            local slotY = 84
            local slotSize = 28
            local slotStep = 31

            local buffHeader = makeLabel(frame, name .. "_BuffHeader", "ZoFontGameSmall", C.green)
            buffHeader:SetAnchor(TOPLEFT, frame, TOPLEFT, buffX, headerY)
            buffHeader:SetDimensions(columnWidth, 16)
            buffHeader:SetText("BUFFS")

            local debuffHeader = makeLabel(frame, name .. "_DebuffHeader", "ZoFontGameSmall", C.red)
            debuffHeader:SetAnchor(TOPLEFT, frame, TOPLEFT, debuffX, headerY)
            debuffHeader:SetDimensions(columnWidth, 16)
            debuffHeader:SetText("DEBUFFS")

            frame.epcBuffHeader = buffHeader
            frame.epcDebuffHeader = debuffHeader
            for i = 1, 6 do
                frame.epcBuffSlots[i] = createAuraSlot("Buff", i, buffX, slotY, slotSize, slotStep, C.green)
                frame.epcDebuffSlots[i] = createAuraSlot("Debuff", i, debuffX, slotY, slotSize, slotStep, C.red)
            end
        end
    end

    return frame
end

function F:CreatePlayerEffectsFrame()
    local frame = self:CreateShell("EPC_PlayerEffectsFrame", "effects", 360, 92)
    -- Player effects are intentionally panel-free. The top-level control remains
    -- draggable in HUD layout mode, but normal gameplay renders only effect
    -- labels/icons/timers with no surrounding backdrop, shadow, or accent bar.
    frame.epcNoPanel = true
    if frame.epcShadow then frame.epcShadow:SetHidden(true) end
    if frame.epcBackground then frame.epcBackground:SetHidden(true) end
    if frame.epcAccent then frame.epcAccent:SetHidden(true) end
    frame.epcBuffSlots, frame.epcDebuffSlots = {}, {}

    local function createAuraSlot(prefix, index, edgeColor)
        local slot = makeBackdrop(frame, "EPC_PlayerEffects_" .. prefix .. tostring(index), {0,0,0,0}, edgeColor)
        slot:SetDimensions(28, 28)
        local icon = wm:CreateControl("EPC_PlayerEffects_" .. prefix .. tostring(index) .. "_Icon", slot, CT_TEXTURE)
        icon:SetAnchor(TOPLEFT, slot, TOPLEFT, 1, 1)
        icon:SetAnchor(BOTTOMRIGHT, slot, BOTTOMRIGHT, -1, -1)
        local timerBack = wm:CreateControl("EPC_PlayerEffects_" .. prefix .. tostring(index) .. "_TimerBack", slot, CT_BACKDROP)
        timerBack:SetAnchor(CENTER, slot, CENTER, 0, 0)
        timerBack:SetDimensions(22, 16)
        timerBack:SetCenterColor(0, 0, 0, 0.94)
        timerBack:SetEdgeColor(0, 0, 0, 1)
        timerBack:SetEdgeTexture(nil, 1, 1, 1)
        timerBack:SetHidden(true)
        local timer = makeLabel(slot, "EPC_PlayerEffects_" .. prefix .. tostring(index) .. "_Timer", "$(BOLD_FONT)|16|soft-shadow-thick", C.white, TEXT_ALIGN_CENTER)
        timer:SetAnchorFill(slot)
        timer:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        timer:SetColor(1.00, 0.64, 0.16, 1)
        local stack = makeLabel(slot, "EPC_PlayerEffects_" .. prefix .. tostring(index) .. "_Stack", "ZoFontGameSmall", C.gold, TEXT_ALIGN_RIGHT)
        stack:SetAnchor(TOPRIGHT, slot, TOPRIGHT, -1, -1)
        stack:SetDimensions(13, 11)
        slot.epcIcon, slot.epcTimerBack, slot.epcTimer, slot.epcStack, slot.epcName = icon, timerBack, timer, stack, ""
        slot:SetHidden(true)
        return slot
    end

    -- No BUFFS/DEBUFFS captions on the player effects overlay. Only effect icons
    -- and their timers/stacks are rendered; the container remains movable.
    frame.epcBuffHeader, frame.epcDebuffHeader = nil, nil
    frame.epcAuraFactory = createAuraSlot
    frame.epcAuraSlotSize, frame.epcAuraSlotStep = 30, 33

    for i=1,6 do
        frame.epcBuffSlots[i] = createAuraSlot("Buff", i, C.green)
        frame.epcDebuffSlots[i] = createAuraSlot("Debuff", i, C.red)
    end
    return frame
end

function F:CreateMemberRow(parent, name, width, height, x, y, showCompanion)
    local row = makeBackdrop(parent, name, C.panel, C.edgeSoft)
    row:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    row:SetDimensions(width, height)

    local accent = wm:CreateControl(name .. "_Accent", row, CT_BACKDROP)
    accent:SetAnchor(TOPLEFT, row, TOPLEFT, 0, 0)
    accent:SetAnchor(BOTTOMLEFT, row, BOTTOMLEFT, 0, 0)
    accent:SetWidth(3)
    accent:SetCenterColor(unpack(C.muted))
    accent:SetEdgeColor(0, 0, 0, 0)

    local label = makeLabel(row, name .. "_Name", "ZoFontGameSmall", C.white)
    label:SetAnchor(TOPLEFT, row, TOPLEFT, 8, 2)
    label:SetDimensions(width - 156, 18)

    local meta = makeLabel(row, name .. "_Meta", "ZoFontGameSmall", C.gold, TEXT_ALIGN_RIGHT)
    meta:SetAnchor(TOPRIGHT, row, TOPRIGHT, -7, 2)
    meta:SetDimensions(142, 18)

    local companion = nil
    local companionMeta = nil
    local healthY = 24
    if showCompanion then
        companion = makeLabel(row, name .. "_Companion", "ZoFontGameSmall", C.muted)
        companion:SetAnchor(TOPLEFT, row, TOPLEFT, 8, 20)
        companion:SetDimensions(width - 106, 16)
        companion:SetHidden(true)

        companionMeta = makeLabel(row, name .. "_CompanionMeta", "ZoFontGameSmall", C.muted, TEXT_ALIGN_RIGHT)
        companionMeta:SetAnchor(TOPRIGHT, row, TOPRIGHT, -7, 20)
        companionMeta:SetDimensions(92, 16)
        companionMeta:SetHidden(true)
        healthY = 39
    end

    local health = createFillBar(row, name .. "_Health", 8, healthY, width - 16, 17, C.health, "", "PERCENT")

    row.epcIsMemberRow = true
    row.epcName = label
    row.epcMeta = meta
    row.epcRole = meta -- compatibility with older style code
    row.epcCompanion = companion or false
    row.epcCompanionMeta = companionMeta or false
    row.epcShowCompanion = showCompanion == true
    row.epcAccent = accent
    row.epcBars = { health = health }
    row.epcUnitTag = nil
    return row
end

function F:CreateGroupFrame()
    local frame = self:CreateShell("EPC_GroupFrame", "group", 334, 308)
    local title = makeLabel(frame, "EPC_GroupFrame_Title", "ZoFontGameBold", C.gold)
    title:SetAnchor(TOPLEFT, frame, TOPLEFT, 12, 6)
    title:SetDimensions(120, 22)
    title:SetText("")

    local status = makeLabel(frame, "EPC_GroupFrame_Status", "ZoFontGameSmall", C.muted, TEXT_ALIGN_RIGHT)
    status:SetAnchor(TOPRIGHT, frame, TOPRIGHT, -10, 6)
    status:SetDimensions(170, 22)

    frame.epcTitle = title
    frame.epcStatus = status
    frame.epcRows = {}
    for i = 1, 4 do
        frame.epcRows[i] = self:CreateMemberRow(frame, "EPC_GroupMember" .. tostring(i), 310, 62, 12, 32 + ((i - 1) * 66), true)
    end
    return frame
end

function F:CreateRaidFrame()
    local maxSize = 12
    if type(GetGroupMaxSize) == "function" then
        local ok, value = pcall(GetGroupMaxSize)
        if ok and tonumber(value) then maxSize = math.max(12, math.min(24, tonumber(value))) end
    end
    self.maxGroupSize = maxSize
    local columns = maxSize > 12 and 3 or 2
    local rowsPerColumn = math.ceil(maxSize / columns)
    local width = 20 + (columns * 250) + ((columns - 1) * 8)
    local height = 38 + (rowsPerColumn * 54)

    local frame = self:CreateShell("EPC_RaidFrame", "raid", width, height)
    local title = makeLabel(frame, "EPC_RaidFrame_Title", "ZoFontGameBold", C.gold)
    title:SetAnchor(TOPLEFT, frame, TOPLEFT, 12, 6)
    title:SetDimensions(120, 22)
    title:SetText("RAID")

    local status = makeLabel(frame, "EPC_RaidFrame_Status", "ZoFontGameSmall", C.muted, TEXT_ALIGN_RIGHT)
    status:SetAnchor(TOPRIGHT, frame, TOPRIGHT, -10, 6)
    status:SetDimensions(190, 22)

    frame.epcTitle = title
    frame.epcStatus = status
    frame.epcRows = {}
    for i = 1, maxSize do
        local column = math.floor((i - 1) / rowsPerColumn)
        local rowIndex = (i - 1) % rowsPerColumn
        frame.epcRows[i] = self:CreateMemberRow(frame, "EPC_RaidMember" .. tostring(i), 250, 50, 12 + (column * 258), 32 + (rowIndex * 54), false)
    end
    return frame
end

function F:CreateStatsFrame()
    local frame = self:CreateShell("EPC_CombatStatsFrame", "stats", 400, 146)
    local title = makeLabel(frame, "EPC_CombatStatsFrame_Title", "ZoFontGameBold", C.gold)
    title:SetAnchor(TOPLEFT, frame, TOPLEFT, 12, 6)
    title:SetDimensions(238, 24)
    title:SetText("LIVE COMBAT STATS")

    local live = makeLabel(frame, "EPC_CombatStatsFrame_Live", "ZoFontGameSmall", C.muted, TEXT_ALIGN_RIGHT)
    live:SetAnchor(TOPRIGHT, frame, TOPRIGHT, -10, 6)
    live:SetDimensions(125, 24)
    live:SetText("PLAYER")

    local defs = {
        { key = "PEN", name = "PEN", x = 12, y = 36 },
        { key = "PWR", name = "PWR", x = 207, y = 36 },
        { key = "SR", name = "SR", x = 12, y = 70 },
        { key = "PR", name = "PR", x = 207, y = 70 },
        { key = "CC", name = "CC", x = 12, y = 104 },
        { key = "CD", name = "CD", x = 207, y = 104 },
    }
    frame.epcLive = live
    frame.epcStats = {}
    frame.epcCells = {}
    for i = 1, #defs do
        local d = defs[i]
        local cell = makeBackdrop(frame, "EPC_CombatStats_" .. d.key, {0.025, 0.030, 0.040, 0.96}, C.edgeSoft)
        cell:SetAnchor(TOPLEFT, frame, TOPLEFT, d.x, d.y)
        cell:SetDimensions(181, 28)
        local value = makeLabel(cell, "EPC_CombatStats_" .. d.key .. "_Value", "ZoFontGameBold", C.white)
        value:SetAnchor(TOPLEFT, cell, TOPLEFT, 8, 0)
        value:SetDimensions(124, 28)
        local abbrev = makeLabel(cell, "EPC_CombatStats_" .. d.key .. "_Label", "ZoFontGameSmall", C.muted, TEXT_ALIGN_RIGHT)
        abbrev:SetAnchor(TOPRIGHT, cell, TOPRIGHT, -7, 0)
        abbrev:SetDimensions(44, 28)
        abbrev:SetText(d.name)
        frame.epcStats[d.key] = value
        frame.epcCells[#frame.epcCells + 1] = cell
    end
    return frame
end

function F:GetUnitMeta(unitTag)
    local name = cleanName(safe(GetUnitName, "", unitTag))
    if name == "" then name = string.upper(unitTag or "UNIT") end
    local level = safeNumber(GetUnitLevel, 0, unitTag)
    local cp = safeNumber(GetUnitChampionPoints, 0, unitTag)
    local dead = safe(IsUnitDead, false, unitTag) == true
    local online = true
    local isPlayerLike = unitTag == "player" or string.sub(tostring(unitTag or ""), 1, 5) == "group" or safe(IsUnitPlayer, false, unitTag) == true
    if isPlayerLike then online = safe(IsUnitOnline, true, unitTag) ~= false end
    local info = ""
    if level > 0 and cp > 0 then
        info = "LV " .. tostring(level) .. "  |  CP " .. tostring(cp)
    elseif level > 0 then
        info = "LV " .. tostring(level)
    elseif cp > 0 then
        info = "CP " .. tostring(cp)
    end
    if dead then info = info ~= "" and (info .. "  DEAD") or "DEAD" end
    if not online then info = info ~= "" and (info .. "  OFFLINE") or "OFFLINE" end
    return name, info, dead, online
end


function F:GetActiveCompanionSummary()
    if type(HasActiveCompanion) == "function" and safe(HasActiveCompanion, false) ~= true then return nil end
    if type(GetActiveCompanionDefId) ~= "function" or type(GetActiveCompanionLevelInfo) ~= "function" then return nil end

    local companionId = safeNumber(GetActiveCompanionDefId, 0)
    if companionId <= 0 then return nil end
    local name = type(GetCompanionName) == "function" and cleanName(safe(GetCompanionName, "", companionId)) or ""
    local levelValue = safe(GetActiveCompanionLevelInfo, 0)
    local level = tonumber(levelValue) or 0
    if name == "" then name = "Companion" end
    if level > 0 then return string.format("COMPANION  %s  |  LV %d", name, level) end
    return "COMPANION  " .. name
end

function F:UpdateUnitFrame(frame, unitTag, preview)
    if not frame then return end
    local exists = preview == true or safe(DoesUnitExist, false, unitTag) == true
    if not exists then return false end

    local name, info, dead = self:GetUnitMeta(unitTag)
    if preview and not safe(DoesUnitExist, false, unitTag) then
        name = frame.epcKind == "target" and "TARGET PREVIEW" or "PLAYER PREVIEW"
        info = "LAYOUT MODE"
    end

    if frame.epcKind ~= "player" then
        frame.epcTitle:SetText(name)
        frame.epcInfo:SetText(info)
    end

    local hp, hpMax = readPower(unitTag, POWER_HEALTH)
    if preview and hpMax <= 0 then hp, hpMax = 76000, 100000 end
    updateFillBar(frame.epcBars.health, hp, hpMax, frame.epcKind == "player" and "" or (dead and "DEAD" or "HEALTH"))

    if frame.epcBars.magicka then
        local mag, magMax = readPower(unitTag, POWER_MAGICKA)
        if preview and magMax <= 0 then mag, magMax = 28000, 40000 end
        updateFillBar(frame.epcBars.magicka, mag, magMax, frame.epcKind == "player" and "" or "MAGICKA")
    end
    if frame.epcBars.stamina then
        local stam, stamMax = readPower(unitTag, POWER_STAMINA)
        if preview and stamMax <= 0 then stam, stamMax = 21000, 30000 end
        updateFillBar(frame.epcBars.stamina, stam, stamMax, frame.epcKind == "player" and "" or "STAMINA")
    end

    if frame.epcKind == "target" and frame.epcAccent then
        local attackable = safe(IsUnitAttackable, false, unitTag) == true
        local friend = safe(IsUnitFriend, false, unitTag) == true
        if attackable then frame.epcAccent:SetCenterColor(unpack(C.red))
        elseif friend then frame.epcAccent:SetCenterColor(unpack(C.green))
        else frame.epcAccent:SetCenterColor(unpack(C.gold)) end
    end
    return true
end

function F:GetAuraData(unitTag)
    local buffs, debuffs = {}, {}

    -- ESO's own buff/debuff UI includes artificial effects for the player in
    -- addition to GetUnitBuffInfo(). Include them here too so negative player
    -- states are not silently absent from the custom Player frame.
    if unitTag == "player" and type(ZO_GetNextActiveArtificialEffectIdIter) == "function" and type(GetArtificialEffectInfo) == "function" then
        for effectId in ZO_GetNextActiveArtificialEffectIdIter do
            local ok, displayName, iconFile, effectType, sortOrder, timeStarted, timeEnding = pcall(GetArtificialEffectInfo, effectId)
            if ok and displayName and displayName ~= "" then
                local data = {
                    name = displayName,
                    startTime = tonumber(timeStarted) or 0,
                    endTime = tonumber(timeEnding) or 0,
                    stackCount = 0,
                    icon = iconFile or "",
                    effectType = effectType,
                    abilityId = effectId,
                    castByPlayer = false,
                    artificial = true,
                }
                if BUFF_EFFECT_TYPE_DEBUFF ~= nil and effectType == BUFF_EFFECT_TYPE_DEBUFF then
                    debuffs[#debuffs + 1] = data
                elseif BUFF_EFFECT_TYPE_BUFF == nil or effectType == BUFF_EFFECT_TYPE_BUFF then
                    buffs[#buffs + 1] = data
                end
            end
        end
    end

    if type(GetNumBuffs) ~= "function" or type(GetUnitBuffInfo) ~= "function" then return buffs, debuffs end
    local count = safeNumber(GetNumBuffs, 0, unitTag)
    for i = 1, count do
        local ok, buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, deprecatedBuffType,
            effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = pcall(GetUnitBuffInfo, unitTag, i)
        if ok and buffName and buffName ~= "" then
            local data = {
                name = buffName,
                startTime = tonumber(timeStarted) or 0,
                endTime = tonumber(timeEnding) or 0,
                stackCount = tonumber(stackCount) or 0,
                icon = iconFilename or "",
                effectType = effectType,
                abilityId = abilityId,
                castByPlayer = castByPlayer == true,
            }
            if BUFF_EFFECT_TYPE_DEBUFF ~= nil and effectType == BUFF_EFFECT_TYPE_DEBUFF then
                debuffs[#debuffs + 1] = data
            elseif BUFF_EFFECT_TYPE_NOT_AN_EFFECT == nil or effectType ~= BUFF_EFFECT_TYPE_NOT_AN_EFFECT then
                buffs[#buffs + 1] = data
            end
        end
    end

    -- ESO can expose the same player effect through both the artificial-effect
    -- iterator and GetUnitBuffInfo(). Collapse those representations before
    -- rendering so one logical aura can never consume two UI slots. Prefer
    -- the normal GetUnitBuffInfo() record because it carries the live ability
    -- id, stack count, caster flag and timing ESO uses for the unit buff list.
    local function normalizeAuraName(value)
        value = tostring(value or "")
        value = value:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
        value = value:gsub("^%s+", ""):gsub("%s+$", "")
        value = value:gsub("%s+", " ")
        return string.lower(value)
    end

    local function dedupeAuras(list)
        local out, seenId, seenVisual = {}, {}, {}
        for _, aura in ipairs(list) do
            local abilityId = tonumber(aura.abilityId) or 0
            local nameKey = normalizeAuraName(aura.name)
            local iconKey = string.lower(tostring(aura.icon or ""))
            local visualKey = nameKey .. "|" .. iconKey
            local existingIndex = abilityId > 0 and seenId[abilityId] or nil
            if not existingIndex and nameKey ~= "" then existingIndex = seenVisual[visualKey] end
            if not existingIndex and nameKey ~= "" then
                -- Artificial effects frequently use a synthetic id and the same
                -- display name while omitting/changing the icon. Name-only is a
                -- final fallback specifically for overlapping artificial entries.
                for i, existing in ipairs(out) do
                    if normalizeAuraName(existing.name) == nameKey and (existing.artificial or aura.artificial) then
                        existingIndex = i
                        break
                    end
                end
            end

            if existingIndex then
                local old = out[existingIndex]
                if old.artificial and not aura.artificial then
                    out[existingIndex] = aura
                else
                    old.stackCount = math.max(tonumber(old.stackCount) or 0, tonumber(aura.stackCount) or 0)
                    old.endTime = math.max(tonumber(old.endTime) or 0, tonumber(aura.endTime) or 0)
                    if (not old.icon or old.icon == "") and aura.icon and aura.icon ~= "" then old.icon = aura.icon end
                    if aura.castByPlayer then old.castByPlayer = true end
                end
            else
                out[#out + 1] = aura
                local idx = #out
                if abilityId > 0 then seenId[abilityId] = idx end
                if nameKey ~= "" then seenVisual[visualKey] = idx end
            end
        end
        return out
    end

    buffs = dedupeAuras(buffs)
    debuffs = dedupeAuras(debuffs)

    local function sortAura(a, b)
        -- Timed effects are generally the ones the player needs to react to.
        -- Put them ahead of permanent/passive effects, then prefer locally cast
        -- effects and the soonest expiry. This also keeps target debuffs applied
        -- by the local player prominent without letting long food/passive buffs
        -- crowd out short combat effects on the Player frame.
        local aTimed = (tonumber(a.endTime) or 0) > 0
        local bTimed = (tonumber(b.endTime) or 0) > 0
        if aTimed ~= bTimed then return aTimed end
        if a.castByPlayer ~= b.castByPlayer then return a.castByPlayer end
        local ae = aTimed and a.endTime or 999999999
        local be = bTimed and b.endTime or 999999999
        if ae == be then return tostring(a.name) < tostring(b.name) end
        return ae < be
    end
    table.sort(buffs, sortAura)
    table.sort(debuffs, sortAura)
    return buffs, debuffs
end

function F:RenderAuraSlots(slots, data, maxVisible, edgeColor)
    for i = 1, #slots do
        local slot = slots[i]
        local aura = i <= maxVisible and data[i] or nil
        if aura then
            slot:SetHidden(false)
            slot.epcName = aura.name
            if aura.icon and aura.icon ~= "" then slot.epcIcon:SetTexture(aura.icon) end
            local timerText = formatAuraTime(aura.endTime)
            slot.epcTimer:SetText(timerText)
            slot.epcStack:SetText((aura.stackCount or 0) > 1 and tostring(aura.stackCount) or "")
            if slot.epcTimerBack then
                local showTimerBack = timerText ~= ""
                slot.epcTimerBack:SetHidden(not showTimerBack)
                if showTimerBack then
                    local textWidth, textHeight = 0, 0
                    if slot.epcTimer and type(slot.epcTimer.GetTextDimensions) == "function" then
                        textWidth, textHeight = slot.epcTimer:GetTextDimensions()
                    end
                    textWidth = tonumber(textWidth) or 0
                    textHeight = tonumber(textHeight) or 0
                    slot.epcTimerBack:SetDimensions(math.max(18, textWidth + 10), math.max(14, textHeight + 6))
                end
            end
            if aura.castByPlayer then slot:SetEdgeColor(unpack(C.gold))
            else slot:SetEdgeColor(unpack(edgeColor)) end
        else
            slot:SetHidden(true)
            slot.epcName = ""
            slot.epcTimer:SetText("")
            slot.epcStack:SetText("")
            if slot.epcTimerBack then slot.epcTimerBack:SetHidden(true) end
        end
    end
end

function F:RefreshTargetAuras(preview)
    local frame = self.targetFrame
    if not frame or not frame.epcBuffSlots then return end
    local maxVisible = math.max(3, math.min(6, tonumber(EPC.saved.targetAuraCount) or 5))

    local function setHeaders(buffCount, debuffCount)
        buffCount = tonumber(buffCount) or 0
        debuffCount = tonumber(debuffCount) or 0
        if frame.epcBuffHeader then
            local extra = math.max(0, buffCount - maxVisible)
            frame.epcBuffHeader:SetText(extra > 0 and ("BUFFS  +" .. tostring(extra)) or "BUFFS")
        end
        if frame.epcDebuffHeader then
            local extra = math.max(0, debuffCount - maxVisible)
            frame.epcDebuffHeader:SetText(extra > 0 and ("DEBUFFS  +" .. tostring(extra)) or "DEBUFFS")
        end
    end

    if preview and not safe(DoesUnitExist, false, "reticleover") then
        self:RenderAuraSlots(frame.epcBuffSlots, {}, maxVisible, C.green)
        self:RenderAuraSlots(frame.epcDebuffSlots, {}, maxVisible, C.red)
        setHeaders(0, 0)
        return
    end
    if safe(DoesUnitExist, false, "reticleover") ~= true then
        self:RenderAuraSlots(frame.epcBuffSlots, {}, maxVisible, C.green)
        self:RenderAuraSlots(frame.epcDebuffSlots, {}, maxVisible, C.red)
        setHeaders(0, 0)
        return
    end
    local buffs, debuffs = self:GetAuraData("reticleover")
    self:RenderAuraSlots(frame.epcBuffSlots, buffs, maxVisible, C.green)
    self:RenderAuraSlots(frame.epcDebuffSlots, debuffs, maxVisible, C.red)
    setHeaders(#buffs, #debuffs)
end

function F:RefreshPlayerAuras(preview)
    local frame = self.playerEffectsFrame
    if not frame or not frame.epcBuffSlots then return end

    local buffs, debuffs = {}, {}
    if not (preview and safe(DoesUnitExist, false, "player") ~= true) then
        buffs, debuffs = self:GetAuraData("player")
    end

    local factory = frame.epcAuraFactory
    local created = false
    if factory then
        while #frame.epcBuffSlots < #buffs do
            local index = #frame.epcBuffSlots + 1
            frame.epcBuffSlots[index] = factory("Buff", index, C.green)
            created = true
        end
        while #frame.epcDebuffSlots < #debuffs do
            local index = #frame.epcDebuffSlots + 1
            frame.epcDebuffSlots[index] = factory("Debuff", index, C.red)
            created = true
        end
    end

    local width = 360
    local slotStep = tonumber(frame.epcAuraSlotStep) or 31
    local leftPad = 10
    local perRow = math.max(1, math.floor((width - 20) / slotStep))

    local function layoutSlots(slots, count, startY)
        for i=1,#slots do
            local slot = slots[i]
            slot:ClearAnchors()
            local row = math.floor((i - 1) / perRow)
            local col = (i - 1) % perRow
            slot:SetAnchor(TOPLEFT, frame, TOPLEFT, leftPad + (col * slotStep), startY + (row * slotStep))
        end
        if count <= 0 then return 0 end
        return math.ceil(count / perRow)
    end

    -- Keep the player effects overlay label-free and compact. Buff icons begin
    -- at the top; debuffs follow beneath them with a small visual gap.
    local topPad = 4
    local buffRows = layoutSlots(frame.epcBuffSlots, #buffs, topPad)
    local debuffStartY = topPad
    if buffRows > 0 then
        debuffStartY = topPad + (buffRows * slotStep) + 5
    end
    local debuffRows = layoutSlots(frame.epcDebuffSlots, #debuffs, debuffStartY)

    local usedRowsHeight = 0
    if buffRows > 0 then usedRowsHeight = buffRows * slotStep end
    if debuffRows > 0 then
        if buffRows > 0 then usedRowsHeight = usedRowsHeight + 5 end
        usedRowsHeight = usedRowsHeight + (debuffRows * slotStep)
    end
    frame:SetHeight(math.max(34, topPad + usedRowsHeight + 4))

    self:RenderAuraSlots(frame.epcBuffSlots, buffs, #buffs, C.green)
    self:RenderAuraSlots(frame.epcDebuffSlots, debuffs, #debuffs, C.red)
    if created then self:ApplyVisualStyle() end
end

function F:RoleText(unitTag)
    if type(GetGroupMemberSelectedRole) ~= "function" or unitTag == "player" then return "" end
    local role = safe(GetGroupMemberSelectedRole, LFG_ROLE_INVALID, unitTag)
    if LFG_ROLE_TANK ~= nil and role == LFG_ROLE_TANK then return "TANK", C.orange end
    if LFG_ROLE_HEAL ~= nil and role == LFG_ROLE_HEAL then return "HEAL", C.green end
    if LFG_ROLE_DPS ~= nil and role == LFG_ROLE_DPS then return "DPS", C.white end
    return "", C.muted
end

function F:GetLevelText(unitTag)
    local level = safeNumber(GetUnitLevel, 0, unitTag)
    local cp = safeNumber(GetUnitChampionPoints, 0, unitTag)
    if level > 0 and cp > 0 then return string.format("LV %d | CP %d", level, cp) end
    if level > 0 then return "LV " .. tostring(level) end
    if cp > 0 then return "CP " .. tostring(cp) end
    return ""
end

function F:GetCompanionForMember(unitTag)
    local companionTag = nil
    if unitTag == "player" then
        if safe(DoesUnitExist, false, "companion") == true then companionTag = "companion" end
    elseif unitTag and type(GetCompanionUnitTagByGroupUnitTag) == "function" then
        companionTag = safe(GetCompanionUnitTagByGroupUnitTag, nil, unitTag)
        if companionTag == "" then companionTag = nil end
        if companionTag and safe(DoesUnitExist, false, companionTag) ~= true then companionTag = nil end
    end
    if not companionTag then return nil, nil, nil end

    -- Defensive guard: a bad/ambiguous companion unit tag must never cause the
    -- member's own name to be rendered a second time as a "companion" line.
    if type(AreUnitsEqual) == "function" and safe(AreUnitsEqual, false, companionTag, unitTag) == true then
        return nil, nil, nil
    end

    local companionName = cleanName(safe(GetUnitName, "", companionTag))
    local memberName = cleanName(safe(GetUnitName, "", unitTag))
    if companionName ~= "" and memberName ~= "" and string.lower(companionName) == string.lower(memberName) then
        return nil, nil, nil
    end
    local companionLevel = safeNumber(GetUnitLevel, 0, companionTag)
    if unitTag == "player" then
        local activeId = safeNumber(GetActiveCompanionDefId, 0)
        if companionName == "" and activeId > 0 and type(GetCompanionName) == "function" then
            companionName = cleanName(safe(GetCompanionName, "", activeId))
        end
        if type(GetActiveCompanionLevelInfo) == "function" then
            local activeLevel = safeNumber(GetActiveCompanionLevelInfo, 0)
            if activeLevel > 0 then companionLevel = activeLevel end
        end
    end
    if companionName == "" then companionName = "Companion" end
    local levelText = companionLevel > 0 and ("LV " .. tostring(companionLevel)) or ""
    return companionTag, companionName, levelText
end

function F:UpdateMemberRow(row, unitTag, previewIndex)
    if not row then return end
    local preview = previewIndex ~= nil
    local exists = preview or (unitTag and safe(DoesUnitExist, false, unitTag) == true)
    row:SetHidden(not exists)
    if not exists then row.epcUnitTag = nil return end

    row.epcUnitTag = unitTag
    local name = preview and ("Member " .. tostring(previewIndex)) or cleanName(safe(GetUnitName, "", unitTag))
    if name == "" then name = unitTag or "Member" end

    local isLeader = not preview and unitTag ~= "player" and safe(IsUnitGroupLeader, false, unitTag) == true
    local isDead = not preview and safe(IsUnitDead, false, unitTag) == true
    local isOnline = preview or unitTag == "player" or safe(IsUnitOnline, true, unitTag) ~= false
    local inRange = preview or unitTag == "player" or safe(IsUnitInGroupSupportRange, true, unitTag) ~= false
    local localPlayer = unitTag == "player"
    if not preview and not localPlayer and type(AreUnitsEqual) == "function" then localPlayer = safe(AreUnitsEqual, false, unitTag, "player") == true end
    if not preview and not localPlayer and type(GetLocalPlayerGroupUnitTag) == "function" then
        localPlayer = safe(GetLocalPlayerGroupUnitTag, "") == unitTag
    end

    local prefix = isLeader and "[L] " or ""
    row.epcName:SetText(prefix .. name)

    local roleText, roleColor = preview and "DPS" or self:RoleText(unitTag)
    local levelText = preview and ("LV " .. tostring(40 + previewIndex)) or self:GetLevelText(unitTag)
    local statusText = ""
    if isDead then statusText, roleColor = "DEAD", C.red
    elseif not isOnline then statusText, roleColor = "OFF", C.muted
    elseif not inRange then statusText, roleColor = "RANGE", C.muted
    elseif not row.epcShowCompanion then statusText = roleText or "" end
    if levelText ~= "" and statusText ~= "" then levelText = levelText .. " | " .. statusText
    elseif statusText ~= "" then levelText = statusText end
    row.epcMeta:SetText(levelText)
    row.epcMeta:SetColor(unpack(roleColor or C.gold))

    if localPlayer then row.epcAccent:SetCenterColor(unpack(C.gold))
    elseif isLeader then row.epcAccent:SetCenterColor(unpack(C.blue))
    elseif roleText == "HEAL" then row.epcAccent:SetCenterColor(unpack(C.green))
    elseif roleText == "TANK" then row.epcAccent:SetCenterColor(unpack(C.orange))
    else row.epcAccent:SetCenterColor(unpack(C.muted)) end

    if row.epcShowCompanion and row.epcCompanion and row.epcCompanionMeta then
        local companionTag, companionName, companionLevel = nil, nil, nil
        if preview then
            companionTag, companionName, companionLevel = "previewcompanion", "Companion", "LV 20"
        else
            companionTag, companionName, companionLevel = self:GetCompanionForMember(unitTag)
        end
        local hasCompanion = companionName ~= nil
        row.epcCompanion:SetHidden(not hasCompanion)
        row.epcCompanionMeta:SetHidden(not hasCompanion)
        if hasCompanion then
            row.epcCompanion:SetText(companionName)
            local chp, chpMax = readPower(companionTag, POWER_HEALTH)
            local healthText = chpMax > 0 and (compactNumber(chp) .. "/" .. compactNumber(chpMax)) or "HP --"
            local meta = companionLevel or ""
            if meta ~= "" then meta = meta .. "  •  " .. healthText else meta = healthText end
            row.epcCompanionMeta:SetText(meta)
        end
    end

    local hp, hpMax = readPower(unitTag, POWER_HEALTH)
    if preview then hp, hpMax = 78000 - (previewIndex * 2200), 100000 end
    updateFillBar(row.epcBars.health, hp, hpMax, "")
end

function F:GetGroupIdentityKey(unitTag)
    if not unitTag or unitTag == "" then return nil end
    local displayName = cleanName(safe(GetUnitDisplayName, "", unitTag))
    if displayName ~= "" then return "display:" .. string.lower(displayName) end
    local unitName = cleanName(safe(GetUnitName, "", unitTag))
    if unitName ~= "" then return "name:" .. string.lower(unitName) end
    return "tag:" .. string.lower(tostring(unitTag))
end

function F:GetGroupUnitTags()
    local tags = {}
    local seenKeys = {}
    local size = safeNumber(GetGroupSize, 0)

    local function isDuplicate(tag)
        if not tag or tag == "" then return true end
        for i = 1, #tags do
            local existing = tags[i]
            if existing == tag then return true end
            if type(AreUnitsEqual) == "function" and safe(AreUnitsEqual, false, existing, tag) == true then
                return true
            end
        end
        local key = self:GetGroupIdentityKey(tag)
        if key and seenKeys[key] then return true end
        if key then seenKeys[key] = true end
        return false
    end

    for i = 1, size do
        local tag = nil
        if type(GetGroupUnitTagByIndex) == "function" then tag = safe(GetGroupUnitTagByIndex, nil, i) end
        if not tag or tag == "" then tag = "group" .. tostring(i) end
        if not isDuplicate(tag) then tags[#tags + 1] = tag end
    end

    return tags, false
end

function F:ResizeGroupContainers(size, layout)
    if self.groupFrame then
        local visibleRows = layout and 4 or math.max(1, math.min(4, tonumber(size) or 0))
        local top = 32
        local rowHeight = 62
        local step = 66
        local bottomPad = 10
        local height = top + ((visibleRows - 1) * step) + rowHeight + bottomPad
        self.groupFrame:SetHeight(height)
    end

    if self.raidFrame then
        local visibleCount = layout and math.min(self.maxGroupSize or 12, 12) or math.max(1, tonumber(size) or 0)
        local columns = visibleCount > 12 and 3 or 2
        if visibleCount <= 4 then columns = 2 end
        local rowsPerColumn = math.max(1, math.ceil(visibleCount / columns))
        local width = 20 + (columns * 250) + ((columns - 1) * 8)
        local height = 38 + (rowsPerColumn * 54)
        self.raidFrame:SetDimensions(width, height)

        for i = 1, #self.raidFrame.epcRows do
            local row = self.raidFrame.epcRows[i]
            if row then
                row:ClearAnchors()
                local column = math.floor((i - 1) / rowsPerColumn)
                local rowIndex = (i - 1) % rowsPerColumn
                row:SetAnchor(TOPLEFT, self.raidFrame, TOPLEFT, 12 + (column * 258), 32 + (rowIndex * 54))
            end
        end
    end
end

function F:RefreshGroupFrames()
    if not self.groupFrame or not self.raidFrame then return end
    local tags, soloCompanion = self:GetGroupUnitTags()
    local size = #tags
    local layout = self.layoutMode == true
    local suppressed = self:IsHudSuppressed()

    self:ResizeGroupContainers(size, layout)

    local groupVisible = not suppressed and (layout or (EPC.saved.showGroupFrame ~= false and size > 1 and size <= 4))
    local raidVisible = not suppressed and (layout or (EPC.saved.showRaidFrame ~= false and size > 4))
    self.groupFrame:SetHidden(not groupVisible)
    self.raidFrame:SetHidden(not raidVisible)

    if groupVisible then
        self.groupFrame.epcStatus:SetText(layout and "LAYOUT PREVIEW" or "")
        for i = 1, #self.groupFrame.epcRows do
            if layout and size == 0 then self:UpdateMemberRow(self.groupFrame.epcRows[i], nil, i)
            else self:UpdateMemberRow(self.groupFrame.epcRows[i], tags[i], nil) end
        end
    end

    if raidVisible then
        self.raidFrame.epcStatus:SetText(layout and "LAYOUT PREVIEW" or (tostring(size) .. " MEMBERS"))
        for i = 1, #self.raidFrame.epcRows do
            if layout and size <= 4 then self:UpdateMemberRow(self.raidFrame.epcRows[i], nil, i)
            else self:UpdateMemberRow(self.raidFrame.epcRows[i], tags[i], nil) end
        end
    end
end

local function readPlayerStat(stat)
    if stat == nil or type(GetPlayerStat) ~= "function" then return 0 end
    local bonusOption = STAT_BONUS_OPTION_APPLY_BONUS or STAT_BONUS_OPTION_DONT_APPLY_BONUS or 0
    local ok, value = pcall(GetPlayerStat, stat, bonusOption)
    if not ok then return 0 end
    return tonumber(value) or 0
end

local function readAdvancedStat(statType)
    if statType == nil or type(GetAdvancedStatValue) ~= "function" then return nil, nil, nil end
    local ok, displayFormat, flatValue, percentValue = pcall(GetAdvancedStatValue, statType)
    if not ok then return nil, nil, nil end
    return displayFormat, tonumber(flatValue), tonumber(percentValue)
end

local function normalizeAdvancedPercent(value)
    value = tonumber(value)
    if not value or value ~= value then return nil end
    -- ESO has exposed advanced percentages as both ratios (0.50) and display
    -- percentages (50) across UI paths. Normalize either form for the HUD.
    if math.abs(value) <= 2 then value = value * 100 end
    if math.abs(value) < 0.0005 then value = 0 end
    if value < 0 then value = 0 end
    return value
end

local function readAdvancedPercent(statType, allowFlatFallback)
    local _, flatValue, percentValue = readAdvancedStat(statType)
    local value = normalizeAdvancedPercent(percentValue)

    -- Some live-client advanced stats (notably Critical Damage) can place the
    -- useful display value in flatValue while percentValue is nil/zero. Only
    -- opt into that fallback for percentage stats where that representation is
    -- known to be meaningful; do not treat arbitrary ratings as percentages.
    if allowFlatFallback and (value == nil or value <= 0) and flatValue and flatValue > 0 and flatValue <= 500 then
        value = normalizeAdvancedPercent(flatValue)
    end
    return value
end

local function readAdvancedFlat(statType)
    local _, flatValue = readAdvancedStat(statType)
    flatValue = tonumber(flatValue) or 0
    if flatValue ~= flatValue or flatValue < 0 then return 0 end
    return flatValue
end

local function parsePercentText(text)
    if type(text) ~= "string" or text == "" then return nil end
    -- Advanced-stat display strings can contain color markup, localized labels,
    -- or a percent sign. Strip markup and read the first numeric percentage.
    text = text:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
    local value = text:match("([%+%-]?%d+[%.%,]?%d*)%s*%%")
    if not value then value = text:match("([%+%-]?%d+[%.%,]?%d*)") end
    if not value then return nil end
    value = tonumber((value:gsub(",", ".")))
    return normalizeAdvancedPercent(value)
end

local function readCriticalDamageFromAdvancedInfo()
    if type(GetNumAdvancedStatCategories) ~= "function"
        or type(GetAdvancedStatsCategoryId) ~= "function"
        or type(GetAdvancedStatCategoryInfo) ~= "function"
        or type(GetAdvancedStatInfo) ~= "function" then
        return nil
    end

    local wantedType = ADVANCED_STAT_DISPLAY_TYPE_CRITICAL_DAMAGE
    local numCategories = tonumber(safe(GetNumAdvancedStatCategories, 0)) or 0
    for categoryIndex = 1, numCategories do
        local categoryId = safe(GetAdvancedStatsCategoryId, nil, categoryIndex)
        if categoryId ~= nil then
            local _, numStats = safe(GetAdvancedStatCategoryInfo, nil, categoryId)
            numStats = tonumber(numStats) or 0
            for statIndex = 1, numStats do
                local ok, statType, statDisplayName, _, flatValueDescription, percentValueDescription =
                    pcall(GetAdvancedStatInfo, categoryId, statIndex)
                if ok then
                    local isCriticalDamage = wantedType ~= nil and statType == wantedType
                    if not isCriticalDamage and type(statDisplayName) == "string" then
                        local normalized = zo_strlower and zo_strlower(statDisplayName) or string.lower(statDisplayName)
                        isCriticalDamage = normalized:find("critical", 1, true) ~= nil
                            and normalized:find("damage", 1, true) ~= nil
                    end
                    if isCriticalDamage then
                        -- Use the statType returned by ESO itself. This is more robust than
                        -- relying on a global enum name being present/unchanged on every client.
                        local value = readAdvancedPercent(statType, true)
                        if value and value > 0 then return value end

                        -- Last-resort compatibility path for clients that only expose a
                        -- human-readable value through the Advanced Stats row descriptions.
                        value = parsePercentText(percentValueDescription)
                        if value == nil or value <= 0 then value = parsePercentText(flatValueDescription) end
                        if value and value > 0 then return value end
                    end
                end
            end
        end
    end
    return nil
end

-- Shared source for the visible Live Combat Stats frame and the combat recorder.
-- Keeping these reads in one function prevents the report and the overlay from
-- disagreeing about PEN/PWR/SR/PR/CC/CD. A very short cache keeps high-frequency
-- combat events from repeatedly querying ESO's Advanced Stats API in the same frame.
function F:GetCombatStatsSnapshot(force)
    local now = 0
    if type(GetFrameTimeMilliseconds) == "function" then
        local ok, value = pcall(GetFrameTimeMilliseconds)
        if ok then now = tonumber(value) or 0 end
    end
    if force ~= true and type(self.combatStatsSnapshot) == "table"
        and now > 0 and (now - (tonumber(self.combatStatsSnapshotAt) or 0)) < 125 then
        return self.combatStatsSnapshot
    end

    local pen = math.max(
        readPlayerStat(STAT_OFFENSIVE_PENETRATION),
        readPlayerStat(STAT_PHYSICAL_PENETRATION),
        readPlayerStat(STAT_SPELL_PENETRATION),
        readAdvancedFlat(ADVANCED_STAT_DISPLAY_TYPE_PHYSICAL_PENETRATION),
        readAdvancedFlat(ADVANCED_STAT_DISPLAY_TYPE_SPELL_PENETRATION)
    )
    local power = readPlayerStat(STAT_WEAPON_AND_SPELL_DAMAGE)
    if power <= 0 then power = math.max(readPlayerStat(STAT_ATTACK_POWER), readPlayerStat(STAT_SPELL_POWER)) end
    local sr = readPlayerStat(STAT_SPELL_RESIST)
    local pr = readPlayerStat(STAT_PHYSICAL_RESIST)
    local cc = readAdvancedPercent(ADVANCED_STAT_DISPLAY_TYPE_CRITICAL_CHANCE, false)

    local cdBonus = readAdvancedPercent(ADVANCED_STAT_DISPLAY_TYPE_CRITICAL_DAMAGE, true)
    if cdBonus == nil then
        cdBonus = readAdvancedPercent(ADVANCED_STAT_DISPLAY_TYPE_CRITICAL_PERCENT, true)
    end
    if cdBonus == nil then
        cdBonus = readCriticalDamageFromAdvancedInfo()
    end
    local cd = cdBonus ~= nil and (50 + cdBonus) or nil

    local snapshot = {
        penetration = tonumber(pen) or 0,
        power = tonumber(power) or 0,
        spellResistance = tonumber(sr) or 0,
        physicalResistance = tonumber(pr) or 0,
        criticalChance = tonumber(cc),
        criticalDamage = tonumber(cd),
    }
    self.combatStatsSnapshot = snapshot
    self.combatStatsSnapshotAt = now
    return snapshot
end

function F:IsHudSuppressed()
    if self.layoutMode == true then return false end
    return EPC.IsGameplayHudSuppressed and EPC:IsGameplayHudSuppressed() == true
end

function F:ApplyDefaultFrameReplacement()
    if not EPC.saved then return end
    local replace = EPC.saved.replaceDefaultUnitFrames ~= false
    local reason = "ESOProgressionCoach"

    -- Current ESO source exposes unit-frame hidden reasons through UNIT_FRAMES.
    -- Use reason-scoped hiding so disabling this option restores the native UI
    -- without overwriting the player's own ESO visibility settings.
    if UNIT_FRAMES then
        if type(UNIT_FRAMES.SetFrameHiddenForReason) == "function" then
            pcall(UNIT_FRAMES.SetFrameHiddenForReason, UNIT_FRAMES, "reticleover", reason, replace and EPC.saved.showTargetFrame ~= false)
            pcall(UNIT_FRAMES.SetFrameHiddenForReason, UNIT_FRAMES, "companion", reason, replace and EPC.saved.showGroupFrame ~= false)
        end
        local hideGroupRaid = replace and (EPC.saved.showGroupFrame ~= false or EPC.saved.showRaidFrame ~= false)
        if type(UNIT_FRAMES.SetGroupAndRaidFramesHiddenForReason) == "function" then
            pcall(UNIT_FRAMES.SetGroupAndRaidFramesHiddenForReason, UNIT_FRAMES, reason, hideGroupRaid)
        end

        -- The live ESO manager stores native small-group, raid, and companion-raid
        -- unit-frame objects in these tables. Apply the same reason directly to
        -- already-created frames as a fallback, then refresh the native subgroup
        -- label anchors. This prevents leftover native names/labels from sitting
        -- underneath EPC's replacement group frame.
        local function applyReasonToNativeFrames(frameTable)
            if type(frameTable) ~= "table" then return end
            for _, unitFrame in pairs(frameTable) do
                if unitFrame and type(unitFrame.SetHiddenForReason) == "function" then
                    pcall(unitFrame.SetHiddenForReason, unitFrame, reason, hideGroupRaid)
                end
            end
        end
        applyReasonToNativeFrames(UNIT_FRAMES.groupFrames)
        applyReasonToNativeFrames(UNIT_FRAMES.raidFrames)
        applyReasonToNativeFrames(UNIT_FRAMES.companionRaidFrames)
        if type(UNIT_FRAMES.UpdateGroupAnchorFrames) == "function" then
            pcall(UNIT_FRAMES.UpdateGroupAnchorFrames, UNIT_FRAMES)
        end
    end

    if PLAYER_ATTRIBUTE_BARS_FRAGMENT and type(PLAYER_ATTRIBUTE_BARS_FRAGMENT.SetHiddenForReason) == "function" then
        pcall(PLAYER_ATTRIBUTE_BARS_FRAGMENT.SetHiddenForReason, PLAYER_ATTRIBUTE_BARS_FRAGMENT, reason, replace and EPC.saved.showPlayerFrame ~= false)
    end
end

function F:HideAllCustomFrames()
    if self.playerFrame then self.playerFrame:SetHidden(true) end
    if self.playerEffectsFrame then self.playerEffectsFrame:SetHidden(true) end
    if self.targetFrame then self.targetFrame:SetHidden(true) end
    if self.groupFrame then self.groupFrame:SetHidden(true) end
    if self.raidFrame then self.raidFrame:SetHidden(true) end
    if self.statsFrame then self.statsFrame:SetHidden(true) end
end

function F:IsPlayerInCombat()
    if safe(IsUnitInCombat, false, "player") == true then return true end
    if EPC.Combat and type(EPC.Combat.GetHUDSummary) == "function" then
        local summary = EPC.Combat:GetHUDSummary()
        if summary and summary.active == true then return true end
    end
    return false
end

function F:IsPlayerFrameContextActive()
    if self.layoutMode == true then return true end
    if EPC.saved and EPC.saved.playerFrameContextual == false then return true end
    if self:IsPlayerInCombat() then return true end

    local health, healthMax = readPower("player", POWER_HEALTH)
    local magicka, magickaMax = readPower("player", POWER_MAGICKA)
    local stamina, staminaMax = readPower("player", POWER_STAMINA)

    if healthMax > 0 and health < healthMax then return true end
    if magickaMax > 0 and magicka < magickaMax then return true end
    if staminaMax > 0 and stamina < staminaMax then return true end
    return false
end

function F:IsCombatStatsContextActive()
    if self.layoutMode == true then return true end
    if EPC.saved and EPC.saved.combatStatsCombatOnly == false then return true end
    return self:IsPlayerInCombat()
end

function F:RefreshContextVisibility()
    if not EPC.saved or self:IsHudSuppressed() then return end

    if self.playerFrame then
        local shouldShowPlayer = (EPC.saved.showPlayerFrame ~= false or self.layoutMode == true)
            and self:IsPlayerFrameContextActive()
        if self.playerFrame:IsHidden() == shouldShowPlayer then
            self:RefreshPlayer()
        end
    end

    if self.statsFrame then
        local shouldShowStats = (EPC.saved.showCombatStatsFrame ~= false or self.layoutMode == true)
            and self:IsCombatStatsContextActive()
        if self.statsFrame:IsHidden() == shouldShowStats then
            self:RefreshStats()
        end
    end
end

function F:RefreshStats()
    if not self.statsFrame or not EPC.saved then return end
    local show = (EPC.saved.showCombatStatsFrame ~= false or self.layoutMode == true)
        and self:IsCombatStatsContextActive()
        and not self:IsHudSuppressed()
    self.statsFrame:SetHidden(not show)
    if not show then return end

    local snapshot = self:GetCombatStatsSnapshot(true) or {}
    local stats = self.statsFrame.epcStats
    stats.PEN:SetText(compactNumber(snapshot.penetration or 0))
    stats.PWR:SetText(compactNumber(snapshot.power or 0))
    stats.SR:SetText(compactNumber(snapshot.spellResistance or 0))
    stats.PR:SetText(compactNumber(snapshot.physicalResistance or 0))
    stats.CC:SetText(snapshot.criticalChance ~= nil and string.format("%.1f%%", snapshot.criticalChance) or "--")
    stats.CD:SetText(snapshot.criticalDamage ~= nil and string.format("%.1f%%", snapshot.criticalDamage) or "--")

    -- A small link back to the shared recorder makes it obvious that this frame
    -- is the live side of Game Combat without changing the user's six stat cells.
    if self.statsFrame.epcLive then
        local live = EPC.Combat and type(EPC.Combat.GetLiveSummary) == "function" and EPC.Combat:GetLiveSummary() or nil
        if self.layoutMode == true then
            self.statsFrame.epcLive:SetText("LAYOUT")
        elseif live and live.active == true then
            self.statsFrame.epcLive:SetText("LIVE  " .. compactNumber(live.dps or 0) .. " DPS")
        else
            self.statsFrame.epcLive:SetText("PLAYER")
        end
    end
end

function F:RefreshPlayer()
    if not self.playerFrame or not EPC.saved then return end
    local show = (EPC.saved.showPlayerFrame ~= false or self.layoutMode == true)
        and self:IsPlayerFrameContextActive()
        and not self:IsHudSuppressed()
    self.playerFrame:SetHidden(not show)
    if self.playerEffectsFrame then self.playerEffectsFrame:SetHidden(not show) end
    if show then
        self:UpdateUnitFrame(self.playerFrame, "player", self.layoutMode)
        self:RefreshPlayerAuras(self.layoutMode)
    end
end

function F:RefreshTarget(refreshAuras)
    if not self.targetFrame or not EPC.saved then return end
    local exists = safe(DoesUnitExist, false, "reticleover") == true
    local show = EPC.saved.showTargetFrame ~= false and exists and not self:IsHudSuppressed()
    if self.layoutMode then show = true end
    self.targetFrame:SetHidden(not show)
    if show then
        self:UpdateUnitFrame(self.targetFrame, "reticleover", self.layoutMode)
        if refreshAuras ~= false then self:RefreshTargetAuras(self.layoutMode) end
    end
end

function F:ApplyScalesAndAlpha()
    if not EPC.saved then return end
    local unitScale = tonumber(EPC.saved.unitFrameScale) or 1.0
    local groupScale = tonumber(EPC.saved.groupFrameScale) or 1.0
    local statsScale = tonumber(EPC.saved.combatStatsScale) or 1.0
    local alpha = tonumber(EPC.saved.unitFrameAlpha) or 0.94
    if self.playerFrame then self.playerFrame:SetScale(unitScale) self.playerFrame:SetAlpha(alpha) end
    if self.playerEffectsFrame then self.playerEffectsFrame:SetScale(unitScale) self.playerEffectsFrame:SetAlpha(alpha) end
    if self.targetFrame then self.targetFrame:SetScale(unitScale) self.targetFrame:SetAlpha(alpha) end
    if self.groupFrame then self.groupFrame:SetScale(groupScale) self.groupFrame:SetAlpha(alpha) end
    if self.raidFrame then self.raidFrame:SetScale(groupScale) self.raidFrame:SetAlpha(alpha) end
    if self.statsFrame then self.statsFrame:SetScale(statsScale) self.statsFrame:SetAlpha(alpha) end
    self:ApplyVisualStyle()
end

-- v0.9.3 compact dark HUD style. Panels are intentionally readable/opaque enough
-- that the game world does not wash through text, bars, or aura icons.
function F:ApplyVisualStyle()
    if not EPC.saved then return end
    local backgrounds = EPC.saved.unitFrameBackgrounds == true
    local softBackground = EPC.saved.unitFrameSoftBackground ~= false
    local backgroundAlpha = math.max(0.45, math.min(0.95, tonumber(EPC.saved.unitFrameBackgroundAlpha) or 0.72))
    local layout = self.layoutMode == true

    local function styleShell(frame)
        if not frame then return end
        if frame.epcNoPanel then
            if frame.epcShadow then frame.epcShadow:SetHidden(true) end
            if frame.epcBackground then frame.epcBackground:SetHidden(true) end
            if frame.epcAccent then frame.epcAccent:SetHidden(true) end
            return
        end
        if frame.epcShadow then frame.epcShadow:SetHidden(not backgrounds or layout) end
        if frame.epcBackground then
            if layout then
                frame.epcBackground:SetHidden(false)
                frame.epcBackground:SetCenterColor(0.018, 0.022, 0.030, 0.34)
                frame.epcBackground:SetEdgeColor(unpack(C.gold))
            elseif backgrounds then
                frame.epcBackground:SetHidden(false)
                frame.epcBackground:SetCenterColor(0.025, 0.032, 0.045, 0.72)
                frame.epcBackground:SetEdgeColor(0.16, 0.19, 0.25, 0.56)
            elseif softBackground then
                frame.epcBackground:SetHidden(false)
                frame.epcBackground:SetCenterColor(0.020, 0.026, 0.036, backgroundAlpha)
                frame.epcBackground:SetEdgeColor(0.18, 0.21, 0.27, math.min(0.82, backgroundAlpha + 0.08))
            else
                frame.epcBackground:SetHidden(true)
            end
        end
    end

    styleShell(self.playerFrame)
    styleShell(self.playerEffectsFrame)
    styleShell(self.targetFrame)
    styleShell(self.groupFrame)
    styleShell(self.raidFrame)
    styleShell(self.statsFrame)

    local function styleMemberRows(frame)
        if not frame or not frame.epcRows then return end
        for i = 1, #frame.epcRows do
            local row = frame.epcRows[i]
            if row then
                if backgrounds then
                    row:SetCenterColor(unpack(C.panel))
                    row:SetEdgeColor(unpack(C.edgeSoft))
                elseif layout then
                    row:SetCenterColor(0.025, 0.030, 0.040, 0.25)
                    row:SetEdgeColor(0.30, 0.32, 0.36, 0.42)
                elseif softBackground then
                    row:SetCenterColor(0.022, 0.028, 0.038, math.max(0.40, backgroundAlpha * 0.82))
                    row:SetEdgeColor(0.16, 0.18, 0.23, math.max(0.34, backgroundAlpha * 0.68))
                else
                    row:SetCenterColor(0, 0, 0, 0)
                    row:SetEdgeColor(0, 0, 0, 0)
                end
            end
        end
    end
    styleMemberRows(self.groupFrame)
    styleMemberRows(self.raidFrame)

    if self.statsFrame and self.statsFrame.epcCells then
        for i = 1, #self.statsFrame.epcCells do
            local cell = self.statsFrame.epcCells[i]
            if backgrounds then
                cell:SetCenterColor(0.025, 0.030, 0.040, 0.96)
                cell:SetEdgeColor(unpack(C.edgeSoft))
            elseif layout then
                cell:SetCenterColor(0.025, 0.030, 0.040, 0.22)
                cell:SetEdgeColor(0.30, 0.32, 0.36, 0.35)
            elseif softBackground then
                cell:SetCenterColor(0.022, 0.028, 0.038, math.max(0.42, backgroundAlpha * 0.88))
                cell:SetEdgeColor(0.16, 0.18, 0.23, math.max(0.34, backgroundAlpha * 0.68))
            else
                cell:SetCenterColor(0, 0, 0, 0)
                cell:SetEdgeColor(0, 0, 0, 0)
            end
        end
    end

    local function styleAuraSlots(frame)
        if not frame then return end
        local groups = { frame.epcBuffSlots, frame.epcDebuffSlots }
        for g = 1, #groups do
            local slots = groups[g]
            if slots then
                for i = 1, #slots do
                    local slot = slots[i]
                    if slot then
                        if frame.epcNoPanel then
                            slot:SetCenterColor(0, 0, 0, 0)
                        elseif backgrounds then
                            slot:SetCenterColor(0.015, 0.018, 0.024, 0.70)
                        elseif softBackground then
                            slot:SetCenterColor(0.020, 0.026, 0.036, math.max(0.44, backgroundAlpha * 0.82))
                        else
                            slot:SetCenterColor(0, 0, 0, 0)
                        end
                    end
                end
            end
        end
    end
    styleAuraSlots(self.playerEffectsFrame)
    styleAuraSlots(self.targetFrame)
end

function F:ApplyLayoutState(frame)
    if not frame then return end
    local active = self.layoutMode == true
    frame:SetMouseEnabled(active)
    frame:SetMovable(active)
    if frame.epcMoveHint then frame.epcMoveHint:SetHidden(not active) end
end

function F:SetLayoutMode(active)
    self.layoutMode = active == true
    self:ApplyLayoutState(self.playerFrame)
    self:ApplyLayoutState(self.playerEffectsFrame)
    self:ApplyLayoutState(self.targetFrame)
    self:ApplyLayoutState(self.groupFrame)
    self:ApplyLayoutState(self.raidFrame)
    self:ApplyLayoutState(self.statsFrame)
    self:ApplyVisualStyle()
    self:RefreshAll(true)
end

function F:ResetPositions()
    if not EPC.saved then return end
    for kind, keys in pairs(POSITION_KEYS) do
        EPC.saved[keys[1]] = -1
        EPC.saved[keys[2]] = -1
        local frame = self[kind .. "Frame"]
        if kind == "stats" then frame = self.statsFrame elseif kind == "effects" then frame = self.playerEffectsFrame end
        if frame then self:AnchorWindow(frame, kind) end
    end
end

function F:RefreshAll(refreshAuras)
    self:ApplyDefaultFrameReplacement()
    self:ApplyScalesAndAlpha()
    self:RefreshPlayer()
    self:RefreshTarget(refreshAuras ~= false)
    self:RefreshGroupFrames()
    self:RefreshStats()
end

function F:RefreshUnitTag(unitTag)
    if not unitTag or unitTag == "" then return end
    if unitTag == "player" then
        self:RefreshPlayer()
    elseif unitTag == "reticleover" then
        self:RefreshTarget(false)
    elseif string.sub(unitTag, 1, 5) == "group" then
        local rows = {}
        if self.groupFrame and not self.groupFrame:IsHidden() then rows = self.groupFrame.epcRows
        elseif self.raidFrame and not self.raidFrame:IsHidden() then rows = self.raidFrame.epcRows end
        for i = 1, #rows do
            if rows[i].epcUnitTag == unitTag then self:UpdateMemberRow(rows[i], unitTag, nil) break end
        end
    end
end

-- Update group health directly from EVENT_POWER_UPDATE's fresh values.
-- Re-reading GetUnitPower() inside the event can lag one state behind for
-- remote group units, making the custom group bar visibly trail the player.
function F:UpdateGroupHealthFromEvent(unitTag, powerValue, powerMax)
    if not unitTag or unitTag == "" then return false end
    local current = tonumber(powerValue)
    local maximum = tonumber(powerMax)
    if current == nil or maximum == nil or maximum <= 0 then return false end

    -- ESO reports the local character's immediate power changes with the
    -- "player" unit tag.  In an actual group, however, our roster row stores
    -- that same character as group1/group2/etc.  Update both identities from
    -- the player event so the Group frame moves on the exact same event as the
    -- Player frame instead of waiting for the periodic roster refresh.
    local localGroupTag = nil
    if unitTag == "player" and type(GetLocalPlayerGroupUnitTag) == "function" then
        localGroupTag = safe(GetLocalPlayerGroupUnitTag, "")
        if localGroupTag == "" then localGroupTag = nil end
    end

    local isGroupEvent = string.sub(unitTag, 1, 5) == "group"
    if unitTag ~= "player" and not isGroupEvent then return false end

    local function rowMatches(row)
        if not row or not row.epcUnitTag then return false end
        if row.epcUnitTag == unitTag then return true end
        if unitTag == "player" then
            if localGroupTag and row.epcUnitTag == localGroupTag then return true end
            if type(AreUnitsEqual) == "function" and safe(AreUnitsEqual, false, row.epcUnitTag, "player") == true then
                return true
            end
        end
        return false
    end

    local function updateRows(frame)
        if not frame or frame:IsHidden() or not frame.epcRows then return false end
        local updated = false
        for i = 1, #frame.epcRows do
            local row = frame.epcRows[i]
            if rowMatches(row) and row.epcBars and row.epcBars.health then
                updateFillBar(row.epcBars.health, current, maximum, "")
                updated = true
            end
        end
        return updated
    end

    local groupUpdated = updateRows(self.groupFrame)
    local raidUpdated = updateRows(self.raidFrame)
    return groupUpdated or raidUpdated
end

-- Apply the event payload directly to the local Player health bar. This avoids
-- re-reading GetUnitPower() inside EVENT_POWER_UPDATE, which can be one update
-- behind on some clients and makes damage/healing appear to stick or jump.
function F:UpdatePlayerHealthFromEvent(unitTag, powerValue, powerMax)
    if unitTag ~= "player" or not self.playerFrame or not self.playerFrame.epcBars then return false end
    local current = tonumber(powerValue)
    local maximum = tonumber(powerMax)
    if current == nil or maximum == nil or maximum <= 0 then return false end
    local bar = self.playerFrame.epcBars.health
    if not bar then return false end
    updateFillBar(bar, current, maximum, "")
    return true
end

-- v0.29.341: target Health can change many times per second in combat. Apply
-- EVENT_POWER_UPDATE's payload directly to the target bar rather than running
-- the full target-frame refresh/aura/layout chain on every damage tick.
function F:UpdateTargetHealthFromEvent029341(unitTag, powerValue, powerMax)
    if unitTag ~= "reticleover" or not self.targetFrame or not self.targetFrame.epcBars then return false end
    local current = tonumber(powerValue)
    local maximum = tonumber(powerMax)
    if current == nil or maximum == nil or maximum <= 0 then return false end
    local bar = self.targetFrame.epcBars.health
    if not bar then return false end
    updateFillBar(bar, current, maximum, "")
    return true
end

-- v0.29.341: sprinting/resource regeneration can emit frequent Stamina and
-- Magicka power events. Update only the affected Player bar from the event
-- payload instead of rebuilding the entire Player frame and its visual-policy
-- wrapper chain on every resource tick.
function F:UpdatePlayerResourceFromEvent029341(unitTag, powerType, powerValue, powerMax)
    if unitTag ~= "player" or not self.playerFrame or not self.playerFrame.epcBars then return false end
    local current = tonumber(powerValue)
    local maximum = tonumber(powerMax)
    if current == nil or maximum == nil or maximum <= 0 then return false end
    local bar = nil
    if powerType == POWER_MAGICKA or powerType == POWERTYPE_MAGICKA then
        bar = self.playerFrame.epcBars.magicka
    elseif powerType == POWER_STAMINA or powerType == POWERTYPE_STAMINA then
        bar = self.playerFrame.epcBars.stamina
    end
    if not bar then return false end
    updateFillBar(bar, current, maximum, "")
    return true
end

-- Companion health is a separate unit power stream. Match the event's companion
-- unit tag against the companion attached to each visible Group row and push the
-- fresh values straight into that companion bar. This works for the local
-- "companion" tag and for group-member companion tags returned by ESO.
function F:UpdateCompanionHealthFromEvent(unitTag, powerValue, powerMax)
    if not unitTag or unitTag == "" then return false end
    local current = tonumber(powerValue)
    local maximum = tonumber(powerMax)
    if current == nil or maximum == nil or maximum <= 0 then return false end

    local function sameUnit(a, b)
        if not a or not b or a == "" or b == "" then return false end
        if a == b then return true end
        if type(AreUnitsEqual) == "function" then
            return safe(AreUnitsEqual, false, a, b) == true
        end
        return false
    end

    local function updateRows(frame)
        if not frame or frame:IsHidden() or not frame.epcRows then return false end
        local updated = false
        for i = 1, #frame.epcRows do
            local row = frame.epcRows[i]
            if row and not row:IsHidden() and row.epcUnitTag and row.epcCompanionHealth and row.epcCompanionHealth ~= false then
                local companionTag = self:GetCompanionForMember(row.epcUnitTag)
                if sameUnit(companionTag, unitTag) then
                    updateFillBar(row.epcCompanionHealth, current, maximum, "")
                    row.epcHasCompanion = true
                    updated = true
                end
            end
        end
        return updated
    end

    local groupUpdated = updateRows(self.groupFrame)
    local raidUpdated = updateRows(self.raidFrame)
    return groupUpdated or raidUpdated
end

function F:RegisterEvents()
    local prefix = EPC.name .. "_UnitFrames"
    if EVENT_POWER_UPDATE then
        local function registerPower(suffix, unitFilterType, unitFilterValue, powerType, syncLiveHealth, combatResourceKey)
            local registration = prefix .. "_Power_" .. suffix
            EVENT_MANAGER:RegisterForEvent(registration, EVENT_POWER_UPDATE, function(_, unitTag, powerIndex, eventPowerType, powerValue, powerMax)
                local handled = false

                if combatResourceKey and unitTag == "player" and EPC.Combat and type(EPC.Combat.OnPowerUpdate) == "function" then
                    EPC.Combat:OnPowerUpdate(combatResourceKey, powerValue, powerMax)
                end

                -- Health bars use the event payload itself so Player, Group/Raid,
                -- and Companion bars deplete/regenerate on the exact power event.
                -- This also avoids expensive whole-frame/aura refreshes on every hit.
                if syncLiveHealth == true then
                    if unitTag == "player" then
                        handled = self:UpdatePlayerHealthFromEvent(unitTag, powerValue, powerMax) or handled
                    elseif unitTag == "reticleover" then
                        handled = self:UpdateTargetHealthFromEvent029341(unitTag, powerValue, powerMax) or handled
                    end
                    handled = self:UpdateGroupHealthFromEvent(unitTag, powerValue, powerMax) or handled
                    handled = self:UpdateCompanionHealthFromEvent(unitTag, powerValue, powerMax) or handled
                end

                -- Player Magicka/Stamina use the event payload directly too. In
                -- particular, sprinting produces frequent Stamina updates; routing
                -- those through RefreshUnitTag() was a major movement-only cost.
                if not handled and unitTag == "player" then
                    handled = self:UpdatePlayerResourceFromEvent029341(unitTag, eventPowerType, powerValue, powerMax) or handled
                end

                -- Unmatched target/other power changes still use the mature full
                -- refresh path. Already-handled Player/Group/Companion events do not.
                if not handled then
                    self:RefreshUnitTag(unitTag)
                end
            end)
            if unitFilterType and unitFilterValue ~= nil then
                EVENT_MANAGER:AddFilterForEvent(registration, EVENT_POWER_UPDATE, unitFilterType, unitFilterValue)
            end
            if REGISTER_FILTER_POWER_TYPE and powerType ~= nil then
                EVENT_MANAGER:AddFilterForEvent(registration, EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, powerType)
            end
        end

        if REGISTER_FILTER_UNIT_TAG then
            registerPower("PlayerHealth", REGISTER_FILTER_UNIT_TAG, "player", FILTER_POWER_HEALTH, true)
            registerPower("PlayerMagicka", REGISTER_FILTER_UNIT_TAG, "player", FILTER_POWER_MAGICKA, false, "MAGICKA")
            registerPower("PlayerStamina", REGISTER_FILTER_UNIT_TAG, "player", FILTER_POWER_STAMINA, false, "STAMINA")
            registerPower("TargetHealth", REGISTER_FILTER_UNIT_TAG, "reticleover", FILTER_POWER_HEALTH, true)
            registerPower("CompanionHealth", REGISTER_FILTER_UNIT_TAG, "companion", FILTER_POWER_HEALTH, true)

            -- One native prefix filter covers the entire group/raid roster and ESO's
            -- group-companion unit tags, including raid slots beyond group12. This is
            -- both more complete and cheaper than dozens of separate Lua callbacks.
            if REGISTER_FILTER_UNIT_TAG_PREFIX then
                registerPower("GroupHealth", REGISTER_FILTER_UNIT_TAG_PREFIX, "group", FILTER_POWER_HEALTH, true)
            else
                local maxGroup = 24
                if type(GetGroupMaxSize) == "function" then
                    local ok, value = pcall(GetGroupMaxSize)
                    if ok and tonumber(value) then maxGroup = math.max(12, math.min(24, tonumber(value))) end
                end
                for i = 1, maxGroup do
                    local groupTag = "group" .. tostring(i)
                    registerPower("GroupHealth" .. tostring(i), REGISTER_FILTER_UNIT_TAG, groupTag, FILTER_POWER_HEALTH, true)
                end
            end
        else
            -- Compatibility fallback for very old clients: still restrict to Health
            -- where the power-type filter is available, then discard unrelated tags
            -- in the lightweight callback above.
            registerPower("FallbackHealth", nil, nil, FILTER_POWER_HEALTH, true)
        end
    end
    if EVENT_PLAYER_COMBAT_STATE then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_CombatState", EVENT_PLAYER_COMBAT_STATE, function()
            self:RefreshPlayer()
            self:RefreshStats()
        end)
    end
    if EVENT_RETICLE_TARGET_CHANGED then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_Target", EVENT_RETICLE_TARGET_CHANGED, function()
            self:RefreshTarget(true)
        end)
    end
    if EVENT_EFFECT_CHANGED then
        local playerEffectsRegistration = prefix .. "_Effects_Player"
        EVENT_MANAGER:RegisterForEvent(playerEffectsRegistration, EVENT_EFFECT_CHANGED, function()
            self:RefreshPlayerAuras(false)
        end)
        if REGISTER_FILTER_UNIT_TAG then
            EVENT_MANAGER:AddFilterForEvent(playerEffectsRegistration, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
        end

        local targetEffectsRegistration = prefix .. "_Effects_Target"
        EVENT_MANAGER:RegisterForEvent(targetEffectsRegistration, EVENT_EFFECT_CHANGED, function()
            self:RefreshTargetAuras(false)
        end)
        if REGISTER_FILTER_UNIT_TAG then
            EVENT_MANAGER:AddFilterForEvent(targetEffectsRegistration, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "reticleover")
        end
    end
    if EVENT_EFFECTS_FULL_UPDATE then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_EffectsFull", EVENT_EFFECTS_FULL_UPDATE, function()
            self:RefreshPlayerAuras(false)
            self:RefreshTargetAuras(false)
        end)
    end
    if EVENT_ARTIFICIAL_EFFECT_ADDED then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_ArtificialAdded", EVENT_ARTIFICIAL_EFFECT_ADDED, function()
            self:RefreshPlayerAuras(false)
        end)
    end
    if EVENT_ARTIFICIAL_EFFECT_REMOVED then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_ArtificialRemoved", EVENT_ARTIFICIAL_EFFECT_REMOVED, function()
            self:RefreshPlayerAuras(false)
        end)
    end
    if EVENT_STATS_UPDATED then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_Stats", EVENT_STATS_UPDATED, function(_, unitTag)
            if unitTag == "player" then self:RefreshStats() self:RefreshPlayer() end
        end)
    end
    if EVENT_LEVEL_UPDATE then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_Level", EVENT_LEVEL_UPDATE, function(_, unitTag)
            self:RefreshUnitTag(unitTag)
        end)
    end
    if EVENT_CHAMPION_POINT_UPDATE then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_CP", EVENT_CHAMPION_POINT_UPDATE, function(_, unitTag)
            self:RefreshUnitTag(unitTag)
        end)
    end
    local companionEvents = { EVENT_ACTIVE_COMPANION_STATE_CHANGED, EVENT_COMPANION_ACTIVATED, EVENT_COMPANION_DEACTIVATED, EVENT_COMPANION_EXPERIENCE_GAIN }
    local companionSeen = {}
    for i = 1, #companionEvents do
        local eventId = companionEvents[i]
        if eventId and not companionSeen[eventId] then
            companionSeen[eventId] = true
            EVENT_MANAGER:RegisterForEvent(prefix .. "_Companion_" .. tostring(eventId), eventId, function()
                self:RefreshPlayer()
                self:RefreshGroupFrames()
                self:ApplyDefaultFrameReplacement()
            end)
        end
    end
    if EVENT_UNIT_DEATH_STATE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_Death", EVENT_UNIT_DEATH_STATE_CHANGED, function(_, unitTag)
            self:RefreshUnitTag(unitTag)
        end)
    end

    local groupEvents = {}
    local function addGroupEvent(eventId)
        if eventId then groupEvents[#groupEvents + 1] = eventId end
    end
    addGroupEvent(EVENT_GROUP_UPDATE)
    addGroupEvent(EVENT_GROUP_MEMBER_JOINED)
    addGroupEvent(EVENT_GROUP_MEMBER_LEFT)
    addGroupEvent(EVENT_GROUP_MEMBER_ROLE_CHANGED)
    addGroupEvent(EVENT_GROUP_MEMBER_CONNECTED_STATUS)
    addGroupEvent(EVENT_GROUP_SUPPORT_RANGE_UPDATE)
    addGroupEvent(EVENT_GROUP_TYPE_CHANGED)
    addGroupEvent(EVENT_PLAYER_ACTIVATED)
    local seen = {}
    for i = 1, #groupEvents do
        local eventId = groupEvents[i]
        if not seen[eventId] then
            seen[eventId] = true
            EVENT_MANAGER:RegisterForEvent(prefix .. "_Group_" .. tostring(eventId), eventId, function()
                self:RefreshGroupFrames()
                self:RefreshPlayer()
                self:ApplyDefaultFrameReplacement()
            end)
        end
    end

    EVENT_MANAGER:RegisterForUpdate(prefix .. "_Visibility", 650, function()
        local suppressed = self:IsHudSuppressed()
        if suppressed ~= self.lastHudSuppressed then
            self.lastHudSuppressed = suppressed
            if suppressed then
                self:HideAllCustomFrames()
                if EPC.UI then
                    if EPC.UI.root then EPC.UI.root:SetHidden(true) end
                    if EPC.UI.combatHud then EPC.UI.combatHud:SetHidden(true) end
                end
            else
                if EPC.UI and EPC.UI.root then EPC.UI.root:SetHidden(true) end -- legacy menu retired; Codex only
                self:RefreshAll(true)
                if EPC.UI and EPC.UI.UpdateCombatHUD and EPC.Combat then EPC.UI:UpdateCombatHUD(EPC.Combat:GetHUDSummary()) end
            end
        elseif not suppressed then
            -- Resource/combat context can change without a scene transition. Only
            -- rebuild a contextual frame when its visibility state actually flips.
            self:RefreshContextVisibility()
        end
    end)
    EVENT_MANAGER:RegisterForUpdate(prefix .. "_StatsTick", 1000, function()
        if self.statsFrame and not self.statsFrame:IsHidden() then self:RefreshStats() end
    end)
end

function F:Initialize()
    self.layoutMode = false
    self.lastHudSuppressed = nil
    self.playerFrame = self:CreateUnitFrame("EPC_PlayerFrame", "player", 288, 88, false)
    self.playerEffectsFrame = self:CreatePlayerEffectsFrame()
    self.targetFrame = self:CreateUnitFrame("EPC_TargetFrame", "target", 468, 120, true)
    self.groupFrame = self:CreateGroupFrame()
    self.raidFrame = self:CreateRaidFrame()
    self.statsFrame = self:CreateStatsFrame()
    self:RegisterEvents()
    self:ApplyScalesAndAlpha()
    self:RefreshAll(true)
end

-- ============================================================================
-- v0.20.0 ESO-style scalable Player/Target frames with integrated effects.
-- This block intentionally overrides the older frame constructors above while
-- keeping the mature Group/Raid/Live Stats code intact.
-- ============================================================================
local EPC_NATIVE_FRAME_TEX = "EsoUI/Art/UnitAttributeVisualizer/attributeBar_dynamic_frame.dds"
local EPC_NATIVE_BG_TEX = "EsoUI/Art/UnitAttributeVisualizer/attributeBar_dynamic_bg.dds"
local EPC_NATIVE_FILL_TEX = "EsoUI/Art/UnitAttributeVisualizer/attributeBar_dynamic_fill.dds"
local EPC_NATIVE_GLOSS_TEX = "EsoUI/Art/UnitAttributeVisualizer/attributeBar_dynamic_fill_gloss.dds"

local function createESOResourceBar(parent, name, width, color)
    local bar = wm:CreateControl(name, parent, CT_CONTROL)
    bar:SetDimensions(width, 23)

    local bg = wm:CreateControl(name .. "_NativeBG", bar, CT_TEXTURE)
    bg:SetAnchor(TOPLEFT, bar, TOPLEFT, 13, 3)
    bg:SetAnchor(BOTTOMRIGHT, bar, BOTTOMRIGHT, -13, -3)
    bg:SetTexture(EPC_NATIVE_BG_TEX)
    bg:SetTextureCoords(0.4921875, 0.5546875, 0.328125, 0.6875)

    local fill = wm:CreateControlFromVirtual(name .. "_NativeFill", bar, "ZO_PlayerAttributeStatusBar_Keyboard_Template")
    fill:ClearAnchors()
    fill:SetAnchor(TOPLEFT, bar, TOPLEFT, 13, 3)
    fill:SetAnchor(BOTTOMRIGHT, bar, BOTTOMRIGHT, -13, -3)
    fill:SetMinMax(0, 1)
    fill:SetValue(0)
    fill:SetColor(unpack(color))

    local gloss = wm:CreateControlFromVirtual(name .. "_Gloss", bar, "ZO_PlayerAttributeStatusBarGloss_Keyboard_Template")
    gloss:ClearAnchors()
    gloss:SetAnchor(TOPLEFT, bar, TOPLEFT, 13, 3)
    gloss:SetAnchor(BOTTOMRIGHT, bar, BOTTOMRIGHT, -13, -3)
    gloss:SetMinMax(0, 1)
    gloss:SetValue(0)
    gloss:SetColor(1,1,1,0.50)

    local left = wm:CreateControl(name .. "_FrameLeft", bar, CT_TEXTURE)
    left:SetDimensions(13, 23)
    left:SetAnchor(LEFT, bar, LEFT, 0, 0)
    left:SetTexture(EPC_NATIVE_FRAME_TEX)
    left:SetTextureCoords(0.3671875, 0.46875, 0.328125, 0.6875)

    local right = wm:CreateControl(name .. "_FrameRight", bar, CT_TEXTURE)
    right:SetDimensions(13, 23)
    right:SetAnchor(RIGHT, bar, RIGHT, 0, 0)
    right:SetTexture(EPC_NATIVE_FRAME_TEX)
    right:SetTextureCoords(0.46875, 0.3671875, 0.328125, 0.6875)

    local center = wm:CreateControl(name .. "_FrameCenter", bar, CT_TEXTURE)
    center:SetAnchor(TOPLEFT, left, TOPRIGHT, 0, 0)
    center:SetAnchor(BOTTOMRIGHT, right, BOTTOMLEFT, 0, 0)
    center:SetTexture(EPC_NATIVE_FRAME_TEX)
    center:SetTextureCoords(0.4921875, 0.5546875, 0.328125, 0.6875)

    local label = makeLabel(bar, name .. "_Value", "ZoFontGameSmall", C.white, TEXT_ALIGN_CENTER)
    label:SetAnchorFill(bar)

    bar.epcNative = true
    bar.epcFill = fill
    bar.epcGloss = gloss
    bar.epcLabel = label
    return bar
end

local function updateESOResourceBar(bar, current, maximum)
    if not bar then return end
    current, maximum = tonumber(current) or 0, tonumber(maximum) or 0
    if maximum <= 0 then
        bar.epcFill:SetMinMax(0, 1)
        bar.epcFill:SetValue(0)
        if bar.epcGloss then bar.epcGloss:SetMinMax(0,1) bar.epcGloss:SetValue(0) end
        bar.epcLabel:SetText("--")
        return
    end
    bar.epcFill:SetMinMax(0, maximum)
    bar.epcFill:SetValue(math.max(0, math.min(current, maximum)))
    if bar.epcGloss then bar.epcGloss:SetMinMax(0,maximum) bar.epcGloss:SetValue(math.max(0,math.min(current,maximum))) end
    bar.epcLabel:SetText(string.format("%s / %s  (%s)", compactNumber(current), compactNumber(maximum), percentText(current, maximum)))
end

local function createIntegratedAuraSlot(frame, name, prefix, index, edgeColor)
    local slot = makeBackdrop(frame, name .. "_" .. prefix .. tostring(index), {0,0,0,0}, edgeColor)
    slot:SetDimensions(30,30)
    slot:SetCenterColor(0,0,0,0)
    slot:SetDrawLayer(DL_OVERLAY)
    slot:SetDrawLevel(prefix == "Debuff" and 80 or 70)
    local icon = wm:CreateControl(name .. "_" .. prefix .. tostring(index) .. "_Icon", slot, CT_TEXTURE)
    icon:SetAnchorFill(slot)
    local timerBack = wm:CreateControl(name .. "_" .. prefix .. tostring(index) .. "_TimerBack", slot, CT_BACKDROP)
    timerBack:SetAnchor(CENTER, slot, CENTER, 0, 0)
    timerBack:SetDimensions(22, 16)
    timerBack:SetCenterColor(0, 0, 0, 0.94)
    timerBack:SetEdgeColor(0, 0, 0, 1)
    timerBack:SetEdgeTexture(nil, 1, 1, 1)
    timerBack:SetHidden(true)
    local timer = makeLabel(slot, name .. "_" .. prefix .. tostring(index) .. "_Timer", "$(BOLD_FONT)|16|soft-shadow-thick", C.white, TEXT_ALIGN_CENTER)
    timer:SetAnchorFill(slot)
    timer:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    timer:SetColor(1.00, 0.64, 0.16, 1)
    local stack = makeLabel(slot, name .. "_" .. prefix .. tostring(index) .. "_Stack", "ZoFontGameSmall", C.gold, TEXT_ALIGN_RIGHT)
    stack:SetAnchor(TOPRIGHT, slot, TOPRIGHT, -1, 0)
    stack:SetDimensions(14,11)
    slot.epcIcon, slot.epcTimerBack, slot.epcTimer, slot.epcStack, slot.epcName = icon, timerBack, timer, stack, ""
    slot:SetHidden(true)
    return slot
end

function F:CreateUnitFrame(name, kind, width, height, includeAuras)
    local frame = self:CreateShell(name, kind, width, height)
    frame.epcNoPanel = true
    if frame.epcShadow then frame.epcShadow:SetHidden(true) end
    if frame.epcBackground then frame.epcBackground:SetHidden(true) end
    if frame.epcAccent then frame.epcAccent:SetHidden(true) end

    local title = makeLabel(frame, name .. "_Name", "ZoFontWinH4", C.white, TEXT_ALIGN_CENTER)
    title:SetAnchor(TOPLEFT, frame, TOPLEFT, 12, 0)
    title:SetDimensions(width - 24, 22)
    local info = makeLabel(frame, name .. "_Info", "ZoFontGameSmall", C.muted, TEXT_ALIGN_CENTER)
    info:SetAnchor(TOPLEFT, frame, TOPLEFT, 12, 20)
    info:SetDimensions(width - 24, 18)

    local barWidth = width - 24
    local health = createESOResourceBar(frame, name .. "_Health", barWidth, C.health)
    local magicka = createESOResourceBar(frame, name .. "_Magicka", barWidth, C.magicka)
    local stamina = createESOResourceBar(frame, name .. "_Stamina", barWidth, C.stamina)

    frame.epcTitle, frame.epcInfo = title, info
    frame.epcCompanionInfo = false
    frame.epcBars = {health=health, magicka=magicka, stamina=stamina}
    frame.epcBuffSlots, frame.epcDebuffSlots = {}, {}
    frame.epcAuraSlotSize, frame.epcAuraSlotStep = 30, 33
    frame.epcAuraFactory = function(prefix, index, edgeColor)
        return createIntegratedAuraSlot(frame, name, prefix, index, edgeColor)
    end
    for i=1,6 do
        frame.epcBuffSlots[i] = frame.epcAuraFactory("Buff", i, C.green)
        frame.epcDebuffSlots[i] = frame.epcAuraFactory("Debuff", i, C.red)
    end
    return frame
end

function F:EnsureIntegratedAuraSlots(frame, buffCount, debuffCount)
    if not frame or not frame.epcAuraFactory then return end
    while #frame.epcBuffSlots < buffCount do
        local i=#frame.epcBuffSlots+1
        frame.epcBuffSlots[i]=frame.epcAuraFactory("Buff",i,C.green)
    end
    while #frame.epcDebuffSlots < debuffCount do
        local i=#frame.epcDebuffSlots+1
        frame.epcDebuffSlots[i]=frame.epcAuraFactory("Debuff",i,C.red)
    end
end

function F:LayoutIntegratedUnitFrame(frame, buffCount, debuffCount, preview)
    if not frame then return end
    local width = frame:GetWidth()
    local step = tonumber(frame.epcAuraSlotStep) or 31
    local pad = 12
    local perRow = math.max(1, math.floor((width - pad*2) / step))
    local top = 39

    local displayBuffs = tonumber(buffCount) or 0
    local displayDebuffs = tonumber(debuffCount) or 0
    if preview then displayBuffs = math.max(displayBuffs, 4) displayDebuffs = math.max(displayDebuffs, 3) end

    local function position(slots, displayCount, startY)
        for i=1,#slots do
            local slot=slots[i]
            slot:ClearAnchors()
            local row=math.floor((i-1)/perRow)
            local col=(i-1)%perRow
            slot:SetAnchor(TOPLEFT,frame,TOPLEFT,pad+col*step,startY+row*step)
        end
        return displayCount > 0 and math.ceil(displayCount/perRow) or 0
    end

    -- Buffs are always above Health.
    local buffRows = position(frame.epcBuffSlots, displayBuffs, top)
    local healthY = top + (buffRows * step) + (buffRows > 0 and 4 or 0)
    frame.epcBars.health:ClearAnchors()
    frame.epcBars.health:SetAnchor(TOPLEFT,frame,TOPLEFT,pad,healthY)

    -- Debuffs are always immediately below Health.
    local debuffY = healthY + 27
    local debuffRows = position(frame.epcDebuffSlots, displayDebuffs, debuffY)
    local magY = debuffY + (debuffRows * step) + (debuffRows > 0 and 4 or 2)
    frame.epcBars.magicka:ClearAnchors()
    frame.epcBars.magicka:SetAnchor(TOPLEFT,frame,TOPLEFT,pad,magY)
    frame.epcBars.stamina:ClearAnchors()
    frame.epcBars.stamina:SetAnchor(TOPLEFT,frame,TOPLEFT,pad,magY+26)
    frame:SetHeight(magY + 52)
end

function F:UpdateUnitFrame(frame, unitTag, preview)
    if not frame then return false end
    local exists = preview == true or safe(DoesUnitExist,false,unitTag) == true
    if not exists then return false end
    local name, info = self:GetUnitMeta(unitTag)
    if preview and safe(DoesUnitExist,false,unitTag) ~= true then
        name = frame.epcKind == "target" and "TARGET PREVIEW" or "PLAYER PREVIEW"
        info = "LAYOUT MODE"
    end
    frame.epcTitle:SetText(name)
    frame.epcInfo:SetText(info)
    local hp,hpMax=readPower(unitTag,POWER_HEALTH)
    local mag,magMax=readPower(unitTag,POWER_MAGICKA)
    local stam,stamMax=readPower(unitTag,POWER_STAMINA)
    if preview then
        if hpMax<=0 then hp,hpMax=76000,100000 end
        if magMax<=0 then mag,magMax=28000,40000 end
        if stamMax<=0 then stam,stamMax=21000,30000 end
    end
    updateESOResourceBar(frame.epcBars.health,hp,hpMax)
    updateESOResourceBar(frame.epcBars.magicka,mag,magMax)
    updateESOResourceBar(frame.epcBars.stamina,stam,stamMax)
    return true
end

function F:RefreshIntegratedAuras(frame, unitTag, preview)
    if not frame then return end
    local buffs,debuffs={},{}
    if not (preview and safe(DoesUnitExist,false,unitTag) ~= true) and safe(DoesUnitExist,false,unitTag) == true then
        buffs,debuffs=self:GetAuraData(unitTag)
    end
    self:EnsureIntegratedAuraSlots(frame,#buffs,#debuffs)
    self:LayoutIntegratedUnitFrame(frame,#buffs,#debuffs,preview)
    self:RenderAuraSlots(frame.epcBuffSlots,buffs,#buffs,C.green)
    self:RenderAuraSlots(frame.epcDebuffSlots,debuffs,#debuffs,C.red)
end

function F:RefreshPlayerAuras(preview)
    self:RefreshIntegratedAuras(self.playerFrame,"player",preview==true)
end

function F:RefreshTargetAuras(preview)
    self:RefreshIntegratedAuras(self.targetFrame,"reticleover",preview==true)
end

function F:IsCombatStatsContextActive()
    if self.layoutMode == true then return true end
    return not EPC.OverlayModeAllows or EPC:OverlayModeAllows("combatStatsVisibility")
end

function F:RefreshPlayer()
    if not self.playerFrame or not EPC.saved then return end
    local show=(EPC.saved.showPlayerFrame ~= false or self.layoutMode == true) and not self:IsHudSuppressed()
    if not self.layoutMode and EPC.OverlayModeAllows then show=show and EPC:OverlayModeAllows("playerFrameVisibility") end
    self.playerFrame:SetHidden(not show)
    if not show then return end
    self:UpdateUnitFrame(self.playerFrame,"player",self.layoutMode)
    self:RefreshPlayerAuras(self.layoutMode)
end

function F:RefreshTarget(refreshAuras)
    if not self.targetFrame or not EPC.saved then return end
    local exists=safe(DoesUnitExist,false,"reticleover") == true
    local show=(EPC.saved.showTargetFrame ~= false and exists and not self:IsHudSuppressed())
    if self.layoutMode then show=true end
    if not self.layoutMode and EPC.OverlayModeAllows then show=show and EPC:OverlayModeAllows("targetFrameVisibility") end
    self.targetFrame:SetHidden(not show)
    if not show then return end
    self:UpdateUnitFrame(self.targetFrame,"reticleover",self.layoutMode)
    if refreshAuras ~= false then self:RefreshTargetAuras(self.layoutMode) end
end

local EPC_v020_RefreshGroupFrames = F.RefreshGroupFrames
function F:RefreshGroupFrames()
    EPC_v020_RefreshGroupFrames(self)
    if not self.layoutMode and EPC.OverlayModeAllows then
        if self.groupFrame and not EPC:OverlayModeAllows("groupFrameVisibility") then self.groupFrame:SetHidden(true) end
        if self.raidFrame and not EPC:OverlayModeAllows("raidFrameVisibility") then self.raidFrame:SetHidden(true) end
    end
end

function F:RefreshContextVisibility()
    -- Combat-mode visibility is event-driven in v0.20.0. Resource, target, group,
    -- and stats updates already have their own ESO events/timers, so the legacy
    -- 100 ms visibility poll intentionally does no expensive frame rebuilding.
end

function F:ApplyScalesAndAlpha()
    if not EPC.saved then return end
    local legacy=tonumber(EPC.saved.unitFrameScale) or 1.0
    local playerScale=tonumber(EPC.saved.playerFrameScale) or legacy
    local targetScale=tonumber(EPC.saved.targetFrameScale) or legacy
    local groupScale=tonumber(EPC.saved.groupFrameScale) or 1.0
    local statsScale=tonumber(EPC.saved.combatStatsScale) or 1.0
    local alpha=tonumber(EPC.saved.unitFrameAlpha) or 0.94
    if self.playerFrame then self.playerFrame:SetScale(playerScale) self.playerFrame:SetAlpha(alpha) end
    if self.targetFrame then self.targetFrame:SetScale(targetScale) self.targetFrame:SetAlpha(alpha) end
    if self.groupFrame then self.groupFrame:SetScale(groupScale) self.groupFrame:SetAlpha(alpha) end
    if self.raidFrame then self.raidFrame:SetScale(groupScale) self.raidFrame:SetAlpha(alpha) end
    if self.statsFrame then self.statsFrame:SetScale(statsScale) self.statsFrame:SetAlpha(alpha) end
    self:ApplyVisualStyle()
end

function F:SetLayoutMode(active)
    self.layoutMode=active==true
    self:ApplyLayoutState(self.playerFrame)
    self:ApplyLayoutState(self.targetFrame)
    self:ApplyLayoutState(self.groupFrame)
    self:ApplyLayoutState(self.raidFrame)
    self:ApplyLayoutState(self.statsFrame)
    self:ApplyVisualStyle()
    self:RefreshAll(true)
end

local EPC_v020_RegisterEvents = F.RegisterEvents
function F:RegisterEvents()
    EPC_v020_RegisterEvents(self)
    local prefix=EPC.name .. "_IntegratedFrames"
    if EVENT_PLAYER_COMBAT_STATE then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_CombatVisibility",EVENT_PLAYER_COMBAT_STATE,function() self:RefreshAll(true) end)
    end
    EVENT_MANAGER:RegisterForUpdate(prefix .. "_AuraTick",900,function()
        if self.playerFrame and not self.playerFrame:IsHidden() then self:RefreshPlayerAuras(self.layoutMode) end
        if self.targetFrame and not self.targetFrame:IsHidden() then self:RefreshTargetAuras(self.layoutMode) end
    end)
end

function F:Initialize()
    self.layoutMode=false
    self.lastHudSuppressed=nil
    self.playerEffectsFrame=nil -- effects are integrated into the Player frame in v0.20.0
    self.playerFrame=self:CreateUnitFrame("EPC_PlayerFrame","player",420,150,true)
    self.targetFrame=self:CreateUnitFrame("EPC_TargetFrame","target",420,150,true)
    self.groupFrame=self:CreateGroupFrame()
    self.raidFrame=self:CreateRaidFrame()
    self.statsFrame=self:CreateStatsFrame()
    self:RegisterEvents()
    self:ApplyScalesAndAlpha()
    self:RefreshAll(true)
end

-- ============================================================================
-- v0.21.0 unit-frame refinements.
-- Player: resources/effects only (no name/level text).
-- Target: Health only, with target identity above it.
-- Buffs stay above Health; debuffs stay below Health. When no debuffs exist,
-- no empty debuff gap is reserved and lower player resources sit normally.
-- Group companions render as a second mini player-style line with Level + Health.
-- ============================================================================

function F:CreateUnitFrame(name, kind, width, height, includeAuras)
    local frame = self:CreateShell(name, kind, width, height)
    frame.epcNoPanel = true
    if frame.epcShadow then frame.epcShadow:SetHidden(true) end
    if frame.epcBackground then frame.epcBackground:SetHidden(true) end
    if frame.epcAccent then frame.epcAccent:SetHidden(true) end

    local title = makeLabel(frame, name .. "_Name", "ZoFontWinH4", C.white, TEXT_ALIGN_CENTER)
    title:SetAnchor(TOPLEFT, frame, TOPLEFT, 12, 0)
    title:SetDimensions(width - 24, 22)
    local info = makeLabel(frame, name .. "_Info", "ZoFontGameSmall", C.muted, TEXT_ALIGN_CENTER)
    info:SetAnchor(TOPLEFT, frame, TOPLEFT, 12, 20)
    info:SetDimensions(width - 24, 18)

    local barWidth = width - 24
    local health = createESOResourceBar(frame, name .. "_Health", barWidth, C.health)
    local magicka = createESOResourceBar(frame, name .. "_Magicka", barWidth, C.magicka)
    local stamina = createESOResourceBar(frame, name .. "_Stamina", barWidth, C.stamina)

    frame.epcTitle, frame.epcInfo = title, info
    frame.epcCompanionInfo = false
    frame.epcBars = {health=health, magicka=magicka, stamina=stamina}
    frame.epcBuffSlots, frame.epcDebuffSlots = {}, {}
    frame.epcAuraSlotSize, frame.epcAuraSlotStep = 30, 33
    frame.epcAuraFactory = function(prefix, index, edgeColor)
        return createIntegratedAuraSlot(frame, name, prefix, index, edgeColor)
    end
    for i=1,6 do
        frame.epcBuffSlots[i] = frame.epcAuraFactory("Buff", i, C.green)
        frame.epcDebuffSlots[i] = frame.epcAuraFactory("Debuff", i, C.red)
    end

    if kind == "player" then
        title:SetHidden(true)
        info:SetHidden(true)
    elseif kind == "target" then
        magicka:SetHidden(true)
        stamina:SetHidden(true)
    end
    return frame
end

function F:LayoutIntegratedUnitFrame(frame, buffCount, debuffCount, preview)
    if not frame then return end
    local width = frame:GetWidth()
    local step = tonumber(frame.epcAuraSlotStep) or 31
    local pad = 12
    local perRow = math.max(1, math.floor((width - pad*2) / step))
    local isPlayer = frame.epcKind == "player"
    local isTarget = frame.epcKind == "target"
    local top = isPlayer and 0 or 39

    local displayBuffs = tonumber(buffCount) or 0
    local displayDebuffs = tonumber(debuffCount) or 0
    if preview then
        displayBuffs = math.max(displayBuffs, 4)
        displayDebuffs = math.max(displayDebuffs, 3)
    end

    local function position(slots, displayCount, startY)
        for i=1,#slots do
            local slot = slots[i]
            slot:ClearAnchors()
            local row = math.floor((i-1)/perRow)
            local col = (i-1)%perRow
            slot:SetAnchor(TOPLEFT, frame, TOPLEFT, pad + col*step, startY + row*step)
        end
        return displayCount > 0 and math.ceil(displayCount/perRow) or 0
    end

    -- Buffs live directly above the Health bar. With no buffs the Health bar
    -- returns to its normal base position instead of reserving empty icon rows.
    local buffRows = position(frame.epcBuffSlots, displayBuffs, top)
    local healthY = top + (buffRows * step) + (buffRows > 0 and 4 or 0)
    frame.epcBars.health:ClearAnchors()
    frame.epcBars.health:SetAnchor(TOPLEFT, frame, TOPLEFT, pad, healthY)

    -- Debuffs live directly below Health. Crucially, when there are zero debuffs
    -- the player resources continue immediately under Health with no dead space.
    local healthBottom = healthY + 23
    local debuffRows = 0
    if displayDebuffs > 0 then
        local debuffY = healthBottom + 4
        debuffRows = position(frame.epcDebuffSlots, displayDebuffs, debuffY)
        healthBottom = debuffY + (debuffRows * step)
    else
        -- Re-anchor hidden debuff controls harmlessly without creating layout space.
        position(frame.epcDebuffSlots, 0, healthBottom)
    end

    if isTarget then
        frame.epcBars.magicka:SetHidden(true)
        frame.epcBars.stamina:SetHidden(true)
        frame:SetHeight(healthBottom + (debuffRows > 0 and 2 or 0))
        return
    end

    frame.epcBars.magicka:SetHidden(false)
    frame.epcBars.stamina:SetHidden(false)
    local magY = healthBottom + (debuffRows > 0 and 4 or 3)
    frame.epcBars.magicka:ClearAnchors()
    frame.epcBars.magicka:SetAnchor(TOPLEFT, frame, TOPLEFT, pad, magY)
    frame.epcBars.stamina:ClearAnchors()
    frame.epcBars.stamina:SetAnchor(TOPLEFT, frame, TOPLEFT, pad, magY + 26)
    frame:SetHeight(magY + 49)
end

function F:UpdateUnitFrame(frame, unitTag, preview)
    if not frame then return false end
    local exists = preview == true or safe(DoesUnitExist, false, unitTag) == true
    if not exists then return false end

    local isPlayer = frame.epcKind == "player"
    local isTarget = frame.epcKind == "target"
    local name, info = self:GetUnitMeta(unitTag)
    if preview and safe(DoesUnitExist, false, unitTag) ~= true then
        name = isTarget and "TARGET PREVIEW" or ""
        info = isTarget and "LAYOUT MODE" or ""
    end

    if isPlayer then
        frame.epcTitle:SetHidden(true)
        frame.epcInfo:SetHidden(true)
    else
        frame.epcTitle:SetHidden(false)
        frame.epcInfo:SetHidden(false)
        frame.epcTitle:SetText(name)
        frame.epcInfo:SetText(info)
    end

    local hp,hpMax = readPower(unitTag, POWER_HEALTH)
    if preview and hpMax <= 0 then hp,hpMax = 76000,100000 end
    updateESOResourceBar(frame.epcBars.health, hp, hpMax)

    if not isTarget then
        local mag,magMax = readPower(unitTag, POWER_MAGICKA)
        local stam,stamMax = readPower(unitTag, POWER_STAMINA)
        if preview then
            if magMax <= 0 then mag,magMax = 28000,40000 end
            if stamMax <= 0 then stam,stamMax = 21000,30000 end
        end
        updateESOResourceBar(frame.epcBars.magicka, mag, magMax)
        updateESOResourceBar(frame.epcBars.stamina, stam, stamMax)
    end
    return true
end

-- Compact group rows: player and companion information stay readable without
-- turning each member into a large rectangular card.
function F:CreateMemberRow(parent, name, width, height, x, y, showCompanion)
    local row = makeBackdrop(parent, name, C.panel, C.edgeSoft)
    row:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    row:SetDimensions(width, height)

    local accent = wm:CreateControl(name .. "_Accent", row, CT_BACKDROP)
    accent:SetAnchor(TOPLEFT, row, TOPLEFT, 0, 0)
    accent:SetAnchor(BOTTOMLEFT, row, BOTTOMLEFT, 0, 0)
    accent:SetWidth(3)
    accent:SetCenterColor(unpack(C.muted))
    accent:SetEdgeColor(0,0,0,0)

    local label = makeLabel(row, name .. "_Name", "ZoFontGameSmall", C.white)
    label:SetAnchor(TOPLEFT, row, TOPLEFT, 7, 1)
    label:SetDimensions(width - 132, 16)

    local meta = makeLabel(row, name .. "_Meta", "ZoFontGameSmall", C.gold, TEXT_ALIGN_RIGHT)
    meta:SetAnchor(TOPRIGHT, row, TOPRIGHT, -6, 1)
    meta:SetDimensions(118, 16)

    local health = createFillBar(row, name .. "_Health", 7, 18, width - 14, 13, C.health, "", "PERCENT")

    local companion, companionMeta, companionHealth, divider = nil, nil, nil, nil
    if showCompanion then
        divider = wm:CreateControl(name .. "_CompanionDivider", row, CT_BACKDROP)
        divider:SetAnchor(TOPLEFT, row, TOPLEFT, 7, 34)
        divider:SetDimensions(width - 14, 1)
        divider:SetCenterColor(0.50,0.42,0.28,0.30)
        divider:SetEdgeColor(0,0,0,0)
        divider:SetHidden(true)

        companion = makeLabel(row, name .. "_Companion", "ZoFontGameSmall", C.white)
        companion:SetAnchor(TOPLEFT, row, TOPLEFT, 7, 37)
        companion:SetDimensions(width - 104, 14)
        companion:SetHidden(true)

        companionMeta = makeLabel(row, name .. "_CompanionMeta", "ZoFontGameSmall", C.gold, TEXT_ALIGN_RIGHT)
        companionMeta:SetAnchor(TOPRIGHT, row, TOPRIGHT, -6, 37)
        companionMeta:SetDimensions(94, 14)
        companionMeta:SetHidden(true)

        companionHealth = createFillBar(row, name .. "_CompanionHealth", 7, 52, width - 14, 11, C.health, "", "PERCENT")
        companionHealth:SetHidden(true)
    end

    row.epcIsMemberRow = true
    row.epcName = label
    row.epcMeta = meta
    row.epcRole = meta
    row.epcCompanion = companion or false
    row.epcCompanionMeta = companionMeta or false
    row.epcCompanionHealth = companionHealth or false
    row.epcCompanionDivider = divider or false
    row.epcShowCompanion = showCompanion == true
    row.epcAccent = accent
    row.epcBars = {health = health}
    row.epcUnitTag = nil
    return row
end

function F:CreateGroupFrame()
    local frame = self:CreateShell("EPC_GroupFrame", "group", 306, 320)
    local title = makeLabel(frame, "EPC_GroupFrame_Title", "ZoFontGameBold", C.gold)
    title:SetAnchor(TOPLEFT, frame, TOPLEFT, 10, 5)
    title:SetDimensions(108, 20)
    title:SetText("")
    local status = makeLabel(frame, "EPC_GroupFrame_Status", "ZoFontGameSmall", C.muted, TEXT_ALIGN_RIGHT)
    status:SetAnchor(TOPRIGHT, frame, TOPRIGHT, -9, 5)
    status:SetDimensions(158,20)
    frame.epcTitle, frame.epcStatus, frame.epcRows = title, status, {}
    for i=1,4 do
        frame.epcRows[i] = self:CreateMemberRow(frame, "EPC_GroupMember" .. tostring(i), 282, 67, 12, 29 + ((i-1)*71), true)
    end
    return frame
end

local EPC_v021_ResizeGroupContainers = F.ResizeGroupContainers
function F:ResizeGroupContainers(size, layout)
    if self.groupFrame then
        local visibleRows = layout and 4 or math.max(1, math.min(4, tonumber(size) or 0))
        local top, rowHeight, step, bottomPad = 29, 67, 71, 8
        self.groupFrame:SetHeight(top + ((visibleRows - 1)*step) + rowHeight + bottomPad)
    end
    -- Preserve the mature raid sizing/anchoring logic from the previous build.
    if self.raidFrame then
        local visibleCount = layout and math.min(self.maxGroupSize or 12, 12) or math.max(1, tonumber(size) or 0)
        local columns = visibleCount > 12 and 3 or 2
        if visibleCount <= 4 then columns = 2 end
        local rowsPerColumn = math.max(1, math.ceil(visibleCount / columns))
        local width = 20 + (columns * 250) + ((columns - 1) * 8)
        local height = 38 + (rowsPerColumn * 54)
        self.raidFrame:SetDimensions(width, height)
        for i=1,#self.raidFrame.epcRows do
            local row = self.raidFrame.epcRows[i]
            if row then
                row:ClearAnchors()
                local column = math.floor((i-1)/rowsPerColumn)
                local rowIndex = (i-1)%rowsPerColumn
                row:SetAnchor(TOPLEFT, self.raidFrame, TOPLEFT, 12 + (column*258), 32 + (rowIndex*54))
            end
        end
    end
end

function F:UpdateMemberRow(row, unitTag, previewIndex)
    if not row then return end
    local preview = previewIndex ~= nil
    local exists = preview or (unitTag and safe(DoesUnitExist, false, unitTag) == true)
    row:SetHidden(not exists)
    if not exists then row.epcUnitTag = nil return end

    row.epcUnitTag = unitTag
    local name = preview and ("Member " .. tostring(previewIndex)) or cleanName(safe(GetUnitName, "", unitTag))
    if name == "" then name = unitTag or "Member" end
    local isLeader = not preview and unitTag ~= "player" and safe(IsUnitGroupLeader, false, unitTag) == true
    local isDead = not preview and safe(IsUnitDead, false, unitTag) == true
    local isOnline = preview or unitTag == "player" or safe(IsUnitOnline, true, unitTag) ~= false
    local inRange = preview or unitTag == "player" or safe(IsUnitInGroupSupportRange, true, unitTag) ~= false
    local localPlayer = unitTag == "player"
    if not preview and not localPlayer and type(AreUnitsEqual) == "function" then localPlayer = safe(AreUnitsEqual, false, unitTag, "player") == true end
    if not preview and not localPlayer and type(GetLocalPlayerGroupUnitTag) == "function" then localPlayer = safe(GetLocalPlayerGroupUnitTag, "") == unitTag end

    row.epcName:SetText((isLeader and "[L] " or "") .. name)
    local roleText, roleColor = preview and "DPS" or self:RoleText(unitTag)
    local levelText = preview and ("LV " .. tostring(40 + previewIndex)) or self:GetLevelText(unitTag)
    local statusText = ""
    if isDead then statusText, roleColor = "DEAD", C.red
    elseif not isOnline then statusText, roleColor = "OFF", C.muted
    elseif not inRange then statusText, roleColor = "RANGE", C.muted
    elseif not row.epcShowCompanion then statusText = roleText or "" end
    if levelText ~= "" and statusText ~= "" then levelText = levelText .. " | " .. statusText
    elseif statusText ~= "" then levelText = statusText end
    row.epcMeta:SetText(levelText)
    row.epcMeta:SetColor(unpack(roleColor or C.gold))

    if localPlayer then row.epcAccent:SetCenterColor(unpack(C.gold))
    elseif isLeader then row.epcAccent:SetCenterColor(unpack(C.blue))
    elseif roleText == "HEAL" then row.epcAccent:SetCenterColor(unpack(C.green))
    elseif roleText == "TANK" then row.epcAccent:SetCenterColor(unpack(C.orange))
    else row.epcAccent:SetCenterColor(unpack(C.muted)) end

    if row.epcShowCompanion and row.epcCompanion and row.epcCompanionMeta then
        local companionTag, companionName, companionLevel
        if preview then
            companionTag, companionName, companionLevel = "previewcompanion", "Companion", "LV 20"
        else
            companionTag, companionName, companionLevel = self:GetCompanionForMember(unitTag)
        end
        local hasCompanion = companionName ~= nil
        row.epcCompanion:SetHidden(not hasCompanion)
        row.epcCompanionMeta:SetHidden(not hasCompanion)
        if row.epcCompanionHealth then row.epcCompanionHealth:SetHidden(not hasCompanion) end
        if row.epcCompanionDivider then row.epcCompanionDivider:SetHidden(not hasCompanion) end
        if hasCompanion then
            row.epcCompanion:SetText(companionName)
            row.epcCompanionMeta:SetText(companionLevel or "")
            row.epcCompanionMeta:SetColor(unpack(C.gold))
            local chp,chpMax = readPower(companionTag, POWER_HEALTH)
            if preview and chpMax <= 0 then chp,chpMax = 16500,22000 end
            updateFillBar(row.epcCompanionHealth, chp, chpMax, "")
        end
    end

    local hp,hpMax = readPower(unitTag, POWER_HEALTH)
    if preview then hp,hpMax = 78000 - (previewIndex*2200),100000 end
    updateFillBar(row.epcBars.health,hp,hpMax,"")
end

-- v0.21.2: companions are truly conditional in the Group frame.
-- When no companion unit exists, the companion controls are hidden AND the
-- member row collapses back to player-only height so no empty companion area
-- is reserved. Layout preview follows the same rule.
local EPC_v0211_UpdateMemberRow = F.UpdateMemberRow
function F:UpdateMemberRow(row, unitTag, previewIndex)
    EPC_v0211_UpdateMemberRow(self, row, unitTag, previewIndex)
    if not row or row:IsHidden() then return end

    local hasCompanion = false
    if row.epcShowCompanion then
        if previewIndex ~= nil then
            -- Preview a companion only when the player actually has an active
            -- companion, and only on the first preview row.
            hasCompanion = previewIndex == 1 and safe(DoesUnitExist, false, "companion") == true
        elseif unitTag then
            local companionTag, companionName = self:GetCompanionForMember(unitTag)
            hasCompanion = companionTag ~= nil and companionName ~= nil
        end
    end

    row.epcHasCompanion = hasCompanion
    if row.epcCompanion then row.epcCompanion:SetHidden(not hasCompanion) end
    if row.epcCompanionMeta then row.epcCompanionMeta:SetHidden(not hasCompanion) end
    if row.epcCompanionHealth then row.epcCompanionHealth:SetHidden(not hasCompanion) end
    if row.epcCompanionDivider then row.epcCompanionDivider:SetHidden(not hasCompanion) end

    -- 34px = player name/meta + Health only. 67px adds the companion line.
    row:SetHeight(hasCompanion and 67 or 34)
end

local EPC_v0211_RefreshGroupFrames = F.RefreshGroupFrames
function F:RefreshGroupFrames()
    EPC_v0211_RefreshGroupFrames(self)
    if not self.groupFrame then return end

    -- Reflow only visible small-group rows after their companion state has
    -- determined the actual row height. This removes every empty companion gap.
    local y = 29
    local visibleRows = 0
    for i = 1, #self.groupFrame.epcRows do
        local row = self.groupFrame.epcRows[i]
        if row and not row:IsHidden() then
            row:ClearAnchors()
            row:SetAnchor(TOPLEFT, self.groupFrame, TOPLEFT, 12, y)
            y = y + row:GetHeight() + 4
            visibleRows = visibleRows + 1
        end
    end

    if visibleRows > 0 then
        self.groupFrame:SetHeight(y + 4)
    end
end



-- v0.22.0: make companion detection reliable for the local player's group tag,
-- and show the Group frame for a solo player with an active companion.
local EPC_v0220_GetCompanionForMember = F.GetCompanionForMember
function F:GetCompanionForMember(unitTag)
    local isLocalPlayer = unitTag == "player"
    if unitTag and not isLocalPlayer and type(AreUnitsEqual) == "function" then
        isLocalPlayer = safe(AreUnitsEqual, false, unitTag, "player") == true
    end
    if unitTag and not isLocalPlayer and type(GetLocalPlayerGroupUnitTag) == "function" then
        local localGroupTag = safe(GetLocalPlayerGroupUnitTag, "")
        isLocalPlayer = localGroupTag ~= "" and localGroupTag == unitTag
    end

    if isLocalPlayer and safe(DoesUnitExist, false, "companion") == true then
        local companionTag = "companion"
        local companionName = cleanName(safe(GetUnitName, "", companionTag))
        local companionLevel = safeNumber(GetUnitLevel, 0, companionTag)
        local activeId = safeNumber(GetActiveCompanionDefId, 0)
        if companionName == "" and activeId > 0 and type(GetCompanionName) == "function" then
            companionName = cleanName(safe(GetCompanionName, "", activeId))
        end
        if type(GetActiveCompanionLevelInfo) == "function" then
            local activeLevel = safeNumber(GetActiveCompanionLevelInfo, 0)
            if activeLevel > 0 then companionLevel = activeLevel end
        end
        if companionName == "" then companionName = "Companion" end
        local levelText = companionLevel > 0 and ("LV " .. tostring(companionLevel)) or ""
        return companionTag, companionName, levelText
    end

    return EPC_v0220_GetCompanionForMember(self, unitTag)
end

local EPC_v0220_GetGroupUnitTags = F.GetGroupUnitTags
function F:GetGroupUnitTags()
    local tags = EPC_v0220_GetGroupUnitTags(self)
    local hasActiveCompanion = safe(DoesUnitExist, false, "companion") == true
    if #tags == 0 and hasActiveCompanion then
        return {"player"}, true
    end
    return tags, false
end

local EPC_v0220_RefreshGroupFrames = F.RefreshGroupFrames
function F:RefreshGroupFrames()
    EPC_v0220_RefreshGroupFrames(self)
    if not self.groupFrame or not EPC.saved then return end

    local tags, soloCompanion = self:GetGroupUnitTags()
    if not soloCompanion then return end
    if self:IsHudSuppressed() and not self.layoutMode then return end

    local show = self.layoutMode == true or EPC.saved.showGroupFrame ~= false
    if not self.layoutMode and EPC.OverlayModeAllows then
        show = show and EPC:OverlayModeAllows("groupFrameVisibility")
    end
    self.groupFrame:SetHidden(not show)
    if not show then return end

    self.groupFrame.epcStatus:SetText("")
    self:UpdateMemberRow(self.groupFrame.epcRows[1], "player", nil)
    for i = 2, #self.groupFrame.epcRows do
        self.groupFrame.epcRows[i]:SetHidden(true)
    end

    local row = self.groupFrame.epcRows[1]
    row:ClearAnchors()
    row:SetAnchor(TOPLEFT, self.groupFrame, TOPLEFT, 12, 29)
    self.groupFrame:SetHeight(29 + row:GetHeight() + 8)
end


-- ============================================================================
-- v0.22.1 HUD polish.
-- * Player/Target native resource fills now run underneath the decorative end
--   caps, eliminating the empty side gutters at full Health/Magicka/Stamina.
-- * Group/Raid member rows use the same ESO attribute-bar art instead of plain
--   rectangular fill bars while retaining compact roster sizing.
-- ============================================================================

-- Rebuild the main resource bar so the colored track/fill extends beneath both
-- native frame caps. The frame art remains on top, so the bar keeps its ESO look
-- while a 100% resource genuinely reads as full from end to end.
--

-- v0.22.4: removed the rectangular color-track backdrops from ESO-style
-- resource bars. Native attribute-bar background art now provides the underlay
-- for Player/Target/Group/Raid/Companion bars so fill, empty track, and frame
-- share one visual silhouette.
-- v0.22.2: explicitly layer the native frame above the StatusBar. In v0.22.1
-- the fill extended correctly, but ESO could draw the StatusBar/leading-edge over
-- the left frame art. Keeping the fill underneath the frame preserves a visually
-- full bar without painting over the decorative end cap.
local function EPC_SetBarDrawOrder(track, bg, fill, gloss, left, right, center, label)
    if track and track.SetDrawLayer then
        track:SetDrawLayer(DL_BACKGROUND)
        track:SetDrawLevel(1)
    end
    if bg and bg.SetDrawLayer then
        bg:SetDrawLayer(DL_BACKGROUND)
        bg:SetDrawLevel(2)
    end
    if fill and fill.SetDrawLayer then
        fill:SetDrawLayer(DL_CONTROLS)
        fill:SetDrawLevel(10)
    end
    if gloss and gloss.SetDrawLayer then
        gloss:SetDrawLayer(DL_CONTROLS)
        gloss:SetDrawLevel(20)
    end
    for _, framePiece in ipairs({left, right, center}) do
        if framePiece and framePiece.SetDrawLayer then
            if framePiece.SetDrawTier then framePiece:SetDrawTier(DT_HIGH) end
            framePiece:SetDrawLayer(DL_OVERLAY)
            framePiece:SetDrawLevel(100)
        end
    end
    if label and label.SetDrawLayer then
        if label.SetDrawTier then label:SetDrawTier(DT_HIGH) end
        label:SetDrawLayer(DL_OVERLAY)
        label:SetDrawLevel(200)
    end
end

-- v0.22.5: build the bars from the same native ESO pieces used by the
-- keyboard attribute bars.  Background and frame use matching left/center/right
-- slices, while the native status-bar fill sits between them.  This avoids a
-- rectangular track showing behind a sculpted frame and keeps the fill inside
-- the same silhouette.
local function EPC_CreateESOShapedBar(parent, name, width, height, color, textMode)
    local bar = wm:CreateControl(name, parent, CT_CONTROL)
    height = tonumber(height) or 23
    bar:SetDimensions(width, height)

    local statusHeight = math.max(8, math.floor(height * (17 / 23) + 0.5))
    local capWidth = math.max(7, math.floor(height * (13 / 23) + 0.5))

    -- Native ESO empty-bar silhouette: separate left cap, center, right cap.
    local bgLeft = wm:CreateControl(name .. "_BgLeft", bar, CT_TEXTURE)
    bgLeft:SetDimensions(capWidth, height)
    bgLeft:SetAnchor(LEFT, bar, LEFT, 0, 0)
    bgLeft:SetTexture(EPC_NATIVE_BG_TEX)
    bgLeft:SetTextureCoords(0.3671875, 0.46875, 0.328125, 0.6875)

    local bgRight = wm:CreateControl(name .. "_BgRight", bar, CT_TEXTURE)
    bgRight:SetDimensions(capWidth, height)
    bgRight:SetAnchor(RIGHT, bar, RIGHT, 0, 0)
    bgRight:SetTexture(EPC_NATIVE_BG_TEX)
    bgRight:SetTextureCoords(0.46875, 0.3671875, 0.328125, 0.6875)

    local bgCenter = wm:CreateControl(name .. "_BgCenter", bar, CT_TEXTURE)
    bgCenter:SetAnchor(TOPLEFT, bgLeft, TOPRIGHT, 0, 0)
    bgCenter:SetAnchor(BOTTOMRIGHT, bgRight, BOTTOMLEFT, 0, 0)
    bgCenter:SetTexture(EPC_NATIVE_BG_TEX)
    bgCenter:SetTextureCoords(0.4921875, 0.5546875, 0.328125, 0.6875)

    -- The actual resource uses ESO's native shaped fill texture.  Anchor it
    -- across the same span as the frame; the texture alpha + cap art defines
    -- the silhouette instead of a rectangular backdrop.
    local fill = wm:CreateControlFromVirtual(name .. "_NativeFill", bar, "ZO_PlayerAttributeStatusBar_Keyboard_Template")
    fill:ClearAnchors()
    fill:SetAnchor(LEFT, bar, LEFT, 0, 0)
    fill:SetAnchor(RIGHT, bar, RIGHT, 0, 0)
    fill:SetHeight(statusHeight)
    fill:SetMinMax(0, 1)
    fill:SetValue(0)
    fill:SetColor(unpack(color))

    local gloss = wm:CreateControlFromVirtual(name .. "_Gloss", bar, "ZO_PlayerAttributeStatusBarGloss_Keyboard_Template")
    gloss:ClearAnchors()
    gloss:SetAnchor(LEFT, bar, LEFT, 0, 0)
    gloss:SetAnchor(RIGHT, bar, RIGHT, 0, 0)
    gloss:SetHeight(statusHeight)
    gloss:SetMinMax(0, 1)
    gloss:SetValue(0)
    gloss:SetColor(1, 1, 1, 0.42)

    -- Native ESO frame silhouette, using the exact same geometry as the BG.
    local left = wm:CreateControl(name .. "_FrameLeft", bar, CT_TEXTURE)
    left:SetDimensions(capWidth, height)
    left:SetAnchor(LEFT, bar, LEFT, 0, 0)
    left:SetTexture(EPC_NATIVE_FRAME_TEX)
    left:SetTextureCoords(0.3671875, 0.46875, 0.328125, 0.6875)

    local right = wm:CreateControl(name .. "_FrameRight", bar, CT_TEXTURE)
    right:SetDimensions(capWidth, height)
    right:SetAnchor(RIGHT, bar, RIGHT, 0, 0)
    right:SetTexture(EPC_NATIVE_FRAME_TEX)
    right:SetTextureCoords(0.46875, 0.3671875, 0.328125, 0.6875)

    local center = wm:CreateControl(name .. "_FrameCenter", bar, CT_TEXTURE)
    center:SetAnchor(TOPLEFT, left, TOPRIGHT, 0, 0)
    center:SetAnchor(BOTTOMRIGHT, right, BOTTOMLEFT, 0, 0)
    center:SetTexture(EPC_NATIVE_FRAME_TEX)
    center:SetTextureCoords(0.4921875, 0.5546875, 0.328125, 0.6875)

    local label = makeLabel(bar, name .. "_Value", "ZoFontGameSmall", C.white, TEXT_ALIGN_CENTER)
    label:SetAnchorFill(bar)

    -- Explicit ESO-like draw order: background -> fill -> gloss -> frame -> text.
    for _, c in ipairs({bgLeft, bgCenter, bgRight}) do
        if c.SetDrawTier then c:SetDrawTier(DT_LOW) end
        if c.SetDrawLayer then c:SetDrawLayer(DL_CONTROLS) end
        if c.SetDrawLevel then c:SetDrawLevel(5) end
    end
    for _, c in ipairs({fill, gloss}) do
        if c.SetDrawTier then c:SetDrawTier(DT_MEDIUM) end
        if c.SetDrawLayer then c:SetDrawLayer(DL_CONTROLS) end
    end
    if fill.SetDrawLevel then fill:SetDrawLevel(20) end
    if gloss.SetDrawLevel then gloss:SetDrawLevel(25) end
    for _, c in ipairs({left, center, right}) do
        if c.SetDrawTier then c:SetDrawTier(DT_HIGH) end
        if c.SetDrawLayer then c:SetDrawLayer(DL_OVERLAY) end
        if c.SetDrawLevel then c:SetDrawLevel(100) end
    end
    if label.SetDrawTier then label:SetDrawTier(DT_HIGH) end
    if label.SetDrawLayer then label:SetDrawLayer(DL_OVERLAY) end
    if label.SetDrawLevel then label:SetDrawLevel(200) end

    bar.epcNative = true
    bar.epcFill = fill
    bar.epcGloss = gloss
    bar.epcLabel = label
    bar.epcTextMode = textMode or "FULL"
    return bar
end

createESOResourceBar = function(parent, name, width, color)
    return EPC_CreateESOShapedBar(parent, name, width, 23, color, "FULL")
end

updateESOResourceBar = function(bar, current, maximum)
    if not bar then return end
    current, maximum = tonumber(current) or 0, tonumber(maximum) or 0
    if maximum <= 0 then
        bar.epcFill:SetMinMax(0, 1)
        bar.epcFill:SetValue(0)
        if bar.epcGloss then bar.epcGloss:SetMinMax(0, 1) bar.epcGloss:SetValue(0) end
        if bar.epcLabel then bar.epcLabel:SetText("--") end
        return
    end

    local value = math.max(0, math.min(current, maximum))
    bar.epcFill:SetMinMax(0, maximum)
    bar.epcFill:SetValue(value)
    if bar.epcGloss then bar.epcGloss:SetMinMax(0, maximum) bar.epcGloss:SetValue(value) end

    if bar.epcLabel then
        if bar.epcTextMode == "PERCENT" then
            bar.epcLabel:SetText(percentText(current, maximum))
        elseif bar.epcTextMode == "NONE" then
            bar.epcLabel:SetText("")
        else
            bar.epcLabel:SetText(string.format("%s / %s  (%s)", compactNumber(current), compactNumber(maximum), percentText(current, maximum)))
        end
    end
end

local function createESOCompactHealthBar(parent, name, width, height)
    return EPC_CreateESOShapedBar(parent, name, width, height, C.health, "PERCENT")
end

-- Existing roster update code calls updateFillBar. Route native roster bars through
-- the ESO status-bar updater while preserving the legacy helper for other bars.
local EPC_v0221_UpdateFillBarLegacy = updateFillBar
updateFillBar = function(bar, current, maximum, prefix)
    if bar and bar.epcNative then
        updateESOResourceBar(bar, current, maximum)
        return
    end
    EPC_v0221_UpdateFillBarLegacy(bar, current, maximum, prefix)
end

function F:CreateMemberRow(parent, name, width, height, x, y, showCompanion)
    local row = makeBackdrop(parent, name, {0.012, 0.014, 0.018, 0.48}, {0.52, 0.41, 0.20, 0.28})
    row:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    row:SetDimensions(width, height)

    local accent = wm:CreateControl(name .. "_Accent", row, CT_BACKDROP)
    accent:SetAnchor(TOPLEFT, row, TOPLEFT, 1, 1)
    accent:SetAnchor(BOTTOMLEFT, row, BOTTOMLEFT, 1, -1)
    accent:SetWidth(2)
    accent:SetCenterColor(unpack(C.muted))
    accent:SetEdgeColor(0, 0, 0, 0)

    local label = makeLabel(row, name .. "_Name", "ZoFontGameSmall", C.white)
    label:SetAnchor(TOPLEFT, row, TOPLEFT, 7, 0)
    label:SetDimensions(width - 166, 15)

    local meta = makeLabel(row, name .. "_Meta", "ZoFontGameSmall", C.gold, TEXT_ALIGN_RIGHT)
    meta:SetAnchor(TOPRIGHT, row, TOPRIGHT, -6, 0)
    meta:SetDimensions(150, 15)

    local health = createESOCompactHealthBar(row, name .. "_Health", width - 12, 16)
    health:SetAnchor(TOPLEFT, row, TOPLEFT, 6, 14)

    local companion, companionMeta, companionHealth, divider = nil, nil, nil, nil
    if showCompanion then
        divider = wm:CreateControl(name .. "_CompanionDivider", row, CT_BACKDROP)
        divider:SetAnchor(TOPLEFT, row, TOPLEFT, 7, 32)
        divider:SetDimensions(width - 14, 1)
        divider:SetCenterColor(0.72, 0.57, 0.27, 0.35)
        divider:SetEdgeColor(0, 0, 0, 0)
        divider:SetHidden(true)

        companion = makeLabel(row, name .. "_Companion", "ZoFontGameSmall", C.white)
        companion:SetAnchor(TOPLEFT, row, TOPLEFT, 7, 34)
        companion:SetDimensions(width - 106, 13)
        companion:SetHidden(true)

        companionMeta = makeLabel(row, name .. "_CompanionMeta", "ZoFontGameSmall", C.gold, TEXT_ALIGN_RIGHT)
        companionMeta:SetAnchor(TOPRIGHT, row, TOPRIGHT, -6, 34)
        companionMeta:SetDimensions(96, 13)
        companionMeta:SetHidden(true)

        companionHealth = createESOCompactHealthBar(row, name .. "_CompanionHealth", width - 12, 14)
        companionHealth:SetAnchor(TOPLEFT, row, TOPLEFT, 6, 47)
        companionHealth:SetHidden(true)
    end

    row.epcIsMemberRow = true
    row.epcESOStyledMember = true
    row.epcCompactHeight = 32
    row.epcExpandedHeight = 63
    row.epcName = label
    row.epcMeta = meta
    row.epcRole = meta
    row.epcCompanion = companion or false
    row.epcCompanionMeta = companionMeta or false
    row.epcCompanionHealth = companionHealth or false
    row.epcCompanionDivider = divider or false
    row.epcShowCompanion = showCompanion == true
    row.epcAccent = accent
    row.epcBars = {health = health}
    row.epcUnitTag = nil
    return row
end

function F:CreateGroupFrame()
    -- v0.22.3: the Group frame intentionally has no GROUP/header row. Keep
    -- hidden compatibility controls because older refresh code writes to
    -- epcTitle/epcStatus, but do not reserve any visual space for them.
    local frame = self:CreateShell("EPC_GroupFrame", "group", 330, 169)
    frame.epcESOGroupStyle = true

    local title = makeLabel(frame, "EPC_GroupFrame_Title", "ZoFontGameBold", C.gold)
    title:SetDimensions(1, 1)
    title:SetHidden(true)
    title:SetText("")

    local status = makeLabel(frame, "EPC_GroupFrame_Status", "ZoFontGameSmall", C.muted, TEXT_ALIGN_RIGHT)
    status:SetDimensions(1, 1)
    status:SetHidden(true)
    status:SetText("")

    frame.epcTitle, frame.epcStatus, frame.epcRows = title, status, {}
    for i = 1, 4 do
        frame.epcRows[i] = self:CreateMemberRow(frame, "EPC_GroupMember" .. tostring(i), 306, 63, 12, 6 + ((i - 1) * 66), true)
    end
    return frame
end

function F:CreateRaidFrame()
    local maxSize = 12
    if type(GetGroupMaxSize) == "function" then
        local ok, value = pcall(GetGroupMaxSize)
        if ok and tonumber(value) then maxSize = math.max(12, math.min(24, tonumber(value))) end
    end
    self.maxGroupSize = maxSize

    local columns = maxSize > 12 and 3 or 2
    local rowsPerColumn = math.ceil(maxSize / columns)
    local rowWidth, rowHeight, gap = 270, 32, 7
    local width = 20 + (columns * rowWidth) + ((columns - 1) * gap)
    local height = 29 + (rowsPerColumn * (rowHeight + 3)) + 5

    local frame = self:CreateShell("EPC_RaidFrame", "raid", width, height)
    frame.epcESOGroupStyle = true

    local title = makeLabel(frame, "EPC_RaidFrame_Title", "ZoFontGameBold", C.gold)
    title:SetAnchor(TOPLEFT, frame, TOPLEFT, 10, 3)
    title:SetDimensions(100, 18)
    title:SetText("RAID")

    local status = makeLabel(frame, "EPC_RaidFrame_Status", "ZoFontGameSmall", C.muted, TEXT_ALIGN_RIGHT)
    status:SetAnchor(TOPRIGHT, frame, TOPRIGHT, -9, 3)
    status:SetDimensions(180, 18)

    local rule = wm:CreateControl("EPC_RaidFrame_ESORule", frame, CT_BACKDROP)
    rule:SetAnchor(TOPLEFT, frame, TOPLEFT, 10, 22)
    rule:SetAnchor(TOPRIGHT, frame, TOPRIGHT, -10, 22)
    rule:SetHeight(1)
    rule:SetCenterColor(0.72, 0.57, 0.27, 0.48)
    rule:SetEdgeColor(0, 0, 0, 0)

    frame.epcTitle, frame.epcStatus, frame.epcRows = title, status, {}
    for i = 1, maxSize do
        local column = math.floor((i - 1) / rowsPerColumn)
        local rowIndex = (i - 1) % rowsPerColumn
        frame.epcRows[i] = self:CreateMemberRow(frame, "EPC_RaidMember" .. tostring(i), rowWidth, rowHeight,
            10 + (column * (rowWidth + gap)), 27 + (rowIndex * (rowHeight + 3)), false)
    end
    return frame
end

local EPC_v0221_UpdateMemberRow = F.UpdateMemberRow
function F:UpdateMemberRow(row, unitTag, previewIndex)
    EPC_v0221_UpdateMemberRow(self, row, unitTag, previewIndex)
    if not row or row:IsHidden() or not row.epcESOStyledMember then return end
    local hasCompanion = row.epcHasCompanion == true
    row:SetHeight(hasCompanion and row.epcExpandedHeight or row.epcCompactHeight)
end

-- Use the compact native-bar measurements whenever the original roster refresh
-- asks the containers to resize/reflow.
function F:ResizeGroupContainers(size, layout)
    if self.groupFrame then
        local visibleRows = layout and 4 or math.max(1, math.min(4, tonumber(size) or 0))
        local top = 6
        -- No Group header is reserved in v0.22.3. Companion rows can still
        -- vary at runtime; the post-refresh reflow tightens this estimate.
        self.groupFrame:SetHeight(top + (visibleRows * 35) + 4)
    end

    if self.raidFrame then
        local visibleCount = layout and math.min(self.maxGroupSize or 12, 12) or math.max(1, tonumber(size) or 0)
        local columns = visibleCount > 12 and 3 or 2
        if visibleCount <= 4 then columns = 2 end
        local rowsPerColumn = math.max(1, math.ceil(visibleCount / columns))
        local rowWidth, rowHeight, gap = 270, 32, 7
        local width = 20 + (columns * rowWidth) + ((columns - 1) * gap)
        local height = 29 + (rowsPerColumn * (rowHeight + 3)) + 5
        self.raidFrame:SetDimensions(width, height)
        for i = 1, #self.raidFrame.epcRows do
            local row = self.raidFrame.epcRows[i]
            if row then
                row:ClearAnchors()
                local column = math.floor((i - 1) / rowsPerColumn)
                local rowIndex = (i - 1) % rowsPerColumn
                row:SetAnchor(TOPLEFT, self.raidFrame, TOPLEFT,
                    10 + (column * (rowWidth + gap)), 27 + (rowIndex * (rowHeight + 3)))
            end
        end
    end
end

-- The v0.21.2 group reflow used the older 29px header offset. Keep all member
-- rows tucked directly beneath the new ESO-style header/rule.
local EPC_v0221_RefreshGroupFrames = F.RefreshGroupFrames
function F:RefreshGroupFrames()
    EPC_v0221_RefreshGroupFrames(self)
    if not self.groupFrame or self.groupFrame:IsHidden() then return end

    local y = 6
    local visibleRows = 0
    for i = 1, #self.groupFrame.epcRows do
        local row = self.groupFrame.epcRows[i]
        if row and not row:IsHidden() then
            row:ClearAnchors()
            row:SetAnchor(TOPLEFT, self.groupFrame, TOPLEFT, 12, y)
            y = y + row:GetHeight() + 3
            visibleRows = visibleRows + 1
        end
    end
    if visibleRows > 0 then self.groupFrame:SetHeight(y + 4) end
end

local EPC_v0221_ApplyVisualStyle = F.ApplyVisualStyle
function F:ApplyVisualStyle()
    EPC_v0221_ApplyVisualStyle(self)
    local function apply(frame)
        if not frame or not frame.epcESOGroupStyle then return end
        if frame.epcBackground then
            frame.epcBackground:SetHidden(false)
            frame.epcBackground:SetCenterColor(0.010, 0.012, 0.016, self.layoutMode and 0.35 or 0.58)
            frame.epcBackground:SetEdgeColor(0.55, 0.43, 0.20, self.layoutMode and 0.85 or 0.48)
        end
        if frame.epcShadow then frame.epcShadow:SetHidden(not self.layoutMode) end
        if frame.epcAccent then frame.epcAccent:SetHidden(true) end
        for _, row in ipairs(frame.epcRows or {}) do
            row:SetCenterColor(0.012, 0.014, 0.018, self.layoutMode and 0.20 or 0.36)
            row:SetEdgeColor(0.52, 0.41, 0.20, self.layoutMode and 0.48 or 0.24)
        end
    end
    apply(self.groupFrame)
    apply(self.raidFrame)
end


-- v0.22.2 BAR LAYER FIX
-- Native frame/end-cap art is explicitly drawn above resource fills so a full
-- bar reaches the styled edges without the colored fill painting over the left
-- decorative cap. Applies to Player, Target, Group, Raid, and Companion bars.

-- ============================================================================
-- v0.22.5 TRUE ESO-SHAPED RESOURCE FILL
-- Rebuild resource bars using the same split left/right StatusBar arrangement
-- and matching background/frame pieces used by ESO's native Health bar.
-- This prevents a rectangular fill silhouette from showing behind the ornate
-- frame and lets a 100% resource fill occupy the actual ESO-shaped track.
-- ============================================================================

local function EPC_CreateNativeTextureFromVirtual(parent, name, template, width, height)
    local control = wm:CreateControlFromVirtual(name, parent, template)
    if width and height then control:SetDimensions(width, height) end
    return control
end

local function EPC_CreateSymmetricESOBar(parent, name, width, height, color, textMode)
    local bar = wm:CreateControl(name, parent, CT_CONTROL)
    bar:SetDimensions(width, height)

    local capWidth = math.max(8, math.floor(13 * (height / 23) + 0.5))
    local fillHeight = math.max(6, math.floor(17 * (height / 23) + 0.5))

    -- Native shaped background: left arrow + center + right arrow.
    local bgLeft = EPC_CreateNativeTextureFromVirtual(bar, name .. "_BgLeft", "ZO_PlayerAttributeBgLeftArrow_Keyboard_Template", capWidth, height)
    bgLeft:ClearAnchors()
    bgLeft:SetAnchor(LEFT, bar, LEFT, 0, 0)

    local bgRight = EPC_CreateNativeTextureFromVirtual(bar, name .. "_BgRight", "ZO_PlayerAttributeBgRightArrow_Keyboard_Template", capWidth, height)
    bgRight:ClearAnchors()
    bgRight:SetAnchor(RIGHT, bar, RIGHT, 0, 0)

    local bgCenter = EPC_CreateNativeTextureFromVirtual(bar, name .. "_BgCenter", "ZO_PlayerAttributeBgCenter_Keyboard_Template")
    bgCenter:ClearAnchors()
    bgCenter:SetAnchor(TOPLEFT, bgLeft, TOPRIGHT, 0, 0)
    bgCenter:SetAnchor(BOTTOMRIGHT, bgRight, BOTTOMLEFT, 0, 0)

    -- ESO's native Health bar is two StatusBars meeting at the center. Using the
    -- same geometry makes the resource fill follow the sculpted bar silhouette.
    local fillLeft = wm:CreateControlFromVirtual(name .. "_FillLeft", bar, "ZO_PlayerAttributeStatusBar_Keyboard_Template")
    fillLeft:ClearAnchors()
    fillLeft:SetHeight(fillHeight)
    fillLeft:SetAnchor(LEFT, bar, LEFT, 0, 0)
    fillLeft:SetAnchor(RIGHT, bar, CENTER, 0, 0)
    fillLeft:SetBarAlignment(BAR_ALIGNMENT_REVERSE)
    fillLeft:SetMinMax(0, 1)
    fillLeft:SetValue(0)
    fillLeft:SetColor(unpack(color))

    local fillRight = wm:CreateControlFromVirtual(name .. "_FillRight", bar, "ZO_PlayerAttributeStatusBar_Keyboard_Template")
    fillRight:ClearAnchors()
    fillRight:SetHeight(fillHeight)
    fillRight:SetAnchor(RIGHT, bar, RIGHT, 0, 0)
    fillRight:SetAnchor(LEFT, bar, CENTER, 0, 0)
    fillRight:SetBarAlignment(BAR_ALIGNMENT_NORMAL)
    fillRight:SetMinMax(0, 1)
    fillRight:SetValue(0)
    fillRight:SetColor(unpack(color))

    local glossLeft = wm:CreateControlFromVirtual(name .. "_GlossLeft", bar, "ZO_PlayerAttributeStatusBarGloss_Keyboard_Template")
    glossLeft:ClearAnchors()
    glossLeft:SetHeight(fillHeight)
    glossLeft:SetAnchor(LEFT, bar, LEFT, 0, 0)
    glossLeft:SetAnchor(RIGHT, bar, CENTER, 0, 0)
    glossLeft:SetBarAlignment(BAR_ALIGNMENT_REVERSE)
    glossLeft:SetMinMax(0, 1)
    glossLeft:SetValue(0)
    glossLeft:SetColor(1, 1, 1, 0.42)

    local glossRight = wm:CreateControlFromVirtual(name .. "_GlossRight", bar, "ZO_PlayerAttributeStatusBarGloss_Keyboard_Template")
    glossRight:ClearAnchors()
    glossRight:SetHeight(fillHeight)
    glossRight:SetAnchor(RIGHT, bar, RIGHT, 0, 0)
    glossRight:SetAnchor(LEFT, bar, CENTER, 0, 0)
    glossRight:SetBarAlignment(BAR_ALIGNMENT_NORMAL)
    glossRight:SetMinMax(0, 1)
    glossRight:SetValue(0)
    glossRight:SetColor(1, 1, 1, 0.42)

    -- Native shaped frame, drawn above the fill exactly like ESO's own bar.
    local frameLeft = EPC_CreateNativeTextureFromVirtual(bar, name .. "_FrameLeft", "ZO_PlayerAttributeFrameLeftArrow_Keyboard_Template", capWidth, height)
    frameLeft:ClearAnchors()
    frameLeft:SetAnchor(LEFT, bar, LEFT, 0, 0)

    local frameRight = EPC_CreateNativeTextureFromVirtual(bar, name .. "_FrameRight", "ZO_PlayerAttributeFrameRightArrow_Keyboard_Template", capWidth, height)
    frameRight:ClearAnchors()
    frameRight:SetAnchor(RIGHT, bar, RIGHT, 0, 0)

    local frameCenter = EPC_CreateNativeTextureFromVirtual(bar, name .. "_FrameCenter", "ZO_PlayerAttributeFrameCenter_Keyboard_Template")
    frameCenter:ClearAnchors()
    frameCenter:SetAnchor(TOPLEFT, frameLeft, TOPRIGHT, 0, 0)
    frameCenter:SetAnchor(BOTTOMRIGHT, frameRight, BOTTOMLEFT, 0, 0)

    -- Force the exact ESO layering: background -> fill/gloss -> ornate frame.
    for _, control in ipairs({bgLeft, bgRight, bgCenter}) do
        if control.SetDrawTier then control:SetDrawTier(DT_LOW) end
        control:SetDrawLayer(DL_CONTROLS)
        control:SetDrawLevel(1)
    end
    for _, control in ipairs({fillLeft, fillRight}) do
        control:SetDrawLayer(DL_CONTROLS)
        control:SetDrawLevel(20)
    end
    for _, control in ipairs({glossLeft, glossRight}) do
        control:SetDrawLayer(DL_CONTROLS)
        control:SetDrawLevel(30)
    end
    for _, control in ipairs({frameLeft, frameRight, frameCenter}) do
        if control.SetDrawTier then control:SetDrawTier(DT_HIGH) end
        control:SetDrawLayer(DL_OVERLAY)
        control:SetDrawLevel(100)
    end

    local label = makeLabel(bar, name .. "_Value", "ZoFontGameSmall", C.white, TEXT_ALIGN_CENTER)
    label:SetAnchorFill(bar)
    if label.SetDrawTier then label:SetDrawTier(DT_HIGH) end
    label:SetDrawLayer(DL_OVERLAY)
    label:SetDrawLevel(200)

    bar.epcNative = true
    bar.epcTrueESOShape = true
    bar.epcFillLeft = fillLeft
    bar.epcFillRight = fillRight
    bar.epcGlossLeft = glossLeft
    bar.epcGlossRight = glossRight
    bar.epcBgPieces = { bgLeft, bgRight, bgCenter }
    bar.epcFramePieces = { frameLeft, frameRight, frameCenter }
    bar.epcGlossPieces = { glossLeft, glossRight }
    bar.epcFillPieces = { fillLeft, fillRight }
    bar.epcLabel = label
    bar.epcTextMode = textMode or "FULL"
    return bar
end

createESOResourceBar = function(parent, name, width, color)
    return EPC_CreateSymmetricESOBar(parent, name, width, 23, color, "FULL")
end

createESOCompactHealthBar = function(parent, name, width, height)
    return EPC_CreateSymmetricESOBar(parent, name, width, height, C.health, "PERCENT")
end

updateESOResourceBar = function(bar, current, maximum)
    if not bar then return end
    current, maximum = tonumber(current) or 0, tonumber(maximum) or 0
    local value = 0
    if maximum > 0 then value = math.max(0, math.min(current, maximum)) end

    local fills = {bar.epcFillLeft, bar.epcFillRight}
    local glosses = {bar.epcGlossLeft, bar.epcGlossRight}
    for _, control in ipairs(fills) do
        if control then
            control:SetMinMax(0, maximum > 0 and maximum or 1)
            control:SetValue(value)
        end
    end
    for _, control in ipairs(glosses) do
        if control then
            control:SetMinMax(0, maximum > 0 and maximum or 1)
            control:SetValue(value)
        end
    end

    -- Backward compatibility for any bar constructed before this override.
    if bar.epcFill then
        bar.epcFill:SetMinMax(0, maximum > 0 and maximum or 1)
        bar.epcFill:SetValue(value)
    end
    if bar.epcGloss then
        bar.epcGloss:SetMinMax(0, maximum > 0 and maximum or 1)
        bar.epcGloss:SetValue(value)
    end

    if bar.epcLabel then
        if maximum <= 0 then
            bar.epcLabel:SetText("--")
        elseif bar.epcTextMode == "PERCENT" then
            bar.epcLabel:SetText(percentText(current, maximum))
        elseif bar.epcTextMode == "NONE" then
            bar.epcLabel:SetText("")
        else
            bar.epcLabel:SetText(string.format("%s / %s  (%s)", compactNumber(current), compactNumber(maximum), percentText(current, maximum)))
        end
    end
end

-- ============================================================================
-- v0.29.72 - Full Suite unit-frame ownership.
-- Reassert replacement of ESO player/target/companion/group/raid frames.
-- Boss health remains owned by ESO and is intentionally not replaced.
-- ============================================================================
function F:CreateBossFrame02972()
    -- v0.29.113: The Suite no longer creates a Boss Health overlay. ESO's
    -- native boss-health UI remains the single boss-health presentation.
    if self.bossFrame then
        self.bossFrame:SetHidden(true)
    end
    return nil
end

function F:RefreshBossFrame02972()
    -- Boss health is owned by ESO. Keep any legacy Suite boss control hidden.
    if self.bossFrame then self.bossFrame:SetHidden(true) end
end

function F:ApplyAllNativeFrameReplacement02972()
    if not EPC.saved then return end
    local replace = EPC.saved.replaceDefaultUnitFrames ~= false
    local reason = "ESOAdventurerSuite_AllUnitFrames02972"

    if UNIT_FRAMES then
        if type(UNIT_FRAMES.SetFrameHiddenForReason) == "function" then
            pcall(UNIT_FRAMES.SetFrameHiddenForReason, UNIT_FRAMES, "reticleover", reason, replace)
            pcall(UNIT_FRAMES.SetFrameHiddenForReason, UNIT_FRAMES, "companion", reason, replace)
        end
        if type(UNIT_FRAMES.SetGroupAndRaidFramesHiddenForReason) == "function" then
            pcall(UNIT_FRAMES.SetGroupAndRaidFramesHiddenForReason, UNIT_FRAMES, reason, replace)
        end
        local function applyReason(frames)
            if type(frames) ~= "table" then return end
            for _, nativeFrame in pairs(frames) do
                if nativeFrame and type(nativeFrame.SetHiddenForReason) == "function" then
                    pcall(nativeFrame.SetHiddenForReason, nativeFrame, reason, replace)
                end
            end
        end
        applyReason(UNIT_FRAMES.groupFrames)
        applyReason(UNIT_FRAMES.raidFrames)
        applyReason(UNIT_FRAMES.companionRaidFrames)
    end

    if PLAYER_ATTRIBUTE_BARS_FRAGMENT and type(PLAYER_ATTRIBUTE_BARS_FRAGMENT.SetHiddenForReason) == "function" then
        pcall(PLAYER_ATTRIBUTE_BARS_FRAGMENT.SetHiddenForReason, PLAYER_ATTRIBUTE_BARS_FRAGMENT, reason, replace)
    end

    -- v0.29.113: Do not hide, force-show, or otherwise manage BOSS_BAR here.
    -- ESO retains full ownership of its native boss-health display.

end

local EAS_ApplyDefaultFrameReplacementBase02972 = F.ApplyDefaultFrameReplacement
function F:ApplyDefaultFrameReplacement()
    if EAS_ApplyDefaultFrameReplacementBase02972 then EAS_ApplyDefaultFrameReplacementBase02972(self) end
    self:ApplyAllNativeFrameReplacement02972()
end

local EAS_RefreshAllBase02972 = F.RefreshAll
function F:RefreshAll(refreshAuras)
    local result = EAS_RefreshAllBase02972(self, refreshAuras)
    self:ApplyAllNativeFrameReplacement02972()
    return result
end

local EAS_SetLayoutModeBase02972 = F.SetLayoutMode
function F:SetLayoutMode(active)
    EAS_SetLayoutModeBase02972(self, active)
end

local EAS_InitializeUnitFramesBase02972 = F.Initialize
function F:Initialize()
    if EPC.saved and EPC.saved.unitFrameReplacementMigrated02972 ~= true then
        EPC.saved.replaceDefaultUnitFrames = true
        EPC.saved.unitFrameReplacementMigrated02972 = true
    end
    EAS_InitializeUnitFramesBase02972(self)
    self:ApplyAllNativeFrameReplacement02972()

    -- Keep ownership of the non-boss native frames only. Boss health remains
    -- entirely under ESO control and has no Suite event/update loop.
    local prefix = (EPC.name or "ESOAdventurerSuite") .. "_NativeUnitFrameOwner02972"
    EVENT_MANAGER:RegisterForUpdate(prefix .. "_Guard", 4000, function()
        if EPC.UnitFrames and EPC.saved and EPC.saved.replaceDefaultUnitFrames ~= false then
            EPC.UnitFrames:ApplyAllNativeFrameReplacement02972()
        end
    end)
end

-- Keep the new boss replacement consistent with the existing HUD lifecycle.
local EAS_HideAllCustomFramesBase02972 = F.HideAllCustomFrames
function F:HideAllCustomFrames()
    EAS_HideAllCustomFramesBase02972(self)
    if self.bossFrame then self.bossFrame:SetHidden(true) end
end

local EAS_ApplyScalesAndAlphaBase02972 = F.ApplyScalesAndAlpha
function F:ApplyScalesAndAlpha()
    EAS_ApplyScalesAndAlphaBase02972(self)
    if self.bossFrame and EPC.saved then
        local scale = tonumber(EPC.saved.targetFrameScale) or tonumber(EPC.saved.unitFrameScale) or 1.0
        local alpha = tonumber(EPC.saved.unitFrameAlpha) or 0.94
        self.bossFrame:SetScale(scale)
        self.bossFrame:SetAlpha(alpha)
    end
end


-- ============================================================================
-- v0.29.90 - Five selectable Suite unit-frame visual styles.
-- ESO Classic preserves the exact pre-0.29.90 appearance. Other themes only
-- restyle existing controls; geometry, saved positions, scales, auras, and unit
-- data are untouched. Player/Target/Group/Raid share one consistent selection.
-- ============================================================================
local EAS_UNIT_FRAME_THEMES_02990 = {
    ESO_CLASSIC = {
        name = "ESO Classic",
        panel = false,
        frame = {1.00, 1.00, 1.00, 1.00},
        gloss = {1.00, 1.00, 1.00, 0.42},
        label = {1.00, 1.00, 1.00, 1.00},
        info = {0.70, 0.73, 0.78, 1.00},
        groupPanel = {0.010, 0.012, 0.016, 0.58},
        groupEdge = {0.55, 0.43, 0.20, 0.48},
        groupRow = {0.012, 0.014, 0.018, 0.36},
        groupRowEdge = {0.52, 0.41, 0.20, 0.24},
        accent = {0.72, 0.57, 0.27, 1.00},
    },
    CLEAN_MINIMAL = {
        name = "Clean Minimal",
        panel = false,
        frame = {0.84, 0.87, 0.91, 0.92},
        gloss = {1.00, 1.00, 1.00, 0.18},
        label = {0.96, 0.97, 0.99, 1.00},
        info = {0.66, 0.70, 0.76, 1.00},
        groupPanel = {0.010, 0.012, 0.016, 0.22},
        groupEdge = {0.44, 0.48, 0.54, 0.34},
        groupRow = {0.010, 0.012, 0.016, 0.18},
        groupRowEdge = {0.44, 0.48, 0.54, 0.22},
        accent = {0.76, 0.80, 0.86, 0.90},
    },
    DARK_GOLD = {
        name = "Dark Gold",
        panel = true,
        panelCenter = {0.012, 0.010, 0.007, 0.70},
        panelEdge = {0.74, 0.55, 0.20, 0.68},
        frame = {0.94, 0.72, 0.31, 1.00},
        gloss = {1.00, 0.86, 0.52, 0.26},
        label = {1.00, 0.96, 0.84, 1.00},
        info = {0.86, 0.72, 0.43, 1.00},
        groupPanel = {0.012, 0.010, 0.007, 0.76},
        groupEdge = {0.78, 0.58, 0.20, 0.74},
        groupRow = {0.018, 0.014, 0.008, 0.58},
        groupRowEdge = {0.72, 0.52, 0.18, 0.48},
        accent = {0.96, 0.72, 0.24, 1.00},
    },
    ARCANE_BLUE = {
        name = "Arcane Blue",
        panel = true,
        panelCenter = {0.006, 0.018, 0.030, 0.72},
        panelEdge = {0.18, 0.68, 0.88, 0.68},
        frame = {0.32, 0.82, 1.00, 1.00},
        gloss = {0.56, 0.90, 1.00, 0.28},
        label = {0.90, 0.98, 1.00, 1.00},
        info = {0.48, 0.80, 0.94, 1.00},
        groupPanel = {0.006, 0.018, 0.030, 0.78},
        groupEdge = {0.18, 0.68, 0.88, 0.72},
        groupRow = {0.008, 0.024, 0.038, 0.58},
        groupRowEdge = {0.16, 0.60, 0.80, 0.48},
        accent = {0.22, 0.78, 1.00, 1.00},
    },
    HIGH_CONTRAST = {
        name = "High Contrast",
        panel = true,
        panelCenter = {0.000, 0.000, 0.000, 0.88},
        panelEdge = {0.88, 0.90, 0.94, 0.82},
        frame = {0.96, 0.97, 1.00, 1.00},
        gloss = {1.00, 1.00, 1.00, 0.10},
        label = {1.00, 1.00, 1.00, 1.00},
        info = {0.86, 0.88, 0.92, 1.00},
        groupPanel = {0.000, 0.000, 0.000, 0.90},
        groupEdge = {0.88, 0.90, 0.94, 0.80},
        groupRow = {0.000, 0.000, 0.000, 0.74},
        groupRowEdge = {0.76, 0.79, 0.84, 0.58},
        accent = {1.00, 1.00, 1.00, 0.96},
    },
}

local function EAS_SetTextureTint02990(control, color)
    if not control or type(control.SetColor) ~= "function" or not color then return end
    control:SetColor(color[1] or 1, color[2] or 1, color[3] or 1, color[4] or 1)
end

local function EAS_SetLabelColor02990(control, color)
    if not control or type(control.SetColor) ~= "function" or not color then return end
    control:SetColor(color[1] or 1, color[2] or 1, color[3] or 1, color[4] or 1)
end

function F:GetVisualTheme02990()
    local key = EPC.saved and tostring(EPC.saved.unitFrameVisualStyle or "ESO_CLASSIC") or "ESO_CLASSIC"
    return EAS_UNIT_FRAME_THEMES_02990[key] or EAS_UNIT_FRAME_THEMES_02990.ESO_CLASSIC, key
end

function F:ApplyBarVisualTheme02990(bar, theme)
    if not bar or not theme then return end
    for _, piece in ipairs(bar.epcBgPieces or {}) do EAS_SetTextureTint02990(piece, {0.72, 0.74, 0.78, 1.00}) end
    for _, piece in ipairs(bar.epcFramePieces or {}) do EAS_SetTextureTint02990(piece, theme.frame) end
    for _, piece in ipairs(bar.epcGlossPieces or {}) do EAS_SetTextureTint02990(piece, theme.gloss) end
    EAS_SetLabelColor02990(bar.epcLabel, theme.label)
end

function F:ApplyUnitFrameVisualTheme02990()
    if not EPC.saved then return end
    local theme, key = self:GetVisualTheme02990()
    local classic = key == "ESO_CLASSIC"
    local layout = self.layoutMode == true

    local function styleShellTheme(frame, isPlayerTarget)
        if not frame then return end

        -- ESO Classic is intentionally the exact legacy/current appearance.
        if classic then
            if isPlayerTarget and frame.epcNoPanel then
                if frame.epcShadow then frame.epcShadow:SetHidden(true) end
                if frame.epcBackground then frame.epcBackground:SetHidden(true) end
                if frame.epcAccent then frame.epcAccent:SetHidden(true) end
            end
            return
        end

        if isPlayerTarget then
            if frame.epcShadow then frame.epcShadow:SetHidden(true) end
            if frame.epcBackground then
                if theme.panel or layout then
                    frame.epcBackground:SetHidden(false)
                    if layout then
                        frame.epcBackground:SetCenterColor(0.018, 0.022, 0.030, 0.42)
                        frame.epcBackground:SetEdgeColor(0.96, 0.72, 0.24, 0.90)
                    else
                        local center = theme.panelCenter or {0.010,0.014,0.020,0.60}
                        local edge = theme.panelEdge or theme.groupEdge
                        frame.epcBackground:SetCenterColor(unpack(center))
                        frame.epcBackground:SetEdgeColor(unpack(edge))
                    end
                else
                    frame.epcBackground:SetHidden(true)
                end
            end
            if frame.epcAccent then
                frame.epcAccent:SetHidden(not theme.panel)
                if theme.panel then frame.epcAccent:SetCenterColor(unpack(theme.accent)) end
            end
        end
    end

    local function styleUnit(frame)
        if not frame then return end
        styleShellTheme(frame, true)
        EAS_SetLabelColor02990(frame.epcTitle, theme.label)
        EAS_SetLabelColor02990(frame.epcInfo, theme.info)
        if frame.epcBars then
            self:ApplyBarVisualTheme02990(frame.epcBars.health, theme)
            self:ApplyBarVisualTheme02990(frame.epcBars.magicka, theme)
            self:ApplyBarVisualTheme02990(frame.epcBars.stamina, theme)
        end
    end

    local function styleRoster(frame)
        if not frame then return end
        if frame.epcBackground then
            frame.epcBackground:SetHidden(false)
            if layout then
                frame.epcBackground:SetCenterColor(0.010, 0.012, 0.016, 0.35)
                frame.epcBackground:SetEdgeColor(0.96, 0.72, 0.24, 0.86)
            else
                frame.epcBackground:SetCenterColor(unpack(theme.groupPanel))
                frame.epcBackground:SetEdgeColor(unpack(theme.groupEdge))
            end
        end
        if frame.epcAccent then
            frame.epcAccent:SetHidden(not (theme.panel and not classic))
            if theme.panel and not classic then frame.epcAccent:SetCenterColor(unpack(theme.accent)) end
        end
        EAS_SetLabelColor02990(frame.epcTitle, theme.label)
        EAS_SetLabelColor02990(frame.epcStatus, theme.info)
        for _, row in ipairs(frame.epcRows or {}) do
            row:SetCenterColor(unpack(layout and {0.012,0.014,0.018,0.26} or theme.groupRow))
            row:SetEdgeColor(unpack(layout and {0.96,0.72,0.24,0.42} or theme.groupRowEdge))
            EAS_SetLabelColor02990(row.epcName, theme.label)
            EAS_SetLabelColor02990(row.epcMeta, theme.info)
            EAS_SetLabelColor02990(row.epcCompanion, theme.label)
            EAS_SetLabelColor02990(row.epcCompanionMeta, theme.info)
            if row.epcAccent and not classic then row.epcAccent:SetCenterColor(unpack(theme.accent)) end
            if row.epcBars then self:ApplyBarVisualTheme02990(row.epcBars.health, theme) end
            if row.epcCompanionHealth then self:ApplyBarVisualTheme02990(row.epcCompanionHealth, theme) end
        end
    end

    styleUnit(self.playerFrame)
    styleUnit(self.targetFrame)
    styleRoster(self.groupFrame)
    styleRoster(self.raidFrame)
end

local EAS_ApplyVisualStyleBase02990 = F.ApplyVisualStyle
function F:ApplyVisualStyle()
    EAS_ApplyVisualStyleBase02990(self)
    self:ApplyUnitFrameVisualTheme02990()
end

-- ============================================================================
-- v0.29.91 - Five genuinely different unit-frame designs.
-- Unlike v0.29.90, these presets change geometry/layout as well as treatment.
-- ESO Classic remains the exact legacy layout. The selected design is shared by
-- Player, Target, Group, and Raid frames, while saved anchors/scales are kept.
-- ============================================================================

-- Give the new layout keys their own restrained visual treatments too. The main
-- difference between these presets is geometry, not color.
EAS_UNIT_FRAME_THEMES_02990.COMPACT_STACK = {
    name = "Compact Stack", panel = false,
    frame = {0.92,0.94,0.97,0.96}, gloss = {1,1,1,0.20},
    label = {1,1,1,1}, info = {0.72,0.75,0.80,1},
    groupPanel = {0.008,0.010,0.014,0.44}, groupEdge = {0.40,0.43,0.49,0.42},
    groupRow = {0.008,0.010,0.014,0.30}, groupRowEdge = {0.40,0.43,0.49,0.26},
    accent = {0.80,0.83,0.88,0.94},
}
EAS_UNIT_FRAME_THEMES_02990.SPLIT_RESOURCES = {
    name = "Split Resources", panel = true,
    panelCenter = {0.010,0.014,0.020,0.66}, panelEdge = {0.60,0.47,0.22,0.60},
    frame = {0.96,0.78,0.42,1}, gloss = {1,0.90,0.66,0.24},
    label = {1,0.98,0.92,1}, info = {0.82,0.72,0.54,1},
    groupPanel = {0.010,0.014,0.020,0.68}, groupEdge = {0.60,0.47,0.22,0.58},
    groupRow = {0.012,0.016,0.022,0.50}, groupRowEdge = {0.55,0.43,0.20,0.38},
    accent = {0.96,0.72,0.24,1},
}
EAS_UNIT_FRAME_THEMES_02990.WIDE_PLATE = {
    name = "Wide Plate", panel = true,
    panelCenter = {0.006,0.012,0.020,0.78}, panelEdge = {0.24,0.58,0.78,0.68},
    frame = {0.46,0.82,1.00,1}, gloss = {0.72,0.93,1.00,0.24},
    label = {0.94,0.99,1.00,1}, info = {0.58,0.82,0.94,1},
    groupPanel = {0.006,0.012,0.020,0.78}, groupEdge = {0.24,0.58,0.78,0.66},
    groupRow = {0.008,0.018,0.030,0.58}, groupRowEdge = {0.20,0.52,0.72,0.46},
    accent = {0.28,0.76,1.00,1},
}
EAS_UNIT_FRAME_THEMES_02990.TACTICAL_GRID = {
    name = "Tactical Grid", panel = true,
    panelCenter = {0.004,0.006,0.009,0.86}, panelEdge = {0.72,0.74,0.78,0.66},
    frame = {0.92,0.94,0.98,1}, gloss = {1,1,1,0.12},
    label = {1,1,1,1}, info = {0.72,0.76,0.82,1},
    groupPanel = {0.004,0.006,0.009,0.88}, groupEdge = {0.72,0.74,0.78,0.62},
    groupRow = {0.008,0.010,0.014,0.72}, groupRowEdge = {0.58,0.61,0.66,0.50},
    accent = {0.96,0.72,0.24,1},
}

local EAS_LEGACY_STYLE_MAP_02991 = {
    CLEAN_MINIMAL = "COMPACT_STACK",
    -- Styles 3-5 were removed in 0.29.111 because they duplicated/simulated
    -- layouts already covered by the retained Center Core design.
    DARK_GOLD = "CENTER_CORE",
    ARCANE_BLUE = "CENTER_CORE",
    HIGH_CONTRAST = "CENTER_CORE",
    SPLIT_RESOURCES = "CENTER_CORE",
    WIDE_PLATE = "CENTER_CORE",
    TACTICAL_GRID = "CENTER_CORE",
}

local function EAS_GetUnitFrameDesign02991()
    local key = EPC.saved and tostring(EPC.saved.unitFrameVisualStyle or "ESO_CLASSIC") or "ESO_CLASSIC"
    return EAS_LEGACY_STYLE_MAP_02991[key] or key
end

local function EAS_SetBarBox02991(bar, x, y, w)
    if not bar then return end
    bar:ClearAnchors()
    bar:SetAnchor(TOPLEFT, bar:GetParent(), TOPLEFT, x, y)
    bar:SetWidth(math.max(80, w))
end

local function EAS_SizeAuraSlots02991(frame, size, step)
    if not frame then return end
    frame.epcAuraSlotSize = size
    frame.epcAuraSlotStep = step
    local function resize(slots)
        for _, slot in ipairs(slots or {}) do
            if slot then
                slot:SetDimensions(size, size)
                if slot.epcTimerBack then
                    slot.epcTimerBack:SetDimensions(math.max(18, size - 8), math.max(13, size - 14))
                end
            end
        end
    end
    resize(frame.epcBuffSlots)
    resize(frame.epcDebuffSlots)
end

local EAS_LayoutIntegratedUnitFrameBase02991 = F.LayoutIntegratedUnitFrame
function F:LayoutIntegratedUnitFrame(frame, buffCount, debuffCount, preview)
    if not frame then return end
    local design = EAS_GetUnitFrameDesign02991()
    local isPlayer = frame.epcKind == "player"
    local isTarget = frame.epcKind == "target"

    if design == "ESO_CLASSIC" then
        frame:SetWidth(420)
        EAS_SizeAuraSlots02991(frame, 30, 33)
        if frame.epcTitle then
            frame.epcTitle:ClearAnchors()
            frame.epcTitle:SetAnchor(TOPLEFT, frame, TOPLEFT, 12, 0)
            frame.epcTitle:SetDimensions(396, 22)
            frame.epcTitle:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        end
        if frame.epcInfo then
            frame.epcInfo:ClearAnchors()
            frame.epcInfo:SetAnchor(TOPLEFT, frame, TOPLEFT, 12, 20)
            frame.epcInfo:SetDimensions(396, 18)
            frame.epcInfo:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        end
        for _, bar in pairs(frame.epcBars or {}) do if bar then bar:SetWidth(396) end end
        return EAS_LayoutIntegratedUnitFrameBase02991(self, frame, buffCount, debuffCount, preview)
    end

    local cfg
    if design == "COMPACT_STACK" then
        cfg = { playerW=340, targetW=360, aura=24, step=27, pad=8, headerPlayer=0, headerTarget=34, mode="STACK" }
    elseif design == "SPLIT_RESOURCES" then
        cfg = { playerW=430, targetW=430, aura=28, step=31, pad=10, headerPlayer=38, headerTarget=38, mode="SPLIT" }
    elseif design == "WIDE_PLATE" then
        cfg = { playerW=520, targetW=520, aura=30, step=33, pad=14, headerPlayer=42, headerTarget=42, mode="PLATE" }
    else -- TACTICAL_GRID
        cfg = { playerW=390, targetW=430, aura=26, step=29, pad=8, headerPlayer=34, headerTarget=34, mode="TACTICAL" }
    end

    local width = isTarget and cfg.targetW or cfg.playerW
    frame:SetWidth(width)
    EAS_SizeAuraSlots02991(frame, cfg.aura, cfg.step)

    local showPlayerHeader = isPlayer and design ~= "COMPACT_STACK"
    local headerHeight = isTarget and cfg.headerTarget or (showPlayerHeader and cfg.headerPlayer or 0)

    if frame.epcTitle then
        frame.epcTitle:ClearAnchors()
        frame.epcTitle:SetAnchor(TOPLEFT, frame, TOPLEFT, cfg.pad, 1)
        frame.epcTitle:SetDimensions(width - (cfg.pad * 2), 20)
    end
    if frame.epcInfo then
        frame.epcInfo:ClearAnchors()
        frame.epcInfo:SetAnchor(TOPLEFT, frame, TOPLEFT, cfg.pad, 20)
        frame.epcInfo:SetDimensions(width - (cfg.pad * 2), 16)
    end

    if design == "TACTICAL_GRID" then
        if frame.epcTitle then frame.epcTitle:SetHorizontalAlignment(TEXT_ALIGN_LEFT) frame.epcTitle:SetWidth(math.floor(width * 0.62)) end
        if frame.epcInfo then
            frame.epcInfo:ClearAnchors()
            frame.epcInfo:SetAnchor(TOPRIGHT, frame, TOPRIGHT, -cfg.pad, 3)
            frame.epcInfo:SetDimensions(math.floor(width * 0.34), 18)
            frame.epcInfo:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        end
    elseif design == "COMPACT_STACK" and isTarget then
        if frame.epcTitle then frame.epcTitle:SetHorizontalAlignment(TEXT_ALIGN_LEFT) end
        if frame.epcInfo then frame.epcInfo:SetHorizontalAlignment(TEXT_ALIGN_RIGHT) end
    else
        if frame.epcTitle then frame.epcTitle:SetHorizontalAlignment(TEXT_ALIGN_CENTER) end
        if frame.epcInfo then frame.epcInfo:SetHorizontalAlignment(TEXT_ALIGN_CENTER) end
    end

    local displayBuffs = tonumber(buffCount) or 0
    local displayDebuffs = tonumber(debuffCount) or 0
    if preview then
        displayBuffs = math.max(displayBuffs, 4)
        displayDebuffs = math.max(displayDebuffs, 3)
    end

    local auraPad = cfg.pad
    if design == "WIDE_PLATE" then auraPad = 40 end
    local perRow = math.max(1, math.floor((width - auraPad * 2) / cfg.step))
    local function position(slots, displayCount, startY)
        for i=1,#(slots or {}) do
            local slot = slots[i]
            slot:ClearAnchors()
            local rowIndex = math.floor((i - 1) / perRow)
            local col = (i - 1) % perRow
            slot:SetAnchor(TOPLEFT, frame, TOPLEFT, auraPad + (col * cfg.step), startY + (rowIndex * cfg.step))
        end
        return displayCount > 0 and math.ceil(displayCount / perRow) or 0
    end

    local buffRows = position(frame.epcBuffSlots, displayBuffs, headerHeight)
    local healthY = headerHeight + (buffRows * cfg.step) + (buffRows > 0 and 4 or 0)

    local healthX, healthW
    if design == "WIDE_PLATE" then
        healthX, healthW = 50, width - 100
    else
        healthX, healthW = cfg.pad, width - (cfg.pad * 2)
    end
    -- Player Styles 1-5 receive their final stable geometry in the mature
    -- 0.29.97 policy below. Keep this base Health anchor mathematically centered
    -- so there is no style-specific bias before that final geometry pass.
    EAS_SetBarBox02991(frame.epcBars.health, healthX, healthY, healthW)

    local healthBottom = healthY + 23
    local debuffRows = 0
    if displayDebuffs > 0 then
        local debuffY = healthBottom + 4
        debuffRows = position(frame.epcDebuffSlots, displayDebuffs, debuffY)
        healthBottom = debuffY + (debuffRows * cfg.step)
    else
        position(frame.epcDebuffSlots, 0, healthBottom)
    end

    if isTarget then
        if frame.epcBars.magicka then frame.epcBars.magicka:SetHidden(true) end
        if frame.epcBars.stamina then frame.epcBars.stamina:SetHidden(true) end
        frame:SetHeight(healthBottom + (debuffRows > 0 and 4 or 2))
        return
    end

    frame.epcBars.magicka:SetHidden(false)
    frame.epcBars.stamina:SetHidden(false)
    local resourcesY = healthBottom + (debuffRows > 0 and 5 or 3)

    if cfg.mode == "SPLIT" or cfg.mode == "TACTICAL" then
        local gap = 8
        local totalW = width - (cfg.pad * 2)
        local half = math.floor((totalW - gap) / 2)
        EAS_SetBarBox02991(frame.epcBars.magicka, cfg.pad, resourcesY, half)
        EAS_SetBarBox02991(frame.epcBars.stamina, cfg.pad + half + gap, resourcesY, totalW - half - gap)
        frame:SetHeight(resourcesY + 26)
    elseif cfg.mode == "PLATE" then
        local resourceW = width - 190
        local resourceX = math.floor((width - resourceW) / 2)
        EAS_SetBarBox02991(frame.epcBars.magicka, resourceX, resourcesY, resourceW)
        EAS_SetBarBox02991(frame.epcBars.stamina, resourceX, resourcesY + 26, resourceW)
        frame:SetHeight(resourcesY + 51)
    else -- compact stack
        local resourceW = width - (cfg.pad * 2)
        EAS_SetBarBox02991(frame.epcBars.magicka, cfg.pad, resourcesY, resourceW)
        EAS_SetBarBox02991(frame.epcBars.stamina, cfg.pad, resourcesY + 24, resourceW)
        frame:SetHeight(resourcesY + 47)
    end
end

local EAS_UpdateUnitFrameBase02991 = F.UpdateUnitFrame
function F:UpdateUnitFrame(frame, unitTag, preview)
    local ok = EAS_UpdateUnitFrameBase02991(self, frame, unitTag, preview)
    if not ok or not frame then return ok end
    local design = EAS_GetUnitFrameDesign02991()
    local isPlayer = frame.epcKind == "player"
    local isTarget = frame.epcKind == "target"

    if isPlayer then
        if design == "ESO_CLASSIC" or design == "COMPACT_STACK" then
            frame.epcTitle:SetHidden(true)
            frame.epcInfo:SetHidden(true)
        else
            local name, info = self:GetUnitMeta(unitTag)
            if preview and safe(DoesUnitExist, false, unitTag) ~= true then
                name, info = "PLAYER PREVIEW", "LAYOUT MODE"
            end
            frame.epcTitle:SetText(name ~= "" and name or "PLAYER")
            frame.epcInfo:SetText(info or "")
            frame.epcTitle:SetHidden(false)
            frame.epcInfo:SetHidden(false)
        end
    elseif isTarget then
        frame.epcTitle:SetHidden(false)
        frame.epcInfo:SetHidden(false)
    end
    return ok
end

local function EAS_LayoutRosterRow02991(row, width, compactH, expandedH, design)
    if not row then return end
    row.epcCompactHeight = compactH
    row.epcExpandedHeight = expandedH
    row:SetWidth(width)
    row:SetHeight(row.epcHasCompanion == true and expandedH or compactH)

    local pad = design == "COMPACT_STACK" and 5 or 7
    local nameY = design == "WIDE_PLATE" and 4 or 1
    local healthY = design == "WIDE_PLATE" and 23 or 15
    if design == "TACTICAL_GRID" then healthY = 17 end
    if design == "SPLIT_RESOURCES" then healthY = 18 end
    if design == "ESO_CLASSIC" then pad, nameY, healthY = 6, 0, 14 end

    if row.epcAccent then
        row.epcAccent:ClearAnchors()
        if design == "WIDE_PLATE" then
            row.epcAccent:SetAnchor(TOPLEFT, row, TOPLEFT, 1, 1)
            row.epcAccent:SetAnchor(TOPRIGHT, row, TOPRIGHT, -1, 1)
            row.epcAccent:SetHeight(2)
        else
            row.epcAccent:SetAnchor(TOPLEFT, row, TOPLEFT, 1, 1)
            row.epcAccent:SetAnchor(BOTTOMLEFT, row, BOTTOMLEFT, 1, -1)
            row.epcAccent:SetWidth(design == "TACTICAL_GRID" and 4 or 2)
        end
    end

    if row.epcName then
        row.epcName:ClearAnchors()
        row.epcName:SetAnchor(TOPLEFT, row, TOPLEFT, pad, nameY)
        row.epcName:SetDimensions(math.max(70, width - (design == "TACTICAL_GRID" and 82 or 150)), 16)
        row.epcName:SetHorizontalAlignment(design == "WIDE_PLATE" and TEXT_ALIGN_CENTER or TEXT_ALIGN_LEFT)
    end
    if row.epcMeta then
        row.epcMeta:ClearAnchors()
        row.epcMeta:SetAnchor(TOPRIGHT, row, TOPRIGHT, -pad, nameY)
        row.epcMeta:SetDimensions(design == "TACTICAL_GRID" and 72 or 136, 16)
        row.epcMeta:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    end
    if row.epcBars and row.epcBars.health then
        row.epcBars.health:ClearAnchors()
        row.epcBars.health:SetAnchor(TOPLEFT, row, TOPLEFT, pad, healthY)
        row.epcBars.health:SetWidth(width - (pad * 2))
    end

    local companionTop = design == "ESO_CLASSIC" and 32 or (healthY + 22)
    if row.epcCompanionDivider and row.epcCompanionDivider ~= false then
        row.epcCompanionDivider:ClearAnchors()
        row.epcCompanionDivider:SetAnchor(TOPLEFT, row, TOPLEFT, pad, companionTop)
        row.epcCompanionDivider:SetDimensions(width - (pad * 2), 1)
    end
    if row.epcCompanion and row.epcCompanion ~= false then
        row.epcCompanion:ClearAnchors()
        row.epcCompanion:SetAnchor(TOPLEFT, row, TOPLEFT, pad, companionTop + 3)
        row.epcCompanion:SetDimensions(math.max(65, width - 110), 14)
    end
    if row.epcCompanionMeta and row.epcCompanionMeta ~= false then
        row.epcCompanionMeta:ClearAnchors()
        row.epcCompanionMeta:SetAnchor(TOPRIGHT, row, TOPRIGHT, -pad, companionTop + 3)
        row.epcCompanionMeta:SetDimensions(96, 14)
    end
    if row.epcCompanionHealth and row.epcCompanionHealth ~= false then
        row.epcCompanionHealth:ClearAnchors()
        row.epcCompanionHealth:SetAnchor(TOPLEFT, row, TOPLEFT, pad, companionTop + 17)
        row.epcCompanionHealth:SetWidth(width - (pad * 2))
    end
end

local EAS_RefreshGroupFramesBase02991 = F.RefreshGroupFrames
function F:RefreshGroupFrames()
    local design = EAS_GetUnitFrameDesign02991()
    -- Restore the exact legacy roster geometry before the mature refresh code
    -- runs, so switching back from a custom design never keeps custom widths.
    if design == "ESO_CLASSIC" then
        if self.groupFrame then
            self.groupFrame:SetWidth(330)
            for _, row in ipairs(self.groupFrame.epcRows or {}) do
                EAS_LayoutRosterRow02991(row, 306, 32, 63, "ESO_CLASSIC")
            end
        end
        if self.raidFrame then
            for _, row in ipairs(self.raidFrame.epcRows or {}) do
                EAS_LayoutRosterRow02991(row, 270, 32, 32, "ESO_CLASSIC")
            end
        end
    end

    EAS_RefreshGroupFramesBase02991(self)
    if design == "ESO_CLASSIC" then return end

    -- Group: four visibly different arrangements across the new designs.
    if self.groupFrame then
        local visible = {}
        for _, row in ipairs(self.groupFrame.epcRows or {}) do if row and not row:IsHidden() then visible[#visible+1] = row end end

        local rowW, compactH, expandedH, gap
        if design == "COMPACT_STACK" then rowW, compactH, expandedH, gap = 276, 32, 58, 3
        elseif design == "SPLIT_RESOURCES" then rowW, compactH, expandedH, gap = 336, 38, 70, 5
        elseif design == "WIDE_PLATE" then rowW, compactH, expandedH, gap = 366, 44, 78, 7
        else rowW, compactH, expandedH, gap = 210, 38, 70, 6 end

        for _, row in ipairs(self.groupFrame.epcRows or {}) do
            EAS_LayoutRosterRow02991(row, rowW, compactH, expandedH, design)
        end

        if design == "TACTICAL_GRID" then
            local stepY = expandedH + gap
            for index, row in ipairs(visible) do
                local col = (index - 1) % 2
                local r = math.floor((index - 1) / 2)
                row:ClearAnchors()
                row:SetAnchor(TOPLEFT, self.groupFrame, TOPLEFT, 8 + col * (rowW + gap), 8 + r * stepY)
            end
            local rows = math.max(1, math.ceil(#visible / 2))
            self.groupFrame:SetDimensions(16 + (rowW * 2) + gap, 16 + (rows * expandedH) + ((rows - 1) * gap))
        else
            local y = 8
            for _, row in ipairs(visible) do
                row:ClearAnchors()
                row:SetAnchor(TOPLEFT, self.groupFrame, TOPLEFT, 8, y)
                y = y + row:GetHeight() + gap
            end
            self.groupFrame:SetDimensions(rowW + 16, math.max(48, y + 5))
        end
    end

    -- Raid: each design uses a different density/column layout.
    if self.raidFrame then
        local visible = {}
        for _, row in ipairs(self.raidFrame.epcRows or {}) do if row and not row:IsHidden() then visible[#visible+1] = row end end
        local rowW, rowH, columns, gap
        if design == "COMPACT_STACK" then rowW, rowH, columns, gap = 220, 30, 3, 5
        elseif design == "SPLIT_RESOURCES" then rowW, rowH, columns, gap = 286, 36, 2, 7
        elseif design == "WIDE_PLATE" then rowW, rowH, columns, gap = 320, 42, 2, 9
        else rowW, rowH, columns, gap = 205, 34, 4, 5 end
        columns = math.max(1, math.min(columns, math.max(1, #visible)))
        local rows = math.max(1, math.ceil(math.max(1, #visible) / columns))
        local top = 29
        for _, row in ipairs(self.raidFrame.epcRows or {}) do EAS_LayoutRosterRow02991(row, rowW, rowH, rowH, design) end
        for index, row in ipairs(visible) do
            local col = (index - 1) % columns
            local r = math.floor((index - 1) / columns)
            row:ClearAnchors()
            row:SetAnchor(TOPLEFT, self.raidFrame, TOPLEFT, 10 + col * (rowW + gap), top + r * (rowH + gap))
        end
        self.raidFrame:SetDimensions(20 + columns * rowW + (columns - 1) * gap, top + rows * rowH + (rows - 1) * gap + 7)
    end
end

-- Re-apply the layout-safe visual treatment after every design refresh.
local EAS_ApplyVisualStyleBase02991 = F.ApplyVisualStyle
function F:ApplyVisualStyle()
    EAS_ApplyVisualStyleBase02991(self)
    local design = EAS_GetUnitFrameDesign02991()
    -- Old saved theme keys from 0.29.90 transparently migrate to the new designs.
    if EPC.saved and EAS_LEGACY_STYLE_MAP_02991[EPC.saved.unitFrameVisualStyle] then
        EPC.saved.unitFrameVisualStyle = design
    end
end

-- ============================================================================
-- v0.29.93 - Ten background-free rectangular unit-frame designs.
-- All Suite Player/Target/Group/Raid designs now use clean square resource bars
-- and no card/panel backdrop. Five additional geometry presets are provided.
-- ============================================================================
local EAS_RECT_DESIGNS_02993 = {
    RECT_STACK = true,
    TRIPLE_BLOCKS = true,
    SIDE_METERS = true,
    CENTER_CORE = true,
    SLIM_LINES = true,
}

-- Register neutral visual entries so the older theme layer never falls back to
-- a panel-oriented preset for the five new geometry keys.
local function EAS_RegisterRectTheme02993(key, name)
    EAS_UNIT_FRAME_THEMES_02990[key] = {
        name = name, panel = false,
        frame = {0.92,0.94,0.98,1.00}, gloss = {1,1,1,0},
        label = {1,1,1,1}, info = {0.72,0.76,0.82,1},
        groupPanel = {0,0,0,0}, groupEdge = {0,0,0,0},
        groupRow = {0,0,0,0}, groupRowEdge = {0,0,0,0},
        accent = {0.82,0.84,0.88,1},
    }
end
EAS_RegisterRectTheme02993("RECT_STACK", "Rect Stack")
EAS_RegisterRectTheme02993("TRIPLE_BLOCKS", "Triple Blocks")
EAS_RegisterRectTheme02993("SIDE_METERS", "Side Meters")
EAS_RegisterRectTheme02993("CENTER_CORE", "Center Core")
EAS_RegisterRectTheme02993("SLIM_LINES", "Slim Lines")

local EAS_WHITE_TEXTURE_02993 = "/esoui/art/miscellaneous/white.dds"

local function EAS_RectColorForBar02993(bar)
    local name = ""
    if bar and type(bar.GetName) == "function" then name = string.lower(tostring(bar:GetName() or "")) end
    if string.find(name, "magicka", 1, true) then return C.magicka end
    if string.find(name, "stamina", 1, true) then return C.stamina end
    return C.health
end

local function EAS_UpdateRectBarFill02993(bar, current, maximum)
    if not bar or not bar.epcRectFill then return end
    current, maximum = tonumber(current) or 0, tonumber(maximum) or 0
    bar.epcRectCurrent, bar.epcRectMaximum = current, maximum
    local ratio = maximum > 0 and math.max(0, math.min(1, current / maximum)) or 0
    if ratio <= 0 then
        bar.epcRectFill:SetHidden(true)
        return
    end
    bar.epcRectFill:SetHidden(false)
    local innerWidth = math.max(1, (tonumber(bar:GetWidth()) or 1) - 4)
    bar.epcRectFill:SetWidth(math.max(1, math.floor(innerWidth * ratio + 0.5)))
end

local function EAS_SeedRectValues02994(bar)
    if not bar then return end
    if (tonumber(bar.epcRectMaximum) or 0) > 0 then return end
    local fill = bar.epcFill or bar.epcFillLeft or bar.epcFillRight
    if not fill then return end
    local current, maximum = nil, nil
    if type(fill.GetValue) == "function" then
        local ok, value = pcall(fill.GetValue, fill)
        if ok then current = tonumber(value) end
    end
    if type(fill.GetMinMax) == "function" then
        local ok, minimum, maxValue = pcall(fill.GetMinMax, fill)
        if ok then maximum = tonumber(maxValue) end
    end
    if maximum and maximum > 0 then
        bar.epcRectCurrent = current or 0
        bar.epcRectMaximum = maximum
    end
end

local function EAS_EnsureRectBar02993(bar)
    if not bar then return end

    -- 0.29.94 restores a visible hard-edged resource shell. 0.29.93 removed
    -- the large frame/card backdrops correctly, but on a freshly-created bar
    -- the replacement textures could initialize before the current power value
    -- was cached, leaving only the text visible. A dedicated backdrop makes the
    -- resource rectangle and its border persistent while keeping the big panel
    -- background removed.
    if not bar.epcRectPanel02994 then
        local panel = wm:CreateControl(nil, bar, CT_BACKDROP)
        panel:SetAnchorFill(bar)
        panel:SetCenterColor(0.018, 0.022, 0.030, 0.90)
        panel:SetEdgeColor(0.62, 0.66, 0.74, 0.96)
        panel:SetEdgeTexture(nil, 1, 1, 1)
        panel:SetDrawLayer(DL_CONTROLS)
        panel:SetDrawLevel(20)
        bar.epcRectPanel02994 = panel
    end

    if not bar.epcRectFill then
        local fill = wm:CreateControl(nil, bar, CT_TEXTURE)
        fill:SetTexture(EAS_WHITE_TEXTURE_02993)
        local c = EAS_RectColorForBar02993(bar)
        fill:SetColor(c[1], c[2], c[3], c[4] or 1)
        fill:SetAnchor(TOPLEFT, bar, TOPLEFT, 2, 2)
        fill:SetAnchor(BOTTOMLEFT, bar, BOTTOMLEFT, 2, -2)
        fill:SetWidth(1)
        fill:SetDrawLayer(DL_CONTROLS)
        fill:SetDrawLevel(45)
        bar.epcRectFill = fill
    end

    -- Retire the old 0.29.93 texture shell if this SavedVariables session has
    -- already created it; the new backdrop provides the visible rectangle.
    if bar.epcRectBack then bar.epcRectBack:SetHidden(true) end
    for _, control in ipairs(bar.epcRectEdges or {}) do control:SetHidden(true) end

    -- Hide the ornate/tapered ESO pieces while preserving their status values.
    for _, list in ipairs({bar.epcBgPieces, bar.epcFramePieces, bar.epcGlossPieces, bar.epcFillPieces}) do
        for _, control in ipairs(list or {}) do if control then control:SetHidden(true) end end
    end
    if bar.epcFill then bar.epcFill:SetHidden(true) end
    if bar.epcGloss then bar.epcGloss:SetHidden(true) end

    bar.epcRectPanel02994:SetHidden(false)
    bar.epcRectFill:SetHidden(false)
    bar.epcRectFill:SetDrawLayer(DL_CONTROLS)
    bar.epcRectFill:SetDrawLevel(45)
    if bar.epcLabel then
        bar.epcLabel:SetDrawLayer(DL_OVERLAY)
        bar.epcLabel:SetDrawLevel(120)
    end

    EAS_SeedRectValues02994(bar)
    EAS_UpdateRectBarFill02993(bar, bar.epcRectCurrent or 0, bar.epcRectMaximum or 0)
end

-- Keep the rectangular fill synchronized with the mature resource updater.
local EAS_UpdateESOResourceBarBase02993 = updateESOResourceBar
updateESOResourceBar = function(bar, current, maximum)
    EAS_UpdateESOResourceBarBase02993(bar, current, maximum)
    if bar and (bar.epcRectFill or bar.epcRectPanel02994 or bar.epcRectBack) then EAS_UpdateRectBarFill02993(bar, current, maximum) end
end

local function EAS_RemoveFrameBackdrops02993(self)
    local function clearUnit(frame)
        if not frame then return end
        if frame.epcShadow then frame.epcShadow:SetHidden(true) end
        if frame.epcBackground then frame.epcBackground:SetHidden(true) end
        if frame.epcAccent then frame.epcAccent:SetHidden(true) end
        -- Keep a thin frame line so the design still has structure without
        -- restoring the large opaque card background.
        if not frame.epcStructureRule02994 then
            local rule = wm:CreateControl(nil, frame, CT_TEXTURE)
            rule:SetTexture(EAS_WHITE_TEXTURE_02993)
            rule:SetColor(0.62, 0.66, 0.74, 0.80)
            rule:SetAnchor(TOPLEFT, frame, TOPLEFT, 8, 35)
            rule:SetAnchor(TOPRIGHT, frame, TOPRIGHT, -8, 35)
            rule:SetHeight(1)
            rule:SetDrawLayer(DL_CONTROLS)
            rule:SetDrawLevel(25)
            frame.epcStructureRule02994 = rule
        end
        frame.epcStructureRule02994:SetHidden(false)
        for _, bar in pairs(frame.epcBars or {}) do EAS_EnsureRectBar02993(bar) end
    end
    local function clearRoster(frame)
        if not frame then return end
        if frame.epcBackground then frame.epcBackground:SetHidden(true) end
        if frame.epcAccent then frame.epcAccent:SetHidden(true) end
        for _, row in ipairs(frame.epcRows or {}) do
            -- Rows are parent controls, so make their backdrop transparent rather than hiding them.
            if row.SetCenterColor then row:SetCenterColor(0,0,0,0) end
            if row.SetEdgeColor then row:SetEdgeColor(0,0,0,0) end
            if row.epcAccent then row.epcAccent:SetHidden(true) end
            if row.epcBars then EAS_EnsureRectBar02993(row.epcBars.health) end
            if row.epcCompanionHealth and row.epcCompanionHealth ~= false then EAS_EnsureRectBar02993(row.epcCompanionHealth) end
        end
    end
    clearUnit(self.playerFrame)
    clearUnit(self.targetFrame)
    clearRoster(self.groupFrame)
    clearRoster(self.raidFrame)
end

local function EAS_SetRectBox02993(bar, parent, x, y, w, h)
    if not bar then return end
    bar:ClearAnchors()
    bar:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    bar:SetDimensions(math.max(28, w), math.max(8, h))
    EAS_EnsureRectBar02993(bar)
    EAS_UpdateRectBarFill02993(bar, bar.epcRectCurrent or 0, bar.epcRectMaximum or 0)
end

local function EAS_LayoutRectUnit02993(frame, buffCount, debuffCount, preview, design)
    if not frame then return end
    local isTarget = frame.epcKind == "target"
    -- Player Styles 6-10 are horizontally balanced as complete compositions:
    -- Stack/Slim fill equal side margins, Triple/Side center their full multi-bar
    -- group, and Center Core shares one center axis for all three resources.
    local cfg = {
        RECT_STACK =    {w=410, pad=10, aura=26, step=29, mode="STACK", header=38},
        TRIPLE_BLOCKS = {w=530, pad=10, aura=28, step=31, mode="TRIPLE", header=38},
        SIDE_METERS =   {w=500, pad=10, aura=28, step=31, mode="SIDE", header=38},
        CENTER_CORE =   {w=480, pad=12, aura=28, step=31, mode="CENTER", header=40},
        SLIM_LINES =    {w=470, pad=8,  aura=24, step=27, mode="SLIM", header=34},
    }
    cfg = cfg[design] or cfg.RECT_STACK
    local width = cfg.w
    if isTarget and design == "TRIPLE_BLOCKS" then width = 470 end
    frame:SetWidth(width)
    EAS_SizeAuraSlots02991(frame, cfg.aura, cfg.step)

    if frame.epcTitle then
        frame.epcTitle:ClearAnchors()
        frame.epcTitle:SetAnchor(TOPLEFT, frame, TOPLEFT, cfg.pad, 0)
        frame.epcTitle:SetDimensions(width - cfg.pad * 2, 20)
        frame.epcTitle:SetHorizontalAlignment(design == "SIDE_METERS" and TEXT_ALIGN_LEFT or TEXT_ALIGN_CENTER)
    end
    if frame.epcInfo then
        frame.epcInfo:ClearAnchors()
        if design == "SIDE_METERS" then
            frame.epcInfo:SetAnchor(TOPRIGHT, frame, TOPRIGHT, -cfg.pad, 0)
            frame.epcInfo:SetDimensions(math.floor(width * 0.38), 20)
            frame.epcInfo:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        else
            frame.epcInfo:SetAnchor(TOPLEFT, frame, TOPLEFT, cfg.pad, 19)
            frame.epcInfo:SetDimensions(width - cfg.pad * 2, 17)
            frame.epcInfo:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        end
    end

    local displayBuffs = tonumber(buffCount) or 0
    local displayDebuffs = tonumber(debuffCount) or 0
    if preview then displayBuffs, displayDebuffs = math.max(displayBuffs, 4), math.max(displayDebuffs, 3) end
    local perRow = math.max(1, math.floor((width - cfg.pad * 2) / cfg.step))
    local function position(slots, count, startY)
        for i, slot in ipairs(slots or {}) do
            slot:ClearAnchors()
            local r, c = math.floor((i - 1) / perRow), (i - 1) % perRow
            slot:SetAnchor(TOPLEFT, frame, TOPLEFT, cfg.pad + c * cfg.step, startY + r * cfg.step)
        end
        return count > 0 and math.ceil(count / perRow) or 0
    end

    local buffRows = position(frame.epcBuffSlots, displayBuffs, cfg.header)
    local y = cfg.header + buffRows * cfg.step + (buffRows > 0 and 4 or 0)
    local inner = width - cfg.pad * 2
    local health, magicka, stamina = frame.epcBars.health, frame.epcBars.magicka, frame.epcBars.stamina

    if isTarget then
        local healthW = design == "CENTER_CORE" and math.floor(inner * 0.78) or inner
        local healthX = design == "CENTER_CORE" and cfg.pad + math.floor((inner - healthW) / 2) or cfg.pad
        local healthH = design == "SLIM_LINES" and 20 or 22
        EAS_SetRectBox02993(health, frame, healthX, y, healthW, healthH)
        if magicka then magicka:SetHidden(true) end
        if stamina then stamina:SetHidden(true) end
        y = y + healthH + 4
    else
        magicka:SetHidden(false); stamina:SetHidden(false)
        if cfg.mode == "TRIPLE" then
            local gap = 6
            local healthW = math.floor(inner * 0.50)
            local rest = inner - healthW - gap * 2
            local resourceW = math.floor(rest / 2)
            EAS_SetRectBox02993(health, frame, cfg.pad, y, healthW, 24)
            EAS_SetRectBox02993(magicka, frame, cfg.pad + healthW + gap, y, resourceW, 24)
            EAS_SetRectBox02993(stamina, frame, cfg.pad + healthW + gap + resourceW + gap, y, rest - resourceW, 24)
            y = y + 28
        elseif cfg.mode == "SIDE" then
            local gap = 8
            local healthW = math.floor(inner * 0.66)
            local sideW = inner - healthW - gap
            EAS_SetRectBox02993(health, frame, cfg.pad, y, healthW, 28)
            EAS_SetRectBox02993(magicka, frame, cfg.pad + healthW + gap, y, sideW, 12)
            EAS_SetRectBox02993(stamina, frame, cfg.pad + healthW + gap, y + 16, sideW, 12)
            y = y + 32
        elseif cfg.mode == "CENTER" then
            local healthW = math.floor(inner * 0.82)
            local resourceW = math.floor(inner * 0.56)
            EAS_SetRectBox02993(health, frame, cfg.pad + math.floor((inner - healthW) / 2), y, healthW, 24)
            EAS_SetRectBox02993(magicka, frame, cfg.pad + math.floor((inner - resourceW) / 2), y + 28, resourceW, 14)
            EAS_SetRectBox02993(stamina, frame, cfg.pad + math.floor((inner - resourceW) / 2), y + 46, resourceW, 14)
            y = y + 64
        elseif cfg.mode == "SLIM" then
            -- Still compact, but tall enough for ESO's keyboard font so values
            -- never spill outside the resource rectangles.
            EAS_SetRectBox02993(health, frame, cfg.pad, y, inner, 20)
            EAS_SetRectBox02993(magicka, frame, cfg.pad, y + 24, inner, 18)
            EAS_SetRectBox02993(stamina, frame, cfg.pad, y + 46, inner, 18)
            y = y + 68
        else -- RECT_STACK
            EAS_SetRectBox02993(health, frame, cfg.pad, y, inner, 24)
            EAS_SetRectBox02993(magicka, frame, cfg.pad, y + 28, inner, 16)
            EAS_SetRectBox02993(stamina, frame, cfg.pad, y + 48, inner, 16)
            y = y + 68
        end
    end

    local debuffRows = position(frame.epcDebuffSlots, displayDebuffs, y)
    if debuffRows > 0 then y = y + debuffRows * cfg.step + 3 end
    frame:SetHeight(math.max(30, y))
end

-- Intercept the five new designs before the 0.29.91 layout fallback can treat
-- them as Tactical Grid. Existing five retain their geometry, but all ten get
-- the new square resource-bar treatment and background-free shell.
local EAS_LayoutIntegratedUnitFrameBase02993 = F.LayoutIntegratedUnitFrame
function F:LayoutIntegratedUnitFrame(frame, buffCount, debuffCount, preview)
    local design = EAS_GetUnitFrameDesign02991()
    if EAS_RECT_DESIGNS_02993[design] then
        EAS_LayoutRectUnit02993(frame, buffCount, debuffCount, preview, design)
    else
        EAS_LayoutIntegratedUnitFrameBase02993(self, frame, buffCount, debuffCount, preview)
        if frame and frame.epcBars then
            for _, bar in pairs(frame.epcBars) do EAS_EnsureRectBar02993(bar) end
        end
    end
    EAS_RemoveFrameBackdrops02993(self)
end

local function EAS_LayoutNewRoster02993(self, frame, design, raid)
    if not frame then return end
    local visible = {}
    for _, row in ipairs(frame.epcRows or {}) do if row and not row:IsHidden() then visible[#visible+1] = row end end

    local rowW, rowH, expandedH, columns, gap, top
    if design == "RECT_STACK" then
        rowW, rowH, expandedH, columns, gap = raid and 230 or 300, raid and 30 or 34, raid and 30 or 68, raid and 3 or 1, 5
    elseif design == "TRIPLE_BLOCKS" then
        rowW, rowH, expandedH, columns, gap = raid and 235 or 250, raid and 32 or 38, raid and 32 or 72, raid and 3 or 2, 7
    elseif design == "SIDE_METERS" then
        rowW, rowH, expandedH, columns, gap = raid and 315 or 390, raid and 34 or 40, raid and 34 or 74, raid and 2 or 1, 7
    elseif design == "CENTER_CORE" then
        rowW, rowH, expandedH, columns, gap = raid and 270 or 280, raid and 34 or 38, raid and 34 or 72, raid and 3 or 2, 6
    else -- SLIM_LINES
        rowW, rowH, expandedH, columns, gap = raid and 235 or 300, raid and 34 or 36, raid and 34 or 70, raid and 4 or 1, 5
    end
    columns = math.max(1, math.min(columns, math.max(1, #visible)))
    top = raid and 29 or 7

    for _, row in ipairs(frame.epcRows or {}) do
        EAS_LayoutRosterRow02991(row, rowW, rowH, expandedH, design)
        if row.epcBars and row.epcBars.health then
            local h = design == "SLIM_LINES" and 16 or (design == "SIDE_METERS" and 16 or 14)
            row.epcBars.health:SetHeight(h)
            EAS_EnsureRectBar02993(row.epcBars.health)
        end
        if row.epcCompanionHealth and row.epcCompanionHealth ~= false then EAS_EnsureRectBar02993(row.epcCompanionHealth) end
    end

    for i, row in ipairs(visible) do
        local col, r = (i - 1) % columns, math.floor((i - 1) / columns)
        row:ClearAnchors()
        local stepH = raid and rowH or expandedH
        row:SetAnchor(TOPLEFT, frame, TOPLEFT, 8 + col * (rowW + gap), top + r * (stepH + gap))
    end
    local rows = math.max(1, math.ceil(math.max(1, #visible) / columns))
    local stepH = raid and rowH or expandedH
    frame:SetDimensions(16 + columns * rowW + (columns - 1) * gap, top + rows * stepH + (rows - 1) * gap + 7)
end

local EAS_RefreshGroupFramesBase02993 = F.RefreshGroupFrames
function F:RefreshGroupFrames()
    EAS_RefreshGroupFramesBase02993(self)
    local design = EAS_GetUnitFrameDesign02991()
    if EAS_RECT_DESIGNS_02993[design] then
        EAS_LayoutNewRoster02993(self, self.groupFrame, design, false)
        EAS_LayoutNewRoster02993(self, self.raidFrame, design, true)
    end
    EAS_RemoveFrameBackdrops02993(self)
end

local EAS_ApplyVisualStyleBase02993 = F.ApplyVisualStyle
function F:ApplyVisualStyle()
    EAS_ApplyVisualStyleBase02993(self)
    EAS_RemoveFrameBackdrops02993(self)
end


-- ============================================================================
-- v0.29.95 - Strict 1-5 original / 6-10 rectangular design split.
-- Styles 1-5 restore the original Suite/ESO-shaped resource artwork and frame
-- treatment from v0.29.91. Styles 6-10 alone use the hard-edged rectangle
-- renderer. Rectangle fills are synchronized from both resource-bar update
-- paths and by a lightweight live resource tick. Player identity text is hidden
-- for every design; the Player frame is resources/effects only.
-- ============================================================================
local function EAS_IsRectDesign02995(design)
    return EAS_RECT_DESIGNS_02993[design] == true
end

local function EAS_RestoreOriginalBar02995(bar)
    if not bar then return end

    -- Hide the v0.29.93/94 replacement shell without destroying it. This lets
    -- the user switch back to Styles 6-10 live without recreating controls.
    if bar.epcRectPanel02994 then bar.epcRectPanel02994:SetHidden(true) end
    if bar.epcRectFill then bar.epcRectFill:SetHidden(true) end
    if bar.epcRectBack then bar.epcRectBack:SetHidden(true) end
    for _, control in ipairs(bar.epcRectEdges or {}) do
        if control then control:SetHidden(true) end
    end

    -- Restore the exact original shaped ESO bar pieces used by Styles 1-5.
    for _, list in ipairs({bar.epcBgPieces, bar.epcFramePieces, bar.epcGlossPieces, bar.epcFillPieces}) do
        for _, control in ipairs(list or {}) do
            if control then control:SetHidden(false) end
        end
    end
    if bar.epcFill then bar.epcFill:SetHidden(false) end
    if bar.epcGloss then bar.epcGloss:SetHidden(false) end
end

local function EAS_RestoreOriginalDesignVisuals02995(self)
    if not self then return end

    local function restoreUnit(frame)
        if not frame then return end
        if frame.epcStructureRule02994 then frame.epcStructureRule02994:SetHidden(true) end
        for _, bar in pairs(frame.epcBars or {}) do EAS_RestoreOriginalBar02995(bar) end
    end

    local function restoreRoster(frame)
        if not frame then return end
        if frame.epcStructureRule02994 then frame.epcStructureRule02994:SetHidden(true) end
        for _, row in ipairs(frame.epcRows or {}) do
            if row.epcAccent then row.epcAccent:SetHidden(false) end
            if row.epcBars then EAS_RestoreOriginalBar02995(row.epcBars.health) end
            if row.epcCompanionHealth and row.epcCompanionHealth ~= false then
                EAS_RestoreOriginalBar02995(row.epcCompanionHealth)
            end
        end
    end

    restoreUnit(self.playerFrame)
    restoreUnit(self.targetFrame)
    restoreRoster(self.groupFrame)
    restoreRoster(self.raidFrame)

    -- Reapply the v0.29.90/91 original treatment after v0.29.93 temporarily
    -- made the roster/backdrops transparent during its compatibility wrapper.
    if type(self.ApplyUnitFrameVisualTheme02990) == "function" then
        self:ApplyUnitFrameVisualTheme02990()
    end
end

-- Record current values regardless of whether the rectangle controls happened
-- to exist at the instant ESO delivered the resource event.
local EAS_UpdateESOResourceBarBase02995 = updateESOResourceBar
updateESOResourceBar = function(bar, current, maximum)
    if bar then
        bar.epcRectCurrent = tonumber(current) or 0
        bar.epcRectMaximum = tonumber(maximum) or 0
    end
    EAS_UpdateESOResourceBarBase02995(bar, current, maximum)
    if bar and bar.epcRectFill then
        EAS_UpdateRectBarFill02993(bar, current, maximum)
    end
end

-- Group/Raid bars use the legacy fill-bar updater rather than the Player/Target
-- ESO resource updater. Hook it too so their visible rectangular health fills
-- actually deplete and regenerate in Styles 6-10.
local EAS_UpdateFillBarBase02995 = updateFillBar
updateFillBar = function(bar, current, maximum, prefix)
    EAS_UpdateFillBarBase02995(bar, current, maximum, prefix)
    if bar then
        bar.epcRectCurrent = tonumber(current) or 0
        bar.epcRectMaximum = tonumber(maximum) or 0
        if bar.epcRectFill then EAS_UpdateRectBarFill02993(bar, current, maximum) end
    end
end

-- Restore original artwork after the v0.29.93 compatibility layer has run for
-- Styles 1-5. Styles 6-10 intentionally retain the rectangle renderer.
local EAS_LayoutIntegratedUnitFrameBase02995 = F.LayoutIntegratedUnitFrame
function F:LayoutIntegratedUnitFrame(frame, buffCount, debuffCount, preview)
    EAS_LayoutIntegratedUnitFrameBase02995(self, frame, buffCount, debuffCount, preview)
    local design = EAS_GetUnitFrameDesign02991()
    if not EAS_IsRectDesign02995(design) then
        EAS_RestoreOriginalDesignVisuals02995(self)
    end

    if frame and frame.epcKind == "player" then
        if frame.epcTitle then frame.epcTitle:SetHidden(true) end
        if frame.epcInfo then frame.epcInfo:SetHidden(true) end
    end

    -- Slim Lines is percentage-only so the text fits comfortably inside its
    -- compact rectangular bars. Other Player/Target designs keep full values.
    if frame and frame.epcBars then
        local slim = design == "SLIM_LINES"
        for _, bar in pairs(frame.epcBars) do
            if bar then bar.epcTextMode = slim and "PERCENT" or "FULL" end
        end
    end
end

local EAS_RefreshGroupFramesBase02995 = F.RefreshGroupFrames
function F:RefreshGroupFrames()
    EAS_RefreshGroupFramesBase02995(self)
    local design = EAS_GetUnitFrameDesign02991()
    if not EAS_IsRectDesign02995(design) then
        EAS_RestoreOriginalDesignVisuals02995(self)
    end
end

local EAS_ApplyVisualStyleBase02995 = F.ApplyVisualStyle
function F:ApplyVisualStyle()
    EAS_ApplyVisualStyleBase02995(self)
    local design = EAS_GetUnitFrameDesign02991()
    if EAS_IsRectDesign02995(design) then
        EAS_RemoveFrameBackdrops02993(self)
    else
        EAS_RestoreOriginalDesignVisuals02995(self)
    end
end

-- Player frame never needs character name, level, or CP. Keep only resources
-- and effects no matter which of the ten visual designs is selected.
local EAS_UpdateUnitFrameBase02995 = F.UpdateUnitFrame
function F:UpdateUnitFrame(frame, unitTag, preview)
    local ok = EAS_UpdateUnitFrameBase02995(self, frame, unitTag, preview)
    if ok and frame and frame.epcKind == "player" then
        if frame.epcTitle then frame.epcTitle:SetHidden(true) frame.epcTitle:SetText("") end
        if frame.epcInfo then frame.epcInfo:SetHidden(true) frame.epcInfo:SetText("") end
    end
    return ok
end

-- Lightweight live sync makes the visible rectangle itself move with power,
-- independently of ESO's original hidden bar artwork. This also covers cases
-- where resource events are coalesced while the HUD is transitioning.
function F:RefreshRectResourceFills02995()
    local design = EAS_GetUnitFrameDesign02991()
    if not EAS_IsRectDesign02995(design) then return end

    local function syncUnit(frame, unitTag, includeResources)
        if not frame or frame:IsHidden() then return end
        if safe(DoesUnitExist, false, unitTag) ~= true and self.layoutMode ~= true then return end

        local hp, hpMax = readPower(unitTag, POWER_HEALTH)
        if self.layoutMode and hpMax <= 0 then hp, hpMax = 76000, 100000 end
        if frame.epcBars and frame.epcBars.health then updateESOResourceBar(frame.epcBars.health, hp, hpMax) end

        if includeResources and frame.epcBars then
            local mag, magMax = readPower(unitTag, POWER_MAGICKA)
            local stam, stamMax = readPower(unitTag, POWER_STAMINA)
            if self.layoutMode then
                if magMax <= 0 then mag, magMax = 28000, 40000 end
                if stamMax <= 0 then stam, stamMax = 21000, 30000 end
            end
            if frame.epcBars.magicka then updateESOResourceBar(frame.epcBars.magicka, mag, magMax) end
            if frame.epcBars.stamina then updateESOResourceBar(frame.epcBars.stamina, stam, stamMax) end
        end
    end

    syncUnit(self.playerFrame, "player", true)
    syncUnit(self.targetFrame, "reticleover", false)

    local function syncRoster(frame)
        if not frame or frame:IsHidden() then return end
        for _, row in ipairs(frame.epcRows or {}) do
            local unitTag = row and row.epcUnitTag
            if row and not row:IsHidden() and unitTag and safe(DoesUnitExist, false, unitTag) == true then
                local hp, hpMax = readPower(unitTag, POWER_HEALTH)
                if row.epcBars and row.epcBars.health then
                    updateFillBar(row.epcBars.health, hp, hpMax, "")
                end
            end
        end
    end

    syncRoster(self.groupFrame)
    syncRoster(self.raidFrame)
end

local EAS_InitializeBase02995 = F.Initialize
function F:Initialize()
    EAS_InitializeBase02995(self)
    local key = (EPC.name or "ESOAdventurerSuite") .. "_RectResourceLive02995"
    EVENT_MANAGER:UnregisterForUpdate(key)
    EVENT_MANAGER:RegisterForUpdate(key, 4000, function()
        local frames = EPC.UnitFrames
        if not frames or not EPC.saved or not EAS_IsRectDesign02995(EAS_GetUnitFrameDesign02991()) then return end
        local visible = frames.layoutMode == true
            or (frames.playerFrame and not frames.playerFrame:IsHidden())
            or (frames.targetFrame and not frames.targetFrame:IsHidden())
            or (frames.groupFrame and not frames.groupFrame:IsHidden())
            or (frames.raidFrame and not frames.raidFrame:IsHidden())
        if visible then frames:RefreshRectResourceFills02995() end
    end)

    -- Ensure an old v0.29.93/94 session cannot leave Styles 1-5 in rectangle
    -- mode after upgrading.
    local design = EAS_GetUnitFrameDesign02991()
    if not EAS_IsRectDesign02995(design) then EAS_RestoreOriginalDesignVisuals02995(self) end
    self:RefreshAll(true)
end

-- ============================================================================
-- v0.29.96 - Clean split: Styles 1-5 original geometry without card panels;
-- Styles 6-10 vivid rectangular resources with fitted text and live fill.
-- ============================================================================
local EAS_RECT_COLORS_02996 = {
    health  = {0.88, 0.10, 0.14, 1.00},
    magicka = {0.10, 0.42, 0.96, 1.00},
    stamina = {0.10, 0.72, 0.28, 1.00},
}

local function EAS_RectColor02996(bar)
    local name = ""
    if bar and type(bar.GetName) == "function" then name = string.lower(tostring(bar:GetName() or "")) end
    if string.find(name, "magicka", 1, true) then return EAS_RECT_COLORS_02996.magicka end
    if string.find(name, "stamina", 1, true) then return EAS_RECT_COLORS_02996.stamina end
    return EAS_RECT_COLORS_02996.health
end

local function EAS_HideCardBackdrops02996(self)
    if not self then return end
    local function hideUnit(frame)
        if not frame then return end
        if frame.epcShadow then frame.epcShadow:SetHidden(true) end
        if frame.epcBackground then frame.epcBackground:SetHidden(true) end
        -- Keep the small accent/structure treatment from the original design,
        -- but never restore the large opaque card panel.
        if frame.epcStructureRule02994 then frame.epcStructureRule02994:SetHidden(true) end
    end
    local function hideRoster(frame)
        if not frame then return end
        if frame.epcBackground then frame.epcBackground:SetHidden(true) end
        -- Group/Raid rows should not look like individual cards. Keep role/
        -- leader accent strips, but make the row backdrop itself transparent.
        for _, row in ipairs(frame.epcRows or {}) do
            if row then
                if row.SetCenterColor then row:SetCenterColor(0, 0, 0, 0) end
                if row.SetEdgeColor then row:SetEdgeColor(0, 0, 0, 0) end
            end
        end
    end
    hideUnit(self.playerFrame)
    hideUnit(self.targetFrame)
    hideRoster(self.groupFrame)
    hideRoster(self.raidFrame)
end

local function EAS_FitRectLabel02996(bar, current, maximum)
    if not bar or not bar.epcLabel then return end
    local label = bar.epcLabel
    local w = math.max(1, tonumber(bar:GetWidth()) or 1)
    local h = math.max(1, tonumber(bar:GetHeight()) or 1)

    label:ClearAnchors()
    label:SetAnchor(TOPLEFT, bar, TOPLEFT, 4, 1)
    label:SetAnchor(BOTTOMRIGHT, bar, BOTTOMRIGHT, -4, -1)
    if label.SetHorizontalAlignment then label:SetHorizontalAlignment(TEXT_ALIGN_CENTER) end
    if label.SetVerticalAlignment then label:SetVerticalAlignment(TEXT_ALIGN_CENTER) end
    if label.SetWrapMode and TEXT_WRAP_MODE_ELLIPSIS then label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) end
    if label.SetMaxLineCount then label:SetMaxLineCount(1) end
    if label.SetDrawTier then label:SetDrawTier(DT_HIGH) end
    if label.SetDrawLayer then label:SetDrawLayer(DL_OVERLAY) end
    if label.SetDrawLevel then label:SetDrawLevel(220) end

    -- Use a smaller font for the short resource blocks. This is especially
    -- important for Triple Blocks / Side Meters / Slim Lines.
    if h <= 14 then
        label:SetFont("$(BOLD_FONT)|13|soft-shadow-thin")
    elseif h <= 18 then
        label:SetFont("$(BOLD_FONT)|14|soft-shadow-thin")
    else
        label:SetFont("ZoFontGameSmall")
    end

    current, maximum = tonumber(current) or 0, tonumber(maximum) or 0
    local design = EAS_GetUnitFrameDesign02991()
    local text
    if maximum <= 0 then
        text = "--"
    elseif design == "SLIM_LINES" or w < 165 or h <= 14 then
        text = percentText(current, maximum)
    elseif w < 245 then
        text = compactNumber(current) .. "  " .. percentText(current, maximum)
    else
        text = compactNumber(current) .. " / " .. compactNumber(maximum) .. "  " .. percentText(current, maximum)
    end
    label:SetText(text)
end

local function EAS_UpdateRectVisual02996(bar, current, maximum)
    if not bar then return end
    local design = EAS_GetUnitFrameDesign02991()
    if not EAS_IsRectDesign02995(design) then return end

    EAS_EnsureRectBar02993(bar)
    current, maximum = tonumber(current) or 0, tonumber(maximum) or 0
    bar.epcRectCurrent, bar.epcRectMaximum = current, maximum

    if bar.epcRectPanel02994 then
        bar.epcRectPanel02994:SetHidden(false)
        bar.epcRectPanel02994:SetCenterColor(0.012, 0.014, 0.020, 0.92)
        bar.epcRectPanel02994:SetEdgeColor(0.72, 0.74, 0.80, 0.96)
        bar.epcRectPanel02994:SetDrawLayer(DL_CONTROLS)
        bar.epcRectPanel02994:SetDrawLevel(15)
    end

    if bar.epcRectFill then
        local c = EAS_RectColor02996(bar)
        bar.epcRectFill:SetTexture(EAS_WHITE_TEXTURE_02993)
        bar.epcRectFill:SetColor(c[1], c[2], c[3], c[4])
        bar.epcRectFill:SetDrawTier(DT_MEDIUM)
        bar.epcRectFill:SetDrawLayer(DL_CONTROLS)
        bar.epcRectFill:SetDrawLevel(70)

        local ratio = maximum > 0 and math.max(0, math.min(1, current / maximum)) or 0
        if ratio <= 0 then
            bar.epcRectFill:SetHidden(true)
        else
            bar.epcRectFill:SetHidden(false)
            bar.epcRectFill:ClearAnchors()
            bar.epcRectFill:SetAnchor(TOPLEFT, bar, TOPLEFT, 2, 2)
            bar.epcRectFill:SetAnchor(BOTTOMLEFT, bar, BOTTOMLEFT, 2, -2)
            local innerWidth = math.max(1, (tonumber(bar:GetWidth()) or 1) - 4)
            bar.epcRectFill:SetWidth(math.max(1, math.floor(innerWidth * ratio + 0.5)))
        end
    end

    EAS_FitRectLabel02996(bar, current, maximum)
end

-- Final resource hooks: keep the visible rectangle synchronized with the actual
-- current/max values after every native update. These wrappers sit after the
-- older compatibility layers, so they drive the controls the player sees.
local EAS_UpdateESOResourceBarBase02996 = updateESOResourceBar
updateESOResourceBar = function(bar, current, maximum)
    EAS_UpdateESOResourceBarBase02996(bar, current, maximum)
    if bar then EAS_UpdateRectVisual02996(bar, current, maximum) end
end

local EAS_UpdateFillBarBase02996 = updateFillBar
updateFillBar = function(bar, current, maximum, prefix)
    EAS_UpdateFillBarBase02996(bar, current, maximum, prefix)
    if bar then EAS_UpdateRectVisual02996(bar, current, maximum) end
end

local function EAS_ApplyDesignPolicy02996(self, force)
    local design = EAS_GetUnitFrameDesign02991()
    -- v0.29.342: do not cache backdrop cleanup by design. Older compatibility
    -- layers can legitimately touch roster/card colors during a layout refresh;
    -- the final cleanup must always run after those non-hot-path operations.
    if EAS_IsRectDesign02995(design) then
        -- Styles 6-10: no surrounding cards, but keep strong rectangular
        -- resource shells/fills and fitted labels.
        EAS_RemoveFrameBackdrops02993(self)
        local function refreshBars(frame)
            if not frame then return end
            for _, bar in pairs(frame.epcBars or {}) do
                EAS_UpdateRectVisual02996(bar, bar.epcRectCurrent or 0, bar.epcRectMaximum or 0)
            end
        end
        refreshBars(self.playerFrame)
        refreshBars(self.targetFrame)
        for _, roster in ipairs({self.groupFrame, self.raidFrame}) do
            if roster then
                for _, row in ipairs(roster.epcRows or {}) do
                    if row and row.epcBars and row.epcBars.health then
                        local b = row.epcBars.health
                        EAS_UpdateRectVisual02996(b, b.epcRectCurrent or 0, b.epcRectMaximum or 0)
                    end
                    if row and row.epcCompanionHealth and row.epcCompanionHealth ~= false then
                        local b = row.epcCompanionHealth
                        EAS_UpdateRectVisual02996(b, b.epcRectCurrent or 0, b.epcRectMaximum or 0)
                    end
                end
            end
        end
    else
        -- Styles 1-5: retain original Suite/ESO bar artwork and geometry, but
        -- strip only the large card/backdrop surfaces.
        EAS_RestoreOriginalDesignVisuals02995(self)
        EAS_HideCardBackdrops02996(self)
    end

    -- Player identity is intentionally omitted in every design.
    if self.playerFrame then
        if self.playerFrame.epcTitle then self.playerFrame.epcTitle:SetHidden(true) self.playerFrame.epcTitle:SetText("") end
        if self.playerFrame.epcInfo then self.playerFrame.epcInfo:SetHidden(true) self.playerFrame.epcInfo:SetText("") end
    end
end

local EAS_LayoutIntegratedUnitFrameBase02996 = F.LayoutIntegratedUnitFrame
function F:LayoutIntegratedUnitFrame(frame, buffCount, debuffCount, preview)
    EAS_LayoutIntegratedUnitFrameBase02996(self, frame, buffCount, debuffCount, preview)
    EAS_ApplyDesignPolicy02996(self, false)
end

local EAS_RefreshGroupFramesBase02996 = F.RefreshGroupFrames
function F:RefreshGroupFrames()
    EAS_RefreshGroupFramesBase02996(self)
    EAS_ApplyDesignPolicy02996(self, true)
end

local EAS_ApplyVisualStyleBase02996 = F.ApplyVisualStyle
function F:ApplyVisualStyle()
    EAS_ApplyVisualStyleBase02996(self)
    EAS_ApplyDesignPolicy02996(self, true)
end

local EAS_UpdateUnitFrameBase02996 = F.UpdateUnitFrame
function F:UpdateUnitFrame(frame, unitTag, preview)
    -- v0.29.341: value changes do not require a full all-frame design pass.
    -- Styling is applied on layout/style/roster changes, while the bar update
    -- helpers below repaint only the resource that actually changed.
    return EAS_UpdateUnitFrameBase02996(self, frame, unitTag, preview)
end

-- The 0.29.95 live tick already reads real Player/Target/Group/Raid power.
-- Add a final visual pass so Styles 6-10 always repaint the currently-visible
-- colored width/text after those values are refreshed.
local EAS_RefreshRectResourceFillsBase02996 = F.RefreshRectResourceFills02995
function F:RefreshRectResourceFills02995()
    -- v0.29.341: the final 0.29.97 renderer below owns the single repaint pass.
    return EAS_RefreshRectResourceFillsBase02996(self)
end

-- ============================================================================
-- v0.29.97 - Unit-frame cleanup and reliable live rectangular color fills.
-- Styles 1-5 keep their original resource artwork but remove all detached
-- card/accent decoration and enforce safe gaps between Player resource bars.
-- Styles 6-10 use a dark resource-tinted track plus a vivid live fill whose
-- width follows current/max Health, Magicka and Stamina values.
-- ============================================================================
local EAS_RESOURCE_COLORS_02997 = {
    health  = {0.92, 0.10, 0.13, 1.00},
    magicka = {0.08, 0.42, 1.00, 1.00},
    stamina = {0.08, 0.78, 0.25, 1.00},
}

local function EAS_TagBar02997(bar, kind)
    if bar then bar.epcResourceKind02997 = kind end
end

local function EAS_TagFrameBars02997(self)
    if not self then return end
    local function tagUnit(frame)
        if not frame or not frame.epcBars then return end
        EAS_TagBar02997(frame.epcBars.health, "health")
        EAS_TagBar02997(frame.epcBars.magicka, "magicka")
        EAS_TagBar02997(frame.epcBars.stamina, "stamina")
    end
    tagUnit(self.playerFrame)
    tagUnit(self.targetFrame)
    for _, roster in ipairs({self.groupFrame, self.raidFrame}) do
        if roster then
            for _, row in ipairs(roster.epcRows or {}) do
                if row and row.epcBars then EAS_TagBar02997(row.epcBars.health, "health") end
                if row and row.epcCompanionHealth and row.epcCompanionHealth ~= false then
                    EAS_TagBar02997(row.epcCompanionHealth, "health")
                end
            end
        end
    end
end

local function EAS_ColorForRectBar02997(bar)
    local kind = bar and bar.epcResourceKind02997 or nil
    if kind and EAS_RESOURCE_COLORS_02997[kind] then return EAS_RESOURCE_COLORS_02997[kind] end
    local name = ""
    if bar and type(bar.GetName) == "function" then name = string.lower(tostring(bar:GetName() or "")) end
    if string.find(name, "magicka", 1, true) then return EAS_RESOURCE_COLORS_02997.magicka end
    if string.find(name, "stamina", 1, true) then return EAS_RESOURCE_COLORS_02997.stamina end
    return EAS_RESOURCE_COLORS_02997.health
end

local function EAS_ForceRectFill02997(bar, current, maximum)
    if not bar or not EAS_IsRectDesign02995(EAS_GetUnitFrameDesign02991()) then return end
    EAS_EnsureRectBar02993(bar)

    current = tonumber(current)
    maximum = tonumber(maximum)
    if (not maximum or maximum <= 0) and bar.epcFill then
        if type(bar.epcFill.GetValue) == "function" then
            local ok, value = pcall(bar.epcFill.GetValue, bar.epcFill)
            if ok and value ~= nil then current = tonumber(value) or current end
        end
        if type(bar.epcFill.GetMinMax) == "function" then
            local ok, _, maxValue = pcall(bar.epcFill.GetMinMax, bar.epcFill)
            if ok and maxValue ~= nil then maximum = tonumber(maxValue) or maximum end
        end
    end
    current, maximum = tonumber(current) or 0, tonumber(maximum) or 0
    bar.epcRectCurrent, bar.epcRectMaximum = current, maximum

    local c = EAS_ColorForRectBar02997(bar)
    if bar.epcRectPanel02994 then
        bar.epcRectPanel02994:SetHidden(false)
        if bar.epcRectPanel02994.SetDrawTier then bar.epcRectPanel02994:SetDrawTier(DT_MEDIUM) end
        bar.epcRectPanel02994:SetDrawLayer(DL_CONTROLS)
        bar.epcRectPanel02994:SetDrawLevel(10)
        -- A very dark tint preserves the resource identity even when depleted,
        -- while the bright child fill still makes depletion obvious.
        bar.epcRectPanel02994:SetCenterColor(c[1] * 0.12, c[2] * 0.12, c[3] * 0.12, 0.96)
        bar.epcRectPanel02994:SetEdgeColor(c[1] * 0.72 + 0.18, c[2] * 0.72 + 0.18, c[3] * 0.72 + 0.18, 1.00)
    end

    if bar.epcRectFill then
        local ratio = maximum > 0 and math.max(0, math.min(1, current / maximum)) or 0
        bar.epcRectFill:SetTexture(EAS_WHITE_TEXTURE_02993)
        bar.epcRectFill:SetColor(c[1], c[2], c[3], 1.00)
        bar.epcRectFill:SetAlpha(1.00)
        if bar.epcRectFill.SetDrawTier then bar.epcRectFill:SetDrawTier(DT_HIGH) end
        bar.epcRectFill:SetDrawLayer(DL_CONTROLS)
        bar.epcRectFill:SetDrawLevel(95)
        bar.epcRectFill:ClearAnchors()
        bar.epcRectFill:SetAnchor(TOPLEFT, bar, TOPLEFT, 2, 2)
        bar.epcRectFill:SetAnchor(BOTTOMLEFT, bar, BOTTOMLEFT, 2, -2)
        local innerWidth = math.max(1, (tonumber(bar:GetWidth()) or 1) - 4)
        bar.epcRectFill:SetWidth(math.max(1, math.floor(innerWidth * ratio + 0.5)))
        bar.epcRectFill:SetHidden(ratio <= 0)
    end

    if bar.epcLabel then
        bar.epcLabel:SetColor(1, 1, 1, 1)
        if bar.epcLabel.SetDrawTier then bar.epcLabel:SetDrawTier(DT_HIGH) end
        bar.epcLabel:SetDrawLayer(DL_OVERLAY)
        bar.epcLabel:SetDrawLevel(230)
        EAS_FitRectLabel02996(bar, current, maximum)
    end
end

local function EAS_HideOriginalFloatingDecor02997(self)
    if not self then return end
    local function cleanUnit(frame)
        if not frame then return end
        if frame.epcShadow then frame.epcShadow:SetHidden(true) end
        if frame.epcBackground then frame.epcBackground:SetHidden(true) end
        if frame.epcAccent then frame.epcAccent:SetHidden(true) end
        if frame.epcStructureRule02994 then frame.epcStructureRule02994:SetHidden(true) end
    end
    local function cleanRoster(frame)
        if not frame then return end
        if frame.epcBackground then frame.epcBackground:SetHidden(true) end
        if frame.epcAccent then frame.epcAccent:SetHidden(true) end
        if frame.epcStructureRule02994 then frame.epcStructureRule02994:SetHidden(true) end
        for _, row in ipairs(frame.epcRows or {}) do
            if row then
                if row.SetCenterColor then row:SetCenterColor(0, 0, 0, 0) end
                if row.SetEdgeColor then row:SetEdgeColor(0, 0, 0, 0) end
                if row.epcAccent then row.epcAccent:SetHidden(true) end
            end
        end
    end
    cleanUnit(self.playerFrame)
    cleanUnit(self.targetFrame)
    cleanRoster(self.groupFrame)
    cleanRoster(self.raidFrame)
end

local function EAS_LocalTop02997(control, parent, fallback)
    if not control or not parent then return fallback or 0 end
    local ok1, top = pcall(control.GetTop, control)
    local ok2, parentTop = pcall(parent.GetTop, parent)
    top, parentTop = tonumber(top), tonumber(parentTop)
    if ok1 and ok2 and top and parentTop then return top - parentTop end
    return fallback or 0
end

local function EAS_ReanchorOriginalBar02997(bar, parent, x, y, w)
    if not bar or not parent then return end
    bar:ClearAnchors()
    bar:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    bar:SetDimensions(math.max(80, w), 23)
end

local function EAS_SpaceOriginalPlayerBars02997(frame, design)
    if not frame or frame.epcKind ~= "player" or not frame.epcBars then return end
    local health, magicka, stamina = frame.epcBars.health, frame.epcBars.magicka, frame.epcBars.stamina
    if not health or not magicka or not stamina then return end

    local frameW = math.max(220, tonumber(frame:GetWidth()) or 420)
    local healthY = EAS_LocalTop02997(health, frame, 0)
    local magYNow = EAS_LocalTop02997(magicka, frame, healthY + 31)
    local resourceY = math.max(magYNow, healthY + 31)

    -- Native ESO resource artwork is 23px tall. Eight pixels of real space
    -- prevents the left/right frame caps from visually colliding.
    local verticalStep = 31

    local function localLeft(control, fallback)
        local okL, left = pcall(control.GetLeft, control)
        local okPL, parentLeft = pcall(frame.GetLeft, frame)
        if okL and okPL and tonumber(left) and tonumber(parentLeft) then
            return tonumber(left) - tonumber(parentLeft)
        end
        return fallback or 0
    end

    local function controlWidth(control, fallback)
        local okW, currentW = pcall(control.GetWidth, control)
        if okW and tonumber(currentW) and tonumber(currentW) > 80 then
            return tonumber(currentW)
        end
        return fallback or 80
    end

    local healthX = localLeft(health, 8)
    local healthW = controlWidth(health, frameW - 16)

    if design == "ESO_CLASSIC" or design == "COMPACT_STACK" then
        -- Styles 1-2: all three native resource bars use the exact same left
        -- edge and width, so the stack reads as one centered, even column.
        EAS_ReanchorOriginalBar02997(health,  frame, healthX, healthY,   healthW)
        EAS_ReanchorOriginalBar02997(magicka, frame, healthX, resourceY, healthW)
        EAS_ReanchorOriginalBar02997(stamina, frame, healthX, resourceY + verticalStep, healthW)
        frame:SetHeight(math.max(tonumber(frame:GetHeight()) or 0, resourceY + verticalStep + 25))

    elseif design == "SPLIT_RESOURCES" or design == "TACTICAL_GRID" then
        -- Styles 3 and 5: mirror Style 9 / Center Core. Health is the wider
        -- centered bar; Magicka and Stamina are narrower centered bars stacked
        -- beneath it on the same center axis.
        local pad = design == "TACTICAL_GRID" and 8 or 10
        local inner = math.max(180, frameW - (pad * 2))
        local centeredHealthW = math.max(120, math.floor(inner * 0.82))
        local centeredResourceW = math.max(100, math.floor(inner * 0.56))
        local centeredHealthX = math.floor((frameW - centeredHealthW) / 2)
        local centeredResourceX = math.floor((frameW - centeredResourceW) / 2)

        EAS_ReanchorOriginalBar02997(health,  frame, centeredHealthX,   healthY, centeredHealthW)
        EAS_ReanchorOriginalBar02997(magicka, frame, centeredResourceX, resourceY, centeredResourceW)
        EAS_ReanchorOriginalBar02997(stamina, frame, centeredResourceX, resourceY + verticalStep, centeredResourceW)
        frame:SetHeight(math.max(tonumber(frame:GetHeight()) or 0, resourceY + verticalStep + 25))

    elseif design == "WIDE_PLATE" then
        -- Style 4: preserve the Wide Plate sizes, but center both lower bars
        -- directly beneath the actual Health bar instead of the frame bounds.
        local resourceW = controlWidth(magicka, math.max(100, frameW - 190))
        resourceW = math.min(resourceW, healthW)
        local resourceX = math.floor(healthX + ((healthW - resourceW) / 2))

        EAS_ReanchorOriginalBar02997(magicka, frame, resourceX, resourceY, resourceW)
        EAS_ReanchorOriginalBar02997(stamina, frame, resourceX, resourceY + verticalStep, resourceW)
        frame:SetHeight(math.max(tonumber(frame:GetHeight()) or 0, resourceY + verticalStep + 25))

    else
        -- Fallback for any legacy/custom native style not covered above.
        local xMag = localLeft(magicka, 8)
        local wMag = controlWidth(magicka, frameW - 16)
        EAS_ReanchorOriginalBar02997(magicka, frame, xMag, resourceY, wMag)
        EAS_ReanchorOriginalBar02997(stamina, frame, xMag, resourceY + verticalStep, wMag)
        frame:SetHeight(math.max(tonumber(frame:GetHeight()) or 0, resourceY + verticalStep + 25))
    end
end

local function EAS_FinalUnitFramePolicy02997(self, allowPlayerSpacing, force)
    local design = EAS_GetUnitFrameDesign02991()
    -- v0.29.342: always finish layout/style/roster refreshes with the final
    -- visual cleanup. The 0.29.341 UpdateUnitFrame hot path still bypasses this
    -- global pass, so live power events remain lightweight.
    EAS_TagFrameBars02997(self)

    if EAS_IsRectDesign02995(design) then
        local function paintUnit(frame)
            if not frame then return end
            for kind, bar in pairs(frame.epcBars or {}) do
                if bar then
                    EAS_TagBar02997(bar, kind)
                    EAS_ForceRectFill02997(bar, bar.epcRectCurrent or 0, bar.epcRectMaximum or 0)
                end
            end
        end
        paintUnit(self.playerFrame)
        paintUnit(self.targetFrame)
        for _, roster in ipairs({self.groupFrame, self.raidFrame}) do
            if roster then
                for _, row in ipairs(roster.epcRows or {}) do
                    if row and row.epcBars and row.epcBars.health then
                        EAS_TagBar02997(row.epcBars.health, "health")
                        EAS_ForceRectFill02997(row.epcBars.health, row.epcBars.health.epcRectCurrent or 0, row.epcBars.health.epcRectMaximum or 0)
                    end
                    if row and row.epcCompanionHealth and row.epcCompanionHealth ~= false then
                        EAS_TagBar02997(row.epcCompanionHealth, "health")
                        EAS_ForceRectFill02997(row.epcCompanionHealth, row.epcCompanionHealth.epcRectCurrent or 0, row.epcCompanionHealth.epcRectMaximum or 0)
                    end
                end
            end
        end
    else
        EAS_HideOriginalFloatingDecor02997(self)
        -- Player Magicka/Stamina geometry must never be recalculated as a side
        -- effect of Target, Group, or power-value refreshes. Target acquisition
        -- was repeatedly entering this shared final-policy path and re-anchoring
        -- only these two bars, which made them jump while Health stayed stable.
        if allowPlayerSpacing == true then
            EAS_SpaceOriginalPlayerBars02997(self.playerFrame, design)
        end
    end

    if self.playerFrame then
        if self.playerFrame.epcTitle then self.playerFrame.epcTitle:SetHidden(true) self.playerFrame.epcTitle:SetText("") end
        if self.playerFrame.epcInfo then self.playerFrame.epcInfo:SetHidden(true) self.playerFrame.epcInfo:SetText("") end
    end
end

-- Final wrappers sit after every older compatibility layer so no earlier theme
-- pass can re-enable the stray card/accent lines or cover the rectangle fill.
local EAS_LayoutIntegratedUnitFrameBase02997 = F.LayoutIntegratedUnitFrame
function F:LayoutIntegratedUnitFrame(frame, buffCount, debuffCount, preview)
    EAS_LayoutIntegratedUnitFrameBase02997(self, frame, buffCount, debuffCount, preview)
    -- Geometry is allowed only while laying out the Player frame itself.
    local allowPlayerSpacing = frame ~= nil and frame.epcKind == "player"
    EAS_FinalUnitFramePolicy02997(self, allowPlayerSpacing, false)
end

local EAS_RefreshGroupFramesBase02997 = F.RefreshGroupFrames
function F:RefreshGroupFrames()
    EAS_RefreshGroupFramesBase02997(self)
    EAS_FinalUnitFramePolicy02997(self, false, true)
    -- v0.29.342: roster rows are parent BackdropControls. Several historical
    -- style layers still color them before the final no-card policy runs. Lock
    -- the final visible state once per roster refresh so those backgrounds do
    -- not alternate/flicker between compatibility passes.
    local function stabilize(frame)
        if not frame then return end
        if frame.epcBackground then frame.epcBackground:SetHidden(true) end
        for _, row in ipairs(frame.epcRows or {}) do
            if row then
                if row.SetCenterColor then row:SetCenterColor(0, 0, 0, 0) end
                if row.SetEdgeColor then row:SetEdgeColor(0, 0, 0, 0) end
            end
        end
    end
    stabilize(self.groupFrame)
    stabilize(self.raidFrame)
end

local EAS_ApplyVisualStyleBase02997 = F.ApplyVisualStyle
function F:ApplyVisualStyle()
    EAS_ApplyVisualStyleBase02997(self)
    -- Explicit style/layout work may intentionally establish Player spacing.
    EAS_FinalUnitFramePolicy02997(self, true, true)
end

local EAS_UpdateUnitFrameBase02997 = F.UpdateUnitFrame
function F:UpdateUnitFrame(frame, unitTag, preview)
    -- v0.29.341: the previous wrapper traversed Player, Target, Group and Raid
    -- bars after every single unit-value update. updateFillBar/updateESOResourceBar
    -- already maintain the live rectangle fill, so no global policy pass belongs
    -- on this hot path.
    return EAS_UpdateUnitFrameBase02997(self, frame, unitTag, preview)
end

local EAS_UpdateESOResourceBarBase02997 = updateESOResourceBar
updateESOResourceBar = function(bar, current, maximum)
    EAS_UpdateESOResourceBarBase02997(bar, current, maximum)
    if bar then EAS_ForceRectFill02997(bar, current, maximum) end
end

local EAS_UpdateFillBarBase02997 = updateFillBar
updateFillBar = function(bar, current, maximum, prefix)
    EAS_UpdateFillBarBase02997(bar, current, maximum, prefix)
    if bar then EAS_ForceRectFill02997(bar, current, maximum) end
end

local EAS_RefreshRectResourceFillsBase02997 = F.RefreshRectResourceFills02995
function F:RefreshRectResourceFills02995()
    EAS_RefreshRectResourceFillsBase02997(self)
    if not EAS_IsRectDesign02995(EAS_GetUnitFrameDesign02991()) then return end
    EAS_TagFrameBars02997(self)
    local function repaint(frame)
        if not frame then return end
        for _, bar in pairs(frame.epcBars or {}) do
            if bar then EAS_ForceRectFill02997(bar, bar.epcRectCurrent or 0, bar.epcRectMaximum or 0) end
        end
    end
    repaint(self.playerFrame)
    repaint(self.targetFrame)
    for _, roster in ipairs({self.groupFrame, self.raidFrame}) do
        if roster then
            for _, row in ipairs(roster.epcRows or {}) do
                if row and row.epcBars and row.epcBars.health then
                    local b = row.epcBars.health
                    EAS_ForceRectFill02997(b, b.epcRectCurrent or 0, b.epcRectMaximum or 0)
                end
                if row and row.epcCompanionHealth and row.epcCompanionHealth ~= false then
                    local b = row.epcCompanionHealth
                    EAS_ForceRectFill02997(b, b.epcRectCurrent or 0, b.epcRectMaximum or 0)
                end
            end
        end
    end
end


-- ============================================================================
-- v0.29.98-stable - Player resource text centering only.
-- IMPORTANT: this stability patch deliberately does NOT change Player frame/bar
-- anchors, dimensions, visibility, fills, textures, or refresh/layout behavior.
-- It only formats and centers the text inside the existing Health/Magicka/
-- Stamina controls from the known-stable 0.29.97 geometry.
-- ============================================================================
local function EAS_IsStablePlayerResourceBar02998(bar)
    if not bar or type(bar.GetParent) ~= "function" then return false end
    local parent = bar:GetParent()
    return parent ~= nil and parent.epcKind == "player"
end

local function EAS_CenterStablePlayerResourceText02998(bar, current, maximum)
    if not EAS_IsStablePlayerResourceBar02998(bar) or not bar.epcLabel then return end

    local label = bar.epcLabel
    -- Alignment only. Do not clear/rebuild anchors here: the label already fills
    -- its own bar, and preserving that anchor avoids introducing another live
    -- geometry path into the stable 0.29.97 frame code.
    if label.SetHorizontalAlignment then label:SetHorizontalAlignment(TEXT_ALIGN_CENTER) end
    if label.SetVerticalAlignment then label:SetVerticalAlignment(TEXT_ALIGN_CENTER) end
    if label.SetMaxLineCount then label:SetMaxLineCount(1) end
    if label.SetWrapMode and TEXT_WRAP_MODE_ELLIPSIS then label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) end

    local width = math.max(1, tonumber(bar:GetWidth()) or 1)
    local height = math.max(1, tonumber(bar:GetHeight()) or 1)
    if height <= 14 then
        label:SetFont("$(BOLD_FONT)|13|soft-shadow-thin")
    elseif height <= 18 then
        label:SetFont("$(BOLD_FONT)|14|soft-shadow-thin")
    else
        label:SetFont("ZoFontGameSmall")
    end

    current, maximum = tonumber(current) or 0, tonumber(maximum) or 0
    local design = EAS_GetUnitFrameDesign02991()
    local text
    if maximum <= 0 then
        text = "--"
    elseif design == "SLIM_LINES" or height <= 14 or width < 170 then
        text = percentText(current, maximum)
    elseif width < 250 then
        text = compactNumber(current) .. "  " .. percentText(current, maximum)
    else
        text = compactNumber(current) .. " / " .. compactNumber(maximum) .. "  " .. percentText(current, maximum)
    end
    label:SetText(text)
end

-- Resource updates are the only hook needed. The mature 0.29.97 updater runs
-- first and retains complete ownership of bar position/fill/visibility; this
-- final step touches only the Player label text/alignment.
local EAS_UpdateESOResourceBarBaseStable02998 = updateESOResourceBar
updateESOResourceBar = function(bar, current, maximum)
    EAS_UpdateESOResourceBarBaseStable02998(bar, current, maximum)
    EAS_CenterStablePlayerResourceText02998(bar, current, maximum)
end
