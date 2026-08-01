local FC = assert(FontChanger, "FontChanger global table not found — check load order in FontChanger.txt")

if PP then
	-- Override PP's font references before PP.Core runs.
	-- PP.f.u57/u67 are read by all PP modules (scenes, compass, keybind strip, etc.)
	-- so this cascades FC's font choices throughout PP's UI.
	ZO_PreHook(PP, "Core", function(...)
		-- PP's EVENT_ADD_ON_LOADED may fire before FC's, so ensure FC is initialized
		if not FC.SV then
			FC:Initialize()
		end
		PP.f.u57 = FC.SV.menu_font
		PP.f.u67 = FC.SV.menu_bold_font
		return false
	end)

	-- PP.compass sets cardinal direction fonts and boss bar text using PP's
	-- hardcoded sizes. Post-hook to reapply with FC's scaling.
	ZO_PostHook(PP, "compass", function(...)
		local compassSize = math.floor(17 * FC.SV.menu_bold_font_scale) -- PP default: 17
		local compassFont = ZO_CreateFontString(FC.SV.menu_bold_font, compassSize, FONT_STYLE_OUTLINE)
		COMPASS.container:SetCardinalDirection(GetString(SI_COMPASS_NORTH_ABBREVIATION), compassFont, CARDINAL_DIRECTION_NORTH)
		COMPASS.container:SetCardinalDirection(GetString(SI_COMPASS_EAST_ABBREVIATION),  compassFont, CARDINAL_DIRECTION_EAST)
		COMPASS.container:SetCardinalDirection(GetString(SI_COMPASS_WEST_ABBREVIATION),  compassFont, CARDINAL_DIRECTION_WEST)
		COMPASS.container:SetCardinalDirection(GetString(SI_COMPASS_SOUTH_ABBREVIATION), compassFont, CARDINAL_DIRECTION_SOUTH)

		local bossBarSize = math.floor(16 * FC.SV.menu_bold_font_scale) -- PP default: 16
		PP.Font(ZO_BossBarHealthText, FC.SV.menu_bold_font, bossBarSize, "outline")
	end)

	-- PP.keybindStrip sets keybind name/key fonts with hardcoded sizes.
	-- Post-hook to reapply with FC's scaling.
	ZO_PostHook(PP, "keybindStrip", function(...)
		local t = {KEYBIND_STRIP_STANDARD_STYLE, KEYBIND_STRIP_CHAMPION_KEYBOARD_STYLE}
		local nameSize = math.floor(18 * FC.SV.menu_bold_font_scale) -- PP default: 18
		local keySize = math.floor(16 * FC.SV.menu_font_scale)       -- PP default: 16
		for _, keybindStrip in ipairs(t) do
			keybindStrip.nameFont = FC.SV.menu_bold_font .. "|" .. nameSize .. "|outline"
			keybindStrip.keyFont = FC.SV.menu_font .. "|" .. keySize
		end
	end)

	-- Chat system isn't ready at file-load time; defer the message
	EVENT_MANAGER:RegisterForEvent(FC.name .. "PPCompat", EVENT_PLAYER_ACTIVATED, function()
		EVENT_MANAGER:UnregisterForEvent(FC.name .. "PPCompat", EVENT_PLAYER_ACTIVATED)
		d("[FontChanger] PerfectPixel compatibility enabled")
	end)
end
