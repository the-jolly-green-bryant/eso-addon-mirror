local U = Ultivite
if not U then return end

U.EnemyUltimateAlerts = U.EnemyUltimateAlerts or {}
local A = U.EnemyUltimateAlerts
local Combat = U.Combat

local EVENT_PREFIX = "UltiviteEnemyUltimateAlert"
local UPDATE_NAME = EVENT_PREFIX .. "Update"
local RETICLE_EVENT_NAME = EVENT_PREFIX .. "Reticle"
local PLAYER_EVENT_NAME = EVENT_PREFIX .. "PlayerActivated"
local UPDATE_MS = 50
-- Corrosive Armor's public skill/effect is 33852, but the hostile periodic
-- damage received by the player is emitted as ability 17879. The latter is the
-- live combat-event signature used by the maintained DKCorrosiveAlert addon.
local CORROSIVE_EFFECT_ID = 33852
local CORROSIVE_DURATION_MS = 10000
local CORROSIVE_TICK_GRACE_MS = 1500
local CORROSIVE_DAMAGE_IDS = {
    [17879] = true,
}
local ONSLAUGHT_DURATION_MS = 8000
local ONSLAUGHT_ABILITY_IDS = {
    [83229] = true,
    [126497] = true,
}

A.active = A.active or { corrosive = {}, onslaught = {} }
A.learnedCorrosiveIds = A.learnedCorrosiveIds or {}
A.learnedOnslaughtIds = A.learnedOnslaughtIds or {}
A.registeredEvents = A.registeredEvents or {}
A.updateRunning = false
A.initialized = false
A.previewKind = nil
A.globalDragging = false
A.targetDragging = false
A.globalRoot = nil
A.targetRoot = nil
A.globalRows = A.globalRows or {}
A.targetSlots = A.targetSlots or {}
A.listenerRegistered = false
A.registrationFilter = "none"
A.lastRegistrationAtMs = 0
A.eventsSeen = 0
A.eventsRejected = 0
A.lastRejectedReason = "none"
A.lastAcceptedEvent = nil

local function nowMs()
    if GetFrameTimeMilliseconds then return GetFrameTimeMilliseconds() end
    if GetGameTimeMilliseconds then return GetGameTimeMilliseconds() end
    return 0
end

local function lower(value)
    local text = tostring(value or "")
    if zo_strlower then return zo_strlower(text) end
    return string.lower(text)
end

local function cleanName(value)
    local text = tostring(value or "")
    if zo_strformat then text = zo_strformat("<<C:1>>", text) end
    text = text:gsub("%^%a+$", "")
    return text
end

local function nameKey(value)
    return lower(cleanName(value))
end

local function validUnitId(value)
    if value == nil then return nil end
    local text = tostring(value)
    if text == "" or text == "0" then return nil end
    return text
end

local function getSettings()
    return Combat and Combat.sv or nil
end

local function requestSave()
    if U.RequestSettingsSave then U.RequestSettingsSave(true) end
end

local function diagnostic(message)
    if Combat and Combat.DiagnosticChat then Combat.DiagnosticChat(message) end
end

local function getTargetOffsets()
    local sv = getSettings()
    local x = tonumber(sv and sv.enemyUltimateAlertTargetX) or 0
    local y = tonumber(sv and sv.enemyUltimateAlertTargetY) or -115
    return zo_clamp(x, -800, 800), zo_clamp(y, -500, 500)
end

local function getGlobalPositionLimits()
    local width = GuiRoot and GuiRoot.GetWidth and (tonumber(GuiRoot:GetWidth()) or 0) or 0
    local height = GuiRoot and GuiRoot.GetHeight and (tonumber(GuiRoot:GetHeight()) or 0) or 0
    local maxX = math.max(800, math.floor((width * 0.5) - 40))
    local maxY = math.max(500, math.floor(height - 90))
    return maxX, maxY
end

local function getGlobalOffsets()
    local sv = getSettings()
    local x = tonumber(sv and sv.enemyUltimateAlertGlobalX) or 0
    local y = tonumber(sv and sv.enemyUltimateAlertGlobalY) or 165
    local maxX, maxY = getGlobalPositionLimits()
    return zo_clamp(x, -maxX, maxX), zo_clamp(y, 0, maxY)
end

-- Warning artwork must not be resolved from combat-event IDs.  Corrosive
-- detection uses effect/damage IDs that are not guaranteed to own the slotted
-- skill artwork, which can make GetAbilityIcon return ESO's question-mark icon.
-- Reference a known in-client Corrosive Armor texture directly instead. ESO-Hub
-- uses a web-export filename for the Update 49 image which is not a valid
-- in-client DDS path; the packaged ESO texture remains ability_dragonknight_018_b.
local OFFICIAL_ULTIMATE_ICONS = {
    corrosive = "EsoUI/Art/Icons/ability_dragonknight_018_b.dds",
    onslaught = "EsoUI/Art/Icons/ability_2handed_006_a.dds",
}

local function resolveIcon(kind)
    -- Prefer ESO's live skill metadata when it resolves to a real texture. Some
    -- combat/effect IDs return icon_missing.dds instead of the slotted skill art,
    -- so Corrosive falls back to the known packaged in-client texture.
    local abilityId = kind == "corrosive" and CORROSIVE_EFFECT_ID or 83229
    if type(GetAbilityIcon) == "function" then
        local ok, value = pcall(GetAbilityIcon, abilityId)
        local icon = ok and tostring(value or "") or ""
        local lowered = lower(icon)
        if icon ~= "" and not lowered:find("icon_missing", 1, true) and not lowered:find("question", 1, true) then
            return icon
        end
    end
    return OFFICIAL_ULTIMATE_ICONS[kind] or OFFICIAL_ULTIMATE_ICONS.onslaught
