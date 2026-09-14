local CC = CombatCoordination
local LUT = CC.LUT.SYNC

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name = "Broadcast",
    Handler = nil,
    Modules = {},

    LutDataIn = {},
    LutDataOut = {},

    requestStartTime = 0,
    echoStartTime = 0,
    timeoutMs = 5000,
    isManualRequest = false,
    isReceivingSync = false,
    isReceivingVersion = false,

    lastRequestTime = 0,

    Default = {
        enableDebugOnData = false,
        enableDebugSync = false,
    },
    ---@type table|any
    SV = {},
}

----------------------------------------------------------------------------------------------------
-- DEBUG SYNCHRONIZATION
----------------------------------------------------------------------------------------------------
function Module:DebugSync(msg)
    if not self.SV.enableDebugSync then return end
    d(CC.CHAT .. " |c00FF00Sync|r " .. msg)
end

SLASH_COMMANDS["/cc_debug_sync"] = function()
    Module.SV.enableDebugSync = not Module.SV.enableDebugSync
    if Module.SV.enableDebugSync then
        d(CC.CHAT .. " |c00FF00Debug [Broadcast Sync] enabled.|r")
    else
        d(CC.CHAT .. " |cFF0000Debug [Broadcast Sync] disabled.|r")
    end
end

----------------------------------------------------------------------------------------------------
-- CUSTOM ENABLE / DISABLE
----------------------------------------------------------------------------------------------------
function Module:CustomEnable()
    self:Initialize()
end

function Module:CustomDisable()
    self.isReceivingSync = false
    self.isReceivingVersion = false
    self.requestStartTime = 0
    self.echoStartTime = 0
    EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. "Broadcast_Sync_Initial")
    EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. "Broadcast_Sync_Loop")
end

----------------------------------------------------------------------------------------------------
-- TEST COMMAND / DEBUG
----------------------------------------------------------------------------------------------------
SLASH_COMMANDS["/cc_test"] = function()
    local abilityId = 32947 -- STANDARD OF MIGHT
    local result = ACTION_RESULT_EFFECT_GAINED
    local sourceType = COMBAT_UNIT_TYPE_PLAYER
    local sourceName = "Cctest"
    local sourceUnitId = 0

    CC.Events:RefreshLastCast(abilityId)
    CC.Events:OnCombatEvent(nil, result, nil, nil, nil, nil, sourceName, sourceType, nil, nil, nil, nil, nil, nil, sourceUnitId, nil, abilityId, nil)

    local stringUnitGrouped = (IsUnitGrouped("player") and " Synchronized via LGB.") or ""
    d(CC.CHAT .. " |c00FF00Test marker drawn.|r" .. stringUnitGrouped)
end

----------------------------------------------------------------------------------------------------
-- SEND STATUS UPDATE (GEAR CHANGE, ASSIGNMENT)
----------------------------------------------------------------------------------------------------
function Module:SendSyncReply()
    -- WATCHDOG..
    self:CleanUpGhosts()

    local playerZoneId = CC.GetCleanZoneId()

    local slayerSide = CC.SlayerAssistant:GetSideIdFromZoneId(playerZoneId) or 0
    local slayerSet  = CC.GetPlayerSetStatus("SLAYER")

    local arkasisSide = CC.ArkasisAssistant:GetSideIdFromZoneId(playerZoneId) or 0
    local arkasisSet  = CC.GetPlayerSetStatus("ARKASIS")

    local RX = CC.IsRaidlead() and 1 or 0
    local RY = (slayerSide * 10) + slayerSet
    local RZ = (arkasisSide * 10) + arkasisSet

    self:UpdateAddonUsers("player", nil, CC.IsRaidlead(), RY, RZ)

    if IsUnitGrouped("player") then
        self:DebugSync("SendSyncReply()")
        self.echoStartTime = GetGameTimeMilliseconds()
        self:Send({ ID = LUT.SYNC_REPLY, TX = 0, TY = 0, TZ = 0, RX = RX, RY = RY, RZ = RZ })
    end
end

