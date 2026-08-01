-- Initialization of variables
WPamA.Today = {}
WPamA.OldShowMode = 9
WPamA.SI_TOOLTIP_ITEM_NAME = GetString(SI_TOOLTIP_ITEM_NAME)
WPamA.RGLA_Started = false
WPamA.RGLA_QuestJI = 0
WPamA.AICfg = {} -- For save AutoInvite config

local function nvl(val) if val == nil then return "nil" end return val end
local function BoolToStr(val) if val == nil then return "Nil" elseif val then return "True" end return "False" end
local function msg(txt, method)
  txt = "|c88aaff" .. WPamA.Name .. ":|r " .. txt
  if method == true or method == nil then
    CHAT_SYSTEM.primaryContainer.currentBuffer:AddMessage(txt) 
  else
    d(txt)
  end
end

function WPamA:UpdToday()
  self.Today.Diff = zo_floor(GetDiffBetweenTimeStamps(GetTimeStamp(), self.Consts.BaseTimeStamp) / self.Consts.SecInDay)
  self.Today.TS = self.Consts.BaseTimeStamp + self.Today.Diff * self.Consts.SecInDay
  self.Today.W = (self.Consts.BaseDayOfWeek + self.Today.Diff) % 7
end

function WPamA:ChekToday(DTS)
  if DTS ~= nil and DTS >= self.Today.TS and DTS < (self.Today.TS + self.Consts.SecInDay) then
    return true
  end
  return false
end

function WPamA:TimestampToStr(tmst)
  local date, time = FormatAchievementLinkTimestamp(tmst)
  if self.Consts.DateTimeFrmt <= 0 then
    return date .. " " .. time
  end
  local dd, mm, yy, n, s = "", "", "", 0, ""

  -- For JP Client
  if self.JP then

    for i=1,string.len(date) do
      s = string.sub(date, i , i)
      if type(tonumber(s)) ~= "number" then
        n = n + 1
      elseif n == 0 then
        yy = yy .. s
      elseif n == 3 then
        mm = mm .. s
      elseif n == 6 then
        dd = dd .. s
      end 
    end

  else

    for i=1,string.len(date) do
      s = string.sub(date, i , i)
      if s == "/" or s == "."  then
        n = n + 1
      elseif n == 0 then
        mm = mm .. s
      elseif n == 1 then
        dd = dd .. s
      elseif n == 2 then
        yy = yy .. s
      end 
    end
  end

  if string.len(mm) == 1 then
      mm = "0" .. mm
  end
  if string.len(dd) == 1 then
      dd = "0" .. dd
  end
  if self.Consts.DateTimeFrmt == 1 then

    -- For JP Client
    if self.JP then
      return mm .. "/" .. dd .. " " .. string.sub(time, 1 , 5)
    else
      return yy .. "-" .. mm .. "-" .. dd .. " " .. string.sub(time, 1 , 5)
    end

  elseif self.Consts.DateTimeFrmt == 3 then
    return dd .. "." .. mm .. "." .. string.sub(yy, 3 , 2)
  end
  return yy .. "-" .. mm .. "-" .. dd
end

function WPamA:Debug(Txt)
  if self.IsDebugMode then
    if self.savedVars.Debug == nil then
      self.savedVars.Debug = {}
    end
    local Lang = GetCVar('Language.2')
    table.insert(self.savedVars.Debug, self:TimestampToStr(GetTimeStamp()) .. "> " .. Txt .. "; Lang: " .. Lang)
    msg(Txt)
  end
end

function WPamA:QDump()
  local n = 0
  local hldDbg = self.IsDebugMode
  self.IsDebugMode = true
  for i = 1, MAX_JOURNAL_QUESTS do -- GetNumJournalQuests()
    if IsValidQuestIndex(i) then
-- questName,backgroundText,activeStepText,activeStepType, activeStepTrackerOverrideText, completed, tracked, questLevel,pushed,questType,instanceDisplayType=GetJournalQuestInfo(i)
      local questName, _, _, _, activeStep, _, _, _, _, questType = GetJournalQuestInfo(i)
      --local questType = GetJournalQuestType(i)
      local isRepeat = GetJournalQuestRepeatType(i)
      self:Debug("DmpQ > QN: " .. questName .. "; JI: " .. i .. "; QT: " .. questType .. "; IR: " .. isRepeat .. "; AS: " .. activeStep)
      n = n + 1
    end
  end
  self.IsDebugMode = hldDbg
  msg("Dumped " .. n .. " quests to debug buffer")
end

function WPamA:StopAIAndRestoreCgf()
  if AutoInvite ~= nil and AutoInviteUI ~= nil then
    AutoInvite.disable()
    local aic = AutoInvite.cfg
    aic.watchStr = self.AICfg.watchStr
    aic.maxSize = self.AICfg.maxSize
    aic.cyrCheck = self.AICfg.cyrCheck
    --aic.restart = false
    --aic.autoKick = false
    --aic.kickDelay = 300
    --aic.showPanel = true
    AutoInviteUI.refresh()
  end
end

function WPamA:GetCurrentWrBoss()
  local v = self.CurChar.WrBoss
  if v[0] ~= nil and v[0] >= 1 and v[0] <= 6 then
    return v[0]
  end
  return 0
end

function WPamA:GetWWBJournalIndex(num)
  if num == nil or num < 1 or num > 6 then
    return 0
  end
  local qn = self.i18n.DailyBossQ[num]
  if qn == nil then
    return 0
  end
  for i = 1, MAX_JOURNAL_QUESTS do -- GetNumJournalQuests()
    if IsValidQuestIndex(i) then
      if GetJournalQuestName(i) == qn then
        return i
      end
    end
  end
  return 0
end

function WPamA:ShareQuest(ji)
  ShareQuest(ji)
  if self.savedVars.QAlert then
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.QUEST_SHARE_SENT, GetString(SI_QUEST_SHARED))
  end
  if self.savedVars.QChat then
    msg(GetString(SI_QUEST_SHARED))
  end
end 

