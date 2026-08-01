-- Ideas:
-- - Inventory Goals per type, like Raw materials, alchemy, etc...
-- TODO: Test disabling all features....
PXInfoPanelAddon = {
  Name = "PXInfoPanel",
  Version = "1.0.17",
  DividerLine = '-----------------------------------------------------------------------------',
  StartTimeMS = 0,
  TimeElapsedMS = 0,
  TimeElapsedInZoneMS = 0,
  TotalGoldMade = 0,
  StartGold = 0,
  StartXP = 0,
  StartAP = 0,
  XpNeededForNextLevel = 0,
  CurrentXP = 0,
  CurrentAP = 0,
  MaxXP = 0,
  LastGold = 0,
  LastWritVouchers = 0,
  Showing = true,
  LastLoot = '',
  LastLootLogged = '',
  LastLoot2 = '',
  LastLoot3 = '',
  LastLoot4 = '',
  LastLoot5 = '',
  BestLoot = '',
  BestLoot2 = '',
  BestLoot3 = '',
  BestLoot4 = '',
  BestLoot5 = '',
  BestLootWorth = 0,
  BestLootWorth2 = 0,
  BestLootWorth3 = 0,
  BestLootWorth4 = 0,
  BestLootWorth5 = 0,
  LastLoreBookLearned = '',
  GoldIconText = zo_iconTextFormat("esoui/art/bank/bank_tabicon_gold_up.dds", 32, 32, " "),
  EarnedAchievementPoints = 0,
  TotAchievementPoints = 0,
  IsEnlightenedAvailableForCharacter = false,
  EnlightenedPool = 0,
  HasBeenNotifiedAboutNoEnlightenment = false,
  WritStatusText = '',
  PVPInfo = {},
  PVPLastAchievementUpdate = GetTimeStamp(),
  PVPLastAchievementId = -1,
  CurrentZone = '',
  CurrentSubZone = '',
  ZoneStartTime = 0,
  SurveyInfo = {
    CountInZone = 0,
    StackCountInZone = 0,
    LocationsInZone = 0,
    CountInZoneDone = 0,
    TimeLeftInZoneMinutes = 0,
    TimeElapsed = 0,
  },

  ColorGold   = '|cd8b620',
  ColorGreen  = '|c28b712',
  ColorOrange = '|cf7952c',
  ColorRed    = '|cd61b1b',
  ColorWhite  = '|cffffff',
  ColorBlue   = '|c2d64bc',

  DefaultSettings = {
    lastLoggedIn = GetTimeStamp(),
    allWritsDoneNotified = false,
    left = 5,
    top = 20,

    fontColor = ZO_ColorDef:New("FFFFFF"),
    fontScale = 1,
    transparency = 0,
    showTime = true,
    showLastLoot = true,
    showLastLootInChat = false,
    showLastLootAndGoldInChat = false,
    showLastLootTrait = false,
    showBestLoot = true,
    showBestLoot2 = false,
    showBestLoot3 = false,
    showBestLoot4 = false,
    showBestLoot5 = false,
    showBestLootNotification = true,
    showMaterialInventory = true,
    showMaterialInventoryCondensed = true,
    showAchievements = true,
    showEnlightenedPool = true,
    showTotalMinutesPlayed = true,
    showTotalZoneMinutesPlayed = false,
    showTotalGoldMade = true,
    showTotalXPMade = true,
    showTotalWritVouchers = true,
    showLastLoreBookLearned = false,
    showPVPInfo = false,
    showPVPInfoOnlyWhenInPVP = false,
    showPVPRank = false,
    showPVPQueueTimeWhenQueued = false,
    notifyOnLootAbove = 1000,
    playSoundOnNotifyOnLootAbove = false,
    notifyOnLoreBooks = true,
    showWritStatus = true,
    showWritStatusCondensed = true,
    showLevelProgress = true,
    showGrindStatus = true,
    hideInfoPanelWhenViewInventory = false,
    showGroupLoot = false,
    lastLootLines = 1,
    showAchievementProgressInChat = false,
    customMonitor1 = { Show = false, SearchText = '', DisplayText = '', Count = 0 },
    customMonitor2 = { Show = false, SearchText = '', DisplayText = '', Count = 0 },
    customMonitor3 = { Show = false, SearchText = '', DisplayText = '', Count = 0 },
    customMonitor4 = { Show = false, SearchText = '', DisplayText = '', Count = 0 },
    customMonitor5 = { Show = false, SearchText = '', DisplayText = '', Count = 0 },
    customMonitor6 = { Show = false, SearchText = '', DisplayText = '', Count = 0 },
    customMonitor7 = { Show = false, SearchText = '', DisplayText = '', Count = 0 },
    customMonitor8 = { Show = false, SearchText = '', DisplayText = '', Count = 0 },
    customMonitor9 = { Show = false, SearchText = '', DisplayText = '', Count = 0 },
    customMonitor10 = { Show = false, SearchText = '', DisplayText = '', Count = 0 },
    enableVendorAutomation = false,
    vendorAutomationMaxGold = 100,
    vendorAutomationMaxUnitPrice = 10,
    vendorAutomationInventoryCount = 10,
    enableVendorAutomationDebugging = false,
    enableMonitorResearch = false,
    enableMonitorResearchBlacksmithing = false,
    enableMonitorResearchClothing = false,
    enableMonitorResearchWoodworking = false,
    enableMonitorResearchAlchemy = false,
    enableMonitorResearchEnchanting = false,
    enableMonitorResearchProvisioning = false,
    enableMonitorResearchJewelry = false,
    enableMonitorResearchShowCondensed = false,
    showSurveyCountInCurrentZone = false,
    showFishingStatistics = false,
    fishingStats = {
      FishCaughtSession = 0,
      FishCaughtTotal = 0,
      FishGoldMadeSession = 0,
      FishGoldMadeTotal = 0,
    },
  },
  MonitorMaterial = {
    { Name = GetString(PXIP_RAW_ANCESTOR_SILK),  RefinedName = GetString(PXIP_RAW_ANCESTOR_SILK_REFINED_NAME),  ShortName = GetString(PXIP_RAW_ANCESTOR_SILK_SHORT_NAME),  Minimum = 200, Count = 0, InventoryCount = 0, RefinedInventoryCount = 0, RawLink = '|H0:item:71200:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h',  RefinedLink = '|H0:item:64504:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h' },
    { Name = GetString(PXIP_RUBEDITE_ORE),       RefinedName = GetString(PXIP_RUBEDITE_ORE_REFINED_NAME),       ShortName = GetString(PXIP_RUBEDITE_ORE_SHORT_NAME),       Minimum = 200, Count = 0, InventoryCount = 0, RefinedInventoryCount = 0, RawLink = '|H0:item:71198:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h',  RefinedLink = '|H0:item:64489:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h' },
    { Name = GetString(PXIP_ROUGH_RUBY_ASH),     RefinedName = GetString(PXIP_ROUGH_RUBY_ASH_REFINED_NAME),     ShortName = GetString(PXIP_ROUGH_RUBY_ASH_SHORT_NAME),     Minimum = 200, Count = 0, InventoryCount = 0, RefinedInventoryCount = 0, RawLink = '|H0:item:71199:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h', RefinedLink = '|H0:item:64502:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h' },
    { Name = GetString(PXIP_RUBEDO_HIDE_SCRAPS), RefinedName = GetString(PXIP_RUBEDO_HIDE_SCRAPS_REFINED_NAME), ShortName = GetString(PXIP_RUBEDO_HIDE_SCRAPS_SHORT_NAME), Minimum = 200, Count = 0, InventoryCount = 0, RefinedInventoryCount = 0, RawLink = '|H0:item:71239:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h',  RefinedLink = '|H0:item:64506:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h' },
    { Name = GetString(PXIP_PLATINUM),           RefinedName = GetString(PXIP_PLATINUM_OUNCE),                  ShortName = GetString(PXIP_PLATINUM_SHORT_NAME),           Minimum = 200, Count = 0, InventoryCount = 0, RefinedInventoryCount = 0, RawLink = '|H0:item:135145:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h', RefinedLink = '|H0:item:135146:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h' },
  },
}

PXInfoPanelAddon.WritStatus = {
  BlackSmithing = false,
  BlackSmithingColor = PXInfoPanelAddon.ColorRed,
  BlackSmithingPickedUp = false,
  Clothing = false,
  ClothingColor = PXInfoPanelAddon.ColorRed,
  ClothingPickedUp = false,
  Woodworking = false,
  WoodworkingColor = PXInfoPanelAddon.ColorRed,
  WoodworkingPickedUp = false,
  Jewelry = false,
  JewelryColor = PXInfoPanelAddon.ColorRed,
  JewelryPickedUp = false,
  Alchemy = false,
  AlchemyColor = PXInfoPanelAddon.ColorRed,
  AlchemyPickedUp = false,
  Enchanting = false,
  EnchantingColor = PXInfoPanelAddon.ColorRed,
  AlchemyPickedUp = false,
  Provisioning = false,
  ProvisioningColor = PXInfoPanelAddon.ColorRed,
  ProvisioningPickedUp = false,
}

PXInfoPanelAddon.ResearchInfoDetail = {
  AllKnown = true,
  SecondsRemaining = 0,
  TimeStringShort = '',
  TimeStringLong = '',
  LinesCurrentlyResearching = 0,
  LinesMaxResearchable = 0,
  TimeStamp = 0
}

PXIP = {}
PXIP.BI = {}
PXIP.CI = {}
PXIP.WI = {}
PXIP.JI = {}

PXInfoPanelAddon.savedVariables = PXInfoPanelAddon.DefaultSettings