end

local function createIconSlot(parent, name, kind)
    local wm = WINDOW_MANAGER
    local root = wm:CreateControl(name, parent, CT_CONTROL)
    root:SetMouseEnabled(false)

    local backdrop = wm:CreateControl(name .. "Backdrop", root, CT_BACKDROP)
    backdrop:SetAnchorFill(root)
    backdrop:SetCenterColor(0.015, 0.015, 0.015, 0.86)
    backdrop:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16, 2, 0)
    if kind == "corrosive" then
        backdrop:SetEdgeColor(0.95, 0.68, 0.10, 1)
    else
        backdrop:SetEdgeColor(0.90, 0.16, 0.12, 1)
    end
    backdrop:SetMouseEnabled(false)

    local icon = wm:CreateControl(name .. "Icon", root, CT_TEXTURE)
    icon:SetTexture(resolveIcon(kind))
    icon:SetTextureCoords(0, 1, 0, 1)
    icon:SetMouseEnabled(false)

    local timer = wm:CreateControl(name .. "Timer", root, CT_LABEL)
    timer:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    timer:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    timer:SetFont("$(BOLD_FONT)|18|soft-shadow-thick")
    timer:SetColor(1, 1, 1, 1)
    timer:SetMouseEnabled(false)

    root.backdrop = backdrop
    root.icon = icon
    root.timer = timer
    root.kind = kind
    root:SetHidden(true)
    return root
end

function A.ApplyLayout()
    local sv = getSettings()
    local size = zo_clamp(tonumber(sv and sv.enemyUltimateAlertIconSize) or 54, 32, 96)
    local pad = 4

    for _, slot in pairs(A.targetSlots or {}) do
        slot:SetDimensions(size, size)
        slot.icon:ClearAnchors()
        slot.icon:SetAnchor(TOPLEFT, slot, TOPLEFT, pad, pad)
        slot.icon:SetDimensions(size - (pad * 2), size - (pad * 2))
        slot.timer:ClearAnchors()
        slot.timer:SetAnchor(BOTTOM, slot, BOTTOM, 0, -1)
        slot.timer:SetDimensions(size, 22)
        slot.timer:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", zo_clamp(math.floor(size * 0.32), 14, 28)))
    end

    if A.targetRoot then
        A.targetRoot:SetDimensions((size * 2) + 8, size + 6)
    end

    local globalX, globalY = getGlobalOffsets()

    local rootWidth = 500
    if GuiRoot and GuiRoot.GetWidth then
        rootWidth = math.max(320, math.min(500, (tonumber(GuiRoot:GetWidth()) or 500) - 32))
    end
    local nextY = 0
    for _, kind in ipairs({ "corrosive", "onslaught" }) do
        local row = A.globalRows and A.globalRows[kind]
        if row then
        local rowSize = zo_clamp(math.floor(size * 0.86), 34, 72)
        row:ClearAnchors()
        row:SetAnchor(TOP, A.globalRoot, TOP, 0, nextY)
        row:SetDimensions(rootWidth - 20, rowSize + 6)
        row.icon:SetDimensions(rowSize, rowSize)
        row.icon:ClearAnchors()
        row.icon:SetAnchor(LEFT, row, LEFT, 0, 0)
        row.label:ClearAnchors()
        row.label:SetAnchor(LEFT, row.icon, RIGHT, 10, 0)
        row.label:SetDimensions(math.max(210, rootWidth - rowSize - 42), rowSize)
        row.label:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", zo_clamp(math.floor(rowSize * 0.42), 18, 28)))
        nextY = nextY + rowSize + 8
        end
    end
    if A.globalRoot then
        A.globalRoot:SetDimensions(rootWidth, math.max(90, nextY))
        if A.globalDragging ~= true then
            A.globalRoot:ClearAnchors()
            A.globalRoot:SetAnchor(TOP, GuiRoot, TOP, globalX, globalY)
        end
    end
end

