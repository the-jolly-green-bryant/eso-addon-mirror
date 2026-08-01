---------------------------------------------------------------------------------------- 
-- Global vars and constants
----------------------------------------------------------------------------------------

Crafty = {}
Crafty.name = "Crafty"
Crafty.version = "v2.65"
Crafty.showSL = false
Crafty.showWL = true
Crafty.ankerSL = true
Crafty.vendorOpen = false
Crafty.vendorClose = false
Crafty.showTS = false
Crafty.showLH = false
Crafty.undoRemove = nil
Crafty.differentWLPositions = false
Crafty.db = false
Crafty.filterTypeSL = 1
Crafty.watchList1 = {}
Crafty.watchList2 = {}
Crafty.watchList3 = {}
Crafty.activewatchList = Crafty.watchList1
Crafty.activewatchListID = 1
Crafty.vendorwatchListID = 1
Crafty.oldactivewatchListID = 1
Crafty.oldshowWL = true
Crafty.oldshowLH = true
Crafty.masterHeight = 600
Crafty.masterWidth = 300
Crafty.autoHeightWL = 600
Crafty.autoHeightWLOpt = true
Crafty.loothistoryHeight = 300
Crafty.masterAlpha = 1
Crafty.accountWide = false
Crafty.sortWLName = "up"
Crafty.sortWLAmount = "down"
Crafty.sortWL = "Name"
Crafty.sortSLName = "up"
Crafty.sortSLAmount = "down"
Crafty.sortSL = "Name"
Crafty.minModeWL1 = false
Crafty.minModeWL2 = false
Crafty.minModeWL3 = false
Crafty.toolTip = true
Crafty.showUIToolTip = true
Crafty.disableVendorItemsearch = false
Crafty.myStyles = {}
Crafty.lootHistory = {}
Crafty.historyAmount = 0
Crafty.thresholdTable = {}
Crafty.thresholdItem = nil
Crafty.thresholdFilter1 = false
Crafty.thresholdFilter2 = false
Crafty.thresholdFilter3 = false
Crafty.activewatchListThresholdFilter = false
Crafty.alarmTable = {}
Crafty.alarmTrigger = {}
Crafty.alarmToggle = true
Crafty.vendorIsOpen = false
Crafty.durationAlarm = 5000
Crafty.durationLoot = 5000

----------------------------------------------------------------------------------------
-- Init functions
----------------------------------------------------------------------------------------

-- initialize when addon was loaded
function Crafty.OnAddOnLoaded(event, addonName)
  if addonName == Crafty.name then
    Crafty.DB("Crafty: OnAddOnLoaded")
    Crafty:Initialize()
  end
end

-- initialize saved vars, positions, listdata and settings
function Crafty:Initialize()
  Crafty.DB("Crafty: Initialize")

  self.savedVariablesACC = ZO_SavedVars:NewAccountWide("CraftySavedVariablesACC", 1, nil, {})  

  if Crafty.savedVariablesACC.AccountWide ~= nil then Crafty.accountWide = Crafty.savedVariablesACC.AccountWide end  

  if not Crafty.accountWide then
    self.savedVariables = ZO_SavedVars:NewCharacterIdSettings("CraftySavedVariables", 1, nil, {})
  else
    self.savedVariables = ZO_SavedVars:NewAccountWide("CraftySavedVariables", 1, nil, {})
  end

  if Crafty.savedVariables.AnkerSL ~= nil then Crafty.ankerSL = Crafty.savedVariables.AnkerSL end
  if Crafty.savedVariables.ShowSL ~= nil then Crafty.showSL = Crafty.savedVariables.ShowSL end
  if Crafty.savedVariables.ShowWL ~= nil then Crafty.showWL = Crafty.savedVariables.ShowWL end
  if Crafty.savedVariables.ShowLH ~= nil then Crafty.showLH = Crafty.savedVariables.ShowLH end
  if Crafty.savedVariables.WatchList1 ~= nil then Crafty.watchList1 = Crafty.savedVariables.WatchList1 end
  if Crafty.savedVariables.WatchList2 ~= nil then Crafty.watchList2 = Crafty.savedVariables.WatchList2 end
  if Crafty.savedVariables.WatchList3 ~= nil then Crafty.watchList3 = Crafty.savedVariables.WatchList3 end
  if Crafty.savedVariables.ActivewatchList ~= nil then Crafty.activewatchList = Crafty.savedVariables.ActivewatchList end
  if Crafty.savedVariables.ActivewatchListID ~= nil then Crafty.activewatchListID = Crafty.savedVariables.ActivewatchListID end
  if Crafty.savedVariables.DifferentWLPositions ~= nil then Crafty.differentWLPositions = Crafty.savedVariables.DifferentWLPositions end
  if Crafty.savedVariables.VendorOpen ~= nil then Crafty.vendorOpen = Crafty.savedVariables.VendorOpen end
  if Crafty.savedVariables.VendorClose ~= nil then Crafty.vendorClose = Crafty.savedVariables.VendorClose end
  if Crafty.savedVariables.VendorwatchListID ~= nil then Crafty.vendorwatchListID = Crafty.savedVariables.VendorwatchListID end
  if Crafty.savedVariables.MasterAlpha ~= nil then Crafty.masterAlpha = Crafty.savedVariables.MasterAlpha end
  if Crafty.savedVariables.MasterHeight ~= nil then Crafty.masterHeight = Crafty.savedVariables.MasterHeight end
  if Crafty.savedVariables.LoothistoryHeight ~= nil then Crafty.loothistoryHeight = Crafty.savedVariables.LoothistoryHeight end
  if Crafty.savedVariables.AutoHeightWLOpt ~= nil then Crafty.autoHeightWLOpt = Crafty.savedVariables.AutoHeightWLOpt end
  if Crafty.savedVariables.SortWLName ~= nil then Crafty.sortWLName = Crafty.savedVariables.SortWLName end  
  if Crafty.savedVariables.SortSLName ~= nil then Crafty.sortSLName = Crafty.savedVariables.SortSLName end  
  if Crafty.savedVariables.SortWLAmount ~= nil then Crafty.sortWLAmount = Crafty.savedVariables.SortWLAmount end  
  if Crafty.savedVariables.SortSLAmount ~= nil then Crafty.sortSLAmount = Crafty.savedVariables.SortSLAmount end  
  if Crafty.savedVariables.SortWL ~= nil then Crafty.sortWL = Crafty.savedVariables.SortWL end  
  if Crafty.savedVariables.SortSL ~= nil then Crafty.sortSL = Crafty.savedVariables.SortSL end 
  if Crafty.savedVariables.MinModeWL1 ~= nil then Crafty.minModeWL1 = Crafty.savedVariables.MinModeWL1 end 
  if Crafty.savedVariables.MinModeWL2 ~= nil then Crafty.minModeWL2 = Crafty.savedVariables.MinModeWL2 end 
  if Crafty.savedVariables.MinModeWL3 ~= nil then Crafty.minModeWL3 = Crafty.savedVariables.MinModeWL3 end
  if Crafty.savedVariables.ToolTip ~= nil then Crafty.toolTip = Crafty.savedVariables.ToolTip end
  if Crafty.savedVariables.LootHistory ~= nil then Crafty.lootHistory = Crafty.savedVariables.LootHistory end
  if Crafty.savedVariables.HistoryAmount ~= nil then Crafty.historyAmount = Crafty.savedVariables.HistoryAmount end
  if Crafty.savedVariables.ThresholdTable ~= nil then Crafty.thresholdTable = Crafty.savedVariables.ThresholdTable end
  if Crafty.savedVariables.ThresholdFilter1 ~= nil then Crafty.thresholdFilter1 = Crafty.savedVariables.ThresholdFilter1 end
  if Crafty.savedVariables.ThresholdFilter2 ~= nil then Crafty.thresholdFilter2 = Crafty.savedVariables.ThresholdFilter2 end
  if Crafty.savedVariables.ThresholdFilter3 ~= nil then Crafty.thresholdFilter3 = Crafty.savedVariables.ThresholdFilter3 end
  if Crafty.savedVariables.ActivewatchListThresholdFilter ~= nil then Crafty.activewatchListThresholdFilter = Crafty.savedVariables.ActivewatchListThresholdFilter end
  if Crafty.savedVariables.AlarmTable ~= nil then Crafty.alarmTable = Crafty.savedVariables.AlarmTable end
  if Crafty.savedVariables.AlarmToggle ~= nil then Crafty.alarmToggle = Crafty.savedVariables.AlarmToggle end
  if Crafty.savedVariables.DurationAlarm ~= nil then Crafty.durationAlarm = Crafty.savedVariables.DurationAlarm end
  if Crafty.savedVariables.DurationLoot ~= nil then Crafty.durationLoot = Crafty.savedVariables.DurationLoot end
  if Crafty.savedVariables.ShowUIToolTip ~= nil then Crafty.showUITooltip = Crafty.savedVariables.ShowUIToolTip end
  if Crafty.savedVariables.DisableVendorItemsearch ~= nil then Crafty.disableVendorItemsearch = Crafty.savedVariables.DisableVendorItemsearch end
 
  Crafty:RestorePosition()
  Crafty.ControlSettings()

  Crafty.CreateScrollListDataTypeSL()
  local stockSL = Crafty.PopulateSL()
  local typeIdSL = 1
  Crafty.UpdateScrollListSL(CraftyStockListList, stockSL, typeIdSL)

  Crafty.CreateScrollListDataTypeWL()
  local stockWL = Crafty.PopulateWL()
  local typeIdWL = 2
  if table.getn(stockWL) ~= 0 then
    Crafty.UpdateScrollListWL(CraftyWatchListList, stockWL, typeIdWL)
  end

  Crafty.CreateScrollListDataTypeLH()
  local stockLH = Crafty.PopulateLH()
  local typeIdLH = 3
  if table.getn(stockLH) ~= 0 then
    Crafty.UpdateScrollListLH(CraftyStockListHistoryList, stockLH, typeIdLH)
  end

  Crafty.SetMasterHeight()
  Crafty.SetLoothistoryHeight()
  Crafty.SetMasterAlpha()
  Crafty.SetTS(1) 

  if Crafty.showWL then
    Crafty.SetActiveWatchList(Crafty.activewatchListID)
    Crafty.SortWLTexture()
    Crafty.SortSLTexture()
  else
    Crafty.SetActiveWatchList(Crafty.activewatchListID)
    Crafty.SortWLTexture()
    Crafty.SortSLTexture()
    Crafty.CloseWL()
  end

  if Crafty.showWL and Crafty.showSL then
    Crafty.OpenSL()
  end

  if Crafty.showLH then
    Crafty.OpenLH()
  else
    Crafty.CloseLH()
  end

  if Crafty.alarmToggle then
    Crafty.SetAlarmMode()
  else
    Crafty.EndAlarmMode()
  end

  Crafty.BuildStyleTable()
  CraftyStockListHistoryHistoryAmount:SetText(Crafty.historyAmount)
  Crafty.CheckHistoryEmpty()

end

----------------------------------------------------------------------------------------
-- Modifiy the interface position / height
----------------------------------------------------------------------------------------

-- set overall interfaceheight (from settings)
function Crafty.SetMasterHeight()
  Crafty.DB("Crafty: SetMasterHeight")

  local width = Crafty.masterWidth
  local height = Crafty.masterHeight
  local myMinMode = false

  if Crafty.activewatchListID == 1 then
    if Crafty.minModeWL1 then myMinMode = true end
  elseif Crafty.activewatchListID == 2 then
    if Crafty.minModeWL2 then myMinMode = true end
  elseif Crafty.activewatchListID == 3 then
    if Crafty.minModeWL3 then myMinMode = true end
  end

  if myMinMode then
    CraftyWatchList:SetWidth(115)
  else
    CraftyWatchList:SetWidth(width)
  end
  CraftyWatchList:SetHeight(height)

  CraftyStockList:SetWidth(width)
  CraftyStockList:SetHeight(height)
  --CraftyStockListType:SetWidth(width)
  --CraftyStockListType:SetHeight(height)

  Crafty.savedVariables.MasterHeight = height
  Crafty.Refresh()
end

