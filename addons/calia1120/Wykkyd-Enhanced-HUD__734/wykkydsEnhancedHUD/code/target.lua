local _addon = WYK_EnhancedHUD

local _key_target_hp = "wykkydsEnhancedHUD_TargetHP"

local isApplied = false
local unadjustedPad = 0

local bars = PLAYER_ATTRIBUTE_BARS
local hp = ZO_PlayerAttributeHealth
local mp = ZO_PlayerAttributeMagicka
local sp = ZO_PlayerAttributeStamina
local ww = ZO_PlayerAttributeWerewolf
local sg = ZO_PlayerAttributeSiegeHealth
local mt = ZO_PlayerAttributeMountStamina

_addon.TargetHUD = function(refresh)
	if not isApplied or refresh then
		isApplied = true
	
		local getCurrMax = function( pVal, pMax )
			if pVal == nil then pVal = 0 end
			if pMax == nil then pMax = 0 end
			return pVal.." / "..pMax
		end
		local getPercent = function( pVal, pMax )
			if pVal == nil then return "unk" end
			if pMax == nil then return "unk" end
			return _addon:Round((pVal / pMax)*100, 0).." %"
		end
		local getCurrent = function( pVal, pMax )
			if pVal == nil then pVal = 0 end
			return pVal
		end
		local getCurrPrc = function( pVal, pMax )
			if pVal == nil then return "unk" end
			if pMax == nil then return "unk" end
			return pVal.." / ".._addon:Round((pVal / pMax)*100, 0).." %"
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
		
		local startPowerInfo = function( callBack, pType )
			local pVal, pStaticMax, pMax = GetUnitPower( "reticleover", pType )
			if pVal ~= nil and pMax ~= nil then
				if pVal ~= 0 and pMax ~= 0 then callBack( _G[_key_target_hp], pVal, pMax )
				else _G[_key_target_hp]:SetText("") end
			end
		end
	
		local hasRegistered = false
		local watchInfoEventTrigger = function( params )
				startPowerInfo( updateNode, POWERTYPE_HEALTH )
		end
	
		local hpSetting = _addon:GetOrDefault( "Off", _addon.Settings["target_health"] )
		if hpSetting ~= "Off" then
			local color = _addon:GetOrDefault( {r=19/255,g=141/255,b=165/255,a=165/255}, _addon.Settings["target_health_color"] )
			local font  = _addon._fontList[_addon:GetOrDefault( "ESO Cartographer", _addon.Settings["target_health_type"] )]
			local style = _addon:GetOrDefault( "outline", _addon.Settings["target_health_style"] )
			local size  = _addon:GetOrDefault( 16, _addon.Settings["target_health_size"] )
			if not hasRegistered then _addon:OnUpdateCallback( "wykkydsEnhancedHUD_updatetic", watchInfoEventTrigger, .25 ) end
			if not _G[_key_target_hp] then local hpinfo = _addon.Frames.__NewLabel(_key_target_hp, ZO_TargetUnitFramereticleover)
				:SetFont(string.format( "%s|%d|%s", font, size, style))
				:SetColor(color.r, color.g, color.b, color.a)
				:SetHorizontalAlignment(_addon.GLOBAL.TextAlign["h"]["center"])
				:SetVerticalAlignment(_addon.GLOBAL.TextAlign["v"]["center"])
				:SetText("")
				:SetHidden(false)
				:SetAnchor( CENTER, ZO_TargetUnitFramereticleover, CENTER, 0, 1 )
			.__END end
			_G[_key_target_hp].Settings = hpSetting
		else
			if _G[_key_target_hp] then _G[_key_target_hp]:SetText("") end
		end
	end
end