---------------------------------------------------------------------------------------------------------
-- Initialize:
---------------------------------------------------------------------------------------------------------
function PXInfoPanelAddon:Initialize()
  d('PXIP -- ' .. self.ColorGreen .. 'P|rhaero' .. self.ColorGreen .. 'X I|rnfo ' .. self.ColorGreen .. 'P|ranel loaded.')
  ZO_CreateStringId("SI_BINDING_NAME_PX_INFO_PANEL_RESET", GetString(PXIP_BINDINGS_RESET))
  ZO_CreateStringId("SI_BINDING_NAME_PX_INFO_PANEL_TOGGLE", GetString(PXIP_BINDINGS_TOGGLE))

  PXInfoPanelAddon.PVPInfo.AlliancePointsToNextOverall1 = 0
  PXInfoPanelAddon.PVPInfo.AlliancePointsToNextOverall2 = 0
  PXInfoPanelAddon.PVPInfo.AlliancePointsToNextOverall3 = 0

  PXInfoPanelAddon.PVPInfo.AlliancePointsToNextAlliance1 = 0
  PXInfoPanelAddon.PVPInfo.AlliancePointsToNextAlliance2 = 0
  PXInfoPanelAddon.PVPInfo.AlliancePointsToNextAlliance3 = 0

  PXInfoPanelAddon.PVPInfo.AlliancePointsToPreviousOverall1 = 0
  PXInfoPanelAddon.PVPInfo.AlliancePointsToPreviousOverall2 = 0
  PXInfoPanelAddon.PVPInfo.AlliancePointsToPreviousOverall3 = 0

  PXInfoPanelAddon.PVPInfo.AlliancePointsToPreviousAlliance1 = 0
  PXInfoPanelAddon.PVPInfo.AlliancePointsToPreviousAlliance2 = 0
  PXInfoPanelAddon.PVPInfo.AlliancePointsToPreviousAlliance3 = 0

  PXInfoPanelAddon.CurrentZone = GetPlayerActiveZoneName()
  PXInfoPanelAddon.CurrentSubZone = GetPlayerActiveSubzoneName()

  ------------
  -- EVENTS --
  ------------

  ---------
  -- PVP --
  ---------
  EVENT_MANAGER:RegisterForEvent(PXInfoPanelAddon.Name, EVENT_KEEP_RESOURCE_UPDATE,
    function(eventCode, keepId)
      local keepName = GetKeepName(keepId)
      local keepType = GetKeepResourceType(keepId)
      if keepType == 0 then
        keepType = GetKeepType(keepId)
      end
      d('PXIP -- Keep = ' .. keepName .. ', KeepType = ' .. keepType)
    end
  )

  EVENT_MANAGER:RegisterForEvent(PXInfoPanelAddon.Name, EVENT_ALLIANCE_POINT_UPDATE,
    function(eventCode, alliancePoints, playSound, difference, reason)
      if (difference > 1) then
        PXInfoPanelAddon.PVPInfo.RankPoints = alliancePoints
        PXInfoPanelAddon.PVPInfo.Difference = difference
        PXInfoPanelAddon.PVPInfo.DifferenceReason = reason
        PXInfoPanelAddon:UpdateUI()
      end
      if (difference >= 500) then
        d('PXIP ===========> TICK <=========== ' .. difference .. ' alliance points.')
        PXInfoPanelAddon:Notify(GetString(PXIP_GAINED) .. difference .. ' AP.' .. GetString(PXIP_NOW_AT) .. PXInfoPanelAddon:MoneyString(alliancePoints) .. ' !!' , SOUNDS.ACHIEVEMENT_AWARDED)
      end
    end
  )

  EVENT_MANAGER:RegisterForEvent(PXInfoPanelAddon.Name, EVENT_ASSIGNED_CAMPAIGN_CHANGED,
    function(eventCode, newAssignedCampaignId)
      PXInfoPanelAddon.PVPInfo.CampaignId = newAssignedCampaignId
      PXInfoPanelAddon.PVPInfo.CampaignName = GetCampaignName(newAssignedCampaignId)
      PXInfoPanelAddon:UpdateUI()
    end
  )

  EVENT_MANAGER:RegisterForEvent(PXInfoPanelAddon.Name, EVENT_CAMPAIGN_LEADERBOARD_DATA_CHANGED,
    function(eventCode)
      local campaignId = GetCurrentCampaignId()
      local playerAllianceId = GetUnitAlliance("player")
      local playerIndex = GetScoreboardPlayerEntryIndex()
      local leaderBoardEntries = GetNumCampaignLeaderboardEntries(campaignId)

      local playerRank = 0
      for x = 1, 100 do
        local isPlayer, ranking, charName, alliancePoints, classId, allianceId, displayName = GetCampaignLeaderboardEntryInfo(campaignId, x)
        if (isPlayer) then
          playerRank = x
          break
        end
      end

      if (playerRank > 0) then
        if (playerRank == 1) then
          local isPlayer, ranking1, charName1, alliancePoints1, classId1, allianceId1, displayName1 = GetCampaignLeaderboardEntryInfo(campaignId, 1)
          local isPlayer, ranking2, charName2, alliancePoints2, classId2, allianceId2, displayName2 = GetCampaignLeaderboardEntryInfo(campaignId, 2)
          d('PXIP -- Overall #1 -- ' .. self:MoneyString(alliancePoints1 - alliancePoints2) .. ' points to no 2 ' .. charName2 .. '@' .. displayName2 .. ' (' .. GetAllianceName(allianceId) .. ')')
        else
          local isPlayer, ranking1, charName1, alliancePoints1, classId1, allianceId1, displayName1 = GetCampaignLeaderboardEntryInfo(campaignId, playerRank - 1)
          local isPlayer, ranking2, charName2, alliancePoints2, classId2, allianceId2, displayName2 = GetCampaignLeaderboardEntryInfo(campaignId, playerRank)
          local isPlayer, ranking3, charName3, alliancePoints3, classId3, allianceId3, displayName3 = GetCampaignLeaderboardEntryInfo(campaignId, playerRank + 1)
          
          PXInfoPanelAddon.PVPInfo.AlliancePointsToNextOverall2 = PXInfoPanelAddon.PVPInfo.AlliancePointsToNextOverall1
          PXInfoPanelAddon.PVPInfo.AlliancePointsToNextOverall1 = alliancePoints1 - alliancePoints2
          
          PXInfoPanelAddon.PVPInfo.AlliancePointsToPreviousOverall2 = PXInfoPanelAddon.PVPInfo.AlliancePointsToPreviousOverall1
          PXInfoPanelAddon.PVPInfo.AlliancePointsToPreviousOverall1 = alliancePoints2 - alliancePoints3
          
          local diffText1 = ''
          diff1 = PXInfoPanelAddon.PVPInfo.AlliancePointsToNextOverall2 - PXInfoPanelAddon.PVPInfo.AlliancePointsToNextOverall1
          if (diff1 > 0) then
            diffText1 = 'Gained ' .. self:MoneyString(diff1) .. '!!'
          else
            diffText1 = 'Lost ' .. self:MoneyString(diff1)
          end

          local diffText2 = ''
          diff2 = PXInfoPanelAddon.PVPInfo.AlliancePointsToPreviousOverall1 - PXInfoPanelAddon.PVPInfo.AlliancePointsToPreviousOverall2
          if (diff2 > 0) then
            diffText2 = 'Gained ' .. self:MoneyString(diff2) .. '!!'
          else
            diffText2 = 'Lost ' .. self:MoneyString(diff2)
          end

          d('PXIP -- Overall #' .. playerRank .. ' -- ' ..
            self:MoneyString(alliancePoints1 - alliancePoints2) .. ' points to no ' .. playerRank - 1 .. ', ' .. diffText1 .. ' -- ' ..
            self:MoneyString(alliancePoints2 - alliancePoints3) .. ', to previous ' .. playerRank + 1 .. ', ' .. diffText2)
        end
      end
      
      for x = 1, 100 do
        local isPlayer, ranking, charName, alliancePoints, classId, displayName = GetCampaignAllianceLeaderboardEntryInfo(campaignId, playerAllianceId, x)
        if (isPlayer) then
          playerRank = x
          break
        end
      end

      if (playerRank > 0) then
        if (playerRank == 1) then
          local isPlayer, ranking1, charName1, alliancePoints1, classId1, displayName1 = GetCampaignAllianceLeaderboardEntryInfo(campaignId, playerAllianceId, 1)
          local isPlayer, ranking2, charName2, alliancePoints2, classId2, displayName2 = GetCampaignAllianceLeaderboardEntryInfo(campaignId, playerAllianceId, 2)
          d('PXIP -- Alliance #1 -- ' .. self:MoneyString(alliancePoints1 - alliancePoints2) .. ' points to no 2 ' .. charName2 .. '@' .. displayName2)
        else
          local isPlayer, ranking1, charName1, alliancePoints1, classId1, displayName1 = GetCampaignAllianceLeaderboardEntryInfo(campaignId, playerAllianceId, playerRank - 1)
          local isPlayer, ranking2, charName2, alliancePoints2, classId2, displayName2 = GetCampaignAllianceLeaderboardEntryInfo(campaignId, playerAllianceId, playerRank)
          local isPlayer, ranking3, charName3, alliancePoints3, classId3, displayName3 = GetCampaignAllianceLeaderboardEntryInfo(campaignId, playerAllianceId, playerRank + 1)

          PXInfoPanelAddon.PVPInfo.AlliancePointsToNextAlliance2 = PXInfoPanelAddon.PVPInfo.AlliancePointsToNextAlliance1
          PXInfoPanelAddon.PVPInfo.AlliancePointsToNextAlliance1 = alliancePoints1 - alliancePoints2

          PXInfoPanelAddon.PVPInfo.AlliancePointsToPreviousAlliance2 = PXInfoPanelAddon.PVPInfo.AlliancePointsToPreviousAlliance1
          PXInfoPanelAddon.PVPInfo.AlliancePointsToPreviousAlliance1 = alliancePoints2 - alliancePoints3
          
          local diffText1 = ''
          diff1 = PXInfoPanelAddon.PVPInfo.AlliancePointsToNextAlliance2 - PXInfoPanelAddon.PVPInfo.AlliancePointsToNextAlliance1
          if (diff1 > 0) then
            diffText1 = 'Gained ' .. self:MoneyString(diff1) .. '!!'
          else
            diffText1 = 'Lost ' .. self:MoneyString(diff1)
          end

          local diffText2 = ''
          diff2 = PXInfoPanelAddon.PVPInfo.AlliancePointsToPreviousAlliance1 - PXInfoPanelAddon.PVPInfo.AlliancePointsToPreviousAlliance2
          if (diff2 > 0) then
            diffText2 = 'Gained ' .. self:MoneyString(diff2) .. '!!'
          else
            diffText2 = 'Lost ' .. self:MoneyString(diff2)
          end

          d('PXIP -- Alliance #' .. playerRank .. ' -- ' .. 
            self:MoneyString(alliancePoints1 - alliancePoints2) .. ' points to no ' .. playerRank - 1 .. ', ' .. diffText1 .. ' -- ' ..
            self:MoneyString(alliancePoints2 - alliancePoints3) .. ', to previous ' .. playerRank + 1 .. ', ' .. diffText2)
        end
      end

      if (IsPlayerInAvAWorld()) then
        if (DoesCampaignHaveEmperor(campaignId)) then
          local emperorAlliance, emperorCharacterName, emperorDisplayName = GetCampaignEmperorInfo(campaignId)
          d('PXIP -- Emperor is ' .. emperorCharacterName .. ' / ' .. emperorDisplayName)
        end
      end
    end
  )

  EVENT_MANAGER:RegisterForEvent(PXInfoPanelAddon.Name, EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED,
    function(eventCode, campaignId, isGroup, position)
      d('PXIP -- EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED ' .. campaignId .. ', ' .. position)
      PXInfoPanelAddon.PVPInfo.QueuePosition = position
      PXInfoPanelAddon:UpdateUI()
    end
  )

  ---------
  -- PVE --
  ---------
  EVENT_MANAGER:RegisterForEvent(PXInfoPanelAddon.Name, EVENT_OPEN_STORE,
    function(eventCode)
      if (PXInfoPanelAddon.savedVariables.enableVendorAutomationDebugging) then
        d('PXVM -- EVENT_OPEN_STORE')
      end
      if (PXInfoPanelAddon.savedVariables.enableVendorAutomation) then
        if (PXInfoPanelAddon.savedVariables.enableVendorAutomationDebugging) then
          d('PXVM -- Vendor automation enabled.')
        end
        local goldSpent = 0
       
        local storeItems = GetNumStoreItems()
        if (PXInfoPanelAddon.savedVariables.enableVendorAutomationDebugging) then
          d('PXVM -- Store Items = ' .. storeItems)
        end

        local notifiedAboutSpendingExceeded = false
        for x = 1, storeItems do
          local itemFilterType = GetStoreEntryTypeInfo(x)
          local icon, name, stack, price, sellPrice, meetsRequirementsToBuy, meetsRequirementsToUse, quality, questNameColor, currencyType1, currencyQuantity1, currencyType2, currencyQuantity2, storeEntryType = GetStoreEntryInfo(x)
          local storeItemLink =  GetStoreItemLink(x, LINK_STYLE_DEFAULT)

          -- ITEMFILTERTYPE_CRAFTING = 4
          -- CURT_MONEY = 1
          if (itemFilterType == ITEMFILTERTYPE_CRAFTING and (currencyType1 == CURT_MONEY or currencyType1 == CURT_NONE)) then
            local stackCountBackpack, stackCountBank, stackCountCraftBag = GetItemLinkStacks(storeItemLink)
            local totalStackSize = stackCountBackpack + stackCountBank + stackCountCraftBag

            if (PXInfoPanelAddon.savedVariables.enableVendorAutomationDebugging) then
              d('PXVM -- Looking at ' .. name .. ', my stack is ' .. totalStackSize .. ' and my goal is ' .. PXInfoPanelAddon.savedVariables.vendorAutomationInventoryCount)
            end

            if (totalStackSize < PXInfoPanelAddon.savedVariables.vendorAutomationInventoryCount) then
              local toBuy = PXInfoPanelAddon.savedVariables.vendorAutomationInventoryCount - totalStackSize
              local maxBuyable = GetStoreEntryMaxBuyable(x)

              if (goldSpent >  PXInfoPanelAddon.savedVariables.vendorAutomationMaxGold and notifiedAboutSpendingExceeded == false) then
                if (PXInfoPanelAddon.savedVariables.enableVendorAutomationDebugging) then
                  d('PXVM -- Spending limit hit. Not buying ' .. toBuy .. ' of ' .. name .. ' @' .. self:MoneyString(price) .. ' = ' .. self:MoneyString(toBuy * price))
                  notifiedAboutSpendingExceeded = true
                end
              else
                if (price <= PXInfoPanelAddon.savedVariables.vendorAutomationMaxUnitPrice) then
                  if (PXInfoPanelAddon.savedVariables.enableVendorAutomationDebugging) then
                    d('PXVM -- Buying ' .. toBuy .. ' of ' .. name .. ' @' .. self:MoneyString(price) .. ' = ' .. self:MoneyString(toBuy * price))
                  end
                  BuyStoreItem(x, toBuy)
                  goldSpent = goldSpent + (toBuy * price)
                else
                  if (PXInfoPanelAddon.savedVariables.enableVendorAutomationDebugging) then
                    d('PXVM -- Price per unit ' .. price .. ' exceeds ' .. PXInfoPanelAddon.savedVariables.vendorAutomationMaxUnitPrice .. '. Not buying ' .. toBuy .. ' of ' .. name .. ' @' .. self:MoneyString(price) .. ' = ' .. self:MoneyString(toBuy * price))
                  end
                end
              end
            else
              if (PXInfoPanelAddon.savedVariables.enableVendorAutomationDebugging) then
                d('PXVM -- Already have enough ' .. name .. ' (' .. totalStackSize .. ') -- So not buying...')
                notifiedAboutSpendingExceeded = true
              end
            end
          end
        end

        if (goldSpent > 0) then
          if (PXInfoPanelAddon.savedVariables.enableVendorAutomationDebugging) then
            d('PXIP -- Spent a total of ' .. self:MoneyString(goldSpent))
          end
        end
      end
    end
  )

  EVENT_MANAGER:RegisterForEvent(PXInfoPanelAddon.Name, EVENT_OPEN_GUILD_BANK,
    function(eventCode, bankBag)
      self.GoldTransferToGuildComplete = true
      self.GuildBankTransferDone = false
    end
  )

  EVENT_MANAGER:RegisterForEvent(PXInfoPanelAddon.Name, EVENT_CLOSE_GUILD_BANK,
    function(eventCode, bankBag)
      self.GuildBankTransferDone = true
    end
  )

  EVENT_MANAGER:RegisterForEvent(PXInfoPanelAddon.Name, EVENT_ACHIEVEMENT_UPDATED,
    function(eventCode, id)
      if (self.savedVariables.showAchievementProgressInChat == false) then
        return
      end
      local sinceLast = GetTimeStamp() - self.PVPLastAchievementUpdate
      if (sinceLast < 10 and self.PVPLastAchievementId == id) then
        return
      end

      local name, description, points, icon, completed, date, time = GetAchievementInfo(id)
      local numCriteria = GetAchievementNumCriteria(id)
      local link = GetAchievementLink(id)

      self.PVPLastAchievementUpdate = GetTimeStamp()
      self.PVPLastAchievementId = id
      if (numCriteria == 1) then
        local description, numCompleted, numRequired = GetAchievementCriterion(id, 1)
        local percentComplete = (numCompleted * 100) / numRequired  
        d('PXIP - Achievement Update: [' .. link .. '] (' .. self:MoneyString(numCompleted) .. '/' .. self:MoneyString(numRequired) .. ') ' .. self:Round(percentComplete) .. '% -- ' .. description)
        PXInfoPanelAddon:UpdateUI()
      else
        if (completed == true) then
          d('PXIP - Achievement Update: You completed [' .. link .. '] (' .. description .. ') !!')
          PXInfoPanelAddon:UpdateUI()
        else
          d('PXIP - Achievement Update: You made progress on [' .. link .. '] ' .. description)
          for criteriaIndex = 1, numCriteria do
            local description, numCompleted, numRequired = GetAchievementCriterion(id, criteriaIndex)
            local percentComplete = (numCompleted * 100) / numRequired  
            if (numCompleted < numRequired) then
              d('PXIP - Achievement Update: [' .. link .. '] (' .. self:MoneyString(numCompleted) .. '/' .. self:MoneyString(numRequired) .. ') ' .. self:Round(percentComplete) .. '% -- ' .. description)
              PXInfoPanelAddon:UpdateUI()
            end
          end
        end
      end
    end
  )

  EVENT_MANAGER:RegisterForEvent(PXInfoPanelAddon.Name, EVENT_ACHIEVEMENTS_UPDATED,
    function(eventCode)
      PXInfoPanelAddon.EarnedAchievementPoints = GetEarnedAchievementPoints()
      PXInfoPanelAddon.TotAchievementPoints = GetTotalAchievementPoints()
      PXInfoPanelAddon:UpdateUI()
    end
  )

  EVENT_MANAGER:RegisterForEvent(PXInfoPanelAddon.Name, EVENT_CRAFT_COMPLETED,
    function(eventCode, craftSkill)
      PXInfoPanelAddon:UpdateWritStatus()
    end
  )

  EVENT_MANAGER:RegisterForEvent(PXInfoPanelAddon.Name, EVENT_EXPERIENCE_GAIN,
    function(eventCode, reason, level, previousExperience, currentExperience, championPoints)
      PXInfoPanelAddon.EarnedAchievementPoints = GetEarnedAchievementPoints()
      PXInfoPanelAddon.TotAchievementPoints = GetTotalAchievementPoints()
      PXInfoPanelAddon.IsEnlightenedAvailableForCharacter = IsEnlightenedAvailableForCharacter()
      PXInfoPanelAddon.EnlightenedPool = GetEnlightenedPool()

      PXInfoPanelAddon:UpdateUI()
    end
  )

  EVENT_MANAGER:RegisterForEvent(PXInfoPanelAddon.Name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
    function(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
      local itemLink = GetItemLink(bagId, slotId, LINK_STYLE_DEFAULT)
      if (itemLink == nil or stackCountChange < 1) then
        return
      end

      local mPrice = PXInfoPanelAddon:GetItemPrice(itemLink)
      if (mPrice <= 0) then
        return
      end
      local tPrice = PXInfoPanelAddon:Round(stackCountChange * mPrice)
      PXInfoPanelAddon.TotalGoldMade = PXInfoPanelAddon.TotalGoldMade + tPrice
      PXInfoPanelAddon:UpdateUI()
    end
  )

  EVENT_MANAGER:RegisterForEvent(PXInfoPanelAddon.Name, EVENT_SMITHING_TRAIT_RESEARCH_CANCELED,
    function(eventCode, craftingSkillType, researchLineIndex, traitIndex)
      PXInfoPanelAddon:CalculateResearchAll()
    end
  )

  EVENT_MANAGER:RegisterForEvent(PXInfoPanelAddon.Name, EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED,
    function(eventCode, craftingSkillType, researchLineIndex, traitIndex)
      PXInfoPanelAddon:CalculateResearchAll()
    end
  )

  EVENT_MANAGER:RegisterForEvent(PXInfoPanelAddon.Name, EVENT_SMITHING_TRAIT_RESEARCH_STARTED,
    function(eventCode, craftingSkillType, researchLineIndex, traitIndex)
      PXInfoPanelAddon:CalculateResearchAll()
    end
  )

  EVENT_MANAGER:RegisterForEvent(PXInfoPanelAddon.Name, EVENT_SMITHING_TRAIT_RESEARCH_TIMES_UPDATED,
    function(eventCode)
      PXInfoPanelAddon:CalculateResearchAll()
    end
  )

  EVENT_MANAGER:RegisterForEvent(PXInfoPanelAddon.Name, EVENT_LOOT_RECEIVED,                   PXInfoPanelAddon.OnLootReceived)
  EVENT_MANAGER:RegisterForEvent(PXInfoPanelAddon.Name, EVENT_LORE_BOOK_LEARNED,               PXInfoPanelAddon.OnLoreBookLearned)
  EVENT_MANAGER:RegisterForEvent(PXInfoPanelAddon.Name, EVENT_MONEY_UPDATE,                    PXInfoPanelAddon.OnMoneyUpdate)
  EVENT_MANAGER:RegisterForEvent(PXInfoPanelAddon.Name, EVENT_RANK_POINT_UPDATE,               PXInfoPanelAddon.OnRankPointUpdated)
  EVENT_MANAGER:RegisterForEvent(PXInfoPanelAddon.Name, EVENT_WRIT_VOUCHER_UPDATE,             PXInfoPanelAddon.OnWritVoucherUpdate)
  EVENT_MANAGER:RegisterForEvent(PXInfoPanelAddon.Name, EVENT_ZONE_CHANGED,                    PXInfoPanelAddon.OnZoneChange)

  EVENT_MANAGER:RegisterForEvent(PXInfoPanelAddon.Name, EVENT_CLOSE_BANK,                      function() PXInfoPanelAddon:UpdateWritStatus() end)
  EVENT_MANAGER:RegisterForEvent(PXInfoPanelAddon.Name, EVENT_END_CRAFTING_STATION_INTERACT,   function() PXInfoPanelAddon:UpdateWritStatus() end)
  EVENT_MANAGER:RegisterForEvent(PXInfoPanelAddon.Name, EVENT_INVENTORY_FULL_UPDATE,           function() PXInfoPanelAddon:UpdateWritStatus() end)
  EVENT_MANAGER:RegisterForEvent(PXInfoPanelAddon.Name, EVENT_ITEM_SLOT_CHANGED,               function() PXInfoPanelAddon:UpdateWritStatus() end)

  EVENT_MANAGER:RegisterForEvent(PXInfoPanelAddon.Name, EVENT_QUEST_ADDED,                     function() PXInfoPanelAddon:UpdateWritStatus() end)
  EVENT_MANAGER:RegisterForEvent(PXInfoPanelAddon.Name, EVENT_QUEST_COMPLETE,                  function() PXInfoPanelAddon:UpdateWritStatus() end)
  EVENT_MANAGER:RegisterForEvent(PXInfoPanelAddon.Name, EVENT_QUEST_LOG_IS_FULL,               function() PXInfoPanelAddon:UpdateWritStatus() end)
  EVENT_MANAGER:RegisterForEvent(PXInfoPanelAddon.Name, EVENT_SKILL_XP_UPDATE,                 function() PXInfoPanelAddon:UpdateWritStatus() end)
  EVENT_MANAGER:RegisterForEvent(PXInfoPanelAddon.Name, EVENT_SMITHING_TRAIT_RESEARCH_STARTED, function() PXInfoPanelAddon:UpdateWritStatus() end)

  PXInfoPanelAddon.savedVariables = ZO_SavedVars:New("PXInfoPanelSavedVariables", 1, nil, PXInfoPanelAddon.DefaultSettings)
  if (PXInfoPanelAddon.savedVariables == nil or PXInfoPanelAddon.savedVariables.left == nil) then  
    PXInfoPanelAddon.savedVariables = PXInfoPanelAddon.DefaultSettings
  end

  PXInfoPanelAddon.accountVariables = ZO_SavedVars:NewAccountWide("PXInfoPanelAccountVariables", 1, nil, {})
  PXInfoPanelAddon:CheckDefaultSettingsAreApplied()

  -- Fade out when using Inventory etc.
  if (PXInfoPanelAddon.savedVariables.hideInfoPanelWhenViewInventory == true) then
    local fragment = ZO_SimpleSceneFragment:New(PXInfoPanelAddonIndicator)
    local scene = SCENE_MANAGER:GetScene("hud")
    scene:AddFragment(fragment)
  end

  PXInfoPanelAddon:GetPVPInfo()

  PXInfoPanelAddon.StartTimeMS = GetTimeStamp()
  PXInfoPanelAddon.ZoneStartTime = GetTimeStamp()
  PXInfoPanelAddon.StartGold = GetCurrentMoney()
  PXInfoPanelAddon.LastGold = PXInfoPanelAddon.StartGold
  PXInfoPanelAddon.LastWritVouchers = GetCarriedCurrencyAmount(CURT_WRIT_VOUCHERS)
  PXInfoPanelAddon.StartXP = GetUnitXP("player")
  PXInfoPanelAddon.StartAP = PXInfoPanelAddon.PVPInfo.RankPoints
  PXInfoPanelAddon.LastLoot = ''
  PXInfoPanelAddon.LastLoot2 = ''
  PXInfoPanelAddon.LastLoot3 = ''
  PXInfoPanelAddon.LastLoot4 = ''
  PXInfoPanelAddon.LastLoot5 = ''
  PXInfoPanelAddon.HasBeenNotifiedAboutNoEnlightenment = false
  PXInfoPanelAddon.savedVariables.allWritsDoneNotified = false

  PXInfoPanelAddon.BestLoot = ''
  PXInfoPanelAddon.BestLootWorth = 0
  PXInfoPanelAddon.BestLoot2 = ''
  PXInfoPanelAddon.BestLootWorth2 = 0
  PXInfoPanelAddon.BestLoot3 = ''
  PXInfoPanelAddon.BestLootWorth3 = 0
  PXInfoPanelAddon.BestLoot4 = ''
  PXInfoPanelAddon.BestLootWorth4 = 0
  PXInfoPanelAddon.BestLoot5 = ''
  PXInfoPanelAddon.BestLootWorth5 = 0

  PXInfoPanelAddon.EarnedAchievementPoints = GetEarnedAchievementPoints()
  PXInfoPanelAddon.TotAchievementPoints = GetTotalAchievementPoints()
  PXInfoPanelAddon.IsEnlightenedAvailableForCharacter = IsEnlightenedAvailableForCharacter()
  PXInfoPanelAddon.EnlightenedPool = GetEnlightenedPool()

  PXInfoPanelAddon.savedVariables.fishingStats.FishCaughtSession = 0
  PXInfoPanelAddon.savedVariables.fishingStats.FishGoldMadeSession = 0

  d('PXIP -- Last logged in ' .. PXInfoPanelAddon:FormatSeconds(GetTimeStamp() - PXInfoPanelAddon.savedVariables.lastLoggedIn) .. ' ago.')
  PXInfoPanelAddon.savedVariables.lastLoggedIn = GetTimeStamp()

  PXInfoPanelAddon:ResetCustomMonitorCounts()
  PXInfoPanelAddon:CreateSettingsWindow()

  -- Initialize the inventory counts on Ancestor Silk etc.
  PXInfoPanelAddon:UpdateMonitoredInventory()

  -- Initialize the research time, consecutive updates will be based on this initial call or if research is started.
  PXInfoPanelAddon:CalculateResearchAll()

  PXInfoPanelAddon:RestorePosition()
  PXInfoPanelAddon:UpdateWritStatus()
end

---------------------------------------------------------------------------------------------------------
-- KEYBINDING EVENTS:
---------------------------------------------------------------------------------------------------------
function PXInfoPanel_ProcessReset()
  PXInfoPanelAddon.StartTimeMS = GetTimeStamp()
  PXInfoPanelAddon.StartGold = GetCurrentMoney()
  PXInfoPanelAddon.LastGold = PXInfoPanelAddon.StartGold
  PXInfoPanelAddon.LastWritVouchers = GetCarriedCurrencyAmount(CURT_WRIT_VOUCHERS)

  PXInfoPanelAddon.StartXP = GetUnitXP("player")
  PXInfoPanelAddon:GetPVPInfo()
  PXInfoPanelAddon.StartAP = PXInfoPanelAddon.PVPInfo.RankPoints

  PXInfoPanelAddon.TotalGoldMade = 0
  PXInfoPanelAddon.BestLoot = ''
  PXInfoPanelAddon.BestLootWorth = 0
  PXInfoPanelAddon.BestLoot2 = ''
  PXInfoPanelAddon.BestLootWorth2 = 0
  PXInfoPanelAddon.BestLoot3 = ''
  PXInfoPanelAddon.BestLootWorth3 = 0
  PXInfoPanelAddon.BestLoot4 = ''
  PXInfoPanelAddon.BestLootWorth4 = 0
  PXInfoPanelAddon.BestLoot5 = ''
  PXInfoPanelAddon.BestLootWorth5 = 0

  PXInfoPanelAddon.LastLoreBookLearned = ''
  PXInfoPanelAddon.WritStatusText = ''

  PXInfoPanelAddon.savedVariables.fishingStats.FishCaughtSession = 0
  PXInfoPanelAddon.savedVariables.fishingStats.FishGoldMadeSession = 0

  PXInfoPanelAddon:ResetCustomMonitorCounts()
  PXInfoPanelAddon:UpdateWritStatus()
end

function PXInfoPanel_ProcessToggle()
  if PXInfoPanelAddon.Showing == true then
    PXInfoPanelAddon.Showing = false
    PXInfoPanelAddon:UpdateUI()
  else
    PXInfoPanelAddon.Showing = true
    PXInfoPanelAddon:UpdateUI()
  end
end

---------------------------------------------------------------------------------------------------------
-- E V E N T S
---------------------------------------------------------------------------------------------------------
function PXInfoPanelAddon.OnAddOnLoaded(event, addonName)
  if addonName == PXInfoPanelAddon.Name then
    EVENT_MANAGER:UnregisterForEvent(addonName, event)
    PXInfoPanelAddon:Initialize()
  end
end

function PXInfoPanelAddon.OnRankPointUpdated(eventCode, unitTag, rankPoints, difference)
  PXInfoPanelAddon:GetPVPInfo()
  PXInfoPanelAddon:UpdateUI()
end

function PXInfoPanelAddon.OnIndicatorMoveStop()
  PXInfoPanelAddon.savedVariables.left = PXInfoPanelAddonIndicator:GetLeft()
  PXInfoPanelAddon.savedVariables.top = PXInfoPanelAddonIndicator:GetTop()
end

function PXInfoPanelAddon:OnLootReceived(lootedBy, itemLink, quantity, itemSound, lootType, self)
  PXInfoPanelAddon:UpdateWritStatus()
  if itemLink == nil then
    return
  end

  PXInfoPanelAddon:UpdateBagCounts(itemLink)

  if (PXInfoPanelAddon.savedVariables.showSurveyCountInCurrentZone) then
    PXInfoPanelAddon:UpdateSurveyCount()
  end

  local mPrice = PXInfoPanelAddon:GetItemPrice(itemLink)
  local tPrice = PXInfoPanelAddon:Round(quantity * mPrice)
  local mtPrice = PXInfoPanelAddon:MoneyString(tPrice)
  local stackCountBackpack, stackCountBank, stackCountCraftBag = GetItemLinkStacks(itemLink)
  local totalStackSize = stackCountBackpack + stackCountBank + stackCountCraftBag
  local icon, sellPrice, meetsUsageRequirement, equipType, itemStyle = GetItemLinkInfo(itemLink)
  local itemType, specializedItemType = GetItemLinkItemType(itemLink)

  local knownText = ''
  if (itemType == ITEMTYPE_RECIPE) then
    local isKnown = IsItemLinkRecipeKnown(itemLink)
    if (isKnown == false) then
      knownText = ' (Unknown!)'
    end
  end

  if (itemType == ITEMTYPE_FISH) then
    PXInfoPanelAddon.savedVariables.fishingStats.FishCaughtSession = PXInfoPanelAddon.savedVariables.fishingStats.FishCaughtSession + 1
    PXInfoPanelAddon.savedVariables.fishingStats.FishCaughtTotal = PXInfoPanelAddon.savedVariables.fishingStats.FishCaughtTotal + 1
    PXInfoPanelAddon.savedVariables.fishingStats.FishGoldMadeSession = PXInfoPanelAddon.savedVariables.fishingStats.FishGoldMadeSession + mPrice
    PXInfoPanelAddon.savedVariables.fishingStats.FishGoldMadeTotal = PXInfoPanelAddon.savedVariables.fishingStats.FishGoldMadeTotal + mPrice
  end

  -- equipType:
  -- EQUIP_SLOT_WAIST, EQUIP_TYPE_CHEST, EQUIP_TYPE_FEET, EQUIP_TYPE_HAND, EQUIP_TYPE_HEAD
  -- EQUIP_TYPE_LEGS, EQUIP_TYPE_SHOULDERS, 
  -- EQUIP_TYPE_MAIN_HAND, EQUIP_TYPE_NECK, EQUIP_TYPE_OFF_HAND, EQUIP_TYPE_ONE_HAND,
  -- EQUIP_TYPE_RING, EQUIP_TYPE_TWO_HAND, EQUIP_SLOT_WRIST
  local equipTypeLarge = false
  if (equipType == EQUIP_TYPE_HEAD or equipType == EQUIP_TYPE_CHEST or equipType == EQUIP_TYPE_LEGS) then
    equipTypeLarge = true
  end

  local itemLinkQuality = GetItemLinkQuality(itemLink)
  local armorType = GetItemLinkArmorType(itemLink)
    -- ARMORTYPE_LIGHT
    -- ARMORTYPE_MEDIUM
    -- ARMORTYPE_HEAVY
  local weaponType = GetItemLinkWeaponType(itemLink)
    -- WEAPONTYPE_AXE
    -- WEAPONTYPE_BOW
    -- WEAPONTYPE_DAGGER
    -- WEAPONTYPE_FIRE_STAFF
    -- WEAPONTYPE_FROST_STAFF
    -- WEAPONTYPE_HAMMER
    -- WEAPONTYPE_HEALING_STAFF
    -- WEAPONTYPE_LIGHTNING_STAFF
    -- WEAPONTYPE_NONE
    -- WEAPONTYPE_RUNE
    -- WEAPONTYPE_SHIELD
    -- WEAPONTYPE_SWORD
    -- WEAPONTYPE_TWO_HANDED_AXE
    -- WEAPONTYPE_TWO_HANDED_HAMMER
    -- WEAPONTYPE_TWO_HANDED_SWORD
  local traitType, traitDescription, traitSubtype, traitSubtypeName, traitSubtypeDescription = GetItemLinkTraitInfo(itemLink)
  local traitName = PXInfoPanelAddon.ColorBlue .. GetString("SI_ITEMTRAITTYPE", traitType) .. '|r'
    -- ITEM_TRAIT_TYPE_ARMOR_DIVINES
    -- ITEM_TRAIT_TYPE_ARMOR_INFUSED
    -- ITEM_TRAIT_TYPE_ARMOR_STURDY
    -- ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE
    -- ITEM_TRAIT_TYPE_WEAPON_SHARPENED
  local requiredChampionPoints = GetItemLinkRequiredChampionPoints(itemLink)
  local hasSet, setName, numBonuses, numEquipped, maxEquipped = GetItemLinkSetInfo(itemLink)

  local itemIconText = zo_iconTextFormat(icon, 32, 32, " ")

  local playerName = zo_strformat(GetUnitName("player"))
  local looterName = zo_strformat("<<1>>", lootedBy)

  local text = ''
  local notifyText = ''
  if (playerName == looterName) then
    if (totalStackSize > 1) then
      if (PXInfoPanelAddon.savedVariables.showLastLootTrait == true and traitType > 0) then
        text = quantity .. ' x '
        text = text .. itemIconText
        text = text .. itemLink .. ' ['
        text = text .. traitName .. '] ('
        text = text .. totalStackSize .. ') '
        text = text .. PXInfoPanelAddon.GoldIconText
        text = text .. PXInfoPanelAddon:MoneyString(tPrice)
        text = text .. knownText
      else
        text = zo_strformat("<<1>> x <<2>><<3>> (<<4>>) <<5>><<6>><<7>>", quantity, itemIconText, itemLink, totalStackSize, PXInfoPanelAddon.GoldIconText, PXInfoPanelAddon:MoneyString(tPrice), knownText)
      end
    else
      if (PXInfoPanelAddon.savedVariables.showLastLootTrait == true and traitType > 0) then
        text = zo_strformat("<<1>> x <<2>><<3>> [<<4>>] <<5>><<6>><<7>>", quantity, itemIconText, itemLink, traitName, PXInfoPanelAddon.GoldIconText, PXInfoPanelAddon:MoneyString(tPrice), knownText)
     else
        text = zo_strformat("<<1>> x <<2>><<3>> <<4>><<5>><<6>>", quantity, itemIconText, itemLink, PXInfoPanelAddon.GoldIconText, PXInfoPanelAddon:MoneyString(tPrice), knownText)
      end
    end
  elseif (PXInfoPanelAddon.savedVariables.showGroupLoot == true) then
    if (PXInfoPanelAddon.savedVariables.showLastLootTrait == true and traitType > 0) then
      text = zo_strformat("<<1>> x <<2>><<3>> [<<4>>] (<<5>>) <<6>><<7>>", quantity, itemIconText, itemLink, traitName, lootedBy, PXInfoPanelAddon.GoldIconText, PXInfoPanelAddon:MoneyString(tPrice))
      d('PXIP - 5 - ' .. text)
    else
      text = zo_strformat("<<1>> x <<2>><<3>> (<<4>>) <<5>><<6>>", quantity, itemIconText, itemLink, lootedBy, PXInfoPanelAddon.GoldIconText, PXInfoPanelAddon:MoneyString(tPrice))
      d('PXIP - 6 - ' .. text)
    end
  end

  -- Best loot:
  local notified = 0
  if (PXInfoPanelAddon.savedVariables.showBestLoot and tPrice > PXInfoPanelAddon.BestLootWorth) then
    PXInfoPanelAddon.BestLootWorth5 = PXInfoPanelAddon.BestLootWorth4
    PXInfoPanelAddon.BestLoot5 = PXInfoPanelAddon.BestLoot4

    PXInfoPanelAddon.BestLootWorth4 = PXInfoPanelAddon.BestLootWorth3
    PXInfoPanelAddon.BestLoot4 = PXInfoPanelAddon.BestLoot3

    PXInfoPanelAddon.BestLootWorth3 = PXInfoPanelAddon.BestLootWorth2
    PXInfoPanelAddon.BestLoot3 = PXInfoPanelAddon.BestLoot2

    PXInfoPanelAddon.BestLootWorth2 = PXInfoPanelAddon.BestLootWorth
    PXInfoPanelAddon.BestLoot2 = PXInfoPanelAddon.BestLoot

    PXInfoPanelAddon.BestLootWorth = tPrice
    PXInfoPanelAddon.BestLoot = text

    if (PXInfoPanelAddon.savedVariables.showBestLootNotification) then
      local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.ACHIEVEMENT_AWARDED)
      params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_ACHIEVEMENT_AWARDED)
      params:SetText(GetString(PXIP_BEST_LOOT_SO_FAR) .. text)
      CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
      notified = 1
    end
  else
    if (tPrice > PXInfoPanelAddon.BestLootWorth2) then
      PXInfoPanelAddon.BestLootWorth5 = PXInfoPanelAddon.BestLootWorth4
      PXInfoPanelAddon.BestLoot5 = PXInfoPanelAddon.BestLoot4

      PXInfoPanelAddon.BestLootWorth4 = PXInfoPanelAddon.BestLootWorth3
      PXInfoPanelAddon.BestLoot4 = PXInfoPanelAddon.BestLoot3

      PXInfoPanelAddon.BestLootWorth3 = PXInfoPanelAddon.BestLootWorth2
      PXInfoPanelAddon.BestLoot3 = PXInfoPanelAddon.BestLoot2

      PXInfoPanelAddon.BestLootWorth2 = tPrice
      PXInfoPanelAddon.BestLoot2 = text
    else
      if (tPrice > PXInfoPanelAddon.BestLootWorth3) then
        PXInfoPanelAddon.BestLootWorth5 = PXInfoPanelAddon.BestLootWorth4
        PXInfoPanelAddon.BestLoot5 = PXInfoPanelAddon.BestLoot4

        PXInfoPanelAddon.BestLootWorth4 = PXInfoPanelAddon.BestLootWorth3
        PXInfoPanelAddon.BestLoot4 = PXInfoPanelAddon.BestLoot3

        PXInfoPanelAddon.BestLootWorth3 = tPrice
        PXInfoPanelAddon.BestLoot3 = text
      else
        if (tPrice > PXInfoPanelAddon.BestLootWorth4) then
          PXInfoPanelAddon.BestLootWorth5 = PXInfoPanelAddon.BestLootWorth4
          PXInfoPanelAddon.BestLoot5 = PXInfoPanelAddon.BestLoot4

          PXInfoPanelAddon.BestLootWorth4 = tPrice
          PXInfoPanelAddon.BestLoot4 = text
        else
          if (tPrice > PXInfoPanelAddon.BestLootWorth5) then
            PXInfoPanelAddon.BestLootWorth5 = tPrice
            PXInfoPanelAddon.BestLoot5 = text
          end
        end
      end
    end
  end

  -- Loot notify:
  if (notified == 0) then
    if (PXInfoPanelAddon.savedVariables.notifyOnLootAbove >= 0 and tPrice >= PXInfoPanelAddon.savedVariables.notifyOnLootAbove) then
      local params = nil
      if (PXInfoPanelAddon.savedVariables.playSoundOnNotifyOnLootAbove == false) then
        params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.NONE)
      else
        params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.ACHIEVEMENT_AWARDED)
      end
      params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_ACHIEVEMENT_AWARDED)
      params:SetText(text)
      CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
    end
  end

  PXInfoPanelAddon:ResetCustomMonitorCounts()
  PXInfoPanelAddon.LastLoot5 = PXInfoPanelAddon.LastLoot4
  PXInfoPanelAddon.LastLoot4 = PXInfoPanelAddon.LastLoot3
  PXInfoPanelAddon.LastLoot3 = PXInfoPanelAddon.LastLoot2
  PXInfoPanelAddon.LastLoot2 = PXInfoPanelAddon.LastLoot
  PXInfoPanelAddon.LastLoot = text;
  PXInfoPanelAddon:UpdateUI()
