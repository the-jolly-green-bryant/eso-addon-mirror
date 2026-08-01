local TT = TargetTaunt

---------------------------------------------------------------------------
-- CREATE INTERFACE ELEMENTS
---------------------------------------------------------------------------
function TT.CreateReticleElements()
    local WM = WINDOW_MANAGER

    -- MAIN CONTAINER (RETICLE)
    TT.RETICLE = WM:CreateTopLevelWindow(TT.NAME .. "_RETICLE")
    TT.RETICLE:SetDimensions(200, 40)
    TT.RETICLE:SetClampedToScreen(true)
    TT.RETICLE:SetMovable(false)
    TT.RETICLE:SetMouseEnabled(false)

    TT.RETICLE:SetDrawTier(TT.SV.reticleDrawTier)
    TT.RETICLE:SetDrawLayer(TT.SV.reticleDrawLayer)

    TT.RETICLE:SetHidden(true)

    -- SAVE POSITION ON MOVE STOP
    TT.RETICLE:SetHandler("OnMoveStop", function() TT.SV.reticleOffsetX = TT.RETICLE:GetLeft() TT.SV.reticleOffsetY = TT.RETICLE:GetTop() end)

    -- NAME LABEL
    TT.RETICLE_NAME = WM:CreateControl("$(parent)_NAME", TT.RETICLE, CT_LABEL)
    TT.RETICLE_NAME:SetAnchor(CENTER, TT.RETICLE, CENTER)
    TT.RETICLE_NAME:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    TT.RETICLE_NAME:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
    TT.RETICLE_NAME:SetHidden(not TT.SV.isEnabledReticleName)

    -- TIME LABEL
    TT.RETICLE_TIME = WM:CreateControl("$(parent)_TIME", TT.RETICLE, CT_LABEL)
    TT.RETICLE_TIME:SetAnchor(TOP, TT.RETICLE_NAME, BOTTOM)
    TT.RETICLE_TIME:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    TT.RETICLE_TIME:SetVerticalAlignment(TEXT_ALIGN_TOP)
    TT.RETICLE_TIME:SetHidden(not TT.SV.isEnabledTimer)

    -- MARKER PREVIEW (2D) ONLY IN MENU
    TT.MARKER_PREVIEW = WM:CreateControl("$(parent)_MARKER_PREVIEW", TT.RETICLE, CT_TEXTURE)
    TT.MARKER_PREVIEW:SetAnchor(BOTTOM, TT.RETICLE_NAME, TOP, 0, 0)
    TT.MARKER_PREVIEW:SetHidden(true)

    TT.UpdateFonts()
    TT.UpdateReticleAnchors()
end

---------------------------------------------------------------------------
-- UPDATE RETICLE ANCHORS
---------------------------------------------------------------------------
function TT.UpdateReticleAnchors()
    TT.RETICLE_NAME:ClearAnchors()
    TT.RETICLE_TIME:ClearAnchors()

    if TT.SV.isEnabledReticleName then
        TT.RETICLE_NAME:SetAnchor(CENTER, TT.RETICLE, CENTER)
        TT.RETICLE_TIME:SetAnchor(TOP, TT.RETICLE_NAME, BOTTOM)
        TT.RETICLE_TIME:SetVerticalAlignment(TEXT_ALIGN_TOP)
    else
        TT.RETICLE_TIME:SetAnchor(CENTER, TT.RETICLE, CENTER)
        TT.RETICLE_TIME:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    end
end

---------------------------------------------------------------------------
-- CALCULATE ROW HEIGHT
---------------------------------------------------------------------------
function TT.GetTrackerRowHeight()
    return TT.SV.trackerFontSize + (2 * TT.SV.trackerEdgeY)
end

