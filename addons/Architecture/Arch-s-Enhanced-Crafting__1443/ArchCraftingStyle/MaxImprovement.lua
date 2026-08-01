--[[ Auto Max Improvement GP Base ]]--
local ArchMaxImprovementGP = ZO_Object:Subclass()

function ArchMaxImprovementGP:Initialize()
	local onAddItemToCraftOriginal = SMITHING_GAMEPAD.improvementPanel.AddItemToCraft
	SMITHING_GAMEPAD.improvementPanel.AddItemToCraft = function (...)
		local gamepadSmithingImprovementPanel = SMITHING_GAMEPAD.improvementPanel
		
		onAddItemToCraftOriginal(...)
		
		if gamepadSmithingImprovementPanel.selectedItem then
			local max = gamepadSmithingImprovementPanel:FindMaxBoostersToApply()
			
			gamepadSmithingImprovementPanel.spinner:Activate()
			gamepadSmithingImprovementPanel.spinner:SetValue(max)
		end
	end
	
	-- Loosely based on Gamepad AutoMaxImprovement code above (should refactor into re-usable component)
	local onSlotChangedOriginal = SMITHING.improvementPanel.OnSlotChanged
	SMITHING.improvementPanel.OnSlotChanged = function (...)
		local keyboardSmithingImprovementPanel = SMITHING.improvementPanel
		
		onSlotChangedOriginal(...)
		
		if keyboardSmithingImprovementPanel.improvementSlot:HasItem() then
			local max = keyboardSmithingImprovementPanel:FindMaxBoostersToApply()
			
			if max > 0 then
				keyboardSmithingImprovementPanel.spinner:SetValue(max)
			end
		
		end
	end
	
end

function ArchCraftingStyle:InitializeImprovement()
	ArchMaxImprovementGP:Initialize()
end

