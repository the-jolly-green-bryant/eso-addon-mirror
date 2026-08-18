local CC = CombatCoordination
local LAM2 = LibAddonMenu2

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name      = "LaunchPad",
    menuName  = "LAUNCH PAD",
    iconPath  = "/esoui/art/icons/ability_dragonknight_029.dds",
    menuLayer = 0,

    isAiming = false,
    previewEffectId = nil,
    lastLoadedCategory = nil,

    TextureChoices = CC.CIRCLE_CHOICES,
    TextureValues  = CC.CIRCLE_VALUES,

    TriggerData = {
        ----------------------------------------------------------------------------------------------------
        -- PULL-TIMER 0 .. 15 (OG)
        ----------------------------------------------------------------------------------------------------
        [1] = { category = "Raidlead Tools", name = "Pull Timer Custom", shortName = "PULL", Color = { 1, 0.5, 0, 0.75 }, Action = function() CC.RaidleadTools:RequestPull() end },
        [2] = { category = "Raidlead Tools", name = "Pull Timer 3s", shortName = "PULL 3", Color = { 1, 0.5, 0, 0.75 }, Action = function() CC.RaidleadTools:RequestPull(3) end },
        [3] = { category = "Raidlead Tools", name = "Pull Timer 5s", shortName = "PULL 5", Color = { 1, 0.5, 0, 0.75 }, Action = function() CC.RaidleadTools:RequestPull(5) end },
        [4] = { category = "Raidlead Tools", name = "Pull Timer 10s", shortName = "PULL 10", Color = { 1, 0.5, 0, 0.75 }, Action = function() CC.RaidleadTools:RequestPull(10) end },

        ----------------------------------------------------------------------------------------------------
        -- SLAYER ASSISTANT 16 .. 31 (RD)
        ----------------------------------------------------------------------------------------------------
        [16] = { category = "Slayer Assistant", name = "Slayer Timer Custom", shortName = "SLAYER", Color = { 1, 0.1, 0.1, 0.75 }, Action = function() if CC.SlayerAssistant then CC.SlayerAssistant:SlayerTrigger(true) end end },
        [17] = { category = "Slayer Assistant", name = "Slayer Timer 3s", shortName = "SLAYER 3", Color = { 1, 0.1, 0.1, 0.75 }, Action = function() if CC.SlayerAssistant then CC.SlayerAssistant:SlayerTrigger(true, 3) end end },
        [18] = { category = "Slayer Assistant", name = "Slayer Timer 5s", shortName = "SLAYER 5", Color = { 1, 0.1, 0.1, 0.75 }, Action = function() if CC.SlayerAssistant then CC.SlayerAssistant:SlayerTrigger(true, 5) end end },

        -------------------------------------------------------------------------------------------------------
        -- ARKASIS ASSISTANT 32 .. 47 (YW)
        ----------------------------------------------------------------------------------------------------
        [32] = { category = "Arkasis Assistant", name = "Arkasis Timer Custom", shortName = "ARKASIS", Color = { 1, 0.875, 0, 0.75 }, Action = function() if CC.ArkasisAssistant then CC.ArkasisAssistant:ArkasisTrigger(true) end end },
        [33] = { category = "Arkasis Assistant", name = "Arkasis Timer 3s", shortName = "ARKASIS 3", Color = { 1, 0.875, 0, 0.75 }, Action = function() if CC.ArkasisAssistant then CC.ArkasisAssistant:ArkasisTrigger(true, 3) end end },
        [34] = { category = "Arkasis Assistant", name = "Arkasis Timer 5s", shortName = "ARKASIS 5", Color = { 1, 0.875, 0, 0.75 }, Action = function() if CC.ArkasisAssistant then CC.ArkasisAssistant:ArkasisTrigger(true, 5) end end },

        ----------------------------------------------------------------------------------------------------
        -- PREBUFF ASSISTANT 48 .. 63
        ----------------------------------------------------------------------------------------------------

        ----------------------------------------------------------------------------------------------------
        -- WIZARDS WARDROBE 512 .. 527
        ----------------------------------------------------------------------------------------------------
        [512] = { category = "Wizards Wardrobe", name = "WW Next Setup", shortName = "WW NEXT", Color = { 0, 1, 0.875, 0.75 }, Action = function() if WizardsWardrobe and WizardsWardrobe.LoadSetupAdjacent then WizardsWardrobe.LoadSetupAdjacent(1) end end },
        [513] = { category = "Wizards Wardrobe", name = "WW Previous Setup", shortName = "WW PREV", Color = { 0, 1, 0.875, 0.75 }, Action = function() if WizardsWardrobe and WizardsWardrobe.LoadSetupAdjacent then WizardsWardrobe.LoadSetupAdjacent(-1) end end },
        [514] = { category = "Wizards Wardrobe", name = "WW Reload Current", shortName = "WW RELOAD", Color = { 0, 1, 0.875, 0.75 }, Action = function() if WizardsWardrobe and WizardsWardrobe.LoadSetupAdjacent then WizardsWardrobe.LoadSetupAdjacent(0) end end },
        -- WW PREBUFF 528 .. 559
        [528] = { category = "Wizards Wardrobe", name = "WW Load Setup 1", shortName = "WW #1", Color = { 0, 1, 0.875, 0.75 }, Action = function() if WizardsWardrobe and WizardsWardrobe.LoadSetupCurrent then WizardsWardrobe.LoadSetupCurrent(1, false) end end },
        [529] = { category = "Wizards Wardrobe", name = "WW Load Setup 2", shortName = "WW #2", Color = { 0, 1, 0.875, 0.75 }, Action = function() if WizardsWardrobe and WizardsWardrobe.LoadSetupCurrent then WizardsWardrobe.LoadSetupCurrent(2, false) end end },
        [530] = { category = "Wizards Wardrobe", name = "WW Load Setup 3", shortName = "WW #3", Color = { 0, 1, 0.875, 0.75 }, Action = function() if WizardsWardrobe and WizardsWardrobe.LoadSetupCurrent then WizardsWardrobe.LoadSetupCurrent(3, false) end end },
        [531] = { category = "Wizards Wardrobe", name = "WW Load Setup 4", shortName = "WW #4", Color = { 0, 1, 0.875, 0.75 }, Action = function() if WizardsWardrobe and WizardsWardrobe.LoadSetupCurrent then WizardsWardrobe.LoadSetupCurrent(4, false) end end },
        [532] = { category = "Wizards Wardrobe", name = "WW Load Setup 5", shortName = "WW #5", Color = { 0, 1, 0.875, 0.75 }, Action = function() if WizardsWardrobe and WizardsWardrobe.LoadSetupCurrent then WizardsWardrobe.LoadSetupCurrent(5, false) end end },
        [533] = { category = "Wizards Wardrobe", name = "WW Load Setup 6", shortName = "WW #6", Color = { 0, 1, 0.875, 0.75 }, Action = function() if WizardsWardrobe and WizardsWardrobe.LoadSetupCurrent then WizardsWardrobe.LoadSetupCurrent(6, false) end end },
        [534] = { category = "Wizards Wardrobe", name = "WW Load Setup 7", shortName = "WW #7", Color = { 0, 1, 0.875, 0.75 }, Action = function() if WizardsWardrobe and WizardsWardrobe.LoadSetupCurrent then WizardsWardrobe.LoadSetupCurrent(7, false) end end },
        [535] = { category = "Wizards Wardrobe", name = "WW Load Setup 8", shortName = "WW #8", Color = { 0, 1, 0.875, 0.75 }, Action = function() if WizardsWardrobe and WizardsWardrobe.LoadSetupCurrent then WizardsWardrobe.LoadSetupCurrent(8, false) end end },
        [536] = { category = "Wizards Wardrobe", name = "WW Load Setup 9", shortName = "WW #9", Color = { 0, 1, 0.875, 0.75 }, Action = function() if WizardsWardrobe and WizardsWardrobe.LoadSetupCurrent then WizardsWardrobe.LoadSetupCurrent(9, false) end end },
        [537] = { category = "Wizards Wardrobe", name = "WW Load Setup 10", shortName = "WW #10", Color = { 0, 1, 0.875, 0.75 }, Action = function() if WizardsWardrobe and WizardsWardrobe.LoadSetupCurrent then WizardsWardrobe.LoadSetupCurrent(10, false) end end },
        [538] = { category = "Wizards Wardrobe", name = "WW Load Setup 11", shortName = "WW #11", Color = { 0, 1, 0.875, 0.75 }, Action = function() if WizardsWardrobe and WizardsWardrobe.LoadSetupCurrent then WizardsWardrobe.LoadSetupCurrent(11, false) end end },
        [539] = { category = "Wizards Wardrobe", name = "WW Load Setup 12", shortName = "WW #12", Color = { 0, 1, 0.875, 0.75 }, Action = function() if WizardsWardrobe and WizardsWardrobe.LoadSetupCurrent then WizardsWardrobe.LoadSetupCurrent(12, false) end end },
        [540] = { category = "Wizards Wardrobe", name = "WW Load Setup 13", shortName = "WW #13", Color = { 0, 1, 0.875, 0.75 }, Action = function() if WizardsWardrobe and WizardsWardrobe.LoadSetupCurrent then WizardsWardrobe.LoadSetupCurrent(13, false) end end },
        [541] = { category = "Wizards Wardrobe", name = "WW Load Setup 14", shortName = "WW #14", Color = { 0, 1, 0.875, 0.75 }, Action = function() if WizardsWardrobe and WizardsWardrobe.LoadSetupCurrent then WizardsWardrobe.LoadSetupCurrent(14, false) end end },
        [542] = { category = "Wizards Wardrobe", name = "WW Load Setup 15", shortName = "WW #15", Color = { 0, 1, 0.875, 0.75 }, Action = function() if WizardsWardrobe and WizardsWardrobe.LoadSetupCurrent then WizardsWardrobe.LoadSetupCurrent(15, false) end end },
        [543] = { category = "Wizards Wardrobe", name = "WW Load Setup 16", shortName = "WW #16", Color = { 0, 1, 0.875, 0.75 }, Action = function() if WizardsWardrobe and WizardsWardrobe.LoadSetupCurrent then WizardsWardrobe.LoadSetupCurrent(16, false) end end },
        [544] = { category = "Wizards Wardrobe", name = "WW Load Setup 17", shortName = "WW #17", Color = { 0, 1, 0.875, 0.75 }, Action = function() if WizardsWardrobe and WizardsWardrobe.LoadSetupCurrent then WizardsWardrobe.LoadSetupCurrent(17, false) end end },
        [545] = { category = "Wizards Wardrobe", name = "WW Load Setup 18", shortName = "WW #18", Color = { 0, 1, 0.875, 0.75 }, Action = function() if WizardsWardrobe and WizardsWardrobe.LoadSetupCurrent then WizardsWardrobe.LoadSetupCurrent(18, false) end end },
        [546] = { category = "Wizards Wardrobe", name = "WW Load Setup 19", shortName = "WW #19", Color = { 0, 1, 0.875, 0.75 }, Action = function() if WizardsWardrobe and WizardsWardrobe.LoadSetupCurrent then WizardsWardrobe.LoadSetupCurrent(19, false) end end },
        [547] = { category = "Wizards Wardrobe", name = "WW Load Setup 20", shortName = "WW #20", Color = { 0, 1, 0.875, 0.75 }, Action = function() if WizardsWardrobe and WizardsWardrobe.LoadSetupCurrent then WizardsWardrobe.LoadSetupCurrent(20, false) end end },
        [548] = { category = "Wizards Wardrobe", name = "WW Load Setup 21", shortName = "WW #21", Color = { 0, 1, 0.875, 0.75 }, Action = function() if WizardsWardrobe and WizardsWardrobe.LoadSetupCurrent then WizardsWardrobe.LoadSetupCurrent(21, false) end end },
        [549] = { category = "Wizards Wardrobe", name = "WW Load Setup 22", shortName = "WW #22", Color = { 0, 1, 0.875, 0.75 }, Action = function() if WizardsWardrobe and WizardsWardrobe.LoadSetupCurrent then WizardsWardrobe.LoadSetupCurrent(22, false) end end },
        [550] = { category = "Wizards Wardrobe", name = "WW Load Setup 23", shortName = "WW #23", Color = { 0, 1, 0.875, 0.75 }, Action = function() if WizardsWardrobe and WizardsWardrobe.LoadSetupCurrent then WizardsWardrobe.LoadSetupCurrent(23, false) end end },
        [551] = { category = "Wizards Wardrobe", name = "WW Load Setup 24", shortName = "WW #24", Color = { 0, 1, 0.875, 0.75 }, Action = function() if WizardsWardrobe and WizardsWardrobe.LoadSetupCurrent then WizardsWardrobe.LoadSetupCurrent(24, false) end end },
        [552] = { category = "Wizards Wardrobe", name = "WW Load Setup 25", shortName = "WW #25", Color = { 0, 1, 0.875, 0.75 }, Action = function() if WizardsWardrobe and WizardsWardrobe.LoadSetupCurrent then WizardsWardrobe.LoadSetupCurrent(25, false) end end },
        -- WW PREBUFF 560 .. 575
        [560] = { category = "Wizards Wardrobe", name = "WW Prebuff 1", shortName = "WW PB 1", Color = { 0, 1, 0.875, 0.75 }, Action = function() if WizardsWardrobe and WizardsWardrobe.prebuff and WizardsWardrobe.prebuff.Prebuff then WizardsWardrobe.prebuff.Prebuff(1) end end },
        [561] = { category = "Wizards Wardrobe", name = "WW Prebuff 2", shortName = "WW PB 2", Color = { 0, 1, 0.875, 0.75 }, Action = function() if WizardsWardrobe and WizardsWardrobe.prebuff and WizardsWardrobe.prebuff.Prebuff then WizardsWardrobe.prebuff.Prebuff(2) end end },
        [562] = { category = "Wizards Wardrobe", name = "WW Prebuff 3", shortName = "WW PB 3", Color = { 0, 1, 0.875, 0.75 }, Action = function() if WizardsWardrobe and WizardsWardrobe.prebuff and WizardsWardrobe.prebuff.Prebuff then WizardsWardrobe.prebuff.Prebuff(3) end end },
        [563] = { category = "Wizards Wardrobe", name = "WW Prebuff 4", shortName = "WW PB 4", Color = { 0, 1, 0.875, 0.75 }, Action = function() if WizardsWardrobe and WizardsWardrobe.prebuff and WizardsWardrobe.prebuff.Prebuff then WizardsWardrobe.prebuff.Prebuff(4) end end },
        [564] = { category = "Wizards Wardrobe", name = "WW Prebuff 5", shortName = "WW PB 5", Color = { 0, 1, 0.875, 0.75 }, Action = function() if WizardsWardrobe and WizardsWardrobe.prebuff and WizardsWardrobe.prebuff.Prebuff then WizardsWardrobe.prebuff.Prebuff(5) end end },
    },

    ActivePads = {},

    Default = {
        SavedPads = {},
        width = 300,
        height = 300,
        visibilityDistance = 100,

        enableDrawName = true,
        useStaticLabelColor = false,
        LabelColor = { 1, 1, 1, 1 },
        texture = "/textures/circle_cc.dds",
        offsetTY = 150,
        fontSize = 50,
        fontStyle = "$(BOLD_FONT)",
        fontWeight = "thick-outline",

        activeTrigger = 1,
    },
    ---@type table|any
    SV = {},
}