---------------------------------------------------------------------------
-- CREATE TRACKER UI
---------------------------------------------------------------------------
function TT.CreateTrackerElements()
    -- PROTOTYP.. NOT GLOBAL YET. WILL PROBL. STAY THIS WAY
    -- AT THIS POINT.. I CAN'T EVEN REMEMBER WHAT I MEANT BY THAT. WILL DEF. STAY THIS WAY LOL
    local rowHeight = TT.GetTrackerRowHeight()

    -- TRACKER WINDOW
    TT.TRACKER = WINDOW_MANAGER:CreateTopLevelWindow(TT.NAME .. "_TRACKER")
    TT.TRACKER:SetMovable(false)
    TT.TRACKER:SetMouseEnabled(false)
    TT.TRACKER:SetClampedToScreen(true)

    TT.TRACKER:SetDrawTier(TT.SV.trackerDrawTier)
    TT.TRACKER:SetDrawLayer(TT.SV.trackerDrawLayer)

    -- DIMENSION CONSTRAINTS AND SAVED SIZE/POSITION
    TT.TRACKER:SetDimensions(TT.SV.trackerWidth, TT.SV.trackerHeight)
    TT.TRACKER:ClearAnchors()
    TT.TRACKER:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TT.SV.trackerOffsetX, TT.SV.trackerOffsetY)

    -- NEW HANDLER WITH GROW STUFF
    TT.TRACKER:SetHandler("OnMoveStop", function()
        TT.SV.trackerOffsetX = TT.TRACKER:GetLeft()
        if TT.SV.trackerGrowUpwards then
            TT.SV.trackerOffsetY = TT.TRACKER:GetBottom()
        else
            TT.SV.trackerOffsetY = TT.TRACKER:GetTop()
        end
    end)

    TT.TRACKER:SetHidden(true)

    -- ROWS
    TT.TRACKER_ROWS = {}

    for i = 1, TT.SV.trackerMaxRows do
        local CONTROL = WINDOW_MANAGER:CreateControl("$(parent)_INDEX_" .. i, TT.TRACKER, CT_BACKDROP)
        CONTROL:SetDimensions(TT.SV.trackerWidth, rowHeight)
        CONTROL:SetCenterColor(0, 0, 0, 0)
        CONTROL:SetEdgeColor(0, 0, 0, 0)
        -- https://wiki.esoui.com/Controls
        -- SetEdgeTexture(string filename, number edgeFileWidth, number edgeFileHeight, number edgeSize, number edgeFilePadding) 
        CONTROL:SetEdgeTexture("", 1, 1, TT.SV.trackerEdgeThickness, 0)
        CONTROL:SetHidden(false)

        if i == 1 then
            CONTROL:SetAnchor(TOPLEFT, TT.TRACKER, TOPLEFT, 0, 0)
        else
            CONTROL:SetAnchor(TOPLEFT, TT.TRACKER_ROWS[i - 1].CONTROL, BOTTOMLEFT, 0, TT.SV.trackerDistanceY)
        end

        local NAME = WINDOW_MANAGER:CreateControl("$(parent)_NAME", CONTROL, CT_LABEL)
        NAME:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        NAME:SetVerticalAlignment(TEXT_ALIGN_CENTER)

        local TIME = WINDOW_MANAGER:CreateControl("$(parent)_TIME", CONTROL, CT_LABEL)
        TIME:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        TIME:SetVerticalAlignment(TEXT_ALIGN_CENTER)

        local TIMELINE = ANIMATION_MANAGER:CreateTimeline()
        local SCALEUP = TIMELINE:InsertAnimation(ANIMATION_SCALE, NAME, 0)
        SCALEUP:SetEasingFunction(ZO_EaseInQuadratic)
        local SCALEDOWN = TIMELINE:InsertAnimation(ANIMATION_SCALE, NAME, 0)
        SCALEDOWN:SetEasingFunction(ZO_EaseOutQuadratic)

        TIMELINE:SetHandler('OnStop', function() NAME:SetScale(1.0) end)

        TT.TRACKER_ROWS[i] = {
            CONTROL = CONTROL,
            NAME = NAME,
            TIME = TIME,
            TIMELINE = TIMELINE,
            SCALEUP = SCALEUP,
            SCALEDOWN = SCALEDOWN
        }
    end
end

