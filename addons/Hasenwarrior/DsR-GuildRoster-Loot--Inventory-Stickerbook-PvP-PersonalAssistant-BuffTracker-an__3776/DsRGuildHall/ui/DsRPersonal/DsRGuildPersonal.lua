-- Create namespace
DsRGuildPersonal = {}
local DsRGuildPersonal = DsRGuildPersonal or {}

DsRGuildPersonal.name = "DsRGuildPersonal"

local function GetSettings()
	local CharName = GetUnitName("player")
	return DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]
end

DsRGuildPersonal.GetSettings = GetSettings

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPersonal.OpenBank(event_code, bank_bag)
	DsRGuildPersonalBanking.CurrencyGold(event_code, bank_bag)
	DsRGuildPersonalBanking.CurrencyAP(event_code, bank_bag)
	DsRGuildPersonalBanking.CurrencyTelVar(event_code, bank_bag)
	DsRGuildPersonalBanking.CurrencyWritVouchers(event_code, bank_bag)
	DsRGuildPersonalBanking.BankingItemDepositOrWithdraw(event_code, bank_bag)

	-- anti spam
	DsRGuildPersonal.ACCconfig.LastStackBags = DsRGuildPersonal.ACCconfig.LastStackBags or 0
	local skipStackBags = false
	if GetTimeStamp() <= DsRGuildPersonal.ACCconfig.LastStackBags + 1 then
	    skipStackBags = true
	end 
	
    if DsRGuildPersonal.ACCconfig.AutoStack and skipStackBags == false then
        StackBag(BAG_BANK)
		DsRGuildPersonal.ACCconfig.LastStackBags = GetTimeStamp()
    end
end


-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPersonal.OpenShop(event_code, bank_bag)
	DsRGuildPersonalDeconJunk.OpenStore(event_code, bank_bag)
	DsRGuildPersonalAvA.BySiegeItems(event_code, bank_bag)

	-- anti spam
	DsRGuildPersonal.ACCconfig.LastStackBags = DsRGuildPersonal.ACCconfig.LastStackBags or 0
	local skipStackBags = false
	if GetTimeStamp() <= DsRGuildPersonal.ACCconfig.LastStackBags + 1 then
	    skipStackBags = true
	end 
	
    if DsRGuildPersonal.ACCconfig.AutoStack and skipStackBags == false then
        StackBag(BAG_BACKPACK)
		-- if IsESOPlusSubscriber() then  -- WENN AKTIVIERT, CRASHED DAS SPIEL!!!!!!!!
        --     StackBag(BAG_SUBSCRIBER_BANK)
        -- end
		DsRGuildPersonal.ACCconfig.LastStackBags = GetTimeStamp()
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPersonal.getFormattedCurrency(currencyAmount, currencyType, noColor)
    local currencyType 	= currencyType or CURT_MONEY
    local noColor 		= noColor or false
    local formatType 	= ZO_CURRENCY_FORMAT_AMOUNT_ICON
    local extraOptions 	= {}

    if currencyAmount < 0 then
        if not noColor then formatType = ZO_CURRENCY_FORMAT_ERROR_AMOUNT_ICON end
        currencyAmount = currencyAmount * -1
    else
        if not noColor and currencyType == CURT_ALLIANCE_POINTS then
			extraOptions = { color = ZO_ColorDef:New("00FF00") }
		elseif not noColor and currencyType == CURT_MONEY then
			extraOptions = { color = ZO_ColorDef:New("FFD700") }
		end
    end
    return zo_strformat(SI_NUMBER_FORMAT, ZO_Currency_FormatKeyboard(currencyType, currencyAmount, formatType, extraOptions))
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- On addon loaded
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPersonal.OnAddOnLoaded(event, name)
	EVENT_MANAGER:RegisterForEvent(DsRGuildPersonal.name, EVENT_OPEN_BANK, DsRGuildPersonal.OpenBank)
	EVENT_MANAGER:RegisterForEvent(DsRGuildPersonal.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, DsRGuildPersonalDeconJunk.MarkItemAsJunk)
	EVENT_MANAGER:RegisterForEvent(DsRGuildPersonal.name, EVENT_OPEN_STORE, DsRGuildPersonal.OpenShop)
	EVENT_MANAGER:RegisterForEvent(DsRGuildPersonal.name, EVENT_CRAFTING_STATION_INTERACT, DsRGuildPersonalDeconJunk.DeconstructorSceneOpen)
	DsRGuildPersonalConsumer.OnAddOnLoaded(event, name)
	DsRGuildPersonalRepair.RepairWorkshop(event, name)

	DsRGuildPersonalMouseMenu.LinkHandlerExtension()
	ZO_PreHook("ZO_InventorySlot_ShowContextMenu", function(inventorySlot) zo_callLater(function() DsRGuildPersonalMouseMenu.ShowContextMenuExtension(inventorySlot) end, 50) end)
end