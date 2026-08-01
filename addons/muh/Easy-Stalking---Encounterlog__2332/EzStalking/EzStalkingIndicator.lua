if EzStalking == nil then EzStalking = { } end
local Ez = _G['EzStalking']
local L = Ez:GetLocale()

Ez.UI = { }

local function set_position()
    local x, y = Ez.settings.indicator.position.x, Ez.settings.indicator.position.y
    Ez.UI.indicator:ClearAnchors()
    Ez.UI.indicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

local function save_position()
    Ez.settings.indicator.position.x = Ez.UI.indicator:GetLeft()
    Ez.settings.indicator.position.y = Ez.UI.indicator:GetTop()
end

function Ez.UI.lock(value)
    Ez.settings.indicator.locked = value
    Ez.UI.update_color()
    Ez.UI.toggle_fg_color()
    Ez.UI.indicator:SetMouseEnabled(not value)
    Ez.UI.indicator:SetMovable(not value)
end

function Ez.UI.update_color()
    local r, g, b = unpack(Ez.settings.indicator.color)
    Ez.UI.indicator_fg:SetCenterColor(r, g, b, 0.7)
    Ez.UI.indicator_fg:SetEdgeColor(r, g, b, 0.37)
end

function Ez.UI.enable_indicator(value)
    Ez.UI.hide_indicator(not value)
    Ez.UI.toggle_fg_color()
    if value then
        SCENE_MANAGER:GetScene("hud"):AddFragment(Ez.UI.indicator_fragment)
        SCENE_MANAGER:GetScene("hudui"):AddFragment(Ez.UI.indicator_fragment)
    else
        SCENE_MANAGER:GetScene("hud"):RemoveFragment(Ez.UI.indicator_fragment)
        SCENE_MANAGER:GetScene("hudui"):RemoveFragment(Ez.UI.indicator_fragment)
    end
end

function Ez.UI.hide_indicator(value)
    Ez.UI.indicator_bg:SetHidden(value)
    Ez.UI.indicator_fg:SetHidden(value)
    Ez.UI.indicator:SetHidden(value)
end

function Ez.UI.toggle_fg_color()
    if (not Ez.settings.indicator.locked or IsEncounterLogEnabled()) then
        local color = Ez.settings.indicator.locked and Ez.settings.indicator.color or Ez.settings.indicator.unlocked_color
        Ez.UI.indicator_fg:SetCenterColor(unpack(color))
    else
        Ez.UI.indicator_fg:SetCenterColor(0, 0, 0, 0)
    end
end

function Ez.UI:initialize()
    local dimensions = 17

    local _indicator = WINDOW_MANAGER:CreateTopLevelWindow("EZS_indicator")
    _indicator:SetClampedToScreen(true)
    _indicator:SetDimensions(dimensions, dimensions)
    _indicator:ClearAnchors()
    _indicator:SetMouseEnabled(false)
    _indicator:SetMovable(false)
    --_indicator:SetHidden(false)
    _indicator:SetDimensionConstraints(dimensions, dimensions, dimensions, dimensions)
    _indicator:SetHandler("OnMoveStop", function(...) save_position() end)

    local _indicator_bg = WINDOW_MANAGER:CreateControl("EZS_backdrop", _indicator, CT_BACKDROP)
    _indicator_bg:SetAnchorFill()
    _indicator_bg:SetCenterColor(0, 0, 0, 0.25)
    _indicator_bg:SetEdgeColor(0, 0, 0, 0.25)
    _indicator_bg:SetEdgeTexture(nil, 1, 1, 0, 0)
    --_indicator_bg:SetHidden(false)

    local _indicator_fg = WINDOW_MANAGER:CreateControl("EZS_foreground", _indicator, CT_BACKDROP)
    _indicator_fg:SetAnchor(CENTER, _indicator, CENTER, 0, 0)
    _indicator_fg:SetDimensions(dimensions, dimensions)
    _indicator_fg:SetCenterColor(1, 0, 0, 0.7)
    _indicator_fg:SetEdgeColor(1, 0, 0, 0.3)
    _indicator_fg:SetEdgeTexture(nil, 1, 1, 0, 0)
    --_indicator_fg:SetHidden(false)

    Ez.UI.indicator = _indicator
    Ez.UI.indicator_bg = _indicator_bg
    Ez.UI.indicator_fg = _indicator_fg
    Ez.UI.indicator_fragment = ZO_HUDFadeSceneFragment:New(_indicator)
    Ez.UI.enable_indicator(true)
    set_position()

    Ez.UI.enable_indicator(Ez.settings.indicator.enabled)
    Ez.UI.lock(Ez.settings.indicator.locked)
end