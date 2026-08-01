-- Shopkeeper Main Addon File
-- Last Updated September 15, 2014
-- Written July 2014 by Dan Stone (@khaibit) - dankitymao@gmail.com
-- Released under terms in license accompanying this file.
-- Distribution without license is prohibited!

-- Computes the weighted moving average across available data
function Shopkeeper:toolTipStats(itemID, itemIndex)
  local sortedTable = {}
  local oldestTime = nil
  local newestTime = nil
  local returnData = nil

  if self.acctSavedVariables.SalesData[itemID] and self.acctSavedVariables.SalesData[itemID][itemIndex] then
    for _, item in ipairs(self.acctSavedVariables.SalesData[itemID][itemIndex]['sales']) do
      local tableSize = #sortedTable
      for i = 1, #sortedTable do
        if item.price > sortedTable[i][1] then
          table.insert(sortedTable, i+1, {item.price, item.timestamp, item.quant})
          break
        end
      end
      if tableSize == #sortedTable then table.insert(sortedTable, {item.price, item.timestamp, item.quant}) end
      if oldestTime == nil or oldestTime > item.timestamp then oldestTime = item.timestamp end
      if newestTime == nil or newestTime < item.timestamp then newestTime = item.timestamp end
    end
  end

  -- Now that we have a price-sorted list, we can use it to compute stats
  if #sortedTable > 0 then
    local timeInterval = newestTime - oldestTime
    local avgPrice = 0
    -- If all sales data covers less than a day, we'll just do a plain average, nothing to weight
    if timeInterval < 86400 then
      for i = 1, #sortedTable do avgPrice = avgPrice + sortedTable[i][1] / sortedTable[i][3] end -- stack size issue fixed by Garkin
      avgPrice = avgPrice / #sortedTable
      returnData = {["avgPrice"] = avgPrice, ["numSales"] = #sortedTable, ["numDays"]= 1}
    -- For a weighted average, the latest data gets a weighting of X, where X is the number of
    -- days the data covers, thus making newest data worth more.
    else
      local dayInterval = math.floor((GetTimeStamp() - oldestTime) / 86400.0) + 1
      local weightedDiv = 0
      for i = 1, #sortedTable do
        local weightValue = dayInterval - math.floor((GetTimeStamp() - sortedTable[i][2]) / 86400.0)
        local perPrice = sortedTable[i][1]
        if sortedTable[i][3] > 1 then perPrice = perPrice / sortedTable[i][3] end
        weightedDiv = weightedDiv + weightValue
        avgPrice = avgPrice + (perPrice * weightValue)
      end
      if weightedDiv ~= 0 then avgPrice = avgPrice / weightedDiv end
      returnData = {["avgPrice"] = avgPrice, ["numSales"] = #sortedTable, ["numDays"] = dayInterval}
    end
  end

  return returnData
end

-- Calculate some stats based on the player's sales
-- and return them as a table.
function Shopkeeper:SalesStats(statsDays)
  -- Initialize some values as we'll be using accumulation in the loop
  -- SK_STATS_TOTAL is a key for the overall stats as a guild is unlikely
  -- to be named that, except maybe just to mess with me :D
  local itemsSold = {["SK_STATS_TOTAL"] = 0}
  local goldMade = {["SK_STATS_TOTAL"] = 0}
  local largestSingle = {["SK_STATS_TOTAL"] = {0, nil}}
  local oldestTime = 0
  local newestTime = 0
  local overallOldestTime = 0
  local kioskSales = {["SK_STATS_TOTAL"] = 0}

  -- Set up the guild chooser, with the all guilds/overall option first
  --(other guilds will be added below)
  local guildDropdown = ZO_ComboBox_ObjectFromContainer(ShopkeeperStatsGuildChooser)
  guildDropdown:ClearItems()
  local allGuilds = guildDropdown:CreateItemEntry(GetString(SK_STATS_ALL_GUILDS), function() self:UpdateStatsWindow("SK_STATS_TOTAL") end)
  guildDropdown:AddItem(allGuilds)

  -- 86,400 seconds in a day; this will be the epoch time statsDays ago
  -- (roughly, actual time computations are a LOT more complex but meh)
  local statsDaysEpoch = GetTimeStamp() - (86400 * statsDays)

  -- Loop through the player's sales and create the stats as appropriate
  -- (everything or everything with a timestamp after statsDaysEpoch)
  local seenIndexes = {}
  for _, indexes in pairs(self.SSIndex) do
    for i = 1, #indexes do
      local itemID = indexes[i][1]
      local itemData = indexes[i][2]
      local itemIndex = indexes[i][3]
      if seenIndexes[itemID] == nil then
        seenIndexes[itemID] = {}
      end
      if seenIndexes[itemID][itemData] == nil then
        seenIndexes[itemID][itemData] = {}
      end
      --local theItem = self.acctSavedVariables.SalesData[itemID][itemData]['sales'][itemIndex]
      if seenIndexes[itemID][itemData][itemIndex] == nil then
        seenIndexes[itemID][itemData][itemIndex] = true
        local theItem = self.acctSavedVariables.SalesData[itemID][itemData]['sales'][itemIndex]
        theItem.itemLink = self:UpdateItemLink(theItem.itemLink)
        if theItem.timestamp > statsDaysEpoch then
          -- Items Sold
          itemsSold["SK_STATS_TOTAL"] = itemsSold["SK_STATS_TOTAL"] + 1
          if itemsSold[theItem.guild] ~= nil then
            itemsSold[theItem.guild] = itemsSold[theItem.guild] + 1
          else
            itemsSold[theItem.guild] = 1
          end

          -- Kiosk sales
          if theItem.wasKiosk then
            kioskSales["SK_STATS_TOTAL"] = kioskSales["SK_STATS_TOTAL"] + 1
            if kioskSales[theItem.guild] ~= nil then
              kioskSales[theItem.guild] = kioskSales[theItem.guild] + 1
            else
              kioskSales[theItem.guild] = 1
            end
          end

          -- Gold made
          goldMade["SK_STATS_TOTAL"] = goldMade["SK_STATS_TOTAL"] + theItem.price
          if goldMade[theItem.guild] ~= nil then
            goldMade[theItem.guild] = goldMade[theItem.guild] + theItem.price
          else
            goldMade[theItem.guild] = theItem.price
          end

          -- Check to see if we need to update the newest or oldest timestamp we've seen
          if oldestTime == 0 or theItem.timestamp < oldestTime then oldestTime = theItem.timestamp end
          if newestTime == 0 or theItem.timestamp > newestTime then newestTime = theItem.timestamp end

          -- Largest single sale
          if theItem.price > largestSingle["SK_STATS_TOTAL"][1] then largestSingle["SK_STATS_TOTAL"] = {theItem.price, theItem.itemLink} end
          if largestSingle[theItem.guild] == nil or theItem.price > largestSingle[theItem.guild][1] then
            largestSingle[theItem.guild] = {theItem.price, theItem.itemLink}
          end
        end
        -- Check to see if we need to update the overall oldest time (used to set slider range)
        if overallOldestTime == 0 or theItem.timestamp < overallOldestTime then
          overallOldestTime = theItem.timestamp
        end
      end
    end
  end
  seenIndexes = nil

  -- Newest timestamp seen minus oldest timestamp seen is the number of seconds between
  -- them; divided by 86,400 it's the number of days (or at least close enough for this)
  local timeWindow = newestTime - oldestTime
  local dayWindow = 1
  if timeWindow > 86400 then dayWindow = math.floor(timeWindow / 86400) + 1 end

  local overallTimeWindow = newestTime - overallOldestTime
  local overallDayWindow = 1
  if overallTimeWindow > 86400 then overallDayWindow = math.floor(overallTimeWindow / 86400) + 1 end

  local goldPerDay = {}
  local kioskPercentage = {}
  local showFullPrice = self:ActiveSettings().showFullPrice

  -- Here we'll tweak stats as needed as well as add guilds to the guild chooser
  for theGuildName, guildItemsSold in pairs(itemsSold) do
    goldPerDay[theGuildName] = math.floor(goldMade[theGuildName] / dayWindow)
    local kioskSalesTemp = 0
    if kioskSales[theGuildName] ~= nil then kioskSalesTemp = kioskSales[theGuildName] end
    kioskPercentage[theGuildName] = math.floor((kioskSalesTemp / guildItemsSold) * 100)

    if theGuildName ~= "SK_STATS_TOTAL" then
      local guildEntry = guildDropdown:CreateItemEntry(theGuildName, function() self:UpdateStatsWindow(theGuildName) end)
      guildDropdown:AddItem(guildEntry)
    end

    -- If they have the option set to show prices post-cut, calculate that here
    if not showFullPrice then
      local cutMult = 1 - (GetTradingHouseCutPercentage() / 100)
      goldMade[theGuildName] = math.floor(goldMade[theGuildName] * cutMult + 0.5)
      goldPerDay[theGuildName] = math.floor(goldPerDay[theGuildName] * cutMult + 0.5)
      largestSingle[theGuildName][1] = math.floor(largestSingle[theGuildName][1] * cutMult + 0.5)
    end
  end

  -- Return the statistical data in a convenient table
  return { numSold = itemsSold,
           numDays = dayWindow,
           totalDays = overallDayWindow,
           totalGold = goldMade,
           avgGold = goldPerDay,
           biggestSale = largestSingle,
           kioskPercent = kioskPercentage, }
end

-- LibAddon init code
function Shopkeeper:LibAddonInit()
  local LAM = LibStub("LibAddonMenu-2.0")
  if LAM then
    local LMP = LibStub("LibMediaProvider-1.0")
    if LMP then
      local panelData = {
        type = "panel",
        name = "Shopkeeper",
        displayName = "Shopkeeper",
        author = "Khaibit (fixed by dOpiate and Garkin)",
        version = self.version,
        registerForDefaults = true,
      }
      LAM:RegisterAddonPanel("ShopkeeperOptions", panelData)

      local settingsToUse = Shopkeeper:ActiveSettings()
      local optionsData = {
        -- Sound and Alert options
        [1] = {
          type = "submenu",
          name = GetString(SK_ALERT_OPTIONS_NAME),
          tooltip = GetString(SK_ALERT_OPTIONS_TIP),
          controls = {
            -- On-Screen Alerts
            [1] = {
              type = "checkbox",
              name = GetString(SK_ALERT_ANNOUNCE_NAME),
              tooltip = GetString(SK_ALERT_ANNOUNCE_TIP),
              getFunc = function() return self:ActiveSettings().showAnnounceAlerts end,
              setFunc = function(value) self:ActiveSettings().showAnnounceAlerts = value end,
            },
            [2] = {
              type = "checkbox",
              name = GetString(SK_ALERT_CYRODIIL_NAME),
              tooltip = GetString(SK_ALERT_CYRODIIL_TIP),
              getFunc = function() return self:ActiveSettings().showCyroAlerts end,
              setFunc = function(value) self:ActiveSettings().showCyroAlerts = value end,
            },
            -- Chat Alerts
            [3] = {
              type = "checkbox",
              name = GetString(SK_ALERT_CHAT_NAME),
              tooltip = GetString(SK_ALERT_CHAT_TIP),
              getFunc = function() return self:ActiveSettings().showChatAlerts end,
              setFunc = function(value) self:ActiveSettings().showChatAlerts = value end,
            },
            -- Sound to use for alerts
            [4] = {
              type = "dropdown",
              name = GetString(SK_ALERT_TYPE_NAME),
              tooltip = GetString(SK_ALERT_TYPE_TIP),
              choices = self:SoundKeys(),
              getFunc = function() return self:SearchSounds(self:ActiveSettings().alertSoundName) end,
              setFunc = function(value) self:ActiveSettings().alertSoundSound = self:SearchSoundNames(value) end,
            },
            -- Whether or not to show multiple alerts for multiple sales
            [5] = {
              type = "checkbox",
              name = GetString(SK_MULT_ALERT_NAME),
              tooltip = GetString(SK_MULT_ALERT_TIP),
              getFunc = function() return self:ActiveSettings().showMultiple end,
              setFunc = function(value) self:ActiveSettings().showMultiple = value end,
            },
            -- Offline sales report
            [6] = {
              type = "checkbox",
              name = GetString(SK_OFFLINE_SALES_NAME),
              tooltip = GetString(SK_OFFLINE_SALES_TIP),
              getFunc = function() return self:ActiveSettings().offlineSales end,
              setFunc = function(value) self:ActiveSettings().offlineSales = value end,
            },
          },
        },
        -- Open main window with mailbox scenes
        [2] = {
          type = "checkbox",
          name = GetString(SK_OPEN_MAIL_NAME),
          tooltip = GetString(SK_OPEN_MAIL_TIP),
          getFunc = function() return self:ActiveSettings().openWithMail end,
          setFunc = function(value)
            self:ActiveSettings().openWithMail = value
            local theFragment = ((settingsToUse.viewSize == "full") and self.uiFragment) or self.miniUiFragment
            if value then
              -- Register for the mail scenes
              MAIL_INBOX_SCENE:AddFragment(theFragment)
              MAIL_SEND_SCENE:AddFragment(theFragment)
            else
              -- Unregister for the mail scenes
              MAIL_INBOX_SCENE:RemoveFragment(theFragment)
              MAIL_SEND_SCENE:RemoveFragment(theFragment)
            end
          end,
        },
        -- Open main window with trading house scene
        [3] = {
          type = "checkbox",
          name = GetString(SK_OPEN_STORE_NAME),
          tooltip = GetString(SK_OPEN_STORE_TIP),
          getFunc = function() return self:ActiveSettings().openWithStore end,
          setFunc = function(value)
            self:ActiveSettings().openWithStore = value
            local theFragment = ((settingsToUse.viewSize == "full") and self.uiFragment) or self.miniUiFragment
            if value then
              -- Register for the store scene
              TRADING_HOUSE_SCENE:AddFragment(theFragment)
            else
              -- Unregister for the store scene
              TRADING_HOUSE_SCENE:RemoveFragment(theFragment)
            end
          end,
        },
        -- Show full sale price or post-tax price
        [4] = {
          type = "checkbox",
          name = GetString(SK_FULL_SALE_NAME),
          tooltip = GetString(SK_FULL_SALE_TIP),
          getFunc = function() return self:ActiveSettings().showFullPrice end,
          setFunc = function(value)
            self:ActiveSettings().showFullPrice = value
            Shopkeeper.listIsDirty["full"] = true
            Shopkeeper.listIsDirty["mini"] = true
          end,
        },
        -- Scan frequency (in seconds)
        [5] = {
          type = "slider",
          name = GetString(SK_SCAN_FREQ_NAME),
          tooltip = GetString(SK_SCAN_FREQ_TIP),
          min = 30,
          max = 600,
          getFunc = function() return self:ActiveSettings().scanFreq end,
          setFunc = function(value)
            self:ActiveSettings().scanFreq = value

            EVENT_MANAGER:UnregisterForUpdate(self.name)
            local scanInterval = value * 1000
            EVENT_MANAGER:RegisterForUpdate(self.name, scanInterval, function() self:ScanStores(false) end)
          end,
        },
        -- Size of sales history
        [6] = {
          type = "slider",
          name = GetString(SK_HISTORY_DEPTH_NAME),
          tooltip = GetString(SK_HISTORY_DEPTH_TIP),
          min = 1,
          max = 30,
          getFunc = function() return self:ActiveSettings().historyDepth end,
          setFunc = function(value) self:ActiveSettings().historyDepth = value end,
        },
        -- Whether or not to show the pricing data in tooltips
        [7] = {
          type = "checkbox",
          name = GetString(SK_SHOW_PRICING_NAME),
          tooltip = GetString(SK_SHOW_PRICING_TIP),
          getFunc = function() return self:ActiveSettings().showPricing end,
          setFunc = function(value) self:ActiveSettings().showPricing = value end,
        },
        -- Should we show the stack price calculator?
        [8] = {
          type = "checkbox",
          name = GetString(SK_CALC_NAME),
          tooltip = GetString(SK_CALC_TIP),
          getFunc = function() return self:ActiveSettings().showCalc end,
          setFunc = function(value) self:ActiveSettings().showCalc = value end,   
        },     
        -- Font to use
        [9] = {
          type = "dropdown",
          name = GetString(SK_WINDOW_FONT_NAME),
          tooltip = GetString(SK_WINDOW_FONT_TIP),
          choices = LMP:List(LMP.MediaType.FONT),
          getFunc = function() return self:ActiveSettings().windowFont end,
          setFunc = function(value)
            self:ActiveSettings().windowFont = value
            self:UpdateFonts()
            if self:ActiveSettings().viewSize == "full" then self.scrollList:RefreshVisible()
            else self.miniScrollList:RefreshVisible() end
          end,
        },
        -- Make all settings account-wide (or not)
        [10] = {
          type = "checkbox",
          name = GetString(SK_ACCOUNT_WIDE_NAME),
          tooltip = GetString(SK_ACCOUNT_WIDE_TIP),
          getFunc = function() return self.acctSavedVariables.allSettingsAccount end,
          setFunc = function(value)
            if value then
              self.acctSavedVariables.showChatAlerts = self.savedVariables.showChatAlerts
              self.acctSavedVariables.showChatAlerts = self.savedVariables.showMultiple
              self.acctSavedVariables.openWithMail = self.savedVariables.openWithMail
              self.acctSavedVariables.openWithStore = self.savedVariables.openWithStore
              self.acctSavedVariables.showFullPrice = self.savedVariables.showFullPrice
              self.acctSavedVariables.winLeft = self.savedVariables.winLeft
              self.acctSavedVariables.winTop = self.savedVariables.winTop
              self.acctSavedVariables.miniWinLeft = self.savedVariables.miniWinLeft
              self.acctSavedVariables.miniWinTop = self.savedVariables.miniWinTop
              self.acctSavedVariables.statsWinLeft = self.savedVariables.statsWinLeft
              self.acctSavedVariables.statsWinTop = self.savedVariables.statsWinTop
              self.acctSavedVariables.windowFont = self.savedVariables.windowFont
              self.acctSavedVariables.showCalc = self.savedVariables.showCalc
              self.acctSavedVariables.showPricing = self.savedVariables.showPricing
              self.acctSavedVariables.historyDepth = self.savedVariables.historyDepth
              self.acctSavedVariables.scanFreq = self.savedVariables.scanFreq
              self.acctSavedVariables.showAnnounceAlerts = self.savedVariables.showAnnounceAlerts
              self.acctSavedVariables.alertSoundName = self.savedVariables.alertSoundName
              self.acctSavedVariables.showUnitPrice = self.savedVariables.showUnitPrice
              self.acctSavedVariables.viewSize = self.savedVariables.viewSize
              self.acctSavedVariables.offlineSales = self.savedVariables.offlineSales
            else
              self.savedVariables.showChatAlerts = self.acctSavedVariables.showChatAlerts
              self.savedVariables.showChatAlerts = self.acctSavedVariables.showMultiple
              self.savedVariables.openWithMail = self.acctSavedVariables.openWithMail
              self.savedVariables.openWithStore = self.acctSavedVariables.openWithStore
              self.savedVariables.showFullPrice = self.acctSavedVariables.showFullPrice
              self.savedVariables.winLeft = self.acctSavedVariables.winLeft
              self.savedVariables.winTop = self.acctSavedVariables.winTop
              self.savedVariables.miniWinLeft = self.acctSavedVariables.miniWinLeft
              self.savedVariables.miniWinTop = self.acctSavedVariables.miniWinTop
              self.savedVariables.statsWinLeft = self.acctSavedVariables.statsWinLeft
              self.savedVariables.statsWinTop = self.acctSavedVariables.statsWinTop
              self.savedVariables.windowFont = self.acctSavedVariables.windowFont
              self.savedVariables.showPricing = self.acctSavedVariables.showPricing
              self.savedVariables.showCalc = self.acctSavedVariables.showCalc
              self.savedVariables.historyDepth = self.acctSavedVariables.historyDepth
              self.savedVariables.scanFreq = self.acctSavedVariables.scanFreq
              self.savedVariables.showAnnounceAlerts = self.acctSavedVariables.showAnnounceAlerts
              self.savedVariables.alertSoundName = self.acctSavedVariables.alertSoundName
              self.savedVariables.showUnitPrice = self.acctSavedVariables.showUnitPrice
              self.savedVariables.viewSize = self.acctSavedVariables.viewSize
              self.savedVariables.offlineSales = self.acctSavedVariables.offlineSales
            end
            self.acctSavedVariables.allSettingsAccount = value
          end,
        },
      }

      -- And make the options panel
      LAM:RegisterOptionControls("ShopkeeperOptions", optionsData)
    end
  end
end

-- Called after store scans complete, re-creates indexes if need be,
-- and updates the slider range. Once this is done it updates the
-- displayed table, sending a message to chat if the scan was initiated
-- via the 'refresh' or 'reset' buttons.
function Shopkeeper:PostScan(doAlert)
  -- If the index is blank (first scan after login or after reset),
  -- build the indexes now that we have a scanned table.
  if self.SRIndex == {} then Shopkeeper:indexHistoryTables() end
  local settingsToUse = Shopkeeper:ActiveSettings()
  if doAlert then CHAT_SYSTEM:AddMessage("[Shopkeeper] " .. GetString(SK_REFRESH_DONE)) end

  -- If there's anything in the alert queue, handle it.
  if #self.alertQueue > 0 then
    -- Play an alert chime once if there are any alerts in the queue
    if settingsToUse.showChatAlerts or settingsToUse.showAnnounceAlerts then
      PlaySound(settingsToUse.alertSoundName)
    end

    local numSold = 0
    local totalGold = 0
    local numAlerts = #self.alertQueue
    local lastEvent = {}
    for i = 1, numAlerts do
      local theEvent = table.remove(self.alertQueue, 1)
      numSold = numSold + 1

      -- Adjust the price if they want the post-cut prices instead
      local dispPrice = theEvent.salePrice
      if not settingsToUse.showFullPrice then
        local cutPrice = dispPrice * (1 - (GetTradingHouseCutPercentage() / 100))
        dispPrice = math.floor(cutPrice + 0.5)
      end
      totalGold = totalGold + dispPrice

      -- Offline sales report
      if self.isFirstScan and settingsToUse.offlineSales then
        local stringPrice = self.LocalizedNumber(dispPrice)
        local textTime = self.TextTimeSince(theEvent.saleTime, true)
        if i == 1 then CHAT_SYSTEM:AddMessage("[Shopkeeper] " .. GetString(SK_SALES_REPORT)) end
        CHAT_SYSTEM:AddMessage(zo_strformat("<<t:1>>", theEvent.itemName) .. " x" .. theEvent.quant .. " -- " .. stringPrice .. " |t16:16:EsoUI/Art/currency/currency_gold.dds|t -- " .. theEvent.guild)
        if i == numAlerts then CHAT_SYSTEM:AddMessage("[Shopkeeper] " .. GetString(SK_SALES_REPORT_END)) end

      -- Subsequent scans
      else
        -- If they want multiple alerts, we'll alert on each loop iteration
        -- or if there's only one.
        if settingsToUse.showMultiple or numAlerts == 1 then
          -- Insert thousands separators for the price
          local stringPrice = self.LocalizedNumber(dispPrice)

          -- On-screen alert; map index 37 is Cyrodiil
          if settingsToUse.showAnnounceAlerts and
            (settingsToUse.showCyroAlerts or GetCurrentMapZoneIndex ~= 37) then

            -- We'll add a numerical suffix to avoid queueing two identical messages in a row
            -- because the alerts will 'miss' if we do
            local textTime = self.TextTimeSince(theEvent.saleTime, true)
            local alertSuffix = ""
            if lastEvent[1] ~= nil and theEvent.itemName == lastEvent[1].itemName and textTime == lastEvent[2] then
              lastEvent[3] = lastEvent[3] + 1
              alertSuffix = " (" .. lastEvent[3] .. ")"
            else
              lastEvent[1] = theEvent
              lastEvent[2] = textTime
              lastEvent[3] = 1
            end
            -- German word order differs so argument order also needs to be changed
            -- Also due to plurality differences in German, need to differentiate
            -- single item sold vs. multiple of an item sold.
            if self.locale == "de" then
              if theEvent.quant > 1 then
                CENTER_SCREEN_ANNOUNCE:AddMessage("ShopkeeperAlert", CSA_EVENT_SMALL_TEXT, SOUNDS.NONE,
                  string.format(GetString(SK_SALES_ALERT_COLOR), theEvent.quant, zo_strformat("<<t:1>>", theEvent.itemName),
                                stringPrice, theEvent.guild, textTime) .. alertSuffix)
              else
                CENTER_SCREEN_ANNOUNCE:AddMessage("ShopkeeperAlert", CSA_EVENT_SMALL_TEXT, SOUNDS.NONE,
                  string.format(GetString(SK_SALES_ALERT_SINGLE_COLOR),zo_strformat("<<t:1>>", theEvent.itemName),
                                stringPrice, theEvent.guild, textTime) .. alertSuffix)
              end
            else
              CENTER_SCREEN_ANNOUNCE:AddMessage("ShopkeeperAlert", CSA_EVENT_SMALL_TEXT, SOUNDS.NONE,
                string.format(GetString(SK_SALES_ALERT_COLOR), zo_strformat("<<t:1>>", theEvent.itemName),
                              theEvent.quant, stringPrice, theEvent.guild, textTime) .. alertSuffix)
            end
          end

          -- Chat alert
          if settingsToUse.showChatAlerts then
            if self.locale == "de" then
              if theEvent.quant > 1 then
                CHAT_SYSTEM:AddMessage(string.format("[Shopkeeper] " .. GetString(SK_SALES_ALERT),
                                      theEvent.quant, zo_strformat("<<t:1>>", theEvent.itemName), stringPrice, theEvent.guild, self.TextTimeSince(theEvent.saleTime, true)))
              else
                CHAT_SYSTEM:AddMessage(string.format("[Shopkeeper] " .. GetString(SK_SALES_ALERT_SINGLE),
                                      zo_strformat("<<t:1>>", theEvent.itemName), stringPrice, theEvent.guild, self.TextTimeSince(theEvent.saleTime, true)))
              end
            else
              CHAT_SYSTEM:AddMessage(string.format("[Shopkeeper] " .. GetString(SK_SALES_ALERT),
                                    zo_strformat("<<t:1>>", theEvent.itemName), theEvent.quant, stringPrice, theEvent.guild, self.TextTimeSince(theEvent.saleTime, true)))
            end
          end
        end
      end

      -- Otherwise, we'll just alert once with a summary at the end
      if not settingsToUse.showMultiple and numAlerts > 1 then
        -- Insert thousands separators for the price
        local stringPrice = self.LocalizedNumber(totalGold)

        if settingsToUse.showAnnounceAlerts then
          CENTER_SCREEN_ANNOUNCE:AddMessage("ShopkeeperAlert", CSA_EVENT_SMALL_TEXT, settingsToUse.alertSoundName,
            string.format(GetString(SK_SALES_ALERT_GROUP_COLOR), numSold, stringPrice))
        else
          CHAT_SYSTEM:AddMessage(string.format("[Shopkeeper] " .. GetString(SK_SALES_ALERT_GROUP),
                                numSold, stringPrice))
        end
      end
    end
  end

  -- Set the stats slider past the max if this is brand new data
  if self.isFirstScan and doAlert then ShopkeeperStatsWindowSlider:SetValue(14) end
  self.isFirstScan = false
  -- We only have to refresh scroll list data if the window is actually visible; methods
  -- to show these windows refresh data before display
  if settingsToUse.viewSize == "full" then
    if not ShopkeeperWindow:IsHidden() then self.scrollList:RefreshData()
    else self.listIsDirty["full"] = true end
    self.listIsDirty["mini"] = true
  else
    if not ShopkeeperMiniWindow:IsHidden() then self.miniScrollList:RefreshData()
    else self.listIsDirty["mini"] = true end
    self.listIsDirty["full"] = true
  end
end

-- Makes sure all the necessary data is there, and adds the passed-in event theEvent
-- to the SalesData table.  If doAlert is true, also adds it to alertQueue,
-- which means an alert may fire during PostScan.
function Shopkeeper:InsertEvent(theEvent, doAlert)
  local thePlayer = string.lower(GetDisplayName())
  local settingsToUse = Shopkeeper:ActiveSettings()

  if theEvent.itemName ~= nil and theEvent.seller ~= nil and theEvent.buyer ~= nil and theEvent.salePrice ~= nil then
    -- Insert the entry into the SalesData table and associated indexes
    Shopkeeper:addToHistoryTables(theEvent)

    -- And then, if it's the player's sale, check here if it's the initial
    -- scan and they want offline sales reports, or if they've enabled chat/on-screen alerts
    -- and it's appropriate to do so (doAlert is false for resets so you don't get spammed.)
    -- If so, add the event to the alert queue for PostScan to pick up.
    if string.lower(theEvent.seller) == thePlayer and ((self.isFirstScan and settingsToUse.offlineSales) or
       (doAlert and (settingsToUse.showChatAlerts or settingsToUse.showAnnounceAlerts))) then
        table.insert(self.alertQueue, theEvent)
    end
  end
end

-- Actually carries out of the scan of a specific guild store's sales history.
-- Grabs all the members of the guild first to determine if a sale came from the
-- guild's kiosk (guild trader) or not.
-- Calls InsertEvent to actually insert the event into the ScanResults table;
-- afterwards, will start scan of the next guild or call postscan if no more guilds.
function Shopkeeper:DoScan(guildNum, checkOlder, doAlert)
  local guildID = GetGuildId(guildNum)
  local numEvents = GetNumGuildEvents(guildID, GUILD_HISTORY_STORE)
  local guildName = GetGuildName(guildID)
  local prevEvents = 0

  if self.numEvents[guildName] ~= nil then prevEvents = self.numEvents[guildName] end

  if numEvents > prevEvents then
    local guildMemberInfo = {}
    -- Index the table with the account names themselves as they're
    -- (hopefully!) unique - search much faster
    for i = 1, GetNumGuildMembers(guildID) do
      local guildMemInfo, _, _, _, _ = GetGuildMemberInfo(guildID, i)
      guildMemberInfo[string.lower(guildMemInfo)] = true
    end

    -- Depending on what order the API returned events in, new events
    -- are either at the start (index 1 is newest item) or the end
    -- (last index is the newest item).  Really ZOS?
    local startIndex = prevEvents + 1
    local endIndex = numEvents
    local loopIncrement = 1
    if self.IsNewestFirst(guildID) then
      startIndex = numEvents - prevEvents
      endIndex = 1
      loopIncrement = -1
    end

    -- We'll grab the most recent sale from this guild, if any, to use as a timestamp
    -- to check against.  If no data can be found for this guild, we'll default
    -- to the time of the last scan (little less precise).
    local lastSaleTime = self.acctSavedVariables.lastScan[guildName]
    if self.acctSavedVariables.newestItem[guildName] ~= nil then lastSaleTime = self.acctSavedVariables.newestItem[guildName] end

    for i = startIndex, endIndex, loopIncrement do
      local theEvent = {}
      theEvent.eventType, theEvent.secsSince, theEvent.seller, theEvent.buyer,
      theEvent.quant, theEvent.itemName, theEvent.salePrice = GetGuildEventInfo(guildID, GUILD_HISTORY_STORE, i)
      theEvent.guild = guildName
      theEvent.saleTime = self.requestTimestamp - theEvent.secsSince

      -- If we're starting at the start of the list, event 1 is the newest, so update
      -- the newestItem variable
      if (endIndex == 1 and i == 1) or (endIndex ~= 1 and i == endIndex) then
        self.acctSavedVariables.newestItem[guildName] = theEvent.saleTime
      end

      if theEvent.eventType ~= GUILD_HISTORY_STORE_HIRED_TRADER then

        -- If we didn't add an entry to guildMemberInfo earlier setting the
        -- buyer's name index to true, then this was either bought at a kiosk
        -- or the buyer left the guild after buying but before we scanned.
        -- Close enough!
        theEvent.kioskSale = (guildMemberInfo[string.lower(theEvent.buyer)] == nil)

        -- Now that we know when the last sale in that guild happened, check the timestamp of this event against that one.
        -- Yes, we'll miss sales that happened the SAME second as one we've already seen but somehow didn't get with the
        -- previous scan, but that's life. :P  If checkOlder is true, then we'll call InsertEvent with the second parameter
        -- false so it knows not to add it to the alert queue (unless it's the first scan after login and they want an
        -- offline sales report).
        if self.acctSavedVariables.lastScan[guildName] == nil or GetDiffBetweenTimeStamps(theEvent.saleTime, lastSaleTime) > 1 then
          self:InsertEvent(theEvent, (not checkOlder))
        end
      end
    end
  end

  -- We got through any new (to us) events, so update the timestamp and number of events
  self.acctSavedVariables.lastScan[guildName] = self.requestTimestamp
  self.numEvents[guildName] = numEvents

  -- If we have another guild to scan, see if we need to check older and scan it
  if guildNum < GetNumGuilds() then
    local nextGuild = guildNum + 1
    local nextGuildID = GetGuildId(nextGuild)
    local nextGuildName = GetGuildName(nextGuildID)

    -- If we don't have any event info for the next guild, do a deep scan
    local nextCheckOlder = (self.numEvents[nextGuildName] == nil or self.numEvents[nextGuildName] == 0)
    self.requestTimestamp = GetTimeStamp()
    RequestGuildHistoryCategoryNewest(nextGuildID, GUILD_HISTORY_STORE)
    if nextCheckOlder then zo_callLater(function() self:ScanOlder(nextGuild, doAlert) end, 1500)
    else zo_callLater(function() self:DoScan(nextGuild, false, doAlert) end, 1500) end
  -- Otherwise, start the postscan routines
  else
    self.isScanning = false
    ShopkeeperResetButton:SetEnabled(true)
    ShopkeeperMiniResetButton:SetEnabled(true)
    ShopkeeperRefreshButton:SetEnabled(true)
    ShopkeeperMiniRefreshButton:SetEnabled(true)
		ShopkeeperWindowLoadingIcon:SetHidden(true)
		ShopkeeperWindowLoadingIcon.animation:Stop()
		ShopkeeperMiniWindowLoadingIcon:SetHidden(true)
		ShopkeeperMiniWindowLoadingIcon.animation:Stop()
    self:PostScan(doAlert)
  end
end

-- Repeatedly checks for older events until there aren't anymore,
-- then calls DoScan to pick up sales events
function Shopkeeper:ScanOlder(guildNum, doAlert)
  local guildID = GetGuildId(guildNum)
  local guildName = GetGuildName(guildID)
  local numEvents = GetNumGuildEvents(guildID, GUILD_HISTORY_STORE)
  local _, secsSinceFirst, _, _, _, _, _, _ = GetGuildEventInfo(guildID, GUILD_HISTORY_STORE, 1)
  local _, secsSinceLast, _, _, _, _, _, _ = GetGuildEventInfo(guildID, GUILD_HISTORY_STORE, numEvents)
  local timeToUse = secsSinceFirst
  -- Events come in reverse order until new ones are added to the history after login.
  -- I have *no* idea why, I just go with it.
  if self.IsNewestFirst(guildID) then timeToUse = secsSinceLast end
  if numEvents > 0 then
    -- If there's more events and we haven't run past the timestamp we've seen
    -- previously, recurse.
    if DoesGuildHistoryCategoryHaveMoreEvents(guildID, GUILD_HISTORY_STORE) and
       (self.acctSavedVariables.lastScan[guildName] == nil or
        (GetTimeStamp() - timeToUse) > self.acctSavedVariables.lastScan[guildName]) then
      RequestGuildHistoryCategoryOlder(guildID, GUILD_HISTORY_STORE)
      zo_callLater(function() self:ScanOlder(guildNum, doAlert) end, 1500)
    -- Otherwise we've got all the new stuff, so call DoScan.
    else zo_callLater(function() self:DoScan(guildNum, true, doAlert) end, 1500) end
  -- If there's no events in the guild, call DoScan just so later guilds get scanned
  -- Don't really need a delay in this case.
  else self:DoScan(guildNum, true, doAlert) end
end

-- Scans all stores a player has access to with delays between them.
function Shopkeeper:ScanStores(doAlert)
  -- If it's been less than 45 seconds since we last scanned the store,
  -- don't do it again so we don't hammer the server either accidentally
  -- or on purpose
  local timeLimit = GetTimeStamp() - 45
  local guildNum = GetNumGuilds()
  -- Nothing to scan!
  if guildNum == 0 then return end

  -- Grab some info about the first guild (since we now know there's at least one)
  local firstGuildID = GetGuildId(1)
  local firstGuildName = GetGuildName(firstGuildID)

  -- Right, let's actually request some events, assuming we haven't already done so recently
  if not self.isScanning and ((self.acctSavedVariables.lastScan[firstGuildName] == nil) or (timeLimit > self.acctSavedVariables.lastScan[firstGuildName])) then
    self.isScanning = true
    ShopkeeperResetButton:SetEnabled(false)
    ShopkeeperMiniResetButton:SetEnabled(false)
    ShopkeeperRefreshButton:SetEnabled(false)
    ShopkeeperMiniRefreshButton:SetEnabled(false)
		ShopkeeperWindowLoadingIcon:SetHidden(false)
		ShopkeeperWindowLoadingIcon.animation:PlayForward()
		ShopkeeperMiniWindowLoadingIcon:SetHidden(false)
		ShopkeeperMiniWindowLoadingIcon.animation:PlayForward()

    self.requestTimestamp = GetTimeStamp()
    RequestGuildHistoryCategoryNewest(firstGuildID, GUILD_HISTORY_STORE)

    -- If we have no event info for this guild, let's do a full scan
    if self.numEvents[firstGuildName] == nil or self.numEvents[firstGuildName] == 0 then zo_callLater(function() self:ScanOlder(1, doAlert) end, 1500)
    -- Otherwise we'll assume 100 events haven't gone by since the last scan and just go straight to DoScan
    else zo_callLater(function() self:DoScan(1, false, doAlert) end, 1500) end
  end
end

-- Handle the refresh button - do a scan if it's been more than a minute
-- since the last successful one.
function Shopkeeper:DoRefresh()
  local timeStamp = GetTimeStamp()

  -- If it's been less than 30 seconds since we last scanned the store,
  -- don't do it again so we don't hammer the server either accidentally
  -- or on purpose, otherwise add a message to chat updating the user and
  -- kick off the scan
  local timeLimit = timeStamp - 29
  local guildNum = GetNumGuilds()
  if guildNum > 0 then
    local firstGuildName = GetGuildName(1)
    if self.acctSavedVariables.lastScan[firstGuildName] == nil or timeLimit > self.acctSavedVariables.lastScan[firstGuildName] then
      CHAT_SYSTEM:AddMessage("[Shopkeeper] " .. GetString(SK_REFRESH_START))
      self:ScanStores(true)

    else CHAT_SYSTEM:AddMessage("[Shopkeeper] " .. GetString(SK_REFRESH_WAIT)) end
  end
end

function Shopkeeper:initGMTools()
  -- Stub for GM Tools init
end

function Shopkeeper:initPurchaseTracking()
  -- Stub for Purchase Tracking init
end

-- Handle the reset button - clear out the search and scan tables,
-- and set the time of the last scan to nil, then force a scan.
function Shopkeeper:DoReset()
  self.acctSavedVariables.SalesData = {}
  self.SRIndex = {}
  self.SSIndex = {}
  self.acctSavedVariables.lastScan = {}
  if ShopkeeperMiniWindow:IsHidden() then Shopkeeper.scrollList:RefreshData()
  else Shopkeeper.miniScrollList:RefreshData() end
  self.isScanning = false
  self.numEvents = {}
  self.acctSavedVariables.newestItem = {}
  CHAT_SYSTEM:AddMessage("[Shopkeeper] " .. GetString(SK_RESET_DONE))
  CHAT_SYSTEM:AddMessage("[Shopkeeper] " .. GetString(SK_REFRESH_START))
  self:ScanStores(true)
end

-- Init function
function Shopkeeper:Initialize()
  -- SavedVar defaults
  local Defaults =  {
    ["showChatAlerts"] = false,
    ["showMultiple"] = true,
    ["openWithMail"] = true,
    ["openWithStore"] = true,
    ["showFullPrice"] = true,
    ["winLeft"] = 30,
    ["winTop"] = 30,
    ["miniWinLeft"] = 30,
    ["miniWinTop"] = 30,
    ["statsWinLeft"] = 720,
    ["statsWinTop"] = 820,
    ["windowFont"] = "ProseAntique",
    ["historyDepth"] = 30,
    ["scanFreq"] = 120,
    ["showAnnounceAlerts"] = true,
    ["showCyroAlerts"] = true,
    ["alertSoundName"] = "Book_Acquired",
    ["showUnitPrice"] = false,
    ["viewSize"] = "full",
    ["offlineSales"] = true,
    ["showPricing"] = true,
    ["showCalc"] = true,
  }

  local acctDefaults = {
    ["lastScan"] = {},
    ["newestItem"] = {},
    ["SalesData"] = {},
    ["SSIndex"] = {},
    ["allSettingsAccount"] = false,
    ["showChatAlerts"] = false,
    ["showMultiple"] = true,
    ["openWithMail"] = true,
    ["openWithStore"] = true,
    ["showFullPrice"] = true,
    ["winLeft"] = 30,
    ["winTop"] = 30,
    ["miniWinLeft"] = 30,
    ["miniWinTop"] = 30,
    ["statsWinLeft"] = 720,
    ["statsWinTop"] = 820,
    ["windowFont"] = "ProseAntique",
    ["historyDepth"] = 30,
    ["scanFreq"] = 120,
    ["showAnnounceAlerts"] = true,
    ["showCyroAlerts"] = true,
    ["alertSoundName"] = "Book_Acquired",
    ["showUnitPrice"] = false,
    ["viewSize"] = "full",
    ["offlineSales"] = true,
    ["showPricing"] = true,
    ["showCalc"] = true,
  }

  -- Populate savedVariables
  self.savedVariables = ZO_SavedVars:New("ShopkeeperSavedVars", 1, GetDisplayName(), Defaults)
  self.acctSavedVariables = ZO_SavedVars:NewAccountWide("ShopkeeperSavedVars", 1, GetDisplayName(), acctDefaults)

  -- Convert the old linear sales history to the new format
  if self.acctSavedVariables.scanHistory then
    for i = 1, #self.acctSavedVariables.scanHistory do
      local v = self.acctSavedVariables.scanHistory[i]
      local theIID = string.match(v[3], "|H.-:item:(.-):")
      theIID = tonumber(theIID)
      local itemIndex = self.makeIndexFromLink(v[3])
      if not self.acctSavedVariables.SalesData[theIID] then self.acctSavedVariables.SalesData[theIID] = {} end
      if Shopkeeper.acctSavedVariables.SalesData[theIID][itemIndex] then
        table.insert(Shopkeeper.acctSavedVariables.SalesData[theIID][itemIndex]["sales"],
          {buyer = v[1], guild = v[2], itemLink = v[3], quant = v[5], timestamp = v[6], price = v[7], seller = v[8], wasKiosk = v[9]})
      else
        Shopkeeper.acctSavedVariables.SalesData[theIID][itemIndex] = {
          ["itemIcon"] = v[4],
          ["sales"] = {{buyer = v[1], guild = v[2], itemLink = v[3], quant = v[5], timestamp = v[6], price = v[7], seller = v[8], wasKiosk = v[9]}}}
      end

      -- We track newest sales items in a savedVar now since we don't have a linear list to easily grab from
      if not self.acctSavedVariables.newestItem[v[2]] then self.acctSavedVariables.newestItem[v[2]] = v[6]
      elseif self.acctSavedVariables.newestItem[v[2]] < v[6] then self.acctSavedVariables.newestItem[v[2]] = v[6] end
    end

    -- Now that we're done with it, clear it out and change the one setting that has changed in magnitude
    self.acctSavedVariables.scanHistory = nil
    Shopkeeper:ActiveSettings().historyDepth = 30
  end

  -- Rather than constantly managing the length of the history, we'll just
  -- truncate it once at init-time.  As a result it will fluctuate in size
  -- depending on how active guild stores are and how long someone plays for
  -- at a time, but that's OK as it shouldn't impact performance too severely
  -- unless someone plays for 24+ hours straight (and I've yet to see the game
  -- client last anywhere near that :P )
  local epochBack = GetTimeStamp() - (86400 * (self:ActiveSettings().historyDepth + 1))
  for k, v in pairs(self.acctSavedVariables.SalesData) do
    for j, dataList in pairs(v) do
      -- We iterate backwards here so we can remove entries without breaking
      -- the for loop
      for i = #dataList['sales'], 1, -1 do
        if dataList['sales'][i]['timestamp'] < epochBack then table.remove(dataList['sales'], i) end
      end
      -- If we just deleted all instances of this ID/data combo, clear the bucket out
      if #dataList['sales'] < 1 then v[j] = nil end
    end
    -- Similarly, if we just deleted all data combos of this ID, clear the bucket out
    if NonContiguousCount(v) < 1 then self.acctSavedVariables.SalesData[k] = nil end
  end

  -- We'll grab their locale now, it's really only used for a couple things as
  -- most localization is handled by the i18n/$(language).lua files
  -- Defaults to English because bias, that's why. :P
  self.locale = GetCVar('Language.2')
  if self.locale ~= "en" and self.locale ~= "de" and self.locale ~= "fr" then
    self.locale = "en"
  end

  -- And index for search
  Shopkeeper:indexHistoryTables()

  -- Setup the options menu and main windows
  self:LibAddonInit()
  self:SetupShopkeeperWindow()
  self:RestoreWindowPosition()

  -- Add the shopkeeper window to the mail and trading house scenes if the
  -- player's settings indicate they want that behavior
  self.uiFragment = ZO_FadeSceneFragment:New(ShopkeeperWindow)
  self.miniUiFragment = ZO_FadeSceneFragment:New(ShopkeeperMiniWindow)

  local settingsToUse = Shopkeeper:ActiveSettings()
  if settingsToUse.openWithMail then
    if settingsToUse.viewSize == "full" then
      MAIL_INBOX_SCENE:AddFragment(self.uiFragment)
      MAIL_SEND_SCENE:AddFragment(self.uiFragment)
    else
      MAIL_INBOX_SCENE:AddFragment(self.miniUiFragment)
      MAIL_SEND_SCENE:AddFragment(self.miniUiFragment)
    end
  end

  if settingsToUse.openWithStore then
    if settingsToUse.viewSize == "full" then
      TRADING_HOUSE_SCENE:AddFragment(self.uiFragment)
    else
      TRADING_HOUSE_SCENE:AddFragment(self.miniUiFragment)
    end
  end

  -- Because we allow manual toggling of the Shopkeeper window in those scenes (without
  -- making that setting permanent), we also have to hide the window on closing them
  -- if they're not part of the scene.
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_MAIL_CLOSE_MAILBOX, function()
    if not settingsToUse.openWithMail then 
      self:ActiveWindow():SetHidden(true)
      ShopkeeperStatsWindow:SetHidden(true)
    end
  end)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CLOSE_TRADING_HOUSE, function()
    if not settingsToUse.openWithStore then 
      self:ActiveWindow():SetHidden(true)
      ShopkeeperStatsWindow:SetHidden(true)
    end
  end)

  -- We also want to make sure the Shopkeeper windows are hidden in the game menu
  ZO_PreHookHandler(ZO_GameMenu_InGame, "OnShow", function()
    self:ActiveWindow():SetHidden(true)
    ShopkeeperStatsWindow:SetHidden(true)
  end)

  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_TRADING_HOUSE_PENDING_ITEM_UPDATE, function (eventCode, slotId, isPending)
    if settingsToUse.showCalc and isPending and GetSlotStackSize(1, slotId) > 1 then
      local theLink = GetItemLink(1, slotId, LINK_STYLE_DEFAULT)
      local theIID = string.match(theLink, "|H.-:item:(.-):")
      local theIData = self.makeIndexFromLink(theLink)
      local postedStats = self:toolTipStats(tonumber(theIID), theIData)
      ShopkeeperPriceCalculatorStack:SetText("x " .. GetSlotStackSize(1, slotId))
      local floorPrice = 0
      if postedStats then floorPrice = math.floor(postedStats['avgPrice']) end
      ShopkeeperPriceCalculatorUnitCostAmount:SetText(floorPrice)
      ShopkeeperPriceCalculatorTotal:SetText("Total: " .. self.LocalizedNumber(floorPrice * GetSlotStackSize(1, slotId)) .. " |t16:16:EsoUI/Art/currency/currency_gold.dds|t")
      ShopkeeperPriceCalculator:SetHidden(false)
    else ShopkeeperPriceCalculator:SetHidden(true) end
  end)
  
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_TRADING_HOUSE_RESPONSE_RECEIVED, function (_, responseType, result)
    if responseType == TRADING_HOUSE_RESULT_POST_PENDING and result == TRADING_HOUSE_RESULT_SUCCESS then ShopkeeperPriceCalculator:SetHidden(true) end
  end)

  -- I could do this with action layer pop/push, but it's kind've a pain
  -- when it's just these I want to hook
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CLOSE_BANK, function() self:ActiveWindow():SetHidden(true) end)
--    ShopkeeperWindow:SetHidden(true)
--    ShopkeeperMiniWindow:SetHidden(true)
--  end)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CLOSE_GUILD_BANK, function() self:ActiveWindow():SetHidden(true) end)
--    ShopkeeperWindow:SetHidden(true)
--    ShopkeeperMiniWindow:SetHidden(true)
--  end)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CLOSE_STORE, function() self:ActiveWindow():SetHidden(true) end)
--    ShopkeeperWindow:SetHidden(true)
--    ShopkeeperMiniWindow:SetHidden(true)
--  end)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_END_CRAFTING_STATION_INTERACT, function() self:ActiveWindow():SetHidden(true) end)
--    ShopkeeperWindow:SetHidden(true)
--    ShopkeeperMiniWindow:SetHidden(true)
--  end)

  -- We'll add stats to tooltips for items we have data for, if desired
  ZO_PreHookHandler(PopupTooltip, 'OnUpdate', function() self:addStatsPopupTooltip() end)
	ZO_PreHookHandler(PopupTooltip, 'OnHide', function() self:remStatsPopupTooltip() end)
  ZO_PreHookHandler(ItemTooltip, 'OnUpdate', function() self:addStatsItemTooltip() end)
	ZO_PreHookHandler(ItemTooltip, 'OnHide', function() self:remStatsItemTooltip() end)
	
  -- Set up GM Tools, if also installed
  self:initGMTools()

  -- Set up purchase tracking, if also installed
  self:initPurchaseTracking()

  -- Right, we're all set up, so wait for the player activated event
  -- and then do an initial (deep) scan in case it's been a while since the player
  -- logged on, then use RegisterForUpdate to set up a timed scan.
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function() 
    self.isFirstScan = self:ActiveSettings().offlineSales
    if NonContiguousCount(self.acctSavedVariables.SalesData) > 0 then self:ScanStores(false)
    else
      CHAT_SYSTEM:AddMessage("[Shopkeeper] " .. GetString(SK_FIRST_SCAN))
      self:ScanStores(true)
    end                           
		EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_PLAYER_ACTIVATED )
		
    -- RegisterForUpdate lets us scan at a given interval (in ms), so we'll use that to
    -- keep the sales history updated
    local scanInterval = self:ActiveSettings().scanFreq * 1000
    EVENT_MANAGER:RegisterForUpdate(self.name, scanInterval, function() self:ScanStores(false) end)
	end)  
