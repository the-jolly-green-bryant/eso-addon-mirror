-- FurnitureCatalogue export helpers.
--
-- Works on either dump: the compact SavedVariables table or the rendered file.
--   local Export = assert(loadfile("<stem>_api.lua"))()
--   local db = Export(FurCDev_SavedVariables.compact)
--   for _, line in ipairs(db.Describe(139369)) do print(line.label, line.price) end

-- Rows are counted sections of numbers, flat to keep the DB small:
--   nSrc, src...  nMat, (matId, qty)...  nPack, packId...
--   nInfo, (srcIndex, vendor, location, event, fromItem, achievement, achievementText, currency, amount, lastSeen)...
--   nTxt, (srcIndex, textRef)...
-- vendor/location/event/lastSeen index SOURCE_TEXTS, 0 when absent. Use the accessors.
local function sections(row)
  local i = 1
  local nSrc = row[i]
  local oSrc = i + 1
  i = oSrc + nSrc
  local nMat = row[i]
  local oMat = i + 1
  i = oMat + nMat * 2
  local nPack = row[i]
  local oPack = i + 1
  i = oPack + nPack
  local nInfo = row[i]
  local oInfo = i + 1
  i = oInfo + nInfo * 10
  local nTxt = row[i]
  local oTxt = i + 1
  return nSrc, oSrc, nMat, oMat, nPack, oPack, nInfo, oInfo, nTxt, oTxt
end

local function SourceCount(row)
  local n = sections(row)
  return n
end

local function GetSource(row, n)
  local nSrc, oSrc = sections(row)
  if n < 1 or n > nSrc then return nil end
  return row[oSrc + n - 1]
end

local function MaterialCount(row)
  local _, _, nMat = sections(row)
  return nMat
end

local function GetMaterial(row, n)
  local _, _, nMat, oMat = sections(row)
  if n < 1 or n > nMat then return nil end
  local at = oMat + (n - 1) * 2
  return row[at], row[at + 1]
end

local function PackCount(row)
  local _, _, _, _, nPack = sections(row)
  return nPack
end

local function GetPack(row, n)
  local _, _, _, _, nPack, oPack = sections(row)
  if n < 1 or n > nPack then return nil end
  return row[oPack + n - 1]
end

local function InfoCount(row)
  local _, _, _, _, _, _, nInfo = sections(row)
  return nInfo
end

local function GetInfo(row, n)
  local _, _, _, _, _, _, nInfo, oInfo = sections(row)
  if n < 1 or n > nInfo then return nil end
  local at = oInfo + (n - 1) * 10
  return row[at], row[at + 1], row[at + 2], row[at + 3], row[at + 4],
    row[at + 5], row[at + 6], row[at + 7], row[at + 8], row[at + 9]
end

local function TextCount(row)
  local _, _, _, _, _, _, _, _, nTxt = sections(row)
  return nTxt
end

local function GetText(row, n)
  local _, _, _, _, _, _, _, _, nTxt, oTxt = sections(row)
  if n < 1 or n > nTxt then return nil end
  local at = oTxt + (n - 1) * 2
  return row[at], row[at + 1]
end

-- ADAPTED FOR ESO ADDON LOADING (2026-08-28): same reasoning as
-- FurnitureFinder_ExportData.lua -- assign to a global instead of a bare
-- top-level return, which ESO's addon loader would otherwise discard.
FurnitureFinder_ExportAPI = function(data)
  local texts = data.sourceTexts or {}
  local currencies = data.currencies or {}
  local labels = data.sourceLabels or {}
  local names = data.itemNames or {}
  local materialNames = data.materialNames or {}

  local api = {
    data = data,
    items = data.items or {},
    SourceCount = SourceCount,
    GetSource = GetSource,
    MaterialCount = MaterialCount,
    GetMaterial = GetMaterial,
    PackCount = PackCount,
    GetPack = GetPack,
    InfoCount = InfoCount,
    GetInfo = GetInfo,
    TextCount = TextCount,
    GetText = GetText,
  }

  -- `{c<id>}` is a currency; spell it out in this dump's language
  function api.Resolve(text)
    if not text then
      return nil
    end
    return (tostring(text):gsub("{c(%d+)}", function(id)
      local currency = currencies[tonumber(id)]
      return (currency and currency.name) or ""
    end))
  end

  function api.Text(ref)
    if not ref or ref == 0 then
      return nil
    end
    return api.Resolve(texts[ref])
  end

  function api.Price(amount, currency)
    local formatted = tostring(amount or 0)
    while true do
      local replaced
      formatted, replaced = formatted:gsub("^(%-?%d+)(%d%d%d)", "%1,%2")
      if replaced == 0 then
        break
      end
    end
    local info = currencies[currency]
    return (info and formatted .. " " .. info.name) or formatted
  end

  function api.Name(itemId)
    return names[itemId]
  end

  function api.SourceLabel(sourceId)
    return labels[sourceId]
  end

  -- One entry per source, best first, with whatever detail that source carries
  function api.Describe(itemId)
    local row = api.items[itemId]
    if not row then
      return {}
    end
    local out = {}
    for n = 1, SourceCount(row) do
      out[n] = { source = GetSource(row, n), label = labels[GetSource(row, n)] }
    end
    for n = 1, InfoCount(row) do
      local idx, vendor, location, event, fromItem, achievement, achievementText, currency, amount, lastSeen =
        GetInfo(row, n)
      local entry = out[idx]
      if entry then
        entry.vendor = api.Text(vendor)
        entry.location = api.Text(location)
        entry.event = api.Text(event)
        entry.fromItem = fromItem ~= 0 and fromItem or nil
        entry.achievement = achievement ~= 0 and achievement or nil
        entry.achievementText = api.Text(achievementText)
        entry.price = amount ~= 0 and api.Price(amount, currency) or nil
        entry.lastSeen = api.Text(lastSeen)
      end
    end
    for n = 1, TextCount(row) do
      local idx, ref = GetText(row, n)
      local entry = out[idx]
      if entry then
        entry.text = api.Text(ref)
      end
    end
    return out
  end

  function api.Materials(itemId)
    local row, out = api.items[itemId], {}
    if not row then
      return out
    end
    for n = 1, MaterialCount(row) do
      local id, quantity = GetMaterial(row, n)
      out[n] = { id = id, quantity = quantity, name = materialNames[id] }
    end
    return out
  end

  return api
end