function A.CreateUI()
    if A.globalRoot or not WINDOW_MANAGER or not GuiRoot then return end
    local wm = WINDOW_MANAGER

    local global = wm:CreateTopLevelWindow("UltiviteEnemyUltimateGlobalAlert")
    global:SetDimensions(500, 140)
    global:SetAnchor(TOP, GuiRoot, TOP, 0, 165)
    global:SetMouseEnabled(false)
    global:SetClampedToScreen(true)
    if global.SetDrawTier then global:SetDrawTier(DT_HIGH) end
    if global.SetDrawLayer then global:SetDrawLayer(DL_OVERLAY) end
    if global.SetDrawLevel then global:SetDrawLevel(4850) end
    global:SetHidden(true)
    A.globalRoot = global

    local function makeGlobalRow(kind, y)
        local row = wm:CreateControl("UltiviteEnemyUltimateGlobal" .. kind, global, CT_CONTROL)
        row:SetAnchor(TOP, global, TOP, 0, y)
        row:SetMouseEnabled(false)

        local icon = wm:CreateControl("UltiviteEnemyUltimateGlobal" .. kind .. "Icon", row, CT_TEXTURE)
        icon:SetTexture(resolveIcon(kind))
        icon:SetMouseEnabled(false)

        local label = wm:CreateControl("UltiviteEnemyUltimateGlobal" .. kind .. "Label", row, CT_LABEL)
        label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        label:SetMouseEnabled(false)
        if kind == "corrosive" then
            label:SetColor(1.0, 0.72, 0.16, 1)
        else
            label:SetColor(1.0, 0.28, 0.20, 1)
        end
        row.icon = icon
        row.label = label
        row:SetHidden(true)
        A.globalRows[kind] = row
        return row
    end

    makeGlobalRow("corrosive", 0)
    makeGlobalRow("onslaught", 66)

    local target = wm:CreateTopLevelWindow("UltiviteEnemyUltimateTargetMarker")
    target:SetMouseEnabled(false)
    target:SetMovable(false)
    target:SetClampedToScreen(true)
    if target.SetDrawTier then target:SetDrawTier(DT_HIGH) end
    if target.SetDrawLayer then target:SetDrawLayer(DL_OVERLAY) end
    if target.SetDrawLevel then target:SetDrawLevel(4860) end
    target:SetHidden(true)
    A.targetRoot = target

    local corrosive = createIconSlot(target, "UltiviteEnemyUltimateTargetCorrosive", "corrosive")
    local onslaught = createIconSlot(target, "UltiviteEnemyUltimateTargetOnslaught", "onslaught")
    corrosive:SetAnchor(LEFT, target, LEFT, 0, 0)
    onslaught:SetAnchor(LEFT, corrosive, RIGHT, 8, 0)
    A.targetSlots.corrosive = corrosive
    A.targetSlots.onslaught = onslaught

    A.ApplyLayout()
end

local function makeSourceKey(sourceUnitId, sourceName)
    local id = validUnitId(sourceUnitId)
    if id then return "id:" .. id end
    local n = nameKey(sourceName)
    if n ~= "" then return "name:" .. n end
    return "unknown"
end

local function resolveAbilityMetadata(abilityId, eventName, eventGraphic)
    local id = tonumber(abilityId) or 0
    local name = tostring(eventName or "")
    local graphic = tostring(eventGraphic or "")

    -- Some PvP combat events expose an internal damage ID with sparse event
    -- metadata. Ask ESO for the public metadata for that ID before giving up.
    if id > 0 then
        if name == "" and GetAbilityName then
            local ok, value = pcall(GetAbilityName, id)
            if ok and value then name = tostring(value) end
        end
        if graphic == "" and GetAbilityIcon then
            local ok, value = pcall(GetAbilityIcon, id)
            if ok and value then graphic = tostring(value) end
        end
    end
    return lower(name), lower(graphic), id
end

local function isCorrosiveEvent(abilityName, abilityGraphic, abilityId)
    local ability, graphic, id = resolveAbilityMetadata(abilityId, abilityName, abilityGraphic)
    if CORROSIVE_DAMAGE_IDS[id] or A.learnedCorrosiveIds[id] == true then return true end

    local matched = ability:find("corrosive armor", 1, true) ~= nil
        or graphic:find("ability_dragonknight_018_b", 1, true) ~= nil
    if matched and id > 0 then A.learnedCorrosiveIds[id] = true end
    return matched
end

local function isOnslaughtEvent(abilityName, abilityId)
    local ability, _, id = resolveAbilityMetadata(abilityId, abilityName, nil)
    if ONSLAUGHT_ABILITY_IDS[id] or (A.learnedOnslaughtIds and A.learnedOnslaughtIds[id] == true) then return true end
    local matched = ability:find("onslaught", 1, true) ~= nil
    if matched and id > 0 then
        A.learnedOnslaughtIds = A.learnedOnslaughtIds or {}
        A.learnedOnslaughtIds[id] = true
    end
    return matched
end

local function recordAlert(kind, sourceName, sourceUnitId, abilityId)
    local now = nowMs()
    local duration = kind == "corrosive" and CORROSIVE_DURATION_MS or ONSLAUGHT_DURATION_MS
    local key = makeSourceKey(sourceUnitId, sourceName)
    local bucket = A.active[kind]
    local existing = bucket[key]

    -- Corrosive ticks arrive every second. Each valid tick is fresh proof that
    -- the source still has Corrosive active, so mirror DKCorrosiveAlert's short
    -- three-second rolling window. Onslaught remains an eight-second window.
    if not existing or now > (tonumber(existing.expiresAtMs) or 0) + 1200 then
        existing = {
            key = key,
            kind = kind,
            sourceName = cleanName(sourceName),
            sourceNameKey = nameKey(sourceName),
            sourceUnitId = validUnitId(sourceUnitId),
            abilityId = tonumber(abilityId) or 0,
            firstSeenMs = now,
            lastSeenMs = now,
            expiresAtMs = now + duration,
        }
        bucket[key] = existing
    else
        existing.lastSeenMs = now
        if existing.sourceName == "" then existing.sourceName = cleanName(sourceName) end
        if existing.sourceNameKey == "" then existing.sourceNameKey = nameKey(sourceName) end
        if not existing.sourceUnitId then existing.sourceUnitId = validUnitId(sourceUnitId) end
        if kind == "corrosive" then
            -- Corrosive's periodic damage arrives once per second. Do not reset a
            -- full ten-second timer on every tick or the warning can outlive the
            -- Ultimate by almost its full duration. Keep the original ten-second
            -- estimate and only add a short grace near the end while fresh ticks
            -- prove the effect is still active. Reticle buff data below replaces
            -- this estimate with ESO's exact endTime whenever it is available.
            existing.expiresAtMs = math.max(tonumber(existing.expiresAtMs) or 0, now + CORROSIVE_TICK_GRACE_MS)
        else
            existing.expiresAtMs = now + duration
        end
    end

    diagnostic(string.format("Enemy ultimate %s source=%s id=%s ability=%s", kind, tostring(existing.sourceName), tostring(existing.sourceUnitId), tostring(abilityId)))
    A.StartUpdateLoop()
    A.Update(true)
