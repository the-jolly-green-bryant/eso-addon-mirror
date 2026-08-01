--Create a namespace for our variables
GoldPerHour = {}
GoldPerHour.defaults = {}
GoldPerHour.defaults.filtered = {}

--List Of ItemTypes--
GoldPerHour.defaults.showOnLoad = true
GoldPerHour.defaults.filtered[1] = true --Weapon
GoldPerHour.defaults.filtered[2] = true --Armor
GoldPerHour.defaults.filtered[4] = true --Food
GoldPerHour.defaults.filtered[5] = true --Trophy
GoldPerHour.defaults.filtered[7] = true --Potion
GoldPerHour.defaults.filtered[8] = true --Racial Style Motif
GoldPerHour.defaults.filtered[9] = true --Tool
GoldPerHour.defaults.filtered[10] = true --Ingredient
GoldPerHour.defaults.filtered[16] = true --Lure
GoldPerHour.defaults.filtered[17] = true --Raw Material
GoldPerHour.defaults.filtered[19] = true --Soul Gem
GoldPerHour.defaults.filtered[20] = true --Glyph Weapon
GoldPerHour.defaults.filtered[21] = true --Glyph Armor
GoldPerHour.defaults.filtered[22] = true --Lockpick
GoldPerHour.defaults.filtered[26] = true --Glyph Jewelry
GoldPerHour.defaults.filtered[27] = true --Spice
GoldPerHour.defaults.filtered[28] = true --Flavoring
GoldPerHour.defaults.filtered[29] = true --Recipe
GoldPerHour.defaults.filtered[30] = true --Poison
GoldPerHour.defaults.filtered[31] = true --Reagent
GoldPerHour.defaults.filtered[33] = true --Potion Base
GoldPerHour.defaults.filtered[34] = true --Collectable
GoldPerHour.defaults.filtered[35] = true --BS Raw
GoldPerHour.defaults.filtered[36] = true --BS Mat
GoldPerHour.defaults.filtered[37] = true --WW Raw Mat
GoldPerHour.defaults.filtered[38] = true --WW Mat
GoldPerHour.defaults.filtered[39] = true --Clothier Raw
GoldPerHour.defaults.filtered[40] = true --Clothier Mat
GoldPerHour.defaults.filtered[44] = true --Style Mat
GoldPerHour.defaults.filtered[45] = true --Armor Trait
GoldPerHour.defaults.filtered[46] = true --Weapon Trait
GoldPerHour.defaults.filtered[48] = true --Trash
GoldPerHour.defaults.filtered[49] = true --Spellcrafting Tablet
GoldPerHour.defaults.filtered[51] = true --Rune Potency
GoldPerHour.defaults.filtered[52] = true --Rune Aspect
GoldPerHour.defaults.filtered[53] = true --Rune Essence
GoldPerHour.defaults.filtered[54] = true --Fish
GoldPerHour.defaults.filtered[56] = true --Treasure
GoldPerHour.defaults.filtered[58] = true --Poison Base
GoldPerHour.defaults.filtered[60] = true --Master Writ
GoldPerHour.defaults.filtered[61] = true --Furnishing
GoldPerHour.defaults.filtered[62] = true --Furnishing Mat
GoldPerHour.defaults.filtered[63] = true --Raw Mat
GoldPerHour.defaults.filtered[64] = true --Jewelry Mat
GoldPerHour.defaults.filtered[66] = true --Jewelry Trait
GoldPerHour.defaults.filtered[68] = true --Jewelry Raw Trait
--End of ItemTypes


local LAM2 = LibAddonMenu2

--Variables
GoldPerHour.name = "GoldPerHour"
GoldPerHour.startTime = 0
GoldPerHour.currentTime = 0
GoldPerHour.goldPerHour = 0
GoldPerHour.running = false
GoldPerHour.money = 0
GoldPerHour.updateTimeInSeconds = 3000
GoldPerHour.elapsedTime = 0
GoldPerHour.paused = false

--Call the initialization
function GoldPerHour.OnAddOnLoaded(event, addonName)
  if addonName == GoldPerHour.name then
    GoldPerHour:Initialize()
  end
