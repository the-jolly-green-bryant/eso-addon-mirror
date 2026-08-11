local CC = CombatCoordination
local LUT = CC.LUT.ARKASIS_ASSISTANT

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name      = "ArkasisAssistant",
    menuName  = "ARKASIS ASSISTANT",
    iconPath  = "/esoui/art/icons/consumable_potion_012_type_002.dds",
    menuLayer = 0,

    GroupChoices = { GetUnitDisplayName("player") },
    GroupValues = { "player" },
    menuTargetUnitTag = "player",
    menuTargetSideId  = 0,

    TEXTURE_INNER_BASE   = "/textures/letter_query.dds",
    TEXTURE_OUTLINE_BASE = "/textures/circle_32_clean.dds",

    TEXTURE_CHOICES = { "Circle 16", "Circle 32", "Circle 48" },
    TEXTURE_VALUES  = { "/textures/circle_16_clean.dds", "/textures/circle_32_clean.dds", "/textures/circle_48_clean.dds" },

    SIDE_NONE  = 0,
    SIDE_1     = 1,
    SIDE_2     = 2,
    SIDE_3     = 3,

    SET_STATUS_NONE = 0,

    isReceivingAssignment = false,
    isReceivingStatus = false,

    TrackedArkasis = {},

    Broadcast = {
        LUT.ARKASIS_TRIGGER,
        LUT.ASSIGNMENT_REQUEST,
        LUT.ASSIGNMENT_TARGETED,
    },

    Default = {
        enableGameAoeFriendlyColor = false,

        Color      = { 1,    0.875, 0,    0.75 },
        ColorNone  = { 0.75, 0.75,  0.75, 0.75 },
        ColorFlash = { 1,    1,     1,    0.75 },

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
    if statusId == 1 then return "ARK" end
    return "N/A"
end

function Module:GetSideNameFromSideId(sideId)
    local colorHex = self.SV.enableGameAoeFriendlyColor and CC.GetHexColorFromArray(CC.GetGameAoeFriendlyColor()) or CC.GetHexColorFromArray(self.SV.Color)
    if sideId == self.SIDE_1 then return colorHex .. "Stack 1|r" end
    if sideId == self.SIDE_2 then return colorHex .. "Stack 2|r" end
    if sideId == self.SIDE_3 then return colorHex .. "Stack 3|r" end
    return CC.GetHexColorFromArray(self.SV.ColorNone) .. "None|r"
end

function Module:GetZoneNameFromZoneId(zoneId)
    return CC.TrialZones[zoneId] or "General"
end

----------------------------------------------------------------------------------------------------
-- BROADCAST WRAP
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
-- NOTIFICATION
----------------------------------------------------------------------------------------------------
function Module:PlayNotification(timeSec)
    local zoneId = CC.GetCurrentTrialZone()
    local sideId = self:GetSideIdFromZoneId(zoneId)

    CC.DisplayNotification:TriggerArkasis(timeSec, sideId)
end

----------------------------------------------------------------------------------------------------
-- GET ACTIVE SIDE FOR CURRENT ZONE
----------------------------------------------------------------------------------------------------
function Module:GetSideIdFromZoneId(zoneId)
    local targetZone = CC.GetCleanZoneId(zoneId)
    return self.SV.AssignmentByZone[targetZone] or self.SIDE_NONE
end

----------------------------------------------------------------------------------------------------
-- GET TEXTURE PATH FOR SIDEID
----------------------------------------------------------------------------------------------------
function Module:GetTextureFromSideId(sideId)
    if sideId == self.SIDE_1 then return "/textures/letter_1.dds" end
    if sideId == self.SIDE_2 then return "/textures/letter_2.dds" end
    if sideId == self.SIDE_3 then return "/textures/letter_3.dds" end
    return self.TEXTURE_INNER_BASE
end

----------------------------------------------------------------------------------------------------
-- UPDATE LAM2 PREVIEW
----------------------------------------------------------------------------------------------------
function Module:UpdatePreview()
    local Preview = CC.Menu.Previews[self.name]
    if not Preview or not Preview.Outline or not Preview.Inner then return end

    local zoneId = self.menuSelectedZone or 0
    local sideId = self:GetSideIdFromZoneId(zoneId)

    local Color = self.SV.enableGameAoeFriendlyColor and CC.GetGameAoeFriendlyColor() or ((sideId == self.SIDE_NONE) and self.SV.ColorNone or self.SV.Color)

    local textureOutline = self.SV.textureOutline or self.TEXTURE_OUTLINE_BASE
    Preview.Outline:SetColor(unpack(Color or {1, 1, 1, 1}))
    Preview.Outline:SetTexture(CC.NAME .. textureOutline)

    local innerSize = 128 * (self.SV.innerSizePercent / 100)
    Preview.Inner:SetDimensions(innerSize, innerSize)
    Preview.Inner:SetColor(unpack(Color or {1, 1, 1, 1}))
    Preview.Inner:SetTexture(CC.NAME .. self:GetTextureFromSideId(sideId))
end

----------------------------------------------------------------------------------------------------
-- ASSIGN POS
----------------------------------------------------------------------------------------------------
function Module:AssignPlayerSide(sideId, targetZoneId, isSilent)
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
            d(string.format("%s Assignment confirmed. Zone: [%s] - Stack: %s", CC.CHAT, zoneName, sideName))
        end

        if CC.DisplayPanel.SV.isVisible then
            CC.DisplayPanel:UpdateData()
        end
    end

    if CC_ArkasisAssistant_Dropdown_SavedSide then
        CC_ArkasisAssistant_Dropdown_SavedSide:UpdateValue()
    end
    self:UpdatePreview()
end

----------------------------------------------------------------------------------------------------
-- ASK GROUP TO ASSIGN POSITION
----------------------------------------------------------------------------------------------------
function Module:SendAssignmentRequest()
    if not CC.IsRaidlead() then
        d(string.format("%s %s", CC.CHAT, CC.ColorString("Permission denied. Raidlead status required.", "RD")))
        return
    end

    d(string.format("%s Arkasis assignment request transmitted.", CC.CHAT))

    -- RX = 1 (MY ZONE FLAG BECAUSE WHY NOT)
    self:BroadcastMessage(LUT.ASSIGNMENT_REQUEST, 1, 0, 0)
end
SLASH_COMMANDS["/cc_arkasis_assignment"] = function() CC.ArkasisAssistant:SendAssignmentRequest() end

----------------------------------------------------------------------------------------------------
-- SEND TARGETED ASSIGNMENT
----------------------------------------------------------------------------------------------------
function Module:SendTargetedAssignment(unitTag, sideId)
    if not CC.IsRaidlead() then
        d(string.format("%s %s", CC.CHAT, CC.ColorString("Permission denied. Raidlead status required.", "RD")))
        return
    end

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
-- TRIGGER ARKASIS
----------------------------------------------------------------------------------------------------
function Module:ArkasisTrigger(isManual, customTimeSec)
    if isManual and not CC.IsRaidlead() then
        d(string.format("%s %s", CC.CHAT, CC.ColorString("Permission denied. Raidlead status required.", "RD")))
        return
    end

    local currentTime = GetGameTimeMilliseconds()
    local isRunning = (self.activeTriggerEndTime and self.activeTriggerEndTime > currentTime)

    local timeSec = customTimeSec or (isRunning and 0 or (self.SV.durationMs / 1000))
    local timeEnc = math.floor((timeSec * 10) + 0.5)

    if isManual and self.SV.enableDebug then
        if timeSec == 0 then
            d(string.format("%s Arkasis countdown stopped.", CC.CHAT))
        else
            d(string.format("%s Arkasis countdown started.", CC.CHAT))
        end
    end

    self:BroadcastMessage(LUT.ARKASIS_TRIGGER, 0, 0, timeEnc)
end

----------------------------------------------------------------------------------------------------
-- SLASH COMMAND FOR TRIGGER
----------------------------------------------------------------------------------------------------
SLASH_COMMANDS["/cc_arkasis"] = function(arg)
    local time = tonumber(arg)
    if time then
        time = math.max(0, math.min(15, time))
    end
    CC.ArkasisAssistant:ArkasisTrigger(true, time)
end

----------------------------------------------------------------------------------------------------
-- DELETE OUTLINE AND INNER SHAPE
----------------------------------------------------------------------------------------------------
function Module:RemoveArkasisEffect(unitTag, isInstant)
    local displayName = GetUnitDisplayName(unitTag) or unitTag
    local trackingKey = "ArkasisAssistant_" .. tostring(displayName)

    local function RemoveTrackedEffect(key)
        local Data = CC.DisplayEffect.EffectTimers[key]
        if Data and Data.effectId then
            if isInstant then
                local Effect = CC.DisplayEffect.TrackedEffects[Data.effectId]
                if Effect then
                    if not Effect.Data then Effect.Data = {} end
                    Effect.Data.animationEnd = 0
                end
            end
            CC.DisplayEffect:RemoveTrackedEffect(Data.effectId)
        end
    end

    RemoveTrackedEffect(trackingKey .. "_Outline")
    RemoveTrackedEffect(trackingKey .. "_Inner")
end

----------------------------------------------------------------------------------------------------
-- DRAW ARKASIS SHAPE
----------------------------------------------------------------------------------------------------
function Module:DrawArkasisEffect(unitTag, sideId, customDurationMs)
    if not DoesUnitExist(unitTag) then
        self:Debug(string.format("DrawArkasisEffect aborted - Unit does not exist: %s", unitTag))
        return
    end

    local zoneId, TX, TY, TZ = GetUnitRawWorldPosition(unitTag)
    local RX = -(math.pi / 2)
    if not (TX and TY and TZ) then return end

    local playerSideId = self:GetSideIdFromZoneId(zoneId)

    -- ONLY SEE OWN TEAM
    if playerSideId ~= self.SIDE_NONE and sideId ~= playerSideId then return end

    local isEquippedLate = customDurationMs and customDurationMs < self.SV.durationMs
    self:RemoveArkasisEffect(unitTag, isEquippedLate)

    local currentTime = GetGameTimeMilliseconds()

    local ID = LUT.ARKASIS_TRIGGER
    local displayName = GetUnitDisplayName(unitTag) or unitTag
    local trackingKey = "ArkasisAssistant_" .. tostring(displayName)

    local durationMs = customDurationMs or self.SV.durationMs
    local animationMs = CC.DisplayEffect.SV.animationMs

    local startScaleOutline = isEquippedLate and 1 or 0.5
    local startScaleInner   = isEquippedLate and 1 or 0
    local animationStartMs  = isEquippedLate and animationMs or durationMs / 2

    local widthOutline  = self.SV.width
    local heightOutline = self.SV.height
    local sizeInner     = widthOutline * (self.SV.innerSizePercent / 100)

    local textureOutline = self.SV.textureOutline or self.TEXTURE_OUTLINE_BASE
    local textureInner   = self:GetTextureFromSideId(sideId)

    local BaseColor = self.SV.enableGameAoeFriendlyColor and CC.GetGameAoeFriendlyColor() or ((sideId == self.SIDE_NONE) and self.SV.ColorNone or self.SV.Color)

    local ColorEnd   = { BaseColor[1] or 1, BaseColor[2] or 1, BaseColor[3] or 1, BaseColor[4] or 1 }
    local ColorStart = { ColorEnd[1] / 2, ColorEnd[2] / 2, ColorEnd[3] / 2, 0 }
    local ColorFlash = self.SV.ColorFlash

    for ghostTag, Effects in pairs(self.TrackedArkasis) do
        if currentTime > Effects.endTime then
            self.TrackedArkasis[ghostTag] = nil
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

    -- DRAW INNER LETTER
    local innerId = CC.DisplayEffect:Draw3DEffect(
    {
        ID = ID .. "_Inner",
        drawLevel = 2,

        TX = TX, RX = RX, FX = false,
        TY = TY, RY = 0,  FY = true,
        TZ = TZ, RZ = 0,  FZ = false,

        offsetTY = 5, -- 5CM HIGHER

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

    CC.DisplayEffect.EffectTimers[trackingKey .. "_Outline"] = { currentTime = currentTime, effectId = outlineId }
    CC.DisplayEffect.EffectTimers[trackingKey .. "_Inner"]   = { currentTime = currentTime, effectId = innerId }

    self.TrackedArkasis[displayName] = { startTime = currentTime, endTime = currentTime + durationMs }
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
        if User and User.ArkasisAssistant then
            local isEquipped = User.ArkasisAssistant.isEquipped
            local RY = User.ArkasisAssistant.sideId
            local targetZoneId = User.ArkasisAssistant.zoneId
            local playerZoneId = CC.GetCleanZoneId()

            if isEquipped ~= self.SET_STATUS_NONE and targetZoneId == playerZoneId then
                local remainingTimeMs = self.activeTriggerEndTime - currentTime
                self:DrawArkasisEffect(unitTag, RY, remainingTimeMs)
            else
                self:RemoveArkasisEffect(unitTag)
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

    local playerZoneId = CC.GetCleanZoneId()

    ----------------------------------------------------------------------------------------------------
    -- INCOMING TRIGGER ARKASIS
    ----------------------------------------------------------------------------------------------------
    if Data.ID == LUT.ARKASIS_TRIGGER then

        if Data.RZ == 0 then
            self.activeTriggerEndTime = 0
            self:PlayNotification(0)

            for trackedTag, _ in pairs(self.TrackedArkasis) do
                self:RemoveArkasisEffect(trackedTag)
            end
            ZO_ClearTable(self.TrackedArkasis)

            if CC.DisplayPanel.SV.isVisible then CC.DisplayPanel:UpdateData() end
            return
        end

        local timeSec = (Data.RZ and Data.RZ > 0) and (Data.RZ / 10) or (self.SV.durationMs / 1000)
        local customDurationMs = timeSec * 1000

        local currentTime = GetGameTimeMilliseconds()
        self.activeTriggerEndTime = currentTime + customDurationMs

        self:PlayNotification(timeSec)
        if CC.DisplayPanel.SV.isVisible then CC.DisplayPanel:UpdateData() end

        local groupSize = GetGroupSize() or 0

        if groupSize == 0 then
            if CC.GetPlayerSetStatus("ARKASIS") ~= self.SET_STATUS_NONE then
                local groupSideId = self:GetSideIdFromZoneId(playerZoneId)
                self:DrawArkasisEffect("player", groupSideId, customDurationMs)
            end
        else
            for i = 1, groupSize do
                local groupTag = "group" .. i
                if DoesUnitExist(groupTag) then
                    local groupDisplayName = GetUnitDisplayName(groupTag)
                    local groupSideId = nil
                    local groupZoneId = 0

                    if AreUnitsEqual("player", groupTag) then
                        if CC.GetPlayerSetStatus("ARKASIS") ~= self.SET_STATUS_NONE then
                            groupSideId = self:GetSideIdFromZoneId(playerZoneId)
                            groupZoneId = playerZoneId
                        end
                    else
                        if CC.UserData[groupDisplayName] and CC.UserData[groupDisplayName].ArkasisAssistant then
                            if CC.UserData[groupDisplayName].ArkasisAssistant.isEquipped ~= self.SET_STATUS_NONE then
                                groupSideId = CC.UserData[groupDisplayName].ArkasisAssistant.sideId
                                groupZoneId = CC.UserData[groupDisplayName].ArkasisAssistant.zoneId
                            end
                        end
                    end

                    if groupSideId ~= nil and groupZoneId == playerZoneId then
                        self:DrawArkasisEffect(groupTag, groupSideId, customDurationMs)
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

        CC.DisplayDialog:RequestArkasis(zoneId, zoneName, sideName)
    end

    ----------------------------------------------------------------------------------------------------
    -- TARGETED ASSIGNMENT
    ----------------------------------------------------------------------------------------------------
    if Data.ID == LUT.ASSIGNMENT_TARGETED then
        local targetIndex = -1
        if Data.TX == Data.TY and Data.TY == Data.TZ then
            targetIndex = Data.TX
        end

        local playerGroupIndex = 0
        if IsUnitGrouped("player") then
            playerGroupIndex = GetGroupIndexByUnitTag("player")
        end

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
-- CONTEXT MENU (LIBCUSTOMMENU)
----------------------------------------------------------------------------------------------------
function Module:OnContextMenu(Data)
    -- YEAH YEAH I KNOW.. LIBCUSTOMMENU IS IN THE DEPENDENCIES. BUT I MIGHT CHANGE THAT.
    if not LibCustomMenu or not Data or not Data.displayName then return end
    if not CC.IsRaidlead() and IsUnitGrouped("player") then return end

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

    local menuIcon = string.format("|t%d:%d:/esoui/art/icons/consumable_potion_012_type_002.dds|t ", CC.SIZE_ICON_LCM, CC.SIZE_ICON_LCM)
    AddCustomSubMenuItem(menuIcon .. CC.ColorString("[CC] ArkasisAssistant", "tier2"), {
        {
            label = "Assign Stack: 1",
            callback = function() self:SendTargetedAssignment(unitTag, self.SIDE_1) end,
        },
        {
            label = "Assign Stack: 2",
            callback = function() self:SendTargetedAssignment(unitTag, self.SIDE_2) end,
        },
        {
            label = "Assign Stack: 3",
            callback = function() self:SendTargetedAssignment(unitTag, self.SIDE_3) end,
        }
    })
end

---------------------------------------------------------------------------
-- CUSTOM ENABLE / DISABLE
---------------------------------------------------------------------------
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
        User.ArkasisAssistant = nil
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

    local TRIAL_ZONE_CHOICES = { "General", }
    local TRIAL_ZONE_VALUES = { 0, }

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
                text = "Arkasis Assistant for assigned positioning and stacking in trials.",
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
                    return string.format("Your saved stack for %s:", CC.ColorString(string.format("[%s]", zoneName), "tier3"))
                end,
                choices = { "None / Unassigned", "Stack 1", "Stack 2", "Stack 3" },
                choicesValues = { self.SIDE_NONE, self.SIDE_1, self.SIDE_2, self.SIDE_3 },
                getFunc = function()
                    return self:GetSideIdFromZoneId(self.menuSelectedZone or 0)
                end,
                setFunc = function(value)
                    local zoneId = self.menuSelectedZone or 0
                    self:AssignPlayerSide(value, zoneId)
                end,
                reference = "CC_ArkasisAssistant_Dropdown_SavedSide",
                disabled = function() return not CC.SV.enableAddon end,
            },

            ----------------------------------------------------------------------------------------------------
            -- VISUALS & COLOR
            ----------------------------------------------------------------------------------------------------
            { type = "header", name = CC.ColorString("VISUALS & COLOR FOR YOURSELF", "tier3") },
            {
                type = "checkbox",
                name = "Enable Game AOE Color",
                getFunc = function() return self.SV.enableGameAoeFriendlyColor end,
                setFunc = function(value)
                    self.SV.enableGameAoeFriendlyColor = value
                    self:UpdatePreview()
                end,
                default = self.Default.enableGameAoeFriendlyColor,
                disabled = function() return not CC.SV.enableAddon end,
            },
            {
                type = "colorpicker",
                name = "Color",
                getFunc = function() return unpack(self.SV.Color) end,
                setFunc = function(r, g, b, a)
                    self.SV.Color = {r, g, b, a}
                    self:UpdatePreview()
                end,
                default = CC.GetRgbaFromArray(self.Default.Color),
                disabled = function() return not CC.SV.enableAddon or self.SV.enableGameAoeFriendlyColor end,
            },
            {
                type = "dropdown",
                name = "Texture Size / Style",
                choices = self.TEXTURE_CHOICES,
                choicesValues = self.TEXTURE_VALUES,
                getFunc = function() return self.SV.textureOutline end,
                setFunc = function(value)
                    self.SV.textureOutline = value
                    self:UpdatePreview()
                end,
                default = self.Default.textureOutline,
                disabled = function() return not CC.SV.enableAddon end,
            },
            {
                type = "custom",
                createFunc = function(CustomControl)
                    CustomControl:SetHeight(128)
                    local ControlOutline = WINDOW_MANAGER:CreateControl(nil, CustomControl, CT_TEXTURE)
                    ControlOutline:SetAnchor(CENTER, CustomControl, CENTER)
                    ControlOutline:SetDimensions(128, 128)

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
                name = "Arkasis Countdown [sec]",
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
                reference = "CC_ArkasisAssistant_Dropdown_GroupMember",
                disabled = function() return not CC.SV.enableAddon or not CC.IsRaidlead() end,
            },
            {
                type = "dropdown",
                name = "Choose Stack to Assign",
                choices = { "None / Unassigned", "Stack 1", "Stack 2", "Stack 3" },
                choicesValues = { self.SIDE_NONE, self.SIDE_1, self.SIDE_2, self.SIDE_3 },
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

                    if CC_ArkasisAssistant_Dropdown_GroupMember then
                        CC_ArkasisAssistant_Dropdown_GroupMember:UpdateChoices(self.GroupChoices, self.GroupValues)
                        CC_ArkasisAssistant_Dropdown_GroupMember:UpdateValue()
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