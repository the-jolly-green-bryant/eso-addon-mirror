local _addon = WYK_EnhancedHUD

local _key_playerhud = "wykkydsEnhancedHUD"
local _key_player_hp = "wykkydsEnhancedHUD_PlayerHP"
local _key_player_mg = "wykkydsEnhancedHUD_PlayerMagicka"
local _key_player_st = "wykkydsEnhancedHUD_PlayerStamina"

local isApplied = false
local unadjustedPad = 0

local bars = PLAYER_ATTRIBUTE_BARS
local hp = ZO_PlayerAttributeHealth
local mp = ZO_PlayerAttributeMagicka
local sp = ZO_PlayerAttributeStamina
local ww = ZO_PlayerAttributeWerewolf
local sg = ZO_PlayerAttributeSiegeHealth
local mt = ZO_PlayerAttributeMountStamina
		
_addon.ShowFrames = function()
	if _addon:GetOrDefault( false, _addon.Settings["always_show"] ) then
		SetSetting( SETTING_TYPE_UI, UI_SETTING_FADE_PLAYER_BARS, "0", 1 )
		_addon:OnUpdateCallback( "wykkydsEnhancedHUD_smartshow", function()
			if _addon.Frames.ShouldBeHidden() then
				SetSetting( SETTING_TYPE_UI, UI_SETTING_FADE_PLAYER_BARS, "1", 1 )
			else
				SetSetting( SETTING_TYPE_UI, UI_SETTING_FADE_PLAYER_BARS, "0", 1 )
			end
		end, .25 )
	else
		_addon:OnUpdateCallback( "wykkydsEnhancedHUD_smartshow" )
		SetSetting( SETTING_TYPE_UI, UI_SETTING_FADE_PLAYER_BARS, "1", 1 )
	end
end

