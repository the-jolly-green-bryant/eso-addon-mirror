-- Libraries

local LAM2 = LibAddonMenu2
local chat = LibChatMessage( "Alliance Buddy", "AB" )

AllianceBuddy = {}

AllianceBuddy.Default = {
  OffsetX = 50,
  OffsetY = 0,
  LegacyOffsetX = 0,
  LegacyOffsetY = 0,
  Show = true,
  StatusBarColor1 = { 0, 1, 0, 1 },
  StatusBarColor2 = { 0, 1, 1, 1 },
  AllianceColors = true,
  ColorSettings = false,
  ShowGOBar = false,
  LegacyUI = false,
  UISettings = "Standart"
}

-------------------------------------------------------------------------------------------------
--  Initialize Variables --
-------------------------------------------------------------------------------------------------
AllianceBuddy.name = "AllianceBuddy"
AllianceBuddy.version = 3.2
AllianceBuddy.variableVersion = 3

----------------------
-- Constant Values
----------------------

local ADYellow = ZO_ColorDef:New( GetInterfaceColor( INTERFACE_COLOR_TYPE_ALLIANCE, ALLIANCE_ALDMERI_DOMINION ) )
local APColor = ZO_ColorDef:New( GetInterfaceColor( INTERFACE_COLOR_TYPE_PROGRESSION, PROGRESSION_COLOR_AVA_RANK_END ) )
local EPRed = ZO_ColorDef:New( GetInterfaceColor( INTERFACE_COLOR_TYPE_ALLIANCE, ALLIANCE_EBONHEART_PACT ) )
local DCBlue = ZO_ColorDef:New( GetInterfaceColor( INTERFACE_COLOR_TYPE_ALLIANCE, ALLIANCE_DAGGERFALL_COVENANT ) )
local Alliance = GetUnitAlliance( "player" )

local currentCampaign = {}
local Underpop = {}
local chat = chat:SetTagColor( "268074" )
local worldName = GetMapName()
local options = 1
local AD_GRADIENT_COLORS = { ADYellow, APColor }
local EP_GRADIENT_COLORS = { EPRed, APColor }
local DC_GRADIENT_COLORS = { DCBlue, APColor }
local CUSTOM_GRADIENT_COLORS = {}
local currentXP = GetUnitAvARankPoints( "player" )
local lastRankXP, nextRankXP = GetAvARankProgress( currentXP )
local gender = GetUnitGender( "player" )
-- gender is used for different languages

-----------------
--  OnAddOnLoaded
-----------------

function AllianceBuddy.OnAddOnLoaded( event, addonName )
  if addonName ~= AllianceBuddy.name then
    return
  end
  AllianceBuddy:Initialize()
end

------------------
-- Other Functions
------------------

-- Icon, Rankname and Ranklevel
function GetLazyText()
  local currentRank = GetUnitAvARank( "player" )
  local rankIcon = GetLargeAvARankIcon( currentRank )
  --[[   local nextRankIcon = GetLargeAvARankIcon(currentRank + 1)
  local nextLevel = currentRank + 1 ]]
  AllianceBuddyUIRankIconDisplay:SetTexture( rankIcon )
  ZO_HoldAllianceIconDisplay:SetTexture( rankIcon )
  -- NewBuddyUIRankIconDisplay:SetTexture(rankIcon)
  -- AllianceBuddyUInextRankIconDisplay:SetTexture(nextRankIcon)

  AllianceBuddyUIAllianceLevelDisplay:SetText( currentRank )
  -- AllianceBuddyUINextAllianceLevelDisplay:SetText(nextLevel)
  -- AllianceBuddyUIAllianceLevelDisplayBG:SetText(currentRank)
  -- AllianceBuddyUINextAllianceLevelDisplayBG:SetText(nextLevel)
  ZO_HoldAllianceLevelDisplay:SetText( currentRank )
  local rankTitle = GetAvARankName( gender, currentRank )
  AllianceBuddyUIAllianceRankDisplay:SetText( rankTitle:gsub( "Grade 1", "I" ):gsub( "Grade 2", "II" ) )
  ZO_HoldAllianceRankDisplay:SetText( rankTitle:gsub( "Grade 1", "I" ):gsub( "Grade 2", "II" ) )