end

local function eventTargetsLocalPlayer(targetName, targetType)
    -- COMBAT_UNIT_TYPE_PLAYER means *this* player, not any player. Enemy players
    -- are normally COMBAT_UNIT_TYPE_OTHER in PvP. The previous Ultivite build
    -- incorrectly required the SOURCE to be COMBAT_UNIT_TYPE_PLAYER, which
    -- discarded the hostile events before an alert could ever be created.
    if targetType ~= nil then
        return targetType == COMBAT_UNIT_TYPE_PLAYER
    end

    -- Fallback only for clients/events that omit targetType. Do not compare
    -- targetUnitId: PvP can obscure or remap unit IDs even when the incoming
    -- event is genuinely for the local player.
    local targetKey = nameKey(targetName)
    if targetKey == "" then return true end
    local playerName = GetUnitName and nameKey(GetUnitName("player")) or ""
    local displayName = GetUnitDisplayName and nameKey(GetUnitDisplayName("player")) or ""
    if playerName == "" and displayName == "" then return true end
    return targetKey == playerName or targetKey == displayName
end

local function buildDamageResults()
    -- These are the result types used by DKcorrosiveAlert / the longstanding
    -- Onslaught combat-event approach. Shielded and blocked damage are retained
    -- as well so the alert still fires when the hit is absorbed.
    return {
        ACTION_RESULT_DAMAGE,
        ACTION_RESULT_CRITICAL_DAMAGE,
        ACTION_RESULT_DOT_TICK,
        ACTION_RESULT_DOT_TICK_CRITICAL,
        ACTION_RESULT_DAMAGE_SHIELDED,
        ACTION_RESULT_BLOCKED_DAMAGE,
    }
end

local damageResultLookup = nil
local function isDamageResult(result)
    if not damageResultLookup then
        damageResultLookup = {}
        for _, allowed in ipairs(buildDamageResults()) do damageResultLookup[allowed] = true end
    end
    return damageResultLookup[result] == true
end

local function rejectEvent(reason)
    A.eventsRejected = (tonumber(A.eventsRejected) or 0) + 1
    A.lastRejectedReason = tostring(reason or "unknown")
    return false
end

local function onIncomingCombatEvent(...)
    local eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType,
        sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType,
        log, sourceUnitId, targetUnitId, abilityId = ...

    A.eventsSeen = (tonumber(A.eventsSeen) or 0) + 1
    if isError == true then return rejectEvent("isError") end
    if not isDamageResult(result) then return rejectEvent("not damage") end
    if not eventTargetsLocalPlayer(targetName, targetType) then return rejectEvent("not local player") end
    if (tonumber(hitValue) or 0) <= 0 then return rejectEvent("zero hit") end

    local sv = getSettings()
    if not sv then return rejectEvent("settings unavailable") end
    if sv.showEnemyCorrosiveAlert ~= false and isCorrosiveEvent(abilityName, abilityGraphic, abilityId) then
        A.lastAcceptedEvent = {
            kind = "corrosive",
            abilityId = tonumber(abilityId) or 0,
            sourceName = cleanName(sourceName),
            sourceUnitId = validUnitId(sourceUnitId),
            atMs = nowMs(),
        }
        recordAlert("corrosive", sourceName, sourceUnitId, abilityId)
        return true
    end
    if sv.showEnemyOnslaughtAlert ~= false and isOnslaughtEvent(abilityName, abilityId) then
        A.lastAcceptedEvent = {
            kind = "onslaught",
            abilityId = tonumber(abilityId) or 0,
            sourceName = cleanName(sourceName),
            sourceUnitId = validUnitId(sourceUnitId),
            atMs = nowMs(),
        }
        recordAlert("onslaught", sourceName, sourceUnitId, abilityId)
        return true
    end
    return rejectEvent("unmatched ability " .. tostring(abilityId or 0))
end

