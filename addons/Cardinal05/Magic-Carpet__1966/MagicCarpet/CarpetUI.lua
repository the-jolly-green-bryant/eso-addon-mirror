------[[ Namespaces ]]------


if not MagicCarpet then MagicCarpet = { } end
local MC = MagicCarpet

if not MC.CarpetUI then MC.CarpetUI = ZO_Object.New( ZO_Object:Subclass() ) end


------[[ Locals ]]------


local WM = WINDOW_MANAGER
local NS = "MC_CarpetUI"

local PI = math.pi
local TWO_PI = 2 * PI

local ANIM_HANDLE = NS .. "_Anim"
local REFRESH_HANDLE = NS .. "_Refresh"

local TROPHY_TIMELINE = 4000
local TROPHY_FLARE_TIMELINE = 16000
local TROPHY_FLARE = 4000
local TROPHY_FLARE_ROTATION_RANGE = math.rad( 80 )
local TROPHY_SPARKLES = 5
local TROPHY_SPARKLE_TIMELINE = 2000

local COLOR_CARPET_BG = ZO_ColorDef:New(ZO_ColorDef.HexToFloats("ffffff"))
local COLOR_CARPET_FG = ZO_ColorDef:New(ZO_ColorDef.HexToFloats("444444"))

local playerX, playerY, playerZ = 1, 1, 1


------[[ Methods ]]------


function MC.CarpetUI:UpdateAnimations( force )
	if not force and self.Window:IsHidden() then
		EVENT_MANAGER:UnregisterForUpdate( ANIM_HANDLE )
		return
	end

	local gt = GetGameTimeMilliseconds()
	local interval = math.sin( ( gt % 30000 ) / 30000 * TWO_PI )

	if not self.TrophyOverlay:IsHidden() then
		local int1, int2 = ( ( gt % TROPHY_TIMELINE ) / TROPHY_TIMELINE ), ( ( ( gt + 500 ) % TROPHY_TIMELINE ) / TROPHY_TIMELINE )
		local sin1, sin2 = math.sin( int1 * TWO_PI ), math.sin( int2 * TWO_PI )

		self.TrophyOverlay:SetVertexColors( 2 + 8, 1, 1, 1, zo_clamp( 0.9 * sin1, 0.2, 0.9 ) )
		self.TrophyOverlay:SetVertexColors( 1 + 4, 1, 1, 1, zo_clamp( 0.9 * sin2, 0.2, 0.9 ) )
	end

	if not self.TrophyFlare:IsHidden() then
		local repeatTime = ( ( gt % TROPHY_FLARE_TIMELINE ) / TROPHY_FLARE_TIMELINE )
		if 0 <= repeatTime and 0.25 > repeatTime then
			local int1 = ( ( gt % TROPHY_FLARE ) / TROPHY_FLARE )
			local sin1 = math.sin( int1 * TWO_PI )

			if math.pi >= int1 then
				self.TrophyFlare:SetTextureRotation( int1 * PI )
				self.TrophyFlare:SetScale(1 - 0.2 * int1)
			end
			self.TrophyFlare:SetAlpha( 0.4 * sin1 )
		else
			self.TrophyFlare:SetAlpha( 0 )
		end
	end

	if not self.TrophySparkles[1]:IsHidden() then
		local delta, interval, sparkle

		for index = 1, TROPHY_SPARKLES do
			delta = ( ( ( gt % TROPHY_SPARKLE_TIMELINE ) + index * ( TROPHY_SPARKLE_TIMELINE / TROPHY_SPARKLES ) ) / TROPHY_SPARKLE_TIMELINE )
			interval = math.sin( delta * TWO_PI )
			sparkle = self.TrophySparkles[index]

			sparkle:SetAlpha( interval )
			if -0.8 >= interval then
				interval = TWO_PI * math.random()
				sparkle:SetSimpleAnchorParent( 48 + 64 * math.sin( interval ), 32 + 64 * math.cos( interval ) )
				sparkle:SetTextureRotation( 0.5 * math.pi * math.random() )
			end
		end
	end
end


function MC.CarpetUI:Show()
	if not MC.Engine:CanSetMode() then
		self:Hide()
		return false
	end

	if nil == self:GetSelectedMode() then self:SelectDefaultMode() end
	self:Refresh( true )
	self:UpdateAnimations( true )
	self.Window:SetHidden( false )

	EVENT_MANAGER:RegisterForUpdate( ANIM_HANDLE, 33, function() self:UpdateAnimations() end )
	return true
end


function MC.CarpetUI:Hide()
	EVENT_MANAGER:UnregisterForUpdate( ANIM_HANDLE )
	EVENT_MANAGER:UnregisterForUpdate( REFRESH_HANDLE )

	if self.Window then self.Window:SetHidden( true ) end
