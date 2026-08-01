local UI = {}
ITTsRosterBot.UI = UI

local validRowCount = 0
local selectedRankIndex = 1
local playerName = GetDisplayName()
local worldName = GetWorldName()
local LTF = LibTextFilter


local function calculateSidebarPerc( current, max )
  local perc = math.floor( ((100 / max) * current) + 0.5 )

  if max == current or perc > 100 then
    perc = 100
  end

  if max == 0 then
    perc = 0
  end

  local percLabelValue = perc

  if max > 0 and perc == 0 then
    percLabelValue = "< 1"
  end

  if current == 0 then
    percLabelValue = 0
  end

  return perc, percLabelValue
end

UI.selectedRankIndex = 4

function UI:isRanksSelected()
  local condition = false

  for i = 1, #ITTsRosterBot.selectedRanks do
    if ITTsRosterBot.selectedRanks[ i ] then
      condition = true
      break
    end
  end

  return condition
end

local function updateRankSelectionTotal()
  if ITTsRosterBot_Controls then
    local membersTotal = GetNumGuildMembers( GUILD_ROSTER_MANAGER.guildId )

    local perc, percLabel = calculateSidebarPerc( validRowCount, membersTotal )

    ITTsRosterBot_Controls:GetNamedChild( "SelectionValue" ):SetText( validRowCount )
    ITTsRosterBot_Controls:GetNamedChild( "SelectionTotal" ):SetText( membersTotal )
    ITTsRosterBot_Controls:GetNamedChild( "SelectionPerc" ):SetText( percLabel )

    UI.RankStatusBar:SetMinMax( 0, 100 )
    ZO_StatusBar_SmoothTransition( UI.RankStatusBar, perc, 100, false, nil, 800 )

    UI.salesTotalMaxValue = (ITTsRosterBot.SalesAdapter:GetGuildTotal( GUILD_ROSTER_MANAGER.guildId ) or 0)

    if not UI:isRanksSelected() and ZO_GuildRosterSearchBox:GetText() == "" then
      UI.salesTotalValue = UI.salesTotalMaxValue
    end

    local taxesTotal = math.floor( UI.salesTotalMaxValue * 0.035 )
    local selectedTaxesTotal = math.floor( UI.salesTotalValue * 0.035 )
    local incomeTotalValue = selectedTaxesTotal + (UI.donationsTotalValue or 0)
    local incomeTotalMaxValue = taxesTotal + (UI.donationsTotalMaxValue or 0)

    local salesPerc, salesPercLabel = calculateSidebarPerc( UI.salesTotalValue, UI.salesTotalMaxValue )
    local incomePerc, incomePercLabel = calculateSidebarPerc( incomeTotalValue, incomeTotalMaxValue )
    local taxesPerc, taxesPercLabel = calculateSidebarPerc( selectedTaxesTotal, incomeTotalValue )

    UI.salesTotal:GetNamedChild( "Value" ):SetText( ZO_LocalizeDecimalNumber( UI.salesTotalValue ) )
    UI.salesTotal:GetNamedChild( "StatusBar" ):SetMinMax( 0, 100 )
    UI.salesTotal:GetNamedChild( "Perc" ):SetText( salesPercLabel )
    ZO_StatusBar_SmoothTransition( UI.salesTotal:GetNamedChild( "StatusBar" ), salesPerc, 100, false, nil, 800 )

    if UI.saleMemberCount > 0 then
      UI.salesTotal:GetNamedChild( "ExtraInfo" ):SetText( "|c2feba0" ..
        tostring( UI.saleMemberCount ) .. " |cFFFFFF/|c00c0ff " .. tostring( validRowCount ) )
    else
      UI.salesTotal:GetNamedChild( "ExtraInfo" ):SetText( "" )
    end

    UI.incomeTotal:GetNamedChild( "Value" ):SetText( ZO_LocalizeDecimalNumber( incomeTotalValue ) )
    UI.incomeTotal:GetNamedChild( "StatusBar" ):SetMinMax( 0, 100 )
    UI.incomeTotal:GetNamedChild( "Perc" ):SetText( incomePercLabel )
    ZO_StatusBar_SmoothTransition( UI.incomeTotal:GetNamedChild( "StatusBar" ), incomePerc, 100, false, nil, 800 )

    UI.taxesTotal:GetNamedChild( "Value" ):SetText( ZO_LocalizeDecimalNumber( selectedTaxesTotal ) )
    UI.taxesTotal:GetNamedChild( "StatusBar" ):SetMinMax( 0, 100 )
    UI.taxesTotal:GetNamedChild( "Perc" ):SetText( taxesPercLabel )
    ZO_StatusBar_SmoothTransition( UI.taxesTotal:GetNamedChild( "StatusBar" ), taxesPerc, 100, false, nil, 800 )

    local donationsPerc, donationsPercLabel = calculateSidebarPerc( UI.donationsTotalValue, incomeTotalValue )

    UI.donationsTotal:GetNamedChild( "Value" ):SetText( ZO_LocalizeDecimalNumber( UI.donationsTotalValue ) )
    UI.donationsTotal:GetNamedChild( "StatusBar" ):SetMinMax( 0, 100 )
    UI.donationsTotal:GetNamedChild( "Perc" ):SetText( donationsPercLabel )

    ZO_StatusBar_SmoothTransition( UI.donationsTotal:GetNamedChild( "StatusBar" ), donationsPerc, 100, false, nil, 800 )

    if UI.donationMemberCount > 0 then
      UI.donationsTotal:GetNamedChild( "ExtraInfo" ):SetText(
        "|cebc22f" .. tostring( UI.donationMemberCount ) .. " |cFFFFFF/|c00c0ff " .. tostring( validRowCount )
      )
    else
      UI.donationsTotal:GetNamedChild( "ExtraInfo" ):SetText( "" )
    end
  end
