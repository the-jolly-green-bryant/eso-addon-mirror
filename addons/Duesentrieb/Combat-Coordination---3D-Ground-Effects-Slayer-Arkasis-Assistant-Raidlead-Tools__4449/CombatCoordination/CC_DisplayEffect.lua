local CC = CombatCoordination

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name = "DisplayEffect",
    Parent = nil,
    Camera = nil,
    cameraName = "",

    RegisteredEffects = {},
    TrackedEffects = {},
    EffectTimers = {},
    effectCounter = 0,
    isEffectTracking = false,

    timeUpdate = 100, -- MILLISECONDS

    Default = {
        enableDepthBuffer = false,
        texture = "/textures/circle_8_clean.dds", -- FALLBACK
        offsetTY = 0,
        distanceMax = 10000, -- CHANGED TO CM.. SO THIS IS 100M!
        animationMs = 250,
        durationFlashMs = 500,

        PermanentEffects = {},
    },
    ---@type table|any
    SV = {},
}

----------------------------------------------------------------------------------------------------
-- CUSTOM ENABLE / DISABLE
----------------------------------------------------------------------------------------------------
function Module:CustomEnable()
    self:Create()
    self:LoadPermanentEffects()
end

function Module:CustomDisable()
    self:ClearAllEffects()
end

function Module:LoadPermanentEffects()
end

