--[[ Auto Max Improvement GP Base ]]--
local ArchRefinementGP = ZO_Object:Subclass()

function ArchRefinementGP:Initialize()
	
	GAMEPAD_SMITHING_REFINE_SCENE:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_SHOWN then
			if not ZO_CraftingUtils_IsPerformingCraftProcess() then
				local gamepadSmithingRefinementPanel = SMITHING_GAMEPAD.refinementPanel
				if (SMITHING_GAMEPAD.mode == ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_RAW_MATERIALS) then
					local bagId, slotIndex = gamepadSmithingRefinementPanel.inventory:CurrentSelectionBagAndSlot()
					if (bagId ~= nil and slotIndex ~= nil) then
						gamepadSmithingRefinementPanel:AddItemToCraft(bagId, slotIndex)
						
						gamepadSmithingRefinementPanel:UpdateSelection()
						KEYBIND_STRIP:UpdateKeybindButtonGroup(gamepadSmithingRefinementPanel.keybindStripDescriptor)
					end
				end
			end
		end
	end)
	
	GAMEPAD_SMITHING_DECONSTRUCT_SCENE:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_SHOWN then
			if not ZO_CraftingUtils_IsPerformingCraftProcess() then
				local gamepadSmithingRefinementPanel = SMITHING_GAMEPAD.deconstructionPanel
				local ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_ANY = 3
				
				if (SMITHING_GAMEPAD.mode == ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_ANY or SMITHING_GAMEPAD.mode == ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_ARMOR or SMITHING_GAMEPAD.mode == ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_WEAPONS) then
					local bagId, slotIndex = gamepadSmithingRefinementPanel.inventory:CurrentSelectionBagAndSlot()
					if (bagId ~= nil and slotIndex ~= nil) then
						gamepadSmithingRefinementPanel:AddItemToCraft(bagId, slotIndex)
						
						gamepadSmithingRefinementPanel:UpdateSelection()
						--gamepadSmithingRefinementPanel:AddItemToWorkbench()
						KEYBIND_STRIP:UpdateKeybindButtonGroup(gamepadSmithingRefinementPanel.keybindStripDescriptor)
					end
				end
			end
		end
	end)
	
	GAMEPAD_ENCHANTING_EXTRACTION_SCENE:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_SHOWN then
			if not ZO_CraftingUtils_IsPerformingCraftProcess() then
				local gamepadEnchantment = GAMEPAD_ENCHANTING
				
				if gamepadEnchantment.enchantingMode == ENCHANTING_MODE_EXTRACTION then
					local bagId, slotIndex = gamepadEnchantment.inventory:CurrentSelectionBagAndSlot()
					if (bagId ~= nil and slotIndex ~= nil) then
						local usedInCraftingType, _, runeType, rankRequirement, rarityRequirement = GetItemCraftingInfo(bagId, slotIndex)
						if usedInCraftingType == CRAFTING_TYPE_ENCHANTING then
							--gamepadEnchantment:AddItemToWorkbench()
							gamepadEnchantment:SetExtractionSlotItem(bagId, slotIndex)
							ZO_GamepadCraftingUtils_PlaySlotBounceAnimation(gamepadEnchantment.extractionSlot)
						
							KEYBIND_STRIP:UpdateKeybindButtonGroup(gamepadEnchantment.keybindEnchantingStripDescriptor)
							
							gamepadEnchantment:UpdateSelection()
						end
					end
				end
			end
		end
	end)

	CALLBACK_MANAGER:RegisterCallback("CraftingAnimationsStopped", function()
		if SCENE_MANAGER:IsShowing("gamepad_smithing_refine") then
			local gamepadSmithingRefinementPanel = SMITHING_GAMEPAD.refinementPanel
		
			gamepadSmithingRefinementPanel:UpdateSelection()
			
			local bagId, slotIndex = gamepadSmithingRefinementPanel.inventory:CurrentSelectionBagAndSlot()

			if (bagId ~= nil and slotIndex ~= nil and SMITHING_GAMEPAD.mode == ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_RAW_MATERIALS) then
				gamepadSmithingRefinementPanel:AddItemToCraft(bagId, slotIndex)
				
				gamepadSmithingRefinementPanel:UpdateSelection()
				KEYBIND_STRIP:UpdateKeybindButtonGroup(gamepadSmithingRefinementPanel.keybindStripDescriptor)
			end
		end
		
		if SCENE_MANAGER:IsShowing("gamepad_smithing_deconstruct") then
			local gamepadSmithingRefinementPanel = SMITHING_GAMEPAD.deconstructionPanel
			
			gamepadSmithingRefinementPanel:UpdateSelection()
			
			local bagId, slotIndex = gamepadSmithingRefinementPanel.inventory:CurrentSelectionBagAndSlot()
			if (bagId ~= nil and slotIndex ~= nil) then
				gamepadSmithingRefinementPanel:AddItemToCraft(bagId, slotIndex)
				
				gamepadSmithingRefinementPanel:UpdateSelection()
				KEYBIND_STRIP:UpdateKeybindButtonGroup(gamepadSmithingRefinementPanel.keybindStripDescriptor)
			end
		end
		
		if SCENE_MANAGER:IsShowing("gamepad_enchanting_extraction") then
			--d("TEST")
			local gamepadEnchantment = GAMEPAD_ENCHANTING
			
			local bagId, slotIndex = gamepadEnchantment.inventory:CurrentSelectionBagAndSlot()
			if (bagId ~= nil and slotIndex ~= nil) then
				local usedInCraftingType, _, runeType, rankRequirement, rarityRequirement = GetItemCraftingInfo(bagId, slotIndex)
				if usedInCraftingType == CRAFTING_TYPE_ENCHANTING then
					--gamepadEnchantment:AddItemToWorkbench()
					gamepadEnchantment:SetExtractionSlotItem(bagId, slotIndex)
					ZO_GamepadCraftingUtils_PlaySlotBounceAnimation(gamepadEnchantment.extractionSlot)
					
					KEYBIND_STRIP:UpdateKeybindButtonGroup(gamepadEnchantment.keybindEnchantingStripDescriptor)
				
					gamepadEnchantment:UpdateSelection()
				end
			end
		end
	end)
	
	EVENT_MANAGER:RegisterForEvent("ArchCraftingStyleCraftingInteract", EVENT_CRAFTING_STATION_INTERACT, function(eventCode, craftingType, sameStation)
		local smithingRefinementPanel = SMITHING.refinementPanel
		if (SMITHING.mode == SMITHING_MODE_REFINMENT and smithingRefinementPanel:GetFilterType() == ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_RAW_MATERIALS) then
			if (smithingRefinementPanel.inventory ~= nil and smithingRefinementPanel.inventory.list ~= nil and #smithingRefinementPanel.inventory.list.data > 0) then
				local currentItem = smithingRefinementPanel.inventory.list.data[1]
				
				SMITHING:AddItemToCraft(currentItem.data.bagId, currentItem.data.slotIndex)
				SMITHING:OnExtractionSlotChanged()
			end
		end
		
		local smithingExtractionPanel = SMITHING.deconstructionPanel
		if (SMITHING.mode == SMITHING_MODE_DECONSTRUCTION and (smithingExtractionPanel:GetFilterType() == ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_ARMOR or smithingExtractionPanel:GetFilterType() == ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_WEAPONS)) then
			if (smithingExtractionPanel.inventory ~= nil and smithingExtractionPanel.inventory.list ~= nil and #smithingExtractionPanel.inventory.list.data > 0) then
				local currentItem = smithingExtractionPanel.inventory.list.data[1]
				
				SMITHING:AddItemToCraft(currentItem.data.bagId, currentItem.data.slotIndex)
				SMITHING:OnExtractionSlotChanged()
			end
		end
	end);
	
	EVENT_MANAGER:RegisterForEvent("ArchCraftingStyleCraftingComplete", EVENT_CRAFT_COMPLETED, function(eventCode, craftingType)
		local smithingRefinementPanel = SMITHING.refinementPanel
		if (SMITHING.mode == SMITHING_MODE_REFINMENT and smithingRefinementPanel:GetFilterType() == ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_RAW_MATERIALS) then
			if (smithingRefinementPanel.inventory ~= nil and smithingRefinementPanel.inventory.list ~= nil and #smithingRefinementPanel.inventory.list.data > 0) then
				local currentItem = smithingRefinementPanel.inventory.list.data[1]
				
				SMITHING:AddItemToCraft(currentItem.data.bagId, currentItem.data.slotIndex)
				SMITHING:OnExtractionSlotChanged()
			end
		end
		
		local smithingExtractionPanel = SMITHING.deconstructionPanel
		if (SMITHING.mode == SMITHING_MODE_DECONSTRUCTION and (smithingExtractionPanel:GetFilterType() == ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_ARMOR or smithingExtractionPanel:GetFilterType() == ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_WEAPONS)) then
			if (smithingExtractionPanel.inventory ~= nil and smithingExtractionPanel.inventory.list ~= nil and #smithingExtractionPanel.inventory.list.data > 0) then
				local currentItem = smithingExtractionPanel.inventory.list.data[1]
				
				SMITHING:AddItemToCraft(currentItem.data.bagId, currentItem.data.slotIndex)
				SMITHING:OnExtractionSlotChanged()
			end
		end
	end);
	
	local origDeconstructionFunc = SMITHING.deconstructionPanel.SetHidden
	
	SMITHING.deconstructionPanel.SetHidden = function(...)
		origDeconstructionFunc(...)
		
		if not hidden then
			local smithingExtractionPanel = SMITHING.deconstructionPanel
			if (SMITHING.mode == SMITHING_MODE_DECONSTRUCTION and (smithingExtractionPanel:GetFilterType() == ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_ARMOR or smithingExtractionPanel:GetFilterType() == ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_WEAPONS)) then
				if (smithingExtractionPanel.inventory ~= nil and smithingExtractionPanel.inventory.list ~= nil and #smithingExtractionPanel.inventory.list.data > 0) then
					local currentItem = smithingExtractionPanel.inventory.list.data[1]
					
					SMITHING:AddItemToCraft(currentItem.data.bagId, currentItem.data.slotIndex)
					SMITHING:OnExtractionSlotChanged()
				end
			end
		end
	end
	
	local origRefinementFunc = SMITHING.refinementPanel.SetHidden
	
	SMITHING.refinementPanel.SetHidden = function(...)
		origRefinementFunc(...)
		
		if not hidden then
			local smithingRefinementPanel = SMITHING.refinementPanel
			if (SMITHING.mode == SMITHING_MODE_REFINMENT and smithingRefinementPanel:GetFilterType() == ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_RAW_MATERIALS) then
				if (smithingRefinementPanel.inventory ~= nil and smithingRefinementPanel.inventory.list ~= nil and #smithingRefinementPanel.inventory.list.data > 0) then
					local currentItem = smithingRefinementPanel.inventory.list.data[1]
					
					SMITHING:AddItemToCraft(currentItem.data.bagId, currentItem.data.slotIndex)
					SMITHING:OnExtractionSlotChanged()
				end
			end
		end
	end

	return
end

function ArchCraftingStyle:InitializeRefinement()
	ArchRefinementGP:Initialize()
end
