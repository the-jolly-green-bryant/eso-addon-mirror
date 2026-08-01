-- Shopkeeper UI Functions File
-- Last Updated September 15, 2014
-- Written August 2014 by Dan Stone (@khaibit) - dankitymao@gmail.com
-- Released under terms in license accompanying this file.
-- Distribution without license is prohibited!

-- Sort scrollList by price in 'ordering' order (asc = true as per ZOS)
-- Rather than using the built-in Lua quicksort, we use my own
-- implementation of Shellsort to save on memory.
function Shopkeeper:SortByPrice(ordering, scrollList)
  local listData = ZO_ScrollList_GetDataList(scrollList.list)
  
  if ordering then
    -- If they're viewing prices per-unit, then we need to sort on price / quantity.
    if self:ActiveSettings().showUnitPrice then
      Shopkeeper.shellSort(listData, function(sortA, sortB)
        -- In case quantity ends up 0 or nil somehow, let's not divide by it
        if sortA.data[6] and sortA.data[6] > 0 and sortB.data[6] and sortB.data[6] > 0 then
          return (sortA.data[5] / sortA.data[6]) > (sortB.data[5] / sortB.data[6])
        else return sortA.data[5] > sortB.data[5] end
      end)
    -- Otherwise just sort on pure price.
    else
      Shopkeeper.shellSort(listData, function(sortA, sortB)
        return sortA.data[5] > sortB.data[5]
      end)
    end
  else
    -- And the same thing with descending sort
    if self:ActiveSettings().showUnitPrice then
      Shopkeeper.shellSort(listData, function(sortA, sortB)
        -- In case quantity ends up 0 or nil somehow, let's not divide by it
        if sortA.data[6] and sortA.data[6] and sortB.data[6] and sortB.data[6] > 0 then
          return (sortA.data[5] / sortA.data[6]) < (sortB.data[5] / sortB.data[6])
        else return sortA.data[5] < sortB.data[5] end
      end)
    else
      Shopkeeper.shellSort(listData, function(sortA, sortB)
        return sortA.data[5] < sortB.data[5]
      end)
    end
  end
end

-- Sort the scrollList by time in 'ordering' order (asc = true as per ZOS).
function Shopkeeper:SortByTime(ordering, scrollList)
  local listData = ZO_ScrollList_GetDataList(scrollList.list)

  if ordering then
      Shopkeeper.shellSort(listData, function(sortA, sortB)
        return sortA.data[4] < sortB.data[4]
      end)
  else
      Shopkeeper.shellSort(listData, function(sortA, sortB)
        return sortA.data[4] > sortB.data[4]
      end)
  end
end

function SKScrollList:SetupSalesRow(control, data)
  control.buyer = GetControl(control, "Buyer")
  control.guild = GetControl(control, "Guild")
  control.icon = GetControl(control, "ItemIcon")
  control.quant = GetControl(control, "Quantity")
  control.itemName = GetControl(control, "ItemName")
  control.sellTime = GetControl(control, "SellTime")
  control.price = GetControl(control, "Price")
  local actualItem = Shopkeeper.acctSavedVariables.SalesData[data[1]][data[2]]['sales'][data[3]]
  actualItem.itemLink = Shopkeeper:UpdateItemLink(actualItem.itemLink)
  local actualItemIcon = Shopkeeper.acctSavedVariables.SalesData[data[1]][data[2]]['itemIcon']
  local isFullSize = string.find(control:GetName(), "^ShopkeeperWindow")

  local LMP = LibStub("LibMediaProvider-1.0")
  if LMP then
    local fontString = LMP:Fetch('font', Shopkeeper:ActiveSettings().windowFont) .. "|%d"

    if isFullSize then control.buyer:SetFont(string.format(fontString, 15)) end
    control.guild:SetFont(string.format(fontString, ((isFullSize and 15) or 11)))
    control.itemName:SetFont(string.format(fontString, ((isFullSize and 15) or 11)))
    control.quant:SetFont(string.format(fontString, ((isFullSize and 15) or 10)) .. "|soft-shadow-thin")
    control.sellTime:SetFont(string.format(fontString, ((isFullSize and 15) or 11)))
    control.price:SetFont(string.format(fontString, ((isFullSize and 15) or 11)))
  end

  -- Some extra stuff for the Buyer cell to handle double-click and color changes
  -- Plus add a marker if buyer is not in-guild (kiosk sale)
  if isFullSize then
    local buyerString = actualItem.buyer
    if actualItem.wasKiosk then buyerString = "|t16:16:/EsoUI/Art/icons/item_generic_coinbag.dds|t" .. buyerString end
    control.buyer:GetLabelControl():SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    control.buyer:SetText(buyerString)
    -- If the seller is the player, color the buyer green.  Otherwise, blue.
    local acctName = GetDisplayName()
    if string.lower(actualItem.seller) == string.lower(acctName) then
      control.buyer:SetNormalFontColor(0.18, 0.77, 0.05, 1)
      control.buyer:SetPressedFontColor(0.18, 0.77, 0.05, 1)
      control.buyer:SetMouseOverFontColor(0.32, 0.90, 0.18, 1)
    else
      control.buyer:SetNormalFontColor(0.21, 0.54, 0.94, 1)
      control.buyer:SetPressedFontColor(0.21, 0.54, 0.94, 1)
      control.buyer:SetMouseOverFontColor(0.34, 0.67, 1, 1)
    end
    control.buyer:SetHandler("OnMouseDoubleClick", function()
      if SCENE_MANAGER.currentScene.name == "mailSend" then ZO_MailSendToField:SetText(actualItem.buyer)
      else ZO_ChatWindowTextEntryEditBox:SetText("/w " .. actualItem.buyer .. " " .. ZO_ChatWindowTextEntryEditBox:GetText()) end
    end)
  end

  -- Guild cell
  control.guild:GetLabelControl():SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
  control.guild:SetText(actualItem.guild)

  -- Item Icon
  control.icon:SetHidden(false)
  control.icon:SetTexture(actualItemIcon)

  -- Item name cell
  control.itemName:GetLabelControl():SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
  control.itemName:SetText(zo_strformat("<<t:1>>", actualItem.itemLink))
  -- Insert the item link into the chat box, with a quick substitution so brackets show up
  control.itemName:SetHandler("OnMouseDoubleClick", function()
    ZO_ChatWindowTextEntryEditBox:SetText(ZO_ChatWindowTextEntryEditBox:GetText() .. string.gsub(actualItem.itemLink, "|H0", "|H1"))
  end)
  control.itemName:SetHandler("OnMouseEnter", function() Shopkeeper.ShowToolTip(actualItem.itemLink, control.itemName) end)
  control.itemName:SetHandler("OnMouseExit", function() ClearTooltip(ItemTooltip) end)

  -- Quantity cell
  if actualItem.quant == 1 then control.quant:SetHidden(true)
  else
    control.quant:SetHidden(false)
    control.quant:SetText(actualItem.quant)
  end

  -- Sale time cell
  control.sellTime:SetText(Shopkeeper.TextTimeSince(actualItem.timestamp, false))

  -- Handle the setting of whether or not to show pre-cut sale prices
  -- math.floor(number + 0.5) is a quick shorthand way to round for
  -- positive values.
  local dispPrice = actualItem.price
  local quantity = actualItem.quant
  local settingsToUse = Shopkeeper:ActiveSettings()
  if settingsToUse.showFullPrice then
    if settingsToUse.showUnitPrice and quantity > 0 then dispPrice = math.floor((dispPrice / quantity) + 0.5) end
  else
    local cutPrice = price * (1 - (GetTradingHouseCutPercentage() / 100))
    if settingsToUse.showUnitPrice and quantity > 0 then cutPrice = cutPrice / quantity end
    dispPrice = math.floor(cutPrice + 0.5)
  end

  -- Insert thousands separators for the price
  local stringPrice = Shopkeeper.LocalizedNumber(dispPrice)

  -- Finally, set the price
  control.price:SetText(stringPrice .. " |t16:16:EsoUI/Art/currency/currency_gold.dds|t")

  ZO_SortFilterList.SetupRow(self, control, data)