function WPamA:RGLARegUnReg(isreg)
  if isreg then
    EVENT_MANAGER:RegisterForEvent(WPamA.Name, EVENT_LEADER_UPDATE, WPamA.OnUnitLeaderUpdate)  
    EVENT_MANAGER:RegisterForEvent(WPamA.Name, EVENT_GROUP_MEMBER_JOINED, WPamA.OnGroupMemberJoined)
    EVENT_MANAGER:RegisterForEvent(WPamA.Name, EVENT_CHAT_MESSAGE_CHANNEL, WPamA.OnChatMessage)
    EVENT_MANAGER:RegisterForEvent(WPamA.Name, EVENT_QUEST_CONDITION_COUNTER_CHANGED, WPamA.OnQCondChanged)
  else
    EVENT_MANAGER:UnregisterForEvent(WPamA.Name, EVENT_LEADER_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(WPamA.Name, EVENT_GROUP_MEMBER_JOINED)
    EVENT_MANAGER:UnregisterForEvent(WPamA.Name, EVENT_CHAT_MESSAGE_CHANNEL)
    EVENT_MANAGER:UnregisterForEvent(WPamA.Name, EVENT_QUEST_CONDITION_COUNTER_CHANGED)
  end
end

function WPamA:IsWrothgarLocation()
  local mzi = GetCurrentMapZoneIndex()
  --msg("MapZoneInd=" .. nvl(mzi))
  if mzi == nil or mzi ~= self.Consts.WrothgarMZI then
    return false
  end
  return true
end

function WPamA:TryRGLAStart()
  -- Check quest - must present quest for Wrothgar World Bosses
  local v = self.CurChar
  if v.WrBoss[0] == nil or v.WrBoss[0] < 1 or v.WrBoss[0] > 6 then
    self.RGLA_QuestJI = 0
  else
    self.RGLA_QuestJI = self:GetWWBJournalIndex(v.WrBoss[0])
  end
  if self.RGLA_QuestJI == 0 then
    msg(self.i18n.RGLA_ErrQuest)
    return false
  end
-- Check quest conditions
  if self.savedVars.BossKilled and GetJournalQuestNumConditions(self.RGLA_QuestJI, 1) ~= 2 then
    msg(self.i18n.RGLA_ErrBoss)
    return false
  end
  -- Check location - must be Wrothgar
  if not WPamA:IsWrothgarLocation() then
    msg(self.i18n.RGLA_ErrWrothgar)
    return false
  end
  -- Check group - must be Leader or not in group
  if IsUnitGrouped("player") and not IsUnitGroupLeader("player") then
    msg(self.i18n.RGLA_ErrLeader)
    return false
  end
  -- Check group - must present AutoInvite addon
  if AutoInvite == nil or AutoInviteUI == nil then
    msg(self.i18n.RGLA_ErrAI)
    return false
  end
  AutoInvite.disable()
  local aic = AutoInvite.cfg
  -- Save current AI values
  self.AICfg.watchStr = aic.watchStr
  self.AICfg.maxSize = aic.maxSize
  self.AICfg.cyrCheck = aic.cyrCheck
  -- Set values for RGLA
  aic.watchStr = self.Consts.DailyBoss[v.WrBoss[0]].S[1]
  aic.maxSize = self.Consts.RGLAMaxGrMember
  aic.cyrCheck = false
  self:RGLARegUnReg(true)
  AutoInvite.startListening()
  AutoInviteUI.refresh()
  return true
end

function WPamA:RGLAStop()
  self.RGLA_Started = false
  self.RGLA_QuestJI = 0
  self:RGLARegUnReg(false)
  self:UpdRGLAInfo()
  self:StopAIAndRestoreCgf()    
end

function WPamA:PostToChatRGLA(var)
  local n = self.CurChar.WrBoss[0]
  local b = self.Consts.DailyBoss[n]
  local e = self.EN.RGLA
  local f = self.savedVars.AutoShare
  local txt = ""
  if var == 1 then
    txt = e.C1 .. b.H .. e.C2 .. b.S[1]
    for i = 2, #b.S do
      if i == #b.S then txt = txt .. e.D2 .. b.S[i] else  txt = txt .. e.D1 .. b.S[i] end
    end
    txt = txt .. e.C3
    if f then txt = txt .. e.C4 end
    txt = txt .. " (" .. self.Name .. ")."
  elseif var == 2 then
    txt = e.C1 .. e.C0 .. b.S[1] .. e.C5
    if f then txt = txt .. e.C6 end
  elseif var == 3 then
    txt = e.CZ .. b.H .. e.C7 
  elseif var == 4 then
    txt = e.CP .. b.H .. e.C7 
  elseif var == 5 then
    txt = e.CP .. e.C8
  elseif var == 6 then
    txt = e.CZ .. b.H .. e.C9
  elseif var == 7 then
    txt = e.CP .. e.Q1
  else
    txt = e.A1 .. self.Name .. " v" .. self.Version .. e.A2
  end
  --msg(txt)
  CHAT_SYSTEM:StartTextEntry(txt) 
end

-- For JP Client
function WPamA:PostToChatRGLAJp(var)

  local wrBoss = self.CurChar.WrBoss[0]
  local dailyBoss = self.Consts.DailyBoss[wrBoss]
  local rgla = self.JP.RGLA
  local autoShare = self.savedVars.AutoShare
  local txt = ""

  if var == 1 then
    txt = zo_strformat(rgla.F1, dailyBoss.H)
  	if autoShare then
  	  txt = txt .. zo_strformat(rgla.F2, dailyBoss.S[1])
  	else
  	  txt = txt .. zo_strformat(rgla.F3, dailyBoss.S[1])
  	end  	
    for i = 2, #dailyBoss.S do
      txt = txt .. zo_strformat(rgla.F4, dailyBoss.S[i])
    end
    txt = txt .. zo_strformat(rgla.F5, self.Name)
    
  elseif var == 2 then
    if autoShare then
      txt = zo_strformat(rgla.F6, dailyBoss.S[1])
	else
      txt = zo_strformat(rgla.F7, dailyBoss.S[1])
    end

  elseif var == 3 then
    txt = zo_strformat(rgla.F8, rgla.CG, dailyBoss.H)

  elseif var == 4 then
    txt = zo_strformat(rgla.F8, rgla.CP, dailyBoss.H)

  elseif var == 5 then
    txt = zo_strformat(rgla.F9, dailyBoss.H)

  elseif var == 6 then
    txt = zo_strformat(rgla.F10, dailyBoss.H)

  elseif var == 7 then
    txt = zo_strformat(rgla.F11)

  else
    txt = zo_strformat(rgla.F12, self.Name, self.Version)
  end

  --msg(txt)
  CHAT_SYSTEM:StartTextEntry(txt) 
end

function WPamA:CheckDungNum(num)
  if num == nil or num <= 1 then
    return 1
  elseif num > 20 then
    return 2
  end
  return num
end

function WPamA:GetDungeonName(num)
  if self.savedVars.ShowLoc == true and num > 2 then
    local mapName, _, _, _ = GetMapInfo(self.Consts.Dungeons[num].Loc)
    mapName = LocalizeString(self.SI_TOOLTIP_ITEM_NAME, mapName)
    return mapName
  end

  if self.savedVars.ENDung and num > 2 then
    return self.EN.DungeonsName[num]
  end
  return self.i18n.Dungeons[num].Name
end

function WPamA:GetGoldDungNum(noffset)
  local num = 1 + noffset % #self.Consts.OrdGold
  if self.Consts.OrdGold[num] ~= nil then
    return self.Consts.OrdGold[num]
  end    
  return 1
end

function WPamA:GetSilverDungNum(noffset)
  local num = 1 + noffset % #self.Consts.OrdSilver
  if self.Consts.OrdSilver[num] ~= nil then
    return self.Consts.OrdSilver[num]
  end    
  return 1
end

function WPamA:UpdSlvGld(Plg, ctrlName, ctrlAct, ctrlMSL, isVeteran, isGold, lvl)
  if Plg ~= nil then
-- 
    if Plg.Act == nil or Plg.Act == 0 then
      ctrlAct:SetHidden(true)
    else
      ctrlAct:SetHidden(false)
    end
--
    local n = self:CheckDungNum(Plg.Num)
    if ctrlMSL ~= nil then
      if self.Consts.Dungeons[n].Lvl == 0 then
        ctrlMSL:SetText("")
      else
        ctrlMSL:SetText(self.Consts.Dungeons[n].Lvl)
      end
    end
--
    local m = self:GetDungeonName(n)
    local c = self.Consts.Dungeons[n].Alli
    if n == 1 then
      if not isVeteran and (isGold or lvl < self.Consts.MinCharLvlForSilver) then
        m = self.i18n.DungStNA
        c = self.Colors.DungStNA
      elseif self:ChekToday(Plg.BTS) and self:ChekToday(Plg.ETS) then
        m = self.i18n.DungStDone
        c = self.Colors.DungStDone
      elseif self.savedVars.DontShowNone then
        m = ""
      end
    end
    ctrlName:SetText(m)
    ctrlName:SetColor(self:GetColor(c))
  end
end

function WPamA:UpdWindowHdrInfo(isRedraw)
-- While ENLIGHTENED LOST is bugged Do this workaround --
  if WPamA.EnlitState and (GetEnlightenedPool() == 0) then
    WPamA.EnlitState = false
    isRedraw = true
  end
-- ------------------------------------------------------
  if (not isRedraw) and (self.OldShowMode == self.savedVars.ShowMode) then
    return
  end
  self.OldShowMode = self.savedVars.ShowMode
  self:UI_UpdMainWindowHdr(self.OldShowMode)
end

function WPamA:UpdLvl(v, r)
  r.Lvl:SetColor(self:GetColor(self.Colors.LabelLvl))
  if v.Veteran then
    r.Lvl:SetText(self.Consts.IconsW.Chm)
  else
    r.Lvl:SetText(v.Lvl)
  end
end

function WPamA:UpdCharWindowInfo()
  local z = 0
  for i=1,self.Consts.RowCnt do
    local r = self.ctrlRows[i]
    if self.savedVars.CharsList[i] == nil then
      r.Row:SetHidden(true)
    else
      local v = self.savedVars.CharsList[i]
      z = i
-- Current char
      if v.Name == self.CharName then
      --if i == 4 then
        r.BG:SetHidden(false)
      else
        r.BG:SetHidden(true)
      end
-- Lvl
      self:UpdLvl(v, r)
-- Name
      r.Char:SetText(v.Name)
      r.Char:SetColor(self:GetColor(v.Alli))
-- Silver
      self:UpdSlvGld(v.Slv, r.Silver, r.SilverAct, r.MSL, v.Veteran, false, v.Lvl)
-- Gold
      self:UpdSlvGld(v.Gld, r.Gold, r.GoldAct, nil, v.Veteran, true, v.Lvl)
--
      r.Row:SetHidden(false)
    end
  end
  self:UI_UpdMainWindowSize(0, z, self.savedVars.CharsList[z+1])
end

function WPamA:PostToChatTd()
  self:UpdToday()

  -- For JP Client
  if self.JP then
    txt = self:BuildInfoStringJP()
  else
    txt = self:BuildInfoStringEN()
  end

  CHAT_SYSTEM:StartTextEntry(txt)
end

function WPamA:BuildInfoStringEN()

  local Chat = self.EN.Chat

-- Date
  local txt =  Chat.Td1
  if self.EN.DayOfWeek ~= nil then
    txt = txt .. self.EN.DayOfWeek[self.Today.W] .. " "
  end
  txt = txt .. self:TimestampToStr(self.Today.TS) .. Chat.Td2
-- Silver
  local q = self:GetSilverDungNum(self.Today.Diff)
  txt = txt .. Chat.Silver .. self.EN.DungeonsName[q] .. " [" .. self.Consts.Dungeons[q].Lvl .. "]"
-- Gold
  q = self:GetGoldDungNum(self.Today.Diff)
  txt = txt .. Chat.Gold .. self.EN.DungeonsName[q]
  if self.Consts.LootGold ~= nil and self.Consts.LootGold[q] ~= nil and self.Consts.LootGold[q] ~= "" then
    txt = txt .. Chat.Loot1 .. self.Consts.LootGold[q] .. Chat.Loot2
  end
-- Addon name, version
  txt = txt .. Chat.Use1 .. self.Name .. " v" .. self.Version .. Chat.Use2

  return txt
end

-- For JP Client
function WPamA:BuildInfoStringJP()

  local Chat = self.JP.Chat

-- Date
  local txt =  Chat.Td1 .. self:TimestampToStr(self.Today.TS) .. "(" .. self.i18n.DayOfWeek[self.Today.W] .. ")" .. Chat.Td2

-- Silver
  local q = self:GetSilverDungNum(self.Today.Diff)
  txt = txt .. Chat.Silver .. self.JP.DungeonsName[q] .. " [Lv" .. self.Consts.Dungeons[q].Lvl .. "]"

-- Gold
  q = self:GetGoldDungNum(self.Today.Diff)
  txt = txt .. Chat.Gold .. self.JP.DungeonsName[q]
  if self.Consts.LootGold ~= nil and self.Consts.LootGold[q] ~= nil and self.Consts.LootGold[q] ~= "" then
    txt = txt .. Chat.Loot1 .. self.Consts.LootGold[q] .. Chat.Loot2
  end

-- Addon name, version
  txt = txt .. Chat.Use1 .. self.Name .. " v" .. self.Version .. Chat.Use2

  return txt
end

function WPamA:UpdClndWindowInfo()
  local q = 0
  self:UpdToday()
  local z = self.Today.Diff - 1
  local t = self.Today.TS - self.Consts.SecInDay
  local w = (self.Today.W + 6) % 7
  z = z - 1
  for i=9,self.Consts.RowCnt do
    self.ctrlRows[i].Row:SetHidden(true)
  end
  for i=1,8 do
    local r = self.ctrlRows[i]
    r.Row:SetHidden(true)
    if i == 2 then
      r.BG:SetHidden(false)
    else
      r.BG:SetHidden(true)
    end
-- Lvl
    r.Lvl:SetHidden(false)
    if self.i18n.DayOfWeek ~= nil then
      r.Lvl:SetText(self.i18n.DayOfWeek[w])
    elseif self.EN.DayOfWeek ~= nil then
      r.Lvl:SetText(self.EN.DayOfWeek[w])
    else
      r.Lvl:SetText("")
    end
-- Day
    r.Char:SetText(self:TimestampToStr(t))
-- Saturday or Sunday
    if w == 0 or w == 6 then
      r.Lvl:SetColor(self:GetColor(self.Colors.Weekend))
      r.Char:SetColor(self:GetColor(self.Colors.Weekend))
    else
      r.Lvl:SetColor(self:GetColor(self.Colors.Workday))
      r.Char:SetColor(self:GetColor(self.Colors.Workday))
    end
-- Next Day
    t = t + self.Consts.SecInDay
    w = (w + 1) % 7
-- Silver
    r.SilverAct:SetHidden(true)
    q = self:GetSilverDungNum(i + z)
    if self.Consts.Dungeons[q].Lvl == 0 then
      r.MSL:SetText("")
    else
      r.MSL:SetText(self.Consts.Dungeons[q].Lvl)
    end
--
    r.Silver:SetText(self:GetDungeonName(q))
    r.Silver:SetColor(self:GetColor(self.Consts.Dungeons[q].Alli))
-- Gold
    r.GoldAct:SetHidden(true)
    q = self:GetGoldDungNum(i + z)
    r.Gold:SetText(self:GetDungeonName(q))
    r.Gold:SetColor(self:GetColor(self.Consts.Dungeons[q].Alli))
--
    r.Row:SetHidden(false)
  end
  self:UI_UpdMainWindowSize(1, 8, nil)
end

function WPamA:UpdWWBColor(WrBoss, ctrl, isCurrent)
  local clr = self.Colors.WWBStNone
  if isCurrent then
    clr = self.Colors.WWBStCur
  elseif WrBoss ~= nil and self:ChekToday(WrBoss) then
    clr = self.Colors.WWBStDone
  end
  ctrl:SetColor(self:GetColor(clr))
end

function WPamA:UpdWWBTxtColor(WrBoss, ctrl, isCurrent)

  local clr, txt = self.Colors.WWBStNone, ""
  if not self.savedVars.DontShowNone then
    txt = self.i18n.WWBStNone
  end
  if isCurrent then
    clr, txt = self.Colors.WWBStCur, self.i18n.WWBStCur
  elseif WrBoss ~= nil and self:ChekToday(WrBoss) then
    clr, txt = self.Colors.WWBStDone, self.i18n.WWBStDone
  end
  ctrl:SetColor(self:GetColor(clr))
  ctrl:SetText(txt)
end

function WPamA:UpdWWBAchiev()
  local _, numCompleted, numRequired = GetAchievementCriterion(self.Consts.WWBAchiev, 1)
  self.CurChar.numWWB = numRequired - numCompleted
end

function WPamA:UpdWWBWindowInfo()
  local z = 0
  for i=1,self.Consts.RowCnt do
    local r = self.ctrlRows[i]
    if self.savedVars.CharsList[i] == nil then
      r.Row:SetHidden(true)
    else
      local v = self.savedVars.CharsList[i]
      z = i
-- Current char
      if v.Name == self.CharName then
      --if i == 4 then
        r.BG:SetHidden(false)
      else
        r.BG:SetHidden(true)
      end
-- Lvl
      self:UpdLvl(v, r)
-- Name
      r.Char:SetText(v.Name)
      r.Char:SetColor(self:GetColor(v.Alli))
-- Boss
      for j=1,6 do
        if j == v.WrBoss[0] then
          self:UpdWWBTxtColor(v.WrBoss[j], r.B[j], true)
        else
          self:UpdWWBTxtColor(v.WrBoss[j], r.B[j], false)
        end
      end
-- Wrothgar WB Achievment
      if v.numWWB == nil then
        r.B[7]:SetText("") -- no data at this moment
      elseif v.numWWB == 0 then
        r.B[7]:SetText(self.Consts.IconsW.A)
      else
        r.B[7]:SetText(tostring(v.numWWB)) -- progress
      end
--
      r.Row:SetHidden(false)
    end
  end
  self:UI_UpdMainWindowSize(2, z, self.savedVars.CharsList[z+1])
end

function WPamA:UpdInvtItemCtrl(ctrl, num, isVeteran, lvl, InvtNum)
  if num == nil or num == 0 then
    ctrl:SetColor(self:GetColor(self.Colors.MenuDisabled))
    if isVeteran or InvtNum>3 or (InvtNum>1 and lvl >= self.Consts.MinCharLvlForSilver) then
      ctrl:SetText(0)
    else
      ctrl:SetText(self.i18n.DungStNA)
    end
  else
    ctrl:SetColor(self:GetColor(self.Colors.LabelLvl))
    ctrl:SetText(num)
  end
end

function WPamA:UpdInvtWindowInfo()
  local z = 0
  local InvtIco = self.Consts.InvtIco
  local ttl = {}
  for i=1,#InvtIco do
    ttl[i] = 0
  end
  for i=1,self.Consts.RowCnt do
    local r = self.ctrlRows[i]
    if self.savedVars.CharsList[i] == nil then
      r.Row:SetHidden(true)
    else
      local v = self.savedVars.CharsList[i]
      z = i
-- Current char
      if v.Name == self.CharName then
      --if i == 4 then
        r.BG:SetHidden(false)
      else
        r.BG:SetHidden(true)
      end
-- Lvl
      self:UpdLvl(v, r)
-- Name
      r.Char:SetText(v.Name)
      r.Char:SetColor(self:GetColor(v.Alli))
-- Items
      for j=1,7 do
        if j <= #InvtIco then
          ttl[j] = ttl[j] + (v.Invt[j] or 0)
          self:UpdInvtItemCtrl(r.B[j], v.Invt[j], v.Veteran, v.Lvl, j)
        else
          r.B[j]:SetText("")
        end
      end
--
      r.Row:SetHidden(false)
    end
  end
  for j=1,7 do
    if j <= #InvtIco then
      self.ctrlWMsg.B[j]:SetText(ttl[j])
    else
      self.ctrlWMsg.B[j]:SetText("")
    end
  end
  self:UI_UpdMainWindowSize(3, z, nil)
end

function WPamA:UpdWindowInfo(isRedraw)
  self:UpdWindowHdrInfo(isRedraw)
  if self.savedVars.ShowMode == 0 then
    self:UpdCharWindowInfo()
  elseif self.savedVars.ShowMode == 1 then
    self:UpdClndWindowInfo()
  elseif self.savedVars.ShowMode == 2 then
    self:UpdWWBWindowInfo()
  elseif self.savedVars.ShowMode == 3 then
    self:UpdInvtWindowInfo()
  end
end

function WPamA:UpdRGLAInfo()

  local v = self.CurChar
  local curPresent = false
  for j=1,6 do
    if j == v.WrBoss[0] then
      curPresent = true
      self:UpdWWBColor(v.WrBoss[j], self.ctrlRGLA[j], true)
    else
      self:UpdWWBColor(v.WrBoss[j], self.ctrlRGLA[j], false)
    end
  end
  local flStart, flStop = false, self.RGLA_Started
  if flStop then
    WPamA_RGLAStart:SetText(self.i18n.RGLAStarted) 
  else
    WPamA_RGLAStart:SetText(self.i18n.RGLAStart)
    if curPresent then
      flStart = true
    end
  end
  WPamA_RGLAStart:SetEnabled(flStart)
  --WPamA_RGLAPost:SetEnabled(true)
  WPamA_RGLAStop:SetEnabled(flStop)
  WPamA_RGLAShare:SetEnabled(curPresent)
end

function WPamA:RestorePosition(ctrl, hld, ismain)
  if hld.m ~= nil and hld.x ~= nil and hld.y ~= nil then
    ctrl:ClearAnchors()
    if hld.m == 4 then
      ctrl:SetAnchor(BOTTOMLEFT, GuiRoot, BOTTOMLEFT, hld.x, -hld.y)
    elseif hld.m == 3 then
      ctrl:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, -hld.x, -hld.y)
    elseif hld.m == 2 then
      ctrl:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -hld.x, hld.y)
    else
      ctrl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, hld.x, hld.y)
    end
  end
  if ismain then
    if hld.s == nil or hld.s == true then
      self.ShowUI()
    else
      self.HideUI()
    end
  end
