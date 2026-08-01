--------------------------------------------------------------
-- EyeOnKeep.lua — v1.0 Console Cyrodiil Intel (Strategic)
-- Author: SugaComa (Rik Sprint)
-- Chat-only, console-safe, strategic signals (low spam)
--------------------------------------------------------------

local ADDON_NAME = "EyeOnKeep"
EyeOnKeep = EyeOnKeep or {}
EyeOnKeep.version = "1.0-Strategic"

local EM = EVENT_MANAGER
local EOK_SV_VERSION = 26
local EOK_SV = nil
local _inited = false
local muted = false
local BG_CONTEXT = BGQUERY_LOCAL

-- Polling + cooldowns
local POLL_INTERVAL_MS = 30000
local MSG_COOLDOWN_MS  = 15000

--------------------------------------------------------------
-- Factions
--------------------------------------------------------------
local FACTION = {
  [ALLIANCE_ALDMERI_DOMINION]     = { tag="AD", name="Aldmeri Dominion",    color="|cFFD700", monarch="Queen Ayrenn" },
  [ALLIANCE_DAGGERFALL_COVENANT]  = { tag="DC", name="Daggerfall Covenant", color="|c4169E1", monarch="King Emeric" },
  [ALLIANCE_EBONHEART_PACT]       = { tag="EP", name="Ebonheart Pact",      color="|cFF2400", monarch="Jorunn the Skald-King" },
  [ALLIANCE_NONE]                 = { tag="--", name="In Conflict",          color="|cFFFFFF", monarch="No ruler" },
}

local INFO_COLOR = "|c00FFCC"  -- electric blue/green for names & key nouns
local TEXT_DIM   = "|cDDDDDD"

local function chat(msg)
  if muted or not msg or msg == "" then return end
  if CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then
    CHAT_SYSTEM:AddMessage("|cFFFFFF" .. msg .. "|r")
  else
    d("|cFFFFFF" .. msg .. "|r")
  end
end

--------------------------------------------------------------
-- Keep Types (ESOUI)
--------------------------------------------------------------
local KEEP_TYPE_KEEP     = 1
local KEEP_TYPE_OUTPOST  = 5
local KEEP_TYPE_TOWN     = 6
local KEEP_TYPE_RESOURCE = 8

--------------------------------------------------------------
-- Territories (native ownership) — core keeps, outposts, towns
--------------------------------------------------------------
local HOME_KEEPS = {
  ["Castle Alessia"]=1,["Castle Black Boot"]=1,["Castle Bloodmayne"]=1,
  ["Castle Brindle"]=1,["Castle Faregyl"]=1,["Castle Roebeck"]=1,
  ["Fort Aleswell"]=2,["Fort Ash"]=2,["Fort Dragonclaw"]=2,
  ["Fort Glademist"]=2,["Fort Rayles"]=2,["Fort Warden"]=2,
  ["Arrius Keep"]=3,["Blue Road Keep"]=3,["Chalman Keep"]=3,
  ["Drakelowe Keep"]=3,["Kingscrest Keep"]=3,["Farragut Keep"]=3,
}
local OUTPOSTS = {
  ["Nikel Outpost"]=1,["Carmala Outpost"]=1,                 -- AD
  ["Bleaker's Outpost"]=2,["Winter's Peak Outpost"]=2,       -- DC
  ["Sejanus Outpost"]=3,["Harlun's Outpost"]=3,              -- EP
}
local TOWNS = { ["Vlastarus"]=1,["Bruma"]=2,["Cropsford"]=3 }

-- Canonicalize names (trim/spell)
local function canon(s)
  if not s then return "" end
  s = string.gsub(s, "’", "'")
  s = string.gsub(s, "^%s*(.-)%s*$", "%1")
  return s
end

-- Native lookup by name
local NATIVE_BY_NAME = {}
local function buildNativeIndex()
  NATIVE_BY_NAME = {}
  for k,v in pairs(HOME_KEEPS) do NATIVE_BY_NAME[canon(k)] = v end
  for k,v in pairs(OUTPOSTS)  do NATIVE_BY_NAME[canon(k)] = v end
  for k,v in pairs(TOWNS)     do NATIVE_BY_NAME[canon(k)] = v end
end
buildNativeIndex()

