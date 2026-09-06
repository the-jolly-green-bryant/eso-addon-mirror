AbilityIDToolkit = AbilityIDToolkit or {}
local AIT = AbilityIDToolkit

local MAX_LOG_DEFAULT = 250
local CAPTURE_WINDOW_MS = 12000

local function SafeAbilityName(id)
    local name = GetAbilityName and GetAbilityName(id) or ""
    if not name or name == "" then return "Unknown Ability" end
    return zo_strformat("<<C:1>>", name)
end

function AIT:InitializeCapture()
    self.capture = {
        active = false,
        startedMs = 0,
        log = {},
        dedupe = {},
        gear = {},
        sessionIndex = 0,
    }
end

function AIT:SnapshotWornSets()
    local found = {}
    if not GetItemLink or not GetItemLinkSetInfo then return found end
    local slots = {
        EQUIP_SLOT_HEAD, EQUIP_SLOT_CHEST, EQUIP_SLOT_SHOULDERS, EQUIP_SLOT_HAND,
        EQUIP_SLOT_WAIST, EQUIP_SLOT_LEGS, EQUIP_SLOT_FEET, EQUIP_SLOT_NECK,
        EQUIP_SLOT_RING1, EQUIP_SLOT_RING2, EQUIP_SLOT_MAIN_HAND, EQUIP_SLOT_OFF_HAND,
        EQUIP_SLOT_BACKUP_MAIN, EQUIP_SLOT_BACKUP_OFF,
    }
    local bySet = {}
    for _, slot in ipairs(slots) do
        local link = GetItemLink(BAG_WORN, slot)
        if link and link ~= "" then
            local hasSet, setName, numBonuses, numEquipped, maxEquipped, setId = GetItemLinkSetInfo(link, false)
            if hasSet and setId and setId ~= 0 then
                local e = bySet[setId] or { setId=setId, name=setName or "Unknown Set", pieces=0 }
                e.pieces = math.max(e.pieces or 0, tonumber(numEquipped) or 0)
                bySet[setId] = e
            end
        end
    end
    for _, e in pairs(bySet) do found[#found + 1] = e end
    table.sort(found, function(a,b) return (a.name or "") < (b.name or "") end)
    return found
end

function AIT:StartCapture()
    self.capture.active = true
    self.capture.startedMs = GetGameTimeMilliseconds()
    self.capture.log = {}
    self.capture.dedupe = {}
    self.capture.gear = self:SnapshotWornSets()
    self.capture.sessionIndex = self.capture.sessionIndex + 1
    self:AppendSystemLine("CAPTURE STARTED", "Proc the set/skill now. Recording unique Effect + Combat events for 12 seconds.")
    self:AppendGearSummary()
    EVENT_MANAGER:RegisterForUpdate(self.name .. "CaptureTimeout", CAPTURE_WINDOW_MS, function()
        EVENT_MANAGER:UnregisterForUpdate(self.name .. "CaptureTimeout")
        if self.capture.active then self:StopCapture("12-second capture window complete") end
    end)
end

function AIT:StopCapture(reason)
    if not self.capture.active then return end
    self.capture.active = false
    EVENT_MANAGER:UnregisterForUpdate(self.name .. "CaptureTimeout")
    self:AppendSystemLine("CAPTURE STOPPED", reason or "Stopped manually")
    self:SaveCaptureSession()
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "Ability ID capture complete - open Ability ID Toolkit to review the results.")
end

function AIT:ClearLog()
    self.capture.log = {}
    self.capture.dedupe = {}
end

function AIT:AppendGearSummary()
    if #self.capture.gear == 0 then
        self:AppendSystemLine("GEAR", "No set information resolved from BAG_WORN.")
        return
    end
    for _, g in ipairs(self.capture.gear) do
        self:AppendSystemLine("GEAR", string.format("%s | Set ID %s | Equipped %s", g.name or "Unknown", tostring(g.setId or 0), tostring(g.pieces or 0)))
    end
end

