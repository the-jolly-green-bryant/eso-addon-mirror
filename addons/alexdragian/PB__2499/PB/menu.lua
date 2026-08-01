local LAM = LibAddonMenu2

function PB.MenuHeader( title, optionsData )
  local spacer = {
    type = "description",
    title = nil,
    text = "",
  }
  optionsData[#optionsData + 1] = spacer
  optionsData[#optionsData + 1] = {
    type = "header",
    name = ZO_HIGHLIGHT_TEXT:Colorize(zo_strformat("<<Z:1>>", title)),
    width = "full",
  }
end

function PB.CreateMenu()

  local panelData = {
    type = "panel",
		name = "Pixel Booty",
		displayName = ZO_HIGHLIGHT_TEXT:Colorize("Pixel Booty"),
		author = "DaKuleMune",
		version = PB.version,
		slashCommand = "/PB",
		website = "https://www.pixelbooty.com",
		registerForRefresh = true,
		registerForDefaults = true
  }

  PB.LAMPanel = LAM:RegisterAddonPanel("PixelBootyOptions", panelData)

  local optionsData = {}

  PB.MenuHeader( "Guild Features", optionsData )
  PB.GuildFeatureMenu( optionsData )

  PB.MenuHeader( "Quality of Life", optionsData )
  PB.QOLMenu( optionsData )
  
  LAM:RegisterOptionControls("PixelBootyOptions", optionsData)

end