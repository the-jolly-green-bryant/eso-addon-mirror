SugasTestZoneBBTCadence = SugasTestZoneBBTCadence or {}
local Project = SugasTestZoneBBTCadence
local Tracker = {}
Project.Tracker = Tracker

local UPDATE_NAME = "Sugas-Test-Zone_BBTCadence_Update"
local lastCenterAlertMs = 0

local function NowMs()
    if type(GetFrameTimeMilliseconds) == "function" then
        return GetFrameTimeMilliseconds()
    end
    if type(GetGameTimeMilliseconds) == "function" then
        return GetGameTimeMilliseconds()
    end
    return 0
end

local function Chat(text)
    if CHAT_ROUTER and type(CHAT_ROUTER.AddSystemMessage) == "function" then
        CHAT_ROUTER:AddSystemMessage("[STZ BBT] " .. tostring(text))
    elseif type(d) == "function" then
        d("[STZ BBT] " .. tostring(text))
    end
end

local function AlertTopRight(message)
    if type(ZO_Alert) == "function" then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS and SOUNDS.NEGATIVE_CLICK or nil,
            "|cFFFFFF[BBT]|r " .. tostring(message))
    end
end

local function AlertCenter(message)
    local now = NowMs()
    local delay = math.max(0, lastCenterAlertMs + 2000 - now)
    if type(zo_callLater) ~= "function" then return end
    zo_callLater(function()
        local csa = CENTER_SCREEN_ANNOUNCE
        if csa and type(csa.CreateMessageParams) == "function" then
            local params = csa:CreateMessageParams(
                CSA_CATEGORY_LARGE_TEXT,
                SOUNDS and SOUNDS.CHAMPION_POINT_GAINED or nil
            )
            params:SetText(message)
            params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_CHAMPION_POINT_GAINED)
            params:MarkSuppressIconFrame()
            csa:DisplayMessage(params)
        elseif type(ZO_Alert) == "function" then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, message)
        end
        lastCenterAlertMs = NowMs()
    end, delay)
end

local function GetBarSettings(hotbar)
    if hotbar == HOTBAR_CATEGORY_PRIMARY then return Project.sv.frontSlots end
    return Project.sv.backSlots
end

local function IsSlotEnabled(hotbar, slot)
    local settings = GetBarSettings(hotbar)
    return type(settings) == "table" and settings[slot] ~= false
end

local function ResolveAbilityId(slot, hotbar)
    if type(GetSlotBoundId) ~= "function" then return 0 end
    local id = tonumber(GetSlotBoundId(slot, hotbar)) or 0
    if id <= 0 then return 0 end
    if type(GetSlotType) == "function"
        and ACTION_TYPE_CRAFTED_ABILITY ~= nil
        and GetSlotType(slot, hotbar) == ACTION_TYPE_CRAFTED_ABILITY
        and type(GetAbilityIdForCraftedAbilityId) == "function" then
        return tonumber(GetAbilityIdForCraftedAbilityId(id)) or id
    end
    return id
end

local function GetStaticDurationMs(abilityId)
    if abilityId <= 0 or type(GetAbilityDuration) ~= "function" then return 0 end
    local duration = tonumber(GetAbilityDuration(abilityId, nil, "player")) or 0
    if duration > 0 and duration < 1000 then return 500 end
    return duration
end

local function IsRelevantRecord(record, hotbar)
    if not record or not record.active then return false end
    if Project.sv.mode == "hud" then
        return IsSlotEnabled(hotbar, record.slot)
            and (tonumber(record.durationMs) or 0) >= Project.Config.minimumDurationMs
    end
    return hotbar == HOTBAR_CATEGORY_BACKUP
end

function Tracker:BuildCache(reason)
    for _, hotbar in ipairs({ HOTBAR_CATEGORY_PRIMARY, HOTBAR_CATEGORY_BACKUP }) do
        for slot = Project.Config.firstSlot, Project.Config.lastSlot do
            local record = Project.State:GetRecord(hotbar, slot)
            local id = ResolveAbilityId(slot, hotbar)
            if record.id ~= id then
                record.endTimeMs = 0
                record.active = false
                record.alerted = false
                record.source = ""
            end
            record.id = id
            record.name = type(GetSlotName) == "function" and tostring(GetSlotName(slot, hotbar) or "") or ""
            record.icon = type(GetSlotTexture) == "function" and tostring(GetSlotTexture(slot, hotbar) or "") or ""
            record.staticDurationMs = GetStaticDurationMs(id)
        end
    end
    Project:Log("Slot cache rebuilt: " .. tostring(reason or "manual"))
end

