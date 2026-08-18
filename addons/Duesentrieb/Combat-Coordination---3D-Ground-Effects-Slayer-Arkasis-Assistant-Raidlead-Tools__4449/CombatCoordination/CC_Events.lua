local CC = CombatCoordination

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name = "Events",
    SkillModules = {},
    BuffModules = {},

    startTimeCombatEvent = 0,
    counterCombatEventGained = 0,
    counterCombatEventFaded = 0,

    trackedLeaderName = nil,
    offlineLeaderName = nil,
    offlineLeaderTime = 0,

    Default = {
        enableAutoPromote = true,
        enableDebugOnCombatEvent = false,
        enableDebugOnActionSlotAbilityUsed = false,
        enableDebugCacheUnitNames = false,
    },
    ---@type table|any
    SV = {},
}

----------------------------------------------------------------------------------------------------
-- ADDING LASTCAST
----------------------------------------------------------------------------------------------------
CC.LastCast = {
    currentTime = 0, abilityId = 0,
    playerX = 0, playerY = 0, playerZ = 0, heading = 0,
    cameraX = 0, cameraY = 0, cameraZ = 0,
}

----------------------------------------------------------------------------------------------------
-- UPDATE TRACKED LEADER
----------------------------------------------------------------------------------------------------
function Module:UpdateTrackedLeader()
    if IsUnitGrouped("player") then
        local leaderTag = GetGroupLeaderUnitTag()
        if leaderTag and leaderTag ~= "" then
            self.trackedLeaderName = GetUnitDisplayName(leaderTag)
        end
    else
        self.trackedLeaderName = nil
        self.offlineLeaderName = nil
        self.offlineLeaderTime = 0
    end
end

----------------------------------------------------------------------------------------------------
-- ON GROUP LEADER CHANGED
----------------------------------------------------------------------------------------------------
function Module:OnLeaderUpdate(eventCode, leaderTag)
    if not CC.SV.enableAddon then return end
    if not IsUnitGrouped("player") then return end

    local newLeaderName = GetUnitDisplayName(leaderTag)

    -- JUST GOT CROWN
    if self.SV.enableAutoPromote and AreUnitsEqual(leaderTag, "player") then
        if self.trackedLeaderName and self.trackedLeaderName ~= newLeaderName then
            -- PREV LEADER OFFLINE??
            local oldLeaderTag = nil
            for i = 1, GetGroupSize() do
                local groupTag = GetGroupUnitTagByIndex(i)
                if GetUnitDisplayName(groupTag) == self.trackedLeaderName then
                    oldLeaderTag = groupTag
                    break
                end
            end

            if oldLeaderTag and not IsUnitOnline(oldLeaderTag) then
                self.offlineLeaderName = self.trackedLeaderName
                self.offlineLeaderTime = GetGameTimeSeconds()
            end
        end
    end

    self.trackedLeaderName = newLeaderName
end

----------------------------------------------------------------------------------------------------
-- ON GROUP MEMBER CONNECTED STATUS CHANGED
----------------------------------------------------------------------------------------------------
function Module:OnGroupMemberConnectedStatus(eventCode, unitTag, isOnline)
    if not CC.SV.enableAddon then return end

    if isOnline and self.SV.enableAutoPromote and self.offlineLeaderName then
        local unitName = GetUnitDisplayName(unitTag)
        if unitName == self.offlineLeaderName then
            if IsUnitGroupLeader("player") then
                local timePassed = GetGameTimeSeconds() - self.offlineLeaderTime
                if timePassed <= 600 then -- 10 MINUTES = 600 SECONDS
                    CC.Debug("Leader returned. Returning crown.")
                    local playerLink = CC.GetPlayerLinkFromDisplayName(unitName) or unitName
                    zo_callLater(function()
                        if IsUnitGroupLeader("player") and IsUnitOnline(unitTag) then
                            GroupPromote(unitTag)
                            d(string.format("%s |c00FF00Returned crown to:|r %s", CC.CHAT, playerLink))
                        end
                    end, 2500)
                end
            end
            -- RESET
            self.offlineLeaderName = nil
            self.offlineLeaderTime = 0
        end
    end
