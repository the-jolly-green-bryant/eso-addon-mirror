BetterGuardAddon = BetterGuardAddon or {}
local BG = BetterGuardAddon

-- Function to convert Hue to RGB. Assumes Saturation = 1 and Value = 1
local function hueToRGB(h)
    local x = 1 - math.abs((h / 60) % 2 - 1)
    local r, g, b

    if h >= 0 and h < 60 then
        r, g, b = 1, x, 0
    elseif h >= 60 and h < 120 then
        r, g, b = x, 1, 0
    elseif h >= 120 and h < 180 then
        r, g, b = 0, 1, x
    elseif h >= 180 and h < 240 then
        r, g, b = 0, x, 1
    elseif h >= 240 and h < 300 then
        r, g, b = x, 0, 1
    else
        r, g, b = 1, 0, x
    end

    return {r, g, b, BG.savedVariables.alpha}
end

local function calculateLineColour(distance)
    if BG.savedVariables.rainbowLine then
        local rainbowColour = hueToRGB((GetGameTimeMilliseconds() / 20) % 360)
        return rainbowColour
    end

    local safezone = BG.savedVariables.safeDistance * 100
    local lerpColour

    if distance <= safezone then
        lerpColour = { unpack(BG.savedVariables.safeColour) }
    else
        local maxDist = 1600 - safezone
        local t = math.min((distance - safezone) / maxDist, 1)
        lerpColour = zo_lerpVector(BG.savedVariables.safeColour, BG.savedVariables.breakingColour, t)
    end

    lerpColour[4] = BG.savedVariables.alpha
    return lerpColour
end

local Quaternion = LibImplex.Q

local CROSS_OFFSET_A = Quaternion.FromEuler(2.35619449019, 0, 0) -- 135 degrees
local CROSS_OFFSET_B = Quaternion.FromEuler(0.78539816339, 0, 0) -- 45 degrees

local line3D
local line3DFlat
local function DrawLine3D(unitTag1, unitTag2)
    local _, x1, y1, z1 = GetUnitRawWorldPosition(unitTag1)
    local _, x2, y2, z2 = GetUnitRawWorldPosition(unitTag2)

    if (x1 == 0 and y1 == 0 and z1 == 0) or (x2 == 0 and y2 == 0 and z2 == 0) then
        line3D:SetHidden(true)
        line3DFlat:SetHidden(true)
    elseif line3D:IsHidden() or line3DFlat:IsHidden() then
        line3D:SetHidden(false)
        line3DFlat:SetHidden(false)
    end

    local fdx = x2 - x1
    local fdy = y2 - y1
    local fdz = z2 - z1
    local mx = x1 + fdx * 0.5
    local my = y1 + fdy * 0.5
    local mz = z1 + fdz * 0.5

    local distance = zo_distance3D(x1, y1, z1, x2, y2, z2)
    if distance < 1e-4 then return end

    local col = calculateLineColour(distance) or {1, 0, 1, 1}
    local width = distance / 100.0
    local height = BG.savedVariables.width / 20.0

    local yaw = math.pi / 2.0 + math.atan2(fdx, fdz)
    local horizontalDist = math.sqrt(fdx * fdx + fdz * fdz)
    local tilt = -math.atan2(fdy, horizontalDist)

    local qTilt = Quaternion.FromEuler(0, 0, tilt)
    local qLine3D     = qTilt * CROSS_OFFSET_A
    local qLine3DFlat = qTilt * CROSS_OFFSET_B

    local pitchA, yawA, rollA = Quaternion.ToEuler(qLine3D)
    local pitchB, yawB, rollB = Quaternion.ToEuler(qLine3DFlat)

    local wX, wY, wZ = WorldPositionToGuiRender3DPosition(mx, my + 170, mz)
    if not BG.depthwin:Has3DRenderSpace() then
        BG.depthwin:Create3DRenderSpace()
    end
    BG.depthwin:Set3DRenderSpaceOrigin(wX, wY, wZ)
    BG.depthwin:Set3DRenderSpaceOrientation(0.0, yaw, 0.0)

    if not line3D:Has3DRenderSpace() then
        line3D:Create3DRenderSpace()
    end
    line3D:SetColor(unpack(col))
    line3D:Set3DLocalDimensions(width, height)
    line3D:Set3DRenderSpaceOrientation(pitchA, yawA, rollA)

    if not line3DFlat:Has3DRenderSpace() then
        line3DFlat:Create3DRenderSpace()
    end
    line3DFlat:SetColor(unpack(col))
    line3DFlat:Set3DLocalDimensions(width, height)
    line3DFlat:Set3DRenderSpaceOrientation(pitchB, yawB, rollB)
end

local function instantiateLine(control)
    if control then
        control:SetTexture("BetterGuard/line_textures/gradient.dds")
        control:Set3DRenderSpaceUsesDepthBuffer(BG.savedVariables.depthBuffer)
        control:SetDrawLevel(3)
        if control:IsHidden() then
            control:SetHidden(false)
        end
    end
end

function BG.OnUpdateLine(unitTag1, unitTag2)
    if not line3D then
        line3D = WINDOW_MANAGER:CreateControl("$(parent)GuardLine3D", BG.depthwin, CT_TEXTURE)
    end
    if not line3DFlat then
        line3DFlat = WINDOW_MANAGER:CreateControl("$(parent)GuardLine3DFlat", BG.depthwin, CT_TEXTURE)
    end
    instantiateLine(line3D)
    instantiateLine(line3DFlat)

    DrawLine3D(unitTag1, unitTag2)
end

function BG.DrawLineBetweenPlayers(unitTag1, unitTag2) -- /script BetterGuardAddon.DrawLineBetweenPlayers("group1", "group2")
    BG.unitTag1 = unitTag1
    BG.unitTag2 = unitTag2
    BG.StartPolling()
end

local function hideLine(control)
    if control then
        control:SetHidden(true)
        control:SetColor(0, 0, 0, 0)
        if control:Has3DRenderSpace() then
            control:Destroy3DRenderSpace()
        end
    end
end

function BG.RemoveLine() -- /script BetterGuardAddon.RemoveLine()
    BG.StopPolling()
    hideLine(line3D)
    hideLine(line3DFlat)
    if BG.depthwin:Has3DRenderSpace() then
        BG.depthwin:Destroy3DRenderSpace()
    end
end