function Tracker:SetTimer(hotbar, slot, durationMs, remainingMs, source)
    local record = Project.State:GetRecord(hotbar, slot)
    if not record or record.id <= 0 then return false end
    durationMs = tonumber(durationMs) or 0
    remainingMs = tonumber(remainingMs) or durationMs
    if durationMs <= 0 or remainingMs <= 0 then return false end

    record.durationMs = durationMs
    record.endTimeMs = NowMs() + remainingMs
    record.active = true
    record.alerted = false
    record.source = tostring(source or "unknown")
    self:RefreshScheduler()
    return true
end

function Tracker:SyncNativeTimer(hotbar, slot)
    if type(GetActionSlotEffectDuration) ~= "function"
        or type(GetActionSlotEffectTimeRemaining) ~= "function" then
        return false
    end
    local duration = tonumber(GetActionSlotEffectDuration(slot, hotbar)) or 0
    local remaining = tonumber(GetActionSlotEffectTimeRemaining(slot, hotbar)) or 0
    if duration > 0 and remaining > 0 then
        return self:SetTimer(hotbar, slot, duration, remaining, "native")
    end

    local record = Project.State:GetRecord(hotbar, slot)
    if record and record.source == "native" and remaining <= 0 then
        record.active = false
        record.endTimeMs = 0
    end
    return false
end

function Tracker:StartFallbackTimer(hotbar, slot)
    local record = Project.State:GetRecord(hotbar, slot)
    if not record then return false end
    local duration = tonumber(record.staticDurationMs) or 0
    if duration <= 0 then return false end
    return self:SetTimer(hotbar, slot, duration, duration, "ability")
end

function Tracker:QueueNativeRetry(hotbar, slot)
    if type(zo_callLater) ~= "function" then return end
    zo_callLater(function()
        if not Tracker:SyncNativeTimer(hotbar, slot) then
            Tracker:StartFallbackTimer(hotbar, slot)
        end
    end, 60)
    zo_callLater(function() Tracker:SyncNativeTimer(hotbar, slot) end, 220)
end

function Tracker:OnAbilityUsed(_, slot)
    slot = tonumber(slot) or 0
    if slot < Project.Config.firstSlot or slot > Project.Config.lastSlot then return end
    local hotbar = type(GetActiveHotbarCategory) == "function"
        and GetActiveHotbarCategory() or HOTBAR_CATEGORY_PRIMARY
    if hotbar ~= HOTBAR_CATEGORY_PRIMARY and hotbar ~= HOTBAR_CATEGORY_BACKUP then return end

    self:BuildCache("ability used")
    local record = Project.State:GetRecord(hotbar, slot)
    if not record or record.id <= 0 then return end

    Project.State.pending[hotbar .. ":" .. slot] = {
        hotbar = hotbar,
        slot = slot,
        abilityId = record.id,
        startedMs = NowMs(),
    }

    if not self:SyncNativeTimer(hotbar, slot) then
        self:StartFallbackTimer(hotbar, slot)
    end
    self:QueueNativeRetry(hotbar, slot)
end

function Tracker:OnSlotEffectUpdated(_, hotbar, slot)
    if hotbar ~= HOTBAR_CATEGORY_PRIMARY and hotbar ~= HOTBAR_CATEGORY_BACKUP then return end
    slot = tonumber(slot) or 0
    if slot < Project.Config.firstSlot or slot > Project.Config.lastSlot then return end
    self:BuildCache("slot effect")
    self:SyncNativeTimer(hotbar, slot)
    self:RefreshScheduler()
end

function Tracker:OnEffectChanged(_, changeType, _, _, unitTag, beginTime, endTime,
        _, _, _, _, _, _, _, _, abilityId)
    if unitTag ~= "player" then return end
    if changeType ~= EFFECT_RESULT_GAINED
        and changeType ~= EFFECT_RESULT_FULL_REFRESH
        and changeType ~= EFFECT_RESULT_UPDATED then return end

    local durationSeconds = (tonumber(endTime) or 0) - (tonumber(beginTime) or 0)
    if durationSeconds <= 0 then return end
    local now = NowMs()
    for key, pending in pairs(Project.State.pending) do
        if now - pending.startedMs > Project.Config.pendingEffectWindowMs then
            Project.State.pending[key] = nil
        elseif pending.abilityId == tonumber(abilityId) then
            self:SetTimer(pending.hotbar, pending.slot,
                durationSeconds * 1000, durationSeconds * 1000, "effect")
            Project.State.pending[key] = nil
        end
    end
end

function Tracker:HasRelevantTimers(now)
    for _, hotbar in ipairs({ HOTBAR_CATEGORY_PRIMARY, HOTBAR_CATEGORY_BACKUP }) do
        for slot = Project.Config.firstSlot, Project.Config.lastSlot do
            local record = Project.State:GetRecord(hotbar, slot)
            if record and record.active and record.endTimeMs > now
                and IsRelevantRecord(record, hotbar) then
                return true
            end
        end
    end
    return false
