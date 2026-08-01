Nvk3UT = Nvk3UT or {}

Nvk3UT.UI = Nvk3UT.UI or {}
local D = Nvk3UT.Diagnostics
local M = {}
Nvk3UT.UI = M

-- Apply toggles (no re-hooking). Only refresh UI/status.
function M.ApplyFeatureToggles()
  -- Update status first and only once
  if Nvk3UT and Nvk3UT.UI and Nvk3UT.UI.UpdateStatus then
    Nvk3UT.UI.UpdateStatus()
  end

  local SM = SCENE_MANAGER
  local ach = (SYSTEMS and SYSTEMS.GetObject and SYSTEMS:GetObject("achievements")) or ACHIEVEMENTS
  local isShowing = SM and SM.IsShowing and SM:IsShowing("achievements")

  if isShowing then
    -- Hard rebuild by briefly closing and re-opening the scene
    SM:Hide("achievements")
    zo_callLater(function()
      SM:Show("achievements")
    end, 50)
  else
    -- Soft refresh so the next open is up-to-date
    if ach and ach.refreshGroups then
      ach.refreshGroups:RefreshAll("FullUpdate")
    end
  end
  -- Toggle category tooltips
  if Nvk3UT and Nvk3UT.Tooltips and Nvk3UT.Tooltips.Enable then
    local general = Nvk3UT.sv and Nvk3UT.sv.General
    local features = general and general.features or (Nvk3UT.sv and Nvk3UT.sv.features)
    local on = features and (features.tooltips ~= false)
    Nvk3UT.Tooltips.Enable(on)
  end
end


-- Refresh the achievements lists to reflect data changes immediately.
function M.RefreshAchievements()
  local ach = (SYSTEMS and SYSTEMS.GetObject and SYSTEMS:GetObject("achievements")) or ACHIEVEMENTS
  if not ach then
    return
  end
  if ach.refreshGroups then
    ach.refreshGroups:RefreshAll("FullUpdate")
  end
  local Rebuild = Nvk3UT and Nvk3UT.Rebuild
  if Rebuild and Rebuild.ForceAchievementRefresh then
    Rebuild.ForceAchievementRefresh("UI.RefreshAchievements")
  end
end

local TITLE = "Nvk3's Ultimate Tracker"

local function ensureStatusLabel()
  local parent = _G["ZO_CompassFrame"] or _G["ZO_Compass"] or GuiRoot
  if not Nvk3UT._status then
    local ctl = WINDOW_MANAGER:CreateControl("Nvk3UT_Status", parent, CT_LABEL)
    ctl:SetFont("ZoFontGameSmall")
    ctl:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, -18)
    Nvk3UT._status = ctl
  end
  return Nvk3UT._status
end
M.GetStatusLabel = ensureStatusLabel

local function Nvk3UT_UI_ComputeCounts()
  local total, done = 0, 0
  local numCats = GetNumAchievementCategories and GetNumAchievementCategories() or 0
  for top = 1, numCats do
    local _, numSub, numAch = GetAchievementCategoryInfo(top)
    if numAch and numAch > 0 then
      for a = 1, numAch do
        local id = GetAchievementId(top, nil, a)
        local _, _, _, _, completed = GetAchievementInfo(id)
        total = total + 1
        if completed then
          done = done + 1
        end
      end
    end
    for sub = 1, (numSub or 0) do
      local _, numAch2 = GetAchievementSubCategoryInfo(top, sub)
      if numAch2 and numAch2 > 0 then
        for a = 1, numAch2 do
          local id = GetAchievementId(top, sub, a)
          local _, _, _, _, completed = GetAchievementInfo(id)
          total = total + 1
          if completed then
            done = done + 1
          end
        end
      end
    end
  end
  return done, total
end
function M.BuildLAM()
  if Nvk3UT.LAM and Nvk3UT.LAM.Build then
    Nvk3UT.LAM.Build(TITLE)
  end
end

local function __nvk3_IsOn(key)
  local sv = Nvk3UT and Nvk3UT.sv
  local general = sv and sv.General
  local features = general and general.features or (sv and sv.features)
  return features and features[key] == true
end

local function __nvk3_CountFavorites()
  local Fav = Nvk3UT and Nvk3UT.FavoritesData
  if not Fav or not Fav.GetAllFavorites then
    return 0
  end
  local sv = Nvk3UT and Nvk3UT.sv
  local general = sv and sv.General
  local scope = (general and general.favScope) or "account"
  local n = 0
  local iterator, state, key = Fav.GetAllFavorites(scope)
  if type(iterator) ~= "function" then
    return 0
  end
  for _, flagged in iterator, state, key do
    if flagged then
      n = n + 1
    end
  end
  return n
end