end

----------------------------------------------------------------------------------------------------
-- GROUP MEMBER JOINED
----------------------------------------------------------------------------------------------------
function Module:OnGroupMemberJoined(eventCode, memberCharacterName, memberDisplayName, isLocalPlayer)
    self:UpdateTrackedLeader()
    EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. "CC_OnGroupMemberJoined_Delay")

    local randomDelay = math.random(2000, 3000)
    EVENT_MANAGER:RegisterForUpdate(CC.NAME .. "CC_OnGroupMemberJoined_Delay", randomDelay, function()
        EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. "CC_OnGroupMemberJoined_Delay")
        CC.Broadcast:SendPingRequest()
    end)
end

----------------------------------------------------------------------------------------------------
-- GROUP MEMBER LEFT
----------------------------------------------------------------------------------------------------
function Module:OnGroupMemberLeft(eventCode, memberCharacterName, reason, isLocalPlayer, isLeader, memberDisplayName, actionRequired)
    self:UpdateTrackedLeader()
    if GetGroupSize() <= 1 then
        -- KEEP MYSELF
        local playerName = GetUnitDisplayName("player")
        for name, _ in pairs(CC.UserData) do
            if name ~= playerName then
                CC.UserData[name] = nil
            end
        end
        return
    end

    if memberDisplayName and CC.UserData[memberDisplayName] then
        CC.UserData[memberDisplayName] = nil
        CC.Debug(string.format("OnGroupMemberLeft: [%s] LEFT GROUP", memberDisplayName))
    end
end

----------------------------------------------------------------------------------------------------
-- GEAR CHANGE
----------------------------------------------------------------------------------------------------
function Module:OnInventorySingleSlotUpdate()
    EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. "EVENT_INVENTORY_SINGLE_SLOT_UPDATED_DELAY")
    EVENT_MANAGER:RegisterForUpdate(CC.NAME .. "EVENT_INVENTORY_SINGLE_SLOT_UPDATED_DELAY", 250, function()
        EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. "EVENT_INVENTORY_SINGLE_SLOT_UPDATED_DELAY")
        CC.Broadcast:BroadcastStatusUpdate()
    end)
end

----------------------------------------------------------------------------------------------------
-- ZONE CHANGE / GO THROUGH DOOR? / PORT
----------------------------------------------------------------------------------------------------
function Module:OnPlayerActivated()
    self:UpdateTrackedLeader()
    CC.DisplayEffect:ClearAllEffects()

    for _, Effect in ipairs(CC.DisplayEffect.RegisteredEffects) do
        if Effect.Control and not Effect.Control:Has3DRenderSpace() then
            Effect.Control:Create3DRenderSpace()
            Effect.Control:Set3DRenderSpaceUsesDepthBuffer(false)--CC.DisplayEffect.SV.enableDepthBuffer)
        end
    end

    CC.SkillBlocker:UpdateEquippedSkills()
    CC.LaunchPad:LoadPadsForCurrentZone()

    -- CHECK ASSIGNMENT ON PORT TO INSTANCE
    local zoneId = CC.GetCleanZoneId()
    if zoneId ~= 0 then
        -- CHECK SLAYER
        local slayerSide = CC.SlayerAssistant:GetSideIdFromZoneId(zoneId)
        if slayerSide == CC.SlayerAssistant.SIDE_NONE then
            local zoneName = CC.SlayerAssistant:GetZoneNameFromZoneId(zoneId)
            local sideName = CC.SlayerAssistant:GetSideNameFromSideId(slayerSide)
            CC.DisplayDialog:RequestSlayer(zoneId, zoneName, sideName)
        end

        -- CHECK ARKASIS
        local arkasisSide = CC.ArkasisAssistant:GetSideIdFromZoneId(zoneId)
        if arkasisSide == CC.ArkasisAssistant.SIDE_NONE then
            local zoneName = CC.ArkasisAssistant:GetZoneNameFromZoneId(zoneId)
            local sideName = CC.ArkasisAssistant:GetSideNameFromSideId(arkasisSide)
            CC.DisplayDialog:RequestArkasis(zoneId, zoneName, sideName)
        end
    end

    -- INSTALLATION CHECK
    zo_callLater(function()
        if CC.SV.isTextureVisible == false then
            CC.DisplayDialog:RequestInstallCheck()
        end
    end, 2500)

    zo_callLater(function()
        CC.Broadcast:SendPingRequest()
    end, 5000)