function Crafty.SetLoothistoryHeight()
  Crafty.DB("Crafty: SetLoothistoryHeight")

  local height = Crafty.loothistoryHeight
  CraftyStockListHistory:SetHeight(height)

  Crafty.savedVariables.LoothistoryHeight = height
  Crafty.Refresh()
end

-- set overall backgroundalpha (from settings)
function Crafty.SetMasterAlpha()
  Crafty.DB("Crafty: SetMasterAlpha")

  CraftyWatchListBG:SetAlpha(Crafty.masterAlpha)
  CraftyStockListBG:SetAlpha(Crafty.masterAlpha)
  CraftyStockListTypeBG:SetAlpha(Crafty.masterAlpha)
  --CraftyStockListTooltipBG:SetAlpha(Crafty.masterAlpha)
  CraftyStockListHistoryBG:SetAlpha(Crafty.masterAlpha)
  --CraftyStockListThresholdBG:SetAlpha(Crafty.masterAlpha)

  Crafty.savedVariables.MasterAlpha = Crafty.masterAlpha
end

-- save position data after moving the interface (from xml)
function Crafty.OnIndicatorMoveStop()
  Crafty.DB("Crafty: OnIndicatorMoveStop - WL"..Crafty.activewatchListID)

  Crafty.savedVariables.leftSL = CraftyStockList:GetLeft()
  Crafty.savedVariables.topSL = CraftyStockList:GetTop()

  Crafty.savedVariables.leftLH = CraftyStockListHistory:GetLeft()
  Crafty.savedVariables.topLH = CraftyStockListHistory:GetTop()

  if Crafty.differentWLPositions then
    if Crafty.activewatchListID == 1 then
      Crafty.savedVariables.leftWL1 = CraftyWatchList:GetLeft()
      Crafty.savedVariables.topWL1 = CraftyWatchList:GetTop()
    end
    if Crafty.activewatchListID == 2 then
      Crafty.savedVariables.leftWL2 = CraftyWatchList:GetLeft()
      Crafty.savedVariables.topWL2 = CraftyWatchList:GetTop()
    end
    if Crafty.activewatchListID == 3 then
      Crafty.savedVariables.leftWL3 = CraftyWatchList:GetLeft()
      Crafty.savedVariables.topWL3 = CraftyWatchList:GetTop()
    end
  else
    Crafty.savedVariables.leftWL = CraftyWatchList:GetLeft()
    Crafty.savedVariables.topWL = CraftyWatchList:GetTop()
  end

  if Crafty.ankerSL then
    Crafty.AnkerSL()
  end
end

-- set position for interface from saved vars and check for anchor stocklist
function Crafty:RestorePosition()
  Crafty.DB("Crafty: RestorePosition - WL"..Crafty.activewatchListID)

  local leftLH = Crafty.savedVariables.leftLH
  local topLH = Crafty.savedVariables.topLH
  CraftyStockListHistory:ClearAnchors()
  CraftyStockListHistory:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, leftLH, topLH) 

  if not Crafty.ankerSL then
    local leftSL = Crafty.savedVariables.leftSL
    local topSL = Crafty.savedVariables.topSL
    CraftyStockList:ClearAnchors()
    CraftyStockList:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, leftSL, topSL)
    CraftyStockListButtonToggleAnkerSL:SetNormalTexture("esoui/art/miscellaneous/unlocked_up.dds")
    CraftyStockListButtonToggleAnkerSL:SetPressedTexture("esoui/art/miscellaneous/unlocked_down.dds")
  else
    Crafty.AnkerSL()
  end
end

function Crafty.ToggleMinMode()
  Crafty.DB("Crafty: ToggleMinMode - WL:"..Crafty.activewatchListID)
  local wl = Crafty.activewatchListID

  if wl == 1 then
    if Crafty.minModeWL1 then
      Crafty.minModeWL1 = false
      Crafty.savedVariables.MinModeWL1 = Crafty.minModeWL1
      Crafty.EndMinMode()
    else
      Crafty.minModeWL1 = true
      Crafty.savedVariables.MinModeWL1 = Crafty.minModeWL1
      Crafty.SetMinMode()
    end
  end
    if wl == 2 then
    if Crafty.minModeWL2 then
      Crafty.minModeWL2 = false
      Crafty.savedVariables.MinModeWL2 = Crafty.minModeWL2
      Crafty.EndMinMode()
    else
      Crafty.minModeWL2 = true
      Crafty.savedVariables.MinModeWL2 = Crafty.minModeWL2
      Crafty.SetMinMode()
    end
  end
    if wl == 3 then
    if Crafty.minModeWL3 then
      Crafty.minModeWL3 = false
      Crafty.savedVariables.MinModeWL3 = Crafty.minModeWL3
      Crafty.EndMinMode()
    else
      Crafty.minModeWL3 = true
      Crafty.savedVariables.MinModeWL3 = Crafty.minModeWL3
      Crafty.SetMinMode()
    end
  end
  Crafty.Refresh()
end

function Crafty.SetMinMode()
  Crafty.DB("Crafty: SetMinMode - WL:"..Crafty.activewatchListID)
  CraftyWatchListWatchList1:SetHidden(true)
  CraftyWatchListWatchList2:SetHidden(true)
  CraftyWatchListWatchList3:SetHidden(true)
  CraftyWatchListButtonClose:SetHidden(true)
  CraftyWatchListButtonSettings:SetHidden(true)
  CraftyWatchListButtonStockList:SetHidden(true)
  CraftyWatchListButtonLootHistory:SetHidden(true)
  CraftyWatchListDivider:SetHidden(true)
  CraftyWatchListSortName:SetHidden(true)
  CraftyWatchListSortAmount:SetHidden(true)
  CraftyWatchList:SetWidth(115)

  CraftyWatchListList:SetAnchor(TOPLEFT, CraftyWatchList, TOPLEFT, 10, 10)
  --CraftyWatchListMinMode:SetNormalTexture("esoui/art/buttons/minus_down.dds")

  Crafty.SetHeightWL()
end

function Crafty.EndMinMode()
  Crafty.DB("Crafty: EndMinMode - WL:"..Crafty.activewatchListID)
  CraftyWatchListWatchList1:SetHidden(false)
  CraftyWatchListWatchList2:SetHidden(false)
  CraftyWatchListWatchList3:SetHidden(false)
  CraftyWatchListButtonClose:SetHidden(false)
  CraftyWatchListButtonSettings:SetHidden(false)
  CraftyWatchListButtonStockList:SetHidden(false)
  CraftyWatchListButtonLootHistory:SetHidden(false)
  CraftyWatchListDivider:SetHidden(false)
  CraftyWatchListSortName:SetHidden(false)
  CraftyWatchListSortAmount:SetHidden(false)
  CraftyWatchList:SetWidth(300)

  CraftyWatchListList:SetAnchor(TOPLEFT, CraftyWatchListDivider, BOTTOMLEFT, 0, 10)
  --CraftyWatchListMinMode:SetNormalTexture("esoui/art/buttons/minus_up.dds")
  Crafty.SetHeightWL()
end

function Crafty.ToggleThresholdMode()
  Crafty.DB("Crafty: ToggleThresholdMode - WL: "..Crafty.activewatchListID)
  local wl = Crafty.activewatchListID

  if wl == 1 then
    if Crafty.thresholdFilter1 then
      Crafty.thresholdFilter1 = false
      Crafty.savedVariables.ThresholdFilter1 = Crafty.thresholdFilter1
    else
      Crafty.thresholdFilter1 = true
      Crafty.savedVariables.ThresholdFilter1 = Crafty.thresholdFilter1
    end
  end
    if wl == 2 then
    if Crafty.thresholdFilter2 then
      Crafty.thresholdFilter2 = false
      Crafty.savedVariables.ThresholdFilter2 = Crafty.thresholdFilter2
    else
      Crafty.thresholdFilter2 = true
      Crafty.savedVariables.ThresholdFilter2 = Crafty.thresholdFilter2
    end
  end
    if wl == 3 then
    if Crafty.thresholdFilter3 then
      Crafty.thresholdFilter3 = false
      Crafty.savedVariables.ThresholdFilter3 = Crafty.thresholdFilter3
    else
      Crafty.thresholdFilter3 = true
      Crafty.savedVariables.ThresholdFilter3 = Crafty.thresholdFilter3
    end
  end

  Crafty.SetThresholdMode()
  Crafty.Refresh()

end

function Crafty.SetThresholdMode()

  local wl = Crafty.activewatchListID
  if wl == 1 then Crafty.activewatchListThresholdFilter = Crafty.thresholdFilter1 end
  if wl == 2 then Crafty.activewatchListThresholdFilter = Crafty.thresholdFilter2 end
  if wl == 3 then Crafty.activewatchListThresholdFilter = Crafty.thresholdFilter3 end

  Crafty.DB("Crafty: SetThresholdMode - WL: "..wl)

  Crafty.savedVariables.ActivewatchListThresholdFilter = Crafty.activewatchListThresholdFilter

  if Crafty.activewatchListThresholdFilter then
    CraftyWatchListThresholdMode:SetNormalTexture("/esoui/art/treeicons/tutorial_idexicon_charprogression_down.dds")
  else
    CraftyWatchListThresholdMode:SetNormalTexture("/esoui/art/treeicons/tutorial_idexicon_charprogression_up.dds")
  end
end

function Crafty.ToggleAlarmMode()
  Crafty.DB("Crafty: ToggleAlarmMode")
  if Crafty.alarmToggle then
    Crafty.alarmToggle = false
    Crafty.EndAlarmMode()
  else
    Crafty.alarmToggle = true
    Crafty.SetAlarmMode()
  end
end

function Crafty.SetAlarmMode()
  Crafty.DB("Crafty: SetAlarmMode")
  CraftyStockListAlarmMode:SetNormalTexture("/esoui/art/lfg/lfg_healer_down_64.dds")
  Crafty.savedVariables.AlarmToggle = Crafty.alarmToggle
end

function Crafty.EndAlarmMode()
  Crafty.DB("Crafty: EndAlarmMode")
  CraftyStockListAlarmMode:SetNormalTexture("/esoui/art/lfg/lfg_healer_up_64.dds")
  Crafty.savedVariables.AlarmToggle = Crafty.alarmToggle
end

-- restore saved position for specific watchlist
function Crafty.RestoreWLPosition(arg)
  Crafty.DB("Crafty: RestoreWLPosition - WL"..arg)

  if Crafty.differentWLPositions then
    if arg == 1 then
      local leftWL = Crafty.savedVariables.leftWL1
      local topWL = Crafty.savedVariables.topWL1
      CraftyWatchList:ClearAnchors()
      CraftyWatchList:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, leftWL, topWL)
    end
    if arg == 2 then
      local leftWL = Crafty.savedVariables.leftWL2
      local topWL = Crafty.savedVariables.topWL2
      CraftyWatchList:ClearAnchors()
      CraftyWatchList:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, leftWL, topWL)
    end
    if arg == 3 then
      local leftWL = Crafty.savedVariables.leftWL3
      local topWL = Crafty.savedVariables.topWL3
      CraftyWatchList:ClearAnchors()
      CraftyWatchList:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, leftWL, topWL)
    end
  else
    if Crafty.savedVariables.leftWL ~= nil then -- only if its not the first time wihout saved pos vars
      local leftWL = Crafty.savedVariables.leftWL
      local topWL = Crafty.savedVariables.topWL
      CraftyWatchList:ClearAnchors()
      CraftyWatchList:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, leftWL, topWL)
    end
  end

end

-- calculate the autoheight for the watchlist, sets the global var
function Crafty.CalculateHeightWL(arg)
  Crafty.DB("Crafty: CalculateHeightWL")
  local watchList = Crafty.activewatchList
  local watchlistItems = table.getn(watchList)
  if arg ~= nil then watchlistItems = arg end
  local watchListID = Crafty.activewatchListID
  local minmode = false

  if watchListID == 1 then minmode = Crafty.minModeWL1 end
  if watchListID == 2 then minmode = Crafty.minModeWL2 end
  if watchListID == 3 then minmode = Crafty.minModeWL3 end

  if minmode then
    Crafty.autoHeightWL = 25+watchlistItems*30
  else
    Crafty.autoHeightWL = 75+watchlistItems*30
  end
