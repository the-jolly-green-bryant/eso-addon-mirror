WritStylePrice.List = ZO_SortFilterList:Subclass()

WritStylePrice.List.masterList = {}

--[[
-- Instanciate a new ZO_SortFilterList which use us and return it
--
-- @return ZO_SortFilterList
--]]
function WritStylePrice.List:New(control)
	return ZO_SortFilterList.New(self, control)
end

--[[
-- @inheritdoc
--]]
function WritStylePrice.List:Initialize(control)
    ZO_SortFilterList.Initialize(self, control)

	ZO_ScrollList_AddDataType(
        self.list,
        1,
        "WritStylePriceUIRow",
        30,
        function(control, data)
            self:SetupItemRow(control, data)
        end
    )

    --Not work T-T
	--ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
    --self:SetAlternateRowBackgrounds(true)

	local sortKeys = {
        ["itemName"]   = {},
        ["nbVouchers"] = {tiebreaker = "itemName", isNumeric=true},
        ["location"]   = {tiebreaker = "itemName"},
        ["styleName"]  = {tiebreaker = "itemName"},
        ["price"]      = {tiebreaker = "itemName", isNumeric=true}
	}

	self.currentSortKey   = "itemName"
	self.currentSortOrder = ZO_SORT_ORDER_UP
	self.sortHeaderGroup:SelectHeaderByKey(self.currentSortKey)
    self.sortFunction = function(listEntry1, listEntry2)
		return(
            ZO_TableOrderingFunction(
                listEntry1.data,
                listEntry2.data,
                self.currentSortKey,
                sortKeys,
                self.currentSortOrder
            )
        )
    end
end

--[[
-- @inheritdoc
--]]
function WritStylePrice.List:BuildMasterList()
    self.masterList = {}

    WritStylePrice.Collect:readAllList(WritStylePrice.List.readItemObj, self)
end

--[[
-- Callback for WritStylePrice.Collect:readAllList, called for each item in the list
-- Self is defined to be the self in WritStylePrice.List:BuildMasterList()
--
-- Add all masterWrit whose style is not known to the masterList
--
-- @param string listType The type of the list (see constants)
-- @param int bagId The bag id where is the item
-- @param string itemKey The item key in self.list[][]
-- @param WritStylePrice.Item itemObj The Item object for the current item readed
--]]
function WritStylePrice.List:readItemObj(listType, bagId, itemKey, itemObj)
    if itemObj.itemType == WritStylePrice.Item.ITEM_TYPE_MW then
        if itemObj.data.styleIsKnown == false then
            table.insert(
                self.masterList,
                self:convertItemDataToDisplay(itemObj)
            )
        end
    end
end

--[[
-- Convert data in Item object to a table used for generate the row
--
-- @param WritStylePrice.Item itemObj
--
-- @return table
--]]
function WritStylePrice.List:convertItemDataToDisplay(itemObj)
    local bagId       = itemObj.bagId
    local locationTxt = ''
    
    if bagId == BAG_BANK or bagId == BAG_SUBSCRIBER_BANK then
        locationTxt = GetString(SI_WRITSTYLEPRICE_LIST_LOCATION_BANK)
    elseif bagId >= BAG_HOUSE_BANK_ONE and bagId <= BAG_HOUSE_BANK_TEN then
        local collectibleId = GetCollectibleForHouseBankBag(bagId)
        locationTxt         = GetCollectibleNickname(collectibleId)
        
        if locationTxt == "" then
            locationTxt = GetCollectibleName(collectibleId)
        end
    elseif bagId == BAG_BACKPACK then
        local charId = itemObj.charId
        locationTxt = WritStylePrice.charactersMap[charId]

        if locationTxt == nil then
            locationTxt = GetString(SI_WRITSTYLEPRICE_LIST_LOCATION_UNKNOWN_CHARACTER)
        end
    else
        locationTxt = GetString(SI_WRITSTYLEPRICE_UNKNOWN)
    end

    local motifLink = itemObj.data.styleItem.motifLink
    local firstPrice, firstPriceTxt = WritStylePrice.Price:obtainPreferredPrice(motifLink)

    return {
        itemLink   = itemObj.itemLink,
        itemName   = itemObj.itemName,
        nbVouchers = ZO_CurrencyControl_FormatCurrency(
            math.floor(itemObj.data.nbVouchers + 0.5)
        ),
        location   = locationTxt,
        styleName  = itemObj.data.styleItem.motifName,
        styleLink  = itemObj.data.styleItem.motifLink,
        price      = firstPrice,
        priceTxt   = firstPriceTxt,
        priceList  = WritStylePrice.Price:obtainPriceList(motifLink)
    }