end

----------------------------------------------------------------------------------------------------
-- COMBAT STATE
----------------------------------------------------------------------------------------------------
function Module:OnPlayerCombatState(eventCode, inCombat)
    CC.SkillBlocker:UpdateEquippedSkills()
end

----------------------------------------------------------------------------------------------------
-- REFRESH THE LAST CAST COORDINATION FOR E.G. SYNERGIE LIKE ALKOSH
----------------------------------------------------------------------------------------------------
function Module:RefreshLastCast(abilityId)
    -- GetUnitRawWorldPosition(string unitTag)
    -- Returns: integer zoneId, integer worldX, integer worldY, integer worldZ
    local zoneId, playerX, playerY, playerZ = GetUnitRawWorldPosition("player")

    -- GetMapPlayerPosition(string unitTag)
    -- Returns: number normalizedX, number normalizedZ, number heading, bool isShownInCurrentMap
    local normalizedX, normalizedZ, heading, isShownInCurrentMap = GetMapPlayerPosition("player")

    local cameraX, cameraY, cameraZ = CC.GetCameraTargetPosition(playerY, 2800)

    CC.LastCast.currentTime = GetGameTimeMilliseconds()
    CC.LastCast.abilityId = abilityId

    CC.LastCast.playerX = playerX or 0
    CC.LastCast.playerY = playerY or 0
    CC.LastCast.playerZ = playerZ or 0

    CC.LastCast.heading = heading or 0

    CC.LastCast.cameraX = cameraX or 0
    CC.LastCast.cameraY = cameraY or 0
    CC.LastCast.cameraZ = cameraZ or 0
end

----------------------------------------------------------------------------------------------------
-- EVENT ACTION SLOT ABILITY USED
----------------------------------------------------------------------------------------------------
function Module:OnActionSlotAbilityUsed(eventCode, actionSlotIndex)
    local abilityId = GetSlotBoundId(actionSlotIndex) or 0

    -- FILTER LIGHT AND HEAVY ATTACKS - WEAVING MESSES UP LASTCAST UNFORT.
    if CC.Blacklist[abilityId] then return end

    if self.SV.enableDebugOnActionSlotAbilityUsed then
        local abilityName = zo_strformat("<<1>>", GetAbilityName(abilityId))
        -- FORMAT IN DATABASE FORMAT: [] = { name = "" },
        d(CC.CHAT .. string.format(' [%s] = { name = "%s", type = ?, offsetPlayer = ?, maxRange = ?, width = ?, height = ?, durationSec = ? },', abilityId, abilityName))
    end

    self:RefreshLastCast(abilityId)

    local SkillModule = self.SkillModules[abilityId]
    if SkillModule and SkillModule.HandleActionSlotAbilityUsed then
        SkillModule:HandleActionSlotAbilityUsed(abilityId)
    end
end

