TetsuCombatHealerHelper = TetsuCombatHealerHelper or {}
local T = TetsuCombatHealerHelper

T.Puddle = T.Puddle or {}
local P = T.Puddle

local CONTROL_NAME = "TetsuCHH_Puddle"
local TIMER_NAME = "TetsuCHH_PuddleHide"

local control
local expiresAt = 0

local function EnsureControl()
    if control then return control end
    local wm = WINDOW_MANAGER
    if not wm or not wm.CreateControl then return nil end

    local parent = GuiRoot
    if wm.CreateTopLevelWindow then
        parent = wm:CreateTopLevelWindow(CONTROL_NAME .. "TL") or GuiRoot
        parent:SetHidden(false)
        parent:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 0, 0)
        parent:SetDimensions(1, 1)
        parent:SetMouseEnabled(false)
    end

    local c = wm:CreateControl(CONTROL_NAME, parent, CT_TEXTURE)
    if not c then return nil end

    if c.Create3DRenderSpace then
        c:Create3DRenderSpace()
    end
    if GUI_RENDER_3D_SPACE_SYSTEM_WORLD and c.Set3DRenderSpaceSystem then
        c:Set3DRenderSpaceSystem(GUI_RENDER_3D_SPACE_SYSTEM_WORLD)
    end
    -- Depth on: characters and world draw over the ring.
    if c.Set3DRenderSpaceUsesDepthBuffer then
        c:Set3DRenderSpaceUsesDepthBuffer(true)
    end
    c:SetHidden(true)
    c:SetDrawLevel(20)
    if c.SetBlendMode and TEX_BLEND_MODE_ALPHA then
        c:SetBlendMode(TEX_BLEND_MODE_ALPHA)
    end
    -- Round ability glow, not the quest diamond we used in 1.0.2.
    c:SetTexture("TetsuCombatHealerHelper/textures/circle.dds")
    if c.Set3DRenderSpaceOrientation then
        c:Set3DRenderSpaceOrientation(-math.pi / 2, 0, 0)
    end
    control = c
    return c
end

local function ApplyVisual()
    local c = EnsureControl()
    if not c then return end
    local vars = T.savedVars
    if not vars then return end

    local col = vars.puddleColor or { r = 0.25, g = 0.95, b = 0.45, a = 0.35 }
    local a = vars.puddleAlpha
    if a == nil then a = col.a or 0.35 end
    c:SetColor(col.r or 0.25, col.g or 0.95, col.b or 0.45, a)

    local diameter = (T.PUDDLE_RADIUS_M or 8) * 2
    if c.Set3DLocalDimensions then
        c:Set3DLocalDimensions(diameter, diameter)
    end
end

function P.Hide()
    expiresAt = 0
    EVENT_MANAGER:UnregisterForUpdate(TIMER_NAME)
    if control then
        control:SetHidden(true)
    end
end

function P.Place(xM, yM, zM, durationMs)
    local vars = T.savedVars
    if not vars or vars.enabled == false or vars.puddleEnabled == false then
        P.Hide()
        return
    end
    if not xM then return end

    local c = EnsureControl()
    if not c then return end

    ApplyVisual()
    c:Set3DRenderSpaceOrigin(xM, yM, zM)
    c:SetHidden(false)

    durationMs = durationMs or T.PUDDLE_DURATION_MS
    expiresAt = GetGameTimeMilliseconds() + durationMs
    EVENT_MANAGER:UnregisterForUpdate(TIMER_NAME)
    EVENT_MANAGER:RegisterForUpdate(TIMER_NAME, 250, function()
        if GetGameTimeMilliseconds() >= expiresAt then
            P.Hide()
        end
    end)
end

function P.PlaceAtUnit(unitTag)
    local wx, wy, wz = T.GetUnitRaw(unitTag or "player")
    if not wx then return end
    local rx, ry, rz = T.WorldToRender(wx, wy, wz)
    if not rx then return end
    P.Place(rx, ry - 0.15, rz, T.PUDDLE_DURATION_MS)
end

local camProbe

local function EnsureCamProbe()
    if camProbe then return camProbe end
    if not WINDOW_MANAGER then return nil end
    local probe = WINDOW_MANAGER:CreateControl("TetsuCHH_CamProbe", GuiRoot, CT_CONTROL)
    if not probe or not probe.Create3DRenderSpace then return nil end
    probe:Create3DRenderSpace()
    camProbe = probe
    return probe
end

function P.GetLookAtGroundRender()
    local probe = EnsureCamProbe()
    if not probe then return nil end
    if Set3DRenderSpaceToCurrentCamera then
        pcall(Set3DRenderSpaceToCurrentCamera, probe:GetName())
    end
    if not probe.Get3DRenderSpaceOrigin or not probe.Get3DRenderSpaceForward then
        return nil
    end
    local ox, oy, oz = probe:Get3DRenderSpaceOrigin()
    local fx, fy, fz = probe:Get3DRenderSpaceForward()
    local wx, wy, wz = T.GetUnitRaw("player")
    if not ox or not fx or not wx then return nil end
    local prx, pry, prz = T.WorldToRender(wx, wy, wz)
    if not prx then return nil end

    -- Distance along the ground from the PLAYER, not the camera.
    -- Camera is behind the character, so a 28 m clamp from camera fell ~1 m short.
    local xz = math.sqrt((fx or 0) * fx + (fz or 0) * fz)
    if xz < 0.05 then
        return prx, pry, prz
    end
    local lx, lz = fx / xz, fz / xz

    local dist
    local camHeight = (oy or pry) - pry
    if fy and math.abs(fy) > 0.04 and camHeight > 0.3 then
        dist = math.abs(camHeight * xz / fy)
    else
        dist = 10
    end
    if dist < 1 then dist = 1 end
    if dist > 28 then dist = 28 end
    dist = dist * 0.90
    -- Sit on the floor, not at hip height (floating ring looks farther than it is).
    return prx + lx * dist, pry - 0.55, prz + lz * dist
end

function P.CacheAim()
    local rx, ry, rz = P.GetLookAtGroundRender()
    if rx then
        P.cachedAim = { rx, ry, rz }
    end
end

function P.PlaceAtCast()
    local rx, ry, rz
    if P.cachedAim then
        rx, ry, rz = P.cachedAim[1], P.cachedAim[2], P.cachedAim[3]
    else
        rx, ry, rz = P.GetLookAtGroundRender()
    end
    if rx then
        P.Place(rx, ry - 0.15, rz, T.PUDDLE_DURATION_MS)
        return
    end
    P.PlaceAtUnit("player")
end

function P.RefreshVisual()
    if control and not control:IsHidden() then
        ApplyVisual()
    end
end

function P.IsActive()
    return expiresAt > GetGameTimeMilliseconds()
end