end

local function applyOfflineTemplates( data, columnCheckSaleData )
  if not data.online and data.secsSinceLogoff > (7 * 86400) then
    local color = "|ca3a079"
    local activity = false

    local hasDonated = (type( data.ITT_Donations ) == "number" and data.ITT_Donations > 0)
    local hasColumnPurchases = (columnCheckSaleData and data.ITT_Purchases and data.ITT_Purchases > 0)

    if (
          (hasDonated or hasColumnPurchases) and
          ((UI.selectedRankIndex >= 1 and UI.selectedRankIndex <= 5) and data.secsSinceLogoff > (10 * 86400))) or
        (
          (hasDonated or hasColumnPurchases) and
          ((UI.selectedRankIndex >= 4 and UI.selectedRankIndex <= 7) and data.secsSinceLogoff > (14 * 86400))) or
        ((hasDonated or hasColumnPurchases) and (UI.selectedRankIndex == 8 and data.secsSinceLogoff > (10 * 86400))) or
        ((hasDonated or hasColumnPurchases) and (UI.selectedRankIndex == 9 and data.secsSinceLogoff > (14 * 86400))) or
        (
          (hasDonated or hasColumnPurchases) and
          ((UI.selectedRankIndex == 10 or UI.selectedRankIndex == 11) and data.secsSinceLogoff > (30 * 86400))) or
        (data.secsSinceLogoff > (30 * 86400) and (columnCheckSaleData and data.ITT_Sales and data.ITT_Sales > 0))
    then
      activity = true
    end

    if (data.secsSinceLogoff > (30 * 86400) and (columnCheckSaleData and data.ITT_Sales and data.ITT_Sales > 0)) then
      activity = true
    end

    if data.secsSinceLogoff > (30 * 86400) then
      color = "|ca6543d"
    elseif data.secsSinceLogoff > (14 * 86400) then
      color = "|ca69f3d"
    end

    if activity then
      data.formattedZone = ZO_FormatDurationAgo( data.secsSinceLogoff ) .. "|cc96c53 (Offline-mode sus)"
    else
      -- data.displayName = color .. data.displayName
      data.formattedZone = color .. ZO_FormatDurationAgo( data.secsSinceLogoff )
    end
  elseif not data.online then
    data.formattedZone = ZO_FormatDurationAgo( data.secsSinceLogoff )
  end

  return data
end

