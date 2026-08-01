local _addon = WYK_Outfitter

_addon.GC.Frame = {}
_addon.GC.Frame.Overlay = nil

local _L = nil
local loadListGear = function()
	local ret = false
	if _addon.Settings.GearSetsChanged2 or _L == nil then
		ret = true
		_L = {}
		_L["ALL"] 	  = {}
		_L["DDL"]  	  = {}
		_L["DDV"]  	  = {}
		if _addon.Settings.GearSets["sets"]["keys"] == nil then _addon.Settings.GearSets["sets"]["keys"] = {} end
		
		for k,v in pairs(_addon.Settings.GearSets["sets"]["keys"]) do 
			_L["DDV"][ v ] = k
		end
		
		for k,v in _addon:PairsByKeys(_L["DDV"]) do
			_L["ALL"][ _addon:GetNextOf(_L["ALL"]) ] = k
			_L["DDL"][ _addon:GetNextOf(_L["DDL"]) ] = k
		end
		
		for k,v in pairs( _L["DDL"] ) do
			_L["DDV"][ v ] = k
		end
		_addon.Settings.GearSetsChanged2 = false
	end
	return ret
end
_addon.GC.ReloadSets = function()
	_addon.Settings.GearSetsChanged2 = true
	loadListGear()
end

local EBox = function(parent, name, text, isMultiLine, getFunc, setFunc, width)
	width = width or 160
	if text == nil then width = width / 2 end
	local editbox = _addon.Frames.__NewTopLevel(name)
		:SetParent(parent)
		:SetAnchor(LEFT, parent, LEFT, 0, -2)
		:SetResizeToFitDescendents(true)
		:SetWidth(width)
		:SetMouseEnabled(true)
		:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
		:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
	.__END
	editbox.Value = getFunc()
	
	if text ~= nil then
		editbox.label = _addon.Frames.__NewLabel(name.."Label", editbox)
			:SetDimensions(width/2, 26)
			:SetAnchor(TOPLEFT)
			:SetFont("ZoFontWinH4")
			:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
			:SetText(text)
			:SetHorizontalAlignment(_addon.GLOBAL.TextAlign["h"]["left"])
			:SetVerticalAlignment(_addon.GLOBAL.TextAlign["v"]["center"])
		.__END
	end
	
	editbox.bg = _addon.Frames.__Chain(WINDOW_MANAGER:CreateControlFromVirtual(name.."BG", editbox, "ZO_EditBackdrop"))
		:SetDimensions(width/2,isMultiLine and 100 or 24)
		:SetCenterColor(0,0,0,1)
		:SetEdgeColor(0,0,0,1)
		:SetEdgeTexture("", 8, 1, 1)
		:SetAlpha(1)
		:SetAnchor(RIGHT)
	.__END
	if text == nil then editbox.bg:SetAnchor(LEFT) end
	
	editbox.edit = _addon.Frames.__Chain(WINDOW_MANAGER:CreateControlFromVirtual(name.."Edit", editbox.bg, isMultiLine and "ZO_DefaultEditMultiLineForBackdrop" or "ZO_DefaultEditForBackdrop"))
		:SetText(editbox.Value)
		:SetColor( .3, .72, 1, 1 )
		:SetHandler("OnFocusLost", function(self) editbox.Value = self:GetText(); end)
	.__END
	
	editbox.SetValue = function( val )
		editbox.Value =  val or ""
		editbox.edit:SetText( val or "" )
	end
	editbox.GetValue = function()
		return editbox.Value
	end
	
	editbox.panel = parent
	editbox.data = {}
	return editbox
end

