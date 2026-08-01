local FlappyNord = FlappyNord

--==================================================
-- Pipe Utilities
--==================================================

function FlappyNord.GetRandomGapY()
    return zo_random(FlappyNord.minGapY, FlappyNord.maxGapY)
end

function FlappyNord.SetPipeHidden(pipe, hidden)
    if not pipe then return end

    if pipe.topBody then pipe.topBody:SetHidden(hidden) end
    if pipe.topCap then pipe.topCap:SetHidden(hidden) end
    if pipe.bottomCap then pipe.bottomCap:SetHidden(hidden) end
    if pipe.bottomBody then pipe.bottomBody:SetHidden(hidden) end
end

function FlappyNord.SetPipesHidden(hidden)
    if not FlappyNord.pipes then return end

    for _, pipe in ipairs(FlappyNord.pipes) do
        FlappyNord.SetPipeHidden(pipe, hidden)
    end
end

function FlappyNord.RefreshPipePositions()
    if not FlappyNord.pipes then return end

    for _, pipe in ipairs(FlappyNord.pipes) do
        FlappyNord.SetPipePairPosition(pipe)
    end
end

function FlappyNord.SetGameLayerSlice(control, offsetX, offsetY, width, height, u1, u2, v2)
    if not control then return end

    if width <= 0 or height <= 0 then
        control:SetHidden(true)
        return
    end

    control:SetHidden(false)
    control:ClearAnchors()
    control:SetAnchor(
        TOPLEFT,
        FlappyNordRootGameWindowGameAreaGameLayer,
        TOPLEFT,
        offsetX,
        offsetY
    )
    control:SetDimensions(width, height)
    control:SetTextureCoords(u1, u2, 0, v2)
end

--==================================================
-- Collision Helpers
--==================================================

function FlappyNord.RectsOverlap(aLeft, aTop, aRight, aBottom, bLeft, bTop, bRight, bBottom)
    return aLeft < bRight
        and aRight > bLeft
        and aTop < bBottom
        and aBottom > bTop
end

--==================================================
-- Scoring
--==================================================

function FlappyNord.CheckPipeScore()
    if not FlappyNord.pipes then return end

    local nordLeft = FlappyNord.nordX

    for _, pipe in ipairs(FlappyNord.pipes) do
        if not pipe.scored then
            local pipeRight = pipe.x + FlappyNord.pipeWidth

            if pipeRight < nordLeft then
                pipe.scored = true
                FlappyNord.score = FlappyNord.score + 1

                if FlappyNord.score > FlappyNord.bestScore then
                    FlappyNord.bestScore = FlappyNord.score

                    if FlappyNord.savedVars then
                        FlappyNord.savedVars.bestScore = FlappyNord.bestScore
                    end
                end

                PlaySound(SOUNDS.SPINNER_UP)
                FlappyNord.UpdateScoreDisplay()
            end
        end
    end
end

--==================================================
-- Pipe Collision
--==================================================

function FlappyNord.IsNordCollidingWithPipe(pipe, nordLeft, nordTop, nordRight, nordBottom)
    local pipeLeft = pipe.x
    local pipeRight = pipe.x + FlappyNord.pipeWidth

    local topPipeTop = 0
    local topPipeBottom = pipe.gapY

    local bottomPipeTop = pipe.gapY + FlappyNord.gapHeight
    local bottomPipeBottom = FlappyNord.groundY

    local hitTopPipe = FlappyNord.RectsOverlap(
        nordLeft, nordTop, nordRight, nordBottom,
        pipeLeft, topPipeTop, pipeRight, topPipeBottom
    )

    local hitBottomPipe = FlappyNord.RectsOverlap(
        nordLeft, nordTop, nordRight, nordBottom,
        pipeLeft, bottomPipeTop, pipeRight, bottomPipeBottom
    )

    return hitTopPipe or hitBottomPipe
end

