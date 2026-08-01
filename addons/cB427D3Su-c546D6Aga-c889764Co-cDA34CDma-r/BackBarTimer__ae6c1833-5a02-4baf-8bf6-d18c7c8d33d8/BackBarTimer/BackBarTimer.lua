--------------------------------------------------------------
-- BackBarTimer.lua
-- Version: 1.4
-- Author: SugaComa
-- Description:
--   Tracks timed back-bar skills and displays a silent visual
--   alert 2 s before expiry (PvE = per-skill, PvP = average).
--   Uses ability API durations (no external libs), clamps instant
--   casts to 0.5 s, logs zero-duration abilities, and rebuilds
--   cache only when a true skill change occurs.
--------------------------------------------------------------

local BackBar = {}
BackBar.name          = "BackBarTimer"
BackBar.version       = "1.4"
BackBar.updateMs      = 200
BackBar.minSlotIndex  = 3
BackBar.maxSlotIndex  = 7
BackBar.hotbarBack    = HOTBAR_CATEGORY_BACKUP
BackBar.hasBuiltCache = false
BackBar.lastSkillHash = nil
BackBar.lastUpdateTime = 0

local EM  = GetEventManager()
local NOW = GetGameTimeSeconds

BackBar.cachedSet  = {}
BackBar.idToSlot   = {}
BackBar.avgAlerted = false
BackBar.clusterAlerted = {}
BackBar.pendingSlot = nil
BackBar.pendingTime = 0
BackBar.pendingAbilityId = 0

local PENDING_EFFECT_WINDOW_MS = 1000

--------------------------------------------------------------
-- Saved Variables
--------------------------------------------------------------
function BackBar:InitSavedVars()
    if not ZO_SavedVars then return end
    self.saved = ZO_SavedVars:NewAccountWide("BackBarTimer_Saved", 1, nil, {
        mode        = "pvp",
        leadSeconds = 2,
        debug       = false,
        suppressZeroDuration = false,
    })
    self.mode        = self.saved.mode
    self.leadSeconds = self.saved.leadSeconds
    self.debug       = self.saved.debug
    self.suppressZeroDuration = self.saved.suppressZeroDuration
end

--------------------------------------------------------------
-- Messaging helpers
--------------------------------------------------------------
local function chat(fmt, ...) CHAT_ROUTER:AddSystemMessage(string.format("[BBT] " .. fmt, ...)) end
local function log(fmt, ...) if BackBar.debug then CHAT_ROUTER:AddSystemMessage(string.format("[BBT-DEBUG] " .. fmt, ...)) end end

--------------------------------------------------------------
-- Alerts
--------------------------------------------------------------
local lastAlertTime = 0
local ALERT_DELAY   = 2000

local function AlertCenter(msg, sound)
    local now = GetFrameTimeMilliseconds()
    local delay = math.max(0, lastAlertTime + ALERT_DELAY - now)
    zo_callLater(function()
        local CSA = CENTER_SCREEN_ANNOUNCE
        if CSA and CSA.CreateMessageParams then
            local p = CSA:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, sound or SOUNDS.CHAMPION_POINT_GAINED)
            p:SetText(msg)
            p:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_CHAMPION_POINT_GAINED)
            p:MarkSuppressIconFrame()
            CSA:DisplayMessage(p)
        else
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "[BBT] " .. tostring(msg))
        end
        lastAlertTime = GetFrameTimeMilliseconds()
    end, delay)
end

local function AlertTopRight(msg, sound)
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, sound or SOUNDS.NEGATIVE_CLICK, "|cFFFFFF[BBT]|r " .. tostring(msg))
end

--------------------------------------------------------------
-- Helpers
--------------------------------------------------------------
local function GetBackBarAbilityId(slot)
    local fn = _G.GetSlotBoundId
    if type(fn) ~= "function" then
        zo_callLater(function() if type(_G.GetSlotBoundId) == "function" then BackBar:BuildCache() end end, 1000)
        return 0
    end
    return fn(slot, BackBar.hotbarBack) or 0
end

local function GenerateSkillHash()
    local ids = {}
    for slot = BackBar.minSlotIndex, BackBar.maxSlotIndex do
        table.insert(ids, tostring(GetBackBarAbilityId(slot)))
    end
    return table.concat(ids, "-")
end

