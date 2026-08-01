-- ZoneMountSwitcher.lua (with universal mounts/pets support)
local ADDON_NAME = "ZoneMountSwitcher"

ZMS = ZMS or {}
ZMS.name = ADDON_NAME

-- =========================
-- =  Saved variables      =
-- =========================
local DEFAULTS = {
  accountWide = {
    -- Scope preference (stored in account-wide vars, always)
    accountWide         = true,  -- true = partage compte, false = par personnage
    -- NEW: lists of ids per group (randomly pick one on apply)
    groupToMountIds     = {},  -- ["NORDIC"]={ collectibleId, ... }
    groupToPetIds       = {},  -- ["NORDIC"]={ collectibleId, ... }
    -- UNIVERSAL: mounts/pets that appear in ALL zones
    universalMountIds   = {},  -- { collectibleId, ... }
    universalPetIds     = {},  -- { collectibleId, ... }
    -- legacy (will be migrated if found): groupToMountId, groupToPetId
    zoneIdsByGroup      = {},  -- ["NORDIC"]={ 41, 103, ... }
    customGroups        = {},  -- ["MYGROUP"]={ displayName="My Group" }
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

local function RemoveIdFromSet(t, key, id)
  if not id or not t[key] then return false end
  for i, v in ipairs(t[key]) do
    if v == id then
      table.remove(t[key], i)
      return true
    end
  end
  return false
end

local function TableIsEmpty(arr)
  return (type(arr) ~= "table") or (#arr == 0)
end

-- =========================
-- =  Group helpers        =
-- =========================

-- Retourne toutes les clés de groupe (défauts + custom)
local function AllGroupKeys()
  local all = {}
  -- Ajouter les groupes par défaut
  for _, k in ipairs(ZMS.GROUP_KEYS or {}) do
    table.insert(all, k)
  end
  -- Ajouter les groupes custom
  if ZMS.saved and ZMS.saved.customGroups then
    for k, _ in pairs(ZMS.saved.customGroups) do
      table.insert(all, k)
    end
  end
  return all
end

-- Nom d'affichage pour un groupe
local function GroupDisplayName(key)
  -- Vérifier si c'est un groupe custom
  if ZMS.saved and ZMS.saved.customGroups and ZMS.saved.customGroups[key] then
    return ZMS.saved.customGroups[key].displayName or key
  end
  -- Sinon utiliser la fonction par défaut
  return ZMS.GroupDisplayName(key)
end

-- Vérifier si un groupe est custom (pas dans les défauts)
local function IsCustomGroup(key)
  for _, k in ipairs(ZMS.GROUP_KEYS or {}) do
    if k == key then return false end
  end
  return true
end

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
  local pool = (#unlocked > 0) and unlocked or idList
  local idx = zo_random(1, #pool)
  return pool[idx]
end

-- =========================
-- =  Core logic (MULTI-GROUP + UNIVERSAL)
-- =========================

-- Retourne TOUS les groupes contenant la zone
function ZMS.FindAllGroupsForZoneId(zoneId)
  if not zoneId or zoneId <= 0 then return {} end
  
  local foundGroups = {}
  local map = ZMS.saved.zoneIdsByGroup or {}
  
  for _, key in ipairs(AllGroupKeys()) do
    local ids = map[key]
    if ids then
      for _, zid in ipairs(ids) do
        if zid == zoneId then
          table.insert(foundGroups, key)
          break
        end
      end
    end
  end
  
  return foundGroups
end

-- Ancienne fonction conservée pour compatibilité
function ZMS.FindGroupForZoneId(zoneId)
  local groups = ZMS.FindAllGroupsForZoneId(zoneId)
  return groups[1]
end

-- Applique monture/pet en fusionnant tous les groupes + universels
function ZMS.ApplyMountForCurrentZone()
  local zid  = GetCurrentZoneId()
  local groups = ZMS.FindAllGroupsForZoneId(zid)
  local name = GetZoneNameById(zid) or ("Zone " .. tostring(zid))

  if #groups == 0 then
    dlog(string.format(L("ZMS_LOG_NOGROUP_FOR_ZONE"), name, zid or -1))
    -- Pas de groupe, mais on applique quand même les universels
  end

  -- Construire les noms des groupes pour le log
  local groupNames = {}
  for _, key in ipairs(groups) do
    table.insert(groupNames, GroupDisplayName(key))
  end
  local groupNamesStr = (#groups > 0) and table.concat(groupNames, ", ") or L("ZMS_NONE")
  
  if #groups > 0 then
    dlog(string.format("Zone %s (%d) appartient a %d groupe(s): %s", name, zid, #groups, groupNamesStr))
  end

  -- ====== MOUNT: Fusionner tous les pools + universels ======
  local allMounts = {}
  
  -- Ajouter les universels d'abord
  if ZMS.saved.universalMountIds and not TableIsEmpty(ZMS.saved.universalMountIds) then
    allMounts = MergeUnique(allMounts, ZMS.saved.universalMountIds)
    dlog(string.format("Ajout de %d monture(s) universelle(s)", #ZMS.saved.universalMountIds))
  end
  
  -- Ajouter les pools des groupes
  for _, key in ipairs(groups) do
    local mPool = (ZMS.saved.groupToMountIds or {})[key]
    if not TableIsEmpty(mPool) then
      allMounts = MergeUnique(allMounts, mPool)
    end
  end

  if not TableIsEmpty(allMounts) then
    local mId = PickRandomUnlockedId(allMounts)
    if not mId then
      dlog(string.format(L("ZMS_LOG_NOMOUNT"), groupNamesStr))
    else
      local currentM = GetActiveByCategory(COLLECTIBLE_CATEGORY_TYPE_MOUNT)
      if currentM ~= mId then
        dlog(string.format("Application monture pour zone %s depuis groupe(s) %s: ID %d", name, groupNamesStr, mId))
        ApplyCollectibleWithRetry(COLLECTIBLE_CATEGORY_TYPE_MOUNT, mId)
      else
        dlog(L("ZMS_LOG_ALREADY"))
      end
    end
  else
    if #groups > 0 then
      dlog(string.format(L("ZMS_LOG_NOMOUNT"), groupNamesStr))
    end
  end

  -- ====== PET: Fusionner tous les pools + universels ======
  local allPets = {}
  
  -- Ajouter les universels d'abord
  if ZMS.saved.universalPetIds and not TableIsEmpty(ZMS.saved.universalPetIds) then
    allPets = MergeUnique(allPets, ZMS.saved.universalPetIds)
    dlog(string.format("Ajout de %d familier(s) universel(s)", #ZMS.saved.universalPetIds))
  end
  
  -- Ajouter les pools des groupes
  for _, key in ipairs(groups) do
    local pPool = (ZMS.saved.groupToPetIds or {})[key]
    if not TableIsEmpty(pPool) then
      allPets = MergeUnique(allPets, pPool)
    end
  end

  if not TableIsEmpty(allPets) then
    local pId = PickRandomUnlockedId(allPets)
    if not pId then
      dlog(string.format(L("ZMS_LOG_NOPET"), groupNamesStr))
    else
      local currentP = GetActiveByCategory(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET)
      if currentP ~= pId then
        dlog(string.format("Application pet pour zone %s depuis groupe(s) %s: ID %d", name, groupNamesStr, pId))
        zo_callLater(function()
          ApplyCollectibleWithRetry(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET, pId)
        end, 300)
      else
        dlog(L("ZMS_LOG_PET_ALREADY"))
      end
    end
  else
    if #groups > 0 then
      dlog(string.format(L("ZMS_LOG_NOPET"), groupNamesStr))
    end
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
-- =  Commands + Help      =
-- =========================
local function CanonicalKeyFromUserInput(userInput)
  if not userInput or userInput == "" then return nil end
  local u = tostring(userInput):upper()
  
  -- Vérifier les groupes par défaut
  for _, k in ipairs(ZMS.GROUP_KEYS or {}) do
    if k == u then return k end
    local dn = ZMS.GroupDisplayName(k):upper()
    if dn == u then return k end
  end
  
  -- Vérifier les groupes custom
  if ZMS.saved and ZMS.saved.customGroups then
    for k, info in pairs(ZMS.saved.customGroups) do
      if k == u then return k end
      if info.displayName and info.displayName:upper() == u then return k end
    end
  end
  
  return nil
end

local function PrintHelp()
  d(L("ZMS_HELP_HEADER"))
  d(" ")
  d(L("ZMS_HELP_SETMOUNT"))
  d(L("ZMS_HELP_CLEARMOUNT"))
  d(L("ZMS_HELP_SETPET"))
  d(L("ZMS_HELP_CLEARPET"))
  d(L("ZMS_HELP_SETALL"))
  d(L("ZMS_HELP_CLEARALL"))
  d(L("ZMS_HELP_BINDHERE"))
  d(L("ZMS_HELP_UNBINDHERE"))
  d(L("ZMS_HELP_LIST"))
  d(L("ZMS_HELP_TEST"))
  d(L("ZMS_HELP_DEBUG"))
  d(L("ZMS_HELP_RESETDEFAULTS"))
  d(L("ZMS_HELP_CREATEGROUP"))
  d(L("ZMS_HELP_DELETEGROUP"))
  d(L("ZMS_HELP_SETUNIVERSAL"))
  d(L("ZMS_HELP_CLEARUNIVERSAL"))
  d("/zms ui  - ouvrir/fermer la fenetre de configuration.")
  d(" ")
  local glist = {}
  for _, k in ipairs(AllGroupKeys()) do
    table.insert(glist, GroupDisplayName(k))
  end
  d(L("ZMS_HELP_GROUPS") .. " " .. table.concat(glist, ", "))
end

local function CmdList(arg)
  local key = nil
  if arg and arg ~= "" then
    key = CanonicalKeyFromUserInput(arg)
    if not key then
      d(string.format(L("ZMS_ERR_UNKNOWN"), tostring(arg)))
      return
    end
  end

  local function listGroup(k)
    local gname = GroupDisplayName(k)
    local mPool = (ZMS.saved.groupToMountIds or {})[k]
    local pPool = (ZMS.saved.groupToPetIds   or {})[k]
    local zones = (ZMS.saved.zoneIdsByGroup  or {})[k]
    
    -- Indiquer si c'est un groupe custom
    local customTag = IsCustomGroup(k) and " |cFFFF00[CUSTOM]|r" or ""

    d(string.format("|cFFFF00%s|r%s", gname, customTag))

    if not TableIsEmpty(mPool) then
      for _, id in ipairs(mPool) do
        local nm = GetCollectibleName(id) or ("ID=" .. tostring(id))
        local lock = IsCollectibleUnlockedSafe(id) and "|c00FF00✓|r" or "|cFF0000✗|r"
        d(("  Mount: %s %s"):format(lock, nm))
      end
    else
      d(string.format("  " .. L("ZMS_NOMOUNT_IN_GROUP"), gname))
    end

    if not TableIsEmpty(pPool) then
      for _, id in ipairs(pPool) do
        local nm = GetCollectibleName(id) or ("ID=" .. tostring(id))
        local lock = IsCollectibleUnlockedSafe(id) and "|c00FF00✓|r" or "|cFF0000✗|r"
        d(("  Pet: %s %s"):format(lock, nm))
      end
    else
      d(string.format("  " .. L("ZMS_NOPET_IN_GROUP"), gname))
    end

    if not TableIsEmpty(zones) then
      local zoneNames = {}
      for _, zid in ipairs(zones) do
        local zn = GetZoneNameById(zid) or ("Zone " .. tostring(zid))
        table.insert(zoneNames, zn)
      end
      d(("  Zones: %s"):format(table.concat(zoneNames, ", ")))
    else
      d(string.format("  " .. L("ZMS_NOZONES_IN_GROUP"), gname))
    end
  end

  if key then
    listGroup(key)
  else
    -- Afficher les universels en premier
    if not TableIsEmpty(ZMS.saved.universalMountIds) or not TableIsEmpty(ZMS.saved.universalPetIds) then
      d("|cFF00FF=== UNIVERSAL (ALL ZONES) ===|r")
      
      if not TableIsEmpty(ZMS.saved.universalMountIds) then
        for _, id in ipairs(ZMS.saved.universalMountIds) do
          local nm = GetCollectibleName(id) or ("ID=" .. tostring(id))
          local lock = IsCollectibleUnlockedSafe(id) and "|c00FF00✓|r" or "|cFF0000✗|r"
          d(("  Mount: %s %s"):format(lock, nm))
        end
      end
      
      if not TableIsEmpty(ZMS.saved.universalPetIds) then
        for _, id in ipairs(ZMS.saved.universalPetIds) do
          local nm = GetCollectibleName(id) or ("ID=" .. tostring(id))
          local lock = IsCollectibleUnlockedSafe(id) and "|c00FF00✓|r" or "|cFF0000✗|r"
          d(("  Pet: %s %s"):format(lock, nm))
        end
      end
      
      d(" ")
    end
    
    -- Afficher tous les groupes
    for _, k in ipairs(AllGroupKeys()) do
      listGroup(k)
      d(" ")
    end
  end
end

-- ------- SET/CLEAR MOUNT -------
local function CmdSetMount(arg)
  local key = CanonicalKeyFromUserInput(arg)
  if not key then d(string.format(L("ZMS_ERR_UNKNOWN"), tostring(arg))) return end

  local mId = GetActiveByCategory(COLLECTIBLE_CATEGORY_TYPE_MOUNT)
  if not mId then d(L("ZMS_ERR_READMOUNT")) return end

  local added = AddIdToSet(ZMS.saved.groupToMountIds, key, mId)
  local name = GetCollectibleName(mId) or tostring(mId)
  d(string.format(L("ZMS_OK_SETMOUNT"), GroupDisplayName(key), name))
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

-- ------- SET/CLEAR UNIVERSAL -------
local function CmdSetUniversal(arg)
  if not arg or arg == "" then
    d(L("ZMS_ERR_SETUNIVERSAL_NOARG"))
    return
  end
  
  local what = arg:lower()
  
  if what == "mount" then
    local mId = GetActiveByCategory(COLLECTIBLE_CATEGORY_TYPE_MOUNT)
    if not mId then d(L("ZMS_ERR_READMOUNT")) return end
    
    ZMS.saved.universalMountIds = ZMS.saved.universalMountIds or {}
    for _, v in ipairs(ZMS.saved.universalMountIds) do
      if v == mId then
        d(L("ZMS_ERR_UNIVERSAL_ALREADY"))
        return
      end
    end
    
    table.insert(ZMS.saved.universalMountIds, mId)
    local name = GetCollectibleName(mId) or tostring(mId)
    d(string.format(L("ZMS_OK_SETUNIVERSAL_MOUNT"), name))
    
  elseif what == "pet" then
    local pId = GetActiveByCategory(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET)
    if not pId then d(L("ZMS_ERR_READPET")) return end
    
    ZMS.saved.universalPetIds = ZMS.saved.universalPetIds or {}
    for _, v in ipairs(ZMS.saved.universalPetIds) do
      if v == pId then
        d(L("ZMS_ERR_UNIVERSAL_ALREADY"))
        return
      end
    end
    
    table.insert(ZMS.saved.universalPetIds, pId)
    local name = GetCollectibleName(pId) or tostring(pId)
    d(string.format(L("ZMS_OK_SETUNIVERSAL_PET"), name))
    
  else
    d(L("ZMS_ERR_SETUNIVERSAL_NOARG"))
  end
end

local function CmdClearUniversal(arg)
  if not arg or arg == "" then
    d(L("ZMS_ERR_CLEARUNIVERSAL_NOARG"))
    return
  end
  
  local what = arg:lower()
  
  if what == "mount" then
    local mId = GetActiveByCategory(COLLECTIBLE_CATEGORY_TYPE_MOUNT)
    if not mId then d(L("ZMS_ERR_READMOUNT")) return end
    
    if RemoveIdFromSet(ZMS.saved, "universalMountIds", mId) then
      local name = GetCollectibleName(mId) or tostring(mId)
      d(string.format(L("ZMS_OK_CLEARUNIVERSAL_MOUNT"), name))
    else
      d(L("ZMS_ERR_UNIVERSAL_NOTFOUND"))
    end
    
  elseif what == "pet" then
    local pId = GetActiveByCategory(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET)
    if not pId then d(L("ZMS_ERR_READPET")) return end
    
    if RemoveIdFromSet(ZMS.saved, "universalPetIds", pId) then
      local name = GetCollectibleName(pId) or tostring(pId)
      d(string.format(L("ZMS_OK_CLEARUNIVERSAL_PET"), name))
    else
      d(L("ZMS_ERR_UNIVERSAL_NOTFOUND"))
    end
    
  else
    d(L("ZMS_ERR_CLEARUNIVERSAL_NOARG"))
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

-- ------- CREATE / DELETE GROUP -------
local function CmdCreateGroup(arg)
  if not arg or arg == "" then
    d(L("ZMS_ERR_CREATEGROUP_NONAME"))
    return
  end
  
  -- Extraire le nom du groupe et le nom d'affichage (optionnel)
  local groupKey, displayName = arg:match("^(%S+)%s*(.*)$")
  groupKey = groupKey:upper()
  
  -- Vérifier si le groupe existe déjà
  if CanonicalKeyFromUserInput(groupKey) then
    d(string.format(L("ZMS_ERR_GROUP_EXISTS"), groupKey))
    return
  end
  
  -- Si pas de nom d'affichage, utiliser la clé
  if not displayName or displayName == "" then
    displayName = groupKey
  end
  
  -- Créer le groupe custom
  ZMS.saved.customGroups = ZMS.saved.customGroups or {}
  ZMS.saved.customGroups[groupKey] = {
    displayName = displayName
  }
  
  -- Initialiser les tables pour ce groupe
  ZMS.saved.zoneIdsByGroup[groupKey] = {}
  ZMS.saved.groupToMountIds[groupKey] = {}
  ZMS.saved.groupToPetIds[groupKey] = {}
  
  d(string.format(L("ZMS_OK_CREATEGROUP"), displayName, groupKey))
end

local function CmdDeleteGroup(arg)
  local key = CanonicalKeyFromUserInput(arg)
  if not key then
    d(string.format(L("ZMS_ERR_UNKNOWN"), tostring(arg)))
    return
  end
  
  -- Empêcher la suppression des groupes par défaut
  if not IsCustomGroup(key) then
    d(string.format(L("ZMS_ERR_CANNOT_DELETE_DEFAULT"), GroupDisplayName(key)))
    return
  end
  
  -- Supprimer le groupe et toutes ses données
  local displayName = GroupDisplayName(key)
  
  ZMS.saved.customGroups[key] = nil
  ZMS.saved.zoneIdsByGroup[key] = nil
  ZMS.saved.groupToMountIds[key] = nil
  ZMS.saved.groupToPetIds[key] = nil
  
  d(string.format(L("ZMS_OK_DELETEGROUP"), displayName))
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
  elseif a1 == "creategroup" then
    CmdCreateGroup(a2)
  elseif a1 == "deletegroup" then
    CmdDeleteGroup(a2)
  elseif a1 == "setuniversal" then
    CmdSetUniversal(a2)
  elseif a1 == "clearuniversal" then
    CmdClearUniversal(a2)
  elseif a1 == "ui" or a1 == "open" then
    ZMS.UI.Toggle()
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

-- =========================
-- =  SavedVars scope swap =
-- =========================
-- Appele au demarrage et quand l'utilisateur change de mode.
-- ZMS.svAccount est toujours disponible (stocke le flag accountWide).
-- ZMS.saved pointe vers svAccount ou svChar selon la preference.
function ZMS.ApplySavedVarsScope()
  local useAccount = (ZMS.svAccount.accountWide ~= false)
  if useAccount then
    ZMS.saved = ZMS.svAccount
  else
    ZMS.saved = ZMS.svChar
  end
end

local function OnAddOnLoaded(event, addonName)
  if addonName ~= ADDON_NAME then return end
  EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

  -- Les deux objets SavedVars coexistent toujours.
  -- svAccount : partage entre tous les persos du compte (par serveur).
  -- svChar    : propre a ce personnage.
  ZMS.svAccount = ZO_SavedVars:NewAccountWide(
      "ZMS_Saved", 1, GetWorldName(), DEFAULTS.accountWide)
  ZMS.svChar    = ZO_SavedVars:NewCharacterIdSettings(
      "ZMS_Saved", 1, nil, DEFAULTS.accountWide)

  -- Garantit que le flag existe (peut etre absent sur des SavedVars tres anciens)
  if ZMS.svAccount.accountWide == nil then
    ZMS.svAccount.accountWide = true
  end

  -- Active le bon jeu de donnees
  ZMS.ApplySavedVarsScope()

  -- ensure tables
  ZMS.saved.groupToMountIds   = ZMS.saved.groupToMountIds   or {}
  ZMS.saved.groupToPetIds     = ZMS.saved.groupToPetIds     or {}
  ZMS.saved.zoneIdsByGroup    = ZMS.saved.zoneIdsByGroup    or {}
  ZMS.saved.customGroups      = ZMS.saved.customGroups      or {}
  ZMS.saved.universalMountIds = ZMS.saved.universalMountIds or {}
  ZMS.saved.universalPetIds   = ZMS.saved.universalPetIds   or {}
  ZMS.saved.defaultsVersion   = ZMS.saved.defaultsVersion   or 0

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
    dlog(("Defaults pack applique (version %s)."):format(tostring(ZMS.saved.defaultsVersion)))
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
    dlog(("Defaults pack mis a niveau -> version %d."):format(newV))
  end

  SLASH_COMMANDS["/zms"] = CmdHandler

  EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
  EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ZONE_CHANGED,     OnZoneChanged)

  d(L("ZMS_LOADED"))
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)