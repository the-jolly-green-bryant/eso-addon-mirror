Squishy = {
	containerIndex = 0,
	rowIndex = 0,

	colors = {
		darkGreen = {0.1058,0.3372,0.0274,0.5},
		darkGrey = {0.0274,0.0784,0.0117,0.5}
	}
}


-- function r(r,g,b){
--   pack = [];
--   Array.from(arguments).forEach(function(color){
--     pack.push(((100/255*color)/100).toFixed(4))
--   });
--   return pack.join(',')
-- }

local function rgbToHex(rgb)
	local hexadecimal = ''

	for key, value in pairs(rgb) do
		local hex = ''

		while(value > 0)do
			local index = math.fmod(value, 16) + 1
			value = math.floor(value / 16)
			hex = string.sub('0123456789ABCDEF', index, index) .. hex			
		end

		if(string.len(hex) == 0)then
			hex = '00'

		elseif(string.len(hex) == 1)then
			hex = '0' .. hex
		end

		hexadecimal = hexadecimal .. hex
	end

	return hexadecimal
end


-------
-- Row
-------

Squishy.Row = ZO_Object:Subclass()

function Squishy.Row:New(...)
	-- d('Squishy.Row:New()')
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function Squishy.Row:Initialize(control,index,key,colorGroup)

	-- d('Squishy.Row:Initialize() '..index)

	self.parentControl = control
	self.controlBaseName = 'squishyRow'..key..tostring(index)

	self.width = 140
	self.index = index
	self.key = key
	self.ready = false
	self.color = colorGroup

	-- d(WINDOW_MANAGER:GetControlByName(self.controlBaseName))

	if WINDOW_MANAGER:GetControlByName(self.controlBaseName) then
		self.bar = WINDOW_MANAGER:GetControlByName(self.controlBaseName)
		self.barLabel = WINDOW_MANAGER:GetControlByName(self.controlBaseName..'BarLabel')
		self.pip = WINDOW_MANAGER:GetControlByName(self.controlBaseName..'Pip')
	else 
		self:CreateBar()
	end
    -- Squishy.rowIndex = Squishy.rowIndex + 1

end


function Squishy.Row:CreateBar()

	-- d('Created '..self.controlBaseName)

	local inc = self.index-1

	self.bar = WINDOW_MANAGER:CreateControl(self.controlBaseName, self.parentControl, CT_STATUSBAR)
    self.bar:SetDimensions(self.width, 25)
    self.bar:SetAnchor(TOPLEFT, self.parentControl, TOPLEFT, 0, (inc*25))
    self.bar:SetMinMax(0,100)
    self.bar:SetHidden(false)
    self.bar:SetInheritAlpha(false)
    self.bar:SetTextureCoords(0,1,0,1)

    self.barLabel = WINDOW_MANAGER:CreateControl(self.controlBaseName..'BarLabel', self.bar, CT_LABEL)
    self.barLabel:SetFont('$(CHAT_FONT)|15|soft-shadow-thick')
    self.barLabel:ClearAnchors()
    self.barLabel:SetAnchor(CENTER, self.bar, CENTER, -5, 0)
    self.barLabel:SetHorizontalAlignment(2)
    self.barLabel:SetVerticalAlignment(1)
    self.barLabel:SetDimensions(self.width,25)
    self.barLabel:SetInheritAlpha(false)


    self.pip = WINDOW_MANAGER:CreateControl(self.controlBaseName..'Pip', self.barLabel, CT_TEXTURE)
    self.pip:ClearAnchors()
    self.pip:SetAnchor(TOPLEFT, self.bar, TOPLEFT, 0, 0)
    self.pip:SetDrawTier(1)
    self.pip:SetHidden(true)
    self.pip:SetInheritAlpha(false)
    self.pip:SetDimensions(25,25)
    self.pip:SetTexture('Ultibomb/ui/ub-corner.dds')
    self.pip:SetVertexColors(1,0,0,0,0.2)
    self.pip:SetColor(0,0,0,0.3)

end

function Squishy.Row:SnapTo(control)
	self.bar:ClearAnchors()
    self.bar:SetAnchor(TOP, control, BOTTOM, 0, 0)
end

function Squishy.Row:UnsetReady()
	self.ready = false
	self.barLabel:SetFont('$(CHAT_FONT)|15|soft-shadow-thick')
	self.barLabel:SetHeight(25)
	self.bar:SetHeight(25)
	self.bar:SetAlpha(1)
    self.barLabel:SetHorizontalAlignment(2)
    self.barLabel:SetSimpleAnchorParent(-5,0)
    self.pip:SetHidden(true)
