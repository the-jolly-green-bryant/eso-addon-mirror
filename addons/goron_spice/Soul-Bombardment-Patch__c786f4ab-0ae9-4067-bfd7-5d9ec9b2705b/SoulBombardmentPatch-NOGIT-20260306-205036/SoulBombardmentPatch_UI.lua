function SoulBombardmentPatch.ConfigureBarZones()
    local dangerWidth = math.floor(SoulBombardmentPatch.barMaxWidth * (1 - SoulBombardmentPatch.dangerStartProgress) + 0.5)
    local safeWidth = SoulBombardmentPatch.barMaxWidth - dangerWidth
    SoulBombardmentPatchIndicatorBarSafe:SetWidth(safeWidth)
    SoulBombardmentPatchIndicatorBarDanger:SetWidth(dangerWidth)
end

function SoulBombardmentPatch.SetBarProgress(progress)
    local clamped = zo_clamp(progress, 0, 1)
    local width = math.floor(SoulBombardmentPatch.barMaxWidth * clamped + 0.5)
    SoulBombardmentPatchIndicatorBarFill:SetWidth(width)

    local lineX = zo_clamp(width - 1, 0, SoulBombardmentPatch.barMaxWidth - 1)
    SoulBombardmentPatchIndicatorProgressLine:ClearAnchors()
    SoulBombardmentPatchIndicatorProgressLine:SetAnchor(LEFT, SoulBombardmentPatchIndicatorBarBackground, LEFT, lineX, -2)
end

function SoulBombardmentPatch.SetCastBarControlsVisible(isVisible)
    local hidden = not isVisible
    SoulBombardmentPatchIndicatorBarBackground:SetHidden(hidden)
    SoulBombardmentPatchIndicatorBarSafe:SetHidden(hidden)
    SoulBombardmentPatchIndicatorBarDanger:SetHidden(hidden)
    SoulBombardmentPatchIndicatorBarFill:SetHidden(hidden)
    SoulBombardmentPatchIndicatorProgressLine:SetHidden(hidden)
end

function SoulBombardmentPatch.HideCastWindow()
    SoulBombardmentPatch.activeCast = nil
    SoulBombardmentPatch.activeIncomingWarning = false
    SoulBombardmentPatch.SetCastBarControlsVisible(true)
    if not SoulBombardmentPatch.positionPreviewVisible then
        SoulBombardmentPatchIndicator:SetHidden(true)
    end
    EVENT_MANAGER:UnregisterForUpdate(SoulBombardmentPatch.name .. "CastBarUpdate")
end

function SoulBombardmentPatch.OnCastBarUpdate()
    local castData = SoulBombardmentPatch.activeCast
    if castData == nil then
        SoulBombardmentPatch.HideCastWindow()
        return
    end

    if castData.durationMs == nil or castData.durationMs <= 0 then
        SoulBombardmentPatch.HideCastWindow()
        return
    end

    local elapsedMs = GetFrameTimeMilliseconds() - castData.startTimeMs
    local progress = elapsedMs / castData.durationMs
    local displayProgress = math.min(progress, 0.99)
    SoulBombardmentPatch.SetBarProgress(displayProgress)
    SoulBombardmentPatchIndicatorLabel:SetText(string.format(
        "Soul Essence Bombardment (%d ms)",
        math.max(castData.durationMs - elapsedMs, 0)
    ))

    if elapsedMs >= (castData.durationMs + 600) then
        SoulBombardmentPatch.HideCastWindow()
    end
end

function SoulBombardmentPatch.StartCastWindow()
    SoulBombardmentPatch.positionPreviewVisible = false
    SoulBombardmentPatch.positionPreviewToken = SoulBombardmentPatch.positionPreviewToken + 1
    SoulBombardmentPatch.activeIncomingWarning = false
    SoulBombardmentPatch.activeCast = {
        startTimeMs = GetFrameTimeMilliseconds(),
        durationMs = SoulBombardmentPatch.castDurationMs,
    }

    SoulBombardmentPatch.SetCastBarControlsVisible(true)
    SoulBombardmentPatchIndicator:SetHidden(false)
    SoulBombardmentPatchIndicatorLabel:SetText("Soul Essence Bombardment")
    SoulBombardmentPatch.SetBarProgress(0)
    SoulBombardmentPatch.PlayStartSound()
    EVENT_MANAGER:RegisterForUpdate(SoulBombardmentPatch.name .. "CastBarUpdate", 16, SoulBombardmentPatch.OnCastBarUpdate)