end

function SKScrollList:ColorRow(control, data, mouseIsOver)
  for i = 1, control:GetNumChildren() do
    local child = control:GetChild(i)
    if not child.nonRecolorable then
      if child:GetType() == CT_LABEL then
        if string.find(child:GetName(), "Price$") then child:SetColor(0.84, 0.71, 0.15, 1)
        else child:SetColor(1, 1, 1, 1) end
      end
    end
  end
end

function SKScrollList:Initialize(controlName)
  self.masterList = {}
  if controlName == "ShopkeeperWindow" then
    ZO_ScrollList_AddDataType(self.list, 1, "ShopkeeperDataRow", 36, function(control, data) self:SetupSalesRow(control, data) end)
  else
    ZO_ScrollList_AddDataType(self.list, 1, "ShopkeeperMiniDataRow", 36, function(control, data) self:SetupSalesRow(control, data) end)
  end
  self:RefreshData()
end

function SKScrollList:New(control)
  local skList = ZO_SortFilterList.New(self, control)
  skList:Initialize(control:GetName())
  if control:GetName() == "ShopkeeperWindow" then
    skList.sortHeaderGroup:SelectHeaderByKey("time")
    ZO_SortHeader_OnMouseExit(ShopkeeperWindowHeadersSellTime)
  else 
    skList.sortHeaderGroup:SelectHeaderByKey("miniTime")
    ZO_SortHeader_OnMouseExit(ShopkeeperMiniWindowHeadersSellTime)
  end
  Shopkeeper.functionPostHook(skList, "RefreshData", function()
    local texCon = skList.list.scrollbar:GetThumbTextureControl()
    if texCon:GetHeight() < 5 then skList.list.scrollbar:SetThumbTextureHeight(5) end
  end)
  Shopkeeper.functionPostHook(skList, "RefreshFilters", function()
    local texCon = skList.list.scrollbar:GetThumbTextureControl()
    if texCon:GetHeight() < 5 then skList.list.scrollbar:SetThumbTextureHeight(5) end
  end)
  return skList
end

function SKScrollList:FilterScrollList()
  local settingsToUse = Shopkeeper:ActiveSettings()
  local listData = ZO_ScrollList_GetDataList(self.list)
  ZO_ClearNumericallyIndexedTable(listData)
  local searchText = nil
  if settingsToUse.viewSize == "full" then searchText = ShopkeeperWindowSearchBox:GetText()
  else searchText = ShopkeeperMiniWindowSearchBox:GetText() end
  if searchText then searchText = string.gsub(string.lower(searchText), "^%s*(.-)%s*$", "%1") end

  if searchText == nil or searchText == "" then
    if Shopkeeper.viewMode == "self" then
      local seenIndexes = {}
      for _, indexes in pairs(Shopkeeper.SSIndex) do
        for i = 1, #indexes do
          local itemID = indexes[i][1]
          local itemData = indexes[i][2]
          local itemIndex = indexes[i][3]
          if itemID and itemData and itemIndex then
            if seenIndexes[itemID] == nil then seenIndexes[itemID] = {} end
            if seenIndexes[itemID][itemData] == nil then seenIndexes[itemID][itemData] = {} end
            if seenIndexes[itemID][itemData][itemIndex] == nil then
              seenIndexes[itemID][itemData][itemIndex] = true
              local actualItem = Shopkeeper.acctSavedVariables.SalesData[itemID][itemData]['sales'][itemIndex]
              table.insert(listData, ZO_ScrollList_CreateDataEntry(1, {itemID, itemData, itemIndex, actualItem.timestamp, actualItem.price, actualItem.quant}))
            end
          end
        end
      end
    else
      for k, v in pairs(Shopkeeper.acctSavedVariables.SalesData) do
        for j, dataList in pairs(v) do
          for i, item in ipairs(dataList['sales']) do
            table.insert(listData, ZO_ScrollList_CreateDataEntry(1, {k, j, i, item.timestamp, item.price, item.quant}))
          end
        end 
      end
    end
  else
    -- Break up search term into words
    local searchByWords = string.gmatch(searchText, "%S+")
    local indexToUse = ((Shopkeeper.viewMode == "self") and Shopkeeper.SSIndex) or Shopkeeper.SRIndex
    local intersectionIndexes = {}

    -- Build up a list of indexes matching each word, then compute the intersection
    -- of those sets
    for searchWord in searchByWords do
      local addedIndexes = {}
      for key, indexes in pairs(indexToUse) do
        local findStatus, findResult = pcall(string.find, key, searchWord)
        if findStatus then
          if findResult then
            for i = 1, #indexes do
              if not addedIndexes[indexes[i][1]] then addedIndexes[indexes[i][1]] = {} end
              if not addedIndexes[indexes[i][1]][indexes[i][2]] then addedIndexes[indexes[i][1]][indexes[i][2]] = {} end
              addedIndexes[indexes[i][1]][indexes[i][2]][indexes[i][3]] = true
            end
          end
        end
      end

      -- If this is the first(or only) word, the intersection is itself
      if NonContiguousCount(intersectionIndexes) == 0 then
        intersectionIndexes = addedIndexes
      else
        -- Compute the intersection of the two
        local newIntersection = {}
        for k, val in pairs(intersectionIndexes) do
          if addedIndexes[k] then
            for j, subval in pairs(val) do
              if addedIndexes[k][j] then
                for i in pairs(subval) do
                  if not newIntersection[k] then newIntersection[k] = {} end
                  if not newIntersection[k][j] then newIntersection[k][j] = {} end
                  newIntersection[k][j][i] = addedIndexes[k][j][i] 
                end
              end
            end
          end
        end
        intersectionIndexes = newIntersection
      end
    end

    -- Now that we have the intersection, actually build the search table
    for k, val in pairs(intersectionIndexes) do
      for j, subval in pairs(val) do
        for i in pairs(subval) do
          local actualItem = Shopkeeper.acctSavedVariables.SalesData[k][j]['sales'][i]
          table.insert(listData, ZO_ScrollList_CreateDataEntry(1, {k, j, i, actualItem.timestamp, actualItem.price, actualItem.quant}))
        end
      end
    end
  end
