DungeonFinderPlus = DungeonFinderPlus or {}
local DFP = DungeonFinderPlus

-- ───────────────── String-Normalisierung ─────────────────
local function latinFold(s)
  if not s then return "" end
  s = s:gsub("Ä","Ae"):gsub("Ö","Oe"):gsub("Ü","Ue")
       :gsub("ä","ae"):gsub("ö","oe"):gsub("ü","ue")
       :gsub("ß","ss")
  s = s
    :gsub("[ÁÀÂÃÅĀĂĄ]","A"):gsub("[áàâãåāăą]","a")
    :gsub("[ÉÈÊËĒĔĖĘĚ]","E"):gsub("[éèêëēĕėęě]","e")
    :gsub("[ÍÌÎÏĪĬĮİ]","I"):gsub("[íìîïīĭįı]","i")
    :gsub("[ÓÒÔÕØŌŎŐ]","O"):gsub("[óòôõøōŏő]","o")
    :gsub("[ÚÙÛÜŪŬŮŰŲ]","U"):gsub("[úùûüūŭůűų]","u")
    :gsub("[ÇĆĈĊČ]","C"):gsub("[çćĉċč]","c")
    :gsub("[ÑŃŅŇ]","N"):gsub("[ñńņň]","n")
    :gsub("[ÝŸŶ]","Y"):gsub("[ýÿŷ]","y")
    :gsub("[ŽŹŻ]","Z"):gsub("[žźż]","z")
  return s
end

local function norm(s)
  if not s then return "" end
  s = latinFold(s):gsub("—","-"):gsub("–","-")
  s = s:gsub("%b()", ""):gsub("[%[%]]","")
  s = s:gsub("%s+", " ")
  return zo_strlower(zo_strtrim(s))
end

local function stripIconAndVetPrefix(s)
  if not s then return "" end
  -- UI-Icon-Tags am Anfang entfernen
  s = s:gsub("^%s*|t.-|t%s*", "")
  -- gängige Vet-Präfixe in mehreren Sprachen entfernen
  s = s:gsub("^%s*[Vv][Ee][Tt][Ee][Rr][Aa][Nn][%s%-]+", "")   -- EN "Veteran "
  s = s:gsub("^%s*[Vv]et[%s%-]+", "")                         -- Kurzform "Vet "
  s = s:gsub("^%s*[Vv]étéran[%s%-]+", "")                    -- FR "Vétéran "
  s = s:gsub("^%s*[Vv]eterano[%s%-]+", "")                   -- ES "Veterano "
  s = s:gsub("^%s*[Vv]eteranen?[%s%-]+", "")                 -- grob DE "Veteranen/ Veteran "
  return s
end


local function splitBaseAndRoman(s)
  local n = norm(s or "")
  local base, roman = n:match("^(.-)%s*%-%s*([ivx]+)$")
  if base and roman then return zo_strtrim(base), roman end
  return n, nil
end

local function seriesKeyKeepRoman(s)
  s = stripIconAndVetPrefix(s or "")
  local base, roman = splitBaseAndRoman(s)
  if not base or base=="" then return "" end
  if roman and roman~="" then return base.." - "..roman end
  return base
end


-- ───────────────── API-Helper ─────────────────
local function aName(id)
  if GetActivityName then
    local n = GetActivityName(id)
    if type(n)=="string" and n~="" then return n end
  end
  if GetActivityInfo then
    local name = select(1, GetActivityInfo(id))
    if type(name)=="string" and name~="" then return name end
  end
  return nil
end

local function aDiff(id)
  if GetActivityDifficulty then
    return GetActivityDifficulty(id)
  end
  return nil
end

local function aTypeIsDungeon(id)
  if GetActivityType then
    local t = GetActivityType(id)
    local D  = _G.LFG_ACTIVITY_DUNGEON or 2            -- Normal
    local DV = _G.LFG_ACTIVITY_MASTER_DUNGEON or 3      -- Vet
    return t == D or t == DV
  end
  return false
end


local function aZoneIsDLC(id)
  if not (GetActivityZoneId and GetZoneIndex and GetCollectibleIdForZone and GetCollectibleInfo) then return false end
  local z = GetActivityZoneId(id); if not(z and z~=0) then return false end
  local zi = GetZoneIndex(z); if not zi or zi==0 then return false end
  local cid = GetCollectibleIdForZone(zi); if not cid or cid==0 then return false end
  local nm  = select(1, GetCollectibleInfo(cid))
  return (type(nm)=="string" and nm~="")
end


local function isVeteranByInfo(id)

  if GetActivityType then
    local t = GetActivityType(id)
    if t == (_G.LFG_ACTIVITY_MASTER_DUNGEON or 3) then return true end
  end

  if GetActivityDifficulty and GetActivityDifficulty(id) == (_G.LFG_DIFFICULTY_VETERAN or 2) then
    return true
  end

  if type(GetActivityInfo) == "function" then

local _,_,_,_,_,_,_, levelMin, _, championPointsMin = GetActivityInfo(id)
    if type(championPointsMin) == "number" and championPointsMin > 0 then return true end
    if type(levelMin) == "number" and levelMin >= 50 then return true end
  end
  return false
end

-- ───────────────── Export ─────────────────
DFP.Dungeons = { series = {} }

function DFP.Dungeons:Rebuild()
  local S = {}

  -- Vollscan:
  for id = 1, 12000 do
    local name = aName(id)
    if name and name ~= "" and aTypeIsDungeon(id) then
      local key = seriesKeyKeepRoman(name)
      if key ~= "" then
        local e = S[key]
        if not e then
          e = { pretty = name, ids = {}, anyDungeon = true, isDLC = false }
          S[key] = e
        end
        e.ids[#e.ids+1] = id
      end
    end
  end

  -- Normal/Vet pro Dungeon-Serie bestimmen
  for _, e in pairs(S) do
    if e.anyDungeon and e.ids and #e.ids > 0 then
      local nId, vId = nil, nil
      for _, id in ipairs(e.ids) do
        if isVeteranByInfo(id) then
          vId = vId or id
        else
          nId = nId or id
        end
      end

      -- Fehlermeldung
      if not nId then
        d("|cFF4444[DFP]|r Keine Normal-ID gefunden für: " .. (e.pretty or "?"))
      end
      if not vId then
        d("|cFF4444[DFP]|r Keine Veteran-ID gefunden für: " .. (e.pretty or "?"))
      end

      e.normalId, e.vetId = nId, vId
      local probe = vId or nId or e.ids[1]
      e.isDLC = aZoneIsDLC(probe or 0)
    end
  end

  local OUT = {}
  for key, e in pairs(S) do
    if e.anyDungeon and (e.normalId or e.vetId) then
      OUT[key] = {
        pretty   = e.pretty or key,
        normalId = e.normalId,
        vetId    = e.vetId,
        isDLC    = e.isDLC and true or false,
      }
    end
  end
  self.series = OUT
end

function DFP.Dungeons:Iter()
  local t = {}
  for key, e in pairs(self.series) do
    t[#t+1] = { key=key, pretty=e.pretty, normalId=e.normalId, vetId=e.vetId, isDLC=e.isDLC }
  end
  table.sort(t, function(a,b) return (a.pretty or a.key) < (b.pretty or b.key) end)
  local i = 0
  return function() i=i+1; local r=t[i]; if not r then return nil end; return r.key, r end
end