local function applySalesTemplates( data, columnCheckSaleData )
  if ITTsRosterBot.db.settings.services.sales == "None" then
    return data
  end

  local sales = 0
  local purchases = 0

  if columnCheckSaleData and data[ ITTsRosterBot.SalesAdapter:Selected().salesColumnKey ] then
    purchases = data[ ITTsRosterBot.SalesAdapter:Selected().purchasesColumnKey ]
  end

  if columnCheckSaleData and data[ ITTsRosterBot.SalesAdapter:Selected().salesColumnKey ] and UI.salesTotal then
    sales = tonumber( data[ ITTsRosterBot.SalesAdapter:Selected().salesColumnKey ] )
  else
    local start, finish = ITTsDonationBot.reportQueries[ UI.selectedRankIndex ].range()
    local userInformation = ITTsRosterBot.SalesAdapter:GetSaleInformation( GUILD_ROSTER_MANAGER.guildId, data.displayName,
      start, finish )

    sales = userInformation.sales
    purchases = userInformation.purchases
  end

  if sales then
    UI.salesTotalValue = UI.salesTotalValue + sales

    if sales > 0 then
      UI.saleMemberCount = UI.saleMemberCount + 1
    end
  end

  data.ITT_Sales = sales
  data.ITT_Purchases = purchases

  return data
end

local function applyDonationTemplates( data, trackDonations )
  if trackDonations and UI.donationsTotal then
    local donation = tonumber( data.ITT_Donations )
    UI.donationsTotalValue = UI.donationsTotalValue + donation

    if donation > 0 then
      UI.donationMemberCount = UI.donationMemberCount + 1
    end
  end

  return data
end

local function rosterFilterScrollList( self )
  local scrollData = ZO_ScrollList_GetDataList( self.list )
  ZO_ClearNumericallyIndexedTable( scrollData )

  validRowCount = 0

  local searchTerm = self.searchBox:GetText()
  local hideOffline = GetSetting_Bool( SETTING_TYPE_UI, UI_SETTING_SOCIAL_LIST_HIDE_OFFLINE )
  local masterList = GUILD_ROSTER_MANAGER:GetMasterList()
  local isRanksSelected = UI:isRanksSelected()

  if isRanksSelected then
    UI.rankCloseButton:SetHidden( false )
  else
    UI.rankCloseButton:SetHidden( true )
  end

  UI.salesTotalValue = 0
  UI.saleMemberCount = 0

  UI.donationsTotalValue = 0
  UI.donationsTotalMaxValue = 0
  UI.donationMemberCount = 0

  local trackDonations = false

  if ITTsDonationBot and ITTsDonationBot:IsGuildEnabled( GUILD_ROSTER_MANAGER.guildId ) then
    trackDonations = true
  end

  local columnCheckSaleData = ITTsRosterBot.SalesAdapter:IsColumnCheckingEnabled()

  for i = 1, #masterList do
    local data = masterList[ i ]
    -- logger:Info(data)
    if trackDonations and UI.donationsTotal then
      UI.donationsTotalMaxValue = UI.donationsTotalValue + tonumber( data.ITT_Donations )
    end

    local searchString = data.displayName ..
        "\n" .. data.note .. "\n" .. data.formattedZone .. "\n" .. data.formattedAllianceName
    if searchTerm == "" or LTF:Filter( string.lower( searchString ), string.lower( searchTerm ) ) or
        GUILD_ROSTER_MANAGER:IsMatch( searchTerm, data ) then
      if not hideOffline or data.online or data.rankId == DEFAULT_INVITED_RANK then
        if isRanksSelected then
          for i = 1, #ITTsRosterBot.selectedRanks do
            if ITTsRosterBot.selectedRanks[ i ] and (data.rankIndex and i == data.rankIndex) then
              table.insert( scrollData, ZO_ScrollList_CreateDataEntry( 1, data ) )
              validRowCount = validRowCount + 1

              data = applySalesTemplates( data, columnCheckSaleData )

              data = applyDonationTemplates( data, trackDonations )

              data = applyOfflineTemplates( data, columnCheckSaleData )
            end
          end
        else
          -- data = applyJoinTemplates(data)
          --           data = applyJoinTemplates(self, control, data, last)
          --
          table.insert( scrollData, ZO_ScrollList_CreateDataEntry( 1, data ) )
          validRowCount = validRowCount + 1

          data = applySalesTemplates( data, columnCheckSaleData )

          data = applyDonationTemplates( data, trackDonations )

          data = applyOfflineTemplates( data, columnCheckSaleData )
        end
      end
    end
  end

  updateRankSelectionTotal()
end

