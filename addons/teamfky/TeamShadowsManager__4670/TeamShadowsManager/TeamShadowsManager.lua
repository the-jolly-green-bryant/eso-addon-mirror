TeamShadowsManager = TeamShadowsManager or {}

local PBT = TeamShadowsManager

local EM = EVENT_MANAGER
local ADDON_NAME = PBT.name
local UPDATE_NAME = ADDON_NAME .. "Countdown"
local SCAN_UPDATE_NAME = ADDON_NAME .. "DeferredScan"
local PORTAL_UPDATE_NAME = ADDON_NAME .. "NahviintaasPortalHP"
local NAHV_TIME_BREACH_ID = 121216
local GROUP_PULL_PREFIX = "PBT_PULL"

local function IsThisAddonLoadedName(addonName)
    return addonName == ADDON_NAME or addonName == PBT.displayName
end

if ZO_CreateStringId then
    ZO_CreateStringId("SI_BINDING_NAME_PBT_GROUP_COUNTDOWN", "Team Shadows Manager: decompte groupe")
    ZO_CreateStringId("SI_BINDING_NAME_PBT_OPEN_SETTINGS", "Team Shadows Manager: ouvrir menu")
    ZO_CreateStringId("SI_BINDING_NAME_PBT_TOGGLE_BOSS_TIMERS", "Team Shadows Manager: ON / OFF timer boss")
    ZO_CreateStringId("SI_BINDING_NAME_PBT_TOGGLE_GROUP_COUNTDOWN", "Team Shadows Manager: ON / OFF decompte")
    ZO_CreateStringId("SI_BINDING_NAME_PBT_RENDEZVOUS", "Team Shadows Manager: placer marker")
end

PBT.isRunning = false
PBT.activeKey = nil
PBT.activeBossName = nil
PBT.endsAt = 0
PBT.lastSecond = nil
PBT.lastScanMs = 0
PBT.triggerLockouts = {}
PBT.zmajaAddKills = 0
PBT.zmajaSpawnStarted = false
PBT.zmajaAddWindowMs = 0
PBT.cloudrestInitMs = 0
PBT.cloudrestPlus = 0
PBT.cloudrestPortalGroup = 0
PBT.cloudrestPortalActive = false
PBT.cloudrestLastPortalTimerMs = 0
PBT.cloudrestPullToken = 0
PBT.lastDummySeenMs = 0
PBT.lastDummyResetMs = 0
PBT.dummyWasInCombat = false
PBT.genericBossCandidates = {}
PBT.asOlmsJumpCount = 0
PBT.asOlmsPhase = 1
PBT.asOlmsLastJumpMs = 0
PBT.falgravnAirborne = false
PBT.falgravnGroundToken = 0
PBT.falgravnBasementAddsKilled = 0
PBT.nahvPortalActive = false
PBT.nahvPortalThreshold = nil
PBT.nahvPortalSkipOk = false
PBT.nahvPortalResultToken = 0
PBT.currentZoneName = nil
PBT.currentZoneId = nil
PBT.narrationLog = {}
PBT.hpThresholdState = {}
PBT.activeDisplayOffset = 0
PBT.settingsPreviewControls = {}
PBT.lastGroupCountdownSentMs = 0
PBT.savedMarkerIcons = {}
PBT.markerCameraProbe = nil

local function Chat(message)
    d(string.format("|cFF3333%s|r: %s", PBT.displayName, tostring(message)))
end

local function NowMs()
    if GetFrameTimeMilliseconds then
        return GetFrameTimeMilliseconds()
    end
    return zo_floor(GetGameTimeMilliseconds and GetGameTimeMilliseconds() or (GetTimeStamp() * 1000))
end

local function NormalizeName(name)
    if type(name) ~= "string" or name == "" then return nil end

    name = zo_strlower(name)
    name = name:gsub("â€™", "'")
    name = name:gsub("Ã©", "e"):gsub("Ã¨", "e"):gsub("Ãª", "e"):gsub("Ã«", "e")
    name = name:gsub("Ã ", "a"):gsub("Ã¢", "a"):gsub("Ã¤", "a")
    name = name:gsub("Ã®", "i"):gsub("Ã¯", "i")
    name = name:gsub("Ã´", "o"):gsub("Ã¶", "o")
    name = name:gsub("Ã¹", "u"):gsub("Ã»", "u"):gsub("Ã¼", "u")
    name = name:gsub("Ã§", "c")
    name = name:gsub("|c%x%x%x%x%x%x", "")
    name = name:gsub("|r", "")
    name = name:gsub("%^.+", "")
    name = name:gsub("^%s+", ""):gsub("%s+$", "")
    name = name:gsub("%s+", " ")

    return name ~= "" and name or nil
end

local function IsEnabled()
    return PBT.savedVars and PBT.savedVars.enabled == true
end

local function BossSpawnTimersEnabled()
    return PBT.savedVars and PBT.savedVars.bossSpawnTimers ~= false
end

local function GroupCountdownEnabled()
    return PBT.savedVars and PBT.savedVars.groupCountdownEnabled ~= false
end

local function RefreshPlayerZone()
    local zoneName
    local zoneId

    if GetUnitZone then
        zoneName = GetUnitZone("player")
    end

    if (not zoneName or zoneName == "") and GetPlayerLocationName then
        zoneName = GetPlayerLocationName()
    end

    if GetUnitZoneIndex and GetZoneId then
        local zoneIndex = GetUnitZoneIndex("player")
        if zoneIndex then
            zoneId = GetZoneId(zoneIndex)
        end
    end

    if not zoneId and GetCurrentMapZoneIndex and GetZoneId then
        local zoneIndex = GetCurrentMapZoneIndex()
        if zoneIndex then
            zoneId = GetZoneId(zoneIndex)
        end
    end

    PBT.currentZoneName = type(zoneName) == "string" and zoneName ~= "" and zoneName or PBT.currentZoneName
    PBT.currentZoneId = zoneId or PBT.currentZoneId
end

local function GetPlayerZoneName()
    if not PBT.currentZoneName then
        RefreshPlayerZone()
    end
    return PBT.currentZoneName
end

local function IsInZoneKey(zoneKey)
    if not zoneKey then return true end

    RefreshPlayerZone()

    local zoneIds = PBT.zoneIds and PBT.zoneIds[zoneKey]
    if zoneIds and PBT.currentZoneId then
        return zoneIds[PBT.currentZoneId] == true
    end

    local zoneName = NormalizeName(PBT.currentZoneName)
    local aliases = PBT.zoneAliases and PBT.zoneAliases[zoneKey]
    if not zoneName or not aliases then return false end

    for _, alias in ipairs(aliases) do
        local normalizedAlias = NormalizeName(alias)
        if normalizedAlias and (zoneName == normalizedAlias or zoneName:find(normalizedAlias, 1, true)) then
            return true
        end
    end

    return false
end

local function GetCurrentTrialKey()
    if not PBT.trials then return nil end

    RefreshPlayerZone()

    for trialKey in pairs(PBT.trials) do
        if IsInZoneKey(trialKey) then
            return trialKey
        end
    end

    return nil
end

function PBT.IsInCurrentZoneKey(zoneKey)
    return IsInZoneKey(zoneKey)
end

function PBT.GetCurrentTrialKey()
    return GetCurrentTrialKey()
end

local function PlayTickSound(secondsRemaining)
    if not PBT.savedVars or not PBT.savedVars.soundEnabled or not PlaySound then return end

    local sounds = SOUNDS or {}
    local sound

    if secondsRemaining == 0 then
        sound = sounds.DUEL_START or sounds.QUEST_OBJECTIVE_STARTED
    elseif secondsRemaining <= 3 then
        sound = sounds.COUNTDOWN_TICK or sounds.DEFAULT_CLICK
    end

    if sound then
        PlaySound(sound)
    end
end

local function IsLockedOut(key, nowMs, lockoutSeconds)
    local lastTrigger = PBT.triggerLockouts[key]
    local seconds = tonumber(lockoutSeconds) or (PBT.savedVars.lockoutSeconds or PBT.defaults.lockoutSeconds)
    local lockoutMs = seconds * 1000

    return lastTrigger ~= nil and (nowMs - lastTrigger) < lockoutMs
end

local function MarkTriggered(key, nowMs)
    PBT.triggerLockouts[key] = nowMs
end

function PBT.StopCountdown(keepVisible)
    EM:UnregisterForUpdate(UPDATE_NAME)

    PBT.isRunning = false
    PBT.activeKey = nil
    PBT.activeBossName = nil
    PBT.endsAt = 0
    PBT.lastSecond = nil
    PBT.activeDisplayOffset = 0

    if keepVisible or (PBT.savedVars and PBT.savedVars.unlocked) then
        PBT.UI:ShowIdle()
    else
        PBT.UI:Hide()
    end
end

function PBT.StartCountdown(trigger)
    if not IsEnabled() or not trigger or not trigger.seconds then return end

    local key = NormalizeName(trigger.lockoutKey or trigger.bossName)
    if not key then return end

    local nowMs = NowMs()
    local canRestart = trigger.restart == true and PBT.isRunning and PBT.activeKey == key

    if PBT.isRunning and not canRestart then return end
    if not canRestart and IsLockedOut(key, nowMs, trigger.lockoutSeconds) then return end

    if not canRestart then
        MarkTriggered(key, nowMs)
    end

    PBT.isRunning = true
    PBT.activeKey = key
    PBT.activeBossName = trigger.bossName
    PBT.activeDisplayOffset = zo_clamp(tonumber(trigger.displayOffset) or 0, -10, tonumber(trigger.seconds) or 0)
    PBT.endsAt = nowMs + ((trigger.seconds - PBT.activeDisplayOffset) * 1000)
    PBT.lastSecond = nil

    local function Update()
        local remainingMs = PBT.endsAt - NowMs()
        local secondsRemaining = zo_ceil(remainingMs / 1000)

        if secondsRemaining <= 0 then
            if PBT.lastSecond ~= 0 then
                PBT.lastSecond = 0
                PBT.UI:ShowGo(PBT.activeBossName)
                PlayTickSound(0)
            end

            zo_callLater(function()
                if PBT.isRunning and PBT.lastSecond == 0 then
                    PBT.StopCountdown(false)
                end
            end, 900)
            EM:UnregisterForUpdate(UPDATE_NAME)
            return
        end

        if secondsRemaining ~= PBT.lastSecond then
            PBT.lastSecond = secondsRemaining
            PBT.UI:ShowCountdown(PBT.activeBossName, secondsRemaining)
            PlayTickSound(secondsRemaining)
        end
    end

    Update()
    EM:RegisterForUpdate(UPDATE_NAME, 100, Update)
end

function PBT.StartNamedCountdown(name, seconds, lockoutKey)
    if not IsEnabled() or not name or not seconds then return end

    PBT.StartCountdown({
        bossName = name,
        seconds = seconds,
        lockoutKey = lockoutKey or name,
    })
end

local function GetGroupCountdownSeconds(args)
    local seconds = tonumber(args)
    if not seconds then
        seconds = tonumber(PBT.savedVars and PBT.savedVars.groupCountdownSeconds) or PBT.defaults.groupCountdownSeconds
    end

    return zo_clamp(seconds, 0, 20)
end

local function GetGroupCountdownPersonalDelay()
    local delay = tonumber(PBT.savedVars and PBT.savedVars.groupCountdownDpsDelay) or PBT.defaults.groupCountdownDpsDelay
    return zo_clamp(delay, -10, 10)
end

local function GetGroupCountdownDisplayOffset()
    return zo_clamp(-GetGroupCountdownPersonalDelay(), -10, 20)
end

local function GetGroupCountdownLabel()
    return "PULL"
end

local function BroadcastGroupCountdown(seconds)
    if not PBT.savedVars or not PBT.savedVars.groupCountdownBroadcast then return end
    if not IsUnitGrouped or not IsUnitGrouped("player") then return end

    seconds = GetGroupCountdownSeconds(seconds)
    PBT.lastGroupCountdownSentMs = NowMs()

    if LibTeamShadows and LibTeamShadows.BroadcastPull then
        LibTeamShadows.BroadcastPull(seconds)
    end

    -- Chat sending from addon code is blocked by ESO secure execution in several contexts.
    -- Group sharing uses LibGroupBroadcast through LibTeamShadows only.
end

function PBT.StartGroupCountdown(seconds, broadcast, received)
    if not GroupCountdownEnabled() then return end

    if PBT.isRunning and PBT.activeKey == "grouppull" and not received then
        PBT.StopCountdown(false)
        if broadcast then
            BroadcastGroupCountdown(0)
        end
        return
    end

    seconds = GetGroupCountdownSeconds(seconds)
    if seconds <= 0 then
        if PBT.isRunning and PBT.activeKey == "grouppull" then
            PBT.StopCountdown(false)
        end
        return
    end

    PBT.triggerLockouts.groupPull = nil
    if PBT.isRunning and PBT.activeKey ~= "grouppull" then
        PBT.StopCountdown(false)
    end

    PBT.StartCountdown({
        bossName = GetGroupCountdownLabel(),
        seconds = seconds,
        lockoutKey = "groupPull",
        lockoutSeconds = 0,
        restart = true,
        displayOffset = GetGroupCountdownDisplayOffset(),
    })

    if broadcast then
        BroadcastGroupCountdown(seconds)
    end
end

local function ReceiveGroupCountdown(seconds)
    if not GroupCountdownEnabled() then return end
    PBT.StartGroupCountdown(seconds, false, true)
end

function PBT.StartGroupCountdownFromKeybind()
    if not PBT.savedVars then return end
    PBT.savedVars.groupCountdownEnabled = true
    PBT.savedVars.groupCountdownBroadcast = true
    PBT.StartGroupCountdown(PBT.savedVars.groupCountdownSeconds, true)
end

function PBT.OpenSettings()
    if LibAddonMenu2 and LibAddonMenu2.OpenToPanel and PBT.settingsPanel then
        LibAddonMenu2:OpenToPanel(PBT.settingsPanel)
        return
    end

    Chat("menu indisponible: LibAddonMenu-2.0 n'est pas active.")
end

function PBT.OpenManagerWindow()
    if PBT.UI and PBT.UI.ShowManagerWindow then
        PBT.UI:ShowManagerWindow()
    end
end

function PBT.ToggleBossSpawnTimers()
    if not PBT.savedVars then return end

    local enabled = not BossSpawnTimersEnabled()
    PBT.savedVars.bossSpawnTimers = enabled
    PBT.savedVars.useSamuraiTimers = enabled
    Chat(enabled and "timers boss ON." or "timers boss OFF.")
end

function PBT.ToggleGroupCountdown()
    if not PBT.savedVars then return end

    PBT.savedVars.groupCountdownEnabled = not GroupCountdownEnabled()
    if not PBT.savedVars.groupCountdownEnabled and PBT.isRunning and PBT.activeKey == "grouppull" then
        PBT.StopCountdown(false)
    end
    Chat(PBT.savedVars.groupCountdownEnabled and "décompte personnalisé ON." or "décompte personnalisé OFF.")
end

