local GS = GetString

-- four different tables that will be checked independently
local gearMarkersData = {}
local gearMarkersUnique = {}
local gearMarkersPoison = {}
local gearMarkersDataWeapons = {}

local markerControls = {}
local showGearMarkers = false

local checkItemLevel = CSPS.checkItemLevel -- function is needed local for checking during the inventory-callback

local gearSlotsHands = CSPS.getGearSlotsHands() -- just returns the local table from csps_gear

local equipSlotDirectlyToEquipType = { -- unlike the gear-manager itself this module uses the table only for armor, so we don't need the boolean-tables from csps_gear
	[EQUIP_SLOT_CHEST] = EQUIP_TYPE_CHEST,
	[EQUIP_SLOT_FEET] = EQUIP_TYPE_FEET,
	[EQUIP_SLOT_HEAD] = EQUIP_TYPE_HEAD,
	[EQUIP_SLOT_LEGS] = EQUIP_TYPE_LEGS,
	[EQUIP_SLOT_SHOULDERS] = EQUIP_TYPE_SHOULDERS,
	[EQUIP_SLOT_WAIST] = EQUIP_TYPE_WAIST,
	[EQUIP_SLOT_HAND] = EQUIP_TYPE_HAND,

	[EQUIP_SLOT_NECK] = EQUIP_TYPE_NECK,
	[EQUIP_SLOT_RING1] = EQUIP_TYPE_RING,
	[EQUIP_SLOT_RING2] = EQUIP_TYPE_RING,
}