end

function PXInfoPanelAddon:OnLoreBookLearned(categoryIndex, collectionIndex, bookIndex, guildIndex, isMaxRank)
  local categoryName, numCollections, categoryId = GetLoreCategoryInfo(categoryIndex)
  local collectionName, collectionDescription, numKnownBooks, totalBooks, hidden, gamepadIcon, collectionId = GetLoreCollectionInfo(categoryIndex, collectionIndex)
  local loreBookTitle, icon, known, bookId = GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex)

  if (collectionName ~= nil and collectionName ~= '') then
    PXInfoPanelAddon.LastLoreBookLearned = GetString(PXIP_LEARNED) .. loreBookTitle .. GetString(PXIP_IN) .. collectionName .. GetString(PXIP_KNOWN) .. numKnownBooks .. ' / ' .. totalBooks .. ')'
  else
    PXInfoPanelAddon.LastLoreBookLearned = GetString(PXIP_LEARNED) .. loreBookTitle
  end

  if (PXInfoPanelAddon.savedVariables.notifyOnLoreBooks) then
    local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.ACHIEVEMENT_AWARDED)
    params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_ACHIEVEMENT_AWARDED)
    params:SetText(PXInfoPanelAddon.LastLoreBookLearned)
    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
  end

  PXInfoPanelAddon:UpdateUI()