local function RefreshLibTeamShadowsOptions()
    if not LibTeamShadows then return end
    if LibTeamShadows.SetRendezvousOptIn then
        LibTeamShadows.SetRendezvousOptIn(PBT.savedVars and PBT.savedVars.groupRendezvousReceive ~= false)
    end
    if LibTeamShadows.SetAcceptLeadOnly then
        LibTeamShadows.SetAcceptLeadOnly(false)
    end
    if LibTeamShadows.SetMarkerSize then
        LibTeamShadows.SetMarkerSize(PBT.savedVars and PBT.savedVars.groupBeaconSize or PBT.defaults.groupBeaconSize)
    end
    if LibTeamShadows.SetMarkerHeight then
        LibTeamShadows.SetMarkerHeight(PBT.savedVars and PBT.savedVars.groupBeaconHeight or PBT.defaults.groupBeaconHeight)
    end
    if LibTeamShadows.SetMarkerDuration then
        LibTeamShadows.SetMarkerDuration((PBT.savedVars and PBT.savedVars.groupBeaconDuration or PBT.defaults.groupBeaconDuration) * 1000)
    end
end

local function RegisterLibTeamShadowsHandlers()
    if not LibTeamShadows or not LibTeamShadows.RegisterHandler then return end

    LibTeamShadows.RegisterHandler(ADDON_NAME, function(command, payload)
        if command ~= "pull" then return end
        if not payload then return end

        local seconds = tonumber(payload.seconds)
        if not seconds then return end

        if seconds <= 0 then
            if PBT.isRunning and PBT.activeKey == "grouppull" then
                PBT.StopCountdown(false)
            end
            return
        end

        ReceiveGroupCountdown(seconds)
    end)
end
local function GetBeaconLabelId()
    if not PBT.savedVars then return 1 end

    local label = PBT.savedVars.groupBeaconLabel or PBT.defaults.groupBeaconLabel
    if label == "auto" then
        local markers = PBT.savedVars.groupBeaconSavedMarkers or {}
        local number = (#markers % 10) + 1
        PBT.savedVars.groupBeaconNextNumber = number + 1
        if PBT.savedVars.groupBeaconNextNumber > 10 then
            PBT.savedVars.groupBeaconNextNumber = 1
        end
        return number
    end

    return PBT.beaconLabelIds[label] or 1
end

local function GetBeaconOptions()
    if not PBT.savedVars then return 1, {} end

    local textureId = zo_clamp(tonumber(PBT.savedVars.groupBeaconTextureId) or PBT.defaults.groupBeaconTextureId, 1, 23)
    return textureId, {
        labelId = GetBeaconLabelId(),
        customLabel = (PBT.savedVars.groupBeaconCustomLabel and PBT.savedVars.groupBeaconCustomLabel ~= "" and PBT.savedVars.groupBeaconCustomLabel) or nil,
        size = zo_clamp(tonumber(PBT.savedVars.groupBeaconSize) or PBT.defaults.groupBeaconSize, 24, 160),
        heightOffset = zo_clamp(tonumber(PBT.savedVars.groupBeaconHeight) or PBT.defaults.groupBeaconHeight, -40, 80),
        durationMs = zo_clamp(tonumber(PBT.savedVars.groupBeaconDuration) or PBT.defaults.groupBeaconDuration, 1, 60) * 1000,
    }
end

local function BuildSavedMarkerOptions(marker)
    marker = marker or {}

    return {
        labelId = marker.labelId,
        size = marker.size,
        heightOffset = zo_clamp(tonumber(marker.heightOffset) or tonumber(PBT.savedVars and PBT.savedVars.groupBeaconHeight) or PBT.defaults.groupBeaconHeight, -40, 80),
        durationMs = marker.durationMs,
        textureId = marker.textureId,
        customLabel = marker.customLabel,
        color = marker.color,
    }
end

local function IsGrouped()
    return IsUnitGrouped and IsUnitGrouped("player")
end

local function BuildBeaconMarker(zone, wX, wY, wZ, textureId, options)
    if not zone or not wX or not wY or not wZ then return nil end

    textureId = textureId or 1
    options = options or {}

    return {
        zone = zone,
        x = wX,
        y = wY,
        z = wZ,
        textureId = textureId,
        labelId = options.labelId,
        size = options.size,
        heightOffset = options.heightOffset,
        customLabel = options.customLabel,
        color = options.color,
        durationMs = options.durationMs,
    }
end

local function BuildMarkerFromCurrentPosition(textureId, options)
    if not PBT.savedVars or not GetUnitRawWorldPosition then return nil end

    local zone, wX, wY, wZ = GetUnitRawWorldPosition("player")
    if not zone or not wX or not wY or not wZ then return nil end

    return BuildBeaconMarker(zone, wX, wY, wZ, textureId, options)
end

local function EnsureMarkerCameraProbe()
    if PBT.markerCameraProbe then return PBT.markerCameraProbe end
    if not WINDOW_MANAGER or not GuiRoot then return nil end

    local probe = WINDOW_MANAGER:CreateControl("TeamShadowsManagerMarkerCameraProbe", GuiRoot, CT_CONTROL)
    probe:SetAnchorFill(GuiRoot)
    probe:Create3DRenderSpace()
    probe:SetHidden(true)

    PBT.markerCameraProbe = probe
    return probe
end

local function BuildMarkerFromCameraTarget(textureId, options)
    if not PBT.savedVars or not GetUnitRawWorldPosition then return nil end
    if not Set3DRenderSpaceToCurrentCamera or not GuiRender3DPositionToWorldPosition then return nil end

    local zone, playerX, playerY, playerZ = GetUnitRawWorldPosition("player")
    if not zone or not playerX or not playerY or not playerZ then return nil end

    local probe = EnsureMarkerCameraProbe()
    if not probe then return nil end

    Set3DRenderSpaceToCurrentCamera(probe:GetName())
    local cameraX, cameraY, cameraZ = GuiRender3DPositionToWorldPosition(probe:Get3DRenderSpaceOrigin())
    local forwardX, forwardY, forwardZ = probe:Get3DRenderSpaceForward()
    if not cameraX or not cameraY or not cameraZ or not forwardX or not forwardY or not forwardZ then return nil end

    -- ESO does not expose the ground-target hit point. This reconstructs it by
    -- intersecting the camera ray with the player's current floor height.
    if math.abs(forwardY) < 0.0001 then return nil end

    local t = (playerY - cameraY) / forwardY
    if t <= 0 then return nil end

    local targetX = cameraX + (forwardX * t)
    local targetY = playerY
    local targetZ = cameraZ + (forwardZ * t)
    local dx = targetX - playerX
    local dz = targetZ - playerZ
    local horizontalDistance = math.sqrt((dx * dx) + (dz * dz))

    if horizontalDistance < 100 or horizontalDistance > 3500 then
        return nil
    end

    return BuildBeaconMarker(zone, zo_round(targetX), zo_round(targetY), zo_round(targetZ), textureId, options)
end

local function SaveMarker(marker)
    if not PBT.savedVars or not marker then return nil end

    PBT.savedVars.groupBeaconSavedMarkers = PBT.savedVars.groupBeaconSavedMarkers or {}
    table.insert(PBT.savedVars.groupBeaconSavedMarkers, marker)

    if PBT.SyncActiveMarkerSet then PBT.SyncActiveMarkerSet() end
    return #PBT.savedVars.groupBeaconSavedMarkers
end

function PBT.PlaceMarkerFromReticle()
    if not PBT.savedVars or PBT.savedVars.groupBeaconPlacementEnabled ~= true then
        Chat("placement marker OFF.")
        return false
    end

    RefreshLibTeamShadowsOptions()

    return PBT.SaveCurrentMarker()
end

function PBT.SendGroupRendezvous()
    return PBT.PlaceMarkerFromReticle()
end

function PBT.SaveCurrentMarker()
    local textureId, options = GetBeaconOptions()
    local marker = BuildMarkerFromCameraTarget(textureId, options) or BuildMarkerFromCurrentPosition(textureId, options)
    if not marker then
        Chat("position joueur indisponible.")
        return false
    end

    local index = SaveMarker(marker)
    PBT.RefreshSavedMarkers()

    if PBT.UI and PBT.UI.RefreshManagerWindow then
        PBT.UI:RefreshManagerWindow()
    end

    Chat(string.format("marker %d enregistre.", index or 0))
    return true
end

function PBT.ClearDisplayedSavedMarkers()
    if not PBT.savedMarkerIcons then
        PBT.savedMarkerIcons = {}
        return
    end

    for _, icon in ipairs(PBT.savedMarkerIcons) do
        if LibTeamShadows and LibTeamShadows.DiscardWorldMarker then
            LibTeamShadows.DiscardWorldMarker(icon)
        end
    end

    PBT.savedMarkerIcons = {}
end

function PBT.RefreshSavedMarkers()
    PBT.ClearDisplayedSavedMarkers()

    if not PBT.savedVars or not LibTeamShadows or not LibTeamShadows.PlaceWorldMarker then return end
    if not GetUnitRawWorldPosition then return end

    local currentZone = GetUnitRawWorldPosition("player")
    local markers = PBT.savedVars.groupBeaconSavedMarkers or {}
    local displayMode = PBT.savedVars.groupBeaconDisplayMode or "all"
    local displayLabel = PBT.savedVars.groupBeaconDisplayLabel or "all"
    local displayLabelId = PBT.beaconLabelIds[displayLabel or ""] or tonumber(displayLabel)

    for _, marker in ipairs(markers) do
        local labelMatches = displayMode ~= "filter" or displayLabel == "all" or tonumber(marker and marker.labelId) == tonumber(displayLabelId)
        if marker and marker.zone == currentZone and labelMatches then
            local options = BuildSavedMarkerOptions(marker)
            options.persistent = true

            local icon = LibTeamShadows.PlaceWorldMarker(marker, options)
            if icon then
                table.insert(PBT.savedMarkerIcons, icon)
            end
        end
    end
end

local function SerializeMarkers(markers)
    local parts = { "TSM1" }

    for _, marker in ipairs(markers) do
        if marker and marker.zone and marker.x and marker.y and marker.z then
            local color = marker.color or {}
            parts[#parts + 1] = table.concat({
                tostring(marker.zone),
                tostring(marker.x),
                tostring(marker.y),
                tostring(marker.z),
                tostring(marker.textureId or 1),
                tostring(marker.labelId or 1),
                tostring(marker.size or PBT.defaults.groupBeaconSize),
                tostring(marker.heightOffset or PBT.defaults.groupBeaconHeight),
                tostring(marker.durationMs or (PBT.defaults.groupBeaconDuration * 1000)),
                tostring(marker.customLabel or ""),
                tostring(color.r or color[1] or ""),
                tostring(color.g or color[2] or ""),
                tostring(color.b or color[3] or ""),
            }, ",")
        end
    end

    return table.concat(parts, ";")
end

function PBT.ExportSavedMarkers()
    local markers = PBT.savedVars and PBT.savedVars.groupBeaconSavedMarkers or {}
    return SerializeMarkers(markers)
end

function PBT.GetSavedMarkerSetName()
    local markers = PBT.savedVars and PBT.savedVars.groupBeaconSavedMarkers or {}
    local marker = markers[1]
    if not marker or not marker.zone then
        return "Aucune instance importee"
    end

    if GetZoneNameById then
        local name = GetZoneNameById(marker.zone)
        if name and name ~= "" then
            return zo_strformat("<<1>>", name)
        end
    end

    return "Zone " .. tostring(marker.zone)
end

local function GetCurrentZoneId()
    if GetUnitRawWorldPosition then
        local zone = GetUnitRawWorldPosition("player")
        return tonumber(zone)
    end
    return nil
end

local raidMarkerDirectory = {
    { zoneKey = "free", name = "Zone libre / actuelle" },
    { zoneKey = "aetherianArchive", name = "Aetherian Archive" },
    { zoneKey = "sanctumOphidia", name = "Sanctum Ophidia" },
    { zoneKey = "helRaCitadel", name = "Hel Ra Citadel" },
    { zoneKey = "mawOfLorkhaj", name = "Maw of Lorkhaj" },
    { zoneKey = "hallsOfFabrication", name = "Halls of Fabrication" },
    { zoneKey = "asylumSanctorium", name = "Asylum Sanctorium" },
    { zoneKey = "cloudrest", name = "Cloudrest" },
    { zoneKey = "sunspire", name = "Sunspire" },
    { zoneKey = "kynesAegis", name = "Kyne's Aegis" },
    { zoneKey = "rockgrove", name = "Rockgrove" },
    { zoneKey = "dreadsailReef", name = "Dreadsail Reef" },
    { zoneKey = "sanitysEdge", name = "Sanity's Edge" },
    { zoneKey = "lucentCitadel", name = "Lucent Citadel" },
    { zoneKey = "osseinCage", name = "Ossein Cage" },
}

local raidMarkerDirectoryByKey = {}
for _, entry in ipairs(raidMarkerDirectory) do
    raidMarkerDirectoryByKey[entry.zoneKey] = entry
end

local function GetPrimaryZoneIdForKey(zoneKey)
    if zoneKey == "free" then return nil end
    local ids = PBT.zoneIds and PBT.zoneIds[zoneKey]
    if type(ids) ~= "table" then return nil end
    for zoneId in pairs(ids) do
        return tostring(zoneId)
    end
    return nil
end

local function GetSelectedMarkerDirectoryKey()
    local selected = PBT.savedVars and PBT.savedVars.groupBeaconDirectoryKey
    if selected and selected ~= "" and raidMarkerDirectoryByKey[selected] then
        return selected
    end

    local currentTrialKey = GetCurrentTrialKey and GetCurrentTrialKey() or nil
    if currentTrialKey and raidMarkerDirectoryByKey[currentTrialKey] then
        if PBT.savedVars then
            PBT.savedVars.groupBeaconDirectoryKey = currentTrialKey
        end
        return currentTrialKey
    end

    if PBT.savedVars then
        PBT.savedVars.groupBeaconDirectoryKey = "free"
    end
    return "free"
end

local function GetMarkerSetZoneKey(zone)
    if PBT.savedVars and PBT.savedVars.groupBeaconDirectoryKey and PBT.savedVars.groupBeaconDirectoryKey ~= "" then
        return GetSelectedMarkerDirectoryKey()
    end
    return tostring(zone or GetCurrentZoneId() or "global")
end

local function GetMarkerSetForRead(zoneKey, slot)
    local sets = PBT.savedVars and PBT.savedVars.groupBeaconMarkerSets
    if not sets then return nil end

    local zoneSets = sets[zoneKey]
    if zoneSets and zoneSets.markers and zoneSets.slots and zoneSets.slots[slot] then
        local namedSet = zoneSets.markers[zoneSets.slots[slot]]
        if namedSet then return namedSet end
    end

    local set = zoneSets and zoneSets[slot]
    if set then return set end

    local legacyZoneId = GetPrimaryZoneIdForKey(zoneKey)
    if legacyZoneId and sets[legacyZoneId] then
        local legacySets = sets[legacyZoneId]
        if legacySets.markers and legacySets.slots and legacySets.slots[slot] then
            local namedSet = legacySets.markers[legacySets.slots[slot]]
            if namedSet then return namedSet end
        end
        return legacySets[slot]
    end

    return nil
end

local function GetMarkerSetSlot()
    return zo_clamp(tonumber(PBT.savedVars and PBT.savedVars.groupBeaconMarkerSetSlot) or 1, 1, 3)
end

