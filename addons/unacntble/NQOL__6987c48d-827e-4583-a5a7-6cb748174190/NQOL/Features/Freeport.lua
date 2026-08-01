NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local Freeport = {}

local EVENT_NAMESPACE = "NQOL_Freeport"
local AVAILABILITY_EVENT_NAMESPACE = EVENT_NAMESPACE .. "_Availability"
local FREEPORT_LABEL = NQOL.L("common.feature.freeport")
NQOL.Lexicon.RegisterRefreshCallback(function() FREEPORT_LABEL = NQOL.L("common.feature.freeport") end)
local HOOK_DELAY_MS = 500
local MAX_HOOK_ATTEMPTS = 20
local MOUNT_RETRY_DELAY_MS = 1500
local PLAYER_JUMP_TIMEOUT_MS = 15000
local GUILD_SCAN_UPDATE_NAMESPACE = EVENT_NAMESPACE .. "_GuildScan"
local GUILD_SCAN_BATCH_SIZE = 40
local PAID_FALLBACK_DIALOG_NAME = "NQOL_FREEPORT_PAID_FALLBACK_CONFIRM"

local hookAttempts = 0
local hooksInstalled = false
local keybindStripHooked = false
local availabilityEventsRegistered = false
local guildScanRunning = false
local paidFallbackDialogRegistered = false
local activeRunId = 0
local localDisplayName
local TryNextCandidate

local function Chat(message)
    NQOL.Chat.Message(message, NQOL.L("common.feature.freeport"))
end

local function StopGuildCandidateScan()
    if guildScanRunning and EVENT_MANAGER then
        EVENT_MANAGER:UnregisterForUpdate(GUILD_SCAN_UPDATE_NAMESPACE)
    end

    guildScanRunning = false
end

local function IsFreeportEnabled()
    return NQOL.Features
        and NQOL.Features.Map
        and NQOL.Features.Map.GetFreeport
        and NQOL.Features.Map.GetFreeport() == true
end

local function IsInPvPZone()
    return (IsPlayerInAvAWorld and IsPlayerInAvAWorld())
        or (IsInImperialCity and IsInImperialCity())
        or (IsActiveWorldBattleground and IsActiveWorldBattleground())
end

local function IsFreeportAvailable()
    return IsFreeportEnabled() and not IsInPvPZone()
end

local function GetFreeportFallback()
    if NQOL.Features
        and NQOL.Features.Map
        and NQOL.Features.Map.GetFreeportFallback
    then
        return NQOL.Features.Map.GetFreeportFallback()
    end

    return "cancel"
end

local function FormatZoneName(zoneName)
    if type(zoneName) ~= "string" or zoneName == "" then
        return ""
    end

    if ZO_CachedStrFormat then
        return ZO_CachedStrFormat(SI_ZONE_NAME, zoneName)
    end

    if zo_strformat then
        return zo_strformat("<<C:1>>", zoneName)
    end

    return zoneName
end

local function GetZoneIdFromZoneIndex(zoneIndex)
    if type(zoneIndex) ~= "number" or zoneIndex <= 0 or not GetZoneId then
        return nil
    end

    local zoneId = GetZoneId(zoneIndex)
    if type(zoneId) ~= "number" or zoneId <= 0 then
        return nil
    end

    return zoneId
end

local function GetSelectedLocation()
    if not GAMEPAD_WORLD_MAP_LOCATIONS or not GAMEPAD_WORLD_MAP_LOCATIONS.selectedData then
        return nil
    end

    local mapIndex = GAMEPAD_WORLD_MAP_LOCATIONS.selectedData.index
    if type(mapIndex) ~= "number" or not GetMapInfoByIndex then
        return nil
    end

    local mapName, _, _, zoneIndex = GetMapInfoByIndex(mapIndex)
    return {
        mapIndex = mapIndex,
        zoneId = GetZoneIdFromZoneIndex(zoneIndex),
        zoneName = FormatZoneName(mapName),
        source = "locations",
    }
