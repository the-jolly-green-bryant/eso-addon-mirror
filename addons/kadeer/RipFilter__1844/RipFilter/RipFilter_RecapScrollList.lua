local RF = RipFilter or {}


--    The ZO_ScrollList control **MUST** be named "$(parent)List",
--    and the container for the list headers MUST be named "$(parent)Headers"
--
--    Uses allRecaps

local RecapScrollList = ZO_SortFilterList:Subclass()
RF.RecapScrollList = RecapScrollList
local selectedRecap = {}
local allPlayersListableItems = {}
local compactMode = false

function RecapScrollList:GetCompactMode()
  return compactMode
end

function RecapScrollList:SetCompactMode(val)
  compactMode = val
end

function RecapScrollList:New(control, allPlayers)

  allPlayersListableItems = allPlayers

  -- sort
  ZO_SortFilterList.InitializeSortFilterList(self, control)
  self:SetAutomaticallyColorRows(false)

  -- doesnt really do anything...timestamp is a string
  local SorterKeys =
  {
    timestamp = {isNumeric = true},
  }

  self.masterList = {}

  -- (self, typeId, templateName, height, setupCallback, hideCallback, dataTypeSelectSound, resetControlCallback)
  ZO_ScrollList_AddDataType(self.list, 1, "RecapRowCompact", 32, function(control, data) self:SetupEntry(control, data) end)
  ZO_ScrollList_AddDataType(self.list, 2, "RecapRowFull", 64, function(control, data) self:SetupEntry(control, data) end)
  ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")

  self.currentSortKey = "timestamp"
  self.currentSortOrder = ZO_SORT_ORDER_DOWN
  self.sortFunction = function(listEntry1, listEntry2) return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, SorterKeys, self.currentSortOrder) end

  return self
end

function RecapScrollList:SetupEntry(control, data)
  control.data = data

  control.timestamp = GetControl(control, "Timestamp")
  control.timestamp:SetText(data.timestamp)

  -- using abilityId to get icon
  control.icon = GetControl(control, "Icon")
  control.icon:SetTexture(GetAbilityIcon(data.abilityId))

  control.sourceName = GetControl(control, "SourceName")
  control.sourceName:SetText(data.sourceName)

  control.abilityName = GetControl(control, "AbilityName")
  control.abilityName:SetText(data.abilityName)

  control.multiplier = GetControl(control, "Multiplier")

  -- display multiple same attacks
  if data.multipleHits > 1 then
    control.multiplier:SetText("x" .. zo_strformat(SI_NUMBER_FORMAT, data.multipleHits))
  else
    control.multiplier:SetText("")
  end

  control.hitValue = GetControl(control, "HitValue")
  control.hitValue:SetText(zo_strformat(SI_NUMBER_FORMAT, ZO_CommaDelimitNumber(data.hitValue)))

  local abilityType = RF.RECAP_ACTION_RESULTS[data.abilityType] ~= nil and RF.RECAP_ACTION_RESULTS[data.abilityType] or ""
  control.abilityType = GetControl(control, "AbilityType")
  control.abilityType:SetText(abilityType)


  ZO_SortFilterList.SetupRow(self, control, data)
end

function RecapScrollList:BuildMasterList()

  self.masterList = {}

  -- iterate big ass array
  for k, v in pairs(selectedRecap) do

    -- table insert each row into masterlist
    table.insert(self.masterList, {
        timestamp = v.timestamp,
        abilityId = v.abilityId,
        abilityName = v.abilityName,
        sourceName = v.sourceName,
        hitValue = v.hitValue,
        multipleHits = v.multipleHits,
        abilityType = v.abilityType,
    })
  end
end

function RecapScrollList:SortScrollList()
  -- local scrollData = ZO_ScrollList_GetDataList(self.list)
  -- table.sort(scrollData, self.sortFunction)
end

function RecapScrollList:FilterScrollList()
  local typeId = compactMode and 1 or 2
  local scrollData = ZO_ScrollList_GetDataList(self.list)
  ZO_ClearNumericallyIndexedTable(scrollData)

  for i = 1, #self.masterList do
    local data = self.masterList[i]
    table.insert(scrollData, ZO_ScrollList_CreateDataEntry(typeId, data))
  end
end

function RecapScrollList:ScrollToBottom()
  local scrollData = ZO_ScrollList_GetDataList(self.list)
  local size = NonContiguousCount(scrollData)

  if size > 0 then
    ZO_ScrollList_ScrollDataIntoView(self.list, size)
  end
end

local currentName = "Erm"
local currentRecapNo = 1

function RecapScrollList:SelectRecap(name, recapNo)

  if recapNo > 0 and recapNo <= #allPlayersListableItems[name].recapList then
    currentName = name
    currentRecapNo = recapNo
    selectedRecap = allPlayersListableItems[name].recapList[recapNo]
    RF_RECAP:SetHidden(false)

    if recapNo == #allPlayersListableItems[name].recapList then
      -- live recap
      RF_RECAP_Title:SetText(name .. " Live")
      RF_RECAP_Footer:SetText("Live")
    else
      -- death recap
      RF_RECAP_Title:SetText(name .. " Death Recap")
      RF_RECAP_Footer:SetText(currentRecapNo .. " / " .. #allPlayersListableItems[name].recapList-1)
    end

    self:RefreshData()
    self:RefreshFilters()
    self:ScrollToBottom()
    return true
  end

  return false
end

function RecapScrollList:RefreshIfLive()

  -- only do this if recap is showing
  if RF_RECAP:IsHidden() then return end

  -- switch to live recap if we are watching this player
  if currentRecapNo ~= #allPlayersListableItems[currentName].recapList then

    -- dont switch recap to live if player dead
    if IsUnitDead("player") then
      return
    else
      currentRecapNo = #allPlayersListableItems[currentName].recapList
      self:SelectRecap(currentName, currentRecapNo)
    end
  end

  if currentRecapNo == #allPlayersListableItems[currentName].recapList then
    self:RefreshData()
    self:RefreshFilters()
    self:ScrollToBottom()
  end
end

function RecapScrollList:Previous()
  self:SelectRecap(currentName, currentRecapNo - 1)
end

function RecapScrollList:Next()
  self:SelectRecap(currentName, currentRecapNo + 1)
end