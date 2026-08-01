local LOM = LightsOfMeridia
LOM.Handlers = LOM.Handlers or { }

---[ Event Handlers ]---

function LOM.Handlers.OnAddOnLoaded( event, addonName )

	if addonName == LOM.Const.AddonName then
		EVENT_MANAGER:UnregisterForEvent( LOM.Const.AddonName, EVENT_ADD_ON_LOADED )
		LOM.Initialize()
	end

end

function LOM.Handlers.OnWorldChange()
	if LOM.Initialized then
		EVENT_MANAGER:RegisterForUpdate( "LOM.World.OnWorldChange", 2000, LOM.World.OnWorldChange )
	end
end

function LOM.Handlers.OnPlayerActivated()
	if not LOM.Initialized then
		LOM.Initialized = true
		LOM.InitSettings()
	end
	LOM.Handlers.OnWorldChange()
end

---[ Event Registration ]---

EVENT_MANAGER:RegisterForEvent( LOM.Const.AddonName, EVENT_ADD_ON_LOADED, LOM.Handlers.OnAddOnLoaded )
EVENT_MANAGER:RegisterForEvent( LOM.Const.AddonName, EVENT_PLAYER_ACTIVATED, LOM.Handlers.OnPlayerActivated )
EVENT_MANAGER:RegisterForEvent( LOM.Const.AddonName, EVENT_LINKED_WORLD_POSITION_CHANGED, LOM.Handlers.OnWorldChange )
EVENT_MANAGER:RegisterForEvent( LOM.Const.AddonName, EVENT_ZONE_CHANGED, LOM.Handlers.OnWorldChange )
EVENT_MANAGER:RegisterForEvent( LOM.Const.AddonName, EVENT_ZONE_UPDATE, LOM.Handlers.OnWorldChange )

EVENT_MANAGER:RegisterForUpdate( LOM.Const.AddonName .. "RefreshLights", 1000, LOM.OnRefreshLights )
