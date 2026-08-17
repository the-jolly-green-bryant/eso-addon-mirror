local CC = CombatCoordination

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name = "DisplayLabel",
    Parent = nil,
    RegisteredLabels = {},
    TrackedLabels = {},
    LabelTimers = {},
    labelCounter = 0,
    activeCounter = 0,
    isUpdateLoop = false,

    timeUpdate = 100,

    Default = {
        offsetTY = 0,
        distanceMax = 10000,
        animationMs = 250,

        fontAlpha = 0.75,
        fontSize = 100,
        fontStyle = "$(BOLD_FONT)",
        fontWeight = "thick-outline",
    },
    ---@type table|any
    SV = {},
}

----------------------------------------------------------------------------------------------------
-- CUSTOM ENABLE / DISABLE
----------------------------------------------------------------------------------------------------
function Module:CustomEnable()
    self:Create()
end

function Module:CustomDisable()
    self:ClearAllLabels()
end

----------------------------------------------------------------------------------------------------
-- DRAW TEXT IN 3D WORLD
----------------------------------------------------------------------------------------------------
function Module:Draw3DLabel(Config)
    if not CC.SV.enableAddon then return end
    if self.SV.fontSize == 0 and not Config.font then return end

    -- CONFIG AND COORDINATION?
    if not Config or not (Config.TX and Config.TY and Config.TZ) then return end

    -- DISTANCE?
    local zoneId, playerX, playerY, playerZ = GetUnitRawWorldPosition("player")
    if not playerX or not playerY or not playerZ then return nil end

    local distanceSquared = (Config.TX - playerX)^2 + (Config.TY - playerY)^2 + (Config.TZ - playerZ)^2
    local distanceMax = self.SV.distanceMax
    if distanceSquared > distanceMax * distanceMax then return nil end

    self.labelCounter = self.labelCounter + 1
    local currentId = self.labelCounter

    local Label = self:GetRecycledLabel()
    local Control = Label.Control

    -- -- ANCHOR / ORIGIN
    -- Control:SetTransformNormalizedOriginPoint(0.5, 0.5)

    -- DATA
    Label.skillId = Config.ID or 0
    Label.durationMs = Config.durationMs or 0

    Label.startScale = 0
    Label.currentScale = 0
    Label.endScale = 1

    Label.displayText = Config.displayText
    Label.displayTime = Config.displayTime

    Label.startTime = GetGameTimeMilliseconds()

    -- CLEAR DATA IN CASE ITS RECYCLED
    local Data = {}
    if Config.unitTag         then Data.unitTag = Config.unitTag end
    if Config.isProximityFade then Data.isProximityFade = true end

    if ZO_IsTableEmpty(Data) then
        Label.Data = nil
    else
        Label.Data = Data
    end

    Label.RX = Config.RX or 0
    Label.RY = Config.RY or 0
    Label.RZ = Config.RZ or 0

    -- FACING CAMERA?
    Label.FX = Config.FX or false
    Label.FY = Config.FY or false
    Label.FZ = Config.FZ or false

    Control:SetText(self:FormatText(Label.displayText, Label.displayTime) or "")
    Control:SetFont(Config.font or string.format("%s|%d|%s", self.SV.fontStyle, self.SV.fontSize, self.SV.fontWeight))

    local rotationX = Label.RX
    local rotationY = Label.RY
    local rotationZ = Label.RZ

    -- FACING FLAGS
    if Label.FX or Label.FY or Label.FZ then
        local cameraForwardX, cameraForwardY, cameraForwardZ = GetCameraForward(SPACE_WORLD)
        local cameraYaw = math.atan2(cameraForwardX, cameraForwardZ) - math.pi
        local cameraPitch = math.atan2(cameraForwardY, math.sqrt(cameraForwardX^2 + cameraForwardZ^2))

        if Label.FX then rotationX = cameraPitch end
        if Label.FY then rotationY = cameraYaw end
        if Label.FZ then rotationZ = 0 end
    end

    -- VERTICAL SHIFT
    local offsetTY = Config.offsetTY or 0
    local random = math.random() -- 1 = 1CM

    Label.offsetTY = offsetTY + random

    local textWidth = Control:GetTextWidth() -- GETTEXTWIDTH IS CM; GETWIDTH IS METER
    Label.offsetRotation = (textWidth / 2) * math.sin(rotationZ)

    Label.TX = Config.TX
    Label.TY = Config.TY + self.SV.offsetTY + Label.offsetRotation + Label.offsetTY
    Label.TZ = Config.TZ

    -- COLOR
    local Color = Config.Color or Config.ColorStart or { 1, 1, 1, 1 }
    local r, g, b, a = unpack(Color)
    a = Config.alpha or self.SV.fontAlpha
    Control:SetColor(r, g, b, a)

    Label.colorR, Label.colorG, Label.colorB = r, g, b
    Label.colorA = a

    -- INITIAL RENDER
    local renderX, renderY, renderZ = WorldPositionToGuiRender3DPosition(Label.TX, Label.TY, Label.TZ)
    Control:SetTransformOffset(renderX, renderY, renderZ)

    -- GIMBAL LOCK; FROM THE REDDIT ARTICLE LOL
    local finalRotationX = rotationX * math.cos(rotationZ) + rotationY * math.sin(rotationZ)
    local finalRotationY = rotationY * math.cos(rotationZ) - rotationX * math.sin(rotationZ)

    Control:SetTransformRotation(finalRotationX, finalRotationY, rotationZ)
    Control:SetHidden(Config.isHidden or false)

    -- PLAY ANIMATION
    if Label.TimelineScale:IsPlaying() then Label.TimelineScale:Stop() end

    local animationMs = math.max(0, math.min(Label.durationMs, Config.animationMs or self.SV.animationMs))
    if animationMs > 0 and not Config.isHidden then
        Label.AnimScale:SetDuration(animationMs)
        Label.AnimScale:SetEasingFunction(ZO_LinearEase)
        Label.TimelineScale:PlayFromStart()
    else
        Control:SetTransformScale(1)
        Label.currentScale = 1
    end

    -- REG FOR REFRESH
    self.TrackedLabels[currentId] = Label
    self.activeCounter = self.activeCounter + 1

    if not self.isUpdateLoop then self:StartUpdateLoop() end

    -- TIMEOUT
    if Label.durationMs > 0 then
        zo_callLater(function()
            self:RemoveTrackedLabel(currentId)
        end, math.min(60000, Label.durationMs))
    end

    return currentId