end

function SKScrollList:SortScrollList()
  if self.currentSortKey == "price" or self.currentSortKey == "miniPrice" then Shopkeeper:SortByPrice(self.currentSortOrder, self)
  else Shopkeeper:SortByTime(self.currentSortOrder, self) end
end

-- Handle the OnMoveStop event for the windows
function Shopkeeper:OnWindowMoveStop(windowMoved)
  local settingsToUse = Shopkeeper:ActiveSettings()

  if windowMoved == ShopkeeperWindow then
    settingsToUse.winLeft = ShopkeeperWindow:GetLeft()
    settingsToUse.winTop = ShopkeeperWindow:GetTop()
  elseif windowMoved == ShopkeeperMiniWindow then
    settingsToUse.miniWinLeft = ShopkeeperMiniWindow:GetLeft()
    settingsToUse.miniWinTop = ShopkeeperMiniWindow:GetTop()
  else
    settingsToUse.statsWinLeft = ShopkeeperStatsWindow:GetLeft()
    settingsToUse.statsWinTop = ShopkeeperStatsWindow:GetTop()
  end
end

-- Restore the window positions from saved vars
function Shopkeeper:RestoreWindowPosition()
  local settingsToUse = Shopkeeper:ActiveSettings()

  ShopkeeperWindow:ClearAnchors()
  ShopkeeperStatsWindow:ClearAnchors()
  ShopkeeperMiniWindow:ClearAnchors()

  ShopkeeperWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, settingsToUse.winLeft, settingsToUse.winTop)
  ShopkeeperStatsWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, settingsToUse.statsWinLeft, settingsToUse.statsWinTop)
  ShopkeeperMiniWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, settingsToUse.miniWinLeft, settingsToUse.miniWinTop)
end

-- Handle the changing of window font settings
function Shopkeeper:UpdateFonts()
  local LMP = LibStub("LibMediaProvider-1.0")
  if LMP then
    local font = LMP:Fetch('font', Shopkeeper:ActiveSettings().windowFont)
    local fontString = font .. "|%d"
    local mainButtonLabel = 14
    local mainTitle = 26
    local mainHeader = 17
    local miniButtonLabel = 11
    local miniTitle = 20
    local miniHeader = 12
    local miniQuant = 10

    -- Main Window
    ShopkeeperWindowHeadersBuyer:GetNamedChild("Name"):SetFont(string.format(fontString, mainHeader))
    ShopkeeperWindowHeadersGuild:GetNamedChild("Name"):SetFont(string.format(fontString, mainHeader))
    ShopkeeperWindowHeadersItemName:GetNamedChild("Name"):SetFont(string.format(fontString, mainHeader))
    ShopkeeperWindowHeadersSellTime:GetNamedChild("Name"):SetFont(string.format(fontString, mainHeader))
    ShopkeeperWindowHeadersPrice:GetNamedChild("Name"):SetFont(string.format(fontString, mainHeader))
    ShopkeeperWindowSearchBox:SetFont(string.format(fontString, mainButtonLabel))
    ShopkeeperWindowTitle:SetFont(string.format(fontString, mainTitle))
    ShopkeeperSwitchViewButton:SetFont(string.format(fontString, mainButtonLabel))
    ShopkeeperPriceSwitchButton:SetFont(string.format(fontString, mainButtonLabel))
    ShopkeeperResetButton:SetFont(string.format(fontString, mainButtonLabel))
    ShopkeeperRefreshButton:SetFont(string.format(fontString, mainButtonLabel))

    -- Mini Window
    ShopkeeperMiniWindowHeadersGuild:GetNamedChild("Name"):SetFont(string.format(fontString, miniHeader))
    ShopkeeperMiniWindowHeadersItemName:GetNamedChild("Name"):SetFont(string.format(fontString, miniHeader))
    ShopkeeperMiniWindowHeadersSellTime:GetNamedChild("Name"):SetFont(string.format(fontString, miniHeader))
    ShopkeeperMiniWindowHeadersPrice:GetNamedChild("Name"):SetFont(string.format(fontString, miniHeader))
    ShopkeeperMiniWindowSearchBox:SetFont(string.format(fontString, miniButtonLabel))
    ShopkeeperMiniWindowTitle:SetFont(string.format(fontString, miniTitle))
    ShopkeeperMiniSwitchViewButton:SetFont(string.format(fontString, miniButtonLabel))
    ShopkeeperMiniPriceSwitchButton:SetFont(string.format(fontString, miniButtonLabel))
    ShopkeeperMiniResetButton:SetFont(string.format(fontString, miniButtonLabel))
    ShopkeeperMiniRefreshButton:SetFont(string.format(fontString, miniButtonLabel))

    -- Stats Window
    ShopkeeperStatsWindowTitle:SetFont(string.format(fontString, mainTitle))
    ShopkeeperStatsWindowGuildChooserLabel:SetFont(string.format(fontString, mainHeader))
    ShopkeeperStatsGuildChooser.m_comboBox:SetFont(string.format(fontString, mainHeader))
    ShopkeeperStatsWindowItemsSoldLabel:SetFont(string.format(fontString, mainHeader))
    ShopkeeperStatsWindowTotalGoldLabel:SetFont(string.format(fontString, mainHeader))
    ShopkeeperStatsWindowBiggestSaleLabel:SetFont(string.format(fontString, mainHeader))
    ShopkeeperStatsWindowSliderSettingLabel:SetFont(string.format(fontString, mainHeader))
    ShopkeeperStatsWindowSliderLabel:SetFont(string.format(fontString, mainButtonLabel))
  end
