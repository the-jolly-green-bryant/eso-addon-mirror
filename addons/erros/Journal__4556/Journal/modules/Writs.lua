JournalCompanion.Writs = {}

-- ── Known writ reward containers ──────────────────────────────────────────────
-- Key: item ID (locale-safe, survives ZOS renames).
-- craft: internal identifier used by the web app.
-- tier:  0 = shipment (sub-box), 1-10 = primary writ reward box.
-- Source: Dolgubon's Lazy Writ Creator, LootHandler.lua (rewardBoxData).
local WRIT_BOXES = {
  -- Blacksmithing
  [57851]  = { craft = "blacksmithing", tier = 1  },
  [58131]  = { craft = "blacksmithing", tier = 2  },
  [58503]  = { craft = "blacksmithing", tier = 3  },
  [58504]  = { craft = "blacksmithing", tier = 4  },
  [58505]  = { craft = "blacksmithing", tier = 5  },
  [58506]  = { craft = "blacksmithing", tier = 6  },
  [58507]  = { craft = "blacksmithing", tier = 7  },
  [58508]  = { craft = "blacksmithing", tier = 8  },
  [58509]  = { craft = "blacksmithing", tier = 9  },
  [71234]  = { craft = "blacksmithing", tier = 10 },
  [121298] = { craft = "blacksmithing", tier = 10 },
  [142134] = { craft = "blacksmithing", tier = 0  },
  [142135] = { craft = "blacksmithing", tier = 0  },
  [142136] = { craft = "blacksmithing", tier = 0  },
  [142137] = { craft = "blacksmithing", tier = 0  },
  [142138] = { craft = "blacksmithing", tier = 0  },
  [142139] = { craft = "blacksmithing", tier = 0  },
  [142140] = { craft = "blacksmithing", tier = 0  },
  [142141] = { craft = "blacksmithing", tier = 0  },
  [142142] = { craft = "blacksmithing", tier = 0  },
  [142174] = { craft = "blacksmithing", tier = 0  },
  -- Clothing (cloth)
  [58519]  = { craft = "clothing", tier = 1  },
  [58520]  = { craft = "clothing", tier = 2  },
  [58521]  = { craft = "clothing", tier = 3  },
  [58522]  = { craft = "clothing", tier = 4  },
  [58523]  = { craft = "clothing", tier = 5  },
  [58524]  = { craft = "clothing", tier = 6  },
  [58525]  = { craft = "clothing", tier = 7  },
  [58526]  = { craft = "clothing", tier = 8  },
  [58527]  = { craft = "clothing", tier = 9  },
  [71233]  = { craft = "clothing", tier = 10 },
  [121297] = { craft = "clothing", tier = 10 },
  [142143] = { craft = "clothing", tier = 0  },
  [142144] = { craft = "clothing", tier = 0  },
  [142145] = { craft = "clothing", tier = 0  },
  [142146] = { craft = "clothing", tier = 0  },
  [142147] = { craft = "clothing", tier = 0  },
  [142148] = { craft = "clothing", tier = 0  },
  [142149] = { craft = "clothing", tier = 0  },
  [142150] = { craft = "clothing", tier = 0  },
  [142151] = { craft = "clothing", tier = 0  },
  [142176] = { craft = "clothing", tier = 0  },
  -- Clothing (leather)
  [147607] = { craft = "clothing", tier = 1  },
  [147608] = { craft = "clothing", tier = 2  },
  [147609] = { craft = "clothing", tier = 3  },
  [147610] = { craft = "clothing", tier = 4  },
  [147611] = { craft = "clothing", tier = 5  },
  [147612] = { craft = "clothing", tier = 6  },
  [147613] = { craft = "clothing", tier = 7  },
  [147614] = { craft = "clothing", tier = 8  },
  [147615] = { craft = "clothing", tier = 9  },
  [147616] = { craft = "clothing", tier = 10 },
  [142152] = { craft = "clothing", tier = 0  },
  [142153] = { craft = "clothing", tier = 0  },
  [142154] = { craft = "clothing", tier = 0  },
  [142155] = { craft = "clothing", tier = 0  },
  [142156] = { craft = "clothing", tier = 0  },
  [142157] = { craft = "clothing", tier = 0  },
  [142158] = { craft = "clothing", tier = 0  },
  [142159] = { craft = "clothing", tier = 0  },
  [142160] = { craft = "clothing", tier = 0  },
  [142177] = { craft = "clothing", tier = 0  },
  -- Enchanting
  [58528]  = { craft = "enchanting", tier = 1  },
  [58529]  = { craft = "enchanting", tier = 2  },
  [58530]  = { craft = "enchanting", tier = 3  },
  [58531]  = { craft = "enchanting", tier = 4  },
  [58532]  = { craft = "enchanting", tier = 5  },
  [58533]  = { craft = "enchanting", tier = 6  },
  [58534]  = { craft = "enchanting", tier = 7  },
  [59735]  = { craft = "enchanting", tier = 8  },
  [59736]  = { craft = "enchanting", tier = 9  },
  [71236]  = { craft = "enchanting", tier = 10 },
  [121300] = { craft = "enchanting", tier = 10 },
  -- Alchemy
  [59705]  = { craft = "alchemy", tier = 1 },
  [59706]  = { craft = "alchemy", tier = 2 },
  [59707]  = { craft = "alchemy", tier = 3 },
  [59708]  = { craft = "alchemy", tier = 4 },
  [59709]  = { craft = "alchemy", tier = 5 },
  [59710]  = { craft = "alchemy", tier = 6 },
  [71238]  = { craft = "alchemy", tier = 7 },
  [121302] = { craft = "alchemy", tier = 7 },
  -- Provisioning
  [59714]  = { craft = "provisioning", tier = 1 },
  [59715]  = { craft = "provisioning", tier = 1 },
  [59716]  = { craft = "provisioning", tier = 1 },
  [59717]  = { craft = "provisioning", tier = 2 },
  [59718]  = { craft = "provisioning", tier = 2 },
  [59719]  = { craft = "provisioning", tier = 2 },
  [59720]  = { craft = "provisioning", tier = 3 },
  [59721]  = { craft = "provisioning", tier = 3 },
  [59723]  = { craft = "provisioning", tier = 4 },
  [59724]  = { craft = "provisioning", tier = 5 },
  [59725]  = { craft = "provisioning", tier = 6 },
  [71237]  = { craft = "provisioning", tier = 7 },
  [121301] = { craft = "provisioning", tier = 7 },
  -- Woodworking
  [58510]  = { craft = "woodworking", tier = 1  },
  [58511]  = { craft = "woodworking", tier = 2  },
  [58512]  = { craft = "woodworking", tier = 3  },
  [58513]  = { craft = "woodworking", tier = 4  },
  [58514]  = { craft = "woodworking", tier = 5  },
  [58515]  = { craft = "woodworking", tier = 6  },
  [58516]  = { craft = "woodworking", tier = 7  },
  [58517]  = { craft = "woodworking", tier = 8  },
  [58518]  = { craft = "woodworking", tier = 9  },
  [71235]  = { craft = "woodworking", tier = 10 },
  [121299] = { craft = "woodworking", tier = 10 },
  [142161] = { craft = "woodworking", tier = 0  },
  [142162] = { craft = "woodworking", tier = 0  },
  [142163] = { craft = "woodworking", tier = 0  },
  [142164] = { craft = "woodworking", tier = 0  },
  [142165] = { craft = "woodworking", tier = 0  },
  [142166] = { craft = "woodworking", tier = 0  },
  [142167] = { craft = "woodworking", tier = 0  },
  [142168] = { craft = "woodworking", tier = 0  },
  [142169] = { craft = "woodworking", tier = 0  },
  [142175] = { craft = "woodworking", tier = 0  },
  -- Jewelry
  [138801] = { craft = "jewelry", tier = 1 },
  [138802] = { craft = "jewelry", tier = 2 },
  [138803] = { craft = "jewelry", tier = 3 },
  [138804] = { craft = "jewelry", tier = 4 },
  [138805] = { craft = "jewelry", tier = 5 },
  [142170] = { craft = "jewelry", tier = 0 },
  [142171] = { craft = "jewelry", tier = 0 },
  [142172] = { craft = "jewelry", tier = 0 },
  [142173] = { craft = "jewelry", tier = 0 },
  [147603] = { craft = "jewelry", tier = 0 },
}

