NEAR_SR.utils = {}
local addon = NEAR_SR
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

NEAR_SR.utils.color = {
	lightPink       = "|cCC99FF",
	white           = "|cFFFFFF",
	grey            = "|c626255",
	lightGrey       = "|cbcbcbc",
	red             = "|cFF0000",
	green           = "|c00FF00",
	blue            = "|c0000FF",
	yellow          = "|cFFFF00",
	lightYellow     = "|cFFFFCC",
	orange          = "|cFF6600",
	darkOrange      = "|cFFA500",
	brightOrange    = "|cE68A00",
	magenta         = "|cFF00FF",
	darkGreen       = "|c7f9c4f",
}

local lightPink = addon.utils.color.lightPink

NEAR_SR.utils.dbg = {
	default         = lightPink.. addon.shortTitle.. ': |r',
	white           = lightPink.. addon.shortTitle.. ': |r'.. addon.utils.color.white,
	grey            = lightPink.. addon.shortTitle.. ': |r'.. addon.utils.color.grey,
	lightGrey       = lightPink.. addon.shortTitle.. ': |r'.. addon.utils.color.lightGrey,
	open            = addon.utils.color.lightGrey.. '--------------------------------------------------',
	close           = addon.utils.color.grey.. '==================================================',
}