end

--Initialize the addon
function GoldPerHour:Initialize()
  ZO_CreateStringId("SI_BINDING_NAME_GOLD_PER_HOUR_TOGGLE", "Toggle Window")
  GoldPerHour.running = true
  GoldPerHour.startTime = GetGameTimeMilliseconds()
  GoldPerHour.IntegrateMM = (MasterMerchant ~= nil)
  GoldPerHourIndicatorGoldPerHour:SetText(string.format("Gold Per Hour: %d", GoldPerHour.money))
  self.savedVariables = ZO_SavedVars:New("GoldPerHourSavedVariables", 1, nil, GoldPerHour.defaults)
  self:RestorePosition()
  EVENT_MANAGER:RegisterForEvent(GoldPerHour.name, EVENT_MONEY_UPDATE, GoldPerHour.OnLootMoney)
  GoldPerHour.CreateSettingsWindow()
  if GoldPerHour.savedVariables.showOnLoad == false then
    toggleUI()
  end
end

--Menu Functions--
function GoldPerHour:CreateSettingsWindow()
  local panelData = {
    type = "panel",
    name = "Gold Per Hour",
    displayName = "Gold Per Hour",
    author = "Satchmo1991",
    slashCommand = "/gphsettings",
    registerForRefresh = true,
    registerForDefaults = true,
  }
  local cntrlOptionsPanel = LAM2:RegisterAddonPanel("Gold_Per_Hour", panelData)
  local optionsData = {
    [1] = {
      type = "header",
      name = "Gold Per Hour Settings",
    },
    [2] = {
      type = "description",
      text = "Here you can adjust how GPH works. Remember to reload UI (/reloadui) to apply changes.",
    },
    [3] = {
      type = "header",
      name = "Crafting"
    },
    [4] = {
      type = "checkbox",
      name = "Blacksmithing Raw",
      getFunc = function() return GoldPerHour.savedVariables.filtered[35] end,
  		setFunc = function(value) GoldPerHour.savedVariables.filtered[35] = value end,
    },
    [5] = {
      type = "checkbox",
      name = "Blacksmithing Refined",
      getFunc = function() return GoldPerHour.savedVariables.filtered[36] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[36] = value end,
    },
    [6] = {
      type = "checkbox",
      name = "Blacksmithing Booster",
      getFunc = function() return GoldPerHour.savedVariables.filtered[41] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[41] = value end,
    },
    [7] = {
      type = "checkbox",
      name = "Clothier Raw",
      getFunc = function() return GoldPerHour.savedVariables.filtered[39] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[39] = value end,
    },
    [8] = {
      type = "checkbox",
      name = "Clothier Refined",
      getFunc = function() return GoldPerHour.savedVariables.filtered[40] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[40] = value end,
    },
    [9] = {
      type = "checkbox",
      name = "Clothier Booster",
      getFunc = function() return GoldPerHour.savedVariables.filtered[43] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[43] = value end,
    },
    [10] = {
      type = "checkbox",
      name = "Woodworking Raw",
      getFunc = function() return GoldPerHour.savedVariables.filtered[37] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[37] = value end,
    },
    [11] = {
      type = "checkbox",
      name = "Woodworking Refined",
      getFunc = function() return GoldPerHour.savedVariables.filtered[38] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[38] = value end,
    },
    [12] = {
      type = "checkbox",
      name = "Woodworking Booster",
      getFunc = function() return GoldPerHour.savedVariables.filtered[42] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[42] = value end,
    },
    [13] = {
      type = "checkbox",
      name = "Jewelry Crafting Raw",
      getFunc = function() return GoldPerHour.savedVariables.filtered[63] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[63] = value end,
    },
    [14] = {
      type = "checkbox",
      name = "Jewelry Crafting Refined",
      getFunc = function() return GoldPerHour.savedVariables.filtered[64] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[64] = value end,
    },
    [15] = {
      type = "checkbox",
      name = "Jewelry Crafting Booster",
      getFunc = function() return GoldPerHour.savedVariables.filtered[65] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[65] = value end,
    },
    [16] = {
      type = 'divider'
    },
    [17] = {
      type = "checkbox",
      name = "Style Material",
      getFunc = function() return GoldPerHour.savedVariables.filtered[44] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[44] = value end,
    },
    [18] = {
      type = "checkbox",
      name = "Armor Trait",
      getFunc = function() return GoldPerHour.savedVariables.filtered[45] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[45] = value end,
    },
    [19] = {
      type = "checkbox",
      name = "Weapon Trait",
      getFunc = function() return GoldPerHour.savedVariables.filtered[46] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[46] = value end,
    },
    [20] = {
      type = "checkbox",
      name = "Jewelry Raw Trait",
      getFunc = function() return GoldPerHour.savedVariables.filtered[68] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[68] = value end,
    },
    [21] = {
      type = "checkbox",
      name = "Jewelry Trait",
      getFunc = function() return GoldPerHour.savedVariables.filtered[66] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[66] = value end,
    },
    [22] = {
      type = "divider"
    },
    [23] = {
      type = "checkbox",
      name = "Rune Essence",
      getFunc = function() return GoldPerHour.savedVariables.filtered[53] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[53] = value end,
    },
    [24] = {
      type = "checkbox",
      name = "Rune Aspect",
      getFunc = function() return GoldPerHour.savedVariables.filtered[52] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[52] = value end,
    },
    [25] = {
      type = "checkbox",
      name = "Rune Potency",
      getFunc = function() return GoldPerHour.savedVariables.filtered[51] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[51] = value end,
    },
    [26] = {
      type = "checkbox",
      name = "Potion Base",
      getFunc = function() return GoldPerHour.savedVariables.filtered[33] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[33] = value end,
    },
    [27] = {
      type = "checkbox",
      name = "Poison Base",
      getFunc = function() return GoldPerHour.savedVariables.filtered[58] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[58] = value end,
    },
    [28] = {
      type = "checkbox",
      name = "Reagent",
      getFunc = function() return GoldPerHour.savedVariables.filtered[31] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[31] = value end,
    },
    [29] = {
      type = "checkbox",
      name = "Ingredient",
      getFunc = function() return GoldPerHour.savedVariables.filtered[10] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[10] = value end,
    },
    [30] = {
      type = "checkbox",
      name = "Spice",
      getFunc = function() return GoldPerHour.savedVariables.filtered[27] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[27] = value end,
    },
    [31] = {
      type = "checkbox",
      name = "Flavoring",
      getFunc = function() return GoldPerHour.savedVariables.filtered[28] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[28] = value end,
    },
    [32] = {
      type = "checkbox",
      name = "Furnishing Mat",
      getFunc = function() return GoldPerHour.savedVariables.filtered[62] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[62] = value end,
    },
    [33] = {
      type = "header",
      name = "Fishing"
    },
    [34] = {
      type = "checkbox",
      name = "Fish",
      getFunc = function() return GoldPerHour.savedVariables.filtered[54] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[54] = value end,
    },
    [35] = {
      type = "checkbox",
      name = "Lure",
      getFunc = function() return GoldPerHour.savedVariables.filtered[16] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[16] = value end,
    },
    [36] = {
      type = "header",
      name = "Consumables"
    },
    [37] = {
      type = "checkbox",
      name = "Food",
      getFunc = function() return GoldPerHour.savedVariables.filtered[4] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[4] = value end,
    },
    [38] = {
      type = "checkbox",
      name = "Potion",
      getFunc = function() return GoldPerHour.savedVariables.filtered[7] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[7] = value end,
    },
    [39] = {
      type = "checkbox",
      name = "Poison",
      getFunc = function() return GoldPerHour.savedVariables.filtered[30] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[30] = value end,
    },
    [40] = {
      type = "checkbox",
      name = "Racial Style Motif",
      getFunc = function() return GoldPerHour.savedVariables.filtered[8] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[8] = value end,
    },
    [41] = {
      type = "checkbox",
      name = "Recipe",
      getFunc = function() return GoldPerHour.savedVariables.filtered[29] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[29] = value end,
    },
    [42] = {
      type = "checkbox",
      name = "Armor Glyph",
      getFunc = function() return GoldPerHour.savedVariables.filtered[21] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[21] = value end,
    },
    [43] = {
      type = "checkbox",
      name = "Weapon Glyph",
      getFunc = function() return GoldPerHour.savedVariables.filtered[20] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[20] = value end,
    },
    [44] = {
      type = "checkbox",
      name = "Jewelry Glyph",
      getFunc = function() return GoldPerHour.savedVariables.filtered[26] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[26] = value end,
    },
    [45] = {
      type = "checkbox",
      name = "Master Writ",
      getFunc = function() return GoldPerHour.savedVariables.filtered[60] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[60] = value end,
    },
    [46] = {
      type = "header",
      name = "Adventuring / Misc"
    },
    [47] = {
      type = "checkbox",
      name = "Weapon",
      getFunc = function() return GoldPerHour.savedVariables.filtered[1] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[1] = value end,
    },
    [48] = {
      type = "checkbox",
      name = "Armor",
      getFunc = function() return GoldPerHour.savedVariables.filtered[2] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[2] = value end,
    },
    [49] = {
      type = "checkbox",
      name = "Trophy",
      getFunc = function() return GoldPerHour.savedVariables.filtered[5] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[5] = value end,
    },
    [50] = {
      type = "checkbox",
      name = "Tool",
      getFunc = function() return GoldPerHour.savedVariables.filtered[9] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[9] = value end,
    },
    [51] = {
      type = "checkbox",
      name = "Raw Material (not sure what this is yet)",
      getFunc = function() return GoldPerHour.savedVariables.filtered[17] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[17] = value end,
    },
    [52] = {
      type = "checkbox",
      name = "Soul Gem",
      getFunc = function() return GoldPerHour.savedVariables.filtered[19] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[19] = value end,
    },
    [53] = {
      type = "checkbox",
      name = "Lockpick",
      getFunc = function() return GoldPerHour.savedVariables.filtered[22] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[22] = value end,
    },
    [54] = {
      type = "checkbox",
      name = "Collectable",
      getFunc = function() return GoldPerHour.savedVariables.filtered[34] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[34] = value end,
    },
    [55] = {
      type = "checkbox",
      name = "Trash",
      getFunc = function() return GoldPerHour.savedVariables.filtered[48] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[48] = value end,
    },
    [56] = {
      type = "checkbox",
      name = "Spellcrafting Tablet",
      getFunc = function() return GoldPerHour.savedVariables.filtered[49] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[49] = value end,
    },
    [57] = {
      type = "checkbox",
      name = "Treasure",
      getFunc = function() return GoldPerHour.savedVariables.filtered[56] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[56] = value end,
    },
    [58] = {
      type = "checkbox",
      name = "Furnishing",
      getFunc = function() return GoldPerHour.savedVariables.filtered[61] end,
      setFunc = function(value) GoldPerHour.savedVariables.filtered[61] = value end,
    },
    [59] = {
      type = "header",
      name = "UI Settings"
    },
    [60] = {
      type = "checkbox",
      name = "Show as default",
      tooltip = "Does the UI appear as a default on load",
      getFunc = function() return GoldPerHour.savedVariables.showOnLoad end,
  		setFunc = function(value) GoldPerHour.savedVariables.showOnLoad = value end,
    },
  }
  LAM2:RegisterOptionControls("Gold_Per_Hour", optionsData)