end

local function IsPinCurrentlyFocused(pin)
    if not pin or type(pin.MouseIsOver) ~= "function" then
        return false
    end

    if ZO_WorldMap_IsMouseOverMap and not ZO_WorldMap_IsMouseOverMap() then
        return false
    end

    if ZO_WorldMapScroll and type(ZO_WorldMapScroll.GetCenter) == "function" then
        local cursorX, cursorY = ZO_WorldMapScroll:GetCenter()
        return pin:MouseIsOver(cursorX, cursorY)
    end

    if GetUIMousePosition then
        local cursorX, cursorY = GetUIMousePosition()
        return pin:MouseIsOver(cursorX, cursorY)
    end

    return false
end

local function GetFocusedWayshrineLocation()
    if not WORLD_MAP_MANAGER
        or not WORLD_MAP_MANAGER.GetFoundTooltipMouseOverPins
        or not GetFastTravelNodeInfo
        or not GetFastTravelNodePOIIndicies
    then
        return nil
    end

    local pins = WORLD_MAP_MANAGER:GetFoundTooltipMouseOverPins()
    if type(pins) ~= "table" then
        return nil
    end

    for _, pin in ipairs(pins) do
        if pin
            and pin.IsFastTravelWayShrine
            and pin:IsFastTravelWayShrine()
            and IsPinCurrentlyFocused(pin)
            and pin.GetFastTravelNodeIndex
        then
            local nodeIndex = pin:GetFastTravelNodeIndex()
            if type(nodeIndex) == "number" then
                local known, nodeName, _, _, _, _, poiType, _, linkedCollectibleIsLocked = GetFastTravelNodeInfo(nodeIndex)
                if known and linkedCollectibleIsLocked ~= true and poiType == POI_TYPE_WAYSHRINE then
                    local zoneIndex = GetFastTravelNodePOIIndicies(nodeIndex)
                    local zoneName = nodeName
                    if type(zoneIndex) == "number" and GetZoneNameByIndex then
                        zoneName = GetZoneNameByIndex(zoneIndex)
                    end

                    return {
                        nodeIndex = nodeIndex,
                        zoneId = GetZoneIdFromZoneIndex(zoneIndex),
                        zoneName = FormatZoneName(zoneName),
                        source = "mainMap",
                    }
                end
            end
        end
    end

    return nil
end

local function IsMatchingZone(target, candidateZoneId, candidateZoneName)
    if not target then
        return false
    end

    if target.zoneId and candidateZoneId and target.zoneId == candidateZoneId then
        return true
    end

    local formattedCandidateZoneName = FormatZoneName(candidateZoneName)
    return target.zoneName ~= "" and formattedCandidateZoneName ~= "" and target.zoneName == formattedCandidateZoneName
end