end

function WPamA:SavePosition(ctrl, hld)
  local gr_width = GuiRoot:GetWidth()
  local gr_height = GuiRoot:GetHeight()
  local locx, locy = ctrl:GetCenter()
  hld.x = ctrl:GetLeft()
  hld.y = ctrl:GetTop()
  if locx < gr_width / 2 then
    if locy < gr_height / 2 then
      hld.m = 1
    else
      hld.m = 4
    end
  else
    hld.x = gr_width - hld.x - ctrl:GetWidth()
    if locy < gr_height / 2 then
      hld.m = 2
    else
      hld.m = 3
    end
  end
  if hld.m == 3 or hld.m == 4 then
    hld.y = gr_height - hld.y - ctrl:GetHeight()
  end
  hld.x = math.floor(hld.x)
  hld.y = math.floor(hld.y)
end

function WPamA:FindChar()
  if self.savedVars.CharsList ~= nil then
    for n, v in pairs(self.savedVars.CharsList) do
      if self.CharName == v.Name then
        self.CharNum = n
        break
      end
    end
  end
end

function WPamA:UpdPlayerLvl()
  self.CurChar.Veteran = IsUnitVeteran("player")
  self.CurChar.Lvl = GetUnitLevel("player")
end

function WPamA:GetPledgeDoneStatus(activeStepText)
  local res = 0
  if activeStepText ~= nil then
    for _, v in pairs(self.i18n.DoneM) do
      if string.find(activeStepText, v) then
        res = 1
        break
      end
    end
  end
  return res