end

-- sets the autoheight value to the xml element watchlist
function Crafty.SetHeightWL(arg)
  if Crafty.autoHeightWLOpt then
    Crafty.DB("Crafty: SetHeightWL")
    Crafty.CalculateHeightWL(arg)
    --local width = Crafty.masterWidth
    local height = Crafty.autoHeightWL

    --CraftyWatchList:SetWidth(width)
    CraftyWatchList:SetHeight(height)
  end
end

-- refreshes the autoheight or sets the masterheight for the watchlist (from settings)
function Crafty.CheckAutoHeightWLOpt()
  if Crafty.autoHeightWLOpt then
    Crafty.Refresh()
    --Crafty.SetHeightWL()
  else
    Crafty.SetMasterHeight()
    Crafty.Refresh()
  end
  Crafty.savedVariables.AutoHeightWLOpt = Crafty.autoHeightWLOpt
end

----------------------------------------------------------------------------------------
-- Listdatahandling
----------------------------------------------------------------------------------------

-- create datatype for scrollist stocklist
function Crafty.CreateScrollListDataTypeSL()
  Crafty.DB("Crafty: CreateScrollListDataTypeSL")
  local control = CraftyStockListList
  local typeId = 1
  local templateName = "StockRow"
  local height = 30
  local setupFunction = Crafty.LayoutRow
  local hideCallback = nil
  local dataTypeSelectSound = nil
  local resetControlCallback = nil
  --local selectTemplate = "ZO_ThinListHighlight"
  --local selectCallback = Crafty.OnMouseUp

  ZO_ScrollList_AddDataType(control, typeId, templateName, height, setupFunction, hideCallback, dataTypeSelectSound, resetControlCallback)
  --ZO_ScrollList_EnableSelection(control, selectTemplate, selectCallback)
end

-- create datatype for scrollist watchlist
function Crafty.CreateScrollListDataTypeWL()
  Crafty.DB("Crafty: CreateScrollListDataTypeWL")
  local control = CraftyWatchListList
  local typeId = 2
  local templateName = "WatchRow"
  local height = 30
  local setupFunction = Crafty.LayoutRow
  local hideCallback = nil
  local dataTypeSelectSound = nil
  local resetControlCallback = nil
  --local selectTemplate = "ZO_ThinListHighlight"
  --local selectCallback = Crafty.OnMouseUp

  ZO_ScrollList_AddDataType(control, typeId, templateName, height, setupFunction, hideCallback, dataTypeSelectSound, resetControlCallback)
  --ZO_ScrollList_EnableSelection(control, selectTemplate, selectCallback)
end

function Crafty.CreateScrollListDataTypeLH()
  Crafty.DB("Crafty: CreateScrollListDataTypeLH")
  local control = CraftyStockListHistoryList
  local typeId = 3
  local templateName = "HistoryRow"
  local height = 30
  local setupFunction = Crafty.LayoutRowLH
  local hideCallback = nil
  local dataTypeSelectSound = nil
  local resetControlCallback = nil
  --local selectTemplate = "ZO_ThinListHighlight"
  --local selectCallback = Crafty.OnMouseUp

  ZO_ScrollList_AddDataType(control, typeId, templateName, height, setupFunction, hideCallback, dataTypeSelectSound, resetControlCallback)
  --ZO_ScrollList_EnableSelection(control, selectTemplate, selectCallback)
end

-- set the active watchlist (from xml)
function Crafty.SetActiveWatchList(arg)
  Crafty.DB("Crafty: SetActiveWatchList: "..arg)
  local mydefcolor = ZO_ColorDef:New("CFDCBD")

  CraftyWatchListWatchList1:SetColor(mydefcolor:UnpackRGBA())
  CraftyWatchListWatchList2:SetColor(mydefcolor:UnpackRGBA())
  CraftyWatchListWatchList3:SetColor(mydefcolor:UnpackRGBA())
  CraftyWatchListWatchList1:SetFont("ZoFontWinH4")
  CraftyWatchListWatchList2:SetFont("ZoFontWinH4")
  CraftyWatchListWatchList3:SetFont("ZoFontWinH4")

  if arg == 1 then
    Crafty.DB(Crafty.minModeWL1)
    CraftyWatchListWatchList1:SetColor(1,1,1)
    CraftyWatchListWatchList1:SetFont("ZoFontWinH4")
    Crafty.activewatchList = Crafty.watchList1
    if Crafty.minModeWL1 then Crafty.SetMinMode() else Crafty.EndMinMode() end
  end
  if arg == 2 then
    CraftyWatchListWatchList2:SetColor(1,1,1)
    CraftyWatchListWatchList2:SetFont("ZoFontWinH4")
    Crafty.activewatchList = Crafty.watchList2
    if Crafty.minModeWL2 then Crafty.SetMinMode() else Crafty.EndMinMode() end
  end
  if arg == 3 then
    CraftyWatchListWatchList3:SetColor(1,1,1)
    CraftyWatchListWatchList3:SetFont("ZoFontWinH4")
    Crafty.activewatchList = Crafty.watchList3
    if Crafty.minModeWL3 then Crafty.SetMinMode() else Crafty.EndMinMode() end
  end

  Crafty.savedVariables.ActivewatchList = Crafty.activewatchList
  Crafty.savedVariables.ActivewatchListThresholdFilter = Crafty.activewatchListThresholdFilter
  Crafty.savedVariables.ActivewatchListID = arg
  Crafty.activewatchListID = arg

  Crafty.showWL = true
  Crafty.savedVariables.ShowWL = true
  CraftyWatchList:SetHidden(false)

  Crafty.SetThresholdMode()
  Crafty.RestoreWLPosition(arg)
  Crafty.Refresh()

  Crafty.ReturnWLItemAmounts()
end

-- set the global var for material type for the typelist
function Crafty.SetTS(arg)
  Crafty.DB("Crafty: SetTS")
  local myoldTS = Crafty.filterTypeSL
  local myTS = arg
  Crafty.filterTypeSL = myTS

  CraftyStockListTypeAlchemyIcon:SetState(0,false)
  CraftyStockListTypeBlacksmithingIcon:SetState(0,false)
  CraftyStockListTypeClothierIcon:SetState(0,false)
  CraftyStockListTypeEnchantingIcon:SetState(0,false)
  CraftyStockListTypeJewelryIcon:SetState(0,false)
  CraftyStockListTypeProvisioningIcon:SetState(0,false)
  CraftyStockListTypeWoodworkingIcon:SetState(0,false)
  CraftyStockListTypeMatsIcon:SetState(0,false)
  CraftyStockListTypeTraitIcon:SetState(0,false)
  CraftyStockListTypeStyleIcon:SetState(0,false)
  CraftyStockListTypeAlarmIcon:SetState(0,false)
  CraftyStockListTypeThresholdIcon:SetState(0,false)

  if         arg == 40 then CraftyStockListTypeMatsIcon:SetState(1,false)
      elseif arg == 1 then CraftyStockListTypeBlacksmithingIcon:SetState(1,false)
      elseif arg == 2 then CraftyStockListTypeClothierIcon:SetState(1,false)
      elseif arg == 3 then CraftyStockListTypeEnchantingIcon:SetState(1,false)
      elseif arg == 4 then CraftyStockListTypeAlchemyIcon:SetState(1,false)
      elseif arg == 5 then CraftyStockListTypeProvisioningIcon:SetState(1,false)
      elseif arg == 6 then CraftyStockListTypeWoodworkingIcon:SetState(1,false)
      elseif arg == 7 then CraftyStockListTypeJewelryIcon:SetState(1,false)
      elseif arg == 20 then CraftyStockListTypeTraitIcon:SetState(1,false)
      elseif arg == 30 then CraftyStockListTypeStyleIcon:SetState(1,false)
      elseif arg == 50 then CraftyStockListTypeThresholdIcon:SetState(1,false)
      elseif arg == 100 then CraftyStockListTypeAlarmIcon:SetState(1,false)
      else
  end

  Crafty.Refresh()
end

-- fill the stocklist with data, uses the global var from materialtype
function Crafty.PopulateSL()
  Crafty.DB("Crafty: PopulateSL")
  local type = Crafty.filterTypeSL
  local stock = {}
  local stockcounter = 0
  local itemType
  local itemTypeSpec
  local itemTypeSpecText

  if type == 20 then -- Traititems
    for index, data in pairs(SHARED_INVENTORY.bagCache[BAG_VIRTUAL]) do
      if data ~= nil then
        itemType, itemTypeSpec = GetItemLinkItemType(GetItemLink(BAG_VIRTUAL,data.slotIndex))
        itemTypeSpecText = GetString("SI_SPECIALIZEDITEMTYPE", itemTypeSpec)
        if itemTypeSpecText == "Armor Trait" or itemTypeSpecText == "Weapon Trait" or itemTypeSpecText == "Jewelry Trait" then
          stockcounter = stockcounter + 1
          stock[stockcounter] = {
            link = GetItemLink(BAG_VIRTUAL,data.slotIndex),
            name = GetItemName(BAG_VIRTUAL,data.slotIndex),
            amount = GetSlotStackSize(BAG_VIRTUAL,data.slotIndex),
            cinfo = GetItemCraftingInfo(BAG_VIRTUAL,data.slotIndex)
          }
        end
      end
    end
  elseif type == 30 then -- Styleitems
    for index, data in pairs(SHARED_INVENTORY.bagCache[BAG_VIRTUAL]) do
      if data ~= nil then
        itemType, itemTypeSpec = GetItemLinkItemType(GetItemLink(BAG_VIRTUAL,data.slotIndex))
        itemTypeSpecText = GetString("SI_SPECIALIZEDITEMTYPE", itemTypeSpec)
        if itemTypeSpecText == "Style Material" then
          stockcounter = stockcounter + 1
          stock[stockcounter] = {
            link = GetItemLink(BAG_VIRTUAL,data.slotIndex),
            name = GetItemName(BAG_VIRTUAL,data.slotIndex),
            amount = GetSlotStackSize(BAG_VIRTUAL,data.slotIndex),
            cinfo = GetItemCraftingInfo(BAG_VIRTUAL,data.slotIndex)
          }
        end
      end
    end
  elseif type == 40 then -- Other material (GetItemCraftingInfo(BAG_VIRTUAL,data.slotIndex) == 0)
    for index, data in pairs(SHARED_INVENTORY.bagCache[BAG_VIRTUAL]) do
      if data ~= nil then
        itemType, itemTypeSpec = GetItemLinkItemType(GetItemLink(BAG_VIRTUAL,data.slotIndex))
        itemTypeSpecText = GetString("SI_SPECIALIZEDITEMTYPE", itemTypeSpec)
        if GetItemCraftingInfo(BAG_VIRTUAL,data.slotIndex) == 0 and itemTypeSpecText ~= "Armor Trait" and itemTypeSpecText ~= "Weapon Trait" and itemTypeSpecText ~= "Jewelry Trait" and itemTypeSpecText ~= "Style Material" then
          stockcounter = stockcounter + 1
          stock[stockcounter] = {
            link = GetItemLink(BAG_VIRTUAL,data.slotIndex),
            name = GetItemName(BAG_VIRTUAL,data.slotIndex),
            amount = GetSlotStackSize(BAG_VIRTUAL,data.slotIndex),
            cinfo = GetItemCraftingInfo(BAG_VIRTUAL,data.slotIndex)
          }
        end
      end
    end
  elseif type == 100 then -- All items with alarmflag
    for index, data in pairs(SHARED_INVENTORY.bagCache[BAG_VIRTUAL]) do
      if data ~= nil then
        if Crafty.ReturnAlarm(GetItemName(BAG_VIRTUAL,data.slotIndex)) then
          stockcounter = stockcounter + 1
          stock[stockcounter] = {
            link = GetItemLink(BAG_VIRTUAL,data.slotIndex),
            name = GetItemName(BAG_VIRTUAL,data.slotIndex),
            amount = GetSlotStackSize(BAG_VIRTUAL,data.slotIndex),
            cinfo = GetItemCraftingInfo(BAG_VIRTUAL,data.slotIndex)
          }
        end
      end
    end
  elseif type == 50 then -- All items with threshold
    for index, data in pairs(SHARED_INVENTORY.bagCache[BAG_VIRTUAL]) do
      if data ~= nil then
        if Crafty.ReturnThreshold(GetItemName(BAG_VIRTUAL,data.slotIndex)) ~= nil then
          stockcounter = stockcounter + 1
          stock[stockcounter] = {
            link = GetItemLink(BAG_VIRTUAL,data.slotIndex),
            name = GetItemName(BAG_VIRTUAL,data.slotIndex),
            amount = GetSlotStackSize(BAG_VIRTUAL,data.slotIndex),
            cinfo = GetItemCraftingInfo(BAG_VIRTUAL,data.slotIndex)
          }
        end
      end
    end
  else
    for index, data in pairs(SHARED_INVENTORY.bagCache[BAG_VIRTUAL]) do
      if data ~= nil then
        if GetItemCraftingInfo(BAG_VIRTUAL,data.slotIndex) == type then
          stockcounter = stockcounter + 1
          stock[stockcounter] = {
            link = GetItemLink(BAG_VIRTUAL,data.slotIndex),
            name = GetItemName(BAG_VIRTUAL,data.slotIndex),
            amount = GetSlotStackSize(BAG_VIRTUAL,data.slotIndex),
            cinfo = GetItemCraftingInfo(BAG_VIRTUAL,data.slotIndex)
          }
        end
      end
    end
  end

  return stock