end

function PXInfoPanelAddon:OnMoneyUpdate(eventCode, newMoney, oldMoney, reason)
  PXInfoPanelAddon.TotalGoldMade = PXInfoPanelAddon.TotalGoldMade + (GetCurrentMoney() - PXInfoPanelAddon.LastGold)
  PXInfoPanelAddon.LastGold = GetCurrentMoney()
  PXInfoPanelAddon.LastWritVouchers = GetCarriedCurrencyAmount(CURT_WRIT_VOUCHERS)
  PXInfoPanelAddon:UpdateUI()
end

function PXInfoPanelAddon:OnWritVoucherUpdate(eventCode, newWritVouchers, oldWritVouchers, reason)
  PXInfoPanelAddon.LastWritVouchers = GetCarriedCurrencyAmount(CURT_WRIT_VOUCHERS)
  PXInfoPanelAddon:UpdateUI()
end

function PXInfoPanelAddon:OnZoneChange(eventCode, zoneName, subZoneName, newSubzone, zoneId, subZoneId)
  if (PXInfoPanelAddon.savedVariables.showSurveyCountInCurrentZone == false) then
    return
  end

  local oldZone = PXInfoPanelAddon.CurrentZone
  PXInfoPanelAddon.CurrentZone = GetPlayerActiveZoneName()
  PXInfoPanelAddon.CurrentSubZone = GetPlayerActiveSubzoneName()
  if (oldZone ~= PXInfoPanelAddon.CurrentZone) then
    PXInfoPanelAddon.ZoneStartTime = GetTimeStamp()
    PXInfoPanelAddon.SurveyInfo.CountInZoneDone = 0
    PXInfoPanelAddon.SurveyInfo.TimeLeftInZoneMinutes = 0
    PXInfoPanelAddon:UpdateSurveyCount()
    PXInfoPanelAddon:UpdateUI()
  end
