DungeonFinderPlus = DungeonFinderPlus or {}
local DFP = DungeonFinderPlus

-- ───────────────── Normalisierung ─────────────────
local function foldLatin(s)
  if not s then return "" end
  return s
    :gsub("Ä","Ae"):gsub("Ö","Oe"):gsub("Ü","Ue")
    :gsub("ä","ae"):gsub("ö","oe"):gsub("ü","ue")
    :gsub("ß","ss")
end

local function n1(s)
  if not s then return "" end
  s = foldLatin(s)
  s = s:gsub("—","-"):gsub("–","-")
  s = s:gsub("^%s*[-:%·•]+%s*", "")          -- vorne Deko
  s = s:gsub("%s*[-:%·•]+%s*$", "")          -- hinten Deko
  s = s:gsub("%b()", ""):gsub("[%[%]]","")   -- Klammern weg
  s = s:gsub("[%s%-:]+([IVXivx]+)$", " %1")
  s = s:gsub("%s+", " ")
  return zo_strlower(zo_strtrim(s))
end


-- ───────── Whitelist: nur die echten Pledge-Geber ─────────
local NAME_ALLOW = (function()
  local list = {
    -- DE
    "glirion der rotbart",
    "maj al-ragath",
    "urgarlag häuptlingsfluch","urgarlag haeuptlingsfluch",
    -- EN
    "glirion the redbeard",
    "maj al-ragath",
    "urgarlag chief-bane","urgarlag chief bane",
    -- FR
    "glirion barbe-rousse","glirion barbe rousse",
    "maj al-ragath",
    "urgarlag l’évmasculatrice","urgarlag l’émasculatrice","urgarlag l'emasculatrice",
    -- ES
    "glirion el barbarroja",
    "maj al-ragath",
    "urgarlag la castradora",
    -- RU
    "глирион краснобородый","глирион рыжебородый",
    "мадж аль-рагат",
    "ургарлаг бич вождей",
    -- JP
    "族長殺しのウルガルラグ",
  }
  local t = {}
  for _,v in ipairs(list) do t[v] = true end
  return t
end)()

-- Nur UI-Title
local function getChatterName()
  if ZO_InteractWindowTargetAreaTitle and ZO_InteractWindowTargetAreaTitle.GetText then
    local s = ZO_InteractWindowTargetAreaTitle:GetText()
    if s and s ~= "" then return s end
  end
  if ZO_InteractWindow_GamepadTitle and ZO_InteractWindow_GamepadTitle.GetText then
    local s = ZO_InteractWindow_GamepadTitle:GetText()
    if s and s ~= "" then return s end
  end
  return ""
end

local function isUndauntedPledgeMaster()
  local raw = getChatterName()
  if raw == "" then return false end
  local who = n1(raw)
  return NAME_ALLOW[who] == true
end

-- ───────── Neuer Filter: Background-Text muss Pledgegeber enthalten ─────────
local function backgroundHasPledgeMaster(qIndex)
  if type(GetJournalQuestInfo) ~= "function" then return false end
  local _, bgText = GetJournalQuestInfo(qIndex)
  if not (bgText and bgText ~= "") then return false end
  local s = n1(bgText)
  for pname,_ in pairs(NAME_ALLOW) do
    if s:find(pname, 1, true) then
      return true
    end
  end
  return false
end


-- ───────────────── UI schließen ─────────────────
local function closeChatterSoon(ms)
  zo_callLater(function()
    if type(CloseChatter)=="function" then CloseChatter() end
    if type(GetInteractionType)=="function" and type(EndInteraction)=="function" then
      local it = GetInteractionType()
      if it ~= nil then EndInteraction(it) end
    end
  end, ms or 120)
end

-- ───────────────── Quest-Flow ─────────────────
local function onQuestCompleteDialog()
  if DFP.sv and DFP.sv.autoPledge and DFP.sv.autoPledge.enabled then
    if type(CompleteQuest)=="function" then CompleteQuest() end
  end
end

local function finalizeAfterTurnIn()
  closeChatterSoon(120)
  EVENT_MANAGER:UnregisterForEvent("DFP_P_QDlg",EVENT_QUEST_COMPLETE_DIALOG)
  EVENT_MANAGER:UnregisterForEvent("DFP_P_QFin",EVENT_QUEST_COMPLETE)
  EVENT_MANAGER:UnregisterForEvent("DFP_P_QRem",EVENT_QUEST_REMOVED)
end

local function onQuestCompleted() finalizeAfterTurnIn() end
local function onQuestRemoved()  finalizeAfterTurnIn() end