local function AddCandidate(candidates, seenDisplayNames, candidate)
    if type(candidate.displayName) ~= "string" or candidate.displayName == "" then
        return
    end

    if seenDisplayNames[candidate.displayName] then
        return
    end

    seenDisplayNames[candidate.displayName] = true
    candidates[#candidates + 1] = candidate
end

local function CanTryPlayerJump(target)
    if IsUnitDead and IsUnitDead("player") then
        return false
    end

    if CanLeaveCurrentLocationViaTeleport and not CanLeaveCurrentLocationViaTeleport() then
        return false
    end

    if target and target.zoneId and CanJumpToPlayerInZone then
        local canJump = CanJumpToPlayerInZone(target.zoneId)
        return canJump == true
    end

    return true
end

local function AddFriendCandidates(target, candidates, seenDisplayNames)
    if not GetNumFriends or not GetFriendInfo or not GetFriendCharacterInfo or not JumpToFriend then
        return
    end

    for friendIndex = 1, GetNumFriends() do
        local displayName, _, playerStatus = GetFriendInfo(friendIndex)
        if playerStatus ~= PLAYER_STATUS_OFFLINE then
            local hasCharacter, _, zoneName, _, _, _, _, zoneId = GetFriendCharacterInfo(friendIndex)
            if hasCharacter and IsMatchingZone(target, zoneId, zoneName) then
                AddCandidate(candidates, seenDisplayNames, {
                    displayName = displayName,
                    jump = function()
                        JumpToFriend(displayName)
                    end,
                })
            end
        end
    end
end

local function AddGuildCandidate(target, candidates, seenDisplayNames, guildId, memberIndex)
    local displayName, _, _, playerStatus = GetGuildMemberInfo(guildId, memberIndex)
    if playerStatus ~= PLAYER_STATUS_OFFLINE and displayName ~= localDisplayName then
        local hasCharacter, _, zoneName, _, _, _, _, zoneId = GetGuildMemberCharacterInfo(guildId, memberIndex)
        if hasCharacter and IsMatchingZone(target, zoneId, zoneName) then
            AddCandidate(candidates, seenDisplayNames, {
                displayName = displayName,
                jump = function()
                    JumpToGuildMember(displayName)
                end,
            })
        end
    end
end

local function QueueGuildCandidates(runId, target, candidates, seenDisplayNames, onComplete)
    StopGuildCandidateScan()

    if not GetNumGuilds
        or not GetGuildId
        or not GetNumGuildMembers
        or not GetGuildMemberInfo
        or not GetGuildMemberCharacterInfo
        or not JumpToGuildMember
    then
        onComplete()
        return
    end

    local guildCount = GetNumGuilds()
    local guildIndex = 1
    local guildId
    local memberIndex = 1
    local memberCount = 0

    local function AdvanceGuild()
        while guildIndex <= guildCount do
            guildId = GetGuildId(guildIndex)
            memberIndex = 1
            memberCount = guildId and GetNumGuildMembers(guildId) or 0
            if guildId and memberCount > 0 then
                return true
            end

            guildIndex = guildIndex + 1
        end

        return false
    end

    local function Complete()
        StopGuildCandidateScan()
        onComplete()
    end

    if not AdvanceGuild() then
        Complete()
        return
    end

    local function ProcessGuildBatch()
        local activeRun = Freeport.activeRun
        if not activeRun or activeRun.id ~= runId then
            StopGuildCandidateScan()
            return
        end

        local processed = 0
        while processed < GUILD_SCAN_BATCH_SIZE do
            if memberIndex <= memberCount then
                AddGuildCandidate(target, candidates, seenDisplayNames, guildId, memberIndex)
                memberIndex = memberIndex + 1
                processed = processed + 1
            else
                guildIndex = guildIndex + 1
                if not AdvanceGuild() then
                    Complete()
                    return
                end
            end
        end
    end

    if EVENT_MANAGER then
        guildScanRunning = true
        EVENT_MANAGER:RegisterForUpdate(GUILD_SCAN_UPDATE_NAMESPACE, 0, ProcessGuildBatch)
        ProcessGuildBatch()
    else
        repeat
            for currentMemberIndex = 1, memberCount do
                AddGuildCandidate(target, candidates, seenDisplayNames, guildId, currentMemberIndex)
            end
            guildIndex = guildIndex + 1
        until not AdvanceGuild()
        onComplete()
    end
end

local function BuildFriendCandidates(target)
    local candidates = {}
    local seenDisplayNames = {}

    AddFriendCandidates(target, candidates, seenDisplayNames)

    return candidates, seenDisplayNames
end

local function FindFirstWayshrineNode(mapIndex)
    if not WORLD_MAP_MANAGER or not WORLD_MAP_MANAGER.SetMapByIndex or not GetNumFastTravelNodes or not GetFastTravelNodeInfo then
        return nil
    end

    WORLD_MAP_MANAGER:SetMapByIndex(mapIndex)

    for nodeIndex = 1, GetNumFastTravelNodes() do
        local known, _, _, _, _, _, poiType, isShownInCurrentMap, linkedCollectibleIsLocked = GetFastTravelNodeInfo(nodeIndex)
        if known and isShownInCurrentMap and linkedCollectibleIsLocked ~= true and poiType == POI_TYPE_WAYSHRINE then
            return nodeIndex
        end
    end

    for nodeIndex = 1, GetNumFastTravelNodes() do
        local known, _, _, _, _, _, _, isShownInCurrentMap, linkedCollectibleIsLocked = GetFastTravelNodeInfo(nodeIndex)
        if known and isShownInCurrentMap and linkedCollectibleIsLocked ~= true then
            return nodeIndex
        end
    end

    return nil
end

local function TravelToWayshrine(runId, target)
    if runId ~= activeRunId then
        return
    end

    if not FastTravelToNode then
        Chat(NQOL.L("features.freeport.wayshrine_unavailable"))
        return
    end

    local currentMapIndex = GetCurrentMapIndex and GetCurrentMapIndex() or nil
    local nodeIndex = target.nodeIndex or FindFirstWayshrineNode(target.mapIndex)

    if nodeIndex then
        FastTravelToNode(nodeIndex)
        return
    end

    if currentMapIndex and target.mapIndex and WORLD_MAP_MANAGER and WORLD_MAP_MANAGER.SetMapByIndex then
        WORLD_MAP_MANAGER:SetMapByIndex(currentMapIndex)
    end

    Chat(NQOL.L("features.freeport.no_wayshrine", target.zoneName))
end

local function RegisterPaidFallbackDialog()
    if paidFallbackDialogRegistered or not ZO_Dialogs_RegisterCustomDialog then
        return
    end

    ZO_Dialogs_RegisterCustomDialog(PAID_FALLBACK_DIALOG_NAME, {
        canQueue = true,
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.BASIC,
        },
        title = {
            text = NQOL.L("features.freeport.freeport_fallback_d0bdf96"),
        },
        mainText = {
            text = function(dialog)
                local zoneName = dialog and dialog.data and dialog.data.target and dialog.data.target.zoneName or NQOL.L("features.freeport.target_zone")
                return NQOL.L("features.freeport.no_players", zoneName)
            end,
        },
        buttons = {
            {
                keybind = "DIALOG_PRIMARY",
                text = NQOL.L("features.freeport.confirm_04a2122"),
                callback = function(dialog)
                    local data = dialog and dialog.data
                    if data and data.target and data.runId then
                        TravelToWayshrine(data.runId, data.target)
                    end
                end,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = NQOL.L("features.freeport.cancel_77dfd21"),
            },
        },
    })

    paidFallbackDialogRegistered = true
