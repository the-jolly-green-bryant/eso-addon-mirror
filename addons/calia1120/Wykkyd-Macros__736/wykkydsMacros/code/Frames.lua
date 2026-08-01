local _addon = WYK_Macros

local keyMap = {}

local firstButtonX, firstButtonY = 0, 2
local winWidth, winHeight = 134, 280
local ctrWidth, ctrHeight = winWidth-4, winHeight-41

local makeMacroButton = function( idx )
	keyMap = _addon.GLOBAL.KeyMap
	local tab = 1
	local c = {.7,.7,.7,1}
	if idx > 12 then tab = 2 end
	if idx > 24 then tab = 3 end
	if idx > 36 then tab = 4 end
	if tab == 1 then c = {.4,.8,1,1} end
	if tab == 2 then c = {.8,.4,1,1} end
	if tab == 3 then c = {1,.4,.4,1} end
	if tab == 4 then c = {.4,1,.4,1} end
	local win = _addon.Macros.Containers[ tab ]
	if win then
		win = win.ctr
		local anchor = {}
		local positionIndex = idx - ((tab - 1) * 12)
		if positionIndex == 1 then anchor = { TOPLEFT, win, TOPLEFT, firstButtonX, firstButtonY }
		elseif positionIndex == 2 then anchor = { TOPLEFT, _addon.Macros.Buttons[ (idx - 1).."" ].Backdrop, TOPRIGHT, 2, 0 }
		else anchor = { TOPLEFT, _addon.Macros.Buttons[ (idx - 2).."" ].Backdrop, BOTTOMLEFT, 0, 2 } end
		if _addon.Macros.Buttons[ idx.."" ] == nil then
			_addon.Macros.Buttons[ idx.."" ] = _addon.Frames.StandardButton:Create(
				win, 
				"wykkydsMacroFrame_macro"..idx, 
				anchor, 
				64, 
				38, 
				{.1,.1,.1,.5}, 
				{0,0,0,1}, 
				{"", 8, 1, 1}, 
				.9, 
				_addon.Macros.macroName(idx..""), 
				{ c[1], c[2], c[3], c[4] }, 
				nil, 
				0, 
				0
			)
			_addon.Macros.Buttons[ idx.."" ].__ButtonIndex = idx
			_addon.Macros.Buttons[ idx.."" ].__TabIndex = tab
			_addon.Macros.Buttons[ idx.."" ].Tip = _addon.Frames.StandardLabel:Create(
				_addon.Macros.Buttons[ idx.."" ].Button, 
				"wykkydsMacroFrame".."_BindTip", 
				{TOP, _addon.Macros.Buttons[ idx.."" ].Button, TOP, 0, 1}, 
				48, 12, 1, 
				"", 
				{ 1, 1, .25, 1 }, nil
			)
			_addon.Macros.Buttons[ idx.."" ].SetKeyTip = function( self )
				local ix = self.__ButtonIndex
				local tb = self.__TabIndex
				local tip = tostring( keyMap[ _addon.Settings.KEYBIND[ "Button"..(ix-((tb-1)*12)) ] ] )
				if tip == "" or tip == "nil" then tip = "<none>" end
				self.Tip.Label:SetText( tip )
			end
			_addon.Macros.Buttons[ idx.."" ].Tip.Label:SetFont(string.format( "%s|%d|%s", "EsoUI/Common/Fonts/univers57.otf", 9, "soft-shadow-thick"))
			_addon.Macros.Buttons[ idx.."" ].Tip.Label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
			_addon.Macros.Buttons[ idx.."" ].Tip.Label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
			_addon.Macros.Buttons[ idx.."" ].Tip.Label:SetHidden( true )
		end
		_addon.Macros.Buttons[ idx.."" ]:SetKeyTip()
		_addon.Macros.Buttons[ idx.."" ].Button:EnableMouseButton(2,true)
		_addon.Macros.Buttons[ idx.."" ].Label:SetHorizontalAlignment(_addon.GLOBAL.TextAlign["h"]["center"])
		_addon.Macros.Buttons[ idx.."" ].Label:SetVerticalAlignment(_addon.GLOBAL.TextAlign["v"]["center"])
		_addon.Macros.Buttons[ idx.."" ].Button:SetHandler( "OnMouseEnter", function(self) 
			_addon.Macros.Buttons[ idx.."" ].Backdrop:SetCenterColor(.3,.3,.3,.5)
			wykkydsMacroFrame.OverButton = idx
			wykkydsMacroFrame:MouseIn() 
		end)
		_addon.Macros.Buttons[ idx.."" ].Button:SetHandler( "OnMouseExit", function(self) 
			_addon.Macros.Buttons[ idx.."" ].Backdrop:SetCenterColor(.1,.1,.1,.5)
			if wykkydsMacroFrame.OverButton == idx then wykkydsMacroFrame.OverButton = nil end
			wykkydsMacroFrame:MouseOut() 
		end)
		_addon.Macros.Buttons[ idx.."" ].Button:SetHandler( "OnClicked", function(self, button) 
			if button == 1 then wykkydsMacroFrame.HideMacroFrame(); _addon.MacroButton(idx); return; end
			for w = 1, _addon.Macros.MaxMacros, 1 do
				local ww = _G["wykkydsMacroFrame_RenamePopup"..w]
				if ww ~= nil then ww:CloseMe() end
				ww = _G["wykkydsMacroFrame_EditPopup"..w]
				if ww ~= nil then ww:CloseMe() end
			end
			local popAnchor = _addon.Macros.getPopupAnchor( idx )
			_addon.Frames.StandardPopup:Create( 
				"wykkydsMacroFrame_popup", 
				nil, 
				popAnchor, 136, 
				{
					[1] = {
						name = "Edit Macro",
						onClick = function(self,button,index) _addon.Macros.Edit(index) end,
						params = idx
					},
					[2] = {
						name = "Rename Macro",
						onClick = function(self,button,index) _addon.Macros.Rename(index) end,
						params = idx
					},
					[3] = {
						name = "Clear Macro",
						onClick = function() _addon.ClearMacro(idx.."") end,
						params = idx
					}
				} 
			)
		end)
	end
