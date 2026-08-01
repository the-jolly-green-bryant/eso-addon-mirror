local _addon = WYK_Macros

local ChildEditWinName = "WykkydEditMacroChild"
local ChildWin1 = ChildEditWinName.."EW1"
local ChildWin2 = ChildEditWinName.."EW2"
local ChildWin3 = ChildEditWinName.."EW3"

local closeChildWin = function( nm, compare )
	if (compare ~= nil and compare ~= nm) and _G[nm] ~= nil then 
		_G[nm]:CloseMe()
	end
end

local editRows = {}
local _L, beenLoaded = {}, false
local bWO = function() return (_G["WYK_Outfitter"] ~= nil) end
local woGearChanged = function( val )
	if bWO() then
		if val ~= nil then WYK_Outfitter.GearSetsChanged = val end
		return WYK_Outfitter.GearSetsChanged
	else
		return false
	end
end
local woSkillsChanged = function( val )
	if bWO() then
		if val ~= nil then WYK_Outfitter.SkillSetsChanged = val end
		return WYK_Outfitter.SkillSetsChanged
	else
		return false
	end
end

local loadListGear = function()
	local ret = false
	if woGearChanged or _L[_addon.G.MACRO_TYPE_GEAR] ==  nil then
		ret = true
		_L[_addon.G.MACRO_TYPE_GEAR] = {}
		_L[_addon.G.MACRO_TYPE_GEAR]["ALL"] 	  = {}
		_L[_addon.G.MACRO_TYPE_GEAR]["DDL"]  	  = {}
		_L[_addon.G.MACRO_TYPE_GEAR]["DDV"]  	  = {}
		if bWO() then
			if WYK_Outfitter.Settings.GearSets["sets"]["keys"] == nil then WYK_Outfitter.Settings.GearSets["sets"]["keys"] = {} end
			
			for k,v in pairs(WYK_Outfitter.Settings.GearSets["sets"]["keys"]) do 
				if v ~= WYK_Outfitter.GC.NekkidKey then
					_L[_addon.G.MACRO_TYPE_GEAR]["DDV"][ v ] = k
				end
			end
			
			for k,v in _addon:PairsByKeys(_L[_addon.G.MACRO_TYPE_GEAR]["DDV"]) do
				_L[_addon.G.MACRO_TYPE_GEAR]["ALL"][ _addon:GetNextOf(_L[_addon.G.MACRO_TYPE_GEAR]["ALL"]) ] = k
				_L[_addon.G.MACRO_TYPE_GEAR]["DDL"][ _addon:GetNextOf(_L[_addon.G.MACRO_TYPE_GEAR]["DDL"]) ] = k
			end
			
			for k,v in pairs( _L[_addon.G.MACRO_TYPE_GEAR]["DDL"] ) do
				_L[_addon.G.MACRO_TYPE_GEAR]["DDV"][ v ] = k
			end
		end
		woGearChanged(false)
	end
	return ret
end

local loadListSkills = function()
	local ret = false
	if woSkillsChanged or _L[_addon.G.MACRO_TYPE_SKILL] ==  nil then
		ret = true
		_L[_addon.G.MACRO_TYPE_SKILL] = {}
		_L[_addon.G.MACRO_TYPE_SKILL]["ALL"] 	  = {}
		_L[_addon.G.MACRO_TYPE_SKILL]["DDL"]  	  = {}
		_L[_addon.G.MACRO_TYPE_SKILL]["DDV"]  	  = {}
		if bWO() then
			if WYK_Outfitter.Settings.SkillSets["sets"]["keys"] == nil then WYK_Outfitter.Settings.SkillSets["sets"]["keys"] = {} end
			
			for k,v in pairs(WYK_Outfitter.Settings.SkillSets["sets"]["keys"]) do 
				_L[_addon.G.MACRO_TYPE_SKILL]["DDV"][ v ] = k
			end
			
			for k,v in _addon:PairsByKeys(_L[_addon.G.MACRO_TYPE_SKILL]["DDV"]) do
				_L[_addon.G.MACRO_TYPE_SKILL]["ALL"][ _addon:GetNextOf(_L[_addon.G.MACRO_TYPE_SKILL]["ALL"]) ] = k
				_L[_addon.G.MACRO_TYPE_SKILL]["DDL"][ _addon:GetNextOf(_L[_addon.G.MACRO_TYPE_SKILL]["DDL"]) ] = k
			end
			
			for k,v in pairs( _L[_addon.G.MACRO_TYPE_SKILL]["DDL"] ) do
				_L[_addon.G.MACRO_TYPE_SKILL]["DDV"][ v ] = k
			end
		end
	end
	return ret