end

--Restores the position of the labels to where the user last had them
function GoldPerHour:RestorePosition()
  local left = self.savedVariables.left
  local top = self.savedVariables.top
  GoldPerHourIndicator:ClearAnchors()
  GoldPerHourIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

--Handle the label being moved
function GoldPerHour:OnIndicatorMoveStop()
  GoldPerHour.savedVariables.left = GoldPerHourIndicator:GetLeft()
  GoldPerHour.savedVariables.top = GoldPerHourIndicator:GetTop()
end

--Grab the value of all the money acquired
function GoldPerHour.OnLootMoney( eventCode,  newMoney,  oldMoney, reason)
  if GoldPerHour.running == true then
    if reason == 0 or reason == 76 or reason == 62 or reason == 13 or reason == 59 or reason == 4 then
      local amountReceived = newMoney - oldMoney
      GoldPerHour.money = GoldPerHour.money + amountReceived
      GoldPerHourIndicatorTotalGold:SetText(string.format("Gold This Session : %d", GoldPerHour.money))
      updateGoldPerHour()
    end
  end
end

--Calculate value of items coming into your backpack. This will subtract the value of items destroyed, or in the case of fish, filleted
function inventoryUpdate(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, updateReason, stackCountChange)
  local link = GetItemLink(bagId, slotIndex)
  local type = GetItemType(bagId, slotIndex)
  if GoldPerHour.savedVariables.filtered[type] == true then
    if GoldPerHour.running == true then
      local itemCost = LibPrice.ItemLinkToPriceGold(link)
      if itemCost ~= nil then
        itemCost = itemCost * stackCountChange
        GoldPerHour.money = GoldPerHour.money + itemCost
        GoldPerHourIndicatorTotalGold:SetText(string.format("Gold This Session : %d", GoldPerHour.money))
        updateGoldPerHour()
      end
    end
  end
