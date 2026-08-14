
PinKiller = PinKiller or {}

-- pin types on the map which can be hidden by this addon
PinKiller.mapPinGroups = {
	[MAP_FILTER_QUESTS] = true,
}

function PinKiller:InitializeMapPins()
	-- wait until addon loaded to override ZO function (if it's called earlier it would result in a crash)
	local oldIsShown = ZO_WorldMap_IsPinGroupShown
	function ZO_WorldMap_IsPinGroupShown( pinTag )
		if self.mapPinGroups[pinTag] then
			if not self:IsMapPinGroupEnabled(pinTag) then
				return false
			end
		end
		return oldIsShown( pinTag )
	end
end