local function onQuestOffered()
  if DFP.sv and DFP.sv.autoPledge and DFP.sv.autoPledge.enabled then
    if type(AcceptOfferedQuest)=="function" then AcceptOfferedQuest() end
  end
end

local function onQuestAdded()
  closeChatterSoon(120)
  EVENT_MANAGER:UnregisterForEvent("DFP_P_QOff",EVENT_QUEST_OFFERED)
  EVENT_MANAGER:UnregisterForEvent("DFP_P_QAdd",EVENT_QUEST_ADDED)
end

-- ───────────────── Chatter-Handler ─────────────────
local function onChatterBegin(_, count)
  if not (DFP and DFP.sv and DFP.sv.autoPledge and DFP.sv.autoPledge.enabled) then return end
  if (count or 0) == 0 then return end
  if not isUndauntedPledgeMaster() then return end
  if type(GetChatterOption)~="function" or type(SelectChatterOption)~="function" then return end

  local idxAccept, idxComplete
  for i=1,count do
    local _, optType = GetChatterOption(i)
    if optType == CHATTER_COMPLETE_QUEST and not idxComplete then
      idxComplete = i
    elseif optType == CHATTER_START_NEW_QUEST_BESTOWAL and not idxAccept then
      idxAccept = i
    end
  end

  if idxComplete then
    EVENT_MANAGER:RegisterForEvent("DFP_P_QDlg",EVENT_QUEST_COMPLETE_DIALOG,onQuestCompleteDialog)
    EVENT_MANAGER:RegisterForEvent("DFP_P_QFin",EVENT_QUEST_COMPLETE,onQuestCompleted)
    EVENT_MANAGER:RegisterForEvent("DFP_P_QRem",EVENT_QUEST_REMOVED,onQuestRemoved)
    SelectChatterOption(idxComplete)
    return
  end

  if idxAccept then
    EVENT_MANAGER:RegisterForEvent("DFP_P_QOff",EVENT_QUEST_OFFERED,onQuestOffered)
    EVENT_MANAGER:RegisterForEvent("DFP_P_QAdd",EVENT_QUEST_ADDED,onQuestAdded)
    SelectChatterOption(idxAccept)
    return
  end
end

-- ───────────────── Registrierung ─────────────────
if EVENT_MANAGER and EVENT_CHATTER_BEGIN then
  EVENT_MANAGER:RegisterForEvent("DFP_P_Chatter",EVENT_CHATTER_BEGIN,onChatterBegin)
end

-- Pledges auslesen
DFP.Pledges = DFP.Pledges or { active = {} }

local _n = n1

-- schneller UI-Refresh
local function ScheduleUIRefresh()
  if DFP._pledgeUIRefreshPending then return end
  DFP._pledgeUIRefreshPending = true
  zo_callLater(function()
    DFP._pledgeUIRefreshPending = false
    if DFP.Finder and type(DFP.Finder.QuickPledgeUpdate)=="function" then
      DFP.Finder:QuickPledgeUpdate()
    elseif DFP.Finder and type(DFP.Finder.RebuildAndRefresh)=="function" then
      DFP.Finder:RebuildAndRefresh()
    end
  end, 50)
end

local function EnsureDungeonNameIndex()
  if DFP._dungeonNameIndex then return end
  local m = {}
  if DFP.Dungeons and DFP.Dungeons.Iter then
    for _, d in DFP.Dungeons:Iter() do
      if d and d.pretty then
        local key = _n(d.pretty)
        if key ~= "" then
          m[key] = true
        end
      end
    end
  end
  DFP._dungeonNameIndex = m
end

local PLEDGE_PREFIXES = {
  "gelobnis","geluebnis","gelöbnis",
  "undaunted pledge",
  "serment des indomptables",
  "promesa de los indomables",
  "обет","клятва",
  "誓い",
}

local function stripPledgePrefix(qname)
  local s = _n(qname or "")
  for _,p in ipairs(PLEDGE_PREFIXES) do
    if s:find(p, 1, true) == 1 then
      s = s:gsub("^"..p.."%s*[:%-–—]%s*", "")
      break
    end
  end
  return s
end

local function findDungeonInText(text)
  if not text or text == "" then return nil end
  local norm_text = _n(text)
  
  EnsureDungeonNameIndex()
  local idx = DFP._dungeonNameIndex
  if not idx then return nil end
  
  for dungeon_key, _ in pairs(idx) do
    if norm_text:find(dungeon_key, 1, true) then
      return dungeon_key
    end
  end
  
  local text_has_roman = norm_text:match("%s[iI][iI]?$")
  if text_has_roman then

    return nil
  end
  
  for dungeon_key, _ in pairs(idx) do
    local dungeon_has_roman = dungeon_key:match("%s[iI][iI]?$")
    if not dungeon_has_roman then
      if norm_text:find(dungeon_key, 1, true) then
        return dungeon_key
      end
    end
  end
  
  return nil
