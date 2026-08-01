-- Shopkeeper Utility Functions File
-- Last Updated September 15, 2014
-- Written August 2014 by Dan Stone (@khaibit) - dankitymao@gmail.com
-- Released under terms in license accompanying this file.
-- Distribution without license is prohibited!

-- Lua's table.sort function uses quicksort.  Here I implement
-- Shellsort in Lua for better memory efficiency.
-- (http://en.wikipedia.org/wiki/Shellsort)
function Shopkeeper.shellSort(inputTable, comparison, numElements)
  numElements = numElements or #inputTable
  for _, gapVal in ipairs(Shopkeeper.shellGaps) do
    for i = gapVal + 1, numElements do
      local tableVal = inputTable[i]
      for j = i - gapVal, 1, -gapVal do
        local testVal = inputTable[j]
        if not comparison(tableVal, testVal) then break end
        inputTable[i] = testVal
        i = j
      end
      inputTable[i] = tableVal
    end
  end

  -- Don't really *need* to do this but for consistency's sake...
  return inputTable
end

-- The index consists of the item's required level, required vet
-- level, quality, and trait(if any), separated by colons.
function Shopkeeper.makeIndexFromLink(itemLink)
  local levelReq = GetItemLinkRequiredLevel(itemLink)
  local vetReq = GetItemLinkRequiredVeteranRank(itemLink)
  local itemQuality = GetItemLinkQuality(itemLink)  
  local itemTrait = GetItemLinkTraitInfo(itemLink)
  return levelReq .. ":" .. vetReq .. ":" .. itemQuality .. ":" .. itemTrait
end

-- For faster searching of large histories, we'll maintain an inverted
-- index of search terms - here we build the indexes from the existing table
function Shopkeeper:indexHistoryTables()
  self.SSIndex = {}
  self.SRIndex = {}
  local playerName = string.lower(GetDisplayName())

  for itemID, datas in pairs(self.acctSavedVariables.SalesData) do
    local numberID = tonumber(itemID)
    for itemData, soldItems in pairs(datas) do
      for itemIndex, soldItem in ipairs(soldItems['sales']) do
        local searchBuyer = string.lower(soldItem['buyer'])
        local searchGuild = string.lower(soldItem['guild'])
        local guildByWords = string.gmatch(searchGuild, "%S+")
        local searchName = string.lower(GetItemLinkName(soldItem['itemLink']))
        local nameByWords = string.gmatch(searchName, "%S+")
        local isSelfSale = playerName == string.lower(soldItem['seller'])

        -- Index buyer
        if self.SRIndex[searchBuyer] == nil then self.SRIndex[searchBuyer] = {{numberID, itemData, itemIndex}}
        else table.insert(self.SRIndex[searchBuyer], {numberID, itemData, itemIndex}) end
        if isSelfSale then
          if self.SSIndex[searchBuyer] == nil then self.SSIndex[searchBuyer] = {{numberID, itemData, itemIndex}}
          else table.insert(self.SSIndex[searchBuyer], {numberID, itemData, itemIndex}) end
        end

        -- Index each word in guild name
        for i in guildByWords do
          if self.SRIndex[i] == nil then self.SRIndex[i] = {{numberID, itemData, itemIndex}}
          else table.insert(self.SRIndex[i], {numberID, itemData, itemIndex}) end
          if isSelfSale then
            if self.SSIndex[i] == nil then self.SSIndex[i] = {{numberID, itemData, itemIndex}}
            else table.insert(self.SSIndex[i], {numberID, itemData, itemIndex}) end
          end
        end

        -- Index each word in item name
        for i in nameByWords do
          if self.SRIndex[i] == nil then self.SRIndex[i] = {{numberID, itemData, itemIndex}}
          else table.insert(self.SRIndex[i], {numberID, itemData, itemIndex}) end
          if isSelfSale then
            if self.SSIndex[i] == nil then self.SSIndex[i] = {{numberID, itemData, itemIndex}}
            else table.insert(self.SSIndex[i], {numberID, itemData, itemIndex}) end
          end
        end
      end
    end
  end
end

-- And here we add a new item
function Shopkeeper:addToHistoryTables(theEvent)
  local theIID = string.match(theEvent.itemName, "|H.-:item:(.-):")
  if theIID == nil then return end --add this line
  theIID = tonumber(theIID)
  local itemIndex = self.makeIndexFromLink(theEvent.itemName)
  if not self.acctSavedVariables.SalesData[theIID] then self.acctSavedVariables.SalesData[theIID] = {} end

  local insertedIndex = 1
  local newSalesItem =
    {buyer = theEvent.buyer,
    guild = theEvent.guild,
    itemLink = self:UpdateItemLink(theEvent.itemName),
    quant = theEvent.quant,
    timestamp = theEvent.saleTime,
    price = theEvent.salePrice,
    seller = theEvent.seller,
    wasKiosk = theEvent.kioskSale}
  if self.acctSavedVariables.SalesData[theIID][itemIndex] then
    table.insert(self.acctSavedVariables.SalesData[theIID][itemIndex]['sales'], newSalesItem)
    insertedIndex = #self.acctSavedVariables.SalesData[theIID][itemIndex]['sales']
  else
    local iconForItem, _, _, _ = GetItemLinkInfo(theEvent.itemName)
    self.acctSavedVariables.SalesData[theIID][itemIndex] = {
      itemIcon = iconForItem,
      sales = {newSalesItem}}
  end

  local searchBuyer = string.lower(theEvent.buyer)
  local searchGuild = string.lower(theEvent.guild)
  local searchName = string.lower(GetItemLinkName(theEvent.itemName))
  local guildByWords = string.gmatch(searchGuild, "%S+")
  local nameByWords = string.gmatch(searchName, "%S+")
  local playerName = string.lower(GetDisplayName())
  local isSelfSale = false
  if playerName == string.lower(theEvent.seller) then isSelfSale = true end

  -- Index buyer
  if self.SRIndex[searchBuyer] == nil then self.SRIndex[searchBuyer] = {{theIID, itemIndex, insertedIndex}}
  else table.insert(self.SRIndex[searchBuyer], {theIID, itemIndex, insertedIndex}) end
  if isSelfSale then
    if self.SSIndex[searchBuyer] == nil then self.SSIndex[searchBuyer] = {{theIID, itemIndex, insertedIndex}}
    else table.insert(self.SSIndex[searchBuyer], {theIID, itemIndex, insertedIndex}) end
  end

  -- Index each word in the guild name
  for i in guildByWords do
    if self.SRIndex[i] == nil then self.SRIndex[i] = {{theIID, itemIndex, insertedIndex}}
    else table.insert(self.SRIndex[i], {theIID, itemIndex, insertedIndex}) end
    if isSelfSale then
      if self.SSIndex[i] == nil then self.SSIndex[i] = {{theIID, itemIndex, insertedIndex}}
      else table.insert(self.SSIndex[i], {theIID, itemIndex, insertedIndex}) end
    end
  end

  -- Index each word in the item name
  for i in nameByWords do
    if self.SRIndex[i] == nil then self.SRIndex[i] = {{theIID, itemIndex, insertedIndex}}
    else table.insert(self.SRIndex[i], {theIID, itemIndex, insertedIndex}) end
    if isSelfSale then
      if self.SSIndex[i] == nil then self.SSIndex[i] = {{theIID, itemIndex, insertedIndex}}
      else table.insert(self.SSIndex[i], {theIID, itemIndex, insertedIndex}) end
    end
  end
end

-- Inserts a comma or period as appropriate every 3 numbers and returns
-- the result as a string.
function Shopkeeper.LocalizedNumber(numberValue)
  if not numberValue then return "0" end
  
  local stringPrice = numberValue
  local subString = "%1" .. GetString(SK_THOUSANDS_SEP) .."%2"

  -- Insert thousands separators for the price
  while true do
    stringPrice, k = string.gsub(stringPrice, "^(-?%d+)(%d%d%d)", subString)
    if (k == 0) then break end
  end

  return stringPrice
end

-- Create a textual representation of a time interval
-- (X and Y) or Z in LUA is the equivalent of C-style
-- ternary syntax X ? Y : Z so long as Y is not false or nil
function Shopkeeper.TextTimeSince(theTime, useLowercase)
  local secsSince = GetTimeStamp() - theTime
  if secsSince < 75 then
    return ((useLowercase and zo_strformat(GetString(SK_TIME_SECONDS_LC), secsSince)) or
             zo_strformat(GetString(SK_TIME_SECONDS), secsSince))
  elseif secsSince < 4500 then
    return ((useLowercase and zo_strformat(GetString(SK_TIME_SECONDS_LC), math.floor(secsSince / 60.0))) or
             zo_strformat(GetString(SK_TIME_MINUTES), math.floor(secsSince / 60.0)))
  elseif secsSince < 86400 then
    return ((useLowercase and zo_strformat(GetString(SK_TIME_SECONDS_LC), math.floor(secsSince / 3600.0))) or
             zo_strformat(GetString(SK_TIME_HOURS), math.floor(secsSince / 3600.0)))
  else
    return ((useLowercase and zo_strformat(GetString(SK_TIME_SECONDS_LC), math.floor(secsSince / 86400.0))) or
             zo_strformat(GetString(SK_TIME_DAYS), math.floor(secsSince / 86400.0)))
  end
end

-- Grabs the first and last events in guildID's sales history and compares the secsSince
-- values returned.  Returns true if the first event (ID 1) is newer than the last event,
-- false otherwise.
function Shopkeeper.IsNewestFirst(guildID)
  local numEvents = GetNumGuildEvents(guildID, GUILD_HISTORY_STORE)
  local _, secsSinceFirst, _, _, _, _, _, _ = GetGuildEventInfo(guildID, GUILD_HISTORY_STORE, 1)
  local _, secsSinceLast, _, _, _, _, _, _ = GetGuildEventInfo(guildID, GUILD_HISTORY_STORE, numEvents)
  return (secsSinceFirst < secsSinceLast)
end

-- A simple utility function to return which set of settings are active,
-- based on the allSettingsAccount option setting.
function Shopkeeper:ActiveSettings()
  return ((self.acctSavedVariables.allSettingsAccount and self.acctSavedVariables) or
          self.savedVariables)
end

function Shopkeeper:ActiveWindow()
  return ((self:ActiveSettings().viewSize == "full" and ShopkeeperWindow) or ShopkeeperMiniWindow)
end

-- A utility function to grab all the keys of the sound table
-- to populate the options dropdown
function Shopkeeper:SoundKeys()
  local keyList = {}
  for i = 1, #self.alertSounds do table.insert(keyList, self.alertSounds[i].name) end
  return keyList
end

-- A utility function to find the key associated with a given value in
-- the sounds table.  Best we can do is a linear search unfortunately,
-- but it's a small table.
function Shopkeeper:SearchSounds(sound)
  for _, theSound in ipairs(self.alertSounds) do
    if theSound.sound == sound then return theSound.name end
  end

  -- If we hit this point, we didn't find what we were looking for
  return nil
end

-- Same as searchSounds, above, but compares names instead of sounds.
function Shopkeeper:SearchSoundNames(name)
  for _,theSound in ipairs(self.alertSounds) do
    if theSound.name == name then return theSound.sound end
  end
end

-- ZOS provides prehook functions, but not posthook.  So here they are.
function Shopkeeper.functionPostHook(control, funcName, callback)
  local tmp = control[funcName]
  if ((tmp ~= nil) and (type(tmp) == "function")) then
    local newFunc = function(...)
      if (not tmp(...)) then return callback(...) end
    end
    control[funcName] = newFunc
  end
end

function Shopkeeper.handlerPostHook(control, handName, callback)
    local tmp = control:GetHandler(handName)
    local newFunc
    if(tmp) then
        newFunc = function(...)
            if(not tmp(...)) then return callback(...) end
        end
    else newFunc = callback end
    control:SetHandler(handName, newFunc)
end

function Shopkeeper:UpdateItemLink(itemLink)
    local linkTable = { ZO_LinkHandler_ParseLink(itemLink) }
    if #linkTable == 23 and linkTable[3] == ITEM_LINK_TYPE then
        linkTable[24] = linkTable[23]
        linkTable[23] = linkTable[22]
        linkTable[22] = "0"
        itemLink = ("|H%d:%s|h%s|h"):format(linkTable[2], table.concat(linkTable, ':', 3), linkTable[1])
    end
    return itemLink
end