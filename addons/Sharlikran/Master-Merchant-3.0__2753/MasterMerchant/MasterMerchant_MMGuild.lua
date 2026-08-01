-- MasterMerchant Utility Functions File
-- Last Updated September 15, 2014
-- Written February 2015 by Chris Lasswell (@Philgo68) - Philgo68@gmail.com
-- Released under terms in license accompanying this file.
-- Distribution without license is prohibited!

MMGuild = ZO_Object:Subclass()
MMGuild.guilds = {}
MMGuild.currentGuilds = {}
MMGuild.guildMemberInfo = {}
MMGuild.guildIdLookup = {}
MMGuild.guildList = ''
MMGuild.salesRankIsDirty = {}
MMGuild.purchaseRankIsDirty = {}

function MMGuild:New(guildName)
  local o = ZO_Object.New(self)
  o:Initialize(guildName)
  return o
end

function MMGuild:Initialize(guildName)
  self.guildName = guildName
  self.sales = {}
  self.purchases = {}
  self.salesTax = {}
  self.salesCount = {}
  self.salesStack = {}
  self.purchaseCount = {}
  self.purchaseStack = {}
  self.salesRank = {}
  self.purchaseRank = {}
end

function MMGuild:GetGuild(guildName)
  if guildName == nil then return nil end

  if self.guilds[guildName] == nil then
    self.guilds[guildName] = MMGuild:New(guildName)
  end

  return self.guilds[guildName]
end

function MMGuild:InitializeGuildMembers()
  self.guildList = ''
  self.currentGuilds = {}
  self.guildMemberInfo = {}
  self.guildIdLookup = {}

  for i = 1, GetNumGuilds() do
    local guildId = GetGuildId(i)
    local guildName = GetGuildName(guildId)

    self.guildList = self.guildList .. guildName .. ', '
    self.currentGuilds[guildId] = guildName
    self.guildIdLookup[guildName] = guildId
    self.guildMemberInfo[guildId] = {}

    for m = 1, GetNumGuildMembers(guildId) do
      local accountName = GetGuildMemberInfo(guildId, m)
      if accountName ~= nil then
        self.guildMemberInfo[guildId][zo_strlower(accountName)] = true
      end
    end
  end
end

function MMGuild:IsCurrentGuild(guildName)
  if guildName == nil then return false end
  return self.guildIdLookup[guildName] ~= nil
end

function MMGuild:IsGuildMemberByName(guildName, accountName)
  if guildName == nil or accountName == nil then return false end
  local guildId = self.guildIdLookup[guildName]
  if guildId == nil then return false end
  return self:IsGuildMember(guildId, accountName)
end

function MMGuild:IsGuildMember(guildId, accountName)
  if guildId == nil or accountName == nil then return false end
  return self.guildMemberInfo[guildId] and self.guildMemberInfo[guildId][zo_strlower(accountName)] == true
end

function MMGuild:MarkSalesDirty(dateRange)
  if dateRange == nil then return end
  self.salesRankIsDirty[dateRange] = true
end

function MMGuild:MarkSalesClean(dateRange)
  if dateRange == nil then return end
  self.salesRankIsDirty[dateRange] = false
end

function MMGuild:IsSalesDirty(dateRange)
  if self.salesRankIsDirty[dateRange] == nil then return true end
  return self.salesRankIsDirty[dateRange]
end

function MMGuild:MarkPurchasesDirty(dateRange)
  if dateRange == nil then return end
  self.purchaseRankIsDirty[dateRange] = true
end

function MMGuild:MarkPurchasesClean(dateRange)
  if dateRange == nil then return end
  self.purchaseRankIsDirty[dateRange] = false
end

function MMGuild:IsPurchasesDirty(dateRange)
  if self.purchaseRankIsDirty[dateRange] == nil then return true end
  return self.purchaseRankIsDirty[dateRange]
end

function MMGuild:addSale(dateRange, amount, stack, sort)
  if sort == nil then sort = not internal.isDatabaseBusy end
  if amount == nil or amount < 1 then amount = 1 end
  if stack == nil or stack < 1 then stack = 1 end

  if not self.sales[dateRange] then
    self.sales[dateRange] = 0
    self.salesTax[dateRange] = 0
    self.salesCount[dateRange] = 0
    self.salesStack[dateRange] = 0
    self.salesRank[dateRange] = 0
  end

  self.sales[dateRange] = self.sales[dateRange] + amount
  self.salesTax[dateRange] = self.salesTax[dateRange] + zo_floor(amount * 0.035)
  self.salesCount[dateRange] = self.salesCount[dateRange] + 1
  self.salesStack[dateRange] = self.salesStack[dateRange] + stack

  MMGuild:MarkSalesDirty(dateRange)

  if sort then
    MMGuild:SortSalesByDateRange(self.guildName, dateRange)
  end