end

--Updates the current Gold Per Hour
function updateGoldPerHour()
  if GoldPerHour.running == true then
    GoldPerHour.currentTime  = GetGameTimeMilliseconds()
    local sessionLengthInHours = ((GoldPerHour.currentTime - GoldPerHour.startTime) / 3600000) + (GoldPerHour.elapsedTime / 60)
    GoldPerHour.goldPerHour = GoldPerHour.money / sessionLengthInHours
    GoldPerHourIndicatorGoldPerHour:SetText(string.format("Gold Per Hour : %d", GoldPerHour.goldPerHour))

    if GoldPerHourIndicatorRunningIndicator:GetText() == "Running" then
      GoldPerHourIndicatorRunningIndicator:SetText("Running.")
    elseif GoldPerHourIndicatorRunningIndicator:GetText() == "Running." then
      GoldPerHourIndicatorRunningIndicator:SetText("Running..")
    elseif GoldPerHourIndicatorRunningIndicator:GetText() == "Running.." then
      GoldPerHourIndicatorRunningIndicator:SetText("Running...")
    elseif GoldPerHourIndicatorRunningIndicator:GetText() == "Running..." then
      GoldPerHourIndicatorRunningIndicator:SetText("Running")
    end
  end
end

--Clear the Gold Per Hour, but keep the program running
function clearGoldPerHour()
  if GoldPerHour.paused ~= true then
    GoldPerHour.goldPerHour = 0
    GoldPerHour.money = 0
    GoldPerHourIndicatorGoldPerHour:SetText(string.format("Gold Per Hour : %d", GoldPerHour.goldPerHour))
    GoldPerHourIndicatorTotalGold:SetText(string.format("Gold This Session : %d", GoldPerHour.money))
    GoldPerHour.startTime = GetGameTimeMilliseconds()
    d("Gold Per Hour cleared!")
  elseif GoldPerHour.running == true then
    d("New session Started at " .. os.date("%X"))
  else
    d("Unpause to reset")
  end