end

-- Finally, we'll register our event handler function to be called when the proper event occurs.
EVENT_MANAGER:RegisterForEvent(PXInfoPanelAddon.Name, EVENT_ADD_ON_LOADED, PXInfoPanelAddon.OnAddOnLoaded)

---------------------------------------------------------------------------------------------------------
-- H E L P E R    F U N C T I O N S
---------------------------------------------------------------------------------------------------------
function PXInfoPanelAddon:FindEmptySlots(location)
  local emptySlots = {}
  for i = FindFirstEmptySlotInBag(location) or 250, GetBagSize(location) do
    if GetItemName(location, i) == "" then
      emptySlots[#emptySlots + 1] = i
    end
  end
  return emptySlots
end

function PXInfoPanelAddon:AdjustItemLink(e)
  if (string.sub(e, 1, 3) == '|H1') then
    return '|H0' .. string.sub(e, 4)
  end
end

function PXInfoPanelAddon:GetItemPrice(itemLink)
  if (itemLink == nil or LibPrice == nil) then
    return 0
  end

  local price, s, f = LibPrice.ItemLinkToPriceGold(itemLink, "mm", "att", "ttc")
  if (price == nil) then
    return 0
  end

  return price
end

function PXInfoPanelAddon:GetPVPInfo()
  PXInfoPanelAddon.PVPInfo.RankPoints = GetUnitAvARankPoints("player")
  PXInfoPanelAddon.PVPInfo.Rank, PXInfoPanelAddon.PVPInfo.SubRank = GetUnitAvARank("player")
  PXInfoPanelAddon.PVPInfo.RankName = GetAvARankName(GetUnitGender("player"), PXInfoPanelAddon.PVPInfo.Rank)
  PXInfoPanelAddon.PVPInfo.SubRankStartsAt,
    PXInfoPanelAddon.PVPInfo.NextSubRankAt,
    PXInfoPanelAddon.PVPInfo.RankStartsAt,
    PXInfoPanelAddon.PVPInfo.NextRankAt = GetAvARankProgress(PXInfoPanelAddon.PVPInfo.RankPoints)
  PXInfoPanelAddon.PVPInfo.PointsNeededForRank = GetNumPointsNeededForAvARank(Rank)
end

function PXInfoPanelAddon:GetTimeElapsed()
  return GetTimeStamp() - PXInfoPanelAddon.StartTimeMS 
end

function PXInfoPanelAddon:GetZoneTimeElapsed()
  return GetTimeStamp() - PXInfoPanelAddon.ZoneStartTime
end

function PXInfoPanelAddon:Notify(text, sound)
  local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(text, sound)
  params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_ACHIEVEMENT_AWARDED)
  params:SetText(text)
  CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
end

function PXInfoPanelAddon:ResetCustomMonitorCounts()
  PXInfoPanelAddon.savedVariables.customMonitor1.Count = 0
  PXInfoPanelAddon.savedVariables.customMonitor1.DisplayText = ''
  PXInfoPanelAddon.savedVariables.customMonitor2.Count = 0
  PXInfoPanelAddon.savedVariables.customMonitor2.DisplayText = ''
  PXInfoPanelAddon.savedVariables.customMonitor3.Count = 0
  PXInfoPanelAddon.savedVariables.customMonitor3.DisplayText = ''
  PXInfoPanelAddon.savedVariables.customMonitor4.Count = 0
  PXInfoPanelAddon.savedVariables.customMonitor4.DisplayText = ''
  PXInfoPanelAddon.savedVariables.customMonitor5.Count = 0
  PXInfoPanelAddon.savedVariables.customMonitor5.DisplayText = ''
  PXInfoPanelAddon.savedVariables.customMonitor6.Count = 0
  PXInfoPanelAddon.savedVariables.customMonitor6.DisplayText = ''
  PXInfoPanelAddon.savedVariables.customMonitor7.Count = 0
  PXInfoPanelAddon.savedVariables.customMonitor7.DisplayText = ''
  PXInfoPanelAddon.savedVariables.customMonitor8.Count = 0
  PXInfoPanelAddon.savedVariables.customMonitor8.DisplayText = ''
  PXInfoPanelAddon.savedVariables.customMonitor9.Count = 0
  PXInfoPanelAddon.savedVariables.customMonitor9.DisplayText = ''
  PXInfoPanelAddon.savedVariables.customMonitor10.Count = 0
  PXInfoPanelAddon.savedVariables.customMonitor10.DisplayText = ''
end

function PXInfoPanelAddon:RestorePosition()
  local left = self.savedVariables.left
  local top = self.savedVariables.top
  if left == 0 and top == 0 then
    left = 100
    top = 100
  end
 
  PXInfoPanelAddonIndicator:ClearAnchors()
  PXInfoPanelAddonIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function PXInfoPanelAddon:Round(num, idp)
  return tonumber(string.format("%." .. (idp or 0) .. "f", num))
  --local mult = 10^(idp or 0)
  --return math.floor(num * mult + 0.5) / mult
end

function PXInfoPanelAddon:UpdateBagCounts(itemLink)
  local itemName = GetItemLinkName(itemLink)
  local formattedItemName = zo_strformat("<<1>>", itemName)
  local stackCountBackpack, stackCountBank, stackCountCraftBag = GetItemLinkStacks(itemLink)
  local stackTotal = stackCountBackpack + stackCountBank + stackCountCraftBag

  if (self.savedVariables.customMonitor1.Show == true) then
    if (itemLink == self.savedVariables.customMonitor1.SearchText) then
      self.savedVariables.customMonitor1.Count = stackTotal
      self.savedVariables.customMonitor1.DisplayText = formattedItemName
    end
  end
  if (self.savedVariables.customMonitor2.Show == true) then
    if (itemLink == self.savedVariables.customMonitor2.SearchText) then
      self.savedVariables.customMonitor2.Count = stackTotal
      self.savedVariables.customMonitor2.DisplayText = formattedItemName
    end
  end
  if (self.savedVariables.customMonitor3.Show == true) then
    if (itemLink == self.savedVariables.customMonitor3.SearchText) then
      self.savedVariables.customMonitor3.Count = stackTotal
      self.savedVariables.customMonitor3.DisplayText = formattedItemName
    end
  end
  if (self.savedVariables.customMonitor4.Show == true) then
    if (itemLink == self.savedVariables.customMonitor4.SearchText) then
      self.savedVariables.customMonitor4.Count = stackTotal
      self.savedVariables.customMonitor4.DisplayText = formattedItemName
    end
  end
  if (self.savedVariables.customMonitor5.Show == true) then
    if (itemLink == self.savedVariables.customMonitor5.SearchText) then
      self.savedVariables.customMonitor5.Count = stackTotal
      self.savedVariables.customMonitor5.DisplayText = formattedItemName
    end
  end
  if (self.savedVariables.customMonitor6.Show == true) then
    if (itemLink == self.savedVariables.customMonitor6.SearchText) then
      self.savedVariables.customMonitor6.Count = stackTotal
      self.savedVariables.customMonitor6.DisplayText = formattedItemName
    end
  end
  if (self.savedVariables.customMonitor7.Show == true) then
    if (itemLink == self.savedVariables.customMonitor7.SearchText) then
      self.savedVariables.customMonitor7.Count = stackTotal
      self.savedVariables.customMonitor7.DisplayText = formattedItemName
    end
  end
  if (self.savedVariables.customMonitor8.Show == true) then
    if (itemLink == self.savedVariables.customMonitor8.SearchText) then
      self.savedVariables.customMonitor8.Count = stackTotal
      self.savedVariables.customMonitor8.DisplayText = formattedItemName
    end
  end
  if (self.savedVariables.customMonitor9.Show == true) then
    if (itemLink == self.savedVariables.customMonitor9.SearchText) then
      self.savedVariables.customMonitor9.Count = stackTotal
      self.savedVariables.customMonitor9.DisplayText = formattedItemName
    end
  end
  if (self.savedVariables.customMonitor10.Show == true) then
    if (itemLink == self.savedVariables.customMonitor10.SearchText) then
      self.savedVariables.customMonitor10.Count = stackTotal
      self.savedVariables.customMonitor10.DisplayText = formattedItemName
    end
  end

  for x = 1, #self.MonitorMaterial do
    if (itemLink == self.MonitorMaterial[x].RefinedLink) then
      self.MonitorMaterial[x].InventoryCount = stackCountBackpack + stackCountBank + stackCountCraftBag
    end
    if (itemLink == self.MonitorMaterial[x].RawLink) then
      self.MonitorMaterial[x].RefinedInventoryCount = stackCountBackpack + stackCountBank + stackCountCraftBag
    end
  end
end

function PXInfoPanelAddon:UpdateWritStatus()
  local journal = {}
  local journalInfo = {}
  local text = ""
  local completedText = ""
  local conditionText = ""

  PXInfoPanelAddon.WritStatus.BlackSmithing = false
  PXInfoPanelAddon.WritStatus.BlackSmithingColor = PXInfoPanelAddon.ColorRed 
  PXInfoPanelAddon.WritStatus.BlackSmithingPickedUp = false
  PXInfoPanelAddon.WritStatus.Clothing = false
  PXInfoPanelAddon.WritStatus.ClothingColor = PXInfoPanelAddon.ColorRed 
  PXInfoPanelAddon.WritStatus.ClothingPickedUp = false
  PXInfoPanelAddon.WritStatus.Woodworking = false
  PXInfoPanelAddon.WritStatus.WoodworkingColor = PXInfoPanelAddon.ColorRed 
  PXInfoPanelAddon.WritStatus.WoodworkingPickedUp = false
  PXInfoPanelAddon.WritStatus.Jewelry = false
  PXInfoPanelAddon.WritStatus.JewelryColor = PXInfoPanelAddon.ColorRed 
  PXInfoPanelAddon.WritStatus.JewelryPickedUp = false
  PXInfoPanelAddon.WritStatus.Alchemy = false
  PXInfoPanelAddon.WritStatus.AlchemyColor = PXInfoPanelAddon.ColorRed 
  PXInfoPanelAddon.WritStatus.AlchemyickedUp = false
  PXInfoPanelAddon.WritStatus.Enchanting = false
  PXInfoPanelAddon.WritStatus.EnchantingColor = PXInfoPanelAddon.ColorRed 
  PXInfoPanelAddon.WritStatus.EnchantingPickedUp = false
  PXInfoPanelAddon.WritStatus.Provisioning = false
  PXInfoPanelAddon.WritStatus.ProvisioningColor = PXInfoPanelAddon.ColorRed 
  PXInfoPanelAddon.WritStatus.ProvisioningPickedUp = false

  for questIndex = 1, MAX_JOURNAL_QUESTS do
    journalInfo = {}
    if IsValidQuestIndex(questIndex) then
      journalInfo.RepeatType = GetJournalQuestRepeatType(questIndex)
      journalInfo.QuestName, journalInfo.BackgroundText, journalInfo.ActiveStepText, journalInfo.ActiveStepType,
      journalInfo.ActiveStepTrackerOverrideText, journalInfo.Completed, journalInfo.Tracked, journalInfo.QuestLevel,
      journalInfo.Pushed, journalInfo.QuestType, journalInfo.InstanceDisplayType = GetJournalQuestInfo(questIndex)

      if journalInfo.QuestType == QUEST_TYPE_CRAFTING and
         journalInfo.RepeatType == QUEST_REPEAT_DAILY then

        local steps = GetJournalQuestNumSteps(questIndex)
        local writCompleted = false
        local partiallyComplete = false
        for z = 0, steps + 1 do
          local stepText, stepVisibility, stepType, stepTrackerOverrideText, conditions = GetJournalQuestStepInfo(questIndex, z)
          for zz = 0, conditions + 1 do
            conditionText, current, max, isFailCondition, isComplete, isCreditShared, isVisible = GetJournalQuestConditionInfo(questIndex, z, zz)
            if (current > 0) then
              partiallyComplete = true
            end
            local subText = string.sub(conditionText, 1, 7)
            if subText == GetString(PXIP_WRITS_DELIVER) then
              writCompleted = true
            end
          end
        end

        if writCompleted == true then
          completedText = GetString(PXIP_WRITS_COMPLETED)

          if (string.match(journalInfo.QuestName, GetString(PXIP_WRITS_BLACKSMITHING_SUBSTRING))) then
            PXInfoPanelAddon.WritStatus.BlackSmithing = true
            PXInfoPanelAddon.WritStatus.BlackSmithingColor = PXInfoPanelAddon.ColorGreen
            PXInfoPanelAddon.WritStatus.BlackSmithingPickedUp = true
          elseif (string.match(journalInfo.QuestName, GetString(PXIP_WRITS_CLOTHING_SUBSTRING))) then
            PXInfoPanelAddon.WritStatus.Clothing = true
            PXInfoPanelAddon.WritStatus.ClothingColor = PXInfoPanelAddon.ColorGreen
            PXInfoPanelAddon.WritStatus.ClothingPickedUp = true
          elseif (string.match(journalInfo.QuestName, GetString(PXIP_WRITS_WOODWORKING_SUBSTRING))) then
            PXInfoPanelAddon.WritStatus.Woodworking = true
            PXInfoPanelAddon.WritStatus.WoodworkingColor = PXInfoPanelAddon.ColorGreen
            PXInfoPanelAddon.WritStatus.WoodworkingPickedUp = true
          elseif (string.match(journalInfo.QuestName, GetString(PXIP_WRITS_JEWELRY_SUBSTRING))) then
            PXInfoPanelAddon.WritStatus.Jewelry = true
            PXInfoPanelAddon.WritStatus.JewelryColor = PXInfoPanelAddon.ColorGreen
            PXInfoPanelAddon.WritStatus.JewelryPickedUp = true
          elseif (string.match(journalInfo.QuestName, GetString(PXIP_WRITS_ALCHEMY_SUBSTRING))) then
            PXInfoPanelAddon.WritStatus.Alchemy = true
            PXInfoPanelAddon.WritStatus.AlchemyColor = PXInfoPanelAddon.ColorGreen
            PXInfoPanelAddon.WritStatus.AlchemyPickedUp = true
          elseif (string.match(journalInfo.QuestName, GetString(PXIP_WRITS_ENCHANTING_SUBSTRING))) then
            PXInfoPanelAddon.WritStatus.Enchanting = true
            PXInfoPanelAddon.WritStatus.EnchantingColor = PXInfoPanelAddon.ColorGreen
            PXInfoPanelAddon.WritStatus.EnchantingPickedUp = true
          elseif(string.match(journalInfo.QuestName, GetString(PXIP_WRITS_PROVISIONING_SUBSTRING))) then
            PXInfoPanelAddon.WritStatus.Provisioning = true
            PXInfoPanelAddon.WritStatus.ProvisioningColor = PXInfoPanelAddon.ColorGreen
            PXInfoPanelAddon.WritStatus.ProvisioningPickedUp = true
          end
        else
          if (string.match(journalInfo.QuestName, GetString(PXIP_WRITS_BLACKSMITHING_SUBSTRING))) then
            PXInfoPanelAddon.WritStatus.BlackSmithingPickedUp = true
            if (partiallyComplete == true) then
              PXInfoPanelAddon.WritStatus.BlackSmithingColor = PXInfoPanelAddon.ColorGold
            end
          elseif (string.match(journalInfo.QuestName, GetString(PXIP_WRITS_CLOTHING_SUBSTRING))) then
            PXInfoPanelAddon.WritStatus.ClothingPickedUp = true
            if (partiallyComplete == true) then
              PXInfoPanelAddon.WritStatus.ClothingColor = PXInfoPanelAddon.ColorGold
            end
          elseif (string.match(journalInfo.QuestName, GetString(PXIP_WRITS_WOODWORKING_SUBSTRING))) then
            PXInfoPanelAddon.WritStatus.WoodworkingPickedUp = true
            if (partiallyComplete == true) then
              PXInfoPanelAddon.WritStatus.WoodworkingColor = PXInfoPanelAddon.ColorGold
            end
          elseif (string.match(journalInfo.QuestName, GetString(PXIP_WRITS_JEWELRY_SUBSTRING))) then
            PXInfoPanelAddon.WritStatus.JewelryPickedUp = true
            if (partiallyComplete == true) then
              PXInfoPanelAddon.WritStatus.JewelryColor = PXInfoPanelAddon.ColorGold
            end
          elseif (string.match(journalInfo.QuestName, GetString(PXIP_WRITS_ALCHEMY_SUBSTRING))) then
            PXInfoPanelAddon.WritStatus.AlchemyPickedUp = true
            if (partiallyComplete == true) then
              PXInfoPanelAddon.WritStatus.AlchemyColor = PXInfoPanelAddon.ColorGold
            end
          elseif (string.match(journalInfo.QuestName, GetString(PXIP_WRITS_ENCHANTING_SUBSTRING))) then
            PXInfoPanelAddon.WritStatus.EnchantingPickedUp = true
            if (partiallyComplete == true) then
              PXInfoPanelAddon.WritStatus.EnchantingColor = PXInfoPanelAddon.ColorGold
            end
          elseif(string.match(journalInfo.QuestName, GetString(PXIP_WRITS_PROVISIONING_SUBSTRING))) then
            PXInfoPanelAddon.WritStatus.ProvisioningPickedUp = true
            if (partiallyComplete == true) then
              PXInfoPanelAddon.WritStatus.ProvisioningColor = PXInfoPanelAddon.ColorGold
            end
          end
        end

        text = text .. journalInfo.QuestName .. " -- " .. completedText .. "\n"
        completedText = ""
      end
    end
  end

  PXInfoPanelAddon.WritStatusText = text
  PXInfoPanelAddon:UpdateUI()
