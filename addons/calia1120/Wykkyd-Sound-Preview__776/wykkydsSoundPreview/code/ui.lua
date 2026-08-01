local _addon = WYK_SoundPreview

local _slider = function( key, parent, label, minVal, maxVal, stepVal, defaultVal, getfunc, setfunc )
	local sliderData = {
		width = "half",
		tooltip = nil,
		name = label,
		min = minVal,
		max = maxVal,
		step = stepVal,
		warning = nil,
		disabled = false,
		default = defaultVal,
		getFunc = getfunc,
		setFunc = setfunc,
	}
	local elem = LAMCreateControl.slider(parent, sliderData, key)
	local scrollwheel = function(self, delta, ctrl, alt, shift) 
		local value = elem.slider:GetValue()
		if delta > 0 then
			if value < maxVal then
				value = value+1
				elem.slider:SetValue(value)
				elem.slidervalue:SetText(value)
			end
		else
			if value > minVal then
				value = value-1
				elem.slider:SetValue(value)
				elem.slidervalue:SetText(value)
			end
		end
		local ui = _G[_addon.__uiKey]
		if ui then 
			ui.data[key] = value
			ui.loadSoundCommand() 
		end
	end
	elem.label:SetHorizontalAlignment(_addon.GLOBAL.TextAlign["h"]["center"])
	elem.label:SetVerticalAlignment(_addon.GLOBAL.TextAlign["v"]["bottom"])
	elem.slider:ClearAnchors()
	elem.slider:SetAnchor( TOP, elem.label, BOTTOM, 0, 0 )
	elem.label:SetMouseEnabled( true )
	elem.label:SetHandler( "OnMouseWheel", scrollwheel )
	elem.slider:SetHandler( "OnMouseWheel", scrollwheel )
	elem.slidervalue:SetHandler( "OnMouseWheel", scrollwheel )
	elem.scroll = scrollwheel
	return elem
end