function A.RefreshEventRegistration()
    for _, eventName in ipairs(A.registeredEvents or {}) do
        EVENT_MANAGER:UnregisterForEvent(eventName, EVENT_COMBAT_EVENT)
    end
    A.registeredEvents = {}
    A.listenerRegistered = false
    A.registrationFilter = "none"

    local sv = getSettings()
    if not sv then return end
    if sv.showEnemyCorrosiveAlert ~= false or sv.showEnemyOnslaughtAlert ~= false then
        -- Register one engine-filtered listener per accepted result so unrelated
        -- combat traffic never reaches Lua. Each AddFilterForEvent call combines
        -- target ownership and result in the form recommended by ESOUI.
        for index, resultCode in ipairs(buildDamageResults()) do
            local eventName = EVENT_PREFIX .. "IncomingPlayer" .. tostring(index)
            EVENT_MANAGER:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, onIncomingCombatEvent)
            EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT,
                REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER,
                REGISTER_FILTER_COMBAT_RESULT, resultCode)
            A.registeredEvents[#A.registeredEvents + 1] = eventName
        end
        A.registrationFilter = "targetType=player + damage results"
        A.listenerRegistered = true
        A.lastRegistrationAtMs = nowMs()
    end
end

local function purgeExpired(kind, now)
    local bucket = A.active[kind]
    for key, entry in pairs(bucket) do
        if (tonumber(entry.expiresAtMs) or 0) <= now then bucket[key] = nil end
    end
end

local function countActive(kind)
    local count, soonest, only = 0, nil, nil
    for _, entry in pairs(A.active[kind]) do
        count = count + 1
        only = entry
        if not soonest or (entry.expiresAtMs or 0) < (soonest.expiresAtMs or 0) then soonest = entry end
    end
    if count ~= 1 then only = nil end
    return count, soonest, only
end

local function entryMatchesTarget(entry, unitId, charName, displayName)
    if not entry then return false end
    local id = validUnitId(unitId)
    if id and entry.sourceUnitId and id == entry.sourceUnitId then return true end
    local charKey = nameKey(charName)
    local displayKey = nameKey(displayName)
    local sourceKey = entry.sourceNameKey or ""
    return sourceKey ~= "" and (sourceKey == charKey or sourceKey == displayKey)
end

local function findForTarget(kind, unitId, charName, displayName)
    for _, entry in pairs(A.active[kind]) do
        if entryMatchesTarget(entry, unitId, charName, displayName) then return entry end
    end
    return nil
end

local function refineCorrosiveFromReticle(entry)
    if not entry or not GetNumBuffs or not GetUnitBuffInfo then return end
    local now = nowMs()
    local count = GetNumBuffs("reticleover") or 0
    for i = 1, count do
        local effectName, beginTime, endTime, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId = GetUnitBuffInfo("reticleover", i)
        local id = tonumber(abilityId) or 0
        if id == CORROSIVE_EFFECT_ID or lower(effectName):find("corrosive armor", 1, true) then
            local endingMs = (tonumber(endTime) or 0) * 1000
            if endingMs > now then entry.expiresAtMs = endingMs end
            return
        end
    end
end

local function getReticleTarget()
    if DoesUnitExist and not DoesUnitExist("reticleover") then return nil end
    if IsUnitPlayer and not IsUnitPlayer("reticleover") then return nil end
    return {
        unitId = GetUnitId and GetUnitId("reticleover") or nil,
        charName = GetUnitName and GetUnitName("reticleover") or "",
        displayName = GetUnitDisplayName and GetUnitDisplayName("reticleover") or "",
    }
end

local function updateTargetSlot(slot, entry, previewSeconds)
    if not slot then return false end
    if not entry and not previewSeconds then slot:SetHidden(true); return false end
    local remaining = previewSeconds or math.max(0, ((entry.expiresAtMs or 0) - nowMs()) / 1000)
    slot.timer:SetText(string.format("%.1f", remaining))
    slot:SetHidden(false)
    return true
end

local function setMouseEnabled(control, enabled)
    if control and control.SetMouseEnabled then control:SetMouseEnabled(enabled == true) end
end

local function setGlobalPreviewMouseEnabled(enabled)
    setMouseEnabled(A.globalRoot, enabled)
    for _, row in pairs(A.globalRows or {}) do
        setMouseEnabled(row, enabled)
        setMouseEnabled(row and row.icon, enabled)
        setMouseEnabled(row and row.label, enabled)
    end
end

local function setTargetPreviewMouseEnabled(enabled)
    setMouseEnabled(A.targetRoot, enabled)
    for _, slot in pairs(A.targetSlots or {}) do
        setMouseEnabled(slot, enabled)
        setMouseEnabled(slot and slot.backdrop, enabled)
        setMouseEnabled(slot and slot.icon, enabled)
        setMouseEnabled(slot and slot.timer, enabled)
    end
end

local function saveGlobalRootPosition()
    local sv = getSettings()
    if not sv or not A.globalRoot or not GuiRoot then return false end
    local cx = A.globalRoot.GetCenter and select(1, A.globalRoot:GetCenter()) or nil
    local gx = GuiRoot.GetCenter and select(1, GuiRoot:GetCenter()) or nil
    local top = A.globalRoot.GetTop and A.globalRoot:GetTop() or nil
    local guiTop = GuiRoot.GetTop and GuiRoot:GetTop() or 0
    if not cx or not gx or not top then return false end
    local maxX, maxY = getGlobalPositionLimits()
    sv.enemyUltimateAlertGlobalX = zo_clamp(zo_round(cx - gx), -maxX, maxX)
    sv.enemyUltimateAlertGlobalY = zo_clamp(zo_round(top - (guiTop or 0)), 0, maxY)
    requestSave()
    return true
end

local function saveTargetRootPosition()
    local sv = getSettings()
    if not sv or not A.targetRoot or not GuiRoot then return false end
    local cx, cy = A.targetRoot:GetCenter()
    local gx, gy = GuiRoot:GetCenter()
    if not cx or not cy or not gx or not gy then return false end
    sv.enemyUltimateAlertTargetX = zo_clamp(zo_round(cx - gx), -800, 800)
    sv.enemyUltimateAlertTargetY = zo_clamp(zo_round(cy - gy), -500, 500)
    requestSave()
    return true
end

function A.StopEditing(saveCurrentPosition)
    -- Hard-stop both native move states and all alert mouse surfaces. This path
    -- is safe to call repeatedly and is used when settings close even if an
    -- OnMouseUp event was lost while the user was dragging.
    if A.globalRoot and A.globalRoot.StopMovingOrResizing then
        pcall(A.globalRoot.StopMovingOrResizing, A.globalRoot)
    end
    if A.targetRoot and A.targetRoot.StopMovingOrResizing then
        pcall(A.targetRoot.StopMovingOrResizing, A.targetRoot)
    end
    if saveCurrentPosition == true then
        saveGlobalRootPosition()
        saveTargetRootPosition()
    end
    A.globalDragging = false
    A.targetDragging = false
    setGlobalPreviewMouseEnabled(false)
    setTargetPreviewMouseEnabled(false)
    return true
end

function A.UpdateTargetMarker()
    if not A.targetRoot then return end
    local preview = A.previewKind
    if preview then
        local showCorrosive = preview == "corrosive" or preview == "all"
        local showOnslaught = preview == "onslaught" or preview == "all"
        updateTargetSlot(A.targetSlots.corrosive, nil, showCorrosive and 10.0 or nil)
        updateTargetSlot(A.targetSlots.onslaught, nil, showOnslaught and 8.0 or nil)
        if A.targetDragging ~= true then
            local targetX, targetY = getTargetOffsets()
            A.targetRoot:ClearAnchors()
            A.targetRoot:SetAnchor(CENTER, GuiRoot, CENTER, targetX, targetY)
        end
        A.targetRoot:SetMovable(true)
        A.targetRoot:SetHidden(false)
        setTargetPreviewMouseEnabled(true)
        return
    end

    A.targetRoot:SetMovable(false)
    setTargetPreviewMouseEnabled(false)
    local target = getReticleTarget()
    if not target then
        updateTargetSlot(A.targetSlots.corrosive, nil, nil)
        updateTargetSlot(A.targetSlots.onslaught, nil, nil)
        A.targetRoot:SetHidden(true)
        return
    end

    -- The warning detection itself deliberately mirrors the original addons and
    -- is based only on incoming damage. Ultivite's only extra presentation is
    -- this mouse-over marker: while your reticle is on the player who triggered
    -- the warning, show the relevant ultimate icon at a fixed 2D reticle anchor.
    local corrosive = findForTarget("corrosive", target.unitId, target.charName, target.displayName)
    local onslaught = findForTarget("onslaught", target.unitId, target.charName, target.displayName)
    if corrosive then refineCorrosiveFromReticle(corrosive) end

    local showCorrosive = updateTargetSlot(A.targetSlots.corrosive, corrosive, nil)
    local showOnslaught = updateTargetSlot(A.targetSlots.onslaught, onslaught, nil)
    if not showCorrosive and not showOnslaught then
        A.targetRoot:SetHidden(true)
        return
    end

    local targetX, targetY = getTargetOffsets()
    A.targetRoot:ClearAnchors()
    -- ESOUI forbids querying non-grouped/enemy world positions. Keep the icon
    -- directly above the reticle only while that same player is under the mouse.
    A.targetRoot:SetAnchor(CENTER, GuiRoot, CENTER, targetX, targetY)
    A.targetRoot:SetHidden(false)
end

function A.UpdateGlobalAlert()
    if not A.globalRoot then return end
    if A.previewKind then
        for _, kind in ipairs({ "corrosive", "onslaught" }) do
            local row = A.globalRows[kind]
            if row then
                local show = A.previewKind == "all" or kind == A.previewKind
                if show then
                    local title = kind == "corrosive" and "CORROSIVE ARMOR" or "ONSLAUGHT"
                    row.label:SetText(string.format("%s   %.1fs  DRAG TO MOVE  •  WHEEL TO RESIZE", title, kind == "corrosive" and 10.0 or 8.0))
                    row:SetHidden(false)
                else
                    row:SetHidden(true)
                end
            end
        end
        A.globalRoot:SetMovable(true)
        setGlobalPreviewMouseEnabled(true)
        A.globalRoot:SetHidden(false)
        return
    end

    A.globalRoot:SetMovable(false)
    setGlobalPreviewMouseEnabled(false)
    local sv = getSettings()
    local now = nowMs()
    local visible = false
    for _, kind in ipairs({ "corrosive", "onslaught" }) do
        local enabled = false
        if sv then
            if kind == "corrosive" then enabled = sv.showEnemyCorrosiveAlert ~= false end
            if kind == "onslaught" then enabled = sv.showEnemyOnslaughtAlert ~= false end
        end
        local row = A.globalRows[kind]
        local count, soonest, only = countActive(kind)
        if enabled and count > 0 and row then
            local remaining = soonest and math.max(0, ((soonest.expiresAtMs or 0) - now) / 1000) or 0
            local title = kind == "corrosive" and "CORROSIVE ARMOR" or "ONSLAUGHT"
            local source = only and only.sourceName and only.sourceName ~= "" and ("  " .. only.sourceName) or ""
            local multiplier = count > 1 and (" x" .. tostring(count)) or ""
            row.label:SetText(string.format("%s%s   %.1fs%s", title, multiplier, remaining, source))
            row:SetHidden(false)
            visible = true
        elseif row then
            row:SetHidden(true)
        end
    end
    A.globalRoot:SetHidden(not visible)
end

function A.Update(force)
    if not A.initialized then return end
    local now = nowMs()
    purgeExpired("corrosive", now)
    purgeExpired("onslaught", now)
    A.UpdateGlobalAlert()
    A.UpdateTargetMarker()

    local c1 = next(A.active.corrosive) ~= nil
    local c2 = next(A.active.onslaught) ~= nil
    if not c1 and not c2 and not A.previewKind then A.StopUpdateLoop() end
end

function A.StartUpdateLoop()
    if A.updateRunning then return end
    A.updateRunning = true
    EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, UPDATE_MS, function() A.Update(false) end)