end

function SoulBombardmentPatch.ResolveCastWindow()
    if SoulBombardmentPatch.activeCast == nil then
        return
    end

    SoulBombardmentPatch.SetBarProgress(1)
    SoulBombardmentPatch.HideCastWindow()
end

function SoulBombardmentPatch.StartIncomingWarningWindow()
    SoulBombardmentPatch.positionPreviewVisible = false
    SoulBombardmentPatch.positionPreviewToken = SoulBombardmentPatch.positionPreviewToken + 1
    SoulBombardmentPatch.activeCast = nil
    SoulBombardmentPatch.activeIncomingWarning = true

    EVENT_MANAGER:UnregisterForUpdate(SoulBombardmentPatch.name .. "CastBarUpdate")
    SoulBombardmentPatch.SetCastBarControlsVisible(false)
    SoulBombardmentPatchIndicator:SetHidden(false)
    SoulBombardmentPatchIndicatorLabel:SetText(SoulBombardmentPatch.soulBombardmentIncomingWarningText or "Soul Bombardment incoming...")
end

function SoulBombardmentPatch.ResolveIncomingWarningWindow()
    if not SoulBombardmentPatch.activeIncomingWarning then
        return
    end

    SoulBombardmentPatch.activeIncomingWarning = false
    SoulBombardmentPatch.SetCastBarControlsVisible(true)
    if SoulBombardmentPatch.activeCast == nil and not SoulBombardmentPatch.positionPreviewVisible then
        SoulBombardmentPatchIndicator:SetHidden(true)
    end
end

function SoulBombardmentPatch.PrepareIndicatorForConsole()
    SoulBombardmentPatch.ApplyIndicatorPosition()
    SoulBombardmentPatch.SetCastBarControlsVisible(true)
    SoulBombardmentPatchIndicator:SetDrawLayer(DL_OVERLAY)
    SoulBombardmentPatchIndicator:SetDrawTier(DT_HIGH)
    SoulBombardmentPatchIndicator:SetDrawLevel(50)
    SoulBombardmentPatchIndicator:SetMouseEnabled(false)
    SoulBombardmentPatchIndicator:SetAlpha(1)
    SoulBombardmentPatchIndicator:SetHidden(true)
end

function SoulBombardmentPatch.ApplyIndicatorPosition()
    SoulBombardmentPatchIndicator:ClearAnchors()
    SoulBombardmentPatchIndicator:SetAnchor(
        BOTTOM,
        GuiRoot,
        CENTER,
        SoulBombardmentPatch.indicatorOffsetX,
        SoulBombardmentPatch.indicatorOffsetY
    )
end

function SoulBombardmentPatch.HidePositionPreview()
    SoulBombardmentPatch.positionPreviewVisible = false
    if SoulBombardmentPatch.activeCast == nil and not SoulBombardmentPatch.activeIncomingWarning then
        SoulBombardmentPatchIndicator:SetHidden(true)
    end
end

function SoulBombardmentPatch.ShowPositionPreview()
    if SoulBombardmentPatch.activeCast ~= nil then
        return
    end

    SoulBombardmentPatch.activeIncomingWarning = false
    SoulBombardmentPatch.SetCastBarControlsVisible(true)
    SoulBombardmentPatch.positionPreviewVisible = true
    SoulBombardmentPatchIndicator:SetHidden(false)
    SoulBombardmentPatchIndicatorLabel:SetText("Soul Bombardment")
    SoulBombardmentPatch.SetBarProgress(0.5)
end

function SoulBombardmentPatch.ScheduleHidePositionPreview(delayMs)
    if SoulBombardmentPatch.joystickRepositionInputActive then
        return
    end
    SoulBombardmentPatch.positionPreviewToken = SoulBombardmentPatch.positionPreviewToken + 1
    local token = SoulBombardmentPatch.positionPreviewToken
    zo_callLater(function()
        if token ~= SoulBombardmentPatch.positionPreviewToken then
            return
        end
        SoulBombardmentPatch.HidePositionPreview()
    end, delayMs or 1200)
end