end

local function ShowPaidFallbackDialog(runId, target)
    RegisterPaidFallbackDialog()
    if not paidFallbackDialogRegistered then
        Chat(NQOL.L("features.freeport.confirmation_unavailable"))
        return
    end

    local data = {
        runId = runId,
        target = target,
    }

    if ZO_Dialogs_ShowGamepadDialog then
        ZO_Dialogs_ShowGamepadDialog(PAID_FALLBACK_DIALOG_NAME, data)
    elseif ZO_Dialogs_ShowPlatformDialog then
        ZO_Dialogs_ShowPlatformDialog(PAID_FALLBACK_DIALOG_NAME, data)
    elseif ZO_Dialogs_ShowDialog then
        ZO_Dialogs_ShowDialog(PAID_FALLBACK_DIALOG_NAME, data)
    else
        Chat(NQOL.L("features.freeport.confirmation_unavailable"))
    end
end

local function HandlePaidFallback(runId, target)
    local fallback = GetFreeportFallback()
    if fallback == "auto" then
        TravelToWayshrine(runId, target)
    elseif fallback == "confirm" then
        ShowPaidFallbackDialog(runId, target)
    else
        Chat(NQOL.L("features.freeport.no_free_teleport", target.zoneName))
    end
end

local function OnPlayerActivated()
    local runId = activeRunId
    local activeRun = Freeport.activeRun

    if activeRun and activeRun.id == runId and activeRun.currentCandidate and activeRun.travelStarted then
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED)
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_DEACTIVATED)
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_PREPARE_FOR_JUMP)
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_JUMP_FAILED)
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_SOCIAL_ERROR)
        Chat(NQOL.L("features.freeport.traveled", activeRun.target.zoneName, activeRun.currentCandidate.displayName))
        Freeport.activeRun = nil
    end