----------------------------------------------------------------------------------------------------
-- DRAW EFFECT IN 3D WORLD
----------------------------------------------------------------------------------------------------
function Module:Draw3DEffect(Config)
    if not CC.SV.enableAddon then return end
    if not Config or not (Config.TX and Config.TY and Config.TZ) then return end

    -- DISTANCE?
    local _, playerX, playerY, playerZ = GetUnitRawWorldPosition("player")
    if not playerX or not playerY or not playerZ then return nil end

    local distanceSquared = (Config.TX - playerX)^2 + (Config.TY - playerY)^2 + (Config.TZ - playerZ)^2
    local distanceMax = self.SV.distanceMax
    if distanceSquared > distanceMax * distanceMax then return nil end

    self.effectCounter = self.effectCounter + 1
    local currentId = self.effectCounter

    local Effect    = self:GetRecycledEffect()
    local Control   = Effect.Control

    Effect.isActive = true
    Effect.isFading = false

    Effect.skillId  = Config.ID or 0

    Effect.startTime  = GetGameTimeMilliseconds()
    Effect.durationMs = Config.durationMs or 0
    Effect.endTime    = Effect.startTime + Effect.durationMs

    Effect.widthMeter  = (Config.width or 0) / 100
    Effect.heightMeter = (Config.height or 0) / 100

    local offsetTY = Config.offsetTY or 0
    local random = math.random() -- 0 .. 1 = 0CM .. 1CM

    Effect.offsetTY = offsetTY + random

    Effect.TX = Config.TX
    Effect.TY = Config.TY + self.SV.offsetTY + Effect.offsetTY
    Effect.TZ = Config.TZ

    Effect.RX = Config.RX or 0
    Effect.RY = Config.RY or 0
    Effect.RZ = Config.RZ or 0

    Effect.FX = Config.FX or false
    Effect.FY = Config.FY or false
    Effect.FZ = Config.FZ or false

    -- FACING CAMERA?
    if Effect.FX or Effect.FY or Effect.FZ then
        local cameraX, cameraY, cameraZ = GetCameraForward(SPACE_WORLD)
        local cameraYaw = math.atan2(cameraX, cameraZ) - math.pi
        local cameraPitch = math.asin(cameraY)

        if Effect.FX then Effect.RX = cameraPitch end
        if Effect.FY then Effect.RY = cameraYaw end
        if Effect.FZ then Effect.RZ = 0 end

        self:StartEffectTracking()
    end

    Effect.ColorStart   = Config.ColorStart or Config.Color or { 1, 1, 1, 1 }
    Effect.startScale   = Config.startScale or 0
    Effect.currentScale = Config.startScale or 0
    Effect.endScale     = Config.endScale or 1

    -- INJECT SPECIAL SNOWFLAKE DATA
    local Data = {}
    if Config.unitTag        then Data.unitTag        = Config.unitTag end
    if Config.ColorEnd       then Data.ColorEnd       = Config.ColorEnd end
    if Config.ColorFlash     then Data.ColorFlash     = Config.ColorFlash end
    if Config.animationEndMs then Data.animationEndMs = Config.animationEndMs end
    if Config.rotateY        then Data.rotateY        = Config.rotateY end
    if Config.isFastUpdate   then Data.isFastUpdate   = Config.isFastUpdate end

    if ZO_IsTableEmpty(Data) then
        Effect.Data = nil
    else
        Effect.Data = Data
        self:StartEffectTracking()
    end

    -- INIT
    Control:Set3DLocalDimensions(Effect.widthMeter * Effect.currentScale, Effect.heightMeter * Effect.currentScale)
    Control:SetTexture(CC.NAME .. (Config.texture ~= "" and Config.texture or self.SV.texture))

    Control:SetDrawTier(Config.drawTier or DT_HIGH)
    Control:SetDrawLayer(Config.drawLayer or DL_OVERLAY)
    Control:SetDrawLevel(Config.drawLevel or 0) -- CAN EVEN BE NEGATIVE.. TODO: Z-FIGHTING? MAYBE..

    -- ROTATE TEXTURE
    Control:SetTextureCoordsRotation(Config.textureCoordsRotation or 0)

    -- (START-) COLOR
    Control:SetColor(unpack(Effect.ColorStart))

    local renderX, renderY, renderZ = WorldPositionToGuiRender3DPosition(Effect.TX, Effect.TY, Effect.TZ)
    Control:Set3DRenderSpaceOrigin(renderX, renderY, renderZ)
    Control:Set3DRenderSpaceOrientation(Effect.RX, Effect.RY, Effect.RZ)
    Control:SetHidden(Config.isHidden == true) -- TODO: DO I NEED THIS ANYMORE?

    -- if Config.enableDepthBuffer then
    --     Control:Set3DRenderSpaceUsesDepthBuffer(true)
    -- end

    -- TIMELINE / ANIMATION
    if Effect.Timeline:IsPlaying() then Effect.Timeline:Stop() end

    if not Config.isHidden then
        local animationStartMs = math.max(0, math.min(Effect.durationMs, Config.animationStartMs or Config.animationMs or self.SV.animationMs))

        if animationStartMs > 0 then
            Effect.Animation:SetDuration(animationStartMs)
            Effect.Animation:SetEasingFunction(ZO_LinearEase) -- ZO_EaseOutQuadratic)
            Effect.Timeline:PlayFromStart()
        else
            Effect.currentScale = Effect.endScale
            Control:Set3DLocalDimensions(Effect.widthMeter * Effect.endScale, Effect.heightMeter * Effect.endScale)
        end
    end

    -- REGISTER
    self.TrackedEffects[currentId] = Effect

    if Effect.durationMs > 0 then
        zo_callLater(function()
            self:RemoveTrackedEffect(currentId)
        end, math.min(60000, Effect.durationMs))
    end

    return currentId
end

----------------------------------------------------------------------------------------------------
-- TRACKING LOOP
----------------------------------------------------------------------------------------------------
function Module:StartEffectTracking()
    if self.isEffectTracking then return end
    self.isEffectTracking = true
    self.timeUpdate = 100
    EVENT_MANAGER:RegisterForUpdate(CC.NAME .. self.name .. "OnUpdate", self.timeUpdate, function() self:OnUpdate() end)
end

function Module:StopEffectTracking()
    if not self.isEffectTracking then return end
    self.isEffectTracking = false
    EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. self.name .. "OnUpdate")
end

