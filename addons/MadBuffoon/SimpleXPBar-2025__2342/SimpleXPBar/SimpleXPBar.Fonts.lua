LMP = LibStub("LibMediaProvider-1.0")

SimpleXPBar.FontStyles = {
	[GetString(SXPB_STYLE_NONE)]            = "",
	[GetString(SXPB_STYLE_THICK_SD)]    = "soft-shadow-thick",
	[GetString(SXPB_STYLE_THIN_SD)]     = "soft-shadow-thin",
}

function SimpleXPBar:FontSizes()
	return Terril_lib.range(8, 72, 2)
end

function SimpleXPBar:StyleList()
	return Terril_lib.keys(self.FontStyles)
end

function SimpleXPBar:GetFont(fontname, size, style)
	local fontstring = LMP:Fetch('font', fontname)
	if fontstring == nil then return end

	return Terril_lib.join({fontstring, size, style}, '|')
	--return self:Join('|', fontstring, size, style)
end

function SimpleXPBar:ExtendLMP()
	-- all these fonts are licensed under the OFL (OpenFontLicense) by their respective owners.
	local FontTable = {
		["Noto Serif"]                      = "SimpleXPBar/fonts/NotoSerif-Regular.ttf",
		["Noto Sans"]                       = "SimpleXPBar/fonts/NotoSans-Regular.ttf",

		["Lato"]                            = "SimpleXPBar/fonts/Lato-Regular.ttf",

		["AnkaCoder"]                       = "SimpleXPBar/fonts/AnkaCoder-r.ttf",
		["Ackermann"]                       = "SimpleXPBar/fonts/Ackermann.otf",
		["Abibas"]                          = "SimpleXPBar/fonts/Abibas.ttf",
		["BackOut"]                         = "SimpleXPBar/fonts/BackOutWeb.otf",
		["Alfphabet Condensed"]             = "SimpleXPBar/fonts/Alfphabet-Condensed.ttf",
		["Alfphabet IV"]                    = "SimpleXPBar/fonts/Alfphabet-IV.ttf",
		["Averia Regular"]                  = "SimpleXPBar/fonts/Averia-Regular.ttf",

		["Combat"]                          = "SimpleXPBar/fonts/Combat.otf",
		["Futura Renner Light"]             = "SimpleXPBar/fonts/FuturaRenner-Light.otf",
		["Futura Renner"]                   = "SimpleXPBar/fonts/FuturaRenner-Regular.otf",
		["GOSTRUS"]                         = "SimpleXPBar/fonts/GTRS_RtpA.ttf",

		["Nova Flat"]						= "SimpleXPBar/fonts/NovaFlat.ttf",
		["Nova Round"]						= "SimpleXPBar/fonts/NovaRound.ttf",

		["Berenika"]						= "SimpleXPBar/fonts/Berenika.ttf",
		["Inkut Antiqua"]					= "SimpleXPBar/fonts/InknutAntiqua-Regular.ttf",
		["Lerotica"]						= "SimpleXPBar/fonts/lerotica-regular.ttf",
	}

	for k,v in pairs(FontTable) do
		LMP:Register('font', k, v)
	end
end