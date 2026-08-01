----------------------------------
--Group List Keyboard
----------------------------------
local BotScan = BotScan or {}

-- Creates a Filtered List object
local TicketList = ZO_SortFilterList:Subclass()

local TICKET_DATA = 1

--Initialize a new FilteredList with a control that has $(parent)Headers and $(parent)List children
function TicketList:New(control)
   return  self:Initialize(control)
end

function TicketList:Initialize(control)
   --Control must have $(parent)List that inherits ZO_ScrollList
   self:InitializeSortFilterList(control)
   
   ZO_ScrollList_AddDataType(self.list, TICKET_DATA, "BotScannerTicketRow", 30, function(control, data) self:SetupScanRow(control, data) end)
   ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
   
   self:SetEmptyText("No Tickets")
   self.emptyRow:ClearAnchors()
   self.emptyRow:SetAnchor(TOPLEFT, GetControl(control, "List"), TOPLEFT, 0,0)
   self.emptyRow:SetWidth(280)
   
   self.masterList = {}
   local sortKeys = {
      ["name"] = { caseInsensitive = true },
   }
   self.currentSortKey = "name"
   self.currentSortOrder = ZO_SORT_ORDER_UP
   self.sortFunction = function(listEntry1, listEntry2 )
      return(ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, sortKeys, self.currentSortOrder))
   end


   return self
end


function TicketList:NewEntry(data)
   if not self.masterList[data.name] then
      self.masterList[data.name] = data

      local scrollData = ZO_ScrollList_GetDataList(self.list)
      table.insert(scrollData, ZO_ScrollList_CreateDataEntry(TICKET_DATA, data))
      self:RefreshFilters()
   end
   return data
end

function TicketList:ClearAll()
   self.masterList = {}
   self:RefreshData()
end


--Callback called by "ZO_ScrollList_CreateDataEntry" to setup a row
function TicketList:SetupScanRow( control, data )
   control.data = data
   data.control = control
   GetControl(control,"Number"):SetText("("..tostring(data.sortIndex)..")")
   
   GetControl(control, "Ticket"):SetText(data.id)
   GetControl(control, "Date"):SetText(os.date("%c",data.t))
   
   --GetControl(control, "BG"):SetHidden(false)

   self:SetupRow(control, data)
end


function TicketList:LoadTickets(list)
   self.masterList = list
   self:RefreshData()
end

function TicketList:AddTicket(ticket)
   local scrollData = ZO_ScrollList_GetDataList(self.list)
   table.insert(self.masterList, ticket)
   table.insert(scrollData, ZO_ScrollList_CreateDataEntry(TICKET_DATA, ticket))
   self:RefreshFilters()
end

function TicketList:BuildMasterList()
   local scrollData = ZO_ScrollList_GetDataList(self.list)
   ZO_ClearNumericallyIndexedTable(scrollData)

   
   for _, ticket in pairs(self.masterList) do
      table.insert(scrollData, ZO_ScrollList_CreateDataEntry(TICKET_DATA, ticket))
   end
end



function BotScanner_TicketList_OnInitialized(self)
   BotScan.ticketList = TicketList:New(self)
end
