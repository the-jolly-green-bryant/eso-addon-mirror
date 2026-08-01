local ADDON_NAME = "FlapRider"
local IDLE_INTERVAL_MS = 200
local UPDATE_INTERVAL_MS = 20
local OFFSET_DISTANCE = 220
local WING_HEIGHT = 200
local FLAP_SPEED = 0.01
local FLAP_ANGLE = math.pi / 4

local getUnitRawWorldPosition = GetUnitRawWorldPosition
local worldPositionToGuiRender3DPosition = WorldPositionToGuiRender3DPosition

-- ==================================================================================================
-- Global addon table (initialized in Settings.lua)
FlapRider = FlapRider or {}
local FR = FlapRider

-- ==================================================================================================
-- Local functions

local worldItemIndex = 0
local function CreateWorldItem(texturePath, size)
    worldItemIndex = worldItemIndex + 1
    local id = "FlapRiderWorldItem" .. worldItemIndex
    size = size or 1

    local control = WINDOW_MANAGER:CreateControl(id, FlapRiderRoot, CT_TEXTURE)
    control:SetDimensions(GuiRoot:GetDimensions())
    control:SetAnchor(CENTER, GuiRoot, CENTER)
    control:SetPixelRoundingEnabled(false)
    control:SetTextureCoords(0, 1, 0, 1)
    control:Create3DRenderSpace()
    control:Set3DRenderSpaceOrigin(0, 0, 0)
    control:Set3DRenderSpaceUsesDepthBuffer(true)
    control:Set3DRenderSpaceOrientation(math.pi / 2, 0, 0)
    control:Set3DLocalDimensions(size, size)
    control:SetTexture(texturePath)
    control:SetColor(1, 1, 1, 1)
    control:SetHidden(false)

    local item = {
        control = control
     }

    item.SetPosition = function(self, x, y, z)
        self.worldX = x
        self.worldY = y
        self.worldZ = z
        local gx, gy, gz = worldPositionToGuiRender3DPosition(x, y, z)
        self.control:Set3DRenderSpaceOrigin(gx, gy, gz)
    end

    item.SetSize = function(self, s)
        self.control:Set3DLocalDimensions(s, s)
    end

    item.SetTexture = function(self, path)
        self.control:SetTexture(path)
    end

    item.SetHidden = function(self, hidden)
        self.control:SetHidden(hidden)
    end

    item.Dispose = function(self)
        self.control:SetHidden(true)
        self.control:Destroy3DRenderSpace()
        self.control = nil
    end

    return item
end

local function CreateWing(texture, tint)
    local item = CreateWorldItem(texture, 4)
    local control = item.control
    control:SetResizeToFitFile(true)
    control:SetTextureReleaseOption(RELEASE_TEXTURE_AT_ZERO_REFERENCES)
    control:SetTextureCoords(1, 0, 0, 1)
    control:SetColor(unpack(tint))
    return item
end

local function TrackMovement()
    local _, px, py, pz = getUnitRawWorldPosition("player")
    if FR.lastPx and FR.lastPz then
        local dx = px - FR.lastPx
        local dy = py - (FR.lastPy or py)
        local dz = pz - FR.lastPz
        local horizontalDist = math.sqrt(dx * dx + dz * dz)

        if horizontalDist > 5 then
            FR.characterHeading = math.atan2(dx, dz)
            FR.characterPitch = math.atan2(dy, horizontalDist)
            local FLAP_CYCLE = 2 * math.pi / 0.01
            FR.distanceTraveled = ((FR.distanceTraveled or 0) + horizontalDist) % FLAP_CYCLE
            FR.lastPx = px
            FR.lastPy = py
            FR.lastPz = pz
        end
    else
        FR.lastPx = px
        FR.lastPy = py
        FR.lastPz = pz
    end
end

local function UpdateWing(item, isRight, heading, pitch, flapAngle)
    local side = isRight and 1 or -1
    local _, px, py, pz = getUnitRawWorldPosition("player")
    local cosPitch = math.cos(pitch)
    local sinPitch = math.sin(pitch)
    local upX = math.sin(heading) * cosPitch
    local upY = sinPitch
    local upZ = math.cos(heading) * cosPitch

    local sideX = math.cos(heading)
    local sideZ = -math.sin(heading)

    local cosFlap = math.cos(flapAngle)
    local sinFlap = math.sin(flapAngle)

    local rightX = side * sideX * cosFlap
    local rightY = sinFlap
    local rightZ = side * sideZ * cosFlap

    local fwdX = side * (upY * rightZ - upZ * rightY)
    local fwdY = side * (upZ * rightX - upX * rightZ)
    local fwdZ = side * (upX * rightY - upY * rightX)

    item:SetPosition(
        px + side * sideX * OFFSET_DISTANCE * cosFlap, py + WING_HEIGHT + OFFSET_DISTANCE * sinFlap, pz + side * sideZ * OFFSET_DISTANCE * cosFlap)

    item.control:Set3DRenderSpaceForward(fwdX, fwdY, fwdZ)
    item.control:Set3DRenderSpaceRight(rightX, rightY, rightZ)
    item.control:Set3DRenderSpaceUp(upX, upY, upZ)
