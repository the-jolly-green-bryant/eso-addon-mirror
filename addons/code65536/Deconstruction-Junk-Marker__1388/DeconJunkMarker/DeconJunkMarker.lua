DeconJunkMarker = {
	name = "DeconJunkMarker",
}

local function OnAddOnLoaded( eventCode, addonName )
	if (addonName ~= DeconJunkMarker.name) then return end

	EVENT_MANAGER:UnregisterForEvent(DeconJunkMarker.name, EVENT_ADD_ON_LOADED)

	local backpacks = {
		ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack,
		ZO_EnchantingTopLevelInventoryBackpack,
		ZO_UniversalDeconstructionTopLevel_KeyboardPanelInventoryBackpack,
	}

	local ToggleMarker = function( control, data )
		local isJunk = IsItemJunk(data.bagId, data.slotIndex)

		-- Get or create our marker
		local marker = control:GetNamedChild(DeconJunkMarker.name)
		if (not marker) then
			-- Be lazy; don't create a marker unless we actually need to show it
			if (not isJunk) then return end

			-- Create and initialize the marker control
			marker = WINDOW_MANAGER:CreateControl(control:GetName() .. DeconJunkMarker.name, control, CT_TEXTURE)
			marker:SetTexture("/esoui/art/inventory/inventory_tabicon_junk_up.dds")
			marker:SetColor(0.9, 0.3, 0.2, 1)
			marker:SetDimensions(34, 34)
			marker:SetAnchor(LEFT)
			marker:SetDrawTier(DT_HIGH)
		end

		marker:SetHidden(not isJunk)
	end

	for _, backpack in ipairs(backpacks) do
		if (backpack and ZO_ScrollList_GetDataTypeTable(backpack, 1)) then
			SecurePostHook(ZO_ScrollList_GetDataTypeTable(backpack, 1), "setupCallback", ToggleMarker)
		end
	end
end

EVENT_MANAGER:RegisterForEvent(DeconJunkMarker.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