end

function MC.CarpetUI:IsHidden()
	return not self.Window or self.Window:IsHidden()
end

function MC.CarpetUI:QueueRefresh()
	if self:IsHidden() then return end
	EVENT_MANAGER:RegisterForUpdate( REFRESH_HANDLE, 1000, function() MC.CarpetUI:Refresh() end )
end

local currentScrollOffset = 1
local function SaveScrollOffset()
	local slider = MC.CarpetUI.ComponentsSlider
	currentScrollOffset = slider:GetValue()
	if currentScrollOffset < 1 then currentScrollOffset = 1 end
end

local function RefreshScroll()
	local sliderBackdrop = MC.CarpetUI.ComponentsSliderBackdrop
	local scroll = MC.CarpetUI.ComponentsScroll
	local slider = MC.CarpetUI.ComponentsSlider
	local _, vExtent = scroll:GetScrollExtents()
	local _, vOffset = scroll:GetScrollOffsets()

	slider:SetMinMax( 1, math.max( 1, vExtent ) )
	slider:SetValue( currentScrollOffset )
	slider:SetHidden( 1 >= vExtent )
	sliderBackdrop:SetHidden( 1 >= vExtent )
end

function MC.CarpetUI:Refresh( force )

	EVENT_MANAGER:UnregisterForUpdate( REFRESH_HANDLE )
	if true ~= force and self:IsHidden() then return end

	local mode = self:GetSelectedMode()
	if nil == mode then return end

	-- If the player is not in a home or has no edit access, simply hide the UI.

	if not MC.House:IsCurrentlyInAHouse() or not MC.House:CanEditCurrentHouse() then
		self:Hide()
		return
	end

	SaveScrollOffset()

	-- If the player cannot place items, disable any source other than the House itself.

	local searchOptions = { }
	if not MC.House:IsOwner() then
		searchOptions.SearchBackpack, searchOptions.SearchBank = false, false
	end

	-- Search for the required components.

	local componentList, components = "", mode and mode:GetComponents() or { }
	local matched, total, list = MC.Furniture:SearchItems( components, searchOptions )
	local summary, itemSummary = { }, nil

	-- Summarize inventory of each required component.

	for _, item in ipairs( list ) do
		itemSummary = summary[ item.Link ]
		if nil == itemSummary then
			itemSummary = { Required = 0, Matched = 0, Bag = 0, Bank = 0, House = 0 }
			summary[ item.Link ] = itemSummary
		end

		itemSummary.Required = itemSummary.Required + 1

		if 0 ~= item.FurnitureId then
			itemSummary.House = itemSummary.House + 1
			itemSummary.Matched = itemSummary.Matched + 1
		elseif 0 ~= item.BagId then
			if item.BagId == BAG_BACKPACK then
				itemSummary.Bag = itemSummary.Bag + 1
				itemSummary.Matched = itemSummary.Matched + 1
			else
				itemSummary.Bank = itemSummary.Bank + 1
				itemSummary.Matched = itemSummary.Matched + 1
			end
		elseif nil ~= item.CollectibleId and item.CollectibleAvailable then
			itemSummary.Matched = itemSummary.Matched + 1
		end
	end

	for _, item in pairs( summary ) do
		item.Quantity = string.format( "x %s%d|r",
			item.Matched >= item.Required and "|cffff44" or "|cff7733",
			item.Required
		)

		item.AvailableHouse = string.format( "%s%d", zo_iconFormat( "esoui/art/icons/poi/poi_group_house_owned.dds", 32, 32 ), item.House or 0 )
		item.AvailableBag = string.format( "%s%d", zo_iconFormat( "esoui/art/icons/servicetooltipicons/gamepad/gp_servicetooltipicon_bagvendor.dds", 32, 32 ), item.Bag or 0 )
		item.AvailableBank = string.format( "%s %d", zo_iconFormat( "esoui/art/icons/mapkey/mapkey_bank.dds", 32, 32 ), item.Bank or 0 )
	end

	local comps = self.Components

	for index, c in ipairs( comps ) do
		c.Control:SetHidden( true )
	end

	local maxIndex = 0

	for index, component in ipairs( components ) do
		local c = comps[ index ]
		maxIndex = maxIndex + 1

		c.Control:SetHidden( false )
		c.Name:SetText( string.format( "%s  %s",
			zo_iconFormat( MC.Furniture:GetIcon( component[1] ), 34, 34 ),
			MC.Furniture:GetName( component[1] ) ) )

		local s = summary[ component[1] ]

		if s and s.Quantity then
			c.Quantity:SetText( s.Quantity )
		else
			c.Quantity:SetText( "" )
		end

		if s and s.AvailableHouse then
			c.AvailableHouse:SetText( s.AvailableHouse )
		else
			c.AvailableHouse:SetText( "" )
		end

		if s and s.AvailableBag then
			c.AvailableBag:SetText( s.AvailableBag )
		else
			c.AvailableBag:SetText( "" )
		end

		if s and s.AvailableBank then
			c.AvailableBank:SetText( s.AvailableBank )
		else
			c.AvailableBank:SetText( "" )
		end
	end

	for index = maxIndex + 1, #comps do
		local c = comps[ index ]
		c.Control:SetHidden( true )
	end

	zo_callLater( RefreshScroll, 100 )

	local slotShortage = 0

	if matched >= total then
		_, slotShortage = MC.Engine:CanComponentsBePlaced()
		slotShortage = slotShortage or 0
	end

	-- Populate the fields.

	self.Name:SetText( mode:GetColorizedName() )
	self.Desc:SetText( mode:GetDescription() )

	local attr = mode:GetAttributeString()
	if mode:GetAuthor() then
		self.Attributes:SetText( string.format( "|cffffbfAuthor:|r  |cffff55%s|r      |cffffbfTags:|r  %s", mode:GetAuthor(), attr or "None" ) )
	else
		self.Attributes:SetText( string.format( "|cffffbfQuality:|r  %s      |cffffbfTags:|r  %s", mode:GetColorizedQualityString(), attr or "None" ) )
	end

	local trophy = MC.Trophy:GetByName( mode:GetName() )
	if nil == trophy then
		self.Trophy:SetHidden( true )
	else
		local dateEarned = trophy:GetDateEarned()
		self.Trophy:SetTexture( trophy:GetIcon() )
		self.Trophy:SetColor( trophy:GetColor() )
		self.Trophy:SetDesaturation( trophy:GetDesaturation() )
		self.Trophy:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )

		if nil == dateEarned then
			self.TrophyOverlay:SetHidden( true )
			self.TrophyFlare:SetHidden( true )
			for index = 1, #self.TrophySparkles do
				self.TrophySparkles[index]:SetHidden( true )
			end
		else
			self.TrophyOverlay:SetTexture( trophy:GetIcon() )
			self.TrophyOverlay:SetAlpha( 0 )
			self.TrophyOverlay:SetHidden( false )
			self.TrophyOverlay:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
			self.TrophyFlare:SetAlpha( 0 )
			self.TrophyFlare:SetHidden( false )
			for index = 1, #self.TrophySparkles do
				self.TrophySparkles[index]:SetHidden( false )
			end
		end

		self.Trophy:SetHidden( false )
	end

	if not mode:IsActive() then
		self.AssemblyStatus:SetText( "Coming soon ..." )
		self.AssemblyStatus:SetColor( 1, 0.8, 0.5, 1 )
		self.AssemblyStatus:SetMouseEnabled( false )
		self.Assemble:SetMouseEnabled( false )
		self.Assemble:SetHidden( true )
	else
		local enabled = false

		if matched < total then
			self.AssemblyStatus:SetText( string.format( "Missing %d item%s", total - matched, 1 ~= ( total - matched ) and "s" or "" ) )
			self.Assemble:SetHidden( true )
		elseif 0 < slotShortage then
			self.AssemblyStatus:SetText( string.format( "Requires %d more house slot%s", slotShortage, 1 ~= slotShortage and "s" or "" ) )
			self.Assemble:SetHidden( true )
		else
			self.AssemblyStatus:SetText( "Start" )
			self.Assemble:SetHidden( false )
			enabled = true
		end

		if enabled then
			self.AssemblyStatus:SetColor( 1, 1, 0.5, 1 )
		else
			self.AssemblyStatus:SetColor( 1, 0.4, 0, 1 )
		end

		self.AssemblyStatus:SetMouseEnabled( enabled )
		self.Assemble:SetMouseEnabled( enabled )
	end

