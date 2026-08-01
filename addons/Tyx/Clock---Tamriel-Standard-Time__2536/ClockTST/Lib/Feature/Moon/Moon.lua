--[[--------------------------------------------
    Project:    Clock - Tamriel Standard Time
    Author:     Arne Rantzen (Tyx) & Phinix
    Created:    2020-01-22
    Updated:    2020-03-06
    License:    GPL-3.0
--------------------------------------------]]--

Clock_TST = Clock_TST or {}

local Moon = ZO_Object:Subclass()
local const = Clock_TST.CONSTANTS()
local i18n = Clock_TST.I18N().view
local settings

-- ----------------
-- Update
-- ----------------

--- Update the anchor of the moon controls
function Moon:UpdatePositions()
    local attribute = settings:GetMoonAttributes()

    local function UpdateControl(control, atr)
        local anchor = atr.anchor
        control:ClearAnchors()
        control:SetAnchor(
                anchor.point, _G[anchor.relativeTo], anchor.relativePoint,
                anchor.offsetX, anchor.offsetY
        )
        control:SetDimensions(atr.dimension.width, atr.dimension.height)
    end

    UpdateControl(self.control, attribute)
    UpdateControl(self.masser_background, attribute.masser)
    UpdateControl(self.secunda_background, attribute.secunda)
end

--- Function to remove the fragment from all scenes and delete the reference
function Moon:RemoveFragment()
    if Clock_TST.MOON_FRAGMENT then
        HUD_SCENE:RemoveFragment(Clock_TST.MOON_FRAGMENT)
        HUD_UI_SCENE:RemoveFragment(Clock_TST.MOON_FRAGMENT)
        WORLD_MAP_SCENE:RemoveFragment(Clock_TST.MOON_FRAGMENT)
        GAME_MENU_SCENE:RemoveFragment(Clock_TST.MOON_FRAGMENT)
        Clock_TST.MOON_FRAGMENT:SetHiddenForReason("Removed", true)
        Clock_TST.MOON_FRAGMENT = nil
    end
end

--- Update the visibility of the moon controls and manage their fragments
function Moon:UpdateVisibility()
    local isHidden = not settings:GetMoonIsVisible() or settings:GetHideInGroup() and IsUnitGrouped("player")
    Clock_TST.MOON_FRAGMENT:SetHiddenForReason("Settings", isHidden)

    if settings:GetMoonIsVisible() then
        local backgroundIsHidden = not settings:GetMoonHasBackground()
        self.masser_background:SetHidden(backgroundIsHidden)
        self.secunda_background:SetHidden(backgroundIsHidden)

        local namespace = self.control:GetName()

        EVENT_MANAGER:UnregisterForEvent(namespace, EVENT_PLAYER_COMBAT_STATE)
        if settings:GetOnlyShowOnMap() then
            HUD_SCENE:RemoveFragment(Clock_TST.MOON_FRAGMENT)
            HUD_UI_SCENE:RemoveFragment(Clock_TST.MOON_FRAGMENT)
            WORLD_MAP_SCENE:AddFragment(Clock_TST.MOON_FRAGMENT)
        else
            if settings:GetHideInFight() then
                EVENT_MANAGER:RegisterForEvent(namespace, EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
                    Clock_TST.MOON_FRAGMENT:SetHiddenForReason("Combat", inCombat)
                end)
            end
            HUD_SCENE:AddFragment(Clock_TST.MOON_FRAGMENT)
            HUD_UI_SCENE:AddFragment(Clock_TST.MOON_FRAGMENT)
            WORLD_MAP_SCENE:RemoveFragment(Clock_TST.MOON_FRAGMENT)
        end

        self:RegisterForUpdates()
    else
        self.UnregisterForUpdates()
    end
end

--- Update if mouse interactions are possible
function Moon:UpdateMouse()
    self.control:SetMovable(settings:GetMoonIsMovable())
    self.control:SetMouseEnabled(settings:GetMoonIsMouseEnabled() and settings:GetMoonIsVisible())
end

--- Update the background texture
function Moon:UpdateBackground()
    self.texture = const.UI.BACKGROUNDS.moon[settings:GetMoonBackground()]
    self.masser_background:SetTexture(self.texture.path .. self.texture.background)
    self.masser_background:SetColor(settings:GetMoonBackgroundColour())
    self.secunda_background:SetTexture(self.texture.path .. self.texture.background)
    self.secunda_background:SetColor(settings:GetMoonBackgroundColour())
end