local getNameWindow = function()
	local parent = _G["wykkydsOutfitterGearUIFrame"]
	local win = "wykkydsOutfitterGearUIBackdropnewName"
	local findAndAnchor = function()
		local m = _G["wykkydsOutfitterGearUIBackdropnewName"]
		if m then
			local p = _G["wykkydsOutfitterGearUIBackdrop"]
			if p then
				local pX, pY = p:GetCenter()
				local pH = (p:GetHeight()/2)
				local mH = (m:GetHeight()/2)
				local offset = pH+mH
				local gX, gY = GuiRoot:GetCenter()
				local p1, p2, p3, p4, p5, p6 = p:GetAnchor(0)
				m:ClearAnchors()
				if pY > gY then -- is lower than center
					m:SetAnchor(p2, p3, p4, p5, p6-offset-2)
				else
					m:SetAnchor(p2, p3, p4, p5, p6+offset+2)
				end
				--d( m:GetAnchor(0) )
			end
		end
		m:SetHidden( false )
		m.SetMyText("")
	end
	if _G[win] then
		findAndAnchor()
		return
	end
	local topLevel = _addon.Frames.__NewTopLevel(win)
		:SetParent(ZO_CharacterApparelSection)
		:SetAnchor(
			TOPLEFT,
			ZO_CharacterApparelSection, 
			TOPRIGHT, 
			-30, 
			132
		)
		:SetDimensions( 250, 80 )
	.__END
	local bg = _addon.Frames.__NewBackdrop( win.."bg", topLevel )
		:SetAnchor( CENTER, topLevel, CENTER, 0, 0 )
		:SetDimensions( 250, 80 )
		:SetCenterColor(0.05,0.05,0.45,1)
		:SetEdgeColor(0,0,0,1)
		:SetEdgeTexture("", 8, 1, 1)
		:SetAlpha(1)
		:SetDrawLayer(9)
	.__END
	bg.SelectedText = ""
	local ebox = EBox(bg, win.."ebox", "Set Name:", false, function() return ""; end, function(val)
		bg.SelectedText = val
	end, 220)
	ebox:SetAnchor( TOP, bg, TOP, 0, 20 )
	topLevel.SetMyText = function(val) ebox.SetValue( val ) end
	topLevel.GetMyText = function() return ebox.GetValue() end
	local saveAndSet = function()
		local txt = topLevel.GetMyText()
		txt = _addon:string_trim(txt)
		if txt ~= "" then
			local doSave = true
			for k,v in pairs( _addon.Settings.GearSets["sets"]["keys"] ) do
				if v == txt then doSave = false end
			end
			if doSave then
				table.insert( _addon.Settings.GearSets["sets"]["keys"], txt )
				_addon.Settings.GearSetsChanged2 = true
				_G["wykkydsOutfitterGearUIFrame"].setScrollToText( txt )
			end
		end
		_G[win]:ClearAnchors()
		_G[win]:SetAnchor( TOP, GuiRoot, TOP, -3000, -6000 )
		_G[win].SetMyText("")
	end
	local SaveBTN = _addon.Frames.StandardButton:Create(
		topLevel, win.."savebtn", 
		{ BOTTOMLEFT, bg, BOTTOMLEFT, 20, -10 }, 
		80, 14, 
		{0,0,0,0}, 
		{0.2,0.2,0.7,0}, 
		{"", 8, 1, 0}, 
		1, "[Save]", 
		{1,1,1,1}, 
		nil, nil, nil
	)
	SaveBTN.Label:SetHorizontalAlignment(_addon.GLOBAL.TextAlign["h"]["center"])
	SaveBTN.Label:SetVerticalAlignment(_addon.GLOBAL.TextAlign["v"]["top"])
	SaveBTN.Button:SetMouseEnabled( true )
	SaveBTN.Button:SetHandler("OnClicked", function(self,button) saveAndSet() end )
	SaveBTN.Button:SetHandler("OnMouseEnter", function() SaveBTN.Label:SetColor(.5,.6,1,1) end)
	SaveBTN.Button:SetHandler("OnMouseExit", function() SaveBTN.Label:SetColor(1,1,1,1) end)
	local CancelBTN = _addon.Frames.StandardButton:Create(
		topLevel, win.."cancelbtn", 
		{ BOTTOMRIGHT, bg, BOTTOMRIGHT, -20, -10 }, 
		80, 14, 
		{0,0,0,0}, 
		{0.2,0.2,0.7,0}, 
		{"", 8, 1, 0}, 
		1, "[Cancel]", 
		{1,1,1,1}, 
		nil, nil, nil
	)
	CancelBTN.Label:SetHorizontalAlignment(_addon.GLOBAL.TextAlign["h"]["center"])
	CancelBTN.Label:SetVerticalAlignment(_addon.GLOBAL.TextAlign["v"]["top"])
	CancelBTN.Button:SetMouseEnabled( true )
	CancelBTN.Button:SetHandler("OnClicked", function(self,button) 
		_G[win]:ClearAnchors()
		_G[win]:SetAnchor( TOP, GuiRoot, TOP, -3000, -6000 )
		_G[win].SetMyText("")
	end )
	CancelBTN.Button:SetHandler("OnMouseEnter", function() CancelBTN.Label:SetColor(.5,.6,1,1) end)
	CancelBTN.Button:SetHandler("OnMouseExit", function() CancelBTN.Label:SetColor(1,1,1,1) end)
	findAndAnchor()
