-- ZoneMountSwitcher.lua
local ADDON_NAME = "ZoneMountSwitcher"

ZMS = ZMS or {}
ZMS.name = ADDON_NAME

-- =========================
-- =  Saved variables      =
-- =========================
local DEFAULTS = {
  accountWide = {
    -- NEW: lists of ids per group (randomly pick one on apply)
    groupToMountIds     = {},  -- ["NORDIC"]={ collectibleId, ... }
    groupToPetIds       = {},  -- ["NORDIC"]={ collectibleId, ... }
    -- legacy (will be migrated if found): groupToMountId, groupToPetId
    zoneIdsByGroup      = {},  -- ["NORDIC"]={ 41, 103, ... }
    defaultsVersion     = 0,
    debug               = false,
  }
}

-- =========================
-- =  Utils & i18n         =
-- =========================
local function L(id)
  local str = GetString(_G[id])
  return (str and str ~= "") and str or id
end

local function dlog(msg)
  if ZMS.saved and ZMS.saved.debug then
    d(("|c87CEEB[ZMS]|r %s"):format(tostring(msg)))
  end
end

local function ShallowCopy(t)
  local r = {}
  for k,v in pairs(t or {}) do
    if type(v) == "table" then
      local arr = {}
      for i=1,#v do arr[i]=v[i] end
      r[k]=arr
    else
      r[k]=v
    end
  end
  return r
end

local function MergeUnique(list, toAdd)
  list = list or {}
  local seen = {}
  for _,v in ipairs(list)  do seen[v]=true end
  for _,v in ipairs(toAdd or {}) do
    if not seen[v] then table.insert(list, v); seen[v]=true end
  end
  return list
end

local function AddIdToSet(t, key, id)
  if not id then return false end
  t[key] = t[key] or {}
  for _,v in ipairs(t[key]) do
    if v == id then return false end
  end
  table.insert(t[key], id)
  return true
end