end

local function OnPlayerDeactivated()
    local activeRun = Freeport.activeRun
    if activeRun and activeRun.currentCandidate then
        activeRun.travelStarted = true
    end
end

local function OnPrepareForJump()
    local activeRun = Freeport.activeRun
    if activeRun and activeRun.currentCandidate then
        activeRun.travelStarted = true
    end
end

local function ContinueAfterJumpFailure(errorCode)
    local activeRun = Freeport.activeRun
    if not activeRun or not activeRun.currentCandidate or activeRun.travelStarted then
        return
    end

    activeRun.lastErrorCode = errorCode or 0
    local runId = activeRun.id

    zo_callLater(function()
        local currentRun = Freeport.activeRun
        if currentRun and currentRun.id == runId and currentRun.lastErrorCode ~= nil and not currentRun.travelStarted then
            TryNextCandidate(runId)
        end
    end, 100)
end

local function OnJumpFailed(_, result)
    ContinueAfterJumpFailure(result)
end

local function OnSocialError(_, errorCode)
    ContinueAfterJumpFailure(errorCode)
end

local function RegisterTravelEvents()
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_DEACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_PREPARE_FOR_JUMP)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_JUMP_FAILED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_SOCIAL_ERROR)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_DEACTIVATED, OnPlayerDeactivated)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PREPARE_FOR_JUMP, OnPrepareForJump)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_JUMP_FAILED, OnJumpFailed)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_SOCIAL_ERROR, OnSocialError)
end

local function UnregisterTravelEvents()
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_DEACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_PREPARE_FOR_JUMP)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_JUMP_FAILED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_SOCIAL_ERROR)
end

local function AttemptCandidateJump(activeRun, candidate)
    if CancelCast then
        CancelCast()
    end

    local succeeded = pcall(candidate.jump)
    if not succeeded then
        return false
    end

    if IsMounted and IsMounted() then
        local runId = activeRun.id
        zo_callLater(function()
            local currentRun = Freeport.activeRun
            if currentRun and currentRun.id == runId and currentRun.currentCandidate == candidate and not currentRun.travelStarted and currentRun.lastErrorCode == nil then
                pcall(candidate.jump)
            end
        end, MOUNT_RETRY_DELAY_MS)
    end

    return true
end

TryNextCandidate = function(runId)
    local activeRun = Freeport.activeRun
    if not activeRun or activeRun.id ~= runId then
        return
    end

    if not CanTryPlayerJump(activeRun.target) then
        local target = activeRun.target
        Freeport.activeRun = nil
        UnregisterTravelEvents()
        HandlePaidFallback(runId, target)
        return
    end

    activeRun.candidateIndex = activeRun.candidateIndex + 1
    local candidate = activeRun.candidates[activeRun.candidateIndex]

    if not candidate then
        local target = activeRun.target
        UnregisterTravelEvents()
        Freeport.activeRun = nil
        HandlePaidFallback(runId, target)
        return
    end

    activeRun.currentCandidate = candidate
    activeRun.travelStarted = false
    activeRun.lastErrorCode = nil
    RegisterTravelEvents()

    local succeeded = AttemptCandidateJump(activeRun, candidate)
    if not succeeded then
        UnregisterTravelEvents()
        TryNextCandidate(runId)
        return
    end

    zo_callLater(function()
        local currentRun = Freeport.activeRun
        if currentRun and currentRun.id == runId and currentRun.currentCandidate == candidate and not currentRun.travelStarted then
            TryNextCandidate(runId)
        end
    end, PLAYER_JUMP_TIMEOUT_MS)