end

function MMGuild:addPurchase(dateRange, amount, stack, sort)
  if sort == nil then sort = not internal.isDatabaseBusy end
  if amount == nil or amount < 1 then amount = 1 end
  if stack == nil or stack < 1 then stack = 1 end

  if not self.purchases[dateRange] then
    self.purchases[dateRange] = 0
    self.purchaseCount[dateRange] = 0
    self.purchaseStack[dateRange] = 0
    self.purchaseRank[dateRange] = 0
  end

  self.purchases[dateRange] = self.purchases[dateRange] + amount
  self.purchaseCount[dateRange] = self.purchaseCount[dateRange] + 1
  self.purchaseStack[dateRange] = self.purchaseStack[dateRange] + stack

  MMGuild:MarkPurchasesDirty(dateRange)

  if sort then
    MMGuild:SortPurchasesByDateRange(self.guildName, dateRange)
  end
end

function MMGuild:addSaleByDate(timestamp, amount, stack, sort)
  if type(timestamp) ~= 'number' then return end
  if not MasterMerchant:ShouldUseSale(timestamp) then return end

  LGSTime:SetOldestTime(timestamp)
  LGSTime:SetNewestTime(timestamp)

  for dateRange = LGS_DATERANGE_TODAY, LGS_DATERANGE_CUSTOM do
    if LGSTime:IsInDateRange(dateRange, timestamp) then
      self:addSale(dateRange, amount, stack, sort)
    end
  end
end

function MMGuild:addPurchaseByDate(timestamp, amount, stack, sort)
  if type(timestamp) ~= 'number' then return end
  if not MasterMerchant:ShouldUseSale(timestamp) then return end

  for dateRange = LGS_DATERANGE_TODAY, LGS_DATERANGE_CUSTOM do
    if LGSTime:IsInDateRange(dateRange, timestamp) then
      self:addPurchase(dateRange, amount, stack, sort)
    end
  end
end

function MMGuild:SortSalesByDateRange(dateRange)
  if dateRange == nil then return end
  if not self:IsSalesDirty(dateRange) then return end

  local rankList = {}

  for _, guildData in pairs(self.guilds) do
    if guildData.sales[dateRange] ~= nil then
      table.insert(rankList, guildData)
    end
  end

  MasterMerchant.shellSort(rankList, function(sortA, sortB)
    return (sortA.sales[dateRange] or 0) > (sortB.sales[dateRange] or 0)
  end)

  for i = 1, #rankList do
    rankList[i].salesRank[dateRange] = i
  end

  self:MarkSalesClean(dateRange)
end

function MMGuild:SortPurchasesByDateRange(dateRange)
  if dateRange == nil then return end
  if not self:IsPurchasesDirty(dateRange) then return end

  local rankList = {}

  for _, guildData in pairs(self.guilds) do
    if guildData.purchases[dateRange] ~= nil then
      table.insert(rankList, guildData)
    end
  end

  MasterMerchant.shellSort(rankList, function(sortA, sortB)
    return (sortA.purchases[dateRange] or 0) > (sortB.purchases[dateRange] or 0)
  end)

  for i = 1, #rankList do
    rankList[i].purchaseRank[dateRange] = i
  end

  self:MarkPurchasesClean(dateRange)
end

function MMGuild:SortByRankIndex(dateRange)
  self:SortSalesByDateRange(dateRange)
  self:SortPurchasesByDateRange(dateRange)
end

function MMGuild:SortAllRanks()
  for dateRange = LGS_DATERANGE_TODAY, LGS_DATERANGE_CUSTOM do
    self:SortByRankIndex(dateRange)
  end
end

function MMGuild:GetGuildSalesTotal(guildName, dateRange)
  if guildName == nil or dateRange == nil then
    return 0
  end

  local guild = self:GetGuild(guildName)
  if guild == nil then
    return 0
  end

  return guild.sales[dateRange] or 0
end