_addon.PlayerHUD = function(refresh)
	if not isApplied or refresh then
		isApplied = true

		if _addon:GetOrDefault( false, _addon.Settings["reposition"] ) then
			if unadjustedPad == 0 then
				unadjustedPad = GuiRoot:GetBottom() - hp:GetBottom()
			end

			local bottomPad = unadjustedPad + mt:GetHeight() + 1 + sp:GetHeight() + 2

			if not _G[_key_playerhud] then
				local hud = _addon.Frames.NewTopLevel(_key_playerhud)
			end
			hud = _G[_key_playerhud]
			hud:SetHidden( false )
			hud:SetAnchor( TOP, GuiRoot, BOTTOM, 0, (bottomPad + hp:GetHeight())*-1 )
			hud:SetResizeToFitDescendents()
			hud:SetDimensions( 1000, 400 )
			
			hp:SetParent(hud); sp:SetParent(hud); mp:SetParent(hud); mt:SetParent(hud); ww:SetParent(hud); sg:SetParent(hud)
			hp:ClearAnchors(); sp:ClearAnchors(); mp:ClearAnchors(); mt:ClearAnchors(); ww:ClearAnchors(); sg:ClearAnchors();
			hp:SetHidden(false); sp:SetHidden(false); mp:SetHidden(false); mt:SetHidden(false); ww:SetHidden(false); sg:SetHidden(false)
			hp:SetAnchor( TOP, hud, TOP, 0, 0 )
			sp:SetAnchor( TOPLEFT, hp, BOTTOM, 1, 3 )
			mp:SetAnchor( TOPRIGHT, hp, BOTTOM, -1, 3 )
			mt:SetAnchor( TOPLEFT, sp, BOTTOMLEFT, 0, 2 )
			ww:SetAnchor( BOTTOM, hp, TOP, 0, -3 )
			sg:SetAnchor( BOTTOM, hp, TOP, 0, -3 )
			
			local hudPopUpOffset = (GuiRoot:GetHeight() / 4)
			ZO_Death:ClearAnchors()
			ZO_Death:SetAnchor( TOP, GuiRoot, CENTER, 0, hudPopUpOffset )
			ZO_PlayerToPlayerArea:ClearAnchors()
			ZO_PlayerToPlayerArea:SetAnchor( TOP, GuiRoot, CENTER, 0, hudPopUpOffset )
		end
		
		_addon.ShowFrames()
	
		local getCurrMax = function( pVal, pMax )
			if pVal == nil then pVal = 0 end
			if pMax == nil then pMax = 0 end
			return pVal.." / "..pMax
		end
		local getPercent = function( pVal, pMax )
			if pVal == nil then return "unk" end
			if pMax == nil then return "unk" end
			return _addon:Round((pVal / pMax)*100, 0).."%"
		end
		local getCurrent = function( pVal, pMax )
			if pVal == nil then pVal = 0 end
			return pVal
		end
		local getCurrPrc = function( pVal, pMax )
			if pVal == nil then return "unk" end
			if pMax == nil then return "unk" end
			return pVal.." / "..getPercent( pVal, pMax ).."%"
		end
		local getCurrMaxPrc = function( pVal, pMax )
			if pVal == nil then return "unk" end
			if pMax == nil then return "unk" end
			return getCurrMax( pVal, pMax ).." ("..getPercent( pVal, pMax )..")"
		end
		
		local updateNode = function( node, pVal, pMax )
			if node ~= nil then
				if node.Settings == "Current / Max" then node:SetText( getCurrMax( pVal, pMax ) )
				elseif node.Settings == "Current / Max (%)" then node:SetText( getCurrMaxPrc( pVal, pMax ) )
				elseif node.Settings == "Percent" then node:SetText( getPercent( pVal, pMax ) )
				elseif node.Settings == "Current" then node:SetText( getCurrent( pVal, pMax ) )
				else node:SetText( getCurrPrc( pVal, pMax ) ) end
			end
		end
	
		local updateHealth = function(  )
			local powerValue, _, powerEffectiveMax = GetUnitPower( "player", POWERTYPE_HEALTH )
			updateNode( _G[_key_player_hp], powerValue, powerEffectiveMax )
		end
		local updateMagicka = function(  )
			local powerValue, _, powerEffectiveMax = GetUnitPower( "player", POWERTYPE_MAGICKA )
			updateNode( _G[_key_player_mg], powerValue, powerEffectiveMax )
		end
		local updateStamina = function(  )
			local powerValue, _, powerEffectiveMax = GetUnitPower( "player", POWERTYPE_STAMINA )
			updateNode( _G[_key_player_st], powerValue, powerEffectiveMax )
		end
	--/script d( GetUnitPower( "player", POWERTYPE_STAMINA ) )
		local hasRegistered = false
		local watchInfoEventTrigger = function()
			updateHealth()
			updateStamina()
			updateMagicka()
		end
		
		local startPowerInfo = function( callBack, pType )
			local pVal, pStaticMax, pMax = GetUnitPower( "player", pType )
			if pVal ~= nil and pMax ~= nil then
				callBack( pVal, pMax )
			end
		end

		local hpSetting = _addon:GetOrDefault( "Off", _addon.Settings["player_health"] )
		if hpSetting ~= "Off" then
			local color = _addon:GetOrDefault({r=19/255,g=141/255,b=165/255,a=165/255}, _addon.Settings["player_health_color"])
			local font  = _addon._fontList[_addon:GetOrDefault( "ESO Cartographer", _addon.Settings["player_health_type"] )]
			local style = _addon:GetOrDefault( "outline", _addon.Settings["player_health_style"] )
			local size  = _addon:GetOrDefault( 16, _addon.Settings["player_health_size"] )
			if not hasRegistered then _addon:OnUpdateCallback( "EHUD_EVENT_POWER_UPDATE", watchInfoEventTrigger, .25 ); hasRegistered = true; end
			if not _G[_key_player_hp] then local hpinfo = _addon.Frames.__NewLabel(_key_player_hp, hp)
				:SetFont(string.format( "%s|%d|%s", font, size, style))
				:SetColor(color.r, color.g, color.b, color.a)
				:SetHorizontalAlignment(_addon.GLOBAL.TextAlign["h"]["center"])
				:SetVerticalAlignment(_addon.GLOBAL.TextAlign["v"]["center"])
				:SetText("")
				:SetHidden(false)
				:SetAnchor( CENTER, hp, CENTER, 0, 1 )
			.__END end
			_G[_key_player_hp].Settings = hpSetting
			updateHealth()
		else
			if _G[_key_player_hp] then _G[_key_player_hp]:SetText("") end
		end
		
		local mpSetting = _addon:GetOrDefault( "Off", _addon.Settings["player_magicka"] )
		if mpSetting ~= "Off" then
			local color = _addon:GetOrDefault({r=165/255,g=145/255,b=15/255,a=165/255}, _addon.Settings["player_magicka_color"])
			local font  = _addon._fontList[_addon:GetOrDefault( "ESO Cartographer", _addon.Settings["player_magicka_type"] )]
			local style = _addon:GetOrDefault( "outline", _addon.Settings["player_magicka_style"] )
			local size  = _addon:GetOrDefault( 16, _addon.Settings["player_magicka_size"] )
			if not hasRegistered then _addon:OnUpdateCallback( "EHUD_EVENT_POWER_UPDATE", watchInfoEventTrigger, .25 ); hasRegistered = true; end
			if not _G[_key_player_mg] then local mpinfo = _addon.Frames.__NewLabel(_key_player_mg, mp)
				:SetFont(string.format( "%s|%d|%s", font, size, style))
				:SetColor(color.r, color.g, color.b, color.a)
				:SetHorizontalAlignment(_addon.GLOBAL.TextAlign["h"]["center"])
				:SetVerticalAlignment(_addon.GLOBAL.TextAlign["v"]["center"])
				:SetText("")
				:SetHidden(false)
				:SetAnchor( CENTER, mp, CENTER, 0, 1 )
			.__END end
			_G[_key_player_mg].Settings = mpSetting
			updateMagicka()
		else
			if _G[_key_player_mg] then _G[_key_player_mg]:SetText("") end
		end
		
		local spSetting = _addon:GetOrDefault( "Off", _addon.Settings["player_stamina"] )
		if spSetting ~= "Off" then
			local color = _addon:GetOrDefault({r=200/255,g=40/255,b=8/255,a=165/255}, _addon.Settings["player_stamina_color"])
			local font  = _addon._fontList[_addon:GetOrDefault( "ESO Cartographer", _addon.Settings["player_stamina_type"] )]
			local style = _addon:GetOrDefault( "outline", _addon.Settings["player_stamina_style"] )
			local size  = _addon:GetOrDefault( 16, _addon.Settings["player_stamina_size"] )
			if not hasRegistered then _addon:OnUpdateCallback( "EHUD_EVENT_POWER_UPDATE", watchInfoEventTrigger, .25 ); hasRegistered = true; end
			if not _G[_key_player_st] then local spinfo = _addon.Frames.__NewLabel(_key_player_st, sp)
				:SetFont(string.format( "%s|%d|%s", font, size, style))
				:SetColor(color.r, color.g, color.b, color.a)
				:SetHorizontalAlignment(_addon.GLOBAL.TextAlign["h"]["center"])
				:SetVerticalAlignment(_addon.GLOBAL.TextAlign["v"]["csaenter"])
				:SetText("")
				:SetHidden(false)
				:SetAnchor( CENTER, sp, CENTER, 0, 1 )
			.__END end
			_G[_key_player_st].Settings = spSetting
			updateStamina()
		else
			if _G[_key_player_st] then _G[_key_player_st]:SetText("") end
		end
	end
end