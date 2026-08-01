local WPamA = WPamA
local nvl = WPamA.SF_Nvl
--===================================================
--======= Cyro Assigned Campaign Section ============
--===================================================
local function GetAVASkillText(char, col)
  local w = WPamA.SkillLines.SkillLineModes[4] or {}
  local l = WPamA.SkillLines.SkillLines
  local k, t = w[col], "0"
  if k ~= nil then 
    local z = char.Skills[k] or {}
    t = WPamA:ColorizeModeCraft(nvl(z.rank, "0"), z.rank, l[k].max)
  end
  return t
end

function WPamA:UpdRowModeAVA(v, r, TS)
  local ava, ac = v.AvA, v.AvA.AssignedCampaign
  local txt, f = "", self.SV_Main.TrialAvlFrmt
  if ava.Rank > 0 then
    r.B[1]:SetColor(self:GetColor(self.Colors.LabelLvl))
    r.B[1]:SetText(zo_strformat("|t26:26:<<1>>|t<<2>>", ava.iconRank, ava.Rank))
  else
    r.B[1]:SetColor(self:GetColor(self.Colors.DungStNA))
    r.B[1]:SetText("0")
  end
--  if ac.Emperor then r.B[2]:SetColor(self:GetColor(self.Colors.DungStDone))
--  else r.B[2]:SetColor(self:GetColor(self.Colors.LabelLvl))
--  end
  r.B[2]:SetColor(self:GetColor(self.Colors.LabelLvl))
  r.B[2]:SetText( GetAVASkillText(v, 4) )
  r.B[3]:SetColor(self:GetColor(self.Colors.LabelLvl))
  r.B[3]:SetText( GetAVASkillText(v, 5) )
  if ac.ID > 0 then
    local campName = GetCampaignName(ac.ID)
    r.B[4]:SetColor(self:GetColor(self.Colors.LabelLvl))
    self:SetScaledText(r.B[4], campName)
  else
    r.B[4]:SetText(" ")
  end
  if TS >= ac.EndTS then
    r.B[5]:SetColor(self:GetColor(self.Colors.DungStNA))
    r.B[5]:SetText("0")
  else
    if ac.RT == 3 then r.B[5]:SetColor(self:GetColor(self.Colors.DungStDone)) -- green
    else r.B[5]:SetColor(self:GetColor(self.Colors.LabelLvl))
    end
    r.B[5]:SetText(ac.RT)
  end
  r.B[6]:SetColor(self:GetColor(self.Colors.LabelLvl))
  if TS >= ac.EndTS then
    if ac.ID > 0 then -- waiting for data
      r.B[6]:SetColor(self:GetColor(self.Colors.DungStNA))
      txt = GetString(SI_GAMEPAD_GENERIC_WAITING_TEXT)
    else txt = " " -- no campaign
    end
  elseif f == 1 then
    txt = self:DifTSToStr(ac.EndTS - TS, true, 0)
  elseif f == 2 then
    txt = self:TimestampToStr(ac.EndTS, 6, true)
  else
    txt = self:TimestampToStr(ac.EndTS, 7, true)
  end
  WPamA:SetScaledText(r.B[6], txt)
  if ac.RankLB > 0 then
    r.B[7]:SetColor(self:GetColor(self.Colors.LabelLvl))
    r.B[7]:SetText(ac.RankLB)
  else
    r.B[7]:SetColor(self:GetColor(self.Colors.DungStNA))
    r.B[7]:SetText(" ")
  end
end -- UpdRowModeAVA end