function FlappyNord.CheckPipeCollision()
    if not FlappyNord.pipes then return end

    local nordLeft, nordTop, nordRight, nordBottom = FlappyNord.GetNordBounds()

    for _, pipe in ipairs(FlappyNord.pipes) do
        if FlappyNord.IsNordCollidingWithPipe(pipe, nordLeft, nordTop, nordRight, nordBottom) then
            FlappyNord.GameOver()
            return
        end
    end
end

--==================================================
-- Ground Placement
--==================================================

function FlappyNord.SetGroundPositions(x1, x2)
    FlappyNord.ground1X = x1
    FlappyNord.ground2X = x2

    local ground1 = FlappyNord.ground1Control
    local ground2 = FlappyNord.ground2Control
    if not ground1 or not ground2 then return end

    local gameAreaWidth = 360

    local function PlaceGroundSegment(control, x)
        local visibleLeft = math.max(0, x)
        local visibleRight = math.min(gameAreaWidth, x + FlappyNord.groundWidth)
        local visibleWidth = visibleRight - visibleLeft

        local u1 = (visibleLeft - x) / FlappyNord.groundWidth
        local u2 = (visibleRight - x) / FlappyNord.groundWidth

        FlappyNord.SetGameLayerSlice(
            control,
            visibleLeft,
            FlappyNord.groundY,
            visibleWidth,
            FlappyNord.groundHeight,
            u1,
            u2,
            1
        )
    end

    PlaceGroundSegment(ground1, x1)
    PlaceGroundSegment(ground2, x2)
end

--==================================================
-- Pipe Placement
--==================================================

function FlappyNord.SetPipePairPosition(pipe)
    local x = pipe.x
    local gapY = pipe.gapY

    local topBody = pipe.topBody
    local topCap = pipe.topCap
    local bottomCap = pipe.bottomCap
    local bottomBody = pipe.bottomBody

    if not topBody or not topCap or not bottomCap or not bottomBody then return end

    local gameAreaWidth = 360
    local capHeight = FlappyNord.pipeCapHeight

    local topPipeHeight = gapY
    local bottomPipeY = gapY + FlappyNord.gapHeight
    local bottomPipeHeight = FlappyNord.groundY - bottomPipeY

    local visibleLeft = math.max(0, x)
    local visibleRight = math.min(gameAreaWidth, x + FlappyNord.pipeWidth)
    local visibleWidth = visibleRight - visibleLeft

    local u1 = (visibleLeft - x) / FlappyNord.pipeWidth
    local u2 = (visibleRight - x) / FlappyNord.pipeWidth

    --==============================
    -- Top Pipe
    --==============================
    local topBodyHeight = math.max(0, topPipeHeight - capHeight)
    local topCapY = topBodyHeight

    FlappyNord.SetGameLayerSlice(
        topBody,
        visibleLeft,
        0,
        visibleWidth,
        topBodyHeight,
        u1,
        u2,
        topBodyHeight / FlappyNord.pipeBodyTextureHeight
    )

    if topPipeHeight > 0 then
        local visibleTopCapHeight = math.min(capHeight, topPipeHeight)

        FlappyNord.SetGameLayerSlice(
            topCap,
            visibleLeft,
            topCapY,
            visibleWidth,
            visibleTopCapHeight,
            u1,
            u2,
            visibleTopCapHeight / capHeight
        )
    else
        topCap:SetHidden(true)
    end

    --==============================
    -- Bottom Pipe
    --==============================
    local bottomCapVisibleHeight = math.min(capHeight, bottomPipeHeight)
    local bottomBodyHeight = math.max(0, bottomPipeHeight - capHeight)
    local bottomBodyY = bottomPipeY + bottomCapVisibleHeight

    FlappyNord.SetGameLayerSlice(
        bottomCap,
        visibleLeft,
        bottomPipeY,
        visibleWidth,
        bottomCapVisibleHeight,
        u1,
        u2,
        bottomCapVisibleHeight / capHeight
    )

    FlappyNord.SetGameLayerSlice(
        bottomBody,
        visibleLeft,
        bottomBodyY,
        visibleWidth,
        bottomBodyHeight,
        u1,
        u2,
        bottomBodyHeight / FlappyNord.pipeBodyTextureHeight
    )