----------------------------------------------------------------------------------------------------
-- CUSTOM ENABLE / DISABLE
----------------------------------------------------------------------------------------------------
function Module:CustomEnable()
    self:LoadPadsForCurrentZone()
    self:StartTriggerLoop()
end

function Module:CustomDisable()
    self:ClearAllPads()
    self:CancelAiming()
    self:StopTriggerLoop()
end

----------------------------------------------------------------------------------------------------
-- LOAD PADS
----------------------------------------------------------------------------------------------------
function Module:LoadPadsForCurrentZone()
    self:ClearAllPads()

    local zoneId = GetUnitRawWorldPosition("player")
    if not zoneId or zoneId == 0 then return end
    if not self.SV.SavedPads[zoneId] then return end

    for index, PadData in ipairs(self.SV.SavedPads[zoneId]) do
        self:DrawPad(index, PadData)
    end
end

----------------------------------------------------------------------------------------------------
-- CLEAR ALL PADS
----------------------------------------------------------------------------------------------------
function Module:ClearAllPads()
    for _, PadCache in pairs(self.ActivePads) do
        if PadCache.effectId then
            CC.DisplayEffect:RemoveTrackedEffect(PadCache.effectId)
        end
        if PadCache.labelId then
            CC.DisplayLabel:RemoveTrackedLabel(PadCache.labelId)
        end
    end
    ZO_ClearTable(self.ActivePads)
