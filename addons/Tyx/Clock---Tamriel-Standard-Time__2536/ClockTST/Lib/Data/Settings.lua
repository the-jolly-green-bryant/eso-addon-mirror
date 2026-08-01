--[[--------------------------------------------
    Project:    Clock - Tamriel Standard Time
    Author:     Arne Rantzen (Tyx) & Phinix
    Created:    2020-01-22
    Updated:    2020-03-06
    License:    GPL-3.0
--------------------------------------------]]--

Clock_TST = Clock_TST or {}
local const = Clock_TST.CONSTANTS()
local d, p, w
local Settings = {
    account = {},
    booleans = {},
    styles = {},
    attributes = {}
}
-- ----------------
-- Account
-- ----------------

--- a function to get the stored boolean value for the core elements
--- @return boolean if the saved variable is account wide
function Settings:GetSaveAccountWide()
    return self.account.saveAccountWide
end

--- a function to store the boolean value for the core elements
--- @param value boolean if the saved variable is account wide
function Settings:SetSaveAccountWide(value)
    self.account.saveAccountWide = value
end

--- a function to get the current version as numbers
--- @return number major version
--- @return number minor version
--- @return number patch version
function Settings:GetVersion()
    local major, minor, patch = string.match(const.VERSION, "(%d+).(%d+).(%d+)")
    return tonumber(major), tonumber(minor), tonumber(patch)
end

--- a function to get last stored version
--- @return number major version
--- @return number minor version
--- @return number patch version
function Settings:GetLastVersion()
    local lV = self.account.lastVersion or {}
    return lV.major, lV.minor, lV.patch
end

--- a function to store the last version
--- @param major number version
--- @param minor number version
--- @param patch number version
function Settings:SetLastVersion(major, minor, patch)
    self.account.lastVersion = {
        major = major,
        minor = minor,
        patch = patch
    }
end

--- a function to get the stored boolean value for the core elements
--- since 2.2.0
--- @return boolean if the debug mode is enabled
function Settings:GetDebug()
    return self.account.debug
end

--- a function to store the boolean value for the core elements
--- since 2.2.0
--- @param value boolean if the debug mode is enabled
function Settings:SetDebug(value)
    self.account.debug = value
end

--- a function to get the stored boolean value for the core elements
-- if it is linked to time, the moon moves with the time object
--- @return boolean if the moon is linked to time
function Settings:GetTimeAndMoonAreLinked()
    return self.booleans.core.timeAndMoonAreLinked
end

--- a function to store the boolean value for the core elements
--- @param value boolean if the moon is linked to time
function Settings:SetTimeAndMoonAreLinked(value)
    self.booleans.core.timeAndMoonAreLinked = value
end

--- a function to get the stored boolean value for the core elements
--- @return boolean if the view should be hidden in groups
function Settings:GetHideInGroup()
    return self.booleans.core.hideInGroup
end

--- a function to store the boolean value for the core elements
--- @param value boolean if the view should be hidden in groups
function Settings:SetHideInGroup(value)
    self.booleans.core.hideInGroup = value
end

--- a function to get the stored boolean value for the core elements
--- @return boolean if the view should be hidden in fights
function Settings:GetHideInFight()
    return self.booleans.core.hideInFight
end

--- a function to store the boolean value for the core elements
--- @param value boolean if the view should be hidden in fights
function Settings:SetHideInFight(value)
    self.booleans.core.hideInFight = value
end

--- a function to get the stored boolean value for the core elements
--- @return boolean if the view should be only visible on the map
function Settings:GetOnlyShowOnMap()
    return self.booleans.core.onlyShowOnMap
end

--- a function to store the boolean value for the core elements
--- @param value boolean if the view should be only visible on the map
function Settings:SetOnlyShowOnMap(value)
    self.booleans.core.onlyShowOnMap = value
end

-- ----------------
-- Time Booleans
-- ----------------