end

-- fill the watchlist with data, uses active watchlist and also calls
-- refreshes the amounts, calling the autoheight value
function Crafty.PopulateWL()
  local watchList = Crafty.activewatchList
  local thresholdfilter = Crafty.activewatchListThresholdFilter

  Crafty.DB("Crafty: PopulateWL -"..Crafty.activewatchListID.."- Items: "..table.getn(watchList))
  Crafty.RefreshWLAmounts()
  local stock = {}
  local mj = 1

  if thresholdfilter then
    Crafty.DB("Crafty: Thresholdfilter is ON for WL -"..Crafty.activewatchListID.."-")
    for i=1, table.getn(watchList) do
     if Crafty.ReturnThreshold(watchList[i].name) ~= nil and watchList[i].amount < Crafty.ReturnThreshold(watchList[i].name) then
        Crafty.DB("Crafty: Threshold for item "..watchList[i].name.." is "..Crafty.ReturnThreshold(watchList[i].name))
        stock[mj] = {
          link = watchList[i].link,
          name = watchList[i].name,
          amount = watchList[i].amount,
          cinfo = watchList[i].cinfo
        }
        Crafty.DB(mj.."-"..stock[mj].name)
        mj = mj+1
      end
    end

  else
    Crafty.DB("Crafty: Thresholdfilter is OFF for WL -"..Crafty.activewatchListID.."-")
    for i=1,table.getn(watchList) do
        stock[i] = {
          link = watchList[i].link,
          name = watchList[i].name,
          amount = watchList[i].amount,
          cinfo = watchList[i].cinfo
        }
    end
  end

  Crafty.DB(table.getn(stock))

  Crafty.SetHeightWL(table.getn(stock))
  return stock
end

function Crafty.PopulateLH()
  local history = Crafty.lootHistory
  Crafty.DB("Crafty: PopulateLH Items:"..table.getn(history))
  local stock = {}
  for i=1,table.getn(history) do
    stock[i] = {
      link = history[i].link,
      amount = history[i].amount,
      time = history[i].time,
      stockamount = history[i].stockamount
    }
  end
  return stock
end

-- sorts the listdata, saves the data and commits the data to the scrollinglist stocklist
function Crafty.UpdateScrollListSL(control, data, rowType)
  Crafty.DB("Crafty: UpdateScrollListSL "..table.getn(data))

  local dataCopy = ZO_DeepTableCopy(data)
  local dataList = ZO_ScrollList_GetDataList(control)

  ZO_ScrollList_Clear(control)

  for key, value in ipairs(dataCopy) do
    local entry = ZO_ScrollList_CreateDataEntry(rowType, value)
    table.insert(dataList, entry)
  end

  if Crafty.sortSL == "Name" then
    if Crafty.sortSLName == "up" then
      table.sort(dataList, function(a,b) return a.data.name < b.data.name end)
    end
    if Crafty.sortSLName == "down" then
      table.sort(dataList, function(a,b) return a.data.name > b.data.name end)
    end
  end
  if Crafty.sortSL == "Amount" then
    if Crafty.sortSLAmount == "up" then
      table.sort(dataList, function(a,b) return a.data.amount < b.data.amount end)
    end
    if Crafty.sortSLAmount == "down" then
      table.sort(dataList, function(a,b) return a.data.amount > b.data.amount end)
    end
  end

  ZO_ScrollList_Commit(control)

  if Crafty.activewatchList == Crafty.watchList1 then
    Crafty.savedVariables.WatchList1 = Crafty.activewatchList
  end
  if Crafty.activewatchList == Crafty.watchList2 then
    Crafty.savedVariables.WatchList2 = Crafty.activewatchList
  end
  if Crafty.activewatchList == Crafty.watchList3 then
    Crafty.savedVariables.WatchList3 = Crafty.activewatchList
  end
end

-- sorts the listdata, saves the data and commits the data to the scrollinglist watchlist
function Crafty.UpdateScrollListWL(control, data, rowType)
  Crafty.DB("Crafty: UpdateScrollListWL "..table.getn(data))

  local dataCopyWL = ZO_DeepTableCopy(data)
  local dataListWL  = ZO_ScrollList_GetDataList(control)

  ZO_ScrollList_Clear(control)

  for key, value in ipairs(dataCopyWL) do
    local entry = ZO_ScrollList_CreateDataEntry(rowType, value)
    table.insert(dataListWL, entry)
  end

  if Crafty.sortWL == "Name" then
    if Crafty.sortWLName == "up" then
      table.sort(dataListWL, function(a,b) return a.data.name < b.data.name end)
    end
    if Crafty.sortWLName == "down" then
      table.sort(dataListWL, function(a,b) return a.data.name > b.data.name end)
    end
  end
  if Crafty.sortWL == "Amount" then
    if Crafty.sortWLAmount == "up" then
      table.sort(dataListWL, function(a,b) return a.data.amount < b.data.amount end)
    end
    if Crafty.sortWLAmount == "down" then
      table.sort(dataListWL, function(a,b) return a.data.amount > b.data.amount end)
    end
  end

  ZO_ScrollList_Commit(control)

  if Crafty.activewatchList == Crafty.watchList1 then
    Crafty.savedVariables.WatchList1 = Crafty.activewatchList
  end
  if Crafty.activewatchList == Crafty.watchList2 then
    Crafty.savedVariables.WatchList2 = Crafty.activewatchList
  end
  if Crafty.activewatchList == Crafty.watchList3 then
    Crafty.savedVariables.WatchList3 = Crafty.activewatchList
  end

end

function Crafty.UpdateScrollListLH(control, data, rowType)
  Crafty.DB("Crafty: UpdateScrollListLH "..table.getn(data))

  local dataCopyLH = ZO_DeepTableCopy(data)
  local dataListLH  = ZO_ScrollList_GetDataList(control)

  ZO_ScrollList_Clear(control)

  for key, value in ipairs(dataCopyLH) do
    local entry = ZO_ScrollList_CreateDataEntry(rowType, value)
    table.insert(dataListLH, entry)
  end

  ZO_ScrollList_Commit(control)
end

-- fills the xml rows with the data from the scrolllists
function Crafty.LayoutRow(rowControl, data, scrollList)
  Crafty.DB("Crafty: LayoutRow")

  rowControl.data = data
  rowControl.icon = GetControl(rowControl, "Icon")
  rowControl.name = GetControl(rowControl, "Name")
  rowControl.amount = GetControl(rowControl, "Amount")

  rowControl.icon:SetTexture(GetItemLinkIcon(data.link))

  local myAlarm = Crafty.ReturnAlarm(data.name)
  if myAlarm then
    rowControl.name:SetText(string.format("|cff4040%s|r |cffe926%s|r", data.link, "*"))
  else
    rowControl.name:SetText(data.link)
  end

  local myThreshold = Crafty.ReturnThreshold(data.name)
  if myThreshold ~= nil then
    --Crafty.DB("Crafty: myThreshold="..data.name.." is "..myThreshold.."")
    if data.amount < myThreshold then 
      rowControl.amount:SetText(string.format("|cff4040%s|r", data.amount))
    else
      rowControl.amount:SetText(string.format("|cb7ffa1%s|r", data.amount))
    end
  else
    rowControl.amount:SetText(data.amount)
  end

  rowControl.name:SetHidden(false)
  rowControl.name:SetWidth(175)

  -- change appearance for minMode
  if scrollList == CraftyWatchListList then
    if Crafty.activewatchListID == 1 and Crafty.minModeWL1 then rowControl.name:SetHidden(true) rowControl.name:SetWidth(1) end
    if Crafty.activewatchListID == 2 and Crafty.minModeWL2 then rowControl.name:SetHidden(true) rowControl.name:SetWidth(1) end
    if Crafty.activewatchListID == 3 and Crafty.minModeWL3 then rowControl.name:SetHidden(true) rowControl.name:SetWidth(1) end
  end
  
end

function Crafty.LayoutRowLH(rowControl, data, scrollList)
  Crafty.DB("Crafty: LayoutRowLH")

  rowControl.data = data
  rowControl.time = GetControl(rowControl, "Time")
  rowControl.icon = GetControl(rowControl, "Icon")
  rowControl.name = GetControl(rowControl, "Name")
  rowControl.amount = GetControl(rowControl, "Amount")
  rowControl.stockamount = GetControl(rowControl, "StockAmount")

  rowControl.time:SetText(data.time)
  rowControl.icon:SetTexture(GetItemLinkIcon(data.link))
  rowControl.name:SetText(data.link)
  rowControl.amount:SetText(data.amount)
  rowControl.stockamount:SetText(data.stockamount)

  rowControl.name:SetHidden(false)
  --rowControl.name:SetWidth(175)
end

----------------------------------------------------------------------------------------
-- Listdatahandling dataupdates
----------------------------------------------------------------------------------------

-- eventmanager target for several inventory change events
function Crafty.InvChange(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, updateReason, stackCountChange)
  local link = GetItemLink(bagId, slotIndex)
  Crafty.DB("Crafty: InvChange - "..link.." *"..stackCountChange)

  if stackCountChange >0 then
    Crafty.AddItemToHistory(link,stackCountChange)

    if Crafty.ReturnAlarm(GetItemLinkName(link)) and Crafty.alarmToggle then
      Crafty.ExecuteLootAlarm(link,stackCountChange)
    end
  end

  Crafty.Refresh()
end

-- refreshs the listdata
function Crafty.Refresh()
  Crafty.DB("Crafty: Refresh")

  local typeIdSL = 1
  local stockSL = Crafty.PopulateSL()
  Crafty.UpdateScrollListSL(CraftyStockListList, stockSL, typeIdSL)

  local typeIdWL = 2
  local stockWL = Crafty.PopulateWL()
  Crafty.UpdateScrollListWL(CraftyWatchListList, stockWL, typeIdWL)

  local typeIdLH = 3
  local stockLH = Crafty.PopulateLH()
  Crafty.UpdateScrollListLH(CraftyStockListHistoryList, stockLH, typeIdLH)
end

-- refreshs the listdata and removes the savedvar for the undoitem (from xml)
function Crafty.FullRefresh()
  Crafty.DB("Crafty: FullRefresh")

  Crafty.undoRemove = nil
  Crafty.CheckUndo()

  local typeIdSL = 1
  local stockSL = Crafty.PopulateSL()
  Crafty.UpdateScrollListSL(CraftyStockListList, stockSL, typeIdSL)

  local typeIdWL = 2
  local stockWL = Crafty.PopulateWL()
  Crafty.UpdateScrollListWL(CraftyWatchListList, stockWL, typeIdWL)

  local typeIdLH = 3
  local stockLH = Crafty.PopulateLH()
  Crafty.UpdateScrollListLH(CraftyStockListHistoryList, stockLH, typeIdLH)
end