function SoulBombardmentPatch.SetIndicatorOffsets(xValue, yValue)
    local normalizedX = zo_round(tonumber(xValue) or 0)
    local normalizedY = zo_round(tonumber(yValue) or 0)
    SoulBombardmentPatch.indicatorOffsetX = normalizedX
    SoulBombardmentPatch.indicatorOffsetY = normalizedY
    if SoulBombardmentPatch.savedVariables ~= nil then
        SoulBombardmentPatch.savedVariables.indicatorOffsetX = normalizedX
        SoulBombardmentPatch.savedVariables.indicatorOffsetY = normalizedY
    end

    SoulBombardmentPatch.ApplyIndicatorPosition()
    SoulBombardmentPatch.ShowPositionPreview()
    if not SoulBombardmentPatch.joystickRepositionInputActive then
        SoulBombardmentPatch.ScheduleHidePositionPreview()
    end
end

function SoulBombardmentPatch.SetIndicatorOffsetX(value)
    SoulBombardmentPatch.SetIndicatorOffsets(value, SoulBombardmentPatch.indicatorOffsetY)
end

function SoulBombardmentPatch.SetIndicatorOffsetY(value)
    SoulBombardmentPatch.SetIndicatorOffsets(SoulBombardmentPatch.indicatorOffsetX, value)
end

function SoulBombardmentPatch.IsSettingsSceneActive()
    if SCENE_MANAGER == nil or SCENE_MANAGER.GetScene == nil then
        return false
    end
    local scene = SCENE_MANAGER:GetScene("LibHarvensAddonSettingsScene")
    if scene == nil or scene.GetState == nil then
        return false
    end
    local state = scene:GetState()
    return state == SCENE_SHOWING or state == SCENE_SHOWN
end

function SoulBombardmentPatch.CanUseJoystickRepositioning()
    return type(IsInGamepadPreferredMode) == "function" and IsInGamepadPreferredMode()
end

function SoulBombardmentPatch.IsJoystickRepositioningActive()
    return SoulBombardmentPatch.joystickRepositioningEnabled == true and SoulBombardmentPatch.IsSettingsSceneActive() and SoulBombardmentPatch.CanUseJoystickRepositioning()
end

function SoulBombardmentPatch.NudgeIndicatorWithJoystick(xDirection, yDirection)
    if not SoulBombardmentPatch.IsJoystickRepositioningActive() then
        return
    end

    local step = tonumber(SoulBombardmentPatch.joystickNudgeStep) or 8
    local currentX = tonumber(SoulBombardmentPatch.indicatorOffsetX) or 0
    local currentY = tonumber(SoulBombardmentPatch.indicatorOffsetY) or 0
    SoulBombardmentPatch.SetIndicatorOffsets(currentX + (xDirection * step), currentY + (yDirection * step))
end

function SoulBombardmentPatch.CanReadRightStickDirectionalInput()
    local hasDirectionalInput = DIRECTIONAL_INPUT ~= nil and ZO_DI_RIGHT_STICK ~= nil
    local hasAxisReader = type(GetGamepadAxisValue) == "function" and (
        GAMEPAD_AXIS_RIGHT_STICK_X ~= nil or GAMEPAD_AXIS_RIGHT_X ~= nil or GAMEPAD_AXIS_RS_X ~= nil
    ) and (
        GAMEPAD_AXIS_RIGHT_STICK_Y ~= nil or GAMEPAD_AXIS_RIGHT_Y ~= nil or GAMEPAD_AXIS_RS_Y ~= nil
    )
    return hasDirectionalInput or hasAxisReader
end

function SoulBombardmentPatch.GetJoystickRepositionUpdateEventName()
    return SoulBombardmentPatch.name .. "JoystickRepositionUpdate"
end

function SoulBombardmentPatch.ResetJoystickRepositionNudgeState()
    SoulBombardmentPatch.joystickRepositionLastXDirection = 0
    SoulBombardmentPatch.joystickRepositionLastYDirection = 0
    SoulBombardmentPatch.joystickRepositionNextNudgeAtMs = 0
    SoulBombardmentPatch.joystickRepositionLastMoveTimeMs = nil
    SoulBombardmentPatch.joystickRepositionFloatX = nil
    SoulBombardmentPatch.joystickRepositionFloatY = nil
end