function WPamA:UpdAssignedCampaignData()
  local ava, ac = self.CurChar.AvA, self.CurChar.AvA.AssignedCampaign
  ava.Rank = GetUnitAvARank("player")
  ava.iconRank = GetAvARankIcon(ava.Rank)
  local CampID = GetAssignedCampaignId()
  ac.ID = CampID
  if CampID > 0 then
    local earnedTier, tierProgress, tierTotal = GetPlayerCampaignRewardTierInfo(CampID)
    if (tierTotal > 0) and ( (tierProgress > 0) or (earnedTier > 0) ) then
      ac.RT = earnedTier + math.floor(100 * tierProgress / tierTotal) / 100
    end
    local secUntilEnd = GetSecondsUntilCampaignEnd(CampID)
    if secUntilEnd > 0 then ac.EndTS = GetTimeStamp() + secUntilEnd end
  else
    ac.RT = 0
    ac.RankLB = 0
    ac.EndTS = 0
  end
  ac.Emperor = false
  if DoesCampaignHaveEmperor(CampID) then
    local empAlli, empCharName, empAccName = GetCampaignEmperorInfo(CampID)
    if empCharName == self.CurChar.Name then ac.Emperor = true end
  end
end -- UpdAssignedCampaignData end

function WPamA:UpdCampaignLeaderBoardData()
  local ac = self.CurChar.AvA.AssignedCampaign
  local alli = self.CurChar.Alli
  local numCampLB = 0
  if ac.ID > 0 then
    numCampLB = GetNumCampaignAllianceLeaderboardEntries(ac.ID, alli)
  end
  if numCampLB > 0 then
    for i = 1, numCampLB do
      local isPlayer, charRank, charName = GetCampaignAllianceLeaderboardEntryInfo(ac.ID, alli, i)
      if isPlayer and (charName == self.CurChar.Name) then
        ac.RankLB = charRank
      end
    end
  end
end -- UpdCampaignLeaderBoardData end

function WPamA:CheckAVADataUpdateNeeded()
  local readyState = 0 -- LEADERBOARD_DATA_READY or LEADERBOARD_DATA_RESPONSE_PENDING
  --- Update the Cyrodiil data ---
  if not IsInCampaign() then
    readyState = QueryCampaignLeaderboardData(self.CurChar.Alli)
    if readyState == LEADERBOARD_DATA_READY then
      self:UpdAssignedCampaignData()
      self:UpdCampaignLeaderBoardData()
    end
  end
  --- Update the battleground data ---
  if not IsActiveWorldBattleground() then
    local bg = self.CurChar.AvA.BattleGrounds
    --- Check for BATTLEGROUND_LEADERBOARD_TYPE_COMPETITIVE ---
    if bg.RankComp > 0 then
      readyState = QueryBattlegroundLeaderboardData(BATTLEGROUND_LEADERBOARD_TYPE_COMPETITIVE)
      if readyState == LEADERBOARD_DATA_READY then
        self:UpdBGrndLeaderBoardData(BATTLEGROUND_LEADERBOARD_TYPE_COMPETITIVE)
      end
    end
--[[
    --- Check for BATTLEGROUND_LEADERBOARD_TYPE_DEATHMATCH ---
    if bg.RankDM > 0 then
      readyState = QueryBattlegroundLeaderboardData(BATTLEGROUND_LEADERBOARD_TYPE_DEATHMATCH)
      if readyState == LEADERBOARD_DATA_READY then
        self:UpdBGrndLeaderBoardData(BATTLEGROUND_LEADERBOARD_TYPE_DEATHMATCH)
      end
    end
    --- Check for BATTLEGROUND_LEADERBOARD_TYPE_LAND_GRAB ---
    if bg.RankLG > 0 then
      readyState = QueryBattlegroundLeaderboardData(BATTLEGROUND_LEADERBOARD_TYPE_LAND_GRAB)
      if readyState == LEADERBOARD_DATA_READY then
        self:UpdBGrndLeaderBoardData(BATTLEGROUND_LEADERBOARD_TYPE_LAND_GRAB)
      end
    end
    --- Check for BATTLEGROUND_LEADERBOARD_TYPE_FLAG_GAMES ---
    if bg.RankFG > 0 then
      readyState = QueryBattlegroundLeaderboardData(BATTLEGROUND_LEADERBOARD_TYPE_FLAG_GAMES)
      if readyState == LEADERBOARD_DATA_READY then
        self:UpdBGrndLeaderBoardData(BATTLEGROUND_LEADERBOARD_TYPE_FLAG_GAMES)
      end
    end
--]]
  end
