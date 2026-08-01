local ISL = ItemSaverLite

local LAM = LibAddonMenu2

function ISL.CreateSettingsMenu()
    local ANCHOR_OPTIONS = {
        "Top Left", "Top", "Top Right",
        "Right", "Bottom Right", "Bottom",
        "Bottom Left", "Left", "Center"
    }

    local markerTexturePaths, markerTextureNames = ISL.GetMarkerTextureArrays()

    local optionsData = {
        { type = "header", name = "Appearance" },
		{
			type = "dropdown", name = "Marker Texture", tooltip = "Icon style for your markers.", choices = markerTextureNames, width = "half",
			getFunc = function() return ISL.SV.markerTexture end,
			setFunc = function(value) ISL.SV.markerTexture = value; ISL.RefreshAll() end,
		},
		{
			type = "colorpicker", name = "Marker Color", tooltip = "The color tint applied to the marker icon.", width = "half",
			getFunc = function() return ISL.HexToRGB(ISL.SV.markerColor) end,
			setFunc = function(r, g, b) ISL.SV.markerColor = ISL.RGBToHex(r, g, b); ISL.RefreshAll() end,
		},
		{
			type = "dropdown", name = "Marker Position", tooltip = "Position of the saved item marker.", choices = ANCHOR_OPTIONS, width = "half",
			getFunc = function() return ANCHOR_OPTIONS[ISL.SV.markerAnchor] or ANCHOR_OPTIONS[1] end,
			setFunc = function(value)
				for i, option in ipairs(ANCHOR_OPTIONS) do
					if option == value then ISL.SV.markerAnchor = i break end
				end
				ISL.RefreshAll()
			end,
		},
		{
			type = "slider", name = "Marker Scale", tooltip = "Size modifier for the texture marker overlay.", min = 0.2, max = 2.0, step = 0.1, width = "half",
			getFunc = function() return ISL.SV.markerScale or 0.6 end,
			setFunc = function(value) ISL.SV.markerScale = value; ISL.RefreshAll() end,
		},
		{
			type = "slider", name = "Custom Horizontal Offset", tooltip = "Add an additional offset to the marker's horizontal position.", min = -10, max = 10, step = 1, width = "half",
			getFunc = function() return ISL.SV.offsetX or 0 end,
			setFunc = function(value) ISL.SV.offsetX = value; ISL.RefreshAll() end,
		},
		{
			type = "slider", name = "Custom Vertical Offset", tooltip = "Add an additional offset to the marker's vertical position.", min = -10, max = 10, step = 1, width = "half",
			getFunc = function() return ISL.SV.offsetY or 0 end,
			setFunc = function(value) ISL.SV.offsetY = value; ISL.RefreshAll() end,
		},
		
		{ type = "header", name = "General Settings" },
		{
			type = "checkbox",
			name = "Enable Context Menu Options",
			tooltip = "Show 'Save Item' / 'Unlock' option in the right‑click context menu.",
			getFunc = function() return ISL.SV.enableContextMenu end,
			setFunc = function(value) ISL.SV.enableContextMenu = value end,
			requiresReload = true,
		},		
		
        { type = "header", name = "Hide Marked Items From" },
        {
            type = "checkbox", name = "Vendor", tooltip = "Should saved items be removed from the store selling context lists?", width = "half",
            getFunc = function() return ISL.SV.filterStore end,
            setFunc = function(value) ISL.SV.filterStore = value; ISL.ToggleFilter("VendorSell", LF_VENDOR_SELL) end,
        },
        {
            type = "checkbox", name = "Deconstruction", tooltip = "Should saved items be removed from deconstruction tables?", width = "half",
            getFunc = function() return ISL.SV.filterDeconstruction end,
            setFunc = function(value)
                ISL.SV.filterDeconstruction = value
                ISL.ToggleFilter("SmithingDeconstruct", LF_SMITHING_DECONSTRUCT)
                ISL.ToggleFilter("JewelryDeconstruct", LF_JEWELRY_DECONSTRUCT)
            end,
        },
        {
            type = "checkbox", name = "Research", tooltip = "Should saved items be protected from trade-in research menus?", width = "half",
            getFunc = function() return ISL.SV.filterResearch end,
            setFunc = function(value)
                ISL.SV.filterResearch = value
                ISL.ToggleFilter("SmithingResearch", LF_SMITHING_RESEARCH)
                ISL.ToggleFilter("JewelryResearch", LF_JEWELRY_RESEARCH)
            end,
        },
        {
            type = "checkbox", name = "Guild Store", tooltip = "Should saved items be removed from the guild store sell tab?", width = "half",
            getFunc = function() return ISL.SV.filterGuildStore end,
            setFunc = function(value) ISL.SV.filterGuildStore = value; ISL.ToggleFilter("GuildStoreSell", LF_GUILDSTORE_SELL) end,
        },
        {
            type = "checkbox", name = "Mail", tooltip = "Should saved items be removed from the mail attachment list?", width = "half",
            getFunc = function() return ISL.SV.filterMail end,
            setFunc = function(value) ISL.SV.filterMail = value; ISL.ToggleFilter("MailSend", LF_MAIL_SEND) end,
        },
        {
            type = "checkbox", name = "Trade", tooltip = "Should saved items be removed from the trade list?", width = "half",
            getFunc = function() return ISL.SV.filterTrade end,
            setFunc = function(value) ISL.SV.filterTrade = value; ISL.ToggleFilter("Trade", LF_TRADE) end,
        },
    }

    LAM:RegisterAddonPanel("ItemSaverLiteSettingsPanel", { type = "panel", name = "|cFFD700Item Saver Lite|r", author = "|cFFD700@Atharti|r" })
    LAM:RegisterOptionControls("ItemSaverLiteSettingsPanel", optionsData)
end