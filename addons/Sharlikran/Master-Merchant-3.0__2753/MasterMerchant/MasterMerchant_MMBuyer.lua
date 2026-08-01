-- MasterMerchant Utility Functions File
-- Last Updated September 15, 2014
-- Written February 2015 by Chris Lasswell (@Philgo68) - Philgo68@gmail.com
-- Released under terms in license accompanying this file.
-- Distribution without license is prohibited!
local internal = _G["LibGuildStore_Internal"]

MMBuyer = ZO_Object:Subclass()
MMBuyer.buyers = {}
MMBuyer.playerBuyers = {}
MMBuyer.buyersRankIsDirty = {}
MMBuyer.playerBuyersRankIsDirty = {}

function MMBuyer:New(guildName, buyerName, outsideBuyer, isPlayerBuyer)
  local o = ZO_Object.New(self)
  o:Initialize(guildName, buyerName, outsideBuyer, isPlayerBuyer)
  return o
end

function MMBuyer:Initialize(guildName, buyerName, outsideBuyer, isPlayerBuyer)
  self.guildName = guildName
  self.buyerName = buyerName
  self.purchases = {}
  self.tax = {}
  self.count = {}
  self.stack = {}
  self.rank = {}
  self.outsideBuyer = outsideBuyer
  self.isPlayerBuyer = isPlayerBuyer
end

function MMBuyer:GetBuyer(guildName, buyerName, outsideBuyer)
  if guildName == nil or buyerName == nil then return nil end
  if not MMGuild:IsGuildMemberByName(guildName, buyerName) then return nil end

  self.buyers[guildName] = self.buyers[guildName] or {}
  self.buyersRankIsDirty[guildName] = self.buyersRankIsDirty[guildName] or {}

  if self.buyers[guildName][buyerName] == nil then
    self.buyers[guildName][buyerName] = MMBuyer:New(guildName, buyerName, outsideBuyer, false)
  end

  return self.buyers[guildName][buyerName]
end

function MMBuyer:GetPlayerBuyer(guildName, buyerName, outsideBuyer, sellerName)
  if guildName == nil or buyerName == nil or sellerName == nil then return nil end
  if not MMGuild:IsGuildMemberByName(guildName, buyerName) then return nil end
  if zo_strlower(sellerName) ~= zo_strlower(GetDisplayName()) then return nil end

  self.playerBuyers[guildName] = self.playerBuyers[guildName] or {}
  self.playerBuyersRankIsDirty[guildName] = self.playerBuyersRankIsDirty[guildName] or {}

  if self.playerBuyers[guildName][buyerName] == nil then
    self.playerBuyers[guildName][buyerName] = MMBuyer:New(guildName, buyerName, outsideBuyer, true)
  end

  return self.playerBuyers[guildName][buyerName]
end

function MMBuyer:addPurchase(dateRange, amount, stack, sort)
  if sort == nil then sort = not internal.isDatabaseBusy end
  if amount == nil or amount < 1 then amount = 1 end
  if stack == nil or stack < 1 then stack = 1 end

  if not self.rank[dateRange] then
    self.rank[dateRange] = 0
    self.purchases[dateRange] = 0
    self.tax[dateRange] = 0
    self.count[dateRange] = 0
    self.stack[dateRange] = 0
  end

  self.purchases[dateRange] = self.purchases[dateRange] + amount
  self.tax[dateRange] = self.tax[dateRange] + zo_floor(amount * 0.035)
  self.count[dateRange] = self.count[dateRange] + 1
  self.stack[dateRange] = self.stack[dateRange] + stack

  if self.isPlayerBuyer then
    MMBuyer:MarkPlayerBuyerDirty(self.guildName, dateRange)
  else
    MMBuyer:MarkBuyerDirty(self.guildName, dateRange)
  end

  if sort then
    if self.isPlayerBuyer then
      MMBuyer:SortPlayerBuyerByDateRange(self.guildName, dateRange)
    else
      MMBuyer:SortBuyerByDateRange(self.guildName, dateRange)
    end
  end
end