----------------------------------------------------------------------------------------------------
-- HANDLE SYNC DATA
----------------------------------------------------------------------------------------------------
function Module:HandleSyncData(unitTag, Data)
    if not CC.SV.enableAddon then return end

    local isValidData = (Data.TX == Data.TY and Data.TY == Data.TZ)
    if not isValidData then return end

    local isPlayer = AreUnitsEqual(unitTag, "player")
    local currentPing = nil
    local isSenderRaidlead = (Data.RX == 1)
    local slayerEnc = Data.RY or 0
    local arkasisEnc = Data.RZ or 0

    if Data.ID == LUT.SYNC_REQUEST then self:StartSyncLoop() end

    if isPlayer then
        if self.isReceivingSync and self.requestStartTime > 0 then
            currentPing = GetGameTimeMilliseconds() - self.requestStartTime

            self:UpdateAddonUsers(unitTag, currentPing, isSenderRaidlead, slayerEnc, arkasisEnc)

            if self.isManualRequest then
                self:PrintReply(unitTag, currentPing, isSenderRaidlead, slayerEnc, arkasisEnc)
            end
        end

        if Data.ID == LUT.SYNC_REPLY and self.echoStartTime and self.echoStartTime > 0 then
            local echoPing = GetGameTimeMilliseconds() - self.echoStartTime
            self.echoStartTime = 0
            self:UpdateAddonUsers(unitTag, echoPing, isSenderRaidlead, slayerEnc, arkasisEnc)
        end

        return
    end

    -- INCOMING REQUEST FROM GROUP
    if Data.ID == LUT.SYNC_REQUEST then
        self:DebugSync("HandleSyncData() Data.ID == LUT.SYNC_REQUEST")

        -- SPAM ON DOORS / PORTS.. SOMEONE ELSE REQUESTED FIRST? BLOCK MY OWN
        self.lastRequestTime = GetGameTimeMilliseconds()

        self:UpdateAddonUsers(unitTag, nil, isSenderRaidlead, slayerEnc, arkasisEnc)
        self:SendSyncReply()

    -- INCOMING REPLY FROM GROUP
    elseif Data.ID == LUT.SYNC_REPLY then
        -- CALC PING OR NIL
        if self.isReceivingSync and self.requestStartTime > 0 then
            currentPing = (GetGameTimeMilliseconds() - self.requestStartTime) / 2
        end

        self:UpdateAddonUsers(unitTag, currentPing, isSenderRaidlead, slayerEnc, arkasisEnc)

        -- PRINT REPLY
        if self.isReceivingSync and self.isManualRequest then
            self:PrintReply(unitTag, currentPing, isSenderRaidlead, slayerEnc, arkasisEnc)
        end
    end
end

----------------------------------------------------------------------------------------------------
-- HANDLE VERSION CHECK
----------------------------------------------------------------------------------------------------
function Module:HandleVersionData(unitTag, Data)
    if not CC.SV.enableAddon then return end

    local isPlayer = AreUnitsEqual(unitTag, "player")

    -- INCOMING REQUEST -> SEND REPLY
    if Data.ID == LUT.VERSION_REQUEST and not isPlayer then
        self:Send({ ID = LUT.VERSION_REPLY, TX = 0, TY = 0, TZ = 0, RX = CC.ADDONVERSION or 0, RY = 0, RZ = 0 })
    end

    -- INCOMING REPLY
    if Data.ID == LUT.VERSION_REPLY then
        local displayName = GetUnitDisplayName(unitTag)
        if not displayName or displayName == "" then return end

        CC.GroupData[displayName] = CC.GroupData[displayName] or {}
        CC.GroupData[displayName].version = Data.RX or 0
        CC.GroupData[displayName].isAddonUser = true
        CC.GroupData[displayName].lastSeen = GetGameTimeSeconds()

        if self.isReceivingVersion then
            local playerLink = CC.GetPlayerLinkFromDisplayName(displayName) or displayName
            d(string.format("%s Version check: %s - %04d", CC.CHAT, playerLink, Data.RX or 0))
        end
    end
end

