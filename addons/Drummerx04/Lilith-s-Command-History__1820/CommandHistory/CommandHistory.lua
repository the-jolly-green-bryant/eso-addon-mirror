-- CommandHistory.lua
CommandHist = ZO_SortFilterList:Subclass()

CommandHist.name = "CommandHistory"
CommandHist.SV = {}
CommandHist.template =
   {
      -- ["\\metasearch"] = "if getmetatable({___}) then for _key1,_value1 in pairs(getmetatable({___}).__index) do if string.find(string.lower(_key1, {__2__})) then df('%s -> %s', tostring(_key1), tostring(_value1)) end end else d(tostring({___})) end",
      ["\\metadump"] = "if getmetatable({___}) then for _key1,_value1 in pairs(getmetatable({___}).__index) do df('%s -> %s', tostring(_key1), tostring(_value1)) end else d(tostring({___})) end",
      ["\\keydump"] = "if type({___}) == 'table' then for _key1,_value1 in pairs({___}) do df('%s -> %s', tostring(_key1), tostring(_value1)) end else d(tostring({___})) end"
   }


local function AddToHistory(command)
   --   CommandHist.SV.index = CommandHist.SV.index + 1
   table.insert(CommandHist.SV.history, command)
   CommandHist:NewEntry(command)
end


local runScript
do
   local EvaluateLua = function(command)
      local f = LoadString(command) -- returns a function?
      if f then
	 return f()
      end      
      f = LoadString("return " ..command)
      if f then
	 local ret = f()
	 if type(ret) == "function" then
	    d(tostring(ret))
	 else
	    d(ret)
	 end	 
	 return
      end
      d("|CFF4444Invalid Script|r")
      assert(LoadString(command))      
   end
   --local EvaluateLua = SLASH_COMMANDS["/script"]
   runScript = function (extra, skipHistory)
      local _,_,expType,first,second = string.find(extra,"^([%!%/%@%\\])(%w+)%s*(%w*)")
      -- d(expType,first,second)

      do
	 local front, back,templateCommand,arg1,rest = string.find(extra,"(\\%w+)%s*%{(.*)%}(.*)")      
	 if front and back then

	    if CommandHist.template[templateCommand] then
	       if not skipHistory then AddToHistory(extra) end
	       local command = extra:sub(1,front - 1) .. string.gsub(CommandHist.template[templateCommand], "%{___%}", arg1) .. rest
	       return runScript(command, true)
	    else
	       d("Invalid template command")
	    end
	    return 
	 end

      end    

      
      if not expType then -- no special handling, act normally
	 if not skipHistory then AddToHistory(extra) end
	 return EvaluateLua(extra)
      end

      
      --local expansionType = string.sub(extra, 1, 1)
      if tonumber(first) then
	 -- df("Command History: %d", tonumber(s))
	 local command = CommandHist.SV.history[tonumber(first)]
	 if command ~= nil then
	    if expType == "!" then -- Execute history command
	       if string.sub(command, 1, 1) == '\\' then 
		  return runScript(command, skipHistory)
	       else
		  return EvaluateLua(command)
	       end
	    elseif expType == "/" then -- Expand history command into chat
	       CommandHist.editbox:SetText(command)
	       CommandHist.editbox:TakeFocus()
	    elseif expType == "@" then
	       if second ~= "" then
		  CommandHist.SV.namedCommands[second] = command
	       else
		  d("Bad format - Expected: @<[[1-9]0-9]*> <[a-zA-Z]+>")
	       end
	    end
	 else
	    df("Error: No History For (%s).", tostring(first))
	 end
      else -- find and execute named commands
	 local command = CommandHist.SV.namedCommands[first] 
	 if command then
	    if expType == "!" then -- Execute named command
	       if string.sub(command, 1, 1) == '\\' then 
		  return runScript(command, skipHistory)
	       else
		  return EvaluateLua(command)
	       end
	    elseif expType == "/" then -- Expand named command into chat
	       CommandHist.editbox:SetText(command)
	       CommandHist.editbox:TakeFocus()
	    end	  
	 elseif expType == "@" then
	    if tonumber(second) then
	       CommandHist.SV.namedCommands[first] = CommandHist.SV.history[tonumber(second)]
	    else
	       df("Bad format - Expected: @<[a-zA-Z]+> <[[1-9]0-9]*>")
	    end
	 else
	    df("Error: No Command For (%s)", s)
	 end
      end
   end


end




local HISTORY_DATA = 1