local function createSidebarTotal( settings )
  local control = CreateControlFromVirtual( settings.name, ITTsRosterBot_Controls, "ITTsRosterBot_SidebarTotal" )
  control:GetNamedChild( "Title" ):SetText( "|t20:20:EsoUI/Art/Guild/guild_tradingHouseAccess.dds|t " .. settings.title )
  control:GetNamedChild( "Value" ):SetText( ZO_LocalizeDecimalNumber( settings.value ) )
  control:GetNamedChild( "Value" ):SetColor( ZO_ColorDef:New( settings.color ):UnpackRGBA() )
  control:GetNamedChild( "StatusBar" ):SetColor( ZO_ColorDef:New( settings.color ):UnpackRGBA() )
  control:GetNamedChild( "StatusBar" ):SetMinMax( 0, 100 )
  control:GetNamedChild( "StatusBar" ):SetValue( settings.perc )
  control:GetNamedChild( "Perc" ):SetText( settings.perc )
  control:GetNamedChild( "Perc" ):SetColor( ZO_ColorDef:New( settings.color ):UnpackRGBA() )
  control:GetNamedChild( "PercSymbol" ):SetColor( ZO_ColorDef:New( settings.color ):UnpackRGBA() )

  if settings.small then
    control:SetDimensions( 132, 40 )
    control:GetNamedChild( "Value" ):SetFont( "$(BOLD_FONT)|$(KB_26)|soft-shadow-thin" )
    control:GetNamedChild( "StatusBackdrop" ):SetDimensions( 132, 2 )
    control:GetNamedChild( "StatusBar" ):SetDimensions( 132, 2 )

    control:GetNamedChild( "Perc" ):ClearAnchors()
    control:GetNamedChild( "Perc" ):SetAnchor( TOPLEFT, control:GetNamedChild( "Value" ), BOTTOMLEFT, 0, -2 )
    control:GetNamedChild( "Perc" ):SetFont( "$(BOLD_FONT)|17|shadow" )

    control:GetNamedChild( "ExtraInfo" ):ClearAnchors()
    control:GetNamedChild( "ExtraInfo" ):SetAnchor( BOTTOMRIGHT, control, BOTTOMRIGHT, 0, 20 )

    control:GetNamedChild( "PercSymbol" ):ClearAnchors()
    control:GetNamedChild( "PercSymbol" ):SetAnchor( TOPLEFT, control:GetNamedChild( "Perc" ), TOPRIGHT, 3, 1 )
    control:GetNamedChild( "PercSymbol" ):SetFont( "$(BOLD_FONT)|14|shadow" )
  end

  control:ClearAnchors()

  return control
end

