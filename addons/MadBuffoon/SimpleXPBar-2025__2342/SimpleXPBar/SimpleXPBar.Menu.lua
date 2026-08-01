function SimpleXPBar:CreateSettingsMenu()
	local LAM2 = LibStub("LibAddonMenu-2.0")
	local panelData = {
		type = "panel",
		name = self.name,
		author = self.author,
		version = self.version,
		registerForRefresh = true,
	}

	local optionsData = 
	{
		{
			type = "checkbox",
			name = GetString(SXPB_PREVIEW),
			width = "full",
			getFunc = function()
				return not SimpleXPBarWindow:IsHidden()
			end,
			setFunc = function(val)
				SimpleXPBarWindow:SetHidden(not val)
			end,
		},
		{
			type = "checkbox",
			name = GetString(SXPB_ACCOUNTWIDE),
			getFunc = function()
				return SimpleXPBar.AWSV.general.account_wide
			end,
			setFunc = function(val)
				if val then
					--load
					SimpleXPBar.AWSV.version = nil
					SimpleXPBar.AWSV = ZO_SavedVars:NewAccountWide("SimpleXPBar_Settings", "1", nil, Terril_lib.DeepCopy(SimpleXPBar.CharSV, SimpleXPBar.default_settings))
					SimpleXPBar.CurSV = SimpleXPBar.AWSV
				else
					SimpleXPBar.CharSV.version = nil
					SimpleXPBar.CharSV = ZO_SavedVars:New("SimpleXPBar_Settings", "1", nil, Terril_lib.DeepCopy(SimpleXPBar.AWSV, SimpleXPBar.default_settings))
					SimpleXPBar.CurSV = SimpleXPBar.CharSV
				end
				SimpleXPBar.AWSV.general.account_wide = val
				SimpleXPBar:UpdateData()
			end,
		},
		{
			type = "checkbox",
			name = GetString(SXPB_HIDE_ORIGINAL),
			width = "full",
			getFunc = function() return SimpleXPBar.CurSV.general.hide_eso_xpbar end,
			setFunc = function(val)
				SimpleXPBar.CurSV.general.hide_eso_xpbar = val
			end,
			disabled = function() return (ImmersionToggles and true or false) end,
		},
		{
			type = "editbox",
			name = GetString(SXPB_CUST_NAME),
			tooltip = GetString(SXPB_CUST_TT),
			width = "full",
			isExtraWide = true,
			isMultiline = false,
			getFunc = function() return SimpleXPBar.CurSV.textbar.text end,
			setFunc = function(val)
				SimpleXPBar.CurSV.textbar.text = val
				SimpleXPBar:UpdateData()
			end,
		},
		{
			type = "description",
			name = GetString(SXPB_CUST_RULES_NAME),
			width = "full",
			text = GetString(SXPB_CUST_RULES),
		},
		{
			type = "submenu",
			name = GetString(SXPB_PBT_NAME),
			controls = 
				{
					{
						type = "checkbox",
						name = GetString(SXPB_GEN_HIDE),
						width = "full",
						getFunc = function() return self.CurSV.textbar.hide end,
						setFunc = function(val)
							self.CurSV.textbar.hide = val
							SimpleXPBar:UpdateControls()
						end,
					},
					{
						type = "dropdown",
						name = GetString(SXPB_GEN_FONT),
						width = "full",
						choices = LMP:List('font'),
						getFunc = function() return SimpleXPBar.CurSV.textbar.font end,
						setFunc = function(val)
							SimpleXPBar.CurSV.textbar.font = val
							SimpleXPBar:UpdateControls()
						end,
					},
					{
						type = "dropdown",
						name = GetString(SXPB_GEN_SIZE),
						width = "full",
						choices = self:FontSizes(),
						getFunc = function() return SimpleXPBar.CurSV.textbar.size end,
						setFunc = function(val)
							SimpleXPBar.CurSV.textbar.size = val
							SimpleXPBar:UpdateControls()
						end,
					},
					{
						type = "dropdown",
						name = GetString(SXPB_GEN_STYLE),
						width = "full",
						choices = self:StyleList(),
						getFunc = function()
							return SimpleXPBar.CurSV.textbar.style
						end,
						setFunc = function(val)
							SimpleXPBar.CurSV.textbar.style = val
							SimpleXPBar:UpdateControls()
						end,
					},
					{
						type = "colorpicker",
						name = GetString(SXPB_GEN_COLOR),
						width = "full",
						getFunc = function()
							return SimpleXPBar.CurSV.textbar.color.r, SimpleXPBar.CurSV.textbar.color.g, SimpleXPBar.CurSV.textbar.color.b, SimpleXPBar.CurSV.textbar.color.a
						end,
						setFunc = function(r, g, b, a)
							SimpleXPBar.CurSV.textbar.color.r = r
							SimpleXPBar.CurSV.textbar.color.b = b
							SimpleXPBar.CurSV.textbar.color.g = g
							SimpleXPBar.CurSV.textbar.color.a = a
							SimpleXPBar:UpdateControls()
						end,
					},
					{
						type = "dropdown",
						name = GetString(SXPB_GEN_POS),
						width = "full",
						choices = SimpleXPBar:GetAnchor(nil),
						getFunc = function() return SimpleXPBar.CurSV.textbar.pos.anchor end,
						setFunc = function(val)
							SimpleXPBar.CurSV.textbar.pos.anchor = val
							SimpleXPBar:UpdateControls()
						end,
					},
					{
						type = "slider",
						name = GetString(SXPB_GEN_HOR),
						min = -100,
						max = 100,
						getFunc = function() return SimpleXPBar.CurSV.textbar.pos.x end,
						setFunc = function(val)
							SimpleXPBar.CurSV.textbar.pos.x = val
							SimpleXPBar:UpdateControls()
						end,
					},
					{
						type = "slider",
						name = GetString(SXPB_GEN_VERT),
						min = -100,
						max = 100,
						getFunc = function() return SimpleXPBar.CurSV.textbar.pos.y end,
						setFunc = function(val)
							SimpleXPBar.CurSV.textbar.pos.y = val
							SimpleXPBar:UpdateControls()
						end,
					},
				},
			},
			{
				type = "submenu",
				name = GetString(SXPB_LRT_NAME),
				controls = 
					{
						{
							type = "checkbox",
							name = GetString(SXPB_GEN_HIDE),
							width = "full",
							getFunc = function() return self.CurSV.textlvl.hide end,
							setFunc = function(val)
								self.CurSV.textlvl.hide = val
								SimpleXPBar:UpdateControls()
							end,
						},
						{
							type = "dropdown",
							name = GetString(SXPB_GEN_FONT),
							width = "full",
							choices = LMP:List('font'),
							getFunc = function() return SimpleXPBar.CurSV.textlvl.font end,
							setFunc = function(val)
								SimpleXPBar.CurSV.textlvl.font = val
								SimpleXPBar:UpdateControls()
							end,
						},
						{
							type = "dropdown",
							name = GetString(SXPB_GEN_SIZE),
							width = "full",
							choices = self:FontSizes(),
							getFunc = function() return SimpleXPBar.CurSV.textlvl.size end,
							setFunc = function(val)
								SimpleXPBar.CurSV.textlvl.size = val
								SimpleXPBar:UpdateControls()
							end,
						},
						{
							type = "dropdown",
							name = GetString(SXPB_GEN_STYLE),
							width = "full",
							choices = self:StyleList(),
							getFunc = function()
								return SimpleXPBar.CurSV.textlvl.style
							end,
							setFunc = function(val)
								SimpleXPBar.CurSV.textlvl.style = val
								SimpleXPBar:UpdateControls()
							end,
						},
						{
							type = "colorpicker",
							name = GetString(SXPB_GEN_COLOR),
							width = "full",
							getFunc = function()
								return SimpleXPBar.CurSV.textlvl.color.r, SimpleXPBar.CurSV.textlvl.color.g, SimpleXPBar.CurSV.textlvl.color.b, SimpleXPBar.CurSV.textlvl.color.a
							end,
							setFunc = function(r, g, b, a)
								SimpleXPBar.CurSV.textlvl.color.r = r
								SimpleXPBar.CurSV.textlvl.color.b = b
								SimpleXPBar.CurSV.textlvl.color.g = g
								SimpleXPBar.CurSV.textlvl.color.a = a
								SimpleXPBar:UpdateControls()
							end,
						},
						{
							type = "dropdown",
							name = GetString(SXPB_GEN_POS),
							width = "full",
							choices = SimpleXPBar:GetAnchor(nil),
							getFunc = function() return SimpleXPBar.CurSV.textlvl.pos.anchor end,
							setFunc = function(val)
								SimpleXPBar.CurSV.textlvl.pos.anchor = val
								SimpleXPBar:UpdateControls()
							end,
						},
						{
							type = "slider",
							name = GetString(SXPB_GEN_HOR),
							min = -100,
							max = 100,
							getFunc = function() return SimpleXPBar.CurSV.textlvl.pos.x end,
							setFunc = function(val)
								SimpleXPBar.CurSV.textlvl.pos.x = val
								SimpleXPBar:UpdateControls()
							end,
						},
						{
							type = "slider",
							name = GetString(SXPB_GEN_VERT),
							min = -100,
							max = 100,
							getFunc = function() return SimpleXPBar.CurSV.textlvl.pos.y end,
							setFunc = function(val)
								SimpleXPBar.CurSV.textlvl.pos.y = val
								SimpleXPBar:UpdateControls()
							end,
						},
					}
			},
			{
				type = "submenu",
				name = GetString(SXPB_BAROPTIONS),
				controls = {
					{
						type = "checkbox",
						name = GetString(SXPB_GEN_HIDE),
						width = "full",
						getFunc = function() return self.CurSV.xpbar.hide end,
						setFunc = function(val)
							self.CurSV.xpbar.hide = val
							SimpleXPBar:UpdateControls()
						end,
					},
					{
						type = "slider",
						name = GetString(SXPB_GEN_WIDTH),
						min = 0,
						max = math.floor(GuiRoot:GetWidth()),
						width = "half",
						getFunc = function() return SimpleXPBar.CurSV.xpbar.size.width end,
						setFunc = function(val)
							SimpleXPBar.CurSV.xpbar.size.width = val
							SimpleXPBar:UpdateControls()
						end,
					},
					{
						type = "slider",
						name = GetString(SXPB_GEN_HEIGHT),
						min = 0,
						max = math.floor(GuiRoot:GetHeight() / 3),
						width = "half",
						getFunc = function() return SimpleXPBar.CurSV.xpbar.size.height end,
						setFunc = function(val)
							SimpleXPBar.CurSV.xpbar.size.height = val
							SimpleXPBar:UpdateControls()
						end,
					},
					{
						type = "slider",
						name = GetString(SXPB_GEN_BORDER),
						min = 0,
						max = 20,
						width = "half",
						getFunc = function() return SimpleXPBar.CurSV.xpbar.size.border end,
						setFunc = function(val)
							SimpleXPBar.CurSV.xpbar.size.border = val
							SimpleXPBar:UpdateControls()
						end,
					},
					{
						type = "slider",
						name = GetString(SXPB_GEN_GAP),
						min = 0,
						max = 20,
						width = "half",
						getFunc = function() return SimpleXPBar.CurSV.xpbar.size.gap end,
						setFunc = function(val)
							SimpleXPBar.CurSV.xpbar.size.gap = val
							SimpleXPBar:UpdateControls()
						end,
					},
					{
						type = "colorpicker",
						name = GetString(SXPB_GEN_BGCLR),
						width = "full",
						getFunc = function()
							return SimpleXPBar.CurSV.xpbar.color.background.r, SimpleXPBar.CurSV.xpbar.color.background.g, SimpleXPBar.CurSV.xpbar.color.background.b, SimpleXPBar.CurSV.xpbar.color.background.a
						end,
						setFunc = function(r, g, b, a)
							SimpleXPBar.CurSV.xpbar.color.background.r = r
							SimpleXPBar.CurSV.xpbar.color.background.b = b
							SimpleXPBar.CurSV.xpbar.color.background.g = g
							SimpleXPBar.CurSV.xpbar.color.background.a = a
							SimpleXPBar:UpdateControls()
						end,
					},
					{
						type = "colorpicker",
						name = GetString(SXPB_GEN_PGCLR),
						width = "full",
						getFunc = function()
							return SimpleXPBar.CurSV.xpbar.color.progress.r, SimpleXPBar.CurSV.xpbar.color.progress.g, SimpleXPBar.CurSV.xpbar.color.progress.b, SimpleXPBar.CurSV.xpbar.color.progress.a
						end,
						setFunc = function(r, g, b, a)
							SimpleXPBar.CurSV.xpbar.color.progress.r = r
							SimpleXPBar.CurSV.xpbar.color.progress.b = b
							SimpleXPBar.CurSV.xpbar.color.progress.g = g
							SimpleXPBar.CurSV.xpbar.color.progress.a = a
							SimpleXPBar:UpdateControls()
						end,
					},
					{
						type = "colorpicker",
						name = GetString(SXPB_GEN_BDRCLR),
						width = "full",
						getFunc = function()
							return SimpleXPBar.CurSV.xpbar.color.border.r, SimpleXPBar.CurSV.xpbar.color.border.g, SimpleXPBar.CurSV.xpbar.color.border.b, SimpleXPBar.CurSV.xpbar.color.border.a
						end,
						setFunc = function(r, g, b, a)
							SimpleXPBar.CurSV.xpbar.color.border.r = r
							SimpleXPBar.CurSV.xpbar.color.border.b = b
							SimpleXPBar.CurSV.xpbar.color.border.g = g
							SimpleXPBar.CurSV.xpbar.color.border.a = a
							SimpleXPBar:UpdateControls()
						end,
					},

				}
			},
	}

	panel = LAM2:RegisterAddonPanel(SimpleXPBar.name .. "OptionsPanel", panelData)
	LAM2:RegisterOptionControls(SimpleXPBar.name .. "OptionsPanel", optionsData)
end
