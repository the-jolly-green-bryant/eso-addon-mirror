
local strings = {
	DEFAULT_TOPLEFT = "Default top left zone name & time display",
	PERFECT_PIXEL = "Mostly for PerfectPixel users ;-)",
	LESS_FLASHY = "Map fading",
	LESS_FLASHY_TOOLTIP = "Slightly fade the map to black to please your eyes at night.\n87 is fine\n100 is game default",
	DESATURATION = "Map desaturation",
	DESATURATION_TOOLTIP = "Desaturate colors on the map.\n20 is fine\n0 is game default",
	SECONDS = "Force 24h format & seconds on the map clock",
	SECONDS_TOOLTIP = ":-)",
	TO = "To ",
	WAYSHRINE = "Wayshrine",
	WAYSHRINE_ONLY = "Can only be travelled to via a wayshrine.",
	ABBR = "Abbreviated Keeps",
	ABBR_TOOLTIP = "Display (international) abbreviated keep names on Cyrodiil map.",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