-- Map resource base tokens -> parent keep name (for territory hints)
local TOKEN_TO_KEEP = {
  ["Alessia"]="Castle Alessia",["Black Boot"]="Castle Black Boot",["Bloodmayne"]="Castle Bloodmayne",
  ["Brindle"]="Castle Brindle",["Faregyl"]="Castle Faregyl",["Roebeck"]="Castle Roebeck",
  ["Aleswell"]="Fort Aleswell",["Ash"]="Fort Ash",["Dragonclaw"]="Fort Dragonclaw",
  ["Glademist"]="Fort Glademist",["Rayles"]="Fort Rayles",["Warden"]="Fort Warden",
  ["Arrius"]="Arrius Keep",["Blue Road"]="Blue Road Keep",["Chalman"]="Chalman Keep",
  ["Drakelowe"]="Drakelowe Keep",["Kingscrest"]="Kingscrest Keep",["Farragut"]="Farragut Keep",
}

local function stripResourceSuffix(name)
  local n = canon(name)
  n = n:gsub("%s+Farm$", ""):gsub("%s+Mine$", ""):gsub("%s+Lumbermill$", "")
  return n
end

local function parentKeepForResource(name)
  local base = stripResourceSuffix(name)
  return TOKEN_TO_KEEP[base]
end

--------------------------------------------------------------
-- Helpers
--------------------------------------------------------------
local function nowMs() return GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or (os.time()*1000) end
local function NormalizeAlliance(a) if type(a)~="number" then return ALLIANCE_NONE else return a end end
local function SafeColor(a) return (FACTION[a] and FACTION[a].color) or "|cFFFFFF" end
local function SafeName(a)  return (FACTION[a] and FACTION[a].name)  or "Unknown" end

local function getKeepType(keepId)
  if type(GetKeepType)~="function" then return 0 end
  return GetKeepType(keepId)
end

local function isCoreKeep(keepId) return getKeepType(keepId) == KEEP_TYPE_KEEP end
local function isOutpost(keepId)  return getKeepType(keepId) == KEEP_TYPE_OUTPOST end
local function isTown(keepId)     return getKeepType(keepId) == KEEP_TYPE_TOWN end
local function isResource(keepId) return getKeepType(keepId) == KEEP_TYPE_RESOURCE end

--------------------------------------------------------------
-- Live state memory per objective (by keepId)
--------------------------------------------------------------
-- lastUnderAlert: anti-spam clock for repeated under-attack reminders
local STATE = {} -- [keepId] = {name, owner, under, lastMsgAt, lastUnderAlert, battleOwner, territory, otype}

local function resolveTerritory(name, keepId)
  local key = canon(name)
  local native = NATIVE_BY_NAME[key]
  if native then return native end
  if isResource(keepId) then
    local parent = parentKeepForResource(name)
    if parent then
      local pNative = NATIVE_BY_NAME[canon(parent)]
      if pNative then return pNative end
    end
  end
  return ALLIANCE_NONE
end

local function getObjectiveType(keepId)
  local kt = getKeepType(keepId)
  if kt == KEEP_TYPE_KEEP then return "keep"
  elseif kt == KEEP_TYPE_OUTPOST then return "outpost"
  elseif kt == KEEP_TYPE_TOWN then return "town"
  elseif kt == KEEP_TYPE_RESOURCE then return "resource"
  else return "other" end
end

local function readState(keepId)
  local name = (type(GetKeepName)=="function" and GetKeepName(keepId, BG_CONTEXT)) or "?"
  local owner = (type(GetKeepAlliance)=="function" and GetKeepAlliance(keepId, BG_CONTEXT)) or ALLIANCE_NONE
  local under = (type(GetKeepUnderAttack)=="function" and GetKeepUnderAttack(keepId, BG_CONTEXT)) or false
  local otype = getObjectiveType(keepId)
  local territory = resolveTerritory(name, keepId)
  return name, owner, under, territory, otype
end

--------------------------------------------------------------
-- Resource filtering (SV): off / own / all
--------------------------------------------------------------
local function resMode() return (EOK_SV and EOK_SV.resourceMode) or "off" end
local function resAllowed(owner, myAlliance)
  local mode = resMode()
  if mode == "off" then return false end
  if mode == "all" then return true end
  return owner == myAlliance
end