----------------------------------------------------------------------------------------------------
-- EFFECT TRACKING UPDATE - COLORS, POSITION ETC
----------------------------------------------------------------------------------------------------
function Module:OnUpdate()
    local currentTime = GetGameTimeMilliseconds()
    local activeTrackers = 0
    local isFastUpdate = false

    local cameraX, cameraY, cameraZ = GetCameraForward(SPACE_WORLD)
    local cameraYaw = math.atan2(cameraX, cameraZ) - math.pi
    local cameraPitch = math.asin(cameraY)

    for _, Effect in pairs(self.TrackedEffects) do
        if Effect.isActive and Effect.Control then
            local needsTransform = false
            local TX, TY, TZ = Effect.TX, Effect.TY, Effect.TZ
            local RX, RY, RZ = Effect.RX, Effect.RY, Effect.RZ
            local offsetTY = 0

            -- FACING
            if Effect.FX or Effect.FY or Effect.FZ then
                if Effect.FX then RX = cameraPitch end
                if Effect.FY then RY = cameraYaw end
                if Effect.FZ then RZ = 0 end
                needsTransform = true
                activeTrackers = activeTrackers + 1
            end

            -- OTHER VISUALS
            if Effect.Data then
                activeTrackers = activeTrackers + 1
                local Data = Effect.Data

                -- FAST UPDATE?
                if Data.isFastUpdate then
                    isFastUpdate = true
                end

                -- ROTATE Y (RPM) -- TODO: ANIMATION TIMELINE?
                if Data.rotateY and Data.rotateY ~= 0 then
                    isFastUpdate = true
                    local passedTime = currentTime - Effect.startTime
                    local radiansPerMs = (Data.rotateY * 2 * math.pi) / 60000
                    local rotationAngle = (passedTime * radiansPerMs) % (2 * math.pi)
                    RY = RY + rotationAngle
                    needsTransform = true
                end

                -- ANIMATION OFFSET CORRECTION
                if Effect.offsetTY and Effect.offsetTY ~= 0 then
                    offsetTY = Effect.offsetTY
                    if Effect.Timeline and Effect.Timeline:IsPlaying() then
                        local currentScale = Effect.currentScale or Effect.startScale or 0
                        offsetTY = Effect.offsetTY * currentScale
                    end
                end

                -- POSITION
                if Data.unitTag then
                    isFastUpdate = true

                    if Data.unitTag == "camera" then
                        local _, _, playerY, _ = GetUnitRawWorldPosition("player")
                        if playerY then
                            local cameraTargetX, cameraTargetY, cameraTargetZ = CC.GetCameraTargetPosition(playerY, 5400)
                            if cameraTargetX and cameraTargetY and cameraTargetZ then
                                TX = cameraTargetX
                                TY = cameraTargetY + self.SV.offsetTY + offsetTY
                                TZ = cameraTargetZ
                                needsTransform = true
                                activeTrackers = activeTrackers + 1
                            end
                        end
                    elseif Data.unitTag and DoesUnitExist(Data.unitTag) then
                        local _, worldX, worldY, worldZ = GetUnitRawWorldPosition(Data.unitTag)
                        if worldX and worldY and worldZ then
                            TX, TY, TZ = worldX, worldY + self.SV.offsetTY + offsetTY, worldZ
                            needsTransform = true
                            activeTrackers = activeTrackers + 1
                        end
                    end
                end

                -- COLORS
                if Data.ColorEnd then
                    if Effect.durationMs > 0 then
                        local passedTime = currentTime - Effect.startTime
                        local progress = passedTime / Effect.durationMs
                        local durationFlashMs = self.SV.durationFlashMs
                        local hasFlash = (Data.ColorFlash and durationFlashMs > 0)

                        progress = math.max(0, math.min(1, progress))

                        local Color = nil
                        if Data.ColorFlash and passedTime > (Effect.durationMs - durationFlashMs) then
                            local flashProgress = (passedTime - (Effect.durationMs - durationFlashMs)) / durationFlashMs
                            flashProgress = math.max(0, math.min(1, flashProgress))

                            local flashFactor = 1 - flashProgress
                            Color = CC.GetLinearColor(flashFactor, Data.ColorEnd, Data.ColorFlash)
                        else
                            local fadeDuration = hasFlash and (Effect.durationMs - durationFlashMs) or Effect.durationMs
                            local fadeProgress = passedTime / math.max(1, fadeDuration)
                            fadeProgress = math.max(0, math.min(1, fadeProgress))

                            local fadeFactor = 1 - fadeProgress
                            Color = CC.GetLinearColor(fadeFactor, Effect.ColorStart, Data.ColorEnd)
                        end

                        Effect.Control:SetColor(unpack(Color or { 1, 1, 1, 1 }))
                    end
                end
            end

            if needsTransform then
                activeTrackers = activeTrackers + 1
                local renderX, renderY, renderZ = WorldPositionToGuiRender3DPosition(TX, TY, TZ)
                Effect.Control:Set3DRenderSpaceOrigin(renderX, renderY, renderZ)
                Effect.Control:Set3DRenderSpaceOrientation(RX, RY, RZ)
            end
        end
    end

    if activeTrackers == 0 then
        self:StopEffectTracking()
    else
        -- INTERVAL SWITCH (OVERDRIVE)
        local timeUpdate = isFastUpdate and 10 or 100
        if self.timeUpdate ~= timeUpdate then
            self.timeUpdate = timeUpdate
            EVENT_MANAGER:RegisterForUpdate(CC.NAME .. self.name .. "OnUpdate", timeUpdate, function() self:OnUpdate() end)
        end
    end