local function CopyTable(source)
    if type(source) ~= "table" then return source end
    local target = {}
    for key, value in pairs(source) do
        target[key] = CopyTable(value)
    end
    return target
end

local function CleanMarkerSetName(slot, name)
    slot = zo_clamp(tonumber(slot) or 1, 1, 3)
    name = tostring(name or "")
    if name == "" or name == ("Liste " .. tostring(slot)) or name == ("Pack " .. tostring(slot)) then
        return "Pack " .. tostring(slot)
    end
    return name
end

local function GetMarkerSetZoneStorage(zoneKey)
    if not PBT.savedVars then return nil end
    PBT.savedVars.groupBeaconMarkerSets = PBT.savedVars.groupBeaconMarkerSets or {}
    PBT.savedVars.groupBeaconMarkerSets[zoneKey] = PBT.savedVars.groupBeaconMarkerSets[zoneKey] or {}

    local storage = PBT.savedVars.groupBeaconMarkerSets[zoneKey]
    storage.markers = storage.markers or {}
    storage.slots = storage.slots or {}
    return storage
end

local function GetMarkerPackName(slot)
    slot = zo_clamp(tonumber(slot) or GetMarkerSetSlot(), 1, 3)
    local zoneKey = GetSelectedMarkerDirectoryKey()
    local storage = GetMarkerSetZoneStorage(zoneKey)
    local key = storage and storage.slots and storage.slots[slot]
    local set = key and storage.markers and storage.markers[key]
    return CleanMarkerSetName(slot, set and set.name or key)
end

local function GetMarkerPackKey(slot)
    slot = zo_clamp(tonumber(slot) or GetMarkerSetSlot(), 1, 3)
    local zoneKey = GetSelectedMarkerDirectoryKey()
    local storage = GetMarkerSetZoneStorage(zoneKey)
    local name = storage and storage.slots and storage.slots[slot]
    if name and name ~= "" then return name end
    return CleanMarkerSetName(slot, nil)
end

function PBT.SaveCurrentMarkerSet(name)
    if not PBT.savedVars then return false, "variables non pretes" end

    local markers = PBT.savedVars.groupBeaconSavedMarkers or {}
    if #markers == 0 then return false, "aucun marker a sauver" end

    local zone = markers[1] and markers[1].zone or GetCurrentZoneId()
    local zoneKey = GetSelectedMarkerDirectoryKey()
    local slot = GetMarkerSetSlot()
    local cleanName = CleanMarkerSetName(slot, name or GetMarkerPackName(slot))
    local storage = GetMarkerSetZoneStorage(zoneKey)

    storage.markers[cleanName] = {
        name = cleanName,
        slot = slot,
        zone = zone,
        markers = CopyTable(markers),
    }
    storage.slots[slot] = cleanName
    storage[slot] = nil
    PBT.savedVars.groupBeaconMarkerSetName = cleanName

    return true, "pack " .. tostring(slot) .. " enregistre"
end

-- Write-through: mirror the working marker list into the active pack
-- slot whenever that slot holds a stored pack. Without this, every
-- edit lived only in groupBeaconSavedMarkers and was silently wiped
-- the next time ActivateCurrentMarkerSet re-copied the stale stored
-- pack over the working list.
function PBT.SyncActiveMarkerSet()
    if not PBT.savedVars then return end

    local slot = GetMarkerSetSlot()
    local zoneKey = GetSelectedMarkerDirectoryKey()
    local sets = PBT.savedVars.groupBeaconMarkerSets
    local storage = sets and sets[zoneKey]
    local key = storage and storage.slots and storage.slots[slot]
    if not key or not storage.markers or not storage.markers[key] then return end

    storage.markers[key].markers = CopyTable(PBT.savedVars.groupBeaconSavedMarkers or {})
end

function PBT.LoadCurrentMarkerSet(slot)
    if not PBT.savedVars then return false, "variables non pretes" end

    slot = zo_clamp(tonumber(slot) or GetMarkerSetSlot(), 1, 3)
    local zoneKey = GetSelectedMarkerDirectoryKey()
    local set = GetMarkerSetForRead(zoneKey, slot)

    if not set or not set.markers then return false, "pack vide" end

    PBT.savedVars.groupBeaconMarkerSetSlot = slot
    PBT.savedVars.groupBeaconSavedMarkers = CopyTable(set.markers)
    PBT.savedVars.groupBeaconImportedName = set.name
    PBT.savedVars.groupBeaconMarkerSetName = set.name
    PBT.RefreshSavedMarkers()
    return true, "pack " .. tostring(slot) .. " charge"
end

