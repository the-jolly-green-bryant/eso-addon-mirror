local CC = CombatCoordination
local LUT = CC.LUT.SLAYER_ASSISTANT

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name      = "SlayerAssistant",
    menuName  = "SLAYER ASSISTANT",
    iconPath  = "/esoui/art/icons/ability_buff_major_slayer.dds",
    menuLayer = 0,

    GroupChoices = { GetUnitDisplayName("player") },
    GroupValues = { "player" },
    menuTargetUnitTag = "player",
    menuTargetSideId  = 0,

    TEXTURE_INNER_BASE   = "/textures/letter_query.dds",
    TEXTURE_OUTLINE_BASE = "/textures/circle_32_clean.dds",
    TEXTURE_DOME_BASE    = "/textures/arc_32_clean.dds",

    TEXTURE_CHOICES = { "Circle / Arc 16", "Circle / Arc 32", "Circle / Arc 48" },
    TEXTURE_VALUES  = { "/textures/circle_16_clean.dds", "/textures/circle_32_clean.dds", "/textures/circle_48_clean.dds" },

    TextureCoupling = {
        ["/textures/circle_16_clean.dds"] = "/textures/arc_16_clean.dds",
        ["/textures/circle_32_clean.dds"] = "/textures/arc_32_clean.dds",
        ["/textures/circle_48_clean.dds"] = "/textures/arc_48_clean.dds",
    },

    SIDE_NONE  = 0,
    SIDE_LEFT  = 1,
    SIDE_RIGHT = 2,

    SET_STATUS_NONE = 0,

    VISIBILITY_VISIBLE = 1,
    VISIBILITY_MUTED   = 2,
    VISIBILITY_HIDDEN  = 3,

    TrackedSlayers = {},

    Broadcast = {
        LUT.SLAYER_TRIGGER,
        LUT.ASSIGNMENT_REQUEST,
        LUT.ASSIGNMENT_TARGETED,
    },

    Default = {
        visibilitySideSelf = 1, -- 1 = VISIBILITY_VISIBLE
        visibilitySideOther = 2, -- 2 = VISIBILITY_MUTED

        ColorNone  = { 0.75, 0.75, 0.75, 0.75 },
        ColorLeft  = { 1,    0.25, 0.25, 0.75 },
        ColorRight = { 0,    0.5,  1,    0.75 },
        ColorFlash = { 1,    1,    1,    0.75 },

        --/script CombatCoordination.SlayerAssistant.SV.textureDome = "/textures/arc_32_clean.dds"
        --/script CombatCoordination.SlayerAssistant.SV.width = 500
        --/script CombatCoordination.SlayerAssistant.SV.height = 500
        textureDome = "/textures/arc_32_clean.dds",
        textureOutline = "/textures/circle_32_clean.dds",
        innerSizePercent = 60,
        width = 500, height = 500,
        durationMs = 5000,
        AssignmentByZone = {},

        enableDebug = false,
    },
    ---@type table|any
    SV = {},
}

----------------------------------------------------------------------------------------------------
-- DEBUG
----------------------------------------------------------------------------------------------------
function Module:Debug(message)
    if not message then return end
    if not self.SV.enableDebug then return end
    d("|cFF7F00[CC " .. self.name .. " Debug]|r " .. tostring(message))
end

----------------------------------------------------------------------------------------------------
-- SET NAME, SIDE NAME, ZONE NAME
----------------------------------------------------------------------------------------------------
function Module:GetSetNameFromStatusId(statusId)
    if statusId == 1 then return "WM" end
    if statusId == 2 then return "MA" end
    if statusId == 3 then return "ROJO" end
    return "N/A"
end

function Module:GetSideNameFromSideId(sideId)
    if sideId == self.SIDE_LEFT then  return CC.GetHexColorFromArray(self.SV.ColorLeft) ..  "Left|r" end
    if sideId == self.SIDE_RIGHT then return CC.GetHexColorFromArray(self.SV.ColorRight) .. "Right|r" end
    return                                   CC.GetHexColorFromArray(self.SV.ColorNone) ..  "None|r"
end

function Module:GetZoneNameFromZoneId(zoneId)
    return CC.TrialZones[zoneId] or "General"
end

----------------------------------------------------------------------------------------------------
-- BROADCAST WRAPPER
----------------------------------------------------------------------------------------------------
function Module:BroadcastMessage(message, RX, RY, RZ, TX, TY, TZ)
    if not message then return end

    local Data = { ID = message, TX = TX or 0, TY = TY or 0, TZ = TZ or 0, RX = RX or 0, RY = RY or 0, RZ = RZ or 0 }

    if not IsUnitGrouped("player") then
        self:HandleBroadcast("player", Data)
        return
    end

    CC.Broadcast:Send(Data)
end

----------------------------------------------------------------------------------------------------
-- NOTIFCATION
----------------------------------------------------------------------------------------------------
function Module:PlayNotification(timeSec)
    local zoneId = CC.GetCurrentTrialZone()
    local sideId = self:GetSideIdFromZoneId(zoneId)

    CC.DisplayNotification:TriggerSlayer(timeSec, sideId)
end

