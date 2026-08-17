local CC = CombatCoordination

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name = "DisplayNotification",
    Parent = nil,
    Container = nil,
    LabelLine1 = nil,
    LabelLine2 = nil,

    isTransparent = false,
    isShowing = false,

    customEndTime = 0,
    customTotalTimeSec = 0,
    customLine1 = "",
    customLine2 = "",

    wipeEndTime = 0,
    portInEndTime = 0,
    portInZoneName = "",

    slayerEndTime = 0,
    slayerTotalTimeSec = 0,
    slayerSideId = 0,
    slayerTargetName = "",

    arkasisEndTime = 0,
    arkasisTotalTimeSec = 0,
    arkasisSideId = 0,

    lastTickSec = 0,

    breakStartTime = 0,
    breakEndTime = 0,
    breakTotalTimeSec = 0,
    finishedEndTime = 0,

    pullEndTime = 0,
    pullFinishedEndTime = 0,
    pullTotalTimeSec = 0,

    TimelineScale = nil,
    AnimScaleUp = nil,
    AnimScaleDown = nil,

    Default = {
        fontSize = 50,
        fontStyle = "$(BOLD_FONT)",
        fontWeight = "thick-outline",

        ColorLine1 = { 1, 1, 1, 1 },
        ColorLine2 = { 1, 1, 1, 1 },

        activeBreakEndTimeStamp = 0,
        activeBreakTotalTimeSec = 0,

        enableSound = true,
    },
    ---@type table|any
    SV = {},
}

----------------------------------------------------------------------------------------------------
-- CREATE UI
----------------------------------------------------------------------------------------------------
function Module:Create()
    if self.Parent then return end

    local offsetY = -(GuiRoot:GetHeight() / 4)

    self.Parent = WINDOW_MANAGER:CreateTopLevelWindow(CC.NAME .. "DisplayNotification_Parent")
    self.Parent:SetAnchor(CENTER, GuiRoot, CENTER, 0, offsetY)
    self.Parent:SetDimensions(450, 80)
    self.Parent:SetHidden(true)
    self.Parent:SetDrawTier(DT_HIGH)

    self.Parent:SetMouseEnabled(true)
    self.Parent:SetHandler("OnMouseUp", function(control, button, upInside)
        if upInside and button == MOUSE_BUTTON_INDEX_LEFT then
            self:ToggleTransparency()
        end
    end)

    self.Container = WINDOW_MANAGER:CreateControl(CC.NAME .. "DisplayNotification_Container", self.Parent, CT_CONTROL)
    self.Container:SetAnchorFill()

    self.LabelLine1 = WINDOW_MANAGER:CreateControl(CC.NAME .. "DisplayNotification_LabelLine1", self.Container, CT_LABEL)
    self.LabelLine1:SetAnchor(CENTER, self.Container, CENTER, 0, 0)
    self.LabelLine1:SetColor(1, 1, 1, 1)
    self.LabelLine1:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.LabelLine1:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    self.LabelLine2 = WINDOW_MANAGER:CreateControl(CC.NAME .. "DisplayNotification_LabelLine2", self.Container, CT_LABEL)
    self.LabelLine2:SetAnchor(TOP, self.LabelLine1, BOTTOM, 0, 0)
    self.LabelLine2:SetColor(1, 1, 1, 1)
    self.LabelLine2:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.LabelLine2:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    self.LabelLine3 = WINDOW_MANAGER:CreateControl(CC.NAME .. "DisplayNotification_LabelLine3", self.Container, CT_LABEL)
    self.LabelLine3:SetAnchor(TOP, self.LabelLine2, BOTTOM, 0, 0)
    self.LabelLine3:SetColor(0.75, 0.75, 0.75, 1)
    self.LabelLine3:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.LabelLine3:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    self:UpdateDimensions()

    -- THX ExoY FOR TEACHING ME THIS
    local Fragment = ZO_HUDFadeSceneFragment:New(self.Parent)
    Fragment:SetConditional(function()
        return self.isShowing
    end)
    HUD_SCENE:AddFragment(Fragment)
    HUD_UI_SCENE:AddFragment(Fragment)