---------------------------------------------------------------------------
-- TRACKER DIMENSIONS
---------------------------------------------------------------------------
function TT.UpdateTrackerDimensions()
    local rowHeight = TT.GetTrackerRowHeight()
    local offsetY = TT.FONT_WEIGHT_OFFSETS[TT.SV.trackerFontWeight] or 0

    TT.TRACKER:SetWidth(TT.SV.trackerWidth)

    if TT.isTrackerUnlocked then
        local totalHeight = (TT.SV.trackerMaxRows * rowHeight) + ((TT.SV.trackerMaxRows - 1) * TT.SV.trackerDistanceY)
        TT.TRACKER:SetHeight(totalHeight)
    end

    for i = 1, TT.SV.trackerMaxRows do
        if TT.TRACKER_ROWS[i] then
            TT.TRACKER_ROWS[i].CONTROL:SetDimensions(TT.SV.trackerWidth, rowHeight)
            TT.TRACKER_ROWS[i].CONTROL:SetEdgeTexture("", 1, 1, TT.SV.trackerEdgeThickness, 0)

            TT.TRACKER_ROWS[i].CONTROL:ClearAnchors()

            if TT.SV.trackerGrowUpwards then
                -- GROW UPWARDS
                if i == 1 then
                    TT.TRACKER_ROWS[i].CONTROL:SetAnchor(BOTTOMLEFT, TT.TRACKER, BOTTOMLEFT, 0, 0)
                else
                    TT.TRACKER_ROWS[i].CONTROL:SetAnchor(BOTTOMLEFT, TT.TRACKER_ROWS[i - 1].CONTROL, TOPLEFT, 0, -TT.SV.trackerDistanceY)
                end
            else
                -- GROW DOWNWARDS
                if i == 1 then
                    TT.TRACKER_ROWS[i].CONTROL:SetAnchor(TOPLEFT, TT.TRACKER, TOPLEFT, 0, 0)
                else
                    TT.TRACKER_ROWS[i].CONTROL:SetAnchor(TOPLEFT, TT.TRACKER_ROWS[i - 1].CONTROL, BOTTOMLEFT, 0, TT.SV.trackerDistanceY)
                end
            end

            --local offsetX = TT.SV.trackerEdgeX + TT.SV.trackerFontSize
            TT.TRACKER_ROWS[i].NAME:ClearAnchors()
            TT.TRACKER_ROWS[i].NAME:SetAnchor(LEFT, TT.TRACKER_ROWS[i].CONTROL, LEFT, TT.SV.trackerEdgeX, offsetY)

            TT.TRACKER_ROWS[i].TIME:ClearAnchors()
            TT.TRACKER_ROWS[i].TIME:SetAnchor(RIGHT, TT.TRACKER_ROWS[i].CONTROL, RIGHT, -TT.SV.trackerEdgeX, offsetY)
        end
    end
end

---------------------------------------------------------------------------
-- UPDATE FONTS BASED ON SETTINGS
---------------------------------------------------------------------------
function TT.UpdateFonts()
    -- RETICLE
    local reticleFontString = TT.SV.reticleFontStyle .. "|" .. TT.SV.reticleFontSize .. "|" .. TT.SV.reticleFontWeight
    TT.RETICLE_NAME:SetFont(reticleFontString)
    TT.RETICLE_TIME:SetFont(reticleFontString)

    -- TRACKER
    if #TT.TRACKER_ROWS > 0 then
        local trackerFontString = TT.SV.trackerFontStyle .. "|" .. TT.SV.trackerFontSize .. "|" .. TT.SV.trackerFontWeight

        for i = 1, TT.SV.trackerMaxRows do
            if TT.TRACKER_ROWS[i] then
                TT.TRACKER_ROWS[i].NAME:SetFont(trackerFontString)
                TT.TRACKER_ROWS[i].TIME:SetFont(trackerFontString)
            end
        end

        TT.UpdateTrackerDimensions()
    end
end

---------------------------------------------------------------------------
-- UPDATE ESO TARGET NAMEPLATES
-- https://wiki.esoui.com/API