end

local function CloseMap()
    if SCENE_MANAGER and SCENE_MANAGER.ShowBaseScene then
        SCENE_MANAGER:ShowBaseScene()
    end
end

local function StartFreeport(target)
    if not IsFreeportAvailable() then
        return
    end

    if type(target) ~= "table" or target.zoneName == nil then
        target = GetSelectedLocation()
    end

    if not target or target.zoneName == "" then
        Chat(NQOL.L("features.freeport.no_location"))
        return
    end

    CloseMap()

    activeRunId = activeRunId + 1
    UnregisterTravelEvents()
    StopGuildCandidateScan()

    local candidates, seenDisplayNames = BuildFriendCandidates(target)
    local runId = activeRunId
    Freeport.activeRun = {
        id = runId,
        target = target,
        candidates = candidates,
        candidateIndex = 0,
    }

    QueueGuildCandidates(runId, target, candidates, seenDisplayNames, function()
        local activeRun = Freeport.activeRun
        if not activeRun or activeRun.id ~= runId then
            return
        end

        if #activeRun.candidates == 0 then
            Freeport.activeRun = nil
            HandlePaidFallback(runId, target)
            return
        end

        TryNextCandidate(runId)
    end)
end

local function StartFocusedWayshrineFreeport()
    StartFreeport(GetFocusedWayshrineLocation())
end

local function ShouldShowLocationsKeybind()
    return IsFreeportAvailable()
        and GAMEPAD_WORLD_MAP_LOCATIONS
        and GAMEPAD_WORLD_MAP_LOCATIONS.selectedData
        and GAMEPAD_WORLD_MAP_LOCATIONS.selectedData.index ~= nil
end

local function ShouldShowMainMapKeybind()
    return IsFreeportAvailable()
        and not (ZO_WorldMap_IsWorldMapInfoShowing and ZO_WorldMap_IsWorldMapInfoShowing())
        and not (ZO_WorldMap_IsKeepInfoShowing and ZO_WorldMap_IsKeepInfoShowing())
        and GetFocusedWayshrineLocation() ~= nil
end

local function AddFreeportKeybind(locations)
    for _, keybindDescriptor in ipairs(locations.keybindStripDescriptor) do
        if keybindDescriptor.nqolFreeport then
            return
        end
    end

    table.insert(locations.keybindStripDescriptor, {
        order = 40,
        keybind = "UI_SHORTCUT_RIGHT_STICK",
        name = FREEPORT_LABEL,
        callback = StartFreeport,
        visible = ShouldShowLocationsKeybind,
        nqolFreeport = true,
    })
end

local function IsMainMapDescriptor(descriptor)
    if type(descriptor) ~= "table" then
        return false
    end

    local hasSelectPin = false
    local hasOptions = false

    for _, keybindDescriptor in ipairs(descriptor) do
        if keybindDescriptor.name == "Gamepad World Map Select Pin" then
            hasSelectPin = true
        elseif keybindDescriptor.keybind == "UI_SHORTCUT_TERTIARY" then
            hasOptions = true
        end
    end

    return hasSelectPin and hasOptions
end

local function AddMainMapFreeportKeybind(descriptor)
    if not IsMainMapDescriptor(descriptor) then
        return
    end

    for _, keybindDescriptor in ipairs(descriptor) do
        if keybindDescriptor.nqolFreeportMainMap then
            return
        end
    end

    for _, keybindDescriptor in ipairs(descriptor) do
        if keybindDescriptor.keybind == "UI_SHORTCUT_RIGHT_STICK" then
            local originalName = keybindDescriptor.name
            local originalCallback = keybindDescriptor.callback

            keybindDescriptor.name = function(...)
                if ShouldShowMainMapKeybind() then
                    return FREEPORT_LABEL
                end

                if type(originalName) == "function" then
                    return originalName(...)
                end

                return originalName
            end

            keybindDescriptor.callback = function(...)
                if ShouldShowMainMapKeybind() then
                    StartFocusedWayshrineFreeport()
                    return
                end

                if originalCallback then
                    return originalCallback(...)
                end
            end

            keybindDescriptor.nqolFreeportMainMap = true
            return
        end
    end
