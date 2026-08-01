----------------------------------
--Group List Keyboard
----------------------------------
BotScan  = {
   name = "BotScanner",
   players = {},
   -- comboBox = ZO_Help_Ask_For_Help_Keyboard_ControlSubcategoryComboBox,

   SV = {},
   reported = {},

}


-- Creates a Filtered List object
local ScanList = ZO_SortFilterList:Subclass()

local SCANNER_DATA = 1

--Initialize a new FilteredList with a control that has $(parent)Headers and $(parent)List children
function ScanList:New(control)
   return  self:Initialize(control)
end

function ScanList:Initialize(control)
   --Control must have $(parent)List that inherits ZO_ScrollList
   self:InitializeSortFilterList(control)
   
   ZO_ScrollList_AddDataType(self.list, SCANNER_DATA, "BotScannerScanRow", 30, function(control, data) self:SetupScanRow(control, data) end)
   ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
   
   self:SetEmptyText("No Targets")
   self.emptyRow:ClearAnchors()
   self.emptyRow:SetAnchor(TOPLEFT, GetControl(control, "List"), TOPLEFT, 0,0)
   self.emptyRow:SetWidth(280)
   
   self.masterList = {}
   local sortKeys = {
      ["name"] = { caseInsensitive = true },
      ["index"] = {}
   }
   self.currentSortKey = "index"
   self.currentSortOrder = ZO_SORT_ORDER_UP
   self.sortFunction = function( listEntry1, listEntry2 )
      return(ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, sortKeys, self.currentSortOrder))
   end


   return self
end


function ScanList:UpdateRow(data)
   local control = data.control
   if not control then return end
   
   GetControl(control,"Number"):SetText("("..tostring(data.index)..")")
   GetControl(control, "Status"):SetHidden(not data.reported)
end

do
   local index = 1
   function ScanList:NewEntry(data)
      if not self.masterList[data.displayname] then
	 self.masterList[data.displayname] = data
	 data.index = index
	 index = index + 1
	 local scrollData = ZO_ScrollList_GetDataList(self.list)
	 table.insert(scrollData, ZO_ScrollList_CreateDataEntry(SCANNER_DATA, data))
	 self:RefreshFilters()
      end
      return data
   end

   function ScanList:ClearAll()
      index = 1
      self.masterList = {}
      self:RefreshData()
   end
end

--Callback called by "ZO_ScrollList_CreateDataEntry" to setup a row
function ScanList:SetupScanRow( control, data )
   control.data = data
   data.control = control
   GetControl(control, "Name"):SetText(data.name)
   --GetControl(control, "BG"):SetHidden(false)

   
   self:SetupRow(control, data)
   self:UpdateRow(data)
end


function ScanList:BuildMasterList()
   local scrollData = ZO_ScrollList_GetDataList(self.list)
   ZO_ClearNumericallyIndexedTable(scrollData)

   for name, data in pairs(self.masterList) do
      table.insert(scrollData, ZO_ScrollList_CreateDataEntry(SCANNER_DATA, data))
   end
end

-- function ScanList:FilterScrollList() end

function ScanList:SortScrollList()
   local scrollData = ZO_ScrollList_GetDataList(self.list)
   table.sort(scrollData, self.sortFunction)
end

local function generateReport(data)
   local s = string.format("Player was seen botting...\n%s (%s)\n%s (%s, %s)\n%s", 
			   data.name, data.displayname, data.location,data.x,data.y, os.date("%c", data.time))
   local function reportSent(...)
      df("Reported: %s (%s)!", data.name, data.displayname)
      BotScan.reported[data.displayname] = true
      data.reported = true
      ScanList:UpdateRow(data)
   end
   if not BotScan.reported[data.displayname] then

      -- d(s)
      -- reportSent()
      ZO_HELP_GENERIC_TICKET_SUBMISSION_MANAGER:OpenReportPlayerTicketScene(data.displayname,reportSent)
      ZO_Help_Ask_For_Help_Keyboard_ControlDescriptionBodyField:SetText(s)


      local comboBox = ZO_Help_Ask_For_Help_Keyboard_ControlSubcategoryComboBox.m_comboBox
      comboBox.m_selectedItemData = comboBox.m_sortedItems[5]

      ZO_Help_Ask_For_Help_Keyboard_ControlSubcategoryComboBoxSelectedItemText:SetText("Other")
      
      
   else
      df("Already Reported: %s (%s)!", data.name, data.displayname)
   end
end

function ScanList:EnterRow(row)
   if not selflockedForUpdates then
      ZO_ScrollList_MouseEnter(self.list, row)
      local data = row.data
      if data then
	 local tooltipText = string.format("%s",data.displayname)
	 InitializeTooltip(InformationTooltip, row, BOTTOM, 100, 0, TOP)
	 SetTooltipText(InformationTooltip, tooltipText)
      end
      -- local data = ZO_ScrollList_GetData(row)
      -- if data then
      -- 	 self:UpdateRow(data)
      -- end
      
      self.mouseOverRow = row
   end
end

function ScanList:ExitRow(row)
   if not self.lockedForUpdates then
      ZO_ScrollList_MouseExit(self.list, row)

      ZO_Options_OnMouseExit(row) 
         
      self.mouseOverRow = nil
   end   
end

function ScanList:RowContextMenu(data)
--   a.hello = crashed
   ClearMenu()
   AddMenuItem(GetString(SI_CHAT_PLAYER_CONTEXT_WHISPER), function() StartChatInput(nil, CHAT_CHANNEL_WHISPER, data.name) end)
   AddMenuItem("Generate Report", function() generateReport(data) end)
   AddMenuItem("Remove From List", function() self.masterList[data.displayname] = nil self:RefreshData() end)
   --AddMenuItem("Dump Data Table", function() for k,v in pairs(data) do df("%s -> %s",tostring(k), tostring(v)) end end)


   if(ZO_Menu_GetNumMenuItems() > 0) then
      ShowMenu()
   end
			
end
function ScanList:MouseClickHandler(control, button, shift)
   local data = control.data
   if button == 1 then
      if shift then
	 generateReport(data)
      else
	 StartChatInput(nil, CHAT_CHANNEL_WHISPER, data.name)
      end
   elseif button == 2 then
      self:RowContextMenu(data)
   elseif button == 3 then
      generateReport(data)
   end
end


function BotScanner_ScanList_OnInitialized(self)
   BotScan.scanList = ScanList:New(self)
end