-- GetNameplateKeyboardFont() -- Returns: string fontName, FontStyle fontStyle
-- SetNameplateKeyboardFont(string fontName, FontStyle fontStyle)

-- GetNameplateGamepadFont() -- Returns: string fontName, FontStyle fontStyle
-- SetNameplateGamepadFont(string fontName, FontStyle fontStyle)
---------------------------------------------------------------------------
function TT.UpdateNameplates()
    -- local fontName, fontStyle
    -- zo_callLater(function() d("TT.UpdateNameplates()") end, 5000)

    if TT.isConsole then
        -- fontName, fontStyle = GetNameplateGamepadFont()
        -- d("[TT DEBUG] <Console> fontName: " .. fontName .. " fontStyle: " .. fontStyle)
        SetNameplateGamepadFont(TT.SV.nameplateFontStyle .. "|" .. TT.SV.nameplateFontSize, TT.SV.nameplateFontEnum)
    else
        -- fontName, fontStyle = GetNameplateKeyboardFont()
        -- d("[TT DEBUG] <Keyboard> fontName: " .. fontName .. " fontStyle: " .. fontStyle)
        SetNameplateKeyboardFont(TT.SV.nameplateFontStyle .. "|" .. TT.SV.nameplateFontSize, TT.SV.nameplateFontEnum)
    end
end

---------------------------------------------------------------------------
-- RESET POSITIONS
---------------------------------------------------------------------------
function TT.ResetReticlePosition()
    TT.RETICLE:ClearAnchors()
    TT.RETICLE:SetAnchor(CENTER, GuiRoot, CENTER, 0, TT.default.reticleOffsetY)
    TT.SV.reticleOffsetX = TT.RETICLE:GetLeft()
    TT.SV.reticleOffsetY = TT.RETICLE:GetTop()
end

-- function TT.ResetTrackerPosition()
--     if TT.TRACKER then
--         TT.TRACKER:ClearAnchors()

--         -- ALSO WITH GROW DIRECTION NOW.. SHOULD WORK LIKE THIS? WHO KNOWS.. SERVER IS DOWN.
--         local ANCHOR = TT.SV.trackerGrowUpwards and BOTTOMLEFT or TOPLEFT
--         TT.TRACKER:SetAnchor(ANCHOR, GuiRoot, TOPLEFT, TT.SV.trackerOffsetX, TT.SV.trackerOffsetY)

--         TT.SV.trackerOffsetX = TT.TRACKER:GetLeft()
--         TT.SV.trackerOffsetY = TT.SV.trackerGrowUpwards and TT.TRACKER:GetBottom() or TT.TRACKER:GetTop()
--     end
-- end

function TT.ResetTrackerPosition()
    if TT.TRACKER then
        TT.TRACKER:ClearAnchors()
        local ANCHOR = TT.SV.trackerGrowUpwards and BOTTOMLEFT or TOPLEFT
        TT.TRACKER:SetAnchor(ANCHOR, GuiRoot, TOPLEFT, TT.SV.trackerOffsetX, TT.SV.trackerOffsetY)
    end
end

function TT.ResetAllPositions()
    TT.ResetReticlePosition()
    TT.ResetTrackerPosition()
end

---------------------------------------------------------------------------
-- UPDATE RETICLE UI (RENDER)
---------------------------------------------------------------------------
function TT.RenderReticleDisplay()
    if TT.isAnimationActive or TT.isWarningActive then return end

    local tauntState, timeRemaining = TT.GetReticleTauntState()
    local isImportant = TT.IsTargetImportant(GetUnitDifficulty("reticleover"), "reticleover", GetUnitName("reticleover"))

    if not isImportant and TT.SV.isEnabledFlagHarmlessImportant then
        if tauntState ~= TT.TAUNT_STATE_NONE then
            isImportant = true
        end
    end

    local r, g, b, a, timeString = TT.GetTauntStateColorTime(tauntState, timeRemaining, isImportant)

    -- FADE FLASH
    local currentTime = GetFrameTimeSeconds()
    if tauntState == TT.TAUNT_STATE_NONE and TT.reticleExpireTimeHighlight > currentTime then
        r, g, b, a = 1, 1, 1, 1
    end

    TT.RETICLE_NAME:SetColor(r, g, b, a)
    TT.RETICLE_TIME:SetColor(r, g, b, a)
    TT.RETICLE_TIME:SetText(timeString)