end

----------------------------------------------------------------------------------------------------
-- PARENT AND RAYCAM
----------------------------------------------------------------------------------------------------
function Module:Create()
    if self.Parent then return end

    self.Parent = WINDOW_MANAGER:CreateTopLevelWindow(CC.NAME .. "DisplayLabel_Parent")
    self.Parent:SetAnchorFill(GuiRoot)
    self.Parent:SetDrawTier(DT_LOW)
    self.Parent:SetDrawLayer(DL_BACKGROUND)
    self.Parent:SetHidden(false)

    -- THX ExoY FOR TEACHING ME THIS
    local Fragment = ZO_HUDFadeSceneFragment:New(self.Parent)
    HUD_SCENE:AddFragment(Fragment)
    HUD_UI_SCENE:AddFragment(Fragment)
end

----------------------------------------------------------------------------------------------------
-- GET LABEL OR CREATE
----------------------------------------------------------------------------------------------------
function Module:GetRecycledLabel()
    for _, VisualLabel in ipairs(self.RegisteredLabels) do
        if not VisualLabel.isActive then
            VisualLabel.isActive = true

            -- ACTIVE? SPACE? ADD; GOOD TO GO!
            if VisualLabel.Control and VisualLabel.Control:GetSpace() ~= SPACE_WORLD then
                VisualLabel.Control:SetSpace(SPACE_WORLD)
            end
            return VisualLabel
        end
    end

    -- NO INACTIVE LABEL.. CREATE ONE
    local index = #self.RegisteredLabels + 1
    local Control = WINDOW_MANAGER:CreateControl(CC.NAME .. "DisplayLabel_Label" .. index, self.Parent, CT_LABEL)

    Control:SetAnchor(CENTER, GuiRoot, CENTER)
    Control:SetSpace(SPACE_WORLD)
    Control:SetTransformNormalizedOriginPoint(0.5, 0.5)
    Control:SetScale(0.01) -- WORLD SCALING

    -- https://wiki.esoui.com/Drawing_Order
    Control:SetDrawTier(DT_HIGH)
    Control:SetDrawLayer(DL_OVERLAY)
    --Control:SetDrawLevel(1)

    -- ANIMATION
    local TimelineScale = ANIMATION_MANAGER:CreateTimeline()
    local AnimScale = TimelineScale:InsertAnimation(ANIMATION_CUSTOM, Control, 0)

    local NewLabel = {
        Control = Control,

        isActive = true,
        isFading = false,

        TX = 0, RX = 0, FX = false,
        TY = 0, RY = 0, FY = false,
        TZ = 0, RZ = 0, FZ = false,

        offsetRotation = 0,

        Data = nil,

        -- ANIMATION PROPERTIES
        TimelineScale = TimelineScale,
        AnimScale = AnimScale,

        startScale = 0,
        currentScale = 0,
        endScale = 1,
    }

    AnimScale:SetUpdateFunction(function(animation, progress)
        NewLabel.currentScale = NewLabel.startScale + (NewLabel.endScale - NewLabel.startScale) * progress
        Control:SetTransformScale(NewLabel.currentScale)
    end)

    table.insert(self.RegisteredLabels, NewLabel)

    return NewLabel
