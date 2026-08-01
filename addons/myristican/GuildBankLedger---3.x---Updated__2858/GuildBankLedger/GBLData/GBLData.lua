local libName, libVersion = "GBLData", 100
local lib = {}
lib.libName = libName
lib.ET_DEPOSIT_GOLD  = "dep_gold"
lib.ET_DEPOSIT_ITEM  = "dep_item"
lib.ET_WITHDRAW_GOLD = "wd_gold"
lib.ET_WITHDRAW_ITEM = "wd_item"
lib.defaults = {
	history = {}
}

local function Initialize()
	for i = 1, GetNumGuilds() do
		local guildID                                 = GetGuildId(i)
		local guildName                               = GetGuildName(guildID)
		lib.defaults["history"][guildName] = {}
	end
	lib.savedVariables = ZO_SavedVars:NewAccountWide("GBLDataSavedVariables", 1, nil, lib.defaults)
	lib.export = {}
end

function lib:priceMM(item_link)
    if not MasterMerchant then return nil end
    if not item_link then return nil end
    mm = MasterMerchant:itemStats(item_link, false)
    if not mm then return nil end
    return mm.avgPrice
end

function lib:priceLP(item_link)
	if not LibPrice then return nil end
	if not item_link then return nil end
	price = LibPrice.ItemLinkToPriceGold(item_link)
	if not price then return nil end
	return price
end

function lib:ToString(theEvent)
	
	--refresh MM price on export
	local item_LP = lib:priceLP(theEvent.item_link)
--	local item_mm = lib:priceMM(theEvent.item_link)
	
		return             tostring(theEvent.timestamp  )
				.. '\t' .. tostring(theEvent.user       )
				.. '\t' .. tostring(theEvent.trans_type )
				.. '\t' .. tostring(theEvent.gold_ct    )
				.. '\t' .. tostring(theEvent.item_ct    )
				.. '\t' .. tostring(theEvent.item_name  )
				.. '\t' .. tostring(theEvent.item_link  )
				.. '\t' .. tostring(item_LP				)
	--			.. '\t' .. tostring(item_mm			    )
				.. '\t' .. tostring(theEvent.id         )
		end
	
function lib:GoldToString(theEvent)
	
	if theEvent.trans_type == lib.ET_DEPOSIT_GOLD
	or theEvent.trans_type == lib.ET_WITHDRAW_GOLD then
		return             tostring(theEvent.timestamp  )
				.. '\t' .. tostring(theEvent.user       )
				.. '\t' .. tostring(theEvent.trans_type )
				.. '\t' .. tostring(theEvent.gold_ct    )
				.. '\t' .. tostring(theEvent.id         )
	else return nil
	end
end

function lib:ExportEvent(guildID, theEvent, guildName, enable_alldata)
    if not lib.export[guildName] then
        lib.export[guildName] = {}
    end	
	local t = lib.export[guildName]
	if enable_alldata then
		table.insert(t, lib:ToString(theEvent))
	else
		table.insert(t, lib:GoldToString(theEvent))
	end
	end

function lib:WriteEvent(guildName)
	lib.savedVariables.history[guildName] = lib.export[guildName]
end

local function OnAddOnLoaded(eventCode, addonName)
  if addonName == lib.libName then
    Initialize()
  end
end

EVENT_MANAGER:RegisterForEvent(lib.libName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

GBLData = lib