LibSideQuestPins = LibSideQuestPins or {}
local lib = LibSideQuestPins
lib.name = "LibSideQuestPins"
lib.version = "0.1.0"

-- Data is loaded from data/LibSideQuestPins_Compact.lua into lib.data
lib.data = lib.data or {}

-- Quest name lookup (English). Returns nil if unknown.
function lib:GetQuestName(questId)
  return lib.data.questNames and lib.data.questNames[questId]
end

-- Returns array of questIds for a zoneKey, or nil.
function lib:GetZoneQuestIds(zoneKey)
  return lib.data.zoneQuestIds and lib.data.zoneQuestIds[zoneKey]
end

-- Returns questPins record for a questId, or nil.
-- Record shape: { zone = "alikr", pins = { {pinId=..., x=..., y=...}, ... } }
function lib:GetQuestPins(questId)
  return lib.data.questPins and lib.data.questPins[questId]
end

-- Iterator over pins for a zoneKey.
-- Yields: questId, x, y, startIndex, startTotal
function lib:IterZone(zoneKey)
  local qids = self:GetZoneQuestIds(zoneKey)
  if not qids then
    return function() return nil end
  end

  local qi = 0
  local curQuestId = nil
  local curPins = nil
  local pi = 0
  local ptot = 0

  return function()
    while true do
      -- advance pin within current quest if possible
      if curPins and pi < ptot then
        pi = pi + 1
        local p = curPins[pi]
        if p and p.x and p.y then
          return curQuestId, p.x, p.y, pi, ptot
        end
        -- if malformed pin, keep looping
      else
        -- move to next quest
        qi = qi + 1
        if qi > #qids then
          return nil
        end
        curQuestId = qids[qi]
        local rec = self:GetQuestPins(curQuestId)
        curPins = rec and rec.pins or nil
        pi = 0
        ptot = (curPins and #curPins) or 0
        -- loop back and emit first valid pin
      end
    end
  end
end


-- ============================================================================
-- MapId support (console-safe)
-- PinIds in the compact data are formatted like:
--   "<zoneKey>:<mapId>:<x>:<y>:<iconType>"
-- We build a lazy index: mapId -> { {questId,x,y,si,st}, ... }
-- ============================================================================

local function parseMapId(pinId)
  if type(pinId) ~= "string" then return nil end
  -- fast parse: take the 2nd colon-delimited field
  local _, _, mapIdStr = pinId:find("^[^:]+:([^:]+):")
  if not mapIdStr then return nil end
  local mapId = tonumber(mapIdStr)
  return mapId
end

function lib:BuildMapIdIndex()
  if self._mapIdIndexBuilt then return end
  self._mapIdIndexBuilt = true
  self._mapIdIndex = {}

  local qp = self.data and self.data.questPins
  if type(qp) ~= "table" then return end

  for questId, rec in pairs(qp) do
    local pins = rec and rec.pins
    if type(pins) == "table" then
      local tot = #pins
      for i = 1, tot do
        local p = pins[i]
        if p and type(p.x) == "number" and type(p.y) == "number" then
          local mid = parseMapId(p.pinId)
          if mid then
            local list = self._mapIdIndex[mid]
            if not list then
              list = {}
              self._mapIdIndex[mid] = list
            end
            list[#list + 1] = { questId = questId, x = p.x, y = p.y, si = i, st = tot }
          end
        end
      end
    end
  end
end

-- Iterator over pins for a mapId.
-- Yields: questId, x, y, startIndex, startTotal
function lib:IterMapId(mapId)
  self:BuildMapIdIndex()
  local list = self._mapIdIndex and self._mapIdIndex[mapId]
  if type(list) ~= "table" then
    return function() return nil end
  end
  local i = 0
  local n = #list
  return function()
    i = i + 1
    if i > n then return nil end
    local e = list[i]
    return e.questId, e.x, e.y, e.si or 1, e.st or 1
  end
end

return lib