----------------------------------------------------------------------------------------------------
-- CACHE UNITNAMES TO MATCH THEM LATER
-- DEBUG /script d(CombatCoordination.UnitNames)
----------------------------------------------------------------------------------------------------
function Module:CacheUnitName(abilityName, sourceName, sourceType, targetName, targetType, sourceUnitId, targetUnitId)
    if sourceType == COMBAT_UNIT_TYPE_PLAYER or sourceType == COMBAT_UNIT_TYPE_GROUP then
        if sourceUnitId ~= 0 and sourceName and sourceName ~= "" and not CC.UnitNames[sourceUnitId] then
            CC.UnitNames[sourceUnitId] = zo_strformat("<<1>>", sourceName)
            if self.SV.enableDebugCacheUnitNames then
                d(CC.CHAT .. " |c00FF00CHACHE!|r (" .. abilityName .. ") sourceName: " .. CC.UnitNames[sourceUnitId] .. (" sourceUnitId: " .. sourceUnitId))
            end
        end
    end
    if targetType == COMBAT_UNIT_TYPE_PLAYER or targetType == COMBAT_UNIT_TYPE_GROUP then
        if targetUnitId ~= 0 and targetName and targetName ~= "" and not CC.UnitNames[targetUnitId] then
            CC.UnitNames[targetUnitId] = zo_strformat("<<1>>", targetName)
            if self.SV.enableDebugCacheUnitNames then
                d(CC.CHAT .. " |c00FF00CHACHE!|r (" .. abilityName .. ") targetName: " .. CC.UnitNames[targetUnitId] .. (" targetUnitId: " .. targetUnitId))
            end
        end
    end
end

----------------------------------------------------------------------------------------------------
-- OUTPUT ONE COMBAT EVENT (AT A TIME)
----------------------------------------------------------------------------------------------------
function Module:DebugCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    local chat = "|c00FF00[CC]|r"
    if result == ACTION_RESULT_EFFECT_GAINED then
        self.counterCombatEventGained = self.counterCombatEventGained + 1
    elseif result == ACTION_RESULT_EFFECT_FADED then
        chat = "|cFF0000[CC]|r"
        self.counterCombatEventFaded = self.counterCombatEventFaded + 1
    else return end

    local ColorHex = CC.GetColorFromAbilityId(abilityId)
    local currentTime = GetGameTimeSeconds()
    local sourceCache = CC.UnitNames[sourceUnitId] or "N/A"
    local targetCache = CC.UnitNames[targetUnitId] or "N/A"

    d(string.format("%s |c%sabilityId: %d - abilityName: %s|r", chat, ColorHex, abilityId, abilityName))
    d(string.format("|c%s      - result: %s - hitValue: %d - currentTime: %.3f (s)|r", ColorHex, result, hitValue, currentTime))
    d(string.format("|c%s      - sourceName: %s - sourceType: %d - sourceUnitId: %d - Cache: %s|r", ColorHex, sourceName, sourceType, sourceUnitId, sourceCache))
    d(string.format("|c%s      - targetName: %s - targetType: %d - targetUnitId: %d - Cache: %s|r", ColorHex, targetName, targetType, targetUnitId, targetCache))
end

----------------------------------------------------------------------------------------------------
-- ON COMBAT EVENT
----------------------------------------------------------------------------------------------------
function Module:OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if not CC.SV.enableAddon then return end

    -- CACHE UNITNAMES FOR MATCHING ID -> GROUPMEMBER
    local cacheSource = (sourceUnitId ~= 0 and (sourceType == COMBAT_UNIT_TYPE_PLAYER or sourceType == COMBAT_UNIT_TYPE_GROUP) and not CC.UnitNames[sourceUnitId])
    local cacheTarget = (targetUnitId ~= 0 and (targetType == COMBAT_UNIT_TYPE_PLAYER or targetType == COMBAT_UNIT_TYPE_GROUP) and not CC.UnitNames[targetUnitId])

    if cacheSource or cacheTarget then
        self:CacheUnitName(abilityName, sourceName, sourceType, targetName, targetType, sourceUnitId, targetUnitId)
    end

    -- OUTPUT EVERYTHING [/cc_debug_combatevent]
    if self.SV.enableDebugOnCombatEvent then
        self:DebugCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    end

    -- MODULE CALLBACK! (IF SO)
    local SkillModule = self.SkillModules[abilityId]
    if SkillModule and SkillModule.HandleCombatEvent then
        SkillModule:HandleCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    end
end

