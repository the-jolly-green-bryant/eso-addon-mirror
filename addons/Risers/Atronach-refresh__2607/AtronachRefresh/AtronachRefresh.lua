AtronachRefresh = {
	name = "AtronachRefresh",

	label = {
		default = "Atronach Refresh",
	},
}

function AtronachRefresh.OnAddOnLoaded( eventCode, addonName )
	if (addonName ~= AtronachRefresh.name) then return end

	EVENT_MANAGER:UnregisterForEvent(AtronachRefresh.name, EVENT_ADD_ON_LOADED)
end

function AtronachRefresh.Use( )
	id = 596
	UseCollectible(id)
end

function AtronachRefresh.Refresh( v1,v2,v3,v4,v5,v6,v7,v8,v9,v10)
	 if (v8 == 0 and v4 == "Atronach Transformation") then
		zo_callLater(AtronachRefresh.Use, 1) 
	 end
end

EVENT_MANAGER:RegisterForEvent(AtronachRefresh.name, EVENT_COMBAT_EVENT, AtronachRefresh.Refresh)

EVENT_MANAGER:RegisterForEvent(AtronachRefresh.name, EVENT_ADD_ON_LOADED, AtronachRefresh.OnAddOnLoaded)