function PBT.ActivateCurrentMarkerSet(slot)
    if not PBT.savedVars then return false, "variables non pretes" end

    slot = zo_clamp(tonumber(slot) or GetMarkerSetSlot(), 1, 3)
    PBT.savedVars.groupBeaconMarkerSetSlot = slot

    local set = GetMarkerSetForRead(GetSelectedMarkerDirectoryKey(), slot)
    if set and set.markers then
        PBT.savedVars.groupBeaconSavedMarkers = CopyTable(set.markers)
        PBT.savedVars.groupBeaconImportedName = set.name
        PBT.savedVars.groupBeaconMarkerSetName = CleanMarkerSetName(slot, set.name)
        PBT.savedVars.groupBeaconNextNumber = (#PBT.savedVars.groupBeaconSavedMarkers % 10) + 1
        PBT.RefreshSavedMarkers()
        return true, "pack " .. tostring(slot) .. " charge"
    end

    PBT.savedVars.groupBeaconSavedMarkers = {}
    PBT.savedVars.groupBeaconImportedName = ""
    PBT.savedVars.groupBeaconMarkerSetName = GetMarkerPackName(slot)
    PBT.savedVars.groupBeaconNextNumber = 1
    PBT.RefreshSavedMarkers()
    return true, "pack " .. tostring(slot) .. " vide"
end

function PBT.ExportCurrentMarkerSet(slot)
    if not PBT.savedVars then return "" end

    slot = zo_clamp(tonumber(slot) or GetMarkerSetSlot(), 1, 3)
    local set = GetMarkerSetForRead(GetSelectedMarkerDirectoryKey(), slot)
    if set and set.markers then
        return SerializeMarkers(set.markers)
    end

    return SerializeMarkers(PBT.savedVars.groupBeaconSavedMarkers or {})
end

function PBT.ImportCurrentMarkerSet(text)
    if not PBT.ImportSavedMarkers then return false, "import indisponible" end

    local ok, message = PBT.ImportSavedMarkers(text)
    if not ok then return ok, message end

    return PBT.SaveCurrentMarkerSet(GetMarkerPackName(GetMarkerSetSlot()))
end

function PBT.DeleteCurrentMarkerSet(slot)
    if not PBT.savedVars then return false, "variables non pretes" end

    slot = zo_clamp(tonumber(slot) or GetMarkerSetSlot(), 1, 3)
    local zoneKey = GetSelectedMarkerDirectoryKey()
    local storage = PBT.savedVars.groupBeaconMarkerSets and PBT.savedVars.groupBeaconMarkerSets[zoneKey]
    if storage then
        local key = storage.slots and storage.slots[slot]
        if key and storage.markers then storage.markers[key] = nil end
        if storage.slots then storage.slots[slot] = nil end
        storage[slot] = nil
    end
    local legacyZoneId = GetPrimaryZoneIdForKey(zoneKey)
    if legacyZoneId and PBT.savedVars.groupBeaconMarkerSets and PBT.savedVars.groupBeaconMarkerSets[legacyZoneId] then
        local legacyStorage = PBT.savedVars.groupBeaconMarkerSets[legacyZoneId]
        local key = legacyStorage.slots and legacyStorage.slots[slot]
        if key and legacyStorage.markers then legacyStorage.markers[key] = nil end
        if legacyStorage.slots then legacyStorage.slots[slot] = nil end
        legacyStorage[slot] = nil
    end

    PBT.savedVars.groupBeaconSavedMarkers = {}
    PBT.savedVars.groupBeaconMarkerSetName = CleanMarkerSetName(slot, nil)
    PBT.savedVars.groupBeaconImportedName = ""
    if PBT.RefreshSavedMarkers then PBT.RefreshSavedMarkers() end

    return true, "pack " .. tostring(slot) .. " supprime"
end

function PBT.GetCurrentMarkerSetInfo(slot)
    if not PBT.savedVars then return nil end

    slot = zo_clamp(tonumber(slot) or GetMarkerSetSlot(), 1, 3)
    local set = GetMarkerSetForRead(GetSelectedMarkerDirectoryKey(), slot)
    if set then
        set.name = CleanMarkerSetName(slot, set.name)
    end
    return set
end

function PBT.GetMarkerPackName(slot)
    return GetMarkerPackName(slot)
end

function PBT.RenameMarkerPack(slot, name)
    if not PBT.savedVars then return false, "variables non pretes" end

    slot = zo_clamp(tonumber(slot) or GetMarkerSetSlot(), 1, 3)
    local newName = CleanMarkerSetName(slot, name)
    local zoneKey = GetSelectedMarkerDirectoryKey()
    local storage = GetMarkerSetZoneStorage(zoneKey)
    local oldKey = storage.slots[slot]

    if oldKey == newName then
        return true, "pack renomme"
    end

    local existing = oldKey and storage.markers[oldKey] or GetMarkerSetForRead(zoneKey, slot) or { markers = {} }
    if oldKey then
        storage.markers[oldKey] = nil
    end
    existing.name = newName
    existing.slot = slot
    existing.markers = existing.markers or {}
    storage.markers[newName] = existing
    storage.slots[slot] = newName
    storage[slot] = nil

    if GetMarkerSetSlot() == slot then
        PBT.savedVars.groupBeaconMarkerSetName = newName
    end

    return true, "pack renomme"
end

function PBT.GetMarkerDirectoryEntries()
    return raidMarkerDirectory
end

function PBT.SetMarkerDirectory(zoneKey)
    if not PBT.savedVars or not raidMarkerDirectoryByKey[zoneKey] then return false end
    PBT.savedVars.groupBeaconDirectoryKey = zoneKey
    return true
end

function PBT.GetMarkerDirectoryKey()
    return GetSelectedMarkerDirectoryKey()
end

function PBT.GetMarkerDirectoryName()
    local key = GetSelectedMarkerDirectoryKey()
    if key == "free" then
        local zoneId = GetCurrentZoneId()
        if zoneId and GetZoneNameById then
            local zoneName = zo_strformat("<<1>>", GetZoneNameById(zoneId) or "")
            if zoneName and zoneName ~= "" then
                return "Libre - " .. zoneName
            end
        end
        return "Zone libre / actuelle"
    end
    local entry = raidMarkerDirectoryByKey[key]
    return entry and entry.name or "Raid"
end

local function GetElmsMarkerStyle(iconKey)
    iconKey = tonumber(iconKey) or 1

    local labelId = 1
    local customLabel = nil
    local textureId = 1
    local color = nil

    if iconKey >= 1 and iconKey <= 10 then
        labelId = iconKey
    elseif iconKey == 18 then
        labelId = PBT.beaconLabelIds.OT or 10
        textureId = 9
    elseif iconKey == 21 then
        labelId = PBT.beaconLabelIds.MT or 9
        textureId = 8
    elseif iconKey >= 24 and iconKey <= 27 then
        labelId = iconKey - 23
        textureId = 2
    elseif iconKey >= 29 and iconKey <= 32 then
        labelId = iconKey - 28
        textureId = 4
    elseif iconKey >= 34 and iconKey <= 37 then
        labelId = iconKey - 33
        textureId = 5
    elseif iconKey >= 40 and iconKey <= 43 then
        labelId = iconKey - 39
        textureId = 1
    elseif iconKey >= 45 and iconKey <= 70 then
        labelId = 1
        customLabel = string.char(64 + (iconKey - 44))
    elseif iconKey == 14 or iconKey == 15 or iconKey == 23 then
        textureId = 2
    elseif iconKey == 16 or iconKey == 28 then
        textureId = 4
    elseif iconKey == 17 or iconKey == 33 then
        textureId = 5
    elseif iconKey == 19 or iconKey == 38 then
        textureId = 6
    elseif iconKey == 20 or iconKey == 39 then
        textureId = 1
    elseif iconKey == 22 or iconKey == 44 then
        textureId = 3
    end

    return textureId, zo_clamp(labelId or 1, 1, 14), customLabel, color
end

local function ImportElmsMarkers(text)
    local imported = {}

    for zone, x, y, z, iconKey in text:gmatch("/(%d+)//(%d+),(%d+),(%d+),(%d+)/") do
        local textureId, labelId, customLabel, color = GetElmsMarkerStyle(iconKey)
        imported[#imported + 1] = {
            zone = tonumber(zone),
            x = tonumber(x),
            y = tonumber(y),
            z = tonumber(z),
            textureId = textureId,
            labelId = labelId,
            customLabel = customLabel,
            color = color,
            size = 112,
            heightOffset = PBT.savedVars and PBT.savedVars.groupBeaconHeight or PBT.defaults.groupBeaconHeight,
            durationMs = (PBT.savedVars and PBT.savedVars.groupBeaconDuration or PBT.defaults.groupBeaconDuration) * 1000,
        }
    end

    return imported
end

function PBT.ImportSavedMarkers(text)
    if not PBT.savedVars then return false, "variables non pretes" end
    if type(text) ~= "string" or text == "" then return false, "texte vide" end

    local imported = {}

    if text:find("^TSM1") then
        local first = true

        for chunk in text:gmatch("[^;]+") do
            if first then
                first = false
            else
                local fields = {}
                for field in (chunk .. ","):gmatch("([^,]*),") do
                    fields[#fields + 1] = field
                    if #fields >= 13 then break end
                end

                local marker = {
                    zone = tonumber(fields[1]),
                    x = tonumber(fields[2]),
                    y = tonumber(fields[3]),
                    z = tonumber(fields[4]),
                textureId = zo_clamp(tonumber(fields[5]) or 1, 1, 23),
                    labelId = tonumber(fields[6]) or 1,
                    size = zo_clamp(tonumber(fields[7]) or PBT.defaults.groupBeaconSize, 24, 160),
                    heightOffset = zo_clamp(tonumber(fields[8]) or PBT.defaults.groupBeaconHeight, -40, 80),
                    durationMs = zo_clamp(tonumber(fields[9]) or (PBT.defaults.groupBeaconDuration * 1000), 1000, 60000),
                    customLabel = fields[10] ~= "" and fields[10] or nil,
                }

                local cr, cg, cb = tonumber(fields[11]), tonumber(fields[12]), tonumber(fields[13])
                if cr and cg and cb then
                    marker.color = {
                        r = zo_clamp(cr, 0, 1),
                        g = zo_clamp(cg, 0, 1),
                        b = zo_clamp(cb, 0, 1),
                    }
                end

                if marker.zone and marker.x and marker.y and marker.z then
                    imported[#imported + 1] = marker
                end
            end
        end
    else
        imported = ImportElmsMarkers(text)
    end

    if #imported == 0 then return false, "aucun marker trouve" end

    PBT.savedVars.groupBeaconSavedMarkers = imported
    PBT.savedVars.groupBeaconNextNumber = (#imported % 10) + 1
    PBT.savedVars.groupBeaconImportedName = PBT.GetSavedMarkerSetName()
    PBT.RefreshSavedMarkers()
    return true, tostring(#imported) .. " markers importes"
end

function PBT.ShareSavedMarker(index)
    if not PBT.savedVars then return false end
    RefreshLibTeamShadowsOptions()

    local markers = PBT.savedVars.groupBeaconSavedMarkers or {}
    local marker = markers[tonumber(index or 0)]
    if not marker then
        Chat("marker introuvable.")
        return false
    end

    if LibTeamShadows.PlaceWorldMarker then
        PBT.RefreshSavedMarkers()
        Chat("partage direct des markers desactive: utilise Exporter / Importer.")
        return true
    end

    Chat("marker non affiche: LibTeamShadows doit etre actif.")
    return false
end

function PBT.ShareAllSavedMarkers()
    if not PBT.savedVars then return end

    local markers = PBT.savedVars.groupBeaconSavedMarkers or {}
    if #markers == 0 then
        Chat("aucun marker enregistre.")
        return
    end

    if PBT.UI and PBT.UI.markerImportBox and PBT.ExportSavedMarkers then
        PBT.UI.markerImportBox:SetText(PBT.ExportSavedMarkers() or "")
        PBT.UI:SelectManagerTab("import")
        Chat("code export prepare: copie/colle le code chez les autres joueurs.")
    else
        Chat("ouvre l'onglet Import puis clique Exporter pour partager la liste.")
    end
end

function PBT.ClearSavedMarkers()
    if not PBT.savedVars then return end
    PBT.savedVars.groupBeaconSavedMarkers = {}
    PBT.savedVars.groupBeaconNextNumber = 1
    PBT.savedVars.groupBeaconImportedName = nil
    if PBT.SyncActiveMarkerSet then PBT.SyncActiveMarkerSet() end
    PBT.ClearDisplayedSavedMarkers()
    Chat("markers enregistres effaces.")
end

function PBT.UpdateSavedMarker(index, changes)
    if not PBT.savedVars or type(changes) ~= "table" then return false end

    local marker = (PBT.savedVars.groupBeaconSavedMarkers or {})[tonumber(index or 0)]
    if not marker then return false end

    if changes.textureId then
        marker.textureId = zo_clamp(tonumber(changes.textureId) or marker.textureId or 1, 1, 23)
        marker.color = nil
    end
    if changes.labelId then
        marker.labelId = zo_clamp(tonumber(changes.labelId) or marker.labelId or 1, 1, 14)
        marker.customLabel = nil
    end
    if changes.customLabel ~= nil then
        local text = tostring(changes.customLabel or ""):gsub("^%s+", ""):gsub("%s+$", "")
        marker.customLabel = text ~= "" and text or nil
    end
    if changes.heightOffset then
        marker.heightOffset = zo_clamp(tonumber(changes.heightOffset) or marker.heightOffset or 0, -40, 80)
    end
    if changes.size then
        marker.size = zo_clamp(tonumber(changes.size) or marker.size or PBT.defaults.groupBeaconSize, 24, 160)
    end
    if changes.durationMs then
        marker.durationMs = zo_clamp(tonumber(changes.durationMs) or marker.durationMs or 8000, 1000, 60000)
    end
    if changes.color then
        marker.color = {
            r = zo_clamp(tonumber(changes.color.r) or 1, 0, 1),
            g = zo_clamp(tonumber(changes.color.g) or 1, 0, 1),
            b = zo_clamp(tonumber(changes.color.b) or 1, 0, 1),
        }
    end

    if PBT.SyncActiveMarkerSet then PBT.SyncActiveMarkerSet() end
    PBT.RefreshSavedMarkers()
    return true
end

function PBT.DeleteSavedMarker(index)
    if not PBT.savedVars then return false end

    local markers = PBT.savedVars.groupBeaconSavedMarkers or {}
    index = tonumber(index or 0)
    if not index or not markers[index] then return false end

    table.remove(markers, index)
    PBT.savedVars.groupBeaconSavedMarkers = markers
    PBT.savedVars.groupBeaconNextNumber = (#markers % 10) + 1
    if PBT.SyncActiveMarkerSet then PBT.SyncActiveMarkerSet() end
    PBT.RefreshSavedMarkers()
    return true
end

function PBT.StartPracticeTimer()
    local seconds = PBT.savedVars and tonumber(PBT.savedVars.practiceSeconds) or 6
    PBT.triggerLockouts.practiceDummy = nil
    PBT.StartNamedCountdown("Training Dummy", seconds, "practiceDummy")
end

local function FindBossTrigger(name)
    local normalized = NormalizeName(name)
    if not normalized then return nil end

    local customAliases = PBT.savedVars and PBT.savedVars.customAliases
    if customAliases and customAliases[normalized] and PBT.bossLookup[customAliases[normalized]] then
        return PBT.bossLookup[customAliases[normalized]]
    end

    if PBT.bossLookup[normalized] then
        return PBT.bossLookup[normalized]
    end

    for bossName, trigger in pairs(PBT.bossLookup) do
        if normalized:find(bossName, 1, true) or bossName:find(normalized, 1, true) then
            return trigger
        end
    end

    return nil
end

local function ApplyTimerOverride(trigger)
    local overrides = PBT.savedVars and PBT.savedVars.timerOverrides
    if not overrides or not trigger or not trigger.key or not tonumber(overrides[trigger.key]) then
        return trigger
    end

    return {
        key = trigger.key,
        trialName = trigger.trialName,
        bossName = trigger.bossName,
        seconds = tonumber(overrides[trigger.key]),
        lockoutSeconds = trigger.lockoutSeconds,
        bossUnitTrigger = trigger.bossUnitTrigger,
        zoneKey = trigger.zoneKey,
        manualOnly = trigger.manualOnly,
    }
end

function PBT.TryStartForName(name)
    if not PBT.savedVars or PBT.savedVars.bossNameTimers ~= true then
        return false
    end

    local trigger = FindBossTrigger(name)
    if trigger then
        if trigger.manualOnly == true then
            return false
        end
        if PBT.savedVars and PBT.savedVars.useSamuraiTimers and trigger.key == "z'maja" then
            return false
        end
        if trigger.key == "saint olms the just" then
            return false
        end

        PBT.StartCountdown(ApplyTimerOverride(trigger))
        return true
    end

    return false
end

local function TrySpecificBossUnitTimer(name)
    local trigger = FindBossTrigger(name)
    if not trigger or trigger.bossUnitTrigger ~= true then return false end
    if trigger.zoneKey and not IsInZoneKey(trigger.zoneKey) then return false end

    PBT.StartCountdown(ApplyTimerOverride(trigger))
    return true
end

function PBT.ScanBossUnits()
    if not IsEnabled() or PBT.isRunning then return end
    if not PBT.savedVars then return end

    for i = 1, 6 do
        local unitTag = "boss" .. tostring(i)
        if DoesUnitExist(unitTag) then
            local name = GetUnitName(unitTag)
            if TrySpecificBossUnitTimer(name) then
                return
            end

            if PBT.savedVars.bossUnitDetection then
                if PBT.TryStartForName(name) then
                    return
                end

                if PBT.TryGenericCinematicTimer(unitTag, name) then
                    return
                end
            end
        end
    end
end

local monsterChannels = {
    [CHAT_CHANNEL_MONSTER_EMOTE] = true,
    [CHAT_CHANNEL_MONSTER_SAY] = true,
    [CHAT_CHANNEL_MONSTER_WHISPER] = true,
    [CHAT_CHANNEL_MONSTER_YELL] = true,
}

local groupCountdownChannels = {
    [CHAT_CHANNEL_PARTY] = true,
}

local function DialogueMatches(text, data)
    if not data or type(text) ~= "string" then return false end

    local patterns = data.patterns or { data.pattern }
    local normalizedText = NormalizeName(text) or text

    for _, pattern in ipairs(patterns) do
        if type(pattern) == "string" and pattern ~= "" then
            if data.plain then
                local normalizedPattern = NormalizeName(pattern) or pattern
                if normalizedText:find(normalizedPattern, 1, true) then
                    return true
                end
            elseif text:find(pattern) then
                return true
            end
        end
    end

    return false
end

local function CaptureNarrationLine(text)
    if not PBT.savedVars or not PBT.savedVars.narrationDebug or type(text) ~= "string" or text == "" then return end

    local line = string.format("%s | %s", GetPlayerZoneName() or "zone ?", text)
    table.insert(PBT.narrationLog, 1, line)
    while #PBT.narrationLog > 20 do
        table.remove(PBT.narrationLog)
    end
    Chat("narration: " .. text)
end

local function OnMonsterChat(_, channelType, _, text)
    if not PBT.savedVars then return end
    if type(text) ~= "string" then return end

    local seconds = text:match(GROUP_PULL_PREFIX .. ":(%d+)")
    if seconds then
        if GroupCountdownEnabled() then
            ReceiveGroupCountdown(seconds)
        end
        return
    end

    if not monsterChannels[channelType] then return end

    CaptureNarrationLine(text)

    if not BossSpawnTimersEnabled() or not PBT.savedVars.useSamuraiTimers then return end

    for index, data in ipairs(PBT.samuraiNarrationTimers or {}) do
        if (not data.zoneKey or IsInZoneKey(data.zoneKey)) and DialogueMatches(text, data) then
            PBT.StartCountdown({
                bossName = data.displayName,
                seconds = data.seconds,
                lockoutKey = data.lockoutKey or ("samuraiLine" .. tostring(index)),
                lockoutSeconds = data.lockoutSeconds,
            })
            return
        end
    end
end

local function IsZmajaActive()
    if not DoesUnitExist("boss1") then return false end

    local bossName = NormalizeName(GetUnitName("boss1"))
    if bossName ~= "z'maja" and bossName ~= "zmaja" then return false end

    local current, max = GetUnitPower("boss1", POWERTYPE_HEALTH)
    return max and max > 0, current, max
end

local function TrySamuraiAbilityTimer(result, abilityId, hitValue)
    local data = PBT.samuraiAbilityTimers and PBT.samuraiAbilityTimers[abilityId]
    if not data or not PBT.savedVars then return false end
    if not BossSpawnTimersEnabled() then return false end
    if data.setting and not PBT.savedVars[data.setting] then return false end
    if data.zoneKey and not IsInZoneKey(data.zoneKey) then return false end
    if data.results and not data.results[result] then return false end
    if data.maxHitValue and tonumber(hitValue or 0) > data.maxHitValue then return false end
    if data.minHitValue and tonumber(hitValue or 0) < data.minHitValue then return false end

    if data.markState == "falgravnAirborne" then
        if result == ACTION_RESULT_BEGIN or result == ACTION_RESULT_EFFECT_GAINED then
            PBT.falgravnAirborne = true
            PBT.falgravnBasementAddsKilled = 0
            PBT.falgravnGroundToken = (PBT.falgravnGroundToken or 0) + 1
        end
        return true
    end

    if not data.seconds then return true end

    PBT.StartCountdown({
        bossName = data.displayName,
        seconds = data.seconds,
        lockoutKey = data.lockoutKey or ("ability" .. tostring(abilityId)),
        lockoutSeconds = data.lockoutSeconds,
        restart = data.restart,
    })
    return true
end

local CLOUDREST_ZMAJA_INIT_ID = 105890
local CLOUDREST_ZMAJA_PLUS_ID = 105541
local CLOUDREST_ZMAJA_PORTAL_CAST_ID = 103946
local CLOUDREST_ZMAJA_SHADOW_REALM_ID = 108045
local CLOUDREST_ZMAJA_PORTAL_DONE_IDS = {
    [104057] = true, -- Remove Shadow Realm
    [104792] = true, -- PC Win Shadow Realm
}

local function TryCloudrestZmajaPortalTimer(result, abilityId)
    if not abilityId or not PBT.savedVars then return false end
    if not BossSpawnTimersEnabled() or not IsInZoneKey("cloudrest") then return false end

    local nowMs = NowMs()

    if abilityId == CLOUDREST_ZMAJA_INIT_ID then
        PBT.cloudrestInitMs = nowMs
        PBT.cloudrestPlus = 0
        PBT.cloudrestPortalGroup = 0
        PBT.cloudrestPortalActive = false
        PBT.cloudrestLastPortalTimerMs = 0
        PBT.cloudrestPullToken = (PBT.cloudrestPullToken or 0) + 1
        return true
    end

    if abilityId == CLOUDREST_ZMAJA_PLUS_ID and result == ACTION_RESULT_EFFECT_GAINED then
        if (PBT.cloudrestInitMs or 0) + 10000 > nowMs then
            PBT.cloudrestPlus = (PBT.cloudrestPlus or 0) + 1
        end
        return true
    end

    if abilityId == CLOUDREST_ZMAJA_PORTAL_CAST_ID then
        PBT.cloudrestPortalActive = true
        PBT.cloudrestPortalGroup = (PBT.cloudrestPortalGroup or 0) + 1
        if PBT.cloudrestPortalGroup > 2 then
            PBT.cloudrestPortalGroup = 1
        end
        PBT.cloudrestLastPortalTimerMs = 0
        return true
    end

    if CLOUDREST_ZMAJA_PORTAL_DONE_IDS[abilityId] and result == ACTION_RESULT_EFFECT_FADED and PBT.cloudrestPortalActive then
        PBT.cloudrestPortalActive = false
        return false
    end

    return false
end

local function TrySamuraiDeathNameTimer(targetName)
    local normalized = NormalizeName(targetName)
    if not normalized or not PBT.savedVars then return false end
    if not BossSpawnTimersEnabled() then return false end

    for index, data in ipairs(PBT.samuraiDeathNameTimers or {}) do
        if (not data.setting or PBT.savedVars[data.setting])
            and (not data.zoneKey or IsInZoneKey(data.zoneKey))
            and (not data.requireState or PBT[data.requireState] == true)
        then
            for _, name in ipairs(data.names or {}) do
                if normalized == name or normalized:find(name, 1, true) then
                    if data.markState then
                        PBT[data.markState] = true
                        if data.stateToken then
                            PBT[data.stateToken] = (PBT[data.stateToken] or 0) + 1
                        end
                    end

                    if data.countRequired then
                        local counterKey = data.counterKey or ("deathCount" .. tostring(index))
                        PBT[counterKey] = (PBT[counterKey] or 0) + 1
                        if PBT[counterKey] < data.countRequired then
                            return true
                        end
                    end

                    if data.seconds then
                        PBT.StartCountdown({
                            bossName = data.displayName,
                            seconds = data.seconds,
                            lockoutKey = data.lockoutKey or ("deathName" .. tostring(index)),
                            lockoutSeconds = data.lockoutSeconds,
                            restart = data.restart,
                        })
                    end

                    if data.clearStateAfterMs and data.requireState then
                        local tokenKey = data.stateToken or "falgravnGroundToken"
                        PBT[tokenKey] = (PBT[tokenKey] or 0) + 1
                        local token = PBT[tokenKey]
                        zo_callLater(function()
                            if PBT[tokenKey] == token then
                                PBT[data.requireState] = false
                                if data.counterKey then
                                    PBT[data.counterKey] = 0
                                end
                            end
                        end, data.clearStateAfterMs)
                    end

                    return true
                end
            end
        end
    end

    return false
end

local AS_OLMS_JUMP_START = 98535
local AS_OLMS_PHASES = {
    [98615] = 2,
    [98677] = 3,
    [98678] = 4,
    [98679] = 5,
}

local function ResetAsOlms()
    PBT.asOlmsJumpCount = 0
    PBT.asOlmsPhase = 1
    PBT.asOlmsLastJumpMs = 0
    PBT.falgravnAirborne = false
    PBT.falgravnGroundToken = 0
    PBT.falgravnBasementAddsKilled = 0
    PBT.hofAfterTriplets = false
    PBT.hofTripletsToken = 0
end

local function TryAsOlmsFourthLanding(result, abilityId)
    if not PBT.savedVars or not PBT.savedVars.asOlmsFourthLanding then return false end
    if not IsInZoneKey("asylumSanctorium") then return false end
    if result ~= ACTION_RESULT_BEGIN and result ~= ACTION_RESULT_EFFECT_GAINED then return false end

    local phase = AS_OLMS_PHASES[abilityId]
    if phase then
        PBT.asOlmsPhase = phase
        PBT.asOlmsJumpCount = 0
        PBT.asOlmsLastJumpMs = 0
        return false
    end

    if abilityId ~= AS_OLMS_JUMP_START then
        return false
    end

    local nowMs = NowMs()
    if nowMs - (PBT.asOlmsLastJumpMs or 0) < 2500 then
        return false
    end

    PBT.asOlmsLastJumpMs = nowMs
    PBT.asOlmsJumpCount = PBT.asOlmsJumpCount + 1

    if PBT.asOlmsJumpCount == 1 then
        local seconds = tonumber(PBT.savedVars.asOlmsLandingSeconds) or PBT.defaults.asOlmsLandingSeconds
        PBT.StartNamedCountdown("Olms 4th Landing", seconds, "asOlmsPhase" .. tostring(PBT.asOlmsPhase))
        return true
    end

    return false
end

local function IsTrainingDummyName(name)
    local normalized = NormalizeName(name)
    if not normalized then return false end

    return normalized:find("target dummy", 1, true)
        or normalized:find("training dummy", 1, true)
        or normalized:find("trial dummy", 1, true)
        or normalized:find("iron atronach", 1, true)
        or normalized:find("entrainement", 1, true)
        or normalized:find("atronach de fer", 1, true)
        or normalized:find("mannequin", 1, true)
        or normalized:find("cible d'entrainement", 1, true)
end

local function MarkDummyCombatFromName(name)
    if not IsTrainingDummyName(name) then return end

    PBT.lastDummySeenMs = NowMs()
    PBT.dummyWasInCombat = true
end

local trashNameFragments = {
    "add",
    "archer",
    "assassin",
    "atronach",
    "behemoth",
    "colossus",
    "creeper",
    "fabricant",
    "factotum",
    "gargoyle",
    "guardian",
    "harpy",
    "knight",
    "mage",
    "protector",
    "sentinel",
    "shaman",
    "soldier",
    "spider",
    "totem",
    "warrior",
    "watcher",
    "araignee",
    "gardien",
    "protecteur",
    "sentinelle",
    "soldat",
    "guerrier",
}

local function IsBossUnitTag(unitTag)
    return type(unitTag) == "string" and unitTag:find("^boss%d+$") ~= nil
end

local function IsHardOrBossDifficulty(unitTag)
    if not GetUnitDifficulty or not unitTag or not DoesUnitExist(unitTag) then
        return false
    end

    local difficulty = GetUnitDifficulty(unitTag)
    return difficulty == MONSTER_DIFFICULTY_HARD
        or difficulty == MONSTER_DIFFICULTY_DEADLY
end

local function LooksLikeTrash(name)
    local normalized = NormalizeName(name)
    if not normalized then return true end

    for _, fragment in ipairs(trashNameFragments) do
        if normalized:find(fragment, 1, true) then
            return true
        end
    end

    return false
end

local function HasBossHealth(unitTag)
    local current, max = GetUnitPower(unitTag, POWERTYPE_HEALTH)
    return max and max > 0 and current and current > 0
end

local function IsEligibleGenericBoss(unitTag, name)
    if not name or name == "" or not HasBossHealth(unitTag) then
        return false
    end

    if IsBossUnitTag(unitTag) then
        if GetUnitDifficulty and IsHardOrBossDifficulty(unitTag) then
            return IsHardOrBossDifficulty(unitTag)
        end
        return not LooksLikeTrash(name)
    end

    if unitTag == "reticleover" and PBT.savedVars and PBT.savedVars.worldBossTimers then
        return IsHardOrBossDifficulty(unitTag) and not LooksLikeTrash(name)
    end

    return false
end

function PBT.TryGenericCinematicTimer(unitTag, name)
    if not PBT.savedVars
        or not PBT.savedVars.genericCinematicTimers
        or IsUnitInCombat("player")
        or not IsEligibleGenericBoss(unitTag, name)
    then
        return false
    end

    local key = NormalizeName(name)
    if not key then return false end

    local nowMs = NowMs()
    local candidate = PBT.genericBossCandidates[key]
    if not candidate or nowMs - candidate.firstSeen > 6000 then
        PBT.genericBossCandidates[key] = {
            firstSeen = nowMs,
            seen = 1,
        }
        zo_callLater(function()
            PBT.ScanBossUnits()
        end, 1200)
        return false
    end

    candidate.seen = candidate.seen + 1
    if candidate.seen < 2 or nowMs - candidate.firstSeen < 1000 then
        zo_callLater(function()
            PBT.ScanBossUnits()
        end, 1200)
        return false
    end

    PBT.StartNamedCountdown(
        zo_strformat("<<1>>", name),
        tonumber(PBT.savedVars.genericCinematicSeconds) or PBT.defaults.genericCinematicSeconds,
        "generic:" .. key
    )
    return true
end

local function StartPracticeFromDummyReset()
    local nowMs = NowMs()

    if not PBT.savedVars
        or not PBT.savedVars.autoPracticeOnDummyReset
        or PBT.isRunning
        or not PBT.dummyWasInCombat
        or nowMs - (PBT.lastDummyResetMs or 0) < 1000
    then
        return false
    end

    PBT.lastDummyResetMs = nowMs
    PBT.dummyWasInCombat = false
    PBT.StartPracticeTimer()
    return true
end

local function ScanReticleBoss()
    if not IsEnabled() or PBT.isRunning then return end
    if not PBT.savedVars or not PBT.savedVars.worldBossTimers then return end

    if DoesUnitExist("reticleover") then
        local name = GetUnitName("reticleover")
        if PBT.TryStartForName(name) then return end
        PBT.TryGenericCinematicTimer("reticleover", name)
    end
end

function PBT.QueueScan(delayMs)
    local nowMs = NowMs()
    if nowMs - (PBT.lastScanMs or 0) < 500 then return end

    PBT.lastScanMs = nowMs
    EM:UnregisterForUpdate(SCAN_UPDATE_NAME)
    EM:RegisterForUpdate(SCAN_UPDATE_NAME, delayMs or 250, function()
        EM:UnregisterForUpdate(SCAN_UPDATE_NAME)
        PBT.ScanBossUnits()
    end)
end

local function OnBossesChanged()
    RefreshPlayerZone()
    if not PBT.savedVars then return end
    PBT.QueueScan(150)
end

local function IsPlayerUnitTag(unitTag)
    if unitTag == "player" then return true end
    if unitTag and AreUnitsEqual then
        return AreUnitsEqual("player", unitTag)
    end
    return false
end

local function IsNahviintaasName(name)
    local normalized = NormalizeName(name)
    return normalized == "nahviintaas" or (normalized and normalized:find("nahviintaas", 1, true) ~= nil)
end

local function GetNahviintaasBossUnitTag()
    for i = 1, 6 do
        local unitTag = "boss" .. tostring(i)
        if DoesUnitExist(unitTag) and IsNahviintaasName(GetUnitName(unitTag)) then
            return unitTag
        end
    end

    return nil
end

local function GetNahviintaasHpPercent()
    local unitTag = GetNahviintaasBossUnitTag()
    if not unitTag then return nil end

    local current, max = GetUnitPower(unitTag, POWERTYPE_HEALTH)
    if not current or not max or max <= 0 then return nil end

    return (current / max) * 100
end

local function GetNextNahviintaasPortalThreshold(percent)
    if not percent then return nil end
    if percent > 70 then return 70 end
    if percent > 50 then return 50 end
    return nil
end

local function ShowNahvPortalResult(text, r, g, b)
    if not PBT.UI or not PBT.UI.ShowPortalStatus then return end

    PBT.UI:ShowPortalStatus(text, r, g, b)
    PBT.nahvPortalResultToken = (PBT.nahvPortalResultToken or 0) + 1
    local token = PBT.nahvPortalResultToken

    zo_callLater(function()
        if PBT.nahvPortalResultToken == token and not PBT.nahvPortalActive and PBT.UI and PBT.UI.HidePortalStatus then
            PBT.UI:HidePortalStatus()
        end
    end, 2200)
end

local function UpdateNahvPortalStatus()
    if not PBT.nahvPortalActive or not IsEnabled() or not PBT.savedVars or not PBT.savedVars.nahvPortalHpWarning then
        EM:UnregisterForUpdate(PORTAL_UPDATE_NAME)
        if PBT.UI and PBT.UI.HidePortalStatus then
            PBT.UI:HidePortalStatus()
        end
        return
    end

    local percent = GetNahviintaasHpPercent()
    if not percent then
        PBT.UI:ShowPortalStatus("PORTAIL: boss ?", 1, 0.75, 0.1)
        return
    end

    if not PBT.nahvPortalThreshold then
        PBT.nahvPortalThreshold = GetNextNahviintaasPortalThreshold(percent)
    end

    local threshold = PBT.nahvPortalThreshold
    if not threshold then
        PBT.UI:ShowPortalStatus("PORTAIL: plus de seuil", 0.8, 0.8, 0.8)
        return
    end

    local delta = percent - threshold
    if delta <= 0 then
        PBT.nahvPortalSkipOk = true
        PBT.UI:ShowPortalStatus(string.format("SKIP %d%% OK", threshold), 0.1, 1, 0.1)
        return
    end

    if delta <= 3 then
        PBT.UI:ShowPortalStatus(string.format("PORTAIL %d%%: %.1f%%", threshold, delta), 1, 0.9, 0.05)
    else
        PBT.UI:ShowPortalStatus(string.format("PORTAIL %d%%: %.1f%%", threshold, delta), 1, 1, 1)
    end
end

local function StartNahvPortalStatus()
    if not PBT.savedVars or not PBT.savedVars.nahvPortalHpWarning then return end

    PBT.nahvPortalActive = true
    PBT.nahvPortalSkipOk = false
    PBT.nahvPortalThreshold = GetNextNahviintaasPortalThreshold(GetNahviintaasHpPercent())
    UpdateNahvPortalStatus()
    EM:UnregisterForUpdate(PORTAL_UPDATE_NAME)
    EM:RegisterForUpdate(PORTAL_UPDATE_NAME, 250, UpdateNahvPortalStatus)
end

local function StopNahvPortalStatus(showResult)
    if not PBT.nahvPortalActive then return end

    local threshold = PBT.nahvPortalThreshold
    local skipOk = PBT.nahvPortalSkipOk

    PBT.nahvPortalActive = false
    PBT.nahvPortalThreshold = nil
    PBT.nahvPortalSkipOk = false
    EM:UnregisterForUpdate(PORTAL_UPDATE_NAME)

    if showResult and threshold then
        if skipOk then
            ShowNahvPortalResult(string.format("SKIP %d%% OK", threshold), 0.1, 1, 0.1)
        else
            ShowNahvPortalResult(string.format("PAS SKIP %d%%", threshold), 1, 0.05, 0.05)
        end
    elseif PBT.UI and PBT.UI.HidePortalStatus then
        PBT.UI:HidePortalStatus()
    end
end

local function UnitNameMatchesList(unitName, names)
    local normalized = NormalizeName(unitName)
    if not normalized then return false end

    for _, name in ipairs(names or {}) do
        local candidate = NormalizeName(name)
        if candidate and (normalized == candidate or normalized:find(candidate, 1, true)) then
            return true
        end
    end

    return false
end

local function ShowShortStatus(text, color)
    if not PBT.UI or not PBT.UI.ShowPortalStatus then return end

    local r, g, b = 1, 1, 1
    if color then
        r, g, b = color[1] or r, color[2] or g, color[3] or b
    end

    PBT.UI:ShowPortalStatus(text, r, g, b)
    PBT.nahvPortalResultToken = (PBT.nahvPortalResultToken or 0) + 1
    local token = PBT.nahvPortalResultToken

    zo_callLater(function()
        if PBT.nahvPortalResultToken == token and not PBT.nahvPortalActive and PBT.UI and PBT.UI.HidePortalStatus then
            PBT.UI:HidePortalStatus()
        end
    end, 2500)
end

local function TryHpThresholdAnnouncement(unitTag, powerValue, powerMax)
    if not IsEnabled() or not PBT.savedVars or not PBT.savedVars.useSamuraiTimers then return end
    if not unitTag or not powerValue or not powerMax or powerMax <= 0 then return end
    if not DoesUnitExist(unitTag) then return end

    local unitName = GetUnitName(unitTag)
    if not unitName or unitName == "" then return end

    local percent = (powerValue / powerMax) * 100
    for _, data in ipairs(PBT.hpThresholdAnnouncements or {}) do
        if (not data.zoneKey or IsInZoneKey(data.zoneKey)) and UnitNameMatchesList(unitName, data.bossNames) then
            for _, threshold in ipairs(data.thresholds or {}) do
                local key = string.format("%s:%s:%s", data.zoneKey or "zone", NormalizeName(unitName) or unitName, tostring(threshold.percent))
                if percent <= threshold.percent and not PBT.hpThresholdState[key] then
                    PBT.hpThresholdState[key] = true
                    ShowShortStatus(string.format("%s %d%%", threshold.text, threshold.percent), threshold.color)
                    return
                end
            end
        end
    end
end

local function OnPowerUpdate(_, unitTag, _, powerType, powerValue, powerMax)
    if powerType and powerType ~= POWERTYPE_HEALTH and powerType ~= COMBAT_MECHANIC_FLAGS_HEALTH then return end
    TryHpThresholdAnnouncement(unitTag, powerValue, powerMax)
end

local function OnEffectChanged(_, changeType, _, effectName, unitTag, _, endTime, stackCount, iconName, _, _, _, _, _, _, abilityId)
    if abilityId == NAHV_TIME_BREACH_ID and IsPlayerUnitTag(unitTag) then
        if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
            if PBT.nahvPortalActive then
                UpdateNahvPortalStatus()
            else
                StartNahvPortalStatus()
            end
        elseif changeType == EFFECT_RESULT_FADED then
            StopNahvPortalStatus(true)
        end
        return
    end

    if abilityId == CLOUDREST_ZMAJA_SHADOW_REALM_ID and changeType == EFFECT_RESULT_FADED then
        TryCloudrestZmajaPortalTimer(ACTION_RESULT_EFFECT_FADED, abilityId)
        return
    end

    if PBT.isRunning or not IsEnabled() then return end

    if unitTag and unitTag:find("boss", 1, true) then
        if PBT.savedVars then
            PBT.QueueScan(250)
        end
        return
    end

    if PBT.savedVars and PBT.savedVars.bossUnitDetection then
        PBT.TryStartForName(effectName)
    end
end

local function OnCombatEvent(_, result, _, abilityName, _, _, sourceName, sourceType, targetName, targetType, hitValue, _, _, _, _, _, abilityId)
    if not IsEnabled() then return end

    MarkDummyCombatFromName(sourceName)
    MarkDummyCombatFromName(targetName)

    if abilityId and TryAsOlmsFourthLanding(result, abilityId) then
        return
    end

    if abilityId and TryCloudrestZmajaPortalTimer(result, abilityId) then
        return
    end

    if abilityId and TrySamuraiAbilityTimer(result, abilityId, hitValue) then
        return
    end

    if result == ACTION_RESULT_DIED and TrySamuraiDeathNameTimer(targetName) then
        return
    end

    if PBT.isRunning then return end

    if PBT.savedVars and PBT.savedVars.bossUnitDetection then
        if PBT.TryStartForName(targetName) or PBT.TryStartForName(sourceName) then
            return
        end

        if abilityName and FindBossTrigger(abilityName) then
            PBT.QueueScan(250)
        end
    end
end
local function ToggleUnlock()
    local unlocked = not (PBT.savedVars and PBT.savedVars.unlocked == true)
    PBT.UI:SetUnlocked(unlocked)
    Chat(unlocked and "fenetre deverrouillee." or "fenetre verrouillee.")
end

local function HandleScale(args)
    local value = tonumber(args)
    if not value then
        Chat("utilisation: /pbtscale 1.0  (min 0.5, max 2.5)")
        return
    end

    local ok, scale = PBT.SetScale(value)
    if ok then
        Chat(string.format("taille reglee sur %.2f.", scale))
    end
end

local function HandleColor(args)
    local r, g, b = zo_strsplit(" ", args or "")
    if not tonumber(r) or not tonumber(g) or not tonumber(b) then
        Chat("utilisation: /pbtcolor 1 0 0  (valeurs RGB entre 0 et 1)")
        return
    end

    local ok, color = PBT.SetColor(tonumber(r), tonumber(g), tonumber(b))

    if not ok or not color then
        Chat("utilisation: /pbtcolor 1 0 0  (valeurs RGB entre 0 et 1)")
        return
    end

    Chat(string.format("couleur reglee sur %.2f %.2f %.2f.", color.r, color.g, color.b))
end

local function PrintTimerList()
    local currentTrialKey = GetCurrentTrialKey()
    if not currentTrialKey then
        Chat("timers actifs: aucune instance reconnue ici.")
        return
    end

    Chat("timers actifs pour cette instance:")

    for trialKey, trial in pairs(PBT.trials) do
        if trialKey == currentTrialKey then
            d(string.format("|cFFFFFF%s|r", trial.name))
            for normalizedName, data in pairs(trial.bosses) do
                local seconds = data.seconds
                local overrides = PBT.savedVars and PBT.savedVars.timerOverrides
                if overrides and tonumber(overrides[normalizedName]) then
                seconds = tonumber(overrides[normalizedName])
                end
                d(string.format("  %s = %ss  (%s)", data.displayName, tostring(seconds), normalizedName))
            end
        end
    end
end

local function ResolveBossKey(name)
    local trigger = FindBossTrigger(name)
    return trigger and trigger.key or nil
end

local function HandleTimer(args)
    args = args or ""

    local bossName, secondsText = args:match("^(.-)%s+(%d+)$")
    local seconds = tonumber(secondsText)

    if not bossName or not seconds then
        Chat("utilisation: /pbttimer z'maja 21")
        return
    end

    local bossKey = ResolveBossKey(bossName)
    if not bossKey then
        Chat("boss inconnu. Utilise /pbtlist pour voir les cles, ou /pbtalias pour ajouter un nom.")
        return
    end

    seconds = zo_clamp(seconds, 1, 60)
    PBT.savedVars.timerOverrides[bossKey] = seconds
    Chat(string.format("%s regle sur %ss.", PBT.bossLookup[bossKey].bossName, seconds))
end

local function StartBossKeyTimer(bossKey)
    local trigger = PBT.bossLookup and PBT.bossLookup[bossKey]
    if not trigger then return false end

    local seconds = trigger.seconds
    local overrides = PBT.savedVars and PBT.savedVars.timerOverrides
    if overrides and tonumber(overrides[bossKey]) then
        seconds = tonumber(overrides[bossKey])
    end

    PBT.StartCountdown({
        key = bossKey,
        trialName = trigger.trialName,
        bossName = trigger.bossName,
        seconds = seconds,
        lockoutSeconds = trigger.lockoutSeconds,
    })

    return true
end

local function HandleInfiniteArchive(args)
    args = args or ""
    local bossKey = ResolveBossKey(args)

    if not bossKey or not PBT.bossLookup[bossKey] or PBT.bossLookup[bossKey].trialName ~= "Infinite Archive" then
        Chat("utilisation: /pbtia tho'at replicanum | frost atronach | mantikora | dragon | marauder bittog")
        return
    end

    StartBossKeyTimer(bossKey)
end

local function HandleAlias(args)
    args = args or ""

    local bossKeyText, alias = args:match("^(.-)%s*=%s*(.+)$")
    if not bossKeyText or bossKeyText == "" then
        bossKeyText, alias = args:match("^(%S+)%s+(.+)$")
    end

    if not bossKeyText or not alias then
        Chat("utilisation: /pbtalias z'maja = Nom exact vu en jeu")
        return
    end

    local bossKey = ResolveBossKey(bossKeyText)
    local normalizedAlias = NormalizeName(alias)

    if not bossKey or not normalizedAlias then
        Chat("boss ou alias invalide.")
        return
    end

    PBT.savedVars.customAliases[normalizedAlias] = bossKey
    Chat(string.format("alias ajoute: %s -> %s.", alias, PBT.bossLookup[bossKey].bossName))
end

local function HandlePractice(args)
    local seconds = tonumber(args)

    if seconds then
        PBT.savedVars.practiceSeconds = zo_clamp(seconds, 1, 60)
    end

    PBT.StartPracticeTimer()
end

local function HandlePracticeTime(args)
    local seconds = tonumber(args)
    if not seconds then
        Chat("utilisation: /pbtpracticetime 6")
        return
    end

    PBT.savedVars.practiceSeconds = zo_clamp(seconds, 1, 60)
    Chat(string.format("timer mannequin regle sur %ss.", PBT.savedVars.practiceSeconds))
end

local function HandleGroupCountdown(args)
    local seconds = GetGroupCountdownSeconds(args)
    PBT.savedVars.groupCountdownSeconds = seconds
    PBT.StartGroupCountdown(seconds, true)
end

local function HandleGroupCountdownTest(args)
    local seconds = GetGroupCountdownSeconds(args)
    PBT.savedVars.groupCountdownBroadcast = true
    PBT.savedVars.groupCountdownEnabled = true
    PBT.StartGroupCountdown(seconds, true)
    Chat(string.format("test decompte groupe envoye: %ss", seconds))
end

local function ResetMenuButton()
    if not PBT.savedVars or not PBT.UI or not PBT.UI.ApplyMenuButtonSettings then return end

    PBT.savedVars.menuButtonEnabled = true
    PBT.savedVars.menuButtonX = 0
    PBT.savedVars.menuButtonY = 0
    PBT.savedVars.menuButtonSize = PBT.savedVars.menuButtonSize or PBT.defaults.menuButtonSize
    PBT.UI:ApplyMenuButtonSettings()
    Chat("bouton menu logo remis au centre.")
end

local function HandleGeneric(args)
    local seconds = tonumber(args)
    if not seconds then
        Chat("utilisation: /pbtgeneric 8")
        return
    end

    PBT.savedVars.genericCinematicSeconds = zo_clamp(seconds, 1, 60)
    Chat(string.format("timer generique boss regle sur %ss.", PBT.savedVars.genericCinematicSeconds))
end

local function HandleAsOlms(args)
    local seconds = tonumber(args)
    if not seconds then
        Chat("utilisation: /pbtolms 10")
        return
    end

    PBT.savedVars.asOlmsLandingSeconds = zo_clamp(seconds, 1, 60)
    Chat(string.format("vAS Olms 1er saut -> 4e atterrissage regle sur %ss.", PBT.savedVars.asOlmsLandingSeconds))
end

local function ToggleNarrationDebug()
    if not PBT.savedVars then return end
    PBT.savedVars.narrationDebug = not PBT.savedVars.narrationDebug
    Chat(PBT.savedVars.narrationDebug and "capture narration activee." or "capture narration desactivee.")
end

local function PrintNarrationLog()
    Chat("dernieres narrations:")
    for i, line in ipairs(PBT.narrationLog or {}) do
        d(string.format("%02d. %s", i, line))
    end
end

local function PrintBossUnits()
    Chat("boss detectes par le client:")

    for i = 1, 6 do
        local unitTag = "boss" .. tostring(i)
        if DoesUnitExist(unitTag) then
            d(string.format("%s = %s", unitTag, GetUnitName(unitTag) or ""))
        else
            d(string.format("%s = absent", unitTag))
        end
    end
end

local function PrintZoneName()
    RefreshPlayerZone()
    Chat(string.format("zone ESO: %s / id %s", GetPlayerZoneName() or "inconnue", tostring(PBT.currentZoneId or "?")))
end

local function RefreshSettingsPreviewControls()
    if not PBT.settingsPreviewControls or not PBT.savedVars then return end

    local color = PBT.savedVars.color or PBT.defaults.color
    local scale = tonumber(PBT.savedVars.scale) or PBT.defaults.scale

    for _, control in ipairs(PBT.settingsPreviewControls) do
        if control and control.label then
            control.label:SetColor(color.r or 1, color.g or 0.12, color.b or 0.08, color.a or 1)
            control.label:SetScale(zo_clamp(scale, 0.5, 2.5))
        end
    end
end

local function CreateSettingsPreview(control)
    if not control then return end

    local wm = WINDOW_MANAGER
    local preview = wm:CreateControl(nil, control, CT_LABEL)
    preview:SetAnchor(LEFT, control, LEFT, 14, 0)
    preview:SetDimensions(160, 48)
    preview:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    preview:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    preview:SetFont("ZoFontWinH1")
    preview:SetText("7")

    control.label = preview
    table.insert(PBT.settingsPreviewControls, control)
    RefreshSettingsPreviewControls()
end

local function CreateSettingsHeaderIcon(control)
    if not control then return end

    local wm = WINDOW_MANAGER
    control:SetDimensions(650, 70)

    local icon = wm:CreateControl(nil, control, CT_TEXTURE)
    icon:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 4)
    icon:SetDimensions(48, 48)
    icon:SetTexture("TeamShadowsManager/TeamShadowsManagerIcon.dds")

    local title = wm:CreateControl(nil, control, CT_LABEL)
    title:SetAnchor(TOPLEFT, icon, TOPRIGHT, 14, 6)
    title:SetDimensions(560, 24)
    title:SetFont("ZoFontWinH4")
    title:SetColor(1, 1, 1, 0.95)
    title:SetText("Team Shadows Manager")

    local author = wm:CreateControl(nil, control, CT_LABEL)
    author:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 2)
    author:SetDimensions(560, 20)
    author:SetFont("ZoFontGameSmall")
    author:SetColor(0.8, 0.8, 0.8, 0.9)
    author:SetText("TeamFky - EyrOn")
end

local function TestVisualAnnouncement()
    if not PBT.UI then return end

    if PBT.isRunning then
        PBT.StopCountdown(false)
    end

    PBT.UI:ApplySettings()
    PBT.UI:ShowCountdown("TEST", 3)

    zo_callLater(function()
        if PBT.UI then PBT.UI:ShowCountdown("TEST", 2) end
    end, 1000)

    zo_callLater(function()
        if PBT.UI then PBT.UI:ShowCountdown("TEST", 1) end
    end, 2000)

    zo_callLater(function()
        if PBT.UI then PBT.UI:ShowGo("TEST") end
    end, 3000)

    zo_callLater(function()
        if PBT.UI and not PBT.isRunning and not PBT.portalStatusActive then
            if PBT.savedVars and PBT.savedVars.unlocked then
                PBT.UI:ShowIdle()
            else
                PBT.UI:Hide()
            end
        end
    end, 4200)
end

local nativeRaidTimers = {
    { zoneKey = "cloudrest", name = "Cloudrest", cases = "Z'Maja pull apres Shadow Realm" },
    { zoneKey = "hallsOfFabrication", name = "Halls of Fabrication", cases = "Hunter-Killer, Pinnacle, Triplets" },
    { zoneKey = "asylumSanctorium", name = "Asylum Sanctorium", cases = "Olms 4e atterrissage" },
    { zoneKey = "mawOfLorkhaj", name = "Maw of Lorkhaj", cases = "Zhaj'hassa, Rakkhat" },
    { zoneKey = "aetherianArchive", name = "Aetherian Archive", cases = "Varlariel" },
    { zoneKey = "sunspire", name = "Sunspire", cases = "Lokkestiiz, Yolnahkriin, Nahviintaas" },
    { zoneKey = "kynesAegis", name = "Kyne's Aegis", cases = "Falgravn retour sous-sol" },
    { zoneKey = "dreadsailReef", name = "Dreadsail Reef", cases = "Taleria execute" },
    { zoneKey = "sanitysEdge", name = "Sanity's Edge", cases = "Yaseyla HP" },
    { zoneKey = "infiniteArchive", name = "Infinite Archive", cases = "Timers manuels" },
}

local function GetNativeRaidTimersForCurrentInstance()
    local currentTrialKey = GetCurrentTrialKey()
    local list = {}

    if not currentTrialKey then
        return list
    end

    for _, raid in ipairs(nativeRaidTimers) do
        if raid.zoneKey == currentTrialKey then
            table.insert(list, raid)
        end
    end

    return list
end

function PBT.GetNativeRaidTimersForCurrentInstance()
    return GetNativeRaidTimersForCurrentInstance()
end

local function CreateNativeRaidGrid(control)
    if not control then return end

    local wm = WINDOW_MANAGER
    local raids = GetNativeRaidTimersForCurrentInstance()
    local columns = 3
    local cellWidth = 205
    local rowHeight = 42
    local rows = math.max(1, zo_ceil(#raids / columns))

    control:SetDimensions(650, 32 + (rows * rowHeight))

    local title = wm:CreateControl(nil, control, CT_LABEL)
    title:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
    title:SetDimensions(640, 26)
    title:SetFont("ZoFontGameBold")
    title:SetColor(1, 1, 1, 0.95)
    title:SetText("Timers boss natifs de l'instance")

    if #raids == 0 then
        local empty = wm:CreateControl(nil, control, CT_LABEL)
        empty:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 34)
        empty:SetDimensions(620, 24)
        empty:SetFont("ZoFontGame")
        empty:SetColor(0.78, 0.78, 0.78, 0.9)
        empty:SetText("Instance non reconnue ici : aucun timer boss appele.")
        return
    end

    for index, raid in ipairs(raids) do
        local column = (index - 1) % columns
        local row = zo_floor((index - 1) / columns)
        local x = column * cellWidth
        local y = 32 + (row * rowHeight)

        local check = wm:CreateControl(nil, control, CT_LABEL)
        check:SetAnchor(TOPLEFT, control, TOPLEFT, x, y + 2)
        check:SetDimensions(24, 24)
        check:SetFont("ZoFontGameBold")
        check:SetColor(0.35, 1, 0.35, 1)
        check:SetText("âœ“")

        local name = wm:CreateControl(nil, control, CT_LABEL)
        name:SetAnchor(TOPLEFT, control, TOPLEFT, x + 25, y)
        name:SetDimensions(cellWidth - 30, 22)
        name:SetFont("ZoFontGameBold")
        name:SetColor(1, 1, 1, 0.95)
        name:SetText(raid.name)

        local detail = wm:CreateControl(nil, control, CT_LABEL)
        detail:SetAnchor(TOPLEFT, control, TOPLEFT, x + 25, y + 19)
        detail:SetDimensions(cellWidth - 30, 18)
        detail:SetFont("ZoFontGameSmall")
        detail:SetColor(0.78, 0.78, 0.78, 0.9)
        detail:SetText(raid.cases or "")
    end
end

local function ResetEncounterState()
    PBT.zmajaAddKills = 0
    PBT.zmajaSpawnStarted = false
    PBT.zmajaAddWindowMs = 0
    PBT.cloudrestInitMs = 0
    PBT.cloudrestPlus = 0
    PBT.cloudrestPortalGroup = 0
    PBT.cloudrestPortalActive = false
    PBT.cloudrestLastPortalTimerMs = 0
    PBT.cloudrestPullToken = (PBT.cloudrestPullToken or 0) + 1
    PBT.genericBossCandidates = {}
    ResetAsOlms()
    PBT.falgravnAirborne = false
    PBT.falgravnGroundToken = (PBT.falgravnGroundToken or 0) + 1
    PBT.falgravnBasementAddsKilled = 0
    PBT.hofAfterTriplets = false
    PBT.hofTripletsToken = (PBT.hofTripletsToken or 0) + 1
    PBT.hpThresholdState = {}
    StopNahvPortalStatus(false)
end

local function GetBossSeconds(normalizedName, data)
    local overrides = PBT.savedVars and PBT.savedVars.timerOverrides
    if overrides and tonumber(overrides[normalizedName]) then
        return tonumber(overrides[normalizedName])
    end

    return data.seconds
end

local function RegisterSettingsPanel()
    local LAM = LibAddonMenu2
    if not LAM or not PBT.savedVars then return end

    local panelData = {
        type = "panel",
        name = PBT.displayName,
        displayName = PBT.displayName,
        author = "TeamFky - EyrOn",
        version = PBT.version,
        slashCommand = "/pbtsettings",
        registerForRefresh = false,
        registerForDefaults = true,
    }

    local options = {
        {
            type = "header",
            name = "Team Shadows Manager",
        },
        {
            type = "description",
            text = "Version " .. tostring(PBT.version) .. "  -  Auteur: TeamFky - EyrOn",
            width = "full",
        },
        {
            type = "header",
            name = "Reglages generiques",
        },
                {
                    type = "checkbox",
                    name = "Addon active",
                    getFunc = function() return PBT.savedVars.enabled end,
                    setFunc = function(value) PBT.savedVars.enabled = value end,
                    default = PBT.defaults.enabled,
                },
                {
                    type = "checkbox",
                    name = "Fenetre deverrouillee",
                    getFunc = function() return PBT.savedVars.unlocked end,
                    setFunc = function(value) PBT.UI:SetUnlocked(value) end,
                    default = PBT.defaults.unlocked,
                },
                {
                    type = "checkbox",
                    name = "Bouton menu logo",
                    tooltip = "Affiche ton logo à l'écran. Clic gauche : ouvre la fenêtre indépendante Team Shadows Manager.",
                    getFunc = function() return PBT.savedVars.menuButtonEnabled ~= false end,
                    setFunc = function(value)
                        PBT.savedVars.menuButtonEnabled = value
                        PBT.UI:ApplyMenuButtonSettings()
                    end,
                    default = PBT.defaults.menuButtonEnabled,
                },
                {
                    type = "slider",
                    name = "Taille bouton logo",
                    tooltip = "Taille du bouton logo visible à l'écran.",
                    min = 28,
                    max = 96,
                    step = 2,
                    getFunc = function() return PBT.savedVars.menuButtonSize end,
                    setFunc = function(value)
                        PBT.savedVars.menuButtonSize = value
                        PBT.UI:ApplyMenuButtonSettings()
                    end,
                    default = PBT.defaults.menuButtonSize,
                },
                {
                    type = "header",
                    name = "Sons",
                },
                {
                    type = "checkbox",
                    name = "Sons du compte à rebours",
                    getFunc = function() return PBT.savedVars.soundEnabled end,
                    setFunc = function(value) PBT.savedVars.soundEnabled = value end,
                    default = PBT.defaults.soundEnabled,
                },
                {
                    type = "checkbox",
                    name = "ON / OFF timers boss",
                    tooltip = "Active uniquement les timers automatiques des boss qui apparaissent, reviennent après une invulnérabilité ou ont une narration longue.",
                    getFunc = function() return PBT.savedVars.bossSpawnTimers end,
                    setFunc = function(value)
                        PBT.savedVars.bossSpawnTimers = value
                        PBT.savedVars.useSamuraiTimers = value
                    end,
                    default = PBT.defaults.bossSpawnTimers,
                },
                {
                    type = "header",
                    name = "Décompte personnalisé",
                },
                {
                    type = "checkbox",
                    name = "ON / OFF décompte personnalisé",
                    tooltip = "Active le décompte groupe lancé par raccourci ou par /pbtpull.",
                    getFunc = function() return PBT.savedVars.groupCountdownEnabled end,
                    setFunc = function(value) PBT.savedVars.groupCountdownEnabled = value end,
                    default = PBT.defaults.groupCountdownEnabled,
                },
                {
                    type = "slider",
                    name = "Décompte groupe",
                    tooltip = "Durée envoyée à tout le groupe par le raid lead.",
                    min = 0,
                    max = 20,
                    step = 1,
                    getFunc = function() return PBT.savedVars.groupCountdownSeconds end,
                    setFunc = function(value) PBT.savedVars.groupCountdownSeconds = value end,
                    default = PBT.defaults.groupCountdownSeconds,
                },
                {
                    type = "slider",
                    name = "Mon délai",
                    tooltip = "Corrige uniquement ton affichage local. -2 affiche ton GO 2 secondes plus tôt. +2 affiche ton GO 2 secondes plus tard.",
                    min = -10,
                    max = 10,
                    step = 0.1,
                    getFunc = function() return PBT.savedVars.groupCountdownDpsDelay end,
                    setFunc = function(value) PBT.savedVars.groupCountdownDpsDelay = value end,
                    default = PBT.defaults.groupCountdownDpsDelay,
                },
                {
                    type = "description",
                    text = "Le décompte groupe est commun. Mon délai ne modifie que ton écran.",
                },
                {
                    type = "header",
                    name = "Diffusion groupe",
                },
                {
                    type = "checkbox",
                    name = "Diffuser le décompte au groupe",
                    tooltip = "Envoie le décompte aux joueurs qui utilisent Team Shadows Manager.",
                    getFunc = function() return PBT.savedVars.groupCountdownBroadcast end,
                    setFunc = function(value) PBT.savedVars.groupCountdownBroadcast = value end,
                    default = PBT.defaults.groupCountdownBroadcast,
                },
                {
                    type = "header",
                    name = "Markers",
                },
                {
                    type = "checkbox",
                    name = "Recevoir les markers",
                    tooltip = "Désactivé pour le moment : les markers se partagent par Exporter / Importer pour éviter les pings instables.",
                    getFunc = function() return PBT.savedVars.groupRendezvousReceive ~= false end,
                    setFunc = function(value)
                        PBT.savedVars.groupRendezvousReceive = value
                        RefreshLibTeamShadowsOptions()
                    end,
                    default = PBT.defaults.groupRendezvousReceive,
                },
                {
                    type = "dropdown",
                    name = "Icone marker",
                    tooltip = "Texture Team Shadows affichee au sol par le marker.",
                    choices = { "Carre rouge", "Carre bleu", "Carre jaune", "Carre vert", "Carre orange", "Carre rose", "Marker bleu clair", "Carre MT", "Carre OT", "Fleche", "Fleche verte", "Shadow", "Buche", "Fish", "Hyxtra", "Lexi", "Og", "Ogu", "Ray-me", "Ronce", "Selegnar", "Sla-anesh", "Tim" },
                    choicesValues = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23 },
                    getFunc = function() return PBT.savedVars.groupBeaconTextureId end,
                    setFunc = function(value)
                        PBT.savedVars.groupBeaconTextureId = value
                    end,
                    default = PBT.defaults.groupBeaconTextureId,
                },
                {
                    type = "dropdown",
                    name = "Texte marker",
                    tooltip = "Auto numerote les markers de 1 a 10, ou force un role precis.",
                    choices = { "Auto 1-10", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "H1", "H2", "MT", "OT" },
                    choicesValues = { "auto", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "H1", "H2", "MT", "OT" },
                    getFunc = function() return PBT.savedVars.groupBeaconLabel end,
                    setFunc = function(value)
                        PBT.savedVars.groupBeaconLabel = value
                    end,
                    default = PBT.defaults.groupBeaconLabel,
                },
                {
                    type = "slider",
                    name = "Taille marker",
                    tooltip = "Taille du carre visible dans le monde.",
                    min = 24,
                    max = 160,
                    step = 4,
                    getFunc = function() return PBT.savedVars.groupBeaconSize end,
                    setFunc = function(value)
                        PBT.savedVars.groupBeaconSize = value
                        RefreshLibTeamShadowsOptions()
                    end,
                    default = PBT.defaults.groupBeaconSize,
                },
                {
                    type = "slider",
                    name = "Duree marker",
                    tooltip = "Temps d'affichage du marker.",
                    min = 1,
                    max = 60,
                    step = 1,
                    getFunc = function() return PBT.savedVars.groupBeaconDuration end,
                    setFunc = function(value)
                        PBT.savedVars.groupBeaconDuration = value
                        RefreshLibTeamShadowsOptions()
                    end,
                    default = PBT.defaults.groupBeaconDuration,
                },
                {
                    type = "button",
                    name = "Placer marker vise",
                    tooltip = "Vise le sol avec le reticule puis valide pour enregistrer le marker.",
                    func = PBT.SendGroupRendezvous,
                    width = "full",
                },
        {
            type = "header",
            name = "Annonce visuelle",
        },
                {
                    type = "description",
                    text = "Reglages de l'affichage de l'annonce au centre de l'ecran.",
                },
                {
                    type = "button",
                    name = "Test annonce 3 sec",
                    tooltip = "Affiche une demo 3, 2, 1, GO avec les couleurs actuelles.",
                    func = TestVisualAnnouncement,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Taille UI",
                    width = "full",
                    min = 50,
                    max = 250,
                    step = 5,
                    getFunc = function() return zo_round((PBT.savedVars.scale or 1) * 100) end,
                    setFunc = function(value)
                        PBT.SetScale(value / 100)
                        RefreshSettingsPreviewControls()
                    end,
                    default = PBT.defaults.scale * 100,
                },
                {
                    type = "description",
                    text = "Apercu: PULL 3 / GO",
                    width = "full",
                },
                {
                    type = "description",
                    text = "Regle l'intensite du rouge et du vert du chiffre du timer.",
                },
                {
                    type = "slider",
                    name = "Intensite rouge",
                    width = "full",
                    min = 0,
                    max = 100,
                    step = 1,
                    getFunc = function() return zo_round((PBT.savedVars.color.r or 1) * 100) end,
                    setFunc = function(value)
                        local color = PBT.savedVars.color
                        PBT.SetColor(value / 100, color.g, color.b)
                        RefreshSettingsPreviewControls()
                    end,
                    default = PBT.defaults.color.r * 100,
                },
                {
                    type = "description",
                    text = "Apercu: PULL 3 / GO",
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Intensite vert",
                    width = "full",
                    min = 0,
                    max = 100,
                    step = 1,
                    getFunc = function() return zo_round((PBT.savedVars.color.g or 0) * 100) end,
                    setFunc = function(value)
                        local color = PBT.savedVars.color
                        PBT.SetColor(color.r, value / 100, color.b)
                        RefreshSettingsPreviewControls()
                    end,
                    default = PBT.defaults.color.g * 100,
                },
                {
                    type = "description",
                    text = "Apercu: PULL 3 / GO",
                    width = "full",
                },
                {
                    type = "button",
                    name = "Remettre rouge par defaut",
                    func = function()
                        PBT.SetColor(PBT.defaults.color.r, PBT.defaults.color.g, PBT.defaults.color.b)
                        RefreshSettingsPreviewControls()
                    end,
                    width = "full",
                },
        {
            type = "header",
            name = "Mannequin",
        },
                {
                    type = "slider",
                    name = "Timer mannequin",
                    tooltip = "Duree du countdown lance apres une sortie de combat contre un mannequin.",
                    min = 1,
                    max = 60,
                    step = 1,
                    getFunc = function() return PBT.savedVars.practiceSeconds end,
                    setFunc = function(value) PBT.savedVars.practiceSeconds = value end,
                    default = PBT.defaults.practiceSeconds,
                },
                {
                    type = "checkbox",
                    name = "Auto timer apres reset mannequin",
                    tooltip = "Lance le timer mannequin a la sortie de combat si le combat precedent etait contre un mannequin.",
                    getFunc = function() return PBT.savedVars.autoPracticeOnDummyReset end,
                    setFunc = function(value) PBT.savedVars.autoPracticeOnDummyReset = value end,
                    default = PBT.defaults.autoPracticeOnDummyReset,
                },
        {
            type = "header",
            name = "Timers prebuff boss",
        },
        {
            type = "description",
            text = "|c55FF55Pris en compte|r\nCloudrest : Z'Maja pull apres Shadow Realm\nHalls of Fabrication : Hunter-Killer Fabricants / Pinnacle Factotum / Triplets\nAsylum Sanctorium : Saint Olms / 4e atterrissage apres jumps\nMaw of Lorkhaj : Zhaj'hassa / Rakkhat\nAetherian Archive : Varlariel\nSunspire : Lokkestiiz / Yolnahkriin / Nahviintaas / portail HP Nahviintaas\nKyne's Aegis : Lord Falgravn / retour apres mort des 3 adds sous-sol\nDreadsail Reef : Taleria / annonce execute uniquement\nSanity's Edge : Exarchanic Yaseyla / phases HP\nInfinite Archive : timers manuels uniquement, pops aleatoires non forces\nMannequin : reset/sortie combat apres mannequin actif",
            width = "full",
        },
    }

    PBT.settingsPanel = LAM:RegisterAddonPanel("TeamShadowsManagerOptions", panelData)
    LAM:RegisterOptionControls("TeamShadowsManagerOptions", options)
end

local function RegisterSlashCommands()
    SLASH_COMMANDS["/pbtunlock"] = ToggleUnlock
    SLASH_COMMANDS["/pbtscale"] = HandleScale
    SLASH_COMMANDS["/pbtcolor"] = HandleColor
    SLASH_COMMANDS["/pbtia"] = HandleInfiniteArchive
    SLASH_COMMANDS["/pbtboss"] = PrintBossUnits
    SLASH_COMMANDS["/pbtzone"] = PrintZoneName
    SLASH_COMMANDS["/pbtpractice"] = HandlePractice
    SLASH_COMMANDS["/pbtpracticetime"] = HandlePracticeTime
    SLASH_COMMANDS["/pbtpull"] = HandleGroupCountdown
    SLASH_COMMANDS["/pbttestpull"] = HandleGroupCountdownTest
    SLASH_COMMANDS["/pbtbutton"] = ResetMenuButton
    SLASH_COMMANDS["/pbtmarker"] = PBT.PlaceMarkerFromReticle
    SLASH_COMMANDS["/pbtfanal"] = PBT.PlaceMarkerFromReticle
    SLASH_COMMANDS["/pbtnarration"] = ToggleNarrationDebug
    SLASH_COMMANDS["/pbtnarrationlog"] = PrintNarrationLog
    SLASH_COMMANDS["/shadows"] = PBT.OpenManagerWindow
end

local function RegisterEvents()
    EM:RegisterForEvent(ADDON_NAME .. "Zone", EVENT_PLAYER_ACTIVATED, function()
        RefreshPlayerZone()
        zo_callLater(function()
            if PBT.RefreshSavedMarkers then
                PBT.RefreshSavedMarkers()
            end
        end, 1200)
    end)
    EM:RegisterForEvent(ADDON_NAME, EVENT_BOSSES_CHANGED, OnBossesChanged)
    EM:RegisterForEvent(ADDON_NAME, EVENT_POWER_UPDATE, OnPowerUpdate)
    EM:RegisterForEvent(ADDON_NAME, EVENT_EFFECT_CHANGED, OnEffectChanged)
    EM:RegisterForEvent(ADDON_NAME, EVENT_COMBAT_EVENT, OnCombatEvent)
    EM:RegisterForEvent(ADDON_NAME, EVENT_CHAT_MESSAGE_CHANNEL, OnMonsterChat)
    EM:RegisterForEvent(ADDON_NAME .. "ReticleBoss", EVENT_RETICLE_TARGET_CHANGED, function()
        zo_callLater(ScanReticleBoss, 300)
    end)
    EM:RegisterForEvent(ADDON_NAME .. "CombatState", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
        if not inCombat then
            if PBT.dummyWasInCombat then
                StartPracticeFromDummyReset()
            end
            ResetEncounterState()
        end
    end)

    if EM.AddFilterForEvent then
        EM:AddFilterForEvent(ADDON_NAME, EVENT_COMBAT_EVENT, REGISTER_FILTER_IS_ERROR, false)
    end
end

local function OnAddonLoaded(_, addonName)
    if not IsThisAddonLoadedName(addonName) then return end

    EM:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    -- SavedVariables are server-dependent (NA / EU / PTS) so profiles no
    -- longer overwrite each other. One-time migration copies the old
    -- shared "Default" profile into the current server's profile.
    local worldName = GetWorldName()
    if worldName == nil or worldName == "" then worldName = "Default" end
    local rawSavedVars = _G[PBT.savedVariableName]
    if rawSavedVars and rawSavedVars["Default"] and worldName ~= "Default" and rawSavedVars[worldName] == nil then
        rawSavedVars[worldName] = ZO_DeepTableCopy(rawSavedVars["Default"])
    end

    PBT.savedVars = ZO_SavedVars:NewAccountWide(
        PBT.savedVariableName,
        PBT.savedVariableVersion,
        nil,
        PBT.defaults,
        worldName
    )

    PBT.savedVars.timerOverrides = PBT.savedVars.timerOverrides or {}
    PBT.savedVars.customAliases = PBT.savedVars.customAliases or {}
    PBT.savedVars.goColor = PBT.savedVars.goColor or PBT.defaults.goColor
    PBT.savedVars.practiceSeconds = tonumber(PBT.savedVars.practiceSeconds) or PBT.defaults.practiceSeconds
    if PBT.savedVars.practiceLogCalibrationApplied ~= true then
        if PBT.savedVars.practiceSeconds == 6 then
            PBT.savedVars.practiceSeconds = PBT.defaults.practiceSeconds
        end
        PBT.savedVars.practiceLogCalibrationApplied = true
    end
    if PBT.savedVars.bossSpawnTimers == nil then
        PBT.savedVars.bossSpawnTimers = PBT.defaults.bossSpawnTimers
    end
    if PBT.savedVars.groupCountdownEnabled == nil then
        PBT.savedVars.groupCountdownEnabled = PBT.defaults.groupCountdownEnabled
    end
    if PBT.savedVars.menuButtonEnabled == nil then
        PBT.savedVars.menuButtonEnabled = PBT.defaults.menuButtonEnabled
    end
    PBT.savedVars.menuButtonSize = tonumber(PBT.savedVars.menuButtonSize) or PBT.defaults.menuButtonSize
    PBT.savedVars.menuButtonSize = zo_clamp(PBT.savedVars.menuButtonSize, 28, 96)
    PBT.savedVars.menuButtonX = tonumber(PBT.savedVars.menuButtonX) or PBT.defaults.menuButtonX
    PBT.savedVars.menuButtonY = tonumber(PBT.savedVars.menuButtonY) or PBT.defaults.menuButtonY
    PBT.savedVars.managerWindowX = tonumber(PBT.savedVars.managerWindowX) or PBT.defaults.managerWindowX
    PBT.savedVars.managerWindowY = tonumber(PBT.savedVars.managerWindowY) or PBT.defaults.managerWindowY
    PBT.savedVars.groupCountdownSeconds = tonumber(PBT.savedVars.groupCountdownSeconds) or PBT.defaults.groupCountdownSeconds
    PBT.savedVars.groupCountdownSeconds = zo_clamp(PBT.savedVars.groupCountdownSeconds, 0, 20)
    PBT.savedVars.groupCountdownDpsDelay = tonumber(PBT.savedVars.groupCountdownDpsDelay) or PBT.defaults.groupCountdownDpsDelay
    PBT.savedVars.groupCountdownDpsDelay = zo_clamp(PBT.savedVars.groupCountdownDpsDelay, -10, 10)
    if PBT.savedVars.groupCountdownBroadcast == nil then
        PBT.savedVars.groupCountdownBroadcast = PBT.defaults.groupCountdownBroadcast
    end
    if PBT.savedVars.groupRendezvousReceive == nil then
        PBT.savedVars.groupRendezvousReceive = PBT.defaults.groupRendezvousReceive
    end
    PBT.savedVars.groupBeaconSavedMarkers = PBT.savedVars.groupBeaconSavedMarkers or {}
    PBT.savedVars.groupBeaconColor = PBT.savedVars.groupBeaconColor or PBT.defaults.groupBeaconColor
    PBT.savedVars.groupBeaconTextureId = zo_clamp(tonumber(PBT.savedVars.groupBeaconTextureId) or PBT.defaults.groupBeaconTextureId, 1, 23)
    PBT.savedVars.groupBeaconColor.r = zo_clamp(tonumber(PBT.savedVars.groupBeaconColor.r) or PBT.defaults.groupBeaconColor.r, 0, 1)
    PBT.savedVars.groupBeaconColor.g = zo_clamp(tonumber(PBT.savedVars.groupBeaconColor.g) or PBT.defaults.groupBeaconColor.g, 0, 1)
    PBT.savedVars.groupBeaconColor.b = zo_clamp(tonumber(PBT.savedVars.groupBeaconColor.b) or PBT.defaults.groupBeaconColor.b, 0, 1)
    if not PBT.beaconLabelIds[PBT.savedVars.groupBeaconLabel or ""] and PBT.savedVars.groupBeaconLabel ~= "auto" then
        PBT.savedVars.groupBeaconLabel = PBT.defaults.groupBeaconLabel
    end
    PBT.savedVars.groupBeaconCustomLabel = tostring(PBT.savedVars.groupBeaconCustomLabel or "")
    PBT.savedVars.groupBeaconNextNumber = zo_clamp(tonumber(PBT.savedVars.groupBeaconNextNumber) or PBT.defaults.groupBeaconNextNumber, 1, 10)
    PBT.savedVars.groupBeaconMarkerSets = PBT.savedVars.groupBeaconMarkerSets or {}
    PBT.savedVars.groupBeaconMarkerSetSlot = zo_clamp(tonumber(PBT.savedVars.groupBeaconMarkerSetSlot) or 1, 1, 3)
    PBT.savedVars.groupBeaconMarkerSetName = tostring(PBT.savedVars.groupBeaconMarkerSetName or "")
    if PBT.savedVars.groupBeaconDisplayMode ~= "filter" then
        PBT.savedVars.groupBeaconDisplayMode = "all"
    end
    if not PBT.beaconLabelIds[PBT.savedVars.groupBeaconDisplayLabel or ""] and PBT.savedVars.groupBeaconDisplayLabel ~= "all" then
        PBT.savedVars.groupBeaconDisplayLabel = "all"
    end
    PBT.savedVars.groupBeaconSize = zo_clamp(tonumber(PBT.savedVars.groupBeaconSize) or PBT.defaults.groupBeaconSize, 24, 160)
    PBT.savedVars.groupBeaconHeight = zo_clamp(tonumber(PBT.savedVars.groupBeaconHeight) or PBT.defaults.groupBeaconHeight, -40, 80)
    if PBT.savedVars.groupBeaconHeightDefaultZeroApplied ~= true then
        PBT.savedVars.groupBeaconHeight = 0
        for _, marker in ipairs(PBT.savedVars.groupBeaconSavedMarkers or {}) do
            if tonumber(marker.heightOffset) == 4.5 then
                marker.heightOffset = 0
            end
        end
        PBT.savedVars.groupBeaconHeightDefaultZeroApplied = true
    end
    if PBT.savedVars.groupBeaconHeightCalibrationApplied ~= true then
        PBT.savedVars.groupBeaconHeight = PBT.defaults.groupBeaconHeight
        for _, marker in ipairs(PBT.savedVars.groupBeaconSavedMarkers or {}) do
            marker.heightOffset = PBT.defaults.groupBeaconHeight
        end
        PBT.savedVars.groupBeaconHeightCalibrationApplied = true
    end
    PBT.savedVars.groupBeaconDuration = zo_clamp(tonumber(PBT.savedVars.groupBeaconDuration) or PBT.defaults.groupBeaconDuration, 1, 60)
    if PBT.savedVars.autoPracticeOnDummyReset == nil then
        PBT.savedVars.autoPracticeOnDummyReset = PBT.defaults.autoPracticeOnDummyReset
    end
    if PBT.savedVars.bossNameTimers == nil then
        PBT.savedVars.bossNameTimers = PBT.defaults.bossNameTimers
    end
    if PBT.savedVars.bossUnitDetection == nil then
        PBT.savedVars.bossUnitDetection = PBT.defaults.bossUnitDetection
    end
    if PBT.savedVars.genericCinematicTimers == nil then
        PBT.savedVars.genericCinematicTimers = PBT.defaults.genericCinematicTimers
    end
    if PBT.savedVars.worldBossTimers == nil then
        PBT.savedVars.worldBossTimers = PBT.defaults.worldBossTimers
    end
    if PBT.savedVars.asOlmsFourthLanding == nil then
        PBT.savedVars.asOlmsFourthLanding = PBT.defaults.asOlmsFourthLanding
    end
    PBT.savedVars.asOlmsLandingSeconds = tonumber(PBT.savedVars.asOlmsLandingSeconds) or PBT.defaults.asOlmsLandingSeconds
    if PBT.savedVars.asOlmsLogCalibrationApplied ~= true then
        if PBT.savedVars.asOlmsLandingSeconds == 30 then
            PBT.savedVars.asOlmsLandingSeconds = PBT.defaults.asOlmsLandingSeconds
        end
        PBT.savedVars.asOlmsLogCalibrationApplied = true
    end
    if PBT.savedVars.disableLateBossUnitTriggersApplied ~= true then
        PBT.savedVars.bossUnitDetection = false
        PBT.savedVars.genericCinematicTimers = false
        PBT.savedVars.worldBossTimers = false
        PBT.savedVars.disableLateBossUnitTriggersApplied = true
    end
    PBT.savedVars.genericCinematicSeconds = tonumber(PBT.savedVars.genericCinematicSeconds) or PBT.defaults.genericCinematicSeconds
    if PBT.savedVars.useSamuraiTimers == nil then
        PBT.savedVars.useSamuraiTimers = PBT.defaults.useSamuraiTimers
    end
    PBT.savedVars.useSamuraiTimers = PBT.savedVars.bossSpawnTimers ~= false
    if PBT.savedVars.showMechanicTimers == nil then
        PBT.savedVars.showMechanicTimers = PBT.defaults.showMechanicTimers
    end
    if PBT.savedVars.nahvPortalHpWarning == nil then
        PBT.savedVars.nahvPortalHpWarning = PBT.defaults.nahvPortalHpWarning
    end
    if PBT.savedVars.narrationDebug == nil then
        PBT.savedVars.narrationDebug = false
    end

    if PBT.savedVars.hofSunspireCalibrationResetV2 ~= true then
        local overrides = PBT.savedVars.timerOverrides or {}
        overrides["pinnacle factotum"] = nil
        overrides["reclaimer reducer reactor"] = nil
        overrides["lokkestiiz"] = nil
        overrides["yolnahkriin"] = nil
        overrides["nahviintaas"] = nil
        PBT.savedVars.bossNameTimers = false
        PBT.savedVars.bossUnitDetection = false
        PBT.savedVars.genericCinematicTimers = false
        PBT.savedVars.worldBossTimers = false
        PBT.savedVars.hofSunspireCalibrationResetV2 = true
    end

    if PBT.savedVars.curatedMechanicTimersV3 ~= true then
        local overrides = PBT.savedVars.timerOverrides or {}
        overrides["hunter-killer fabricants"] = nil
        overrides["pinnacle factotum"] = nil
        overrides["reclaimer reducer reactor"] = nil
        overrides["zhaj'hassa the forgotten"] = nil
        overrides["rakkhat"] = nil
        overrides["nahviintaas"] = nil
        PBT.savedVars.bossNameTimers = false
        PBT.savedVars.bossUnitDetection = false
        PBT.savedVars.genericCinematicTimers = false
        PBT.savedVars.worldBossTimers = false
        PBT.savedVars.curatedMechanicTimersV3 = true
    end

    PBT.BuildBossLookup()
    PBT.UI:Initialize()
    PBT.UI:ApplySettings()
    RefreshPlayerZone()
    RegisterSlashCommands()
    RegisterSettingsPanel()
    RegisterEvents()
    RefreshLibTeamShadowsOptions()
    RegisterLibTeamShadowsHandlers()
    zo_callLater(function()
        if PBT.RefreshSavedMarkers then
            PBT.RefreshSavedMarkers()
        end
    end, 1600)
    zo_callLater(function()
        if PBT.UI and PBT.UI.ShowMarkerReadyAlert then
            PBT.UI:ShowMarkerReadyAlert()
            zo_callLater(function()
                if PBT.UI and not PBT.isRunning and not (PBT.savedVars and PBT.savedVars.unlocked) then
                    PBT.UI:Hide()
                end
            end, 1800)
        end
    end, 2200)

    if PBT.savedVars.bossUnitDetection then
        zo_callLater(function()
            PBT.QueueScan(100)
        end, 1200)
    end
end

EM:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)










