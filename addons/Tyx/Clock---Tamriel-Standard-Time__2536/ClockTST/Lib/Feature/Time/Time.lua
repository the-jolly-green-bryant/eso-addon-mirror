--[[--------------------------------------------
    Project:    Clock - Tamriel Standard Time
    Author:     Arne Rantzen (Tyx) & Phinix
    Created:    2020-01-22
    Updated:    2020-03-06
    License:    GPL-3.0
--------------------------------------------]]--

Clock_TST = Clock_TST or {}

local Time = ZO_Object:Subclass()
local const = Clock_TST.CONSTANTS()
local i18n = Clock_TST.I18N().view
local settings

-- ----------------
-- Update
-- ----------------

--- Update the Time anchor
function Time:UpdatePositions()
    local attribute = settings:GetTimeAttributes()

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
end

--- Function to remove the fragment from all scenes and delete the reference
function Time:RemoveFragment()
    if Clock_TST.TIME_FRAGMENT then
        HUD_SCENE:RemoveFragment(Clock_TST.TIME_FRAGMENT)
        HUD_UI_SCENE:RemoveFragment(Clock_TST.TIME_FRAGMENT)
        WORLD_MAP_SCENE:RemoveFragment(Clock_TST.TIME_FRAGMENT)
        GAME_MENU_SCENE:RemoveFragment(Clock_TST.TIME_FRAGMENT)
        Clock_TST.TIME_FRAGMENT:SetHiddenForReason("Removed", true)
        Clock_TST.TIME_FRAGMENT = nil
    end
end

--- Update the visibility and fragment visibility of the Time object
function Time:UpdateVisibility()
    local isHidden = not settings:GetTimeIsVisible() or settings:GetHideInGroup() and IsUnitGrouped("player")
    Clock_TST.TIME_FRAGMENT:SetHiddenForReason("Settings", isHidden)

    if settings:GetTimeIsVisible() then
        local backgroundIsHidden = not settings:GetTimeHasBackground()
        self.background:SetHidden(backgroundIsHidden)

        local namespace = self.control:GetName()
        EVENT_MANAGER:UnregisterForEvent(namespace, EVENT_PLAYER_COMBAT_STATE)
        if settings:GetOnlyShowOnMap() then
            HUD_SCENE:RemoveFragment(Clock_TST.TIME_FRAGMENT)
            HUD_UI_SCENE:RemoveFragment(Clock_TST.TIME_FRAGMENT)
            WORLD_MAP_SCENE:AddFragment(Clock_TST.TIME_FRAGMENT)
        else
            if settings:GetHideInFight() then
                EVENT_MANAGER:RegisterForEvent(namespace, EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
                    Clock_TST.TIME_FRAGMENT:SetHiddenForReason("Combat", inCombat)
                end)
            end
            HUD_SCENE:AddFragment(Clock_TST.TIME_FRAGMENT)
            HUD_UI_SCENE:AddFragment(Clock_TST.TIME_FRAGMENT)
            WORLD_MAP_SCENE:RemoveFragment(Clock_TST.TIME_FRAGMENT)
        end

        self:RegisterForUpdates()
    else
        self.UnregisterForUpdates()
    end
end

--- Update if the object is interactable with the mouse
function Time:UpdateMouse()
    self.control:SetMovable(settings:GetTimeIsMovable())
    self.control:SetMouseEnabled(settings:GetTimeIsMouseEnabled() and settings:GetTimeIsVisible())
end

--- Update the background texture and alpha value
function Time:UpdateBackground()
    self.texture = const.UI.BACKGROUNDS.time[settings:GetTimeBackground()]
    self.background:SetTexture(self.texture.path .. self.texture.background)
    self.background:SetColor(settings:GetTimeBackgroundColour())
end