end

function A.StopUpdateLoop()
    if not A.updateRunning then return end
    A.updateRunning = false
    EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
end

function A.GetCorrosiveEnabled()
    local sv = getSettings()
    return sv ~= nil and sv.showEnemyCorrosiveAlert ~= false
end

function A.GetOnslaughtEnabled()
    local sv = getSettings()
    return sv ~= nil and sv.showEnemyOnslaughtAlert ~= false
end

function A.SetCorrosiveEnabled(enabled)
    local sv = getSettings()
    if not sv then return false end
    sv.showEnemyCorrosiveAlert = enabled and true or false
    if not sv.showEnemyCorrosiveAlert then A.active.corrosive = {} end
    A.RefreshEventRegistration()
    requestSave()
    A.Update(true)
    return true
end

function A.SetOnslaughtEnabled(enabled)
    local sv = getSettings()
    if not sv then return false end
    sv.showEnemyOnslaughtAlert = enabled and true or false
    if not sv.showEnemyOnslaughtAlert then A.active.onslaught = {} end
    A.RefreshEventRegistration()
    requestSave()
    A.Update(true)
    return true
end

function A.SetIconSize(value)
    local sv = getSettings()
    if not sv then return false end
    sv.enemyUltimateAlertIconSize = zo_clamp(math.floor(tonumber(value) or 54), 32, 96)
    A.ApplyLayout()
    requestSave()
    A.Update(true)
    return true