-- refreshs the watchlist amountdata
function Crafty.RefreshWLAmounts()
  Crafty.DB("Crafty: RefreshWLAmounts")
  local stocklist = Crafty.PopulateCompleteStock()
  local watchlist = Crafty.activewatchList
  for i=1,table.getn(watchlist) do
    local name = watchlist[i].name
    local stockamount = Crafty.ReturnStockListItemAmount(name,stocklist)
    --Crafty.DB(name)
    --Crafty.DB(stockamount)
    watchlist[i].amount = stockamount
    -- this amount can be 0 and will be set to 0
    -- at this point future actions can react to 0 amounts in watchlist
  end
end

----------------------------------------------------------------------------------------
-- Functions to call from events, xml (buttons) or settings
----------------------------------------------------------------------------------------

-- close or hide the watchlist
function Crafty.ToogleWL()
  if Crafty.showWL then
    Crafty.showWL = false
    Crafty.savedVariables.ShowWL = false
    Crafty.CloseWL()
  else
    Crafty.showWL = true
    Crafty.savedVariables.ShowWL = true
    Crafty.OpenWL()
  end
end

-- open interface on vendor if set (called from eventmanager)
function Crafty.EventCheckVendorOpen()
  Crafty.DB("Crafty: EventCheckVendorOpen")
  Crafty.DB(Crafty.vendorwatchListID)
  if Crafty.vendorOpen then -- open vendorwatchlist if setting is on / else do nothing
    Crafty.oldactivewatchListID = Crafty.activewatchListID
    Crafty.oldshowWL = Crafty.showWL
    Crafty.oldshowLH = Crafty.showLH
    Crafty.SetActiveWatchList(Crafty.vendorwatchListID)
    CraftyStockListHistory:SetHidden(true)
  end
  Crafty.vendorIsOpen = true

end

-- close interface on vendor if set (called from eventmanager)
function Crafty.EventCheckVendorClose()
  Crafty.DB("Crafty: EventCheckVendorClose")
  --d(Crafty.oldshowWL)
  if Crafty.vendorOpen then -- only do something if vendorOpen setting is on
    if Crafty.vendorClose then -- close watchlist is on
      Crafty.SetActiveWatchList(Crafty.oldactivewatchListID) -- set active watchlist to previous in case user opens watchlist later
      Crafty.CloseWL()
    else -- close watchlist is off -> switch to previous watchlist but only if the previous was shown
      if Crafty.oldshowWL then
        Crafty.CloseSL()
        Crafty.SetActiveWatchList(Crafty.oldactivewatchListID)
      else -- close the watchlist cause the switch was not performed
        Crafty.SetActiveWatchList(Crafty.oldactivewatchListID)
        Crafty.CloseWL()
      end
    end
    if Crafty.oldshowLH then
      CraftyStockListHistory:SetHidden(false)
    end
  end
  Crafty.vendorIsOpen = false

end

-- Disable Setting "Close after guildvendor" if vendorOpen == false
function Crafty.CheckVendorClose()
  Crafty.DB("Crafty: CheckVendorClose")
  --Crafty.DB(Crafty.vendorClose)
  if not Crafty.vendorOpen then
    Crafty.vendorClose = false
    Crafty.SavevendorClose()
    return false
  end
  return Crafty.vendorClose
end

-- Save setting "Open on guildvendor"
function Crafty.SavevendorOpen()
  Crafty.DB("Crafty: SavevendorOpen")
  --Crafty.DB(Crafty.vendorOpen)
  Crafty.savedVariables.VendorOpen = Crafty.vendorOpen
end

-- Save setting "Close after guildvendor"
function Crafty.SavevendorClose()
  Crafty.DB("Crafty: SavevendorClose")
  Crafty.savedVariables.VendorClose = Crafty.vendorClose
end

-- Save setting "Guildvendor watchlist"
function Crafty.SavevendorwatchListID()
  Crafty.DB("Crafty: SavevendorwatchListID")
  Crafty.savedVariables.VendorwatchListID = Crafty.vendorwatchListID
end

-- Save setting "Different watchlist positions"
function Crafty.SavedifferentWLPositions()
  Crafty.DB("Crafty: savedifferentWLPositions")
  Crafty.savedVariables.DifferentWLPositions = Crafty.differentWLPositions
end

-- Save setting "Accountwide settings"
function Crafty.SaveaccountWide()
  Crafty.DB("Crafty: SaveaccountWide")
  Crafty.savedVariablesACC.AccountWide = Crafty.accountWide
  --ReloadUI("ingame")
end

-- Save setting "Enable tooltip"
function Crafty.SavetoolTip()
  Crafty.DB("Crafty: SavetoolTip")
  Crafty.savedVariables.ToolTip = Crafty.toolTip
  --ReloadUI("ingame")
end

-- Save setting "Enable ui tooltip"
function Crafty.SaveUIToolTip()
  Crafty.DB("Crafty: SaveUIToolTip")
  Crafty.savedVariables.ShowUIToolTip = Crafty.showUIToolTip
  --ReloadUI("ingame")
end

-- Save setting "Disable vendor itemsearch"
function Crafty.SaveDisableVendorItemsearch()
  Crafty.DB("Crafty: SaveDisableVendorItemsearch")
  Crafty.savedVariables.DisableVendorItemsearch = Crafty.disableVendorItemsearch
  --ReloadUI("ingame")
end

-- Save setting "Show Watchlist"
function Crafty.SaveShowwatchlist()
  Crafty.DB("Crafty: SaveShowwatchlist")
  Crafty.savedVariables.ShowWL = Crafty.showWL
  if Crafty.showWL then
    Crafty.OpenWL()
  else
    Crafty.CloseWL()
  end
end

-- save duration for alarmwindow (from settings)
function Crafty.SaveDurationAlarm()
  Crafty.DB("Crafty: SaveDurationAlarm")
  Crafty.DB(Crafty.durationAlarm)
  Crafty.savedVariables.DurationAlarm = Crafty.durationAlarm
end

-- save duration for lootwindow (from settings)
function Crafty.SaveDurationLoot()
  Crafty.DB("Crafty: SaveDurationLoot")
  Crafty.DB(Crafty.durationLoot)
  Crafty.savedVariables.DurationLoot = Crafty.durationLoot
end

-- Sort WL Initial (set texture)
function Crafty.SortWLTexture()
  Crafty.DB("Crafty: SortWLTexture")
  if Crafty.sortWL == "Name" then
    if Crafty.sortWLName == "up" then
      CraftyWatchListSortName:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_sortup.dds")
    else
      CraftyWatchListSortName:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_sortdown.dds")
    end
  else
    if Crafty.sortWLAmount == "up" then
      CraftyWatchListSortAmount:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_sortup.dds")
    else
      CraftyWatchListSortAmount:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_sortdown.dds")
    end
  end
end

-- Sort WL Name
function Crafty.SortWLName()
  Crafty.DB("Crafty: SortWLName")
  Crafty.sortWL = "Name"
  Crafty.sortWLAmount = "down"
  CraftyWatchListSortAmount:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_neutral.dds")
  if Crafty.sortWLName == "up" then
    Crafty.sortWLName = "down"
    CraftyWatchListSortName:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_sortdown.dds")
  else
    Crafty.sortWLName = "up"
    CraftyWatchListSortName:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_sortup.dds")
  end
  Crafty.savedVariables.SortWL = Crafty.sortWL
  Crafty.savedVariables.SortWLName = Crafty.sortWLName
  Crafty.savedVariables.SortWLAmount = Crafty.sortWLAmount
  Crafty.Refresh()
end

-- Sort WL Amount
function Crafty.SortWLAmount()
  Crafty.DB("Crafty: SortWLAmount")
  Crafty.sortWL = "Amount"
  Crafty.sortWLName = "down"
  CraftyWatchListSortName:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_neutral.dds")
  if Crafty.sortWLAmount == "up" then
    Crafty.sortWLAmount = "down"
    CraftyWatchListSortAmount:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_sortdown.dds")
  else
    Crafty.sortWLAmount = "up"
    CraftyWatchListSortAmount:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_sortup.dds")
  end
  Crafty.savedVariables.SortWL = Crafty.sortWL
  Crafty.savedVariables.SortWLAmount = Crafty.sortWLAmount
  Crafty.savedVariables.SortWLName = Crafty.sortWLName
  Crafty.Refresh()
end

-- Sort SL Initial (set texture)
function Crafty.SortSLTexture()
  Crafty.DB("Crafty: SortSLTexture")
  if Crafty.sortSL == "Name" then
    if Crafty.sortSLName == "up" then
      CraftyStockListSortName:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_sortup.dds")
    else
      CraftyStockListSortName:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_sortdown.dds")
    end
  else
    if Crafty.sortSLAmount == "up" then
      CraftyStockListSortAmount:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_sortup.dds")
    else
      CraftyStockListSortAmount:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_sortdown.dds")
    end
  end
end

-- Sort SL Name
function Crafty.SortSLName()
  Crafty.DB("Crafty: SortSLName")
  Crafty.sortSL = "Name"
  Crafty.sortSLAmount = "down"
  CraftyStockListSortAmount:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_neutral.dds")
  if Crafty.sortSLName == "up" then
    Crafty.sortSLName = "down"
    CraftyStockListSortName:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_sortdown.dds")
  else
    Crafty.sortSLName = "up"
    CraftyStockListSortName:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_sortup.dds")
  end
  Crafty.savedVariables.SortSL = Crafty.sortSL
  Crafty.savedVariables.SortSLName = Crafty.sortSLName
  Crafty.savedVariables.SortSLAmount = Crafty.sortSLAmount
  Crafty.Refresh()
end

-- Sort SL Amount
function Crafty.SortSLAmount()
  Crafty.DB("Crafty: SortSLAmount")
  Crafty.sortSL = "Amount"
  Crafty.sortSLName = "down"
  CraftyStockListSortName:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_neutral.dds")
  if Crafty.sortSLAmount == "up" then
    Crafty.sortSLAmount = "down"
    CraftyStockListSortAmount:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_sortdown.dds")
  else
    Crafty.sortSLAmount = "up"
    CraftyStockListSortAmount:SetNormalTexture("esoui/art/miscellaneous/list_sortheader_icon_sortup.dds")
  end
  Crafty.savedVariables.SortSL = Crafty.sortSL
  Crafty.savedVariables.SortSLAmount = Crafty.sortSLAmount
  Crafty.savedVariables.SortSLName = Crafty.sortSLName
  Crafty.Refresh()
end

-- show or hide stocklist (from xml)
function Crafty.ToggleSL()
  Crafty.DB("Crafty: ToggleSL")
  if Crafty.showSL then
    Crafty.CloseSL()
  else
    Crafty.OpenSL()
  end
end

-- show or hide watchlist (from keybinding)
function Crafty.ToggleWL()
  Crafty.DB("Crafty: ToggleWL")
  if Crafty.showWL then
    Crafty.CloseWL()
  else
    Crafty.OpenWL()
  end
end

-- show or hide loothistory (from keybinding)
function Crafty.ToggleLH()
  Crafty.DB("Crafty: ToggleLH")
  if Crafty.showLH then
    Crafty.CloseLH()
  else
    Crafty.OpenLH()
  end
end

-- show or hide stocklist (from keybinding)
function Crafty.ToggleSL()
  Crafty.DB("Crafty: ToggleSL")
  if Crafty.showSL then
    Crafty.CloseSL()
  else
    Crafty.OpenSL()
  end
end

-- anker the stocklist to watchlist
function Crafty.AnkerSL()
  Crafty.DB("Crafty: AnkerSL")
  CraftyStockList:ClearAnchors()
  CraftyStockList:SetAnchor(TOPRIGHT, CraftyWatchList, TOPLEFT, -15 ,0)

  -- Close Stocklist if there is no watchlist open
  if Crafty.showWL == false then
    Crafty.CloseSL()
  end
end