end


function MC.CarpetUI:GetSelectedMode()

	return MC.Engine:GetMode()

end


function MC.CarpetUI:SelectMode( mode )

	if not MC.Engine:SetMode( mode ) then
		self:Hide()
		return
	end
	self:Refresh()

end


function MC.CarpetUI:GetMostRecentModeHomeKey()

	if MC.House:IsCurrentlyInAHouse() then
		local houseKey = string.format( "%d%s", MC.House:GetHouseId(), MC.House:GetOwner() )
		return houseKey
	else
		return nil
	end

end


function MC.CarpetUI:SetMostRecentMode( mode )

	local modeName

	if mode then
		modeName = mode:GetName()
	else
		return
	end

	MC.Vars.Settings.MostRecentMode = modeName

	local homeModes = MC.Vars.Settings.MostRecentHomeModes
	if not homeModes then
		homeModes = { }
		MC.Vars.Settings.MostRecentHomeModes = homeModes
	end

	local houseKey = self:GetMostRecentModeHomeKey()
	if houseKey then
		homeModes[houseKey] = modeName
	end

end


function MC.CarpetUI:GetMostRecentMode()

	local mode = MC.Mode:GetByName( MC.Vars.Settings.MostRecentMode )

	if false ~= MC.Vars.Settings.RememberModeForEachHome then
		local homeModes = MC.Vars.Settings.MostRecentHomeModes
		if not homeModes then
			homeModes = { }
			MC.Vars.Settings.MostRecentHomeModes = homeModes
		end

		local houseKey = self:GetMostRecentModeHomeKey()
		if houseKey then
			local homeMode = homeModes[houseKey]

			if homeMode then
				homeMode = MC.Mode:GetByName( homeMode )
				if homeMode then
					mode = homeMode
				end
			end
		end
	end

	if not mode then
		mode = MC.Mode:GetDefaultMode()
	end

	return mode

