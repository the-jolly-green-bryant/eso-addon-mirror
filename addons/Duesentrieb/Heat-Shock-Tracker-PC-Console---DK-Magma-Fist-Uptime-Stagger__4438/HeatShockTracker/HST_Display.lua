local HST = HeatShockTracker

---------------------------------------------------------------------------
-- CREATE INTERFACE ELEMENTS
---------------------------------------------------------------------------
function HST.CreateGuiElements()
    local wm = WINDOW_MANAGER

    -- PARENT
    HST.PARENT = wm:CreateTopLevelWindow(HST.NAME .. "Control")
    HST.PARENT:SetDimensions(HST.SV.iconSize, HST.SV.iconSize)
    HST.PARENT:SetClampedToScreen(true)
    HST.PARENT:SetMovable(not HST.SV.isLocked)
    HST.PARENT:SetMouseEnabled(not HST.SV.isLocked)
    HST.PARENT:SetHidden(true)

    HST.PARENT:SetHandler("OnMoveStop", function()
        HST.SV.offsetX = HST.PARENT:GetLeft()
        HST.SV.offsetY = HST.PARENT:GetTop()
    end)

    -- BACKGROUND
    HST.BG = wm:CreateControl("$(parent)_BG", HST.PARENT, CT_BACKDROP)
    HST.BG:SetAnchor(TOPLEFT, HST.PARENT, TOPLEFT)
    HST.BG:SetDimensions(HST.SV.iconSize, HST.SV.iconSize)
    local r, g, b, a = unpack(HST.SV.ColorStack0)
    HST.BG:SetCenterColor(r, g, b, a)
    HST.BG:SetEdgeColor(0, 0, 0, 1)
    HST.BG:SetEdgeTexture("", 1, 1, HST.SV.edgeThickness, 0)

    -- ABILITY ICON (STAGGER ICON FROM SLOT ID SHOULD WORK)
    HST.ICON = wm:CreateControl("$(parent)_Icon", HST.PARENT, CT_TEXTURE)
    HST.ICON:SetAnchor(CENTER, HST.PARENT, CENTER)
    local innerSize = math.max(1, HST.SV.iconSize - (HST.SV.borderThickness * 2))
    HST.ICON:SetDimensions(innerSize, innerSize)
    HST.ICON:SetTexture(GetAbilityIcon(HST.SLOT_ID))
    HST.ICON:SetDesaturation(HST.SV.iconDesaturation / 100)

    -- REMAINING DURATION (CENTER)
    HST.DURATION = wm:CreateControl("$(parent)_Duration", HST.PARENT, CT_LABEL)
    HST.DURATION:SetColor(unpack(HST.SV.TextColorStacks))
    HST.DURATION:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    HST.DURATION:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    HST.UpdateTimerPosition()

    -- STACK COUNT (TOP RIGHT)
    HST.STACK_LABEL = wm:CreateControl("$(parent)_Stacks", HST.PARENT, CT_LABEL)
    HST.STACK_LABEL:SetColor(unpack(HST.SV.TextColorStacks))
    HST.STACK_LABEL:SetAnchor(TOPRIGHT, HST.PARENT, TOPRIGHT, -7, 4)

    -- UPTIME PERCENTAGE (TOP LET)
    HST.UPTIME_LABEL = wm:CreateControl("$(parent)_Uptime", HST.PARENT, CT_LABEL)
    HST.UPTIME_LABEL:SetColor(unpack(HST.SV.TextColorStacks))
    HST.UPTIME_LABEL:SetAnchor(TOPLEFT, HST.PARENT, TOPLEFT, 7, 4)

    -- BOSS LABEL (ABOVE TRACKER)
    HST.BOSS_LABEL = wm:CreateControl("$(parent)_BossLabel", HST.PARENT, CT_LABEL)
    HST.BOSS_LABEL:SetColor(unpack(HST.SV.TextColorBoss))
    HST.BOSS_LABEL:SetText("BOSS")
    HST.BOSS_LABEL:SetHidden(HST.SV.isHideBossLabel)
    HST.UpdateBossPosition()

    HST.UpdateFonts()
end

---------------------------------------------------------------------------
-- UPDATE TIMER POSITION
---------------------------------------------------------------------------
function HST.UpdateTimerPosition()
    HST.DURATION:ClearAnchors()

    if HST.SV.isHideUptime and HST.SV.isHideStacks then
        HST.DURATION:SetAnchor(CENTER, HST.PARENT, CENTER, 0, HST.SV.offsetYTimer - HST.Default.offsetYTimer)
    else
        HST.DURATION:SetAnchor(CENTER, HST.PARENT, CENTER, 0, HST.SV.offsetYTimer)
    end
end

---------------------------------------------------------------------------
-- UPDATE BOSS LABEL POSITION
---------------------------------------------------------------------------
function HST.UpdateBossPosition()
    HST.BOSS_LABEL:ClearAnchors()
    HST.BOSS_LABEL:SetAnchor(BOTTOM, HST.PARENT, TOP, 0, HST.SV.offsetYBoss)
end

---------------------------------------------------------------------------
-- GET CURRENT FONT STYLE
---------------------------------------------------------------------------
function HST.GetFontStyle()
    return HST.SV.isThickOutline and "thick-outline" or "soft-shadow-thick"
end

---------------------------------------------------------------------------
-- UPDATE FONT SIZES
---------------------------------------------------------------------------
function HST.UpdateFonts()
    local style = HST.GetFontStyle()
    HST.DURATION:SetFont("$(BOLD_FONT)|" .. HST.SV.fontSizeTimer .. "|" .. style)
    HST.STACK_LABEL:SetFont("$(BOLD_FONT)|" .. HST.SV.fontSizeStacks .. "|" .. style)
    HST.UPTIME_LABEL:SetFont("$(BOLD_FONT)|" .. HST.SV.fontSizeUptime .. "|" .. style)
    HST.BOSS_LABEL:SetFont("$(BOLD_FONT)|" .. HST.SV.fontSizeBoss .. "|" .. style)