end

function GetUnderdogBonuses()
  local currentCampaign = GetCurrentCampaignId()
  local Underpop = IsUnderpopBonusEnabled( currentCampaign, Alliance )

  AllianceBuddyUILowPop:SetHidden( not Underpop )
end

function UnderdogYelling()
  local currentCampaign = GetCurrentCampaignId()
  local Underpop = IsUnderpopBonusEnabled( currentCampaign, Alliance )

  if Underpop == true then
    ScreenAnnouncementBig( "Underdog Bonus |c2efe2eactivated|r", SOUNDS.AVA_GATE_OPENED )
    chat:Print( "Underdog bonus |c2efe2eactive." )
  else
    ScreenAnnouncementMedium( "Aww, there goes our Underdog Bonus... \n\nIt was fun while it lasted" )
    chat:Print( "Underdog bonus |cff0000inactive" )
  end
  GetUnderdogBonuses()
end

EVENT_MANAGER:RegisterForEvent( AllianceBuddy.name, EVENT_CAMPAIGN_UNDERPOP_BONUS_CHANGE_NOTIFICATION, UnderdogYelling )

-----------------------
---Screen Announcements
-----------------------
function ScreenAnnouncementBig( memo, sound )
  local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams( CSA_CATEGORY_LARGE_TEXT, SOUNDS.JUSTICE_NO_LONGER_KOS )
  params:SetCSAType( CENTER_SCREEN_ANNOUNCE_TYPE_POI_DISCOVERED )
  params:SetSound( sound )
  params:SetText( memo )
  CENTER_SCREEN_ANNOUNCE:AddMessageWithParams( params )
end

function ScreenAnnouncementMedium( memo )
  local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams( CSA_CATEGORY_SMALL_TEXT, SOUNDS.NONE )
  params:SetCSAType( CENTER_SCREEN_ANNOUNCE_TYPE_POI_DISCOVERED )
  params:SetText( memo )
  CENTER_SCREEN_ANNOUNCE:AddMessageWithParams( params )
end

function DisableColorSettings()
  return AllianceBuddy.savedVariables.AllianceColors
end

local function GetAllianceFlag()
  if (Alliance == 1) then
    AllianceBuddyUIAllianceFlag:SetTexture( "esoui/art/stats/alliancebadge_aldmeri.dds" )
    ZO_HoldAllianceFlag:SetTexture( "esoui/art/guild/banner_aldmeri.dds" )
    -- NewBuddyUIAllianceFlag:SetTexture("esoui/art/stats/alliancebadge_aldmeri.dds")
  end
  if (Alliance == 2) then
    AllianceBuddyUIAllianceFlag:SetTexture( "esoui/art/stats/alliancebadge_ebonheart.dds" )
    ZO_HoldAllianceFlag:SetTexture( "esoui/art/guild/banner_ebonheart.dds" )
  end
  if (Alliance == 3) then
    AllianceBuddyUIAllianceFlag:SetTexture( "esoui/art/stats/alliancebadge_daggerfall.dds" )
    ZO_HoldAllianceFlag:SetTexture( "esoui/art/guild/banner_daggerfall.dds" )
  end
end