----------------------------------------------------------------------------------------------------
-- DRAW GROUND EFFECT AFTER COMBAT EVENT (OR CUSTOM)
----------------------------------------------------------------------------------------------------
function Module:HandleCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if result ~= ACTION_RESULT_EFFECT_GAINED then return end
    if sourceType ~= COMBAT_UNIT_TYPE_PLAYER then return end

    local ID = abilityId
    local SkillData = CC.SkillData[ID]
    if not SkillData then return end

    -- NOTE TO LATER SELF: IN CASE OF OLORIME THIS DATA IS ALREADY INJECTED WITH CAMERA TARGET
    local originX = CC.LastCast.playerX
    local originY = CC.LastCast.playerY
    local originZ = CC.LastCast.playerZ
    local heading = CC.LastCast.heading
    if not (originX and originY and originZ and heading) then return end

    local TX, TY, TZ = CC.GetAbilityTargetPosition(SkillData, originX, originY, originZ, heading)
    local RX, RY, RZ = CC.GetGroundRotation(TX, TY, TZ)
    RY = heading or RY
    if not (TX and TY and TZ and RY) then return end

    local isPlayer = true
    CC.DrawCombatVisuals(self, isPlayer, "player", ID, TX, TY, TZ, RX, RY, RZ)
end

----------------------------------------------------------------------------------------------------
-- ON EFFECT CHANGED
----------------------------------------------------------------------------------------------------
function Module:OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceUnitType)
    -- SKILLBLOCKER
    local ShouldBlock = CC.SkillBlocker.BlockableBuffs[abilityId]
    if ShouldBlock then
        if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
            local expireTimeMs = (endTime > 0) and (math.floor(endTime * 1000) + 500) or 0
            CC.SkillBlocker.PlayerBuffs[abilityId] = expireTimeMs
            CC.SkillBlocker:StartSkillBlockerLoop()
        elseif changeType == EFFECT_RESULT_FADED then
            CC.SkillBlocker.PlayerBuffs[abilityId] = nil
        end
    end

    -- VISUALS
    local BuffModule = CC.Events.BuffModules[abilityId]
    if BuffModule and BuffModule.HandleEffectChanged then
        BuffModule:HandleEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceUnitType)
    end
end

----------------------------------------------------------------------------------------------------
-- DRAW EFFECT CHANGED
----------------------------------------------------------------------------------------------------
function Module:HandleEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceUnitType)
    if changeType ~= EFFECT_RESULT_GAINED and changeType ~= EFFECT_RESULT_UPDATED then return end
    if sourceUnitType ~= COMBAT_UNIT_TYPE_PLAYER then return end

    local ID = abilityId
    local SkillData = CC.SkillData[ID]
    if not SkillData then return end

    local _, playerX, playerY, playerZ = GetUnitRawWorldPosition("player")
    local _, _, heading = GetMapPlayerPosition("player")
    if not (playerX and playerY and playerZ and heading) then return end

    local TX, TY, TZ = CC.GetAbilityTargetPosition(SkillData, playerX, playerY, playerZ, heading)
    local RX, RY, RZ = CC.GetGroundRotation(TX, TY, TZ)
    RY = heading or RY
    if not (TX and TY and TZ and RY) then return end

    local isPlayer = true
    CC.DrawCombatVisuals(self, isPlayer, "player", ID, TX, TY, TZ, RX, RY, RZ)
end