end

local macroTab = function( idx )
	local containerKey = "wykkydsMacroFrame_tab"..idx.."_container"
	local buttonKey = "wykkydsMacroFrame_tab"..idx.."_button"
	    
	local anchor = {}
	if idx == 1 then anchor = { TOPLEFT, wykkydsMacroFrame.Backdrop, TOPLEFT, 2, 18 }
	else anchor = { LEFT, _addon.Macros.Containers[ idx-1 ].btn.Backdrop, RIGHT, 2, 0 }
	end
	
	local ctr = _G[containerKey]
	if ctr == nil then ctr = _addon.Frames.StandardBackdrop:Create(
			wykkydsMacroFrame.Backdrop, 
			containerKey, 
			{ TOP, wykkydsMacroFrame.Backdrop, TOP, 0, 38 }, 
			ctrWidth, ctrHeight, 
			{0,0,0,0}, 
			{0,0,0,0}, 
			{"", 8, 1, 0}, 
			1, 
			nil
		)
	end
	
	_addon.Macros.Containers[ idx ] = {}
	_addon.Macros.Containers[ idx ].ctr = ctr.Backdrop
	
	local btn = _G[buttonKey]
	if btn == nil then btn = _addon.Frames.StandardButton:Create(
			wykkydsMacroFrame.Backdrop, 
			buttonKey, 
			anchor, 
			31, 
			20, 
			{0,0,.2,1}, 
			{.7,.7,.7,.5}, 
			{"", 8, 1, 1}, 
			.9, 
			(idx..""), 
			{.7,.7,.7,1}, 
			nil, 
			0, 
			0
		) 
	end
	btn.Label:SetHorizontalAlignment(_addon.GLOBAL.TextAlign["h"]["center"])
	btn.Label:SetVerticalAlignment(_addon.GLOBAL.TextAlign["v"]["center"])
	btn.Label:SetScale(.85)
	btn.Label:SetAnchor( CENTER, btn.Backdrop, CENTER, 0, -2 )
	
	_addon.Macros.Containers[ idx ].btn = btn
