local WPamA = WPamA
local EndlessDungeonCurrentData = { ID = 0, GT = -1, Arc = 0, Cycle = 0, Stage = 0 } -- local data array

local function CalcEDProgressValue(A, C, S)
  if type(A) == "number" and type(C) == "number" and type(S) == "number" then
    local val = (100 * A) + (10 * C) + S
    return val
  end
  return 0
end

local function SaveBetterEDProgress(valArc, valCycle, valStage, edId, edGroupType)
  local CCED = WPamA.CurChar.EndlessDungeons[edId]
  local data = CCED[edGroupType]
  if data then
    if CalcEDProgressValue(valArc, valCycle, valStage) >
       CalcEDProgressValue(data.BestArc, data.BestCycle, data.BestStage) then
         data.BestArc, data.BestCycle, data.BestStage = valArc, valCycle, valStage
    end
  end
end

local function UpdateEndlessDungeonCurrentData(edID)
  local curED = EndlessDungeonCurrentData
  curED.ID = edID or DEFAULT_ENDLESS_DUNGEON_ID
  curED.GT = GetEndlessDungeonGroupType()
  curED.Arc   = GetEndlessDungeonCounterValue( ENDLESS_DUNGEON_COUNTER_TYPE_ARC ) or 0
  curED.Cycle = GetEndlessDungeonCounterValue(ENDLESS_DUNGEON_COUNTER_TYPE_CYCLE) or 0
  curED.Stage = GetEndlessDungeonCounterValue(ENDLESS_DUNGEON_COUNTER_TYPE_STAGE) or 0
end

local function UpdEndlessDungeonLBData(groupType, edID, classID)
  local CurCharName = WPamA.CurChar.Name
  local countEntries = 0
  if     groupType == ENDLESS_DUNGEON_GROUP_TYPE_SOLO then
    countEntries = GetNumEndlessDungeonSoloLeaderboardEntries(edID) or 0
    if countEntries > 0 then
      for index = 1, countEntries do
        local ranking, charName, _, _, _, stage, cycle, arc = GetEndlessDungeonSoloLeaderboardEntryInfo(edID, index)
        if (charName == CurCharName) and (ranking > 0) then
          SaveBetterEDProgress(arc, cycle, stage, edID, groupType)
        end
      end
    end
--
  elseif groupType == ENDLESS_DUNGEON_GROUP_TYPE_DUO  then
    countEntries = GetNumEndlessDungeonDuoLeaderboardEntries(edID) or 0
    if countEntries > 0 then
      for index = 1, countEntries do
        local ranking, charName, _, _, _, stage, cycle, arc = GetEndlessDungeonDuoLeaderboardEntryInfo(edID, index)
        if (charName == CurCharName) and (ranking > 0) then
          SaveBetterEDProgress(arc, cycle, stage, edID, groupType)
        end
      end
    end
--
  end
end -- UpdEndlessDungeonLBData end

function WPamA:CheckEDADataUpdateNeeded()
  local readyState = 0 -- LEADERBOARD_DATA_READY or LEADERBOARD_DATA_RESPONSE_PENDING
  local id = self.EndlessDungeons.Iterators.I[ DEFAULT_ENDLESS_DUNGEON_ID ]
  --- Update the Intro/Daily Quest status ---
  local ed = self.CurChar.EndlessDungeons[id]
  if ed then
    local hasNoIntro = HasCompletedQuest( self.EndlessDungeons.Dungeons[id].IQI ) or false
    if not hasNoIntro then
      ed.EndTS = -1 -- Intro quest is available
    elseif (ed.EndTS < 0) and hasNoIntro then
      ed.EndTS = 0 -- Intro quest is completed
    elseif not self:CheckToday(ed.EndTS) then
      ed.EndTS = 0 -- Daily quest is available
    end
--[[
    local secUntilEnd = GetEndlessDungeonOfTheWeekTimes()
    if secUntilEnd > 0 then ed.EndTS = GetTimeStamp() + secUntilEnd end
--]]
  end
  --- Update the Endless Dungeon LB data ---
  if not IsInstanceEndlessDungeon() then
    -- Query for Solo LB data --
    readyState = QueryEndlessDungeonLeaderboardData(ENDLESS_DUNGEON_GROUP_TYPE_SOLO, id)
    if readyState == LEADERBOARD_DATA_READY then
      UpdEndlessDungeonLBData(ENDLESS_DUNGEON_GROUP_TYPE_SOLO, id, self.CurChar.Class)
    end
    -- Query for Duo LB data --
    readyState = QueryEndlessDungeonLeaderboardData(ENDLESS_DUNGEON_GROUP_TYPE_DUO, id)
    if readyState == LEADERBOARD_DATA_READY then
      UpdEndlessDungeonLBData(ENDLESS_DUNGEON_GROUP_TYPE_DUO, id, self.CurChar.Class)
    end
  else
    -- Update current ED status --
    UpdateEndlessDungeonCurrentData(DEFAULT_ENDLESS_DUNGEON_ID)
  end