end

function WPamA:UpdatePledge(questName, isStart, activeStepText)
  if questName == nil then return end
  local num = 2
-- Detect dungeon
  for i=3,20 do
    if self.i18n.Dungeons[i] ~= nil then
      if string.find(questName, self.i18n.Dungeons[i].Mark) then
        num = i
        break
      end
    end
  end
-- Detect Gold/Silver
  local isGold = false
  if self.Consts.Dungeons[num].Gold == true then
    isGold = true
  end
  if isGold == false and string.find(questName, self.i18n.VeteranM) then
    isGold = true
  end
-- Detect stage and Update Start DTS
  local act = 0
  if isStart then
    if isGold then
      self.CurChar.Gld.QN = questName
      self.CurChar.Gld.BTS = GetTimeStamp()
      self.CurChar.Gld.ETS = nil
    else
      self.CurChar.Slv.QN = questName
      self.CurChar.Slv.BTS = GetTimeStamp()
      self.CurChar.Slv.ETS = nil
    end
  else
    act = self:GetPledgeDoneStatus(activeStepText)
  end
-- Write to saved variables
  if isGold then
    self.CurChar.Gld.Num = num
    self.CurChar.Gld.Act = act
  else
    self.CurChar.Slv.Num = num
    self.CurChar.Slv.Act = act
  end
