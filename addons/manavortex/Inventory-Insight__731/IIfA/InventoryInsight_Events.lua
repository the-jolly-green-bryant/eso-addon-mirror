local LCM = LibCustomMenu
-- 2016-7-26 AM - added global funcs for events
-- the following functions are all globals, not tied to the IIfA class, but call the IIfA class member functions for event processing

-- 2015-3-7 AssemblerManiac - added code to collect inventory data at char disconnect
local function IIfA_EventOnPlayerDeactivated()
  IIfA:dm("Debug", "[IIfA_EventOnPlayerDeactivated] Event Starting...")
  -- to help prevent CollectAll() from trying to gather BAG_COMPANION_WORN data
  IIfA.currentCompanionId = IIfA:GetCurrentCompanionHashId()

  -- update the stored inventory every time character logs out, will assure it's always right when viewing from other chars
  IIfA:CollectAll() -- don't call CollectAllUseAsync using async lib

  IIfA.CharCurrencyFrame:UpdateAssets()
  IIfA.CharBagFrame:UpdateAssets()
end

-- used by an event function
function IIfA:InventorySlotUpdate(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange, triggeredByCharacterName, triggeredByDisplayName, isLastUpdateForMessage, bonusDropSource)
  local hasNoBagInfo = not bagId or not slotIndex
  local hasNoActiveCompanion = bagId == BAG_COMPANION_WORN and not HasActiveCompanion()
  if hasNoBagInfo or hasNoActiveCompanion then return end
  IIfA:dm("Debug", "[InventorySlotUpdate] Bag: <<1>>, Slot: <<2>>, stackCountChange: <<3>>", bagId, slotIndex, stackCountChange)

  IIfA:EvalBagItem(bagId, slotIndex)

  -- once a bunch of items comes in, this will be created for each, but only the last one stays alive
  -- so once all the items are finished coming in, it'll only need to update the shown list one time
  local callbackName = "IIfA_RefreshInventoryScroll"
  local function Update()
    EVENT_MANAGER:UnregisterForUpdate(callbackName)
    if IIFA_GUI:IsControlHidden() then
      return
    else
      IIfA:RefreshInventoryScroll()
    end
  end

  --cancel previously scheduled update if any
  EVENT_MANAGER:UnregisterForUpdate(callbackName)
  --register a new one
  if not IIFA_GUI:IsControlHidden() then
    -- only update the frame if it's shown
    EVENT_MANAGER:RegisterForUpdate(callbackName, IIFA_DATABASE[IIfA.currentAccount].settings.refreshDelay, Update)
  end
end

-- eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange, triggeredByCharacterName, triggeredByDisplayName, isLastUpdateForMessage, bonusDropSource
local function IIfA_InventorySlotUpdate(...)
  IIfA:InventorySlotUpdate(...)
end

local function IIfA_ScanHouse(eventCode, oldMode, newMode)
  IIfA:dm("Debug", "[IIfA_ScanHouse] Event Starting - oldMode: '<<2>>', newMode: '<<3>>'", oldMode, newMode)
  if newMode == "showing" or newMode == "shown" then return end
  -- are we listening?
  if not IIfA:GetCollectingHouseData() then return end
  local houseCollectibleId = GetCollectibleIdForHouse(GetCurrentZoneHouseId())
  IIfA:RescanHouse(houseCollectibleId)
end

local function IIfA_HouseEntered(eventCode, oldMode, newMode)
  if not IsOwnerOfCurrentHouse() then return end
  IIfA:dm("Debug", "[IIfA_HouseEntered] Event Starting - oldMode: '<<2>>', newMode: '<<3>>'", oldMode, newMode)

  -- Get the house collectible ID
  local houseCollectibleId = GetCollectibleIdForHouse(GetCurrentZoneHouseId())
  IIfA:dm("Debug", "[IIfA_HouseEntered] houseCollectibleId: '<<1>>'", houseCollectibleId)

  -- Ensure the house is registered
  local collectHouseData = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType].collectHouseData
  if collectHouseData[houseCollectibleId] == nil then
    IIfA:SetTrackingForHouse(houseCollectibleId, IIfA:GetCollectingHouseData())
  end
  IIfA:GetTrackedBags()[houseCollectibleId] = IIfA:GetTrackedBags()[houseCollectibleId] or collectHouseData[houseCollectibleId]

  -- Rescan the house if tracking is enabled
  if IIfA:GetTrackedBags()[houseCollectibleId] then
    IIfA:RescanHouse(houseCollectibleId)
  end
end