function Module:GetSideIdFromZoneId(zoneId)
    local targetZone = CC.GetCleanZoneId(zoneId)
    return self.SV.AssignmentByZone[targetZone] or self.SIDE_NONE
end

----------------------------------------------------------------------------------------------------
-- GET TEXTURE PATH FOR SIDEID
----------------------------------------------------------------------------------------------------
function Module:GetTextureFromSideId(texturePath, sideId)
    if not texturePath then return "" end

    local base = string.gsub(texturePath, "_query.dds", "")
    base = string.gsub(base, "_l%.dds", "")
    base = string.gsub(base, "_r%.dds", "")

    if sideId == self.SIDE_LEFT then return base .. "_l.dds" end
    if sideId == self.SIDE_RIGHT then return base .. "_r.dds" end
    return base .. "_query.dds"
end

----------------------------------------------------------------------------------------------------
-- LAM2 PREVIEW
----------------------------------------------------------------------------------------------------
function Module:UpdatePreview()
    local Preview = CC.Menu.Previews[self.name]
    if not Preview or not Preview.Outline or not Preview.Inner then return end

    local zoneId = self.menuSelectedZone or 0
    local sideId = self:GetSideIdFromZoneId(zoneId)

    local Color = (sideId == self.SIDE_RIGHT) and self.SV.ColorRight or (sideId == self.SIDE_LEFT) and self.SV.ColorLeft or self.SV.ColorNone
    local textureOutline = self.TextureCoupling[self.SV.textureOutline] and self.SV.textureOutline or self.TEXTURE_OUTLINE_BASE

    Preview.Outline:SetColor(unpack(Color or {1, 1, 1, 1}))
    Preview.Outline:SetTexture(CC.NAME .. textureOutline)

    local innerSize = 128 * (self.SV.innerSizePercent / 100)
    Preview.Inner:SetDimensions(innerSize, innerSize)
    Preview.Inner:SetColor(unpack(Color or {1, 1, 1, 1}))
    Preview.Inner:SetTexture(CC.NAME .. self:GetTextureFromSideId(self.TEXTURE_INNER_BASE, sideId))
end

----------------------------------------------------------------------------------------------------
-- ASSIGN POSITION
----------------------------------------------------------------------------------------------------
function Module:AssignPlayerSide(sideId, targetZoneId, isSilent)
    -- SPECIFIC OR CURRENT ZONE?
    local zoneId = CC.GetCleanZoneId(targetZoneId)

    if self.SV.AssignmentByZone[zoneId] ~= sideId then
        self.SV.AssignmentByZone[zoneId] = sideId
        local activeZoneId = CC.GetCleanZoneId()

        if zoneId == activeZoneId then
            CC.Broadcast:BroadcastStatusUpdate()
        end

        if not isSilent then
            local sideName = self:GetSideNameFromSideId(sideId)
            local zoneName = self:GetZoneNameFromZoneId(zoneId)
            d(string.format("%s Assignment confirmed. Zone: [%s] - Position: %s", CC.CHAT, zoneName, sideName))
        end

        -- REFRESH PANEL
        if CC.DisplayPanel.SV.isVisible then
            CC.DisplayPanel:UpdateData()
        end
    end

    if CC_SlayerAssistant_Dropdown_SavedSide then
        CC_SlayerAssistant_Dropdown_SavedSide:UpdateValue()
    end
    self:UpdatePreview()
end

----------------------------------------------------------------------------------------------------
-- ASK GRP TO ASSIGN POS (DIALOG)
----------------------------------------------------------------------------------------------------
function Module:SendAssignmentRequest()
    if not CC.IsRaidlead() then
        d(string.format("%s %s", CC.CHAT, CC.ColorString("Permission denied. Raidlead status required.", "RD")))
        return
    end

    d(string.format("%s Slayer assignment request transmitted.", CC.CHAT))

    -- RX = 1 (MY ZONE FLAG BECAUSE WHY NOT)
    self:BroadcastMessage(LUT.ASSIGNMENT_REQUEST, 1, 0, 0)
end
SLASH_COMMANDS["/cc_slayer_assignment"] = function() CC.SlayerAssistant:SendAssignmentRequest() end

----------------------------------------------------------------------------------------------------
-- SEND TARGETED ASSIGNMENT
----------------------------------------------------------------------------------------------------
function Module:SendTargetedAssignment(unitTag, sideId)
    if not CC.IsRaidlead() then
        d(string.format("%s %s", CC.CHAT, CC.ColorString("Permission denied. Raidlead status required.", "RD")))
        return
    end

    -- FIND TARGET INDEX
    local targetGroupIndex = 0
    if IsUnitGrouped("player") then
        targetGroupIndex = GetGroupIndexByUnitTag(unitTag)
    end

    if not targetGroupIndex or targetGroupIndex < 0 then return end

    local TX, TY, TZ = targetGroupIndex, targetGroupIndex, targetGroupIndex

    local targetZoneId = self.menuSelectedZone or 0
    local RX = (targetZoneId == 0) and 1 or (CC.ZoneSyncMap[targetZoneId] or 1)

    local targetName = GetUnitDisplayName(unitTag) or unitTag
    local playerLink = CC.GetPlayerLinkFromDisplayName(targetName) or targetName
    local sideName = self:GetSideNameFromSideId(sideId)
    local zoneName = self:GetZoneNameFromZoneId(targetZoneId)

    d(string.format("%s Assignment for %s - New: %s for [%s]", CC.CHAT, playerLink, sideName, zoneName))

    self:BroadcastMessage(LUT.ASSIGNMENT_TARGETED, RX, sideId, 0, TX, TY, TZ)