----------------------------------------------------------------------------------------------------
-- DRAW / BROADCAST
----------------------------------------------------------------------------------------------------
function CC.DrawCombatVisuals(self, isPlayer, unitTag, ID, TX, TY, TZ, RX, RY, RZ)
    local SkillData = CC.SkillData[ID]
    if not SkillData then
        CC.Debug("CC.DrawCombatVisuals; if not SkillData then return end")
        return
    end

    local trackingKey = self.name .. (isPlayer and "Player" or tostring(unitTag))

    local LastEffectData = CC.DisplayEffect.EffectTimers[trackingKey] or { currentTime = 0, startTime = nil, effectId = nil }
    local LastLabelData = CC.DisplayLabel.LabelTimers[trackingKey] or { currentTime = 0, startTime = nil, labelId = nil }

    local currentTime = GetGameTimeMilliseconds()
    if currentTime < (LastEffectData.currentTime + 1000) then return end

    local width, height = (SkillData.width * 100), (SkillData.height * 100)
    local texture = self.SV.texture
    local durationMs = SkillData.durationSec * 1000
    local startTime = LastEffectData.startTime or currentTime

    local Color = self.SV.enableGameAoeFriendlyColor and CC.GetGameAoeFriendlyColor() or (isPlayer and self.SV.ColorSelf or self.SV.ColorGroup)

    if SkillData.isRecast and LastEffectData.startTime and LastEffectData.startTime > 0 then
        local timePassed = currentTime - LastEffectData.startTime
        if timePassed < durationMs then
            durationMs = durationMs - timePassed
        else
            startTime = currentTime
        end
    end

    -- REMOVE OLD EFFECT(S)
    if LastEffectData.effectId then CC.DisplayEffect:RemoveTrackedEffect(LastEffectData.effectId) end
    if LastLabelData.labelId then CC.DisplayLabel:RemoveTrackedLabel(LastLabelData.labelId) end

    -- START HIDDEN (ID IS NEEDED FOR BLOCKER; DRAW INVISIBLE)
    local isHidden = false
    if isPlayer then
        isHidden = (not self.SV.enableDrawSelf and not CC.enablePreview)
    else
        isHidden = (not self.SV.enableDrawGroup and not CC.enablePreview)
    end

    if CC.SkillBlocker.EquippedSkills[ID] and CC.SkillBlocker.BlockableSkills[ID] and self.SV.enableSkillBlocker then
        CC.SkillBlocker:StartSkillBlockerLoop()
    end

    -- DRAW EFFECT
    local effectId = CC.DisplayEffect:Draw3DEffect(
    {
        ID = ID,

        TX = TX, RX = RX, FX = false,
        TY = TY, RY = RY, FY = false,
        TZ = TZ, RZ = RZ, FZ = false,

        width = width,
        height = height,

        texture = texture,
        Color = Color,
        isHidden = isHidden,
        durationMs = durationMs,
    })
    CC.DisplayEffect.EffectTimers[trackingKey] = { currentTime = currentTime, startTime = startTime, effectId = effectId }

    -- BROADCAST: ENCODE RADIANS TO 0-628 FOR THE DUMB LGB PIPE
    if isPlayer and CC.Broadcast.LutDataOut[ID] and CC.Broadcast.Handler and CC.Broadcast.Handler:IsFinalized() then

        CC.Broadcast:Send({
            ID = ID,
            TX = TX, TY = TY, TZ = TZ,

            -- TODO: CHECK IF THIS IS STILL CORRECT:
            RX = CC.GetEncodedRadiant(RX),
            RY = CC.GetEncodedRadiant(RY),
            RZ = CC.GetEncodedRadiant(RZ),
        })
    end

    -- DRAW LABEL
    local timerMode = self.SV.timer or 0
    if CC.enablePreview then timerMode = math.max(1, timerMode) end

    if timerMode > 0 then
        local labelTY = TY
        local labelRX, labelRY = RX, RY
        local FX, FY = false, false

        -- MODES
        if timerMode == 2 then
            -- VERTICAL, FACING
            labelTY = labelTY + 250 + (math.max(width, height) / 10)
            labelRX = 0
            labelRY = 0
            FX = true
            FY = true
        end

        -- local animationMs = CC.DisplayLabel.SV.animationMs

        -- DRAW LABEL
        local labelId = CC.DisplayLabel:Draw3DLabel({
            ID = ID,

            TX = TX,      RX = labelRX, FX = FX,
            TY = labelTY, RY = labelRY, FY = FY,
            TZ = TZ,      RZ = RZ,      FZ = false,

            isProximityFade = (timerMode == 2 and true) or nil,

            displayTime = durationMs,
            Color = Color,
            isHidden = isHidden,
            durationMs = durationMs,
        })
        CC.DisplayLabel.LabelTimers[trackingKey] = { currentTime = currentTime, startTime = startTime, labelId = labelId }
    end
end

