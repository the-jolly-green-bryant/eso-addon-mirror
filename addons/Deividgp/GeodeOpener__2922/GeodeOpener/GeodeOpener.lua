GO = {}

GO.name = "GeodeOpener"
GO.name = "GeodeOpener"
GO.version = "v0.9.3"
GO.author = "Deividgp"

GO.defaults = {
  autoOpener = false,
  openMailGeode = false,
  openQuestGeode = false,
}
--Item Id's
--134595: Tester's Infinite Transmutation Geode (PTS)
--134583: White Transmutation Geode
--134588: Blue Transmutation Geode
--134590: Purple Transmutation Geode
--134591: Gold Transmutation Geode
--171531: Green Transmutation Geode
--134618: Gold Uncracked Transmutation Geode
--134622: Blue Uncracked Transmutation Geode
--134623: Purple Uncracked Transmutation Geode
--140222: 200 Transmute Crystals
local geodeIds = {134595, 134583, 134588, 134590, 134591, 171531, 134618, 134622, 134623, 140222}
local limitText = "GeodeOpener stopped because looting would put you over the stone limit"
local notEnoughText = "There is not enough space. Use some crystals"
local cooldown = 500
local openCd = 1000
local lootCd = 500
local enoughSpace

--Checks if there are geodes with a specific id
local function existsId(itemId)
  for index, value in ipairs(geodeIds) do
      if value == itemId then
          return true
      end
  end
  return false
end

--Checks if the user can open more crystals
local function hasMaxSpace()
  if GetCurrencyAmount(CURT_CHAOTIC_CREATIA,CURRENCY_LOCATION_ACCOUNT) >=  GetMaxPossibleCurrency(CURT_CHAOTIC_CREATIA, CURRENCY_LOCATION_ACCOUNT) then
    return true
  end
  return false
end

--Resets the cooldown variable so it's ready for the next iteration (500 ms)
local function resetCd()
  cooldown = lootCd
end

--Proceeds to open the geode
local function openGeode(bagId, slotId)
  --if enoughSpace == true then
    if IsProtectedFunction("UseItem") then
      CallSecureProtected("UseItem", bagId, slotId)
    else
      UseItem(bagId, slotId)
    end
  --end
end

--Proceeds to loot the geode
local function lootGeode()
  --if enoughSpace == true then
    --Check if looting that geode would put the user over the stone limit
    if GetCurrencyAmount(CURT_CHAOTIC_CREATIA,CURRENCY_LOCATION_ACCOUNT) + GetLootCurrency(CURT_CHAOTIC_CREATIA) <=  GetMaxPossibleCurrency(CURT_CHAOTIC_CREATIA, CURRENCY_LOCATION_ACCOUNT) then
      --Loots and ends looting
      LootCurrency(CURT_CHAOTIC_CREATIA)
      EndLooting()
    else
      --If not enough space ends looting
      EndLooting()
      d(limitText)
      enoughSpace = false
    end
  --end
end

--Main function
local function loopGeodes()
  enoughSpace = true
  --Main loop to iterate through the whole backpack
  for slotId=0, GetBagSize(BAG_BACKPACK) do
    local itemId = GetItemId(BAG_BACKPACK, slotId)
    if existsId(itemId) then
      --Opens after cooldown
      zo_callLater(function()
        openGeode(BAG_BACKPACK, slotId)
      end, cooldown)
      --Adds cooldown (+500 ms)
      cooldown = cooldown + lootCd
      --Attempts to loot after cooldown
      zo_callLater(function()
        lootGeode()
      end, cooldown)
      --Adds more cooldown (+1000 ms)
      cooldown = cooldown + openCd

    end
  end
  --Resets cooldown when loop ends
  resetCd()
end

--Function to check if the user has enough space before starting the loop
local function initializeLoop()
  if hasMaxSpace() == true then
    d(notEnoughText)
  else
    loopGeodes()
  end
end

function GO.OnPlayerActivated(event)
  initializeLoop()
end

function GO.OnTakeAttachedSuccess(event, mailId)
  initializeLoop()
end

function GO.OnQuestComplete(event, questName, playerLevel, previousXP, currentXP, playerVeteranRank, previousVeteranPoints, currentVeteranPoints)
  initializeLoop()
end

--Once addons are fully loaded (login or reloadui)
function GO.OnAddOnLoaded(event, addOnName)
  --Checks if the loaded addon is GeodeOpener
  if GO.name ~= addOnName then return end

  --Removes the event to free up some space
  EVENT_MANAGER:UnregisterForEvent(GO.name, EVENT_ADD_ON_LOADED)

  --Slash commands
  SLASH_COMMANDS["/geodeopener"] = initializeLoop
  SLASH_COMMANDS["/go"] = initializeLoop

  --Saves the default variables
  GO.vars = ZO_SavedVars:NewAccountWide("GeodeOpenerSavedVars", 1, nil, GO.defaults)
  GO.CreateSettingsMenu()

  --If autoOpener is on (starts everytime there is a loading screen)
  if GO.vars.autoOpener then
    EVENT_MANAGER:RegisterForEvent(GO.name, EVENT_PLAYER_ACTIVATED, GO.OnPlayerActivated)
  end
  --If openMailGeode is on (starts everytime the user takes mail attachments)
  if GO.vars.openMailGeode then
    EVENT_MANAGER:RegisterForEvent(GO.name, EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS, GO.OnTakeAttachedSuccess)
  end
  --If openQuestGeode is on (starts everytime completes a quest)
  if GO.vars.openQuestGeode then
    EVENT_MANAGER:RegisterForEvent(GO.name, EVENT_QUEST_COMPLETE, GO.OnQuestComplete)
  end
end

EVENT_MANAGER:RegisterForEvent(GO.name, EVENT_ADD_ON_LOADED, GO.OnAddOnLoaded)