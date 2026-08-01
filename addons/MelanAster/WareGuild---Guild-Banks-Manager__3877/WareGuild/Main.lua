local WG = SDC_WareGuild

WG.name = "WareGuild"
WG.title = "WareGuild"
WG.author = "@MelanAster"
WG.version = "0.23"

--Default Setting
WG.Default = {
  CV = false,
  
  AutoOpen = false,
  ForceOpen = false,
  AutoClose = true,
  
  KeepCraft = true,
  NE_Take = false,
  NE_Store = false,
  Log = true,
  
  Guild = {},
  Guild1 = {},
  Guild2 = {},
  Guild3 = {},
  Guild4 = {},
  Guild5 = {},
  
  AutoCraftBag = nil,
  IgnoreInventory = false,
  
  IgnoreFCOIS = false,
}

--Structure of Rules Stored in GuildX
--[[
{
  [GuildId] = Num,
  [Type] = StepType,
  [ItemId] = Num,
  [ItemLink] = String,
  [Count] = Num,
}
]]

-------------------
----Start point----
-------------------
local function OnAddOnLoaded(eventCode, addonName)
  --when addon loaded
  if addonName ~= WG.name then return end
  EVENT_MANAGER:UnregisterForEvent(WG.name, EVENT_ADD_ON_LOADED)
  
  --Restore from saved setting
  WG.AV = ZO_SavedVars:NewAccountWide("WareGuild_SaveVars", 1, nil, WG.Default, GetWorldName())
  WG.CV = ZO_SavedVars:NewCharacterIdSettings("WareGuild_SaveVars", 1, nil, WG.Default, GetWorldName())
  WG.SwitchSV()

  --CallBack
  SCENE_MANAGER:RegisterCallback("SceneStateChanged", WG.InteractCore)
  
  --LAM
  WG.BuildMenu()
end

--Character Setting?
function WG.SwitchSV()
  --Account/Character
  if WG.CV.CV then
    WG.SV = WG.CV
  else
    WG.SV = WG.AV
  end
end

----------------
----Interact----
----------------

--When open interact
function WG.InteractCore(scene, _, newstate)
  --Interact?
  if newstate ~= SCENE_SHOWN then return end
  if scene.name ~= "gamepadInteract" and scene.name ~= "interact" then return end
  
  --Bank NPC Interact?
  local Type
  local OptionNum = GetChatterOptionCount() + 2
  local Open = function()
    SCENE_MANAGER:RegisterCallback("SceneStateChanged", WG.GuildBankCore)
    SelectChatterOption(2)
  end

    --PC
  if SCENE_MANAGER:IsShowing("interact") then
    local control = WINDOW_MANAGER:GetControlByName("ZO_ChatterOption2")
    Type = control.optionType
    if Type ~= 3300 then return end
    INTERACTION:PopulateChatterOption(OptionNum, Open, "WareGuild", 600)
    INTERACTION:FinalizeChatterOptions(OptionNum)
  else
    --gamepad
    if not SCENE_MANAGER:IsShowing("gamepadInteract") then return end
    Type = GAMEPAD_INTERACTION.itemList.dataList[2].optionType
    if Type ~= 3300 then return end
    local entry = GAMEPAD_INTERACTION:GetChatterOptionData(Open, "WareGuild", 600, 0, false, false, 0)
    GAMEPAD_INTERACTION.itemList:AddEntry("ZO_ChatterOption_Gamepad", entry)
    GAMEPAD_INTERACTION:FinalizeChatterOptions(OptionNum)
  end
  
  --AutoOpen
  if WG.ShouldOpenGuildBank() then
    zo_callLater(Open, 200)
  end
end

--Hold Craft Writs?
local function HaveWrits()
  for a = 1, 25 do
    local Type = select(10, GetJournalQuestInfo(a)) 
    if Type == 4 then return true end
  end
  return false
end