----------------------------------------------------------------------------------------------------
-- SEND BROADCAST
----------------------------------------------------------------------------------------------------
function Module:Send(Data)
    if not self.Handler or not self.Handler:IsFinalized() then return false end
    local ID = self.LutDataOut[Data.ID] or Data.ID
    if not ID then return false end

    local IntData = { ID = ID }

    -- CHECK IF TRACKING (TX == TY == TZ)
    local isTracking = (Data.TX and Data.TX == Data.TY and Data.TY == Data.TZ)
    local hasCoords = not isTracking and ((Data.TX and Data.TX ~= 0) or (Data.TY and Data.TY ~= 0) or (Data.TZ and Data.TZ ~= 0))

    if isTracking then
        IntData.TX = Data.TX
        IntData.TY = Data.TY
        IntData.TZ = Data.TZ
    elseif hasCoords then
        IntData.TX = math.floor(((Data.TX or 0) / 10) + 0.5) % 1024
        IntData.TY = math.floor(((Data.TY or 0) /  2) + 0.5) % 1024
        IntData.TZ = math.floor(((Data.TZ or 0) / 10) + 0.5) % 1024
    else
        IntData.TX = 0
        IntData.TY = 0
        IntData.TZ = 0
    end

    IntData.RX = math.floor(Data.RX or 0) % 1024
    IntData.RY = math.floor(Data.RY or 0) % 1024
    IntData.RZ = math.floor(Data.RZ or 0) % 1024

    self.Handler:Send(IntData)
    return true
end

----------------------------------------------------------------------------------------------------
-- INCOMING BROADCAST
----------------------------------------------------------------------------------------------------
function Module:OnData(unitTag, Data)
    if not CC.SV.enableAddon then return end
    if not unitTag or not Data then return end

    local broadcastId = self.LutDataIn[Data.ID] or Data.ID
    Data.ID = broadcastId

    -- COORDS DECOMPRESS
    local hasCoords = (Data.TX ~= 0 or Data.TY ~= 0 or Data.TZ ~= 0)

    -- DON'T COMPRESS.. LOOKS LIKE TRACKING DATA
    if Data.TX == Data.TY and Data.TY == Data.TZ then
        hasCoords = false
    end

    if hasCoords then
        if not DoesUnitExist(unitTag) then return end

        local _, worldX, worldY, worldZ = GetUnitRawWorldPosition(unitTag)
        if not (worldX and worldY and worldZ) then
            CC.Debug("CC.Broadcast:OnData: Missing unit raw position.")
            return
        end

        local lsbTX = math.floor((worldX / 10) + 0.5)
        local deltaX = ((Data.TX or 0) - lsbTX + 512) % 1024 - 512
        Data.TX = (lsbTX + deltaX) * 10

        local lsbTZ = math.floor((worldZ / 10) + 0.5)
        local deltaZ = ((Data.TZ or 0) - lsbTZ + 512) % 1024 - 512
        Data.TZ = (lsbTZ + deltaZ) * 10

        local lsbTY = math.floor((worldY / 2) + 0.5)
        local deltaY = ((Data.TY or 0) - lsbTY + 512) % 1024 - 512
        Data.TY = (lsbTY + deltaY) * 2
    end

    -- PING AND VERSION CHECK
    if Data.ID == LUT.SYNC_REPLY or Data.ID == LUT.SYNC_REQUEST then
        self:HandleSyncData(unitTag, Data)
        return
    elseif Data.ID == LUT.VERSION_REPLY or Data.ID == LUT.VERSION_REQUEST then
        self:HandleVersionData(unitTag, Data)
        return
    end

    -- DEBUG
    if self.SV.enableDebugOnData then
        local displayName = GetUnitDisplayName(unitTag) or "Unknown"
        local playerLink = CC.GetPlayerLinkFromDisplayName(displayName) or displayName
        local abilityName = ""
        local SkillData = CC.SkillData[Data.ID]
        if SkillData then abilityName = " (" .. (SkillData.name or "Unknown") .. ")" end
        d(string.format("%s OnData! [%s] ID:%s%s TX:%s TY:%s TZ:%s RX:%s RY:%s RZ:%s", CC.CHAT, playerLink, Data.ID, abilityName, Data.TX, Data.TY, Data.TZ, Data.RX, Data.RY, Data.RZ))
    end

    -- ROUTE TO MODULE
    local BroadcastModule = self.Modules[Data.ID]

    if BroadcastModule and BroadcastModule.HandleBroadcast then
        BroadcastModule:HandleBroadcast(unitTag, Data)
        CC.DisplayStatus:PlayAnimation()
    end
