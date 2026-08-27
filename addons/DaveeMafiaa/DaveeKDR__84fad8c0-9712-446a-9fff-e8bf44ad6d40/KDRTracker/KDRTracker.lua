KDRTracker = KDRTracker or {}
local KDR = KDRTracker

KDR.name = "KDRTracker"
KDR.displayName = "KDR Tracker"
KDR.version = "1.6.0"

local defaults = {
    sessionKills = 0,
    sessionDeaths = 0,
    currentStreak = 0,
    bestStreak = 0,
    lifetimeKills = 0,
    lifetimeDeaths = 0,
    lifetimeBestStreak = 0,
    hudVisible = true,
    hudLocked = true,
    hudScale = 1.00,
    textSize = 2,
    hudAlpha = 0.00,
    hudX = -55,
    hudY = 105,
    hudAnchor = TOPRIGHT,
    killsColor = 2,
    deathsColor = 3,
    ratioColor = 4,
    streakColor = 5,
    announcements = true,
    onlyPvP = true,
    killsRGBA = { 0.49, 1.00, 0.45, 1.00 },
    deathsRGBA = { 1.00, 0.36, 0.38, 1.00 },
    ratioRGBA = { 0.33, 0.84, 1.00, 1.00 },
    streakRGBA = { 1.00, 0.83, 0.35, 1.00 },
    uiVersion = 4,
}

KDR.palette = {
    { name = "White",  r = 1.00, g = 1.00, b = 1.00 },
    { name = "Green",  r = 0.49, g = 1.00, b = 0.45 },
    { name = "Red",    r = 1.00, g = 0.36, b = 0.38 },
    { name = "Blue",   r = 0.33, g = 0.84, b = 1.00 },
    { name = "Gold",   r = 1.00, g = 0.83, b = 0.35 },
    { name = "Purple", r = 0.72, g = 0.47, b = 1.00 },
    { name = "Orange", r = 1.00, g = 0.55, b = 0.20 },
    { name = "Pink",   r = 1.00, g = 0.42, b = 0.76 },
    { name = "Cyan",   r = 0.25, g = 1.00, b = 0.95 },
}

KDR.fontPresets = {
    { key = "ZoFontGamepadBold20", value = "ZoFontGamepadBold27", title = "Small" },
    { key = "ZoFontGamepadBold27", value = "ZoFontGamepadBold34", title = "Medium" },
    { key = "ZoFontGamepadBold34", value = "ZoFontGamepadBold48", title = "Large" },
}

local function SafeCall(fn, ...)
    if type(fn) == "function" then
        local ok, result = pcall(fn, ...)
        if ok then return result end
    end
    return nil
end

function KDR:IsPvPContext()
    local inBG = SafeCall(IsUnitInBattleground, "player")
    if inBG == true then return true end
    local inAvA = SafeCall(IsPlayerInAvAWorld)
    if inAvA == true then return true end
    local zoneIndex = SafeCall(GetUnitZoneIndex, "player")
    if zoneIndex and type(GetZoneNameByIndex) == "function" then
        local zoneName = string.lower(GetZoneNameByIndex(zoneIndex) or "")
        if string.find(zoneName, "cyrodiil", 1, true)
            or string.find(zoneName, "imperial city", 1, true)
            or string.find(zoneName, "battleground", 1, true) then
            return true
        end
    end
    return false
end

function KDR:GetRatio(kills, deaths)
    if deaths <= 0 then
        if kills <= 0 then return "0.00" end
        return string.format("%.2f", kills)
    end
    return string.format("%.2f", kills / deaths)
end