end

----------------------------------------------------------------------------------------------------
-- CLEANUP
----------------------------------------------------------------------------------------------------
function Module:ClearAllLabels()
    -- ACTIVE LABELS
    for _, Label in ipairs(self.RegisteredLabels) do
        if Label.TimelineScale and Label.TimelineScale:IsPlaying() then
            Label.TimelineScale:SetHandler("OnStop", nil)
            Label.TimelineScale:Stop()
        end
        Label.isActive = false
        Label.isFading = false
        if Label.Control then
            Label.Control:SetHidden(true)
        end
    end

    ZO_ClearTable(self.TrackedLabels)
    ZO_ClearTable(self.LabelTimers)
    self.activeCounter = 0

    EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. self.name .. "OnUpdate")
    self.isUpdateLoop = false
end

----------------------------------------------------------------------------------------------------
-- REMOVE TRACKED LABEL
----------------------------------------------------------------------------------------------------
function Module:RemoveTrackedLabel(labelId)
    local TrackedLabel = self.TrackedLabels[labelId]

    if TrackedLabel and TrackedLabel.Control and TrackedLabel.isActive and not TrackedLabel.isFading then
        TrackedLabel.isFading = true

        if TrackedLabel.TimelineScale:IsPlaying() then TrackedLabel.TimelineScale:Stop() end

            TrackedLabel.startScale = TrackedLabel.currentScale
            TrackedLabel.endScale = 0

            local animationMs = math.max(0, self.SV.animationMs)

        if animationMs > 0 then
            TrackedLabel.AnimScale:SetDuration(animationMs)
            TrackedLabel.AnimScale:SetEasingFunction(ZO_LinearEase)

            TrackedLabel.TimelineScale:SetHandler("OnStop", function(TimelineScale)
                TimelineScale:SetHandler("OnStop", nil)
                if TrackedLabel and TrackedLabel.isFading then
                    TrackedLabel.isActive = false
                    TrackedLabel.isFading = false
                    if TrackedLabel.Control then
                    TrackedLabel.Control:SetHidden(true)
                end
                    self.TrackedLabels[labelId] = nil
                    self.activeCounter = math.max(0, self.activeCounter - 1)
                end
            end)

            TrackedLabel.TimelineScale:PlayFromStart()
        else
            TrackedLabel.isActive = false
            TrackedLabel.isFading = false
            TrackedLabel.Control:SetHidden(true)
            self.TrackedLabels[labelId] = nil
            self.activeCounter = math.max(0, self.activeCounter - 1)
        end
    end
