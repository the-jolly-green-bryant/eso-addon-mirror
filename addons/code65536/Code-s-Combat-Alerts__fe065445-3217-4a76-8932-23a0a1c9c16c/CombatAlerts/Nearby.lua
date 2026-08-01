local LCA = LibCombatAlerts
local CA2 = CombatAlerts2

local NB = {
	name = "CA_Nearby",

	titleTime = 4000, -- Time to show the title text before displaying data
	pollingInterval = 100,
	defaultPosition = {
		right = 0,
		top = 300,
	},

	enabled = false,
	initialized = false,
	rows = { },
	visibleRows = 0,
}


--------------------------------------------------------------------------------
-- Public interface
--------------------------------------------------------------------------------

function CA2.NearbyToggle( enable )
	if (enable and not NB.enabled) then
		NB.enabled = true

		if (not NB.initialized) then
			NB.initialized = true
			NB.control = CA_Nearby
			NB.fragment = ZO_SimpleSceneFragment:New(NB.control)
			NB.placeholder = NB.control:GetNamedChild("Placeholder")
			NB.positioner = LCA.MoveableControl:New(NB.control)
			NB.positioner:RegisterCallback(NB.name, LCA.EVENT_CONTROL_MOVE_STOP, function(pos) CA2.sv.nearbyPos = pos end)
		end

		NB.placeholder:SetText(GetString(SI_CA_NEARBY))
		NB.delayedEnable = GetGameTimeMilliseconds() + NB.titleTime

		EVENT_MANAGER:RegisterForUpdate(NB.name, NB.pollingInterval, NB.UpdatePoll)
		NB.UpdatePoll()

		NB.positioner:UpdatePosition(CA2.sv.nearbyPos or NB.defaultPosition)
		LCA.ToggleUIFragment(NB.fragment, true)
	elseif (not enable and NB.enabled) then
		NB.enabled = false
		EVENT_MANAGER:UnregisterForUpdate(NB.name)
		LCA.ToggleUIFragment(NB.fragment, false)
	end
end

function CA2.NearbyEnabled( )
	return NB.enabled
end

function CA2.NearbySetPosition( pos )
	if (NB.enabled) then
		NB.positioner:UpdatePosition(pos or NB.defaultPosition)
	end
end

function CA2.NearbyGetDefaultPosition( )
	return ZO_ShallowTableCopy(NB.defaultPosition)
end


--------------------------------------------------------------------------------
-- Private
--------------------------------------------------------------------------------

function NB.GetRow( r )
	local rows = NB.rows
	if (#rows < r) then
		for i = #rows + 1, r do
			local control = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)Row" .. i, NB.control, "CA_Nearby_Row")
			if (i == 1) then
				control:SetAnchor(TOPLEFT)
			else
				control:SetAnchor(TOPLEFT, rows[i - 1].control, BOTTOMLEFT)
			end

			local range = control:GetNamedChild("Range")
			local name = control:GetNamedChild("Name")
			range:SetDimensionConstraints(range:GetStringWidth("00.0m") / GetUIGlobalScale(), 0, 0, 0)
			name:SetDimensionConstraints(120, 0, 0, 0)

			rows[i] = {
				control = control,
				range = range,
				name = name,
			}
		end
	end
	return rows[r]
end

function NB.UpdatePoll( )
	local results = { }

	if (GetGameTimeMilliseconds() > NB.delayedEnable) then
		for i = 1, GetGroupSize() do
			local unitTag = GetGroupUnitTagByIndex(i)
			if ((not AreUnitsEqual("player", unitTag)) and IsUnitInGroupSupportRange(unitTag)) then
				table.insert(results, { LCA.GetDistance("player", unitTag), unitTag })
			end
		end
		table.sort(results, function(a, b) return a[1] < b[1] end)
		NB.placeholder:SetText((#results > 0) and "" or GetString(SI_CA_NEARBY_EMPTY))
	end

	for i = 1, CA2.sv.nearby do
		local row = NB.GetRow(i)
		local result = results[i]
		row.range:SetText(result and string.format("%.1fm", result[1]) or " ")
		row.name:SetText(result and GetUnitDisplayName(result[2]) or " ")
		row.control:SetHidden(false)
	end

	if (NB.visibleRows > CA2.sv.nearby) then
		for i = CA2.sv.nearby + 1, NB.visibleRows do
			NB.GetRow(i).control:SetHidden(true)
		end

		-- Force size recalculation
		NB.control:SetHeight(1)
		NB.control:SetResizeToFitConstrains(ANCHOR_CONSTRAINS_XY)
	end

	NB.visibleRows = CA2.sv.nearby
end


--------------------------------------------------------------------------------
-- Bootstrap
--------------------------------------------------------------------------------

LCA.RunAfterInitialLoadscreen(function( )
	if (CA2.loaded) then
		CA2.NearbyToggle(CA2.sv.nearby > 0)
	end
end)