end

local function CreateWings()
    local wing = FR.savedVars.wing
    FR.wingRight = CreateWing(wing.texture, wing.tint)
    FR.wingLeft = CreateWing(wing.texture, wing.tint)
end

local function RemoveWings()
    if FR.wingRight then
        FR.wingRight:Dispose()
        FR.wingRight = nil
    end
    if FR.wingLeft then
        FR.wingLeft:Dispose()
        FR.wingLeft = nil
    end
end

local function StopTracking()
    EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_Update")
end

local function StopIdleTracking()
    EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_Idle")
end

local function StartIdleTracking()
    EVENT_MANAGER:RegisterForUpdate(
        ADDON_NAME .. "_Idle", IDLE_INTERVAL_MS, function()
            TrackMovement()
        end)
end

local function UpdatePosition()
    TrackMovement()

    if not FR.characterHeading then
        return
    end

    if not FR.wingRight and FR.savedVars.showWings then
        CreateWings()
    end

    if not FR.wingRight then
        return
    end

    local heading = FR.characterHeading
    local pitch = FR.characterPitch or 0
    local flapAngle = math.sin((FR.distanceTraveled or 0) * FLAP_SPEED) * FLAP_ANGLE

    UpdateWing(FR.wingRight, true, heading, pitch, flapAngle)
    UpdateWing(FR.wingLeft, false, heading, pitch, flapAngle)
end

local function StartTracking()
    EVENT_MANAGER:RegisterForUpdate(
        ADDON_NAME .. "_Update", UPDATE_INTERVAL_MS, function()
            UpdatePosition()
        end)
end

local function OnMountStateChanged(_, isMounted)
    if isMounted then
        StopIdleTracking()
        local _, px, py, pz = getUnitRawWorldPosition("player")
        FR.lastPx = px
        FR.lastPy = py
        FR.lastPz = pz
        FR.characterPitch = 0
        FR.distanceTraveled = 0
        if FR.savedVars.showWings and FR.characterHeading then
            CreateWings()
        end
        StartTracking()
    else
        StopTracking()
        RemoveWings()
        StartIdleTracking()
    end
end

local function Init()
    if FR.initialized then
        return
    end
    FR.initialized = true

    local fragment = ZO_HUDFadeSceneFragment:New(FlapRiderRoot)
    SCENE_MANAGER:GetScene("hud"):AddFragment(fragment)
    SCENE_MANAGER:GetScene("hudui"):AddFragment(fragment)

    SLASH_COMMANDS["/flaprider"] = function(args)
        local cmd = string.lower(args or "")
        if cmd == "config" then
            FlapRider.ToggleSettings()
        else
            FR:ToggleWings()
        end
    end

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_MOUNTED_STATE_CHANGED, OnMountStateChanged)

    StartIdleTracking()
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    CALLBACK_MANAGER:FireCallbacks("OnFlapRiderInitializing")
    Init()
end

-- ==================================================================================================
-- Keybind
local hotkeyDebouncer = FlapRiderCommon.Debouncer:New(
    function(count)
        CALLBACK_MANAGER:FireCallbacks("FlapRider_Hotkey", count)
    end, 300)

function FlapRider_OnKeybind()
    hotkeyDebouncer:Invoke()
end

-- ==================================================================================================
-- FlapRider public methods

function FR:UpdateWingAppearance()
    local wing = self.savedVars.wing
    for _, item in ipairs(
        {
            self.wingRight,
            self.wingLeft
         }) do
        if item then
            item:SetTexture(wing.texture)
            item.control:SetColor(unpack(wing.tint))
        end
    end
end

function FR:ToggleWings()
    self.savedVars.showWings = not self.savedVars.showWings
    if self.savedVars.showWings and IsMounted("player") then
        CreateWings()
    else
        RemoveWings()
    end
end

-- ==================================================================================================
-- Bootstrap
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