end

local loadListEmotes = function()
	local ret = false
	if woSkillsChanged or _L[_addon.G.MACRO_TYPE_EMOTE] ==  nil then
		ret = true
		_L[_addon.G.MACRO_TYPE_EMOTE] = {}
		_L[_addon.G.MACRO_TYPE_EMOTE]["ALL"] 	  = {}
		_L[_addon.G.MACRO_TYPE_EMOTE]["DDL"]  	  = {}
		_L[_addon.G.MACRO_TYPE_EMOTE]["DDV"]  	  = {}
		_addon:LoadEmotes()
		
		for k,v in pairs(_addon.GLOBAL.emotesSorted) do 
			_L[_addon.G.MACRO_TYPE_EMOTE]["DDV"][ v.name ] = v.name
		end
		
		for k,v in _addon:PairsByKeys(_L[_addon.G.MACRO_TYPE_EMOTE]["DDV"]) do
			_L[_addon.G.MACRO_TYPE_EMOTE]["ALL"][ _addon:GetNextOf(_L[_addon.G.MACRO_TYPE_EMOTE]["ALL"]) ] = k
			_L[_addon.G.MACRO_TYPE_EMOTE]["DDL"][ _addon:GetNextOf(_L[_addon.G.MACRO_TYPE_EMOTE]["DDL"]) ] = v
		end
		
		for k,v in pairs( _L[_addon.G.MACRO_TYPE_EMOTE]["DDL"] ) do
			_L[_addon.G.MACRO_TYPE_EMOTE]["DDV"][ v ] = k
		end
end
	return ret
end

local loadLists = function()
	if beenLoaded then return end
	beenLoaded = true
	
	loadListGear()
	loadListSkills()
	loadListEmotes()
end

local makeScrollSelector = function( selected, targetWin, targetList, listCallback )
	local parent = _G[targetWin]
	local lName = targetWin.."_scrollctrl"
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
	
	local frame = WINDOW_MANAGER:CreateControl(lName .. "Fra4me", aBox, CT_TEXTURE)
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
	
	local scrollIcon = WINDOW_MANAGER:CreateControl(lName .. "scrollIcon", frame, CT_TEXTURE)
	scrollIcon:SetDimensions(32, 32)
	scrollIcon:SetAnchor( LEFT, frame, RIGHT, 3, 0 )
	scrollIcon:SetTexture(parent.icons.scrollers.hasBoth)
	scrollIcon:SetColor(0, 1, 1, 1)
	scrollIcon:SetMouseEnabled( true )
	
	parent.setScroll = function( sel )
		local num = _addon:GetCountOf( targetList )
		if sel == nil then sel = 1 end
		if sel < 1 then sel = 1 end
		if sel > num then sel = num end
		
		local base = ""
		local a, b, c = base, targetList[sel], base
		
		if sel > 1 then a = targetList[sel-1] end
		if sel < num then c = targetList[sel+1] end
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
		listCallback()
		for k,v in pairs( targetList ) do
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

local makeScrollSelector1 = function( selected )
	return makeScrollSelector( selected, ChildWin1, _L[_addon.G.MACRO_TYPE_GEAR]["DDL"], loadListGear )
end

local makeScrollSelector2 = function( selected )
	return makeScrollSelector( selected, ChildWin2, _L[_addon.G.MACRO_TYPE_SKILL]["DDL"], loadListSkills )
end

local makeScrollSelector3 = function( selected )
	return makeScrollSelector( selected, ChildWin3, _L[_addon.G.MACRO_TYPE_EMOTE]["DDL"], loadListEmotes )
end