end

function WPamA:FindDailyBossQuest(questName)

  local r = 0
  for n, v in pairs(self.i18n.DailyBossQ) do
    if v == questName then
      r = n
      break
    end
  end
  return r
end

function WPamA:CloseQuest(isDone, questName)
  self:UpdToday()
  local v = self.CurChar
  if v.Gld.QN == questName then
    if isDone and self:ChekToday(v.Gld.BTS) then
      v.Gld.ETS = GetTimeStamp()
    else
      v.Gld.BTS = nil
      v.Gld.ETS = nil
      v.Gld.QN = nil
    end
  elseif v.Slv.QN == questName then
    if isDone and self:ChekToday(v.Slv.BTS) then
      v.Slv.ETS = GetTimeStamp()
    else
      v.Slv.BTS = nil
      v.Slv.ETS = nil
      v.Slv.QN = nil
    end
  else
    local qi = self:FindDailyBossQuest(questName)
    if qi ~= 0 then
      v.WrBoss[0] = nil
      if isDone then
        v.WrBoss[qi] = GetTimeStamp()
        self:UpdWWBAchiev()
      end
      if self.RGLA_Started then
        self:RGLAStop()
      else
        self:UpdRGLAInfo()
      end
    end
  end
end

function WPamA:ChkAddBossDailyQuests(questName)

  local qi = self:FindDailyBossQuest(questName)
  if qi ~= 0 then
    self.CurChar.WrBoss[0] = qi
    self:UpdRGLAInfo()
  end
end

function WPamA:FindUpdateQuests()
  local v = self.CurChar
  v.Gld.Num = 1
  v.Gld.Act = 0
  v.Slv.Num = 1
  v.Slv.Act = 0
  v.WrBoss[0] = nil

  for i = 1, MAX_JOURNAL_QUESTS do -- GetNumJournalQuests()
    if IsValidQuestIndex(i) then
      local questName, _, _, _, activeStep, _, _, _, _, questType = GetJournalQuestInfo(i)
      --local questType = GetJournalQuestType(i)
      local isRepeat = GetJournalQuestRepeatType(i)
      if isRepeat == 2 then
        if questType == 5 then  -- undaunted dailies
          self:UpdatePledge(questName, false, activeStep)
        elseif questType == 1 then -- any quest include Wrothgar daily
          self:ChkAddBossDailyQuests(questName)          
        end
      end
    end
  end
end

function WPamA:UpdInvtItems()
  if self.CurChar then
    self.CurChar.Invt = {}
    local Invt = self.CurChar.Invt
    local InvtIco = self.Consts.InvtIco
    local bagId = BAG_BACKPACK
    local slotId = ZO_GetNextBagSlotIndex(bagId, nil)
    while slotId do
      itemType = GetItemType(bagId, slotId)
      if itemType == ITEMTYPE_TROPHY or itemType == ITEMTYPE_TOOL or itemType == ITEMTYPE_SOUL_GEM then
        for i=1,#InvtIco do
          local icon, stack, _, _, _, _, _, _ = GetItemInfo(bagId, slotId)
          if itemType == InvtIco[i].IT and icon == InvtIco[i].I then
            Invt[i] = (Invt[i] or 0) + stack
          end
        end
      end
      slotId = ZO_GetNextBagSlotIndex(bagId, slotId)
    end
  end
end

function WPamA:UpdCharInfo()
-- Get the name of the character and are looking for it in the saved variables table
  self.CharName = GetUnitName("player")
  self.CharNum = 0
  self.CurChar = nil
  self:FindChar()
-- Insert NEW character into saved variables table
  if self.CharNum == 0 then
    local addRow = {
      Name = self.CharName,
      Alli = GetUnitAlliance("player"),
      Gld = {},
      Slv = {},
      WrBoss = {},
      Invt = {},
    }
    table.insert(self.savedVars.CharsList, addRow)
    self:FindChar()
  end 
-- Update information about character
  if self.CharNum ~= 0 then
    self.CurChar = self.savedVars.CharsList[self.CharNum]
    self:UpdPlayerLvl()
    self:FindUpdateQuests()
    self:UpdWWBAchiev()
    self:UpdInvtItems()
    self:UpdWindowInfo()
  end 
end

function WPamA:ChkUpdPledge(Plg)
  if Plg.ETS ~= nil and not self:ChekToday(Plg.ETS) or 
     Plg.BTS ~= nil and Plg.Num == 1 and not self:ChekToday(Plg.BTS)
  then
    Plg.QN  = nil
    Plg.BTS = nil
    Plg.ETS = nil
  end
end

function WPamA:ChkUpdBoss(Boss)
  for i=1,6 do
    if Boss[i] ~= nil and not self:ChekToday(Boss[i]) then
      Boss[i] = nil
    end
  end
end

function WPamA:Initialize()
  self:UpdToday()
  self:LoadTbColors()
-- Initialization of saved variables
  local defaults = {
     CharsList = {},
  }
  self.savedVars = ZO_SavedVars:NewAccountWide("WPamASavedVars", 1, nil, defaults)
  local SV = self.savedVars
  if SV.WinMain == nil then
    SV.WinMain = {}
    self:SavePosition(WPamA_Win, SV.WinMain)
  end
  if SV.WinRGLA == nil then
    SV.WinRGLA = {}
    self:SavePosition(WPamA_RGLA, SV.WinRGLA)
  end
-- Initialization of some saved variables
  if SV.BossKilled == nil then SV.BossKilled = true end
  if SV.QChat == nil then SV.QChat = false end
  if SV.QAlert == nil then SV.QAlert = true end
  if SV.ENDung == nil then SV.ENDung = false end
  if SV.ShowLoc == nil then SV.ShowLoc = false end
  if SV.ShowMode == nil then SV.ShowMode = 0 end
  if SV.AutoShare == nil then SV.AutoShare = true end
  if SV.DontShowNone == nil then SV.DontShowNone = false end
  if SV.TitleToolTip == nil then SV.TitleToolTip = false end

  for n, v in pairs(SV.CharsList) do
    if v.Gld == nil then
      v.Gld = {}
    else
      self:ChkUpdPledge(v.Gld)
    end
    if v.Slv == nil then
      v.Slv = {}
    else
      self:ChkUpdPledge(v.Slv)
    end
    if v.WrBoss == nil then
      v.WrBoss = {}
    else
      self:ChkUpdBoss(v.WrBoss)
    end
    if v.Invt == nil then
      v.Invt = {}
    end
  end
--------------------------------------------
  self:UI_InitMainWindow()
  self:UI_InitRGLAWindow()
--------------------------------------------
-- Init current Enlightenment status
  if IsEnlightenedAvailableForAccount() and (GetEnlightenedPool() ~= 0) then
    WPamA.EnlitState = true
  end
-- Init Options window
  ZO_CheckButton_SetCheckState(WPamA_OptLocation, SV.ShowLoc)
  ZO_CheckButton_SetCheckState(WPamA_OptENDung, SV.ENDung)
  ZO_CheckButton_SetCheckState(WPamA_OptDontShowNone, SV.DontShowNone)
  ZO_CheckButton_SetCheckState(WPamA_OptTitleToolTip, SV.TitleToolTip)

  ZO_CheckButton_SetToggleFunction(WPamA_OptLocation, WPamA.OnOptionsLocClick)
  ZO_CheckButton_SetToggleFunction(WPamA_OptENDung, WPamA.OnOptionsENDungClick)
  ZO_CheckButton_SetToggleFunction(WPamA_OptDontShowNone, WPamA.OnOptionsDontShowNoneClick)
  ZO_CheckButton_SetToggleFunction(WPamA_OptTitleToolTip, WPamA.OnOptionsTitleToolTip)

  WPamA_OptResetChar:SetHandler("OnClicked", WPamA.OnOptionsResetClick)
