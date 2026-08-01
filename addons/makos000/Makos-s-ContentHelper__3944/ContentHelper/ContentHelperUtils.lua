ContentHelper = ContentHelper or {}
local ContentHelper = ContentHelper

---------------------------------------------------
---------------------------------------------------
----------- Saved Variables
---------------------------------------------------
---------------------------------------------------

function ContentHelper.SavedVars()
    if (ContentHelper.savedVariables.soundEffect == nil) then
        ContentHelper.savedVariables.soundEffect = "JUSTICE_PICKPOCKET_BONUS"
    end

    if (ContentHelper.savedVariables.texture == nil) then
        ContentHelper.savedVariables.texture = { "ContentHelper/ic/square_green.dds", "static", nil }
    end

    if (ContentHelper.savedVariables.iconSize == nil) then
        ContentHelper.savedVariables.iconSize = 170
    end

    if (ContentHelper.savedVariables.placeVolume == nil) then
        ContentHelper.savedVariables.placeVolume = 5
    end

    if (ContentHelper.savedVariables.debug == nil) then
        ContentHelper.savedVariables.debug = false
    end

    if (ContentHelper.savedVariables.chatNot == nil) then
        ContentHelper.savedVariables.chatNot = true
    end

    if (ContentHelper.savedVariables.isMarkerEnemy == nil) then
        ContentHelper.savedVariables.isMarkerEnemy = true
    end

    if (ContentHelper.savedVariables.enemyMarkerSize == nil) then
        ContentHelper.savedVariables.enemyMarkerSize = 120
    end
end

---------------------------------------------------
---------------------------------------------------
----------- UI
---------------------------------------------------
---------------------------------------------------

function ContentHelper.CreateTextureGrid()
    local gridSize = 14
    local iconSize = 50
    local windowSize = gridSize * iconSize

    local window = WINDOW_MANAGER:CreateTopLevelWindow("RandomTextureGridWindow")
    window:SetDimensions(windowSize, windowSize)
    window:SetAnchor(BOTTOM, GuiRoot, BOTTOM, 0, 0)
    window:SetMouseEnabled(true)
    window:SetMovable(false)
    window:SetClampedToScreen(true)
    window:SetHidden(true)

    local background = WINDOW_MANAGER:CreateControl("$(parent)Background", window, CT_TEXTURE)
    background:SetDimensions(windowSize, windowSize)
    background:SetAnchor(CENTER, window, CENTER, 0, 0)
    background:SetColor(0, 0, 0, 1)
    background:SetTexture(nil)

    local textures = ContentHelper.textures
    if TbudkosIcons and TbudkosIcons.textures then
        ContentHelper.AppendTables(ContentHelper.textures, TbudkosIcons.textures)
        textures = ContentHelper.textures
    end
    local textureCount = #textures

    if not ContentHelper.savedVariables.texture then
        ContentHelper.savedVariables.texture = { "ContentHelper/ic/square_green.dds", "static", nil }
    end

    local button = WINDOW_MANAGER:CreateTopLevelWindow("SimpleButton")
    button:SetDimensions(50, 50)
    local buttonX = ContentHelper.savedVariables.buttonX or 200
    local buttonY = ContentHelper.savedVariables.buttonY or 200
    button:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, buttonX, buttonY)
    button:SetMouseEnabled(true)
    button:SetMovable(true)
    button:SetClampedToScreen(true)

    local buttonBg = WINDOW_MANAGER:CreateControl("$(parent)Bg", button, CT_TEXTURE)
    buttonBg:SetAnchorFill(button)

    if ContentHelper.savedVariables.texture then
        buttonBg:SetTexture(ContentHelper.savedVariables.texture[1])
    else
        buttonBg:SetTexture("ContentHelper/ic/square_green.dds")
    end

    local textureIndex = 1
    for row = 0, gridSize - 1 do
        for col = 0, gridSize - 1 do
            if textureIndex <= textureCount then
                local currentTexture = textures[textureIndex]
                local textureButton = WINDOW_MANAGER:CreateControl("$(parent)Texture" .. row .. "_" .. col, window, CT_BUTTON)
                textureButton:SetDimensions(iconSize, iconSize)
                textureButton:SetAnchor(TOPLEFT, window, TOPLEFT, col * iconSize, row * iconSize)
                textureButton:SetHidden(false)
                textureButton:SetMouseEnabled(true)

                if currentTexture[2] == "animated" then

                    local tex = WINDOW_MANAGER:CreateControl(nil, textureButton, CT_TEXTURE)
                    tex:SetAnchorFill()
                    tex:SetTexture(currentTexture[1])
                    tex:SetDrawLayer(DL_CONTROLS)

                    local timeline = ANIMATION_MANAGER:CreateTimeline()
                    timeline:SetPlaybackType(ANIMATION_PLAYBACK_LOOP, LOOP_INDEFINITELY)

                    local anim = timeline:InsertAnimation(ANIMATION_TEXTURE, tex)
                    anim.ctrl = anim
                    anim.ctrl:SetImageData(currentTexture[3][2], currentTexture[3][3]) -- cols, rows
                    anim.ctrl:SetFramerate(currentTexture[3][1]) -- FPS
                    timeline:PlayFromStart()

                    textureButton._animated = tex
                    textureButton._timeline = timeline
                else
                    textureButton:SetNormalTexture(currentTexture[1])
                end

                textureButton:SetHandler("OnClicked", function()
                    if currentTexture then
                        ContentHelper.savedVariables.texture = currentTexture
                        buttonBg:SetTexture(ContentHelper.savedVariables.texture[1])
                        window:SetHidden(not window:IsHidden())
                    end
                end)

                textureIndex = textureIndex + 1
            else
                break
            end
        end
        if textureIndex > textureCount then
            break
        end
    end

    local function UpdateGridPosition()
        window:ClearAnchors()
        window:SetAnchor(BOTTOM, button, TOP, 0, 0)
    end

    local function SaveButtonPosition()
        local left, top = button:GetLeft(), button:GetTop()
        ContentHelper.savedVariables.buttonX = left
        ContentHelper.savedVariables.buttonY = top
    end

    button:SetHandler("OnMoveStop", function()
        UpdateGridPosition()
        SaveButtonPosition()
    end)

    button:SetHandler("OnMouseDown", function()
        window:SetHidden(not window:IsHidden())
        if not window:IsHidden() then
            UpdateGridPosition()
        end
    end)

    UpdateGridPosition()