--Initialize a new FilteredList with a control that has $(parent)Headers and $(parent)List children
function CommandHist:InitializeList(control)
   self:InitializeSortFilterList(control)
   
   ZO_ScrollList_AddDataType(self.list, HISTORY_DATA, "CommandHistoryRow", 28, function(control, data) self:SetupHistoryRow(control, data) end)
   ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")

   self:SetAlternateRowBackgrounds(true)
   self:SetEmptyText("No History")
   self.emptyRow:ClearAnchors()
   self.emptyRow:SetAnchor(TOPLEFT, GetControl(control, "List"), TOPLEFT, 0,0)
   self.emptyRow:SetWidth(280)
   
   local sortKeys = {
      ["number"] = { caseInsensitive = true },
   }
   self.currentSortKey = "number"
   self.currentSortOrder = ZO_SORT_ORDER_DOWN
   self.sortFunction = function(listEntry1, listEntry2 )
      return(ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, sortKeys, self.currentSortOrder))
   end

   self.editbox = GetControl(control, "ScriptBox")
   self.evaluate = GetControl(control, "EvaluateButton")
   self.evaluate:SetHandler("OnClicked", function() if self.editbox:GetText() ~= "" then runScript(self.editbox:GetText()) end end)
			    
			    return self
end




function CommandHist:ClearAll()
   self.masterList = {}
   self:RefreshData()
end


--Callback called by "ZO_ScrollList_CreateDataEntry" to setup a row
function CommandHist:SetupHistoryRow( control, data )
   control.data = data
   data.control = control
   GetControl(control,"Number"):SetText("("..tostring(data.number)..")")
  
   GetControl(control, "Command"):SetText(data.command)
   
   --GetControl(control, "BG"):SetHidden(false)

   self:SetupRow(control, data)
end

do
   local index = 1
   local noNewIndexes = { __newindex = function() end }

   function CommandHist:RowContextMenu(data)
      --   a.hello = crashed
      ClearMenu()
      AddMenuItem("Edit", function()
		     local editbox = GetControl(CommandHistory, "ScriptBox")
		     editbox:SetText(data.command)
		     editbox:TakeFocus()		     
      end)
      AddMenuItem("Execute", function() runScript(data.command, true) end)
      AddMenuItem("Remove", function()
		     table.remove(self.SV.history, data.number)
		     index = 1
		     self:LoadHistory()
      end)
      --AddMenuItem("Dump Data Table", function() for k,v in pairs(data) do df("%s -> %s",tostring(k), tostring(v)) end end)
      

      if(ZO_Menu_GetNumMenuItems() > 0) then
	 ShowMenu()
      end
      
   end
   function CommandHist:MouseClickHandler(control, button, shift)
      local data = control.data
      if button == 1 then
	 if shift then
	    local editbox = GetControl(CommandHistory, "ScriptBox")
	    editbox:SetText(data.command)
	    editbox:TakeFocus()
	    
	    --StartChatInput("/script "..data.command, CHAT_CHANNEL_ZONE)
	 else
	    runScript(data.command, true)
	 end
      elseif button == 2 then
	 if shift then
	    table.remove(self.SV.history, data.number)
	    index = 1
	    self:LoadHistory()
	 else
	    self:RowContextMenu(data)
	 end
      end
   end

   
   function CommandHist:NewEntry(command)

      local data = setmetatable({command = command, number = index, sortIndex = -1}, noNewIndexes)
      index = index + 1
      
      table.insert(self.masterList, data)

      local scrollData = ZO_ScrollList_GetDataList(self.list)
      table.insert(scrollData, ZO_ScrollList_CreateDataEntry(HISTORY_DATA, data))
      self:RefreshFilters()
      
      return data
   end

   
   function CommandHist:LoadHistory()
      self.masterList = {}
      for i, command in ipairs(self.SV.history) do
	 table.insert(self.masterList, setmetatable({command = command, number = index, sortIndex = -1}, noNewIndexes))
	 index = index + 1
      end
      self.currentSortOrder = self.SV.order
      self:RefreshData()
   end
end

function CommandHist:BuildMasterList()
   local scrollData = ZO_ScrollList_GetDataList(self.list)
   ZO_ClearNumericallyIndexedTable(scrollData)
   
   for _, ticket in pairs(self.masterList) do
      table.insert(scrollData, ZO_ScrollList_CreateDataEntry(HISTORY_DATA, ticket))
   end
end

function CommandHist:SortScrollList()
   local scrollData = ZO_ScrollList_GetDataList(self.list)
   table.sort(scrollData, self.sortFunction)
end



-- local function histIter(history)
--    local index = 0 
--    local maxIndex = CommandHist.SV.index
--    return function ()
--       repeat
-- 	 index = index + 1
--       until history[index] or index > maxIndex
--       return (index <= maxIndex and index or nil), history[index]
--    end
-- end

function CommandHist:GetControlUnderCursor()
   lchcontrol = moc()
   if lchcontrol then
      self.moc:SetText("lchcontrol: " .. lchcontrol:GetName())
   else
      self.moc:SetText("lchcontrol: ")
   end
   