end


function DFP.Pledges:ScanJournal()
  EnsureDungeonNameIndex()
  local pledges = {}
  local getNum = type(GetNumJournalQuests)=="function" and GetNumJournalQuests() or 25

  for qi = 1, getNum do
    local qName = select(1, GetJournalQuestInfo(qi))
    if qName and qName ~= "" then
      local cleaned = stripPledgePrefix(qName)
      local hit = findDungeonInText(cleaned)

      if not hit and type(GetJournalQuestNumSteps)=="function" and type(GetJournalQuestStepInfo)=="function" then
        local numSteps = GetJournalQuestNumSteps(qi) or 0
        for si = 1, numSteps do
          local stepText = select(1, GetJournalQuestStepInfo(qi, si))
          if stepText and stepText~="" then
            hit = findDungeonInText(stepText)
            if hit then break end
          end
          if type(GetJournalQuestNumConditions)=="function" and type(GetJournalQuestConditionInfo)=="function" then
            local numCond = GetJournalQuestNumConditions(qi, si) or 0
            for ci = 1, numCond do
              local cText = select(1, GetJournalQuestConditionInfo(qi, si, ci))
              if cText and cText~="" then
                hit = findDungeonInText(cText)
                if hit then break end
              end
            end
            if hit then break end
          end
        end
      end

      -- Nur als Pledge zählen, wenn der Background-Text auch den Namen eines Pledgegebers enthält.
      if hit and backgroundHasPledgeMaster(qi) then
        pledges[hit] = true
      end
    end
  end

  self.active = pledges
  ScheduleUIRefresh()
end

-- Journal-Events bündeln (Debounce 50ms)
local function DebouncedScan()
  if DFP._pledgeScanPending then return end
  DFP._pledgeScanPending = true
  zo_callLater(function()
    DFP._pledgeScanPending = false
    if DFP and DFP.Pledges and DFP.Pledges.ScanJournal then
      DFP.Pledges:ScanJournal()
    end
  end, 50)
end

function DFP.Pledges.RegisterEvents()
  if not EVENT_MANAGER then return end
  EVENT_MANAGER:RegisterForEvent("DFP_P_QAddedScan",      EVENT_QUEST_ADDED,                        DebouncedScan)
  EVENT_MANAGER:RegisterForEvent("DFP_P_QRemovedScan",    EVENT_QUEST_REMOVED,                      DebouncedScan)
  EVENT_MANAGER:RegisterForEvent("DFP_P_QCompletedScan",  EVENT_QUEST_COMPLETE,                     DebouncedScan)
  if _G.EVENT_QUEST_ADVANCED then
    EVENT_MANAGER:RegisterForEvent("DFP_P_QAdvancedScan", EVENT_QUEST_ADVANCED,                      DebouncedScan)
  end
  if _G.EVENT_QUEST_CONDITION_COUNTER_CHANGED then
    EVENT_MANAGER:RegisterForEvent("DFP_P_QCondChanged",  EVENT_QUEST_CONDITION_COUNTER_CHANGED,     DebouncedScan)
  end
  EVENT_MANAGER:RegisterForEvent("DFP_P_PlayerActivatedScan", EVENT_PLAYER_ACTIVATED, function()
    EVENT_MANAGER:UnregisterForEvent("DFP_P_PlayerActivatedScan", EVENT_PLAYER_ACTIVATED)
    DebouncedScan()
  end)
end

function DFP.Pledges.UnregisterEvents()
  if not EVENT_MANAGER then return end
  EVENT_MANAGER:UnregisterForEvent("DFP_P_QAddedScan",      EVENT_QUEST_ADDED)
  EVENT_MANAGER:UnregisterForEvent("DFP_P_QRemovedScan",    EVENT_QUEST_REMOVED)
  EVENT_MANAGER:UnregisterForEvent("DFP_P_QCompletedScan",  EVENT_QUEST_COMPLETE)
  if _G.EVENT_QUEST_ADVANCED then
    EVENT_MANAGER:UnregisterForEvent("DFP_P_QAdvancedScan", EVENT_QUEST_ADVANCED)
  end
  if _G.EVENT_QUEST_CONDITION_COUNTER_CHANGED then
    EVENT_MANAGER:UnregisterForEvent("DFP_P_QCondChanged",  EVENT_QUEST_CONDITION_COUNTER_CHANGED)
  end
  EVENT_MANAGER:UnregisterForEvent("DFP_P_PlayerActivatedScan", EVENT_PLAYER_ACTIVATED)
end