local function createRankSelectTiles()
  UI.rankTiles = {}
  ITTsRosterBot.selectedRanks = {}

  local testBg = CreateControlFromVirtual( "ITTsRosterBot_Controls", ZO_GuildRoster, "ITTsRosterBot_RosterBG" )

  for i = 1, 10 do
    local rankFilter = CreateControlFromVirtual( "ITTsRosterBot_ControlsAreaRankFilter" .. i, ITTsRosterBot_Controls,
      "ITTsRosterBot_RankFilter" )
    rankFilter:GetNamedChild( "_BG" ):SetEdgeColor( ZO_ColorDef:New( 0, 0, 0, 0 ):UnpackRGBA() )
    -- rankFilter:GetNamedChild('_Icon'):SetTexture(GetGuildRankSmallIcon(iconIndex))
    rankFilter:SetHidden( true )
    rankFilter:SetMouseEnabled( true )

    if i == 1 then
      rankFilter:SetAnchor( TOPLEFT, ITTsRosterBot_ControlsArea, TOPLEFT, 0, 0 )
    elseif i == 6 then
      rankFilter:SetAnchor( TOPLEFT, ITTsRosterBot_ControlsArea:GetNamedChild( "RankFilter1" ), BOTTOMLEFT, 0, 2 )
    else
      rankFilter:SetAnchor( LEFT, ITTsRosterBot_ControlsArea:GetNamedChild( "RankFilter" .. tostring( i - 1 ) ), RIGHT, 2, 0 )
    end

    rankFilter:GetNamedChild( "_Button" )._activeIndex = i
    ITTsRosterBot.selectedRanks[ i ] = false
    table.insert( UI.rankTiles, rankFilter )

    UI.rankTiles[ i ]:GetNamedChild( "_Button" ):SetHandler(
      "OnMouseEnter",
      function( control )
        InitializeTooltip( InformationTooltip )
        InformationTooltip:ClearAnchors()
        InformationTooltip:SetOwner( control, BOTTOM, 0, 0 )
        if ITTsRosterBot.guildRanks[ control._activeIndex ] then
          InformationTooltip:AddLine( ITTsRosterBot.guildRanks[ control._activeIndex ].name, "",
            ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB() )
        end

        if not ITTsRosterBot.selectedRanks[ control._activeIndex ] then
          UI.rankTiles[ i ]:GetNamedChild( "_BG" ):SetCenterColor( ZO_ColorDef:New( "6d6d6d" ):UnpackRGBA() )
        end
      end
    )

    UI.rankTiles[ i ]:GetNamedChild( "_Button" ):SetHandler(
      "OnClicked",
      function( control )
        ITTsRosterBot.selectedRanks[ control._activeIndex ] = not ITTsRosterBot.selectedRanks[ control._activeIndex ]

        if ITTsRosterBot.selectedRanks[ control._activeIndex ] then
          UI.rankTiles[ i ]:GetNamedChild( "_BG" ):SetCenterColor( ZO_ColorDef:New( "00c0ff" ):UnpackRGBA() )
        else
          UI.rankTiles[ i ]:GetNamedChild( "_BG" ):SetCenterColor( ZO_ColorDef:New( "6d6d6d" ):UnpackRGBA() )
        end

        GUILD_ROSTER_MANAGER:RefreshData()
      end
    )

    UI.rankTiles[ i ]:GetNamedChild( "_Button" ):SetHandler(
      "OnMouseExit",
      function( control )
        ClearTooltip( InformationTooltip )

        if not ITTsRosterBot.selectedRanks[ control._activeIndex ] then
          UI.rankTiles[ i ]:GetNamedChild( "_BG" ):SetCenterColor( ZO_ColorDef:New( "383838" ):UnpackRGBA() )
        end
      end
    )
  end

  local statusBarBG = ITTsRosterBot_Controls:GetNamedChild( "RankStatusBackdrop" )
  statusBarBG:ClearAnchors()
  statusBarBG:SetAnchor( TOPLEFT, UI.rankTiles[ 6 ], BOTTOMLEFT, 0, 10 )

  UI.RankStatusBar = ITTsRosterBot_Controls:GetNamedChild( "RankStatusBar" )
  UI.RankStatusBar:SetMinMax( 0, 400 )
  UI.RankStatusBar:SetValue( 280 )

  UI.rankCloseButton = ITTsRosterBot_Controls:GetNamedChild( "Close" )
  UI.rankCloseButton:ClearAnchors()
  UI.rankCloseButton:SetAnchor( BOTTOMRIGHT, UI.rankTiles[ 5 ], TOPRIGHT, 0, -10 )

  UI.rankCloseButton:SetHandler(
    "OnClicked",
    function( control )
      for i = 1, 10 do
        ITTsRosterBot.selectedRanks[ i ] = false
        UI.rankTiles[ i ]:GetNamedChild( "_BG" ):SetCenterColor( ZO_ColorDef:New( "383838" ):UnpackRGBA() )
      end

      GUILD_ROSTER_MANAGER:RefreshData()
    end
  )

  UI.donationsTotal =
      createSidebarTotal(
        {
          name = "ITTsRosterBot_DonationsTotal",
          color = "ebc22f",
          title = "DONATIONS",
          value = 1043812,
          perc = 58,
          small = true
        }
      )

  UI.donationsTotal:SetAnchor( BOTTOMRIGHT, ITTsRosterBot_ControlsArea, BOTTOMRIGHT, 0, 25 )

  UI.taxesTotal =
      createSidebarTotal(
        {
          name = "ITTsRosterBot_TaxesTotal",
          color = "eb2f96",
          title = "TAXES",
          value = 43119,
          perc = 28,
          small = true
        }
      )

  UI.taxesTotal:SetAnchor( TOPRIGHT, UI.donationsTotal, TOPLEFT, -5, 0 )

  UI.incomeTotal =
      createSidebarTotal(
        {
          name = "ITTsRosterBot_IncomeTotal",
          color = "eb802f",
          title = "INCOME",
          value = 43119,
          perc = 28
        }
      )

  UI.incomeTotal:SetAnchor( BOTTOMRIGHT, UI.donationsTotal, TOPRIGHT, 0, -50 )

  UI.salesTotal =
      createSidebarTotal(
        {
          name = "ITTsRosterBot_SalesTotal",
          color = "2feba0",
          title = "SALES",
          value = 1443119,
          perc = 78
        }
      )

  UI.salesTotal:SetAnchor( BOTTOMLEFT, UI.incomeTotal, TOPLEFT, 0, -40 )

  if ITTsRosterBot.db.settings.services.sales ~= "None" then
    ITTsRosterBot_SalesTotalTitle:SetText(
      "|t20:20:EsoUI/Art/Guild/guild_tradingHouseAccess.dds|t SALES   |c66ffc2[ " ..
      ITTsRosterBot.db.settings.services.sales .. " ]"
    )
  end