function SoulBombardmentPatch.ApplyJoystickRepositionDirections(normalizedX, normalizedY)
    if normalizedX == 0 and normalizedY == 0 then
        SoulBombardmentPatch.joystickRepositionLastMoveTimeMs = nil
        SoulBombardmentPatch.joystickRepositionFloatX = tonumber(SoulBombardmentPatch.indicatorOffsetX) or 0
        SoulBombardmentPatch.joystickRepositionFloatY = tonumber(SoulBombardmentPatch.indicatorOffsetY) or 0
        return
    end

    local nowMs = GetFrameTimeMilliseconds()
    local lastMoveTimeMs = tonumber(SoulBombardmentPatch.joystickRepositionLastMoveTimeMs)
    local deltaMs = 16
    if lastMoveTimeMs ~= nil and nowMs > lastMoveTimeMs then
        deltaMs = zo_clamp(nowMs - lastMoveTimeMs, 1, 80)
    end
    SoulBombardmentPatch.joystickRepositionLastMoveTimeMs = nowMs

    local currentX = tonumber(SoulBombardmentPatch.joystickRepositionFloatX)
    local currentY = tonumber(SoulBombardmentPatch.joystickRepositionFloatY)
    if currentX == nil then
        currentX = tonumber(SoulBombardmentPatch.indicatorOffsetX) or 0
    end
    if currentY == nil then
        currentY = tonumber(SoulBombardmentPatch.indicatorOffsetY) or 0
    end

    local speedPixelsPerSecond = tonumber(SoulBombardmentPatch.joystickNudgePixelsPerSecond) or 420
    local seconds = deltaMs / 1000
    local deltaX = normalizedX * speedPixelsPerSecond * seconds
    local deltaY = normalizedY * speedPixelsPerSecond * seconds
    if math.abs(deltaX) < 0.01 and math.abs(deltaY) < 0.01 then
        return
    end

    currentX = currentX + deltaX
    currentY = currentY + deltaY
    SoulBombardmentPatch.joystickRepositionFloatX = currentX
    SoulBombardmentPatch.joystickRepositionFloatY = currentY
    SoulBombardmentPatch.SetIndicatorOffsets(currentX, currentY)
end

function SoulBombardmentPatch.TryReadDirectionalPair(xMethodName, yMethodName, includeStickId)
    if DIRECTIONAL_INPUT == nil then
        return nil
    end
    local xMethod = DIRECTIONAL_INPUT[xMethodName]
    local yMethod = DIRECTIONAL_INPUT[yMethodName]
    if type(xMethod) ~= "function" or type(yMethod) ~= "function" then
        return nil
    end

    local okX, xValue
    local okY, yValue
    if includeStickId then
        okX, xValue = pcall(xMethod, DIRECTIONAL_INPUT, ZO_DI_RIGHT_STICK)
        okY, yValue = pcall(yMethod, DIRECTIONAL_INPUT, ZO_DI_RIGHT_STICK)
    else
        okX, xValue = pcall(xMethod, DIRECTIONAL_INPUT)
        okY, yValue = pcall(yMethod, DIRECTIONAL_INPUT)
    end
    if not okX or not okY then
        return nil
    end

    local numericX = tonumber(xValue)
    local numericY = tonumber(yValue)
    if numericX == nil or numericY == nil then
        return nil
    end
    return {
        x = numericX,
        y = numericY,
        mode = string.format("%s/%s%s", xMethodName, yMethodName, includeStickId and "(stick)" or "(no-arg)"),
    }
end

function SoulBombardmentPatch.TryReadRightStickAxes()
    if not SoulBombardmentPatch.CanReadRightStickDirectionalInput() then
        return nil
    end

    if DIRECTIONAL_INPUT ~= nil and ZO_DI_RIGHT_STICK ~= nil and type(DIRECTIONAL_INPUT.UpdateDirectionalInput) == "function" then
        pcall(DIRECTIONAL_INPUT.UpdateDirectionalInput, DIRECTIONAL_INPUT, ZO_DI_RIGHT_STICK, true)
    end

    if DIRECTIONAL_INPUT ~= nil and ZO_DI_RIGHT_STICK ~= nil then
        local attempts = {
            { "GetX", "GetY", true },
            { "GetX", "GetY", false },
            { "GetXValue", "GetYValue", true },
            { "GetXValue", "GetYValue", false },
            { "GetHorizontalMovement", "GetVerticalMovement", true },
            { "GetHorizontalMovement", "GetVerticalMovement", false },
        }
        for _, attempt in ipairs(attempts) do
            local sample = SoulBombardmentPatch.TryReadDirectionalPair(attempt[1], attempt[2], attempt[3])
            if sample ~= nil then
                return sample
            end
        end
    end

    if type(GetGamepadAxisValue) == "function" then
        local rightXId = GAMEPAD_AXIS_RIGHT_STICK_X or GAMEPAD_AXIS_RIGHT_X or GAMEPAD_AXIS_RS_X
        local rightYId = GAMEPAD_AXIS_RIGHT_STICK_Y or GAMEPAD_AXIS_RIGHT_Y or GAMEPAD_AXIS_RS_Y
        if rightXId ~= nil and rightYId ~= nil then
            local okX, rawX = pcall(GetGamepadAxisValue, rightXId)
            local okY, rawY = pcall(GetGamepadAxisValue, rightYId)
            local numericX = okX and tonumber(rawX) or nil
            local numericY = okY and tonumber(rawY) or nil
            if numericX ~= nil and numericY ~= nil then
                return {
                    x = numericX,
                    y = numericY,
                    mode = "GetGamepadAxisValue",
                }
            end
        end
    end

    return nil
