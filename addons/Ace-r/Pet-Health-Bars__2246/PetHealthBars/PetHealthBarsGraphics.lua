function PHB.UIUtil.bar(id, parent, width, height, offset)
	if parent == nil then return end
	if (id < 1 or id > 7 ) then return end
	local bar = {}
	bar = {
		hp = 0,
		hpmax  = 0,
		shield = 0,
		id = id,
		unitTag = "playerpet"..id,
		
		_back = PHB.UIUtil._backdrop("PHBBar"..id.."Back", parent, {offset[1],offset[2]+height}, {0.1,0.1,0.1,0.7}, {0.1,0.1,0.1,1}),
		_bar = PHB.UIUtil._bar("PHBBar"..id.."Bar", parent, {offset[1],offset[2]+height}, {0.7, 0.2, 0.7}, 0.8),
		_shieldBar = PHB.UIUtil._bar("PHBBar"..id.."ShieldBar", parent, {offset[1],offset[2]-1+height*1.5}, {0.7, 0.2, 0.2}, 0.5),
		_label1 = PHB.UIUtil._label("PHBBar"..id.."Label1", parent, {offset[1],offset[2]+height}, "$(BOLD_FONT)|$(KB_19)|soft-shadow-thin", 1),
		_label2 = PHB.UIUtil._label("PHBBar"..id.."Label2", parent, offset, "$(BOLD_FONT)|$(KB_22)|soft-shadow-thick", 1),
		
		Update = function(self, hp, hpmax, shield, format, formatShield)
			self:SetMax(hpmax)
			self:SetHp(hp)
			self:SetShield(shield)
			self:SetText(self.hp, self.hpmax, self.shield, format, formatShield)
			
			self:SetHidden(self.hpmax < 1)
			if self.hp == 0 then self:SetShield(0) end
			
		end,
		
		Demo = function(self, format, formatShield)
			local d = {
				{99999, 99999, 0},
				{12345, 678690, 0},
				{20000, 30000, 5500},
				{500, 2000, 1200},
				{50000, 50000, 10000},
			}
			local i = d[self.id%5+1]
			self:Update(i[1], i[2], i[3], format, formatShield)
		end,
		
		SetWidth = function(self, w)
			self._back:SetWidth(w)
			self._bar:SetWidth(w-2)
			self._shieldBar:SetWidth(w-2)
			self._label1:SetWidth(w)
			self._label2:SetWidth(w)
		end,
		
		SetHeight = function(self, h)
			self._back:SetHeight(h)
			self._bar:SetHeight(h-2)
			self._shieldBar:SetHeight((h-2)*0.5)
			self._label1:SetHeight(h)
			self._label2:SetHeight(h)
		end,
		
		SetBarColor = function(self, c)
			self._bar:SetColor(c[1], c[2], c[3])
			self._bar:SetAlpha(c[4])
		end,

		SetShieldColor = function(self, c)
			self._shieldBar:SetColor(c[1], c[2], c[3])
			self._shieldBar:SetAlpha(c[4])
		end,
		
		SetFontSize = function(self, f)
			self._label1:SetFont("$(BOLD_FONT)|$(KB_"..f..")|soft-shadow-thin")
			self._label2:SetFont("$(BOLD_FONT)|$(KB_"..(f+3)..")|soft-shadow-thick")
		end,
		
		SetMax = function(self, max)
			self.hpmax = max
			self._bar:SetMinMax(0, self.hpmax)
			self._shieldBar:SetMinMax(0, self.hpmax)
		end,
	
		SetHp = function(self, val)
			self.hp = val
			ZO_StatusBar_SmoothTransition(self._bar, self.hp, self:GetMax(), false, nil, 100)
		end,

		SetShield = function(self, s)
			if s < 0 then return end
			self.shield = s
			ZO_StatusBar_SmoothTransition(self._shieldBar, self.shield, self:GetMax(), false, nil, 100)
		end,

		SetText = function(self, val, max, s, format, formatShield)
			local text
			if self.shield > 0 then 
				text = zo_strformat(formatShield, val, max, s)
			else
				text = zo_strformat(format, val, max)
			end
			self._label1:SetText(text)
			self._label2:SetText(GetUnitName(self.unitTag))
		end,
		
        SetHidden = function(self, state)
			if self.hpmax < 1 then state = true end
            self._back:SetHidden(state)
            self._bar:SetHidden(state)
            self._shieldBar:SetHidden(state)
            self._label1:SetHidden(state)
			self._label2:SetHidden(state)
        end,
		
		GetMax = function(self)
			min, max = self._bar:GetMinMax()
			return max
		end,
	}
	
	return bar
end

function PHB.UIUtil.backdrop(name, parent, offset, centerColor, edgeColor)
	if parent == nil then return end
	local bd = {}
	bd = {
		back = PHB.UIUtil._backdrop(name, parent, offset, centerColor, edgeColor),
		
		SetHeight = function(self, x)
			self.back:SetHeight(x)
		end,
		
		SetWidth = function(self, x)
			self.back:SetWidth(x)
		end,
		
		GetHeight = function(self)
			return self.back:GetHeight()
		end,
		
		GetWidth = function(self)
			return self.back:GetWidth()
		end,
	}
	return bd
end

function PHB.UIUtil._bar(name, parent, offset, color, alpha)
	if parent == nil then return end
	local b = parent:CreateControl(name, CT_STATUSBAR)
    b:ClearAnchors()
	b:SetAnchor(TOPLEFT, parent, TOPLEFT, offset[1], offset[2])
	b:SetColor(unpack(color))
	b:SetAlpha(alpha)
	return b
end

function PHB.UIUtil._label(name, parent, offset, font, valign)
	if parent == nil then return end
	local l = parent:CreateControl(name, CT_LABEL)
    l:ClearAnchors()
	l:SetAnchor(TOPLEFT, parent, TOPLEFT, offset[1], offset[2])
	l:SetAlpha(1)
	l:SetFont(font)
	l:SetDrawLayer(DL_TEXT)
	l:SetVerticalAlignment(valign)
	return l
end

function PHB.UIUtil._backdrop(name, parent, offset, centerColor, edgeColor)
	if parent == nil then return end
	local back = parent:CreateControl(name, CT_BACKDROP)
    back:ClearAnchors()
    back:SetAnchor(TOPLEFT, parent, TOPLEFT, offset[1]-1, offset[2]-1)
    back:SetEdgeTexture("", 8,1,0)
    back:SetEdgeColor(unpack(edgeColor))
    back:SetCenterColor(unpack(centerColor))
	return back
end