end

function A.SetPreviewKind(kind)
    if kind ~= "corrosive" and kind ~= "onslaught" and kind ~= "all" then kind = nil end
    if kind == nil then A.StopEditing(false) end
    A.previewKind = kind
    if kind then A.StartUpdateLoop() end
    A.Update(true)
end

function A.GetStatusText()
    local sv = getSettings()
    local listener = A.listenerRegistered and "REGISTERED" or "NOT REGISTERED"
    local corrosive = sv and sv.showEnemyCorrosiveAlert ~= false and "on" or "off"
    local onslaught = sv and sv.showEnemyOnslaughtAlert ~= false and "on" or "off"
    local last = A.lastAcceptedEvent
    local lastText = "none"
    if last then
        lastText = string.format(
            "%s id=%s source=%s at=%sms",
            tostring(last.kind or "unknown"),
            tostring(last.abilityId or 0),
            tostring(last.sourceName ~= "" and last.sourceName or last.sourceUnitId or "hidden"),
            tostring(last.atMs or 0)
        )
    end
    return string.format(
        "Listener %s (%s). Corrosive %s, Onslaught %s. Events seen %d, rejected %d. Last accepted: %s. Last rejection: %s.",
        listener,
        tostring(A.registrationFilter or "none"),
        corrosive,
        onslaught,
        tonumber(A.eventsSeen) or 0,
        tonumber(A.eventsRejected) or 0,
        lastText,
        tostring(A.lastRejectedReason or "none")
    )
end

function A.PrintStatus()
    if d then d("[Ultivite] Enemy Ultimate alerts: " .. A.GetStatusText()) end
    return A.GetStatusText()
end

function A.TestAlert(kind)
    if kind ~= "corrosive" and kind ~= "onslaught" then return false end
    local sv = getSettings()
    if not sv then return false end
    if kind == "corrosive" and sv.showEnemyCorrosiveAlert == false then return false end
    if kind == "onslaught" and sv.showEnemyOnslaughtAlert == false then return false end

    A.previewKind = nil
    A.active[kind] = {}
    local result = ACTION_RESULT_DAMAGE
    if result == nil then return false end
    local targetName = GetUnitName and GetUnitName("player") or "ULTIVITE PLAYER"
    local abilityId = kind == "corrosive" and 17879 or 83229
    -- Inject the test through the exact live classifier. A green test therefore
    -- proves result filtering, local-player targeting, ability ID matching,
    -- source tracking and both warning displays rather than bypassing detection.
    return onIncomingCombatEvent(
        EVENT_COMBAT_EVENT,
        result,
        false,
        "",
        "",
        0,
        "ULTIVITE TEST",
        COMBAT_UNIT_TYPE_OTHER,
        targetName,
        COMBAT_UNIT_TYPE_PLAYER,
        1,
        0,
        0,
        false,
        "ultivite-test-" .. kind,
        "ultivite-test-player",
        abilityId
    ) == true
end

