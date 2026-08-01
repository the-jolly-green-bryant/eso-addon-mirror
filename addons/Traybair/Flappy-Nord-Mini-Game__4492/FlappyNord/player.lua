local FlappyNord = FlappyNord

--==================================================
-- Helpers
--==================================================

function FlappyNord.SetTopLeftAnchorIfPresent(control, offsetX, offsetY)
    if not control then return end

    control:ClearAnchors()
    control:SetAnchor(
        TOPLEFT,
        FlappyNordRootGameWindowGameAreaGameLayer,
        TOPLEFT,
        offsetX,
        offsetY
    )
end

function FlappyNord.SetTextureRotationIfPresent(control, angle)
    if control then
        control:SetTextureRotation(angle)
    end
end

--==================================================
-- Nord Tilt
--==================================================

function FlappyNord.UpdateNordTilt(dt)
    local nord = FlappyNord.nordControl
    if not nord then return end

    local targetTilt = -FlappyNord.nordVelocityY * FlappyNord.tiltFactor
    targetTilt = FlappyNord.Clamp(targetTilt, FlappyNord.maxTiltUp, FlappyNord.maxTiltDown)

    FlappyNord.currentTilt = FlappyNord.currentTilt +
        ((targetTilt - FlappyNord.currentTilt) * FlappyNord.tiltLerpSpeed * dt)

    nord:SetTextureRotation(FlappyNord.currentTilt)
end

--==================================================
-- Arm Animation
--==================================================

function FlappyNord.TriggerArmFlap()
    FlappyNord.armBurstTimer = FlappyNord.armBurstDuration
end

function FlappyNord.UpdateArmAnimation(dt)
    local arm = FlappyNord.armControl
    if not arm then return end

    if FlappyNord.armBurstTimer > 0 then
        FlappyNord.armBurstTimer = FlappyNord.armBurstTimer - dt

        local elapsed = FlappyNord.armBurstDuration - FlappyNord.armBurstTimer
        local progress = elapsed / FlappyNord.armBurstDuration

        local flapMid = (FlappyNord.armUpAngle + FlappyNord.armDownAngle) * 0.5
        local flapAmp = (FlappyNord.armDownAngle - FlappyNord.armUpAngle) * 0.5

        FlappyNord.armFlapOffset = flapMid +
            math.sin(progress * math.pi * 2 * FlappyNord.armFlapsPerBurst) * flapAmp
    else
        -- Smoothly settle the arm back to its resting position.
        FlappyNord.armFlapOffset = FlappyNord.armFlapOffset +
            ((FlappyNord.armDownAngle - FlappyNord.armFlapOffset) * FlappyNord.armReturnSpeed * dt)
    end

    FlappyNord.SetTextureRotationIfPresent(arm, FlappyNord.currentTilt + FlappyNord.armFlapOffset)
end

--==================================================
-- Nord Collision Bounds
--==================================================

function FlappyNord.GetNordBounds()
    local left = FlappyNord.nordX + FlappyNord.hitboxInsetX
    local top = FlappyNord.nordY + FlappyNord.hitboxInsetY
    local right = FlappyNord.nordX + FlappyNord.nordWidth - FlappyNord.hitboxInsetX
    local bottom = FlappyNord.nordY + FlappyNord.nordHeight - FlappyNord.hitboxInsetY

    return left, top, right, bottom
end

--==================================================
-- Nord / Arm Positioning
--==================================================

function FlappyNord.SetNordPosition(x, y)
    FlappyNord.nordX = x
    FlappyNord.nordY = y

    FlappyNord.SetTopLeftAnchorIfPresent(FlappyNord.nordControl, x, y)
    FlappyNord.SetTopLeftAnchorIfPresent(
        FlappyNord.armControl,
        x + FlappyNord.armOffsetX,
        y + FlappyNord.armOffsetY
    )
end

--==================================================
-- Reset
--==================================================

function FlappyNord.ResetNord()
    local startX = 60
    local startY = 260

    FlappyNord.currentTilt = 0
    FlappyNord.nordVelocityY = 0

    FlappyNord.armBurstTimer = 0
    FlappyNord.armFlapOffset = FlappyNord.armDownAngle

    FlappyNord.SetNordPosition(startX, startY)

    FlappyNord.SetTextureRotationIfPresent(FlappyNord.nordControl, 0)
    FlappyNord.SetTextureRotationIfPresent(FlappyNord.armControl, FlappyNord.armDownAngle)
end
