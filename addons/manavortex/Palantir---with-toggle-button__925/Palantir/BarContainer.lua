------------------
-- BarContainer Object
PalantirHUD.BarContainer = ZO_Object:Subclass()

-- rest is local
local BC = PalantirHUD.BarContainer
local Chain = PalantirHUD.Chain

local global_padding = 220
local bars_spacing = 24
local text_padding = 120
local text_height = 13

-- Create and Initialize a NEW Bar Container Object (OOP FTW)
function BC:New(parent, side)
	local self = ZO_Object.New( self )
	
	self.parent = parent

	if side == 0 then
		self.file = "Palantir\\textures\\left.dds"
		self.dir = -1
		self.text_anchor = TOPRIGHT
	else
		self.file = "Palantir\\textures\\right.dds"
		self.dir = 1
		self.text_anchor = TOPLEFT
	end

	-- control to hold all child elements
	self.container = Chain( WINDOW_MANAGER:CreateControl( nil, self.parent, CT_CONTROL ) )
		:SetAnchor( CENTER, self.parent, CENTER, self.dir*global_padding, 0 )
	.__END

	self.bars = {}
	
	return self
end

function BC:Update()
	-- first build ordered list of visible bars
	local activeBars = {}
	for index, bar in ipairs(self.bars) do
		if not bar.container:IsHidden() then
			table.insert(activeBars, bar)
		end
	end

	local barsCount = #activeBars
	for index, bar in ipairs(activeBars) do
		bar.container:ClearAnchors()
		bar.container:SetAnchor( CENTER, self.container, CENTER, ( (index-1) - (#activeBars-1)/2 ) * bars_spacing * self.dir, 0 )
		-- TODO: position of text
		if bar.text then
			bar.text:ClearAnchors()
			bar.text_ext:ClearAnchors()
			bar.text_ext:SetAnchor( self.text_anchor, bar.container, CENTER, self.dir*((#activeBars-1) * bars_spacing - text_height/2), text_padding - text_height * index*2   )
			bar.text:SetAnchor( self.text_anchor, bar.container, CENTER,     self.dir*((#activeBars-1) * bars_spacing )               , text_padding - text_height*(index*2+1) )
		end
	end
end
