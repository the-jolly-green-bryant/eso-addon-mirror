JournalCompanion = JournalCompanion or {}
JournalCompanion.ChatLink = {}

-- Surfaces covered: player inventory, bank, subscriber bank, housing storage,
-- chat windows, guild history, mail, and trade windows.

local debugMode  = false
local pendingLink = nil  -- set when an inventory slot is right-clicked; consumed by ShowMenu hook

local function FormatGold(amount)
  if amount >= 1000000 then
    return string.format("%.1fm", amount / 1000000)
  elseif amount >= 1000 then
    return string.format("%.1fk", amount / 1000)
  else
    return tostring(math.floor(amount))
  end
end

local function BuildAndInsertMenuItem(link)
  local ok, price, sales = pcall(JournalCompanion.Pricing.LookupPrice, link)
  if not ok then price = nil end

  AddMenuItem("Link with Journal price", function()
    local text
    if price then
      local suffix = sales and (" (" .. sales .. " sold/wk)") or ""
      text = link .. " — Journal: " .. FormatGold(price) .. suffix
    else
      text = link
    end
    StartChatInput(text)
  end)

  local itemId = GetItemLinkItemId(link)
  if itemId and itemId ~= 0 then
    AddMenuItem("View on Journal market", function()
      RequestOpenUnsafeURL("https://journal.erros.gg/dashboard/market?id=" .. itemId)
    end)
  end
end

local function RegisterContextMenuHook()
  -- ZO_InventorySlot_ShowContextMenu calls ClearMenu() internally, which would
  -- wipe any item added by a ZO_PreHook.  Instead, we override the function to
  -- capture the item link before the original runs, then inject our menu entry
  -- in a ShowMenu pre-hook — after ClearMenu + standard items, right before display.
  local origShowContextMenu = ZO_InventorySlot_ShowContextMenu
  ZO_InventorySlot_ShowContextMenu = function(inventorySlot)
    if JournalCompanion.sv.chatLinkEnabled then
      local bagId     = inventorySlot.bagId
      local slotIndex = inventorySlot.slotIndex

      if not bagId and inventorySlot.slotData then
        bagId     = inventorySlot.slotData.bagId
        slotIndex = inventorySlot.slotData.slotIndex
      end

      if bagId and slotIndex then
        -- Real inventory slot: capture its link for the ShowMenu pre-hook.
        pendingLink = nil
        local link = GetItemLink(bagId, slotIndex)
        if link and link ~= "" then
          pendingLink = link
          if debugMode then
            d(string.format("|cC9A24AJournal ChatLink|r: captured inventory link bagId=%d slotIndex=%d", bagId, slotIndex))
          end
        end
      end
    end

    origShowContextMenu(inventorySlot)
  end

  -- Fires after ClearMenu + standard item additions, just before the menu shows.
  -- Handles the inventory slot path set up above.
  ZO_PreHook("ShowMenu", function()
    if debugMode then
      d("|cC9A24AJournal ChatLink|r: ShowMenu fired, pendingLink=" .. tostring(pendingLink))
    end
    if not pendingLink then return end
    local link = pendingLink
    pendingLink = nil

    if debugMode then d("|cC9A24AJournal ChatLink|r: injecting inventory menu item") end
    BuildAndInsertMenuItem(link)
  end)

  -- Right-clicks on item links in chat, guild history, mail, and other non-inventory
  -- surfaces fire LINK_MOUSE_UP_EVENT on mouse-up, after the base context menu has
  -- been committed.  Use zo_callLater (same pattern as MasterMerchant) to defer
  -- AddMenuItem + ShowMenu until the next update cycle so our item appends cleanly.
  if LINK_HANDLER and LINK_HANDLER.LINK_MOUSE_UP_EVENT then
    LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, function(rawLink, button, _, _, linkType)
      if button ~= MOUSE_BUTTON_INDEX_RIGHT then return end
      if not JournalCompanion.sv.chatLinkEnabled then return end
      if linkType ~= ITEM_LINK_TYPE then return end
      if not rawLink or rawLink == "" then return end

      if debugMode then
        d("|cC9A24AJournal ChatLink|r: LINK_MOUSE_UP_EVENT captured item link")
      end

      local link = rawLink
      zo_callLater(function()
        if debugMode then d("|cC9A24AJournal ChatLink|r: injecting link-surface menu item") end
        BuildAndInsertMenuItem(link)
        ShowMenu()
      end, 0)
    end)
  end
end

function JournalCompanion.ChatLink.SetDebug(v)
  debugMode = v
  d("|cC9A24AThe Journal Companion:|r chat link debug " .. (v and "on" or "off"))
end

function JournalCompanion.ChatLink.Init()
  if JournalCompanion.sv.chatLinkEnabled == nil then
    JournalCompanion.sv.chatLinkEnabled = true
  end

  if ZO_InventorySlot_ShowContextMenu then
    RegisterContextMenuHook()
  else
    d("|cC9A24AThe Journal Companion:|r ZO_InventorySlot_ShowContextMenu not found — chat links unavailable")
  end
end
