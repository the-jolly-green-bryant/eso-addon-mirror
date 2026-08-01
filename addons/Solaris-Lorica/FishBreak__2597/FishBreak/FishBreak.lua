FishBreak = {}

FishBreak.name="FishBreak"

FishBreak.fishingHoles = {["Foul Fishing Hole"] = true, ["Lake Fishing Hole"] = true, ["Saltwater Fishing Hole"] =  true, ["River Fishing Hole"] = true, ["Mystic Fishing Hole"] = true, ["Oily Fishing Hole"] = true}

function FishBreak.OnAddOnLoaded(event, addOnName)
	if addOnName == FishBreak.name then
		FishBreak:Initialize()
	end
end

function FishBreak:Initialize() 
	EVENT_MANAGER:UnregisterForEvent(FishBreak.name, EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:RegisterForEvent(FishBreak.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, FishBreak.baitGone)
	EVENT_MANAGER:AddFilterForEvent(FishBreak.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
	EVENT_MANAGER:AddFilterForEvent(FishBreak.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_IS_NEW_ITEM, false)
	EVENT_MANAGER:RegisterForEvent(FishBreak.name, EVENT_CLIENT_INTERACT_RESULT, FishBreak.startFish)
	EVENT_MANAGER:RegisterForEvent(FishBreak.name, EVENT_CHATTER_END, FishBreak.ranAway)
end

function FishBreak.startFish(_,_,targetName)
	if FishBreak.fishingHoles[targetName] then
		FishBreak.fishing = true
	else
		FishBreak.fishing = false
	end
end

function FishBreak.baitGone(_,bagId,_,_,_,_,stackCount)
	if bagId == BAG_BACKPACK or bagId == BAG_VIRTUAL then
		if FishBreak.fishing and stackCount == -1 then
			FishIndicator:SetHidden(false)		
		else
			FishIndicator:SetHidden(true)
		end
	end
end

function FishBreak.ranAway(_)
	FishIndicator:SetHidden(true)
end

EVENT_MANAGER:RegisterForEvent(FishBreak.name, EVENT_ADD_ON_LOADED, FishBreak.OnAddOnLoaded)