local function __nvk3_CountRecent()
  local RD = Nvk3UT and Nvk3UT.RecentData
  if not RD then
    return 0
  end
  if RD.CountConfigured then
    return RD.CountConfigured()
  end
  if RD.ListConfigured then
    local l = RD.ListConfigured()
    return type(l) == "table" and #l or 0
  end
  return 0
end

local function __nvk3_CountTodo()
  local TD = Nvk3UT and Nvk3UT.TodoData
  if not TD then
    return 0
  end
  if TD.CountOpen then
    return TD.CountOpen()
  end
  if TD.ListAllOpen then
    local list = TD.ListAllOpen(999999, false)
    return type(list) == "table" and #list or 0
  end
  return 0
end

local QUEST_LOG_LIMIT = 25

local function __nvk3_IsQuestTrackerEnabled()
  local trackerModule = Nvk3UT and Nvk3UT.QuestTracker
  if trackerModule and trackerModule.IsActive then
    return trackerModule.IsActive()
  end

  local sv = Nvk3UT and Nvk3UT.sv
  local tracker = sv and sv.QuestTracker
  if tracker and tracker.active == false then
    return false
  end
  return true
end

local function __nvk3_GetQuestCountForTracker()
  local QuestModel = Nvk3UT and Nvk3UT.QuestModel
  if QuestModel and QuestModel.GetSnapshot then
    local snapshot = QuestModel.GetSnapshot()
    local quests = snapshot and snapshot.quests
    if type(quests) == "table" then
      local count = #quests
      count = math.min(math.max(count, 0), QUEST_LOG_LIMIT)
      return count
    end
  end

  local apiCount = 0
  if GetNumJournalQuests then
    local total = GetNumJournalQuests() or 0
    apiCount = math.min(math.max(total, 0), QUEST_LOG_LIMIT)
  end

  return apiCount
end

local function __nvk3_BuildQuestStatusPart()
  if not __nvk3_IsQuestTrackerEnabled() then
    return nil
  end

  local count = __nvk3_GetQuestCountForTracker()
  return zo_strformat(GetString(SI_NVK3UT_STATUS_TEXT_QUEST_PROGRESS), count, QUEST_LOG_LIMIT)
end

local function __nvk3_BuildStatusParts()
  local parts = {}

  local questPart = __nvk3_BuildQuestStatusPart()
  if questPart then
    parts[#parts + 1] = questPart
  end

  -- Abgeschlossen zuerst
  if __nvk3_IsOn("completed") then
    if Nvk3UT_UI_ComputeCounts then
      local done, total = Nvk3UT_UI_ComputeCounts()
      parts[#parts + 1] = zo_strformat(GetString(SI_NVK3UT_STATUS_TEXT_COMPLETED_PROGRESS), done or 0, total or 0)
    end
  end

  if __nvk3_IsOn("favorites") then
    local n = __nvk3_CountFavorites()
    parts[#parts + 1] = zo_strformat(GetString(SI_NVK3UT_STATUS_TEXT_FAVORITES_COUNT), n)
  end

  if __nvk3_IsOn("recent") then
    local n = __nvk3_CountRecent()
    parts[#parts + 1] = zo_strformat(GetString(SI_NVK3UT_STATUS_TEXT_RECENT_COUNT), n)
  end

  if __nvk3_IsOn("todo") then
    local n = __nvk3_CountTodo()
    parts[#parts + 1] = zo_strformat(GetString(SI_NVK3UT_STATUS_TEXT_TODO_COUNT), n)
  end

  return parts
end

-- Patch/define UpdateStatus in module M or Nvk3UT.UI
do
  local ns = Nvk3UT and Nvk3UT.UI
  local function __nvk3_UpdateStatus_impl()
    if not (Nvk3UT and Nvk3UT.sv and Nvk3UT.sv.General) then
      return
    end
    local show = Nvk3UT.sv.General.showStatus ~= false
    local getLabel = (ns and ns.GetStatusLabel) or (M and M.GetStatusLabel)
    if not getLabel then
      return
    end
    local ctl = getLabel()
    if not ctl then
      return
    end

    local parts = __nvk3_BuildStatusParts()
    if (not show) or (#parts == 0) then
      ctl:SetHidden(true)
      ctl._nvk3_last = ""
      return
    end

    local headerText = GetString(SI_NVK3UT_STATUS_TEXT_HEADER)
    local header = (headerText and headerText ~= "" and ("|c66CCFF" .. headerText .. "|r  –  ")) or ""
    local txt = header .. table.concat(parts, "  •  ")
    if ctl._nvk3_last ~= txt then
      ctl:SetText(txt)
      ctl._nvk3_last = txt
    end
    ctl:SetHidden(false)
  end

  if ns then
    ns.UpdateStatus = __nvk3_UpdateStatus_impl
  elseif M then
    M.UpdateStatus = __nvk3_UpdateStatus_impl
  end
end
-- <<< NVK3UT v0.10.1
