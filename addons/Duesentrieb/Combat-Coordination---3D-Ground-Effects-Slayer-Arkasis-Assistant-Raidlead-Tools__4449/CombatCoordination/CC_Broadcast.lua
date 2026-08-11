local CC = CombatCoordination
local LUT = CC.LUT.SYNC

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name = "Broadcast",
    Handler = nil,
    CallbackModules = {},

    LutDataIn = {},
    LutDataOut = {},

    startTime = 0,
    timeoutMs = 5000,
    isReceiving = false,

    Default = { enableDebugOnData = false, },
    ---@type table|any
    SV = {},
}

----------------------------------------------------------------------------------------------------
-- CUSTOM ENABLE / DISABLE
----------------------------------------------------------------------------------------------------
function Module:CustomEnable()
    self:Initialize()
end

function Module:CustomDisable()
    self.isReceiving = false
    self.startTime = 0
end

----------------------------------------------------------------------------------------------------
-- TEST COMMAND / DEBUG
----------------------------------------------------------------------------------------------------
SLASH_COMMANDS["/cc_test"] = function()

    --local abilityId = 107141 -- OLORIME
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
function Module:BroadcastStatusUpdate()
    local playerZoneId = CC.GetCleanZoneId()

    local slayerSide = CC.SlayerAssistant:GetSideIdFromZoneId(playerZoneId) or 0
    local slayerSet  = CC.GetPlayerSetStatus("SLAYER")

    local arkasisSide = CC.ArkasisAssistant:GetSideIdFromZoneId(playerZoneId) or 0
    local arkasisSet  = CC.GetPlayerSetStatus("ARKASIS")

    local RX = CC.IsRaidlead() and 1 or 0
    local RY = (slayerSide * 10) + slayerSet
    local RZ = (arkasisSide * 10) + arkasisSet

    self:UpdateAddonUsers("player", 0, CC.IsRaidlead(), RY, RZ)

    if IsUnitGrouped("player") then
        self:Send({ ID = LUT.PING_REPLY, TX = 0, TY = 0, TZ = 0, RX = RX, RY = RY, RZ = RZ })
    end
end

