if NBUI == nil then NBUI = {} end

function CreateNBUISettings()
	local LAM2 = LibStub("LibAddonMenu-2.0")
	local panelData = {
        type = "panel",
        name = "Notebooks",
		displayName = ZO_HIGHLIGHT_TEXT:Colorize(GetString(SI_NBUI_ADDONOPTIONS_NAME)),
		author = GetString(SI_NBUI_AUTHOR),
		version = GetString(SI_NBUI_VERSION_NUM),		
		registerForRefresh  = true,
		registerForDefaults = true,
		website = "http://www.esoui.com/downloads/info1105-Notebook.html",
		-- chat command to open settings window
		slashCommand = "/nbs", 

		-- resets NBUI position, when reset to defaults is pressed
		resetFunc = function()
			NBUI.NB1MainWindow:ClearAnchors()
			NBUI.NB1MainWindow:SetAnchor (CENTER, GuiRoot, CENTER, 0, -48)			
			 _,a,_,b,x,y = NBUI.NB1MainWindow:GetAnchor()
			NBUIDB.NB1_Anchor = {["a"]=a, ["b"]=b, ["x"]=x, ["y"]=y}
		
			NBUI.NB2MainWindow:ClearAnchors()
			NBUI.NB2MainWindow:SetAnchor (CENTER, GuiRoot, CENTER, 0, -48)			
			 _,a,_,b,x,y = NBUI.NB2MainWindow:GetAnchor()
			NBUIDB.NB2_Anchor = {["a"]=a, ["b"]=b, ["x"]=x, ["y"]=y}		
		
			NBUI.NB3MainWindow:ClearAnchors()
			NBUI.NB3MainWindow:SetAnchor (CENTER, GuiRoot, CENTER, 0, -48)			
			 _,a,_,b,x,y = NBUI.NB3MainWindow:GetAnchor()
			NBUIDB.NB3_Anchor = {["a"]=a, ["b"]=b, ["x"]=x, ["y"]=y}		
		end
    }
	LAM2:RegisterAddonPanel("NBUIOptions", panelData)
	
	local optionsData = {		
		[1]={ -- general category
			type = "submenu",
			name = ZO_HIGHLIGHT_TEXT:Colorize(GetString(SI_NBUI_NB1KEYBIND_LABEL)),
			controls = {
			[1]={ -- general category
				type = "header",
				name = ZO_HIGHLIGHT_TEXT:Colorize(GetString(SI_NBUI_HEADER_GENERAL)),
				},			
			[2]={ -- show title
				type = "checkbox",
				name = GetString(SI_NBUI_SHOWTITLE_LABEL),
				tooltip = GetString(SI_NBUI_SHOWTITLE_TOOLTIP),
				getFunc = function() return NBUIDB.NB1_ShowTitle end,
				setFunc = function(value)
					NBUIDB.NB1_ShowTitle = value
					NBUI.NB1LeftPage_Title:SetHidden(not NBUIDB.NB1_ShowTitle)
					NBUI.NB1LeftPage_Separator:SetHidden(not NBUIDB.NB1_ShowTitle)
					NBUI.NB1Information_Button:SetHidden(not NBUIDB.NB1_ShowTitle)
						if (NBUIDB.NB1_ShowTitle) then
							NBUI.NB1LeftPage_Backdrop:SetDimensions(420, 645)
						else
							NBUI.NB1LeftPage_Backdrop:SetDimensions(420, 690)
						end
					end,
				default = NBUI.defaults.NB1_ShowTitle,
				},						
			[3]={ -- title label
				type = "editbox",
				name = GetString(SI_NBUI_TITLE_LABEL),
				tooltip = GetString(SI_NBUI_TITLE_TOOLTIP),
				getFunc = function() return NBUIDB.NB1_Title end,
				setFunc = function(value)
					NBUIDB.NB1_Title = value
					NBUI.NB1LeftPage_Title:SetText(NBUIDB.NB1_Title)
					end,
				default = NBUI.defaults.NB1_Title,
				},					
			[4]={ -- change book color
				type = "colorpicker",
				name = GetString(SI_NBUI_COLOR_LABEL),
				tooltip = GetString(SI_NBUI_COLOR_TOOLTIP),
				getFunc = function() return unpack(NBUIDB.NB1_BookColor) end,
				setFunc = function(r, g, b, a)
					NBUIDB.NB1_BookColor = {r, g, b, a}
					NBUI.NB1MainWindow_Cover:SetColor(r, g, b, a)
					NBUI.NB1MaxChatWin_ButtonTexture:SetColor(r, g, b, a)
					NBUI.NB1MinChatWin_ButtonTexture:SetColor(r, g, b, a)
					end,
				default = { r = NBUI.defaults.NB1_BookColor[1], g = NBUI.defaults.NB1_BookColor[2], b = NBUI.defaults.NB1_BookColor[3], a = NBUI.defaults.NB1_BookColor[4]},
				},								
			[5] = { -- display dialog
				type = "checkbox",
				name = GetString(SI_NBUI_DIALOG),
				tooltip = GetString(SI_NBUI_DIALOG_TOOLTIP),
				getFunc = function() return NBUIDB.NB1_ShowDialog end,
				setFunc = function(value)
					NBUIDB.NB1_ShowDialog = value
						NBUI.NB1SavePage_Button:SetHandler("OnClicked", function(self)
							if (NBUIDB.NB1_ShowDialog) then
								ZO_Dialogs_ShowDialog("CONFIRM_NBUI_SAVE")
							else
								NBUI.NB1SavePage(self)
							end			
						end)
						NBUI.NB1UndoPage_Button:SetHandler("OnClicked", function()
							if (NBUIDB.NB1_ShowDialog) then
								ZO_Dialogs_ShowDialog("CONFIRM_NBUI_UNDO")
							else
								NBUI.NB1UndoPage()
							end			
						end)
						NBUI.NB1DeletePage_Button:SetHandler("OnClicked", function()
							if (NBUIDB.NB1_ShowDialog) then
								ZO_Dialogs_ShowDialog("CONFIRM_NBUI_DELETE")
							else
								NBUI.NB1DeletePage()
							end			
						end)
						NBUI.NB1NewPage_Button:SetHandler("OnClicked", function(self)
							if (NBUIDB.NB1_ShowDialog) then
								ZO_Dialogs_ShowDialog("CONFIRM_NBUI_NEWPAGE")
							else
								NBUI.NB1NewPage(self)
							end			
						end)					
					end,
				default = NBUI.defaults.NB1_ShowDialog,
				},
			[6]={ -- lock position
				type = "checkbox",
				name = GetString(SI_NBUI_LOCK_LABEL),
				tooltip = GetString(SI_NBUI_LOCK_TOOLTIP),
				getFunc = function() return NBUIDB.NB1_Locked end,
				setFunc = function(value)
					NBUIDB.NB1_Locked = value
					NBUI.NB1MainWindow:SetMovable(not NBUIDB.NB1_Locked)
					end,
				default = NBUI.defaults.NB1_Locked,
				},
			[7]={ -- toggle chat button
				type = "checkbox",
				name =  GetString(SI_NBUI_BUTTON_LABEL),
				tooltip = GetString(SI_NBUI_BUTTON_TOOLTIP),
				getFunc = function() return NBUIDB.NB1_ChatButton end,
				setFunc = function(value) 
					NBUIDB.NB1_ChatButton = value 
					NBUI.NB1MaxChatWin_Button:SetHidden(not NBUIDB.NB1_ChatButton)
					NBUI.NB1MaxChatWin_ButtonTexture:SetHidden(not NBUIDB.NB1_ChatButton)
					NBUI.NB1MinChatWin_Button:SetHidden(not NBUIDB.NB1_ChatButton)
					NBUI.NB1MinChatWin_ButtonTexture:SetHidden(not NBUIDB.NB1_ChatButton) 
					end,
				default = NBUI.defaults.NB1_ChatButton,
				},
			[8]={ -- offset man chat button
				type = "slider",
				name = GetString(SI_NBUI_OFFSETMAX_LABEL),
				tooltip = GetString(SI_NBUI_OFFSETMAX_TOOLTIP),
				min = -300,
				max = -40,
				step = 1,
				getFunc = function() return NBUIDB.NB1_MaxOffsetChatButton end,
				setFunc = function(offset)
					if (NBUIDB.NB1_ChatButton) then
						NBUIDB.NB1_MaxOffsetChatButton = offset
						NBUI.NB1MaxChatWin_Button:SetAnchor(TOPRIGHT, ZO_ChatWindow, TOPRIGHT, NBUIDB.NB1_MaxOffsetChatButton, 7)
					end
				end,						
				disabled = function()
					return not NBUIDB.NB1_ChatButton
				end,
				default = NBUI.defaults.NB1_MaxOffsetChatButton,
				},
			[9]={ -- offset min chat button
				type = "slider",
				name = GetString(SI_NBUI_OFFSETMIN_LABEL),
				tooltip = GetString(SI_NBUI_OFFSETMIN_TOOLTIP),
				min = -400,
				max = 0,
				step = 1,
				getFunc = function() return NBUIDB.NB1_MinOffsetChatButton end,
				setFunc = function(offset)
					if (NBUIDB.NB1_ChatButton) then
						NBUIDB.NB1_MinOffsetChatButton = offset
						NBUI.NB1MinChatWin_Button:SetAnchor(BOTTOMLEFT, ZO_ChatWindowMinBar, BOTTOMLEFT, -3, NBUIDB.NB1_MinOffsetChatButton)
					end
				end,						
				disabled = function()
					return not NBUIDB.NB1_ChatButton
				end,
				default = NBUI.defaults.NB1_MinOffsetChatButton,
				},
			},
		},
		[2]={ -- general category
			type = "submenu",
			name = ZO_HIGHLIGHT_TEXT:Colorize(GetString(SI_NBUI_NB2KEYBIND_LABEL)),
			controls = {
			[1]={ -- general category
				type = "header",
				name = ZO_HIGHLIGHT_TEXT:Colorize(GetString(SI_NBUI_HEADER_GENERAL)),
				},			
			[2]={ -- show title
				type = "checkbox",
				name = GetString(SI_NBUI_SHOWTITLE_LABEL),
				tooltip = GetString(SI_NBUI_SHOWTITLE_TOOLTIP),
				getFunc = function() return NBUIDB.NB2_ShowTitle end,
				setFunc = function(value)
					NBUIDB.NB2_ShowTitle = value
					NBUI.NB2LeftPage_Title:SetHidden(not NBUIDB.NB2_ShowTitle)
					NBUI.NB2LeftPage_Separator:SetHidden(not NBUIDB.NB2_ShowTitle)
					NBUI.NB2Information_Button:SetHidden(not NBUIDB.NB2_ShowTitle)
						if (NBUIDB.NB2_ShowTitle) then
							NBUI.NB2LeftPage_Backdrop:SetDimensions(420, 645)
						else
							NBUI.NB2LeftPage_Backdrop:SetDimensions(420, 690)
						end
					end,
				default = NBUI.defaults.NB2_ShowTitle,
				},						
			[3]={ -- title label
				type = "editbox",
				name = GetString(SI_NBUI_TITLE_LABEL),
				tooltip = GetString(SI_NBUI_TITLE_TOOLTIP),
				getFunc = function() return NBUIDB.NB2_Title end,
				setFunc = function(value)
					NBUIDB.NB2_Title = value
					NBUI.NB2LeftPage_Title:SetText(NBUIDB.NB2_Title)
					end,
				default = NBUI.defaults.NB2_Title,
				},					
			[4]={ -- change book color
				type = "colorpicker",
				name = GetString(SI_NBUI_COLOR_LABEL),
				tooltip = GetString(SI_NBUI_COLOR_TOOLTIP),
				getFunc = function() return unpack(NBUIDB.NB2_BookColor) end,
				setFunc = function(r, g, b, a)
					NBUIDB.NB2_BookColor = {r, g, b, a}
					NBUI.NB2MainWindow_Cover:SetColor(r, g, b, a)
					NBUI.NB2MaxChatWin_ButtonTexture:SetColor(r, g, b, a)
					NBUI.NB2MinChatWin_ButtonTexture:SetColor(r, g, b, a)
					end,
				default = { r = NBUI.defaults.NB2_BookColor[1], g = NBUI.defaults.NB2_BookColor[2], b = NBUI.defaults.NB2_BookColor[3], a = NBUI.defaults.NB2_BookColor[4]},
				},								
			[5] = { -- display dialog
				type = "checkbox",
				name = GetString(SI_NBUI_DIALOG),
				tooltip = GetString(SI_NBUI_DIALOG_TOOLTIP),
				getFunc = function() return NBUIDB.NB2_ShowDialog end,
				setFunc = function(value)
					NBUIDB.NB2_ShowDialog = value
						NBUI.NB2SavePage_Button:SetHandler("OnClicked", function(self)
							if (NBUIDB.NB2_ShowDialog) then
								ZO_Dialogs_ShowDialog("CONFIRM_NBUI_SAVE")
							else
								NBUI.NB2SavePage(self)
							end			
						end)
						NBUI.NB2UndoPage_Button:SetHandler("OnClicked", function()
							if (NBUIDB.NB2_ShowDialog) then
								ZO_Dialogs_ShowDialog("CONFIRM_NBUI_UNDO")
							else
								NBUI.NB2UndoPage()
							end			
						end)
						NBUI.NB2DeletePage_Button:SetHandler("OnClicked", function()
							if (NBUIDB.NB2_ShowDialog) then
								ZO_Dialogs_ShowDialog("CONFIRM_NBUI_DELETE")
							else
								NBUI.NB2DeletePage()
							end			
						end)
						NBUI.NB2NewPage_Button:SetHandler("OnClicked", function(self)
							if (NBUIDB.NB2_ShowDialog) then
								ZO_Dialogs_ShowDialog("CONFIRM_NBUI_NEWPAGE")
							else
								NBUI.NB2NewPage(self)
							end			
						end)					
					end,
				default = NBUI.defaults.NB2_ShowDialog,
				},
			[6]={ -- lock position
				type = "checkbox",
				name = GetString(SI_NBUI_LOCK_LABEL),
				tooltip = GetString(SI_NBUI_LOCK_TOOLTIP),
				getFunc = function() return NBUIDB.NB2_Locked end,
				setFunc = function(value)
					NBUIDB.NB2_Locked = value
					NBUI.NB2MainWindow:SetMovable(not NBUIDB.NB2_Locked)
					end,
				default = NBUI.defaults.NB2_Locked,
				},
			[7]={ -- toggle chat button
				type = "checkbox",
				name =  GetString(SI_NBUI_BUTTON_LABEL),
				tooltip = GetString(SI_NBUI_BUTTON_TOOLTIP),
				getFunc = function() return NBUIDB.NB2_ChatButton end,
				setFunc = function(value) 
					NBUIDB.NB2_ChatButton = value 
					NBUI.NB2MaxChatWin_Button:SetHidden(not NBUIDB.NB2_ChatButton)
					NBUI.NB2MaxChatWin_ButtonTexture:SetHidden(not NBUIDB.NB2_ChatButton)
					NBUI.NB2MinChatWin_Button:SetHidden(not NBUIDB.NB2_ChatButton)
					NBUI.NB2MinChatWin_ButtonTexture:SetHidden(not NBUIDB.NB2_ChatButton) 
					end,
				default = NBUI.defaults.NB2_ChatButton,
				},
			[8]={ -- offset man chat button
				type = "slider",
				name = GetString(SI_NBUI_OFFSETMAX_LABEL),
				tooltip = GetString(SI_NBUI_OFFSETMAX_TOOLTIP),
				min = -300,
				max = -40,
				step = 1,
				getFunc = function() return NBUIDB.NB2_MaxOffsetChatButton end,
				setFunc = function(offset)
					if (NBUIDB.NB2_ChatButton) then
						NBUIDB.NB2_MaxOffsetChatButton = offset
						NBUI.NB2MaxChatWin_Button:SetAnchor(TOPRIGHT, ZO_ChatWindow, TOPRIGHT, NBUIDB.NB2_MaxOffsetChatButton, 7)
					end
				end,						
				disabled = function()
					return not NBUIDB.NB2_ChatButton
				end,
				default = NBUI.defaults.NB2_MaxOffsetChatButton,
				},
			[9]={ -- offset min chat button
				type = "slider",
				name = GetString(SI_NBUI_OFFSETMIN_LABEL),
				tooltip = GetString(SI_NBUI_OFFSETMIN_TOOLTIP),
				min = -400,
				max = 0,
				step = 1,
				getFunc = function() return NBUIDB.NB2_MinOffsetChatButton end,
				setFunc = function(offset)
					if (NBUIDB.NB2_ChatButton) then
						NBUIDB.NB2_MinOffsetChatButton = offset
						NBUI.NB2MinChatWin_Button:SetAnchor(BOTTOMLEFT, ZO_ChatWindowMinBar, BOTTOMLEFT, -3, NBUIDB.NB2_MinOffsetChatButton)
					end
				end,						
				disabled = function()
					return not NBUIDB.NB2_ChatButton
				end,
				default = NBUI.defaults.NB2_MinOffsetChatButton,
				},
			},
		},
		[3]={ -- general category
			type = "submenu",
			name = ZO_HIGHLIGHT_TEXT:Colorize(GetString(SI_NBUI_NB3KEYBIND_LABEL)),
			controls = {
			[1]={ -- general category
				type = "header",
				name = ZO_HIGHLIGHT_TEXT:Colorize(GetString(SI_NBUI_HEADER_GENERAL)),
				},			
			[2]={ -- show title
				type = "checkbox",
				name = GetString(SI_NBUI_SHOWTITLE_LABEL),
				tooltip = GetString(SI_NBUI_SHOWTITLE_TOOLTIP),
				getFunc = function() return NBUIDB.NB3_ShowTitle end,
				setFunc = function(value)
					NBUIDB.NB3_ShowTitle = value
					NBUI.NB3LeftPage_Title:SetHidden(not NBUIDB.NB3_ShowTitle)
					NBUI.NB3LeftPage_Separator:SetHidden(not NBUIDB.NB3_ShowTitle)
					NBUI.NB3Information_Button:SetHidden(not NBUIDB.NB3_ShowTitle)
						if (NBUIDB.NB3_ShowTitle) then
							NBUI.NB3LeftPage_Backdrop:SetDimensions(420, 645)
						else
							NBUI.NB3LeftPage_Backdrop:SetDimensions(420, 690)
						end
					end,
				default = NBUI.defaults.NB3_ShowTitle,
				},						
			[3]={ -- title label
				type = "editbox",
				name = GetString(SI_NBUI_TITLE_LABEL),
				tooltip = GetString(SI_NBUI_TITLE_TOOLTIP),
				getFunc = function() return NBUIDB.NB3_Title end,
				setFunc = function(value)
					NBUIDB.NB3_Title = value
					NBUI.NB3LeftPage_Title:SetText(NBUIDB.NB3_Title)
					end,
				default = NBUI.defaults.NB3_Title,
				},					
			[4]={ -- change book color
				type = "colorpicker",
				name = GetString(SI_NBUI_COLOR_LABEL),
				tooltip = GetString(SI_NBUI_COLOR_TOOLTIP),
				getFunc = function() return unpack(NBUIDB.NB3_BookColor) end,
				setFunc = function(r, g, b, a)
					NBUIDB.NB3_BookColor = {r, g, b, a}
					NBUI.NB3MainWindow_Cover:SetColor(r, g, b, a)
					NBUI.NB3MaxChatWin_ButtonTexture:SetColor(r, g, b, a)
					NBUI.NB3MinChatWin_ButtonTexture:SetColor(r, g, b, a)
					end,
				default = { r = NBUI.defaults.NB3_BookColor[1], g = NBUI.defaults.NB3_BookColor[2], b = NBUI.defaults.NB3_BookColor[3], a = NBUI.defaults.NB3_BookColor[4]},
				},								
			[5] = { -- display dialog
				type = "checkbox",
				name = GetString(SI_NBUI_DIALOG),
				tooltip = GetString(SI_NBUI_DIALOG_TOOLTIP),
				getFunc = function() return NBUIDB.NB3_ShowDialog end,
				setFunc = function(value)
					NBUIDB.NB3_ShowDialog = value
						NBUI.NB3SavePage_Button:SetHandler("OnClicked", function(self)
							if (NBUIDB.NB3_ShowDialog) then
								ZO_Dialogs_ShowDialog("CONFIRM_NBUI_SAVE")
							else
								NBUI.NB3SavePage(self)
							end			
						end)
						NBUI.NB3UndoPage_Button:SetHandler("OnClicked", function()
							if (NBUIDB.NB3_ShowDialog) then
								ZO_Dialogs_ShowDialog("CONFIRM_NBUI_UNDO")
							else
								NBUI.NB3UndoPage()
							end			
						end)
						NBUI.NB3DeletePage_Button:SetHandler("OnClicked", function()
							if (NBUIDB.NB3_ShowDialog) then
								ZO_Dialogs_ShowDialog("CONFIRM_NBUI_DELETE")
							else
								NBUI.NB3DeletePage()
							end			
						end)
						NBUI.NB3NewPage_Button:SetHandler("OnClicked", function(self)
							if (NBUIDB.NB3_ShowDialog) then
								ZO_Dialogs_ShowDialog("CONFIRM_NBUI_NEWPAGE")
							else
								NBUI.NB3NewPage(self)
							end			
						end)					
					end,
				default = NBUI.defaults.NB3_ShowDialog,
				},
			[6]={ -- lock position
				type = "checkbox",
				name = GetString(SI_NBUI_LOCK_LABEL),
				tooltip = GetString(SI_NBUI_LOCK_TOOLTIP),
				getFunc = function() return NBUIDB.NB3_Locked end,
				setFunc = function(value)
					NBUIDB.NB3_Locked = value
					NBUI.NB3MainWindow:SetMovable(not NBUIDB.NB3_Locked)
					end,
				default = NBUI.defaults.NB3_Locked,
				},
			[7]={ -- toggle chat button
				type = "checkbox",
				name =  GetString(SI_NBUI_BUTTON_LABEL),
				tooltip = GetString(SI_NBUI_BUTTON_TOOLTIP),
				getFunc = function() return NBUIDB.NB3_ChatButton end,
				setFunc = function(value) 
					NBUIDB.NB3_ChatButton = value 
					NBUI.NB3MaxChatWin_Button:SetHidden(not NBUIDB.NB3_ChatButton)
					NBUI.NB3MaxChatWin_ButtonTexture:SetHidden(not NBUIDB.NB3_ChatButton)
					NBUI.NB3MinChatWin_Button:SetHidden(not NBUIDB.NB3_ChatButton)
					NBUI.NB3MinChatWin_ButtonTexture:SetHidden(not NBUIDB.NB3_ChatButton) 
					end,
				default = NBUI.defaults.NB3_ChatButton,
				},
			[8]={ -- offset man chat button
				type = "slider",
				name = GetString(SI_NBUI_OFFSETMAX_LABEL),
				tooltip = GetString(SI_NBUI_OFFSETMAX_TOOLTIP),
				min = -300,
				max = -40,
				step = 1,
				getFunc = function() return NBUIDB.NB3_MaxOffsetChatButton end,
				setFunc = function(offset)
					if (NBUIDB.NB3_ChatButton) then
						NBUIDB.NB3_MaxOffsetChatButton = offset
						NBUI.NB3MaxChatWin_Button:SetAnchor(TOPRIGHT, ZO_ChatWindow, TOPRIGHT, NBUIDB.NB3_MaxOffsetChatButton, 7)
					end
				end,						
				disabled = function()
					return not NBUIDB.NB3_ChatButton
				end,
				default = NBUI.defaults.NB3_MaxOffsetChatButton,
				},
			[9]={ -- offset min chat button
				type = "slider",
				name = GetString(SI_NBUI_OFFSETMIN_LABEL),
				tooltip = GetString(SI_NBUI_OFFSETMIN_TOOLTIP),
				min = -400,
				max = 0,
				step = 1,
				getFunc = function() return NBUIDB.NB3_MinOffsetChatButton end,
				setFunc = function(offset)
					if (NBUIDB.NB3_ChatButton) then
						NBUIDB.NB3_MinOffsetChatButton = offset
						NBUI.NB3MinChatWin_Button:SetAnchor(BOTTOMLEFT, ZO_ChatWindowMinBar, BOTTOMLEFT, -3, NBUIDB.NB3_MinOffsetChatButton)
					end
				end,						
				disabled = function()
					return not NBUIDB.NB3_ChatButton
				end,
				default = NBUI.defaults.NB3_MinOffsetChatButton,
				},
			},
		},		
	}
	LAM2:RegisterOptionControls("NBUIOptions", optionsData)
end