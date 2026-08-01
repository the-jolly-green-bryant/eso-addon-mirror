-- Namespace
DLC_SlotsCount = {}

DLC_SlotsCount.name = "SlotsCount"
DLC_SlotsCount.guildData = {}
DLC_SlotsCount.guildSlots = {}
DLC_SlotsCount.guildName = {}
DLC_SlotsCount.isScanning = false

DLC_SlotsCount.savedDataVersion = 1
DLC_SlotsCount.savedData = nil

local logger = nil
if LibDebugLogger then
  logger = LibDebugLogger.Create(DLC_SlotsCount.name)
  DLC_SlotsCount.logger = logger
else
  logger = {
    Info = function(msg) end,
    Debug = function(msg) end,
  }
end

function DLC_SlotsCount:GetUserSlots(guildID, userDisplayName)
  local gd = DLC_SlotsCount.guildData[guildID]
  local slots = 0
  if gd then
      sellerName = userDisplayName:gsub("|c.*|r", "")
      slots = gd[sellerName] or 0
  end
  return slots
end

function DLC_SlotsCount:Initialize()
  DLC_SlotsCount.slotsColumn = LibGuildRoster:AddColumn({
    key = 'DLCSlotsCount',
    width = 80,
    header = {
      title = 'Slots'
    },
    row = {
      align = TEXT_ALIGN_CENTER,
      data = function(guildID, rowData, index)
        return DLC_SlotsCount:GetUserSlots(guildID, rowData.displayName)
      end,
      format = function(value)
        return zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(tonumber(value)))
      end
    },
    guildFilter = { nil }
  })

  ZO_CreateStringId("SI_BINDING_NAME_DLC_SC_SCAN", "Count Slots")

  DLC_SlotsCount.startScanButton = {
    name = "Count Slots",
    keybind = "DLC_SC_SCAN",
    callback = function()
        DLC_SlotsCount:Scan()
      end,
    enabled = function()
        return not DLC_SlotsCount.isScanning
      end,
    alignment = KEYBIND_STRIP_ALIGN_LEFT
  }

  DLC_SlotsCount.savedData = ZO_SavedVars:NewAccountWide("SlotsCountData", DLC_SlotsCount.savedDataVersion, nil, nil, nil)

  logger:Info("CSlotsCount initialized!")
end

function DLC_SlotsCount:SetUI(isStoreOpened)
  DLC_SlotsCount.storeOpened = isStoreOpened
  DLC_SlotsCount:UpdateButtons()
end

function DLC_SlotsCount:UpdateButtons()
  if DLC_SlotsCount.storeOpened then 
    if (not KEYBIND_STRIP:HasKeybindButton(DLC_SlotsCount.startScanButton)) then
      KEYBIND_STRIP:AddKeybindButton(DLC_SlotsCount.startScanButton)
    else
      KEYBIND_STRIP:UpdateKeybindButton(DLC_SlotsCount.startScanButton)
    end
  else
    KEYBIND_STRIP:RemoveKeybindButton(DLC_SlotsCount.startScanButton)
  end
end

function DLC_SlotsCount.SaveData()
  if DLC_SlotsCount.isScanning then return end

  DLC_SlotsCount.savedData.GuildData = DLC_SlotsCount.guildData 
  DLC_SlotsCount.savedData.GuildSlots = DLC_SlotsCount.guildSlots 
  DLC_SlotsCount.savedData.GuildName = DLC_SlotsCount.guildName 
end

function DLC_SlotsCount.ClearData()
  if DLC_SlotsCount.isScanning then return end

  DLC_SlotsCount.slotsColumn:SetGuildFilter({ "None" }) 
  DLC_SlotsCount.guildData = {}
  DLC_SlotsCount.guildSlots = {}
  DLC_SlotsCount.guildName = {}

  DLC_SlotsCount.savedData = {}
  LibGuildRoster:Refresh()
end

local function DLC_CloseMsgBox()
  ZO_Dialogs_ReleaseDialog("DLCSlotsCount", false)
  DLC_SlotsCount.activeDialog = nil
end

local function DLC_ShowMsgBox(title, msg)
  if ZO_Dialogs_IsShowing("DLCSlotsCount") and DLC_SlotsCount.activeDialog then
    ZO_Dialogs_UpdateDialogMainText(DLC_SlotsCount.activeDialog, {text = msg})
  else
    local confirmDialog = 
    {
      title = { text = title },
      mainText = { text = msg },
      buttons = {}
    }
    ZO_Dialogs_RegisterCustomDialog("DLCSlotsCount", confirmDialog)
    DLC_SlotsCount.activeDialog = ZO_Dialogs_ShowDialog("DLCSlotsCount")
  end 
end

local function DLC_GetDelay()
    return math.max(GetTradingHouseCooldownRemaining() + 100, 500)
end