-- Writ quest name fragments mapped to craft identifiers.
-- ESO uses practitioner names: "Woodworker Writ", "Blacksmith Writ", etc.
local WRIT_QUEST_MAP = {
  { pattern = "woodworker",        craft = "woodworking"   },
  { pattern = "blacksmith",        craft = "blacksmithing" },
  { pattern = "clothier",          craft = "clothing"      },
  { pattern = "alchemist",         craft = "alchemy"       },
  { pattern = "provisioner",       craft = "provisioning"  },
  { pattern = "enchanter",         craft = "enchanting"    },
  { pattern = "jewelry crafting",  craft = "jewelry"       },
}

-- ── State ─────────────────────────────────────────────────────────────────────

-- How long after quest completion to associate a box opening with that quest.
-- Writ Helper opens boxes immediately, but we allow a generous manual window.
local QUEST_BOX_WINDOW  = 300  -- seconds
local COMMIT_DELAY_MS   = 500  -- fallback commit if EVENT_LOOT_CLOSED never fires

local debugMode       = false
local activeSession   = nil  -- set when a known box arrives in inventory
local pendingQuests   = {}   -- queue of { name, craft, t, gold }
local commitGen       = 0    -- incremented each commit; cancels stale zo_callLater timers

-- ── Helpers ───────────────────────────────────────────────────────────────────

