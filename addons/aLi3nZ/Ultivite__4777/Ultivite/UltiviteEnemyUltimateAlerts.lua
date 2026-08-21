local U = Ultivite
if not U then return end

U.EnemyUltimateAlerts = U.EnemyUltimateAlerts or {}
local A = U.EnemyUltimateAlerts
local Combat = U.Combat

local EVENT_PREFIX = "UltiviteEnemyUltimateAlert"
local UPDATE_NAME = EVENT_PREFIX .. "Update"
local RETICLE_EVENT_NAME = EVENT_PREFIX .. "Reticle"
local UPDATE_MS = 50
local CORROSIVE_SKILL_ID = 33852
local CORROSIVE_DURATION_MS = 10000
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
A.globalRoot = nil
A.targetRoot = nil
A.globalRows = A.globalRows or {}
A.targetSlots = A.targetSlots or {}

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
    if U.RequestSettingsSave then U.RequestSettingsSave() end
end

local function diagnostic(message)
    if Combat and Combat.DiagnosticChat then Combat.DiagnosticChat(message) end
end

local function resolveIcon(kind)
    local abilityId = kind == "corrosive" and CORROSIVE_SKILL_ID or 83229
    if GetAbilityIcon then
        local ok, icon = pcall(GetAbilityIcon, abilityId)
        if ok and icon and icon ~= "" then return icon end
    end
    if kind == "corrosive" then
        return "EsoUI/Art/Icons/ability_dragonknight_018_b.dds"
    end
    return "EsoUI/Art/Icons/icon_missing.dds"
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

    for _, row in pairs(A.globalRows or {}) do
        local rowSize = zo_clamp(math.floor(size * 0.86), 34, 72)
        row:SetDimensions(480, rowSize + 6)
        row.icon:SetDimensions(rowSize, rowSize)
        row.icon:ClearAnchors()
        row.icon:SetAnchor(LEFT, row, LEFT, 0, 0)
        row.label:ClearAnchors()
        row.label:SetAnchor(LEFT, row.icon, RIGHT, 10, 0)
        row.label:SetDimensions(410, rowSize)
        row.label:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", zo_clamp(math.floor(rowSize * 0.42), 18, 28)))
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
    if id == CORROSIVE_SKILL_ID or A.learnedCorrosiveIds[id] == true then return true end

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

    -- Corrosive ticks arrive every second. The original DKcorrosiveAlert logic
    -- treats those hits as proof that the nearby source currently has Corrosive
    -- active. Keep the first activation window instead of adding ten seconds on
    -- every tick. Onslaught is a one-hit trigger, so a repeated valid hit may
    -- safely refresh its eight-second window.
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
        if kind == "onslaught" then existing.expiresAtMs = now + duration end
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
    if COMBAT_UNIT_TYPE_PLAYER ~= nil and targetType ~= nil then
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