-- request from Baertram - add right click context menu "Search thru Inventory Insight" to item links
local function addItemLinkSearchContextMenuEntry(itemLink, rowControl)
  if rowControl then
    local slotType = ZO_InventorySlot_GetType(rowControl)
    if slotType == SLOT_TYPE_ITEM or slotType == SLOT_TYPE_EQUIPMENT or slotType == SLOT_TYPE_BANK_ITEM or slotType == SLOT_TYPE_GUILD_BANK_ITEM or
      slotType == SLOT_TYPE_TRADING_HOUSE_POST_ITEM or slotType == SLOT_TYPE_REPAIR or slotType == SLOT_TYPE_CRAFTING_COMPONENT or slotType == SLOT_TYPE_PENDING_CRAFTING_COMPONENT or
      slotType == SLOT_TYPE_PENDING_CRAFTING_COMPONENT or slotType == SLOT_TYPE_PENDING_CRAFTING_COMPONENT or slotType == SLOT_TYPE_CRAFT_BAG_ITEM then
      local bag, index = ZO_Inventory_GetBagAndIndex(rowControl)
      itemLink = GetItemLink(bag, index, LINK_STYLE_BRACKETS)
    end
    if slotType == SLOT_TYPE_TRADING_HOUSE_ITEM_RESULT then
      itemLink = GetTradingHouseSearchResultItemLink(ZO_Inventory_GetSlotIndex(rowControl), LINK_STYLE_BRACKETS)
    end
    if slotType == SLOT_TYPE_TRADING_HOUSE_ITEM_LISTING then
      itemLink = GetTradingHouseListingItemLink(ZO_Inventory_GetSlotIndex(rowControl), LINK_STYLE_BRACKETS)
    end
    local hasStoreIndexData = rowControl and rowControl.index and slotType == SLOT_TYPE_STORE_BUY
    if hasStoreIndexData then
      itemLink = GetStoreItemLink(rowControl.index, LINK_STYLE_BRACKETS)
    end
  end
  if not itemLink or itemLink == IIfA.EMPTY_STRING then return end
  --Get the item's name from the link
  local itemNameClean = ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(itemLink))
  if not itemNameClean or itemNameClean == IIfA.EMPTY_STRING then return end
  --Change the dropdown box of IIfA to "All", GetString(IIFA_LOCATION_NAME_ALL)
  if IIFA_GUI_Header_Dropdown_Main then
    local comboBox = IIFA_GUI_Header_Dropdown_Main.m_comboBox
    comboBox:SetSelectedItem(comboBox.m_sortedItems[1].name)
  end
  --Put the name in the IIfA search box
  IIfA.GUI_SearchBox:SetText(itemNameClean)
  IIfA:ApplySearchText(itemNameClean)
  --Open the IIfA UI if not already shown
  if IIFA_GUI:IsControlHidden() then
    IIfA:ToggleInventoryFrame()
  end
end

local function IIfA_LinkContext_InsertLinkEvent(link, button, control, _, linkType, ...)
  IIfA:dm("Debug", "[ZO_LinkHandler_InsertLinkEvent] occured.")
end
local function IIfA_LinkContext_LinkClickedEvent(link, button, control, _, linkType, ...)
  IIfA:dm("Debug", "[ZO_LinkHandler_LinkClickedEvent] occured.")
end

--Contextmenu from chat/link handler
local function IIfA_LinkContext_LinkMouseUpEvent(link, button, control, _, linkType, ...)
  IIfA:dm("Debug", "[ZO_LinkHandler_LinkMouseUpEvent] occured.")
  if button == MOUSE_BUTTON_INDEX_RIGHT and linkType == ITEM_LINK_TYPE then
    IIfA:dm("Debug", "[MOUSE_BUTTON_INDEX_RIGHT] used.")
    AddCustomMenuItem("IIfA: Search inventories", function() addItemLinkSearchContextMenuEntry(link, nil) end, MENU_ADD_OPTION_LABEL)
    if IIfA.bAddContextMenuEntryMissingMotifsInIIfA and GetItemLinkItemType(link) == ITEMTYPE_RACIAL_STYLE_MOTIF then
      local isMotif, motifNum = IIfA:IsItemMotif(link)
      if isMotif and motifNum then
        AddCustomMenuItem("Missing motifs (#" .. tostring(motifNum) .. ") to text", function() IIfA:FMC(control, link, "Private") end, MENU_ADD_OPTION_LABEL)
        AddCustomMenuItem("Missing motifs (#" .. tostring(motifNum) .. ") to chat", function() IIfA:FMC(control, link, "Public") end, MENU_ADD_OPTION_LABEL)
      end
    end
    --Show the context menu entries at the itemlink handler now
    ShowMenu()
  else
    IIfA:dm("Debug", "[MOUSE_BUTTON_INDEX_RIGHT] not used.")
  end