end

----------------------------------------------------------------------------------------------------
-- INCOMING EFFECT DATA
----------------------------------------------------------------------------------------------------
function Module:HandleBroadcast(unitTag, Data)
    if AreUnitsEqual(unitTag, "player") then return end

    local ID = Data.ID
    local SkillData = CC.SkillData[ID]
    if not SkillData then return end

    local TX, TY, TZ = Data.TX, Data.TY, Data.TZ
    if not (TX and TY and TZ) then return end

    -- DECODE ROTATION
    local RX = (Data.RX or 0) / 100
    local RY = (Data.RY or 0) / 100
    local RZ = (Data.RZ or 0) / 100

    local isPlayer = false
    CC.DrawCombatVisuals(self, isPlayer, unitTag, ID, TX, TY, TZ, RX, RY, RZ)
end

----------------------------------------------------------------------------------------------------
-- INITIALIZE
----------------------------------------------------------------------------------------------------
function Module:Initialize()
    if self.Handler then return end

    -- YEAH YEAH I KNOW.. IT'S IN THE DEPENDENCIES. BUT I CAN SLEEP BETTER WITH THIS LINE OF SAFETY.
    if LibGroupBroadcast then
        local Handler = LibGroupBroadcast:RegisterHandler("CombatCoordination")
        Handler:SetDisplayName("|cFF7F00Combat|r |cFFFFFFCoordination|r")
        Handler:SetDescription("Shares 3D combat markers and essential tools for raid coordination.")
        -- https://wiki.esoui.com/LibGroupBroadcast_IDs
        self.Handler = Handler:DeclareProtocol(500, "CombatCoordination")

        local IdentifierOptions  = { numBits = 10, minValue = 0,    maxValue = 1023 } -- UNSIGNED  0 <= v <= 1023
        local CoordinatesOptions = { numBits = 10, minValue = 0,    maxValue = 1023 } -- UNSIGNED  0 <= v <= 1023
        local OrientationOptions = { numBits = 10, minValue = 0,    maxValue = 1023 } -- UNSIGNED  0 <= v <= 628

        self.Handler
            :AddField(LibGroupBroadcast.CreateNumericField("ID", IdentifierOptions))  -- EVENT ID

            -- TRANSLATION: TX, TY, TZ
            :AddField(LibGroupBroadcast.CreateNumericField("TX", CoordinatesOptions)) -- CENTER X
            :AddField(LibGroupBroadcast.CreateNumericField("TY", CoordinatesOptions)) -- CENTER Y
            :AddField(LibGroupBroadcast.CreateNumericField("TZ", CoordinatesOptions)) -- CENTER Z

            -- ROTATION: RX, RY, RZ
            :AddField(LibGroupBroadcast.CreateNumericField("RX", OrientationOptions)) -- ROT X
            :AddField(LibGroupBroadcast.CreateNumericField("RY", OrientationOptions)) -- ROT Y
            :AddField(LibGroupBroadcast.CreateNumericField("RZ", OrientationOptions)) -- ROT Z

            :OnData(function(unitTag, Data) self:OnData(unitTag, Data) end)
        self.Handler:Finalize({ isRelevantInCombat = true })
    end
end

