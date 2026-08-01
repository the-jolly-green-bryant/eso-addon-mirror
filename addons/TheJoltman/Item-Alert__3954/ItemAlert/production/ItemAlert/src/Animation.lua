--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.PingPongAnimation(control)

    if control == nil then return end

    -- Create a timeline containing the animation to produce a ping-pong type effect by scaleing the display bar
    if control.timeline == nil then

        local animation, timeline = CreateSimpleAnimation(ANIMATION_SCALE, control, 0)
        animation:SetScaleValues(1, 1.25)
        animation:SetDuration(150)
        control.animation = animation
        control.timeline = timeline
        control.timeline:SetPlaybackType(ANIMATION_PLAYBACK_PING_PONG, 3)

    end

    -- Do not start playing if an animation is already playing
    if control.timeline:IsPlaying() then return end

    -- Play the animation timeline
    control.timeline:PlayFromStart()

end