local function onCorrosiveCombatEvent(_, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    if isError then return end
    if not eventTargetsLocalPlayer(targetName, targetType) then return end
    if tonumber(hitValue) and tonumber(hitValue) <= 0 then return end
    if not isCorrosiveEvent(abilityName, abilityGraphic, abilityId) then return end
    recordAlert("corrosive", sourceName, sourceUnitId, abilityId)
end

local function onOnslaughtCombatEvent(_, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    if isError then return end
    if not eventTargetsLocalPlayer(targetName, targetType) then return end
    if tonumber(hitValue) and tonumber(hitValue) <= 0 then return end
    if not isOnslaughtEvent(abilityName, abilityId) then return end
    recordAlert("onslaught", sourceName, sourceUnitId, abilityId)
end

local function onDiscoveryCombatEvent(_, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    -- Reliability fallback based on the original addon behaviour: inspect only
    -- real incoming damage to the local player. This catches internal ZOS damage
    -- IDs that differ from the public skill ID while keeping normal outgoing and
    -- non-damage combat traffic out of Lua.
    if isError then return end
    if not eventTargetsLocalPlayer(targetName, targetType) then return end
    if tonumber(hitValue) and tonumber(hitValue) <= 0 then return end

    local sv = getSettings()
    if not sv then return end
    local id = tonumber(abilityId) or 0

    if sv.showEnemyCorrosiveAlert ~= false
        and id ~= CORROSIVE_SKILL_ID
        and A.learnedCorrosiveIds[id] ~= true
        and isCorrosiveEvent(abilityName, abilityGraphic, id) then
        recordAlert("corrosive", sourceName, sourceUnitId, id)
        return
    end

    if sv.showEnemyOnslaughtAlert ~= false
        and not ONSLAUGHT_ABILITY_IDS[id]
        and not (A.learnedOnslaughtIds and A.learnedOnslaughtIds[id] == true)
        and isOnslaughtEvent(abilityName, id) then
        recordAlert("onslaught", sourceName, sourceUnitId, id)
    end
end

local function buildDamageResults()
    local results, seen = {}, {}
    local function add(result)
        if result ~= nil and not seen[result] then
            seen[result] = true
            results[#results + 1] = result
        end
    end
    -- These are the result types used by DKcorrosiveAlert / the longstanding
    -- Onslaught combat-event approach. Shielded and blocked damage are retained
    -- as well so the alert still fires when the hit is absorbed.
    add(ACTION_RESULT_DAMAGE)
    add(ACTION_RESULT_CRITICAL_DAMAGE)
    add(ACTION_RESULT_DOT_TICK)
    add(ACTION_RESULT_DOT_TICK_CRITICAL)
    add(ACTION_RESULT_DAMAGE_SHIELDED)
    add(ACTION_RESULT_BLOCKED_DAMAGE)
    return results
end

local function registerCombatEvent(uniqueName, result, abilityId, callback)
    EVENT_MANAGER:RegisterForEvent(uniqueName, EVENT_COMBAT_EVENT, callback)

    -- Match the original warning addon's proven incoming-player registration
    -- path: UNIT_TAG "player" + one combat result + (when known) ability ID.
    -- Never filter SOURCE combat unit type. In PvP the hostile source is not
    -- COMBAT_UNIT_TYPE_PLAYER; that constant identifies the local player/self.
    local hasUnitTag = REGISTER_FILTER_UNIT_TAG ~= nil
    local hasTargetType = REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE ~= nil and COMBAT_UNIT_TYPE_PLAYER ~= nil
    local hasError = REGISTER_FILTER_IS_ERROR ~= nil
    local hasAbility = abilityId ~= nil and REGISTER_FILTER_ABILITY_ID ~= nil

    if hasUnitTag and hasError and hasAbility then
        EVENT_MANAGER:AddFilterForEvent(uniqueName, EVENT_COMBAT_EVENT,
            REGISTER_FILTER_UNIT_TAG, "player",
            REGISTER_FILTER_COMBAT_RESULT, result,
            REGISTER_FILTER_IS_ERROR, false,
            REGISTER_FILTER_ABILITY_ID, abilityId)
    elseif hasUnitTag and hasAbility then
        EVENT_MANAGER:AddFilterForEvent(uniqueName, EVENT_COMBAT_EVENT,
            REGISTER_FILTER_UNIT_TAG, "player",
            REGISTER_FILTER_COMBAT_RESULT, result,
            REGISTER_FILTER_ABILITY_ID, abilityId)
    elseif hasUnitTag and hasError then
        EVENT_MANAGER:AddFilterForEvent(uniqueName, EVENT_COMBAT_EVENT,
            REGISTER_FILTER_UNIT_TAG, "player",
            REGISTER_FILTER_COMBAT_RESULT, result,
            REGISTER_FILTER_IS_ERROR, false)
    elseif hasUnitTag then
        EVENT_MANAGER:AddFilterForEvent(uniqueName, EVENT_COMBAT_EVENT,
            REGISTER_FILTER_UNIT_TAG, "player",
            REGISTER_FILTER_COMBAT_RESULT, result)
    elseif hasTargetType and hasError and hasAbility then
        EVENT_MANAGER:AddFilterForEvent(uniqueName, EVENT_COMBAT_EVENT,
            REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER,
            REGISTER_FILTER_COMBAT_RESULT, result,
            REGISTER_FILTER_IS_ERROR, false,
            REGISTER_FILTER_ABILITY_ID, abilityId)
    elseif hasTargetType and hasAbility then
        EVENT_MANAGER:AddFilterForEvent(uniqueName, EVENT_COMBAT_EVENT,
            REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER,
            REGISTER_FILTER_COMBAT_RESULT, result,
            REGISTER_FILTER_ABILITY_ID, abilityId)
    elseif hasTargetType and hasError then
        EVENT_MANAGER:AddFilterForEvent(uniqueName, EVENT_COMBAT_EVENT,
            REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER,
            REGISTER_FILTER_COMBAT_RESULT, result,
            REGISTER_FILTER_IS_ERROR, false)
    elseif hasTargetType then
        EVENT_MANAGER:AddFilterForEvent(uniqueName, EVENT_COMBAT_EVENT,
            REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER,
            REGISTER_FILTER_COMBAT_RESULT, result)
    elseif hasAbility then
        EVENT_MANAGER:AddFilterForEvent(uniqueName, EVENT_COMBAT_EVENT,
            REGISTER_FILTER_COMBAT_RESULT, result,
            REGISTER_FILTER_ABILITY_ID, abilityId)
    else
        EVENT_MANAGER:AddFilterForEvent(uniqueName, EVENT_COMBAT_EVENT,
            REGISTER_FILTER_COMBAT_RESULT, result)
    end
    A.registeredEvents[#A.registeredEvents + 1] = uniqueName
end

function A.RefreshEventRegistration()
    for _, eventName in ipairs(A.registeredEvents or {}) do
        EVENT_MANAGER:UnregisterForEvent(eventName, EVENT_COMBAT_EVENT)
    end
    A.registeredEvents = {}

    local sv = getSettings()
    if not sv then return end
    local results = buildDamageResults()

    if sv.showEnemyCorrosiveAlert ~= false then
        local exactIds = { [CORROSIVE_SKILL_ID] = true }
        for learnedId in pairs(A.learnedCorrosiveIds) do
            learnedId = tonumber(learnedId)
            if learnedId and learnedId > 0 then exactIds[learnedId] = true end
        end
        for abilityId in pairs(exactIds) do
            for _, result in ipairs(results) do
                registerCombatEvent(EVENT_PREFIX .. "Corrosive" .. tostring(abilityId) .. "_" .. tostring(result), result, abilityId, onCorrosiveCombatEvent)
            end
        end
    end

    if sv.showEnemyOnslaughtAlert ~= false then
        local exactIds = {}
        for abilityId in pairs(ONSLAUGHT_ABILITY_IDS) do exactIds[abilityId] = true end
        for abilityId in pairs(A.learnedOnslaughtIds or {}) do
            abilityId = tonumber(abilityId)
            if abilityId and abilityId > 0 then exactIds[abilityId] = true end
        end
        for abilityId in pairs(exactIds) do
            for _, result in ipairs(results) do
                registerCombatEvent(EVENT_PREFIX .. "Onslaught" .. tostring(abilityId) .. "_" .. tostring(result), result, abilityId, onOnslaughtCombatEvent)
            end
        end
    end

    -- One narrow incoming-damage discovery path handles ZOS internal-ID changes
    -- for both warnings. It is target/result filtered in C before Lua sees it.
    if sv.showEnemyCorrosiveAlert ~= false or sv.showEnemyOnslaughtAlert ~= false then
        for _, result in ipairs(results) do
            registerCombatEvent(EVENT_PREFIX .. "Discovery_" .. tostring(result), result, nil, onDiscoveryCombatEvent)
        end
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
        if id == CORROSIVE_SKILL_ID or lower(effectName):find("corrosive armor", 1, true) then
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

local function projectReticleHead()
    if not Combat or not Combat.CreateWorldTargetProbe or not GetUnitWorldPosition or not WorldPositionToGuiRender3DPosition then return nil, nil end
    Combat.CreateWorldTargetProbe()
    local probe = Combat.worldProbe
    if not probe then return nil, nil end

    local ok, zoneId, x, y, z = pcall(GetUnitWorldPosition, "reticleover")
    if not ok or not zoneId or tonumber(zoneId) == 0 then return nil, nil end
    x, y, z = tonumber(x), tonumber(y), tonumber(z)
    if not x or not y or not z or (x == 0 and y == 0 and z == 0) then return nil, nil end

    local headOffsetCm = tonumber(Combat and Combat.sv and Combat.sv.targetHeadOffsetCm) or 220
    local okRender, rx, ry, rz = pcall(WorldPositionToGuiRender3DPosition, x, y + headOffsetCm, z)
    if not okRender or not rx or not ry or not rz then return nil, nil end
    local okOrigin = pcall(probe.Set3DRenderSpaceOrigin, probe, rx, ry, rz)
    if not okOrigin then return nil, nil end

    local sx, sy
    if probe.ProjectToScreen then
        local okProject, px, py = pcall(probe.ProjectToScreen, probe, 0.5, 0.5)
        if okProject then sx, sy = tonumber(px), tonumber(py) end
    elseif probe.ProjectRectToScreenAndComputeAABBPoint then
        local okProject, px, py = pcall(probe.ProjectRectToScreenAndComputeAABBPoint, probe, CENTER)
        if okProject then sx, sy = tonumber(px), tonumber(py) end
    end
    if not sx or not sy then return nil, nil end

    local w, h = GuiRoot:GetDimensions()
    if sx < -100 or sy < -100 or sx > (tonumber(w) or 0) + 100 or sy > (tonumber(h) or 0) + 100 then return nil, nil end
    return sx, sy
end

local function updateTargetSlot(slot, entry, previewSeconds)
    if not slot then return false end
    if not entry and not previewSeconds then slot:SetHidden(true); return false end
    local remaining = previewSeconds or math.max(0, ((entry.expiresAtMs or 0) - nowMs()) / 1000)
    slot.timer:SetText(string.format("%.1f", remaining))
    slot:SetHidden(false)
    return true
end

function A.UpdateTargetMarker()
    if not A.targetRoot then return end
    local preview = A.previewKind
    if preview then
        local showCorrosive = preview == "corrosive"
        local showOnslaught = preview == "onslaught"
        updateTargetSlot(A.targetSlots.corrosive, nil, showCorrosive and 10.0 or nil)
        updateTargetSlot(A.targetSlots.onslaught, nil, showOnslaught and 8.0 or nil)
        A.targetRoot:ClearAnchors()
        local target = getReticleTarget()
        local sx, sy
        if target then sx, sy = projectReticleHead() end
        if sx and sy then
            A.targetRoot:SetAnchor(BOTTOM, GuiRoot, TOPLEFT, sx, sy - 8)
        else
            A.targetRoot:SetAnchor(CENTER, GuiRoot, CENTER, 0, -115)
        end
        A.targetRoot:SetHidden(false)
        A.targetRoot:SetMouseEnabled(true)
        return
    end

    A.targetRoot:SetMouseEnabled(false)
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
    -- the warning, show the relevant ultimate icon above that player's body.
    local corrosive = findForTarget("corrosive", target.unitId, target.charName, target.displayName)
    local onslaught = findForTarget("onslaught", target.unitId, target.charName, target.displayName)
    if corrosive then refineCorrosiveFromReticle(corrosive) end

    local showCorrosive = updateTargetSlot(A.targetSlots.corrosive, corrosive, nil)
    local showOnslaught = updateTargetSlot(A.targetSlots.onslaught, onslaught, nil)
    if not showCorrosive and not showOnslaught then
        A.targetRoot:SetHidden(true)
        return
    end

    A.targetRoot:ClearAnchors()
    local sx, sy = projectReticleHead()
    if sx and sy then
        A.targetRoot:SetAnchor(BOTTOM, GuiRoot, TOPLEFT, sx, sy - 8)
    else
        -- World projection is not always exposed for hostile players in PvP.
        -- Keep the icon directly above the reticle only while that same player
        -- is under the mouse, rather than attaching it to a different/stale UI.
        A.targetRoot:SetAnchor(CENTER, GuiRoot, CENTER, 0, -115)
    end
    A.targetRoot:SetHidden(false)
end

function A.UpdateGlobalAlert()
    if not A.globalRoot then return end
    if A.previewKind then
        A.globalRoot:SetHidden(true)
        return
    end

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
    if kind ~= "corrosive" and kind ~= "onslaught" then kind = nil end
    A.previewKind = kind
    if kind then A.StartUpdateLoop() end
    A.Update(true)
end

function A.Initialize()
    if A.initialized then return end
    A.initialized = true
    A.CreateUI()
    A.RefreshEventRegistration()

    if EVENT_RETICLE_TARGET_CHANGED then
        EVENT_MANAGER:RegisterForEvent(RETICLE_EVENT_NAME, EVENT_RETICLE_TARGET_CHANGED, function() A.Update(true) end)
    end

    if A.targetRoot then
        A.targetRoot:SetHandler("OnMouseWheel", function(_, delta)
            local q = U.QuickMenu
            if not q or q.previewEnabled ~= true or q.resizeEnabled ~= true or not A.previewKind or delta == 0 then return end
            local sv = getSettings()
            local current = tonumber(sv and sv.enemyUltimateAlertIconSize) or 54
            A.SetIconSize(current + (delta > 0 and 2 or -2))
        end)
    end

    A.Update(true)
end
