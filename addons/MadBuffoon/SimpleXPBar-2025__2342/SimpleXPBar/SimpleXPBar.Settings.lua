SimpleXPBar.default_settings = {
	xpbar = {
		hide = false,
		size = {
			width = 388,
			height = 40,
			border = 2,
			gap = 2,
		},
		pos = {
			anchor = TOPLEFT,
			anchor_rel = TOPLEFT,
			x = 25,
			y = 25,
		},
		color = {
			progress = {
				r = 0.5,
				b = 0.5,
				g = 0.5,
				a = 0.9,
			},
			background = {
				r = 0.5,
				b = 0.5,
				g = 0.5,
				a = 0.4,
			},
			border = {
				r = 0.5,
				b = 0.5,
				g = 0.5,
				a = 0.9,
			},
		},
	},

	textbar = {
		hide = false,
		text = GetString(SXPB_CUST_DEFAULT),
		color = {
			r = 200,
			g = 200,
			b = 200,
			a = 0.8,
		},
		pos = {
			anchor = "CENTER",
			x = "0",
			y = "0",
		},
		font = "Abibas",
		size = "20",
		style = "Thick shadow",
	},

	textlvl = {
		hide = false,
		color = {
			r = 200,
			g = 200,
			b = 200,
			a = 0.8,
		},
		pos = {
			anchor = "RIGHT",
			x = "10",
			y = "0",
		},
		font = "Abibas",
		size = "68",
		style = "Thin shadow",
	},

	general = {
		hide_eso_xpbar = true,
		account_wide = false,
	},
}

function SimpleXPBar:LoadSettings()
	SimpleXPBar.AWSV = ZO_SavedVars:NewAccountWide("SimpleXPBar_Settings", "1", nil, SimpleXPBar.default_settings)
	SimpleXPBar.CharSV = ZO_SavedVars:New("SimpleXPBar_Settings", "1", nil, SimpleXPBar.default_settings)

	if SimpleXPBar.AWSV.general.account_wide then
		SimpleXPBar.CurSV = SimpleXPBar.AWSV
		SimpleXPBar.CharSV.version = nil
		SimpleXPBar.CharSV = ZO_SavedVars:New("SimpleXPBar_Settings", "1", nil, Terril_lib.DeepCopy(SimpleXPBar.AWSV, SimpleXPBar.default_settings))
	else
		SimpleXPBar.CurSV = SimpleXPBar.CharSV
	end

	SimpleXPBarWindow:SetHandler("OnMoveStop", function()
		_, self.CurSV.xpbar.pos.anchor, _, self.CurSV.xpbar.pos.anchor_rel, self.CurSV.xpbar.pos.x, self.CurSV.xpbar.pos.y = SimpleXPBarWindow:GetAnchor()
	end)
	--dont check for immersion toggles anymore, just let immersiontoggles do its thing since we've shifted the burden there
	PLAYER_PROGRESS_BAR_FRAGMENT:SetConditional(function() return (not SimpleXPBar.CurSV.general.hide_eso_xpbar) end)
	PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT:SetConditional(function() return (not SimpleXPBar.CurSV.general.hide_eso_xpbar) end)
	
	SimpleXPBarWindow:SetHandler("OnShow", function() SimpleXPBar:UpdateData() end)

	self:CreateSettingsMenu()
	self:ExtendLMP()
	self:UpdateControls()
end

function SimpleXPBar:GetAnchor(anchor_name)
	local anchors = {
		[GetString(SXPB_ANCHOR_RIGHT)] 			= {val=RIGHT, rev=LEFT},
		[GetString(SXPB_ANCHOR_LEFT)] 			= {val=LEFT, rev=RIGHT},
		[GetString(SXPB_ANCHOR_TOPRIGHT)] 		= {val=TOPRIGHT, rev=BOTTOMLEFT},
		[GetString(SXPB_ANCHOR_TOPLEFT)] 		= {val=TOPLEFT, rev=BOTTOMRIGHT},
		[GetString(SXPB_ANCHOR_BOTTOMRIGHT)] 	= {val=BOTTOMRIGHT, rev=TOPLEFT},
		[GetString(SXPB_ANCHOR_BOTTOMLEFT)] 	= {val=BOTTOMLEFT, rev=TOPRIGHT},
		[GetString(SXPB_ANCHOR_CENTER)] 		= {val=CENTER, rev=CENTER},
		[GetString(SXPB_ANCHOR_BOTTOM)] 		= {val=BOTTOM, rev=TOP},
		[GetString(SXPB_ANCHOR_TOP)] 			= {val=TOP, rev=BOTTOM},
	}
	if not anchor_name or anchor_name == "" then
		return Terril_lib.keys(anchors)
	end

	local anchor = anchors[anchor_name]
	if not anchor then return CENTER, CENTER end
	return anchor.rev, anchor.val
end