end

--Start the program
function startSession()
  if GoldPerHour.running ~= true and GoldPerHour.paused ~= true then
    GoldPerHour.elapsedTime = 0
    GoldPerHourIndicator:SetHidden(false)
    GoldPerHour.running = true
    GoldPerHour.startTime = GetGameTimeMilliseconds()
    d("Session Started at " .. os.date("%X"))
    GoldPerHourIndicatorRunningIndicator:SetText("Running")
  elseif GoldPerHour.running == false and GoldPerHour.paused == true then
    d("Unpause to resume")
  else
    d("Already running")
  end
end

--Stops the program
function endSession()
  if GoldPerHour.running == true then
    d("Session Ended at ".. os.date("%X") ..". You earned " .. math.floor(GoldPerHour.money) .. " gold in " .. (round(((GetGameTimeMilliseconds() - GoldPerHour.startTime) / 60000), 2) + GoldPerHour.elapsedTime) .. " minutes at and average of " .. math.floor(GoldPerHour.goldPerHour) .. " gold per hour!")
    GoldPerHour.running = false
    clearGoldPerHour()
    GoldPerHourIndicatorRunningIndicator:SetText("Stopped")
  elseif GoldPerHour.running == false and GoldPerHour.paused == true then
    d("Please unpause, then stop")
  else
    d("GPH is not running")
  end