--------------------------------------------------------------
-- Build Local Cache
--------------------------------------------------------------
function BackBar:BuildCache()
    if type(_G.GetAbilityDuration) ~= "function" or type(_G.GetAbilityName) ~= "function" then
        zo_callLater(function() BackBar:BuildCache() end, 1000)
        return
    end

    self.cachedSet = {}
    self.idToSlot = {}
    local trackedCount, unknownList = 0, {}

    for slot = self.minSlotIndex, self.maxSlotIndex do
        local id = GetBackBarAbilityId(slot)
        if id and id > 0 then
            local name = GetAbilityName(id, "player") or "Unknown"
            local durationMs = GetAbilityDuration(id, nil, "player") or 0
            local toggled = false
            if type(_G.IsAbilityDurationToggled) == "function" then
                toggled = IsAbilityDurationToggled(id, "player") == true
            end

            if durationMs <= 0 or toggled then
                self.cachedSet[slot] = {slot=slot, id=id, name=name, dur=0, tracked=false, unknown=true}
                table.insert(unknownList, {slot=slot, id=id, name=name})
            else
                local dur = durationMs / 1000
                if dur < 1.0 then dur = 0.5 end
                self.cachedSet[slot] = {slot=slot, id=id, name=name, dur=dur, tracked=true}
                trackedCount = trackedCount + 1
            end
            self.idToSlot[id] = slot
        end
    end

    BackBar.lastSkillHash  = GenerateSkillHash()
    BackBar.lastUpdateTime = GetFrameTimeMilliseconds()

    chat(string.format("Back Bar skills cached: %d", trackedCount))
    if not BackBar.suppressZeroDuration then
        for _, e in ipairs(unknownList) do
            chat(string.format("Slot %d: No duration for ability %d (%s)", e.slot, e.id, e.name))
        end
    end
end

--------------------------------------------------------------
-- Smart Cache Guard
--------------------------------------------------------------
local function ShouldRebuild()
    local now = GetFrameTimeMilliseconds()
    if now - (BackBar.lastUpdateTime or 0) < 10000 then return false end
    local current = GenerateSkillHash()
    if current == BackBar.lastSkillHash then return false end
    return true
end

--------------------------------------------------------------
-- Timers
--------------------------------------------------------------
local function StartTimer(slot, id)
    local s = BackBar.cachedSet[slot]
    if not s or s.instant or s.unknown or not s.tracked or s.id ~= id then return end
    s.endTime, s.alerted = NOW() + s.dur, false
end

local function StartTimerWithDuration(slot, id, durationSeconds)
    local s = BackBar.cachedSet[slot]
    if not s or s.id ~= id then return end
    local dur = tonumber(durationSeconds) or 0
    if dur <= 0 then return end
    s.dur = dur
    s.tracked = true
    s.unknown = false
    s.instant = (dur < 1.0)
    if s.instant then s.dur = 0.5 end
    s.endTime, s.alerted = NOW() + s.dur, false
end