--Should Open Guild Bank?
function WG.ShouldOpenGuildBank()
  local Step = WG.AllGuildStep()
  for i = 1, #Step do
    local Type = Step[i]["Type"]
    --When Daily Craft
    if WG.SV.ForceOpen and Type == WAREGUILD_DAILY and HaveWrits() then return true end
    --Have Something to Store
    if WG.SV.AutoOpen then
      if Type == WAREGUILD_STORE_ALL and WG.FindItem(1, Step[i]["ItemId"], Step[i]["ItemLink"]) then return true end
      if Type < 10 and WG.FindItemType(Type)[1] then return true end
    end
  end
  return false
end

---------------------
----Tool function----
---------------------

--Id to Link
local function ToLink(Id)
  return "|H1:item:"..Id..":30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
end

--ItemLink to [ItemLink]
local function ToBracket(ItemLink)
  if not ItemLink then return nil end
  return ItemLink:gsub("|H0:", "|H1:")
end

--Total Step of All Guilds
function WG.AllGuildStep()
  local Tep = {}
  local Guild = {WG.SV.Guild1, WG.SV.Guild2, WG.SV.Guild3, WG.SV.Guild4, WG.SV.Guild5}
  for a = 1, #Guild do
    for b = 1, #Guild[a] do
      table.insert(Tep, Guild[a][b])
    end
  end
  return Tep
end

----------------------------------------------
--For Addon (FCOIS ItemSaver)
local function FCOISAllow(bagId, slotIndex)
  --No Need to Do
  if WG.SV.IgnoreFCOIS then return true end
  if not FCOIS then return true end
  --Backbag
  if bagId == 1 then
    return not FCOIS.IsGuildBankDepositLocked(bagId, slotIndex)
  end
  --GuildBank
  if bagId == 3 then
    return not FCOIS.IsGuildBankWithdrawLocked(bagId, slotIndex)
  end
end

--Patch for Bug of ItemLink in Guild Bank
local function DoesItemMatch(Link, ItemId, ItemLink)
  --No Link Get
  if not Link or Link == "" then return false end
  
  --Normal Match
  if Link == ItemLink or GetItemLinkItemId(Link) == ItemId then return true end

  --Patch for InternalLevel
  if ItemLink then
    local F_1, I_1, A_1 = string.match(Link, "(item:%d+:%d+):(%d+):(.+)")
    local F_2, I_2, A_2 = string.match(ItemLink, "(item:%d+:%d+):(%d+):(.+)")
    if I_1 == "0" or I_1 == "1" or I_2 == "0" or I_2 == "1" then
      if F_1 == F_2 and A_1 == A_2 then return true end
    end
  end

  --Nothing Match
  return false
end

--CORE: Find Item Slot
function WG.FindItem(BagId, ItemId, ItemLink)
  local Slot = {}
  local Total = 0
  
  --BackBag
  if BagId == 1 then
    for i = 0, GetBagSize(1) do
      local Link = GetItemLink(1, i)
      if not IsItemLinkStolen(Link) and FCOISAllow(1, i) and DoesItemMatch(Link, ItemId, ItemLink) then
        local count = select(2, GetItemInfo(1, i))
        Total = Total + count
        table.insert(Slot, {["BagId"] = 1, ["SlotId"] = i, ["Count"] = count})
      end
    end

  --Current Guild Bank
  elseif BagId == 3 then
    local StartPoint = GetNextGuildBankSlotId()
    for i = StartPoint, StartPoint + 500 do
      local Link = GetItemLink(3, i)
      if FCOISAllow(3, i) and DoesItemMatch(Link, ItemId, ItemLink) then
        local count = select(2, GetItemInfo(3, i))
        Total = Total + count
        table.insert(Slot, {["BagId"] = 3, ["SlotId"] = i, ["Count"] = count})
      end
    end
  end
  
  --Resort by Stack Count
  table.sort(
    Slot,
    function(a, b)
      if BagId == 1 then return a["Count"] > b["Count"] end
      if BagId == 3 then return a["Count"] < b["Count"] end
    end
  )
  
  --TotalCount
  Slot["Total"] = Total
  
  return Slot
end