end

_addon.MacroFrame = function(keystroke)
	if _addon.Settings.KEYBIND == nil then _addon.Settings.KEYBIND = {} end
	local key = "wykkydsMacroFrame"
	if not _G[key] then
		_addon.Frames.StandardWindow:Create( key, "Wykkyd's Macros", true, true, _addon.Settings, winWidth, winHeight, 1 )
		
		local bindTip = {}
		
		if _addon:GetOrDefault( false, _addon.Settings["keyboard_intercept"] ) then
		
			bindTip = _addon.Frames.StandardLabel:Create(wykkydsMacroFrame.Backdrop, "wykkydsMacroFrame".."_BindTip", {TOP, wykkydsMacroFrame, BOTTOM, 0, 0}, wykkydsMacroFrame.Backdrop:GetWidth(), 22, 1, "Hold CTRL to Keybind", { 1, 1, .25, 1 }, nil)
			bindTip.Label:SetFont(string.format( "%s|%d|%s", "EsoUI/Common/Fonts/univers57.otf", 13, "soft-shadow-thick"))
			bindTip.Label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
			bindTip.Label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
			
			wykkydsMacroFrame.ExitTip = _addon.Frames.StandardLabel:Create(
				wykkydsMacroFrame.Backdrop, 
				"wykkydsMacroFrame".."_ExitTip", 
				{TOPLEFT, wykkydsMacroFrame.Backdrop, TOPRIGHT, 2, 2}, 
				60, 12, 1, 
				"Exit Window:", 
				{ 1, 1, .6, 1 }, nil
			)
			wykkydsMacroFrame.ExitTip.Label:SetFont(string.format( "%s|%d|%s", "EsoUI/Common/Fonts/univers57.otf", 9, "soft-shadow-thick"))
			wykkydsMacroFrame.ExitTip.Label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
			wykkydsMacroFrame.ExitTip.Label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
			wykkydsMacroFrame.ExitTip.Label:SetHidden( true )
			
			wykkydsMacroFrame.ExitTipTip = _addon.Frames.StandardLabel:Create(
				wykkydsMacroFrame.ExitTip.Label, 
				"wykkydsMacroFrame".."_ExitTipTip", 
				{LEFT, wykkydsMacroFrame.ExitTip.Label, RIGHT, 2, 0}, 
				60, 12, 1, 
				"ESC", 
				{ 1, 1, .25, 1 }, nil
			)
			wykkydsMacroFrame.ExitTipTip.Label:SetFont(string.format( "%s|%d|%s", "EsoUI/Common/Fonts/univers57.otf", 9, "soft-shadow-thick"))
			wykkydsMacroFrame.ExitTipTip.Label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
			wykkydsMacroFrame.ExitTipTip.Label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
			
			wykkydsMacroFrame.ReloadTip = _addon.Frames.StandardLabel:Create(
				wykkydsMacroFrame.ExitTip.Label, 
				"wykkydsMacroFrame".."_ReloadTip", 
				{TOPLEFT, wykkydsMacroFrame.ExitTip.Label, BOTTOMLEFT, 0, 2}, 
				60, 12, 1, 
				"Reload UI:", 
				{ 1, 1, .6, 1 }, nil
			)
			wykkydsMacroFrame.ReloadTip.Label:SetFont(string.format( "%s|%d|%s", "EsoUI/Common/Fonts/univers57.otf", 9, "soft-shadow-thick"))
			wykkydsMacroFrame.ReloadTip.Label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
			wykkydsMacroFrame.ReloadTip.Label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
			
			wykkydsMacroFrame.ReloadTipTip = _addon.Frames.StandardLabel:Create(
				wykkydsMacroFrame.ReloadTip.Label, 
				"wykkydsMacroFrame".."_ReloadTipip", 
				{LEFT, wykkydsMacroFrame.ReloadTip.Label, RIGHT, 2, 0}, 
				60, 12, 1, 
				"F1", 
				{ 1, 1, .25, 1 }, nil
			)
			wykkydsMacroFrame.ReloadTipTip.Label:SetFont(string.format( "%s|%d|%s", "EsoUI/Common/Fonts/univers57.otf", 9, "soft-shadow-thick"))
			wykkydsMacroFrame.ReloadTipTip.Label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
			wykkydsMacroFrame.ReloadTipTip.Label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
			
			wykkydsMacroFrame.CloseTip = _addon.Frames.StandardLabel:Create(
				wykkydsMacroFrame.ExitTip.Label, 
				"wykkydsMacroFrame".."_CloseTip", 
				{TOPLEFT, wykkydsMacroFrame.ReloadTip.Label, BOTTOMLEFT, 0, 2}, 
				60, 12, 1, 
				"Close Button:", 
				{ 1, 1, .6, 1 }, nil
			)
			wykkydsMacroFrame.CloseTip.Label:SetFont(string.format( "%s|%d|%s", "EsoUI/Common/Fonts/univers57.otf", 9, "soft-shadow-thick"))
			wykkydsMacroFrame.CloseTip.Label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
			wykkydsMacroFrame.CloseTip.Label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
			
			wykkydsMacroFrame.CloseTipTip = _addon.Frames.StandardLabel:Create(
				wykkydsMacroFrame.CloseTip.Label, 
				"wykkydsMacroFrame".."_CloseTipTip", 
				{LEFT, wykkydsMacroFrame.CloseTip.Label, RIGHT, 2, 0}, 
				60, 12, 1, 
				"", 
				{ 1, 1, .25, 1 }, nil
			)
			wykkydsMacroFrame.CloseTipTip.SetKeyTip = function( self )
				local tip = tostring( keyMap[ _addon.Settings.KEYBIND[ "CloseButton" ] ] )
				if tip == "" or tip == "nil" then tip = "<none>" end
				self.Label:SetText( tip )
			end
			wykkydsMacroFrame.CloseTipTip:SetKeyTip()
			wykkydsMacroFrame.CloseTipTip.Label:SetFont(string.format( "%s|%d|%s", "EsoUI/Common/Fonts/univers57.otf", 9, "soft-shadow-thick"))
			wykkydsMacroFrame.CloseTipTip.Label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
			wykkydsMacroFrame.CloseTipTip.Label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
			
			wykkydsMacroFrame.Tab1Tip = _addon.Frames.StandardLabel:Create(
				wykkydsMacroFrame.ExitTip.Label, 
				"wykkydsMacroFrame".."_Tab1Tip", 
				{TOPLEFT, wykkydsMacroFrame.CloseTip.Label, BOTTOMLEFT, 0, 2}, 
				60, 12, 1, 
				"Tab 1:", 
				{ 1, 1, .6, 1 }, nil
			)
			wykkydsMacroFrame.Tab1Tip.Label:SetFont(string.format( "%s|%d|%s", "EsoUI/Common/Fonts/univers57.otf", 9, "soft-shadow-thick"))
			wykkydsMacroFrame.Tab1Tip.Label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
			wykkydsMacroFrame.Tab1Tip.Label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
			
			wykkydsMacroFrame.Tab1TipTip = _addon.Frames.StandardLabel:Create(
				wykkydsMacroFrame.Tab1Tip.Label, 
				"wykkydsMacroFrame".."_Tab1TipTip", 
				{LEFT, wykkydsMacroFrame.Tab1Tip.Label, RIGHT, 2, 0}, 
				60, 12, 1, 
				"", 
				{ 1, 1, .25, 1 }, nil
			)
			wykkydsMacroFrame.Tab1TipTip.SetKeyTip = function( self )
				local tip = tostring( keyMap[ _addon.Settings.KEYBIND[ "Tab1" ] ] )
				if tip == "" or tip == "nil" then tip = "<none>" end
				self.Label:SetText( tip )
			end
			wykkydsMacroFrame.Tab1TipTip:SetKeyTip()
			wykkydsMacroFrame.Tab1TipTip.Label:SetFont(string.format( "%s|%d|%s", "EsoUI/Common/Fonts/univers57.otf", 9, "soft-shadow-thick"))
			wykkydsMacroFrame.Tab1TipTip.Label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
			wykkydsMacroFrame.Tab1TipTip.Label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
			
			wykkydsMacroFrame.Tab2Tip = _addon.Frames.StandardLabel:Create(
				wykkydsMacroFrame.ExitTip.Label, 
				"wykkydsMacroFrame".."_Tab2Tip", 
				{TOPLEFT, wykkydsMacroFrame.Tab1Tip.Label, BOTTOMLEFT, 0, 2}, 
				60, 12, 1, 
				"Tab 1:", 
				{ 1, 1, .6, 1 }, nil
			)
			wykkydsMacroFrame.Tab2Tip.Label:SetFont(string.format( "%s|%d|%s", "EsoUI/Common/Fonts/univers57.otf", 9, "soft-shadow-thick"))
			wykkydsMacroFrame.Tab2Tip.Label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
			wykkydsMacroFrame.Tab2Tip.Label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
			
			wykkydsMacroFrame.Tab2TipTip = _addon.Frames.StandardLabel:Create(
				wykkydsMacroFrame.Tab2Tip.Label, 
				"wykkydsMacroFrame".."_Tab2TipTip", 
				{LEFT, wykkydsMacroFrame.Tab2Tip.Label, RIGHT, 2, 0}, 
				60, 12, 1, 
				"", 
				{ 1, 1, .25, 1 }, nil
			)
			wykkydsMacroFrame.Tab2TipTip.SetKeyTip = function( self )
				local tip = tostring( keyMap[ _addon.Settings.KEYBIND[ "Tab2" ] ] )
				if tip == "" or tip == "nil" then tip = "<none>" end
				self.Label:SetText( tip )
			end
			wykkydsMacroFrame.Tab2TipTip:SetKeyTip()
			wykkydsMacroFrame.Tab2TipTip.Label:SetFont(string.format( "%s|%d|%s", "EsoUI/Common/Fonts/univers57.otf", 9, "soft-shadow-thick"))
			wykkydsMacroFrame.Tab2TipTip.Label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
			wykkydsMacroFrame.Tab2TipTip.Label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
			
			wykkydsMacroFrame.Tab3Tip = _addon.Frames.StandardLabel:Create(
				wykkydsMacroFrame.ExitTip.Label, 
				"wykkydsMacroFrame".."_Tab3Tip", 
				{TOPLEFT, wykkydsMacroFrame.Tab2Tip.Label, BOTTOMLEFT, 0, 2}, 
				60, 12, 1, 
				"Tab 1:", 
				{ 1, 1, .6, 1 }, nil
			)
			wykkydsMacroFrame.Tab3Tip.Label:SetFont(string.format( "%s|%d|%s", "EsoUI/Common/Fonts/univers57.otf", 9, "soft-shadow-thick"))
			wykkydsMacroFrame.Tab3Tip.Label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
			wykkydsMacroFrame.Tab3Tip.Label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
			
			wykkydsMacroFrame.Tab3TipTip = _addon.Frames.StandardLabel:Create(
				wykkydsMacroFrame.Tab3Tip.Label, 
				"wykkydsMacroFrame".."_Tab3TipTip", 
				{LEFT, wykkydsMacroFrame.Tab3Tip.Label, RIGHT, 2, 0}, 
				60, 12, 1, 
				"", 
				{ 1, 1, .25, 1 }, nil
			)
			wykkydsMacroFrame.Tab3TipTip.SetKeyTip = function( self )
				local tip = tostring( keyMap[ _addon.Settings.KEYBIND[ "Tab3" ] ] )
				if tip == "" or tip == "nil" then tip = "<none>" end
				self.Label:SetText( tip )
			end
			wykkydsMacroFrame.Tab3TipTip:SetKeyTip()
			wykkydsMacroFrame.Tab3TipTip.Label:SetFont(string.format( "%s|%d|%s", "EsoUI/Common/Fonts/univers57.otf", 9, "soft-shadow-thick"))
			wykkydsMacroFrame.Tab3TipTip.Label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
			wykkydsMacroFrame.Tab3TipTip.Label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
			
			wykkydsMacroFrame.Tab4Tip = _addon.Frames.StandardLabel:Create(
				wykkydsMacroFrame.ExitTip.Label, 
				"wykkydsMacroFrame".."_Tab4Tip", 
				{TOPLEFT, wykkydsMacroFrame.Tab3Tip.Label, BOTTOMLEFT, 0, 2}, 
				60, 12, 1, 
				"Tab 1:", 
				{ 1, 1, .6, 1 }, nil
			)
			wykkydsMacroFrame.Tab4Tip.Label:SetFont(string.format( "%s|%d|%s", "EsoUI/Common/Fonts/univers57.otf", 9, "soft-shadow-thick"))
			wykkydsMacroFrame.Tab4Tip.Label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
			wykkydsMacroFrame.Tab4Tip.Label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
			
			wykkydsMacroFrame.Tab4TipTip = _addon.Frames.StandardLabel:Create(
				wykkydsMacroFrame.Tab4Tip.Label, 
				"wykkydsMacroFrame".."_Tab4TipTip", 
				{LEFT, wykkydsMacroFrame.Tab4Tip.Label, RIGHT, 2, 0}, 
				60, 12, 1, 
				"", 
				{ 1, 1, .25, 1 }, nil
			)
			wykkydsMacroFrame.Tab4TipTip.SetKeyTip = function( self )
				local tip = tostring( keyMap[ _addon.Settings.KEYBIND[ "Tab4" ] ] )
				if tip == "" or tip == "nil" then tip = "<none>" end
				self.Label:SetText( tip )
			end
			wykkydsMacroFrame.Tab4TipTip:SetKeyTip()
			wykkydsMacroFrame.Tab4TipTip.Label:SetFont(string.format( "%s|%d|%s", "EsoUI/Common/Fonts/univers57.otf", 9, "soft-shadow-thick"))
			wykkydsMacroFrame.Tab4TipTip.Label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
			wykkydsMacroFrame.Tab4TipTip.Label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
		
		end
		
		macroTab( 1 )
		macroTab( 2 )
		macroTab( 3 )
		macroTab( 4 )
		
		for b = 1, _addon.Macros.MaxMacros, 1 do makeMacroButton( b ) end
		
		local tabToShow = _addon.Settings["lastTab"] or 1
		
		local hideAllTabs = function()
			for idx = 1, 4, 1 do
				if _addon.Macros.Containers[ idx ] then
					if _addon.Macros.Containers[ idx ].ctr then
						_addon.Macros.Containers[ idx ].ctr:SetHidden( true )
					end
					if _addon.Macros.Containers[ idx ].btn then
						_addon.Macros.Containers[ idx ].btn.Label:SetColor(.7,.7,.7,1)
						_addon.Macros.Containers[ idx ].btn.Backdrop:SetCenterColor(.3,.3,.3,.5)
					end
				end
			end
		end
		local showTab = function( idx )
			_addon.Settings["lastTab"] = idx
			hideAllTabs()
			if _addon.Macros.Containers[ idx ] then
				if _addon.Macros.Containers[ idx ].ctr then
					_addon.Macros.Containers[ idx ].ctr:SetHidden( false )
				end
				if _addon.Macros.Containers[ idx ].btn then
					_addon.Macros.Containers[ idx ].btn.Label:SetColor(.8,1,.8,1)
					_addon.Macros.Containers[ idx ].btn.Backdrop:SetCenterColor(.5,.5,1,.5)
				end
			end
		end
		
		showTab( tabToShow )
		
		for idx = 1, 4, 1 do
			if _addon.Macros.Containers[ idx ] then
				if _addon.Macros.Containers[ idx ].btn then
					_addon.Macros.Containers[ idx ].btn.Label:SetHorizontalAlignment(_addon.GLOBAL.TextAlign["h"]["center"])
					_addon.Macros.Containers[ idx ].btn.Label:SetVerticalAlignment(_addon.GLOBAL.TextAlign["v"]["center"])
					_addon.Macros.Containers[ idx ].btn.Button:SetHandler( "OnMouseEnter", function(self) wykkydsMacroFrame.OverTabButton = idx; wykkydsMacroFrame:MouseIn() end)
					_addon.Macros.Containers[ idx ].btn.Button:SetHandler( "OnMouseExit", function(self) if wykkydsMacroFrame.OverTabButton == idx then wykkydsMacroFrame.OverTabButton = nil end; wykkydsMacroFrame:MouseOut() end)
					_addon.Macros.Containers[ idx ].btn.Button:SetHandler( "OnClicked", function(self) showTab( idx ) end)
				end
			end
		end
		
		if _addon.Settings["Settings"] == nil then _addon.Settings["Settings"] = {} end
		if _addon.Settings["Settings"].Hidden == nil then _addon.Settings["Settings"].Hidden = true end
		if _addon.Settings["Shown"] == nil then _addon.Settings["Shown"] = false end
			
		_addon.Settings["Settings"].Hidden = ( not _addon.Settings["Shown"] );
		wykkydsMacroFrame.Backdrop:SetHidden( not _addon.Settings["Shown"] )
		
		_G[key].HideMacroFrame = function()
			SetGameCameraUIMode( false )
			wykkydsMacroFrame:SetHidden(true)
			wykkydsMacroFrame.Backdrop:SetHidden(true)
			_addon.Settings["Shown"] = false
			_addon.Settings["Settings"].Hidden = true
			_addon:OnUpdateCallback( "macro_frame_force_mouse"  )
			return
		end
		
		_G[key].CloseButton:SetHandler( "OnMouseUp", function(self) _G[key].HideMacroFrame(); self:SetTexture( "/esoui/art/buttons/clearslot_up.dds" ); end )
		_G[key].CloseButton:SetHandler( "OnMouseEnter", function(self) wykkydsMacroFrame.OverCloseButton = true; end)
		_G[key].CloseButton:SetHandler( "OnMouseExit", function(self) wykkydsMacroFrame.OverCloseButton = false; end)
		
		if _addon:GetOrDefault( false, _addon.Settings["keyboard_intercept"] ) then
		
			_G[key].Backdrop:SetKeyboardEnabled(true)
			_G[key].Backdrop:SetHandler("OnKeyDown", function(event, stroke, ctrl, alt, shift)
				if stroke == KEY_CTRL then
					bindTip.Label:SetText( "Mouseover & tap key" )
					for xxx = 1, 48, 1 do
						_addon.Macros.Buttons[ xxx.."" ].Tip.Label:SetHidden( false )
					end
					wykkydsMacroFrame.ExitTip.Label:SetHidden( false )
				end
			end)
			_G[key].Backdrop:SetHandler("OnKeyUp", function(event, stroke, ctrl, alt, shift)
				if stroke == KEY_ESCAPE or stroke == KEY_ALT or stroke == KEY_ENTER or alt then
					wykkydsMacroFrame.HideMacroFrame()
					return
				end
				if stroke == KEY_CTRL then
					bindTip.Label:SetText( "Hold CTRL to Keybind" )
					for xxx = 1, 48, 1 do
						_addon.Macros.Buttons[ xxx.."" ].Tip.Label:SetHidden( true )
					end
					wykkydsMacroFrame.ExitTip.Label:SetHidden( true )
				end
				local activeTab = _addon.Settings["lastTab"] or 1
				if stroke == KEY_F1 then ReloadUI() end
				if ctrl and keyMap[stroke] ~= nil then
					if wykkydsMacroFrame.OverTabButton ~= nil then
						_addon.Settings.KEYBIND["Tab"..wykkydsMacroFrame.OverTabButton] = stroke
						_addon:Print("|c610B0B[Macros]"..LWF4_DEFAULT_CHAT_COLOR.."  Tab "..wykkydsMacroFrame.OverTabButton.." is now bound to: "..keyMap[stroke] )
						wykkydsMacroFrame.Tab1TipTip:SetKeyTip()
						wykkydsMacroFrame.Tab2TipTip:SetKeyTip()
						wykkydsMacroFrame.Tab3TipTip:SetKeyTip()
						wykkydsMacroFrame.Tab4TipTip:SetKeyTip()
						return
					end
					if wykkydsMacroFrame.OverButton ~= nil then
						local btn = 0
						local kkey = wykkydsMacroFrame.OverButton
						btn = kkey-(12*(activeTab-1))
						_addon.Settings.KEYBIND["Button"..btn] = stroke
						_addon:Print("|c610B0B[Macros]"..LWF4_DEFAULT_CHAT_COLOR.."  Button "..btn.." of the active tab is now bound to: "..keyMap[stroke] )
						for xxx = 1, 48, 1 do
							_addon.Macros.Buttons[ xxx.."" ]:SetKeyTip()
						end
						return
					end
					if wykkydsMacroFrame.OverCloseButton then
						_addon.Settings.KEYBIND["CloseButton"] = stroke
						_addon:Print("|c610B0B[Macros]"..LWF4_DEFAULT_CHAT_COLOR.."  Close Button is now bound to: "..keyMap[stroke] )
						wykkydsMacroFrame.CloseTipTip:SetKeyTip()
					end
					return
				end
				if _addon.Settings.KEYBIND["CloseButton"] then
					if _addon.Settings.KEYBIND["CloseButton"] == stroke then
						wykkydsMacroFrame.HideMacroFrame()
						return
					end
				end
				for ix = 1, 4, 1 do if _addon.Settings.KEYBIND["Tab"..ix] == stroke then showTab( ix ); return; end end
				for ix = 1, 12, 1 do 
					if _addon.Settings.KEYBIND["Button"..ix] == stroke then 
						_addon.MacroButton( ix+(12*(activeTab-1)) ); _G[key].HideMacroFrame(); return; end 
				end
			end)

		end
		
		if keystroke then 
			if _G[key].Backdrop:IsHidden() and not IsUnitInCombat("player") then 
				SetGameCameraUIMode( true )
				_addon:OnUpdateCallback( "macro_frame_force_mouse", function() SetGameCameraUIMode( true ) end, .01 )
				_G[key]:SetHidden(false); 
				_G[key].Backdrop:SetHidden(false); 
				_addon.Settings["Shown"] = true; 
				_addon.Settings["Settings"].Hidden = false;
			else _G[key].HideMacroFrame()
			end
		else _G[key].HideMacroFrame()
		end
	else
		if keystroke then
			if _G[key].Backdrop:IsHidden() and not IsUnitInCombat("player") then 
				SetGameCameraUIMode( true )
				_addon:OnUpdateCallback( "macro_frame_force_mouse", function() SetGameCameraUIMode( true ) end, .01 )
				_G[key]:SetHidden(false); 
				_G[key].Backdrop:SetHidden(false); 
				_addon.Settings["Shown"] = true; 
				_addon.Settings["Settings"].Hidden = false;
			else _G[key].HideMacroFrame()
			end
		else _G[key].HideMacroFrame()
		end
	end
	if _G[key].Backdrop:IsHidden() == false then
		SetGameCameraUIMode( true )
	end
end