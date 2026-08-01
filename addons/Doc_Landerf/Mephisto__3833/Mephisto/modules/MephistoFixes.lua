Mephisto = Mephisto or {}
local MP = Mephisto

MP.fixes = {}
local MPF = MP.fixes

function MPF.Init()
	MPF.name = MP.name .. "Fixes"
	MPF.flippingShoulders = false
end

function MPF.FlipShoulders()
	if MPF.flippingShoulders then return end
	MPF.flippingShoulders = true
	
	local itemId = GetItemId(BAG_WORN, EQUIP_SLOT_SHOULDERS)
	local itemLink = GetItemLink(BAG_WORN, EQUIP_SLOT_SHOULDERS)
	if not itemId or itemId == 0 then 
		MPF.flippingShoulders = false
		return
	end
	
	if not DoesBagHaveSpaceFor(BAG_BACKPACK, BAG_WORN, EQUIP_SLOT_SHOULDERS) then
		MP.Log(GetString(MP_MSG_WITHDRAW_FULL), MP.LOGTYPES.ERROR)
		MPF.flippingShoulders = false
		return
	end
	
	local slot = FindFirstEmptySlotInBag(BAG_BACKPACK)
	if not slot then
		MPF.flippingShoulders = false
		return
	end
		
	CallSecureProtected("RequestMoveItem", BAG_WORN, EQUIP_SLOT_SHOULDERS, BAG_BACKPACK, slot, 1)
	
	local i = 1
	EVENT_MANAGER:RegisterForUpdate(MPF.name .. "FlipShoulders", 100, function()
		local lookupId = GetItemId(BAG_BACKPACK, slot)
		if lookupId == itemId then
			EVENT_MANAGER:UnregisterForUpdate(MPF.name .. "FlipShoulders")
			zo_callLater(function()
				EquipItem(BAG_BACKPACK, slot, EQUIP_SLOT_SHOULDERS)
			end, 500)
			MPF.flippingShoulders = false
			return
		end
		
		i = i + 1
		if i > 30 then -- 3000ms
			EVENT_MANAGER:UnregisterForUpdate(MPF.name .. "FlipShoulders")
			MP.Log(GetString(MP_MSG_GEARSTUCK), MP.LOGTYPES.ERROR, nil, itemLink)
			MPF.flippingShoulders = false
			return
		end
	end)
end

function MPF.FixSurfingWeapons()
	local collectibleId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_HAT)
	if collectibleId == 0 then collectibleId = 5002 end
	
	UseCollectible(collectibleId)
	
	zo_callLater(function()
		UseCollectible(collectibleId)	
	end, 1500 + GetLatency())
end