end

----------------------------------------------------------------------------------------------------
-- UPDATE DIMENSIONS (AND FONTS)
----------------------------------------------------------------------------------------------------
function Module:UpdateDimensions()
    local fontSize1 = self.SV.fontSize
    local fontSize2 = math.floor(self.SV.fontSize * 2/3)
    local fontSize3 = math.floor(self.SV.fontSize * 1/3)

    self.LabelLine1:SetFont(string.format("%s|%d|%s", self.SV.fontStyle, fontSize1, self.SV.fontWeight))
    self.LabelLine2:SetFont(string.format("%s|%d|%s", self.SV.fontStyle, fontSize2, self.SV.fontWeight))
    self.LabelLine3:SetFont(string.format("%s|%d|%s", self.SV.fontStyle, fontSize3, self.SV.fontWeight))

    self.LabelLine1:ClearAnchors()
    self.LabelLine2:ClearAnchors()
    self.LabelLine3:ClearAnchors()

    self.LabelLine1:SetAnchor(CENTER, self.Container, CENTER, 0, 0)
    self.LabelLine2:SetAnchor(CENTER, self.LabelLine1, CENTER, 0, fontSize1 / 2 + fontSize2 / 2)
    self.LabelLine3:SetAnchor(CENTER, self.LabelLine1, CENTER, 0, fontSize1 / 2 + fontSize3 / 2)
end

----------------------------------------------------------------------------------------------------
-- TOGGLE TRANSPARENCY
----------------------------------------------------------------------------------------------------
function Module:ToggleTransparency()
    if not self.Container then return end

    self.isTransparent = not self.isTransparent

    if self.isTransparent then
        self.Container:SetAlpha(0.2)
    else
        self.Container:SetAlpha(1.0)
    end
end

----------------------------------------------------------------------------------------------------
-- RESET TRANSPARENCY
----------------------------------------------------------------------------------------------------
function Module:ResetTransparency()
    self.isTransparent = false
    if self.Container then
        self.Container:SetAlpha(1.0)
    end
end

----------------------------------------------------------------------------------------------------
-- CUSTOM NOTIFICATION
----------------------------------------------------------------------------------------------------
function Module:TriggerCustom(timeSec, line1, line2, playSound)
    if not timeSec or timeSec <= 0 then
        self.customEndTime = 0
        self.customTotalTimeSec = 0
        self.customLine1 = ""
        self.customLine2 = ""
        self:UpdateTick()
        return
    end

    if not self.Parent then self:Create() end

    self.customEndTime = GetGameTimeSeconds() + timeSec
    self.customTotalTimeSec = timeSec
    self.customLine1 = line1 or ""
    self.customLine2 = line2 or ""

    self.LabelLine1:SetColor(unpack(self.SV.ColorLine1))
    self.LabelLine2:SetColor(unpack(self.SV.ColorLine2))

    -- TODO: MAKE PLAYSOUND NOT A BOOL BUT FLEXIBLE TO ALSO TAKE A SOUNDS.STRING
    if playSound and self.SV.enableSound then
        CC.PlaySound(SOUNDS.ABILITY_ULTIMATE_READY, 2)
    end

    EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. "Notification_UpdateLoop")
    EVENT_MANAGER:RegisterForUpdate(CC.NAME .. "Notification_UpdateLoop", 100, function() self:UpdateTick() end)

    self:UpdateTick()
end

