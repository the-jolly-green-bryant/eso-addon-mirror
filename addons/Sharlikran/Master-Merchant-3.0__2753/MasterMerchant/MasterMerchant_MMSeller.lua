-- MasterMerchant Utility Functions File
-- Last Updated September 15, 2014
-- Written February 2015 by Chris Lasswell (@Philgo68) - Philgo68@gmail.com
-- Released under terms in license accompanying this file.
-- Distribution without license is prohibited!
local internal = _G["LibGuildStore_Internal"]

MMSeller = ZO_Object:Subclass()
MMSeller.sellers = {}
MMSeller.rankIsDirty = {}

function MMSeller:New(guildName, sellerName)
  local o = ZO_Object.New(self)
  o:Initialize(guildName, sellerName)
  return o
end

function MMSeller:Initialize(guildName, sellerName)
  self.guildName = guildName
  self.sellerName = sellerName
  self.sales = {}
  self.tax = {}
  self.count = {}
  self.stack = {}
  self.rank = {}
end

function MMSeller:GetSeller(guildName, sellerName)
  if guildName == nil or sellerName == nil then return nil end
  if not MMGuild:IsGuildMemberByName(guildName, sellerName) then return nil end

  self.sellers[guildName] = self.sellers[guildName] or {}
  self.rankIsDirty[guildName] = self.rankIsDirty[guildName] or {}

  if self.sellers[guildName][sellerName] == nil then
    self.sellers[guildName][sellerName] = MMSeller:New(guildName, sellerName)
  end

  return self.sellers[guildName][sellerName]
end

function MMSeller:addSale(dateRange, amount, stack, sort)
  if sort == nil then sort = not internal.isDatabaseBusy end
  if amount == nil or amount < 1 then amount = 1 end
  if stack == nil or stack < 1 then stack = 1 end

  if not self.rank[dateRange] then
    self.rank[dateRange] = 0
    self.sales[dateRange] = 0
    self.tax[dateRange] = 0
    self.count[dateRange] = 0
    self.stack[dateRange] = 0
  end

  self.sales[dateRange] = self.sales[dateRange] + amount
  self.tax[dateRange] = self.tax[dateRange] + zo_floor(amount * 0.035)
  self.count[dateRange] = self.count[dateRange] + 1
  self.stack[dateRange] = self.stack[dateRange] + stack

  MMSeller:MarkDirty(self.guildName, dateRange)

  if sort then
    MMSeller:SortByDateRange(self.guildName, dateRange)
  end
end

function MMSeller:addSaleByDate(timestamp, amount, stack, sort)
  if amount == nil or stack == nil or timestamp == nil or type(timestamp) ~= 'number' then return end

  for dateRange = LGS_DATERANGE_TODAY, LGS_DATERANGE_CUSTOM do
    if LGSTime:IsInDateRange(dateRange, timestamp) then
      self:addSale(dateRange, amount, stack, sort)
    end
  end
end

function MMSeller:MarkDirty(guildName, dateRange)
  if guildName == nil or dateRange == nil then return end
  self.rankIsDirty[guildName] = self.rankIsDirty[guildName] or {}
  self.rankIsDirty[guildName][dateRange] = true
end

function MMSeller:MarkClean(guildName, dateRange)
  if guildName == nil or dateRange == nil then return end
  self.rankIsDirty[guildName] = self.rankIsDirty[guildName] or {}
  self.rankIsDirty[guildName][dateRange] = false
end

function MMSeller:IsDirty(guildName, dateRange)
  return self.rankIsDirty[guildName] and self.rankIsDirty[guildName][dateRange]
end

function MMSeller:SortByDateRange(guildName, dateRange)
  if guildName == nil or dateRange == nil then return end
  if self.sellers[guildName] == nil then return end
  if not self:IsDirty(guildName, dateRange) then return end

  local rankList = {}

  for sellerName, sellerData in pairs(self.sellers[guildName]) do
    if sellerData.sales[dateRange] ~= nil then
      table.insert(rankList, sellerData)
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

function MMSeller:SortAllRanks()
  for guildName, guildSellers in pairs(self.sellers) do
    for dateRange = LGS_DATERANGE_TODAY, LGS_DATERANGE_CUSTOM do
      self:SortByDateRange(guildName, dateRange)
    end
  end
end
