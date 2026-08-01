FlappyNord = {
    --==================================================
    -- Addon Identity
    --==================================================
    name = "FlappyNord",

    --==================================================
    -- Saved Variables
    --==================================================
    savedVars = nil,
    savedVarsName = "FlappyNordSavedVars",
    savedVarsVersion = 1,

    --==================================================
    -- Control References
    --==================================================
    nordControl = nil,
    armControl = nil,

    startLabel = nil,
    gameOverLabel = nil,
    restartButton = nil,
    restartButtonLabel = nil,
    scoreLabel = nil,
    flashOverlay = nil,

    ground1Control = nil,
    ground2Control = nil,

    --==================================================
    -- Nord Sprite / Visual Size
    --==================================================
    nordWidth = 96,
    nordHeight = 96,

    --==================================================
    -- Nord Collision
    --==================================================
    hitboxInsetX = 14,
    hitboxInsetY = 26,
    groundCollisionInset = 26,

    --==================================================
    -- Nord Position / Movement
    --==================================================
    nordX = 0,
    nordY = 0,
    nordVelocityY = 0,

    gravity = 1600,
    flapStrength = -500,

    --==================================================
    -- Nord Tilt
    --==================================================
    currentTilt = 0,
    maxTiltUp = -0.5,
    maxTiltDown = 1.0,
    tiltFactor = 0.0015,
    tiltLerpSpeed = 8,

    --==================================================
    -- Arm Sprite / Placement
    --==================================================
    armWidth = 48,
    armHeight = 48,
    armOffsetX = 25,
    armOffsetY = 26,

    --==================================================
    -- Arm Animation
    --==================================================
    armUpAngle = -1.25,
    armDownAngle = 0,
    armReturnSpeed = 50,
    armFlapOffset = 0,

    armBurstTimer = 0,
    armBurstDuration = 0.30,
    armFlapsPerBurst = 4,

    --==================================================
    -- Pipes
    --==================================================
    pipeWidth = 80,
    pipeBodyTextureHeight = 64,
    pipeCapHeight = 32,

    gapHeight = 170,
    minGapY = 80,
    maxGapY = 260,

    pipeSpeed = 180,
    pipeSpacing = 240,

    --==================================================
    -- Ground
    --==================================================
    groundWidth = 360,
    groundHeight = 80,
    groundY = 560,

    ground1X = 0,
    ground2X = 360,
    groundSpeed = 180,

    --==================================================
    -- Game State
    --==================================================
    isRunning = false,
    gameState = "idle",
    lastUpdateTime = nil,

    --==================================================
    -- Flash / Death Effect
    --==================================================
    flashTimer = 0,
    flashDuration = 0.12,

    --==================================================
    -- Score
    --==================================================
    score = 0,
    bestScore = 0,
}

local FlappyNord = FlappyNord

--==================================================
-- Helpers
--==================================================

function FlappyNord.HasSavedWindowPosition()
    return FlappyNord.savedVars
        and FlappyNord.savedVars.windowX ~= nil
        and FlappyNord.savedVars.windowY ~= nil
end

function FlappyNord.Clamp(value, minValue, maxValue)
    if value < minValue then return minValue end
    if value > maxValue then return maxValue end
    return value
end

function FlappyNord.ApplyOverlayStyle(control)
    if not control then return end
    control:SetDrawLayer(DL_OVERLAY)
    control:SetDrawTier(DT_HIGH)
end

function FlappyNord.ApplyOverlayButtonStyle(button, onClickedHandler)
    if not button then return end

    FlappyNord.ApplyOverlayStyle(button)

    if onClickedHandler then
        button:SetHandler("OnClicked", onClickedHandler)
    end
end

--==================================================
-- Control Lookup
--==================================================

function FlappyNord.CreateNord()
    FlappyNord.nordControl = FlappyNordRootGameWindowGameAreaGameLayerNord
    FlappyNord.armControl = FlappyNordRootGameWindowGameAreaGameLayerNordArm
end

--==================================================
-- Game Flow
--==================================================

function FlappyNord.GameOver()
    if FlappyNord.gameState == "gameOver" then return end

    PlaySound(SOUNDS.RADIAL_MENU_CLOSE)

    FlappyNord.TriggerDeathFlash()
    FlappyNord.SetState("gameOver")

    if FlappyNord.nordVelocityY < 0 then
        FlappyNord.nordVelocityY = 0
    end
end

function FlappyNord.ResetTransientEffects()
    FlappyNord.lastUpdateTime = nil
    FlappyNord.flashTimer = 0

    if FlappyNord.flashOverlay then
        FlappyNord.flashOverlay:SetHidden(true)
        FlappyNord.flashOverlay:SetAlpha(1)
    end
end

function FlappyNord.ResetGame()
    FlappyNord.ResetNord()
    FlappyNord.ResetObstacles()

    FlappyNord.score = 0
    FlappyNord.UpdateScoreDisplay()

    FlappyNord.ResetTransientEffects()
    FlappyNord.SetState("idle")
end

--==================================================
-- Update Helpers
--==================================================

function FlappyNord.GetFloorY()
    return FlappyNord.groundY - FlappyNord.nordHeight + FlappyNord.groundCollisionInset
end

function FlappyNord.UpdateNordPhysics(dt)
    FlappyNord.nordVelocityY = FlappyNord.nordVelocityY + (FlappyNord.gravity * dt)
    FlappyNord.nordY = FlappyNord.nordY + (FlappyNord.nordVelocityY * dt)
end

function FlappyNord.ClampNordToScreen(floorY, triggerGameOverOnFloor)
    if FlappyNord.nordY > floorY then
        FlappyNord.nordY = floorY

        if triggerGameOverOnFloor then
            FlappyNord.GameOver()
        else
            FlappyNord.nordVelocityY = 0
        end
    end

    if FlappyNord.nordY < 0 then
        FlappyNord.nordY = 0
        FlappyNord.nordVelocityY = 0
    end