----------------------------------------------------------------------------------------------------
-- UPDATE TICK
----------------------------------------------------------------------------------------------------
function Module:UpdateTick()
    if not self.Parent then return end

    local currentTime = GetGameTimeSeconds()
    local showLabel = false
    local textLine1 = ""
    local textLine2 = ""
    local textLine3 = ""
    local ColorLine1 = self.SV.ColorLine1
    local ColorLine2 = self.SV.ColorLine2
    local ColorLine3 = { 0.75, 0.75, 0.75, 1 }

    ----------------------------------------------------------------------------------------------------
    -- CUSTOM
    ----------------------------------------------------------------------------------------------------
    if self.customEndTime > currentTime then
        showLabel = true

        textLine1 = self.customLine1
        if self.customLine2 ~= "" then
            textLine2 = self.customLine2
        end

    ----------------------------------------------------------------------------------------------------
    -- WIPE PLEASE
    ----------------------------------------------------------------------------------------------------
    elseif self.wipeEndTime > currentTime then
        local remaining = self.wipeEndTime - currentTime
        showLabel = true

        ColorLine1 = { 1, 0, 0, 1 }
        ColorLine2 = { 1, 1, 1, 1 }

        textLine1 = "WIPE PLEASE"
        textLine2 = "SAVE YOUR ULTS"

        -- TODO: EDGE COLOR

        local currentSec = math.ceil(remaining)
        if currentSec <= 5 and currentSec > 0 and currentSec ~= self.lastTickSec then
            self.lastTickSec = currentSec
            self:PlayAnimation(1.0, 1.25, 1.0)
        end

    elseif self.wipeEndTime > 0 then
        self.wipeEndTime = 0
        -- TODO: EDGE COLOR REMOVE

    ----------------------------------------------------------------------------------------------------
    -- PORT IN PLEASE
    ----------------------------------------------------------------------------------------------------
    elseif self.portInEndTime > currentTime then
        local remaining = self.portInEndTime - currentTime
        showLabel = true

        ColorLine1 = { 0, 0.75, 1, 1 }
        ColorLine2 = { 1, 1, 1, 1 }

        textLine1 = "PORT IN PLEASE"
        textLine2 = string.format("ZONE: %s", string.upper(self.portInZoneName))

        local currentSec = math.ceil(remaining)
        if currentSec <= 5 and currentSec > 0 and currentSec ~= self.lastTickSec then
            self.lastTickSec = currentSec
            self:PlayAnimation(1.0, 1.25, 1.0)
        end

    elseif self.portInEndTime > 0 then
        self.portInEndTime = 0

    ----------------------------------------------------------------------------------------------------
    -- SLAYER
    ----------------------------------------------------------------------------------------------------
    elseif self.slayerEndTime > currentTime then
        local remaining = self.slayerEndTime - currentTime
        showLabel = true

        local ColorSide = CC.SlayerAssistant.SV.ColorNone
        if self.slayerSideId == CC.SlayerAssistant.SIDE_LEFT then
            ColorSide = CC.SlayerAssistant.SV.ColorLeft
        elseif self.slayerSideId == CC.SlayerAssistant.SIDE_RIGHT then
            ColorSide = CC.SlayerAssistant.SV.ColorRight
        end
        ColorLine1 = { ColorSide[1], ColorSide[2], ColorSide[3], 1 }

        local colorTimeHex = CC.GetHexColorFromArray(CC.GetTimerColor(remaining, self.slayerTotalTimeSec)) or "|cFFFFFF"

        local arrow = ""
        if self.slayerSideId == CC.SlayerAssistant.SIDE_LEFT then
            arrow = "|cFFFFFF<<|r"
            textLine1 = string.format("LEFT SLAYER %s%.1f|r", colorTimeHex, remaining)
        elseif self.slayerSideId == CC.SlayerAssistant.SIDE_RIGHT then
            arrow = "|cFFFFFF>>|r"
            textLine1 = string.format("RIGHT SLAYER %s%.1f|r", colorTimeHex, remaining)
        else
            textLine1 = string.format("SLAYER %s%.1f|r", colorTimeHex, remaining)
        end

        if self.slayerTargetName ~= "" then
            textLine2 = string.format("%s %s %s", arrow, self.slayerTargetName, arrow)
            ColorLine2 = ColorLine1
        end

        local currentSec = math.ceil(remaining)
        if currentSec <= 10 and currentSec > 0 and currentSec ~= self.lastTickSec then
            self.lastTickSec = currentSec
            CC.PlaySound(SOUNDS.COUNTDOWN_TICK, 2)

            self:PlayAnimation(1.0, 1.25, 1.0)
        end

    ----------------------------------------------------------------------------------------------------
    -- SLAYER FINISHED
    ----------------------------------------------------------------------------------------------------
    elseif self.slayerEndTime > 0 then
        self.slayerEndTime = 0
        -- if self.SV.enableSound then
        --     CC.PlaySound(SOUNDS.ABILITY_ULTIMATE_READY, 2)
        -- end
    ----------------------------------------------------------------------------------------------------
    -- ARKASIS
    ----------------------------------------------------------------------------------------------------
    elseif self.arkasisEndTime > currentTime then
        local remaining = self.arkasisEndTime - currentTime
        showLabel = true

        local ColorSide = CC.ArkasisAssistant.SV.enableGameAoeFriendlyColor and CC.GetGameAoeFriendlyColor() or ((self.arkasisSideId == CC.ArkasisAssistant.SIDE_NONE) and CC.ArkasisAssistant.SV.ColorNone or CC.ArkasisAssistant.SV.Color)
        ColorLine1 = { ColorSide[1], ColorSide[2], ColorSide[3], 1 }
        ColorLine2 = ColorLine1

        local colorTimeHex = CC.GetHexColorFromArray(CC.GetTimerColor(remaining, self.arkasisTotalTimeSec)) or "|cFFFFFF"
        textLine1 = string.format("ARKASIS %s%.1f|r", colorTimeHex, remaining)

        if self.arkasisSideId == CC.ArkasisAssistant.SIDE_1 then
            local arrow = "|cFFFFFF<<|r"
            textLine2 = string.format("%s STACK 1 %s", arrow, arrow)
        elseif self.arkasisSideId == CC.ArkasisAssistant.SIDE_2 then
            local arrowLeft = "|cFFFFFF>>|r"
            local arrowRight = "|cFFFFFF<<|r"
            textLine2 = string.format("%s STACK 2 %s", arrowLeft, arrowRight)
        elseif self.arkasisSideId == CC.ArkasisAssistant.SIDE_3 then
            local arrow = "|cFFFFFF>>|r"
            textLine2 = string.format("%s STACK 3 %s", arrow, arrow)
        else
            textLine2 = ""
        end

        local currentSec = math.ceil(remaining)
        if currentSec <= 10 and currentSec > 0 and currentSec ~= self.lastTickSec then
            self.lastTickSec = currentSec
            CC.PlaySound(SOUNDS.COUNTDOWN_TICK, 2)
            self:PlayAnimation(1.0, 1.25, 1.0)
        end

    elseif self.arkasisEndTime > 0 then
        self.arkasisEndTime = 0
        -- if self.SV.enableSound then
        --     CC.PlaySound(SOUNDS.ABILITY_ULTIMATE_READY, 2)
        -- end

    ----------------------------------------------------------------------------------------------------
    -- PULL TIMER
    ----------------------------------------------------------------------------------------------------
    elseif self.pullEndTime > currentTime then
        local remaining = self.pullEndTime - currentTime
        showLabel = true

        local colorTimeHex = CC.GetHexColorFromArray(CC.GetTimerColor(remaining, self.pullTotalTimeSec)) or "|cFFFFFF"
        textLine1 = string.format("PULL %s%.1f|r", colorTimeHex, remaining)

        if self.pullTotalTimeSec > 5 then
            if remaining > 3 then
                textLine2 = "PREBUFF / DOTS"
            else
                textLine2 = "<< |cFF00FFGET READY!|r >>"
            end
            ColorLine2 = ColorLine1
        end

        local currentSec = math.ceil(remaining)
        if currentSec <= 10 and currentSec > 0 and currentSec ~= self.lastTickSec then
            self.lastTickSec = currentSec
            CC.PlaySound(SOUNDS.COUNTDOWN_TICK, 2)
            self:PlayAnimation(1.0, 1.25, 1.0)
        end

    elseif self.pullEndTime > 0 then
        self.pullEndTime = 0

        if self.pullTotalTimeSec > 3 then
            self.pullFinishedEndTime = currentTime + 1.0

            if self.SV.enableSound then
                CC.PlaySound(SOUNDS.DUEL_START, 1)
            end
            self:PlayAnimation(1.0, 1.5, 1.0)

            showLabel = true
            ColorLine1 = { 0, 1, 0, 1 }
            textLine1 = "PULL!"
        else
            self.pullFinishedEndTime = 0
            self.pullTotalTimeSec = 0
        end

    elseif self.pullFinishedEndTime > currentTime then
        showLabel = true
        ColorLine1 = { 0, 1, 0, 1 }
        textLine1 = "PULL!"

    ----------------------------------------------------------------------------------------------------
    -- BREAK TIMER
    ----------------------------------------------------------------------------------------------------
    elseif self.breakEndTime > currentTime then
        local remaining = math.ceil(self.breakEndTime - currentTime)
        local breakMinutes = math.floor(remaining / 60)
        local breakSeconds = remaining % 60

        showLabel = true

        local colorTimeHex = CC.GetHexColorFromArray(CC.GetTimerColor(remaining, self.breakTotalTimeSec)) or "|cFFFFFF"
        textLine1 = string.format("BREAK %s%d:%02d|r", colorTimeHex, breakMinutes, breakSeconds)
        textLine3 = "CLICK TO TOGGLE TRANSPARENCY"

    elseif self.breakEndTime > 0 then
        self:ResetTransparency()
        self.breakEndTime = 0
        self.finishedEndTime = currentTime + 5 -- "BREAK OVER"
        self.SV.activeBreakEndTimeStamp = 0
        self.SV.activeBreakTotalTimeSec = 0

        CC.PlaySound(SOUNDS.DUEL_WON, 2)

        self:PlayAnimation(1.0, 1.5, 1.0)

        showLabel = true
        ColorLine1 = { 0, 1, 0, 1 }
        textLine1 = "BREAK OVER"

    elseif self.finishedEndTime > currentTime then
        self:ResetTransparency()
        showLabel = true
        ColorLine1 = { 0, 1, 0, 1 }
        textLine1 = "BREAK OVER"
    end

    if showLabel then
        self.LabelLine1:SetText(textLine1)
        self.LabelLine1:SetColor(unpack(ColorLine1))
        self.LabelLine2:SetText(textLine2)
        self.LabelLine2:SetColor(unpack(ColorLine2))

        if self.LabelLine3 then
            self.LabelLine3:SetText(textLine3)
            self.LabelLine3:SetColor(unpack(ColorLine3))
        end

        if not self.isShowing then
            self.isShowing = true
            self:PlayAnimation(0.0, 1.25, 1.0)
        end
    else
        if self.isShowing or (not self.Parent:IsHidden() and not self.isHiding) then
            self.isShowing = false
            self.isHiding = true
            self:PlayAnimation(1.0, 0.0, 0.0)
        end

        if self.customEndTime == 0
        and self.slayerEndTime == 0
        and self.arkasisEndTime == 0
        and self.breakEndTime == 0
        and self.finishedEndTime < currentTime
        and self.pullEndTime == 0
        and self.pullFinishedEndTime < currentTime
        and self.wipeEndTime == 0 then
            EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. "Notification_UpdateLoop")
        end
    end
end

----------------------------------------------------------------------------------------------------
-- ANIMATION
----------------------------------------------------------------------------------------------------
function Module:PlayAnimation(startScale, peakScale, endScale)
    if not self.Parent then return end

    if not self.TimelineScale then
        self.TimelineScale = ANIMATION_MANAGER:CreateTimeline()

        self.AnimScaleUp = self.TimelineScale:InsertAnimation(ANIMATION_SCALE, self.Parent, 0)
        self.AnimScaleUp:SetEasingFunction(ZO_LinearEase)

        self.AnimScaleDown = self.TimelineScale:InsertAnimation(ANIMATION_SCALE, self.Parent, 0)
        self.AnimScaleDown:SetEasingFunction(ZO_LinearEase)
    end

    if self.TimelineScale:IsPlaying() then self.TimelineScale:Stop() end

    -- 100% -> 0%
    if peakScale == 0 and endScale == 0 then
        self.AnimScaleUp:SetScaleValues(startScale, 0)
        self.AnimScaleUp:SetDuration(200)
        self.AnimScaleDown:SetDuration(0)

        self.TimelineScale:SetHandler('OnStop', function()
            self.Parent:SetHidden(true)
            self:ResetTransparency()
            self.isHiding = false
            self.isShowing = false
        end)
        self.TimelineScale:PlayFromStart()
        return
    end

    -- 0 -> 2.0 -> 1.0 OR 1.0 -> 1.5 -> 1.0
    self.TimelineScale:SetHandler('OnStop', nil)
    self.Parent:SetHidden(false)
    self.isHiding = false

    self.AnimScaleUp:SetScaleValues(startScale, peakScale)
    self.AnimScaleUp:SetDuration(150)

    self.AnimScaleDown:SetScaleValues(peakScale, endScale)
    self.AnimScaleDown:SetDuration(150)
    self.TimelineScale:SetAnimationOffset(self.AnimScaleDown, 150)

    self.TimelineScale:PlayFromStart()
end

----------------------------------------------------------------------------------------------------
-- TRIGGER WIPE PLEASE
----------------------------------------------------------------------------------------------------
function Module:TriggerWipe(timeSec)
    if not timeSec or timeSec <= 0 then
        self.wipeEndTime = 0
        self.lastTickSec = 0
        self:UpdateTick()
        return
    end

    if not self.Parent then self:Create() end
    self:ResetTransparency()

    self.wipeEndTime = GetGameTimeSeconds() + timeSec
    self.lastTickSec = math.ceil(timeSec) + 1

    if self.SV.enableSound then
        CC.PlaySound(SOUNDS.DUEL_START, 1)
    end

    EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. "Notification_UpdateLoop")
    EVENT_MANAGER:RegisterForUpdate(CC.NAME .. "Notification_UpdateLoop", 100, function() self:UpdateTick() end)

    self:UpdateTick()
end

----------------------------------------------------------------------------------------------------
-- TRIGGER PORT IN PLEASE
----------------------------------------------------------------------------------------------------
function Module:TriggerPortIn(timeSec, zoneName)
    if not timeSec or timeSec <= 0 then
        self.portInEndTime = 0
        self.portInZoneName = ""
        self.lastTickSec = 0
        self:UpdateTick()
        return
    end

    if not self.Parent then self:Create() end
    self:ResetTransparency()

    self.portInEndTime = GetGameTimeSeconds() + timeSec
    self.portInZoneName = zoneName or "Unknown Zone"
    self.lastTickSec = math.ceil(timeSec) + 1

    if self.SV.enableSound then
        CC.PlaySound(SOUNDS.ABILITY_ULTIMATE_READY, 2)
    end

    EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. "Notification_UpdateLoop")
    EVENT_MANAGER:RegisterForUpdate(CC.NAME .. "Notification_UpdateLoop", 100, function() self:UpdateTick() end)

    self:UpdateTick()
end

----------------------------------------------------------------------------------------------------
-- TRIGGER SLAYER
----------------------------------------------------------------------------------------------------
function Module:TriggerSlayer(timeSec, sideId, targetName)
    if not timeSec or timeSec <= 0 then
        self.slayerEndTime = 0
        self.slayerTotalTimeSec = 0
        self.slayerSideId = 0
        self.slayerTargetName = ""
        self.lastTickSec = 0
        self:UpdateTick()
        return
    end

    if not self.Parent then self:Create() end
    self:ResetTransparency()

    self.slayerEndTime = GetGameTimeSeconds() + timeSec
    self.slayerTotalTimeSec = timeSec
    self.slayerSideId = sideId or 0
    self.slayerTargetName = targetName or ""
    self.lastTickSec = math.ceil(timeSec) + 1

    EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. "Notification_UpdateLoop")
    EVENT_MANAGER:RegisterForUpdate(CC.NAME .. "Notification_UpdateLoop", 100, function() self:UpdateTick() end)

    if self.SV.enableSound then
        CC.PlaySound(SOUNDS.ABILITY_ULTIMATE_READY, 2)
    end

    self:UpdateTick()
end

----------------------------------------------------------------------------------------------------
-- TRIGGER ARKASIS
----------------------------------------------------------------------------------------------------
function Module:TriggerArkasis(timeSec, sideId)
    if not timeSec or timeSec <= 0 then
        self.arkasisEndTime = 0
        self.arkasisTotalTimeSec = 0
        self.arkasisSideId = 0
        self.lastTickSec = 0
        self:UpdateTick()
        return
    end

    if not self.Parent then self:Create() end
    self:ResetTransparency()

    self.arkasisEndTime = GetGameTimeSeconds() + timeSec
    self.arkasisTotalTimeSec = timeSec
    self.arkasisSideId = sideId or 0
    self.lastTickSec = math.ceil(timeSec) + 1

    EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. "Notification_UpdateLoop")
    EVENT_MANAGER:RegisterForUpdate(CC.NAME .. "Notification_UpdateLoop", 100, function() self:UpdateTick() end)

    if self.SV.enableSound then
        CC.PlaySound(SOUNDS.ABILITY_ULTIMATE_READY, 2)
    end

    self:UpdateTick()
end

----------------------------------------------------------------------------------------------------
-- TRIGGER PULL TIMER
----------------------------------------------------------------------------------------------------
function Module:TriggerPull(timeSec)
    if not timeSec or timeSec <= 0 then
        self.pullEndTime = 0
        self.pullFinishedEndTime = 0
        self.pullTotalTimeSec = 0
        self.lastTickSec = 0
        self:UpdateTick()
        return
    end

    if not self.Parent then self:Create() end
    self:ResetTransparency()

    self.pullEndTime = GetGameTimeSeconds() + timeSec
    self.pullFinishedEndTime = 0
    self.pullTotalTimeSec = timeSec
    self.lastTickSec = math.ceil(timeSec) + 1

    EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. "Notification_UpdateLoop")
    EVENT_MANAGER:RegisterForUpdate(CC.NAME .. "Notification_UpdateLoop", 100, function() self:UpdateTick() end)

    self:UpdateTick()
end

----------------------------------------------------------------------------------------------------
-- TRIGGER BREAK TIMER
----------------------------------------------------------------------------------------------------
function Module:TriggerBreak(timeSec, sourceName, isRestore)
    local unitName = ""
    if sourceName then
        local playerLink = CC.GetPlayerLinkFromDisplayName(sourceName) or sourceName
        unitName = string.format(" %s", playerLink)
    end

    if not timeSec or timeSec <= 0 then
        if self.breakEndTime > 0 then
            self.breakEndTime = 1 -- NOT 0 TO PLAY THE FINISH SOUND
        else
            self.breakEndTime = 0
            self.breakTotalTimeSec = 0
            self.finishedEndTime = 0
            self.SV.activeBreakEndTimeStamp = 0
            self.SV.activeBreakTotalTimeSec = 0
        end

        self:UpdateTick()
        return
    end

    if not self.Parent then self:Create() end
    self:ResetTransparency()

    local currentTime = GetGameTimeSeconds()
    self.breakStartTime = currentTime
    self.breakEndTime = currentTime + timeSec
    self.finishedEndTime = 0

    if not isRestore then
        self.breakTotalTimeSec = timeSec
        self.SV.activeBreakEndTimeStamp = GetTimeStamp() + timeSec
        self.SV.activeBreakTotalTimeSec = timeSec

        -- LOCAL TIME FOR CHAT
        local currentMidnight = GetSecondsSinceMidnight()
        local nextMidnight = (currentMidnight + timeSec) % 86400
        local clockHours = math.floor(nextMidnight / 3600)
        local clockMinutes = math.floor((nextMidnight % 3600) / 60)
        local durationBreak = math.floor(timeSec / 60)

        -- PRINT CHAT
        d(string.format("%s BREAK!%s (%d Min) - Resuming at %02d:%02d", CC.CHAT, unitName, durationBreak, clockHours, clockMinutes))
    else
        -- RESTORE TOTAL TIME
        self.breakTotalTimeSec = self.SV.activeBreakTotalTimeSec or timeSec
    end

    EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. "Notification_UpdateLoop")
    EVENT_MANAGER:RegisterForUpdate(CC.NAME .. "Notification_UpdateLoop", 100, function() self:UpdateTick() end)

    self:UpdateTick()
end

----------------------------------------------------------------------------------------------------
-- HIDE
----------------------------------------------------------------------------------------------------
function Module:Hide()
    self:ResetTransparency()
    self.isShowing = false

    self.customEndTime = 0
    self.customTotalTimeSec = 0
    self.customLine1 = ""
    self.customLine2 = ""

    self.wipeEndTime = 0
    self.portInEndTime = 0
    self.portInZoneName = ""

    self.slayerEndTime = 0
    self.slayerTotalTimeSec = 0
    self.slayerSideName = ""
    self.slayerTargetName = ""

    self.arkasisEndTime = 0
    self.arkasisTotalTimeSec = 0
    self.arkasisSideId = 0

    self.pullEndTime = 0
    self.pullFinishedEndTime = 0
    self.pullTotalTimeSec = 0

    self.breakEndTime = 0
    self.breakTotalTimeSec = 0
    self.finishedEndTime = 0

    self.lastTickSec = 0

    if self.Parent then
        if self.TimelineScale and self.TimelineScale:IsPlaying() then self.TimelineScale:Stop() end
        self.Parent:SetScale(1.0)
        self.isHiding = false

        self.Parent:SetHidden(true)
    end

    EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. "Notification_UpdateLoop")
end

----------------------------------------------------------------------------------------------------
-- CUSTOM ENABLE
----------------------------------------------------------------------------------------------------
function Module:CustomEnable()
    if not self.Parent then self:Create() end
    self:Hide()

    -- RESTORE BREAK TIMER AFTER RELOADUI
    if self.SV.activeBreakEndTimeStamp and self.SV.activeBreakEndTimeStamp > GetTimeStamp() then
        local remaining = self.SV.activeBreakEndTimeStamp - GetTimeStamp()
        self:TriggerBreak(remaining, nil, true)
    else
        self.SV.activeBreakEndTimeStamp = 0
        self.SV.activeBreakTotalTimeSec = 0
    end
end

----------------------------------------------------------------------------------------------------
-- CUSTOM DISABLE
----------------------------------------------------------------------------------------------------
function Module:CustomDisable()
    self:Hide()
end

----------------------------------------------------------------------------------------------------
-- REGISTER MODULE
----------------------------------------------------------------------------------------------------
CC[Module.name] = Module
table.insert(CC.Modules, Module)