end

function UI.renderRankTiles()
  local guildId = GUILD_ROSTER_MANAGER.guildId
  local guildRanksTotal = 0
  ITTsRosterBot.guildRanks = {}

  -- ITTsRosterBot.SalesAdapter:RefreshAllGuildTotals()

  for i = 1, GetNumGuildRanks( guildId ) do
    ITTsRosterBot.guildRanks[ i ] = { name = GetFinalGuildRankName( guildId, i ), index = i }
    guildRanksTotal = guildRanksTotal + 1
  end

  for i = 1, 10 do
    UI.rankTiles[ i ]:SetHidden( true )
    ITTsRosterBot.selectedRanks[ i ] = false
    UI.rankTiles[ i ]:GetNamedChild( "_BG" ):SetCenterColor( ZO_ColorDef:New( "383838" ):UnpackRGBA() )
  end

  UI.rankCloseButton:SetHidden( true )

  for i = 1, guildRanksTotal do
    local iconIndex = GetGuildRankIconIndex( guildId, ITTsRosterBot.guildRanks[ i ].index )
    UI.rankTiles[ i ]:GetNamedChild( "_Icon" ):SetTexture( GetGuildRankSmallIcon( iconIndex ) )
    UI.rankTiles[ i ]:SetHidden( false )
  end

  local anchorIndex = 6

  if guildRanksTotal < 6 then
    anchorIndex = 1
  end

  ITTsRosterBot_Controls:GetNamedChild( "RankStatusBackdrop" ):SetAnchor( TOPLEFT, UI.rankTiles[ anchorIndex ], BOTTOMLEFT, 0,
    10 )

  UI.salesTotalMaxValue = 0
  UI.incomeTotalMaxValue = 0
  UI.donationsTotalMaxValue = 0

  UI:CheckServiceStatus()
end

local function toggleServiceStatus( control, condition )
  if condition then
    control:GetNamedChild( "Title" ):SetAlpha( 1 )
    control:GetNamedChild( "Value" ):SetAlpha( 1 )
    control:GetNamedChild( "Perc" ):SetAlpha( 1 )
    control:GetNamedChild( "PercSymbol" ):SetAlpha( 1 )
  else
    control:GetNamedChild( "Title" ):SetAlpha( 0.6 )
    control:GetNamedChild( "Value" ):SetAlpha( 0.4 )
    control:GetNamedChild( "Perc" ):SetAlpha( 0.4 )
    control:GetNamedChild( "PercSymbol" ):SetAlpha( 0.4 )
  end
end

function UI:CheckServiceStatus()
  local hasDonationsEnabled = false
  local hasSalesEnabled = false
  local guildId = GUILD_ROSTER_MANAGER.guildId

  if ITTsDonationBot and ITTsDonationBot:IsGuildEnabled( guildId ) then
    toggleServiceStatus( UI.donationsTotal, true )
    hasDonationsEnabled = true
  else
    toggleServiceStatus( UI.donationsTotal, false )
  end

  if ITTsRosterBot.db.settings.services.sales == "None" then
    toggleServiceStatus( UI.salesTotal, false )
    toggleServiceStatus( UI.taxesTotal, false )
  else
    toggleServiceStatus( UI.salesTotal, true )
    toggleServiceStatus( UI.taxesTotal, true )
    hasSalesEnabled = true
  end

  if hasDonationsEnabled or hasSalesEnabled then
    toggleServiceStatus( UI.incomeTotal, true )
    ITTsRosterBot_ControlsTimeRangeDropdown:SetHidden( false )
    ITTsRosterBot_ControlsTimeRangeTitle:SetHidden( false )
  else
    toggleServiceStatus( UI.incomeTotal, false )
    ITTsRosterBot_ControlsTimeRangeDropdown:SetHidden( true )
    ITTsRosterBot_ControlsTimeRangeTitle:SetHidden( true )
  end