end

local makeScrollSelector = function( selected )
	local parent = _G["wykkydsOutfitterGearUIFrame"]
	local lName = "wykkydsOutfitterGearUIFrame_scrollctrl"
	local ww = 180
	
	local aBox = _addon.Frames.__NewLabel(lName .. "aBox", parent)
		:SetAnchor( TOPLEFT, parent, TOPLEFT, 12, 29 )
		:SetDimensions( ww , 14 )
		:SetFont(string.format( "%s|%d|%s", "EsoUI/Common/Fonts/univers57.otf", 11, "soft-shadow-thick"))
		:SetColor( 184/255, 134/255, 11/255, 1 )
		:SetHidden(false)
		:SetText("TEST A")
		:SetHorizontalAlignment(_addon.GLOBAL.TextAlign["h"]["center"])
		:SetVerticalAlignment(_addon.GLOBAL.TextAlign["v"]["center"])
		:SetMouseEnabled( true )
	.__END
	local bBox = _addon.Frames.__NewLabel(lName .. "bBox", parent)
		:SetAnchor( TOP, aBox, BOTTOM, 0, 1 )
		:SetDimensions( ww , 24 )
		:SetFont(string.format( "%s|%d|%s", "EsoUI/Common/Fonts/univers57.otf", 16, "soft-shadow-thick"))
		:SetColor( .90, .90, .25, 1 )
		:SetHidden(false)
		:SetText("TEST B")
		:SetHorizontalAlignment(_addon.GLOBAL.TextAlign["h"]["center"])
		:SetVerticalAlignment(_addon.GLOBAL.TextAlign["v"]["center"])
	.__END
	local cBox = _addon.Frames.__NewLabel(lName .. "cBox", parent)
		:SetAnchor( TOP, bBox, BOTTOM, 0, 2 )
		:SetDimensions( ww , 14 )
		:SetFont(string.format( "%s|%d|%s", "EsoUI/Common/Fonts/univers57.otf", 11, "soft-shadow-thick"))
		:SetColor( 184/255, 134/255, 11/255, 1 )
		:SetHidden(false)
		:SetText("TEST C")
		:SetHorizontalAlignment(_addon.GLOBAL.TextAlign["h"]["center"])
		:SetVerticalAlignment(_addon.GLOBAL.TextAlign["v"]["center"])
		:SetMouseEnabled( true )
	.__END
	
	local frame = _addon.Frames.NewImage(lName .. "Fra4me", aBox)
	frame:SetDimensions(ww, 26)
	frame:SetAnchor( CENTER, bBox, CENTER, 0, 1 )
	frame:SetTexture("/esoui/art/ava/ava_resourcestatus_progbar_achieved_overlay.dds")
	frame:SetColor(0, 1, 1, 1)
	frame:SetMouseEnabled( true )
	
	parent.icons = {}
	parent.icons.scrollers	= {}
	parent.icons.scrollers.hasBoth 	= "/esoui/art/miscellaneous/list_sortheader_icon_neutral.dds"
	parent.icons.scrollers.hasNone 	= "/esoui/art/miscellaneous/list_sortheader_icon_over.dds"
	parent.icons.scrollers.hasUp 	= "/esoui/art/miscellaneous/list_sortheader_icon_sortup.dds"
	parent.icons.scrollers.hasDown 	= "/esoui/art/miscellaneous/list_sortheader_icon_sortdown.dds"
	parent.icons.addnew	= {}
	parent.icons.addnew.newUp	= "/esoui/art/progression/addpoints_up.dds"
	parent.icons.addnew.newOver	= "/esoui/art/progression/addpoints_over.dds"
	parent.icons.addnew.newDown	= "/esoui/art/progression/addpoints_down.dds"
	
	local scrollIcon = _addon.Frames.NewImage(lName .. "scrollIcon", frame)
	scrollIcon:SetDimensions(32, 32)
	scrollIcon:SetAnchor( LEFT, frame, RIGHT, 3, 0 )
	scrollIcon:SetTexture(parent.icons.scrollers.hasBoth)
	scrollIcon:SetColor(0, 1, 1, 1)
	scrollIcon:SetMouseEnabled( true )
	
	local addNew = _addon.Frames.NewImage(lName .. "addNew", frame)
	addNew:SetDimensions(36, 36)
	addNew:SetAnchor( LEFT, scrollIcon, RIGHT, -8, 1 )
	addNew:SetTexture(parent.icons.addnew.newUp)
	addNew:SetColor(0, 1, 1, 1)
	addNew:SetMouseEnabled( true )
	addNew.MouseOver = false
	addNew:SetHandler("OnMouseEnter", function()
		addNew.MouseOver = true
		addNew:SetTexture(parent.icons.addnew.newOver)
	end )
	addNew:SetHandler("OnMouseExit", function()
		addNew.MouseOver = false
		addNew:SetTexture(parent.icons.addnew.newUp)
	end )
	addNew:SetHandler("OnMouseDown", function()
		if addNew.MouseOver then addNew:SetTexture(parent.icons.addnew.newDown) end
	end )
	addNew:SetHandler("OnMouseUp", function()
		if addNew.MouseOver then 
			addNew:SetTexture(parent.icons.addnew.newOver)
			getNameWindow( parent )
		else addNew:SetTexture(parent.icons.addnew.newUp) end
	end )
	
	parent.setScroll = function( sel )
		local num = _addon:GetCountOf( _L["DDL"] )
		if sel == nil then sel = 1 end
		if sel < 1 then sel = 1 end
		if sel > num then sel = num end
		
		local base = ""
		local a, b, c = base, _L["DDL"][sel], base
		
		if sel > 1 then a = _L["DDL"][sel-1] end
		if sel < num then c = _L["DDL"][sel+1] end
		aBox:SetText( a )
		bBox:SetText( b )
		cBox:SetText( c )
		
		parent.SelectedIndex = sel
		parent.SelectedName = b
		parent.SelectionCount = nume
		
		if a == "" and c == "" then scrollIcon:SetTexture( parent.icons.scrollers.hasNone )
		elseif a ~= "" and c ~= "" then scrollIcon:SetTexture( parent.icons.scrollers.hasBoth )
		elseif a ~= "" then scrollIcon:SetTexture( parent.icons.scrollers.hasUp )
		else scrollIcon:SetTexture( parent.icons.scrollers.hasDown ) end
	end
	parent.setScrollToText = function( txt )
		loadListGear()
		for k,v in pairs( _L["DDL"] ) do
			if v == txt then parent.setScroll( k ); return; end
		end
		parent.setScroll( 1 );
	end
	parent.CycleDown = function() parent.setScroll( parent.SelectedIndex+1 ) end
	parent.CycleUp = function() parent.setScroll( parent.SelectedIndex-1 ) end
	parent.HandleScroll = function(self, delta, ctrl, alt, shift) if delta > 0 then parent.CycleUp() else parent.CycleDown() end end
	frame:SetHandler( "OnMouseWheel", function(self, delta, ctrl, alt, shift) parent.HandleScroll(self, delta, ctrl, alt, shift) end )
	scrollIcon:SetHandler( "OnMouseWheel", function(self, delta, ctrl, alt, shift) parent.HandleScroll(self, delta, ctrl, alt, shift) end )
	aBox:SetHandler( "OnMouseWheel", function(self, delta, ctrl, alt, shift) parent.HandleScroll(self, delta, ctrl, alt, shift) end )
	cBox:SetHandler( "OnMouseWheel", function(self, delta, ctrl, alt, shift) parent.HandleScroll(self, delta, ctrl, alt, shift) end )
	
	parent.setScroll( selected )
