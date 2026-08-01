local _addon = WYK_FullImmersion

local registeredForEvents = false
local startedWielding = false
local waitSheath = 0
local bufferName = "_addon.AutoSheath_delaytoggle"

_addon.AutoSheath.BeginCastCallback = function( params )
	if params.unitTag == "player" then
		_addon.AutoSheath.ShouldBeWielding()
	end
end
_addon.AutoSheath.ShouldBeWielding = function()
	startedWielding = true; waitSheath = 2.5
end
_addon.AutoSheath.EventCausedSheath = function()
	startedWielding = false; waitSheath = 0
end
_addon.AutoSheath.EventCausedUnSheath = function()
	startedWielding = true; waitSheath = 2.5
end
_addon.AutoSheath.FinishWielding = function()
	if not IsUnitInCombat( "player" ) and waitSheath ~= 0 then
		if _addon:BufferPause( bufferName, waitSheath ) then
			if startedWielding then TogglePlayerWield(); waitSheath = 0; startedWielding = false; end
		end
	end
end
_addon.AutoSheath.CombatStateChange = function( params )
	if not params.inCombat then
		_addon.AutoSheath.FinishWielding()
	end
end

_addon.AutoSheath.Enable = function()
	if not registeredForEvents then		
		_addon:RegisterEvent( EVENT_BEGIN_LOCKPICK, _addon.AutoSheath.EventCausedSheath, true )
		_addon:RegisterEvent( EVENT_CHATTER_BEGIN, _addon.AutoSheath.EventCausedSheath, true )
		_addon:RegisterEvent( EVENT_OPEN_BANK, _addon.AutoSheath.EventCausedSheath, true )
		_addon:RegisterEvent( EVENT_OPEN_GUILD_BANK, _addon.AutoSheath.EventCausedSheath, true )
		_addon:RegisterEvent( EVENT_OPEN_HOOK_POINT_STORE, _addon.AutoSheath.EventCausedSheath, true )
		_addon:RegisterEvent( EVENT_OPEN_STORE, _addon.AutoSheath.EventCausedSheath, true )
		_addon:RegisterEvent( EVENT_OPEN_TRADING_HOUSE, _addon.AutoSheath.EventCausedSheath, true )
		_addon:RegisterEvent( EVENT_TRADE_INVITE_ACCEPTED, _addon.AutoSheath.EventCausedSheath, true )
		
		_addon:RegisterEvent( EVENT_LOCAL_PLAYER_ABILITY_OCCURED, _addon.AutoSheath.EventCausedUnSheath, true )
		_addon:RegisterEvent( EVENT_LOCAL_PLAYER_KICKOFF_CAST, _addon.AutoSheath.EventCausedUnSheath, true )
		
		_addon:RegisterEvent( EVENT_BEGIN_CAST, _addon.AutoSheath.BeginCastCallback, true )
		_addon:RegisterEvent( EVENT_DELAY_CAST, _addon.AutoSheath.BeginCastCallback, true )
		
		_addon:RegisterEvent( EVENT_END_CAST, _addon.AutoSheath.ShouldBeWielding, true )
		_addon:RegisterEvent( EVENT_LOCAL_PLAYER_WEAPON_ABILITY_WAIT_END, _addon.AutoSheath.ShouldBeWielding, true )
		_addon:RegisterEvent( EVENT_LOCAL_PLAYER_CHARGEUP_COMPLETE, _addon.AutoSheath.ShouldBeWielding, true )
						
		_addon:OnUpdateCallback( "_addon.AutoSheath_watch", _addon.AutoSheath.FinishWielding, .1 )
		
		registeredForEvents = true
	end
end
_addon.AutoSheath.Disable = function()
	if registeredForEvents then
		_addon:RegisterEvent( EVENT_BEGIN_LOCKPICK, nil, true )
		_addon:RegisterEvent( EVENT_CHATTER_BEGIN, nil, true )
		_addon:RegisterEvent( EVENT_OPEN_BANK, nil, true )
		_addon:RegisterEvent( EVENT_OPEN_GUILD_BANK, nil, true )
		_addon:RegisterEvent( EVENT_OPEN_HOOK_POINT_STORE, nil, true )
		_addon:RegisterEvent( EVENT_OPEN_STORE, nil, true )
		_addon:RegisterEvent( EVENT_OPEN_TRADING_HOUSE, nil, true )
		_addon:RegisterEvent( EVENT_TRADE_INVITE_ACCEPTED, nil, true )
		
		_addon:RegisterEvent( EVENT_LOCAL_PLAYER_ABILITY_OCCURED, nil, true )
		_addon:RegisterEvent( EVENT_LOCAL_PLAYER_KICKOFF_CAST, nil, true )
		
		_addon:RegisterEvent( EVENT_BEGIN_CAST, nil, true )
		_addon:RegisterEvent( EVENT_DELAY_CAST, nil, true )
		
		_addon:RegisterEvent( EVENT_END_CAST, nil, true )
		_addon:RegisterEvent( EVENT_LOCAL_PLAYER_WEAPON_ABILITY_WAIT_END, nil, true )
		_addon:RegisterEvent( EVENT_LOCAL_PLAYER_CHARGEUP_COMPLETE, nil, true )
		
		_addon:OnUpdateCallback( "_addon.AutoSheath_watch", nil )
		
		registeredForEvents = false
	end
end

WYK_FullImmersion = _addon