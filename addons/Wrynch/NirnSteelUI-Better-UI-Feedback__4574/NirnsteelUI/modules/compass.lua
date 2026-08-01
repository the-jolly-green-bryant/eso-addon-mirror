local ADDON_NAME = "NirnsteelUI"
local EVENT_NAMESPACE = ADDON_NAME .. "_Compass"

Nirnsteel_UI = Nirnsteel_UI or {}
local Nirnsteel_UI = Nirnsteel_UI
local CompassModule = {}
Nirnsteel_UI.Compass = CompassModule

local COMPASS_TEXTURE = "EsoUI/Art/Compass/compass.dds"

local KEYBOARD_HEIGHT = 39
local GAMEPAD_HEIGHT = 24
local KEYBOARD_END_CAP_WIDTH = 18
local GAMEPAD_END_CAP_WIDTH = 14

local KEYBOARD_CENTER_COORDS = { 0.78125, 1, 0, 0.609375 }
local KEYBOARD_LEFT_COORDS = { 0, 0.28125, 0, 0.609375 }
local KEYBOARD_RIGHT_COORDS = { 0.28125, 0, 0, 0.609375 }
local GAMEPAD_CENTER_COORDS = { 0.78125, 1, 0, 0.75 }
local GAMEPAD_LEFT_COORDS = { 0, 0.4375, 0, 0.75 }
local GAMEPAD_RIGHT_COORDS = { 0.4375, 0, 0, 0.75 }

local function IsModuleEnabled()
    return not Nirnsteel_UI.Settings or Nirnsteel_UI.Settings:IsCompassEnabled()
end

local function ShouldHideCompass()
    return Nirnsteel_UI.Settings and Nirnsteel_UI.Settings:ShouldHardcoreHideCompass()
end

local function ApplyTextureCoords(control, coords)
    if control and coords then
        control:SetTextureCoords(coords[1], coords[2], coords[3], coords[4])
    end
end

local function ApplyColor(control, r, g, b, a)
    if control then
        control:SetColor(r, g, b, a)
    end
end

local function SafeSetTexture(control, texture)
    if control then
        control:SetTexture(texture)
    end
end

local function SafeSetDimensions(control, width, height)
    if control then
        control:SetDimensions(width, height)
    end
end

local function SetOverlayHidden(center, name, hidden)
    local overlay = center and center:GetNamedChild(name)
    if overlay then
        overlay:SetHidden(hidden)
    end
end

function CompassModule:ApplyCardinalStyle()
    if COMPASS and COMPASS.SetCardinalDirections then
        local font = IsInGamepadPreferredMode() and "ZoFontGamepadBold34" or "ZoFontHeader3"
        COMPASS:SetCardinalDirections(font)
    end
end

function CompassModule:ApplyNirnsteelStyle()
    local frame = ZO_CompassFrame
    if not frame or not IsModuleEnabled() or ShouldHideCompass() then
        return
    end

    local center = frame:GetNamedChild("Center")
    local left = frame:GetNamedChild("Left")
    local right = frame:GetNamedChild("Right")
    local gamepadMode = IsInGamepadPreferredMode()
    local bossBarActive = COMPASS_FRAME and COMPASS_FRAME.GetBossBarActive and COMPASS_FRAME:GetBossBarActive()
    local height = gamepadMode and GAMEPAD_HEIGHT or KEYBOARD_HEIGHT
    local endCapWidth = gamepadMode and GAMEPAD_END_CAP_WIDTH or KEYBOARD_END_CAP_WIDTH

    SafeSetTexture(center, COMPASS_TEXTURE)
    SafeSetTexture(left, COMPASS_TEXTURE)
    SafeSetTexture(right, COMPASS_TEXTURE)

    if gamepadMode then
        ApplyTextureCoords(center, GAMEPAD_CENTER_COORDS)
        ApplyTextureCoords(left, GAMEPAD_LEFT_COORDS)
        ApplyTextureCoords(right, GAMEPAD_RIGHT_COORDS)
    else
        ApplyTextureCoords(center, KEYBOARD_CENTER_COORDS)
        ApplyTextureCoords(left, KEYBOARD_LEFT_COORDS)
        ApplyTextureCoords(right, KEYBOARD_RIGHT_COORDS)
    end

    SafeSetDimensions(left, endCapWidth, height)
    SafeSetDimensions(right, endCapWidth, height)
    if not bossBarActive then
        frame:SetHeight(height)
    end

    ApplyColor(center, 0.02, 0.018, 0.014, 0.88)
    ApplyColor(left, 0.72, 0.66, 0.48, 0.95)
    ApplyColor(right, 0.72, 0.66, 0.48, 0.95)

    SetOverlayHidden(center, "TopMungeOverlay", false)
    SetOverlayHidden(center, "BottomMungeOverlay", false)

    self:ApplyCardinalStyle()
end

function CompassModule:ApplyStockStyle()
    if COMPASS_FRAME and self.originalApplyStyle then
        self.restoringStockStyle = true
        self.originalApplyStyle(COMPASS_FRAME)
        self.restoringStockStyle = false
    end

    if COMPASS_FRAME and COMPASS_FRAME.UpdateWidth then
        COMPASS_FRAME:UpdateWidth()
    end
end

function CompassModule:Apply()
    if COMPASS_FRAME and COMPASS_FRAME.SetCompassHidden then
        COMPASS_FRAME:SetCompassHidden(ShouldHideCompass() == true)
    end

    if ShouldHideCompass() then
        return
    end

    if IsModuleEnabled() then
        self:ApplyNirnsteelStyle()
    else
        self:ApplyStockStyle()
    end
end

function CompassModule:InstallHooks()
    if self.hooksInstalled or not COMPASS_FRAME then
        return
    end

    local originalApplyStyle = COMPASS_FRAME.ApplyStyle
    if not originalApplyStyle then
        return
    end

    self.originalApplyStyle = originalApplyStyle
    COMPASS_FRAME.ApplyStyle = function(frame, ...)
        local result = originalApplyStyle(frame, ...)
        if not CompassModule.restoringStockStyle then
            CompassModule:Apply()
        end
        return result
    end

    self.hooksInstalled = true
end

function CompassModule:RegisterEvents()
    if self.eventsRegistered then
        return
    end

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED, function()
        self:InstallHooks()
        zo_callLater(function() self:Apply() end, 250)
    end)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_SCREEN_RESIZED, function()
        zo_callLater(function() self:Apply() end, 50)
    end)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function()
        zo_callLater(function() self:Apply() end, 50)
    end)

    self.eventsRegistered = true
end

function CompassModule:RefreshSettings()
    self:RegisterEvents()
    self:InstallHooks()
    self:Apply()
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_Loaded", EVENT_ADD_ON_LOADED)
    CompassModule:RefreshSettings()
    zo_callLater(function() CompassModule:RefreshSettings() end, 1000)
end

EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_Loaded", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
