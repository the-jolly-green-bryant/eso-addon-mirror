local _addon = WYK_Outfitter

_addon.controlsToWatch = {}

_addon.CreateIndicatorControl = function(parent)
	local control = _addon.Frames.NewTexture(parent:GetName() .. "Outfit", parent)
	control:SetDimensions(24, 24)
	control:SetAnchor(RIGHT, parent, LEFT, 34)
	control:SetTexture("/esoui/art/ava/ava_resourcestatus_upkeeplevel_marker.dds")
	control:SetHidden(true)
	control:SetColor(0, 1, 1, 1)

	return control
end

_addon.AddOutfitIndicatorToSlot = function(control)
	local bagId = control.dataEntry.data.bagId
	local slotIndex = control.dataEntry.data.slotIndex
	
	local indicatorControl = control:GetNamedChild("Outfit")
	if(not indicatorControl) then
		indicatorControl = _addon.CreateIndicatorControl(control)
		table.insert(_addon.controlsToWatch, indicatorControl)
	end

	local _,_,_,_,_,equipType = GetItemInfo(bagId, slotIndex)
	local itemType = GetItemType(bagId, slotIndex)

	if( itemType ~= ITEMTYPE_ARMOR and itemType ~= ITEMTYPE_WEAPON ) then
		indicatorControl:SetHidden(true)
	else
		local itemId = GetItemUniqueId( bagId, slotIndex )
		local isInOutfit = _addon.CheckIsItemOutfit( itemId )

		if( isInOutfit ) then
			indicatorControl:SetHidden(false)
		else 
			indicatorControl:SetHidden(true)
		end
	end
end

local prepScreen = function( obj )
	if not obj then return; end
	if (_addon:GetCountOf(obj.activeControls) > 0 and not obj.isGrid and not obj:IsHidden()) then
		for _,v in pairs(obj.activeControls) do
			_addon.AddOutfitIndicatorToSlot(v)
		end
	end
end

_addon.AddOutfitIndicators = function (self)
	prepScreen( ZO_PlayerInventoryBackpack )
	prepScreen( ZO_PlayerBankBackpack )
	prepScreen( ZO_SmithingTopLevelRefinementPanelInventoryBackpack )
	prepScreen( ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack )
	prepScreen( ZO_SmithingTopLevelImprovementPanelInventoryBackpack )
end

_addon.CheckIsItemOutfit = function (itemId)
	obj = _addon.Settings.GearSets["sets"]

	for k,t in pairs(_addon.Settings.GearSets["sets"]["keys"]) do
		if _addon.Settings.GearSets["sets"][t] ~= nil then
			for i,l in pairs(_addon.Settings.GearSets["sets"][t]) do
				if((itemId.."") == l) then
					return true
				end
			end
		end
	end

	return false
end