end -- CheckAVADataUpdateNeeded end

function WPamA:ClearOutdatedAVAData()
  local CL, CC, CN = self.SV_Main.CharsList, self.CurChar, self.CharNum
  local ac = CC.AvA.AssignedCampaign
  local id, ets = ac.ID, ac.EndTS
  local ts = GetTimeStamp()
  for i = 1, #CL do
    if CL[i] then
      --== Check for outdated Cyrodiil data ==--
      local charAC = CL[i].AvA.AssignedCampaign
      -- when the campaign not exist
      if (charAC.ID > 0) and (GetCampaignName(charAC.ID) == "") then
        CL[i].AvA.AssignedCampaign = { ID = 0, RT = 0, EndTS = 0, RankLB = 0, Emperor = false }
      end
      -- when the campaign is exist but outdated
      if (charAC.ID > 0) and (charAC.ID == id) and (ts >= charAC.EndTS) then
        charAC.RT = 0
        charAC.RankLB = 0
        charAC.Emperor = false
        if i ~= CN then charAC.EndTS = ets end -- it's not a current char
      end
      --== Check for outdated BattleGround data ==--
      local charBG = CL[i].AvA.BattleGrounds
      if (charBG.EndTS > 0) and (ts >= charBG.EndTS) then
        CL[i].AvA.BattleGrounds = { RankComp = 0, EndTS = 0 } -- RankDM = 0, RankLG = 0, RankFG = 0
      end
-----------
    end
  end
end -- ClearOutdatedAVAData end

function WPamA.OnRankPointUpdate(event, unitTag, rankPoints, rankDiff)
--EVENT_RANK_POINT_UPDATE (number eventCode, string unitTag, number rankPoints, number difference)
  QueryCampaignLeaderboardData(WPamA.CurChar.Alli)
end

function WPamA.OnCampLBDataReceived(event, alliance)
--EVENT_CAMPAIGN_LEADERBOARD_DATA_RECEIVED (*integer* _campaignId_, *[Alliance]* _alliance_)
  WPamA:UpdAssignedCampaignData()
  WPamA:UpdCampaignLeaderBoardData()
  local m = WPamA.SV_Main.ShowMode
  if m == 16 then WPamA:UpdWindowInfo() end
end

function WPamA.OnAssignedCampChanged(event, newCampID)
--EVENT_ASSIGNED_CAMPAIGN_CHANGED (number eventCode, number newAssignedCampaignId)
  QueryCampaignLeaderboardData(WPamA.CurChar.Alli)
end

function WPamA.OnCampScoreDataChanged(event)
--EVENT_CAMPAIGN_SCORE_DATA_CHANGED (number eventCode)
  QueryCampaignLeaderboardData(WPamA.CurChar.Alli)
end

function WPamA.OnCampEmperorChanged(event, campID)
--EVENT_CAMPAIGN_EMPEROR_CHANGED (number eventCode, number campaignId)
  local ac = WPamA.CurChar.AvA.AssignedCampaign
  if ac.ID == campID then QueryCampaignLeaderboardData(WPamA.CurChar.Alli) end
end
--===================================================
--============ Battlegrounds Section ================
--===================================================
function WPamA:UpdRowModeBGrnd(v, r, TS)
  local ava, bg = v.AvA, v.AvA.BattleGrounds
  local txt, f = "", self.SV_Main.TrialAvlFrmt
  if ava.Rank > 0 then
    r.B[1]:SetColor(self:GetColor(self.Colors.LabelLvl))
    txt = zo_strformat("|t26:26:<<1>>|t<<2>>", ava.iconRank, ava.Rank)
  else
    r.B[1]:SetColor(self:GetColor(self.Colors.DungStNA))
    txt = "0"
  end
  r.B[1]:SetText(txt)
------
  r.B[2]:SetColor(self:GetColor(self.Colors.LabelLvl))
  r.B[2]:SetText( GetAVASkillText(v, 5) )