end

---------------------------------------------------------------------------
-- RENDER TRACKER DISPLAY (USING CENTRAL DATA)
---------------------------------------------------------------------------
function TT.RenderTrackerDisplay()
    if TT.isTrackerUnlocked then return end

    local currentTime = GetFrameTimeSeconds()
    local displayCount = 0

    for i = 1, TT.SV.trackerMaxRows do
        local TRACKER_ROW = TT.TRACKER_ROWS[i]
        local unitId = TT.targetList[i]

        if unitId then
            local targetData = TT.targetData[unitId]

            if targetData and targetData.isActive then
                displayCount = displayCount + 1
                TRACKER_ROW.CONTROL:SetHidden(false)

                local timeRemaining = 0
                if targetData.endTime > 0 then
                    timeRemaining = math.max(0, targetData.endTime - currentTime)
                end

                local r, g, b, a, timeString = TT.GetTauntStateColorTime(targetData.tauntState, timeRemaining, targetData.isImportant)

                local isCurrentTarget = false
                if targetData.name == TT.currentReticleName then
                    if targetData.endTime > 0 or TT.currentReticleEndTime > 0 then
                        if math.abs(targetData.endTime - TT.currentReticleEndTime) < 0.05 then
                            isCurrentTarget = true
                        end
                    else
                        isCurrentTarget = true
                    end
                end

                local fR, fG, fB, fA, cR, cG, cB, cA, eR, eG, eB, eA = TT.GetTrackerRowColors(r, g, b, a, isCurrentTarget)

                if targetData.tauntState == TT.TAUNT_STATE_NONE and targetData.expireTimeHighlight > currentTime then
                    -- d("YOYOYO " .. currentTime)
                    fR, fG, fB, fA, cR, cG, cB, cA, eR, eG, eB, eA = TT.GetTrackerRowColors(1, 1, 1, 1, true)
                end

                local displayName = TT.GetFormattedName(targetData.name, targetData.isBoss, TT.SV.trackerMaxLengthName)
                if isCurrentTarget then
                    local aR, aG, aB = math.min(1, fR + 2/3), math.min(1, fG + 2/3), math.min(1, fB + 2/3)
                    local colorArrow = string.format("%02X%02X%02X", aR * 255, aG * 255, aB * 255)
                    displayName = string.format("%s |c%s←|r", displayName, colorArrow)
                    TRACKER_ROW.CONTROL:SetEdgeTexture("", 1, 1, TT.SV.trackerEdgeThickness + 1, 0)
                else
                    TRACKER_ROW.CONTROL:SetEdgeTexture("", 1, 1, TT.SV.trackerEdgeThickness, 0)
                end

                TRACKER_ROW.NAME:SetColor(fR, fG, fB, fA)
                TRACKER_ROW.NAME:SetText(displayName)

                TRACKER_ROW.TIME:SetColor(fR, fG, fB, fA)
                TRACKER_ROW.TIME:SetText(timeString)

                TRACKER_ROW.CONTROL:SetCenterColor(cR, cG, cB, cA)
                TRACKER_ROW.CONTROL:SetEdgeColor(eR, eG, eB, eA)

                -- local alpha = TT.isCombat and 3/3 or 2/3
                -- TRACKER_ROW.CONTROL:SetAlpha(alpha)
            else
                TRACKER_ROW.CONTROL:SetHidden(true)
                if TRACKER_ROW.TIMELINE:IsPlaying() then
                    TRACKER_ROW.TIMELINE:Stop()
                    TRACKER_ROW.NAME:SetScale(1.0)
                end
            end
        else
            TRACKER_ROW.CONTROL:SetHidden(true)
            if TRACKER_ROW.TIMELINE:IsPlaying() then
                TRACKER_ROW.TIMELINE:Stop() 
                TRACKER_ROW.NAME:SetScale(1.0)
            end
        end
    end

    TT.ResizeTracker(displayCount)