function KDR:GetPalette(index)
    return self.palette[zo_clamp(index or 1, 1, #self.palette)]
end

function KDR:ApplyColor(label, index)
    if not label then return end
    local c = self:GetPalette(index)
    label:SetColor(c.r, c.g, c.b, 1)
end

function KDR:ApplyFonts()
    local preset = self.fontPresets[zo_clamp(self.sv.textSize or 2, 1, #self.fontPresets)]
    if KDRTrackerHUDSession then KDRTrackerHUDSession:SetFont(preset.key) end
    local keys = { KDRTrackerHUDKillsKey, KDRTrackerHUDDeathsKey, KDRTrackerHUDRatioKey, KDRTrackerHUDStreakKey }
    local vals = { KDRTrackerHUDKillsValue, KDRTrackerHUDDeathsValue, KDRTrackerHUDRatioValue, KDRTrackerHUDStreakValue }
    for _, control in ipairs(keys) do if control then control:SetFont(preset.key) end end
    for _, control in ipairs(vals) do if control then control:SetFont(preset.value) end end
end

function KDR:ApplyRGBA(label, rgba)
    if not label or not rgba then return end
    label:SetColor(rgba[1] or 1, rgba[2] or 1, rgba[3] or 1, rgba[4] or 1)
end

function KDR:ApplyHUDColors()
    self:ApplyRGBA(KDRTrackerHUDKillsKey, self.sv.killsRGBA)
    self:ApplyRGBA(KDRTrackerHUDKillsValue, self.sv.killsRGBA)
    self:ApplyRGBA(KDRTrackerHUDDeathsKey, self.sv.deathsRGBA)
    self:ApplyRGBA(KDRTrackerHUDDeathsValue, self.sv.deathsRGBA)
    self:ApplyRGBA(KDRTrackerHUDRatioKey, self.sv.ratioRGBA)
    self:ApplyRGBA(KDRTrackerHUDRatioValue, self.sv.ratioRGBA)
    self:ApplyRGBA(KDRTrackerHUDStreakKey, self.sv.streakRGBA)
    self:ApplyRGBA(KDRTrackerHUDStreakValue, self.sv.streakRGBA)
end

function KDR:UpdateHUD()
    if not KDRTrackerHUD then return end
    local sv = self.sv
    KDRTrackerHUD:SetHidden(not sv.hudVisible)
    KDRTrackerHUD:SetScale(sv.hudScale)
    if KDRTrackerHUDBG then
        KDRTrackerHUDBG:SetCenterColor(0, 0, 0, sv.hudAlpha)
        KDRTrackerHUDBG:SetEdgeColor(0, 0, 0, math.min(1, sv.hudAlpha * 1.5))
    end
    self:ApplyFonts()
    self:ApplyHUDColors()
    KDRTrackerHUDKillsValue:SetText(tostring(sv.sessionKills))
    KDRTrackerHUDDeathsValue:SetText(tostring(sv.sessionDeaths))
    KDRTrackerHUDRatioValue:SetText(self:GetRatio(sv.sessionKills, sv.sessionDeaths))
    KDRTrackerHUDStreakValue:SetText(tostring(sv.currentStreak))
    KDRTrackerHUD:SetMouseEnabled(not sv.hudLocked)
    KDRTrackerHUD:SetMovable(not sv.hudLocked)
end

function KDR:RestorePosition()
    if not KDRTrackerHUD then return end
    local sv = self.sv
    KDRTrackerHUD:ClearAnchors()
    local anchor = sv.hudAnchor or TOPRIGHT
    KDRTrackerHUD:SetAnchor(anchor, GuiRoot, anchor, sv.hudX or -55, sv.hudY or 105)
end

function KDR:MoveHUD(dx, dy)
    self.sv.hudAnchor = TOPRIGHT
    self.sv.hudX = (self.sv.hudX or -55) + dx
    self.sv.hudY = (self.sv.hudY or 105) + dy
    self:RestorePosition()
    self:RefreshSettingsStatus()
end

function KDR:ShowAnnouncement(text, r, g, b)
    if not self.sv.announcements or not KDRTrackerAnnouncement or not KDRTrackerAnnouncementText then return end
    self.announcementToken = (self.announcementToken or 0) + 1
    local token = self.announcementToken
    KDRTrackerAnnouncementText:SetText(text)
    KDRTrackerAnnouncementText:SetColor(r or 1, g or 1, b or 1, 1)
    KDRTrackerAnnouncement:SetHidden(false)
    if zo_callLater then
        zo_callLater(function()
            if KDRTracker and KDRTracker.announcementToken == token and KDRTrackerAnnouncement then
                KDRTrackerAnnouncement:SetHidden(true)
            end
        end, 1500)
    end
end

function KDR:AddKill()
    local sv = self.sv
    sv.sessionKills = sv.sessionKills + 1
    sv.lifetimeKills = sv.lifetimeKills + 1
    sv.currentStreak = sv.currentStreak + 1
    if sv.currentStreak > sv.bestStreak then sv.bestStreak = sv.currentStreak end
    if sv.currentStreak > sv.lifetimeBestStreak then sv.lifetimeBestStreak = sv.currentStreak end
    self:UpdateHUD()
    local c = self:GetPalette(sv.killsColor)
    self:ShowAnnouncement(string.format("KILL  •  %d STREAK", sv.currentStreak), c.r, c.g, c.b)
end

function KDR:AddDeath()
    local sv = self.sv
    sv.sessionDeaths = sv.sessionDeaths + 1
    sv.lifetimeDeaths = sv.lifetimeDeaths + 1
    local endedStreak = sv.currentStreak
    sv.currentStreak = 0
    self:UpdateHUD()
    local c = self:GetPalette(sv.deathsColor)
    if endedStreak > 1 then
        self:ShowAnnouncement(string.format("DEATH  •  %d STREAK ENDED", endedStreak), c.r, c.g, c.b)
    else
        self:ShowAnnouncement("DEATH", c.r, c.g, c.b)
    end
end

function KDR:ResetSession()
    local sv = self.sv
    sv.sessionKills = 0
    sv.sessionDeaths = 0
    sv.currentStreak = 0
    sv.bestStreak = 0
    self:UpdateHUD()
    self:RefreshSettingsStatus()
end

function KDR:ResetAllStats()
    local sv = self.sv
    sv.sessionKills = 0
    sv.sessionDeaths = 0
    sv.currentStreak = 0
    sv.bestStreak = 0
    sv.lifetimeKills = 0
    sv.lifetimeDeaths = 0
    sv.lifetimeBestStreak = 0
    self.recentPvPEvents = {}
    self.lastVerifiedPvPDeathMs = nil
    self:UpdateHUD()
    self:ShowAnnouncement("KDR STATS RESET", 1, 0.83, 0.35)
end


function KDR:IsPlayerKillingBlow(result, sourceName, sourceType, targetType)
    if result ~= ACTION_RESULT_KILLING_BLOW then return false end
    if COMBAT_UNIT_TYPE_PLAYER and targetType and targetType ~= COMBAT_UNIT_TYPE_PLAYER then return false end
    if sourceType and COMBAT_UNIT_TYPE_PLAYER and sourceType == COMBAT_UNIT_TYPE_PLAYER then return true end
    local playerName = GetUnitName("player") or ""
    local playerDisplayName = GetUnitDisplayName("player") or ""
    return sourceName == playerName or sourceName == playerDisplayName
end

function KDR:OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType,
                           sourceName, sourceType, targetName, targetType, hitValue, powerType,
                           damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if self.sv.onlyPvP and not self:IsPvPContext() then return end
    if not self:IsPlayerKillingBlow(result, sourceName, sourceType, targetType) then return end

    -- Combat events are only a fallback because they can miss PvP killing blows.
    -- Use the local player as killer and targetName as victim, with the same
    -- duplicate filter used by the native PvP events.
    local myDisplay = GetUnitDisplayName("player") or ""
    local myCharacter = GetUnitName("player") or ""
    self:RecordPvPKill(myDisplay, myCharacter, nil, targetName, "COMBAT_FALLBACK")
end

function KDR:OnPlayerDead()
    if self.sv.onlyPvP and not self:IsPvPContext() then return end

    local now = self:NowMs()
    if self.lastVerifiedPvPDeathMs and now > 0 and (now - self.lastVerifiedPvPDeathMs) < 5000 then
        return
    end

    self.lastVerifiedPvPDeathMs = now
    self:AddDeath()
end


function KDR:NormalizePlayerName(name)
    if not name or name == "" then return "" end
    if zo_strformat then
        return zo_strformat("<<1>>", name)
    end
    return string.gsub(name, "%^.*$", "")
end

function KDR:IsLocalPlayer(displayName, characterName)
    local myDisplay = GetUnitDisplayName("player") or ""
    local myCharacter = self:NormalizePlayerName(GetUnitName("player") or "")
    local eventCharacter = self:NormalizePlayerName(characterName or "")

    if displayName and displayName ~= "" and displayName == myDisplay then
        return true
    end
    if eventCharacter ~= "" and myCharacter ~= "" and eventCharacter == myCharacter then
        return true
    end
    return false
end

function KDR:NowMs()
    if GetFrameTimeMilliseconds then
        return GetFrameTimeMilliseconds()
    end
    if GetGameTimeMilliseconds then
        return GetGameTimeMilliseconds()
    end
    return 0
end

function KDR:IsDuplicatePvPEvent(kind, killerDisplay, victimDisplay, killerCharacter, victimCharacter)
    self.recentPvPEvents = self.recentPvPEvents or {}

    local killer = killerDisplay or self:NormalizePlayerName(killerCharacter or "")
    local victim = victimDisplay or self:NormalizePlayerName(victimCharacter or "")
    local key = tostring(kind) .. "|" .. tostring(killer) .. "|" .. tostring(victim)
    local now = self:NowMs()
    local previous = self.recentPvPEvents[key]

    -- EVENT_PVP_KILL_FEED_DEATH may fire twice for the same kill.
    -- Five seconds is short enough to allow legitimate later kills while
    -- suppressing the death/respawn duplicate notification.
    if previous and now > 0 and (now - previous) < 5000 then
        return true
    end

    self.recentPvPEvents[key] = now

    -- Periodically prune old keys.
    if now > 0 then
        for k, timestamp in pairs(self.recentPvPEvents) do
            if timestamp and (now - timestamp) > 15000 then
                self.recentPvPEvents[k] = nil
            end
        end
    end

    return false
end

function KDR:RecordPvPKill(killerDisplay, killerCharacter, victimDisplay, victimCharacter, source)
    if not self:IsLocalPlayer(killerDisplay, killerCharacter) then return end
    if self:IsLocalPlayer(victimDisplay, victimCharacter) then return end

    if self:IsDuplicatePvPEvent("KILL", killerDisplay, victimDisplay, killerCharacter, victimCharacter) then
        return
    end

    self:AddKill()
end

function KDR:RecordPvPDeath(killerDisplay, killerCharacter, victimDisplay, victimCharacter, source)
    if not self:IsLocalPlayer(victimDisplay, victimCharacter) then return end

    if self:IsDuplicatePvPEvent("DEATH", killerDisplay, victimDisplay, killerCharacter, victimCharacter) then
        return
    end

    self.lastVerifiedPvPDeathMs = self:NowMs()
    self:AddDeath()
end

-- Cyrodiil / Imperial City native kill-feed event.
-- Signature:
-- killLocation, killerDisplayName, killerCharacterName, killerAlliance, killerRank,
-- victimDisplayName, victimCharacterName, victimAlliance, victimRank
function KDR:OnPvPKillFeedDeath(eventCode, killLocation,
                                killerDisplayName, killerCharacterName, killerAlliance, killerRank,
                                victimDisplayName, victimCharacterName, victimAlliance, victimRank)
    self:RecordPvPKill(
        killerDisplayName, killerCharacterName,
        victimDisplayName, victimCharacterName,
        "PVP_KILL_FEED"
    )

    self:RecordPvPDeath(
        killerDisplayName, killerCharacterName,
        victimDisplayName, victimCharacterName,
        "PVP_KILL_FEED"
    )
end

-- Battleground server-authoritative kill event.
-- Signature:
-- killedCharacterName, killedDisplayName, killedAlliance,
-- killingCharacterName, killingDisplayName, killingAlliance, killType
function KDR:OnBattlegroundKill(eventCode,
                                killedCharacterName, killedDisplayName, killedAlliance,
                                killingCharacterName, killingDisplayName, killingAlliance,
                                battlegroundKillType)
    self:RecordPvPKill(
        killingDisplayName, killingCharacterName,
        killedDisplayName, killedCharacterName,
        "BATTLEGROUND"
    )

    self:RecordPvPDeath(
        killingDisplayName, killingCharacterName,
        killedDisplayName, killedCharacterName,
        "BATTLEGROUND"
    )
end

function KDR:TryRegisterAddonSettings()
    if self.settingsRegistered then return true end

    if LibHarvensAddonSettings and self.RegisterAddonSettings then
        local ok = pcall(function() self:RegisterAddonSettings() end)
        if ok and self.settingsRegistered then
            self.settingsMode = "addon"
            return true
        end
    end

    self.settingsMode = "fallback"
    return false
end

function KDR:OpenFallbackEditor()
    if self.OpenSettings then
        self:OpenSettings()
    else
        d("KDR Tracker: Settings library unavailable on this console build.")
    end
end

function KDR:Initialize()
    self.sv = ZO_SavedVars:NewAccountWide("KDRTrackerSavedVariables", 1, nil, defaults)
    if (self.sv.uiVersion or 1) < 3 then
        self.sv.textSize = self.sv.textSize or 2
        self.sv.killsColor = self.sv.killsColor or 2
        self.sv.deathsColor = self.sv.deathsColor or 3
        self.sv.ratioColor = self.sv.ratioColor or 4
        self.sv.streakColor = self.sv.streakColor or 5
        self.sv.uiVersion = 3
    end

    if (self.sv.uiVersion or 1) < 4 then
        self.sv.killsRGBA = self.sv.killsRGBA or { 0.49, 1.00, 0.45, 1.00 }
        self.sv.deathsRGBA = self.sv.deathsRGBA or { 1.00, 0.36, 0.38, 1.00 }
        self.sv.ratioRGBA = self.sv.ratioRGBA or { 0.33, 0.84, 1.00, 1.00 }
        self.sv.streakRGBA = self.sv.streakRGBA or { 1.00, 0.83, 0.35, 1.00 }
        self.sv.uiVersion = 4
    end

    self:RestorePosition()
    self:UpdateHUD()
    self:TryRegisterAddonSettings()
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_COMBAT_EVENT, function(...) self:OnCombatEvent(...) end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_DEAD, function() self:OnPlayerDead() end)

    if EVENT_PVP_KILL_FEED_DEATH then
        EVENT_MANAGER:RegisterForEvent(
            self.name .. "_PvPKillFeed",
            EVENT_PVP_KILL_FEED_DEATH,
            function(...) self:OnPvPKillFeedDeath(...) end
        )
    end

    if EVENT_BATTLEGROUND_KILL then
        EVENT_MANAGER:RegisterForEvent(
            self.name .. "_BattlegroundKill",
            EVENT_BATTLEGROUND_KILL,
            function(...) self:OnBattlegroundKill(...) end
        )
    end
    if REGISTER_FILTER_COMBAT_RESULT and ACTION_RESULT_KILLING_BLOW then
        EVENT_MANAGER:AddFilterForEvent(self.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_KILLING_BLOW)
    end
    SLASH_COMMANDS["/kdr"] = function() d("KDR Tracker: Settings > Addons > KDR Tracker") end
    SLASH_COMMANDS["/kdrreset"] = function() self:ResetSession() end
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= KDR.name then return end
    EVENT_MANAGER:UnregisterForEvent(KDR.name, EVENT_ADD_ON_LOADED)
    KDR:Initialize()
end

EVENT_MANAGER:RegisterForEvent(KDR.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)

function KDRTracker_OnHudMoveStop(control)
    if not KDRTracker or not KDRTracker.sv then return end
    local point, _, _, x, y = control:GetAnchor(0)
    KDRTracker.sv.hudAnchor = point or TOPRIGHT
    KDRTracker.sv.hudX = x or -55
    KDRTracker.sv.hudY = y or 105
end

function KDRTracker_OnHudMouseUp(control, button, upInside)
    if not upInside or not KDRTracker or not KDRTracker.sv then return end
    if not KDRTracker.sv.hudLocked and button == MOUSE_BUTTON_INDEX_RIGHT then
        KDRTracker:ToggleSettings()
    end
end