end

function FlappyNord.UpdateNordVisuals(dt)
    FlappyNord.SetNordPosition(FlappyNord.nordX, FlappyNord.nordY)
    FlappyNord.UpdateNordTilt(dt)
    FlappyNord.UpdateArmAnimation(dt)
end

function FlappyNord.UpdatePlayingState(dt, floorY)
    FlappyNord.UpdateNordPhysics(dt)
    FlappyNord.ClampNordToScreen(floorY, true)
    FlappyNord.UpdateNordVisuals(dt)

    FlappyNord.UpdateObstacles(dt)
    FlappyNord.CheckPipeCollision()
    FlappyNord.CheckPipeScore()
end

function FlappyNord.UpdateGameOverState(dt, floorY)
    FlappyNord.UpdateNordPhysics(dt)
    FlappyNord.ClampNordToScreen(floorY, false)
    FlappyNord.UpdateNordVisuals(dt)

    FlappyNord.currentTilt = FlappyNord.currentTilt + ((1.2 - FlappyNord.currentTilt) * 6 * dt)

    if FlappyNord.nordControl then
        FlappyNord.nordControl:SetTextureRotation(FlappyNord.currentTilt)
    end
end

--==================================================
-- Main Update Loop
--==================================================

function FlappyNord.Update(dt)
    if not FlappyNord.isRunning then return end

    FlappyNord.UpdateFlash(dt)

    local floorY = FlappyNord.GetFloorY()

    if FlappyNord.gameState == "playing" then
        FlappyNord.UpdatePlayingState(dt, floorY)
    elseif FlappyNord.gameState == "gameOver" then
        FlappyNord.UpdateGameOverState(dt, floorY)
    end
end

--==================================================
-- Initialization Helpers
--==================================================

function FlappyNord.InitializeSavedVars()
    FlappyNord.savedVars = ZO_SavedVars:NewAccountWide(
        FlappyNord.savedVarsName,
        FlappyNord.savedVarsVersion,
        nil,
        {
            bestScore = 0,
            windowX = nil,
            windowY = nil,
        }
    )

    FlappyNord.bestScore = FlappyNord.savedVars.bestScore or 0
end

function FlappyNord.InitializeHandlers()
    FlappyNordRoot:SetHandler("OnShow", FlappyNord.OnWindowShown)
    FlappyNordRoot:SetHandler("OnHide", FlappyNord.OnWindowHidden)
    FlappyNordRoot:SetHandler("OnKeyDown", FlappyNord.OnKeyDown)

    FlappyNordRootGameWindowTitleBar:SetHandler("OnMouseDown", FlappyNord.OnWindowMoveStart)
    FlappyNordRootGameWindowTitleBar:SetHandler("OnMouseUp", FlappyNord.OnWindowMoveStop)

    FlappyNordRootGameWindowGameArea:SetHandler("OnUpdate", FlappyNord.OnGameAreaUpdate)
end

function FlappyNord.InitializeControls()
    FlappyNord.CreateNord()
    FlappyNord.CreateLabels()
    FlappyNord.CreateObstacleSet()
end

function FlappyNord.InitializeUILayers()
    FlappyNord.ApplyOverlayStyle(FlappyNord.flashOverlay)
    if FlappyNord.flashOverlay then
        FlappyNord.flashOverlay:SetAlpha(0)
        FlappyNord.flashOverlay:SetHidden(true)
    end

    FlappyNord.ApplyOverlayStyle(FlappyNord.startLabel)
    FlappyNord.ApplyOverlayStyle(FlappyNord.gameOverLabel)
    FlappyNord.ApplyOverlayStyle(FlappyNord.scoreLabel)
    FlappyNord.ApplyOverlayStyle(FlappyNord.restartButtonLabel)

    FlappyNord.ApplyOverlayButtonStyle(
        FlappyNord.restartButton,
        FlappyNord.OnRestartButtonClicked
    )
end

function FlappyNord.InitializeGameState()
    FlappyNord.RestoreWindowPosition()
    FlappyNord.ResetNord()
    FlappyNord.ResetObstacles()
    FlappyNord.UpdateScoreDisplay()
    FlappyNord.SetState("idle")
    FlappyNordRoot:SetHidden(true)
end

function FlappyNord.OnGameAreaUpdate(_, currentTime)
    if not FlappyNord.isRunning then return end

    if FlappyNord.lastUpdateTime == nil then
        FlappyNord.lastUpdateTime = currentTime
        return
    end

    local dt = currentTime - FlappyNord.lastUpdateTime
    FlappyNord.lastUpdateTime = currentTime

    FlappyNord.Update(dt)
end

--==================================================
-- Main Initialization
--==================================================

function FlappyNord.InitializeRuntime()
    FlappyNord.InitializeHandlers()
    FlappyNord.InitializeControls()
    FlappyNord.InitializeUILayers()
    FlappyNord.InitializeGameState()
end

function FlappyNord.Initialize()
    FlappyNord.InitializeSavedVars()
    FlappyNord.InitializeRuntime()

    SLASH_COMMANDS["/flappynord"] = function()
        FlappyNord.Toggle()
    end

    EVENT_MANAGER:UnregisterForEvent(FlappyNord.name, EVENT_ADD_ON_LOADED)
end

function FlappyNord.OnAddOnLoaded(event, addonName)
    if addonName == FlappyNord.name then
        FlappyNord.Initialize()
    end
end

EVENT_MANAGER:RegisterForEvent(FlappyNord.name, EVENT_ADD_ON_LOADED, FlappyNord.OnAddOnLoaded)
