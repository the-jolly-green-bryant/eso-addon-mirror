local FlappyNord = FlappyNord

--==================================================
-- Window Visibility
--==================================================

function FlappyNord.Show()
    FlappyNordRoot:SetHidden(false)
end

function FlappyNord.Hide()
    FlappyNordRoot:SetHidden(true)
end

function FlappyNord.Toggle()
    if FlappyNordRoot:IsHidden() then
        FlappyNord.Show()
    else
        FlappyNord.Hide()
    end
end

--==================================================
-- Window Position
--==================================================

function FlappyNord.SaveWindowPosition()
    if not FlappyNord.savedVars then return end

    FlappyNord.savedVars.windowX = FlappyNordRoot:GetLeft()
    FlappyNord.savedVars.windowY = FlappyNordRoot:GetTop()
end

function FlappyNord.RestoreWindowPosition()
    if not FlappyNord.HasSavedWindowPosition() then return end

    FlappyNordRoot:ClearAnchors()
    FlappyNordRoot:SetAnchor(
        TOPLEFT,
        GuiRoot,
        TOPLEFT,
        FlappyNord.savedVars.windowX,
        FlappyNord.savedVars.windowY
    )
end

function FlappyNord.OnWindowMoveStart(_, button)
    if button ~= MOUSE_BUTTON_INDEX_LEFT then return end

    FlappyNordRoot:StartMoving()
end

function FlappyNord.OnWindowMoveStop(_, button)
    if button ~= MOUSE_BUTTON_INDEX_LEFT then return end

    FlappyNordRoot:StopMovingOrResizing()
    FlappyNord.SaveWindowPosition()
end

--==================================================
-- Game State
--==================================================

function FlappyNord.ApplyIdleState()
    FlappyNord.SetPipesHidden(true)
end

function FlappyNord.ApplyPlayingState()
    FlappyNord.RefreshPipePositions()
end

function FlappyNord.ApplyGameOverState()
    -- Keep the current window visible on death.
end

function FlappyNord.SetState(newState)
    FlappyNord.gameState = newState

    if newState == "idle" then
        FlappyNord.ApplyIdleState()
    elseif newState == "playing" then
        FlappyNord.ApplyPlayingState()
    elseif newState == "gameOver" then
        FlappyNord.ApplyGameOverState()
    end

    FlappyNord.RefreshStateUI()
end

--==================================================
-- Window Lifecycle Helpers
--==================================================

function FlappyNord.SetWindowUIMode(enabled)
    -- UI mode may need more work for gamepad auto-switch compatibility.
    SetGameCameraUIMode(enabled)
end

function FlappyNord.OnWindowShown()
    FlappyNord.isRunning = true
    FlappyNord.lastUpdateTime = nil

    FlappyNord.ResetGame()

    FlappyNord.SetWindowUIMode(true)
    PlaySound(SOUNDS.DEFAULT_WINDOW_OPEN)
end

function FlappyNord.OnWindowHidden()
    FlappyNord.isRunning = false
    FlappyNord.lastUpdateTime = nil

    FlappyNord.SetState("idle")
    FlappyNord.SetWindowUIMode(false)
    PlaySound(SOUNDS.DEFAULT_WINDOW_CLOSE)
end

--==================================================
-- Run Start
--==================================================

function FlappyNord.StartRun()
    if not FlappyNord.pipes or not FlappyNord.pipes[1] or not FlappyNord.pipes[2] then return end

    local pipe1 = FlappyNord.pipes[1]
    local pipe2 = FlappyNord.pipes[2]

    -- Reposition the second pipe relative to the first at the start of a run.
    FlappyNord.ResetPipe(pipe2, pipe1.x + FlappyNord.pipeSpacing)

    FlappyNord.RefreshPipePositions()

    FlappyNord.SetState("playing")
    FlappyNord.nordVelocityY = FlappyNord.flapStrength
    FlappyNord.TriggerArmFlap()
end