-- Init RGLA window
  ZO_CheckButton_SetCheckState(WPamA_RGLA_OptAutoShare, SV.AutoShare)
  ZO_CheckButton_SetToggleFunction(WPamA_RGLA_OptAutoShare, self.OnRGLAAutoShareClick)
  ZO_CheckButton_SetCheckState(WPamA_RGLA_OptQAlert, SV.QAlert)
  ZO_CheckButton_SetToggleFunction(WPamA_RGLA_OptQAlert, self.OnRGLAQAlertClick)
  ZO_CheckButton_SetCheckState(WPamA_RGLA_OptQChat, SV.QChat)
  ZO_CheckButton_SetToggleFunction(WPamA_RGLA_OptQChat, self.OnRGLAQChatClick)
  ZO_CheckButton_SetCheckState(WPamA_RGLA_OptBossKilled, SV.BossKilled)
  ZO_CheckButton_SetToggleFunction(WPamA_RGLA_OptBossKilled, self.OnRGLABossKilledClick)

  WPamA_RGLAStart:SetHandler("OnClicked", WPamA.OnRGLAStartClick)
  WPamA_RGLAPost:SetHandler("OnClicked", WPamA.OnRGLASelectMsgClick)
  WPamA_RGLAStop:SetHandler("OnClicked", WPamA.OnRGLAStopClick)
  WPamA_RGLAShare:SetHandler("OnClicked", WPamA.OnRGLAShareClick)
--
  self:RestorePosition(WPamA_Win, SV.WinMain, true)
  self:RestorePosition(WPamA_RGLA, SV.WinRGLA, false)
  self:UpdCharInfo()
-- Register keybinding string
  ZO_CreateStringId("SI_BINDING_NAME_WPAMACHARTOGGLE", self.i18n.KeyBindCharStr)
  ZO_CreateStringId("SI_BINDING_NAME_WPAMACLNDTOGGLE", self.i18n.KeyBindClndStr)
  ZO_CreateStringId("SI_BINDING_NAME_WPAMACHATPOSTTD", self.i18n.KeyBindPostTd)

  ZO_CreateStringId("SI_BINDING_NAME_WPAMAWINDOWTOGGLE", self.i18n.KeyBindShowStr)
  ZO_CreateStringId("SI_BINDING_NAME_WPAMAMODECHANGE", self.i18n.KeyBindChgStr)
  ZO_CreateStringId("SI_BINDING_NAME_WPAMAWRBTOGGLE", self.i18n.KeyBindWWBStr)
  ZO_CreateStringId("SI_BINDING_NAME_WPAMAINVTTOGGLE", self.i18n.KeyBindInvtStr)

  ZO_CreateStringId("SI_BINDING_NAME_WPAMARGLA", self.i18n.KeyBindRGLA)
  ZO_CreateStringId("SI_BINDING_NAME_WPAMARGLASRT", self.i18n.KeyBindRGLASrt)
  ZO_CreateStringId("SI_BINDING_NAME_WPAMARGLASTP", self.i18n.KeyBindRGLAStp)
  ZO_CreateStringId("SI_BINDING_NAME_WPAMARGLAPST", self.i18n.KeyBindRGLAPst)
  ZO_CreateStringId("SI_BINDING_NAME_WPAMARGLASHR", self.i18n.KeyBindRGLAShr)

-- Register Slash Command to show/hide addon window
  SLASH_COMMANDS["/wpa"] = function(cmd)
    if cmd == "" then
      self.TogleUI()
    elseif cmd == "td" or cmd == "today" then
      self:PostToChatTd()
    elseif cmd == "on" or cmd == "show" then
      self.ShowUI()
    elseif cmd == "off" or cmd == "hide" then
      self.HideUI()
    elseif cmd == "r" or cmd == "refresh" then
      self:FindUpdateQuests()
      self:UpdWindowInfo()
    elseif cmd == "ch" or cmd == "char" then
      SV.ShowMode = 0
      self:UpdWindowInfo()
      self.ShowUI()
    elseif cmd == "cl" or cmd == "calendar" then
      SV.ShowMode = 1
      self:UpdWindowInfo()
      self.ShowUI()
    elseif cmd == "rch" or cmd == "resetchar" then
      SV.CharsList = {}
      self:UpdCharInfo()
    elseif cmd == "n" or cmd == "name" then
      if SV.ShowLoc == true then
        SV.ShowLoc = false
        ZO_CheckButton_SetUnchecked(WPamA_OptLocation)
        self:UpdWindowInfo()
      end
    elseif cmd == "l" or cmd == "location" then
      if SV.ShowLoc == false then
        SV.ShowLoc = true
        ZO_CheckButton_SetChecked(WPamA_OptLocation)
        self:UpdWindowInfo()
      end
    elseif cmd == "ts" or cmd == "timestamp" then
      msg("TimeStamp: " .. GetTimeStamp())
    elseif cmd == "dbgon" then
      self.IsDebugMode = true
      msg("Debug on")
    elseif cmd == "dbgoff" then
      self.IsDebugMode = false
      msg("Debug off")
    elseif cmd == "dbgclr" then
      SV.Debug = {}
      msg("The debug buffer is cleared")
    elseif cmd == "qdump" then
      self:QDump()
    end
  end
  SLASH_COMMANDS["/rgla"] = function(cmd)
    if cmd == "" then
      self.TogleRGLA()
    elseif cmd == "on" or cmd == "show" then
      self.ShowRGLA()
    elseif cmd == "off" or cmd == "hide" then
      self.HideRGLA()
    elseif cmd == "s" or cmd == "start" then
      self.OnRGLAStartClick()
    elseif cmd == "t" or cmd == "stop" then
      self.OnRGLAStopClick()
    elseif cmd == "p" or cmd == "post" then
      self.OnRGLAMsgClick(1)
    end
  end
end

-- ==== EVENT FUNCTIONS ==== --
-- Function header in this section must use "." instead ":".
-- Also inside the function can not be used "self".
-- Instead, it must explicitly specify the variable
function WPamA.OnLevelUpdate(_eventCode, _unitTag, _level)
--  if _unitTag = "player" then
  local bakVet = WPamA.savedVars.CharsList[WPamA.CharNum].Veteran
  local bakLvl = WPamA.savedVars.CharsList[WPamA.CharNum].Lvl
  WPamA:UpdPlayerLvl()
  if bakVet ~= WPamA.savedVars.CharsList[WPamA.CharNum].Veteran or bakLvl ~= WPamA.savedVars.CharsList[WPamA.CharNum].Lvl then
    WPamA:UpdWindowInfo()
  end
--  end
end

function WPamA.ShowUI()
  WPamA_Win:SetHidden(false)
  WPamA.savedVars.WinMain.s = true
  if WPamA.ShowMsg and WPamA_Msg ~= nil then
    WPamA_Msg:SetHidden(false)
  end
end 

function WPamA.HideUI()
  WPamA_Win:SetHidden(true)
  WPamA.savedVars.WinMain.s = false
  if WPamA_Opt ~= nil then
    WPamA_Opt:SetHidden(true)
  end
  if WPamA_Msg ~= nil then
    WPamA_Msg:SetHidden(true)
  end
end 

function WPamA.TogleUI()
  if WPamA_Win:IsHidden() then
    WPamA.ShowUI()
  else
    WPamA.HideUI()
  end
end 

function WPamA.OnWindowMoveStop()
  WPamA:SavePosition(WPamA_Win, WPamA.savedVars.WinMain)
end 

function WPamA.OnWinRGLAMoveStop()
  WPamA:SavePosition(WPamA_RGLA, WPamA.savedVars.WinRGLA)
end 

function WPamA.ShowRGLA()
  WPamA:UpdRGLAInfo()
  WPamA_RGLA:SetHidden(false)
end 

function WPamA.HideRGLA()
  WPamA_RGLA:SetHidden(true)
  WPamA_RGLA_Opt:SetHidden(true)
  WPamA_RGLA_Msg:SetHidden(true)