end

----------------------------------------------------------------------------------------------------
-- DRAW PAD
----------------------------------------------------------------------------------------------------
function Module:DrawPad(index, PadData)
    self.ActivePads[index] = {
        effectId = nil,
        labelId = nil,
        Data = PadData,
        isCooldown = false,
        hasTriggered = false,
        cooldownEndTime = 0,
        isHidden = true,
    }
end

----------------------------------------------------------------------------------------------------
-- CREATE PAD VISUALS (DYNAMISCHES NACHLADEN)
----------------------------------------------------------------------------------------------------
function Module:CreatePadVisuals(index, PadCache)
    local heading = PadCache.Data.RY
    local TriggerData = self.TriggerData[PadCache.Data.TRG]
    local PadColor = TriggerData and TriggerData.Color or { 1, 1, 1, 0.75 }

    PadCache.effectId = CC.DisplayEffect:Draw3DEffect({
        TX = PadCache.Data.TX, TY = PadCache.Data.TY, TZ = PadCache.Data.TZ,
        RX = -(math.pi / 2), RY = heading, RZ = 0,
        offsetTY = 0,
        width = self.SV.width, height = self.SV.height,
        texture = self.SV.texture,
        ColorStart = PadColor,
        durationMs = 0,
        rotateY = -5,
    })

    if self.SV.enableDrawName then
        local font = string.format("%s|%d|%s", self.SV.fontStyle, self.SV.fontSize, self.SV.fontWeight)
        local shortName = TriggerData and TriggerData.shortName or "PAD"
        local labelColor = self.SV.useStaticLabelColor and self.SV.LabelColor or { PadColor[1], PadColor[2], PadColor[3], 1 }

        PadCache.labelId = CC.DisplayLabel:Draw3DLabel({
            ID = "CC_LaunchPad_Label_" .. index,
            TX = PadCache.Data.TX, RX = 0,       FX = false,
            TY = PadCache.Data.TY, RY = heading, FY = true,
            TZ = PadCache.Data.TZ, RZ = 0,       FZ = false,
            offsetTY = self.SV.offsetTY,
            font = font,
            displayText = shortName,
            Color = labelColor,
            durationMs = 0,
        })
    end