end

---------------------------------------------------------------------------
-- RESIZE TRACKER WINDOW BASED ON ACTIVE TARGETS
---------------------------------------------------------------------------
function TT.ResizeTracker(displayCount)
    if TT.isTrackerUnlocked then return end

    if displayCount == 0 or not TT.IsTrackerEnabled() or TT.isHiddenByScene then
        TT.TRACKER:SetHidden(true)
    else
        TT.TRACKER:SetHidden(false)
        local totalHeight = (displayCount * TT.GetTrackerRowHeight()) + ((displayCount - 1) * TT.SV.trackerDistanceY)
        TT.TRACKER:SetHeight(totalHeight)
    end
end

---------------------------------------------------------------------------
-- RENDER PREVIEW TABLE
---------------------------------------------------------------------------
function TT.RenderTrackerPreview()
    local maxLength = TT.SV.trackerMaxLengthName

    -- PREVIEW SCENARIOS
    local previewData = {
        [1] = { name = "Active Target Taunt",   time = "7.5",       color = TT.SV.colorPlayer50,  isCurrentTarget = false },
        [2] = { name = "Boss Formatted",        time = "13.8",      color = TT.SV.colorPlayer100, isCurrentTarget = false },
        [3] = { name = "Taunt About To Expire", time = "2.8",       color = TT.SV.colorPlayer0,   isCurrentTarget = false },
        [4] = { name = "Current Target",        time = "14.9",      color = TT.SV.colorPlayer100, isCurrentTarget = true },
        [5] = { name = "Faded Taunt / Loose",   time = "0.0",       color = TT.SV.colorNone,      isCurrentTarget = false },
        [6] = { name = "Group Member Taunt",    time = "11.2",      color = TT.SV.colorOther,     isCurrentTarget = false },
        [7] = { name = "Taunt Immunity",        time = "IMMUNE",    color = TT.SV.colorImmune,    isCurrentTarget = false },
    }

    for i = 1, TT.SV.trackerMaxRows do
        local TRACKER_ROW = TT.TRACKER_ROWS[i]
        if not TRACKER_ROW then break end

        TRACKER_ROW.CONTROL:SetHidden(false)

        -- SCENARIO OR HARMLESS
        local data = previewData[i]
        if not data then
            data = { name = "Harmless Target " .. i, time = "0.0", color = TT.SV.colorHarmless, isCurrentTarget = false }
        end

        local cleanName = data.name
        local isBoss = false
        if i == 2 then isBoss = true end

        local displayName = TT.GetFormattedName(cleanName, isBoss, maxLength)
        if data.isCurrentTarget then
            displayName = displayName .. " ←"
            TRACKER_ROW.CONTROL:SetEdgeTexture("", 1, 1, TT.SV.trackerEdgeThickness + 1, 0)
        else
            TRACKER_ROW.CONTROL:SetEdgeTexture("", 1, 1, TT.SV.trackerEdgeThickness, 0)
        end

        local r, g, b, a = unpack(data.color)
        local fR, fG, fB, fA, cR, cG, cB, cA, eR, eG, eB, eA = TT.GetTrackerRowColors(r, g, b, a, data.isCurrentTarget)

        -- TEXT AND TEXTCOLOR
        TRACKER_ROW.NAME:SetText(displayName)
        TRACKER_ROW.NAME:SetColor(fR, fG, fB, fA)
        TRACKER_ROW.TIME:SetText(string.format("%s", data.time))
        TRACKER_ROW.TIME:SetColor(fR, fG, fB, fA)

        -- ROW COLORS
        TRACKER_ROW.CONTROL:SetCenterColor(cR, cG, cB, cA)
        TRACKER_ROW.CONTROL:SetEdgeColor(eR, eG, eB, eA)

        --TRACKER_ROW.CONTROL:SetAlpha(1 - (i / TT.SV.trackerMaxRows))
    end