----------------------------------------------------------------------------------------------------
-- REG GROUP MEMBER
----------------------------------------------------------------------------------------------------
function Module:UpdateAddonUsers(unitTag, currentPing, isRaidlead, slayerEnc, arkasisEnc)
    local displayName = GetUnitDisplayName(unitTag)
    if not displayName or displayName == "" then return end

    CC.GroupData[displayName] = CC.GroupData[displayName] or {}
    local GroupMember = CC.GroupData[displayName]

    -- ADDON FLAG AND WATCHDOG
    GroupMember.isAddonUser = true
    GroupMember.lastSeen = GetGameTimeSeconds()

    if currentPing ~= nil and currentPing >= 0 then
        GroupMember.pingMs = currentPing
    end

    if isRaidlead ~= nil then
        GroupMember.isRaidlead = isRaidlead
    end

    local targetZoneId = CC.GetCleanZoneId(GetUnitRawWorldPosition(unitTag))

    -- DECODE SLAYER
    if slayerEnc then
        local sideId = math.floor(slayerEnc / 10)
        local setId = slayerEnc % 10
        GroupMember.SlayerAssistant = GroupMember.SlayerAssistant or {}
        GroupMember.SlayerAssistant.sideId = sideId
        GroupMember.SlayerAssistant.isEquipped = setId
        GroupMember.SlayerAssistant.zoneId = targetZoneId
    end

    -- DECODE ARKASIS
    if arkasisEnc then
        local sideId = math.floor(arkasisEnc / 10)
        local setId = arkasisEnc % 10
        GroupMember.ArkasisAssistant = GroupMember.ArkasisAssistant or {}
        GroupMember.ArkasisAssistant.sideId = sideId
        GroupMember.ArkasisAssistant.isEquipped = setId
        GroupMember.ArkasisAssistant.zoneId = targetZoneId
    end

    CC.DisplayStatus:Update()

    if CC.DisplayPanel.SV.isVisible then
        CC.DisplayPanel:UpdateData()
    end

    -- TRIGGER LATE DRAWS
    CC.SlayerAssistant:CheckLateDraw(unitTag)
    CC.ArkasisAssistant:CheckLateDraw(unitTag)
end

----------------------------------------------------------------------------------------------------
-- WATCHDOG
----------------------------------------------------------------------------------------------------
function Module:CleanUpGhosts()
    local currentTime = GetGameTimeSeconds()
    local hasRemoved = false
    local playerName = GetUnitDisplayName("player")

    for displayName, GroupMember in pairs(CC.GroupData) do
        if displayName ~= playerName then
            local lastSeen = GroupMember.lastSeen or currentTime

            if (currentTime - lastSeen) > 180 then
                local isStillInGroup = false
                if IsUnitGrouped("player") then
                    for i = 1, GetGroupSize() do
                        if GetUnitDisplayName("group" .. i) == displayName then
                            isStillInGroup = true
                            break
                        end
                    end
                end

                if isStillInGroup then
                    -- NO ADDON PINGS
                    GroupMember.isAddonUser = false
                    GroupMember.pingMs = nil
                    GroupMember.version = nil
                    GroupMember.isRaidlead = nil
                    GroupMember.SlayerAssistant = nil
                    GroupMember.ArkasisAssistant = nil
                    GroupMember.lastSeen = currentTime
                    hasRemoved = true
                else
                    CC.Debug(string.format("Ghost removed: %s", displayName))
                    CC.GroupData[displayName] = nil
                    hasRemoved = true
                end
            end
        else
            GroupMember.isAddonUser = true
            GroupMember.lastSeen = currentTime
        end
    end

    if hasRemoved then
        CC.DisplayStatus:Update()
        if CC.DisplayPanel.SV.isVisible then
            CC.DisplayPanel:UpdateData()
        end
    end
end

----------------------------------------------------------------------------------------------------
-- RING SYNC
----------------------------------------------------------------------------------------------------
function Module:StartSyncLoop()
    EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. "Broadcast_Sync_Initial")
    EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. "Broadcast_Sync_Loop")

    if not IsUnitGrouped("player") then return end

    -- INDIVIDUAL OFFSET.. GROUP INDEX * 5
    local groupIndex = GetGroupIndexByUnitTag("player") or 1
    local initialDelayMs = groupIndex * 5000

    EVENT_MANAGER:RegisterForUpdate(CC.NAME .. "Broadcast_Sync_Initial", initialDelayMs, function()
        EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. "Broadcast_Sync_Initial")
        self:SendSyncReply()

        EVENT_MANAGER:RegisterForUpdate(CC.NAME .. "Broadcast_Sync_Loop", 60000, function()
            self:SendSyncReply()
        end)
    end)
end