----------------------------------------------------------------------------------------------------
-- HANDLE BROADCAST DATA
----------------------------------------------------------------------------------------------------
function Module:HandleSynchronization(unitTag, Data)
    if not CC.SV.enableAddon then return end

    local currentTime = GetGameTimeMilliseconds()
    local currentPing = nil

    local isPlayer = AreUnitsEqual(unitTag, "player")
    local isSenderRaidlead = (Data.RX == 1)

    local slayerEnc = Data.RY or 0
    local arkasisEnc = Data.RZ or 0

    -- CALC PING
    if self.isReceiving and self.startTime > 0 then
        currentPing = (currentTime - self.startTime)
        if not isPlayer then currentPing = currentPing / 2 end
    end

    -- INCOMING REQUEST -> SEND REPLY
    if Data.ID == LUT.PING_REQUEST and not isPlayer then
        self:UpdateAddonUsers(unitTag, nil, isSenderRaidlead, slayerEnc, arkasisEnc)

        local playerZoneId = CC.GetCleanZoneId()
        local slayerSide = CC.SlayerAssistant:GetSideIdFromZoneId(playerZoneId) or 0
        local slayerSet  = CC.GetPlayerSetStatus("SLAYER")

        local arkasisSide = CC.ArkasisAssistant:GetSideIdFromZoneId(playerZoneId) or 0
        local arkasisSet  = CC.GetPlayerSetStatus("ARKASIS")

        local playerRX = CC.IsRaidlead() and 1 or 0
        local playerRY = (slayerSide * 10) + slayerSet
        local playerRZ = (arkasisSide * 10) + arkasisSet

        self:Send({ ID = LUT.PING_REPLY, TX = 0, TY = 0, TZ = 0, RX = playerRX, RY = playerRY, RZ = playerRZ })
    end

    -- INCOMING REPLY OR SELF PING
    if Data.ID == LUT.PING_REPLY or (Data.ID == LUT.PING_REQUEST and isPlayer) then
        self:UpdateAddonUsers(unitTag, currentPing, isSenderRaidlead, slayerEnc, arkasisEnc)
        if self.isReceiving then
            self:PrintReply(unitTag, currentPing, isSenderRaidlead, slayerEnc, arkasisEnc)
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

    -- PING
    if Data.ID == LUT.PING_REPLY or Data.ID == LUT.PING_REQUEST then
        self:HandleSynchronization(unitTag, Data)
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
    local CallbackModule = self.CallbackModules[Data.ID]

    if CallbackModule and CallbackModule.HandleBroadcast then
        CallbackModule:HandleBroadcast(unitTag, Data)
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

    CC.UserData[displayName] = CC.UserData[displayName] or {}
    local User = CC.UserData[displayName]

    if currentPing ~= nil and currentPing >= 0 then
        User.ping = currentPing
    end

    if isRaidlead ~= nil then
        User.isRaidlead = isRaidlead
    end

    local targetZoneId = CC.GetCleanZoneId(GetUnitRawWorldPosition(unitTag))

    -- DECODE SLAYER
    if slayerEnc then
        local sideId = math.floor(slayerEnc / 10)
        local setId = slayerEnc % 10
        User.SlayerAssistant = User.SlayerAssistant or {}
        User.SlayerAssistant.sideId = sideId
        User.SlayerAssistant.isEquipped = setId
        User.SlayerAssistant.zoneId = targetZoneId
    end

    -- DECODE ARKASIS
    if arkasisEnc then
        local sideId = math.floor(arkasisEnc / 10)
        local setId = arkasisEnc % 10
        User.ArkasisAssistant = User.ArkasisAssistant or {}
        User.ArkasisAssistant.sideId = sideId
        User.ArkasisAssistant.isEquipped = setId
        User.ArkasisAssistant.zoneId = targetZoneId
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
-- SEND REQUEST (PING GROUP)
----------------------------------------------------------------------------------------------------
function Module:SendPingRequest(isManual)
    if self.isReceiving then
        if isManual then CC.Debug("Still receiving..") end
        return
    end

    -- RESET TO ZE ZE ZE .. ZERO
    for _, User in pairs(CC.UserData) do
        User.ping = 0
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

    if not IsUnitGrouped("player") and not isManual then return end
    if not self.Handler or not self.Handler:IsFinalized() then return end

    self.startTime = GetGameTimeMilliseconds()
    self.isReceiving = (isManual == true)

    if isManual then
        CC.Debug("Ping request sent. Receiving..")
    end

    local timerName = CC.NAME .. self.name .. "PING_REQUEST_TIMEOUT"
    EVENT_MANAGER:UnregisterForUpdate(timerName)
    EVENT_MANAGER:RegisterForUpdate(timerName, 5000, function()
        EVENT_MANAGER:UnregisterForUpdate(timerName)
        if self.isReceiving then
            self.startTime = 0
            self.isReceiving = false
            CC.DisplayStatus:Update()
            if isManual then CC.Debug("Ping request end!") end
        end
    end)

    self:Send({ ID = LUT.PING_REQUEST, TX = 0, TY = 0, TZ = 0, RX = RX, RY = RY, RZ = RZ })
end

----------------------------------------------------------------------------------------------------
-- PRINT PING REPLY TO CHAT
----------------------------------------------------------------------------------------------------
function Module:PrintReply(unitTag, currentPing, isRaidlead, slayerEnc, arkasisEnc)
    if not self.isReceiving then return end
    if not unitTag or unitTag == "" then return end

    local displayName = GetUnitDisplayName(unitTag)
    local playerLink = CC.GetPlayerLinkFromDisplayName(displayName) or displayName
    local leadText = isRaidlead and " |cFFDF00RL|r" or ""
    local ping = (currentPing and currentPing >= 0) and math.floor(currentPing) or 0

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

    d(string.format("%s Data received. Source: %s%s - Latency: %d ms%s", CC.CHAT, playerLink, leadText, ping, extraInfo))
end

----------------------------------------------------------------------------------------------------
-- REGISTER SLASH COMMANDS
----------------------------------------------------------------------------------------------------
SLASH_COMMANDS["/cc_ping"] = function()
    Module:SendPingRequest(true)
end

SLASH_COMMANDS["/cc_debug_ondata"] = function()
    Module.SV.enableDebugOnData = not Module.SV.enableDebugOnData
    if Module.SV.enableDebugOnData then
        d(CC.CHAT .. " |c00FF00Data debug enabled.|r")
    else
        d(CC.CHAT .. " |cFF0000Data debug disabled.|r")
    end
end

----------------------------------------------------------------------------------------------------
-- REGISTER MODULE
----------------------------------------------------------------------------------------------------
CC[Module.name] = Module
table.insert(CC.Modules, Module)