TributesEnhancement = TributesEnhancement or {}

local ETE = TributesEnhancement

local Lib = LibExoYsUtilities

---------------
-- Turn Time --
---------------

local turnTimeGui = { initialized = false }

function ETE.InitializeTurnTimeGui()
  if turnTimeGui.initialized then return end
  turnTimeGui.name = ETE.name.."TurnTimeGui"

  local store = ETE.store.turnTime

  local win = ETE.WM:CreateTopLevelWindow( turnTimeGui.name.."Window" )
  win:ClearAnchors()
  win:SetAnchor( BOTTOMRIGHT, GuiRoot, TOPLEFT, store.position.x, store.position.y)
  win:SetHidden(true)
  win:SetHandler( "OnMoveStop", function()
    store.position.x = win:GetLeft() + win:GetWidth()
    store.position.y = win:GetTop() + win:GetHeight()
  end)
  win:SetMouseEnabled( false )
  win:SetMovable(true)


  local ctrl = ETE.WM:CreateControl( turnTimeGui.name.."Control", win, CT_CONTROL)
  ctrl:ClearAnchors()
  ctrl:SetAnchor( BOTTOMRIGHT, win, BOTTOMRIGHT, 0, 0)

  local label = ETE.WM:CreateControl( turnTimeGui.name.."Label", ctrl, CT_LABEL)
  label:ClearAnchors()
  label:SetAnchor(BOTTOMRIGHT, ctrl, BOTTOMRIGHT, 0, 0)
  label:SetColor(1,1,1,1)
  label:SetVerticalAlignment( TEXT_ALIGN_BOTTOM )
  label:SetHorizontalAlignment( TEXT_ALIGN_RIGHT )

  local function SetSize( size )
    store.size = size
    --label:SetFont( Lib.GetFont( size , "ProseAntique") )
    label:SetFont("EsoUI/Common/Fonts/ProseAntiquePSMT.otf|20|soft-shadow-thick" )
    local newWidth, newHeigth = label:GetDimensions()
    win:SetDimensions( newWidth, newHeigth )
    ctrl:SetDimensions( newWidth, newHeigth )
  end

  local function ChangeSize( task ) -- if task then up else down end
    local oldSize = store.size
    local newSize = task and oldSize + 5 or oldSize - 5
    if newSize < 12 then newSize = 12 end
    if newSize > 72 then newSize = 72 end
    SetSize( newSize )
  end
  SetSize( store.size )

  local buttons = ETE.WM:CreateControl( turnTimeGui.name.."Buttons", ctrl, CT_CONTROl)
  buttons:ClearAnchors()
  buttons:SetAnchor(BOTTOMLEFT, ctrl, BOTTOMRIGHT, 0, 0)
  buttons:SetHidden(true)

  local up = ETE.WM:CreateControl( turnTimeGui.name.."Up", buttons, CT_BUTTON)
  up:ClearAnchors()
  up:SetAnchor( BOTTOM, buttons, BOTTOMRIGHT, 20, -35 )
  up:SetDimensions( 30, 30 )
  up:SetHidden(true)
  local upTexture = "esoui/art/buttons/large_uparrow"
  up:SetNormalTexture( upTexture.."_up.dds" )
  up:SetMouseOverTexture( upTexture.."_over.dds" )
  up:SetPressedTexture( upTexture.."_down.dds")
  up:SetHandler( "OnClicked", function() ChangeSize(true) end)

  local down = ETE.WM:CreateControl( turnTimeGui.name.."Down", buttons, CT_BUTTON)
  down:ClearAnchors()
  down:SetAnchor( BOTTOM, buttons, BOTTOMRIGHT, 20, -20 )
  down:SetDimensions( 30, 30 )
  down:SetHidden(true)
  local downTexture = "esoui/art/buttons/large_downarrow"
  down:SetNormalTexture( downTexture.."_up.dds" )
  down:SetMouseOverTexture( downTexture.."_over.dds" )
  down:SetPressedTexture( downTexture.."_down.dds")
  down:SetHandler( "OnClicked", function() ChangeSize(false) end)

  local function ToggleSizeButtonVisibility( show )
    up:SetHidden( not show )
    down:SetHidden( not show )
  end

  turnTimeGui.locked = true
  local lock = ETE.WM:CreateControl( turnTimeGui.name.."Lock", buttons, CT_BUTTON)
  lock:ClearAnchors()
  lock:SetAnchor( BOTTOM, buttons, BOTTOMRIGHT, 25, 0 )
  lock:SetDimensions( 20, 20 )
  lock:SetHidden( not store.showLock )

  local function SetLockTexture(locked)
    local lockTexture = locked and  "esoui/art/miscellaneous/locked" or "esoui/art/miscellaneous/unlocked"
    lock:SetNormalTexture( lockTexture.."_up.dds" )
    lock:SetMouseOverTexture( lockTexture.."_over.dds" )
    lock:SetPressedTexture( lockTexture.."_down.dds")
  end

  lock:SetHandler( "OnClicked", function()
    ToggleSizeButtonVisibility( turnTimeGui.locked )
    turnTimeGui.locked = not turnTimeGui.locked
    win:SetMouseEnabled( not turnTimeGui.locked )
    SetLockTexture( turnTimeGui.locked )
  end )

  SetLockTexture( true )

  turnTimeGui.win = win
  turnTimeGui.label = label
  turnTimeGui.buttons = buttons

  turnTimeGui.initialized = true