end

----------------------------------------------------------------------------------------------------
-- TRIGGER SLAYER
----------------------------------------------------------------------------------------------------
function Module:SlayerTrigger(isManual, customTimeSec)
    if isManual and not CC.IsRaidlead() then
        d(string.format("%s %s", CC.CHAT, CC.ColorString("Permission denied. Raidlead status required.", "RD")))
        return
    end

    local currentTime = GetGameTimeMilliseconds()
    local isRunning = (self.activeTriggerEndTime and self.activeTriggerEndTime > currentTime)

    -- ENCODE DUR
    local timeSec = customTimeSec or (isRunning and 0 or (self.SV.durationMs / 1000))
    local timeEnc = math.floor((timeSec * 10) + 0.5)

    if isManual and self.SV.enableDebug then
        if timeSec == 0 then
            d(string.format("%s Slayer countdown stopped.", CC.CHAT))
        else
            d(string.format("%s Slayer countdown started.", CC.CHAT))
        end
    end

    self:BroadcastMessage(LUT.SLAYER_TRIGGER, 0, 0, timeEnc)
end

----------------------------------------------------------------------------------------------------
-- SLASH COMMAND FOR SLAYER TRIGGER
----------------------------------------------------------------------------------------------------
SLASH_COMMANDS["/cc_slayer"] = function(arg)
    local time = tonumber(arg)
    if time then
        time = math.max(0, math.min(15, time))
    end
    CC.SlayerAssistant:SlayerTrigger(true, time)
end

----------------------------------------------------------------------------------------------------
-- DELETE OUTLINE AND INNER SHAPE
----------------------------------------------------------------------------------------------------
function Module:RemoveSlayerEffect(unitTag, isInstant)
    local displayName = GetUnitDisplayName(unitTag) or unitTag
    local trackingKey = "SlayerAssistant_" .. tostring(displayName)

    local function RemoveTrackedEffect(key)
        local Data = CC.DisplayEffect.EffectTimers[key]
        if Data and Data.effectId then
            if isInstant then
                local Effect = CC.DisplayEffect.TrackedEffects[Data.effectId]
                if Effect then
                    if not Effect.Data then Effect.Data = {} end -- ITS NIL AFTER RECYCLING
                    Effect.Data.animationEnd = 0
                end
            end
            CC.DisplayEffect:RemoveTrackedEffect(Data.effectId)
        end
    end

    RemoveTrackedEffect(trackingKey .. "_Dome")
    RemoveTrackedEffect(trackingKey .. "_Outline")
    RemoveTrackedEffect(trackingKey .. "_Inner")
end