local childEditWin = function( parent, vars, prep, targetWin, label, selectorCallback )
	if vars == nil then vars = {} end
	if _G[targetWin] == nil then
		_addon.Frames.StandardPopup:Create( 
			targetWin, label, 
			{TOPLEFT, parent, TOPRIGHT, 7, 0}, 260, 
			nil, function()
				return
			end, true
		)
		local obj = _G[targetWin]
		
		obj.ChildCallback = parent.ChildCallBack
		
		obj.Type = _addon.G.MACRO_TYPE_GEAR
		obj.Param1 = vars.Param1
		obj.Param2 = nil
		if vars.Type ~= obj.Type then obj.Param1 = nil; obj.Param2 = nil; end
		
		obj.DDL = selectorCallback()
	
		obj.tooltip = _addon.Frames.__NewLabel(targetWin.."_tooltip", _G[targetWin])
			:SetAnchor( TOP, _G[targetWin], TOP, 0, 17 )
			:SetDimensions( 150 , 14 )
			:SetFont(string.format( "%s|%d|%s", "EsoUI/Common/Fonts/univers67.otf", 10, "soft-shadow-thick"))
			:SetColor( .85, .85, .85, 1 )
			:SetAlpha(1)
			:SetHidden(false)
			:SetText("- use your scroll wheel -")
			:SetHorizontalAlignment(_addon.GLOBAL.TextAlign["h"]["center"])
			:SetVerticalAlignment(_addon.GLOBAL.TextAlign["v"]["center"])
		.__END
		
		obj:SetHeight( 120 )
		
		obj.Param1Hold = ""
		obj.Param2Hold = ""
		
		obj.SetValues = function( param1, param2 )
			_G[targetWin].setScrollToText( param1 )
			obj.Param1 = param1 or -1
			obj.Param1Hold = obj.Param1
		end
		obj.GetValues = function()
			return obj.Param1, nil
		end
		
		if obj.setBtn == nil then obj.setBtn = _addon.Frames.StandardButton:Create(
				obj, targetWin.."setBtn", 
				{ BOTTOMRIGHT, obj.Backdrop, BOTTOM, -43, 0 }, 
				80, 14, 
				{0,0,0,0}, 
				{0.2,0.2,0.7,0}, 
				{"", 8, 1, 0}, 
				1, "[Set]", 
				{1,1,1,1}, 
				nil, nil, nil
			)
			obj.setBtn.Backdrop:ClearAnchors()
			obj.setBtn.Backdrop:SetAnchor( BOTTOMRIGHT, obj.Backdrop, BOTTOM, -43, -6 )
			obj.setBtn.Label:SetHorizontalAlignment(_addon.GLOBAL.TextAlign["h"]["center"])
			obj.setBtn.Label:SetVerticalAlignment(_addon.GLOBAL.TextAlign["v"]["top"])
			obj.setBtn.Button:SetHandler("OnClicked", function(self,button) 
				obj.SetValues( _G[targetWin].SelectedName, nil )
				obj.ChildCallback( targetWin )
				obj:MouseOut()
			end )
			obj.setBtn.Button:SetHandler("OnMouseEnter", function() obj.setBtn.Label:SetColor(.5,.6,1,1) end)
			obj.setBtn.Button:SetHandler("OnMouseExit", function() obj.setBtn.Label:SetColor(1,1,1,1) end)
		end
		
		if obj.clearBtn == nil then obj.clearBtn = _addon.Frames.StandardButton:Create(
				obj, targetWin.."clearBtn", 
				{ BOTTOM, obj.Backdrop, BOTTOM, 0, 0 }, 
				80, 14, 
				{0,0,0,0}, 
				{0.2,0.2,0.7,0}, 
				{"", 8, 1, 0}, 
				1, "[Clear]", 
				{1,1,1,1}, 
				nil, nil, nil
			)
			obj.clearBtn.Backdrop:ClearAnchors()
			obj.clearBtn.Backdrop:SetAnchor( BOTTOM, obj.Backdrop, BOTTOM, 0, -6 )
			obj.clearBtn.Label:SetHorizontalAlignment(_addon.GLOBAL.TextAlign["h"]["center"])
			obj.clearBtn.Label:SetVerticalAlignment(_addon.GLOBAL.TextAlign["v"]["top"])
			obj.clearBtn.Button:SetHandler("OnClicked", function(self,button) 
				obj.SetValues( nil, nil )
				obj.ChildCallback( targetWin )
				obj:MouseOut()
			end )
			obj.clearBtn.Button:SetHandler("OnMouseEnter", function() obj.clearBtn.Label:SetColor(.5,.6,1,1) end)
			obj.clearBtn.Button:SetHandler("OnMouseExit", function() obj.clearBtn.Label:SetColor(1,1,1,1) end)
		end
		
		if obj.cancelBtn == nil then obj.cancelBtn = _addon.Frames.StandardButton:Create(
				obj, targetWin.."cancelBtn", 
				{ BOTTOMLEFT, obj.Backdrop, BOTTOM, 43, 0 }, 
				80, 14, 
				{0,0,0,0}, 
				{0.2,0.2,0.7,0}, 
				{"", 8, 1, 0}, 
				1, "[Cancel]", 
				{1,1,1,1}, 
				nil, nil, nil
			)
			obj.cancelBtn.Backdrop:ClearAnchors()
			obj.cancelBtn.Backdrop:SetAnchor( BOTTOMLEFT, obj.Backdrop, BOTTOM, 43, -6 )
			obj.cancelBtn.Label:SetHorizontalAlignment(_addon.GLOBAL.TextAlign["h"]["center"])
			obj.cancelBtn.Label:SetVerticalAlignment(_addon.GLOBAL.TextAlign["v"]["top"])
			obj.cancelBtn.Button:SetHandler("OnClicked", function(self,button) 
				obj.Param1 = obj.Param1Hold
				obj.Param2 = obj.Param2Hold
				obj:MouseOut()
			end )
			obj.cancelBtn.Button:SetHandler("OnMouseEnter", function() obj.cancelBtn.Label:SetColor(.5,.6,1,1) end)
			obj.cancelBtn.Button:SetHandler("OnMouseExit", function() obj.cancelBtn.Label:SetColor(1,1,1,1) end)
		end
		
		if prep then obj:SetHidden(true) end
	else
		if not prep then
			local obj = _G[targetWin]
			if vars ~= nil then
				if table_count(vars) > 0 then
					obj.SetValues( vars.Param1, nil )
				end
			end
			obj:SetHidden(false)
		end
	end
	if prep then _G[targetWin]:SetHidden(true) end
