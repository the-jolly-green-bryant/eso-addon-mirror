tlztRestockSM = {}
tlztRestockSM.name = "tlztRestockSM"
tlztRestockSM.variableVersion  = 2

local LAM2 = LibAddonMenu2
local RSM = tlztRestockSM 

RSM.Default = {
	defThreshold = 20,
	defRepair = true,
	defGold = 450
}


function RSM.OnAddOnLoaded(event, addonName)
	if addonName ~= RSM.name then return end
    RSM:initialize()
end

function RSM:initialize()
	RSM.savedVariables = ZO_SavedVars:NewAccountWide("tlztRestockSMVar", RSM.variableVersion, nil, RSM.Default, GetWorldName())
	local panelData = {
		type = "panel",
		name = "Teilzeit Restock Options",
	}
	
	local tlztRestockOptions = {
		[1] = {
			type = "checkbox",
			name = "Auto Repair",
			tooltip = "Activate for auto repair when visiting merchant",
			getFunc = function() return RSM.savedVariables.defRepair end,
			setFunc = function(value) 
					RSM.savedVariables.defRepair = value end,
		},
		[2] = {
			type = "slider",
			name = "Threshold",
			tooltip = "Threshold value. If you fall below this value new Style Materials are bought",
			min = 1,
			max = 100,
			getFunc = function() return RSM.savedVariables.defThreshold end,
			setFunc = function(value) 
					RSM.savedVariables.defThreshold= value end,
			step = 1, 
			width = "full",
		},
		[3] = {
			type = "slider",
			name = "Max Gold",
			tooltip = "Max Gold to spend per Style item",
			min = 15,
			max = 1500,
			getFunc = function() return RSM.savedVariables.defGold end,
			setFunc = function(value) 
					RSM.savedVariables.defGold= value end,
			step = 15, 
			width = "full",
		},
	}	
	
	LAM2:RegisterAddonPanel("Teilzeit Restock Options", panelData)
	LAM2:RegisterOptionControls("Teilzeit Restock Options", tlztRestockOptions)
	EVENT_MANAGER:UnregisterForEvent(RSM.name.."OnLoad", EVENT_ADD_ON_LOADED)
end


function RSM.onOpenStore(event)
	RSM.savedVariables = ZO_SavedVars:NewAccountWide("tlztRestockSMVar", RSM.variableVersion, nil, RSM.Default, GetWorldName())
	--EVENT_MANAGER:UnregisterForEvent(RSM.name, EVENT_OPEN_STORE)
	local smTargetCount = RSM.savedVariables.defThreshold
	local blRepair = RSM.savedVariables.defRepair
	smTargetCount = smTargetCount or 20
		
	for i = 1, 9 do
		smActuals = GetCurrentSmithingStyleItemCount(i)
		if smActuals < smTargetCount then
			local smDelta = smTargetCount - smActuals
			RSM.purchaseItem(i, smDelta)
		end	
	end
	local smImpActual = GetCurrentSmithingStyleItemCount(34)
	if smImpActual < smTargetCount then
		local smDelta = smTargetCount - smImpActual
		RSM.purchaseItem(34, smDelta)
	end
	
	if blRepair == true then
			RSM.repairAll()
	end
end

function RSM.purchaseItem(int, amount)
	for iStore =1, GetNumStoreItems() do
		local storeItem = GetStoreItemLink(iStore, LINK_STYLE_DEFAULT)
		local bagItem = GetItemStyleMaterialLink(int, LINK_STYLE_DEFAULT)
		local StoreItemStyle = GetItemLinkItemStyle(storeItem)
		local BagItemStyle = GetItemLinkItemStyle(bagItem)
		local _, name, _, price, _, _, _, _, _, _, _, _, _, _ = GetStoreEntryInfo(iStore)	
				
		if StoreItemStyle == BagItemStyle then
			if (price*amount > defGold) then
				local tempamount = defGold/price
				amount = math.floor(tempamount)
			end 
			if price == 15 then
				BuyStoreItem(iStore, amount)
				d("Item bought: " .. GetStoreItemLink(iStore, LINK_STYLE_DEFAULT) .. ": " .. amount)					 
			end
		else
		end
				
	end
end

function RSM.repairAll()
	if CanStoreRepair() then
		if GetRepairAllCost() > 0 then
			local repCost = GetRepairAllCost()
			RepairAll()
			d("Everything repaired with overall costs: " .. repCost .. " Gold")
		end
	end
	
end

EVENT_MANAGER:RegisterForEvent(RSM.name.."OnLoad", EVENT_ADD_ON_LOADED, RSM.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(RSM.name.."OpenStore", EVENT_OPEN_STORE, RSM.onOpenStore)
