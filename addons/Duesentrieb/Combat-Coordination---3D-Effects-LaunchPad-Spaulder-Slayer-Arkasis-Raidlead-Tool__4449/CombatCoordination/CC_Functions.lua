local CC = CombatCoordination

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
CC.Functions ={
    Default = {},
    ---@type table|any
    SV = {},
}

----------------------------------------------------------------------------------------------------
-- GET SUB-SAMPLING
----------------------------------------------------------------------------------------------------
function CC.CheckSubSamplingSetting()
    if true then return end

    local rawValue = GetSetting(SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_SUB_SAMPLING)
    local currentValue = tonumber(rawValue)

    if currentValue ~= SUB_SAMPLING_MODE_MEDIUM then
        SetSetting(SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_SUB_SAMPLING, SUB_SAMPLING_MODE_MEDIUM)
        ApplySettings()

        d(string.format("%s Sub-Sampling: %s -> %s", CC.CHAT, tostring(currentValue), SUB_SAMPLING_MODE_MEDIUM))
    else
        d(string.format("%s Sub-Sampling MEDIUM. Nothing changed.", CC.CHAT))
    end
end

----------------------------------------------------------------------------------------------------
-- CALC SPAWN POSITION BASED ON SKILL TYPE
----------------------------------------------------------------------------------------------------
function CC.GetAbilityTargetPosition(SkillData, originX, originY, originZ, heading)
    if not SkillData then return nil, nil, nil end
    heading = heading or 0

    local targetX, targetY, targetZ = nil, nil, nil

    -- LOCAL EFFECTS LIKE WALL (FORW OFFSET)
    if SkillData.type == CC.SKILL_TYPE_FIXED then
        local offsetPlayer = (SkillData.offsetPlayer or 0) * 100

        targetX = originX - offsetPlayer * math.sin(heading)
        targetY = originY
        targetZ = originZ - offsetPlayer * math.cos(heading)

    -- RANGE EFFECTS LIKE CALTROPS
    elseif SkillData.type == CC.SKILL_TYPE_RANGED then
        local maxRange = (SkillData.maxRange or 28) * 100
        targetX, targetY, targetZ = CC.GetCameraTargetPosition(originY, maxRange)
    end

    return targetX, targetY, targetZ
end

----------------------------------------------------------------------------------------------------
-- CALC ROTATION OF GROUND AT TARGET POS
----------------------------------------------------------------------------------------------------
function CC.GetGroundRotation(TX, TY, TZ)
    -- THIS WILL GET IMPLEMENTED ONCE LIBHEIGHTMAP IS READY
    local RX = -(math.pi / 2)
    local RY = 0
    local RZ = 0
    return RX, RY, RZ
end

----------------------------------------------------------------------------------------------------
-- GET CAMERA YAW
----------------------------------------------------------------------------------------------------
function CC.GetCameraYaw()
    local forwardX, _, forwardZ = GetCameraForward(SPACE_WORLD)
    local cameraYaw = math.atan2(forwardX, forwardZ) - math.pi
    return cameraYaw
end

----------------------------------------------------------------------------------------------------
-- GET CAMERA PITCH
----------------------------------------------------------------------------------------------------
function CC.GetCameraPitch()
    local forwardX, forwardY, forwardZ = GetCameraForward(SPACE_WORLD)
    local cameraPitch = math.atan2(forwardY, math.sqrt((forwardX * forwardX) + (forwardZ * forwardZ)))
    return cameraPitch
end

----------------------------------------------------------------------------------------------------
-- CALC RANGE TARGET POS
----------------------------------------------------------------------------------------------------
function CC.GetCameraTargetPosition(originY, maxRange)
    -- https://wiki.esoui.com/Positions
    Set3DRenderSpaceToCurrentCamera(CC.DisplayEffect.cameraName)

    local renderX, renderY, renderZ = CC.DisplayEffect.Camera:Get3DRenderSpaceOrigin()
    local worldX, worldY, worldZ = GuiRender3DPositionToWorldPosition(renderX, renderY, renderZ)
    local forwardX, forwardY, forwardZ = GetCameraForward(SPACE_WORLD)

    -- CALC YAW
    local cameraYaw = math.atan2(forwardX, forwardZ) - math.pi
    -- PITCH: ARCTAN(Y / (X^2 + Z^2))
    local cameraPitch = math.atan2(forwardY, math.sqrt((forwardX * forwardX) + (forwardZ * forwardZ)))
    -- local maxPitch = math.rad(-2.5) -- (-2.5°) FROM HORIZONTAL
    local maxPitch = -0.043633231
    -- CALC DIST NOW
    local distance = (worldY - originY) / math.tan(cameraPitch)
    -- https://wiki.esoui.com/Positions -> HAS A CONSISTENT 1:100 SCALE
    local rangeLimit = maxRange or 2800

    if cameraPitch > maxPitch then
        distance = rangeLimit
    else
        distance = (worldY - originY) / math.tan(cameraPitch)
        if distance > rangeLimit and maxRange ~= 0 then
            distance = rangeLimit
        end
    end

    -- X AND Z CALC
    local targetX = distance * math.sin(cameraYaw) + worldX
    local targetY = originY
    local targetZ = distance * math.cos(cameraYaw) + worldZ

    return targetX, targetY, targetZ
end

----------------------------------------------------------------------------------------------------
-- PREVIEW AIMING START POSITION
----------------------------------------------------------------------------------------------------
function CC.GetAimTargetPosition()
    local _, playerX, playerY, playerZ = GetUnitRawWorldPosition("player")
    local startX, startY, startZ = playerX or 0, playerY or 0, playerZ or 0

    if playerY then
        local cameraX, cameraY, cameraZ = CC.GetCameraTargetPosition(playerY, 5400)
        if cameraX and cameraY and cameraZ then
            startX, startY, startZ = cameraX, cameraY, cameraZ
        end
    end

    return startX, startY, startZ
end