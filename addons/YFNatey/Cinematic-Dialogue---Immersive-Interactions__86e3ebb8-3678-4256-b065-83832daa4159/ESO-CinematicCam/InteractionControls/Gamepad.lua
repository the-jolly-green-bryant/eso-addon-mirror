--- Track gamepad sticks and trigger inputs during interactions for emote and camera controls.
function CinematicCam:StartGamepadConsumedUIPoll()
    -- Only keep unconsumed if we're actively in a modified interaction
    if self.isInteractionModified and self.gamepadStickPoll and self.gamepadStickPoll.isActive then
        SetGamepadLeftStickConsumedByUI(false)
    else
        -- Reset to consumed if interaction ended
        SetGamepadLeftStickConsumedByUI(true)
        EVENT_MANAGER:UnregisterForUpdate("CinematicCam_GamepadConsumedUIPoll")
    end
end

function CinematicCam:StartGamepadStickPoll()
    if not self.gamepadStickPoll or not self.gamepadStickPoll.isActive then
        self:StopGamepadStickPoll()
        return
    end

    local interactionType = GetInteractionType()
    if interactionType == INTERACTION_NONE then
        self:StopGamepadStickPoll()
        if self.isInteractionModified then
            self:OnInteractionEnd()
        end
        return
    end

    if not self.isInteractionModified then
        return
    end

    local leftTrigger = GetGamepadLeftTriggerMagnitude()
    local rightTrigger = GetGamepadRightTriggerMagnitude()
    local rightX = ZO_Gamepad_GetRightStickEasedX()
    local rightY = ZO_Gamepad_GetRightStickEasedY()
    local leftX = ZO_Gamepad_GetLeftStickEasedX()
    local leftY = ZO_Gamepad_GetLeftStickEasedY()

    local rightMagnitude = zo_sqrt(rightX * rightX + rightY * rightY)
    local leftMagnitude = zo_sqrt(leftX * leftX + leftY * leftY)
    local currentTime = GetGameTimeMilliseconds()

    local HOLD_THRESHOLD = 800 -- ms before the pad UI reveals itself

    if (rightMagnitude > 0 or leftMagnitude > 0) and rightTrigger == 0 then
        SetGameCameraUIMode(CinematicCam.CAMERA_MODE.FREE)
    end

    if leftTrigger > 0.3 and CinematicCam.savedVars.interaction.allowImmersionControls then
        SetGameCameraUIMode(CinematicCam.CAMERA_MODE.STATIC)

        -- Start/continue the hold timer
        if not self.gamepadStickPoll.leftTriggerHoldStart then
            self.gamepadStickPoll.leftTriggerHoldStart = currentTime
        end
        local leftHeldFor = currentTime - self.gamepadStickPoll.leftTriggerHoldStart

        -- Only reveal the pad once held long enough
        if leftHeldFor >= HOLD_THRESHOLD and not self.emotePadVisible then
            self:ShowEmotePad()
        end

        if self.cameraPadVisible then
            self:HideCameraPad()
            self:ResetCameraHighlights()
        end

        -- Emote detection runs regardless of hold time / visibility
        if rightMagnitude > self.gamepadStickPoll.deadzone then
            local timeSinceLastEmote = currentTime - self.gamepadStickPoll.lastEmoteTime

            if timeSinceLastEmote >= self.gamepadStickPoll.emoteCooldown then
                if math.abs(rightX) > math.abs(rightY) then
                    if rightX > 0 then
                        self:HighlightEmoteDirection("Right")
                        local emote = self:GetEmoteForSlot(2)
                        CinematicCam.savedVars.emoteWheel.lastUsedSlot = 2
                        if emote then
                            DoCommand(emote)
                            self.gamepadStickPoll.lastEmoteTime = currentTime
                        end
                    elseif rightX < 0 then
                        self:HighlightEmoteDirection("Left")
                        local emote = self:GetEmoteForSlot(4)
                        CinematicCam.savedVars.emoteWheel.lastUsedSlot = 4
                        if emote then
                            DoCommand(emote)
                            self.gamepadStickPoll.lastEmoteTime = currentTime
                        end
                    end
                else
                    if rightY > 0 then
                        self:HighlightEmoteDirection("Top")
                        local emote = self:GetEmoteForSlot(1)
                        CinematicCam.savedVars.emoteWheel.lastUsedSlot = 1
                        if emote then
                            DoCommand(emote)
                            self.gamepadStickPoll.lastEmoteTime = currentTime
                        end
                    elseif rightY < 0 then
                        self:HighlightEmoteDirection("Bottom")
                        local emote = self:GetEmoteForSlot(3)
                        CinematicCam.savedVars.emoteWheel.lastUsedSlot = 3
                        if emote then
                            DoCommand(emote)
                            self.gamepadStickPoll.lastEmoteTime = currentTime
                        end
                    end
                end
            end
        else
            self:ResetEmoteHighlights()
        end
    elseif rightTrigger > 0.3 and CinematicCam.savedVars.interaction.allowCameraMovementDuringDialogue then
        if not self.gamepadStickPoll.rightTriggerHoldStart then
            self.gamepadStickPoll.rightTriggerHoldStart = currentTime
        end
        local rightHeldFor = currentTime - self.gamepadStickPoll.rightTriggerHoldStart

        if rightHeldFor >= HOLD_THRESHOLD and not self.cameraPadVisible then
            self:ShowCameraPad()
        end

        if self.emotePadVisible then
            self:HideEmotePad()
            self:ResetEmoteHighlights()
        end

        if rightMagnitude > 0 then
            local timeSinceLastSwitch = currentTime - self.gamepadStickPoll.lastCameraSwitch

            if math.abs(rightX) > math.abs(rightY) then
                if timeSinceLastSwitch >= self.gamepadStickPoll.cameraSwitchCooldown then
                    if rightX > 0 then
                        self:HighlightCameraDirection("Right")
                        self.savedVars.useCinematicCamera = true
                        SetInteractionUsingInteractCamera(self.savedVars.useCinematicCamera)
                        self.gamepadStickPoll.lastCameraSwitch = currentTime
                    elseif rightX < 0 then
                        self:HighlightCameraDirection("Left")
                        self.savedVars.useCinematicCamera = false
                        SetInteractionUsingInteractCamera(self.savedVars.useCinematicCamera)
                        self.gamepadStickPoll.lastCameraSwitch = currentTime
                    end
                end
            else
                if rightY > 0 then
                    self:HighlightCameraDirection("Top")
                    CameraZoomIn()
                    SetGameCameraUIMode(CinematicCam.CAMERA_MODE.STATIC)
                elseif rightY < 0 then
                    self:HighlightCameraDirection("Bottom")
                    CameraZoomOut()
                    SetGameCameraUIMode(CinematicCam.CAMERA_MODE.STATIC)
                end
            end
        else
            self:ResetCameraHighlights()
        end
    else
        -- No trigger held: reset hold timers and hide both pads
        self.gamepadStickPoll.leftTriggerHoldStart = nil
        self.gamepadStickPoll.rightTriggerHoldStart = nil

        if self.emotePadVisible then
            self:HideEmotePad()
            self:ResetEmoteHighlights()
        end

        if self.cameraPadVisible then
            self:HideCameraPad()
            self:ResetCameraHighlights()
        end

        if rightMagnitude >= self.gamepadStickPoll.deadzone then
            if self.gamepadStickPoll.currentCameraMode == "free" then
                SetGameCameraUIMode(CinematicCam.CAMERA_MODE.FREE)
            end
        end
    end
end

function CinematicCam:StopGamepadStickPoll()
    if not self.gamepadStickPoll then return end
    self.gamepadStickPoll.isActive = false

    self:HideEmoteWheel()
    self:HideEmotePad()
    self:HideCameraWheel()
    self:HideCameraPad()
end