--Find Craft Materials Slot
function WG.FindItemType(CraftType)
  local Slot = {}
  for i = 0, GetBagSize(1) do
    local ItemLink = GetItemLink(1, i)
    local SkillType = GetItemLinkCraftingSkillType(ItemLink)
    local Fliter1, Fliter2 = GetItemLinkFilterTypeInfo(ItemLink)
    if not IsItemLinkStolen(ItemLink) and FCOISAllow(1, i) and Fliter1 == ITEMFILTERTYPE_CRAFTING then
      if CraftType == SkillType or
        (CraftType == 8 and Fliter2 == ITEMFILTERTYPE_STYLE_MATERIALS) or
        (CraftType == 9 and Fliter2 == ITEMFILTERTYPE_TRAIT_ITEMS)
      then
        table.insert(Slot, {["BagId"] = 1, ["SlotId"] = i})
      end
    end
  end
  return Slot
end

--Step To String
function WG.StepToString(Step)
  local Type = Step.Type
  local Craft = {WG.Lang.BLACKSMITH, WG.Lang.CLOTH, WG.Lang.ENCHANT, WG.Lang.ALCHEMY, WG.Lang.COOK, WG.Lang.WOOD, WG.Lang.JEWELRY, WG.Lang.STYLE, WG.Lang.TRAIT}
  if Type < 10 then 
    local String = "|t25:25:esoui/art/treeicons/gamepad/gp_esoplussub_increasedbankspace.dds|t "
    String = String..zo_strformat(WG.Lang.CHAT_STORE_ALL_TYPE, Craft[Type])
    return String
  end
  if Type == WAREGUILD_TAKE_TO then 
    local String = "|t25:25:esoui/art/tooltips/icon_bag.dds|t "
    String = String..zo_strformat(WG.Lang.CHAT_TAKE_TO, ToBracket(Step.ItemLink) or ToLink(Step.ItemId)..WG.Lang.CHAT_FUZZY, Step.Count)
    return String
  end
  if Type == WAREGUILD_TAKE_ALL then
    local String = "|t25:25:esoui/art/tooltips/icon_bag.dds|t "
    String = String..zo_strformat(WG.Lang.CHAT_TAKE_ALL, ToBracket(Step.ItemLink) or ToLink(Step.ItemId)..WG.Lang.CHAT_FUZZY)
    return String
  end
  if Type == WAREGUILD_STORE_TO then
    local String = "|t25:25:esoui/art/treeicons/gamepad/gp_esoplussub_increasedbankspace.dds|t "
    String = String..zo_strformat(WG.Lang.CHAT_STORE_TO, ToBracket(Step.ItemLink) or ToLink(Step.ItemId)..WG.Lang.CHAT_FUZZY, Step.Count)
    return String
  end
  if Type == WAREGUILD_STORE_ALL then
    local String = "|t25:25:esoui/art/treeicons/gamepad/gp_esoplussub_increasedbankspace.dds|t "
    String = String..zo_strformat(WG.Lang.CHAT_STORE_ALL, ToBracket(Step.ItemLink) or ToLink(Step.ItemId)..WG.Lang.CHAT_FUZZY)
    return String
  end
  if Type == WAREGUILD_DAILY then 
    return "|t25:25:esoui/art/tooltips/icon_bag.dds|t "..WG.Lang.CHAT_DAILY_WRITS
  end
  return WG.Lang.CHAT_ERROR
end

--Should Stack?
local function NotFull(SlotId)
  local Now, Max = GetSlotStackSize(1, SlotId)
  return Now < Max
end

local function ShouldStack()
  for a = 0, GetBagSize(1) do
    local ItemLink = GetItemLink(1, a)
    if ItemLink ~= "" and NotFull(a) then
      for b = a + 1, GetBagSize(1) do
        if ItemLink == GetItemLink(1, b) and NotFull(b) then
          return true, ItemLink
        end
      end
    end
  end
  return false
end