end 

function WPamA.TogleRGLA()
  if WPamA_RGLA:IsHidden() then
    WPamA.ShowRGLA()
  else
    WPamA.HideRGLA()
  end
end 

function WPamA.OnRGLAStartClick()
  if not WPamA.RGLA_Started then
    WPamA.RGLA_Started = WPamA:TryRGLAStart()
    WPamA:UpdRGLAInfo()
  end
end 

function WPamA.OnRGLAMsgClick(var)
  if var >= 7 or WPamA.RGLA_Started or (var == 6 and WPamA:GetCurrentWrBoss() ~= 0 and WPamA:IsWrothgarLocation()) then 

    -- For JP Client
    if WPamA.JP then
      WPamA:PostToChatRGLAJp(var)
    else
      WPamA:PostToChatRGLA(var)
    end

    WPamA_RGLA_Msg:SetHidden(true)
  end
end

function WPamA.OnRGLAStopClick()
  if WPamA.RGLA_Started then
    WPamA:RGLAStop()
  end
end 

function WPamA.OnGroupMemberJoined()
  if WPamA.RGLA_Started and WPamA.RGLA_QuestJI ~= nil and WPamA.RGLA_QuestJI > 0 and WPamA.savedVars.AutoShare then
    WPamA:ShareQuest(WPamA.RGLA_QuestJI)
  end
end

function WPamA.OnRGLAShareClick()
  local ji = WPamA:GetWWBJournalIndex(WPamA:GetCurrentWrBoss())
  if ji == 0 then
    msg(WPamA.i18n.RGLA_ErrQuest)
  elseif IsUnitGrouped("player") then
    WPamA:ShareQuest(ji)
  end
end 

function WPamA.OnRGLAAutoShareClick(checkButton, isChecked)
  WPamA.savedVars.AutoShare = isChecked
end

function WPamA.OnRGLAQAlertClick(checkButton, isChecked)
  WPamA.savedVars.QAlert = isChecked
end

function WPamA.OnRGLAQChatClick(checkButton, isChecked)
  WPamA.savedVars.QChat = isChecked
end

function WPamA.OnRGLABossKilledClick(checkButton, isChecked)
  WPamA.savedVars.BossKilled = isChecked
end

function WPamA.ShowHideRGLAOptions()
  if WPamA_RGLA_Opt:IsHidden() then
    local hld = WPamA.savedVars.WinRGLA
    if hld ~= nil and hld.m ~= nil then
      WPamA_RGLA_Opt:ClearAnchors()
      if hld.m == 3 or hld.m == 4 then
        WPamA_RGLA_Opt:SetAnchor(BOTTOMLEFT, WPamA_RGLA, TOPLEFT, 0, -18)
      else
        WPamA_RGLA_Opt:SetAnchor(TOPLEFT, WPamA_RGLA, BOTTOMLEFT, 0, 18)
      end
    end
    WPamA_RGLA_Opt:SetHidden(false)
  else
    WPamA_RGLA_Opt:SetHidden(true)
  end
end

function WPamA.RGLAMsgTxtColor(ctrl, num, isHighlighted)
  local clr = WPamA.Colors
  local cl = clr.MenuEnabled
  if num >= 7 then
    if isHighlighted then cl = clr.MenuActive end
  elseif num == 6 then
    if WPamA:GetCurrentWrBoss() == 0 or not WPamA:IsWrothgarLocation() then
      cl = clr.MenuDisabled
    elseif isHighlighted then
      cl = clr.MenuActive 
    end
  else
    if not WPamA.RGLA_Started then
      cl = clr.MenuDisabled
    elseif isHighlighted then
      cl = clr.MenuActive 
    end
  end
  ctrl:SetColor(WPamA:GetColor(cl))
end

function WPamA.OnRGLASelectMsgClick()
  if WPamA_RGLA_Msg:IsHidden() then
    local hld = WPamA.savedVars.WinRGLA
    if hld ~= nil and hld.m ~= nil then
      WPamA_RGLA_Msg:ClearAnchors()
      if hld.m == 3 or hld.m == 4 then
        WPamA_RGLA_Msg:SetAnchor(BOTTOMLEFT, WPamA_RGLAPost, BOTTOMRIGHT, 0, -4)
      else
        WPamA_RGLA_Msg:SetAnchor(TOPLEFT, WPamA_RGLAPost, TOPRIGHT, 0, 0)
      end
    end
    for j=1,WPamA.Consts.RGLAMsgCnt do
      WPamA.RGLAMsgTxtColor(GetControl(WPamA_RGLA_Msg, "Txt" .. j), j, false)
    end
    WPamA_RGLA_Msg:SetHidden(false)
  else
    WPamA_RGLA_Msg:SetHidden(true)
  end
end

function WPamA.CheckChatMsg(txt, sarr)
  txt = txt:gsub(" ","") -- Del all space
  for i=1, #sarr do
    if txt:match(sarr[i]) then return true end
  end
  return false
end

function WPamA.OnChatMessage(eventCode, channelType, fromName, messageText, isCustomerService)
-- channelType: 0-say, 2-whisper, 3-party, 31-zone
  local txt = messageText:lower()
  local nam = fromName:gsub("%^.+", "")  -- "PlayerName^Mx" -> "PlayerName"
  if nam ~= WPamA.CharName then
    if channelType == 3 then
      if txt:match(WPamA.EN.ShareSubstr) then
        WPamA.OnGroupMemberJoined()
      end
    elseif nam ~= nil and nam ~= "" then
      local n = WPamA.CurChar.WrBoss[0]
      local b = WPamA.Consts.DailyBoss[n]
      -- Case when txt == b.S[1] will be processed inside the AutoInvite
      if txt ~= b.S[1] and WPamA.CheckChatMsg(txt, b.S) then
        if (channelType >= CHAT_CHANNEL_GUILD_1 and channelType <= CHAT_CHANNEL_OFFICER_5) or channelType == CHAT_CHANNEL_WHISPER then
          nam = AutoInvite.accountNameLookup(channelType, fromName)
          nam = nam:gsub("%^.+", "")
          if nam == nil or nam == "" then return end
        end
        
        if WPamA.JP then
          msg(zo_strformat(WPamA.i18n.SendInvTo, nam))
        else
	  msg(WPamA.i18n.SendInvTo .. nam)
	end
	    
        AutoInvite:invitePlayer(nam)
      end
    end
  end
end

function WPamA.OnUnitLeaderUpdate(eventCode, unitTag)
  if WPamA.RGLA_Started and IsUnitGrouped("player") and not IsUnitGroupLeader("player") then
    msg(WPamA.i18n.RGLALeaderChanged)
    WPamA:RGLAStop()
  end
end

function WPamA.ChangeUIMode(Mode)
  if Mode == nil then
    WPamA.savedVars.ShowMode = (WPamA.savedVars.ShowMode + 1) % 4
    WPamA:UpdWindowInfo()
    WPamA.ShowUI()
  else
    if WPamA.savedVars.ShowMode == Mode then
      WPamA.TogleUI()
    else
      WPamA.savedVars.ShowMode = Mode
      WPamA:UpdWindowInfo()
      WPamA.ShowUI()
    end
  end
end 

function WPamA.KeyPostChatTd()
  WPamA:PostToChatTd()
end 

function WPamA.OnQuestAdded(eventCode, journalIndex, questName, objectiveName)
--EVENT_QUEST_ADDED (integer eventCode, integer journalIndex, string questName, string objectiveName) 
  local _, _, _, _, activeStep, _, _, _, _, questType = GetJournalQuestInfo(journalIndex)
  --local questType = GetJournalQuestType(journalIndex)
  local isRepeat = GetJournalQuestRepeatType(journalIndex)
  WPamA:Debug("AddQ > QN: " .. questName .. "; JI: " .. journalIndex .. "; QT: " .. questType .. "; IR: " .. isRepeat .. "; AS: " .. activeStep .. "; EC: " .. eventCode)
  if isRepeat == 2 then
    if questType == 5 then  -- undaunted dailies
      WPamA:UpdatePledge(questName, true, "")
      WPamA:UpdWindowInfo()
    elseif questType == 1 then -- any quest include Wrothgar daily
      WPamA:ChkAddBossDailyQuests(questName)          
      WPamA:UpdWindowInfo()
    end
  end