end -- CheckEDADataUpdateNeeded end

function WPamA:UpdRowModeEDArchive(v, r, TS)
  local id = self.EndlessDungeons.Iterators.I[ DEFAULT_ENDLESS_DUNGEON_ID ]
  local CCED = v.EndlessDungeons[id] or {} -- id = 1 for Endless Archive in U40
  local icon, clr = self.EndlessDungeons.InheritColorIcons, self.Colors
  local txt = ""
  -- Daily Quest status
  r.B[1]:SetColor(self:GetColor(clr.LabelLvl))
  if not CCED.EndTS then -- data not exist
    r.B[1]:SetColor(self:GetColor(clr.DungStNA)) -- gray
    txt = self.i18n.DungStNA
  elseif CCED.EndTS == -1 then -- character has a Intro quest
    r.B[1]:SetColor(self:GetColor(clr.DungStNA)) -- gray
    txt = icon.Lock
  elseif self:CheckToday(CCED.EndTS) then -- Daily quest is completed
    r.B[1]:SetColor(self:GetColor(clr.DungStDone))
    txt = icon.ChkM
  else -- character has a Daily quest
    r.B[1]:SetColor(self:GetColor(clr.DailyQuest))
    txt = icon.Quest
  end
  r.B[1]:SetText(txt)
--
  local data = CCED[ ENDLESS_DUNGEON_GROUP_TYPE_SOLO ]
  if data then
  -- Best Run Solo
    if (data.BestStage + data.BestCycle + data.BestArc) == 0 then
      r.B[2]:SetColor(self:GetColor(clr.DungStNA)) -- gray
    else
      r.B[2]:SetColor(self:GetColor(clr.LabelLvl))
    end
    txt = ZO_EndlessDungeonManager.GetProgressionText(data.BestStage, data.BestCycle, data.BestArc, false)
    self:SetScaledText(r.B[2], txt)
  -- LeadBrd Solo
    if data.Rank == 0 then
      r.B[3]:SetColor(self:GetColor(clr.DungStNA)) -- gray
    else
      r.B[3]:SetColor(self:GetColor(clr.LabelLvl))
    end
    r.B[3]:SetText(data.Rank)
  -- data not exist
  else
    txt = self.i18n.DungStNA
    r.B[2]:SetColor(self:GetColor(clr.DungStNA)) -- gray
    r.B[2]:SetText(txt)
    r.B[3]:SetColor(self:GetColor(clr.DungStNA)) -- gray
    r.B[3]:SetText(txt)
  end
--
  data = CCED[ ENDLESS_DUNGEON_GROUP_TYPE_DUO ]
  if data then
  -- Best Run Duo
    if (data.BestStage + data.BestCycle + data.BestArc) == 0 then
      r.B[4]:SetColor(self:GetColor(clr.DungStNA)) -- gray
    else
      r.B[4]:SetColor(self:GetColor(clr.LabelLvl))
    end
    txt = ZO_EndlessDungeonManager.GetProgressionText(data.BestStage, data.BestCycle, data.BestArc, false)
    self:SetScaledText(r.B[4], txt)
  -- LeadBrd Duo
    if data.Rank == 0 then
      r.B[5]:SetColor(self:GetColor(clr.DungStNA)) -- gray
    else
      r.B[5]:SetColor(self:GetColor(clr.LabelLvl))
    end
    r.B[5]:SetText(data.Rank)
  -- data not exist
  else
    txt = self.i18n.DungStNA
    r.B[4]:SetColor(self:GetColor(clr.DungStNA)) -- gray
    r.B[4]:SetText(txt)
    r.B[5]:SetColor(self:GetColor(clr.DungStNA)) -- gray
    r.B[5]:SetText(txt)
  end
--
end -- UpdRowModeEDArchive end

