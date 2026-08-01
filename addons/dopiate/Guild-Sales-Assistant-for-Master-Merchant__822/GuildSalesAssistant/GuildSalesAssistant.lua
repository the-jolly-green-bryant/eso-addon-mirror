-- written by Philgo68
-- updates and changes dOpiate

GuildSalesAssistant = { }

GuildSalesAssistant.name = "GuildSalesAssistant"
GuildSalesAssistant.MasterMerchantEdition = true
 
function GuildSalesAssistant:InitializeMM()
  self.acctSavedVariables = ZO_SavedVars:NewAccountWide("GuildSalesAssistantSavedVars", 1, GetDisplayName(), { })
  if not self.acctSavedVariables.SalesData then self.acctSavedVariables.SalesData = { } end
  self.salesData = self.acctSavedVariables.SalesData
  self.acctSavedVariables.newestItem = self.acctSavedVariables.newestItem or {}
  self.acctSavedVariables.lastScan = self.acctSavedVariables.lastScan or {}
end

function GuildSalesAssistant:LoadInitialData(salesDataMM)
  -- If we don't have any GSA data yet, start with the MerchantMaster data
  if salesDataMM == nil then return end
  if NonContiguousCount(self.salesData) == 0 then
    local thePlayer = string.lower(GetDisplayName())
    for k, v in pairs(salesDataMM) do
      for j, dataList in pairs(v) do
        for i = 1, #dataList['sales'], 1 do
          local newSalesItem = dataList['sales'][i]
          if string.lower(newSalesItem.seller) == thePlayer then
            if not self.salesData[k] then self.salesData[k] = { } end
            if self.salesData[k][j] then
              table.insert(self.salesData[k][j]['sales'], newSalesItem)
            else
              local iconForItem, _, _, _ = GetItemLinkInfo(newSalesItem.itemLink)
              self.salesData[k][j] = {
                itemIcon = iconForItem,
                sales = { newSalesItem }
              }
            end
            self.acctSavedVariables.newestItem[newSalesItem.guild] = math.max(newSalesItem.timestamp, self.acctSavedVariables.newestItem[newSalesItem.guild] or 0)
          end
        end
      end
    end
  end
end

function GuildSalesAssistant:TrimHistory(epochBack)
  if self.salesData then
    for k, v in pairs(self.salesData) do
      for j, dataList in pairs(v) do
        -- We iterate backwards here so we can remove entries without breaking
        -- the for loop
        for i = #dataList['sales'], 1, -1 do
          if type(dataList['sales'][i]['timestamp']) ~= 'number' or dataList['sales'][i]['timestamp'] < epochBack then
            table.remove(dataList['sales'], i)
          end
        end
        -- If we just deleted all instances of this ID/data combo, clear the bucket out
        if #dataList['sales'] < 1 then v[j] = nil end
      end
      -- Similarly, if we just deleted all data combos of this ID, clear the bucket out
      if NonContiguousCount(v) < 1 then self.salesData[k] = nil end
    end
  end
end

function GuildSalesAssistant.makeIndexFromLink(itemLink)
  local levelReq = GetItemLinkRequiredLevel(itemLink)
  local valueItem = GetItemLinkValue(itemLink)
  local itemQuality = GetItemLinkQuality(itemLink)
  local itemTrait = GetItemLinkTraitInfo(itemLink)
	local index = levelReq .. ':' .. valueItem .. ':' .. itemQuality .. ':' .. itemTrait 

  return index
end

function GuildSalesAssistant:addToHistoryTables(theEvent)
    
  local theIID = string.match(theEvent.itemName, '|H.-:item:(.-):')
  if theIID == nil then return end

  theIID = tonumber(theIID)
  local itemIndex = self.makeIndexFromLink(theEvent.itemName)

  if not self.salesData[theIID] then self.salesData[theIID] = { } end

  local newSalesItem =
  {
    buyer = theEvent.buyer,
    guild = theEvent.guild,
    itemLink = string.gsub(theEvent.itemName, '|h|h', '|h' .. GetItemLinkName(theEvent.itemName) .. '|h'),
    quant = theEvent.quant,
    timestamp = theEvent.saleTime,
    price = theEvent.salePrice,
    seller = theEvent.seller,
    wasKiosk = theEvent.kioskSale,
    id = theEvent.id,
    itemname = GetItemLinkName(theEvent.itemName)																																								--dOpiate
  }
  if self.salesData[theIID][itemIndex] then
    table.insert(self.salesData[theIID][itemIndex]['sales'], newSalesItem)
    insertedIndex = #self.salesData[theIID][itemIndex]['sales']
  else
    local iconForItem, _, _, _ = GetItemLinkInfo(theEvent.itemName)
    self.salesData[theIID][itemIndex] = {
      itemIcon = iconForItem,
      sales = { newSalesItem }
    }
  end
end

function GuildSalesAssistant:InsertEvent(theEvent)
  --d('InsertEvent: ')  
  --d(theEvent)
  
  self.acctSavedVariables.newestItem[theEvent.guild] = theEvent.saleTime
  
  if GetDiffBetweenTimeStamps(theEvent.saleTime, self.lastSaleTime) > 1 and
    theEvent.itemName ~= nil and theEvent.seller ~= nil and theEvent.buyer ~= nil and theEvent.salePrice ~= nil
    and theEvent.seller == GetDisplayName() then
    -- Insert the entry into the SalesData table
    self:addToHistoryTables(theEvent)
  end
end

function GuildSalesAssistant:InitLastSaleTime(guildName)
  self.lastSaleTime = self.acctSavedVariables.newestItem[guildName] or self.acctSavedVariables.lastScan[guildName] or 0
  --d('InitLastSaleTime: ' .. guildName .. ' ' .. self.lastSaleTime)
end

function GuildSalesAssistant:GuildScanDone(guildName, requestTimestamp)
  --d('GuildScanDone: ' .. guildName)
  self.acctSavedVariables.lastScan[guildName] = requestTimestamp
end

