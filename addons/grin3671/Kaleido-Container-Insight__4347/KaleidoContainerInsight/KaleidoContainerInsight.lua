local this = {}
this.name = "KaleidoContainerInsight"
this.version = "1.0.4"
this.author = "grin3671"
this.sv = "KaleidoContainerInsightSavedVariables"

-- What this AddOn is supposed to do:
-- 1. Highlight already opened containers in the inventory
-- 2. Remember the contents of opened containers and display them in tooltips

-- What this AddOn actually does (step by step):
-- 1. Initialization
--    1.1 Add hidden Indicator to all inventory items via InventoryAddIndicators()
--    1.2 Get SCENE_MANAGER callback for better tracking Inventory closing
--        BUG: If it's possible to open the Loot screen somewhere other than the Inventory 
--             without turning on the HUD, it will cause an error in Saved Variables data.
--    1.3 Add Hook for Tooltip to show container content in tooltip via TooltipDisplayContent()
--    NOTE: next hooks are needed to tie Container in Inventory with Loot data
--    1.4 Add Hook to handle Double-click AND Primary Action "E" in Inventory
--    1.5 TODO: Add Hook for right-click and Use action
-- 2. Get containerId (UniqueId64) from Hooks and pass it to AwaitLootData()
-- 3. Register Loot-related Event Listener to link containerId and loot table in Saved Variables
-- 4. Update Indicator visibility when OnLootClosed triggers via RefreshInventorySlot()
-- 5. Clear old UniqueId64 entries from ADDONSV["checkedContainers"] when Inventory closes

-- What features might be added in the future:
-- Actual work with the "Use" option in the context menu
-- Settings such as changing Indicators icon (texture), color, size and position (global SV)
-- Additional information at items list like equipment traits and price (change String to list of xml Controls)


-- Save Character's Settings
local ADDONSV = {
  ["checkedContainers"] = {},
  ["devMode"] = false
}


local function LogDev(func, msg)
  if not ADDONSV["devMode"] then return end
  local text = zo_strformat("[<<1>>] <<2>>", "KCI:" .. func, msg)
  d(text)
end

local function LogTable(o)
  if type(o) == 'table' then
     local s = ''
     for k,v in pairs(o) do
        if type(k) ~= 'number' then k = '"'..k..'"' end
        s = s .. '['..k..'] = ' .. LogTable(v) .. ',\n'
     end
     return s
  else
     return tostring(o)
  end
end

-- Remove old entries from SV
local function InventoryGetContainers()
  -- Step 1: Create a temporary table to track found containers
  local foundContainers = {}

  -- Step 2: Iterate through the BACKPACK inventory
  for slotIndex = 0, GetBagSize(BAG_BACKPACK) do
    local itemLink = GetItemLink(BAG_BACKPACK, slotIndex)
    local itemIsContainer = IsItemLinkContainer(itemLink)
    if itemIsContainer then
      local containerId = Id64ToString(GetItemUniqueId(BAG_BACKPACK, slotIndex))
      foundContainers[containerId] = true
    end
  end

  return foundContainers
end

local function RemoveOldEntries()
  -- Step 3: Compare and remove missing items from SV
  local foundContainers = InventoryGetContainers()
  for containerId, containerData in pairs(ADDONSV["checkedContainers"]) do
    if not foundContainers[containerId] then
      ADDONSV["checkedContainers"][containerId] = nil
      LogDev("RemoveOldEntries", "Missing container ID was removed from SV: " .. tostring(containerId))
    elseif #containerData == 0 then
      ADDONSV["checkedContainers"][containerId] = nil
      LogDev("RemoveOldEntries", "Empty container ID was removed from SV: " .. tostring(containerId))
    end
  end
end

local function ForceUnregisterEvents()
  LogDev("ForceUnregisterEvents", "Unregister Loot Window events")
  EVENT_MANAGER:UnregisterForEvent(this.name, EVENT_LOOT_UPDATED)
  EVENT_MANAGER:UnregisterForEvent(this.name, EVENT_LOOT_CLOSED)
end

local function OnLootUpdated(containerId)
  LogDev("OnLootUpdated", "Loot Window Updated (" .. tostring(containerId) .. ")")

  ADDONSV["checkedContainers"][containerId] = {}

  local lootData = LOOT_SHARED:GetSortedLootData()
  for i, data in ipairs(lootData) do
    -- TODO: Change itemType to "Item", "Currency", "Lead" strings. Move "currencyType" to "itemData".
    local itemType = data.currencyType or data.itemType == LOOT_TYPE_ANTIQUITY_LEAD and "Lead" or 0
    local itemAmount
    local itemData

    if data.currencyType then
      itemAmount = data.currencyAmount
    elseif data.itemType == LOOT_TYPE_ANTIQUITY_LEAD then
      itemAmount = data.count
      itemData = GetLootAntiquityLeadId(data.lootId)
    else
      itemAmount = data.count
      itemData = GetLootItemLink(data.lootId)
    end

    table.insert(ADDONSV["checkedContainers"][containerId], {
      [1] = itemType,
      [2] = itemAmount,
      [3] = itemData,
    })
  end