end



---------------------------------------------------
---------------------------------------------------
----------- Sounds
---------------------------------------------------
---------------------------------------------------

function ContentHelper.PreviewSound()

    for i = 1, 10 do
        PlaySound(SOUNDS[potential_sounds[r]])
    end

    d(potential_sounds[r])

    r = r + 1
end

function ContentHelper.PlayCustomSound()
    PlaySound(SOUNDS.COUNTDOWN_TICK)
    PlaySound(SOUNDS.COUNTDOWN_TICK)
    PlaySound(SOUNDS.COUNTDOWN_TICK)
end

function ContentHelper.PlayCustomSound2()
    PlaySound(SOUNDS.JUSTICE_STATE_CHANGED)
    PlaySound(SOUNDS.JUSTICE_STATE_CHANGED)
    PlaySound(SOUNDS.JUSTICE_STATE_CHANGED)
end

function ContentHelper.PlayRWSound()
    PlaySound(SOUNDS.TRIBUTE_SUMMARY_PLACEMENT_MATCH_SEGMENT_FILL_VICTORY)
    PlaySound(SOUNDS.TRIBUTE_SUMMARY_PLACEMENT_MATCH_SEGMENT_FILL_VICTORY)
    PlaySound(SOUNDS.TRIBUTE_SUMMARY_PLACEMENT_MATCH_SEGMENT_FILL_VICTORY)
    PlaySound(SOUNDS.TRIBUTE_SUMMARY_PLACEMENT_MATCH_SEGMENT_FILL_VICTORY)
    PlaySound(SOUNDS.TRIBUTE_SUMMARY_PLACEMENT_MATCH_SEGMENT_FILL_VICTORY)
end

function ContentHelper.PlayPlaceMarker()

    local volume = ContentHelper.savedVariables.placeVolume

    for i = 1, volume, 1 do
        PlaySound(SOUNDS[ContentHelper.savedVariables.soundEffect])
    end

end

---------------------------------------------------
---------------------------------------------------
----------- Helpers
---------------------------------------------------
---------------------------------------------------

function ContentHelper.ClearText()
    CDLabel1:SetText("")
end

function ContentHelper.Debug()
    ContentHelper.savedVariables.debug = not ContentHelper.savedVariables.debug
    d("debug is " .. tostring(ContentHelper.savedVariables.debug))
end

function ContentHelper.MarkerOffCD()

    isMarkerCD = false

end

function ContentHelper.FindIndex(t, str)
    for i, v in ipairs(t) do
        --d(i .. ": " .. tostring(v[1]))
        --d(str)
        if v[1] == str then
            return i
        end
    end
    return nil
end

function ContentHelper.AppendTables(a, b)
    for i = 1, #b do
        table.insert(a, b[i])
    end
end

function ContentHelper.MarkMakos()
    local zone, mx, my, mz = GetUnitRawWorldPosition( "player" )

    ContentHelper.iconA = OSI.CreatePositionIcon(
            mx,
            my,
            mz,
            "/esoui/art/buttons/large_downarrow_up.dds",
            180,
            {1,0,0}
    )

    local function UpdateRaidIcon()

        local zone, mx, my, mz = GetUnitRawWorldPosition("player")

        if DoesUnitExist("player") then


            ContentHelper.iconA.x = mx
            ContentHelper.iconA.y = my + 25
            ContentHelper.iconA.z = mz
            ContentHelper.iconA.ctrl:SetHidden(false)
        else
            ContentHelper.iconA.ctrl:SetHidden(true)
        end
    end

    local function OnPlayerActivated()
        EVENT_MANAGER:RegisterForUpdate("SimpleRaidIconUpdate", 10, UpdateRaidIcon)
    end

    EVENT_MANAGER:RegisterForEvent("SimpleRaidIconInit", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    OnPlayerActivated()
end



