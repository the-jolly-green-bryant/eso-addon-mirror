local FlappyNord = FlappyNord

local FLAPPY_KEY_SPACE = 13
local FLAPPY_KEY_SLASH = 108

local function OpenChatInputWithText(chatText)
    zo_callLater(function()
        StartChatInput(chatText)
    end, 0)
end

--==================================================
-- Restart
--==================================================

function FlappyNord.OnRestartButtonClicked()
    if FlappyNord.gameState ~= "gameOver" then return end

    FlappyNord.ResetGame()
    FlappyNord.StartRun()
end

--==================================================
-- Flap Input
--==================================================

function FlappyNord.Flap()
    if not FlappyNord.isRunning then return end

    if FlappyNord.gameState == "idle" then
        -- First flap starts the run.
        FlappyNord.StartRun()
    elseif FlappyNord.gameState == "playing" then
        -- Standard flap during gameplay.
        FlappyNord.nordVelocityY = FlappyNord.flapStrength
        FlappyNord.TriggerArmFlap()
        PlaySound(SOUNDS.MAP_ZOOM_IN)
    elseif FlappyNord.gameState == "gameOver" then
        -- Ignore flap input after death.
        return
    end
end

--==================================================
-- Keyboard Handling
--==================================================

function FlappyNord.OnKeyDown(_, key, _, _, _, _)
    if key == FLAPPY_KEY_SPACE then
        FlappyNord.Flap()
        return true
    elseif key == KEY_ESCAPE then
        FlappyNord.Hide()
        return true
    elseif key == FLAPPY_KEY_SLASH or key == KEY_ENTER then
        local chatText = ""

        if key == FLAPPY_KEY_SLASH then
            -- Open chat with slash already inserted.
            chatText = "/"
        end

        OpenChatInputWithText(chatText)

        return true
    end

    return false
end