------
  if bg.RankComp > 0 then
    r.B[3]:SetColor(self:GetColor(self.Colors.LabelLvl))
    r.B[3]:SetText(bg.RankComp)
  else
    r.B[3]:SetColor(self:GetColor(self.Colors.DungStNA))
    r.B[3]:SetText(" ")
  end
------
  r.B[4]:SetColor(self:GetColor(self.Colors.LabelLvl))
  if TS >= bg.EndTS then
    if bg.RankComp > 0 then -- waiting for data
    ---- if (bg.RankDM + bg.RankLG + bg.RankFG) > 0 then -- waiting for data
      r.B[4]:SetColor(self:GetColor(self.Colors.DungStNA))
      txt = GetString(SI_GAMEPAD_GENERIC_WAITING_TEXT)
    else txt = " " -- no active LBs
    end
  elseif f == 1 then
    txt = self:DifTSToStr(bg.EndTS - TS, true, 0)
  elseif f == 2 then
    txt = self:TimestampToStr(bg.EndTS, 6, true)
  else
    txt = self:TimestampToStr(bg.EndTS, 7, true)
  end
  WPamA:SetScaledText(r.B[4], txt)
------
--[[
  if bg.RankDM > 0 then
    r.B[3]:SetColor(self:GetColor(self.Colors.LabelLvl))
    r.B[3]:SetText(bg.RankDM)
  else
    r.B[3]:SetColor(self:GetColor(self.Colors.DungStNA))
    r.B[3]:SetText(" ")
  end
------
  if bg.RankLG > 0 then
    r.B[4]:SetColor(self:GetColor(self.Colors.LabelLvl))
    r.B[4]:SetText(bg.RankLG)
  else
    r.B[4]:SetColor(self:GetColor(self.Colors.DungStNA))
    r.B[4]:SetText(" ")
  end
------
  if bg.RankFG > 0 then
    r.B[5]:SetColor(self:GetColor(self.Colors.LabelLvl))
    r.B[5]:SetText(bg.RankFG)
  else
    r.B[5]:SetColor(self:GetColor(self.Colors.DungStNA))
    r.B[5]:SetText(" ")
  end
--]]
------
end -- UpdRowModeBGrnd end

function WPamA:UpdBGrndLeaderBoardData(battlegroundType)
  local bg = self.CurChar.AvA.BattleGrounds
  local function UpdateCharRankLB(typeLB)
     local charRank = GetBattlegroundLeaderboardLocalPlayerInfo(typeLB)
     if charRank > 0 then
       if typeLB == BATTLEGROUND_LEADERBOARD_TYPE_COMPETITIVE then
         bg.RankComp = charRank
       end
       --[[
       if typeLB == BATTLEGROUND_LEADERBOARD_TYPE_DEATHMATCH then
         bg.RankDM = charRank
       elseif typeLB == BATTLEGROUND_LEADERBOARD_TYPE_LAND_GRAB then
         bg.RankLG = charRank
       elseif typeLB == BATTLEGROUND_LEADERBOARD_TYPE_FLAG_GAMES then
         bg.RankFG = charRank
       end
       --]]
     end
  end
-- Update BG ranks
  if battlegroundType and (battlegroundType > 0) then
    UpdateCharRankLB(battlegroundType)
  else
    for i = 1, BATTLEGROUND_LEADERBOARD_TYPE_MAX_VALUE do UpdateCharRankLB(i) end
  end
-- Update EndTS for the active fighter only
  if bg.RankComp > 0 then
  ---- if (bg.RankDM + bg.RankLG + bg.RankFG) > 0 then
    local secUntilEnd = GetBattlegroundLeaderboardsSchedule(BATTLEGROUND_LEADERBOARD_TYPE_COMPETITIVE)
    if secUntilEnd > 0 then bg.EndTS = GetTimeStamp() + secUntilEnd end
  end
end -- UpdBGrndLeaderBoardData end

