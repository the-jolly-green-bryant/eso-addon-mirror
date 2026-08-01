local FlappyNord = FlappyNord

--==================================================
-- UI Helpers
--==================================================

function FlappyNord.SetHiddenIfPresent(control, hidden)
    if control then
        control:SetHidden(hidden)
    end
end

--==================================================
-- Flash / Death Effect
--==================================================

function FlappyNord.HideFlashOverlay()
    if not FlappyNord.flashOverlay then return end

    FlappyNord.flashOverlay:SetHidden(true)
    FlappyNord.flashOverlay:SetAlpha(1)
end

function FlappyNord.ShowFlashOverlay(alpha)
    if not FlappyNord.flashOverlay then return end

    FlappyNord.flashOverlay:SetHidden(false)
    FlappyNord.flashOverlay:SetAlpha(alpha)
end

function FlappyNord.UpdateFlash(dt)
    if FlappyNord.flashTimer <= 0 then
        if FlappyNord.flashOverlay and not FlappyNord.flashOverlay:IsHidden() then
            FlappyNord.HideFlashOverlay()
        end
        return
    end

    FlappyNord.flashTimer = FlappyNord.flashTimer - dt

    local alpha = FlappyNord.flashTimer / FlappyNord.flashDuration
    alpha = FlappyNord.Clamp(alpha, 0, 1)

    FlappyNord.ShowFlashOverlay(alpha)

    if FlappyNord.flashTimer <= 0 then
        FlappyNord.HideFlashOverlay()
    end
end

function FlappyNord.TriggerDeathFlash()
    FlappyNord.flashTimer = FlappyNord.flashDuration
    FlappyNord.ShowFlashOverlay(1)
end

--==================================================
-- Score UI
--==================================================

function FlappyNord.UpdateScoreDisplay()
    if not FlappyNord.scoreLabel then return end

    FlappyNord.scoreLabel:SetText(tostring(FlappyNord.score))

    -- Green while tied with or beating best score during a run.
    if FlappyNord.score >= FlappyNord.bestScore and FlappyNord.score > 0 then
        FlappyNord.scoreLabel:SetColor(0, 1, 0, 1)
    else
        FlappyNord.scoreLabel:SetColor(1, 1, 1, 1)
    end
end

--==================================================
-- State-Based UI Visibility
--==================================================

function FlappyNord.RefreshStateUI()
    if not FlappyNord.startLabel or not FlappyNord.gameOverLabel then return end

    local isIdle = FlappyNord.gameState == "idle"
    local isGameOver = FlappyNord.gameState == "gameOver"
    local hideRestart = not isGameOver

    FlappyNord.SetHiddenIfPresent(FlappyNord.startLabel, not isIdle)
    FlappyNord.SetHiddenIfPresent(FlappyNord.gameOverLabel, not isGameOver)
    FlappyNord.SetHiddenIfPresent(FlappyNord.restartButton, hideRestart)
    FlappyNord.SetHiddenIfPresent(FlappyNord.restartButtonLabel, hideRestart)
end

--==================================================
-- Control Lookup
--==================================================

function FlappyNord.CreateLabels()
    FlappyNord.startLabel = FlappyNordRootGameWindowGameAreaUILayerStartLabel
    FlappyNord.gameOverLabel = FlappyNordRootGameWindowGameAreaUILayerGameOverLabel
    FlappyNord.scoreLabel = FlappyNordRootGameWindowGameAreaUILayerScoreLabel

    FlappyNord.restartButton = FlappyNordRootGameWindowGameAreaUILayerRestartButton
    FlappyNord.restartButtonLabel = FlappyNordRootGameWindowGameAreaUILayerRestartButtonLabel

    FlappyNord.flashOverlay = FlappyNordRootGameWindowGameAreaUILayerFlashOverlay
end
