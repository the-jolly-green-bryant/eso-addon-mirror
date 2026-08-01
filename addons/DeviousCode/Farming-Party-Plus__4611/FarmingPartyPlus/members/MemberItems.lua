local listContainer
local memberKey = zo_strformat(SI_UNIT_NAME, GetUnitName('player'))
local members = {}
local Settings
local Addon = FarmingPartyPlus

local MemberItems = ZO_Object:Subclass()
Addon.Classes.MemberItems = MemberItems

function MemberItems:New()
  local obj = ZO_Object.New(self)
  obj:Initialize()
  return obj
end

function MemberItems:Initialize()
  members = FarmingPartyPlus.Modules.Members
  Settings = FarmingPartyPlus.Settings
  listContainer = FarmingPartyPlusMemberItemsWindow:GetNamedChild('List')

  FarmingPartyPlusMemberItemsWindow:ClearAnchors()
  FarmingPartyPlusMemberItemsWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, Settings:ItemsWindow().positionLeft, Settings:ItemsWindow().positionTop)
  FarmingPartyPlusMemberItemsWindow:SetDimensions(Settings:ItemsWindow().width, Settings:ItemsWindow().height)
  FarmingPartyPlusMemberItemsWindow:SetHandler('OnResizeStop', function(...)
    self:WindowResizeHandler(...)
  end)
  FarmingPartyPlusMemberItemsWindow.onResize = self.onResize

  self:SetWindowTransparency()
  self:SetWindowBackgroundTransparency()
  self:SetTitle()
  self:SetupScrollList()
  self:UpdateScrollList()

  members:RegisterCallback('OnKeysUpdated', self.UpdateScrollList)
end

function MemberItems:Finalize()
  Settings:ItemsWindow().positionLeft = FarmingPartyPlusMemberItemsWindow:GetLeft()
  Settings:ItemsWindow().positionTop = FarmingPartyPlusMemberItemsWindow:GetTop()
  Settings:ItemsWindow().width = FarmingPartyPlusMemberItemsWindow:GetWidth()
  Settings:ItemsWindow().height = FarmingPartyPlusMemberItemsWindow:GetHeight()
end

function MemberItems:SetupScrollList()
  ZO_ScrollList_AddResizeOnScreenResize(listContainer)
  ZO_ScrollList_AddDataType(listContainer, FarmingPartyPlus.DataTypes.MEMBER_ITEM, 'FarmingPartyPlusItemDataRow', 20, function(listControl, data)
    self:SetupItemRow(listControl, data)
  end)
end

function MemberItems:UpdateScrollList()
  ZO_ScrollList_Clear(listContainer)
  local member = members:GetMember(memberKey)
  if member == nil then
    return
  end

  local memberItemArray = {}
  for key, value in pairs(members:GetItemsForMember(memberKey)) do
    memberItemArray[#memberItemArray + 1] = {
      itemLink = key,
      count = value.count,
      value = value.value,
      totalValue = value.totalValue
    }
  end

  table.sort(memberItemArray, function(left, right)
    if left.totalValue == right.totalValue then
      return left.itemLink < right.itemLink
    end
    return left.totalValue > right.totalValue
  end)

  local scrollData = ZO_ScrollList_GetDataList(listContainer)
  for _, item in ipairs(memberItemArray) do
    scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(FarmingPartyPlus.DataTypes.MEMBER_ITEM, { rawData = item })
  end
  ZO_ScrollList_Commit(listContainer)
end

function MemberItems:SetupItemRow(rowControl, rowData)
  local data = rowData.rawData
  GetControl(rowControl, 'ItemName'):SetText(data.itemLink)
  GetControl(rowControl, 'Count'):SetText(data.count)
  GetControl(rowControl, 'TotalValue'):SetText(FarmingPartyPlus.FormatNumber(data.totalValue) .. 'g')
end

function MemberItems.onResize()
  ZO_ScrollList_Commit(listContainer)
end

function MemberItems:WindowResizeHandler(control)
  Settings:ItemsWindow().width = control:GetWidth()
  Settings:ItemsWindow().height = control:GetHeight()
  ZO_ScrollList_Commit(listContainer)
end

function MemberItems:SetAndToggle(key)
  if memberKey == key then
    self:ToggleWindow()
  else
    memberKey = key
    self:SetTitle()
    self:OpenWindow()
    self:UpdateScrollList()
  end
end

function MemberItems:SetTitle()
  local title = FarmingPartyPlusMemberItemsWindow:GetNamedChild('Title')
  local member = members:GetMember(memberKey)
  if member ~= nil then
    title:SetText(member.displayName .. "'s Farmed Items")
  end
end

function MemberItems:ToggleWindow()
  FarmingPartyPlusMemberItemsWindow:SetHidden(not FarmingPartyPlusMemberItemsWindow:IsHidden())
end

function MemberItems:OpenWindow()
  FarmingPartyPlusMemberItemsWindow:SetHidden(false)
end

function MemberItems:SetWindowTransparency(value)
  if value ~= nil then
    Settings:ItemsWindow().transparency = value
  end
  FarmingPartyPlusMemberItemsWindow:SetAlpha(Settings:ItemsWindow().transparency / 100)
end

function MemberItems:SetWindowBackgroundTransparency(value)
  if value ~= nil then
    Settings:ItemsWindow().backgroundTransparency = value
  end
  FarmingPartyPlusMemberItemsWindow:GetNamedChild('BG'):SetAlpha(Settings:ItemsWindow().backgroundTransparency / 100)
end