end

----------------------------------------------------------------------------------------------------
-- START UPDATE LOOP
----------------------------------------------------------------------------------------------------
function Module:StartUpdateLoop()
    self.isUpdateLoop = true
    self.timeUpdate = 100
    EVENT_MANAGER:RegisterForUpdate(CC.NAME .. self.name .. "OnUpdate", self.timeUpdate, function() self:OnUpdate() end)
end

----------------------------------------------------------------------------------------------------
-- TEXT UPDATE LOOP
----------------------------------------------------------------------------------------------------
function Module:OnUpdate()
    local currentTime = GetGameTimeMilliseconds()
    local activeTrackers = 0

    local cameraForwardX, cameraForwardY, cameraForwardZ = GetCameraForward(SPACE_WORLD)
    local cameraYaw = math.atan2(cameraForwardX, cameraForwardZ) - math.pi
    local cameraPitch = math.atan2(cameraForwardY, math.sqrt(cameraForwardX^2 + cameraForwardZ^2))

    Set3DRenderSpaceToCurrentCamera(CC.DisplayEffect.cameraName)
    local originX, originY, originZ = CC.DisplayEffect.Camera:Get3DRenderSpaceOrigin()
    local cameraX, cameraY, cameraZ = GuiRender3DPositionToWorldPosition(originX, originY, originZ)

    local isFastUpdate = false

    for _, Label in pairs(self.TrackedLabels) do
        if Label.isActive then
            activeTrackers = activeTrackers + 1

            -- STRING / TIMER UPDATE
            if Label.displayTime and not Label.isFading then
                local timePassed = currentTime - Label.startTime
                local timeLeft = math.max(0, Label.displayTime - timePassed)
                local displayText = self:FormatText(Label.displayText, timeLeft)
                Label.Control:SetText(displayText or "")
            end

            -- UPDATE POSITION BY UNIT TAG
            if Label.Data and Label.Data.unitTag then
                isFastUpdate = true

                if Label.Data.unitTag == "camera" then
                    local _, _, playerY, _ = GetUnitRawWorldPosition("player")
                    if playerY then
                        local cameraTargetX, cameraTargetY, cameraTargetZ = CC.GetCameraTargetPosition(playerY, 5400)
                        if cameraTargetX and cameraTargetY and cameraTargetZ then
                            Label.TX = cameraTargetX
                            Label.TY = cameraTargetY + self.SV.offsetTY + (Label.offsetRotation or 0) + (Label.offsetTY or 0)
                            Label.TZ = cameraTargetZ
                        end
                    end
                elseif DoesUnitExist(Label.Data.unitTag) then
                    local _, worldX, worldY, worldZ = GetUnitRawWorldPosition(Label.Data.unitTag)
                    if worldX and worldY and worldZ then
                        Label.TX = worldX
                        Label.TY = worldY + self.SV.offsetTY + (Label.offsetRotation or 0) + (Label.offsetTY or 0)
                        Label.TZ = worldZ
                    end
                end
            end

            -- PROXIMITY FADE
            if Label.Data and Label.Data.isProximityFade and cameraX and not Label.isFading then
                local dX = Label.TX - cameraX
                local dY = Label.TY - cameraY
                local dZ = Label.TZ - cameraZ
                local dist = math.sqrt(dX * dX + dY * dY + dZ * dZ)

                local factor = math.max(0, math.min(1, dist / 1000))
                local currentAlpha = Label.colorA * factor

                Label.Control:SetColor(Label.colorR, Label.colorG, Label.colorB, currentAlpha)
            end

            local renderX, renderY, renderZ = WorldPositionToGuiRender3DPosition(Label.TX, Label.TY, Label.TZ)
            Label.Control:SetTransformOffset(renderX, renderY, renderZ)

            local rotationX = Label.RX
            local rotationY = Label.RY
            local rotationZ = Label.RZ

            -- FACING?
            if Label.FX then rotationX = cameraPitch end
            if Label.FY then rotationY = cameraYaw end
            if Label.FZ then rotationZ = 0 end

            local finalRotationX = rotationX * math.cos(rotationZ) + rotationY * math.sin(rotationZ)
            local finalRotationY = rotationY * math.cos(rotationZ) - rotationX * math.sin(rotationZ)

            Label.Control:SetTransformRotation(finalRotationX, finalRotationY, rotationZ)
        end
    end

    if activeTrackers == 0 then
        EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. self.name .. "OnUpdate")
        self.isUpdateLoop = false
    else
        local timeUpdate = isFastUpdate and 10 or 100
        if self.timeUpdate ~= timeUpdate then
            self.timeUpdate = timeUpdate
            EVENT_MANAGER:RegisterForUpdate(CC.NAME .. self.name .. "OnUpdate", timeUpdate, function() self:OnUpdate() end)
        end
    end