end

function Shopkeeper:updateCalc()
  local stackSize = string.match(ShopkeeperPriceCalculatorStack:GetText(), "x (%d+)")
  local totalPrice = tonumber(ShopkeeperPriceCalculatorUnitCostAmount:GetText()) * tonumber(stackSize)
  ShopkeeperPriceCalculatorTotal:SetText("Total: " .. Shopkeeper.LocalizedNumber(totalPrice) .. " |t16:16:EsoUI/Art/currency/currency_gold.dds|t")
  TRADING_HOUSE:SetPendingPostPrice(totalPrice)
end

function Shopkeeper:addStatsPopupTooltip()
  -- Make sure we don't double-add stats (or double-calculate them if they bring
  -- up the same link twice) since we have to call this on Update rather than Show
if not self:ActiveSettings().showPricing or PopupTooltip.lastLink == nil or
    (self.activeTip and self.activeTip == PopupTooltip.lastLink) then return end -- thanks Garkin
  self.activeTip = PopupTooltip.lastLink
  local theIID = string.match(self.activeTip, "|H.-:item:(.-):")
  local itemIndex = self.makeIndexFromLink(self.activeTip)
  local tipStats = self:toolTipStats(tonumber(theIID), itemIndex)
  if tipStats then
    local tipLine = nil
    if tipStats['numDays'] < 2 then
      tipLine = string.format(GetString(SK_PRICETIP_ONEDAY), zo_strformat(GetString(SK_PRICETIP_SALES), tipStats['numSales']), tipStats['avgPrice'])
    else tipLine = string.format(GetString(SK_PRICETIP_MULTDAY), zo_strformat(GetString(SK_PRICETIP_SALES), tipStats['numSales']), tipStats['numDays'], tipStats['avgPrice']) end
    if tipLine then
      PopupTooltip:AddVerticalPadding(25)
      PopupTooltip:AddLine(tipLine)
    end
  end
end

function Shopkeeper:remStatsPopupTooltip() self.activeTip = nil end

-- ItemTooltips get used all over the place, we have to figure out
-- who the control generating the tooltip is so we know
-- how to grab the item data
function Shopkeeper:addStatsItemTooltip()
  local skMoc = moc()
  -- Make sure we don't double-add stats or try to add them to nothing
  -- Since we call this on Update rather than Show it gets called a lot
  -- even after the tip appears
  if not self:ActiveSettings().showPricing or
    (not skMoc or not skMoc:GetParent() or skMoc == self.tippingControl) then return end

  local itemLink = nil
  local mocParent = skMoc:GetParent():GetName()
  -- Store screen
  if mocParent == "ZO_StoreWindowListContents" then itemLink = GetStoreItemLink(skMoc.index)
  -- Store buyback screen
  elseif mocParent == "ZO_BuyBackListContents" then itemLink = GetBuybackItemLink(skMoc.index)
  -- Guild store posted items
  elseif mocParent == "ZO_TradingHousePostedItemsListContents" then
    local mocData = skMoc.dataEntry.data
    itemLink = GetTradingHouseListingItemLink(mocData.slotIndex)
  -- Guild store search
  elseif mocParent == "ZO_TradingHouseItemPaneSearchResultsContents" then
    local rData = skMoc.dataEntry and skMoc.dataEntry.data or nil
    -- The only thing with 0 time remaining should be guild tabards, no
    -- stats on those!
    if not rData or rData.timeRemaining == 0 then return end
    itemLink = GetTradingHouseSearchResultItemLink(rData.slotIndex)
  -- Guild store item posting
  elseif mocParent == "ZO_TradingHouseLeftPanePostItemFormInfo" then
    if skMoc.slotIndex and skMoc.bagId then itemLink = GetItemLink(skMoc.bagId, skMoc.slotIndex) end
  -- Player bags (and bank)
  elseif mocParent == "ZO_PlayerInventoryBackpackContents" or
         mocParent == "ZO_PlayerBankBackpackContents" or
         mocParent == "ZO_GuildBankBackpackContents" then
         if skMoc and skMoc.dataEntry then
            local rData = skMoc.dataEntry.data
            itemLink = GetItemLink(rData.bagId, rData.slotIndex)
         end
  -- Worn equipment
  elseif mocParent == "ZO_Character" then itemLink = GetItemLink(skMoc.bagId, skMoc.slotIndex)
  -- Loot window if autoloot is disabled
  elseif mocParent == "ZO_LootAlphaContainerListContents" then itemLink = GetLootItemLink(skMoc.dataEntry.data.lootId)
  elseif mocParent == "ZO_MailInboxMessageAttachments" then itemLink = GetAttachedItemLink(MAIL_INBOX:GetOpenMailId(), skMoc.id, LINK_STYLE_DEFAULT)
  elseif mocParent == "ZO_MailSendAttachments" then itemLink = GetMailQueuedAttachmentLink(skMoc.id, LINK_STYLE_DEFAULT)
  -- Shopkeeper windows
  else
    local mocGP = skMoc:GetParent():GetParent()
    if mocGP and (mocGP:GetName() == "ShopkeeperWindowListContents" or mocGP:GetName() == "ShopkeeperMiniWindowListContents") then
      local itemLabel = skMoc:GetLabelControl()
      if itemLabel then itemLink = itemLabel:GetText() end
    end
  end

  if itemLink then
    self.tippingControl = skMoc
    local theIID = string.match(itemLink, "|H.-:item:(.-):")
    local itemIndex = self.makeIndexFromLink(itemLink)
    local tipStats = self:toolTipStats(tonumber(theIID), itemIndex)
    if tipStats then
      local tipLine = nil
      if tipStats['numDays'] < 2 then
        tipLine = string.format(GetString(SK_PRICETIP_ONEDAY), zo_strformat(GetString(SK_PRICETIP_SALES), tipStats['numSales']), tipStats['avgPrice'])
      else tipLine = string.format(GetString(SK_PRICETIP_MULTDAY), zo_strformat(GetString(SK_PRICETIP_SALES), tipStats['numSales']), tipStats['numDays'], tipStats['avgPrice']) end
      if tipLine then
        ItemTooltip:AddVerticalPadding(25)
        ItemTooltip:AddLine(tipLine)
      end
    end
  end