----------------------------------------------------------------------------------------------------
-- SEND REQUEST (PING GROUP)
----------------------------------------------------------------------------------------------------
function Module:SendSyncRequest(isManualRequest, isForced)
    if not isManualRequest then
        local currentTime = GetGameTimeMilliseconds()
        if not isForced and (currentTime - self.lastRequestTime) < 60000 then
            return
        end
        self.lastRequestTime = currentTime
    end

    if self.isReceivingSync then
        if isManualRequest then CC.Debug("Still receiving..") end
        return
    end

    for _, GroupMember in pairs(CC.GroupData) do
        GroupMember.pingMs = 0
    end

    local playerZoneId = CC.GetCleanZoneId()
    local slayerSide = CC.SlayerAssistant:GetSideIdFromZoneId(playerZoneId) or 0
    local slayerSet  = CC.GetPlayerSetStatus("SLAYER")

    local arkasisSide = CC.ArkasisAssistant:GetSideIdFromZoneId(playerZoneId) or 0
    local arkasisSet  = CC.GetPlayerSetStatus("ARKASIS")

    local RX = CC.IsRaidlead() and 1 or 0
    local RY = (slayerSide * 10) + slayerSet
    local RZ = (arkasisSide * 10) + arkasisSet

    self:UpdateAddonUsers("player", 0, CC.IsRaidlead(), RY, RZ)

    if not IsUnitGrouped("player") then
        if isManualRequest then
            d(string.format("%s %s", CC.CHAT, CC.ColorString("Permission denied. Not in a group.", "RD")))
        end
        return
    end
    if not self.Handler or not self.Handler:IsFinalized() then return end

    self.requestStartTime = GetGameTimeMilliseconds()
    self.isReceivingSync = true
    self.isManualRequest = (isManualRequest == true)

    if isManualRequest then CC.Debug("Ping request sent. Receiving..") end

    EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. "Broadcast_Sync_Request_Timeout")
    EVENT_MANAGER:RegisterForUpdate(CC.NAME .. "Broadcast_Sync_Request_Timeout", 5000, function()
        EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. "Broadcast_Sync_Request_Timeout")
        if self.isReceivingSync then
            self.requestStartTime = 0
            self.isReceivingSync = false
            CC.DisplayStatus:Update()
            if self.isManualRequest then CC.Debug("Ping request end!") end
        end
    end)

    local strIsManualRequest, strIsForced = tostring(isManualRequest), tostring(isForced)
    self:DebugSync(string.format("SendSyncRequest(%s, %s)", strIsManualRequest, strIsForced))
    self:Send({ ID = LUT.SYNC_REQUEST, TX = 0, TY = 0, TZ = 0, RX = RX, RY = RY, RZ = RZ })

    -- START RING
    self:StartSyncLoop()
end

----------------------------------------------------------------------------------------------------
-- SEND REQUEST (VERSION CHECK)
----------------------------------------------------------------------------------------------------
function Module:SendVersionRequest()
    self.isReceivingVersion = true

    -- RESET VERSIONS
    for _, GroupMember in pairs(CC.GroupData) do
        GroupMember.version = 0
    end

    -- SET OWN VERSION
    local playerName = GetUnitDisplayName("player")
    CC.GroupData[playerName] = CC.GroupData[playerName] or {}
    CC.GroupData[playerName].version = CC.ADDONVERSION or 0
    CC.GroupData[playerName].isAddonUser = true

    d(string.format("%s Version request sent.", CC.CHAT))
    d(string.format("%s Your version: %04d", CC.CHAT, CC.ADDONVERSION or 0))

    if not IsUnitGrouped("player") then
        self.isReceivingVersion = false
        return
    end

    if not self.Handler or not self.Handler:IsFinalized() then return end

    EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. "Broadcast_Version_Request_Timeout")
    EVENT_MANAGER:RegisterForUpdate(CC.NAME .. "Broadcast_Version_Request_Timeout", 5000, function()
        EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. "Broadcast_Version_Request_Timeout")
        self.isReceivingVersion = false
    end)

    self:Send({ ID = LUT.VERSION_REQUEST, TX = 0, TY = 0, TZ = 0, RX = 0, RY = 0, RZ = 0 })
end