end

local function renderDropdown( timeRangeOptions )
  if not UI.timeRangeDropdown then
    UI.timeRangeDropdown = ZO_ComboBox_ObjectFromContainer( ITTsRosterBot_ControlsTimeRangeDropdown )
    UI.timeRangeDropdown:SetSelectedItemFont( "ZoFontHeader2" )
    UI.timeRangeDropdown:SetDropdownFont( "ZoFontHeader" )
    UI.timeRangeDropdown:SetSpacing( 8 )
  else
    UI.timeRangeDropdown:ClearItems()
  end

  ITTsRosterBot.SalesAdapter:DisplayUI( false )

  local function callback()
    UI.selectedRankIndex = UI.timeRangeDropdown:GetSelectedItemData().index
    ITTsRosterBot.db.timeFrameIndex = UI.selectedRankIndex

    -- if ITTsRosterBot.db.settings.services.sales then

    -- end

    if ITTsRosterBot.SalesAdapter:IsColumnCheckingEnabled() then
      ITTsRosterBot.SalesAdapter:SelectColumnTimeRange( UI.selectedRankIndex )
    else
      local start, finish = ITTsDonationBot.reportQueries[ UI.selectedRankIndex ].range()
      ITTsRosterBot.SalesAdapter:RefreshAllGuildTotals( start, finish )
    end

    if ITTsDonationBot and ITTsDonationBot.Roster and ITTsDonationBot.Roster.queryReportMode then
      if ITTsRosterBot.db.settings.services.sales ~= "None" and ITTsRosterBot.SalesAdapter:Selected().DonationMapOptions and
          #ITTsRosterBot.SalesAdapter:Selected().DonationMapOptions > 0
      then
        ITTsDonationBot.Roster.queryReportMode:SelectItemByIndex( ITTsRosterBot.SalesAdapter:Selected().DonationMapOptions[
        UI.selectedRankIndex ] )
      else
        ITTsDonationBot.Roster.queryReportMode:SelectItemByIndex( UI.selectedRankIndex )
      end
    else
      LibGuildRoster:Refresh()
    end
  end

  UI.timeRangeDropdown:SetSortsItems( false )

  for i = 1, #timeRangeOptions do
    UI.timeRangeDropdown:AddItem(
      {
        index = i,
        name = timeRangeOptions[ i ],
        callback = callback
      }
    )
  end

  if ITTsRosterBot.db.timeFrameIndex > #timeRangeOptions then
    ITTsRosterBot.db.timeFrameIndex = #timeRangeOptions
  end

  UI.timeRangeDropdown:SelectItemByIndex( ITTsRosterBot.db.timeFrameIndex )
end

-- local cachedHistoryFilterScrollList
local cachedRosterFilterScrollList

local function applyNativeCallbacks()
  GUILD_ROSTER_KEYBOARD.FilterScrollList = cachedRosterFilterScrollList
end

local function applyModifiedCallbacks()
  GUILD_ROSTER_KEYBOARD.FilterScrollList = rosterFilterScrollList
end