end

function ETE.SetTurnTimeGuiOutput( output)
  turnTimeGui.label:SetText( output )
end


function ETE.SetTurnTimeGuiVisibility( show )
  --Lib.DebugMsg( ETE.store.dev, "ETE", {"SetTurnTimeGuiVisibility", tostring(show)}, {": "} )
  turnTimeGui.win:SetHidden( not show )

  -- show or hide buttons
  local showButtons = show
  if not ETE.store.turnTime.showLock then showButtons = false end
  turnTimeGui.buttons:SetHidden( not showButtons )
end

----------------
-- Match Data  --
----------------

function ETE.ApplyMatchDataDesign()
  local store = ETE.store.matchData
  local gui = ETE.matchDataGui
  gui.label:SetFont( Lib.GetFont( store.size, store.font) )
end


function ETE.CreateMatchDataGui()
  local guiName = ETE.name.."MatchDataGui"
  local store = ETE.store.matchData

  local win = ETE.WM:CreateTopLevelWindow( guiName.."Window" )
  win:ClearAnchors()
  win:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, store.position.x, store.position.y)
  win:SetMouseEnabled(false)
  win:SetMovable(true)
  win:SetHidden(true)
  win:SetDimensions(100,100)
  win:SetClampedToScreen(true)
  win:SetHandler( "OnMoveStop", function()
      store.position.x = win:GetLeft()
      store.position.y = win:GetTop()
    end )

  local ctrl = ETE.WM:CreateControl( guiName.."Control", win, CT_CONTROL )
  ctrl:ClearAnchors()
  ctrl:SetAnchor(TOPLEFT, win, TOPLEFT, 0, 0)

  local label = ETE.WM:CreateControl( guiName.."Label", ctrl, CT_LABEL )
  label:ClearAnchors()
  label:SetAnchor( TOPLEFT, ctrl, TOPLEFT, 0, 0 )
  label:SetColor(1,1,1,1)

  local whisper = ETE.WM:CreateControl( guiName.."whisper", ctrl, CT_BUTTON )
  whisper:ClearAnchors()
  whisper:SetAnchor( TOPRIGHT, ctrl, TOPLEFT, 0, 0 )
  whisper:SetDimensions( 30, 30 )
  whisper:SetNormalTexture("/esoui/art/chatwindow/chat_notification_up.dds")
  whisper:SetMouseOverTexture( "/esoui/art/chatwindow/chat_notification_over.dds" )
  whisper:SetPressedTexture("/esoui/art/chatwindow/chat_notification_glow.dds" )
  whisper:SetHandler( "OnClicked", function( )
      if GetTributeMatchType() == TRIBUTE_MATCH_TYPE_CLIENT then return end
      local opponentName, opponentType = GetTributePlayerInfo(TRIBUTE_PLAYER_PERSPECTIVE_OPPONENT)
      if not opponentType == TRIBUTE_PLAYER_TYPE_REMOTE_PLAYER then return end
      StartChatInput("", CHAT_CHANNEL_WHISPER, opponentName)
    end)

  return {win = win, ctrl = ctrl, label = label, whisper = whisper}
end


----------------
-- Statistics Old --
----------------

local function GetHorizontalPosition( position )
  return position*100
end

local function CreateLabel(name, parent, offsetX, offsetY)
  local label = ETE.WM:CreateControl( name, parent, CT_LABEL )
  label:ClearAnchors()
  label:SetAnchor( TOPLEFT, ctrl, TOPLEFT, offsetX or 0, offsetY or 0 )
  label:SetColor(1,1,1,1)
  label:SetFont( Lib.GetFont() )
  return label
end