--- a function to get the stored boolean value for the time
--- @return boolean if the time is visible
function Settings:GetTimeIsVisible()
    return self.booleans.time.isVisible
end

--- a function to store the boolean value for the time
--- @param value boolean if the time is visible
function Settings:SetTimeIsVisible(value)
    self.booleans.time.isVisible = value
end

--- a function to get the stored boolean value for the time
--- @return boolean if the time is mouseEnabled
function Settings:GetTimeIsMouseEnabled()
    return self.booleans.time.isMouseEnabled
end

--- a function to store the boolean value for the time
--- @param value boolean if the time is mouseEnabled
function Settings:SetTimeIsMouseEnabled(value)
    self.booleans.time.isMouseEnabled = value
end

--- a function to get the stored boolean value for the time
--- @return boolean if the time is movable
function Settings:GetTimeIsMovable()
    return self.booleans.time.isMovable
end

--- a function to store the boolean value for the time
--- @param value boolean if the time is movable
function Settings:SetTimeIsMovable(value)
    self.booleans.time.isMovable = value
end

--- a function to get the stored boolean value for the time
--- @return boolean if the time has tooltip
function Settings:GetTimeHasTooltip()
    return self.booleans.time.hasTooltip
end

--- a function to store the boolean value for the time
--- @param value boolean if the time has tooltip
function Settings:SetTimeHasTooltip(value)
    self.booleans.time.hasTooltip = value
end

--- a function to get the stored boolean value for the time
--- @return boolean if the time has background
function Settings:GetTimeHasBackground()
    return self.booleans.time.hasBackground
end

--- a function to store the boolean value for the time
--- @param value boolean if the time has background
function Settings:SetTimeHasBackground(value)
    self.booleans.time.hasBackground = value
end

--- a function to get the stored boolean value for the time
--- @return boolean if a 0 should be added before a single digit
function Settings:GetTimeAddZero(opt)
	if opt == "hour" then
		return self.booleans.time.addZeroHour
	elseif opt == "min" then
		return self.booleans.time.addZeroMin
	elseif opt == "sec" then
		return self.booleans.time.addZeroSec
	elseif opt == "day" then
		return self.booleans.time.addZeroDay
	elseif opt == "month" then
		return self.booleans.time.addZeroMonth
	end
end

--- a function to store the boolean value for the time
--- @param value boolean if a 0 should be added before a single digit
function Settings:SetTimeAddZero(value, opt)
	if opt == "hour" then
		self.booleans.time.addZeroHour = value
	elseif opt == "min" then
		self.booleans.time.addZeroMin = value
	elseif opt == "sec" then
		self.booleans.time.addZeroSec = value
	elseif opt == "day" then
		self.booleans.time.addZeroDay = value
	elseif opt == "month" then
		self.booleans.time.addZeroMonth = value
	end
end

--- a function to get the stored boolean value for the time
--- @return boolean if the time has US format {12,1,...,11} am : {12,1,...,11} pm
function Settings:GetTimeHasUSFormat()
    return self.booleans.time.hasUSFormat
end

--- a function to store the boolean value for the time
--- @param value boolean if the time has the US format
function Settings:SetTimeHasUSFormat(value)
    self.booleans.time.hasUSFormat = value
end

--- a function to get the stored boolean value for the am/pm format
--- @return boolean if using minimalistic am/pm
function Settings:GetMinimalAMPM()
    return self.booleans.time.minAMPM
end

--- a function to store the boolean value for the am/pm format
--- @param value boolean if using minimalistic am/pm
function Settings:SetMinimalAMPM(value)
    self.booleans.time.minAMPM = value
end

--- a function to get the stored boolean value for the time
--- @return boolean if the time has Japanese format {0,1,...,11} am : {12,1,...,11} pm
function Settings:GetTimeHasJapFormat()
    return self.booleans.time.hasJapFormat
end

--- a function to store the boolean value for the time
--- @param value boolean if the time has the Japanese format
function Settings:SetTimeHasJapFormat(value)
    self.booleans.time.hasJapFormat = value