--------------------------------------------------------------
-- Messaging
--------------------------------------------------------------
local function sayUnderAttack(name, owner, territory, otype, myAlliance)
  local nameC = INFO_COLOR .. name .. "|r"
  local ownerC = SafeColor(owner) .. SafeName(owner) .. "|r"

  if otype == "resource" then
    if owner == myAlliance then
      chat(string.format("%s is under attack — defend your lines!", nameC))
    else
      if resMode() == "all" then
        chat(string.format("%s is under attack — %s are defending.", nameC, ownerC))
      end
    end
    return
  end

  -- Keeps / Outposts / Towns
  if owner == myAlliance and territory == myAlliance then
    chat(string.format("%s is under attack! Defend your territory!", nameC))
  elseif owner ~= myAlliance and territory == myAlliance then
    chat(string.format("%s is under attack — chance to reclaim Dominion ground!", nameC))
  elseif owner == myAlliance and territory ~= myAlliance and territory ~= ALLIANCE_NONE then
    chat(string.format("Enemies are attempting to seize %s from the %s!", nameC, SafeName(myAlliance)))
  elseif territory ~= ALLIANCE_NONE then
    chat(string.format("Territory to be claimed by the victor at %s.", nameC))
  else
    chat(string.format("%s is in conflict.", nameC))
  end
end

local function sayResolution(name, oldOwnerAtStart, ownerNow, territory, otype, myAlliance)
  local nameC = INFO_COLOR .. name .. "|r"
  local nowC  = SafeColor(ownerNow) .. SafeName(ownerNow) .. "|r"

  if otype == "resource" then
    if ownerNow == myAlliance or resMode()=="all" then
      if ownerNow == oldOwnerAtStart then
        chat(string.format("%s is now secure. %s held.", nameC, nowC))
      else
        chat(string.format("%s is now secure. %s took control.", nameC, nowC))
      end
    end
    return
  end

  -- Keeps/Outposts/Towns
  if ownerNow == oldOwnerAtStart then
    chat(string.format("%s successfully defended %s.", SafeColor(ownerNow)..SafeName(ownerNow).."|r", nameC))
  else
    if ownerNow == territory and territory ~= ALLIANCE_NONE then
      local monarch = FACTION[ownerNow] and FACTION[ownerNow].monarch or "their ruler"
      chat(string.format("%s has reclaimed %s in the name of %s.", SafeColor(ownerNow)..SafeName(ownerNow).."|r", nameC, monarch))
    elseif ownerNow == myAlliance and territory ~= myAlliance and territory ~= ALLIANCE_NONE then
      chat(string.format("%s forces have taken %s from %s!", SafeColor(myAlliance)..SafeName(myAlliance).."|r",
                         nameC, SafeColor(territory)..SafeName(territory).."|r"))
    elseif territory == myAlliance and ownerNow ~= myAlliance then
      chat(string.format("%s have taken %s — %s territory.", SafeColor(ownerNow)..SafeName(ownerNow).."|r",
                         nameC, SafeColor(myAlliance)..SafeName(myAlliance).."|r"))
    else
      chat(string.format("%s has claimed %s.", nowC, nameC))
    end
  end
end