end


function MC.CarpetUI:SelectDefaultMode()

	self:SelectMode( MC.CarpetUI:GetMostRecentMode() )

end


function MC.CarpetUI:SelectPreviousMode()

	local mode = self:GetSelectedMode()
	if nil == mode then
		mode = MC.Mode:GetDefaultMode()
	else
		mode = mode:GetPreviousMode()
	end
	self:SelectMode( mode )

end


function MC.CarpetUI:SelectNextMode()

	local mode = self:GetSelectedMode()
	if nil == mode then
		mode = MC.Mode:GetDefaultMode()
	else
		mode = mode:GetNextMode()
	end
	self:SelectMode( mode )

end


function MC.CarpetUI:StartAssembly()

	flag, message = MC.Engine:Activate()
	if not flag then
		MC.FailedAlert()
		df( "Failed to activate:\n%s", message )
		return false
	end

	return true

end


------[[ Constructors ]]------


do
	local self = MC.CarpetUI
	local c, cc, cg, w

	-- Top-level Window

	w = WM:CreateTopLevelWindow( NS )
	self.Window = w
	w:SetHidden( true )
	w:SetDimensionConstraints(1100, 800, 1100, 800)
	w:SetMovable( true )
	w:SetMouseEnabled( true )
	w:SetClampedToScreen( true )
	w:SetAlpha( 1.0 )
	w:SetAnchor( CENTER, GuiRoot, CENTER, 0, 0 )
	w:SetHandler( "OnMouseWheel", function( control, delta ) if delta < 0 then self:SelectPreviousMode() elseif delta > 0 then self:SelectNextMode() end end )

	-- Outer Container

	cg = WM:CreateControl( NS .. "Container", w, CT_CONTROL )
	self.Container = cg
	--cg:SetDimensions( 820, 520 )
	--cg:SetAnchor( CENTER, w, CENTER, 0, 0 )
	cg:SetAnchor(TOPLEFT, w, nil, nil, 100, 100)
	cg:SetAnchor(BOTTOMRIGHT, w, nil, nil, -100, -100)
	cg:SetMouseEnabled( false )

	-- Backdrop
--[[
	c = WM:CreateControl(NS .. "BackdropBG", cg, CT_TEXTURE)
	self.BackdropBG = c
	c:SetTexture("/MagicCarpet/media/carpet.dds")
	c:SetTextureReleaseOption(RELEASE_TEXTURE_AT_ZERO_REFERENCES)
	c:SetAnchor(TOPLEFT)
	c:SetAnchor(BOTTOMRIGHT)
	do
		local r, g, b = COLOR_CARPET_BG:UnpackRGBA()
		local a = 0.85
		c:SetColor(r, g, b, a)
		c:SetVertexColors(1, r * 0.85, g * 0.85, b * 0.85, a)
		c:SetVertexColors(6, r * 0.7, g * 0.7, b * 0.7, a)
		c:SetVertexColors(8, r * 0.6, g * 0.6, b * 0.6, a)
	end
	c:SetMouseEnabled(false)
	c:SetShaderEffectType(SHADER_EFFECT_TYPE_WAVE)
	c:SetWave(1.4, 0.77, 2, 0)
	c:SetWaveBounds(0.06, 0.06, 0.04, 0.04)
]]
	c = WM:CreateControl(NS .. "Backdrop", cg, CT_TEXTURE)
	self.Backdrop = c
	c:SetTexture("/MagicCarpet/media/carpet.dds")
	c:SetTextureReleaseOption(RELEASE_TEXTURE_AT_ZERO_REFERENCES)
	--c:SetAnchor(TOPLEFT, nil, nil, 12, 9)
	--c:SetAnchor(BOTTOMRIGHT, nil, nil, -12, -9)
	c:SetAnchor(CENTER, nil, nil, nil, 50)
	c:SetDimensions(2000, 600)
	c:SetColor(1, 1, 1, 1)
	c:SetMouseEnabled(false)
	c:SetShaderEffectType(SHADER_EFFECT_TYPE_WAVE)
	c:SetWave(0, 2, 3, 0)
	c:SetWaveBounds(0.02, 0.02, 0.06, 0.12)