end

--- a function to get the stored boolean value for the time
--- @return boolean if the time has a lore date
function Settings:GetTimeHasLoreDate()
    return self.booleans.time.hasLoreDate
end

--- a function to store the boolean value for the time
--- @return boolean if the time has a lore date
function Settings:SetTimeHasLoreDate(value)
    self.booleans.time.hasLoreDate = value
end

--- a function to get the stored boolean value for the time
--- @return boolean if the time has a fake lore date
function Settings:GetTimeHasFakeLoreDate()
    return self.booleans.time.hasFakeLoreDate
end

--- a function to store the boolean value for the time
--- @return boolean if the time has a fake lore date
function Settings:SetTimeHasFakeLoreDate(value)
    self.booleans.time.hasFakeLoreDate = value
end

--- a function to get the stored boolean value for the time
--- @return boolean if the time has a real date
function Settings:GetTimeHasRealDate()
    return self.booleans.time.hasRealDate
end

--- a function to store the boolean value for the time
--- @return boolean if the time has a real date
function Settings:SetTimeHasRealDate(value)
    self.booleans.time.hasRealDate = value
end

--- a function to get the stored boolean value for the time
--- @return boolean if the time should scale up when hovering over
function Settings:GetTimeScaleWhenHover()
    return self.booleans.time.scaleWhenHover
end

--- a function to store the boolean value for the time
--- @param value boolean if the time should scale up when hovering over
function Settings:SetTimeScaleWhenHover(value)
    self.booleans.time.scaleWhenHover = value
end

--- a function to get the stored boolean value for the time
--- @return boolean if the time should change colour when hovering over
function Settings:GetTimeHighlightWhenHover()
    return self.booleans.time.highlightWhenHover
end

--- a function to store the boolean value for the time
--- @param value boolean if the time should change colour when hovering over
function Settings:SetTimeHighlightWhenHover(value)
    self.booleans.time.highlightWhenHover = value
end

-- ----------------
-- Moon Booleans
-- ----------------

--- a function to get the stored boolean value for the moon
--- @return boolean if the moon is visible
function Settings:GetMoonIsVisible()
    return self.booleans.moon.isVisible
end

--- a function to store the boolean value for the moon
--- @param value boolean if the moon is visible
function Settings:SetMoonIsVisible(value)
    self.booleans.moon.isVisible = value
end

--- a function to get the stored boolean value for the moon
--- @return boolean if the moon is mouseEnabled
function Settings:GetMoonIsMouseEnabled()
    return self.booleans.moon.isMouseEnabled
end

--- a function to store the boolean value for the moon
--- @param value boolean if the moon is mouseEnabled
function Settings:SetMoonIsMouseEnabled(value)
    self.booleans.moon.isMouseEnabled = value
end

--- a function to get the stored boolean value for the moon
--- @return boolean if the moon is movable
function Settings:GetMoonIsMovable()
    return self.booleans.moon.isMovable
end

--- a function to store the boolean value for the moon
--- @param value boolean if the moon is movable
function Settings:SetMoonIsMovable(value)
    self.booleans.moon.isMovable = value
end

--- a function to get the stored boolean value for the moon
--- @return boolean if the moon has background
function Settings:GetMoonHasBackground()
    return self.booleans.moon.hasBackground
end

--- a function to store the boolean value for the moon
--- @param value boolean if the moon has background
function Settings:SetMoonHasBackground(value)
    self.booleans.moon.hasBackground = value
end

--- a function to get the stored boolean value for the moon
--- @return boolean if the moon has tooltip
function Settings:GetMoonHasTooltip()
    return self.booleans.moon.hasTooltip
end

--- a function to store the boolean value for the moon
--- @param value boolean if the moon has tooltip
function Settings:SetMoonHasTooltip(value)
    self.booleans.moon.hasTooltip = value
end