end

----------------------------------------------------------------------------------------------------
-- TRIGGER LOOP
----------------------------------------------------------------------------------------------------
function Module:StartTriggerLoop()
    EVENT_MANAGER:RegisterForUpdate(CC.NAME .. "LaunchPad_TriggerLoop", 100, function()
        if not CC.SV.enableAddon then return end
        local zoneId, playerX, playerY, playerZ = GetUnitRawWorldPosition("player")
        if not playerX then return end

        local currentTime = GetGameTimeMilliseconds()
        local radiusSquared = (self.SV.width / 2) ^ 2
        local safeRadiusSquared = (self.SV.width / 2 + 100) ^ 2
        local visibilityDistSquared = (self.SV.visibilityDistance * 100) ^ 2

        for index, PadCache in pairs(self.ActivePads) do
            local deltaX = playerX - PadCache.Data.TX
            local deltaZ = playerZ - PadCache.Data.TZ
            local distanceSquared = (deltaX * deltaX) + (deltaZ * deltaZ)
            local heightDifference = math.abs(playerY - PadCache.Data.TY)

            -- PROXIMITY
            local shouldHide = (distanceSquared > visibilityDistSquared)
            local visualExists = PadCache.effectId and CC.DisplayEffect.TrackedEffects[PadCache.effectId]
            if not shouldHide and not visualExists then
                self:CreatePadVisuals(index, PadCache)
                if not PadCache.effectId then
                    shouldHide = true
                end
            end

            -- VISIBILITY TOGGLE
            if shouldHide ~= PadCache.isHidden then
                PadCache.isHidden = shouldHide

                if PadCache.effectId then
                    local Effect = CC.DisplayEffect.TrackedEffects[PadCache.effectId]
                    if Effect and Effect.Control then
                        Effect.Control:SetHidden(shouldHide)
                    end
                end

                if PadCache.labelId then
                    local Label = CC.DisplayLabel.TrackedLabels[PadCache.labelId]
                    if Label and Label.Control then
                        Label.Control:SetHidden(shouldHide)
                    end
                end
            end

            -- COOLDOWN
            local isTimeCooldown = (PadCache.cooldownEndTime > currentTime)
            local isDistanceCooldown = (distanceSquared <= safeRadiusSquared and PadCache.hasTriggered)

            if not isDistanceCooldown and not isTimeCooldown then
                PadCache.hasTriggered = false
                PadCache.isCooldown = false
            else
                PadCache.isCooldown = true
            end

            -- TRIGGER
            if not PadCache.isCooldown then
                if distanceSquared <= radiusSquared and heightDifference < 500 then
                    PadCache.hasTriggered = true
                    PadCache.cooldownEndTime = currentTime + 1000
                    PadCache.isCooldown = true
                    self:ExecuteTrigger(PadCache.Data.TRG)
                end
            end

            -- COLOR DIMMING ON COOLDOWN
            if not shouldHide then
                if PadCache.effectId then
                    local Effect = CC.DisplayEffect.TrackedEffects[PadCache.effectId]
                    if Effect and Effect.Control then
                        local TriggerData = self.TriggerData[PadCache.Data.TRG]
                        local baseColor = TriggerData and TriggerData.Color or { 1, 1, 1, 0.75 }
                        local currentAlpha = PadCache.isCooldown and 0.25 or baseColor[4]

                        Effect.Control:SetColor(baseColor[1], baseColor[2], baseColor[3], currentAlpha)
                    end
                end

                if PadCache.labelId then
                    local Label = CC.DisplayLabel.TrackedLabels[PadCache.labelId]
                    if Label and Label.Control then
                        local currentAlpha = PadCache.isCooldown and 0.25 or Label.colorA
                        Label.Control:SetColor(Label.colorR, Label.colorG, Label.colorB, currentAlpha)
                    end
                end
            end
        end
    end)