end

----------------------------------------------------------------------------------------------------
-- PARENT AND DIY RAYTRACING
----------------------------------------------------------------------------------------------------
function Module:Create()
    if self.Parent then return end

    self.Parent = WINDOW_MANAGER:CreateTopLevelWindow(CC.NAME .. "DisplayEffect_Parent")
    self.Parent:SetAnchorFill(GuiRoot)
    self.Parent:SetDrawTier(DT_LOW)
    self.Parent:SetDrawLayer(DL_BACKGROUND)
    self.Parent:SetHidden(false)

    self.Camera = WINDOW_MANAGER:CreateTopLevelWindow(CC.NAME .. "DisplayEffect_Camera")
    self.Camera:Create3DRenderSpace()
    self.Camera:SetHidden(true)

    self.cameraName = self.Camera:GetName()

    -- THX ExoY FOR TEACHING ME THIS
    local Fragment = ZO_HUDFadeSceneFragment:New(self.Parent)
    HUD_SCENE:AddFragment(Fragment)
    HUD_UI_SCENE:AddFragment(Fragment)
end

----------------------------------------------------------------------------------------------------
-- GET EFFECT OR CREATE
----------------------------------------------------------------------------------------------------
function Module:GetRecycledEffect()
    for _, Effect in ipairs(self.RegisteredEffects) do
        if not Effect.isActive then
            Effect.isActive = true

            -- ENSURE ITS ACTIVE AND HAS 3DSPACE
            if Effect.Control and not Effect.Control:Has3DRenderSpace() then
                Effect.Control:Create3DRenderSpace()
                Effect.Control:Set3DRenderSpaceUsesDepthBuffer(false)--self.SV.enableDepthBuffer)
            end
            return Effect
        end
    end

    -- NO INACTIVE EFFECT.. CREATE ONE
    local index = #self.RegisteredEffects + 1
    local Control = WINDOW_MANAGER:CreateControl(CC.NAME .. "DisplayEffect_Texture" .. index, self.Parent, CT_TEXTURE)

    Control:SetTexture("")
    -- https://wiki.esoui.com/Controls -> SetAddressMode(number TextureAddressMode addressMode)
    Control:SetAddressMode(TEX_MODE_CLAMP) -- OR WRAP; CLAMP SEEMS PREFERABLE
    Control:Create3DRenderSpace()
    Control:Set3DRenderSpaceUsesDepthBuffer(false)--self.SV.enableDepthBuffer)

    -- https://wiki.esoui.com/Drawing_Order
    Control:SetDrawTier(DT_HIGH)
    Control:SetDrawLayer(DL_OVERLAY)
    --Control:SetDrawLevel(0)

    -- ANIMATION
    local Timeline = ANIMATION_MANAGER:CreateTimeline()
    local Animation = Timeline:InsertAnimation(ANIMATION_CUSTOM, Control, 0)

    local NewEffect = {
        Control = Control,
        isActive = true,
        isFading = false,

        TX = 0, RX = 0, FX = false,
        TY = 0, RY = 0, FY = false,
        TZ = 0, RZ = 0, FZ = false,

        Data = nil,

        -- ANIMATION PROPERTIES
        Timeline = Timeline,
        Animation = Animation,

        startScale = 0,
        currentScale = 0,
        endScale = 1,
    }

    Animation:SetUpdateFunction(function(animation, progress)
        NewEffect.currentScale = NewEffect.startScale + (NewEffect.endScale - NewEffect.startScale) * progress
        NewEffect.Control:Set3DLocalDimensions(NewEffect.widthMeter * NewEffect.currentScale, NewEffect.heightMeter * NewEffect.currentScale)
    end)

    table.insert(self.RegisteredEffects, NewEffect)

    return NewEffect
