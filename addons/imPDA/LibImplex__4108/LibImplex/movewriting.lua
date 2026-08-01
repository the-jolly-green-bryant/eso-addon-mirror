function LibImplex_Move(direction)
	local editedText = LIB_IMPLEX_EDITED_TEXT[1]
	local editedTextPosition = editedText.position

    local increment = 1

    if direction == 'u' then
        editedTextPosition[2] = editedTextPosition[2] + increment
        return
    elseif direction == 'd' then
        editedTextPosition[2] = editedTextPosition[2] - increment
        return
    end

    local cameraHeading = GetPlayerCameraHeading()

    if direction == 'f' then
        increment = -1
    elseif direction == 'b' then
        increment = 1
    elseif direction == 'r' then
        cameraHeading = cameraHeading - math.pi / 2
        increment = -1
    elseif direction == 'l' then
        cameraHeading = cameraHeading - math.pi / 2
        increment = 1
    end

    local dx = math.sin(cameraHeading) * increment
    local dz = math.cos(cameraHeading) * increment

	editedTextPosition[1] = editedTextPosition[1] + dx
    editedTextPosition[3] = editedTextPosition[3] + dz

    editedText:Rerender()

    LIB_IMPLEX_EDITED_TEXT[2].control:Set3DRenderSpaceOrigin(WorldPositionToGuiRender3DPosition(unpack(editedTextPosition)))
end