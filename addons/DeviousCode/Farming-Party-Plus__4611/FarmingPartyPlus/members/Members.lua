local Addon = FarmingPartyPlus
local Members = ZO_CallbackObject:Subclass()

Addon.Classes.Members = Members

local function NormalizeDisplayName(displayName)
  if displayName == nil or displayName == '' then
    return nil
  end
  return UndecorateDisplayName(displayName)
end

function Members:New(saveData)
  local storage = ZO_CallbackObject.New(self)
  storage.members = saveData.members or {}
  storage.displayNameIndex = {}
  for memberKey, memberData in pairs(storage.members) do
    local normalizedDisplayName = NormalizeDisplayName(memberData.displayName)
    if normalizedDisplayName ~= nil then
      storage.displayNameIndex[normalizedDisplayName] = memberKey
    end
  end
  saveData.members = storage.members
  return storage
end

function Members:Finalize()
end

function Members:GetMembers()
  return self.members
end

function Members:GetCleanMembers()
  local cleanMembers = {}
  for key, member in pairs(self.members) do
    cleanMembers[key] = {
      bestItem = member.bestItem,
      totalValue = member.totalValue,
      items = member.items,
      displayName = member.displayName,
      helperActive = member.helperActive,
      isOnline = member.isOnline ~= false
    }
  end
  return cleanMembers
end

function Members:GetKeys()
  local keys = {}
  for key in pairs(self.members) do
    keys[#keys + 1] = key
  end
  table.sort(keys)
  return keys
end

function Members:GetMember(key)
  return self.members[key]
end

function Members:HasMember(key)
  return self.members[key] ~= nil
end

function Members:HasMembers()
  return next(self.members) ~= nil
end

function Members:GetMemberKeyByDisplayName(displayName)
  local normalizedDisplayName = NormalizeDisplayName(displayName)
  if normalizedDisplayName == nil then
    return nil
  end
  return self.displayNameIndex[normalizedDisplayName]
end

function Members:HasDisplayName(displayName)
  return self:GetMemberKeyByDisplayName(displayName) ~= nil
end

function Members:SetMember(key, member)
  local keyExists = self:HasMember(key)
  if keyExists then
    local existingMember = self.members[key]
    local existingDisplayName = existingMember ~= nil and NormalizeDisplayName(existingMember.displayName) or nil
    if existingDisplayName ~= nil and existingDisplayName ~= NormalizeDisplayName(member.displayName) then
      self.displayNameIndex[existingDisplayName] = nil
    end
  end

  self.members[key] = member
  local normalizedDisplayName = NormalizeDisplayName(member.displayName)
  if normalizedDisplayName ~= nil then
    self.displayNameIndex[normalizedDisplayName] = key
  end
  if not keyExists then
    self:FireCallbacks('OnKeysUpdated')
  end
end

function Members:UpdateDisplayName(key, displayName)
  local member = self:GetMember(key)
  if member == nil then
    return
  end

  local existingDisplayName = NormalizeDisplayName(member.displayName)
  local updatedDisplayName = NormalizeDisplayName(displayName)
  if existingDisplayName == updatedDisplayName then
    return
  end

  if existingDisplayName ~= nil and self.displayNameIndex[existingDisplayName] == key then
    self.displayNameIndex[existingDisplayName] = nil
  end

  member.displayName = displayName
  if updatedDisplayName ~= nil then
    self.displayNameIndex[updatedDisplayName] = key
  end
  self:FireCallbacks('OnKeysUpdated')
end

function Members:DeleteMember(key)
  local keyExists = self:HasMember(key)
  if keyExists then
    local member = self.members[key]
    local normalizedDisplayName = member ~= nil and NormalizeDisplayName(member.displayName) or nil
    if normalizedDisplayName ~= nil and self.displayNameIndex[normalizedDisplayName] == key then
      self.displayNameIndex[normalizedDisplayName] = nil
    end
  end
  self.members[key] = nil
  if keyExists then
    self:FireCallbacks('OnKeysUpdated')
  end
end

function Members:DeleteAllMembers()
  local hasMembers = self:HasMembers()
  ZO_ClearTable(self.members)
  ZO_ClearTable(self.displayNameIndex)
  if hasMembers then
    self:FireCallbacks('OnKeysUpdated')
  end
end

function Members:GetItemForMember(memberKey, itemLink)
  local member = self:GetMember(memberKey)
  return member.items[itemLink]
end

function Members:SetItemForMember(memberKey, itemLink, item)
  local member = self:GetMember(memberKey)
  member.items[itemLink] = item
end

function Members:DeleteItemForMember(memberKey, itemLink)
  local member = self:GetMember(memberKey)
  member.items[itemLink] = nil
end

function Members:GetItemsForMember(key)
  local member = self:GetMember(key)
  return member.items
end

function Members:NewMember(name, displayName)
  local newMember = {
    bestItem = { itemLink = '', value = 0 },
    totalValue = 0,
    items = {},
    displayName = displayName,
    helperActive = false,
    isOnline = true
  }
  self:FireCallbacks('OnKeysUpdated')
  return newMember
end

function Members:SetOnlineState(name, isOnline)
  local member = self:GetMember(name)
  if member == nil then
    return
  end

  local normalizedOnlineState = isOnline == true
  if member.isOnline == normalizedOnlineState then
    return
  end

  member.isOnline = normalizedOnlineState
  self:FireCallbacks('OnKeysUpdated')
end

function Members:SetHelperActive(name, isActive)
  local member = self:GetMember(name)
  if member == nil or member.helperActive == isActive then
    return
  end
  member.helperActive = isActive
  self:FireCallbacks('OnKeysUpdated')
end

function Members:UpdateTotalValueAndSetBestItem(name, item, valueToAdd)
  local member = self:GetMember(name)
  local bestItem = member.bestItem
  if item.value > bestItem.value then
    bestItem = item
    bestItem.itemLink = item.itemLink
  end
  member.bestItem = bestItem
  member.totalValue = member.totalValue + valueToAdd
  self:FireCallbacks('OnKeysUpdated')
end

function Members:RebuildMemberTotals(name)
  local member = self:GetMember(name)
  local bestItem = { itemLink = '', value = 0 }
  local totalValue = 0
  local itemsToDelete = {}

  for itemLink, item in pairs(member.items) do
    if item.count == nil or item.count <= 0 then
      itemsToDelete[#itemsToDelete + 1] = itemLink
    else
      totalValue = totalValue + (item.totalValue or 0)
      if (item.value or 0) > (bestItem.value or 0) then
        bestItem = {
          itemLink = item.itemLink,
          count = item.count,
          value = item.value,
          totalValue = item.totalValue
        }
      end
    end
  end

  for _, itemLink in ipairs(itemsToDelete) do
    member.items[itemLink] = nil
  end

  member.bestItem = bestItem
  member.totalValue = totalValue
  self:FireCallbacks('OnKeysUpdated')
end