--Stack Item
local function StackItem(SlotIdList, Fun)
  local NewList = {}
  for i = 1, #SlotIdList do
    local Count, Max = GetSlotStackSize(1, SlotIdList[i]["SlotId"])
    if Count > 0 and Count < Max then
      table.insert(NewList, SlotIdList[i])
    end
  end
  --Done?
  if NewList[2] == nil then WG.Stack(Fun) return end
  --Move
  EVENT_MANAGER:RegisterForEvent(WG.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, 
    function(_, BagId, SlotId, IsNew, _, _, NumChange)
      if NumChange > 0 then return end
      EVENT_MANAGER:UnregisterForEvent(WG.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
      StackItem(NewList, Fun)
    end
  )
  CallSecureProtected("RequestMoveItem", 1, NewList[#NewList]["SlotId"], 1, NewList[1]["SlotId"], -1)
end

--Stack Core
function WG.Stack(Fun)
  local UnDone, ItemLink = ShouldStack()
  if UnDone then
    local List = {}
    for i = 0, GetBagSize(1) do
      if ItemLink == GetItemLink(1, i) then
        local Now, Max = GetSlotStackSize(1, i)
        if Now < Max then
          table.insert(List, {["SlotId"] = i, ["Count"] = Now})
        end
      end
    end
    table.sort(List,
    function(a, b)
      return a["Count"] > b["Count"]
    end
    )
    StackItem(List, Fun)
  else
    return Fun()
  end
end

-----------------
----Bank Core----
-----------------

local Step = {--[[
  {
    [GuildId] = Num,
    [Type] = StepType,
    [ItemId] = Num,
    [ItemLink] = String,
    [Count] = Num,
  }
]]}
local Queue = {--[[
  {
    [Type] = QueueType,
    [SlotId] = Num,
    *[Count] = Num,
  }
]]}

local Close = false

--When open GuildBank
function WG.GuildBankCore(scene, _, newstate)
  --GuildBank?
  if scene.name == "bank" or scene.name == "gamepad_banking" then WG.GuildBankEnd() return end
  if scene.name ~= "gamepad_guild_bank" and scene.name ~= "guildBank" then return end

  --When Close
  if newstate == SCENE_HIDING then 
    WG.GuildBankEnd()
    StackBag(BAG_BACKPACK)
  end
  
  --When Open
  if newstate ~= SCENE_SHOWN then return end
    --Start to Set Work 
  Step = WG.AllGuildStep()
  if WG.SV.KeepCraft and HaveWrits() then
    for i = 1, #Step do
      if Step[i]["Type"] < 10 or Step[i]["Type"] == WAREGUILD_STORE_ALL or Step[i]["Type"] == WAREGUILD_STORE_TO then
        Step[i] = "Skip"
      end
    end
  end
  --Turn off Auto Craft Bag
  WG.CV.AutoCraftBag = GetSetting(SETTING_TYPE_LOOT, 4)
  SetSetting(SETTING_TYPE_LOOT, 4, 0)
  
  EVENT_MANAGER:RegisterForEvent(WG.name, EVENT_GUILD_BANK_ITEMS_READY, 
    function()
      EVENT_MANAGER:UnregisterForEvent(WG.name, EVENT_GUILD_BANK_ITEMS_READY)
      WG.GuildBankWork(false)
    end
  )
  Close = false
end

--Analyze each step and make queue
function WG.GuildBankWork(DoRemove)
  --Last Step Done
  if DoRemove then
    --Display Step
    if WG.SV.Log then d("["..GetGuildName(GetSelectedGuildBankId()).."] "..WG.StepToString(Step[1])) end
    --Stack if need
    if ShouldStack() then
      WG.Stack(function() table.remove(Step, 1) WG.GuildBankWork(false) end)
      return
    else
      table.remove(Step, 1)
    end
  end

  --Skip
  if Step[1] == "Skip" then
    table.remove(Step, 1)
    WG.GuildBankWork(false)
    return
  end

  --Step All Done?
  if Step[1] == nil then
    if Close then 
      d("[WareGuild] "..WG.Lang.CHAT_DONE)
    else
      d("[WareGuild] "..WG.Lang.CHAT_NO_WORK)
    end
    WG.GuildBankEnd()
    return 
  end

  --Try Stack When No Free Slots in Backbag
  if GetNumBagFreeSlots(BAG_BACKPACK) == 0 then
    if ShouldStack() then
      WG.Stack(function() WG.GuildBankWork(false) end)
    else
      d("[WareGuild] "..WG.Lang.CHAT_STOP)
      d("[WareGuild] "..WG.Lang.CHAT_BACKBAG_FULL)
      Close = false
      WG.GuildBankEnd()
    end
    return
  end

  local bank = Step[1]
  
  --SelectGuild with stack
  if GetSelectedGuildBankId() ~= bank.GuildId then
    EVENT_MANAGER:RegisterForEvent(WG.name, EVENT_GUILD_BANK_ITEMS_READY, 
      function()
        EVENT_MANAGER:UnregisterForEvent(WG.name, EVENT_GUILD_BANK_ITEMS_READY)
        WG.GuildBankWork(false)
      end
    )
    SelectGuildBank(bank.GuildId)
    return
  end

--AnalyzeStep
  --CraftStore
  if bank.Type < 10 then
    local Slot = WG.FindItemType(bank.Type)
    for i = 1, #Slot do
      local Tep = {
        ["Type"] = WAREGUILD_QUEUE_STORE,
        ["SlotId"] = Slot[i]["SlotId"],
      }
      table.insert(Queue, Tep)
    end
  end
  
  --ItemTake
  if bank.Type > 10 and bank.Type < 20 then
    local Slot = WG.FindItem(3, bank.ItemId, bank.ItemLink)
    --TakeAll
    if bank.Type == WAREGUILD_TAKE_ALL then
      for i = 1, #Slot do
        local Tep = {
          ["Type"] = WAREGUILD_QUEUE_TAKE,
          ["SlotId"] = Slot[i]["SlotId"],
        }
        table.insert(Queue, Tep)
      end
    end
    --TakeTo
    if bank.Type == WAREGUILD_TAKE_TO then
      local BagSlot = WG.FindItem(1, bank.ItemId, bank.ItemLink)
      local ToTake = bank.Count - BagSlot["Total"]
      --Need to take
      if ToTake > 0 then
        --Not Enough Items
        if ToTake > Slot["Total"] then
          d(zo_strformat(
              WG.Lang.CHAT_NE_TAKE, 
              GetGuildName(GetSelectedGuildBankId()), 
              bank.ItemLink or ToLink(bank.ItemId)..WG.Lang.CHAT_FUZZY
            )
          )
          if Slot["Total"] ~= 0 and WG.SV.NE_Take then
            Step[1]["Type"] = WAREGUILD_TAKE_ALL
          else
            table.remove(Step, 1)
          end
          WG.GuildBankWork(false)
          return
        end
        --Take Items
        for i = 1, #Slot do
          if ToTake <= 0 then break end
          local Tep = {
              ["Type"] = WAREGUILD_QUEUE_TAKE,
              ["SlotId"] = Slot[i]["SlotId"],
            }
          table.insert(Queue, Tep)
          ToTake = ToTake - Slot[i]["Count"]
        end
      end
      --Need to Store Back
      if ToTake < 0 then
        table.insert(Step, 2, {
              ["GuildId"] = bank.GuildId,
              ["Type"] = WAREGUILD_STORE_TO,
              ["ItemId"] = bank.ItemId,
              ["ItemLink"] = bank.ItemLink,
              ["Count"] = Slot["Total"] + BagSlot["Total"] - bank.Count,
            })
      end
    end
  end
  
  --ItemStore
  if bank.Type > 20 and bank.Type < 30 then
    local Slot = WG.FindItem(1, bank.ItemId, bank.ItemLink)
    --StoreAll
    if bank.Type == WAREGUILD_STORE_ALL then
      for i = 1, #Slot do
        local Tep = {
          ["Type"] = WAREGUILD_QUEUE_STORE,
          ["SlotId"] = Slot[i]["SlotId"],
        }
        table.insert(Queue, Tep)
      end
    end
    if bank.Type == WAREGUILD_STORE_TO then
      local BankSlot = WG.FindItem(3, bank.ItemId, bank.ItemLink)
      local ToStore = bank.Count - BankSlot["Total"]
      --Need to Store
      if ToStore > 0 then
        --Not Enough Items
        if ToStore > Slot["Total"] then
          d(zo_strformat(
              WG.Lang.CHAT_NE_STORE,
              GetGuildName(GetSelectedGuildBankId()),
              bank.ItemLink or ToLink(bank.ItemId)..WG.Lang.CHAT_FUZZY
            )
          )
          if Slot["Total"] ~= 0 and WG.SV.NE_Store then
            Step[1]["Type"] = WAREGUILD_STORE_ALL
          else
            table.remove(Step, 1)
          end
          WG.GuildBankWork(false)
          return
        end
        --To Store
        for i = 1, #Slot do
          ToStore = ToStore - Slot[i]["Count"]
          if ToStore < 0 then
            local Tep = {
                ["Type"] = WAREGUILD_QUEUE_SPLIT,
                ["SlotId"] = Slot[i]["SlotId"],
                ["Count"] = -ToStore,
              }
            table.insert(Queue, Tep)
            ToStore = 0
          end
          local Tep = {
              ["Type"] = WAREGUILD_QUEUE_STORE,
              ["SlotId"] = Slot[i]["SlotId"],
            }
          table.insert(Queue, Tep)
          if ToStore == 0 then break end
        end
      end
      --Turn to Take
      if ToStore < 0 then
        Step[1]["Type"] = WAREGUILD_TAKE_TO
        Step[1]["Count"] = Slot["Total"] + BankSlot["Total"] - bank.Count
        WG.GuildBankWork(false)
        return
      end
    end
  end
  
  --CraftTake
  if bank.Type > 30 then
    local Materials = WG.FindDailyItem()
    for i = 1, #Materials do
      local Tep = {
        ["GuildId"] = bank.GuildId,
        ["Type"] = WAREGUILD_TAKE_TO,
        ["ItemLink"] = Materials[i]["ItemLink"],
        ["ItemId"] = Materials[i]["ItemId"],
        ["Count"] = Materials[i]["Count"],
      }
      table.insert(Step, 2, Tep)
    end
  end
  
--Add Queue EndPoint
  table.insert(Queue, "Done")
  WG.GuildBankQueue(false)
  return
end

--Do take&Store
function WG.GuildBankQueue(Event)
--DoneWithQueue
  if Event then
    table.remove(Queue, 1)
  end

--DoneWithStep
  if Queue[1] == "Done" then 
    table.remove(Queue, 1)
    WG.GuildBankWork(true)
    return
  end

--Really to do sth
  if not Close then
    if SCENE_MANAGER:IsShowing("guildBank") then GUILD_BANK_FRAGMENT:Hide() end
    if SCENE_MANAGER:IsShowing("gamepad_guild_bank") then GAMEPAD_GUILD_BANK_FRAGMENT:Hide() end
  end
  
  Close = true

--DoQueue
  local Target = Queue[1]
  --Take
  if Target.Type == WAREGUILD_QUEUE_TAKE then
    --Free slot?
    if GetNumBagFreeSlots(BAG_BACKPACK) == 0 then
      if ShouldStack() then
        WG.Stack(function() WG.GuildBankQueue(false) end)
      else
        d("[WareGuild] "..WG.Lang.CHAT_STOP)
        d("[WareGuild] "..WG.Lang.CHAT_BACKBAG_FULL)
        Close = false
        WG.GuildBankEnd()
      end
      return
    end
    --Do Take
    EVENT_MANAGER:RegisterForEvent(WG.name, EVENT_GUILD_BANK_ITEM_REMOVED, 
    function(Event)
      EVENT_MANAGER:UnregisterForEvent(WG.name, EVENT_GUILD_BANK_ITEM_REMOVED)
      WG.GuildBankQueue(true)
    end
    )
    TransferFromGuildBank(Target.SlotId)
    ClearCursor()
  end
  
  --Split
  if Target.Type == WAREGUILD_QUEUE_SPLIT then
    --Free slot?
    if GetNumBagFreeSlots(1) == 0 then
      d("[WareGuild] "..WG.Lang.CHAT_STOP)
      d("[WareGuild] "..WG.Lang.CHAT_BACKBAG_FULL)
      Close = false
      WG.GuildBankEnd()
      return
    end
    --Do Split
    local NewSlot = FindFirstEmptySlotInBag(1)
    EVENT_MANAGER:RegisterForEvent(WG.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, 
    function(Event, BagId, SlotId, IsNew, _, _, NumChange)
      if NumChange > 0 then return end
      EVENT_MANAGER:UnregisterForEvent(WG.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
      WG.GuildBankQueue(true)
    end
    )
    CallSecureProtected("RequestMoveItem", 1, Target.SlotId, 1, NewSlot, Target.Count)
    ClearCursor()
  end
  
  --Store
  if Target.Type == WAREGUILD_QUEUE_STORE then
    --Free slot?
    if GetNumBagFreeSlots(3) == 0 then
      d("[WareGuild] "..WG.Lang.CHAT_STOP)
      d("[WareGuild] "..WG.Lang.CHAT_GUILD_BANK_FULL)
      Close = false
      WG.GuildBankEnd()
      return
    end
    --Do Store
    EVENT_MANAGER:RegisterForEvent(WG.name, EVENT_GUILD_BANK_ITEM_ADDED, 
    function(Event)
      EVENT_MANAGER:UnregisterForEvent(WG.name, EVENT_GUILD_BANK_ITEM_ADDED)
      WG.GuildBankQueue(true)
      --if WG.SV.Log then d(String) end
    end
    )
    TransferToGuildBank(1, Target.SlotId)
    ClearCursor()
  end
end

--End Part
function WG.GuildBankEnd()
  --Reset V
  Step = {}
  Queue = {}
  --Unregister
  SCENE_MANAGER:UnregisterCallback("SceneStateChanged", WG.GuildBankCore)
  EVENT_MANAGER:UnregisterForEvent(WG.name, EVENT_GUILD_BANK_ITEMS_READY)
  EVENT_MANAGER:UnregisterForEvent(WG.name, EVENT_GUILD_BANK_ITEM_ADDED)
  EVENT_MANAGER:UnregisterForEvent(WG.name, EVENT_GUILD_BANK_ITEM_REMOVED)
  EVENT_MANAGER:UnregisterForEvent(WG.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
  EVENT_MANAGER:UnregisterForEvent(WG.name, EVENT_INVENTORY_FULL_UPDATE)
  --Show guild fragment
  if Close then
    if SCENE_MANAGER:IsShowing("guildBank") then GUILD_BANK_FRAGMENT:Show() end
    if SCENE_MANAGER:IsShowing("gamepad_guild_bank") then GAMEPAD_GUILD_BANK_FRAGMENT:Show() end
    PLAYER_INVENTORY:RefreshAllGuildBankItems()
    KEYBIND_STRIP:UpdateKeybindButtonGroup(PLAYER_INVENTORY.guildBankWithdrawTabKeybindButtonGroup)
  end
  --AutoClose
  if WG.SV.AutoClose and Close then
    SCENE_MANAGER:Hide("guildBank")
    SCENE_MANAGER:Hide("gamepad_guild_bank")
  end
  --Reset Auto Craft Bag
  if WG.CV.AutoCraftBag then 
    SetSetting(SETTING_TYPE_LOOT, 4, WG.CV.AutoCraftBag) 
    WG.CV.AutoCraftBag = nil
  end
end

--Debug
function WG.DebugTable()
  d("----Step: ")
  d(Step)
  d("----Queue: ")
  d(Queue)
end

-------------------
----Start Point----
-------------------
EVENT_MANAGER:RegisterForEvent(WG.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)