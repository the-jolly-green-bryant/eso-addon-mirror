-- Initialization for SnapShot.lua

local BAG_HOUSE = 1000  -- Base bagId for houses
local BAG_MAIL  = 100   -- Base base bagId for mail attachments

if GetString("OT_LOCATION",0)=="" then
  local n
  n = "OT_LOCATION"..BAG_BACKPACK         ZO_CreateStringId(n,"Backpack")
  n = "OT_LOCATION"..BAG_BANK             ZO_CreateStringId(n,"Bank")
  n = "OT_LOCATION"..BAG_BUYBACK          ZO_CreateStringId(n,"Buyback")
  n = "OT_LOCATION"..BAG_COMPANION_WORN   ZO_CreateStringId(n,"Companion")
  n = "OT_LOCATION"..BAG_GUILDBANK        ZO_CreateStringId(n,"Guild Bank")
  n = "OT_LOCATION"..BAG_HOUSE_BANK_ONE   ZO_CreateStringId(n,"Storage 1")
  n = "OT_LOCATION"..BAG_HOUSE_BANK_TWO   ZO_CreateStringId(n,"Storage 2")
  n = "OT_LOCATION"..BAG_HOUSE_BANK_THREE ZO_CreateStringId(n,"Storage 3")
  n = "OT_LOCATION"..BAG_HOUSE_BANK_FOUR  ZO_CreateStringId(n,"Storage 4")
  n = "OT_LOCATION"..BAG_HOUSE_BANK_FIVE  ZO_CreateStringId(n,"Storage 5")
  n = "OT_LOCATION"..BAG_HOUSE_BANK_SIX   ZO_CreateStringId(n,"Storage 6")
  n = "OT_LOCATION"..BAG_HOUSE_BANK_SEVEN ZO_CreateStringId(n,"Storage 7")
  n = "OT_LOCATION"..BAG_HOUSE_BANK_EIGHT ZO_CreateStringId(n,"Storage 8")
  n = "OT_LOCATION"..BAG_HOUSE_BANK_NINE  ZO_CreateStringId(n,"Storage 9")
  n = "OT_LOCATION"..BAG_HOUSE_BANK_TEN   ZO_CreateStringId(n,"Storage 10")
  n = "OT_LOCATION"..BAG_SUBSCRIBER_BANK  ZO_CreateStringId(n,"Bank")
  n = "OT_LOCATION"..BAG_VIRTUAL          ZO_CreateStringId(n,"Craft Bag")
  n = "OT_LOCATION"..BAG_WORN             ZO_CreateStringId(n,"Equipped")
  n = "OT_LOCATION"..BAG_HOUSE            ZO_CreateStringId(n,"House")
  n = "OT_LOCATION"..BAG_MAIL             ZO_CreateStringId(n,"Mail")
end


OTSNAP_MM_SPACING = -36                                                                 -- Main Menu offsetX

SnapShot            = SnapShot or {}
SnapShot.name       = "SnapShot"
SnapShot.ReportName = ""

SnapShot.MAX_LOOTS  = 2000                                                 -- Maximum size of SnapShot.Loots

SnapShot.PageCount  = 1
SnapShot.PageLength = 500
SnapShot.PageNum    = 1

SnapShot.Header     = {}                                                                    -- Output Header
SnapShot.Lines      = {}                                                             -- Output Display Lines

SnapShot.Loots      = {}                                                            -- List of gathered loot
SnapShot.Stuff      = {}                                                                    -- Data Raw List
SnapShot.StuffXT    = {}                                                           -- Extended Data Raw List

SnapShot.History    = { {},{},{},{},{} }                                 -- Guild Event History Entry Guilds
for ix=1,5 do SnapShot.History[ix] = { {},{},{},{},{} } end                -- Guild Event History Categories

function OT_GetBagName(bagId)                                                                 -- 2021/10/13
  if     bagId < BAG_MAIL   then return GetString("OT_LOCATION",bagId)
  elseif bagId >= BAG_HOUSE then return "House"
  elseif bagId >= BAG_MAIL  then return "Mail"
  end
end
function OT_GetPriceATT(itemLink) -- ATT Sales Average. Last checked 2024 Feb 29
	local value = 0
	if ArkadiusTradeTools
    and ArkadiusTradeTools.Modules
    and ArkadiusTradeTools.Modules.Sales
    and ArkadiusTradeTools.Modules.Sales.addMenuItems
    then value = ArkadiusTradeTools.Modules.Sales:GetAveragePricePerItem(itemLink,0)
	end
	return OTX.TrimDecimals(value)
end
function OT_GetPriceMM(itemLink) -- MM Sales Average. Last checked 2024 Feb 29
	local value = 0
	if MasterMerchant then value = MasterMerchant.GetItemLinePrice(itemLink) or 0 end
	return OTX.TrimDecimals(value)
end
function OT_GetPriceTTC(itemLink,cat) -- TTC Sales. Last checked 2024 Feb 29
	local value = 0
	if TamrielTradeCentre then
		local iTTC = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
		if iTTC then
      if     cat=="Avg" then value = (iTTC.Avg or 0)
      elseif cat=="Sale" then value = (iTTC.SaleAvg or 0)
      elseif cat=="Sugg" then value = (iTTC.SuggestedPrice or 0) * 1.25
      end
		end
	end
	return OTX.TrimDecimals(value)
end

-- =========================================================================================================