local function toggleServicesUI( display, service )
  if display then
    -- ZO_GuildRosterSearchBoxText:SetText(UI.originalSearchBoxPlaceholder)
    applyNativeCallbacks()

    ITTsRosterBot_Controls:SetHidden( true )

    if service then
      ITTsRosterBot.SalesAdapter:DisplayUI( true )
    end

    if ZO_GuildRoster_PP_BG then
      zo_callLater(
        function()
          if SCENE_MANAGER.currentScene.name == "guildRoster" then
            ZO_GuildRoster_PP_BG:ClearAnchors()
            ZO_GuildRoster_PP_BG:SetAnchor( TOPLEFT, ZO_GuildRoster, TOPLEFT, -10, -10 )
            ZO_GuildRoster_PP_BG:SetAnchor( BOTTOMRIGHT, ZO_GuildRoster, BOTTOMRIGHT, 0, 10 )
            ZO_GuildRoster_PP_BG:SetWidth( ZO_SharedRightBackgroundLeft:GetWidth() - 240 )
          end
        end,
        0
      )
    end
  else
    -- ZO_GuildRosterSearchBoxText:SetText("names, notes or @user")
    applyModifiedCallbacks()

    zo_callLater(
      function()
        if SCENE_MANAGER.currentScene.name == "guildRoster" then
          if ZO_GuildRoster_PP_BG then
            ZO_GuildRoster_PP_BG:ClearAnchors()
            ZO_GuildRoster_PP_BG:SetAnchor( TOPRIGHT, ZO_GuildRoster, TOPRIGHT, -10, -10 )
            ZO_GuildRoster_PP_BG:SetAnchor( BOTTOMRIGHT, ZO_GuildRoster, BOTTOMRIGHT, 0, 10 )
            ZO_GuildRoster_PP_BG:SetWidth( ZO_SharedRightBackgroundLeft:GetWidth() + 240 )
          else
            ZO_SharedRightBackgroundLeft:SetWidth( ZO_SharedRightBackgroundLeft:GetWidth() + 300 )
          end
        end

        ITTsRosterBot_Controls:SetHidden( false )
      end,
      0
    )

    if service then
      ITTsRosterBot.SalesAdapter:DisplayUI( false )
    end
  end

  UI:CheckServiceStatus()
end
function UI:ConfigureDropdown()
  local timeRangeOptions = ITTsRosterBot.SalesAdapter:GetTimeRangeOptions()

  if not timeRangeOptions then
    timeRangeOptions = {
      "Today",
      "Yesterday",
      "Two days ago",
      "This Week",
      "Last Week",
      "Prior Week",
      "Last 7 Days",
      "Last 10 Days",
      "Last 14 Days",
      "Last 30 Days",
      "Total"
    }
  end

  renderDropdown( timeRangeOptions )
end

function UI:Setup()
  -- renderHistorySearch()
  ITTsRosterBot.Mail:Setup()

  createRankSelectTiles()

  zo_callLater(
    function()
      UI:ConfigureDropdown()
    end,
    3800
  )

  -- cachedHistoryFilterScrollList = GUILD_HISTORY.FilterScrollList
  cachedRosterFilterScrollList = GUILD_ROSTER_KEYBOARD.FilterScrollList
  GUILD_ROSTER_KEYBOARD.FilterScrollList = rosterFilterScrollList
  -- GUILD_HISTORY.FilterScrollList = GuildHistoryManagerFilterScrollList

  ITTsRosterBot.SalesAdapter:RefreshAllGuildTotals()

  --[[  UI.originalSearchBoxPlaceholder = ZO_GuildRosterSearchBoxText:GetText()
  ZO_GuildRosterSearchBoxText:SetText("names, notes or @user") ]]
  SCENE_MANAGER.scenes.guildRoster:RegisterCallback(
    "StateChange",
    function( oldState, newState )
      if (newState == "showing" or newState == "shown") and ITTsRosterBot:IsGuildEnabled( GUILD_ROSTER_MANAGER.guildId ) then
        toggleServicesUI( false, true )
      else
        toggleServicesUI( true )
      end
    end
  )

  UI.currentGuildId = GUILD_SELECTOR.guildId

  ZO_PreHook(
    GUILD_ROSTER_MANAGER,
    "OnGuildIdChanged",
    function()
      if GUILD_SELECTOR.guildId ~= UI.currentGuildId then
        UI.renderRankTiles()
        UI.currentGuildId = GUILD_SELECTOR.guildId
      end

      if SCENE_MANAGER.currentScene and SCENE_MANAGER.currentScene.name == "guildRoster" and
          ITTsRosterBot:IsGuildEnabled( GUILD_ROSTER_MANAGER.guildId )
      then
        toggleServicesUI( false, true )
      else
        toggleServicesUI( true, true )
      end
    end
  )

  if SCENE_MANAGER.currentScene and ITTsRosterBot:IsGuildEnabled( GUILD_ROSTER_MANAGER.guildId ) then
    UI.renderRankTiles()
    toggleServicesUI( false, true )
  else
    toggleServicesUI( true, true )
  end
end