----------------------------------------------------------------------------------------------------
-- DRAW SLAYER (OUTLINE, DOME + LETTER)
----------------------------------------------------------------------------------------------------
function Module:DrawSlayerEffect(unitTag, sideId, customDurationMs)
    if not DoesUnitExist(unitTag) then
        self:Debug(string.format("DrawSlayerEffect aborted - Unit does not exist: %s", unitTag))
        return
    end

    local zoneId, TX, TY, TZ = GetUnitRawWorldPosition(unitTag)
    local RX = -(math.pi / 2) -- GROUND
    if not (TX and TY and TZ) then return end

    local playerSideId = self:GetSideIdFromZoneId(zoneId)
    local isPlayerSide = (sideId == playerSideId)

    if playerSideId ~= self.SIDE_NONE then
        if isPlayerSide then
            -- DELAYED SYNC
            if CC.DisplayNotification.slayerEndTime > 0 then
                CC.DisplayNotification.slayerTargetName = GetUnitDisplayName(unitTag)
                CC.DisplayNotification.slayerSideId = sideId
                CC.DisplayNotification:UpdateTick()
            end

            if self.SV.visibilitySideSelf == self.VISIBILITY_HIDDEN then return end
        else
            if self.SV.visibilitySideOther == self.VISIBILITY_HIDDEN then return end
        end
    end

    local isEquippedLate = customDurationMs and customDurationMs < self.SV.durationMs

    -- VALID DATA; REMOVE OLD
    self:RemoveSlayerEffect(unitTag, isEquippedLate)

    local currentTime = GetGameTimeMilliseconds()

    local ID = LUT.SLAYER_TRIGGER
    local displayName = GetUnitDisplayName(unitTag) or unitTag
    local trackingKey = "SlayerAssistant_" .. tostring(displayName)

    local durationMs = customDurationMs or self.SV.durationMs
    local animationMs = CC.DisplayEffect.SV.animationMs

    -- WHEN LATE
    local startScaleOutline = isEquippedLate and 1 or 0.5
    local startScaleInner   = isEquippedLate and 1 or 0
    local startScaleDome    = isEquippedLate and 1 or 0.5
    local animationStartMs  = isEquippedLate and animationMs or durationMs / 2

    -- SIZES AND TEXTURES
    local widthDome = self.SV.width
    local heightDome = self.SV.height
    local widthOutline = self.SV.width
    local heightOutline = self.SV.height
    local sizeInner = widthOutline * (self.SV.innerSizePercent / 100)

    -- COUPLED TEX FOR DOME
    local textureOutline = self.TextureCoupling[self.SV.textureOutline] and self.SV.textureOutline or self.TEXTURE_OUTLINE_BASE
    local textureDome    = self.TextureCoupling[textureOutline] or self.TEXTURE_DOME_BASE
    local textureInner   = self:GetTextureFromSideId(self.TEXTURE_INNER_BASE, sideId)

    -- BASE COLOR ASSIGNED SIDE
    local BaseColor = (sideId == self.SIDE_LEFT) and self.SV.ColorLeft or (sideId == self.SIDE_RIGHT) and self.SV.ColorRight or self.SV.ColorNone
    local Color

    local shouldMute = false
    if playerSideId ~= self.SIDE_NONE then
        if isPlayerSide and self.SV.visibilitySideSelf == self.VISIBILITY_MUTED then
            shouldMute = true
        elseif not isPlayerSide and self.SV.visibilitySideOther == self.VISIBILITY_MUTED then
            shouldMute = true
        end
    end

    if shouldMute then
        Color = {0.5, 0.5, 0.5, 0.75}
    else
        Color = BaseColor
    end

    local ColorEnd   = { Color[1] or 1, Color[2] or 1, Color[3] or 1, Color[4] or 1 }
    local ColorStart = { ColorEnd[1] / 2, ColorEnd[2] / 2, ColorEnd[3] / 2, 0 }
    local ColorFlash = self.SV.ColorFlash

    -- DELETE GHOST.. IF THERE IS ONE?
    for ghostTag, Effects in pairs(self.TrackedSlayers) do
        if currentTime > Effects.endTime then
            self.TrackedSlayers[ghostTag] = nil
        end
    end

    -- DRAW OUTLINE
    local outlineId = CC.DisplayEffect:Draw3DEffect(
    {
        ID = ID .. "_Outline",
        drawLevel = 1,

        TX = TX, RX = RX, FX = false,
        TY = TY, RY = 0,  FY = true,
        TZ = TZ, RZ = 0,  FZ = false,

        startScale = startScaleOutline,
        endScale = 1,

        width = widthOutline, height = heightOutline,
        texture = textureOutline,

        durationMs  = durationMs,

        animationStartMs = animationStartMs,
        animationEndMs = animationMs,

        ColorStart = ColorStart,
        ColorEnd   = ColorEnd,

        ColorFlash = ColorFlash,
        unitTag    = unitTag,
    })

    -- DRAW DOME
    local domeId = CC.DisplayEffect:Draw3DEffect(
    {
        ID = ID .. "_Dome",
        drawLevel = 3,

        TX = TX, RX = 0, FX = false,
        TY = TY, RY = 0, FY = false,
        TZ = TZ, RZ = 0, FZ = false,

        offsetTY = heightDome / 2,

        rotateY = (sideId == self.SIDE_LEFT) and (-30) or (sideId == self.SIDE_RIGHT) and (30) or 30,

        startScale = startScaleDome,
        endScale = 1,

        width = widthDome, height = heightDome,
        texture = textureDome,

        durationMs  = durationMs,

        animationStartMs = animationStartMs,
        animationEndMs = 0, --  DOME INSTANT FADE

        ColorStart = ColorStart,
        ColorEnd   = ColorEnd,

        ColorFlash = ColorFlash,
        unitTag    = unitTag,
    })

    -- DRAW INNER LETTER
    local innerId = CC.DisplayEffect:Draw3DEffect(
    {
        ID = ID .. "_Inner",
        drawLevel = 2,

        TX = TX, RX = RX, FX = false,
        TY = TY, RY = 0,  FY = true,
        TZ = TZ, RZ = 0,  FZ = false,

        offsetTY = 5, -- PLUS 5CM

        startScale = startScaleInner,
        endScale = 1,

        width = sizeInner, height = sizeInner,
        texture = textureInner,

        durationMs  = durationMs,

        animationStartMs = animationStartMs,
        animationEndMs = animationMs,

        ColorStart = ColorStart,
        ColorEnd   = ColorEnd,

        ColorFlash = ColorFlash,
        unitTag    = unitTag,
    })

    CC.DisplayEffect.EffectTimers[trackingKey .. "_Dome"]    = { currentTime = currentTime, effectId = domeId }
    CC.DisplayEffect.EffectTimers[trackingKey .. "_Outline"] = { currentTime = currentTime, effectId = outlineId }
    CC.DisplayEffect.EffectTimers[trackingKey .. "_Inner"]   = { currentTime = currentTime, effectId = innerId }

    self.TrackedSlayers[displayName] = { startTime = currentTime, endTime = currentTime + durationMs }
end