end

local function InstallKeybindStripHook()
    if keybindStripHooked or not KEYBIND_STRIP or not KEYBIND_STRIP.AddKeybindButtonGroup then
        return
    end

    keybindStripHooked = true
    local originalAddKeybindButtonGroup = KEYBIND_STRIP.AddKeybindButtonGroup
    KEYBIND_STRIP.AddKeybindButtonGroup = function(self, descriptor, ...)
        AddMainMapFreeportKeybind(descriptor)
        return originalAddKeybindButtonGroup(self, descriptor, ...)
    end
end

local function InstallHooks()
    if hooksInstalled then
        return
    end

    if not GAMEPAD_WORLD_MAP_LOCATIONS or not GAMEPAD_WORLD_MAP_LOCATIONS.keybindStripDescriptor then
        hookAttempts = hookAttempts + 1
        if hookAttempts < MAX_HOOK_ATTEMPTS then
            zo_callLater(InstallHooks, HOOK_DELAY_MS)
        end
        return
    end

    AddFreeportKeybind(GAMEPAD_WORLD_MAP_LOCATIONS)
    InstallKeybindStripHook()
    hooksInstalled = true
end

local function RefreshAvailability()
    if IsInPvPZone() then
        Freeport.Cancel()
    end
    Freeport.RefreshKeybinds()
end

local function RegisterAvailabilityEvents()
    if availabilityEventsRegistered or not EVENT_MANAGER then
        return
    end

    availabilityEventsRegistered = true
    EVENT_MANAGER:RegisterForEvent(AVAILABILITY_EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED, RefreshAvailability)
    EVENT_MANAGER:RegisterForEvent(AVAILABILITY_EVENT_NAMESPACE, EVENT_ZONE_CHANGED, RefreshAvailability)
end

local function UnregisterAvailabilityEvents()
    if not availabilityEventsRegistered or not EVENT_MANAGER then
        return
    end

    availabilityEventsRegistered = false
    EVENT_MANAGER:UnregisterForEvent(AVAILABILITY_EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(AVAILABILITY_EVENT_NAMESPACE, EVENT_ZONE_CHANGED)
end

function Freeport.RefreshAvailabilityEvents()
    if IsFreeportEnabled() then
        RegisterAvailabilityEvents()
    else
        UnregisterAvailabilityEvents()
        Freeport.Cancel()
    end
end

function Freeport.Initialize()
    localDisplayName = GetDisplayName and GetDisplayName() or nil
    Freeport.RefreshAvailabilityEvents()
    InstallKeybindStripHook()
    InstallHooks()
end

function Freeport.Cancel()
    activeRunId = activeRunId + 1
    Freeport.activeRun = nil
    StopGuildCandidateScan()
    UnregisterTravelEvents()
end

function Freeport.RefreshKeybinds()
    if GAMEPAD_WORLD_MAP_LOCATIONS and GAMEPAD_WORLD_MAP_LOCATIONS.RefreshKeybind then
        GAMEPAD_WORLD_MAP_LOCATIONS:RefreshKeybind()
    elseif KEYBIND_STRIP and GAMEPAD_WORLD_MAP_LOCATIONS and GAMEPAD_WORLD_MAP_LOCATIONS.keybindStripDescriptor then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(GAMEPAD_WORLD_MAP_LOCATIONS.keybindStripDescriptor)
    end

    if ZO_WorldMap_MarkKeybindStripsDirty then
        ZO_WorldMap_MarkKeybindStripsDirty()
    end
end

NQOL.Features.Freeport = Freeport