end

local childEditWin1 = function( parent, vars, prep )
	return childEditWin( parent, vars, prep, ChildWin1, "Select a Gear Set", makeScrollSelector1 )
end
local childEditWin2 = function( parent, vars, prep )
	return childEditWin( parent, vars, prep, ChildWin2, "Select a Skill Set", makeScrollSelector2 )
end
local childEditWin3 = function( parent, vars, prep )
	return childEditWin( parent, vars, prep, ChildWin3, "Select an Emote", makeScrollSelector3 )
end

local eRow = function( idx, parent, values, inSettingType, typeText, targetWin, useOutfitter, callBackChildWin, labelPrefix )
	if values == nil then values = {} end
	if parent == nil then return end
	local key = parent:GetName()
	if editRows[key] == nil then editRows[key] = {} end
	local anchor = { TOPLEFT, editRows[key][idx-1], BOTTOMLEFT, 0, 4 }
	if idx == 1 then anchor = { LEFT, parent, TOPLEFT, 6, 70 } end
	if editRows[key][idx] == nil then 
		local baseName = key.."_row"..idx
		editRows[key][idx] = _addon.Frames.__NewTopLevel( baseName )
			:SetParent(parent)
			:SetAnchor(anchor[1], anchor[2], anchor[3], anchor[4], anchor[5])
			:SetWidth(parent:GetWidth()-12)
			:SetHeight(32)
			:SetMouseEnabled(true)
		.__END
		editRows[key][idx].ChildWinInteracted = false
		
		editRows[key][idx].label = _addon.Frames.__Chain( WINDOW_MANAGER:CreateControl( baseName.."Label", editRows[key][idx], CT_LABEL ) )
			:SetDimensions(1, 26)
			:SetAnchor(LEFT, editRows[key][idx], LEFT, 0, 0)
			:SetFont("ZoFontWinH4")
			:SetText(idx)
		.__END
		
		editRows[key][idx].Settings = {}
		editRows[key][idx].Settings.Type = inSettingType
		editRows[key][idx].Settings.Param1 = values.Param1 or -1
		editRows[key][idx].Settings.Param2 = values.Param2 or ""
		
		editRows[key][idx].Type = _addon.Frames.__Chain( WINDOW_MANAGER:CreateControl( baseName.."Type", editRows[key][idx], CT_LABEL ) )
			:SetDimensions(65, 26)
			:SetAnchor(LEFT, editRows[key][idx].label, RIGHT, -12, 0)
			:SetFont("ZoFontWinH4")
			:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
			:SetText(typeText)
			:SetHorizontalAlignment(_addon.GLOBAL.TextAlign["h"]["right"])
			:SetVerticalAlignment(_addon.GLOBAL.TextAlign["v"]["center"])
		.__END
		editRows[key][idx].Type.Value = inSettingType
		editRows[key][idx].Settings.Type = inSettingType
		
		editRows[key][idx].configOver = false
		editRows[key][idx].ConfigButton = _addon.Frames.__NewImage( baseName.."ConfigButton", editRows[key][idx] )
			:SetAnchor( LEFT, editRows[key][idx].Type, RIGHT, 0, -4 )
			:SetTexture( "/esoui/art/buttons/edit_up.dds" )
			:SetDimensions( 32, 32 )
			:SetMouseEnabled(true)
			:SetHandler( "OnMouseEnter", function(self) 
				editRows[key][idx].configOver = true
				self:SetTexture( "/esoui/art/buttons/edit_over.dds" ) 
			end )
			:SetHandler( "OnMouseExit", function(self) 
				editRows[key][idx].configOver = false
				self:SetTexture( "/esoui/art/buttons/edit_up.dds" ) 
			end )
			:SetHandler( "OnMouseDown", function(self) self:SetTexture( "/esoui/art/buttons/edit_down.dds" ) end )
			:SetHandler( "OnMouseUp", function(self) 
				if editRows[key][idx].configOver then
					self:SetTexture( "/esoui/art/buttons/edit_over.dds" ) 
					local nm, parms = "", { Param1 = editRows[key][idx].Settings.Param1, Param2 = editRows[key][idx].Settings.Param2 }
					if (useOutfitter and _G["WYK_Outfitter"] ~= nil) or not useOutfitter then 
						nm = targetWin
						if _G[nm] == nil then callBackChildWin( editRows[key][idx], parms, true ) end
					end
					closeChildWin(ChildWin1, nm)
					closeChildWin(ChildWin2, nm)
					closeChildWin(ChildWin3, nm)
					if _G[nm] ~= nil then
						if _G[nm]:IsHidden() then 
							_G[nm]:ShowMe()
							_G[nm]:ClearAnchors()
							_G[nm]:SetAnchor( TOPLEFT, editRows[key][idx], TOPRIGHT, 8, 0 )
							_G[nm].SetValues(editRows[key][idx].Settings.Param1, editRows[key][idx].Settings.Param2)
							_G[nm].ChildCallback = editRows[key][idx].ChildCallback
						else _G[nm]:CloseMe()  end
					end
				else
					self:SetTexture( "/esoui/art/buttons/edit_up.dds" ) 
				end
			end )
			:SetHidden(false)
		.__END
		
		editRows[key][idx].MessageBG = _addon.Frames.StandardBackdrop:Create( 
			editRows[key][idx], key.."_row"..idx.."MessageBG", 
			{ LEFT, editRows[key][idx].Type, RIGHT, 36, -3 }, 
			140, 24, {0,0,0,1}, {0,0,0,1}, {"", 8, 1, 1}, 
			.7, nil
		)
		editRows[key][idx].MessageBG = editRows[key][idx].MessageBG.Backdrop
		editRows[key][idx].Message = _addon.Frames.StandardLabel:Create(editRows[key][idx], key.."_row"..idx.."Message", 
			{LEFT, editRows[key][idx].MessageBG, LEFT, 3, 0}, 130, 22, 1, "undefined", {.65,.65,.65,.65}, nil)
		editRows[key][idx].Message = editRows[key][idx].Message.Label
		editRows[key][idx].Message:SetWrapMode( TEXT_WRAP_MODE_ELLIPSIS )
		
		editRows[key][idx].SetValues = function( Type, Param1, Param2 )
			local nm = ""
			if (useOutfitter and _G["WYK_Outfitter"] ~= nil) or not useOutfitter then nm = targetWin end
			if nm ~= ChildWin1 and _G[ChildWin1] ~= nil then _G[ChildWin1].SetValues(0, nil) end
			if nm ~= ChildWin2 and _G[ChildWin2] ~= nil then _G[ChildWin2].SetValues(0, nil) end
			if nm ~= ChildWin3 and _G[ChildWin3] ~= nil then _G[ChildWin3].SetValues(0, nil) end
			if _G[nm] ~= nil then _G[nm].SetValues(Param1, Param2) end
			editRows[key][idx].Settings.Type = inSettingType
			editRows[key][idx].Settings.Param1 = Param1 or -1
			editRows[key][idx].Settings.Param2 = Param2
			if editRows[key][idx].Settings.Param1 ~= -1 and editRows[key][idx].Settings.Param1 ~= 0 then
				editRows[key][idx].Message:SetText( labelPrefix..editRows[key][idx].Settings.Param1 )
				editRows[key][idx].Message:SetColor(.65,.65,1,1)
			else
				editRows[key][idx].Message:SetText( "" )
				editRows[key][idx].Message:SetColor(.65,.65,1,1)
			end
		end
		editRows[key][idx].GetValues = function()
			local ret = {}
			ret.Type = inSettingType
			if editRows[key][idx].ChildWinInteracted then
				ret.Param1, ret.Param2 = _G[targetWin].GetValues()
			else
				ret.Param1, ret.Param2 = editRows[key][idx].Settings.Param1, editRows[key][idx].Settings.Param2
			end
			return ret
		end
		editRows[key][idx].ChildCallback = function( nm )
			local a, b = _G[nm].GetValues()
			editRows[key][idx].ChildWinInteracted = true
			editRows[key][idx].Settings.Param1 = a or -1
			editRows[key][idx].Settings.Param2 = b or ""
			
			if editRows[key][idx].Settings.Param1 ~= -1 and editRows[key][idx].Settings.Param1 ~= 0 then
				editRows[key][idx].Message:SetText( labelPrefix..editRows[key][idx].Settings.Param1 )
				editRows[key][idx].Message:SetColor(.65,.65,1,1)
			else
				editRows[key][idx].Message:SetText( "" )
				editRows[key][idx].Message:SetColor(.65,.65,1,1)
			end
		end
		
		local parms = {}
		parms[inSettingType] = { Param1 = editRows[key][idx].Settings.Param1, Param2 = editRows[key][idx].Settings.Param2 }
		
		callBackChildWin(  editRows[key][idx], parms[1], true )
	end
	
	if values ~= nil then
		editRows[key][idx].SetValues( inSettingType, values.Param1 or -1, values.Param2 )
	end
