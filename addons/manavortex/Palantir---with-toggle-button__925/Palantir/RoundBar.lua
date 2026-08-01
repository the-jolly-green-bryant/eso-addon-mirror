------------------
-- RoundBar Object
PalantirHUD.RoundBar = ZO_Object:Subclass()

-- rest is local
local RB = PalantirHUD.RoundBar
local Chain = PalantirHUD.Chain
local str_format = string.format

local texture = {
	th = 256, -- texture height
	tw = 256, -- texture width
	h = 190,  -- one element height
	w = 64,   -- one element width
	ft = 6,   -- filler top pixel
	fb = 183, -- filler bottom pixel
}

local barHeight = texture.fb - texture.ft

local bg_colour		= { r=0.01, g=0, b=0 }
local bg_err_colour	= { r=1,    g=0, b=0 }

-- Create and Initialize a NEW Bar Object (OOP FTW)
function RB:New(parent)
	local self = ZO_Object.New( self )

	self.parent = parent
	
	table.insert(self.parent.bars, self)

	-- control to hold all child elements
	self.container = WINDOW_MANAGER:CreateControl( nil, self.parent.container, CT_CONTROL )
	self.container:SetHidden(false)
	--[[
	container
		|-- bg
		|	|-- fill
		|	|-- sfill
		|	|-- regen
		|	|-- degen
		|-- text
		|-- text_ext
	]]--

	self.bg = Chain( WINDOW_MANAGER:CreateControl( nil, self.container, CT_TEXTURE ) )
		:SetAnchor( CENTER )
		:SetDimensions( texture.w, texture.h )
		:SetTexture( self.parent.file )
		:SetTextureCoords(0, texture.w/texture.tw, 0, texture.h/texture.th )
		:SetColor(bg_colour.r, bg_colour.g, bg_colour.b)
	.__END

	self.fill = Chain( WINDOW_MANAGER:CreateControl( nil, self.bg, CT_TEXTURE ) )
		:SetAnchor( BOTTOM, self.bg, BOTTOM, 0, texture.fb-texture.h )
		:SetTexture( self.parent.file )
	.__END

	self.regen = Chain( WINDOW_MANAGER:CreateControl( nil, self.bg, CT_TEXTURE ) )
		:SetAnchor( CENTER )
		:SetDimensions( texture.w, texture.h )
		:SetTexture( self.parent.file )
		:SetTextureCoords(2*texture.w/texture.tw, 3*texture.w/texture.tw, 0, texture.h/texture.th )
		:SetHidden( true )
	.__END
	self.regenAnimation = ZO_AlphaAnimation:New(self.regen)

	self.degen = Chain( WINDOW_MANAGER:CreateControl( nil, self.bg, CT_TEXTURE ) )
		:SetAnchor( CENTER )
		:SetDimensions( texture.w, texture.h )
		:SetTexture( self.parent.file )
		:SetTextureCoords(3*texture.w/texture.tw, 4*texture.w/texture.tw, 0, texture.h/texture.th )
		:SetHidden( true )
	.__END
	self.degenAnimation = ZO_AlphaAnimation:New(self.degen)

	self.sfill = nil
	
	self.error = false
	self.values = {1,1,1}
	self.shield = nil
	self.text = nil
	
	return self
end

function RB:CreateShield()
	self.sfill = Chain( WINDOW_MANAGER:CreateControl( nil, self.bg, CT_TEXTURE ) )
		:SetTexture( self.parent.file )
		:SetColor(1, 0.57, 0 )
	.__END

	self.shield = 0
end

function RB:CreateText()
	self.text = Chain( WINDOW_MANAGER:CreateControl( nil, self.container, CT_LABEL ) )
		:SetText( '100%' )
		:SetFont('$(ANTIQUE_FONT)|13|soft-shadow-thin')
	.__END
	self.text_ext = Chain( WINDOW_MANAGER:CreateControl( nil, self.container, CT_LABEL ) )
		:SetText( '1234/1234' )
		:SetFont('$(ANTIQUE_FONT)|13|soft-shadow-thin')
	.__END
end

-- set value of the bar
function RB:SetValue(powerValue, powerMax, powerEffectiveMax)
	self.values = {powerValue, powerMax, powerEffectiveMax}
	self:_UpdateBar()
end

-- update shield values
function RB:UpdateShield( shield )
	if self.shield == nil then return end
	self.shield = shield or 0
	self:_UpdateBar()
end

-- blink red fast
function RB:OnError()
	if self.error then return end

	self.error = true
	self.bg:SetColor(bg_err_colour.r, bg_err_colour.g, bg_err_colour.b)

	zo_callLater(function()
		self.bg:SetColor(bg_colour.r, bg_colour.g, bg_colour.b)
		zo_callLater(function() self.error = false end, 200)
		end, 300 )

end

-- set regen/degen display
function RB:SetRegen(value)
	self.regen:SetHidden( value <= 0 )
	self.degen:SetHidden( value >= 0 )
	-- make animaition
	if value > 0 then
		self.regenAnimation:PingPong(0.1, 1.0, 300, nil, nil)
		self.degenAnimation:Stop()
	elseif value < 0 then
		self.regenAnimation:Stop()
		self.degenAnimation:PingPong(0.1, 1.0, 300, nil, nil)
	else
		self.regenAnimation:Stop()
		self.degenAnimation:Stop()
	end
	
end

-- proxy functions
function RB:SetHidden( isHidden )
	self.container:SetHidden( isHidden )
	self.parent:Update()
end

function RB:SetColor(r, g, b, a)
	self.fill:SetColor(r, g, b, a or 1)
	if self.text then
		self.text:SetColor(r, g, b, a or 1)
		self.text_ext:SetColor(r, g, b, a or 1)
	end
end

-- private functions

function RB:_UpdateBar()
	local value, _, valueMax = unpack(self.values)
	local shield = self.shield or 0

	if shield > 0 then
		local bpct = value  / ( valueMax + shield )
		local spct = shield / ( valueMax + shield )
		local vpct = valueMax / ( valueMax + shield )
		self.fill:SetDimensions( texture.w, barHeight*bpct )
		self.sfill:SetDimensions( texture.w, barHeight*spct )
		self.fill:SetTextureCoords(texture.w/texture.tw, 2*texture.w/texture.tw, (texture.fb - barHeight*bpct)/texture.th, texture.fb/texture.th )
		self.sfill:SetTextureCoords(texture.w/texture.tw, 2*texture.w/texture.tw, (texture.fb - barHeight*(vpct+spct))/texture.th, (texture.fb - barHeight*vpct)/texture.th )
		self.sfill:ClearAnchors()
		self.sfill:SetAnchor( BOTTOM, self.bg, BOTTOM, 0, texture.fb-texture.h-barHeight*vpct )
		self.sfill:SetHidden(false)
	else
		local pct = value / valueMax
		self.fill:SetDimensions( texture.w, barHeight*pct )
		self.fill:SetTextureCoords(texture.w/texture.tw, 2*texture.w/texture.tw, (texture.fb - barHeight*pct)/texture.th, texture.fb/texture.th )
		if self.sfill then self.sfill:SetHidden(true) end
	end

	if self.text then
		self.text:SetText( str_format("%d%%", 100*value/valueMax ) )
		self.text_ext:SetText( str_format("%d/%d", value, valueMax ) )
	end
end
