-- SPDX-FileCopyrightText: 2025 m00nyONE
-- SPDX-License-Identifier: Artistic-2.0

--[[ doc.lua begin ]]
local addon_name = "SocialIcons"
local addon = _G[addon_name]

local LCI = LibCustomIcons

-- the textures are copied from OdySupportIcons
addon.PLAYER_STATUS = {
    [PLAYER_STATUS_ONLINE]          = "SocialIcons/textures/status-on.dds",
    [PLAYER_STATUS_AWAY]            = "SocialIcons/textures/status-afk.dds",
    [PLAYER_STATUS_DO_NOT_DISTURB]  = "SocialIcons/textures/status-dnd.dds",
    [PLAYER_STATUS_OFFLINE]         = "SocialIcons/textures/status-off.dds",
}

--- Create a hook for the given ZO_SocialManager's SetupEntry function
--- @param socialManager ZO_SocialManager
--- @return void
function addon.createHook(socialManager)
    local setupEntryOriginal = socialManager.SetupEntry
    local function setupEntryHook(self, control, data, selected)
        setupEntryOriginal(self, control, data, selected)
        addon.setupEntryHook(self, control, data, selected)
    end
    socialManager.SetupEntry = setupEntryHook
end

--- Hook function for ZO_SocialManager's SetupEntry
--- @param self ZO_SocialManager
--- @param control Control The control being set up
--- @param data table The data for the entry
--- @param selected boolean Whether the entry is selected
--- @return void
function addon.setupEntryHook(self, control, data, selected)
    local texturePath, left, right, top, bottom, width, height, fps = addon.getUserIcon(data.displayName, addon.sw.enableAnimations)
    local isAnimation = width and height and fps

    local originalStatusIcon = control:GetNamedChild("StatusIcon")
    local overlay = control:GetNamedChild("SocialIconsOverlay")
    if not overlay then
        overlay = addon.createOverlay(control, originalStatusIcon)
    end
    local userIcon = overlay:GetNamedChild("UserIcon")
    local statusIcon = overlay:GetNamedChild("StatusIcon")
    local animation = userIcon.animation

    -- no icon found, reset to default
    if not texturePath then
        addon.stopAnimation(animation)
        overlay:SetHidden(true)
        originalStatusIcon:SetAlpha(1)
        return
    end
    originalStatusIcon:SetAlpha(0)
    overlay:SetHidden(false)

    -- set up icon
    userIcon:SetDrawLayer(2)
    userIcon:SetTexture(texturePath)
    userIcon:SetTextureCoords(left, right, top, bottom)
    userIcon:SetDesaturation(data.online and 0 or 1)

    statusIcon:SetTexture(addon.PLAYER_STATUS[data.status or PLAYER_STATUS_OFFLINE])
    statusIcon:SetTextureCoords(0, 1, 0, 1)

    -- if the user has no animation, we can stop here
    if not isAnimation then
        addon.stopAnimation(animation)
        userIcon:SetTextureCoords(left, right, top, bottom)
        return
    end

    -- set up and start animation
    animation.animationObject:SetImageData(width, height)
    animation.animationObject:SetFramerate(fps)
    addon.startAnimation(animation)
end