--- a function to get the stored boolean value for the moon
--- @return boolean if the moon should scale up when hovering over
function Settings:GetMoonScaleWhenHover()
    return self.booleans.moon.scaleWhenHover
end

--- a function to store the boolean value for the moon
--- @param value boolean if the moon should scale up when hovering over
function Settings:SetMoonScaleWhenHover(value)
    self.booleans.moon.scaleWhenHover = value
end

--- a function to get the stored boolean value for the moon
--- @return boolean if the moon should change colour when hovering over
function Settings:GetMoonHighlightWhenHover()
    return self.booleans.moon.highlightWhenHover
end

--- a function to store the boolean value for the moon
--- @param value boolean if the moon should change colour when hovering over
function Settings:SetMoonHighlightWhenHover(value)
    self.booleans.moon.highlightWhenHover = value
end

-- ----------------
-- Time Styles
-- ----------------

--- a function to get the stored style value for the time
--- @return string the format for the time
function Settings:GetTimeFormat()
    return self.styles.time.format
end

--- a function to store the style value for the moon
--- @param value string the format for the time
function Settings:SetTimeFormat(value)
    self.styles.time.format = value
end

--- a function to get the stored style value for the time
--- @return number the size for the time
function Settings:GetTimeSize()
    return self.styles.time.size
end

--- a function to store the style value for the moon
--- @param value number the size for the time
function Settings:SetTimeSize(value)
    self.styles.time.size = value
end

--- a function to get the stored style value for the time
--- @return number r red colour
--- @return number g green colour
--- @return number b blue colour
--- @return number a alpha value
function Settings:GetTimeColour()
    local colour = self.styles.time.colour
    return colour.r, colour.g, colour.b, colour.a
end

--- a function to store the style value for the moon
--- @param r number red colour
--- @param g number green colour
--- @param b number blue colour
--- @param a number alpha value
function Settings:SetTimeColour(r, g, b, a)
    self.styles.time.colour = {
        r = r,
        g = g,
        b = b,
        a = a
    }
end

--- a function to get the stored style value for the time
--- @return string the font for the time
function Settings:GetTimeFont()
    return self.styles.time.font
end

--- a function to store the style value for the moon
--- @param value string the font for the time
function Settings:SetTimeFont(value)
    self.styles.time.font = value
end

--- a function to get the stored style value for the time
--- @return string the style for the time
function Settings:GetTimeStyle()
    return self.styles.time.style
end

--- a function to store the style value for the moon
--- @param value string the style for the time
function Settings:SetTimeStyle(value)
    self.styles.time.style = value
end

--- a function to get the stored style value for the time
--- @return number the line count for the time
function Settings:GetTimeLineCount()
    return self.styles.time.lineCount
end

--- a function to store the style value for the moon
--- @param value number the line count for the time
function Settings:SetTimeLineCount(value)
    self.styles.time.lineCount = value
end

--- a function to get the stored style value for the time
--- @return string background texture table key
function Settings:GetTimeBackground()
    return self.styles.time.background
end

--- a function to store the style value for the time
--- @param value table key for background name
function Settings:SetTimeBackground(value)
    self.styles.time.background = value
end

--- a function to get the stored style value for the time
--- since 2.1.0
--- @return number r red colour
--- @return number g green colour
--- @return number b blue colour
--- @return number a alpha value
function Settings:GetTimeBackgroundColour()
    local colour = self.styles.time.backgroundColour
    return colour.r, colour.g, colour.b, colour.a
end

--- a function to store the style value for the moon
--- since 2.1.0
--- @param r number red colour
--- @param g number green colour
--- @param b number blue colour
--- @param a number alpha value
function Settings:SetTimeBackgroundColour(r, g, b, a)
    self.styles.time.backgroundColour = {
        r = r,
        g = g,
        b = b,
        a = a
    }
end

--- a function to get the stored style value for the time
--- since 2.1.0
--- @return number r red colour
--- @return number g green colour
--- @return number b blue colour
--- @return number a alpha value
function Settings:GetTimeBackgroundHoverColour()
    local colour = self.styles.time.backgroundHoverColour
    return colour.r, colour.g, colour.b, colour.a