-- EQUIP_SLOT_COSTUME		[EQUIP_TYPE_COSTUME

function CSPS.buildGearMarkerTable()
	gearMarkersData = {}
	gearMarkersDataWeapons = {}
	gearMarkersUnique = {}
	gearMarkersPoison = {}
	
	local function addProfileMarkers(myProfile)
		local gearComp = myProfile.gearComp
		local gearCompUnique = myProfile.gearCompUnique
		if myProfile.comp2 then
			gearComp, gearCompUnique = SplitString("#", myProfile.comp2)
			gearComp = gearComp ~= "-" and gearComp
			gearCompUnique = gearCompUnique ~= "-" and gearCompUnique
		end
		if not gearComp and not gearCompUnique then return end
		local profileName = myProfile.name or GS(CSPS_Txt_StandardProfile)
		local myGear = CSPS.extractGearString(myProfile.gearComp, myProfile.gearCompUnique)
		if myGear then 
			for gearSlot, gearData in pairs(myGear) do
				if gearData then 
					if gearData.itemUniqueID then -- first check: itemUniqueID (will always be preferred, other factors will be discarded if found)
						local itemUniqueID = gearData.itemUniqueID
						gearMarkersUnique[itemUniqueID] = gearMarkersUnique[itemUniqueID] or {}
						table.insert(gearMarkersUnique[itemUniqueID],  profileName)
					elseif gearData.firstId then -- is it a poison?
						firstId = gearData.firstId
						secondId = gearData.secondId or 0
						gearMarkersPoison[firstId] = gearMarkersPoison[firstId] or {}
						gearMarkersPoison[firstId][secondId] = gearMarkersPoison[firstId][secondId] or {}			
						table.insert(gearMarkersPoison[firstId][secondId],  profileName)			
					elseif showGearMarkersDataBased and gearData.setId then -- does it have a set-id?
						local myType = gearData.type or 0
						local gearSlotData = {}
						-- for weapons the weapon-type will be used as an index
						if gearSlotsHands[gearSlot] then
							gearSlotData = gearMarkersDataWeapons[myType] or {}
							gearMarkersDataWeapons[myType] = gearSlotData
						else
							-- for armor the equiptype will be used first, then the armortype (set to 0 for jewelry)
							gearMarkersData[equipSlotDirectlyToEquipType[gearSlot]] = gearMarkersData[equipSlotDirectlyToEquipType[gearSlot]] or {}
							gearMarkersData[equipSlotDirectlyToEquipType[gearSlot]][myType] = gearMarkersData[equipSlotDirectlyToEquipType[gearSlot]][myType] or {}
							gearSlotData = gearMarkersData[equipSlotDirectlyToEquipType[gearSlot]][myType] or {}
							gearMarkersData[equipSlotDirectlyToEquipType[gearSlot]][myType] = gearSlotData
						end
						gearSlotData[gearData.setId] = gearSlotData[gearData.setId] or {}
						gearData.quality = gearData.quality or 1
						gearSlotData[gearData.setId][gearData.quality] = gearSlotData[gearData.setId][gearData.quality] or {}
						gearData.enchant = gearData.enchant or 1
						gearSlotData[gearData.setId][gearData.quality][gearData.enchant] = gearSlotData[gearData.setId][gearData.quality][gearData.enchant] or {}
						gearData.trait = gearData.trait or 1
						gearSlotData[gearData.setId][gearData.quality][gearData.enchant][gearData.trait] = gearSlotData[gearData.setId][gearData.quality][gearData.enchant][gearData.trait] or {}
						table.insert(gearSlotData[gearData.setId][gearData.quality][gearData.enchant][gearData.trait], profileName)
					end
				end
			end
		end
	end
	
	addProfileMarkers(CSPS.currentCharData)
	
	for _, myProfile in pairs(CSPS.currentCharData.profiles) do
		addProfileMarkers(myProfile)
	end
	PLAYER_INVENTORY:RefreshAllInventorySlots(INVENTORY_BACKPACK)
	return gearMarkersUnique, gearMarkersData, gearMarkersDataWeapons, gearMarkersPoison
end

local function getMarkerControl(control)
  local name = control:GetName()
  local marker = markerControls[name]
  if not marker then
    marker = WINDOW_MANAGER:CreateControl(name.."_CSPSGearMarker", control, CT_TEXTURE)
    markerControls[name] = marker
    marker:SetTexture("esoui/art/crafting/crafting_alchemy_badslot.dds")
    marker:SetColor(0, 1, 1, 1)
	marker:SetDesaturation(8)
    marker:SetDrawLayer(3)
    marker:SetHidden(true)
    marker:SetDimensions(11,11)
	marker:SetTextureRotation(math.pi/4, 0.5,0.5)
	local xPos = 38
	if WizardsWardrobe and WizardsWardrobe.settings and WizardsWardrobe.settings.inventoryMarker then
		xPos = 48
	end
    marker:SetAnchor(RIGHT, control, LEFT, xPos)
    marker:SetMouseEnabled(true)
	marker:SetHandler("OnMouseExit", function()
		ZO_Tooltips_HideTextTooltip()
	end)
  end
  return marker
end


local function getItemProfileList(itemData)
	
	local itemLink = itemData.itemLink or GetItemLink(itemData.bagId, itemData.slotIndex)
	
	if not itemLink or itemLink == "" then return false, false end
	
	local itemProfileListSpecific, itemProfileListData = false, false 
	
	
	local itemUniqueID = Id64ToString(GetItemUniqueId(itemData.bagId, itemData.slotIndex))
	local weaponOrArmor = {[ITEMTYPE_ARMOR] = true, [ITEMTYPE_WEAPON] = true}
	
	if gearMarkersUnique[itemUniqueID] then
		itemProfileListSpecific = gearMarkersUnique[itemUniqueID]
	end
		
	if itemData.itemType == ITEMTYPE_POISON then	
		local firstId = GetItemLinkItemId(itemLink)
		local secondId = tonumber(string.match(itemLink, ":(%d+)|")) or 0
		itemProfileListData = gearMarkersPoison[firstId] and gearMarkersPoison[firstId][secondId] or false
		return itemProfileListSpecific, itemProfileListData
	end
	
	if not showGearMarkersDataBased then return itemProfileListSpecific, false end
	
	if weaponOrArmor[itemData.itemType] then
		if itemData.itemType == ITEMTYPE_WEAPON then 
			itemProfileListData = gearMarkersDataWeapons[GetItemLinkWeaponType(itemLink)] or false
		else
			itemProfileListData = gearMarkersData[itemData.equipType] or false
			itemProfileListData = itemProfileListData and itemProfileListData[GetItemLinkArmorType(itemLink)] or false 
		end
		if itemProfileListData then
		
			local _, _, _, _, _, setId = GetItemLinkSetInfo(itemLink)
			local quality = GetItemLinkDisplayQuality(itemLink) 
			local enchant = GetItemLinkFinalEnchantId(itemLink) 
			local trait = GetItemLinkTraitInfo(itemLink)
			
			itemProfileListData = itemProfileListData and itemProfileListData[setId] or false 
			itemProfileListData = itemProfileListData and itemProfileListData[quality] or false 
			itemProfileListData = itemProfileListData and itemProfileListData[enchant] or false 
			itemProfileListData = itemProfileListData and itemProfileListData[trait] or false 
			
			if itemProfileListData and checkItemLevel(itemLink, true) then itemProfileListData = false end
			
		end	
	end	
		
	
	return itemProfileListSpecific, itemProfileListData
end


local function addCSPSMarkerCallback(control)
	local marker = getMarkerControl(control)
	if not showGearMarkers then marker:SetHidden(true) return end
	
	local itemProfileListSpecific, itemProfileListData  = getItemProfileList(control.dataEntry.data)
	
	marker:SetHandler("OnMouseEnter", function(markerControl)
		itemProfileListSpecific, itemProfileListData = getItemProfileList(control.dataEntry.data)
		local tooltipText = {}
		
		if itemProfileListSpecific and #itemProfileListSpecific > 0 then 
			table.insert(tooltipText, string.format(GS(CSPS_SavedSpecific), table.concat(itemProfileListSpecific, ", ")))
		end
		
		if itemProfileListData and #itemProfileListData > 0 then 
			table.insert(tooltipText, string.format(GS(CSPS_SavedData), table.concat(itemProfileListData, ", ")))
		end
		
		if #tooltipText > 0 then 
			table.insert(tooltipText, 1, "|c9e0911CSPS|r")
			ZO_Tooltips_ShowTextTooltip(markerControl, BOTTOMRIGHT, table.concat(tooltipText, "\n  "))
		end
	end)

	marker:SetHidden(not itemProfileListSpecific and not itemProfileListData)
end

function CSPS.setGearMarkerOption(value)
	showGearMarkers =  not CSPS.moduleExclude.gear  and value
	CSPS.savedVariables.settings.showGearMarkers = value
	PLAYER_INVENTORY:RefreshAllInventorySlots(INVENTORY_BACKPACK)
end

function CSPS.setGearMarkerOptionData(value)
	showGearMarkersDataBased = value
	CSPS.savedVariables.settings.showGearMarkerDataBased = value
	CSPS.buildGearMarkerTable()
end

function CSPS.setupGearMarkers()
	local inventories = {
		ZO_PlayerInventoryBackpack,
		ZO_PlayerBankBackpack,
		ZO_GuildBankBackpack,
		ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack,
		ZO_SmithingTopLevelImprovementPanelInventoryBackpack,
	  }
	for _, inventory in pairs(inventories) do
	SecurePostHook(inventory.dataTypes[INVENTORY_BACKPACK], "setupCallback", 
		function(control, slot)
			addCSPSMarkerCallback(control)
		end)
	end
	CSPS.buildGearMarkerTable()
end