function AllianceBuddy.GetStatus( eventCode )
  local currentXP = GetUnitAvARankPoints( "player" )
  local lastRankXP, nextRankXP = GetAvARankProgress( currentXP )
  local type1 = ZO_CommaDelimitNumber( currentXP - lastRankXP )
  local type2 = ZO_CommaDelimitNumber( nextRankXP - lastRankXP )
  local type3 = ZO_CommaDelimitNumber( math.floor( (currentXP - lastRankXP) / (nextRankXP - lastRankXP) * 100 ) )
  local type4 = ZO_CommaDelimitNumber( currentXP )
  local value = (currentXP - lastRankXP) / (nextRankXP - lastRankXP) * 100

  AllianceBuddyUIStatusBar:SetMinMax( 0, 100 )
  AllianceBuddyUIStatusBarGloss:SetMinMax( 0, 100 )
  ZO_HoldStatusBar:SetMinMax( 0, 100 )
  ZO_HoldStatusBarGloss:SetMinMax( 0, 100 )
  if currentXP > 64680000 then
    AllianceBuddyUIStatusBar:SetValue( 100 )
    AllianceBuddyUIStatusBarGloss:SetValue( 100 )
    ZO_HoldStatusBar:SetValue( 100 )
    ZO_HoldStatusBarGloss:SetValue( 100 )
    AllianceBuddyUIAlliancePointsDisplay:SetText( type4 .. " / " .. type4 .. " (100%)" )
  else
    AllianceBuddyUIStatusBar:SetValue( value )
    AllianceBuddyUIStatusBarGloss:SetValue( value )
    ZO_HoldStatusBar:SetValue( value )
    -- NewBuddyUIStatusBar:SetValue(value)
    -- NewBuddyUITelVarFill:StartFixedCooldown(value / 100, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING, NO_LEADING_EDGE)
    ZO_HoldStatusBarGloss:SetValue( value )
    AllianceBuddyUIAlliancePointsDisplay:SetText( type1 .. " / " .. type2 .. " (" .. type3 .. "%) " )
    -- NewBuddyUIAlliancePointsDisplay:SetText(type1 .. " / " .. type2 .. " (" .. type3 .. "%) ")
    ZO_HoldAlliancePointsDisplay:SetText( type1 .. " / " .. type2 .. " (" .. type3 .. "%) " )
    AllianceBuddyUIGOStatusBar:SetValue( currentXP / 64680000 * 100 )
    ZO_HoldGOStatusBar:SetValue( currentXP / 64680000 * 100 )
  end
  GetLazyText()
end

EVENT_MANAGER:RegisterForEvent( AllianceBuddy.name, EVENT_RANK_POINT_UPDATE, AllianceBuddy.GetStatus )

function SetLegacyBuddy()
  if AllianceBuddy.savedVariables.LegacyUI == true then
    AllianceBuddyUI:SetHidden( true )
    ZO_AllianceBuddyUI:SetHidden( false )
  else
    AllianceBuddyUI:SetHidden( false )
    ZO_AllianceBuddyUI:SetHidden( true )
  end
end

local function SetColorSettings()
  local CustomGradient1 = ZO_ColorDef:New( unpack( AllianceBuddy.savedVariables.StatusBarColor1 ) )
  local CustomGradient2 = ZO_ColorDef:New( unpack( AllianceBuddy.savedVariables.StatusBarColor2 ) )
  local CUSTOM_GRADIENT_COLORS = { CustomGradient1, CustomGradient2 }

  if AllianceBuddy.savedVariables.AllianceColors == false then
    ZO_StatusBar_SetGradientColor( AllianceBuddyUIStatusBar, CUSTOM_GRADIENT_COLORS )
    ZO_StatusBar_SetGradientColor( ZO_HoldStatusBar, CUSTOM_GRADIENT_COLORS )
  elseif Alliance == 1 then
    -- ZO_StatusBar_SetGradientColor(NewBuddyUIStatusBar, AD_GRADIENT_COLORS)
    -- NewBuddyUIFrameBG2:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_ALLIANCE, ALLIANCE_ALDMERI_DOMINION))
    --[[ NewBuddyUITelVarFill:SetFillColor(
      GetInterfaceColor(INTERFACE_COLOR_TYPE_PROGRESSION, PROGRESSION_COLOR_AVA_RANK_END)
    ) ]]
    ZO_StatusBar_SetGradientColor( AllianceBuddyUIStatusBar, AD_GRADIENT_COLORS )
    ZO_StatusBar_SetGradientColor( ZO_HoldStatusBar, AD_GRADIENT_COLORS )
  elseif Alliance == 2 then
    -- NewBuddyUIFrameBG2:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_ALLIANCE, ALLIANCE_EBONHEART_PACT))
    ZO_StatusBar_SetGradientColor( AllianceBuddyUIStatusBar, EP_GRADIENT_COLORS )
    ZO_StatusBar_SetGradientColor( ZO_HoldStatusBar, EP_GRADIENT_COLORS )
  elseif Alliance == 3 then
    ZO_StatusBar_SetGradientColor( AllianceBuddyUIStatusBar, DC_GRADIENT_COLORS )
    ZO_StatusBar_SetGradientColor( ZO_HoldStatusBar, DC_GRADIENT_COLORS )
    -- NewBuddyUIFrameBG2:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_ALLIANCE, ALLIANCE_DAGGERFALL_COVENANT))
  end
  -- NewBuddyUITelVarFill:SetFillColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_PROGRESSION, PROGRESSION_COLOR_AVA_RANK_END))