end

function Squishy.Row:Hide()
	self.bar:SetHidden(true)
	self.barLabel:SetHidden(true)
	self.pip:SetHidden(true)
end

function Squishy.Row:SetReady()
	self.ready = true
	self.bar:SetColor(self.color.r,self.color.g,self.color.b,1)
	self.barLabel:SetFont('$(CHAT_FONT)|22|soft-shadow-thick')
	self.barLabel:SetHeight(32)
	self.bar:SetHeight(32)
	self.bar:SetAlpha(0.8)
    self.barLabel:SetHorizontalAlignment(0)
    self.barLabel:SetSimpleAnchorParent(22,0)
    self.barLabel:SetColor(255,255,255)
    self.pip:SetHidden(false)
end

function Squishy.Row:SetInactive()
	self.bar:SetAlpha(0.2)
	self.barLabel:SetAlpha(0.3)
	self.pip:SetAlpha(0.1)
end

function Squishy.Row:SetBarValue(name,value)

	if value < 100 and self.ready then
		self:UnsetReady()
	end

	self.value = value
	self.bar:SetValue(value)
	self.bar:SetColor(self.color.r,self.color.g,self.color.b,(0.4/100*value)+0.05)

	local unit = math.floor(190/100*value)

	if unit < 65 then unit = 65 end
	if value == 100 then unit = 255 end

	local color = '|c'..rgbToHex({unit,unit,unit})

	unit = 1/255*unit
	alpha = (0.6/100*value)+0.2
	alpha = 1

	self.barLabel:SetColor(unit,unit,unit,alpha)

	value = tostring(value)..'%'

	if self.value >= 100 then 
		self:SetReady()
		value = ''
	end

	self.barLabel:SetText(name..' '..value)
	self.bar:SetHidden(false)
	self.barLabel:SetHidden(false)

end

-------
-- Container
-------

Squishy.Container = ZO_Object:Subclass()

function Squishy.Container:New(...)
	-- d('Squishy.Container:New()')
    local object = ZO_Object.New(self)
    Squishy.containerIndex = Squishy.containerIndex + 1
    object:Initialize(...)
    return object
end

function Squishy.Container:Initialize(control, label, colorGroup)

	-- d('Squishy.Container:Initialize()')

	self.parentControl = control
	self.label = label
	self.controlBaseName = 'squishyContainer'..tostring(Squishy.containerIndex)

	self.width = 180

	self.color = colorGroup
	self.rows = {}

	self:CreateHeader()
	self:CreateBody()

end

function Squishy.Container:GetLabel()
	return self.label
end

function Squishy.Container:SetHidden( option )


	self.header:SetHidden(option)
	self.headerLabel:SetHidden(option)
	self.body:SetHidden(option)
	self.warningLabel:SetHidden(option)
	self.ultiLabel:SetHidden(option)

end


function Squishy.Container:CreateHeader()

	self.header = WINDOW_MANAGER:CreateControl(self.controlBaseName, self.parentControl, CT_BACKDROP)
    self.header:SetDimensions(self.width, 35)
    self.header:ClearAnchors()
    self.header:SetAnchor(TOPLEFT, self.parentControl, TOPLEFT, 0, 0)
    self.header:SetCenterColor(ZO_ColorDef:New(0,0,0,1):UnpackRGBA())
    self.header:SetEdgeColor(ZO_ColorDef:New(0,0,0,0):UnpackRGBA())
    self.header:SetHidden(false)

    self.headerLabel = WINDOW_MANAGER:CreateControl(self.controlBaseName..'Label', self.header, CT_LABEL)
    self.headerLabel:SetFont('$(CHAT_FONT)|16|soft-shadow-thick')
    self.headerLabel:ClearAnchors()
    self.headerLabel:SetAnchor(CENTER, self.header, CENTER, 0, 0)
    self.headerLabel:SetHorizontalAlignment(1)
    self.headerLabel:SetVerticalAlignment(1)
    self.headerLabel:SetDimensions(self.width,35)

end

function Squishy.Container:HideAllRows()
	for i in pairs(self.rows) do
		self.rows[i]:Hide()
	end
end

function Squishy.Container:SetHeaderCount(index, total)

	local color = '|c999999'

	if index > 0 then
		color = self.color.zo
	end

	if total > 0 then
		self.ultiLabel:SetHidden(false)
		self.warningLabel:SetHidden(true)
		self:AdjustBodyHeight( total )
	else
		self.ultiLabel:SetHidden(true)
		self.warningLabel:SetHidden(false)
		self.body:SetHeight(25)
	end

	self.headerLabel:SetText('|c555555'..self.label..color..' '..tostring(index)..' |c555555/ '..total)