local function TableIsEmpty(arr)
  return (type(arr) ~= "table") or (#arr == 0)
end

-- =========================
-- =  Group helpers        =
-- =========================
local function AllGroupKeys() return ZMS.GROUP_KEYS end
local function GroupDisplayName(key) return ZMS.GroupDisplayName(key) end

-- =========================
-- =  Zone helpers         =
-- =========================
local function GetCurrentZoneId()
  local zoneIndex = GetUnitZoneIndex("player")
  if zoneIndex and zoneIndex > 0 then
    local zid = GetZoneId(zoneIndex)
    if zid and zid > 0 then return zid end
  end
  local zoneId = select(1, GetUnitWorldPosition("player"))
  return zoneId or 0
end

-- =========================
-- =  Collectibles         =
-- =========================
local function IsCollectibleUnlockedSafe(collectibleId)
  if not collectibleId then return false end
  local ok = IsCollectibleUnlocked and IsCollectibleUnlocked(collectibleId)
  return ok == true
end

local function GetActiveByCategory(categoryType)
  if GetActiveCollectibleByType then
    return GetActiveCollectibleByType(categoryType)
  end
  if GetActiveCollectibleId then
    return GetActiveCollectibleId(categoryType)
  end
  return nil
end

local function GetCollectibleName(collectibleId)
  if not collectibleId then return nil end
  if GetCollectibleInfo then
    local name = GetCollectibleInfo(collectibleId)
    return name
  end
  return nil
end

local function ApplyCollectibleWithRetry(categoryType, targetId, attempt)
  attempt = attempt or 1
  if not targetId or attempt > 5 then return end

  zo_callLater(function()
    local current = GetActiveByCategory(categoryType)
    if current ~= targetId then
      if type(SetActiveCollectible) == "function" then
        dlog(("Retry %d: SetActiveCollectible(%d) [cat=%d]"):format(attempt, targetId, categoryType))
        SetActiveCollectible(targetId)
      elseif type(SetActiveCollectibleByType) == "function" then
        dlog(("Retry %d: SetActiveCollectibleByType(%d, %d)"):format(attempt, categoryType, targetId))
        SetActiveCollectibleByType(categoryType, targetId)
      elseif type(UseCollectible) == "function" then
        dlog(("Retry %d: UseCollectible(%d) [cat=%d]"):format(attempt, targetId, categoryType))
        UseCollectible(targetId)
      else
        dlog(L("ZMS_LOG_NOAPI")); return
      end
      ApplyCollectibleWithRetry(categoryType, targetId, attempt + 1)
    else
      dlog(("Collectible switched OK (cat=%d)"):format(categoryType))
    end
  end, attempt * 400)
end

-- =========================
-- =  Picker (random)      =
-- =========================
local function PickRandomUnlockedId(idList)
  if TableIsEmpty(idList) then return nil end
  -- Filtrer sur les collectibles débloqués
  local unlocked = {}
  for _, id in ipairs(idList) do
    if IsCollectibleUnlockedSafe(id) then table.insert(unlocked, id) end
  end
  local pool = (#unlocked > 0) and unlocked or idList -- si aucun débloqué, on essaie quand même
  local idx = zo_random(1, #pool)
  return pool[idx]
end

-- =========================
-- =  Core logic           =
-- =========================
function ZMS.FindGroupForZoneId(zoneId)
  if not zoneId or zoneId <= 0 then return nil end
  local map = ZMS.saved.zoneIdsByGroup or {}
  for _, key in ipairs(AllGroupKeys()) do
    local ids = map[key]
    if ids then
      for _, zid in ipairs(ids) do
        if zid == zoneId then
          return key
        end
      end
    end
  end
  return nil
end

function ZMS.ApplyMountForCurrentZone()
  local zid  = GetCurrentZoneId()
  local key  = ZMS.FindGroupForZoneId(zid)
  local name = GetZoneNameById(zid) or ("Zone " .. tostring(zid))

  if not key then
    dlog(string.format(L("ZMS_LOG_NOGROUP_FOR_ZONE"), name, zid or -1))
    return
  end

  -- ====== MOUNT (random in pool) ======
  local mPool = (ZMS.saved.groupToMountIds or {})[key]
  if not TableIsEmpty(mPool) then
    local mId = PickRandomUnlockedId(mPool)
    if not mId then
      dlog(string.format(L("ZMS_LOG_NOMOUNT"), GroupDisplayName(key)))
    else
      local currentM = GetActiveByCategory(COLLECTIBLE_CATEGORY_TYPE_MOUNT)
      if currentM ~= mId then
        dlog(string.format(L("ZMS_LOG_APPLY_MOUNT"), name, GroupDisplayName(key), mId))
        ApplyCollectibleWithRetry(COLLECTIBLE_CATEGORY_TYPE_MOUNT, mId)
      else
        dlog(L("ZMS_LOG_ALREADY"))
      end
    end
  else
    dlog(string.format(L("ZMS_LOG_NOMOUNT"), GroupDisplayName(key)))
  end

  -- ====== PET (random in pool) ======
  local pPool = (ZMS.saved.groupToPetIds or {})[key]
  if not TableIsEmpty(pPool) then
    local pId = PickRandomUnlockedId(pPool)
    if not pId then
      dlog(string.format(L("ZMS_LOG_NOPET"), GroupDisplayName(key)))
    else
      local currentP = GetActiveByCategory(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET)
      if currentP ~= pId then
        dlog(string.format(L("ZMS_LOG_APPLY_PET"), name, GroupDisplayName(key), pId))
        zo_callLater(function()
          ApplyCollectibleWithRetry(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET, pId)
        end, 300)
      else
        dlog(L("ZMS_LOG_PET_ALREADY"))
      end
    end
  else
    dlog(string.format(L("ZMS_LOG_NOPET"), GroupDisplayName(key)))
  end
end

-- =========================
-- =  Scheduling           =
-- =========================
ZMS._applyScheduled = false
local function ScheduleApply(delayMs)
  if ZMS._applyScheduled then return end
  ZMS._applyScheduled = true
  zo_callLater(function()
    ZMS._applyScheduled = false
    ZMS.ApplyMountForCurrentZone()
  end, delayMs or 300)
end

-- =========================
-- =  Commands             =
-- =========================
local function PrintHelp()
  d(L("ZMS_HELP_TITLE"))
  d(L("ZMS_HELP_SETMOUNT"))
  d(L("ZMS_HELP_CLEARMOUNT"))
  d(L("ZMS_HELP_SETPET"))
  d(L("ZMS_HELP_CLEARPET"))
  d(L("ZMS_HELP_SETALL"))
  d(L("ZMS_HELP_CLEARALL"))
  d(L("ZMS_HELP_TEST"))
  d(L("ZMS_HELP_DEBUG"))
  d(L("ZMS_HELP_LIST"))
  d(L("ZMS_HELP_RESETDEFAULTS"))
  local names = {}
  for _, key in ipairs(AllGroupKeys()) do
    table.insert(names, GroupDisplayName(key))
  end
  d(string.format(L("ZMS_HELP_GROUPS"), table.concat(names, ", ")))
end

local function CanonicalKeyFromUserInput(txt)
  txt = txt and txt:upper() or ""
  for _, key in ipairs(AllGroupKeys()) do
    if txt == key or txt == (GroupDisplayName(key):upper()) then
      return key
    end
  end
  return nil
end

-- ------- LIST -------
local function NamesFromIdList(list)
  if TableIsEmpty(list) then return L("ZMS_EMPTY") end
  local parts = {}
  for _, id in ipairs(list) do
    table.insert(parts, GetCollectibleName(id) or ("#" .. tostring(id)))
  end
  return table.concat(parts, ", ")
end

local function CmdList(arg)
  local key = CanonicalKeyFromUserInput(arg)
  if not key then
    d(L("ZMS_LIST_HEADER"))
    for _, g in ipairs(AllGroupKeys()) do
      local ids = ZMS.saved.zoneIdsByGroup[g] or {}
      if #ids > 0 then
        local parts = {}
        for _, zid in ipairs(ids) do
          table.insert(parts, string.format("%s (%d)", GetZoneNameById(zid) or "?", zid))
        end
        d(("- %s : %s"):format(GroupDisplayName(g), table.concat(parts, ", ")))
      else
        d(("- %s : (%s)"):format(GroupDisplayName(g), L("ZMS_EMPTY")))
      end
    end
    d(L("ZMS_LIST_MOUNTSPETS"))
    for _, g in ipairs(AllGroupKeys()) do
      local mPool = (ZMS.saved.groupToMountIds or {})[g]
      local pPool = (ZMS.saved.groupToPetIds or {})[g]
      local mNames = NamesFromIdList(mPool)
      local pNames = NamesFromIdList(pPool)
      d(("- %s : Mounts=[%s]  |  Pets=[%s]"):format(GroupDisplayName(g), mNames, pNames))
    end
  else
    local ids = ZMS.saved.zoneIdsByGroup[key] or {}
    d(string.format(L("ZMS_LIST_GROUP_HEADER"), GroupDisplayName(key)))
    if #ids == 0 then
      d("(" .. L("ZMS_NONE") .. ")")
    else
      for _, zid in ipairs(ids) do
        d(string.format("- %s (%d)", GetZoneNameById(zid) or "?", zid))
      end
    end
    local mPool = (ZMS.saved.groupToMountIds or {})[key]
    local pPool = (ZMS.saved.groupToPetIds or {})[key]
    d(("- %s : [%s]"):format(L("ZMS_WORD_MOUNT"), NamesFromIdList(mPool)))
    d(("- %s : [%s]"):format(L("ZMS_WORD_PET"),   NamesFromIdList(pPool)))
  end
end

-- ------- SET/CLEAR MOUNT -------
local function CmdSetMount(arg)
  local key = CanonicalKeyFromUserInput(arg)
  if not key then d(string.format(L("ZMS_ERR_UNKNOWN"), tostring(arg))) return end

  local mId = GetActiveByCategory(COLLECTIBLE_CATEGORY_TYPE_MOUNT)
  if not mId then d(L("ZMS_ERR_READMOUNT")) return end

  local added = AddIdToSet(ZMS.saved.groupToMountIds, key, mId)
  d(string.format(L("ZMS_OK_SETMOUNT"), GroupDisplayName(key), mId))
  if not added then dlog("Mount already present in pool; no duplicate added.") end
end

local function CmdClearMount(arg)
  local key = CanonicalKeyFromUserInput(arg)
  if not key then d(string.format(L("ZMS_ERR_UNKNOWN"), tostring(arg))) return end

  local pool = (ZMS.saved.groupToMountIds or {})[key]
  if not TableIsEmpty(pool) then
    ZMS.saved.groupToMountIds[key] = {}
    d(string.format(L("ZMS_OK_CLEARMOUNT"), GroupDisplayName(key)))
  else
    d(string.format(L("ZMS_NO_CLEARMOUNT"), GroupDisplayName(key)))
  end
end

-- ------- SET/CLEAR PET -------
local function CmdSetPet(arg)
  local key = CanonicalKeyFromUserInput(arg)
  if not key then d(string.format(L("ZMS_ERR_UNKNOWN"), tostring(arg))) return end

  local pId = GetActiveByCategory(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET)
  if not pId then d(L("ZMS_ERR_READPET")) return end

  local added = AddIdToSet(ZMS.saved.groupToPetIds, key, pId)
  local name = GetCollectibleName(pId) or tostring(pId)
  d(string.format(L("ZMS_OK_SETPET"), GroupDisplayName(key), name))
  if not added then dlog("Pet already present in pool; no duplicate added.") end
end

local function CmdClearPet(arg)
  local key = CanonicalKeyFromUserInput(arg)
  if not key then d(string.format(L("ZMS_ERR_UNKNOWN"), tostring(arg))) return end

  local pool = (ZMS.saved.groupToPetIds or {})[key]
  if not TableIsEmpty(pool) then
    ZMS.saved.groupToPetIds[key] = {}
    d(string.format(L("ZMS_OK_CLEARPET"), GroupDisplayName(key)))
  else
    d(string.format(L("ZMS_NO_CLEARPET"), GroupDisplayName(key)))
  end
end

-- ------- SET ALL (add both current) -------
local function CmdSetAll(arg)
  local key = CanonicalKeyFromUserInput(arg)
  if not key then d(string.format(L("ZMS_ERR_UNKNOWN"), tostring(arg))) return end

  local mId = GetActiveByCategory(COLLECTIBLE_CATEGORY_TYPE_MOUNT)
  local pId = GetActiveByCategory(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET)

  local mName = L("ZMS_NONE")
  local pName = L("ZMS_NONE")

  if mId then
    AddIdToSet(ZMS.saved.groupToMountIds, key, mId)
    mName = GetCollectibleName(mId) or ("#" .. tostring(mId))
  end
  if pId then
    AddIdToSet(ZMS.saved.groupToPetIds, key, pId)
    pName = GetCollectibleName(pId) or ("#" .. tostring(pId))
  end

  if not mId and not pId then
    d(L("ZMS_ERR_READALL"))
    return
  end

  d(string.format(L("ZMS_OK_SETALL"), GroupDisplayName(key), mName, pName))
end

-- ------- CLEAR ALL (clear both pools) -------
local function CmdClearAll(arg)
  local key = CanonicalKeyFromUserInput(arg)
  if not key then d(string.format(L("ZMS_ERR_UNKNOWN"), tostring(arg))) return end

  local had = false
  if not TableIsEmpty((ZMS.saved.groupToMountIds or {})[key]) then ZMS.saved.groupToMountIds[key] = {} had=true end
  if not TableIsEmpty((ZMS.saved.groupToPetIds   or {})[key]) then ZMS.saved.groupToPetIds[key]   = {} had=true end

  if had then
    d(string.format(L("ZMS_OK_CLEARALL"), GroupDisplayName(key)))
  else
    d(string.format(L("ZMS_NO_CLEARMOUNT"), GroupDisplayName(key)))
    d(string.format(L("ZMS_NO_CLEARPET"),   GroupDisplayName(key)))
  end
end

-- ------- TEST/DEBUG -------
local function CmdTest()  ScheduleApply(300) end
local function CmdDebug()
  ZMS.saved.debug = not ZMS.saved.debug
  d(string.format(L("ZMS_DEBUG_TOGGLE"), tostring(ZMS.saved.debug)))
end

-- ------- BIND / UNBIND ZONE -------
local function GetCurrentZoneIdSafe() return GetCurrentZoneId() end

local function CmdBindHere(arg)
  local key = CanonicalKeyFromUserInput(arg)
  if not key then d(string.format(L("ZMS_ERR_UNKNOWN"), tostring(arg))) return end
  local zid = GetCurrentZoneIdSafe()
  if zid and zid > 0 then
    ZMS.saved.zoneIdsByGroup[key] = ZMS.saved.zoneIdsByGroup[key] or {}
    for _, v in ipairs(ZMS.saved.zoneIdsByGroup[key]) do
      if v == zid then
        dlog(string.format(L("ZMS_LOG_ALREADY_BOUND"), zid, GroupDisplayName(key)))
        ScheduleApply(300)
        return
      end
    end
    table.insert(ZMS.saved.zoneIdsByGroup[key], zid)
    dlog(string.format(L("ZMS_LOG_BOUND"), zid, GetZoneNameById(zid) or "?", GroupDisplayName(key)))
    ScheduleApply(300)
  end
end

local function CmdUnbindHere(arg)
  local key = CanonicalKeyFromUserInput(arg)
  if not key then d(string.format(L("ZMS_ERR_UNKNOWN"), tostring(arg))) return end
  local zid = GetCurrentZoneIdSafe()
  local list = ZMS.saved.zoneIdsByGroup[key]
  if not list then
    d(L("ZMS_ERR_UNKNOWN"))
    return
  end
  for i, v in ipairs(list) do
    if v == zid then
      table.remove(list, i)
      dlog(string.format(L("ZMS_LOG_UNBOUND"), zid, GroupDisplayName(key)))
      ScheduleApply(300)
      return
    end
  end
  dlog(string.format(L("ZMS_LOG_UNBOUND"), zid, GroupDisplayName(key)))
end

-- ------- Reset defaults -------
local function CmdResetDefaults()
  if type(ZMS.DEFAULT_ZONE_GROUPS) ~= "table" then
    d(L("ZMS_ERR_NODEFAULTS")); return
  end
  ZMS.saved.zoneIdsByGroup = ShallowCopy(ZMS.DEFAULT_ZONE_GROUPS)
  ZMS.saved.defaultsVersion = ZMS.DEFAULTS_VERSION or 1
  d(string.format(L("ZMS_OK_RESETDEFAULTS"), tostring(ZMS.saved.defaultsVersion)))
end

-- ------- Dispatcher -------
local function CmdHandler(txt)
  txt = txt or ""
  local a1, a2 = txt:match("^(%S+)%s*(.*)$")
  if not a1 then PrintHelp() return end
  a1 = a1:lower()

  if a1 == "setmount" then
    CmdSetMount(a2)
  elseif a1 == "clearmount" then
    CmdClearMount(a2)
  elseif a1 == "setpet" then
    CmdSetPet(a2)
  elseif a1 == "clearpet" then
    CmdClearPet(a2)
  elseif a1 == "setall" then
    CmdSetAll(a2)
  elseif a1 == "clearall" then
    CmdClearAll(a2)
  elseif a1 == "test" then
    CmdTest()
  elseif a1 == "debug" then
    CmdDebug()
  elseif a1 == "bindhere" then
    CmdBindHere(a2)
  elseif a1 == "unbindhere" then
    CmdUnbindHere(a2)
  elseif a1 == "list" then
    CmdList(a2)
  elseif a1 == "resetdefaults" then
    CmdResetDefaults()
  else
    PrintHelp()
  end
end

-- =========================
-- =  Events               =
-- =========================
local function OnPlayerActivated() ScheduleApply(1200) end
local function OnZoneChanged(_, unitTag, _, _, _) if unitTag=="player" then ScheduleApply(1000) end end

-- =========================
-- =  Init + Migration     =
-- =========================
local function MigrateLegacySinglesToPools()
  -- Ancien schéma: groupToMountId / groupToPetId → on les ajoute à groupToMountIds / groupToPetIds
  if type(ZMS.saved.groupToMountId) == "table" then
    for key, id in pairs(ZMS.saved.groupToMountId) do
      if id then AddIdToSet(ZMS.saved.groupToMountIds, key, id) end
    end
    ZMS.saved.groupToMountId = nil
  end
  if type(ZMS.saved.groupToPetId) == "table" then
    for key, id in pairs(ZMS.saved.groupToPetId) do
      if id then AddIdToSet(ZMS.saved.groupToPetIds, key, id) end
    end
    ZMS.saved.groupToPetId = nil
  end
end

local function OnAddOnLoaded(event, addonName)
  if addonName ~= ADDON_NAME then return end
  EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

  ZMS.saved = ZO_SavedVars:NewAccountWide("ZMS_Saved", 1, GetWorldName(), DEFAULTS.accountWide)

  -- ensure tables
  ZMS.saved.groupToMountIds = ZMS.saved.groupToMountIds or {}
  ZMS.saved.groupToPetIds   = ZMS.saved.groupToPetIds   or {}
  ZMS.saved.zoneIdsByGroup  = ZMS.saved.zoneIdsByGroup  or {}
  ZMS.saved.defaultsVersion = ZMS.saved.defaultsVersion or 0

  -- migration depuis ancien format
  MigrateLegacySinglesToPools()

  -- Seed defaults zones au premier lancement
  local hasAny = false
  for _, key in ipairs(ZMS.GROUP_KEYS or {}) do
    local t = ZMS.saved.zoneIdsByGroup[key]
    if t and #t > 0 then hasAny = true break end
  end
  if not hasAny and type(ZMS.DEFAULT_ZONE_GROUPS) == "table" then
    ZMS.saved.zoneIdsByGroup = ShallowCopy(ZMS.DEFAULT_ZONE_GROUPS)
    ZMS.saved.defaultsVersion = ZMS.DEFAULTS_VERSION or 1
    dlog(("Defaults pack appliqué (version %s)."):format(tostring(ZMS.saved.defaultsVersion)))
  end

  -- Upgrade doux si pack defaults plus récent
  local curV = tonumber(ZMS.saved.defaultsVersion or 0) or 0
  local newV = tonumber(ZMS.DEFAULTS_VERSION or 0) or 0
  if newV > curV and type(ZMS.DEFAULT_ZONE_GROUPS) == "table" then
    for _, key in ipairs(ZMS.GROUP_KEYS or {}) do
      local curList = ZMS.saved.zoneIdsByGroup[key] or {}
      local defList = ZMS.DEFAULT_ZONE_GROUPS[key] or {}
      ZMS.saved.zoneIdsByGroup[key] = MergeUnique(curList, defList)
    end
    ZMS.saved.defaultsVersion = newV
    dlog(("Defaults pack mis à niveau → version %d."):format(newV))
  end

  SLASH_COMMANDS["/zms"] = CmdHandler

  EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
  EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ZONE_CHANGED,     OnZoneChanged)

  d(L("ZMS_LOADED"))
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