end

function Tracker:NeedsScheduler()
    local now = NowMs()
    if self:HasRelevantTimers(now) then return true end
    if Project.State.inCombat and Project.sv.mode == "hud" then
        if Project.sv.blockCadence then return true end
        if Project.State.lightCadenceStartedMs then return true end
    end
    return false
end

function Tracker:RefreshScheduler()
    local needed = self:NeedsScheduler()
    if needed and not self.schedulerRunning then
        EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, Project.Config.updateIntervalMs, function()
            Tracker:OnUpdate()
        end)
        self.schedulerRunning = true
    elseif not needed and self.schedulerRunning then
        EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
        self.schedulerRunning = false
    end
end

function Tracker:ExpireTimers(now)
    for _, hotbar in ipairs({ HOTBAR_CATEGORY_PRIMARY, HOTBAR_CATEGORY_BACKUP }) do
        for slot = Project.Config.firstSlot, Project.Config.lastSlot do
            local record = Project.State:GetRecord(hotbar, slot)
            if record.active and record.endTimeMs <= now then
                record.active = false
                record.endTimeMs = 0
            end
        end
    end
end

function Tracker:UpdateCadence(now)
    local state = Project.State
    if not state.inCombat or Project.sv.mode ~= "hud" then return end

    if Project.sv.blockCadence and type(IsBlockActive) == "function" then
        local blocking = IsBlockActive() == true
        if blocking and not state.blockWasActive and not state.blockCadenceStartedMs then
            state.blockCadenceStartedMs = now
            state.blockLastPulse = -1
            Project:Log("Block cadence started")
        end
        state.blockWasActive = blocking
    end

    if state.blockCadenceStartedMs then
        local pulse = math.floor((now - state.blockCadenceStartedMs) / Project.Config.cadencePeriodMs)
        if pulse >= 1 and pulse ~= state.blockLastPulse then
            state.blockLastPulse = pulse
            state.blockPulseUntilMs = now + Project.Config.cadencePulseMs
        end
    end

    if state.lightCadenceStartedMs then
        local pulse = math.floor((now - state.lightCadenceStartedMs) / Project.Config.cadencePeriodMs)
        if pulse >= 1 and pulse ~= state.lightLastPulse then
            state.lightLastPulse = pulse
            state.lightPulseUntilMs = now + Project.Config.cadencePulseMs
        end
    end
end

