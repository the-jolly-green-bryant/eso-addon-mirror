if not EHT then EHT = { } end
if not EHT.UI then EHT.UI = { } end

local displayNameLower = string.lower( GetDisplayName() )
local RAD45, RAD90, RAD180, RAD270, RAD360 = 0.25 * math.pi, 0.5 * math.pi, math.pi, 1.5 * math.pi, 2 * math.pi
local round = function( n, d ) if nil == d then return zo_roundToZero( n ) else return zo_roundToNearest( n, 1 / ( 10 ^ d ) ) end end
local bit = EHT.Bit
local clone = EHT.Util.CloneTable
local sin, cos = math.sin, math.cos

local function CaseInsensitiveStringComparer( s1, s2 )
	if not s1 and s2 then return true end
	if s1 and not s2 then return false end
	return string.lower( s1 ) > string.lower( s2 )
end

local MSG_SELECTION_EMPTY = "|cffffff" ..
	"No items are selected.\n" ..
	"Please select one or more items first.\n\n" ..
	"To select or deselect items, enter Housing Editor mode (|c00ffffF5|cffffff by default), " ..
	"target an item and press the Select / Deselect key (|c00ffffG|cffffff by default).\n\n" ..
	"While in Housing Editor mode, selected items are marked with a \"check\" icon."

local MSG_SCENE_EMPTY = "|cffffff" ..
	"No items are selected for this Scene.\n" ..
	"Please add one or more items to this Scene first.\n\n" ..
	"To add Scene items, enter Housing Editor mode (|c00ffffF5|cffffff by default), " ..
	"target an item and press the Select / Deselect key (|c00ffffG|cffffff by default). " ..
	"Select all items that you want to add to the Scene.\n\n" ..
	"Then, click |c00ffffChange these items...|cffffff on the |c00ffffScenes|cffffff tab and " ..
	"choose |c00ffffAdd Selected Items|cffffff."

local TIP_FX_SHARE_COMMUNITY = "|cffffff" ..
	"Publish a home's FX to |c00ffffall PC players on all servers|cffffff. " ..
	"You may publish multiple homes' FX to the Community.\n\n" ..
	"This sharing method:\n" ..
	" - |c00ffffInstantly|cffffff shares FX data after your next login or /reloadui.\n" ..
	" - |c00ffffCan|cffffff share with offline players.\n" ..
	" - |c00ffffDoes not|cffffff use chat or in-game mail.\n" ..
	"\nKeep in mind that this method:\n" ..
	" - |c00ffffCannot|cffffff share other players' FX.\n" ..
	" - |c00ffffDoes|cffffff require the Essential Housing Community app to be installed. You will be prompted to install it if you have not done so already.\n"

local TIP_FX_SHARE_GUILDS = "|cffffff" ..
	"Share your FX with any online members of one or more of your guilds. Silent but slower than other sharing methods.\n\n" ..
	"This sharing method:\n" ..
	" - |c00ffffCan|cffffff share other players' FX.\n" ..
	" - |c00ffffDoes not|cffffff use chat or in-game mail.\n" ..
	" - |c00ffffDoes not|cffffff require the Essential Housing Community app.\n" ..
	"\nKeep in mind that this method:\n" ..
	" - |c00ffffSlowly|cffffff shares your data in the background.\n" ..
	" - |c00ffffCannot|cffffff share with offline players.\n"

local TIP_FX_SHARE_CHAT = "|cffffff" ..
	"Share your FX with any players in your current Chat channel, such as |cffff00/say|cffffff, |cffff00/group|cffffff or |cffff00/guild|cffffff.\n\n" ..
	"This sharing method:\n" ..
	" - |c00ffffCan|cffffff share other players' FX.\n" ..
	" - |c00ffffDoes not|cffffff require the Essential Housing Community app.\n" ..
	"\nKeep in mind that this method:\n" ..
	" - |c00ffffDoes|cffffff use chat messages to share FX data.\n" ..
	" - |c00ffffRequires|cffffff you to manually send one or more messages.\n" ..
	" - |c00ffffCannot|cffffff share with offline players.\n"

local TIP_FX_SHARE_MAIL = "|cffffff" ..
	"Share your FX with a specific @player. Ideal for sharing with an offline player that does not have the Essential Housing Community app installed.\n\n" ..
	"This sharing method:\n" ..
	" - |c00ffffInstantly|cffffff shares your data.\n" ..
	" - |c00ffffCan|cffffff share with offline players.\n" ..
	" - |c00ffffDoes not|cffffff require the Essential Housing Community app.\n" ..
	"\nKeep in mind that this method:\n" ..
	" - |c00ffffDoes|cffffff use in-game mail to share FX data.\n" ..
	" - |c00ffffCannot|cffffff share other players' FX.\n"

function EHT.UI.BuildItemQuantityList( itemQuantities, formatString, itemSeparator )
	local list = { }
	for item, quantity in pairs( itemQuantities ) do
		table.insert( list, string.format( formatString or "%s (x%d)", item, quantity ) )
	end
	return table.concat( list, itemSeparator or ", " )
end

function EHT.UI.GetAllChildControls( parent, children )
	children = children or {}
	if parent then
		local numChildren = parent:GetNumChildren()
		for childIndex = 1, numChildren do
			local child = parent:GetChild( childIndex )
			table.insert( children, child )
			EHT.UI.GetAllChildControls( child, children )
		end
	end
	return children
end

function EHT.UI.ForEachChildControl( parent, callback )
	local children = EHT.UI.GetAllChildControls( parent )
	for index, child in ipairs( children ) do
		callback( child )
	end
	return children
end

do
	local enabled = false
	
	local function OnNightModeUpdate()
		if not enabled or not EHT.Housing.IsHouseZone() then
			enabled = false
			EHT.Effect.RequestBrightness( nil, "Override", nil )
			EVENT_MANAGER:UnregisterForUpdate("EHT.UI.OnNightModeUpdate", OnNightModeUpdate)
			EHT.UI.RefreshEditToggles()
			return
		end

		if EHT.Util.IsDayTime() then
			EHT.Effect.RequestBrightness( nil, "Override", 0.25 )
		else
			EHT.Effect.RequestBrightness( nil, "Override", nil )
		end
	end
	
	local function OnNightModeChanged()
		EHT.UI.RefreshEditToggles()
		
		if enabled then
			EVENT_MANAGER:RegisterForUpdate("EHT.UI.OnNightModeUpdate", 5000, OnNightModeUpdate)
			OnNightModeUpdate()
		end
	end

	function EHT.UI.IsNightModeEnabled()
		return enabled
	end

	function EHT.UI.ToggleNightMode()
		enabled = not enabled
		OnNightModeChanged()
	end
end

---[ Colors ]---

local function IsColor( c )
	return	"table" == type( c ) and
			"number" == type( c.r ) and
			"number" == type( c.g ) and
			"number" == type( c.b ) and
			"number" == type( c.a )
end

local function IsGradient( c )
	return	"table" == type( c ) and
			IsColor( c.tl ) and
			IsColor( c.tr ) and
			IsColor( c.bl ) and
			IsColor( c.br )
end

local function CreateColor( r, g, b, a )
	return { r = r, g = g, b = b, a = a }
end

local function UnpackColor(c, alpha)
	return c.r, c.g, c.b, alpha or c.a
end

local function FadeColor( c, colorCoeff, alphaCoeff )
	colorCoeff = colorCoeff or 1
	alphaCoeff = alphaCoeff or 0

	if IsGradient( c ) then
		return CreateColor( colorCoeff * c.tl.r, colorCoeff * c.tl.g, colorCoeff * c.tl.b, alphaCoeff * c.tl.a )
	else
		return CreateColor( colorCoeff * c.r, colorCoeff * c.g, colorCoeff * c.b, alphaCoeff * c.a )
	end
end

local function CreateGradient( topLeft, topRight, bottomLeft, bottomRight )
	return { tl = clone( topLeft ), tr = clone( topRight ), bl = clone( bottomLeft ), br = clone( bottomRight ) }
end

local function CreateGradientFade( color, directions )
	local c

	if IsGradient( color ) then
		c = CreateGradient( color.tl, color.tr, color.bl, color.br )
	else
		c = CreateGradient( color, color, color, color )
	end

	if bit.Has( directions, bit.New( 1 ) ) then c.tl = FadeColor( c.tl ) end
	if bit.Has( directions, bit.New( 2 ) ) then c.tr = FadeColor( c.tr ) end
	if bit.Has( directions, bit.New( 3 ) ) then c.bl = FadeColor( c.bl ) end
	if bit.Has( directions, bit.New( 4 ) ) then c.br = FadeColor( c.br ) end

	return c
end

local function LerpColor( cout, c1, c2, interval )
	if IsGradient( c1 ) then
		local tl1, tr1, bl1, br1 = c1.tl, c1.tr, c1.bl, c1.br
		local tl2, tr2, bl2, br2 = c2.tl, c2.tr, c2.bl, c2.br

		if not cout then
			cout = { tl = clone( Colors.Black ), tr = clone( Colors.Black ), bl = clone( Colors.Black ), br = clone( Colors.Black ) }
		elseif not cout.tl then
			cout.tl, cout.tr, cout.bl, cout.br = clone( Colors.Black ), clone( Colors.Black ), clone( Colors.Black ), clone( Colors.Black )
		end

		cout.tl.r, cout.tl.g, cout.tl.b, cout.tl.a = zo_lerp( tl1.r, tl2.r, interval ), zo_lerp( tl1.g, tl2.g, interval ), zo_lerp( tl1.b, tl2.b, interval ), zo_lerp( tl1.a, tl2.a, interval )
		cout.tr.r, cout.tr.g, cout.tr.b, cout.tr.a = zo_lerp( tr1.r, tr2.r, interval ), zo_lerp( tr1.g, tr2.g, interval ), zo_lerp( tr1.b, tr2.b, interval ), zo_lerp( tr1.a, tr2.a, interval )
		cout.bl.r, cout.bl.g, cout.bl.b, cout.bl.a = zo_lerp( bl1.r, bl2.r, interval ), zo_lerp( bl1.g, bl2.g, interval ), zo_lerp( bl1.b, bl2.b, interval ), zo_lerp( bl1.a, bl2.a, interval )
		cout.br.r, cout.br.g, cout.br.b, cout.br.a = zo_lerp( br1.r, br2.r, interval ), zo_lerp( br1.g, br2.g, interval ), zo_lerp( br1.b, br2.b, interval ), zo_lerp( br1.a, br2.a, interval )
	else
		if not cout then
			cout = { }
		elseif cout.tl then
			cout.tl, cout.tr, cout.bl, cout.br = nil, nil, nil, nil
		end

		cout.r, cout.g, cout.b, cout.a = zo_lerp( c1.r, c2.r, interval ), zo_lerp( c1.g, c2.g, interval ), zo_lerp( c1.b, c2.b, interval ), zo_lerp( c1.a, c2.a, interval )
	end
end

local function SetVertexColor( control, vertex, color, filter )
	if "userdata" ~= type( control ) or "number" ~= type( vertex ) or "table" ~= type( color ) or not control.SetVertexColors then
		return
	end

	if "table" ~= type( filter ) then
		filter = { }
	end

	control:SetVertexColors( vertex, color.r * ( filter.r or 1 ), color.g * ( filter.g or 1 ), color.b * ( filter.b or 1 ), color.a * ( filter.a or 1 ) )
end

local function SetColor( control, color, filter )
	if "userdata" ~= type( control ) or "table" ~= type( color ) then
		return
	end

	if "table" ~= type( filter ) then
		filter = { }
	end

	if color.tl or color.tr or color.bl or color.br then
		SetVertexColor( control, 1, color.tl, filter )
		SetVertexColor( control, 2, color.tr, filter )
		SetVertexColor( control, 4, color.bl, filter )
		SetVertexColor( control, 8, color.br, filter )
	else
		control:SetColor( ( color.r or 1 ) * ( filter.r or 1 ), ( color.g or 1 ) * ( filter.g or 1 ), ( color.b or 1 ) * ( filter.b or 1 ), ( color.a or 1 ) * ( filter.a or 1 ) )
	end
end
EHT.UI.SetColor = SetColor

local function AlphaColor( color, alpha )
	return CreateColor( color.r * alpha, color.g * alpha, color.b * alpha, color.a * alpha )
end

-- 0.768, 1.000, 1.000
-- 0.615, 0.800, 1.000
-- 0.307, 0.400, 0.500
-- 0.205, 0.266, 0.333
-- 0.154, 0.200, 0.250
-- 0.102, 0.133, 0.166

local Colors = { }
Colors.Arrow = CreateColor(0.768, 1.000, 1.000, 1)
Colors.Black = CreateColor(0, 0, 0, 1)
Colors.ButtonOutline = CreateColor(0, 0, 0, 1)
Colors.ButtonBackdrop = CreateGradient( CreateColor(0.307, 0.400, 0.500, 1 ), CreateColor(0.154, 0.200, 0.250, 1 ), CreateColor(0.307, 0.400, 0.500, 1 ), CreateColor(0.154, 0.200, 0.250, 1 ) )
Colors.ButtonLabel = CreateColor(0.750, 0.950, 1.000, 1)
Colors.ButtonLabelFont = "$(BOLD_FONT)|$(KB_17)|soft-shadow-thin"
Colors.ControlBackdrop = CreateColor(0, 0, 0, 1)
Colors.ControlBackdropHighlight = CreateColor(0.3, 0.3, 0.3, 1)
Colors.ControlBox = CreateGradient( CreateColor(0.768, 1.000, 1.000, 1 ), CreateColor(0.615, 0.800, 1.000, 1 ), CreateColor(0.768, 1.000, 1.000, 1 ), CreateColor(0.615, 0.800, 1.000, 1 ) )
Colors.CustomFont = "$(MEDIUM_FONT)|$(KB_%d)|%s"
Colors.CustomFontType = "$(%s)|$(KB_%d)|%s"
Colors.DataLabel = CreateColor(1, 0.78, 0.45, 1)
Colors.DirectionalArrow1 = CreateGradient( CreateColor( 1, 0.5, 0, 0.75 ), CreateColor( 1, 0.5, 0, 0.75 ), CreateColor( 0, 1, 0.5, 0.75 ), CreateColor( 0, 1, 0.5, 0.75 ) )
Colors.DirectionalArrow2 = CreateGradient( CreateColor( 0, 1, 0.5, 0.75 ), CreateColor( 0, 1, 0.5, 0.75 ), CreateColor( 1, 1, 1, 0.75 ), CreateColor( 1, 1, 1, 0.75 ) )
Colors.DirectionalArrow3 = CreateGradient( CreateColor( 1, 1, 1, 0.75 ), CreateColor( 1, 1, 1, 0.75 ), CreateColor( 1, 0.5, 0, 0.75 ), CreateColor( 1, 0.5, 0, 0.75 ) )
Colors.DirectionalButton = CreateColor(0.615, 0.800, 1.000, 1)
Colors.DirectionalButtonLabelFont = "$(BOLD_FONT)|$(KB_16)|soft-shadow-thick"
Colors.DisabledLabelColor = CreateColor(0.5, 0.5, 0.5, 1)
Colors.Divider = CreateColor(0.615, 0.800, 1.000, 1)
Colors.Icon = CreateColor(0.615, 0.800, 1.000, 1)
Colors.Label = CreateColor(1, 1, 1, 1)
Colors.LabelFont = "$(MEDIUM_FONT)|$(KB_16)"
Colors.LabelFontBold = "$(BOLD_FONT)|$(KB_16)|soft-shadow-thick"
Colors.LabelHeading = CreateColor(0.750, 0.950, 1.000, 1) -- (0.2, 0.85, 0.95, 1)
Colors.LabelHeadingFont = "$(BOLD_FONT)|$(KB_18)"
Colors.ListBackdrop = CreateGradient( CreateColor(0.205, 0.266, 0.333, 1 ), CreateColor(0.102, 0.133, 0.166, 1 ), CreateColor(0.205, 0.266, 0.333, 1 ), CreateColor(0.102, 0.133, 0.166, 1 ) )
Colors.ListBox = CreateGradient( CreateColor(0.768, 1.000, 1.000, 1 ), CreateColor(0.615, 0.800, 1.000, 1 ), CreateColor(0.768, 1.000, 1.000, 1 ), CreateColor(0.615, 0.800, 1.000, 1 ) )
Colors.ListItemFont = "$(BOLD_FONT)|$(KB_16)|soft-shadow-thick"
Colors.ListItemBackdrop = CreateColor(0.154, 0.200, 0.250, 0 )
Colors.ListItemSelectedBackdrop = CreateColor(0.3, 0.3, 0.3, 0.6)
Colors.ItemMouseEnter = CreateGradient(CreateColor(0.205, 0.266, 0.333, 0.1), CreateColor(0.307, 0.400, 0.500, 0.4), CreateColor(0.205, 0.266, 0.333, 0.1), CreateColor(0.307, 0.400, 0.500, 0.4))
Colors.ItemSelected = CreateGradient(CreateColor(0.5, 0.4, 0.1, 0.4), CreateColor(0.5, 0.4, 0.1, 0.1), CreateColor(0.5, 0.4, 0.1, 0.4), CreateColor(0.5, 0.4, 0.1, 0.1))
Colors.ItemLabel = CreateColor(1, 1, 1, 1)
Colors.FilterDisabled = CreateColor(0.4, 0.4, 0.4, 1)
Colors.SliderArrow = CreateColor(0.768, 1.000, 1.000, 1)
Colors.SliderBackdrop = CreateColor( 0, 0, 0, 1)
Colors.SliderThumb = CreateColor(0.768, 1.000, 1.000, 1)
Colors.TabBackdrop = CreateColor(0.307, 0.400, 0.500, 1) -- CreateGradient(CreateColor(0.154, 0.200, 0.250, 1), CreateColor(0.102, 0.133, 0.166, 1), CreateColor(0.154, 0.200, 0.250, 1), CreateColor(0.102, 0.133, 0.166, 1))
Colors.ToolDialogBackdrop = CreateColor(0.2, 0.2, 0.2, 1)
Colors.Transparent = CreateColor(0, 0, 0, 0)
Colors.White = CreateColor(1, 1, 1, 1)
Colors.WindowBackdrop = CreateGradient( CreateColor( 0, 0.05, 0.1, 0.8 ), CreateColor( 0, 0, 0.05, 0.8 ), CreateColor( 0, 0.05, 0.1, 0.8 ), CreateColor( 0, 0, 0.05, 0.8 ) )
Colors.WindowBox = CreateGradient( CreateColor(0.307, 0.400, 0.500, 0.5 ), CreateColor(0.154, 0.200, 0.250, 0.5 ), CreateColor(0.307, 0.400, 0.500, 0.5 ), CreateColor(0.154, 0.200, 0.250, 0.5 ) )
EHT.UI.Colors = Colors

---[ Controls ]---

do
	local function SetMouseEnabled(control, enabled)
		if enabled then
			local parentControl = control:GetParent()
			if parentControl then
				control:SetDrawLayer(parentControl:GetDrawLayer())
				control:SetDrawLevel(parentControl:GetDrawLevel())
				control:SetDrawTier(parentControl:GetDrawTier())
			end
		end
		control:_SetMouseEnabled(enabled)
	end

	function EHT.CreateControl(name, parentControl, controlType)
		local control = CreateControl(name, parentControl, controlType)
		control._SetMouseEnabled = control.SetMouseEnabled
		control.SetMouseEnabled = SetMouseEnabled
		return control
	end
end

function EHT.UI.CreateItemStockString( itemLabel, totalCount, boundCount )
	totalCount, boundCount = totalCount or 0, boundCount or 0
	local tradeableCount = totalCount - boundCount
	local tradeableString = tradeableCount > 0 and string.format( " |cffffffx|cffff88%d%s|r", tradeableCount, EHT.ICON_TRADEABLE ) or ""
	local boundString = boundCount > 0 and string.format( " |cffffffx|cffff88%d%s|r", boundCount, EHT.ICON_CROWN ) or ""
	return string.format( "|caaaaaa%s|r%s%s", itemLabel or "", tradeableString, boundString )
end

local function SetControlHidden( control, hidden, includeNestedChildren )
	local t = type( control )

	if "userdata" == t then
		control:SetHidden( hidden )

		if includeNestedChildren then
			local child

			for index = 1, control:GetNumChildren() do
				child = control:GetChild( index )
				SetControlHidden( child, hidden, true )
			end
		end
	elseif "table" == t then
		for index = 1, #control do
			SetControlHidden( control[index], hidden, includeNestedChildren )
		end
	end
end
EHT.SetControlHidden = SetControlHidden

local function CreateAnchor( localPoint, anchorControl, anchorPoint, offsetX, offsetY )
	return { localPoint, anchorControl, anchorPoint, offsetX, offsetY }
end

local function AddAnchor( control, anchor )
	if anchor then
		control:SetAnchor( anchor[1], anchor[2], anchor[3], anchor[4], anchor[5] )
	end
end

local function CreateWindow( name, anchor1, anchor2, width, height, movable, resizable, clamped )
	local w = WINDOW_MANAGER:CreateTopLevelWindow( name )

	if anchor1 then AddAnchor( w, anchor1 ) end
	if anchor2 then AddAnchor( w, anchor2 ) end
	if width then w:SetWidth( width ) end
	if height then w:SetHeight( height ) end
	w:SetMouseEnabled( true )
	w:SetMovable( false ~= movable )
	w:SetResizeHandleSize( false ~= resizable and 10 or 0 )
	w:SetClampedToScreen( false ~= clamped )

	return w
end

local function CreateLabel( name, control, text, anchor1, anchor2, width, height, Halignment, Valignment, color )
	local c = EHT.CreateControl( name, control, CT_LABEL )

	c:SetFont( Colors.LabelFont )
	c:SetHorizontalAlignment( Halignment or TEXT_ALIGN_LEFT )
	c:SetVerticalAlignment( Valignment or TEXT_ALIGN_CENTER )
	c:SetText( text )
	if anchor1 then AddAnchor( c, anchor1 ) end
	if anchor2 then AddAnchor( c, anchor2 ) end
	if width then c:SetWidth( width ) end
	if height then c:SetHeight( height ) end
	if color then SetColor( c, color ) else c:SetColor( 1, 1, 1, 1 ) end

	return c
end

local function SetLabelFont( control, size, shadow, outline )
	control:SetFont( string.format( Colors.CustomFont, size, shadow and "soft-shadow-thick" or ( outline and "outline" or "" ) ) )
end

local function SetLabelCustomFont( control, fontType, size, shadow, outline )
	control:SetFont( string.format( Colors.CustomFontType, fontType, size, shadow and "soft-shadow-thick" or ( outline and "outline" or "" ) ) )
end

local function CreateButtonLabel(...)
	local c = CreateLabel(...)
	SetColor(c, Colors.ButtonLabel)
	c:SetFont(Colors.ButtonLabelFont)
	c:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

	return c
end

local function CreateContainer( name, parent, anchor1, anchor2, width, height )
	local c = EHT.CreateControl( name, parent, CT_CONTROL )

	if not width and not height then c:SetResizeToFitDescendents( true ) end
	if anchor1 then AddAnchor( c, anchor1 ) end
	if anchor2 then AddAnchor( c, anchor2 ) end
	if width then c:SetWidth( width ) end
	if height then c:SetHeight( height ) end

	return c
end

local function CreateTexture( name, parent, anchor1, anchor2, width, height, texture, color )
	local c = EHT.CreateControl( name, parent, CT_TEXTURE )

	c:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
	if anchor1 then AddAnchor( c, anchor1 ) end
	if anchor2 then AddAnchor( c, anchor2 ) end
	if width then c:SetWidth( width ) end
	if height then c:SetHeight( height ) end
	if texture then c:SetTexture( texture ) end
	if color then SetColor( c, color ) end

	return c
end

local function CreateButtonOnMouseEnter( control )
	control.Backdrop:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 1.4 )
	WINDOW_MANAGER:SetMouseCursor( MOUSE_CURSOR_UI_HAND )
end

local function CreateButtonOnMouseExit( control )
	control.Backdrop:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 1 )
	WINDOW_MANAGER:SetMouseCursor( MOUSE_CURSOR_DO_NOT_CARE )
end

local function CreateButton( name, parent, label, anchor, width, height, onClick )
	local button = CreateContainer( name, parent, anchor, nil, width, height )
	if anchor then AddAnchor( button, anchor ) end
	button:SetMouseEnabled( true )
	button:SetHandler( "OnMouseDown", onClick )
	button:SetHandler( "OnMouseEnter", CreateButtonOnMouseEnter )
	button:SetHandler( "OnMouseExit", CreateButtonOnMouseExit )

	button.Outline = CreateTexture( name .. "Outline", button, CreateAnchor( TOPLEFT, button, TOPLEFT, 0, 0 ), CreateAnchor( BOTTOMRIGHT, button, BOTTOMRIGHT, 0, 0 ), nil, nil, EHT.Textures.SOLID, Colors.ButtonOutline )
	button.Outline:SetMouseEnabled( false )

	button.Backdrop = CreateTexture( name .. "Backdrop", button.Outline, CreateAnchor( TOPLEFT, button.Outline, TOPLEFT, 1, 1 ), CreateAnchor( BOTTOMRIGHT, button.Outline, BOTTOMRIGHT, -1, -1 ), nil, nil, EHT.Textures.SOLID, Colors.ButtonBackdrop )
	button.Backdrop:SetMouseEnabled( false )
	
	button.Label = CreateButtonLabel( name .. "Label", button.Backdrop, label, CreateAnchor( TOPLEFT, button.Backdrop, TOPLEFT, 0, 0 ), CreateAnchor( BOTTOMRIGHT, button.Backdrop, BOTTOMRIGHT, 0, 0 ) )
	button.Label:SetMouseEnabled( false )

	if not width and not height then
		local width, height = button.Label:GetTextDimensions()
		button:SetDimensions( width + 24, height + 12 )
	end

	return button
end

local function CreateEditBox( name, parent, anchor1, anchor2, width, height, maxChars )
	local c = WINDOW_MANAGER:CreateControlFromVirtual( nil, parent, "ZO_EditBackdrop" )
	local co = Colors.ControlBox.tr

	co = Colors.ControlBackdrop
	c:SetDimensions( width or 200, height or 28 )

	AddAnchor( c, anchor1 )
	AddAnchor( c, anchor2 )

	local e = WINDOW_MANAGER:CreateControlFromVirtual( name, c, "ZO_DefaultEditForBackdrop" )

	e:SetFont( "$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thin" )
	e:SetAnchor( TOPLEFT, c, TOPLEFT, 2, 2 )
	e:SetAnchor( BOTTOMRIGHT, c, BOTTOMRIGHT, -2, -2 )
	e:SetMaxInputChars( maxChars or 255 )
	e:SetMouseEnabled( true )

	return e, c
end

local function Create3DTexture( name, parent, texture, options )
	local width, height, r, g, b, a, x, y, z, pitch, yaw, roll, cx1, cx2, cy1, cy2, depthBuffer, wrap

	if "table" == type( options ) then
		width = tonumber( options.width )
		height = tonumber( options.height )
		r, g, b, a = tonumber( options.r ), tonumber( options.g ), tonumber( options.b ), tonumber( options.a )
		x, y, z = tonumber( options.x ), tonumber( options.y ), tonumber( options.z )
		pitch, yaw, roll = tonumber( options.pitch ), tonumber( options.yaw ), tonumber( options.roll )
		cx1, cx2, cy1, cy2 = tonumber( options.cx1 ), tonumber( options.cx2 ), tonumber( options.cy1 ), tonumber( options.cy2 )
		depthBuffer = options.depthBuffer
		wrap = options.wrap
	end

	width, height = width or 500, height or 500
	r, g, b, a = r or 1, g or 1, b or 1, a or 1
	pitch, yaw, roll = pitch or 0, yaw or 0, roll or 0
	cx1, cx2, cy1, cy2 = cx1 or 0, cx2 or 1, cy1 or 0, cy2 or 1
	depthBuffer = false ~= depthBuffer
	wrap = true == wrap

	local c = CreateTexture( name, parent )
	c:SetHidden( true )
	c:SetTexture( texture )
	c:SetAddressMode( wrap and TEX_MODE_WRAP or TEX_MODE_CLAMP )
	c:SetColor( r, g, b, a )
	c:SetTextureCoords( cx1, cx2, cy1, cy2 )
	c:Create3DRenderSpace()
	c:Set3DLocalDimensions( width / 100, height / 100 )
	c:Set3DRenderSpaceOrientation( pitch, yaw, roll )
	if x or y or z then
		c:Set3DRenderSpaceOrigin( EHT.Effect:Get3DPosition( x or 0, y or 0, z or 0 ) )
	end
	c:Set3DRenderSpaceUsesDepthBuffer( depthBuffer )
	c.cx1, c.cx2, c.cy1, c.cy2 = cx1, cx2, cy1, cy2

	return c
end

local function CreateWindowBackdrop( outlineName, backdropName, parent, topFadeHeight, bottomFadeHeight )
	topFadeHeight, bottomFadeHeight = topFadeHeight or 0, bottomFadeHeight or 0
	local f, bb, bo, tb, to

	local o = CreateTexture( outlineName, parent )
	o:SetAnchor( TOPLEFT, parent, TOPLEFT, 0, topFadeHeight )
	o:SetAnchor( BOTTOMRIGHT, parent, BOTTOMRIGHT, 0, bottomFadeHeight )
	o:SetMouseEnabled( false )
	SetColor( o, Colors.WindowBox )

	if 0 < topFadeHeight then
		f = CreateTexture( nil, parent )
		to = f
		f:SetAnchor( TOPLEFT, o, TOPLEFT, 0, -topFadeHeight )
		f:SetAnchor( BOTTOMRIGHT, o, TOPRIGHT, 0, 0 )
		f:SetMouseEnabled( false )
		SetColor( f, CreateGradientFade( Colors.WindowBox, bit.Set( bit.New( 1 ), bit.New( 2 ) ) ) )

		f = CreateTexture( nil, parent )
		tb = f
		f:SetAnchor( TOPLEFT, o, TOPLEFT, 2, -( topFadeHeight - 2 ) )
		f:SetAnchor( BOTTOMRIGHT, o, TOPRIGHT, -2, 2 )
		f:SetMouseEnabled( false )
		SetColor( f, CreateGradientFade( Colors.WindowBackdrop, bit.Set( bit.New( 1 ), bit.New( 2 ) ) ) )
	end

	if 0 < bottomFadeHeight then
		f = CreateTexture( nil, parent )
		bo = f
		f:SetAnchor( TOPLEFT, o, BOTTOMLEFT, 0, 0 )
		f:SetAnchor( BOTTOMRIGHT, o, BOTTOMRIGHT, 0, bottomFadeHeight )
		f:SetMouseEnabled( false )
		SetColor( f, CreateGradientFade( Colors.WindowBox, bit.Set( bit.New( 3 ), bit.New( 4 ) ) ) )

		f = CreateTexture( nil, parent )
		bb = f
		f:SetAnchor( TOPLEFT, o, BOTTOMLEFT, 2, -2 )
		f:SetAnchor( BOTTOMRIGHT, o, BOTTOMRIGHT, -2, bottomFadeHeight - 2 )
		f:SetMouseEnabled( false )
		SetColor( f, CreateGradientFade( Colors.WindowBackdrop, bit.Set( bit.New( 3 ), bit.New( 4 ) ) ) )
	end

	local b = CreateTexture( backdropName, parent )

	b:SetAnchor( TOPLEFT, o, TOPLEFT, 2, 2 )
	b:SetAnchor( BOTTOMRIGHT, o, BOTTOMRIGHT, -2, -2 )
	b:SetMouseEnabled( false )
	SetColor( b, Colors.WindowBackdrop )

	return o, b, to, tb, bo, bb
end

local function CreateWindowPanel( outlineName, backdropName, parent, anchor1, anchor2 )
	local o = CreateTexture( outlineName, parent )

	if anchor1 then
		AddAnchor( o, anchor1 )
	else
		o:SetAnchor( TOPLEFT, parent, TOPLEFT, 0, 0 )
	end

	if anchor2 then
		AddAnchor( o, anchor2 )
	else
		o:SetAnchor( BOTTOMRIGHT, parent, BOTTOMRIGHT, 0, 0 )
	end

	o:SetMouseEnabled( false )
	SetColor( o, Colors.ControlBox )

	local b = CreateTexture( backdropName, parent )

	b:SetAnchor( TOPLEFT, o, TOPLEFT, 2, 2 )
	b:SetAnchor( BOTTOMRIGHT, o, BOTTOMRIGHT, -2, -2 )
	b:SetMouseEnabled( false )
	SetColor( b, Colors.ListBackdrop )

	return o, b
end

local function CreateDivider( name, parent, anchor1, anchor2 )
	local c = EHT.CreateControl( name, parent, CT_TEXTURE )

	c:SetHeight( 8 )
	c:SetTexture( EHT.Textures.SOLID_SOFT )
	c:SetTextureCoords( 0, 1, -1.25, 2.25 )
	SetColor( c, Colors.Divider )
	AddAnchor( c, anchor1 )
	AddAnchor( c, anchor2 )

	return c
end

---[ Custom Control Pool ]---

do
	EHT.ControlPool = ZO_ObjectPool:Subclass()

	local function ControlFactory( pool )
		local control = EHT.CreateControl( nil, pool.parent, pool.controlType )
		control:SetHidden( true )
		if pool.customFactory then pool.customFactory( control ) end
		return control
	end

	local function ControlReset( control, pool )
		if pool.customReset then pool.customReset( control ) end
	end

	function EHT.ControlPool:New( controlType, parent, customFactory, customReset )
		local pool = ZO_ObjectPool.New( self, ControlFactory, ControlReset )
		pool.parent = parent or GuiRoot
		pool.controlType = controlType
		pool.customFactory = customFactory
		pool.customReset = customReset
		return pool
	end

	function EHT.ControlPool:AcquireObject( objectKey )
		local control, key = ZO_ObjectPool.AcquireObject( self, objectKey )
		if control then control.key = key end
		return control, key
	end
end

---[ Picklist Control ]---

do
	EHT.UI.Picklist = ZO_Object:Subclass()

	local base = EHT.UI.Picklist

	local defaults = { }
	base.Defaults = defaults
	defaults.AlphaPicklist = 1
	defaults.ColorArrow = Colors.Arrow
	defaults.ColorBackdrop = Colors.ControlBackdrop
	defaults.ColorBox = Colors.ControlBox
	defaults.ColorLabel = Colors.Label
	defaults.ColorListBackdrop = Colors.ListBackdrop
	defaults.ColorListBox = Colors.ListBox
	defaults.ColorItemMouseEnter = Colors.ItemMouseEnter
	defaults.ColorItemSelected = Colors.ItemSelected
	defaults.ColorItemLabel = Colors.ItemLabel
	defaults.ColorFilterDisabled = Colors.FilterDisabled
	defaults.ColorSliderArrow = Colors.SliderArrow
	defaults.ColorSliderBackdrop = Colors.SliderBackdrop
	defaults.ColorSliderThumb = Colors.SliderThumb
	defaults.DrawLayerPicklist = DL_TEXT
	defaults.DrawLevelPicklist = 50000
	defaults.DrawTierPicklist = DT_HIGH
	defaults.FontLabel = "$(MEDIUM_FONT)|$(KB_16)"
	defaults.FontItemLabel = "$(MEDIUM_FONT)|$(KB_16)"
	defaults.Height = 26
	defaults.HeightListMaxRatio = 0.9
	defaults.HeightMax = 200
	defaults.HeightMin = 24
	defaults.PaddingListHeight = 10
	defaults.PaddingListWidth = 28
	defaults.ScrollInterval = 100
	defaults.ScrollLinesLarge = 10
	defaults.ScrollLinesSmall = 1
	defaults.SpacingItems = 2
	defaults.VisibleItemsMax = 60
	defaults.VisibleItemsMin = 1
	defaults.Width = 200
	defaults.WidthMax = 1024
	defaults.WidthMin = 50

	local behaviors = { }
	base.EventBehaviors = behaviors
	behaviors.HardwareOnly = 1
	behaviors.AlwaysRaise = 2

	base.ActiveInstance = nil
	base.CreateTooltip = EHT.UI.SetInfoTooltip
	base.DefaultSortFunction = function( itemA, itemB ) return 0 > string.compare( itemA.Label, itemB.Label ) end
	base.Instances = { }
	base.WasHardwareEventRaised = false
	base.PicklistDialog = ZO_Object.New( ZO_Object:Subclass() )

	function base.PicklistDialog:Initialize()
		if not self.Initialized then
			local prefix = "EHTPicklistDialog"
			local w, c

			w = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
			self.Window = w
			w:SetHidden( true )
			w:SetAlpha( base.Defaults.AlphaPicklist )
			w:SetClampedToScreen( true )
			w:SetMovable( false )
			w:SetMouseEnabled( false )
			w:SetResizeHandleSize( 0 )
			w:SetDrawLayer( base.Defaults.DrawLayerPicklist )
			w:SetDrawLevel( base.Defaults.DrawLevelPicklist )
			w:SetDrawTier( base.Defaults.DrawTierPicklist )

			c = EHT.CreateControl( nil, w, CT_TEXTURE )
			self.Box = c
			c:SetTexture( EHT.Textures.SOLID )
			c:SetBlendMode( TEX_BLEND_MODE_ALPHA )
			c:SetMouseEnabled( false )
			SetColor( c, base.Defaults.ColorListBox )
			c:SetAnchorFill( w )

			c = EHT.CreateControl( nil, self.Box, CT_TEXTURE )
			self.Backdrop = c
			c:SetTexture( EHT.Textures.SOLID )
			c:SetBlendMode( TEX_BLEND_MODE_ALPHA )
			c:SetMouseEnabled( false )
			SetColor( c, base.Defaults.ColorListBackdrop )
			c:SetAnchor( TOPLEFT, self.Box, TOPLEFT, 2, 2 )
			c:SetAnchor( BOTTOMRIGHT, self.Box, BOTTOMRIGHT, -2, -2 )

			c = EHT.CreateControl( nil, self.Backdrop, CT_SCROLL )
			self.ScrollRegion = c
			c:SetMouseEnabled( true )
			c:SetAnchor( TOPLEFT, self.Backdrop, TOPLEFT, 2, 2 )
			c:SetAnchor( BOTTOMRIGHT, self.Backdrop, BOTTOMRIGHT, -18, -2 )

			c = EHT.CreateControl( nil, self.Backdrop, CT_TEXTURE )
			self.SliderBox = c
			c:SetAnchor( TOPLEFT, self.Backdrop, TOPRIGHT, -17, 21 )
			c:SetAnchor( BOTTOMRIGHT, self.Backdrop, BOTTOMRIGHT, -2, -21 )
			SetColor( c, base.Defaults.ColorSliderBackdrop )
			c:SetMouseEnabled( false )

			c = EHT.CreateControl( nil, self.SliderBox, CT_SLIDER )
			self.Slider = c
			c:SetAllowDraggingFromThumb( true )
			c:SetMouseEnabled( true )
			c:SetValue( 0 )
			c:SetValueStep( 1 )
			c:SetOrientation( ORIENTATION_VERTICAL )
			c:SetThumbTexture( "EsoUI\\Art\\Miscellaneous\\scrollbox_elevator.dds", "EsoUI\\Art\\Miscellaneous\\scrollbox_elevator_disabled.dds", nil, 15, 64 )
			SetColor( c:GetThumbTextureControl(), base.Defaults.ColorSliderThumb )
			c:SetAnchorFill( self.SliderBox )

			self.Slider:SetHandler( "OnValueChanged", function( control, value, eventReason )
				self:Refresh( value )
			end )

			local scrollingUp

			local function Scrolling()
				local value = self.Slider:GetValue()
				if 0 >= value then value = 1 end
				local direction = scrollingUp and -1 or 1
				self.Slider:SetValue( value + direction * ( IsShiftKeyDown() and base.Defaults.ScrollLinesLarge or base.Defaults.ScrollLinesSmall ) )
			end

			local function StopScrolling()
				EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.Picklist.Scrolling" )
			end

			local function StartScrolling( isUp )
				scrollingUp = isUp
				Scrolling()

				EVENT_MANAGER:RegisterForUpdate( "EHT.UI.Picklist.Scrolling", base.Defaults.ScrollInterval, Scrolling )
			end

			self.ScrollRegion:SetHandler( "OnMouseWheel", function( control, delta, ctrl, alt, shift )
				local slider = self.Slider
				local value = slider:GetValue()

				if 0 == value then value = 1 end
				slider:SetValue( value - ( delta * ( shift and base.Defaults.ScrollLinesLarge or base.Defaults.ScrollLinesSmall ) ) )
			end )

			c = EHT.CreateControl( nil, self.Slider, CT_TEXTURE )
			self.SliderUp = c
			c:SetTexture( "esoui/art/miscellaneous/gamepad/gp_scrollarrow_up.dds" )
			c:SetAnchor( BOTTOM, self.Slider, TOP, 0, -1 )
			SetColor( c, base.Defaults.ColorSliderArrow )
			c:SetDimensions( 15, 18 )
			c:SetMouseEnabled( true )
			c:SetHandler( "OnMouseUp", StopScrolling )
			c:SetHandler( "OnMouseDown", function() StartScrolling( true ) end )

			c = EHT.CreateControl( nil, self.Slider, CT_TEXTURE )
			self.SliderDown = c
			c:SetTexture( "esoui/art/miscellaneous/gamepad/gp_scrollarrow.dds" )
			c:SetAnchor( TOP, self.Slider, BOTTOM, 0, 1 )
			SetColor( c, base.Defaults.ColorSliderArrow )
			c:SetDimensions( 15, 18 )
			c:SetMouseEnabled( true )
			c:SetHandler( "OnMouseUp", StopScrolling )
			c:SetHandler( "OnMouseDown", function() StartScrolling( false ) end )

			c = EHT.CreateControl( nil, self.ScrollRegion, CT_CONTROL )
			self.ListBox = c
			c:SetAnchorFill( self.ScrollRegion )
			c:SetMouseEnabled( false )

			c = EHT.CreateControl( nil, self.ListBox, CT_TEXTURE )
			self.ItemMouseEnter = c
			c:SetHidden( true )
			c:SetTexture( EHT.Textures.SOLID )
			c:SetBlendMode( TEX_BLEND_MODE_ALPHA )
			SetColor( c, base.Defaults.ColorItemMouseEnter )
			c:SetMouseEnabled( false )

			c = EHT.CreateControl( nil, self.ListBox, CT_TEXTURE )
			self.ItemSelected = c
			c:SetHidden( true )
			c:SetTexture( EHT.Textures.SOLID )
			c:SetBlendMode( TEX_BLEND_MODE_ALPHA )
			SetColor( c, base.Defaults.ColorItemSelected )
			c:SetMouseEnabled( false )

			self.ListItems = { }

			for index = 1, base.Defaults.VisibleItemsMax do
				c = EHT.CreateControl( nil, self.ListBox, CT_LABEL )
				table.insert( self.ListItems, c )
				SetColor( c, base.Defaults.ColorItemLabel )
				c:SetFont( base.Defaults.FontItemLabel )
				c:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
				c:SetMaxLineCount( 10 )
				c:SetMouseEnabled( true )
				c:SetText( "" )
				c:SetWrapMode( TEXT_WRAP_MODE_ELLIPSIS )
				c:SetHandler( "OnMouseEnter", function( control )
					self:OnItemMouseEnter( control )
					self:OnShowItemTooltip( control )
				end )
				c:SetHandler( "OnMouseExit", function( control )
					self:OnItemMouseExit( control )
					EHT.UI.HideTooltip()
				end )
				c:SetHandler( "OnMouseDown", function( control, ... )
					self:OnItemMouseDown( control.ItemIndex, control.Item, ... )
				end )
			end

			self.OnMousePressHandler = function( ... )
				self:OnMousePressed( ... )
			end

			self.Initialized = true
		end

		return self.Window
	end

	function base.PicklistDialog:OnMousePressed( button, state )
		if self.ActiveInstance then
			if not EHT.UI.IsMouseOverControl( self.Window ) and not EHT.UI.IsMouseOverControl( self.ActiveInstance:GetControl() ) then
				self:Hide()
			end
		end
	end

	function base.PicklistDialog:GetMaxHeight()
		return math.floor( GuiRoot:GetHeight() * base.Defaults.HeightListMaxRatio )
	end

	function base.PicklistDialog:IsActiveInstance( instance )
		return instance == self.ActiveInstance
	end

	function base.PicklistDialog:Hide()
		self.ActiveInstance = nil

		local win = self:Initialize()
		win:SetHidden( true )
	end

	function base.PicklistDialog:Show( instance )
		if self.ActiveInstance == instance then
			return
		end

		local win = self:Initialize()
		win:SetHidden( true )

		self.ActiveInstance = instance
		if not instance then
			return
		end

		local items = instance:GetItems()
		if not items then
			return
		end

		local itemHeight = self:GetItemHeight()
		local listItemsVisible = self:GetNumVisibleItems()
		local listHeight = ( itemHeight * listItemsVisible ) + base.Defaults.PaddingListHeight
		local listWidth = instance:GetWidth() + base.Defaults.PaddingListWidth
		local listItem, previousItem

		self.ItemMouseEnter:SetHidden( true )
		self.ItemMouseEnter:ClearAnchors()

		self.ItemSelected:SetHidden( true )
		self.ItemSelected:ClearAnchors()

		for index = 1, #self.ListItems do
			listItem = self.ListItems[index]

			listItem:ClearAnchors()
			if 1 == index then
				listItem:SetAnchor( TOPLEFT, self.ListBox, TOPLEFT, 1, 1 )
				listItem:SetAnchor( BOTTOMRIGHT, self.ListBox, TOPRIGHT, -1, itemHeight )
				listItem:SetHidden( false )
			elseif index <= listItemsVisible then
				listItem:SetAnchor( TOPLEFT, previousItem, BOTTOMLEFT, 0, 0 )
				listItem:SetAnchor( BOTTOMRIGHT, previousItem, BOTTOMRIGHT, 0, itemHeight )
				listItem:SetHidden( false )
			else
				listItem:SetHidden( true )
			end

			previousItem = listItem
		end

		self.Slider:SetMinMax( 1, math.max( 1, 1 + #items - listItemsVisible ) )

		if instance:GetSorted() and instance:GetItemsDirty() then
			local sorter = instance:GetSortFunction()

			if "function" == type( sorter ) then
				table.sort( instance:GetItems(), sorter )
			end

			instance:SetItemsDirty( false )
		end

		self.Slider:SetHidden( listItemsVisible >= #items )

		local maxWidth = 0

		for index = 1, listItemsVisible do
			maxWidth = math.max( maxWidth, self:GetItemLabelWidth( index ) )
		end

		if maxWidth > listWidth - base.Defaults.PaddingListWidth then
			listWidth = maxWidth + 2 * base.Defaults.PaddingListWidth
		end

		win:SetDimensions( listWidth, listHeight )
		self:RefreshAnchor()
		self:ScrollToSelected()
		win:SetHidden( false )

		EVENT_MANAGER:RegisterForUpdate( "EHT.UI.PicklistDialog.OnHeartbeat", 200, function() self:OnHeartbeat() end )
	end

	function base.PicklistDialog:RefreshAnchor()
		if not self.Window or not self.ActiveInstance then
			return
		end

		local instance = self.ActiveInstance
		local screenWidth, screenHeight = GuiRoot:GetDimensions()
		local screenCenterX, screenCenterY = GuiRoot:GetCenter()
		local width, height = self.Window:GetDimensions()
		local left, top, right, bottom = instance:GetScreenRect()
		local centerX, centerY = instance:GetCenter()

		self.Window:ClearAnchors()

		if screenWidth > left + width and screenHeight > bottom + height then
			self.Window:SetAnchor( TOPLEFT, instance:GetControl(), BOTTOMLEFT, 0, -1 )
		elseif 0 < right - width and screenHeight > bottom + height then
			self.Window:SetAnchor( TOPRIGHT, instance:GetControl(), BOTTOMRIGHT, 0, -1 )
		elseif screenWidth > left + width and 0 < top - height then
			self.Window:SetAnchor( BOTTOMLEFT, instance:GetControl(), TOPLEFT, 0, 1 )
		elseif 0 < right - width and 0 < top - height then
			self.Window:SetAnchor( BOTTOMRIGHT, instance:GetControl(), TOPRIGHT, 0, 1 )
		elseif screenCenterX >= centerX then
			self.Window:SetAnchor( LEFT, instance:GetControl(), RIGHT, -1, 0 )
		else
			self.Window:SetAnchor( RIGHT, instance:GetControl(), LEFT, 1, 0 )
		end

		self.AnchorX, self.AnchorY = centerX, centerY
	end

	function base.PicklistDialog:GetFontHeight()
		return self.ListItems[1]:GetFontHeight()
	end

	function base.PicklistDialog:GetItemLabelWidth( index )
		local item = self.ListItems[index]

		if not item then
			return 0
		end

		local text = item:GetText()

		if not text or "" == text then
			return 0
		end

		local newLineIndex = string.find( text, "\n" )

		if newLineIndex and 0 < newLineIndex then
			text = string.sub( text, 1, newLineIndex - 1 )
		end

		return item:GetStringWidth( text )
	end

	function base.PicklistDialog:GetItemHeight()
		local instance = self.ActiveInstance
		local itemLineHeight = self:GetFontHeight() or 0
		local itemLines = instance and ( instance:GetItemLines() or 0 ) or 0
		local itemHeight = itemLines * itemLineHeight + base.Defaults.SpacingItems

		return itemHeight
	end

	function base.PicklistDialog:GetNumVisibleItems()
		local instance = self.ActiveInstance

		if not instance then
			return 0
		end

		local items = instance:GetItems()

		if not items then
			return 0
		end

		local itemHeight = self:GetItemHeight()
		local maxHeight = self:GetMaxHeight()
		local count = math.floor( math.max( base.Defaults.VisibleItemsMin * itemHeight, math.min( #items * itemHeight, maxHeight ) ) / itemHeight )

		return math.min( count, base.Defaults.VisibleItemsMax )
	end

	function base.PicklistDialog:Refresh( offset )
		local instance = self.ActiveInstance
		if not instance then
			return
		end

		offset = offset or self.Slider:GetValue()

		local win = self:Initialize()
		local items = instance:GetItems()
		local itemIndex = offset
		local itemsVisible = self:GetNumVisibleItems()
		local maxItemIndex = math.min( #items, offset + itemsVisible )
		local selectedItem = instance:GetSelectedItemObject()

		for index = 1, itemsVisible do
			local listItem = self.ListItems[index]
			local item = items[itemIndex]

			if item then
				listItem:SetText( item.Label )
				listItem.ItemIndex = itemIndex
				listItem.Item = item

				if selectedItem == item then
					self.ItemSelected:ClearAnchors()
					self.ItemSelected:SetAnchorFill( listItem )
					self.ItemSelected:SetHidden( false )
					selectedItem = nil
				end

				itemIndex = itemIndex + 1
				if itemIndex > maxItemIndex then
					itemIndex = -1
				end
			else
				listItem:SetText( "" )
				listItem.ItemIndex = nil
				listItem.Item = nil
			end
		end

		if selectedItem then
			self.ItemSelected:SetHidden( true )
			self.ItemSelected:ClearAnchors()
		end
	end

	function base.PicklistDialog:ScrollToTop()
		self.Slider:SetValue( 1 )
		self:Refresh()
	end

	function base.PicklistDialog:ScrollToSelected()
		local instance = self.ActiveInstance

		if not instance then
			self:ScrollToTop()
			return
		end

		local itemIndex = instance:GetSelectedItemIndex()

		if not itemIndex then
			self:ScrollToTop()
			return
		end

		self.Slider:SetValue( itemIndex )
		self:Refresh()
	end

	function base.PicklistDialog:OnHeartbeat()
		local instance = self.ActiveInstance

		if not instance then
			EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.PicklistDialog.OnHeartbeat" )
			return
		end

		if instance:GetControl():IsHidden() then
			self:Hide()
			EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.PicklistDialog.OnHeartbeat" )
			return
		end

		local centerX, centerY = instance:GetCenter()

		if centerX ~= self.AnchorX or centerY ~= self.AnchorY then
			self:RefreshAnchor()
		end
	end

	function base.PicklistDialog:OnItemMouseEnter( control )
		if control and control.Item then
			local _, _, anchor = self.ItemMouseEnter:GetAnchor( 1 )

			if control ~= anchor then
				self.ItemMouseEnter:ClearAnchors()
				self.ItemMouseEnter:SetAnchorFill( control )
				self.ItemMouseEnter:SetHidden( false )
			end
		end
	end

	function base.PicklistDialog:OnItemMouseExit( control )
		local _, _, anchor = self.ItemMouseEnter:GetAnchor( 1 )

		if control == anchor then
			self.ItemMouseEnter:SetHidden( true )
			self.ItemMouseEnter:ClearAnchors()
		end
	end

	function base.PicklistDialog:OnItemMouseDown( itemIndex, item )
		local instance = self.ActiveInstance

		if instance and itemIndex and item then
			base.WasHardwareEventRaised = true
			instance:SetSelectedItem( item )
		end

		self:Hide()
	end

	function base.PicklistDialog:OnShowItemTooltip( control )
		if control:GetWidth() < control:GetStringWidth( control:GetText() ) then
			local screenX = GuiRoot:GetCenter()
			local controlX = control:GetCenter()
			local anchorTooltip, anchorControl, anchorOffsetX

			if controlX <= screenX then
				anchorTooltip, anchorControl, anchorOffsetX = LEFT, RIGHT, 25
			else
				anchorTooltip, anchorControl, anchorOffsetX = RIGHT, LEFT, -25
			end

			EHT.UI.ShowTooltip( nil, control, EHT.Util.Trim( control:GetText() ), anchorTooltip, anchorOffsetX, 0, anchorControl )
		end
	end

	function EHT.UI.Picklist:New( ... )
		local obj = ZO_Object.New( self )
		local picklist = obj:Initialize( ... )

		if picklist then
			base.Instances[picklist:GetName()] = picklist
		end

		return picklist
	end

	function EHT.UI.Picklist:Initialize( name, parent, anchorFrom, anchor, anchorTo, anchorOffsetX, anchorOffsetY, width, height )
		if not self then
			error( string.format( "Failed to create Picklist: Initialization instance is nil." ) )
			return nil
		end

		if self.Initialized then
			error( string.format( "Failed to create Picklist: Instance is already initialized." ) )
			return nil
		end

		if not parent then
			error( string.format( "Failed to create Picklist: Parent is required." ) )
			return nil
		end

		if not name then
			error( string.format( "Failed to create Picklist: Name is required." ) )
			return nil
		end

		if base.Instances[name] then
			error( string.format( "Failed to create Picklist: Duplicate name: %s", name ) )
			return nil
		end

		local c

		self.Enabled = true
		self.EventBehavior = base.EventBehaviors.HardwareOnly
		self.Name = name
		self.Parent = parent
		self.Width = width or base.Defaults.Width
		self.Height = height or base.Defaults.Height
		self.ItemLines = 1
		self.Sorted = false
		self.SortFunction = base.DefaultSortFunction
		self.SelectedItem = nil
		self.ItemsDirty = false
		self.Items = { }

		c = EHT.CreateControl( name, parent, CT_CONTROL )
		self.Control = c
		c:SetDimensions( self.Width, self.Height )
		c:SetMouseEnabled( true )
		c:SetHandler( "OnMouseDown", function( ... )
			self:TogglePicklist()
		end )

		c = EHT.CreateControl( nil, self.Control, CT_TEXTURE )
		self.Control.Box = c
		c:SetTexture( EHT.Textures.SOLID )
		c:SetBlendMode( TEX_BLEND_MODE_ALPHA )
		SetColor( c, base.Defaults.ColorBox )
		c:SetAnchor( TOPLEFT, self.Control, TOPLEFT, 0, 0 )
		c:SetAnchor( BOTTOMRIGHT, self.Control, BOTTOMRIGHT, 0, 0 )

		c = EHT.CreateControl( nil, self.Control.Box, CT_TEXTURE )
		self.Control.Backdrop = c
		c:SetTexture( EHT.Textures.SOLID )
		c:SetBlendMode( TEX_BLEND_MODE_ALPHA )
		SetColor( c, base.Defaults.ColorBackdrop )
		c:SetAnchor( TOPLEFT, self.Control.Box, TOPLEFT, 2, 2 )
		c:SetAnchor( BOTTOMRIGHT, self.Control.Box, BOTTOMRIGHT, -2, -2 )

		c = EHT.CreateControl( nil, self.Control.Backdrop, CT_LABEL )
		self.Control.Label = c
		SetColor( c, base.Defaults.ColorLabel )
		c:SetFont( base.Defaults.FontLabel )
		c:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		c:SetText( "" )
		c:SetVerticalAlignment( TEXT_ALIGN_CENTER )
		c:SetAnchor( TOPLEFT, self.Control.Backdrop, TOPLEFT, 3, 0 )
		c:SetAnchor( BOTTOMRIGHT, self.Control.Backdrop, BOTTOMRIGHT, -20, -2 )

		c = EHT.CreateControl( nil, self.Control.Backdrop, CT_TEXTURE )
		self.Control.Arrow = c
		c:SetTexture( EHT.Textures.ICON_ARROW )
		c:SetBlendMode( TEX_BLEND_MODE_ALPHA )
		SetColor( c, base.Defaults.ColorArrow )
		c:SetTextureCoords( 0, 1, 1, 0 )
		c:SetAnchor( TOPLEFT, self.Control.Backdrop, TOPRIGHT, -14, 8 )
		c:SetAnchor( BOTTOMRIGHT, self.Control.Backdrop, BOTTOMRIGHT, -3, -8 )

		self:SetAnchor( anchorFrom, anchor, anchorTo, anchorOffsetX, anchorOffsetY )
		self.Initialized = true

		return self
	end

	function EHT.UI.Picklist:RefreshEnabled()
		self:HidePicklist()
		self.Control:SetMouseEnabled( self.Enabled )
		SetColor( self.Control.Box, base.Defaults.ColorBox, ( not self.Enabled ) and base.Defaults.ColorFilterDisabled )
		SetColor( self.Control.Label, base.Defaults.ColorLabel, ( not self.Enabled ) and base.Defaults.ColorFilterDisabled )
	end

	function EHT.UI.Picklist:SetEnabled( value )
		self.Enabled = true == value
		self:RefreshEnabled()
	end

	function EHT.UI.Picklist:GetEventBehavior( value )
		return self.EventBehavior
	end

	function EHT.UI.Picklist:SetEventBehavior( value )
		if EHT.Util.IsListValue( base.EventBehaviors, value ) then
			self.EventBehavior = value
		end
	end

	function EHT.UI.Picklist:GetName()
		return self.Name
	end

	function EHT.UI.Picklist:GetParent()
		return self.Parent
	end

	function EHT.UI.Picklist:GetControl()
		return self.Control
	end

	function EHT.UI.Picklist:GetDrawLevel()
		return self.Control:GetDrawLevel()
	end

	function EHT.UI.Picklist:SetDrawLevel( value )
		self.Control:SetDrawLevel( value )
	end

	function EHT.UI.Picklist:GetWidth()
		return self.Control:GetWidth()
	end

	function EHT.UI.Picklist:SetWidth( value )
		self.Width = zo_clamp( tonumber( value ) or base.Defaults.Width, base.Defaults.WidthMin, base.Defaults.WidthMax )
		self.Control:SetWidth( self.Width )
		return self.Width
	end

	function EHT.UI.Picklist:GetHeight()
		return self.Control:GetHeight()
	end

	function EHT.UI.Picklist:SetHeight( value )
		self.Height = zo_clamp( tonumber( value ) or base.Defaults.Height, base.Defaults.HeightMin, base.Defaults.HeightMax )
		self.Control:SetHeight( self.Height )
		return self.Height
	end

	function EHT.UI.Picklist:GetDimensions()
		return self.Control:GetDimensions()
	end

	function EHT.UI.Picklist:SetDimensions( width, height )
		self.Control:SetDimensions( width, height )
	end

	function EHT.UI.Picklist:GetCenter()
		return self.Control:GetCenter()
	end

	function EHT.UI.Picklist:GetScreenRect()
		return self.Control:GetScreenRect()
	end

	function EHT.UI.Picklist:GetItemLines()
		return self.ItemLines or 1
	end

	function EHT.UI.Picklist:SetItemLines( value )
		self.ItemLines = zo_clamp( tonumber( value ) or 1, 1, 10 )
	end

	function EHT.UI.Picklist:GetItemsDirty()
		return self.ItemsDirty
	end

	function EHT.UI.Picklist:SetItemsDirty( value )
		self.ItemsDirty = true == value
	end

	function EHT.UI.Picklist:GetSorted()
		return self.Sorted
	end

	function EHT.UI.Picklist:SetSorted( value )
		self.Sorted = true == value
		self.ItemsDirty = true
	end

	function EHT.UI.Picklist:GetSortFunction()
		return self.SortFunction
	end

	function EHT.UI.Picklist:SetSortFunction( func )
		self.ItemsDirty = true
		self.SortFunction = "function" == type( func ) and func or nil

		if self.SortFunction then
			self.Sorted = true
		else
			self.Sorted = false
			self.SortFunction = base.DefaultSortFunction
		end
	end

	function EHT.UI.Picklist:GetHandlers( event )
		if not event then
			return nil
		end

		event = string.lower( event )

		if not self.Handlers then
			self.Handlers = { }
		end

		local handlers = self.Handlers[event]

		if not handlers then
			handlers = { }
			self.Handlers[event] = handlers
		end

		return handlers
	end

	function EHT.UI.Picklist:AddHandler( event, handler )
		local handlers = self:GetHandlers( event )

		if handlers then
			handlers[handler] = true
			return handler
		end

		return nil
	end

	function EHT.UI.Picklist:RemoveHandler( event, handler )
		local handlers = self:GetHandlers( event )

		if handlers and handlers[handler] then
			handlers[handler] = nil
			return handler
		end

		return nil
	end

	function EHT.UI.Picklist:CallHandlers( event, ... )
		local handlers = self:GetHandlers( event )

		if handlers then
			for handler in pairs( handlers ) do
				handler( self, ... )
			end
		end
	end

	function EHT.UI.Picklist:IsHidden()
		return self.Control:IsHidden()
	end

	function EHT.UI.Picklist:SetHidden( value )
		self.Control:SetHidden( value )
	end

	function EHT.UI.Picklist:ClearAnchors()
		self.Control:ClearAnchors()
		self:OnResized()
	end

	function EHT.UI.Picklist:SetAnchor( anchorFrom, anchor, anchorTo, anchorOffsetX, anchorOffsetY )
		if anchorFrom or anchor or anchorTo then
			self.Control:SetAnchor( anchorFrom, anchor, anchorTo, anchorOffsetX, anchorOffsetY )
		end
	end

	function EHT.UI.Picklist:GetItems()
		return self.Items
	end

	function EHT.UI.Picklist:GetItemByIndex( index )
		return self.Items[index]
	end

	function EHT.UI.Picklist:FindItemIndex( item )
		local matchedIndex = nil

		if "number" == type( item ) then
			for index, itemObj in ipairs( self.Items ) do
				if item == itemObj.Value then
					matchedIndex = index
					break
				end
			end
		elseif "string" == type( item ) then
			local lowerValue = string.lower( EHT.Util.Trim( item ) )

			for index, itemObj in ipairs( self.Items ) do
				if lowerValue == string.lower( EHT.Util.Trim( itemObj.Label ) ) then
					matchedIndex = index
					break
				end
			end
		elseif "table" == type( item ) then
			for index, itemObj in ipairs( self.Items ) do
				if item.Label == itemObj.Label and item.Value == itemObj.Value then
					matchedIndex = index
					break
				end
			end
		end

		return matchedIndex
	end

	function EHT.UI.Picklist:FindItem( item )
		return self.Items[self:FindItemIndex( item )]
	end

	function EHT.UI.Picklist:GetSelectedItemIndex()
		return self:FindItemIndex( self.SelectedItem )
	end

	function EHT.UI.Picklist:GetSelectedItemValue()
		if self.SelectedItem then
			return self.SelectedItem.Value
		end
		return nil
	end

	function EHT.UI.Picklist:GetSelectedItem()
		return self.SelectedItem and self.SelectedItem.Label or nil
	end

	function EHT.UI.Picklist:GetSelectedItemObject()
		return self.SelectedItem
	end

	function EHT.UI.Picklist:ClearItems()
		if not self.Items then
			self.Items = { }
		else
			for index = #self.Items, 1, -1 do
				table.remove( self.Items, index )
			end
		end

		self.SelectedItem = nil
		self.ItemsDirty = true
		self:Refresh()
	end

	function EHT.UI.Picklist:SetItems( items )
		if "table" == type( items ) then
			self.Items = items
		else
			self:ClearItems()
		end

		self.ItemsDirty = true

		if self.SelectedItem then
			self.SelectedItem = self:FindItem( self.SelectedItem )
		end

		return self:GetItems()
	end

	function EHT.UI.Picklist:AddItem( label, clickHandler, value )
		local item = nil
		if label then
			item = { Label = label, Value = value, ClickHandler = clickHandler }
			table.insert( self.Items, item )
		end

		self.ItemsDirty = true
		return item
	end

	function EHT.UI.Picklist:InsertItem( index, label, clickHandler, value )
		local item = nil
		if label then
			item = { Label = label, Value = value, ClickHandler = clickHandler }
			table.insert( self.Items, index, item )
		end

		self.ItemsDirty = true
		return item
	end

	function EHT.UI.Picklist:SetSelectedItem( item )
		local hardware = base.WasHardwareEventRaised
		base.WasHardwareEventRaised = false

		local previousSelectedItem = self.SelectedItem
		self.SelectedItem = self:FindItem( item )

		if hardware or self:GetEventBehavior() == base.EventBehaviors.AlwaysRaise then
			self:OnSelectionChanged( self.SelectedItem )
		end

		self:Refresh()
		return self.SelectedItem
	end

	function EHT.UI.Picklist:SelectFirstItem()
		local item = self.Items[1]
		if item then
			self:SetSelectedItem( item )
		end
	end

	function EHT.UI.Picklist:OnSelectionChanged( previousItem )
		if self.SelectingRecursions and 0 < self.SelectingRecursions then return end
		self.SelectingRecursions = ( self.SelectingRecursions or 0 ) + 1

		local item = self:GetSelectedItemObject()

		if item and item.ClickHandler then
			item.ClickHandler( self, item )
		end

		self:CallHandlers( "OnSelectionChanged", item, previousItem )
		self.SelectingRecursions = self.SelectingRecursions - 1
	end

	function EHT.UI.Picklist:Refresh()
		local label = nil
		local item = self:GetSelectedItemObject()

		if item then
			label = item.Label
		end

		self.Control.Label:SetText( label or "" )
	end

	function EHT.UI.Picklist:HidePicklist()
		if self.PicklistDialog:IsActiveInstance( self ) then
			self.PicklistDialog:Hide()
		end
	end

	function EHT.UI.Picklist:ShowPicklist()
		self.PicklistDialog:Show( self )
	end

	function EHT.UI.Picklist:TogglePicklist()
		if self.PicklistDialog:IsActiveInstance( self ) then
			self:CallHandlers( "OnHidePicklist" )
			self.PicklistDialog:Hide()
		else
			self:CallHandlers( "OnShowPicklist" )
			self.PicklistDialog:Show( self )
		end
	end

end

---[ List Control ]---

do
	local base = ZO_Object:Subclass()
	EHT.UI.List = base

	local defaults = { }
	base.Defaults = defaults
	defaults.AlphaList = 1
	defaults.ColorBackdrop = Colors.ListBackdrop
	defaults.ColorBox = Colors.ControlBox
	defaults.ColorItemMouseEnter = Colors.ItemMouseEnter
	defaults.ColorItemLabel = Colors.ItemLabel
	defaults.ColorListItemBackdrop = Colors.ListItemBackdrop
	defaults.ColorListItemSelectedBackdrop = Colors.ListItemSelectedBackdrop
	defaults.ColorSliderArrow = Colors.SliderArrow
	defaults.ColorSliderBackdrop = Colors.SliderBackdrop
	defaults.ColorSliderThumb = Colors.SliderThumb
	defaults.DrawLayer = DL_TEXT
	defaults.DrawLevel = 50000
	defaults.DrawTier = DT_HIGH
	defaults.FontItemLabel = "$(BOLD_FONT)|$(KB_16)"
	defaults.Height = 200
	defaults.HeightListMaxRatio = 0.9
	defaults.HeightMax = 1000
	defaults.HeightMin = 40
	defaults.PaddingListHeight = 10
	defaults.PaddingListWidth = 28
	defaults.ScrollInterval = 100
	defaults.ScrollLinesLarge = 10
	defaults.ScrollLinesSmall = 3
	defaults.ScrollRegionInsets = 2
	defaults.SpacingItems = 2
	defaults.VisibleItemsMax = 60
	defaults.VisibleItemsMin = 1
	defaults.Width = 200
	defaults.WidthMax = 1000
	defaults.WidthMin = 80

	local behaviors = { }
	behaviors.HardwareOnly = 1
	behaviors.AlwaysRaise = 2
	base.EventBehaviors = behaviors

	base.CreateTooltip = EHT.UI.SetInfoTooltip
	base.DefaultSortFunction = function( itemA, itemB ) return 0 > string.compare( itemA.Label, itemB.Label ) end

	function base:New( ... )
		local obj = ZO_Object.New( self )
		local list = obj:Initialize( ... )
		return list
	end

	function base:Initialize( name, parent, anchorFrom, anchor, anchorTo, anchorOffsetX, anchorOffsetY, width, height )
		if not self then
			error( string.format( "Failed to create List: Initialization instance is nil." ) )
			return nil
		end

		if self.Initialized then
			error( string.format( "Failed to create List: Instance is already initialized." ) )
			return nil
		end

		if not parent then
			error( string.format( "Failed to create List: Parent is required." ) )
			return nil
		end

		self.Enabled = true
		self.EventBehavior = self.EventBehaviors.HardwareOnly
		self.Name = name
		self.Parent = parent
		self.ItemLines = 1
		self.Sorted = false
		self.SortFunction = base.DefaultSortFunction
		self.DragAndDropEnabled = false
		self.ItemsDirty = false
		self.Items = { }

		local c

		c = EHT.CreateControl( name, parent, CT_CONTROL )
		self.Control = c
		c:SetMouseEnabled( false )
		c:SetDrawTier(DT_HIGH)
		if width and height then
			c:SetDimensions( self.Width, self.Height )
		else
			c:SetResizeToFitDescendents( true )
		end

		c = EHT.CreateControl( nil, self.Control, CT_TEXTURE )
		self.Control.Box = c
		c:SetTexture( EHT.Textures.SOLID )
		c:SetBlendMode( TEX_BLEND_MODE_ALPHA )
		SetColor( c, base.Defaults.ColorBox )
		c:SetAnchor( TOPLEFT, self.Control, TOPLEFT, 0, 0 )
		c:SetAnchor( BOTTOMRIGHT, self.Control, BOTTOMRIGHT, 0, 0 )

		c = EHT.CreateControl( nil, self.Control.Box, CT_TEXTURE )
		self.Control.Backdrop = c
		c:SetTexture( EHT.Textures.SOLID )
		c:SetBlendMode( TEX_BLEND_MODE_ALPHA )
		SetColor( c, base.Defaults.ColorBackdrop )
		c:SetAnchor( TOPLEFT, self.Control.Box, TOPLEFT, 2, 2 )
		c:SetAnchor( BOTTOMRIGHT, self.Control.Box, BOTTOMRIGHT, -2, -2 )

		c = EHT.CreateControl( nil, self.Control.Backdrop, CT_SCROLL )
		self.Control.ScrollRegion = c
		c:SetMouseEnabled( true )
		c:SetAnchor( TOPLEFT, self.Control.Backdrop, TOPLEFT, 2, base.Defaults.ScrollRegionInsets )
		c:SetAnchor( BOTTOMRIGHT, self.Control.Backdrop, BOTTOMRIGHT, -18, -base.Defaults.ScrollRegionInsets )

		c = EHT.CreateControl( nil, self.Control.Backdrop, CT_TEXTURE )
		self.Control.SliderBox = c
		c:SetAnchor( TOPLEFT, self.Control.Backdrop, TOPRIGHT, -17, 21 )
		c:SetAnchor( BOTTOMRIGHT, self.Control.Backdrop, BOTTOMRIGHT, -2, -21 )
		SetColor( c, base.Defaults.ColorSliderBackdrop )
		c:SetMouseEnabled( false )

		c = EHT.CreateControl( nil, self.Control.SliderBox, CT_SLIDER )
		self.Control.Slider = c
		c:SetAllowDraggingFromThumb( true )
		c:SetMouseEnabled( true )
		c:SetValue( 0 )
		c:SetValueStep( 1 )
		c:SetOrientation( ORIENTATION_VERTICAL )
		c:SetThumbTexture( "EsoUI\\Art\\Miscellaneous\\scrollbox_elevator.dds", "EsoUI\\Art\\Miscellaneous\\scrollbox_elevator_disabled.dds", nil, 15, 64 )
		SetColor( c:GetThumbTextureControl(), base.Defaults.ColorSliderThumb )
		c:SetAnchorFill( self.Control.SliderBox )

		self.Control.Slider:SetHandler( "OnValueChanged", function( control, value, eventReason )
			self:Refresh( value )
		end )

		self.Control.ScrollRegion:SetHandler( "OnMouseWheel", function( control, delta, ctrl, alt, shift )
			local slider = self.Control.Slider
			local value = slider:GetValue()
			if 0 == value then value = 1 end
			slider:SetValue( value - ( delta * ( shift and base.Defaults.ScrollLinesLarge or base.Defaults.ScrollLinesSmall ) ) )
		end )

		local scrollingUp

		local function Scrolling()
			local value = self.Control.Slider:GetValue()
			if 0 >= value then value = 1 end
			local direction = scrollingUp and -1 or 1
			self.Control.Slider:SetValue( value + direction * ( IsShiftKeyDown() and base.Defaults.ScrollLinesLarge or base.Defaults.ScrollLinesSmall ) )
		end

		local function StopScrolling()
			EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.List.Scrolling" )
		end

		local function StartScrolling( isUp )
			scrollingUp = isUp
			Scrolling()

			EVENT_MANAGER:RegisterForUpdate( "EHT.UI.List.Scrolling", base.Defaults.ScrollInterval, Scrolling )
		end

		c = EHT.CreateControl( nil, self.Control.Slider, CT_TEXTURE )
		self.Control.SliderUp = c
		c:SetTexture( "esoui/art/miscellaneous/gamepad/gp_scrollarrow_up.dds" )
		c:SetAnchor( BOTTOM, self.Control.Slider, TOP, 0, -1 )
		SetColor( c, base.Defaults.ColorSliderArrow )
		c:SetDimensions( 15, 18 )
		c:SetMouseEnabled( true )
		c:SetHandler( "OnMouseUp", StopScrolling )
		c:SetHandler( "OnMouseDown", function() StartScrolling( true ) end )

		c = EHT.CreateControl( nil, self.Control.Slider, CT_TEXTURE )
		self.Control.SliderDown = c
		c:SetTexture( "esoui/art/miscellaneous/gamepad/gp_scrollarrow.dds" )
		c:SetAnchor( TOP, self.Control.Slider, BOTTOM, 0, 1 )
		SetColor( c, base.Defaults.ColorSliderArrow )
		c:SetDimensions( 15, 18 )
		c:SetMouseEnabled( true )
		c:SetHandler( "OnMouseUp", StopScrolling )
		c:SetHandler( "OnMouseDown", function() StartScrolling( false ) end )

		c = EHT.CreateControl( nil, self.Control.ScrollRegion, CT_CONTROL )
		self.Control.ListBox = c
		c:SetAnchorFill( self.Control.ScrollRegion )
		c:SetMouseEnabled( false )

		self.ListItemBackdrops = { }
		self.ListItems = { }

		for index = 1, base.Defaults.VisibleItemsMax do
			local c = EHT.CreateControl( nil, self.Control.ListBox, CT_TEXTURE )
			table.insert( self.ListItemBackdrops, c )
			SetColor( c, base.Defaults.ColorListItemBackdrop )
			c:SetResizeToFitDescendents( true )
			c:SetMouseEnabled( false )
		end

		c = EHT.CreateControl( nil, self.Control.ListBox, CT_TEXTURE )
		self.Control.ItemMouseEnter = c
		c:SetHidden( true )
		c:SetTexture( EHT.Textures.SOLID )
		c:SetBlendMode( TEX_BLEND_MODE_ALPHA )
		SetColor( c, base.Defaults.ColorItemMouseEnter )
		c:SetMouseEnabled( false )

		for index = 1, base.Defaults.VisibleItemsMax do
			local c = EHT.CreateControl( nil, self.Control.ListBox, CT_LABEL )
			table.insert( self.ListItems, c )

			SetColor( c, base.Defaults.ColorItemLabel )
			c:SetFont( base.Defaults.FontItemLabel )
			c:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
			c:SetMaxLineCount( 10 )
			c:SetText( "" )
			c:SetWrapMode( TEXT_WRAP_MODE_ELLIPSIS )
			c:SetMouseEnabled( true )
			c:SetHandler( "OnMouseEnter", function()
				self:OnItemMouseEnter( c )
				self:OnShowItemTooltip( c )
			end )
			c:SetHandler( "OnMouseExit", function()
				self:OnItemMouseExit( c )
				EHT.UI.HideTooltip()
			end )
			c:SetHandler( "OnMouseDown", function( c, ... )
				self:OnItemMouseDown( c, ... )
			end )
			c:SetHandler( "OnMouseUp", function( c, ... )
				self:OnItemMouseUp( c, ... )
			end )
		end

		self:AnchorListItems()
		self:SetAnchor( anchorFrom, anchor, anchorTo, anchorOffsetX, anchorOffsetY )
		self.Initialized = true

		do
			local w = WINDOW_MANAGER:CreateTopLevelWindow()
			self.DragContainer = w
			w:SetDimensions( 400, 50 )
			w:SetClampedToScreen( true )
			w:SetClampedToScreenInsets( 0, 0, 0, 0 )
			w:SetMouseEnabled( true )
			w:SetMovable( true )
			w:SetResizeHandleSize( 0 )
			w:SetHidden( true )
			w:SetDrawLayer( DL_OVERLAY )
			w:SetDrawTier( DT_HIGH )
			w:SetDrawLevel( 221001 )

			local bo = EHT.CreateControl( nil, self.DragContainer, CT_TEXTURE )
			w.Border = bo
			SetColor( bo, FadeColor( base.Defaults.ColorListItemSelectedBackdrop, 1, 0.65 ) )
			bo:SetMouseEnabled( false )
			bo:SetAnchor( TOPLEFT, w, TOPLEFT, 0, 0 )
			bo:SetAnchor( BOTTOMRIGHT, w, BOTTOMRIGHT, 0, 0 )

			local b = EHT.CreateControl( nil, self.DragContainer, CT_TEXTURE )
			w.Backdrop = b
			SetColor( b, FadeColor( base.Defaults.ColorBackdrop, 1, 0.65 ) )
			b:SetMouseEnabled( false )
			b:SetAnchor( TOPLEFT, w, TOPLEFT, 3, 3 )
			b:SetAnchor( BOTTOMRIGHT, w, BOTTOMRIGHT, -3, -3 )

			local c = EHT.CreateControl( nil, b, CT_LABEL )
			w.Label = c
			SetColor( c, base.Defaults.ColorItemLabel )
			c:SetMouseEnabled( false )
			c:SetFont( base.Defaults.FontItemLabel )
			c:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
			c:SetVerticalAlignment( TEXT_ALIGN_CENTER )
			c:SetMaxLineCount( 10 )
			c:SetText( "" )
			c:SetWrapMode( TEXT_WRAP_MODE_ELLIPSIS )
			c:SetAnchor( TOPLEFT, b, TOPLEFT, 6, 3 )
			c:SetAnchor( BOTTOMRIGHT, b, BOTTOMRIGHT, -6, -3 )
		end

		return self
	end

	function base:RefreshList()
		local items = self:GetItems()
		if not items then
			return
		end

		local listItemsVisible = self:GetNumVisibleItems()
		self.Control.ItemMouseEnter:SetHidden( true )
		self.Control.ItemMouseEnter:ClearAnchors()
		self.Control.Slider:SetMinMax( 1, math.max( 1, 1 + #items - listItemsVisible ) )
		self.Control.Slider:SetHidden( listItemsVisible >= #items )

		if self:GetSorted() and self:GetItemsDirty() then
			local sorter = self:GetSortFunction()

			if "function" == type( sorter ) then
				table.sort( self:GetItems(), sorter )
			end

			self:SetItemsDirty( false )
		end

		self:AnchorListItems()
		self:Refresh()
	end

	function base:Refresh( offset )
		offset = offset or self.Control.Slider:GetValue()

		local backdrops, listItems = self.ListItemBackdrops, self.ListItems
		local items = self:GetItems()
		local itemIndex = offset
		local itemsVisible = self:GetNumVisibleItems()
		local maxItemIndex = math.min( #items, offset + itemsVisible )

		for index = 1, #listItems do
			local backdrop = backdrops[index]
			local listItem = listItems[index]
			local item = items[itemIndex]

			if index <= itemsVisible and item then
				SetColor( backdrop, item.BackdropColor or base.Defaults.ColorListItemBackdrop )
				backdrop:SetHidden( false )

				listItem:SetText( item.Label )
				listItem:SetHidden( false )
				listItem.ItemIndex = itemIndex
				listItem.Item = item
				listItem.ToolTip = item.ToolTip

				itemIndex = itemIndex + 1
				if itemIndex > maxItemIndex then
					itemIndex = -1
				end
			else
				backdrop:SetHidden( true )

				listItem:SetText( "" )
				listItem:SetHidden( true )
				listItem.ItemIndex = nil
				listItem.Item = nil
				listItem.ToolTip = nil
			end
		end
	end

	function base:GetFontHeight()
		return self.ListItems[1]:GetFontHeight()
	end

	function base:GetItemLabelWidth( index )
		local item = self.ListItems[index]

		if not item then
			return 0
		end

		local text = item:GetText()

		if not text or "" == text then
			return 0
		end

		local newLineIndex = string.find( text, "\n" )

		if newLineIndex and 0 < newLineIndex then
			text = string.sub( text, 1, newLineIndex - 1 )
		end

		return item:GetStringWidth( text )
	end

	function base:GetItemHeight()
		return self.ItemHeight or 25
	end

	function base:SetItemHeight( value )
		self.ItemHeight = tonumber( value ) or 25
		local items = self.ListItems

		for _, item in ipairs( items ) do
			item:SetHeight( self.ItemHeight )
		end
	end

	function base:GetScrollRegionInsets()
		return 2 * base.Defaults.ScrollRegionInsets
	end

	function base:GetNumVisibleItems()
		local items = self:GetItems()

		if not items then
			return 0
		end

		local itemHeight = self:GetItemHeight()
		local spacing = self:GetItemSpacing()
		local height = self:GetHeight() - self:GetScrollRegionInsets()
		local count = math.floor( height / ( itemHeight + spacing ) )

		return zo_clamp( count, base.Defaults.VisibleItemsMin, math.min( #items, base.Defaults.VisibleItemsMax ) ) -- math.min( count, base.Defaults.VisibleItemsMax )
	end

	function base:ScrollTo( index )
		local items = self:GetItems()
		index = zo_clamp( tonumber( index ) or 0, 0, items and #items or 0 )

		self.Control.Slider:SetValue( index )
		self:Refresh()
	end

	function base:ScrollToTop()
		self:ScrollTo( 1 )
	end

	function base:OnItemMouseEnter( control )
		if control then
			local item = control.Item
			if item then
				local highlight = self.Control.ItemMouseEnter
				local _, _, anchor = highlight:GetAnchor( 1 )

				if control ~= anchor then
					highlight:ClearAnchors()
					highlight:SetAnchorFill( control )
					highlight:SetHidden( false )
				end

				if item.MouseEnterHandler then
					item.MouseEnterHandler( item, control.ItemIndex )
				end
			end
		end
	end

	function base:OnItemMouseExit( control )
		if control then
			local item = control.Item
			local highlight = self.Control.ItemMouseEnter
			local _, _, anchor = highlight:GetAnchor( 1 )

			if control == anchor then
				highlight:SetHidden( true )
				highlight:ClearAnchors()
			end

			if item and item.MouseExitHandler then
				item.MouseExitHandler( item, control.ItemIndex )
			end
		end
	end

	function base:OnItemDragStart()
		EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.List.OnItemDragStart" )
		EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.List.OnItemDragUpdate" )

		if not self:GetDragAndDropEnabled() then
			self.DragData = nil
			EHT.UI.DisplayNotification( self:GetDragAndDropDisabledMessage() or "Drag-and-drop is disabled." )
			return
		end

		local dragData = self.DragData
		if not dragData then
			return
		end

		local item, control = dragData.Item, dragData.Control
		local args = dragData.Args and unpack( dragData.Args ) or nil
		local mx, my = GetUIMousePosition()
		local dc = self.DragContainer

		dragData.IsDragging = true
		dc.Label:SetText( item.Label )
		dc:ClearAnchors()
		dc:SetAnchor( CENTER, GuiRoot, TOPLEFT, mx, my )
		dc:SetHidden( false )
		dc:StartMoving()

		EVENT_MANAGER:RegisterForUpdate( "EHT.UI.List.OnItemDragUpdate", 100, function() self:OnItemDragUpdate() end )
	end

	function base:OnItemDragUpdate()
		local dragData = self.DragData
		if not dragData then
			return
		end

		local item, control = dragData.Item, dragData.Control
		local mx, my = GetUIMousePosition()
		local _, y1, _, y2 = self.Control.Box:GetScreenRect()
		local offset = self.Control.Slider:GetValue()
		local newOffset

		if my < y1 then
			newOffset = offset - 1
		elseif my > y2 then
			newOffset = offset + 1
		end

		if newOffset then
			newOffset = zo_clamp( newOffset, 1, #self:GetItems() )

			if newOffset ~= offset then
				self.Control.Slider:SetValue( newOffset )
			end
		end
	end

	function base:OnItemMouseUp()
		EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.List.OnItemDragStart" )
		EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.List.OnItemDragUpdate" )

		local dragData = self.DragData
		if not dragData then
			return
		end

		local item, control = dragData.Item, dragData.Control
		local args = dragData.Args and unpack( dragData.Args ) or nil

		if item then
			if not dragData.IsDragging then
				if item.ClickHandler then
					item.ClickHandler( item, control.ItemIndex, args )
				elseif item.MouseDownHandler then
					item.MouseDownHandler( item, control.ItemIndex, args )
				end
			else
				local items = self:GetItems()
				local numItems = #items
				local dc = self.DragContainer
				local _, dcy = dc:GetCenter()

				dc:StopMovingOrResizing()
				dc:SetHidden( true )

				local box = self.Control.Box
				local _, by1, _, by2 = box:GetScreenRect()
				local margin = math.floor( self:GetScrollRegionInsets() * 0.5 )
				local itemHeight = self:GetItemHeight() + self:GetItemSpacing()
				local baseIndex = self.Control.Slider:GetValue()
				local offset = dcy - ( by1 + margin )
				local itemOffset = math.floor( offset / itemHeight )
				local targetIndex = baseIndex + itemOffset
				local sourceIndex = item.Index

				sourceIndex, targetIndex = zo_clamp( sourceIndex, 1, numItems ), zo_clamp( targetIndex, 1, numItems )
				EHT.UI.OnSelectedItemDragAndDrop( sourceIndex, targetIndex )
			end
		end
	end

	function base:OnItemMouseDown( control, ... )
		EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.List.OnItemDragStart" )
		EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.List.OnItemDragUpdate" )

		if control then
			local dragData = self.DragData
			if not dragData then
				dragData = { }
				self.DragData = dragData
			end

			dragData.IsDragging = false
			dragData.Control = control
			dragData.Item = control.Item
			dragData.StartTime = GetGameTimeMilliseconds()
			dragData.Args = {...}

			EVENT_MANAGER:RegisterForUpdate( "EHT.UI.List.OnItemDragStart", 260, function() self:OnItemDragStart() end )
		end
	end

	function base:OnShowItemTooltip( control )
		local msg = control.ToolTip or control:GetText()

		if control:GetWidth() < control:GetStringWidth( msg ) then
			local screenX = GuiRoot:GetCenter()
			local controlX = control:GetCenter()
			local anchorTooltip, anchorControl, anchorOffsetX

			if controlX <= screenX then
				anchorTooltip, anchorControl, anchorOffsetX = LEFT, RIGHT, 25
			else
				anchorTooltip, anchorControl, anchorOffsetX = RIGHT, LEFT, -25
			end

			EHT.UI.ShowTooltip( nil, control, EHT.Util.Trim( msg ), anchorTooltip, anchorOffsetX, 0, anchorControl )
		end
	end

	function base:RefreshEnabled()
		self.Control:SetMouseEnabled( self.Enabled )
		SetColor( self.Control.Box, base.Defaults.ColorBox, ( not self.Enabled ) and base.Defaults.ColorFilterDisabled )
		SetColor( self.Control.Label, base.Defaults.ColorLabel, ( not self.Enabled ) and base.Defaults.ColorFilterDisabled )
	end

	function base:SetEnabled( value )
		self.Enabled = true == value
		self:RefreshEnabled()
	end

	function base:GetDragAndDropDisabledMessage()
		return self.DragAndDropDisabledMessage
	end

	function base:SetDragAndDropDisabledMessage( value )
		self.DragAndDropDisabledMessage = value
	end

	function base:GetDragAndDropEnabled()
		return true == self.DragAndDropEnabled
	end

	function base:SetDragAndDropEnabled( value )
		self.DragAndDropEnabled = true == value
		self:Refresh()
	end

	function base:GetEventBehavior( value )
		return self.EventBehavior
	end

	function base:SetEventBehavior( value )
		if EHT.Util.IsListValue( base.EventBehaviors, value ) then
			self.EventBehavior = value
		end
	end

	function base:GetName()
		return self.Name
	end

	function base:GetParent()
		--return self.Parent
		return self.Control:GetParent()
	end

	function base:SetParent( parent )
		--self.Parent = parent
		self.Control:SetParent( parent )
	end

	function base:GetControl()
		return self.Control
	end

	function base:GetDrawLevel()
		return self.Control:GetDrawLevel()
	end

	function base:SetDrawLevel( value )
		self.Control:SetDrawLevel( value )
	end

	function base:GetWidth()
		return self.Control:GetWidth()
	end

	function base:SetWidth( value )
		self.Width = zo_clamp( tonumber( value ) or base.Defaults.Width, base.Defaults.WidthMin, base.Defaults.WidthMax )
		self.Control:SetWidth( self.Width )
		return self.Width
	end

	function base:GetHeight()
		return self.Control:GetHeight()
	end

	function base:SetHeight( value )
		self.Height = zo_clamp( tonumber( value ) or base.Defaults.Height, base.Defaults.HeightMin, base.Defaults.HeightMax )
		self.Control:SetHeight( self.Height )
		return self.Height
	end

	function base:GetDimensions()
		return self.Control:GetDimensions()
	end

	function base:SetDimensions( width, height )
		self:SetWidth( width )
		self:SetHeight( height )
	end

	function base:GetCenter()
		return self.Control:GetCenter()
	end

	function base:GetScreenRect()
		return self.Control:GetScreenRect()
	end

	function base:SetItemHorizontalAlignment( value )
		for _, item in ipairs( self.ListItems ) do
			item:SetHorizontalAlignment( value )
		end
	end

	function base:SetItemVerticalAlignment( value )
		for _, item in ipairs( self.ListItems ) do
			item:SetVerticalAlignment( value )
		end
	end

	function base:SetItemFont( value )
		for _, item in ipairs( self.ListItems ) do
			item:SetFont( value )
		end
	end

	function base:GetItemSpacing()
		return self.ItemSpacing or base.Defaults.SpacingItems
	end

	function base:SetItemSpacing( value )
		local spacing = tonumber( value ) or self.ItemSpacing or base.Defaults.SpacingItems
		self.ItemSpacing = spacing
		self:AnchorListItems()
	end

	function base:AnchorListItems()
		local backdrops, items = self.ListItemBackdrops, self.ListItems
		local spacing = self:GetItemSpacing()
		local previousItem
		local maxIndex = #items

		for index = 1, maxIndex do
			local backdrop, item = backdrops[index], items[index]

			backdrop:ClearAnchors()
			item:ClearAnchors()

			if not previousItem then
				item:SetAnchor( TOPLEFT, self.Control.ListBox, TOPLEFT, 1, 0 )
				item:SetAnchor( TOPRIGHT, self.Control.ListBox, TOPRIGHT, -1, 0 )
			else
				item:SetAnchor( TOPLEFT, previousItem, BOTTOMLEFT, 0, spacing )
				item:SetAnchor( TOPRIGHT, previousItem, BOTTOMRIGHT, 0, spacing )
			end

			backdrop:SetAnchor( TOPLEFT, item, TOPLEFT, 0, 0 )
			backdrop:SetAnchor( BOTTOMRIGHT, item, BOTTOMRIGHT, 0, 0 )

			previousItem = item
		end
	end

	function base:GetItemLines()
		return self.ItemLines or 1
	end

	function base:SetItemLines( value )
		value = zo_clamp( tonumber( value ) or 1, 1, 10 )
		self.ItemLines = value

		local lineHeight = value * self:GetFontHeight()
		local items = self.ListItems

		for index = 1, #items do
			local item = items[index]
			item:SetMaxLineCount( value )
			item:SetHeight( lineHeight )
		end

		self:Refresh()
	end

	function base:GetItemsDirty()
		return self.ItemsDirty
	end

	function base:SetItemsDirty( value )
		self.ItemsDirty = true == value
	end

	function base:GetSorted()
		return self.Sorted
	end

	function base:SetSorted( value )
		self.Sorted = true == value
		self.ItemsDirty = true
	end

	function base:GetSortFunction()
		return self.SortFunction
	end

	function base:SetSortFunction( func )
		self.ItemsDirty = true
		self.SortFunction = "function" == type( func ) and func or nil

		if self.SortFunction then
			self.Sorted = true
		else
			self.SortFunction = base.DefaultSortFunction
		end
	end

	function base:GetHandlers( event )
		if not event then
			return nil
		end

		event = string.lower( event )

		if not self.Handlers then
			self.Handlers = { }
		end

		local handlers = self.Handlers[event]

		if not handlers then
			handlers = { }
			self.Handlers[event] = handlers
		end

		return handlers
	end

	function base:AddHandler( event, handler )
		local handlers = self:GetHandlers( event )

		if handlers then
			handlers[handler] = true
			return handler
		end

		return nil
	end

	function base:RemoveHandler( event, handler )
		local handlers = self:GetHandlers( event )

		if handlers and handlers[handler] then
			handlers[handler] = nil
			return handler
		end

		return nil
	end

	function base:CallHandlers( event, ... )
		local handlers = self:GetHandlers( event )

		if handlers then
			for handler in pairs( handlers ) do
				handler( self, ... )
			end
		end
	end

	function base:IsHidden()
		return self.Control:IsHidden()
	end

	function base:SetHidden( value )
		self.Control:SetHidden( value )
	end

	function base:ClearAnchors()
		self.Control:ClearAnchors()
		self:OnResized()
	end

	function base:SetAnchor( anchorFrom, anchor, anchorTo, anchorOffsetX, anchorOffsetY )
		if anchorFrom or anchor or anchorTo then
			self.Control:SetAnchor( anchorFrom, anchor, anchorTo, anchorOffsetX, anchorOffsetY )
		end
	end

	function base:GetItems()
		return self.Items
	end

	function base:GetItemByIndex( index )
		return self.Items[index]
	end

	function base:FindItemIndex( item )
		local matchedIndex = nil

		if "number" == type( item ) then
			for index, itemObj in ipairs( self.Items ) do
				if item == itemObj.Value then
					matchedIndex = index
					break
				end
			end
		elseif "string" == type( item ) then
			local lowerValue = string.lower( EHT.Util.Trim( item ) )

			for index, itemObj in ipairs( self.Items ) do
				if lowerValue == string.lower( EHT.Util.Trim( itemObj.Label ) ) then
					matchedIndex = index
					break
				end
			end
		elseif "table" == type( item ) then
			for index, itemObj in ipairs( self.Items ) do
				if item.Label == itemObj.Label and item.Value == itemObj.Value then
					matchedIndex = index
					break
				end
			end
		end

		return matchedIndex
	end

	function base:FindItem( item )
		return self.Items[self:FindItemIndex( item )]
	end

	function base:ClearItems()
		if not self.Items then
			self.Items = { }
		else
			for index = #self.Items, 1, -1 do
				table.remove( self.Items, index )
			end
		end

		self.SelectedItem = nil
		self.ItemsDirty = true
		self:Refresh()
	end

	function base:SetItems( items )
		if "table" == type( items ) then
			self.Items = items
		else
			self:ClearItems()
		end

		self.ItemsDirty = true
		return self:GetItems()
	end

	function base:AddItem( label, value, clickHandler, mouseEnterHandler, mouseExitHandler )
		local item = nil
		if label then
			item = { Label = label, Value = value, ClickHandler = clickHandler, MouseEnterHandler = mouseEnterHandler, MouseExitHandler = mouseExitHandler }
			table.insert( self.Items, item )
		end

		self.ItemsDirty = true
		return item
	end

	function base:InsertItem( index, label, value, clickHandler, mouseEnterHandler, mouseExitHandler )
		local item = nil
		if label then
			item = { Label = label, Value = value, ClickHandler = clickHandler, MouseEnterHandler = mouseEnterHandler, MouseExitHandler = mouseExitHandler }
			table.insert( self.Items, index, item )
		end

		self.ItemsDirty = true
		return item
	end

end

---[ Operations : UI Extensions ]---

local function PlayUISound( sound )
	PlaySound( sound )
end

function EHT.UI.GetCurrentSceneName()
	local scene = SCENE_MANAGER:GetCurrentScene()
	if scene then return scene:GetName() end
	return ""
end

function EHT.UI.IsHUDSceneShowing()
	local sceneName = EHT.UI.GetCurrentSceneName()
	return "hud" == sceneName or "hudui" == sceneName
end

function EHT.UI.SetupUIExtensions()
	local prefix = "EHTUIExt"
	local uiExt = { }
	local tip = EHT.UI.SetInfoTooltip
	local c

	EHT.UI.UIExt = uiExt

	do
		local target = ZO_HousingFurniturePlacementPanel_KeyboardTopLevelContentsList
		if target then
			c = EHT.CreateControl( prefix .. "FurniturePlacementInstructions", target, CT_LABEL )
			uiExt.FurniturePlacementInstructions = c
			c:SetFont( "$(BOLD_FONT)|$(KB_15)|soft-shadow-thin" )
			c:SetColor( 1, 1, 1, 1 )
			c:SetAnchor( TOPRIGHT, target, BOTTOMRIGHT, 0, 5 )
			c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
			c:SetText( "Right-click an item to place it immediately." )
		end
	end

	do
		local target = ZO_HousingFurnitureRetrievalPanel_KeyboardTopLevelContentsList
		if target then
			c = EHT.CreateControl( prefix .. "FurnitureRetrievalInstructions", target, CT_LABEL )
			uiExt.FurnitureRetrievalInstructions = c
			c:SetFont( "$(BOLD_FONT)|$(KB_15)|soft-shadow-thin" )
			c:SetColor( 1, 1, 1, 1 )
			c:SetAnchor( TOPRIGHT, target, BOTTOMRIGHT, 0, 5 )
			c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
			c:SetText( "Right-click an item to put it away immediately." )
		end
	end
end

---[ Email ]---

function EHT.UI.ShowNewEmail( to, subject, attachGold )
	SCENE_MANAGER:Show( "mailSend" )

	zo_callLater( function()
		ZO_MailSendToField:SetText( to )

		if subject then
			ZO_MailSendSubjectField:SetText( subject )
		else
			ZO_MailSendSubjectField:SetText( "" )
		end

		if attachGold then
			QueueMoneyAttachment( attachGold )
		end

		ZO_MailSendBodyField:TakeFocus()
	end, 500 )
end

---[ Operations : UI Keybind Functions ]---

function EHT.UI.RefreshEditToggles()
	local ui = EHT.UI.EHTButtonContextMenu
	if nil == ui then return end

	local CHECKED = "esoui/art/buttons/gamepad/gp_checkbox_downover.dds"
	local UNCHECKED = "esoui/art/buttons/gamepad/gp_checkbox_upover.dds"
	local enabled, horizontal, vertical, rotation

	horizontal, vertical = EHT.Biz.AreGuidelinesEnabled()
	ui.GridHorizontal:SetTexture( horizontal and CHECKED or UNCHECKED )
	ui.GridVertical:SetTexture( vertical and CHECKED or UNCHECKED )

	if not horizontal then vertical = false end

	if horizontal then
		ui.GridVertical.OldR, ui.GridVertical.OldG, ui.GridVertical.OldB, ui.GridVertical.OldA = 1, 1, 1, 1
	else
		ui.GridVertical.OldR, ui.GridVertical.OldG, ui.GridVertical.OldB, ui.GridVertical.OldA =  0.4, 0.4, 0.4, 1
	end
	ui.GridVertical:SetColor( ui.GridVertical.OldR, ui.GridVertical.OldG, ui.GridVertical.OldB, ui.GridVertical.OldA )

	if horizontal then
		ui.GridLock.OldR, ui.GridLock.OldG, ui.GridLock.OldB, ui.GridLock.OldA = 1, 1, 1, 1
	else
		ui.GridLock.OldR, ui.GridLock.OldG, ui.GridLock.OldB, ui.GridLock.OldA = 0.4, 0.4, 0.4, 1
	end
	ui.GridLock:SetColor( ui.GridLock.OldR, ui.GridLock.OldG, ui.GridLock.OldB, ui.GridLock.OldA )

	if horizontal then
		ui.GridSnapHorizontal.OldR, ui.GridSnapHorizontal.OldG, ui.GridSnapHorizontal.OldB, ui.GridSnapHorizontal.OldA = 1, 1, 1, 1
	else
		ui.GridSnapHorizontal.OldR, ui.GridSnapHorizontal.OldG, ui.GridSnapHorizontal.OldB, ui.GridSnapHorizontal.OldA = 0.4, 0.4, 0.4, 1
	end
	ui.GridSnapHorizontal:SetColor( ui.GridSnapHorizontal.OldR, ui.GridSnapHorizontal.OldG, ui.GridSnapHorizontal.OldB, ui.GridSnapHorizontal.OldA )

	if vertical then
		ui.GridSnapVertical.OldR, ui.GridSnapVertical.OldG, ui.GridSnapVertical.OldB, ui.GridSnapVertical.OldA = 1, 1, 1, 1
	else
		ui.GridSnapVertical.OldR, ui.GridSnapVertical.OldG, ui.GridSnapVertical.OldB, ui.GridSnapVertical.OldA = 0.4, 0.4, 0.4, 1
	end
	ui.GridSnapVertical:SetColor( ui.GridSnapVertical.OldR, ui.GridSnapVertical.OldG, ui.GridSnapVertical.OldB, ui.GridSnapVertical.OldA )

	if horizontal or vertical then
		ui.GridSnapRotation.OldR, ui.GridSnapRotation.OldG, ui.GridSnapRotation.OldB, ui.GridSnapRotation.OldA = 1, 1, 1, 1
	else
		ui.GridSnapRotation.OldR, ui.GridSnapRotation.OldG, ui.GridSnapRotation.OldB, ui.GridSnapRotation.OldA = 0.4, 0.4, 0.4, 1
	end
	ui.GridSnapRotation:SetColor( ui.GridSnapRotation.OldR, ui.GridSnapRotation.OldG, ui.GridSnapRotation.OldB, ui.GridSnapRotation.OldA )

	horizontal, vertical, rotation = EHT.Biz.AreGuidelinesSnapped()
	ui.GridSnapHorizontal:SetTexture( horizontal and CHECKED or UNCHECKED )
	ui.GridSnapVertical:SetTexture( vertical and CHECKED or UNCHECKED )
	ui.GridSnapRotation:SetTexture( rotation and CHECKED or UNCHECKED )

	enabled = EHT.Biz.AreGuidelinesLocked()
	ui.GridLock:SetTexture( enabled and CHECKED or UNCHECKED )

	enabled = EHT.Biz.IsSelectionBoxEnabled()
	ui.SelectBox:SetTexture( enabled and CHECKED or UNCHECKED )

	enabled = EHT.Biz.AreSelectionIndicatorsEnabled()
	ui.SelectCheck:SetTexture( enabled and CHECKED or UNCHECKED )

	enabled = not EHT.EffectUI.AreEditButtonsHidden()
	ui.SelectEffect:SetTexture( enabled and CHECKED or UNCHECKED )

	enabled = EHT.UI.IsNightModeEnabled()
	ui.NightMode:SetTexture( enabled and CHECKED or UNCHECKED )

	-- enabled = EHT.GetSetting( "EnableEasySlide" )
	-- ui.EasySlide:SetTexture( enabled and CHECKED or UNCHECKED )
end

function EHT.UI.ToggleGuidelinesHorizontal()
	EHT.Biz.ToggleGuidelines( true, false )
	EHT.UI.RefreshEditToggles()
end

function EHT.UI.ToggleGuidelinesVertical()
	EHT.Biz.ToggleGuidelines( false, true )
	EHT.UI.RefreshEditToggles()
end

function EHT.UI.ToggleGuidelinesSnapHorizontal()
	EHT.Biz.ToggleGuidelinesSnapHorizontal()
	EHT.UI.RefreshEditToggles()
end

function EHT.UI.ToggleGuidelinesSnapVertical()
	EHT.Biz.ToggleGuidelinesSnapVertical()
	EHT.UI.RefreshEditToggles()
end

function EHT.UI.ToggleGuidelinesSnapRotation()
	EHT.Biz.ToggleGuidelinesSnapRotation()
	EHT.UI.RefreshEditToggles()
end

function EHT.UI.ToggleGuidelinesLock()
	EHT.Biz.ToggleGuidelinesLock()
	EHT.UI.RefreshEditToggles()
end

function EHT.UI.ToggleSelectionBox()
	EHT.Pointers.SetGroupOutlineHidden( EHT.Biz.ToggleSelectionBox() )
	EHT.UI.RefreshEditToggles()
	EHT.Biz.SetGuidelinesSettingsChanged()
end

function EHT.UI.ToggleSelectionIndicators()
	EHT.Pointers.SetGroupedHidden( EHT.Biz.ToggleSelectionIndicators() )
	EHT.UI.RefreshEditToggles()
	EHT.Biz.SetGuidelinesSettingsChanged()
end

function EHT.UI.ToggleSelectionPaintBuckets()
	EHT.EffectUI.ShowHideEditButtons()
	EHT.UI.RefreshEditToggles()
end
--[[
function EHT.UI.ToggleEasySlide()
	EHT.SavedVars.EnableEasySlide = not EHT.GetSetting( "EnableEasySlide" )
	EHT.UI.RefreshEditToggles()
end
]]
function EHT.UI.ToggleMoveSpeed( offset )
	local precision = EHT.SavedVars.SelectionPrecision

	if nil == offset then
		precision = precision + 1
		if precision > 6 then precision = 1 end
	elseif 0 < offset and 6 > precision then
		precision = precision + 1
	elseif 0 > offset and 1 < precision then
		precision = precision - 1
	end

	EHT.SavedVars.SelectionPrecision = precision

	local ui = EHT.UI.ToolDialog
	if nil ~= ui then
		if EHT.SavedVars.SelectionPrecisionUseCustom then
			ZO_CheckButton_SetCheckState( ui.CustomPrecisionToggle, false )	
			EHT.SavedVars.SelectionPrecisionUseCustom = false
		end

		ui.Precision:SetValue( precision )
		EHT.UI.SetPrecisionInfoTooltip( true )
		ui.Precision:SetEnabled( true )
	end
end

function EHT.UI.MoveSelection( direction )
	if nil == direction then return false end
	direction = string.lower( string.trim( direction ) )

	local relativeMode = ( EHT.SavedVars.EditMode or EHT.CONST.EDIT_MODE.RELATIVE ) == EHT.CONST.EDIT_MODE.RELATIVE
	local editFunction = EHT.Biz.AdjustSelectedOrPositionedFurniture
	local msg

	if "forward" == direction then
		if relativeMode then
			editFunction( { Forward = 1 } )
			msg = "Move Forward"
		else
			editFunction( { Z = -1 } )
			msg = "Move North"
		end
	elseif "backward" == direction then
		if relativeMode then
			editFunction( { Forward = -1 } )
			msg = "Move Backward"
		else
			editFunction( { Z = 1 } )
			msg = "Move South"
		end
	elseif "left" == direction then
		if relativeMode then
			editFunction( { Left = 1 } )
			msg = "Move Left"
		else
			editFunction( { X = -1 } )
			msg = "Move West"
		end
	elseif "right" == direction then
		if relativeMode then
			editFunction( { Left = -1 } )
			msg = "Move Right"
		else
			editFunction( { X = 1 } )
			msg = "Move East"
		end
	elseif "up" == direction then
		editFunction( { Y = 1 } )
		msg = "Move Up"
	elseif "down" == direction then
		editFunction( { Y = -1 } )
		msg = "Move Down"
	elseif "rotatecw" == direction then
		editFunction( { Yaw = -1 } )
		msg = "Rotate Clockwise"
	elseif "rotateccw" == direction then
		editFunction( { Yaw = 1 } )
		msg = "Rotate Counterclockwise"
	else
		return false
	end

	if msg and EHT.GetSetting( "ShowSelectionInOSD" ) then
		EHT.UI.DisplayNotification( msg )
	end

	return true
end

function EHT.UI.JumpToHome()
	return EHT.Biz.SlashCommandHome()
end

function EHT.UI.JumpToFavoriteHouse( index )
	return EHT.Biz.SlashCommandHouse( tostring( index ) )
end

function EHT.UI.SaveFrame()
	if not EHT.UI.CanEditAnimation() then
		d( "Cannot edit Scene right now." )
		return
	end

	EHT.Biz.UpdateSceneFrame()
	df( "Scene frame saved." )
	EHT.UI.PlaySoundConfirm()
end

function EHT.UI.SaveFrameAndInsert()
	if not EHT.UI.CanEditAnimation() then
		d( "Cannot edit Scene right now." )
		return
	end

	if nil ~= EHT.Biz.InsertSceneFrame( nil, false ) then
		df( "Scene frame saved. New frame inserted." )
		EHT.UI.PlaySoundConfirm()
	end
end


function EHT.UI.ParseGroupIndexFromLink( link )

	local pos1, pos2

	if nil == link or "" == link then return nil end

	local _, group = EHT.Data.GetCurrentHouse()
	if nil == group then return nil end

	local pos1 = string.find( link, "|h" )
	if nil == pos1 then return nil end
	pos1 = pos1 + 2

	local pos2 = string.find( link, "[.]", pos1 )
	if nil == pos2 then return nil end
	pos2 = pos2 - 1

	local index = tonumber( string.sub( link, pos1, pos2 ) )
	if nil == index or 1 > index or index > #group then return nil end

	return index, group

end


function EHT.UI.SnapFurniture( id, x, y, z, pitch, yaw, roll )

	if EHT.Biz.IsProcessRunning() then return false end

	if nil == id then
		local effect, _, effectDistance = EHT.World:GetReticleTargetEffect()

		if HousingEditorCanSelectTargettedFurniture() then
			EHT.Interop.SuspendFurnitureSnap()

			EHT.SnapFurnitureInitiating = true

			LockCameraRotation( true )
			HousingEditorSelectTargettedFurniture()
			id = HousingEditorGetSelectedFurnitureId()
			HousingEditorRequestModeChange( HOUSING_EDITOR_MODE_DISABLED )
			LockCameraRotation( false )

			EHT.Interop.ResumeFurnitureSnap()
		end

		if effect and not id then
			id = effect:GetRecordId()
		elseif effect and id then
			local x, y, z = EHT.Housing.GetFurniturePosition( id )
			local pX, pY, pZ = EHT.World:GetPlayerPosition()
			if effectDistance < zo_distance3D( x, y, z, pX, pY, pZ ) then
				id = effect:GetRecordId()
			end
		end

		if nil == id then
			EHT.SnapFurnitureInitiating = false
			EHT.UI.PlaySoundFailure()

			d( "No furniture targeted." )
			return false
		end
	end

	EHT.Biz.ResetSnapFurniture()

	local ui = EHT.UI.SetupSnapFurnitureDialog()
	ui.Window:SetHidden( true )

	if not EHT.SnapFurnitureItem then EHT.SnapFurnitureItem = { } end
	local sfi = EHT.SnapFurnitureItem

	local itemLink = EHT.Housing.GetFurnitureLink( id )
	local itemName = EHT.Housing.GetFurnitureLinkName( itemLink )
	local itemIcon = GetItemLinkIcon( itemLink )
	local collectibleId = GetCollectibleIdFromLink( itemLink )

	if nil ~= collectibleId and 0 ~= collectibleId then
		local collectibleName, _, collectibleIcon = GetCollectibleInfo( collectibleId )
		itemLink = collectibleLink
		itemName = collectibleName
		itemIcon = collectibleIcon
	end

	if nil ~= itemIcon and "" ~= itemIcon then
		itemIcon = zo_iconFormat( itemIcon )
	else
		itemIcon = nil
	end

	if not x or not y or not z then
		x, y, z = EHT.Housing.GetFurniturePosition( id )
		x, y, z = math.floor( x ), math.floor( y ), math.floor( z )
	end

	if not pitch or not yaw or not roll then
		pitch, yaw, roll = EHT.Housing.GetFurnitureOrientation( id )
	end

	if 0 == x and 0 == y and 0 == z then
		EHT.UI.HideSnapFurnitureDialog()
		return
	end

	sfi.Id, sfi.Icon, sfi.Name, sfi.Link = id, itemIcon, itemName, itemLink
	sfi.X, sfi.Y, sfi.Z, sfi.Pitch, sfi.Yaw, sfi.Roll = x, y, z, pitch, yaw, roll
	sfi.AdjacentItemIndex = 0
	sfi.ItemLabel = "Snap " .. ( nil ~= itemIcon and itemIcon or "Item" )

	local items = EHT.Housing.FindAdjacentFurniture( sfi.Id, EHT.SavedVars.SnapFurnitureRadius, false, false )
	local adjItems = { }

	for index, adjId in ipairs( items ) do
		table.insert( adjItems, EHT.Data.CreateFurniture( adjId ) )
	end

	sfi.AdjacentItems = adjItems

	if 1 >= #sfi.AdjacentItems then
		EHT.UI.DisplayNotification( "No items are close enough to snap to." )
		EHT.UI.HideSnapFurnitureDialog()
		EHT.UI.PlaySoundFailure()

		return
	end

	if 2 >= #sfi.AdjacentItems then
		ui.SnapItemGroup:SetHidden( true )
		ui.OrientationGroup:ClearAnchors()
		ui.OrientationGroup:SetAnchor( BOTTOM, ui.Window, BOTTOM, 0, -5 )
	else
		ui.SnapItemGroup:SetHidden( false )
		ui.OrientationGroup:ClearAnchors()
		ui.OrientationGroup:SetAnchor( BOTTOM, ui.Window, BOTTOM, 60, -5 )
	end
	ui.ItemLabel:SetText( sfi.ItemLabel )

	EHT.Biz.InitSnapFurniture()

end


function EHT.UI.GroupUngroupFurniture()

	local result = EHT.Biz.GroupUngroupFurniture()
	EHT.UI.UpdateKeybindStrip()
	return result

end


function EHT.UI.UngroupAllFurniture()

	local result = EHT.Biz.ResetSelection()
	EHT.UI.UpdateKeybindStrip()
	return result

end


function EHT.UI.Undo() return EHT.CT.Undo() end


function EHT.UI.Redo() return EHT.CT.Redo() end


function EHT.UI.PointToFurniture( link )

	local index, group = EHT.UI.ParseGroupIndexFromLink( link )
	if nil == index or nil == group then return false end

	local item = group[ index ]
	if nil == item then return false end

	local x, y, z = EHT.Housing.GetFurnitureCenter( item.Id )
	if nil ~= x and 0 ~= x then
		EHT.Pointers.SetSelected( x, y, z, 2, 1, 1, 1 )
	end

	return true

end


function EHT.UI.UngroupFurniture( link )

	local index, group = EHT.UI.ParseGroupIndexFromLink( link )
	if nil == index or nil == group then return false end

	if EHT.SavedVars.ShowSelectionInChat then df( "Removed '%s' from selection.", link ) end

	local item = table.remove( group, index )
	EHT.UI.RefreshSelection()
	EHT.Handlers.OnFurnitureUnselected( item )

	return true

end

function EHT.UI.RemoveClipboardFurniture( link )
	if nil == link or "" == link then return false end

	local group = EHT.SavedVars.Clipboard
	if nil == group then return false end

	local pos1 = string.find( link, "|h" )
	if nil == pos1 then return false end
	pos1 = pos1 + 2

	local pos2 = string.find( link, "[.]", pos1 )
	if nil == pos2 then return false end
	pos2 = pos2 - 1

	local index = tonumber( string.sub( link, pos1, pos2 ) )
	if nil == index or 1 > index or index > #group then return false end

	if EHT.SavedVars.ShowSelectionInChat then df( "Removed '%s' from clipboard.", link ) end

	table.remove( group, index )
	EHT.UI.RefreshClipboard()

	return true
end

function EHT.UI.PublishFX( houseId, confirm )
	if not confirm then
		EHT.UI.ShowConfirmationDialog( "",
			"Do you want to publish this home's effects to the Community, allowing all Community members to see this home's effects (as these effects exist right now) when visiting this home?",
			function()
				EHT.UI.PublishFX( houseId, true )
			end )
		return
	end

	local success = EHT.Effect:PublishFX( houseId )

	if success then
		if not houseId then
			houseId = EHT.Housing.GetHouseId()
		end

		local SEND_NOW = "|c00ffffReload UI now to publish your changes immediately?"

		if not EssentialHousingHub:IsOpenHouse( houseId ) then
			local nickname = EHT.Housing.GetHouseNickname( houseId )

			EHT.UI.ShowConfirmationDialog( "",
				string.format( "|cffffffWould you also like to also register your \"|c00ffff%s|cffffff\" as an |c88ffffOpen House for the Community|cffffff?", nickname ),

				function()
					EssentialHousingHub:ToggleOpenHouse( houseId )
					EHT.UI.ShowConfirmationDialog( "", "|cffffffYour home |c00ff00will|cffffff also be registered as an Open House.\n\n" .. SEND_NOW, EHCommunity_DoubleReloadUI and EHCommunity_DoubleReloadUI or ReloadUI )
				end,

				function()
					EHT.UI.ShowConfirmationDialog( "", "|cffffffYour home |cff0000will not|cffffff be registered as an Open House.\n\n" .. SEND_NOW, EHCommunity_DoubleReloadUI and EHCommunity_DoubleReloadUI or ReloadUI )
				end
			)
		else
			EHT.UI.ShowConfirmationDialog( "", SEND_NOW, EHCommunity_DoubleReloadUI and EHCommunity_DoubleReloadUI or ReloadUI )
		end
	end
end

function EHT.UI.UnpublishFX( houseId, confirm )
	if not confirm then
		EHT.UI.ShowConfirmationDialog( "",
			"Do you want to unpublish this home's effects from the Community?\n\n" ..
			"Note that Community members will no longer be able to see your effects unless you share them using another method, such as Chat, Mail or Guild.",
			function()
				EHT.UI.UnpublishFX( houseId, true )
			end )
		return
	end

	local success = EHT.Effect:UnpublishFX( houseId )

	if success then
		if not houseId then
			houseId = EHT.Housing.GetHouseId()
		end

		local FX_UNPUBLISHED = "|cffffff" ..
			"Your FX data will be unpublished once you reload the UI or log out.\n\n"

		local SEND_NOW = "|c00ffff" ..
			"Reload UI now to unpublish your changes immediately?"

		EHT.UI.ShowConfirmationDialog( "", FX_UNPUBLISHED .. SEND_NOW, EHCommunity_DoubleReloadUI and EHCommunity_DoubleReloadUI or ReloadUI )
	end
end

function EHT.UI.RefreshEffectsPreviewState()
	local ui = EHT.UI.EHTEffectsButtonContextMenu

	if not ui or not ui.PublishedControls or not ui.SharingControls then
		return
	end

	if EHT.PreviewEffectHouseId then
		ui.PublishedPreviewInstructions:SetText( string.format( "|cffffff" ..
			"You are currently previewing the version of your effects that was last shared or published " ..
			"|cffff00%s|cffffff.\n\n" ..
			"While previewing, you may optionally choose to replace your effects with this published version of your effects.\n\n" ..
			"Note that if you choose to replace your effects, you may undo those changes with " ..
			"|c00ffffEHT button |cffffff|||c00ffff Undo|cffffff",
			( not EHT.PreviewEffectTS or 0 == EHT.PreviewEffectTS ) and "Some time" or EHT.Util.GetRelativeTimeString( EHT.PreviewEffectTS, GetTimeStamp(), 2 ) ) )

		ui.PublishedControls:SetHidden( false )
		ui.SharingControls:SetHidden( true )
		EHT.UI.ShowEffectsPreviewDialog()
	else
		ui.PublishedControls:SetHidden( true )
		ui.SharingControls:SetHidden( false )
		EHT.UI.HideEffectsPreviewDialog()
	end
end

function EHT.UI.PreviewPublishedFX()
	if EHT.PreviewEffectHouseId then
		return EHT.UI.CancelPreviewFX()
	end

	local effects = EssentialHousingHub:GetCommunityHouseFXRecord( GetDisplayName(), EHT.Util.GetWorldCode(), EHT.Housing.GetHouseId() )

	if not effects or not effects.Effects then
		local message = "You have not published a copy of this home's effects to the Community."
		EHT.UI.ShowAlertDialog( "", message )

		return false, message
	end

	local result, message = EHT.EffectUI.PreviewEffects( effects.Effects, effects.TS )

	if not result then
		message = string.format( "Cannot preview published effects:\n%s", message or "Unknown error" )
		EHT.UI.ShowAlertDialog( "", message )
	end

	EHT.UI.RefreshEffectsPreviewState()
	EHT.UI.DisplayNotification(
		string.format( "Previewing your effects published to Community %s", EHT.Util.GetRelativeTimeString( EHT.PreviewEffectTS, GetTimeStamp(), 2 ) ),
		5000 )

	return result, message
end

function EHT.UI.CancelPreviewFX()
	local result = EHT.EffectUI.CancelPreviewEffects()

	if not result then
		local message = string.format( "Failed to cancel effects preview." )
		EHT.UI.ShowAlertDialog( "", message )
	end

	EHT.UI.RefreshEffectsPreviewState()
	EHT.UI.DisplayNotification( "Effects preview ended" )

	return result, message
end

function EHT.UI.AcceptPreviewFX()
	local result = EHT.EffectUI.AcceptPreviewEffects()

	if not result then
		local message = string.format( "Failed to accept preview effects." )
		EHT.UI.ShowAlertDialog( "", message )
	end

	EHT.UI.RefreshEffectsPreviewState()
	EHT.UI.DisplayNotification(
		"Your effects have been replaced with the published version\n" ..
		"You may undo this change with |c00ffffEHT button |cffffff|||c00ffff Undo",
		8000 )

	return result, message
end

---[ Operations : UI Functions  ]---

function EHT.UI.OnHousePopulationChanged( population )
	local previousPopulation = EHT.CurrentHousePopulation or 0
	EHT.CurrentHousePopulation = population

	if 0 == population or not EHT.Housing.IsHouseZone() then
		return
	end

	EHT.UI.SetToolDialogWindowTitle()
end

function EHT.UI.SummonKiosk( summonFunction )
	if EHT.Biz.IsProcessRunning() then
		EHT.UI.DisplayNotification( "A process is already running" )
		return nil
	end

	if not EHT.Housing.IsHouseZone() or not EHT.Housing.IsOwner() then
		EHT.UI.DisplayNotification( "You are not in your home" )
		return
	end

	if EHT.Biz.IsKioskInUse() then
		if EHT.Biz.DismissKiosk() then
			EHT.UI.DisplayNotification( string.format( "Dismissing %s...", tostring( EHT.Biz.GetCurrentKioskName() ) ) )

			local emote = math.random( 1, 3 )
			if 1 == emote then
				EHT.Util.PlayEmote( "/goaway" )
			elseif 2 == emote then
				EHT.Util.PlayEmote( "/dustoff" )
			else
				EHT.Util.PlayEmote( "/dismiss" )
			end
		end
	else
		local result = summonFunction()
		if result then
			EHT.UI.DisplayNotification( string.format( "Summoning %s...", tostring( EHT.Biz.GetCurrentKioskName() ) ) )

			local emote = math.random( 1, 3 )
			if 1 == emote then
				EHT.Util.PlayEmote( "/preen" )
			elseif 2 == emote then
				EHT.Util.PlayEmote( "/surprised" )
			else
				EHT.Util.PlayEmote( "/dustoff" )
			end
		end
	end
end

function EHT.UI.SummonStorage()
	EHT.UI.SummonKiosk( function() EHT.Biz.SummonStorageKiosk() end )
end

function EHT.UI.SummonCrafting()
	EHT.UI.SummonKiosk( function() EHT.Biz.SummonCraftingKiosk() end )
end

function EHT.UI.CopySelectionToClipboard()
	local groupSize = EHT.Biz.GetGroupSize()

	if 0 >= groupSize then
		EHT.UI.ShowAlertDialog( "Copy to Clipboard", MSG_SELECTION_EMPTY )
	else
		EHT.UI.ShowConfirmationDialog( "Copy to Clipboard", string.format( "Copy the %d selected item(s) to the virtual clipboard?", groupSize ), function() EHT.Biz.CopyGroupToClipboard() end )
	end
end

function EHT.UI.CutSelectionToClipboard( preserveClipboard )
	local groupSize = EHT.Biz.GetGroupSize()

	if 0 >= groupSize then
		EHT.UI.ShowAlertDialog( "Cut to Clipboard", MSG_SELECTION_EMPTY )
	else
		if true == preserveClipboard then
			EHT.UI.ShowConfirmationDialog( "Cut Items", string.format( "Cut the %d selected item(s), removing those items to your inventory?", groupSize ), function() EHT.Biz.CutGroupToInventory( preserveClipboard ) end )
		else
			EHT.UI.ShowConfirmationDialog( "Cut to Clipboard and Remove", string.format( "Copy the %d selected item(s) to the virtual clipboard and remove all selected items to your inventory?", groupSize ), function() EHT.Biz.CutGroupToInventory( preserveClipboard ) end )
		end
	end
end

function EHT.UI.PasteFromInventory()
	local groupSize = EHT.Biz.GetClipboardSize()

	if 0 >= groupSize then
		EHT.UI.ShowAlertDialog( "Paste from Inventory", "The virtual clipboard is empty.\nYou must copy a selection of items to the virtual clipboard first." )
	else
		EHT.Biz.PasteClipboardFromInventory()
		--EHT.UI.ShowConfirmationDialog( "Paste Clipboard from Inventory", string.format( "Paste the %d clipboard item(s) from your inventory, bank or storage containers?", groupSize ), function() EHT.Biz.PasteClipboardFromInventory() end )
	end
end

function EHT.UI.ConfirmPasteLocation( group, pasteCallback )
	EHT.UI.ShowCustomDialog(
		"Paste to your current location or to the original location from which these items were copied?",
		"Current Location",
		function()
			local x, y, z = GetPlayerWorldPositionInHouse()
			EHT.Biz.MoveGroupCenterTo( group, x, y, z )
			pasteCallback()
		end,
		"Original Location",
		function()
			pasteCallback()
		end )
end

function EHT.UI.StackInGroups( groupCount )
	local groups = "one pile"
	if nil == groupCount or 1 >= groupCount then
		groupCount = 1
	else
		groups = string.format( "%d separate groups", groupCount )
	end

	EHT.UI.ShowConfirmationDialog(
		"Stack all selected items",
		string.format( "Stack all selected items into %s?", groups ),
		function() EHT.Biz.StackSelectedFurniture( groupCount ) end )

end


function EHT.UI.DeselectAlternateItems( startIndex )

	local house, group = EHT.Data.GetCurrentHouse()
	if nil == house or nil == group or 0 >= #group then
		EHT.UI.ShowAlertDialog( "", MSG_SELECTION_EMPTY )
		return
	end

	EHT.UI.ShowConfirmationDialog(
		"",
		string.format( "Deselect all %s numbered items?", 1 == startIndex and "odd" or "even" ),
		function() EHT.Biz.DeselectAlternateItems( startIndex ) end )

end


function EHT.UI.RandomlyOrderItems()

	EHT.Biz.RandomlyOrderItems()
	--[[
	local house, group = EHT.Data.GetCurrentHouse()
	if nil == house or nil == group or 0 >= #group then
		EHT.UI.ShowAlertDialog( "", MSG_SELECTION_EMPTY )
		return
	end

	EHT.UI.ShowConfirmationDialog(
		"",
		string.format( "Reorder all selected items randomly?" ),
		function() EHT.Biz.RandomlyOrderItems() end )
	]]

end


function EHT.UI.ReverseOrderItems()

	EHT.Biz.ReverseOrderItems()
	--[[
	local house, group = EHT.Data.GetCurrentHouse()
	if nil == house or nil == group or 0 >= #group then
		EHT.UI.ShowAlertDialog( "", MSG_SELECTION_EMPTY )
		return
	end

	EHT.UI.ShowConfirmationDialog(
		"",
		string.format( "Reverse the order of all selected items?" ),
		function() EHT.Biz.ReverseOrderItems() end )
	]]

end


function EHT.UI.CloneScene()

	if not EHT.UI.CanEditAnimation() then return end

	EHT.UI.ShowConfirmationDialog(
		"Clone Scene?",
		"Cloning a Scene will replace your current Scene.\n" ..
		"You should save any changes to the current Scene first.\n\n" ..
		"Continue with cloning a Scene?",
		function() EHT.UI.ShowCloneSceneDialog() end )

end


function EHT.UI.SelectSceneItems()

	if not EHT.UI.CanEditAnimation() then return end

	local _, group, scene = EHT.Data.GetCurrentHouse()
	if nil == scene or 0 >= #scene.Group then
		EHT.UI.ShowErrorDialog( "Scene Empty", MSG_SCENE_EMPTY, function() end )
	else
		if nil ~= group and 0 < #group then
			EHT.UI.ShowConfirmationDialog( "Replace Current Selection",
				"Replace current selection with this Scene's furniture?",
				function() EHT.Biz.SetupGroupFromCurrentScene() end )
		else
			EHT.Biz.SetupGroupFromCurrentScene()
		end
	end

end


function EHT.UI.ReverseScene()

	if not EHT.UI.CanEditAnimation() then return end

	local _, group, scene = EHT.Data.GetCurrentHouse()
	if nil == scene or 0 >= #scene.Group then
		EHT.UI.ShowErrorDialog( "Scene Empty", "Scene is empty.", function() end )
	else
		EHT.UI.ShowConfirmationDialog( "Reverse Scene",
			"Reverse the order of this Scene's Frames?",
			function() EHT.Biz.ReverseSceneFrames() end )
	end

end


function EHT.UI.AddSelectionToScene()

	if not EHT.UI.CanEditAnimation() then return end

	local _, group, scene = EHT.Data.GetCurrentHouse()
	if nil == group or 0 >= #group then
		EHT.UI.ShowErrorDialog( "Selection Empty", MSG_SELECTION_EMPTY, function() end )
	else
		EHT.UI.ShowConfirmationDialog( "Add Selected Items",
			"Add selected items to this Scene?",
			function()
				local oldCount = #scene.Group
				EHT.Biz.AddToSceneFromCurrentGroup()
				local newCount = #scene.Group
				EHT.UI.ShowAlertDialog( "Selection Added", tostring( newCount - oldCount ) .. " new item(s) have been added to the Scene.", function() end )
			end )
	end

end


function EHT.UI.RemoveSelectionFromScene()

	if not EHT.UI.CanEditAnimation() then return end

	local _, group, scene = EHT.Data.GetCurrentHouse()
	if nil == group or 0 >= #group then
		EHT.UI.ShowErrorDialog( "Selection Empty", MSG_SELECTION_EMPTY, function() end )
	else
		EHT.UI.ShowConfirmationDialog( "Remove Selected Items",
			"Remove selected items from this Scene?\n\nThis change cannot be undone.\nIt is recommended that you save a copy of this Scene first.",
			function()
				local oldCount = #scene.Group
				EHT.Biz.RemoveCurrentGroupFromScene()
				local newCount = #scene.Group
				EHT.UI.ShowAlertDialog( "Selection Removed", tostring( oldCount - newCount ) .. " item(s) have been removed from the Scene.", function() end )
			end )
	end

end

---[ Operations : Sounds  ]---

do
	local soundReadyTime = 0

	function EHT.UI.PlaySoundThrottled( sound, duration )
		if nil == duration then duration = 450 end
		local currentTime = GetFrameTimeMilliseconds()
		if currentTime < soundReadyTime then return false end
		soundReadyTime = currentTime + duration

		PlaySound( sound )

		return true
	end
end

function EHT.UI.PlaySoundFailure() return EHT.UI.PlaySoundThrottled( SOUNDS.GENERAL_ALERT_ERROR ) end
function EHT.UI.PlaySoundConfirm() return EHT.UI.PlaySoundThrottled( SOUNDS.POSITIVE_CLICK ) end
function EHT.UI.PlaySoundEffectAdded() return EHT.UI.PlaySoundThrottled( SOUNDS.CROWN_CRATES_DEAL_PRIMARY ) end
function EHT.UI.PlaySoundEffectChanged() return PlaySound( SOUNDS.DYEING_TOOL_SET_FILL_USED ) end
function EHT.UI.PlaySoundEffectCloned() return EHT.UI.PlaySoundThrottled( SOUNDS.CROWN_CRATES_CARDS_LEAVE ) end
function EHT.UI.PlaySoundEffectEndEdit() return EHT.UI.PlaySoundThrottled( SOUNDS.TABLET_CLOSE ) end
function EHT.UI.PlaySoundEffectRemoved() return EHT.UI.PlaySoundThrottled( SOUNDS.HUD_ARMOR_BROKEN ) end
function EHT.UI.PlaySoundEffectStartEdit() return EHT.UI.PlaySoundThrottled( SOUNDS.TABLET_OPEN ) end
--function EHT.UI.PlaySoundEffectChanged() return EHT.UI.PlaySoundThrottled( SOUNDS.TABLET_PAGE_TURN ) end

---[ Operations : UI Coordination ]---

function EHT.UI.GetHousingHUDButton()
	return WINDOW_MANAGER:GetControlByName( "ZO_HousingHUDFragmentTopLevelKeybindButton" )
end

function EHT.UI.GetHousingEditorUndoStackControls()
	if nil ~= HOUSING_EDITOR_UNDO_STACK and nil ~= HOUSING_EDITOR_UNDO_STACK.control then
		return HOUSING_EDITOR_UNDO_STACK.control:GetChild( 1 ), HOUSING_EDITOR_UNDO_STACK.control:GetChild( 2 )
	end
end

function EHT.UI.SetHousingEditorUndoStackHidden( hidden )
	local ctrl1, ctrl2 = EHT.UI.GetHousingEditorUndoStackControls()
	if nil == ctrl1 or nil == ctrl2 then return end

	ctrl1:SetHidden( hidden )
	ctrl2:SetAlpha( hidden and 0 or 1 )

	EHT.SavedVars.HideHousingEditorUndoStack = hidden
end

function EHT.UI.SetupHousingEditorUndoStack()
	local hidden = EHT.SavedVars.HideHousingEditorUndoStack
	EHT.UI.SetHousingEditorUndoStackHidden( hidden )
end

local isUIHidden = false
local hiddenDialogs = { }

function EHT.UI.GetCurrentSceneName()
	local scene = SCENE_MANAGER:GetCurrentScene()
	if scene and scene.GetName then
		return scene:GetName()
	end
	return nil
end

function EHT.UI.UpdateUIMode( scene, forceRefresh )
	local houseId = GetCurrentZoneHouseId()
	local mode = GetHousingEditorMode()
	local hideUI = true

	EHT.UI.UpdateInventoryKeybindStrip( false )
	EHT.CurrentSceneName = string.lower( scene or "" )
--[[
	if nil ~= scene and ( "tradinghouse" == scene or "keyboard_housing_furniture_scene" == scene or "gamepad_housing_furniture_scene" == scene ) then -- or "outfitStylesBook" == scene or "inventory" == scene or "smithing" == scene or "store" == scene ) then
		EHT.UI.ShowPreviewControlsDialog()
	else
		EHT.UI.HidePreviewControlsDialog()
	end
]]
	if 0 < houseId then
		if nil ~= scene then
			local isHUD = "hud" == scene or "hudui" == scene
			local isHousingEditorHUD = not isHUD and ( "housingEditorHud" == scene or "housingEditorHudUI" == scene )

			EHT.UI.ShowEHTButton( isHUD or isHousingEditorHUD )

			if isHUD then
				hideUI = false
			elseif isHousingEditorHUD then
				if mode ~= HOUSING_EDITOR_MODE_BROWSE then
					if mode == HOUSING_EDITOR_MODE_PLACEMENT then
						if not EHT.SavedVars.HideDuringPlacement then
							hideUI = false
						end
					else
						hideUI = false
					end
				end
			elseif "inventory" == scene then
				EHT.UI.UpdateInventoryKeybindStrip( true )
			end
		else
			if mode ~= HOUSING_EDITOR_MODE_BROWSE then
				if mode == HOUSING_EDITOR_MODE_PLACEMENT then
					if not EHT.SavedVars.HideDuringPlacement then
						hideUI = false
					end
				else
					hideUI = false
				end
			end
		end
	end

	if mode ~= HOUSING_EDITOR_MODE_DISABLED then
		if EHT.SnapFurnitureInitiating then
			EHT.SnapFurnitureInitiating = false
		else
			EHT.UI.HideSnapFurnitureDialog()
		end
	end

	EHT.UI.UpdateHiddenDialogs( hideUI, forceRefresh )
end

function EHT.UI.IsDialogHidden( dialog ) return hiddenDialogs[ dialog ] end

function EHT.UI.ClearDialogHidden( dialog ) hiddenDialogs[ dialog ] = false end

function EHT.UI.SetDialogHidden( dialog ) hiddenDialogs[ dialog ] = true end

do
	local dialogs =
	{
		{ "BackupsDialog", "BACKUPS", EHT.UI.QueueRefreshBackups, },
		{ "ClipboardDialog", "CLIPBOARD", EHT.UI.RefreshClipboard, },
		{ "CopyFromSelectionsDialog", "COPY_FROM_SELECTION", EHT.UI.RefreshCopyFromSelectionsDialog, },
		{ "CloneSceneDialog", "CLONE_SCENE", EHT.UI.RefreshCloneSceneDialog, },
		{ "EHTEffectsButtonContextMenu", "FXMENU", EHT.UI.HideEHTEffectsButtonContextMenu, },
		{ "GuildcastDialog", "GUILDCAST", nil, },
		{ "InteractionPromptDialog", "INTERACTION_PROMPT", nil, },
		{ "ImportClipboardDialog", "IMPORT_CLIPBOARD", EHT.UI.RefreshImportClipboardDialog, },
		{ "ExportClipboardDialog", "EXPORT_CLIPBOARD", EHT.UI.RefreshExportClipboardDialog, },
		{ "ManageBuildsDialog", "MANAGE_BUILDS", EHT.UI.RefreshManageBuildsDialog, },
		{ "ManageSelectionsDialog", "MANAGE_SELECTIONS", EHT.UI.RefreshManageSelectionsDialogs, },
		{ "PositionDialog", "POSITION", EHT.UI.RefreshPositionDialog, },
		{ "ToolDialog", "TOOL", function() EHT.UI.RefreshSelectionList() EHT.UI.RefreshTriggers() end, },
		{ "SnapFurnitureDialog", "SNAP_FURNITURE", nil, },
		{ "TutorialDialog", "TUTORIAL", nil, },
		{ "TriggerQueueDialog", "TRIGGERQUEUE", EHT.UI.UpdateTriggerQueueDialog, },
		{ "ReportDialog", "REPORT", nil, },
	}
	
	local COLUMN_UI = 1
	local COLUMN_KEY = 2
	local COLUMN_UPDATE = 3

	local function RefreshDialog( dialog, updateFunc )
		if dialog and dialog.Window and not dialog.Window:IsHidden() then
			updateFunc()
		end
	end

	function EHT.UI.RefreshUI()
		for _, dialogData in ipairs( dialogs ) do
			local dialogUI = EHT.UI[dialogData[COLUMN_UI]]
			local updateFunc = dialogData[COLUMN_UPDATE]
			if updateFunc and dialogUI and dialogUI.Window and not dialogUI.Window:IsHidden() then
				updateFunc()
			end
		end
	end

	function EHT.UI.UpdateHiddenDialogs( hideUI, forceRefresh )
		if hideUI then
			if not isUIHidden then
				isUIHidden = true

				for _, dialogData in ipairs( dialogs ) do
					local dialogUI = EHT.UI[dialogData[COLUMN_UI]]
					if dialogUI and dialogUI.Window then
						local dialogKey = dialogData[COLUMN_KEY]
						if dialogKey then
							hiddenDialogs[dialogKey] = not dialogUI.Window:IsHidden()
							if hiddenDialogs[dialogKey] then
								dialogUI.Window:SetHidden( true )
							end
						end
					end
				end

				EHT.Pointers.ClearPointers()
			end
		else
			if isUIHidden then
				isUIHidden = false

				for _, dialogData in ipairs( dialogs ) do
					local dialogUI = EHT.UI[dialogData[COLUMN_UI]]
					if dialogUI and dialogUI.Window then
						local dialogKey = dialogData[COLUMN_KEY]
						if dialogKey then
							if hiddenDialogs[dialogKey] then
								dialogUI.Window:SetHidden( false )
							end
						end
					end
				end
			end

			if forceRefresh then
				EHT.UI.RefreshUI()
			end
		end
	end
end
--[[
		if EHT.UI.ClipboardDialog and not EHT.UI.ClipboardDialog.Window:IsHidden() then EHT.UI.RefreshClipboard() end
		if EHT.UI.CopyFromSelectionsDialog and not EHT.UI.CopyFromSelectionsDialog.Window:IsHidden() then EHT.UI.RefreshCopyFromSelectionsDialog() end
		if EHT.UI.CloneSceneDialog and not EHT.UI.CloneSceneDialog.Window:IsHidden() then EHT.UI.RefreshCloneSceneDialog() end
		if EHT.UI.ImportClipboardDialog and not EHT.UI.ImportClipboardDialog.Window:IsHidden() then EHT.UI.RefreshImportClipboardDialog() end
		if EHT.UI.ExportClipboardDialog and not EHT.UI.ExportClipboardDialog.Window:IsHidden() then EHT.UI.RefreshExportClipboardDialog() end
		if EHT.UI.ManageBuildsDialog and not EHT.UI.ManageBuildsDialog.Window:IsHidden() then EHT.UI.RefreshManageBuildsDialog() end
		if EHT.UI.ManageSelectionsDialog and not EHT.UI.ManageSelectionsDialog.Window:IsHidden() then EHT.UI.RefreshManageSelectionsDialogs() end
		if EHT.UI.PositionDialog and not EHT.UI.PositionDialog.Window:IsHidden() then EHT.UI.RefreshPositionDialog() end
		if EHT.UI.ToolDialog and not EHT.UI.ToolDialog.Window:IsHidden() then EHT.UI.RefreshSelectionList() EHT.UI.RefreshTriggers() end
		if EHT.UI.BackupsDialog and not EHT.UI.BackupsDialog.Window:IsHidden() then EHT.UI.QueueRefreshBackups() end
		if EHT.UI.EHTEffectsButtonContextMenu and not EHT.UI.EHTEffectsButtonContextMenu.Window:IsHidden() then EHT.UI.HideEHTEffectsButtonContextMenu() end
		if EHT.UI.TriggerQueueDialog and not EHT.UI.TriggerQueueDialog.Window:IsHidden() then EHT.UI.UpdateTriggerQueueDialog() end
	end

function EHT.UI.UpdateHiddenDialogs( hideUI, forceRefresh )
	if hideUI then
		if not isUIHidden then
			isUIHidden = true

			hiddenDialogs[ EHT.CONST.DIALOG.BACKUPS ] = EHT.UI.BackupsDialog and not EHT.UI.BackupsDialog.Window:IsHidden()
			hiddenDialogs[ EHT.CONST.DIALOG.CLIPBOARD ] = EHT.UI.ClipboardDialog and not EHT.UI.ClipboardDialog.Window:IsHidden()
			hiddenDialogs[ EHT.CONST.DIALOG.COPY_FROM_SELECTION ] = EHT.UI.CopyFromSelectionsDialog and not EHT.UI.CopyFromSelectionsDialog.Window:IsHidden()
			hiddenDialogs[ EHT.CONST.DIALOG.CLONE_SCENE ] = EHT.UI.CloneSceneDialog and not EHT.UI.CloneSceneDialog.Window:IsHidden()
			hiddenDialogs[ EHT.CONST.DIALOG.IMPORT_CLIPBOARD ] = EHT.UI.ImportClipboardDialog and not EHT.UI.ImportClipboardDialog.Window:IsHidden()
			hiddenDialogs[ EHT.CONST.DIALOG.EXPORT_CLIPBOARD ] = EHT.UI.ExportClipboardDialog and not EHT.UI.ExportClipboardDialog.Window:IsHidden()
			hiddenDialogs[ EHT.CONST.DIALOG.MANAGE_BUILDS ] = EHT.UI.ManageBuildsDialog and not EHT.UI.ManageBuildsDialog.Window:IsHidden()
			hiddenDialogs[ EHT.CONST.DIALOG.MANAGE_SELECTIONS ] = EHT.UI.ManageSelectionsDialog and not EHT.UI.ManageSelectionsDialog.Window:IsHidden()
			hiddenDialogs[ EHT.CONST.DIALOG.POSITION ] = EHT.UI.PositionDialog and not EHT.UI.PositionDialog.Window:IsHidden()
			hiddenDialogs[ EHT.CONST.DIALOG.TOOL ] = EHT.UI.ToolDialog and not EHT.UI.ToolDialog.Window:IsHidden()
			hiddenDialogs[ EHT.CONST.DIALOG.SNAP_FURNITURE ] = EHT.UI.SnapFurnitureDialog and not EHT.UI.SnapFurnitureDialog.Window:IsHidden()
			hiddenDialogs[ EHT.CONST.DIALOG.TUTORIAL ] = EHT.UI.TutorialDialog and not EHT.UI.TutorialDialog.Window:IsHidden()
			hiddenDialogs[ EHT.CONST.DIALOG.FXMENU ] = EHT.UI.EHTEffectsButtonContextMenu and not EHT.UI.EHTEffectsButtonContextMenu.Window:IsHidden()
			hiddenDialogs[ EHT.CONST.DIALOG.TRIGGERQUEUE ] = EHT.UI.EHTTriggerQueue and not EHT.UI.EHTTriggerQueue.Window:IsHidden()

			if hiddenDialogs[ EHT.CONST.DIALOG.BACKUPS ] then EHT.UI.BackupsDialog.Window:SetHidden( true ) end
			if hiddenDialogs[ EHT.CONST.DIALOG.CLIPBOARD ] then EHT.UI.ClipboardDialog.Window:SetHidden( true ) end
			if hiddenDialogs[ EHT.CONST.DIALOG.COPY_FROM_SELECTION ] then EHT.UI.CopyFromSelectionsDialog.Window:SetHidden( true ) end
			if hiddenDialogs[ EHT.CONST.DIALOG.CLONE_SCENE ] then EHT.UI.CloneSceneDialog.Window:SetHidden( true ) end
			if hiddenDialogs[ EHT.CONST.DIALOG.FXMENU ] then EHT.UI.EHTEffectsButtonContextMenu.Window:SetHidden( true ) end
			if hiddenDialogs[ EHT.CONST.DIALOG.IMPORT_CLIPBOARD ] then EHT.UI.ImportClipboardDialog.Window:SetHidden( true ) end
			if hiddenDialogs[ EHT.CONST.DIALOG.EXPORT_CLIPBOARD ] then EHT.UI.ExportClipboardDialog.Window:SetHidden( true ) end
			if hiddenDialogs[ EHT.CONST.DIALOG.MANAGE_BUILDS ] then EHT.UI.ManageBuildsDialog.Window:SetHidden( true ) end
			if hiddenDialogs[ EHT.CONST.DIALOG.MANAGE_SELECTIONS ] then EHT.UI.ManageSelectionsDialog.Window:SetHidden( true ) end
			if hiddenDialogs[ EHT.CONST.DIALOG.POSITION ] then EHT.UI.PositionDialog.Window:SetHidden( true ) end
			if hiddenDialogs[ EHT.CONST.DIALOG.TOOL ] then EHT.UI.ToolDialog.Window:SetHidden( true ) end
			if hiddenDialogs[ EHT.CONST.DIALOG.SNAP_FURNITURE ] then EHT.UI.SnapFurnitureDialog.Window:SetHidden( true ) end
			if hiddenDialogs[ EHT.CONST.DIALOG.TUTORIAL ] then EHT.UI.TutorialDialog.Window:SetHidden( true ) end
			if hiddenDialogs[ EHT.CONST.DIALOG.TRIGGERQUEUE ] then EHT.UI.EHTTriggerQueue.Window:SetHidden( true ) end

			EHT.Pointers.ClearPointers()
		end
	else
		if isUIHidden then
			isUIHidden = false

			if hiddenDialogs[ EHT.CONST.DIALOG.BACKUPS ] then EHT.UI.BackupsDialog.Window:SetHidden( false ) EHT.UI.QueueRefreshBackups() end
			if hiddenDialogs[ EHT.CONST.DIALOG.CLIPBOARD ] then EHT.UI.ClipboardDialog.Window:SetHidden( false ) EHT.UI.RefreshClipboard() end
			if hiddenDialogs[ EHT.CONST.DIALOG.COPY_FROM_SELECTION ] then EHT.UI.CopyFromSelectionsDialog.Window:SetHidden( false ) EHT.UI.RefreshCopyFromSelectionsDialog() end
			if hiddenDialogs[ EHT.CONST.DIALOG.CLONE_SCENE ] then EHT.UI.CloneSceneDialog.Window:SetHidden( false ) EHT.UI.RefreshCloneSceneDialog() end
			if hiddenDialogs[ EHT.CONST.DIALOG.FXMENU ] then EHT.UI.EHTEffectsButtonContextMenu.Window:SetHidden( false ) end
			if hiddenDialogs[ EHT.CONST.DIALOG.IMPORT_EXPORT_CLIPBOARD ] then EHT.UI.ImportExportClipboardDialog.Window:SetHidden( false ) EHT.UI.RefreshImportExportClipboardDialog() end
			if hiddenDialogs[ EHT.CONST.DIALOG.MANAGE_BUILDS ] then EHT.UI.ManageBuildsDialog.Window:SetHidden( false ) EHT.UI.RefreshManageBuildsDialog() end
			if hiddenDialogs[ EHT.CONST.DIALOG.MANAGE_SELECTIONS ] then EHT.UI.ManageSelectionsDialog.Window:SetHidden( false ) EHT.UI.RefreshManageSelectionsDialogs() end
			if hiddenDialogs[ EHT.CONST.DIALOG.POSITION ] then EHT.UI.PositionDialog.Window:SetHidden( false ) EHT.UI.RefreshPositionDialog() end
			if hiddenDialogs[ EHT.CONST.DIALOG.TOOL ] then EHT.UI.ToolDialog.Window:SetHidden( false ) EHT.UI.RefreshSelection() EHT.UI.RefreshTriggers() end
			if hiddenDialogs[ EHT.CONST.DIALOG.SNAP_FURNITURE ] then EHT.UI.SnapFurnitureDialog.Window:SetHidden( false ) end
			if hiddenDialogs[ EHT.CONST.DIALOG.TUTORIAL ] then EHT.UI.TutorialDialog.Window:SetHidden( false ) end
			if hiddenDialogs[ EHT.CONST.DIALOG.TRIGGERQUEUE ] then EHT.UI.EHTTriggerQueue.Window:SetHidden( false ) end
		end

		if forceRefresh then EHT.UI.RefreshUI() end
	end
end
]]
---[ Operations : Controls  ]---

function EHT.UI.IsMouseOverControl( c1, c2, c3 )
	local iterations = 0
	local mControl = WINDOW_MANAGER:GetMouseOverControl()

	if not mControl then
		return false
	end

	if mControl then
		local parent = mControl:GetOwningWindow()

		if parent then
			if parent == c1 or parent == c2 or parent == c3 then
				return true
			end
		end
	end

	while mControl and 200 > iterations do
		if mControl == c1 or mControl == c2 or mControl == c3 then
			return true
		end

		mControl = mControl:GetParent()
		iterations = iterations + 1
	end
	
	return false
end

function EHT.UI.IsMouseOverAnyControl(controls)
	local mouseX, mouseY = GetUIMousePosition()

	for index, control in ipairs(controls) do
		local left, top, right, bottom = control:GetScreenRect()
		if mouseX >= left and mouseX <= right and mouseY >= top and mouseY <= bottom then
			return true
		end
	end

	return false
end

do
	local FocusControls = { }
	local PreFadeDuration = 100

	function EHT.UI.FocusLostHide( control, mouseOverControls, hideDelay )
		hideDelay = hideDelay or PreFadeDuration
		local ft = GetFrameTimeMilliseconds()
		local data = { Control = control, Controls = mouseOverControls, HideDelay = hideDelay, FadeTime = ft + hideDelay }
		table.insert( FocusControls, data )
		control:SetHidden( false )
		EVENT_MANAGER:RegisterForUpdate( "EHT.UI.FocusLostHideCheck", 100, EHT.UI.FocusLostHideCheck )
	end

	function EHT.UI.FocusLostHideCheck()
		local ft = GetFrameTimeMilliseconds()
		local iterations = 0
		local data, mouseOver
		local moving = IsPlayerMoving()

		for index = #FocusControls, 1, -1 do
			data = FocusControls[index]

			if moving then
				data.Control:SetHidden( true )
				table.remove( FocusControls, index )
			else
				mouseOver = false

				for _, control in pairs( data.Controls ) do
					if EHT.UI.IsMouseOverControl( control ) then
						mouseOver = true
						break
					end
				end

				if mouseOver then
					data.FadeTime = ft + data.HideDelay
				elseif data.FadeTime < ft or data.Control:IsHidden() then
					data.Control:SetHidden( true )
					table.remove( FocusControls, index )
				end
			end
		end

		if 0 == #FocusControls then
			EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.FocusLostHideCheck" )
		end
	end
end

function EHT.UI.UpdateScrollFade( scroll, gradientSize )
	if nil ~= scroll then
		ZO_UpdateScrollFade( true, scroll, ZO_SCROLL_DIRECTION_VERTICAL, gradientSize or EHT.CONST.UI.MAX_FADE_GRADIENT_SIZE )
	end
end

function EHT.UI.UpdateScrollExtents( container, slider, upButton, downButton, sliderBackdrop )
	if nil == container or nil == slider then return false end

	local _, scrollHeight = container:GetScrollExtents()
	-- local _, scrollOffset = container:GetScrollOffsets()

	slider:SetMinMax( 0, scrollHeight )
	slider:SetHidden( 1 >= scrollHeight )

	if nil ~= upButton then upButton:SetHidden( 1 >= scrollHeight ) end
	if nil ~= downButton then downButton:SetHidden( 1 >= scrollHeight ) end
	if nil ~= sliderBackdrop then sliderBackdrop:SetHidden( 1 >= scrollHeight ) end

	EHT.UI.UpdateScrollFade( container )

	return true
end

function EHT.UI.UpdateInventoryKeybindStrip( show )
	if show then
		KEYBIND_STRIP:AddKeybindButtonGroup( EHT.INVENTORY_KEYBIND_BUTTONS )
	else
		KEYBIND_STRIP:RemoveKeybindButtonGroup( EHT.INVENTORY_KEYBIND_BUTTONS )
	end
end

function EHT.UI.AddKeybindButton( buttonDescriptor )
	if not buttonDescriptor.added then
		buttonDescriptor.added = true
		KEYBIND_STRIP:AddKeybindButton( buttonDescriptor )
	end
end

function EHT.UI.RemoveKeybindButton( buttonDescriptor )
	if buttonDescriptor.added then
		buttonDescriptor.added = false
		KEYBIND_STRIP:RemoveKeybindButton( buttonDescriptor )
	end
end

function EHT.UI.UpdateKeybindStrip( mode )
	if nil == standardKeybindStripPadding then
		standardKeybindStripPadding = KEYBIND_STRIP.styleInfo.resizeToFitPadding
	end

	KEYBIND_STRIP.styleInfo.resizeToFitPadding = standardKeybindStripPadding

	for _, button in pairs( EHT.KEYBIND_BUTTONS ) do
		EHT.UI.RemoveKeybindButton( button )
	end

	if 0 >= GetCurrentZoneHouseId() then return end

	KEYBIND_STRIP.styleInfo.resizeToFitPadding = 15

	if nil == mode then mode = GetHousingEditorMode() end

	if EHT.ChooseItemCallback and mode == HOUSING_EDITOR_MODE_SELECTION then
		EHT.UI.AddKeybindButton( EHT.KEYBIND_BUTTONS.CHOOSE_TARGET )
	else
		if not EHT.SavedVars.HideKeybinds then
			if not EHT.ChooseItemCallback and mode == HOUSING_EDITOR_MODE_SELECTION then
				if EHT.SavedVars.EnableHouseHistory then
					EHT.UI.AddKeybindButton( EHT.KEYBIND_BUTTONS.UNDO )
					--EHT.UI.AddKeybindButton( EHT.KEYBIND_BUTTONS.REDO )
				end

				EHT.UI.AddKeybindButton( EHT.KEYBIND_BUTTONS.POSITION )
				EHT.UI.AddKeybindButton( EHT.KEYBIND_BUTTONS.SELECT )
			end

			if mode == HOUSING_EDITOR_MODE_PLACEMENT then
				local furnitureId = HousingEditorGetSelectedFurnitureId()

				if nil == EHT.Data.GetGroupFurniture( furnitureId ) then
					EHT.UI.AddKeybindButton( EHT.KEYBIND_BUTTONS.SELECT )
				else
					EHT.UI.AddKeybindButton( EHT.KEYBIND_BUTTONS.DESELECT )
				end
			end
		end
	end

	if mode == HOUSING_EDITOR_MODE_SELECTION or mode == HOUSING_EDITOR_MODE_PLACEMENT then
		EHT.UI.AddKeybindButton( EHT.KEYBIND_BUTTONS.QUICK_ACTIONS )
	end
end

function EHT.UI.ShowHelp()
	return EHT.UI.ShowURL( EHT.ADDON_HELP_URL )
end

function EHT.UI.ShowFeedback()
	local ui = EHT.UI.ToolDialog
	local to = "@Cardinal05"
	local subject = "Essential Housing Tools Feedback"
	EHT.UI.ShowNewEmail(to, subject, nil)
end

do
	local activeTooltipControls = { }

	function EHT.UI.ShowTooltip( tooltip, control, message, tooltipAnchor, offsetX, offsetY, controlAnchor )
		if nil == control then return end
		if nil == tooltip then tooltip = InformationTooltip end

		local centerX, centerY = GuiRoot:GetCenter()
		local controlX, controlY = control:GetCenter()

		if nil == tooltipAnchor and nil == controlAnchor then
			if controlX >= centerX then
				tooltipAnchor, controlAnchor, offsetX = RIGHT, LEFT, -30
			else
				tooltipAnchor, controlAnchor, offsetX = LEFT, RIGHT, 30
			end

			if 300 < math.abs( centerY - controlY ) then
				if controlY >= centerY then
					if tooltipAnchor == RIGHT then
						tooltipAnchor, controlAnchor, offsetY = BOTTOMRIGHT, TOPLEFT, -30
					else
						tooltipAnchor, controlAnchor, offsetY = BOTTOMLEFT, TOPRIGHT, -30
					end
				else
					if tooltipAnchor == RIGHT then
						tooltipAnchor, controlAnchor, offsetY = TOPRIGHT, BOTTOMLEFT, 30
					else
						tooltipAnchor, controlAnchor, offsetY = TOPLEFT, BOTTOMRIGHT, 30
					end
				end
			end
		else
			if nil == tooltipAnchor then tooltipAnchor = RIGHT end
			if nil == controlAnchor then controlAnchor = LEFT end
			if nil == offsetX then offsetX = -5 end
			if nil == offsetY then offsetY = 0 end
		end

		activeTooltipControls[tooltip] = control
		InitializeTooltip( tooltip, control, tooltipAnchor, offsetX, offsetY, controlAnchor )
		tooltip:AddLine( message, "", 1, 1, 1, 1 )
	end

	function EHT.UI.ShowControlTooltip( tooltip, control, tooltipAnchor, offsetX, offsetY, controlAnchor, relativeControl )
		local message

		if control then
			if "function" == type( control.InfoTooltipMessage ) then
				message = control.InfoTooltipMessage( control )
			else
				message = control.InfoTooltipMessage
			end
		end

		if message then
			EHT.UI.ShowTooltip( tooltip, relativeControl or control, message, tooltipAnchor, offsetX, offsetY, controlAnchor )
		end
	end

	function EHT.UI.HideTooltip( tooltip )
		if nil == tooltip then tooltip = InformationTooltip end
		activeTooltipControls[tooltip] = nil
		ClearTooltip( tooltip )
	end

	function EHT.UI.SetInfoTooltip( control, message, tooltipAnchor, offsetX, offsetY, controlAnchor, relativeControl, showImmediately )
		if nil == control or nil == message or ( "string" == type( message ) and "" == message ) then
			return
		end

		if nil ~= control.InfoTooltipMessage then
			control.InfoTooltipMessage = message
		else
			control.InfoTooltipMessage = message
			control.PostTooltipOnEnter = control:GetHandler( "OnMouseEnter" )
			control.PostTooltipOnExit = control:GetHandler( "OnMouseExit" )

			control:SetHandler( "OnMouseEnter", function( ... )
				EHT.UI.ShowControlTooltip( InformationTooltip, control, tooltipAnchor, offsetX, offsetY, controlAnchor, relativeControl )
				if nil ~= control.PostTooltipOnEnter then control.PostTooltipOnEnter( ... ) end
			end )

			control:SetHandler( "OnMouseExit", function( ... )
				EHT.UI.HideTooltip( InformationTooltip )
				if nil ~= control.PostTooltipOnExit then control.PostTooltipOnExit( ... ) end
			end )
		end

		if control.Backdrop then
			EHT.UI.SetInfoTooltip( control.Backdrop, message, BOTTOMRIGHT, offsetX, offsetY, TOPLEFT )
		end

		if control.Label then
			EHT.UI.SetInfoTooltip( control.Label, message, BOTTOMRIGHT, offsetX, offsetY, TOPLEFT )
		end

		if control.Value then
			EHT.UI.SetInfoTooltip( control.Value, message, BOTTOMLEFT, offsetX, offsetY, TOPRIGHT )
		end

		if control.MinLabel then
			EHT.UI.SetInfoTooltip( control.MinLabel, message, BOTTOMRIGHT, offsetX, offsetY, TOPLEFT )
		end

		if control.MaxLabel then
			EHT.UI.SetInfoTooltip( control.MaxLabel, message, BOTTOMLEFT, offsetX, offsetY, TOPRIGHT )
		end

		if control.UnitsLabel then
			EHT.UI.SetInfoTooltip( control.UnitsLabel, message, BOTTOMLEFT, offsetX, offsetY, TOPRIGHT )
		end

		for tooltipControl, targetControl in pairs( activeTooltipControls ) do
			if targetControl == control then
				EHT.UI.ShowControlTooltip( tooltipControl, control, tooltipAnchor, offsetX, offsetY, controlAnchor )
				break
			end
		end
		
		if showImmediately then
			EHT.UI.ShowControlTooltip( InformationTooltip, control, tooltipAnchor, offsetX, offsetY, controlAnchor, relativeControl )
		end
	end

	function EHT.UI.ClearInfoTooltip( control )
		if nil == control then return end

		if nil ~= control.InfoTooltipMessage then
			control.InfoTooltipMessage = nil
			control:SetHandler( "OnMouseEnter", control.PostTooltipOnEnter )
			control:SetHandler( "OnMouseExit", control.PostTooltipOnExit )
		end

		for tooltipControl, targetControl in pairs( activeTooltipControls ) do
			if targetControl == control then
				EHT.UI.HideTooltip( tooltipControl )
				break
			end
		end
	end
end

function EHT.UI.CreateHeading( controlName, parentControl, text )
	local control = EHT.CreateControl( controlName, parentControl, CT_LABEL )

	control:SetFont( Colors.LabelHeadingFont )
	control:SetColor( 1.0, 1.0, 0.5, 1 )
	control:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
	control:SetVerticalAlignment( TEXT_ALIGN_TOP )
	control:SetText( text )

	return control
end

function EHT.UI.CreateButton( controlName, parentControl, text, anchors, clickHandler )
	local control = EHT.CreateControl(controlName, parentControl, CT_BUTTON)

	control:SetClickSound("Click")
	control:SetFont(Colors.LabelFontBold)
	control:SetNormalFontColor(UnpackColor(Colors.ButtonLabel))
	control:SetMouseOverFontColor(UnpackColor(Colors.White))
	control:SetDisabledFontColor(UnpackColor(Colors.DisabledLabelColor))
	control:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	control:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	if nil ~= text then
		control:SetText(text)
	end
	control:SetDimensions(EHT.CONST.CONTROL_DEFAULT.BUTTON_TEXT_MARGIN_WIDTH + control:GetLabelControl():GetTextWidth(), EHT.CONST.CONTROL_DEFAULT.BUTTON_HEIGHT)
	if nil ~= clickHandler then
		control:SetHandler("OnClicked", clickHandler)
	end
	if nil ~= anchors and 0 < #anchors then
		for index, anchor in ipairs(anchors) do
			control:SetAnchor(anchor[1], anchor[2], anchor[3], anchor[4], anchor[5])
		end
	end

	return control
end

function EHT.UI.CreateTextureButton( controlName, parentControl, texture, width, height, anchors, clickHandler )
	local control = EHT.CreateControl( controlName, parentControl, CT_BUTTON )

	control:SetClickSound( "Click" )
	control:SetText( "" )
	control:SetNormalTexture( texture )
	if width then control:SetWidth( width ) end
	if height then control:SetHeight( height ) end
	if nil ~= clickHandler then control:SetHandler( "OnClicked", clickHandler ) end
	if nil ~= anchors and 0 < #anchors then
		for index, anchor in ipairs( anchors ) do control:SetAnchor( anchor[1], anchor[2], anchor[3], anchor[4], anchor[5] ) end
	end

	return control
end

do
	local function OnMouseEnter( control )
		control.Backdrop:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 2 )
	end

	local function OnMouseExit( control )
		control.Backdrop:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 1 )
	end

	function EHT.UI.CreateTabButton( controlName, parentControl, text, width, height, anchors, clickHandler )
		local control = EHT.CreateControl( controlName, parentControl, CT_CONTROL )

		if nil ~= anchors and 0 < #anchors then
			for index, anchor in ipairs( anchors ) do
				control:SetAnchor( anchor[1], anchor[2], anchor[3], anchor[4], anchor[5] )
			end
		end

		control:SetResizeToFitDescendents(true)
		control:SetMouseEnabled(true)
		control.Backdrop = CreateTexture(controlName .. "Backdrop", control, CreateAnchor(CENTER, control, CENTER, 0, 0), nil, 60, 22)
		SetColor(control.Backdrop, Colors.TabBackdrop)
		control.Button = CreateButtonLabel(controlName .. "Button", control.Backdrop, text, CreateAnchor(CENTER, control.Backdrop, CENTER, 0, 0))
		control:SetHandler("OnMouseDown", clickHandler)
		control:SetHandler("OnMouseEnter", OnMouseEnter)
		control:SetHandler("OnMouseExit", OnMouseExit)

		return control
	end
end

function EHT.UI.CreateSlider( controlName, controlLabel, unitsLabel, parentControl, valueChangedFunc, minValue, maxValue, valueStep, precision, allowDefault, tabFunc )
	local currentValue = minValue
	if nil == currentValue then currentValue = 0 end

	local slider = EHT.CreateControl( controlName, parentControl, CT_SLIDER )
	slider.LabelText = controlLabel
	slider.Precision = precision or 0
	slider.ValueChangedFunc = valueChangedFunc
	slider.IsParam = true

	slider:SetHeight( 15 )
	slider:SetOrientation( ORIENTATION_HORIZONTAL )
	slider:SetMinMax( minValue, maxValue )
	slider:SetValueStep( valueStep )
	slider:SetThumbTexture( "EsoUI/Art/Miscellaneous/scrollbox_elevator.dds", "EsoUI/Art/Miscellaneous/scrollbox_elevator_disabled.dds", nil, 8, 16 )
	slider:SetAllowDraggingFromThumb( true )
	slider:SetMouseEnabled( true )
	slider:SetBackgroundMiddleTexture( "EsoUI/Art/ChatWindow/chat_scrollbar_track.dds" )
	slider.PreviousValue = nil
	slider:SetValue( currentValue )
	slider:SetDrawLayer( DL_OVERLAY )
	slider:SetDrawTier( DT_HIGH )

	slider:SetHandler( "OnValueChanged", function( self, value, eventReason )

		if nil == value then value = 0 end

		local precision = slider.Precision
		if nil == precision then precision = 0 end

		if eventReason == EVENT_REASON_HARDWARE then

			local hardwarePrecision = 1
			local _, sliderMax = slider:GetMinMax()
			local sliderWidth = slider:GetWidth()

			if sliderWidth >= ( sliderMax * 10 ) then hardwarePrecision = 0.1
			elseif sliderWidth >= ( sliderMax * 4 ) then hardwarePrecision = 0.25
			elseif sliderWidth >= ( sliderMax * 2 ) then hardwarePrecision = 0.5 end

			zo_callLater( function() if value == slider:GetValue() then slider:SetValue( zo_roundToNearest( value, hardwarePrecision ) ) end end, 10 )

		else
			value = zo_roundToNearest( value, 1 / math.pow( 10, precision ) )
		end

		local curValue = slider.Value:GetText()
		slider.Value:SetText( string.format( "%." .. tostring( precision ) .. "f", value ) )

		if "" ~= curValue then
			curValue = tonumber( curValue )
			if nil ~= curValue and 0 > curValue then
				if slider.UnitsLabel and "degrees" == slider.UnitsLabel:GetText() then
					local textValue = ( -360 + value )
					slider.Value:SetText( string.format( "%." .. tostring( precision ) .. "f", textValue ) )
				end
			end
		end

		if not EHT.SuppressSliderFunctions then
			if slider.ValueChangedFunc then slider.ValueChangedFunc( slider, value ) end
		end

	end )

	slider.Backdrop = EHT.CreateControl( nil, slider, CT_BACKDROP )
	slider.Backdrop:SetCenterColor( 0, 0, 0 )
	slider.Backdrop:SetAnchor( TOPLEFT, slider, TOPLEFT, 0, 4 )
	slider.Backdrop:SetAnchor( BOTTOMRIGHT, slider, BOTTOMRIGHT, 0, -4 )
	slider.Backdrop:SetEdgeTexture( "EsoUI/Art/Tooltips/UI-SliderBackdrop.dds", 32, 4 )
	slider.Backdrop:SetMouseEnabled( false )

	slider.RowBackdrop = EHT.CreateControl( nil, slider, CT_BACKDROP )
	slider.RowBackdrop:SetAnchor( TOPLEFT, slider, TOPLEFT, -5, -26 )
	slider.RowBackdrop:SetAnchor( BOTTOMRIGHT, slider, BOTTOMRIGHT, 5, 3 )
	slider.RowBackdrop:SetMouseEnabled( false )

	slider.MinLabel = EHT.CreateControl( nil, slider, CT_LABEL )
	slider.MinLabel:SetFont( "ZoFontGameSmall" )
	slider.MinLabel:SetAnchor( LEFT, slider, LEFT, 1, -14 )
	slider.MinLabel:SetText( tostring( minValue ) )
	slider.MinLabel:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
	slider.MinLabel:SetMouseEnabled( true )

	slider.MaxLabel = EHT.CreateControl( nil, slider, CT_LABEL )
	slider.MaxLabel:SetFont( "ZoFontGameSmall" )
	slider.MaxLabel:SetAnchor( RIGHT, slider, RIGHT, -1, -14 )
	slider.MaxLabel:SetText( tostring( maxValue ) )
	slider.MaxLabel:SetHorizontalAlignment( TEXT_ALIGN_RIGHT )
	slider.MaxLabel:SetMouseEnabled( true )

	slider.Label = EHT.CreateControl( nil, slider, CT_LABEL )
	slider.Label:SetFont( "ZoFontWinH5" )
	slider.Label:SetAnchor( BOTTOMLEFT, slider, TOPLEFT, 10, 0 )
	slider.Label:SetAnchor( BOTTOMRIGHT, slider, TOP, -5, 0 )
	slider.Label:SetText( slider.LabelText )
	slider.Label:SetHorizontalAlignment( TEXT_ALIGN_RIGHT )
	slider.Label:SetWidth( 150 )
	slider.Label:SetMouseEnabled( true )

	slider.ValueBackdrop = WINDOW_MANAGER:CreateControlFromVirtual( nil, slider, "ZO_EditBackdrop" )
	slider.ValueBackdrop:SetAnchor( LEFT, slider.Label, RIGHT, 10, -2 )
	slider.ValueBackdrop:SetDimensions( 55, 20 )

	slider.Value = WINDOW_MANAGER:CreateControlFromVirtual( nil, slider.ValueBackdrop, "ZO_DefaultEditForBackdrop" ) 
	slider.Value:SetFont( "$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thin" )
	slider.Value:SetAnchor( TOPLEFT, slider.ValueBackdrop, TOPLEFT, 4, 0 )
	slider.Value:SetAnchor( BOTTOMRIGHT, slider.ValueBackdrop, BOTTOMRIGHT, -4, 0 )
	slider.Value:SetDrawLayer( DL_OVERLAY )
	slider.Value:SetDrawTier( DT_HIGH )
	slider.Value:SetMaxInputChars( 7 )
	slider.Value.PreviousValue = nil
	slider.Value:SetHandler( "OnFocusLost", function()

		local text = slider.Value:GetText()

		if "" ~= text and slider.DefaultCheckbox then
			ZO_CheckButton_SetCheckState( slider.DefaultCheckbox, false )
		else

			local value = tonumber( text ) or 0

			if 0 > value then
				if slider.UnitsLabel and "degrees" == slider.UnitsLabel:GetText() then
					value = ( 360 + value ) % 360
				end
			end

			slider:SetValue( value )

		end

	end )
	slider.Value:SetHandler( "OnEnter", function( self ) self:LoseFocus() end )
	if nil ~= tabFunc then slider.Value:SetHandler( "OnTab", function() tabFunc( slider ) end ) end

	slider.Value:SetText( string.format( "%." .. tostring( slider.Precision ) .. "f", currentValue ) )

	if nil ~= unitsLabel and "" ~= unitsLabel then
		slider.UnitsLabel = EHT.CreateControl( nil, slider, CT_LABEL )
		slider.UnitsLabel:SetFont( "$(MEDIUM_FONT)|$(KB_14)|soft-shadow-thin" )
		slider.UnitsLabel:SetAnchor( LEFT, slider.ValueBackdrop, RIGHT, 8, 2 )
		slider.UnitsLabel:SetText( unitsLabel )
		slider.UnitsLabel:SetMouseEnabled( true )
	end

	if allowDefault then
		slider.DefaultCheckbox = WINDOW_MANAGER:CreateControlFromVirtual( controlName .. "_DefaultCheckbox", slider, "ZO_CheckButton" )
		slider.DefaultCheckbox:SetAnchor( BOTTOMRIGHT, slider, TOPRIGHT, -36, -2 )
		ZO_CheckButton_SetLabelText( slider.DefaultCheckbox, "Default" )
		slider.DefaultCheckbox.label:ClearAnchors()
		slider.DefaultCheckbox.label:SetAnchor( RIGHT, slider.DefaultCheckbox, LEFT, -5, 1 )
		slider.DefaultCheckbox.label:SetFont( "ZoFontGameSmall" )

		ZO_CheckButton_SetCheckState( slider.DefaultCheckbox, false )
		ZO_CheckButton_SetToggleFunction( slider.DefaultCheckbox, function()
			if ZO_CheckButton_IsChecked( slider.DefaultCheckbox ) then
				slider.Value:SetText( "" )
			end
		end )
	end

	return slider
end

function EHT.UI.AdjustSlider( window, buffer, slider )
	local numHistoryLines = buffer:GetNumHistoryLines()
	local numVisHistoryLines = buffer:GetNumVisibleLines()
	local bufferScrollPos = buffer:GetScrollPosition()
	local sliderMin, sliderMax = slider:GetMinMax()
	local sliderValue = slider:GetValue()
	
	slider:SetMinMax( 0, numHistoryLines )
	
	if sliderValue == sliderMax then
		slider:SetValue( numHistoryLines )
	elseif numHistoryLines == buffer:GetMaxHistoryLines() then
		slider:SetValue( sliderValue - 1 )
	end

	if numHistoryLines > numVisHistoryLines then
		slider:SetHidden( false )
	else
		slider:SetHidden( true )
	end

end


function EHT.UI.AddBufferText( window, buffer, slider, message )

	if nil == window or nil == buffer or nil == slider or nil == message then return end
	buffer:AddMessage( message, 1, 1, 1 )
	EHT.UI.AdjustSlider( window, buffer, slider )

end


function EHT.UI.CreateComboBoxEntry( comboBox, label, value, callback )

	local item = comboBox:CreateItemEntry( label, callback )
	item.Value = value
	comboBox:AddItem( item )

end


function EHT.UI.GetSelectedComboBoxEntry( comboBox )

	local item = comboBox:GetSelectedItemData()
	return item

end


function EHT.UI.GetSelectedComboBoxValue( comboBox )

	local value, item = nil, EHT.UI.GetSelectedComboBoxEntry( comboBox )
	if nil ~= item then value = item.Value end
	return value

end


function EHT.UI.SelectComboBoxValue( comboBox, value )

	for index, item in ipairs( comboBox:GetItems() ) do
		if value == item.Value then
			comboBox:SelectItemByIndex( index )
			break
		end
	end

end


---[ Operations : Modal Dialogs ]---

function EHT.UI.EnterUIMode(delay)
	zo_callLater( function() if not IsGameCameraUIModeActive() then ZO_SceneManager_ToggleHUDUIBinding() end end, delay or 50 )
end

function EHT.UI.ExitUIMode()
	zo_callLater( function() if IsGameCameraUIModeActive() then ZO_SceneManager_ToggleHUDUIBinding() end end, delay or 50 )
end

function EHT.UI.HideAllDialogs()
	ZO_Dialogs_ReleaseAllDialogs()
end

function EHT.UI.SetupAlertDialog()
    if not ESO_Dialogs[ EHT.CONST.DIALOG_ALERT ] then
		ESO_Dialogs[ EHT.CONST.DIALOG_ALERT ] = {
            canQueue = true,
            title = {
                text = "",
            },
            mainText = {
                text = "",
            },
            buttons = {
                [1] = {
                    text = SI_OK,
                    callback = function( dialog ) end,
                },
            }
        }
    end

	return ESO_Dialogs[ EHT.CONST.DIALOG_ALERT ]
end

function EHT.UI.SetupConfirmDialog()
    if not ESO_Dialogs[ EHT.CONST.DIALOG_CONFIRM ] then
		ESO_Dialogs[ EHT.CONST.DIALOG_CONFIRM ] = {
            canQueue = true,
            title = {
                text = "",
            },
            mainText = {
                text = "",
            },
            buttons = {
                [1] = {
                    text = SI_DIALOG_CONFIRM,
                    callback = function( dialog ) end,
                },
                [2] = {
                    text = SI_DIALOG_CANCEL,
					callback = function( dialog ) end,
                }
            }
        }
    end

	return ESO_Dialogs[ EHT.CONST.DIALOG_CONFIRM ]
end

function EHT.UI.SetupCustomDialog()
    if not ESO_Dialogs[ EHT.CONST.DIALOG_CUSTOM ] then
		ESO_Dialogs[ EHT.CONST.DIALOG_CUSTOM ] = {
            canQueue = true,
            title = {
                text = "",
            },
            mainText = {
                text = "",
            },
            buttons = {
				[1] = {
					text = "",
					callback = nil,
				},
				[2] = {
					text = "",
					callback = nil,
				},
            }
        }
    end

	return ESO_Dialogs[ EHT.CONST.DIALOG_CUSTOM ]
end

do
	local suppressedUIs
	local unsuppressing = false

	function EHT.UI.SuppressDialogUI()
		if not suppressedUIs then
			suppressedUIs = { }

			if not EHT.UI.IsHousingHubHidden() then
				suppressedUIs["HousingHub"] = true
				EHT.UI.HideHousingHub()
			end
		end

		if table.isEmpty( suppressedUIs ) then
			suppressedUIs = nil
		else
			EVENT_MANAGER:RegisterForUpdate( "EHT.UI.UnsuppressDialogUI", 250, EHT.UI.UnsuppressDialogUI )
		end
	end

	function EHT.UI.UnsuppressDialogUI()
		if ZO_Dialogs_IsShowingDialog() then
			return
		end

		if not unsuppressing then
			unsuppressing = true
		else
			EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.UnsuppressDialogUI" )

			if suppressedUIs then
				if suppressedUIs["HousingHub"] then
					zo_callLater( function() EHT.UI.ShowHousingHub( true ) end, 100 )
				end
			end

			suppressedUIs = nil
			unsuppressing = false
		end
	end

	function EHT.UI.ShowURL( url )
		EHT.UI.SuppressDialogUI()
		RequestOpenUnsafeURL( url )
	end

	function EHT.UI.ShowAlertDialog( title, body, confirmCallback, forceUIMode )
		local dialog = EHT.UI.SetupAlertDialog()
		dialog.title.text = EHT.ADDON_TITLE
		dialog.mainText.text = body
		dialog.buttons[1].callback = function()
			if nil ~= confirmCallback then
				confirmCallback()
			end
			if nil == forceUIMode or forceUIMode then
				EHT.UI.EnterUIMode()
			end
		end

		EHT.UI.SuppressDialogUI()
		ZO_Dialogs_ShowDialog( EHT.CONST.DIALOG_ALERT )
	end

	function EHT.UI.ShowErrorDialog( ... )
		EHT.UI.PlaySoundFailure()
		EHT.UI.ShowAlertDialog( ... )
	end

	function EHT.UI.ShowConfirmationDialog( title, body, confirmCallback, cancelCallback, forceUIMode )
		local dialog = EHT.UI.SetupConfirmDialog()
		dialog.title.text = EHT.ADDON_TITLE
		dialog.mainText.text = body
		dialog.buttons[1].callback = function()
			if nil ~= confirmCallback then
				confirmCallback()
			end
			if nil == forceUIMode or forceUIMode then
				EHT.UI.EnterUIMode()
			end
		end
		dialog.buttons[2].callback = function()
			if nil ~= cancelCallback then
				cancelCallback()
			end
			if nil == forceUIMode or forceUIMode then
				EHT.UI.EnterUIMode()
			end
		end

		EHT.UI.SuppressDialogUI()
		ZO_Dialogs_ShowDialog( EHT.CONST.DIALOG_CONFIRM )
	end

	function EHT.UI.ShowCustomDialog( message, button1, button1Callback, button2, button2Callback )
		local dialog = EHT.UI.SetupCustomDialog()

		dialog.title.text = EHT.ADDON_TITLE
		dialog.mainText.text = message

		dialog.buttons[1].text = button1
		dialog.buttons[1].callback = button1Callback

		dialog.buttons[2].text = button2
		dialog.buttons[2].callback = button2Callback

		EHT.UI.SuppressDialogUI()
		ZO_Dialogs_ShowDialog( EHT.CONST.DIALOG_CUSTOM )
	end
end

function EHT.UI.ShowCommunityAppReminder()
	if not EHT.Housing.IsHouseZone() then
		return
	end

	local SUPPRESS_DIALOG = true
	if not EssentialHousingHub:CheckCommunityConnection(SUPPRESS_DIALOG) then
		if not EHT.SavedVars.LastCommunityAppReminderMessage then
			EHT.SavedVars.LastCommunityAppReminderMessage = GetTimeStamp()

			EHT.UI.ShowAlertDialog("",
				"|cff0000We apologize for the inconvenience.|r\n\n" ..
				"A recent Essential Housing Tools update may have caused your Community app to stop working.\n\n" ..
				"If you had installed the Community app and find that you can no longer sign Guest Journals, list Open Houses or Publish FX, " ..
				"please update to the latest version of Essential Housing Tools and simply re-run the Community app installation.",
				function()
					EHT.UI.ShowConfirmationDialog("",
						"Would you like to view the brief Community App Setup Guide video now?",
						function()
							EHT.UI.ShowURL(EHT.CONST.URLS.SetupCommunityPC)
						end)
				end)
		end
	end
end

function EHT.UI.CreateHouseLink( ownerName, houseId )
	houseId = tonumber( houseId ) or 0
	ownerName = tostring( ownerName ) or ""
	if "" == ownerName or "nil" == ownerName then
		ownerName = GetDisplayName()
	end
	return ZO_HousingBook_GetHouseLink( houseId, ownerName )
end

function EHT.UI.ShareHouseLink( ownerName, houseId )
	ZO_LinkHandler_InsertLink( EHT.UI.CreateHouseLink( ownerName, houseId ) )
	EHT.UI.DisplayNotification( "Link pasted to chat" )
	return true
end

function EHT.UI.ShareHubHouseLink( control )
	if "table" == type( control.Data ) then
		local ownerName, houseId = control.Data.Owner, control.Data.HouseId
		EHT.UI.ShareHouseLink( ownerName, houseId )
	end
end

---[ Operations : Dialog Settings ]---

function EHT.UI.ResetAllDialogSettings() EHT.SavedVars.UI.DialogSettings = { } end

function EHT.UI.GetDialogSettings( windowName )
	if nil == EHT.SavedVars.UI then EHT.SavedVars.UI = { } end
	if nil == EHT.SavedVars.UI.DialogSettings then EHT.SavedVars.UI.DialogSettings = { } end

	local settings = EHT.SavedVars.UI.DialogSettings[ windowName ]
	if nil == settings then
		settings = { }
		EHT.SavedVars.UI.DialogSettings[ windowName ] = settings
	end

	return settings
end

function EHT.UI.SaveDialogSettings( windowName, windowOrKey, value )
	local settings = EHT.UI.GetDialogSettings( windowName )

	if "userdata" == type( windowOrKey ) then
		local window = windowOrKey

		settings.Left = window:GetLeft()
		settings.Top = window:GetTop()
		settings.Right = window:GetRight()
		settings.Bottom = window:GetBottom()
		settings.Width = window:GetWidth()
		settings.Height = window:GetHeight()
	else
		settings[ windowOrKey ] = value
	end
end

---[ Interaction : Choose An Item ]---

function EHT.UI.InitChooseAnItem()
	EHT.ChooseItemCallback = nil
	EHT.ChooseItemCallbackArgs = nil
	EHT.ChooseItemPreviousEditorMode = GetHousingEditorMode()
end

function EHT.UI.ChooseAnItem( callback, arg1, arg2, arg3, prompt )
	if nil == callback then return false end
	if 0 == GetCurrentZoneHouseId() then return false end

	local furnitureId = HousingEditorGetSelectedFurnitureId()

	if nil ~= furnitureId then
		HousingEditorRequestModeChange( HOUSING_EDITOR_MODE_DISABLED )
		if nil ~= EHT.ChooseItemPreviousEditorMode then HousingEditorRequestModeChange( EHT.ChooseItemPreviousEditorMode ) end
		zo_callLater( function() callback( furnitureId, arg1, arg2, arg3 ) end, 50 )

		return true
	end

	HousingEditorRequestModeChange( HOUSING_EDITOR_MODE_DISABLED )
	zo_callLater( function() EHT.UI.ChooseAnItemSetup( callback, arg1, arg2, arg3, prompt ) end, 50 )

	return true
end

function EHT.UI.ChooseAnItemSetup( callback, arg1, arg2, arg3, prompt )
	prompt = prompt or "Select an item"

	HousingEditorRequestModeChange( HOUSING_EDITOR_MODE_SELECTION )
	EHT.ChooseItemCallback = callback
	EHT.ChooseItemCallbackArgs = { arg1, arg2, arg3 }
	EHT.UI.ShowInteractionPrompt( "HOUSING_EDITOR_PRIMARY_ACTION", prompt, EHT.UI.ChooseAnItemCallback )
end

function EHT.UI.ChooseAnItemCallback()
	local callback = EHT.ChooseItemCallback
	if nil == callback then
		EHT.UI.UpdateKeybindStrip()
		return
	end

	local camX, camY, camZ = EHT.World:GetCameraPosition()
	local effect, _, effectDistance = EHT.World:GetReticleTargetEffect()
	local furnitureId = HousingEditorGetSelectedFurnitureId()

	if nil == furnitureId then
		if HousingEditorCanSelectTargettedFurniture() then
			EHT.Interop.SuspendFurnitureSnap()
			
			LockCameraRotation( true )
			HousingEditorSelectTargettedFurniture()
			furnitureId = HousingEditorGetSelectedFurnitureId()
			HousingEditorRequestModeChange( HOUSING_EDITOR_MODE_DISABLED )
			LockCameraRotation( false )

			EHT.Interop.ResumeFurnitureSnap()
		end
	end

	if nil ~= effect then
		if nil == furnitureId then
			furnitureId = effect:GetRecordId()
		else
			local x, y, z = EHT.Housing.GetFurnitureCenter( furnitureId )
			local useEffect = true

			if x and y and z then
				local furnitureDistance = zo_distance3D( x, y, z, camX, camY, camZ )
				if furnitureDistance < effectDistance then
					useEffect = false
				end
			end

			if useEffect then
				furnitureId = effect:GetRecordId()
			end
		end
	end

	if nil ~= furnitureId then
		local args = EHT.ChooseItemCallbackArgs
		zo_callLater( function() callback( furnitureId, args[1], args[2], args[3] ) end, 500 )

		HousingEditorRequestModeChange( HOUSING_EDITOR_MODE_DISABLED )
		if nil ~= EHT.ChooseItemPreviousEditorMode then HousingEditorRequestModeChange( EHT.ChooseItemPreviousEditorMode ) end

		EHT.ChooseItemCallback = nil
		EHT.ChooseItemCallbackArgs = nil
		EHT.UI.HideInteractionPrompt()
	end
end

function EHT.UI.ChooseAnItemFailedCallback()
	EHT.ChooseItemCallback = nil
	EHT.ChooseItemCallbackArgs = nil
	EHT.UI.HideInteractionPrompt()

	d( "Failed to select a target item. Please try again." )
end

---[ Dialog : Tools ]---

function EHT.UI.ShowWarning( message )
	local ui = EHT.UI.ToolDialog
	if nil == ui then return end

	ui.NotificationLabel:SetText( message )
	ui.NotificationPanel:SetHeight( 25 )
	ui.NotificationPanel:SetHidden( false )
end

function EHT.UI.ClearWarning()
	local ui = EHT.UI.ToolDialog
	if nil == ui then return end

	ui.NotificationPanel:SetHidden( true )
	ui.NotificationPanel:SetHeight( 0 )
	ui.NotificationLabel:SetText( "" )
end

function EHT.UI.RefreshGroupedIndicators( queuedId )
	EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.QueueRefreshGroupedIndicators" )

	local editorMode = GetHousingEditorMode()
	local currentTab = EHT.UI.GetCurrentToolTab()
	local ids, items, isBuilding = { }, { }, currentTab == EHT.CONST.TOOL_TABS.BUILD

	if editorMode == HOUSING_EDITOR_MODE_SELECTION or editorMode == HOUSING_EDITOR_MODE_PLACEMENT then
		if currentTab == EHT.CONST.TOOL_TABS.ANIMATE then
			local _, _, group = EHT.Data.GetCurrentHouse( true )

			if group and group.Group then
				group = group.Group

				if 0 < #group then
					for index, item in ipairs( group ) do
						if nil ~= item.Id then
							local x, y, z = EHT.Housing.GetFurnitureCenter( item.Id )

							if nil ~= x and 0 ~= x then
								local sId = tostring( item.Id )

								local newItem = { sId, x, y, z, false, false, true }
								table.insert( items, newItem )
								ids[ sId ] = newItem
							end
						end
					end
				end
			end
		end

		do
			local _, group = EHT.Data.GetCurrentHouse( true )

			if nil ~= group and 0 < #group then
				for index, item in ipairs( group ) do
					if nil ~= item.Id then
						local x, y, z = EHT.Housing.GetFurnitureCenter( item.Id )

						if nil ~= x and 0 ~= x then
							local sId = tostring( item.Id )

							local newItem = ids[ sId ]
							if newItem then
								newItem[8], newItem[9] = true, isBuilding
							else
								newItem = { sId, x, y, z, true, isBuilding, false }
								table.insert( items, newItem )
								ids[ sId ] = newItem
							end
						end
					end
				end
			end
		end
	end

	for _, item in ipairs( items ) do
		EHT.Pointers.SetGrouped( unpack( item ) )
	end

	EHT.Pointers.RetainGroupedSet( ids )
end

function EHT.UI.RefreshGroupOutlineIndicators( queueId )
	EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.QueueRefreshGroupOutlineIndicators" )

	EHT.Pointers.ClearGroupOutline()

	local editorMode = GetHousingEditorMode()
	if editorMode == HOUSING_EDITOR_MODE_SELECTION or editorMode == HOUSING_EDITOR_MODE_PLACEMENT then
		local house, group = EHT.Data.GetCurrentHouse( true )
		if nil ~= group and 0 < #group then
			local origin = EHT.Housing.CalculateFurnitureBoundsOrigin( group )
			if nil ~= origin then
				-- EHT.DirectionalIndicators:SetOrigin( origin )
				EHT.Pointers.SetGroupOutline( origin.MinX, origin.MinY, origin.MinZ, origin.MaxX, origin.MaxY, origin.MaxZ )
			end
		end
	end
end

function EHT.UI.RefreshLockedIndicators( queuedId )
	EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.QueueRefreshLockedIndicators" )

	local locks = EHT.Data.GetLocks()
	EHT.Pointers.ClearLocked()

	if nil ~= locks then
		local id, x, y, z
		for id, _ in pairs( locks ) do
			x, y, z = EHT.Housing.GetFurnitureCenter( id )
			if nil ~= x and 0 ~= x then
				local minX, minY, minZ, maxX, maxY, maxZ = EHT.Housing.GetFurnitureWorldBounds( id )
				local dimX, dimY, dimZ = maxX - minX, maxY - minY, maxZ - minZ
				EHT.Pointers.SetLocked( x, y, z, dimX, dimY, dimZ )
			end
		end
	end
end

function EHT.UI.RefreshIndicators( items )
	EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.QueueRefreshIndicators" )

	EHT.Pointers.ClearIndicators()

	if items then
		for index, item in ipairs( items ) do
			local x, y, z = EHT.Housing.GetFurnitureCenter( item.Id )
			if nil ~= x and 0 ~= x then
				EHT.Pointers.SetLocked( x, y, z, dimX, dimY, dimZ )
			end
		end
	end
end

function EHT.UI.OnSelectedItemDragAndDrop( sourceIndex, targetIndex )
	local _, items = EHT.Data.GetCurrentHouse()
	local numItems = #items

	sourceIndex = zo_clamp( sourceIndex, 1, numItems )
	targetIndex = zo_clamp( targetIndex, 1, numItems )

	local sourceItem = items[sourceIndex]

	if targetIndex > sourceIndex then
		for index = ( sourceIndex + 1 ), targetIndex do
			items[index - 1] = items[index]
		end
	else
		for index = ( sourceIndex - 1 ), targetIndex, -1 do
			items[index + 1] = items[index]
		end
	end

	items[targetIndex] = sourceItem
	EHT.UI.RefreshSelection()
end

function EHT.UI.RefreshSelectionListAppearance()
	local ui = EHT.UI.ToolDialog or EHT.UI.SetupToolDialog()
	if nil == ui then return end

	local appearance = string.lower(EHT.GetSetting("SelectionListFontSize"))
	local fontSize, itemHeight = 20, 27

	if "small" == appearance then
		fontSize, itemHeight = 16, 20
	elseif "large" == appearance then
		fontSize, itemHeight = 24, 32
	end

	local list = ui.Buffer
	list:SetItemFont( string.format( "$(CHAT_FONT)|$(KB_%d)|soft-shadow-thick", fontSize ) )
	list:SetItemHeight( itemHeight )
	list:Refresh()
end

do
	local Items = { }
EHTItems=Items
	local PrevPlayerX, PrevPlayerY, PrevPlayerZ = 0, 0, 0

	local function CompareNumericStrings( a, b )
		if "string" ~= type( a ) or "string" ~= type( b ) then
			return false
		end

		local s1, s2 = #a, #b

		if s1 > s2 then
			return true
		elseif s2 > s1 then
			return false
		else
			for index = 1, s1 do
				local n1 = tonumber( string.sub( a, index, index ) )
				local n2 = tonumber( string.sub( b, index, index ) )

				if not n1 or not n2 then
					return false
				elseif n1 > n2 then
					return true
				elseif n2 > n1 then
					return false
				end
			end

			return false
		end
	end

	local function SortItemsAlpha( a, b )
		local an, bn = string.lower( a.Name ), string.lower( b.Name )
		return an < bn or ( an == bn and CompareNumericStrings( a.Value, b.Value ) )
	end

	local function SortItemsDistance( a, b )
		local ad, bd = a.Distance, b.Distance
		return ad < bd or ( ad == bd and CompareNumericStrings( a.Value, b.Value ) )
	end

	local function OnClick( item, index, button, ... )
		local msg
		local itemCopy = EHT.Util.CloneTable( item )

		if IsAltKeyDown() or IsShiftKeyDown() or IsControlKeyDown() then
			StartChatInput( itemCopy.Link )
			CHAT_SYSTEM:Maximize()
			zo_callLater( function() StartChatInput( "" ) end, 250 )
			EHT.UI.DisplayNotification( "Link pasted to chat" )

			return
		end

		if button == MOUSE_BUTTON_INDEX_LEFT then
			local _, added = EHT.Biz.GroupUngroupFurnitureById( itemCopy.Value )

			if nil ~= added then
				msg = string.format( "|cffffff%s |c00ffff%s", true == added and "Selected" or false == added and "Deselected" or "", itemCopy.Name or "" )
			end
		elseif button == MOUSE_BUTTON_INDEX_RIGHT then
			local furnitureId = EHT.Housing.FindFurnitureId( itemCopy.Value )
			local x, y, z = EHT.Housing.GetFurnitureCenter( furnitureId )

			if x and y and z then
				SetPlayerWaypointByWorldLocation( x, y, z )

				local SCALE = 2
				local r, g, b = 1, 1, 1
				EHT.Pointers.SetSelect(x, y, z, SCALE, r, g, b)

				msg = string.format("Waypoint placed on %s", itemCopy.Name or "item")
			end
		end

		EHT.UI.DisplayNotification( msg )
	end

	function EHT.UI.RefreshSelectionDistanceUpdate()
		EHT.UI.RefreshSelection( "D" )
	end

	function EHT.UI.RefreshSelection(distanceUpdate)
		EVENT_MANAGER:UnregisterForUpdate("EHT.UI.RefreshSelection")

		EHT.EffectEditor.RefreshEditorSelectButton()
		EHT.UI.QueueRefreshGroupedIndicators()
		EHT.UI.RefreshGroupOutlineIndicators()
		EHT.UI.RefreshLockedIndicators()

		local ui = EHT.UI.ToolDialog or EHT.UI.SetupToolDialog()
		if not ui or not ui.Window or ui.Window:IsHidden() then return end

		local playerX, playerY, playerZ = GetPlayerWorldPositionInHouse()
		local distanceSorted = "distance" == string.lower(EHT.GetSetting("SelectionListSort"))
		local sortFunction = distanceSorted and SortItemsDistance or SortItemsAlpha
		local includeAll = true == EHT.GetSetting("SelectionListIncludeAll")
		local playerMoved = not ( PrevPlayerX == playerX and PrevPlayerY == playerY and PrevPlayerZ == playerZ )
		PrevPlayerX, PrevPlayerY, PrevPlayerZ = playerX, playerY, playerZ

		ui.Buffer:SetDragAndDropEnabled( not includeAll )

		if "D" == distanceUpdate then
			if not distanceSorted then
				EVENT_MANAGER:UnregisterForUpdate( "EHT.RefreshSelectionByDistance" )
				return
			end

			if not playerMoved then
				return
			end
		end

		if EHT.CONST.TOOL_TABS.SELECT ~= EHT.UI.GetCurrentToolTab() then return end

		local house, group = EHT.Data.GetCurrentHouse( true )
		if nil == house or nil == group or ui.Window:IsHidden() then return end

		local window = ui.Window
		local buffer = ui.Buffer
		local count, total, missing, itemIndex = 0, 0, 0, 1
		local selectedIds = { }
		local locked = zo_iconFormat( "esoui/art/campaign/campaignbrowser_fullpop.dds" ) .. " "
		local selected = zo_iconFormat( EHT.Textures.ICON_CHECKED_N ) .. " "
		local unselected = zo_iconFormat( EHT.Textures.ICON_UNCHECKED_N ) .. " "
		local unselectedBackdrop = CreateColor( 0, 0, 0, 1 )

		if not EHT.DecoTrackTooltip then
			if DecoTrack and DecoTrack.GenerateTooltipInfo then
				EHT.DecoTrackTooltip = function( link )
					if link and not GetCollectibleIdFromLink( link ) and not EHT.Housing.IsEffectItemLink( link ) then
						local items, total = DecoTrack.GenerateTooltipInfo( link )
						if items and total then
							items = string.gsub( items, "%b()%s", "" )
							return string.format( "%s\n%s", items, total )
						end
					end

					return ""
				end
			else
				EHT.DecoTrackTooltip = function( link ) return "" end
			end
		end

		if "D" == distanceUpdate then
			for index, item in ipairs( Items ) do
				local x, y, z = EHT.Housing.GetFurniturePosition( item.Value )
				item.Distance = zo_distance3D( x, y, z, playerX, playerY, playerZ )
			end
		else
			ui.SelectionName:SetText( house.CurrentGroupName or "" )
			ui.SelectionList:SetSelectedItem( house.CurrentGroupName or "" )

			for index, item in ipairs( group ) do
				if nil ~= item.Id then
					local link, itemLink = item.Link, item.Link
					if "" == itemLink then itemLink = nil end

					local isCollectible = 0 ~= ( GetCollectibleIdFromLink( link or "" ) or 0 )
					local effectId, effectTypeId = EHT.Housing.GetEffectLinkInfo( link )
					local isEffect = nil ~= effectTypeId
					local name = EHT.Housing.GetFurnitureLinkName( link or "" )
					local lock = ""

					if isEffect then
						link = EHT.Housing.GenerateEffectLink( effectId, effectTypeId, string.format( "%d.  %s", index, name ) )
						if nil == EHT.Data.GetEffectRecordById( effectId ) then
							missing = missing + 1
							if link then
								link = link .. " |cff4444Missing!|r"
							end
						end
					elseif link then
						link = string.gsub( link, "|h|h", string.format( "|h%d.  %s|h", index, name ), 1 )
					end

					if nil ~= link and 2 < #link and not isEffect and not isCollectible and nil == EHT.Housing.FindFurnitureId( item.Id, itemLink ) then
						missing = missing + 1
						link = link .. " |cff4444Missing!|r"
					end

					if EHT.Data.IsLocked( item.Id ) then
						lock = locked
					end

					count = count + 1
					total = total + 1

					local entry = Items[itemIndex]
					if not entry then
						entry = {
							ClickHandler = OnClick,
							MouseEnterHandler = nil,
							MouseExitHandler = nil
						}
						Items[itemIndex] = entry
					end
					itemIndex = itemIndex + 1

					selectedIds[ item.Id ] = true
					entry.Index = total
					entry.Value = string.fromId64( item.Id )
					entry.Label = string.format( "%s%s %d. %s %s", selected, lock, count, item.Icon and zo_iconFormat( item.Icon ) or "", name )
					entry.Link = link
					entry.Name = name
					entry.Distance = distanceSorted and zo_distance3D( item.X or 0, item.Y or 0, item.Z or 0, playerX, playerY, playerZ ) or 0
					entry.ToolTip = string.format( "%s\n\nThis item is |caa99ffselected|cffffff\n|c00ffffLeft-click|cffffff to deselect\n|c00ffffRight-click|cffffff to identify\n\n%s\n\n\n\n%s\n\n|c000000_", entry.Name, EHT.DecoTrackTooltip( link ), item.Icon and zo_iconFormat( item.Icon, 120, 120 ) or "" )
					entry.BackdropColor = Colors.ListItemSelectedBackdrop
				end
			end

			if includeAll then
				local unselectedItems = { }
				local id = EHT.Housing.GetNextFurnitureId()

				while id do
					local sid = string.fromId64( id )

					if not selectedIds[ sid ] then
						local link, lock = EHT.Housing.GetFurnitureLink( id ), ""

						if EHT.Data.IsLocked( id ) then
							lock = locked
						end

						local icon = EHT.Housing.GetFurnitureLinkIconFile( link )
						local name = EHT.Housing.GetFurnitureLinkName( link )
						local distance = 0
						total = total + 1

						if distanceSorted then
							local x, y, z = EHT.Housing.GetFurniturePosition( id )
							distance = zo_distance3D( x, y, z, playerX, playerY, playerZ )
						end

						table.insert( unselectedItems, {
							BackdropColor = unselectedBackdrop,
							Index = total,
							Value = sid,
							Label = string.format( "%s%s%s %s", unselected, lock, icon and zo_iconFormat( icon ) or "", name ),
							Link = link,
							Name = name,
							Distance = distance,
							ToolTip = string.format( "%s\n\nThis item is |cffff00not selected|cffffff\n|c00ffffLeft-click|cffffff to select\n|c00ffffRight-click|cffffff to identify\n\n%s\n\n\n\n%s\n\n|c000000_", name, EHT.DecoTrackTooltip( link ), icon and zo_iconFormat( icon, 120, 120 ) or "" ),
							ClickHandler = OnClick,
							MouseEnterHandler = nil,
							MouseExitHandler = nil
						} )
					end

					id = EHT.Housing.GetNextFurnitureId( id )
				end

				if 0 < #unselectedItems then
					for _, item in ipairs( unselectedItems ) do
						Items[itemIndex] = item
						itemIndex = itemIndex + 1
					end
				end
			end

			for index = #Items, itemIndex, -1 do
				table.remove( Items, index )
			end

			if includeAll then
				ui.SelectionCountLabel:SetText(string.format("%d |cffffffof |c00ffff%d |cffffffselected", count, total))
			else
				ui.SelectionCountLabel:SetText(string.format("%d |cffffffselected", count))
			end
		end

		if includeAll then
			table.sort( Items, sortFunction )
		end

		if 0 < #Items then
			buffer:SetItems( Items )
		else
			buffer:ClearItems()
		end

		buffer:RefreshList()

		if 0 < missing then
			EHT.UI.ShowWarning( string.format( "%d item%s missing.", missing, 1 == missing and "" or "s" ) )
		else
			EHT.UI.ClearWarning()
		end

		if distanceSorted then
			EVENT_MANAGER:RegisterForUpdate( "EHT.RefreshSelectionByDistance", 5000, EHT.UI.RefreshSelectionDistanceUpdate )
		else
			EVENT_MANAGER:UnregisterForUpdate( "EHT.RefreshSelectionByDistance" )
		end
	end
end

function EHT.UI.SelectionListChanged()
	local ui = EHT.UI.ToolDialog
	if nil == ui then return end

	local groupName = ui.SelectionList:GetSelectedItem()
	if nil == groupName or "" == groupName then groupName = EHT.CONST.GROUP_DEFAULT end

	EHT.Biz.LoadGroup( groupName, false )
end

function EHT.UI.RefreshSelectionList()
--EHT.PushTS("EHT.UI.RefreshSelectionList")
	EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.QueueRefreshSelectionList" )

	local ui = EHT.UI.ToolDialog
	if nil == ui then return end

	ui.SelectionList:ClearItems()
	ui.SelectionName:SetText( "" )

	local house = EHT.Data.GetCurrentHouse()
	if nil == house then return end

	local currentGroupName = house.CurrentGroupName
	if nil == currentGroupName or currentGroupName == EHT.CONST.GROUP_DEFAULT then currentGroupName = "" end

	ui.SelectionName:SetText( currentGroupName )

	for groupName, group in pairs( house.Groups ) do
		if groupName ~= EHT.CONST.GROUP_DEFAULT then
			ui.SelectionList:AddItem( groupName, EHT.UI.SelectionListChanged )
		end
	end

	if currentGroupName ~= EHT.CONST.GROUP_DEFAULT then
		ui.SelectionList:SetSelectedItem( currentGroupName )
	end

	ui.SelectionList:Refresh()
--EHT.PopTS("EHT.UI.RefreshSelectionList")
	EHT.UI.RefreshSelection()
end

function EHT.UI.RefreshClipboard( queuedId )
	EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.QueueRefreshClipboard" )
	if nil == EHT.UI.ClipboardDialog or EHT.UI.ClipboardDialog.Window:IsHidden() then return end

	local house = EHT.Data.GetCurrentHouse( true )
	if nil == house then return end

	local group = EHT.SavedVars.Clipboard
	local window = EHT.UI.ClipboardDialog.Window
	local buffer = EHT.UI.ClipboardDialog.ClipboardBuffer
	local slider = EHT.UI.ClipboardDialog.ClipboardSlider
	local count = 0
	local item = nil

	local scrollPosition = buffer:GetScrollPosition()
	buffer:Clear()

	local EXCLUDE_PATH_NODE = true
	for index, item in ipairs( group ) do
		if nil ~= item and nil ~= item.Link then
			local link = item.Link
			link = string.gsub( link, "|h|h", string.format( "|h%d.  %s|h", index, EHT.Housing.GetFurnitureLinkName( link, nil, EXCLUDE_PATH_NODE ) ), 1 )
			local icon = EHT.Housing.GetFurnitureLinkIcon( link )

			count = count + 1
			EHT.UI.AddBufferText( window, buffer, slider, string.format( "%s %s", link, icon ) )
		end
	end

	if 0 == count then
		EHT.UI.AddBufferText( window, buffer, slider, "Clipboard is empty." )
	else
		buffer:SetScrollPosition( scrollPosition )
	end
	slider:SetValue( buffer:GetNumHistoryLines() - buffer:GetScrollPosition() )

	EHT.UI.RefreshSelection()
end

function EHT.UI.RefreshHistory( queuedId )

	EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.QueueRefreshHistory" )

	if EHT.CONST.TOOL_TABS.HISTORY ~= EHT.UI.GetCurrentToolTab() then return end

	local house = EHT.Data.GetCurrentHouse( true )
	if nil == house or nil == EHT.UI.ToolDialog or EHT.UI.ToolDialog.Window:IsHidden() then return end

	local window = EHT.UI.ToolDialog.Window
	local buffer = EHT.UI.ToolDialog.HistoryBuffer
	local slider = EHT.UI.ToolDialog.HistorySlider
	local count, missing = 0, 0
	local item = nil
	local scrollPosition = buffer:GetScrollPosition()

	buffer:Clear()

	local curIndex = tonumber( house.HistoryIndex or 0 )
	local color, history, op = nil, nil, nil
	local indicator = ""

	for index = #house.History, 1, -1 do
		history = EHT.Data.DeserializeHistoryRecord( house.History[ index ] )

		if curIndex == index then
			color = "|cfafaff"
			indicator = " <<<"
		else
			color = "|c999999"
			indicator = ""
		end

		if EHT.CONST.CHANGE_TYPE.CHANGE == history.Op then op = "|caaaaffChanged|r"
		elseif EHT.CONST.CHANGE_TYPE.PLACE == history.Op then op = "|caaffaaPlaced|r"
		elseif EHT.CONST.CHANGE_TYPE.REMOVE == history.Op then op = "|cffaaaaRemoved|r"
		else op = "Unknown" end

		EHT.UI.AddBufferText( window, buffer, slider, string.format( "%s %d. (|r%s%s) %s%s|r", color, index, op, color, history.Link or "", indicator ) )
	end

	if 0 >= #house.History then
		EHT.UI.AddBufferText( window, buffer, slider, "No history." )
	else
		buffer:SetScrollPosition( scrollPosition )
	end

	slider:SetValue( buffer:GetNumHistoryLines() - buffer:GetScrollPosition() )
	
end

function EHT.UI.QueueRefreshGroupedIndicators()
	EVENT_MANAGER:RegisterForUpdate( "EHT.UI.QueueRefreshGroupedIndicators", 500, EHT.UI.RefreshGroupedIndicators )
end

function EHT.UI.QueueRefreshGroupOutlineIndicators()
	EHT.UI.RefreshGroupOutlineIndicators()
end

function EHT.UI.QueueRefreshLockedIndicators()
	EHT.UI.RefreshLockedIndicators()
end

function EHT.UI.QueueRefreshSelection()
	EVENT_MANAGER:RegisterForUpdate( "EHT.UI.RefreshSelection", 100, EHT.UI.RefreshSelection )
end

function EHT.UI.QueueRefreshSelectionList()
	EHT.UI.RefreshSelectionList()
end

function EHT.UI.QueueRefreshClipboard()
	EHT.UI.RefreshClipboard()
end

function EHT.UI.QueueRefreshBuild()
	EHT.UI.RefreshBuild()
end

function EHT.UI.QueueRefreshHistory()
	EHT.UI.RefreshHistory()
end

function EHT.UI.HideToolDialog()
	if nil ~= EHT.UI.ToolDialog then
		EHT.UI.ClearDialogHidden( EHT.CONST.DIALOG.TOOL )
		EHT.UI.ToolDialog.Window:SetHidden( true )
		EHT.Pointers.ClearPointers()
		EHT.Biz.CancelRandomizeBuild()
	end
end

function EHT.UI.ShowBuildPointers()
	local build = EHT.Data.GetBuild()
	if nil == build or nil == build.X or nil == build.Y or nil == build.Z then return end

	EHT.Pointers.ClearPointers()
	EHT.Pointers.SetBuild( tonumber( build.X ), tonumber( build.Y ), tonumber( build.Z ), nil, 0, 1, 1, 0.5 )
end

function EHT.UI.UpdateBuildScrollExtents()
	EHT.UI.UpdateScrollExtents( EHT.UI.ToolDialog.BuildParamsContainer, EHT.UI.ToolDialog.BuildParamsScrollSlider, EHT.UI.ToolDialog.BuildParamsScrollSliderUpButton, EHT.UI.ToolDialog.BuildParamsScrollSliderDownButton )
end

function EHT.UI.SetupToolDialogBuildTabTemplate()
	local ui = EHT.UI.ToolDialog
	if nil == ui then return end

	local paramsSection = ui.BuildParams
	if nil == paramsSection then return end

	local build = EHT.Data.GetBuild()
	local param = nil

	local templateName = build.TemplateName
	local templateControls = EHT.CONST.BUILD_TEMPLATE_CONTROLS[ templateName ] or { }

	local yOffset = 0
	local headingControl = nil
	local alternateRow = true

	for index, paramName in ipairs( EHT.CONST.ALL_BUILD_TEMPLATE_CONTROLS ) do

		local param = paramsSection[ paramName ]
		local matched = false
		paramName = string.lower( paramName )

		if "heading" == string.sub( paramName, -7 ) then

			headingControl = param
			headingControl:SetHidden( true )

		elseif nil ~= param then

			if not matched then
				for _, controlName in ipairs( EHT.CONST.GLOBAL_BUILD_TEMPLATE_CONTROLS ) do
					if string.lower( controlName ) == paramName then
						matched = true
						break
					end
				end
			end

			if not matched then
				for _, controlName in ipairs( templateControls ) do
					if string.lower( controlName ) == paramName then
						matched = true
						break
					end
				end
			end

			if not matched then
				param:SetHidden( true )
			else
				if nil ~= headingControl then
					headingControl:SetHidden( false )
					headingControl:SetSimpleAnchorParent( 0, yOffset )
					yOffset = yOffset + 45
					headingControl = nil
				end

				if param.RowBackdrop then
					if alternateRow then
						param.RowBackdrop:SetCenterColor( 0.1, 0.1, 0.05 )
						param.RowBackdrop:SetEdgeColor( 0.1, 0.1, 0.05 )
					else
						param.RowBackdrop:SetCenterColor( 0.02, 0.02, 0 )
						param.RowBackdrop:SetEdgeColor( 0.02, 0.02, 0 )
					end
					alternateRow = not alternateRow
				end

				param:SetHidden( false )
				if param:GetType() ~= CT_SLIDER then yOffset = yOffset - 30 end
				param:SetSimpleAnchorParent( 0, yOffset )
				yOffset = yOffset + param:GetHeight()
				yOffset = yOffset + ( param:GetType() == CT_SLIDER and 30 or 20 )
			end

		end

	end

	EHT.UI.BuildParamAutoSpacingChanged( paramsSection.ItemSpacingAuto.AutoSpacing, true )
	EHT.UI.BuildParamEllipseChanged( paramsSection.Ellipse, true )

	zo_callLater( EHT.UI.UpdateBuildScrollExtents, 100 )

	EHT.UI.ShowBuildPointers()

end


function EHT.UI.FocusBuildParameter( param )

	if nil == param or not param.IsParam then return end

	if param.Value and param.Value.TakeFocus then
		param.Value:TakeFocus()
		param.Value:SelectAll()
	elseif param.TakeFocus then
		param:TakeFocus()
	end

	local parent = param:GetParent()
	if nil == parent then return end

	local scroll = EHT.UI.ToolDialog.BuildParamsContainer
	if nil == scroll then return end

	local slider = EHT.UI.ToolDialog.BuildParamsScrollSlider
	if nil == slider then return end

	local paramTop, parentTop = param:GetTop(), parent:GetTop()
	local scrollPosition = paramTop - parentTop - 45

	slider:SetValue( scrollPosition )

end


function EHT.UI.TabToNextBuildParameter( self )

	if nil == self then return end

	local selfName = self:GetName()
	if nil == selfName or "" == selfName then return end

	local direction = 1
	if IsShiftKeyDown() then direction = -1 end

	local paramsSection = EHT.UI.ToolDialog.BuildParamsSection
	local maxIndex = paramsSection:GetNumChildren()
	local matchedIndex, param

	matchedIndex = -1

	for childIndex = 1, maxIndex do
		param = paramsSection:GetChild( childIndex )

		if param.IsParam and not param:IsHidden() and selfName == param:GetName() then
			matchedIndex = childIndex
			break
		end
	end

	if 0 < matchedIndex then
		if -1 == direction then maxIndex = 1 end
		matchedIndex = matchedIndex + direction

		for childIndex = matchedIndex, maxIndex, direction do
			param = paramsSection:GetChild( childIndex )

			if param.IsParam and not param:IsHidden() then
				if ( not param.Value and param.TakeFocus ) or ( param.Value and not param.Value:IsHidden() ) then
					EHT.UI.FocusBuildParameter( param )
					break
				end
			end
		end
	end
end

local isRefreshingBuild = false

function EHT.UI.RefreshBuild( queuedId )
	if nil ~= queuedId and queuedId ~= EHT.UI.QueuedRefreshBuildId then return end
	EHT.UI.QueuedRefreshBuildId = nil

	if EHT.CONST.TOOL_TABS.BUILD ~= EHT.UI.GetCurrentToolTab() then return end

	local ui = EHT.UI.ToolDialog
	if nil == ui then return end

	local params = ui.BuildParams
	if nil == params then return end

	local build = EHT.Data.GetBuild()
	if nil == build then return end

	EHT.Biz.CleanBuildValues( build )

	isRefreshingBuild = true

	if nil ~= build.TemplateName then ui.BuildTemplate:SetSelectedItem( build.TemplateName ) end

	if build.ItemCount then
		params.ItemCount:SetValue( tostring( build.ItemCount ) )
	else
		local _, group = EHT.Data.GetCurrentHouseRecords()
		if nil ~= group then params.ItemCount:SetValue( #group ) end
	end

	params.Radius:SetValue( build.Radius / 100 )
	params.RadiusX:SetValue( build.RadiusX / 100 )
	params.RadiusY:SetValue( build.RadiusY / 100 )
	params.RadiusZ:SetValue( build.RadiusZ / 100 )
	params.RadiusStart:SetValue( build.RadiusStart / 100 )
	params.RadiusEnd:SetValue( build.RadiusEnd / 100 )
	params.ArcLength:SetValue( build.ArcLength )
	params.Circumference:SetValue( build.Circumference )

	params.Pitch:SetValue( build.Pitch )
	params.Yaw:SetValue( build.Yaw )
	params.Roll:SetValue( build.Roll )

	local playerX, playerY, playerZ, playerHeading = GetPlayerWorldPositionInHouse()
	params.X:SetValue( ( build.X or playerX ) / 100 )
	params.Y:SetValue( ( build.Y or playerY ) / 100 )
	params.Z:SetValue( ( build.Z or ( playerZ + 1000 ) ) / 100 )

	params.ItemPitch:SetValue( build.ItemPitch )
	params.ItemYaw:SetValue( build.ItemYaw )
	params.ItemRoll:SetValue( build.ItemRoll )

	params.ItemHeight:SetValue( build.ItemHeight / 100 )
	params.ItemLength:SetValue( build.ItemLength / 100 )
	params.ItemWidth:SetValue( build.ItemWidth / 100 )

	ZO_CheckButton_SetCheckState( params.Ellipse, build.Ellipse )
	EHT.UI.BuildParamEllipseChanged( params.Ellipse )
	ZO_CheckButton_SetCheckState( params.ItemSpacingAuto.AutoSpacing, build.AutoSpacing )
	EHT.UI.BuildParamAutoSpacingChanged( params.ItemSpacingAuto.AutoSpacing )
	ZO_CheckButton_SetCheckState( params.CheckerPattern.CheckerPatternEnabled, build.CheckerPattern )
	ZO_CheckButton_SetCheckState( params.ReverseSort.ReverseSortEnabled, build.ReverseSort )
	params.ItemSpacingHeight:SetValue( build.ItemSpacingHeight / 100 )
	params.ItemSpacingLength:SetValue( build.ItemSpacingLength / 100 )
	params.ItemSpacingWidth:SetValue( build.ItemSpacingWidth / 100 )

	params.Length:SetValue( build.Length )
	params.Width:SetValue( build.Width )
	params.Height:SetValue( build.Height )

	params.Message.Value:SetText( build.Message )
	params.CharacterSpacing:SetValue( build.CharacterSpacing / 100 )
	params.LineSpacing:SetValue( build.LineSpacing / 100 )

	EHT.UI.SetupToolDialogBuildTabTemplate()

	isRefreshingBuild = false
end

function EHT.UI.BuildParamsChanged( self )
	if isRefreshingBuild then return end

	local ui = EHT.UI.ToolDialog
	if nil == ui then return end

	local params = ui.BuildParams
	if nil == params then return end

	local build = EHT.Data.GetBuild()
	build.TemplateName = ui.BuildTemplate:GetSelectedItem()
	build.ItemCount = tonumber( params.ItemCount:GetValue() )

	build.Pitch = tonumber( params.Pitch:GetValue() )
	build.Yaw = tonumber( params.Yaw:GetValue() )
	build.Roll = tonumber( params.Roll:GetValue() )

	build.X = tonumber( params.X:GetValue() ) * 100
	build.Y = tonumber( params.Y:GetValue() ) * 100
	build.Z = tonumber( params.Z:GetValue() ) * 100

	build.ItemPitch = tonumber( params.ItemPitch:GetValue() )
	build.ItemYaw = tonumber( params.ItemYaw:GetValue() )
	build.ItemRoll = tonumber( params.ItemRoll:GetValue() )

	build.Radius = ( tonumber( params.Radius:GetValue() ) ) * 100
	build.RadiusX = ( tonumber( params.RadiusX:GetValue() ) ) * 100
	build.RadiusY = ( tonumber( params.RadiusY:GetValue() ) ) * 100
	build.RadiusZ = ( tonumber( params.RadiusZ:GetValue() ) ) * 100
	build.RadiusStart = ( tonumber( params.RadiusStart:GetValue() ) ) * 100
	build.RadiusEnd = ( tonumber( params.RadiusEnd:GetValue() ) ) * 100
	build.ArcLength = tonumber( params.ArcLength:GetValue() ) or 0
	build.Circumference = ( tonumber( params.Circumference:GetValue() ) )

	build.ItemHeight = ( tonumber( params.ItemHeight:GetValue() ) ) * 100
	build.ItemLength = ( tonumber( params.ItemLength:GetValue() ) ) * 100
	build.ItemWidth = ( tonumber( params.ItemWidth:GetValue() ) ) * 100

	build.Ellipse = ZO_CheckButton_IsChecked( params.Ellipse )
	build.AutoSpacing = ZO_CheckButton_IsChecked( params.ItemSpacingAuto.AutoSpacing )
	build.CheckerPattern = ZO_CheckButton_IsChecked( params.CheckerPattern.CheckerPatternEnabled )
	build.ReverseSort = ZO_CheckButton_IsChecked( params.ReverseSort.ReverseSortEnabled )
	build.ItemSpacingHeight = ( tonumber( params.ItemSpacingHeight:GetValue() ) ) * 100
	build.ItemSpacingLength = ( tonumber( params.ItemSpacingLength:GetValue() ) ) * 100
	build.ItemSpacingWidth = ( tonumber( params.ItemSpacingWidth:GetValue() ) ) * 100

	build.Length = ( tonumber( params.Length:GetValue() ) )
	build.Width = ( tonumber( params.Width:GetValue() ) )
	build.Height = ( tonumber( params.Height:GetValue() ) )

	build.Message = params.Message.Value:GetText()
	build.CharacterSpacing = ( tonumber( params.CharacterSpacing:GetValue() ) ) * 100
	build.LineSpacing = ( tonumber( params.LineSpacing:GetValue() ) ) * 100

	EHT.Biz.CleanBuildValues( build )
	EHT.UI.SetupToolDialogBuildTabTemplate()
--	EHT.UI.SetUnsavedToolChanges( true )

	if EHT.SavedVars.AutoBuild then
		EHT.Biz.Build( build )
	end
end

function EHT.UI.BuildParamEllipseChanged( ctrl, skipRefresh )
	local bp = EHT.UI.ToolDialog.BuildParams
	if nil == bp then return end

	if ctrl:IsHidden() then
		if not bp.Radius:IsHidden() then
			bp.Radius:SetEnabled( true )
			bp.Radius.Value:SetHidden( false )
		end

		if not bp.RadiusX:IsHidden() then
			bp.RadiusX:SetEnabled( true )
			bp.RadiusX.Value:SetHidden( false )
		end

		if not bp.RadiusY:IsHidden() then
			bp.RadiusY:SetEnabled( true )
			bp.RadiusY.Value:SetHidden( false )
		end

		if not bp.RadiusZ:IsHidden() then
			bp.RadiusZ:SetEnabled( true )
			bp.RadiusZ.Value:SetHidden( false )
		end

		return
	end

	local build = EHT.Data.GetBuild()
	local enabled = ctrl and ctrl:GetParent() and not ctrl:GetParent():IsHidden() and ZO_CheckButton_IsChecked( ctrl )

	bp.Radius.Value:SetHidden( enabled )
	bp.Radius:SetEnabled( not enabled )

	bp.RadiusX.Value:SetHidden( not enabled )
	bp.RadiusX:SetEnabled( enabled )

	bp.RadiusY.Value:SetHidden( not enabled )
	bp.RadiusY:SetEnabled( enabled )

	bp.RadiusZ.Value:SetHidden( not enabled )
	bp.RadiusZ:SetEnabled( enabled )

	if build.Ellipse and not enabled and nil ~= bp.RadiusX:GetValue() then
		bp.Radius:SetValue( bp.RadiusX:GetValue() )
	elseif not build.Ellipse and enabled and nil ~= bp.Radius:GetValue() then
		bp.RadiusX:SetValue( bp.Radius:GetValue() )
		bp.RadiusY:SetValue( bp.Radius:GetValue() )
		bp.RadiusZ:SetValue( bp.Radius:GetValue() )
	end

	if not skipRefresh then EHT.UI.BuildParamsChanged() end
end

function EHT.UI.BuildParamAutoSpacingChanged( ctrl, skipRefresh )
	local bp = EHT.UI.ToolDialog.BuildParams

	if not ctrl:GetParent():IsHidden() then
		local enabled = ctrl and ctrl:GetParent() and ZO_CheckButton_IsChecked( ctrl )

		bp.Circumference.Value:SetHidden( not enabled )
		bp.Circumference:SetEnabled( enabled )

		bp.ItemSpacingLength.Value:SetHidden( enabled )
		bp.ItemSpacingLength:SetEnabled( not enabled )
		bp.ItemSpacingWidth.Value:SetHidden( enabled )
		bp.ItemSpacingWidth:SetEnabled( not enabled )
		bp.ItemSpacingHeight.Value:SetHidden( enabled )
		bp.ItemSpacingHeight:SetEnabled( not enabled )
	else
		bp.Circumference.Value:SetHidden( false )
		bp.Circumference:SetEnabled( true )

		bp.ItemSpacingLength.Value:SetHidden( false )
		bp.ItemSpacingLength:SetEnabled( true )
		bp.ItemSpacingWidth.Value:SetHidden( false )
		bp.ItemSpacingWidth:SetEnabled( true )
		bp.ItemSpacingHeight.Value:SetHidden( false )
		bp.ItemSpacingHeight:SetEnabled( true )
	end

	if not skipRefresh then EHT.UI.BuildParamsChanged() end
end

function EHT.UI.SetupToolDialogBuildTab( ui, parent, prefix, settings )
	local div = nil
	local tip = EHT.UI.SetInfoTooltip

	if nil == EHT.SavedVars.Build then EHT.SavedVars.Build = { } end

	-- Build Header

	ui.BuildHeaderGroup = EHT.CreateControl( prefix .. "BuildHeaderGroup", parent, CT_CONTROL )
	ui.BuildHeaderGroup:SetAnchor( TOPLEFT, parent, TOPLEFT, 0, 0 )
	ui.BuildHeaderGroup:SetAnchor( TOPRIGHT, parent, TOPRIGHT, 0, 0 )
	ui.BuildHeaderGroup:SetResizeToFitDescendents( true )

	ui.BuildTemplate = EHT.UI.Picklist:New( prefix .. "BuildTemplate", ui.BuildHeaderGroup, TOPLEFT, ui.BuildHeaderGroup, TOPLEFT, 0, 0, 180 )
	ui.BuildTemplate:SetSorted( true )
	for _, templateName in pairs( EHT.CONST.BUILD_TEMPLATE ) do
		ui.BuildTemplate:AddItem( templateName, EHT.UI.BuildParamsChanged )
	end
	ui.BuildTemplate:SetSelectedItem( EHT.SavedVars.Build.TemplateName )
	tip( ui.BuildTemplate:GetControl(), "The template defines the general shape that is constructed." )

	ui.BuildLoadSaveButton = EHT.UI.CreateButton(
		prefix .. "BuildLoadSaveButton",
		ui.BuildHeaderGroup,
		"Load/Save",
		{ { TOPRIGHT, ui.BuildHeaderGroup, TOPRIGHT, 0, 2 } },
		function() EHT.UI.ShowManageBuildsDialog() end )
	tip( ui.BuildLoadSaveButton, "Save your Build parameters or load a previously saved Build." )

	ui.BuildMeasureButton = EHT.UI.CreateButton(
		prefix .. "BuildMeasureButton",
		ui.BuildHeaderGroup,
		"Measure",
		{ { RIGHT, ui.BuildLoadSaveButton, LEFT, -2, 0 } },
		function() EHT.UI.ShowConfirmationDialog( "Measure Items", "Measure the selected items again and adjust the Item Dimensions?", function() EHT.Biz.ResetBuild( true ) end ) end )
	tip( ui.BuildMeasureButton, "Measure your selected items for more accurate construction." )

	ui.BuildResetButton = EHT.UI.CreateButton(
		prefix .. "BuildResetButton",
		ui.BuildHeaderGroup,
		"Reset",
		{ { RIGHT, ui.BuildMeasureButton, LEFT, -2, 0 } },
		function() EHT.UI.ShowConfirmationDialog( "Reset Build", "Reset all build parameters?", function() EHT.Biz.ResetBuild() end ) end )
	tip( ui.BuildResetButton, "Reset your Build parameters and measure your selected items for more accurate construction." )


	ui.BuildFunctionGroup = EHT.CreateControl( prefix .. "BuildFunctionGroup", parent, CT_CONTROL )
	ui.BuildFunctionGroup:SetAnchor( TOPLEFT, ui.BuildHeaderGroup, BOTTOMLEFT, 0, 2 )
	ui.BuildFunctionGroup:SetAnchor( TOPRIGHT, ui.BuildHeaderGroup, BOTTOMRIGHT, 0, 2 )
	ui.BuildFunctionGroup:SetResizeToFitDescendents( true )

	ui.BuildButton = EHT.UI.CreateButton(
		prefix .. "BuildButton",
		ui.BuildFunctionGroup,
		"Build",
		{ { TOPLEFT, ui.BuildFunctionGroup, TOPLEFT, 0, 0 } },
		function() EHT.Biz.Build( EHT.Data.GetBuild() ) end )
	tip( ui.BuildButton, "Begin construction using your selected items and the parameters configured below." )

	ui.AutoBuild = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "_AutoBuild", ui.BuildFunctionGroup, "ZO_CheckButton" )
	ui.AutoBuild:SetAnchor( LEFT, ui.BuildButton, RIGHT, 10, 0 )
	ZO_CheckButton_SetLabelText( ui.AutoBuild, "Auto-Build" )
	ui.AutoBuild.label:SetFont( "ZoFontWinH5" )
	tip( ui.AutoBuild, "When enabled, construction begins automatically whenever you change the Build's parameters.\n\nWhen disabled, click the |caaaaffBuild|r button to manually begin construction." )

	ZO_CheckButton_SetToggleFunction( ui.AutoBuild, function()
		EHT.SavedVars.AutoBuild = ZO_CheckButton_IsChecked( ui.AutoBuild )
	end )
	ZO_CheckButton_SetCheckState( ui.AutoBuild, EHT.SavedVars.AutoBuild )

	ui.RandomizeBuildButton = EHT.UI.CreateButton(
		prefix .. "RandomizeBuildButton",
		ui.BuildFunctionGroup,
		"Randomize",
		{ { TOPRIGHT, ui.BuildFunctionGroup, TOPRIGHT, 0, 0 } },
		function()
			if EHT.Biz.IsRandomizingBuild() then
				EHT.Biz.CancelRandomizeBuild()
			else
				EHT.UI.ShowConfirmationDialog( "", "Begin randomization of different parameters?\n\nNote: Click this button again to stop the process at any time.", function()
					EHT.Biz.RandomizeBuild( EHT.Data.GetBuild() )
				end )
			end
		end )
	tip( ui.RandomizeBuildButton, "Randomizes parameters of this build, slowly evolving the shape.\n\nOnce started, click this button again to stop the process at any time." )

	ui.BuildBringToMePinIcon = CreateTexture( "", ui.BuildFunctionGroup, CreateAnchor( TOPLEFT, ui.BuildResetButton, BOTTOMLEFT, 0, 7 ), nil, 18, 18, EHT.Textures.ICON_PIN, CreateColor( 1, 0, 0, 1 ) )

	ui.BuildBringToMeButton = EHT.UI.CreateButton(
		prefix .. "BuildBringToMeButton",
		ui.BuildFunctionGroup,
		"Build Here",
		{ { LEFT, ui.BuildBringToMePinIcon, RIGHT, -2, 0 }, },
		function() EHT.UI.ShowConfirmationDialog( "Build Here", "Center the build at this location?", function() EHT.Biz.ArrangeBringToMe() end ) end )
	tip( ui.BuildBringToMeButton, "Center the build at your current location.\n\nUse this when you do not know where your build is currently located." )
	ui.BuildBringToMeButton:SetNormalFontColor( 1, 1, 0, 1 )

	-- Build Parameters

	div = CreateDivider( nil, parent, CreateAnchor( TOPLEFT, ui.BuildFunctionGroup, BOTTOMLEFT, 0, 5 ), CreateAnchor( TOPRIGHT, ui.BuildFunctionGroup, BOTTOMRIGHT, 0, 5 ) )

	c = EHT.UI.Picklist:New( prefix .. "ArrangeBuildDropdown", parent, BOTTOMLEFT, parent, BOTTOMLEFT, 0, -1, 180, 26 )
	ui.ArrangeBuildDropdown = c

	local arrangeOptions = { }
	table.insert( arrangeOptions, EHT.CONST.GROUP_OPERATIONS.A_SUMMON_OPERATION.BRING_TO_ME )
	table.insert( arrangeOptions, EHT.CONST.GROUP_OPERATIONS.ALIGN_OPERATIONS.ALIGN_GROUP_WITH_TARGET_AXIS_X )
	table.insert( arrangeOptions, EHT.CONST.GROUP_OPERATIONS.ALIGN_OPERATIONS.ALIGN_GROUP_WITH_TARGET_AXIS_Y )
	table.insert( arrangeOptions, EHT.CONST.GROUP_OPERATIONS.ALIGN_OPERATIONS.ALIGN_GROUP_WITH_TARGET_AXIS_Z )
	table.insert( arrangeOptions, EHT.CONST.GROUP_OPERATIONS.ALIGN_OPERATIONS.CENTER_ON_TARGET )
	table.insert( arrangeOptions, EHT.CONST.GROUP_OPERATIONS.ALIGN_OPERATIONS.CENTER_BETWEEN_2_TARGETS )
	table.insert( arrangeOptions, EHT.CONST.GROUP_OPERATIONS.ALIGN_OPERATIONS.LEVEL_GROUP_WITH_TARGET )
	table.sort( arrangeOptions )
	table.insert( arrangeOptions, 1, "Arrange this build..." )
	for _, optName in ipairs( arrangeOptions ) do
		c:AddItem( optName, function() EHT.UI.ArrangeSelectedItems( ui.ArrangeBuildDropdown, optName ) end )
	end
	c:SetSelectedItem( "Arrange this build..." )

	EHT.UI.SetInfoTooltip( ui.ArrangeBuildDropdown:GetControl(), "Arrange your selected items using a variety of options." )

    local cbg = EHT.CreateControl( nil, parent, CT_BACKDROP )
	ui.BuildParamsContainerBackdrop = cbg
    cbg:SetCenterColor( 0, 0, 0 )
	cbg:SetAnchor( TOPLEFT, div, BOTTOMLEFT, -4, 5 )
	cbg:SetAnchor( BOTTOMRIGHT, parent, BOTTOMRIGHT, -8, -34 )
    cbg:SetEdgeTexture( "EsoUI\\Art\\Tooltips\\UI-SliderBackdrop.dds", 32, 4 )
-- EHT.UI.ToolDialog.BuildParamsContainer
	ui.BuildParamsContainer = EHT.CreateControl( prefix .. "BuildParamsSection", cbg, CT_SCROLL )
	ui.BuildParamsContainer:SetAnchor( TOPLEFT, cbg, TOPLEFT, 4, 4 )
	ui.BuildParamsContainer:SetAnchor( BOTTOMRIGHT, cbg, BOTTOMRIGHT, -4, -4 )
	ui.BuildParamsContainer:SetDrawLayer( DL_CONTROLS )
	ui.BuildParamsContainer:SetDrawTier( DT_HIGH )
	ui.BuildParamsContainer:SetMouseEnabled( true )
	ui.BuildParamsContainer:SetHandler( "OnMouseWheel", function( self, delta, ctrl, alt, shift )
		local scroll = ui.BuildParamsContainer
		local _, scrollHeight = scroll:GetScrollExtents()
		local slider = EHT.UI.ToolDialog.BuildParamsScrollSlider
		local value = slider:GetValue()
		if 0 == value then value = 20 end
		slider:SetValue( value - ( delta * 45 ) )
		EHT.UI.UpdateScrollFade( scroll )
	end )

	ui.BuildParamsSection = EHT.CreateControl( prefix .. "BuildParamsContainer", ui.BuildParamsContainer, CT_CONTROL )
	ui.BuildParamsSection:SetAnchor( TOPLEFT, ui.BuildParamsContainer, TOPLEFT, 0, 5 )
	ui.BuildParamsSection:SetResizeToFitDescendents( true )
	ui.BuildParamsSection:SetWidth( ui.BuildParamsContainer:GetWidth() )

	ui.BuildParamsScrollSlider = EHT.CreateControl( prefix .. "BuildParamsScrollSlider", parent, CT_SLIDER )
	ui.BuildParamsScrollSlider:SetWidth( 15 )
	ui.BuildParamsScrollSlider:SetAnchor( TOPLEFT, ui.BuildParamsContainerBackdrop, TOPRIGHT, -1, 16 )
	ui.BuildParamsScrollSlider:SetAnchor( BOTTOMRIGHT, ui.BuildParamsContainerBackdrop, BOTTOMRIGHT, 15, -15 )
	ui.BuildParamsScrollSlider:SetValue( 1 )
	ui.BuildParamsScrollSlider:SetValueStep( 1 )
	ui.BuildParamsScrollSlider:SetMouseEnabled( true )
	ui.BuildParamsScrollSlider:SetAllowDraggingFromThumb( true )
    ui.BuildParamsScrollSlider:SetThumbTexture( "EsoUI\\Art\\Miscellaneous\\scrollbox_elevator.dds", "EsoUI\\Art\\Miscellaneous\\scrollbox_elevator_disabled.dds", nil, 16, 64 )
	ui.BuildParamsScrollSlider:SetOrientation( ORIENTATION_VERTICAL )
	ui.BuildParamsScrollSlider:SetHandler( "OnValueChanged", function( self, value, eventReason )
		local scroll = ui.BuildParamsContainer
		local _, scrollHeight = scroll:GetScrollExtents()
		scroll:SetVerticalScroll( scrollHeight - ( scrollHeight - value ) )
		EHT.UI.UpdateScrollFade( scroll )
	end )

    local bg = EHT.CreateControl( nil, ui.BuildParamsScrollSlider, CT_BACKDROP )
	ui.BuildParamsScrollSlider.Backdrop = bg
    bg:SetCenterColor( 0, 0, 0 )
    bg:SetAnchor( TOPLEFT, ui.BuildParamsScrollSlider, TOPLEFT, 1, -16 )
    bg:SetAnchor( BOTTOMRIGHT, ui.BuildParamsScrollSlider, BOTTOMRIGHT, -1, 15 )
    bg:SetEdgeTexture( "EsoUI\\Art\\Tooltips\\UI-SliderBackdrop.dds", 32, 4 )

	ui.BuildParamsScrollSliderUpButton = EHT.UI.CreateTextureButton(
		prefix .. "BuildParamsScrollSliderUpButton",
		parent,
		"esoui/art/miscellaneous/gamepad/gp_scrollarrow_up.dds",
		15, 15,
		{ { BOTTOM, ui.BuildParamsScrollSlider, TOP, 0, 0 } },
		function() local value = ui.BuildParamsScrollSlider:GetValue() ui.BuildParamsScrollSlider:SetValue( value - 45 ) end )

	ui.BuildParamsScrollSliderDownButton = EHT.UI.CreateTextureButton(
		prefix .. "BuildParamsScrollSliderDownButton",
		parent,
		"esoui/art/miscellaneous/gamepad/gp_scrollarrow.dds",
		15, 15,
		{ { TOP, ui.BuildParamsScrollSlider, BOTTOM, 0, 0 } },
		function() local value = ui.BuildParamsScrollSlider:GetValue() if 0 == value then value = 20 end ui.BuildParamsScrollSlider:SetValue( value + 45 ) end )


	local width = ui.BuildParamsSection:GetWidth()
	local bps = ui.BuildParamsSection
	local bp = { }
	local tabFunc = EHT.UI.TabToNextBuildParameter
	ui.BuildParams = bp

	local function setRandom( c, step, valMin, valMax )
		c.RandomUnit = step
		c.RandomMin = valMin
		c.RandomMax = valMax
	end


	bp.ShapeDimensionsHeading = EHT.UI.CreateHeading( prefix .. "ShapeDimensionsHeading", bps, "Overall Dimensions" )
	bp.ShapeDimensionsHeading:SetMouseEnabled( true )
	tip( bp.ShapeDimensionsHeading, "|cffffaaOverall Dimensions|r allow you to customize options that are specific to the Shape template that you selected above." )

	bp.ItemCount = EHT.UI.CreateSlider( prefix .. "BuildItemCount", "Item Count", "items", bps, EHT.UI.BuildParamsChanged,
		1, 2000, 1, 0, false, tabFunc )
	bp.ItemCount:SetWidth( width )
	tip( bp.ItemCount, "The number of Items used in construction.\n\n" ..
		"Enter a number |caaffffless than|r the number of items in your selection to construct with fewer items.\n\n" ..
		"Enter a number |caaffffgreater than|r the number of items in your selection to simulate motion.\n\n" ..
		"|ce0e0e0* This is particularly useful while you are recording an animation.|r" )


	local msg = EHT.CreateControl( prefix .. "BuildMessageParam", bps, CT_CONTROL )
	bp.Message = msg
	msg:SetDimensions( width, 50 )
	msg.IsParam = true

	msg.Label = EHT.CreateControl( nil, msg, CT_LABEL ) 
	msg.Label:SetFont( "ZoFontWinH5" )
	msg.Label:SetAnchor( RIGHT, msg, CENTER, -5, 0 )
	msg.Label:SetHorizontalAlignment( TEXT_ALIGN_RIGHT )
	msg.Label:SetVerticalAlignment( TEXT_ALIGN_CENTER )
	msg.Label:SetText( "Message" )

	msg.Backdrop = WINDOW_MANAGER:CreateControlFromVirtual( nil, msg, "ZO_EditBackdrop" )
	msg.Backdrop:SetAnchor( TOPLEFT, msg, TOP, 5, 8 )
	msg.Backdrop:SetAnchor( BOTTOMRIGHT, msg, BOTTOMRIGHT, -2, -8 )

	msg.Value = WINDOW_MANAGER:CreateControlFromVirtual( nil, msg.Backdrop, "ZO_DefaultEditForBackdrop" ) 
	msg.Value:SetFont( "$(CHAT_FONT)|$(KB_14)" )
	msg.Value:SetAnchor( TOPLEFT, msg.Backdrop, TOPLEFT, 4, 0 )
	msg.Value:SetAnchor( BOTTOMRIGHT, msg.Backdrop, BOTTOMRIGHT, -4, 0 )
	msg.Value:SetMaxInputChars( 500 )
	msg.Value:SetMultiLine( true )
	msg.Value:SetHandler( "OnFocusLost", EHT.UI.BuildParamsChanged )
	msg.Value:SetHandler( "OnEnter", function( ... ) end )
	tip( msg.Value, "The message to construct from the items in your selection.\n\nMessage length limit will vary by the number of items in your selection as well as the specific letters, digits and punctuation used." )

	bp.CharacterSpacing = EHT.UI.CreateSlider( prefix .. "CharacterSpacing", "Character Spacing", "meters", bps, EHT.UI.BuildParamsChanged,
		0, 10, 0.01, 2, false, tabFunc )
	bp.CharacterSpacing:SetWidth( width )
	setRandom( bp.CharacterSpacing, 1, 3, 10 )
	tip( bp.CharacterSpacing, "The distance between each letter, measured in meters." )

	bp.LineSpacing = EHT.UI.CreateSlider( prefix .. "LineSpacing", "Line Spacing", "meters", bps, EHT.UI.BuildParamsChanged,
		0, 10, 0.01, 2, false, tabFunc )
	bp.LineSpacing:SetWidth( width )
	setRandom( bp.LineSpacing, 1, 3, 10 )
	tip( bp.LineSpacing, "The distance between each line for multi-line messages, measured in meters." )

	bp.EllipseParam = EHT.CreateControl( prefix .. "BuildEllipseParam", bps, CT_CONTROL )
	local mrp = bp.EllipseParam
	mrp:SetWidth( width )
	mrp:SetHeight( 40 )
	mrp.IsParam = true

	bp.Ellipse = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "BuildEllipse", mrp, "ZO_CheckButton" )
	local mr = bp.Ellipse
	mr:SetAnchor( TOPLEFT, mrp, TOPLEFT, 0, 15 )
	ZO_CheckButton_SetLabelText( mr, "Elliptical" )
	mr.label:SetFont( "ZoFontWinH5" )
	ZO_CheckButton_SetToggleFunction( mr, function( ctrl ) EHT.UI.BuildParamEllipseChanged( ctrl, false ) end )
	ZO_CheckButton_SetCheckState( mr, true )

	bp.Radius = EHT.UI.CreateSlider( prefix .. "BuildRadius", "Radius", "meters", bps, EHT.UI.BuildParamsChanged,
		0.00, 150, 0.01, 2, false, tabFunc )
	bp.Radius:SetWidth( width )
	setRandom( bp.Radius, 0.5, 0, 5 )
	tip( bp.Radius, "The Radius of the shape, measured in meters." )

	bp.RadiusX = EHT.UI.CreateSlider( prefix .. "BuildRadiusX", "Radius (X)", "meters", bps, EHT.UI.BuildParamsChanged,
		0.00, 150, 0.01, 2, false, tabFunc )
	bp.RadiusX:SetWidth( width )
	setRandom( bp.RadiusX, 0.5, 0, 5 )
	tip( bp.RadiusX, "The X-axis Radius of the shape, measured in meters." )

	bp.RadiusY = EHT.UI.CreateSlider( prefix .. "BuildRadiusY", "Radius (Y)", "meters", bps, EHT.UI.BuildParamsChanged,
		0.00, 150, 0.01, 2, false, tabFunc )
	bp.RadiusY:SetWidth( width )
	setRandom( bp.RadiusY, 0.5, 0, 5 )
	tip( bp.RadiusY, "The Y-axis Radius of the shape, measured in meters." )

	bp.RadiusZ = EHT.UI.CreateSlider( prefix .. "BuildRadiusZ", "Radius (Z)", "meters", bps, EHT.UI.BuildParamsChanged,
		0.00, 150, 0.01, 2, false, tabFunc )
	bp.RadiusZ:SetWidth( width )
	setRandom( bp.RadiusZ, 0.5, 0, 5 )
	tip( bp.RadiusZ, "The Z-axis Radius of the shape, measured in meters." )

	bp.RadiusStart = EHT.UI.CreateSlider( prefix .. "BuildRadiusStart", "Radius (Start)", "meters", bps, EHT.UI.BuildParamsChanged,
		0.00, 100, 0.01, 2, false, tabFunc )
	bp.RadiusStart:SetWidth( width )
	setRandom( bp.RadiusStart, 0.5, 0, 5 )
	tip( bp.RadiusStart, "The initial Radius of the shape, measured in meters.\n\nExample: You may create a cone-shaped Spiral using a larger Start Radius (ex: 5.0m) and a smaller End Radius (ex: 1.0m)." )

	bp.RadiusEnd = EHT.UI.CreateSlider( prefix .. "BuildRadiusEnd", "Radius (End)", "meters", bps, EHT.UI.BuildParamsChanged,
		0.00, 100, 0.01, 2, false, tabFunc )
	bp.RadiusEnd:SetWidth( width )
	setRandom( bp.RadiusEnd, 0.5, 0, 5 )
	tip( bp.RadiusEnd, "The final Radius of the shape, measured in meters.\n\nExample: You may create a cone-shaped Spiral using a larger Start Radius (ex: 5.0m) and a smaller End Radius (ex: 1.0m)." )

	bp.ArcLength = EHT.UI.CreateSlider( prefix .. "BuildArcLength", "Arc Length", "degrees", bps, EHT.UI.BuildParamsChanged,
		0.00, 360, 0.01, 2, false, tabFunc )
	bp.ArcLength:SetWidth( width )
	tip( bp.ArcLength, "The measure of the shape's circumference in degrees.\n\nExample: A full circle uses an Arc Length of 360 degrees.\nExample: A half circle uses an Arc Length of 180 degrees." )

	bp.Circumference = EHT.UI.CreateSlider( prefix .. "BuildCircumference", "Circumference", "items", bps, EHT.UI.BuildParamsChanged,
		0, 100, 1, 0, false, tabFunc )
	bp.Circumference:SetWidth( width )
	tip( bp.Circumference, "The number of items placed around the Circumference of the shape.\n\nNote:\nFor shapes that use a Start Radius and End Radius, the Circumference is the number of items placed at the Start Radius.\nIn this case, the number of items placed would increase or decrease automatically as the shape approached the End Radius." )

	bp.Length = EHT.UI.CreateSlider( prefix .. "BuildLength", "Length", "items", bps, EHT.UI.BuildParamsChanged,
		0, 100, 1, 0, false, tabFunc )
	bp.Length:SetWidth( width )
	setRandom( bp.Length, 1, 3, 20 )
	tip( bp.Length, "The number of items placed along the Length of the shape." )

	bp.Width = EHT.UI.CreateSlider( prefix .. "BuildWidth", "Width", "items", bps, EHT.UI.BuildParamsChanged,
		0, 100, 1, 0, false, tabFunc )
	bp.Width:SetWidth( width )
	setRandom( bp.Width, 1, 3, 20 )
	tip( bp.Width, "The number of items placed along the Width of the shape." )

	bp.Height = EHT.UI.CreateSlider( prefix .. "BuildHeight", "Height", "items", bps, EHT.UI.BuildParamsChanged,
		0, 100, 1, 0, false, tabFunc )
	bp.Height:SetWidth( width )
	setRandom( bp.Height, 1, 3, 20 )
	tip( bp.Height, "The number of items placed along the Height of the shape." )


	bp.ItemOrientationHeading = EHT.UI.CreateHeading( prefix .. "ItemOrientationHeading", bps, "Item Orientation" )
	bp.ItemOrientationHeading:SetMouseEnabled( true )
	tip( bp.ItemOrientationHeading, "|cffffaaItem Orientation|r allows you to control the orientation of the individual items.\n\nFor example, you can rotate the individual items by adjusting the |caaffffItem Yaw|r." )

	bp.ItemPitch = EHT.UI.CreateSlider( prefix .. "BuildItemPitch", "Item Pitch", "degrees", bps, EHT.UI.BuildParamsChanged,
		0.00, 360, 0.01, 2, false, tabFunc )
	bp.ItemPitch:SetWidth( width )
	setRandom( bp.ItemPitch, 20, 0, 360 )
	tip( bp.ItemPitch, "The initial Pitch of the first item in the shape, measured in degrees. Adjusting this will typically pitch the item forward or backward." )

	bp.ItemYaw = EHT.UI.CreateSlider( prefix .. "BuildItemYaw", "Item Yaw", "degrees", bps, EHT.UI.BuildParamsChanged,
		0.00, 360, 0.01, 2, false, tabFunc )
	bp.ItemYaw:SetWidth( width )
	setRandom( bp.ItemYaw, 20, 0, 360 )
	tip( bp.ItemYaw, "The initial Yaw of the first item in the shape, measured in degrees. Adjusting this will typically rotate the item left or right." )

	bp.ItemRoll = EHT.UI.CreateSlider( prefix .. "BuildItemRoll", "Item Roll", "degrees", bps, EHT.UI.BuildParamsChanged,
		0.00, 360, 0.01, 2, false, tabFunc )
	bp.ItemRoll:SetWidth( width )
	bp.ItemRoll.RandomUnit = 15
	setRandom( bp.ItemRoll, 20, 0, 360 )
	tip( bp.ItemRoll, "The initial Roll of the first item in the shape, measured in degrees. Adjusting this will typically roll the item on its left or right side." )


	bp.ItemSpacingHeading = EHT.UI.CreateHeading( prefix .. "ItemSpacingHeading", bps, "Item Spacing" )
	bp.ItemSpacingHeading:SetMouseEnabled( true )
	tip( bp.ItemSpacingHeading, "|cffffaaItem Spacing|r allows you to control the space between each individual item." )

	bp.ItemSpacingLength = EHT.UI.CreateSlider( prefix .. "BuildItemSpacingLength", "Length", "meters", bps, EHT.UI.BuildParamsChanged,
		-10, 10, 0.01, 2, false, tabFunc )
	bp.ItemSpacingLength:SetWidth( width )
	tip( bp.ItemSpacingLength, "The space between items along the Length, measured in meters." )

	bp.ItemSpacingWidth = EHT.UI.CreateSlider( prefix .. "BuildItemSpacingWidth", "Width", "meters", bps, EHT.UI.BuildParamsChanged,
		-10, 10, 0.01, 2, false, tabFunc )
	bp.ItemSpacingWidth:SetWidth( width )
	tip( bp.ItemSpacingWidth, "The space between items along the Width, measured in meters." )

	bp.ItemSpacingHeight = EHT.UI.CreateSlider( prefix .. "BuildItemSpacingHeight", "Height", "meters", bps, EHT.UI.BuildParamsChanged,
		-10, 10, 0.01, 2, false, tabFunc )
	bp.ItemSpacingHeight:SetWidth( width )
	tip( bp.ItemSpacingHeight, "The space between items along the Height, measured in meters." )

	bp.ItemSpacingAuto = EHT.CreateControl( prefix .. "BuildItemSpacingAuto", bps, CT_CONTROL )
	local as = bp.ItemSpacingAuto
	as:SetWidth( width )
	as:SetHeight( 40 )
	as.IsParam = true

	as.AutoSpacing = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "BuildAutoSpacing", as, "ZO_CheckButton" )
	as.AutoSpacing:SetAnchor( TOPLEFT, as, TOPLEFT, 0, 15 )
	ZO_CheckButton_SetLabelText( as.AutoSpacing, "Space items automatically based on Item Count" )
	as.AutoSpacing.label:SetFont( "ZoFontWinH5" )
	ZO_CheckButton_SetToggleFunction( as.AutoSpacing, function( ctrl ) EHT.UI.BuildParamAutoSpacingChanged( ctrl, false ) end )
	ZO_CheckButton_SetCheckState( as.AutoSpacing, true )

	bp.CheckerPattern = EHT.CreateControl( prefix .. "BuildCheckerPattern", bps, CT_CONTROL )
	local checker = bp.CheckerPattern
	checker:SetWidth( width )
	checker:SetHeight( 40 )
	checker.IsParam = true

	checker.CheckerPatternEnabled = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "BuildCheckerPatternEnabled", checker, "ZO_CheckButton" )
	checker.CheckerPatternEnabled:SetAnchor( TOPLEFT, checker, TOPLEFT, 0, 15 )
	ZO_CheckButton_SetLabelText( checker.CheckerPatternEnabled, "Layout items in a Checker pattern" )
	checker.CheckerPatternEnabled.label:SetFont( "ZoFontWinH5" )
	ZO_CheckButton_SetToggleFunction( checker.CheckerPatternEnabled, EHT.UI.BuildParamsChanged )
	ZO_CheckButton_SetCheckState( checker.CheckerPatternEnabled, false )

	bp.ReverseSort = EHT.CreateControl( prefix .. "BuildReverseSort", bps, CT_CONTROL )
	local reverseSort = bp.ReverseSort
	reverseSort:SetWidth( width )
	reverseSort:SetHeight( 40 )
	reverseSort.IsParam = true

	reverseSort.ReverseSortEnabled = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "BuildReverseSortEnabled", reverseSort, "ZO_CheckButton" )
	reverseSort.ReverseSortEnabled:SetAnchor( TOPLEFT, reverseSort, TOPLEFT, 0, 15 )
	ZO_CheckButton_SetLabelText( reverseSort.ReverseSortEnabled, "Sort in reverse alphabetical order" )
	reverseSort.ReverseSortEnabled.label:SetFont( "ZoFontWinH5" )
	ZO_CheckButton_SetToggleFunction( reverseSort.ReverseSortEnabled, EHT.UI.BuildParamsChanged )
	ZO_CheckButton_SetCheckState( reverseSort.ReverseSortEnabled, false )


	bp.ItemDimensionsHeading = EHT.UI.CreateHeading( prefix .. "ItemDimensionsHeading", bps, "Item Dimensions" )
	bp.ItemDimensionsHeading:SetMouseEnabled( true )
	tip( bp.ItemDimensionsHeading, "|cffffaaItem Dimensions|r specify the length, width and height of one individual item.\n\nThis is set automatically whenever you click |caaffffReset|r; you can also automatically measure your selected item(s) by clicking |caaffffMeasure|r." )

	bp.ItemLength = EHT.UI.CreateSlider( prefix .. "BuildItemLength", "Item Length", "meters", bps, EHT.UI.BuildParamsChanged,
		0, 50, 0.01, 2, false, tabFunc )
	bp.ItemLength:SetWidth( width )
	tip( bp.ItemLength, "The Length of a single item, measured in meters.\nAdjusting this value can increase or decrease the space between individual items.\n\nNote: The Length is auto-populated with the measured length of the first item in your selection." )

	bp.ItemWidth = EHT.UI.CreateSlider( prefix .. "BuildItemWidth", "Item Width", "meters", bps, EHT.UI.BuildParamsChanged,
		0, 50, 0.01, 2, false, tabFunc )
	bp.ItemWidth:SetWidth( width )
	tip( bp.ItemWidth, "The Width of a single item, measured in meters.\nAdjusting this value can increase or decrease the space between individual items.\n\nNote: The Width is auto-populated with the measured width of the first item in your selection." )

	bp.ItemHeight = EHT.UI.CreateSlider( prefix .. "BuildItemHeight", "Item Height", "meters", bps, EHT.UI.BuildParamsChanged,
		0, 50, 0.01, 2, false, tabFunc )
	bp.ItemHeight:SetWidth( width )
	tip( bp.ItemHeight, "The Height of a single item, measured in meters.\nAdjusting this value can increase or decrease the space between individual items.\n\nNote: The Height is auto-populated with the measured height of the first item in your selection." )


	bp.ShapeOrientationHeading = EHT.UI.CreateHeading( prefix .. "ShapeOrientationHeading", bps, "Overall Orientation" )
	bp.ShapeOrientationHeading:SetMouseEnabled( true )
	tip( bp.ShapeOrientationHeading, "|cffffaaOverall Orientation|r allows you to control the orientation of the entire shape that you are building.\n\nFor example, if you are building a Floor, you can rotate the entire floor by adjusting the |caaffffYaw|r.\n\nNote: While you are in the |caaffffBuilds|r tab, you may use the Directional Pads at the bottom to adjust the orientation of your shape." )

	bp.Pitch = EHT.UI.CreateSlider( prefix .. "BuildPitch", "Pitch", "degrees", bps, EHT.UI.BuildParamsChanged,
		0.00, 360, 0.01, 2, false, tabFunc )
	bp.Pitch:SetWidth( width )
	setRandom( bp.Pitch, 20, 0, 360 )
	tip( bp.Pitch, "The overall Pitch of the shape, measured in degrees. Adjusting this will typically pitch the entire shape forwards or backwards." )

	bp.Yaw = EHT.UI.CreateSlider( prefix .. "BuildYaw", "Yaw", "degrees", bps, EHT.UI.BuildParamsChanged,
		0.00, 360, 0.01, 2, false, tabFunc )
	bp.Yaw:SetWidth( width )
	setRandom( bp.Yaw, 20, 0, 360 )
	tip( bp.Yaw, "The overall Yaw of the shape, measured in degrees. Adjusting this will typically rotate the entire shape left or right." )

	bp.Roll = EHT.UI.CreateSlider( prefix .. "BuildRoll", "Roll", "degrees", bps, EHT.UI.BuildParamsChanged,
		0.00, 360, 0.01, 2, false, tabFunc )
	bp.Roll:SetWidth( width )
	setRandom( bp.Roll, 20, 0, 360 )
	tip( bp.Roll, "The overall Roll of the shape, measured in degrees. Adjusting this will typically roll the entire shape on its left or right side." )


	bp.ShapePositionHeading = EHT.UI.CreateHeading( prefix .. "ShapePositionHeading", bps, "Overall Position" )
	bp.ShapePositionHeading:SetMouseEnabled( true )
	tip( bp.ShapePositionHeading, "|cffffaaOverall Position|r allows you to change the position of the entire shape that you are building.\n\nFor example, if you are building a Wall, you can use the |cffffaaOverall Position|r options to relocate the wall.\n\nNote: While you are in the |caaffffBuilds|r tab, you may use the Directional Pads at the bottom to adjust the position of your shape." )

	bp.X = EHT.UI.CreateSlider( prefix .. "BuildX", "X", "meters", bps, EHT.UI.BuildParamsChanged,
		0, 2500, 0.01, 2, false, tabFunc )
	bp.X:SetWidth( width )
	tip( bp.X, "The X-axis Position of the overall shape, measured in meters. Adjusting this will move the entire shape east or west." )

	bp.Y = EHT.UI.CreateSlider( prefix .. "BuildY", "Y", "meters", bps, EHT.UI.BuildParamsChanged,
		0, 2500, 0.01, 2, false, tabFunc )
	bp.Y:SetWidth( width )
	tip( bp.Y, "The Y-axis Position of the overall shape, measured in meters. Adjusting this will move the entire shape up or down." )

	bp.Z = EHT.UI.CreateSlider( prefix .. "BuildZ", "Z", "meters", bps, EHT.UI.BuildParamsChanged,
		0, 2500, 0.01, 2, false, tabFunc )
	bp.Z:SetWidth( width )
	tip( bp.Z, "The Z-axis Position of the overall shape, measured in meters. Adjusting this will move the entire shape north or south." )


	ui.BuildParamsContainer:SetDrawTier( DT_HIGH )
	ui.BuildParamsContainer:SetDrawLayer( DL_CONTROLS )
end

local DIRECTIONAL_PAD_OFFSET = 40

function EHT.UI.UpdateDirectionalPadHeading()
	local ui = EHT.UI.ToolDialog
	local button = ui.ToggleDirectionalMode
	if button:IsHidden() then
		EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.UpdateDirectionalPadHeading" )
		return
	end

	local heading = RAD360 - EHT.Biz.GetEditorHeading()
	if EHT.Biz.IsCardinalPositionMode() then
		local north = ui.DirectionalModeNorth
		local south = ui.DirectionalModeSouth
		local east = ui.DirectionalModeEast
		local west = ui.DirectionalModeWest

		north:ClearAnchors()
		south:ClearAnchors()
		east:ClearAnchors()
		west:ClearAnchors()

		do
			local x, y = sin(heading), cos(heading)
			south:SetAnchor(CENTER, button, CENTER, x * DIRECTIONAL_PAD_OFFSET, y * DIRECTIONAL_PAD_OFFSET)
			north:SetAnchor(CENTER, button, CENTER, -x * DIRECTIONAL_PAD_OFFSET, -y * DIRECTIONAL_PAD_OFFSET)

			local scale = zo_max(0.5, -y * .5 + .5)
			south:SetScale(scale)
			south:SetColor(scale, scale, scale, 1)
			scale = zo_max(0.5, y * .5 + .5)
			north:SetScale(scale)
			north:SetColor(scale, scale, scale, 1)
		end

		do
			heading = heading + RAD90
			local x, y = sin(heading), cos(heading)
			east:SetAnchor(CENTER, button, CENTER, x * DIRECTIONAL_PAD_OFFSET, y * DIRECTIONAL_PAD_OFFSET)
			west:SetAnchor(CENTER, button, CENTER, -x * DIRECTIONAL_PAD_OFFSET, -y * DIRECTIONAL_PAD_OFFSET)

			local scale = zo_max(0.5, -y * .5 + .5)
			east:SetScale(scale)
			east:SetColor(scale, scale, scale, 1)
			scale = zo_max(0.5, y * .5 + .5)
			west:SetScale(scale)
			west:SetColor(scale, scale, scale, 1)
		end
	else
		EHT.World.RotateTexture( ui.ToggleDirectionalMode, heading )
	end
end

function EHT.UI.RefreshDirectionalPad( showTooltip )
	local ui = EHT.UI.ToolDialog
	if ui then
		local isCardinal = EHT.Biz.IsCardinalPositionMode()
		local isRelative = not isCardinal
		local isUnitHeadingRelative = isRelative and EHT.Biz.DoesRelativePositionUseUnitHeading()
		local control = ui.ToggleDirectionalMode
		local modeDirections = isRelative and "Forward / Backward / Left / Right" or "North / South / East / West"
		local tooltipText = string.format( "|cffffffMove selected items using\n|c88ffff%s|r", modeDirections )

		EHT.UI.ClearInfoTooltip( control )
		EHT.UI.SetInfoTooltip( control, tooltipText, TOPLEFT, 0, 10, BOTTOMLEFT, ui.Window, showTooltip )
		EHT.World.RotateTexture( control, 0 )

		ui.DirectionalModeNorth:ClearAnchors()
		ui.DirectionalModeNorth:SetAnchor( CENTER, control, CENTER, 0, -DIRECTIONAL_PAD_OFFSET )
		ui.DirectionalModeNorth:SetScale( 1.5 )

		ui.DirectionalModeSouth:ClearAnchors()
		ui.DirectionalModeSouth:SetAnchor( CENTER, control, CENTER, 0, DIRECTIONAL_PAD_OFFSET )
		ui.DirectionalModeSouth:SetScale( 0.85 )

		ui.DirectionalModeEast:ClearAnchors()
		ui.DirectionalModeEast:SetAnchor( CENTER, control, CENTER, DIRECTIONAL_PAD_OFFSET, 0 )
		ui.DirectionalModeEast:SetScale( 1.175 )

		ui.DirectionalModeWest:ClearAnchors()
		ui.DirectionalModeWest:SetAnchor( CENTER, control, CENTER, -DIRECTIONAL_PAD_OFFSET, 0 )
		ui.DirectionalModeWest:SetScale( 1.175 )

		ui.CardinalGroup:SetHidden( not isCardinal )
		ui.RelationalGroup:SetHidden( isCardinal )
	end
end

function EHT.UI.RefreshSelectionLinkItemsMode( showTooltip )
	local ui = EHT.UI.ToolDialog
	if ui then
		local enabled = EHT.SavedVars.SelectionLinkItems == true
		local texture = enabled and EHT.Textures.ICON_LINK_GROUP or EHT.Textures.ICON_UNLINK_GROUP
		local tooltipText = string.format( "|cffffffManually move any selected item to\n|c88ffff%s", enabled and "move all selected items as a group" or "adjust that individual item" )

		ui.LinkItemsToggle:SetTexture( texture )
		EHT.UI.SetInfoTooltip( ui.LinkItemsToggle, tooltipText, TOPRIGHT, 0, 10, BOTTOMRIGHT, ui.Window, showTooltip )
	end
end

function EHT.UI.ToggleGroup( state )
	local _, group = EHT.Data.GetCurrentHouse()
	EHT.Biz.SetFurnitureStates( state, nil, group )
end

local skipArrangeRequests = false

function EHT.UI.ArrangeSelectedItems(ctrl, opt)
	if skipArrangeRequests then return end

	if nil == ctrl or nil == opt or "" == opt then return end
	if EHT.Biz.IsProcessRunning() then return end

	opt = EHT.Util.Trim( opt )
	if EHT.Biz.IsDefaultOperation( opt ) or opt == "Arrange this build..." then return end

	EHT.UI.InitChooseAnItem()

	local groupOps = EHT.CONST.GROUP_OPERATIONS

	if opt == groupOps.LINK_OPERATIONS.LINK_GROUP then
		EHT.Biz.LinkGroup()
	elseif opt == groupOps.LINK_OPERATIONS.UNLINK_GROUP then
		EHT.Biz.UnlinkGroup()
	end

	if opt == groupOps.CLIPBOARD_OPERATIONS.CUT_GROUP then
		EHT.UI.CutSelectionToClipboard( true )
	elseif opt == groupOps.CLIPBOARD_OPERATIONS.CUT_COPY_GROUP then
		EHT.UI.CutSelectionToClipboard( false )
	elseif opt == groupOps.CLIPBOARD_OPERATIONS.COPY_GROUP then
		EHT.UI.CopySelectionToClipboard()
	elseif opt == groupOps.CLIPBOARD_OPERATIONS.PASTE_GROUP then
		EHT.UI.PasteFromInventory()
	end

	if opt == groupOps.A_SUMMON_OPERATION.BRING_TO_ME then
		EHT.Biz.ArrangeBringToMe()
	end

	if opt == groupOps.ALIGN_OPERATIONS.CENTER_ON_TARGET then
		EHT.UI.ChooseAnItem( EHT.Biz.ArrangeCenterOnTarget )
	elseif opt == groupOps.ALIGN_OPERATIONS.CENTER_BETWEEN_2_TARGETS then
		EHT.UI.ChooseAnItem( function( furnitureId1 ) EHT.UI.ChooseAnItem( EHT.Biz.ArrangeCenterBetweenTargets, furnitureId1, nil, nil, "Select 2nd item" ) end, nil, nil, nil, "Select 1st item" )
	elseif opt == groupOps.ALIGN_OPERATIONS.LEVEL_EACH_WITH_TARGET then
		EHT.UI.ChooseAnItem( EHT.Biz.ArrangeLevelEachWithTarget )
	elseif opt == groupOps.ALIGN_OPERATIONS.LEVEL_GROUP_WITH_TARGET then
		EHT.UI.ChooseAnItem( EHT.Biz.ArrangeLevelGroupWithTarget )
	elseif opt == groupOps.ALIGN_OPERATIONS.ALIGN_EACH_WITH_TARGET_AXIS_X then
		EHT.UI.ChooseAnItem( function( furnitureId ) EHT.Biz.ArrangeAlignEachWithTargetAxis( furnitureId, true, false, false ) end )
	elseif opt == groupOps.ALIGN_OPERATIONS.ALIGN_EACH_WITH_TARGET_AXIS_Y then
		EHT.UI.ChooseAnItem( function( furnitureId ) EHT.Biz.ArrangeAlignEachWithTargetAxis( furnitureId, false, true, false ) end )
	elseif opt == groupOps.ALIGN_OPERATIONS.ALIGN_EACH_WITH_TARGET_AXIS_Z then
		EHT.UI.ChooseAnItem( function( furnitureId ) EHT.Biz.ArrangeAlignEachWithTargetAxis( furnitureId, false, false, true ) end )
	elseif opt == groupOps.ALIGN_OPERATIONS.ALIGN_GROUP_WITH_TARGET_AXIS_X then
		EHT.UI.ChooseAnItem( function( furnitureId ) EHT.Biz.ArrangeAlignGroupWithTargetAxis( furnitureId, true, false, false ) end )
	elseif opt == groupOps.ALIGN_OPERATIONS.ALIGN_GROUP_WITH_TARGET_AXIS_Y then
		EHT.UI.ChooseAnItem( function( furnitureId ) EHT.Biz.ArrangeAlignGroupWithTargetAxis( furnitureId, false, true, false ) end )
	elseif opt == groupOps.ALIGN_OPERATIONS.ALIGN_GROUP_WITH_TARGET_AXIS_Z then
		EHT.UI.ChooseAnItem( function( furnitureId ) EHT.Biz.ArrangeAlignGroupWithTargetAxis( furnitureId, false, false, true ) end )
	end

	if opt == groupOps.ARRANGE_OPERATIONS.FLIP_GROUP_ON_X_AXIS then
		EHT.Biz.FlipSelectedFurniture( EHT.CONST.AXIS.X )
	elseif opt == groupOps.ARRANGE_OPERATIONS.FLIP_GROUP_ON_Y_AXIS then
		EHT.Biz.FlipSelectedFurniture( EHT.CONST.AXIS.Y )
	elseif opt == groupOps.ARRANGE_OPERATIONS.FLIP_GROUP_ON_Z_AXIS then
		EHT.Biz.FlipSelectedFurniture( EHT.CONST.AXIS.Z )
	elseif opt == groupOps.ARRANGE_OPERATIONS.MATCH_TARGET_ORIENTATION then
		EHT.UI.ChooseAnItem( EHT.Biz.ArrangeMatchTargetOrientation )
	elseif opt == groupOps.ARRANGE_OPERATIONS.RESET_EACH_ORIENTATION then
		EHT.Biz.ArrangeResetEachOrientation()
	elseif opt == groupOps.ARRANGE_OPERATIONS.STACK_IN_1_GROUP then
		EHT.UI.StackInGroups( 1 )
	elseif opt == groupOps.ARRANGE_OPERATIONS.STACK_IN_2_GROUPS then
		EHT.UI.StackInGroups( 2 )
	elseif opt == groupOps.ARRANGE_OPERATIONS.STACK_IN_4_GROUPS then
		EHT.UI.StackInGroups( 4 )
	end

	if opt == groupOps.STATE_OPERATIONS.TOGGLE_STATE then
		EHT.UI.ToggleGroup( EHT.STATE.TOGGLE )
	elseif opt == groupOps.STATE_OPERATIONS.SET_STATE_OFF then
		EHT.UI.ToggleGroup( EHT.STATE.OFF )
	elseif opt == groupOps.STATE_OPERATIONS.SET_STATE_ON then
		EHT.UI.ToggleGroup( EHT.STATE.ON )
	elseif opt == groupOps.STATE_OPERATIONS.SET_STATE_ON2 then
		EHT.UI.ToggleGroup( EHT.STATE.ON2 )
	elseif opt == groupOps.STATE_OPERATIONS.SET_STATE_ON3 then
		EHT.UI.ToggleGroup( EHT.STATE.ON3 )
	elseif opt == groupOps.STATE_OPERATIONS.SET_STATE_ON4 then
		EHT.UI.ToggleGroup( EHT.STATE.ON4 )
	elseif opt == groupOps.STATE_OPERATIONS.SET_STATE_ON5 then
		EHT.UI.ToggleGroup( EHT.STATE.ON5 )
	end

	if opt == groupOps.ORDER_OPERATIONS.GROUP_BY_NAME_ASC then
		EHT.Biz.SortGroup( true )
	elseif opt == groupOps.ORDER_OPERATIONS.GROUP_BY_NAME_DESC then
		EHT.Biz.SortGroup( false )
	elseif opt == groupOps.ORDER_OPERATIONS.ORDER_BY_DISTANCE_ASC then
		EHT.Biz.SortGroupByDistance( true )
	elseif opt == groupOps.ORDER_OPERATIONS.ORDER_BY_DISTANCE_DESC then
		EHT.Biz.SortGroupByDistance( false )
	elseif opt == groupOps.ORDER_OPERATIONS.ALTERNATE_BY_NAME_ASC then
		EHT.Biz.AlternateGroup( true )
	elseif opt == groupOps.ORDER_OPERATIONS.ALTERNATE_BY_NAME_DESC then
		EHT.Biz.AlternateGroup( false )
	elseif opt == groupOps.ORDER_OPERATIONS.DESELECT_EVEN_ITEMS then
		EHT.UI.DeselectAlternateItems( 2 )
	elseif opt == groupOps.ORDER_OPERATIONS.DESELECT_ODD_ITEMS then
		EHT.UI.DeselectAlternateItems( 1 )
	elseif opt == groupOps.ORDER_OPERATIONS.REVERSE then
		EHT.UI.ReverseOrderItems()
	elseif opt == groupOps.ORDER_OPERATIONS.RANDOMIZE then
		EHT.UI.RandomlyOrderItems()
	end

	local sceneOps = EHT.CONST.SCENE_OPERATIONS

	if opt == sceneOps.ARRANGE_OPERATIONS.BRING_TO_ME and EHT.UI.CanEditAnimation() then
		EHT.Biz.ArrangeBringToMe()
	elseif opt == sceneOps.ARRANGE_OPERATIONS.CENTER_ON_TARGET and EHT.UI.CanEditAnimation() then
		EHT.UI.ChooseAnItem( EHT.Biz.ArrangeCenterOnTarget )
	elseif opt == sceneOps.ARRANGE_OPERATIONS.CENTER_BETWEEN_2_TARGETS and EHT.UI.CanEditAnimation() then
		EHT.UI.ChooseAnItem( function( furnitureId1 ) EHT.UI.ChooseAnItem( EHT.Biz.ArrangeCenterBetweenTargets, furnitureId1, nil, nil, "Select 2nd item" ) end, nil, nil, nil, "Select 1st item" )
	elseif opt == sceneOps.ARRANGE_OPERATIONS.ALIGN_SCENE_WITH_TARGET_AXIS_X and EHT.UI.CanEditAnimation() then
		EHT.UI.ChooseAnItem( function( furnitureId ) EHT.Biz.ArrangeAlignGroupWithTargetAxis( furnitureId, true, false, false ) end )
	elseif opt == sceneOps.ARRANGE_OPERATIONS.ALIGN_SCENE_WITH_TARGET_AXIS_Y and EHT.UI.CanEditAnimation() then
		EHT.UI.ChooseAnItem( function( furnitureId ) EHT.Biz.ArrangeAlignGroupWithTargetAxis( furnitureId, false, true, false ) end )
	elseif opt == sceneOps.ARRANGE_OPERATIONS.ALIGN_SCENE_WITH_TARGET_AXIS_Z and EHT.UI.CanEditAnimation() then
		EHT.UI.ChooseAnItem( function( furnitureId ) EHT.Biz.ArrangeAlignGroupWithTargetAxis( furnitureId, false, false, true ) end )
	end

	if opt == sceneOps.EDIT_OPERATIONS.COPY_SCENE and EHT.UI.CanEditAnimation() then
		EHT.UI.CloneScene()
	elseif opt == sceneOps.EDIT_OPERATIONS.MERGE_WITH_SCENE and EHT.UI.CanEditAnimation() then
		EHT.UI.ShowToolTab( EHT.CONST.TOOL_TABS.ANIMATE, EHT.CONST.TOOL_TABS_STATE.MERGE )
	elseif opt == sceneOps.EDIT_OPERATIONS.APPEND_WITH_SCENE and EHT.UI.CanEditAnimation() then
		EHT.UI.ShowToolTab( EHT.CONST.TOOL_TABS.ANIMATE, EHT.CONST.TOOL_TABS_STATE.APPEND )
	elseif opt == sceneOps.EDIT_OPERATIONS.REVERSE_SCENE and EHT.UI.CanEditAnimation() then
		EHT.UI.ReverseScene()
	end

	if opt == sceneOps.EDIT_ITEM_OPERATIONS.SELECT_ITEMS and EHT.UI.CanEditAnimation() then
		EHT.UI.SelectSceneItems()
	elseif opt == sceneOps.EDIT_ITEM_OPERATIONS.ADD_ITEMS and EHT.UI.CanEditAnimation() then
		EHT.UI.AddSelectionToScene()
	elseif opt == sceneOps.EDIT_ITEM_OPERATIONS.REMOVE_ITEMS and EHT.UI.CanEditAnimation() then
		EHT.UI.RemoveSelectionFromScene()
	end

	skipArrangeRequests = true

	zo_callLater(function()
		if ctrl and ctrl.SelectFirstItem then
			ctrl:SelectFirstItem()
		end

		skipArrangeRequests = false
	end, 1)
end

function EHT.UI.SetPrecisionInfoTooltip( showTooltip )
	local ui = EHT.UI.ToolDialog
	if ui then
		local precision = EHT.SavedVars.SelectionPrecision
		local coordPrecision = EHT.SavedVars.SelectionPrecisionMoveCustom
		local anglePrecision = EHT.SavedVars.SelectionPrecisionRotateCustom

		if not EHT.SavedVars.SelectionPrecisionUseCustom then
			coordPrecision, anglePrecision = EHT.Biz.GetPrecisionIncrements( precision )
			anglePrecision = math.deg( anglePrecision )
		end

		EHT.UI.SetInfoTooltip(
			ui.Precision,
			string.format( "|cffffffMove items by |c88ffff%s\n|cffffffRotate items by |c88ffff%.2f degrees", ( 100 > ( coordPrecision or 0 ) ) and string.format( "%d centimeters", coordPrecision or 0 ) or string.format( "%d meters", ( coordPrecision or 0 ) / 100 ), anglePrecision or 0 ),
			TOP, 0, 10, BOTTOM, ui.Window, showTooltip )
	end
end

function EHT.UI.SetupToolDialogEditTab( ui, parent, prefix, settings, source )
	local sourceEditFurniture = "EditFurniture" == source
	local editFunction = EHT.Biz.AdjustSelectedOrPositionedFurniture
	local grp, c, tipMsg

	local function tip( control, msg )
		EHT.UI.SetInfoTooltip( control, msg )
	end

	local angle = 0
	ui.EditButtons = {}

	local function onUpdate( c )
		local group = EHT.Data.GetCurrentGroup()

		c:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 1 + (c.isMouseDown and 1 or (c.isMouseOver and 0.5 or 0)))
		if ( c.isMouseDown or c.isMouseOver ) and group and 0 < #group then
			if c.directionOrientation then
				EHT.DirectionalIndicators:SetActive( c.isMouseDown )
				EHT.DirectionalIndicators:SetDirection( c.directionOrientation )
				EHT.DirectionalIndicators:SetHidden( false )
			end
		else
			EHT.DirectionalIndicators:SetHidden( true )
			EHT.DirectionalIndicators:SetActive( false )
		end
	end

	local function onMouseEnter( c )
		c.isMouseOver = true
		onUpdate( c )
	end

	local function onMouseExit( c )
		c.isMouseOver = false
		onUpdate( c )
	end

	local function onClick( c )
		if c.onClick then
			c.onClick()
		end
		onUpdate( c )
	end
	
	local function onMouseDown( c )
		EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.ToolDialog.OnEditMouseDown" )
		local group = EHT.Data.GetCurrentGroup()
		local delay = math.min( 1200, 100 + 100 * ("table" == type(group) and #group or 0) )
		EVENT_MANAGER:RegisterForUpdate( "EHT.UI.ToolDialog.OnEditMouseDown", delay, function() onClick( c ) end )

		c.isMouseDown = true
		onClick( c )
	end

	local function onMouseUp( c )
		EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.ToolDialog.OnEditMouseDown" )

		c.isMouseDown = false
		onUpdate( c )
	end

	local function onHidden( c )
		if c.isMouseDown then
			onMouseUp( c )
		end

		if c.isMouseOver then
			onMouseExit( c )
		end
	end

	local nextButtonIndex = 0
	local function getNextButtonControlName()
		local name = string.format("EHTToolDialogDirectionalButton%d", nextButtonIndex)
		nextButtonIndex = nextButtonIndex + 1
		return name
	end
-- /script C = WINDOW_MANAGER:GetMouseOverControl() d( C:GetName() )
-- /script d( 
-- /script d( EHT.UI.ToolDialog.RelationalGroup: )
-- /script d( EHT.UI.ToolDialog.EditButtons[1]:GetDrawLayer() )
	local function addButton(label, parent, directionOrientation, onClick)
		local b = EHT.CreateControl(getNextButtonControlName(), parent, CT_TEXTURE)
		b.directionOrientation = directionOrientation
		b.onClick = onClick
		SetColor(b, Colors.DirectionalButton)
		b:SetDimensions(50, 50)
		b:SetMouseEnabled(true)
		b:SetTexture(EHT.Textures.ARROW_3)
		b:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES)
		b:SetHandler("OnMouseEnter", onMouseEnter)
		b:SetHandler("OnMouseExit", onMouseExit)
		b:SetHandler("OnMouseDown", onMouseDown)
		b:SetHandler("OnMouseUp", onMouseUp)
		b:SetHandler("OnEffectivelyHidden", onHidden)
		b:SetDrawLevel( parent:GetDrawLevel() + 1)

		local l = EHT.CreateControl( nil, parent, CT_LABEL )
		b.Label = l
		SetColor(l, Colors.White)
		l:SetFont(Colors.DirectionalButtonLabelFont)
		l:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
		l:SetText(label)

		if 0 == angle then		b:SetTextureRotation( 0.5 * math.pi )	b:SetAnchor( TOP, parent, TOP, 0, 0 )			l:SetAnchor( BOTTOM, b, BOTTOM, 0, -4 )
		elseif 1 == angle then	b:SetTextureRotation( -0.5 * math.pi )	b:SetAnchor( BOTTOM, parent, BOTTOM, 0, 0 )		l:SetAnchor( TOP, b, TOP, 0, 4 )
		elseif 2 == angle then	b:SetTextureRotation( math.pi )			b:SetAnchor( LEFT, parent, LEFT, 0, 0 )			l:SetAnchor( RIGHT, b, RIGHT, -5, 0 )
		elseif 3 == angle then	b:SetTextureRotation( 0 )				b:SetAnchor( RIGHT, parent, RIGHT, 0, 0 )		l:SetAnchor( LEFT, b, LEFT, 5, 0 )
		end

		angle = ( angle + 1 ) % 4
		table.insert(ui.EditButtons, b)
	end

	-- Directional Controls

	ui.DirectionalControls = EHT.CreateControl( prefix .. "DirectionalControls", parent, CT_CONTROL )
	ui.DirectionalControls:SetAnchor( TOPLEFT, parent, TOPLEFT, 0, 0 )
	ui.DirectionalControls:SetAnchor( TOPRIGHT, parent, TOPRIGHT, 0, 0 )
	ui.DirectionalControls:SetHeight( 116 )
	ui.DirectionalControls:SetMouseEnabled(false)
	ui.DirectionalControls:SetDrawLevel( 250001 ) -- parent:GetDrawLevel() + 1 )

	ui.RelationalGroup = EHT.CreateControl( prefix .. "RelationalGroup", ui.DirectionalControls, CT_CONTROL )
	ui.RelationalGroup:SetAnchor( TOPLEFT, ui.DirectionalControls, TOPLEFT, -10, 0 )
	ui.RelationalGroup:SetDimensions( 130, 140 )
	ui.RelationalGroup:SetMouseEnabled(false)
	ui.RelationalGroup:SetDrawLevel( ui.DirectionalControls:GetDrawLevel() + 1 )

	addButton("Fwd", ui.RelationalGroup, "forward", function() editFunction( { Forward = 1 } ) end)
	addButton("Back", ui.RelationalGroup, "backward", function() editFunction( { Forward = -1 } ) end)
	addButton("Left", ui.RelationalGroup, "left", function() editFunction( { Left = 1 } ) end)
	addButton("Right", ui.RelationalGroup, "right", function() editFunction( { Left = -1 } ) end)

	if not sourceEditFurniture then 
		ui.CardinalGroup = EHT.CreateControl( prefix .. "CardinalGroup", ui.DirectionalControls, CT_CONTROL )
		ui.CardinalGroup:SetAnchor( TOPLEFT, ui.DirectionalControls, TOPLEFT, -10, 0 )
		ui.CardinalGroup:SetDimensions( 130, 140 )
		ui.CardinalGroup:SetMouseEnabled(false)

		addButton("North", ui.CardinalGroup, "forward", function() editFunction( { Z = -1 } ) end)
		addButton("South", ui.CardinalGroup, "backward", function() editFunction( { Z = 1 } ) end)
		addButton("West", ui.CardinalGroup, "left", function() editFunction( { X = -1 } ) end)
		addButton("East", ui.CardinalGroup, "right", function() editFunction( { X = 1 } ) end)
	end

	ui.PitchRollGroup = EHT.CreateControl( prefix .. "PitchRollGroup", ui.DirectionalControls, CT_CONTROL )
	ui.PitchRollGroup:SetDimensions( 130, 140 )
	ui.PitchRollGroup:SetAnchor( TOPRIGHT, ui.DirectionalControls, TOPRIGHT, 10, 0 )
	ui.PitchRollGroup:SetMouseEnabled(false)

	addButton("Pitch", ui.PitchRollGroup, "pitch-", function() editFunction( { Pitch = -1 } ) end)
	addButton("Pitch", ui.PitchRollGroup, "pitch+", function() editFunction( { Pitch = 1 } ) end)
	addButton("Roll", ui.PitchRollGroup, "roll+", function() editFunction( { Roll = 1 } ) end)
	addButton("Roll", ui.PitchRollGroup, "roll-", function() editFunction( { Roll = -1 } ) end)

	ui.RotationalGroup = EHT.CreateControl( prefix .. "RotationalGroup", ui.DirectionalControls, CT_CONTROL )
	ui.RotationalGroup:SetDimensions( 130, 140 )
	if not sourceEditFurniture then
		ui.RotationalGroup:SetAnchor( TOP, ui.DirectionalControls, TOP, 0, 0 )
	else
		ui.RotationalGroup:SetAnchor( TOP, ui.DirectionalControls, TOP, 0, 65 )
	end
	ui.RotationalGroup:SetMouseEnabled(false)

	addButton("Up", ui.RotationalGroup, "up", function() editFunction( { Y = 1 } ) end)
	addButton("Down", ui.RotationalGroup, "down", function() editFunction( { Y = -1 } ) end)
	addButton("Turn", ui.RotationalGroup, "yaw-", function() editFunction( { Yaw = -1 } ) end)
	addButton("Turn", ui.RotationalGroup, "yaw+", function() editFunction( { Yaw = 1 } ) end)

	-- Edit Settings

	ui.EditSettingsGroup = EHT.CreateControl( prefix .. "EditSettingsGroup", parent, CT_CONTROL )
	ui.EditSettingsGroup:SetAnchor( TOPLEFT, ui.DirectionalControls, BOTTOMLEFT, 0, 25 )
	ui.EditSettingsGroup:SetAnchor( TOPRIGHT, ui.DirectionalControls, BOTTOMRIGHT, 0, 25 )
	ui.EditSettingsGroup:SetResizeToFitDescendents( true )
	ui.EditSettingsGroup:SetMouseEnabled(false)

	ui.Precision = EHT.CreateControl( prefix .. "Precision", ui.EditSettingsGroup, CT_SLIDER )
	ui.Precision:SetAnchor( TOP, ui.EditSettingsGroup, TOP, 0, 38 )
	ui.Precision:SetHeight( 15 )
	ui.Precision:SetWidth( 130 )
	ui.Precision:SetMouseEnabled( true )
	ui.Precision:SetOrientation( ORIENTATION_HORIZONTAL )
	ui.Precision:SetThumbTexture( "EsoUI/Art/Miscellaneous/scrollbox_elevator.dds", "EsoUI/Art/Miscellaneous/scrollbox_elevator_disabled.dds", nil, 12, 16 )
	ui.Precision:SetMinMax( 1, 6 )
	ui.Precision:SetValueStep( 1 )
	ui.Precision:SetValue( EHT.SavedVars.SelectionPrecision or 4 )
	ui.Precision:SetHandler( "OnValueChanged", function( self, value, eventReason )
		if eventReason == EVENT_REASON_SOFTWARE then return end
		EHT.SavedVars.SelectionPrecision = value
		EHT.UI.SetPrecisionInfoTooltip( true )
	end )
	ui.Precision:SetEnabled( not EHT.SavedVars.SelectionPrecisionUseCustom )

	EHT.UI.SetPrecisionInfoTooltip()

	ui.PrecisionBackdrop = EHT.CreateControl( nil, ui.Precision, CT_BACKDROP )
	ui.PrecisionBackdrop:SetCenterColor( 0, 0, 0 )
	ui.PrecisionBackdrop:SetAnchor( TOPLEFT, ui.Precision, LEFT, 4, -3 )
	ui.PrecisionBackdrop:SetAnchor( BOTTOMRIGHT, ui.Precision, RIGHT, -4, 3 )
	ui.PrecisionBackdrop:SetEdgeTexture( "EsoUI/Art/Tooltips/UI-SliderBackdrop.dds", 32, 4 )

	ui.PrecisionLabel = EHT.CreateControl( nil, ui.Precision, CT_LABEL )
	ui.PrecisionLabel:SetFont( "ZoFontGameSmall" )
	ui.PrecisionLabel:SetAnchor( BOTTOM, ui.Precision, TOP, 0, -3 )
	ui.PrecisionLabel:SetText( "Changes" )

	ui.PrecisionMinLabel = EHT.CreateControl( nil, ui.Precision, CT_LABEL )
	ui.PrecisionMinLabel:SetFont( "ZoFontGameSmall" )
	ui.PrecisionMinLabel:SetAnchor( BOTTOMLEFT, ui.Precision, TOPLEFT, -8, -1 )
	ui.PrecisionMinLabel:SetText( "small" )
	ui.PrecisionMinLabel:SetHorizontalAlignment( TEXT_ALIGN_LEFT )

	ui.PrecisionMaxLabel = EHT.CreateControl( nil, ui.Precision, CT_LABEL )
	ui.PrecisionMaxLabel:SetFont( "ZoFontGameSmall" )
	ui.PrecisionMaxLabel:SetAnchor( BOTTOMRIGHT, ui.Precision, TOPRIGHT, 8, -1 )
	ui.PrecisionMaxLabel:SetText( "large" )
	ui.PrecisionMaxLabel:SetHorizontalAlignment( TEXT_ALIGN_RIGHT )

	local notch = nil
	for notchIndex = 1, 4 do
		notch = CreateTexture( nil, ui.Precision )
		notch:SetDimensions( 10, 15 )
		notch:SetAlpha( 1 )
		notch:SetAnchor( TOPLEFT, ui.Precision, TOPLEFT, ( 25 * notchIndex ) - 1, 0 )
		notch:SetTexture( "EsoUI/Art/Miscellaneous/verticaldivider_64.dds" )
		notch:SetTextureCoords( 0, 1, 0.25, 0.75 )
	end

	ui.CustomPrecisionToggle = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "CustomPrecisionToggle", ui.EditSettingsGroup, "ZO_CheckButton" )
	ui.CustomPrecisionToggle:SetAnchor( TOP, ui.Precision, BOTTOM, -63, 24 )
	ZO_CheckButton_SetLabelText( ui.CustomPrecisionToggle, "Use Custom Precision" )
	ui.CustomPrecisionToggle.label:ClearAnchors()
	ui.CustomPrecisionToggle.label:SetAnchor( LEFT, ui.CustomPrecisionToggle, RIGHT, 5, 1 )
	ui.CustomPrecisionToggle.label:SetWidth( 120 )
	ui.CustomPrecisionToggle.label:SetHorizontalAlignment( TEXT_ALIGN_RIGHT )
	ZO_CheckButton_SetCheckState( ui.CustomPrecisionToggle, EHT.SavedVars.SelectionPrecisionUseCustom )

	local function OnUseCustomPrecisionToggled()
		local control = EHT.UI.ToolDialog
		local enabled = ZO_CheckButton_IsChecked(control.CustomPrecisionToggle)
		local c = enabled and 0.5 or 1

		EHT.SavedVars.SelectionPrecisionUseCustom = enabled
		control.Precision:SetEnabled(not enabled)
		control.PrecisionLabel:SetColor(c, c, c, 1)
		control.PrecisionMaxLabel:SetColor(c, c, c, 1)
		control.PrecisionMinLabel:SetColor(c, c, c, 1)
		
		if not control.CustomPrecisionToggle:IsHidden() then
			EHT.UI.SetPrecisionInfoTooltip(true)
		end
	end

	ZO_CheckButton_SetToggleFunction(ui.CustomPrecisionToggle, OnUseCustomPrecisionToggled)
	ui.CustomPrecisionToggle:GetChild( 1 ):SetFont( "ZoFontGameSmall" )

	EHT.UI.SetInfoTooltip(
		ui.CustomPrecisionToggle,
		"|cffffffEnable |c88ffffCustom Move and Rotate Precision|cffffff\n\nTo change these custom values go to\n|c88ffffSettings > Addons > Essential Housing Tools",
		TOP, 0, 10, BOTTOM, ui.Window )

	OnUseCustomPrecisionToggled()

	do
		local b = EHT.CreateControl( nil, ui.EditSettingsGroup, CT_TEXTURE )
		ui.LinkItemsToggle = b
		b:SetAnchor( RIGHT, ui.EditSettingsGroup, RIGHT, -5, 12 ) -- -21, 8 )
		b:SetTexture( EHT.Textures.ICON_LINK_GROUP )
		b:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
		b:SetDimensions( 60, 60 )
		SetColor(b, Colors.DirectionalButton)
		b:SetMouseEnabled( true )
		b:SetHandler( "OnMouseDown", function()
			EHT.Biz.ToggleSelectionLinkItemsMode()
		end )
		b:SetHandler( "OnMouseEnter", function( control )
			control:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 1.5 )
		end )
		b:SetHandler( "OnMouseExit", function( control )
			control:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 1 )
		end )

		EHT.UI.RefreshSelectionLinkItemsMode()
	end

	do
		local b = EHT.CreateControl( nil, ui.EditSettingsGroup, CT_TEXTURE )
		ui.ToggleDirectionalMode = b
		b:SetAnchor( LEFT, ui.EditSettingsGroup, LEFT, 5, 12 ) -- 21, 8 )
		b:SetTexture( EHT.Textures.ICON_COMPASS_RELATIVE )
		b:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
		b:SetDimensions( 60, 60 )
		SetColor(b, Colors.DirectionalButton)
		b:SetMouseEnabled( true )
		b:SetHandler( "OnMouseDown", function()
			EHT.Biz.ToggleDirectionalPositionMode()
		end )
		b:SetHandler( "OnMouseEnter", function( control )
			control:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 1.5 )
		end )
		b:SetHandler( "OnMouseExit", function( control )
			control:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 1 )
		end )
		b:SetExcludeFromResizeToFitExtents( true )

		local function CreateDirectionLabel( text )
			local l = CreateLabel("", b, text)
			SetLabelCustomFont(l, "BOLD_FONT", 30, false, false)
			SetColor(l, Colors.White)
			return l
		end

		ui.DirectionalModeNorth = CreateDirectionLabel("N")
		ui.DirectionalModeSouth = CreateDirectionLabel("S")
		ui.DirectionalModeEast = CreateDirectionLabel("E")
		ui.DirectionalModeWest = CreateDirectionLabel("W")

		b:SetHandler( "OnEffectivelyShown", function() EVENT_MANAGER:RegisterForUpdate( "EHT.UI.UpdateDirectionalPadHeading", 1, EHT.UI.UpdateDirectionalPadHeading ) end )
		b:SetHandler( "OnEffectivelyHidden", function() EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.UpdateDirectionalPadHeading" ) end )

		EHT.UI.RefreshDirectionalPad()
	end
end

function EHT.UI.SetupToolDialogSelectionTab( ui, parent, prefix, settings )
	local tip = function( control, message ) EHT.UI.SetInfoTooltip( control, message, BOTTOMRIGHT, nil, -8, TOPLEFT ) end
	local c, div, grp, sgrp

	-- Selection Settings

	grp = EHT.CreateControl( prefix .. "LoadSelectionContainer", parent, CT_CONTROL )
	ui.LoadSelectionContainer = grp
	grp:SetAnchor( TOPLEFT, parent, TOPLEFT, 0, 0 )
	grp:SetAnchor( BOTTOMRIGHT, parent, TOPRIGHT, 0, 51 )

	c = EHT.CreateControl( prefix .. "LoadSelectionLabel", grp, CT_LABEL )
	ui.LoadSelectionLabel = c
	c:SetFont( Colors.LabelFont )
	SetColor(c, Colors.White)
	c:SetAnchor( TOPLEFT, grp, TOPLEFT, 0, 0 )
	c:SetAnchor( TOPRIGHT, grp, TOPRIGHT, 0, 0 )
	c:SetText( "Load a saved selection" )

	ui.RestoreSelectionButton = EHT.UI.CreateButton(
		prefix .. "RestoreSelectionButton",
		grp,
		"Revert to Last Save",
		{ { TOPRIGHT, grp, TOPRIGHT, 0, 2 } },
		function()
			local groupName = ui.SelectionList:GetSelectedItem()

			if nil == groupName or "" == groupName then
				EHT.UI.ShowAlertDialog( "Choose a Selection", "Choose a selection to restore." )
				return
			end
--[[
			EHT.UI.ShowConfirmationDialog(
				"Restore Selection",
				string.format( "|cffffffRestore items in |c00ffff%s|cffffff to their last saved positions|r?", groupName ),
				function() EHT.Biz.LoadGroup( groupName, true ) end )
]]
			local changed = EHT.Biz.GetCurrentStateVersusGroupDeltas( groupName )
			changed = #changed
			local numItems = 0 < changed and string.format( "%d changed item%s", changed, 1 == changed and "" or "s" ) or "items"

			EHT.UI.ShowConfirmationDialog(
				"Restore Selection",
				string.format( "|cffffffRestore %s in |c00ffff%s|cffffff to the last saved position%s|r?", numItems, groupName, 1 == changed and "" or "s" ),
				function()
					EHT.Biz.LoadGroup( groupName, true )
					EssentialHousingHub:IncUMTD("n_sres", 1)
				end )
		end )

	EHT.UI.SetInfoTooltip( ui.RestoreSelectionButton, "Restores a saved selection's items to their last saved positions." )

	c = EHT.UI.Picklist:New( prefix .. "SelectionList", grp )
	ui.SelectionList = c
	c:SetAnchor( TOPLEFT, ui.LoadSelectionLabel, BOTTOMLEFT, 0, 6 )
	c:SetAnchor( TOPRIGHT, ui.LoadSelectionLabel, BOTTOMRIGHT, 0, 6 )
	c:SetHeight( 25 )
	c:SetSorted( true )
	tip( c:GetControl(), "Select a saved selection to edit or delete, or click \"New\" to create a new selection." )

	grp = EHT.CreateControl( prefix .. "SelectionHeaderGroup", parent, CT_CONTROL )
	ui.SelectionHeaderGroup = grp
	grp:SetAnchor( TOPLEFT, ui.LoadSelectionContainer, BOTTOMLEFT, 0, 4 )
	grp:SetAnchor( TOPRIGHT, ui.LoadSelectionContainer, BOTTOMRIGHT, 0, 4 )
	grp:SetResizeToFitDescendents( true )

	ui.NewSelectionButton = EHT.UI.CreateButton(
		prefix .. "NewSelectionButton",
		grp,
		"Clear/New Selection",
		{ { BOTTOMLEFT, grp, BOTTOMLEFT, 0, 0 } },
		function() EHT.UI.ShowConfirmationDialog( "New Selection", "Start a new selection?\n\nPlease save your current selection first if you wish to keep any changes.", function() EHT.Biz.ResetSelection() end ) end )

	EHT.UI.SetInfoTooltip( ui.NewSelectionButton, "Create a new selection." )

	ui.DeleteSelectionButton = EHT.UI.CreateButton(
		prefix .. "DeleteSelectionButton",
		grp,
		"Delete",
		{ { BOTTOMRIGHT, grp, BOTTOMRIGHT, 0, 0 } },
		function()
			local groupName = ui.SelectionList:GetSelectedItem()
			if nil == groupName or "" == groupName then
				EHT.UI.PlaySoundFailure()
				EHT.UI.ShowAlertDialog( "Choose a Selection", "Choose a Saved Selection to delete." )
			else
				EHT.UI.ShowConfirmationDialog( "Remove Selection", string.format( "Delete the Saved Selection \"%s\"?", groupName ), function() EHT.Biz.RemoveGroup( groupName ) end )
			end
		end )

	EHT.UI.SetInfoTooltip( ui.DeleteSelectionButton, "Deletes the current selection." )

	ui.SaveSelectionButton = EHT.UI.CreateButton(
		prefix .. "SaveSelectionButton",
		grp,
		"Save",
		{ { RIGHT, ui.DeleteSelectionButton, LEFT, -10, 0 } },
		function()

			local house = EHT.Data.GetCurrentHouse()
			if nil == house then return end

			local groupName = ui.SelectionName:GetText()
			if not EHT.Util.CompareText( groupName, house.CurrentGroupName ) and nil ~= EHT.Data.GetGroup( groupName ) then
				EHT.UI.ShowConfirmationDialog( "Overwrite Selection", string.format( "Overwrite the Saved Selection \"%s\"?", groupName ), function()
					EHT.Biz.SaveGroup( groupName )
					EssentialHousingHub:IncUMTD("n_ssvd", 1)
				end )
			else
				EHT.Biz.SaveGroup( groupName )
				EssentialHousingHub:IncUMTD("n_ssvd", 1)
			end

		end )

	EHT.UI.SetInfoTooltip( ui.SaveSelectionButton, "Save your current selection or load a previously saved selection." )

	do
		local g = CreateContainer( nil, parent, CreateAnchor( TOPLEFT, ui.SelectionHeaderGroup, BOTTOMLEFT, 0, 4 ), CreateAnchor( TOPRIGHT, ui.SelectionHeaderGroup, BOTTOMRIGHT, 0, 4 ) )
		ui.SelectionNameGroup = g

		c = EHT.CreateControl( nil, g, CT_LABEL )
		ui.SelectionNameLabel = c
		c:SetFont( Colors.LabelFont )
		SetColor(c, Colors.White)
		c:SetAnchor( LEFT, g, LEFT, 0, 0 )
		c:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		c:SetText( "Selection name" )
		c:SetWidth( 120 )

		c = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "SelectionNameBackdrop", g, "ZO_EditBackdrop" )
		ui.SelectionNameBackdrop = c
		AddAnchor( c, CreateAnchor( LEFT, ui.SelectionNameLabel, RIGHT, 4, 0 ) )
		AddAnchor( c, CreateAnchor( RIGHT, g, RIGHT, 0, 0 ) )
		c:SetHeight( 22 )

		c = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "SelectionName", ui.SelectionNameBackdrop, "ZO_DefaultEditForBackdrop" ) 
		ui.SelectionName = c
		c:SetFont( Colors.LabelFont )
		c:SetAnchor( TOPLEFT, ui.SelectionNameBackdrop, TOPLEFT, 4, 0 )
		c:SetAnchor( BOTTOMRIGHT, ui.SelectionNameBackdrop, BOTTOMRIGHT, -4, 0 )
		c:SetMaxInputChars( 60 )
		tip( c, "A brief description of this selection." )
	end

	local div = CreateDivider( nil, parent, CreateAnchor( TOPLEFT, ui.SelectionNameGroup, BOTTOMLEFT, 0, 6 ), CreateAnchor( TOPRIGHT, ui.SelectionNameGroup, BOTTOMRIGHT, 0, 6 ) )

	do
		local g = CreateContainer( nil, parent, CreateAnchor( TOPLEFT, div, BOTTOMLEFT, 0, 6 ), CreateAnchor( TOPRIGHT, div, BOTTOMRIGHT, 0, 6 ) )
		ui.SelectionSettingsGroup = g

		c = EHT.CreateControl( nil, g, CT_LABEL )
		ui.SelectionTypeLabel = c
		c:SetFont(Colors.LabelFont)
		SetColor(c, Colors.White)
		c:SetAnchor( LEFT, g, LEFT, 0, 0 )
		c:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		c:SetText("Selection mode")
		c:SetWidth( 120 )

		c = EHT.UI.Picklist:New( prefix .. "SelectionType", g ) --, 270, 25
		AddAnchor( c, CreateAnchor( LEFT, ui.SelectionTypeLabel, RIGHT, 4, 0 ) )
		AddAnchor( c, CreateAnchor( RIGHT, g, RIGHT, 0, 0 ) )
		ui.SelectionType = c

		local function selectionTypeBoxChanged( control )
			local selectedItem = control:GetSelectedItem()
			EHT.SavedVars.SelectionMode = selectedItem
		end

		local function selectFunction( control, item )
			local oldMode = EHT.SavedVars.SelectionMode
			local newMode = item.Label

			if newMode == EHT.CONST.SELECTION_MODE.ADD_SELECTION then
				EHT.UI.ShowAddSelectionDialog()
			elseif newMode == EHT.CONST.SELECTION_MODE.REMOVE_SELECTION then
				EHT.UI.ShowRemoveSelectionDialog()
			elseif newMode == EHT.CONST.SELECTION_MODE.LIMIT_TRADITIONAL then
				EHT.Biz.GroupFurnitureByLimitType( HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_ITEM )
			elseif newMode == EHT.CONST.SELECTION_MODE.LIMIT_SPECIAL then
				EHT.Biz.GroupFurnitureByLimitType( HOUSING_FURNISHING_LIMIT_TYPE_HIGH_IMPACT_ITEM )
			elseif newMode == EHT.CONST.SELECTION_MODE.LIMIT_COLLECTIBLE then
				EHT.Biz.GroupFurnitureByLimitType( HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_COLLECTIBLE )
			elseif newMode == EHT.CONST.SELECTION_MODE.LIMIT_SPECIAL_COLLECTIBLE then
				EHT.Biz.GroupFurnitureByLimitType( HOUSING_FURNISHING_LIMIT_TYPE_HIGH_IMPACT_COLLECTIBLE )
			end

			zo_callLater( function()
				control:SetSelectedItem( oldMode )
			end, 1 )
		end

		local function SelectAllWithExceptions( control, description, exclusions )
			local mode = EHT.SavedVars.SelectionMode

			EHT.UI.ShowConfirmationDialog( "Select " .. description, "Select " .. description .. " in this house?", function()
				EHT.Biz.SelectAll( exclusions )
			end )

			zo_callLater( function()
				control:SetSelectedItem( mode )
			end, 1 )
		end

		c:AddItem( EHT.CONST.SELECTION_MODE.SINGLE, selectionTypeBoxChanged )
		c:AddItem( EHT.CONST.SELECTION_MODE.CONNECTED, selectionTypeBoxChanged )
		c:AddItem( EHT.CONST.SELECTION_MODE.CONNECTED_HOMOGENEOUS, selectionTypeBoxChanged )
		c:AddItem( EHT.CONST.SELECTION_MODE.LINKED, selectionTypeBoxChanged )
		c:AddItem( EHT.CONST.SELECTION_MODE.LINKED_CHILDREN, selectionTypeBoxChanged )
		c:AddItem( EHT.CONST.SELECTION_MODE.LIMIT_TRADITIONAL, selectFunction )
		c:AddItem( EHT.CONST.SELECTION_MODE.LIMIT_SPECIAL, selectFunction )
		c:AddItem( EHT.CONST.SELECTION_MODE.LIMIT_COLLECTIBLE, selectFunction )
		c:AddItem( EHT.CONST.SELECTION_MODE.LIMIT_SPECIAL_COLLECTIBLE, selectFunction )
		c:AddItem( EHT.CONST.SELECTION_MODE.RADIUS, selectionTypeBoxChanged )
		c:AddItem( EHT.CONST.SELECTION_MODE.RADIUS_HOMOGENEOUS, selectionTypeBoxChanged )
		c:AddItem( EHT.CONST.SELECTION_MODE.RELATED_PATH_NODES, selectionTypeBoxChanged )
		c:AddItem( EHT.CONST.SELECTION_MODE.ADD_SELECTION, selectFunction )
		c:AddItem( EHT.CONST.SELECTION_MODE.REMOVE_SELECTION, selectFunction )
		c:AddItem( EHT.CONST.SELECTION_MODE.ALL_STATIONS, function( control )
			local mode = EHT.SavedVars.SelectionMode
			EHT.Biz.SelectAllStations()
			zo_callLater( function() control:SetSelectedItem( mode ) end, 1 )
		end )
		c:AddItem( EHT.CONST.SELECTION_MODE.ALL_STATIONS_HOMOGENEOUS, selectionTypeBoxChanged )
		c:AddItem( "All Effects", function( control )
			local mode = EHT.SavedVars.SelectionMode
			EHT.UI.ShowConfirmationDialog( "Select all effects", "Select all |cffffffeffects|r in the house?", function() EHT.Biz.SelectAllEffects() end )
			zo_callLater( function() control:SetSelectedItem( mode ) end, 1 )
		end )
		c:AddItem( EHT.CONST.SELECTION_MODE.ALL_HOMOGENEOUS, selectionTypeBoxChanged )
		c:AddItem( EHT.CONST.SELECTION_MODE.EXCEPT_EFFECTS, function( control )
			SelectAllWithExceptions( control, "all items |cccffffexcept|r effects",{ ["effects"] = true } )
		end )
		c:AddItem( EHT.CONST.SELECTION_MODE.EXCEPT_STATIONS, function( control )
			SelectAllWithExceptions( control, "all items |cccffffexcept|r crafting stations", { ["stations"] = true } )
		end )
		c:AddItem( "All Items", function( control )
			SelectAllWithExceptions( control, "all |cffffffitems and effects|r" )
		end )
		c:SetSelectedItem( EHT.SavedVars.SelectionMode )

		EHT.UI.SetInfoTooltip( c:GetControl(),
			"When you target and Group Select an item, the Select Mode controls if and how other nearby items are also automatically selected." ..
			"\n\n" ..
			EHT.CONST.COLORS.HIGHLIGHT .. "Radius" .. EHT.CONST.COLORS.NORMAL .. " includes any items near the targeted item.\n" ..
			EHT.CONST.COLORS.HIGHLIGHT .. "Connected" .. EHT.CONST.COLORS.NORMAL .. " includes any items directly or indirectly touching the targeted item.\n" ..
			EHT.CONST.COLORS.HIGHLIGHT .. "Same As Target" .. EHT.CONST.COLORS.NORMAL .. " selects only the exact same items as the targeted item." )
	end

	-- Selection Actions

	grp = EHT.CreateControl( prefix .. "SelectionActionsGroupContainer", parent, CT_CONTROL )
	ui.SelectionActionsGroupContainer = grp
	grp:SetAnchor( BOTTOMLEFT, parent, BOTTOMLEFT, 0, 0 )
	grp:SetAnchor( BOTTOMRIGHT, parent, BOTTOMRIGHT, 0, 0 )
	grp:SetResizeToFitDescendents( true )

	c = EHT.UI.Picklist:New( prefix .. "ArrangeDropdown", grp, LEFT, grp, LEFT, 0, 0, 180, 26 )
	ui.ArrangeDropdown = c

	local groupOperations, groupOptions, subOptions, optGroup = { }, { }, nil, nil

	table.insert( groupOperations, EHT.CONST.GROUP_OPERATIONS.DEFAULT )

	for optGroupKey, optGroup in pairs( EHT.CONST.GROUP_OPERATIONS ) do
		if "table" == type( optGroup ) then table.insert( groupOptions, optGroupKey ) end
	end

	table.sort( groupOptions )

	for _, optGroupKey in ipairs( groupOptions ) do
		optGroup = EHT.CONST.GROUP_OPERATIONS[ optGroupKey ]

		if optGroup.DEFAULT then
			table.insert( groupOperations, " " )
			table.insert( groupOperations, "  " .. optGroup.DEFAULT )
		end

		subOptions = { }

		for optKey, optName in pairs( optGroup ) do
			if optKey ~= "DEFAULT" then table.insert( subOptions, "    " .. optName ) end
		end

		table.sort( subOptions )

		for _, optName in ipairs( subOptions ) do
			table.insert( groupOperations, "    " .. optName )
		end
	end

	for _, optName in ipairs( groupOperations ) do
		c:AddItem( optName, function() EHT.UI.ArrangeSelectedItems( ui.ArrangeDropdown, optName ) end )
	end

	c:SetSelectedItem( EHT.CONST.GROUP_OPERATIONS.DEFAULT )

	EHT.UI.SetInfoTooltip( ui.ArrangeDropdown:GetControl(), "Align, center, flip, level, reorder, stack, copy/paste/remove, or toggle on/off your selected items." )

	c = EHT.UI.CreateButton(
		prefix .. "ClipboardButton",
		grp,
		"Copy/Paste",
		{ { RIGHT, grp, RIGHT, 0, 0 } },
		function() EHT.UI.ShowClipboardDialog() end )
	ui.ClipboardButton = c
	EHT.UI.SetInfoTooltip( c, "Copy/Cut the selected items, Paste copied items and Import/Export copied items." )

	c = EHT.UI.CreateButton(
		prefix .. "LockUnlockItemsTextButton",
		grp,
		"Lock/Unlock",
		{ { RIGHT, ui.ClipboardButton, LEFT, -8, 0 } },
		function() EHT.Biz.LockUnlockItems() end )
	ui.LockUnlockItemsTextButton = c
	EHT.UI.SetInfoTooltip( c, "Lock/Unlock the selected items to prevent you from moving them.\n\nNote: Locked items are only locked for yourself - other decorators can still edit locked items." )

	-- Selection Actions

	grp = EHT.CreateControl( prefix .. "SelectionStatsContainer", parent, CT_CONTROL )
	ui.SelectionStatsContainer = grp
	grp:SetAnchor( BOTTOMLEFT, ui.SelectionActionsGroupContainer, TOPLEFT, 0, -6 )
	grp:SetAnchor( BOTTOMRIGHT, ui.SelectionActionsGroupContainer, TOPRIGHT, 0, -6 )
	grp:SetResizeToFitDescendents( true )

	do
		local tip = "Choose whether to see all placed items or only those which you have selected, as well as how to sort the list."

		c = EHT.CreateControl( nil, grp, CT_LABEL )
		ui.SelectionSortLabel = c
		c:SetFont( Colors.LabelFont )
		SetColor(c, Colors.White)
		c:SetAnchor( LEFT, grp, LEFT, 0, 0 )
		c:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		c:SetText( "View" )
		EHT.UI.SetInfoTooltip( c, tip )

		c = EHT.UI.Picklist:New( prefix .. "SelectionSort", grp, LEFT, ui.SelectionSortLabel, RIGHT, 6, 0, 175, 26 )
		ui.SelectionSort = c
		EHT.UI.SetInfoTooltip( c.Control, tip )

		if "distance" == EHT.SavedVars.SelectionListSort and not EHT.SavedVars.SelectionListIncludeAll then
			EHT.SavedVars.SelectionListSort = "alpha"
		end

		c:SetItems( { { Label = "Selected Items Only", Value = 1 }, { Label = "All Items from A-Z", Value = 2 }, { Label = "All Items by Distance", Value = 3 }, } )
		c:AddHandler( "OnSelectionChanged", function( control, item )
			if not item then return end

			local value = tonumber( item.Value )
			if not value then return end

			EHT.SavedVars.SelectionListSort = 3 == value and "distance" or "alpha"
			EHT.SavedVars.SelectionListIncludeAll = 1 < value
			EHT.UI.QueueRefreshSelection()
		end )

		if false ~= EHT.GetSetting( "SelectionListIncludeAll" ) then
			c:SetSelectedItem( "distance" == EHT.SavedVars.SelectionListSort and 3 or 2 )
		else
			c:SetSelectedItem( 1 )
		end
	end
--[[
	c = EHT.CreateControl( nil, grp, CT_LABEL )
	ui.SelectionSort = c
	c:SetFont( Colors.LabelFont )
	c:SetColor( 0.85, 1, 1, 1 )
	c:SetAnchor( LEFT, grp, LEFT, 0, 0 )
	c:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
	c:SetText( "Sort Alpha" )
	c:SetHandler( "OnMouseDown", function()
		if "Distance" ~= EHT.SavedVars.SelectionSort then
			EHT.SavedVars.SelectionSort = "Distance"
		else
			EHT.SavedVars.SelectionSort = "Alpha"
		end
		EHT.UI.RefreshSelection()
	end )
]]
	c = EHT.CreateControl(nil, grp, CT_LABEL)
	ui.SelectionCountLabel = c
	c:SetFont(Colors.LabelFont)
	SetColor(c, Colors.DataLabel)
	c:SetAnchor(RIGHT, grp, RIGHT, 0, 0)
	c:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	c:SetText("")

	-- Dividers

	--local divider1 = CreateDivider( nil, parent, CreateAnchor( TOPLEFT, ui.SelectionSettingsGroup, BOTTOMLEFT, 0, 5 ), CreateAnchor( TOPRIGHT, ui.SelectionSettingsGroup, BOTTOMRIGHT, 0, 5 ) )
	--local divider2 = CreateDivider( nil, parent, CreateAnchor( BOTTOMLEFT, ui.SelectionActionsGroupContainer, TOPLEFT, 0, -4 ), CreateAnchor( BOTTOMRIGHT, ui.SelectionActionsGroupContainer, TOPRIGHT, 0, -4 ) )

	-- Selection List

	c = EHT.UI.List:New( prefix .. "Buffer", parent )
	ui.Buffer = c
	AddAnchor( c, CreateAnchor( TOPLEFT, ui.SelectionSettingsGroup, BOTTOMLEFT, 0, 6 ) )
	AddAnchor( c, CreateAnchor( BOTTOMRIGHT, ui.SelectionStatsContainer, TOPRIGHT, 0, -6 ) )
	c:SetItemVerticalAlignment( TEXT_ALIGN_CENTER )
	c:SetItemSpacing( 0 )
	c:SetDragAndDropDisabledMessage( "|cffffffSwitch to |c00ffffSelected Items Only|cffffff View to reorder items with drag-and-drop." )

	EHT.UI.SetInfoTooltip( c:GetControl(), "These are the items that you have selected.\n\nLeft-click an item to show a pointer to it.\nRight-click an item to unselect it." )
	EHT.UI.RefreshSelectionListAppearance()
--[[
	ui.Buffer = EHT.CreateControl( prefix .. "Buffer", parent, CT_TEXTBUFFER )
	ui.Buffer:SetFont( "ZoFontChat" )
	ui.Buffer:SetMaxHistoryLines( 750 )
	ui.Buffer:SetMouseEnabled( true )
	ui.Buffer:SetLinkEnabled( true )
	ui.Buffer:SetAnchor( TOPLEFT, divider1, BOTTOMLEFT, 0, 2 )
	ui.Buffer:SetAnchor( BOTTOMRIGHT, divider2, TOPRIGHT, -16, -2 )

	ui.Buffer:SetHandler( "OnLinkMouseUp", function( self, linkText, link, button )

		if nil ~= string.find( link, ":item:" ) or nil ~= string.find( link, ":collectible:" ) or nil ~= string.find( link, ":effect:" ) then
			if button ~= MOUSE_BUTTON_INDEX_RIGHT then
				EHT.UI.PointToFurniture( link )
			else
				EHT.UI.UngroupFurniture( link )
			end
		else
			ZO_LinkHandler_OnLinkMouseUp( link, button, self )
		end

	end )

	ui.Buffer:SetHandler( "OnMouseWheel", function( self, delta, ctrl, alt, shift )
		local offset = delta
		local slider = EHT.UI.ToolDialog.Slider
		if shift then
			offset = offset * self:GetNumVisibleLines()
		elseif ctrl then
			offset = offset * self:GetNumHistoryLines()
		end
		self:SetScrollPosition( self:GetScrollPosition() + offset )
		slider:SetValue( slider:GetValue() - offset )
	end )

	EHT.UI.SetInfoTooltip( ui.Buffer, "These are the items that you have selected.\n\nLeft-click an item to show a pointer to it.\nRight-click an item to unselect it." )

	ui.Slider = EHT.CreateControl( prefix .. "Slider", parent, CT_SLIDER )
	ui.Slider:SetWidth( 15 )
	ui.Slider:SetAnchor( TOPLEFT, ui.Buffer, TOPRIGHT, 1, 0 )
	ui.Slider:SetAnchor( BOTTOMLEFT, ui.Buffer, BOTTOMRIGHT, 1, 0 )
	ui.Slider:SetMinMax( 1, 1 )
	ui.Slider:SetMouseEnabled( true )
	ui.Slider:SetValueStep( 1 )
	ui.Slider:SetValue( 1 )
	ui.Slider:SetHidden( true )
	ui.Slider:SetThumbTexture( "EsoUI/Art/ChatWindow/chat_thumb.dds", "EsoUI/Art/ChatWindow/chat_thumb_disabled.dds", nil, 8, 22, nil, nil, 0.6875, nil )
	ui.Slider:SetBackgroundMiddleTexture( "EsoUI/Art/ChatWindow/chat_scrollbar_track.dds" )
	ui.Slider:SetHandler( "OnValueChanged", function( self, value, eventReason )
		if eventReason == EVENT_REASON_HARDWARE then
			local buffer = EHT.UI.ToolDialog.Buffer
			buffer:SetScrollPosition( buffer:GetNumHistoryLines() - self:GetValue() )
		end
	end )
]]
end


function EHT.UI.SetupToolDialogClipboardTab( ui, parent, prefix, settings )

	local grp

	-- Clipboard Actions

	ui.ClipboardActionsGroupContainer = EHT.CreateControl( prefix .. "ClipboardActionsGroupContainer", parent, CT_CONTROL )
	ui.ClipboardActionsGroupContainer:SetAnchor( BOTTOMLEFT, parent, BOTTOMLEFT, 0, 0 )
	ui.ClipboardActionsGroupContainer:SetAnchor( BOTTOMRIGHT, parent, BOTTOMRIGHT, 0, 0 )
	ui.ClipboardActionsGroupContainer:SetResizeToFitDescendents( true )

	grp = EHT.CreateControl( prefix .. "ClipboardCopyActionsGroup", ui.ClipboardActionsGroupContainer, CT_CONTROL )
	ui.ClipboardCopyActionsGroup = grp
	grp:SetAnchor( TOP, ui.ClipboardActionsGroupContainer, TOP, 0, 0 )
	grp:SetResizeToFitDescendents( true )

	ui.CopyCutButton = EHT.UI.CreateButton(
		prefix .. "CopyCutButton",
		grp,
		"Cut & Copy Selection",
		{ { LEFT, grp, LEFT, 0, 0 } },
		EHT.UI.CutSelectionToClipboard )

	EHT.UI.SetInfoTooltip( ui.CopyCutButton, "Copies all selected items to the clipboard and removes the items from your home, placing them back into your inventory." )

	ui.CopyButton = EHT.UI.CreateButton(
		prefix .. "CopyButton",
		grp,
		"Copy Selection",
		{ { LEFT, ui.CopyCutButton, RIGHT, 5, 0 } },
		EHT.UI.CopySelectionToClipboard )

	EHT.UI.SetInfoTooltip( ui.CopyButton, "Copies all selected items to the clipboard." )

	ui.CopyFromButton = EHT.UI.CreateButton(
		prefix .. "CopyFromButton",
		grp,
		"Copy Saved Selection",
		{ { LEFT, ui.CopyButton, RIGHT, 5, 0 } },
		function() EHT.UI.ShowCopyFromSelectionsDialog() end )

	EHT.UI.SetInfoTooltip( ui.CopyFromButton, "Copies all items from a Saved Selection to the clipboard." )

	grp = EHT.CreateControl( prefix .. "ClipboardPasteActionsGroup", ui.ClipboardActionsGroupContainer, CT_CONTROL )
	ui.ClipboardPasteActionsGroup = grp
	grp:SetAnchor( TOP, ui.ClipboardCopyActionsGroup, BOTTOM, 0, 2 )
	grp:SetResizeToFitDescendents( true )

	ui.PasteClipboardFromSelectionButton = EHT.UI.CreateButton(
		prefix .. "PasteClipboardFromSelectionButton",
		grp,
		"Paste from Selection",
		{ { LEFT, grp, LEFT, 0, 0 } },
		function()
			EHT.UI.ShowConfirmationDialog(
				"Paste Clipboard from Selected Items",
				"Find the items in your current selection that match the items on the clipboard and then rearrange those items to match the clipboard's layout?",
				function() EHT.Biz.PasteClipboardFromSelection() end )
		end )

	EHT.UI.SetInfoTooltip( ui.PasteClipboardFromSelectionButton, "Rerranges the matching items that are in your current selection using the layout stored in the clipboard." )

	ui.PasteClipboardFromHouseItemsButton = EHT.UI.CreateButton(
		prefix .. "PasteClipboardFromHouseItemsButton",
		grp,
		"Paste from House Items",
		{ { LEFT, ui.PasteClipboardFromSelectionButton, RIGHT, 5, 0 } },
		function()
			EHT.UI.ShowConfirmationDialog(
				"Paste Clipboard from House Items",
				"Find the items in your house that match the items on the clipboard and then rearrange those items to match the clipboard's layout?\n\n" ..
				"Note: The items nearest to you will be matched first whenever possible.",
				function() EHT.Biz.PasteClipboardFromHouse() end )
		end )

	EHT.UI.SetInfoTooltip( ui.PasteClipboardFromHouseItemsButton, "Rerranges the matching items that are already placed in your home using the layout stored in the clipboard." )

	ui.PasteClipboardFromInventoryButton = EHT.UI.CreateButton(
		prefix .. "PasteClipboardFromInventoryButton",
		grp,
		"Paste from Inventory",
		{ { LEFT, ui.PasteClipboardFromHouseItemsButton, RIGHT, 5, 0 } },
		EHT.UI.PasteFromInventory )

	EHT.UI.SetInfoTooltip( ui.PasteClipboardFromInventoryButton, "Pastes the clipboard items into your home using items from your inventory, bank and home storage containers." )

	grp = EHT.CreateControl( prefix .. "ClipboardOtherActionsGroup", ui.ClipboardActionsGroupContainer, CT_CONTROL )
	ui.ClipboardOtherActionsGroup = grp
	grp:SetAnchor( TOP, ui.ClipboardPasteActionsGroup, BOTTOM, 0, 2 )
	grp:SetResizeToFitDescendents( true )

	ui.ExportClipboardButton = EHT.UI.CreateButton(
		prefix .. "ExportClipboardButton",
		grp,
		"Export",
		{ { LEFT, grp, LEFT, 0, 0 } },
		function() EHT.UI.ShowExportClipboardDialog() end )

	EHT.UI.SetInfoTooltip( ui.ExportClipboardButton, "Export this clipboard to text." )

	ui.ImportClipboardButton = EHT.UI.CreateButton(
		prefix .. "ImportClipboardButton",
		grp,
		"Import",
		{ { LEFT, ui.ExportClipboardButton, RIGHT, 25, 0 } },
		function() EHT.UI.ShowImportClipboardDialog() end )

	EHT.UI.SetInfoTooltip( ui.ImportClipboardButton, "Import a clipboard from text." )

	ui.ClearClipboardButton = EHT.UI.CreateButton(
		prefix .. "ClearClipboardButton",
		grp,
		"Clear",
		{ { LEFT, ui.ImportClipboardButton, RIGHT, 25, 0 } },
		function() EHT.UI.ShowConfirmationDialog( "Clear Clipboard", "Empty the virtual Clipboard?", function() EHT.Biz.ResetClipboard() end ) end )

	EHT.UI.SetInfoTooltip( ui.ClearClipboardButton, "Clears the items from your clipboard." )

	-- Dividers

	ui.DividerTop = CreateDivider( nil, parent, CreateAnchor( TOPLEFT, parent, TOPLEFT, 0, 0 ), CreateAnchor( TOPRIGHT, parent, TOPRIGHT, 0, 0 ) )
	ui.DividerBottom = CreateDivider( nil, parent, CreateAnchor( BOTTOMLEFT, ui.ClipboardActionsGroupContainer, TOPLEFT, 0, 0 ), CreateAnchor( BOTTOMRIGHT, ui.ClipboardActionsGroupContainer, TOPRIGHT, 0, 0 ) )

	-- Clipboard List

	grp = EHT.CreateControl( prefix .. "ClipboardContainer", parent, CT_CONTROL )
	ui.ClipboardContainer = grp
	grp:SetAnchor( TOPLEFT, ui.DividerTop, TOPLEFT, 5, 0 )
	grp:SetAnchor( BOTTOMRIGHT, ui.DividerBottom, TOPRIGHT, -5, 0 )

	ctl = EHT.CreateControl( nil, grp, CT_BACKDROP )
	ui.ClipboardBackdrop = ctl
	ctl:SetCenterColor( 0, 0, 0, 1 )
	ctl:SetEdgeColor( 0.0, 0.0, 0.0, 1 )
	ctl:SetInsets( 0, 0, 0, 0 )
	ctl:SetAnchorFill( grp )

	ctl = EHT.CreateControl( prefix .. "ClipboardBuffer", grp, CT_TEXTBUFFER )
	ui.ClipboardBuffer = ctl
	ctl:SetFont( "ZoFontChat" )
	ctl:SetMaxHistoryLines( 750 )
	ctl:SetMouseEnabled( true )
	ctl:SetLinkEnabled( true )
	ctl:SetAnchor( TOPLEFT, grp, TOPLEFT, 5, 0 )
	ctl:SetAnchor( BOTTOMRIGHT, grp, BOTTOMRIGHT, -20, 0 )

	ctl:SetHandler( "OnLinkMouseUp", function( self, linkText, link, button )
		if button ~= MOUSE_BUTTON_INDEX_RIGHT then
			ZO_LinkHandler_OnLinkMouseUp( link, button, self )
		else
			EHT.UI.RemoveClipboardFurniture( link )
		end
	end )

	ctl:SetHandler( "OnMouseWheel", function( control, delta, ctrl, alt, shift )
		local slider = EHT.UI.ToolDialog.Slider
		if not slider then
			return
		end

		local offset = delta or 0
		if shift then
			offset = offset * control:GetNumVisibleLines()
		elseif ctrl then
			offset = offset * control:GetNumHistoryLines()
		end

		control:SetScrollPosition( control:GetScrollPosition() + offset )
		slider:SetValue( slider:GetValue() - offset )
	end )

	EHT.UI.SetInfoTooltip( ctl, "These are the items in your virtual clipboard.\n\nRight-click an item to remove it from the clipboard." )

	ui.ClipboardSlider = EHT.CreateControl( prefix .. "ClipboardSlider", grp, CT_SLIDER )
	ui.ClipboardSlider:SetWidth( 15 )
	ui.ClipboardSlider:SetAnchor( TOPLEFT, ui.ClipboardBuffer, TOPRIGHT, 1, 0 )
	ui.ClipboardSlider:SetAnchor( BOTTOMLEFT, ui.ClipboardBuffer, BOTTOMRIGHT, 1, 0 )
	ui.ClipboardSlider:SetMinMax( 1, 1 )
	ui.ClipboardSlider:SetMouseEnabled( true )
	ui.ClipboardSlider:SetValueStep( 1 )
	ui.ClipboardSlider:SetValue( 1 )
	ui.ClipboardSlider:SetHidden( true )
	ui.ClipboardSlider:SetThumbTexture( "EsoUI/Art/ChatWindow/chat_thumb.dds", "EsoUI/Art/ChatWindow/chat_thumb_disabled.dds", nil, 8, 22, nil, nil, 0.6875, nil )
	ui.ClipboardSlider:SetBackgroundMiddleTexture( "EsoUI/Art/ChatWindow/chat_scrollbar_track.dds" )
	ui.ClipboardSlider:SetHandler( "OnValueChanged", function( self, value, eventReason )
		if eventReason == EVENT_REASON_HARDWARE then
			local buffer = EHT.UI.ClipboardDialog.ClipboardBuffer
			buffer:SetScrollPosition( buffer:GetNumHistoryLines() - self:GetValue() )
		end
	end )

end


function EHT.UI.SetupToolDialogAnimateTab( ui, parent, prefix, settings )

	local tip = EHT.UI.SetInfoTooltip
	local c, grp, tipMsg

	---- Edit Scene Group ----

	ui.EditSceneGroup = EHT.CreateControl( prefix .. "EditSceneGroup", parent, CT_CONTROL )
	ui.EditSceneGroup:SetAnchor( TOPLEFT, parent, TOPLEFT, 0, 0 )
	ui.EditSceneGroup:SetAnchor( TOPRIGHT, parent, TOPRIGHT, 0, 0 )
	ui.EditSceneGroup:SetHidden( false )
	ui.EditSceneGroup:SetResizeToFitDescendents( true )

	do

		-- Manage Scenes Group

		ui.ManageScenesGroup = EHT.CreateControl( prefix .. "ManageScenesGroup", ui.EditSceneGroup, CT_CONTROL )
		ui.ManageScenesGroup:SetAnchor( TOPLEFT, ui.EditSceneGroup, TOPLEFT, 0, 0 )
		ui.ManageScenesGroup:SetAnchor( TOPRIGHT, ui.EditSceneGroup, TOPRIGHT, 0, 0 )
		ui.ManageScenesGroup:SetResizeToFitDescendents( true )

		ui.CurrentScene = EHT.CreateControl( prefix .. "CurrentScene", ui.ManageScenesGroup, CT_LABEL )
		ui.CurrentScene:SetFont( "ZoFontWinH4" )
		ui.CurrentScene:SetColor( 1, 1, 1, 1 )
		ui.CurrentScene:SetAnchor( TOPLEFT, ui.ManageScenesGroup, TOPLEFT, 0, 0 )
		ui.CurrentScene:SetAnchor( TOPRIGHT, ui.ManageScenesGroup, TOPRIGHT, 0, 0 )
		ui.CurrentScene:SetHorizontalAlignment( TEXT_ALIGN_CENTER )


		ui.NewSceneButton = EHT.UI.CreateButton(
			prefix .. "NewSceneButton",
			ui.ManageScenesGroup,
			"New",
			{ { TOPLEFT, ui.CurrentScene, BOTTOMLEFT, 0, 0 } },
			function()
				if not EHT.UI.CanEditAnimation() then return end
				local _, group, scene = EHT.Data.GetCurrentHouse()

				if nil ~= group and 0 < #group then
					if nil ~= scene and 0 < #scene.Frames then
						EHT.UI.ShowConfirmationDialog( "New from Selection", "Abandon current Scene and replace with the currently selected furniture?", function() EHT.Biz.SetupSceneFromCurrentGroup() end )
					else
						EHT.Biz.SetupSceneFromCurrentGroup()
					end
				else
					EHT.UI.ShowErrorDialog( "Selection Empty", "To create a new Scene, first select one or more furniture items.", function() end )
				end
			end )
		tip( ui.NewSceneButton, "Create a new Scene using the items in your current Selection." )

		ui.LoadSceneButton = EHT.UI.CreateButton(
			prefix .. "LoadSceneButton",
			ui.ManageScenesGroup,
			"Load",
			{ { TOPRIGHT, ui.CurrentScene, BOTTOMRIGHT, 0, 0 } },
			function() if not EHT.UI.CanEditAnimation() then return end EHT.UI.ShowToolTab( EHT.CONST.TOOL_TABS.ANIMATE, EHT.CONST.TOOL_TABS_STATE.LOAD ) end )
		tip( ui.LoadSceneButton, "Load a previously saved Scene from this house." )

		ui.SaveSceneButton = EHT.UI.CreateButton(
			prefix .. "SaveSceneButton",
			ui.ManageScenesGroup,
			"Save",
			{ { RIGHT, ui.LoadSceneButton, LEFT, -2, 0 } },
			function() if not EHT.UI.CanEditAnimation() then return end EHT.UI.ShowToolTab( EHT.CONST.TOOL_TABS.ANIMATE, EHT.CONST.TOOL_TABS_STATE.SAVE ) end )
		tip( ui.SaveSceneButton, "Save the current Scene into this house." )

		-- Frame Group

		local divider = EHT.CreateControl( nil, ui.EditSceneGroup, CT_TEXTURE )
		divider:SetHeight( 5 )
		divider:SetAlpha( 0.5 )
		divider:SetAnchor( TOPLEFT, ui.ManageScenesGroup, BOTTOMLEFT, 0, 8 )
		divider:SetAnchor( TOPRIGHT, ui.ManageScenesGroup, BOTTOMRIGHT, 0, 8 )
		divider:SetTexture( "EsoUI/Art/Miscellaneous/horizontalDivider.dds" )
		divider:SetTextureCoords( 0.181640625, 0.818359375, 0, 1 )

		ui.FrameGroup = EHT.CreateControl( prefix .. "FrameGroup", ui.EditSceneGroup, CT_CONTROL )
		ui.FrameGroup:SetAnchor( TOPLEFT, divider, BOTTOMLEFT, 0, 5 )
		ui.FrameGroup:SetAnchor( TOPRIGHT, divider, BOTTOMRIGHT, 0, 5 )
		ui.FrameGroup:SetResizeToFitDescendents( true )

		ui.PreviewToggle = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "PreviewToggle", ui.FrameGroup, "ZO_CheckButton" )
		ZO_CheckButton_SetCheckState( ui.PreviewToggle, EHT.SavedVars.ScenePreview )
		ZO_CheckButton_SetLabelText( ui.PreviewToggle, "Preview" )
		ZO_CheckButton_SetToggleFunction( ui.PreviewToggle, function()

			EHT.SavedVars.ScenePreview = ZO_CheckButton_IsChecked( ui.PreviewToggle )
			if ZO_CheckButton_IsChecked( ui.PreviewToggle ) then
				local _, _, scene = EHT.Data.GetCurrentHouse()
				if nil ~= scene then EHT.Biz.PlayScene( scene.FrameIndex, true ) end
				EHT.UI.RefreshAnimationDialog()
			end

		end )
		ui.PreviewToggle:GetChild( 1 ):SetFont( "ZoFontWinH5" )
		ui.PreviewToggle:SetAnchor( TOPLEFT, ui.FrameGroup, TOPLEFT, 0, 2 )
		tip( ui.PreviewToggle, "When ON, items will be moved to their saved positions for the current Frame.\n\nWhen OFF, items will NOT be moved to their saved positions.\n\nNOTE: You may use this feature to copy Frames. To do so, check Preview while on the Frame that you wish to copy. Next, uncheck Preview and move to the Frame that you want to copy it into. Finally, click Save Frame." )

		ui.LoopToggle = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "LoopToggle", ui.FrameGroup, "ZO_CheckButton" )
		ZO_CheckButton_SetLabelText( ui.LoopToggle, "Loop" )
		ZO_CheckButton_SetToggleFunction( ui.LoopToggle, function()
			local _, _, scene = EHT.Data.GetCurrentHouse()
			if nil ~= scene then scene.Loop = ZO_CheckButton_IsChecked( ui.LoopToggle ) end
			EHT.UI.RefreshAnimationDialog()
		end )
		ui.LoopToggle:GetChild( 1 ):SetFont( "ZoFontWinH5" )
		ui.LoopToggle:SetAnchor( TOPLEFT, ui.FrameGroup, TOPLEFT, 0, 60 )
		tip( ui.LoopToggle, "Loop this scene any time it is played." )

		ui.StopButton = EHT.UI.CreateButton(
			prefix .. "StopButton",
			ui.FrameGroup,
			"Stop",
			{ { TOP, ui.FrameGroup, TOP, 0, 0 } },
			function() EHT.Biz.StopScene() end )

		ui.RewindButton = EHT.UI.CreateButton(
			prefix .. "RewindButton",
			ui.FrameGroup,
			"<< Rew",
			{ { RIGHT, ui.StopButton, LEFT, -2, 0 } },
			function() EHT.Biz.RewindScene() end )

		ui.PlayButton = EHT.UI.CreateButton(
			prefix .. "PlayButton",
			ui.FrameGroup,
			"Play >>",
			{ { LEFT, ui.StopButton, RIGHT, 2, 0 } },
			function()
				local _, _, scene = EHT.Data.GetCurrentHouse()
				if nil ~= scene then
					if scene.FrameIndex >= #scene.Frames then scene.FrameIndex = 1 end
					EHT.Biz.PlayScene()
				end
			end )

		ui.RecordButton = EHT.UI.CreateButton(
			prefix .. "RecordButton",
			ui.FrameGroup,
			"|cff3333Record|r",
			{ { TOPRIGHT, ui.FrameGroup, TOPRIGHT, 0, 0 } },
			function()
				local _, _, scene = EHT.Data.GetCurrentHouse()
				if nil ~= scene then
					if 1 >= #scene.Frames then
						EHT.Biz.RecordScene()
					else
						EHT.UI.ShowConfirmationDialog( "Record Scene", "Recording will insert new frames after the current frame.\n\nBegin recording now?", EHT.Biz.RecordScene, nil )
					end
				end
			end )
		tip( ui.RecordButton, "Begin recording all changes made to this scene's furniture.\nA new frame will be created for each change made." )

		ui.FrameIndex = EHT.CreateControl( prefix .. "FrameIndex", ui.FrameGroup, CT_SLIDER )
		ui.FrameIndex:SetAnchor( TOPLEFT, ui.FrameGroup, TOPLEFT, 35, 30 )
		ui.FrameIndex:SetAnchor( TOPRIGHT, ui.FrameGroup, TOPRIGHT, -50, 30 )
		ui.FrameIndex:SetHeight( 20 )
		ui.FrameIndex:SetMouseEnabled( true )
		ui.FrameIndex:SetOrientation( ORIENTATION_HORIZONTAL )
		ui.FrameIndex:SetThumbTexture( "EsoUI/Art/Miscellaneous/scrollbox_elevator.dds", "EsoUI/Art/Miscellaneous/scrollbox_elevator_disabled.dds", nil, 8, 16 )
		ui.FrameIndex:SetMinMax( 1, 1 )
		ui.FrameIndex:SetValueStep( 1 )
		ui.FrameIndex:SetValue( 1 )
		ui.FrameIndex:SetHandler( "OnValueChanged", function( self, value, eventReason )
			if eventReason == EVENT_REASON_SOFTWARE then return end
			if not EHT.UI.CanEditAnimation() then return end

			local _, _, scene = EHT.Data.GetCurrentHouse()
			if nil ~= scene then

				value = math.min( value, #scene.Frames )
				scene.FrameIndex = value
				EHT.Biz.PlayScene( scene.FrameIndex, true )

			end

			EHT.UI.RefreshAnimationDialog()
		end )

		ui.FrameIndexBackdrop = EHT.CreateControl( nil, ui.FrameGroup, CT_BACKDROP )
		ui.FrameIndexBackdrop:SetCenterColor( 0, 0, 0 )
		ui.FrameIndexBackdrop:SetAnchor( TOPLEFT, ui.FrameIndex, TOPLEFT, 0, 4 )
		ui.FrameIndexBackdrop:SetAnchor( BOTTOMRIGHT, ui.FrameIndex, BOTTOMRIGHT, 0, -4 )
		ui.FrameIndexBackdrop:SetEdgeTexture( "EsoUI/Art/Tooltips/UI-SliderBackdrop.dds", 32, 4 )

		ui.FrameIndexLabel = EHT.CreateControl( nil, ui.FrameGroup, CT_LABEL )
		ui.FrameIndexLabel:SetFont( "ZoFontWinH4" )
		ui.FrameIndexLabel:SetAnchor( TOP, ui.FrameIndex, BOTTOM, 0, 0 )
		ui.FrameIndexLabel:SetText( "Frame" )

		ui.FrameIndexMinLabel = EHT.CreateControl( nil, ui.FrameGroup, CT_LABEL )
		ui.FrameIndexMinLabel:SetFont( "$(BOLD_FONT)|$(KB_15)|soft-shadow-thin" )
		ui.FrameIndexMinLabel:SetAnchor( RIGHT, ui.FrameIndex, LEFT, -5, -1 )
		ui.FrameIndexMinLabel:SetText( "1" )
		ui.FrameIndexMinLabel:SetWidth( 10 )
		ui.FrameIndexMinLabel:SetHorizontalAlignment( TEXT_ALIGN_RIGHT )

		ui.FrameIndexMaxLabel = EHT.CreateControl( nil, ui.FrameGroup, CT_LABEL )
		ui.FrameIndexMaxLabel:SetFont( "$(BOLD_FONT)|$(KB_15)|soft-shadow-thin" )
		ui.FrameIndexMaxLabel:SetAnchor( LEFT, ui.FrameIndex, RIGHT, 5, -1 )
		ui.FrameIndexMaxLabel:SetText( "1" )
		ui.FrameIndexMaxLabel:SetWidth( 24 )
		ui.FrameIndexMaxLabel:SetHorizontalAlignment( TEXT_ALIGN_LEFT )

		ui.PrevFrameButton = EHT.UI.CreateButton(
			prefix .. "PrevFrameButton",
			ui.FrameGroup,
			"<<",
			{ { RIGHT, ui.FrameIndexMinLabel, LEFT, -2, -3 } },
			function()
				local _, _, scene = EHT.Data.GetCurrentHouse()
				if nil ~= scene and scene.FrameIndex > 1 then EHT.Biz.PlayScene( scene.FrameIndex - 1, true ) end
			end )

		ui.NextFrameButton = EHT.UI.CreateButton(
			prefix .. "NextFrameButton",
			ui.FrameGroup,
			">>",
			{ { LEFT, ui.FrameIndexMaxLabel, RIGHT, 2, -3 } },
			function()
				local _, _, scene = EHT.Data.GetCurrentHouse()
				if nil ~= scene and scene.FrameIndex < #scene.Frames then EHT.Biz.PlayScene( scene.FrameIndex + 1, true ) end
			end )

		-- Manage Frames Group

		ui.ManageFramesGroup = EHT.CreateControl( prefix .. "ManageFramesGroup", ui.EditSceneGroup, CT_CONTROL )
		ui.ManageFramesGroup:SetAnchor( TOPLEFT, ui.FrameGroup, BOTTOMLEFT, 0, 2 )
		ui.ManageFramesGroup:SetAnchor( TOPRIGHT, ui.FrameGroup, BOTTOMRIGHT, 0, 2 )
		ui.ManageFramesGroup:SetResizeToFitDescendents( true )

		ui.SaveFrameButton = EHT.UI.CreateButton(
			prefix .. "SaveFrameButton",
			ui.ManageFramesGroup,
			"Save Frame",
			{ { TOPRIGHT, ui.ManageFramesGroup, TOP, 5, 0 } },
			function() if not EHT.UI.CanEditAnimation() then return end EHT.Biz.UpdateSceneFrame() end )
		ui.SaveFrameButton:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		tip( ui.SaveFrameButton, "Save changes made to this frame." )

		ui.DeleteFrameButton = EHT.UI.CreateButton(
			prefix .. "DeleteFrameButton",
			ui.ManageFramesGroup,
			"Delete",
			{ { TOPLEFT, ui.ManageFramesGroup, TOP, 15, 0 } },
			function() if not EHT.UI.CanEditAnimation() then return end EHT.Biz.DeleteSceneFrame() end )
		ui.DeleteFrameButton:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		tip( ui.DeleteFrameButton, "Delete this frame." )

		ui.InsertBeforeButton = EHT.UI.CreateButton(
			prefix .. "InsertBeforeButton",
			ui.ManageFramesGroup,
			"< Insert",
			{ { TOPLEFT, ui.ManageFramesGroup, TOPLEFT, 0, 0 } },
			function() if not EHT.UI.CanEditAnimation() then return end EHT.Biz.InsertSceneFrame( nil, true ) end )
		ui.InsertBeforeButton:SetHorizontalAlignment( TEXT_ALIGN_RIGHT )
		tip( ui.InsertBeforeButton, "Insert a new frame before this frame." )

		ui.InsertAfterButton = EHT.UI.CreateButton(
			prefix .. "InsertAfterButton",
			ui.ManageFramesGroup,
			"Insert >",
			{ { TOPRIGHT, ui.ManageFramesGroup, TOPRIGHT, 0, 0 } },
			function() if not EHT.UI.CanEditAnimation() then return end EHT.Biz.InsertSceneFrame( nil, false ) end )
		ui.InsertAfterButton:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		tip( ui.InsertAfterButton, "Insert a new frame after this frame." )

		-- Frame Details Group 

		ui.FrameDetailsGroup = EHT.CreateControl( prefix .. "FrameDetailsGroup", ui.EditSceneGroup, CT_CONTROL )
		ui.FrameDetailsGroup:SetAnchor( TOPLEFT, ui.ManageFramesGroup, BOTTOMLEFT, 0, 10 )
		ui.FrameDetailsGroup:SetAnchor( TOPRIGHT, ui.ManageFramesGroup, BOTTOMRIGHT, 0, 10 )
		ui.FrameDetailsGroup:SetResizeToFitDescendents( true )

		ui.FrameDurationGroup = EHT.CreateControl( prefix .. "FrameDurationGroup", ui.FrameDetailsGroup, CT_CONTROL )
		ui.FrameDurationGroup:SetAnchor( TOP, ui.FrameDetailsGroup, TOP, 0, 0 )
		ui.FrameDurationGroup:SetResizeToFitDescendents( true )

		ui.FrameDurationLabel = EHT.CreateControl( nil, ui.FrameDurationGroup, CT_LABEL )
		ui.FrameDurationLabel:SetFont( "ZoFontWinH5" )
		ui.FrameDurationLabel:SetAnchor( TOPLEFT, ui.FrameDurationGroup, TOPLEFT, 0, 0 )
		ui.FrameDurationLabel:SetText( "Frame duration" )
		ui.FrameDurationLabel:SetHorizontalAlignment( TEXT_ALIGN_LEFT )

		ui.FrameDurationBackdrop = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "FrameDurationBackdrop", ui.FrameDurationGroup, "ZO_EditBackdrop" )
		ui.FrameDurationBackdrop:SetAnchor( LEFT, ui.FrameDurationLabel, RIGHT, 6, 0 )
		ui.FrameDurationBackdrop:SetDimensions( 42, 25 )

		ui.FrameDuration = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "FrameDuration", ui.FrameDurationBackdrop, "ZO_DefaultEditForBackdrop" ) 
		ui.FrameDuration:SetFont( "ZoFontWinH5" )
		ui.FrameDuration:SetAnchor( TOPLEFT, ui.FrameDurationBackdrop, TOPLEFT, 4, 0 )
		ui.FrameDuration:SetAnchor( BOTTOMRIGHT, ui.FrameDurationBackdrop, BOTTOMRIGHT, -4, 0 )
		ui.FrameDuration:SetMaxInputChars( 6 )
		ui.FrameDuration:SetHandler( "OnFocusLost", function()
			if not EHT.UI.CanEditAnimation() then return end
			local _, _, _, frame = EHT.Data.GetCurrentHouse()
			if "table" == type(frame) then
				frame.Duration = tonumber( ui.FrameDuration:GetText() )
				if nil == frame.Duration or 0 >= frame.Duration then
					frame.Duration = EHT.CONST.SCENE_FRAME_DURATION_DEFAULT
				else
					frame.Duration = frame.Duration * 1000
				end
			end
			EHT.UI.RefreshAnimationDialog()
		end )

		ui.FrameDurationLabel2 = EHT.CreateControl( nil, ui.FrameDurationGroup, CT_LABEL )
		ui.FrameDurationLabel2:SetFont( "ZoFontWinH5" )
		ui.FrameDurationLabel2:SetAnchor( LEFT, ui.FrameDurationBackdrop, RIGHT, 4, 0 )
		ui.FrameDurationLabel2:SetText( "sec" )
		ui.FrameDurationLabel2:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		ui.FrameDurationLabel2:SetVerticalAlignment( TEXT_ALIGN_CENTER )

		ui.SetAllSubsequentFrameDurations = EHT.UI.CreateButton(
			prefix .. "SetAllSubsequentFrameDurations",
			ui.FrameDurationGroup,
			"Update Remaining Frames",
			{ { LEFT, ui.FrameDurationLabel2, RIGHT, 10, 0 } },
			function()
				if not EHT.UI.CanEditAnimation() then return end

				local _, _, _, frame = EHT.Data.GetCurrentHouse()
				if "table" ~= type(frame) then
					EHT.UI.ShowAlertDialog("Frames must be added to a Scene first.", "Frames must be added to a Scene first.")
					return
				end

				local duration = frame.Duration
				if nil == duration then duration = EHT.CONST.SCENE_FRAME_DURATION_DEFAULT end

				EHT.UI.ShowConfirmationDialog( "Update Duration of all Subsequent Frames",
					"Set the duration of all subsequent frames to " .. tostring( duration / 1000 ) .. " seconds?",
					function()
						EHT.Biz.UpdateAllSubsequentFrameDurations()
					end )
			end )
		tip( ui.SetAllSubsequentFrameDurations, "Update the duration of all frames that follow to match this frame's duration." )

		c = EHT.UI.Picklist:New( prefix .. "FrameSound", ui.FrameDetailsGroup )
		ui.FrameSound = c
		c:SetAnchor( TOPLEFT, ui.FrameDurationGroup, BOTTOMLEFT, 0, 6 )
		c:SetAnchor( TOPRIGHT, ui.FrameDurationGroup, BOTTOMRIGHT, -28, 6 )
		c:SetHeight( 26 )
		tip( c:GetControl(),
			"Select a sound effect for this frame during playback.\n\n" ..
			"Please note the following:\n\n" .. 
			"Verify that your \"Settings > Audio > Interface Volume\" is sufficiently loud enough to hear these sounds.\n\n" ..
			"Other players that are in your Group and in your House, and that have Essential Housing Tools installed can also hear these sound effects as this Scene is playing." )

		EHT.UI.UpdateFrameSoundsList()

		c = EHT.CreateControl( prefix .. "TestFrameSound", ui.FrameDetailsGroup, CT_TEXTURE )
		ui.TestFrameSound = c
		c:SetAnchor( LEFT, ui.FrameSound:GetControl(), RIGHT, 2, 0 )
		c:SetTexture( "esoui/art/charactercreate/charactercreate_audio_up.dds" )
		c:SetDimensions( 26, 26 )
		c:SetMouseEnabled( true )
		c:SetHandler( "OnMouseDown", function()
			local soundId = EHT.UI.GetSelectedFrameSound()
			if nil ~= soundId then
				PlaySound( soundId )
			else
				EHT.UI.PlaySoundFailure()
			end
		end )

		-- Scene Tools

		div = EHT.CreateControl( nil, parent, CT_TEXTURE )
		div:SetHeight( 5 )
		div:SetAlpha( 0.5 )
		div:SetAnchor( BOTTOMLEFT, parent, BOTTOMLEFT, 0, -30 )
		div:SetAnchor( BOTTOMRIGHT, parent, BOTTOMRIGHT, 0, -30 )
		div:SetTexture( "EsoUI/Art/Miscellaneous/horizontalDivider.dds" )
		div:SetTextureCoords( 0.181640625, 0.818359375, 0, 1 )

		c = EHT.UI.Picklist:New( prefix .. "SceneToolsDropdown", parent, BOTTOMLEFT, parent, BOTTOMLEFT, 0, -1, 180, 26 )
		ui.SceneToolsDropdown = c

		local sceneTools, sceneSubTools = { }, nil
		local sceneOps = EHT.CONST.SCENE_OPERATIONS

		table.insert( sceneTools, sceneOps.DEFAULT )

		sceneSubTools = { }
		table.insert( sceneTools, " " )
		table.insert( sceneTools, "  " .. sceneOps.ARRANGE_OPERATIONS.DEFAULT )
		table.insert( sceneSubTools, "    " .. sceneOps.ARRANGE_OPERATIONS.ALIGN_SCENE_WITH_TARGET_AXIS_X )
		table.insert( sceneSubTools, "    " .. sceneOps.ARRANGE_OPERATIONS.ALIGN_SCENE_WITH_TARGET_AXIS_Y )
		table.insert( sceneSubTools, "    " .. sceneOps.ARRANGE_OPERATIONS.ALIGN_SCENE_WITH_TARGET_AXIS_Z )
		table.insert( sceneSubTools, "    " .. sceneOps.ARRANGE_OPERATIONS.BRING_TO_ME )
		table.insert( sceneSubTools, "    " .. sceneOps.ARRANGE_OPERATIONS.CENTER_ON_TARGET )
		table.insert( sceneSubTools, "    " .. sceneOps.ARRANGE_OPERATIONS.CENTER_BETWEEN_2_TARGETS )
		table.sort( sceneSubTools )
		for _, optName in ipairs( sceneSubTools ) do table.insert( sceneTools, optName ) end

		sceneSubTools = { }
		table.insert( sceneTools, " " )
		table.insert( sceneTools, "  " .. sceneOps.EDIT_OPERATIONS.DEFAULT )
		table.insert( sceneSubTools, "    " .. sceneOps.EDIT_OPERATIONS.COPY_SCENE )
		table.insert( sceneSubTools, "    " .. sceneOps.EDIT_OPERATIONS.MERGE_WITH_SCENE )
		table.insert( sceneSubTools, "    " .. sceneOps.EDIT_OPERATIONS.APPEND_WITH_SCENE )
		table.insert( sceneSubTools, "    " .. sceneOps.EDIT_OPERATIONS.REVERSE_SCENE )
		table.sort( sceneSubTools )
		for _, optName in ipairs( sceneSubTools ) do table.insert( sceneTools, optName ) end

		sceneSubTools = { }
		table.insert( sceneTools, " " )
		table.insert( sceneTools, "  " .. sceneOps.EDIT_ITEM_OPERATIONS.DEFAULT )
		table.insert( sceneSubTools, "    " .. sceneOps.EDIT_ITEM_OPERATIONS.SELECT_ITEMS )
		table.insert( sceneSubTools, "    " .. sceneOps.EDIT_ITEM_OPERATIONS.ADD_ITEMS )
		table.insert( sceneSubTools, "    " .. sceneOps.EDIT_ITEM_OPERATIONS.REMOVE_ITEMS )
		table.sort( sceneSubTools )
		for _, optName in ipairs( sceneSubTools ) do table.insert( sceneTools, optName ) end

		for _, optName in ipairs( sceneTools ) do c:AddItem( optName, function() EHT.UI.ArrangeSelectedItems( ui.SceneToolsDropdown, optName ) end ) end
		c:SelectFirstItem()

		EHT.UI.SetInfoTooltip( ui.SceneToolsDropdown:GetControl(), "Arrange and edit your Scene with a variety of tools." )

	end

	---- Load Scene Group ----

	ui.LoadSceneGroup = EHT.CreateControl( prefix .. "LoadSceneGroup", parent, CT_CONTROL )
	ui.LoadSceneGroup:SetAnchor( TOPLEFT, parent, TOPLEFT, 10, 10 )
	ui.LoadSceneGroup:SetAnchor( TOPRIGHT, parent, TOPRIGHT, -15, 10 )
	ui.LoadSceneGroup:SetHidden( true )
	ui.LoadSceneGroup:SetResizeToFitDescendents( true )
	ui.LoadSceneGroup:SetResizeToFitPadding( 10, 15 )

	do

		ui.LoadSceneLabel = EHT.CreateControl( nil, ui.LoadSceneGroup, CT_LABEL )
		ui.LoadSceneLabel:SetFont( "ZoFontWinH5" )
		ui.LoadSceneLabel:SetAnchor( TOP, ui.LoadSceneGroup, TOP, 0, 0 )
		ui.LoadSceneLabel:SetText( "Load a saved Scene: " )

		ui.LoadScenes = EHT.UI.Picklist:New( prefix .. "LoadScenes", ui.LoadSceneGroup, TOP, ui.LoadSceneLabel, BOTTOM, 0, 5, 300, 25 )
		ui.LoadScenes:SetSorted( true )

		ui.LoadButton = EHT.UI.CreateButton(
			prefix .. "LoadButton",
			ui.LoadSceneGroup,
			"Load",
			{ { TOPLEFT, ui.LoadScenes:GetControl(), BOTTOMLEFT, 0, 15 } },
			function()
				local sceneName = ui.LoadScenes:GetSelectedItem()

				if nil == sceneName or "" == sceneName then
					EHT.UI.ShowErrorDialog( "Select a Saved Scene", "Select a Saved Scene to load.", function() end )
					return
				end

				local loadSceneFunc = function()
					local _, _, scene = EHT.Data.GetCurrentHouse()

					if nil ~= scene and 0 < #scene.Frames then
						EHT.UI.ShowConfirmationDialog( "Load Scene", "Abandon current Scene and load the Scene '" .. sceneName .. "'?", function() EHT.Biz.LoadScene( sceneName ) end )
					else
						EHT.Biz.LoadScene( sceneName )
					end
				end

				if EHT.SavedVars.WarnLoadScene then
					EHT.UI.ShowConfirmationDialog( "Warning", "Loading a Scene restores all of the Scene's furniture to their positions in the first Frame.", function() loadSceneFunc() end )
				else
					loadSceneFunc()
				end
			end )

		ui.DeleteButton = EHT.UI.CreateButton(
			prefix .. "DeleteButton",
			ui.LoadSceneGroup,
			"Delete",
			{ { LEFT, ui.LoadButton, RIGHT, 15, 0 } },
			function()
				local sceneName = ui.LoadScenes:GetSelectedItem()

				if nil == sceneName or "" == sceneName then
					EHT.UI.ShowErrorDialog( "Select a saved scene", "Select a saved scene to delete.", function() end )
					return
				end

				EHT.UI.ShowConfirmationDialog( "Warning", string.format( "Delete the saved scene \"%s\"?", sceneName ), function() EHT.Data.DeleteScene( sceneName ) end )
			end )

		ui.CancelLoadButton = EHT.UI.CreateButton(
			prefix .. "CancelLoadButton",
			ui.LoadSceneGroup,
			"Cancel",
			{ { TOPRIGHT, ui.LoadScenes:GetControl(), BOTTOMRIGHT, 0, 15 } },
			function() EHT.UI.ShowToolTab( EHT.CONST.TOOL_TABS.ANIMATE, EHT.CONST.TOOL_TABS_STATE.DEFAULT ) end )

	end

	---- Save Scene Group ----

	ui.SaveSceneGroup = EHT.CreateControl( prefix .. "SaveSceneGroup", parent, CT_CONTROL )
	ui.SaveSceneGroup:SetAnchor( TOPLEFT, parent, TOPLEFT, 15, 10 )
	ui.SaveSceneGroup:SetAnchor( TOPRIGHT, parent, TOPRIGHT, -15, 15 )
	ui.SaveSceneGroup:SetHidden( true )
	ui.SaveSceneGroup:SetResizeToFitDescendents( true )
	ui.SaveSceneGroup:SetResizeToFitPadding( 10, 20 )

	do

		ui.SaveSceneLabel = EHT.CreateControl( nil, ui.SaveSceneGroup, CT_LABEL )
		ui.SaveSceneLabel:SetFont( "ZoFontWinH5" )
		ui.SaveSceneLabel:SetAnchor( TOP, ui.SaveSceneGroup, TOP, 0, 0 )
		ui.SaveSceneLabel:SetText( "Save as Existing Scene: " )

		ui.SaveScenes = EHT.UI.Picklist:New( prefix .. "SaveScenes", ui.SaveSceneGroup, TOP, ui.SaveSceneLabel, BOTTOM, 0, 5, 300, 25 )
		ui.SaveScenes:SetSorted( true )

		ui.SaveButton = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "SaveButton", ui.SaveSceneGroup, "ZO_DefaultButton" )
		ui.SaveButton:SetDimensions( 160, 25 )
		ui.SaveButton:SetAnchor( TOP, ui.SaveScenes:GetControl(), BOTTOM, 0, 5 )
		ui.SaveButton:SetFont( "ZoFontWinH5" )
		ui.SaveButton:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		ui.SaveButton:SetText( "Overwrite Saved Scene" )
		ui.SaveButton:SetClickSound( "Click" )
		ui.SaveButton:SetHandler( "OnClicked", function()
			local sceneName = ui.SaveScenes:GetSelectedItem()

			if nil == sceneName or "" == sceneName then
				EHT.UI.ShowErrorDialog( "Select a Saved Scene", "Select a Saved Scene to overwrite.", function() end )
				return
			end

			if nil ~= EHT.Data.GetScene( sceneName ) then
				EHT.UI.ShowConfirmationDialog( "Save Scene", "Overwrite Saved Scene '" .. sceneName .. "'?", function() EHT.Biz.SaveScene( sceneName ) end )
			else
				EHT.Biz.SaveScene( sceneName )
			end
		end )

		ui.SaveAsSceneLabel = EHT.CreateControl( nil, ui.SaveSceneGroup, CT_LABEL )
		ui.SaveAsSceneLabel:SetFont( "ZoFontWinH5" )
		ui.SaveAsSceneLabel:SetAnchor( TOP, ui.SaveButton, BOTTOM, 0, 20 )
		ui.SaveAsSceneLabel:SetText( "Save as New Scene: " )

		ui.SaveSceneNameBackdrop = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "SaveSceneNameBackdrop", ui.SaveSceneGroup, "ZO_EditBackdrop" )
		ui.SaveSceneNameBackdrop:SetAnchor( TOP, ui.SaveAsSceneLabel, BOTTOM, 0, 5 )
		ui.SaveSceneNameBackdrop:SetDimensions( 300, 25 )

		ui.SaveSceneName = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "SaveSceneName", ui.SaveSceneNameBackdrop, "ZO_DefaultEditForBackdrop" ) 
		ui.SaveSceneName:SetFont( "ZoFontWinH5" )
		ui.SaveSceneName:SetAnchor( TOPLEFT, ui.SaveSceneNameBackdrop, TOPLEFT, 1, 0 )
		ui.SaveSceneName:SetAnchor( BOTTOMRIGHT, ui.SaveSceneNameBackdrop, BOTTOMRIGHT, -1, 0 )
		ui.SaveSceneName:SetMaxInputChars( 40 )

		ui.SaveAsButton = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "SaveAsButton", ui.SaveSceneGroup, "ZO_DefaultButton" )
		ui.SaveAsButton:SetDimensions( 140, 25 )
		ui.SaveAsButton:SetAnchor( TOP, ui.SaveSceneNameBackdrop, BOTTOM, -75, 5 )
		ui.SaveAsButton:SetFont( "ZoFontWinH5" )
		ui.SaveAsButton:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		ui.SaveAsButton:SetText( "Save Scene As" )
		ui.SaveAsButton:SetClickSound( "Click" )
		ui.SaveAsButton:SetHandler( "OnClicked", function()
			local sceneName = ui.SaveSceneName:GetText()

			if nil == sceneName or "" == sceneName then
				EHT.UI.ShowErrorDialog( "Enter a Scene Name", "Enter a Scene Name.", function() end )
				return
			end

			if nil ~= EHT.Data.GetScene( sceneName ) then
				EHT.UI.ShowConfirmationDialog( "Save Scene", "Overwrite Saved Scene '" .. sceneName .. "'?", function() EHT.Biz.SaveScene( sceneName ) end )
			else
				EHT.Biz.SaveScene( sceneName )
			end
		end )

		ui.CancelSaveButton = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "CancelSaveButton", ui.SaveSceneGroup, "ZO_DefaultButton" )
		ui.CancelSaveButton:SetDimensions( 90, 25 )
		ui.CancelSaveButton:SetAnchor( TOP, ui.SaveSceneNameBackdrop, BOTTOM, 50, 5 )
		ui.CancelSaveButton:SetFont( "ZoFontWinH5" )
		ui.CancelSaveButton:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		ui.CancelSaveButton:SetText( "Cancel" )
		ui.CancelSaveButton:SetClickSound( "Click" )
		ui.CancelSaveButton:SetHandler( "OnClicked", function() EHT.UI.ShowToolTab( EHT.CONST.TOOL_TABS.ANIMATE, EHT.CONST.TOOL_TABS_STATE.DEFAULT ) end )

	end

	---- Merge Scene Group ----

	ui.MergeSceneGroup = EHT.CreateControl( prefix .. "MergeSceneGroup", parent, CT_CONTROL )
	ui.MergeSceneGroup:SetAnchor( TOPLEFT, parent, TOPLEFT, 15, 10 )
	ui.MergeSceneGroup:SetAnchor( TOPRIGHT, parent, TOPRIGHT, -15, 15 )
	ui.MergeSceneGroup:SetHidden( true )
	ui.MergeSceneGroup:SetResizeToFitDescendents( true )
	ui.MergeSceneGroup:SetResizeToFitPadding( 10, 20 )

	do

		ui.MergeSceneLabel = EHT.CreateControl( nil, ui.MergeSceneGroup, CT_LABEL )
		ui.MergeSceneLabel:SetFont( "ZoFontWinH5" )
		ui.MergeSceneLabel:SetAnchor( TOP, ui.MergeSceneGroup, TOP, 0, 0 )
		ui.MergeSceneLabel:SetText( "Merge with Scene: " )

		ui.MergeScenes = EHT.UI.Picklist:New( prefix .. "MergeScenes", ui.MergeSceneGroup, TOP, ui.MergeSceneLabel, BOTTOM, 0, 5, 300, 25 )
		ui.MergeScenes:SetSorted( true )

		ui.MergeAsSceneLabel = EHT.CreateControl( nil, ui.MergeSceneGroup, CT_LABEL )
		ui.MergeAsSceneLabel:SetFont( "ZoFontWinH5" )
		ui.MergeAsSceneLabel:SetAnchor( TOP, ui.MergeScenes:GetControl(), BOTTOM, 0, 15 )
		ui.MergeAsSceneLabel:SetText( "Merge as New Scene: " )

		ui.MergeSceneNameBackdrop = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "MergeSceneNameBackdrop", ui.MergeSceneGroup, "ZO_EditBackdrop" )
		ui.MergeSceneNameBackdrop:SetAnchor( TOP, ui.MergeAsSceneLabel, BOTTOM, 0, 5 )
		ui.MergeSceneNameBackdrop:SetDimensions( 300, 25 )

		ui.MergeSceneName = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "MergeSceneName", ui.MergeSceneNameBackdrop, "ZO_DefaultEditForBackdrop" ) 
		ui.MergeSceneName:SetFont( "ZoFontWinH5" )
		ui.MergeSceneName:SetAnchor( TOPLEFT, ui.MergeSceneNameBackdrop, TOPLEFT, 1, 0 )
		ui.MergeSceneName:SetAnchor( BOTTOMRIGHT, ui.MergeSceneNameBackdrop, BOTTOMRIGHT, -1, 0 )
		ui.MergeSceneName:SetMaxInputChars( 40 )

		tipMsg = "When enabled while merging two Scenes of different run times, the Frames from the shorter run time Scene will be repeated as necessary to match the run time of the longer duration Scene."

		c = EHT.CreateControl( nil, ui.MergeSceneGroup, CT_CONTROL )
		ui.MergeSceneLoopedContainer = c
		c:SetAnchor( TOP, ui.MergeSceneNameBackdrop, BOTTOM, 0, 15 )
		c:SetResizeToFitDescendents( true )

		c = EHT.CreateControl( nil, ui.MergeSceneLoopedContainer, CT_LABEL )
		ui.MergeSceneLoopedLabel = c
		c:SetFont( "ZoFontWinH5" )
		c:SetAnchor( TOP, ui.MergeSceneLoopedContainer, TOP, 12, 0 )
		c:SetText( "Loop frames if necessary to match Scene lengths" )
		c:SetMouseEnabled( true )

		tip( c, tipMsg )

		c = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "MergeSceneLooped", ui.MergeSceneLoopedContainer, "ZO_CheckButton" )
		ui.MergeSceneLooped = c
		c:SetAnchor( RIGHT, ui.MergeSceneLoopedLabel, LEFT, -6, -1 )
		ZO_CheckButton_SetCheckState( c, true )

		tip( c, tipMsg )

		ui.MergeSceneLoopedLabel:SetHandler( "OnMouseUp", function( control, button, upInside )
			local checked = ZO_CheckButton_IsChecked( ui.MergeSceneLooped )
			ZO_CheckButton_SetCheckState( ui.MergeSceneLooped, not checked )
		end )

		ui.MergeAsButton = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "MergeAsButton", ui.MergeSceneGroup, "ZO_DefaultButton" )
		ui.MergeAsButton:SetDimensions( 140, 25 )
		ui.MergeAsButton:SetAnchor( TOPRIGHT, ui.MergeSceneLoopedContainer, BOTTOM, 15, 15 )
		ui.MergeAsButton:SetFont( "ZoFontWinH5" )
		ui.MergeAsButton:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		ui.MergeAsButton:SetText( "Merge Scenes" )
		ui.MergeAsButton:SetClickSound( "Click" )
		ui.MergeAsButton:SetHandler( "OnClicked", function()
			local targetSceneName = ui.MergeSceneName:GetText()
			local sourceSceneName = ui.MergeScenes:GetSelectedItem()
			local loopFrames = ZO_CheckButton_IsChecked( ui.MergeSceneLooped )

			if nil == sourceSceneName or "" == sourceSceneName then
				EHT.UI.ShowErrorDialog( "Select a Scene", "Select a Scene to merge with.", function() end )
				return
			end

			if nil == targetSceneName or "" == targetSceneName then
				EHT.UI.ShowErrorDialog( "Enter a Scene Name", "Enter a Scene Name.", function() end )
				return
			end

			local callback = function( scene, message )
				if nil == scene then
					EHT.UI.ShowErrorDialog( "Merge Failed", "Merge failed.\n" .. ( message or "" ), function() end )
					return
				end

				EHT.UI.ShowAlertDialog( "Merge Complete", "Merge complete.", function() end )
				EHT.Biz.LoadScene( targetSceneName )
			end

			if nil ~= EHT.Data.GetScene( targetSceneName ) then
				EHT.UI.ShowConfirmationDialog(
					"Merge Scene",
					"Overwrite Saved Scene '" .. targetSceneName .. "'?",
					function()
						EHT.Biz.MergeScenes( nil, sourceSceneName, targetSceneName, loopFrames, callback, true )
					end )
			else
				EHT.Biz.MergeScenes( nil, sourceSceneName, targetSceneName, loopFrames, callback )
			end
		end )

		ui.CancelMergeButton = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "CancelMergeButton", ui.MergeSceneGroup, "ZO_DefaultButton" )
		ui.CancelMergeButton:SetDimensions( 90, 25 )
		ui.CancelMergeButton:SetAnchor( TOPLEFT, ui.MergeSceneLoopedContainer, BOTTOM, 15, 15 )
		ui.CancelMergeButton:SetFont( "ZoFontWinH5" )
		ui.CancelMergeButton:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		ui.CancelMergeButton:SetText( "Cancel" )
		ui.CancelMergeButton:SetClickSound( "Click" )
		ui.CancelMergeButton:SetHandler( "OnClicked", function() EHT.UI.ShowToolTab( EHT.CONST.TOOL_TABS.ANIMATE, EHT.CONST.TOOL_TABS_STATE.DEFAULT ) end )

	end

	---- Append Scene Group ----

	ui.AppendSceneGroup = EHT.CreateControl( prefix .. "AppendSceneGroup", parent, CT_CONTROL )
	ui.AppendSceneGroup:SetAnchor( TOPLEFT, parent, TOPLEFT, 15, 10 )
	ui.AppendSceneGroup:SetAnchor( TOPRIGHT, parent, TOPRIGHT, -15, 15 )
	ui.AppendSceneGroup:SetHidden( true )
	ui.AppendSceneGroup:SetResizeToFitDescendents( true )
	ui.AppendSceneGroup:SetResizeToFitPadding( 10, 20 )

	do

		ui.AppendSceneLabel = EHT.CreateControl( nil, ui.AppendSceneGroup, CT_LABEL )
		ui.AppendSceneLabel:SetFont( "ZoFontWinH5" )
		ui.AppendSceneLabel:SetAnchor( TOP, ui.AppendSceneGroup, TOP, 0, 0 )
		ui.AppendSceneLabel:SetText( "Scene to append at the end: " )

		ui.AppendScenes = EHT.UI.Picklist:New( prefix .. "AppendScenes", ui.AppendSceneGroup, TOP, ui.AppendSceneLabel, BOTTOM, 0, 5, 300, 25 )
		ui.AppendScenes:SetSorted( true )

		ui.AppendAsSceneLabel = EHT.CreateControl( nil, ui.AppendSceneGroup, CT_LABEL )
		ui.AppendAsSceneLabel:SetFont( "ZoFontWinH5" )
		ui.AppendAsSceneLabel:SetAnchor( TOP, ui.AppendScenes:GetControl(), BOTTOM, 0, 15 )
		ui.AppendAsSceneLabel:SetText( "Save as New Scene: " )

		ui.AppendSceneNameBackdrop = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "AppendSceneNameBackdrop", ui.AppendSceneGroup, "ZO_EditBackdrop" )
		ui.AppendSceneNameBackdrop:SetAnchor( TOP, ui.AppendAsSceneLabel, BOTTOM, 0, 5 )
		ui.AppendSceneNameBackdrop:SetDimensions( 300, 25 )

		ui.AppendSceneName = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "AppendSceneName", ui.AppendSceneNameBackdrop, "ZO_DefaultEditForBackdrop" ) 
		ui.AppendSceneName:SetFont( "ZoFontWinH5" )
		ui.AppendSceneName:SetAnchor( TOPLEFT, ui.AppendSceneNameBackdrop, TOPLEFT, 1, 0 )
		ui.AppendSceneName:SetAnchor( BOTTOMRIGHT, ui.AppendSceneNameBackdrop, BOTTOMRIGHT, -1, 0 )
		ui.AppendSceneName:SetMaxInputChars( 40 )

		ui.AppendAsButton = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "AppendAsButton", ui.AppendSceneGroup, "ZO_DefaultButton" )
		ui.AppendAsButton:SetDimensions( 140, 25 )
		ui.AppendAsButton:SetAnchor( TOPRIGHT, ui.AppendSceneName, BOTTOM, 15, 15 )
		ui.AppendAsButton:SetFont( "ZoFontWinH5" )
		ui.AppendAsButton:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		ui.AppendAsButton:SetText( "Append Scenes" )
		ui.AppendAsButton:SetClickSound( "Click" )
		ui.AppendAsButton:SetHandler( "OnClicked", function()
			local targetSceneName = ui.AppendSceneName:GetText()
			local sourceSceneName = ui.AppendScenes:GetSelectedItem()

			if nil == sourceSceneName or "" == sourceSceneName then
				EHT.UI.ShowErrorDialog( "Select a Scene", "Select a Scene to Append onto the end of the current Scene.", function() end )
				return
			end

			if nil == targetSceneName or "" == targetSceneName then
				EHT.UI.ShowErrorDialog( "Enter a Scene Name", "Enter a Scene Name.", function() end )
				return
			end

			local callback = function( scene, message )
				if nil == scene then
					EHT.UI.ShowErrorDialog( "Append Failed", "Append failed.\n" .. ( message or "" ), function() end )
					return
				end

				EHT.UI.ShowAlertDialog( "Append Complete", "Append complete.", function() end )
				EHT.Biz.LoadScene( targetSceneName )
			end

			if nil ~= EHT.Data.GetScene( targetSceneName ) then
				EHT.UI.ShowConfirmationDialog(
					"Append Scene",
					"Overwrite Saved Scene '" .. targetSceneName .. "'?",
					function()
						EHT.Biz.AppendScenes( nil, sourceSceneName, targetSceneName, callback, true )
					end )
			else
				EHT.Biz.AppendScenes( nil, sourceSceneName, targetSceneName, callback )
			end
		end )

		ui.CancelAppendButton = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "CancelAppendButton", ui.AppendSceneGroup, "ZO_DefaultButton" )
		ui.CancelAppendButton:SetDimensions( 90, 25 )
		ui.CancelAppendButton:SetAnchor( TOPLEFT, ui.AppendAsButton, TOPRIGHT, 15, 0 )
		ui.CancelAppendButton:SetFont( "ZoFontWinH5" )
		ui.CancelAppendButton:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		ui.CancelAppendButton:SetText( "Cancel" )
		ui.CancelAppendButton:SetClickSound( "Click" )
		ui.CancelAppendButton:SetHandler( "OnClicked", function() EHT.UI.ShowToolTab( EHT.CONST.TOOL_TABS.ANIMATE, EHT.CONST.TOOL_TABS_STATE.DEFAULT ) end )

	end

end


function EHT.UI.SetupToolDialogTriggerTab( ui, parent, prefix, settings )

	local tip = function( control, message ) EHT.UI.SetInfoTooltip( control, message, BOTTOMRIGHT, nil, -8, TOPLEFT ) end
	local c, div, grp, sgrp

	-- Trigger List

	grp = EHT.CreateControl( prefix .. "TriggerContainer", parent, CT_CONTROL )
	ui.TriggerContainer = grp
	grp:SetAnchor( TOPLEFT, parent, TOPLEFT, 0, 0 )
	grp:SetAnchor( BOTTOMRIGHT, parent, BOTTOMRIGHT, 0, 0 )
	grp:SetResizeToFitDescendents( true )

	c = EHT.CreateControl( nil, grp, CT_LABEL )
	ui.TriggerLabel = c
	c:SetFont( "ZoFontWinH5" )
	c:SetAnchor( TOPLEFT, grp, TOPLEFT, 0, 0 )
	c:SetAnchor( TOPRIGHT, grp, TOPRIGHT, 0, 0 )
	c:SetText( "Load a saved trigger" )

	c = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "DisableTriggers", grp, "ZO_CheckButton" )
	ui.DisableTriggers = c
	c:SetAnchor( TOPRIGHT, grp, TOPRIGHT, -120, 4 )
	ZO_CheckButton_SetLabelText( c, "Disable Triggers" )
	ZO_CheckButtonLabel_SetTextColor( c, 1, 0.4, 0.4 )
	ZO_CheckButtonLabel_SetDefaultColors( c.label, ZO_ColorDef:New( 1, 0.4, 0.4, 1 ), ZO_ColorDef:New( 1, 0.6, 0.6, 1 ) )
	c.label:SetFont( "ZoFontWinH5" )
	ZO_CheckButton_SetToggleFunction( c, function( control, value )
		EHT.Biz.SetDisableTriggers( value )
	end )
	if EHT.SavedVars.DisableTriggers then
		ZO_CheckButton_SetCheckState( c, true )
	else
		ZO_CheckButton_SetCheckState( c, false )
	end
	EHT.Biz.SetDisableTriggers( EHT.SavedVars.DisableTriggers )
	tip( c, "Disables all trigger execution and clears any pending actions from the trigger queue." )

	c = EHT.UI.Picklist:New( prefix .. "TriggerList", grp )
	ui.TriggerList = c
	c:SetSorted( true )
	c:SetAnchor( TOPLEFT, ui.TriggerLabel, BOTTOMLEFT, 0, 3 )
	c:SetAnchor( TOPRIGHT, ui.TriggerLabel, BOTTOMRIGHT, 0, 3 )
	c:SetHeight( 26 )
	c:SetItemLines( 6 )
	tip( c:GetControl(), "Select a trigger to edit or delete, or click \"New\" to create a new trigger." )

	-- Trigger Actions

	grp = EHT.CreateControl( prefix .. "TriggerActionsContainer", grp, CT_CONTROL )
	ui.TriggerActionsContainer = grp
	grp:SetAnchor( TOPLEFT, ui.TriggerList:GetControl(), BOTTOMLEFT, 0, 1 )
	grp:SetAnchor( TOPRIGHT, ui.TriggerList:GetControl(), BOTTOMRIGHT, 0, 1 )
	grp:SetResizeToFitDescendents( true )

	ui.CreateTriggerButton = EHT.UI.CreateButton(
		prefix .. "CreateTriggerButton",
		grp,
		"New",
		{ { TOPLEFT, grp, TOPLEFT, 0, 0 } },
		function() EHT.UI.ShowConfirmationDialog( "New Trigger", "Create a new Trigger?", function() EHT.Biz.CreateTrigger() end ) end )

	ui.DeleteTriggerButton = EHT.UI.CreateButton(
		prefix .. "DeleteTriggerButton",
		grp,
		"Delete",
		{ { TOPRIGHT, grp, TOPRIGHT, 0, 0 } },
		function() EHT.UI.ShowConfirmationDialog( "Delete Trigger", "Delete this Trigger?", function() EHT.Biz.DeleteTrigger() end ) end )

	ui.SaveTriggerButton = EHT.UI.CreateButton(
		prefix .. "SaveTriggerButton",
		grp,
		"Save",
		{ { RIGHT, ui.DeleteTriggerButton, LEFT, -10, 0 } },
		function() EHT.Biz.SaveTrigger() end )

	-- Trigger Scrolling Region

	div = EHT.CreateControl( nil, grp, CT_TEXTURE )
	div:SetHeight( 5 )
	div:SetAlpha( 0.5 )
	div:SetAnchor( TOPLEFT, ui.TriggerList:GetControl(), BOTTOMLEFT, 0, 25 )
	div:SetAnchor( TOPRIGHT, ui.TriggerList:GetControl(), BOTTOMRIGHT, 0, 25 )
	div:SetTexture( "EsoUI/Art/Miscellaneous/horizontalDivider.dds" )
	div:SetTextureCoords( 0.181640625, 0.818359375, 0, 1 )

	grp = EHT.CreateControl( prefix .. "TriggerScroll", ui.TriggerContainer, CT_SCROLL )
	ui.TriggerScroll = grp
	grp:SetAnchor( TOPLEFT, div, BOTTOMLEFT, 0, 2 )
	grp:SetAnchor( BOTTOMRIGHT, ui.TriggerContainer, BOTTOMRIGHT, -15, 0 )
	grp:SetMouseEnabled( true )

	c = EHT.CreateControl( prefix .. "TriggerScrollBackground1", ui.TriggerContainer, CT_TEXTURE )
	ui.TriggerScrollBackground1 = c
	c:SetAnchor( TOPLEFT, div, BOTTOMLEFT, -4, -6 )
	c:SetAnchor( BOTTOMRIGHT, div, BOTTOMRIGHT, 0, -2 )
	c:SetTexture( "esoui/art/windows/gamepad/gp_nav1_hordividerflat.dds" )
	c:SetTextureCoords( 0.4, 0.6, 0, 1 )
	c:SetColor( 1, 1, 1, 1 )
	c:SetMouseEnabled( false )

	c = EHT.CreateControl( prefix .. "TriggerScrollBackground2", ui.TriggerContainer, CT_TEXTURE )
	ui.TriggerScrollBackground2 = c
	c:SetAnchor( TOPLEFT, div, BOTTOMLEFT, -4, -5 )
	c:SetAnchor( BOTTOMRIGHT, ui.TriggerContainer, BOTTOMLEFT, -3, 2 )
	c:SetTexture( "esoui/art/windows/gamepad/gp_nav1_hordividerflat.dds" )
	c:SetTextureCoordsRotation( -0.5 *  math.pi )
	c:SetTextureCoords( 0, 1, 0.4, 0.6 )
	c:SetColor( 1, 1, 1, 1 )
	c:SetMouseEnabled( false )

	c = EHT.CreateControl( prefix .. "TriggerScrollBackground3", ui.TriggerContainer, CT_TEXTURE )
	ui.TriggerScrollBackground3 = c
	c:SetAnchor( TOPLEFT, div, BOTTOMRIGHT, 0, -1 )
	c:SetAnchor( BOTTOMRIGHT, ui.TriggerContainer, BOTTOMRIGHT, -2, 2 )
	c:SetTexture( "esoui/art/windows/gamepad/gp_nav1_hordividerflat.dds" )
	c:SetTextureCoordsRotation( -0.5 *  math.pi )
	c:SetTextureCoords( 0, 1, 0.4, 0.6 )
	c:SetColor( 1, 1, 1, 1 )
	c:SetMouseEnabled( false )

	grp = EHT.CreateControl( prefix .. "TriggerScrollContainer", ui.TriggerScroll, CT_CONTROL )
	ui.TriggerScrollContainer = grp
	grp:SetAnchor( TOPLEFT, ui.TriggerScroll, TOPLEFT, 0, 0 )
	grp:SetAnchor( TOPRIGHT, ui.TriggerScroll, TOPRIGHT, 0, 0 )
	grp:SetResizeToFitDescendents( true )

	c = EHT.CreateControl( prefix .. "TriggerSlider", ui.TriggerContainer, CT_SLIDER )
	ui.TriggerSlider = c
	local triggerSlider = c
	c:SetWidth( 15 )
	c:SetAnchor( TOPLEFT, ui.TriggerScroll, TOPRIGHT, 0, 15 )
	c:SetAnchor( BOTTOMLEFT, ui.TriggerScroll, BOTTOMRIGHT, 0, -15 )
	c:SetMinMax( 0, 1000 )
	c:SetValue( 1 )
	c:SetValueStep( 1 )
	c:SetMouseEnabled( true )
	c:SetAllowDraggingFromThumb( true )
	c:SetThumbTexture( "EsoUI/Art/ChatWindow/chat_thumb.dds", "EsoUI/Art/ChatWindow/chat_thumb_disabled.dds", nil, 8, 22, nil, nil, 0.6875, nil )
	c:SetBackgroundMiddleTexture( "EsoUI/Art/ChatWindow/chat_scrollbar_track.dds" )

	ui.TriggerSliderUp = EHT.UI.CreateTextureButton(
		prefix .. "TriggerSliderUp",
		ui.TriggerContainer,
		"esoui/art/miscellaneous/gamepad/gp_scrollarrow_up.dds",
		15, 15,
		{ { BOTTOM, ui.TriggerSlider, TOP, 0, 0 } },
		function() local value = ui.TriggerSlider:GetValue() ui.TriggerSlider:SetValue( value - 45 ) end )

	ui.TriggerSliderDown = EHT.UI.CreateTextureButton(
		prefix .. "TriggerSliderDown",
		ui.TriggerContainer,
		"esoui/art/miscellaneous/gamepad/gp_scrollarrow.dds",
		15, 15,
		{ { TOP, ui.TriggerSlider, BOTTOM, 0, 0 } },
		function() local value = ui.TriggerSlider:GetValue() if 0 == value then value = 20 end ui.TriggerSlider:SetValue( value + 45 ) end )

	ui.TriggerSlider:SetHandler( "OnValueChanged", function( self, value, eventReason )
		local scroll = ui.TriggerScroll
		local _, scrollHeight = scroll:GetScrollExtents()
		scroll:SetVerticalScroll( scrollHeight - ( scrollHeight - value ) )
	end )

	ui.TriggerScroll:SetHandler( "OnMouseWheel", function( self, delta, ctrl, alt, shift )
		local scroll = ui.TriggerScroll
		local _, scrollHeight = scroll:GetScrollExtents()
		local slider = ui.TriggerSlider
		local value = slider:GetValue()
		slider:SetValue( value - ( delta * 20 ) )
	end )

	c = EHT.CreateControl( nil, grp, CT_LABEL )
	ui.TriggerInfoLabel = c
	c:SetFont( "$(BOLD_FONT)|$(KB_17)|soft-shadow-thick" )
	c:SetColor( 1, 1, 1, 1 )
	c:SetMaxLineCount( 3 )
	c:SetAnchor( TOPLEFT, grp, TOPLEFT, 0, 0 )
	c:SetAnchor( TOPRIGHT, grp, TOPRIGHT, 0, 0 )
	c:SetText( "|cffff44While you are home|r Triggers can automate Lights, restore a saved Selection or play an animation Scene." )

	-- Trigger Details

	c = EHT.CreateControl( nil, grp, CT_LABEL )
	ui.TriggerNameLabel = c
	c:SetFont( "$(BOLD_FONT)|$(KB_18)|soft-shadow-thick" )
	SetColor(c, Colors.White)
	c:SetAnchor( TOPLEFT, ui.TriggerInfoLabel, BOTTOMLEFT, 0, 8 )
	c:SetAnchor( TOPRIGHT, ui.TriggerInfoLabel, BOTTOMRIGHT, 0, 8 )
	c:SetText( "Trigger description" )

	c = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "TriggerNameBackdrop", grp, "ZO_EditBackdrop" )
	ui.TriggerNameBackdrop = c
	c:SetAnchor( TOPLEFT, ui.TriggerNameLabel, BOTTOMLEFT, 0, 5 )
	c:SetAnchor( TOPRIGHT, ui.TriggerNameLabel, BOTTOMRIGHT, 0, 5 )
	c:SetHeight( 22 )

	c = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "TriggerName", ui.TriggerNameBackdrop, "ZO_DefaultEditForBackdrop" ) 
	ui.TriggerName = c
	c:SetFont( "$(BOLD_FONT)|$(KB_16)|soft-shadow-thick" )
	c:SetAnchor( TOPLEFT, ui.TriggerNameBackdrop, TOPLEFT, 1, 0 )
	c:SetAnchor( BOTTOMRIGHT, ui.TriggerNameBackdrop, BOTTOMRIGHT, -1, 0 )
	c:SetMaxInputChars( 60 )
	tip( c, "A brief description of this trigger." )

	c = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "TriggerRecursion", grp, "ZO_CheckButton" )
	ui.TriggerRecursion = c
	c:SetAnchor( TOPLEFT, ui.TriggerNameBackdrop, BOTTOMLEFT, 0, 5 )
	ZO_CheckButton_SetLabelText( ui.TriggerRecursion, "Allow reactivation while running" )
	ZO_CheckButton_SetCheckState( ui.TriggerRecursion, false )
	tip( c, "When enabled, this trigger can be reactivated while it is already running.\n\nFor example, toggling a Switch multiple times in a row could queue this Trigger to run multiple times in a row when this option is enabled." )


	local function addCondition( index, prefix, ui, parent, caption )

		prefix = prefix .. tostring( index )
		local c, grp, sgrp

		---- Trigger Condition

		c = EHT.CreateControl( nil, parent, CT_CONTROL )
		ui.TriggerConditionTypeLabel = c
		c:SetAnchor( TOPLEFT, parent, TOPLEFT, 0, 0 )
		c:SetAnchor( TOPRIGHT, parent, TOPRIGHT, 0, 0 )
		c:SetResizeToFitDescendents( true )

		c = EHT.CreateControl( nil, ui.TriggerConditionTypeLabel, CT_LABEL )
		c:SetFont( "$(BOLD_FONT)|$(KB_18)|soft-shadow-thick" )
		SetColor(c, Colors.White)
		c:SetAnchor( TOPLEFT, ui.TriggerConditionTypeLabel, TOPLEFT, 1 == index and 0 or 8, 0 )
		c:SetAnchor( TOPRIGHT, ui.TriggerConditionTypeLabel, TOPRIGHT, 0, 0 )
		c:SetText( caption )

		c = EHT.UI.Picklist:New( prefix .. "TriggerConditionList", parent )
		ui.TriggerConditionList = c
		c:SetAnchor( TOPLEFT, ui.TriggerConditionTypeLabel, BOTTOMLEFT, 20, 10 )
		c:SetAnchor( TOPRIGHT, ui.TriggerConditionTypeLabel, BOTTOMRIGHT, 0, 10 )
		c:SetHeight( 25 )
		if 1 < index then
			c:AddItem( EHT.CONST.TRIGGER_CONDITION.NONE, EHT.UI.TriggerChanged )
			c:AddItem( " ", EHT.UI.TriggerConditionInvalid )
		end
		c:AddItem( "Activated while you are home...", EHT.UI.TriggerConditionInvalid )
		c:AddItem( " ", EHT.UI.TriggerConditionInvalid )
		c:AddItem( "  " .. EHT.CONST.TRIGGER_CONDITION.DAY_TIME, EHT.UI.TriggerChanged )
		c:AddItem( "  " .. EHT.CONST.TRIGGER_CONDITION.NIGHT_TIME, EHT.UI.TriggerChanged )
		c:AddItem( " ", EHT.UI.TriggerConditionInvalid )
		c:AddItem( "Activated by anyone while you are home...", EHT.UI.TriggerConditionInvalid )
		c:AddItem( " ", EHT.UI.TriggerConditionInvalid )
		c:AddItem( "  " .. EHT.CONST.TRIGGER_CONDITION.FURNITURE_STATE, EHT.UI.TriggerChanged )
		if 1 == index then
		c:AddItem( "  " .. EHT.CONST.TRIGGER_CONDITION.GUEST_ARRIVES, EHT.UI.TriggerChanged )
		c:AddItem( "  " .. EHT.CONST.TRIGGER_CONDITION.GUEST_DEPARTS, EHT.UI.TriggerChanged )
		c:AddItem( "  " .. EHT.CONST.TRIGGER_CONDITION.PHRASE, EHT.UI.TriggerChanged )
		end
		c:AddItem( " ", EHT.UI.TriggerConditionInvalid )
		c:AddItem( "Activated by you and your group while you are home...", EHT.UI.TriggerConditionInvalid )
		c:AddItem( " ", EHT.UI.TriggerConditionInvalid )
		c:AddItem( "  " .. EHT.CONST.TRIGGER_CONDITION.ENTER_POSITION, EHT.UI.TriggerChanged )
		c:AddItem( "  " .. EHT.CONST.TRIGGER_CONDITION.LEAVE_POSITION, EHT.UI.TriggerChanged )
		c:AddItem( " ", EHT.UI.TriggerConditionInvalid )
		c:AddItem( "Activated only by you...", EHT.UI.TriggerConditionInvalid )
		c:AddItem( " ", EHT.UI.TriggerConditionInvalid )
		c:AddItem( "  " .. EHT.CONST.TRIGGER_CONDITION.ENTER_COMBAT, EHT.UI.TriggerChanged )
		c:AddItem( "  " .. EHT.CONST.TRIGGER_CONDITION.LEAVE_COMBAT, EHT.UI.TriggerChanged )
		if 1 == index then
		c:AddItem( "  " .. EHT.CONST.TRIGGER_CONDITION.EMOTE, EHT.UI.TriggerChanged )
		c:AddItem( "  " .. EHT.CONST.TRIGGER_CONDITION.QUICKSLOT, EHT.UI.TriggerChanged )
		c:AddItem( "  " .. EHT.CONST.TRIGGER_CONDITION.INTERACT_TARGET, EHT.UI.TriggerChanged )
		end
		c:SetSelectedItem( 1 == index and EHT.CONST.TRIGGER_CONDITION.FURNITURE_STATE or EHT.CONST.TRIGGER_CONDITION.NONE )
		c:SetEventBehavior( c.EventBehaviors.AlwaysRaise )

		grp = EHT.CreateControl( prefix .. "TriggerConditionContainer", parent, CT_CONTROL )
		ui.TriggerConditionContainer = grp
		grp:SetAnchor( TOPLEFT, ui.TriggerConditionList:GetControl(), BOTTOMLEFT, -20, 2 )
		grp:SetAnchor( TOPRIGHT, ui.TriggerConditionList:GetControl(), BOTTOMRIGHT, 0, 2 )
		grp:SetResizeToFitDescendents( true )

		-- Trigger Condition: Furniture State

		sgrp = EHT.CreateControl( prefix .. "TriggerConditionItemContainer", ui.TriggerConditionContainer, CT_CONTROL )
		ui.TriggerConditionItemContainer = sgrp
		sgrp:SetAnchor( TOPLEFT, ui.TriggerConditionContainer, TOPLEFT, 20, 0 )
		sgrp:SetAnchor( TOPRIGHT, ui.TriggerConditionContainer, TOPRIGHT, 0, 0 )
		sgrp:SetResizeToFitDescendents( true )

		c = EHT.UI.CreateButton(
			prefix .. "TriggerConditionItemSet",
			sgrp,
			"Select An Item ...",
			{ { TOPLEFT, sgrp, TOPLEFT, 0, 0 } },
			function() EHT.UI.SetTriggerConditionItem( index ) end )
		ui.TriggerConditionItemSet = c
		c:SetHorizontalAlignment( 0 )
		tip( c, "Select the switch or light that will trigger the action." )

		c = EHT.CreateControl( prefix .. "TriggerConditionItemIcon", sgrp, CT_LABEL )
		ui.TriggerConditionItemIcon = c
		c:SetFont( "$(BOLD_FONT)|$(KB_16)|soft-shadow-thick" )
		c:SetAnchor( TOPLEFT, sgrp, TOPLEFT, 0, 24 )
		c:SetText( "" )
		c:SetDimensions( 0, 0 )
		tip( c, "The switch or light that will trigger the action." )

		c = EHT.CreateControl( prefix .. "TriggerConditionItem", sgrp, CT_LABEL )
		ui.TriggerConditionItem = c
		c:SetFont( "$(BOLD_FONT)|$(KB_16)|soft-shadow-thick" )
		c:SetAnchor( TOPLEFT, ui.TriggerConditionItemIcon, TOPRIGHT, 0, 0 )
		c:SetAnchor( TOPRIGHT, sgrp, TOPRIGHT, 0, 24 )
		c:SetText( "" )
		c:SetDimensions( 0, 0 )
		c:SetWrapMode( TEXT_WRAP_MODE_ELLIPSIS )
		c:SetMouseEnabled( true )
		c:SetLinkEnabled( true )
		c:SetHandler( "OnLinkMouseUp", function( self, linkText, link, button ) ZO_LinkHandler_OnLinkMouseUp( link, button, self ) end )
		tip( c, "The switch or light that will trigger the action." )

		c = EHT.CreateControl( nil, sgrp, CT_LABEL )
		ui.TriggerConditionStateLabel = c
		c:SetFont( "$(BOLD_FONT)|$(KB_18)|soft-shadow-thick" )
		c:SetAnchor( TOPLEFT, ui.TriggerConditionItemIcon, BOTTOMLEFT, 0, 2 )
		c:SetText( "is" )

		c = EHT.UI.Picklist:New( prefix .. "TriggerConditionStateList", sgrp, LEFT, ui.TriggerConditionStateLabel, RIGHT, 10, 0, 85, 25 )
		ui.TriggerConditionStateList = c
		c:SetSorted( true )
		tip( c:GetControl(), "Select the item state that will trigger the action." )
		for _, state in pairs( EHT.STATE ) do
			if state ~= EHT.STATE.RESTORE and ( 1 == index or state ~= EHT.STATE.TOGGLE ) then
				c:AddItem( state, EHT.UI.TriggerChanged )
			end
		end
		c:SetSelectedItem( EHT.STATE.ON )

		-- Trigger Condition: Phrase

		sgrp = EHT.CreateControl( prefix .. "TriggerConditionPhraseContainer", ui.TriggerConditionContainer, CT_CONTROL )
		ui.TriggerConditionPhraseContainer = sgrp
		sgrp:SetAnchor( TOPLEFT, ui.TriggerConditionContainer, TOPLEFT, 20, 0 )
		sgrp:SetAnchor( TOPRIGHT, ui.TriggerConditionContainer, TOPRIGHT, 0, 0 )
		sgrp:SetResizeToFitDescendents( true )
		sgrp:SetHidden( true )

		c = EHT.CreateControl( nil, sgrp, CT_LABEL )
		ui.TriggerConditionPhraseLabel = c
		c:SetFont( "$(BOLD_FONT)|$(KB_18)|soft-shadow-thick" )
		c:SetAnchor( TOPLEFT, sgrp, TOPLEFT, 0, 0 )
		c:SetText( "Phrase:" )

		c = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "TriggerConditionPhraseBackdrop", sgrp, "ZO_EditBackdrop" )
		ui.TriggerConditionPhraseBackdrop = c
		c:SetAnchor( LEFT, ui.TriggerConditionPhraseLabel, RIGHT, 10, 0 )
		c:SetDimensions( 220, 22 )

		c = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "TriggerConditionPhrase", ui.TriggerConditionPhraseBackdrop, "ZO_DefaultEditForBackdrop" ) 
		ui.TriggerConditionPhrase = c
		c:SetFont( "$(BOLD_FONT)|$(KB_16)|soft-shadow-thick" )
		c:SetAnchor( TOPLEFT, ui.TriggerConditionPhraseBackdrop, TOPLEFT, 1, 0 )
		c:SetAnchor( BOTTOMRIGHT, ui.TriggerConditionPhraseBackdrop, BOTTOMRIGHT, -1, 0 )
		c:SetText( "Hello!" )
		c:SetMaxInputChars( 100 )
		tip( c, "The phrase that will activate this trigger.\n\n" ..
			"Note that this phrase will be matched regardless of case (\"case insensitive\")." )

		-- Trigger Condition: Position

		sgrp = EHT.CreateControl( prefix .. "TriggerConditionPositionContainer", ui.TriggerConditionContainer, CT_CONTROL )
		ui.TriggerConditionPositionContainer = sgrp
		sgrp:SetAnchor( TOPLEFT, ui.TriggerConditionContainer, TOPLEFT, 20, 0 )
		sgrp:SetAnchor( TOPRIGHT, ui.TriggerConditionContainer, TOPRIGHT, 0, 0 )
		sgrp:SetResizeToFitDescendents( true )
		sgrp:SetHidden( true )

		c = EHT.CreateControl( nil, sgrp, CT_LABEL )
		ui.TriggerConditionRadiusLabel = c
		c:SetFont( "$(BOLD_FONT)|$(KB_18)|soft-shadow-thick" )
		c:SetAnchor( TOPLEFT, sgrp, TOPLEFT, 0, 0 )
		c:SetText( "within" )

		c = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "TriggerConditionRadiusBackdrop", sgrp, "ZO_EditBackdrop" )
		ui.TriggerConditionRadiusBackdrop = c
		c:SetAnchor( LEFT, ui.TriggerConditionRadiusLabel, RIGHT, 10, 0 )
		c:SetDimensions( 42, 22 )

		c = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "TriggerConditionRadius", ui.TriggerConditionRadiusBackdrop, "ZO_DefaultEditForBackdrop" ) 
		ui.TriggerConditionRadius = c
		c:SetFont( "$(BOLD_FONT)|$(KB_16)|soft-shadow-thick" )
		c:SetAnchor( TOPLEFT, ui.TriggerConditionRadiusBackdrop, TOPLEFT, 1, 0 )
		c:SetAnchor( BOTTOMRIGHT, ui.TriggerConditionRadiusBackdrop, BOTTOMRIGHT, -1, 0 )
		c:SetText( "3.0" )
		c:SetMaxInputChars( 6 )
		tip( c, "The maximum trigger radius from the location point." )

		c = EHT.CreateControl( nil, sgrp, CT_LABEL )
		ui.TriggerConditionRadiusUnits = c
		c:SetFont( "$(BOLD_FONT)|$(KB_18)|soft-shadow-thick" )
		c:SetAnchor( LEFT, ui.TriggerConditionRadiusBackdrop, RIGHT, 10, 0 )
		c:SetText( "meters of" )

		c = EHT.CreateControl( prefix .. "TriggerConditionPosition", sgrp, CT_LABEL )
		ui.TriggerConditionPosition = c
		c:SetFont( "$(BOLD_FONT)|$(KB_16)|soft-shadow-thick" )
		c:SetAnchor( TOPLEFT, ui.TriggerConditionRadiusLabel, BOTTOMLEFT, 10, 5 )
		c:SetText( "" )
		tip( c, "The location that will trigger this action." )

		c = EHT.UI.CreateButton(
			prefix .. "TriggerConditionPositionSet",
			sgrp,
			"Use Current Location",
			{ { TOPLEFT, ui.TriggerConditionPosition, BOTTOMLEFT, 0, 2 } },
			function() EHT.Biz.ChooseTriggerPosition( index, true ) end )
		ui.TriggerConditionPositionSet = c
		c:SetHorizontalAlignment( 0 )
		tip( c, "Use your current location." )
--[[
		c = CreateContainer( nil, sgrp, CreateAnchor( TOPLEFT, ui.TriggerConditionPositionSet, BOTTOMLEFT, -10, 5 ) )
		ui.TriggerConditionSquareContainer = c

		c = EHT.UI.Checkbox:New( prefix .. "TriggerConditionSquare", ui.TriggerConditionSquareContainer, TOPLEFT, ui.TriggerConditionSquareContainer, TOPLEFT, 0, 0, 70 )
		ui.TriggerConditionSquare = c
		c:SetText( "Square" )
		tip( c:GetControl(), "Use a square hotspot instead of a round hotspot." )

		c = CreateTexture( nil, ui.TriggerConditionSquareContainer, CreateAnchor( LEFT, ui.TriggerConditionSquare:GetControl(), RIGHT, 20, 0 ), nil, 15, 15 )
		c:SetTexture( EHT.Textures.ICON_ARROW )
		c:SetTextureRotation( 0.5 * math.pi )
		ui.TriggerConditionYawLeft = c

		c = CreateLabel( nil, ui.TriggerConditionSquareContainer, "0 deg", CreateAnchor( LEFT, ui.TriggerConditionYawLeft, RIGHT, 5, 0 ), nil, 80 )
		c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		ui.TriggerConditionYaw = c

		c = CreateTexture( nil, ui.TriggerConditionSquareContainer, CreateAnchor( LEFT, ui.TriggerConditionYaw, RIGHT, 5, 0 ), nil, 15, 15 )
		c:SetTexture( EHT.Textures.ICON_ARROW )
		c:SetTextureRotation( -0.5 * math.pi )
		ui.TriggerConditionYawRight = c
]]
		c = EHT.CreateControl( prefix .. "TriggerConditionPositionValid", sgrp, CT_LABEL )
		ui.TriggerConditionPositionValid = c
		c:SetFont( "$(BOLD_FONT)|$(KB_18)|soft-shadow-thick" )
		c:SetAnchor( TOPLEFT, ui.TriggerConditionPositionSet, BOTTOMLEFT, -10, 5 )
		-- c:SetAnchor( TOPLEFT, ui.TriggerConditionSquareContainer, BOTTOMLEFT, 0, 5 )
		c:SetText( "|c33ff33Criteria is currently met.|r" )
		c:SetHidden( true )

		c = EHT.CreateControl( prefix .. "TriggerConditionPositionInvalid", sgrp, CT_LABEL )
		ui.TriggerConditionPositionInvalid = c
		c:SetFont( "$(BOLD_FONT)|$(KB_18)|soft-shadow-thick" )
		c:SetAnchor( TOPLEFT, ui.TriggerConditionPositionSet, BOTTOMLEFT, -10, 5 )
		-- c:SetAnchor( TOPLEFT, ui.TriggerConditionSquareContainer, BOTTOMLEFT, 0, 5 )
		c:SetText( "|cff3333Criteria is NOT currently met.|r" )
		c:SetHidden( true )

		-- Trigger Condition: Emote

		sgrp = EHT.CreateControl( prefix .. "TriggerConditionEmoteContainer", ui.TriggerConditionContainer, CT_CONTROL )
		ui.TriggerConditionEmoteContainer = sgrp
		sgrp:SetAnchor( TOPLEFT, ui.TriggerConditionContainer, TOPLEFT, 20, 0 )
		sgrp:SetAnchor( TOPRIGHT, ui.TriggerConditionContainer, TOPRIGHT, 0, 0 )
		sgrp:SetResizeToFitDescendents( true )

		c = EHT.UI.Picklist:New( prefix .. "TriggerConditionEmoteList", sgrp, TOPLEFT, sgrp, TOPLEFT, 0, 0 )
		ui.TriggerConditionEmoteList = c
		tip( c:GetControl(), "Select the emote that will trigger the action." )
		local emoteSlashNames = EHT.Util.GetEmoteSlashNames()
		for slashName, _ in pairs( emoteSlashNames ) do
			c:AddItem( slashName, EHT.UI.TriggerChanged )
		end
		c:SetHeight( 170 )
		c:SetSelectedItem( nil )
		c:SetSorted( true )

		-- Trigger Condition: Quickslot

		sgrp = EHT.CreateControl( prefix .. "TriggerConditionQuickslotContainer", ui.TriggerConditionContainer, CT_CONTROL )
		ui.TriggerConditionQuickslotContainer = sgrp
		sgrp:SetAnchor( TOPLEFT, ui.TriggerConditionContainer, TOPLEFT, 20, 0 )
		sgrp:SetAnchor( TOPRIGHT, ui.TriggerConditionContainer, TOPRIGHT, 0, 0 )
		sgrp:SetResizeToFitDescendents( true )

		c = EHT.CreateControl( prefix .. "TriggerConditionQuickslotLabel", sgrp, CT_LABEL )
		ui.TriggerConditionQuickslotLabel = c
		c:SetFont( "$(BOLD_FONT)|$(KB_18)|soft-shadow-thick" )
		c:SetAnchor( TOPLEFT, sgrp, TOPLEFT, 0, 0 )
		c:SetText( "Item:" )

		c = EHT.CreateControl( prefix .. "TriggerConditionQuickslotLink", sgrp, CT_LABEL )
		ui.TriggerConditionQuickslotLink = c
		c:SetFont( "$(BOLD_FONT)|$(KB_16)|soft-shadow-thick" )
		c:SetAnchor( LEFT, ui.TriggerConditionQuickslotLabel, RIGHT, 5, 0 )
		c:SetText( "No item selected" )
		c:SetMouseEnabled( true )
		c:SetLinkEnabled( true )
		c:SetHandler( "OnLinkMouseUp", function( self, linkText, link, button ) ZO_LinkHandler_OnLinkMouseUp( link, button, self ) end )

		c = EHT.CreateControl( prefix .. "TriggerConditionQuickslotInstructions", sgrp, CT_LABEL )
		ui.TriggerConditionQuickslotInstructions = c
		c:SetFont( "$(BOLD_FONT)|$(KB_18)|soft-shadow-thick" )
		c:SetAnchor( TOPLEFT, ui.TriggerConditionQuickslotLabel, BOTTOMLEFT, 0, 0 )
		c:SetText( "Use the Quickslot item you want to trigger with." )

		-- Trigger Condition: Interact

		sgrp = EHT.CreateControl( prefix .. "TriggerConditionInteractContainer", ui.TriggerConditionContainer, CT_CONTROL )
		ui.TriggerConditionInteractContainer = sgrp
		sgrp:SetAnchor( TOPLEFT, ui.TriggerConditionContainer, TOPLEFT, 20, 0 )
		sgrp:SetAnchor( TOPRIGHT, ui.TriggerConditionContainer, TOPRIGHT, 0, 0 )
		sgrp:SetResizeToFitDescendents( true )

		c = EHT.CreateControl( prefix .. "TriggerConditionInteractLabel", sgrp, CT_LABEL )
		ui.TriggerConditionInteractLabel = c
		c:SetFont( "$(BOLD_FONT)|$(KB_18)|soft-shadow-thick" )
		c:SetAnchor( TOPLEFT, sgrp, TOPLEFT, 0, 0 )
		c:SetText( "Interaction Target:" )

		c = EHT.CreateControl( prefix .. "TriggerConditionInteractTarget", sgrp, CT_LABEL )
		ui.TriggerConditionInteractTarget = c
		c:SetFont( "ZoFontWinH5" )
		c:SetAnchor( LEFT, ui.TriggerConditionInteractLabel, RIGHT, 5, 0 )
		c:SetText( "No target selected" )
		c:SetColor( 1, 1, 0.2, 1 )

		c = EHT.CreateControl( prefix .. "TriggerConditionInteractInstructions", sgrp, CT_LABEL )
		ui.TriggerConditionInteractInstructions = c
		c:SetFont( "ZoFontWinH5" )
		c:SetAnchor( TOPLEFT, ui.TriggerConditionInteractLabel, BOTTOMLEFT, 0, 0 )
		c:SetText( "Interact with the target you want to trigger with." )

	end

	
	ui.Conditions = { }


	grp = EHT.CreateControl( nil, ui.TriggerScrollContainer, CT_CONTROL )
	ui.TriggerCondition1 = grp
	grp:SetAnchor( TOPLEFT, ui.TriggerNameBackdrop, BOTTOMLEFT, 0, 30 )
	grp:SetAnchor( TOPRIGHT, ui.TriggerNameBackdrop, BOTTOMRIGHT, 0, 30 )
	grp:SetResizeToFitDescendents( true )

	ui.Conditions[1] = { }
	addCondition( 1, prefix, ui.Conditions[1], grp, "If ..." )


	grp = EHT.CreateControl( nil, ui.TriggerScrollContainer, CT_CONTROL )
	ui.TriggerCondition2 = grp
	grp:SetAnchor( TOPLEFT, ui.TriggerCondition1, BOTTOMLEFT, 0, 8 )
	grp:SetAnchor( TOPRIGHT, ui.TriggerCondition1, BOTTOMRIGHT, 0, 8 )
	grp:SetResizeToFitDescendents( true )

	ui.Conditions[2] = { }
	addCondition( 2, prefix, ui.Conditions[2], grp, "and ..." )


	---- Trigger Action

	grp = EHT.CreateControl( prefix .. "TriggerActionContainer", ui.TriggerScrollContainer, CT_CONTROL )
	ui.TriggerActionContainer = grp
	grp:SetAnchor( TOPLEFT, ui.TriggerCondition2, BOTTOMLEFT, 0, 8 )
	grp:SetAnchor( TOPRIGHT, ui.TriggerCondition2, BOTTOMRIGHT, 0, 8 )
	grp:SetResizeToFitDescendents( true )

	c = EHT.CreateControl( nil, grp, CT_LABEL )
	ui.TriggerActionLabel = c
	c:SetFont( "$(BOLD_FONT)|$(KB_18)|soft-shadow-thick" )
	SetColor(c, Colors.White)
	c:SetAnchor( TOPLEFT, grp, TOPLEFT, 0, 0 )
	c:SetAnchor( TOPRIGHT, grp, TOPRIGHT, 0, 0 )
	c:SetText( "Then ..." )
	
	-- Trigger Action: Group State

	sgrp = EHT.CreateControl( prefix .. "TriggerActionGroupContainer", ui.TriggerActionContainer, CT_CONTROL )
	ui.TriggerActionGroupContainer = sgrp
	sgrp:SetAnchor( TOPLEFT, ui.TriggerActionLabel, BOTTOMLEFT, 20, 4 )
	sgrp:SetAnchor( TOPRIGHT, ui.TriggerActionLabel, BOTTOMRIGHT, 0, 4 )
	sgrp:SetResizeToFitDescendents( true )

	c = EHT.CreateControl( nil, sgrp, CT_LABEL )
	ui.TriggerActionGroupLabel = c
	c:SetFont( "$(BOLD_FONT)|$(KB_18)|soft-shadow-thick" )
	c:SetAnchor( TOPLEFT, sgrp, TOPLEFT, 0, 0 )
	c:SetAnchor( TOPRIGHT, sgrp, TOPRIGHT, 0, 0 )
	c:SetText( "The items in the Saved Selection" )

	c = EHT.UI.Picklist:New( prefix .. "TriggerActionGroupList", sgrp )
	ui.TriggerActionGroupList = c
	c:SetAnchor( TOPLEFT, ui.TriggerActionGroupLabel, BOTTOMLEFT, 0, 2 )
	c:SetAnchor( TOPRIGHT, ui.TriggerActionGroupLabel, BOTTOMRIGHT, 0, 2 )
	c:SetHeight( 25 )
	tip( c:GetControl(), "Select a Saved Selection containing the items that will be changed." )

	c = EHT.CreateControl( nil, sgrp, CT_LABEL )
	ui.TriggerActionGroupStateLabel = c
	c:SetFont( "$(BOLD_FONT)|$(KB_18)|soft-shadow-thick" )
	c:SetAnchor( TOPLEFT, ui.TriggerActionGroupList:GetControl(), BOTTOMLEFT, 0, 2 )
	c:SetText( "will be" )

	c = EHT.UI.Picklist:New( prefix .. "TriggerActionGroupStateList", sgrp, TOPLEFT, ui.TriggerActionGroupStateLabel, TOPRIGHT, 10, 0, 130, 25 )
	ui.TriggerActionGroupStateList = c
	tip( c:GetControl(), "Select the state that the Saved Selection's items will be set to, or select 'Restored' to move the items back to their last saved positions." )
	c:SetSorted( true )
	for _, state in pairs( EHT.STATE ) do
		c:AddItem( state, EHT.UI.TriggerChanged )
	end
	c:SetSelectedItem( EHT.STATE.ON )

	-- Trigger Action: Scene

	sgrp = EHT.CreateControl( prefix .. "TriggerActionSceneContainer", ui.TriggerActionContainer, CT_CONTROL )
	ui.TriggerActionSceneContainer = sgrp
	sgrp:SetAnchor( TOPLEFT, ui.TriggerActionGroupContainer, BOTTOMLEFT, 0, 8 )
	sgrp:SetAnchor( TOPRIGHT, ui.TriggerActionGroupContainer, BOTTOMRIGHT, 0, 8 )
	sgrp:SetResizeToFitDescendents( true )

	c = EHT.CreateControl( nil, sgrp, CT_LABEL )
	ui.TriggerActionSceneLabel = c
	c:SetFont( "$(BOLD_FONT)|$(KB_18)|soft-shadow-thick" )
	c:SetAnchor( TOPLEFT, sgrp, TOPLEFT, 0, 0 )
	c:SetAnchor( TOPRIGHT, sgrp, TOPRIGHT, 0, 0 )
	c:SetText( "Play the Animation Scene" )

	c = EHT.UI.Picklist:New( prefix .. "TriggerActionSceneList", sgrp )
	ui.TriggerActionSceneList = c
	c:SetAnchor( TOPLEFT, ui.TriggerActionSceneLabel, BOTTOMLEFT, 0, 0 )
	c:SetAnchor( TOPRIGHT, ui.TriggerActionSceneLabel, BOTTOMRIGHT, 0, 0 )
	c:SetHeight( 25 )
	tip( c:GetControl(), "Select an Animation Scene to play." )

	-- Trigger Action: Trigger

	sgrp = EHT.CreateControl( prefix .. "TriggerActionTriggerContainer", ui.TriggerActionContainer, CT_CONTROL )
	ui.TriggerActionTriggerContainer = sgrp
	sgrp:SetAnchor( TOPLEFT, ui.TriggerActionSceneContainer, BOTTOMLEFT, 0, 8 )
	sgrp:SetAnchor( TOPRIGHT, ui.TriggerActionSceneContainer, BOTTOMRIGHT, 0, 8 )
	sgrp:SetResizeToFitDescendents( true )

	c = EHT.CreateControl( nil, sgrp, CT_LABEL )
	ui.TriggerActionTriggerLabel = c
	c:SetFont( "$(BOLD_FONT)|$(KB_18)|soft-shadow-thick" )
	c:SetAnchor( TOPLEFT, sgrp, TOPLEFT, 0, 0 )
	c:SetAnchor( TOPRIGHT, sgrp, TOPRIGHT, 0, 0 )
	c:SetText( "Activate the Trigger" )

	c = EHT.UI.Picklist:New( prefix .. "TriggerActionTriggerList", sgrp )
	ui.TriggerActionTriggerList = c
	c:SetAnchor( TOPLEFT, ui.TriggerActionTriggerLabel, BOTTOMLEFT, 0, 0 )
	c:SetAnchor( TOPRIGHT, ui.TriggerActionTriggerLabel, BOTTOMRIGHT, 0, 0 )
	c:SetHeight( 25 )
	tip( c:GetControl(), "Select the Trigger to activate." )

	c = EHT.CreateControl( nil, sgrp, CT_LABEL )
	c:SetAnchor( TOP, ui.TriggerActionTriggerList:GetControl(), BOTTOM, 0, 5 )
	c:SetDimensions( 20, 20 )
	c:SetText( "" )

	zo_callLater( function() EHT.UI.TriggerChanged() end, 50 )

end


function EHT.UI.SetupToolDialogToolTab( ui, parent, prefix, settings )

	local c, grp, pc
	local tip = EHT.UI.SetInfoTooltip


	grp = EHT.CreateControl( prefix .. "HouseInfoSection", parent, CT_CONTROL )
	ui.HouseInfoSection = grp
	grp:SetAnchor( TOPLEFT, parent, TOPLEFT, 0, 5 )
	grp:SetResizeToFitDescendents( true )

	c = EHT.CreateControl( prefix .. "HouseInfoHeading", grp, CT_LABEL )
	ui.HouseInfoHeading = c
	c:SetFont( "ZoFontWinH5" )
	c:SetColor( 1, 1, 0.75, 1 )
	c:SetAnchor( TOPLEFT, grp, TOPLEFT, 5, 0 )
	c:SetAnchor( TOPRIGHT, grp, TOPRIGHT, 0, 0 )
	c:SetText( "House Information" )

	pc = c
	c = EHT.CreateControl( nil, grp, CT_TEXTURE )
	c:SetHeight( 5 )
	c:SetAlpha( 0.5 )
	c:SetAnchor( TOPLEFT, pc, BOTTOMLEFT, -5, 0 )
	c:SetAnchor( TOPRIGHT, pc, BOTTOMRIGHT, 0, 0 )
	c:SetTexture( "EsoUI/Art/Miscellaneous/horizontalDivider.dds" )
	c:SetTextureCoords( 0.181640625, 0.818359375, 0, 1 )

	pc = c
	c = EHT.UI.CreateButton(
		prefix .. "PublishHouseInfo",
		grp,
		"Publish house name",
		{ { TOPLEFT, pc, BOTTOMLEFT, 5, 2 } },
		function()
			local result, message = EHT.Housing.PublishHouseInfo()
			if not result and message then EHT.UI.ShowAlertDialog( "Publish Failed", message ) end
		end )
	ui.PublishHouseInfo = c
	tip( c, "Publishes your nickname for this house to the other members of your guilds.\n\n" ..
		"Once published, your house nickname will be displayed to the other members of your guilds whenever they enter this house.\n\n" ..
		"|cffffaaGuild members must have " .. EHT.ADDON_TITLE .. " installed to see your house nickname.|r" )


	grp = EHT.CreateControl( prefix .. "ToggledItemsSection", parent, CT_CONTROL )
	ui.ToggledItemsSection = grp
	grp:SetAnchor( TOPLEFT, ui.HouseInfoSection, BOTTOMLEFT, 0, 20 )
	grp:SetResizeToFitDescendents( true )

	c = EHT.CreateControl( prefix .. "InteractiveItemsHeading", grp, CT_LABEL )
	ui.InteractiveItemsHeading = c
	c:SetFont( "ZoFontWinH5" )
	c:SetColor( 1, 1, 0.75, 1 )
	c:SetAnchor( TOPLEFT, grp, TOPLEFT, 5, 0 )
	c:SetAnchor( TOPRIGHT, grp, TOPRIGHT, 0, 0 )
	c:SetText( "Interactive Items" )

	pc = c
	c = EHT.CreateControl( nil, grp, CT_TEXTURE )
	c:SetHeight( 5 )
	c:SetAlpha( 0.5 )
	c:SetAnchor( TOPLEFT, pc, BOTTOMLEFT, -5, 0 )
	c:SetAnchor( TOPRIGHT, pc, BOTTOMRIGHT, 0, 0 )
	c:SetTexture( "EsoUI/Art/Miscellaneous/horizontalDivider.dds" )
	c:SetTextureCoords( 0.181640625, 0.818359375, 0, 1 )

	pc = c
	c = EHT.UI.CreateButton(
		prefix .. "TurnAllOn",
		grp,
		"Turn On all items",
		{ { TOPLEFT, pc, BOTTOMLEFT, 5, 2 } },
		function() EHT.Biz.SetFurnitureStates( EHT.STATE.ON ) end )
	ui.TurnAllOn = c
	tip( c, "Turns On all interactive items (lights, incense, etc.)" )

	pc = c
	c = EHT.UI.CreateButton(
		prefix .. "TurnAllOff",
		grp,
		"Turn Off all items",
		{ { TOPLEFT, pc, BOTTOMLEFT, 0, 2 } },
		function() EHT.Biz.SetFurnitureStates( EHT.STATE.OFF ) end )
	ui.TurnAllOff = c
	tip( c, "Turns Off all interactive items (lights, incense, etc.)" )

	pc = c
	c = EHT.UI.CreateButton(
		prefix .. "ToggleAll",
		grp,
		"Toggle all items",
		{ { TOPLEFT, pc, BOTTOMLEFT, 0, 2 } },
		function() EHT.Biz.SetFurnitureStates( EHT.STATE.TOGGLE ) end )
	ui.ToggleAll = c
	tip( c, "Toggles the state of all interactive items (lights, incense, etc.)" )


	grp = EHT.CreateControl( prefix .. "ReportsSection", parent, CT_CONTROL )
	ui.ReportsSection = grp
	grp:SetAnchor( TOPLEFT, parent, TOP, 0, 5 )
	grp:SetResizeToFitDescendents( true )

	c = EHT.CreateControl( prefix .. "ReportsHeading", grp, CT_LABEL )
	ui.ReportsHeading = c
	c:SetFont( "ZoFontWinH5" )
	c:SetColor( 1, 1, 0.75, 1 )
	c:SetAnchor( TOPLEFT, grp, TOPLEFT, 5, 0 )
	c:SetAnchor( TOPRIGHT, grp, TOPRIGHT, 0, 0 )
	c:SetText( "Reports" )

	pc = c
	c = EHT.CreateControl( nil, grp, CT_TEXTURE )
	c:SetHeight( 5 )
	c:SetAlpha( 0.5 )
	c:SetAnchor( TOPLEFT, pc, BOTTOMLEFT, -5, 0 )
	c:SetAnchor( TOPRIGHT, pc, BOTTOMRIGHT, 0, 0 )
	c:SetTexture( "EsoUI/Art/Miscellaneous/horizontalDivider.dds" )
	c:SetTextureCoords( 0.181640625, 0.818359375, 0, 1 )

	pc = c
	c = EHT.UI.CreateButton(
		prefix .. "ReportHouseItems",
		grp,
		"Items by House",
		{ { TOPLEFT, pc, BOTTOMLEFT, 5, 2 } },
		function() EHT.UI.ShowReport( "Items by House", EHT.Biz.ReportHouseItems ) end )
	ui.ReportHouseItems = c
	tip( c, "Produces an exportable report of all placed items, for a specific House, grouped by:\n" ..
		" - Automatic Backups\n" ..
		" - Recent Undo History\n" ..
		" - Saved Selections" )


end


function EHT.UI.SetupToolDialogHistoryTab( ui, parent, prefix, settings )

	ui.HistoryListing = EHT.CreateControl( prefix .. "HistoryListing", parent, CT_CONTROL )
	ui.HistoryListing:SetAnchor( TOPLEFT, parent, TOPLEFT, 0, 0 )
	ui.HistoryListing:SetAnchor( BOTTOMRIGHT, parent, BOTTOMRIGHT, 0, -30 )

	-- History List

	ui.HistoryBuffer = EHT.CreateControl( prefix .. "HistoryBuffer", ui.HistoryListing, CT_TEXTBUFFER )
	ui.HistoryBuffer:SetFont( "ZoFontChat" )
	ui.HistoryBuffer:SetMaxHistoryLines( EHT.CONST.MAX_HOUSE_HISTORY )
	ui.HistoryBuffer:SetMouseEnabled( true )
	ui.HistoryBuffer:SetLinkEnabled( true )
	ui.HistoryBuffer:SetAnchor( TOPLEFT, ui.HistoryListing, TOPLEFT, 0, 0 )
	ui.HistoryBuffer:SetAnchor( BOTTOMRIGHT, ui.HistoryListing, BOTTOMRIGHT, -16, 0 )
	ui.HistoryBuffer:SetHandler( "OnLinkMouseUp", function( self, linkText, link, button ) ZO_LinkHandler_OnLinkMouseUp( link, button, self ) end )
	ui.HistoryBuffer:SetHandler( "OnMouseWheel", function( self, delta, ctrl, alt, shift )
		local offset = delta
		local slider = EHT.UI.ToolDialog.HistorySlider
		if shift then
			offset = offset * self:GetNumVisibleLines()
		elseif ctrl then
			offset = offset * self:GetNumHistoryLines()
		end
		self:SetScrollPosition( self:GetScrollPosition() + offset )
		slider:SetValue( slider:GetValue() - offset )
	end )

	ui.HistorySlider = EHT.CreateControl( prefix .. "HistorySlider", ui.HistoryListing, CT_SLIDER )
	ui.HistorySlider:SetWidth( 15 )
	ui.HistorySlider:SetAnchor( TOPLEFT, ui.HistoryBuffer, TOPRIGHT, 1, 0 )
	ui.HistorySlider:SetAnchor( BOTTOMLEFT, ui.HistoryBuffer, BOTTOMRIGHT, 1, 0 )
	ui.HistorySlider:SetMinMax( 1, 1 )
	ui.HistorySlider:SetMouseEnabled( true )
	ui.HistorySlider:SetValueStep( 1 )
	ui.HistorySlider:SetValue( 1 )
	ui.HistorySlider:SetHidden( true )
	ui.HistorySlider:SetThumbTexture( "EsoUI/Art/ChatWindow/chat_thumb.dds", "EsoUI/Art/ChatWindow/chat_thumb_disabled.dds", nil, 8, 22, nil, nil, 0.6875, nil )
	ui.HistorySlider:SetBackgroundMiddleTexture( "EsoUI/Art/ChatWindow/chat_scrollbar_track.dds" )
	ui.HistorySlider:SetHandler( "OnValueChanged", function( self, value, eventReason )
		if eventReason == EVENT_REASON_HARDWARE then
			local buffer = EHT.UI.ToolDialog.HistoryBuffer
			buffer:SetScrollPosition( buffer:GetNumHistoryLines() - self:GetValue() )
		end
	end )

	ui.HistoryActions = EHT.CreateControl( prefix .. "HistoryActions", parent, CT_CONTROL )
	ui.HistoryActions:SetAnchor( TOPLEFT, ui.HistoryListing, BOTTOMLEFT, 0, -2 )
	ui.HistoryActions:SetAnchor( BOTTOMRIGHT, parent, BOTTOMRIGHT, 0, -2 )

	local divider = EHT.CreateControl( nil, ui.HistoryActions, CT_TEXTURE )
	divider:SetHeight( 5 )
	divider:SetAlpha( 0.5 )
	divider:SetAnchor( TOPLEFT, ui.HistoryActions, TOPLEFT, 0, 6 )
	divider:SetAnchor( TOPRIGHT, ui.HistoryActions, TOPRIGHT, 0, 6 )
	divider:SetTexture( "EsoUI/Art/Miscellaneous/horizontalDivider.dds" )
	divider:SetTextureCoords( 0.181640625, 0.818359375, 0, 1 )

	ui.UndoButton = EHT.UI.CreateButton(
		prefix .. "UndoButton",
		ui.HistoryActions,
		"Undo",
		{ { BOTTOMLEFT, ui.HistoryActions, BOTTOMLEFT, 0, 0 } },
		function() EHT.CT.Undo() end )

	ui.RedoButton = EHT.UI.CreateButton(
		prefix .. "RedoButton",
		ui.HistoryActions,
		"Redo",
		{ { LEFT, ui.UndoButton, RIGHT, 10, 0 } },
		function() EHT.CT.Redo() end )

	ui.ClearHistoryButton = EHT.UI.CreateButton(
		prefix .. "ClearHistoryButton",
		ui.HistoryActions,
		"Clear",
		{ { LEFT, ui.RedoButton, RIGHT, 10, 0 } },
		function() EHT.UI.ShowConfirmationDialog( "Clear History", "You will not be able to Undo/Redo any of the recorded changes after clearing this history. Continue?", function() EHT.CT.ClearUndoHistory() end ) end )

	ui.ShowBackupsButton = EHT.UI.CreateButton(
		prefix .. "ShowBackupsButton",
		ui.HistoryActions,
		"Automatic Backups",
		{ { BOTTOMRIGHT, ui.HistoryActions, BOTTOMRIGHT, 0, 0 } },
		function() EHT.UI.ShowBackupsDialog() end )

end


function EHT.UI.UpdatePersistentNotifications()
	local ui = EHT.UI.ToolDialog
	if nil == ui then return end

	local msgs = EHT.PersistentNotifications
	if nil == msgs then msgs = { } EHT.PersistentNotifications = msgs end

	local msgString = ""
	local mKeys = { }

	for key, _ in pairs( msgs ) do table.insert( mKeys, key ) end
	table.sort( mKeys )

	for _, key in ipairs( mKeys ) do
		msgString = msgString .. msgs[ key ] .. "\n"
	end
	if "" ~= msgString then msgString = string.sub( msgString, 1, -2 ) end

	if not ui.PersistentNotificationLabel or not ui.PersistentNotificationPanel then
		return
	end

	ui.PersistentNotificationLabel:SetText( msgString )
	ui.PersistentNotificationPanel:SetHidden( "" == msgString )

	if not ui.PersistentNotificationPanel:IsHidden() then
		ui.PersistentNotificationPanel:SetResizeToFitDescendents( false )
		ui.PersistentNotificationPanel:SetHeight( 1 )
		ui.PersistentNotificationPanel:SetResizeToFitDescendents( true )
	end
end


function EHT.UI.SetPersistentNotification( msgKey, msg, duration )

	local msgs = EHT.PersistentNotifications
	if nil == msgs then msgs = { } EHT.PersistentNotifications = msgs end

	local msgCallbacks = EHT.PersistentNotificationCallbacks
	if nil == msgCallbacks then msgCallbacks = { } EHT.PersistentNotificationCallbacks = msgCallbacks end

	msgs[ msgKey ] = msg
	EHT.UI.UpdatePersistentNotifications()

	if nil ~= duration and 0 < duration then
		if 500 > duration then duration = duration * 1000 end
		msgCallbacks[ msgKey ] = zo_callLater( function( id ) EHT.UI.ClearPersistentNotificationCallback( id, msgKey ) end, duration )
	else
		msgCallbacks[ msgKey ] = nil
	end

end


function EHT.UI.ClearPersistentNotification( msgKey )

	local msgs = EHT.PersistentNotifications
	if nil == msgs then msgs = { } EHT.PersistentNotifications = msgs end
	msgs[ msgKey ] = nil

	EHT.UI.UpdatePersistentNotifications()
end

function EHT.UI.ClearPersistentNotificationCallback( callbackId, msgKey )
	local msgCallbacks = EHT.PersistentNotificationCallbacks
	if nil == msgCallbacks then msgCallbacks = { } EHT.PersistentNotificationCallbacks = msgCallbacks end

	if callbackId == msgCallbacks[ msgKey ] then
		msgCallbacks[ msgKey ] = nil
		EHT.UI.ClearPersistentNotification( msgKey )
	end
end

function EHT.UI.SetToolDialogWindowTitleCallback()
	if not EHT.Housing.IsHouseZone() then
		EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.SetToolDialogWindowTitle" )
		return
	end

	local td = EHT.UI.ToolDialog
	local eb = EHT.UI.EHTButtonDialog

	if not ( td or eb ) then
		return
	end

	local title, stats, labelLimit, labelLimitMax, labelPop, labelPopMax, labelFX = EHT.ADDON_TITLE, "", "", "", "", "", ""
	local houseId, owner, isOwner, houseName, houseNickname, customHouseName = EHT.Housing.GetHouseInfo()
	local pop, maxPop = GetCurrentHousePopulation(), GetCurrentHousePopulationCap()
	local _, maxItems, items = EHT.Housing.GetLimit( HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_ITEM )
	local maxFX = EHT.Effect:GetLimit()

	if nil ~= houseId and 0 < houseId then
		if isOwner then
			if nil ~= houseNickname and "" ~= houseNickname then
				title = houseNickname
			else
				title = houseName
			end
		else
			if nil ~= customHouseName and "" ~= customHouseName then
				title = customHouseName
			else
				title = houseName
			end
		end

		local numFX = EHT.Effect:GetNumPlacedEffects()

		labelFX = string.format( "%s%d|r", maxFX <= numFX and "|cffc773" or "", numFX )

		labelLimit = string.format(
			"%s%d%s",
			maxItems <= items and "|cffc773" or "",
			items or 0,
			maxItems <= items and "|r" or "" )

		labelLimitMax = string.format( "%s / %d", labelLimit, maxItems )

		labelPop = string.format(
			"%s%d%s",
			maxPop <= pop and "|cffc773" or "",
			pop or 0,
			maxPop <= pop and "|r" or ""
			-- ffdd44
		)

		labelPopMax = string.format( "%s / %d", labelPop, maxPop )

		stats = string.format(
			"EHT %s %s%s %s%s",
			EHT.ADDON_VERSION,
			zo_iconFormat( "esoui/art/crafting/provisioner_indexIcon_furnishings_down.dds", 30, 30 ),
			labelLimitMax,
			zo_iconFormat( "esoui/art/mainmenu/menubar_character_down.dds", 30, 30 ),
			labelPopMax
		)

		if nil == title then title = "" end
		title = string.sub( title, 1, 20 )

		if eb then
			eb.LimitLabel:SetText( labelLimit )
			eb.LimitMaxLabel:SetText( string.format( "/ %d", maxItems ) )
			eb.FXLabel:SetText( labelFX )
			eb.FXMaxLabel:SetText( string.format( "/ %d", maxFX ) )
			eb.PopulationLabel:SetText( labelPop )
			eb.PopulationMaxLabel:SetText( string.format( "/ %d", maxPop ) )
		end
	end
end

function EHT.UI.SetToolDialogWindowTitle()
	EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.SetToolDialogWindowTitle" )
	EVENT_MANAGER:RegisterForUpdate( "EHT.UI.SetToolDialogWindowTitle", 3000, EHT.UI.SetToolDialogWindowTitleCallback )
end

function EHT.UI.UpdateEditButtonVisibility()
	local ui = EHT.UI.ToolDialog
	if not ui or not ui.EditButtons then return end

	local inherit = not EHT.GetSetting("RetainEditButtonVisibility")
	for _, b in ipairs(ui.EditButtons) do
		b:SetInheritAlpha(inherit)
		b.Label:SetInheritAlpha(inherit)
		ui.ToggleDirectionalMode:SetInheritAlpha(inherit)

		if inherit then
			b:SetAlpha(1)
			b.Label:SetAlpha(1)
			ui.ToggleDirectionalMode:SetAlpha(1)
		end
	end
end

function EHT.UI.SetupToolDialog()
	local ui = EHT.UI.ToolDialog

	if nil == ui then
		ui = { }
		EHT.UI.ToolDialog = ui

		local prefix = "EHTToolDialog"
		local settingsName = "ToolDialog"
		local c, divider, grp

		-- Window Controls

		ui.Window = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
		ui.Window:SetHidden( true )
		ui.Window:SetMovable( true )
		ui.Window:SetMouseEnabled( true )
		ui.Window:SetClampedToScreen( true )
		ui.Window:SetAlpha( 1 )
		ui.Window:SetResizeHandleSize( 10 )
		ui.Window:SetClampedToScreenInsets( 0, 0, 0, 20 )
		ui.Window:SetDimensionConstraints( EHT.CONST.UI.TOOL_DIALOG.MIN_WIDTH, EHT.CONST.UI.TOOL_DIALOG.MIN_HEIGHT, EHT.CONST.UI.TOOL_DIALOG.MAX_WIDTH, EHT.CONST.UI.TOOL_DIALOG.MAX_HEIGHT )
		ui.Window:SetDrawLevel( EHT.Effects.MAX_EDITOR_DRAW_LEVEL + 1 )

		local settings = EHT.UI.GetDialogSettings( settingsName )
		if settings.Left and settings.Top then
			ui.Window:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, settings.Left, settings.Top )
		else
			ui.Window:SetAnchor( BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, -20, -58 )
		end

		if settings.Width and settings.Height then
			ui.Window:SetDimensions( settings.Width, settings.Height )
		else
			ui.Window:SetDimensions( EHT.CONST.UI.TOOL_DIALOG.MIN_WIDTH, EHT.CONST.UI.TOOL_DIALOG.MIN_HEIGHT )
		end

		ui.Window:SetHandler( "OnMoveStop", function()
			EHT.UI.SaveDialogSettings( settingsName, ui.Window )
		end )
		ui.Window:SetHandler( "OnResizeStop", function()
			ui.Buffer:RefreshList()
			EHT.UI.SaveDialogSettings( settingsName, ui.Window )
			zo_callLater( EHT.UI.UpdateBuildScrollExtents, 10 )
			zo_callLater( EHT.UI.UpdateTriggerScrollExtents, 10 )
		end )

		ui.Backdrop = CreateTexture("$(parent)Backdrop", ui.Window, CreateAnchor(TOPLEFT), CreateAnchor(BOTTOMRIGHT), nil, nil, EHT.UI_TEXTURES.GLASS_FROSTED, Colors.ToolDialogBackdrop)

		do
			local maxAlpha, transInterval = 0.95, 300
			local background = { ui.Window, ui.Backdrop, }
			local alphaEnter, alphaExit
			local alphaStart = 0

			function EHT.UI.ToolDialogAlpha()
				if ui.Window:IsHidden() then
					alphaEnter, alphaExit = nil, nil
					EVENT_MANAGER:UnregisterForUpdate("EHT.UI.ToolDialogAlpha")
					return
				end

				local minAlpha = tonumber(EHT.GetSetting("MinimumWindowOpacity")) or 65
				minAlpha = minAlpha / 100
				local ft = GetFrameTimeMilliseconds()
				local currentAlpha = background[1]:GetAlpha()
				local alpha

				if EHT.UI.IsMouseOverControl(ui.Window, EHT.UI.Picklist.PicklistDialog.Window) and not EHT.UI.IsMouseOverAnyControl(ui.EditButtons) then
					if currentAlpha ~= minAlpha then
						if not alphaEnter then
							alphaStart, alphaEnter = currentAlpha, ft
						end

						local interval = ( ft - alphaEnter ) / transInterval
						alpha = math.min( maxAlpha, zo_lerp( alphaStart, maxAlpha, interval ) )
						alphaExit = nil
					end
				else
					if currentAlpha ~= maxAlpha then
						if not alphaExit then
							alphaStart, alphaExit = currentAlpha, ft
						end

						local interval = ( ft - alphaExit ) / transInterval
						alpha = math.max( minAlpha, zo_lerp( alphaStart, minAlpha, interval ) )
						alphaEnter = nil
					end
				end

				if alpha then
					local backgroundAlpha = alpha -- -0.3 + alpha

					for index, control in ipairs( background ) do
						if 1 == index then
							control:SetAlpha( alpha )
						else
							control:SetAlpha( backgroundAlpha )
						end
					end

					if not EHT.GetSetting("RetainEditButtonVisibility") then
						local buttonAlpha = math.max( 0.65, alpha )

						for _, b in ipairs(ui.EditButtons) do
							b:SetAlpha(buttonAlpha)
							b.Label:SetAlpha(buttonAlpha)
						end
						
						ui.ToggleDirectionalMode:SetAlpha(buttonAlpha)
					end
				end
			end

			ui.Window:SetHandler( "OnEffectivelyShown", function()
				alphaEnter, alphaExit = nil, nil
				EVENT_MANAGER:RegisterForUpdate( "EHT.UI.ToolDialogAlpha", 1, EHT.UI.ToolDialogAlpha )
			end )

			ui.Window:SetHandler( "OnEffectivelyHidden", function()
				alphaEnter, alphaExit = nil, nil
				EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.ToolDialogAlpha" )
			end )
		end

		-- Persistent Notifications

		grp = EHT.CreateControl( prefix .. "PersistentNotificationPanel", ui.Window, CT_CONTROL )
		ui.PersistentNotificationPanel = grp
		grp:SetAnchor( TOPLEFT, ui.Window, BOTTOMLEFT, 0, 20 )
		grp:SetAnchor( TOPRIGHT, ui.Window, BOTTOMRIGHT, 0, 20 )
		grp:SetResizeToFitDescendents( true )
		grp:SetHidden( true )

		c = EHT.CreateControl( prefix .. "PersistentNotificationBackdrop", grp, CT_TEXTURE )
		ui.PersistentNotificationBackdrop = c
		c:SetAnchor( TOPLEFT, grp, TOPLEFT, 0, 0 )
		c:SetAnchor( BOTTOMRIGHT, grp, BOTTOMRIGHT, 0, 0 )
		c:SetTexture( "esoui/art/buttons/gamepad/inline_controllerbkg_darkgrey-center.dds" )
		c:SetColor( 1, 1, 1, 1 )
		c:SetBlendMode( TEX_BLEND_MODE_ALPHA )

		c = EHT.CreateControl( prefix .. "PersistentNotificationLabel", grp, CT_LABEL )
		ui.PersistentNotificationLabel = c
		c:SetFont( "$(BOLD_FONT)|$(KB_18)|soft-shadow-thick" )
		c:SetColor( 1, 0, 0, 1 )
		c:SetAnchor( CENTER, grp, CENTER, 0, 0 )
		c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		c:SetMaxLineCount( 8 )

		-- Edit Container

		ui.EditSection = EHT.CreateControl( prefix .. "EditSection", ui.Window, CT_CONTROL )
		ui.EditSection:SetAnchor( BOTTOMLEFT, ui.Window, BOTTOMLEFT, 15, -15 )
		ui.EditSection:SetAnchor( BOTTOMRIGHT, ui.Window, BOTTOMRIGHT, -18, -15 )
		ui.EditSection:SetResizeToFitDescendents( true )
		ui.EditSection:SetMouseEnabled(false)

		EHT.UI.SetupToolDialogEditTab( ui, ui.EditSection, prefix, settings )
		EHT.UI.UpdateEditButtonVisibility()

		-- Tab Control Container

		ui.TabControl = EHT.CreateControl( prefix .. "TabControl", ui.Window, CT_CONTROL )
		ui.TabControl:SetAnchor( TOPLEFT, ui.Window, TOPLEFT, 18, 35 )
		ui.TabControl:SetAnchor( BOTTOMRIGHT, ui.EditSection, TOPRIGHT, 0, -16 )
		ui.TabControl:SetMouseEnabled(false)

		divider = CreateDivider( prefix .. "TabBottomDivider", ui.Window, CreateAnchor( TOPLEFT, ui.TabControl, BOTTOMLEFT, 0, 6 ), CreateAnchor( TOPRIGHT, ui.TabControl, BOTTOMRIGHT, 0, 6 ) )
		ui.TabBottomDivider = divider
		divider:SetHeight( 8 )

		ui.Tabs = EHT.CreateControl( prefix .. "Tabs", ui.TabControl, CT_CONTROL )
		ui.Tabs:SetAnchor( BOTTOMLEFT, ui.TabControl, TOPLEFT, 0, 37 )
		ui.Tabs:SetHeight( 37 )
		ui.Tabs:SetResizeToFitDescendents( true )

		divider = CreateDivider( prefix .. "TabTopDivider", ui.TabControl, CreateAnchor( BOTTOMLEFT, ui.TabControl, TOPLEFT, 0, 42 ), CreateAnchor( BOTTOMRIGHT, ui.TabControl, TOPRIGHT, 0, 42 ) )
		ui.TabTopDivider = divider
		divider:SetHeight( 8 )

		ui.HistoryTabButton = EHT.UI.CreateTabButton(
			prefix .. "HistoryTabButton",
			ui.Tabs,
			EHT.CONST.TOOL_TABS.HISTORY,
			nil, 25,
			{ { BOTTOMRIGHT, ui.Tabs, BOTTOMRIGHT, 0, 2 } },
			function() EHT.UI.ShowToolTab( EHT.CONST.TOOL_TABS.HISTORY ) end )

		EHT.UI.SetInfoTooltip( ui.HistoryTabButton, "Restore a backup of your entire home or undo recently made changes." )

		ui.ToolTabButton = EHT.UI.CreateTabButton(
			prefix .. "ToolTabButton",
			ui.Tabs,
			EHT.CONST.TOOL_TABS.TOOLS,
			nil, 25,
			{ { BOTTOMRIGHT, ui.HistoryTabButton, BOTTOMLEFT, -4, 0 } },
			function() EHT.UI.ShowToolTab( EHT.CONST.TOOL_TABS.TOOLS ) end )

		EHT.UI.SetInfoTooltip( ui.ToolTabButton, "One-click Toggle all lights, publish a home's name and more." )

		ui.TriggerTabButton = EHT.UI.CreateTabButton(
			prefix .. "TriggerTabButton",
			ui.Tabs,
			EHT.CONST.TOOL_TABS.TRIGGERS,
			nil, 25,
			{ { BOTTOMRIGHT, ui.ToolTabButton, BOTTOMLEFT, -4, 0 } },
			function() EHT.UI.ShowToolTab( EHT.CONST.TOOL_TABS.TRIGGERS ) end )

		EHT.UI.SetInfoTooltip( ui.TriggerTabButton, "Automatically set lights and play animation scenes when toggling a switch, entering an area, saying a phrase and more." )

		ui.AnimateTabButton = EHT.UI.CreateTabButton(
			prefix .. "AnimateTabButton",
			ui.Tabs,
			EHT.CONST.TOOL_TABS.ANIMATE,
			nil, 25,
			{ { BOTTOMRIGHT, ui.TriggerTabButton, BOTTOMLEFT, -4, 0 } },
			function() EHT.UI.ShowToolTab( EHT.CONST.TOOL_TABS.ANIMATE ) end )

		EHT.UI.SetInfoTooltip( ui.AnimateTabButton, "Create and play back animation scenes using the items that you have selected." )

		ui.BuildTabButton = EHT.UI.CreateTabButton(
			prefix .. "BuildTabButton",
			ui.Tabs,
			EHT.CONST.TOOL_TABS.BUILD,
			nil, 25,
			{ { BOTTOMRIGHT, ui.AnimateTabButton, BOTTOMLEFT, -4, 0 } },
			function() EHT.UI.ShowToolTab( EHT.CONST.TOOL_TABS.BUILD ) end )

		EHT.UI.SetInfoTooltip( ui.BuildTabButton, "Use your currently selected items to build geometric shapes or layout crafting stations." )

		ui.SelectionTabButton = EHT.UI.CreateTabButton(
			prefix .. "SelectionTabButton",
			ui.Tabs,
			EHT.CONST.TOOL_TABS.SELECT,
			nil, 25,
			{ { BOTTOMRIGHT, ui.BuildTabButton, BOTTOMLEFT, -4, 0 } },
			function() EHT.UI.ShowToolTab( EHT.CONST.TOOL_TABS.SELECT ) end )

		EHT.UI.SetInfoTooltip( ui.SelectionTabButton, "All things start here by selecting one or more items to move, build with, animate or trigger from." )

		-- Tab Containers

		ui.NotificationPanel = EHT.CreateControl( prefix .. "NotificationPanel", ui.TabControl, CT_CONTROL )
		ui.NotificationPanel:SetAnchor( TOPLEFT, divider, BOTTOMLEFT, 0, 0 )
		ui.NotificationPanel:SetAnchor( TOPRIGHT, divider, BOTTOMRIGHT, 0, 0 )
		ui.NotificationPanel:SetHeight( 0 )
		ui.NotificationPanel:SetHidden( true )

		ui.NotificationLabel = EHT.CreateControl( prefix .. "NotificationLabel", ui.NotificationPanel, CT_LABEL )
		ui.NotificationLabel:SetFont( "ZoFontWinH5" )
		ui.NotificationLabel:SetColor( 1, 0.2, 0.2, 1 )
		ui.NotificationLabel:SetAnchor( TOP, ui.NotificationPanel, TOP, -45, 0 )
		ui.NotificationLabel:SetText( "Warning" )

		ui.NotificationAction = EHT.UI.CreateButton(
			prefix .. "NotificationAction",
			ui.NotificationPanel,
			"Fix Now",
			{ { LEFT, ui.NotificationLabel, RIGHT, 10, 0 } },
			function()
				EHT.UI.ShowConfirmationDialog(
					"Warning",
					"Find replacements for missing item(s) and automatically revert ALL items to their last saved positions?",
					function()
						local groupName = ui.SelectionList:GetSelectedItem()
						local group
						if nil ~= groupName and "" ~= groupName then
							group = EHT.Biz.LoadGroup( groupName, true )
						end

						EHT.UI.ShowCustomDialog(
							"Search for missing items in this |c99ffffHouse|r (the nearest matching items will be used first) or in your |c99ffffInventory, Bank and Storage Coffers|r?",
							"House",
							function()
								EHT.Biz.ReplaceMissingItems( group, nil, false, true )
							end,
							"Inventory",
							function()
								EHT.Biz.ReplaceMissingItems( group, nil, true, false )
							end )
					end )

			end )

		ui.TabContainer = EHT.CreateControl( prefix .. "TabContainer", ui.TabControl, CT_CONTROL )
		ui.TabContainer:SetAnchor( TOPLEFT, ui.NotificationPanel, BOTTOMLEFT, 0, 0 )
		ui.TabContainer:SetAnchor( BOTTOMRIGHT, ui.TabControl, BOTTOMRIGHT, 0, 0 )

		ui.SelectionTab = EHT.CreateControl( prefix .. "SelectionTab", ui.TabContainer, CT_BUTTON )
		ui.SelectionTab:SetAnchor( TOPLEFT, ui.TabContainer, TOPLEFT, 0, 0 )
		ui.SelectionTab:SetAnchor( BOTTOMRIGHT, ui.TabContainer, BOTTOMRIGHT, 0, 0 )
		ui.SelectionTab:SetResizeToFitDescendents( true )
		ui.SelectionTab:SetHidden( false )

		ui.AnimateTab = EHT.CreateControl( prefix .. "AnimateTab", ui.TabContainer, CT_BUTTON )
		ui.AnimateTab:SetAnchor( TOPLEFT, ui.TabContainer, TOPLEFT, 0, 0 )
		ui.AnimateTab:SetAnchor( BOTTOMRIGHT, ui.TabContainer, BOTTOMRIGHT, 0, 0 )
		ui.AnimateTab:SetResizeToFitDescendents( true )
		ui.AnimateTab:SetHidden( true )

		ui.TriggerTab = EHT.CreateControl( prefix .. "TriggerTab", ui.TabContainer, CT_BUTTON )
		ui.TriggerTab:SetAnchor( TOPLEFT, ui.TabContainer, TOPLEFT, 0, 0 )
		ui.TriggerTab:SetAnchor( BOTTOMRIGHT, ui.TabContainer, BOTTOMRIGHT, 0, 0 )
		ui.TriggerTab:SetResizeToFitDescendents( true )
		ui.TriggerTab:SetHidden( true )

		ui.ToolTab = EHT.CreateControl( prefix .. "ToolTab", ui.TabContainer, CT_BUTTON )
		ui.ToolTab:SetAnchor( TOPLEFT, ui.TabContainer, TOPLEFT, 0, 0 )
		ui.ToolTab:SetAnchor( BOTTOMRIGHT, ui.TabContainer, BOTTOMRIGHT, 0, 0 )
		ui.ToolTab:SetResizeToFitDescendents( true )
		ui.ToolTab:SetHidden( true )

		ui.BuildTab = EHT.CreateControl( prefix .. "BuildTab", ui.TabContainer, CT_BUTTON )
		ui.BuildTab:SetAnchor( TOPLEFT, ui.TabContainer, TOPLEFT, 0, 0 )
		ui.BuildTab:SetAnchor( BOTTOMRIGHT, ui.TabContainer, BOTTOMRIGHT, 0, 0 )
		ui.BuildTab:SetResizeToFitDescendents( true )
		ui.BuildTab:SetHidden( true )

		ui.HistoryTab = EHT.CreateControl( prefix .. "HistoryTab", ui.TabContainer, CT_BUTTON )
		ui.HistoryTab:SetAnchor( TOPLEFT, ui.TabContainer, TOPLEFT, 0, 0 )
		ui.HistoryTab:SetAnchor( BOTTOMRIGHT, ui.TabContainer, BOTTOMRIGHT, 0, 0 )
		ui.HistoryTab:SetResizeToFitDescendents( true )
		ui.HistoryTab:SetHidden( true )

		EHT.UI.SetupToolDialogSelectionTab( ui, ui.SelectionTab, prefix, settings )
		EHT.UI.SetupToolDialogBuildTab( ui, ui.BuildTab, prefix, settings )
		EHT.UI.SetupToolDialogAnimateTab( ui, ui.AnimateTab, prefix, settings )
		EHT.UI.SetupToolDialogTriggerTab( ui, ui.TriggerTab, prefix, settings )
		EHT.UI.SetupToolDialogToolTab( ui, ui.ToolTab, prefix, settings )
		EHT.UI.SetupToolDialogHistoryTab( ui, ui.HistoryTab, prefix, settings )

		-- Progress Bar

		do
			local container
			do
				local c = EHT.CreateControl(prefix .. "ProcessProgressBarContainer", ui.Window, CT_CONTROL)
				container = c
				ui.ProcessProgressBarContainer = c
				c:SetAnchor(TOPLEFT, nil, BOTTOMLEFT, 0, 7)
				c:SetAnchor(BOTTOMRIGHT, nil, nil, 0, 61)
				c:SetHidden(true)
				c:SetInheritAlpha(false)
			end

			do
				local c = EHT.CreateControl(prefix .. "ProcessProgressBarBkg", container, CT_TEXTURE)
				ui.ProcessProgressBarBkg = c
				c:SetAnchor(TOPLEFT)
				c:SetAnchor(BOTTOMRIGHT, nil, TOPRIGHT, 0, 30)
				c:SetColor(0, 0, 0, 1)
				c:SetInheritAlpha(false)
			end

			do
				local c = EHT.CreateControl(prefix .. "ProcessProgressBar", ui.ProcessProgressBarBkg, CT_TEXTURE)
				ui.ProcessProgressBar = c
				c:SetAnchor(TOPLEFT, nil, nil, 3, 3)
				c:SetAnchor(BOTTOMRIGHT, nil, nil, -3, -3)
				c:SetColor(0, 0, 0, 1)
				c:SetInheritAlpha(false)
				c:SetVertexColors(VERTEX_POINTS_TOPLEFT + VERTEX_POINTS_TOPRIGHT, 0, 0, 1, 0.8)
				c:SetVertexColors(VERTEX_POINTS_BOTTOMLEFT + VERTEX_POINTS_BOTTOMRIGHT, 0.8, 0.8, 1, 0.8)
			end

			do
				local c = EHT.CreateControl(prefix .. "ProcessName", container, CT_LABEL)
				ui.ProcessName = c
				c:SetFont("ZoFontWinH5")
				c:SetAnchor(BOTTOM)
				c:SetColor(1, 1, 1, 1)
				c:SetInheritAlpha(false)
				c:SetText("")
			end

			do
				local c = CreateButton(prefix .. "ProcessCancel", container, "Cancel", CreateAnchor(TOP, container, TOP, 0, 1), 80, 28, EHT.Biz.CancelProcess)
				ui.ProcessCancel = c
				c:SetInheritAlpha(false)
			end
		end

		-- Window Controls

		do
			local b = EHT.CreateControl( prefix .. "SettingsButton", ui.Window, CT_BUTTON )
			ui.SettingsButton = b
			b:SetDimensions( 16, 16 )
			b:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
			b:SetAnchor( TOPLEFT, ui.Window, TOPLEFT, 12, 14 )
			b:SetNormalTexture( EHT.Textures.ICON_BUILD )
			b:SetPressedTexture( EHT.Textures.ICON_BUILD )
			b:SetMouseOverTexture( EHT.Textures.ICON_BUILD )
			b:SetHandler( "OnClicked", function() if EHT.Setup.ShowSettings() then EHT.UI.HideToolDialog() end end )

			EHT.UI.SetInfoTooltip( b, "Open the Settings panel." )
		end

		do
			local b = EHT.CreateControl( prefix .. "FeedbackButton", ui.Window, CT_BUTTON )
			ui.FeedbackButton = b
			b:SetDimensions( 20, 18 )
			b:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
			b:SetAnchor( LEFT, ui.SettingsButton, RIGHT, 3, 0 )
			b:SetNormalTexture( EHT.Textures.ICON_FEEDBACK )
			b:SetPressedTexture( EHT.Textures.ICON_FEEDBACK )
			b:SetMouseOverTexture( EHT.Textures.ICON_FEEDBACK )
			b:SetHandler( "OnClicked", function() EHT.UI.ShowFeedback() end )

			EHT.UI.SetInfoTooltip( b, "Submit any questions or feedback." )
		end

		do
			local b = EHT.CreateControl( prefix .. "HelpButton", ui.Window, CT_BUTTON )
			ui.HelpButton = b
			b:SetDimensions( 16, 16 )
			b:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
			b:SetAnchor( LEFT, ui.FeedbackButton, RIGHT, 3, 0 )
			b:SetNormalTexture( EHT.Textures.ICON_HELP )
			b:SetPressedTexture( EHT.Textures.ICON_HELP )
			b:SetMouseOverTexture( EHT.Textures.ICON_HELP )
			b:SetHandler( "OnClicked", function() EHT.UI.ShowNextTutorial( true ) end )

			EHT.UI.SetInfoTooltip( b, "Show tutorial tips for the current tab." )
		end

		do
			local b = EHT.CreateControl( prefix .. "VideoGuideButton", ui.Window, CT_BUTTON )
			ui.VideoGuideButton = b
			b:SetDimensions( 20, 16 )
			b:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
			b:SetAnchor( LEFT, ui.HelpButton, RIGHT, 3, 0 )
			b:SetNormalTexture( EHT.Textures.ICON_YOUTUBE )
			b:SetPressedTexture( EHT.Textures.ICON_YOUTUBE )
			b:SetMouseOverTexture( EHT.Textures.ICON_YOUTUBE )
			b:SetTextureCoords( 0, 1, 0, 23 / 32 )
			b:SetHandler( "OnClicked", function() EHT.UI.ShowHelp() end )

			EHT.UI.SetInfoTooltip( b, "Open the Video Tutorials in a web browser." )
		end

		c = CreateTexture( prefix .. "CloseButton", ui.Window, CreateAnchor( TOPRIGHT, ui.Window, TOPRIGHT, -12, 12 ) )
		ui.CloseButton = c
		c:SetTexture( EHT.Textures.ICON_CLOSE )
		c:SetColor( 1, 1, 1, 1 )
		c:SetDimensions( 16, 16 )
		c:SetMouseEnabled( true )
		c:SetHandler( "OnMouseDown", function() EHT.UI.HideToolDialog() end )
		EHT.UI.SetInfoTooltip( c, "Closes this window." )

		c = CreateTexture( prefix .. "MinimizeButton", ui.Window, CreateAnchor( TOPRIGHT, ui.CloseButton, TOPLEFT, -4, 0 ) )
		ui.MinimizeButton = c
		c:SetTexture( EHT.Textures.ICON_MINIMIZE )
		c:SetColor( 1, 1, 1, 1 )
		c:SetDimensions( 16, 16 )
		c:SetMouseEnabled( true )
		c:SetHandler( "OnMouseDown", function() EHT.UI.MinimizeToolDialog() end )
		EHT.UI.SetInfoTooltip( c, "Toggle window size to focus on the tabs, the directional controls or to minimize for less clutter." )

		c = CreateLabel( prefix .. "WindowTitle", ui.Window, "", CreateAnchor( TOP, ui.Window, TOP, 0, 10 ) )
		ui.WindowTitle = c
		SetLabelFont( c, 14, false, true )
		c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		c:SetText( string.format( "EHT  v%s", EHT.ADDON_VERSION ) )

		EHT.UI.SetToolDialogWindowTitle()
		ui.Window:SetHidden( true )
	end

	return ui
end

do
	local currentToolTab
	local unsavedChanges = false
	local lastBuildPosition

	function EHT.UI.HasUnsavedToolChanges()
		return true == unsavedChanges
	end

	function EHT.UI.SetUnsavedToolChanges( unsaved )
		unsavedChanges = unsaved
	end

	function EHT.UI.GetCurrentToolTab()
		local ui = EHT.UI.SetupToolDialog()

		if nil == ui or ui.Window:IsHidden() then return nil end
		return currentToolTab or EHT.CONST.TOOL_TABS.SELECT
	end

	function EHT.UI.ShowToolTab( tab, tabState )
		local tabChanged = nil
		local baseDrawLevel = 20
		local ui = EHT.UI.SetupToolDialog()

		if not isUIHidden and ui.Window:IsHidden() then
			ui.Window:SetHidden( false )
			EHT.UI.EnterUIMode()
			tabChanged = true
		end

		EHT.UI.HideEHTButtonContextMenu()
		EHT.UI.HideEHTEffectsButtonContextMenu()
		EHT.UI.RefreshEditToggles()
		EHT.UI.ClearWarning()
		EHT.UI.SetToolDialogWindowTitle()

		local previousTab = EHT.UI.GetCurrentToolTab()

		if nil == tabChanged then tabChanged = previousTab ~= tab end
		if nil == tab then tab = EHT.CONST.TOOL_TABS.SELECT end
		if tab ~= previousTab then
			EHT.Pointers.ClearPointers()
		end

		currentToolTab = tab

		ui.SelectionTab:SetHidden( tab ~= EHT.CONST.TOOL_TABS.SELECT )
		ui.AnimateTab:SetHidden( tab ~= EHT.CONST.TOOL_TABS.ANIMATE )
		ui.TriggerTab:SetHidden( tab ~= EHT.CONST.TOOL_TABS.TRIGGERS )
		ui.ToolTab:SetHidden( tab ~= EHT.CONST.TOOL_TABS.TOOLS )
		ui.BuildTab:SetHidden( tab ~= EHT.CONST.TOOL_TABS.BUILD )
		ui.HistoryTab:SetHidden( tab ~= EHT.CONST.TOOL_TABS.HISTORY )

		if tab == EHT.CONST.TOOL_TABS.SELECT then
			ui.SelectionTabButton.Button:SetHeight( 35 )
			ui.SelectionTabButton.Backdrop:SetHeight( 32 )
			ui.SelectionTabButton.Button:SetDrawLevel( baseDrawLevel - 1 )
			ui.SelectionTabButton.Button:SetColor(UnpackColor(Colors.White))
		else
			ui.SelectionTabButton.Button:SetHeight( 25 )
			ui.SelectionTabButton.Backdrop:SetHeight( 22 )
			ui.SelectionTabButton.Button:SetDrawLevel( baseDrawLevel )
			ui.SelectionTabButton.Button:SetColor(UnpackColor(Colors.ButtonLabel))
		end

		if tab == EHT.CONST.TOOL_TABS.ANIMATE then
			ui.AnimateTabButton.Button:SetHeight( 35 )
			ui.AnimateTabButton.Backdrop:SetHeight( 32 )
			ui.AnimateTabButton.Button:SetDrawLevel( baseDrawLevel - 1 )
			ui.AnimateTabButton.Button:SetColor(UnpackColor(Colors.White))

			ui.EditSceneGroup:SetHidden( nil ~= tabState and tabState ~= EHT.CONST.TOOL_TABS_STATE.DEFAULT )
			ui.LoadSceneGroup:SetHidden( tabState ~= EHT.CONST.TOOL_TABS_STATE.LOAD )
			ui.SaveSceneGroup:SetHidden( tabState ~= EHT.CONST.TOOL_TABS_STATE.SAVE )
			ui.MergeSceneGroup:SetHidden( tabState ~= EHT.CONST.TOOL_TABS_STATE.MERGE )
			ui.AppendSceneGroup:SetHidden( tabState ~= EHT.CONST.TOOL_TABS_STATE.APPEND )

			EHT.UI.RefreshAnimationDialog()
			EHT.Biz.CheckForMissingSceneItems()
		else
			ui.AnimateTabButton.Button:SetHeight( 25 )
			ui.AnimateTabButton.Backdrop:SetHeight( 22 )
			ui.AnimateTabButton.Button:SetDrawLevel( baseDrawLevel )
			ui.AnimateTabButton.Button:SetColor(UnpackColor(Colors.ButtonLabel))
		end

		if tab == EHT.CONST.TOOL_TABS.TRIGGERS then
			ui.TriggerTabButton.Button:SetHeight( 35 )
			ui.TriggerTabButton.Backdrop:SetHeight( 32 )
			ui.TriggerTabButton.Button:SetDrawLevel( baseDrawLevel - 1 )
			ui.TriggerTabButton.Button:SetColor(UnpackColor(Colors.White))

			EHT.UI.RefreshTriggers()
		else
			ui.TriggerTabButton.Button:SetHeight( 25 )
			ui.TriggerTabButton.Backdrop:SetHeight( 22 )
			ui.TriggerTabButton.Button:SetDrawLevel( baseDrawLevel )
			ui.TriggerTabButton.Button:SetColor(UnpackColor(Colors.ButtonLabel))
		end

		if tab == EHT.CONST.TOOL_TABS.TOOLS then
			ui.ToolTabButton.Button:SetHeight( 35 )
			ui.ToolTabButton.Backdrop:SetHeight( 32 )
			ui.ToolTabButton.Button:SetDrawLevel( baseDrawLevel - 1 )
			ui.ToolTabButton.Button:SetColor(UnpackColor(Colors.White))
		else
			ui.ToolTabButton.Button:SetHeight( 25 )
			ui.ToolTabButton.Backdrop:SetHeight( 22 )
			ui.ToolTabButton.Button:SetDrawLevel( baseDrawLevel )
			ui.ToolTabButton.Button:SetColor(UnpackColor(Colors.ButtonLabel))
		end

		if tab == EHT.CONST.TOOL_TABS.BUILD then
			ui.BuildTabButton.Button:SetHeight( 35 )
			ui.BuildTabButton.Backdrop:SetHeight( 32 )
			ui.BuildTabButton.Button:SetDrawLevel( baseDrawLevel - 1 )
			ui.BuildTabButton.Button:SetColor(UnpackColor(Colors.White))

			EHT.UI.RefreshBuild()
			if previousTab ~= tab then EHT.Biz.CheckBuildState() end
		else
			ui.BuildTabButton.Button:SetHeight( 25 )
			ui.BuildTabButton.Backdrop:SetHeight( 22 )
			ui.BuildTabButton.Button:SetDrawLevel( baseDrawLevel )
			ui.BuildTabButton.Button:SetColor(UnpackColor(Colors.ButtonLabel))

			EHT.Biz.CancelRandomizeBuild()
		end

		if tab == EHT.CONST.TOOL_TABS.HISTORY then
			ui.HistoryTabButton.Button:SetHeight( 35 )
			ui.HistoryTabButton.Backdrop:SetHeight( 32 )
			ui.HistoryTabButton.Button:SetDrawLevel( baseDrawLevel - 1 )
			ui.HistoryTabButton.Button:SetColor(UnpackColor(Colors.White))

			EHT.UI.RefreshHistory()
		else
			ui.HistoryTabButton.Button:SetHeight( 25 )
			ui.HistoryTabButton.Backdrop:SetHeight( 22 )
			ui.HistoryTabButton.Button:SetDrawLevel( baseDrawLevel )
			ui.HistoryTabButton.Button:SetColor(UnpackColor(Colors.ButtonLabel))
		end

		if tabChanged then
			EHT.UI.ShowNextTutorial()
		end

		EHT.UI.RefreshSelectionList()
		EHT.UI.SetToolDialogWindowTitle()

		return ui
	end

	function EHT.UI.ShowToolDialog()
		return EHT.UI.ShowToolTab( EHT.CONST.TOOL_TABS.SELECT )
	end

	function EHT.UI.ShowHideToolDialog()
		local firstLoad = EHT.UI.ToolDialog == nil
		local ui = EHT.UI.SetupToolDialog()

		if firstLoad or ui.Window:IsHidden() then
			PlayUISound( "GroupElection_VotedSubmitted" )
			return EHT.UI.ShowToolDialog()
		else
			PlayUISound( "Market_Opened" )
			EHT.UI.ClearDialogHidden( EHT.CONST.DIALOG.TOOL )
			ui.Window:SetHidden( true )
			EHT.UI.ExitUIMode()
			EHT.Biz.CancelRandomizeBuild()
			return ui
		end
	end

	function EHT.UI.MinimizeToolDialog()
		local ui = EHT.UI.SetupToolDialog()
		if nil == ui then return end
		if ui.Window:IsHidden() then return end

		local state = ui.WindowState or 1

		if 1 == state then
			local height = ui.EditSection:GetHeight() + 50

			ui.RestoreWidth, ui.RestoreHeight = ui.Window:GetWidth(), ui.Window:GetHeight()
			ui.TabControl:SetHidden( true )
			ui.TabBottomDivider:SetHidden( true )
			ui.Window:SetDimensionConstraints( EHT.CONST.UI.TOOL_DIALOG.MIN_WIDTH, height, EHT.CONST.UI.TOOL_DIALOG.MAX_WIDTH, height )
		elseif 2 == state then
			local height = ui.EditSection:GetHeight()

			ui.TabControl:SetHidden( false )
			ui.TabControl:ClearAnchors()
			ui.TabControl:SetAnchor( TOPLEFT, ui.Window, TOPLEFT, 18, 35 )
			ui.TabControl:SetAnchor( BOTTOMRIGHT, ui.Window, BOTTOMRIGHT, -25, -15 )
			ui.EditSection:SetHidden( true )
			ui.Window:SetDimensionConstraints( EHT.CONST.UI.TOOL_DIALOG.MIN_WIDTH, EHT.CONST.UI.TOOL_DIALOG.MIN_HEIGHT - height, EHT.CONST.UI.TOOL_DIALOG.MAX_WIDTH, EHT.CONST.UI.TOOL_DIALOG.MAX_HEIGHT )
		elseif 3 == state then
			ui.TabControl:SetHidden( true )
			ui.EditSection:SetHidden( true )
			ui.Window:SetDimensionConstraints( EHT.CONST.UI.TOOL_DIALOG.MIN_WIDTH, EHT.CONST.UI.TOOL_DIALOG.MINIMIZED_HEIGHT, EHT.CONST.UI.TOOL_DIALOG.MAX_WIDTH, EHT.CONST.UI.TOOL_DIALOG.MINIMIZED_HEIGHT )
		else
			ui.TabControl:SetHidden( false )
			ui.TabControl:ClearAnchors()
			ui.TabControl:SetAnchor( TOPLEFT, ui.Window, TOPLEFT, 18, 35 )
			ui.TabControl:SetAnchor( BOTTOMRIGHT, ui.EditSection, TOPRIGHT, 0, -10 )
			ui.EditSection:SetHidden( false )
			ui.TabBottomDivider:SetHidden( false )
			ui.Window:SetDimensionConstraints( EHT.CONST.UI.TOOL_DIALOG.MIN_WIDTH, EHT.CONST.UI.TOOL_DIALOG.MIN_HEIGHT, EHT.CONST.UI.TOOL_DIALOG.MAX_WIDTH, EHT.CONST.UI.TOOL_DIALOG.MAX_HEIGHT )

			if ui.RestoreWidth and ui.RestoreHeight then
				ui.Window:SetWidth( ui.RestoreWidth )
				ui.Window:SetHeight( ui.RestoreHeight )
			end
		end

		state = state + 1
		if state > 4 then state = 1 end
		ui.WindowState = state
	end

	function EHT.UI.IsToolDialogHidden()
		local ui = EHT.UI.ToolDialog
		return not ui or ui.Window:IsHidden()
	end

	function EHT.UI.EnableToolDialog()
		if nil == EHT.UI.ToolDialog then EHT.UI.SetupToolDialog() end
		local ui = EHT.UI.ToolDialog

		if not EHT.Biz.IsUninterruptableProcessRunning( true ) then
			for sectionKey, _ in pairs( EHT.CONST.UI_DISABLED_CONTROLS ) do
				ui[ sectionKey ]:SetAlpha( 1 )
			end
		end
	end

	function EHT.UI.DisableToolDialog()
		if nil == EHT.UI.ToolDialog then EHT.UI.SetupToolDialog() end
		local ui = EHT.UI.ToolDialog

		for sectionKey, _ in pairs( EHT.CONST.UI_DISABLED_CONTROLS ) do
			ui[ sectionKey ]:SetAlpha( 0.3 )
		end
	end
end

---[ Dialog : EHT Button ]---

do
	local ehtButtonHidden = false
	local ehtButtonLeft, ehtButtonTop = 0, 0
	local moveThreshold = 4

	local function UpdateMailOwnerPosition()
		local ui = EHT.UI.EHTButtonDialog
		if not ui then return end

		local screenLeft = ui.Window:GetCenter() <= GuiRoot:GetCenter()
		ui.MailOwner:ClearAnchors()
		ui.MailOwner:SetAnchor(screenLeft and LEFT or RIGHT, ui.EHTButton, screenLeft and RIGHT or LEFT, screenLeft and 46 or -46, 0)
	end
	
	local function UpdatePublishFXPosition()
		local ui = EHT.UI.EHTButtonDialog
		if not ui then return end

		local screenLeft = ui.Window:GetCenter() <= GuiRoot:GetCenter()
		ui.PublishFX:ClearAnchors()
		ui.PublishFX:SetAnchor(CENTER, ui.EHTButton, screenLeft and RIGHT or LEFT, screenLeft and 95 or -95, 45)
		ui.PublishFX.Label:ClearAnchors()
		ui.PublishFX.Label:SetAnchor(CENTER, ui.EHTButton, screenLeft and RIGHT or LEFT, screenLeft and 95 or -95, 82)
	end

	local function SetCaption( button, title )
		local ui = EHT.UI.EHTButtonDialog

		if title then
			ui.AltCaption:SetText( title )
			ui.AltCaption:SetAlpha( 1 )
		else
			ui.AltCaption:SetText( "" )
			ui.AltCaption:SetAlpha( 0 )
		end

		if EHT.GetSetting("AnimateEHTButton") then
			ui.SummonStorage:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, button == ui.SummonStorage and 1.7 or 1 )
			ui.FX:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, button == ui.FX and 1.7 or 1 )
			ui.HousingTools:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, button == ui.HousingTools and 1.7 or 1 )
			ui.HousingHub:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, button == ui.HousingHub and 1.7 or 1 )
			ui.Options:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, button == ui.Options and 1.7 or 1 )
			ui.EHTButton:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, button == ui.EHTButton and 2.5 or 1 )
		else
			ui.SummonStorage:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_ALPHA_AS_RGB, button == ui.SummonStorage and 0.5 or 0 )
			ui.FX:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_ALPHA_AS_RGB, button == ui.FX and 0.5 or 0 )
			ui.HousingTools:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_ALPHA_AS_RGB, button == ui.HousingTools and 0.5 or 0 )
			ui.HousingHub:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_ALPHA_AS_RGB, button == ui.HousingHub and 0.5 or 0 )
			ui.Options:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_ALPHA_AS_RGB, button == ui.Options and 0.5 or 0 )
		end

		ui.MailOwner:SetTextureSampleProcessingWeight(TEX_SAMPLE_PROCESSING_RGB, button == ui.MailOwner and 1 or .5)
		ui.MailOwner:SetAlpha(button == ui.MailOwner and 1 or .5)
		
		do
			local isPublishFX = button == ui.PublishFX
			if isPublishFX then
				ui.PublishFX.highlightAnimation:PlayForward()
			else
				ui.PublishFX.highlightAnimation:PlayBackward()
			end
		end
	end

	function EHT.UI.EHTButtonOnMoved()
		local ui = EHT.UI.EHTButtonDialog
		if nil == ui then return end

		zo_callLater(UpdateMailOwnerPosition, 200)
		zo_callLater(UpdatePublishFXPosition, 200)
		EHT.UI.SaveDialogSettings("EHTButtonDialog", ui.Window)
	end

	local function AnimateEHTButtonBackdrop()
		local ui = EHT.UI.EHTButtonDialog

		if nil == ui then
			EVENT_MANAGER:UnregisterForUpdate( "AnimateEHTButtonBackdrop" )
			return
		end

		if 1 == ui.TargetBackdropAlpha and 0.5 <= ui.BackdropAlpha then
			if EHT.UI.IsMouseOverControl( ui.Window ) or EHT.UI.IsMouseOverControl( ui.ToolsContextMenu.Window ) then
				return
			end
			ui.TargetBackdropAlpha = 0
			ui.TargetBackdropTime = GetFrameTimeMilliseconds() + 600
		end

		local complete, alpha, target, targetTime = false, ui.BackdropAlpha, ui.TargetBackdropAlpha, ui.TargetBackdropTime
		local duration, maxWeight = 1 == target and 460 or 600, 1 == target and 6 or 12
		local remaining = 1 - ( ( targetTime - GetFrameTimeMilliseconds() ) / duration )
		local current = 1 == target and 0.5 * remaining or 0.5 * ( 1 - remaining )

		if 1 == target then
			alpha = math.max( alpha, current )

			if alpha >= 0.5 then
				alpha = 0.5
			end
		else
			alpha = math.min( alpha, current )

			if alpha <= 0 then
				complete = true
			end
		end

		local sinAlpha = math.sin(2 * alpha * math.pi)
		local colorAlpha = 2 * sinAlpha
		local weight = 1.5 + maxWeight * sinAlpha

		ui.BackdropAlpha = alpha
		ui.Backdrop:SetColor(colorAlpha, colorAlpha, colorAlpha, 4 * alpha)
		ui.Backdrop:SetTextureSampleProcessingWeight(TEX_SAMPLE_PROCESSING_ALPHA_AS_RGB, weight)

		ui.SummonStorage:SetAlpha(2 * alpha)
		ui.FX:SetAlpha(2 * alpha)
		ui.HousingHub:SetAlpha(2 * alpha)
		ui.HousingTools:SetAlpha(2 * alpha)
		ui.Options:SetAlpha(2 * alpha)
		ui.ToolsContextMenu.SetAlpha(2 * alpha)
		ui.ToolsContextMenu.Window:SetHidden(0 >= alpha or not ui.FXContextMenu.Window:IsHidden() or not EHT.UI.IsToolDialogHidden())

		ui.EHTButton:SetAlpha( 1.5 - 2 * alpha )
		ui.Caption:SetAlpha( 1 - 2 * alpha )
		ui.AltCaption:SetAlpha( 2 * alpha )

		if complete then
			EVENT_MANAGER:UnregisterForUpdate( "AnimateEHTButtonBackdrop" )
		end
	end

	function EHT.UI.EHTButtonFade()
		local ui = EHT.UI.EHTButtonDialog
		if nil == ui then return end

		ui.TargetBackdropAlpha = 0
		ui.TargetBackdropTime = GetFrameTimeMilliseconds() + 600
	end

	function EHT.UI.EHTButtonOnMouseEnter()
		local ui = EHT.UI.EHTButtonDialog
		if nil == ui then return end
		if 1 == ui.TargetBackdropAlpha then return end

		if not ui.FXContextMenu.SuppressAutoHide then
			ui.FXContextMenu.Window:SetHidden( true )
		end

		if not ui.ToolsContextMenu.SuppressAutoHide then
			ui.ToolsContextMenu.Window:SetHidden( true )
		end

		EHT.UI.RefreshEditToggles()

		if EHT.GetSetting("AnimateEHTButton") then
			ui.TargetBackdropAlpha = 1
			ui.TargetBackdropTime = GetFrameTimeMilliseconds() + 460
			EVENT_MANAGER:RegisterForUpdate( "AnimateEHTButtonBackdrop", 10, AnimateEHTButtonBackdrop )
		end
	end

	function EHT.UI.EHTButtonOnMouseDown()
		local ui = EHT.UI.EHTButtonDialog
		if nil == ui then return end

		ehtButtonLeft, ehtButtonTop = ui.Window:GetLeft(), ui.Window:GetTop()
		ui.Window:StartMoving()
	end

	function EHT.UI.EHTButtonOnMouseUp( control, button, upInside, suppressDialog )
		local ui = EHT.UI.EHTButtonDialog
		if nil == ui then return end

		ui.Window:StopMovingOrResizing()

		ehtButtonLeft, ehtButtonTop = ehtButtonLeft or 0, ehtButtonTop or 0
		if ehtButtonLeft and ehtButtonTop and moveThreshold < math.abs( ehtButtonLeft - ui.Window:GetLeft() ) or moveThreshold < math.abs( ehtButtonTop - ui.Window:GetTop() ) then
			EHT.UI.SaveDialogSettings( "EHTButtonDialog", ui.Window )
			return
		end

		if button == MOUSE_BUTTON_INDEX_LEFT and upInside and not suppressDialog then
			EHT.UI.EHTButtonFade()
			EHT.UI.ShowHideToolDialog()
		end
	end

	function EHT.UI.ResetEHTButton()
		local ui = EHT.UI.EHTButtonDialog
		if ui then
			ui.EHTButton:SetAlpha( 1 )
			ui.Backdrop:SetAlpha( 0 )
			ui.Caption:SetAlpha( 1 )
			ui.AltCaption:SetAlpha( 0 )

			if EHT.GetSetting("AnimateEHTButton") then
				ui.SummonStorage:SetAlpha( 0 )
				ui.FX:SetAlpha( 0 )
				ui.HousingHub:SetAlpha( 0 )
				ui.HousingTools:SetAlpha( 0 )
				ui.Options:SetAlpha( 0 )
			else
				ui.SummonStorage:SetAlpha( 1 )
				ui.FX:SetAlpha( 1 )
				ui.HousingHub:SetAlpha( 1 )
				ui.HousingTools:SetAlpha( 1 )
				ui.Options:SetAlpha( 1 )
			end
		end
	end
--[[
	function EHT.UI.UpdateEHTButtonNoise()
		local ui = EHT.UI.EHTButtonDialog
		if not ui then
			return
		end

		local interval = EHT.World:GetLinearInterval( 20000, 0 )
		for index, p in ipairs( ui.Noise ) do
			EHT.World.RotateTexture( p, ( 0 == index % 2 and 1 or -1 ) * interval * RAD360, 0.5, 0.5, SCALEX or 1, SCALEY or 1 )
			p:SetAlpha( 0.5 + 0.5 * EHT.World.VariableEase( ( ( 0 == index % 2 and 0 or 0.5 ) + ( interval * 3 ) ) % 1, 2 ) )
			p:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 1 + ( SAMPLE or 2 ) * EHT.World.VariableEase( ( interval - index * 0.18 ) % 1, 1.2 ) )
		end
	end
]]
	local function GetEHTButtonDialog()
		return EHT.UI.EHTButtonDialog
	end

	function EHT.UI.SetupEHTButton()
		local ui = EHT.UI.EHTButtonDialog
		if nil == ui then
			do
				local win = WINDOW_MANAGER:CreateTopLevelWindow( "EHTHouseNameWin" )
				win:SetAlpha( 1 )
				win:SetDimensions( 250, 24 )
				win:SetClampedToScreen( true )
				win:SetClampedToScreenInsets( -6, -3, 6, 3 )
				win:SetMouseEnabled( true )
				win:SetMovable( true )
				win:SetResizeHandleSize( 0 )

				zo_callLater( function()
					local win = EHTHouseNameWin
					local settings = EHT.UI.GetDialogSettings( "EHTHouseNameWin" )

					if settings.Left and settings.Top then
						win:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, settings.Left, settings.Top )
					else
						win:SetAnchor( TOPRIGHT, GuiRoot, TOPRIGHT, -2, 2 )
					end

					EHT.UI.OnHouseNameMoved()
				end, 2000 )

				local c = EHT.CreateControl( "EHTHouseName", win, CT_LABEL )
				c:SetFont( "$(GAMEPAD_MEDIUM_FONT)|$(KB_22)|soft-shadow-thick" )
				c:SetInheritAlpha( false )
				c:SetColor( 1, 1, 1, 1 )
				c:SetDimensions( 250, 22 )
				c:SetHorizontalAlignment( TEXT_ALIGN_RIGHT )
				c:SetText( "" )
				c:SetAnchor( TOPRIGHT, win, TOPRIGHT, 0, 1 )
				c:SetMouseEnabled( false )

				win:SetHandler( "OnMoveStop", EHT.UI.OnHouseNameMoved )
			end

			local c, grp, win
			ui = { }
			EHT.UI.EHTButtonDialog = ui

			local prefix = "EHTButtonDialog"
			local settingsName = "EHTButtonDialog"
			local c, grp, win
			ui.Initialized = false

			-- Controls

			win = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
			ui.Window = win
			win:SetDimensionConstraints( 180, 80, 180, 80 )
			win:SetMovable( true )
			win:SetMouseEnabled( true )
			win:SetClampedToScreen( true )
			win:SetAlpha( 1 )
			win:SetDrawLevel( 10 )
			win:SetHidden( true )

			zo_callLater( function()
				local settings = EHT.UI.GetDialogSettings( settingsName )
				if settings.Left and settings.Top then
					win:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, settings.Left, settings.Top )
				else
					local housingEditorButton = EHT.UI.GetHousingHUDButton()
					if nil ~= housingEditorButton and not housingEditorButton:IsHidden() then
						win:SetAnchor( BOTTOM, housingEditorButton, TOP, 0, -40 )
					else
						win:SetAnchor( BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, -50, -50 )
					end
				end

				win:SetHandler( "OnMoveStop", EHT.UI.EHTButtonOnMoved )
				ui.Initialized = true
				EHT.UI.ShowEHTButton( not ui.Hidden )
			end, 1000 )

			ui.BackdropAlpha = 0
			c = EHT.CreateControl( prefix .. "Backdrop", win, CT_TEXTURE )
			ui.Backdrop = c
			c:SetColor(1, 1, 1, 0)
			c:SetTexture( EHT.Textures.ICON_RADIAL_MENU_BG )
			c:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
			c:SetDimensions( 180, 180 )
			c:SetAnchor( CENTER, win, CENTER, 0, -24 )
			c:SetMouseEnabled( true )
			c:SetBlendMode(TEX_BLEND_MODE_ADD)

			c = EHT.CreateControl( prefix .. "EHTButton", win, CT_TEXTURE )
			ui.EHTButton = c
			c:SetTexture( "esoui/art/campaign/gamepad/gp_overview_menuicon_home.dds" )
			c:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
			c:SetDimensions( 48, 48 )
			c:SetAnchor( TOP, win, TOP, 0, -10 )
			c:SetColor( UnpackColor(Colors.Icon) )
			c:SetMouseEnabled( true )
			c:SetHandler( "OnMouseEnter", function() SetCaption( ui.EHTButton, "Housing Tools" ) end )
			c:SetHandler( "OnMouseExit", function() SetCaption() end )
			c:SetHandler( "OnMouseDown", EHT.UI.EHTButtonOnMouseDown )
			c:SetHandler( "OnMouseUp", EHT.UI.EHTButtonOnMouseUp )

			c = EHT.CreateControl( prefix .. "Caption", win, CT_LABEL )
			ui.Caption = c
			c:SetFont( "$(BOLD_FONT)|$(KB_24)|thick-outline" )
			c:SetColor(UnpackColor(Colors.Label))
			c:SetAnchor( CENTER, ui.EHTButton, CENTER, 1, 20 )
			c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
			c:SetText( "EHT" )
			c:SetMouseEnabled( false )

			c = EHT.CreateControl( prefix .. "AltCaption", win, CT_LABEL )
			ui.AltCaption = c
			c:SetFont( "$(GAMEPAD_MEDIUM_FONT)|$(KB_26)|thick-outline" )
			c:SetColor(UnpackColor(Colors.Label, 0))
			c:SetAnchor( CENTER, ui.EHTButton, CENTER, 1, 38 )
			c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
			c:SetText( "" )
			c:SetMouseEnabled( false )

			c = EHT.CreateControl( prefix .. "SummonStorage", win, CT_TEXTURE )
			ui.SummonStorage = c
			c:SetTexture( EHT.Textures.ICON_BAG )
			c:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
			c:SetDimensions( 28, 28 )
			c:SetAnchor( BOTTOMRIGHT, ui.EHTButton, TOP, 14, -4 )
			c:SetColor(UnpackColor(Colors.Icon, 0))
			c:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 1 )
			c:SetMouseEnabled( true )
			c:SetHandler( "OnMouseEnter", function() SetCaption( ui.SummonStorage, "Bank & Storage" ) end )
			c:SetHandler( "OnMouseExit", function() SetCaption() end )
			c:SetHandler( "OnMouseDown", function() EHT.UI.SummonStorage() end )

			c = EHT.CreateControl( prefix .. "HousingTools", win, CT_TEXTURE )
			ui.HousingTools = c
			c:SetTexture( EHT.Textures.ICON_RADIAL_MENU )
			c:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
			c:SetDimensions( 28, 28 )
			c:SetAnchor( BOTTOMRIGHT, ui.EHTButton, TOP, -18, 12 )
			c:SetColor(UnpackColor(Colors.Icon, 0))
			c:SetTextureCoords( 0, 0.5, 0, 0.5 )
			c:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 1 )
			c:SetMouseEnabled( true )
			c:SetHandler( "OnMouseEnter", function() SetCaption( ui.HousingTools, "Housing Tools" ) end )
			c:SetHandler( "OnMouseExit", function() SetCaption() end )
			c:SetHandler( "OnMouseDown", function() EHT.UI.EHTButtonFade() EHT.UI.ShowHideToolDialog() end )

			c = EHT.CreateControl( prefix .. "HousingHub", win, CT_TEXTURE )
			ui.HousingHub = c
			c:SetTexture( EHT.Textures.ICON_RADIAL_MENU )
			c:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
			c:SetDimensions( 28, 28 )
			c:SetAnchor( BOTTOMLEFT, ui.EHTButton, TOP, 18, 12 )
			c:SetColor(UnpackColor(Colors.Icon, 0))
			c:SetTextureCoords( 0.5, 1, 0, 0.5 )
			c:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 1 )
			c:SetMouseEnabled( true )
			c:SetHandler( "OnMouseEnter", function() SetCaption( ui.HousingHub, "Housing Hub" ) end )
			c:SetHandler( "OnMouseExit", function() SetCaption() end )
			c:SetHandler( "OnMouseDown", function() EHT.UI.ShowHousingHub() end )

			c = EHT.CreateControl( prefix .. "MailOwner", win, CT_TEXTURE )
			ui.MailOwner = c
			c:SetTexture( EHT.Textures.ICON_MAIL_OWNER )
			c:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
			c:SetDimensions( 52*(247/234), 52 )
			zo_callLater( UpdateMailOwnerPosition, 1500 )
			c:SetColor( UnpackColor(Colors.White, 0.5) )
			c:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 1 )
			c:SetMouseEnabled( true )
			c:SetHandler( "OnMouseEnter", function() SetCaption( ui.MailOwner, "Contact Homeowner" ) end )
			c:SetHandler( "OnMouseExit", function() SetCaption() end )
			c:SetHandler( "OnMouseDown", function()
				if EHT.Housing.IsHouseZone() and not EHT.Housing.IsOwner() then
					local owner = EHT.Housing.GetHouseOwner()
					local houseName = EHT.Housing.GetHouseName()

					SCENE_MANAGER:Show( "mailSend" )

					zo_callLater( function()
						ZO_MailSendToField:SetText( owner )
						ZO_MailSendSubjectField:SetText( string.format( "Re: Your %s", houseName ) )
						ZO_MailSendBodyField:TakeFocus()
					end, 500 )
				else
					EHT.ShowAlertDialog( "", "You must be in someone else's home in order to email the owner." )
				end
			end )

			c = EHT.CreateControl(prefix .. "PublishFXLabel", win, CT_LABEL)
			ui.PublishFXLabel = c
			c:SetColor(UnpackColor(Colors.White, 0))
			c:SetFont("$(BOLD_FONT)|$(KB_16)|soft-shadow-thick")
			c:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
			c:SetText("Publish\nFX")
			c:SetMouseEnabled(false)

			c = EHT.CreateControl(prefix .. "PublishFX", win, CT_TEXTURE)
			ui.PublishFX = c
			ui.PublishFX.Label = ui.PublishFXLabel
			c:SetTexture(EHT.Textures.ICON_FX_UNPUBLISHED)
			c:SetTextureReleaseOption(RELEASE_TEXTURE_AT_ZERO_REFERENCES)
			c:SetDimensions(64, 64)
			zo_callLater(UpdatePublishFXPosition, 1500)
			c:SetColor(UnpackColor(Colors.White))
			c:SetTextureCoords(0, 1, -(1 - .5624), .5624)
			c:SetMouseEnabled(true)

			local BounceEase = ZO_GenerateCubicBezierEase(.48, .74, .06, 1.54)

			do
				local timeline = ANIMATION_MANAGER:CreateTimeline()
				ui.PublishFX.alphaAnimation = timeline

				local animation = timeline:InsertAnimation(ANIMATION_CUSTOM, ui.PublishFX)
				animation:SetDuration(500)

				local function Update(timeline, progress)
					local control = timeline:GetAnimatedControl()
					local easedProgress = BounceEase(progress)
					control:SetAlpha(zo_lerp(0, .65, easedProgress))
				end
				animation:SetUpdateFunction(Update)
			end

			do
				local timeline = ANIMATION_MANAGER:CreateTimeline()
				ui.PublishFX.highlightAnimation = timeline

				local animation = timeline:InsertAnimation(ANIMATION_CUSTOM, ui.PublishFX)
				animation:SetDuration(350)

				local function Update(timeline, progress)
					local control = timeline:GetAnimatedControl()
					local easedProgress = BounceEase(progress)
					local y1 = zo_lerp(-.4, 0, easedProgress)
					local y2 = zo_lerp(.6, 1, easedProgress)
					control:SetTextureCoords(0, 1, y1, y2)
					control:SetAlpha(.65 + .35 * easedProgress)
					control.Label:SetAlpha(easedProgress)
				end
				animation:SetUpdateFunction(Update)
			end

			c:SetHandler("OnMouseEnter", function()
				ui.PublishFX.highlightAnimation:PlayForward()
			end)

			c:SetHandler("OnMouseExit", function()
				ui.PublishFX.highlightAnimation:PlayBackward()
			end)

			c:SetHandler("OnMouseDown", function()
				if EHT.Housing.IsHouseZone() and EHT.Housing.IsOwner() then
					EHT.UI.PublishFX()
				end
			end)

			c = EHT.CreateControl( prefix .. "FX", win, CT_TEXTURE )
			ui.FX = c
			c:SetTexture( EHT.Textures.ICON_RADIAL_MENU )
			c:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
			c:SetDimensions( 28, 28 )
			c:SetAnchor( TOPRIGHT, ui.HousingTools, BOTTOM, 2, 6 )
			c:SetColor(UnpackColor(Colors.Icon, 0))
			c:SetTextureCoords( 0.5, 1, 0.5, 1 )
			c:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 1 )
			c:SetMouseEnabled( true )
			c:SetHandler( "OnMouseEnter", function() SetCaption( ui.FX, "Essential FX" ) end )
			c:SetHandler( "OnMouseExit", function() SetCaption() end )

			c = EHT.CreateControl( prefix .. "Options", win, CT_TEXTURE )
			ui.Options = c
			c:SetTexture( EHT.Textures.ICON_RADIAL_MENU )
			c:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
			c:SetDimensions( 28, 28 )
			c:SetAnchor( TOPLEFT, ui.HousingHub, BOTTOM, 0, 6 )
			c:SetColor(UnpackColor(Colors.Icon, 0))
			c:SetTextureCoords( 0, 0.5, 0.5, 1 )
			c:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 1 )
			c:SetMouseEnabled( true )
			c:SetHandler( "OnMouseEnter", function() SetCaption( ui.Options, "Shortcuts & Options" ) end )
			c:SetHandler( "OnMouseExit", function() SetCaption() end )
			c:SetHandler( "OnMouseDown", function()
				EHT.UI.HideToolDialog()
				ui.ShowToolsContextMenu()
			end )

			do
				local contextMenu = EHT.UI.SetupEHTButtonContextMenu( BOTTOM, ui.Window, TOP, 0, -40 )
				ui.ToolsContextMenu = contextMenu

				ui.HideToolsContextMenu = function()
					ui.ToolsContextMenu.Window:SetHidden( true )
					ui.ToolsContextMenu.SuppressAutoHide = false
				end

				ui.ShowToolsContextMenu = function()
					EHT.UI.RefreshEditToggles()
					EHT.UI.HideEHTEffectsButtonContextMenu()

					if ui.ToolsContextMenu.Window:IsHidden() then
						ui.ToolsContextMenu.SuppressAutoHide = true
						ui.ToolsContextMenu.Window:SetHidden( false )
						EHT.UI.FocusLostHide( contextMenu.Window, { contextMenu.Window, ui.Window, ui.Options }, 750 )
					else
						ui.HideToolsContextMenu()
					end
				end
			end

			do
				local contextMenu = EHT.UI.SetupEHTEffectsButtonContextMenu( BOTTOM, ui.Window, TOP, 0, -22 )
				local firstUse = true
				ui.FXContextMenu = contextMenu

				function EHT.UI.ShowEHTEffectsButtonContextMenu()
					EHT.UI.HideEffectsPreviewDialog()
					EHT.UI.EHTButtonFade()
					local hidden = not contextMenu.Window:IsHidden()
					if not hidden then
						EHT.UI.HideToolDialog()
					end
					ui.ToolsContextMenu.Window:SetHidden( not hidden )
					ui.FXContextMenu.SuppressAutoHide = true
					ui.FXContextMenu.Window:SetHidden( hidden )

					if hidden then
						PlayUISound( "Champion_ZoomOut" )
					else
						PlayUISound( "Champion_ZoomIn" )
					end

					if firstUse then
						firstUse = false
						contextMenu.ToggleTab( 1 )
					end

					return contextMenu
				end

				ui.FX:SetHandler( "OnMouseDown", EHT.UI.ShowEHTEffectsButtonContextMenu )
			end

			local limits = EHT.CreateControl( prefix .. "LimitContainer", win, CT_CONTROL )
			ui.LimitContainer = limits
			limits:SetAnchor( TOP, ui.EHTButton, BOTTOM, 0, 14 )
			limits:SetResizeToFitDescendents( true )
			limits:SetMouseEnabled( false )

			grp = EHT.CreateControl( prefix .. "PopLimit", limits, CT_CONTROL )
			ui.PopLimit = grp
			grp:SetAnchor( LEFT, limits, LEFT, 0, 0 )
			grp:SetResizeToFitDescendents( true )
			grp:SetMouseEnabled( false )

			c = EHT.CreateControl( nil, grp, CT_TEXTURE )
			c:SetTexture( EHT.Textures.ICON_LIMITS )
			c:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
			c:SetDimensions( 22, 24 )
			c:SetAnchor( LEFT, grp, LEFT, 2, 2 )
			c:SetColor( 0, 0, 0, 0.7 )
			c:SetMouseEnabled( false )
			c:SetTextureCoords( 0.5, 0.9, 0, 0.5 )

			c = EHT.CreateControl( prefix .. "PopulationIcon", grp, CT_TEXTURE )
			ui.PopulationIcon = c
			c:SetTexture( EHT.Textures.ICON_LIMITS )
			c:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
			c:SetDimensions( 22, 23 )
			c:SetAnchor( LEFT, grp, LEFT, 0, 0 )
			c:SetColor(UnpackColor(Colors.Icon))
			c:SetMouseEnabled( false )
			c:SetTextureCoords( 0.5, 0.9, 0, 0.5 )

			c = EHT.CreateControl( prefix .. "PopulationLabel", grp, CT_LABEL )
			ui.PopulationLabel = c
			c:SetFont( "$(BOLD_FONT)|$(KB_18)|thick-outline" )
			c:SetColor(UnpackColor(Colors.Label, 0.9))
			c:SetAnchor( LEFT, ui.PopulationIcon, RIGHT, 1, 0 )
			c:SetMouseEnabled( false )

			c = EHT.CreateControl( prefix .. "PopulationMaxLabel", grp, CT_LABEL )
			ui.PopulationMaxLabel = c
			c:SetFont( "$(MEDIUM_FONT)|$(KB_15)|outline" )
			c:SetColor(UnpackColor(Colors.Label, 0.9))
			c:SetAnchor( TOP, ui.PopulationLabel, BOTTOM, 0, 0 )
			c:SetMouseEnabled( false )

			grp = EHT.CreateControl( prefix .. "FurnitureLimit", limits, CT_CONTROL )
			ui.FurnitureLimit = grp
			grp:SetAnchor( LEFT, ui.PopLimit, RIGHT, 10, 0 )
			grp:SetResizeToFitDescendents( true )
			grp:SetMouseEnabled( false )

			c = EHT.CreateControl( nil, grp, CT_TEXTURE )
			c:SetTexture( EHT.Textures.ICON_LIMITS )
			c:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
			c:SetDimensions( 23, 25 )
			c:SetAnchor( LEFT, grp, LEFT, 2, 2 )
			c:SetColor( 0, 0, 0, 0.7 )
			c:SetMouseEnabled( false )
			c:SetTextureCoords( 0, 0.4, 0, 0.5 )

			c = EHT.CreateControl( prefix .. "FurnitureIcon", grp, CT_TEXTURE )
			ui.FurnitureIcon = c
			c:SetTexture( EHT.Textures.ICON_LIMITS )
			c:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
			c:SetDimensions( 23, 25 )
			c:SetAnchor( LEFT, grp, LEFT, 0, 0 )
			c:SetColor(UnpackColor(Colors.Icon))
			c:SetMouseEnabled( false )
			c:SetTextureCoords( 0, 0.4, 0, 0.5 )

			c = EHT.CreateControl( prefix .. "LimitLabel", grp, CT_LABEL )
			ui.LimitLabel = c
			c:SetFont( "$(BOLD_FONT)|$(KB_18)|thick-outline" )
			c:SetColor(UnpackColor(Colors.Label, 0.9))
			c:SetAnchor( LEFT, ui.FurnitureIcon, RIGHT, 1, 0 )
			c:SetMouseEnabled( false )

			c = EHT.CreateControl( prefix .. "LimitMaxLabel", grp, CT_LABEL )
			ui.LimitMaxLabel = c
			c:SetFont( "$(MEDIUM_FONT)|$(KB_15)|outline" )
			c:SetColor(UnpackColor(Colors.Label, 0.9))
			c:SetAnchor( TOP, ui.LimitLabel, BOTTOM, 0, 0 )
			c:SetMouseEnabled( false )

			grp = EHT.CreateControl( prefix .. "FXLimit", limits, CT_CONTROL )
			ui.FXLimit = grp
			grp:SetAnchor( LEFT, ui.FurnitureLimit, RIGHT, 10, 0 )
			grp:SetResizeToFitDescendents( true )
			grp:SetMouseEnabled( false )

			c = EHT.CreateControl( nil, grp, CT_TEXTURE )
			c:SetTexture( EHT.Textures.ICON_LIMITS )
			c:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
			c:SetDimensions( 26, 26 )
			c:SetAnchor( LEFT, grp, LEFT, 2, 2 )
			c:SetColor( 0, 0, 0, 0.7 )
			c:SetMouseEnabled( false )
			c:SetTextureCoords( 0, 0.45, 0.5, 1 )

			c = EHT.CreateControl( prefix .. "FXIcon", grp, CT_TEXTURE )
			ui.FXIcon = c
			c:SetTexture( EHT.Textures.ICON_LIMITS )
			c:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
			c:SetDimensions( 26, 26 )
			c:SetAnchor( LEFT, grp, LEFT, 0, 0 )
			c:SetColor(UnpackColor(Colors.Icon))
			c:SetMouseEnabled( false )
			c:SetTextureCoords( 0, 0.45, 0.5, 1 )

			c = EHT.CreateControl( prefix .. "FXLabel", grp, CT_LABEL )
			ui.FXLabel = c
			c:SetFont( "$(BOLD_FONT)|$(KB_18)|thick-outline" )
			c:SetColor(UnpackColor(Colors.Label, 0.9))
			c:SetAnchor( LEFT, ui.FXIcon, RIGHT, 1, 0 )
			c:SetMouseEnabled( false )

			c = EHT.CreateControl( prefix .. "FXMaxLabel", grp, CT_LABEL )
			ui.FXMaxLabel = c
			c:SetFont( "$(MEDIUM_FONT)|$(KB_15)|outline" )
			c:SetColor(UnpackColor(Colors.Label, 0.9))
			c:SetAnchor( TOP, ui.FXLabel, BOTTOM, 0, 0 )
			c:SetMouseEnabled( false )
--[[			
			ui.Noise = {}

			local numNoiseTextures = 2
			for noiseIndex = 1, numNoiseTextures do
				c = EHT.CreateControl( nil, win, CT_TEXTURE )
				table.insert( ui.Noise, c )
				c:SetAnchor( CENTER, win, CENTER, 0, 1 == noiseIndex and 15 or -15 )
				c:SetBlendMode( TEX_BLEND_MODE_COLOR_DODGE )
				c:SetDimensions( 256, 256 )
				c:SetDrawLayer( DL_OVERLAY )
				c:SetDrawLevel( 220000 )
				c:SetDrawTier( DT_HIGH )
				c:SetColor( 1, 1, 1, 0 )
				c:SetMouseEnabled( false )
				c:SetTexture( EHT.Textures.NOISE_NEGATIVE )
				c:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
				c:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 1.2 )
			end
]]
			win:SetHidden( true )
			for index, control in pairs( ui ) do
				if "userdata" == type( control ) and control:IsMouseEnabled() then
					local prevEnter = control:GetHandler( "OnMouseEnter" )
					if prevEnter then
						control:SetHandler( "OnMouseEnter", function( ... ) prevEnter( ... ) EHT.UI.EHTButtonOnMouseEnter() end )
					else
						control:SetHandler( "OnMouseEnter", EHT.UI.EHTButtonOnMouseEnter )
					end
				end
			end

			EHT.UI.ResetEHTButton()
		end

		return ui
	end
	
	function EHT.UI.RefreshHousingHUDButton()
		if 0 ~= GetCurrentZoneHouseId() then
			local c = EHT.UI.GetHousingHUDButton()

			if nil ~= c then
				if ehtButtonHidden then
					c:SetHidden( true )
					return
				end

				if EHT.SavedVars.HideHousingEditorHUDButton then
					if GetHousingVisitorRole() ~= HOUSING_VISITOR_ROLE_PREVIEW  then
						c:SetHidden( true )
						return
					end
				end

				c:SetHidden( false )
			end
		end
	end
	
	function EHT.UI.RefreshPublishFXButton()
		local ui = GetEHTButtonDialog()
		if ui and ui.Initialized then
			local publishFX = ui.PublishFX
			local uiHidden = ui.Hidden or not EHT.Housing.IsHouseZone() or not EHT.Housing.IsOwner()
			local fxHidden = not EHT.Data.AreHouseFXDirty()
			local hidden = uiHidden or fxHidden
			publishFX:SetHidden(hidden)

			local uiHiddenChanged = publishFX.wasUIHidden == uiHidden
			local fxHiddenChanged = publishFX.wasFXHidden == fxHidden
			publishFX.wasUIHidden = uiHidden
			publishFX.wasFXHidden = fxHidden
			if fxHiddenChanged then
				if fxHidden then
					publishFX.alphaAnimation:PlayBackward()
				else
					publishFX.alphaAnimation:PlayForward()
				end
			end
		end
	end

	function EHT.UI.ShowEHTButton( isShown )
		if nil == isShown then isShown = true end
		if ehtButtonHidden then isShown = false end

		local ui = EHT.UI.SetupEHTButton()
		if not ui then return end

		ui.Hidden = not isShown
		if ui.Initialized then
			ui.Window:SetHidden(ui.Hidden)
			EHTHouseNameWin:SetHidden(ui.Hidden)

			local hideMailOwner = ui.Hidden or not EHT.Housing.IsHouseZone() or EHT.Housing.IsOwner()
			ui.MailOwner:SetHidden(hideMailOwner)

			EHT.UI.RefreshPublishFXButton()
		end

		if isShown and EHT.UI.IsTutorialHidden() then EHT.UI.ShowNextTutorial() end
	end

	function EHT.UI.RefreshEHTButton()
		local houseId = GetCurrentZoneHouseId()
		EHT.UI.ShowEHTButton( houseId and houseId ~= 0 )
	end

	function EHT.UI.ToggleEHTButton()
		ehtButtonHidden = not ehtButtonHidden
		EHT.UI.RefreshEHTButton()
	end

	function EHT.UI.GetCustomHouseName()
		return EHT.CurrentHouseName
	end

	function EHT.UI.SetCustomHouseName( name )
		local houseId, ownerName, isOwner, houseName, houseNickname, customHouseNickname = EHT.Housing.GetHouseInfo()

		EHT.CurrentHouseName = name
		if not EHT.CurrentHouseName or "" == EHT.CurrentHouseName then
			if 0 ~= houseId then
				if isOwner then
					EHT.CurrentHouseName = houseNickname
				else
					EHT.CurrentHouseName = customHouseNickname
				end
			end
		end

		if EHTHouseName then
			EHTHouseName:SetText( EHT.CurrentHouseName or houseName or "" )
		end
	end

	function EHT.UI.OnHouseNameMoved()
		local win = EHTHouseNameWin
		if not win then return end

		EHT.UI.SaveDialogSettings( "EHTHouseNameWin", win )

		local x, y = win:GetCenter()
		local centerX = GuiRoot:GetCenter()
		local screenWidth = GuiRoot:GetWidth()
		local textAlign, anchorLocal, anchorRelative

		local distCenter = math.abs( centerX - x )
		local distLeft = x
		local distRight = screenWidth - x

		if distLeft < distCenter and distLeft < distRight then
			textAlign = TEXT_ALIGN_LEFT
			anchorLocal, anchorRelative = TOPLEFT, TOPLEFT
		elseif distRight < distCenter and distRight < distLeft then
			textAlign = TEXT_ALIGN_RIGHT
			anchorLocal, anchorRelative = TOPRIGHT, TOPRIGHT
		else
			textAlign = TEXT_ALIGN_CENTER
			anchorLocal, anchorRelative = TOP, TOP
		end

		EHTHouseName:ClearAnchors()
		EHTHouseName:SetAnchor( anchorLocal, win, anchorRelative, 0, 1 )
		EHTHouseName:SetHorizontalAlignment( textAlign )
	end
end

---[ Dialog : Certification ]---

function EHT.UI.SetupCertificationDialog()
	local ui = EHT.UI.CertificationDialog
	if nil == ui then
		ui = { }
		EHT.UI.CertificationDialog = ui

		local prefix = "EHTCertificationDialog"
		local settingsName = "CertificationDialog"
		local c, grp, win

		-- Controls

		win = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
		ui.Window = win
		win:SetAlpha( 0.8 )
		win:SetClampedToScreen( true )
		win:SetDimensionConstraints( 84, 84, 84, 84 )
		win:SetHidden( true )
		win:SetMouseEnabled( true )
		win:SetMovable( true )
		win:SetResizeHandleSize( 0 )

		local settings = EHT.UI.GetDialogSettings( settingsName )

		if settings.Left and settings.Top then
			win:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, settings.Left, settings.Top )
		else
			win:SetAnchor( TOPRIGHT, GuiRoot, TOPRIGHT, -30, -30 )
		end

		win:SetHandler( "OnMoveStop", function() EHT.UI.SaveDialogSettings( settingsName, win ) end )

		c = EHT.CreateControl( nil, win, CT_TEXTURE )
		ui.Seal = c
		c:SetTexture( "art/fx/texture/aoe_circle_hollow.dds" )
		c:SetAnchor( CENTER, win, CENTER, 0, 36 )
		c:SetDimensions( 118, 118 )
		c:SetColor( 1.0, 1.0, 1.0, 0.3 )
		c:SetMouseEnabled( false )

		c = EHT.CreateControl( nil, win, CT_TEXTURE )
		ui.House = c
		c:SetTexture( "esoui/art/guild/tabicon_home_down.dds" )
		c:SetAnchor( CENTER, win, CENTER, 0, 0 )
		c:SetDimensions( 50, 50 )
		c:SetColor( 1.0, 1.0, 1.0, 1.0 )
		c:SetMouseEnabled( false )

		c = EHT.CreateControl( prefix .. "EHTLabel", win, CT_LABEL )
		ui.EHTLabel = c
		c:SetFont( "$(BOLD_FONT)|$(KB_54)|soft-shadow-thick" )
		c:SetColor( 1.0, 1.0, 1.0, 1.0 )
		c:SetAnchor( TOP, ui.House, BOTTOM, 0, -18 )
		c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		c:SetText( "EHT" )
		c:SetMouseEnabled( false )

		c = EHT.CreateControl( prefix .. "CertLabel", win, CT_LABEL )
		ui.CertLabel = c
		c:SetFont( "$(HANDWRITTEN_FONT)|$(KB_24)|soft-shadow-thick" )
		c:SetColor( 1.0, 1.0, 0.2, 1.0 )
		c:SetAnchor( TOP, ui.EHTLabel, BOTTOM, 0, -14 )
		c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		c:SetText( "Certified" )
		c:SetMouseEnabled( false )
	end
	ui.Window:SetHidden( not ui.Window:IsHidden() )
	return ui
end

SLASH_COMMANDS[ "/ehtcert" ] = EHT.UI.SetupCertificationDialog

---[ Dialog : Death Counter ]---

do
	local deaths = 0

	function EHT.UI.SetupDeathCounterDialog()
		local ui = EHT.UI.DeathCounterDialog
		if nil == ui then
			ui = { }
			EHT.UI.DeathCounterDialog = ui

			local prefix = "EHTDeathCounterDialog"
			local settingsName = "DeathCounterDialog"
			local settings = EHT.UI.GetDialogSettings( settingsName )
			local drawLevel = 1000
			local dim = 200
			local c, grp, w
			local characterTexture, characterWidth, characterHeight = EHT.UI.GetDeathCounterCharacterTexture( dim )

			-- Controls

			w = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
			ui.Window = w
			w:SetAlpha( 0.8 )
			w:SetClampedToScreen( true )
			w:SetDimensionConstraints( 160, 160, dim, dim )
			w:SetHidden( true )
			w:SetMouseEnabled( true )
			w:SetMovable( true )
			w:SetResizeHandleSize( 0 )
			w:SetDrawLevel( drawLevel ) drawLevel = drawLevel + 1
			if settings.Left and settings.Top then
				w:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, settings.Left, settings.Top )
			else
				w:SetAnchor( RIGHT, GuiRoot, RIGHT, -30, 0 )
			end
			w:SetHandler( "OnMoveStop", function() EHT.UI.SaveDialogSettings( settingsName, w ) end )
			w:SetHandler( "OnMouseDown", function( evt, button )
				if button == MOUSE_BUTTON_INDEX_RIGHT then
					w:SetHidden( true )
					w:SetAlpha( 0 )
				end
			end )
			EHT.UI.SetInfoTooltip( w, "Right-click to hide\nClick+Hold to move" )

			c = EHT.CreateControl( nil, w, CT_TEXTURE )
			ui.TextBackdrop = c
			c:SetTexture( EHT.Textures.CIRCLE_SOFT )
			c:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
			c:SetAnchor( CENTER, w, BOTTOMRIGHT, -40, -35 )
			c:SetDimensions( 80, 80 )
			c:SetColor( 0, 0, 0, 1 )
			c:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 2 )
			c:SetMouseEnabled( false )
			c:SetDrawLevel( drawLevel ) drawLevel = drawLevel + 1

			c = EHT.CreateControl( nil, w, CT_LABEL )
			ui.Sponsor = c
			c:SetFont( "$(BOLD_FONT)|$(KB_20)|thin-outline" )
			c:SetColor( 1, 1, 1, 0 )
			c:SetAnchor( BOTTOM, w, TOP, 0, 12 )
			c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
			c:SetText( "Sponsored by EHT" )
			c:SetMouseEnabled( false )
			c:SetDrawLevel( drawLevel ) drawLevel = drawLevel + 1

			c = EHT.CreateControl( nil, w, CT_TEXTURE )
			ui.Silhouette = c
			c:SetTexture( characterTexture )
			c:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
			c:SetAnchor( LEFT, w, LEFT, 8, 0 )
			c:SetDimensions( characterWidth, characterHeight )
			c:SetColor( 0, 0, 0, 1 )
			c:SetMouseEnabled( false )
			c:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 1.7 )
			c:SetDrawLevel( drawLevel ) drawLevel = drawLevel + 1

			c = EHT.CreateControl( nil, w, CT_TEXTURE )
			ui.Scythe = c
			c:SetTexture( EHT.Textures.SCYTHE )
			c:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
			c:SetAnchorFill( w )
			c:SetMouseEnabled( false )
			c:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 3 )
			c:SetDrawLevel( drawLevel ) drawLevel = drawLevel + 1

			c = EHT.CreateControl( nil, w, CT_TEXTURE )
			ui.Character = c
			c:SetTexture( characterTexture )
			c:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
			c:SetAnchor( LEFT, w, LEFT, 8, 0 )
			c:SetDimensions( characterWidth, characterHeight )
			c:SetColor( 0.8, 0.7, 0.7, 1 )
			c:SetMouseEnabled( false )
			c:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 1.8 )
			c:SetDrawLevel( drawLevel ) drawLevel = drawLevel + 1

			c = EHT.CreateControl( nil, w, CT_LABEL )
			ui.Caption = c
			c:SetFont( "$(MEDIUM_FONT)|$(KB_24)|soft-shadow-thick" )
			c:SetColor( 1, 1, 1, 1 )
			c:SetAnchor( BOTTOM, w, BOTTOMRIGHT, -40, 2 )
			c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
			c:SetText( "" )
			c:SetMouseEnabled( false )
			c:SetDrawLevel( drawLevel ) drawLevel = drawLevel + 1

			c = EHT.CreateControl( nil, w, CT_LABEL )
			ui.Counter = c
			c:SetFont( "$(BOLD_FONT)|$(KB_36)|soft-shadow-thick" )
			c:SetColor( 1, 0, 0, 0 )
			c:SetAnchor( CENTER, w, BOTTOMRIGHT, -40, -45 )
			c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
			c:SetText( "" )
			c:SetMouseEnabled( false )
			c:SetDrawLevel( drawLevel ) drawLevel = drawLevel + 1

			c = EHT.CreateControl( nil, w, CT_LABEL )
			ui.CounterCallout = c
			c:SetFont( "$(BOLD_FONT)|$(KB_54)|thin-outline" )
			c:SetColor( 0, 0, 0, 0 )
			c:SetAnchor( CENTER, w, BOTTOMRIGHT, -43, -42 )
			c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
			c:SetText( "" )
			c:SetMouseEnabled( false )
			c:SetDrawLevel( drawLevel ) drawLevel = drawLevel + 1

			c = EHT.CreateControl( nil, w, CT_LABEL )
			ui.CounterCallout2 = c
			c:SetFont( "$(BOLD_FONT)|$(KB_54)|thin-outline" )
			c:SetColor( 1, 1, 1, 0 )
			c:SetAnchor( CENTER, w, BOTTOMRIGHT, -40, -45 )
			c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
			c:SetText( "" )
			c:SetMouseEnabled( false )
			c:SetDrawLevel( drawLevel ) drawLevel = drawLevel + 1
		end
		return ui
	end

	function EHT.UI.ShowDeathCounterDialog( show )
		local ui = EHT.UI.SetupDeathCounterDialog()
		ui.Counter:SetText( tostring( deaths ) )
		ui.Window:SetHidden( false == show )
	end

	function EHT.UI.OnDeathCounterAnimate()
		local ui = EHT.UI.SetupDeathCounterDialog()
		local ft = GetFrameTimeMilliseconds()
		local interval = zo_clamp( 1 - ( ( ui.AnimEnd - ft ) / ( ui.AnimEnd - ui.AnimStart ) ), 0, 1 )
		local eased = zo_clamp( math.sin( math.pi * interval ), 0.01, 1 )
		local bd = 0.5 * eased

		if 0.8 > ui.Window:GetAlpha() then
			ui.Window:SetAlpha( zo_clamp( 2.4 * interval, 0, 0.8 ) )
		end
		ui.Caption:SetColor( 1, 1 - eased, 1 - eased, 1 )
		ui.Counter:SetColor( 1, 0, 0, 1 - eased )
		ui.CounterCallout:SetColor( 0, 0, 0, eased )
		ui.CounterCallout2:SetColor( 0.5 + 0.5 * eased, 1, 1, eased )
		ui.Character:SetAlpha( 1 - eased )
		ui.Character:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 1.8 - 1.8 * eased )
		ui.Scythe:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 3 + 6 * eased )
		ui.Scythe:SetTextureCoordsRotation( -0.12 * math.pi * eased )
		ui.Sponsor:SetColor( 1, 1, 1, 0.8 * eased )

		if 1 <= interval then
			EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.OnDeathCounterAnimate" )
		end
	end

	function EHT.UI.IncrementDeathCounter()
		local ui = EHT.UI.SetupDeathCounterDialog()
		local ft = GetFrameTimeMilliseconds()

		deaths = deaths + 1
		ui.Caption:SetText( 1 == deaths and "Death" or "Deaths" )
		ui.Counter:SetText( tostring( deaths ) )
		ui.CounterCallout:SetText( tostring( deaths ) )
		ui.CounterCallout2:SetText( tostring( deaths ) )
		ui.AnimStart = ft
		ui.AnimEnd = ft + 6000

		EVENT_MANAGER:RegisterForUpdate( "EHT.UI.OnDeathCounterAnimate", 20, EHT.UI.OnDeathCounterAnimate )
	end

	function EHT.UI.OnLocalPlayerDeath()
		if EHT.Housing.IsHouseZone() then
			EHT.UI.ShowDeathCounterDialog()
			zo_callLater( EHT.UI.IncrementDeathCounter, 1000 )
		end
	end

	function EHT.UI.GetDeathCounterCharacterTexture( dimension )
		local preloadValue
		if not EHT.Textures then preloadValue = "" end
		dimension = dimension or 140

		if "@jhartellis" == displayNameLower then
			return preloadValue or EHT.Textures.JHART, dimension * 390 / 785, dimension
		elseif "@stabbitydoom" == displayNameLower or "@stabbiteedoom" == displayNameLower then
			return preloadValue or EHT.Textures.STABBITYDOOM, dimension * 320 / 760, dimension
		end
	end

	if EHT.UI.GetDeathCounterCharacterTexture() then
		EVENT_MANAGER:RegisterForEvent( "EHT.UI.OnLocalPlayerDeath", EVENT_PLAYER_DEAD, EHT.UI.OnLocalPlayerDeath )
	end
end

------[[ Dialog : Manage Selections ]]------

function EHT.UI.HideManageSelectionsDialog()
	if nil ~= EHT.UI.ManageSelectionsDialog then
		EHT.UI.ClearDialogHidden( EHT.CONST.DIALOG.MANAGE_SELECTIONS )
		EHT.UI.ManageSelectionsDialog.Window:SetHidden( true )
		EHT.UI.EnableToolDialog()
	end
end

function EHT.UI.SetupManageSelectionsDialog()
	local ui = EHT.UI.ManageSelectionsDialog
	if nil == ui then
		ui = { }
		local windowName = "ManageSelectionsDialog"
		local prefix = "EHTManageSelectionsDialog"

		-- Window Controls

		ui.Window = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
		ui.Window:SetDimensionConstraints( 500, 228, 500, 228 )
		ui.Window:SetMovable( false )
		ui.Window:SetMouseEnabled( true )
		ui.Window:SetClampedToScreen( true )
		ui.Window:SetAlpha( 1 )
		ui.Window:SetResizeHandleSize( 0 )
		ui.Window:SetAnchor( CENTER, GuiRoot, CENTER, 0, 0 )

		ui.Backdrop = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "Backdrop", ui.Window, "ZO_DefaultBackdrop" )
		ui.Backdrop:SetAnchor( TOPLEFT, ui.Window, TOPLEFT, 5, 5 )
		ui.Backdrop:SetAnchor( BOTTOMRIGHT, ui.Window, BOTTOMRIGHT, -5, -5 )
		ui.Backdrop:SetAlpha( 1 )


		-- Load Selection

		ui.LoadSelectionGroup = EHT.CreateControl( prefix .. "LoadSelectionGroup", ui.Window, CT_CONTROL )
		ui.LoadSelectionGroup:SetAnchor( TOPLEFT, ui.Window, TOPLEFT, 15, 25 )
		ui.LoadSelectionGroup:SetAnchor( TOPRIGHT, ui.Window, TOPRIGHT, -15, 25 )
		ui.LoadSelectionGroup:SetHeight( 85 )

		ui.LoadSelectionLabel = EHT.CreateControl( prefix .. "LoadSelectionLabel", ui.LoadSelectionGroup, CT_LABEL )
		ui.LoadSelectionLabel:SetText( "Load an existing Selection" )
		ui.LoadSelectionLabel:SetFont( "ZoFontGameLarge" )
		ui.LoadSelectionLabel:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		ui.LoadSelectionLabel:SetAnchor( TOPLEFT, ui.LoadSelectionGroup, TOPLEFT, 0, 0 )
		ui.LoadSelectionLabel:SetAnchor( TOPRIGHT, ui.LoadSelectionGroup, TOPRIGHT, 0, 0 )
		ui.LoadSelectionLabel:SetHeight( 25 )

		ui.LoadPositionsToggle = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "LoadPositionsToggle", ui.LoadSelectionGroup, "ZO_CheckButton" )
		ui.LoadPositionsToggle:SetAnchor( TOPLEFT, ui.LoadSelectionLabel, BOTTOMLEFT, 0, 5 )
		ZO_CheckButton_SetLabelText( ui.LoadPositionsToggle, "Restore items to their saved positions and orientations" )
		ZO_CheckButton_SetCheckState( ui.LoadPositionsToggle, false )

		ui.LoadSelection = EHT.UI.Picklist:New( prefix .. "LoadSelection", ui.LoadSelectionGroup )
		ui.LoadSelection:SetAnchor( TOPLEFT, ui.LoadSelectionLabel, BOTTOMLEFT, 0, 35 )
		ui.LoadSelection:SetAnchor( TOPRIGHT, ui.LoadSelectionLabel, BOTTOMRIGHT, -160, 35 )
		ui.LoadSelection:SetHeight( 25 )
		ui.LoadSelection:SetSorted( true )

		ui.LoadSelectionButton = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "LoadSelectionButton", ui.LoadSelectionGroup, "ZO_DefaultButton" )
		ui.LoadSelectionButton:SetDimensions( 70, 25 )
		ui.LoadSelectionButton:SetAnchor( LEFT, ui.LoadSelection:GetControl(), RIGHT, 10, 0 )
		ui.LoadSelectionButton:SetFont( "ZoFontWinH5" )
		ui.LoadSelectionButton:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		ui.LoadSelectionButton:SetText( "Load" )
        ui.LoadSelectionButton:SetClickSound( "Click" )
		ui.LoadSelectionButton:SetHandler( "OnClicked", function()
			local groupName = ui.LoadSelection:GetSelectedItem()
			local loadPositions = ZO_CheckButton_IsChecked( ui.LoadPositionsToggle )
			if nil == groupName or "" == groupName then
				EHT.UI.PlaySoundFailure()
			else
				EHT.UI.ShowConfirmationDialog( "Load Selection", EHT.UI.GetLoadGroupConfirmation( groupName, loadPositions or false ), function() EHT.Biz.LoadGroup( groupName, loadPositions or false ) end )
			end
		end )

		ui.RemoveSelectionButton = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "RemoveSelectionButton", ui.LoadSelectionGroup, "ZO_DefaultButton" )
		ui.RemoveSelectionButton:SetDimensions( 70, 25 )
		ui.RemoveSelectionButton:SetAnchor( LEFT, ui.LoadSelectionButton, RIGHT, 10, 0 )
		ui.RemoveSelectionButton:SetFont( "ZoFontWinH5" )
		ui.RemoveSelectionButton:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		ui.RemoveSelectionButton:SetText( "Remove" )
        ui.RemoveSelectionButton:SetClickSound( "Click" )
		ui.RemoveSelectionButton:SetHandler( "OnClicked", function()
			local groupName = ui.LoadSelection:GetSelectedItem()
			if nil == groupName or "" == groupName then
				EHT.UI.PlaySoundFailure()
			else
				EHT.UI.ShowConfirmationDialog( "Remove Selection", string.format( "Delete the Saved Selection \"%s\"?", groupName ), function() EHT.Biz.RemoveGroup( groupName ) end )
			end
		end )


		ui.Divider1 = EHT.CreateControl( prefix .. "Divider1", ui.Window, CT_TEXTURE )
		ui.Divider1:SetHeight( 5 )
		ui.Divider1:SetAnchor( TOPLEFT, ui.LoadSelectionGroup, BOTTOMLEFT, 0, 15 )
		ui.Divider1:SetAnchor( TOPRIGHT, ui.LoadSelectionGroup, BOTTOMRIGHT, 0, 12 )
		ui.Divider1:SetTexture( "EsoUI/Art/Miscellaneous/horizontalDivider.dds" )
		ui.Divider1:SetTextureCoords( 0.181640625, 0.818359375, 0, 1 )


		-- Save Selection

		ui.SaveSelectionGroup = EHT.CreateControl( prefix .. "SaveSelectionGroup", ui.Window, CT_CONTROL )
		ui.SaveSelectionGroup:SetAnchor( TOPLEFT, ui.Divider1, BOTTOMLEFT, 0, 8 )
		ui.SaveSelectionGroup:SetAnchor( TOPRIGHT, ui.Divider1, BOTTOMRIGHT, 0, 8 )
		ui.SaveSelectionGroup:SetHeight( 60 )

		ui.SaveSelectionLabel = EHT.CreateControl( prefix .. "SaveSelectionLabel", ui.SaveSelectionGroup, CT_LABEL )
		ui.SaveSelectionLabel:SetText( "Save Selection" )
		ui.SaveSelectionLabel:SetFont( "ZoFontGameLarge" )
		ui.SaveSelectionLabel:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		ui.SaveSelectionLabel:SetAnchor( TOPLEFT, ui.SaveSelectionGroup, TOPLEFT, 0, 0 )
		ui.SaveSelectionLabel:SetAnchor( TOPRIGHT, ui.SaveSelectionGroup, TOPRIGHT, 0, 0 )
		ui.SaveSelectionLabel:SetHeight( 25 )

		ui.SelectionNameBackdrop = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "SelectionNameBackdrop", ui.SaveSelectionGroup, "ZO_EditBackdrop" )
		ui.SelectionNameBackdrop:SetAnchor( TOPLEFT, ui.SaveSelectionLabel, BOTTOMLEFT, 0, 5 )
		ui.SelectionNameBackdrop:SetAnchor( TOPRIGHT, ui.SaveSelectionLabel, BOTTOMRIGHT, -80, 5 )
		ui.SelectionNameBackdrop:SetHeight( 25 )

		ui.SelectionNameField = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "SelectionNameField", ui.SelectionNameBackdrop, "ZO_DefaultEditForBackdrop" ) 
		ui.SelectionNameField:SetFont( "ZoFontGameSmall" )
		ui.SelectionNameField:SetMaxInputChars( EHT.CONST.GROUP_NAME_MAX_LEN )
		ui.SelectionNameField:SetAnchor( TOPLEFT, ui.SelectionNameBackdrop, TOPLEFT, 4, 0 )
		ui.SelectionNameField:SetAnchor( BOTTOMRIGHT, ui.SelectionNameBackdrop, BOTTOMRIGHT, -4, 0 )

		ui.SaveSelectionButton = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "SaveSelectionButton", ui.SaveSelectionGroup, "ZO_DefaultButton" )
		ui.SaveSelectionButton:SetDimensions( 70, 25 )
		ui.SaveSelectionButton:SetAnchor( LEFT, ui.SelectionNameBackdrop, RIGHT, 10, 0 )
		ui.SaveSelectionButton:SetFont( "ZoFontWinH5" )
		ui.SaveSelectionButton:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		ui.SaveSelectionButton:SetText( "Save" )
        ui.SaveSelectionButton:SetClickSound( "Click" )
		ui.SaveSelectionButton:SetHandler( "OnClicked", function()
			local groupName = ui.SelectionNameField:GetText()
			if nil ~= EHT.Data.GetGroup( groupName ) then
				EHT.UI.ShowConfirmationDialog( "Overwrite Selection", string.format( "Overwrite the Saved Selection \"%s\"?", groupName ), function() EHT.Biz.SaveGroup( groupName ) end )
			else
				EHT.Biz.SaveGroup( groupName )
			end
		end )


		-- Top Window Controls

		ui.CloseButton = EHT.CreateControl( prefix .. "CloseButton", ui.Window, CT_BUTTON )
		ui.CloseButton:SetDimensions( 30, 30 )
		ui.CloseButton:SetAnchor( TOPRIGHT, ui.Window, TOPRIGHT, 0, 12 )
		ui.CloseButton:SetNormalTexture( "EsoUI/Art/Buttons/closebutton_up.dds" )
		ui.CloseButton:SetPressedTexture( "EsoUI/Art/Buttons/closebutton_down.dds" )
		ui.CloseButton:SetMouseOverTexture( "EsoUI/Art/Buttons/closebutton_mouseover.dds" )
		ui.CloseButton:SetDisabledTexture( "EsoUI/Art/Buttons/closebutton_disabled.dds" )
		ui.CloseButton:SetHandler( "OnClicked", function()
			EHT.UI.HideManageSelectionsDialog()
		end )


		EHT.UI.ManageSelectionsDialog = ui
		EHT.UI.RefreshManageSelectionsDialog()

	end

end


function EHT.UI.ShowManageSelectionsDialog()

	if nil == EHT.UI.ManageSelectionsDialog then EHT.UI.SetupManageSelectionsDialog() end
	if not isUIHidden and EHT.UI.ManageSelectionsDialog.Window:IsHidden() then
		EHT.UI.ManageSelectionsDialog.Window:SetHidden( false )
		EHT.UI.EnterUIMode()
	end
	EHT.UI.RefreshManageSelectionsDialog()
	EHT.UI.DisableToolDialog()

end


------[[ Dialog : Manage Builds ]]------


function EHT.UI.RefreshManageBuildsDialog()
	local ui = EHT.UI.ManageBuildsDialog
	if nil == ui then return end

	ui.LoadBuild:ClearItems()
	ui.BuildNameField:SetText( "" )

	local builds = EHT.Data.GetBuilds()

	for index, build in pairs( builds ) do
		ui.LoadBuild:AddItem( build.Name, nil )
	end

	ui.BuildNameField:SetText( EHT.Data.GetBuild().Name or "" )
end

function EHT.UI.HideManageBuildsDialog()
	if nil ~= EHT.UI.ManageBuildsDialog then
		EHT.UI.ClearDialogHidden( EHT.CONST.DIALOG.MANAGE_BUILDS )
		EHT.UI.ManageBuildsDialog.Window:SetHidden( true )
		EHT.UI.EnableToolDialog()
	end
end

function EHT.UI.SetupManageBuildsDialog()
	local ui = EHT.UI.ManageBuildsDialog
	if nil == ui then
		ui = { }

		local windowName = "ManageBuildsDialog"
		local prefix = "EHTManageBuildsDialog"

		-- Window Controls

		ui.Window = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
		ui.Window:SetDimensionConstraints( 500, 200, 500, 200 )
		ui.Window:SetMovable( false )
		ui.Window:SetMouseEnabled( true )
		ui.Window:SetClampedToScreen( true )
		ui.Window:SetAlpha( 1 )
		ui.Window:SetResizeHandleSize( 0 )
		ui.Window:SetAnchor( CENTER, GuiRoot, CENTER, 0, 0 )

		ui.Backdrop = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "Backdrop", ui.Window, "ZO_DefaultBackdrop" )
		ui.Backdrop:SetAnchor( TOPLEFT, ui.Window, TOPLEFT, 5, 5 )
		ui.Backdrop:SetAnchor( BOTTOMRIGHT, ui.Window, BOTTOMRIGHT, -5, -5 )
		ui.Backdrop:SetAlpha( 1 )


		-- Load Build

		ui.LoadBuildGroup = EHT.CreateControl( prefix .. "LoadBuildGroup", ui.Window, CT_CONTROL )
		ui.LoadBuildGroup:SetAnchor( TOPLEFT, ui.Window, TOPLEFT, 15, 25 )
		ui.LoadBuildGroup:SetAnchor( TOPRIGHT, ui.Window, TOPRIGHT, -15, 25 )
		ui.LoadBuildGroup:SetResizeToFitDescendents( true )

		ui.LoadBuildLabel = EHT.CreateControl( prefix .. "LoadBuildLabel", ui.LoadBuildGroup, CT_LABEL )
		ui.LoadBuildLabel:SetText( "Load a saved build" )
		ui.LoadBuildLabel:SetFont( "ZoFontGameLarge" )
		ui.LoadBuildLabel:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		ui.LoadBuildLabel:SetAnchor( TOPLEFT, ui.LoadBuildGroup, TOPLEFT, 0, 0 )
		ui.LoadBuildLabel:SetAnchor( TOPRIGHT, ui.LoadBuildGroup, TOPRIGHT, 0, 0 )
		ui.LoadBuildLabel:SetHeight( 25 )

		ui.LoadBuild = EHT.UI.Picklist:New( prefix .. "LoadBuild", ui.Window )
		ui.LoadBuild:SetAnchor( TOPLEFT, ui.LoadBuildLabel, BOTTOMLEFT, 0, 10 )
		ui.LoadBuild:SetAnchor( TOPRIGHT, ui.LoadBuildLabel, BOTTOMRIGHT, -160, 10 )
		ui.LoadBuild:SetHeight( 25 )
		ui.LoadBuild:SetSorted( true )

		ui.LoadBuildButton = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "LoadBuildButton", ui.LoadBuildGroup, "ZO_DefaultButton" )
		ui.LoadBuildButton:SetDimensions( 70, 25 )
		ui.LoadBuildButton:SetAnchor( LEFT, ui.LoadBuild:GetControl(), RIGHT, 10, 0 )
		ui.LoadBuildButton:SetFont( "ZoFontWinH5" )
		ui.LoadBuildButton:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		ui.LoadBuildButton:SetText( "Load" )
        ui.LoadBuildButton:SetClickSound( "Click" )
		ui.LoadBuildButton:SetHandler( "OnClicked", function()
			local buildName = ui.LoadBuild:GetSelectedItem()
			if nil == buildName or "" == buildName then
				EHT.UI.PlaySoundFailure()
			else
				EHT.UI.ShowConfirmationDialog( "Load Build", "Load the saved build '" .. buildName .. "'?", function() if EHT.Biz.LoadBuild( buildName ) then EHT.UI.HideManageBuildsDialog() EHT.UI.RefreshBuild() end end )
			end
		end )

		ui.RemoveBuildButton = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "RemoveBuildButton", ui.LoadBuildGroup, "ZO_DefaultButton" )
		ui.RemoveBuildButton:SetDimensions( 70, 25 )
		ui.RemoveBuildButton:SetAnchor( LEFT, ui.LoadBuildButton, RIGHT, 10, 0 )
		ui.RemoveBuildButton:SetFont( "ZoFontWinH5" )
		ui.RemoveBuildButton:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		ui.RemoveBuildButton:SetText( "Remove" )
        ui.RemoveBuildButton:SetClickSound( "Click" )
		ui.RemoveBuildButton:SetHandler( "OnClicked", function()
			local buildName = ui.LoadBuild:GetSelectedItem()
			if nil == buildName or "" == buildName then
				EHT.UI.PlaySoundFailure()
			else
				EHT.UI.ShowConfirmationDialog( "Remove Build", "Delete the saved build '" .. buildName .. "'?\n\n|cffaaaaBuilds cannot be undeleted.|r", function() EHT.Biz.RemoveBuild( buildName ) EHT.UI.RefreshManageBuildsDialog() end )
			end
		end )


		local div = EHT.CreateControl( nil, ui.Window, CT_TEXTURE )
		div:SetHeight( 5 )
		div:SetAnchor( TOPLEFT, ui.LoadBuildGroup, BOTTOMLEFT, 0, 15 )
		div:SetAnchor( TOPRIGHT, ui.LoadBuildGroup, BOTTOMRIGHT, 0, 15 )
		div:SetTexture( "EsoUI/Art/Miscellaneous/horizontalDivider.dds" )
		div:SetTextureCoords( 0.181640625, 0.818359375, 0, 1 )


		-- Save Build

		ui.SaveBuildGroup = EHT.CreateControl( prefix .. "SaveBuildGroup", ui.Window, CT_CONTROL )
		ui.SaveBuildGroup:SetAnchor( TOPLEFT, div, BOTTOMLEFT, 0, 8 )
		ui.SaveBuildGroup:SetAnchor( TOPRIGHT, div, BOTTOMRIGHT, 0, 8 )
		ui.SaveBuildGroup:SetHeight( 60 )

		ui.SaveBuildLabel = EHT.CreateControl( prefix .. "SaveBuildLabel", ui.SaveBuildGroup, CT_LABEL )
		ui.SaveBuildLabel:SetText( "Save the current build" )
		ui.SaveBuildLabel:SetFont( "ZoFontGameLarge" )
		ui.SaveBuildLabel:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		ui.SaveBuildLabel:SetAnchor( TOPLEFT, ui.SaveBuildGroup, TOPLEFT, 0, 0 )
		ui.SaveBuildLabel:SetAnchor( TOPRIGHT, ui.SaveBuildGroup, TOPRIGHT, 0, 0 )
		ui.SaveBuildLabel:SetHeight( 25 )

		ui.BuildNameBackdrop = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "BuildNameBackdrop", ui.SaveBuildGroup, "ZO_EditBackdrop" )
		ui.BuildNameBackdrop:SetAnchor( TOPLEFT, ui.SaveBuildLabel, BOTTOMLEFT, 0, 5 )
		ui.BuildNameBackdrop:SetAnchor( TOPRIGHT, ui.SaveBuildLabel, BOTTOMRIGHT, -80, 5 )
		ui.BuildNameBackdrop:SetHeight( 25 )

		ui.BuildNameField = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "BuildNameField", ui.BuildNameBackdrop, "ZO_DefaultEditForBackdrop" ) 
		ui.BuildNameField:SetFont( "ZoFontGameSmall" )
		ui.BuildNameField:SetMaxInputChars( EHT.CONST.GROUP_NAME_MAX_LEN )
		ui.BuildNameField:SetAnchor( TOPLEFT, ui.BuildNameBackdrop, TOPLEFT, 4, 0 )
		ui.BuildNameField:SetAnchor( BOTTOMRIGHT, ui.BuildNameBackdrop, BOTTOMRIGHT, -4, 0 )

		ui.SaveBuildButton = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "SaveBuildButton", ui.SaveBuildGroup, "ZO_DefaultButton" )
		ui.SaveBuildButton:SetDimensions( 70, 25 )
		ui.SaveBuildButton:SetAnchor( LEFT, ui.BuildNameBackdrop, RIGHT, 10, 0 )
		ui.SaveBuildButton:SetFont( "ZoFontWinH5" )
		ui.SaveBuildButton:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		ui.SaveBuildButton:SetText( "Save" )
        ui.SaveBuildButton:SetClickSound( "Click" )
		ui.SaveBuildButton:SetHandler( "OnClicked", function()
			local buildName = ui.BuildNameField:GetText()
			if nil ~= EHT.Data.GetBuild( buildName ) then
				EHT.UI.ShowConfirmationDialog( "Overwrite Build", "Overwrite the saved build '" .. buildName .. "'?", function() if EHT.Biz.SaveBuild( buildName ) then EHT.UI.HideManageBuildsDialog() end end )
			else
				if EHT.Biz.SaveBuild( buildName ) then EHT.UI.HideManageBuildsDialog() end
			end
		end )


		-- Top Window Controls

		ui.CloseButton = EHT.CreateControl( prefix .. "CloseButton", ui.Window, CT_BUTTON )
		ui.CloseButton:SetDimensions( 30, 30 )
		ui.CloseButton:SetAnchor( TOPRIGHT, ui.Window, TOPRIGHT, 0, 12 )
		ui.CloseButton:SetNormalTexture( "EsoUI/Art/Buttons/closebutton_up.dds" )
		ui.CloseButton:SetPressedTexture( "EsoUI/Art/Buttons/closebutton_down.dds" )
		ui.CloseButton:SetMouseOverTexture( "EsoUI/Art/Buttons/closebutton_mouseover.dds" )
		ui.CloseButton:SetDisabledTexture( "EsoUI/Art/Buttons/closebutton_disabled.dds" )
		ui.CloseButton:SetHandler( "OnClicked", function()
			EHT.UI.HideManageBuildsDialog()
			EHT.UI.EnableToolDialog()
		end )


		EHT.UI.ManageBuildsDialog = ui
		EHT.UI.RefreshManageBuildsDialog()

	end

end


function EHT.UI.ShowManageBuildsDialog()
	if nil == EHT.UI.ManageBuildsDialog then EHT.UI.SetupManageBuildsDialog() end
	if not isUIHidden and EHT.UI.ManageBuildsDialog.Window:IsHidden() then
		EHT.UI.ManageBuildsDialog.Window:SetHidden( false )
		EHT.UI.EnterUIMode()
	end

	EHT.UI.RefreshManageBuildsDialog()
	EHT.UI.DisableToolDialog()
end

------[[ Dialog : Clipboard ]]------

function EHT.UI.HideClipboardDialog()
	if nil ~= EHT.UI.ClipboardDialog then
		EHT.UI.ClearDialogHidden( EHT.CONST.DIALOG.CLIPBOARD )
		EHT.UI.ClipboardDialog.Window:SetHidden( true )
	end
end

function EHT.UI.SetupClipboardDialog()
	local ui = EHT.UI.ClipboardDialog
	if nil == ui then
		ui = { }

		local windowName = "ClipboardDialog"
		local prefix = "EHTClipboardDialog"
		local ctl

		-- Window Controls

		ui.Window = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
		ui.Window:SetDimensionConstraints( 680, 350, 1000, 1000 )
		ui.Window:SetMovable( true )
		ui.Window:SetMouseEnabled( true )
		ui.Window:SetClampedToScreen( true )
		ui.Window:SetAlpha( 1 )
		ui.Window:SetResizeHandleSize( 5 )
		ui.Window:SetDrawLevel( EHT.Effects.MAX_EDITOR_DRAW_LEVEL + 100 )

		local settings = EHT.UI.GetDialogSettings( windowName )

		if settings.Left and settings.Top then
			ui.Window:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, settings.Left, settings.Top )
		else
			ui.Window:SetAnchor( CENTER, GuiRoot, CENTER, 0, 0 )
		end

		if settings.Width and settings.Height then
			ui.Window:SetDimensions( settings.Width, settings.Height )
		else
			ui.Window:SetDimensions( 680, 350 )
		end

		ui.Window:SetHandler( "OnMoveStop", function() EHT.UI.SaveDialogSettings( windowName, ui.Window ) end )
		ui.Window:SetHandler( "OnResizeStop", function() EHT.UI.SaveDialogSettings( windowName, ui.Window ) end )

		ui.Backdrop = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "Backdrop", ui.Window, "ZO_DefaultBackdrop" )
		ui.Backdrop:SetAnchor( TOPLEFT, ui.Window, TOPLEFT, 5, 5 )
		ui.Backdrop:SetAnchor( BOTTOMRIGHT, ui.Window, BOTTOMRIGHT, -5, -5 )
		ui.Backdrop:SetAlpha( 1 )

		ctl = EHT.CreateControl( prefix .. "ClipboardLabel", ui.Window, CT_LABEL )
		ui.ClipboardLabel = ctl
		ctl:SetText( "Clipboard" )
		ctl:SetFont( "ZoFontGameLarge" )
		ctl:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		ctl:SetAnchor( TOP, ui.Window, TOP, 0, 12 )


		-- Clipboard Export Group

		ui.ClipboardGroup = EHT.CreateControl( prefix .. "ClipboardGroup", ui.Window, CT_CONTROL )
		ui.ClipboardGroup:SetAnchor( TOPLEFT, ui.Window, TOPLEFT, 10, 36 )
		ui.ClipboardGroup:SetAnchor( BOTTOMRIGHT, ui.Window, BOTTOMRIGHT, -10, -15 )

		EHT.UI.SetupToolDialogClipboardTab( ui, ui.ClipboardGroup, prefix )


		-- Top Window Controls

		ui.CloseButton = EHT.CreateControl( prefix .. "CloseButton", ui.Window, CT_BUTTON )
		ui.CloseButton:SetDimensions( 30, 30 )
		ui.CloseButton:SetAnchor( TOPRIGHT, ui.Window, TOPRIGHT, 0, 12 )
		ui.CloseButton:SetNormalTexture( "EsoUI/Art/Buttons/closebutton_up.dds" )
		ui.CloseButton:SetPressedTexture( "EsoUI/Art/Buttons/closebutton_down.dds" )
		ui.CloseButton:SetMouseOverTexture( "EsoUI/Art/Buttons/closebutton_mouseover.dds" )
		ui.CloseButton:SetDisabledTexture( "EsoUI/Art/Buttons/closebutton_disabled.dds" )
		ui.CloseButton:SetHandler( "OnClicked", function() EHT.UI.HideClipboardDialog() end )


		EHT.UI.ClipboardDialog = ui
		EHT.UI.QueueRefreshClipboard()

	end

end


function EHT.UI.ShowClipboardDialog()

	if nil == EHT.UI.ClipboardDialog then EHT.UI.SetupClipboardDialog() end
	if not isUIHidden and EHT.UI.ClipboardDialog.Window:IsHidden() then
		EHT.UI.ClipboardDialog.Window:SetHidden( false )
		EHT.UI.EnterUIMode()
	end
	EHT.UI.QueueRefreshClipboard()

end


------[[ Dialog : Import Clipboard ]]------

function EHT.UI.ClearImportClipboardText()
	local ui = EHT.UI.ImportClipboardDialog
	if ui then
		ui.Clipboard:SetText( "" )
	end
end

function EHT.UI.SetImportClipboardMessage( message )
	local ui = EHT.UI.ImportClipboardDialog
	if ui then
		ui.Message:SetText( message )
	end
end

function EHT.UI.ResetImportClipboardDialog()
	local ui = EHT.UI.ImportClipboardDialog
	if ui then
		EHT.UI.ClearImportClipboardText()
		EHT.UI.SetImportClipboardMessage( "" )
		ui.ClipboardParts = { }
	end
end

function EHT.UI.HideImportClipboardDialog()
	local ui = EHT.UI.SetupImportClipboardDialog()
	EHT.UI.ClearDialogHidden( EHT.CONST.DIALOG.IMPORT_CLIPBOARD )
	ui.Window:SetHidden( true )
	EHT.UI.EnableToolDialog()
end

function EHT.UI.ShowImportClipboardDialog()
	local ui = EHT.UI.SetupImportClipboardDialog()
	if not isUIHidden then
		EHT.UI.ResetImportClipboardDialog()
		EHT.UI.ImportClipboardDialog.Window:SetHidden( false )
		EHT.UI.EnterUIMode()
		EHT.UI.DisableToolDialog()
	end
end

function EHT.UI.ProcessClipboardImport()
	local ui = EHT.UI.ImportClipboardDialog
	if nil == ui then
		return
	end

	local clipboardText = ui.Clipboard:GetText()
	if not clipboardText or #clipboardText < 5 then
		return
	end

	table.insert( ui.ClipboardParts, clipboardText )
	EHT.UI.ClearImportClipboardText()

	if #clipboardText > EHT.CONST.MAX_CLIPBOARD_LENGTH then
		local nextPart = #ui.ClipboardParts + 1
		local PREFIXES = { "Excellent.", "Great.", "Nice.", }
		local prefix = PREFIXES[ 1 + ( nextPart % 3 ) ]
		EHT.UI.SetImportClipboardMessage( string.format( "%s Now paste part %d of the clipboard above.", prefix, nextPart ) )
	else
		local clipboardParts = ui.ClipboardParts
		local success, message = EHT.Biz.ImportClipboard( clipboardParts )
		EHT.UI.ResetImportClipboardDialog()

		if success then
			EHT.UI.ShowAlertDialog( "Clipboard Imported", "Clipboard imported successfully.", nil )
			EHT.UI.HideImportClipboardDialog()
		else
			EHT.UI.ShowErrorDialog( "Clipboard Import Failed", string.format( "Clipboard import failed:\n\n%s", message or "Unspecified exception." ), nil )
		end
	end
end

function EHT.UI.SetupImportClipboardDialog()
	local ui = EHT.UI.ImportClipboardDialog
	if nil == ui then
		ui = { }

		local windowName = "ImportClipboardDialog"
		local prefix = "EHTImportClipboardDialog"

		-- Window Controls

		ui.Window = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
		ui.Window:SetDimensionConstraints( 600, 300, 600, 300 )
		ui.Window:SetMovable( true )
		ui.Window:SetMouseEnabled( true )
		ui.Window:SetClampedToScreen( true )
		ui.Window:SetAlpha( 1 )
		ui.Window:SetResizeHandleSize( 0 )
		ui.Window:SetAnchor( CENTER, GuiRoot, CENTER, 0, 0 )
		ui.Window:SetDrawLevel( EHT.Effects.MAX_EDITOR_DRAW_LEVEL + 200 )
		ui.Window:SetHidden( true )

		ui.Backdrop = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "Backdrop", ui.Window, "ZO_DefaultBackdrop" )
		ui.Backdrop:SetAnchor( TOPLEFT, ui.Window, TOPLEFT, 5, 5 )
		ui.Backdrop:SetAnchor( BOTTOMRIGHT, ui.Window, BOTTOMRIGHT, -5, -5 )
		ui.Backdrop:SetMouseEnabled( false )
		ui.Backdrop:SetAlpha( 1 )

		ui.Content = EHT.CreateControl( prefix .. "Content", ui.Window, CT_CONTROL )
		ui.Content:SetAnchor( TOPLEFT, nil, nil, 15, 15 )
		ui.Content:SetAnchor( BOTTOMRIGHT, nil, nil, -15, -15 )
		ui.Content:SetMouseEnabled( false )

		ui.Caption = EHT.CreateControl( prefix .. "Caption", ui.Content, CT_LABEL )
		ui.Caption:SetText( "Clipboard Import" )
		ui.Caption:SetFont( "ZoFontGameLarge" )
		ui.Caption:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		ui.Caption:SetAnchor( TOPLEFT, ui.Content, TOPLEFT, 0, 0 )
		ui.Caption:SetAnchor( TOPRIGHT, ui.Content, TOPRIGHT, 0, 0 )
		ui.Caption:SetMouseEnabled( false )

		ui.Instructions = EHT.CreateControl( prefix .. "Instructions", ui.Content, CT_LABEL )
		ui.Instructions:SetFont( "ZoFontGameSmall" )
		ui.Instructions:SetAnchor( TOPLEFT, ui.Caption, BOTTOMLEFT, 0, 5 )
		ui.Instructions:SetAnchor( TOPRIGHT, ui.Caption, BOTTOMRIGHT, 0, 5 )
		ui.Instructions:SetText( "Click below and press CTRL+V or CMD+V to paste an exported clipboard" )

		ui.ClipboardBackdrop = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "ClipboardBackdrop", ui.Content, "ZO_EditBackdrop" )
		ui.ClipboardBackdrop:SetAnchor( TOPLEFT, ui.Instructions, BOTTOMLEFT, 0, 5 )
		ui.ClipboardBackdrop:SetAnchor( TOPRIGHT, ui.Instructions, BOTTOMRIGHT, 0, 5 )
		ui.ClipboardBackdrop:SetHeight( 140 )

		ui.Clipboard = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "Clipboard", ui.ClipboardBackdrop, "ZO_DefaultEditMultiLineForBackdrop" ) 
		ui.Clipboard:SetCopyEnabled( true )
		ui.Clipboard:SetEditEnabled( true )
		ui.Clipboard:SetFont( "ZoFontGameSmall" )
		ui.Clipboard:SetMaxInputChars( 1024000 )
		ui.Clipboard:SetMouseEnabled( true )
		ui.Clipboard:SetMultiLine( true )
		ui.Clipboard:SetNewLineEnabled( true )
		ui.Clipboard:SetAnchor( TOPLEFT, ui.ClipboardBackdrop, TOPLEFT, 8, 8 )
		ui.Clipboard:SetAnchor( BOTTOMRIGHT, ui.ClipboardBackdrop, BOTTOMRIGHT, -8, -8 )
		ui.Clipboard:SetHandler( "OnTextChanged", EHT.UI.ProcessClipboardImport )

		ui.Message = EHT.CreateControl( prefix .. "Message", ui.Content, CT_LABEL )
		ui.Message:SetFont( "ZoFontGameLarge" )
		ui.Message:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		ui.Message:SetAnchor( TOPLEFT, ui.ClipboardBackdrop, BOTTOMLEFT, 0, 5 )
		ui.Message:SetAnchor( TOPRIGHT, ui.ClipboardBackdrop, BOTTOMRIGHT, 0, 5 )
		ui.Message:SetColor( 1, 0.8, 0, 1 )

		ui.Close = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "Close", ui.Content, "ZO_DefaultButton" )
		ui.Close:SetAnchor( BOTTOM, ui.Content )
		ui.Close:SetFont( "ZoFontWinH5" )
		ui.Close:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		ui.Close:SetText( "Cancel" )
        ui.Close:SetClickSound( "Click" )
		ui.Close:SetHandler( "OnClicked", function()
			EHT.UI.HideImportClipboardDialog()
		end )

		-- Order matters:
		EHT.UI.ImportClipboardDialog = ui
		EHT.UI.ResetImportClipboardDialog()
	end
	
	return ui
end

------[[ Dialog : Export Clipboard ]]------

function EHT.UI.ClearExportClipboardText()
	local ui = EHT.UI.ExportClipboardDialog
	if ui then
		ui.Clipboard:SetText( "" )
	end
end

function EHT.UI.SetExportClipboardMessage( message )
	local ui = EHT.UI.ExportClipboardDialog
	if ui then
		ui.Message:SetText( message )
	end
end

function EHT.UI.ResetExportClipboardDialog()
	local ui = EHT.UI.ExportClipboardDialog
	if ui then
		EHT.UI.ClearExportClipboardText()
		EHT.UI.SetExportClipboardMessage( "" )
		ui.NextOrClose:SetText( "Close" )
		ui.ClipboardParts = { }
		ui.CurrentPartIndex = 0
	end
end

function EHT.UI.HideExportClipboardDialog()
	local ui = EHT.UI.SetupExportClipboardDialog()
	EHT.UI.ClearDialogHidden( EHT.CONST.DIALOG.EXPORT_CLIPBOARD )
	ui.Window:SetHidden( true )
	EHT.UI.EnableToolDialog()
end

function EHT.UI.ShowExportClipboardDialog()
	local ui = EHT.UI.SetupExportClipboardDialog()
	if not isUIHidden then
		EHT.UI.ResetExportClipboardDialog()
		EHT.UI.ProcessClipboardExport()
		EHT.UI.ExportClipboardDialog.Window:SetHidden( false )
		EHT.UI.EnterUIMode()
		EHT.UI.DisableToolDialog()
	end
end

function EHT.UI.ProcessClipboardExport()
	local ui = EHT.UI.ExportClipboardDialog
	if nil == ui then
		return
	end
	
	ui.NextOrClose.isClose = true
	ui.NextOrClose:SetText( "Close" )

	if #ui.ClipboardParts == 0 then
		local clipboardItems = EHT.SavedVars.Clipboard
		if "table" ~= type( clipboardItems ) or 0 == #clipboardItems then
			EHT.UI.SetExportClipboardMessage( "There is nothing to export - your clipboard is currently empty" )
			return
		else
			local clipboardData = EHT.Biz.SerializeClipboard()
			if "table" ~= type( clipboardData ) then
				EHT.UI.SetExportClipboardMessage( "Failed to export your clipboard - Unknown error" )
				return
			else
				if 0 == #clipboardData then
					EHT.UI.SetExportClipboardMessage( "There is nothing to export - your clipboard is currently empty" )
					return
				end

				local success, response = EHT.Biz.DeserializeClipboard( clipboardData )
				if not success or "table" ~= type( response ) then
					EHT.UI.SetExportClipboardMessage( "Clipboard export data was corrupt - please notify @Architectura and @Cardinal05" )
					return
				end

				ui.ClipboardParts = clipboardData
			end
		end
	end

	ui.CurrentPartIndex = ui.CurrentPartIndex + 1
	local clipboardPart = ui.ClipboardParts[ ui.CurrentPartIndex ]

	if clipboardPart then
		ui.Clipboard:SetText( clipboardPart )
		--ui.Clipboard:SelectAll()
		--ui.Clipboard:TakeFocus()
	else
		ui.Clipboard:SetText( "" )
	end

	if ui.CurrentPartIndex >= #ui.ClipboardParts then
		if ui.CurrentPartIndex == 1 then
			EHT.UI.SetExportClipboardMessage( "Copy your Clipboard Export from above" )
		else
			EHT.UI.SetExportClipboardMessage( "Copy the final part of your Clipboard Export from above" )
		end
	else
		local currentPart, numParts = ui.CurrentPartIndex, #ui.ClipboardParts
		EHT.UI.SetExportClipboardMessage( string.format( "Copy part %d of %d of your Clipboard Export from above", currentPart, numParts ) )
		ui.NextOrClose.isClose = false
		ui.NextOrClose:SetText( string.format( "Show part %d of %d", currentPart + 1, numParts ) )
	end
end

function EHT.UI.SetupExportClipboardDialog()
	local ui = EHT.UI.ExportClipboardDialog
	if nil == ui then
		ui = { }

		local windowName = "ExportClipboardDialog"
		local prefix = "EHTExportClipboardDialog"

		-- Window Controls

		ui.Window = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
		ui.Window:SetDimensionConstraints( 600, 300, 600, 300 )
		ui.Window:SetMovable( true )
		ui.Window:SetMouseEnabled( true )
		ui.Window:SetClampedToScreen( true )
		ui.Window:SetAlpha( 1 )
		ui.Window:SetResizeHandleSize( 0 )
		ui.Window:SetAnchor( CENTER, GuiRoot, CENTER, 0, 0 )
		ui.Window:SetDrawLevel( EHT.Effects.MAX_EDITOR_DRAW_LEVEL + 200 )
		ui.Window:SetHidden( true )

		ui.Backdrop = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "Backdrop", ui.Window, "ZO_DefaultBackdrop" )
		ui.Backdrop:SetAnchor( TOPLEFT, ui.Window, TOPLEFT, 5, 5 )
		ui.Backdrop:SetAnchor( BOTTOMRIGHT, ui.Window, BOTTOMRIGHT, -5, -5 )
		ui.Backdrop:SetMouseEnabled( false )
		ui.Backdrop:SetAlpha( 1 )

		ui.Content = EHT.CreateControl( prefix .. "Content", ui.Window, CT_CONTROL )
		ui.Content:SetAnchor( TOPLEFT, nil, nil, 15, 15 )
		ui.Content:SetAnchor( BOTTOMRIGHT, nil, nil, -15, -15 )
		ui.Content:SetMouseEnabled( false )

		ui.Caption = EHT.CreateControl( prefix .. "Caption", ui.Content, CT_LABEL )
		ui.Caption:SetText( "Clipboard Export" )
		ui.Caption:SetFont( "ZoFontGameLarge" )
		ui.Caption:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		ui.Caption:SetAnchor( TOPLEFT, ui.Content, TOPLEFT, 0, 0 )
		ui.Caption:SetAnchor( TOPRIGHT, ui.Content, TOPRIGHT, 0, 0 )
		ui.Caption:SetMouseEnabled( false )

		ui.Instructions = EHT.CreateControl( prefix .. "Instructions", ui.Content, CT_LABEL )
		ui.Instructions:SetFont( "ZoFontGameSmall" )
		ui.Instructions:SetAnchor( TOPLEFT, ui.Caption, BOTTOMLEFT, 0, 5 )
		ui.Instructions:SetAnchor( TOPRIGHT, ui.Caption, BOTTOMRIGHT, 0, 5 )
		ui.Instructions:SetText( "To copy highlight ALL of the text below and press CTRL+C or CMD+C" )

		ui.ClipboardBackdrop = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "ClipboardBackdrop", ui.Content, "ZO_EditBackdrop" )
		ui.ClipboardBackdrop:SetAnchor( TOPLEFT, ui.Instructions, BOTTOMLEFT, 0, 5 )
		ui.ClipboardBackdrop:SetAnchor( TOPRIGHT, ui.Instructions, BOTTOMRIGHT, 0, 5 )
		ui.ClipboardBackdrop:SetHeight( 140 )

		ui.Clipboard = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "Clipboard", ui.ClipboardBackdrop, "ZO_DefaultEditMultiLineForBackdrop" ) 
		ui.Clipboard:SetCopyEnabled( true )
		ui.Clipboard:SetEditEnabled( false )
		ui.Clipboard:SetFont( "ZoFontGameSmall" )
		ui.Clipboard:SetMaxInputChars( 1024000 )
		ui.Clipboard:SetMouseEnabled( true )
		ui.Clipboard:SetMultiLine( true )
		ui.Clipboard:SetNewLineEnabled( true )
		ui.Clipboard:SetAnchor( TOPLEFT, ui.ClipboardBackdrop, TOPLEFT, 8, 8 )
		ui.Clipboard:SetAnchor( BOTTOMRIGHT, ui.ClipboardBackdrop, BOTTOMRIGHT, -8, -8 )

		ui.Message = EHT.CreateControl( prefix .. "Message", ui.Content, CT_LABEL )
		ui.Message:SetFont( "ZoFontGameLarge" )
		ui.Message:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		ui.Message:SetAnchor( TOPLEFT, ui.ClipboardBackdrop, BOTTOMLEFT, 0, 5 )
		ui.Message:SetAnchor( TOPRIGHT, ui.ClipboardBackdrop, BOTTOMRIGHT, 0, 5 )
		ui.Message:SetColor( 1, 0.8, 0, 1 )

		ui.NextOrClose = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "NextOrClose", ui.Content, "ZO_DefaultButton" )
		ui.NextOrClose:SetAnchor( BOTTOM, ui.Content )
		ui.NextOrClose:SetFont( "ZoFontWinH5" )
		ui.NextOrClose:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		ui.NextOrClose:SetText( "Cancel" )
        ui.NextOrClose:SetClickSound( "Click" )
		ui.NextOrClose.isClose = true
		ui.NextOrClose:SetHandler( "OnClicked", function()
			if ui.NextOrClose.isClose then
				EHT.UI.HideExportClipboardDialog()
			else
				EHT.UI.ProcessClipboardExport()
			end
		end )

		-- Order matters:
		EHT.UI.ExportClipboardDialog = ui
		EHT.UI.ResetExportClipboardDialog()
	end
	
	return ui
end

------[[ Dialog : Copy From Selections ]]------

function EHT.UI.CopyFromHouseSelected( houseId )

	local ui = EHT.UI.CopyFromSelectionsDialog
	if nil == ui then return end

	local selectionList = ui.SelectionList
	selectionList:ClearItems()

	if nil == houseId or "table" == type( houseId ) then
		local houseBox = ui.HouseBox
		houseId = houseBox:GetSelectedItemValue()
		if nil == houseId then return end
	end

	local houseSelections = EHT.Data.GetGroups( houseId )

	for groupName, group in pairs( houseSelections ) do
		if groupName ~= EHT.CONST.GROUP_DEFAULT then
			selectionList:AddItem( groupName, nil, houseId )
		end
	end

end


function EHT.UI.RefreshCopyFromSelectionsDialog()

	local ui = EHT.UI.CopyFromSelectionsDialog
	if nil == ui then return end

	local houseBox = ui.HouseBox
	houseBox:ClearItems()

	for houseId, house in pairs( EHT.Data.GetHouses() ) do
		-- Only list homes that the player owns.
		if tonumber( houseId ) then
			houseBox:AddItem( house.Name, EHT.UI.CopyFromHouseSelected, houseId )
		end
	end

	local currentHouse = EHT.Data.GetCurrentHouse()
	if nil ~= currentHouse then
		houseBox:SetSelectedItem( currentHouse.Name )
		EHT.UI.CopyFromHouseSelected( currentHouse.HouseId )
	end
end

function EHT.UI.HideCopyFromSelectionsDialog()
	local ui = EHT.UI.CopyFromSelectionsDialog
	if nil ~= ui then
		EHT.UI.ClearDialogHidden( EHT.CONST.DIALOG.COPY_FROM_SELECTION )
		ui.Window:SetHidden( true )
		EHT.UI.EnableToolDialog()
	end
end

function EHT.UI.SetupCopyFromSelectionsDialog()
	local ui = EHT.UI.CopyFromSelectionsDialog
	if nil == ui then

		ui = { }

		local windowName = "CopyFromSelectionsDialog"
		local prefix = "EHTCopyFromSelectionsDialog"
		local dl = EHT.Effects.MAX_EDITOR_DRAW_LEVEL + 200

		-- Window Controls

		ui.Window = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
		ui.Window:SetDimensionConstraints( 400, 200, 400, 200 )
		ui.Window:SetMovable( false )
		ui.Window:SetMouseEnabled( true )
		ui.Window:SetClampedToScreen( true )
		ui.Window:SetAlpha( 1 )
		ui.Window:SetResizeHandleSize( 0 )
		ui.Window:SetAnchor( CENTER, GuiRoot, CENTER, 0, 0 )
		ui.Window:SetDrawLevel( dl )

		ui.Backdrop = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "Backdrop", ui.Window, "ZO_DefaultBackdrop" )
		ui.Backdrop:SetAnchor( TOPLEFT, ui.Window, TOPLEFT, 5, 5 )
		ui.Backdrop:SetAnchor( BOTTOMRIGHT, ui.Window, BOTTOMRIGHT, -5, -5 )
		ui.Backdrop:SetAlpha( 1 )


		-- Selections

		ui.SelectionGroup = EHT.CreateControl( prefix .. "SelectionGroup", ui.Window, CT_CONTROL )
		ui.SelectionGroup:SetAnchor( TOPLEFT, ui.Window, TOPLEFT, 15, 25 )
		ui.SelectionGroup:SetAnchor( TOPRIGHT, ui.Window, TOPRIGHT, -15, 25 )
		ui.SelectionGroup:SetResizeToFitDescendents( true )

		ui.HouseLabel = EHT.CreateControl( prefix .. "HouseLabel", ui.SelectionGroup, CT_LABEL )
		ui.HouseLabel:SetText( "House" )
		ui.HouseLabel:SetFont( "ZoFontGameLarge" )
		ui.HouseLabel:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		ui.HouseLabel:SetAnchor( TOPLEFT, ui.SelectionGroup, TOPLEFT, 0, 0 )
		ui.HouseLabel:SetHeight( 25 )

		ui.HouseBox = EHT.UI.Picklist:New( prefix .. "HouseBox", ui.SelectionGroup, TOPLEFT, ui.HouseLabel, BOTTOMLEFT, 0, 0, 370, 25 )
		ui.HouseBox:SetSorted( true )

		ui.SelectionLabel = EHT.CreateControl( prefix .. "SelectionLabel", ui.SelectionGroup, CT_LABEL )
		ui.SelectionLabel:SetText( "Selection" )
		ui.SelectionLabel:SetFont( "ZoFontGameLarge" )
		ui.SelectionLabel:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		ui.SelectionLabel:SetAnchor( TOPLEFT, ui.HouseBox:GetControl(), BOTTOMLEFT, 0, 10 )
		ui.SelectionLabel:SetHeight( 25 )

		ui.SelectionList = EHT.UI.Picklist:New( prefix .. "Selection", ui.SelectionGroup, TOPLEFT, ui.SelectionLabel, BOTTOMLEFT, 0, 0, 370, 25 )
		ui.SelectionList:SetSorted( true )

		ui.CopyFromButton = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "CopyFromButton", ui.SelectionGroup, "ZO_DefaultButton" )
		ui.CopyFromButton:SetDimensions( 150, 25 )
		ui.CopyFromButton:SetAnchor( TOP, ui.SelectionList:GetControl(), BOTTOM, 0, 10 )
		ui.CopyFromButton:SetFont( "ZoFontWinH5" )
		ui.CopyFromButton:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		ui.CopyFromButton:SetText( "Copy Selection" )
        ui.CopyFromButton:SetClickSound( "Click" )
		ui.CopyFromButton:SetHandler( "OnClicked", function()
			local groupName = ui.SelectionList:GetSelectedItem()
			local houseId = ui.SelectionList:GetSelectedItemValue()

			if nil == groupName or "" == groupName or nil == houseId then
				EHT.UI.ShowErrorDialog( "Choose a Selection", "Choose a Saved Selection to Copy From.", nil )
				return
			end

			local group = EHT.Data.GetGroup( groupName, houseId )

			if nil ~= group then
				EHT.Biz.CopyGroupToClipboard( group, false )
				EHT.UI.ShowClipboardDialog()
				EHT.UI.HideCopyFromSelectionsDialog()
			end
		end )


		-- Top Window Controls

		ui.CloseButton = EHT.CreateControl( prefix .. "CloseButton", ui.Window, CT_BUTTON )
		ui.CloseButton:SetDimensions( 30, 30 )
		ui.CloseButton:SetAnchor( TOPRIGHT, ui.Window, TOPRIGHT, 0, 12 )
		ui.CloseButton:SetNormalTexture( "EsoUI/Art/Buttons/closebutton_up.dds" )
		ui.CloseButton:SetPressedTexture( "EsoUI/Art/Buttons/closebutton_down.dds" )
		ui.CloseButton:SetMouseOverTexture( "EsoUI/Art/Buttons/closebutton_mouseover.dds" )
		ui.CloseButton:SetDisabledTexture( "EsoUI/Art/Buttons/closebutton_disabled.dds" )
		ui.CloseButton:SetHandler( "OnClicked", function()
			EHT.UI.HideCopyFromSelectionsDialog()
			EHT.UI.EnableToolDialog()
		end )


		EHT.UI.CopyFromSelectionsDialog = ui

	end
	
	return ui

end


function EHT.UI.ShowCopyFromSelectionsDialog()

	local ui = EHT.UI.CopyFromSelectionsDialog
	if nil == ui then ui = EHT.UI.SetupCopyFromSelectionsDialog() end
	EHT.UI.RefreshCopyFromSelectionsDialog()
	EHT.UI.DisableToolDialog()
	if not isUIHidden and ui.Window:IsHidden() then
		ui.Window:SetHidden( false )
		EHT.UI.EnterUIMode()
	end

end

------[[ Dialog : Add Selection ]]------

function EHT.UI.SetupAddSelectionDialog()
	local ui = EHT.UI.AddSelectionDialog
	if nil == ui then
		ui = { }
		EHT.UI.AddSelectionDialog = ui

		local windowName = "AddSelectionDialog"
		local prefix = "EHTAddSelectionDialog"
		local dl = EHT.Effects.MAX_EDITOR_DRAW_LEVEL + 200

		-- Window Controls

		ui.Window = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
		ui.Window:SetHidden( true )
		ui.Window:SetDimensionConstraints( 400, 150, 400, 150 )
		ui.Window:SetMovable( true )
		ui.Window:SetMouseEnabled( true )
		ui.Window:SetClampedToScreen( true )
		ui.Window:SetAlpha( 1 )
		ui.Window:SetResizeHandleSize( 0 )
		ui.Window:SetAnchor( CENTER, GuiRoot, CENTER, 0, 0 )
		ui.Window:SetDrawLevel( dl )

		ui.Backdrop = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "Backdrop", ui.Window, "ZO_DefaultBackdrop" )
		ui.Backdrop:SetAnchor( TOPLEFT, ui.Window, TOPLEFT, 5, 5 )
		ui.Backdrop:SetAnchor( BOTTOMRIGHT, ui.Window, BOTTOMRIGHT, -5, -5 )
		ui.Backdrop:SetAlpha( 1 )

		-- Selections

		ui.SelectionGroup = EHT.CreateControl( nil, ui.Window, CT_CONTROL )
		ui.SelectionGroup:SetAnchor( TOPLEFT, ui.Window, TOPLEFT, 20, 20 )
		ui.SelectionGroup:SetAnchor( TOPRIGHT, ui.Window, TOPRIGHT, -20, 20 )
		ui.SelectionGroup:SetResizeToFitDescendents( true )

		ui.SelectionLabel = EHT.CreateControl( prefix .. "SelectionLabel", ui.SelectionGroup, CT_LABEL )
		ui.SelectionLabel:SetText( "Add Items From Saved Selection" )
		ui.SelectionLabel:SetFont( "ZoFontGameLarge" )
		ui.SelectionLabel:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		ui.SelectionLabel:SetAnchor( TOPLEFT, ui.SelectionGroup, TOPLEFT, 0, 0 )
		ui.SelectionLabel:SetHeight( 25 )

		ui.SelectionList = EHT.UI.Picklist:New( prefix .. "Selection", ui.SelectionGroup, TOPLEFT, ui.SelectionLabel, BOTTOMLEFT, 0, 0, 360, 25 )
		ui.SelectionList:SetSorted( true )

		ui.ConfirmButton = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "ConfirmButton", ui.SelectionGroup, "ZO_DefaultButton" )
		ui.ConfirmButton:SetDimensions( 130, 30 )
		ui.ConfirmButton:SetAnchor( TOPRIGHT, ui.SelectionList:GetControl(), BOTTOM, -10, 15 )
		ui.ConfirmButton:SetFont( "ZoFontWinH5" )
		ui.ConfirmButton:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		ui.ConfirmButton:SetText( "Add Items" )
        ui.ConfirmButton:SetClickSound( "Click" )
		ui.ConfirmButton:SetHandler( "OnClicked", function()
			local groupName = ui.SelectionList:GetSelectedItem()
			if nil == groupName or "" == groupName then
				EHT.UI.ShowErrorDialog( "Choose a Selection", "Choose a Saved Selection.", nil )
				return
			end

			local group = EHT.Data.GetGroup( groupName )
			if nil ~= group then
				EHT.Biz.AddGroupToCurrentGroup( group )
				EHT.UI.HideAddSelectionDialog()
			end
		end )

		ui.CancelButton = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "CancelButton", ui.SelectionGroup, "ZO_DefaultButton" )
		ui.CancelButton:SetDimensions( 130, 30 )
		ui.CancelButton:SetAnchor( TOPLEFT, ui.SelectionList:GetControl(), BOTTOM, 10, 15 )
		ui.CancelButton:SetFont( "ZoFontWinH5" )
		ui.CancelButton:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		ui.CancelButton:SetText( "Cancel" )
        ui.CancelButton:SetClickSound( "Click" )
		ui.CancelButton:SetHandler( "OnClicked", function()
			EHT.UI.HideAddSelectionDialog()
		end )

		ui.Window:SetHandler( "OnEffectivelyShown", function()
			local selectionList = ui.SelectionList
			selectionList:ClearItems()

			local groups = EHT.Data.GetGroups()
			for groupName, group in pairs( groups ) do
				if groupName ~= EHT.CONST.GROUP_DEFAULT then
					selectionList:AddItem( groupName, nil )
				end
			end

			selectionList:Refresh()
		end )
	end
	
	return ui
end

function EHT.UI.HideAddSelectionDialog()
	local ui = EHT.UI.AddSelectionDialog
	if ui then
		ui.Window:SetHidden( true )
		EHT.UI.EnableToolDialog()
	end
end

function EHT.UI.ShowAddSelectionDialog()
	local ui = EHT.UI.SetupAddSelectionDialog()
	if ui then
		EHT.UI.DisableToolDialog()
		ui.Window:SetHidden( false )
	end
end

------[[ Dialog : Remove Selection ]]------

function EHT.UI.SetupRemoveSelectionDialog()
	local ui = EHT.UI.RemoveSelectionDialog
	if nil == ui then
		ui = { }
		EHT.UI.RemoveSelectionDialog = ui

		local windowName = "RemoveSelectionDialog"
		local prefix = "EHTRemoveSelectionDialog"
		local dl = EHT.Effects.MAX_EDITOR_DRAW_LEVEL + 200

		-- Window Controls

		ui.Window = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
		ui.Window:SetHidden( true )
		ui.Window:SetDimensionConstraints( 400, 150, 400, 150 )
		ui.Window:SetMovable( true )
		ui.Window:SetMouseEnabled( true )
		ui.Window:SetClampedToScreen( true )
		ui.Window:SetAlpha( 1 )
		ui.Window:SetResizeHandleSize( 0 )
		ui.Window:SetAnchor( CENTER, GuiRoot, CENTER, 0, 0 )
		ui.Window:SetDrawLevel( dl )

		ui.Backdrop = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "Backdrop", ui.Window, "ZO_DefaultBackdrop" )
		ui.Backdrop:SetAnchor( TOPLEFT, ui.Window, TOPLEFT, 5, 5 )
		ui.Backdrop:SetAnchor( BOTTOMRIGHT, ui.Window, BOTTOMRIGHT, -5, -5 )
		ui.Backdrop:SetAlpha( 1 )

		-- Selections

		ui.SelectionGroup = EHT.CreateControl( nil, ui.Window, CT_CONTROL )
		ui.SelectionGroup:SetAnchor( TOPLEFT, ui.Window, TOPLEFT, 20, 20 )
		ui.SelectionGroup:SetAnchor( TOPRIGHT, ui.Window, TOPRIGHT, -20, 20 )
		ui.SelectionGroup:SetResizeToFitDescendents( true )

		ui.SelectionLabel = EHT.CreateControl( prefix .. "SelectionLabel", ui.SelectionGroup, CT_LABEL )
		ui.SelectionLabel:SetText( "Remove Items In Saved Selection" )
		ui.SelectionLabel:SetFont( "ZoFontGameLarge" )
		ui.SelectionLabel:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		ui.SelectionLabel:SetAnchor( TOPLEFT, ui.SelectionGroup, TOPLEFT, 0, 0 )
		ui.SelectionLabel:SetHeight( 25 )

		ui.SelectionList = EHT.UI.Picklist:New( prefix .. "Selection", ui.SelectionGroup, TOPLEFT, ui.SelectionLabel, BOTTOMLEFT, 0, 0, 360, 25 )
		ui.SelectionList:SetSorted( true )

		ui.ConfirmButton = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "ConfirmButton", ui.SelectionGroup, "ZO_DefaultButton" )
		ui.ConfirmButton:SetDimensions( 130, 30 )
		ui.ConfirmButton:SetAnchor( TOPRIGHT, ui.SelectionList:GetControl(), BOTTOM, -10, 15 )
		ui.ConfirmButton:SetFont( "ZoFontWinH5" )
		ui.ConfirmButton:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		ui.ConfirmButton:SetText( "Remove Items" )
        ui.ConfirmButton:SetClickSound( "Click" )
		ui.ConfirmButton:SetHandler( "OnClicked", function()
			local groupName = ui.SelectionList:GetSelectedItem()
			if nil == groupName or "" == groupName then
				EHT.UI.ShowErrorDialog( "Choose a Selection", "Choose a Saved Selection.", nil )
				return
			end

			local group = EHT.Data.GetGroup( groupName )
			if nil ~= group then
				EHT.Biz.RemoveGroupFromCurrentGroup( group )
				EHT.UI.HideRemoveSelectionDialog()
			end
		end )

		ui.CancelButton = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "CancelButton", ui.SelectionGroup, "ZO_DefaultButton" )
		ui.CancelButton:SetDimensions( 130, 30 )
		ui.CancelButton:SetAnchor( TOPLEFT, ui.SelectionList:GetControl(), BOTTOM, 10, 15 )
		ui.CancelButton:SetFont( "ZoFontWinH5" )
		ui.CancelButton:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		ui.CancelButton:SetText( "Cancel" )
        ui.CancelButton:SetClickSound( "Click" )
		ui.CancelButton:SetHandler( "OnClicked", function()
			EHT.UI.HideRemoveSelectionDialog()
		end )

		ui.Window:SetHandler( "OnEffectivelyShown", function()
			local selectionList = ui.SelectionList
			selectionList:ClearItems()

			local groups = EHT.Data.GetGroups()
			for groupName, group in pairs( groups ) do
				if groupName ~= EHT.CONST.GROUP_DEFAULT then
					selectionList:AddItem( groupName, nil )
				end
			end

			selectionList:Refresh()
		end )
	end
	
	return ui
end

function EHT.UI.HideRemoveSelectionDialog()
	local ui = EHT.UI.RemoveSelectionDialog
	if ui then
		ui.Window:SetHidden( true )
		EHT.UI.EnableToolDialog()
	end
end

function EHT.UI.ShowRemoveSelectionDialog()
	local ui = EHT.UI.SetupRemoveSelectionDialog()
	if ui then
		EHT.UI.DisableToolDialog()
		ui.Window:SetHidden( false )
	end
end

------[[ Dialog : Clone Scene ]]------

function EHT.UI.CloneSceneHouseSelected( houseId )

	local ui = EHT.UI.CloneSceneDialog
	if nil == ui then return end

	local sceneList = ui.SceneList
	sceneList:ClearItems()

	if nil == houseId or "table" == type( houseId ) then
		local houseBox = ui.HouseBox
		local itemData = houseBox:GetSelectedItemValue()
		if nil == itemData then return end
		houseId = itemData
	end

	local houseScenes = EHT.Data.GetScenes( houseId )

	for sceneName, scene in pairs( houseScenes ) do
		if sceneName ~= EHT.CONST.SCENE_DEFAULT then
			sceneList:AddItem( sceneName, nil, houseId )
		end
	end

end


function EHT.UI.RefreshCloneSceneDialog()

	local ui = EHT.UI.CloneSceneDialog
	if nil == ui then return end

	local currentHouseId = EHT.Housing.GetHouseId()
	local houseBox = ui.HouseBox
	houseBox:ClearItems()

	for houseId, house in pairs( EHT.Data.GetHouses() ) do
		if houseId ~= currentHouseId then
			houseBox:AddItem( house.Name, EHT.UI.CloneSceneHouseSelected, houseId )
		end
	end

	local currentHouse = EHT.Data.GetCurrentHouse()
	if nil ~= currentHouse then
		houseBox:SetSelectedItem( currentHouse.Name )
		EHT.UI.CloneSceneHouseSelected( currentHouse.HouseId )
	end
end

function EHT.UI.HideCloneSceneDialog()
	local ui = EHT.UI.CloneSceneDialog
	if nil ~= ui then
		EHT.UI.ClearDialogHidden( EHT.CONST.DIALOG.CLONE_SCENE )
		ui.Window:SetHidden( true )
		EHT.UI.EnableToolDialog()
	end
end

function EHT.UI.SetupCloneSceneDialog()
	local ui = EHT.UI.CloneSceneDialog
	if nil == ui then
		ui = { }

		local windowName = "CloneSceneDialog"
		local prefix = "EHTCloneSceneDialog"

		-- Window Controls

		ui.Window = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
		ui.Window:SetDimensionConstraints( 400, 200, 400, 200 )
		ui.Window:SetMovable( false )
		ui.Window:SetMouseEnabled( true )
		ui.Window:SetClampedToScreen( true )
		ui.Window:SetAlpha( 1 )
		ui.Window:SetResizeHandleSize( 0 )
		ui.Window:SetAnchor( CENTER, GuiRoot, CENTER, 0, 0 )

		ui.Backdrop = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "Backdrop", ui.Window, "ZO_DefaultBackdrop" )
		ui.Backdrop:SetAnchor( TOPLEFT, ui.Window, TOPLEFT, 5, 5 )
		ui.Backdrop:SetAnchor( BOTTOMRIGHT, ui.Window, BOTTOMRIGHT, -5, -5 )
		ui.Backdrop:SetAlpha( 1 )


		-- Scenes

		ui.SceneGroup = EHT.CreateControl( prefix .. "SceneGroup", ui.Window, CT_CONTROL )
		ui.SceneGroup:SetAnchor( TOPLEFT, ui.Window, TOPLEFT, 15, 25 )
		ui.SceneGroup:SetAnchor( TOPRIGHT, ui.Window, TOPRIGHT, -15, 25 )
		ui.SceneGroup:SetResizeToFitDescendents( true )

		ui.HouseLabel = EHT.CreateControl( prefix .. "HouseLabel", ui.SceneGroup, CT_LABEL )
		ui.HouseLabel:SetText( "House" )
		ui.HouseLabel:SetFont( "ZoFontGameLarge" )
		ui.HouseLabel:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		ui.HouseLabel:SetAnchor( TOPLEFT, ui.SceneGroup, TOPLEFT, 0, 0 )
		ui.HouseLabel:SetHeight( 25 )

		ui.HouseBox = EHT.UI.Picklist:New( prefix .. "HouseBox", ui.SceneGroup )
		ui.HouseBox:SetAnchor( TOPLEFT, ui.HouseLabel, BOTTOMLEFT, 0, 0 )
		ui.HouseBox:SetDimensions( 370, 25 )
		ui.HouseBox:SetSorted( true )

		ui.SceneLabel = EHT.CreateControl( prefix .. "SceneLabel", ui.SceneGroup, CT_LABEL )
		ui.SceneLabel:SetText( "Scene" )
		ui.SceneLabel:SetFont( "ZoFontGameLarge" )
		ui.SceneLabel:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		ui.SceneLabel:SetAnchor( TOPLEFT, ui.HouseBox:GetControl(), BOTTOMLEFT, 0, 10 )
		ui.SceneLabel:SetHeight( 25 )

		ui.SceneList = EHT.UI.Picklist:New( prefix .. "SceneList", ui.SceneGroup, TOPLEFT, ui.SceneLabel, BOTTOMLEFT, 0, 0, 370, 25 )
		ui.SceneList:SetSorted( true )

		ui.CloneSceneButton = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "CloneSceneButton", ui.SceneGroup, "ZO_DefaultButton" )
		ui.CloneSceneButton:SetDimensions( 150, 25 )
		ui.CloneSceneButton:SetAnchor( TOP, ui.SceneList:GetControl(), BOTTOM, 0, 10 )
		ui.CloneSceneButton:SetFont( "ZoFontWinH5" )
		ui.CloneSceneButton:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		ui.CloneSceneButton:SetText( "Clone Scene" )
        ui.CloneSceneButton:SetClickSound( "Click" )
		ui.CloneSceneButton:SetHandler( "OnClicked", function()

			local sceneName = ui.SceneList:GetSelectedItem()
			local houseId = ui.SceneList:GetSelectedItemValue()

			if nil == sceneName or "" == sceneName or nil == houseId then
				EHT.UI.ShowErrorDialog( "Choose a Scene", "Choose a Scene to clone.", nil )
				return
			end

			local scene = EHT.Data.GetScene( sceneName, houseId )

			if nil == scene then
				EHT.UI.ShowAlertDialog( "Select a valid Scene", "Select a specific Scene to clone from one of your Houses." )
				return
			end

			scene = EHT.Biz.SetupNewScene()

			EHT.Biz.CloneScene(
				houseId,
				sceneName,
				scene.Name,
				function( scene, msg )
					if nil == msg or "" == msg then
						EHT.UI.HideCloneSceneDialog()
						EHT.UI.EnableToolDialog()
						EHT.UI.RefreshAnimationDialog()
						EHT.Biz.CheckForMissingSceneItems()
						EHT.UI.ShowAlertDialog(
							"Clone Scene Complete",
							"Scene cloned successfully.\n\nPlease click |cff0000Fix Now|r to place the cloned Scene's items."
						)
					else
						EHT.UI.ShowAlertDialog(
							"Clone Scene Failed",
							string.format( "Scene clone failed:\n%s", msg )
						)
					end
				end,
				true)

		end )


		-- Top Window Controls

		ui.CloseButton = EHT.CreateControl( prefix .. "CloseButton", ui.Window, CT_BUTTON )
		ui.CloseButton:SetDimensions( 30, 30 )
		ui.CloseButton:SetAnchor( TOPRIGHT, ui.Window, TOPRIGHT, 0, 12 )
		ui.CloseButton:SetNormalTexture( "EsoUI/Art/Buttons/closebutton_up.dds" )
		ui.CloseButton:SetPressedTexture( "EsoUI/Art/Buttons/closebutton_down.dds" )
		ui.CloseButton:SetMouseOverTexture( "EsoUI/Art/Buttons/closebutton_mouseover.dds" )
		ui.CloseButton:SetDisabledTexture( "EsoUI/Art/Buttons/closebutton_disabled.dds" )
		ui.CloseButton:SetHandler( "OnClicked", function()
			EHT.UI.HideCloneSceneDialog()
			EHT.UI.EnableToolDialog()
		end )


		EHT.UI.CloneSceneDialog = ui

	end
	
	return ui

end

function EHT.UI.ShowCloneSceneDialog()
	local ui = EHT.UI.CloneSceneDialog
	if nil == ui then ui = EHT.UI.SetupCloneSceneDialog() end
	EHT.UI.RefreshCloneSceneDialog()
	EHT.UI.DisableToolDialog()
	if not isUIHidden and ui.Window:IsHidden() then
		ui.Window:SetHidden( false )
		EHT.UI.EnterUIMode()
	end
end

------[[ Dialog : Backups ]]------

function EHT.UI.HideBackupsDialog()
	if nil ~= EHT.UI.BackupsDialog then
		EHT.UI.ClearDialogHidden( EHT.CONST.DIALOG.BACKUPS )
		EHT.UI.BackupsDialog.Window:SetHidden( true )
	end
end

function EHT.UI.SetupBackupsDialog()
	local ui = EHT.UI.BackupsDialog
	if nil == ui then
		ui = { }
		EHT.UI.BackupsDialog = ui

		local tip = EHT.UI.SetInfoTooltip
		local windowName = "BackupsDialog"
		local prefix = "EHTBackupsDialog"
		local c, grp, win

		-- Window Controls

		win = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
		ui.Window = win
		win:SetDimensionConstraints( 500, 450, 500, 450 )
		win:SetMovable( true )
		win:SetMouseEnabled( true )
		win:SetClampedToScreen( true )
		win:SetAlpha( 1 )
		win:SetResizeHandleSize( 0 )
		win:SetAnchor( CENTER, GuiRoot, CENTER, 0, 0 )
		win:SetHandler( "OnMoveStop", function() EHT.UI.SaveDialogSettings( windowName, win ) end )
		win:SetHandler( "OnResizeStop", function() EHT.UI.SaveDialogSettings( windowName, win ) end )
		win:SetHidden( true )
		win:SetDrawLevel( EHT.Effects.MAX_EDITOR_DRAW_LEVEL + 100 )

		c = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "Backdrop", win, "ZO_DefaultBackdrop" )
		ui.Backdrop = c
		c:SetAnchor( TOPLEFT, win, TOPLEFT, 5, 5 )
		c:SetAnchor( BOTTOMRIGHT, win, BOTTOMRIGHT, -5, -5 )
		c:SetAlpha( 1 )

		c = EHT.CreateControl( prefix .. "BackupsTitle", win, CT_LABEL )
		ui.BackupsTitle = c
		c:SetText( "Automatic Backups" )
		c:SetFont( "ZoFontWinH3" )
		c:SetColor( 1, 1, 0.65, 1 )
		c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		c:SetAnchor( TOP, win, TOP, 0, 20 )

		c = EHT.CreateControl( prefix .. "BackupsStatus", win, CT_LABEL )
		ui.BackupsStatus = c
		c:SetFont( "$(BOLD_FONT)|$(KB_18)|soft-shadow-thick" )
		c:SetColor( 1, 1, 1, 1 )
		c:SetAnchor( TOPLEFT, win, TOPLEFT, 20, 60 )
		c:SetText( "Automatic backups are currently: " )

		c = EHT.CreateControl( prefix .. "BackupsEnabled", win, CT_LABEL )
		ui.BackupsEnabled = c
		c:SetFont( "$(BOLD_FONT)|$(KB_18)|soft-shadow-thin" )
		c:SetColor( 0.5, 1, 0.5, 1 )
		c:SetAnchor( LEFT, ui.BackupsStatus, RIGHT, 8, 0 )
		c:SetText( "Enabled" )

		c = EHT.CreateControl( prefix .. "BackupsDisabled", win, CT_LABEL )
		ui.BackupsDisabled = c
		c:SetFont( "$(BOLD_FONT)|$(KB_18)|soft-shadow-thin" )
		c:SetColor( 1, 0.5, 0.5, 1 )
		c:SetAnchor( LEFT, ui.BackupsStatus, RIGHT, 8, 0 )
		c:SetText( "Disabled" )

		c = EHT.CreateControl( prefix .. "BackupSettings", win, CT_LABEL )
		ui.BackupSettings = c
		c:SetFont( "$(BOLD_FONT)|$(KB_18)" )
		c:SetColor( 0.6, 0.6, 0.6, 1 )
		c:SetAnchor( TOPLEFT, win, TOPLEFT, 20, 85 )
		c:SetText( "Automatic backups can be enabled or disabled from Settings." )

		c = EHT.CreateControl( prefix .. "BackupsInfo", win, CT_LABEL )
		ui.BackupsInfo = c
		c:SetFont( "$(BOLD_FONT)|$(KB_18)|soft-shadow-thick" )
		c:SetColor( 0.9, 0.9, 0.9, 1 )
		c:SetAnchor( TOPLEFT, win, TOPLEFT, 20, 125 )
		c:SetAnchor( TOPRIGHT, win, TOPRIGHT, -20, 125 )
		c:SetMaxLineCount( 10 )
		c:SetText(
			string.format(
				"%s can periodically save a backup of your furniture placement automatically:\n" ..
				"- Separate backups are maintained for each home.\n" ..
				"- The %d most recent backups are retained for each home.\n" ..
				"- A new backup is saved upon leaving your home.\n" ..
				"  * Avoid force closing the game (such as ALT + F4) as this will lose any unsaved add-on data (including the latest snapshot of your home)",
				EHT.ADDON_TITLE, EHT.CONST.MAX_HOUSE_BACKUPS ) )

		-- Restore Status

		c = EHT.CreateControl( prefix .. "RestoreStatusLabel", win, CT_LABEL )
		ui.RestoreStatusLabel = c
		c:SetHidden( true )
		c:SetFont( "ZoFontWinH4" )
		SetColor(c, Colors.White)
		c:SetAnchor( BOTTOM, win, BOTTOM, 0, -20 )
		c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		c:SetText( "" )

		-- Backups Group

		grp = EHT.CreateControl( prefix .. "BackupsGroup", win, CT_CONTROL )
		ui.BackupsGroup = grp
		grp:SetAnchor( TOPLEFT, ui.BackupsInfo, BOTTOMLEFT, 0, 12 )
		grp:SetAnchor( TOPRIGHT, ui.BackupsInfo, BOTTOMRIGHT, 0, 12 )
		grp:SetResizeToFitDescendents( true )

		ui.CreateBackupButton = EHT.UI.CreateButton(
			prefix .. "CreateBackupButton",
			grp,
			"Create a new backup now",
			{ { TOP, grp, TOP, 0, 0 } },
			function()
				local success, message = EHT.Biz.CreateBackup( false, true )
				EHT.UI.ShowAlertDialog( "Create Backup", message )
				EHT.UI.QueueRefreshBackups()
			end )
		tip( ui.CreateBackupButton, "Creates a backup of your current house." )

		c = EHT.CreateControl( prefix .. "BackupListLabel", grp, CT_LABEL )
		ui.BackupListLabel = c
		c:SetFont( "ZoFontWinH4" )
		SetColor(c, Colors.White)
		c:SetAnchor( TOPLEFT, grp, TOPLEFT, 5, 30 )
		c:SetAnchor( TOPRIGHT, grp, TOPRIGHT, 0, 30 )
		c:SetText( "Available Backups" )

		c = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "BackupBox", grp, "ZO_ComboBox" )
		ui.BackupBox = c
		c:SetAnchor( TOPLEFT, ui.BackupListLabel, BOTTOMLEFT, 0, 2 )
		c:SetAnchor( TOPRIGHT, ui.BackupListLabel, BOTTOMRIGHT, -90, 2 )
		c:SetHeight( 25 )
		tip( c, "Select a saved backup to restore." )

		c = ZO_ComboBox_ObjectFromContainer( c )
		ui.BackupList = c
		c:SetFont( "ZoFontWinH5" )
		c:SetSortsItems( true )

		ui.RestoreBackupButton = EHT.UI.CreateButton(
			prefix .. "RestoreBackupButton",
			grp,
			"Restore",
			{ { LEFT, ui.BackupBox, RIGHT, 6, -1 } },
			function()
				local item = ui.BackupList:GetSelectedItemData()
				if nil == item then
					EHT.UI.ShowAlertDialog( "Restore Backup", "Select a backup to restore." )
					return
				end

				local backupIndex = item.BackupIndex
				local warning = "\n\n|cffffffWARNING: |cffff00All Furniture Linking will be removed in order to prevent the server from moving pre-linked items as your backup is restored.|r"

				EHT.UI.ShowConfirmationDialog( "Restore Backup",
					string.format( "Restore the backup\n\"%s\"?" .. warning, item.name ),
					function()
						EHT.Biz.RestoreBackup( backupIndex )
					end )
			end )

		tip( ui.RestoreBackupButton,
			"Restores the selected backup.\n" ..
			"This INCLUDES:\n\n" ..
			"- Placing any items removed since the backup (as long as the items are available in your inventory, bank or house storage containers)\n" ..
			"- Restoring all backed up items to their positions at the time of the backup.\n\n" ..
			"This DOES NOT INCLUDE:\n\n" ..
			"- Removing any items added since the backup.\n\n" ..
			"WARNING:\n\n" ..
			"Any linked items will be unlinked in order to prevent linked items from shifting during the restore process." )

		-- Top Window Controls

		c = EHT.CreateControl( prefix .. "CloseButton", win, CT_BUTTON )
		ui.CloseButton = c
		c:SetDimensions( 42, 42 )
		c:SetAnchor( TOPRIGHT, win, TOPRIGHT, -5, 16 )
		c:SetNormalTexture( "EsoUI/Art/Buttons/closebutton_up.dds" )
		c:SetPressedTexture( "EsoUI/Art/Buttons/closebutton_down.dds" )
		c:SetMouseOverTexture( "EsoUI/Art/Buttons/closebutton_mouseover.dds" )
		c:SetDisabledTexture( "EsoUI/Art/Buttons/closebutton_disabled.dds" )
		c:SetHandler( "OnClicked", function() EHT.UI.HideBackupsDialog() end )

	end

	return ui

end


function EHT.UI.ShowBackupsDialog()

	if nil == EHT.UI.BackupsDialog then EHT.UI.SetupBackupsDialog() end
	if not isUIHidden and EHT.UI.BackupsDialog.Window:IsHidden() then
		EHT.UI.BackupsDialog.Window:SetHidden( false )
		EHT.UI.EnterUIMode()
	end
	EHT.UI.QueueRefreshBackups()

end


function EHT.UI.QueueRefreshBackups()

	local house = EHT.Data.GetCurrentHouse()
	if nil == house then return end

	local ui = EHT.UI.SetupBackupsDialog()
	if nil == ui then return end

	ui.BackupsEnabled:SetHidden( not EHT.SavedVars.AutoBackup )
	ui.BackupsDisabled:SetHidden( EHT.SavedVars.AutoBackup )

	local c = ui.BackupList
	c:ClearItems()

	local backups = house.Backups
	if nil == backups then return end

	local item
	c:SetSortsItems( false )

	if nil ~= backups.PreRestore then
		item = c:CreateItemEntry( string.format( "%s at %s (%d items) [Before Restore]", backups.PreRestore.BDate, backups.PreRestore.BTime, #backups.PreRestore.Items ) )
		item.BackupIndex = "PreRestore"
		c:AddItem( item )
	end

	for index, backup in ipairs( house.Backups ) do
		if nil ~= backup.Items and nil ~= backup.BDate and nil ~= backup.BTime then
			item = c:CreateItemEntry( string.format( "%s at %s (%d items)", backup.BDate, backup.BTime, #backup.Items ) )
			item.BackupIndex = index
			c:AddItem( item )
		end
	end

	c:SetSelectedItem( nil )

end


function EHT.UI.UpdateRestoreStatus( status )

	local ui = EHT.UI.BackupsDialog
	if not ui then return end

	if status then
		ui.RestoreStatusLabel:SetText( status )
		ui.RestoreStatusLabel:SetHidden( false )
	else
		ui.RestoreStatusLabel:SetHidden( true )
	end

	if status then
		ui.BackupsGroup:SetHidden( true )
	else
		ui.BackupsGroup:SetHidden( false )
	end

end


------[[ Dialog : Position ]]------


function EHT.UI.PositionDialogChanged( ctrl )

	-- if EHT.Util.LoopCounter( "EHT.UI.PositionDialogChanged" ) then return end
	--if nil ~= ctrl and nil ~= ctrl.PreviousValue and ctrl.PreviousValue == ctrl:GetText() then return else ctrl.PreviousValue = ctrl:GetText() end

	local id = EHT.PositionItemId
	local ui = EHT.UI.PositionDialog
	if nil == id or 0 == id or nil == ui then return end

	local isEffect = EHT.Housing.IsEffectId( id )
	local moveGroup = ZO_CheckButton_IsChecked( ui.MoveGroupItems )
	local x, y, z = EHT.Util.StringToNumber( ui.XField:GetText(), 0 ), EHT.Util.StringToNumber( ui.YField:GetText(), 0 ), EHT.Util.StringToNumber( ui.ZField:GetText(), 0 )
	local pitch, yaw, roll = EHT.Util.StringToNumber( ui.PitchField:GetText() ), EHT.Util.StringToNumber( ui.YawField:GetText() ), EHT.Util.StringToNumber( ui.RollField:GetText() )
	local effect, effectColor, r, g, b, a, sizeX, sizeY, sizeZ
	local oldR, oldG, oldB, oldA, oldSizeX, oldSizeY, oldSizeZ
	local compColor, oldCompColor

	if isEffect then
		effect = EHT.Effect:GetByRecordId( id )

		if effect then
			effectColor = EHT.Util.Trim( ui.ColorField:GetText() ) or ""

			if effectColor and "" ~= effectColor then
				r = tonumber( string.format( "0x%s", string.sub( effectColor, 1, 2 ) or "0" ) )
				g = tonumber( string.format( "0x%s", string.sub( effectColor, 3, 4 ) or "0" ) )
				b = tonumber( string.format( "0x%s", string.sub( effectColor, 5, 6 ) or "0" ) )

				r, g, b = ( r or 0 ) / 255, ( g or 0 ) / 255, ( b or 0 ) / 255
				compColor = EHT.Util.CompressColor( r, g, b )
			end

			sizeX, sizeY, sizeZ = round( tonumber( ui.SizeXField:GetText() ) ), round( tonumber( ui.SizeYField:GetText() ) ), round( tonumber( ui.SizeZField:GetText() ) )
		end

		oldR, oldG, oldB, oldA = effect:GetColor()
		a = oldA
		oldSizeX, oldSizeY, oldSizeZ = effect:GetSize()
		oldSizeX, oldSizeY, oldSizeZ = round( oldSizeX ), round( oldSizeY ), round( oldSizeZ )
		oldCompColor = EHT.Util.CompressColor( oldR, oldG, oldB )
	end

	local currentX, currentY, currentZ = EHT.Housing.GetFurniturePosition( id )

	if 0 == x then x = currentX ui.XField:SetText( tostring( round( x, 0 ) ) ) ui.XField.PreviousValue = ui.XField:GetText() end
	if 0 == y then y = currentY ui.YField:SetText( tostring( round( y, 0 ) ) ) ui.YField.PreviousValue = ui.YField:GetText() end
	if 0 == z then z = currentZ ui.ZField:SetText( tostring( round( z, 0 ) ) ) ui.ZField.PreviousValue = ui.ZField:GetText() end

	local currentPitch, currentYaw, currentRoll = EHT.Housing.GetFurnitureOrientation( id )

	if "number" ~= type( pitch ) then pitch = currentPitch else pitch = math.rad( pitch ) end
	if "number" ~= type( yaw ) then yaw = currentYaw else yaw = math.rad( yaw ) end
	if "number" ~= type( roll ) then roll = currentRoll else roll = math.rad( roll ) end

	ui.PitchField:SetText( tostring( round( math.deg( pitch ), 2 ) ) ) ui.PitchField.PreviousValue = ui.PitchField:GetText()
	ui.YawField:SetText( tostring( round( math.deg( yaw ), 2 ) ) ) ui.YawField.PreviousValue = ui.YawField:GetText()
	ui.RollField:SetText( tostring( round( math.deg( roll ), 2 ) ) ) ui.RollField.PreviousValue = ui.RollField:GetText()

	pitch, yaw, roll = EHT.Housing.CorrectGimbalLock( pitch, yaw, roll, nil, id )

	if 0 ~= x and 0 ~= y and 0 ~= z then
		local moveItem = true

		if moveGroup then
			local item = EHT.Data.GetGroupFurniture( id )
			if nil ~= item then
				moveItem = false

				local updatedItem = { X = x, Y = y, Z = z, Pitch = pitch, Yaw = yaw, Roll = roll, Color = compColor, Alpha = a, SizeX = sizeX, SizeY = sizeY, SizeZ = sizeZ }
				local previousItem = { X = currentX, Y = currentY, Z = currentZ, Pitch = currentPitch, Yaw = currentYaw, Roll = currentRoll, Color = oldCompColor, Alpha = oldA, SizeX = oldSizeX, SizeY = oldSizeY, SizeZ = oldSizeZ }

				EHT.Biz.AdjustRelativeFurniture( updatedItem, previousItem, id )
			end
		end

		if moveItem then
			if effect then
				EHT.Housing.SetFurniturePositionAndOrientation( id, x, y, z, pitch, yaw, roll )
				effect:SetColor( r, g, b )
				effect:SetSize( sizeX, sizeY, sizeZ )
				effect:UpdateRecord()
			else
				local oldX, oldY, oldZ = EHT.Housing.GetFurniturePosition( id )
				local oldPitch, oldYaw, oldRoll = EHT.Housing.GetFurnitureOrientation( id )
				local link = EHT.Housing.GetFurnitureLink( id )
				local updatedItem = { Id = id, Link = link, X = x, Y = y, Z = z, Pitch = pitch, Yaw = yaw, Roll = roll }
				local previousItem = { Id = id, Link = link, X = oldX, Y = oldY, Z = oldZ, Pitch = oldPitch, Yaw = oldYaw, Roll = oldRoll }

				EHT.Housing.SetFurniturePositionAndOrientation( id, x, y, z, pitch, yaw, roll )
				EHT.Handlers.OnFurnitureChanged( updatedItem, previousItem, "PositionDialog" )
			end
		end
	end

	EHT.Pointers.ShowGuidelinesArrows( false )

end


function EHT.UI.PositionDialogMoveGroupChanged()

	local ui = EHT.UI.PositionDialog
	if nil == ui then return end

	local isGroupFurniture = nil ~= EHT.Data.GetGroupFurniture( EHT.PositionItemId )
	local moveGroup = ZO_CheckButton_IsChecked( ui.MoveGroupItems )

end


function EHT.UI.RefreshPositionDialog( furniture )

	-- if EHT.Util.LoopCounter( "EHT.UI.RefreshPositionDialog" ) then return end
	local id = EHT.PositionItemId
	local ui = EHT.UI.PositionDialog
	if nil == id or nil == ui then return end

	local itemLink = EHT.Housing.GetFurnitureLink( id )
	local itemName = EHT.Housing.GetFurnitureLinkName( itemLink )
	local itemIcon = EHT.Housing.GetFurnitureLinkIconFile( itemLink )
	if nil == itemIcon then itemIcon = "" end

	local colorR, colorG, colorB, colorA = GetInterfaceColor( INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, GetItemLinkQuality( itemLink ) )
	local effect, r, g, b, a, sizeX, sizeY, sizeZ
	local x, y, z, pitch, yaw, roll
	local effectId = id
	local isEffect = false

	if nil ~= furniture then
		x, y, z = furniture.X, furniture.Y, furniture.Z
		pitch, yaw, roll = furniture.Pitch, furniture.Yaw, furniture.Roll
		effectId = furniture.Id
	else
		x, y, z = EHT.Housing.GetFurniturePosition( id )
		pitch, yaw, roll = EHT.Housing.GetFurnitureOrientation( id )
	end

	isEffect = EHT.Housing.IsEffectId( effectId )
	if isEffect then
		effect = EHT.Effect:GetByRecordId( effectId )

		if effect then
			r, g, b, a = effect:GetColor()
			sizeX, sizeY, sizeZ = effect:GetSize()
		end

		r, g, b, a = r or 0, g or 0, b or 0, a or 0
		sizeX, sizeY, sizeZ = sizeX or 100, sizeY or 100, sizeZ or 100
	end

	if nil == x or nil == y or nil == z or nil == pitch or nil == yaw or nil == roll or 0 == x and 0 == y and 0 == z then
		EHT.UI.HidePositionDialog()
		return
	end

	x, y, z = math.floor( x ), math.floor( y ), math.floor( z )

	ui.ItemLabel:SetText( itemName or "" )
	if nil ~= colorR and colorR then ui.ItemLabel:SetColor( colorR, colorG, colorB, 1 ) end
	ui.ItemIconBackdrop:SetTexture( itemIcon )
	ui.ItemIcon:SetTexture( itemIcon )

	ui.XField:SetText( tostring( round( x, 0 ) ) ) ui.XField.PreviousValue = ui.XField:GetText()
	ui.YField:SetText( tostring( round( y, 0 ) ) ) ui.YField.PreviousValue = ui.YField:GetText()
	ui.ZField:SetText( tostring( round( z, 0 ) ) ) ui.ZField.PreviousValue = ui.ZField:GetText()

	ui.PitchField:SetText( tostring( round( math.deg( pitch ), 2 ) ) ) ui.PitchField.PreviousValue = ui.PitchField:GetText()
	ui.YawField:SetText( tostring( round( math.deg( yaw ), 2 ) ) ) ui.YawField.PreviousValue = ui.YawField:GetText()
	ui.RollField:SetText( tostring( round( math.deg( roll ), 2 ) ) ) ui.RollField.PreviousValue = ui.RollField:GetText()

	ui.ColorField:SetEditEnabled( isEffect )
	ui.SizeXField:SetEditEnabled( isEffect )
	ui.SizeYField:SetEditEnabled( isEffect )
	ui.SizeZField:SetEditEnabled( isEffect )

	if isEffect and effect then
		ui.ColorField:SetText( string.format( "%.2x%.2x%.2x", math.ceil( ( r or 0 ) * 255 ), math.ceil( ( g or 0 ) * 255 ), math.ceil( ( b or 0 ) * 255 ) ) )
		ui.SizeXField:SetText( tostring( sizeX ) )
		ui.SizeYField:SetText( tostring( sizeY ) )
		ui.SizeZField:SetText( tostring( sizeZ ) )
	else
		ui.ColorField:SetText( "" )
		ui.SizeXField:SetText( "" )
		ui.SizeYField:SetText( "" )
		ui.SizeZField:SetText( "" )
	end

	local isGroupFurniture = nil ~= EHT.Data.GetGroupFurniture( id )
	ZO_CheckButton_SetEnableState( ui.MoveGroupItems, isGroupFurniture )

	EHT.UI.PositionDialogMoveGroupChanged()
	ui.UpdateDimensions()
end

function EHT.UI.HidePositionDialog()
	if nil ~= EHT.UI.PositionDialog then
		EHT.PositionItemId = nil
		EHT.UI.ClearDialogHidden( EHT.CONST.DIALOG.POSITION )
		EHT.UI.PositionDialog.Window:SetHidden( true )
	end
end

function EHT.UI.SetupPositionDialog()
	local ui = EHT.UI.PositionDialog
	if nil == ui then
		ui = { }

		local windowName = "PositionDialog"
		local prefix = "EHTPositionDialog"
		local settings = EHT.UI.GetDialogSettings( windowName )

		local minWidth, maxWidth = 160, 376
		local minHeight, maxHeight = 160, 400


		local adjustDimensions = function()

			local settings = EHT.UI.GetDialogSettings( windowName )
			local width, height = ui.Window:GetDimensions()
			local maxValidHeight = maxHeight

			if	( height == settings.Height and ( ( maxWidth - minWidth ) / 2 ) <= ( width - minWidth ) ) or
				( width == settings.Width and ( ( maxValidHeight - minHeight ) / 2 ) > ( height - minHeight ) ) or
				( ( ( maxWidth - minWidth ) / 2 ) <= ( width - minWidth ) and ( ( maxValidHeight - minHeight ) / 2 ) > ( height - minHeight ) ) then

				width = maxWidth
				height = minHeight

			else

				width = minWidth
				height = maxHeight

			end

			ui.Window:SetDimensions( width, height )

			if width == maxWidth then
				ui.XLabel:SetWidth( 14 )
				ui.YLabel:SetWidth( 14 )
				ui.ZLabel:SetWidth( 14 )

				ui.OrientationGroup:ClearAnchors()
				ui.OrientationGroup:SetAnchor( LEFT, ui.PositionGroup, RIGHT, 16, 0 )

				ui.FXGroup:ClearAnchors()
				ui.FXGroup:SetAnchor( LEFT, ui.OrientationGroup, RIGHT, 16, 0 )
			else
				ui.XLabel:SetWidth( 48 )
				ui.YLabel:SetWidth( 48 )
				ui.ZLabel:SetWidth( 48 )

				ui.OrientationGroup:ClearAnchors()
				ui.OrientationGroup:SetAnchor( TOP, ui.PositionGroup, BOTTOM, 0, 16 )

				ui.FXGroup:ClearAnchors()
				ui.FXGroup:SetAnchor( TOPLEFT, ui.OrientationGroup, BOTTOMLEFT, 0, 16 )
			end

			EHT.UI.SaveDialogSettings( windowName, ui.Window )

		end
		
		ui.UpdateDimensions = adjustDimensions


		-- Window Controls

		ui.Window = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
		ui.Window:SetDimensionConstraints( minWidth, minHeight, maxWidth, maxHeight )
		ui.Window:SetMovable( true )
		ui.Window:SetMouseEnabled( true )
		ui.Window:SetClampedToScreen( true )
		ui.Window:SetAlpha( 1 )
		ui.Window:SetResizeHandleSize( 5 )

		if settings.Left and settings.Top then
			ui.Window:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, settings.Left, settings.Top )
		else
			ui.Window:SetAnchor( TOPRIGHT, GuiRoot, TOPRIGHT, -40, 40 )
		end

		if settings.Width and settings.Height then
			ui.Window:SetDimensions( settings.Width, settings.Height )
		else
			ui.Window:SetDimensions( maxWidth, minHeight )
		end


		ui.Backdrop = EHT.CreateControl( prefix .. "Backdrop", ui.Window, CT_TEXTURE )
		ui.Backdrop:SetAnchor( TOPLEFT, ui.Window, TOPLEFT, 0, 0 )
		ui.Backdrop:SetAnchor( BOTTOMRIGHT, ui.Window, BOTTOMRIGHT, 0, 0 )
		ui.Backdrop:SetVertexColors( 1, 0, 0.3, 0.1, 0.6 )
		ui.Backdrop:SetVertexColors( 2 + 4, 0, 0.15, 0.15, 0.6 )
		ui.Backdrop:SetVertexColors( 8, 0, 0.1, 0.3, 0.6 )
		ui.Backdrop:SetMouseEnabled( false )

		ui.Top = EHT.CreateControl( prefix .. "Top", ui.Window, CT_CONTROL )
		ui.Top:SetAnchor( BOTTOMLEFT, ui.Window, TOPLEFT, 0, 0 )
		ui.Top:SetAnchor( BOTTOMRIGHT, ui.Window, TOPRIGHT, 0, 0 )
		ui.Top:SetResizeToFitDescendents( true )
		ui.Top:SetResizeToFitPadding( 0, 20 )
		
		ui.Top:SetMouseEnabled( true )
		ui.Top:SetHandler( "OnMouseDown", function() ui.Window:StartMoving() end )
		ui.Top:SetHandler( "OnMouseUp", function() ui.Window:StopMovingOrResizing() end )

		ui.TopBackdrop = EHT.CreateControl( prefix .. "TopBackdrop", ui.Window, CT_TEXTURE )
		ui.TopBackdrop:SetAnchor( TOPLEFT, ui.Top, TOPLEFT, 0, 0 )
		ui.TopBackdrop:SetAnchor( BOTTOMRIGHT, ui.Top, BOTTOMRIGHT, 0, 0 )
		ui.TopBackdrop:SetVertexColors( 1 + 2, 1, 1, 1, 0 )
		ui.TopBackdrop:SetVertexColors( 4, 0, 0.3, 0.1, 0.6 )
		ui.TopBackdrop:SetVertexColors( 8, 0, 0.15, 0.15, 0.6 )
		ui.TopBackdrop:SetMouseEnabled( false )

		ui.ItemLabel = EHT.CreateControl( prefix .. "ItemLabel", ui.Top, CT_LABEL )
		ui.ItemLabel:SetText( "" )
		ui.ItemLabel:SetFont( "$(MEDIUM_FONT)|$(KB_20)|soft-shadow-thick" )
		ui.ItemLabel:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		ui.ItemLabel:SetAnchor( BOTTOMLEFT, ui.Top, BOTTOMLEFT, 50, 2 )
		ui.ItemLabel:SetAnchor( BOTTOMRIGHT, ui.Top, BOTTOMRIGHT, 0, 2 )
		ui.ItemLabel:SetMaxLineCount( 4 )

		ui.ItemIconBackdrop = EHT.CreateControl( prefix .. "ItemIconBackdrop", ui.Top, CT_TEXTURE )
		ui.ItemIconBackdrop:SetAnchor( BOTTOMLEFT, ui.Top, BOTTOMLEFT, 2, 0 )
		ui.ItemIconBackdrop:SetColor( 0, 0, 0, 1 )
		ui.ItemIconBackdrop:SetDimensions( 46, 46 )
		ui.ItemIconBackdrop:SetDesaturation( 1 )
		-- ui.ItemIconBackdrop:SetTextureSampleProcessingWeight( 0, 1 )

		ui.ItemIcon = EHT.CreateControl( prefix .. "ItemIcon", ui.Top, CT_TEXTURE )
		ui.ItemIcon:SetAnchor( BOTTOMLEFT, ui.Top, BOTTOMLEFT, 0, -2 )
		ui.ItemIcon:SetColor( 1, 1, 1, 1 )
		ui.ItemIcon:SetDimensions( 46, 46 )
		ui.ItemIcon:SetTextureSampleProcessingWeight( 1, 0.1 )


		ui.Bottom = EHT.CreateControl( prefix .. "Bottom", ui.Window, CT_CONTROL )
		ui.Bottom:SetAnchor( BOTTOMLEFT, ui.Window, BOTTOMLEFT, 15, -15 )
		ui.Bottom:SetAnchor( BOTTOMRIGHT, ui.Window, BOTTOMRIGHT, -15, -15 )
		ui.Bottom:SetResizeToFitDescendents( true )
		ui.Bottom:SetMouseEnabled( true )

		ui.MoveGroupItems = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "MoveGroupItems", ui.Bottom, "ZO_CheckButton" )
		ui.MoveGroupItems:SetAnchor( LEFT, ui.Bottom, LEFT, 0, 0 )
		ZO_CheckButton_SetCheckState( ui.MoveGroupItems, false )
		ZO_CheckButton_SetToggleFunction( ui.MoveGroupItems, EHT.UI.PositionDialogMoveGroupChanged )
		ui.MoveGroupItems:SetMouseEnabled( false )

		ui.MoveGroupItemsLabel = EHT.CreateControl( prefix .. "MoveGroupItemsLabel", ui.Bottom, CT_LABEL )
		ui.MoveGroupItemsLabel:SetText( "Apply to all selected items" )
		ui.MoveGroupItemsLabel:SetFont( "$(MEDIUM_FONT)|$(KB_18)" )
		ui.MoveGroupItemsLabel:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		ui.MoveGroupItemsLabel:SetVerticalAlignment( TEXT_ALIGN_BOTTOM )
		ui.MoveGroupItemsLabel:SetAnchor( BOTTOMLEFT, ui.Bottom, BOTTOMLEFT, 20, 0 )
		ui.MoveGroupItemsLabel:SetAnchor( BOTTOMRIGHT, ui.Bottom, BOTTOMRIGHT, 0, 0 )

		ui.Bottom:SetHandler( "OnMouseDown", function()
			ZO_CheckButton_SetCheckState( ui.MoveGroupItems, not ZO_CheckButton_IsChecked( ui.MoveGroupItems ) )
		end )


		ui.ControlGroup = EHT.CreateControl( prefix .. "ControlGroup", ui.Window, CT_CONTROL )
		ui.ControlGroup:SetAnchor( TOPLEFT, ui.Window, TOPLEFT, 15, 16 )
		ui.ControlGroup:SetAnchor( BOTTOMRIGHT, ui.Bottom, TOPRIGHT, 0, -6 )


		-- Position Group

		ui.PositionGroup = EHT.CreateControl( prefix .. "PositionGroup", ui.ControlGroup, CT_CONTROL )
		ui.PositionGroup:SetAnchor( TOPLEFT, ui.ControlGroup, TOPLEFT, 0, 0 )
		ui.PositionGroup:SetResizeToFitDescendents( true )


		ui.XLabel = EHT.CreateControl( prefix .. "XLabel", ui.PositionGroup, CT_LABEL )
		ui.XLabel:SetText( "X" )
		ui.XLabel:SetFont( "$(MEDIUM_FONT)|$(KB_20)" )
		ui.XLabel:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		ui.XLabel:SetVerticalAlignment( TEXT_ALIGN_CENTER )
		ui.XLabel:SetAnchor( TOPLEFT, ui.PositionGroup, TOPLEFT, 0, 0 )
		ui.XLabel:SetDimensions( 14, 25 )

		ui.XBackdrop = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "XBackdrop", ui.PositionGroup, "ZO_EditBackdrop" )
		ui.XBackdrop:SetAnchor( TOPLEFT, ui.XLabel, TOPRIGHT, 5, 0 )
		ui.XBackdrop:SetDimensions( 60, 25 )

		ui.XField = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "XField", ui.XBackdrop, "ZO_DefaultEditForBackdrop" ) 
		ui.XField:SetFont( "$(CHAT_FONT)|$(KB_18)" )
		ui.XField:SetAnchor( TOPLEFT, ui.XBackdrop, TOPLEFT, 1, 0 )
		ui.XField:SetAnchor( BOTTOMRIGHT, ui.XBackdrop, BOTTOMRIGHT, -1, 0 )
		ui.XField:SetHandler( "OnFocusLost", EHT.UI.PositionDialogChanged )
		ui.XField:SetMaxInputChars( 6 )

		ui.YLabel = EHT.CreateControl( prefix .. "YLabel", ui.PositionGroup, CT_LABEL )
		ui.YLabel:SetText( "Y" )
		ui.YLabel:SetFont( "$(MEDIUM_FONT)|$(KB_20)" )
		ui.YLabel:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		ui.YLabel:SetVerticalAlignment( TEXT_ALIGN_CENTER )
		ui.YLabel:SetAnchor( TOPLEFT, ui.XLabel, BOTTOMLEFT, 0, 10 )
		ui.YLabel:SetDimensions( 14, 25 )

		ui.YBackdrop = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "YBackdrop", ui.PositionGroup, "ZO_EditBackdrop" )
		ui.YBackdrop:SetAnchor( TOPLEFT, ui.YLabel, TOPRIGHT, 5, 0 )
		ui.YBackdrop:SetDimensions( 60, 25 )

		ui.YField = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "YField", ui.YBackdrop, "ZO_DefaultEditForBackdrop" ) 
		ui.YField:SetFont( "$(CHAT_FONT)|$(KB_18)" )
		ui.YField:SetAnchor( TOPLEFT, ui.YBackdrop, TOPLEFT, 1, 0 )
		ui.YField:SetAnchor( BOTTOMRIGHT, ui.YBackdrop, BOTTOMRIGHT, -1, 0 )
		ui.YField:SetHandler( "OnFocusLost", EHT.UI.PositionDialogChanged )
		ui.YField:SetMaxInputChars( 6 )


		ui.ZLabel = EHT.CreateControl( prefix .. "ZLabel", ui.PositionGroup, CT_LABEL )
		ui.ZLabel:SetText( "Z" )
		ui.ZLabel:SetFont( "$(MEDIUM_FONT)|$(KB_20)" )
		ui.ZLabel:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		ui.ZLabel:SetVerticalAlignment( TEXT_ALIGN_CENTER )
		ui.ZLabel:SetAnchor( TOPLEFT, ui.YLabel, BOTTOMLEFT, 0, 10 )
		ui.ZLabel:SetDimensions( 14, 25 )

		ui.ZBackdrop = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "ZBackdrop", ui.PositionGroup, "ZO_EditBackdrop" )
		ui.ZBackdrop:SetAnchor( TOPLEFT, ui.ZLabel, TOPRIGHT, 5, 0 )
		ui.ZBackdrop:SetDimensions( 60, 25 )

		ui.ZField = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "ZField", ui.ZBackdrop, "ZO_DefaultEditForBackdrop" ) 
		ui.ZField:SetFont( "$(CHAT_FONT)|$(KB_18)" )
		ui.ZField:SetAnchor( TOPLEFT, ui.ZBackdrop, TOPLEFT, 1, 0 )
		ui.ZField:SetAnchor( BOTTOMRIGHT, ui.ZBackdrop, BOTTOMRIGHT, -1, 0 )
		ui.ZField:SetHandler( "OnFocusLost", EHT.UI.PositionDialogChanged )
		ui.ZField:SetMaxInputChars( 6 )


		-- OrientationGroup

		ui.OrientationGroup = EHT.CreateControl( prefix .. "OrientationGroup", ui.ControlGroup, CT_CONTROL )
		ui.OrientationGroup:SetAnchor( LEFT, ui.PositionGroup, RIGHT, 16, 0 )
		ui.OrientationGroup:SetResizeToFitDescendents( true )


		ui.PitchLabel = EHT.CreateControl( prefix .. "PitchLabel", ui.OrientationGroup, CT_LABEL )
		ui.PitchLabel:SetText( "Pitch" )
		ui.PitchLabel:SetFont( "$(MEDIUM_FONT)|$(KB_20)" )
		ui.PitchLabel:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		ui.PitchLabel:SetVerticalAlignment( TEXT_ALIGN_CENTER )
		ui.PitchLabel:SetAnchor( TOPLEFT, ui.OrientationGroup, TOPLEFT, 0, 0 )
		ui.PitchLabel:SetDimensions( 48, 25 )

		ui.PitchBackdrop = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "PitchBackdrop", ui.OrientationGroup, "ZO_EditBackdrop" )
		ui.PitchBackdrop:SetAnchor( TOPLEFT, ui.PitchLabel, TOPRIGHT, 5, 0 )
		ui.PitchBackdrop:SetDimensions( 60, 25 )

		ui.PitchField = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "PitchField", ui.PitchBackdrop, "ZO_DefaultEditForBackdrop" ) 
		ui.PitchField:SetFont( "$(CHAT_FONT)|$(KB_18)" )
		ui.PitchField:SetAnchor( TOPLEFT, ui.PitchBackdrop, TOPLEFT, 1, 0 )
		ui.PitchField:SetAnchor( BOTTOMRIGHT, ui.PitchBackdrop, BOTTOMRIGHT, -1, 0 )
		ui.PitchField:SetHandler( "OnFocusLost", EHT.UI.PositionDialogChanged )
		ui.PitchField:SetMaxInputChars( 6 )


		ui.YawLabel = EHT.CreateControl( prefix .. "YawLabel", ui.OrientationGroup, CT_LABEL )
		ui.YawLabel:SetText( "Yaw" )
		ui.YawLabel:SetFont( "$(MEDIUM_FONT)|$(KB_20)" )
		ui.YawLabel:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		ui.YawLabel:SetVerticalAlignment( TEXT_ALIGN_CENTER )
		ui.YawLabel:SetAnchor( TOPLEFT, ui.PitchLabel, BOTTOMLEFT, 0, 10 )
		ui.YawLabel:SetDimensions( 48, 25 )

		ui.YawBackdrop = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "YawBackdrop", ui.OrientationGroup, "ZO_EditBackdrop" )
		ui.YawBackdrop:SetAnchor( TOPLEFT, ui.YawLabel, TOPRIGHT, 5, 0 )
		ui.YawBackdrop:SetDimensions( 60, 25 )

		ui.YawField = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "YawField", ui.YawBackdrop, "ZO_DefaultEditForBackdrop" ) 
		ui.YawField:SetFont( "$(CHAT_FONT)|$(KB_18)" )
		ui.YawField:SetAnchor( TOPLEFT, ui.YawBackdrop, TOPLEFT, 1, 0 )
		ui.YawField:SetAnchor( BOTTOMRIGHT, ui.YawBackdrop, BOTTOMRIGHT, -1, 0 )
		ui.YawField:SetHandler( "OnFocusLost", EHT.UI.PositionDialogChanged )
		ui.YawField:SetMaxInputChars( 6 )


		ui.RollLabel = EHT.CreateControl( prefix .. "RollLabel", ui.OrientationGroup, CT_LABEL )
		ui.RollLabel:SetText( "Roll" )
		ui.RollLabel:SetFont( "$(MEDIUM_FONT)|$(KB_20)" )
		ui.RollLabel:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		ui.RollLabel:SetVerticalAlignment( TEXT_ALIGN_CENTER )
		ui.RollLabel:SetAnchor( TOPLEFT, ui.YawLabel, BOTTOMLEFT, 0, 10 )
		ui.RollLabel:SetDimensions( 48, 25 )

		ui.RollBackdrop = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "RollBackdrop", ui.OrientationGroup, "ZO_EditBackdrop" )
		ui.RollBackdrop:SetAnchor( TOPLEFT, ui.RollLabel, TOPRIGHT, 5, 0 )
		ui.RollBackdrop:SetDimensions( 60, 25 )

		ui.RollField = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "RollField", ui.RollBackdrop, "ZO_DefaultEditForBackdrop" ) 
		ui.RollField:SetFont( "$(CHAT_FONT)|$(KB_18)" )
		ui.RollField:SetAnchor( TOPLEFT, ui.RollBackdrop, TOPLEFT, 1, 0 )
		ui.RollField:SetAnchor( BOTTOMRIGHT, ui.RollBackdrop, BOTTOMRIGHT, -1, 0 )
		ui.RollField:SetHandler( "OnFocusLost", EHT.UI.PositionDialogChanged )
		ui.RollField:SetMaxInputChars( 6 )


		-- FXGroup

		ui.FXGroup = EHT.CreateControl( prefix .. "FXGroup", ui.ControlGroup, CT_CONTROL )
		ui.FXGroup:SetAnchor( LEFT, ui.OrientationGroup, RIGHT, 16, 0 )
		ui.FXGroup:SetResizeToFitDescendents( true )

		ui.ColorLabel = EHT.CreateControl( prefix .. "ColorLabel", ui.FXGroup, CT_LABEL )
		ui.ColorLabel:SetText( "Color (RGB)" )
		ui.ColorLabel:SetFont( "$(MEDIUM_FONT)|$(KB_20)" )
		ui.ColorLabel:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		ui.ColorLabel:SetVerticalAlignment( TEXT_ALIGN_CENTER )
		ui.ColorLabel:SetAnchor( TOPLEFT, ui.FXGroup, TOPLEFT, 0, 0 )
		ui.ColorLabel:SetDimensions( 48, 25 )

		ui.ColorBackdrop = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "ColorBackdrop", ui.FXGroup, "ZO_EditBackdrop" )
		ui.ColorBackdrop:SetAnchor( TOPLEFT, ui.ColorLabel, TOPRIGHT, 5, 0 )
		ui.ColorBackdrop:SetDimensions( 60, 25 )

		ui.ColorField = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "ColorField", ui.ColorBackdrop, "ZO_DefaultEditForBackdrop" )
		ui.ColorField:SetMaxInputChars( 6 )
		ui.ColorField:SetFont( "$(CHAT_FONT)|$(KB_18)" )
		ui.ColorField:SetAnchor( TOPLEFT, ui.ColorBackdrop, TOPLEFT, 1, 0 )
		ui.ColorField:SetAnchor( BOTTOMRIGHT, ui.ColorBackdrop, BOTTOMRIGHT, -1, 0 )
		ui.ColorField:SetHandler( "OnFocusLost", EHT.UI.PositionDialogChanged )

		ui.SizeLabel = EHT.CreateControl( prefix .. "SizeLabel", ui.FXGroup, CT_LABEL )
		ui.SizeLabel:SetText( "Size (X x Y x Z)" )
		ui.SizeLabel:SetFont( "$(MEDIUM_FONT)|$(KB_20)" )
		ui.SizeLabel:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		ui.SizeLabel:SetVerticalAlignment( TEXT_ALIGN_CENTER )
		ui.SizeLabel:SetAnchor( TOPLEFT, ui.ColorLabel, BOTTOMLEFT, 0, 10 )
		ui.SizeLabel:SetHeight( 25 )

		ui.SizeXBackdrop = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "SizeXBackdrop", ui.FXGroup, "ZO_EditBackdrop" )
		ui.SizeXBackdrop:SetAnchor( TOPLEFT, ui.SizeLabel, BOTTOMLEFT, 0, 10 )
		ui.SizeXBackdrop:SetDimensions( 38, 25 )

		ui.SizeXField = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "SizeXField", ui.SizeXBackdrop, "ZO_DefaultEditForBackdrop" ) 
		ui.SizeXField:SetFont( "$(CHAT_FONT)|$(KB_18)" )
		ui.SizeXField:SetAnchor( TOPLEFT, ui.SizeXBackdrop, TOPLEFT, 1, 0 )
		ui.SizeXField:SetAnchor( BOTTOMRIGHT, ui.SizeXBackdrop, BOTTOMRIGHT, -1, 0 )
		ui.SizeXField:SetHandler( "OnFocusLost", EHT.UI.PositionDialogChanged )
		ui.SizeXField:SetMaxInputChars( 6 )

		ui.SizeYBackdrop = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "SizeYBackdrop", ui.FXGroup, "ZO_EditBackdrop" )
		ui.SizeYBackdrop:SetAnchor( LEFT, ui.SizeXBackdrop, RIGHT, 8, 0 )
		ui.SizeYBackdrop:SetDimensions( 38, 25 )

		ui.SizeYField = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "SizeYField", ui.SizeYBackdrop, "ZO_DefaultEditForBackdrop" ) 
		ui.SizeYField:SetFont( "$(CHAT_FONT)|$(KB_18)" )
		ui.SizeYField:SetAnchor( TOPLEFT, ui.SizeYBackdrop, TOPLEFT, 1, 0 )
		ui.SizeYField:SetAnchor( BOTTOMRIGHT, ui.SizeYBackdrop, BOTTOMRIGHT, -1, 0 )
		ui.SizeYField:SetHandler( "OnFocusLost", EHT.UI.PositionDialogChanged )
		ui.SizeYField:SetMaxInputChars( 6 )

		ui.SizeZBackdrop = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "SizeZBackdrop", ui.FXGroup, "ZO_EditBackdrop" )
		ui.SizeZBackdrop:SetAnchor( LEFT, ui.SizeYBackdrop, RIGHT, 8, 0 )
		ui.SizeZBackdrop:SetDimensions( 38, 25 )

		ui.SizeZField = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "SizeZField", ui.SizeZBackdrop, "ZO_DefaultEditForBackdrop" ) 
		ui.SizeZField:SetFont( "$(CHAT_FONT)|$(KB_18)" )
		ui.SizeZField:SetAnchor( TOPLEFT, ui.SizeZBackdrop, TOPLEFT, 1, 0 )
		ui.SizeZField:SetAnchor( BOTTOMRIGHT, ui.SizeZBackdrop, BOTTOMRIGHT, -1, 0 )
		ui.SizeZField:SetHandler( "OnFocusLost", EHT.UI.PositionDialogChanged )
		ui.SizeZField:SetMaxInputChars( 6 )


		ui.CloseButton = EHT.CreateControl( prefix .. "CloseButton", ui.Window, CT_LABEL )
		ui.CloseButton:SetAnchor( BOTTOMRIGHT, ui.ItemLabel, TOPRIGHT, -5, -5 )
		ui.CloseButton:SetColor( 1, 1, 1, 1 )
		ui.CloseButton:SetFont( "$(BOLD_FONT)|$(KB_18)|soft-shadow-thick" )
		ui.CloseButton:SetText( "Close" )
		ui.CloseButton:SetMouseEnabled( true )
		ui.CloseButton:SetHandler( "OnMouseDown", function() EHT.UI.HidePositionDialog() end )

		ui.Window:SetHandler( "OnMoveStop", function() EHT.UI.SaveDialogSettings( windowName, ui.Window ) end )
		ui.Window:SetHandler( "OnResizeStop", adjustDimensions )


		EHT.UI.PositionDialog = ui

		adjustDimensions()

	end

	return ui

end


function EHT.UI.ShowPositionDialog( furnitureId )

	if EHT.Biz.IsUninterruptableProcessRunning( true ) then return nil end

	if nil == furnitureId then

		local house, group = EHT.Data.GetCurrentHouse()
		if nil == house or nil == group then return end

		furnitureId = HousingEditorGetSelectedFurnitureId()
		if nil ~= furnitureId then
			d( "Please place the furniture first." )
			EHT.UI.PlaySoundFailure()
			EHT.UI.HidePositionDialog()

			return
		end

		local effect, _, effectDistance = EHT.World:GetReticleTargetEffect()

		if HousingEditorCanSelectTargettedFurniture() then
			EHT.Interop.SuspendFurnitureSnap()

			local currentEditorMode = GetHousingEditorMode()

			LockCameraRotation( true )
			HousingEditorSelectTargettedFurniture()
			furnitureId = HousingEditorGetSelectedFurnitureId()
			HousingEditorRequestModeChange( HOUSING_EDITOR_MODE_DISABLED )
			LockCameraRotation( false )

			if currentEditorMode ~= HOUSING_EDITOR_MODE_DISABLED then HousingEditorRequestModeChange( currentEditorMode ) end

			EHT.Interop.ResumeFurnitureSnap()
		end

		if effect and not furnitureId then
			furnitureId = effect:GetRecordId()
		elseif effect and furnitureId then
			local x, y, z = EHT.Housing.GetFurniturePosition( furnitureId )
			local pX, pY, pZ = EHT.World:GetPlayerPosition()
			if effectDistance < zo_distance3D( x, y, z, pX, pY, pZ ) then
				furnitureId = effect:GetRecordId()
			end
		end

		if nil == furnitureId then
			if EHT.UI.PositionDialog and EHT.UI.PositionDialog.Window:IsHidden() then
				EHT.UI.DisplayNotification( "You must target (point at) an item." )
				EHT.UI.PlaySoundFailure()
			end

			EHT.UI.HidePositionDialog()
			return
		end

	end

	EHT.PositionItemId = furnitureId

	if nil == EHT.UI.PositionDialog then
		EHT.UI.SetupPositionDialog()
	end

	if not isUIHidden and EHT.UI.PositionDialog.Window:IsHidden() then
		EHT.UI.PositionDialog.Window:SetHidden( false )
	end

	EHT.UI.HideEHTButtonContextMenu()
	EHT.UI.HideEHTEffectsButtonContextMenu()
	EHT.UI.RefreshPositionDialog()
end


------[[ Dialog : Animation ]]------

function EHT.UI.CanEditAnimation()
	return not EHT.Biz.IsUninterruptableProcessRunning(false)
end

function EHT.UI.GetSelectedFrameSound()
	local c = EHT.UI.ToolDialog.FrameSound
	if nil == c then return nil end

	local soundId = c:GetSelectedItem()
	if nil ~= soundId and string.sub( soundId, 1, 4 ) == "    " then
		return string.sub( soundId, 5 )
	end

	return nil
end

do
	local sortedSounds

	function EHT.UI.GetSoundsSorted()
		if nil == sortedSounds then
			sortedSounds = { }

			for sound in pairs( EHT.Sounds ) do
				table.insert( sortedSounds, sound )
			end

			table.sort( sortedSounds )
		end

		return sortedSounds

	end
	
	function findSoundId( search )

		search = string.lower( search )
		local matches = 0

		d( "____________" )
		d( "Searching..." )

		for _, soundId in pairs( EHT.UI.GetSoundsSorted() ) do
			if string.find( string.lower( soundId ), search ) then
				d( soundId )
				matches = matches + 1
			end
		end

		df( "%d sounds found.", matches )

	end

	SLASH_COMMANDS[ "/findsound" ] = findSoundId

end


function EHT.UI.UpdateFrameSoundsList()

	local recents = EHT.SavedVars.RecentlyUsedFrameSounds
	local c = EHT.UI.ToolDialog.FrameSound
	if nil == c then return end

	EHT.Biz.SuppressSceneFrameSound( true )

	c:ClearItems()

	local sounds = EHT.UI.GetSoundsSorted()

	local function ResetList()
		c:SelectFirstItem()
	end

	c:AddItem( "Add a sound effect to this frame...", EHT.Biz.UpdateSceneFrameSound )
	c:AddItem( "", ResetList )
	c:AddItem( "  Recently Used Sounds...", ResetList )
	if "table" == type( recents ) then
		for _, soundId in ipairs( recents ) do
			c:AddItem( string.format( "    %s", soundId ), EHT.Biz.UpdateSceneFrameSound )
		end
	end
	c:AddItem( "", ResetList )
	c:AddItem( "  All Sounds...", ResetList )
	for _, soundId in ipairs( sounds ) do
		c:AddItem( string.format( "    %s", soundId ), EHT.Biz.UpdateSceneFrameSound )
	end
	ResetList()

	EHT.Biz.SuppressSceneFrameSound( false )

end


function EHT.UI.AddRecentFrameSound( soundId )

	if nil == soundId or "" == soundId then return false end

	local recents = EHT.SavedVars.RecentlyUsedFrameSounds
	if nil == recents then
		recents = { }
		EHT.SavedVars.RecentlyUsedFrameSounds = recents
	end

	for index, sound in ipairs( recents ) do
		if sound == soundId then
			return false
		end
	end

	if #recents >= EHT.CONST.MAX_RECENT_SOUNDS then
		table.remove( recents, EHT.CONST.MAX_RECENT_SOUNDS )
	end

	table.insert( recents, 1, soundId )
	EHT.UI.UpdateFrameSoundsList()

	return true

end


function EHT.UI.RefreshAnimationDialog()

	local ui = EHT.UI.ToolDialog
	if nil == ui then return end

	if EHT.CONST.TOOL_TABS.ANIMATE ~= EHT.UI.GetCurrentToolTab() then return end

	local house, group, scene, frame = EHT.Data.GetCurrentHouse()
	local frameIndex, minFrame, maxFrame = 1, 1, 1

	if not ui.EditSceneGroup:IsHidden() then

		if nil ~= scene then
			ui.CurrentScene:SetText( string.upper( scene.Name or EHT.CONST.SCENE_DEFAULT ) )

			if nil ~= scene.Frames and 0 < #scene.Frames then maxFrame = #scene.Frames end
			frameIndex = scene.FrameIndex or 1

			ZO_CheckButton_SetCheckState( ui.LoopToggle, scene.Loop )

			local isPlaying = EHT.Biz.GetProcess() == EHT.PROCESS_NAME.PLAY_SCENE
			local isRecording = EHT.RecordingSceneFrames

			ui.RewindButton:SetEnabled( not isRecording and 1 ~= frameIndex )
			ui.StopButton:SetEnabled( isRecording or ( isPlaying and not EHT.ProcessData.SingleFrame ) )
			ui.PlayButton:SetEnabled( not isRecording and not isPlaying )
			ui.RecordButton:SetEnabled( not isRecording and not isPlaying )
		end

		local isEditable = frameIndex <= maxFrame and 0 < frameIndex

		ui.FrameIndex:SetMinMax( minFrame, maxFrame )
		ui.FrameIndex:SetValue( frameIndex )
		ui.FrameIndex:SetEnabled( not isEditMode )

		ui.FrameIndexMinLabel:SetText( tostring( minFrame) )
		ui.FrameIndexMaxLabel:SetText( tostring( maxFrame) )
		ui.FrameIndexLabel:SetText( "Frame  |cffffc9" .. tostring( frameIndex ) .. "|r" )

		ui.InsertBeforeButton:SetEnabled( true )
		ui.InsertAfterButton:SetEnabled( true )
		ui.DeleteFrameButton:SetEnabled( isEditable )

		EHT.Biz.SuppressSceneFrameSound( true )

		if nil ~= frame then
			ui.FrameDuration:SetText( string.format( "%.1f", ( frame.Duration or 0 ) / 1000 ) )
			if nil == frame.Sound then
				ui.FrameSound:SelectFirstItem()
			else
				ui.FrameSound:SetSelectedItem( string.format( "    %s", frame.Sound ) )
			end
		else
			ui.FrameDuration:SetText( string.format( "%.1f", EHT.CONST.SCENE_FRAME_DURATION_DEFAULT / 1000 ) )
			ui.FrameSound:SelectFirstItem()
		end

		EHT.Biz.SuppressSceneFrameSound( false )

	else

		EHT.UI.RefreshAnimationDialogSavedScenes()

	end

end


function EHT.UI.RefreshAnimationDialogSavedScenes()

	local ui = EHT.UI.ToolDialog
	if nil == ui then return end

	ui.LoadScenes:ClearItems()
	ui.SaveScenes:ClearItems()
	ui.MergeScenes:ClearItems()
	ui.AppendScenes:ClearItems()

	ui.LoadScenes:AddItem( "" )
	ui.SaveScenes:AddItem( "" )
	ui.MergeScenes:AddItem( "" )
	ui.AppendScenes:AddItem( "" )

	local house, _, currentScene = EHT.Data.GetCurrentHouse()
	if nil == house then return end

	for sceneName, scene in pairs( house.Scenes ) do
		if nil ~= scene and nil ~= sceneName and string.lower( sceneName ) ~= string.lower( EHT.CONST.SCENE_DEFAULT ) then
			ui.LoadScenes:AddItem( sceneName )
			ui.SaveScenes:AddItem( sceneName )
			if nil == currentScene or string.lower( sceneName ) ~= string.lower( ui.CurrentScene:GetText() ) then
				ui.MergeScenes:AddItem( sceneName )
				ui.AppendScenes:AddItem( sceneName )
			end
		end
	end

	ui.LoadScenes:SetSelectedItem( "" )

	if nil ~= currentScene and string.lower( currentScene.Name ) ~= EHT.CONST.SCENE_DEFAULT then
		ui.SaveScenes:SetSelectedItem( currentScene.Name )
	else
		ui.SaveScenes:SetSelectedItem( "" )
	end

	ui.SaveSceneName:SetText( "" )

end

---[ Dialog : EHT Button Context Menu ]---

do

	local HighlightControls = { }

	local function OnContextMenuMouseEnter( control )
		local oldR, oldG, oldB, oldA

		for highlightControl, _ in pairs( HighlightControls ) do
			oldR, oldG, oldB, oldA = highlightControl.OldR or 1, highlightControl.OldG or 1, highlightControl.OldB or 1, highlightControl.OldA or 1
			highlightControl:SetColor( oldR, oldG, oldB, oldA )
			HighlightControls[ highlightControl ] = nil
		end

		local child, parent = nil, control:GetParent()
		if nil ~= parent then
			for index = 1, parent:GetNumChildren() do

				child = parent:GetChild( index )
				if nil ~= child and child:GetType() == CT_LABEL then
					HighlightControls[ child ] = true
					child.OldR, child.OldG, child.OldB, child.OldA = 1, 1, 1, 1
					child:SetColor( 1, 1, 0.3, 1 )
				end

			end
		end
	end

	local function OnContextMenuMouseExit( control )
		local oldR, oldG, oldB, oldA

		local child, parent = nil, control:GetParent()
		if nil ~= parent then
			for index = 1, parent:GetNumChildren() do

				child = parent:GetChild( index )
				if nil ~= child and HighlightControls[ child ] then
					oldR, oldG, oldB, oldA = child.OldR or 1, child.OldG or 1, child.OldB or 1, child.OldA or 1
					child:SetColor( oldR, oldG, oldB, oldA )
					HighlightControls[ child ] = nil
				end

			end
		end
	end

	function EHT.UI.AddEHTButtonContextMenuControl( control )
		local enterHandler, exitHandler

		enterHandler = control:GetHandler( "OnMouseEnter" )
		exitHandler = control:GetHandler( "OnMouseExit" )

		if enterHandler then
			control:SetHandler( "OnMouseEnter", function( ... ) OnContextMenuMouseEnter( ... ) enterHandler( ... ) end )
		else
			control:SetHandler( "OnMouseEnter", OnContextMenuMouseEnter )
		end

		if exitHandler then
			control:SetHandler( "OnMouseExit", function( ... ) OnContextMenuMouseExit( ... ) exitHandler( ... ) end )
		else
			control:SetHandler( "OnMouseExit", OnContextMenuMouseExit )
		end
	end
end

function EHT.UI.HideEHTButtonContextMenu()
	local ui = EHT.UI.EHTButtonContextMenu
	if ui then
		ui.Window:SetHidden( true )
		ui.SuppressAutoHide = false
	end
end

function EHT.UI.IsEHTButtonContextMenuHidden()
	local ui = EHT.UI.EHTButtonContextMenu
	return not ui or ui.Window:IsHidden()
end

function EHT.UI.SetupEHTButtonContextMenu( anchorPoint, anchorControl, anchorControlPoint, anchorOffsetX, anchorOffsetY )
	local ui = EHT.UI.EHTButtonContextMenu
	if nil == ui then
		ui = { }
		EHT.UI.EHTButtonContextMenu = ui
		ui.SuppressAutoHide = false

		local windowName = "EHTButtonContextMenu"
		local prefix = "EHTButtonContextMenu"
		local settings = EHT.UI.GetDialogSettings( windowName )
		local height, width, dragOffset = 580, 250, 16
		local baseDrawLevel = 1

		-- Window Controls

		local c, grp, section, frame, win, windowFrame

		local function tip( control, msg )
			EHT.UI.SetInfoTooltip( control, msg )
		end

		win = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
		ui.Window = win
		win:SetDimensionConstraints( width, height + 2 * dragOffset, width, height + 2 * dragOffset )
		win:SetHidden( true )
		win:SetAlpha( 1 )
		win:SetMovable( false )
		win:SetMouseEnabled( true )
		win:SetClampedToScreen( false )
		win:SetResizeHandleSize( 0 )
		win:SetDrawTier( DT_HIGH )
		win:SetHandler( "OnMouseEnter", function()
			zo_callLater( function()
				ui.SuppressAutoHide = false
			end, 400 )
		end )

		if nil ~= anchorPoint and nil ~= anchorControl and nil ~= anchorControlPoint then
			local offsetX, offsetY = anchorOffsetX or 0, anchorOffsetY or 0
			win:SetAnchor( anchorPoint, anchorControl, anchorControlPoint, offsetX, offsetY )
		end

		c = EHT.CreateControl( nil, win, CT_LINE )
		ui.Backdrop = c
		c:SetInheritAlpha( false )
		c:SetAnchor( TOP, win, TOP, 0, 0 )
		c:SetAnchor( BOTTOM, win, BOTTOM, 0, 0 )
		c:SetThickness( width )
		c:SetDrawLevel( baseDrawLevel - 1 )
		c:SetBlendMode( TEX_BLEND_MODE_ALPHA )

		c = EHT.CreateControl( nil, win, CT_LINE )
		ui.Separator = c
		c:SetInheritAlpha( false )
		c:SetAnchor( TOP, win, TOP, 0, 0 )
		c:SetAnchor( BOTTOM, win, BOTTOM, 0, 0 )
		c:SetThickness( 1.5 )
		c:SetDrawLevel( baseDrawLevel )
		c:SetBlendMode( TEX_BLEND_MODE_ADD )

		ui.SetAlpha = function( alpha )
			ui.Window:SetAlpha( alpha )

			local r, g, b = UnpackColor(Colors.Icon)
			ui.Backdrop:SetVertexColors( 1 + 4, r, g, b, 0.8 * alpha )
			ui.Backdrop:SetVertexColors( 2 + 8, 0.1, 0.1, 0.1, 0.6 * alpha )

			ui.Separator:SetVertexColors( 1 + 4, 1, 1, 1, alpha )
			ui.Separator:SetVertexColors( 2 + 8, 0, 0, 0, 0.8 * alpha )
		end

		ui.SetAlpha( 1 )

		windowFrame = EHT.CreateControl( prefix .. "WindowFrame", win, CT_CONTROL )
		ui[ "WindowFrame" ] = windowFrame
		windowFrame:SetAnchor( TOPLEFT, win, TOPLEFT, 10, dragOffset )
		windowFrame:SetAnchor( BOTTOMRIGHT, win, BOTTOMRIGHT, -10, -dragOffset )
		windowFrame:SetResizeToFitDescendents( true )
		windowFrame:SetDrawLevel( baseDrawLevel )

		local function onEHTButtonMouseEnter( control )
			if control == ui.DragHandle1 then ui.DragHandle1:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 5 ) end
			if control == ui.DragHandle2 then ui.DragHandle2:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 5 ) end
		end

		local function onEHTButtonMouseExit()
			ui.DragHandle1:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 1 )
			ui.DragHandle2:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 1 )
		end

		local function onEHTButtonMouseDown( control )
			if control == ui.DragHandle1 then ui.DragHandle1:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 5 ) end
			if control == ui.DragHandle2 then ui.DragHandle2:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 5 ) end
			EHT.UI.EHTButtonOnMouseDown()
		end

		local function onEHTButtonMouseUp()
			ui.DragHandle1:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 1 )
			ui.DragHandle2:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 1 )
			EHT.UI.EHTButtonOnMouseUp( nil, MOUSE_BUTTON_INDEX_LEFT, true )
		end

		win:SetHandler( "OnMouseDown", onEHTButtonMouseDown )
		win:SetHandler( "OnMouseUp", onEHTButtonMouseUp )
		ui.DragHandle1 = CreateTexture( prefix .. "DragHandle1", windowFrame, CreateAnchor( TOPLEFT, windowFrame, TOPLEFT, -8, -8 ), nil, dragOffset, dragOffset, EHT.Textures.ICON_DRAG_HANDLE, CreateColor( 1, 1, 1, 0.65 ) )
		ui.DragHandle1:SetDrawLevel( baseDrawLevel + 100 )
		ui.DragHandle1:SetMouseEnabled( true )
		ui.DragHandle1:SetTextureCoords( 0, 1, 1, 0 )
		ui.DragHandle1:SetHandler( "OnMouseEnter", onEHTButtonMouseEnter )
		ui.DragHandle1:SetHandler( "OnMouseExit", onEHTButtonMouseExit )
		ui.DragHandle1:SetHandler( "OnMouseDown", onEHTButtonMouseDown )
		ui.DragHandle1:SetHandler( "OnMouseUp", onEHTButtonMouseUp )
		ui.DragHandle2 = CreateTexture( prefix .. "DragHandle2", windowFrame, CreateAnchor( BOTTOMLEFT, windowFrame, BOTTOMLEFT, -8, -8 ), nil, dragOffset, dragOffset, EHT.Textures.ICON_DRAG_HANDLE, CreateColor( 1, 1, 1, 0.65 ) )
		ui.DragHandle2:SetDrawLevel( baseDrawLevel + 100 )
		ui.DragHandle2:SetMouseEnabled( true )
		ui.DragHandle2:SetHandler( "OnMouseEnter", onEHTButtonMouseEnter )
		ui.DragHandle2:SetHandler( "OnMouseExit", onEHTButtonMouseExit )
		ui.DragHandle2:SetHandler( "OnMouseDown", onEHTButtonMouseDown )
		ui.DragHandle2:SetHandler( "OnMouseUp", onEHTButtonMouseUp )

		local pl = EHT.CreateControl( prefix .. "PanelLeft", win, CT_CONTROL )
		ui[ "PanelLeft" ] = pl
		pl:SetAnchor( TOPLEFT, windowFrame, TOPLEFT, 0, 0 )
		pl:SetAnchor( BOTTOMRIGHT, windowFrame, BOTTOM, -10, 0 )
		pl:SetDrawLevel( baseDrawLevel )

		local pr = EHT.CreateControl( prefix .. "PanelRight", win, CT_CONTROL )
		ui[ "PanelRight" ] = pr
		pr:SetAnchor( TOPLEFT, windowFrame, TOP, 10, 0 )
		pr:SetAnchor( BOTTOMRIGHT, windowFrame, BOTTOMRIGHT, 0, 0 )
		pr:SetDrawLevel( baseDrawLevel )

		local function CreateSection( ui, window, anchorControl, anchorPosition, name, label )
			local sect = EHT.CreateControl( prefix .. name .. "Section", window, CT_CONTROL )
			ui[ name .. "Section" ] = sect
			sect:SetAnchor( TOPLEFT, anchorControl, anchorPosition == TOP and TOPLEFT or BOTTOMLEFT, 0, 6 )
			sect:SetAnchor( TOPRIGHT, anchorControl, anchorPosition == TOP and TOPRIGHT or BOTTOMRIGHT, 0, 6 )
			sect:SetResizeToFitDescendents( true )
			sect:SetWidth( width )
			sect:SetDrawLevel( baseDrawLevel )

			local lbl = EHT.CreateControl( prefix .. name .. "Label", sect, CT_LABEL )
			ui[ name .. "Label" ] = lbl
			lbl:SetFont( "$(BOLD_FONT)|$(KB_18)|soft-shadow-thick" )
			lbl:SetAnchor( TOPLEFT, sect, TOPLEFT, 0, 0 )
			lbl:SetText( label )
			lbl:SetColor(UnpackColor(Colors.LabelHeading))
			lbl:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
			lbl:SetMouseEnabled( false )
			lbl:SetDrawLevel( baseDrawLevel )

			sect.BottomControl = lbl

			return sect, lbl
		end

		local function CreateField( ui, container, textureFile, name, label, tooltip, onClick )
			local bottomControl = container.BottomControl
			local grp = EHT.CreateControl( prefix .. name .. "Group", container, CT_CONTROL )

			ui[ name .. "Group" ] = grp
			grp:SetAnchor( TOPLEFT, bottomControl, BOTTOMLEFT, 0, -1 )
			grp:SetResizeToFitDescendents( true )
			grp:SetWidth( width )
			container.BottomControl = grp

			local showIcon = textureFile and textureFile[1]
			if showIcon then
				local c = EHT.CreateControl( prefix .. name, grp, CT_TEXTURE )
				ui[ name ] = c
				local width, height = textureFile[2] or 28, textureFile[3] or 28
				c:SetDrawLevel( baseDrawLevel )
				c:SetAnchor( LEFT, grp, LEFT, 0, 0 ) --, math.floor( ( 30 - height ) * 0.5 ) )
				c:SetTexture( textureFile[1] )
				c:SetDimensions( width, height )
				c:SetTextureCoords( 0.02, 0.98, 0.02, 0.98 )
				c:SetMouseEnabled( true )
				c:SetHandler( "OnMouseDown", onClick )
				tip( c, tooltip )
			end

			local lbl = EHT.CreateControl( prefix .. name .. "Label", grp, CT_LABEL )
			ui[ name .. "Label" ] = lbl
			lbl:SetDrawLevel( baseDrawLevel )
			lbl:SetFont( "$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thick" )
			lbl:SetColor(UnpackColor(Colors.Label))
			if showIcon then
				lbl:SetAnchor( LEFT, grp, LEFT, 30, 0 )
			else
				lbl:SetAnchor( LEFT, grp, LEFT, 5, 0 )
			end
			lbl:SetText( label )
			lbl:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
			lbl:SetMouseEnabled( true )
			lbl:SetHandler( "OnMouseDown", onClick )
			tip( lbl, tooltip )

			EHT.UI.AddEHTButtonContextMenuControl( c )
			EHT.UI.AddEHTButtonContextMenuControl( lbl )

			return c, lbl
		end

		-- Edit Controls

		local lbTools = EHT.CreateControl( prefix .. "ToolsLabel", pl, CT_LABEL )
		ui[ "ToolsLabel" ] = lbTools
		lbTools:SetFont( "$(BOLD_FONT)|$(KB_22)|soft-shadow-thick" )
		lbTools:SetAnchor( TOPLEFT, pl, TOPLEFT, 0, 0 )
		lbTools:SetAnchor( TOPRIGHT, pl, TOPRIGHT, 0, 0 )
		lbTools:SetText( "Shortcuts" )
		lbTools:SetColor(UnpackColor(Colors.LabelHeading))
		lbTools:SetMouseEnabled( false )
		lbTools:SetDrawLevel( baseDrawLevel )
		lbTools:SetHorizontalAlignment( TEXT_ALIGN_CENTER )

		section = CreateSection( ui, pl, lbTools, BOTTOM, "Clipboard", "Clipboard" )
		c = CreateField( ui, section, nil, "Copy", "Copy Items", "Copies the selected items to the virtual clipboard.", EHT.UI.CopySelectionToClipboard )
		c = CreateField( ui, section, nil, "Cut", "Cut Items", "Copies the selected items to the virtual clipboard and then removes them into your inventory.", EHT.UI.CutSelectionToClipboard )
		c = CreateField( ui, section, nil, "Paste", "Paste Items", "Pastes the items in the virtual clipboard into the house using items from your inventory, bank and storage chests.", EHT.UI.PasteFromInventory )

		section = CreateSection( ui, pl, section, BOTTOM, "Lights", "Lights" )
		c = CreateField( ui, section, nil, "AllOn", "Turn All On", "Turns all \"toggled\" items ON.", function() EHT.Biz.ToggleAll( EHT.STATE.ON ) end )
		c = CreateField( ui, section, nil, "AllOff", "Turn All Off", "Turns all \"toggled\" items OFF.", function() EHT.Biz.ToggleAll( EHT.STATE.OFF ) end )

		section = CreateSection( ui, pl, section, BOTTOM, "Links", "Links" )
		c = CreateField( ui, section, nil, "Link", "Link Items", "Links the selected items together, allowing you to move the entire group instantly by adjusting the primary (parent) item.", EHT.Biz.LinkGroup )
		c = CreateField( ui, section, nil, "Unlink", "Unlink Items", "Unlinks the selected items from one another.", EHT.Biz.UnlinkGroup )
 
		section = CreateSection( ui, pl, section, BOTTOM, "Locks", "Locks" )
		c = CreateField( ui, section, nil, "Lock", "Lock Items", "Locks the selected items to prevent you from moving them.\n\nNote: Locked items are only locked for yourself - other decorators can still edit locked items.", function() EHT.Biz.LockItems() end )
		c = CreateField( ui, section, nil, "Unlock", "Unlock Items", "Unlocks the selected items to allow you to move them.\n\nNote: Locked items are only locked for yourself - other decorators can still edit locked items.", function() EHT.Biz.UnlockItems() end )

		section = CreateSection( ui, pl, section, BOTTOM, "Recovery", "Recovery" )
		c = CreateField( ui, section, nil, "Undo", "Undo", "Undo the most recent furniture move, placement or retrieval.", EHT.UI.Undo )
		c = CreateField( ui, section, nil, "Redo", "Redo", "Redo the most recently undone furniture move, placement or retrieval.", EHT.UI.Redo )
		c = CreateField( ui, section, nil, "Backups", "Backups", "Review and restore any of the automatically captured snapshots of your entire house layout in the event of an emergency.", EHT.UI.ShowBackupsDialog )

		section = CreateSection( ui, pl, section, BOTTOM, "Summon", "Summon" )
		c = CreateField( ui, section, nil, "SummonGuestJournal", "Guest Journal", "Summon the Guest Journal, if possible.", function()
			if not EHT.Effect:SummonGuestbook( true ) then
				EHT.UI.ShowConfirmationDialog( "",
					"The Guest Journal could not be summoned...\n\n" ..
					"Only Open Houses have Guest Journals. How could you expect that many guests otherwise? ;)\n\n" ..
					"|cffff00Would you like to watch the video guide?\n(approx. 1 min)",
					function() EHT.UI.ShowURL( EHT.CONST.URLS.SetupOpenHouse ) end )
			end
		end )
		c = CreateField( ui, section, nil, "SummonCrafting", "Craft Workshop", "Summon the Crafting Workshop, if possible.", EHT.UI.SummonCrafting )
		c = CreateField( ui, section, nil, "SummonStorage", "Assistants\n & Storage", "Summon Assistants and Storage, if possible.", EHT.UI.SummonStorage )

		-- Visual Controls

		local lbToggles = EHT.CreateControl( prefix .. "TogglesLabel", pl, CT_LABEL )
		ui[ "TogglesLabel" ] = lbToggles
		lbToggles:SetFont( "$(BOLD_FONT)|$(KB_22)|soft-shadow-thick" )
		lbToggles:SetAnchor( TOPLEFT, pr, TOPLEFT, 0, 0 )
		lbToggles:SetAnchor( TOPRIGHT, pr, TOPRIGHT, 0, 0 )
		lbToggles:SetText( "Options" )
		lbToggles:SetColor(UnpackColor(Colors.LabelHeading))
		lbToggles:SetMouseEnabled( false )
		lbToggles:SetDrawLevel( baseDrawLevel )
		lbToggles:SetHorizontalAlignment( TEXT_ALIGN_CENTER )

		section = CreateSection( ui, pr, lbToggles, BOTTOM, "GridLines", "Grid Lines" )
		c = CreateField( ui, section, { "esoui/art/buttons/gamepad/gp_checkbox_downover.dds" }, "GridHorizontal", "Horizontal", "Toggles the display of the horizontal grid.", EHT.UI.ToggleGuidelinesHorizontal )
		c = CreateField( ui, section, { "esoui/art/buttons/gamepad/gp_checkbox_downover.dds" }, "GridVertical", "Vertical", "Toggles the display of the vertical grid.", EHT.UI.ToggleGuidelinesVertical )
		c = CreateField( ui, section, { "esoui/art/buttons/gamepad/gp_checkbox_downover.dds" }, "GridLock", "Lock", "Locks the grid in the current position.", EHT.UI.ToggleGuidelinesLock )
		c = CreateField( ui, section, { "esoui/art/compass/ava_returnpoint_neutral.dds" }, "GridAdjustment", "Adjust", "Pans, scales or rotates the grid.", EHT.UI.ShowAdjustGuidelinesDialog )

		section = CreateSection( ui, pr, section, BOTTOM, "SnapToGrid", "Snap to Grid" )
		c = CreateField( ui, section, { "esoui/art/buttons/gamepad/gp_checkbox_downover.dds" }, "GridSnapHorizontal", "Horizontal", "Toggles the automatic snapping of items to the horizontal grid.", EHT.UI.ToggleGuidelinesSnapHorizontal )
		c = CreateField( ui, section, { "esoui/art/buttons/gamepad/gp_checkbox_downover.dds" }, "GridSnapVertical", "Vertical", "Toggles the automatic snapping of items to the vertical grid.", EHT.UI.ToggleGuidelinesSnapVertical )
		c = CreateField( ui, section, { "esoui/art/buttons/gamepad/gp_checkbox_downover.dds" }, "GridSnapRotation", "Rotation", "Toggles the automatic snapping of item rotation to the horizontal grid.", EHT.UI.ToggleGuidelinesSnapRotation )

		section = CreateSection( ui, pr, section, BOTTOM, "Select", "Selection" )
		c = CreateField( ui, section, { "esoui/art/buttons/gamepad/gp_checkbox_downover.dds" }, "SelectBox", "Box", "Toggles the display of the bounding box encompassing all selected items.", EHT.UI.ToggleSelectionBox )
		c = CreateField( ui, section, { "esoui/art/buttons/gamepad/gp_checkbox_downover.dds" }, "SelectCheck", "Checks", "Toggles the display of the check mark on each selected item.", EHT.UI.ToggleSelectionIndicators )
		c = CreateField( ui, section, { "esoui/art/buttons/gamepad/gp_checkbox_downover.dds" }, "SelectEffect", "FX Buckets", "Toggles the display of the paint bucket on each selectable effect.", EHT.UI.ToggleSelectionPaintBuckets )

		section = CreateSection( ui, pr, section, BOTTOM, "Environment", "Environment" )
		c = CreateField( ui, section, { "esoui/art/buttons/gamepad/gp_checkbox_downover.dds" }, "NightMode", "Night Mode", "Adjusts the environment to approximate night time light levels.\n\nNote that guests will not see this adjustment. Use any of the \"Brightness\" Lighting FX to adjust lighting for yourself and guests.", EHT.UI.ToggleNightMode )

		--section = CreateSection( ui, pr, section, BOTTOM, "Edit", "Editing" )
		--c = CreateField( ui, section, { "esoui/art/buttons/gamepad/gp_checkbox_downover.dds" }, "EasySlide", "EasySlide", "EasySlide(tm) allows you to |c00ffffClick and Hold|r items to drag them in a straight line along any axis.", EHT.UI.ToggleEasySlide )

		local l
		local launchQuickTips = function() EHT.UI.ShowToolDialog() EHT.UI.ShowNextTutorial( true ) end
		local launchTutorialVideos = function() EHT.UI.ShowURL( EHT.ADDON_HELP_URL ) end

		section, l = CreateSection( ui, pr, section, BOTTOM, "Help", "Help!" )
		l:SetMouseEnabled( true )
		l:SetHandler( "OnMouseDown", launchTutorialVideos )
		c = CreateField( ui, section, nil, "QuickTips", "|cffff66Quick Tips|r  " .. zo_iconFormat( EHT.Textures.ICON_HELP, 14, 14 ), "Quick tips about whichever part of EHT is open.", launchQuickTips )
		c = CreateField( ui, section, nil, "Tutorials", "|cffff66Tutorials|r  " .. zo_iconFormat( EHT.Textures.ICON_YOUTUBE, 16, 15 ), "Watch the tutorial video playlist on YouTube.", launchTutorialVideos )
		c = CreateField( ui, section, nil, "FixMyFX", "Fix My FX", "Click this if you are experiencing issues with visual FX including invisible FX, distorted FX or FX that are visible through walls and terrain.", function() local FORCE_PROMPT = true EHT.UI.ShowEffectsRelatedSettingsAdjustmentPrompt( FORCE_PROMPT ) end )

		EHT.UI.RefreshEditToggles()

	end

	return ui

end


------[[ Dialog : EHT Effects Button Context Menu ]]------


do

	local DEFAULT_SEARCH = "search"
	local baseDrawLevel = 1
	local placedPool = { Active = { }, Inactive = { } }
	local receivedPool = { Active = { }, Inactive = { } }
	local allEffects = { }
	local listEffects = { }
	local sortedEffects = { }
	local effectsSections = { }
	local sortedReceivedEffects = { }
	local previewEffect, queuedPreviewEffectName
	local isAddTab, isPlacedTab, isShareTab = true, false, false

	local function OnPlacedEffectClicked( item )
		if item and item.Value then
			local editor = EHT.GetEffectEditor()
			if not editor:CheckEditEffectPermission() then return end

			if not EHT.Housing.IsSelectionMode() then
				HousingEditorRequestModeChange( HOUSING_EDITOR_MODE_SELECTION )
			end

			editor:BindToEffect( item.Value )
			editor:ShowEditor()
		end
	end

	local function EffectDistanceComparer( e1, e2 )
		return ( e1.Distance or 0 ) < ( e2.Distance or 0 )
	end

	local function DeleteDynamicLabel( pool, key )
		local label = pool.Active[key]
		if label then
			label:SetHidden( true )
			pool.Active[key] = nil
			table.insert( pool.Inactive, label )
		end
	end

	local function CreateDynamicLabel( pool, key, parent, text, onClick )
		local label = pool.Active[key]
		if not label then
			label = table.remove( pool.Inactive, 1 )
			if not label then
				label = EHT.CreateControl( nil, parent, CT_LABEL )
				label:SetDrawLevel( baseDrawLevel )
				label:SetFont( "$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thick" )
				label:SetColor( 1, 1, 1, 1 )
				label:SetMaxLineCount( 3 )
				label:SetMouseEnabled( true )
			end
		end
		pool.Active[key] = label

		label.Key = key
		label.Updated = true
		label:ClearAnchors()
		label:SetText( text )
		label:SetHandler( "OnMouseDown", onClick )
		label:SetHidden( false )

		return label
	end

	local function BeginDynamicLabelUpdates( pool )
		for _, label in pairs( pool.Active ) do
			label.Updated = false
		end
	end

	local function CommitDynamicLabelUpdates( pool )
		for key, label in pairs( pool.Active ) do
			if not label.Updated then DeleteDynamicLabel( pool, key ) end
		end
	end

	local function RefreshScrollPanel()
		EVENT_MANAGER:UnregisterForUpdate( "EHTEffectsRefreshScrollPanel" )
	end

	local initalTabOpening = true

	local function GetCurrentTab()
		local ui = EHT.UI.EHTEffectsButtonContextMenu
		local addPanel = ui.AddEffectsPanel
		local placedPanel = ui.PlacedEffectsPanel
		local sharePanel = ui.ShareEffectsPanel

		return	not addPanel:IsHidden() and 1 or
				not placedPanel:IsHidden() and 2 or
				not sharePanel:IsHidden() and 3
	end

	local function ToggleTab( tabId )
		local ui = EHT.UI.EHTEffectsButtonContextMenu
		local addPanel = ui.AddEffectsPanel
		local placedPanel = ui.PlacedEffectsPanel
		local sharePanel = ui.ShareEffectsPanel

		if tabId ~= 3 and EHT.EffectUI.IsPreviewingEffects() then
			-- Force the player to remain on the Share tab until the Effects Preview is concluded.
			tabId = 3
		end

		isAddTab, isPlacedTab, isShareTab = 1 == tabId, 2 == tabId, 3 == tabId

		addPanel:SetHidden( not isAddTab )
		placedPanel:SetHidden( not isPlacedTab )
		sharePanel:SetHidden( not isShareTab )

		ui.SearchEffectsBackdrop:SetHidden( not isAddTab and not isPlacedTab )
		ui.NumEffects:SetHidden( not isAddTab and not isPlacedTab )
		ui.ShareEffectsTip:SetHidden( not isShareTab )

		if isAddTab then
			addPanel:SetParent( ui.ScrollPanel )
			SetColor( ui.AddEffectsBackdrop, Colors.ControlBox ) -- :SetColor( 0.05, 0.45, 0.45, 1 )
		else
			addPanel:SetParent( nil )
			SetColor( ui.AddEffectsBackdrop, Colors.ListBackdrop ) -- :SetColor( 0, 0.2, 0.2, 1 )
		end

		if isPlacedTab then
			placedPanel:SetParent( ui.ScrollPanel )
			SetColor( ui.PlacedEffectsBackdrop, Colors.ControlBox ) -- :SetColor( 0.05, 0.45, 0.45, 1 )
			EHT.UI.RefreshPlacedEffectsList()
		else
			placedPanel:SetParent( nil )
			SetColor( ui.PlacedEffectsBackdrop, Colors.ListBackdrop ) -- :SetColor( 0, 0.2, 0.2, 1 )
		end

		if isShareTab then
			sharePanel:SetParent( ui.ScrollPanel )
			SetColor( ui.ShareEffectsBackdrop, Colors.ControlBox ) -- :SetColor( 0.05, 0.45, 0.45, 1 )
		else
			sharePanel:SetParent( nil )
			SetColor( ui.ShareEffectsBackdrop, Colors.ListBackdrop ) -- :SetColor( 0, 0.2, 0.2, 1 )
		end

		if isAddTab or isPlacedTab then
			EHT.UI.RefreshEffectsList()
		end

		if not initalTabOpening then
			PlayUISound( "Market_PurchaseSelected" )
		else
			initalTabOpening = false
		end
	end

	local function StopFlashingSearchEffects()
		EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.FlashSearchEffects" )

		local ui = EHT.UI.EHTEffectsButtonContextMenu
		if ui then
			local c = ui.SearchEffectsBackdrop
			if c then
				c:SetCenterColor( 0, 0, 0, 1 )
				c:SetEdgeColor( 0, 0, 0, 1 )
				c.FlashState = false
			end
		end
	end

	local function FlashSearchEffects()
		local ui = EHT.UI.EHTEffectsButtonContextMenu
		local forceOff = false

		if not ui or ui.Window:IsHidden() then
			forceOff = true
			StopFlashingSearchEffects()
			return
		end

		local c = ui.SearchEffectsBackdrop
		if c then
			if forceOff or not c.FlashState then
				c:SetCenterColor( 0, 0, 0, 1 )
				c:SetEdgeColor( 0, 0, 0, 1 )
				c.FlashState = true
			else
				c:SetCenterColor( 1, 1, 1, 1 )
				c:SetEdgeColor( 1, 1, 1, 1 )
				c.FlashState = false
			end
		end
	end

	function OnSearchEffectsChanged()
		local ui = EHT.UI.EHTEffectsButtonContextMenu

		if not ui or ui.Window:IsHidden() then
			StopFlashingSearchEffects()
			return
		end

		local c = ui.SearchEffects
		local s = c and string.lower( EHT.Util.Trim( c:GetText() ) ) or ""

		if s and "" ~= s and s ~= DEFAULT_SEARCH then
			EVENT_MANAGER:RegisterForUpdate( "EHT.UI.FlashSearchEffects", 500, FlashSearchEffects )
		else
			if c and "" == s and not c:HasFocus() then
				c:SetText( DEFAULT_SEARCH )
			end

			EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.FlashSearchEffects" )
		end
	end

	local function CompareEffects( a, b )
		return string.lower( a.Value ) < string.lower( b.Value )
	end

	local function RefreshAddEffectsList()
		local ui = EHT.UI.EHTEffectsButtonContextMenu
		local list = ui.AddEffectsPanel
		local filter = string.lower( EHT.Util.Trim( ui.SearchEffects:GetText() ) )
		local all, shown = allEffects, { }
		local numEffects = 0

		listEffects = shown
		if "" == filter or filter == string.lower( DEFAULT_SEARCH ) then
			filter = nil
		end

		for index, section in ipairs( all ) do
			if not filter then
				table.insert( shown, section )
			end

			if ( not filter and section.Visible ) or ( filter and "Recently Used" ~= section.Value ) then
				local children = section.Children

				for index, effect in ipairs( children ) do
					if ( not filter and effect.Visible ) or ( filter and PlainStringFind( string.lower( effect.Label ), filter ) ) then
						table.insert( shown, effect )
						numEffects = numEffects + 1
					end
				end
			end
		end

		if filter then
			table.sort( shown, CompareEffects )
		end

		list:SetItems( shown )
		list:RefreshList()
		ui.NumEffects:SetText( string.format( "%d effect%s", numEffects, 1 ~= numEffects and "s" or "" ) )
		OnSearchEffectsChanged()
	end

	function EHT.UI.RefreshPlacedEffectsList()
		if not EHT.Housing.IsHouseZone() then
			EVENT_MANAGER:UnregisterForUpdate( "RefreshPlacedEffectsList" )
			return
		end

		if 2 ~= GetCurrentTab() then
			return
		end

		local ui = EHT.UI.EHTEffectsButtonContextMenu
		local effects = EHT.Effect:GetAll()
		local filter = string.lower( EHT.Util.Trim( ui.SearchEffects:GetText() ) )
		local numEffects = 0
		local label, value

		if "" == filter or filter == string.lower( DEFAULT_SEARCH ) then
			filter = nil
		end

		for index, effect in ipairs( effects ) do
			if not effect.EffectType:IsReserved() then
				if ( not filter and effect.Active ) or ( filter and PlainStringFind( string.lower( effect.EffectType.Name ) .. " " .. string.lower( effect.EffectType.Submitter or "" ), filter ) ) then
					numEffects = numEffects + 1

					local item = sortedEffects[numEffects]
					if not item then
						item = { ClickHandler = OnPlacedEffectClicked }
						sortedEffects[numEffects] = item
					end

					local name = effect.EffectType.Name
					local distance = effect:GetPlayerDistance() / 100
					local group = tonumber(effect:GetEffectGroupBitmask())
					if group and 0 < group then
						local groupId = EHT.Housing.GetEffectGroupId(group)
						if "number" == type(groupId) then
							group = string.format("(|c00ffffGroup %d|cffffff) ", 1 - EHT.CONST.EFFECT_GROUP_ID_MIN + groupId)
						else
							group = ""
						end
					else
						group = ""
					end

					item.Label = string.format( "(|cffff00%.1fm|cffffff) |cffffff%s%s", distance, group, name )
					item.Value = effect
					item.Distance = distance
				end
			end
		end

		for index = #sortedEffects, numEffects + 1, -1 do
			table.remove( sortedEffects, index )
		end

		table.sort( sortedEffects, EffectDistanceComparer )

		ui.PlacedEffectsPanel:SetItems( sortedEffects )
		ui.PlacedEffectsPanel:RefreshList()
		ui.NumEffects:SetText( string.format( "%d effect%s", numEffects, 1 ~= numEffects and "s" or "" ) )
		OnSearchEffectsChanged()
	end

	function EHT.UI.RefreshEffectsList()
		local tabId = GetCurrentTab()

		if 1 == tabId then
			return RefreshAddEffectsList()
		elseif 2 == tabId then
			return EHT.UI.RefreshPlacedEffectsList()
		end
	end

	local function ToggleEffectCategory( toggled )
		toggled = toggled.Value

		for index, section in ipairs( allEffects ) do
			if toggled == section.Value then
				section.Visible = not section.Visible
			else
				section.Visible = false
			end
		end

		RefreshAddEffectsList()
	end

	local function CreateSection( label, level, ui, parent, anchorControl, anchorPosition, anchorOffsetX, anchorOffsetY )
		if nil == anchorControl then anchorControl = parent end

		local indent = 0
		if anchorControl == parent then indent = 10 end

		if nil == ui.EffectCategories then ui.EffectCategories = {} end

		local lbl = EHT.CreateControl( nil, parent, CT_LABEL )
		table.insert( ui.EffectCategories, lbl )
		lbl:SetFont( "$(BOLD_FONT)|$(KB_18)|soft-shadow-thick" )
		lbl:SetSimpleAnchor( anchorControl, 0, 5 )
		lbl:SetText( label )
		lbl:SetColor( 1 == level and 0.5 or 0.75, 1, 1, 1 )
		lbl:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		lbl:SetDrawLevel( baseDrawLevel )

		local sect = EHT.CreateControl( nil, parent, CT_CONTROL )
		sect:SetSimpleAnchor( lbl, 0, 25 )
		sect:SetResizeToFitDescendents( true )
		sect:SetWidth( width )
		sect:SetDrawLevel( baseDrawLevel )
		sect:SetHidden( true )
		sect.BottomControl = nil

		table.insert( effectsSections, { Heading = lbl, Section = sect } )

		lbl:SetMouseEnabled( true )
		lbl:SetHandler( "OnMouseDown", function() ToggleEffectsCategory( sect ) end )

		return sect, lbl
	end

	local function CreateField( ui, container, label, onClick, bold, recordId, onMouseEnter, onMouseExit )
		local bottomControl = container.BottomControl
		local lbl = EHT.CreateControl( nil, container, CT_LABEL )
		container.BottomControl = lbl

		lbl.RecordId = recordId
		lbl:SetDrawLevel( baseDrawLevel )
		if not bold then
			lbl:SetFont( "$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thick" )
		else
			lbl:SetFont( "$(BOLD_FONT)|$(KB_16)|soft-shadow-thick" )
		end
		if bottomControl then
			lbl:SetAnchor( TOPLEFT, bottomControl, BOTTOMLEFT, 0, 0 )
		else
			lbl:SetAnchor( TOPLEFT, bottomControl, TOPLEFT, 10, 0 )
		end
		lbl:SetText( label )
		lbl:SetColor( 1, 1, 1, 1 )
		lbl:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		lbl:SetMouseEnabled( true )
		lbl:SetHandler( "OnMouseDown", onClick )
		lbl:SetHandler( "OnMouseEnter", onMouseEnter )
		lbl:SetHandler( "OnMouseExit", onMouseExit )
		EHT.UI.AddEHTButtonContextMenuControl( lbl )

		return lbl
	end

	function EHT.UI.HideEHTEffectsButtonContextMenu()
		local ui = EHT.UI.EHTEffectsButtonContextMenu
		EHT.UI.ClearDialogHidden( EHT.CONST.DIALOG.FXMENU )
		if ui and ui.Window then ui.Window:SetHidden( true ) end
		if EHT.EffectUI.IsPreviewingEffects() then
			EHT.UI.ShowEffectsPreviewDialog()
		end
	end

	local function PreviewEffect()
		if previewEffect then
			if previewEffect.Active then
				previewEffect:Delete()
				return
			end

			if not previewEffect.Deleted or ( previewEffect.Particles and 0 < #previewEffect.Particles ) then
				return
			end

			previewEffect = nil
			return
		end

		EVENT_MANAGER:UnregisterForUpdate( "EHT.PreviewEffect" )

		if queuedPreviewEffectName then
			local effectType = EHT.EffectType:GetByName( queuedPreviewEffectName )
			if effectType and effectType:UsesPreview() then
				_, previewEffect = EHT.EffectUI.AddEffect( queuedPreviewEffectName, nil, true )
			end
			queuedPreviewEffectName = nil
		end
	end

	local function RefreshRecentlyUsedEffects()
		local maxRecents = tonumber(EHT.GetSetting("MaxRecentlyUsedEffects")) or 10

		local ui = EHT.UI.EHTEffectsButtonContextMenu
		if not ui then return end

		local list = ui.RecentlyUsed
		if not list then return end

		local recents = EHT.SavedVars.RecentlyUsedEffects
		if not recents then
			recents = { }
			EHT.SavedVars.RecentlyUsedEffects = recents
		end

		for index = 1, 30 do
			local item = list[index]
			if item then
				local effect = recents[index]
				if effect and index <= maxRecents then
					item.Visible = true
					item.Label = string.format( "   |cffffff%s|r", effect )
					item.Value = effect
				else
					item.Visible = false
					item.Label = ""
					item.Value = ""
				end
			end
		end

		RefreshAddEffectsList()
	end

	local function UpdateRecentlyUsedEffects( recordId )
		local maxRecents = tonumber(EHT.GetSetting("MaxRecentlyUsedEffects")) or 10

		local newEffect = string.lower( recordId )
		if not newEffect or "" == newEffect then return end

		local recents = EHT.SavedVars.RecentlyUsedEffects
		if not recents then
			recents = { }
			EHT.SavedVars.RecentlyUsedEffects = recents
		end

		local added = false
		for index, effect in ipairs( recents ) do
			if string.lower( effect ) == newEffect then
				if 1 ~= index then
					table.remove( recents, index )
					table.insert( recents, 1, recordId )
				end

				added = true
				break
			end
		end

		if not added then
			table.insert( recents, 1, recordId )
		end

		local iters = 0
		while #recents > maxRecents or 100 < iters do
			table.remove( recents, maxRecents + 1 )
			iters = iters + 1
		end

		RefreshRecentlyUsedEffects()
	end

	local function OnEffectMouseDown( control )
		if control.Value then
			EHT.UI.CancelPreviewEffect()
			EHT.EffectUI.AddEffect( control.Value )
			UpdateRecentlyUsedEffects( control.Value )
		end
	end

	local function OnEffectMouseEnter( control )
		if control.Value then
			queuedPreviewEffectName = control.Value
			EVENT_MANAGER:RegisterForUpdate( "EHT.PreviewEffect", 250, PreviewEffect )
		end
	end

	local function OnEffectMouseExit( control )
		if control.Value then
			queuedPreviewEffectName = nil
			EVENT_MANAGER:RegisterForUpdate( "EHT.PreviewEffect", 250, PreviewEffect )
		end
	end

	function EHT.UI.CancelPreviewEffect()
		if previewEffect then
			EVENT_MANAGER:RegisterForUpdate( "EHT.PreviewEffect", 250, PreviewEffect )
		end
	end

	function EHT.UI.SetupEHTEffectsButtonContextMenu( anchorPoint, anchorControl, anchorControlPoint, anchorOffsetX, anchorOffsetY )
		local ui = EHT.UI.EHTEffectsButtonContextMenu
		if nil == ui then
			ui = { }
			EHT.UI.EHTEffectsButtonContextMenu = ui
			ui.SuppressAutoHide = false

			local windowName = "EHTEffectsButtonContextMenu"
			local prefix = "EHTEffectsButtonContextMenu"
			local settings = EHT.UI.GetDialogSettings( windowName )
			local height, width, dragOffset = 674, 310, 16

			-- Window Controls

			local c, grp, section, frame, win, windowFrame
			local function tip( control, msg )
				EHT.UI.SetInfoTooltip( control, msg )
			end

			ui.ToggleTab = ToggleTab

			win = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
			ui.Window = win
			win:SetDimensionConstraints( width, height + 2 * dragOffset, width, height + 2 * dragOffset )
			win:SetHidden( true )
			win:SetAlpha( 1 )
			win:SetMovable( false )
			win:SetMouseEnabled( true )
			win:SetClampedToScreen( false )
			win:SetResizeHandleSize( 0 )
			win:SetDrawTier( DT_HIGH )

			win:SetHandler( "OnMouseEnter", function() zo_callLater( function() ui.SuppressAutoHide = false end, 400 ) end )
			win:SetHandler( "OnShow", function() EVENT_MANAGER:RegisterForUpdate( "RefreshPlacedEffectsList", 2000, EHT.UI.RefreshPlacedEffectsList ) end )
			win:SetHandler( "OnHide", function() EVENT_MANAGER:UnregisterForUpdate( "RefreshPlacedEffectsList" ) end )
			win:SetHandler( "OnMouseDown", function() EHT.UI.EHTButtonOnMouseDown() end )
			win:SetHandler( "OnMouseUp", function() EHT.UI.EHTButtonOnMouseUp( nil, MOUSE_BUTTON_INDEX_LEFT, true, true ) end )

			if nil ~= anchorPoint and nil ~= anchorControl and nil ~= anchorControlPoint then
				local offsetX, offsetY = anchorOffsetX or 0, anchorOffsetY or 0
				win:SetAnchor( anchorPoint, anchorControl, anchorControlPoint, offsetX, offsetY )
			end

			do
				local lbl = EHT.CreateControl( prefix .. "Heading", win, CT_LABEL )
				ui.Heading = lbl
				lbl:SetDrawLevel( baseDrawLevel )
				lbl:SetFont( "$(MEDIUM_FONT)|$(KB_24)|thick-outline" )
				lbl:SetColor( 0.4, 0.9, 1, 1 )
				lbl:SetAnchor( BOTTOM, win, TOP, -5, 0 )
				lbl:SetText( "Essential Effects" )
				lbl:SetMouseEnabled( false )

				lbl = EHT.CreateControl( prefix .. "HeadingTM", win, CT_LABEL )
				ui.HeadingTM = lbl
				lbl:SetDrawLevel( baseDrawLevel )
				lbl:SetFont( "$(MEDIUM_FONT)|$(KB_9)|thick-outline" )
				lbl:SetColor( 0.3, 0.8, 0.9, 1 )
				lbl:SetAnchor( BOTTOMLEFT, ui.Heading, RIGHT, 0, 7 )
				lbl:SetText( "TM" )
				lbl:SetMouseEnabled( false )
			end

			windowFrame = EHT.CreateControl( prefix .. "WindowFrame", win, CT_CONTROL )
			ui.WindowFrame = windowFrame
			windowFrame:SetAnchor( TOPLEFT, win, TOPLEFT, 0, dragOffset )
			windowFrame:SetAnchor( BOTTOMRIGHT, win, BOTTOMRIGHT, 0, -dragOffset )
			windowFrame:SetDrawLevel( baseDrawLevel )

			local function onEHTButtonMouseEnter( control )
				if control == ui.DragHandle1 then ui.DragHandle1:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 5 ) end
				if control == ui.DragHandle2 then ui.DragHandle2:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 5 ) end
			end

			local function onEHTButtonMouseExit()
				ui.DragHandle1:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 1 )
				ui.DragHandle2:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 1 )
			end

			local function onEHTButtonMouseDown( control )
				if control == ui.DragHandle1 then ui.DragHandle1:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 5 ) end
				if control == ui.DragHandle2 then ui.DragHandle2:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 5 ) end
				EHT.UI.EHTButtonOnMouseDown()
			end

			local function onEHTButtonMouseUp()
				ui.DragHandle1:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 1 )
				ui.DragHandle2:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 1 )
				EHT.UI.EHTButtonOnMouseUp( nil, MOUSE_BUTTON_INDEX_LEFT, true, true )
			end

			win:SetHandler( "OnMouseDown", onEHTButtonMouseDown )
			win:SetHandler( "OnMouseUp", onEHTButtonMouseUp )
			ui.DragHandle1 = CreateTexture( prefix .. "DragHandle1", windowFrame, CreateAnchor( TOPLEFT, windowFrame, TOPLEFT, -8, -8 ), nil, dragOffset, dragOffset, EHT.Textures.ICON_DRAG_HANDLE, CreateColor( 1, 1, 1, 0.65 ) )
			ui.DragHandle1:SetDrawLevel( baseDrawLevel + 100 )
			ui.DragHandle1:SetMouseEnabled( true )
			ui.DragHandle1:SetTextureCoords( 0, 1, 1, 0 )
			ui.DragHandle1:SetHandler( "OnMouseEnter", onEHTButtonMouseEnter )
			ui.DragHandle1:SetHandler( "OnMouseExit", onEHTButtonMouseExit )
			ui.DragHandle1:SetHandler( "OnMouseDown", onEHTButtonMouseDown )
			ui.DragHandle1:SetHandler( "OnMouseUp", onEHTButtonMouseUp )
			ui.DragHandle2 = CreateTexture( prefix .. "DragHandle2", windowFrame, CreateAnchor( BOTTOMLEFT, windowFrame, BOTTOMLEFT, -8, -8 ), nil, dragOffset, dragOffset, EHT.Textures.ICON_DRAG_HANDLE, CreateColor( 1, 1, 1, 0.65 ) )
			ui.DragHandle2:SetDrawLevel( baseDrawLevel + 100 )
			ui.DragHandle2:SetMouseEnabled( true )
			ui.DragHandle2:SetHandler( "OnMouseEnter", onEHTButtonMouseEnter )
			ui.DragHandle2:SetHandler( "OnMouseExit", onEHTButtonMouseExit )
			ui.DragHandle2:SetHandler( "OnMouseDown", onEHTButtonMouseDown )
			ui.DragHandle2:SetHandler( "OnMouseUp", onEHTButtonMouseUp )

			c = EHT.CreateControl( prefix .. "ScrollPanel", windowFrame, CT_SCROLL )
			ui.ScrollPanel = c
			c:SetAnchor( TOPLEFT, windowFrame, TOPLEFT, 0, 70 )
			c:SetAnchor( BOTTOMRIGHT, windowFrame, BOTTOMRIGHT, 0, -60 )
			c:SetMouseEnabled( true )
			c:SetDrawLevel( baseDrawLevel )

			c = EHT.UI.List:New( prefix .. "AddEffectsPanel", ui.ScrollPanel )
			ui.AddEffectsPanel = c
			local addPanel = c
			do
				c:SetAnchor( TOPLEFT, ui.ScrollPanel, TOPLEFT, 0, 0 )
				c:SetAnchor( BOTTOMRIGHT, ui.ScrollPanel, BOTTOMRIGHT, 0, 0 )
				c:SetDrawLevel( baseDrawLevel )
				c:SetItemVerticalAlignment( TEXT_ALIGN_CENTER )
				c:SetItemFont( "$(BOLD_FONT)|$(KB_18)" )
				c:SetItemSpacing( 0 )
				c:SetItemHeight( 28 )
				c:RefreshList()
			end

			do
				c = WINDOW_MANAGER:CreateControlFromVirtual( nil, windowFrame, "ZO_EditBackdrop" )
				ui.SearchEffectsBackdrop = c
				c:SetInheritAlpha( false )
				c:SetDrawLevel( baseDrawLevel )
				c:SetAnchor( TOPLEFT, ui.ScrollPanel, BOTTOMLEFT, 0, 8 )
				c:SetDimensions( 200, 26 )
				c:SetCenterColor( 0, 0, 0, 1 )
				c:SetEdgeColor( 0, 0, 0, 1 )

				c = WINDOW_MANAGER:CreateControlFromVirtual( nil, ui.SearchEffectsBackdrop, "ZO_DefaultEditForBackdrop" )
				ui.SearchEffects = c
				c:SetInheritAlpha( false )
				c:SetFont( "$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thin" )
				c:SetDrawLevel( baseDrawLevel )
				c:SetAnchor( TOPLEFT, ui.SearchEffectsBackdrop, TOPLEFT, 4, 2 )
				c:SetAnchor( BOTTOMRIGHT, ui.SearchEffectsBackdrop, BOTTOMRIGHT, -4, -2 )
				c:SetMaxInputChars( 255 )
				c:SetMouseEnabled( true )
				c:SetText( DEFAULT_SEARCH )
				c:SetHandler( "OnMouseUp", function()
					zo_callLater( function()
						ui.SearchEffects:SelectAll()
					end, 20 )
				end )
				c:SetHandler( "OnFocusLost", RefreshAddEffectsList )
				c:SetHandler( "OnEnter", function()
					ui.SearchEffects:LoseFocus()
					EHT.UI.RefreshEffectsList()
				end )

				c = EHT.CreateControl( nil, windowFrame, CT_LABEL )
				ui.NumEffects = c
				c:SetDrawLevel( baseDrawLevel )
				c:SetFont( "$(MEDIUM_FONT)|$(KB_18)|thick-outline" )
				c:SetAnchor( TOPRIGHT, ui.ScrollPanel, BOTTOMRIGHT, 0, 8 )
				c:SetText( "" )
				c:SetColor( 0.85, 0.85, 0, 1 )
				c:SetMouseEnabled( false )
			end

			c = EHT.UI.List:New( prefix .. "PlacedEffectsPanel", ui.ScrollPanel )
			ui.PlacedEffectsPanel = c
			local placedPanel = c
			do
				c:SetHidden( true )
				c:SetAnchor( TOPLEFT, ui.ScrollPanel, TOPLEFT, 0, 0 )
				c:SetAnchor( BOTTOMRIGHT, ui.ScrollPanel, BOTTOMRIGHT, 0, 0 )
				c:SetDrawLevel( baseDrawLevel )
				c:SetItemVerticalAlignment( TEXT_ALIGN_CENTER )
				c:SetItemFont( "$(BOLD_FONT)|$(KB_18)" )
				c:SetItemSpacing( 0 )
				c:SetItemHeight( 28 )
			end

			local _, sharePanel = CreateWindowPanel( prefix .. "ShareEffectsPanel", prefix .. "ShareEffectsBackground", ui.ScrollPanel,
				CreateAnchor( TOPLEFT, ui.ScrollPanel, TOPLEFT, 0, 0 ),
				CreateAnchor( BOTTOMRIGHT, ui.ScrollPanel, BOTTOMRIGHT, 0, -56 ) )
			ui.ShareEffectsPanel = sharePanel
			sharePanel:SetDrawLevel( baseDrawLevel )
			sharePanel:SetHidden( true )

			do
				local bkd = EHT.CreateControl( nil, windowFrame, CT_TEXTURE )
				ui.AddEffectsBackdrop = bkd
				bkd:SetDrawLevel( baseDrawLevel )
				bkd:SetAnchor( TOPLEFT, windowFrame, TOPLEFT, 0, 35 )
				bkd:SetAnchor( BOTTOMRIGHT, windowFrame, TOPLEFT, 90, 70 )
				bkd:SetColor( 0, 0.2, 0.2, 1 )
				bkd:SetMouseEnabled( true )
				bkd:SetHandler( "OnMouseDown", function() ToggleTab( 1 ) end )

				local btn = EHT.CreateControl( prefix .. "AddEffects", windowFrame, CT_LABEL )
				ui.AddEffects = btn
				btn:SetDrawLevel( baseDrawLevel )
				btn:SetFont( "$(BOLD_FONT)|$(KB_18)|outline" )
				btn:SetAnchor( CENTER, bkd, CENTER, 0, 0 )
				btn:SetText( "Add" )
				btn:SetColor( 1, 1, 0.4, 1 )
				btn:SetMouseEnabled( false )
			end

			do
				local bkd = EHT.CreateControl( nil, windowFrame, CT_TEXTURE )
				ui.PlacedEffectsBackdrop = bkd
				bkd:SetDrawLevel( baseDrawLevel )
				bkd:SetAnchor( TOPLEFT, ui.AddEffectsBackdrop, TOPRIGHT, 8, 0 )
				bkd:SetAnchor( BOTTOMRIGHT, ui.AddEffectsBackdrop, BOTTOMRIGHT, 98, 0 )
				bkd:SetColor( 0, 0.2, 0.2, 1 )
				bkd:SetMouseEnabled( true )
				bkd:SetHandler( "OnMouseDown", function() ToggleTab( 2 ) end )

				local btn = EHT.CreateControl( prefix .. "PlacedEffects", windowFrame, CT_LABEL )
				ui.PlacedEffects = btn
				btn:SetDrawLevel( baseDrawLevel )
				btn:SetFont( "$(BOLD_FONT)|$(KB_18)|outline" )
				btn:SetAnchor( CENTER, bkd, CENTER, 0, 0 )
				btn:SetText( "Placed" )
				btn:SetColor( 1, 1, 0.4, 1 )
				btn:SetMouseEnabled( false )
			end

			do
				local bkd = EHT.CreateControl( nil, windowFrame, CT_TEXTURE )
				ui.ShareEffectsBackdrop = bkd
				bkd:SetDrawLevel( baseDrawLevel )
				bkd:SetAnchor( TOPLEFT, ui.PlacedEffectsBackdrop, TOPRIGHT, 8, 0 )
				bkd:SetAnchor( BOTTOMRIGHT, ui.PlacedEffectsBackdrop, BOTTOMRIGHT, 98, 0 )
				bkd:SetColor( 0, 0.2, 0.2, 1 )
				bkd:SetMouseEnabled( true )
				bkd:SetHandler( "OnMouseDown", function() ToggleTab( 3 ) end )

				local btn = EHT.CreateControl( prefix .. "ShareEffects", windowFrame, CT_LABEL )
				ui.ShareEffects = btn
				btn:SetDrawLevel( baseDrawLevel )
				btn:SetFont( "$(BOLD_FONT)|$(KB_18)|outline" )
				btn:SetAnchor( CENTER, bkd, CENTER, 0, 0 )
				btn:SetText( "Share" )
				btn:SetColor( 1, 1, 0.4, 1 )
				btn:SetMouseEnabled( false )
			end

			do
				local lbl = EHT.CreateControl( prefix .. "ShowHideEffectsLabel", windowFrame, CT_LABEL )
				ui.ShowHideEffectsLabel = lbl
				lbl:SetDrawLevel( baseDrawLevel )
				lbl:SetFont( "$(MEDIUM_FONT)|$(KB_16)|thick-outline" )
				lbl:SetAnchor( TOPLEFT, windowFrame, TOPLEFT, 25, 2 )
				lbl:SetText( "Hide FX" )
				lbl:SetColor( 1, 1, 1, 1 )
				lbl:SetMouseEnabled( true )
				lbl:SetHandler( "OnMouseDown", function()
					EHT.EffectUI.ShowHideEffects()
				end )
			end

			do
				local lbl = EHT.CreateControl( prefix .. "RemoveAllEffectsLabel", windowFrame, CT_LABEL )
				ui.RemoveAllEffectsLabel = lbl
				lbl:SetDrawLevel( baseDrawLevel )
				lbl:SetFont( "$(MEDIUM_FONT)|$(KB_16)|thick-outline" )
				lbl:SetAnchor( TOPRIGHT, windowFrame, TOPRIGHT, -10, 2 )
				lbl:SetText( "Delete All FX" )
				lbl:SetColor( 1, 1, 1, 1 )
				lbl:SetMouseEnabled( true )
				lbl:SetHandler( "OnMouseDown", function()
					if not EHT.EffectUI.DeleteAllEffects() then
						EHT.UI.ShowAlertDialog( "", "You do not have permission to remove effects from this home." )
					end
				end )
			end


			local shareControls = CreateContainer( nil, ui.ShareEffectsPanel, CreateAnchor( CENTER, ui.ShareEffectsPanel, CENTER, 0, 0 ) )
			ui.ShareEffectsControls = shareControls


			c = EHT.CreateControl( nil, shareControls, CT_CONTROL )
			ui.PublishedControls = c
			local publishedControls = c
			c:SetDrawLevel( baseDrawLevel )
			c:SetAnchorFill( shareControls )
			c:SetHidden( true )

			c = EHT.CreateControl( nil, publishedControls, CT_LABEL )
			ui.PublishedPreviewInstructions = c
			c:SetDrawLevel( baseDrawLevel + 2 )
			c:SetFont( "$(BOLD_FONT)|$(KB_17)|soft-shadow-thick" )
			c:SetAnchor( TOP, publishedControls, TOP, 0, 0 )
			c:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
			c:SetMaxLineCount( 16 )
			c:SetWidth( 280 )
			c:SetColor( 1, 1, 1, 1 )
			c:SetMouseEnabled( false )


			c = EHT.CreateControl( nil, publishedControls, CT_TEXTURE )
			ui.RevertToOriginalOutline = c
			c:SetDrawLevel( baseDrawLevel )
			c:SetAnchor( TOP, ui.PublishedPreviewInstructions, BOTTOM, 0, 24 )
			c:SetDimensions( 250, 34 )
			c:SetColor( 0.8, 0.8, 0.8, 1 )
			c:SetMouseEnabled( true )
			c:SetHandler( "OnMouseDown", function()
				EHT.UI.CancelPreviewFX()
			end )
			
			c = EHT.CreateControl( nil, ui.RevertToOriginalOutline, CT_TEXTURE )
			ui.RevertToOriginal = c
			c:SetDrawLevel( baseDrawLevel + 1 )
			c:SetAnchor( CENTER, ui.RevertToOriginalOutline, CENTER, 0, 0 )
			c:SetDimensions( 246, 30 )
			c:SetColor( 0.1, 0.3, 0.3, 1 )

			c = EHT.CreateControl( nil, ui.RevertToOriginal, CT_LABEL )
			ui.RevertToOriginalLabel = c
			c:SetDrawLevel( baseDrawLevel + 2 )
			c:SetFont( Colors.LabelFontBold )
			c:SetAnchor( CENTER, ui.RevertToOriginal, CENTER, -2, 0 )
			c:SetText( "End Preview" )
			c:SetColor( 1, 1, 0, 1 )


			c = EHT.CreateControl( nil, publishedControls, CT_TEXTURE )
			ui.AcceptPreviewOutline = c
			c:SetDrawLevel( baseDrawLevel )
			c:SetAnchor( TOP, ui.RevertToOriginalOutline, BOTTOM, 0, 18 )
			c:SetDimensions( 250, 34 )
			c:SetColor( 0.8, 0.8, 0.8, 1 )
			c:SetMouseEnabled( true )
			c:SetHandler( "OnMouseDown", function()
				EHT.UI.ShowConfirmationDialog( "", "|cffffff" ..
					"Are you sure that you want to replace your effects with this published version of your effects?\n\n" ..
					"Note that you may undo this change with:\n" ..
					"|c00ffffEHT button |cffffff|||c00ffff Undo",
					function()
						EHT.UI.AcceptPreviewFX()
					end )
			end )
			
			tip( c, "This will replace your original effects with the version that you are previewing now." )

			c = EHT.CreateControl( nil, ui.AcceptPreviewOutline, CT_TEXTURE )
			ui.AcceptPreview = c
			c:SetDrawLevel( baseDrawLevel + 1 )
			c:SetAnchor( CENTER, ui.AcceptPreviewOutline, CENTER, 0, 0 )
			c:SetDimensions( 246, 30 )
			c:SetColor( 0.1, 0.3, 0.3, 1 )

			c = EHT.CreateControl( nil, ui.AcceptPreview, CT_LABEL )
			ui.AcceptPreviewLabel = c
			c:SetDrawLevel( baseDrawLevel + 2 )
			c:SetFont( "$(BOLD_FONT)|$(KB_17)|soft-shadow-thick" )
			c:SetAnchor( CENTER, ui.AcceptPreview, CENTER, -2, 0 )
			c:SetText( "Use Published Version" )
			c:SetColor( 1, 1, 0, 1 )


			c = EHT.CreateControl( nil, shareControls, CT_CONTROL )
			ui.SharingControls = c
			c:SetDrawLevel( baseDrawLevel )
			c:SetAnchorFill( shareControls )
			shareControls = c

			do
				local lbl = EHT.CreateControl( prefix .. "ShareEffectsLabel", shareControls, CT_LABEL )
				ui.ShareEffectsLabel = lbl
				lbl:SetDrawLevel( baseDrawLevel )
				lbl:SetFont( "$(MEDIUM_FONT)|$(KB_18)|soft-shadow-thick" )
				lbl:SetMaxLineCount( 4 )
				lbl:SetWidth( 270 )
				lbl:SetAnchor( TOP, shareControls, TOP, 0, 0 )
				lbl:SetText( "Share a snapshot of this home's Essential Effects(tm) with a group, guild or all Community members." )
				lbl:SetColor( 1, 1, 1, 1 )
				lbl:SetMouseEnabled( false )

				local bkg = CreateTexture( nil, windowFrame ) --, CreateAnchor( BOTTOM, windowFrame, BOTTOM, 0, -10 ) )
				ui.ShareEffectsTip = bkg
				bkg:SetResizeToFitDescendents( true )
				bkg:SetTexture( EHT.Textures.SOLID )
				AddAnchor( bkg, CreateAnchor( TOPLEFT, windowFrame, BOTTOMLEFT, 5, -105 ) )
				AddAnchor( bkg, CreateAnchor( BOTTOMRIGHT, windowFrame, BOTTOMRIGHT, -5, -5 ) )
				SetColor( bkg, Colors.WindowBackdrop )
				bkg:SetAlpha( 0.7 )

				local lbl = EHT.CreateControl( prefix .. "ShareEffectsTip", bkg, CT_LABEL )
				lbl:SetDrawLevel( baseDrawLevel )
				lbl:SetFont( "$(MEDIUM_FONT)|$(KB_17)|soft-shadow-thick" )
				lbl:SetMaxLineCount( 7 )
				lbl:SetInheritAlpha( false )
				lbl:SetWidth( width - 30 )
				lbl:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
				lbl:SetVerticalAlignment( TEXT_ALIGN_CENTER )
				lbl:SetAnchor( CENTER, bkg, CENTER, 0, 0 )
				lbl:SetText( "|cffff55Tip:|cffffff " ..
					"Just click any home's |c55ffffShare FX|cffffff button on the Housing Hub to share any player's effects from anywhere." )
				lbl:SetColor( 1, 1, 1, 1 )
				lbl:SetMouseEnabled( true )
				lbl:SetHandler( "OnMouseDown", function()
					EHT.UI.HideEHTEffectsButtonContextMenu()
					EHT.UI.ShowHousingHub()
				end )
			end

			c = EHT.CreateControl( nil, shareControls, CT_TEXTURE )
			ui.PublishButtonOutline = c
			c:SetDrawLevel( baseDrawLevel )
			c:SetAnchor( TOP, ui.ShareEffectsLabel, BOTTOM, 0, 24 )
			c:SetDimensions( 200, 34 )
			c:SetColor( 0.8, 0.8, 0.8, 1 )
			c:SetMouseEnabled( true )
			c:SetHandler( "OnMouseDown", function()
				EHT.UI.PublishFX()
			end )
			
			tip( c, TIP_FX_SHARE_COMMUNITY )

			c = EHT.CreateControl( nil, ui.PublishButtonOutline, CT_TEXTURE )
			ui.PublishButton = c
			c:SetDrawLevel( baseDrawLevel + 1 )
			c:SetAnchor( CENTER, ui.PublishButtonOutline, CENTER, 0, 0 )
			c:SetDimensions( 196, 30 )
			c:SetColor( 0.1, 0.3, 0.3, 1 )

			c = EHT.CreateControl( nil, ui.PublishButton, CT_LABEL )
			ui.PublishButtonLabel = c
			c:SetDrawLevel( baseDrawLevel + 2 )
			c:SetFont( "$(BOLD_FONT)|$(KB_17)|soft-shadow-thick" )
			c:SetAnchor( CENTER, ui.PublishButton, CENTER, -2, 0 )
			c:SetText( "Publish to Community" )
			c:SetColor( 1, 1, 0, 1 )

			c = EHT.CreateControl( nil, shareControls, CT_LABEL )
			ui.PreviewPublished = c
			c:SetDrawLevel( baseDrawLevel + 2 )
			c:SetFont( "$(BOLD_FONT)|$(KB_16)|soft-shadow-thick" )
			c:SetAnchor( TOP, ui.PublishButtonOutline, BOTTOM, 0, 8 )
			c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
			c:SetMaxLineCount( 2 )
			c:SetWidth( 280 )
			c:SetColor( 0.95, 0.95, 0, 1 )
			c:SetMouseEnabled( true )
			c:SetText( "Preview published version of effects" ) 
			c:SetHandler( "OnMouseDown", function( self )
				EHT.UI.PreviewPublishedFX()
			end )

			EHT.UI.RefreshEffectsPreviewState()

			c = EHT.CreateControl( nil, shareControls, CT_TEXTURE )
			ui.GuildcastButtonOutline = c
			c:SetDrawLevel( baseDrawLevel )
			c:SetAnchor( TOP, ui.PreviewPublished, BOTTOM, 0, 24 )
			c:SetDimensions( 200, 34 )
			c:SetColor( 0.8, 0.8, 0.8, 1 )
			c:SetMouseEnabled( true )
			c:SetHandler( "OnMouseDown", function()
				EHT.UI.ShowGuildcast()
			end )

			tip( c, TIP_FX_SHARE_GUILDS )

			c = EHT.CreateControl( nil, ui.GuildcastButtonOutline, CT_TEXTURE )
			ui.GuildcastButton = c
			c:SetDrawLevel( baseDrawLevel + 1 )
			c:SetAnchor( CENTER, ui.GuildcastButtonOutline, CENTER, 0, 0 )
			c:SetDimensions( 196, 30 )
			c:SetColor( 0.1, 0.3, 0.3, 1 )

			c = EHT.CreateControl( nil, ui.GuildcastButton, CT_LABEL )
			ui.GuildcastButtonLabel = c
			c:SetDrawLevel( baseDrawLevel + 2 )
			c:SetFont( "$(BOLD_FONT)|$(KB_17)|soft-shadow-thick" )
			c:SetAnchor( CENTER, ui.GuildcastButton, CENTER, -2, 0 )
			c:SetText( "Share with Guilds" )
			c:SetColor( 1, 1, 0, 1 )

			c = EHT.CreateControl( nil, shareControls, CT_LABEL )
			ui.ShareSeparatorLabel1 = c
			c:SetDrawLevel( baseDrawLevel )
			c:SetFont( "$(MEDIUM_FONT)|$(KB_17)|soft-shadow-thick" )
			c:SetAnchor( TOP, ui.GuildcastButtonOutline, BOTTOM, 0, 8 )
			c:SetText( "or" )
			c:SetColor( 1, 1, 1, 1 )
			c:SetMouseEnabled( false )

			c = EHT.CreateControl( nil, shareControls, CT_TEXTURE )
			ui.ChatcastButtonOutline = c
			c:SetDrawLevel( baseDrawLevel )
			c:SetAnchor( TOP, ui.ShareSeparatorLabel1, BOTTOM, 0, 10 )
			c:SetDimensions( 200, 34 )
			c:SetColor( 0.8, 0.8, 0.8, 1 )
			c:SetMouseEnabled( true )
			c:SetHandler( "OnMouseDown", function()
				EHT.UI.ShowConfirmationDialog(
					"Share FX with Chat",
					"Share a snapshot of this home's Essential Effects(TM) data?\n\n" ..
					"Note that you will need to share your data again if you make additional changes.\n\n" ..
					"|c0099ffPlease remember that you may be asked to press ENTER more than once in order to send " ..
					"your data across multiple chat messages, depending on the number of effects that you have placed.|r\n\n" ..
					"For this reason, it is recommended that you Share using a more private channel " ..
					"whenever possible, such as |cffffff/group|r, |cffffff/say|r or |cffffff/tell|r.\n",
					function()
						local CURRENT_CHANNEL = nil
						local owner, houseId = EHT.Housing.GetHouseOwner()
						EHT.Effect:InitializeChatcast(CURRENT_CHANNEL, houseId, owner)
					end )
			end )

			tip( c, TIP_FX_SHARE_CHAT )

			c = EHT.CreateControl( nil, ui.ChatcastButtonOutline, CT_TEXTURE )
			ui.ChatcastButton = c
			c:SetDrawLevel( baseDrawLevel + 1 )
			c:SetAnchor( CENTER, ui.ChatcastButtonOutline, CENTER, 0, 0 )
			c:SetDimensions( 196, 30 )
			c:SetColor( 0.1, 0.3, 0.3, 1 )

			c = EHT.CreateControl( nil, ui.ChatcastButton, CT_LABEL )
			ui.ChatcastButtonLabel = c
			c:SetDrawLevel( baseDrawLevel + 2 )
			c:SetFont( "$(BOLD_FONT)|$(KB_17)|soft-shadow-thick" )
			c:SetAnchor( CENTER, ui.ChatcastButton, CENTER, -2, 0 )
			c:SetText( "Share with Chat" )
			c:SetColor( 1, 1, 0, 1 )

			c = EHT.CreateControl( nil, shareControls, CT_LABEL )
			ui.ShareSeparatorLabel2 = c
			c:SetDrawLevel( baseDrawLevel )
			c:SetFont( "$(MEDIUM_FONT)|$(KB_17)|soft-shadow-thick" )
			c:SetAnchor( TOP, ui.ChatcastButtonOutline, BOTTOM, 0, 8 )
			c:SetText( "or" )
			c:SetColor( 1, 1, 1, 1 )
			c:SetMouseEnabled( false )

			local DEFAULT_MAILCAST_PLAYER = "mail recipient's @name"

			local OnFocusGainedMailcastPlayer = function()
				zo_callLater( function()
					ui.MailcastPlayer:SelectAll()
				end, 50 )
			end

			c = WINDOW_MANAGER:CreateControlFromVirtual( nil, shareControls, "ZO_EditBackdrop" )
			ui.MailcastPlayerBackdrop = c
			c:SetDrawLevel( baseDrawLevel )
			c:SetAnchor( TOP, ui.ShareSeparatorLabel2, BOTTOM, 0, 8 )
			c:SetDimensions( 200, 26 )

			c = WINDOW_MANAGER:CreateControlFromVirtual( nil, ui.MailcastPlayerBackdrop, "ZO_DefaultEditForBackdrop" )
			ui.MailcastPlayer = c
			c:SetFont( "$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thin" )
			c:SetDrawLevel( baseDrawLevel )
			c:SetAnchor( TOPLEFT, ui.MailcastPlayerBackdrop, TOPLEFT, 4, 2 )
			c:SetAnchor( BOTTOMRIGHT, ui.MailcastPlayerBackdrop, BOTTOMRIGHT, -4, -2 )
			c:SetMaxInputChars( 64 )
			c:SetMouseEnabled( true )
			c:SetText( DEFAULT_MAILCAST_PLAYER )
			c:SetHandler( "OnMouseUp", OnFocusGainedMailcastPlayer )

			c = EHT.CreateControl( nil, shareControls, CT_TEXTURE )
			ui.MailcastButtonOutline = c
			c:SetDrawLevel( baseDrawLevel )
			c:SetAnchor( TOP, ui.MailcastPlayerBackdrop, BOTTOM, 0, 10 )
			c:SetDimensions( 200, 34 )
			c:SetColor( 0.8, 0.8, 0.8, 1 )
			c:SetMouseEnabled( true )
			c:SetHandler( "OnMouseDown", function()
				local player = ui.MailcastPlayer:GetText()

				if not player or "" == player or "@" ~= string.sub( player, 1, 1 ) then
					EHT.UI.ShowAlertDialog( "", "Please enter the player's |cffff66@name|r that you would like to mail your Essential Effects(tm) data to." )
					return
				end

				EHT.UI.ShowConfirmationDialog(
					"Share with Mail", string.format(
					"Mail a snapshot of this home's Essential Effects(TM) data to |cffff66%s|r?\n\n" ..
					"Note that sharing your data by mail will send one or more mail messages to the recipient, " ..
					"depending on the number of effects that you have placed in this home.", player or "" ),
					function()
						local success, message = EHT.Effect:Mailcast( player )
						if not success then
							EHT.UI.ShowAlertDialog( "", message )
						else
							ui.MailcastPlayer:SetText( DEFAULT_MAILCAST_PLAYER )
						end
					end )
			end )

			tip( c, TIP_FX_SHARE_MAIL )

			c = EHT.CreateControl( nil, ui.MailcastButtonOutline, CT_TEXTURE )
			ui.MailcastButton = c
			c:SetDrawLevel( baseDrawLevel + 1 )
			c:SetAnchor( CENTER, ui.MailcastButtonOutline, CENTER, 0, 0 )
			c:SetDimensions( 196, 30 )
			c:SetColor( 0.1, 0.3, 0.3, 1 )

			c = EHT.CreateControl( nil, ui.MailcastButton, CT_LABEL )
			ui.MailcastButtonLabel = c
			c:SetDrawLevel( baseDrawLevel + 2 )
			c:SetFont( "$(BOLD_FONT)|$(KB_17)|soft-shadow-thick" )
			c:SetAnchor( CENTER, ui.MailcastButton, CENTER, -2, 0 )
			c:SetText( "Share with Mail" )
			c:SetColor( 1, 1, 0, 1 )

			local enabledEffectTypes = EHT.EffectType and EHT.EffectType:GetEnabled()
			if "table" ~= type(enabledEffectTypes) then
				zo_callLater(function() d("Failed to initialize Essential Housing Tools effect list.") end, 5000)
			else
				local categories, sortedCategories = { }, { }
				local effectTypes, effectType, parentSection, section, name, bold

				for _, effectType in pairs(enabledEffectTypes) do
					if "" ~= effectType.Category then
						if not effectType.Category then effectType.Category = "Other" end

						effectTypes = categories[ effectType.Category ]
						if nil == effectTypes then
							effectTypes = { }
							categories[ effectType.Category ] = effectTypes
						end

						table.insert( effectTypes, effectType.Name )
					end
				end

				for category, effectTypes in pairs( categories ) do
					table.insert( sortedCategories, category )
					table.sort( effectTypes )
				end

				table.sort( sortedCategories )

				section = { Visible = true, Label = "|c33ffffRecently Used|r", Value = "Recently Used", ClickHandler = ToggleEffectCategory, Children = { } }
				ui.RecentlyUsed = section.Children
				table.insert( allEffects, section )

				do
					for recentIndex = 1, 30 do
						table.insert( section.Children, { Visible = false, Label = "", Value = "", ClickHandler = OnEffectMouseDown, MouseEnterHandler = OnEffectMouseEnter, MouseExitHandler = OnEffectMouseExit } )
					end
				end

				for _, category in ipairs( sortedCategories ) do
					effectTypes = categories[ category ]
					name = string.format( "|c33ffff%s|r", category )

					for _, effectTypeName in ipairs( effectTypes ) do
						effectType = EHT.EffectType:GetByName( effectTypeName )
						if nil ~= effectType and 0 < effectType:NewAge() then
							name = string.format( "|cffff33%s|r (NEW)", category ) -- , newAgeColor( 1 ) )
							break
						end
					end

					section = { Visible = false, Label = name, Value = category, ClickHandler = ToggleEffectCategory, Children = { } }
					table.insert( allEffects, section )

					for _, effectTypeName in ipairs( effectTypes ) do
						effectType = EHT.EffectType:GetByName( effectTypeName )
						if nil ~= effectType then
							if 0 < effectType:NewAge() then
								name = string.format( "   |cffff33%s|r (NEW)", effectTypeName ) -- , newAgeColor( effectType:NewAge() ) )
							else
								name = string.format( "   |cffffff%s", effectTypeName )
							end

							if effectType.Submitter and "" ~= effectType.Submitter then
								name = string.format( "%s |c888888by |cd0d0d0%s|r", name, tostring( effectType.Submitter ) )
							end

							table.insert( section.Children, { Visible = true, Label = name, Value = effectTypeName, ClickHandler = OnEffectMouseDown, MouseEnterHandler = OnEffectMouseEnter, MouseExitHandler = OnEffectMouseExit } )
						end
					end
				end

				RefreshAddEffectsList()
			end

			zo_callLater( function()
				ToggleTab( 1 )
				RefreshRecentlyUsedEffects()
			end, 500 )
		end

		return ui

	end

end

---[[ Dialog : Snap Furniture ]---

function EHT.UI.HideSnapFurnitureDialog()
	if nil ~= EHT.UI.SnapFurnitureDialog then
		if EHT.SnapFurnitureItem and EHT.SnapFurnitureItem.Id then
			local before = EHT.SnapFurnitureItem.ItemBefore

			if before then
				local after = EHT.Data.CreateFurniture( EHT.SnapFurnitureItem.Id )
				EHT.Biz.AddChangeHistory( before, after )
			end

			EHT.SnapFurnitureItem.Id, EHT.SnapFurnitureItem.ItemBefore = nil, nil
		end
		
		if not EHT.UI.SnapFurnitureDialog.Window:IsHidden() then
			EHT.Pointers.ClearSelected()
		end

		EHT.UI.ClearDialogHidden( EHT.CONST.DIALOG.SNAP_FURNITURE )
		EHT.UI.SnapFurnitureDialog.Window:SetHidden( true )
	end
end

function EHT.UI.SetupSnapFurnitureDialog()
	local ui = EHT.UI.SnapFurnitureDialog
	if nil == ui then
		ui = { }

		local windowName = "SnapFurnitureDialog"
		local prefix = "EHTSnapFurnitureDialog"
		local settings = EHT.UI.GetDialogSettings( windowName )

		local minWidth, maxWidth = 350, 350
		local minHeight, maxHeight = 244, 244

		-- Window Controls

		local ctl, grp, win

		ui.Window = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
		win = ui.Window
		win:SetDimensionConstraints( minWidth, minHeight, maxWidth, maxHeight )
		win:SetMovable( true )
		win:SetMouseEnabled( true )
		win:SetClampedToScreen( true )
		win:SetAlpha( 0.85 )
		win:SetResizeHandleSize( 0 )

		if settings.Left and settings.Top then
			win:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, settings.Left, settings.Top )
		else
			win:SetAnchor( CENTER, GuiRoot, CENTER, 0, 0 )
		end

		if settings.Width and settings.Height then
			win:SetDimensions( settings.Width, settings.Height )
		else
			win:SetDimensions( maxWidth, minHeight )
		end

		ui.ItemLabelBackdrop = EHT.CreateControl( prefix .. "ItemLabelBackdrop", win, CT_LINE )
		ctl = ui.ItemLabelBackdrop
		ctl:SetColor( 0.6, 0.6, 0.6, 0.75 )
		ctl:SetAnchor( TOPLEFT, win, TOPLEFT, 0, 22 )
		ctl:SetAnchor( TOPRIGHT, win, TOPRIGHT, 0, 22 )
		ctl:SetThickness( 45 )

		ui.Backdrop = EHT.CreateControl( prefix .. "Backdrop", win, CT_LINE )
		ctl = ui.Backdrop
		ctl:SetColor( 0.25, 0.25, 0.25, 0.75 )
		ctl:SetAnchor( BOTTOMLEFT, win, BOTTOMLEFT, 0, -100 )
		ctl:SetAnchor( BOTTOMRIGHT, win, BOTTOMRIGHT, 0, -100 )
		ctl:SetThickness( 200 )

		ui.ItemLabel = EHT.CreateControl( prefix .. "ItemLabel", win, CT_LABEL )
		ctl = ui.ItemLabel
		ctl:SetColor( 1, 1, 1, 1 )
		ctl:SetText( "Snap Furniture" )
		ctl:SetFont( "$(BOLD_FONT)|$(KB_28)|soft-shadow-thick" )
		ctl:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		ctl:SetVerticalAlignment( TEXT_ALIGN_TOP )
		ctl:SetAnchor( TOP, win, TOP, 0, 5 )


		-- X Margin Group

		ui.XMarginGroup = EHT.CreateControl( prefix .. "XMarginGroup", win, CT_CONTROL )
		grp = ui.XMarginGroup
		grp:SetAnchor( LEFT, win, LEFT, 5, -28 )
		grp:SetDimensions( 105, 94 )

		ui.XMarginDec = EHT.CreateControl( prefix .. "XMarginDec", grp, CT_BUTTON )
		ctl = ui.XMarginDec
		ctl:SetDimensions( 40, 40 )
		ctl:SetAnchor( LEFT, grp, LEFT, 5, 0 )
		ctl:SetNormalTexture( "esoui/art/housing/housing_axiscontrolicon_yawcw.dds" )
		ctl:SetPressedTexture( "esoui/art/housing/housing_axiscontrolicon_yawcw.dds" )
		ctl:SetMouseOverTexture( "esoui/art/housing/housing_axiscontrolicon_yawcw.dds" )
		ctl:SetDisabledTexture( "esoui/art/housing/housing_axiscontrolicon_yawcw.dds" )
		ctl:SetHandler( "OnClicked", function() EHT.Biz.AdjustSnapFurnitureMargin( "X", -1 ) end )

		ui.XMarginInc = EHT.CreateControl( prefix .. "XMarginInc", grp, CT_BUTTON )
		ctl = ui.XMarginInc
		ctl:SetDimensions( 40, 40 )
		ctl:SetAnchor( RIGHT, grp, RIGHT, -5, 0 )
		ctl:SetNormalTexture( "esoui/art/housing/housing_axiscontrolicon_yawccw.dds" )
		ctl:SetPressedTexture( "esoui/art/housing/housing_axiscontrolicon_yawccw.dds" )
		ctl:SetMouseOverTexture( "esoui/art/housing/housing_axiscontrolicon_yawccw.dds" )
		ctl:SetDisabledTexture( "esoui/art/housing/housing_axiscontrolicon_yawccw.dds" )
		ctl:SetHandler( "OnClicked", function() EHT.Biz.AdjustSnapFurnitureMargin( "X", 1 ) end )

		ctl = EHT.CreateControl( nil, grp, CT_LABEL )
		ctl:SetColor( 1, 1, 1, 1 )
		ctl:SetFont( "$(MEDIUM_FONT)|$(KB_18)|soft-shadow-thick" )
		ctl:SetText( "Margin (X)" )
		ctl:SetAnchor( TOP, grp, TOP, 0, 0 )
		ctl:SetHorizontalAlignment( TEXT_ALIGN_CENTER )

		ui.XMarginValue = EHT.CreateControl( nil, grp, CT_LABEL )
		ctl = ui.XMarginValue
		ctl:SetColor( 1, 1, 1, 1 )
		ctl:SetFont( "$(MEDIUM_FONT)|$(KB_18)|soft-shadow-thick" )
		ctl:SetText( "0 cm" )
		ctl:SetAnchor( BOTTOM, grp, BOTTOM, 0, 0 )
		ctl:SetHorizontalAlignment( TEXT_ALIGN_CENTER )


		-- Y Margin Group

		ui.YMarginGroup = EHT.CreateControl( prefix .. "YMarginGroup", win, CT_CONTROL )
		grp = ui.YMarginGroup
		grp:SetAnchor( CENTER, win, CENTER, 0, -28 )
		grp:SetDimensions( 105, 94 )

		ui.YMarginDec = EHT.CreateControl( prefix .. "YMarginDec", grp, CT_BUTTON )
		ctl = ui.YMarginDec
		ctl:SetDimensions( 40, 40 )
		ctl:SetAnchor( LEFT, grp, LEFT, 5, 0 )
		ctl:SetNormalTexture( "esoui/art/housing/housing_axiscontrolicon_pitchccw.dds" )
		ctl:SetPressedTexture( "esoui/art/housing/housing_axiscontrolicon_pitchccw.dds" )
		ctl:SetMouseOverTexture( "esoui/art/housing/housing_axiscontrolicon_pitchccw.dds" )
		ctl:SetDisabledTexture( "esoui/art/housing/housing_axiscontrolicon_pitchccw.dds" )
		ctl:SetHandler( "OnClicked", function() EHT.Biz.AdjustSnapFurnitureMargin( "Y", -1 ) end )

		ui.YMarginInc = EHT.CreateControl( prefix .. "YMarginInc", grp, CT_BUTTON )
		ctl = ui.YMarginInc
		ctl:SetDimensions( 40, 40 )
		ctl:SetAnchor( RIGHT, grp, RIGHT, -5, 0 )
		ctl:SetNormalTexture( "esoui/art/housing/housing_axiscontrolicon_pitchcw.dds" )
		ctl:SetPressedTexture( "esoui/art/housing/housing_axiscontrolicon_pitchcw.dds" )
		ctl:SetMouseOverTexture( "esoui/art/housing/housing_axiscontrolicon_pitchcw.dds" )
		ctl:SetDisabledTexture( "esoui/art/housing/housing_axiscontrolicon_pitchcw.dds" )
		ctl:SetHandler( "OnClicked", function() EHT.Biz.AdjustSnapFurnitureMargin( "Y", 1 ) end )

		ctl = EHT.CreateControl( nil, grp, CT_LABEL )
		ctl:SetColor( 1, 1, 1, 1 )
		ctl:SetFont( "$(MEDIUM_FONT)|$(KB_18)|soft-shadow-thick" )
		ctl:SetText( "Margin (Y)" )
		ctl:SetAnchor( TOP, grp, TOP, 0, 0 )
		ctl:SetHorizontalAlignment( TEXT_ALIGN_CENTER )

		ui.YMarginValue = EHT.CreateControl( nil, grp, CT_LABEL )
		ctl = ui.YMarginValue
		ctl:SetColor( 1, 1, 1, 1 )
		ctl:SetFont( "$(MEDIUM_FONT)|$(KB_18)|soft-shadow-thick" )
		ctl:SetText( "0 cm" )
		ctl:SetAnchor( BOTTOM, grp, BOTTOM, 0, 0 )
		ctl:SetHorizontalAlignment( TEXT_ALIGN_CENTER )


		-- Z Margin Group

		ui.ZMarginGroup = EHT.CreateControl( prefix .. "ZMarginGroup", win, CT_CONTROL )
		grp = ui.ZMarginGroup
		grp:SetAnchor( RIGHT, win, RIGHT, -5, -28 )
		grp:SetDimensions( 105, 94 )

		ui.ZMarginDec = EHT.CreateControl( prefix .. "ZMarginDec", grp, CT_BUTTON )
		ctl = ui.ZMarginDec
		ctl:SetDimensions( 40, 40 )
		ctl:SetAnchor( LEFT, grp, LEFT, 5, 0 )
		ctl:SetNormalTexture( "esoui/art/housing/housing_axiscontrolicon_yawcw.dds" )
		ctl:SetPressedTexture( "esoui/art/housing/housing_axiscontrolicon_yawcw.dds" )
		ctl:SetMouseOverTexture( "esoui/art/housing/housing_axiscontrolicon_yawcw.dds" )
		ctl:SetDisabledTexture( "esoui/art/housing/housing_axiscontrolicon_yawcw.dds" )
		ctl:SetHandler( "OnClicked", function() EHT.Biz.AdjustSnapFurnitureMargin( "Z", -1 ) end )

		ui.ZMarginInc = EHT.CreateControl( prefix .. "ZMarginInc", grp, CT_BUTTON )
		ctl = ui.ZMarginInc
		ctl:SetDimensions( 40, 40 )
		ctl:SetAnchor( RIGHT, grp, RIGHT, -5, 0 )
		ctl:SetNormalTexture( "esoui/art/housing/housing_axiscontrolicon_yawccw.dds" )
		ctl:SetPressedTexture( "esoui/art/housing/housing_axiscontrolicon_yawccw.dds" )
		ctl:SetMouseOverTexture( "esoui/art/housing/housing_axiscontrolicon_yawccw.dds" )
		ctl:SetDisabledTexture( "esoui/art/housing/housing_axiscontrolicon_yawccw.dds" )
		ctl:SetHandler( "OnClicked", function() EHT.Biz.AdjustSnapFurnitureMargin( "Z", 1 ) end )

		ctl = EHT.CreateControl( nil, grp, CT_LABEL )
		ctl:SetColor( 1, 1, 1, 1 )
		ctl:SetFont( "$(MEDIUM_FONT)|$(KB_18)|soft-shadow-thick" )
		ctl:SetText( "Margin (Z)" )
		ctl:SetAnchor( TOP, grp, TOP, 0, 0 )
		ctl:SetHorizontalAlignment( TEXT_ALIGN_CENTER )

		ui.ZMarginValue = EHT.CreateControl( nil, grp, CT_LABEL )
		ctl = ui.ZMarginValue
		ctl:SetColor( 1, 1, 1, 1 )
		ctl:SetFont( "$(MEDIUM_FONT)|$(KB_18)|soft-shadow-thick" )
		ctl:SetText( "0 cm" )
		ctl:SetAnchor( BOTTOM, grp, BOTTOM, 0, 0 )
		ctl:SetHorizontalAlignment( TEXT_ALIGN_CENTER )


		-- Snap Item Group

		ui.SnapItemGroup = EHT.CreateControl( prefix .. "SnapItemGroup", win, CT_CONTROL )
		grp = ui.SnapItemGroup
		grp:SetAnchor( BOTTOM, win, BOTTOM, -60, -5 )
		grp:SetDimensions( 105, 94 )

		ui.SnapPrevItem = EHT.CreateControl( prefix .. "SnapPrevItem", grp, CT_BUTTON )
		ctl = ui.SnapPrevItem
		ctl:SetDimensions( 40, 40 )
		ctl:SetAnchor( LEFT, ui.SnapGroup, LEFT, 5, 0 )
		ctl:SetNormalTexture( "esoui/art/housing/housing_axiscontrolicon_rollccw.dds" )
		ctl:SetPressedTexture( "esoui/art/housing/housing_axiscontrolicon_rollccw.dds" )
		ctl:SetMouseOverTexture( "esoui/art/housing/housing_axiscontrolicon_rollccw.dds" )
		ctl:SetDisabledTexture( "esoui/art/housing/housing_axiscontrolicon_rollccw.dds" )
		ctl:SetHandler( "OnClicked", function() EHT.Biz.SnapFurniturePreviousItem() end )

		ui.SnapNextItem = EHT.CreateControl( prefix .. "SnapNextItem", grp, CT_BUTTON )
		ctl = ui.SnapNextItem
		ctl:SetDimensions( 40, 40 )
		ctl:SetAnchor( RIGHT, ui.SnapGroup, RIGHT, -5, 0 )
		ctl:SetNormalTexture( "esoui/art/housing/housing_axiscontrolicon_rollcw.dds" )
		ctl:SetPressedTexture( "esoui/art/housing/housing_axiscontrolicon_rollcw.dds" )
		ctl:SetMouseOverTexture( "esoui/art/housing/housing_axiscontrolicon_rollcw.dds" )
		ctl:SetDisabledTexture( "esoui/art/housing/housing_axiscontrolicon_rollcw.dds" )
		ctl:SetHandler( "OnClicked", function() EHT.Biz.SnapFurnitureNextItem() end )

		ctl = EHT.CreateControl( nil, grp, CT_LABEL )
		ctl:SetColor( 1, 1, 1, 1 )
		ctl:SetFont( "$(MEDIUM_FONT)|$(KB_18)|soft-shadow-thick" )
		ctl:SetText( "Adjacent Item" )
		ctl:SetAnchor( TOP, grp, TOP, 0, -2 )
		ctl:SetHorizontalAlignment( TEXT_ALIGN_CENTER )

		ui.SnapItemCount = EHT.CreateControl( nil, grp, CT_LABEL )
		ctl = ui.SnapItemCount
		ctl:SetColor( 1, 1, 1, 1 )
		ctl:SetFont( "$(MEDIUM_FONT)|$(KB_18)|soft-shadow-thick" )
		ctl:SetText( "0 / 0" )
		ctl:SetAnchor( BOTTOM, grp, BOTTOM, 0, 2 )
		ctl:SetHorizontalAlignment( TEXT_ALIGN_CENTER )


		-- Orientation Group

		ui.OrientationGroup = EHT.CreateControl( prefix .. "OrientationGroup", win, CT_CONTROL )
		grp = ui.OrientationGroup
		grp:SetAnchor( BOTTOM, win, BOTTOM, 60, -5 )
		grp:SetDimensions( 105, 94 )

		ui.SnapPrevOrientation = EHT.CreateControl( prefix .. "SnapPrevOrientation", grp, CT_BUTTON )
		ctl = ui.SnapPrevOrientation
		ctl:SetDimensions( 40, 40 )
		ctl:SetAnchor( LEFT, ui.OrientationGroup, LEFT, 5, 0 )
		ctl:SetNormalTexture( "esoui/art/housing/housing_axiscontrolicon_rollccw.dds" )
		ctl:SetPressedTexture( "esoui/art/housing/housing_axiscontrolicon_rollccw.dds" )
		ctl:SetMouseOverTexture( "esoui/art/housing/housing_axiscontrolicon_rollccw.dds" )
		ctl:SetDisabledTexture( "esoui/art/housing/housing_axiscontrolicon_rollccw.dds" )
		ctl:SetHandler( "OnClicked", function() EHT.Biz.SnapFurniturePreviousOrientation() end )

		ui.SnapNextOrientation = EHT.CreateControl( prefix .. "SnapNextOrientation", grp, CT_BUTTON )
		ctl = ui.SnapNextOrientation
		ctl:SetDimensions( 40, 40 )
		ctl:SetAnchor( RIGHT, ui.OrientationGroup, RIGHT, -5, 0 )
		ctl:SetNormalTexture( "esoui/art/housing/housing_axiscontrolicon_rollcw.dds" )
		ctl:SetPressedTexture( "esoui/art/housing/housing_axiscontrolicon_rollcw.dds" )
		ctl:SetMouseOverTexture( "esoui/art/housing/housing_axiscontrolicon_rollcw.dds" )
		ctl:SetDisabledTexture( "esoui/art/housing/housing_axiscontrolicon_rollcw.dds" )
		ctl:SetHandler( "OnClicked", function() EHT.Biz.SnapFurnitureNextOrientation() end )

		ctl = EHT.CreateControl( nil, grp, CT_LABEL )
		ctl:SetColor( 1, 1, 1, 1 )
		ctl:SetFont( "$(MEDIUM_FONT)|$(KB_18)|soft-shadow-thick" )
		ctl:SetText( "Alignment" )
		ctl:SetAnchor( TOP, grp, TOP, 0, -2 )
		ctl:SetHorizontalAlignment( TEXT_ALIGN_CENTER )

		ui.SnapOrientationCount = EHT.CreateControl( nil, grp, CT_LABEL )
		ctl = ui.SnapOrientationCount
		ctl:SetColor( 1, 1, 1, 1 )
		ctl:SetFont( "$(MEDIUM_FONT)|$(KB_18)|soft-shadow-thick" )
		ctl:SetText( "0 / 0" )
		ctl:SetAnchor( BOTTOM, grp, BOTTOM, 0, 2 )
		ctl:SetHorizontalAlignment( TEXT_ALIGN_CENTER )


		-- Top Window Controls

		ui.CloseButton = EHT.CreateControl( prefix .. "CloseButton", win, CT_BUTTON )
		ctl = ui.CloseButton
		ctl:SetDimensions( 35, 35 )
		ctl:SetAnchor( TOPLEFT, win, TOPLEFT, 6, 12 )
		ctl:SetNormalTexture( "EsoUI/Art/Buttons/closebutton_up.dds" )
		ctl:SetPressedTexture( "EsoUI/Art/Buttons/closebutton_down.dds" )
		ctl:SetMouseOverTexture( "EsoUI/Art/Buttons/closebutton_mouseover.dds" )
		ctl:SetDisabledTexture( "EsoUI/Art/Buttons/closebutton_disabled.dds" )
		ctl:SetHandler( "OnClicked", function() EHT.UI.HideSnapFurnitureDialog() end )

		win:SetHandler( "OnMoveStop", function() EHT.UI.SaveDialogSettings( windowName, win ) end )

		EHT.UI.SnapFurnitureDialog = ui

	end

	return ui

end


function EHT.UI.ShowSnapFurnitureDialog()

	local ui = EHT.UI.SetupSnapFurnitureDialog()
	if ( not isUIHidden or EHT.SnapFurnitureInitiating ) and ui.Window:IsHidden() then
		ui.Window:SetHidden( false )
		EHT.UI.EnterUIMode()
	end

end


------[[ Dialog : Edit Furniture ]]------


function EHT.UI.HideEditFurnitureDialog()

	if nil ~= EHT.UI.EditFurnitureDialog then
		if EHT.EditFurnitureItem then
			EHT.EditFurnitureItem.Id = nil
		end

		EHT.UI.ClearDialogHidden( EHT.CONST.DIALOG.EDIT_FURNITURE )
		EHT.UI.EditFurnitureDialog.Window:SetHidden( true )
	end

end


function EHT.UI.SetupEditFurnitureDialog()

	local ui = EHT.UI.EditFurnitureDialog

	if nil == ui then

		ui = { }

		local windowName = "EditFurnitureDialog"
		local prefix = "EHTEditFurnitureDialog"
		local settings = EHT.UI.GetDialogSettings( windowName )

		local minWidth, maxWidth = 300, 300
		local minHeight, maxHeight = 250, 250


		-- Window Controls

		local ctl, grp, win

		win = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
		ui.Window = win
		win:SetDimensionConstraints( minWidth, minHeight, maxWidth, maxHeight )
		win:SetMovable( true )
		win:SetMouseEnabled( true )
		win:SetClampedToScreen( true )
		win:SetAlpha( 0.85 )
		win:SetResizeHandleSize( 0 )

		if settings.Left and settings.Top then
			win:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, settings.Left, settings.Top )
		else
			win:SetAnchor( CENTER, GuiRoot, CENTER, 0, 0 )
		end

		if settings.Width and settings.Height then
			win:SetDimensions( settings.Width, settings.Height )
		else
			win:SetDimensions( maxWidth, minHeight )
		end

		ctl = EHT.CreateControl( prefix .. "HeaderBackdrop", win, CT_LINE )
		ui.HeaderBackdrop = ctl
		ctl:SetColor( 0.5, 0.5, 0.5, 0.9 )
		ctl:SetAnchor( TOPLEFT, win, TOPLEFT, 0, 20 )
		ctl:SetAnchor( TOPRIGHT, win, TOPRIGHT, 0, 20 )
		ctl:SetThickness( 40 )

		ctl = EHT.CreateControl( prefix .. "Backdrop", win, CT_LINE )
		ui.Backdrop = ctl
		ctl:SetColor( 0.15, 0.15, 0.15, 0.9 )
		ctl:SetAnchor( BOTTOMLEFT, win, BOTTOMLEFT, 0, -105 )
		ctl:SetAnchor( BOTTOMRIGHT, win, BOTTOMRIGHT, 0, -105 )
		ctl:SetThickness( 210 )

		ctl = EHT.CreateControl( prefix .. "ItemLabel", win, CT_LABEL )
		ui.ItemLabel = ctl
		ctl:SetColor( 1, 1, 1, 1 )
		ctl:SetText( "Edit Furniture" )
		ctl:SetFont( "$(BOLD_FONT)|$(KB_28)|soft-shadow-thick" )
		ctl:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		ctl:SetVerticalAlignment( TEXT_ALIGN_TOP )
		ctl:SetAnchor( TOP, win, TOP, 0, 2 )


		grp = EHT.CreateControl( prefix .. "EditControls", win, CT_CONTROL )
		ui.EditControls = grp
		grp:SetAnchor( TOPLEFT, win, TOPLEFT, 5, 45 )
		grp:SetAnchor( BOTTOMRIGHT, win, BOTTOMRIGHT, -5, -5 )

		EHT.UI.SetupToolDialogEditTab( ui, grp, prefix, nil, "EditFurniture" )


		-- Top Window Controls

		ui.CloseButton = EHT.CreateControl( prefix .. "CloseButton", win, CT_BUTTON )
		ctl = ui.CloseButton
		ctl:SetDimensions( 35, 35 )
		ctl:SetAnchor( TOPLEFT, win, TOPLEFT, 6, 12 )
		ctl:SetNormalTexture( "EsoUI/Art/Buttons/closebutton_up.dds" )
		ctl:SetPressedTexture( "EsoUI/Art/Buttons/closebutton_down.dds" )
		ctl:SetMouseOverTexture( "EsoUI/Art/Buttons/closebutton_mouseover.dds" )
		ctl:SetDisabledTexture( "EsoUI/Art/Buttons/closebutton_disabled.dds" )
		ctl:SetHandler( "OnClicked", function() EHT.UI.HideEditFurnitureDialog() end )

		win:SetHandler( "OnMoveStop", function() EHT.UI.SaveDialogSettings( windowName, win ) end )

		EHT.UI.EditFurnitureDialog = ui

	end

	return ui

end


function EHT.UI.ShowEditFurnitureDialog()

	local ui = EHT.UI.SetupEditFurnitureDialog()
	if ( not isUIHidden or EHT.EditFurnitureInitiating ) and ui.Window:IsHidden() then
		ui.Window:SetHidden( false )
		EHT.UI.EnterUIMode()
	end

end

sef = EHT.UI.ShowEditFurnitureDialog

---[ Dialog : Tutorial ]---

function EHT.UI.IsTutorialHidden()
	return not EHT.UI.TutorialDialog or EHT.UI.TutorialDialog.Window:IsHidden()
end

function EHT.UI.HideTutorialDialog()
	if nil ~= EHT.UI.TutorialDialog then
		EHT.UI.ClearDialogHidden( EHT.CONST.DIALOG.TUTORIAL )
		EHT.UI.TutorialDialog.Window:SetHidden( true )
	end
end

function EHT.UI.SetupTutorialDialog()
	local ui = EHT.UI.TutorialDialog

	if nil == ui then
		ui = { }
		EHT.UI.TutorialDialog = ui

		local prefix = "EHTTutorialDialog"
		local c, grp, win

		-- Window Controls

		win = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
		ui.Window = win
		win:SetHidden( true )
		win:SetAlpha( 1.0 )
		win:SetClampedToScreen( true )
		win:SetMouseEnabled( true )
		win:SetMovable( false )
		win:SetResizeHandleSize( 0 )
		win:SetAnchor( CENTER, GuiRoot, CENTER, 0, 0 )
		win:SetDimensions( 400, 400 )
		win:SetDrawTier( DT_HIGH )
		win:SetDrawLayer( DL_OVERLAY )
		win:SetDrawLevel( 212000 )

		CreateWindowBackdrop( prefix .. "Outline", prefix .. "Backdrop", win, 0, 0 )

		-- Title

		c = EHT.CreateControl( prefix .. "Title", win, CT_LABEL )
		ui.Title = c
		c:SetColor( 1, 1, 0.5, 1 )
		c:SetText( "Did you know..." )
		c:SetFont( "$(BOLD_FONT)|$(KB_22)|soft-shadow-thick" )
		c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		c:SetVerticalAlignment( TEXT_ALIGN_TOP )
		c:SetAnchor( TOPLEFT, win, TOPLEFT, 8, 6 )
		c:SetAnchor( TOPRIGHT, win, TOPRIGHT, -8, 6 )
		c:SetMaxLineCount( 2 )

		-- Caption

		c = EHT.CreateControl( prefix .. "Caption", win, CT_LABEL )
		ui.Caption = c
		c:SetAnchor( TOPLEFT, ui.Title, BOTTOMLEFT, 0, 8 )
		c:SetAnchor( BOTTOMRIGHT, win, BOTTOMRIGHT, -8, -35 )
		c:SetColor( 1.0, 1.0, 1.0, 1.0 )
		c:SetFont( "$(CHAT_FONT)|$(KB_18)" )
		c:SetMaxLineCount( 30 )
		c:SetText( "There are new features!" )
		c:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		c:SetVerticalAlignment( TEXT_ALIGN_TOP )

		-- Pointers

		c = EHT.CreateControl( prefix .. "UpArrow", win, CT_TEXTURE )
		ui.UpArrow = c
		c:SetHidden( true )
		c:SetTexture( EHT.Textures.ARROW_2 )
		c:SetDimensions( 64, 64 )
		c:SetTextureCoords( 0, 1, 0, 1 )
		c:SetVertexColors( 1 + 2, 0, 0.7, 0.7, 0.4 )
		c:SetVertexColors( 4 + 8, 0, 0.7, 0.7, 1 )
		c:SetAnchor( BOTTOM, win, TOP, 0, 0 )

		c = EHT.CreateControl( prefix .. "DownArrow", win, CT_TEXTURE )
		ui.DownArrow = c
		c:SetHidden( true )
		c:SetTexture( EHT.Textures.ARROW_2 )
		c:SetDimensions( 64, 64 )
		c:SetTextureCoords( 0, 1, 1, 0 )
		c:SetVertexColors( 4 + 8, 0, 0.7, 0.7, 0.4 )
		c:SetVertexColors( 1 + 2, 0, 0.7, 0.7, 1 )
		c:SetAnchor( TOP, win, BOTTOM, 0, 0 )

		-- Buttons

		c = EHT.UI.CreateButton(
			prefix .. "DisableTutorialsButton",
			win,
			zo_iconFormat( "esoui/art/buttons/cancel_up.dds" ) .. " No more tips",
			{ { BOTTOM, win, BOTTOM, -110, -15 } },
			function()
				EHT.UI.HideTutorialDialog()
				EHT.Tutorials.DisableTutorials( true )
			end )
		ui.DisableTutorialsButton = c
		c:SetWidth( 145 )
		c:SetFont( "$(CHAT_FONT)|$(KB_20)" )

		c = EHT.UI.CreateButton(
			prefix .. "CloseButton",
			win,
			zo_iconFormat( "esoui/art/buttons/accept_up.dds" ) .. " Ok, got it",
			{ { BOTTOM, win, BOTTOM, 114, -15 } },
			function()
				EHT.UI.HideTutorialDialog()
				EHT.UI.OnTutorialClosed()
			end )
		ui.CloseButton = c
		c:SetWidth( 145 )
		c:SetFont( "$(BOLD_FONT)|$(KB_20)" )
	end

	return ui
end

local TUTORIAL_DIALOG_WIDTH = 360

function EHT.UI.ShowTutorialDialog( anchorControl, headerTitle, caption, disableButtonCaption, closeButtonCaption, disableButtonHandler, closeButtonHandler )
	if nil == anchorControl or "userdata" ~= type( anchorControl ) then
		--EHT.UI.OnTutorialClosed()
		return false
	end

	local ui = EHT.UI.SetupTutorialDialog()

	if not isUIHidden then
		ui.Window:SetHidden( false )
	else
		EHT.UI.SetDialogHidden( EHT.CONST.DIALOG.TUTORIAL )
	end

	if nil == disableButtonCaption then disableButtonCaption = "No more tips" end
	if nil == closeButtonCaption then closeButtonCaption = "Ok, got it" end

	if "" ~= disableButtonCaption then
		ui.DisableTutorialsButton:SetText( disableButtonCaption )
		ui.DisableTutorialsButton:SetHidden( false )
		ui.DisableTutorialsButton:SetHandler(
			"OnClicked",
			function()
				EHT.UI.HideTutorialDialog()
				if disableButtonHandler then
					disableButtonHandler( self )
				else
					EHT.Tutorials.DisableTutorials( true )
				end
			end )
	else
		ui.DisableTutorialsButton:SetHidden( true )
	end

	if "" ~= closeButtonCaption then
		ui.CloseButton:SetText( closeButtonCaption )
		ui.CloseButton:SetHidden( false )
		ui.CloseButton:SetHandler(
			"OnClicked",
			function()
				EHT.UI.HideTutorialDialog()
				if closeButtonHandler then
					closeButtonHandler( self )
				else
					EHT.UI.OnTutorialClosed()
				end
			end )
	else
		ui.CloseButton:SetHidden( true )
	end

	local win = ui.Window
	win:ClearAnchors()
	win:SetDimensions( TUTORIAL_DIALOG_WIDTH, 800 )
	ui.Title:SetText( headerTitle )
	ui.Caption:SetText( caption )

	local centerX, centerY = GuiRoot:GetCenter()
	local titleWidth, titleHeight = ui.Title:GetTextDimensions()
	local captionWidth, captionHeight = ui.Caption:GetTextDimensions()
	captionHeight = math.max( captionHeight, 40 )
	win:SetDimensions( zo_clamp( captionWidth + 20, TUTORIAL_DIALOG_WIDTH, 1.5 * TUTORIAL_DIALOG_WIDTH ), captionHeight + titleHeight + 60 )

	if anchorControl == GuiRoot then
		win:SetAnchor( TOP, anchorControl, CENTER, 0, 0 )
		ui.DownArrow:SetHidden( true )
		ui.UpArrow:SetHidden( false )
	else
		local controlX, controlY = anchorControl:GetCenter()
		if controlY <= centerY then
			win:SetAnchor( TOP, anchorControl, BOTTOM, 0, 70 )
			ui.DownArrow:SetHidden( true )
			ui.UpArrow:SetHidden( false )
		else
			win:SetAnchor( BOTTOM, anchorControl, TOP, 0, -70 )
			ui.DownArrow:SetHidden( false )
			ui.UpArrow:SetHidden( true )
		end
	end

	return true
end

function EHT.UI.ShowNextTutorial( includeShown )
	local anchorControl, title, caption, disableCaption, disableHandler = EHT.Tutorials.GetNextTutorial( includeShown )

	if nil ~= anchorControl then
		EHT.UI.ShowTutorialDialog( anchorControl, title, caption, disableCaption, nil, disableHandler, nil )
		return true
	end

	if includeShown then
		EHT.UI.ShowTutorialDialog( EHT.UI.ToolDialog.Window, "No Tips Here Yet", "There are no Tips for here just yet, but be sure to check back in a future update..." )
	end

	return false
end

function EHT.UI.OnTutorialClosed()
	EHT.UI.ShowNextTutorial()
end

---[ Triggers Tab ]---

function EHT.UI.ShowTriggerPointers()
	local ui = EHT.UI.ToolDialog
	if nil == ui or ui.Window:IsHidden() then return end

	for index, condition in ipairs( ui.Conditions ) do
		local furnitureId = condition.TriggerConditionItemFurnitureId

		if nil ~= furnitureId then
			local x, y, z = EHT.Housing.GetFurnitureCenter( furnitureId )

			if nil ~= x and 0 ~= x then
				if 1 == index then
					zo_callLater( function()
						EHT.Pointers.SetSelected( x, y, z, nil, 1, 1, 1 )
					end, 500 )
				else
					zo_callLater( function()
						EHT.Pointers.SetSelected2( x, y, z, nil, 1, 1, 1 )
					end, 500 )
				end
			else
				if 1 == index then EHT.Pointers.ClearSelected() else EHT.Pointers.ClearSelected2() end
			end
		else
			if 1 == index then EHT.Pointers.ClearSelected() else EHT.Pointers.ClearSelected2() end
		end

		if nil == condition.TriggerConditionPositionX then
			if 1 == index then
				EHT.Pointers.ClearSelectRadius()
			else
				EHT.Pointers.ClearSelectRadius2()
			end
		else
			EHT.UI.SetTriggerRadiusCheck( true )
		end
	end
end

function EHT.UI.UpdateTriggerScrollExtents( )
	local ui = EHT.UI.ToolDialog
	if nil == ui or ui.Window:IsHidden() then return end

	local _, scrollHeight = ui.TriggerScroll:GetScrollExtents()
	local hidden = 0 >= math.floor( scrollHeight )

	ui.TriggerSlider:SetMinMax( 0, scrollHeight )
	ui.TriggerSlider:SetHidden( hidden )
	ui.TriggerSliderDown:SetHidden( hidden )
	ui.TriggerSliderUp:SetHidden( hidden )
end

function EHT.UI.OnTriggerRadiusCheck()
	if isUIHidden then return end

	local ui = EHT.UI.ToolDialog
	if nil == ui or EHT.CONST.TOOL_TABS.TRIGGERS ~= EHT.UI.GetCurrentToolTab() then
		EHT.UI.SetTriggerRadiusCheck( false )
		return
	end

	local conditionType = EHT.Util.Trim( ui.Conditions[1].TriggerConditionList:GetSelectedItem() )
	local conditionType2 = EHT.Util.Trim( ui.Conditions[2].TriggerConditionList:GetSelectedItem() )

	if conditionType ~= EHT.CONST.TRIGGER_CONDITION.ENTER_POSITION and conditionType ~= EHT.CONST.TRIGGER_CONDITION.LEAVE_POSITION and conditionType2 ~= EHT.CONST.TRIGGER_CONDITION.ENTER_POSITION and conditionType2 ~= EHT.CONST.TRIGGER_CONDITION.LEAVE_POSITION then
		EHT.UI.SetTriggerRadiusCheck( false )
		return
	end

	for index, condition in ipairs( ui.Conditions ) do
		local conditionType = EHT.Util.Trim( condition.TriggerConditionList:GetSelectedItem() )
		local isEnter = nil
		
		if conditionType == EHT.CONST.TRIGGER_CONDITION.ENTER_POSITION then isEnter = true end
		if conditionType == EHT.CONST.TRIGGER_CONDITION.LEAVE_POSITION then isEnter = false end
		
		if nil ~= isEnter then
			local radius = tonumber( condition.TriggerConditionRadius:GetText() )
			local x, y, z = tonumber( condition.TriggerConditionPositionX ), tonumber( condition.TriggerConditionPositionY ), tonumber( condition.TriggerConditionPositionZ )

			if nil ~= radius and nil ~= x and nil ~= y and nil ~= z then
				local valid = false
				if isEnter then
					valid = EHT.Biz.IsAnyUnitInRadius( x, y, z, radius * 100 )
				else
					valid = not EHT.Biz.IsAnyUnitInRadius( x, y, z, radius * 100 )
				end

				condition.TriggerConditionPositionValid:SetHidden( not valid )
				condition.TriggerConditionPositionInvalid:SetHidden( valid )

				if 1 == index then
					EHT.Pointers.SetSelectRadius( x, y, z, radius * 2, not valid and 1 or 0, valid and 1 or 0, 0, 0.65 )
				else
					EHT.Pointers.SetSelectRadius2( x, y, z, radius * 2, not valid and 1 or 0, valid and 1 or 0, 0, 0.65 )
				end
			end
		end
	end
end

function EHT.UI.SetTriggerRadiusCheck( enabled )
	EVENT_MANAGER:UnregisterForUpdate( EHT.TRIGGER_CHECK_RADIUS_ID )

	if enabled then
		EVENT_MANAGER:RegisterForUpdate( EHT.TRIGGER_CHECK_RADIUS_ID, EHT.TRIGGER_CHECK_RADIUS_INTERVAL, EHT.UI.OnTriggerRadiusCheck )
	else
		EHT.Pointers.ClearSelectRadius()
	end
end

function EHT.UI.RefreshTriggers( queueId )
	if nil ~= queuedId and queuedId ~= EHT.UI.QueuedRefreshTriggersId then return end
	EHT.UI.QueuedRefreshTriggersId = nil

	if EHT.CONST.TOOL_TABS.TRIGGERS ~= EHT.UI.GetCurrentToolTab() then return end

	local ui = EHT.UI.ToolDialog
	if nil == ui or ui.Window:IsHidden() then return end

	local triggerList, triggerDesc = ui.TriggerList, nil
	local detailedList = true == EHT.GetSetting("ShowDetailedTriggerList")

	triggerList:SetItemLines( detailedList and 6 or 1 )
	triggerList:ClearItems()
	triggerList:SetSelectedItem( nil )

	local triggers = EHT.Data.GetTriggers()
	if nil == triggers then return end

	for triggerIndex, trigger in pairs( triggers ) do
		triggerDesc = detailedList and EHT.Data.GetTriggerString( trigger ) or trigger.Name
		triggerList:AddItem( triggerDesc, function() EHT.Biz.LoadTrigger( triggerIndex ) end )

		if triggerIndex == ui.TriggerIndex then
			triggerList:SetSelectedItem( triggerDesc )
		end
	end

	EHT.UI.ShowTriggerPointers()
	EHT.UI.SetTriggerRadiusCheck( true )
end

function EHT.UI.QueueRefreshTriggers()
	EHT.UI.QueuedRefreshTriggersId = zo_callLater( function( id ) EHT.UI.RefreshTriggers( id ) end, 10 )
end

function EHT.UI.TriggerConditionInvalid( ctrl )
	local ui = EHT.UI.ToolDialog
	if nil == ui then return end

	ctrl:SetSelectedItem( EHT.CONST.TRIGGER_CONDITION.FURNITURE_STATE )
	zo_callLater( function() EHT.UI.TriggerChanged() end, 200 )
end

function EHT.UI.TriggerChanged()
	local uid = EHT.UI.ToolDialog
	if nil == uid then return end

	local house = EHT.Data.GetCurrentHouseRecords()
	if nil == house then return end

	EHT.UI.SetTriggerRadiusCheck( false )

	local function processCondition( ui )
		-- Trigger Conditions

		local list, entry, entries, currentEntry
		local conditionType = EHT.Util.Trim( ui.TriggerConditionList:GetSelectedItem() )

		ui.TriggerConditionDayTime = nil
		ui.TriggerConditionNightTime = nil
		if conditionType == EHT.CONST.TRIGGER_CONDITION.DAY_TIME then
			ui.TriggerConditionDayTime = true
		elseif conditionType == EHT.CONST.TRIGGER_CONDITION.NIGHT_TIME then
			ui.TriggerConditionNightTime = true
		end

		if conditionType == EHT.CONST.TRIGGER_CONDITION.FURNITURE_STATE then
			ui.TriggerConditionItemContainer:SetHidden( false )
		else
			ui.TriggerConditionItemContainer:SetHidden( true )
			ui.TriggerConditionItemFurnitureId = nil
		end

		if conditionType == EHT.CONST.TRIGGER_CONDITION.PHRASE then
			ui.TriggerConditionPhraseContainer:SetHidden( false )
		else
			ui.TriggerConditionPhraseContainer:SetHidden( true )
			ui.TriggerConditionPhrase:SetText( "" )
		end

		if conditionType == EHT.CONST.TRIGGER_CONDITION.ENTER_POSITION or conditionType == EHT.CONST.TRIGGER_CONDITION.LEAVE_POSITION then
			ui.TriggerConditionPositionContainer:SetHidden( false )
			local radius = tonumber( ui.TriggerConditionRadius:GetText() )
			if nil == radius or 0 > radius then ui.TriggerConditionRadius:SetText( "" ) end
			EHT.UI.SetTriggerRadiusCheck( true )
		else
			ui.TriggerConditionPositionContainer:SetHidden( true )
			ui.TriggerConditionPositionX, ui.TriggerConditionPositionY, ui.TriggerConditionPositionZ = nil, nil, nil
		end

		if conditionType == EHT.CONST.TRIGGER_CONDITION.EMOTE then
			ui.TriggerConditionEmoteContainer:SetHidden( false )
		else
			ui.TriggerConditionEmoteContainer:SetHidden( true )
			ui.TriggerConditionEmoteList:SetSelectedItem( "" )
		end

		if conditionType == EHT.CONST.TRIGGER_CONDITION.QUICKSLOT then
			ui.TriggerConditionQuickslotContainer:SetHidden( false )
		else
			ui.TriggerConditionQuickslotContainer:SetHidden( true )
			ui.TriggerConditionQuickslotLink:SetText( "No item selected" )
		end

		if conditionType == EHT.CONST.TRIGGER_CONDITION.INTERACT_TARGET then
			ui.TriggerConditionInteractContainer:SetHidden( false )
		else
			ui.TriggerConditionInteractContainer:SetHidden( true )
			ui.TriggerConditionInteractTarget:SetText( "No target selected" )
		end

		-- Trigger Field Dependencies

		if "" == ui.TriggerConditionItem:GetText() or string.find( ui.TriggerConditionItem:GetText(), "(Missing)" ) then
			ui.TriggerConditionStateList:SetEnabled( false )
		else
			ui.TriggerConditionStateList:SetEnabled( true )
		end
	end

	processCondition( uid.Conditions[1] )
	processCondition( uid.Conditions[2] )

	-- Trigger Action: Group list

	local ui = uid

	list = ui.TriggerActionGroupList
	currentEntry = list:GetSelectedItem()

	entries = { }
	for groupName, group in pairs( house.Groups ) do
		if groupName ~= EHT.CONST.GROUP_DEFAULT then
			table.insert( entries, groupName )
		end
	end
	table.sort( entries )

	list:ClearItems()
	list:AddItem( EHT.CONST.TRIGGER_DEFAULT_GROUP, EHT.UI.TriggerChanged )
	for _, entryName in ipairs( entries ) do
		list:AddItem( entryName, EHT.UI.TriggerChanged )
	end

	if nil == currentEntry or "" == currentEntry then
		list:SetSelectedItem( EHT.CONST.TRIGGER_DEFAULT_GROUP )
	else
		list:SetSelectedItem( currentEntry )
	end

	-- Trigger Action: Scene list

	list = ui.TriggerActionSceneList
	currentEntry = list:GetSelectedItem()
	
	entries = { }
	for sceneName, scene in pairs( house.Scenes ) do
		if sceneName ~= EHT.CONST.SCENE_DEFAULT then
			table.insert( entries, sceneName )
		end
	end
	table.sort( entries )

	list:ClearItems()
	list:AddItem( EHT.CONST.TRIGGER_DEFAULT_SCENE, EHT.UI.TriggerChanged )
	for _, entryName in ipairs( entries ) do
		list:AddItem( entryName, EHT.UI.TriggerChanged )
	end

	if nil == currentEntry or "" == currentEntry then
		list:SetSelectedItem( EHT.CONST.TRIGGER_DEFAULT_SCENE )
	else
		list:SetSelectedItem( currentEntry )
	end

	-- Trigger Action: Trigger list

	list = ui.TriggerActionTriggerList
	currentEntry = list:GetSelectedItemValue()

	entries = { }
	for index, trigger in pairs( EHT.Data.GetTriggers() ) do
		table.insert( entries, trigger )
	end
	table.sort( entries, function( triggerA, triggerB ) return triggerA.Name < triggerB.Name end )

	list:ClearItems()
	list:AddItem( EHT.CONST.TRIGGER_DEFAULT_TRIGGER, EHT.UI.TriggerChanged )
	for _, trigger in ipairs( entries ) do
		list:AddItem( trigger.Name, function() end, trigger.UniqueId )
	end

	if nil == currentEntry or "" == currentEntry then
		list:SetSelectedItem( EHT.CONST.TRIGGER_DEFAULT_TRIGGER )
	else
		list:SetSelectedItem( tonumber( currentEntry ) )
	end

	if EHT.CONST.TRIGGER_DEFAULT_GROUP == ui.TriggerActionGroupList:GetSelectedItem() then
		ui.TriggerActionGroupStateList:SetEnabled( false )
	else
		ui.TriggerActionGroupStateList:SetEnabled( true )
	end

	zo_callLater( EHT.UI.UpdateTriggerScrollExtents, 10 )
end

function EHT.UI.SetTriggerConditionItem( index )
	local ui = EHT.UI.ToolDialog
	if nil == ui then return end

	EHT.UI.InitChooseAnItem()
	EHT.UI.ChooseAnItem( function( ... ) EHT.Biz.ChooseTriggerItem( index, ... ) end, nil, nil, nil, "Select Trigger item" )
end

------[[ Effects Settings Auto Adjustment ]]------

function EHT.UI.ShowEffectsRelatedSettingsAdjustmentPrompt( forcePrompt )
	if forcePrompt then
		EHT.Effect:AdjustEffectsRelatedSettings()
		
		if "Always" == EHT.CONST.ADJUST_FX_SETTINGS[EHT.GetSetting("AdjustFXSettings")] then
			EHT.UI.ShowAlertDialog( "", "Your video settings have been temporarily adjusted to support the display of FX." )
		else
			EHT.ShownPromptForAutomaticEffectsSettingAdjustment = true
			EHT.UI.ShowConfirmationDialog( "", "Your video settings have been temporarily adjusted to support the display of FX.\n\n" ..
				"Would you like your video settings temporarily adjusted during future visits to homes with FX automatically?",
				function()
					local ALWAYS_ADJUST = true
					EHT.Effect:AdjustEffectsRelatedSettings( ALWAYS_ADJUST )
				end
			)
		end
	else
		EHT.UI.ShowConfirmationDialog( "", "" ..
			"This home has FX which may not display properly with your current video settings.\n\n" ..
			"May we temporarily adjust your video settings until you leave this home?\n\n" ..
			"Note that you may enable or disable this notification at any time from:\n" ..
			"Settings || Addons || Essential Housing Tools",
			function()
				EHT.Effect:AdjustEffectsRelatedSettings()
				if not EHT.ShownPromptForAutomaticEffectsSettingAdjustment then
					EHT.ShownPromptForAutomaticEffectsSettingAdjustment = true
					EHT.UI.ShowConfirmationDialog( "", "Would you like your video settings temporarily adjusted during future visits to homes with FX automatically?",
						function()
							local ALWAYS_ADJUST = true
							EHT.Effect:AdjustEffectsRelatedSettings( ALWAYS_ADJUST )
						end
					)
				end
			end
		)
	end
end

function EHT.UI.ConfirmEffectsRelatedSettingsPrompt()
	EHT.UI.ShowConfirmationDialog( "", "Your video settings are already properly configured to support the display of FX." )
end

------[[ HUD : Item Information ]]------

function EHT.UI.IsItemInfoDialogHidden()
	local ui = EHT.UI.ItemInfoDialog
	if ui then
		return ui.Window:IsHidden()
	else
		return true
	end
end

function EHT.UI.HideItemInfoDialog( forceHidden )
	local ui = EHT.UI.ItemInfoDialog
	if ui then
		if not forceHidden and ui.hideOnMovement then
			return
		end

		ui.Window:SetHidden( true )
		EHT.UI.ItemInfoFurnitureId = nil
		EHT.UI.ItemInfoItemId = nil
		EVENT_MANAGER:UnregisterForUpdate( EHT.ADDON_NAME .. "ItemInfo" )
	end
end

do
	local function AnchorBelow( control, parent, verticalMargin )
		verticalMargin = verticalMargin or 0
		control:ClearAnchors()
		control:SetAnchor( TOPLEFT, parent, BOTTOMLEFT, 0, verticalMargin )
		control:SetAnchor( TOPRIGHT, parent, BOTTOMRIGHT, 0, verticalMargin )
	end

	function EHT.UI.SetupItemInfoDialog()
		local ui = EHT.UI.ItemInfoDialog

		if nil == ui then
			ui = { }
			EHT.UI.ItemInfoDialog = ui

			local windowName = "ItemInfoDialog"
			local prefix = "EHTItemInfoDialog"
			local settings = EHT.UI.GetDialogSettings( windowName )

			ui.X_MARGIN, ui.Y_MARGIN = 20, 40
			ui.MIN_WIDTH, ui.MAX_WIDTH = 400, 400
			ui.MIN_HEIGHT, ui.MAX_HEIGHT = 56, 1000

			-- Window Controls

			local c, grp, win

			win = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
			ui.Window = win
			win:SetDimensionConstraints( ui.MIN_WIDTH, ui.MIN_HEIGHT, ui.MAX_WIDTH, ui.MAX_HEIGHT )
			win:SetMovable( true )
			win:SetMouseEnabled( true )
			win:SetClampedToScreen( true )
			win:SetResizeHandleSize( 0 )
			win:SetAlpha( 1 )

			if settings.Top and settings.Left then
				win:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, settings.Left, settings.Top )
			else
				win:SetAnchor( TOPRIGHT, GuiRoot, TOPRIGHT, -10, 10 )
			end

			win:SetDimensions( ui.MAX_WIDTH, ui.MIN_HEIGHT )

			c = EHT.CreateControl( prefix .. "Backdrop", win, CT_TEXTURE )
			ui.Backdrop = c
			c:SetExcludeFromResizeToFitExtents( true )
			c:SetColor( 0, 0, 0, 0.7 )
			c:SetAnchor( TOPLEFT, win, TOPLEFT, 0, 0 )
			c:SetAnchor( BOTTOMRIGHT, win, BOTTOMRIGHT, 0, 0 )
			c:SetMouseEnabled( false )

			grp = EHT.CreateControl( prefix .. "ItemInfoGroup", win, CT_CONTROL )
			ui.ItemInfoGroup = grp
			grp:SetDimensionConstraints( ui.MIN_WIDTH - ui.X_MARGIN, ui.MIN_HEIGHT - ui.Y_MARGIN, ui.MAX_WIDTH - ui.X_MARGIN, ui.MAX_HEIGHT - ui.Y_MARGIN )
			grp:SetAnchor( TOPLEFT, win, TOPLEFT, 0.5 * ui.X_MARGIN, 0.75 * ui.Y_MARGIN )
			grp:SetResizeToFitDescendents( true )
			grp:SetMouseEnabled( false )
			
			c = EHT.CreateControl( prefix .. "ItemIcon", win, CT_TEXTURE )
			ui.ItemIcon = c
			c:SetColor( 1, 1, 1, 1 )
			--c:SetAnchor( BOTTOM, grp, TOP, 0, -6 )
			c:SetAnchor( CENTER, win, TOP, 0, 0 )
			c:SetDimensions( 52, 52 )
			c:SetMouseEnabled( false )
			c:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 1.5 )

			c = EHT.CreateControl( prefix .. "ItemLabel", grp, CT_LABEL )
			ui.ItemLabel = c
			c:SetColor( 1, 1, 1, 1 )
			c:SetFont( "$(BOLD_FONT)|$(KB_20)" )
			c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
			c:SetVerticalAlignment( TEXT_ALIGN_TOP )
			c:SetAnchor( TOPLEFT, grp, TOPLEFT, 0, 0 )
			c:SetAnchor( TOPRIGHT, grp, TOPRIGHT, 0, 0 )
			c:SetMaxLineCount( 3 )
			c:SetWrapMode( TEXT_WRAP_MODE_ELLIPSIS )
			c:SetMouseEnabled( true )
			c:SetLinkEnabled( true )
			c:SetHandler( "OnLinkMouseUp", function( self, linkText, link, button )
				if IsShiftKeyDown() or IsControlKeyDown() then
					ZO_LinkHandler_InsertLink( link )
				else
					ZO_LinkHandler_OnLinkMouseUp( link, button, self )
				end
			end )
			EHT.UI.SetInfoTooltip( c, "|c00ffffClick|r for tooltip\n|c00ffffShift+Click|r to link to chat" )

			c = EHT.CreateControl( prefix .. "ItemLimit", grp, CT_LABEL )
			ui.ItemLimit = c
			c:SetColor( 1, 1, 1, 1 )
			c:SetFont( "$(CHAT_FONT)|$(KB_14)" )
			c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
			c:SetVerticalAlignment( TEXT_ALIGN_TOP )
			AnchorBelow( c, ui.ItemLabel, 2 )
			c:SetWrapMode( TEXT_WRAP_MODE_ELLIPSIS )
			c:SetMouseEnabled( false )

			c = EHT.CreateControl( prefix .. "ItemOrientation", grp, CT_LABEL )
			ui.ItemOrientation = c
			c:SetColor( 1, 1, 1, 1 )
			c:SetFont( "$(CHAT_FONT)|$(KB_16)" )
			c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
			c:SetVerticalAlignment( TEXT_ALIGN_TOP )
			AnchorBelow( c, ui.ItemLimit, 8 )
			c:SetMaxLineCount( 1 )
			c:SetWrapMode( TEXT_WRAP_MODE_ELLIPSIS )
			c:SetMouseEnabled( false )

			c = EHT.CreateControl( prefix .. "ItemPosition", grp, CT_LABEL )
			ui.ItemPosition = c
			c:SetColor( 1, 1, 1, 1 )
			c:SetFont( "$(CHAT_FONT)|$(KB_16)" )
			c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
			c:SetVerticalAlignment( TEXT_ALIGN_TOP )
			AnchorBelow( c, ui.ItemOrientation, 2 )
			c:SetMaxLineCount( 1 )
			c:SetWrapMode( TEXT_WRAP_MODE_ELLIPSIS )
			c:SetMouseEnabled( false )

			c = EHT.CreateControl( prefix .. "ItemDimensions", grp, CT_LABEL )
			ui.ItemDimensions = c
			c:SetColor( 1, 1, 1, 1 )
			c:SetFont( "$(CHAT_FONT)|$(KB_16)" )
			c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
			c:SetVerticalAlignment( TEXT_ALIGN_TOP )
			AnchorBelow( c, ui.ItemPosition, 2 )
			c:SetMaxLineCount( 1 )
			c:SetWrapMode( TEXT_WRAP_MODE_ELLIPSIS )
			c:SetMouseEnabled( false )

			c = EHT.CreateControl( prefix .. "ItemDecoTrack", grp, CT_LABEL )
			ui.ItemDecoTrack = c
			c:SetColor( 1, 1, 1, 1 )
			c:SetFont( "$(CHAT_FONT)|$(KB_16)" )
			c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
			c:SetVerticalAlignment( TEXT_ALIGN_TOP )
			AnchorBelow( c, ui.ItemDimensions, 8 )
			c:SetMaxLineCount( 10 )
			c:SetWrapMode( TEXT_WRAP_MODE_ELLIPSIS )
			c:SetMouseEnabled( false )

			zo_callLater( EHT.UI.ResizeItemInfoDialog, 10 )

			win:SetHandler( "OnMoveStop", function() EHT.UI.SaveDialogSettings( windowName, win ) end )
		end

		return ui
	end

	function EHT.UI.SetItemInfoPositionHidden( hidden )
		local ui = EHT.UI.ItemInfoDialog
		if nil == ui then return end

		ui.ItemPosition:SetHidden( hidden )
		ui.ItemOrientation:SetHidden( hidden )

		if hidden then
			AnchorBelow( ui.ItemDimensions, ui.ItemLimit, 8 )
		else
			AnchorBelow( ui.ItemDimensions, ui.ItemPosition, 2 )
		end
	end
end

function EHT.UI.ResizeItemInfoDialog()
	local ui = EHT.UI.ItemInfoDialog
	if nil == ui then return end

	local width, height = ui.ItemInfoGroup:GetDimensions()
	ui.Window:SetDimensions( width + ui.X_MARGIN, height + ui.Y_MARGIN )
end

function EHT.UI.ShowItemInfoDialog( id, nodeIndex, hideOnMovement )
	if not hideOnMovement and not EHT.SavedVars.EnableHUDItemData then
		return
	end

	local ui = EHT.UI.SetupItemInfoDialog()
	ui.Window:SetHidden( false )
	ui.hideOnMovement = true == hideOnMovement

	EHT.UI.ItemInfoStartingPosition = { GetPlayerWorldPositionInHouse() }
	if id then
		EHT.UI.ItemInfoFurnitureId = id
	else
		EHT.UI.ItemInfoFurnitureId = nil
	end
	
	EHT.UI.RefreshItemInfoDialog( id, nodeIndex )
	
	if EHT.Housing.IsPlacementMode() then
		EVENT_MANAGER:RegisterForUpdate( EHT.ADDON_NAME .. "ItemInfo", 500, EHT.UI.RefreshItemInfoDialog )
	end
end

function EHT.UI.RefreshItemInfoDialog()
	local ui = EHT.UI.SetupItemInfoDialog()

	local id = EHT.UI.ItemInfoFurnitureId
	if not id or id == 0 then
		id = HousingEditorGetSelectedFurnitureId()
	end
	if not id or id == 0 then
		id = HousingEditorGetTargetInfo()
	end
	if id == 0 then
		id = nil
	end

	if nil == id or nil == ui or ( not ui.hideOnMovement and not EHT.SavedVars.EnableHUDItemData ) then
		EHT.UI.HideItemInfoDialog()
		return
	end
	
	if ui.hideOnMovement then
		local position = EHT.UI.ItemInfoStartingPosition
		if position then
			local playerX, playerY, playerZ = GetPlayerWorldPositionInHouse()
			if 3 < zo_distance3D( position[1], position[2], position[3], playerX, playerY, playerZ ) then
				local FORCE = true
				EHT.UI.HideItemInfoDialog( FORCE )
				return
			end
		end
	end

	local x, y, z, pitch, yaw, roll, itemId, collectibleId, link, itemName, icon, dataId, limitType = EHT.Housing.GetFurnitureInfo( id )
	local sizeX, sizeY, sizeZ = EHT.Housing.GetFurnitureLocalDimensions( id )
	local pX, pY, pZ, pYaw = GetPlayerWorldPositionInHouse()
	local cData = "|cffff33"

	if nil == x or nil == y or nil == z or ( 0 == x and 0 == y and 0 == z ) then
		local FORCE = true
		EHT.UI.HideItemInfoDialog( FORCE )
		return
	end

	x, y, z = x, y, z
	pX, pY, pZ = pX, pY, pZ
	sizeX, sizeY, sizeZ = sizeX, sizeY, sizeZ
	
	local dist = zo_distance3D( x, y, z, pX, pY, pZ )
	local limitName, limitMax, limitUsed = EHT.Housing.GetLimit( limitType )

	ui.ItemOrientation:SetText( string.format( "|rpitch: %s%.2f|rdeg  yaw: %s%.2f|rdeg  roll: %s%.2f|rdeg", cData, math.deg( pitch or 0 ), cData, math.deg( yaw or 0 ), cData, math.deg( roll or 0 ) ) )
	ui.ItemPosition:SetText( string.format( "|rx: %s%d|rcm  y: %s%d|rcm  z: %s%d|rcm  (%s%d|rcm away)", cData, x or 0, cData, y or 0, cData, z or 0, cData, dist ) )
	ui.ItemDimensions:SetText( string.format( "|rwidth: %s%d|rcm  height: %s%d|rcm  depth: %s%d|rcm", cData, sizeX, cData, sizeY, cData, sizeZ ) )
	ui.ItemLimit:SetText( string.format( "|r%s", limitName or "Item" ) )

	if itemId ~= EHT.UI.ItemInfoItemId then
		if "|H1" == string.sub( link, 1, 3 ) then
			link = "|H0" .. string.sub( link, 4 )
		end

		EHT.UI.ItemInfoItemId = itemId
		ui.ItemIcon:SetTexture( icon )
		ui.ItemLabel:SetText( link )

		ui.Window:SetDimensions( ui.MAX_WIDTH, ui.MIN_HEIGHT )
		local containerString

		if EHT.SavedVars.EnableHUDDecoTrackData then
			local containers, boundContainers = EHT.Interop.GetDecoTrackCountsByItemId( itemId )
			if nil ~= containers and "table" == type( containers ) then
				boundContainers = boundContainers or { }
				local containerCounts = { }
				local totalCount = 0

				for containerName, itemCount in pairs( containers ) do
					local boundCount = boundContainers[ containerName ] or 0
					table.insert( containerCounts, EHT.UI.CreateItemStockString( containerName, itemCount, boundCount ) )
					totalCount = totalCount + ( itemCount or 0 )
				end

				table.sort( containerCounts )

				if 0 < totalCount then
					table.insert( containerCounts, EHT.UI.CreateItemStockString( "|cffffffTotal", totalCount, boundCount ) )
				end

				for index, cString in ipairs( containerCounts ) do
					containerString = string.format( "%s%s", nil ~= containerString and ( containerString .. "\n" ) or "", cString )
				end
			end
		end

		ui.ItemDecoTrack:SetText( containerString or "" )

		EHT.UI.SetItemInfoPositionHidden( not EHT.Housing.IsOwner() and not HasAnyEditingPermissionsForCurrentHouse() )
	end

	zo_callLater( EHT.UI.ResizeItemInfoDialog, 10 )
end

function EHT.UI.OnItemInfoDialogInspectionTargetChanged()
	local isSelectionMode = EHT.Housing.IsSelectionMode()
	if not (isSelectionMode or EHT.Housing.IsPlacementMode()) then
		EHT.UI.HideItemInfoDialog()
		return
	end

	local id = nil
	if isSelectionMode then
		id = HousingEditorGetTargetInfo()
	else
		id = HousingEditorGetSelectedFurnitureId()
	end

	EHT.UI.ItemInfoFurnitureId = id
	if id == 0 or not id then
		EHT.UI.HideItemInfoDialog()
	elseif EHT.UI.IsItemInfoDialogHidden() then
		EHT.UI.ShowItemInfoDialog()
	else
		EHT.UI.RefreshItemInfoDialog()
	end
end

function EHT.UI.SetInspectionItemInfoDialogEnabled(enabled)
	EHT.IsInspectionItemInfoDialogEnabled = enabled

	if enabled then
		EVENT_MANAGER:RegisterForEvent("EHTInspectionItemInfoDialog", EVENT_HOUSING_EDITOR_MODE_CHANGED, EHT.UI.OnItemInfoDialogInspectionTargetChanged)
		EVENT_MANAGER:RegisterForEvent("EHTInspectionItemInfoDialog", EVENT_HOUSING_TARGET_FURNITURE_CHANGED, EHT.UI.OnItemInfoDialogInspectionTargetChanged)
	else
		EVENT_MANAGER:UnregisterForEvent("EHTInspectionItemInfoDialog", EVENT_HOUSING_EDITOR_MODE_CHANGED)
		EVENT_MANAGER:UnregisterForEvent("EHTInspectionItemInfoDialog", EVENT_HOUSING_TARGET_FURNITURE_CHANGED)
	end
end

---[ HUD : Notification ]---

function EHT.UI.SetupNotificationDialog()
	local ui = EHT.UI.NotificationDialog

	if nil == ui then
		ui = { }
		EHT.UI.NotificationDialog = ui

		local prefix = "EHTNotificationDialog"
		local c, grp, win

		win = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
		ui.Window = win
		win:SetAlpha( 0.5 )
		win:SetClampedToScreen( true )
		win:SetMouseEnabled( false )
		win:SetMovable( false )
		win:SetResizeHandleSize( 0 )
		win:SetAnchor( BOTTOM, GuiRoot, BOTTOM, 0, -340 )
		win:SetDimensions( 1, 100 )
		win:SetHidden( true )
		win:SetDrawLayer( DL_OVERLAY )
		win:SetDrawTier( DT_HIGH )
		win:SetDrawLevel( 230000 )

		c = CreateTexture( prefix .. "Backdrop", win, CreateAnchor( CENTER, win, CENTER, 0, 0 ), nil, nil, nil, EHT.Textures.SOLID, CreateColor( 0, 0, 0, 0.9 ) )
		ui.Backdrop = c
		c:SetBlendMode( TEX_BLEND_MODE_ALPHA )
		c:SetDrawLayer( DL_OVERLAY )
		c:SetDrawLevel( 230000 )
		c:SetDrawTier( DT_HIGH )

		c = EHT.CreateControl( prefix .. "Message", ui.Backdrop, CT_LABEL )
		ui.Message = c
		c:SetColor( 1, 1, 0.5, 1 )
		c:SetText( "" )
		c:SetFont( "$(BOLD_FONT)|$(KB_32)" )
		c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		c:SetVerticalAlignment( TEXT_ALIGN_TOP )
		c:SetMouseEnabled( false )
		c:SetAnchor( CENTER, ui.Backdrop, CENTER, 0, 0 )
		c:SetDrawLayer( DL_OVERLAY )
		c:SetDrawLevel( 230001 )
		c:SetDrawTier( DT_HIGH )
	end

	return ui
end

function EHT.UI.HideNotification()
	local ui = EHT.UI.SetupNotificationDialog()
	ui.Window:SetHidden( true )
end

function EHT.UI.FadeNotification()
	local ui = EHT.UI.NotificationDialog
	local alpha = ui.CurrentAlpha
	local beginTime = ui.BeginTransition or 0
	local endTime = ui.EndTransition or 0
	local ft = GetFrameTimeMilliseconds()
	local interp = ( ft - beginTime ) / ( endTime - beginTime )

	if ui.IsFading then
		alpha = 1 - interp
	else
		alpha = interp

		if 2 <= interp then
			ui.IsFading = true
			ui.BeginTransition = ft
			ui.EndTransition = ft + 2000
		end
	end

	ui.Window:SetAlpha( alpha )
	ui.CurrentAlpha = alpha

	if ui.IsFading and 0.01 > alpha then
		EHT.UI.HideNotification()
		EVENT_MANAGER:UnregisterForUpdate( EHT.ADDON_NAME .. "FadeNotification" )
	end
end

function EHT.UI.DisplayNotification( message, duration )
	if not message then
		return false
	end

	local ft = GetFrameTimeMilliseconds()
	local ui = EHT.UI.SetupNotificationDialog()
	duration = tonumber( duration ) or zo_clamp( ( #message / 16 ) * 400, 400, 4000 )

	ui.BeginTransition = ft
	ui.EndTransition = ft + duration
	ui.Message:SetText( message )
	ui.Backdrop:SetResizeToFitDescendents( true )
	ui.Backdrop:SetResizeToFitPadding( 16, 20 )
	ui.Window:SetHidden( false )
	ui.Window:SetAlpha( 0 )
	ui.CurrentAlpha = 0
	ui.IsFading = false
	EVENT_MANAGER:RegisterForUpdate( EHT.ADDON_NAME .. "FadeNotification", 20, EHT.UI.FadeNotification )

	return true
end

function EHT.UI.DisplaySelectionChangeNotification( count, isAdd )
	if 0 < count then
		msg = string.format( "%s %d item%s", isAdd and "Selected" or "Deselected", count, 1 == count and "" or "s" )
	else
		msg = "No items found"
	end

	if EHT.GetSetting("ShowSelectionInOSD") then
		EHT.UI.DisplayNotification( msg )
	end
end

---[ Dialog : Adjust Guidelines ]---

function EHT.UI.HideAdjustGuidelinesDialog()
	local ui = EHT.UI.AdjustGuidelinesDialog
	if nil ~= ui then ui.Window:SetHidden( true ) end
end

function EHT.UI.ShowAdjustGuidelinesDialog()
	local ui = EHT.UI.SetupAdjustGuidelinesDialog()
	if nil ~= ui then
		if not EHT.Biz.AreGuidelinesEnabled() then
			EHT.Biz.ToggleGuidelines( true, true )
			EHT.UI.RefreshEditToggles()
		end

		if GetHousingEditorMode() == HOUSING_EDITOR_MODE_DISABLED then
			HousingEditorRequestModeChange( HOUSING_EDITOR_MODE_SELECTION )
		end

		EHT.UI.RefreshAdjustGuidelinesDialog()
		ui.Window:SetHidden( false )
	end
end

function EHT.UI.RefreshAdjustGuidelinesDialog()
	local ui = EHT.UI.SetupAdjustGuidelinesDialog()
	if nil ~= ui then

		local enabled, originX, originY, originZ, originYaw, units, radius, maxDistance, alpha = EHT.Biz.GetGuidelinesSettings()
		local yawDegrees = math.deg( originYaw )
		if 0.1 > yawDegrees and -0.1 < yawDegrees then yawDegrees = 0
		elseif 0 > yawDegrees then yawDegrees = 90 + yawDegrees end

		ui.Scale:SetText( string.format( "%.2fm", units / 100 ) )
		ui.Offsets:SetText( string.format( "%.2fm, %.2fm", originX / 100, originZ / 100 ) )
		ui.Rotation:SetText( string.format( "%.2f deg", yawDegrees ) )
	end
end

function EHT.UI.SetupAdjustGuidelinesDialog()
	local ui = EHT.UI.AdjustGuidelinesDialog

	if nil == ui then
		ui = { }
		EHT.UI.AdjustGuidelinesDialog = ui

		-- Window

		local windowName = "AdjustGuidelinesDialog"
		local prefix = "EHTAdjustGuidelinesDialog"
		local c, grp, win

		win = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
		ui.Window = win
		win:SetHidden( true )
		win:SetDimensionConstraints( 500, 300, 500, 300 )
		win:SetMovable( false )
		win:SetMouseEnabled( true )
		win:SetClampedToScreen( true )
		win:SetResizeHandleSize( 0 )
		win:SetAlpha( 1 )
		win:SetAnchor( CENTER, GuiRoot, CENTER, 0, 3 )

		-- Movement Group

		grp = EHT.CreateControl( prefix .. "MovementGroup", win, CT_CONTROL )
		ui.MovementGroup = grp
		grp:SetAnchor( CENTER, win, CENTER, 0, 0 )
		grp:SetDimensions( 300, 300 )

		c = EHT.CreateControl( prefix .. "MoveEast", grp, CT_TEXTURE )
		ui.MoveEast = c
		c:SetAnchor( LEFT, grp, CENTER, 14, 0 )
		c:SetTexture( "esoui/art/crowncrates/gamepad/gp_gemification_arrow.dds" )
		c:SetDimensions( 128, 64 )
		c:SetVertexColors( 10, 0.0, 0.3, 0.4, 1.0 )
		c:SetVertexColors( 5, 0.2, 0.8, 1.0, 1.0 )
		c:SetMouseEnabled( true )

		EHT.Util.CreateAndAssignRepeaterButton( c,
			function()
				EHT.Pointers.AdjustGuidelines( ( IsControlKeyDown() or IsShiftKeyDown() ) and 2 or 10 )
			end )

		c = EHT.CreateControl( prefix .. "EastLabel", grp, CT_LABEL )
		ui.EastLabel = c
		c:SetColor( 1, 1, 1, 1 )
		c:SetText( "E" )
		c:SetFont( "$(CHAT_FONT)|$(KB_18)|thick-outline" )
		c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		c:SetVerticalAlignment( TEXT_ALIGN_CENTER )
		c:SetAnchor( CENTER, ui.MoveEast, CENTER, 0, -4 )
		c:SetMouseEnabled( false )

		c = EHT.CreateControl( prefix .. "MoveWest", grp, CT_TEXTURE )
		ui.MoveWest = c
		c:SetAnchor( RIGHT, grp, CENTER, -14, 0 )
		c:SetTexture( "esoui/art/crowncrates/gamepad/gp_gemification_arrow.dds" )
		c:SetTextureCoords( 1, 0, 0, 1 )
		c:SetDimensions( 128, 64 )
		c:SetVertexColors( 10, 0.0, 0.3, 0.4, 1.0 )
		c:SetVertexColors( 5, 0.2, 0.8, 1.0, 1.0 )
		c:SetMouseEnabled( true )

		EHT.Util.CreateAndAssignRepeaterButton( c,
			function()
				EHT.Pointers.AdjustGuidelines( ( IsControlKeyDown() or IsShiftKeyDown() ) and -2 or -10 )
			end )

		c = EHT.CreateControl( prefix .. "WestLabel", grp, CT_LABEL )
		ui.WestLabel = c
		c:SetColor( 1, 1, 1, 1 )
		c:SetText( "W" )
		c:SetFont( "$(CHAT_FONT)|$(KB_18)|thick-outline" )
		c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		c:SetVerticalAlignment( TEXT_ALIGN_CENTER )
		c:SetAnchor( CENTER, ui.MoveWest, CENTER, 1, -4 )
		c:SetMouseEnabled( false )

		c = EHT.CreateControl( prefix .. "MoveNorth", grp, CT_TEXTURE )
		ui.MoveNorth = c
		c:SetAnchor( BOTTOM, grp, CENTER, 4, -17 )
		c:SetTexture( "esoui/art/crowncrates/gamepad/gp_gemification_arrow.dds" )
		c:SetDimensions( 64, 128 )
		c:SetVertexColors( 10, 0.0, 0.3, 0.4, 1.0 )
		c:SetVertexColors( 5, 0.2, 0.8, 1.0, 1.0 )
		c:SetTextureCoordsRotation( 0.5 * math.pi )
		c:SetMouseEnabled( true )

		EHT.Util.CreateAndAssignRepeaterButton( c,
			function()
				EHT.Pointers.AdjustGuidelines( nil, nil, ( IsControlKeyDown() or IsShiftKeyDown() ) and -2 or -10 )
			end )

		c = EHT.CreateControl( prefix .. "NorthLabel", grp, CT_LABEL )
		ui.NorthLabel = c
		c:SetColor( 1, 1, 1, 1 )
		c:SetText( "N" )
		c:SetFont( "$(CHAT_FONT)|$(KB_18)|thick-outline" )
		c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		c:SetVerticalAlignment( TEXT_ALIGN_CENTER )
		c:SetAnchor( CENTER, ui.MoveNorth, CENTER, -3, 0 )
		c:SetMouseEnabled( false )

		c = EHT.CreateControl( prefix .. "MoveSouth", grp, CT_TEXTURE )
		ui.MoveSouth = c
		c:SetAnchor( TOP, grp, CENTER, -4, 9 )
		c:SetTexture( "esoui/art/crowncrates/gamepad/gp_gemification_arrow.dds" )
		c:SetTextureCoordsRotation( -0.5 * math.pi )
		c:SetDimensions( 64, 128 )
		c:SetVertexColors( 10, 0.0, 0.3, 0.4, 1.0 )
		c:SetVertexColors( 5, 0.2, 0.8, 1.0, 1.0 )
		c:SetMouseEnabled( true )

		EHT.Util.CreateAndAssignRepeaterButton( c,
			function()
				EHT.Pointers.AdjustGuidelines( nil, nil, ( IsControlKeyDown() or IsShiftKeyDown() ) and 2 or 10 )
			end )

		c = EHT.CreateControl( prefix .. "SouthLabel", grp, CT_LABEL )
		ui.SouthLabel = c
		c:SetColor( 1, 1, 1, 1 )
		c:SetText( "S" )
		c:SetFont( "$(CHAT_FONT)|$(KB_18)|thick-outline" )
		c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		c:SetVerticalAlignment( TEXT_ALIGN_CENTER )
		c:SetAnchor( CENTER, ui.MoveSouth, CENTER, 4, 0 )

		-- Scale Group

		grp = EHT.CreateControl( prefix .. "ScaleGroup", win, CT_CONTROL )
		ui.ScaleGroup = grp
		grp:SetAnchor( LEFT, win, LEFT, 0, 0 )
		grp:SetDimensions( 100, 300 )

		c = EHT.CreateControl( prefix .. "ScaleUp", grp, CT_TEXTURE )
		ui.ScaleUp = c
		c:SetAnchor( BOTTOM, grp, CENTER, 4, -38 )
		c:SetTexture( "esoui/art/crowncrates/gamepad/gp_gemification_arrow.dds" )
		c:SetDimensions( 64, 128 )
		c:SetVertexColors( 10, 0.0, 0.3, 0.4, 1.0 )
		c:SetVertexColors( 5, 0.2, 0.8, 1.0, 1.0 )
		c:SetTextureCoordsRotation( 0.5 * math.pi )
		c:SetMouseEnabled( true )

		EHT.Util.CreateAndAssignRepeaterButton( c,
			function()
				EHT.Pointers.AdjustGuidelines( nil, nil, nil, nil, ( IsControlKeyDown() or IsShiftKeyDown() ) and 5 or 50 )
			end )

		c = EHT.CreateControl( prefix .. "ScaleUpLabel", grp, CT_LABEL )
		ui.ScaleUpLabel = c
		c:SetColor( 1, 1, 1, 1 )
		c:SetText( "Larger" )
		c:SetFont( "$(CHAT_FONT)|$(KB_18)|thick-outline" )
		c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		c:SetVerticalAlignment( TEXT_ALIGN_CENTER )
		c:SetAnchor( TOP, ui.ScaleUp, BOTTOM, -3, 0 )
		c:SetMouseEnabled( false )

		c = EHT.CreateControl( prefix .. "ScaleDown", grp, CT_TEXTURE )
		ui.ScaleDown = c
		c:SetAnchor( TOP, grp, CENTER, -4, 30 )
		c:SetTexture( "esoui/art/crowncrates/gamepad/gp_gemification_arrow.dds" )
		c:SetTextureCoordsRotation( -0.5 * math.pi )
		c:SetDimensions( 64, 128 )
		c:SetVertexColors( 10, 0.0, 0.3, 0.4, 1.0 )
		c:SetVertexColors( 5, 0.2, 0.8, 1.0, 1.0 )
		c:SetMouseEnabled( true )

		EHT.Util.CreateAndAssignRepeaterButton( c,
			function()
				EHT.Pointers.AdjustGuidelines( nil, nil, nil, nil, ( IsControlKeyDown() or IsShiftKeyDown() ) and -5 or -50 )
			end )

		c = EHT.CreateControl( prefix .. "ScaleDownLabel", grp, CT_LABEL )
		ui.ScaleDownLabel = c
		c:SetColor( 1, 1, 1, 1 )
		c:SetText( "Smaller" )
		c:SetFont( "$(CHAT_FONT)|$(KB_18)|thick-outline" )
		c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		c:SetVerticalAlignment( TEXT_ALIGN_CENTER )
		c:SetAnchor( BOTTOM, ui.ScaleDown, TOP, 4, 0 )

		-- Rotate Group

		grp = EHT.CreateControl( prefix .. "RotateGroup", win, CT_CONTROL )
		ui.RotateGroup = grp
		grp:SetAnchor( RIGHT, win, RIGHT, 0, 0 )
		grp:SetDimensions( 100, 300 )

		c = EHT.CreateControl( prefix .. "RotateLabel", grp, CT_LABEL )
		ui.RotateLabel = c
		c:SetColor( 1, 1, 1, 1 )
		c:SetText( "Rotate" )
		c:SetFont( "$(CHAT_FONT)|$(KB_18)|thick-outline" )
		c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		c:SetVerticalAlignment( TEXT_ALIGN_CENTER )
		c:SetAnchor( CENTER, grp, CENTER, 0, 0 )
		c:SetMouseEnabled( false )

		c = EHT.CreateControl( prefix .. "RotateCW", grp, CT_TEXTURE )
		ui.RotateCW = c
		c:SetAnchor( TOP, grp, CENTER, 0, 20 )
		c:SetTexture( "esoui/art/housing/gamepad/gp_toolicon_rotate_y.dds" )
		c:SetTextureCoords( 1, 0, 0, 1 )
		c:SetDimensions( 96, 96 )
		c:SetVertexColors( 3, 0.0, 0.3, 0.4, 1.0 )
		c:SetVertexColors( 12, 0.2, 0.8, 1.0, 1.0 )
		c:SetMouseEnabled( true )

		EHT.Util.CreateAndAssignRepeaterButton( c,
			function()
				EHT.Pointers.AdjustGuidelines( nil, nil, nil, math.rad( ( IsControlKeyDown() or IsShiftKeyDown() ) and -0.11 or -1.0 ) )
			end )

		c = EHT.CreateControl( prefix .. "RotateCCW", grp, CT_TEXTURE )
		ui.RotateCCW = c
		c:SetAnchor( BOTTOM, grp, CENTER, 0, -18 )
		c:SetTexture( "esoui/art/housing/gamepad/gp_toolicon_rotate_y.dds" )
		c:SetDimensions( 96, 96 )
		c:SetVertexColors( 3, 0.0, 0.3, 0.4, 1.0 )
		c:SetVertexColors( 12, 0.2, 0.8, 1.0, 1.0 )
		c:SetMouseEnabled( true )

		EHT.Util.CreateAndAssignRepeaterButton( c,
			function()
				EHT.Pointers.AdjustGuidelines( nil, nil, nil, math.rad( ( IsControlKeyDown() or IsShiftKeyDown() ) and 0.11 or 1.0 ) )
			end )

		-- Close Group

		grp = EHT.CreateControl( prefix .. "CloseGroup", win, CT_CONTROL )
		ui.CloseGroup = grp
		grp:SetAnchor( TOP, win, BOTTOM, 0, 0 )
		grp:SetResizeToFitDescendents( true )

		c = EHT.CreateControl( prefix .. "CloseLabel", grp, CT_LABEL )
		ui.CloseLabel = c
		c:SetColor( 1, 1, 1, 1 )
		c:SetText( "CLOSE" )
		c:SetFont( "$(CHAT_FONT)|$(KB_26)|thick-outline" )
		c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		c:SetVerticalAlignment( TEXT_ALIGN_CENTER )
		c:SetAnchor( LEFT, grp, LEFT, 0, 0 )
		c:SetMouseEnabled( true )
		c:SetHandler( "OnMouseUp", EHT.UI.HideAdjustGuidelinesDialog )

		c = EHT.CreateControl( prefix .. "Close", grp, CT_TEXTURE )
		ui.Close = c
		c:SetAnchor( LEFT, ui.CloseLabel, RIGHT, 0, 0 )
		c:SetTexture( "esoui/art/miscellaneous/gamepad/gp_submit.dds" )
		c:SetTextureRotation( 0.5 * math.pi )
		c:SetDimensions( 64, 64 )
		c:SetVertexColors( 12, 0.0, 0.3, 0.4, 1.0 )
		c:SetVertexColors( 3, 0.2, 0.8, 1.0, 1.0 )
		c:SetMouseEnabled( true )
		c:SetHandler( "OnMouseUp", EHT.UI.HideAdjustGuidelinesDialog )

		c = EHT.CreateControl( prefix .. "InstructionLabel", win, CT_LABEL )
		ui.InstructionLabel = c
		c:SetColor( 1, 1, 1, 1 )
		c:SetMaxLineCount( 4 )
		c:SetText( "|c00ffffSHIFT|cffffff+|c00ffffCLICK|cffffff for precise adjustment\n" ..
			"|c00ffffCLICK|cffffff+|c00ffffHOLD|cffffff for continuous adjustment" )
		c:SetFont( "$(CHAT_FONT)|$(KB_16)|thick-outline" )
		c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		c:SetVerticalAlignment( TEXT_ALIGN_CENTER )
		c:SetAnchor( BOTTOM, grp, TOP, 0, -5 )
		c:SetMouseEnabled( false )

		-- Scale Header Group

		grp = EHT.CreateControl( prefix .. "ScaleHeaderGroup", win, CT_CONTROL )
		ui.ScaleHeaderGroup = grp
		grp:SetAnchor( BOTTOM, ui.ScaleGroup, TOP, 0, 0 )
		grp:SetDimensions( 100, 80 )

		c = EHT.CreateControl( prefix .. "Scale", grp, CT_LABEL )
		ui.Scale = c
		c:SetColor( 1, 1, 0, 1 )
		c:SetFont( "$(CHAT_FONT)|$(KB_32)|thick-outline" )
		c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		c:SetVerticalAlignment( TEXT_ALIGN_CENTER )
		c:SetAnchor( BOTTOM, grp, BOTTOM, 0, 0 )
		c:SetMouseEnabled( false )

		c = EHT.CreateControl( prefix .. "ScaleLabel", grp, CT_LABEL )
		ui.ScaleLabel = c
		c:SetColor( 1, 1, 1, 1 )
		c:SetText( "Scale" )
		c:SetFont( "$(CHAT_FONT)|$(KB_26)|thick-outline" )
		c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		c:SetVerticalAlignment( TEXT_ALIGN_CENTER )
		c:SetAnchor( TOP, grp, TOP, 0, 0 )
		c:SetMouseEnabled( false )

		-- Offsets Header Group

		grp = EHT.CreateControl( prefix .. "OffsetsHeaderGroup", win, CT_CONTROL )
		ui.OffsetsHeaderGroup = grp
		grp:SetAnchor( BOTTOM, ui.MovementGroup, TOP, 0, 0 )
		grp:SetDimensions( 100, 80 )

		c = EHT.CreateControl( prefix .. "Offsets", grp, CT_LABEL )
		ui.Offsets = c
		c:SetColor( 1, 1, 0, 1 )
		c:SetFont( "$(CHAT_FONT)|$(KB_32)|thick-outline" )
		c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		c:SetVerticalAlignment( TEXT_ALIGN_CENTER )
		c:SetAnchor( BOTTOM, grp, BOTTOM, 0, 0 )
		c:SetMouseEnabled( false )

		c = EHT.CreateControl( prefix .. "OffsetsLabel", grp, CT_LABEL )
		ui.OffsetsLabel = c
		c:SetColor( 1, 1, 1, 1 )
		c:SetText( "Offsets" )
		c:SetFont( "$(CHAT_FONT)|$(KB_26)|thick-outline" )
		c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		c:SetVerticalAlignment( TEXT_ALIGN_CENTER )
		c:SetAnchor( TOP, grp, TOP, 0, 0 )
		c:SetMouseEnabled( false )

		-- Rotate Header Group

		grp = EHT.CreateControl( prefix .. "RotateHeaderGroup", win, CT_CONTROL )
		ui.RotateHeaderGroup = grp
		grp:SetAnchor( BOTTOM, ui.RotateGroup, TOP, 0, 0 )
		grp:SetDimensions( 100, 80 )

		c = EHT.CreateControl( prefix .. "Rotation", grp, CT_LABEL )
		ui.Rotation = c
		c:SetColor( 1, 1, 0, 1 )
		c:SetFont( "$(CHAT_FONT)|$(KB_32)|thick-outline" )
		c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		c:SetVerticalAlignment( TEXT_ALIGN_CENTER )
		c:SetAnchor( BOTTOM, grp, BOTTOM, 0, 0 )
		c:SetMouseEnabled( false )

		c = EHT.CreateControl( prefix .. "RotationLabel", grp, CT_LABEL )
		ui.RotationLabel = c
		c:SetColor( 1, 1, 1, 1 )
		c:SetText( "Rotation" )
		c:SetFont( "$(CHAT_FONT)|$(KB_26)|thick-outline" )
		c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		c:SetVerticalAlignment( TEXT_ALIGN_CENTER )
		c:SetAnchor( TOP, grp, TOP, 0, 0 )
		c:SetMouseEnabled( false )

		-- Title Group

		grp = EHT.CreateControl( prefix .. "TitleGroup", win, CT_CONTROL )
		ui.TitleGroup = grp
		grp:SetAnchor( BOTTOM, ui.OffsetsHeaderGroup, TOP, 0, 0 )
		grp:SetDimensions( 200, 80 )

		c = EHT.CreateControl( prefix .. "TitleLabel", grp, CT_LABEL )
		ui.TitleLabel = c
		c:SetColor( 1, 1, 1, 1 )
		c:SetText( "Grid Adjustment" )
		c:SetFont( "$(CHAT_FONT)|$(KB_36)|thick-outline" )
		c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		c:SetVerticalAlignment( TEXT_ALIGN_CENTER )
		c:SetAnchor( CENTER, grp, CENTER, 0, 0 )
		c:SetMouseEnabled( false )
	end

	return ui
end

---[ Dialog : Reports ]---

function EHT.UI.HideReportDialog()
	if nil ~= EHT.UI.ReportDialog then
		EHT.UI.ClearDialogHidden( EHT.CONST.DIALOG.REPORT )
		EHT.UI.ReportDialog.Window:SetHidden( true )
	end
end

function EHT.UI.SetupReportDialog()
	local ui = EHT.UI.ReportDialog

	if nil == ui then
		ui = { }
		EHT.UI.ReportDialog = ui

		local prefix = "EHTReportDialog"
		local c, grp, win

		-- Window Controls

		win = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
		ui.Window = win
		win:SetAlpha( 1.0 )
		win:SetClampedToScreen( true )
		win:SetMouseEnabled( true )
		win:SetMovable( true )
		win:SetResizeHandleSize( 10 )
		win:SetAnchor( CENTER, GuiRoot, CENTER, 0, 0 )
		win:SetDimensionConstraints( 800, 400, 1600, 1200 )

		c = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "Backdrop", ui.Window, "ZO_DefaultBackdrop" )
		ui.Backdrop = c
		c:SetAnchor( TOPLEFT, ui.Window, TOPLEFT, 5, 5 )
		c:SetAnchor( BOTTOMRIGHT, ui.Window, BOTTOMRIGHT, -5, -5 )
		c:SetAlpha( 1 )

		-- Title

		c = EHT.CreateControl( prefix .. "Title", win, CT_LABEL )
		ui.Title = c
		c:SetColor( 1, 1, 0.5, 1 )
		c:SetText( "Report" )
		c:SetFont( "$(BOLD_FONT)|$(KB_18)|soft-shadow-thick" )
		c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		c:SetVerticalAlignment( TEXT_ALIGN_TOP )
		c:SetAnchor( TOP, win, TOP, 0, 10 )
		c:SetMaxLineCount( 2 )

		-- All Criteria

		local cgrp = EHT.CreateControl( prefix .. "Criteria", win, CT_CONTROL )
		ui.Criteria = cgrp
		cgrp:SetAnchor( TOPLEFT, win, TOPLEFT, 18, 40 )
		cgrp:SetAnchor( TOPRIGHT, win, TOPRIGHT, -18, 40 )
		cgrp:SetResizeToFitDescendents( true )

		-- House Item Criteria

		grp = EHT.CreateControl( prefix .. "HouseItemCriteria", cgrp, CT_CONTROL )
		ui.HouseItemCriteria = grp
		grp:SetAnchor( TOPLEFT, cgrp, TOPLEFT, 0, 0 )
		grp:SetAnchor( TOPRIGHT, cgrp, TOPRIGHT, 0, 0 )
		grp:SetResizeToFitDescendents( true )
		grp:SetHidden( false )

		c = EHT.CreateControl( nil, grp, CT_LABEL )
		ui.CriteriaHouseLabel = c
		c:SetColor( 0.9, 0.9, 0.9, 1 )
		c:SetText( "House:" )
		c:SetFont( "$(CHAT_FONT)|$(KB_14)|soft-shadow-thick" )
		c:SetHorizontalAlignment( TEXT_ALIGN_RIGHT )
		c:SetVerticalAlignment( TEXT_ALIGN_CENTER )
		c:SetAnchor( LEFT, grp, LEFT, 0, 0 )
--[[
		c = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "CriteriaHouse", grp, "ZO_ComboBox" )
		ui.CriteriaHouseBox = c
		c:SetAnchor( LEFT, ui.CriteriaHouseLabel, RIGHT, 6, 0 )
		c:SetDimensions( 250, 25 )
		ui.CriteriaHouse = ZO_ComboBox_ObjectFromContainer( ui.CriteriaHouseBox )
		ui.CriteriaHouse:SetFont( "$(CHAT_FONT)|$(KB_14)" )
		ui.CriteriaHouse:SetSortsItems( true )
]]
		c = EHT.UI.Picklist:New( prefix .. "CriteriaHouse", grp, LEFT, ui.CriteriaHouseLabel, RIGHT, 6, 0, 250, 25 )
		ui.CriteriaHouse = c
		c:SetSorted( true )
		--c:AddHandler( "OnSelectionChanged", function( ctl, item ) end )

		-- Paging

		local grp = EHT.CreateControl( prefix .. "Paging", win, CT_CONTROL )
		ui.Paging = grp
		grp:SetAnchor( TOP, cgrp, BOTTOM, 0, 4 )
		grp:SetResizeToFitDescendents( true )

		c = EHT.CreateControl( prefix .. "PageCount", grp, CT_LABEL )
		ui.PageCount = c
		c:SetColor( 0.9, 0.9, 0.9, 1 )
		c:SetText( "Page 0 of 0" )
		c:SetFont( "$(CHAT_FONT)|$(KB_15)|soft-shadow-thick" )
		c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		c:SetVerticalAlignment( TEXT_ALIGN_CENTER )
		c:SetAnchor( CENTER, grp, CENTER, 0, 0 )
		c:SetMouseEnabled( true )
		c:SetHandler( "OnMouseDown", EHT.UI.ReportPageBack )

		c = EHT.CreateControl( prefix .. "PageBack", grp, CT_LABEL )
		ui.PageBack = c
		c:SetColor( 0.9, 0.9, 0.4, 1 )
		c:SetText( "<< Back" )
		c:SetFont( "$(CHAT_FONT)|$(KB_15)|soft-shadow-thick" )
		c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		c:SetVerticalAlignment( TEXT_ALIGN_CENTER )
		c:SetAnchor( RIGHT, ui.PageCount, LEFT, -20, 0 )
		c:SetMouseEnabled( true )
		c:SetHandler( "OnMouseDown", EHT.UI.ReportPageBack )

		c = EHT.CreateControl( prefix .. "PageNext", grp, CT_LABEL )
		ui.PageNext = c
		c:SetColor( 0.9, 0.9, 0.4, 1 )
		c:SetText( "Next >>" )
		c:SetFont( "$(CHAT_FONT)|$(KB_15)|soft-shadow-thick" )
		c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		c:SetVerticalAlignment( TEXT_ALIGN_CENTER )
		c:SetAnchor( LEFT, ui.PageCount, RIGHT, 21, 0 )
		c:SetMouseEnabled( true )
		c:SetHandler( "OnMouseDown", EHT.UI.ReportPageNext )

		-- Body

		c = WINDOW_MANAGER:CreateControlFromVirtual( "BodyBackdrop", win, "ZO_EditBackdrop" )
		ui.BodyBackdrop = c
		c:SetAnchor( TOPLEFT, ui.Criteria, BOTTOMLEFT, 0, 30 )
		c:SetAnchor( BOTTOMRIGHT, win, BOTTOMRIGHT, -18, -34 )

		c = WINDOW_MANAGER:CreateControlFromVirtual( "Body", ui.BodyBackdrop, "ZO_DefaultEditForBackdrop" )
		ui.Body = c
		c:SetFont( "$(CHAT_FONT)|$(KB_16)|soft-shadow-thin" )
		c:SetAnchor( TOPLEFT, cBackdrop, TOPLEFT, 2, 2 )
		c:SetAnchor( BOTTOMRIGHT, cBackdrop, BOTTOMRIGHT, -2, -2 )
		c:SetMultiLine( true )
		c:SetNewLineEnabled( true )
		c:SetEditEnabled( false )
		c:SetCopyEnabled( true )
		c:SetMaxInputChars( 31920 )
		c:SetHandler( "OnMouseWheel", function( self, delta, ctrl, alt, shift )
			local topLine = self:GetTopLineIndex() or 1
			topLine = topLine - delta * 10
			self:SetTopLineIndex( topLine )
		end )


		-- Copy Instructions

		c = EHT.CreateControl( prefix .. "Instructions", win, CT_LABEL )
		ui.Instructions = c
		c:SetColor( 0.9, 0.9, 0.9, 1 )
		c:SetText( "Use  Control + C (Windows)  or  Command + C (Mac)  to copy" )
		c:SetFont( "$(MEDIUM_FONT)|$(KB_12)" )
		c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		c:SetVerticalAlignment( TEXT_ALIGN_TOP )
		c:SetAnchor( BOTTOM, win, BOTTOM, 0, -14 )

		-- Close

		c = EHT.CreateControl( prefix .. "Close", win, CT_LABEL )
		ui.Close = c
		c:SetColor( 1, 1, 0.8, 1 )
		c:SetText( "Close" )
		c:SetFont( "$(BOLD_FONT)|$(KB_18)|soft-shadow-thick" )
		c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		c:SetVerticalAlignment( TEXT_ALIGN_TOP )
		c:SetAnchor( TOPRIGHT, win, TOPRIGHT, -20, 10 )
		c:SetText( "Close" )
		c:SetMouseEnabled( true )
		c:SetHandler( "OnMouseDown", EHT.UI.HideReportDialog )


	end

	return ui

end


function EHT.UI.ShowReport( reportName, reportFunc )

	local ui = EHT.UI.SetupReportDialog()
	if not isUIHidden then
		ui.Window:SetHidden( false )
	else
		EHT.UI.SetDialogHidden( EHT.CONST.DIALOG.REPORT )
	end

	local win = ui.Window

	ui.Title:SetText( string.format( "Report - %s", reportName ) )
	ui.PageCount:SetText( "Page 0 of 0" )
	ui.ReportFunc = reportFunc
	ui.ReportPages = nil
	ui.ReportPage = 0

	if reportFunc then
		ui.Body:SetText( "" )
	else
		ui.Body:SetText( "Invalid report configuration." )
	end

	EHT.UI.RefreshReportCriteria()

	return true

end


function EHT.UI.GetReportCriteria()

	local criteria = { }

	local ui = EHT.UI.ReportDialog
	if nil == ui then return criteria end

	criteria.HouseId = ui.CriteriaHouse:GetSelectedItemValue()
	criteria.House = ui.CriteriaHouse:GetSelectedItem()
	return criteria

end


do


	local refreshingCriteria = false


	function EHT.UI.RefreshReportCriteria()

		local ui = EHT.UI.ReportDialog
		if nil == ui then return false end

		refreshingCriteria = true

		local criteria = EHT.UI.GetReportCriteria()

		-- Houses

		local houses = ui.CriteriaHouse
		houses:ClearItems()
		houses:AddItem( "-select-" )
		for houseId, house in pairs( EHT.Data.GetHouses() ) do
			if tonumber( houseId ) then
				houses:AddItem( house.Name, EHT.UI.RefreshReport, houseId )
			end
		end

		if criteria and criteria.House then
			houses:SetSelectedItem( criteria.House )
		else
			houses:SetSelectedItem( "-select-" )
		end

		refreshingCriteria = false

	end


	function EHT.UI.RefreshReport()

		if refreshingCriteria then return end

		local ui = EHT.UI.ReportDialog
		if nil == ui then return false end

		local reportFunc = ui.ReportFunc
		if nil == reportFunc then return false end

		local criteria = EHT.UI.GetReportCriteria()
		local body = reportFunc( criteria )

		if nil == body then
			ui.Body:SetText( "Failed to generate report." )
		else
			EHT.UI.SetReportBody( body )
		end

	end


end


do


	local MAX_PAGE_LENGTH = 28000


	function EHT.UI.SetReportBody( body )

		local ui = EHT.UI.ReportDialog
		if nil == ui then return false end

		if nil == body or "" == body then
			ui.ReportPages = nil
			ui.PageCount:SetText( "Page 0 of 0" )
		else
			local page, pageRev, pages, newLineIndex = nil, nil, { }, 0

			ui.ReportPages = pages
			ui.ReportPage = 1

			while #body > MAX_PAGE_LENGTH do
				page = string.sub( body, 1, MAX_PAGE_LENGTH )
				pageRev = string.reverse( page )

				newLineIndex = string.find( pageRev, "\n", 1, true )
				if nil ~= newLineIndex then
					page = string.sub( page, 1, -1 * newLineIndex )
				end
				body = string.sub( body, #page + 1 )

				table.insert( pages, page )
			end

			if 0 < #body then
				table.insert( pages, body )
			end

			EHT.UI.RefreshReportPage()
		end

	end


	function EHT.UI.RefreshReportPage()

		local ui = EHT.UI.ReportDialog
		if nil == ui then return false end

		local pageNum, pages = ui.ReportPage or 1, ui.ReportPages or { }
		ui.PageCount:SetText( string.format( "Page %d of %d", pageNum, #pages ) )

		local page = pages[ pageNum ]
		if page then
			ui.Body:SetText( page )

			zo_callLater( function()
				ui.Body:SelectAll()
				ui.Body:TakeFocus()
			end, 500 )
		else
			ui.Body:SetText( "" )
		end

	end


	function EHT.UI.ReportPageNext()

		local ui = EHT.UI.ReportDialog
		if nil == ui then return false end

		local pageNum, pages = ui.ReportPage or 0, ui.ReportPages or { }
		pageNum = pageNum + 1

		if pageNum <= #pages then
			ui.ReportPage = pageNum
		end

		EHT.UI.RefreshReportPage()
	
	end


	function EHT.UI.ReportPageBack()

		local ui = EHT.UI.ReportDialog
		if nil == ui then return false end

		local pageNum, pages = ui.ReportPage or 0, ui.ReportPages or { }
		pageNum = pageNum - 1

		if pageNum > 0 then
			ui.ReportPage = pageNum
		end

		EHT.UI.RefreshReportPage()

	end


end


------[ Mapcast ]------


function EHT.UI.SetupMapcastDialog()

	local ui = EHT.UI.MapcastDialog
	if nil == ui then

		ui = { }
		EHT.UI.MapcastDialog = ui

		local prefix = "EHTMapcastDialog"
		local c, grp, win

		-- Window Controls

		win = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
		ui.Window = win
		win:SetHidden( true )
		win:SetAlpha( 0.7 )
		win:SetClampedToScreen( true )
		win:SetMouseEnabled( false )
		win:SetMovable( false )
		win:SetResizeHandleSize( 0 )
		win:SetAnchor( BOTTOM, GuiRoot, BOTTOM, 0, -50 )
		win:SetDimensionConstraints( 300, 240, 300, 240 )

		c = EHT.CreateControl( prefix .. "Animation", win, CT_TEXTURE )
		ui.Animation = c
		c:SetAnchor( CENTER, win, CENTER, 0, 0 )
		c:SetTexture( "art/fx/texture/smoke_heavy_01_8x8_loop.dds" )
		c:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 1 )
		c:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_ALPHA_AS_RGB, 0 )
		c:SetDimensions( 300, 200 )
		c:SetColor( 0.5, 1, 1, 1 )

		c = EHT.CreateControl( prefix .. "Message", win, CT_LABEL )
		ui.Message = c
		c:SetAnchor( CENTER, win, CENTER, 0, 0 )
		c:SetColor( 1, 1, 0.5, 1 )
		c:SetFont( "$(GAMEPAD_MEDIUM_FONT)|$(KB_28)|thick-outline" )
		c:SetText( "" )

	end
	return ui

end


function EHT.UI.AnimateMapcastDialog()

	local anim = EHT.UI.MapcastDialog.Animation
	anim:SetTextureCoords( EHT.World:GetIntervalSurfaceCoords( 8, 8, 8000, 0 ) )

end


function EHT.UI.ShowMapcastDialog( alignCenter )

	local ui = EHT.UI.SetupMapcastDialog()

	ui.Window:ClearAnchors()
	if alignCenter then
		ui.Window:SetAnchor( CENTER, GuiRoot, CENTER, 0, 0 )
	else
		ui.Window:SetAnchor( BOTTOM, GuiRoot, BOTTOM, 0, -50 )
	end

	ui.Window:SetHidden( false )

	EVENT_MANAGER:RegisterForUpdate( "EHT.UI.AnimateMapcastDialog", 60, EHT.UI.AnimateMapcastDialog )

	return ui

end


function EHT.UI.HideMapcastDialog()

	local ui = EHT.UI.SetupMapcastDialog()
	ui.Window:SetHidden( true )
	ui.Message:SetText( "" )
	EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.AnimateMapcastDialog" )
	EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.HideMapcastDialog" )

end


function EHT.UI.ShowSendingMapcast( mapcastType, alignCenter )

	local ui = EHT.UI.ShowMapcastDialog( alignCenter )
	ui.Message:SetText( string.format( "Sending %s data...", mapcastType ) )
	EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.HideMapcastDialog" )
	EVENT_MANAGER:RegisterForUpdate( "EHT.UI.HideMapcastDialog", 5000, EHT.UI.HideMapcastDialog )

end


function EHT.UI.ShowReceivingMapcast( mapcastType, alignCenter )

	local ui = EHT.UI.ShowMapcastDialog( alignCenter )
	ui.Message:SetText( string.format( "Receiving %s data...", mapcastType ) )
	EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.HideMapcastDialog" )
	EVENT_MANAGER:RegisterForUpdate( "EHT.UI.HideMapcastDialog", 5000, EHT.UI.HideMapcastDialog )

end

---[ Preview : Controls ]---

do

	local screenX, screenY
	local defaultX, defaultY = 0.25, 0.5

	function EHT.UI.SetupPreviewControlsDialog()
		local ui = EHT.UI.PreviewControlsDialog
		local isGamepadMode = IsInGamepadPreferredMode()
		local keyboardSettings = "PreviewControlsDialog"
		local gamepadSettings = "PreviewControlsDialogGamepad"

		if nil == ui then
			ui = { }
			EHT.UI.PreviewControlsDialog = ui

			local prefix = "EHTPreviewControlsDialog"
			local c, grp, win

			-- Window Controls

			win = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
			ui.Window = win
			win:SetHidden( true )
			win:SetAlpha( 1 )
			win:SetClampedToScreen( true )
			win:SetMouseEnabled( true )
			win:SetMovable( true )
			win:SetResizeHandleSize( 0 )
			win:SetDimensionConstraints( 338, 128, 338, 128 )
			win:SetDrawLevel( 200000 )

			win:SetHandler( "OnMouseEnter", function()
				WINDOW_MANAGER:SetMouseCursor( MOUSE_CURSOR_PAN )
			end )

			win:SetHandler( "OnMouseExit", function()
				WINDOW_MANAGER:SetMouseCursor( MOUSE_CURSOR_DO_NOT_CARE )
			end )

			win:SetHandler( "OnMoveStop", function()
				if IsInGamepadPreferredMode() then
					EHT.UI.SaveDialogSettings( gamepadSettings, win )
				else
					EHT.UI.SaveDialogSettings( keyboardSettings, win )
				end
			end )

			c = EHT.CreateControl( prefix .. "Pad", win, CT_TEXTURE )
			ui.Pad = c
			c:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
			c:SetAnchor( RIGHT, win, RIGHT, 0, 0 )
			c:SetTexture( "esoui/art/buttons/gamepad/ps4/nav_ps4_dpad.dds" )
			c:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 1 )
			c:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_ALPHA_AS_RGB, 0 )
			c:SetDimensions( 128, 128 )
			c:SetMouseEnabled( false )
			c:SetColor( 0, 1, 1, 0.5 )

			c = EHT.CreateControl( prefix .. "RulerBackdrop", win, CT_TEXTURE )
			ui.RulerBackdrop = c
			c:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
			c:SetAnchor( LEFT, win, LEFT, 0, 0 )
			c:SetTexture( EHT.Textures.SOLID )
			c:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 1 )
			c:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_ALPHA_AS_RGB, 0 )
			c:SetDimensions( 200, 24 )
			c:SetMouseEnabled( false )
			c:SetColor( 0.8, 0.8, 0.8, 0.5 )

			c = EHT.CreateControl( prefix .. "Ruler", win, CT_TEXTURE )
			ui.Ruler = c
			c:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
			c:SetTexture( EHT.Textures.RULER_HORIZ )
			c:SetAnchor( TOPLEFT, ui.RulerBackdrop, TOPLEFT, 0, 7 )
			c:SetAnchor( BOTTOMRIGHT, ui.RulerBackdrop, BOTTOMRIGHT, 0, -4 )
			c:SetMouseEnabled( false )
			c:SetColor( 0, 0, 0, 1 )
			local rulerControl = c
			zo_callLater( function()
				rulerControl:SetAddressMode( TEX_MODE_WRAP )
				rulerControl:SetTextureCoords( -0.05, 6.04, 0.4, 1 )
			end, 1000 )

			c = EHT.CreateControl( prefix .. "Pan", win, CT_LABEL )
			ui.Pan = c
			c:SetAnchor( LEFT, ui.Pad, CENTER, 17, 0 )
			c:SetColor( 1, 1, 1, 1 )
			c:SetFont( "$(GAMEPAD_MEDIUM_FONT)|$(KB_22)|thick-outline" )
			c:SetText( "Pan" )

			c = EHT.CreateControl( prefix .. "Tilt", win, CT_LABEL )
			ui.Tilt = c
			c:SetAnchor( BOTTOM, ui.Pad, CENTER, 0, -17 )
			c:SetColor( 1, 1, 1, 1 )
			c:SetFont( "$(GAMEPAD_MEDIUM_FONT)|$(KB_22)|thick-outline" )
			c:SetText( "Tilt" )

			c = EHT.CreateControl( prefix .. "RulerLabel", win, CT_LABEL )
			ui.RulerLabel = c
			c:SetAnchor( BOTTOM, ui.RulerBackdrop, TOP, 0, 0 )
			c:SetColor( 1, 1, 1, 1 )
			c:SetFont( "$(GAMEPAD_MEDIUM_FONT)|$(KB_24)|thick-outline" )
			c:SetText( "Measure" )

			c = EHT.CreateControl( prefix .. "PadUp", win, CT_TEXTURE )
			ui.PadUp = c
			c:SetAnchor( BOTTOM, ui.Pad, CENTER, 0, -10 )
			c:SetDimensions( 40, 54 )
			c:SetColor( 1, 1, 1, 0 )
			c:SetMouseEnabled( true )
			c:SetHandler( "OnMouseUp", EHT.UI.OnPreviewControlClicked )

			c = EHT.CreateControl( prefix .. "PadDown", win, CT_TEXTURE )
			ui.PadDown = c
			c:SetAnchor( TOP, ui.Pad, CENTER, 0, 10 )
			c:SetDimensions( 40, 54 )
			c:SetColor( 1, 1, 1, 0 )
			c:SetMouseEnabled( true )
			c:SetHandler( "OnMouseUp", EHT.UI.OnPreviewControlClicked )

			c = EHT.CreateControl( prefix .. "PadLeft", win, CT_TEXTURE )
			ui.PadLeft = c
			c:SetAnchor( RIGHT, ui.Pad, CENTER, -10, 0 )
			c:SetDimensions( 54, 40 )
			c:SetColor( 1, 1, 1, 0 )
			c:SetMouseEnabled( true )
			c:SetHandler( "OnMouseUp", EHT.UI.OnPreviewControlClicked )

			c = EHT.CreateControl( prefix .. "PadRight", win, CT_TEXTURE )
			ui.PadRight = c
			c:SetAnchor( LEFT, ui.Pad, CENTER, 10, 0 )
			c:SetDimensions( 54, 40 )
			c:SetColor( 1, 1, 1, 0 )
			c:SetMouseEnabled( true )
			c:SetHandler( "OnMouseUp", EHT.UI.OnPreviewControlClicked )

			c = EHT.CreateControl( prefix .. "PadRuler", win, CT_TEXTURE )
			ui.PadRuler = c
			c:SetAnchor( TOPLEFT, ui.RulerBackdrop, TOPLEFT, 0, -20 )
			c:SetAnchor( BOTTOMRIGHT, ui.RulerBackdrop, BOTTOMRIGHT, 0, 0 )
			c:SetColor( 0, 0, 0, 0 )
			c:SetMouseEnabled( true )
			c:SetHandler( "OnMouseUp", EHT.UI.OnPreviewControlClicked )
		end

		local settings = EHT.UI.GetDialogSettings( isGamepadMode and gamepadSettings or keyboardSettings )
		local win = ui.Window
		win:ClearAnchors()

		if settings.Left and settings.Top then
			win:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, settings.Left, settings.Top )
		else
			if isGamepadMode then
				win:SetAnchor( TOP, GuiRoot, TOP, 0, 30 )
			else
				win:SetAnchor( CENTER, ZO_ItemPreview_KeyboardTopLevel, TOP, 0, 0 )
			end
		end

		return ui
	end

	function EHT.UI.ShowPreviewControlsDialog()
		local ui = EHT.UI.PreviewControlsDialog or EHT.UI.SetupPreviewControlsDialog()
		if ui and ui.Window and false ~= EHT.GetSetting("EnableEssentialPreview") and not IsInGamepadPreferredMode() then
			ui.Window:SetHidden( false )
			EHT.PreviewScale:SetEnabled( EHT.PreviewScale:IsEnabled() )
			EHT.UI.UpdatePreviewControls()
			EVENT_MANAGER:RegisterForUpdate( "EHT.UI.OnPreviewControlsUpdate", 32, EHT.UI.OnPreviewControlsUpdate )
		end
	end

	function EHT.UI.HidePreviewControlsDialog()
		EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.OnPreviewControlsUpdate" )
		screenX, screenY = nil, nil

		local ui = EHT.UI.PreviewControlsDialog
		if ui and ui.Window then
			ui.Window:SetHidden( true )
		end
		
		EHT.PreviewScale:SetEnabled( false )
	end

	function EHT.UI.OnPreviewControlsUpdate()
		if IsInGamepadPreferredMode() or not GetPreviewModeEnabled() then
			EHT.UI.HidePreviewControlsDialog()
			return
		end

		local ui = EHT.UI.PreviewControlsDialog
		if ui and ui.Window then
			if not IsCurrentlyPreviewing() then
				ui.Window:SetHidden( true )
			else
				if EHT.PreviewScale:IsEnabled() then
					local mod = 0.7 * EHT.World.EaseOutIn2( ( GetGameTimeMilliseconds() % 2000 ) / 2000 )
					ui.RulerBackdrop:SetColor( 0, 0.3 + mod, 0.3 + mod, 0.3 + mod )
				else
					ui.RulerBackdrop:SetColor( 0.8, 0.8, 0.8, 0.5 )
				end

				local c = ui.Ruler
				c:SetAddressMode( TEX_MODE_WRAP )
				c:SetTextureCoords( -0.05, 6.04, 0.4, 1 )
				c:SetColor( 0, 0, 0, 1 )
				
				ui.Window:SetHidden( false )
			end
		end
	end

	function EHT.UI.UpdatePreviewControls()
		local ui = EHT.UI.PreviewControlsDialog
		if screenX and screenY and ui and ui.Window and not ui.Window:IsHidden() then
			SetFrameLocalPlayerTarget( screenX, screenY )
		end
	end

	function EHT.UI.OnPreviewControlClicked( control, button, upInside )
		local name = control:GetName()
		local c = ( IsAltKeyDown() or IsCommandKeyDown() or IsControlKeyDown() or IsShiftKeyDown() ) and 2 or 1
		screenX, screenY = screenX or defaultX, screenY or defaultY

		if "EHTPreviewControlsDialogPadUp" == name then
			screenY = zo_clamp( screenY - c * 0.05, 0, 1 )
		elseif "EHTPreviewControlsDialogPadDown" == name then
			screenY = zo_clamp( screenY + c * 0.05, 0, 1 )
		elseif "EHTPreviewControlsDialogPadLeft" == name then
			screenX = zo_clamp( screenX + c * 0.05, 0, 1 )
		elseif "EHTPreviewControlsDialogPadRight" == name then
			screenX = zo_clamp( screenX - c * 0.05, 0, 1 )
		elseif "EHTPreviewControlsDialogPadRuler" == name then
			EHT.PreviewScale:ToggleEnabled()
		end

		EHT.UI.UpdatePreviewControls()
	end

end

---[ Essential Housing Hub ]---
--[[
function EHT.UI.RegisterHousingHubScene()
	if not ESSENTIAL_HOUSING_HUB_SCENE then
		EHT.HubSceneName = "EssentialHousingHubScene"

		local ui = EHT.UI.SetupHousingHub()
		local scene = ZO_Scene:New(EHT.HubSceneName, SCENE_MANAGER)
		EHT.HubScene = scene
		ESSENTIAL_HOUSING_HUB_SCENE = scene
		--scene:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW_NO_KEYBIND_STRIP)
		scene:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
		scene:AddFragment(ZO_FadeSceneFragment:New(ui.Window))
		scene:AddFragment(CODEX_WINDOW_SOUNDS)
		scene:AddFragment(MOUSE_UI_MODE_FRAGMENT)

		EHT.UI.RegisterHousingBookHousingHub()
		local categoryInfo =
		{
			descriptor = EHT.HubSceneName,
			binding = "EHT_HOUSING_HUB",
			categoryName = SI_BINDING_NAME_EHT_HOUSING_HUB,
			callback = EHT.UI.ShowHousingHub,
			visible = function(buttonData) return true end,
			normal = "esoui/art/collections/collections_tabicon_housing_up.dds",
			pressed = "esoui/art/collections/collections_tabicon_housing_down.dds",
			highlight = "esoui/art/collections/collections_tabicon_housing_over.dds",
			disabled = "esoui/art/collections/collections_tabicon_housing_disabled.dds",
		}
		ZO_MenuBar_AddButton(MAIN_MENU_KEYBOARD.categoryBar, categoryInfo)
		
		scene:RegisterCallback("StateChange", function(oldState, newState)
			if newState == SCENE_SHOWN then
				EHT.UI.RefreshHousingHub()
			elseif newState == SCENE_HIDING then
				EHT.UI.HideShareFXContextMenu()
			end
		end)
	end
end

function EHT.UI.RegisterHousingBookHousingHub()
	local dock = ZO_HousingBook_KeyboardContents
	if not dock then
		return
	end

	local function OnClick()
		SCENE_MANAGER:ShowBaseScene()
		zo_callLater(function() EHT.UI.ShowHousingHub() end, 500)
	end

	local button = CreateButton("EHHHousingBookHubButton", dock, "Housing Hub", nil, 120, 36, OnClick)
	button:SetExcludeFromResizeToFitExtents(true)
	button:SetAnchor(TOP, dock, BOTTOM, 0, 4)
end

local function SetFormButtonEnabled( control, enabled )
	if enabled then
		control.r1, control.g1, control.b1, control.a1 = nil, nil, nil, nil
		control.r2, control.g2, control.b2, control.a2 = nil, nil, nil, nil
	else
		control.r1, control.g1, control.b1, control.a1 = 0.3, 0.3, 0.3, 1
		control.r2, control.g2, control.b2, control.a2 = 0.2, 0.2, 0.2, 0.5
	end
end
]]
local function OnFormButtonMouseEnter( control )
	local r1, g1, b1, a1 = control.r1 or 0, control.g1 or 0.7, control.b1 or 0.7, control.a1 or 1
	local r2, g2, b2, a2 = control.r2 or 0, control.g2 or 0.5, control.b2 or 0.5, control.a2 or 0.5
	control:SetVertexColors( 1 + 2, r1, g1, b1, a1 )
	control:SetVertexColors( 4 + 8, r2, g2, b2, a2 )
	WINDOW_MANAGER:SetMouseCursor( MOUSE_CURSOR_UI_HAND )
end

local function OnFormButtonMouseExit( control )
	local r1, g1, b1, a1 = control.r1 or 0, control.g1 or 0.5, control.b1 or 0.5, control.a1 or 1
	local r2, g2, b2, a2 = control.r2 or 0, control.g2 or 0.5, control.b2 or 0.5, control.a2 or 0.5
	control:SetVertexColors( 1 + 2, r1, g1, b1, a1 )
	control:SetVertexColors( 4 + 8, r2, g2, b2, a2 )
	WINDOW_MANAGER:SetMouseCursor( MOUSE_CURSOR_DO_NOT_CARE )
end

function EHT.UI.IsHousingHubHidden()
	return EssentialHousingHub:IsHousingHubHidden()
end

function EHT.UI.ShowHousingHub(forceShow)
	EssentialHousingHub:ShowHousingHub(forceShow)
end

function EHT.UI.HideHousingHub()
	EssentialHousingHub:HideHousingHub()
end

function EHT.UI.RefreshHousingHub()
	EssentialHousingHub:RefreshHousingHub()
end

do
	local notifiedOwners = { }

	function EHT.UI.ConfirmNotifyOpenHouseOwner( owner, houseId )
		if not owner or not houseId then
			return
		end

		local house = EHT.Housing.GetHouseById( houseId )
		local houseName = "open house"
		if house then
			houseName = house.Name
		end

		owner = string.lower( owner )
		local notificationKey = string.format( "%s_%s", owner, houseName )
		if notifiedOwners[ notificationKey ] then
			EHT.UI.ShowAlertDialog( "", string.format( "%s's %s still appears to be inaccessible at the moment - but they have been notified. :)", owner, houseName ) )
			return
		end

		EHT.UI.ShowConfirmationDialog( "", string.format(
			"|c00ffff%s|cffffff's |c00ffff%s|cffffff does not appear to be open for visitors (most likely a simple oversight).\n\n" ..
			"|cffff00Would you like to automatically notify this homeowner to make them aware of the issue?", owner, houseName ),
			function()
				if not notifiedOwners[ notificationKey ] then
					notifiedOwners[ notificationKey ] = true

					EHT.Effect:OpenMailbox()
					SendMail( owner, "Open House Access", string.format(
						"Hello! This is an automated message sent via Essential Housing Tools just to let you know that I was " ..
						"unable to visit the Open House you are hosting at your %s. If possible, would you be able to check that " ..
						"home's Settings in the Housing Editor to verify that your Default Visitor Access is set to allow visitors? " ..
						"Thank you so much!", houseName ) )
					zo_callLater( function()
						EHT.Effect:CloseMailbox()
						zo_callLater( function()
							EHT.UI.ShowAlertDialog( "", string.format( "An in-game mail has been sent to %s regarding visitor access for their %s. Thanks for letting them know!", owner, houseName ) )
						end, 500 )
					end, 1000 )
				end
			end )
	end
end


---[ Hint ]---


do


	local hideDuration, hideCallback


	function EHT.UI.SetupHintDialog()

		local ui = EHT.UI.HintDialog
		if nil == ui then

			ui = { }
			EHT.UI.HintDialog = ui

			local prefix = "EHTHintDialog"
			local settingsName = "HintDialog"
			local w = WINDOW_MANAGER:CreateTopLevelWindow( prefix )

			ui.Window = w
			w:SetDimensions( 100, 100 )
			w:SetMovable( true )
			w:SetMouseEnabled( true )
			w:SetClampedToScreen( true )
			w:SetResizeHandleSize( 0 )
			w:SetAlpha( 0.8 )
			w:SetHidden( true )

			local settings = EHT.UI.GetDialogSettings( settingsName )

			if settings.Left and settings.Top then
				w:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, settings.Left, settings.Top )
			else
				w:SetAnchor( CENTER, GuiRoot, CENTER, 0, 200 )
			end

			w:SetHandler( "OnMoveStart", function()
				EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.HideHint" )
			end )

			w:SetHandler( "OnMoveStop", function()
				EHT.UI.SaveDialogSettings( settingsName, w )

				if hideDuration then
					EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.HideHint" )
					EVENT_MANAGER:RegisterForUpdate( "EHT.UI.HideHint", hideDuration, EHT.UI.HideHint )
				end
			end )

			local l = EHT.CreateControl( prefix .. "InstructionLabel", w, CT_LABEL )
			ui.Hint = l
			l:SetFont( "$(BOLD_FONT)|$(KB_22)|soft-shadow-thin" )
			l:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
			l:SetColor( 1, 1, 1, 1 )
			l:SetAnchor( CENTER, w, CENTER, 0, 0 )
			l:SetMaxLineCount( 6 )

		end

		return ui, ui.Window, ui.Hint

	end


	function EHT.UI.ShowHint( msg, duration, callback )

		local ui, w, l = EHT.UI.SetupHintDialog()
		if not ui or not w or not l then return end

		l:SetText( msg )
		w:SetDimensions( l:GetTextDimensions() )
		w:SetHidden( false )

		hideDuration = duration
		hideCallback = callback

		if duration then
			EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.HideHint" )
			EVENT_MANAGER:RegisterForUpdate( "EHT.UI.HideHint", hideDuration, EHT.UI.HideHint )
		end

	end


	function EHT.UI.HideHint()

		EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.HideHint" )

		local ui, w, l = EHT.UI.SetupHintDialog()
		if not ui or not w or not l then return end

		w:SetHidden( true )

		if hideCallback then hideCallback() end

	end


end

---[ Trigger Queue ]---

do

	local ListData = { }
	local ListRows = { }
	local ListFirstIndex = 1
	local NumListRows = 3
	local MaxListData = 50
	local SuppressDialog = false

	function EHT.UI.SetupTriggerQueue()
		local ui = EHT.UI.TriggerQueueDialog

		if not ui then
			ui = { }
			EHT.UI.TriggerQueueDialog = ui

			local windowName = "EHTTriggerQueue"
			local prefix = "EHTTriggerQueue"
			local settings = EHT.UI.GetDialogSettings( windowName )
			local height, width = 226, 410
			local baseDrawLevel = 100

			-- Window Controls

			local c, grp, section, frame, win, windowFrame

			win = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
			ui.Window = win
			win:SetDimensionConstraints( width, height, width, height )
			win:SetAlpha( 0.8 )
			win:SetHidden( true )
			win:SetMovable( true )
			win:SetMouseEnabled( true )
			win:SetClampedToScreen( true )
			win:SetResizeHandleSize( 0 )
			win:SetDrawTier( DT_HIGH )

			if settings.Left and settings.Top then
				win:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, settings.Left, settings.Top )
			else
				win:SetAnchor( LEFT, GuiRoot, LEFT, 5, 0 )
			end

			win:SetHandler( "OnMoveStop", function() EHT.UI.SaveDialogSettings( windowName, win ) end )
			win:SetHandler( "OnUpdate", function() if not EHT.TriggerQueue or 0 == #EHT.TriggerQueue then EHT.UI.HideTriggerQueue() end end )

			do
				grp = EHT.CreateControl( nil, win, CT_CONTROL )
				ui.TitleBar = grp
				grp:SetAnchor( BOTTOMLEFT, win, TOPLEFT, 10, 0 )
				grp:SetAnchor( TOPRIGHT, win, TOPRIGHT, -10, -50 )
				grp:SetMouseEnabled( true )
				grp:SetHandler( "OnMouseDown", function() win:StartMoving() end )
				grp:SetHandler( "OnMouseUp", function() win:StopMovingOrResizing() end )

				c = EHT.CreateControl( nil, grp, CT_TEXTURE )
				ui.HeadingBackdrop = c
				c:SetTexture( EHT.Textures.SOLID )
				c:SetAnchor( BOTTOMLEFT, grp, BOTTOMLEFT, 0, 0 )
				c:SetAnchor( TOPRIGHT, grp, TOPRIGHT, 0, 0 )
				c:SetVertexColors( 1 + 2, 0.5, 0.5, 0.5, 0 )
				c:SetVertexColors( 4 + 8, 0.4, 0.4, 0.4, 0.94 )
				c:SetBlendMode( TEX_BLEND_MODE_ALPHA )
				c:SetMouseEnabled( false )

				c = EHT.CreateControl( nil, grp, CT_TEXTURE )
				ui.IconBackdrop = c
				c:SetTexture( "esoui/art/campaign/gamepad/gp_overview_menuicon_home.dds" )
				c:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
				c:SetAnchor( BOTTOMLEFT, grp, BOTTOMLEFT, 6, 1 )
				c:SetAnchor( TOPRIGHT, grp, BOTTOMLEFT, 46, -44 )
				c:SetColor( 0, 0, 0, 0.5 )
				c:SetBlendMode( TEX_BLEND_MODE_ALPHA )
				c:SetMouseEnabled( false )

				c = EHT.CreateControl( nil, grp, CT_TEXTURE )
				ui.Icon = c
				c:SetTexture( "esoui/art/campaign/gamepad/gp_overview_menuicon_home.dds" )
				c:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
				c:SetAnchor( BOTTOMLEFT, grp, BOTTOMLEFT, 5, 0 )
				c:SetAnchor( TOPRIGHT, grp, BOTTOMLEFT, 45, -45 )
				c:SetColor( 0.9, 0.9, 0.9, 1 )
				c:SetBlendMode( TEX_BLEND_MODE_ALPHA )
				c:SetMouseEnabled( false )

				c = EHT.CreateControl( prefix .. "Heading", grp, CT_LABEL )
				ui.Heading = c
				c:SetDrawLevel( baseDrawLevel )
				c:SetFont( "$(MEDIUM_FONT)|$(KB_22)|soft-shadow-thick" )
				c:SetColor( 0, 0.9, 0.9, 1 )
				c:SetAnchor( BOTTOMLEFT, grp, BOTTOMLEFT, 50, -5 )
				c:SetText( "Trigger Queue" )
				c:SetMouseEnabled( false )

				c = EHT.CreateControl( prefix .. "Count", grp, CT_LABEL )
				ui.Count = c
				c:SetDrawLevel( baseDrawLevel )
				c:SetFont( "$(BOLD_FONT)|$(KB_22)|soft-shadow-thick" )
				c:SetColor( 0, 0.9, 0.9, 1 )
				c:SetAnchor( LEFT, ui.Heading, RIGHT, 10, 0 )
				c:SetText( "" )
				c:SetMouseEnabled( false )

				c = EHT.CreateControl( prefix .. "CloseButton", grp, CT_TEXTURE )
				ui.CloseButton = c
				c:SetAnchor( BOTTOMRIGHT, grp, BOTTOMRIGHT, -10, -5 )
				c:SetDimensions( 24, 24 )
				c:SetColor( 0, 0.9, 0.9, 1 )
				c:SetTextureRotation( 0.5 * math.pi )
				c:SetTexture( "esoui/art/miscellaneous/gamepad/gp_submit.dds" )
				c:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
				c:SetMouseEnabled( true )
				c:SetHandler( "OnMouseUp", function() EHT.UI.HideTriggerQueue( true ) end )

				c = EHT.CreateControl( prefix .. "CloseButtonLabel", grp, CT_LABEL )
				ui.CloseButtonLabel = c
				c:SetDrawLevel( baseDrawLevel )
				c:SetFont( "$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thin" )
				c:SetColor( 0, 0.9, 0.9, 1 )
				c:SetAnchor( RIGHT, ui.CloseButton, LEFT, -2, 0 )
				c:SetText( "Close" )
				c:SetMouseEnabled( true )
				c:SetHandler( "OnMouseUp", function() EHT.UI.HideTriggerQueue( true ) end )
			end

			c = EHT.CreateControl( nil, win, CT_TEXTURE )
			ui.BackdropShadow = c
			c:SetTexture( EHT.Textures.SOLID )
			c:SetColor( 0.4, 0.4, 0.4, 0.94 )
			c:SetAnchor( TOPLEFT, win, TOPLEFT, 10, 0 )
			c:SetAnchor( BOTTOMRIGHT, win, BOTTOMRIGHT, -10, -10 )
			c:SetBlendMode( TEX_BLEND_MODE_ALPHA )
			c:SetMouseEnabled( false )

			c = EHT.CreateControl( nil, win, CT_TEXTURE )
			ui.Backdrop = c
			c:SetTexture( EHT.Textures.SOLID )
			c:SetVertexColors( 1, 0, 0.3, 0.1, 0.6 )
			c:SetVertexColors( 2 + 4, 0, 0.15, 0.15, 0.6 )
			c:SetVertexColors( 8, 0, 0.1, 0.3, 0.6 )
			c:SetAnchor( TOPLEFT, win, TOPLEFT, 14, 4 )
			c:SetAnchor( BOTTOMRIGHT, win, BOTTOMRIGHT, -14, -14 )
			c:SetBlendMode( TEX_BLEND_MODE_ALPHA )
			c:SetMouseEnabled( false )

			windowFrame = EHT.CreateControl( prefix .. "WindowFrame", win, CT_CONTROL )
			ui.WindowFrame = windowFrame
			windowFrame:SetAnchor( TOPLEFT, win, TOPLEFT, 18, 5 )
			windowFrame:SetAnchor( BOTTOMRIGHT, win, BOTTOMRIGHT, -18, -15 )
			windowFrame:SetDrawLevel( baseDrawLevel )

			c = EHT.CreateControl( prefix .. "ScrollPanel", windowFrame, CT_CONTROL )
			ui.ScrollPanel = c
			c:SetAnchor( TOPLEFT, windowFrame, TOPLEFT, 4, 8 )
			c:SetAnchor( BOTTOMRIGHT, windowFrame, BOTTOMRIGHT, -22, 0 )
			c:SetMouseEnabled( true )
			c:SetDrawLevel( baseDrawLevel )

			c = EHT.CreateControl( prefix .. "ScrollSliderBackground", windowFrame, CT_TEXTURE )
			ui.ScrollSliderBackground = c
			c:SetAnchor( TOPLEFT, ui.ScrollPanel, TOPRIGHT, 4, 30 )
			c:SetAnchor( BOTTOMRIGHT, ui.ScrollPanel, BOTTOMRIGHT, 22, -30 )
			c:SetColor( 0, 0, 0, 0.65 )
			c:SetMouseEnabled( false )

			c = EHT.CreateControl( prefix .. "ScrollSlider", windowFrame, CT_SLIDER )
			ui.ScrollSlider = c
			c:SetAnchor( TOPLEFT, ui.ScrollSliderBackground, TOPLEFT, 1, 1 )
			c:SetAnchor( BOTTOMRIGHT, ui.ScrollSliderBackground, BOTTOMRIGHT, -1, -1 )
			c:SetValue( 0 )
			c:SetValueStep( 1 )
			c:SetMouseEnabled( true )
			c:SetDrawLevel( baseDrawLevel )
			c:SetAllowDraggingFromThumb( true )
			c:SetThumbTexture( "EsoUI\\Art\\Miscellaneous\\scrollbox_elevator.dds", "EsoUI\\Art\\Miscellaneous\\scrollbox_elevator_disabled.dds", nil, 22, 64 )
			c:GetThumbTextureControl():SetAlpha( 0.55 )
			c:SetOrientation( ORIENTATION_VERTICAL )

			ui.ScrollSlider:SetHandler( "OnValueChanged", function( self, value, eventReason )
				EHT.UI.UpdateTriggerQueue( value )
			end )

			ui.ScrollPanel:SetHandler( "OnMouseWheel", function( self, delta, ctrl, alt, shift )
				local slider = ui.ScrollSlider
				local value = slider:GetValue()
				if 0 == value then value = 1 end
				slider:SetValue( value - ( delta * ( shift and 5 or 1 ) ) )
			end )

			ui.ScrollSliderUp = EHT.UI.CreateTextureButton(
				prefix .. "ScrollSliderUpButton",
				ui.ScrollSlider,
				"esoui/art/miscellaneous/gamepad/gp_scrollarrow_up.dds",
				22, 22,
				{ { BOTTOM, ui.ScrollSlider, TOP, 0, 0 } },
				function() local value = ui.ScrollSlider:GetValue() ui.ScrollSlider:SetValue( value - ( IsShiftKeyDown() and 5 or 1 ) ) end )
			ui.ScrollSliderUp:SetMouseEnabled( true )
			ui.ScrollSliderUp:SetAlpha( 0.55 )

			ui.ScrollSliderDown = EHT.UI.CreateTextureButton(
				prefix .. "ScrollSliderDownButton",
				ui.ScrollSlider,
				"esoui/art/miscellaneous/gamepad/gp_scrollarrow.dds",
				22, 22,
				{ { TOP, ui.ScrollSlider, BOTTOM, 0, 0 } },
				function() local value = ui.ScrollSlider:GetValue() if 0 == value then value = 1 end ui.ScrollSlider:SetValue( value + ( IsShiftKeyDown() and 5 or 1 ) ) end )
			ui.ScrollSliderDown:SetMouseEnabled( true )
			ui.ScrollSliderDown:SetAlpha( 0.55 )

			c = EHT.CreateControl( prefix .. "ScrollList", ui.ScrollPanel, CT_CONTROL )
			ui.ScrollList = c
			local list = c
			c:SetAnchor( TOPLEFT, ui.ScrollPanel, TOPLEFT, 0, 5 )
			c:SetResizeToFitDescendents( true )
			c:SetWidth( ui.ScrollPanel:GetWidth() )
			c:SetMouseEnabled( false )
			c:SetDrawLevel( baseDrawLevel )

			for index = 1, NumListRows do
				EHT.UI.CreateTriggerQueueRow( index )
			end
		end

		return ui
	end

	function EHT.UI.CreateTriggerQueueRow( index )
		local baseDrawLevel = 100
		local ui = EHT.UI.TriggerQueueDialog
		local controls = ListRows
		local previousRow = controls[ index - 1 ]
		local c, control

		if not ui.ScrollEntryWidth then ui.ScrollEntryWidth = ui.ScrollList:GetWidth() end

		control = EHT.CreateControl( nil, ui.ScrollList, CT_CONTROL )
		controls[ index ] = control
		control:SetDrawLevel( baseDrawLevel )
		control:SetDimensions( ui.ScrollEntryWidth, 54 )
		control.Data = { }
		control:SetMouseEnabled( true )
		control:SetHidden( true )

		if previousRow then
			control:SetAnchor( TOPLEFT, previousRow, BOTTOMLEFT, 0, 10 )
		else
			control:SetAnchor( TOPLEFT, ui.ScrollList, TOPLEFT, 0, 0 )
		end

		baseDrawLevel = baseDrawLevel + 1

		c = EHT.CreateControl( nil, control, CT_TEXTURE )
		control.Background = c
		c:SetDrawLevel( baseDrawLevel )
		c:SetAnchor( TOPLEFT, control, TOPLEFT, 0, 0 )
		c:SetAnchor( BOTTOMRIGHT, control, BOTTOMRIGHT, 0, 0 )
		c:SetTexture( EHT.Textures.SOLID )
		c:SetColor( 0, 0, 0, 0.5 )

		baseDrawLevel = baseDrawLevel + 1

		c = EHT.CreateControl( nil, control, CT_LABEL )
		control.Index = c
		c:SetDrawLevel( baseDrawLevel )
		c:SetAnchor( LEFT, control, LEFT, 5, 0 )
		c:SetAnchor( RIGHT, control, LEFT, 25, 0 )
		c:SetFont( "$(BOLD_FONT)|$(KB_16)|soft-shadow-thin" )
		c:SetColor( 1, 1, 1, 1 )
		c:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		c:SetMaxLineCount( 1 )

		c = EHT.CreateControl( nil, control, CT_LABEL )
		control.Description = c
		c:SetDrawLevel( baseDrawLevel )
		c:SetAnchor( BOTTOMLEFT, control, LEFT, 36, -2 )
		c:SetAnchor( BOTTOMRIGHT, control, RIGHT, -90, -2 )
		c:SetFont( "$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thin" )
		c:SetColor( 1, 1, 1, 1 )
		c:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		c:SetMaxLineCount( 1 )
		c:SetMouseEnabled( true )

		c = EHT.CreateControl( nil, control, CT_LABEL )
		control.Task = c
		c:SetDrawLevel( baseDrawLevel )
		c:SetAnchor( TOPLEFT, control, LEFT, 36, 2 )
		c:SetAnchor( TOPRIGHT, control, RIGHT, -90, 2 )
		c:SetFont( "$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thin" )
		c:SetColor( 1, 1, 1, 1 )
		c:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		c:SetMaxLineCount( 1 )

		c = EHT.CreateControl( nil, control, CT_LABEL )
		control.Status = c
		c:SetDrawLevel( baseDrawLevel )
		c:SetAnchor( LEFT, control, RIGHT, -75, 0 )
		c:SetAnchor( RIGHT, control, RIGHT, -5, 0 )
		c:SetFont( "$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thin" )
		c:SetColor( 1, 1, 1, 1 )
		c:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		c:SetMaxLineCount( 1 )

		return control
	end

	function EHT.UI.UpdateTriggerQueueRow( row, data, index )
		if not data or not row then return end
		row.Data = data

		local desc = tostring( data.Trigger and data.Trigger.Name or "" )
		local task = "Task: |c66ffff"
		local alpha, status

		if data.TaskType == EHT.TASK_TYPE.ACTIVATE_TRIGGER then
			task = task .. "Activate Trigger"
		elseif data.TaskType == EHT.TASK_TYPE.PLAY_SCENE then
			task = task .. "Play Scene"
		else
			task = task .. "Update Items"
		end

		if not data.Started then
			status = "Pending"
			alpha = 0.5
		else
			status = "|c33ffffRunning"
			alpha = 1
		end

		row:SetAlpha( alpha )
		row.Index:SetText( tostring( index ) )
		row.Description:SetText( desc )
		row.Task:SetText( task )
		row.Status:SetText( status )

		EHT.UI.SetInfoTooltip( row.Description, desc )
	end

	function EHT.UI.UnsuppressDialog()
		SuppressDialog = false
	end

	function EHT.UI.HideTriggerQueue( suppress )
		if suppress then
			SuppressDialog = true
		end

		local ui = EHT.UI.TriggerQueueDialog

		if ui then
			ui.Window:SetHidden( true )
		end
	end

	function EHT.UI.ShowTriggerQueue()
		local ui = EHT.UI.SetupTriggerQueue()

		if not SuppressDialog and not isUIHidden then
			ui.Window:SetHidden( true == EHT.IsUIHidden )
		else
			ui.Window:SetHidden( true )
		end
	end

	function EHT.UI.UpdateTriggerQueue( firstIndex )
		firstIndex = firstIndex or ListFirstIndex or 1

		local ui = EHT.UI.SetupTriggerQueue()
		local list = ListData
		local maxIndex = list and #list or 0
		local c, r, lastIndex

		if 0 < maxIndex then
			if not firstIndex or firstIndex > maxIndex then
				firstIndex = 1
			end

			lastIndex = firstIndex + NumListRows - 1

			if lastIndex > maxIndex then
				lastIndex = maxIndex
				firstIndex = lastIndex - NumListRows + 1
				if 1 > firstIndex then firstIndex = 1 end
			end

			for index = 1, NumListRows do
				c = ListRows[ index ]

				if c then
					r = list[ index + firstIndex - 1 ]

					if r then
						EHT.UI.UpdateTriggerQueueRow( c, r, index + firstIndex - 1 )
						c:SetHidden( false )
					else
						c:SetHidden( true )
					end
				end
			end

			ListFirstIndex = firstIndex
		elseif ListRows then
			for _, c in ipairs( ListRows ) do
				c:SetHidden( true )
			end
		end
	end

	function EHT.UI.RefreshTriggerQueue( list )
		local ui = EHT.UI.SetupTriggerQueue()
		if not ui then return end

		if not list then
			EHT.UI.HideTriggerQueue()
			return
		end

		ListData = list
		local numItems = #ListData

		EHT.UI.UpdateTriggerQueue()

		local scrollMin, scrollMax = ( 0 < numItems and 1 or 0 ), ( 0 < ( numItems - NumListRows + 1 ) and ( numItems - NumListRows + 1 ) or 1 )
		ui.ScrollSlider:SetMinMax( scrollMin, scrollMax )

		local hideSlider = 1 >= scrollMax
		ui.ScrollSlider:SetHidden( hideSlider )
		ui.ScrollSliderUp:SetHidden( hideSlider )
		ui.ScrollSliderDown:SetHidden( hideSlider )
		ui.ScrollSliderBackground:SetHidden( hideSlider )

		ui.Count:SetText( string.format( "(%d)", tostring( #ListData ) ) )

		if 0 < #ListData and EHT.GetSetting("ShowTriggerQueue") then
			EHT.UI.ShowTriggerQueue()
		else
			EHT.UI.HideTriggerQueue()
		end
	end

end

---[ Guildcast ]---

do
	local ListData = { }
	local ListRows = { }
	local ListFirstIndex = 1
	local NumListRows = 5
	local MaxListData = 5

	function EHT.UI.SetupGuildcast()
		local ui = EHT.UI.GuildcastDialog
		if not ui then
			ui = { }
			EHT.UI.GuildcastDialog = ui

			local windowName = "EHTGuildcast"
			local prefix = "EHTGuildcast"
			local settings = EHT.UI.GetDialogSettings( windowName )
			local height, width = 334, 450
			local baseDrawLevel = 100

			-- Window Controls

			local c, grp, section, frame, win, windowFrame

			win = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
			ui.Window = win
			win:SetDimensionConstraints( width, height, width, height )
			win:SetAlpha( 0.8 )
			win:SetHidden( true )
			win:SetMovable( true )
			win:SetMouseEnabled( true )
			win:SetClampedToScreen( true )
			win:SetResizeHandleSize( 0 )
			win:SetDrawTier( DT_HIGH )

			if settings.Left and settings.Top then
				win:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, settings.Left, settings.Top )
			else
				win:SetAnchor( LEFT, GuiRoot, LEFT, 5, 0 )
			end

			win:SetHandler( "OnMoveStop", function() EHT.UI.SaveDialogSettings( windowName, win ) end )

			do

				grp = EHT.CreateControl( nil, win, CT_CONTROL )
				ui.TitleBar = grp
				grp:SetAnchor( BOTTOMLEFT, win, TOPLEFT, 10, 0 )
				grp:SetAnchor( TOPRIGHT, win, TOPRIGHT, -10, -50 )
				grp:SetMouseEnabled( true )
				grp:SetHandler( "OnMouseDown", function() win:StartMoving() end )
				grp:SetHandler( "OnMouseUp", function() win:StopMovingOrResizing() end )

				c = EHT.CreateControl( nil, grp, CT_TEXTURE )
				ui.HeadingBackdrop = c
				c:SetTexture( EHT.Textures.SOLID )
				c:SetAnchor( BOTTOMLEFT, grp, BOTTOMLEFT, 0, 0 )
				c:SetAnchor( TOPRIGHT, grp, TOPRIGHT, 0, 0 )
				c:SetVertexColors( 1 + 2, 0.5, 0.5, 0.5, 0 )
				c:SetVertexColors( 4 + 8, 0.4, 0.4, 0.4, 0.94 )
				c:SetBlendMode( TEX_BLEND_MODE_ALPHA )
				c:SetMouseEnabled( false )

				c = EHT.CreateControl( nil, grp, CT_TEXTURE )
				ui.IconBackdrop = c
				c:SetTexture( "esoui/art/campaign/gamepad/gp_overview_menuicon_home.dds" )
				c:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
				c:SetAnchor( BOTTOMLEFT, grp, BOTTOMLEFT, 6, 1 )
				c:SetAnchor( TOPRIGHT, grp, BOTTOMLEFT, 46, -44 )
				c:SetColor( 0, 0, 0, 0.5 )
				c:SetBlendMode( TEX_BLEND_MODE_ALPHA )
				c:SetMouseEnabled( false )

				c = EHT.CreateControl( nil, grp, CT_TEXTURE )
				ui.Icon = c
				c:SetTexture( "esoui/art/campaign/gamepad/gp_overview_menuicon_home.dds" )
				c:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
				c:SetAnchor( BOTTOMLEFT, grp, BOTTOMLEFT, 5, 0 )
				c:SetAnchor( TOPRIGHT, grp, BOTTOMLEFT, 45, -45 )
				c:SetColor( 0.9, 0.9, 0.9, 1 )
				c:SetBlendMode( TEX_BLEND_MODE_ALPHA )
				c:SetMouseEnabled( false )

				c = EHT.CreateControl( prefix .. "HeadingBackdrop", grp, CT_LABEL )
				ui.HeadingBackdrop = c
				c:SetDrawLevel( baseDrawLevel + 1 )
				c:SetFont( "$(MEDIUM_FONT)|$(KB_24)" )
				c:SetColor( 0, 0, 0, 1 )
				c:SetAnchor( BOTTOMLEFT, grp, BOTTOMLEFT, 52, -3 )
				c:SetText( "Share FX with Online Guild members" )
				c:SetMouseEnabled( false )

				c = EHT.CreateControl( prefix .. "Heading", grp, CT_LABEL )
				ui.Heading = c
				c:SetDrawLevel( baseDrawLevel + 2 )
				c:SetFont( "$(MEDIUM_FONT)|$(KB_24)" )
				c:SetColor( 0, 1, 1, 1 )
				c:SetAnchor( BOTTOMLEFT, grp, BOTTOMLEFT, 50, -5 )
				c:SetText( "Share FX with |cffff00Online|r Guild members" )
				c:SetMouseEnabled( false )

			end

			c = EHT.CreateControl( nil, win, CT_TEXTURE )
			ui.Backdrop = c
			c:SetTexture( EHT.Textures.SOLID )
			c:SetVertexColors( 1, 0, 0.3, 0.1, 1 )
			c:SetVertexColors( 2 + 4, 0, 0.15, 0.15, 1 )
			c:SetVertexColors( 8, 0, 0.1, 0.3, 1 )
			c:SetAnchor( TOPLEFT, win, TOPLEFT, 10, 0 )
			c:SetAnchor( BOTTOMRIGHT, win, BOTTOMRIGHT, -10, 0 )
			c:SetBlendMode( TEX_BLEND_MODE_ALPHA )
			c:SetMouseEnabled( false )

			windowFrame = EHT.CreateControl( prefix .. "WindowFrame", win, CT_CONTROL )
			ui.WindowFrame = windowFrame
			windowFrame:SetAnchor( TOPLEFT, win, TOPLEFT, 18, 5 )
			windowFrame:SetAnchor( BOTTOMRIGHT, win, BOTTOMRIGHT, -18, -15 )
			windowFrame:SetDrawLevel( baseDrawLevel )

			c = EHT.CreateControl( prefix .. "HouseNameLabel", windowFrame, CT_LABEL )
			ui.HouseNameLabel = c
			c:SetDrawLevel( baseDrawLevel )
			c:SetFont( "$(BOLD_FONT)|$(KB_18)|soft-shadow-thick" )
			c:SetColor( 1, 1, 1, 1 )
			c:SetAnchor( TOPLEFT, windowFrame, TOPLEFT, 4, 0 )
			c:SetAnchor( TOPRIGHT, windowFrame, TOPRIGHT, -4, 0 )
			c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
			c:SetMaxLineCount( 1 )
			c:SetText( "" )
			c:SetMouseEnabled( false )

			c = EHT.CreateControl( prefix .. "HouseOwnerLabel", windowFrame, CT_LABEL )
			ui.HouseOwnerLabel = c
			c:SetDrawLevel( baseDrawLevel )
			c:SetFont( "$(MEDIUM_FONT)|$(KB_18)|soft-shadow-thick" )
			c:SetColor( 1, 1, 1, 1 )
			c:SetAnchor( TOPLEFT, ui.HouseNameLabel, BOTTOMLEFT )
			c:SetAnchor( TOPRIGHT, ui.HouseNameLabel, BOTTOMRIGHT )
			c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
			c:SetMaxLineCount( 1 )
			c:SetText( "" )
			c:SetMouseEnabled( false )

			c = EHT.CreateControl( prefix .. "ScrollPanel", windowFrame, CT_CONTROL )
			ui.ScrollPanel = c
			c:SetAnchor( TOPLEFT, ui.HouseOwnerLabel, BOTTOMLEFT, 0, 5 )
			c:SetAnchor( BOTTOMRIGHT, windowFrame, BOTTOMRIGHT, -22, 0 )
			c:SetMouseEnabled( true )
			c:SetDrawLevel( baseDrawLevel )

			c = EHT.CreateControl( prefix .. "ScrollSliderBackground", windowFrame, CT_TEXTURE )
			ui.ScrollSliderBackground = c
			c:SetAnchor( TOPLEFT, ui.ScrollPanel, TOPRIGHT, 4, 30 )
			c:SetAnchor( BOTTOMRIGHT, ui.ScrollPanel, BOTTOMRIGHT, 22, -30 )
			c:SetColor( 0, 0, 0, 0.65 )
			c:SetMouseEnabled( false )

			c = EHT.CreateControl( prefix .. "ScrollSlider", windowFrame, CT_SLIDER )
			ui.ScrollSlider = c
			c:SetAnchor( TOPLEFT, ui.ScrollSliderBackground, TOPLEFT, 1, 1 )
			c:SetAnchor( BOTTOMRIGHT, ui.ScrollSliderBackground, BOTTOMRIGHT, -1, -1 )
			c:SetValue( 0 )
			c:SetValueStep( 1 )
			c:SetMouseEnabled( true )
			c:SetDrawLevel( baseDrawLevel )
			c:SetAllowDraggingFromThumb( true )
			c:SetThumbTexture( "EsoUI\\Art\\Miscellaneous\\scrollbox_elevator.dds", "EsoUI\\Art\\Miscellaneous\\scrollbox_elevator_disabled.dds", nil, 22, 64 )
			c:GetThumbTextureControl():SetAlpha( 0.55 )
			c:SetOrientation( ORIENTATION_VERTICAL )

			ui.ScrollSlider:SetHandler( "OnValueChanged", function( self, value, eventReason )
				EHT.UI.UpdateGuildcast( value )
			end )

			ui.ScrollPanel:SetHandler( "OnMouseWheel", function( self, delta, ctrl, alt, shift )
				local slider = ui.ScrollSlider
				local value = slider:GetValue()
				if 0 == value then value = 1 end
				slider:SetValue( value - ( delta * ( shift and 5 or 1 ) ) )
			end )

			ui.ScrollSliderUp = EHT.UI.CreateTextureButton(
				prefix .. "ScrollSliderUpButton",
				ui.ScrollSlider,
				"esoui/art/miscellaneous/gamepad/gp_scrollarrow_up.dds",
				22, 22,
				{ { BOTTOM, ui.ScrollSlider, TOP, 0, 0 } },
				function() local value = ui.ScrollSlider:GetValue() ui.ScrollSlider:SetValue( value - ( IsShiftKeyDown() and 5 or 1 ) ) end )
			ui.ScrollSliderUp:SetMouseEnabled( true )
			ui.ScrollSliderUp:SetAlpha( 0.55 )

			ui.ScrollSliderDown = EHT.UI.CreateTextureButton(
				prefix .. "ScrollSliderDownButton",
				ui.ScrollSlider,
				"esoui/art/miscellaneous/gamepad/gp_scrollarrow.dds",
				22, 22,
				{ { TOP, ui.ScrollSlider, BOTTOM, 0, 0 } },
				function() local value = ui.ScrollSlider:GetValue() if 0 == value then value = 1 end ui.ScrollSlider:SetValue( value + ( IsShiftKeyDown() and 5 or 1 ) ) end )
			ui.ScrollSliderDown:SetMouseEnabled( true )
			ui.ScrollSliderDown:SetAlpha( 0.55 )

			c = EHT.CreateControl( prefix .. "ScrollList", ui.ScrollPanel, CT_CONTROL )
			ui.ScrollList = c
			local list = c
			c:SetAnchor( TOPLEFT, ui.ScrollPanel, TOPLEFT, 0, 5 )
			c:SetResizeToFitDescendents( true )
			c:SetWidth( ui.ScrollPanel:GetWidth() )
			c:SetMouseEnabled( false )
			c:SetDrawLevel( baseDrawLevel )


			for index = 1, NumListRows do
				EHT.UI.CreateGuildcastRow( index )
			end


			do

				grp = EHT.CreateControl( nil, win, CT_CONTROL )
				ui.FooterBar = grp
				grp:SetAnchor( TOPLEFT, win, BOTTOMLEFT, 10, 0 )
				grp:SetAnchor( BOTTOMRIGHT, win, BOTTOMRIGHT, -10, 50 )
				grp:SetMouseEnabled( true )
				grp:SetHandler( "OnMouseDown", function() win:StartMoving() end )
				grp:SetHandler( "OnMouseUp", function() win:StopMovingOrResizing() end )

				c = EHT.CreateControl( nil, grp, CT_TEXTURE )
				ui.FooterBackdrop = c
				c:SetTexture( EHT.Textures.SOLID )
				c:SetAnchor( BOTTOMLEFT, grp, BOTTOMLEFT, 0, 0 )
				c:SetAnchor( TOPRIGHT, grp, TOPRIGHT, 0, 0 )
				c:SetVertexColors( 4 + 8, 0.5, 0.5, 0.5, 0 )
				c:SetVertexColors( 1 + 2, 0.4, 0.4, 0.4, 0.94 )
				c:SetBlendMode( TEX_BLEND_MODE_ALPHA )
				c:SetMouseEnabled( false )

				c = EHT.CreateControl( nil, grp, CT_TEXTURE )
				ui.ShareButtonOutline = c
				c:SetDrawLevel( baseDrawLevel )
				c:SetAnchor( LEFT, grp, CENTER, 20, 4 )
				c:SetDimensions( 121, 39 )
				c:SetColor( 0.8, 0.8, 0.8, 1 )
				c:SetMouseEnabled( true )
				c:SetHandler( "OnMouseDown", function()

					if 0 ~= EHT.Guilds:GetNumQueuedActions() then
						EHT.UI.HideGuildcast()
						EHT.UI.ShowAlertDialog( "", "FX are currently being shared with one or more guilds.\n\nPlease wait until the current sharing is complete.", EHT.UI.UnhideGuildcast )
						return
					end

					local guilds = { }
					local guildCount = 0

					for index, c in pairs( ListRows ) do
						if c.GuildName and c.Enabled.Checked then
							guilds[c.GuildName] = true
							guildCount = guildCount + 1
						end
					end

					local houseId, houseOwner = ui.HouseId, ui.HouseOwner

					if 0 == guildCount then
						EHT.UI.HideGuildcast()
						EHT.UI.ShowAlertDialog( "", "Please select one or more guilds to share with.", EHT.UI.UnhideGuildcast )
						return
					end

					local estDuration = EHT.Effect:QueueGuildcast( houseId, houseOwner, guilds )
					EHT.UI.HideGuildcast()

					if "number" == type( estDuration ) then
						if 60 > estDuration then
							estDuration = string.format( "%d second(s)", estDuration )
						elseif 0 ~= ( estDuration % 60 ) then
							estDuration = string.format( "%d minute(s), %d second(s)", estDuration / 60, estDuration % 60 )
						else
							estDuration = string.format( "%d minute(s)", estDuration / 60 )
						end
					end

					EHT.UI.ShowAlertDialog( "", string.format(
						"Sharing has started and is estimated to take approximately:\n|c00ffff%s",
						estDuration or "Not long"
					) )

				end )

				c = EHT.CreateControl( nil, ui.ShareButtonOutline, CT_TEXTURE )
				ui.ShareButton = c
				c:SetDrawLevel( baseDrawLevel + 1 )
				c:SetAnchor( CENTER, ui.ShareButtonOutline, CENTER, 0, 0 )
				c:SetDimensions( 117, 35 )
				c:SetColor( 0.1, 0.3, 0.3, 1 )

				c = EHT.CreateControl( nil, ui.ShareButton, CT_LABEL )
				ui.ShareButtonLabel = c
				c:SetDrawLevel( baseDrawLevel + 2 )
				c:SetFont( "$(BOLD_FONT)|$(KB_18)|soft-shadow-thick" )
				c:SetAnchor( CENTER )
				c:SetText( "Share" )
				c:SetColor( 1, 1, 0, 1 )

				c = EHT.CreateControl( nil, grp, CT_TEXTURE )
				ui.CloseButtonOutline = c
				c:SetAnchor( RIGHT, grp, CENTER, -20, 4 )
				c:SetDrawLevel( baseDrawLevel )
				c:SetDimensions( 121, 39 )
				c:SetColor( 0.8, 0.8, 0.8, 1 )
				c:SetMouseEnabled( true )
				c:SetHandler( "OnMouseDown", function() EHT.UI.HideGuildcast() end )

				c = EHT.CreateControl( prefix .. "CloseButton", ui.CloseButtonOutline, CT_TEXTURE )
				ui.CloseButton = c
				c:SetDrawLevel( baseDrawLevel + 1 )
				c:SetAnchor( CENTER )
				c:SetDimensions( 117, 35 )
				c:SetColor( 0.1, 0.3, 0.3, 1 )
				c:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
				c:SetMouseEnabled( false )

				c = EHT.CreateControl( prefix .. "CloseButtonLabel", ui.CloseButton, CT_LABEL )
				ui.CloseButtonLabel = c
				c:SetDrawLevel( baseDrawLevel + 2 )
				c:SetFont( "$(BOLD_FONT)|$(KB_18)|soft-shadow-thick" )
				c:SetAnchor( CENTER )
				c:SetText( "Cancel" )
				c:SetColor( 1, 1, 0, 1 )
				c:SetMouseEnabled( false )

			end

		end

		return ui
	end

	function EHT.UI.CreateGuildcastRow( index )
		local baseDrawLevel = 100
		local ui = EHT.UI.GuildcastDialog
		local controls = ListRows
		local previousRow = controls[ index - 1 ]
		local c, control

		if not ui.ScrollEntryWidth then ui.ScrollEntryWidth = ui.ScrollList:GetWidth() end

		control = EHT.CreateControl( nil, ui.ScrollList, CT_CONTROL )
		controls[ index ] = control
		control:SetDrawLevel( baseDrawLevel )
		control:SetDimensions( ui.ScrollEntryWidth, 42 )
		control.Data = { }
		control:SetMouseEnabled( true )
		control:SetHidden( true )

		if previousRow then
			control:SetAnchor( TOPLEFT, previousRow, BOTTOMLEFT, 0, 10 )
		else
			control:SetAnchor( TOPLEFT, ui.ScrollList, TOPLEFT, 0, 0 )
		end

		baseDrawLevel = baseDrawLevel + 1

		c = EHT.CreateControl( nil, control, CT_TEXTURE )
		control.Background = c
		c:SetDrawLevel( baseDrawLevel )
		c:SetAnchor( TOPLEFT, control, TOPLEFT, 0, 0 )
		c:SetAnchor( BOTTOMRIGHT, control, BOTTOMRIGHT, 0, 0 )
		c:SetTexture( EHT.Textures.SOLID )
		c:SetColor( 0, 0, 0, 0.5 )
		c:SetMouseEnabled( false )

		baseDrawLevel = baseDrawLevel + 1

		c = EHT.CreateControl( nil, control, CT_TEXTURE )
		control.BackgroundHighlight = c
		c:SetDrawLevel( baseDrawLevel )
		c:SetAnchor( TOPLEFT, control, TOPLEFT, 0, 0 )
		c:SetAnchor( BOTTOMRIGHT, control, BOTTOMRIGHT, 0, 0 )
		c:SetTexture( EHT.Textures.SOLID )
		c:SetColor( 0, 0, 0, 0 )
		c:SetMouseEnabled( false )

		baseDrawLevel = baseDrawLevel + 1

		c = EHT.CreateControl( nil, control, CT_TEXTURE )
		control.Enabled = c
		c:SetDrawLevel( baseDrawLevel )
		c:SetAnchor( LEFT, control, LEFT, 5, 0 )
		c:SetDimensions( 40, 40 )
		c:SetColor( 1, 1, 1, 1 )
		c:SetMouseEnabled( false )
		c.Checked = false

		c = EHT.CreateControl( nil, control, CT_LABEL )
		control.Description = c
		c:SetDrawLevel( baseDrawLevel )
		c:SetAnchor( LEFT, control, LEFT, 50, 0 )
		c:SetAnchor( RIGHT, control, RIGHT, -80, 0 )
		c:SetFont( "$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thin" )
		c:SetColor( 1, 1, 1, 1 )
		c:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		c:SetMaxLineCount( 1 )
		c:SetMouseEnabled( false )

		control.RefreshEnabled = function()
			local enabled = control.Enabled.Checked

			if enabled then
				control.Enabled:SetTexture( "esoui/art/cadwell/checkboxicon_checked.dds" )
				control.Enabled:SetColor( 1, 1, 1, 1 )
				control.Description:SetColor( 0.5, 1, 1, 1 )
				control.BackgroundHighlight:SetAlpha( 0.5 )
			else
				control.Enabled:SetTexture( "esoui/art/cadwell/checkboxicon_unchecked.dds" )
				control.Enabled:SetColor( 0.5, 0.5, 0.5, 1 )
				control.Description:SetColor( 1, 1, 1, 1 )
				control.BackgroundHighlight:SetAlpha( 0 )
			end

			if control.IsDisabled then
				control.Description:SetColor( 0.3, 0.3, 0.3, 1 )
			end
		end

		control.Toggle = function()
			if control.IsDisabled then
				EHT.UI.HideGuildcast()
				EHT.UI.ShowAlertDialog( "",
					"Permission to edit your Guild Member Note is required in order to share FX with your guild.\n\n" ..
					"Please contact this guild's Guild Master or an Officer to request permission.", EHT.UI.UnhideGuildcast )

				return
			end

			local enabled = not control.Enabled.Checked

			control.Enabled.Checked = enabled
			control.RefreshEnabled()
		end

		control:SetHandler( "OnMouseDown", control.Toggle )

		return control
	end

	function EHT.UI.UpdateGuildcastRow( row, data, index )
		if not data or not row then return end
		row.Data = data

		local name = tostring( data.Name or "" )
		row.GuildName = name
		row.Description:SetText( name )

		row.IsDisabled = not data.CanEditNotes
		if row.IsDisabled then row.Enabled.Checked = false end

		row.RefreshEnabled()
	end

	function EHT.UI.HideGuildcast()
		local ui = EHT.UI.GuildcastDialog
		if ui then ui.Window:SetHidden( true ) end
	end

	function EHT.UI.UnhideGuildcast()
		local ui = EHT.UI.GuildcastDialog
		if ui then ui.Window:SetHidden( false ) end
	end

	function EHT.UI.ShowGuildcast( houseId, owner )
		local forceShow = houseId or owner
		local ui = EHT.UI.SetupGuildcast()

		ui.HouseId = houseId or EHT.Housing.GetHouseId()
		ui.HouseOwner = owner or GetDisplayName()

		local house = EHT.Housing.GetHouseById( ui.HouseId )
		if not house then
			EHT.UI.ShowAlertDialog( "", "Error: Guild sharing window was initialized with an invalid House Id.\n\nIf you would submit this error message via the Feedback form, it would be greatly appreciated." )
			return
		end

		ui.HouseNameLabel:SetText( house.Name )
		ui.HouseOwnerLabel:SetText( ui.HouseOwner )

		local list = EHT.Guilds:GetGuilds()
		if not list then return end

		ListData = list
		local numItems = #ListData

		EHT.UI.UpdateGuildcast()

		local scrollMin, scrollMax = ( 0 < numItems and 1 or 0 ), ( 0 < ( numItems - NumListRows + 1 ) and ( numItems - NumListRows + 1 ) or 1 )
		ui.ScrollSlider:SetMinMax( scrollMin, scrollMax )

		local hideSlider = 1 >= scrollMax
		ui.ScrollSlider:SetHidden( hideSlider )
		ui.ScrollSliderUp:SetHidden( hideSlider )
		ui.ScrollSliderDown:SetHidden( hideSlider )
		ui.ScrollSliderBackground:SetHidden( hideSlider )

		if ( forceShow or not isUIHidden ) and ui.Window:IsHidden() then ui.Window:SetHidden( false ) end

	end


	function EHT.UI.UpdateGuildcast( firstIndex )

		firstIndex = firstIndex or ListFirstIndex or 1

		local ui = EHT.UI.SetupGuildcast()
		local list = ListData
		local maxIndex = list and #list or 0
		local c, r, lastIndex

		if 0 < maxIndex then
			if not firstIndex or firstIndex > maxIndex then
				firstIndex = 1
			end

			lastIndex = firstIndex + NumListRows - 1

			if lastIndex > maxIndex then
				lastIndex = maxIndex
				firstIndex = lastIndex - NumListRows + 1
				if 1 > firstIndex then firstIndex = 1 end
			end

			for index = 1, NumListRows do
				c = ListRows[ index ]

				if c then
					r = list[ index + firstIndex - 1 ]

					if r then
						EHT.UI.UpdateGuildcastRow( c, r, index + firstIndex - 1 )
						c:SetHidden( false )
					else
						c:SetHidden( true )
					end
				end
			end

			ListFirstIndex = firstIndex
		elseif ListRows then
			for _, c in ipairs( ListRows ) do
				c:SetHidden( true )
			end
		end

	end

end

---[ Share FX Context Menu ]---

function EHT.UI.OnAutoHideShareFXContextMenu()
	local ui = EHT.UI.SetupShareFXContextMenu()

	if not EHT.UI.IsMouseOverControl( ui.Window ) and not EHT.UI.IsMouseOverControl( ui.Data.AnchorControl ) then
		local ts = GetFrameTimeMilliseconds()

		if not ui.Data.AutoHideTS then
			ui.Data.AutoHideTS = ts + 250
		elseif ts > ui.Data.AutoHideTS then
			EHT.UI.HideShareFXContextMenu()
		end
	elseif ui.Data.AutoHideTS then
		ui.Data.AutoHideTS = nil
	end
end

function EHT.UI.HideShareFXContextMenu()
	local ui = EHT.UI.SetupShareFXContextMenu()
	ui.Window:SetHidden( true )

	EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.OnAutoHideShareFXContextMenu" )
end

function EHT.UI.ShowShareFXContextMenu( player, houseId, anchorPoint, anchorControl, anchorControlPoint, anchorOffsetX, anchorOffsetY )
	if not player or "" == player then
		player = GetDisplayName()
	end

	if not houseId or 0 == houseId then
		houseId = EHT.Housing.GetZoneHouseId()
	end

	if not houseId or 0 == houseId then
		return false
	end

	local house = EHT.Housing.GetHouseById( houseId )
	if not house then
		return false
	end
	local houseName = house.Name

	local ui = EHT.UI.SetupShareFXContextMenu()

	ui.Data.AutoHideTS = nil
	ui.Data.AnchorControl = anchorControl
	ui.Data.Player = player
	ui.Data.HouseId = houseId
	ui.Data.HouseName = houseName

	local thirdParty = string.lower( ui.Data.Player ) ~= displayNameLower

	if not thirdParty then
		local size = EssentialHousingHub:EstimateCommunityFXRecordSize( houseId )
		ui.FXSize:SetText( ( not size or 0 == size ) and "No FX published" or string.format( "Published |cffff33%d|rk / |cffff33700|rk FX data", ( size / 1000 ) + 1 ) )
	else
		ui.FXSize:SetText( "Third-party Sharing" )
	end

	ui.PublishButton.Enabled = not thirdParty
	if thirdParty then
		ui.PublishButton:SetDesaturation( 1 )
		ui.PublishButton:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 0.5 )
		ui.PublishButton.Label:SetText( "Publish to Community" )
	else
		ui.PublishButton:SetDesaturation( 0 )
		ui.PublishButton:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 1 )

		local house = EHT.Data.GetHouseById( houseId )
		if "table" ~= type( house ) or "table" ~= type( house.Effects ) then
			ui.PublishButton.Label:SetText( "Publish to Community" )
		else
			ui.PublishButton.Label:SetText( string.format( "Publish to Community (|cffff33%d|rk)", ( #EHT.Util.Serialize( house.Effects ) / 1000 ) + 1 ) )
		end
	end

	ui.UnpublishButton.Enabled = false
	if not thirdParty then
		ui.UnpublishButton.Enabled = nil ~= EssentialHousingHub:GetCommunityHouseFXRecord( GetDisplayName(), EHT.Util.GetWorldCode(), ui.Data.HouseId )
	end

	if not ui.UnpublishButton.Enabled then
		ui.UnpublishButton:SetDesaturation( 1 )
		ui.UnpublishButton:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 0.5 )
	else
		ui.UnpublishButton:SetDesaturation( 0 )
		ui.UnpublishButton:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 1 )
	end

	ui.Window:ClearAnchors()
	ui.Window:SetAnchor( anchorPoint, anchorControl, anchorControlPoint, anchorOffsetX or 0, anchorOffsetY or 0 )
	ui.Window:SetHidden( false )

	EVENT_MANAGER:RegisterForUpdate( "EHT.UI.OnAutoHideShareFXContextMenu", 100, EHT.UI.OnAutoHideShareFXContextMenu )

	return true
end

function EHT.UI.SetupShareFXContextMenu()
	local ui = EHT.UI.ShareFXContextMenu

	if nil == ui then

		ui = { Data = { } }
		EHT.UI.ShareFXContextMenu = ui

		local prefix = "ShareFXContextMenu"
		local height, width = 206, 240
		local baseDrawLevel = 1000

		-- Window Controls

		local b, btn, c, win

		local function tip( control, msg )
			EHT.UI.SetInfoTooltip( control, msg )
		end

		win = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
		ui.Window = win
		win:SetDimensionConstraints( width, height, width, height )
		win:SetHidden( true )
		win:SetAlpha( 1 )
		win:SetMovable( false )
		win:SetMouseEnabled( true )
		win:SetClampedToScreen( false )
		win:SetResizeHandleSize( 0 )
		win:SetDrawTier( DT_HIGH )
		win:SetDrawLayer( DL_TEXT )

		c = EHT.CreateControl( nil, win, CT_TEXTURE )
		ui.BackdropShadow = c
		c:SetAnchor( TOPLEFT, win, TOPLEFT, 0, 0 )
		c:SetAnchor( BOTTOMRIGHT, win, BOTTOMRIGHT, 0, 0 )
		c:SetBlendMode( TEX_BLEND_MODE_ALPHA )
		c:SetDrawLevel( baseDrawLevel - 2 )
		c:SetTexture( EHT.Textures.SOLID )
		c:SetVertexColors( 2 + 8, 0, 0.3, 0.4, 1 )
		c:SetVertexColors( 1 + 4, 0.1, 0.1, 0.1, 1 )

		c = EHT.CreateControl( nil, win, CT_TEXTURE )
		ui.Backdrop = c
		c:SetAnchor( TOPLEFT, win, TOPLEFT, 2, 2 )
		c:SetAnchor( BOTTOMRIGHT, win, BOTTOMRIGHT, -2, -2 )
		c:SetBlendMode( TEX_BLEND_MODE_ALPHA )
		c:SetDrawLevel( baseDrawLevel - 1 )
		c:SetTexture( EHT.Textures.SOLID )
		c:SetVertexColors( 1 + 4, 0, 0.3, 0.4, 1 )
		c:SetVertexColors( 2 + 8, 0.1, 0.1, 0.1, 1 )

		b = EHT.CreateControl( prefix .. "Body", win, CT_CONTROL )
		ui.Body = b
		b:SetAnchor( TOPLEFT, win, TOPLEFT, 10, 14 )
		b:SetAnchor( BOTTOMRIGHT, win, BOTTOMRIGHT, -10, -14 )
		b:SetDrawLevel( baseDrawLevel )

		c = EHT.CreateControl( nil, b, CT_LABEL )
		ui.FXSize = c
		c:SetAnchor( TOP, b, TOP, 0, 0 )
		c:SetDrawLevel( baseDrawLevel )
		c:SetFont( "$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thin" )
		c:SetMouseEnabled( false )
		c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		c:SetText( "" )

		-- Buttons

		c = EHT.CreateControl( nil, b, CT_TEXTURE )
		ui.PublishButton = c
		c:SetAnchor( TOP, b, TOP, 0, 30 )
		c:SetDimensions( 220, 30 )
		c:SetDrawLevel( baseDrawLevel )
		c:SetTexture( EHT.Textures.SOLID )
		c:SetColor( 0, 0.7, 0.7, 1 )
		c:SetMouseEnabled( true )
		c:SetHandler( "OnMouseEnter", OnFormButtonMouseEnter )
		c:SetHandler( "OnMouseExit", OnFormButtonMouseExit )
		c:SetHandler( "OnMouseUp", function()
			if not ui.PublishButton.Enabled then
				return
			end
			EHT.UI.PublishFX( ui.Data.HouseId )
		end )
		btn = c

		tip( btn, TIP_FX_SHARE_COMMUNITY )

		c = EHT.CreateControl( nil, btn, CT_LABEL )
		btn.Label = c
		c:SetAnchor( CENTER, btn, CENTER, 0, 0 )
		c:SetDrawLevel( baseDrawLevel )
		c:SetFont( "$(BOLD_FONT)|$(KB_16)|soft-shadow-thin" )
		c:SetMouseEnabled( false )
		c:SetText( "Publish to Community" )

		OnFormButtonMouseExit( btn )

		c = EHT.CreateControl( nil, b, CT_TEXTURE )
		ui.UnpublishButton = c
		c:SetAnchor( TOP, btn, BOTTOM, 0, 10 )
		c:SetDimensions( 220, 30 )
		c:SetDrawLevel( baseDrawLevel )
		c:SetTexture( EHT.Textures.SOLID )
		c:SetColor( 0, 0.7, 0.7, 1 )
		c:SetMouseEnabled( true )
		c:SetHandler( "OnMouseEnter", OnFormButtonMouseEnter )
		c:SetHandler( "OnMouseExit", OnFormButtonMouseExit )
		c:SetHandler( "OnMouseUp", function()
			if not ui.UnpublishButton.Enabled then
				return
			end
			EHT.UI.UnpublishFX( ui.Data.HouseId )
		end )
		btn = c

		tip( btn, "Removes the previously published FX for this home from the Community server." )

		c = EHT.CreateControl( nil, btn, CT_LABEL )
		btn.Label = c
		c:SetAnchor( CENTER, btn, CENTER, 0, 0 )
		c:SetDrawLevel( baseDrawLevel )
		c:SetFont( "$(BOLD_FONT)|$(KB_16)|soft-shadow-thin" )
		c:SetMouseEnabled( false )
		c:SetText( "Unpublish from Community" )

		OnFormButtonMouseExit( btn )

		c = EHT.CreateControl( nil, b, CT_TEXTURE )
		ui.GuildButton = c
		c:SetAnchor( TOP, btn, BOTTOM, 0, 10 )
		c:SetDimensions( 220, 30 )
		c:SetDrawLevel( baseDrawLevel )
		c:SetTexture( EHT.Textures.SOLID )
		c:SetColor( 0, 0.7, 0.7, 1 )
		c:SetMouseEnabled( true )
		c:SetHandler( "OnMouseEnter", OnFormButtonMouseEnter )
		c:SetHandler( "OnMouseExit", OnFormButtonMouseExit )
		c:SetHandler( "OnMouseUp", function()
			EHT.UI.HideShareFXContextMenu()
			EHT.UI.HideHousingHub()
			EHT.UI.ShowGuildcast( ui.Data.HouseId, ui.Data.Player )
		end )
		btn = c

		tip( btn, TIP_FX_SHARE_GUILDS )

		c = EHT.CreateControl( nil, btn, CT_LABEL )
		btn.Label = c
		c:SetAnchor( CENTER, btn, CENTER, 0, 0 )
		c:SetDrawLevel( baseDrawLevel )
		c:SetFont( "$(BOLD_FONT)|$(KB_16)|soft-shadow-thin" )
		c:SetMouseEnabled( false )
		c:SetText( "Share with Guilds" )

		OnFormButtonMouseExit( btn )

		c = EHT.CreateControl( nil, b, CT_TEXTURE )
		ui.ChatButton = c
		c:SetAnchor( TOP, btn, BOTTOM, 0, 10 )
		c:SetDimensions( 220, 30 )
		c:SetDrawLevel( baseDrawLevel )
		c:SetTexture( EHT.Textures.SOLID )
		c:SetColor( 0, 0.7, 0.7, 1 )
		c:SetMouseEnabled( true )
		c:SetHandler( "OnMouseEnter", OnFormButtonMouseEnter )
		c:SetHandler( "OnMouseExit", OnFormButtonMouseExit )
		c:SetHandler( "OnMouseUp", function()
			EHT.UI.HideShareFXContextMenu()
			EHT.UI.HideHousingHub()
			EHT.Effect:InitializeChatcast( nil, ui.Data.HouseId, ui.Data.Player )
		end )
		btn = c

		tip( btn, TIP_FX_SHARE_CHAT )

		c = EHT.CreateControl( nil, btn, CT_LABEL )
		btn.Label = c
		c:SetAnchor( CENTER, btn, CENTER, 0, 0 )
		c:SetDrawLevel( baseDrawLevel )
		c:SetFont( "$(BOLD_FONT)|$(KB_16)|soft-shadow-thin" )
		c:SetMouseEnabled( false )
		c:SetText( "Share with Chat" )

		OnFormButtonMouseExit( btn )

	end

	return ui
end

---[ Multi-Place Context Menu ]---

function EHT.UI.OnAutoHideMultiPlaceContextMenu()
	local ui = EHT.UI.SetupMultiPlaceContextMenu()

	if not EHT.UI.IsMouseOverControl( ui.Window ) and ( not ui.Data.AnchorControl or not EHT.UI.IsMouseOverControl( ui.Data.AnchorControl ) ) then
		local ts = GetFrameTimeMilliseconds()

		if not ui.Data.AutoHideTS then
			ui.Data.AutoHideTS = ts + 250
		elseif ts > ui.Data.AutoHideTS then
			EHT.UI.HideMultiPlaceContextMenu()
		end
	elseif ui.Data.AutoHideTS then
		ui.Data.AutoHideTS = nil
	end
end

function EHT.UI.HideMultiPlaceContextMenu()
	local ui = EHT.UI.SetupMultiPlaceContextMenu()
	ui.Window:SetHidden( true )

	EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.OnAutoHideMultiPlaceContextMenu" )
end

function EHT.UI.ShowMultiPlaceContextMenu( options, anchorPoint, anchorControl, anchorControlPoint, anchorOffsetX, anchorOffsetY )
	local ui = EHT.UI.SetupMultiPlaceContextMenu()

	ui.Data.AutoHideTS = nil
	ui.Data.AnchorControl = anchorControl
	ui.Data.Options = options

	local thirdParty = string.lower( ui.Data.Player ) ~= displayNameLower

	if not thirdParty then
		local size = EssentialHousingHub:EstimateCommunityFXRecordSize()
		ui.FXSize:SetText( ( not size or 0 == size ) and "No FX published" or string.format( "Published |cffff33%d|rk / |cffff33700|rk FX data", ( size / 1000 ) + 1 ) )
	else
		ui.FXSize:SetText( "Third-party Sharing" )
	end

	ui.PublishButton.Enabled = not thirdParty
	if thirdParty then
		ui.PublishButton:SetDesaturation( 1 )
		ui.PublishButton:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 0.5 )
		ui.PublishButton.Label:SetText( "Publish to Community" )
	else
		ui.PublishButton:SetDesaturation( 0 )
		ui.PublishButton:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 1 )

		local house = EHT.Data.GetHouseById( houseId )
		if "table" ~= type( house ) or "table" ~= type( house.Effects ) then
			ui.PublishButton.Label:SetText( "Publish to Community" )
		else
			ui.PublishButton.Label:SetText( string.format( "Publish to Community (|cffff33%d|rk)", ( #EHT.Util.Serialize( house.Effects ) / 1000 ) + 1 ) )
		end
	end

	ui.UnpublishButton.Enabled = false
	if not thirdParty then
		ui.UnpublishButton.Enabled = nil ~= EssentialHousingHub:GetCommunityHouseFXRecord( GetDisplayName(), EHT.Util.GetWorldCode(), ui.Data.HouseId )
	end

	if not ui.UnpublishButton.Enabled then
		ui.UnpublishButton:SetDesaturation( 1 )
		ui.UnpublishButton:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 0.5 )
	else
		ui.UnpublishButton:SetDesaturation( 0 )
		ui.UnpublishButton:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, 1 )
	end

	ui.Window:ClearAnchors()
	ui.Window:SetAnchor( anchorPoint, anchorControl, anchorControlPoint, anchorOffsetX or 0, anchorOffsetY or 0 )
	ui.Window:SetHidden( false )

	EVENT_MANAGER:RegisterForUpdate( "EHT.UI.OnAutoHideMultiPlaceContextMenu", 100, EHT.UI.OnAutoHideMultiPlaceContextMenu )

	return true
end

function EHT.UI.SetupMultiPlaceContextMenu()
	local ui = EHT.UI.MultiPlaceContextMenu

	if nil == ui then
		ui = { Data = { } }
		EHT.UI.MultiPlaceContextMenu = ui

		local prefix = "MultiPlaceContextMenu"
		local height, width = 206, 240
		local baseDrawLevel = 1000

		-- Window Controls

		local b, btn, c, win

		local function tip( control, msg )
			EHT.UI.SetInfoTooltip( control, msg )
		end

		win = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
		ui.Window = win
		win:SetDimensionConstraints( width, height, width, height )
		win:SetHidden( true )
		win:SetAlpha( 1 )
		win:SetMovable( false )
		win:SetMouseEnabled( true )
		win:SetClampedToScreen( false )
		win:SetResizeHandleSize( 0 )
		win:SetDrawTier( DT_HIGH )
		win:SetDrawLayer( DL_TEXT )

		c = EHT.CreateControl( nil, win, CT_TEXTURE )
		ui.BackdropShadow = c
		c:SetAnchor( TOPLEFT, win, TOPLEFT, 0, 0 )
		c:SetAnchor( BOTTOMRIGHT, win, BOTTOMRIGHT, 0, 0 )
		c:SetBlendMode( TEX_BLEND_MODE_ALPHA )
		c:SetDrawLevel( baseDrawLevel - 2 )
		c:SetTexture( EHT.Textures.SOLID )
		c:SetVertexColors( 2 + 8, 0, 0.3, 0.4, 1 )
		c:SetVertexColors( 1 + 4, 0.1, 0.1, 0.1, 1 )

		c = EHT.CreateControl( nil, win, CT_TEXTURE )
		ui.Backdrop = c
		c:SetAnchor( TOPLEFT, win, TOPLEFT, 2, 2 )
		c:SetAnchor( BOTTOMRIGHT, win, BOTTOMRIGHT, -2, -2 )
		c:SetBlendMode( TEX_BLEND_MODE_ALPHA )
		c:SetDrawLevel( baseDrawLevel - 1 )
		c:SetTexture( EHT.Textures.SOLID )
		c:SetVertexColors( 1 + 4, 0, 0.3, 0.4, 1 )
		c:SetVertexColors( 2 + 8, 0.1, 0.1, 0.1, 1 )

		b = EHT.CreateControl( prefix .. "Body", win, CT_CONTROL )
		ui.Body = b
		b:SetAnchor( TOPLEFT, win, TOPLEFT, 10, 14 )
		b:SetAnchor( BOTTOMRIGHT, win, BOTTOMRIGHT, -10, -14 )
		b:SetDrawLevel( baseDrawLevel )

		-- Item Type

		c = EHT.CreateControl( nil, b, CT_LABEL )
		ui.ItemTypeLabel = c
		c:SetAnchor( TOP, b, TOP, 0, 0 )
		c:SetDrawLevel( baseDrawLevel )
		c:SetFont( "$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thin" )
		c:SetMouseEnabled( false )
		c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		c:SetText( "Place all" )

		c = EHT.UI.Picklist:New( prefix .. "ItemTypeList", b, TOPLEFT, ui.ItemTypeLabel, BOTTOMLEFT, 0, 0, 10 )
		ui.ItemTypeList = c
		c:SetSorted( true )
		tip( c:GetControl(), "Choose the category or subcategory of items to place." )
	end

	return ui
end

function EHT.UI.ShowBook( title, body, medium )
	LORE_READER:Show( title, body, medium or 1, true )
	PlaySound( "Book_Open" )
end

function EHT.UI.HideBook()
	SCENE_MANAGER:Hide( "loreReaderInteraction" )
	PlaySound( "Book_Close" )
end

function EHT.UI.IsBookHidden()
	return LORE_READER.title:IsHidden()
end

function EHT.UI.OnGuestbookInterval()
	if EHT.UI.IsBookHidden() then
		EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.OnGuestbookInterval" )

		for index = 1, 5 do
			KEYBIND_STRIP:RemoveKeybindButton( EHT.GUESTBOOK_KEYBIND_BUTTONS.SIGN )
			KEYBIND_STRIP:RemoveKeybindButton( EHT.GUESTBOOK_KEYBIND_BUTTONS.DISMISS )
			KEYBIND_STRIP:RemoveKeybindButton( EHT.GUESTBOOK_KEYBIND_BUTTONS.RESET )
		end

		return
	end
end

do
	local houseGuests

	local function GuestComparer( left, right )
		return left.visitDate > right.visitDate
	end

	function EHT.UI.GetViewedGuestCount()
		return EHT.SavedVars.ViewedGuestCount or 0
	end
	
	function EHT.UI.HasUnviewedGuests( guests )
		guests = guests or EHT.UI.GetAllHouseGuests()
		local currentGuestCount = EHT.UI.GetViewedGuestCount()
		local newGuestCount = guests and #guests or 0
		return 0 ~= newGuestCount and newGuestCount ~= currentGuestCount
	end

	function EHT.UI.ResetViewedGuestCount()
		EHT.SavedVars.ViewedGuestCount = nil
	end

	function EHT.UI.UpdateViewedGuestCount()
		local guests = EHT.UI.GetAllHouseGuests()
		EHT.SavedVars.ViewedGuestCount = guests and #guests or 0
	end

	function EHT.UI.GetAllHouseGuests()
		if not houseGuests then
			houseGuests = { }
			local owner = displayNameLower
			local openHouses = EssentialHousingHub:GetOpenHouses()

			if openHouses then
				for houseId, house in pairs( openHouses ) do
					if house.houseId then
						local signatures = EssentialHousingHub:GetCommunityGuestbookRecord( owner, houseId )
						if signatures then
							for _, signature in pairs( signatures ) do
								local guestName, guestVisitDate = signature[1], tonumber( signature[2] )
								if guestName and guestVisitDate then
									local guest =
									{
										houseId = house.houseId,
										houseName = EHT.Housing.GetHouseName( house.houseId ),
										name = guestName,
										visitDate = guestVisitDate,
									}
									table.insert( houseGuests, guest )
								end
							end
						end
					end
				end

				table.sort( houseGuests, GuestComparer )
			end
		end

		return houseGuests
	end
end

do
	local addedKeybinds = false

	function EHT.UI.ShowGuestbook( forceOpen, owner, houseId )
		if not forceOpen and not EHT.Effect:CanShowGuestbook() then
			return false
		end

		if not EHT.UI.IsBookHidden() then
			-- Avoid refreshing unnecessarily.
			return false
		end

		if not houseId then
			owner, houseId = EHT.Housing.GetHouseOwner()
		end

		local signatures = EssentialHousingHub:GetGuestbook(owner, houseId)

		if "table" ~= type( signatures ) then
			return false
		end

		local signatureList = { }
		local groupDate, signatureDate, ts
		local line, dateLine, indent = 0, 0, 0
		local localPlayerSignature = string.format("(%s)", displayNameLower)

		for index, signature in ipairs( signatures ) do
			if "table" == type( signature ) and 2 <= #signature then
				ts = tonumber( signature[2] )

				if ts then
					signatureDate = FormatAchievementLinkTimestamp( signature[2] )

					if not groupDate or groupDate ~= signatureDate then
						groupDate = signatureDate
						line = line + 1 indent = string.rep( " ", 3 - round( 3 * math.sin( 0.1 * ( line % 15 ) * math.pi ) ) )
						dateLine = dateLine + 1

						if 0 ~= dateLine % 3 then
							table.insert( signatureList, "" )
						end
						table.insert( signatureList, "" )
						table.insert( signatureList, indent .. groupDate )
					end

					line = line + 1 indent = string.rep( " ", round( 5 * math.sin( 0.1 * ( line % 15 ) * math.pi ) ) )

					local signatureString = signature[1]
					if PlainStringFind(string.lower(signatureString), localPlayerSignature) then
						signatureString = string.format("|c0011bb%s|c000000", signatureString)
					end

					table.insert(signatureList, indent .. signatureString)
				end
			end
		end

		if 0 == #signatureList then
			table.insert( signatureList, "\n\n|c003090The journal is empty\n ...though you could change that.|r" )
		end

		if not EssentialHousingHub:IsOpenHouse( houseId, owner ) then
			return false
		end

		local title = EssentialHousingHub:GetOpenHouseName( houseId, owner ) or ""
		local preface = string.format( "\n\n%s wishes you a pleasant visit and politely asks that first-time guests sign in...\n", owner )

		EHT.UI.ShowBook( "|c000000" .. title, "|c000000" .. preface .. table.concat( signatureList, "\n" ) )

		if not KEYBIND_STRIP:HasKeybindButton( EHT.GUESTBOOK_KEYBIND_BUTTONS.SIGN ) then
			KEYBIND_STRIP:AddKeybindButton( EHT.GUESTBOOK_KEYBIND_BUTTONS.SIGN )
		end

		if not KEYBIND_STRIP:HasKeybindButton( EHT.GUESTBOOK_KEYBIND_BUTTONS.DISMISS ) then
			KEYBIND_STRIP:AddKeybindButton( EHT.GUESTBOOK_KEYBIND_BUTTONS.DISMISS )
		end

		if EHT.Housing.IsOwner() then
			if not KEYBIND_STRIP:HasKeybindButton( EHT.GUESTBOOK_KEYBIND_BUTTONS.RESET ) then
				KEYBIND_STRIP:AddKeybindButton( EHT.GUESTBOOK_KEYBIND_BUTTONS.RESET )
			end
		end

		EVENT_MANAGER:RegisterForUpdate( "EHT.UI.OnGuestbookInterval", 200, EHT.UI.OnGuestbookInterval )

		return true
	end
end

function EHT.UI.SignGuestbook()
	local signatures = EssentialHousingHub:GetGuestbook()

	if "table" ~= type( signatures ) then
		return false
	end

	local hasSigned = false
	local myself = string.lower( EssentialHousingHub:GetCurrentSignerName() )

	for index, signature in ipairs( signatures ) do
		if "string" == type( signature[1] ) and myself == string.lower( signature[1] ) then
			hasSigned = true
			break
		end
	end

	if EssentialHousingHub:SignCommunityGuestbook() then
		EHT.UI.DismissGuestbook( true )
		EssentialHousingHub:OnGuestJournalSigned()

		if hasSigned then
			EHT.UI.ShowAlertDialog( "",
				"You erase your old signature and sign at the end of the list." ..
				"\n\n|c00ffff" ..
				"Please note that your signature will only be visible to others once you |cffff00/reloadui|c00ffff or relog." )
		else
			EHT.UI.ShowAlertDialog( "",
				"Your signature has been recorded." ..
				"\n\n|c00ffff" ..
				"Please note that your signature will only be visible to others once you |cffff00/reloadui|c00ffff or relog." )
		end
	end

	return true
end

function EHT.UI.ResetGuestbook( confirmed )
	if not EHT.Housing.IsOwner() then
		EHT.UI.ShowAlertDialog( "", "This is not your home.\n\n" ..
			"It would be rude to tear all of the pages out of someone else's Guest Journal." )
		return false
	end

	local signatures = EssentialHousingHub:GetGuestbook()

	if "table" ~= type( signatures ) or 0 >= #signatures then
		EHT.UI.ShowAlertDialog( "", "The guest journal already appears to be empty." )
		return false
	end

	if true ~= confirmed then
		zo_callLater( function()
			EHT.UI.ShowConfirmationDialog( "",
				"|cff0000YOU CANNOT UNDO A GUEST JOURNAL RESET.\n\n" ..
				"|cffffffReset your Guest Journal and reload the UI?|r",
				function() zo_callLater( function() EHT.UI.ResetGuestbook( true ) end, 500 ) end )
		end, 500 )
		return false
	end

	local result, message = EssentialHousingHub:SetCommunityResetGuestbookRecord()
	if result then
		if EHCommunity_DoubleReloadUI then EHCommunity_DoubleReloadUI() else ReloadUI() end
		return true
	end

	EHT.UI.ShowAlert( "", string.format( "Request failed:\n%s", message or "Unknown exception." ) )
	return false
end

function EHT.UI.DismissGuestbook( suppressDialogs )
	if not EHT.UI.IsBookHidden() then
		EHT.Effect:DismissGuestbook()
		EHT.UI.HideBook()

		if true ~= suppressDialogs then
			if EHT.Housing.IsOwner() and not EHT.GetSetting("HideMyGuestJournals") then
				EHT.UI.ShowConfirmationDialog(
					"",
					"The guest journal has been dismissed.\n\n" ..
					"|cffff00Would you like to hide your homes' Guest Journals on future visits?|r\n\n" ..
					"|c00ffffPlease note that you may summon the Guest Journal with the EHT button's\n" ..
					"|cffff00Guest Journal > Summon|c00ffff option at any time.",
					function()
						EHT.SavedVars.HideMyGuestJournals = true
					end
				)
			elseif not EHT.Housing.IsOwner() and not EHT.GetSetting("HideSignedGuestJournals") then
				EHT.UI.ShowConfirmationDialog(
					"",
					"The guest journal has been dismissed.\n\n" ..
					"|cffff00Would you like to hide your other players' Guest Journals that you have already signed?|r\n\n" ..
					"|c00ffffPlease note that you may summon the Guest Journal with the EHT button's\n" ..
					"|cffff00Guest Journal > Summon|c00ffff option at any time.",
					function()
						EHT.SavedVars.HideSignedGuestJournals = true
					end
				)
			end
		end
	end
end

---[ Folium Discognitum ]---

function EHT.UI.OnLoreBookInterval()
	if EHT.UI.IsBookHidden() then
		if not EHT.UI.IsLorebookSelectionDialogHidden() then
			EHT.UI.EnterUIMode()
		end

		EHT.Effect:SetCanShowFoliumDiscognitum( false )
		EHT.Effect:SetCanShowLoreBook( false )

		zo_callLater( function()
			EHT.Effect:SetCanShowFoliumDiscognitum( true )
			EHT.Effect:SetCanShowLoreBook( true )
		end, 200 )

		EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.OnLoreBookInterval" )
	end
end

do
	function EHT.UI.IsLorebookSelectionDialogHidden()
		local ui = EHT.UI.LorebookSelectionDialog
		return not ui or ui.Window:IsHidden()
	end

	function EHT.UI.SetupLorebookSelectionDialog( categoryId, categoryLabel )
		local ui = EHT.UI.LorebookSelectionDialog

		if ui then
			ui.CategoryId = categoryId
		else
			ui = { }
			EHT.UI.LorebookSelectionDialog = ui
			ui.CategoryId = categoryId

			local prefix = "EHTLorebookSelectionDialog"
			local c, w

			w = CreateWindow( prefix, CreateAnchor( CENTER, GuiRoot, CENTER ), nil, 400, 200, false, false, true )
			ui.Window = w
			w:SetHidden( true )
			w:SetAlpha( 0.9 )
			w:SetMouseEnabled( false )
			w:SetResizeHandleSize( 0 )
			w:SetDrawTier( DT_LOW )
			w:SetDrawLayer( DL_BACKGROUND )

			ui.Outline, ui.Backdrop = CreateWindowBackdrop( prefix .. "Outline", prefix .. "Backdrop", w, 10, 10 )

			c = CreateLabel( prefix .. "Category", w, "", CreateAnchor( TOP, w, TOP, 0, 15 ), nil, nil, nil, TEXT_ALIGN_CENTER )
			ui.CategoryLabel = c
			SetLabelFont( c, 22, false, true )
			c:SetColor( 0.1, 1, 1, 1 )

			c = CreateLabel( prefix .. "Directions", w, "Choose a collection and book...", CreateAnchor( TOP, ui.CategoryLabel, BOTTOM, 0, 15 ) )
			ui.DirectionsLabel = c

			c = EHT.UI.Picklist:New( prefix .. "Collection", w, TOP, ui.DirectionsLabel, BOTTOM, 0, 10, 380 )
			ui.Collection = c
			c:SetSorted( true )

			c = EHT.UI.Picklist:New( prefix .. "Book", w, TOP, ui.Collection:GetControl(), BOTTOM, 0, 10, 380 )
			ui.Book = c
			c:SetSorted( true )

			c = CreateTexture( prefix .. "CloseButton", w, CreateAnchor( BOTTOM, w, BOTTOM, 0, 0 ), nil, 100, 30 )
			ui.CloseButton = c
			c:SetColor( 0, 0.3, 0.4, 1 )
			c:SetMouseEnabled( true )
			c:SetHandler( "OnMouseUp", function( control )
				ui.Window:SetAlpha( 0 )
				zo_callLater( function() if ui.Window:GetAlpha() == 0 then ui.Window:SetHidden( true ) end end, 500 )
			end )

			c = CreateButtonLabel( prefix .. "CloseButtonLabel", w, "Close", CreateAnchor( CENTER, ui.CloseButton, CENTER, 0, 0 ) )
			ui.CloseButtonLabel = c

			local function OnCheckLorebookSelectionDialog()
				local success = false
				local maxDistance = 10
				local x, y, z = GetPlayerWorldPositionInHouse()

				if x or y or z then
					local dx, dy, dz = x - ( ui.PlayerX or 0 ), y - ( ui.PlayerY or 0 ), z - ( ui.PlayerZ or 0 )

					if maxDistance >= math.abs( dx ) and maxDistance >= math.abs( dy ) and maxDistance >= math.abs( dz ) then
						success = true
					end
				end

				if not success then
					ui.Window:SetHidden( true )
					EVENT_MANAGER:UnregisterForUpdate( "EHT.OnCheckLorebookSelectionDialog" )
				end
			end

			ui.Window:SetHandler( "OnShow", function( control )
				local category = ui.CategoryId
				if not category then return end

				ui.Book:ClearItems()
				ui.Book:Refresh()
				ui.Collection:ClearItems()

				for collection = 1, 300 do
					local text = GetLoreCollectionInfo( category, collection )

					if "" ~= ( text or "" ) then
						ui.Collection:AddItem( text, nil, collection )
					else
						break
					end
				end

				ui.Collection:Refresh()
				EHT.UI.HideInteractionPrompt()

				ui.PlayerX, ui.PlayerY, ui.PlayerZ = GetPlayerWorldPositionInHouse()
				ui.Window:SetAlpha( 1 )
				EHT.UI.EnterUIMode()

				EVENT_MANAGER:RegisterForUpdate( "EHT.OnCheckLorebookSelectionDialog", 100, OnCheckLorebookSelectionDialog )
			end )

			ui.Collection:AddHandler( "OnSelectionChanged", function( control, item )
				local category = ui.CategoryId
				if not category or not item then return end

				local collection = tonumber( item.Value )
				if not collection then return end

				ui.CollectionId = collection
				ui.Book:ClearItems()

				for book = 1, 300 do
					local text = GetLoreBookInfo( category, collection, book )

					if "" ~= ( text or "" ) then
						ui.Book:AddItem( text, nil, book )
					else
						break
					end
				end

				ui.Book:Refresh()
			end )

			ui.Book:AddHandler( "OnSelectionChanged", function( control, item )
				local category, collection = ui.CategoryId, ui.CollectionId
				if not category or not collection or not item then return end

				local book = tonumber( item.Value )
				if not book then return end

				if EHT.UI.ShowSpecificBook( category, collection, book ) then
					--ui.Window:SetHidden( true )
				end
			end )
		end

		ui.CategoryLabel:SetText( categoryLabel )

		return ui
	end

	function EHT.UI.ShowSpecificBook( category, collection, book )
		local body, medium, showTitle = ReadLoreBook( category, collection, book )
		local title, result

		if "" == ( body or "" ) then
			body = "You have never seen this volume before -- or perhaps you simply cannot recall?\n\nShalidor may be able to provide you with answers..."
			result = false
		elseif showTitle then
			title = GetLoreBookInfo( category, collection, book )
			result = true
		end

		EHT.UI.ShowBook( title and ( "|c000000" .. title ) or "", "|c000000\n" .. body )
		EHT.Effect:SetCanShowFoliumDiscognitum( false )
		EHT.Effect:SetCanShowLoreBook( false )
		EVENT_MANAGER:RegisterForUpdate( "EHT.UI.OnLoreBookInterval", 100, EHT.UI.OnLoreBookInterval )

		return result
	end

	function EHT.UI.ShowFoliumDiscognitum( title, category )
		category = tonumber( category )

		local ui = EHT.UI.SetupLorebookSelectionDialog( category, title )
		ui.Window:SetHidden( false )

		return true
	end
end

---[ Interaction Prompt ]---

function EHT.UI.RegisterInteractionKeybinds()
	KEYBIND_STRIP:RemoveKeybindButtonGroup( EHT.GUESTBOOK_KEYBIND_BUTTONS.SHOW )
	KEYBIND_STRIP:AddKeybindButtonGroup( EHT.GUESTBOOK_KEYBIND_BUTTONS.SHOW )
	InsertNamedActionLayerAbove( "Essential Housing Tools (Interaction)", GetString( SI_KEYBINDINGS_LAYER_GENERAL ) )
end

function EHT.UI.UnregisterInteractionKeybinds()
	RemoveActionLayerByName( "Essential Housing Tools (Interaction)" )
	KEYBIND_STRIP:RemoveKeybindButtonGroup( EHT.GUESTBOOK_KEYBIND_BUTTONS.SHOW )
end

function EHT.UI.ShowInteractionPrompt( keybind, label, callback, rightAlign )
	local ui = EHT.UI.InteractionPromptDialog

	if not ui then
		ui = { }
		EHT.UI.InteractionPromptDialog = ui

		local prefix = "EHTInteractionPrompt"

		local win = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
		ui.Window = win
		win:SetDimensionConstraints( 200, 60, 200, 60 )
		win:SetHidden( true )
		win:SetAlpha( 0.9 )
		win:SetMovable( false )
		win:SetMouseEnabled( false )
		win:SetClampedToScreen( true )
		win:SetResizeHandleSize( 0 )
		win:SetDrawTier( DT_HIGH )
		win:SetDrawLayer( DL_TEXT )
		win:SetAnchor( TOPRIGHT, GuiRoot, CENTER, -60, 0 )

		local btn = WINDOW_MANAGER:CreateControlFromVirtual( prefix .. "KeybindButton", win, "ZO_KeybindButton" )
		ui.Button = btn
		btn:SetAnchorFill()
		btn:SetupStyle( KEYBIND_STRIP_STANDARD_STYLE )
		btn:SetNormalTextColor( ZO_NORMAL_TEXT )
		btn.nameLabel:SetHorizontalAlignment( TEXT_ALIGN_RIGHT )
	end

	ui.Window:SetHidden( true )
	ui.Button:SetText( label )

	if keybind then
		ui.Button:SetKeybind( keybind )
		ui.Button:SetCallback( callback )
		ui.Button:ShowKeyIcon( true )
		ui.Button:SetEnabled( true )
		ui.Button:SetKeybindEnabled( true )

		EHT.UI.RegisterInteractionKeybinds()
	else
		ui.Button:SetKeybind( nil )
		ui.Button:ShowKeyIcon( false )
		ui.Button:SetEnabled( false )
		ui.Button:SetKeybindEnabled( false )
		ui.Button:SetCallback( nil )

		EHT.UI.UnregisterInteractionKeybinds()
	end

	if not IsUIHidden then
		ui.Window:SetHidden( false )
		hiddenDialogs["INTERACTION_PROMPT"] = false
	else
		hiddenDialogs["INTERACTION_PROMPT"] = true
	end
end

function EHT.UI.HideInteractionPrompt()
	local ui = EHT.UI.InteractionPromptDialog
	if ui then
		hiddenDialogs["INTERACTION_PROMPT"] = false
		ui.Window:SetHidden( true )
		ui.Button:SetEnabled( false )
	end
	EHT.UI.UnregisterInteractionKeybinds()
end

function EHT.UI.IsInteractionPromptHidden()
	local ui = EHT.UI.InteractionPromptDialog
	return not ui or ui.Window:IsHidden()
end

function EHT.UI.GetInteractionPromptLabel()
	local ui = EHT.UI.InteractionPromptDialog
	if not ui or not ui.Button or not ui.Button.nameLabel or ui.Window:IsHidden() then return "" end
	return ui.Button.nameLabel:GetText() or ""
end

---[ Community App Dialog ]---

function EHT.UI.HideCommunityAppDialog()
	local ui = EHT.UI.CommunityAppDialog

	if ui then
		ui.Window:SetHidden( true )
	end
end

function EHT.UI.ShowCommunityAppDialog()
	local ui = EHT.UI.CommunityAppDialog

	if nil == ui then
		ui = { }
		EHT.UI.CommunityAppDialog = ui

		local prefix = "CommunityAppDialog"
		local height, width = 566, 600
		local baseDrawLevel = 1000
		local b, btn, c, win

		local function tip( control, msg )
			EHT.UI.SetInfoTooltip( control, msg )
		end

		win = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
		ui.Window = win
		win:SetDimensionConstraints( width, height, width, height )
		win:SetHidden( true )
		win:SetAlpha( 0.85 )
		win:SetMovable( true )
		win:SetMouseEnabled( true )
		win:SetClampedToScreen( true )
		win:SetResizeHandleSize( 0 )
		win:SetDrawTier( DT_HIGH )
		win:SetDrawLayer( DL_TEXT )
		win:SetAnchor( CENTER, GuiRoot, CENTER, 0, 0 )

		c = EHT.CreateControl( nil, win, CT_TEXTURE )
		ui.BackdropShadow = c
		c:SetAnchor( TOPLEFT, win, TOPLEFT, 0, 0 )
		c:SetAnchor( BOTTOMRIGHT, win, BOTTOMRIGHT, 0, 0 )
		c:SetBlendMode( TEX_BLEND_MODE_ALPHA )
		c:SetDrawLevel( baseDrawLevel - 2 )
		c:SetTexture( EHT.Textures.SOLID )
		c:SetVertexColors( 2 + 8, 0, 0.3, 0.4, 1 )
		c:SetVertexColors( 1 + 4, 0.1, 0.1, 0.1, 1 )

		c = EHT.CreateControl( nil, win, CT_TEXTURE )
		ui.Backdrop = c
		c:SetAnchor( TOPLEFT, win, TOPLEFT, 2, 2 )
		c:SetAnchor( BOTTOMRIGHT, win, BOTTOMRIGHT, -2, -2 )
		c:SetBlendMode( TEX_BLEND_MODE_ALPHA )
		c:SetDrawLevel( baseDrawLevel - 1 )
		c:SetTexture( EHT.Textures.SOLID )
		c:SetVertexColors( 1 + 4, 0, 0.3, 0.4, 1 )
		c:SetVertexColors( 2 + 8, 0.1, 0.1, 0.1, 1 )

		b = EHT.CreateControl( prefix .. "Body", win, CT_CONTROL )
		ui.Body = b
		b:SetAnchor( LEFT, win, LEFT, 15, 0 )
		b:SetAnchor( RIGHT, win, RIGHT, -15, 0 )
		b:SetDrawLevel( baseDrawLevel )
		b:SetResizeToFitDescendents( true )

		c = EHT.CreateControl( nil, b, CT_LABEL )
		ui.Title = c
		c:SetAnchor( TOPLEFT, b, TOPLEFT, 0, 0 )
		c:SetAnchor( TOPRIGHT, b, TOPRIGHT, 0, 0 )
		c:SetDrawLevel( baseDrawLevel )
		c:SetFont( "$(BOLD_FONT)|$(KB_36)|soft-shadow-thick" )
		c:SetMouseEnabled( false )
		c:SetText( "Join Our Community" )
		c:SetColor( 0.5, 1, 1, 1 )
		c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )

		c = EHT.CreateControl( nil, b, CT_LABEL )
		ui.Prologue = c
		c:SetAnchor( TOP, ui.Title, BOTTOM, 0, 15 )
		c:SetDrawLevel( baseDrawLevel )
		c:SetFont( "$(MEDIUM_FONT)|$(KB_20)|soft-shadow-thick" )
		c:SetMouseEnabled( false )
		c:SetText( "|cffffffThe following |cffff00free|cffffff features are available to all Community members:" )
		c:SetMaxLineCount( 2 )
		c:SetColor( 1, 1, 1, 1 )
		c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		c:SetWidth( width - 10 )

		c = EHT.CreateControl( nil, b, CT_LABEL )
		ui.Features = c
		c:SetAnchor( TOPLEFT, ui.Prologue, BOTTOMLEFT, 54, 15 )
		c:SetAnchor( TOPRIGHT, ui.Prologue, BOTTOMRIGHT, -28, 15 )
		c:SetDrawLevel( baseDrawLevel )
		c:SetFont( "$(MEDIUM_FONT)|$(KB_20)|soft-shadow-thick" )
		c:SetMouseEnabled( false )
		c:SetMaxLineCount( 12 )
		c:SetText( "" ..
			"Publicly invite all Community members to visit by hosting an Open House at any or all of your homes.\n\n" ..
			"Allow your guests to sign in and see who stopped by with the Guest Journal that is automatically included in each of your Open Houses.\n\n" ..
			"Easily publish all of your home's visual FX** to all Community players (even when they are offline) and without the need to share via chat, email or guild." )
		c:SetColor( 1, 1, 0.4, 1 )

		c = EHT.CreateControl( nil, b, CT_LABEL )
		ui.Addendum = c
		c:SetAnchor( TOP, ui.Features, BOTTOM, 0, 4 )
		c:SetDrawLevel( baseDrawLevel )
		c:SetFont( "$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thick" )
		c:SetMouseEnabled( false )
		c:SetText( "** Maximum storage capacity allows for approximately 3,000 FX" )
		c:SetColor( 1, 1, 1, 1 )

		c = EHT.CreateControl( nil, b, CT_LABEL )
		ui.Epilogue = c
		c:SetAnchor( TOP, ui.Features, BOTTOM, -12, 40 )
		c:SetDrawLevel( baseDrawLevel )
		c:SetFont( "$(MEDIUM_FONT)|$(KB_20)|soft-shadow-thick" )
		c:SetMouseEnabled( false )
		c:SetText( "" ..
			"|cffffffSelect your platform below for a " ..
			"|cffff00simple, 1-minute Setup Guide|cffffff " ..
			"and join our growing Community of builders, designers and creators..." )
		c:SetColor( 1, 1, 1, 1 )
		c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		c:SetMaxLineCount( 4 )
		c:SetWidth( width - 40 )

		c = EHT.CreateControl( nil, b, CT_TEXTURE )
		btn = c
		ui.WindowsButton = c
		c:SetAnchor( TOP, ui.Epilogue, BOTTOM, -170, 25 )
		c:SetDimensions( 150, 50 )
		c:SetDrawLevel( baseDrawLevel )
		c:SetTexture( EHT.Textures.SOLID )
		c:SetColor( 0, 0.7, 0.7, 1 )
		c:SetMouseEnabled( true )
		c:SetHandler( "OnMouseEnter", OnFormButtonMouseEnter )
		c:SetHandler( "OnMouseExit", OnFormButtonMouseExit )
		c:SetHandler( "OnMouseUp", function()
			EHT.UI.HideCommunityAppDialog()
			EHT.UI.ShowConfirmationDialog( "", "" ..
				"|cffffffInstallation on |c00ffffWindows|cffffff takes less than 60 seconds " ..
				"and requires NO additional download - the app is already included in " ..
				"Essential Housing Tools...\n\n" ..
				"A one-time installation is all that is needed to get started.\n\n" .. 
				"|cffff00Watch the " .. zo_iconFormat( EHT.Textures.ICON_YOUTUBE, 24, 24 ) .. "|cffff00 " ..
				"Installation Guide video now?",
				function()
					EHT.UI.ShowURL( EHT.CONST.URLS.SetupCommunityPC )
				end )
		end )

		c = EHT.CreateControl( nil, btn, CT_LABEL )
		btn.Label = c
		c:SetAnchor( CENTER, btn, CENTER, 0, 0 )
		c:SetDrawLevel( baseDrawLevel )
		c:SetFont( "$(BOLD_FONT)|$(KB_22)|soft-shadow-thick" )
		c:SetMouseEnabled( false )
		c:SetText( "Windows" )
		c:SetColor( 1, 1, 1, 1 )

		OnFormButtonMouseExit( btn )

		c = EHT.CreateControl( nil, b, CT_TEXTURE )
		btn = c
		ui.MacButton = c
		c:SetAnchor( TOP, ui.Epilogue, BOTTOM, 0, 25 )
		c:SetDimensions( 150, 50 )
		c:SetDrawLevel( baseDrawLevel )
		c:SetTexture( EHT.Textures.SOLID )
		c:SetColor( 0, 0.7, 0.7, 1 )
		c:SetMouseEnabled( true )
		c:SetHandler( "OnMouseEnter", OnFormButtonMouseEnter )
		c:SetHandler( "OnMouseExit", OnFormButtonMouseExit )
		c:SetHandler( "OnMouseUp", function()
			local guideVideo = function()
				EHT.UI.ShowConfirmationDialog( "", "" ..
					"|cffff00Would you like to watch the Community for Mac setup guide video?",
					function()
						EHT.UI.ShowURL( EHT.CONST.URLS.SetupCommunityMac )
					end )
			end

			EHT.UI.HideCommunityAppDialog()
			EHT.UI.ShowConfirmationDialog( "", "" ..
				"|cffffffInstallation on |c00ffffMac|cffffff is easy - just download the " ..
				"Essential Housing Community for Mac app package, right-click the package and " ..
				"choose \"Open\".\n\n" ..
				"The package installer guides you through the setup process in seconds.\n\n" ..
				"|cffff00Would you like to download the |c00ffffMac|cffff00 app now?",
				function() 
					EHT.UI.ShowURL( EHT.CONST.URLS.DownloadCommunityMac )
					guideVideo()
				end,
				function()
					guideVideo()
				end )
		end )

		c = EHT.CreateControl( nil, btn, CT_LABEL )
		btn.Label = c
		c:SetAnchor( CENTER, btn, CENTER, 0, 0 )
		c:SetDrawLevel( baseDrawLevel )
		c:SetFont( "$(BOLD_FONT)|$(KB_22)|soft-shadow-thick" )
		c:SetMouseEnabled( false )
		c:SetText( "Mac" )
		c:SetColor( 1, 1, 1, 1 )

		OnFormButtonMouseExit( btn )

		c = EHT.CreateControl( nil, b, CT_TEXTURE )
		btn = c
		ui.CancelButton = c
		c:SetAnchor( TOP, ui.Epilogue, BOTTOM, 170, 27 )
		c:SetDimensions( 135, 46 )
		c:SetDrawLevel( baseDrawLevel )
		c:SetTexture( EHT.Textures.SOLID )
		c:SetColor( 0, 0.6, 0.6, 1 )
		c:SetMouseEnabled( true )
		c:SetHandler( "OnMouseEnter", OnFormButtonMouseEnter )
		c:SetHandler( "OnMouseExit", OnFormButtonMouseExit )
		c:SetHandler( "OnMouseUp", function()
			EHT.UI.HideCommunityAppDialog()
		end )

		c = EHT.CreateControl( nil, btn, CT_LABEL )
		btn.Label = c
		c:SetAnchor( CENTER, btn, CENTER, 0, 0 )
		c:SetDrawLevel( baseDrawLevel )
		c:SetFont( "$(BOLD_FONT)|$(KB_22)|soft-shadow-thick" )
		c:SetMouseEnabled( false )
		c:SetText( "Maybe Later" )
		c:SetColor( 0.85, 0.85, 0.85, 1 )

		OnFormButtonMouseExit( btn )
	end

	EHT.UI.HideHousingHub()
	ui.Window:SetHidden( false )
	EHT.UI.EnterUIMode(250)

	return ui
end

---[ Checkbox Control ]---

do

	EHT.UI.Checkbox = ZO_Object:Subclass()

	local base = EHT.UI.Checkbox

	local behaviors = { }
	base.EventBehaviors = behaviors
	behaviors.HardwareOnly = 1
	behaviors.AlwaysRaise = 2
	behaviors = nil

	local states = { }
	base.States = states
	states.Indeterminate = 0
	states.Unchecked = 1
	states.Checked = 2
	states = nil

	base.CreateTooltip = EHT.UI.SetInfoTooltip
	base.WasHardwareEventRaised = false


	function EHT.UI.Checkbox:New( ... )

		local obj = ZO_Object.New( self )
		local control = obj:Initialize( ... )
		return control

	end


	function EHT.UI.Checkbox:Initialize( name, parent, anchorFrom, anchor, anchorTo, anchorOffsetX, anchorOffsetY, width, height )

		if not self then
			error( string.format( "Failed to create Checkbox: Initialization instance is nil." ) )
			return nil
		end

		if self.Initialized then
			error( string.format( "Failed to create Checkbox: Instance is already initialized." ) )
			return nil
		end

		if not parent then
			error( string.format( "Failed to create Checkbox: Parent is required." ) )
			return nil
		end

		local c

		self.Enabled = true
		self.EventBehavior = base.EventBehaviors.HardwareOnly
		self.Name = name
		self.Parent = parent
		self.Width = width or 200
		self.Height = height or 28
		self.State = base.States.Unchecked

		c = EHT.CreateControl( name, parent, CT_CONTROL )
		self.Control = c
		c:SetDimensions( self.Width, self.Height )
		c:SetMouseEnabled( true )
		c:SetHandler( "OnMouseDown", function( ... )
			base.WasHardwareEventRaised = true
			self:Toggle()
			base.WasHardwareEventRaised = false
		end )

		c = CreateTexture( nil, self.Control )
		self.Control.Box = c
		c:SetTexture( EHT.Textures.ICON_UNCHECKED )
		c:SetBlendMode( TEX_BLEND_MODE_ALPHA )
		SetColor( c, Colors.Box )
		c:SetDimensions( 16, 16 )
		c:SetAnchor( LEFT, self.Control, LEFT, 0, 0 )

		c = EHT.CreateControl( nil, self.Control, CT_LABEL )
		self.Control.Label = c
		SetColor( c, Colors.Label )
		c:SetFont( Colors.LabelFont )
		c:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
		c:SetText( "" )
		c:SetVerticalAlignment( TEXT_ALIGN_CENTER )
		c:SetAnchor( LEFT, self.Control.Box, RIGHT, 4, 0 )
		c:SetAnchor( RIGHT, self.Control, RIGHT, 0, 0 )

		self:SetAnchor( anchorFrom, anchor, anchorTo, anchorOffsetX, anchorOffsetY )
		self.Initialized = true

		return self

	end


	function EHT.UI.Checkbox:RefreshEnabled()

		self.Control:SetMouseEnabled( self.Enabled )
		SetColor( self.Control.Box, Colors.Box, ( not self.Enabled ) and Colors.FilterDisabled )
		SetColor( self.Control.Label, Colors.Label, ( not self.Enabled ) and Colors.FilterDisabled )

	end


	function EHT.UI.Checkbox:SetEnabled( value )

		self.Enabled = true == value
		self:RefreshEnabled()

	end


	function EHT.UI.Checkbox:GetEventBehavior( value )

		return self.EventBehavior

	end


	function EHT.UI.Checkbox:SetEventBehavior( value )

		if EHT.Util.IsListValue( base.EventBehaviors, value ) then
			self.EventBehavior = value
		end

	end


	function EHT.UI.Checkbox:GetName()
	
		return self.Name

	end


	function EHT.UI.Checkbox:GetParent()

		return self.Parent

	end


	function EHT.UI.Checkbox:GetControl()

		return self.Control

	end


	function EHT.UI.Checkbox:GetDrawLevel()

		return self.Control:GetDrawLevel()

	end


	function EHT.UI.Checkbox:SetDrawLevel( value )

		self.Control:SetDrawLevel( value )

	end


	function EHT.UI.Checkbox:GetText()

		return self.Control.Label:GetText()

	end


	function EHT.UI.Checkbox:SetText( value )

		self.Control.Label:SetText( value )

	end


	function EHT.UI.Checkbox:GetWidth()

		return self.Control:GetWidth()

	end


	function EHT.UI.Checkbox:SetWidth( value )

		self.Width = zo_clamp( tonumber( value ) or 200, 40, 2000 )
		self.Control:SetWidth( self.Width )
		return self.Width

	end


	function EHT.UI.Checkbox:GetHeight()

		return self.Control:GetHeight()

	end


	function EHT.UI.Checkbox:SetHeight( value )

		self.Height = zo_clamp( tonumber( value ) or 28, 28, 2000 )
		self.Control:SetHeight( self.Height )
		return self.Height

	end


	function EHT.UI.Checkbox:GetDimensions()

		return self.Control:GetDimensions()

	end


	function EHT.UI.Checkbox:SetDimensions( width, height )

		self.Control:SetDimensions( width, height )

	end


	function EHT.UI.Checkbox:GetCenter()

		return self.Control:GetCenter()

	end


	function EHT.UI.Checkbox:GetScreenRect()

		return self.Control:GetScreenRect()

	end


	function EHT.UI.Checkbox:GetHandlers( event )

		if not event then
			return nil
		end

		event = string.lower( event )

		if not self.Handlers then
			self.Handlers = { }
		end

		local handlers = self.Handlers[event]

		if handlers then
			handlers = { }
			self.Handlers[event] = { }
		end

		return handlers

	end


	function EHT.UI.Checkbox:AddHandler( event, handler )

		local handlers = self:GetHandlers( event )

		if handlers then
			handlers[handler] = true
			return handler
		end

		return nil

	end


	function EHT.UI.Checkbox:RemoveHandler( event, handler )

		local handlers = self:GetHandlers( event )

		if handlers and handlers[handler] then
			handlers[handler] = nil
			return handler
		end

		return nil

	end


	function EHT.UI.Checkbox:CallHandlers( event, ... )

		local handlers = self:GetHandlers( event )

		if handlers then
			for handler in pairs( handlers ) do
				handler( self, ... )
			end
		end

	end


	function EHT.UI.Checkbox:IsHidden()

		return self.Control:IsHidden()

	end


	function EHT.UI.Checkbox:SetHidden( value )

		self.Control:SetHidden( value )

	end


	function EHT.UI.Checkbox:ClearAnchors()

		self.Control:ClearAnchors()
		self:OnResized()

	end


	function EHT.UI.Checkbox:SetAnchor( anchorFrom, anchor, anchorTo, anchorOffsetX, anchorOffsetY )

		if anchorFrom or anchor or anchorTo then
			self.Control:SetAnchor( anchorFrom, anchor, anchorTo, anchorOffsetX, anchorOffsetY )
		end

	end


	function EHT.UI.Checkbox:IsIndeterminate()

		return self.State == base.States.Indeterminate

	end


	function EHT.UI.Checkbox:IsUnchecked()

		return self.State == base.States.Unchecked

	end


	function EHT.UI.Checkbox:IsChecked()

		return self.State == base.States.Checked

	end


	function EHT.UI.Checkbox:SetState( state )

		if EHT.Util.IsListValue( base.States, state ) then
			self.State = state

			if base.WasHardwareEventRaised or self:GetEventBehavior() ~= base.EventBehaviors.HardwareOnly then
				self:OnChanged()
			end

			self:Refresh()
		end

	end


	function EHT.UI.Checkbox:Toggle()

		if self.State == base.States.Checked then
			self:SetState( base.States.Unchecked )
		else
			self:SetState( base.States.Checked )
		end

	end


	function EHT.UI.Checkbox:SetChecked( value )

		self:SetState( value and base.States.Checked or base.States.Unchecked )

	end


	function EHT.UI.Checkbox:Refresh()

		if self.State == base.States.Checked then
			self.Control.Box:SetTexture( EHT.Textures.ICON_CHECKED )
		elseif self.State == base.States.Unchecked then
			self.Control.Box:SetTexture( EHT.Textures.ICON_UNCHECKED )
		else
			self.Control.Box:SetTexture( EHT.Textures.ICON_INDETERMINATE )
		end

	end


	do

		local isChanging = false

		function EHT.UI.Checkbox:OnChanged()

			if isChanging then
				return
			end

			isChanging = true
			self:CallHandlers( "OnChanged", self.State )
			isChanging = false

		end

	end

end

---[ New Installation Dialog ]---

function EHT.UI.HideNewInstallationDialog()
	local ui = EHT.UI.NewInstallationDialog

	if ui then
		ui.Window:SetHidden( true )
	end
end

function EHT.UI.ShowNewInstallationDialog()
	local ui = EHT.UI.NewInstallationDialog

	if nil == ui then
		ui = { }
		EHT.UI.NewInstallationDialog = ui

		local prefix = "NewInstallationDialog"
		local height, width = 315, 600
		local baseDrawLevel = 1000
		local b, btn, c, win

		local function tip( control, msg )
			EHT.UI.SetInfoTooltip( control, msg )
		end

		win = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
		ui.Window = win
		win:SetDimensionConstraints( width, height, width, height )
		win:SetHidden( true )
		win:SetAlpha( 0.85 )
		win:SetMovable( true )
		win:SetMouseEnabled( true )
		win:SetClampedToScreen( true )
		win:SetResizeHandleSize( 0 )
		win:SetDrawTier( DT_HIGH )
		win:SetDrawLayer( DL_TEXT )
		win:SetAnchor( CENTER, GuiRoot, CENTER, 0, 0 )

		ui.WindowOutline, ui.Backdrop = CreateWindowBackdrop( nil, prefix .. "Backdrop", win, 30, 6 )

		b = EHT.CreateControl( nil, win, CT_CONTROL )
		ui.Body = b
		b:SetAnchor( TOPLEFT, win, TOPLEFT, 20, 20 )
		b:SetAnchor( BOTTOMRIGHT, win, BOTTOMRIGHT, -20, -15 )
		b:SetDrawLevel( baseDrawLevel )
		b:SetResizeToFitDescendents( true )

		c = CreateLabel( nil, b, "Essential Housing Tools", CreateAnchor( TOPLEFT, b, TOPLEFT, 0, 15 ), CreateAnchor( TOPRIGHT, b, TOPRIGHT, 0, 15 ), nil, nil, TEXT_ALIGN_CENTER )
		ui.Title = c
		SetLabelFont( c, 28, true, false )
		SetColor( c, Colors.LabelHeading )

		c = CreateLabel( nil, b, "|cffffff" ..
			"Hi! You seem to have a new installation of Essential Housing Tools. That's great! :) Just to confirm though...",
			CreateAnchor( TOPLEFT, ui.Title, BOTTOMLEFT, 0, 20 ), CreateAnchor( TOPRIGHT, ui.Title, BOTTOMRIGHT, 0, 20 ) )
		ui.Instructions = c
		SetLabelFont( c, 20, true, false )

		c = CreateLabel( nil, b,
			"|caaffffDid you recently install Essential Housing Tools?\n "..
			"|cffffffor\n" ..
			"|caaffffHave you recently changed your @player name?",
			CreateAnchor( TOPLEFT, ui.Instructions, BOTTOMLEFT, 0, 20 ), CreateAnchor( TOPRIGHT, ui.Instructions, BOTTOMRIGHT, 0, 20 ),
			nil, nil, TEXT_ALIGN_CENTER )
		ui.Questions = c
		SetLabelFont( c, 20, true, false )

		c = CreateTexture( nil, b, CreateAnchor( BOTTOMRIGHT, b, BOTTOM, -10, 0 ), nil, 250, 30 )
		c:SetTexture( EHT.Textures.SOLID )
		btn = c
		ui.CancelButton = c
		c:SetMouseEnabled( true )
		c:SetHandler( "OnMouseEnter", OnFormButtonMouseEnter )
		c:SetHandler( "OnMouseExit", OnFormButtonMouseExit )
		c:SetHandler( "OnMouseUp", function()
			EHT.UI.HideNewInstallationDialog()
			EHT.UI.ShowAlertDialog( "", "|cffffff" ..
				"Welcome!\n\n" ..
				"If you need help at any time, there are tutorials as well as tons of " ..
				"walkthrough videos available.\n\n" ..
				"To access these video guides, just place your cursor over the |caaffffEHT" ..
				"|cffffff button and click |cffffaaTutorials|cffffff.",
				function() EHT.UI.DeclinedTransferDataDialog( true ) end )
		end )

		c = CreateButtonLabel( nil, btn, "I recently installed the add-on", CreateAnchor( LEFT, btn, LEFT, 0, 0 ), CreateAnchor( RIGHT, btn, RIGHT, 0, 0 ), nil, nil, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		btn.Label = c
		c:SetMouseEnabled( false )

		OnFormButtonMouseExit( btn )

		c = CreateTexture( nil, b, CreateAnchor( BOTTOMLEFT, b, BOTTOM, 10, 0 ), nil, 250, 30 )
		c:SetTexture( EHT.Textures.SOLID )
		btn = c
		ui.TransferButton = c
		c:SetMouseEnabled( true )
		c:SetHandler( "OnMouseEnter", OnFormButtonMouseEnter )
		c:SetHandler( "OnMouseExit", OnFormButtonMouseExit )
		c:SetHandler( "OnMouseUp", function()
			EHT.UI.HideNewInstallationDialog()
			EHT.UI.ShowAlertDialog( "", "|cffffff" ..
				"If you have recently changed your @player name, any of your saved data " ..
				"will need to be transferred from your old @player name to this new one.\n\n" ..
				"You will just need to know your previous @player name.\n\n" ..
				"Click |caaffffOK|cffffff to get started.",
				EHT.UI.ShowTransferDataDialog,
				EHT.UI.DeclinedTransferDataDialog )
		end )

		c = CreateButtonLabel( nil, btn, "My @player name changed...", CreateAnchor( LEFT, btn, LEFT, 0, 0 ), CreateAnchor( RIGHT, btn, RIGHT, 0, 0 ), nil, nil, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		btn.Label = c
		c:SetMouseEnabled( false )

		OnFormButtonMouseExit( btn )
	end

	ui.Window:SetHidden( false )

	return ui
end

---[ Transfer Data Dialog ]---

function EHT.UI.DeclinedTransferDataDialog( suggested )
	local message = "To transfer data from an old @Player name\n" ..
		"at any time open\n" ..
		"|cffff00Settings || Addons || Essential Housing Tools|r\n" ..
		"and click \"|cffff00My @Name Changed|r\" near\n" ..
		"the bottom of the settings panel."
	if true == suggested then
		message = "|c00ffffBut just in case you did need to...|r\n\n" .. message
	end

	EHT.UI.HideTransferDataDialog()
	EHT.UI.ShowAlertDialog( "", message, function()
		if true ~= suggested then
			EHT.UI.DisplayNotification( message )
		end
	end )
end

function EHT.UI.HideTransferDataDialog()
	local ui = EHT.UI.TransferDataDialog

	if ui then
		ui.Window:SetHidden( true )
	end
end

function EHT.UI.ShowTransferDataDialog()
	local ui = EHT.UI.TransferDataDialog

	if nil == ui then
		ui = { }
		EHT.UI.TransferDataDialog = ui

		local prefix = "TransferDataDialog"
		local height, width = 400, 520
		local baseDrawLevel = 1000
		local b, btn, c, win

		local function tip( control, msg )
			EHT.UI.SetInfoTooltip( control, msg )
		end

		win = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
		ui.Window = win
		win:SetDimensionConstraints( width, height, width, height )
		win:SetHidden( true )
		win:SetAlpha( 0.85 )
		win:SetMovable( true )
		win:SetMouseEnabled( true )
		win:SetClampedToScreen( true )
		win:SetResizeHandleSize( 0 )
		win:SetDrawTier( DT_HIGH )
		win:SetDrawLayer( DL_TEXT )
		win:SetAnchor( CENTER, GuiRoot, CENTER, 0, 0 )

		ui.WindowOutline, ui.Backdrop = CreateWindowBackdrop( nil, prefix .. "Backdrop", win, 30, 6 )

		b = EHT.CreateControl( nil, win, CT_CONTROL )
		ui.Body = b
		b:SetAnchor( TOPLEFT, win, TOPLEFT, 20, 20 )
		b:SetAnchor( BOTTOMRIGHT, win, BOTTOMRIGHT, -20, -15 )
		b:SetDrawLevel( baseDrawLevel )
		b:SetResizeToFitDescendents( true )

		c = CreateLabel( nil, b, "Essential Housing Tools", CreateAnchor( TOPLEFT, b, TOPLEFT, 0, 10 ), CreateAnchor( TOPRIGHT, b, TOPRIGHT, 0, 10 ), nil, nil, TEXT_ALIGN_CENTER )
		ui.Caption = c
		SetLabelFont( c, 18, true, false )

		c = CreateLabel( nil, b, "Transfer Saved Data", CreateAnchor( TOPLEFT, ui.Caption, BOTTOMLEFT, 0, 100 ), CreateAnchor( TOPRIGHT, ui.Caption, BOTTOMRIGHT, 0, 10 ), nil, nil, TEXT_ALIGN_CENTER )
		ui.Title = c
		SetLabelFont( c, 28, true, false )
		SetColor( c, Colors.LabelHeading )

		c = CreateLabel( nil, ui.Title,
			"If you have recently changed your @player name, you will need to transfer your " ..
			"saved data, including backups, builds, FX, history, scenes, selections and triggers.",
			CreateAnchor( TOPLEFT, ui.Title, BOTTOMLEFT, 0, 15 ), CreateAnchor( TOPRIGHT, ui.Title, BOTTOMRIGHT, 0, 15 ) )
		ui.Instructions = c
		SetLabelFont( c, 18, true, false )

		c = CreateLabel( nil, ui.Instructions,
			"|cff9900TRANSFERRING DATA FROM ANOTHER @PLAYER NAME WILL OVERWRITE THIS PLAYER'S EXISTING DATA|r",
			CreateAnchor( TOPLEFT, ui.Instructions, BOTTOMLEFT, 0, 15 ), CreateAnchor( TOPRIGHT, ui.Instructions, BOTTOMRIGHT, 0, 15 ), nil, nil, TEXT_ALIGN_CENTER )
		ui.Warning = c
		SetLabelFont( c, 20, true, false )

		c = CreateLabel( nil, b, "Enter your previous @player name:", CreateAnchor( TOP, ui.Warning, BOTTOM, 0, 15 ), nil, nil, nil, TEXT_ALIGN_CENTER )
		ui.PlayerNameLabel = c
		SetLabelFont( c, 18, true, false )

		c = CreateEditBox( nil, b, CreateAnchor( TOP, ui.PlayerNameLabel, BOTTOM, 0, 4 ) )
		ui.PlayerName = c

		c = CreateTexture( nil, b, CreateAnchor( BOTTOMRIGHT, b, BOTTOM, -40, 0 ), nil, 80, 30 )
		c:SetTexture( EHT.Textures.SOLID )
		btn = c
		ui.CancelButton = c
		c:SetMouseEnabled( true )
		c:SetHandler( "OnMouseEnter", OnFormButtonMouseEnter )
		c:SetHandler( "OnMouseExit", OnFormButtonMouseExit )
		c:SetHandler( "OnMouseUp", EHT.UI.DeclinedTransferDataDialog )

		c = CreateButtonLabel( nil, btn, "Cancel", CreateAnchor( LEFT, btn, LEFT, 0, 0 ), CreateAnchor( RIGHT, btn, RIGHT, 0, 0 ), nil, nil, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		btn.Label = c
		c:SetMouseEnabled( false )

		OnFormButtonMouseExit( btn )

		c = CreateTexture( nil, b, CreateAnchor( BOTTOMLEFT, b, BOTTOM, 0, 0 ), nil, 120, 30 )
		c:SetTexture( EHT.Textures.SOLID )
		btn = c
		ui.TransferButton = c
		c:SetMouseEnabled( true )
		c:SetHandler( "OnMouseEnter", OnFormButtonMouseEnter )
		c:SetHandler( "OnMouseExit", OnFormButtonMouseExit )
		c:SetHandler( "OnMouseUp", function()
			local playerName = EHT.Util.Trim( ui.PlayerName:GetText() )

			if not playerName or "" == playerName or "@" ~= string.sub( playerName, 1, 1 ) then
				EHT.UI.HideTransferDataDialog()
				EHT.UI.ShowAlertDialog(
					"", "Please enter your previous @player name.",
					function()
						EHT.UI.ShowTransferDataDialog()
					end )
				return
			end

			EHT.UI.InitiateTransferData( playerName )
		end )

		c = CreateButtonLabel( nil, btn, "Transfer Data", CreateAnchor( LEFT, btn, LEFT, 0, 0 ), CreateAnchor( RIGHT, btn, RIGHT, 0, 0 ), nil, nil, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		btn.Label = c
		c:SetMouseEnabled( false )

		OnFormButtonMouseExit( btn )
	end

	ui.Window:SetHidden( false )

	return ui
end

function EHT.UI.InitiateTransferData( playerName )
	EHT.UI.HideTransferDataDialog()

	if string.lower( playerName ) == string.lower( EHT.Util.Trim( GetDisplayName() ) ) then
		EHT.UI.ShowAlertDialog(
			"", "You may only transfer data from a different @player account - ideally this would be your previous @player name.",
			function()
				EHT.UI.ShowTransferDataDialog()
			end )
		return
	end

	local data = ZO_SavedVars:NewAccountWide( EHT.SAVED_VARS_FILE, EHT.SAVED_VARS_VERSION, nil, nil, nil, playerName )

	if "table" ~= type( data ) or not data.Houses then
		EHT.UI.ShowAlertDialog(
			"", string.format( "No saved data was found for @player account \"%s\".", playerName ),
			function()
				EHT.UI.ShowTransferDataDialog()
			end )
		return
	end

	local buildCount, houseCount, groupCount, sceneCount, triggerCount = 0, 0, 0, 0, 0
	local builds = data.Builds
	local houses = data.Houses

	if "table" == type( builds ) then
		for name, build in pairs( builds ) do
			buildCount = buildCount + 1
		end
	end

	if "table" == type( houses ) then
		for houseId, house in pairs( houses ) do
			if tonumber( houseId ) then
				houseCount = houseCount + 1

				if "table" == type( house.Groups ) then
					for name, group in pairs( house.Groups ) do
						groupCount = groupCount + 1
					end
				end

				if "table" == type( house.Scenes ) then
					for name, scene in pairs( house.Scenes ) do
						sceneCount = sceneCount + 1
					end
				end

				if "table" == type( house.Triggers ) then
					for name, trigger in pairs( house.Triggers ) do
						triggerCount = triggerCount + 1
					end
				end
			end
		end
	end

	EHT.UI.ShowConfirmationDialog( "", string.format(
		"The account \"%s\" contains data for %d home(s), including:\n\n" ..
		"%-5d Saved Selection(s)\n" ..
		"%-5d Scenes(s)\n" ..
		"%-5d Triggers(s)\n" ..
		"%-5d Build(s)\n\n" ..
		"|cff9900Do you want to OVERWRITE your saved data with these records?|r",
		playerName, houseCount, groupCount, sceneCount, triggerCount, buildCount ),
		function()
			EHT.UI.ConfirmTransferData( playerName, data )
		end,
		function()
			EHT.UI.ShowAlertDialog(
				"", "Transfer has been cancelled.",
				function()
					EHT.UI.ShowTransferDataDialog()
				end )
		end )
end

function EHT.UI.ConfirmTransferData( playerName, data )
	EHT.SavedVars.Houses = EHT.Util.CloneTable( data.Houses )
	EHT.SavedVars.Builds = EHT.Util.CloneTable( data.Builds )
	EHT.SavedVars.DataTransferredFrom = playerName

	EHT.UI.ShowConfirmationDialog( "",
		"Data transfer is complete.\n\n" ..
		"You must reload the user interface in order to safely access the transferred data.\n\n" ..
		"Would you like to reload now?",
		ReloadUI )
end

---[ Size Comparison ]---

do
	local prefix = "EHTPreviewScale"
	EHT.PreviewScale = ZO_Object.New( ZO_Object:Subclass() )

	function EHT.PreviewScale:Reset()
		local win = self.Window

		if win then
			win:Destroy3DRenderSpace()
			win:Create3DRenderSpace()
		end

		local cs = self.Controls

		if "table" == type( cs ) then
			for _, c in pairs( cs ) do
				c:Destroy3DRenderSpace()
				c:Create3DRenderSpace()
			end
		end
	end

	function EHT.PreviewScale:Initialize()
		local cs = self.Controls
		if not cs then
			cs = { }
			self.Controls = cs
			self.Enabled = nil
			self.IsHidden = nil

			local w = CreateWindow( prefix, CreateAnchor( CENTER, GuiRoot, CENTER, 0, 0 ), nil, 1, 1, true, false, false )
			self.Window = w
			w:SetDrawLayer( DL_BACKGROUND )
			w:SetDrawTier( DT_LOW )
			w:Create3DRenderSpace()
			w:SetHidden( true )

			c = Create3DTexture( nil, w, EHT.Textures.FENCE, { width = 777, height = 793, depthBuffer = true, wrap = false, } )
			c:SetDrawLevel( 0 )
			cs.Fence = c
			c.OffsetX, c.OffsetY, c.OffsetZ = -600, 400, -28

			c = Create3DTexture( nil, w, EHT.Textures.BOOKSHELVES_3, { width = 225, height = 370, depthBuffer = true, wrap = false, } )
			c:SetDrawLevel( 1 )
			cs.Bookshelves = c
			c.OffsetX, c.OffsetY, c.OffsetZ = -200, 185, 0

			c = Create3DTexture( nil, w, EHT.Textures.TYTHIS, { width = 82, height = 224, depthBuffer = true, wrap = false, } )
			c:SetDrawLevel( 2 )
			cs.Tythis = c
			c.OffsetX, c.OffsetY, c.OffsetZ = -40, 115, 0

			c = Create3DTexture( nil, w, EHT.Textures.RULER_HORIZ, { width = 8000, height = 40, a = 0.75, cx1 = 80.5, cx2 = 0.5, cy1 = 0, cy2 = 1, depthBuffer = false, wrap = true } )
			c:SetDrawLevel( 3 )
			cs.Horizontal = c
			c.OffsetX, c.OffsetY, c.OffsetZ = 0, 20, 10

			c = Create3DTexture( nil, w, EHT.Textures.RULER_VERT, { width = 40, height = 8000, a = 0.75, cx1 = 1, cx2 = 0, cy1 = 0.1, cy2 = 80, depthBuffer = false, wrap = true } )
			c:SetDrawLevel( 4 )
			cs.Vertical = c
			c.OffsetX, c.OffsetY, c.OffsetZ = 60, 4000, 10

			c = Create3DTexture( nil, w, EHT.Textures.UNITS_1, { width = 100, height = 60, cx1 = 0, cx2 = 1, cy1 = 0, cy2 = 0.5, depthBuffer = false, wrap = false, } )
			c:SetDrawLevel( 5 )
			cs.Units = c
			c.OffsetX, c.OffsetY, c.OffsetZ = -50, -40, 10
		end
	end

	function EHT.PreviewScale:SetHidden( hidden, reason )
		if self.Controls and hidden ~= self.IsHidden then
			self.IsHidden = hidden
			self.Window:SetHidden( hidden )
			for _, c in pairs( self.Controls ) do
				c:SetHidden( hidden )
			end
		end
	end
	
	function EHT.PreviewScale:RegisterOnUpdate()
		EVENT_MANAGER:UnregisterForUpdate( "EHT.PreviewScale:OnUpdate" )
		EVENT_MANAGER:RegisterForUpdate( "EHT.PreviewScale:OnUpdate", 200, function() EHT.PreviewScale:OnUpdate() end )
		self:SetFurnitureBrowserAlpha( 0 )
		self:SetHidden( false )
	end

	function EHT.PreviewScale:UnregisterOnUpdate()
		EVENT_MANAGER:UnregisterForUpdate( "EHT.PreviewScale:OnUpdate" )
		self:SetFurnitureBrowserAlpha( 1 )
		self:SetHidden( true )
	end

	function EHT.PreviewScale:OnUpdate()
		if not GetPreviewModeEnabled() then
			self:SetHidden( true, "Preview mode disabled" )
			self:UnregisterOnUpdate()
			return
		end

		if not IsCurrentlyPreviewing() then
			self:SetHidden( true, "No collection shown" )
			return
		end

		local cs = self.Controls
		local yaw = GetPlayerCameraHeading()
		local px, py, pz

		if EHT.Housing.IsHouseZone() then
			px, py, pz = GetPlayerWorldPositionInHouse()
		else
			local h
			h, px, py, pz = EHT.GetPlayerPosition( "player" )
		end
		py = py + 100000

		local cx, cy, cz = EHT.World:GetCameraPosition()
		local localOffsetX, localOffsetY, localOffsetZ = EHT.World.RotateAxisY( math.abs( px - cx ), math.abs( py - cy ), math.abs( pz - cz ), yaw % RAD180 )
		local distance = zo_distance3D( 0, 0, 0, localOffsetX, 0, localOffsetZ )
		local frustumWidth = GetWorldDimensionsOfViewFrustumAtDepth( distance )
		local offset = math.min( -80, -0.25 * frustumWidth )
		local lengthCoeff = 2000 > distance and 1 or 0.5
		local cint = EHT.World:GetLoopInterval( 6000 )
		local cr, cg, cb = 0.6 + 0.4 * cint, 1 - 0.4 * cint, 1
		local ox, oy, oz

		do
			local c

			c = cs.Horizontal
			c:SetTextureCoords( lengthCoeff * c.cx1, c.cx2, c.cy1, c.cy2 )

			c = cs.Vertical
			c:SetTextureCoords( c.cx1, c.cx2, c.cy1, lengthCoeff * c.cy2 )

			c = cs.Units
			if 1 > lengthCoeff then
				c:SetTextureCoords( 0, 1, 0.5, 1 )
			else
				c:SetTextureCoords( 0, 1, 0, 0.5 )
			end
		end

		local c = cs.Tythis
		ox, oy, oz = EHT.World.Rotate( c.OffsetX + offset, c.OffsetY, c.OffsetZ, 0, yaw, 0 )
		c:Set3DRenderSpaceOrigin( EHT.World:Get3DPosition( px + ox, py + oy, pz + oz ) )

		c = cs.Bookshelves
		ox, oy, oz = EHT.World.Rotate( c.OffsetX + offset, c.OffsetY, c.OffsetZ, 0, yaw, 0 )
		c:Set3DRenderSpaceOrigin( EHT.World:Get3DPosition( px + ox, py + oy, pz + oz ) )

		c = cs.Fence
		ox, oy, oz = EHT.World.Rotate( c.OffsetX + offset, c.OffsetY, c.OffsetZ, 0, yaw, 0 )
		c:Set3DRenderSpaceOrigin( EHT.World:Get3DPosition( px + ox, py + oy, pz + oz ) )

		c = cs.Horizontal
		ox, oy, oz = EHT.World.Rotate( c.OffsetX, c.OffsetY, c.OffsetZ, 0, yaw, 0 )
		c:Set3DRenderSpaceOrigin( EHT.World:Get3DPosition( px + ox, py + oy, pz + oz ) )
		c:SetColor( cr, cg, cb, 0.75 )

		c = cs.Vertical
		ox, oy, oz = EHT.World.Rotate( c.OffsetX + offset, c.OffsetY, c.OffsetZ, 0, yaw, 0 )
		c:Set3DRenderSpaceOrigin( EHT.World:Get3DPosition( px + ox, py + oy, pz + oz ) )
		c:SetColor( cr, cg, cb, 0.75 )

		c = cs.Units
		ox, oy, oz = EHT.World.Rotate( ( 1 / lengthCoeff ) * c.OffsetX, ( 1 / lengthCoeff ) * c.OffsetY, c.OffsetZ, 0, yaw, 0 )
		c:Set3DRenderSpaceOrigin( EHT.World:Get3DPosition( px + ox, py + oy, pz + oz ) )
		c:Set3DLocalDimensions( ( 1 / lengthCoeff ) * 1, ( 1 / lengthCoeff ) * 0.6 )

		for _, c in pairs( self.Controls ) do
			c:Set3DRenderSpaceOrientation( 0, yaw, 0 )
		end

		self:SetHidden( false )
	end

	function EHT.PreviewScale:IsEnabled()
		return true == self.Enabled
	end

	function EHT.PreviewScale:SetEnabled( enabled )
		if enabled ~= self.Enabled then
			self.Enabled = enabled
			if enabled then
				EHT.Effect:CheckEffectsRelatedSettings()
				self:Initialize()
				self:RegisterOnUpdate()
			else
				self:UnregisterOnUpdate()
			end
		end
	end

	function EHT.PreviewScale:ToggleEnabled()
		self:SetEnabled( not self:IsEnabled() )
	end

	function EHT.PreviewScale:SetFurnitureBrowserAlpha( alpha )
		if TITLE_FRAGMENT and TITLE_FRAGMENT.control then TITLE_FRAGMENT.control:SetAlpha( alpha ) end
		if RIGHT_BG_FRAGMENT and RIGHT_BG_FRAGMENT.control then RIGHT_BG_FRAGMENT.control:SetAlpha( alpha ) end
		if TREE_UNDERLAY_FRAGMENT and TREE_UNDERLAY_FRAGMENT.control then TREE_UNDERLAY_FRAGMENT.control:SetAlpha( alpha ) end
	end
end

---[ Progress Indicator ]---

function EHT.UI.ShowProgressIndicatorDialog( caption )
	local ui = EHT.UI.ProgressIndicatorDialog

	if nil == ui then
		ui = { }
		EHT.UI.ProgressIndicatorDialog = ui

		local prefix = "ProgressIndicatorDialog"
		local height, width = 50, 360
		local baseDrawLevel = 1000
		local b, btn, c, win

		local function tip( control, msg )
			EHT.UI.SetInfoTooltip( control, msg )
		end

		win = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
		ui.Window = win
		win:SetDimensionConstraints( width, height, width, height )
		win:SetHidden( true )
		win:SetAlpha( 0.6 )
		win:SetMovable( true )
		win:SetMouseEnabled( true )
		win:SetClampedToScreen( true )
		win:SetResizeHandleSize( 0 )
		win:SetDrawTier( DT_HIGH )
		win:SetDrawLayer( DL_TEXT )
		win:SetDrawLevel( baseDrawLevel ) baseDrawLevel = baseDrawLevel + 1

		local settings = EHT.UI.GetDialogSettings( prefix )

		if settings.Left and settings.Top then
			win:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, settings.Left, settings.Top )
		else
			win:SetAnchor( BOTTOM, GuiRoot, BOTTOM, 0, -150 )
		end

		win:SetHandler( "OnMoveStop", function() EHT.UI.SaveDialogSettings( prefix, win ) end )

		c = CreateLabel( nil, win, "Essential Housing Tools", CreateAnchor( BOTTOMLEFT, win, TOPLEFT, 0, 0 ), CreateAnchor( BOTTOMRIGHT, win, TOPRIGHT, 0, 0 ), nil, nil, TEXT_ALIGN_CENTER )
		ui.Heading = c
		SetLabelFont( c, 14, true, true )
		c:SetInheritAlpha( false )
		c:SetMouseEnabled( false )
		c:SetDrawLevel( baseDrawLevel ) baseDrawLevel = baseDrawLevel + 1

		b = EHT.CreateControl( nil, win, CT_CONTROL )
		ui.Body = b
		b:SetAnchor( LEFT, win, LEFT, 5, 0 )
		b:SetAnchor( RIGHT, win, RIGHT, -5, 0 )
		b:SetDrawLevel( baseDrawLevel ) baseDrawLevel = baseDrawLevel + 1
		b:SetMouseEnabled( false )
		b:SetResizeToFitDescendents( true )

		c = CreateTexture( nil, b, CreateAnchor( LEFT, b, LEFT, 0, 0 ), CreateAnchor( RIGHT, b, RIGHT, 0, 0 ) )
		c:SetTexture( EHT.Textures.SOLID )
		ui.BarBackdrop = c
		c:SetMouseEnabled( false )
		c:SetColor( 0, 0, 0, 1 )
		c:SetDrawLevel( baseDrawLevel ) baseDrawLevel = baseDrawLevel + 1
		c:SetHeight( 40 )

		c = CreateTexture( nil, ui.BarBackdrop, CreateAnchor( LEFT, ui.BarBackdrop, LEFT, 5, 0 ), CreateAnchor( RIGHT, ui.BarBackdrop, RIGHT, -5, 0 ) )
		c:SetTexture( EHT.Textures.SOLID )
		ui.BarProgress = c
		c:SetMouseEnabled( false )
		c:SetColor( 0, 0.6, 0.6, 1 )
		c:SetDrawLevel( baseDrawLevel ) baseDrawLevel = baseDrawLevel + 1
		c:SetHeight( 34 )

		c = CreateLabel( nil, ui.BarBackdrop, "Please wait...", CreateAnchor( LEFT, ui.BarBackdrop, LEFT, 0, 0 ), CreateAnchor( RIGHT, ui.BarBackdrop, RIGHT, 0, 0 ), nil, nil, TEXT_ALIGN_CENTER )
		ui.Caption = c
		SetLabelFont( c, 18, true, false )
		c:SetInheritAlpha( false )
		c:SetMouseEnabled( false )
		c:SetDrawLevel( baseDrawLevel ) baseDrawLevel = baseDrawLevel + 1

		ui.CancelButton = CreateButton( prefix .. "CancelButton", win, "Cancel", CreateAnchor( TOP, ui.Body, BOTTOM, 0, 8 ), 80, 24, EHT.Biz.CancelProcess )
		ui.CancelButton:SetInheritAlpha( false )
	end

	if caption then
		ui.Caption:SetText( caption )
	end

	local separateBar = EHT.GetSetting("ShowSeparateProgressBar")
	if true == EHT.IsUIHidden or false == separateBar then
		ui.Window:SetHidden(true)
	else
		ui.CancelButton:SetHidden(true == EHT.ProcessRollingBack)
		ui.Window:SetHidden(false)
	end

	return ui
end

function EHT.UI.UpdateProgressIndicator( caption, progress )
	progress = zo_clamp( tonumber( progress ) or 0, 0, 1 )

	local ui = EHT.UI.ShowProgressIndicatorDialog()
	local maxWidth = ui.BarBackdrop:GetWidth() - 10
	local width = maxWidth * progress

	if caption then
		ui.Caption:SetText( caption )
	end

	ui.BarProgress:ClearAnchors()
	AddAnchor( ui.BarProgress, CreateAnchor( LEFT, ui.BarBackdrop, LEFT, 5, 0 ) )
	AddAnchor( ui.BarProgress, CreateAnchor( RIGHT, ui.BarBackdrop, LEFT, 5 + width, 0 ) )
end

function EHT.UI.HideProgressIndicatorDialog()
	local ui = EHT.UI.ProgressIndicatorDialog
	if ui then
		ui.Window:SetHidden( true )
	end
end

---[ HUD : Effects Preview Dialog ]---

do
	function EHT.UI.ShowEffectsPreviewDialog()
		EHT.UI.HideToolDialog()
		local menu = EHT.UI.ShowEHTEffectsButtonContextMenu()
		if menu then
			if menu.Window:IsHidden() then
				EHT.UI.ShowEHTEffectsButtonContextMenu()
			end
			menu.ToggleTab( 3 )
			menu.AddEffects:SetColor( 0.4, 0.4, 0.4, 1 )
			menu.PlacedEffects:SetColor( 0.4, 0.4, 0.4, 1 )
		end
	end

	function EHT.UI.HideEffectsPreviewDialog()
		local menu = EHT.UI.EHTEffectsButtonContextMenu
		if menu then
			menu.AddEffects:SetColor( 1, 1, 0.4, 1 )
			menu.PlacedEffects:SetColor( 1, 1, 0.4, 1 )
		end
	end
end

---[ Directional Indicators ]---

do
	local DirectionalIndicators = ZO_Object:Subclass()

	function DirectionalIndicators:New( ... )
		local obj = ZO_Object.New( self )
		obj:Initialize( ... )
		return obj
	end
	
	function DirectionalIndicators:Initialize( ... )
		self.DirectionSystems =
		{
			cardinal = 1,
			camera = 2,
			character = 3,
			relative = 4,
		}

		self.DirectionOrientations =
		{
			forward =
			{
				-RAD90,
				0,
				0,
				indicator = "arrow",
			},
			backward =
			{
				-RAD90,
				RAD180,
				0,
				indicator = "arrow",
			},
			left =
			{
				-RAD90,
				RAD90,
				0,
				indicator = "arrow",
			},
			right =
			{
				-RAD90,
				RAD270,
				0,
				indicator = "arrow",
			},
			up =
			{
				0,
				0,
				0,
				indicator = "arrow",
			},
			down =
			{
				RAD180,
				0,
				0,
				indicator = "arrow",
			},
			["pitch+"] =
			{
				RAD180,
				RAD90,
				0,
				indicator = "rotate",
			},
			["pitch-"] =
			{
				0,
				RAD90,
				0,
				indicator = "rotate",
			},
			["roll+"] =
			{
				RAD180,
				0,
				0,
				indicator = "rotate",
			},
			["roll-"] =
			{
				0,
				0,
				0,
				indicator = "rotate",
			},
			["yaw+"] =
			{
				RAD90,
				RAD180,
				0,
				indicator = "rotate",
			},
			["yaw-"] =
			{
				-RAD90,
				RAD180,
				0,
				indicator = "rotate",
			},
		}

		self.active = false
		self.animationColor = CreateGradient( Colors.Black, Colors.Black, Colors.Black, Colors.Black )
		self.direction = nil
		self.directionOrientation = nil
		self.directionSystem = self.DirectionSystems.cardinal
		self.enabled = true
		self.furnitureId = nil
		self.hidden = true
		self.scale = 2
		self.worldX, self.worldY, self.worldZ = 0, 0, 0

		local window = WINDOW_MANAGER:CreateTopLevelWindow( "EHTDirectionalIndicators" )
		self.window = window
		window:SetHidden( true )
		window:SetAlpha( 0.5 )
		window:SetAnchorFill()
		window:SetMouseEnabled( false )
		window:Create3DRenderSpace()
		window:Set3DRenderSpaceOrigin( 0, 0, 0 )
		window:Set3DRenderSpaceOrientation( 0, 0, 0 )

		self.directionArrows = { }
		self.rotationArrows = { }

		local timeline = ANIMATION_MANAGER:CreateTimeline()
		self.animationTimeline = timeline
		timeline:SetPlaybackType( ANIMATION_PLAYBACK_LOOP )
		timeline:SetPlaybackLoopCount( LOOP_INDEFINITELY )

		local function OnUpdateWindow()
			local CAMERA_DISTANCE = 500
			local camX, camY, camZ = EHT.World:GetCameraPosition()
			local fwdX, fwdY, fwdZ = EHT.World:GetCameraForward()
			local x, y, z = camX + fwdX * CAMERA_DISTANCE, camY + fwdY * CAMERA_DISTANCE, camZ + fwdZ * CAMERA_DISTANCE
			self:SetPosition( x, y, z )

			local interval = 3 * ( ( GetFrameTimeMilliseconds() % 6000 ) / 6000 )
			if interval < 1 then
				LerpColor( self.animationColor, Colors.DirectionalArrow1, Colors.DirectionalArrow2, interval )
			elseif interval < 2 then
				LerpColor( self.animationColor, Colors.DirectionalArrow2, Colors.DirectionalArrow3, interval % 1 )
			else
				LerpColor( self.animationColor, Colors.DirectionalArrow3, Colors.DirectionalArrow1, interval % 1 )
			end
		end

		window:SetHandler( "OnEffectivelyHidden", function()
			EVENT_MANAGER:UnregisterForUpdate( "EHT.DirectionalIndicators.UpdateWindow" )
			timeline:Stop()
		end )
		window:SetHandler( "OnEffectivelyShown", function()
			EVENT_MANAGER:RegisterForUpdate( "EHT.DirectionalIndicators.UpdateWindow", 1, OnUpdateWindow )
			timeline:PlayForward()
		end )

		local function OnUpdateControl( animationControl, progress )
			local control = animationControl:GetAnimatedControl()
			if control.active then
				if control.animateTextureY then
					local offset = control.animateTextureY * ( 1 - ( ( 1 - progress ) ^ 2 ) )
					control:SetTextureCoords( 0, 1, offset, 1 + offset )
				elseif control.animateTextureAngle then
					local offset = -control.animateTextureAngle * ( ( 1 - progress ) ^ 2 )
					EHT.World.RotateTexture( control, offset )
				end

				SetColor( control, self.animationColor )
			else
				SetColor( control, Colors.Transparent )
			end
		end

		for index = 1, 2 do
			local normalizedOffset = ( index - 1 ) / 1
			local offsetPosition = zo_lerp( -0.01, 0.01, normalizedOffset )
			local offsetSampling = zo_lerp( 1, 0, normalizedOffset )

			local arrow = EHT.CreateControl( nil, window, CT_TEXTURE )
			table.insert( self.directionArrows, arrow )
			arrow.offsetPosition = offsetPosition
			arrow.offsetSampling = offsetSampling
			arrow.animateTextureY = 0.2
			arrow:SetMouseEnabled( false )
			arrow:Create3DRenderSpace()
			arrow:Set3DRenderSpaceUsesDepthBuffer( false )
			arrow:Set3DLocalDimensions( 1, 1 )
			arrow:SetTexture( EHT.Textures.ICON_DIRECTION_ARROW )
			arrow:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
			arrow:SetDrawLevel( 210000 - index )

			local animation = timeline:InsertAnimation( ANIMATION_CUSTOM, arrow )
			arrow.animation = animation
			animation:SetDuration( 3000 )
			animation:SetUpdateFunction( OnUpdateControl )

			local arrow = EHT.CreateControl( nil, window, CT_TEXTURE )
			table.insert( self.rotationArrows, arrow )
			arrow.offsetPosition = offsetPosition
			arrow.offsetSampling = offsetSampling
			arrow.animateTextureAngle = math.rad( 90 )
			arrow:SetMouseEnabled( false )
			arrow:Create3DRenderSpace()
			arrow:Set3DRenderSpaceUsesDepthBuffer( false )
			arrow:Set3DLocalDimensions( 1, 1 )
			arrow:SetTexture( EHT.Textures.ICON_ROTATION_ARROW )
			arrow:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
			arrow:SetDrawLevel( 210000 - index )

			local animation = timeline:InsertAnimation( ANIMATION_CUSTOM, arrow )
			arrow.animation = animation
			animation:SetDuration( 3000 )
			animation:SetUpdateFunction( OnUpdateControl )
		end

		self:RefreshSettings()
	end
	
	function DirectionalIndicators:IsHidden()
		return self.hidden
	end

	function DirectionalIndicators:SetHidden( hidden )
		if true == hidden or false == hidden then
			self.hidden = hidden
		end
		self.window:SetHidden( self.hidden or not self.enabled )
	end

	function DirectionalIndicators:SetEnabled( enabled )
		if true == enabled or false == enabled then
			self.enabled = enabled
			self:SetHidden()
		end
	end

	function DirectionalIndicators:SetPosition( worldX, worldY, worldZ )
		self.worldX, self.worldY, self.worldZ = worldX, worldY, worldZ
		local renderX, renderY, renderZ = WorldPositionToGuiRender3DPosition( worldX, worldY, worldZ )
		self.window:Set3DRenderSpaceOrigin( renderX, renderY, renderZ )
	end

	function DirectionalIndicators:SetOrientation( pitch, yaw, roll )
		self.window:Set3DRenderSpaceOrientation( pitch, yaw, roll )
	end

	function DirectionalIndicators:SetPositionAndOrientation( worldX, worldY, worldZ, pitch, yaw, roll )
		self:SetPosition( worldX, worldY, worldZ )
		self:SetOrientation( pitch, yaw, roll )
	end
--[[
	function DirectionalIndicators:SetOrigin( origin )
		if origin then
			local scale = zo_clamp( ( origin.LenX + origin.LenY + origin.LenZ ) / 600, 0.35, 50 )
			EHT.DirectionalIndicators:SetScale( scale )
			EHT.DirectionalIndicators:SetPosition( origin.X, origin.Y, origin.Z )
		end
	end

	function DirectionalIndicators:ClearFurnitureId()
		self.furnitureId = nil
		self:SetDirection( nil )
		self:Update()
	end

	function DirectionalIndicators:SetFurnitureId( furnitureId )
		self.furnitureId = furnitureId
		self:Update()
	end
]]
	function DirectionalIndicators:SetDirection( direction )
		self.direction = string.lower( direction or "" )
		self.directionOrientation = self.DirectionOrientations[self.direction]
		self:Update()
	end

	function DirectionalIndicators:SetDirectionSystem( system )
		self.directionSystem = self.DirectionSystems[string.lower( system or "" )] or self.DirectionSystems.Cardinal
	end

	function DirectionalIndicators:SetScale( scale )
		self.scale = zo_clamp( tonumber( scale ) or 1, 0.1, 100 )
		self:Update()
	end

	function DirectionalIndicators:SetActive( active )
		self.active = active
		self:Update()
	end
	
	function DirectionalIndicators:RefreshSettings()
		local enabled = EHT.GetSetting( "ShowDirectionalArrowsInWorld" )
		self:SetEnabled( enabled )

		local directionSystem = "cardinal"
		if not EHT.Biz.IsCardinalPositionMode() then
			if EHT.Biz.DoesRelativePositionUseUnitHeading() then
				directionSystem = "character"
			else
				directionSystem = "camera"
			end
		end
		self:SetDirectionSystem( directionSystem )
	end

	function DirectionalIndicators:Update()
--[[
		if self.furnitureId then
			worldX, worldY, worldZ, pitch, yaw, roll = EHT.Housing.GetFurniturePositionAndOrientation( self.furnitureId )
		else
			worldX, worldY, worldZ = self.worldX, self.worldY, self.worldZ
			pitch, yaw, roll = 0, 0, 0
		end
]]
		local pitch, yaw, roll = 0, 0, 0
		local directionOrientation = self.directionOrientation
		local directionSystem = self.directionSystem
		if directionSystem == self.DirectionSystems.cardinal or ( directionOrientation and "rotate" == directionOrientation.indicator ) then
			pitch, yaw, roll = 0, 0, 0
		elseif directionSystem == self.DirectionSystems.camera then
			pitch, yaw, roll = 0, GetPlayerCameraHeading(), 0
		elseif directionSystem == self.DirectionSystems.character then
			pitch, roll = 0, 0
			local _, _, _, characterYaw = GetPlayerWorldPositionInHouse()
			yaw = characterYaw
		end

		if directionOrientation then
			--self:SetPositionAndOrientation( worldX, worldY, worldZ, pitch, yaw, roll )
			local fwdX, fwdY, fwdZ = EHT.World:GetCameraForward()
			pitch = pitch - ( 0 < fwdY and 1 or -1 ) * math.rad( 15 - 10 * math.abs( fwdY ) )

			local heading = GetPlayerCameraHeading()
			local offsetYaw = ( heading > yaw and ( heading - yaw ) or ( yaw - heading ) ) % RAD90
			if RAD45 < offsetYaw then
				offsetYaw = ( offsetYaw - RAD45 ) / RAD45
			else
				offsetYaw = -( 1 - ( offsetYaw / RAD45 ) )
			end
			yaw = yaw + offsetYaw * math.rad( 10 )

			self:SetOrientation( pitch, yaw, roll )

			local dirPitch, dirYaw, dirRoll = unpack( directionOrientation )
			if math.huge == dirYaw then
				local cameraX, cameraY, cameraZ = EHT.World:GetCameraPosition()
				dirYaw = math.atan2( cameraX - worldX, cameraZ - worldZ )
			end

			for _, arrow in ipairs( self.directionArrows ) do
				arrow:Set3DRenderSpaceOrientation( dirPitch, dirYaw, dirRoll )
				arrow:Set3DRenderSpaceOrigin( 0, 0, 0 )
				local x0, y0, z0 = arrow:Convert3DWorldPositionToLocalPosition( 0, 0, 0 )
				local x1, y1, z1 = arrow:Convert3DWorldPositionToLocalPosition( arrow.offsetPosition, arrow.offsetPosition, arrow.offsetPosition )
				arrow:Set3DRenderSpaceOrigin( x1 - x0, y1 - y0, z1 - z0 )
			end
			for _, arrow in ipairs( self.rotationArrows ) do
				arrow:Set3DRenderSpaceOrientation( dirPitch, dirYaw, dirRoll )
				arrow:Set3DRenderSpaceOrigin( 0, 0, 0 )
				local x0, y0, z0 = arrow:Convert3DWorldPositionToLocalPosition( 0, 0, 0 )
				local x1, y1, z1 = arrow:Convert3DWorldPositionToLocalPosition( arrow.offsetPosition, arrow.offsetPosition, arrow.offsetPosition )
				arrow:Set3DRenderSpaceOrigin( x1 - x0, y1 - y0, z1 - z0 )
			end
			
			local activeArrows, inactiveArrows
			if "rotate" == directionOrientation.indicator then
				activeArrows, inactiveArrows = self.rotationArrows, self.directionArrows
			else
				activeArrows, inactiveArrows = self.directionArrows, self.rotationArrows
			end

			for _, arrow in ipairs( activeArrows ) do
				arrow.active = true
			end
			for _, arrow in ipairs( inactiveArrows ) do
				arrow.active = false
			end
		else
			for _, arrow in ipairs( self.directionArrows ) do
				arrow:Set3DRenderSpaceOrientation( 0, 0, 0 )
				arrow.active = false
			end
			for _, arrow in ipairs( self.rotationArrows ) do
				arrow:Set3DRenderSpaceOrientation( 0, 0, 0 )
				arrow.active = false
			end
		end

		for _, arrow in ipairs( self.directionArrows ) do
			arrow:Set3DLocalDimensions( self.scale, self.scale )
		end
		for _, arrow in ipairs( self.rotationArrows ) do
			arrow:Set3DLocalDimensions( self.scale, self.scale )
		end

		local sampling = self.active and 2 or 1
		for _, arrow in ipairs( self.directionArrows ) do
			arrow:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, sampling * arrow.offsetSampling )
		end
		for _, arrow in ipairs( self.rotationArrows ) do
			arrow:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, sampling * arrow.offsetSampling )
		end
	end

	local function OnPlayerActivated()
		EVENT_MANAGER:UnregisterForEvent( "EHT.DirectionalIndicators", EVENT_PLAYER_ACTIVATED )
		EHT.DirectionalIndicators = DirectionalIndicators:New()
	end

	EVENT_MANAGER:RegisterForEvent( "EHT.DirectionalIndicators", EVENT_PLAYER_ACTIVATED, OnPlayerActivated )
end

---[ World Rendering ]---

do
	local disabledCount = 0

	function EHT.UI.SetWorldRenderingEnabled( enabled )
		if false ~= enabled then
			disabledCount = math.max( 0, disabledCount - 1 )
		else
			disabledCount = disabledCount + 1
		end

		SetShouldRenderWorld( 0 >= disabledCount )
	end
end

---[ Undo and Redo : Ancillary ]---

function EHT.UI.ChangeTrackingAlert( msg )
	EHT.UI.DisplayNotification( msg )
end


EHT.Modules = ( EHT.Modules or { } ) EHT.Modules.UI = true