--------------------------------------------------------------
-- Tick
--------------------------------------------------------------
local CLUSTER_WINDOW = 3
local function Tick()
    local now = NOW()
    local active, sum = {}, 0
    for _, s in pairs(BackBar.cachedSet) do
        if s.tracked and not s.instant and s.endTime and s.endTime > now then
            local remain = s.endTime - now
            table.insert(active, { s = s, remain = remain })
            sum = sum + remain
        end
    end
    if #active == 0 then return end

    if BackBar.mode == "pve" then
        for _, entry in ipairs(active) do
            local s = entry.s
            local remain = entry.remain
            if remain <= BackBar.leadSeconds and not s.alerted then
                AlertTopRight(string.format("Recast %s!", s.name))
                s.alerted = true
            end
        end
    else
        table.sort(active, function(a, b) return a.remain < b.remain end)
        local minRemain = active[1].remain
        local maxRemain = active[#active].remain
        local clusters = {}

        if (maxRemain - minRemain) <= CLUSTER_WINDOW then
            clusters[1] = { items = active, sum = sum, min = minRemain }
        else
            local current = { items = { active[1] }, sum = active[1].remain, min = active[1].remain }
            for i = 2, #active do
                local prev = active[i - 1].remain
                local cur = active[i].remain
                if (cur - prev) <= CLUSTER_WINDOW then
                    table.insert(current.items, active[i])
                    current.sum = current.sum + cur
                    current.min = math.min(current.min, cur)
                else
                    table.insert(clusters, current)
                    current = { items = { active[i] }, sum = cur, min = cur }
                end
            end
            table.insert(clusters, current)
        end

        local newAlerted = {}
        for idx, cluster in ipairs(clusters) do
            local clusterKeyParts = {}
            for _, entry in ipairs(cluster.items) do
                local slot = entry.s.slot or 0
                table.insert(clusterKeyParts, tostring(slot))
            end
            table.sort(clusterKeyParts)
            local clusterKey = table.concat(clusterKeyParts, "-")
            local remaining = 0
            if #clusters == 1 and (maxRemain - minRemain) <= CLUSTER_WINDOW then
                remaining = cluster.sum / #cluster.items
            else
                remaining = cluster.min
            end

            if remaining <= BackBar.leadSeconds then
                if not BackBar.clusterAlerted[clusterKey] then
                    BackBar.clusterAlerted[clusterKey] = true
                    newAlerted[clusterKey] = true
                    AlertCenter("|c00FF00Back |cFFCC00Bar |cFF0000Buffs|r")
                    if BackBar.debug then
                        local list = {}
                        for _, entry in ipairs(active) do
                            table.insert(list, string.format("%.1f", entry.remain))
                        end
                        local clustersText = {}
                        for cidx, c in ipairs(clusters) do
                            local cmin = c.min
                            local cmax = c.items[#c.items].remain
                            table.insert(clustersText, string.format("#%d[%s..%s]", cidx, string.format("%.1f", cmin), string.format("%.1f", cmax)))
                        end
                        log("Timers: " .. table.concat(list, ", "))
                        log("Clusters: " .. table.concat(clustersText, " | "))
                        log("Triggered cluster: " .. clusterKey)
                    end
                else
                    newAlerted[clusterKey] = true
                end
            else
                newAlerted[clusterKey] = false
            end
        end
        BackBar.clusterAlerted = newAlerted
    end
end

--------------------------------------------------------------
-- Events
--------------------------------------------------------------
local function OnAbilityUsed(_, slotNum)
    if slotNum < BackBar.minSlotIndex or slotNum > BackBar.maxSlotIndex then return end
    if GetActiveHotbarCategory() ~= BackBar.hotbarBack then return end
    local id = GetBackBarAbilityId(slotNum)
    if BackBar.debug then
        local name = GetAbilityName and GetAbilityName(id, "player") or "Unknown"
        log(string.format("Ability used: Slot %d | ID %d | %s", slotNum, id, name))
    end
    local s = BackBar.cachedSet[slotNum]
    if s and s.tracked and s.dur and s.dur > 0 then
        StartTimer(slotNum, id)
        return
    end
    if type(_G.GetAbilityDuration) == "function" then
        local durationMs = GetAbilityDuration(id, nil, "player") or 0
        if durationMs > 0 then
            StartTimerWithDuration(slotNum, id, durationMs / 1000)
            BackBar.pendingSlot = nil
            BackBar.pendingTime = 0
            BackBar.pendingAbilityId = 0
            return
        end
    end
    -- If duration is unknown/zero, wait for effect change and bind it to this slot.
    BackBar.pendingSlot = slotNum
    BackBar.pendingTime = GetFrameTimeMilliseconds()
    BackBar.pendingAbilityId = id
end

local function OnEffectChanged(_, changeType, _, _, unitTag, beginTime, endTime, _, _, _, _, _, _, _, _, abilityId)
    if unitTag ~= "player" then return end
    local slot = BackBar.idToSlot and BackBar.idToSlot[abilityId]
    if changeType ~= EFFECT_RESULT_GAINED and changeType ~= EFFECT_RESULT_FULL_REFRESH and changeType ~= EFFECT_RESULT_UPDATED then
        return
    end
    local duration = tonumber(endTime) and tonumber(beginTime) and (endTime - beginTime) or 0
    if not duration or duration <= 0 then return end
    if slot then
        StartTimerWithDuration(slot, abilityId, duration)
        return
    end

    -- Fallback: map fresh effect to the last-used backbar slot if it happened recently.
    if BackBar.pendingSlot and BackBar.pendingTime then
        local nowMs = GetFrameTimeMilliseconds()
        if nowMs - BackBar.pendingTime <= PENDING_EFFECT_WINDOW_MS then
            local currentId = GetBackBarAbilityId(BackBar.pendingSlot)
            if currentId == BackBar.pendingAbilityId then
                StartTimerWithDuration(BackBar.pendingSlot, currentId, duration)
                if BackBar.debug then
                    log(string.format("Effect-mapped to slot %d (ability %d) via pending window.", BackBar.pendingSlot, currentId))
                end
            end
        end
    end
end

local function OnSkillLayoutChanged()
    if not ShouldRebuild() then return end
    BackBar:BuildCache()
end

local function QueueRebuild(reason)
    BackBar.lastSkillHash = nil
    BackBar.lastUpdateTime = 0
    if BackBar.debug then
        log("Rebuild queued (" .. tostring(reason) .. ")")
    end
    zo_callLater(function() BackBar:BuildCache() end, 500)
    zo_callLater(function() BackBar:BuildCache() end, 2000)
end

local function OnSkillsMenuClose() BackBar:BuildCache() end

local function OnPlayerActivated()
    if BackBar.hasBuiltCache then return end
    BackBar.hasBuiltCache = true
    zo_callLater(function() BackBar:BuildCache() end, 500)
end

local function OnArmoryBuildRestoreResponse(_, result, buildIndex)
    if result == ARMORY_BUILD_RESTORE_RESULT_SUCCESS then
        QueueRebuild("ArmoryRestore " .. tostring(buildIndex))
    elseif BackBar.debug then
        log("Armory restore result " .. tostring(result) .. " for build " .. tostring(buildIndex))
    end
end

local function OnSkillBuildSelectionUpdated()
    QueueRebuild("SkillBuildSelection")
end

--------------------------------------------------------------
-- Init
--------------------------------------------------------------
function BackBar:Initialize()
    EM:RegisterForEvent(self.name.."_Used", EVENT_ACTION_SLOT_ABILITY_USED, OnAbilityUsed)
    EM:RegisterForEvent(self.name.."_FullUpdate", EVENT_ACTION_SLOTS_FULL_UPDATE, OnSkillLayoutChanged)
    EM:RegisterForEvent(self.name.."_AllHotbars", EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, OnSkillLayoutChanged)
    EM:RegisterForEvent(self.name.."_SkillMenuClose", EVENT_CLOSE_SKILLS, OnSkillsMenuClose)
    EM:RegisterForEvent(self.name.."_Activated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    if EVENT_ARMORY_BUILD_RESTORE_RESPONSE then
        EM:RegisterForEvent(self.name.."_ArmoryRestore", EVENT_ARMORY_BUILD_RESTORE_RESPONSE, OnArmoryBuildRestoreResponse)
    end
    if EVENT_SKILL_BUILD_SELECTION_UPDATED then
        EM:RegisterForEvent(self.name.."_SkillBuildSelection", EVENT_SKILL_BUILD_SELECTION_UPDATED, OnSkillBuildSelectionUpdated)
    end
    if EVENT_EFFECT_CHANGED then
        EM:RegisterForEvent(self.name.."_EffectChanged", EVENT_EFFECT_CHANGED, OnEffectChanged)
    end
    EM:RegisterForUpdate(self.name.."_Tick", self.updateMs, Tick)
    if _G.BBTMenu and BBTMenu.Setup then
        BBTMenu.Setup(self)
    end
end

function BackBar:OnAddOnLoaded(_, addonName)
    if addonName ~= self.name then return end
    EM:UnregisterForEvent(self.name.."_Loaded", EVENT_ADD_ON_LOADED)
    self:InitSavedVars()
    self:Initialize()
end
EM:RegisterForEvent("BackBarTimer_Loaded", EVENT_ADD_ON_LOADED, function(_, a) BackBar:OnAddOnLoaded(_, a) end)

--------------------------------------------------------------
-- Slash Commands
--------------------------------------------------------------
SLASH_COMMANDS["/bbtdebug"] = function()
    if not BackBar.saved then BackBar:InitSavedVars() end
    BackBar.debug = not BackBar.debug
    chat("Debug Mode " .. (BackBar.debug and "ON" or "OFF"))
end

SLASH_COMMANDS["/bbtmode"] = function()
    if not BackBar.saved then BackBar:InitSavedVars() end
    if BackBar.mode == "pvp" then
        BackBar.mode = "pve"
        chat("PvE Mode ON — per-skill (top-right alerts)")
    else
        BackBar.mode = "pvp"
        chat("PvP Mode ON — average (center screen)")
    end
    BackBar.saved.mode = BackBar.mode
end

SLASH_COMMANDS["/bbtrebuild"] = function() BackBar:BuildCache() end