end

function Shopkeeper:remStatsItemTooltip() Shopkeeper.tippingControl = nil end

-- Display item tooltips
function Shopkeeper.ShowToolTip(itemName, itemButton)
  InitializeTooltip(ItemTooltip, itemButton)
  ItemTooltip:SetLink(itemName)
end

function Shopkeeper:HeaderToolTip(control, tipString)
  InitializeTooltip(InformationTooltip, control, BOTTOM, 0, -5)
  SetTooltipText(InformationTooltip, tipString)
end

-- Update all the fields of the stats window based on the response from SalesStats()
function Shopkeeper:UpdateStatsWindow(guildName)
  if not guildName or guildName == "" then guildName = "SK_STATS_TOTAL" end
  local sliderLevel = ShopkeeperStatsWindowSlider:GetValue()
  self.newStats = self:SalesStats(sliderLevel)

  -- Hide the slider if there's less than a day of data
  -- and set the slider's range for the new day range returned
  ShopkeeperStatsWindowSliderLabel:SetHidden(false)
  ShopkeeperStatsWindowSlider:SetHidden(false)
  ShopkeeperStatsWindowSlider:SetMinMax(1, (self.newStats['totalDays']))

  if self.newStats['totalDays'] == nil or self.newStats['totalDays'] < 2 then
    ShopkeeperStatsWindowSlider:SetHidden(true)
    ShopkeeperStatsWindowSliderLabel:SetHidden(true)
    sliderLevel = 1
  elseif sliderLevel > (self.newStats['totalDays']) then sliderLevel = self.newStats['totalDays'] end

  -- Set the time range label appropriately
  if sliderLevel == self.newStats['totalDays'] then ShopkeeperStatsWindowSliderSettingLabel:SetText(GetString(SK_STATS_TIME_ALL))
  else ShopkeeperStatsWindowSliderSettingLabel:SetText(zo_strformat(GetString(SK_STATS_TIME_SOME), sliderLevel)) end

  -- Grab which guild is selected
  local guildSelected = GetString(SK_STATS_ALL_GUILDS)
  if guildName ~= "SK_STATS_TOTAL" then guildSelected = guildName end
  local guildDropdown = ZO_ComboBox_ObjectFromContainer(ShopkeeperStatsGuildChooser)
  guildDropdown:SetSelectedItem(guildSelected)

  -- And set the rest of the stats window up with data from the appropriate
  -- guild (or overall data)
  ShopkeeperStatsWindowItemsSoldLabel:SetText(string.format(GetString(SK_STATS_ITEMS_SOLD), self.LocalizedNumber(self.newStats['numSold'][guildName]), (self.newStats['kioskPercent'][guildName] or "0")))
  ShopkeeperStatsWindowTotalGoldLabel:SetText(string.format(GetString(SK_STATS_TOTAL_GOLD), self.LocalizedNumber(self.newStats['totalGold'][guildName]), self.LocalizedNumber(self.newStats['avgGold'][guildName])))
  ShopkeeperStatsWindowBiggestSaleLabel:SetText(string.format(GetString(SK_STATS_BIGGEST), zo_strformat("<<t:1>>", self.newStats['biggestSale'][guildName][2]), self.LocalizedNumber(self.newStats['biggestSale'][guildName][1])))
end

-- Switches the main window between full and half size.  Really this is hiding one
-- and showing the other, but close enough ;)  Also makes the scene adjustments
-- necessary to maintain the desired mail/trading house behaviors.  Copies the
-- contents of the search box and the current sorting settings so they're the
-- same on the other window when it appears.
function Shopkeeper:ToggleViewMode()
  local settingsToUse = Shopkeeper:ActiveSettings()
  -- Switching to mini view
  if settingsToUse.viewSize == "full" then
    settingsToUse.viewSize = "half"
    ShopkeeperMiniWindowSearchBox:SetText(ShopkeeperWindowSearchBox:GetText())
    ShopkeeperWindow:SetHidden(true)
    self.miniScrollList.sortHeaderGroup.sortDirection = not self.scrollList.sortHeaderGroup.sortDirection
    self.miniScrollList.currentSortOrder = self.scrollList.currentSortOrder
    local selectedHeader = self.scrollList.sortHeaderGroup.selectedSortHeader
    self.miniScrollList.sortHeaderGroup.selectedSortHeader.selected = nil
    if selectedHeader == ShopkeeperWindowHeadersPrice then 
      ShopkeeperMiniWindowHeadersPrice.selected = true
      self.miniScrollList.sortHeaderGroup.selectedSortHeader = ShopkeeperMiniWindowHeadersPrice
      self.miniScrollList.sortHeaderGroup:SelectHeaderByKey("miniPrice", true)
      self.miniScrollList.currentSortKey = "miniPrice"
      ZO_SortHeader_OnMouseExit(ShopkeeperMiniWindowHeadersPrice)
    else
      ShopkeeperMiniWindowHeadersSellTime.selected = true
      self.miniScrollList.sortHeaderGroup.selectedSortHeader = ShopkeeperMiniWindowHeadersSellTime
      self.miniScrollList.sortHeaderGroup:SelectHeaderByKey("miniTime", true)
      self.miniScrollList.currentSortKey = "miniTime"
      ZO_SortHeader_OnMouseExit(ShopkeeperMiniWindowHeadersSellTime)      
    end
    if not self.listIsDirty["mini"] then self.miniScrollList:RefreshFilters() end
    ShopkeeperMiniWindow:SetHidden(false)

    if settingsToUse.openWithMail then
      MAIL_INBOX_SCENE:RemoveFragment(self.uiFragment)
      MAIL_SEND_SCENE:RemoveFragment(self.uiFragment)
      MAIL_INBOX_SCENE:AddFragment(self.miniUiFragment)
      MAIL_SEND_SCENE:AddFragment(self.miniUiFragment)
    end

    if settingsToUse.openWithStore then
      TRADING_HOUSE_SCENE:RemoveFragment(self.uiFragment)
      TRADING_HOUSE_SCENE:AddFragment(self.miniUiFragment)
    end
  -- Switching to full view
  else
    settingsToUse.viewSize = "full"
    ShopkeeperWindowSearchBox:SetText(ShopkeeperMiniWindowSearchBox:GetText())
    ShopkeeperMiniWindow:SetHidden(true)
    self.scrollList.sortHeaderGroup.sortDirection = not self.miniScrollList.sortHeaderGroup.sortDirection
    self.scrollList.currentSortOrder = self.miniScrollList.currentSortOrder
    local selectedHeader = self.miniScrollList.sortHeaderGroup.selectedSortHeader
    self.scrollList.sortHeaderGroup.selectedSortHeader.selected = nil
    if selectedHeader == ShopkeeperMiniWindowHeadersPrice then
      ShopkeeperWindowHeadersPrice.selected = true
      self.scrollList.sortHeaderGroup.selectedSortHeader = ShopkeeperWindowHeadersPrice
      self.scrollList.sortHeaderGroup:SelectHeaderByKey("price", true)
      self.ScrollList.currentSortKey = "price"
      ZO_SortHeader_OnMouseExit(ShopkeeperWindowHeadersPrice)      
    else
      ShopkeeperWindowHeadersSellTime.selected = true
      self.scrollList.sortHeaderGroup.selectedSortHeader = ShopkeeperWindowHeadersSellTime
      self.scrollList.sortHeaderGroup:SelectHeaderByKey("time", true)
      self.scrollList.currentSortKey = "time"
      ZO_SortHeader_OnMouseExit(ShopkeeperWindowHeadersSellTime)      
    end
    if not self.listIsDirty["full"] then self.scrollList:RefreshFilters() end
    ShopkeeperWindow:SetHidden(false)

    if settingsToUse.openWithMail then
      MAIL_INBOX_SCENE:RemoveFragment(self.miniUiFragment)
      MAIL_SEND_SCENE:RemoveFragment(self.miniUiFragment)
      MAIL_INBOX_SCENE:AddFragment(self.uiFragment)
      MAIL_SEND_SCENE:AddFragment(self.uiFragment)
    end

    if settingsToUse.openWithStore then
      TRADING_HOUSE_SCENE:RemoveFragment(self.miniUiFragment)
      TRADING_HOUSE_SCENE:AddFragment(self.uiFragment)
    end
  end