function Tracker:UpdateLegacyAlerts(now)
    if Project.sv.mode == "hud" then return end
    local active = {}
    for slot = Project.Config.firstSlot, Project.Config.lastSlot do
        local record = Project.State:GetRecord(HOTBAR_CATEGORY_BACKUP, slot)
        if record and record.active and record.endTimeMs > now then
            active[#active + 1] = { record = record, remain = record.endTimeMs - now }
        end
    end
    if #active == 0 then return end

    local leadMs = (tonumber(Project.sv.leadSeconds) or 2) * 1000
    if Project.sv.mode == "pve" then
        for _, entry in ipairs(active) do
            if entry.remain <= leadMs and not entry.record.alerted then
                AlertTopRight("Recast " .. (entry.record.name ~= "" and entry.record.name or "skill") .. "!")
                entry.record.alerted = true
            end
        end
        return
    end

    table.sort(active, function(a, b) return a.remain < b.remain end)
    local clusters = {}
    local current = nil
    for _, entry in ipairs(active) do
        if not current or entry.remain - current.lastRemain > Project.Config.clusterWindowMs then
            current = { items = {}, minimum = entry.remain, lastRemain = entry.remain, sum = 0 }
            clusters[#clusters + 1] = current
        end
        current.items[#current.items + 1] = entry
        current.minimum = math.min(current.minimum, entry.remain)
        current.lastRemain = entry.remain
        current.sum = current.sum + entry.remain
    end

    local nextAlerted = {}
    for _, cluster in ipairs(clusters) do
        local keyParts = {}
        for _, entry in ipairs(cluster.items) do keyParts[#keyParts + 1] = tostring(entry.record.slot) end
        table.sort(keyParts)
        local key = table.concat(keyParts, "-")
        local remaining = cluster.minimum
        if #clusters == 1
            and active[#active].remain - active[1].remain <= Project.Config.clusterWindowMs then
            remaining = cluster.sum / #cluster.items
        end
        if remaining <= leadMs then
            nextAlerted[key] = true
            if not Project.State.clusterAlerted[key] then
                AlertCenter("|c00FF00Back |cFFCC00Bar |cFF0000Buffs|r")
            end
        end
    end
    Project.State.clusterAlerted = nextAlerted
end

function Tracker:OnUpdate()
    local now = NowMs()
    self:ExpireTimers(now)
    self:UpdateCadence(now)
    self:UpdateLegacyAlerts(now)
    Project.HUD:Refresh(now)
    self:RefreshScheduler()
end

function Tracker:OnCombatState(_, inCombat)
    Project.State.inCombat = inCombat == true
    if not Project.State.inCombat then
        Project.State:ClearCadence()
    end
    Project.HUD:Refresh(NowMs())
    self:RefreshScheduler()
end

function Tracker:OnCombatEvent(_, _, isError, _, _, actionSlotType,
        _, sourceType)
    if isError or not Project.State.inCombat then return end
    if Project.sv.mode ~= "hud" or not Project.sv.lightCadence then return end
    if sourceType ~= COMBAT_UNIT_TYPE_PLAYER then return end
    if actionSlotType ~= ACTION_SLOT_TYPE_LIGHT_ATTACK then return end
    if Project.State.lightCadenceStartedMs then return end

    Project.State.lightCadenceStartedMs = NowMs()
    Project.State.lightLastPulse = -1
    Project:Log("Light-attack cadence started")
    self:RefreshScheduler()
end

function Tracker:OnLayoutChanged()
    self:BuildCache("layout changed")
    for _, hotbar in ipairs({ HOTBAR_CATEGORY_PRIMARY, HOTBAR_CATEGORY_BACKUP }) do
        for slot = Project.Config.firstSlot, Project.Config.lastSlot do
            self:SyncNativeTimer(hotbar, slot)
        end
    end
    self:RefreshScheduler()
end

function Tracker:Initialize()
    self:BuildCache("initialization")
    local prefix = "Sugas-Test-Zone_BBTCadence_"

    EVENT_MANAGER:RegisterForEvent(prefix .. "Used", EVENT_ACTION_SLOT_ABILITY_USED,
        function(...) self:OnAbilityUsed(...) end)
    if EVENT_ACTION_SLOT_EFFECT_UPDATE then
        EVENT_MANAGER:RegisterForEvent(prefix .. "SlotEffect", EVENT_ACTION_SLOT_EFFECT_UPDATE,
            function(...) self:OnSlotEffectUpdated(...) end)
    end
    if EVENT_EFFECT_CHANGED then
        EVENT_MANAGER:RegisterForEvent(prefix .. "Effect", EVENT_EFFECT_CHANGED,
            function(...) self:OnEffectChanged(...) end)
        if type(EVENT_MANAGER.AddFilterForEvent) == "function" then
            EVENT_MANAGER:AddFilterForEvent(prefix .. "Effect", EVENT_EFFECT_CHANGED,
                REGISTER_FILTER_UNIT_TAG, "player")
        end
    end
    EVENT_MANAGER:RegisterForEvent(prefix .. "Combat", EVENT_PLAYER_COMBAT_STATE,
        function(...) self:OnCombatState(...) end)
    EVENT_MANAGER:RegisterForEvent(prefix .. "Full", EVENT_ACTION_SLOTS_FULL_UPDATE,
        function() self:OnLayoutChanged() end)
    if EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED then
        EVENT_MANAGER:RegisterForEvent(prefix .. "AllBars", EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED,
            function() self:OnLayoutChanged() end)
    end
    if EVENT_ACTIVE_WEAPON_PAIR_CHANGED then
        EVENT_MANAGER:RegisterForEvent(prefix .. "WeaponPair", EVENT_ACTIVE_WEAPON_PAIR_CHANGED,
            function() self:OnLayoutChanged() end)
    end
    if EVENT_ARMORY_BUILD_RESTORE_RESPONSE then
        EVENT_MANAGER:RegisterForEvent(prefix .. "Armory", EVENT_ARMORY_BUILD_RESTORE_RESPONSE,
            function(_, result)
                if result == ARMORY_BUILD_RESTORE_RESULT_SUCCESS and type(zo_callLater) == "function" then
                    zo_callLater(function() self:OnLayoutChanged() end, 500)
                end
            end)
    end
    EVENT_MANAGER:RegisterForEvent(prefix .. "Player", EVENT_PLAYER_ACTIVATED,
        function()
            if type(zo_callLater) == "function" then
                zo_callLater(function() self:OnLayoutChanged() end, 500)
            end
        end)
    EVENT_MANAGER:RegisterForEvent(prefix .. "Light", EVENT_COMBAT_EVENT,
        function(...) self:OnCombatEvent(...) end)
    if type(EVENT_MANAGER.AddFilterForEvent) == "function" then
        EVENT_MANAGER:AddFilterForEvent(prefix .. "Light", EVENT_COMBAT_EVENT,
            REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    end

    Project.State.inCombat = type(IsUnitInCombat) == "function" and IsUnitInCombat("player") == true
    self:RefreshScheduler()
    Chat("Experiment " .. Project.Config.version .. " initialized in " .. tostring(Project.sv.mode) .. " mode.")
end