end

function SoulBombardmentPatch.NormalizeJoystickAxisValue(rawValue, deadzone)
    local numeric = tonumber(rawValue) or 0
    local absoluteValue = math.abs(numeric)
    if absoluteValue > 1 then
        if absoluteValue >= 10000 then
            numeric = numeric / 32767
        elseif absoluteValue >= 200 then
            numeric = numeric / 255
        else
            numeric = numeric / 100
        end
    end

    numeric = zo_clamp(numeric, -1, 1)
    local threshold = tonumber(deadzone) or 0.45
    local magnitude = math.abs(numeric)
    if magnitude <= threshold then
        return 0
    end

    local normalizedMagnitude = (magnitude - threshold) / (1 - threshold)
    return numeric > 0 and normalizedMagnitude or -normalizedMagnitude
end

function SoulBombardmentPatch.OnJoystickRepositionUpdate()
    if not SoulBombardmentPatch.IsJoystickRepositioningActive() then
        return
    end
    if not SoulBombardmentPatch.CanReadRightStickDirectionalInput() then
        return
    end

    local sample = SoulBombardmentPatch.TryReadRightStickAxes()
    if sample == nil then
        if not SoulBombardmentPatch.joystickRightAnalogUnavailableLoggedThisSession then
            SoulBombardmentPatch.joystickRightAnalogUnavailableLoggedThisSession = true
            d("Soul Bombardment Patch: right analog axis reader unavailable (no matching API reader).")
        end
        return
    end
    SoulBombardmentPatch.joystickRightAnalogUnavailableLoggedThisSession = false

    local rawX = sample.x or 0
    local rawY = sample.y or 0
    local deadzone = tonumber(SoulBombardmentPatch.joystickNudgeDeadzone) or 0.45

    local normalizedX = SoulBombardmentPatch.NormalizeJoystickAxisValue(rawX, deadzone)
    local normalizedY = SoulBombardmentPatch.NormalizeJoystickAxisValue(rawY, deadzone)

    if SoulBombardmentPatch.joystickRightAnalogReaderMode ~= sample.mode then
        SoulBombardmentPatch.joystickRightAnalogReaderMode = sample.mode
        d(string.format("Soul Bombardment Patch: right analog reader=%s.", tostring(sample.mode)))
    end

    if not SoulBombardmentPatch.joystickRightAnalogLoggedThisSession and (normalizedX ~= 0 or normalizedY ~= 0) then
        SoulBombardmentPatch.joystickRightAnalogLoggedThisSession = true
        d(string.format(
            "Soul Bombardment Patch: right analog input detected (reader=%s, rawX=%.2f, rawY=%.2f, normX=%.2f, normY=%.2f).",
            tostring(sample.mode),
            rawX,
            rawY,
            normalizedX,
            normalizedY
        ))
    end

    SoulBombardmentPatch.ApplyJoystickRepositionDirections(normalizedX, normalizedY)
end