end

local eRow1 = function( idx, parent, values )
	return eRow( idx, parent, values, _addon.G.MACRO_TYPE_GEAR, "GEAR", ChildWin1, true, childEditWin1, "Set: " )
end
local eRow2 = function( idx, parent, values )
	return eRow( idx, parent, values, _addon.G.MACRO_TYPE_SKILL, "SKILLS", ChildWin2, true, childEditWin2, "Set: " )
end
local eRow3 = function( idx, parent, values )
	return eRow( idx, parent, values, _addon.G.MACRO_TYPE_EMOTE, "EMOTE", ChildWin3, false, childEditWin3, "" )
end

local EBox = function(parent, name, text, isMultiLine, getFunc, setFunc, width)
	width = width or 160
	if text == nil then width = width / 2 end
	local editbox = _addon.Frames.__NewTopLevel(name)
		:SetParent(parent)
		:SetAnchor(TOP, parent, BOTTOM, 0, 4)
		:SetResizeToFitDescendents(true)
		:SetWidth(width)
		:SetMouseEnabled(true)
		:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
		:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
	.__END
	editbox.Value = getFunc()
	
	if text ~= nil then
		editbox.label = _addon.Frames.__Chain(WINDOW_MANAGER:CreateControl(name.."Label", editbox, CT_LABEL))
			:SetDimensions(width/2, 26)
			:SetAnchor(TOPLEFT)
			:SetFont("ZoFontWinH4")
			:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
			:SetText(text)
		.__END
	end
	
	editbox.bg = _addon.Frames.__Chain(WINDOW_MANAGER:CreateControlFromVirtual(name.."BG", editbox, "ZO_EditBackdrop"))
		:SetDimensions(width/2,isMultiLine and 100 or 24)
		:SetAnchor(RIGHT)
	.__END
	if text == nil then editbox.bg:SetAnchor(LEFT) end
	
	editbox.edit = _addon.Frames.__Chain(WINDOW_MANAGER:CreateControlFromVirtual(name.."Edit", editbox.bg, isMultiLine and "ZO_DefaultEditMultiLineForBackdrop" or "ZO_DefaultEditForBackdrop"))
		:SetText(editbox.Value)
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

_addon.Macros.Edit = function(idx)
	loadLists()
	
	_addon.Frames.StandardPopup:Create( 
		"wykkydsMacroFrame_EditPopup"..idx, 
		"Edit Macro", 
		_addon.Macros.getPopupAnchor( idx, true ), 240, 
		nil, function()
			closeChildWin(ChildWin1)
			closeChildWin(ChildWin2)
		end, true
	)
	local obj = _G[ "wykkydsMacroFrame_EditPopup"..idx ]

	obj:SetHeight(217)
	
	obj.Title.Label:SetText("Edit Macro "..idx)
	obj.MacroName = _addon.Macros.macroName( idx.."" )
	obj.CommandStack = _addon.Macros.Load( idx )
	if obj.CommandStack then
		obj.Commands = obj.CommandStack.Commands
	else
		obj.Commands = {}
	end
	
	if obj.nameBox == nil then obj.nameBox = EBox(
		obj.Title.Backdrop, 
		"wykkydsMacroFrame_EditPopup_namebox"..idx, "Name", false, 
		function() return _addon.Macros.macroName( obj.MacroName ) end,
		function(val) obj.MacroName = val; end,
		nil
	) end
	obj.nameBox.edit:SetText( obj.MacroName )
	
	local erKey = obj:GetName()

	if editRows[erKey] == nil then editRows[erKey] = {} end
	for x = 1, 3, 1 do
		if editRows[erKey][x] == nil then 
			if x == 1 then eRow1( x, obj, nil, idx ) end
			if x == 2 then eRow2( x, obj, nil, idx ) end
			if x == 3 then eRow3( x, obj, nil, idx ) end
			if editRows[erKey][x] ~= nil then
				if obj.Commands ~= nil then
					if obj.Commands[x] ~= nil then
						editRows[erKey][x].SetValues( obj.Commands[x].Type, obj.Commands[x].Param1, obj.Commands[x].Param2 )
					else
						editRows[erKey][x].SetValues( 0, 0, nil )
					end
				else
					editRows[erKey][x].SetValues( 0, 0, nil )
				end
			end
		else
			if obj.Commands ~= nil then
				if obj.Commands[x] ~= nil then
					editRows[erKey][x].SetValues( obj.Commands[x].Type, obj.Commands[x].Param1, obj.Commands[x].Param2 )
				else
					editRows[erKey][x].SetValues( 0, 0, nil )
				end
			else
				editRows[erKey][x].SetValues( 0, 0, nil )
			end
		end
	end
	
	obj.SaveMacro = function()
		local settings = {}
		settings.Name = obj.nameBox.GetValue()
		settings.Commands = {}
		for x = 1, 3, 1 do settings.Commands[x] = editRows[erKey][x].GetValues(); end
		_addon.Macros.Save( idx, settings )
	end
	
	if obj.saveBtn == nil then obj.saveBtn = _addon.Frames.StandardButton:Create(
			obj, "wykkydsMacroFrame_EditPopup_save", 
			{ BOTTOMRIGHT, obj.Backdrop, BOTTOM, -3, 0 }, 
			80, 14, 
			{0,0,0,0}, 
			{0.2,0.2,0.7,0}, 
			{"", 8, 1, 0}, 
			1, "[Save]", 
			{1,1,1,1}, 
			nil, nil, nil
		)
		obj.saveBtn.Backdrop:ClearAnchors()
		obj.saveBtn.Backdrop:SetAnchor( BOTTOMRIGHT, obj.Backdrop, BOTTOM, -3, -6 )
		obj.saveBtn.Label:SetHorizontalAlignment(_addon.GLOBAL.TextAlign["h"]["center"])
		obj.saveBtn.Label:SetVerticalAlignment(_addon.GLOBAL.TextAlign["v"]["top"])
		obj.saveBtn.Button:SetHandler("OnClicked", function(self,button) 
			obj.SaveMacro()
			obj:MouseOut()
		end )
		obj.saveBtn.Button:SetHandler("OnMouseEnter", function() obj.saveBtn.Label:SetColor(.5,.6,1,1) end)
		obj.saveBtn.Button:SetHandler("OnMouseExit", function() obj.saveBtn.Label:SetColor(1,1,1,1) end)
	end
	if obj.closeBtn == nil then obj.closeBtn = _addon.Frames.StandardButton:Create(
			obj, "wykkydsMacroFrame_EditPopup_close", 
			{ BOTTOMLEFT, obj.Backdrop, BOTTOM, 3, 0 }, 
			80, 14, 
			{0,0,0,0}, 
			{0.2,0.2,0.7,0}, 
			{"", 8, 1, 0}, 
			1, "[Cancel]", 
			{1,1,1,1}, 
			nil, nil, nil
		)
		obj.closeBtn.Backdrop:ClearAnchors()
		obj.closeBtn.Backdrop:SetAnchor( BOTTOMLEFT, obj.Backdrop, BOTTOM, 3, -6 )
		obj.closeBtn.Label:SetHorizontalAlignment(_addon.GLOBAL.TextAlign["h"]["center"])
		obj.closeBtn.Label:SetVerticalAlignment(_addon.GLOBAL.TextAlign["v"]["top"])
		obj.closeBtn.Button:SetHandler("OnClicked", function(self,button) 
			obj:MouseOut()
		end )
		obj.closeBtn.Button:SetHandler("OnMouseEnter", function() obj.closeBtn.Label:SetColor(.5,.6,1,1) end)
		obj.closeBtn.Button:SetHandler("OnMouseExit", function() obj.closeBtn.Label:SetColor(1,1,1,1) end)
	end
	
	obj:SetHidden(false)