end

function PXInfoPanelAddon:UpdateUI()
  local text = ''
  local newLine = ''

  PXInfoPanelAddon:UpdateMonitoredInventory()

  if PXInfoPanelAddon.Showing == false then
    PXInfoPanelAddonIndicator:SetHidden(true)
  else
    PXInfoPanelAddonIndicator:SetHidden(false)
  end

  PXInfoPanelAddon.TimeElapsedMS = PXInfoPanelAddon.GetTimeElapsed()
  if PXInfoPanelAddon.TimeElapsedMS == 0 then
    PXInfoPanelAddon.TimeElapsedMS = 1
  end
  PXInfoPanelAddon.TimeElapsedInZoneMS = PXInfoPanelAddon.GetZoneTimeElapsed()
  if PXInfoPanelAddon.TimeElapsedInZoneMS == 0 then
    PXInfoPanelAddon.TimeElapsedInZoneMS = 1
  end

  local timePlayedMins = self:Round(PXInfoPanelAddon.TimeElapsedMS / 60, 0)
  local timePlayedMinsInZone = self:Round(PXInfoPanelAddon:GetZoneTimeElapsed() / 60)
  local goldAMinute = self:Round((PXInfoPanelAddon.TotalGoldMade / self:Round(PXInfoPanelAddon.TimeElapsedMS)) * 60, 0)

  local isChampion = IsUnitChampion('player')
  local cp = GetUnitChampionPoints('player')

  local nextChampPointAtXP = isChampion and GetNumChampionXPInChampionPoint(cp) or GetUnitXPMax("player")

  PXInfoPanelAddon.CurrentXP = IsUnitChampion('player') and GetPlayerChampionXP() or GetUnitXP("player")
  PXInfoPanelAddon.XpNeededForNextLevel = nextChampPointAtXP - PXInfoPanelAddon.CurrentXP
  PXInfoPanelAddon.MaxXP = nextChampPointAtXP

  local xpMade = GetUnitXP("player") - PXInfoPanelAddon.StartXP
  if (xpMade < 0) then
    -- This happens when leveling up
    PXInfoPanelAddon.StartXP = 0
    xpMade = GetUnitXP("player") - PXInfoPanelAddon.StartXP
  end
  local xpAMinute = self:Round((xpMade / self:Round(PXInfoPanelAddon.TimeElapsedMS)) * 60 ,0)

  local levelUpInMin = 0
  if (xpAMinute > 0) then
    levelUpInMin = self:Round(PXInfoPanelAddon.XpNeededForNextLevel / xpAMinute, 0)
  end

  local targetLevel = IsUnitChampion('player') and GetPlayerChampionPointsEarned() +1 or GetUnitLevel('player') + 1
  local targetType  = IsUnitChampion("player") and GetString(PXIP_CP) or GetString(PXIP_LEVEL)

  if (self.savedVariables.showTime) then
    if (text == nil or text == '') then newLine = '' else  newLine = '\n' end
    text = text .. newLine .. ZO_FormatClockTime()
  end

  if (self.savedVariables.showLastLoot) then
    if (text == nil or text == '') then newLine = '' else  newLine = '\n' end
    text = text .. newLine .. GetString(PXIP_LAST) .. self.LastLoot
    newLine = '\n'

    if (self.savedVariables.lastLootLines >= 2 and self.LastLoot2 ~= nil and self.LastLoot2 ~= '') then
      text = text .. newLine .. GetString(PXIP_LAST) .. self.LastLoot2
    end
    if (self.savedVariables.lastLootLines >= 3 and self.LastLoot2 ~= nil and self.LastLoot3 ~= '') then
      text = text .. newLine .. GetString(PXIP_LAST) .. self.LastLoot3
    end
    if (self.savedVariables.lastLootLines >= 4 and self.LastLoot2 ~= nil and self.LastLoot4 ~= '') then
      text = text .. newLine .. GetString(PXIP_LAST) .. self.LastLoot4
    end
    if (self.savedVariables.lastLootLines >= 5 and self.LastLoot2 ~= nil and self.LastLoot5 ~= '') then
      text = text .. newLine .. GetString(PXIP_LAST) .. self.LastLoot5
    end
  end

  if (self.savedVariables.showLastLootInChat and self.LastLoot ~= '' and self.LastLoot ~= self.LastLootLogged) then
    if (self.savedVariables.showLastLootAndGoldInChat) then
      d(self.ColorGold .. 'PXIP ' .. self.ColorGreen .. ' -- ' .. '|r' .. self.LastLoot .. self.ColorGreen .. ' -- ' .. GetString(PXIP_TOTAL_GOLD_MADE_1) .. self:MoneyString(self.TotalGoldMade) .. ' (|cd8b620' .. self:MoneyString(goldAMinute) .. GetString(PXIP_TOTAL_GOLD_MADE_2))
    else
      d(self.ColorGold .. 'PXIP ' .. self.ColorGreen .. ' -- ' .. '|r' .. self.LastLoot)
    end
    self.LastLootLogged = self.LastLoot
  end

  if (self.savedVariables.showBestLoot) then
    if (text == nil or text == '') then newLine = '' else  newLine = '\n' end
    text = text .. newLine .. GetString(PXIP_BEST) .. self.BestLoot
  end

  if (self.savedVariables.showBestLoot2) then
    if (text == nil or text == '') then newLine = '' else  newLine = '\n' end
    text = text .. newLine .. GetString(PXIP_2ND) .. self.BestLoot2
  end

  if (self.savedVariables.showBestLoot3) then
    if (text == nil or text == '') then newLine = '' else  newLine = '\n' end
    text = text .. newLine .. GetString(PXIP_3RD) .. self.BestLoot3
  end

  if (self.savedVariables.showBestLoot4) then
    if (text == nil or text == '') then newLine = '' else  newLine = '\n' end
    text = text .. newLine .. GetString(PXIP_4TH) .. self.BestLoot4
  end

  if (self.savedVariables.showBestLoot5) then
    if (text == nil or text == '') then newLine = '' else  newLine = '\n' end
    text = text .. newLine .. GetString(PXIP_5TH) .. self.BestLoot5
  end

  if (self.savedVariables.showMaterialInventory) then
    if (text == nil or text == '') then newLine = '' else  newLine = '\n' end
    if (self.savedVariables.showDividerLine == true) then
      text = text .. newLine .. self.DividerLine
    end

    if (self.savedVariables.showMaterialInventoryCondensed == false) then
      for x = 1, #self.MonitorMaterial do
        text = text .. newLine .. self.MonitorMaterial[x].RefinedName .. ': |c08e304' .. self.MonitorMaterial[x].InventoryCount .. '|r / |cb78a4b' .. self.MonitorMaterial[x].RefinedInventoryCount .. '|r'
      end
    else
      local divider = '\n'
      for x = 1, #self.MonitorMaterial do
        if (x > 1) then
          divider = ' '
        end
        text = text .. divider .. self.MonitorMaterial[x].ShortName .. ': |c08e304' .. self.MonitorMaterial[x].InventoryCount .. '|r / |cb78a4b' .. self.MonitorMaterial[x].RefinedInventoryCount .. '|r'
      end
    end
  end

  if (self.savedVariables.customMonitor1.Show == true and self.savedVariables.customMonitor1.SearchText ~= nil and self.savedVariables.customMonitor1.Count ~= nil) then
    if (text == nil or text == '') then newLine = '' else  newLine = '\n' end
    text = text .. newLine .. self.savedVariables.customMonitor1.SearchText .. ': |c08e304' .. self.savedVariables.customMonitor1.Count .. '|r'
  end
  if (self.savedVariables.customMonitor2.Show == true and self.savedVariables.customMonitor2.SearchText ~= nil and self.savedVariables.customMonitor2.Count ~= nil) then
    if (text == nil or text == '') then newLine = '' else  newLine = '\n' end
    text = text .. newLine .. self.savedVariables.customMonitor2.SearchText .. ': |c08e304' .. self.savedVariables.customMonitor2.Count .. '|r'
  end
  if (self.savedVariables.customMonitor3.Show == true and self.savedVariables.customMonitor3.SearchText ~= nil and self.savedVariables.customMonitor3.Count ~= nil) then
    if (text == nil or text == '') then newLine = '' else  newLine = '\n' end
    text = text .. newLine .. self.savedVariables.customMonitor3.SearchText .. ': |c08e304' .. self.savedVariables.customMonitor3.Count .. '|r'
  end
  if (self.savedVariables.customMonitor4.Show == true and self.savedVariables.customMonitor4.SearchText ~= nil and self.savedVariables.customMonitor4.Count ~= nil) then
    if (text == nil or text == '') then newLine = '' else  newLine = '\n' end
    text = text .. newLine .. self.savedVariables.customMonitor4.SearchText .. ': |c08e304' .. self.savedVariables.customMonitor4.Count .. '|r'
  end
  if (self.savedVariables.customMonitor5.Show == true and self.savedVariables.customMonitor5.SearchText ~= nil and self.savedVariables.customMonitor5.Count ~= nil) then
    if (text == nil or text == '') then newLine = '' else  newLine = '\n' end
    text = text .. newLine .. self.savedVariables.customMonitor5.SearchText .. ': |c08e304' .. self.savedVariables.customMonitor5.Count .. '|r'
  end
  if (self.savedVariables.customMonitor6Show == true and self.savedVariables.customMonitor6.SearchText ~= nil and self.savedVariables.customMonitor6.Count ~= nil) then
    if (text == nil or text == '') then newLine = '' else  newLine = '\n' end
    text = text .. newLine .. self.savedVariables.customMonitor6.SearchText .. ': |c08e304' .. self.savedVariables.customMonitor6.Count .. '|r'
  end
  if (self.savedVariables.customMonitor7.Show == true and self.savedVariables.customMonitor7.SearchText ~= nil and self.savedVariables.customMonitor7.Count ~= nil) then
    if (text == nil or text == '') then newLine = '' else  newLine = '\n' end
    text = text .. newLine .. self.savedVariables.customMonitor7.SearchText .. ': |c08e304' .. self.savedVariables.customMonitor7.Count .. '|r'
  end
  if (self.savedVariables.customMonitor8.Show == true and self.savedVariables.customMonitor8.SearchText ~= nil and self.savedVariables.customMonitor8.Count ~= nil) then
    if (text == nil or text == '') then newLine = '' else  newLine = '\n' end
    text = text .. newLine .. self.savedVariables.customMonitor8.SearchText .. ': |c08e304' .. self.savedVariables.customMonitor8.Count .. '|r'
  end
  if (self.savedVariables.customMonitor9.Show == true and self.savedVariables.customMonitor9.SearchText ~= nil and self.savedVariables.customMonitor9.Count ~= nil) then
    if (text == nil or text == '') then newLine = '' else  newLine = '\n' end
    text = text .. newLine .. self.savedVariables.customMonitor9.SearchText .. ': |c08e304' .. self.savedVariables.customMonitor9.Count .. '|r'
  end
  if (self.savedVariables.customMonitor10.Show == true and self.savedVariables.customMonitor10.SearchText ~= nil and self.savedVariables.customMonitor10.Count ~= nil) then
    if (text == nil or text == '') then newLine = '' else  newLine = '\n' end
    text = text .. newLine .. self.savedVariables.customMonitor10.SearchText .. ': |c08e304' .. self.savedVariables.customMonitor10.Count .. '|r'
  end

  if (self.savedVariables.showDividerLine == true) then
    text = text .. newLine .. self.DividerLine
  end
  if (self.savedVariables.showAchievements) then
    if (text == nil or text == '') then newLine = '' else  newLine = '\n' end
    text = text .. newLine .. GetString(PXIP_ACHIEVEMENT_POINTS) .. self:MoneyString(PXInfoPanelAddon.EarnedAchievementPoints) .. ' / ' .. self:MoneyString(PXInfoPanelAddon.TotAchievementPoints) .. ' ~ ' .. self:Round((self.EarnedAchievementPoints / self.TotAchievementPoints) * 100, 0) .. '%'
  end

  if (self.savedVariables.showEnlightenedPool and self.IsEnlightenedAvailableForCharacter) then
    if (text == nil or text == '') then newLine = '' else  newLine = '\n' end
    text = text .. newLine .. PXInfoPanelAddon:GetEnlightenedPoolText()

    if GetEnlightenedPool() <= 0 and PXInfoPanelAddon.HasBeenNotifiedAboutNoEnlightenment == false then
      PXInfoPanelAddon.HasBeenNotifiedAboutNoEnlightenment = true
      local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.ACHIEVEMENT_AWARDED)
      params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_ACHIEVEMENT_AWARDED)
      params:SetText(GetString(PXIP_ENLIGHTENED_POOL_EXHAUSTED))
      CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
    end

    if GetEnlightenedPool() >= 1000000 and PXInfoPanelAddon.HasBeenNotifiedAboutNoEnlightenment == false then
      PXInfoPanelAddon.HasBeenNotifiedAboutNoEnlightenment = true
      local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.ACHIEVEMENT_AWARDED)
      params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_ACHIEVEMENT_AWARDED)
      params:SetText(GetString(PXIP_ENLIGHTENED_POOL_ABOVE_ONE_MILLION))
      CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
    end
  end

  local zoneText = ''
  if (self.savedVariables.showTotalZoneMinutesPlayed) then
    zoneText = ' -- ' .. GetString(PXIP_TIME_PLAYED_IN_ZONE) .. ' ' .. timePlayedMinsInZone
  end
  if (self.savedVariables.showTotalMinutesPlayed) then
    if (text == nil or text == '') then newLine = '' else  newLine = '\n' end
    text = text .. newLine .. GetString(PXIP_TOTAL_MINS_PLAYED) .. timePlayedMins .. zoneText
  end

  if (self.savedVariables.showLevelProgress and self.CurrentXP ~= nil and self.CurrentXP > 0) then
    if (text == nil or text == '') then newLine = '' else  newLine = '\n' end
    text = text .. newLine .. GetString(PXIP_LEVEL_PROGRESS) .. self:MoneyString(self.CurrentXP) .. ' / ' .. self:MoneyString(self.MaxXP) .. ' ~ ' .. self:Round((self.CurrentXP / self.MaxXP) * 100, 0) .. '%'
  end

  if (self.savedVariables.showGrindStatus and levelUpInMin > 0) then
    if (text == nil or text == '') then newLine = '' else  newLine = '\n' end
    text = text .. newLine .. GetString(PXIP_GRIND_STATUS_1) .. targetType .. ' ' .. targetLevel .. GetString(PXIP_GRIND_STATUS_2) .. levelUpInMin .. GetString(PXIP_GRIND_STATUS_3)
  end

  if (self.savedVariables.showTotalGoldMade) then
    if (text == nil or text == '') then newLine = '' else  newLine = '\n' end
    text = text .. newLine .. GetString(PXIP_TOTAL_GOLD_MADE_1) .. self:MoneyString(self.TotalGoldMade) .. ' (|cd8b620' .. self:MoneyString(goldAMinute) .. GetString(PXIP_TOTAL_GOLD_MADE_2)
  end

  if (self.savedVariables.showTotalXPMade) then
    if (text == nil or text == '') then newLine = '' else  newLine = '\n' end
    text = text .. newLine .. GetString(PXIP_TOTAL_XP_MADE_1) .. self:MoneyString(xpMade) .. ' (|cd8b620' .. self:MoneyString(xpAMinute) .. GetString(PXIP_TOTAL_XP_MADE_2)
  end
  
  if (self.savedVariables.showPVPInfoOnlyWhenInPVP) then
    if (IsInCampaign()) then
      text = PXInfoPanelAddon:ShowPVPInformation(text, newLine)
    end
  else
    text = PXInfoPanelAddon:ShowPVPInformation(text, newLine)
  end

  if (self.savedVariables.showTotalWritVouchers and self.LastWritVouchers > 0) then
    if (text == nil or text == '') then newLine = '' else  newLine = '\n' end
    text = text .. newLine .. GetString(PXIP_TOTAL_WRIT_VOUCHERS) .. self:MoneyString(PXInfoPanelAddon.LastWritVouchers)
  end

  if (self.savedVariables.showLastLoreBookLearned and self.LastLoreBookLearned ~= nill and self.LastLoreBookLearned ~= '') then
    if (text == nil or text == '') then newLine = '' else  newLine = '\n' end
    text = text .. newLine .. self.LastLoreBookLearned
  end

  if (self.savedVariables.showSurveyCountInCurrentZone and self.SurveyInfo.CountInZone > 0) then
    text = text .. newLine .. GetString(PXIP_SURVEYS_IN_ZONE) .. ' ' .. self.SurveyInfo.CountInZone .. ' (' .. self.SurveyInfo.StackCountInZone .. ' locations), ' .. self.SurveyInfo.CountInZoneDone .. ' done. Done in ' .. self.SurveyInfo.TimeLeftInZoneMinutes .. ' minutes.'
  end

  if (self.savedVariables.showFishingStatistics and self.savedVariables.fishingStats.FishCaughtTotal > 0) then
    text = text .. newLine .. GetString(PXIP_FISH_CAUGHT) .. ' ' .. PXInfoPanelAddon.savedVariables.fishingStats.FishCaughtSession
    text = text .. '/' .. PXInfoPanelAddon.savedVariables.fishingStats.FishCaughtTotal
    text = text .. ', Profits: ' .. PXInfoPanelAddon:MoneyString(PXInfoPanelAddon:Round(PXInfoPanelAddon.savedVariables.fishingStats.FishGoldMadeSession))
    text = text .. '/' .. PXInfoPanelAddon:MoneyString(PXInfoPanelAddon:Round(PXInfoPanelAddon.savedVariables.fishingStats.FishGoldMadeTotal))
  end

  if (self.savedVariables.showWritStatus and self.WritStatusText ~= nill and self.WritStatusText ~= '') then
    if (text == nil or text == '') then newLine = '' else  newLine = '\n' end

    if (self.savedVariables.showWritStatusCondensed) then
      text = text .. newLine
      if (PXInfoPanelAddon.WritStatus.BlackSmithingPickedUp) then
        text = text .. PXInfoPanelAddon.WritStatus.BlackSmithingColor .. GetString(PXIP_BLACKSMITHING_LETTER)
      end
      if (PXInfoPanelAddon.WritStatus.ClothingPickedUp) then
        text = text .. PXInfoPanelAddon.WritStatus.ClothingColor .. GetString(PXIP_CLOTHING_LETTER)
      end
      if (PXInfoPanelAddon.WritStatus.WoodworkingPickedUp) then
        text = text .. PXInfoPanelAddon.WritStatus.WoodworkingColor .. GetString(PXIP_WOODWORKING_LETTER)
      end
      if (PXInfoPanelAddon.WritStatus.JewelryPickedUp) then
        text = text .. PXInfoPanelAddon.WritStatus.JewelryColor .. GetString(PXIP_JEWELRY_LETTER)
      end
      if (PXInfoPanelAddon.WritStatus.AlchemyPickedUp) then
        text = text .. PXInfoPanelAddon.WritStatus.AlchemyColor .. GetString(PXIP_ALCHEMY_LETTER)
      end
      if (PXInfoPanelAddon.WritStatus.EnchantingPickedUp) then
        text = text .. PXInfoPanelAddon.WritStatus.EnchantingColor .. GetString(PXIP_ENCHANTING_LETTER)
      end
      if (PXInfoPanelAddon.WritStatus.ProvisioningPickedUp) then
        text = text .. PXInfoPanelAddon.WritStatus.ProvisioningColor .. GetString(PXIP_PROVISIONING_LETTER)
      end
    else
      text = text .. newLine .. self.WritStatusText
    end

    -- Notify on all writs done:
    if (self.savedVariables.allWritsDoneNotified == false and PXInfoPanelAddon.WritStatus.BlackSmithing and PXInfoPanelAddon.WritStatus.Clothing and PXInfoPanelAddon.WritStatus.Woodworking and PXInfoPanelAddon.WritStatus.Jewelry and PXInfoPanelAddon.WritStatus.Alchemy and PXInfoPanelAddon.WritStatus.Enchanting and PXInfoPanelAddon.WritStatus.Provisioning) then
      local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.ACHIEVEMENT_AWARDED)
      params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_ACHIEVEMENT_AWARDED)
      params:SetText(PXInfoPanelAddon.ColorGreen .. GetString(PXIP_WRITS_ALL_WRITS_DONE) .. PXInfoPanelAddon.ColorGold .. GetString(PXIP_WRITS_TIME_TO_TURN_THEM_IN))
      CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
      self.savedVariables.allWritsDoneNotified = true
    end
  end

  text = text .. PXInfoPanelAddon:MonitorResearch()
  self:WriteLog(text)
