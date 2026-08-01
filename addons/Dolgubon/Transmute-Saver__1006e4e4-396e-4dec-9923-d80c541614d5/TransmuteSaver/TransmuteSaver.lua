TransmuteSaver = {}

TransmuteSaver.name = "TransmuteSaver"
transmuteCap = 151

local originalLootAll = LootAll
LootAll = function(...)
	--LOOT_SHARED:LootAllItems()
	local n = SCENE_MANAGER:GetCurrentScene().name
	
	local numTransmute = GetCurrencyAmount(CURT_CHAOTIC_CREATIA,CURRENCY_LOCATION_ACCOUNT)
	local numLootTransmute = GetLootCurrency(CURT_CHAOTIC_CREATIA)

	if numLootTransmute==0 or numTransmute + numLootTransmute <=  GetMaxPossibleCurrency( CURT_CHAOTIC_CREATIA , CURRENCY_LOCATION_ACCOUNT) then
		originalLootAll()
		return 
	else
		-- GetLootItemInfo(number lootIndex)
		-- do not loot the transmute if it would go over max
		for i = 1, GetNumLootItems() do
			local lootId, name,_,_,_,_,_,_,lootType = GetLootItemInfo(i)
			LootItemById(lootId)
		end
		d("Transmute Saver: Looting this would put you over the transmute stone limit!")
		return 
	end
	originalLootAll()
	return
end

local original = LootCurrency
LootCurrency = function(CurrencyType, ...)
	if CurrencyType == CURT_CHAOTIC_CREATIA then

		local numTransmute = GetCurrencyAmount(CURT_CHAOTIC_CREATIA,CURRENCY_LOCATION_ACCOUNT)
		local numLootTransmute = GetLootCurrency(CURT_CHAOTIC_CREATIA)

		if numLootTransmute==0 or numTransmute + numLootTransmute <= GetMaxPossibleCurrency( CURT_CHAOTIC_CREATIA , CURRENCY_LOCATION_ACCOUNT) then
			
			return original(CurrencyType, ...)
		else
			d("Transmute Saver: Looting this would put you over the transmute stone limit!")
		end
	else
		return original(CurrencyType, ...)
	end
end



function TransmuteSaver.Initialize()

end

function TransmuteSaver.OnAddOnLoaded(event, addonName)
	if addonName == TransmuteSaver.name then
		TransmuteSaver.Initialize()
	end
end

EVENT_MANAGER:RegisterForEvent(TransmuteSaver.name, EVENT_ADD_ON_LOADED, TransmuteSaver.OnAddOnLoaded)