--------------------------------------------------------------
-- State transition handler (FIXED: first-sight & periodic under-attack)
--------------------------------------------------------------
local function handleUpdate(keepId, myAlliance, forceEvent)
  local name, owner, under, territory, otype = readState(keepId)
  if name == "?" then return end

  local st = STATE[keepId]
  local tNow = nowMs()

  if not st then
    st = {
      name=name, owner=owner, under=under, territory=territory, otype=otype,
      lastMsgAt=0, lastUnderAlert=0, battleOwner=nil
    }
    STATE[keepId] = st
    -- NEW: if we first see it already under attack, announce immediately (cooldown-respected)
    if otype ~= "resource" or resAllowed(owner, myAlliance) then
      if under and (tNow - st.lastUnderAlert >= MSG_COOLDOWN_MS) then
        st.battleOwner = owner
        sayUnderAttack(name, owner, territory, otype, myAlliance)
        st.lastUnderAlert = tNow
        st.lastMsgAt = tNow
      end
    end
    return
  end

  -- refresh static fields if changed
  st.name, st.territory, st.otype = name, territory, otype

  -- Resource visibility gating
  if otype == "resource" and not resAllowed(owner, myAlliance) then
    st.owner, st.under = owner, under
    return
  end

  local cooldownOk = (tNow - (st.lastMsgAt or 0) >= MSG_COOLDOWN_MS)
  local underCooldownOk = (tNow - (st.lastUnderAlert or 0) >= MSG_COOLDOWN_MS)

  -- ENTERING under attack OR periodic reminder while still under
  if under and (not st.under or underCooldownOk) then
    st.battleOwner = st.battleOwner or owner  -- set on first entry; keep original defender for resolution
    if cooldownOk or not st.under then
      sayUnderAttack(name, owner, territory, otype, myAlliance)
      st.lastMsgAt = tNow
      st.lastUnderAlert = tNow
    end

  -- LEAVING under attack -> resolve winner/defender
  elseif not under and st.under then
    if cooldownOk then
      sayResolution(name, st.battleOwner or st.owner, owner, territory, otype, myAlliance)
      st.lastMsgAt = tNow
    end
    st.battleOwner = nil

  -- STILL under attack, owner flipped mid-battle (flags shift)
  elseif under and owner ~= st.owner then
    if cooldownOk then
      chat(string.format("%sControl has shifted at %s — battle continues.", TEXT_DIM, INFO_COLOR..name.."|r"))
      st.lastMsgAt = tNow
    end
  end

  st.owner, st.under = owner, under
end

--------------------------------------------------------------
-- Event handlers (fast path)
--------------------------------------------------------------
local function OnKeepUnderAttackChanged(_, keepId, bgContext, underAttack)
  if bgContext ~= BG_CONTEXT or muted then return end
  local myAlliance = (GetUnitAlliance and GetUnitAlliance("player")) or ALLIANCE_NONE
  handleUpdate(keepId, myAlliance, true)
end

local function OnKeepOwnerChanged(_, keepId, bgContext, oldAlliance, newAlliance)
  if bgContext ~= BG_CONTEXT or muted then return end
  local myAlliance = (GetUnitAlliance and GetUnitAlliance("player")) or ALLIANCE_NONE
  handleUpdate(keepId, myAlliance, true)
end

--------------------------------------------------------------
-- Polling sweep (robust path)
--------------------------------------------------------------
local function PollAll()
  if muted then zo_callLater(PollAll, POLL_INTERVAL_MS); return end
  local myAlliance = (GetUnitAlliance and GetUnitAlliance("player")) or ALLIANCE_NONE
  local total = (type(GetNumKeeps)=="function" and GetNumKeeps()) or 0
  for keepId = 1, total do
    local kt = getKeepType(keepId)
    if kt == KEEP_TYPE_KEEP or kt == KEEP_TYPE_OUTPOST or kt == KEEP_TYPE_TOWN or kt == KEEP_TYPE_RESOURCE then
      handleUpdate(keepId, myAlliance, false)
    end
  end
  zo_callLater(PollAll, POLL_INTERVAL_MS)
end