----------------------------------------------------------------------------------------------------
-- CLEAR VISUALS (EARLY)
----------------------------------------------------------------------------------------------------
function CC.ClearCombatVisuals(self, isPlayer, unitTag)
    local trackingKey = self.name .. (isPlayer and "Player" or tostring(unitTag))

    -- REMOVE 3D EFFECT
    local LastEffectData = CC.DisplayEffect.EffectTimers[trackingKey]
    if LastEffectData and LastEffectData.effectId then
        CC.DisplayEffect:RemoveTrackedEffect(LastEffectData.effectId)
        CC.DisplayEffect.EffectTimers[trackingKey] = nil
    end

    -- REMOVE LABEL
    local LastLabelData = CC.DisplayLabel.LabelTimers[trackingKey]
    if LastLabelData and LastLabelData.labelId then
        CC.DisplayLabel:RemoveTrackedLabel(LastLabelData.labelId)
        CC.DisplayLabel.LabelTimers[trackingKey] = nil
    end
end

----------------------------------------------------------------------------------------------------
-- TEST AND DEBUG
----------------------------------------------------------------------------------------------------
function Module:ToggleDebugCombatEvent()
    self.SV.enableDebugOnCombatEvent = not self.SV.enableDebugOnCombatEvent

    if self.SV.enableDebugOnCombatEvent then
        self.startTimeCombatEvent = GetGameTimeSeconds()
        self.counterCombatEventGained = 0
        self.counterCombatEventFaded = 0
        d(CC.CHAT .. " |c00FF00Combat event debug enabled.|r")
    else
        local time = GetGameTimeSeconds() - self.startTimeCombatEvent
        d(string.format("%s |cFF0000Combat event debug disabled.|r Duration: %.3fs - |c00FF00Gained: %d|r - |cFF0000Faded: %d|r", CC.CHAT, time, self.counterCombatEventGained, self.counterCombatEventFaded))
    end
end
SLASH_COMMANDS["/cc_debug_combatevent"] = function() CC.Events:ToggleDebugCombatEvent() end

----------------------------------------------------------------------------------------------------
-- CASTS / ABILITYIDS
----------------------------------------------------------------------------------------------------
function Module:ToggleDebugAbility()
    self.SV.enableDebugOnActionSlotAbilityUsed = not self.SV.enableDebugOnActionSlotAbilityUsed
    if self.SV.enableDebugOnActionSlotAbilityUsed then
        d(CC.CHAT .. " |c00FF00Ability debug enabled.|r")
    else
        d(CC.CHAT .. " |cFF0000Ability debug disabled.|r")
    end
end
SLASH_COMMANDS["/cc_debug_ability"] = function() CC.Events:ToggleDebugAbility() end

----------------------------------------------------------------------------------------------------
-- CACHE FOR UNITNAMES
----------------------------------------------------------------------------------------------------
function Module:ToggleDebugCacheUnitNames()
    self.SV.enableDebugCacheUnitNames = not self.SV.enableDebugCacheUnitNames
    if self.SV.enableDebugCacheUnitNames then
        d(CC.CHAT .. " |c00FF00Cache debug enabled.|r")
    else
        d(CC.CHAT .. " |cFF0000Cache debug disabled.|r")
    end
end
SLASH_COMMANDS["/cc_debug_cache"] = function() CC.Events:ToggleDebugCacheUnitNames() end

function Module:CacheClean()
    ZO_ClearTable(CC.UnitNames)
    d(CC.CHAT .. " |cFF0000Cache cleared.|r")
end
SLASH_COMMANDS["/cc_cache_clean"] = function() CC.Events:CacheClean() end

function Module:CachePrint()
    d(CC.CHAT .. " |c00FF00Current cache data:|r")
    d(CC.UnitNames)
end
SLASH_COMMANDS["/cc_cache_print"] = function() CC.Events:CachePrint() end

----------------------------------------------------------------------------------------------------
-- REGISTER MODULE
----------------------------------------------------------------------------------------------------
CC[Module.name] = Module
table.insert(CC.Modules, Module)