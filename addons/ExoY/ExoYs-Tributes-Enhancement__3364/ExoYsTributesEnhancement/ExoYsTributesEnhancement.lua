TributesEnhancement = TributesEnhancement or {}

local ETE = TributesEnhancement

local Lib = LibExoYsUtilities

--[[
Sound:
music still audible
"Effects volume" is cards played, patron selected and used, currency gained etc
"Interface Volume" sound for concede, end of the game screen etc
TODO
-- igno removes friend list

IsFriend(string charOrDisplayName)

AddIgnore(@)
RemoveIgnore(@)
SetSessionIgnore(string userName, boolean isIgnoredThisSession)
ClearSessionIgnores()
GetIgnoredInfo(number index) -> Returns: string displayName, string note
GetNumIgnored()
IsIgnored(string charOrDisplayName)
SetIgnoreNote(number ignoreIndex, string note)

KEYBOARD_CHAT_SYSTEM:Maximize()
else
KEYBOARD_CHAT_SYSTEM:Minimize()
*GAMEPAD_CHAT...

+ positioning not correct (example jessi's bildschirm)
+ aktuell keine Zeitbeschränkung gegen Freund und NPC's...?!
+ erster Zug
+ etwas mehr als 90 sek (einmal 94 und einmal 96)
+ dauer, wie lange das spiel schon geht

* GetNumPatronsFavoringPlayerPerspective(*[TributePlayerPerspective|#TributePlayerPerspective]* _playerPerspective_)
** _Returns:_ *integer* _numPatronsFavored_

* GetTributePatronIdAtIndex(*luaindex* _index_)
** _Returns:_ *integer* _patronId_

* GetTributePatronNumStarterCards(*integer* _patronId_)
** _Returns:_ *integer* _numStarterCards_

* GetTributePatronNumDockCards(*integer* _patronId_)
** _Returns:_ *integer* _numStarterCards_

-- GetTributePlayerClubRank()
* EVENT_TRIBUTE_CLUB_RANK_CHANGED (*[TributeClubRank|#TributeClubRank]* _newClubRank_)

* EVENT_TRIBUTE_LEADERBOARD_DATA_RECEIVED (*[TributeLeaderboardType|#TributeLeaderboardType]* _leaderboardType_)

h5. TributeClubRank
* TRIBUTE_CLUB_RANK_ADEPT
* TRIBUTE_CLUB_RANK_EXPERT
* TRIBUTE_CLUB_RANK_INITIATE
* TRIBUTE_CLUB_RANK_MASTER
* TRIBUTE_CLUB_RANK_NOVICE
* TRIBUTE_CLUB_RANK_REGULAR
* TRIBUTE_CLUB_RANK_TRAINEE
* TRIBUTE_CLUB_RANK_VETERAN

* GetTributeLeaderboardRankInfo()
** _Returns:_ *integer* _playerLeaderboardRank_, *integer* _totalLeaderboardSize_

* GetTributeLeaderboardsSchedule()
** _Returns:_ *integer* _secondsUntilEnd_, *integer* _secondsUntilNextStart_

-- GetActiveTributePlayerPerspective() 1 during opponent turn,
-- GeTributeRemainingTimeForTurn()

* GetTributePatronSuitIcon(*integer* _patronId_)
** _Returns:_ *textureName* _suitIcon_

* GetTributePatronSmallIcon(*integer* _patronId_)
** _Returns:_ *textureName* _smallIcon_

* GetTributePatronLargeIcon(*integer* _patronId_)
** _Returns:_ *textureName* _largeIcon_

* GetTributePatronLargeRingIcon(*integer* _patronId_)
** _Returns:_ *textureName* _largeRingIcon_

/script d(GetTributeForfeitPenaltyDurationMs())
* GetTributeForfeitPenaltyDurationMs()
** _Returns:_ *integer* _forfeitPenaltyMs_

* GetTotalClubMatchesPlayed()
** _Returns:_ *integer* _totalMatchesPlayed_

* GetCurrentClubMatchStreak()
** _Returns:_ *integer* _currentStreak_

* GetTotalCampaignMatchesPlayed(*integer:nilable* _campaignId_)
** _Returns:_ *integer* _totalMatchesPlayed_

* GetCurrentCampaignMatchStreak(*integer:nilable* _campaignId_)
** _Returns:_ *integer* _currentStreak_

* IsPlacedInCampaign(*integer:nilable* _campaignId_)
** _Returns:_ *bool* _isPlaced_

* RequestActiveTributeCampaignData()
** _Returns:_ *[TributePlayerInitializationState|#TributePlayerInitializationState]* _state_


--- Leaderboard

LEADERBOARD_LIST_MANAGER:GetMasterList()



]]

----------------
-- References --
----------------
--[[
h5. TributePlayerPerspective
* TRIBUTE_PLAYER_PERSPECTIVE_SELF      -- 0
* TRIBUTE_PLAYER_PERSPECTIVE_OPPONENT  -- 1

h5. TributePlayerType
* TRIBUTE_PLAYER_TYPE_BASE              -- 0
* TRIBUTE_PLAYER_TYPE_NPC               -- 2
* TRIBUTE_PLAYER_TYPE_PLAYER            -- 1
* TRIBUTE_PLAYER_TYPE_REMOTE_PLAYER     -- 2

h5. TributeVictoryType
* TRIBUTE_VICTORY_TYPE_CONCESSION       -- 3
* TRIBUTE_VICTORY_TYPE_EARLY_CONCESSION -- 5
* TRIBUTE_VICTORY_TYPE_NONE             -- 0
* TRIBUTE_VICTORY_TYPE_PATRON           -- 2
* TRIBUTE_VICTORY_TYPE_PRESTIGE         -- 1
* TRIBUTE_VICTORY_TYPE_SYSTEM_DISBAND   -- 4

h5. TributeGameFlowState
* TRIBUTE_GAME_FLOW_STATE_BOARD_SETUP   -- 3
* TRIBUTE_GAME_FLOW_STATE_GAME_OVER     -- 5
* TRIBUTE_GAME_FLOW_STATE_INACTIVE      -- 0
* TRIBUTE_GAME_FLOW_STATE_INTRO         -- 1
* TRIBUTE_GAME_FLOW_STATE_PATRON_DRAFT  -- 2
* TRIBUTE_GAME_FLOW_STATE_PLAYING       -- 4
]]



---------------
-- variables --
---------------

ETE.name = "ExoYsTributesEnhancement"
ETE.EM = GetEventManager()
ETE.WM = GetWindowManager()

---------------------
-- local variables --
---------------------

local OUTCOME_UNKOWN = 0
local OUTCOME_VICTORY = 1
local OUTCOME_DEFEAT = 2
local OUTCOME_OMITTED = 3

local FLOW_STATE = 0
local MATCH_PENDING = false

local IGNORE_NOTE = "TributesEnhancement Temporary Ignore"

--------------------
-- loockup tables --
--------------------

local matchTypeOrder = {
    TRIBUTE_MATCH_TYPE_CLIENT,          -- 3
    TRIBUTE_MATCH_TYPE_PRIVATE,         -- 2
    TRIBUTE_MATCH_TYPE_CASUAL,          -- 4
    TRIBUTE_MATCH_TYPE_COMPETITIVE      -- 1
}

function ETE.GetMatchTypeOrder()
  return matchTypeOrder
end

local matchTypeName = {
  [TRIBUTE_MATCH_TYPE_CASUAL] = ETE_MATCH_TYPE_CASUAL,       -- 4
  [TRIBUTE_MATCH_TYPE_CLIENT] = ETE_MATCH_TYPE_CLIENT,          -- 3
  [TRIBUTE_MATCH_TYPE_COMPETITIVE] = ETE_MATCH_TYPE_COMPETITIVE,  -- 1
  [TRIBUTE_MATCH_TYPE_PRIVATE] = ETE_MATCH_TYPE_PRIVATE,    -- 2
}

function ETE.GetMatchTypeName( matchType )
  return matchTypeName[matchType]
end

local outcomeDesignation = {
  [OUTCOME_VICTORY] = ETE_OUTCOME_VICTORY,
  [OUTCOME_DEFEAT] = ETE_OUTCOME_DEFEAT,
}

function ETE.GetOutcomeDesignation( outcome )
  return outcomeDesignation[outcome]
end

--

local FEATURES = { update = {} }

local function RegisterUpdate(id, callback, interval )
  if not interval then interval = 100 end
  ETE.EM:RegisterForUpdate(ETE.name.."Update"..id, interval, callback)
  FEATURES.update[id] = true
end
------------------------
-- Match Data Manager --
------------------------

local matchData = {}

local function InitializeMatchData()
--[[ TODO
whisper:SetHandler( "OnClicked", function( )
    if GetTributeMatchType() == TRIBUTE_MATCH_TYPE_CLIENT then return end
    local opponentName, opponentType = GetTributePlayerInfo(TRIBUTE_PLAYER_PERSPECTIVE_OPPONENT)
    if not opponentType == TRIBUTE_PLAYER_TYPE_REMOTE_PLAYER then return end
    StartChatInput("", CHAT_CHANNEL_WHISPER, opponentName)
  end)
]]
  local function InitPlayerOpponentTable()
    return { [TRIBUTE_PLAYER_PERSPECTIVE_SELF] = 0, [TRIBUTE_PLAYER_PERSPECTIVE_OPPONENT] = 0, }
  end

  local opponentName, opponentType = GetTributePlayerInfo(TRIBUTE_PLAYER_PERSPECTIVE_OPPONENT)

  matchData = {
    matchType = GetTributeMatchType(),
    opponentName = opponentName,
    opponentType = opponentType,
    outcome = OUTCOME_UNKOWN,
    matchStart = GetGameTimeMilliseconds(),
    matchDuration = 0,
    turnStart = 0,
    turns = InitPlayerOpponentTable(),
    time = InitPlayerOpponentTable(),
    patrons = InitPlayerOpponentTable(),
    perspective = 0,
    }
end

local function IsMatchDataInitialized()
  return not ZO_IsTableEmpty(matchData)
end

local function ClearMatchData()
  matchData = {}
end

local function IsPlayerTurn()
  return matchData.perspective == TRIBUTE_PLAYER_PERSPECTIVE_SELF
end
----
--[[IsFriend(string charOrDisplayName)

AddIgnore(@)
RemoveIgnore(@)
SetSessionIgnore(string userName, boolean isIgnoredThisSession)
ClearSessionIgnores()
GetIgnoredInfo(number index) -> Returns: string displayName, string note
GetNumIgnored()
IsIgnored(string charOrDisplayName)
SetIgnoreNote(number ignoreIndex, string note)]]

----------------
-- Safe Space --
----------------

local SafeSpace = { }
local Automation = { }

--[[function SafeSpace.AddIgnore( displayName )
  -- TODO Menu Setting
  if IsFriend(displayName) then
    Lib.DebugMsg( ETE.store.debug, "TributesEnhancement", {displayName, " is friend"} )
    return
  end
  if IsIgnored(displayName) then
    Lib.DebugMsg( ETE.store.debug, "TributesEnhancement", {displayName, " is already igored"} )
    return end
  AddIgnore(displayName)
  Lib.DebugMsg( ETE.store.debug, "TributesEnhancement", {displayName, " added to ignore list"} )
  for i=1,GetNumIgnored()  do
    local name,_ = GetIgnoredInfo()
    if name == displayName then
      SetIgnoreNote(i, IGNORE_NOTE)
      Lib.DebugMsg( ETE.store.debug, "TributesEnhancement", {"Ignore note set for ", displayName} )
    end
  end
end

local function RemoveTemporaryIgnoreEntries( )
  local removeList = {}
  -- check everybody on ingame ignore list for a specific note and remember the names
  for i=1,GetNumIgnored() do
    local name, note = GetIgnoredInfo(i)
    if note == IGNORE_NOTE then
      table.insert(removeList, name)
    end
  end
  -- remove everybody from ingame ignore list identified by previous loop
  for _, name in pairs(removeList) do
    RemoveIgnore(name)
    Lib.DebugMsg( ETE.store.debug, "TributesEnhancement", {displayName, " removed from ignore  list"} )
  end

end]]

local defaultPlayerStatus = PLAYER_STATUS_ONLINE

local function CreateSafeEnvironment()
  if not IsMatchDataInitialized() then return end

  -- player Status
  local store = ETE.store.automation
  local matchType = matchData.matchType

  if store.changePlayerStatus[matchType].enabled then
    SelectPlayerStatus( store.changePlayerStatus[matchType].status )
    --Lib.DebugMsg( ETE.store.debug, "TributesEnhancement", {"Set Player Status", store.changePlayerStatus[matchType].status}, {" (", ")"} )
  end

  --

end


local function RevertSafeEnvironmentChanges()
  SelectPlayerStatus( defaultPlayerStatus )
  --Lib.DebugMsg( ETE.store.debug, "TributesEnhancement", {"Set Player Status", defaultPlayerStatus}, {" (", ")"} )
  --RemoveTemporaryIgnoreEntries( )
end

----

local function UpdateMatchDataGui()
  local currentTurnDuration = GetGameTimeMilliseconds() - matchData.turnStart
  local playerTime = matchData.time[TRIBUTE_PLAYER_PERSPECTIVE_SELF]
  local opponentTime = matchData.time[TRIBUTE_PLAYER_PERSPECTIVE_OPPONENT]

  if IsPlayerTurn() then
    playerTime = playerTime + currentTurnDuration
  else
    opponentTime = opponentTime + currentTurnDuration
  end

  local output = "Whisper Opponent \n"
  --output = output.."Total: "..Lib.GetFormattedDuration(currentTime - matchData.gameStartTime, "compact").."\n"
  output = output.."Player: "..Lib.GetFormattedDuration(playerTime, "compact", "minute").."\n"
  output = output.."Opponent: "..Lib.GetFormattedDuration(opponentTime, "compact", "minute").."\n"

  ETE.matchDataGui.label:SetText( output )
end

function ETE.OnUpdate()
  UpdateMatchDataGui()
end


local function VictoryDefeatStatsTableStructure()
  local tableStructure = {}
  for i = 1,4 do
    tableStructure[i] = {}
    for j = 1,6 do
      tableStructure[i][j-1] = 0
    end
  end
  return tableStructure
end

local function AddVictoryAndDefeatStatsTables() --compatibility with SV earlier than 1.2

end


local function CreateCharStatistics(charId)
  ETE.store.statistics.character[charId] = {
    name = GetUnitName("player"),
    server = GetWorldName(),
    games = {
      [TRIBUTE_MATCH_TYPE_CASUAL] = {time = 0, played = 0, won = 0},
      [TRIBUTE_MATCH_TYPE_CLIENT] = {time = 0, played = 0, won = 0},
      [TRIBUTE_MATCH_TYPE_COMPETITIVE] = {time = 0, played = 0, won = 0},
      [TRIBUTE_MATCH_TYPE_PRIVATE] = {time = 0, played = 0, won = 0},
    },
    victory = VictoryDefeatStatsTableStructure(),
    defeat = VictoryDefeatStatsTableStructure(),
  }
end

local function AddVictoryAndDefeatStatsTables(charId) --compatibility with SV earlier than 1.2
    ETE.store.statistics.character[charId].victory = VictoryDefeatStatsTableStructure()
    ETE.store.statistics.character[charId].defeat = VictoryDefeatStatsTableStructure()
end

local function PostMatchProcess( )

  -- check if it should be omitted

  local victoryPerspective, victoryType = GetTributeResultsWinnerInfo()
  local victory =  victoryPerspective == TRIBUTE_PLAYER_PERSPECTIVE_SELF

  matchData.outcome = victory and OUTCOME_VICTORY or OUTCOME_DEFEAT

  local charId = GetCurrentCharacterId()
  if not ETE.store.statistics.character[charId] then
    CreateCharStatistics(charId)
  end

  if not ETE.store.statistics.character[charId].victory then
    AddVictoryAndDefeatStatsTables(charId)
  end

  --Lib.DebugMsg( ETE.store.debug, "TributesEnhancement", {"PostProcess", "MatchType", ETE.GetMatchTypeName( matchData.matchType )}, {" - ", " (", ")"} )
  --Lib.DebugMsg( ETE.store.debug, "TributesEnhancement", {"PostProcess", "Outcome", ETE.GetOutcomeDesignation( matchData.outcome ) }, {" - ", " (", ")"} )

  -- record match data
  local store = ETE.store.statistics.character[charId]
  store.games[matchData.matchType].played = store.games[matchData.matchType].played + 1
  if victory then
    store.games[matchData.matchType].won = store.games[matchData.matchType].won + 1
  end
  store.games[matchData.matchType].time = store.games[matchData.matchType].time + matchData.matchDuration

  -- record victory/defeat type
  if victory then
    store.victory[matchData.matchType][victoryType] = store.victory[matchData.matchType][victoryType] + 1
  else
    store.defeat[matchData.matchType][victoryType] = store.victory[matchData.matchType][victoryType] + 1
  end

end


---------------------------
-- Turn Time Gui Handler --
---------------------------

local function DecideTurnTimeGuiVisibility( setValue )
  local show = true
  if not IsPlayerTurn() and ETE.store.turnTime.onlyForPlayer then show = false end

  local overwrite = type(setValue) == "boolean"
  if overwrite then show = setValue end
  --Lib.DebugMsg( ETE.store.dev, "ETE", {"DecideTurnTimeGuiVisibility", tostring(show), overwrite and " (overwrite)" or ""}, {": "} )
  ETE.SetTurnTimeGuiVisibility( show )
  FEATURES.turnTimeGuiVisible = show
end

local function OnUpdateTurnTimeGui()
  if not FEATURES.turnTimeGuiVisible then return end

  local timeRemaining = GetTributeRemainingTimeForTurn()
  local output = timeRemaining and Lib.GetCountdownString( timeRemaining, true, true ) or "∞"

  ETE.SetTurnTimeGuiOutput( output )
end


---------------------
-- Event Callbacks --
---------------------

--TODO WARNING Gamepad mode (GAMEPAD_CHAT)
local function MaximizeChat()
  KEYBOARD_CHAT_SYSTEM:Maximize()
end


local function MinimizeChat()
  KEYBOARD_CHAT_SYSTEM:Minimize()
end


local function OnGameFlowStateChange( _, flowState )
  FLOW_STATE = flowState
  if flowState == TRIBUTE_GAME_FLOW_STATE_INTRO then
    InitializeMatchData()
    defaultPlayerStatus = GetPlayerStatus()
    CreateSafeEnvironment()
  elseif flowState == TRIBUTE_GAME_FLOW_STATE_PLAYING then
    --if ETE.store.automation.maxChatAtGameStart then
    --  MaximizeChat()
    --end

    matchData.turnStart = GetGameTimeMilliseconds()
    matchData.perspective = GetActiveTributePlayerPerspective()

    ETE.EM:RegisterForUpdate(ETE.name.."Update", 100, ETE.OnUpdate)
    ETE.matchDataGui.win:SetHidden(false)

    if matchData.matchType == TRIBUTE_MATCH_TYPE_CASUAL or matchData.matchType == TRIBUTE_MATCH_TYPE_COMPETITIVE then
      if ETE.store.turnTime.enabled then
        DecideTurnTimeGuiVisibility()
        RegisterUpdate("TurnTime", OnUpdateTurnTimeGui )
      end
    end

  elseif flowState == TRIBUTE_GAME_FLOW_STATE_GAME_OVER then

    ETE.matchDataGui.win:SetHidden(true)
    ETE.EM:UnregisterForUpdate(ETE.name.."Update")

    matchData.matchDuration = GetGameTimeMilliseconds() - matchData.matchStart --TODO new or old?
    PostMatchProcess()

    DecideTurnTimeGuiVisibility(false)

    -- Unregister all Updates
    for update, _ in pairs( FEATURES.update) do
      ETE.EM:UnregisterForUpdate(ETE.name.."Update"..update)
    end
    FEATURES.update = {}

  elseif flowState == TRIBUTE_GAME_FLOW_STATE_INACTIVE then
    ClearMatchData()
    RevertSafeEnvironmentChanges()
  end
end


local function OnPlayerTurnStart(_, isPlayer)
  local currentTime = GetGameTimeMilliseconds()
  matchData.turns[matchData.perspective] = matchData.turns[matchData.perspective] + 1

  matchData.time[matchData.perspective] = matchData.time[matchData.perspective] + currentTime - matchData.turnStart

  matchData.patrons[TRIBUTE_PLAYER_PERSPECTIVE_SELF] = GetNumPatronsFavoringPlayerPerspective(TRIBUTE_PLAYER_PERSPECTIVE_SELF)
  matchData.patrons[TRIBUTE_PLAYER_PERSPECTIVE_OPPONENT] = GetNumPatronsFavoringPlayerPerspective(TRIBUTE_PLAYER_PERSPECTIVE_OPPONENT)

  matchData.perspective = isPlayer and TRIBUTE_PLAYER_PERSPECTIVE_SELF or TRIBUTE_PLAYER_PERSPECTIVE_OPPONENT
  matchData.turnStart = currentTime

  if FEATURES.update["TurnTime"] then
    DecideTurnTimeGuiVisibility()
  end

  -- chat automation
  --[[if isPlayer then
    if ETE.store.automation.minChatAtPlayerTurnStart then
      MinimizeChat()
    end
  else
    if ETE.store.automation.maxChatAtOpponentTurnStart then
      MaximizeChat()
    end
  end]]

  -- call for additional checks etc
  -- sound
end



local function LFG_ReadyCheck( lfgActivity )
    local tributeActivity = {
      [LFG_ACTIVITY_TRIBUTE_CASUAL] = ETE_MATCH_TYPE_CASUAL,
      [LFG_ACTIVITY_TRIBUTE_COMPETITIVE] = ETE_MATCH_TYPE_COMPETITIVE
    }

    if not tributeActivity[lfgActivity] then return end

    MATCH_PENDING = true

    --Lib.DebugMsg( ETE.store.debug, "TributesEnhancement", {"ToT Match found", tributeActivity[lfgActivity]}, {" (",")"} )

    if ETE.store.automation[lfgActivity] then
      --Lib.DebugMsg( ETE.store.debug, "TributesEnhancement", zo_strformat("Autoaccept in <<1>>s", ETE.store.automation["delay"]) )
      zo_callLater(function() AcceptLFGReadyCheckNotification() end, ETE.store.automation["delay"]*1000)
    end

    --  zo_removeCallLater( callbackId )
end

local function OnActivityFinderStatusUpdate(_, finderStatus)

  if finderStatus == ACTIVITY_FINDER_STATUS_NONE then
    MATCH_PENDING = false
  elseif finderStatus == ACTIVITY_FINDER_STATUS_READY_CHECK then
    if MATCH_PENDING then return end
    LFG_ReadyCheck( GetLFGReadyCheckActivityType() )
  end

end





----------------
-- Initialize --
----------------

--local functions for initialization
local function ValidateCharacterInfo(store, player)
  if not store[player.charId] then return end
  store[player.charId].name = player.charName

  if not store[player.charId].server then
      store[player.charId].server = GetWorldName()
  end
end


local function GetDefaults()
  local widthRoot, heightRoot = GuiRoot:GetDimensions()
  local defaults = {
    debug = false,
    dev = false,
    fixed = true,
    statistics = {
      character = {}
    },
    automation = {
      [LFG_ACTIVITY_TRIBUTE_CASUAL] = true,
      [LFG_ACTIVITY_TRIBUTE_COMPETITIVE] = true,
      ["delay"] = 5,
      --["maxChatAtGameStart"] = true,
      --["maxChatAtOpponentTurnStart"] = true,
      --["minChatAtPlayerTurnStart"] = true,
      ["changePlayerStatus"] = {},
    },
    turnTime = {
      onlyForPlayer = false,
      enabled = true,
      position = {
        x = 0.85*widthRoot,
        y = 0.4*heightRoot,
      },
      size = 20,
      showLock = true,
    },
    matchData = {
      position = {
        x = 200,
        y = 200,
      },
      enabled = true,
      font = "Univers67",
      size = 20,
    }
  }

  for _, matchType in pairs( matchTypeOrder) do
    defaults.automation.changePlayerStatus[matchType] = {enabled = true, status = PLAYER_STATUS_DO_NOT_DISTURB}
  end

  return defaults
end



local function Initialize()

  ETE.store = ZO_SavedVars:NewAccountWide("ETESV", 1, nil, GetDefaults() )

  ETE.player = {
    ["charName"] = GetUnitName("player"),
    ["charId"] = GetCurrentCharacterId(),
  }

  ValidateCharacterInfo(ETE.store.statistics.character, ETE.player)

  ETE.InitializeTurnTimeGui()

  ETE.matchDataGui = ETE.CreateMatchDataGui()
  ETE.ApplyMatchDataDesign()

  --ETE.statsGui = ETE.CreateStatsGui()
  --ETE.UpdateStatsGui()
  ETE.InitializeStatsGui()



  ETE.EM:RegisterForEvent(ETE.name.."PlayerTurnStart", EVENT_TRIBUTE_PLAYER_TURN_STARTED, OnPlayerTurnStart)
  ETE.EM:RegisterForEvent(ETE.name.."FlowStateChange", EVENT_TRIBUTE_GAME_FLOW_STATE_CHANGE, OnGameFlowStateChange)

  ETE.EM:RegisterForEvent(ETE.name.."ActivityFinterStatus", EVENT_ACTIVITY_FINDER_STATUS_UPDATE, OnActivityFinderStatusUpdate)

  ETE.CreateMenu()

  ZO_PostHook("AcceptLFGReadyCheckNotification", function()
    MATCH_PENDING = false
  end)

  ZO_PostHook("DeclineLFGReadyCheckNotification", function()
    MATCH_PENDING = false
  end)



end

ZO_CreateStringId("SI_BINDING_NAME_ETE_TOGGLE_STATS_WINDOW", "Toggle Stats Window")


local function OnAddonLoaded(_, addonName)
  if addonName == ETE.name then
    Initialize()
    ETE.EM:UnregisterForEvent(ETE.name, EVENT_ADD_ON_LOADED)
  end
end

ETE.EM:RegisterForEvent(ETE.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)


function ETE.TogglePositionFix()
  local setting = ETE.store.fixed
  if setting then ETE.UnlockGui() else ETE.LockGui() end
  ETE.store.fixed = not setting
end

SLASH_COMMANDS["/hourglass"] = ETE.TogglePositionFix