end

--==================================================
-- Obstacle Setup
--==================================================

function FlappyNord.CreatePipe(topBody, topCap, bottomCap, bottomBody, x)
    return {
        topBody = topBody,
        topCap = topCap,
        bottomCap = bottomCap,
        bottomBody = bottomBody,
        x = x,
        gapY = FlappyNord.GetRandomGapY(),
        scored = false,
    }
end

function FlappyNord.ResetPipe(pipe, x)
    if not pipe then return end

    pipe.x = x
    pipe.gapY = FlappyNord.GetRandomGapY()
    pipe.scored = false
end

function FlappyNord.CreateObstacleSet()
    FlappyNord.ground1Control = FlappyNordRootGameWindowGameAreaGameLayerGround1
    FlappyNord.ground2Control = FlappyNordRootGameWindowGameAreaGameLayerGround2

    FlappyNord.pipes = {
        FlappyNord.CreatePipe(
            FlappyNordRootGameWindowGameAreaGameLayerPipeTopBody,
            FlappyNordRootGameWindowGameAreaGameLayerPipeTopCap,
            FlappyNordRootGameWindowGameAreaGameLayerPipeBottomCap,
            FlappyNordRootGameWindowGameAreaGameLayerPipeBottomBody,
            260
        ),
        FlappyNord.CreatePipe(
            FlappyNordRootGameWindowGameAreaGameLayerPipeTopBody2,
            FlappyNordRootGameWindowGameAreaGameLayerPipeTopCap2,
            FlappyNordRootGameWindowGameAreaGameLayerPipeBottomCap2,
            FlappyNordRootGameWindowGameAreaGameLayerPipeBottomBody2,
            260 + FlappyNord.pipeSpacing
        ),
    }
end

--==================================================
-- Obstacle Update
--==================================================

function FlappyNord.UpdateObstacles(dt)
    if not FlappyNord.pipes then return end
    if FlappyNord.gameState ~= "playing" then return end

    local farthestX = -math.huge

    for _, pipe in ipairs(FlappyNord.pipes) do
        if pipe.x > farthestX then
            farthestX = pipe.x
        end
    end

    for _, pipe in ipairs(FlappyNord.pipes) do
        pipe.x = pipe.x - (FlappyNord.pipeSpeed * dt)

        if pipe.x < -FlappyNord.pipeWidth then
            FlappyNord.ResetPipe(pipe, farthestX + FlappyNord.pipeSpacing)
            farthestX = pipe.x
        end

    end

    FlappyNord.RefreshPipePositions()

    FlappyNord.ground1X = FlappyNord.ground1X - (FlappyNord.groundSpeed * dt)
    FlappyNord.ground2X = FlappyNord.ground2X - (FlappyNord.groundSpeed * dt)

    if FlappyNord.ground1X <= -FlappyNord.groundWidth then
        FlappyNord.ground1X = FlappyNord.ground2X + FlappyNord.groundWidth
    end

    if FlappyNord.ground2X <= -FlappyNord.groundWidth then
        FlappyNord.ground2X = FlappyNord.ground1X + FlappyNord.groundWidth
    end

    FlappyNord.SetGroundPositions(FlappyNord.ground1X, FlappyNord.ground2X)
end

--==================================================
-- Reset
--==================================================

function FlappyNord.ResetObstacles()
    if not FlappyNord.pipes or not FlappyNord.pipes[1] or not FlappyNord.pipes[2] then return end

    FlappyNord.ResetPipe(FlappyNord.pipes[1], 360 + 40)
    FlappyNord.ResetPipe(FlappyNord.pipes[2], FlappyNord.pipes[1].x + FlappyNord.pipeSpacing)

    FlappyNord.RefreshPipePositions()
    FlappyNord.SetPipeHidden(FlappyNord.pipes[2], true)

    FlappyNord.SetGroundPositions(0, FlappyNord.groundWidth)
end