end

--[[
-- @inheritdoc
-- Note : Populate the ScrollList's rows, using our data model as a source.
--]]
function WritStylePrice.List:FilterScrollList()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    ZO_ClearNumericallyIndexedTable(scrollData)

    for i = 1, #self.masterList do
        local data = self.masterList[i]
        table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
    end
end

--[[
-- @inheritdoc
--]]
function WritStylePrice.List:SortScrollList()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    table.sort(scrollData, self.sortFunction)
end

--[[
-- @inheritdoc
-- Define each row
--]]
function WritStylePrice.List:SetupItemRow(control, data)
    control.data = data
    
    local labelName       = control:GetNamedChild("Name")
    local labelNbVouchers = control:GetNamedChild("NbVouchers")
    local labelLocation   = control:GetNamedChild("Location")
    local labelStyleName  = control:GetNamedChild("StyleName")
    local labelPrice      = control:GetNamedChild("Price")

	labelName:SetText(data.itemLink)
    self:createItemTooltip(labelName)

	labelNbVouchers.normalColor = ZO_DEFAULT_TEXT
	labelNbVouchers:SetText(data.nbVouchers)

	labelLocation.normalColor = ZO_DEFAULT_TEXT
	labelLocation:SetText(data.location)

	labelStyleName.normalColor = ZO_DEFAULT_TEXT
	labelStyleName:SetText(data.styleLink)
    self:createItemTooltip(labelStyleName)

	labelPrice.normalColor = ZO_DEFAULT_TEXT
    labelPrice:SetText(data.priceTxt)
    self:createPriceTooltip(labelPrice, data)

	ZO_SortFilterList.SetupRow(self, control, data)
end

--[[
-- Create the item tooltip for the current item in the cell
--
-- @param table control The cell control
--]]
function WritStylePrice.List:createItemTooltip(control)
    control:SetMouseEnabled(true)

    control:SetHandler("OnMouseEnter", function(self)
        InitializeTooltip(ItemTooltip, self, LEFT, 0, 0, 0)
        ItemTooltip:SetLink(self:GetText())
        
        --Extracted from craftStore function CS.Tooltip()
		ZO_ItemTooltip_ClearCondition(ItemTooltip)
        ZO_ItemTooltip_ClearCharges(ItemTooltip)
        
        --Integrate TTC info
        if TamrielTradeCentre and TamrielTradeCentrePrice then
            TamrielTradeCentrePrice:AppendPriceInfo(ItemTooltip, self:GetText())
        end
        --Integrate MM graphs
        if MasterMerchant then
            MasterMerchant:addStatsAndGraph(ItemTooltip, self:GetText(), false)
        end
        
        --End extracted from craftStore
    end)

    control:SetHandler("OnMouseExit", function(self)
        ClearTooltip(ItemTooltip)
    end)

    control:SetHandler("OnMouseUp", function(self, button, upInside, ctrl, alt, shift, command)
        if upInside then
            ZO_LinkHandler_OnLinkClicked(self:GetText(), button, self)
        end
    end)
end

--[[
-- Create the tooltip to display all price found for an item
--
-- @param table control The cell control
-- @param table data All data about the item to display on the row
--]]
function WritStylePrice.List:createPriceTooltip(control, data)
    control:SetMouseEnabled(true)

    control:SetHandler("OnMouseEnter", function(self)
        InitializeTooltip(InformationTooltip)
        ZO_Tooltips_SetupDynamicTooltipAnchors(InformationTooltip, control)

        if data.price == nil then
            InformationTooltip:AddLine(
                GetString(SI_WRITSTYLEPRICE_LIST_NO_PRICE_FOUND)
            )
        else
            for _, source in pairs(WritStylePrice.Price:obtainOrder()) do
                if data.priceList[source] ~= nil then
                    InformationTooltip:AddLine(zo_strformat(
                        "<<1>> : <<2>>",
                        WritStylePrice.Price:convertSourceKeyToStr(source),
                        data.priceList[source].priceTxt
                    ))
                end
            end
        end
    end)
    control:SetHandler("OnMouseExit", function(self)
        ClearTooltip(InformationTooltip)
    end)
end