-- set anker on or off, also sets the texture
function Crafty.ToggleAnkerSL()
  Crafty.DB("Crafty: ToggleAnkerSL")
  if Crafty.ankerSL then
    Crafty.ankerSL = false
    Crafty.savedVariables.AnkerSL = false

    CraftyStockListButtonToggleAnkerSL:SetNormalTexture("esoui/art/miscellaneous/unlocked_up.dds")
    CraftyStockListButtonToggleAnkerSL:SetMouseOverTexture("esoui/art/miscellaneous/unlocked_over.dds")

  else
    Crafty.ankerSL = true
    Crafty.savedVariables.AnkerSL = true

    CraftyStockListButtonToggleAnkerSL:SetNormalTexture("esoui/art/miscellaneous/locked_up.dds")
    CraftyStockListButtonToggleAnkerSL:SetMouseOverTexture("esoui/art/miscellaneous/locked_over.dds")

    Crafty.AnkerSL()
  end
end

---- show or hide the typewindow (depricated)
--function Crafty.ToggleTS()
--  Crafty.DB("Crafty: ToggleTS")
--  if Crafty.showTS then
--    Crafty.CloseTS()
--  else
--    Crafty.OpenTS()
--  end
--end

-- hide the typewindow
function Crafty.CloseTS()
  Crafty.DB("Crafty: CloseTS")
  CraftyStockListType:SetHidden(true)
  Crafty.showTS = false
end

-- show the typewindow
function Crafty.OpenTS()
  Crafty.DB("Crafty: OpenTS")
  CraftyStockListType:SetHidden(false)
  Crafty.showTS = true
end

-- close the stocklist and typewindow
function Crafty.CloseSL()
  if Crafty.ankerSL then -- close SL only if its anchored
    Crafty.DB("Crafty: CloseSL")
    CraftyStockList:SetHidden(true)
    Crafty.showSL = false
    Crafty.savedVariables.ShowSL = false
    Crafty.CloseTS()
    Crafty.CloseTH()
  end
end

-- show the stocklist and typewindow
function Crafty.OpenSL()
  Crafty.DB("Crafty: OpenSL")
  CraftyStockList:SetHidden(false)
  Crafty.showSL = true
  Crafty.savedVariables.ShowSL = true
  Crafty.OpenTS()
end

-- close the watchlist, stocklist and typewindow
function Crafty.CloseWL()
  Crafty.DB("Crafty: CloseWL")
  CraftyWatchList:SetHidden(true)
  Crafty.showWL = false
  Crafty.savedVariables.ShowWL = false

  -- Only close Stocklist if its locked to watchlist
  if Crafty.ankerSL then
    CraftyStockList:SetHidden(true)
    Crafty.showSL = false
    Crafty.savedVariables.ShowSL = false
    Crafty.CloseSL()
    Crafty.CloseTS()
  end

  Crafty.undoRemove = nil
  Crafty.CheckUndo()
  Crafty.CloseTH()
end

-- open the watchlist
function Crafty.OpenWL()
  Crafty.DB("Crafty: OpenWL")
  CraftyWatchList:SetHidden(false)
  Crafty.showWL = true
  Crafty.savedVariables.ShowWL = true
  Crafty.showSL = false
  Crafty.savedVariables.ShowSL = false 
end

-- close loothistory
function Crafty.CloseLH()
  Crafty.DB("Crafty: CloseLH")
  CraftyStockListHistory:SetHidden(true)
  Crafty.showLH = false
  Crafty.savedVariables.ShowLH = false
end

-- open loothistory
function Crafty.OpenLH()
  Crafty.DB("Crafty: OpenLH")
  CraftyStockListHistory:SetHidden(false)
  Crafty.showLH = true
  Crafty.savedVariables.ShowLH = true 
end

function Crafty.OpenTH(control)
  Crafty.DB("Crafty: OpenTH")

  Crafty.thresholdItem = control
  local parent = control:GetParent():GetParent():GetParent()
  local itemLink = control.data.link
  local itemName = control.data.name
  local myAmount = Crafty.ReturnThreshold(itemName)
  local myAlarm = Crafty.ReturnAlarm(itemName)

  CraftyStockListThresholdItemLink:SetText(itemLink)
  CraftyStockListThresholdThresholdAmountThresholdAmountText:SetText(myAmount)

  if myAlarm then
    CraftyStockListThresholdAlarmSwitch:SetText("ON")
  else
    CraftyStockListThresholdAlarmSwitch:SetText(string.format("|cadadad%s|r", "OFF"))
  end

  CraftyStockListThreshold:SetAnchor(BOTTOMLEFT, parent, TOPLEFT, 0, -50)
  CraftyStockListThreshold:SetHidden(false)
end

function Crafty.CloseTH()
  Crafty.DB("Crafty: CloseTH")
  CraftyStockListThreshold:SetHidden(true)
end


-- for future use build a style table (tooltip)
function Crafty.BuildStyleTable()
  Crafty.DB("Crafty: BuildStyleTable")
  for i=1,  GetNumValidItemStyles() do
    Crafty.myStyles[i] = GetItemStyleName(i)
  end
end

-- return name of style from id
function Crafty.ReturnStyle(arg)
  --Crafty.DB("Crafty: ReturnStyle")  
  return Crafty.myStyles[arg]
end

-- return the windowposition left
function Crafty.ReturnXLPosition(control)
--Crafty.DB("Crafty: ReturnXLPosition")
  local myXLPos
  myXLPos = control:GetLeft()
  return myXLPos
end

-- return the windowposition right
function Crafty.ReturnXRPosition(control)
--Crafty.DB("Crafty: ReturnXRPosition")
  local myXRPos
  myXRPos = control:GetRight()
  return myXRPos
end

-- return true/false of minmode for active watchlist
function Crafty.ReturnMinMode()
--Crafty.DB("Crafty: ReturnMinMode")
  local wl = Crafty.activewatchListID
  if wl == 1 then return Crafty.minModeWL1 end
  if wl == 2 then return Crafty.minModeWL2 end
  if wl == 3 then return Crafty.minModeWL3 end
end

-- show ToolTip
function Crafty.ShowTooltip(control)
  Crafty.DB("Crafty: ShowTooltip")

  CraftyStockListTooltip:SetHidden(false) -- position at end of function?
  CraftyStockListTooltip:ClearAnchors()
  CraftyStockListTooltipThresholdIcon:SetHidden(false)
  local controlTopLevel = control:GetParent():GetParent():GetParent()
  local myXLPos = Crafty.ReturnXLPosition(controlTopLevel)
  local myXRPos = Crafty.ReturnXRPosition(controlTopLevel)
  local myLeftCol = false
  local myRightCol = false
  if myXLPos < 340 then myLeftCol = true end
  local myXRightPos = GuiRoot:GetRight()
  if myXRPos > myXRightPos - 350 then myRightCol = true end

  -- position the tooltip
  local controlName = control:GetParent():GetName()   
  if controlName == "CraftyWatchListListContents" then
    if Crafty.showSL then -- stocklist is open
      if Crafty.ankerSL then -- stocklist is open and docked!
        if myRightCol then
          CraftyStockListTooltip:SetAnchor(RIGHT, control, LEFT, -340, 0)
        else
          CraftyStockListTooltip:SetAnchor(LEFT, control, RIGHT, 35, 0)
        end
      else -- not docked
        if myLeftCol then
          CraftyStockListTooltip:SetAnchor(LEFT, control, RIGHT, 35, 0)
        else
          CraftyStockListTooltip:SetAnchor(RIGHT, control, LEFT, -25, 0)
        end
      end
    else -- stocklist not open
      if myLeftCol then
        CraftyStockListTooltip:SetAnchor(LEFT, control, RIGHT, 35, 0)
      else
        CraftyStockListTooltip:SetAnchor(RIGHT, control, LEFT, -25, 0)
      end
    end
  end

  if controlName == "CraftyStockListListContents" then
    if myLeftCol then
      if Crafty.ankerSL then
        if Crafty.ReturnMinMode() then
          CraftyStockListTooltip:SetAnchor(LEFT, control, RIGHT, CraftyWatchList:GetLeft()-CraftyStockList:GetLeft()-150, 0)
        else
          CraftyStockListTooltip:SetAnchor(LEFT, control, RIGHT, CraftyWatchList:GetLeft()-CraftyStockList:GetLeft()+35, 0)
        end
      else
        CraftyStockListTooltip:SetAnchor(LEFT, control, RIGHT, 35, 0)
      end
    else
      CraftyStockListTooltip:SetAnchor(RIGHT, control, LEFT, -25, 0)
    end
  end

  if controlName == "CraftyStockListHistoryListContents" then
    if myLeftCol then
      CraftyStockListTooltip:SetAnchor(LEFT, control, RIGHT, 35, 0)
    else
      CraftyStockListTooltip:SetAnchor(RIGHT, control, LEFT, -20, 0)
    end
  end

  -- display threshold for the item
  local myThreshold = Crafty.ReturnThreshold(control.data.name)
  if myThreshold == nil then
    myThreshold = ""
    CraftyStockListTooltipThresholdIcon:SetHidden(true)
  end

  local myAlarm= Crafty.ReturnAlarm(control.data.name)
  CraftyStockListTooltipAlarmIcon:SetHidden(true)
  if myAlarm then
    CraftyStockListTooltipAlarmIcon:SetAnchor(TOPRIGHT, CraftyStockListTooltipThresholdIcon, TOPLEFT, 0, 0  )
    CraftyStockListTooltipAlarmIcon:SetHidden(false)
    if myThreshold == "" then
      CraftyStockListTooltipAlarmIcon:SetAnchor(TOPRIGHT, CraftyStockListTooltip, TOPRIGHT, -10, 5  )
    end
  end

  local myHeight = 130
  local itemIcon
  local itemLink
  local traitText
  local traitType
  local traitTypeText =""
  local traitTypeDesc
  local itemType
  local itemTypeSpec
  local itemTypeSpecText
  local itemFlavor
  local itemStyle
  local itemCraftingType
  local traitTypeTextHeight = 0
  local itemFlavorTextHeight = 0
  local icon,sellPrice,meetsUsageRequirement,equipType,itemStyleId = GetItemLinkInfo(control.data.link)

  itemIcon = GetItemLinkIcon(control.data.link)
  itemLink = control.data.link
  itemStyle = Crafty.ReturnStyle(itemStyleId)
  itemCraftingType = GetItemLinkCraftingSkillType(itemLink)

  if GetItemLinkTraitType(control.data.link) ~= 0 then
    traitType, traitTypeDesc =  GetItemLinkTraitInfo(control.data.link)
    traitTypeText = string.format("|cFFFFFF%s|r", GetString("SI_ITEMTRAITTYPE", traitType)).."\n("..traitTypeDesc..")\n"
  end
  itemType, itemTypeSpec = GetItemLinkItemType(control.data.link)
  itemTypeSpecText = GetString("SI_SPECIALIZEDITEMTYPE", itemTypeSpec)
  itemFlavor = GetItemLinkFlavorText(control.data.link)

  if itemTypeSpecText == "Style Material" then -- its a style material
    if itemStyle ~= nil then
      itemFlavor = "An ingredient for crafting in the "..string.format("|cFFFFFF%s|r", itemStyle).." style." 
    end
  end

  if itemCraftingType == 3 then -- its a rune (enchanting)
    itemFlavor = ""
  end
    if       itemCraftingType == 0 then CraftyStockListTooltipItemProf:SetTexture("esoui/art/inventory/inventory_tabicon_crafting_up.dds")
      elseif itemCraftingType == 1 then CraftyStockListTooltipItemProf:SetTexture("esoui/art/inventory/inventory_tabicon_craftbag_blacksmithing_up.dds")
      elseif itemCraftingType == 2 then CraftyStockListTooltipItemProf:SetTexture("esoui/art/inventory/inventory_tabicon_craftbag_clothing_up.dds")
      elseif itemCraftingType == 3 then CraftyStockListTooltipItemProf:SetTexture("esoui/art/inventory/inventory_tabicon_craftbag_enchanting_up.dds")
      elseif itemCraftingType == 4 then CraftyStockListTooltipItemProf:SetTexture("esoui/art/inventory/inventory_tabicon_craftbag_alchemy_up.dds")
      elseif itemCraftingType == 5 then CraftyStockListTooltipItemProf:SetTexture("esoui/art/inventory/inventory_tabicon_craftbag_provisioning_up.dds")
      elseif itemCraftingType == 6 then CraftyStockListTooltipItemProf:SetTexture("esoui/art/inventory/inventory_tabicon_craftbag_woodworking_up.dds")
      elseif itemCraftingType == 7 then CraftyStockListTooltipItemProf:SetTexture("esoui/art/inventory/inventory_tabicon_craftbag_jewelrycrafting_up.dds")
      else
  end

  if itemTypeSpecText == "Style Material" then
    CraftyStockListTooltipItemProf:SetTexture("esoui/art/inventory/inventory_tabicon_craftbag_stylematerial_up.dds")
  end
  if itemTypeSpecText == "Armor Trait" or itemTypeSpecText == "Weapon Trait" or itemTypeSpecText == "Jewelry Trait" then
    CraftyStockListTooltipItemProf:SetTexture("esoui/art/inventory/inventory_tabicon_craftbag_itemtrait_up.dds")
  end
  if itemTypeSpecText == "Lure" then
    CraftyStockListTooltipItemProf:SetTexture("esoui/art/inventory/inventory_tabicon_craftbag_fishing_up.dds")
  end
  if itemTypeSpecText == "Furnishing Material" then
    CraftyStockListTooltipItemProf:SetTexture("EsoUI/Art/Inventory/inventory_tabIcon_furnishing_material_up.dds")
  end
  if itemTypeSpecText == "Raw Material" or itemTypeSpecText == "Raw Trait" then
    CraftyStockListTooltipItemProf:SetTexture("EsoUI/Art/TradingHouse/Tradinghouse_Materials_Style_RawMats_up.dds")
  end

  CraftyStockListTooltipItemThreshold:SetText(myThreshold)

  CraftyStockListTooltipItemIcon:SetTexture(itemIcon)
  CraftyStockListTooltipItemLink:SetText(itemLink)
  CraftyStockListTooltipItemType:SetText(itemTypeSpecText)
  CraftyStockListTooltipTraitTypeText:SetText(traitTypeText)
  CraftyStockListTooltipItemFlavor:SetText(itemFlavor)

  traitTypeTextHeight = CraftyStockListTooltipTraitTypeText:GetTextHeight()
  itemFlavorTextHeight = CraftyStockListTooltipItemFlavor:GetTextHeight()
  CraftyStockListTooltip:SetHeight(myHeight+traitTypeTextHeight+itemFlavorTextHeight)