----------------------------------------------------------------------------------------------------
-- LATE EQUIP DRAWING CHECK (TRIGGERED BY BROADCAST)
----------------------------------------------------------------------------------------------------
function Module:CheckLateDraw(unitTag)
    local currentTime = GetGameTimeMilliseconds()
    if self.activeTriggerEndTime and currentTime < self.activeTriggerEndTime then
        local displayName = GetUnitDisplayName(unitTag)
        if not displayName then return end

        local User = CC.UserData[displayName]
        if User and User.SlayerAssistant then
            local isEquipped = User.SlayerAssistant.isEquipped
            local RY = User.SlayerAssistant.sideId
            local targetZoneId = User.SlayerAssistant.zoneId
            local playerZoneId = CC.GetCleanZoneId()

            if isEquipped ~= self.SET_STATUS_NONE and targetZoneId == playerZoneId then
                local remainingTimeMs = self.activeTriggerEndTime - currentTime
                self:DrawSlayerEffect(unitTag, RY, remainingTimeMs)
            else
                self:RemoveSlayerEffect(unitTag)
            end
        end
    end
end

----------------------------------------------------------------------------------------------------
-- BROADCAST INCOMING
----------------------------------------------------------------------------------------------------
function Module:HandleBroadcast(unitTag, Data)
    if not DoesUnitExist(unitTag) then
        self:Debug(string.format("HandleBroadcast aborted - Unit does not exist: %s", unitTag))
        return
    end

    local displayName = GetUnitDisplayName(unitTag)
    local playerZoneId = CC.GetCleanZoneId()

    ----------------------------------------------------------------------------------------------------
    -- INCOMING TRIGGER SLAYER
    ----------------------------------------------------------------------------------------------------
    if Data.ID == LUT.SLAYER_TRIGGER then

        -- CANCEL RZ == 0
        if Data.RZ == 0 then
            self.activeTriggerEndTime = 0
            self:PlayNotification(0)

            for trackedTag, _ in pairs(self.TrackedSlayers) do
                self:RemoveSlayerEffect(trackedTag)
            end
            ZO_ClearTable(self.TrackedSlayers)

            if CC.DisplayPanel.SV.isVisible then CC.DisplayPanel:UpdateData() end
            return
        end

        -- DECODE DURATION (E.G. 55 / 10 = 5.5S)
        local timeSec = (Data.RZ and Data.RZ > 0) and (Data.RZ / 10) or (self.SV.durationMs / 1000)
        local customDurationMs = timeSec * 1000

        -- END TIME
        local currentTime = GetGameTimeMilliseconds()
        self.activeTriggerEndTime = currentTime + customDurationMs

        self:PlayNotification(timeSec)
        if CC.DisplayPanel.SV.isVisible then CC.DisplayPanel:UpdateData() end

        local groupSize = GetGroupSize() or 0

        -- WHEN SOLO.. DEBUG
        if groupSize == 0 then
            if CC.GetPlayerSetStatus("SLAYER") ~= self.SET_STATUS_NONE then
                local groupSideId = self:GetSideIdFromZoneId(playerZoneId)
                self:DrawSlayerEffect("player", groupSideId, customDurationMs)
            end
        else
            for i = 1, groupSize do
                local groupTag = "group" .. i
                if DoesUnitExist(groupTag) then
                    local groupDisplayName = GetUnitDisplayName(groupTag)
                    local groupSideId = nil
                    local groupZoneId = 0

                    if AreUnitsEqual("player", groupTag) then
                        if CC.GetPlayerSetStatus("SLAYER") ~= self.SET_STATUS_NONE then
                            groupSideId = self:GetSideIdFromZoneId(playerZoneId)
                            groupZoneId = playerZoneId
                        end
                    else
                        if CC.UserData[groupDisplayName] and CC.UserData[groupDisplayName].SlayerAssistant then
                            -- CHECK IF SET IS ACTUALLY EQUIPPED
                            if CC.UserData[groupDisplayName].SlayerAssistant.isEquipped ~= self.SET_STATUS_NONE then
                                groupSideId = CC.UserData[groupDisplayName].SlayerAssistant.sideId
                                groupZoneId = CC.UserData[groupDisplayName].SlayerAssistant.zoneId
                            end
                        end
                    end

                    if groupSideId ~= nil and groupZoneId == playerZoneId then
                        self:DrawSlayerEffect(groupTag, groupSideId, customDurationMs)
                    end
                end
            end
        end
    end

    ----------------------------------------------------------------------------------------------------
    -- INC SYNC REQUEST (OPEN DIALOG)
    ----------------------------------------------------------------------------------------------------
    if Data.ID == LUT.ASSIGNMENT_REQUEST then
        local zoneId = CC.GetZoneIdFromFlag(Data.RX, unitTag)
        local zoneName = self:GetZoneNameFromZoneId(zoneId)
        local sideId = self:GetSideIdFromZoneId(zoneId)
        local sideName = self:GetSideNameFromSideId(sideId)

        CC.DisplayDialog:RequestSlayer(zoneId, zoneName, sideName)
    end

    ----------------------------------------------------------------------------------------------------
    -- TARGETED ASSIGNMENT
    ----------------------------------------------------------------------------------------------------
    if Data.ID == LUT.ASSIGNMENT_TARGETED then
        -- DECODE TRACKING TARGET (TX == TY == TZ)
        local targetIndex = -1
        if Data.TX == Data.TY and Data.TY == Data.TZ then
            targetIndex = Data.TX
        end

        -- GET OWN GROUP INDEX (0 = SOLO FALLBACK?)
        local playerGroupIndex = 0
        if IsUnitGrouped("player") then
            playerGroupIndex = GetGroupIndexByUnitTag("player")
        end

        -- IS THIS MESSAGE FOR ME?
        if targetIndex == playerGroupIndex and targetIndex >= 0 then
            local targetZoneId = CC.GetZoneIdFromFlag(Data.RX, unitTag)

            local senderName = GetUnitDisplayName(unitTag) or "Unknown"
            local playerLink = CC.GetPlayerLinkFromDisplayName(senderName) or senderName
            local sideName = self:GetSideNameFromSideId(Data.RY)
            local zoneName = self:GetZoneNameFromZoneId(targetZoneId)

            d(string.format("%s Assignment from %s - New: %s for [%s]", CC.CHAT, playerLink, sideName, zoneName))

            local isSilent = true
            self:AssignPlayerSide(Data.RY, targetZoneId, isSilent)
        end
    end