end

_addon.Macros.Rename = function( idx )
	_addon.Frames.StandardPopup:Create( 
		"wykkydsMacroFrame_RenamePopup"..idx, 
		"Rename Macro "..idx, 
		_addon.Macros.getPopupAnchor( idx ), 188, 
		nil, function()
		end, true
	)
	local obj = _G["wykkydsMacroFrame_RenamePopup"..idx]

	obj:SetHeight(88)
	obj.MacroName = _addon.Macros.macroName(idx.."")
	if obj.ebx == nil then obj.ebx = EBox(
		obj.Title.Backdrop, 
		"wykkydsMacroFrame_RenamePopup_editbox"..idx, "Name", false, 
		function() return obj.MacroName; end,
		function(val) obj.MacroName = val; end,
		nil
	) end
	
	if obj.saveBtn == nil then obj.saveBtn = _addon.Frames.StandardButton:Create(
			obj, "wykkydsMacroFrame_RenamePopup_save"..idx, 
			{ BOTTOMRIGHT, obj.Backdrop, BOTTOM, -3, 0 }, 
			80, 14, 
			{0,0,0,0}, 
			{0.2,0.2,0.7,0}, 
			{"", 8, 1, 0}, 
			1, "[Save]", 
			{1,1,1,1}, 
			nil, nil, nil
		)
		obj.saveBtn.Backdrop:ClearAnchors()
		obj.saveBtn.Backdrop:SetAnchor( BOTTOMRIGHT, obj.Backdrop, BOTTOM, -3, -6 )
		obj.saveBtn.Label:SetHorizontalAlignment(_addon.GLOBAL.TextAlign["h"]["center"])
		obj.saveBtn.Label:SetVerticalAlignment(_addon.GLOBAL.TextAlign["v"]["top"])
		obj.saveBtn.Button:SetHandler("OnClicked", function(self,button) 
			local val = obj.ebx.GetValue()
			if val ~= nil then _addon.RenameMacro(idx, val) end
			obj:MouseOut()
		end )
		obj.saveBtn.Button:SetHandler("OnMouseEnter", function() obj.saveBtn.Label:SetColor(.5,.6,1,1) end)
		obj.saveBtn.Button:SetHandler("OnMouseExit", function() obj.saveBtn.Label:SetColor(1,1,1,1) end)
	end
	if obj.closeBtn == nil then obj.closeBtn = _addon.Frames.StandardButton:Create(
			obj, "wykkydsMacroFrame_RenamePopup_close"..idx, 
			{ BOTTOMLEFT, obj.Backdrop, BOTTOM, 3, 0 }, 
			80, 14, 
			{0,0,0,0}, 
			{0.2,0.2,0.7,0}, 
			{"", 8, 1, 0}, 
			1, "[Cancel]", 
			{1,1,1,1}, 
			nil, nil, nil
		)
		obj.closeBtn.Backdrop:ClearAnchors()
		obj.closeBtn.Backdrop:SetAnchor( BOTTOMLEFT, obj.Backdrop, BOTTOM, 3, -6 )
		obj.closeBtn.Label:SetHorizontalAlignment(_addon.GLOBAL.TextAlign["h"]["center"])
		obj.closeBtn.Label:SetVerticalAlignment(_addon.GLOBAL.TextAlign["v"]["top"])
		obj.closeBtn.Button:SetHandler("OnClicked", function(self,button) 
			obj:MouseOut()
		end )
		obj.closeBtn.Button:SetHandler("OnMouseEnter", function() obj.closeBtn.Label:SetColor(.5,.6,1,1) end)
		obj.closeBtn.Button:SetHandler("OnMouseExit", function() obj.closeBtn.Label:SetColor(1,1,1,1) end)
	end
	
	local a = _addon.Macros.getPopupAnchor( idx )
	obj:ClearAnchors()
	obj:SetAnchor(a[1], a[2], a[3], a[4], a[5])
	obj:SetHidden(false)
end