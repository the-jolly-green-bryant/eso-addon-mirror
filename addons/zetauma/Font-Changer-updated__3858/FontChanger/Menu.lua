local FC = assert(FontChanger, "FontChanger global table not found — check load order in FontChanger.txt")
local LAM2 = LibAddonMenu2

function FC:InitializeAddonMenu()
	local panelData = {
		type = "panel",
		name = "FontChanger",
		displayName = "|c4B8BFEFont Changer|r",
		author = "|c4B8BFEFerrety|r, |cFF1493Antisenil|r, |c9966ffzetauma|r",
		version = self.version,
		slashCommand = "/fc",
		registerForRefresh = true,
		registerForDefaults = true
	}

	-- Build merged font lists (copies to avoid mutating the constant arrays)
	local fontChoices = {}
	local fontValues = {}
	for i, v in ipairs(FC.DEFAULT_FONT_CHOICES) do
		fontChoices[i] = v
		fontValues[i] = FC.DEFAULT_FONT_VALUES[i]
	end
	for _, v in ipairs(FC.CUSTOM_FONT_CHOICES) do
		table.insert(fontChoices, v)
	end
	for _, v in ipairs(FC.CUSTOM_FONT_VALUES) do
		table.insert(fontValues, v)
	end

	-- Shared apply callbacks
	local function applyUI() self:SetUIFonts() end
	local function applyNameplate() self:SetNameplateFont(self.SV.nameplate_style, self.SV.nameplate_size) end
	local function applySCT() self:SetSCTFont(self.SV.sct_style, self.SV.sct_size) end
	local function applyChat() self:ChangeChatFonts() end

	-- Helper to build a LAM2 dropdown from a saved-variable key
	local function dropdown(svKey, name, tooltip, choices, choicesValues, applyFunc, opts)
		opts = opts or {}
		return {
			type = "dropdown",
			name = name,
			choices = choices,
			choicesValues = choicesValues,
			tooltip = tooltip,
			getFunc = function() return self.SV[svKey] end,
			setFunc = function(value)
				self.SV[svKey] = value
				applyFunc()
			end,
			default = self.defaults[svKey],
			warning = opts.warning,
			scrollable = opts.scrollable ~= false,
			disabled = opts.disabled,
		}
	end

	-- Helper to build a LAM2 slider from a saved-variable key
	local function slider(svKey, name, tooltip, applyFunc, opts)
		opts = opts or {}
		return {
			type = "slider",
			name = name,
			tooltip = tooltip,
			min = opts.min or 0.1,
			max = opts.max or 2,
			step = opts.step or 0.1,
			decimals = opts.decimals or 1,
			getFunc = function() return self.SV[svKey] end,
			setFunc = function(value)
				self.SV[svKey] = value
				applyFunc()
			end,
			default = self.defaults[svKey],
			warning = opts.warning,
			disabled = opts.disabled,
		}
	end

	local RELOAD = { warning = "Reload UI Required." }
	local NO_SCROLL = { scrollable = false }
	local loreDisabled = function() return not self.SV.lore_fonts_enabled end
	local LORE_WARN = { warning = "Takes effect on next book open. Reload UI for full effect.", disabled = loreDisabled }
	local LORE_SLIDER = { warning = "Takes effect on next book open. Reload UI for full effect.", disabled = loreDisabled }

	local optionsData = {
		-- Menu/UI --
		{ type = "header", name = "Menu/UI" },
		dropdown("menu_font", "UI Font",
			"Changes normal font, mostly used in descriptions (mouseover texts) and in the eso settings menu.",
			fontChoices, fontValues, applyUI, RELOAD),
		slider("menu_font_scale", "UI Font Scale",
			"Changes the size for normal font, mostly used in descriptions (mouseover texts) and in the eso settings menu.",
			applyUI, RELOAD),
		dropdown("menu_bold_font", "UI Bold Font",
			"Changes the bold font, most texts in ESO use this font.",
			fontChoices, fontValues, applyUI, RELOAD),
		slider("menu_bold_font_scale", "UI Bold Font Scale",
			"Changes the size for bold font, most texts in ESO use this font.",
			applyUI, RELOAD),
		dropdown("menu_style", "UI Font Style",
			"Changes the style of UI fonts.",
			FC.UI_FONTSTYLE_CHOICES, FC.UI_FONTSTYLE_VALUES, applyUI, { warning = "Reload UI Required.", scrollable = false }),

		-- Books / Letters / Tablets --
		{ type = "header", name = "BOOKS / LETTERS / TABLETS" },
		{
			type = "checkbox",
			name = "Enable Lore Font Replacement",
			tooltip = "When enabled, books, letters, and stone tablets use the fonts selected below. When disabled, vanilla fonts are used.",
			default = self.defaults.lore_fonts_enabled,
			warning = "Reload UI Required.",
			getFunc = function() return self.SV.lore_fonts_enabled end,
			setFunc = function(value) self.SV.lore_fonts_enabled = value end,
		},
		{
			type = "submenu",
			name = "Lore Font Settings",
			controls = {
				dropdown("book_font", "Book Font",
					"Changes the font used for books.",
					fontChoices, fontValues, applyUI, LORE_WARN),
				slider("book_font_scale", "Book Font Scale",
					"Changes the text size of books.",
					applyUI, LORE_SLIDER),
				dropdown("letter_font", "Letter Font",
					"Changes the font used for letters and handwritten notes.",
					fontChoices, fontValues, applyUI, LORE_WARN),
				slider("letter_font_scale", "Letter Font Scale",
					"Changes the text size of letters and handwritten notes.",
					applyUI, LORE_SLIDER),
				dropdown("tablet_font", "Tablet Font",
					"Changes the font used for stone tablets.",
					fontChoices, fontValues, applyUI, LORE_WARN),
				slider("tablet_font_scale", "Tablet Font Scale",
					"Changes the text size of stone tablets.",
					applyUI, LORE_SLIDER),
			},
		},

		-- Nameplates --
		{ type = "header", name = "Nameplates" },
		dropdown("nameplate_font", "Nameplate Font",
			"Changes the font for all nameplates.",
			fontChoices, fontValues, applyNameplate),
		dropdown("nameplate_size", "Nameplate Font Size",
			"Changes the size of all nameplates.",
			FC.FONTSIZE_CHOICES, FC.FONTSIZE_VALUES, applyNameplate),
		dropdown("nameplate_style", "Nameplate Font Style",
			"Changes the style of nameplates.",
			FC.FONTSTYLE_CHOICES, FC.FONTSTYLE_VALUES, applyNameplate, NO_SCROLL),

		-- Scrolling Combat Text --
		{ type = "header", name = "Scrolling Combat Text (SCT)" },
		dropdown("sct_font", "SCT Font",
			"Changes the font of scrolling combat text (SCT).",
			fontChoices, fontValues, applySCT),
		dropdown("sct_size", "SCT Font Size",
			"Changes the size of scrolling combat text (SCT).",
			FC.FONTSIZE_CHOICES, FC.FONTSIZE_VALUES, applySCT),
		dropdown("sct_style", "SCT Font Style",
			"Changes the style of SCT.",
			FC.FONTSTYLE_CHOICES, FC.FONTSTYLE_VALUES, applySCT, NO_SCROLL),

		-- Chat --
		{ type = "header", name = "Chat" },
		dropdown("chat_font", "Chat Font",
			"Changes the font of the chat window.",
			fontChoices, fontValues, applyChat),
		dropdown("chat_style", "Chat Font Style",
			"Changes the style of chat font.",
			FC.FONTWEIGHT_CHOICES, FC.FONTWEIGHT_VALUES, applyChat, NO_SCROLL),

		-- Utilities --
		{ type = "header", name = "Utilities" },
		{
			type = "button",
			name = "Restore Vanilla Nameplate & SCT Fonts",
			tooltip = "Resets nameplate and scrolling combat text fonts to the game defaults that were active before FontChanger was installed. Use this before disabling the addon, as these settings persist in the game even without the addon.",
			func = function() self:RestoreVanillaFonts() end,
		},

		-- Gamepad Mode --
		{ type = "header", name = "Gamepad Mode" },
		{
			type = "checkbox",
			name = "Enable for Gamepad mode",
			tooltip = "Enables the font settings when in Gamepad mode.",
			default = self.defaults.gamepad_fonts_enabled,
			getFunc = function() return self.SV.gamepad_fonts_enabled end,
			setFunc = function(value) self.SV.gamepad_fonts_enabled = value end,
		},
	}

	LAM2:RegisterAddonPanel("FontChangerAddonOptions", panelData)
	LAM2:RegisterOptionControls("FontChangerAddonOptions", optionsData)
end
