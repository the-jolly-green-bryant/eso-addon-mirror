-- BotScanner.lua

local BotScan = BotScan

do
   local index = 1
   function BotScan.toggleScanFeature()
      if index == 1 then -- Start scanner
	 index = 2
	 d("Beginning Scan (Opening scan window)")
	 SLASH_COMMANDS["/bot"]("scan")
      elseif index == 2 then -- Pause Scanner
	 d("Pausing Scan")
	 SLASH_COMMANDS["/bot"]("pause")
	 index = 3
      elseif index == 3 then
	 d("Closing scan window")
	 SLASH_COMMANDS["/bot"]("hide")
	 index = 1
      end
      
   end
end


-- local function extractLinkData(linkText)
--    local data = {}
--    for val in string.gfind(linkText, "[:H]([^%:|]+)","%1") do
--       table.insert(data, val)
--    end
--    return data
-- end


-- Callback for when customized Bot Scanner Link is clicked

function BotScan.OnAddonLoaded(eventId, name)
   --   BotScan.addons[name] = true
   if name == BotScan.name then
      --    BotScan.passed = true
      local defaults = {
	 offX = 100,
	 offY = 300,
	 anchorPoint = TOPLEFT,
	 ticketList = {},
	 order = ZO_SORT_ORDER_UP
      }
      BotScan.SV = ZO_SavedVars:New("BotScanner_Data", 1, nil, defaults, nil)

      if BotScan.SV.autoWaypoint then
	 EVENT_MANAGER:RegisterForEvent(BotScan.name,EVENT_CHAT_MESSAGE_CHANNEL, BotScan.ChatUpdate)
	 BotScanner_AutoWaypoint:SetText("Auto Waypoint: On")
      end
      BotScan.scanList.currentSortOrder = BotScan.SV.order
      BotScanner:ClearAnchors()
      BotScanner:SetAnchor(BotScan.SV.anchorPoint, GuiRoot, nil, BotScan.SV.offX, BotScan.SV.offY)

      BotScan:LoadTickets()
      --BotScanner_Text:SetHandler("OnLinkClicked", OnLinkClickedCallback)

      ZO_CreateStringId("SI_BINDING_NAME_BotScanner_ToggleScanner", "Toggle Bot Scanner") -- you also need to use a bindings.xml in order to display your keybind in options.
      EVENT_MANAGER:UnregisterForEvent(BotScan.name, EVENT_ADD_ON_LOADED)
   end
end


function BotScan.TargetChanged(event)
   if not DoesUnitExist('reticleover') then return end
   
   if IsUnitPlayer('reticleover') then
      local x, y = GetMapPlayerPosition('player')
      local name = GetUnitDisplayName('reticleover')
      local data = {
	 active = true,
	 name = GetUnitName('reticleover'),
	 displayname = name,
	 x = x,
	 y = y,
	 location = GetPlayerLocationName(),
	 time = os.time(),
	 reported = BotScan.reported[name] ~= nil
      }
            
      BotScan.scanList:NewEntry(data)
   end
end


function BotScan:OnMoveStop()
   if self.SV ~= nil then 
      _,self.SV.anchorPoint,_,_, self.SV.offX, self.SV.offY = BotScanner:GetAnchor()
   end
end
function BotScan:ShowNamesWindow()
   BotScannerScanWindow:SetHidden(false)
end

function BotScan:HideNamesWindow()
   BotScanner:SetHidden(true)
end


do
   local toggle = true
   function BotScan:ToggleListView(control)
      BotScannerScanWindow:SetHidden(toggle)
      toggle = not toggle
      BotScannerTicketWindow:SetHidden(toggle)

      control:SetText(toggle and "View Ticket List" or "View Scan List")
	 
   end
end


