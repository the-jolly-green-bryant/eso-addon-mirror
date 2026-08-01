local icons = null

ZO_CreateStringId('SI_BINDING_NAME_MMS_TOGGLE', 'Toggle Icon')

function MMS_Toggle()
	if icons then
		for i, icon in ipairs(icons) do
			OSI.DiscardPositionIcon(icon)
		end
		icons = null
		d('Mark My Spot: Position cleared')
	else
		local _, px, py, pz = GetUnitRawWorldPosition('player')
		icons = {
			OSI.CreatePositionIcon(px, py, pz, '/esoui/art/buttons/large_downarrow_up.dds', 100, {0.75, 0.25, 1.00, 1.00}),
			OSI.CreatePositionIcon(px, py + 25, pz, '/esoui/art/buttons/large_downarrow_up.dds', 100, {0.75, 0.25, 1.00, 1.00}),
			OSI.CreatePositionIcon(px, py + 50, pz, '/esoui/art/buttons/large_downarrow_up.dds', 100, {0.75, 0.25, 1.00, 1.00}),
			OSI.CreatePositionIcon(px, py + 100, pz, '/esoui/art/buttons/large_downarrow_up.dds', 100, {0.75, 0.25, 1.00, 0.75}),
			OSI.CreatePositionIcon(px, py + 200, pz, '/esoui/art/buttons/large_downarrow_up.dds', 100, {0.75, 0.25, 1.00, 0.50}),
			OSI.CreatePositionIcon(px, py + 400, pz, '/esoui/art/buttons/large_downarrow_up.dds', 100, {0.75, 0.25, 1.00, 0.25})
		}
		d('Mark My Spot: Position set')
	end
end