end

----------------------------------------------------------------------------------------------------
-- STOP TRIGGER LOOP
----------------------------------------------------------------------------------------------------
function Module:StopTriggerLoop()
    EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. "LaunchPad_TriggerLoop")
end

----------------------------------------------------------------------------------------------------
-- EXECUTE TRIGGER
----------------------------------------------------------------------------------------------------
function Module:ExecuteTrigger(TRG)
    local TriggerData = self.TriggerData[TRG]
    if TriggerData and TriggerData.Action then
        TriggerData.Action()
    end
end

----------------------------------------------------------------------------------------------------
-- PLACE ON SELF
----------------------------------------------------------------------------------------------------
function Module:PlaceOnSelf()
    self:CancelAiming()
    local zoneId, TX, TY, TZ = GetUnitRawWorldPosition("player")
    if not (zoneId and TX and TY and TZ) then return end

    if not self.SV.SavedPads[zoneId] then self.SV.SavedPads[zoneId] = {} end
    local heading = CC.GetCameraYaw() or 0

    local newPad = {
        TX = TX, TY = TY, TZ = TZ,
        RX = -(math.pi / 2), RY = heading, RZ = 0,
        TRG = self.SV.activeTrigger,
    }

    table.insert(self.SV.SavedPads[zoneId], newPad)
    d(string.format("%s LaunchPad placed on self.", CC.CHAT))
    self:LoadPadsForCurrentZone()
end

----------------------------------------------------------------------------------------------------
-- START AIMING
----------------------------------------------------------------------------------------------------
function Module:StartAiming()
    self.isAiming = true
    d(string.format("%s Place LaunchPad (Block = Place | Menu = Cancel)", CC.CHAT))

    self:DrawPreviewEffect()
    local wasBlocking = IsBlockActive()

    EVENT_MANAGER:RegisterForUpdate(CC.NAME .. "LaunchPad_Aiming", 100, function()
        if SCENE_MANAGER:IsInUIMode() then
            self:CancelAiming()
            return
        end

        local isBlocking = IsBlockActive()
        if isBlocking and not wasBlocking then
                self:ConfirmPlacement()
            return
        end
        wasBlocking = isBlocking
    end)
end

----------------------------------------------------------------------------------------------------
-- DRAW PREVIEW
----------------------------------------------------------------------------------------------------
function Module:DrawPreviewEffect()
    local startX, startY, startZ = CC.GetAimTargetPosition()
    local heading = CC.GetCameraYaw() or 0

    local TriggerData = self.TriggerData[self.SV.activeTrigger]
    local PadColor = TriggerData and TriggerData.Color or { 1, 1, 1, 0.75 }

    self.previewEffectId = CC.DisplayEffect:Draw3DEffect({
        ID = "CC_LaunchPad_Preview",
        unitTag = "camera",

        TX = startX, RX = -(math.pi / 2), FX = false,
        TY = startY, RY = heading,        FY = false,
        TZ = startZ, RZ = 0,              FZ = false,

        offsetTY = 0,
        isFastUpdate = true,
        width = self.SV.width, height = self.SV.height,
        texture = self.SV.texture,
        durationMs = 0,
        ColorStart = PadColor,
        rotateY = -5,
    })