end

function AllianceBuddy.SaveLocation()
  AllianceBuddy.savedVariables.OffsetX = AllianceBuddyUI:GetLeft()
  AllianceBuddy.savedVariables.OffsetY = AllianceBuddyUI:GetTop()
end

function AllianceBuddy.SaveLegacyLocation()
  AllianceBuddy.savedVariables.LegacyOffsetX = ZO_Hold:GetLeft()
  AllianceBuddy.savedVariables.LegacyOffsetY = ZO_Hold:GetTop()
end

---------------
-- SettingsMenu
---------------

function AllianceBuddy.CreateSettingsWindow()
  local panelData = {
    type = "panel",
    name = "Alliance Buddy",
    displayName = "Alliance Buddy..",
    author = "JN_Slevin",
    version = AllianceBuddy.version,
    slashCommand = "/absettings",
    registerForRefresh = true,
    registerForDefaults = true
  }
  LAM2:RegisterAddonPanel( "Alliance_Buddy", panelData )

  local optionsData = {
    [ 1 ] = {
      type = "header",
      name = "Alliance Buddy Settings"
    },
    [ 2 ] = {
      type = "description",
      text = "Here you can adjust how Alliance Buddy behaves."
    },
    [ 3 ] = {
      type = "texture",
      image = "/esoui/art/miscellaneous/gamepad/horizontaldivider.dds",
      imageWidth = 510, --max of 250 for half width, 510 for full
      imageHeight = 5   --max of 100
    },
    [ 4 ] = {
      type = "checkbox",
      name = "Show Alliance Buddy",
      tooltip = "When ON Alliance Buddy will be visible. When OFF Alliance Buddy will be hidden",
      default = "true",
      getFunc = function()
        return AllianceBuddy.savedVariables.Show
      end,
      setFunc = function( newValue )
        AllianceBuddy.savedVariables.Show = newValue
        AllianceBuddyUI:SetHidden( not newValue )
        ZO_Hold:SetHidden( not newValue )
        if newValue == true then
          SetLegacyBuddy()
        else
          return false
        end
      end
    },
    [ 5 ] = {
      type = "checkbox",
      name = "Show Statusbar for the road to Grand Overlord",
      tooltip = "When ON Alliance Buddy will inject another Statusbar, which shows the progress from 0 to Grand Overlord",
      default = "false",
      getFunc = function()
        return AllianceBuddy.savedVariables.ShowGOBar
      end,
      setFunc = function( newValue )
        AllianceBuddy.savedVariables.ShowGOBar = newValue
        AllianceBuddyUIGOStatusBar:SetHidden( not newValue )
        ZO_HoldGOStatusBar:SetHidden( not newValue )
      end
    },
    [ 6 ] = {
      type = "checkbox",
      name = "Use Legacy UI",
      tooltip = "When ON Alliance Buddy will change into its legacy version, created by |cffffffMinceraft|r",
      default = "true",
      getFunc = function()
        return AllianceBuddy.savedVariables.LegacyUI
      end,
      setFunc = function( newValue )
        AllianceBuddy.savedVariables.LegacyUI = newValue
        SetLegacyBuddy( newValue )
        SetColorSettings()
      end
    },
    [ 7 ] = {
      type = "submenu",
      name = "Status Bar Colors",
      tooltip = "Allows you to change the bar colors.",
      controls = {
        [ 1 ] = {
          type = "checkbox",
          name = "Use Alliance Colors",
          tooltip =
          "When ON the Statusbar will use your alliance color and the AP Color for its gradient. When OFF Alliance Buddy will use the values down below to create a custom gradient",
          default = "true",
          getFunc = function()
            return AllianceBuddy.savedVariables.AllianceColors
          end,
          setFunc = function( newValue )
            AllianceBuddy.savedVariables.AllianceColors = newValue
            SetColorSettings()
          end
        },
        [ 2 ] = {
          type = "colorpicker",
          name = "Bar Color 1",
          disabled = DisableColorSettings,
          tooltip = "Changes the color of Alliance Buddy's background",
          getFunc = function()
            return unpack( AllianceBuddy.savedVariables.StatusBarColor1 )
          end,
          setFunc = function( r, g, b, a )
            AllianceBuddy.savedVariables.StatusBarColor1 = { r, g, b, a }
            SetColorSettings()
          end,
          width = "half"
        },
        [ 3 ] = {
          type = "colorpicker",
          name = "Bar Color 2",
          disabled = DisableColorSettings,
          tooltip = "Changes the color of Alliance Buddy's background",
          getFunc = function()
            return unpack( AllianceBuddy.savedVariables.StatusBarColor2 )
          end,
          setFunc = function( r, g, b, a )
            AllianceBuddy.savedVariables.StatusBarColor2 = { r, g, b, a }
            SetColorSettings()
          end,
          width = "half"
        }
      }
    },
    [ 8 ] = {
      type = "submenu",
      name = "Changelog |c268074AllianceBuddy|r 3.0",
      tooltip = "Changes on AllianceBuddy",
      controls = {
        [ 1 ] = {
          type = "description",
          text = AllianceBuddy.Changelog
        },
        [ 2 ] = {
          type = "submenu",
          name = "Changelog before the current Version",
          --tooltip = "Allows you to change the bar colors.",
          controls = {
            [ 1 ] = {
              type = "description",
              text = AllianceBuddy.ChangelogOld
            }
          }
        }
      }
    }
  }
  LAM2:RegisterOptionControls( "Alliance_Buddy", optionsData )