function WPamA.OnBGrndLBDataReceived(event, battlegroundType)
--EVENT_BATTLEGROUND_LEADERBOARD_DATA_RECEIVED (*[BattlegroundLeaderboardType]* _battlegroundType_)
  WPamA:UpdBGrndLeaderBoardData(battlegroundType)
  local m = WPamA.SV_Main.ShowMode
  if m == 18 then WPamA:UpdWindowInfo() end
end

--[[ function WPamA.OnBGrndScoreDataChanged(event)
--EVENT_BATTLEGROUND_SCOREBOARD_UPDATED (number eventCode)
  QueryBattlegroundLeaderboardData()
--QueryBattlegroundLeaderboardData(*[BattlegroundLeaderboardType|#BattlegroundLeaderboardType]* _battlegroundType_)
--_Returns:_ *[LeaderboardDataReadyState|#LeaderboardDataReadyState]* _readyState_
end --]]
--===================================================
--========== AvA Daily Rewards Section ==============
--===================================================
function WPamA:UpdWindowModeAvARewards()
  local InvtItem = self.Inventory.InvtItem
  local TS = GetTimeStamp()
  local LNK = "|H0:item:<<1>>:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h"
  local RewardsList = {
         [1] = { Name = GetItemLinkName( zo_strformat(LNK, InvtItem[14].link) ):gsub("%^.+", ""),
                 Icon = InvtItem[14].HdT:gsub("%(.+", "") },
         [2] = { Name = GetItemLinkName( zo_strformat(LNK, InvtItem[26].link) ):gsub("%^.+", ""),
                 Icon = InvtItem[26].HdT },
         [3] = { Name = GetItemLinkName( zo_strformat(LNK, InvtItem[28].link) ):gsub("%^.+", ""),
                 Icon = InvtItem[28].HdT },
         [4] = { Name = GetItemLinkName( zo_strformat(LNK, InvtItem[45].link) ):gsub("%^.+", ""),
                 Icon = InvtItem[45].HdT },
        }
  local f = self.SV_Main.LFGRndAvlFrmt
  local ADR = self.SV_Main.AvADailyRewards
  local RowCnt = #RewardsList
  for i = RowCnt + 1, self.Consts.RowCnt do
    self.ctrlRows[i].Row:SetHidden(true)
  end
  self:UI_UpdMainWindowSize(22, RowCnt)
--
  for i = 1, RowCnt do
    local r = self.ctrlRows[i]
    r.BG:SetHidden(true)
    r.Lvl:SetText(RewardsList[i].Icon)
    r.Char:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    r.Char:SetColor(self:GetColor(self.Colors.LabelLvl))
    self:SetScaledText(r.Char, RewardsList[i].Name)
    r.B[1]:SetColor(self:GetColor(self.Colors.LabelLvl))
    if type(ADR[i]) ~= "number" then ADR[i] = 0 end
    if ADR[i] > 0 then
      local txt = ""
      if TS >= ADR[i] then
        --r.B[1]:SetColor(self:GetColor(self.Colors.LabelLvl))
        txt = GetString(SI_GAMEPAD_STABLE_TRAINABLE_READY)
      elseif f == 1 then
        txt = self:DifTSToStr(ADR[i] - TS, true, 0)
      elseif f == 2 then
        txt = self:TimestampToStr(ADR[i], 6, true)
      else
        txt = self:TimestampToStr(ADR[i], 7, true)
      end
      WPamA:SetScaledText(r.B[1], txt)
    else -- data not exist
      r.B[1]:SetColor(self:GetColor(self.Colors.DungStNA)) -- gray
      r.B[1]:SetText(self.i18n.DungStNA)
    end
--
    r.Row:SetHidden(false)
  end
end -- UpdWindowModeAvARewards end

function WPamA.OnLootUpdated(event)
-- EVENT_LOOT_UPDATED(number eventCode)
  if not IsLooting() then return end
  local nameLT, typeLT = GetLootTargetInfo()
  if typeLT ~= INTERACT_TARGET_TYPE_ITEM then return end
  if nameLT ~= "" then
    local InvtItem, SV = WPamA.Inventory.InvtItem, WPamA.SV_Main
    local numItems = GetNumLootItems()
    if numItems > 0 then
      for i = 1, numItems do
        local lootID = GetLootItemInfo(i)
        local lootLink = GetLootItemLink(lootID, LINK_STYLE_DEFAULT)
        local itemID = GetItemLinkItemId(lootLink)
        if ZO_IsElementInNumericallyIndexedTable(InvtItem[14].ids, itemID) then -- Transmutation Geode (25) + (4-25)
          local TS = GetTimeStamp()
          if not SV.AvADailyRewards[1] then SV.AvADailyRewards[1] = 0 end
          if SV.AvADailyRewards[1] < TS then SV.AvADailyRewards[1] = WPamA:GetNextDailyResetTS() end
        elseif itemID == InvtItem[26].ids then -- Arena Gladiator's Proof
          local TS = GetTimeStamp()
          if not SV.AvADailyRewards[2] then SV.AvADailyRewards[2] = 0 end
          if SV.AvADailyRewards[2] < TS then SV.AvADailyRewards[2] = WPamA:GetNextDailyResetTS() end
        elseif itemID == InvtItem[28].ids then -- Siege of Cyrodiil Merit
          local TS = GetTimeStamp()
          if not SV.AvADailyRewards[3] then SV.AvADailyRewards[3] = 0 end
          if SV.AvADailyRewards[3] < TS then SV.AvADailyRewards[3] = WPamA:GetNextDailyResetTS() end
        elseif itemID == InvtItem[45].ids then -- Battlemaster Token
          local TS = GetTimeStamp()
          if not SV.AvADailyRewards[4] then SV.AvADailyRewards[4] = 0 end
          if SV.AvADailyRewards[4] < TS then SV.AvADailyRewards[4] = WPamA:GetNextDailyResetTS() end
        end
      end
    end
  end
--
  local m = WPamA.SV_Main.ShowMode
  if m == 22 then WPamA:UpdWindowInfo() end
end -- OnLootUpdated end
--===================================================
--============ AvA AP Bonus Section =================
--===================================================
function WPamA:UpdRowModeAvAXPBuffs(v, r, ttl, TS)
  local ava = self.TimedEffects.AvA -- [index] = { AbilityId = {aid}, Perc = 00, ItemId = {item_id} }
  local ccte = v.TimedEffects.AvA -- { Index = ava[aid], EndTS = ETS, SecUE = SecUntilEnd }
  local isCurChar = v.Name == self.CurChar.Name
  local map = self.ModeSettings[50].Map
--  local II = self.Inventory.InvtItem
  local timeTxt = isCurChar and self:DifTSToStr(ccte.EndTS - TS, true, 0) or self:DifTSToStr(ccte.SecUE, false, 0)
  local isDataActual = isCurChar and (TS < ccte.EndTS) or (ccte.SecUE > 0)
  ---
  if isDataActual then
    r.B[1]:SetColor(self:GetColor(self.Colors.LabelLvl))
--    r.B[1]:SetText(zo_strformat("+<<1>>%", ava[ ccte.Index ].Perc))
    r.B[1]:SetText(zo_strformat(SI_TOOLTIP_DISTRICT_TEL_VAR_BONUS_FORMAT, ava[ ccte.Index ].Perc))
    r.B[2]:SetColor(self:GetColor(self.Colors.LabelLvl))
    r.B[2]:SetText(timeTxt)
  else -- saved data is outdated or not available
    r.B[1]:SetColor(self:GetColor(self.Colors.DungStNA))
    r.B[1]:SetText("---")
    r.B[2]:SetColor(self:GetColor(self.Colors.DungStNA))
    r.B[2]:SetText("---")
  end
  ---
  for j = 3, 5 do
    if map[j] then
      local k = v.Invt[ map[j] ] or 0
      ttl[j] = ttl[j] + k
      self:UpdInvtItemCtrl(r.B[j], k, false)
    else
      r.B[j]:SetText("")
    end
  end
  ---
end -- UpdRowModeAvAXPBuffs end