end


function CommandHist.OnAddonLoaded(eventId, name)
   if name == CommandHist.name then
      ZO_CreateStringId("SI_BINDING_NAME_CommandHistory_ToggleWindow", "Toggle Command History")
      ZO_CreateStringId("SI_BINDING_NAME_CommandHistory_ReloadUI", "ReloadUI")
      ZO_CreateStringId("SI_BINDING_NAME_CommandHistory_GetControlUnderCursor", "Get Control Under Mouse")
      
      EVENT_MANAGER:UnregisterForEvent(CommandHist.name, EVENT_ADD_ON_LOADED)
      
      local defaults = {
	 offX = 100,
	 offY = 300,
	 anchorPoint = TOPLEFT,
	 show = false,
	 order = ZO_SORT_ORDER_DOWN,
	 history = {},
	 namedCommands = {},
      }
      CommandHist.SV = ZO_SavedVars:NewAccountWide("CommandHistory_Data", 1, nil, defaults, nil)

      CommandHistory:ClearAnchors()
      CommandHistory:SetAnchor(CommandHist.SV.anchorPoint, GuiRoot, nil, CommandHist.SV.offX, CommandHist.SV.offY)
      CommandHistoryScriptBox:SetMaxInputChars(2000) -- Set to the maximum history string size that can be placed in SavedVars

      if CommandHist.SV.show then
	 CommandHist:ShowHistoryWindow()
      end
      
      CommandHist:LoadHistory()

      -- CommandHistory_Text:SetHandler("OnLinkClicked", OnHistLinkClicked)

   end
end


function CommandHist:OnMoveStop()
   if self.SV ~= nil then 
      _,self.SV.anchorPoint,_,_, self.SV.offX, self.SV.offY = CommandHistory:GetAnchor()
   end
end

function CommandHist:ShowHistoryWindow()
   self.SV.show = true
   CommandHistory:SetHidden(false)
end

function CommandHist:HideHistoryWindow()
   self.SV.show = false
   CommandHistory:SetHidden(true)
end

function CommandHist:ToggleHistoryWindow()
   self.SV.show = not self.SV.show
   if self.SV.show then
      CommandHist:ShowHistoryWindow()
   else
      CommandHist:HideHistoryWindow()
   end
end

function CommandHist:EnterRow(row)
   if not selflockedForUpdates then
      ZO_ScrollList_MouseEnter(self.list, row)


      local data = ZO_ScrollList_GetData(row)
      if data then
	 InitializeTooltip(InformationTooltip, row, TOPLEFT, 0, 0, TOPRIGHT)
	 SetTooltipText(InformationTooltip, data.command)
      end

      self.mouseOverRow = row
   end
end

function CommandHist:ExitRow(row)
   if not self.lockedForUpdates then
      ZO_ScrollList_MouseExit(self.list, row)
      
      self.mouseOverRow = nil
      ZO_Options_OnMouseExit(row) 
   end   
end








function CommandHist:OnInitialized(control)
   
   EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ADD_ON_LOADED, self.OnAddonLoaded)

   self.moc = control:GetNamedChild("mocLabel")
   self:InitializeList(control)
   
   SLASH_COMMANDS["/script"] = runScript
   -- SLASH_COMMANDS["/ltest"] = function (sequence)
   --    df("Start: %s", sequence)
   --    local escaped = escapeColons(sequence)      
   --    df("Escaped: %s", escaped)
   --    local r = unescapeColons(escaped)
   --    df("Restored: %s", r)
   --    d(sequence == r)
   -- end
   SLASH_COMMANDS["/comhist"] = function (extra)
      if extra == nil or extra == "" then 
	 CommandHist:ToggleHistoryWindow()
	 return 
      end
      
      local _,_, command, arg1 = string.find(extra, "(%w+)%s*(%w*)%s*(%w*)")
      --d(command, arg1, arg2)
      if command == "show" then CommandHist:ShowHistoryWindow()
      elseif command == "hide" then CommandHist:HideHistoryWindow()
      elseif command == "dump" and arg1 == "named" then
	 d(CommandHist.SV.namedCommands)
      elseif command == "clear" then 
	 if arg1 == '' then d("Usage: <clear> <all/history/allnamed/[Named Value]>") return end
	 if arg1 == "all" then	    
	    CommandHist:ClearAll()

	    self.SV.history = {}
	    self.SV.namedCommands = {}
	 elseif arg1 == "history" then
	    CommandHist:ClearAll()

	    self.SV.history = {}
	 elseif arg1 == "allnamed" then
	    self.SV.namedCommands = {}
	 else
	    self.SV.namedCommands[arg1] = nil
	 end
      end
      
   end

end