end

-------------
-- Activation
-------------
local function OnPlayerActivated()
  GetUnderdogBonuses()
end
-------------------------------------------------------------------------------------------------
--  Initialize Function --
-------------------------------------------------------------------------------------------------
function AllianceBuddy.Initialize()
  AllianceBuddy.savedVariables =
      ZO_SavedVars:NewCharacterIdSettings(
        "AllianceBuddy_Vars",
        AllianceBuddy.variableVersion,
        nil,
        AllianceBuddy.Default,
        GetWorldName()
      )

  AllianceBuddy.CreateSettingsWindow()
  AllianceBuddyUI:SetHidden( not AllianceBuddy.savedVariables.Show )
  -- AllianceBuddy.SetBarSize(AllianceBuddy.savedVariables.BarWidth, AllianceBuddy.savedVariables.BarHeight)
  -- AllianceBuddyUIStatusBar:SetColor(unpack(AllianceBuddy.savedVariables.StatusBarColor))
  GetAllianceFlag()
  GetLazyText()
  AllianceBuddy.GetStatus()
  OnPlayerActivated()
  SetColorSettings()
  SetLegacyBuddy()

  -- HideInPVP()
  AllianceBuddyUI:ClearAnchors()
  AllianceBuddyUI:SetAnchor(
    TOPLEFT,
    GuiRoot,
    TOPLEFT,
    AllianceBuddy.savedVariables.OffsetX,
    AllianceBuddy.savedVariables.OffsetY
  )
  ZO_AllianceBuddyUI:ClearAnchors()
  ZO_AllianceBuddyUI:SetAnchor(
    TOPLEFT,
    GuiRoot,
    TOPLEFT,
    AllianceBuddy.savedVariables.LegacyOffsetX,
    AllianceBuddy.savedVariables.LegacyOffsetY
  )

  EVENT_MANAGER:UnregisterForEvent( AllianceBuddy.name, EVENT_ADD_ON_LOADED )
end

-------------------
--  Register Events
-------------------
EVENT_MANAGER:RegisterForEvent( AllianceBuddy.name, EVENT_ADD_ON_LOADED, AllianceBuddy.OnAddOnLoaded )
EVENT_MANAGER:RegisterForEvent( AllianceBuddy.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated )
