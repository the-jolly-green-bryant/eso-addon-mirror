local _addon = WYK_FullImmersion

_addon.Subtitles.gameTimeStamp = 0

_addon.Subtitles.Draw = function()
	_addon.Subtitles.Create()
	if _addon:GetOrDefault( false, _addon.Settings["subtitles_enabled"] ) then
		_addon:RegisterEvent( EVENT_CHAT_MESSAGE_CHANNEL, _addon.Subtitles.Subtitle )
	else
		_addon:UnregisterEvent( EVENT_CHAT_MESSAGE_CHANNEL )
	end
end

_addon.Subtitles.Create = function()
	local key = "wykkydsSubtitles"
	
	if not _G[key] then 
		local o = _addon.Frames.__NewTopLevel(key)
			:SetDimensions(1000, ((18 * ( _addon:GetOrDefault( 100, _addon.Settings["subtitles_scale"] ) / 100) ) + 2 ) * 3 )
			:SetAnchor( CENTER, GuiRoot, CENTER, _addon:GetOrDefault( 0, _addon.Settings["subtitles_shiftx"] ), _addon:GetOrDefault( 400, _addon.Settings["subtitles_shifty"] ) )
			:SetHidden( not _addon.Settings["subtitles_enabled"] )
			:SetMovable( _addon.Settings["subtitles_moveable"] )
			:SetMouseEnabled( _addon.Settings["subtitles_moveable"] )
		.__END
		wykkydsSubtitles.SetFrameCoords = function(self)
			local addOnX, addOnY = self:GetCenter()
			local guiRootX, guiRootY = GuiRoot:GetCenter()
			local x = addOnX - guiRootX
			local y = addOnY - guiRootY
			if _addon:GetOrDefault( true, _addon.Settings["subtitles_lockhc"] ) then x = 0 end
			_addon.Settings["subtitles_shiftx"] = x
			_addon.Settings["subtitles_shifty"] = y
			if _addon:GetOrDefault( true, _addon.Settings["subtitles_lockhc"] ) then
				self:ClearAnchors()
				self:SetAnchor(CENTER, GuiRoot, CENTER, 0, _addon.Settings["subtitles_shifty"] )
			end
		end
		wykkydsSubtitles.Label = _addon.Frames.__NewLabel(key.."Label", o)
			:SetDimensions(1000, ((18 * (_addon:GetOrDefault( 100, _addon.Settings["subtitles_scale"] ) / 100)) + 2) * 3 )
			:SetFont(string.format( "%s|%d|%s", "EsoUI/Common/Fonts/univers57.otf", 18 * (_addon:GetOrDefault( 100, _addon.Settings["subtitles_scale"] ) / 100), "soft-shadow-thick"))
			:SetColor( .75, .85, 1, 1 )
			:SetText( "Hello, this is a test Subtitles Text Wrap. I'll just keep typing until the text finally wraps for this demonstration. How's your day going? Oh look! It wrapped!" )
			:SetAnchor( CENTER, wykkydsSubtitles, CENTER, 0, 0 )
			:SetHorizontalAlignment(_addon.GLOBAL.TextAlign["h"][string.lower( _addon:GetOrDefault("CENTER", _addon.Settings["subtitles_align"] ) )])
			:SetWrapMode( 1000 )
		.__END
		wykkydsSubtitles.bg = _addon.Frames.__NewBackdrop(key.."BG", o.Label)
			:SetAnchor(TOPLEFT, wykkydsSubtitles.Label, TOPLEFT, -2, -2)
			:SetAnchor(BOTTOMRIGHT, wykkydsSubtitles.Label, BOTTOMRIGHT, 2, 2)
			:SetCenterColor(0.1,0.1,0.1,.33)
			:SetEdgeColor(0,0,0,1)
			:SetEdgeTexture("", 8, 1, 1)
			:SetHidden( not _addon.Settings["subtitles_moveable"] )
		.__END
	end
	wykkydsSubtitles:SetFrameCoords()
	wykkydsSubtitles:SetHandler("OnMoveStop", function(self) wykkydsSubtitles:SetFrameCoords() end)
	wykkydsSubtitles:SetHidden( not _addon.Settings["subtitles_enabled"] )
end
	
_addon.Subtitles.Subtitle = function(eventCode, channel, name, Text)
	if not _addon:GetOrDefault( false, _addon.Settings["subtitles_enabled"] ) then return end
	local namefinal, crap = SplitString("^",name)
	if (channel == CHAT_CHANNEL_MONSTER_EMOTE
	or channel == CHAT_CHANNEL_MONSTER_SAY
	or channel == CHAT_CHANNEL_MONSTER_WHISPER
	or channel == CHAT_CHANNEL_MONSTER_YELL) and type(namefinal) == "string" and type(Text) == "string" then
		wykkydsSubtitles.Label:SetText( namefinal..": "..Text )
		wykkydsSubtitles.Label:SetAlpha(1)
		_addon.Subtitles.gameTimeStamp = GetGameTimeMilliseconds()
	end
end

_addon.Subtitles.SubtitleSpecial = function(Text)
	if _G["wykkydsSubtitles"] == nil then return end
	if not _addon:GetOrDefault( false, _addon.Settings["subtitles_enabled"] ) then return end
	wykkydsSubtitles.Label:SetText( Text )
	wykkydsSubtitles.Label:SetAlpha(1)
	_addon.Subtitles.gameTimeStamp = GetGameTimeMilliseconds()
end

_addon.Subtitles.Update = function()
	if not _addon:GetOrDefault( false, _addon.Settings["subtitles_enabled"] ) then return end
	local duration = _addon:GetOrDefault( 8, _addon.Settings["subtitles_fade"] ) * 1000
	local key = "wykkydsSubtitles"
	local o = _G[key]
	if o == nil then return end
	local gameTime = GetGameTimeMilliseconds()
	local span = gameTime - _addon.Subtitles.gameTimeStamp
	if span < duration then wykkydsSubtitles.Label:SetAlpha( (1 - ( span / duration ) ) ) end
	if ( span >= duration ) then
		wykkydsSubtitles.Label:SetText()
		wykkydsSubtitles.Label:SetAlpha(1)
	end
end

WYK_FullImmersion = _addon