end

--- a function to store the style value for the moon
--- since 2.1.0
--- @param r number red colour
--- @param g number green colour
--- @param b number blue colour
--- @param a number alpha value
function Settings:SetTimeBackgroundHoverColour(r, g, b, a)
    self.styles.time.backgroundHoverColour = {
        r = r,
        g = g,
        b = b,
        a = a
    }
end

--- a function to get the stored style value for the time
--- @return number background width offset
function Settings:GetTimeBackgroundOffset()
    return self.styles.time.backgroundOffset
end

--- a function to store the style value for the time
--- @param value number background width offset
function Settings:SetTimeBackgroundOffset(value)
    self.styles.time.backgroundOffset = value
end

-- ----------------
-- Moon Styles
-- ----------------

--- a function to get the stored style value for the moon
--- @return string background texture table key
function Settings:GetMoonBackground()
    return self.styles.moon.background
end

--- a function to store the style value for the moon
--- @param value string background texture table key
function Settings:SetMoonBackground(value)
    self.styles.moon.background = value
end

--- a function to get the stored style value for the moon
--- since 2.1.0
--- @return number r red colour
--- @return number g green colour
--- @return number b blue colour
--- @return number a alpha value
function Settings:GetMoonBackgroundColour()
    local colour = self.styles.moon.backgroundColour
    return colour.r, colour.g, colour.b, colour.a
end

--- a function to store the style value for the moon
--- since 2.1.0
--- @param r number red colour
--- @param g number green colour
--- @param b number blue colour
--- @param a number alpha value
function Settings:SetMoonBackgroundColour(r, g, b, a)
    self.styles.moon.backgroundColour = {
        r = r,
        g = g,
        b = b,
        a = a
    }
end

--- a function to get the stored style value for the moon
--- since 2.1.0
--- @return number r red colour
--- @return number g green colour
--- @return number b blue colour
--- @return number a alpha value
function Settings:GetMoonBackgroundHoverColour()
    local colour = self.styles.moon.backgroundHoverColour
    return colour.r, colour.g, colour.b, colour.a
end

--- a function to store the style value for the moon
--- since 2.1.0
--- @param r number red colour
--- @param g number green colour
--- @param b number blue colour
--- @param a number alpha value
function Settings:SetMoonBackgroundHoverColour(r, g, b, a)
    self.styles.moon.backgroundHoverColour = {
        r = r,
        g = g,
        b = b,
        a = a
    }
end

--- a function to get the stored style value for the moon
--- @return table key for masser texture
function Settings:GetMoonTextureKeyMasser()
    return self.styles.moon.masser
end

--- a function to store the style value for the moon
--- @param value table key for masser texture
function Settings:SetMoonTextureKeyMasser(value)
    self.styles.moon.masser = value
end

--- a function to get the stored style value for the moon
--- @return table key for secunda texture
function Settings:GetMoonTextureKeySecunda()
    return self.styles.moon.secunda
end

--- a function to store the style value for the moon
--- @param value table key for secunda texture
function Settings:SetMoonTextureKeySecunda(value)
    self.styles.moon.secunda = value
end

--- a function to get the stored style value for the moon
--- @return number value of how much the moon texture is visible
function Settings:GetMoonAlpha()
    return self.styles.moon.alpha
end

--- a function to store the style value for the moon
--- @param value number of how much the moon texture is visible
function Settings:SetMoonAlpha(value)
    self.styles.moon.alpha = value
end

-- ----------------
-- Core Attributes
-- ----------------

--- a function to get the stored scale factor
--- @return number range (-inf:inf)
function Settings:GetScaleFactor()
    return self.attributes.core.scaleFactor
end

--- a function to store the scale factor
--- @param value number range (-inf:inf)
function Settings:SetScaleFactor(value)
    self.attributes.core.scaleFactor = value