--- Update the dimension and offset of the control
-- Only if the sizeHasUpdated variable is true!
function Time:UpdateSize()
    if not self.sizeHasUpdated then
        return
    end
    self.sizeHasUpdated = false

    local baseLength = 35
    local baseSize = const.Settings.styles.DEFAULTS.time.size
    local size = settings:GetTimeSize()
    local length = Clock_TST.GetLargestLine(self.label:GetText())
    local lines = settings:GetTimeLineCount()

    local function CreateDimension(dimension, baseDimension, offset)
        dimension.height = size / baseSize * math.max(1, lines * 0.75) * baseDimension.height + offset.y
        dimension.width = length / baseLength * size / baseSize * baseDimension.width + offset.x
    end

    local function CreateOffset(x, y, width, height, dimension)
        local offsetX = x + (width - dimension.width) * .1
        local offsetY = y + (height - dimension.height) * .1
        return offsetX, offsetY
    end
    local width, height = settings:GetTimeDimension().width, settings:GetTimeDimension().height
    CreateDimension(
            settings:GetTimeDimension(),
            const.Settings.attributes.DEFAULTS.time.dimension,
            settings:GetTimeBackgroundOffset()
    )
    local x, y = settings:GetTimeOffset()
    settings:SetTimeOffset(
            CreateOffset(
                    x, y,
                    width, height,
                    settings:GetTimeDimension()
            )
    )


    self:UpdatePositions()
end

--- Update the Style of the label
function Time:UpdateStyle()
    local size = settings:GetTimeSize()
    local font = const.UI.FONTS[settings:GetTimeFont()]
    local style = settings:GetTimeStyle()
    local look = zo_strformat("<<1>>|<<2>>|<<3>>", font, size, style)

    self.label:SetFont(look)
    self.label:SetColor(settings:GetTimeColour())
end

--- Update the content of the label
function Time:UpdateLabel()
    local format = settings:GetTimeFormat()

    if settings:GetTimeHasRealDate() then
        local rDate = self.replacement.date.real
        local rTime = self.replacement.time.real
        format = format:gsub("%%x", rDate.x)
        format = format:gsub("%%A", rDate.A)
        format = format:gsub("%%a", rDate.a)
        format = format:gsub("%%B", rDate.B)
        format = format:gsub("%%b", rDate.b)
        format = format:gsub("%%D", rDate.D)
        format = format:gsub("%%d", rDate.d)
        format = format:gsub("%%m", rDate.m)
        format = format:gsub("%%w", rDate.w)
        format = format:gsub("%%Y", rDate.Y)
        format = format:gsub("%%y", rDate.y)
        format = format:gsub("%%X", rTime.X)
        format = format:gsub("%%H", rTime.H)
        format = format:gsub("%%I", rTime.I)
        format = format:gsub("%%M", rTime.M)
        format = format:gsub("%%S", rTime.S)
        format = format:gsub("%%p", rTime.p)
    end

    if settings:GetTimeHasFakeLoreDate() then
        local lDate = self.replacement.date.fake
		local lTime = self.replacement.time.fake
        format = format:gsub("$x", lDate.x)
        format = format:gsub("$A", lDate.A)
        format = format:gsub("$a", lDate.a)
        format = format:gsub("$B", lDate.B)
        format = format:gsub("$b", lDate.b)
        format = format:gsub("$D", lDate.D)
        format = format:gsub("$d", lDate.d)
        format = format:gsub("$m", lDate.m)
        format = format:gsub("$w", lDate.w)
        format = format:gsub("$Y", lDate.Y)
        format = format:gsub("$y", lDate.y)
        format = format:gsub("$X", lTime.X)
        format = format:gsub("$H", lTime.H)
        format = format:gsub("$I", lTime.I)
        format = format:gsub("$M", lTime.M)
        format = format:gsub("$S", lTime.S)
        format = format:gsub("$p", lTime.p)
    end

    if settings:GetTimeHasLoreDate() or settings:GetTimeHasFakeLoreDate() then
        local lDate = self.replacement.date.lore
        local lTime = self.replacement.time.lore
        format = format:gsub("#x", lDate.x)
        format = format:gsub("#A", lDate.A)
        format = format:gsub("#a", lDate.a)
        format = format:gsub("#B", lDate.B)
        format = format:gsub("#b", lDate.b)
        format = format:gsub("#D", lDate.D)
        format = format:gsub("#d", lDate.d)
        format = format:gsub("#m", lDate.m)
        format = format:gsub("#w", lDate.w)
        format = format:gsub("#Y", lDate.Y)
        format = format:gsub("#y", lDate.y)
        format = format:gsub("#X", lTime.X)
        format = format:gsub("#H", lTime.H)
        format = format:gsub("#I", lTime.I)
        format = format:gsub("#M", lTime.M)
        format = format:gsub("#S", lTime.S)
        format = format:gsub("#p", lTime.p)
    end

    self.label:SetText(format)
end

--- Update the content of the tooltip
function Time:UpdateTooltip()
    local loreTime = self.replacement.time.lore
    local loreDate = self.replacement.date.lore
    self.tooltip = zo_strformat("<<1>>, <<2>>. <<t:3>> <<4>> <<5>> <<6>>\n",
            loreDate.A, loreDate.D, loreDate.B, loreDate.E, loreDate.Y, loreTime.X)

    local realTime = self.replacement.time.real
    local realDate = self.replacement.date.real
    self.tooltip = self.tooltip .. zo_strformat("<<1>>, <<2>>. <<t:3>> <<4>> <<5>>",
            realDate.A, realDate.D, realDate.B, realDate.Y, realTime.X)
end

--- Add a zero in front of a number if smaller than 10
--@param value is the number
local function AddZero(value, var)
    local number = tonumber(value)
	
	if (settings:GetTimeAddZero(var)) then
		if number < 10 then
			return "0" .. value
		end
	end
    return number
end

--- Create the values for the time to be exchanged with their respective chars
--@param loreTime is the lore time object with { hour = h, minute = m, second = s }
function Time:CreateTimeReplacements(loreTime)
    local function I(hour)
        local h = tonumber(hour)
        if settings:GetTimeHasUSFormat() and h > 12 then
            return h - 12
        elseif settings:GetTimeHasUSFormat() and not settings:GetTimeHasJapFormat() and h == 0 then
            return 12
        end
        return h
    end
    local function p(hour)
        local h = tonumber(hour)
		local ampm = settings:GetMinimalAMPM()

        if h < 12 or (settings:GetTimeHasJapFormat() and h < 13) then
            return (ampm) and i18n.time.amM or i18n.time.am
        else
            return (ampm) and i18n.time.pmM or i18n.time.pm
        end
    end
    local tFormat = TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR
    if settings:GetTimeHasUSFormat() then
        tFormat = TIME_FORMAT_PRECISION_TWELVE_HOUR
    end
    local h, m, s = GetTimeString():match("(%d+):(%d+):(%d+)")
    self.replacement.time.real = {
        X = ZO_FormatTime(GetSecondsSinceMidnight(), TIME_FORMAT_STYLE_CLOCK_TIME, tFormat), -- GetTimeString(),
        H = AddZero(I(h), "hour"),
        I = AddZero(I(h), "hour"),
        M = m,
        S = s,
        p = p(h)
    }
    local lh, lm, ls = loreTime.hour, loreTime.minute, loreTime.second
    -- zo_strformat("<<1>>:<<2>>:<<3>>", lh, lm, ls)
    self.replacement.time.lore = {
        X = ZO_FormatTime(lh * 3600 + lm * 60 + ls, TIME_FORMAT_STYLE_CLOCK_TIME, tFormat),
        H = AddZero(I(lh), "hour"),
        I = AddZero(I(loreTime.hour), "hour"),
        M = AddZero(lm, "min"),
        S = AddZero(ls, "sec"),
        p = p(lh)
    }
	self.replacement.time.fake = {
		X = ZO_FormatTime(lh * 3600 + lm * 60 + ls, TIME_FORMAT_STYLE_CLOCK_TIME, tFormat),
		H = AddZero(I(lh), "hour"),
		I = AddZero(I(loreTime.hour), "hour"),
		M = AddZero(lm, "min"),
		S = AddZero(ls, "sec"),
		p = p(lh)
	}
end

--- Create the values for the date to be exchanged with their respective chars
--@param loreDate is the lore date object with { day = d, weekDay = w, month = m, year = y }
function Time:CreateDateReplacements(loreDate)
    local realDateString = tostring(GetDate())
    local ry, rm, rd = realDateString:match("(%d%d%d%d)(%d%d)(%d%d)")
    rd, rm, ry = tonumber(rd), tonumber(rm), tonumber(ry)
    local rw = LibClockTST.GetWeekDay({ year = ry, month = rm, day = rd }) -- modified library method of deriving time/date values from epoch time stamp (Phinix)

    self.replacement.date.real = {
        x = GetDateStringFromTimestamp(GetTimeStamp()),
        A = i18n.date.real.week[rw],
        a = i18n.date.real.week[rw]:sub(1, 3),
        B = i18n.date.real.months[rm],
        b = i18n.date.real.months[rm]:sub(1, 3),
		D = zo_strformat("<<i:1>>", AddZero(rd, "day")),
        d = AddZero(rd, "day"),
        m = AddZero(rm, "month"),
        w = rw,
        Y = ry,
        y = ry - 2000
}

    self.replacement.date.fake = {
        x = zo_strformat(
                "<<1>>.<<2>>.<<3>><<4>>",
                rd, rm, i18n.date.lore.year, loreDate.year
        ),
        A = i18n.date.lore.week[rw],
        a = i18n.date.lore.week[rw]:sub(1, 3),
        B = i18n.date.lore.months[rm],
        b = i18n.date.lore.months[rm]:sub(1, 3),
		D = zo_strformat("<<i:1>>", AddZero(rd, "day")),
        d = AddZero(rd, "day"),
        m = AddZero(rm, "month"),
        w = rw,
        Y = i18n.date.lore.year .. " " .. loreDate.year,
        y = loreDate.year
    }

    self.replacement.date.lore = {
        x = zo_strformat(
                "<<1>>.<<2>>.<<3>><<4>>",
                loreDate.day, loreDate.month, i18n.date.lore.year, loreDate.year
        ),
        A = i18n.date.lore.week[loreDate.weekDay],
        a = i18n.date.lore.week[loreDate.weekDay]:sub(1, 3),
        B = i18n.date.lore.months[loreDate.month],
        b = i18n.date.lore.months[loreDate.month]:sub(1, 3),
		D = zo_strformat("<<i:1>>", AddZero(loreDate.day, "day")),
        d = AddZero(loreDate.day, "day"),
        m = AddZero(loreDate.month, "month"),
        w = loreDate.weekDay,
        Y = i18n.date.lore.year .. " " .. loreDate.year,
        y = loreDate.year
    }
end

--- Function to be given to the LibClockTST for the time and date updates
-- It will handle the updates of the label and tooltip
--@param time for the time object { hour = h, minute = m, second = s }
--@param date for the date object { day = d, weekDay = w, month = m, year = y }
function Time:UpdateTime(time, date)
    self:CreateTimeReplacements(time)
    if tonumber(self.replacement.date.d) ~= date.day then
        self:CreateDateReplacements(date)
    end
    self:UpdateLabel()
    self:UpdateSize()
    if settings:GetTimeHasTooltip() then
        self:UpdateTooltip()
    end
end

-- ----------------
-- Register
-- ----------------

--- Reset the previous saved replacements and mark the size as updated
function Time:ResetReplacement()
    self.replacement = {
        date = { real = {}, lore = {}, fake = {} },
        time = { real = {}, lore = {} }
    }
    self.sizeHasUpdated = true
end

--- Register the update function with the LibClockTST
function Time:RegisterForUpdates()
    local lib = LibClockTST:Instance()
    self:ResetReplacement()
    lib:Register(const.NAME, function(time, date)
        self:UpdateTime(time, date)
    end)
end

--- Remove this object from receiving further updates from the LibClockTST
function Time.UnregisterForUpdates()
    local lib = LibClockTST:Instance()
    lib:CancelSubscription(const.NAME)
end

-- ----------------
-- Setup
-- ----------------

--- Setup the tooltip to show when hovering over the label
function Time:SetupTooltip()
    local scale
    self.control:SetHandler("OnMouseEnter", function(control)
        if settings:GetTimeHasTooltip() then
            InitializeTooltip(InformationTooltip, control, TOP, 0, 0)
            SetTooltipText(InformationTooltip, self.tooltip or Clock_TST.I18N().error.library)
        end

        -- Hover
        if settings:GetTimeHighlightWhenHover() then
            if self.texture.hover then
                self.background:SetTexture(self.texture.path .. self.texture.hover)
            end
            self.background:SetColor(settings:GetTimeBackgroundHoverColour())
        end

        if settings:GetTimeScaleWhenHover() then
            scale = control:GetScale()
            control:SetScale(scale * settings:GetScaleFactor())
        end
    end)
    self.control:SetHandler("OnMouseExit", function(control)
        ClearTooltip(InformationTooltip)

        -- Hover
        self:UpdateBackground()

        control:SetScale(scale or 1)
    end)
end

--- Setup the movement of the Time and link it with the Moon control
function Time:SetupMovement()
    local function LeftClick(control)
        local offsetX, offsetY = control:GetLeft(), control:GetTop()

        if settings:GetTimeAndMoonAreLinked() then
            local moonOffsetX, moonOffsetY = settings:GetMoonOffset()
            local oldOffsetX, oldOffsetY = settings:GetTimeOffset()
            local newMoonOffsetX = moonOffsetX + offsetX - oldOffsetX
            local newMoonOffsetY = moonOffsetY + offsetY - oldOffsetY
            settings:SetMoonOffset(newMoonOffsetX, newMoonOffsetY)
            Clock_TST.moon:UpdatePositions()
        end

        settings:SetTimeOffset(offsetX, offsetY)
        self:UpdatePositions()
    end

    local function RightClick(control)
        local function Setup(isEnabled, func, text)
            if isEnabled then
                AddMenuItem("[X]\t" .. text, function()
                    func(false)
                end)
            else
                AddMenuItem("[ ]\t" .. text, function()
                    func(true)
                end)
            end
        end
        ClearMenu()
        local baseSize = const.Settings.styles.DEFAULTS.time.size
        local scalePercentage = math.floor(settings:GetTimeSize() * 100 / baseSize)
        if scalePercentage ~= 100 then
            AddMenuItem(zo_strformat("[<<1>>%]\t<<2>>", scalePercentage, i18n.core.menu.scale), function()
                settings:SetTimeSize(baseSize)
                self.sizeHasUpdated = true
                self:UpdateStyle()
            end)
        end
        Setup(settings:GetTimeIsMovable(), function(value)
            settings:SetTimeIsMovable(value)
            self:UpdateMouse()
        end, i18n.core.menu.movable)
        Setup(settings:GetTimeAndMoonAreLinked(), function(value)
            settings:SetTimeAndMoonAreLinked(value)
        end, i18n.core.menu.link)
        Setup(settings:GetTimeHasTooltip(), function(value)
            settings:SetTimeHasTooltip(value)
        end, i18n.core.menu.tooltip)
        Setup(settings:GetTimeHasBackground(), function(value)
            settings:SetTimeHasBackground(value)
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

--- Setup the mouse wheel interaction to change the size of the font when scrolling
function Time:SetupScale()
    self.control:SetHandler("OnMouseWheel", function(_, delta)
        local size = settings:GetTimeSize()
        settings:SetTimeSize(math.max(4, math.min(size + delta, 72)))
        self:UpdateStyle()
        self.sizeHasUpdated = true
    end)
end

--- Setup all controls and the Time fragment
--@param control of the TopLevelControl
function Time:SetupControls(control)
    self.control = control
    self.background = GetControl(control, "Background")
    self.label = GetControl(control, "Label")

    Clock_TST.TIME_FRAGMENT = ZO_HUDFadeSceneFragment:New(control)
    Clock_TST.TIME_FRAGMENT:Hide()
end

-- ----------------
-- Start
-- ----------------

--- Create a new time object
--@param ... control of the time object
function Time:New(...)
    local container = ZO_Object.New(self)
    container:SetupControls(...)
    return container
end

--- function to reload all values from the settings
function Clock_TST:SetupTime()
    settings = self.settings
    if Clock_TST.time then
        Clock_TST.time:RemoveFragment()
        Clock_TST.time = nil
    end

    self.time = Time:New(Clock_TST_Time)

    self.time:SetupTooltip()
    self.time:SetupMovement()
    self.time:SetupScale()

    self.time:UpdatePositions()
    self.time:UpdateVisibility()
    self.time:UpdateMouse()
    self.time:UpdateStyle()
    self.time:UpdateBackground()
end
