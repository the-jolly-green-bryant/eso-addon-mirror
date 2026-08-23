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

-- GetUnitPower() and EVENT_POWER_UPDATE filters use different constant families.
-- GetUnitPower() must receive POWERTYPE_* constants.  REGISTER_FILTER_POWER_TYPE
-- receives COMBAT_MECHANIC_FLAGS_* on current ESO clients.  Keep them separate:
-- reusing the filter constants for GetUnitPower() can map a Health read to another
-- resource (observed as Stamina in the custom Group frame).
local POWER_HEALTH = POWERTYPE_HEALTH
local POWER_MAGICKA = POWERTYPE_MAGICKA
local POWER_STAMINA = POWERTYPE_STAMINA

local FILTER_POWER_HEALTH = COMBAT_MECHANIC_FLAGS_HEALTH or POWERTYPE_HEALTH
local FILTER_POWER_MAGICKA = COMBAT_MECHANIC_FLAGS_MAGICKA or POWERTYPE_MAGICKA
local FILTER_POWER_STAMINA = COMBAT_MECHANIC_FLAGS_STAMINA or POWERTYPE_STAMINA

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
        local timer = makeLabel(slot, "EPC_PlayerEffects_" .. prefix .. tostring(index) .. "_Timer", "ZoFontGameSmall", C.white, TEXT_ALIGN_CENTER)
        timer:SetAnchor(BOTTOMLEFT, slot, BOTTOMLEFT, 0, 0)
        timer:SetAnchor(BOTTOMRIGHT, slot, BOTTOMRIGHT, 0, 0)
        timer:SetHeight(11)
        local stack = makeLabel(slot, "EPC_PlayerEffects_" .. prefix .. tostring(index) .. "_Stack", "ZoFontGameSmall", C.gold, TEXT_ALIGN_RIGHT)
        stack:SetAnchor(TOPRIGHT, slot, TOPRIGHT, -1, -1)
        stack:SetDimensions(13, 11)
        slot.epcIcon, slot.epcTimer, slot.epcStack, slot.epcName = icon, timer, stack, ""
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
            slot.epcTimer:SetText(formatAuraTime(aura.endTime))
            slot.epcStack:SetText((aura.stackCount or 0) > 1 and tostring(aura.stackCount) or "")
            if aura.castByPlayer then slot:SetEdgeColor(unpack(C.gold))
            else slot:SetEdgeColor(unpack(edgeColor)) end
        else
            slot:SetHidden(true)
            slot.epcName = ""
            slot.epcTimer:SetText("")
            slot.epcStack:SetText("")
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

    -- Penetration is a flat rating, not a percentage. Read every current ESO
    -- representation and keep the strongest valid value so hybridized stats and
    -- client-side advanced-stat representation changes cannot leave PEN at zero.
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

    -- ESO's Critical Damage advanced stat is the BONUS above the universal 50%
    -- critical-hit base. A perfectly valid bonus of 0 therefore means 50% total,
    -- not "stat unavailable". Current LibCombat uses the same 50 + ZOS bonus
    -- calculation. Keep zero as a valid result and only fall back when the API
    -- truly returns nil/unavailable.
    local cdBonus = readAdvancedPercent(ADVANCED_STAT_DISPLAY_TYPE_CRITICAL_DAMAGE, true)
    if cdBonus == nil then
        cdBonus = readAdvancedPercent(ADVANCED_STAT_DISPLAY_TYPE_CRITICAL_PERCENT, true)
    end
    if cdBonus == nil then
        cdBonus = readCriticalDamageFromAdvancedInfo()
    end
    local cd = cdBonus ~= nil and (50 + cdBonus) or nil

    local stats = self.statsFrame.epcStats
    stats.PEN:SetText(compactNumber(pen))
    stats.PWR:SetText(compactNumber(power))
    stats.SR:SetText(compactNumber(sr))
    stats.PR:SetText(compactNumber(pr))
    stats.CC:SetText(cc and string.format("%.1f%%", cc) or "--")
    stats.CD:SetText(cd and string.format("%.1f%%", cd) or "--")
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

function F:RegisterEvents()
    local prefix = EPC.name .. "_UnitFrames"
    if EVENT_POWER_UPDATE then
        local function registerPower(suffix, unitFilterType, unitFilterValue, powerType, syncGroupHealth)
            local registration = prefix .. "_Power_" .. suffix
            EVENT_MANAGER:RegisterForEvent(registration, EVENT_POWER_UPDATE, function(_, unitTag, powerIndex, eventPowerType, powerValue, powerMax)
                -- Feed group/raid rows the event payload immediately. For the local
                -- player we must ALSO refresh the Player frame; the same "player"
                -- event drives both displays.
                -- Only HEALTH registrations may drive the group/raid health bars.
                -- Player Magicka/Stamina events use the same callback shape, and feeding
                -- those values into UpdateGroupHealthFromEvent would overwrite Health
                -- with the wrong resource (most visibly Stamina).
                local groupUpdated = false
                if syncGroupHealth == true then
                    groupUpdated = self:UpdateGroupHealthFromEvent(unitTag, powerValue, powerMax)
                end
                if unitTag == "player" or unitTag == "reticleover" or not groupUpdated then
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
            registerPower("PlayerMagicka", REGISTER_FILTER_UNIT_TAG, "player", FILTER_POWER_MAGICKA, false)
            registerPower("PlayerStamina", REGISTER_FILTER_UNIT_TAG, "player", FILTER_POWER_STAMINA, false)
            registerPower("TargetHealth", REGISTER_FILTER_UNIT_TAG, "reticleover", FILTER_POWER_HEALTH, false)
            -- Group health: register each concrete group unit tag separately.
            -- This avoids relying on UNIT_TAG_PREFIX matching for EVENT_POWER_UPDATE,
            -- while still keeping the high-volume event natively filtered before Lua.
            for i = 1, 12 do
                local groupTag = "group" .. tostring(i)
                registerPower("GroupHealth" .. tostring(i), REGISTER_FILTER_UNIT_TAG, groupTag, FILTER_POWER_HEALTH, true)
            end
        else
            registerPower("Fallback", nil, nil, nil, false)
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

    EVENT_MANAGER:RegisterForUpdate(prefix .. "_Visibility", 250, function()
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
        self:RefreshStats()
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
    local timer = makeLabel(slot, name .. "_" .. prefix .. tostring(index) .. "_Timer", "ZoFontGameSmall", C.white, TEXT_ALIGN_CENTER)
    timer:SetAnchor(BOTTOMLEFT, slot, BOTTOMLEFT, 0, -1)
    timer:SetAnchor(BOTTOMRIGHT, slot, BOTTOMRIGHT, 0, -1)
    timer:SetHeight(11)
    local stack = makeLabel(slot, name .. "_" .. prefix .. tostring(index) .. "_Stack", "ZoFontGameSmall", C.gold, TEXT_ALIGN_RIGHT)
    stack:SetAnchor(TOPRIGHT, slot, TOPRIGHT, -1, 0)
    stack:SetDimensions(14,11)
    slot.epcIcon, slot.epcTimer, slot.epcStack, slot.epcName = icon, timer, stack, ""
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
    EVENT_MANAGER:RegisterForUpdate(prefix .. "_AuraTick",500,function()
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