end

local function IIfA_LinkContext_NotHandledEvent(link, button, control, _, linkType, ...)
  IIfA:dm("Debug", "[ZO_LinkHandler_NotHandledEvent] occured.")
end

local function IIfA_StackedAllItemsInBagId(eventCode, bagId)
  IIfA:dm("Debug", "[IIfA_StackedAllItemsInBagId] bagId: <<1>>", bagId)
  IIfA:RescanBag(bagId)
  IIfA:MakeBSI()
end

local function IIfA_UpdateBackpackAndCraftBag()
  IIfA:dm("Debug", "[IIfA_UpdateBackpackAndCraftBag] Inventory Full Update called, scanning Backpack and Craft Bag Starting...")
  IIfA:ScanBackpackAndCraftBag()
end

function IIfA:UpdateCurrentCompanionInfo()
  IIfA:UpdateCompanionCharLookups()
  IIfA.currentCompanionId = IIfA:GetCurrentCompanionHashId()
  if HasActiveCompanion() then IIfA:RescanBag(BAG_COMPANION_WORN) end
end

function IIfA:CompanionDeactivated()
  IIfA.currentCompanionId = IIfA:GetCurrentCompanionHashId()
end

--Contextmenu from inventory row
local function ZO_InventorySlot_ShowContextMenu_For_IIfA(inventorySlot, slotActions)
  -- IIfA:dm("Debug", "[ZO_InventorySlot_ShowContextMenu_For_IIfA] Inventory Menu")
  local slotType = ZO_InventorySlot_GetType(inventorySlot)
  local itemLink = nil
  if slotType == SLOT_TYPE_ITEM or slotType == SLOT_TYPE_EQUIPMENT or slotType == SLOT_TYPE_BANK_ITEM or slotType == SLOT_TYPE_GUILD_BANK_ITEM or
    slotType == SLOT_TYPE_TRADING_HOUSE_POST_ITEM or slotType == SLOT_TYPE_REPAIR or slotType == SLOT_TYPE_CRAFTING_COMPONENT or slotType == SLOT_TYPE_PENDING_CRAFTING_COMPONENT or
    slotType == SLOT_TYPE_PENDING_CRAFTING_COMPONENT or slotType == SLOT_TYPE_PENDING_CRAFTING_COMPONENT or slotType == SLOT_TYPE_CRAFT_BAG_ITEM then
    local bag, index = ZO_Inventory_GetBagAndIndex(inventorySlot)
    itemLink = GetItemLink(bag, index, LINK_STYLE_BRACKETS)
  end
  if slotType == SLOT_TYPE_TRADING_HOUSE_ITEM_RESULT then
    itemLink = GetTradingHouseSearchResultItemLink(ZO_Inventory_GetSlotIndex(inventorySlot), LINK_STYLE_BRACKETS)
  end

  if not inventorySlot or (inventorySlot.GetOwningWindow and inventorySlot:GetOwningWindow() == IIFA_GUI) then return end

  if IIfA.bAddContextMenuEntryMissingMotifsInIIfA and itemLink and GetItemLinkItemType(itemLink) == ITEMTYPE_RACIAL_STYLE_MOTIF then
    local isMotif, motifNum = IIfA:IsItemMotif(itemLink)
    if isMotif and motifNum then
      AddCustomMenuItem("Missing motifs (#" .. tostring(motifNum) .. ") to text", function() IIfA:FMC(inventorySlot, itemLink, "Private") end, MENU_ADD_OPTION_LABEL)
      AddCustomMenuItem("Missing motifs (#" .. tostring(motifNum) .. ") to chat", function() IIfA:FMC(inventorySlot, itemLink, "Public") end, MENU_ADD_OPTION_LABEL)
    end
  end

  AddCustomMenuItem("IIfA: Search inventories", function() addItemLinkSearchContextMenuEntry(nil, inventorySlot) end, MENU_ADD_OPTION_LABEL)
  ShowMenu(inventorySlot)
end

local function IIfA_EventOnPlayerActivated()
  IIfA:LibAddonInit()
  EVENT_MANAGER:UnregisterForEvent("IIFA_PLAYER_ACTIVATED_EVENTS", EVENT_PLAYER_ACTIVATED)
end