local function DLC_ProcessTradingHouseSearchResults()
  local numItemsOnPage, currentPage, hasMorePages = GetTradingHouseSearchResultsInfo()
  local gid, guildName = GetCurrentTradingHouseGuildDetails()
  DLC_ShowMsgBox("Slots Count", "scanning page " .. (currentPage+1))
  logger:Debug("...scanning page " .. (currentPage+1))
  
  for i = 1, numItemsOnPage do
    local _, _, _, stackCount, sellerName, _, _, _, uid = GetTradingHouseSearchResultItemInfo(i)
    sellerName = sellerName:gsub("|c.*|r", "")
    local count = DLC_SlotsCount.guildData[gid][sellerName] or 0
    DLC_SlotsCount.guildData[gid][sellerName] = count+1
    local total = DLC_SlotsCount.guildSlots[gid] + 1 
    DLC_SlotsCount.guildSlots[gid] = total
  end

  if hasMorePages then
    zo_callLater(function()
        ExecuteTradingHouseSearch(currentPage + 1)
      end, DLC_GetDelay())
  else
    EVENT_MANAGER:UnregisterForEvent(DLC_SlotsCount.name, EVENT_TRADING_HOUSE_RESPONSE_RECEIVED)
    ClearAllTradingHouseSearchTerms()
    
    local guildFilter = {}
    local n=1
    for k,v in pairs(DLC_SlotsCount.guildData) do
      guildFilter[n] = k
      n = n + 1 
      logger:Debug(k .. " added to guild filter")
    end
    logger:Debug("guild filter has: " .. #guildFilter .. " entries")
    DLC_SlotsCount.slotsColumn:SetGuildFilter(guildFilter)
    LibGuildRoster:Refresh()


    DLC_ShowMsgBox("Slots Count", "Scanning finished. SlotsCount: " .. (DLC_SlotsCount.guildSlots[gid]))
    CHAT_ROUTER:AddSystemMessage("SlotsCount: guild: " .. guildName .. " slots count " .. (DLC_SlotsCount.guildSlots[gid]))

    zo_callLater(function()
        logger:Info("SlotsCount Scanning finished. SlotsCount: " .. (DLC_SlotsCount.guildSlots[gid]))
        CHAT_ROUTER:AddSystemMessage("SlotsCount: You can use /sc_clear command to remove slots count data from memory.")
        DLC_SlotsCount.isScanning = false
        DLC_SlotsCount.UpdateButtons()
        DLC_SlotsCount.SaveData()
        DLC_CloseMsgBox()
        ExecuteTradingHouseSearch(currentPage + 1)
      end, DLC_GetDelay())
  end
end

local function DLC_OnTradingHouseResponseReceived(eventCode, responseType, result)
  if (responseType == TRADING_HOUSE_RESULT_SEARCH_PENDING) then
    DLC_ProcessTradingHouseSearchResults()
  end
end

function DLC_SlotsCount:Scan()
  if not DLC_SlotsCount.storeOpened then 
    DLC_ShowMsgBox("Slots Count", "Guild Store Not Opened")
    zo_callLater(DLC_CloseMsgBox, 2000)
    return 
  end
  
  local gid, name = GetCurrentTradingHouseGuildDetails()

  DLC_ShowMsgBox("Slots Count", "SlotsCount Started scanning guild " .. name .. "...")
  logger:Info("SlotsCount Started scanning guild " .. name .. "...")

  DLC_SlotsCount.isScanning = true
  DLC_SlotsCount.UpdateButtons()

  DLC_SlotsCount.guildData[gid] = { }
  DLC_SlotsCount.guildSlots[gid] = 0
  DLC_SlotsCount.guildName[gid] = name

  ClearAllTradingHouseSearchTerms()

  EVENT_MANAGER:RegisterForEvent(DLC_SlotsCount.name, EVENT_TRADING_HOUSE_RESPONSE_RECEIVED, DLC_OnTradingHouseResponseReceived)
  zo_callLater(function()
      ExecuteTradingHouseSearch(0)
    end, DLC_GetDelay())
end

local function DLC_OnTradingHouseOpened()
  DLC_SlotsCount:SetUI(true)
end

local function DLC_OnTradingHouseClosed()
  EVENT_MANAGER:UnregisterForEvent(DLC_SlotsCount.name, EVENT_TRADING_HOUSE_RESPONSE_RECEIVED)
  DLC_SlotsCount.isScanning = false

  DLC_SlotsCount:SetUI(false)
end

local function DLC_OnAddonLoaded(event, addonName)
  if addonName == DLC_SlotsCount.name then
    DLC_SlotsCount:Initialize()

    SLASH_COMMANDS['/sc_clear'] = DLC_SlotsCount.ClearData
    SLASH_COMMANDS['/sc_save'] = DLC_SlotsCount.SaveData

    EVENT_MANAGER:UnregisterForEvent(DLC_SlotsCount.name, eventCode)

    EVENT_MANAGER:RegisterForEvent(DLC_SlotsCount.name, EVENT_CLOSE_TRADING_HOUSE, DLC_OnTradingHouseClosed)
    EVENT_MANAGER:RegisterForEvent(DLC_SlotsCount.name, EVENT_OPEN_TRADING_HOUSE, DLC_OnTradingHouseOpened)
  end
end

EVENT_MANAGER:RegisterForEvent(DLC_SlotsCount.name, EVENT_ADD_ON_LOADED, DLC_OnAddonLoaded)