end

-- Set the visibility status of the main window to the opposite of its current status
function Shopkeeper.ToggleShopkeeperWindow()
  if Shopkeeper:ActiveSettings().viewSize == "full" then
    ShopkeeperMiniWindow:SetHidden(true)
    ShopkeeperWindow:SetHidden(not ShopkeeperWindow:IsHidden())
  else
    ShopkeeperWindow:SetHidden(true)
    ShopkeeperMiniWindow:SetHidden(not ShopkeeperMiniWindow:IsHidden())
  end
end

-- Set the visibility status of the stats window to the opposite of its current status
function Shopkeeper.ToggleShopkeeperStatsWindow()
  if ShopkeeperStatsWindow:IsHidden() then Shopkeeper:UpdateStatsWindow("SK_STATS_TOTAL") end
  ShopkeeperStatsWindow:SetHidden(not ShopkeeperStatsWindow:IsHidden())
end

-- Switch between all sales and your sales
function Shopkeeper:SwitchViewMode()
  if self.viewMode == "self" then
    ShopkeeperSwitchViewButton:SetText(GetString(SK_VIEW_YOUR_SALES))
    ShopkeeperWindowTitle:SetText("Shopkeeper - " .. GetString(SK_ALL_SALES_TITLE))
    ShopkeeperMiniSwitchViewButton:SetText(GetString(SK_VIEW_YOUR_SALES))
    ShopkeeperMiniWindowTitle:SetText("Shopkeeper - " .. GetString(SK_ALL_SALES_TITLE))
    self.viewMode = "all"
  else
    ShopkeeperSwitchViewButton:SetText(GetString(SK_VIEW_ALL_SALES))
    ShopkeeperWindowTitle:SetText("Shopkeeper - " .. GetString(SK_YOUR_SALES_TITLE))
    ShopkeeperMiniSwitchViewButton:SetText(GetString(SK_VIEW_ALL_SALES))
    ShopkeeperMiniWindowTitle:SetText("Shopkeeper - " .. GetString(SK_YOUR_SALES_TITLE))
    self.viewMode = "self"
  end

  if Shopkeeper:ActiveSettings().viewSize == "full" then
    self.scrollList:RefreshFilters()
    ZO_Scroll_ResetToTop(self.scrollList.list)
  else 
    self.miniScrollList:RefreshFilters()
    ZO_Scroll_ResetToTop(self.miniScrollList.list)
  end
end

-- Switch between total price mode and unit price mode
function Shopkeeper:SwitchPriceMode()
  local settingsToUse = Shopkeeper:ActiveSettings()
  if settingsToUse.showUnitPrice then
    settingsToUse.showUnitPrice = false
    ShopkeeperPriceSwitchButton:SetText(GetString(SK_SHOW_UNIT))
    ShopkeeperWindowHeadersPrice:GetNamedChild("Name"):SetText(GetString(SK_PRICE_COLUMN))
    ShopkeeperMiniPriceSwitchButton:SetText(GetString(SK_SHOW_UNIT))
    ShopkeeperMiniWindowHeadersPrice:GetNamedChild("Name"):SetText(GetString(SK_PRICE_COLUMN))
  else
    settingsToUse.showUnitPrice = true
    ShopkeeperPriceSwitchButton:SetText(GetString(SK_SHOW_TOTAL))
    ShopkeeperWindowHeadersPrice:GetNamedChild("Name"):SetText(GetString(SK_PRICE_EACH_COLUMN))
    ShopkeeperMiniPriceSwitchButton:SetText(GetString(SK_SHOW_TOTAL))
    ShopkeeperMiniWindowHeadersPrice:GetNamedChild("Name"):SetText(GetString(SK_PRICE_EACH_COLUMN))
  end

  if settingsToUse.viewSize == "full" then Shopkeeper.scrollList:RefreshFilters()
  else Shopkeeper.miniScrollList:RefreshFilters() end
end