end

---------------------------------------------------------------------------
-- PREVIEW MODE FOR UI POSITIONING
---------------------------------------------------------------------------
function TT.UpdatePreview()
    -- if (TT.isReticleUnlocked or TT.isMenuPreview) and TT.IsReticleEnabled() then
    if TT.isReticleUnlocked and TT.IsReticleEnabled() then
        TT.RETICLE:SetHidden(false)
        TT.RETICLE:SetMovable(TT.isReticleUnlocked)
        TT.RETICLE:SetMouseEnabled(TT.isReticleUnlocked)

        local r, g, b, a = unpack(TT.SV.colorPlayer100)
        TT.RETICLE_NAME:SetHidden(not TT.SV.isEnabledReticleName)
        TT.RETICLE_TIME:SetHidden(not TT.SV.isEnabledTimer)
        TT.RETICLE_NAME:SetText(TT.GetFormattedName("Target Name", true, TT.SV.reticleMaxLengthName))
        TT.RETICLE_NAME:SetColor(r, g, b, a)
        TT.RETICLE_TIME:SetText("15.0")
        TT.RETICLE_TIME:SetColor(r, g, b, a)

        if TT.MARKER_PREVIEW then
            if TT.SV.isEnabledFloatingMarker and TT.SV.floatingMarkerTexture ~= "" then
                TT.MARKER_PREVIEW:SetTexture(TT.SV.floatingMarkerTexture)
                TT.MARKER_PREVIEW:SetDimensions(TT.SV.floatingMarkerSize, TT.SV.floatingMarkerSize)
                TT.MARKER_PREVIEW:SetHidden(false)
            else
                TT.MARKER_PREVIEW:SetHidden(true)
            end
        end
    else
        TT.RETICLE:SetMovable(false)
        TT.RETICLE:SetMouseEnabled(false)
        TT.RETICLE:SetHidden(true)
        if TT.MARKER_PREVIEW then TT.MARKER_PREVIEW:SetHidden(true) end
        TT.UpdateReticleTarget()
    end

    if TT.isTrackerUnlocked and TT.IsTrackerEnabled() then
        TT.TRACKER:SetHidden(false)
        TT.TRACKER:SetMovable(true)
        TT.TRACKER:SetMouseEnabled(true)
        TT.UpdateTrackerDimensions()
        TT.RenderTrackerPreview()
    -- else
    --     TT.TRACKER:SetMovable(false)
    --     TT.TRACKER:SetMouseEnabled(false)
    --     TT.ResizeTracker(TT.activeTargetCount)
    --     TT.RenderTrackerDisplay()
    -- end
    else
        TT.TRACKER:SetMovable(false)
        TT.TRACKER:SetMouseEnabled(false)

        TT.TRACKER:ClearAnchors()
        local ANCHOR = TT.SV.trackerGrowUpwards and BOTTOMLEFT or TOPLEFT
        TT.TRACKER:SetAnchor(ANCHOR, GuiRoot, TOPLEFT, TT.SV.trackerOffsetX, TT.SV.trackerOffsetY)

        TT.ResizeTracker(TT.activeTargetCount)
        TT.RenderTrackerDisplay()
    end
end

---------------------------------------------------------------------------
-- SCENE CHANGE (HIDE ADDON WHEN IN MENU ETC)
---------------------------------------------------------------------------
function TT.OnStateChange(oldState, newState)
    if newState == SCENE_SHOWN then
        TT.isHiddenByScene = false
        TT.UpdateReticleTarget()
        TT.RenderTrackerDisplay()
    elseif newState == SCENE_HIDING then
        local isPreview = TT.isReticleUnlocked or TT.isTrackerUnlocked or TT.isMenuPreview

        if not isPreview then
            TT.isHiddenByScene = true
            TT.RETICLE:SetHidden(true)
            TT.TRACKER:SetHidden(true)
        end
    end
end