local function Log(msg)
  if debugMode then
    d(string.format("|cC9A24A[Journal Writs]|r %s", msg))
  end
end

local function CraftFromQuestName(name)
  if not name then return nil end
  local lower = zo_strlower(name)
  for _, entry in ipairs(WRIT_QUEST_MAP) do
    if lower:find(entry.pattern, 1, true) then
      return entry.craft
    end
  end
  return nil
end

-- Shared save logic: strip delivery box if present, merge quest gold, then persist.
local function CommitSession()
  commitGen = commitGen + 1  -- cancel any pending zo_callLater timer
  if not activeSession then return end

  -- Strip the source box from items if it's there — it's a delivery artifact.
  for i, item in ipairs(activeSession.items) do
    if item.itemId == activeSession.itemId then
      table.remove(activeSession.items, i)
      Log("CommitSession: stripped delivery box from items")
      break
    end
  end

  -- Merge the most recent matching pending quest.
  local now = GetTimeStamp()
  for i, q in ipairs(pendingQuests) do
    if q.craft == activeSession.craft and now - q.t <= QUEST_BOX_WINDOW then
      activeSession.quest = q.name
      activeSession.gold  = q.gold or 0
      Log(string.format("CommitSession: merged quest '%s' (%dg)", q.name, activeSession.gold))
      table.remove(pendingQuests, i)
      break
    end
  end

  local count = #activeSession.items
  Log(string.format("CommitSession — saving (%d items, %dg box gold, %dg quest gold)",
    count, activeSession.boxGold or 0, activeSession.gold or 0))

  if count > 0 or (activeSession.gold or 0) > 0 or (activeSession.boxGold or 0) > 0 then
    local sv = JournalCompanion.sv
    sv.writ_rewards[#sv.writ_rewards + 1] = activeSession
  end

  activeSession = nil
end

-- Schedule a fallback commit in case EVENT_LOOT_CLOSED never fires (Writ Helper
-- auto-loots everything and dismisses the window without raising the close event).
-- Only called for non-box items (contents window) to avoid firing during delivery window.
local function ScheduleCommit()
  local gen = commitGen + 1
  commitGen = gen
  zo_callLater(function()
    if gen == commitGen and activeSession then
      Log("Timer: EVENT_LOOT_CLOSED did not fire — committing session")
      CommitSession()
      d("|cC9A24AThe Journal Companion:|r Writ recorded — ready for next turn-in.")
    end
  end, COMMIT_DELAY_MS)
end

-- ── Event: inventory slot changed ────────────────────────────────────────────
-- Start a session the moment a known writ box arrives in the backpack (isNew=true).
-- This fires before EVENT_LOOT_RECEIVED, so activeSession is set in time to capture items.

local function OnSlotUpdate(_, bagId, slotIndex, isNew)
  if bagId ~= BAG_BACKPACK or not isNew then return end
  local itemId = GetItemId(bagId, slotIndex)
  if not itemId or itemId == 0 then return end
  local box = WRIT_BOXES[itemId]
  if not box then return end

  Log(string.format("Writ box received: itemId=%d craft=%s tier=%d", itemId, box.craft, box.tier))

  if activeSession then
    Log("Previous session still open — closing early to start new box session")
    CommitSession()
  end

  activeSession = {
    t       = GetTimeStamp(),
    char    = GetUnitName("player"),
    account = GetDisplayName(),
    kind    = "box",
    itemId  = itemId,
    craft   = box.craft,
    tier    = box.tier,
    items   = {},
  }
end

-- ── Event: item looted ────────────────────────────────────────────────────────

-- Parameters: eventCode, receivedBy, itemName, quantity, itemSound,
--             lootType, self, isPickpocketLoot, questConstrainedLoot, itemId
local function OnLootReceived(_, _, itemName, quantity, _, lootType, isSelf, _, _, itemId)
  Log(string.format("Loot received: type=%s self=%s id=%s name=%s qty=%d",
    tostring(lootType), tostring(isSelf), tostring(itemId), tostring(itemName), quantity or 0))

  if not isSelf or not activeSession then return end

  if lootType == LOOT_TYPE_ITEM then
    activeSession.items[#activeSession.items + 1] = {
      name   = itemName,
      itemId = itemId,
      qty    = quantity,
    }
    Log(string.format("  → recorded itemId=%s qty=%d", tostring(itemId), quantity or 0))
    -- Schedule fallback commit only for contents items (not the delivery box itself).
    -- EVENT_LOOT_CLOSED may not fire when Writ Helper auto-loots the window.
    if itemId ~= activeSession.itemId then
      ScheduleCommit()
    end
  elseif lootType == LOOT_TYPE_MONEY then
    activeSession.boxGold = (activeSession.boxGold or 0) + (quantity or 0)
    Log(string.format("  → recorded %dg from box", quantity or 0))
    ScheduleCommit()
  end
end

-- ── Event: loot window closed ─────────────────────────────────────────────────

local function OnLootClosed()
  if not activeSession then return end

  -- ESO delivers the box via a quest-reward loot window, so the box item itself
  -- appears in loot received. If we see the source box among the looted items
  -- and no box gold was awarded, this was the delivery window — remove the box
  -- and keep the session open for the contents window Writ Helper will open.
  if (activeSession.boxGold or 0) == 0 then
    for i, item in ipairs(activeSession.items) do
      if item.itemId == activeSession.itemId then
        table.remove(activeSession.items, i)
        Log("Box delivery window closed — keeping session open for contents")
        return
      end
    end
  end

  Log("Loot closed — committing session")
  CommitSession()
  d("|cC9A24AThe Journal Companion:|r Writ recorded — ready for next turn-in.")
end

-- ── Flush expired quests ──────────────────────────────────────────────────────
-- Save a gold-only record for any quest whose box window has elapsed without
-- a matching box being opened (e.g. the player deferred opening).

local function FlushExpiredQuests()
  local now      = GetTimeStamp()
  local sv       = JournalCompanion.sv
  local surviving = {}
  for _, q in ipairs(pendingQuests) do
    if now - q.t > QUEST_BOX_WINDOW then
      if (q.gold or 0) > 0 then
        Log(string.format("Quest window expired — saving gold-only record for '%s' (%dg)",
          q.name, q.gold))
        sv.writ_rewards[#sv.writ_rewards + 1] = {
          t       = q.t,
          char    = GetUnitName("player"),
          account = GetDisplayName(),
          kind    = "quest_gold",
          quest   = q.name,
          craft   = q.craft,
          gold    = q.gold,
        }
      end
    else
      surviving[#surviving + 1] = q
    end
  end
  pendingQuests = surviving
end

-- ── Event: quest completion dialog ───────────────────────────────────────────
-- Fires before the quest is turned in, so the quest is still in the journal
-- and GetJournalQuestRewardInfo can be used to read the gold reward directly.

local function OnQuestCompleteDialog(_, journalIndex)
  local questName = GetJournalQuestName(journalIndex)
  local craft = CraftFromQuestName(questName)
  if not craft then return end

  local gold = 0
  for i = 1, GetJournalQuestNumRewards(journalIndex) do
    local rewardType, _, amount = GetJournalQuestRewardInfo(journalIndex, i)
    if rewardType == REWARD_TYPE_MONEY then
      gold = amount
      break
    end
  end

  FlushExpiredQuests()
  Log(string.format("Quest dialog: '%s' craft=%s gold=%dg", questName, craft, gold))
  pendingQuests[#pendingQuests + 1] = { name = questName, craft = craft, t = GetTimeStamp(), gold = gold }
end

-- ── Event: quest completed ────────────────────────────────────────────────────
-- Gold is already captured in OnQuestCompleteDialog; this only flushes stale entries.

local function OnQuestComplete(_, questName)
  Log("Quest complete: " .. tostring(questName))
  FlushExpiredQuests()
end

-- ── Public API ────────────────────────────────────────────────────────────────

function JournalCompanion.Writs.SetDebug(on)
  debugMode = on
  d(string.format("|cC9A24AThe Journal Companion:|r Writ debug %s", on and "ON" or "OFF"))
end

function JournalCompanion.Writs.Status()
  local sv = JournalCompanion.sv
  d(string.format("|cC9A24AThe Journal Companion:|r Writ rewards recorded: %d", #sv.writ_rewards))
end

function JournalCompanion.Writs.Init()
  local ns = JournalCompanion.name .. "_Writs"
  EVENT_MANAGER:RegisterForEvent(ns, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnSlotUpdate)
  EVENT_MANAGER:RegisterForEvent(ns, EVENT_LOOT_RECEIVED,                OnLootReceived)
  EVENT_MANAGER:RegisterForEvent(ns, EVENT_LOOT_CLOSED,                  OnLootClosed)
  EVENT_MANAGER:RegisterForEvent(ns, EVENT_QUEST_COMPLETE_DIALOG,        OnQuestCompleteDialog)
  EVENT_MANAGER:RegisterForEvent(ns, EVENT_QUEST_COMPLETE,               OnQuestComplete)
end