end

function Squishy.Container:CreateBody()

	self.body = WINDOW_MANAGER:CreateControl(self.controlBaseName..'Body', self.parentControl, CT_BACKDROP)
    self.body:SetDimensions(self.width, 35)
    self.body:ClearAnchors()
    self.body:SetAnchor(TOP, self.header, BOTTOM, 0, 0)
    self.body:SetCenterColor(ZO_ColorDef:New(0,0,0,0.7):UnpackRGBA())
    self.body:SetEdgeColor(ZO_ColorDef:New(0,0,0,0):UnpackRGBA())
    self.body:SetHidden(false)

    self.warningLabel = WINDOW_MANAGER:CreateControl(self.controlBaseName..'WarningLabel', self.body, CT_LABEL)
    self.warningLabel:SetFont('$(CHAT_FONT)|15|soft-shadow-thick')
    self.warningLabel:ClearAnchors()
    self.warningLabel:SetAnchor(CENTER, self.body, CENTER, 0, 0)
    self.warningLabel:SetHorizontalAlignment(1)
    self.warningLabel:SetVerticalAlignment(1)
    self.warningLabel:SetDimensions(self.width,55)
    self.warningLabel:SetText(self.color.zo..'No '..self.label)
    self.warningLabel:SetAlpha(0.5)
    self.warningLabel:SetHidden(true)

    self.ultiLabel = WINDOW_MANAGER:CreateControl(self.controlBaseName..'UltiLabel', self.body, CT_LABEL)
    self.ultiLabel:SetFont('$(CHAT_FONT)|18|soft-shadow-thick')
    self.ultiLabel:ClearAnchors()
    self.ultiLabel:SetAnchor(TOP, self.body, TOP, 0, 5)
    self.ultiLabel:SetHorizontalAlignment(1)
    self.ultiLabel:SetVerticalAlignment(1)
    self.ultiLabel:SetDimensions(self.width,35)
    self.ultiLabel:SetText(self.color.zo..'No '..self.label)
    self.ultiLabel:SetAlpha(1)
    self.ultiLabel:SetHidden(true)

    self:SetHeaderCount(0,0)

end

function Squishy.Container:GetBody()
	return self.body
end

function Squishy.Container:SnapTo(control)
	self.header:ClearAnchors()
	self.relativeControl = control
    self.header:SetAnchor(TOP, control, BOTTOM, 0, 0)
	-- self.header:SetAnchor(BOTTOMLEFT, control, TOPRIGHT, 0, 0)
end

function Squishy.Container:RenderHorz(mainHeader)
	local control = self.relativeControl or self.parentControl

	self.header:ClearAnchors()

	if mainHeader then
		self.header:SetAnchor(TOP, UltibombGUIBlankHeader, BOTTOM, 0, 0)
	else
		self.header:SetAnchor(TOPLEFT, control, TOPRIGHT, 0, -35)
	end
end

function Squishy.Container:RenderVertical(mainHeader)
	local control = self.relativeControl or self.parentControl

	self.header:ClearAnchors()

	if mainHeader then
		self.header:SetAnchor(TOP, UltibombGUIBlankHeader, BOTTOM, 0, 0)
	else
		self.header:SetAnchor(TOP, control, BOTTOM, 0, 0)
	end
end

function Squishy.Container:AdjustBodyHeight( total )
	
	local height = (25 * total)

	-- for i in pairs(self.rows) do

	-- 	local bar =self.rows[i].bar

	-- 	if i > 1 then
	-- 		self.rows[i]:SnapTo( self.rows[i-1].bar )
	-- 		-- d(self.rows[i].bar)
	-- 	end

	-- 	if not bar:IsHidden() then
	-- 		height = height + bar:GetHeight()
	-- 	end
	-- end

	self.ultiLabel:SetHeight(height + 25)

	self:GetBody():SetHeight(height + 15)

end

function Squishy.Container:CreateRow()
	-- d('Squishy.Container:CreateRow() '..tostring(#self.rows+1))
	local row = Squishy.Row:New(self:GetBody(),#self.rows+1,self.label,self.color)
	self.rows[#self.rows+1] = row

	zo_callLater(function() self:AdjustBodyHeight() end,500)

	-- d('Finish row')
	return self.rows[#self.rows]
end