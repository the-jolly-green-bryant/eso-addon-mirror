OpulentOrdealNavigator = OpulentOrdealNavigator or {}

local OON = OpulentOrdealNavigator
local ADDON_NAME = "OpulentOrdealNavigator"
local DETECTION_NAME = ADDON_NAME .. "Detection"
local WIPE_CHECK_UPDATE = DETECTION_NAME .. "WipeCheck"
local AFFINITY_SCAN_UPDATE = DETECTION_NAME .. "AffinityScan"
local GROUP_AFFINITY_EVENT = DETECTION_NAME .. "GroupAffinity"

local csaHooked = false
local detectionActive = false
local lastRouteClearAt = 0
local completedOrbSoakRooms = {}
local completedOrbSoakSet = {}

local function Print(message)
    if OON.Print then
        OON.Print(message)
    end
end

local function GetDisplayName(unitTag)
    local accountName = GetUnitDisplayName(unitTag)
    if accountName and accountName ~= "" then
        return accountName
    end
    return GetUnitName(unitTag)
end

local function OnAffinityChanged(_, changeType, _, _, unitTag, beginTime, endTime, _, _, _, _, _, _, _, _, abilityId)
    local color = OON.COMBAT_IDS.affinities[abilityId]
    if not color or not unitTag or unitTag == "" then
        return
    end

    local name = GetDisplayName(unitTag)
    if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
        local appliedColor = OON.SetRosterColorSilent(name, color, "affinity")
        if unitTag == "player" and appliedColor == color then
            OON.saved.preferredRoom = color
            if changeType == EFFECT_RESULT_GAINED then
                Print(string.format("Detected your Affinity: %s.", OON.ROOMS[color].label))
            end
            if OON.RefreshInfoWindowVisibility then
                OON.RefreshInfoWindowVisibility()
            end
        end
    elseif changeType == EFFECT_RESULT_FADED then
        -- Keep the manual roster assignment. Affinity fades should not erase
        -- planned team color during reloads or phase transitions.
    end
end

local function OnLampBuffChanged(_, changeType, _, _, unitTag, _, endTime, _, _, _, _, _, _, _, _, abilityId)
    if unitTag ~= "player" or not OON.COMBAT_IDS.lampBuffs[abilityId] then
        return
    end

    if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
        if OON.ShowLampBuffTimer then
            OON.ShowLampBuffTimer(endTime)
        end
    elseif changeType == EFFECT_RESULT_FADED and OON.HideLampBuffTimer then
        OON.HideLampBuffTimer()
    end
end

local function ScanUnitAffinity(unitTag)
    if not unitTag or not DoesUnitExist(unitTag) or not GetNumBuffs or not GetUnitBuffInfo then
        return
    end

    for buffIndex = 1, GetNumBuffs(unitTag) do
        local _, _, _, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo(unitTag, buffIndex)
        local color = OON.COMBAT_IDS.affinities[abilityId]
        if color then
            local _, beginTime, endTime = GetUnitBuffInfo(unitTag, buffIndex)
            OnAffinityChanged(nil, EFFECT_RESULT_GAINED, nil, nil, unitTag, beginTime, endTime, nil, nil, nil, nil, nil, nil, nil, nil, abilityId)
            return
        end
    end
end

local function ScanPlayerLampBuff()
    if not DoesUnitExist("player") or not GetNumBuffs or not GetUnitBuffInfo then
        return
    end

    for buffIndex = 1, GetNumBuffs("player") do
        local _, _, endTime, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", buffIndex)
        if OON.COMBAT_IDS.lampBuffs[abilityId] then
            OnLampBuffChanged(nil, EFFECT_RESULT_GAINED, nil, nil, "player", nil, endTime, nil, nil, nil, nil, nil, nil, nil, nil, abilityId)
            return
        end
    end

    if OON.HideLampBuffTimer then
        OON.HideLampBuffTimer()
    end
end

local function ScanGroupAffinities()
    EVENT_MANAGER:UnregisterForUpdate(AFFINITY_SCAN_UPDATE)
    ScanUnitAffinity("player")
    ScanPlayerLampBuff()
    for index = 1, GetGroupSize() do
        ScanUnitAffinity(GetGroupUnitTagByIndex(index))
    end