end

----------------------------------------------------------------------------------------------------
-- CONTEXT MENU
----------------------------------------------------------------------------------------------------
function Module:OnContextMenu(Data)
    if not LibCustomMenu or not Data or not Data.displayName then return end
    if not CC.IsRaidlead() then return end
    if not IsUnitGrouped("player") then return end

    local unitTag = nil
    local targetName = Data.displayName

    for i = 1, GetGroupSize() do
        local tag = GetGroupUnitTagByIndex(i)
        if GetUnitDisplayName(tag) == targetName or GetRawUnitName(tag) == targetName then
            unitTag = tag
            break
        end
    end

    if not unitTag and (GetUnitDisplayName("player") == targetName or GetRawUnitName("player") == targetName) then
        unitTag = "player"
    end

    if not unitTag then return end

    local menuIcon = string.format("|t%d:%d:/esoui/art/icons/ability_buff_major_slayer.dds|t ", CC.SIZE_ICON_LCM, CC.SIZE_ICON_LCM)
    AddCustomSubMenuItem(menuIcon .. CC.ColorString("[CC] SlayerAssistant", "tier2"), {
        {
            label = "Assign Side: Left",
            callback = function() self:SendTargetedAssignment(unitTag, self.SIDE_LEFT) end,
        },
        {
            label = "Assign Side: Right",
            callback = function() self:SendTargetedAssignment(unitTag, self.SIDE_RIGHT) end,
        }
    })
end

----------------------------------------------------------------------------------------------------
-- CUSTOM ENABLE / DISABLE
----------------------------------------------------------------------------------------------------
function Module:CustomEnable()
    if IsUnitGrouped("player") then
        zo_callLater(function()
            CC.Broadcast:SendPingRequest(false)
        end, 2500)
    end

    -- YEAH YEAH I KNOW.. LIBCUSTOMMENU IS IN THE DEPENDENCIES. BUT I MIGHT CHANGE THAT.
    if LibCustomMenu then
        LibCustomMenu:RegisterGroupListContextMenu(function(Data) self:OnContextMenu(Data) end, LibCustomMenu.CATEGORY_LATE)
    end
end

function Module:CustomDisable()
    for _, User in pairs(CC.UserData) do
        User.SlayerAssistant = nil
    end
end