end

function PXInfoPanelAddon:MonitorResearch()
  local text = ''
  local char = '\n'
  if (self.savedVariables.enableMonitorResearchBlacksmithing) then
    if (self.savedVariables.enableMonitorResearchShowCondensed) then
      text = text .. PXInfoPanelAddon:CheckResearch(char, CRAFTING_TYPE_BLACKSMITHING, GetString(PXIP_BLACKSMITHING_LETTER))
    else
      text = text .. PXInfoPanelAddon:CheckResearch('\n', CRAFTING_TYPE_BLACKSMITHING, GetString(PXIP_BLACKSMITHING_LETTER))
    end
    if (text ~= '') then
      char = ','
    end
  end
  if (self.savedVariables.enableMonitorResearchClothing) then
    if (self.savedVariables.enableMonitorResearchShowCondensed) then
      text = text .. PXInfoPanelAddon:CheckResearch(char, CRAFTING_TYPE_CLOTHIER, GetString(PXIP_CLOTHING_LETTER))
    else
      text = text .. PXInfoPanelAddon:CheckResearch('\n', CRAFTING_TYPE_CLOTHIER, GetString(PXIP_CLOTHING_LETTER))
    end
    if (text ~= '') then
      char = ','
    end
  end
  if (self.savedVariables.enableMonitorResearchWoodworking) then
    if (self.savedVariables.enableMonitorResearchShowCondensed) then
      text = text .. PXInfoPanelAddon:CheckResearch(char, CRAFTING_TYPE_WOODWORKING, GetString(PXIP_WOODWORKING_LETTER))
    else
      text = text .. PXInfoPanelAddon:CheckResearch('\n', CRAFTING_TYPE_WOODWORKING, GetString(PXIP_WOODWORKING_LETTER))
    end
    if (text ~= '') then
      char = ','
    end
  end
  if (self.savedVariables.enableMonitorResearchJewelry) then
    if (self.savedVariables.enableMonitorResearchShowCondensed) then
      text = text .. PXInfoPanelAddon:CheckResearch(char, CRAFTING_TYPE_JEWELRYCRAFTING, GetString(PXIP_JEWELRY_LETTER))
    else
      text = text .. PXInfoPanelAddon:CheckResearch('\n', CRAFTING_TYPE_JEWELRYCRAFTING, GetString(PXIP_JEWELRY_LETTER))
    end
    if (text ~= '') then
      char = ','
    end
  end

  return text
end

function PXInfoPanelAddon:CalculateResearchAll()
  PXInfoPanelAddon:CalculateResearch(CRAFTING_TYPE_BLACKSMITHING, PXIP.BI)
  PXInfoPanelAddon:CalculateResearch(CRAFTING_TYPE_CLOTHIER, PXIP.CI)
  PXInfoPanelAddon:CalculateResearch(CRAFTING_TYPE_WOODWORKING, PXIP.WI)
  PXInfoPanelAddon:CalculateResearch(CRAFTING_TYPE_JEWELRYCRAFTING, PXIP.JI)
end

function PXInfoPanelAddon:CalculateResearch(craftingType, ri)
  ri.LinesCurrentlyResearching = 0

  ri.MaxLinesResearch = GetMaxSimultaneousSmithingResearch(craftingType)
  local researchLines = GetNumSmithingResearchLines(craftingType)
  local shortestResearchTimeInLine = 60 * 60 * 24 * 30 * 12 -- a year
  local traitName = ''
  local ttype = ''

  -- Check to see if all traits are known for this crafting type:
  for x = 1, researchLines do
    local lineInfoName, icon, numTraits, timeRequiredForNextResearchSecs = GetSmithingResearchLineInfo(craftingType, x)
    for trait = 1, numTraits do
      local traitType, traitDescription, known = GetSmithingResearchLineTraitInfo(craftingType, x, trait)
      if (known == false) then
        ri.AllKnown = false
      end

      local duration, timeRemainingSecs = GetSmithingResearchLineTraitTimes(craftingType, x, trait)
      if (timeRemainingSecs ~= nil and timeRemainingSecs > 0) then
        ri.LinesCurrentlyResearching = ri.LinesCurrentlyResearching + 1
        if (timeRemainingSecs < shortestResearchTimeInLine) then
          ri.SecondsRemaining = timeRemainingSecs
          ri.TimeStamp = GetTimeStamp()
          ri.TimeStringLong = self:SecondsToClock(timeRemainingSecs)
          ri.TimeStringShort = self:FormatSeconds(timeRemainingSecs)
          shortestResearchTimeInLine = timeRemainingSecs
        end
      end
    end
  end