--------------------------------------------------------------
--------------------------------------------------------------
-- /eyesup — counts for keeps, outposts, towns (excl. resources)
--------------------------------------------------------------
local function ReportKeepOwnership()
  local total = (type(GetNumKeeps)=="function" and GetNumKeeps()) or 0
  if total == 0 then chat("Cyrodiil data unavailable."); return end

  local keeps     = { [ALLIANCE_ALDMERI_DOMINION]=0, [ALLIANCE_DAGGERFALL_COVENANT]=0, [ALLIANCE_EBONHEART_PACT]=0 }
  local outposts  = { [ALLIANCE_ALDMERI_DOMINION]=0, [ALLIANCE_DAGGERFALL_COVENANT]=0, [ALLIANCE_EBONHEART_PACT]=0 }
  local towns     = { [ALLIANCE_ALDMERI_DOMINION]=0, [ALLIANCE_DAGGERFALL_COVENANT]=0, [ALLIANCE_EBONHEART_PACT]=0 }
  local conflicts = 0

  for keepId = 1, total do
    local kt   = getKeepType(keepId)
    local name = GetKeepName(keepId, BG_CONTEXT)
    local a    = GetKeepAlliance(keepId, BG_CONTEXT)

    if type(GetKeepUnderAttack)=="function" and GetKeepUnderAttack(keepId, BG_CONTEXT) then
      conflicts = conflicts + 1
    end

    if kt == KEEP_TYPE_KEEP then
      keeps[a] = (keeps[a] or 0) + 1
    elseif kt == KEEP_TYPE_OUTPOST then
      outposts[a] = (outposts[a] or 0) + 1
    elseif kt == KEEP_TYPE_TOWN and TOWNS[name] then
      towns[a] = (towns[a] or 0) + 1
    end
  end

  local campaign = "Unknown Campaign"
  if GetCurrentCampaignId and GetCampaignName then
    local id = GetCurrentCampaignId()
    if id and id > 0 then campaign = GetCampaignName(id) or campaign end
  end

  chat(string.format("%sEyeOnKeep|r watching over %s%s|r — Cyrodiil Intel",
    FACTION[ALLIANCE_ALDMERI_DOMINION].color, INFO_COLOR, campaign))
  chat("|cAAAAAA--------------------------------------|r")

  for id, f in pairs(FACTION) do
    if id ~= ALLIANCE_NONE then
      local k = keeps[id] or 0
      local o = outposts[id] or 0
      local t = towns[id] or 0
      chat(string.format("%s%s|r Keeps: %-2d  Outposts: %-2d  Towns: %-2d", f.color, f.name, k, o, t))
    end
  end

  chat("|cAAAAAA--------------------------------------|r")
  if conflicts > 0 then
    chat(string.format("|cFF0000%d locations currently under attack.|r", conflicts))
  else
    chat("|c00FF00No active conflicts detected.|r")
  end
end


--------------------------------------------------------------
-- Init + Loader
--------------------------------------------------------------
local function EyeOnKeep_Init()
  if _inited then return end
  _inited = true
  EOK_SV = ZO_SavedVars:NewAccountWide("EyeOnKeep_SV", EOK_SV_VERSION, nil, {excludeIC=true, resourceMode="on"})

  -- Commands
  SLASH_COMMANDS["/eyesup"] = ReportKeepOwnership
  SLASH_COMMANDS["/keepmute"] = function() muted = true;  chat("Muted") end
  SLASH_COMMANDS["/keepunmute"] = function() muted = false; chat("Unmuted") end
  SLASH_COMMANDS["/eyeonres"] = function(arg)
    arg = (arg or ""):lower()
    if arg == "" then
      local mode = (EOK_SV and EOK_SV.resourceMode) or "off"
      if mode == "off" then
        chat("Resource alerts: off")
      elseif mode == "all" then
        chat("Resource alerts: all factions")
      else
        chat("Resource alerts: your faction only")
      end
      return
    end
    if arg == "off" or arg=="0" then
      EOK_SV.resourceMode = "off"; chat("Resource alerts: off")
    elseif arg == "all" or arg == "on+" then
      EOK_SV.resourceMode = "all"; chat("Resource alerts: all factions")
    elseif arg == "on" or arg == "own" or arg == "1" then
      EOK_SV.resourceMode = "on";  chat("Resource alerts: your faction only")
    else
      chat("Usage: /eyeonres [off | on | own | all]")
    end
  end

  -- Events (fast path)
  EM:RegisterForEvent(ADDON_NAME.."_Attack", EVENT_KEEP_UNDER_ATTACK_CHANGED, OnKeepUnderAttackChanged)
  EM:RegisterForEvent(ADDON_NAME.."_Owner",  EVENT_KEEP_ALLIANCE_OWNER_CHANGED, OnKeepOwnerChanged)

  -- Start polling
  zo_callLater(PollAll, 2000)

  -- Startup line
  local myAlliance = (GetUnitAlliance and GetUnitAlliance("player")) or ALLIANCE_NONE
  local f = FACTION[myAlliance] or FACTION[ALLIANCE_NONE]
  local campaign = "Unknown Campaign"
  if GetCurrentCampaignId and GetCampaignName then
    local id = GetCurrentCampaignId()
    if id and id > 0 then campaign = GetCampaignName(id) or campaign end
  end
  chat(string.format("%sEyeOnKeep|r is watching over %s%s|r for the %s%s|r.",
    FACTION[ALLIANCE_ALDMERI_DOMINION].color, INFO_COLOR, campaign, f.color, f.name))
end

local function OnAddonLoaded(_, addon)
  if addon ~= ADDON_NAME then return end
  EM:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
  EyeOnKeep_Init()
end
EM:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