function MMBuyer:addPurchaseByDate(timestamp, amount, stack, sort)
  if amount == nil or stack == nil or timestamp == nil or type(timestamp) ~= 'number' then return end

  for dateRange = LGS_DATERANGE_TODAY, LGS_DATERANGE_CUSTOM do
    if LGSTime:IsInDateRange(dateRange, timestamp) then
      self:addPurchase(dateRange, amount, stack, sort)
    end
  end
end

function MMBuyer:MarkBuyerDirty(guildName, dateRange)
  if guildName == nil or dateRange == nil then return end
  self.buyersRankIsDirty[guildName] = self.buyersRankIsDirty[guildName] or {}
  self.buyersRankIsDirty[guildName][dateRange] = true
end

function MMBuyer:MarkBuyerClean(guildName, dateRange)
  if guildName == nil or dateRange == nil then return end
  self.buyersRankIsDirty[guildName] = self.buyersRankIsDirty[guildName] or {}
  self.buyersRankIsDirty[guildName][dateRange] = false
end

function MMBuyer:IsBuyerDirty(guildName, dateRange)
  return self.buyersRankIsDirty[guildName] and self.buyersRankIsDirty[guildName][dateRange]
end

function MMBuyer:MarkPlayerBuyerDirty(guildName, dateRange)
  if guildName == nil or dateRange == nil then return end
  self.playerBuyersRankIsDirty[guildName] = self.playerBuyersRankIsDirty[guildName] or {}
  self.playerBuyersRankIsDirty[guildName][dateRange] = true
end

function MMBuyer:MarkPlayerBuyerClean(guildName, dateRange)
  if guildName == nil or dateRange == nil then return end
  self.playerBuyersRankIsDirty[guildName] = self.playerBuyersRankIsDirty[guildName] or {}
  self.playerBuyersRankIsDirty[guildName][dateRange] = false
end

function MMBuyer:IsPlayerBuyerDirty(guildName, dateRange)
  return self.playerBuyersRankIsDirty[guildName] and self.playerBuyersRankIsDirty[guildName][dateRange]
end

function MMBuyer:SortBuyerByDateRange(guildName, dateRange)
  if guildName == nil or dateRange == nil then return end
  if self.buyers[guildName] == nil then return end
  if not self:IsBuyerDirty(guildName, dateRange) then return end

  local rankList = {}

  for buyerName, buyerData in pairs(self.buyers[guildName]) do
    if buyerData.purchases[dateRange] ~= nil then
      table.insert(rankList, buyerData)
    end
  end

  MasterMerchant.shellSort(rankList, function(sortA, sortB)
    return (sortA.purchases[dateRange] or 0) > (sortB.purchases[dateRange] or 0)
  end)

  for i = 1, #rankList do
    rankList[i].rank[dateRange] = i
  end

  self:MarkBuyerClean(guildName, dateRange)
  return rankList
end

function MMBuyer:SortPlayerBuyerByDateRange(guildName, dateRange)
  if guildName == nil or dateRange == nil then return end
  if self.playerBuyers[guildName] == nil then return end
  if not self:IsPlayerBuyerDirty(guildName, dateRange) then return end

  local rankList = {}

  for buyerName, buyerData in pairs(self.playerBuyers[guildName]) do
    if buyerData.purchases[dateRange] ~= nil then
      table.insert(rankList, buyerData)
    end
  end

  MasterMerchant.shellSort(rankList, function(sortA, sortB)
    return (sortA.purchases[dateRange] or 0) > (sortB.purchases[dateRange] or 0)
  end)

  for i = 1, #rankList do
    rankList[i].rank[dateRange] = i
  end

  self:MarkPlayerBuyerClean(guildName, dateRange)
  return rankList
end

function MMBuyer:SortAllRanks()
  for guildName, guildBuyers in pairs(self.buyers) do
    for dateRange = LGS_DATERANGE_TODAY, LGS_DATERANGE_CUSTOM do
      self:SortBuyerByDateRange(guildName, dateRange)
    end
  end

  for guildName, guildBuyers in pairs(self.playerBuyers) do
    for dateRange = LGS_DATERANGE_TODAY, LGS_DATERANGE_CUSTOM do
      self:SortPlayerBuyerByDateRange(guildName, dateRange)
    end
  end
end
