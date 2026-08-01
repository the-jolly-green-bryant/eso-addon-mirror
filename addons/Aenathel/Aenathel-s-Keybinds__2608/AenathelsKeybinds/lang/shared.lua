--[[
  This file is part of Aenathel's Keybinds, licensed under The MIT License.
  See the LICENSE file in the root of this project for more information.
--]]

ZO_CreateStringId("AEKB_ADDON_VERSION", "1.10.1")
ZO_CreateStringId("AEKB_ADDON_WEBSITE", "https://www.esoui.com/downloads/fileinfo.php?id=2608")

local function AEKB_CreateToggleStringId(code, panelStringId, tabStringId)
  local id = "SI_BINDING_NAME_AEKB_TOGGLE_" .. code
  local toggle = GetString(AEKB_TOGGLE)
  local panelTitle = GetString(panelStringId)
  local tabTitle = GetString(tabStringId)

  ZO_CreateStringId(id, string.format("%s %s > %s", toggle, panelTitle, tabTitle))
end

AEKB_CreateToggleStringId("COLLECTIONS_SETS", SI_MAIN_MENU_COLLECTIONS, SI_ITEM_SETS_BOOK_TITLE)

AEKB_CreateToggleStringId("GROUP_GROUP", SI_MAIN_MENU_GROUP, SI_MAIN_MENU_GROUP)
AEKB_CreateToggleStringId("GROUP_ENDEAVORS", SI_MAIN_MENU_GROUP, SI_ACTIVITY_FINDER_CATEGORY_TIMED_ACTIVITIES)
AEKB_CreateToggleStringId("GROUP_DUNGEON_FINDER", SI_MAIN_MENU_GROUP, SI_ACTIVITY_FINDER_CATEGORY_DUNGEON_FINDER)
AEKB_CreateToggleStringId("GROUP_BATTLEGROUNDS", SI_MAIN_MENU_GROUP, SI_ACTIVITY_FINDER_CATEGORY_BATTLEGROUNDS)

AEKB_CreateToggleStringId("GUILDS_HOME", SI_MAIN_MENU_GUILDS, SI_WINDOW_TITLE_GUILD_HOME)
AEKB_CreateToggleStringId("GUILDS_ROSTER", SI_MAIN_MENU_GUILDS, SI_WINDOW_TITLE_GUILD_ROSTER)

AEKB_CreateToggleStringId("INVENTORY_ITEMS", SI_MAIN_MENU_INVENTORY, SI_INVENTORY_MODE_ITEMS)
AEKB_CreateToggleStringId("INVENTORY_CRAFT_BAG", SI_MAIN_MENU_INVENTORY, SI_INVENTORY_MODE_CRAFT_BAG)
AEKB_CreateToggleStringId("INVENTORY_CURRENCY", SI_MAIN_MENU_INVENTORY, SI_INVENTORY_MODE_CURRENCY)

AEKB_CreateToggleStringId("JOURNAL_QUESTS", SI_MAIN_MENU_JOURNAL, SI_JOURNAL_MENU_QUESTS)
AEKB_CreateToggleStringId("JOURNAL_ANTIQUITIES", SI_MAIN_MENU_JOURNAL, SI_JOURNAL_MENU_ANTIQUITIES)
AEKB_CreateToggleStringId("JOURNAL_ACHIEVEMENTS", SI_MAIN_MENU_JOURNAL, SI_JOURNAL_MENU_ACHIEVEMENTS)

AEKB_CreateToggleStringId("MAP_QUESTS", SI_MAIN_MENU_MAP, SI_MAP_INFO_MODE_QUESTS)
AEKB_CreateToggleStringId("MAP_LOCATIONS", SI_MAIN_MENU_MAP, SI_MAP_INFO_MODE_LOCATIONS)
AEKB_CreateToggleStringId("MAP_HOUSES", SI_MAIN_MENU_MAP, SI_MAP_INFO_MODE_HOUSES)

local function AEKB_CreateWriteInChatStringId(code, channel)
  local id = "SI_BINDING_NAME_AEKB_WRITE_IN_CHAT_" .. code
  local channelString = type(channel) == "number" and GetString(channel) or channel
  local writeInChat = zo_strformat(GetString(AEKB_WRITE_IN_CHAT), channelString) 

  ZO_CreateStringId(id, writeInChat)
end

AEKB_CreateWriteInChatStringId("GROUP", SI_CHAT_CHANNEL_NAME_PARTY)
AEKB_CreateWriteInChatStringId("ZONE", SI_CHAT_CHANNEL_NAME_ZONE)

-- Creates GUILD_1 to GUILD_5
for i = 1, 5 do AEKB_CreateWriteInChatStringId("GUILD_" .. i, zo_strformat(SI_EMPTY_GUILD_CHANNEL_NAME, i)) end