-- Update the stats window if the slider in it moved
function Shopkeeper.OnStatsSliderMoved(self, sliderLevel, eventReason)
  local guildDropdown = ZO_ComboBox_ObjectFromContainer(ShopkeeperStatsGuildChooser)
  local selectedGuild = guildDropdown:GetSelectedItem()
  if selectedGuild == GetString(SK_STATS_ALL_GUILDS) then selectedGuild = "SK_STATS_TOTAL" end
  Shopkeeper:UpdateStatsWindow(selectedGuild)
end

-- Set up the labels and tooltips from translation files and do a couple other UI
-- setup routines
function Shopkeeper:SetupShopkeeperWindow()
  local settingsToUse = self:ActiveSettings()
  -- Shopkeeper button in guild store screen
  local reopenShopkeeper = CreateControlFromVirtual("ShopkeeperReopenButton", ZO_TradingHouseLeftPane, "ZO_DefaultButton")
  reopenShopkeeper:SetAnchor(CENTER, ZO_TradingHouseLeftPane, BOTTOM, 0, 5)
  reopenShopkeeper:SetWidth(200)
  reopenShopkeeper:SetText("Shopkeeper")
  reopenShopkeeper:SetHandler("OnClicked", self.ToggleShopkeeperWindow)
  local skCalc = CreateControlFromVirtual("ShopkeeperPriceCalculator", ZO_TradingHouseLeftPanePostItem, "ShopkeeperPriceCalc")
  skCalc:SetAnchor(BOTTOM, reopenShopkeeper, TOP, 0, -4)

  -- Shopkeeper button in mail screen
  local shopkeeperMail = CreateControlFromVirtual("ShopkeeperMailButton", ZO_MailInbox, "ZO_DefaultButton")
  shopkeeperMail:SetAnchor(TOPLEFT, ZO_MailInbox, TOPLEFT, 100, 4)
  shopkeeperMail:SetWidth(200)
  shopkeeperMail:SetText("Shopkeeper")
  shopkeeperMail:SetHandler("OnClicked", self.ToggleShopkeeperWindow)

  -- Stats dropdown choice box
  local shopkeeperStatsGuild = CreateControlFromVirtual("ShopkeeperStatsGuildChooser", ShopkeeperStatsWindow, "ShopkeeperStatsGuildDropdown")
  shopkeeperStatsGuild:SetDimensions(270,25)
  shopkeeperStatsGuild:SetAnchor(LEFT, ShopkeeperStatsWindowGuildChooserLabel, RIGHT, 5, 0)
  shopkeeperStatsGuild.m_comboBox:SetSortsItems(false)

  -- Set sort column headers and search label from translation
  local LMP = LibStub("LibMediaProvider-1.0")
  local fontString = "ZoFontGameLargeBold"
  local miniFontString = "ZoFontGameLargeBold"
  if LMP then
    local font = LMP:Fetch('font', self:ActiveSettings().windowFont)
    fontString = font .. "|17"
    miniFontString = font .. "|12"
  end
  ShopkeeperWindowHeadersBuyer:GetNamedChild("Name"):SetText(GetString(SK_BUYER_COLUMN))
  ShopkeeperWindowHeadersGuild:GetNamedChild("Name"):SetText(GetString(SK_GUILD_COLUMN))
  ShopkeeperWindowHeadersItemName:GetNamedChild("Name"):SetText(GetString(SK_ITEM_COLUMN))
  ShopkeeperWindowHeadersSellTime:GetNamedChild("Name"):SetModifyTextType(MODIFY_TEXT_TYPE_NONE)
  ZO_SortHeader_Initialize(ShopkeeperWindowHeadersSellTime, GetString(SK_TIME_COLUMN), "time", ZO_SORT_ORDER_DOWN, TEXT_ALIGN_LEFT, fontString)
  ShopkeeperMiniWindowHeadersGuild:GetNamedChild("Name"):SetText(GetString(SK_GUILD_COLUMN))
  ShopkeeperMiniWindowHeadersItemName:GetNamedChild("Name"):SetText(GetString(SK_ITEM_COLUMN))
  ShopkeeperMiniWindowHeadersSellTime:GetNamedChild("Name"):SetModifyTextType(MODIFY_TEXT_TYPE_NONE)
  ZO_SortHeader_Initialize(ShopkeeperMiniWindowHeadersSellTime, GetString(SK_TIME_COLUMN), "miniTime", ZO_SORT_ORDER_DOWN, TEXT_ALIGN_LEFT, miniFontString)

  ShopkeeperWindowHeadersPrice:GetNamedChild("Name"):SetModifyTextType(MODIFY_TEXT_TYPE_NONE)
  ShopkeeperWindowHeadersPrice:GetNamedChild("Name"):SetColor(0.84, 0.71, 0.15, 1)
  ShopkeeperMiniWindowHeadersPrice:GetNamedChild("Name"):SetModifyTextType(MODIFY_TEXT_TYPE_NONE)
  ShopkeeperMiniWindowHeadersPrice:GetNamedChild("Name"):SetColor(0.84, 0.71, 0.15, 1)
  if settingsToUse.showUnitPrice then
    ZO_SortHeader_Initialize(ShopkeeperWindowHeadersPrice, GetString(SK_PRICE_EACH_COLUMN), "price", ZO_SORT_ORDER_DOWN, TEXT_ALIGN_LEFT, fontString)
    ZO_SortHeader_Initialize(ShopkeeperMiniWindowHeadersPrice, GetString(SK_PRICE_EACH_COLUMN), "miniPrice", ZO_SORT_ORDER_DOWN, TEXT_ALIGN_LEFT, miniFontString)
  else
    ZO_SortHeader_Initialize(ShopkeeperWindowHeadersPrice, GetString(SK_PRICE_COLUMN), "price", ZO_SORT_ORDER_DOWN, TEXT_ALIGN_LEFT, fontString)
    ZO_SortHeader_Initialize(ShopkeeperMiniWindowHeadersPrice, GetString(SK_PRICE_COLUMN), "miniPrice", ZO_SORT_ORDER_DOWN, TEXT_ALIGN_LEFT, miniFontString)
  end

  -- Set second half of window title from translation
  ShopkeeperWindowTitle:SetText("Shopkeeper - " .. GetString(SK_YOUR_SALES_TITLE))
  ShopkeeperMiniWindowTitle:SetText("Shopkeeper - " .. GetString(SK_YOUR_SALES_TITLE))

  -- And set the stats window title and slider label from translation
  ShopkeeperStatsWindowTitle:SetText("Shopkeeper " .. GetString(SK_STATS_TITLE))
  ShopkeeperStatsWindowGuildChooserLabel:SetText(GetString(SK_GUILD_COLUMN) .. ": ")
  ShopkeeperStatsWindowSliderLabel:SetText(GetString(SK_STATS_DAYS))

  -- Set up some helpful tooltips for the Time and Price column headers
  ZO_SortHeader_SetTooltip(ShopkeeperWindowHeadersSellTime, GetString(SK_SORT_TIME_TOOLTIP))
  ZO_SortHeader_SetTooltip(ShopkeeperWindowHeadersPrice, GetString(SK_SORT_PRICE_TOOLTIP))
  ZO_SortHeader_SetTooltip(ShopkeeperMiniWindowHeadersSellTime, GetString(SK_SORT_TIME_TOOLTIP))
  ZO_SortHeader_SetTooltip(ShopkeeperMiniWindowHeadersPrice, GetString(SK_SORT_PRICE_TOOLTIP))

  -- Scroll list init
  self.scrollList = SKScrollList:New(ShopkeeperWindow)
  self.scrollList:Initialize()
  self.functionPostHook(self.scrollList.sortHeaderGroup, "OnHeaderClicked", function(self, header, suppressCallbacks)
    if header == ShopkeeperWindowHeadersPrice then 
      if header.mouseIsOver then ShopkeeperWindowHeadersPrice:GetNamedChild("Name"):SetColor(0.95, 0.92, 0.26, 1)
      else ShopkeeperWindowHeadersPrice:GetNamedChild("Name"):SetColor(0.84, 0.81, 0.15, 1) end
    else ShopkeeperWindowHeadersPrice:GetNamedChild("Name"):SetColor(0.84, 0.71, 0.15, 1) end
  end)
  self.handlerPostHook(ShopkeeperWindowHeadersPrice, "OnMouseExit", function()
    if ShopkeeperWindowHeadersPrice.selected then ShopkeeperWindowHeadersPrice:GetNamedChild("Name"):SetColor(0.84, 0.81, 0.15, 1)
    else ShopkeeperWindowHeadersPrice:GetNamedChild("Name"):SetColor(0.84, 0.71, 0.15, 1) end
  end)
  self.handlerPostHook(ShopkeeperWindowHeadersPrice, "OnMouseEnter", function(control)
    if control == ShopkeeperWindowHeadersPrice then ShopkeeperWindowHeadersPrice:GetNamedChild("Name"):SetColor(0.84, 0.81, 0.15, 1)
    else ShopkeeperWindowHeadersPrice:GetNamedChild("Name"):SetColor(0.84, 0.71, 0.15, 1) end
  end)
  self.miniScrollList = SKScrollList:New(ShopkeeperMiniWindow)
  self.miniScrollList:Initialize()
  self.functionPostHook(self.miniScrollList.sortHeaderGroup, "OnHeaderClicked", function()
    ShopkeeperMiniWindowHeadersPrice:GetNamedChild("Name"):SetColor(0.84, 0.71, 0.15, 1)
  end)
  self.handlerPostHook(ShopkeeperMiniWindowHeadersPrice, "OnMouseExit", function()
    ShopkeeperMiniWindowHeadersPrice:GetNamedChild("Name"):SetColor(0.84, 0.71, 0.15, 1)
  end)
  self.handlerPostHook(ShopkeeperMiniWindowHeadersPrice, "OnMouseEnter", function()
    ShopkeeperMiniWindowHeadersPrice:GetNamedChild("Name"):SetColor(0.84, 0.71, 0.15, 1)
  end)

  -- View switch button
  ShopkeeperSwitchViewButton:SetText(GetString(SK_VIEW_ALL_SALES))
  ShopkeeperMiniSwitchViewButton:SetText(GetString(SK_VIEW_ALL_SALES))

  -- Total / unit price switch button
  if settingsToUse.showUnitPrice then
    ShopkeeperPriceSwitchButton:SetText(GetString(SK_SHOW_TOTAL))
    ShopkeeperMiniPriceSwitchButton:SetText(GetString(SK_SHOW_TOTAL))
  else
    ShopkeeperPriceSwitchButton:SetText(GetString(SK_SHOW_UNIT))
    ShopkeeperMiniPriceSwitchButton:SetText(GetString(SK_SHOW_UNIT))
  end

  -- Spinny animations that display while SK is scanning
	ShopkeeperWindowLoadingIcon.animation = ANIMATION_MANAGER:CreateTimelineFromVirtual("LoadIconAnimation", ShopkeeperWindowLoadingIcon)
	ShopkeeperMiniWindowLoadingIcon.animation = ANIMATION_MANAGER:CreateTimelineFromVirtual("LoadIconAnimation", ShopkeeperMiniWindowLoadingIcon)

  -- Refresh button
  ShopkeeperRefreshButton:SetText(GetString(SK_REFRESH_LABEL))
  ShopkeeperMiniRefreshButton:SetText(GetString(SK_REFRESH_LABEL))

  -- Reset button and confirmation dialog
  ShopkeeperResetButton:SetText(GetString(SK_RESET_LABEL))
  ShopkeeperMiniResetButton:SetText(GetString(SK_RESET_LABEL))
  local confirmDialog = {
    title = { text = GetString(SK_RESET_CONFIRM_TITLE) },
    mainText = { text = GetString(SK_RESET_CONFIRM_MAIN) },
    buttons = {
      {
        text = SI_DIALOG_ACCEPT,
        callback = function() self:DoReset() end
      },
      { text = SI_DIALOG_CANCEL }
    }
  }
  ZO_Dialogs_RegisterCustomDialog("ShopkeeperResetConfirmation", confirmDialog)

  -- Stats buttons
  ShopkeeperWindowStatsButton:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, GetString(SK_STATS_TOOLTIP)) end)
  ShopkeeperMiniWindowStatsButton:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, GetString(SK_STATS_TOOLTIP)) end)

  -- View size change buttons
  ShopkeeperWindowViewSizeButton:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, GetString(SK_SIZE_TOOLTIP)) end)
  ShopkeeperMiniWindowViewSizeButton:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, GetString(SK_SIZE_TOOLTIP)) end)

  -- Slider setup
  ShopkeeperStatsWindowSlider:SetValue(32)

  -- We're all set, so make sure we're using the right font to finish up
  self:UpdateFonts()
end