---=============================================================================
-- Interaction Camera Wheel UI
--=============================================================================
function CinematicCam:InitializeCameraWheel()
    self.cameraWheelVisible = false
    self.cameraPadVisible = false

    -- Set platform-specific trigger icon
    self:SetPlatformCameraTriggerIcon()

    -- Start hidden
    self:HideCameraWheel()
    self:HideCameraPad()
end

-- Set the correct trigger icon based on platform for camera wheel
function CinematicCam:SetPlatformCameraTriggerIcon()
    local xboxRT = _G["CinematicCam_XboxRT"]
    local ps4RT = _G["CinematicCam_PS4RT"]
    local xboxRS_Slide = _G["CinematicCam_XboxRS_Slide"]
    local xboxRS_Scroll = _G["CinematicCam_XboxRS_Scroll"]
    local ps4RS = _G["CinematicCam_PS4RS"]

    if not xboxRT or not ps4RT then
        return
    end

    local worldName = GetWorldName()

    -- Default to Xbox, switch to PS if on PlayStation
    if worldName == "PS4live" or worldName == "PS4live-eu" or worldName == "NA Megaserver" then
        -- Show PlayStation icons
        xboxRT:SetTexture("/esoui/art/buttons/gamepad/ps5/nav_ps5_r2.dds")

        if xboxRS_Slide then xboxRS_Slide:SetTexture("/esoui/art/buttons/gamepad/ps5/nav_ps5_rs_slide.dds") end
        if xboxRS_Scroll then xboxRS_Scroll:SetTexture("/esoui/art/buttons/gamepad/ps5/nav_ps5_rs_scroll.dds") end
        if ps4RS then ps4RS:SetHidden(false) end
    else
        -- Show Xbox icons (includes PC, NA Megaserver, EU Megaserver, XB1live, XB1live-eu)
        xboxRT:SetHidden(false)
        ps4RT:SetHidden(true)

        if xboxRS_Slide then xboxRS_Slide:SetHidden(false) end
        if xboxRS_Scroll then xboxRS_Scroll:SetHidden(false) end
        if ps4RS then ps4RS:SetHidden(true) end
    end
end

-- Show the camera wheel indicator
function CinematicCam:ShowCameraWheel()
    local control = _G["CinematicCam_CameraWheel"]
    if not control then return end

    -- Set platform-specific icon BEFORE showing
    self:SetPlatformCameraTriggerIcon()

    control:SetHidden(false)
    control:SetAlpha(0)

    -- Fade in animation
    local timeline = ANIMATION_MANAGER:CreateTimeline()
    local animation = timeline:InsertAnimation(ANIMATION_ALPHA, control)
    animation:SetAlphaValues(0, 1)
    animation:SetDuration(200)
    animation:SetEasingFunction(ZO_EaseOutQuadratic)
    timeline:PlayFromStart()

    self.cameraWheelVisible = true
end

-- Hide the camera wheel indicator
function CinematicCam:HideCameraWheel()
    local control = _G["CinematicCam_CameraWheel"]
    if not control then return end

    -- Fade out animation
    local timeline = ANIMATION_MANAGER:CreateTimeline()
    local animation = timeline:InsertAnimation(ANIMATION_ALPHA, control)
    animation:SetAlphaValues(control:GetAlpha(), 0)
    animation:SetDuration(200)
    animation:SetEasingFunction(ZO_EaseOutQuadratic)

    timeline:SetHandler("OnStop", function()
        control:SetHidden(true)
    end)

    timeline:PlayFromStart()

    self.cameraWheelVisible = false
end

-- Show the camera directional pad
function CinematicCam:ShowCameraPad()
    local control = _G["CinematicCam_CameraPad"]
    if not control then return end

    control:SetHidden(false)
    control:SetAlpha(0)

    -- Fade in animation
    local timeline = ANIMATION_MANAGER:CreateTimeline()
    local animation = timeline:InsertAnimation(ANIMATION_ALPHA, control)
    animation:SetAlphaValues(0, 1)
    animation:SetDuration(150)
    animation:SetEasingFunction(ZO_EaseOutQuadratic)
    timeline:PlayFromStart()

    self.cameraPadVisible = true
end

-- Hide the camera directional pad
function CinematicCam:HideCameraPad()
    local control = _G["CinematicCam_CameraPad"]
    if not control then return end

    -- Fade out animation
    local timeline = ANIMATION_MANAGER:CreateTimeline()
    local animation = timeline:InsertAnimation(ANIMATION_ALPHA, control)
    animation:SetAlphaValues(control:GetAlpha(), 0)
    animation:SetDuration(150)
    animation:SetEasingFunction(ZO_EaseOutQuadratic)

    timeline:SetHandler("OnStop", function()
        control:SetHidden(true)
    end)

    timeline:PlayFromStart()

    self.cameraPadVisible = false
end

-- Highlight active camera direction
function CinematicCam:HighlightCameraDirection(direction)
    local directions = { "Top", "Right", "Bottom", "Left" }

    for _, dir in ipairs(directions) do
        local texture = _G["CinematicCam_CameraPad_" .. dir]
        if texture then
            if dir == direction then
                texture:SetColor(0.3, 0.3, 0.3, 0.95) -- Lighter gray for selected
            else
                -- ALL directions now active (not just Top/Bottom)
                texture:SetColor(0, 0, 0, 0.85) -- Dark for unselected active buttons
            end
        end
    end
end

function CinematicCam:ResetCameraHighlights()
    local directions = { "Top", "Right", "Bottom", "Left" }

    for _, dir in ipairs(directions) do
        local texture = _G["CinematicCam_CameraPad_" .. dir]
        if texture then
            texture:SetColor(0, 0, 0, 0.85) -- All active now
        end
    end
end