end

----------------------------------------------------------------------------------------------------
-- CANCEL AIMING
----------------------------------------------------------------------------------------------------
function Module:CancelAiming()
    self.isAiming = false
    EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. "LaunchPad_Aiming")

    if self.previewEffectId then
        CC.DisplayEffect:RemoveTrackedEffect(self.previewEffectId)
        self.previewEffectId = nil
    end
end

----------------------------------------------------------------------------------------------------
-- CONFIRM PLACE
----------------------------------------------------------------------------------------------------
function Module:ConfirmPlacement()
    self:CancelAiming()
    local TX, TY, TZ = CC.GetAimTargetPosition()
    if not TX or (TX == 0 and TY == 0 and TZ == 0) then
        d(string.format("%s %s", CC.CHAT, CC.ColorString("Invalid placement location.", "RD")))
        return
    end

    local zoneId = GetUnitRawWorldPosition("player")
    if not zoneId or zoneId == 0 then return end

    local heading = CC.GetCameraYaw() or 0

    if not self.SV.SavedPads[zoneId] then self.SV.SavedPads[zoneId] = {} end

    local newPad = {
        TX = TX, TY = TY, TZ = TZ,
        RX = -(math.pi / 2), RY = heading, RZ = 0,
        TRG = self.SV.activeTrigger,
    }

    table.insert(self.SV.SavedPads[zoneId], newPad)
    d(string.format("%s LaunchPad placed.", CC.CHAT))
    self:LoadPadsForCurrentZone()
end

----------------------------------------------------------------------------------------------------
-- DELETE CLOSSET PAD
----------------------------------------------------------------------------------------------------
function Module:DeleteClosestPad()
    local zoneId = GetUnitRawWorldPosition("player")
    if not zoneId or zoneId == 0 then return end
    if not self.SV.SavedPads[zoneId] or #self.SV.SavedPads[zoneId] == 0 then return end

    local _, playerX, playerY, playerZ = GetUnitRawWorldPosition("player")
    if not playerX then return end

    local closestIndex = nil
    local minDistanceSquared = (1000 ^ 2) -- 10 METERS IN CM

    for i, Pad in ipairs(self.SV.SavedPads[zoneId]) do
        local deltaX = playerX - Pad.TX
        local deltaZ = playerZ - Pad.TZ
        local distanceSquared = (deltaX * deltaX) + (deltaZ * deltaZ)

        if distanceSquared <= minDistanceSquared then
            minDistanceSquared = distanceSquared
            closestIndex = i
        end
    end

    if closestIndex then
        table.remove(self.SV.SavedPads[zoneId], closestIndex)
        d(string.format("%s Closest LaunchPad deleted.", CC.CHAT))
        self:LoadPadsForCurrentZone()
    else
        d(string.format("%s No LaunchPad found within 10 meters.", CC.CHAT))
    end
end