function WPamA.OnEndlessDungeonEvents( event, ... )
  local CCED = WPamA.CurChar.EndlessDungeons
  local curED = EndlessDungeonCurrentData
-----
  if event == EVENT_ENDLESS_DUNGEON_INITIALIZED then
    -- *integer* endlessDungeonId, *integer* flags, *bool* completed
    local endlessDungeonId = ...
    UpdateEndlessDungeonCurrentData(endlessDungeonId)
--d("-= In Init:" .. ZO_EndlessDungeonManager.GetProgressionText(curED.Stage, curED.Cycle, curED.Arc, false) )
--    curED.Arc, curED.Cycle, curED.Stage = 0, 0, 0
--    curED.GT, curED.ID = -1, endlessDungeonId
    if WPamA.SV_Main.AutoCallEyeInfinite then
      zo_callLater( function() WPamA:UseCollectibleItem(WPamA.EndlessDungeons.EyeOfInfinite.C) end, GetLatency() )
    end
-----
  elseif (event == EVENT_ENDLESS_DUNGEON_STARTED) or
         (event == EVENT_ENDLESS_DUNGEON_COMPLETED) then
    UpdateEndlessDungeonCurrentData(DEFAULT_ENDLESS_DUNGEON_ID)
    local data = CCED[curED.ID][curED.GT]
    if data then
      SaveBetterEDProgress(curED.Arc, curED.Cycle, curED.Stage, curED.ID, curED.GT)
    end
-----
  elseif event == EVENT_ENDLESS_DUNGEON_COUNTER_VALUE_CHANGED then
    if curED.GT < 0 then return end
    --- *EndlessDungeonCounterType* counterType, *integer* counterValue
    local counterType, counterValue = ...
    if     counterType == ENDLESS_DUNGEON_COUNTER_TYPE_ARC   then
      curED.Arc   = counterValue
      curED.Cycle = 1
      curED.Stage = 1
    elseif counterType == ENDLESS_DUNGEON_COUNTER_TYPE_CYCLE then
      curED.Cycle = counterValue
      curED.Stage = 1
    elseif counterType == ENDLESS_DUNGEON_COUNTER_TYPE_STAGE then
      curED.Stage = counterValue
    else
      return
    end
--d("-= In Event:" .. ZO_EndlessDungeonManager.GetProgressionText(curED.Stage, curED.Cycle, curED.Arc, false) )
    curED.GT = GetEndlessDungeonGroupType()
    local data = CCED[curED.ID][curED.GT]
    if data then
      SaveBetterEDProgress(curED.Arc, curED.Cycle, curED.Stage, curED.ID, curED.GT)
--d("-= In Save:" .. ZO_EndlessDungeonManager.GetProgressionText(data.BestStage, data.BestCycle, data.BestArc, false) )
    end
    if WPamA.SV_Main.AutoCallEyeInfinite then
      local Eye = WPamA.EndlessDungeons.EyeOfInfinite
      if not WPamA:HasPetSummonedBySkillId(Eye.S) then WPamA:UseCollectibleItem(Eye.C) end
    end -- AutoCallEyeInfinite
-----
  elseif (event == EVENT_ENDLESS_DUNGEON_LEADERBOARD_PLAYER_DATA_CHANGED) or
         (event == EVENT_ENDLESS_DUNGEON_LEADERBOARD_DATA_RECEIVED) then
    for id, data in pairs( CCED ) do
      local rank
      --- Solo LB rank ---
      rank = GetEndlessDungeonLeaderboardLocalPlayerInfo(ENDLESS_DUNGEON_GROUP_TYPE_SOLO, id) or 0
      if data[ ENDLESS_DUNGEON_GROUP_TYPE_SOLO ].Rank ~= rank then
        data[ ENDLESS_DUNGEON_GROUP_TYPE_SOLO ].Rank = rank
      end
      --- Duo LB rank ---
      rank = GetEndlessDungeonLeaderboardLocalPlayerInfo(ENDLESS_DUNGEON_GROUP_TYPE_DUO, id) or 0
      if data[ ENDLESS_DUNGEON_GROUP_TYPE_DUO ].Rank ~= rank then
        data[ ENDLESS_DUNGEON_GROUP_TYPE_DUO ].Rank = rank
      end
    end
-----
  end
--
  local m = WPamA.SV_Main.ShowMode
  if m == 43 then WPamA:UpdWindowInfo() end
end -- OnEndlessDungeonEvents end