function AIT:AppendSystemLine(kind, text)
    self.capture.log[#self.capture.log + 1] = { eventType=kind, text=text, timestamp=GetGameTimeMilliseconds() }
    self:TrimLog()
end

function AIT:TrimLog()
    local maxLog = tonumber(self.sv.maxLog) or MAX_LOG_DEFAULT
    while #self.capture.log > maxLog do table.remove(self.capture.log, 1) end
end

function AIT:ShouldAcceptEvent(abilityId, sourceName, targetName)
    if not self.capture.active or not abilityId or abilityId == 0 then return false end
    if self.sv.localPlayerOnly then
        local player = zo_strformat("<<1>>", GetUnitDisplayName("player") or "")
        local source = zo_strformat("<<1>>", sourceName or "")
        if source ~= "" and player ~= "" and source ~= player and source ~= GetUnitName("player") then
            return false
        end
    end
    return true
end

function AIT:AppendCapturedEvent(data)
    local now = GetGameTimeMilliseconds()
    local sig = table.concat({data.eventType or "", data.abilityId or 0, data.sourceName or "", data.targetName or "", data.changeType or data.result or ""}, "|")
    local last = self.capture.dedupe[sig]
    if last and (now - last) < 120 then return end
    self.capture.dedupe[sig] = now

    data.timestamp = now
    data.name = data.name or SafeAbilityName(data.abilityId)
    self.capture.log[#self.capture.log + 1] = data
    self:TrimLog()
    self:AddDiscovery(data.abilityId, data)
end

function AIT:OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    if not self.sv.captureEffectEvents then return end
    local sourceName = ""
    local targetName = unitName or (unitTag and GetUnitDisplayName(unitTag)) or ""
    if not self:ShouldAcceptEvent(abilityId, sourceName, targetName) then return end
    local duration = 0
    if tonumber(endTime) and tonumber(beginTime) then duration = math.max(0, endTime - beginTime) end
    self:AppendCapturedEvent({
        eventType="EFFECT",
        abilityId=abilityId,
        name=effectName ~= "" and effectName or SafeAbilityName(abilityId),
        sourceName=sourceName,
        targetName=targetName,
        unitTag=unitTag,
        changeType=changeType,
        duration=duration,
        stacks=stackCount,
        icon=iconName,
        buffType=buffType,
        effectType=effectType,
        abilityType=abilityType,
        statusEffectType=statusEffectType,
        unitId=unitId,
        sourceType=sourceType,
    })
end

function AIT:OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if not self.sv.captureCombatEvents then return end
    if not self:ShouldAcceptEvent(abilityId, sourceName, targetName) then return end
    self:AppendCapturedEvent({
        eventType="COMBAT",
        abilityId=abilityId,
        name=abilityName ~= "" and abilityName or SafeAbilityName(abilityId),
        sourceName=sourceName,
        targetName=targetName,
        result=result,
        hitValue=hitValue,
        powerType=powerType,
        damageType=damageType,
        sourceType=sourceType,
        targetType=targetType,
        sourceUnitId=sourceUnitId,
        targetUnitId=targetUnitId,
        overflow=overflow,
    })
end

function AIT:SaveCaptureSession()
    local saved = { timestamp=GetTimeStamp(), gear=self.capture.gear, entries={} }
    for _, e in ipairs(self.capture.log) do
        if e.abilityId then
            saved.entries[#saved.entries + 1] = {
                abilityId=e.abilityId, name=e.name, eventType=e.eventType, duration=e.duration,
                changeType=e.changeType, result=e.result, sourceName=e.sourceName, targetName=e.targetName,
                stacks=e.stacks, hitValue=e.hitValue,
            }
        end
    end
    self.sv.sessions[#self.sv.sessions + 1] = saved
    while #self.sv.sessions > 20 do table.remove(self.sv.sessions, 1) end
end

function AIT:RegisterCaptureEvents()
    EVENT_MANAGER:RegisterForEvent(self.name .. "Effect", EVENT_EFFECT_CHANGED, function(...) self:OnEffectChanged(...) end)
    EVENT_MANAGER:RegisterForEvent(self.name .. "Combat", EVENT_COMBAT_EVENT, function(...) self:OnCombatEvent(...) end)
end