----------------------------------------------------------------------------------------------------
-- PRINT PING REPLY TO CHAT
----------------------------------------------------------------------------------------------------
function Module:PrintReply(unitTag, currentPing, isRaidlead, slayerEnc, arkasisEnc)
    if not self.isReceivingSync then return end
    if not unitTag or unitTag == "" then return end

    local displayName = GetUnitDisplayName(unitTag)
    local playerLink = CC.GetPlayerLinkFromDisplayName(displayName) or displayName
    local leadText = isRaidlead and " |cFFDF00RL|r" or ""
    local pingMs = (currentPing and currentPing >= 0) and math.floor(currentPing) or 0

    local extraInfo = ""
        local slayerStr = ""
        local arkasisStr = ""

    -- SLAYER DECODE
    if slayerEnc then
        local sideId = math.floor(slayerEnc / 10)
        local slayerColorHex = CC.GetHexColorFromArray(CC.SlayerAssistant.SV.ColorNone) or "|cBFBFBF"
        local slayerLetter = "?"

        if sideId == CC.SlayerAssistant.SIDE_LEFT then
            slayerLetter = "L"
            slayerColorHex = CC.GetHexColorFromArray(CC.SlayerAssistant.SV.ColorLeft)
        elseif sideId == CC.SlayerAssistant.SIDE_RIGHT then
            slayerLetter = "R"
            slayerColorHex = CC.GetHexColorFromArray(CC.SlayerAssistant.SV.ColorRight)
        end
    slayerStr = string.format("%s%s|r", slayerColorHex, slayerLetter)
    end

    -- ARKASIS DECODE
    if arkasisEnc then
        local sideId = math.floor(arkasisEnc / 10)
        local arkasisLetter = "?"
        local arkasisColorHex = CC.GetHexColorFromArray(CC.ArkasisAssistant.SV.ColorNone) or "|cBFBFBF"

        if sideId == CC.ArkasisAssistant.SIDE_1 then
            arkasisLetter = "1"
            arkasisColorHex = CC.ArkasisAssistant.SV.enableGameAoeFriendlyColor and CC.GetHexColorFromArray(CC.GetGameAoeFriendlyColor()) or CC.GetHexColorFromArray(CC.ArkasisAssistant.SV.Color)
        elseif sideId == CC.ArkasisAssistant.SIDE_2 then
            arkasisLetter = "2"
            arkasisColorHex = CC.ArkasisAssistant.SV.enableGameAoeFriendlyColor and CC.GetHexColorFromArray(CC.GetGameAoeFriendlyColor()) or CC.GetHexColorFromArray(CC.ArkasisAssistant.SV.Color)
        elseif sideId == CC.ArkasisAssistant.SIDE_3 then
            arkasisLetter = "3"
            arkasisColorHex = CC.ArkasisAssistant.SV.enableGameAoeFriendlyColor and CC.GetHexColorFromArray(CC.GetGameAoeFriendlyColor()) or CC.GetHexColorFromArray(CC.ArkasisAssistant.SV.Color)
        end
        arkasisStr = string.format("%s%s|r", arkasisColorHex, arkasisLetter)
    end

    if slayerStr ~= "" and arkasisStr ~= "" then
        extraInfo = string.format(" - %s / %s", slayerStr, arkasisStr)
    end

    d(string.format("%s Ping: %s%s (%d ms)%s", CC.CHAT, playerLink, leadText, pingMs, extraInfo))
end

----------------------------------------------------------------------------------------------------
-- REGISTER SLASH COMMANDS
----------------------------------------------------------------------------------------------------
SLASH_COMMANDS["/cc_ping"] = function()
    Module:SendSyncRequest(true, true)
end

SLASH_COMMANDS["/cc_version"] = function()
    Module:SendVersionRequest()
end

SLASH_COMMANDS["/cc_debug_ondata"] = function()
    Module.SV.enableDebugOnData = not Module.SV.enableDebugOnData
    if Module.SV.enableDebugOnData then
        d(CC.CHAT .. " |c00FF00Debug [OnData] enabled.|r")
    else
        d(CC.CHAT .. " |cFF0000Debug [OnData] disabled.|r")
    end
end

----------------------------------------------------------------------------------------------------
-- REGISTER MODULE
----------------------------------------------------------------------------------------------------
CC[Module.name] = Module
table.insert(CC.Modules, Module)