----------------------------------------------------------------------------------------------------
-- LAM2 MENU
----------------------------------------------------------------------------------------------------
function Module:GetMenuOptions()
    if not self.menuSelectedZone then
        local zoneId = CC.GetCurrentTrialZone()
        self.menuSelectedZone = zoneId
    end

    local VISIBILITY_CHOICES_SELF = { "Visible" }
    local VISIBILITY_VALUES_SELF  = { self.VISIBILITY_VISIBLE, }

    local VISIBILITY_CHOICES_OTHER = { "Visible", "Muted", "Hidden" }
    local VISIBILITY_VALUES_OTHER  = { self.VISIBILITY_VISIBLE, self.VISIBILITY_MUTED, self.VISIBILITY_HIDDEN, }

    local TRIAL_ZONE_CHOICES = { "General", }
    local TRIAL_ZONE_VALUES = { 0, }

    -- FOR DEBUG / DEV ONLY
    if GetUnitDisplayName("player") == CC.AUTHOR then
        VISIBILITY_CHOICES_SELF = { "Visible", "Muted [Dev]", "Hidden [Dev]", }
        VISIBILITY_VALUES_SELF  = { self.VISIBILITY_VISIBLE, self.VISIBILITY_MUTED, self.VISIBILITY_HIDDEN, }
    end

    local SortedZones = {}
    for zoneId, zoneName in pairs(CC.TrialZones) do table.insert(SortedZones, { zoneId = zoneId, zoneName = zoneName }) end
    table.sort(SortedZones, function(a, b) return a.zoneName < b.zoneName end)

    for _, Zone in ipairs(SortedZones) do
        table.insert(TRIAL_ZONE_CHOICES, Zone.zoneName)
        table.insert(TRIAL_ZONE_VALUES, Zone.zoneId)
    end

    local menuIcon = string.format("|t%d:%d:%s|t", CC.SIZE_ICON_LAM_SM, CC.SIZE_ICON_LAM_SM, self.iconPath)

    return {
        type = "submenu",
        name = string.format("%s %s %s", menuIcon, CC.ColorString(self.menuName, "tier2"), CC.ColorString("[LGB]", "GN")),
        controls = {
            {
                type = "description",
                text = "Slayer Assistant for assigned positioning in trials.",
                width = "full",
            },
            ----------------------------------------------------------------------------------------------------
            -- ASSIGNMENT & STATUS
            ----------------------------------------------------------------------------------------------------
            { type = "header", name = CC.ColorString("ASSIGNMENT FOR YOURSELF", "tier3") },
            {
                type = "dropdown",
                name = "Edit Settings For Specific Instance: ",
                choices = TRIAL_ZONE_CHOICES,
                choicesValues = TRIAL_ZONE_VALUES,
                getFunc = function() return self.menuSelectedZone end,
                setFunc = function(value)
                    self.menuSelectedZone = value
                    self:UpdatePreview()
                end,
                disabled = function() return not CC.SV.enableAddon end,
            },
            {
                type = "dropdown",
                name = function()
                    local zoneId = self.menuSelectedZone or 0
                    local zoneName = self:GetZoneNameFromZoneId(zoneId)
                    return string.format("Your saved position for %s:", CC.ColorString(string.format("[%s]", zoneName), "tier3"))
                end,
                choices = { "None / Unassigned", "Slayer: Left", "Slayer: Right" },
                choicesValues = { self.SIDE_NONE, self.SIDE_LEFT, self.SIDE_RIGHT },
                getFunc = function()
                    return self:GetSideIdFromZoneId(self.menuSelectedZone or 0)
                end,
                setFunc = function(value)
                    local zoneId = self.menuSelectedZone or 0
                    self:AssignPlayerSide(value, zoneId)
                end,
                reference = "CC_SlayerAssistant_Dropdown_SavedSide",
                disabled = function() return not CC.SV.enableAddon end,
            },

            ----------------------------------------------------------------------------------------------------
            -- VISUALS & COLOR
            ----------------------------------------------------------------------------------------------------
            { type = "header", name = CC.ColorString("VISUALS & COLOR FOR YOURSELF", "tier3") },
            {
                type = "dropdown",
                name = "Visibility: Your Side",
                choices = VISIBILITY_CHOICES_SELF,
                choicesValues = VISIBILITY_VALUES_SELF,
                getFunc = function() return self.SV.visibilitySideSelf end,
                setFunc = function(value) self.SV.visibilitySideSelf = value end,
                default = self.Default.visibilitySideSelf,
                disabled = function() return not CC.SV.enableAddon end,
            },
            {
                type = "dropdown",
                name = "Visibility: Other Side",
                choices = VISIBILITY_CHOICES_OTHER,
                choicesValues = VISIBILITY_VALUES_OTHER,
                getFunc = function() return self.SV.visibilitySideOther end,
                setFunc = function(value) self.SV.visibilitySideOther = value end,
                default = self.Default.visibilitySideOther,
                disabled = function() return not CC.SV.enableAddon end,
            },
            -- {
            --     type = "checkbox",
            --     name = "Enable Game AOE Color",
            --     getFunc = function() return self.SV.enableGameAoeFriendlyColor end,
            --     setFunc = function(value) self.SV.enableGameAoeFriendlyColor = value end,
            --     default = self.Default.enableGameAoeFriendlyColor,
            --     disabled = function() return not CC.SV.enableAddon end,
            -- },
            {
                type = "colorpicker",
                name = "Color: LEFT",
                getFunc = function() return unpack(self.SV.ColorLeft) end,
                setFunc = function(r, g, b, a)
                    self.SV.ColorLeft = {r, g, b, a}
                    self:UpdatePreview()
                end,
                default = CC.GetRgbaFromArray(self.Default.ColorLeft),
                disabled = function() return not CC.SV.enableAddon end,
            },
            {
                type = "colorpicker",
                name = "Color: RIGHT",
                getFunc = function() return unpack(self.SV.ColorRight) end,
                setFunc = function(r, g, b, a)
                    self.SV.ColorRight = {r, g, b, a}
                    self:UpdatePreview()
                end,
                default = CC.GetRgbaFromArray(self.Default.ColorRight),
                disabled = function() return not CC.SV.enableAddon end,
            },
            {
                type = "dropdown",
                name = "Texture Size / Style",
                choices = self.TEXTURE_CHOICES,
                choicesValues = self.TEXTURE_VALUES,
                getFunc = function() return self.SV.textureOutline end,
                setFunc = function(value)
                    self.SV.textureOutline = value
                    self.SV.textureDome = self.TextureCoupling[value] or self.TEXTURE_DOME_BASE
                    self:UpdatePreview()
                end,
                default = self.Default.textureOutline,
                disabled = function() return not CC.SV.enableAddon end,
            },
            -- {
            --     type = "slider",
            --     name = "Inner Texture Size [%]",
            --     tooltip = "Scales the inner letter relative to the outline.",
            --     min = 50, max = 100, step = 2.5, decimals = 1,
            --     getFunc = function() return self.SV.innerSizePercent end,
            --     setFunc = function(value)
            --         self.SV.innerSizePercent = value
            --         UpdatePreview()
            --     end,
            --     default = self.Default.innerSizePercent,
            --     disabled = function() return not CC.SV.enableAddon end,
            -- },
            {
                type = "custom",
                createFunc = function(CustomControl)
                    CustomControl:SetHeight(128)
                    -- OUTLINE
                    local ControlOutline = WINDOW_MANAGER:CreateControl(nil, CustomControl, CT_TEXTURE)
                    ControlOutline:SetAnchor(CENTER, CustomControl, CENTER)
                    ControlOutline:SetDimensions(128, 128)

                    -- INNER LETTER
                    local ControlInner = WINDOW_MANAGER:CreateControl(nil, CustomControl, CT_TEXTURE)
                    ControlInner:SetAnchor(CENTER, CustomControl, CENTER)

                    CC.Menu.Previews[self.name] = { Outline = ControlOutline, Inner = ControlInner }
                    self:UpdatePreview()
                end,
                minHeight = 128,
                width = "full",
            },

            ----------------------------------------------------------------------------------------------------
            -- TARGETED ASSIGNMENT
            ----------------------------------------------------------------------------------------------------
            { type = "header", name = CC.ColorString("RAIDLEAD ONLY: (RE-) ASSIGN MEMBER", "tier3") },
            {
                type = "description",
                text = CC.ColorString("Tip:", "tier2") .. " You can also assign group members directly via the group window by right-clicking their name and using the context menu.",
                width = "full",
            },
            {
                type = "slider",
                name = "Slayer Countdown [sec]",
                min = 0, max = 15, step = 1, decimals = 0,
                getFunc = function() return self.SV.durationMs / 1000 end,
                setFunc = function(value)
                    self.SV.durationMs = value * 1000
                end,
                default = self.Default.durationMs / 1000,
                disabled = function() return not CC.SV.enableAddon or not CC.IsRaidlead() end,
            },
            {
                type = "divider",
            },
            {
                type = "dropdown",
                name = "Choose Group Member",
                choices = self.GroupChoices,
                choicesValues = self.GroupValues,
                getFunc = function() return self.menuTargetUnitTag end,
                setFunc = function(value) self.menuTargetUnitTag = value end,
                reference = "CC_SlayerAssistant_Dropdown_GroupMember",
                disabled = function() return not CC.SV.enableAddon or not CC.IsRaidlead() end,
            },
            {
                type = "dropdown",
                name = "Choose Side to Assign",
                choices = { "None / Unassigned", "Slayer: Left", "Slayer: Right" },
                choicesValues = { self.SIDE_NONE, self.SIDE_LEFT, self.SIDE_RIGHT },
                getFunc = function() return self.menuTargetSideId end,
                setFunc = function(value) self.menuTargetSideId = value end,
                disabled = function() return not CC.SV.enableAddon or not CC.IsRaidlead() end,
            },
            {
                type = "description",
                text = CC.ColorString("Please Note:", "tier2") .. " Forced assignments will refer to YOUR current zone.",
                width = "full",
                disabled = function() return not CC.SV.enableAddon or not CC.IsRaidlead() end,
            },
            {
                type = "button",
                name = "REFRESH LIST",
                func = function()
                    ZO_ClearTable(self.GroupChoices)
                    ZO_ClearTable(self.GroupValues)

                    table.insert(self.GroupChoices, GetUnitDisplayName("player"))
                    table.insert(self.GroupValues, "player")

                    if GetGroupSize() > 0 then
                        for i = 1, GetGroupSize() do
                            local unitTag = "group" .. i
                            if not AreUnitsEqual("player", unitTag) then
                                local displayName = GetUnitDisplayName(unitTag)
                                if displayName and displayName ~= "" then
                                    table.insert(self.GroupChoices, displayName)
                                    table.insert(self.GroupValues, unitTag)
                                end
                            end
                        end
                    end

                    self.menuTargetUnitTag = "player"

                    if CC_SlayerAssistant_Dropdown_GroupMember then
                        CC_SlayerAssistant_Dropdown_GroupMember:UpdateChoices(self.GroupChoices, self.GroupValues)
                        CC_SlayerAssistant_Dropdown_GroupMember:UpdateValue()
                    end
                end,
                width = "half",
                disabled = function() return not CC.SV.enableAddon or not CC.IsRaidlead() end,
            },
            {
                type = "button",
                name = "FORCE / SAVE",
                func = function()
                    if self.menuTargetUnitTag and self.menuTargetSideId then
                        self:SendTargetedAssignment(self.menuTargetUnitTag, self.menuTargetSideId)
                    end
                end,
                width = "half",
                disabled = function() return not CC.SV.enableAddon or not CC.IsRaidlead() end,
            },
            {
                type = "divider",
            },
            {
                type = "checkbox",
                name = "Enable Debug",
                getFunc = function() return self.SV.enableDebug end,
                setFunc = function(value) self.SV.enableDebug = value end,
                default = self.Default.enableDebug,
                disabled = function() return not CC.SV.enableAddon end,
            },
        },
    }
end

CC[Module.name] = Module
table.insert(CC.Modules, Module)