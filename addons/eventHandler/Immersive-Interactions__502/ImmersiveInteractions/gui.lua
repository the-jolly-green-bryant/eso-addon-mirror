-- ==================================================================================================== --
-- # Immersive Interactions
-- # 
-- # It's an addon for ESO. I'm not going to put a fancy license or disclaimer. Go crazy with it.
-- #
-- # Currently using LibAddonMenu-2.0 for standardized settings interface.
-- ==================================================================================================== --

do
	function ImmersiveFunctions.SetupControl()
		local LMP			= LibMediaProvider
		local fontList		= LMP:List('font')

		local ZHT			= ZO_HIGHLIGHT_TEXT
		local IMF			= ImmersiveFunctions

		local optionsData = {
		{
			type = "description",
			text = IMF.Colorize("des", "Most changes take effect without /reloadui, except where noted."),
		},
		{
			type = "description",
			text = IMF.Colorize("des", "See Controls in the System Menu to assign keybinds."),
		},
		{
			type = "texture",
			image = "EsoUI/Art/Quest/questJournal_divider.dds",
			imageWidth = 510,
			imageHeight = 4,
		},
		{
			type = "checkbox",
			name = "Enable Immersive Interactions?",
			--tooltip = ZHT:Colorize(""),
			getFunc = IMF.GetAccessor("bEnabled"),
			setFunc = IMF.GetSetter("bEnabled"),
		},
		{
			type = "submenu",
			name = "What to Hide",
			controls = {
				{
					type = "checkbox",
					name = "Keep other addons visible?",
					tooltip = ZHT:Colorize("This will hide all parts of the interaction scene. So the chat window won't be affected, but you can hide it with an option below. This mode will still obey the timer rules and the keybinds."),
					getFunc = IMF.GetAccessor("bHideWindow"),
					setFunc = IMF.GetSetter("bHideWindow"),
				},
				{
					type = "checkbox",
					name = "Hide default NPC name?",
					--tooltip = ZHT:Colorize(""),
					getFunc = IMF.GetAccessor("bHideTitle"),
					setFunc = IMF.GetSetter("bHideTitle"),
				},
				{
					type = "checkbox",
					name = "Hide response options?",
					--tooltip = ZHT:Colorize(""),
					getFunc = IMF.GetAccessor("bHideOptions"),
					setFunc = IMF.GetSetter("bHideOptions"),
				},
				{
					type = "checkbox",
					name = "Hide dialog background?",
					--tooltip = ZHT:Colorize(""),
					getFunc = IMF.GetAccessor("bHideDialogBG"),
					setFunc = IMF.GetSetter("bHideDialogBG"),
				},
				{
					type = "checkbox",
					name = "Forget hiding anything, turn off the UI!",
					tooltip = ZHT:Colorize("This will completely toggle the ui off and show nothing but the scene regardless of addons (probably). This mode will still obey the timer rules and the keybinds."),
					getFunc = IMF.GetAccessor("bHideUI"),
					setFunc = IMF.GetSetter("bHideUI"),
				},
			},
		},
		{
			type = "submenu",
			name = "When to Hide",
			controls = {
				{
					type = "checkbox",
					name = "Skip Repeatable Quest NPCs?",
					--tooltip = ZHT:Colorize(""),
					getFunc = IMF.GetAccessor("bSkipDaily"),
					setFunc = IMF.GetSetter("bSkipDaily"),
				},
				{
					type = "checkbox",
					name = "Skip while in PvP zones?",
					tooltip = ZHT:Colorize("Cyrodiil, Imperial City, Imperial City Sewers"),
					getFunc = IMF.GetAccessor("bAlwaysShowPvP"),
					setFunc = IMF.GetSetter("bAlwaysShowPvP"),
				},
				{
					type = "checkbox",
					name = "Hide Until Keypress?",
					tooltip = ZHT:Colorize("Turn off the timer and always hide unless a keybind/mouse is used to force display."),
					getFunc = IMF.GetAccessor("bAlwaysHide"),
					setFunc = IMF.GetSetter("bAlwaysHide"),
				},
				{
					type = "texture",
					image = "EsoUI/Art/Quest/questJournal_divider.dds",
					imageWidth = 510,
					imageHeight = 4,
				},
				{
					type = "editbox",
					name = "Add names to skip hiding:",
					tooltip = "not yet implemented",
					getFunc = IMF.GetAccessor("bCustomNames"),
					setFunc = IMF.GetSetter("bCustomNames"),
					isMultiline = false,
					width = "full",
				},
				{
					type = "editbox",
					name = "Remove names from hiding:",
					tooltip = "not yet implemented",
					getFunc = IMF.GetAccessor("bCustomNames"),
					setFunc = IMF.GetSetter("bCustomNames"),
					isMultiline = false,
					width = "full",
				},
			},
		},
		{
			type = "submenu",
			name = "Dialog Colors",
			controls = {
				{
					type = "colorpicker",
					name = ZHT:Colorize("Default NPC Name Display Color:"),
					tooltip = ZHT:Colorize("Change the color for the default NPC name text."),
					getFunc = IMF.GetAccessor("tatRGBA"),
					setFunc = IMF.GetSetter("tatRGBA"),
				},
				{
					type = "colorpicker",
					name = ZHT:Colorize("Alternate NPC Name Display Color:"),
					tooltip = ZHT:Colorize("Change the alternate color of the NPC (or other interactable) name when in dialog windows."),
					getFunc = IMF.GetAccessor("altRGBA"),
					setFunc = IMF.GetSetter("altRGBA"),
				},
				{
					type = "colorpicker",
					name = ZHT:Colorize("NPC Dialog Text Display Color:"),
					tooltip = ZHT:Colorize("Change the conversation text color."),
					getFunc = IMF.GetAccessor("tabRGBA"),
					setFunc = IMF.GetSetter("tabRGBA"),
				},
				{
					type = "colorpicker",
					name = ZHT:Colorize("Response Text Display Color:"),
					tooltip = ZHT:Colorize("Change the conversation response text color."),
					getFunc = IMF.GetAccessor("optRGBA"),
					setFunc = IMF.GetSetter("optRGBA"),
				},
				{
					type = "colorpicker",
					name = ZHT:Colorize("Response Number Display Color:"),
					tooltip = ZHT:Colorize("Change the text color of the response option numbering."),
					getFunc = IMF.GetAccessor("opnRGBA"),
					setFunc = IMF.GetSetter("opnRGBA"),
				},
				{
					type = "colorpicker",
					name = ZHT:Colorize("Response Separator Display Color:"),
					tooltip = ZHT:Colorize("Change the color of the divider between option number and option text."),
					getFunc = IMF.GetAccessor("oppRGBA"),
					setFunc = IMF.GetSetter("oppRGBA"),
				},
				{
					type = "colorpicker",
					name = ZHT:Colorize("Special Highlight Color:"),
					tooltip = ZHT:Colorize("Used for highlighting Persuade and Intimidate options; possibly other special actions."),
					getFunc = IMF.GetAccessor("spcRGBA"),
					setFunc = IMF.GetSetter("spcRGBA"),
				},
			},
		},
		{
			type = "submenu",
			name = "Dialog Fonts",
			controls = {
				{
					type = "description",
					text = IMF.Colorize("des", "Standard Title"),
				},
				{
					type = "dropdown",
					name = ZHT:Colorize("Font Face"),
					--tooltip = ZHT:Colorize("not fully tested"),
					choices = fontList,
					getFunc = IMF.GetAccessor("fontFaceTat"),
					setFunc = IMF.GetSetter("fontFaceTat"),
				},
				{
					type = "dropdown",
					name = ZHT:Colorize("Font Style"),
					--tooltip = ZHT:Colorize("not fully tested"),
					choices = ImmersiveData.fontStyle,
					getFunc = IMF.GetAccessor("fontStyleTat"),
					setFunc = IMF.GetSetter("fontStyleTat"),
				},
				{
					type = "slider",
					name = ZHT:Colorize("Font Size"),
					--tooltip = ZHT:Colorize("not fully tested"),
					min = 16,
					max = 48,
					step = 2,
					getFunc = IMF.GetAccessor("fontSizeTat"),
					setFunc = IMF.GetSetter("fontSizeTat"),
					width="half",
				},
				{
					type = "texture",
					image = "EsoUI/Art/Quest/questJournal_divider.dds",
					imageWidth = 510,
					imageHeight = 4,
				},
				{
					type = "description",
					text = IMF.Colorize("des", "Alternate Title"),
				},
				{
					type = "dropdown",
					name = ZHT:Colorize("Font Face"),
					--tooltip = ZHT:Colorize("not fully tested"),
					choices = fontList,
					getFunc = IMF.GetAccessor("fontFaceAlt"),
					setFunc = IMF.GetSetter("fontFaceAlt"),
				},
				{
					type = "dropdown",
					name = ZHT:Colorize("Font Style"),
					--tooltip = ZHT:Colorize("not fully tested"),
					choices = ImmersiveData.fontStyle,
					getFunc = IMF.GetAccessor("fontStyleAlt"),
					setFunc = IMF.GetSetter("fontStyleAlt"),
				},
				{
					type = "slider",
					name = ZHT:Colorize("Font Size"),
					--tooltip = ZHT:Colorize("not fully tested"),
					min = 16,
					max = 48,
					step = 2,
					getFunc = IMF.GetAccessor("fontSizeAlt"),
					setFunc = IMF.GetSetter("fontSizeAlt"),
					width="half",
				},
				{
					type = "texture",
					image = "EsoUI/Art/Quest/questJournal_divider.dds",
					imageWidth = 510,
					imageHeight = 4,
				},
				{
					type = "description",
					text = IMF.Colorize("des", "Dialog Body Text"),
				},
				{
					type = "dropdown",
					name = ZHT:Colorize("Font Face"),
					--tooltip = ZHT:Colorize("not fully tested"),
					choices = fontList,
					getFunc = IMF.GetAccessor("fontFaceTab"),
					setFunc = IMF.GetSetter("fontFaceTab"),
				},
				{
					type = "dropdown",
					name = ZHT:Colorize("Font Style"),
					--tooltip = ZHT:Colorize("not fully tested"),
					choices = ImmersiveData.fontStyle,
					getFunc = IMF.GetAccessor("fontStyleTab"),
					setFunc = IMF.GetSetter("fontStyleTab"),
				},
				{
					type = "slider",
					name = ZHT:Colorize("Font Size"),
					--tooltip = ZHT:Colorize("not fully tested"),
					min = 16,
					max = 48,
					step = 2,
					getFunc = IMF.GetAccessor("fontSizeTab"),
					setFunc = IMF.GetSetter("fontSizeTab"),
					width="half",
				},
				{
					type = "texture",
					image = "EsoUI/Art/Quest/questJournal_divider.dds",
					imageWidth = 510,
					imageHeight = 4,
				},
				{
					type = "description",
					text = IMF.Colorize("des", "Dialog Response Text"),
				},
				{
					type = "dropdown",
					name = ZHT:Colorize("Font Face"),
					--tooltip = ZHT:Colorize("not fully tested"),
					choices = fontList,
					getFunc = IMF.GetAccessor("fontFaceOpt"),
					setFunc = IMF.GetSetter("fontFaceOpt"),
				},
				{
					type = "dropdown",
					name = ZHT:Colorize("Font Style"),
					--tooltip = ZHT:Colorize("not fully tested"),
					choices = ImmersiveData.fontStyle,
					getFunc = IMF.GetAccessor("fontStyleOpt"),
					setFunc = IMF.GetSetter("fontStyleOpt"),
				},
				{
					type = "slider",
					name = ZHT:Colorize("Font Size"),
					--tooltip = ZHT:Colorize("not fully tested"),
					min = 16,
					max = 48,
					step = 2,
					getFunc = IMF.GetAccessor("fontSizeOpt"),
					setFunc = IMF.GetSetter("fontSizeOpt"),
					width="half",
				},
			},
		},
		{
			type = "submenu",
			name = "Dialog Formatting",
			controls = {
				{
					type = "checkbox",
					name = "Trim NPC name dashes?",
					--tooltip = ZHT:Colorize(""),
					getFunc = IMF.GetAccessor("bTrimDashes"),
					setFunc = IMF.GetSetter("bTrimDashes"),
				},
				{
					type = "checkbox",
					name = "Add numbers to response options?",
					--tooltip = ZHT:Colorize(""),
					getFunc = IMF.GetAccessor("bAddNums"),
					setFunc = IMF.GetSetter("bAddNums"),
				},
				{
					type = "checkbox",
					name = "Use Alternate NPC nameplate?",
					--tooltip = ZHT:Colorize(""),
					getFunc = IMF.GetAccessor("bAltTitle"),
					setFunc = IMF.GetSetter("bAltTitle"),
				},
				{
					type = "editbox",
					name = "Separator:",
					tooltip = "The default is ), for example:\n1) response\n2) response\n3) Goodbye.",
					getFunc = IMF.GetAccessor("szDivider"),
					setFunc = IMF.GetSetter("szDivider"),
					isMultiline = false,
					width = "full",
					default = ")",
				},
				{
					type = "slider",
					name = "Delay in milliseconds per letter:",
					tooltip = ZHT:Colorize("Default is 50ms, which is usually too fast for Argonians. Setting to zero will turn off dialog hiding completely."),
					min = 0,
					max = 200,
					getFunc = IMF.GetAccessor("iOffsetMS"),
					setFunc = IMF.GetSetter("iOffsetMS"),
					width = "half",
				},
			},
		},
		{
			type = "submenu",
			name = "Chat Options",
			controls = {
				{
					type = "description",
					--title = ZHT:Colorize("                -= Chat Window Settings =-\n"),
					text = IMF.Colorize("des", "If you have already minimized the chat window before starting a conversation, it will probably stay minimized."),
				},
				{
					type = "checkbox",
					name = "Minimize chat window during dialog?",
					tooltip = ZHT:Colorize("If the chat window is open when starting an interaction, set this to have it hide automatically for normal interactions."),
					getFunc = IMF.GetAccessor("bHideChat"),
					setFunc = IMF.GetSetter("bHideChat"),
				},
				{
					type = "checkbox",
					name = "    Also minimize at services?",
					tooltip = ZHT:Colorize("Pick whether or not to hide chat while interacting with banks, shops, and so on."),
					getFunc = IMF.GetAccessor("bHideChatShop"),
					setFunc = IMF.GetSetter("bHideChatShop"),
				},
				{
					type = "checkbox",
					name = "Hide sidebar when chat is minimized?",
					tooltip = ZHT:Colorize("During interactions, enabling this will hide the sidebar which normally shows on screen when the chat window is minimized. You will not be able to open the chat window during dialog if this is selected."),
					getFunc = IMF.GetAccessor("bHideMini"),
					setFunc = IMF.GetSetter("bHideMini"),
				},
				{
					type = "checkbox",
					name = "    Also hide sidebar at services?",
					tooltip = ZHT:Colorize("If disabled, the sidebar will display as normal when interacting with npc's offering services."),
					getFunc = IMF.GetAccessor("bHideMiniShop"),
					setFunc = IMF.GetSetter("bHideMiniShop"),
				},
				{
					type = "checkbox",
					name = "Output dialog to chat?",
					tooltip = ZHT:Colorize(""),
					getFunc = IMF.GetAccessor("bPrintDialog"),
					setFunc = IMF.GetSetter("bPrintDialog"),
				},
			},
		},
		{
			type = "submenu",
			name = "System Options",
			controls = {
				{
					type = "description",
					--title = ZHT:Colorize("                -= System Options =-\n"),
					text = IMF.Colorize("des", "You should probably /reloadui after using these, but it isn't required."),
				},
				{
					type = "checkbox",
					name = "Use Account-wide Settings?",
					--tooltip = ZHT:Colorize("not fully tested"),
					getFunc = IMF.GetAccessor("bUseAcct"),
					setFunc = IMF.GetSetter("bUseAcct"),
				},
				{
					type = "button",
					name = "Restore Defaults?",
					--tooltip = ZHT:Colorize("not fully tested"),
					func = IMF.RestoreDefault,
					width = "half",
				},
			},
		},
		{
			type = "submenu",
			name = "NEW Options (Unsorted)",
			controls = {
				{
					type = "description",
					--title = ZHT:Colorize("                -= System Options =-\n"),
					text = IMF.Colorize("des", "Work in Progress"),
				},
				{
					type = "checkbox",
					name = "Show Toggle Button for Dialog Window?",
					--tooltip = ZHT:Colorize("not fully tested"),
					getFunc = IMF.GetAccessor("bToggleButton"),
					setFunc = IMF.GetSetter("bToggleButton"),
				},
				{
					type = "checkbox",
					name = "Show Dialog Output Window?",
					--tooltip = ZHT:Colorize("not fully tested"),
					getFunc = IMF.GetAccessor("bMsgWindow"),
					setFunc = IMF.GetSetter("bMsgWindow"),
				},
				{
					type = "editbox",
					name = "Dialog Output - Label",
					tooltip = "",
					getFunc = IMF.GetAccessor("szMsgWindowLabel"),
					setFunc = IMF.GetSetter("szMsgWindowLabel"),
					isMultiline = false,
					width = "full",
					default = "Transcripts",
				},
				{
					type = "editbox",
					name = "Dialog Output - Fade Delay",
					tooltip = "",
					min = 0,
					max = 6000,
					getFunc = IMF.GetAccessor("iFadeDelay"),
					setFunc = IMF.GetSetter("iFadeDelay"),
					width = "full",
				},
				{
					type = "editbox",
					name = "Dialog Output - Fade Duration",
					tooltip = "",
					min = 0,
					max = 6000,
					getFunc = IMF.GetAccessor("iFadeDuration"),
					setFunc = IMF.GetSetter("iFadeDuration"),
					width = "full",
				},
			},
		},
		-- end of optionsData
		}

		do
			local IMD = ImmersiveData.addonInfo
			local panelData = {
				type = "panel",
				name					= IMD.displayName,
				displayName				= IMD.displayName,
				author					= IMD.author,
				version					= IMD.version,
				website					= IMD.website,
				keywords				= IMD.keywords,
				slashCommand			= IMD.slash,
				registerForRefresh		= true,
				registerForDefaults		= true,
				resetFunc				= IMF.RestoreDefault,
			}

			local LAM = LibAddonMenu2

			local name = IMD.name
			local panel = LAM:RegisterAddonPanel(name.."Options", panelData)

			local wm = WINDOW_MANAGER
			-- using a logo image instead of a label was inspired by Garkin's addons
			panel.logo = wm:CreateControl(nil, panel, CT_TEXTURE)
			panel.logo:SetAnchor(TOP, panel, TOP, 0, 0)
			panel.logo:SetDimensions(420, 60)
			panel.logo:SetTexture(name.."/art/logo.dds")
			panel.logo:SetTextureCoords(0, 1, 0, 0.1429)

			panel.dividerTop = wm:CreateControlFromVirtual(nil, panel, "ZO_Options_Divider")
			panel.dividerTop:SetWidth(510)
			panel.dividerTop:SetAnchor(TOP, panel.logo, BOTTOM, 0, 0)

			panel.label:SetHeight(65)
			panel.label:SetHidden(true)
			panel.container:ClearAnchors()
			panel.container:SetAnchor(TOPLEFT, panel.info, BOTTOMLEFT, 0, 10)
			panel.container:SetAnchor(BOTTOMRIGHT, panel, BOTTOMRIGHT, -3, -3)

			LAM:RegisterOptionControls(name.."Options", optionsData)
		end
	end
end
