MMItems = ZO_Object:Subclass()
MMItems.items = {}
MMItems.rankIsDirty = {}

function MMItems:New(guildName, itemLink, searchText)
  local o = ZO_Object.New(self)
  o:Initialize(guildName, itemLink, searchText)
  return o
end

function MMItems:Initialize(guildName, itemLink, searchText)
  self.guildName = guildName
  self.itemLink = itemLink
  self.sales = {}
  self.count = {}
  self.stack = {}
  self.rank = {}
  self.searchText = zo_strlower(searchText or '')
end

function MMItems:GetItem(guildName, itemLink, searchText)
  if guildName == nil or itemLink == nil then return nil end

  self.items[guildName] = self.items[guildName] or {}
  self.rankIsDirty[guildName] = self.rankIsDirty[guildName] or {}

  if self.items[guildName][itemLink] == nil then
    self.items[guildName][itemLink] = MMItems:New(guildName, itemLink, searchText)
  end

  return self.items[guildName][itemLink]
end

function MMItems:addItemSale(dateRange, amount, stack, sort)
  if sort == nil then sort = not internal.isDatabaseBusy end
  if amount == nil or amount < 1 then amount = 1 end
  if stack == nil or stack < 1 then stack = 1 end

  if not self.rank[dateRange] then
    self.rank[dateRange] = 0
    self.sales[dateRange] = 0
    self.count[dateRange] = 0
    self.stack[dateRange] = 0
  end

  self.sales[dateRange] = self.sales[dateRange] + amount
  self.count[dateRange] = self.count[dateRange] + 1
  self.stack[dateRange] = self.stack[dateRange] + stack

  MMItems:MarkDirty(self.guildName, dateRange)

  if sort then
    MMItems:SortByDateRange(self.guildName, dateRange)
  end
end

function MMItems:addItemSaleByDate(timestamp, amount, stack, sort)
  if amount == nil or stack == nil or timestamp == nil or type(timestamp) ~= 'number' then return end
  for dateRange = LGS_DATERANGE_TODAY, LGS_DATERANGE_CUSTOM do
    if LGSTime:IsInDateRange(dateRange, timestamp) then
      MMItems:MarkDirty(self.guildName, dateRange)
      self:addItemSale(dateRange, amount, stack, sort)
    end
  end
end

function MMItems:MarkDirty(guildName, dateRange)
  self.rankIsDirty[guildName][dateRange] = true
end

function MMItems:MarkClean(guildName, dateRange)
  self.rankIsDirty[guildName][dateRange] = false
end

function MMItems:IsDirty(guildName, dateRange)
  return self.rankIsDirty[guildName][dateRange]
end

function MMItems:SortByDateRange(guildName, dateRange)
  if guildName == nil then return end
  if self.items[guildName] == nil then return end

  local rankList = {}

  for itemLink, itemData in pairs(self.items[guildName]) do
    if itemData.sales[dateRange] ~= nil then
      table.insert(rankList, itemData)
    end
  end

  MasterMerchant.shellSort(rankList, function(sortA, sortB)
    return (sortA.sales[dateRange] or 0) > (sortB.sales[dateRange] or 0)
  end)

  for i = 1, #rankList do
    rankList[i].rank[dateRange] = i
  end

  self:MarkClean(guildName, dateRange)
  return rankList
end

function MMItems:SortAllRanks()
  for guildName, guildItems in pairs(self.items) do
    for dateRange = LGS_DATERANGE_TODAY, LGS_DATERANGE_CUSTOM do
      self:SortByDateRange(guildName, dateRange)
    end
  end
end