end

----------------------------------------------------------------------------------------------------
-- CLEANUP
----------------------------------------------------------------------------------------------------
function Module:ClearAllEffects()
    for _, Effect in ipairs(self.RegisteredEffects) do
        if Effect.Timeline and Effect.Timeline:IsPlaying() then
            Effect.Timeline:SetHandler("OnStop", nil)
            Effect.Timeline:Stop()
        end
        Effect.isActive = false
        Effect.isFading = false
        if Effect.Control then
            Effect.Control:SetHidden(true)
        end
    end

    ZO_ClearTable(self.TrackedEffects)
    ZO_ClearTable(self.EffectTimers)
end

----------------------------------------------------------------------------------------------------
-- UPDATE DEPTH BUFFER
----------------------------------------------------------------------------------------------------
function Module:UpdateDepthBuffer()
    for _, Effect in ipairs(self.RegisteredEffects) do
        if Effect.Control and Effect.Control:Has3DRenderSpace() then
            Effect.Control:Set3DRenderSpaceUsesDepthBuffer(false)--self.SV.enableDepthBuffer)
        end
    end
end

----------------------------------------------------------------------------------------------------
-- UPDATE TEXTURES
----------------------------------------------------------------------------------------------------
function Module:UpdateActiveTextures(skillId, newTexture)
    for _, Effect in pairs(self.TrackedEffects) do
        if Effect.isActive and Effect.skillId == skillId and Effect.Control then
            Effect.Control:SetTexture(CC.NAME .. newTexture)
        end
    end
end

----------------------------------------------------------------------------------------------------
-- REMOVE TRACKED EFFECT
----------------------------------------------------------------------------------------------------
function Module:RemoveTrackedEffect(effectId)
    local Effect = self.TrackedEffects[effectId]

    if Effect and Effect.Control and Effect.isActive and not Effect.isFading then
        Effect.isFading = true
        if Effect.Timeline:IsPlaying() then Effect.Timeline:Stop() end

        Effect.startScale = Effect.currentScale
        Effect.endScale = 0

        local animationMs = self.SV.animationMs
        if Effect.Data and Effect.Data.animationEndMs then
            animationMs = Effect.Data.animationEndMs
        end

        if animationMs > 0 then
            Effect.Animation:SetDuration(animationMs)
            Effect.Animation:SetEasingFunction(ZO_LinearEase) --ZO_EaseInQuadratic)

            Effect.Timeline:SetHandler("OnStop", function(EffectTimeline)
                EffectTimeline:SetHandler("OnStop", nil)
                if Effect and Effect.isFading then
                    Effect.isActive = false
                    Effect.isFading = false
                    if Effect.Control then
                        Effect.Control:SetHidden(true)
                    end
                    self.TrackedEffects[effectId] = nil
                end
            end)

            Effect.Timeline:PlayFromStart()
        else
            Effect.isActive = false
            Effect.isFading = false
            Effect.Control:SetHidden(true)
            self.TrackedEffects[effectId] = nil
        end
    end
end

CC[Module.name] = Module
table.insert(CC.Modules, Module)