end

function TogglePause()
  if GoldPerHour.running == true and GoldPerHour.paused ~= true then
    --Pause--
    GoldPerHour.paused = true
    GoldPerHour.running = false
    GoldPerHourIndicatorPause:SetText("Unpause")
    GoldPerHourIndicatorRunningIndicator:SetText("Paused")
    d("Session paused at " .. os.date("%X"))
    GoldPerHour.elapsedTime = GoldPerHour.elapsedTime + round(((GetGameTimeMilliseconds() - GoldPerHour.startTime) / 60000), 2)
    d(GoldPerHour.elapsedTime)
  elseif GoldPerHour.running ~= true and GoldPerHour.paused == true then
    --Unpause--
    GoldPerHour.paused = false
    GoldPerHour.running = true
    GoldPerHourIndicatorRunningIndicator:SetText("Running")
    GoldPerHourIndicatorPause:SetText("Pause")
    d("Session resumed at " .. os.date("%X"))
    GoldPerHour.startTime = GetGameTimeMilliseconds()
  elseif GoldPerHour.running ~= true and GoldPerHour.paused ~= true then
    d("GPH is not running")
  end
end

--Handles slash commands
function commands(command)
  if command == "clear" or command == "cl" then
    clearGoldPerHour()
  elseif command == "start" or command == "run" then
    startSession()
  elseif command == "end" or command == "stop" then
    endSession()
  elseif command == "uptime" then
    printUpTime()
  elseif command == "cam" then
    local cam = GetGameCameraInteractableActionInfo()
    d(cam)
  else
    d("Invalid Command")
  end
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function printUpTime()
  if GoldPerHour.running == true then
    local upTime = (round(((GetGameTimeMilliseconds() - GoldPerHour.startTime) / 60000), 2) + GoldPerHour.elapsedTime)
    d("This session is " .. upTime .. " minutes long.")
  else
    d("GPH is not running")
  end
end

--Toggle UI in menus
local gphFragment = ZO_HUDFadeSceneFragment:New(GoldPerHourIndicator, nil, 0)
HUD_SCENE:AddFragment(gphFragment)
HUD_UI_SCENE:AddFragment(gphFragment)


--Manually toggle UI on button click
function toggleUI()
  if GoldPerHourIndicatorbg:IsHidden() == true then
    GoldPerHourIndicatorbg:SetHidden(false)
    GoldPerHourIndicatorTotalGold:SetHidden(false)
    GoldPerHourIndicatorGoldPerHour:SetHidden(false)
    GoldPerHourIndicatorStart:SetHidden(false)
    GoldPerHourIndicatorStop:SetHidden(false)
    GoldPerHourIndicatorReset:SetHidden(false)
    GoldPerHourIndicatorRunningIndicator:SetHidden(false)
    GoldPerHourIndicatorPause:SetHidden(false)
  else
    GoldPerHourIndicatorbg:SetHidden(true)
    GoldPerHourIndicatorTotalGold:SetHidden(true)
    GoldPerHourIndicatorGoldPerHour:SetHidden(true)
    GoldPerHourIndicatorStart:SetHidden(true)
    GoldPerHourIndicatorStop:SetHidden(true)
    GoldPerHourIndicatorReset:SetHidden(true)
    GoldPerHourIndicatorRunningIndicator:SetHidden(true)
    GoldPerHourIndicatorPause:SetHidden(true)
  end
end


--Global commands and Listeners
SLASH_COMMANDS["/gph"] = commands
EVENT_MANAGER:RegisterForEvent(GoldPerHour.name, EVENT_ADD_ON_LOADED, GoldPerHour.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(GoldPerHour.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, inventoryUpdate)
EVENT_MANAGER:RegisterForUpdate(GoldPerHour.name, GoldPerHour.updateTimeInSeconds, updateGoldPerHour)
EVENT_MANAGER:AddFilterForEvent(GoldPerHour.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
