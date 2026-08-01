local DsRBeam = DsRGuildBeam
DsRBeam.Handlers = DsRBeam.Handlers or { }

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRBeam.Handlers.OnAddOnLoaded( event, name )
	EVENT_MANAGER:UnregisterForEvent(DsRBeam.Const.AddonName, EVENT_ADD_ON_LOADED) 
	
	DsRBeam.Initialize()

	local LIGHT_ENABLED = DsRBeam.GetSetting( "LightEnabled" )

	if LIGHT_ENABLED == true then
		
		EVENT_MANAGER:RegisterForEvent( DsRBeam.Const.AddonName, EVENT_PLAYER_ACTIVATED, DsRBeam.Handlers.OnPlayerActivated )
		EVENT_MANAGER:RegisterForEvent( DsRBeam.Const.AddonName, EVENT_LINKED_WORLD_POSITION_CHANGED, DsRBeam.Handlers.OnWorldChange )
		EVENT_MANAGER:RegisterForEvent( DsRBeam.Const.AddonName, EVENT_ZONE_CHANGED, DsRBeam.Handlers.OnWorldChange )
		EVENT_MANAGER:RegisterForEvent( DsRBeam.Const.AddonName, EVENT_ZONE_UPDATE, DsRBeam.Handlers.OnWorldChange )

		EVENT_MANAGER:RegisterForUpdate( DsRBeam.Const.AddonName .. "RefreshLights", 1000, DsRBeam.OnRefreshLights )

		DsRBeam.SetSetting( "LightEnabled", false )
		DsRBeam.SetSetting( "LightEnabled", true )
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRBeam.Handlers.OnWorldChange()
	if DsRBeam.Initialized then
		EVENT_MANAGER:RegisterForUpdate( "DsRBeamOnWorldChange", 2000, DsRBeam.World.OnWorldChange )
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRBeam.Handlers.OnPlayerActivated()
	if not DsRBeam.Initialized then
		DsRBeam.Initialized = true
	end
	DsRBeam.Handlers.OnWorldChange()
end