end

local function OnLootClosed(callback)
  LogDev("OnLootClosed", "Loot Window closed")
  EVENT_MANAGER:UnregisterForEvent(this.name, EVENT_LOOT_UPDATED)
  EVENT_MANAGER:UnregisterForEvent(this.name, EVENT_LOOT_CLOSED)
  callback() -- update indicator icon in inventory list
end

local function AwaitLootData(containerId, callback)
  ForceUnregisterEvents() -- FIX: event race then previous container not opened coz empty or too many cristals
  EVENT_MANAGER:RegisterForEvent(this.name, EVENT_LOOT_UPDATED, function()
    OnLootUpdated(containerId)
  end)
  EVENT_MANAGER:RegisterForEvent(this.name, EVENT_LOOT_CLOSED, function()
    OnLootClosed(callback)
  end)
end

-- NOTE: It just works
local playerBackpack = PLAYER_INVENTORY.inventories[INVENTORY_BACKPACK].listView

-- Add Control and Indicator to Inventory List
local function InventoryAddIndicators(control, inventorySlot)
  local indicatorName = this.name .. "Indicator"
  local iconControl = control:GetNamedChild("Button")
  if not iconControl then return end

  -- Get or create addon indicator
  local indicator = iconControl:GetNamedChild(indicatorName)
  if not indicator then
    -- Create and initialize the indicator
    indicator = WINDOW_MANAGER:CreateControl(iconControl:GetName() .. indicatorName, iconControl, CT_TEXTURE)
    indicator:SetDimensions(32, 32)
    indicator:SetInheritScale(false)
    indicator:SetAnchor(CENTER)
    indicator:SetDrawTier(DT_HIGH)
    indicator:SetTexture("EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_equipped.dds")
    indicator:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, 1))
  end

  -- Get container UniqueId
  local containerId = Id64ToString(GetItemUniqueId(inventorySlot.bagId, inventorySlot.slotIndex))

  -- Set Visible if SV contains containerId
  if ADDONSV["checkedContainers"][containerId] then
    indicator:SetHidden(false)
  else
    indicator:SetHidden(true)
  end
end


-- Check Item and Add UniqueId to Storage
local function OnItemUse(inventorySlot, bagId, slotIndex)
  local itemLink = GetItemLink(bagId, slotIndex)
  local itemIsContainer = IsItemLinkContainer(itemLink)
  if itemIsContainer ~= true then return end

  local containerId = Id64ToString(GetItemUniqueId(bagId, slotIndex))

  -- start Events to record Loot in SV + wait for callback after Loot closes to update Indicator
  AwaitLootData(containerId, function()
    -- playerBackpack = playerBackpack or PLAYER_INVENTORY.inventories[INVENTORY_BACKPACK].listView
    ZO_ScrollList_RefreshVisible(playerBackpack, ZO_ScrollList_GetData(inventorySlot))
  end)
end


local function TooltipDisplayContent(control, bagId, slotIndex)
  local containerId = Id64ToString(GetItemUniqueId(bagId, slotIndex))
  local containerData = ADDONSV["checkedContainers"][containerId]
  if not containerData then return end
  if #containerData == 0 then return end -- do not change tooltip for empty containers

  -- Prepare text
  local itemList = {}
  for i, itemData in ipairs(containerData) do
    local icon
    local name

    if itemData[1] == "Lead" then
      local antiquityLeadName = zo_strformat(SI_ANTIQUITY_LEAD_NAME_FORMATTER, GetAntiquityName(itemData[3]))
      local antiquityLeadQuality = GetAntiquityQuality(itemData[3])
      local antiquityLeadQualityColorDef = GetAntiquityQualityColor(antiquityLeadQuality)
      icon = "/esoui/art/icons/quest_plans_001.dds"
      name = antiquityLeadQualityColorDef:Colorize(antiquityLeadName)
    else
      icon = itemData[1] > 0 and GetCurrencyLootGamepadIcon(itemData[1]) or GetItemLinkIcon(itemData[3])
      name = itemData[1] > 0 and GetCurrencyName(itemData[1]) or GetItemLinkName(itemData[3])
      local qualityColor = GetItemQualityColor(GetItemLinkDisplayQuality(itemData[3]))
      name = zo_strformat(SI_TOOLTIP_ITEM_NAME, qualityColor:Colorize(name))
    end

    table.insert(itemList, zo_strformat("<<1>> ×<<2>>", zo_iconTextFormat(icon, 20, 20, name), itemData[2]))
  end
  itemList = ZO_GenerateNewlineSeparatedList(itemList)

  -- Add texts to tooltip
  control:AddVerticalPadding(10)
  control:AddLine(GetString(SI_MODBROWSERLISTINGREPORTSOURCE4), "ZoFontWinT1") -- Title "Contents"
  control:AddLine(itemList, "ZoFontGameMedium", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true) -- Item list