end

-- hide Tooltip
function Crafty.HideTooltip(control)
  --Crafty.DB("Crafty: OnMouseExitWL")
  CraftyStockListTooltip:SetHidden(true)
end

----------------------------------------------------------------------------------------
-- Functions for modifying the listdata (add items, remove, undo)
----------------------------------------------------------------------------------------

-- adds an item to the watchlist, function for calling from xml (stocklist)
function Crafty.OnMouseUpSL(control, button, upInside)
  Crafty.DB("Crafty: OnMouseUpSL")
  if button == 1 then
    if Crafty.vendorIsOpen then
      Crafty.DB("Crafty: SearchForItemLink in Vendor")
      TRADING_HOUSE:SearchForItemLink(control.data.link)
    else
      Crafty.AddItemToWatchList(control)
    end
  else
    Crafty.OpenTH(control)
  end
end

-- removes an item from the watchlist, function for calling from xml (watchlist) / or insert item into guildvendorsearch if vendor is open
function Crafty.OnMouseUpWL(control, button, upInside)
  Crafty.DB("Crafty: OnMouseUpWL")
  if button == 1 then
    if Crafty.vendorIsOpen then
      if Crafty.disableVendorItemsearch then
        Crafty.RemoveItemFromWatchList(control)
      else
        Crafty.DB("Crafty: SearchForItemLink in Vendor")
        TRADING_HOUSE:SearchForItemLink(control.data.link)
      end
    else
      Crafty.RemoveItemFromWatchList(control)
    end
  else
    Crafty.OpenTH(control)
  end
end

-- depricated
function Crafty.InsertItemToVendorSearch(control)
  Crafty.DB("Crafty: AddItemToVendorSearch")
  local MakeExactSearchText = ZO_TradingHouseNameSearchFeature_Shared.MakeExactSearchText
  local vendorControl = Crafty.IdentifyVendorSearch()
  local text = MakeExactSearchText(zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(control)))
  vendorControl:SetText(text.."\n")
  TRADING_HOUSE_SEARCH:DoSearch()
  --Crafty.DB(vendorControl)
end

-- depricated
-- what control is the vendor search field
function Crafty.IdentifyVendorSearch()
  Crafty.DB("Crafty: identifyVendorSearch")
  local vendorControl = WINDOW_MANAGER:GetControlByName("ZO_TradingHouseItemNameSearchBox")
  return vendorControl
end

-- adds an item to the watchlist, only if its not there, undoitem removed, updated icons on interface
function Crafty.AddItemToWatchList(control)
  Crafty.DB("Crafty: AddItemToWatchList")
  local name = control.data.name
  local watchList = Crafty.activewatchList
  local size = table.getn(watchList)

  local found = Crafty.CheckItemInWatchList(control.data.name)

  if not found then
    watchList[size+1] = {
        link = control.data.link,
        name = control.data.name,
        amount = control.data.amount,
        cinfo = control.data.cinfo
      }
      Crafty.undoRemove = nil
      Crafty.CheckUndo()
  end
    
  Crafty.DB("Crafty: Added "..name.." at #"..table.getn(watchList))
  --Crafty.DBPrintWatchList()
  Crafty.Refresh()
end

-- removes an item from the watchlist
function Crafty.RemoveItemFromWatchList(control)
  Crafty.DB("Crafty: RemoveItemFromWatchList")
  local name=control.data.name
  local watchList = Crafty.activewatchList
  for i=1,table.getn(watchList) do
    if watchList[i].name == name then
      Crafty.DB("Crafty: Removed "..name.." at #"..i)
      Crafty.undoRemove = (watchList[i])
      Crafty.CheckUndo()
      table.remove(watchList, i)
      break
    end
  end
  --Crafty.DBPrintWatchList()
  Crafty.Refresh()
end

-- add an item to the history
function Crafty.AddItemToHistory(mylink,stackCountChange)
  Crafty.DB("Crafty: AddItemToHistory - "..mylink.." *"..stackCountChange)

  Crafty.historyAmount = Crafty.historyAmount + stackCountChange

  local stocklist = Crafty.PopulateCompleteStock()
  local myName = GetItemLinkName(mylink)
  local stockAmount = Crafty.ReturnStockListItemAmount(myName,stocklist)

  local myTable = Crafty.lootHistory
  local mylootHistory = {}
  local myTime = ZO_FormatClockTime()

  mylootHistory[1] = 
  {
    link = mylink,
    amount = stackCountChange,
    stockamount = stockAmount,
    time = myTime
  }

  table.insert(myTable,1,mylootHistory[1])

  CraftyStockListHistoryHistoryAmount:SetText(Crafty.historyAmount)

  Crafty.savedVariables.LootHistory = myTable
  Crafty.savedVariables.HistoryAmount = Crafty.historyAmount

  if table.getn(myTable) >= 500 then
    Crafty.DB("Crafty: Dropped history table n >= 500")
    Crafty.ResetHistory()
  end

  Crafty.CheckHistoryEmpty()
  --Crafty.ReturnHistory()
end

-- Clear the History
function Crafty.ResetHistory()
  Crafty.DB("Crafty: ResetHistory")

  Crafty.lootHistory = {}
  Crafty.historyAmount = 0

  Crafty.savedVariables.LootHistory = Crafty.lootHistory
  Crafty.savedVariables.HistoryAmount = Crafty.historyAmount
  CraftyStockListHistoryHistoryAmount:SetText(Crafty.historyAmount)

  Crafty.CheckHistoryEmpty()
  Crafty.Refresh()
end

function Crafty.CheckHistoryEmpty()
  Crafty.DB("Crafty: HistoryEmpty")
  if Crafty.historyAmount == 0 then
    CraftyStockListHistoryEmptyLogo:SetHidden(false)
  else
    CraftyStockListHistoryEmptyLogo:SetHidden(true)
  end
end

-- return the history -- only for debugging
function Crafty.ReturnHistory()
  Crafty.DB("Crafty: ReturnHistory")
  local historyN = table.getn(Crafty.lootHistory)
  for i=1,historyN do
    local myLink = Crafty.lootHistory[i].link
    local myAmount = Crafty.lootHistory[i].amount
    local myTime = Crafty.lootHistory[i].time
    Crafty.DB(myTime.."-["..i.."]: "..myLink.." * "..myAmount)
  end
end

-- set alarm for item
function Crafty.SetAlarm()
  Crafty.DB("Crafty: SetAlarm")
  local myTable = Crafty.alarmTable
  local myItem = Crafty.thresholdItem 
  local myLink = myItem.data.link
  local myName = myItem.data.name
  local myAlarm = {}
  local myRemoved = false

  myAlarm[1] =
  {
    link = myLink,
    name = myName
  }

  if table.getn(myTable) ~= 0 then
    for i=1,table.getn(myTable) do
      if myTable[i].name == myName then
        table.remove(myTable, i)
        myRemoved = true
        break
      end
    end
  end
  if not myRemoved then
    table.insert(myTable,1,myAlarm[1])
  end

  Crafty.savedVariables.AlarmTable = Crafty.alarmTable
  Crafty.CloseTH()
  Crafty.Refresh()
  --Crafty.DebugAlarm()
end

-- Return if alarm is set for item (itemName)
function Crafty.ReturnAlarm(itemName)
  --Crafty.DB("Crafty: ReturnAlarm: "..itemName)
  local myTable = Crafty.alarmTable
  local myFound = false

  for i=1,table.getn(myTable) do
    if myTable[i].name == itemName then
      myFound = true
    end
  end
  return myFound
end

-- Perform the alarm for found item (itemLink)
function Crafty.ExecuteLootAlarm(itemLink, lootAmount)
  Crafty.DB("Crafty: ExecuteLootAlarm: "..itemLink)
  local itemIcon = GetItemLinkIcon(itemLink)
  local itemName = GetItemLinkName(itemLink)
  local myControl = WINDOW_MANAGER:GetControlByName("Alert"..itemLink, "")
  local alertBox
  local myLastControl
  local myLHHidden = CraftyStockListHistory:IsHidden()

  if myControl == nil then
    alertBox = WINDOW_MANAGER:CreateControlFromVirtual("Alert"..itemLink, GuiRoot, "CraftyStockListAlarm")
  else
    alertBox = myControl
  end

  alertBox:ClearAnchors()
  Crafty.LogAlarmControl(alertBox)
  myLastControl = Crafty.ReturnLastAlarmControl()

  if myLastControl ~= nil and myLastControl ~= alertBox then
    alertBox:SetAnchor(BOTTOMLEFT, myLastControl, TOPLEFT, 0,-45)
  else
    alertBox:SetAnchor(BOTTOMLEFT, CraftyStockListHistory, TOPLEFT, 0,-20)
  end
  alertBox:SetHidden(false)

  local AlertAnim, AlertTimeline = CreateSimpleAnimation(ANIMATION_ALPHA, alertBox)
  AlertAnim:SetAlphaValues(0, 1)
  AlertAnim:SetDuration(500)
  AlertTimeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)
  AlertTimeline:PlayFromStart()

  if myLHHidden then
    CraftyStockListHistory:SetHidden(false)

    local HistAnim, HistTimeline = CreateSimpleAnimation(ANIMATION_ALPHA, CraftyStockListHistory)
    HistAnim:SetAlphaValues(0, 1)
    HistAnim:SetDuration(500)
    HistTimeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)
    HistTimeline:PlayFromStart()
  end

  local myItemIcon = WINDOW_MANAGER:GetControlByName("Alert"..itemLink.."ItemIcon", "")
  local myItemLink = WINDOW_MANAGER:GetControlByName("Alert"..itemLink.."ItemLink", "")
  myItemIcon:SetTexture(itemIcon)
  myItemLink:SetText(lootAmount.." * "..itemLink)

  --Glow Animation
  local animControl = WINDOW_MANAGER:GetControlByName("Alert"..itemLink.."AlarmGlow1", "")
  local timeline = ANIMATION_MANAGER:CreateTimeline()

  local rotateright = timeline:InsertAnimation(ANIMATION_TEXTUREROTATE, animControl)
  rotateright:SetRotationValues(0, 360)
  rotateright:SetDuration(2000)
  local rotateleft = timeline:InsertAnimation(ANIMATION_TEXTUREROTATE, animControl, 2000)
  rotateleft:SetRotationValues(360, 0)
  rotateleft:SetDuration(2000)

  timeline:SetPlaybackType(ANIMATION_PLAYBACK_LOOP, LOOP_INDEFINITELY)
  timeline:PlayFromStart()

  zo_callLater(function () timeline:Stop() end, Crafty.durationAlarm+500)
  zo_callLater(function () Crafty.LootAlarmCloseAlertBox(alertBox) end, Crafty.durationAlarm)
  if myLHHidden then
    zo_callLater(function () Crafty.LootAlarmCloseHistory() end, Crafty.durationLoot)
  end