local function AddEntry( charId ) --TODO naming
  local entry = {}
  local guiName = tostring(charId)

  entry.ctrl = ETE.WM:CreateControl( guiName.."Control", ETE.statsGui.win, CT_CONTROL )

  entry.name = CreateLabel(guiName.."name", entry.ctrl, -50)

  for position, matchType in ipairs( ETE.GetMatchTypeOrder() ) do
    entry[matchType] = CreateLabel( guiName..ETE.GetMatchTypeName(matchType), entry.ctrl, GetHorizontalPosition(position))
  end

  --entry[TRIBUTE_MATCH_TYPE_CASUAL] = CreateLabel("a", entry.ctrl, 50)
  --entry[TRIBUTE_MATCH_TYPE_CLIENT] = CreateLabel("b", entry.ctrl, 100)
  --entry[TRIBUTE_MATCH_TYPE_COMPETITIVE] = CreateLabel("c", entry.ctrl, 150)
  --entry[TRIBUTE_MATCH_TYPE_PRIVATE] = CreateLabel("d", entry.ctrl, 200)

  return entry
end


function ETE.UpdateStatsGui()
  local store = ETE.store.statistics
  local counter = 0
  for charId, charStats in pairs( store.character ) do
    local gui = ETE.statsGui[charId] or AddEntry(charId)
    gui.name:SetText( charStats.name )
    for matchType, data in pairs( charStats.games ) do
      gui[matchType]:SetText( zo_strformat("<<1>>/<<2>>", data.won, data.played) )
    end
    gui.ctrl:ClearAnchors()
    gui.ctrl:SetAnchor(TOPLEFT, ETE.statsGui.win, TOPLEFT, 0, counter*30)

    counter = counter + 1
  end
end


function ETE.CreateStatsGui() --TODO naming
  local guiName = ETE.name.."StatsGui"
  --local store = ETE.store.turnTime

  local win = ETE.WM:CreateTopLevelWindow( guiName.."Window" )
  win:ClearAnchors()
  --win:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, store.position.x, store.position.y)
  win:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, 600, 600)
  win:SetMouseEnabled(false)
  win:SetMovable(true)
  win:SetHidden(true)
  win:SetDimensions(100,100)
  win:SetClampedToScreen(true)
  --win:SetHandler( "OnMoveStop", function()
  --    store.position.x = win:GetLeft()
  --    store.position.y = win:GetTop()
  --  end )


  local ctrl = ETE.WM:CreateControl( guiName.."Control", win, CT_CONTROL )
  ctrl:ClearAnchors()
  ctrl:SetAnchor(TOPLEFT, win, TOPLEFT, 0, 0)

  for position, matchType in ipairs( ETE.GetMatchTypeOrder() ) do
      local label = CreateLabel(guiName..tostring(position), ctrl, GetHorizontalPosition(position), -50)
      label:SetText( ETE.GetMatchTypeName(matchType) )
  end


  return {win = win, ctrl = ctrl}
end


----------------
-- Statistics --
----------------

local StatsGui = {name = "TestGui".."StatisticsGui", visible = false, initialized = false, } --TODO name

local function OpenStatsWindow()
  ETE.UpdateStatsGui()
  --HUD_UI_SCENE:AddFragment( StatsGui.frag )
  --HUD_SCENE:AddFragment( StatsGui.frag )
  StatsGui.win:SetHidden(false)

end

local function CloseStatsWindow()
  StatsGui.win:SetHidden(true)
  --HUD_UI_SCENE:RemoveFragment( StatsGui.frag )
  --HUD_SCENE:RemoveFragment( StatsGui.frag )
end

function ETE.ToggleStatsWindow()
  if StatsGui.visible then
    CloseStatsWindow()
  else
    OpenStatsWindow()
  end
  StatsGui.visible = not StatsGui.visible
end

local labelList = {
  ["num"] = 50,
  ["perc"] = 75,
  ["average"] = 125,
  ["time"] = 150}

function ETE.UpdateStatsGui()
  if not ETE.store.statistics.character[ETE.player.charId] then return end
  for position, matchType in ipairs( ETE.GetMatchTypeOrder() ) do
    local store = ETE.store.statistics.character[ETE.player.charId].games[matchType]
    local labels = StatsGui.charOverview[matchType]

    local numLoss = store.played - store.won

    labels["num"]:SetText( zo_strformat("W: <<1>> / L: <<2>>", store.won, numLoss) )

    if store.played == 0 then
      labels["perc"]:SetText( "Win Rate Time: -" )
      labels["average"]:SetText( "Average Time: -" )
      labels["time"]:SetText( "Total Time: -" )
    else
      labels["perc"]:SetText( zo_strformat("Win rate: <<1>>%", store.won/store.played*100))
      labels["average"]:SetText( zo_strformat("Average Time: <<1>>", Lib.GetFormattedDuration(store.time/store.played, "compact") ) )
      labels["time"]:SetText( zo_strformat("Total Time: <<1>>", Lib.GetFormattedDuration(store.time, "acronym") ) )
    end
  end