end
-- ----------------
-- Time Attributes
-- ----------------

--- a function to get the current attributes for the time.
-- Inside are also the attribute tables of label and background.
--- @return table time = {
--    anchor = { point, relativeTo, relativePoint, offsetX, offsetY, },
--    dimension = { width, height, },
--    background = {
--        anchor = { point, relativeTo, relativePoint, offsetX, offsetY, },
--        dimension = { width, height, },
--        background = {
--            anchor = { point, relativeTo, relativePoint, offsetX, offsetY, },
--            dimension = { width, height, },
--        },
--    },
--    label = {
--        anchor = { point, relativeTo, relativePoint, offsetX, offsetY, },
--        dimension = { width, height, },
--        background = {
--            anchor = { point, relativeTo, relativePoint, offsetX, offsetY, },
--            dimension = { width, height, },
--        },
--    },
--}
function Settings:GetTimeAttributes()
    return self.attributes.time
end

--- a function to get the current offset of the time
--- @return number offsetX
--- @return number offsetY
function Settings:GetTimeOffset()
    local anchor = self.attributes.time.anchor
    return anchor.offsetX, anchor.offsetY
end

--- a function to save the current offset of the time
--- @param x number offset
--- @param y number offset
function Settings:SetTimeOffset(x, y)
    self.attributes.time.anchor.offsetX = x
    self.attributes.time.anchor.offsetY = y
end

--- a function to get the current dimension for the time.
--- @return table dimension = { width, height, }
function Settings:GetTimeDimension()
    return self.attributes.time.dimension
end

--- a function to get the current dimension for the time.
--- @param value table dimension = { width, height, }
function Settings:SetTimeDimension(value)
    self.attributes.time.dimension = value
end

-- ----------------
-- Moon Attributes
-- ----------------

--- a function to get the current attributes for the moon.
-- Inside are also the attribute tables of Secunda and Masser.
--- @return table moon = {
--    anchor = { point, relativeTo, relativePoint, offsetX, offsetY, },
--    dimension = { width, height, },
--    masser = {
--        anchor = { point, relativeTo, relativePoint, offsetX, offsetY, },
--        dimension = { width, height, },
--        background = {
--            anchor = { point, relativeTo, relativePoint, offsetX, offsetY, },
--            dimension = { width, height, },
--        },
--    },
--    secunda = {
--        anchor = { point, relativeTo, relativePoint, offsetX, offsetY, },
--        dimension = { width, height, },
--        background = {
--            anchor = { point, relativeTo, relativePoint, offsetX, offsetY, },
--            dimension = { width, height, },
--        },
--    },
--}
function Settings:GetMoonAttributes()
    return self.attributes.moon
end

--- a function to get the current moon anchor
--- @return table anchor = { point, relativeTo, relativePoint, offsetX, offsetY, }
function Settings:GetMoonAnchor()
    return self.attributes.moon.anchor
end

--- a function to get the current offset of the moon
--- @return number offsetX
--- @return number offsetY
function Settings:GetMoonOffset()
    local anchor = self.attributes.moon.anchor
    return anchor.offsetX, anchor.offsetY
end

--- a function to save the current offset of the moon
--- @param x number offset
--- @param y number offset
function Settings:SetMoonOffset(x, y)
    self.attributes.moon.anchor.offsetX = x
    self.attributes.moon.anchor.offsetY = y
end

--- a function to get the current dimension for the moon.
--- @return table dimension = { width, height, }
function Settings:GetMoonDimension()
    return self.attributes.moon.dimension
end

--- a function to get the current dimension for the moon.
--- @param value table dimension = { width, height, }
function Settings:SetMoonDimension(value)
    self.attributes.moon.dimension = value
end

