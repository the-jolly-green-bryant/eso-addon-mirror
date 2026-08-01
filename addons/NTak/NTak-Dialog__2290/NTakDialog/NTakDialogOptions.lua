local NTakDialog	= NTDial
local ADDON_NAME	= "NTakDialog"
local texts			= NTDial_Texts
local icons			= NTakDialog.icons


------------------------------------------
--		INITIALIZATIONS

local left		= texts.choicesAlign[1]
local center	= texts.choicesAlign[2]
local right		= texts.choicesAlign[3]


------------------------------------------
--		SETTINGS

local LAM2 = LibAddonMenu2
function NTDial.InitSettings()
	--	Usefull
	local function Titler(text)
		return ZO_HIGHLIGHT_TEXT:Colorize(zo_strformat("<<Z:1>>", text))
	end
	local function IsNeeded(text)
		return "“" .. text .. "”" .. texts.isNeeded
	end
	local SUBDIVIDER = {
		type = "divider",
		alpha = 0.33,
		width = "half",
	}
	local SPACER = {
		type = "description",
		title = nil,
		text = " ",
	}
	
	local panelData = {
		type = "panel",
		name = "N'Tak' Dialog",
		displayName = "N'|c887788Tak'|r Dialog",
		author = "N'|c887788Tak'|r",
		version = "1.12.5",
		slashCommand = "/ntdial",
		website = "https://www.esoui.com/portal.php?id=285&a=list",
		registerForRefresh = true,
		registerForDefaults = true,
	}

	local options =
	{
		{ -- ACCOUNT WIDE
			type = "checkbox",
			name = Titler(texts.cat00.title),
			getFunc = function()
				return NTakDialog_SavedVariables.Default[GetDisplayName()][GetCurrentCharacterId()]["Settings"]["accountWide"]
			end,
			setFunc = function(value)
				NTakDialog_SavedVariables.Default[GetDisplayName()][GetCurrentCharacterId()]["Settings"]["accountWide"] = value
				-- zo_callLater(function() ReloadUI() end, 200)
			end,
			requiresReload = true,
			width = "full",
		},
		{ -- GAMEPAD MODE
			type = "checkbox",
			name = Titler("Gamepad mode (BETA)"),
			getFunc = function() return NTakDialog.settings.gamepad end,
			setFunc = function(value)
				NTakDialog.settings.gamepad = value
				-- zo_callLater(function() ReloadUI() end, 200)
			end,
			requiresReload = true,
			width = "full",
			default = false,
		},
		SPACER,
		{ -- HISTORY
			type = "submenu",
			name = icons["History"] .. " " .. Titler(texts.cat0.title),
			width = "full",
			controls = {
				{ -- Enable
					type = "checkbox",
					name = texts.cat0.opt0,
					getFunc = function() return NTakDialog.settings.chatHistory end,
					setFunc = function(value) NTakDialog.settings.chatHistory = value end,
					width = "full",
					default = false,
				},
				{ -- Enable
					type = "checkbox",
					name = texts.cat0.opt0b,
					getFunc = function() return NTakDialog.settings.chatLastReply end,
					setFunc = function(value) NTakDialog.settings.chatLastReply = value end,
					width = "full",
					disabled = function() return not(NTakDialog.settings.chatHistory) end,
					default = false,
				},
				{ -- Expand as text appears
					type = "checkbox",
					name = texts.cat3.opt21,
					getFunc = function() return NTakDialog.settings.textFadeExpand end,
					setFunc = function(value) NTakDialog.settings.textFadeExpand = value end,
					width = "full",
					default = false,
					warning = IsNeeded(texts.cat3.opt20),
					disabled = function() return
						not(NTakDialog.settings.chatHistory) or
						not(NTakDialog.settings.textFadeIn)
					end,
				},
        		-- SUBDIVIDER,
				{ -- Prefix styling
					type = "editbox",
					name = texts.cat0.opt1,
					getFunc = function() return NTakDialog.settings.chatOptionPrefix end,
					setFunc = function(value)
						NTakDialog.settings.chatOptionPrefix = value
						NTDial.InitDialogs()
					end,
					width = "full",
					disabled = function() return not(NTakDialog.settings.chatHistory) end,
					default = "> ",
				},
				-- { -- Styling description
					-- type = "description",
					-- title = nil,
					-- text = texts.cat4.desc22 .. "“> ”, “- ”, “~ ”, “x)”, “[x]”, “x ~”, …",
					-- width = "full",
					-- disabled = function() return not(NTakDialog.settings.chatHistory) end,
					-- -- warning = IsNeeded(texts.cat4.opt21),
				-- },
        		-- SUBDIVIDER,
				-- { -- Names
					-- type = "checkbox",
					-- name = texts.cat0.opt2,
					-- getFunc = function() return NTakDialog.settings.chatNames end,
					-- setFunc = function(value) NTakDialog.settings.chatNames = value end,
					-- width = "full",
					-- disabled = function() return not(NTakDialog.settings.chatHistory) end,
					-- default = false,
				-- },
				-- { -- Names on new lines
					-- type = "checkbox",
					-- name = texts.cat0.opt2,
					-- getFunc = function() return NTakDialog.settings.chatNamesCR end,
					-- setFunc = function(value) NTakDialog.settings.chatNamesCR = value end,
					-- width = "full",
					-- disabled = function() return
							-- not(NTakDialog.settings.chatHistory) or
							-- not(NTakDialog.settings.chatNames)
					-- end,
					-- default = false,
				-- },
				SUBDIVIDER,
				{ -- Enable
					type = "checkbox",
					name = texts.cat0.optA,
					getFunc = function() return NTakDialog.settings.chatOutput end,
					setFunc = function(value) NTakDialog.settings.chatOutput = value end,
					width = "full",
					default = false,
				},
			},
		},
		{ -- WINDOW TWEAKS
			type = "submenu",
			name = icons["Chat"] .. " " .. Titler(texts.cat1.title),
			width = "full",
			controls = {
				{ -- Centerize
					type = "checkbox",
					name = "Centerize (BETA)", --texts.cat1.opt1,
					getFunc = function() return NTakDialog.settings.windowCenterize end,
					setFunc = function(value)
						NTakDialog.settings.windowCenterize = value
						zo_callLater(function() ReloadUI() end, 200)
						-- NTDial.InitDialogs()
					end,
					warning = texts.cat1.warn1,
					width = "full",
					default = false,
				},
				{ -- Height
					type = "slider",
					name = texts.cat1.opt4,
					tooltip = nil,
					min = -40,
					step = 1,
					max = 40,
					getFunc = function() return NTakDialog.settings.windowVerticalPosition * 100 end,
					setFunc = function(value)
						NTakDialog.settings.windowVerticalPosition = value / 100
						NTDial.InitDialogs()
					end,
					width = "full",
					default = 0,
				},
				{ -- Resize
					type = "checkbox",
					name = texts.cat1.opt1,
					getFunc = function() return NTakDialog.settings.windowResize end,
					setFunc = function(value)
						NTakDialog.settings.windowResize = value
						if value == false then
							zo_callLater(function() ReloadUI() end, 200)
						end
						NTDial.InitDialogs()
					end,
					warning = texts.cat1.warn1,
					width = "full",
					default = false,
				},
				{ -- Width
					type = "slider",
					name = texts.cat1.opt2,
					tooltip = nil,
					min = 20,
					step = 1,
					max = 100,
					getFunc = function() return NTakDialog.settings.windowWidth * 100 end,
					setFunc = function(value)
						NTakDialog.settings.windowWidth = value / 100
						NTDial.InitDialogs()
					end,
					width = "full",
					disabled = function() return not(NTakDialog.settings.windowResize) end,
					default = 45,
				},
				{ -- Height
					type = "slider",
					name = texts.cat1.opt3,
					tooltip = nil,
					min = 0,
					step = 1,
					max = 100,
					getFunc = function() return NTakDialog.settings.windowHeight * 100 end,
					setFunc = function(value)
						NTakDialog.settings.windowHeight = value / 100
						NTDial.InitDialogs()
					end,
					width = "full",
					disabled = function() return not(NTakDialog.settings.windowResize) end,
					default = 30,
				},
				SUBDIVIDER,
				{ -- Paddings
					type = "checkbox",
					name = texts.cat1.opt10,
					getFunc = function() return NTakDialog.settings.windowPaddings end,
					setFunc = function(value)
						NTakDialog.settings.windowPaddings = value
						NTDial.InitDialogs()
					end,
					width = "full",
					default = false,
				},
				{ -- Automatic padding
					type = "checkbox",
					name = texts.cat1.opt11,
					getFunc = function() return NTakDialog.settings.windowPaddingAuto end,
					setFunc = function(value)
						NTakDialog.settings.windowPaddingAuto = value
						NTDial.InitDialogs()
					end,
					width = "full",
					disabled = function() return not(NTakDialog.settings.windowPaddings) end,
					default = false,
				},
				{ -- Padding left
					type = "slider",
					name = texts.cat1.opt12,
					tooltip = nil,
					min = 0,
					step = 1,
					max = 100,
					getFunc = function() return NTakDialog.settings.windowPaddingLeft end,
					setFunc = function(value)
						NTakDialog.settings.windowPaddingLeft = value
						NTDial.InitDialogs()
					end,
					width = "full",
					disabled = function() return
						not(NTakDialog.settings.windowPaddings)
						or NTakDialog.settings.windowPaddingAuto
					end,
					default = 10,
				},
				{ -- Padding right
					type = "slider",
					name = texts.cat1.opt13,
					tooltip = nil,
					min = 0,
					step = 1,
					max = 100,
					getFunc = function() return NTakDialog.settings.windowPaddingRight end,
					setFunc = function(value)
						NTakDialog.settings.windowPaddingRight = value
						NTDial.InitDialogs()
					end,
					width = "full",
					disabled = function() return
						not(NTakDialog.settings.windowPaddings)
						or NTakDialog.settings.windowPaddingAuto
					end,
					default = 30,
				},
				SUBDIVIDER,
				{ -- Background transparency
					type = "slider",
					name = texts.cat1.opt21,
					tooltip = nil,
					min = 0,
					step = 1,
					max = 100,
					getFunc = function() return NTakDialog.settings.windowBkgTransparency * 100 end,
					setFunc = function(value)
						NTakDialog.settings.windowBkgTransparency = value / 100
						NTDial.InitDialogs()
					end,
					width = "full",
					default = 0,
				},
				{ -- Content transparency
					type = "slider",
					name = texts.cat1.opt22,
					tooltip = nil,
					min = 0,
					step = 1,
					max = 99,
					getFunc = function() return NTakDialog.settings.windowContentTransparency * 100 end,
					setFunc = function(value)
						NTakDialog.settings.windowContentTransparency = value / 100
						NTDial.InitDialogs()
					end,
					width = "full",
					default = 0,
				},
			},
			disabled = function() return NTakDialog.settings.gamepad end,
		},
		{ -- TITLE TWEAKS
			type = "submenu",
			name = icons["Title"] .. " " .. Titler(texts.cat2.title),
			width = "full",
			controls = {
				{ -- Text size
					type = "slider",
					name = texts.catX.optTextSize,
					min = -2,
					step = 1,
					max = 2,
					getFunc = function() return NTakDialog.settings.titleSize end,
					setFunc = function(value)
						NTakDialog.settings.titleSize = value
						NTDial.InitDialogs()
					end,
					width = "full",
					default = 1,
				},
				{ -- Alignment
					type = "dropdown",
					name = texts.catX.optAlignH,
					choices = texts.choicesAlign,
					getFunc = function() return
						texts.choicesAlign[NTakDialog.settings.titleAlign]
					end,
					setFunc = function(value)
						if value == texts.choicesAlign[1]	then NTakDialog.settings.titleAlign = 1 end
						if value == texts.choicesAlign[2]	then NTakDialog.settings.titleAlign = 2 end
						if value == texts.choicesAlign[3]	then NTakDialog.settings.titleAlign = 3 end
						NTDial.InitDialogs()
					end,
					width = "full",
					default = left,
				},
				{ -- Padding
					type = "slider",
					name = texts.catX.optPaddingH,
					min = 0,
					step = 1,
					max = 200,
					getFunc = function() return NTakDialog.settings.titlePadding end,
					setFunc = function(value)
						NTakDialog.settings.titlePadding = value
					end,
					width = "full",
					disabled =  function() return NTakDialog.settings.titleAlign == 2 end,
					default = 0,
				},
				SUBDIVIDER, -- Text hidden
				{ -- Clean title
					type = "checkbox",
					name = texts.cat2.opt4,
					getFunc = function() return NTakDialog.settings.titleClean end,
					setFunc = function(value)
						NTakDialog.settings.titleClean = value
					end,
					width = "full",
					default = true,
				},
				{ -- Alternative color
					type = "checkbox",
					name = texts.cat2.opt5 .. ZO_HIGHLIGHT_TEXT:Colorize("   [Abc]"),
					getFunc = function() return NTakDialog.settings.titleColorAlt end,
					setFunc = function(value)
						NTakDialog.settings.titleColorAlt = value
					end,
					width = "full",
					default = true,
				},
			},
		},
		{ -- TEXT TWEAKS
			type = "submenu",
			name = icons["Text"] .. " " .. Titler(texts.cat3.title),
			width = "full",
			controls = {
				{ -- Text size
					type = "slider",
					name = texts.catX.optTextSize,
					min = -2,
					step = 1,
					max = 2,
					getFunc = function() return NTakDialog.settings.textSize end,
					setFunc = function(value)
						NTakDialog.settings.textSize = value
						NTDial.InitDialogs()
					end,
					width = "full",
					default = 0,
				},
				{ -- Alignment
					type = "dropdown",
					name = texts.catX.optAlignH,
					choices = texts.choicesAlign,
					getFunc = function() return
						texts.choicesAlign[NTakDialog.settings.textAlign]
					end,
					setFunc = function(value)
						if value == texts.choicesAlign[1]	then NTakDialog.settings.textAlign = 1 end
						if value == texts.choicesAlign[2]	then NTakDialog.settings.textAlign = 2 end
						if value == texts.choicesAlign[3]	then NTakDialog.settings.textAlign = 3 end
						NTDial.InitDialogs()
					end,
					width = "full",
					default = left,
				},
				SUBDIVIDER, -- Text hidden
				{ -- Hide
					type = "checkbox",
					name = texts.cat3.opt11,
					getFunc = function() return NTakDialog.settings.textHide end,
					setFunc = function(value)
						NTakDialog.settings.textHide = value
						if value then NTakDialog.settings.textFadeIn = false end
						NTDial.InitDialogs()
					end,
					width = "full",
					default = false,
				},
				{ -- Use same delays as fading text
					type = "checkbox",
					name = texts.cat3.opt12 .. "“" .. texts.cat3.opt20 .. "”",
					getFunc = function() return NTakDialog.settings.textHideSameDelays end,
					setFunc = function(value)
						NTakDialog.settings.textHideSameDelays = value
						NTDial.InitDialogs()
					end,
					width = "full",
					default = false,
					disabled = function() return not(NTakDialog.settings.textHide) end,
				},
				SUBDIVIDER,	-- Text fading
				{ -- Fade-in text
					type = "checkbox",
					name = texts.cat3.opt20,
					getFunc = function() return NTakDialog.settings.textFadeIn end,
					setFunc = function(value)
						NTakDialog.settings.textFadeIn = value
						if value then NTakDialog.settings.textHide = false end
						NTDial.InitDialogs()
					end,
					width = "full",
					default = false,
				},
				{ -- Expand as text appears
					type = "checkbox",
					name = texts.cat3.opt21,
					getFunc = function() return NTakDialog.settings.textFadeExpand end,
					setFunc = function(value) NTakDialog.settings.textFadeExpand = value end,
					width = "full",
					default = false,
					disabled = function() return not(NTakDialog.settings.textFadeIn) end,
				},
				{ -- Fade-in start delay
					type = "slider",
					name = texts.cat3.opt22,
					min = 0,
					step = 1,
					max = 1000,
					getFunc = function() return NTakDialog.settings.textFadeDelay end,
					setFunc = function(value) NTakDialog.settings.textFadeDelay = value end,
					width = "full",
					default = 200,
					disabled = function() return
						not(NTakDialog.settings.textFadeIn) and
						not(NTakDialog.settings.textHide and NTakDialog.settings.textHideSameDelays)
					end,
				},
				{ -- Fade-in delay per letter
					type = "slider",
					name = texts.cat3.opt23,
					min = 1,
					step = 1,
					max = 50,
					getFunc = function() return NTakDialog.settings.textFadeDelta end,
					setFunc = function(value) NTakDialog.settings.textFadeDelta = value end,
					width = "full",
					default = 22,
					disabled = function() return
						not(NTakDialog.settings.textFadeIn) and
						not(NTakDialog.settings.textHide and NTakDialog.settings.textHideSameDelays)
					end,
				},
				{ -- Fade-in extent on letters
					type = "slider",
					name = texts.cat3.opt24,
					min = 1,
					step = 1,
					max = 50,
					getFunc = function() return NTakDialog.settings.textFadeExtent end,
					setFunc = function(value) NTakDialog.settings.textFadeExtent = value end,
					width = "full",
					default = 10,
					disabled = function() return not(NTakDialog.settings.textFadeIn) end,
				},
				{ -- Display on key press
					type = "checkbox",
					name = texts.cat3.opt25,
					getFunc = function() return NTakDialog.settings.textFadeShowOnPress end,
					setFunc = function(value) NTakDialog.settings.textFadeShowOnPress = value end,
					width = "full",
					default = true,
					disabled = function() return not(NTakDialog.settings.textFadeIn) end,
				},
				-- SUBDIVIDER,	-- Chat history
				-- { -- History
					-- type = "checkbox",
					-- name = "BETA: Display text history", -- texts.cat3.opt25,
					-- getFunc = function() return NTakDialog.settings.chatHistory end,
					-- setFunc = function(value)
						-- NTakDialog.settings.chatHistory = value
					-- end,
					-- width = "full",
					-- default = true,
				-- },				
			},
		},
		{ -- OPTIONS TWEAKS
			type = "submenu",
			name = icons["Options"] .. " " .. Titler(texts.cat4.title),
			width = "full",
			controls = {
				{ -- Text size
					type = "slider",
					name = texts.catX.optTextSize,
					min = -2,
					step = 1,
					max = 2,
					getFunc = function() return NTakDialog.settings.optionSize end,
					setFunc = function(value)
						NTakDialog.settings.optionSize = value
						NTDial.InitDialogs()
					end,
					width = "full",
					default = 0,
				},
				{ -- Alignment
					type = "dropdown",
					name = texts.catX.optAlignH,
					choices = texts.choicesAlign,
					getFunc = function() return
						texts.choicesAlign[NTakDialog.settings.optionAlign]
					end,
					setFunc = function(value)
						if value == texts.choicesAlign[1]	then NTakDialog.settings.optionAlign = 1 end
						if value == texts.choicesAlign[2]	then NTakDialog.settings.optionAlign = 2 end
						if value == texts.choicesAlign[3]	then NTakDialog.settings.optionAlign = 3 end
						NTDial.InitDialogs()
					end,
					width = "full",
					default = left,
				},
				{ -- Option height
					type = "slider",
					name = texts.catX.optPaddingV,
					min = 0,
					step = 1,
					max = 20,
					getFunc = function() return NTakDialog.settings.optionHeightInc / 2 end,
					setFunc = function(value)
						NTakDialog.settings.optionHeightInc = value * 2
						NTDial.InitDialogs()
					end,
					width = "full",
					default = 2,
				},
				SUBDIVIDER,
				{ -- Show instantly
					type = "checkbox",
					name = texts.cat4.optA,
					getFunc = function() return NTakDialog.settings.optionShowDirect end,
					setFunc = function(value)
						NTakDialog.settings.optionShowDirect 	= value
						NTakDialog.settings.optionShowAfterText = not(value)
						NTakDialog.settings.optionShowOnPress	= not(value)
					end,
					width = "full",
					default = false,
				},
				{ -- Show after text fade-in
					type = "checkbox",
					name = texts.cat4.optB,
					getFunc = function() return NTakDialog.settings.optionShowAfterText end,
					setFunc = function(value)
						NTakDialog.settings.optionShowAfterText = value
						if not(NTakDialog.settings.optionShowAfterText
							or NTakDialog.settings.optionShowOnPress)
						then
							NTakDialog.settings.optionShowDirect = true
						end
					end,
					width = "full",
					default = true,
					disabled = function() return (NTakDialog.settings.optionShowDirect) end,
				},
				{ -- Show on key press
					type = "checkbox",
					name = texts.cat4.optC,
					getFunc = function() return NTakDialog.settings.optionShowOnPress end,
					setFunc = function(value)
						NTakDialog.settings.optionShowOnPress = value
						if not(NTakDialog.settings.optionShowAfterText
							or NTakDialog.settings.optionShowOnPress)
						then
							NTakDialog.settings.optionShowDirect = true
						end
					end,
					width = "full",
					default = true,
					disabled = function() return (NTakDialog.settings.optionShowDirect) end,
				},
				{ -- Fading time
					type = "slider",
					name = texts.cat4.optD,
					min = 0,
					step = 1,
					max = 500,
					getFunc = function() return NTakDialog.settings.optionFadeTime end,
					setFunc = function(value) NTakDialog.settings.optionFadeTime = value end,
					width = "full",
					default = 200,
					disabled = function() return (NTakDialog.settings.optionShowDirect) end,
				},
				SUBDIVIDER,
				{ -- Repeat
					type = "checkbox",
					name = texts.cat4.optR0,
					getFunc = function() return NTakDialog.settings.optionAddRepeat end,
					setFunc = function(value)
						NTakDialog.settings.optionAddRepeat = value
					end,
					width = "full",
					default = false,
					warning = texts.cat4.warnR0,
				},
				{ -- Grey repeat
					type = "checkbox",
					name = texts.cat4.optR1,
					getFunc = function() return NTakDialog.settings.optionGreyRepeat end,
					setFunc = function(value)
						NTakDialog.settings.optionGreyRepeat = value
					end,
					width = "full",
					default = true,
					disabled = function() return not(NTakDialog.settings.optionAddRepeat) end,
				},
				{ -- Grey goodbye
					type = "checkbox",
					name = texts.cat4.opt4,
					getFunc = function() return NTakDialog.settings.optionGreyBye end,
					setFunc = function(value)
						NTakDialog.settings.optionGreyBye = value
					end,
					width = "full",
					default = true,
				},
				SUBDIVIDER,
				{ -- Icons
					type = "checkbox",
					name = texts.cat4.opt11,
					getFunc = function() return NTakDialog.settings.optionIcons end,
					setFunc = function(value)
						NTakDialog.settings.optionIcons = value
					end,
					width = "full",
					-- tooltip = NTakDialog.iconsTooltip,
					default = true,
				},
				{ -- Icons preview
					type = "description",
					title = nil,
					text = texts.cat4.desc11 .. "\n" .. NTakDialog.iconsTooltip,
					width = "full",
					disabled = function() return not(NTakDialog.settings.optionIcons) end,
				},
				{ -- Spaces after icons
					type = "slider",
					name = texts.cat4.opt12,
					min = 0,
					step = 1,
					max = 4,
					getFunc = function() return NTakDialog.settings.optionIconsSpace end,
					setFunc = function(value)
						NTakDialog.settings.optionIconsSpace = value
						NTDial.InitDialogs()
					end,
					width = "full",
					disabled = function() return not(NTakDialog.settings.optionIcons) end,
					default = 2,
				},
				SUBDIVIDER,
				{ -- Numbers
					type = "checkbox",
					name = texts.cat4.opt21,
					getFunc = function() return NTakDialog.settings.optionNumbers end,
					setFunc = function(value)
						NTakDialog.settings.optionNumbers = value
						NTDial.InitDialogs()
					end,
					width = "full",
					default = true,
				},
				{ -- Styling
					type = "editbox",
					name = texts.cat4.opt22,
					getFunc = function() return NTakDialog.settings.optionNumberStyling end,
					setFunc = function(value)
						NTakDialog.settings.optionNumberStyling = value
						NTDial.InitDialogs()
					end,
					width = "full",
					disabled = function() return not(NTakDialog.settings.optionNumbers) end,
					default = "x)",
				},
				{ -- Styling description
					type = "description",
					title = nil,
					text = texts.cat4.desc22 .. "“x)”, “[x]”, “x ~”, …",
					width = "full",
					disabled = function() return not(NTakDialog.settings.optionNumbers) end,
				},
				{ -- Spaces after styling
					type = "slider",
					name = texts.cat4.opt23,
					min = 0,
					step = 1,
					max = 4,
					getFunc = function() return NTakDialog.settings.optionNumberSpace end,
					setFunc = function(value)
						NTakDialog.settings.optionNumberSpace = value
						NTDial.InitDialogs()
					end,
					width = "full",
					disabled = function() return not(NTakDialog.settings.optionNumbers) end,
					default = 2,
				},
				SUBDIVIDER,				
				{ -- Options transparency
					type = "slider",
					name = texts.cat4.opt31,
					tooltip = nil,
					min = 0,
					step = 1,
					max = 99,
					getFunc = function() return NTakDialog.settings.optionTransparency * 100 end,
					setFunc = function(value)
						NTakDialog.settings.optionTransparency = value / 100
						NTDial.InitDialogs()
					end,
					width = "full",
					default = 0,
				},
			},
		},
		{ -- HIGHLIGHT TWEAKS
			type = "submenu",
			name = icons["Hover"] .. " " .. Titler(texts.cat5.title),
			width = "full",
			controls = {
				{ -- Borders width
					type = "slider",
					name = texts.cat5.opt1,
					tooltip = nil,
					min = 0,
					step = 1,
					max = 10,
					getFunc = function() return NTakDialog.settings.HLBordersWidth end,
					setFunc = function(value)
						NTakDialog.settings.HLBordersWidth = value
						NTDial.InitDialogs()
					end,
					width = "full",
					default = 2,
				},
				{ -- Background opacity
					type = "slider",
					name = texts.cat5.opt2,
					tooltip = nil,
					min = 0,
					step = 1,
					max = 100,
					getFunc = function() return NTakDialog.settings.HLBackAlpha * 100 end,
					setFunc = function(value)
						NTakDialog.settings.HLBackAlpha = value / 100
						NTDial.InitDialogs()
					end,
					width = "full",
					default = 66,
				},
				{ -- Background full width
					type = "checkbox",
					name = texts.cat5.opt3,
					getFunc = function() return NTakDialog.settings.HLFullWidth end,
					setFunc = function(value)
						NTakDialog.settings.HLFullWidth = value
						NTDial.InitDialogs()
					end,
					width = "full",
					default = true,
				},
			},
		},
		{ -- SPECIFIC DIALOGS
			type = "submenu",
			name = icons["Specific"] .. " " .. Titler(texts.cat6.title),
			width = "full",
			controls = {
				{ -- Banker
					type = "submenu",
					name = icons["Bank"] .. " " .. texts.cat6.menu1,
					width = "full",
					disabledLabel = function() return
						not(NTakDialog.settings.muteBanker) and
						not(NTakDialog.settings.autoBanker) and
						not(NTakDialog.settings.speedBanker) and
						not(NTakDialog.settings.directBanker)
					end,
					controls = {
                        { -- Mute
                            type = "checkbox",
                            name = texts.cat6.opt1,
                            getFunc = function() return NTakDialog.settings.muteBanker end,
                            setFunc = function(value) NTakDialog.settings.muteBanker = value end,
                            width = "full",
                            default = false,
                        },
						SUBDIVIDER,
                        { -- Speed-up fading
                            type = "checkbox",
                            name = texts.cat6.opt3,
                            getFunc = function() return NTakDialog.settings.speedBanker end,
                            setFunc = function(value)
                                NTakDialog.settings.speedBanker = value
                                if value then
                                    NTakDialog.settings.directBanker = false
									NTakDialog.settings.autoBanker = false
                                end
                            end,
                            width = "full",
                            default = false,
							-- warning = IsNeeded(texts.cat3.opt21),
                            -- disabled = function() return not(NTakDialog.settings.textFadeIn) end,
                        },
                        { -- Instant display
                            type = "checkbox",
                            name = texts.cat6.opt4,
                            getFunc = function() return NTakDialog.settings.directBanker end,
                            setFunc = function(value)
                                NTakDialog.settings.directBanker = value
                                if value then
                                    NTakDialog.settings.speedBanker = false
									NTakDialog.settings.autoBanker = false
                                end
                            end,
                            width = "full",
                            default = false,
							-- warning = IsNeeded(texts.cat3.opt21),
                            -- disabled = function() return not(NTakDialog.settings.textFadeIn) end,
                        },
	                    { -- Auto open
	                        type = "checkbox",
	                        name = texts.cat6.opt2,
	                        getFunc = function() return NTakDialog.settings.autoBanker end,
	                        setFunc = function(value)
								NTakDialog.settings.autoBanker = value
								if value then
									NTakDialog.settings.speedBanker = false
									NTakDialog.settings.directBanker = false
								end								
							end,
	                        width = "full",
	                        default = false,
	                    },
					},
				},
				{ -- Vendor
					type = "submenu",
					name = icons["Store"] .. " " .. texts.cat6.menu2,
					width = "full",
					disabledLabel = function() return
						not(NTakDialog.settings.muteVendor) and
						not(NTakDialog.settings.autoVendor) and
						not(NTakDialog.settings.speedVendor) and
						not(NTakDialog.settings.directVendor)
					end,
					controls = {
	                    { -- Mute
	                        type = "checkbox",
	                        name = texts.cat6.opt1,
	                        getFunc = function() return NTakDialog.settings.muteVendor end,
	                        setFunc = function(value) NTakDialog.settings.muteVendor = value end,
	                        width = "full",
	                        default = false,
	                    },
						SUBDIVIDER,
						{ -- Speed-up fading
							type = "checkbox",
							name = texts.cat6.opt3,
							getFunc = function() return NTakDialog.settings.speedVendor end,
							setFunc = function(value)
								NTakDialog.settings.speedVendor = value
								if value then
									NTakDialog.settings.directVendor = false
									NTakDialog.settings.autoVendor = false
								end
							end,
							width = "full",
							default = false,
							-- warning = IsNeeded(texts.cat3.opt21),
							-- disabled = function() return not(NTakDialog.settings.textFadeIn) end,
						},
						{ -- Instant display
							type = "checkbox",
							name = texts.cat6.opt4,
							getFunc = function() return NTakDialog.settings.directVendor end,
							setFunc = function(value)
								NTakDialog.settings.directVendor = value
								if value then
									NTakDialog.settings.speedVendor = false
									NTakDialog.settings.autoVendor = false
								end
							end,
							width = "full",
							default = false,
							-- warning = IsNeeded(texts.cat3.opt21),
							-- disabled = function() return not(NTakDialog.settings.textFadeIn) end,
						},
	                    { -- Auto open
	                        type = "checkbox",
	                        name = texts.cat6.opt2,
	                        getFunc = function() return NTakDialog.settings.autoVendor end,
	                        setFunc = function(value)
								NTakDialog.settings.autoVendor = value
								if value then
									NTakDialog.settings.speedVendor = false
									NTakDialog.settings.directVendor = false
								end
							end,
	                        width = "full",
	                        default = false,
	                    },
					},
				},
				{ -- Guild Trader
					type = "submenu",
					name = icons["Store"] .. " " .. texts.cat6.menu3,
					width = "full",
					disabledLabel = function() return
						not(NTakDialog.settings.muteTrader) and
						not(NTakDialog.settings.autoTrader) and
						not(NTakDialog.settings.speedTrader) and
						not(NTakDialog.settings.directTrader)
					end,
					controls = {
	                    { -- Mute
	                        type = "checkbox",
	                        name = texts.cat6.opt1,
	                        getFunc = function() return NTakDialog.settings.muteTrader end,
	                        setFunc = function(value) NTakDialog.settings.muteTrader = value end,
	                        width = "full",
	                        default = false,
	                    },
						SUBDIVIDER,
						{ -- Speed-up fading
							type = "checkbox",
							name = texts.cat6.opt3,
							getFunc = function() return NTakDialog.settings.speedTrader end,
							setFunc = function(value)
								NTakDialog.settings.speedTrader = value
								if value then
									NTakDialog.settings.directTrader = false
									NTakDialog.settings.autoTrader = false
								end
							end,
							width = "full",
							default = false,
							-- warning = IsNeeded(texts.cat3.opt21),
							-- disabled = function() return not(NTakDialog.settings.textFadeIn) end,
						},
						{ -- Instant display
							type = "checkbox",
							name = texts.cat6.opt4,
							getFunc = function() return NTakDialog.settings.directTrader end,
							setFunc = function(value)
								NTakDialog.settings.directTrader = value
								if value then
									NTakDialog.settings.speedTrader = false
									NTakDialog.settings.autoTrader = false
								end
							end,
							width = "full",
							default = false,
							-- warning = IsNeeded(texts.cat3.opt21),
							-- disabled = function() return not(NTakDialog.settings.textFadeIn) end,
						},
	                    { -- Auto open
	                        type = "checkbox",
	                        name = texts.cat6.opt2,
	                        getFunc = function() return NTakDialog.settings.autoTrader end,
	                        setFunc = function(value)
								NTakDialog.settings.autoTrader = value								
								if value then
									NTakDialog.settings.speedTrader = false
									NTakDialog.settings.directTrader = false
								end
							end,
	                        width = "full",
	                        default = false,
	                    },
					},
				},
				{ -- Stable master
					type = "submenu",
					name = icons["Mount"] .. " " .. texts.cat6.menu4,
					width = "full",
					disabledLabel = function() return
						not(NTakDialog.settings.muteStable) and
						not(NTakDialog.settings.autoStable) and
						not(NTakDialog.settings.speedStable) and
						not(NTakDialog.settings.directStable)
					end,
					controls = {
	                    { -- Mute
	                        type = "checkbox",
	                        name = texts.cat6.opt1,
	                        getFunc = function() return NTakDialog.settings.muteStable end,
	                        setFunc = function(value) NTakDialog.settings.muteStable = value end,
	                        width = "full",
	                        default = false,
	                    },
						SUBDIVIDER,
						{ -- Speed-up fading
							type = "checkbox",
							name = texts.cat6.opt3,
							getFunc = function() return NTakDialog.settings.speedStable end,
							setFunc = function(value)
								NTakDialog.settings.speedStable = value
								if value then
									NTakDialog.settings.directStable = false
									NTakDialog.settings.autoStable = false
								end
							end,
							width = "full",
							default = false,
							-- warning = IsNeeded(texts.cat3.opt21),
							-- disabled = function() return not(NTakDialog.settings.textFadeIn) end,
						},
						{ -- Instant display
							type = "checkbox",
							name = texts.cat6.opt4,
							getFunc = function() return NTakDialog.settings.directStable end,
							setFunc = function(value)
								NTakDialog.settings.directStable = value
								if value then
									NTakDialog.settings.speedStable = false
									NTakDialog.settings.autoStable = false
								end
							end,
							width = "full",
							default = false,
							-- warning = IsNeeded(texts.cat3.opt21),
							-- disabled = function() return not(NTakDialog.settings.textFadeIn) end,
						},
	                    { -- Auto open
	                        type = "checkbox",
	                        name = texts.cat6.opt2,
	                        getFunc = function() return NTakDialog.settings.autoStable end,
	                        setFunc = function(value)
								NTakDialog.settings.autoStable = value
								if value then
									NTakDialog.settings.speedStable = false
									NTakDialog.settings.directStable = false
								end
							end,
	                        width = "full",
	                        default = false,
	                    },
					},
				},
				{ -- Descriptive texts
					type = "submenu",
					name = icons["Text"] .. " " .. texts.cat6.menu9,
					width = "full",
					disabledLabel = function() return
						not(NTakDialog.settings.speedDescription) and
						not(NTakDialog.settings.directDescription)
					end,
					controls = {
						{ -- Speed-up fading
							type = "checkbox",
							name = texts.cat6.opt3,
							getFunc = function() return NTakDialog.settings.speedDescription end,
							setFunc = function(value)
								NTakDialog.settings.speedDescription = value
								if value then
									NTakDialog.settings.directDescription = false
								end
							end,
							width = "full",
							default = false,
							-- warning = IsNeeded(texts.cat3.opt21),
							-- disabled = function() return not(NTakDialog.settings.textFadeIn) end,
						},
						{ -- Instant display
							type = "checkbox",
							name = texts.cat6.opt4,
							getFunc = function() return NTakDialog.settings.directDescription end,
							setFunc = function(value)
								NTakDialog.settings.directDescription = value
								if value then
									NTakDialog.settings.speedDescription = false
								end
							end,
							width = "full",
							default = false,
							-- warning = IsNeeded(texts.cat3.opt21),
							-- disabled = function() return not(NTakDialog.settings.textFadeIn) end,
						},
					},
				},
				-- { -- Quests options
					-- type = "submenu",
					-- name = icons["Quest"] .. " " .. texts.cat6.menuA,
					-- width = "full",
					-- disabledLabel = function() return
						-- not(NTakDialog.settings.autoQuestOpen) and
						-- not(NTakDialog.settings.autoQuestAccept) and
						-- not(NTakDialog.settings.autoQuestComplete)
					-- end,
					-- controls = {
	                    -- { -- Auto open
	                        -- type = "checkbox",
	                        -- name = texts.cat6.optA1,
	                        -- getFunc = function() return NTakDialog.settings.autoQuestOpen end,
	                        -- setFunc = function(value)
								-- NTakDialog.settings.autoQuestOpen = value
							-- end,
	                        -- width = "full",
	                        -- default = false,
	                    -- },
	                    -- { -- Auto take
	                        -- type = "checkbox",
	                        -- name = texts.cat6.optA2,
	                        -- getFunc = function() return NTakDialog.settings.autoQuestAccept end,
	                        -- setFunc = function(value)
								-- NTakDialog.settings.autoQuestAccept = value
							-- end,
	                        -- width = "full",
	                        -- default = false,
	                    -- },
	                    -- { -- Auto complete
	                        -- type = "checkbox",
	                        -- name = texts.cat6.optA3,
	                        -- getFunc = function() return NTakDialog.settings.autoQuestComplete end,
	                        -- setFunc = function(value)
								-- NTakDialog.settings.autoQuestComplete = value
							-- end,
	                        -- width = "full",
	                        -- default = false,
	                    -- },
					-- },
				-- },
			},
		},
    	SPACER,
	}
	
	--	Data are done, create !
	LAM2:RegisterAddonPanel(ADDON_NAME, panelData)
	LAM2:RegisterOptionControls(ADDON_NAME, options)
end