end

local function ScheduleAffinityScan()
    EVENT_MANAGER:UnregisterForUpdate(AFFINITY_SCAN_UPDATE)
    EVENT_MANAGER:RegisterForUpdate(AFFINITY_SCAN_UPDATE, 500, ScanGroupAffinities)
end

local function OnSummonEssence(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, abilityId)
    OON.pendingEssenceColor = OON.ESSENCE_SUMMON_TO_COLOR[abilityId]
    if OON.SetEncounterPhase then
        OON.SetEncounterPhase(1)
    else
        OON.saved.encounterPhase = 1
    end
end

local function GetEssenceColorFromStunnedId(abilityId)
    for _, data in pairs(OON.COMBAT_IDS.essences) do
        if data.stunnedId == abilityId then
            return data.color
        end
    end
    return nil
end

local function OnEssenceDone(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, abilityId)
    local color = GetEssenceColorFromStunnedId(abilityId) or OON.pendingEssenceColor
    OON.pendingEssenceColor = nil
    OON.HideAnimatedPath()

    if color and not completedOrbSoakSet[color] then
        completedOrbSoakSet[color] = true
        completedOrbSoakRooms[#completedOrbSoakRooms + 1] = color
    end

    if #completedOrbSoakRooms > 0 and OON.HandleOrbSoakSequence then
        OON.HandleOrbSoakSequence(completedOrbSoakRooms)
    end
end

local function OnSoakCall(_, _, _, _, _, _, _, _, _, _, hitValue, _, _, _, _, _, abilityId)
    local phase = OON.saved.encounterPhase or 1
    local isDualCall = OON.COMBAT_IDS.dualSoaks and OON.COMBAT_IDS.dualSoaks[abilityId] ~= nil
    local data = isDualCall and OON.COMBAT_IDS.dualSoaks[abilityId] or OON.COMBAT_IDS.soaks[abilityId]
    if not data then
        return
    end
    local shouldUseDualSoak = isDualCall or phase >= 2

    local now = GetGameTimeMilliseconds()
    OON.lastSoakCallAt = OON.lastSoakCallAt or {}
    if OON.lastSoakCallAt[abilityId] and now - OON.lastSoakCallAt[abilityId] < 1500 then
        return
    end
    OON.lastSoakCallAt[abilityId] = now

    local durationMs = hitValue and hitValue > 0 and hitValue or 6000
    if shouldUseDualSoak and phase < 2 then
        OON.SetEncounterPhase(2)
    end
    OON.HandleSoakCall(data.room, durationMs, shouldUseDualSoak)
end

local function OnSmokeStep()
    if OON.SetEncounterPhase then
        OON.SetEncounterPhase(2, "Phase 2 dual-soak mode enabled.")
    else
        OON.saved.encounterPhase = 2
        Print("Phase 2 dual-soak mode enabled.")
    end
end

local function ClearRouteForWipe(reason)
    local now = GetGameTimeMilliseconds()
    if now - lastRouteClearAt < 2500 then
        return
    end
    lastRouteClearAt = now

    if OON.ClearRouteState then
        OON.ClearRouteState(reason)
    else
        OON.HideAnimatedPath()
    end
end

local function ResetOrbSoakSequence()
    completedOrbSoakRooms = {}
    completedOrbSoakSet = {}
end

local function IsOnline(unitTag)
    if IsUnitOnline then
        return IsUnitOnline(unitTag)
    end
    return true
end

local function CheckGroupWipe()
    EVENT_MANAGER:UnregisterForUpdate(WIPE_CHECK_UPDATE)

    local groupSize = GetGroupSize()
    if groupSize <= 0 then
        return
    end

    local onlineCount = 0
    local deadCount = 0
    for index = 1, groupSize do
        local unitTag = GetGroupUnitTagByIndex(index)
        if unitTag and DoesUnitExist(unitTag) and IsOnline(unitTag) then
            onlineCount = onlineCount + 1
            if IsUnitDead and IsUnitDead(unitTag) then
                deadCount = deadCount + 1
            end
        end
    end

    if onlineCount > 0 and deadCount >= onlineCount then
        ResetOrbSoakSequence()
        if OON.SetEncounterPhase then
            OON.SetEncounterPhase(1)
        else
            OON.saved.encounterPhase = 1
        end
        ClearRouteForWipe("Route cleared: group wipe detected.")
    end
end

local function OnDeathStateChanged(_, unitTag, isDead)
    if not detectionActive or not isDead then
        return
    end

    EVENT_MANAGER:UnregisterForUpdate(WIPE_CHECK_UPDATE)
    EVENT_MANAGER:RegisterForUpdate(WIPE_CHECK_UPDATE, 300, CheckGroupWipe)
end

local function HandleAnnouncementText(mainText)
    local route = mainText and OON.ESSENCE_ANNOUNCEMENTS[mainText]
    if not route then
        return
    end

    OON.pendingEssenceColor = nil
    if OON.StartAutomatedRoute then
        OON.StartAutomatedRoute(route.orbColor, route.spawnRoom, nil, "detection")
    else
        OON.StartManualRoute(route.orbColor, route.spawnRoom)
    end
end

local function CenterScreenAnnouncementHook(_, messageParams)
    if not detectionActive or not messageParams then
        return
    end

    HandleAnnouncementText(messageParams:GetMainText())
end

local function RegisterCombatEvent(suffix, callback, result, abilityId)
    local name = DETECTION_NAME .. suffix
    EVENT_MANAGER:RegisterForEvent(name, EVENT_COMBAT_EVENT, callback)
    if result then
        EVENT_MANAGER:AddFilterForEvent(name, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, result)
    end
    if abilityId then
        EVENT_MANAGER:AddFilterForEvent(name, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId)
    end
end

local function UnregisterCombatEvent(suffix)
    EVENT_MANAGER:UnregisterForEvent(DETECTION_NAME .. suffix, EVENT_COMBAT_EVENT)
end

local function RegisterAffinityEvent(abilityId)
    local groupName = DETECTION_NAME .. "AffinityGroup" .. abilityId
    EVENT_MANAGER:RegisterForEvent(groupName, EVENT_EFFECT_CHANGED, OnAffinityChanged)
    EVENT_MANAGER:AddFilterForEvent(groupName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityId)
    EVENT_MANAGER:AddFilterForEvent(groupName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")

    local playerName = DETECTION_NAME .. "AffinityPlayer" .. abilityId
    EVENT_MANAGER:RegisterForEvent(playerName, EVENT_EFFECT_CHANGED, OnAffinityChanged)
    EVENT_MANAGER:AddFilterForEvent(playerName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityId)
    EVENT_MANAGER:AddFilterForEvent(playerName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
end

local function UnregisterAffinityEvent(abilityId)
    EVENT_MANAGER:UnregisterForEvent(DETECTION_NAME .. "AffinityGroup" .. abilityId, EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(DETECTION_NAME .. "AffinityPlayer" .. abilityId, EVENT_EFFECT_CHANGED)
end

local function RegisterLampBuffEvent(abilityId)
    local name = DETECTION_NAME .. "LampBuff" .. abilityId
    EVENT_MANAGER:RegisterForEvent(name, EVENT_EFFECT_CHANGED, OnLampBuffChanged)
    EVENT_MANAGER:AddFilterForEvent(name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityId)
    EVENT_MANAGER:AddFilterForEvent(name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
end

local function UnregisterLampBuffEvent(abilityId)
    EVENT_MANAGER:UnregisterForEvent(DETECTION_NAME .. "LampBuff" .. abilityId, EVENT_EFFECT_CHANGED)
end

function OON.RegisterOpulentDetection()
    if detectionActive then
        return
    end
    detectionActive = true
    ResetOrbSoakSequence()

    for abilityId in pairs(OON.COMBAT_IDS.affinities) do
        RegisterAffinityEvent(abilityId)
    end
    for abilityId in pairs(OON.COMBAT_IDS.lampBuffs or {}) do
        RegisterLampBuffEvent(abilityId)
    end
    EVENT_MANAGER:RegisterForEvent(GROUP_AFFINITY_EVENT, EVENT_GROUP_UPDATE, ScheduleAffinityScan)
    ScheduleAffinityScan()

    for _, data in pairs(OON.COMBAT_IDS.essences) do
        RegisterCombatEvent("SummonEssence" .. data.summonId, OnSummonEssence, ACTION_RESULT_BEGIN, data.summonId)
        RegisterCombatEvent("EssenceDone" .. data.stunnedId, OnEssenceDone, nil, data.stunnedId)
    end

    RegisterCombatEvent("SmokeStep", OnSmokeStep, ACTION_RESULT_BEGIN, OON.COMBAT_IDS.bombs.smokeStep)
    for abilityId in pairs(OON.COMBAT_IDS.soaks) do
        RegisterCombatEvent("SoakCall" .. abilityId, OnSoakCall, ACTION_RESULT_EFFECT_GAINED_DURATION, abilityId)
    end
    for abilityId in pairs(OON.COMBAT_IDS.dualSoaks or {}) do
        RegisterCombatEvent("DualSoakCall" .. abilityId, OnSoakCall, ACTION_RESULT_BEGIN, abilityId)
    end

    EVENT_MANAGER:RegisterForEvent(DETECTION_NAME .. "PlayerDeath", EVENT_UNIT_DEATH_STATE_CHANGED, OnDeathStateChanged)
    EVENT_MANAGER:AddFilterForEvent(DETECTION_NAME .. "PlayerDeath", EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
    EVENT_MANAGER:RegisterForEvent(DETECTION_NAME .. "GroupDeath", EVENT_UNIT_DEATH_STATE_CHANGED, OnDeathStateChanged)
    EVENT_MANAGER:AddFilterForEvent(DETECTION_NAME .. "GroupDeath", EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")

    if not csaHooked then
        csaHooked = true
        ZO_PreHook(CENTER_SCREEN_ANNOUNCE, "QueueMessage", CenterScreenAnnouncementHook)
    end

    Print("Opulent Ordeal auto-detection enabled.")
end

function OON.UnregisterOpulentDetection()
    if not detectionActive then
        return
    end
    detectionActive = false
    ResetOrbSoakSequence()

    for abilityId in pairs(OON.COMBAT_IDS.affinities) do
        UnregisterAffinityEvent(abilityId)
    end
    for abilityId in pairs(OON.COMBAT_IDS.lampBuffs or {}) do
        UnregisterLampBuffEvent(abilityId)
    end

    for _, data in pairs(OON.COMBAT_IDS.essences) do
        UnregisterCombatEvent("SummonEssence" .. data.summonId)
        UnregisterCombatEvent("EssenceDone" .. data.stunnedId)
    end

    UnregisterCombatEvent("SmokeStep")
    for abilityId in pairs(OON.COMBAT_IDS.soaks) do
        UnregisterCombatEvent("SoakCall" .. abilityId)
    end
    for abilityId in pairs(OON.COMBAT_IDS.dualSoaks or {}) do
        UnregisterCombatEvent("DualSoakCall" .. abilityId)
    end
    EVENT_MANAGER:UnregisterForEvent(DETECTION_NAME .. "PlayerDeath", EVENT_UNIT_DEATH_STATE_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(DETECTION_NAME .. "GroupDeath", EVENT_UNIT_DEATH_STATE_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(GROUP_AFFINITY_EVENT, EVENT_GROUP_UPDATE)
    EVENT_MANAGER:UnregisterForUpdate(WIPE_CHECK_UPDATE)
    EVENT_MANAGER:UnregisterForUpdate(AFFINITY_SCAN_UPDATE)

    OON.pendingEssenceColor = nil
    if OON.HideLampBuffTimer then
        OON.HideLampBuffTimer()
    end
    if OON.ClearRouteState then
        OON.ClearRouteState(nil, true)
    else
        OON.HidePersonalSoakWarning()
        OON.HideAnimatedPath()
    end
end