end

----------------------------------------------------------------------------------------------------
-- BUILD STRING FOR TIMER DISPLAY
----------------------------------------------------------------------------------------------------
function Module:FormatText(displayText, displayTime)
    if not displayText and not displayTime then return nil end
    local stringTime = nil

    if displayTime then
        local timeSec = math.max(0, displayTime / 1000)
        if timeSec < 5 then
            stringTime = string.format("%.1f", timeSec)
        else
            stringTime = string.format("%.0f", timeSec)
        end
    end

    if displayText and stringTime then return displayText .. " " .. stringTime
    elseif stringTime then             return stringTime .. "s"
    else                               return displayText
    end
end

----------------------------------------------------------------------------------------------------
-- TEST
----------------------------------------------------------------------------------------------------
SLASH_COMMANDS["/cc_labeltest"] = function()
    local zoneId, playerX, playerY, playerZ = GetUnitRawWorldPosition("player")
    playerY = playerY + 150

    -- TIMER (VERTICAL)
    CC.DisplayLabel:Draw3DLabel({
        ID = "LabelTest1",

        TX = playerX, RX = 0, FX = false,
        TY = playerY, RY = 0, FY = true,
        TZ = playerZ, RZ = 0, FZ = false,

        offsetTY = 200,

        displayText = "TIMER", displayTime = 10000,
        Color = { 0, 1, 0, 1 },
        durationMs = 10000, animationMs = 250
    })

    -- GROUND TEST
    CC.DisplayLabel:Draw3DLabel({
        ID = "LabelTest2",

        TX = playerX + 200, RX = -(math.pi / 2), FX = false,
        TY = playerY,       RY = 0,              FY = false,
        TZ = playerZ,       RZ = 0,              FZ = false,

        offsetTY = -150,

        displayText = "FLAT GROUND TEST",
        Color = { 1, 0, 0, 1 },
        durationMs = 10000, animationMs = 250
    })

    -- LOOKING AT YOU!
    CC.DisplayLabel:Draw3DLabel({
        ID = "LabelTest3",

        TX = playerX - 200, RX = 0, FX = true,
        TY = playerY,       RY = 0, FY = true,
        TZ = playerZ,       RZ = 0, FZ = false,

        offsetTY = 0,

        displayText = "LOOKING AT YOU!",
        Color = { 0, 0.5, 1, 1 },
        durationMs = 10000, animationMs = 5000
    })
end

----------------------------------------------------------------------------------------------------
-- EXPORT MODULE
----------------------------------------------------------------------------------------------------
CC[Module.name] = Module
table.insert(CC.Modules, Module)