end

function ETE.InitializeStatsGui()
  if StatsGui.initialized then return end

  local win = ETE.WM:CreateTopLevelWindow( StatsGui.name.."Window")
  win:ClearAnchors()
  win:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, 400, 400)
  win:SetHidden(true)
  StatsGui.win = win

  --local frag = ZO_HUDFadeSceneFragment:New( win )
  --StatsGui.frag = frag

  local ctrl = ETE.WM:CreateControl( StatsGui.name.."Control", win, CT_CONTROL)
  ctrl:ClearAnchors()
  ctrl:SetAnchor(TOPLEFT, win, TOPLEFT, 0, 0)
  StatsGui.ctrl = ctrl

  local back = ETE.WM:CreateControl( StatsGui.name.."Back", ctrl, CT_BACKDROP)
  back:ClearAnchors()
  back:SetAnchor( TOPLEFT, ctrl, TOPLEFT, 0, 0)
  back:SetDimensions( 830, 230)
  back:SetCenterColor( 0, 0, 0, 0.8)
  back:SetEdgeTexture(nil, 2,2,2)
  back:SetEdgeColor( 0, 0, 0, 1)

  StatsGui.back = back

  --local header = ETE.WM:CreateControl( StatsGui.name.."Header", ctrl, CT_LABEL)
  local header = CreateLabel( StatsGui.name.."Header", ctrl, 20, -30)
  header:SetText( "TributesEnhancement - Character Statistics")
  StatsGui.header = header


  -- Character Stats --
  local guiName = StatsGui.name.."CharacterOverview"

  local function CreateMatchTypeInfo( parent, matchType, position)
    local name = guiName..ETE.GetMatchTypeName(matchType)

    --local store = ETE.store.statistics.character[ETE.player.charId]

    --local function CreateLabel(name, parent, offsetX, offsetY)

    local labels = {}
    labels["matchType"] = CreateLabel( name.."matchType", parent, (position-1)*200+20, 20)
    labels["matchType"]:SetText( ETE.GetMatchTypeName(matchType) )
    for labelName, offset in pairs(labelList) do
      labels[labelName] = CreateLabel( name..labelName, parent, (position-1)*200+20, offset+40)
    end
    return labels
  end

  StatsGui.charOverview = {}

  for position, matchType in ipairs( ETE.GetMatchTypeOrder() ) do
    StatsGui.charOverview[matchType] = CreateMatchTypeInfo(ctrl, matchType, position)
  end


    -- ChatCommand
  SLASH_COMMANDS["/tributes_stats"] = ETE.ToggleStatsWindow

  StatsGui.button = false

  -- Icon in Tribute ActivityFinder
  ZO_PostHook(ZO_ActivityFinderTemplate_Shared, "OnTributeClubDataInitialized", function(self)
    if StatsGui.button then return end
    if not self then return end
    if not self.clubRankObject then return end
    if not self.clubRankObject.iconTexture then return end

    local parent = self.clubRankObject.iconTexture

    local icon = "esoui/art/mainmenu/menubar_journal"

    local width, height = parent:GetDimensions()

    local button = ETE.WM:CreateControl( "TestButton", parent, CT_BUTTON )
    button:ClearAnchors()
    button:SetAnchor(CENTER, parent, CENTER, -width, 0)
    button:SetDimensions( width, height )
    button:SetNormalTexture( icon.."_up.dds")
    button:SetMouseOverTexture( icon.."_over.dds" )
    button:SetHandler( "OnClicked", function( )
      ETE.ToggleStatsWindow()
    end)

    StatsGui.button = true --WARNING funktioniert nicht richtig, beim ersten login scheint der hook einmal ausgeführt zu werden
  end)

  StatsGui.initialized = true
end

---------------------
-- GuiManipulation --
---------------------





---------------------------
-- Vanilla Menu Addition --
---------------------------

--gameui/ava/avacapturebar
--battle ground has green
--gameui/companion/keyboard/companion_overview = gameui/guild/tabicon_roster

--gameui/death/ death-timer-base <<< complete circle

-- "esoui/art/mainmenu/menubar_journal"
-- SI_ACTIVITY_FINDER_CATEGORY_TRIBUTE