function SoulBombardmentPatch.RegisterJoystickRepositionKeybinds()
    if SoulBombardmentPatch.joystickRepositionInputActive then
        return
    end
    if not SoulBombardmentPatch.IsJoystickRepositioningActive() then
        return
    end
    if EVENT_MANAGER == nil or type(EVENT_MANAGER.RegisterForUpdate) ~= "function" then
        return
    end
    if not SoulBombardmentPatch.CanReadRightStickDirectionalInput() then
        return
    end

    SoulBombardmentPatch.ResetJoystickRepositionNudgeState()
    SoulBombardmentPatch.joystickRightAnalogLoggedThisSession = false
    SoulBombardmentPatch.joystickRightAnalogUnavailableLoggedThisSession = false
    SoulBombardmentPatch.joystickRightAnalogReaderMode = nil
    EVENT_MANAGER:RegisterForUpdate(
        SoulBombardmentPatch.GetJoystickRepositionUpdateEventName(),
        16,
        SoulBombardmentPatch.OnJoystickRepositionUpdate
    )
    SoulBombardmentPatch.joystickRepositionInputActive = true
    SoulBombardmentPatch.ShowPositionPreview()
    d("Soul Bombardment Patch: joystick repositioning ON. Use the right analog stick to move the timer, then toggle this setting OFF to finish.")
end

function SoulBombardmentPatch.UnregisterJoystickRepositionKeybinds()
    if not SoulBombardmentPatch.joystickRepositionInputActive then
        SoulBombardmentPatch.ResetJoystickRepositionNudgeState()
        return
    end

    if EVENT_MANAGER ~= nil and type(EVENT_MANAGER.UnregisterForUpdate) == "function" then
        EVENT_MANAGER:UnregisterForUpdate(SoulBombardmentPatch.GetJoystickRepositionUpdateEventName())
    end
    SoulBombardmentPatch.joystickRepositionInputActive = false
    SoulBombardmentPatch.joystickRightAnalogLoggedThisSession = false
    SoulBombardmentPatch.joystickRightAnalogUnavailableLoggedThisSession = false
    SoulBombardmentPatch.joystickRightAnalogReaderMode = nil
    SoulBombardmentPatch.ResetJoystickRepositionNudgeState()
    SoulBombardmentPatch.ScheduleHidePositionPreview(500)
end

function SoulBombardmentPatch.RefreshJoystickRepositionMode()
    if SoulBombardmentPatch.IsJoystickRepositioningActive() then
        SoulBombardmentPatch.RegisterJoystickRepositionKeybinds()
    else
        SoulBombardmentPatch.UnregisterJoystickRepositionKeybinds()
    end
end

function SoulBombardmentPatch.SetJoystickRepositioningEnabled(enabled)
    local normalized = enabled == true
    SoulBombardmentPatch.joystickRepositioningEnabled = normalized
    if SoulBombardmentPatch.savedVariables ~= nil then
        SoulBombardmentPatch.savedVariables.enableJoystickRepositioning = normalized
    end

    SoulBombardmentPatch.RefreshJoystickRepositionMode()
    d(string.format(
        "Soul Bombardment Patch: joystick repositioning %s.",
        normalized and "enabled" or "disabled (position saved)"
    ))
end

function SoulBombardmentPatch.OnSettingsSceneStateChanged(oldState, newState)
    if newState == SCENE_SHOWING or newState == SCENE_SHOWN then
        SoulBombardmentPatch.RefreshJoystickRepositionMode()
    elseif newState == SCENE_HIDING or newState == SCENE_HIDDEN then
        SoulBombardmentPatch.UnregisterJoystickRepositionKeybinds()
    end
end

function SoulBombardmentPatch.EnsureJoystickRepositionSceneHook()
    if SoulBombardmentPatch.joystickRepositionSceneHooked then
        return
    end
    if SCENE_MANAGER == nil or SCENE_MANAGER.GetScene == nil then
        return
    end

    local scene = SCENE_MANAGER:GetScene("LibHarvensAddonSettingsScene")
    if scene == nil or scene.RegisterCallback == nil then
        return
    end

    scene:RegisterCallback("StateChange", SoulBombardmentPatch.OnSettingsSceneStateChanged)
    SoulBombardmentPatch.joystickRepositionSceneHooked = true
end

function SoulBombardmentPatch.PlayStartSound()
    if not SoulBombardmentPatch.playStartSound then
        return
    end
    if type(PlaySound) ~= "function" then
        return
    end

    local soundId = nil
    if type(SOUNDS) == "table" then
        soundId = SOUNDS[SoulBombardmentPatch.startSoundId]
    end
    if soundId ~= nil then
        PlaySound(soundId)
    end
end

function SoulBombardmentPatch.SetPlayStartSound(enabled)
    SoulBombardmentPatch.playStartSound = enabled == true
    if SoulBombardmentPatch.savedVariables ~= nil then
        SoulBombardmentPatch.savedVariables.playStartSound = SoulBombardmentPatch.playStartSound
    end
end