end

function Crafty.LootAlarmCloseAlertBox(control)
  local AlertAnim, AlertTimeline = CreateSimpleAnimation(ANIMATION_ALPHA, control)
  AlertAnim:SetAlphaValues(1, 0)
  AlertAnim:SetDuration(500)
  AlertTimeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)
  AlertTimeline:PlayFromStart()

  zo_callLater(function () control:SetHidden(true) end, 500)

end

function Crafty.LootAlarmCloseHistory()
  local HistAnim, HistTimeline = CreateSimpleAnimation(ANIMATION_ALPHA, CraftyStockListHistory)
    HistAnim:SetAlphaValues(1, 0)
    HistAnim:SetDuration(500)
    HistTimeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)
    HistTimeline:PlayFromStart()

    zo_callLater(function () CraftyStockListHistory:SetHidden(true) end, 500)
    zo_callLater(function () CraftyStockListHistory:SetAlpha(1) end, 1000)

end

function Crafty.LogAlarmControl(control)
  --Crafty.DB("Crafty: LogAlarmControl")
  local myTable = Crafty.alarmTrigger
  table.insert(myTable,control)
end

function Crafty.ReturnLastAlarmControl()
  --Crafty.DB("Crafty: ReturnLastAlarmControlTOPLEFT")
  local myTable = Crafty.alarmTrigger
  local myLastControl
  for i=1,table.getn(myTable) do
    if myTable[i]~=nil then
      if myTable[i]:IsHidden()==false then
        myLastControl = myTable[i]
      end
    end
  end
  if myLastControl ~= nil then Crafty.DB(myLastControl:GetName()) end
  return myLastControl
end

function Crafty.DebugAlarm()
  local myTable = Crafty.alarmTable
  local myItem = Crafty.thresholdItem
  local myName = myItem.data.name

  for i=1,table.getn(myTable) do
     Crafty.DB("Alarm["..i.."]:"..myTable[i].name)
  end

end

-- set thresholdamount for item
function Crafty.SetThreshold()

  local myAmount = CraftyStockListThresholdThresholdAmountThresholdAmountText:GetText()
  local myTable = Crafty.thresholdTable
  local myItem = Crafty.thresholdItem
  local myLink = myItem.data.link
  local myName = myItem.data.name
  local myThreshold = {}
  local newItem = true

  Crafty.DB("Crafty: SetThreshold Item:"..myName)

  myThreshold[1] = 
  {
    link = myLink,
    amount = myAmount,
    name = myName
  }

  if table.getn(myTable) ~= 0 then
    for i=1,table.getn(myTable) do
      if myTable[i].name == myName then
        table.remove(myTable, i)
        break
      end
    end
  end

  table.insert(myTable,1,myThreshold[1])

  Crafty.savedVariables.ThresholdTable = Crafty.thresholdTable
  --Crafty.DebugThreshold()
  Crafty.CloseTH()
  Crafty.Refresh()
end

-- return thresholdamount for item
function Crafty.ReturnThreshold(itemName)
  --Crafty.DB("Crafty: ReturnThreshold: "..itemName)
  local myTable = Crafty.thresholdTable

  for i=1,table.getn(myTable) do
    if myTable[i].name == itemName then
      --Crafty.DB(myTable[i].amount)
      return tonumber(myTable[i].amount)
    end
  end

end

-- delete thresholdamount for item
function Crafty.DeleteThreshold()
  Crafty.DB("Crafty: DeleteThreshold: "..Crafty.thresholdItem.data.name)

  local myTable = Crafty.thresholdTable
  local myItem = Crafty.thresholdItem
  local myName = myItem.data.name

  for i=1,table.getn(myTable) do
    if myTable[i].name == myName then
      table.remove(myTable, i)
      break
    end
  end

  Crafty.savedVariables.ThresholdTable = Crafty.thresholdTable
  --Crafty.DebugThreshold()
  Crafty.CloseTH()
  Crafty.Refresh()
end

function Crafty.DebugThreshold()
  local myTable = Crafty.thresholdTable
  local myItem = Crafty.thresholdItem
  local myName = myItem.data.name

  for i=1,table.getn(myTable) do
     Crafty.DB("Threshold["..i.."]:"..myTable[i].name..":"..myTable[i].amount)
  end

end

-- checks if there is an undoitem and sets the button in xml
function Crafty.CheckUndo()
  Crafty.DB("Crafty: CheckUndo")
  if Crafty.undoRemove ~= nil then
    CraftyWatchListButtonUndo:SetHidden(false)
  else
    CraftyWatchListButtonUndo:SetHidden(true)
  end
end

-- adds the item from the undovar, if its not allready there
function Crafty.UndoRemove()
  Crafty.DB("Crafty: UndoRemove")
  local found = Crafty.CheckItemInWatchList(Crafty.undoRemove.name)
  if Crafty.undoRemove ~= nil then
    if not found then
      table.insert(Crafty.activewatchList, Crafty.undoRemove)
    else
      return
    end
  end
  Crafty.undoRemove = nil
  Crafty.CheckUndo()
  Crafty.Refresh()
end

function Crafty.UndoTooltip(control)
  Crafty.DB("Crafty: UndoTooltip")

  if Crafty.undoRemove ~= nil then
    ZO_Tooltips_ShowTextTooltip(control, TOP, "Insert: "..Crafty.undoRemove.link)
  end
end

function Crafty.ThresholdTooltip(control)
  Crafty.DB("Crafty: ThresholdTooltip")

  local myAmount, myLootalarm, myThreshold, myBThreshold = Crafty.ReturnWLItemAmounts()
  ZO_Tooltips_ShowTextTooltip(control, TOP, "Threshold mode:\n"..myThreshold.." from "..myAmount.." items with threshold\n"..myBThreshold.." below threshold")

end


-- helper function to return number of items in active watchlist
-- return arg1 - number of items
-- return arg2 - number of items with lootalarm
-- return arg3 - number of items with threshold
-- return arg4 - number of items below threshold
function Crafty.ReturnWLItemAmounts()
  --Crafty.DB("Crafty: ReturnWLItemAmounts")
  local myAmount
  local myLootalarm = 0
  local myThreshold = 0
  local myBThreshold = 0
  local myWL = Crafty.activewatchList

  myAmount = table.getn(myWL)

  for i=1, myAmount do
    local myName = myWL[i].name
    if Crafty.ReturnAlarm(myName) then myLootalarm = myLootalarm+1 end
  end

  for i=1, myAmount do
    local myName = myWL[i].name
    if Crafty.ReturnThreshold(myName) ~= nil then myThreshold = myThreshold+1 end
  end

  for i=1, myAmount do
    local myName = myWL[i].name
    local myBagAmount = myWL[i].amount
    if Crafty.ReturnThreshold(myName) ~= nil then
      if myBagAmount < Crafty.ReturnThreshold(myName) then myBThreshold = myBThreshold+1 end
    end
  end

  Crafty.DB("Crafty: ReturnWLItemAmounts: N-"..myAmount.." LA-"..myLootalarm.." TH-"..myThreshold .." BTH-"..myBThreshold)

  return myAmount, myLootalarm, myThreshold, myBThreshold

end

-- helper function to check if an item is in the watchlist (the name!)
function Crafty.CheckItemInWatchList(control)
  Crafty.DB("Crafty: CheckItemInWatchList")
  local found = false
  local watchList = Crafty.activewatchList
  for i=1,table.getn(watchList) do
    if watchList[i].name == control then
      local found = true
      return found
    end
  end
  return found
end

-- helper function to return stocklist item amount
function Crafty.ReturnStockListItemAmount(itemname,stocklist)
  Crafty.DB("Crafty: ReturnStockListItemAmount")
  local amount = 0
  for i=1,table.getn(stocklist) do
    --Crafty.DB(stocklist[i].name)
    if stocklist[i].name == itemname then
      local amount = stocklist[i].amount
      --Crafty.DB(amount)
      return amount
    end
  end
  --Crafty.DB(amount)
  return amount
end

-- helper function to create a complete stocklist table
function Crafty.PopulateCompleteStock()
  Crafty.DB("Crafty: PopulateCompleteStock")
  local cstock = {}
  local stockcounter = 0

  for index, data in pairs(SHARED_INVENTORY.bagCache[BAG_VIRTUAL]) do
    if data ~= nil then
      stockcounter = stockcounter + 1
      cstock[stockcounter] = {
        link = GetItemLink(BAG_VIRTUAL,data.slotIndex),
        name = GetItemName(BAG_VIRTUAL,data.slotIndex),
        amount = GetSlotStackSize(BAG_VIRTUAL,data.slotIndex),
        cinfo = GetItemCraftingInfo(BAG_VIRTUAL,data.slotIndex)
      }
      --Crafty.DB(cstock[stockcounter].icon) --working
    end
  end
  return cstock
end

function Crafty.ShowUIToolTip(control,pos,text)
  Crafty.DB("Crafty: ShowUIToolTip")
  if Crafty.showUIToolTip then
    ZO_Tooltips_ShowTextTooltip(control, pos, text)
  end
end

----------------------------------------------------------------------------------------
-- Debugfunctions
----------------------------------------------------------------------------------------

-- show debug message
function Crafty.DB(message)
  if Crafty.db then
    d(message)
  end
end

-- for slashcommand
function Crafty.ToggleDB()
  if Crafty.db then
    d("Crafty: Debugmode off")
    Crafty.db = false
  else
    d("Crafty: Debugmode on")
    Crafty.db = true
  end
end

-- output complete watchlist1
function Crafty.DBPrintWatchList()
  local watchList = Crafty.watchList1
  if Crafty.db then
    Crafty.DB("Debug WatchList -------------------------")
    for i=1,table.getn(watchList) do
      Crafty.DB(watchList[i].link)
    end
  end
end

----------------------------------------------------------------------------------------
-- Events
----------------------------------------------------------------------------------------

EVENT_MANAGER:RegisterForEvent(Crafty.name, EVENT_ADD_ON_LOADED, Crafty.OnAddOnLoaded)

EVENT_MANAGER:RegisterForEvent(Crafty.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, Crafty.InvChange)
EVENT_MANAGER:AddFilterForEvent(Crafty.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_VIRTUAL)

EVENT_MANAGER:RegisterForEvent(Crafty.name, EVENT_OPEN_TRADING_HOUSE, Crafty.EventCheckVendorOpen)
EVENT_MANAGER:RegisterForEvent(Crafty.name, EVENT_CLOSE_TRADING_HOUSE, Crafty.EventCheckVendorClose)

--EVENT_MANAGER:RegisterForEvent(Crafty.name, EVENT_BUY_RECEIPT, Crafty.InvChange)
--EVENT_MANAGER:RegisterForEvent(Crafty.name, EVENT_LOOT_RECEIVED, Crafty.InvChange)
--EVENT_MANAGER:RegisterForEvent(Crafty.name, EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS , Crafty.InvChange)
--EVENT_MANAGER:RegisterForEvent(Crafty.name, EVENT_CRAFT_COMPLETED, Crafty.InvChange)


----------------------------------------------------------------------------------------
-- Slash Commands
----------------------------------------------------------------------------------------

SLASH_COMMANDS["/crafty"] = function()  Crafty.ToggleWL() end
SLASH_COMMANDS["/craftydb"] = function()  Crafty.ToggleDB() end
--SLASH_COMMANDS["/craftytest"] = function()  Crafty.ReturnStockListItemAmount("silver dust") end