--- Update the texture of the moons to fit the phases
--@param currentPhaseName is the name of the current phase in English
function Moon:UpdateTexture(currentPhaseName)
    if currentPhaseName == "new" then
        self.masser:SetHidden(true)
        self.secunda:SetHidden(true)
    else
        local texturesMasser = const.UI.MOONS.masser[settings:GetMoonTextureKeyMasser()]
        for name, texture in pairs(texturesMasser) do
            if currentPhaseName == name then
                self.masser:SetHidden(false)
                self.masser:SetTexture(texturesMasser.path .. texture)
                self.masser:SetColor(1, 1, 1, settings:GetMoonAlpha())
            end
        end
        local texturesSecunda = const.UI.MOONS.secunda[settings:GetMoonTextureKeySecunda()]
        for name, texture in pairs(texturesSecunda) do
            if currentPhaseName == name then
                self.secunda:SetHidden(false)
                self.secunda:SetTexture(texturesSecunda.path .. texture)
                self.secunda:SetColor(1, 1, 1, settings:GetMoonAlpha())
            end
        end
    end
    if settings:GetMoonHasBackground() then
        self:UpdateBackground()
    end
end

--- Update the tooltip information
--@param moon object { ... }
function Moon:UpdateTooltip(moon)
    local tooltip_format = i18n.moon.tooltip
    local days
    if moon.isFull then
        local hours = math.floor(moon.secondsUntilNextPhase / 3600)
        days = math.floor(moon.daysUntilNextPhase)
        self.tooltip = zo_strformat(tooltip_format.full, hours)
    else
        local percentage = math.floor(moon.percentageOfFullMoon * 100)
        local hours = math.floor(moon.secondsUntilFullMoon / 3600)
        days = math.floor(moon.daysUntilFullMoon)
        if moon.isWaxing then
            self.tooltip = zo_strformat(tooltip_format.isWaxing, percentage, hours)
        else
            self.tooltip = zo_strformat(tooltip_format.isWaning, percentage, hours)
        end
    end
    self.tooltip = self.tooltip .. zo_strformat(tooltip_format.duration, days)
end

--- Update the moon texture and tooltip
-- This function is meant to be given to the LibClockTST.
--@param moon object { ... }
function Moon:UpdateMoon(moon)
    self:UpdateTexture(moon.currentPhaseName)

    if settings:GetMoonHasTooltip() then
        self:UpdateTooltip(moon)
    end
end

-- ----------------
-- Register
-- ----------------

--- Register the moon updates with the LibClockTST
function Moon:RegisterForUpdates()
    local lib = LibClockTST:Instance()
    lib:RegisterForMoon(const.NAME, function(...)
        self:UpdateMoon(...)
    end)
end

--- Stop further updates from the LibClockTST
function Moon.UnregisterForUpdates()
    local lib = LibClockTST:Instance()
    lib:CancelSubscriptionForMoon(const.NAME)
end

-- ----------------
-- Start
-- ----------------

--- Setup a tooltip to be shown if hovering over the moon control
function Moon:SetupTooltip()
    self.control:SetHandler("OnMouseEnter", function(control)
        if settings:GetMoonHasTooltip() then
            InitializeTooltip(InformationTooltip, control, TOP, 0, 0)
            SetTooltipText(InformationTooltip, self.tooltip or Clock_TST.I18N().error.library)
        end

        -- Hover
        if settings:GetMoonHighlightWhenHover() then
            if self.texture.hover then
                self.masser_background:SetTexture(self.texture.path .. self.texture.hover)
                self.secunda_background:SetTexture(self.texture.path .. self.texture.hover)
            end
            self.masser_background:SetColor(settings:GetMoonBackgroundHoverColour())
            self.secunda_background:SetColor(settings:GetMoonBackgroundHoverColour())
        end

        if settings:GetMoonScaleWhenHover() then
            local scale = settings:GetMoonScale()
            control:SetScale(scale * settings:GetScaleFactor())
        end
    end)
    self.control:SetHandler("OnMouseExit", function(control)
        ClearTooltip(InformationTooltip)

        -- Hover
        self:UpdateBackground()

        control:SetScale(settings:GetMoonScale())
    end)
end

