DungeonFinderPlus = DungeonFinderPlus or {}
local DFP = DungeonFinderPlus

DFP.Update = DFP.Update or {}


local function FullRefresh()
  if not (DFP and DFP.Finder) then return end
  DFP.Finder:EnsureInit()
  DFP.Finder:RebuildData()
  if DFP.sv and DFP.sv.lastSearch then
    DFP.Finder:SetSearchText(DFP.sv.lastSearch)
  end
end

-- debounce 
local _pending = false
local function ScheduleRefresh()
  if _pending then return end
  _pending = true
  zo_callLater(function()
    _pending = false
    FullRefresh()
  end, 50)
end

function DFP.Update.RefreshList()
  ScheduleRefresh()
end


local function onPlayerActivated()
  EVENT_MANAGER:UnregisterForEvent("DFP_Update_OnPA", EVENT_PLAYER_ACTIVATED)
  FullRefresh()
end

function DFP.Update.RegisterEvents()
  if not EVENT_MANAGER then return end
  -- einmaliger Full-Refresh nach Login / Zonenwechsel
  EVENT_MANAGER:RegisterForEvent("DFP_Update_OnPA", EVENT_PLAYER_ACTIVATED, onPlayerActivated)

  -- Status-Änderungen
  if _G.EVENT_GROUP_FINDER_STATUS_UPDATED then
    EVENT_MANAGER:RegisterForEvent("DFP_Update_OnGF", EVENT_GROUP_FINDER_STATUS_UPDATED, ScheduleRefresh)
  end
end

function DFP.Update.UnregisterEvents()
  if not EVENT_MANAGER then return end
  EVENT_MANAGER:UnregisterForEvent("DFP_Update_OnPA", EVENT_PLAYER_ACTIVATED)
  if _G.EVENT_GROUP_FINDER_STATUS_UPDATED then
    EVENT_MANAGER:UnregisterForEvent("DFP_Update_OnGF", EVENT_GROUP_FINDER_STATUS_UPDATED)
  end
end