end

_addon.GC.Frame.Load = function()
	_addon.GC.Frame.Overlay = _addon.Frames.__NewTopLevel("wykkydsOutfitterGearUIFrame")
		:SetParent(ZO_CharacterApparelSection)
		:SetAnchor(
			_addon:GetOrDefault( TOPLEFT, _addon.GlobalSettings["gc_anchor1"] ),
			ZO_CharacterApparelSection, 
			_addon:GetOrDefault( TOPRIGHT, _addon.GlobalSettings["gc_anchor2"] ), 
			_addon:GetOrDefault( 300, _addon.GlobalSettings["gc_shiftx"]), -- -30
			_addon:GetOrDefault( 0, _addon.GlobalSettings["gc_shifty"])
		)
		:SetDimensions( 250, 132 )
		:SetMovable(true)
		:SetMouseEnabled(true)
		:SetClampedToScreen(true)
	.__END
	
	function _addon.GC.Frame.Overlay.SaveOffscreenLoss(self)
		local guiRootX, guiRootY = GuiRoot:GetCenter()
		if self:GetLeft() < 0
		or self:GetRight() > (guiRootX*2)
		or self:GetTop() < 0
		or self:GetBottom() > (guiRootY*2)
		then
			_addon.GC.Frame.Overlay:SetHandler("OnMoveStop", function(self) return; end)
			self:ClearAnchors()
			self:SetAnchor( TOPLEFT, ZO_CharacterApparelSection, TOPRIGHT, -30, 0 )
			guiRootX, guiRootY = ZO_CharacterApparelSection:GetCenter()
			local addOnX, addOnY = self:GetCenter()
			local x = addOnX - guiRootX
			local y = addOnY - guiRootY
			_addon.GlobalSettings["gc_anchor1"] = CENTER
			_addon.GlobalSettings["gc_anchor2"] = CENTER
			_addon.GlobalSettings["gc_shiftx"] = x
			_addon.GlobalSettings["gc_shifty"] = y
			_addon.GC.Frame.Overlay:SetHandler("OnMoveStop", function(self) self:SetFrameCoords() end)
			return
		end
	end
	function _addon.GC.Frame.Overlay.SetFrameCoords(self)
		local addOnX, addOnY = self:GetCenter()
		local guiRootX, guiRootY = ZO_CharacterApparelSection:GetCenter()
		local x = addOnX - guiRootX
		local y = addOnY - guiRootY
		_addon.GlobalSettings["gc_anchor1"] = CENTER
		_addon.GlobalSettings["gc_anchor2"] = CENTER
		_addon.GlobalSettings["gc_shiftx"] = x
		_addon.GlobalSettings["gc_shifty"] = y
		self:SaveOffscreenLoss()
	end
	_addon.GC.Frame.Overlay:SetHandler("OnMoveStop", function(self) self:SetFrameCoords() end)
	_addon.GC.Frame.Overlay:SetFrameCoords()
	
	_addon.GC.Frame.Overlay.BG = _addon.Frames.__NewBackdrop("wykkydsOutfitterGearUIBackdrop", _addon.GC.Frame.Overlay)
		:SetAnchor(CENTER, _addon.GC.Frame.Overlay, CENTER, 0, 0)
		:SetDimensions( _addon.GC.Frame.Overlay:GetWidth(), _addon.GC.Frame.Overlay:GetHeight() )
		:SetCenterColor(0.05,0.05,0.05,.85)
		:SetEdgeColor(0,0,0,1)
		:SetEdgeTexture("", 8, 1, 1)
		:SetAlpha(1)
		:SetHidden(false)
		:SetDrawLayer(9)
	.__END
	
	_addon.GC.Frame.Overlay.Title = _addon.Frames.__NewLabel("wykkydsOutfitterGearUITitle", _addon.GC.Frame.Overlay.BG)
		:SetAnchor( TOP, _addon.GC.Frame.Overlay.BG, TOP, 0, 0 )
		:SetDimensions( w , h )
		:SetFont("ZoFontGame")
		:SetColor( .3, .72, 1, 1 )
		:SetAlpha(1)
		:SetHidden(false)
		:SetText("Wykkyd's Outfitter")
	.__END
	
	_addon.GC.Frame.Overlay.tooltip = _addon.Frames.__NewLabel("wykkydsOutfitterGearUI_tooltip", _addon.GC.Frame.Overlay.BG)
		:SetAnchor( TOP, _addon.GC.Frame.Overlay.BG, TOP, 0, 17 )
		:SetDimensions( w , h )
		:SetFont(string.format( "%s|%d|%s", "EsoUI/Common/Fonts/univers67.otf", 10, "soft-shadow-thick"))
		:SetColor( .85, .85, .85, 1 )
		:SetAlpha(1)
		:SetHidden(false)
		:SetText("- use your scroll wheel -")
	.__END
	
	loadListGear()
	
	_addon.GC.Frame.Overlay.DDL = makeScrollSelector()
		
	_addon.GC.Frame.Overlay.EquipBTN = _addon.Frames.StandardButton:Create(
		_addon.GC.Frame.Overlay.BG, "wykkydsOutfitterGearUIDDLEquipBTN", 
		{ BOTTOMRIGHT, _addon.GC.Frame.Overlay.BG, BOTTOM, -3, 0 }, 
		80, 14, 
		{0,0,0,0}, 
		{0.2,0.2,0.7,0}, 
		{"", 8, 1, 0}, 
		1, "[Equip]", 
		{1,1,1,1}, 
		nil, nil, nil
	)
	_addon.GC.Frame.Overlay.EquipBTN.Backdrop:ClearAnchors()
	_addon.GC.Frame.Overlay.EquipBTN.Backdrop:SetAnchor( BOTTOM, _addon.GC.Frame.Overlay.BG, BOTTOM, 0, -29 )
	_addon.GC.Frame.Overlay.EquipBTN.Label:SetHorizontalAlignment(_addon.GLOBAL.TextAlign["h"]["center"])
	_addon.GC.Frame.Overlay.EquipBTN.Label:SetVerticalAlignment(_addon.GLOBAL.TextAlign["v"]["top"])
	_addon.GC.Frame.Overlay.EquipBTN.Button:SetHandler("OnClicked", function(self,button) 
		local idx = _G["wykkydsOutfitterGearUIFrame"].SelectedName
		if idx ~= nil and idx ~= "  " then
			_addon.GC.LoadCommands( idx )
		end
	end )
	_addon.GC.Frame.Overlay.EquipBTN.Button:SetHandler("OnMouseEnter", function() _addon.GC.Frame.Overlay.EquipBTN.Label:SetColor(.5,.6,1,1) end)
	_addon.GC.Frame.Overlay.EquipBTN.Button:SetHandler("OnMouseExit", function() _addon.GC.Frame.Overlay.EquipBTN.Label:SetColor(1,1,1,1) end)
	
	_addon.GC.Frame.Overlay.SaveBTN = _addon.Frames.StandardButton:Create(
		_addon.GC.Frame.Overlay.BG, "wykkydsOutfitterGearUIDDLSaveBTN", 
		{ BOTTOMRIGHT, _addon.GC.Frame.Overlay.BG, BOTTOM, -3, 0 }, 
		80, 14, 
		{0,0,0,0}, 
		{0.2,0.2,0.7,0}, 
		{"", 8, 1, 0}, 
		1, "[Save]", 
		{1,1,1,1}, 
		nil, nil, nil
	)
	_addon.GC.Frame.Overlay.SaveBTN.Backdrop:ClearAnchors()
	_addon.GC.Frame.Overlay.SaveBTN.Backdrop:SetAnchor( RIGHT, _addon.GC.Frame.Overlay.EquipBTN.Backdrop, LEFT, -3, 0 )
	_addon.GC.Frame.Overlay.SaveBTN.Label:SetHorizontalAlignment(_addon.GLOBAL.TextAlign["h"]["center"])
	_addon.GC.Frame.Overlay.SaveBTN.Label:SetVerticalAlignment(_addon.GLOBAL.TextAlign["v"]["top"])
	_addon.GC.Frame.Overlay.SaveBTN.Button:SetHandler("OnClicked", function(self,button) 
		local idx = _G["wykkydsOutfitterGearUIFrame"].SelectedName
		if idx ~= nil and idx ~= "  " then
			_addon.GC.SaveCommands( idx )
			_addon.Settings.GearSetsChanged2 = true
			_G["wykkydsOutfitterGearUIFrame"].setScrollToText( idx )
		end
	end )
	_addon.GC.Frame.Overlay.SaveBTN.Button:SetHandler("OnMouseEnter", function() _addon.GC.Frame.Overlay.SaveBTN.Label:SetColor(.5,.6,1,1) end)
	_addon.GC.Frame.Overlay.SaveBTN.Button:SetHandler("OnMouseExit", function() _addon.GC.Frame.Overlay.SaveBTN.Label:SetColor(1,1,1,1) end)
		
	_addon.GC.Frame.Overlay.DeleteBTN = _addon.Frames.StandardButton:Create(
		_addon.GC.Frame.Overlay.BG, "wykkydsOutfitterGearUIDDLDeleteBTN", 
		{ BOTTOMRIGHT, _addon.GC.Frame.Overlay.BG, BOTTOM, -3, 0 }, 
		80, 14, 
		{0,0,0,0}, 
		{0.2,0.2,0.7,0}, 
		{"", 8, 1, 0}, 
		1, "[Delete]", 
		{1,1,1,1}, 
		nil, nil, nil
	)
	_addon.GC.Frame.Overlay.DeleteBTN.Backdrop:ClearAnchors()
	_addon.GC.Frame.Overlay.DeleteBTN.Backdrop:SetAnchor( LEFT, _addon.GC.Frame.Overlay.EquipBTN.Backdrop, RIGHT, 3, 0 )
	_addon.GC.Frame.Overlay.DeleteBTN.Label:SetHorizontalAlignment(_addon.GLOBAL.TextAlign["h"]["center"])
	_addon.GC.Frame.Overlay.DeleteBTN.Label:SetVerticalAlignment(_addon.GLOBAL.TextAlign["v"]["top"])
	_addon.GC.Frame.Overlay.DeleteBTN.Button:SetHandler("OnClicked", function(self,button) 
		local idx = _G["wykkydsOutfitterGearUIFrame"].SelectedName
		if idx ~= nil and idx ~= "  " then
			_addon.GC.ClearCommands( idx )
			_addon.Settings.GearSetsChanged2 = true
			_G["wykkydsOutfitterGearUIFrame"].setScrollToText( "" )
		end
	end )
	_addon.GC.Frame.Overlay.DeleteBTN.Button:SetHandler("OnMouseEnter", function() _addon.GC.Frame.Overlay.DeleteBTN.Label:SetColor(.5,.6,1,1) end)
	_addon.GC.Frame.Overlay.DeleteBTN.Button:SetHandler("OnMouseExit", function() _addon.GC.Frame.Overlay.DeleteBTN.Label:SetColor(1,1,1,1) end)
		
	_addon.GC.Frame.Overlay.NakedBTN = _addon.Frames.StandardButton:Create(
		_addon.GC.Frame.Overlay.BG, "wykkydsOutfitterGearUIDDLNakedBTN", 
		{ BOTTOMRIGHT, _addon.GC.Frame.Overlay.BG, BOTTOM, -3, 0 }, 
		88, 14, 
		{0,0,0,0}, 
		{0.2,0.2,0.7,0}, 
		{"", 8, 1, 0}, 
		1, "[Go Naked]", 
		{1,1,1,1}, 
		nil, nil, nil
	)
	_addon.GC.Frame.Overlay.NakedBTN.Backdrop:ClearAnchors()
	_addon.GC.Frame.Overlay.NakedBTN.Backdrop:SetAnchor( BOTTOMRIGHT, _addon.GC.Frame.Overlay.BG, BOTTOM, -3, -6 )
	_addon.GC.Frame.Overlay.NakedBTN.Label:SetHorizontalAlignment(_addon.GLOBAL.TextAlign["h"]["center"])
	_addon.GC.Frame.Overlay.NakedBTN.Label:SetVerticalAlignment(_addon.GLOBAL.TextAlign["v"]["top"])
	_addon.GC.Frame.Overlay.NakedBTN.Button:SetHandler( "OnClicked", function(self,button) _addon.GC.StripNaked(); end )
	_addon.GC.Frame.Overlay.NakedBTN.Button:SetHandler( "OnMouseEnter", function() _addon.GC.Frame.Overlay.NakedBTN.Label:SetColor(.5,.6,1,1) end )
	_addon.GC.Frame.Overlay.NakedBTN.Button:SetHandler( "OnMouseExit", function() _addon.GC.Frame.Overlay.NakedBTN.Label:SetColor(1,1,1,1) end )
		
	_addon.GC.Frame.Overlay.DressBTN = _addon.Frames.StandardButton:Create(
		_addon.GC.Frame.Overlay.BG, "wykkydsOutfitterGearUIDDLNakedBTN", 
		{ BOTTOMRIGHT, _addon.GC.Frame.Overlay.BG, BOTTOM, -3, 0 }, 
		88, 14, 
		{0,0,0,0}, 
		{0.2,0.2,0.7,0}, 
		{"", 8, 1, 0}, 
		1, "[Dress Up]", 
		{1,1,1,1}, 
		nil, nil, nil
	)
	_addon.GC.Frame.Overlay.DressBTN.Backdrop:ClearAnchors()
	_addon.GC.Frame.Overlay.DressBTN.Backdrop:SetAnchor( BOTTOMLEFT, _addon.GC.Frame.Overlay.BG, BOTTOM, 3, -6 )
	_addon.GC.Frame.Overlay.DressBTN.Label:SetHorizontalAlignment(_addon.GLOBAL.TextAlign["h"]["center"])
	_addon.GC.Frame.Overlay.DressBTN.Label:SetVerticalAlignment(_addon.GLOBAL.TextAlign["v"]["top"])
	_addon.GC.Frame.Overlay.DressBTN.Button:SetHandler( "OnClicked", function(self,button) _addon.GC.GetDressed(); end )
	_addon.GC.Frame.Overlay.DressBTN.Button:SetHandler( "OnMouseEnter", function() _addon.GC.Frame.Overlay.DressBTN.Label:SetColor(.5,.6,1,1) end )
	_addon.GC.Frame.Overlay.DressBTN.Button:SetHandler( "OnMouseExit", function() _addon.GC.Frame.Overlay.DressBTN.Label:SetColor(1,1,1,1) end )
end