--- Setup the movement of the moon control and link the time control to it if set
function Moon:SetupMovement()
    local function LeftClick(control)
        local offsetX, offsetY = control:GetLeft(), control:GetTop()

        if settings:GetTimeAndMoonAreLinked() then
            local timeOffsetX, timeOffsetY = settings:GetTimeOffset()
            local oldOffsetX, oldOffsetY = settings:GetMoonOffset()
            local newTimeOffsetX = timeOffsetX + offsetX - oldOffsetX
            local newTimeOffsetY = timeOffsetY + offsetY - oldOffsetY
            settings:SetTimeOffset(newTimeOffsetX, newTimeOffsetY)
            Clock_TST.time:UpdatePositions()
        end

        settings:SetMoonOffset(offsetX, offsetY)
        self:UpdatePositions()
    end

    --- Create menu if user clicks right
    -- control is the main control
    local function RightClick(control)
        local function Setup(isEnabled, func, text)
            if isEnabled then
                AddMenuItem("[X]\t" .. text,
                        function()
                            func(false)
                        end)
            else
                AddMenuItem("[ ]\t" .. text,
                        function()
                            func(true)
                        end)
            end
        end
        ClearMenu()
        local baseScale = const.Settings.attributes.DEFAULTS.moon.scale
        local scalePercentage = math.floor(settings:GetMoonScale() * 100 / baseScale)
        if scalePercentage ~= 100 then
            AddMenuItem(zo_strformat("[<<1>>%]\t<<2>>", scalePercentage, i18n.core.menu.scale), function()
                settings:SetMoonScale(baseScale)
                self:SetupScale()
            end)
        end
        Setup(settings:GetMoonIsMovable(), function(value)
            settings:SetMoonIsMovable(value)
            self:UpdateMouse()
        end, i18n.core.menu.movable)
        Setup(settings:GetTimeAndMoonAreLinked(), function(value)
            settings:SetTimeAndMoonAreLinked(value)
        end, i18n.core.menu.link)
        Setup(settings:GetMoonHasTooltip(), function(value)
            settings:SetMoonHasTooltip(value)
        end, i18n.core.menu.tooltip)
        Setup(settings:GetMoonHasBackground(), function(value)
            settings:SetMoonHasBackground(value)
            self:UpdateVisibility()
        end, i18n.core.menu.background)
        AddMenuItem( i18n.core.menu.open, function() LibAddonMenu2:OpenToPanel(CLOCK_TST_MENU) end)
        ShowMenu(control)
    end

    self.control:SetHandler("OnMouseDown", function(control, button)
        if button == 2 then
            control:SetMovable(false)
        end
    end)

    self.control:SetHandler("OnMouseUp", function(control, button)
        if button == 2 then
            RightClick(control)
            self:UpdateMouse()
        else
            LeftClick(control)
        end
    end)
end

--- Setup a mouse wheel interaction to change the size of the moon
function Moon:SetupScale()
    self.control:SetScale(settings:GetMoonScale())
    self.control:SetHandler("OnMouseWheel", function(_, delta)
        --[[
        local factor_masser = settings:GetScaleFactor() * delta
        local factor_secunda = factor_masser * .625 -- size of secunda / size of masser

        local function ChangeDimension(dimension, default, factor)
            dimension.width = math.max(default.width * .1, dimension.width + factor)
            dimension.height = math.max(default.height * .1, dimension.height + factor)
            return dimension
        end

        local default = const.Settings.attributes.DEFAULTS.moon
        local moon_dimension = settings:GetMoonAttributes().dimension
        local masser_dimension = settings:GetMoonMasserAttributes().dimension
        local secunda_dimension = settings:GetMoonSecundaAttributes().dimension

        masser_dimension = ChangeDimension(masser_dimension, default.masser.dimension, factor_masser)

        secunda_dimension = ChangeDimension(secunda_dimension, default.secunda.dimension, factor_secunda)
        moon_dimension.width = masser_dimension.width + secunda_dimension.width * .5
        moon_dimension.height = masser_dimension.height * .5 + secunda_dimension.height

        self:UpdatePositions()
        ]]--
        local scale = settings:GetMoonScale()
        scale = scale + delta * 0.02
        self.control:SetScale(scale)
        settings:SetMoonScale(scale)
    end)
end

--- Setup the controls and the fragment
--@param control of the TopLevelControl
function Moon:SetupControls(control)
    self.control = control
    self.masser = GetControl(control, "Masser")
    self.masser_background = GetControl(control, "Masser_Background")
    self.secunda = GetControl(control, "Secunda")
    self.secunda_background = GetControl(control, "Secunda_Background")

    Clock_TST.MOON_FRAGMENT = ZO_HUDFadeSceneFragment:New(control)
    Clock_TST.MOON_FRAGMENT:Hide()
end

-- ----------------
-- Start
-- ----------------

--- Create a new Moon object
--@param ... control of the moon object
function Moon:New(...)
    local container = ZO_Object.New(self)
    container:SetupControls(...)
    return container
end

--- function to reload all values from the settings
function Clock_TST:SetupMoon()
    settings = self.settings
    if Clock_TST.moon then
        Clock_TST.moon:RemoveFragment()
        Clock_TST.moon = nil
    end

    self.moon = Moon:New(Clock_TST_Moon)

    self.moon:SetupTooltip()
    self.moon:SetupMovement()
    self.moon:SetupScale()

    self.moon:UpdatePositions()
    self.moon:UpdateVisibility()
    self.moon:UpdateMouse()
end
