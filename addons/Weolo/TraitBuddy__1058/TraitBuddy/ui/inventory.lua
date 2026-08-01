TB_Inventory = ZO_Object:Subclass()

function TB_Inventory:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function TB_Inventory:Initialize()
	self.inventories = {
		bag = {
			list = ZO_PlayerInventoryList,
			showKey = "bag",
		},
		bank = {
			list = ZO_PlayerBankBackpack,
			showKey = "bank",
		},
		guild = {
			list = ZO_GuildBankBackpack,
			showKey = "guild",
		},
		deconstruction = {
			list = ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack,
			showKey = "crafting",
		},
		improvement = {
			list = ZO_SmithingTopLevelImprovementPanelInventoryBackpack,
			showKey = "crafting",
		},
		assistant = {
			list = ZO_UniversalDeconstructionTopLevel_KeyboardPanelInventoryBackpack,
			showKey = "crafting",
		},
	}
	self:HookInventory()
end

function TB_Inventory:IsWeapon(da)
	return da and (da.itemType==ITEMTYPE_WEAPON)
end

function TB_Inventory:IsArmour(da)
	--Includes jewellery
	return da and (da.itemType==ITEMTYPE_ARMOR and da.equipType~=EQUIP_TYPE_INVALID and da.equipType~=EQUIP_TYPE_COSTUME)
end

function TB_Inventory:IsMotif(da)
	return da and (da.itemType==ITEMTYPE_RACIAL_STYLE_MOTIF)
end

function TB_Inventory:CreateInventoryControl(parent)
	local control = CreateControl("$(parent)TBIndicator", parent, CT_TEXTURE)
	control:SetHidden(true)
	control:SetAnchor(TOPLEFT, parent:GetNamedChild("TraitInfo"), TOPLEFT, 0, 0)
	control:SetAnchor(BOTTOMRIGHT, parent:GetNamedChild("TraitInfo"), BOTTOMRIGHT, 0, 0)
	return control
end

function TB_Inventory:UpdateInventoryControl(control, hidden, r, g, b)
	if control then
		if InventoryGridView and InventoryGridView.settings.vars.isGrid[IGVID_INVENTORY] and TraitBuddy.settings.inventory.IGVOnTop then
			control:SetDrawTier(DT_HIGH)
		else
			control:SetDrawTier(DT_MEDIUM)
		end
		if TraitBuddy.settings.inventory.gameIcon then
			control:SetTexture(GetPlatformTraitInformationIcon(ITEM_TRAIT_INFORMATION_CAN_BE_RESEARCHED))
		else
			control:SetTexture("esoui/art/treeicons/store_indexicon_craftingmotiff_up.dds")
		end
		control:SetHidden(hidden)
		control:SetColor(r, g, b)
	end
end

function TB_Inventory:GetInventoryControl(parent)
	if not parent then return nil end
	local control = parent:GetNamedChild("TBIndicator")
	if control then
		control:SetHidden(true)
	end
	return control
end

function TB_Inventory:HookInventory()
	for k,inv in pairs(self.inventories) do
		-- Add safety checks
		if not inv.list then
			d("[TraitBuddy] Warning: Inventory list for " .. k .. " is nil, skipping hook")
		else
			local dataType = ZO_ScrollList_GetDataTypeTable(inv.list, 1)
			if not dataType then
				d("[TraitBuddy] Warning: Could not get data type for " .. k .. ", skipping hook")
			else
				local show = TraitBuddy.settings.inventory.show[inv.showKey]
				SecurePostHook(dataType, "setupCallback", function(control, dataEntryData)
					-- Add nil checks
					if not control or not dataEntryData then
						return
					end
					
					local indicator = self:GetInventoryControl(control)

					-- Only create the control if really need to
					if show then
						if self:IsWeapon(dataEntryData) or self:IsArmour(dataEntryData) or self:IsMotif(dataEntryData) then
							if indicator == nil then
								indicator = self:CreateInventoryControl(control)
							end
							local toHide, r, g, b = self:GetDetails(dataEntryData)
							self:UpdateInventoryControl(indicator, toHide, r, g, b)
						end
					end
				end)
			end
		end
	end
end

function TB_Inventory:GetDetails(dataEntry)
	local toHide = true
	local col = TraitBuddy.settings.inventory.colours.othersCan
	local r = col.r
	local g = col.g
	local b = col.b
	
	-- Enhanced nil check
	if not dataEntry or not dataEntry.bagId or not dataEntry.slotIndex then
		return toHide, r, g, b
	end
	
	if GetItemTraitInformation(dataEntry.bagId, dataEntry.slotIndex) == ITEM_TRAIT_INFORMATION_CAN_BE_RESEARCHED then
		return toHide, r, g, b
	end
	
	local itemLink = GetItemLink(dataEntry.bagId, dataEntry.slotIndex, LINK_STYLE_BRACKETS)
	if not itemLink or itemLink == "" then
		return toHide, r, g, b
	end
	
	local itemType = GetItemLinkItemType(itemLink)
	if itemType == ITEMTYPE_RACIAL_STYLE_MOTIF then
		-- Check if TraitBuddy.data exists
		if not TraitBuddy.data then
			return toHide, r, g, b
		end
		
		local itemStyleId, chapter, motifOrder, chapterOrder = TraitBuddy.data:GetMotifStyle(itemLink)
		if itemStyleId > 0 then
			-- Check if ui.motifs exists
			if not TraitBuddy.ui or not TraitBuddy.ui.motifs then
				return toHide, r, g, b
			end
			
			local kk, dd = TraitBuddy.ui.motifs:GetWhoKnowsMotif(motifOrder, chapterOrder, true)
			toHide = (#dd==0)
			local c = TraitBuddy:GetCharacter(TraitBuddy.characterId)
			if c and ZO_IsElementInNumericallyIndexedTable(dd, c.name) then
				r = 1
				g = 1
				b = 1
			end
		end
	else
		local traitType = GetItemLinkTraitInfo(itemLink)
		if TraitBuddy:IsResearchableTrait(traitType) then
			local armorType = GetItemLinkArmorType(itemLink)
			local weaponType = GetItemLinkWeaponType(itemLink)
			local equipType = GetItemLinkEquipType(itemLink)
			local craftingSkillType = TraitBuddy:LinkToCraftingSkillType(itemLink)
			local researchLineIndex = TraitBuddy:ItemToResearchLineIndex(itemType, armorType, weaponType, equipType)
			local traitIndex = TraitBuddy:FindTraitIndex(craftingSkillType, researchLineIndex, traitType)
			if craftingSkillType and researchLineIndex and traitIndex then
				if craftingSkillType>0 and researchLineIndex>0 and traitIndex>0 then
					local kk, rr, dd = TraitBuddy:GetWhoKnows(craftingSkillType, researchLineIndex, traitIndex, true)
					toHide = (#dd==0)
				end
			end
		end
	end
	return toHide, r, g, b
end