-- /script MagicCarpet.CarpetUI.Backdrop:SetWave( 0, 2, 3, 0)
-- /script MagicCarpet.CarpetUI.Backdrop:SetWaveBounds( 0.02, 0.02, 0.06, 0.12 )
	--c:SetWave(1.4, 0.77, 2, 0)
	--c:SetWaveBounds(0.06, 0.06, 0.04, 0.04)

	-- Trophy

	c = WM:CreateControl( NS .. "Trophy", cg, CT_TEXTURE )
	self.Trophy = c
	c:SetAnchor( BOTTOM, cg, TOP, 0, 140 )
	c:SetBlendMode( TEX_BLEND_MODE_ALPHA )
	c:SetDimensions( 256, 256 )
	c:SetColor( 1, 1, 1, 1 )

	c = WM:CreateControl( NS .. "TrophyOverlay", cg, CT_TEXTURE )
	self.TrophyOverlay = c
	c:SetAnchor( BOTTOMRIGHT, self.Trophy, BOTTOMRIGHT, 0, 0 )
	c:SetBlendMode( TEX_BLEND_MODE_ADD )
	c:SetDimensions( 256, 256 )
	c:SetColor( 1, 1, 1, 1 )
	c:SetDesaturation( 1 )

	c = WM:CreateControl( NS .. "TrophyFlare", cg, CT_TEXTURE )
	self.TrophyFlare = c
	c:SetAnchor( CENTER, self.Trophy, CENTER, 20, -20 )
	c:SetTexture( "art/fx/texture/lensflare_thickraysb&w.dds" )
	c:SetBlendMode( TEX_BLEND_MODE_ADD )
	c:SetDimensions( 512, 512 )
	c:SetColor( 1, 1, 1, 1 )

	self.TrophySparkles = { }
	for index = 1, TROPHY_SPARKLES do
		local color = index / TROPHY_SPARKLES
		c = WM:CreateControl( NS .. "TrophySparkle" .. tostring( index ), self.Trophy, CT_TEXTURE )
		table.insert( self.TrophySparkles, c )
		c:SetSimpleAnchorParent( 0, 0 )
		c:SetTexture( "art/fx/texture/sparkles_twinkling.dds" )
		c:SetBlendMode( TEX_BLEND_MODE_ADD )
		c:SetDimensions( 96, 96 )
		c:SetColor( color, 0.8 * color, 0.5 * color, 1 )
	end

	-- Mode Name

	c = WM:CreateControl( NS .. "Name", cg, CT_LABEL )
	self.Name = c
	c:SetAnchor( TOP, cg, TOP, 0, 130 )
	c:SetDimensions( 400, 30 )
	c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
	c:SetVerticalAlignment( TEXT_ALIGN_CENTER )
	--c:SetFont("$(MEDIUM_FONT)|$(KB_30)|outline")
	c:SetFont("ZoFontWinH1")
	c:SetColor( 1, 1, 1, 1 )

	-- Mode Attributes

	local ac = WM:CreateControl( NS .. "AttributeContainer", cg, CT_CONTROL )
	self.AttributeContainer = ac
	ac:SetAnchor( TOP, self.Name, BOTTOM, 0, 5 )
	ac:SetDimensions( 1000, 50 )
	ac:SetMouseEnabled( false )

	c = WM:CreateControl( NS .. "Attributes", ac, CT_LABEL )
	self.Attributes = c
	c:SetAnchor( CENTER, ac, CENTER, 0, 0 )
	c:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
	c:SetVerticalAlignment( TEXT_ALIGN_TOP )
	--c:SetFont( "$(MEDIUM_FONT)|$(KB_22)|outline" )
	c:SetFont("ZoFontWinH4")
	c:SetColor( 1, 1, 0.25, 1 )

	-- Mode Description

	c = WM:CreateControl( NS .. "Desc", cg, CT_LABEL )
	self.Desc = c
	c:SetAnchor( TOP, ac, BOTTOM, 0, -5 )
	c:SetWidth( 1000 )
	c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
	c:SetVerticalAlignment( TEXT_ALIGN_CENTER )
	--c:SetFont( "$(MEDIUM_FONT)|$(KB_24)|outline" )
	c:SetFont("ZoFontWinH4")
	c:SetMaxLineCount( 4 )
	c:SetColor( 1, 1, 1, 1 )

	-- Components

	cc = WM:CreateControl( NS .. "ComponentsScrollContainer", cg, CT_CONTROL )
	self.ComponentsScrollContainer = cc
	cc:SetAnchor(TOP, self.Desc, BOTTOM, 0, 40, ANCHOR_CONSTRAINS_Y)
	cc:SetAnchor(BOTTOM, cg, nil, 0, -100)
	cc:SetWidth(700)
	cc:SetMouseEnabled(true)

	c = WM:CreateControl( NS .. "ComponentsTitle", cg, CT_LABEL )
	self.ComponentsTitle = c
	c:SetAnchor( BOTTOM, cc, TOP )
	c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
	c:SetVerticalAlignment( TEXT_ALIGN_TOP )
	--c:SetFont( "$(MEDIUM_FONT)|$(KB_22)|outline" )
	c:SetFont("ZoFontWinH3")
	c:SetColor( 1, 1, 1, 1 )
	c:SetText( "Items Required" )

	local scroll = WM:CreateControl( NS .. "ComponentsScroll", cc, CT_SCROLL )
	self.ComponentsScroll = scroll
	scroll:SetAnchor( TOPLEFT, cc, TOPLEFT, 0, 10 )
	scroll:SetAnchor( BOTTOMRIGHT, cc, BOTTOMRIGHT, 0, -10 )
	scroll:SetMouseEnabled( true )

	c = WM:CreateControl( NS .. "ComponentsScrollBackdrop2", cc, CT_TEXTURE )
	self.ComponentsSliderBackdrop = c
	c:SetAnchor( TOPLEFT, cc, TOPRIGHT, 2, 10 )
	c:SetAnchor( BOTTOMRIGHT, cc, BOTTOMRIGHT, 20, -10 )
	c:SetBlendMode( TEX_BLEND_MODE_ALPHA )
	c:SetColor( 0, 0, 0, 0.65 )

	c = WM:CreateControl( NS .. "ComponentsSlider", cc, CT_SLIDER )
	self.ComponentsSlider = c
	c:SetWidth( 15 )
	c:SetAnchor( TOPLEFT, cc, TOPRIGHT, 0, 10 )
	c:SetAnchor( BOTTOMLEFT, cc, BOTTOMRIGHT, 0, -10 )
	c:SetMinMax( 0, 0 )
	c:SetValue( 1 )
	c:SetValueStep( 1 )
	c:SetMouseEnabled( true )
	c:SetAllowDraggingFromThumb( true )
	c:SetThumbTexture( "/MagicCarpet/media/sliderthumb.dds", "/MagicCarpet/media/sliderthumb.dds", "/MagicCarpet/media/sliderthumb.dds", 22, 22, 0, 0, 1, 1 )
	c:SetBackgroundMiddleTexture( "EsoUI/Art/ChatWindow/chat_scrollbar_track.dds" )

	self.ComponentsSlider:SetHandler( "OnValueChanged", function( _, value, eventReason )
		local scroll = self.ComponentsScroll
		local _, scrollHeight = scroll:GetScrollExtents()
		scroll:SetVerticalScroll( scrollHeight - ( scrollHeight - value ) )
	end )

	self.ComponentsScroll:SetHandler( "OnMouseWheel", function( _, delta, ctrl, alt, shift )
		local scroll = self.ComponentsScroll
		local _, scrollHeight = scroll:GetScrollExtents()
		local slider = self.ComponentsSlider
		local value = slider:GetValue()
		slider:SetValue( value - ( delta * 15 ) )
	end )

	grp = WM:CreateControl( NS .. "ComponentsContainer", scroll, CT_CONTROL )
	self.ComponentsContainer = grp
	grp:SetAnchor( TOPLEFT, scroll, TOPLEFT, 0, 0 )
	grp:SetAnchor( TOPRIGHT, scroll, TOPRIGHT, 0, 0 )
	grp:SetResizeToFitDescendents( true )

	self.Components = { }
	local component, prevComponent = nil, nil

	for index = 1, 20 do
		component = { }
		self.Components[ index ] = component

		c = WM:CreateControl( nil, grp, CT_CONTROL )
		component.Control = c
		if prevComponent then
			c:SetAnchor( TOPLEFT, prevComponent, BOTTOMLEFT, 0, 0 )
			c:SetAnchor( TOPRIGHT, prevComponent, BOTTOMRIGHT, 0, 0 )
		else
			c:SetAnchor( TOPLEFT, grp, TOPLEFT, 0, 0 )
			c:SetAnchor( TOPRIGHT, grp, TOPRIGHT, 0, 0 )
		end
		--c:SetResizeToFitDescendents( true )
		c:SetDimensions( 640, 35 )

		c = WM:CreateControl( nil, component.Control, CT_TEXTURE )
		component.Background = c
		c:SetAnchorFill()
		c:SetColor(1, 1, 1, 0.1)

		c = WM:CreateControl( nil, component.Control, CT_LABEL )
		component.Name = c
		--c:SetAnchor( RIGHT, component.Control, CENTER, 68, 0 )
		c:SetAnchor( LEFT, component.Control, LEFT, 10, 0 )
		c:SetWidth(370)
		c:SetHeight(35)
		c:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		c:SetVerticalAlignment( TEXT_ALIGN_CENTER )
		--c:SetFont( "$(CHAT_FONT)|$(KB_20)" )
		c:SetFont("ZoFontWinH4")
		c:SetColor( 1.0, 1.0, 1.0, 1.0 )
		c:SetText( "" )

		c = WM:CreateControl( nil, component.Control, CT_LABEL )
		component.Quantity = c
		c:SetAnchor( LEFT, component.Name, RIGHT, 15, 0 )
		c:SetWidth( 52 )
		c:SetHeight(35)
		c:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		c:SetVerticalAlignment( TEXT_ALIGN_CENTER )
		--c:SetFont( "$(CHAT_FONT)|$(KB_20)" )
		c:SetFont("ZoFontWinH4")
		c:SetColor( 1.0, 1.0, 1.0, 1.0 )
		c:SetText( "" )

		c = WM:CreateControl( nil, component.Control, CT_LABEL )
		component.AvailableHouse = c
		c:SetAnchor( LEFT, component.Quantity, RIGHT, 15, 0 )
		c:SetWidth( 68 )
		c:SetHeight(35)
		c:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		c:SetVerticalAlignment( TEXT_ALIGN_CENTER )
		--c:SetFont( "$(CHAT_FONT)|$(KB_20)" )
		c:SetFont("ZoFontWinH4")
		c:SetColor( 1.0, 1.0, 1.0, 1.0 )
		c:SetText( "" )

		c = WM:CreateControl( nil, component.Control, CT_LABEL )
		component.AvailableBag = c
		c:SetAnchor( LEFT, component.AvailableHouse, RIGHT, 5, 0 )
		c:SetWidth( 80 )
		c:SetHeight(35)
		c:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		c:SetVerticalAlignment( TEXT_ALIGN_CENTER )
		--c:SetFont( "$(CHAT_FONT)|$(KB_20)" )
		c:SetFont("ZoFontWinH4")
		c:SetColor( 1.0, 1.0, 1.0, 1.0 )
		c:SetText( "" )

		c = WM:CreateControl( nil, component.Control, CT_LABEL )
		component.AvailableBank = c
		c:SetAnchor( LEFT, component.AvailableBag, RIGHT, 5, 0 )
		c:SetWidth( 75 )
		c:SetHeight(35)
		c:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		c:SetVerticalAlignment( TEXT_ALIGN_CENTER )
		--c:SetFont( "$(CHAT_FONT)|$(KB_20)" )
		c:SetFont("ZoFontWinH4")
		c:SetColor( 1.0, 1.0, 1.0, 1.0 )
		c:SetText( "" )

		prevComponent = component.Control
	end

	-- Mode Selection

	c = WM:CreateControl( NS .. "SelectPrevious", cg, CT_TEXTURE )
	self.SelectPrevious = c
	c:SetAnchor(TOPRIGHT, cg, TOP, -110, 40)
	c:SetDrawLayer(DL_CONTROLS)
	c:SetTexture( "esoui/art/crowncrates/keyboard/gemification_arrow.dds" )
	c:SetDimensions(220, 80)
	c:SetTextureCoords( 1, 0, 0, 1 )
	c:SetColor( 0.5, 0.5, 0.5, 1 )
	c:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 1.3 )
	c:SetMouseEnabled( true )
	c:SetHandler( "OnMouseUp", function() self:SelectPreviousMode() end )
	c:SetHandler( "OnMouseEnter", function( ctl ) ctl:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 2 ) end )
	c:SetHandler( "OnMouseExit", function( ctl ) ctl:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 1.3 ) end )

	c = WM:CreateControl( NS .. "PreviousLabel", cg, CT_LABEL )
	self.PreviousLabel = c
	c:SetAnchor( CENTER, self.SelectPrevious, CENTER, 50, -7 )
	c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
	c:SetVerticalAlignment( TEXT_ALIGN_CENTER )
	--c:SetFont( "$(MEDIUM_FONT)|$(KB_28)|outline" )
	c:SetFont("ZoFontWinH2")
	c:SetColor(1, 1, 1, 1)
	c:SetText( "Previous" )
	c:SetMouseEnabled( false )

	c = WM:CreateControl( NS .. "SelectNext", cg, CT_TEXTURE )
	self.SelectNext = c
	c:SetAnchor(TOPLEFT, cg, TOP, 110, 40)
	c:SetDrawLayer(DL_CONTROLS)
	c:SetTexture( "esoui/art/crowncrates/keyboard/gemification_arrow.dds" )
	c:SetDimensions(220, 80)
	c:SetTextureCoords( 0, 1, 0, 1 )
	c:SetColor( 0.5, 0.5, 0.5, 1 )
	c:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 1.3 )
	c:SetMouseEnabled( true )
	c:SetHandler( "OnMouseUp", function() self:SelectNextMode() end )
	c:SetHandler( "OnMouseEnter", function( ctl ) ctl:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 2 ) end )
	c:SetHandler( "OnMouseExit", function( ctl ) ctl:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 1.3 ) end )

	c = WM:CreateControl( NS .. "NextLabel", cg, CT_LABEL )
	self.NextLabel = c
	c:SetAnchor( CENTER, self.SelectNext, CENTER, -40, -7 )
	c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
	c:SetVerticalAlignment( TEXT_ALIGN_CENTER )
	--c:SetFont( "$(MEDIUM_FONT)|$(KB_28)|outline" )
	c:SetFont("ZoFontWinH2")
	c:SetColor(1, 1, 1, 1)
	c:SetText( "Next" )
	c:SetMouseEnabled( false )

	-- Assembly

	c = WM:CreateControl( NS .. "AssemblyStatus", cg, CT_LABEL )
	self.AssemblyStatus = c
	c:SetAnchor(TOP, cg, BOTTOM, 150, -90)
	c:SetDrawLayer(DL_CONTROLS)
	c:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	c:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	--c:SetFont( "$(CHAT_FONT)|$(KB_26)|outline" )
	c:SetFont("ZoFontWinH1")
	c:SetColor(1, 1, 0.5, 1)
	c:SetText("Start")
	c:SetMaxLineCount(2)
	c:SetMouseEnabled( true )
	c:SetHandler( "OnMouseUp", function() self:StartAssembly() end )

	c = WM:CreateControl(NS .. "Assemble", cg, CT_TEXTURE)
	self.Assemble = c
	c:SetAnchor(LEFT, self.AssemblyStatus, RIGHT, 0, 1)
	c:SetDrawLayer(DL_CONTROLS)
	c:SetTexture("esoui/art/buttons/large_rightarrow_up.dds")
	c:SetBlendMode(TEX_BLEND_MODE_ALPHA)
	c:SetDimensions(48, 48)
	c:SetColor(1, 1, 0.5, 1)
	c:SetMouseEnabled( true )
	c:SetHandler("OnMouseUp", function() self:StartAssembly() end)

	-- Close

	c = WM:CreateControl( NS .. "Close", cg, CT_LABEL )
	self.Close = c
	c:SetAnchor(TOP, cg, BOTTOM, -150, -90)
	c:SetDrawLayer(DL_CONTROLS)
	c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
	c:SetVerticalAlignment( TEXT_ALIGN_CENTER )
	--c:SetFont( "$(CHAT_FONT)|$(KB_26)|outline" )
	c:SetFont("ZoFontWinH1")
	c:SetColor(1, 1, 0.5, 1)
	c:SetText("Close")
	c:SetMaxLineCount( 2 )
	c:SetMouseEnabled( true )
	c:SetHandler( "OnMouseUp", function() self:Hide() end )

	c = WM:CreateControl( NS .. "CloseIcon", cg, CT_TEXTURE )
	self.CloseIcon = c
	c:SetAnchor( RIGHT, self.Close, LEFT, 10, 1 )
	c:SetDrawLayer(DL_CONTROLS)
	c:SetTexture( "esoui/art/hud/radialicon_cancel_up.dds" )
	c:SetBlendMode( TEX_BLEND_MODE_ALPHA )
	c:SetDimensions( 64, 64 )
	c:SetColor( 1, 1, 0.5, 1 )
	c:SetMouseEnabled( true )
	c:SetHandler( "OnMouseUp", function() self:Hide() end )
end


if not SLASH_COMMANDS["/re"] then SLASH_COMMANDS["/re"] = ReloadUI end