end


local function Initialization()
  ADDONSV = ZO_SavedVars:NewCharacterIdSettings(this.sv, 1, nil, ADDONSV)

  -- Add hidden Indicators and start Inventory Hook
  if (playerBackpack and playerBackpack.dataTypes) then
    SecurePostHook(ZO_ScrollList_GetDataTypeTable(playerBackpack, 1), "setupCallback", InventoryAddIndicators)
  end

  -- Remove old SV entries on inventory closing
  local isInventoryOpen = false -- use an additional variable because opening containers forces the inventory to close.
  SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(scene, oldState)
    if scene:GetName() == "inventory" and oldState == SCENE_HIDDEN then
      isInventoryOpen = true
    elseif scene:GetName() == "hud" and oldState == SCENE_HIDDEN and isInventoryOpen then
      LogDev("InventoryStateChange", "Inventory closed")
      ForceUnregisterEvents() -- prevent the next open loot window from being registered as container loot in some cases
      RemoveOldEntries()
      isInventoryOpen = false
    end
  end)

  -- Handle Double-click AND Primary Action "E" in Inventory
  -- NOTE: "options" is ZO_InventorySlotActions object itself
  --       options.m_slotActions[1][2] contains TryUseItem() // so near and yet so far
  SecurePostHook(ZO_InventorySlotActions, "DoPrimaryAction", function(options)
    if IsInGamepadPreferredMode() then return end -- just to avoid problems since m_inventorySlot is empty
    local inventorySlot = ZO_InventorySlot_GetInventorySlotComponents(options.m_inventorySlot)
    -- It is necessary to check the cooldown, since the key can be pressed quickly 2-3 times before the container opens
    if not inventorySlot.inCooldown and options:GetPrimaryActionName(options) == GetString(SI_ITEM_ACTION_USE) then
      OnItemUse(inventorySlot, inventorySlot.bagId, inventorySlot.slotIndex)
    end
  end)


  -- Handle Right-click and then Use (PrimaryAction) // TODO: override orginal function

  -- Show content in tooltip
  ZO_PostHook(ItemTooltip, "SetBagItem", function(control, bagId, slotIndex)
    TooltipDisplayContent(control, bagId, slotIndex)
  end)


  SLASH_COMMANDS["/kci"] = function(extra)
    local options = {}
    local searchResult = { string.match(extra,"^(%S*)%s*(.-)$") }
    for i,v in pairs(searchResult) do
      if (v ~= nil and v ~= "") then
        options[i] = string.lower(v)
      end
    end

    if #options == 0 or options[1] == "help" then
      -- Display help
      d("[Kaleido Container Insight] Chat Commands:\n/kci show -- Displays checked containers data.\n/kci delete -- Resets all saved data for the addon.\n/kci help -- Shows list of available commands.\n/kci dev -- Toggles debug mode. Chat flood incoming!")
    elseif options[1] == "show" then
      d("[Kaleido Container Insight] Saved Variables:\n" .. LogTable(ADDONSV["checkedContainers"]))
    elseif options[1] == "delete" then
      ADDONSV["checkedContainers"] = {}
      d("[Kaleido Container Insight] Saved Variables has been cleared!")
    elseif options[1] == "dev" then
      if ADDONSV["devMode"] then
        ADDONSV["devMode"] = false
        d("[Kaleido Container Insight] Dev Mode is disabled!")
      else
        ADDONSV["devMode"] = true
        d("[Kaleido Container Insight] Dev Mode is enabled!")
      end
    end
  end
end


EVENT_MANAGER:RegisterForEvent(this.name, EVENT_ADD_ON_LOADED, function(event, addonName)
  if addonName ~= this.name then return end
  EVENT_MANAGER:UnregisterForEvent(this.name, EVENT_ADD_ON_LOADED)
  Initialization()
end)