--- a function to get the current attributes for the moon Masser.
--- @return table masser = {
--    anchor = { point, relativeTo, relativePoint, offsetX, offsetY, },
--    dimension = { width, height, },
--    background = {
--        anchor = { point, relativeTo, relativePoint, offsetX, offsetY, },
--        dimension = { width, height, },
--}
function Settings:GetMoonMasserAttributes()
    return self.attributes.moon.masser
end

--- a function to get the current attributes for the moon Secunda.
--- @return table secunda = {
--    anchor = { point, relativeTo, relativePoint, offsetX, offsetY, },
--    dimension = { width, height, },
--    background = {
--        anchor = { point, relativeTo, relativePoint, offsetX, offsetY, },
--        dimension = { width, height, },
--}
function Settings:GetMoonSecundaAttributes()
    return self.attributes.moon.secunda
end

--- a function to get the stored scale
--- @return number range [0, inf)
function Settings:GetMoonScale()
    return self.attributes.moon.scale
end

--- a function to store the scale
--- @param value number range [0, inf)
function Settings:SetMoonScale(value)
    self.attributes.moon.scale = value
end

-- ----------------
-- Presets
-- ----------------

--- Function to get a list of all presets
--- since 2.2.2
--- @return table of preset keys
function Settings:GetPresets()
    return Clock_TST.GetKeys(self.presets.saved)
end

--- Function to apply a specific preset
--- since 2.2.2
--- @param key string of the preset
function Settings:ApplyPreset(key)
    --- Function to deep replace values from one table in an other
    --- @param old table which should be changed
    --- @param new table of the source
    local function Replace(old, new)
        if type(new) == "table" and next(new) then
            for k, v in pairs(new) do
                if type(v) == "table" then
                    Replace(old[k], v)
                else
                    old[k] = v
                end
            end
        end
    end

    self:ResetAttributes()
    self:ResetBooleans()
    self:ResetStyles()

    if key ~= "Default" then
        local copy = {}
        ZO_DeepTableCopy(self.presets.saved[key], copy)
        Replace(self.attributes, copy.attributes)
        Replace(self.booleans, copy.booleans)
        Replace(self.styles, copy.styles)
    end

    if self:GetDebug() then
        d("Preset %s applied.", key)
    end

    self:SetCurrentPreset(key)
end

--- Function to add a new preset
--- since 2.2.2
--- @param key string of the new preset
function Settings:AddPreset(key)
    if key == "Default" then
        w("Overwriting the default preset is not allowed.")
        return
    end

    self.presets.saved[key] = {
        attributes = Clock_TST.SelectiveCopy(
                getmetatable(self.attributes).__index,
                const.Settings.attributes.DEFAULTS,
                "version"),
        booleans = Clock_TST.SelectiveCopy(
                getmetatable(self.booleans).__index,
                const.Settings.booleans.DEFAULTS,
                "version"),
        styles = Clock_TST.SelectiveCopy(
                getmetatable(self.styles).__index,
                const.Settings.styles.DEFAULTS,
                "version")
    }

    if not next(self.presets.saved[key]) then
        w("Tried to save preset without any differences to the default preset.")
        self.presets.saved[key] = nil
    end

    if self:GetDebug() then
        d("Preset %s added.", key)
    end
end

--- Function to remove a preset
--- since 2.2.2
--- @param key string of the preset
function Settings:RemovePreset(key)
    self.presets.saved[key] = nil
    if self:GetCurrentPreset() == key then
        self:SetCurrentPreset(nil)
    end

    if self:GetDebug() then
        d("Preset %s removed.", key)
    end
end

--- Function to get the current preset
--- since 2.2.2
--- @return string current preset key
function Settings:GetCurrentPreset()
    return self.presets.current
end

---Function to set the current preset
--- since 2.2.2
--- @param key string for preset
function Settings:SetCurrentPreset(key)
    self.presets.current = key
end

---Function to find out if the current preset already exists
--- since 2.2.2
function Settings:CurrentPresetExists()
    for _, v in pairs(self:GetPresets()) do
        if self:GetCurrentPreset() == v then return true end
    end
    return false
end

-- ----------------
-- Reset
-- ----------------

--- Resets the attributes table to the default values
function Settings:ResetAttributes()
    for k, v in pairs(Clock_TST.CONSTANTS().Settings.attributes.DEFAULTS) do
        self.attributes[k] = v
    end
    if self:GetDebug() then
        d("Attributes reset")
    end
end

--- Resets the booleans table to the default values
function Settings:ResetBooleans()
    for k, v in pairs(Clock_TST.CONSTANTS().Settings.booleans.DEFAULTS) do
        self.booleans[k] = v
    end
    if self:GetDebug() then
        d("Booleans reset")
    end
end

--- Resets the styles table to the default values
function Settings:ResetStyles()
    for k, v in pairs(Clock_TST.CONSTANTS().Settings.styles.DEFAULTS) do
        self.styles[k] = v
    end
    if self:GetDebug() then
        d("Styles reset")
    end
end

--- Resets the preset table to the default values
--- since 2.2.2
function Settings:ResetPresets()
    for k, _ in pairs(self.presets) do
        self.presets[k] = nil
    end
    for k, v in pairs(Clock_TST.CONSTANTS().Settings.presets.DEFAULTS) do
        self.presets[k] = v
    end
    if self:GetDebug() then
        d("Presets reset")
    end
end

--- Resets the self table to the default values
function Settings:Reset()
    self:ResetAttributes()
    self:ResetBooleans()
    self:ResetStyles()
    self:ResetPresets()
end

-- ----------------
-- Initialize
-- ----------------

--- Function to migrate saved variables to latest version without having to reset it
function Settings:Migrate()
    local major, minor = self:GetLastVersion()
    -- Update 2.1.0 introduced background and hover colour
    if not major or major == 2 and minor < 1 then
        -- Before the version was a string not a table
        if type(self.account.lastVersion) ~= "2.1.0" then
            local function CopyRGBA(colour, default)
                for k, c in pairs(default) do
                    colour[k] = c
                end
            end
            -- Add background colour
            local default = Clock_TST.CONSTANTS().Settings.styles.DEFAULTS
            CopyRGBA(self.styles.time.backgroundColour, default.time.backgroundColour)
            CopyRGBA(self.styles.time.backgroundHoverColour, default.time.backgroundHoverColour)
            CopyRGBA(self.styles.moon.backgroundColour, default.moon.backgroundColour)
            CopyRGBA(self.styles.moon.backgroundHoverColour, default.moon.backgroundHoverColour)


            -- Remove background strength
            self.styles.time.backgroundStrength = nil
            self.styles.moon.backgroundStrength = nil

            p("Updated to 2.1")

        end
    end

    self:SetLastVersion(self:GetVersion())
end

--- Load the SavedVariables or register the default values.
function Settings:New()
    local function InitializeSavedVariable(table, isAccountWide)
        if isAccountWide then
            return ZO_SavedVars:NewAccountWide(
                    const.SAVED_NAME,
                    table.SAVED_VERSION,
                    table.SAVED_NAME,
                    table.DEFAULTS
                )
        else
            return ZO_SavedVars:New(
                const.SAVED_NAME,
                table.SAVED_VERSION,
                table.SAVED_NAME,
                table.DEFAULTS
            )
        end
    end
    self.account = InitializeSavedVariable(
            const.Settings.account,
            true
    )
    self.booleans = InitializeSavedVariable(
            const.Settings.booleans,
            self.account.saveAccountWide
    )
    self.styles = InitializeSavedVariable(
            const.Settings.styles,
            self.account.saveAccountWide
    )
    self.attributes = InitializeSavedVariable(
            const.Settings.attributes,
            self.account.saveAccountWide
    )
    self.presets = InitializeSavedVariable(
            const.Settings.presets,
            self.account.saveAccountWide
    )
    self:Migrate()
    return self
end

function Clock_TST:SetupSettings()
    d = Clock_TST.Debug
    p = Clock_TST.Print
    w = Clock_TST.Warn
    self.settings = Settings:New()
end