function A.Initialize()
    if A.initialized then return end
    A.initialized = true
    A.CreateUI()
    A.RefreshEventRegistration()

    EVENT_MANAGER:RegisterForEvent(RETICLE_EVENT_NAME, EVENT_RETICLE_TARGET_CHANGED, function() A.Update(true) end)
    EVENT_MANAGER:RegisterForEvent(PLAYER_EVENT_NAME, EVENT_PLAYER_ACTIVATED, function()
        A.RefreshEventRegistration()
        A.Update(true)
    end)

    if A.globalRoot then
        local function canEditAlerts()
            local q = U.QuickMenu
            return q and q.previewEnabled == true and A.previewKind ~= nil
        end

        local function saveGlobalPosition()
            saveGlobalRootPosition()
            A.ApplyLayout()
            A.UpdateGlobalAlert()
        end

        local function beginGlobalDrag(button)
            if button ~= MOUSE_BUTTON_INDEX_LEFT or not canEditAlerts() then return end
            local q = U.QuickMenu
            if q and q.BeginPreviewHudInteraction then q.BeginPreviewHudInteraction() end
            A.globalDragging = true
            A.globalRoot:SetMovable(true)
            A.globalRoot:StartMoving()
        end

        local function finishGlobalDrag(button)
            if button ~= nil and button ~= MOUSE_BUTTON_INDEX_LEFT then return end
            if A.globalDragging ~= true then return end
            A.globalDragging = false
            -- Clear the engine drag state before re-anchoring to the saved offset.
            if A.globalRoot.StopMovingOrResizing then A.globalRoot:StopMovingOrResizing() end
            saveGlobalPosition()
            local q = U.QuickMenu
            if q and q.EndPreviewHudInteraction then q.EndPreviewHudInteraction() end
        end

        local function resizeAlerts(delta)
            local q = U.QuickMenu
            if not canEditAlerts() or not q or q.resizeEnabled ~= true or delta == 0 then return end
            local sv = getSettings()
            local current = tonumber(sv and sv.enemyUltimateAlertIconSize) or 54
            if q.BeginPreviewHudInteraction then q.BeginPreviewHudInteraction() end
            A.SetIconSize(current + (delta > 0 and 2 or -2))
            if q.EndPreviewHudInteraction then q.EndPreviewHudInteraction() end
        end

        local function bindGlobalDragSurface(surface)
            if not surface or surface.ultiviteEnemyAlertDragBound == true then return end
            surface.ultiviteEnemyAlertDragBound = true
            surface:SetHandler("OnMouseDown", function(_, button) beginGlobalDrag(button) end)
            surface:SetHandler("OnMouseUp", function(_, button) finishGlobalDrag(button) end)
            surface:SetHandler("OnMouseWheel", function(_, delta) resizeAlerts(delta) end)
        end

        A.globalRoot:SetHandler("OnMoveStop", function()
            if A.globalDragging == true then
                A.globalDragging = false
                saveGlobalPosition()
                local q = U.QuickMenu
                if q and q.EndPreviewHudInteraction then q.EndPreviewHudInteraction() end
            end
        end)

        bindGlobalDragSurface(A.globalRoot)
        for _, row in pairs(A.globalRows or {}) do
            bindGlobalDragSurface(row)
            bindGlobalDragSurface(row and row.icon)
            bindGlobalDragSurface(row and row.label)
        end
    end

    if A.targetRoot then
        local function canEditAlerts()
            local q = U.QuickMenu
            return q and q.previewEnabled == true and A.previewKind ~= nil
        end

        local function saveTargetPosition()
            saveTargetRootPosition()
            A.UpdateTargetMarker()
        end

        local function beginTargetDrag(button)
            if button ~= MOUSE_BUTTON_INDEX_LEFT or not canEditAlerts() then return end
            local q = U.QuickMenu
            if q and q.BeginPreviewHudInteraction then q.BeginPreviewHudInteraction() end
            A.targetDragging = true
            A.targetRoot:SetMovable(true)
            A.targetRoot:StartMoving()
        end

        local function finishTargetDrag(button)
            if button ~= nil and button ~= MOUSE_BUTTON_INDEX_LEFT then return end
            if A.targetDragging ~= true then return end
            A.targetDragging = false
            if A.targetRoot.StopMovingOrResizing then A.targetRoot:StopMovingOrResizing() end
            saveTargetPosition()
            local q = U.QuickMenu
            if q and q.EndPreviewHudInteraction then q.EndPreviewHudInteraction() end
        end

        local function resizeAlerts(delta)
            local q = U.QuickMenu
            if not canEditAlerts() or not q or q.resizeEnabled ~= true or delta == 0 then return end
            local sv = getSettings()
            local current = tonumber(sv and sv.enemyUltimateAlertIconSize) or 54
            if q.BeginPreviewHudInteraction then q.BeginPreviewHudInteraction() end
            A.SetIconSize(current + (delta > 0 and 2 or -2))
            if q.EndPreviewHudInteraction then q.EndPreviewHudInteraction() end
        end

        local function bindTargetDragSurface(surface)
            if not surface or surface.ultiviteEnemyAlertDragBound == true then return end
            surface.ultiviteEnemyAlertDragBound = true
            surface:SetHandler("OnMouseDown", function(_, button) beginTargetDrag(button) end)
            surface:SetHandler("OnMouseUp", function(_, button) finishTargetDrag(button) end)
            surface:SetHandler("OnMouseWheel", function(_, delta) resizeAlerts(delta) end)
        end

        A.targetRoot:SetHandler("OnMoveStop", function()
            if A.targetDragging == true then
                A.targetDragging = false
                saveTargetPosition()
                local q = U.QuickMenu
                if q and q.EndPreviewHudInteraction then q.EndPreviewHudInteraction() end
            end
        end)

        bindTargetDragSurface(A.targetRoot)
        for _, slot in pairs(A.targetSlots or {}) do
            bindTargetDragSurface(slot)
            bindTargetDragSurface(slot and slot.backdrop)
            bindTargetDragSurface(slot and slot.icon)
            bindTargetDragSurface(slot and slot.timer)
        end
    end

    A.Update(true)
end