-- updates all control attributes, except their values
function SimpleXPBar:UpdateControls()
	SimpleXPBarWindow:SetDimensions(self.CurSV.xpbar.size.width, self.CurSV.xpbar.size.height)
	SimpleXPBarWindowBackdrop:SetCenterColor(self.CurSV.xpbar.color.background.r, self.CurSV.xpbar.color.background.g,
											 self.CurSV.xpbar.color.background.b, self.CurSV.xpbar.color.background.a)
	SimpleXPBarWindowBackdrop:SetEdgeColor(self.CurSV.xpbar.color.border.r, self.CurSV.xpbar.color.border.g,
										   self.CurSV.xpbar.color.border.b, self.CurSV.xpbar.color.border.a)
	SimpleXPBarWindowBackdrop:SetEdgeTexture(nil, 2, 2, self.CurSV.xpbar.size.border, nil)

	SimpleXPBarWindowStatusBar:SetColor(self.CurSV.xpbar.color.progress.r, self.CurSV.xpbar.color.progress.g,
										self.CurSV.xpbar.color.progress.b, self.CurSV.xpbar.color.progress.a)

	SimpleXPBarWindowStatusBar:ClearAnchors()
	SimpleXPBarWindowStatusBar:SetAnchor(TOPLEFT,
										 SimpleXPBarWindow,
										 TOPLEFT,
										 self.CurSV.xpbar.size.border + self.CurSV.xpbar.size.gap,
										 self.CurSV.xpbar.size.border + self.CurSV.xpbar.size.gap)
	SimpleXPBarWindowStatusBar:SetAnchor(BOTTOMRIGHT,
										 SimpleXPBarWindow,
										 BOTTOMRIGHT,
										 (self.CurSV.xpbar.size.border + self.CurSV.xpbar.size.gap) * -1,
										 (self.CurSV.xpbar.size.border + self.CurSV.xpbar.size.gap) * -1)
	-- text self.settings
	SimpleXPBarWindowLabel:SetColor(self.CurSV.textbar.color.r, self.CurSV.textbar.color.g,
									self.CurSV.textbar.color.b, self.CurSV.textbar.color.a)
	SimpleXPBarWindowAltLabel:SetColor(self.CurSV.textlvl.color.r, self.CurSV.textlvl.color.g,
									   self.CurSV.textlvl.color.b, self.CurSV.textlvl.color.a)

	SimpleXPBarWindowLabel:ClearAnchors()
	SimpleXPBarWindowAltLabel:ClearAnchors()
	local textbar_anchor, textbar_anchor_r = self:GetAnchor(self.CurSV.textbar.pos.anchor)
	SimpleXPBarWindowLabel:SetAnchor(textbar_anchor, parent, textbar_anchor_r, self.CurSV.textbar.pos.x, self.CurSV.textbar.pos.y)
	local textlvl_anchor, textlvl_anchor_r = self:GetAnchor(self.CurSV.textlvl.pos.anchor)
	SimpleXPBarWindowAltLabel:SetAnchor(textlvl_anchor, parent, textlvl_anchor_r, self.CurSV.textlvl.pos.x, self.CurSV.textlvl.pos.y)

	-->remove in few a weeks (jan 3/4)
	if self.CurSV.textlvl.hide == nil then
		self.CurSV.textlvl.hide = not self.CurSV.textlvl.visible.level
		self.CurSV.textlvl.visible.level = nil
	end
	if self.CurSV.textbar.hide == nil then self.CurSV.textbar.hide = false end
	if self.CurSV.xpbar.hide == nil then self.CurSV.xpbar.hide = false end
	--<remove
	SimpleXPBarWindowAltLabel:SetHidden(self.CurSV.textlvl.hide)
	SimpleXPBarWindowLabel:SetHidden(self.CurSV.textbar.hide)
	SimpleXPBarWindowBackdrop:SetHidden(self.CurSV.xpbar.hide)
	SimpleXPBarWindowStatusBar:SetHidden(self.CurSV.xpbar.hide)

	--set label fonts here
	local textbar_font = self:GetFont(
		self.CurSV.textbar.font, self.CurSV.textbar.size, self.FontStyles[self.CurSV.textbar.style]
	)
	local textlvl_font = self:GetFont(
		self.CurSV.textlvl.font, self.CurSV.textlvl.size, self.FontStyles[self.CurSV.textlvl.style]
	)
	SimpleXPBarWindowLabel:SetFont(textbar_font)
	SimpleXPBarWindowAltLabel:SetFont(textlvl_font)

	-- window anchor
	SimpleXPBarWindow:ClearAnchors()
	SimpleXPBarWindow:SetAnchor(self.CurSV.xpbar.pos.anchor,
								parent,
								self.CurSV.xpbar.pos.anchor_rel,
								self.CurSV.xpbar.pos.x, self.CurSV.xpbar.pos.y)
end