do
   local ticketsLoaded = false
   local noNewIndexes = { __newindex = function() end }
   local function defaults()
      local default = { sortIndex = -1}
      default.__index = default
      default.__newindex = default
      return setmetatable(default, noNewIndexes)
   end

   function BotScan:LoadTickets()
      if not ticketsLoaded then
	 ticketsLoaded = true
	 for i, v in ipairs(BotScan.SV.ticketList) do
	    if type(v) == "string" then
	       BotScan.SV.ticketList[i] = setmetatable({id = v, t = os.time()}, defaults())
	    else
	       setmetatable(v, defaults())
	    end
	    
	 end
	 BotScan.ticketList:LoadTickets(BotScan.SV.ticketList)
      end
   end

   function BotScan:TicketSubmitted(eventCode, responseMessage,success)
   if success then
      --df("Success: %s", responseMessage)
      local _,_,ticket = string.find(responseMessage, "(%d+-%d+)")
      if ticket then
	 BotScan.ticketList:AddTicket(setmetatable({id = ticket, t = os.time()}, defaults()))
	 -- BotScanner_TicketList:AddMessage(ticket)
      end
   else
      d("failure", responseMessage)
   end
end

end



do
   local supportedChannels = {
      [CHAT_CHANNEL_ZONE] = true,
      [CHAT_CHANNEL_WHISPER] = true,
      [CHAT_CHANNEL_SAY] = true,
   }
   function BotScan.ChatUpdate(eventCode,channelType,fromName,text,isCustomerService,fromDisplayName)
--      if  supportedChannels[channelType] then
	 local _,_, x, y = string.find(text,"%[Bot Scanner%]:%((.-),(.-)%)")
	 --d(text)
	 if x and y  then --and fromDisplayName ~= GetUnitDisplayName('player')
	    CENTER_SCREEN_ANNOUNCE:AddMessage(EVENT_BROADCAST, CSA_CATEGORY_SMALL_TEXT, SOUNDS.EMPEROR_CORONATED_DAGGERFALL,
					      zo_strformat("<<1>> has discovered bots at <<o:1>> location!", fromName),
					      nil, nil, nil, nil, nil, 5000)
	    PingMap(MAP_PIN_TYPE_RALLY_POINT,PIN_ANIMATION_TARGET_MAP_AND_GUTTER, tonumber(x),tonumber(y))
	 end
  --    end
   end
end

function BotScan:ToggleAutoWaypoint(buttonControl)
   self.SV.autoWaypoint = not self.SV.autoWaypoint
   if self.SV.autoWaypoint then
      EVENT_MANAGER:RegisterForEvent(self.name,EVENT_CHAT_MESSAGE_CHANNEL, self.ChatUpdate)
      buttonControl:SetText("Auto Waypoint: On")
   else
      EVENT_MANAGER:UnregisterForEvent(self.name,EVENT_CHAT_MESSAGE_CHANNEL)
      buttonControl:SetText("Auto Waypoint: Off")
   end
end
function BotScan:OnInitialized()
   
   EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ADD_ON_LOADED, self.OnAddonLoaded)
   
   EVENT_MANAGER:RegisterForEvent(self.name,EVENT_CUSTOMER_SERVICE_TICKET_SUBMITTED, function (...) return self:TicketSubmitted(...) end)
   --EVENT_MANAGER:RegisterForEvent(self.name, EVENT_RETICLE_TARGET_PLAYER_CHANGED, BotScan.TargetPlayerChanged)
   
   SLASH_COMMANDS["/bot"] = function (extra)
      if extra == "clear" then
	 self.scanList:ClearAll()
	 

      elseif extra == "start" or extra == "scan" then
	 EVENT_MANAGER:RegisterForEvent(self.name, EVENT_RETICLE_TARGET_CHANGED, self.TargetChanged)
	 BotScanner:SetHidden(false)
      elseif extra == "hide" then
	 EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_RETICLE_TARGET_CHANGED)
	 BotScanner:SetHidden(true)
      elseif extra == "show" then
	 BotScanner:SetHidden(false)
      elseif extra == "pause" then
      	 EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_RETICLE_TARGET_CHANGED)
      elseif extra == "fin" then
	 EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_RETICLE_TARGET_CHANGED)
	 BotScanner:SetHidden(true)
	 self.scanList:ClearAll()
	 
      else
	 d("/bot -> print summary")
	 d("/bot scan||start -> begin scanning")
	 d("/bot fin -> Totally finished, clear everything")
	 d("/bot clear -> just clear window and data")
	 d("/bot pause -> pause the collection of data")
	 d("/bot hide -> hide the bot window and stop scanning")
	 d("/bot show -> reveal the scan window")
      end
   end
end