end


-------------------------------------------------------------------------------
-- LMP - Removed Fonts v1.1
-------------------------------------------------------------------------------
--
-- Copyright (c) 2014 Ales Machat (Garkin)
--
-- Permission is hereby granted, free of charge, to any person
-- obtaining a copy of this software and associated documentation
-- files (the "Software"), to deal in the Software without
-- restriction, including without limitation the rights to use,
-- copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the
-- Software is furnished to do so, subject to the following
-- conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
-- OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
-- NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
-- HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
-- WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- OTHER DEALINGS IN THE SOFTWARE.


local function OnAddOnLoaded(eventCode, addOnName)
   if addOnName:find("^ZO_") then return end
   if addOnName == Shopkeeper.name then
        Shopkeeper:Initialize()
   end
   
   local LMP = LibStub("LibMediaProvider-1.0")

   --if the first loaded version of LibMediaProvider was r6 and older, fonts are
   --already registered, but with invalid paths.
   if LMP.MediaTable.font["Arial Narrow"]     then LMP.MediaTable.font["Arial Narrow"]     = "Shopkeeper/Fonts/arialn.ttf"               end
   if LMP.MediaTable.font["ESO Cartographer"] then LMP.MediaTable.font["ESO Cartographer"] = "Shopkeeper/Fonts/esocartographer-bold.otf" end
   if LMP.MediaTable.font["Fontin Bold"]      then LMP.MediaTable.font["Fontin Bold"]      = "Shopkeeper/Fonts/fontin_sans_b.otf"        end
   if LMP.MediaTable.font["Fontin Italic"]    then LMP.MediaTable.font["Fontin Italic"]    = "Shopkeeper/Fonts/fontin_sans_i.otf"        end
   if LMP.MediaTable.font["Fontin Regular"]   then LMP.MediaTable.font["Fontin Regular"]   = "Shopkeeper/Fonts/fontin_sans_r.otf"        end
   if LMP.MediaTable.font["Fontin SmallCaps"] then LMP.MediaTable.font["Fontin SmallCaps"] = "Shopkeeper/Fonts/fontin_sans_sc.otf"       end

   --LMP r7 and above doesn't have fonts registered yet
   LMP:Register("font", "Arial Narrow",           "Shopkeeper/Fonts/arialn.ttf")
   LMP:Register("font", "ESO Cartographer",       "Shopkeeper/Fonts/esocartographer-bold.otf")
   LMP:Register("font", "Fontin Bold",            "Shopkeeper/Fonts/fontin_sans_b.otf")
   LMP:Register("font", "Fontin Italic",          "Shopkeeper/Fonts/fontin_sans_i.otf")
   LMP:Register("font", "Fontin Regular",         "Shopkeeper/Fonts/fontin_sans_r.otf")
   LMP:Register("font", "Fontin SmallCaps",       "Shopkeeper/Fonts/fontin_sans_sc.otf")

   --this game font is missing in all versions of LMP
   LMP:Register("font", "Futura Condensed Bold",  "EsoUI/Common/Fonts/FuturaStd-CondensedBold.otf")
end

-- Event handler for the OnAddOnLoaded event
--function Shopkeeper.OnAddOnLoaded(event, addonName)
--  if addonName == Shopkeeper.name then
--    Shopkeeper:Initialize()
----end
--end

-- Register for the OnAddOnLoaded event
EVENT_MANAGER:RegisterForEvent(Shopkeeper.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

-- Set up /shopkeeper as a slash command toggle for the main window
SLASH_COMMANDS["/shopkeeper"] = function() Shopkeeper:ToggleShopkeeperWindow() end