end

function WPamA.OnQuestRemoved(eventCode, isCompleted, journalIndex, questName, zoneIndex, poiIndex)
--EVENT_QUEST_REMOVED (integer eventCode, bool isCompleted, integer journalIndex, string questName, integer zoneIndex, integer poiIndex)
  local questType = GetJournalQuestType(journalIndex)
  local isRepeat = GetJournalQuestRepeatType(journalIndex)
  WPamA:Debug("RemQ > QN: " .. questName .. "; JI: " .. journalIndex .. "; QT: " .. questType .. "; IR: " .. isRepeat .. "; Done: " .. BoolToStr(isCompleted) .. "; EC: " .. eventCode)
  WPamA:CloseQuest(isCompleted, questName)
  WPamA:FindUpdateQuests()
  WPamA:UpdWindowInfo()
end

function WPamA.OnQuestAdvanced(eventCode, journalIndex, questName, isPushed, isComplete, mainStepChanged)
--EVENT_QUEST_ADVANCED (integer eventCode, integer journalIndex, string questName, bool isPushed, bool isComplete, bool mainStepChanged)
  local _, _, _, _, activeStep, _, _, _, _, questType = GetJournalQuestInfo(journalIndex)
  local isRepeat = GetJournalQuestRepeatType(journalIndex)
  WPamA:Debug("AdvQ > QN: " .. questName .. "; JI: " .. journalIndex .. "; QT: " .. questType .. "; IR: " .. isRepeat .. "; AS: " .. activeStep .. "; EC: " .. eventCode)
  if questType == 5 and isRepeat == 2 then  -- undaunted dailies
    WPamA:UpdatePledge(questName, false, activeStep)
    WPamA:UpdWindowInfo()
  end
end

function WPamA.OnChmpGained(eventCode)
-- EVENT_CHAMPION_POINT_GAINED (integer eventCode)
  WPamA.ChmPoints = GetPlayerChampionPointsEarned()
  WPamA:UpdWindowHdrInfo(true)
end

function WPamA.OnQCondChanged(eventCode, journalIndex, questName, conditionText, conditionType, currConditionVal, newConditionVal, conditionMax, isFailCondition, stepOverrideText, isPushed, isComplete, isConditionComplete, isStepHidden)
  if WPamA.savedVars.BossKilled and journalIndex == WPamA.RGLA_QuestJI then -- this quest from RGLA
    if isConditionComplete and (not isStepHidden) and (conditionMax == 1) then
      msg(WPamA.i18n.RGLABossKilled)
      WPamA:RGLAStop()
    end
  end
end

function WPamA.ShowHideOptions()
  if WPamA_Opt:IsHidden() then
    WPamA_Opt:SetHidden(false)
  else
    WPamA_Opt:SetHidden(true)
  end
end

function WPamA.SwapWindowMode()
  if WPamA.savedVars.ShowMode == nil then
    WPamA.savedVars.ShowMode = 0
  else
    WPamA.savedVars.ShowMode = (WPamA.savedVars.ShowMode + 1) % 4
  end
  WPamA:UpdWindowInfo()
  WPamA.ShowUI()
end

function WPamA.OnOptionsResetClick()
  WPamA.savedVars.CharsList = {}
  WPamA:UpdCharInfo()
end

function WPamA.OnOptionsLocClick(checkButton, isChecked)
--local isChecked = ZO_CheckButton_IsChecked(WPamA_OptLocation)
  if WPamA.savedVars.ShowLoc ~= isChecked then
    WPamA.savedVars.ShowLoc = isChecked
    WPamA:UpdWindowInfo()
  end
end

function WPamA.OnOptionsENDungClick(checkButton, isChecked)
  if WPamA.savedVars.ENDung ~= isChecked then
    WPamA.savedVars.ENDung = isChecked
    WPamA:UpdWindowInfo()
  end
end

function WPamA.OnOptionsDontShowNoneClick(checkButton, isChecked)
  if WPamA.savedVars.DontShowNone ~= isChecked then
    WPamA.savedVars.DontShowNone = isChecked
    WPamA:UpdWindowInfo()
  end
end

function WPamA.OnOptionsTitleToolTip(checkButton, isChecked)
  if WPamA.savedVars.TitleToolTip ~= isChecked then
    WPamA.savedVars.TitleToolTip = isChecked
    WPamA:UpdWindowInfo(true)
  end
end

function WPamA.OnEnlitGained(eventCode)
-- EVENT_ENLIGHTENED_STATE_GAINED (integer eventCode)
--  if IsEnlightenedAvailableForAccount() then
    WPamA.EnlitState = true
    WPamA:UpdWindowHdrInfo(true)
--  end
end

function WPamA.OnEnlitLost(eventCode)
-- EVENT_ENLIGHTENED_STATE_LOST (integer eventCode)
--  if IsEnlightenedAvailableForAccount() then
    WPamA.EnlitState = false
    WPamA:UpdWindowHdrInfo(true)
--  end
end

function WPamA.OnInvtUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, updateReason)
  if bagId == BAG_BACKPACK then
    local itemType = GetItemType(bagId, slotId)
    if itemType == ITEMTYPE_NONE or itemType == ITEMTYPE_TROPHY or itemType == ITEMTYPE_TOOL or itemType == ITEMTYPE_SOUL_GEM then
      WPamA:UpdInvtItems()
      if WPamA.savedVars.ShowMode == 3 then
        WPamA:UpdInvtWindowInfo()
      end
    end
  end
end

function WPamA.OnAddOnLoaded(event, addonName)
  if addonName == WPamA.Name then
    WPamA:Initialize()
    EVENT_MANAGER:RegisterForEvent(WPamA.Name, EVENT_LEVEL_UPDATE, WPamA.OnLevelUpdate)
    EVENT_MANAGER:RegisterForEvent(WPamA.Name, EVENT_QUEST_ADDED, WPamA.OnQuestAdded)
    EVENT_MANAGER:RegisterForEvent(WPamA.Name, EVENT_QUEST_REMOVED, WPamA.OnQuestRemoved)
    EVENT_MANAGER:RegisterForEvent(WPamA.Name, EVENT_QUEST_ADVANCED, WPamA.OnQuestAdvanced)
    EVENT_MANAGER:RegisterForEvent(WPamA.Name, EVENT_LOGOUT_DEFERRED, WPamA.OnRGLAStopClick)
    EVENT_MANAGER:RegisterForEvent(WPamA.Name, EVENT_LOGOUT_DISALLOWED, WPamA.OnRGLAStopClick)
    EVENT_MANAGER:RegisterForEvent(WPamA.Name, EVENT_CHAMPION_POINT_GAINED, WPamA.OnChmpGained)
    EVENT_MANAGER:RegisterForEvent(WPamA.Name, EVENT_ENLIGHTENED_STATE_GAINED, WPamA.OnEnlitGained)
    EVENT_MANAGER:RegisterForEvent(WPamA.Name, EVENT_ENLIGHTENED_STATE_LOST, WPamA.OnEnlitLost)
    EVENT_MANAGER:RegisterForEvent(WPamA.Name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, WPamA.OnInvtUpdate)
    EVENT_MANAGER:UnregisterForEvent(WPamA.Name, EVENT_ADD_ON_LOADED)
  end
end
 
EVENT_MANAGER:RegisterForEvent(WPamA.Name, EVENT_ADD_ON_LOADED, WPamA.OnAddOnLoaded)