----------------------------------------------------------------------------------------------------
-- MENU SETTINGS
----------------------------------------------------------------------------------------------------
function Module:GetMenuOptions()
    local menuIcon = string.format("|t%d:%d:%s|t", CC.SIZE_ICON_LAM_SM, CC.SIZE_ICON_LAM_SM, self.iconPath)

    -- CATEGORIES
    local CategoriesMap = {}
    local CategoryChoices = {}
    for id, Data in pairs(self.TriggerData) do
        local category = Data.category or "Other"
        if not CategoriesMap[category] then
            CategoriesMap[category] = {}
            table.insert(CategoryChoices, category)
        end
        table.insert(CategoriesMap[category], id)
    end
    table.sort(CategoryChoices)

    for _, ids in pairs(CategoriesMap) do table.sort(ids) end
    local function GetCategoryForTrigger(triggerId)
        local Data = self.TriggerData[triggerId]
        return Data and Data.category or CategoryChoices[1]
    end

    local function GetChoicesForCategory(category)
        local Choices, Values = {}, {}
        for _, id in ipairs(CategoriesMap[category] or {}) do
            table.insert(Choices, self.TriggerData[id].name)
            table.insert(Values, id)
        end
        return Choices, Values
    end

    local initCategory = GetCategoryForTrigger(self.SV.activeTrigger)
    local initChoices, initValues = GetChoicesForCategory(initCategory)

    self.menuSelectedCategory = initCategory
    self.lastLoadedCategory = initCategory

    local function SyncCategoryAndChoices()
        local expectedCategory = GetCategoryForTrigger(self.SV.activeTrigger)
        if self.lastLoadedCategory ~= expectedCategory then
            if CC_LaunchPad_Dropdown_Trigger then
                local Choices, Values = GetChoicesForCategory(expectedCategory)
                CC_LaunchPad_Dropdown_Trigger:UpdateChoices(Choices, Values)
                self.lastLoadedCategory = expectedCategory
                self.menuSelectedCategory = expectedCategory
            else
                self.menuSelectedCategory = expectedCategory
            end
        end
        return expectedCategory
    end

    return {
        type = "submenu",
        name = string.format("%s %s", menuIcon, CC.ColorString(self.menuName, "tier2")),
        controls = {
            {
                type = "description",
                text = "Place permanent trigger pads on the ground.\nStepping on a pad automatically triggers its assigned action or timer.\n\n" .. CC.ColorString("Note:", "tier2") .. " Group tools and timers require [CC] Raidlead status.\nPersonal actions, like Wizard's Wardrobe, work for everyone.",
                width = "full",
            },

            { type = "header", name = CC.ColorString("PLACEMENT", "tier3") },
            {
                type = "dropdown",
                name = "Trigger Category",
                choices = CategoryChoices,
                getFunc = function() return SyncCategoryAndChoices() end,
                setFunc = function(value)
                    self.menuSelectedCategory = value
                    self.lastLoadedCategory = value
                    local newChoices, newValues = GetChoicesForCategory(value)

                    self.SV.activeTrigger = newValues[1]

                    if CC_LaunchPad_Dropdown_Trigger then
                        CC_LaunchPad_Dropdown_Trigger:UpdateChoices(newChoices, newValues)
                        CC_LaunchPad_Dropdown_Trigger:UpdateValue()
                    end

                    local Preview = CC.Menu.Previews[self.name]
                    if Preview then
                        local Color = self.TriggerData[self.SV.activeTrigger] and self.TriggerData[self.SV.activeTrigger].Color or { 1, 1, 1, 1 }
                        Preview:SetColor(unpack(Color))
                    end
                end,
                disabled = function() return not CC.SV.enableAddon end,
            },
            {
                type = "dropdown",
                name = "Action on Trigger",
                choices = initChoices,
                choicesValues = initValues,
                getFunc = function()
                    SyncCategoryAndChoices()
                    return self.SV.activeTrigger
                end,
                setFunc = function(value)
                    self.SV.activeTrigger = value
                    local Preview = CC.Menu.Previews[self.name]
                    if Preview then
                        local Color = self.TriggerData[value] and self.TriggerData[value].Color or { 1, 1, 1, 1 }
                        Preview:SetColor(unpack(Color))
                    end
                end,
                reference = "CC_LaunchPad_Dropdown_Trigger",
                default = self.Default.activeTrigger,
                disabled = function() return not CC.SV.enableAddon end,
            },
            {
                type = "button",
                name = "PLACE AT CURSOR",
                func = function()
                    if CC.Menu.PanelName and LAM2 then
                        SCENE_MANAGER:SetInUIMode(false)
                        self:StartAiming()
                    end
                end,
                width = "half",
                disabled = function() return not CC.SV.enableAddon end,
            },
            {
                type = "button",
                name = "PLACE ON SELF",
                func = function()
                    self:PlaceOnSelf()
                end,
                width = "half",
                disabled = function() return not CC.SV.enableAddon end,
            },
            {
                type = "button",
                name = "CLEAR ZONE",
                warning = "Delete all LaunchPads in the current zone. Can't be undone!",
                isDangerous = true,
                func = function()
                    local zoneId = GetUnitRawWorldPosition("player")
                    if zoneId and zoneId ~= 0 then
                        self.SV.SavedPads[zoneId] = nil
                        self:ClearAllPads()
                        d(string.format("%s All LaunchPads in zone cleared.", CC.CHAT))
                    end
                end,
                width = "half",
                disabled = function() return not CC.SV.enableAddon end,
            },
            {
                type = "button",
                name = "DELETE CLOSEST",
                tooltip = "Deletes the closest LaunchPad within a 10m radius.",
                func = function()
                    self:DeleteClosestPad()
                end,
                width = "half",
                disabled = function() return not CC.SV.enableAddon end,
            },

            { type = "header", name = CC.ColorString("SETTINGS NAMEPLATE", "tier3") },
            {
                type = "checkbox",
                name = "Enable Nameplate",
                tooltip = "Draws trigger name above the LaunchPad.",
                getFunc = function() return self.SV.enableDrawName end,
                setFunc = function(value)
                    self.SV.enableDrawName = value
                    self:LoadPadsForCurrentZone()
                end,
                default = self.Default.enableDrawName,
                disabled = function() return not CC.SV.enableAddon end,
            },
            {
                type = "checkbox",
                name = "Use Static Nameplate Color",
                tooltip = "If disabled, the nameplate inherits the color of the pad.",
                getFunc = function() return self.SV.useStaticLabelColor end,
                setFunc = function(value)
                    self.SV.useStaticLabelColor = value
                    self:LoadPadsForCurrentZone()
                end,
                default = self.Default.useStaticLabelColor,
                disabled = function() return not CC.SV.enableAddon or not self.SV.enableDrawName end,
            },
            {
                type = "colorpicker",
                name = "Nameplate Color",
                getFunc = function() return unpack(self.SV.LabelColor) end,
                setFunc = function(r, g, b, a)
                    self.SV.LabelColor = {r, g, b, a}
                    self:LoadPadsForCurrentZone()
                end,
                default = CC.GetRgbaFromArray(self.Default.LabelColor),
                disabled = function() return not CC.SV.enableAddon or not self.SV.enableDrawName or not self.SV.useStaticLabelColor end,
            },
            {
                type = "slider",
                name = "Vertical Offset [meter]",
                tooltip = "Distance from the ground for nameplate.",
                min = 0, max = 3, step = 0.1, decimals = 1,
                getFunc = function() return self.SV.offsetTY / 100 end,
                setFunc = function(value) self.SV.offsetTY = value * 100 end,
                default = self.Default.offsetTY / 100,
                disabled = function() return not CC.SV.enableAddon or not self.SV.enableDrawName end,
            },
            {
                type = "slider",
                name = "Font Size",
                min = 25, max = 75, step = 5,
                getFunc = function() return self.SV.fontSize end,
                setFunc = function(value)
                    self.SV.fontSize = value
                    self:LoadPadsForCurrentZone()
                end,
                default = self.Default.fontSize,
                disabled = function() return not CC.SV.enableAddon or not self.SV.enableDrawName end,
            },
            {
                type = "dropdown",
                name = "Font Style",
                choices = CC.FONT_STYLE_CHOICES,
                choicesValues = CC.FONT_STYLE_VALUES,
                getFunc = function() return self.SV.fontStyle end,
                setFunc = function(value)
                    self.SV.fontStyle = value
                    self:LoadPadsForCurrentZone()
                end,
                default = self.Default.fontStyle,
                disabled = function() return not CC.SV.enableAddon or not self.SV.enableDrawName end,
            },
            {
                type = "dropdown",
                name = "Font Weight",
                tooltip = "Select outline style for nameplate.",
                choices = CC.FONT_WEIGHT_CHOICES,
                choicesValues = CC.FONT_WEIGHT_VALUES,
                getFunc = function() return self.SV.fontWeight end,
                setFunc = function(value)
                    self.SV.fontWeight = value
                    self:LoadPadsForCurrentZone()
                end,
                default = self.Default.fontWeight,
                disabled = function() return not CC.SV.enableAddon or not self.SV.enableDrawName end,
            },

            { type = "header", name = CC.ColorString("VISUALS", "tier3") },
            {
                type = "slider",
                name = "Visibility Distance [meter]",
                min = 0, max = 200, step = 5,
                getFunc = function() return self.SV.visibilityDistance end,
                setFunc = function(value)
                    self.SV.visibilityDistance = value
                end,
                default = self.Default.visibilityDistance,
            },
            {
                type = "slider",
                name = "Marker Width [meter]",
                min = 1, max = 5, step = 0.5, decimals = 1,
                getFunc = function() return self.SV.width / 100 end,
                setFunc = function(value)
                    self.SV.width = value * 100
                    self:LoadPadsForCurrentZone()
                end,
                default = self.Default.width / 100,
            },
            {
                type = "slider",
                name = "Marker Length [meter]",
                min = 1, max = 5, step = 0.5, decimals = 1,
                getFunc = function() return self.SV.height / 100 end,
                setFunc = function(value)
                    self.SV.height = value * 100
                    self:LoadPadsForCurrentZone()
                end,
                default = self.Default.height / 100,
            },
            {
                type = "dropdown",
                name = "Texture",
                choices = self.TextureChoices,
                choicesValues = self.TextureValues,
                getFunc = function() return self.SV.texture end,
                setFunc = function(value)
                    self.SV.texture = value
                    self:LoadPadsForCurrentZone()
                    local Preview = CC.Menu.Previews[self.name]
                    if Preview then
                        Preview:SetTexture(CC.NAME .. value)
                    end
                end,
                default = self.Default.texture,
            },
            {
                type = "custom",
                createFunc = function(CustomControl)
                    local Control = WINDOW_MANAGER:CreateControl(nil, CustomControl, CT_TEXTURE)
                    Control:SetAnchor(CENTER, CustomControl, CENTER)
                    Control:SetDimensions(128, 128)
                    Control:SetTexture(CC.NAME .. self.SV.texture)

                    local activeTriggerData = self.TriggerData[self.SV.activeTrigger]
                    local Color = activeTriggerData and activeTriggerData.Color or {1, 1, 1, 1}
                    Control:SetColor(unpack(Color))

                    -- ANIMATION ROTATION
                    local TimelineRotation = ANIMATION_MANAGER:CreateTimeline()
                    TimelineRotation:SetPlaybackType(ANIMATION_PLAYBACK_LOOP, LOOP_INDEFINITELY)
                    local AnimRotation = TimelineRotation:InsertAnimation(ANIMATION_CUSTOM, Control, 0)

                    AnimRotation:SetDuration(12000) -- 5 RPM
                    AnimRotation:SetUpdateFunction(function(animation, progress)
                        local currentRY = progress * 2 * math.pi * (-1)
                        Control:SetTextureRotation(currentRY)
                    end)
                    TimelineRotation:PlayFromStart()

                    CC.Menu.Previews[self.name] = Control
                end,
                minHeight = 128,
                width = "full",
            },
        },
    }
end

CC[Module.name] = Module
table.insert(CC.Modules, Module)