end

---------------------------------------------------------------------------
-- ANIMATION
---------------------------------------------------------------------------
function HST.PlayAnimation()
    if HST.isAnimationActive then return end
    HST.isAnimationActive = true

    local durationGrow = math.floor(HST.SV.animationDuration / 3)
    local durationShrink = HST.SV.animationDuration - durationGrow

    -- CREATE TIMELINE AND ANIMATION IF NOT YET CREATE
    if not HST.TIMELINE then
        HST.TIMELINE = ANIMATION_MANAGER:CreateTimeline()

        HST.ANIMATION_SCALEUP = HST.TIMELINE:InsertAnimation(ANIMATION_SCALE, HST.DURATION, 0)
        HST.ANIMATION_SCALEUP:SetEasingFunction(ZO_EaseInQuadratic)

        HST.ANIMATION_SCALEDOWN = HST.TIMELINE:InsertAnimation(ANIMATION_SCALE, HST.DURATION, 0)
        HST.ANIMATION_SCALEDOWN:SetEasingFunction(ZO_EaseOutQuadratic)

        -- RESET ON STOP
        HST.TIMELINE:SetHandler('OnStop', function()
            HST.DURATION:SetScale(1.0)
            HST.isAnimationActive = false
        end)
    end

    -- IF ANIMATION RUNS STOP IT.. PREVENTS CRASHES
    if HST.TIMELINE:IsPlaying() then HST.TIMELINE:Stop() end

    -- SET NEW VALUES
    HST.ANIMATION_SCALEUP:SetScaleValues(1.0, HST.SV.animationScale / 100)
    HST.ANIMATION_SCALEUP:SetDuration(durationGrow)

    HST.ANIMATION_SCALEDOWN:SetScaleValues(HST.SV.animationScale / 100, 1.0)
    HST.ANIMATION_SCALEDOWN:SetDuration(durationShrink)
    HST.TIMELINE:SetAnimationOffset(HST.ANIMATION_SCALEDOWN, durationGrow)

    HST.TIMELINE:PlayFromStart()
end

---------------------------------------------------------------------------
-- UPDATE LAYOUT AND COLORS
---------------------------------------------------------------------------
function HST.UpdateVisuals()
    local currentTime = GetGameTimeMilliseconds()

    -- UPDATE BORDER COLOR BASED ON CURRENT STACKS
    local colorArray = HST.SV["ColorStack" .. HST.currentStacks] or HST.SV.ColorStack0
    local r, g, b, a = unpack(colorArray)
    HST.BG:SetCenterColor(r, g, b, a)

    if HST.SV.edgeThickness == 0 then
        -- HIDE EDGE WHNN SET TO 0
        HST.BG:SetEdgeColor(0, 0, 0, 0)
    else
        HST.BG:SetEdgeColor(0, 0, 0, 1)
    end

    -- CALCULATE REMAINING TIME
    local remainingTime = math.max(0, (HST.StackEndTimes[1] - currentTime) / 1000)
    local percentage = 100 / (HST.DURATION_MS / 1000) * remainingTime


    -- SET TEXT (WILL SHOW 0 IF NO TIME REMAINING)
    if remainingTime > 0 then
        local stringTime = string.format("%.1f", remainingTime)
        HST.DURATION:SetText(stringTime)
    else
        HST.DURATION:SetText("0")
    end

    -- SET TIMER COLOR
    if HST.SV.isColoredTimer then
        local timerColor = HST.GetPercentageColor(percentage)
        HST.DURATION:SetColor(unpack(timerColor))
    else
        HST.DURATION:SetColor(unpack(HST.SV.TextColorTimer))
    end

    HST.BOSS_LABEL:SetHidden(HST.SV.isHideBossLabel or not (HST.isTrackedBoss or HST.isForceShow or HST.isMenuPreview))
    if HST.isForceShow or HST.isMenuPreview then
        HST.BOSS_LABEL:SetText("BOSS1")
    else
        HST.BOSS_LABEL:SetText(HST.trackedBossLabel or "BOSS")
    end

    if HST.SV.isColoredBossLabel then
        HST.BOSS_LABEL:SetColor(unpack(colorArray))
    else
        HST.BOSS_LABEL:SetColor(unpack(HST.SV.TextColorBoss))
    end

    -- UPDATE STACKS
    HST.STACK_LABEL:SetHidden(HST.SV.isHideStacks)
    HST.STACK_LABEL:SetText(tostring(HST.currentStacks))
    HST.STACK_LABEL:SetColor(unpack(HST.SV.TextColorStacks))

    -- UPDATE UPTIME
    HST.UPTIME_LABEL:SetHidden(HST.SV.isHideUptime)
    HST.UPTIME_LABEL:SetText(string.format("%.0f%%", HST.Percentages[3]))
    HST.UPTIME_LABEL:SetColor(unpack(HST.SV.TextColorUptime))
end

---------------------------------------------------------------------------
-- RESET POSITION TO DEFAULT
---------------------------------------------------------------------------
function HST.SetDefaultPosition()
    HST.PARENT:ClearAnchors()
    HST.PARENT:SetAnchor(CENTER, GuiRoot, CENTER, 0, HST.Default.offsetY)
    HST.SV.offsetX = HST.PARENT:GetLeft()
    HST.SV.offsetY = HST.PARENT:GetTop()
end