end

function PXInfoPanelAddon:CheckResearch(newLine, craftingTraitType, name)
  local text = ''
  local ri = {}
  local color = PXInfoPanelAddon.ColorRed

  if (craftingTraitType == CRAFTING_TYPE_BLACKSMITHING) then
    ri = PXIP.BI
  elseif (craftingTraitType == CRAFTING_TYPE_CLOTHIER) then
    ri = PXIP.CI
  elseif (craftingTraitType == CRAFTING_TYPE_WOODWORKING) then
    ri = PXIP.WI
  elseif (craftingTraitType == CRAFTING_TYPE_JEWELRYCRAFTING) then
    ri = PXIP.JI
  end

  if (ri.AllKnown) then
    return
  end

  if (ri.LinesCurrentlyResearching == ri.MaxLinesResearch) then
    color = PXInfoPanelAddon.ColorGreen
  else
  end

  if (ri.LinesCurrentlyResearching == 0) then
    if (self.savedVariables.enableMonitorResearchShowCondensed) then
      text = newLine .. color .. name .. ' (' .. ri.LinesCurrentlyResearching .. '/' .. ri.MaxLinesResearch .. ')|r: -'
    else
      text = newLine .. color .. name .. ' (' .. ri.LinesCurrentlyResearching .. '/' .. ri.MaxLinesResearch .. ')|r: No research active.'
    end
  else
    secondsLeft = ri.SecondsRemaining - ((GetTimeStamp() - ri.TimeStamp))
    if (self.savedVariables.enableMonitorResearchShowCondensed) then
      text = newLine .. color .. name .. ' (' .. ri.LinesCurrentlyResearching .. '/' .. ri.MaxLinesResearch .. ')|r: ' .. PXInfoPanelAddon:SecondsToClock(secondsLeft)
    else
      text = newLine .. color .. name .. ' (' ..  ri.LinesCurrentlyResearching .. '/' .. ri.MaxLinesResearch .. ')|r: ' .. self:FormatSeconds(secondsLeft)
    end
  end

  return text
end

function PXInfoPanelAddon:BooleanToString(b)
  if (b == true) then
    return 'true'
  else
    return 'false'
  end
end

function PXInfoPanelAddon:GetEnlightenedPoolText()
  local txt = GetString(PXIP_ENLIGHTENED_POOL)
  local ep = self.EnlightenedPool

  if (ep > 1000000) then
    txt = txt .. self.ColorRed
  elseif (ep > 800000) then
    txt = txt .. self.ColorOrange
  end

  txt = txt .. self:MoneyString(ep) .. '|r'
  return txt 
end

function PXInfoPanelAddon:FormatSeconds(secondsArg)
   local weeks = math.floor(secondsArg / 604800)
   local remainder = secondsArg % 604800
   local days = math.floor(remainder / 86400)
   local remainder = remainder % 86400
   local hours = math.floor(remainder / 3600)
   local remainder = remainder % 3600
   local minutes = math.floor(remainder / 60)
   local seconds = remainder % 60
   
   local weeksTxt, daysTxt, hoursTxt, minutesTxt, secondsTxt = ""
   if weeks == 1 then weeksTxt = 'week' else weeksTxt = 'weeks' end
   if days == 1 then daysTxt = 'day' else daysTxt = 'days' end
   if hours == 1 then hoursTxt = 'hour' else hoursTxt = 'hours' end
   if minutes == 1 then minutesTxt = 'minute' else minutesTxt = 'minutes' end
   if seconds == 1 then secondsTxt = 'second' else secondsTxt = 'seconds' end
   
   if secondsArg >= 604800 then
      return weeks .. ' ' .. weeksTxt .. ', ' .. days .. ' ' .. daysTxt .. ', ' .. hours .. ' ' .. hoursTxt .. ', ' .. minutes .. ' ' .. minutesTxt .. ', ' .. seconds .. ' ' .. secondsTxt
   elseif secondsArg >= 86400 then
      return days .. ' ' .. daysTxt .. ', ' .. hours .. ' ' .. hoursTxt .. ', ' .. minutes .. ' ' .. minutesTxt .. ', ' .. seconds .. ' ' .. secondsTxt
   elseif secondsArg >= 3600 then
      return hours .. ' ' .. hoursTxt .. ', ' .. minutes .. ' ' .. minutesTxt .. ', ' .. seconds .. ' ' .. secondsTxt
   elseif secondsArg >= 60 then
      return minutes .. ' ' .. minutesTxt .. ', ' .. seconds .. ' ' .. secondsTxt
   else
      return seconds  ..  ' '  ..  secondsTxt
   end  
end

function PXInfoPanelAddon:MoneyString(amount)
  local formatted = amount
  while true do  
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted
end

function PXInfoPanelAddon:SecondsToClock(seconds)
  local seconds = tonumber(seconds)

  if seconds <= 0 then
    return "00:00:00";
  else
    hours = string.format("%02.f", math.floor(seconds / 3600));
    mins = string.format("%02.f", math.floor(seconds / 60 - (hours * 60)));
    secs = string.format("%02.f", math.floor(seconds - hours * 3600 - mins * 60));
    return hours..":"..mins..":"..secs
  end
end

function PXInfoPanelAddon:ShowPVPInformation(text, newLine)
  PXInfoPanelAddon:GetPVPInfo()
  local apMade = PXInfoPanelAddon.PVPInfo.RankPoints - PXInfoPanelAddon.StartAP
  local apAMinute = self:Round((apMade / self:Round(PXInfoPanelAddon.TimeElapsedMS)) * 60 ,0)

  if (self.savedVariables.showPVPRank) then
    text = text .. newLine .. 'PVP: ' .. PXInfoPanelAddon.PVPInfo.RankName
  end

  if (self.savedVariables.showPVPQueueTimeWhenQueued and PXInfoPanelAddon.PVPInfo.QueuePosition ~= nil and PXInfoPanelAddon.PVPInfo.QueuePosition > 0) then
    text = text .. newLine .. 'PVP: Queue Position for ' .. PXInfoPanelAddon.PVPInfo.CampaignName .. ' is ' .. PXInfoPanelAddon.PVPInfo.QueuePosition
  end

  if (self.savedVariables.showPVPInfo) then
    local apNeededForNextLevel = PXInfoPanelAddon.PVPInfo.NextRankAt - PXInfoPanelAddon.PVPInfo.RankPoints
    if (apMade > 0) then
      local apLevelUpInMin = self:Round(apNeededForNextLevel / apAMinute, 0)
      text = text .. newLine .. 'PVP: AP Made: ' .. self:MoneyString(apMade) .. ' (|cd8b620' .. self:MoneyString(apAMinute) .. GetString(PXIP_TOTAL_XP_MADE_2)
      text = text .. newLine .. 'PVP: Level up needs ' .. self:MoneyString(apNeededForNextLevel) .. ' AP. Level up in ' .. apLevelUpInMin .. ' minutes.'
    else
      text = text .. newLine .. 'PVP: Level up needs ' .. self:MoneyString(apNeededForNextLevel)
    end
  end

  return text
end

function PXInfoPanelAddon:UpdateMonitoredInventory()
  for x = 1, #PXInfoPanelAddon.MonitorMaterial do
    PXInfoPanelAddon:UpdateBagCounts(PXInfoPanelAddon.MonitorMaterial[x].RawLink)
    PXInfoPanelAddon:UpdateBagCounts(PXInfoPanelAddon.MonitorMaterial[x].RefinedLink)
  end

  if (PXInfoPanelAddon.savedVariables.customMonitor1.Show == true) then
    PXInfoPanelAddon:UpdateBagCounts(PXInfoPanelAddon.savedVariables.customMonitor1.SearchText)
  end
  if (PXInfoPanelAddon.savedVariables.customMonitor2.Show == true) then
    PXInfoPanelAddon:UpdateBagCounts(PXInfoPanelAddon.savedVariables.customMonitor2.SearchText)
  end
  if (PXInfoPanelAddon.savedVariables.customMonitor3.Show == true) then
    PXInfoPanelAddon:UpdateBagCounts(PXInfoPanelAddon.savedVariables.customMonitor3.SearchText)
  end
  if (PXInfoPanelAddon.savedVariables.customMonitor4.Show == true) then
    PXInfoPanelAddon:UpdateBagCounts(PXInfoPanelAddon.savedVariables.customMonitor4.SearchText)
  end
  if (PXInfoPanelAddon.savedVariables.customMonitor5.Show == true) then
    PXInfoPanelAddon:UpdateBagCounts(PXInfoPanelAddon.savedVariables.customMonitor5.SearchText)
  end
  if (PXInfoPanelAddon.savedVariables.customMonitor6.Show == true) then
    PXInfoPanelAddon:UpdateBagCounts(PXInfoPanelAddon.savedVariables.customMonitor6.SearchText)
  end
  if (PXInfoPanelAddon.savedVariables.customMonitor7.Show == true) then
    PXInfoPanelAddon:UpdateBagCounts(PXInfoPanelAddon.savedVariables.customMonitor7.SearchText)
  end
  if (PXInfoPanelAddon.savedVariables.customMonitor8.Show == true) then
    PXInfoPanelAddon:UpdateBagCounts(PXInfoPanelAddon.savedVariables.customMonitor8.SearchText)
  end
  if (PXInfoPanelAddon.savedVariables.customMonitor9.Show == true) then
    PXInfoPanelAddon:UpdateBagCounts(PXInfoPanelAddon.savedVariables.customMonitor9.SearchText)
  end
  if (PXInfoPanelAddon.savedVariables.customMonitor10.Show == true) then
    PXInfoPanelAddon:UpdateBagCounts(PXInfoPanelAddon.savedVariables.customMonitor10.SearchText)
  end
end

function PXInfoPanelAddon:WriteLog(text)
  if PXInfoPanelAddon.savedVariables.fontScale ~= nil then
    PXInfoPanelAddonIndicatorLabel:SetScale(PXInfoPanelAddon.savedVariables.fontScale)
  end
  if PXInfoPanelAddon.savedVariables.fontColor ~= nil then
    PXInfoPanelAddonIndicatorLabel:SetColor(PXInfoPanelAddon.savedVariables.fontColor.r, PXInfoPanelAddon.savedVariables.fontColor.g, PXInfoPanelAddon.savedVariables.fontColor.b)
  end
  PXInfoPanelAddonIndicatorBG:SetAlpha(PXInfoPanelAddon.savedVariables.transparency)

  PXInfoPanelAddonIndicatorLabel:SetText(text)

  local x = PXInfoPanelAddonIndicatorLabel:GetWidth()
  local y = PXInfoPanelAddonIndicatorLabel:GetHeight()
  PXInfoPanelAddonIndicator:SetDimensions(x + 15, y + 15)
end

function PXInfoPanelAddon:SafeAssign(text)
  if (text == nil) then
    return ''
  end
  return text
end

function PXInfoPanelAddon:UpdateSurveyCount()
  local bagItemCount = GetBagSize(BAG_BACKPACK)
  local SurveyCountInZoneBefore = self.SurveyInfo.CountInZone
  self.SurveyInfo.CountInZone = 0
  self.SurveyInfo.StackCountInZone = 0
  
  for x = 1, bagItemCount do
    local itemLink = GetItemLink(BAG_BACKPACK, x)
    if (itemLink ~= nil and itemLink ~= '') then
      local itemType, specializedItemType = GetItemLinkItemType(itemLink)
      if (itemType == ITEMTYPE_TROPHY and specializedItemType == SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT) then 
        local itemName = (zo_strformat(GetItemName(BAG_BACKPACK, x)):match "^%s*(.-)%s*$")
        if (string.match(itemName, self.CurrentZone)) then
          local stackCountBackpack, stackCountBank, stackCountCraftBag = GetItemLinkStacks(itemLink)
          self.SurveyInfo.CountInZone = self.SurveyInfo.CountInZone + stackCountBackpack
          self.SurveyInfo.StackCountInZone = self.SurveyInfo.StackCountInZone + 1
        -- Exceptions to the rule here:
        elseif (self.CurrentZone == "Alik'r Desert" and string.match(itemName, "Alik'r")) then
          local stackCountBackpack, stackCountBank, stackCountCraftBag = GetItemLinkStacks(itemLink)
          self.SurveyInfo.CountInZone = self.SurveyInfo.CountInZone + stackCountBackpack
          self.SurveyInfo.StackCountInZone = self.SurveyInfo.StackCountInZone + 1
        end
      end
    end
  end
  self.SurveyInfo.CountInZoneDone = self.SurveyInfo.CountInZoneDone + (SurveyCountInZoneBefore - self.SurveyInfo.CountInZone)
  if (self.SurveyInfo.CountInZoneDone < 0) then
    self.SurveyInfo.CountInZoneDone = 0
  end
  if (self.SurveyInfo.CountInZone > 0) then
    self.SurveyInfo.TimeElapsed = PXInfoPanelAddon:GetZoneTimeElapsed()
    if self.SurveyInfo.TimeElapsed == 0 then
      self.SurveyInfo.TimeElapsed = 1
    end

    if (self.SurveyInfo.CountInZoneDone > 0) then
      local averageSurveyTimeInSeconds = self:Round(self.SurveyInfo.TimeElapsed / self.SurveyInfo.CountInZoneDone, 0)
      local surveyTimeLeftInSeconds = averageSurveyTimeInSeconds * self.SurveyInfo.CountInZone
      self.SurveyInfo.TimeLeftInZoneMinutes = self:Round(surveyTimeLeftInSeconds / 60, 0)
    end
  end
end