local _make = function()
	local w, h = 280, 320
	local key = _addon.__uiKey
	local ui = _addon.Frames.__NewTopLevel( key )
		:SetDimensions( w, h )
		:SetAnchor( CENTER, GuiRoot, CENTER, 0, 0 )
		:SetMovable( false )
		:SetHidden( true )
	.__END
	ui.BG = _addon.Frames.__NewBackdrop( key, ui )
		:SetAnchor( CENTER, ui, CENTER, 0, 0 )
		:SetDimensions( w, h )
		:SetCenterColor( .25, .25, .25, .95 )
		:SetEdgeColor( 0, 0, 0, 1 )
		:SetEdgeTexture( "", 8, 1, 1 )
		:SetAlpha( 1 )
		:SetHidden( true )
	.__END
	ui.Show = function(self)
		self:SetHidden( false )
		self.BG:SetHidden( false )
	end
	ui.Hide = function(self)
		self:SetHidden( true )
		self.BG:SetHidden( true )
	end
	ui.Toggle = function(self)
		local setTo = self:IsHidden()
		self:SetHidden( not setTo )
		self.BG:SetHidden( not setTo )
		ui.RepeatSlider:SetHidden( not setTo )
		ui.VolumeSlider:SetHidden( not setTo )
		ui.SoundSlider:SetHidden( not setTo )
	end
	ui.data = {}
	
	ui.BG.panel = {}		-- to ghost LAM2
	ui.BG.panel.data = {}	-- to ghost LAM2
	
	ui.loadSoundCommand = function() return end
	
	ui.SoundNameBG = WINDOW_MANAGER:CreateControlFromVirtual(nil, ui.BG, "ZO_EditBackdrop")
	ui.SoundNameBG:SetDimensions(w-12, 16)
	ui.SoundNameBG:SetAnchor(TOP, slider, BOTTOM, 0, 0)
	ui.SoundName = WINDOW_MANAGER:CreateControlFromVirtual(nil, ui.SoundNameBG, "ZO_DefaultEditForBackdrop")
	ui.SoundName:ClearAnchors()
	ui.SoundName:SetAnchor(TOPLEFT, ui.SoundNameBG, TOPLEFT, 3, 1)
	ui.SoundName:SetAnchor(BOTTOMRIGHT, ui.SoundNameBG, BOTTOMRIGHT, -3, -1)
	ui.SoundName:SetFont("ZoFontGameSmall")
	ui.SoundName:SetEditEnabled( false )
	
	ui.SoundCommandBG = WINDOW_MANAGER:CreateControlFromVirtual(nil, ui.BG, "ZO_EditBackdrop")
	ui.SoundCommandBG:SetDimensions(w-12, 16)
	ui.SoundCommandBG:SetAnchor(TOP, slider, BOTTOM, 0, 0)
	ui.SoundCommand = WINDOW_MANAGER:CreateControlFromVirtual(nil, ui.SoundCommandBG, "ZO_DefaultEditForBackdrop")
	ui.SoundCommand:ClearAnchors()
	ui.SoundCommand:SetAnchor(TOPLEFT, ui.SoundCommandBG, TOPLEFT, 3, 1)
	ui.SoundCommand:SetAnchor(BOTTOMRIGHT, ui.SoundCommandBG, BOTTOMRIGHT, -3, -1)
	ui.SoundCommand:SetFont("ZoFontGameSmall")
	ui.SoundCommand:SetEditEnabled( false )
	
	ui.SoundSlider = _slider( 
		key.."SoundSlider", ui.BG, "Game Sound Index", 
		1, _addon:GetCountOf( _addon.GLOBAL.GameSounds ), 1, 1,
		function() return ui.data[key.."SoundSlider"] or 1; end,
		function(val) ui.data[key.."SoundSlider"] = val; ui.loadSoundCommand(); end
	)
	
	ui.VolumeSlider = _slider( 
		key.."AdjustVolumeSlider", ui.BG, "IO Volume During Playback", 
		1, 100, 1, 100,
		function() return ui.data[key.."AdjustVolumeSlider"] or 100; end,
		function(val) ui.data[key.."AdjustVolumeSlider"] = val; ui.loadSoundCommand(); end
	)
	
	ui.RepeatSlider = _slider( 
		key.."RepeatSlider", ui.BG, "Repeats", 
		1, 100, 1, 1,
		function() return ui.data[key.."RepeatSlider"] or 1; end,
		function(val) ui.data[key.."RepeatSlider"] = val; ui.loadSoundCommand(); end
	)
	
	ui.SoundSlider:SetAnchor( TOP, ui.BG, TOP, 0, 4 )
	ui.VolumeSlider:SetAnchor( TOP, ui.SoundSlider, BOTTOM, 0, 4 )
	ui.RepeatSlider:SetAnchor( TOP, ui.VolumeSlider, BOTTOM, 0, 4 )
	
	ui.SoundNameBG:ClearAnchors()
	ui.SoundNameBG:SetAnchor( TOP, ui.RepeatSlider, BOTTOM, 0, 12 )
	ui.SoundCommandBG:ClearAnchors()
	ui.SoundCommandBG:SetAnchor( TOP, ui.SoundNameBG, BOTTOM, 0, 12 )
	
	ui.command = function() return end
	
	ui.loadSoundCommand = function()
		local snd = ui.data[key.."SoundSlider"] or 1
		local vol = ui.data[key.."AdjustVolumeSlider"] or 100
		local rpt = ui.data[key.."RepeatSlider"] or 1
		
		ui.command = function() WYK_SoundPreview:PlaySound( {[1]={ix=snd,adj=250}}, vol, rpt ) end
		ui.SoundCommand:SetText( "<addon>:PlaySound( "..snd..", "..vol..", "..rpt.." )" )
		ui.SoundName:SetText( "SOUNDS.".._addon.GLOBAL.GameSoundsByIndex[ snd ] )
	end
	
	local iNormal = "/esoui/art/buttons/right_normal.dds"
	local iDown = "/esoui/art/buttons/right_mousedown.dds"
	local iDisabled = "/esoui/art/buttons/rightarrow_disabled.dds"
	ui.playdisabled = false
	ui.PlayButton = _addon.Frames.__NewTexture( key.."PlayButton", ui.BG )
		:SetDimensions( 64, 64)
		:SetAnchor( TOP, ui.SoundCommandBG, BOTTOM, 0, 12 )
		:SetTexture( iNormal )
		:SetMouseEnabled( true )
		:SetHandler( "OnMouseDown", function(self) 
			if ui.playdisabled then return end 
			self:SetTexture( iDown )
		end )
		:SetHandler( "OnMouseUp", function(self) 
			if ui.playdisabled then return end
			ui.playdisabled = true
			self:SetTexture( iDisabled )
			zo_callLater( function() 
					ui.playdisabled = false
					ui.PlayButton:SetTexture( iNormal )
				end, 
				((ui.data[key.."RepeatSlider"] or 1) * 300)+600
			)
			ui.command(); 
		end )
		:SetHandler( "OnMouseWheel", function(...) ui.SoundSlider.scroll( ... ) end )
	.__END
	
	ui.loadSoundCommand()
	
	return ui
end

function _addon.ui:Create()
	return _G[_addon.__uiKey] or _make()
end

function _addon.ui:Toggle()
	local ui = _addon.ui:Create()
	ui:Toggle()
end

WYK_SoundPreview = _addon