function IIfA:RegisterForEvents()
  -- 2016-6-24 AM - commented this out, doing nothing at the moment, revisit later
  EVENT_MANAGER:RegisterForEvent("IIFA_PLAYER_ACTIVATED_EVENTS", EVENT_PLAYER_ACTIVATED, IIfA_EventOnPlayerActivated)

  -- 2015-3-7 AssemblerManiac - added EVENT_PLAYER_DEACTIVATED event
  EVENT_MANAGER:RegisterForEvent("IIFA_PLAYER_UNLOADED_EVENTS", EVENT_PLAYER_DEACTIVATED, IIfA_EventOnPlayerDeactivated)

  -- when item comes into inventory
  EVENT_MANAGER:RegisterForEvent("IIFA_InventorySlotUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, IIfA_InventorySlotUpdate)
  EVENT_MANAGER:AddFilterForEvent("IIFA_InventorySlotUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)

  -- Events for data collection
  --	EVENT_MANAGER:RegisterForEvent("IIFA_ALPUSH", 		EVENT_ACTION_LAYER_PUSHED, 	function() IIfA:ActionLayerInventoryUpdate() end)
  EVENT_MANAGER:RegisterForEvent("IIFA_BANK_OPEN", EVENT_OPEN_BANK, function() IIfA:ScanBank() end)

  -- on opening guild bank:
  EVENT_MANAGER:RegisterForEvent("IIFA_GUILDBANK_LOADED", EVENT_GUILD_BANK_ITEMS_READY, function() IIfA:GuildBankDelayReady() end)

  -- on adding or removing an item from the guild bank:
  EVENT_MANAGER:RegisterForEvent("IIFA_GUILDBANK_ITEM_ADDED", EVENT_GUILD_BANK_ITEM_ADDED, function(...) IIfA:GuildBankAddRemove(...) end)
  EVENT_MANAGER:RegisterForEvent("IIFA_GUILDBANK_ITEM_REMOVED", EVENT_GUILD_BANK_ITEM_REMOVED, function(...) IIfA:GuildBankAddRemove(...) end)

  -- Housing
  EVENT_MANAGER:RegisterForEvent("IIFA_HOUSING_PLAYER_INFO_CHANGED", EVENT_PLAYER_ACTIVATED, IIfA_HouseEntered)
  EVENT_MANAGER:RegisterForEvent("IIfA_HOUSE_MANAGER_MODE_CHANGED", EVENT_HOUSING_EDITOR_MODE_CHANGED, IIfA_ScanHouse)

  EVENT_MANAGER:RegisterForEvent("IIFA_GuildJoin", EVENT_GUILD_SELF_JOINED_GUILD, function() IIfA:CreateOptionsMenu() end)
  EVENT_MANAGER:RegisterForEvent("IIFA_GuildLeave", EVENT_GUILD_SELF_LEFT_GUILD, function() IIfA:CreateOptionsMenu() end)

  EVENT_MANAGER:RegisterForEvent("IIFA_CompanionActivated", EVENT_COMPANION_ACTIVATED, function() IIfA:UpdateCurrentCompanionInfo() end)
  EVENT_MANAGER:RegisterForEvent("IIFA_CompanionDeactivated", EVENT_COMPANION_DEACTIVATED, function() IIfA:CompanionDeactivated() end)

  EVENT_MANAGER:RegisterForEvent("IIFA_StackedItems", EVENT_STACKED_ALL_ITEMS_IN_BAG, IIfA_StackedAllItemsInBagId)

  EVENT_MANAGER:RegisterForEvent("IIFA_InventoryFullUpdate", EVENT_INVENTORY_FULL_UPDATE, IIfA_UpdateBackpackAndCraftBag)

  --    ZO_QuickSlot:RegisterForEvent(EVENT_ABILITY_COOLDOWN_UPDATED, IIfA_EventDump)
  ZO_PreHook('ZO_InventorySlot_ShowContextMenu', function(rowControl) IIfA:ProcessRightClick(rowControl) end)

  -- handle right clicks on links
  --Add contextmenu entry to items to search for the item in the IIfA UI
  if IIFA_DATABASE[IIfA.currentAccount].settings.bAddContextMenuEntrySearchInIIfA then
    -- The link handler context menu
    LINK_HANDLER:RegisterCallback(LINK_HANDLER.INSERT_LINK_EVENT, IIfA_LinkContext_InsertLinkEvent)
    LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_CLICKED_EVENT, IIfA_LinkContext_LinkClickedEvent)
    LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, IIfA_LinkContext_LinkMouseUpEvent)
    LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_NOT_HANDLED_EVENT, IIfA_LinkContext_NotHandledEvent)
    -- The inventory row context menu
    LCM:RegisterContextMenu(ZO_InventorySlot_ShowContextMenu_For_IIfA)
  end
end