--- Create an overlay control on top of the given control
--- @param parent Control The parent control for the overlay
--- @param overlayOnTopOf Control The control to overlay on top of
--- @return Control The created overlay control
function addon.createOverlay(parent, overlayOnTopOf)
    -- push the control that gets overlay to the background
    overlayOnTopOf:SetDrawLayer(1)

    -- create overlay and it's controls
    local overlayName = string.format("%s%s", parent:GetName(), "SocialIconsOverlay")
    local overlay = parent:CreateControl(overlayName, CT_CONTROL)
    overlay:ClearAnchors()
    overlay:SetParent(parent)
    overlay:SetAnchor(CENTER, overlayOnTopOf, CENTER, 0, 0)
    overlay:SetDimensions(overlayOnTopOf:GetWidth() - 4, overlayOnTopOf:GetHeight() - 4 )
    overlay:SetInheritAlpha(false)
    local userIconName = string.format("%s%s", overlay:GetName(), "UserIcon")
    local userIcon = overlay:CreateControl(userIconName, CT_TEXTURE)
    userIcon:ClearAnchors()
    userIcon:SetParent(overlay)
    userIcon:SetAnchor(CENTER, overlay, CENTER, 0, 0 )
    userIcon:SetDimensions(overlay:GetWidth(), overlay:GetHeight() )
    userIcon:SetDrawLayer(2)
    local statusIconName = string.format("%s%s", overlay:GetName(), "StatusIcon")
    local statusIcon = overlay:CreateControl(statusIconName, CT_TEXTURE)
    statusIcon:ClearAnchors()
    statusIcon:SetParent(overlay)
    statusIcon:SetAnchor(CENTER, overlay, CENTER, 0, 0 )
    statusIcon:SetDimensions(overlay:GetWidth() + 4, overlay:GetHeight() + 4)
    statusIcon:SetDrawLayer(3)

    -- create an animation for the userIcon control
    local timeline = ANIMATION_MANAGER:CreateTimeline()
    timeline:SetPlaybackType( ANIMATION_PLAYBACK_LOOP, LOOP_INDEFINITELY )
    local animationObject = timeline:InsertAnimation(ANIMATION_TEXTURE, userIcon)
    userIcon.animation = {
        timeline = timeline,
        animationObject = animationObject,
    }

    return overlay
end

--- Get the user icon texture path and coordinates
--- @param displayName string The display name of the user
--- @param enableAnimations boolean Whether animations are enabled
--- @return string texturePath, number left, number right, number top, number bottom, number|nil columns, number|nil rows, number|nil fps
function addon.getUserIcon(displayName, enableAnimations)
    local texturePath, left, right, top, bottom, columns, rows, fps = nil, 0, 1, 0, 1, nil, nil, nil
    local hasAnimated = LCI.HasAnimated(displayName)
    local hasStatic = LCI.HasStatic(displayName)

    -- prefer animated icon if animations are enabled
    if enableAnimations and hasAnimated then
        texturePath, left, right, top, bottom, columns, rows, fps = LCI.GetAnimated(displayName)
        if type(texturePath) == "table" then
            texturePath, left, right, top, bottom, columns, rows, fps = texturePath[1], 0, 1, 0, 1, texturePath[2], texturePath[3], texturePath[4]
        end

    -- prefer static if animations are not enabled
    elseif hasStatic then
        texturePath, left, right, top, bottom = LCI.GetStatic(displayName)

    -- fallback to animated and take the first frame if no static icon found
    elseif hasAnimated then
        texturePath, left, right, top, bottom, columns, rows, fps = LCI.GetAnimated(displayName) -- for combined textures support of LCI
        if type(texturePath) == "table" then
            texturePath, left, right, top, bottom, columns, rows, fps = texturePath[1], 0, 1/texturePath[2], 0, 1/texturePath[3], nil, nil, nil -- take first frame only (legacy support of LCI)
        else -- take first frame only (combined textures)
            left, right, top, bottom = left, right/columns, top, bottom/rows -- take first frame only
        end
    end

    return texturePath, left, right, top, bottom, columns, rows, fps
end

--- Start the given animation if not already playing
--- @param animation table The animation to start
--- @return void
function addon.startAnimation(animation)
    if animation and not animation.timeline:IsPlaying() then
        animation.timeline:PlayFromStart()
    end
end
--- Stop the given animation if playing
--- @param animation table The animation to stop
--- @return void
function addon.stopAnimation(animation)
    if animation and animation.timeline:IsPlaying() then
        animation.timeline:Stop()
    end
end

--[[ doc.lua end ]]