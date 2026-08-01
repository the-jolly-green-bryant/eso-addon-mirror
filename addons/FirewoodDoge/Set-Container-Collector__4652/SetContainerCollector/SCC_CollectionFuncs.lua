SetContainerCollector = SetContainerCollector or {}
local SCC = SetContainerCollector

local tos = tostring
local LibSets = LibSets

-- Cyrodiil elite monster gear (711-713): head and shoulder boxes are separate itemIds.
local CYRO_ELITE_MONSTER_SET_IDS = {
  [711] = true,
  [712] = true,
  [713] = true,
}

local MONSTER_SET_TYPES = {
  [LIBSETS_SETTYPE_MONSTER] = true,
  [LIBSETS_SETTYPE_IMPERIALCITY_MONSTER] = true,
  [LIBSETS_SETTYPE_CYRODIIL_MONSTER] = true,
}

local poolPieceCache = {}

-- ---------------------------------------------------------------------------
-- Container link resolution
-- ---------------------------------------------------------------------------

local function ResolveSetFromContainerLink(itemLink)
  if not itemLink or itemLink == "" then return nil, nil end
  if not GetItemLinkNumContainerSetIds or not GetItemLinkContainerSetInfo then
    return nil, nil
  end

  local numContainerSets = GetItemLinkNumContainerSetIds(itemLink)
  if not numContainerSets or numContainerSets <= 0 then
    return nil, nil
  end

  local _, setName, _, _, _, setId = GetItemLinkContainerSetInfo(itemLink, 1)
  if setId and setId > 0 then
    return setId, setName
  end

  return nil, nil
end

local function IsSetContainerItemLink(itemLink)
  if not itemLink or itemLink == "" then return false end

  if SCC.Data.Containers[GetItemLinkItemId(itemLink)] then
    return true
  end

  if GetItemLinkSetInfo(itemLink) then
    return false
  end

  if not GetItemLinkNumContainerSetIds then return false end
  local numContainerSets = GetItemLinkNumContainerSetIds(itemLink)
  return numContainerSets ~= nil and numContainerSets > 0
end

local function IsMonsterSet(setId)
  if not setId or not LibSets or not LibSets.GetSetType then return false end
  return MONSTER_SET_TYPES[LibSets:GetSetType(setId)] == true
end

local function IsSingleSetContainer(itemLink)
  if not GetItemLinkNumContainerSetIds then return false end
  return GetItemLinkNumContainerSetIds(itemLink) == 1
end

local function InferEquipSlotFromContainerLink(itemLink, setId)
  if not itemLink or itemLink == "" or not setId then return nil end
  if not IsSingleSetContainer(itemLink) or not IsMonsterSet(setId) then return nil end
  if CYRO_ELITE_MONSTER_SET_IDS[setId] then return nil end
  return EQUIP_TYPE_SHOULDERS
end

local function BuildAutoResolvedDef(setId, label, itemLink)
  local def = {
    type = "set",
    setId = setId,
    label = label or GetItemSetName(setId),
    autoResolved = true,
  }

  local inferredSlot = InferEquipSlotFromContainerLink(itemLink, setId)
  if inferredSlot then
    def.equipSlot = inferredSlot
    def.inferredEquipSlot = true
  end

  return def
end

-- ---------------------------------------------------------------------------
-- Collection piece filtering
-- ---------------------------------------------------------------------------

local function Linkify(itemId)
  return "|H1:item:" .. itemId .. ":1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
end

local function NormalizePieceFilter(filterOrEquipSlot)
  if filterOrEquipSlot == nil then return nil end
  if type(filterOrEquipSlot) == "table" then
    return filterOrEquipSlot
  end
  return { equipSlot = filterOrEquipSlot }
end

local function EquipSlotMatchesCollectionSlot(equipSlot, collectionSlot)
  if equipSlot == EQUIP_TYPE_HEAD then
    return collectionSlot == ITEM_SET_COLLECTION_SLOT_HEAD
  end
  if equipSlot == EQUIP_TYPE_SHOULDERS then
    return collectionSlot == ITEM_SET_COLLECTION_SLOT_SHOULDERS
  end
  return false
end

local function PieceMatchesFilter(pieceId, filter, collectionSlot)
  if filter == nil then return true end

  local itemLink = Linkify(pieceId)
  if filter.equipSlot ~= nil then
    local matchesEquipType = GetItemLinkEquipType(itemLink) == filter.equipSlot
    local matchesCollectionSlot = EquipSlotMatchesCollectionSlot(filter.equipSlot, collectionSlot)
    if not matchesEquipType and not matchesCollectionSlot then
      return false
    end
  end
  if filter.weaponType ~= nil and GetItemLinkWeaponType(itemLink) ~= filter.weaponType then
    return false
  end
  return true
end

function SCC.GetCollectionPiecesForSet(setId, filterOrEquipSlot)
  local filter = NormalizePieceFilter(filterOrEquipSlot)
  local pieces = {}
  local numPieces = GetNumItemSetCollectionPieces(setId)
  for i = 1, numPieces do
    local pieceId, collectionSlot = GetItemSetCollectionPieceInfo(setId, i)
    if pieceId and pieceId > 0 and PieceMatchesFilter(pieceId, filter, collectionSlot) then
      pieces[#pieces + 1] = pieceId
    end
  end
  return pieces
end

function SCC.GetCollectionPiecesForSetIds(setIds, filterOrEquipSlot)
  local pieces = {}
  local seen = {}
  for _, setId in ipairs(setIds) do
    for _, pieceId in ipairs(SCC.GetCollectionPiecesForSet(setId, filterOrEquipSlot)) do
      if not seen[pieceId] then
        seen[pieceId] = true
        pieces[#pieces + 1] = pieceId
      end
    end
  end
  return pieces
end

function SCC.GetCollectionStats(pieceIds)
  local known = 0
  for _, pieceId in ipairs(pieceIds) do
    if IsItemSetCollectionPieceUnlocked(pieceId) then
      known = known + 1
    end
  end
  return known, #pieceIds
end

local function GetProgressColor(known, total)
  if known == 0 then
    return SCC.savedVariables.colorUnknown
  end
  if known >= total then
    return SCC.savedVariables.colorKnown
  end
  return SCC.savedVariables.colorPartial
end

function SCC.FormatProgressText(known, total)
  local progress = zo_strformat(GetString(SI_SCC_TOOLTIP_PROGRESS), known, total)
  return string.format("|c%06X%s|r", GetProgressColor(known, total), progress)
end

local function GetContainerPieceFilter(containerDef)
  if containerDef.equipSlot == nil and containerDef.weaponType == nil then
    return nil
  end
  return {
    equipSlot = containerDef.equipSlot,
    weaponType = containerDef.weaponType,
  }
end

local function BuildCollectionSummary(label, setIds, pieces)
  local known, total = SCC.GetCollectionStats(pieces)
  return {
    label = label,
    known = known,
    total = total,
    setCount = #setIds,
    setIds = setIds,
  }
end

local function BuildSummaryForSetContainer(containerDef)
  local setIds

  if containerDef.type == "set" then
    if not containerDef.setId then return nil end
    setIds = { containerDef.setId }
  elseif containerDef.type == "sets" then
    if not containerDef.setIds or #containerDef.setIds == 0 then return nil end
    setIds = containerDef.setIds
  else
    return nil
  end

  local pieces = SCC.GetCollectionPiecesForSetIds(setIds, GetContainerPieceFilter(containerDef))
  return BuildCollectionSummary(containerDef.label, setIds, pieces)
end

-- ---------------------------------------------------------------------------
-- Pool cache
-- ---------------------------------------------------------------------------

local function IsLibSetsReady()
  return LibSets ~= nil and LibSets.fullyLoaded == true
end

local function SetPassesPoolFilters(setId, poolDef)
  if poolDef.armorType ~= nil and not LibSets.IsArmorTypeSet(setId, poolDef.armorType) then
    return false
  end
  if poolDef.setType ~= nil and LibSets.GetSetType(setId) ~= poolDef.setType then
    return false
  end
  return true
end

local function GetSetIdsForDropMechanic(dropMechanic, poolDef)
  local setIds = {}
  local allSetIds = LibSets.GetAllSetIds()
  if not allSetIds then return setIds end

  for setId in pairs(allSetIds) do
    local mechanics = LibSets.GetDropMechanic(setId)
    if mechanics then
      for _, mechanic in ipairs(mechanics) do
        if mechanic == dropMechanic then
          if SetPassesPoolFilters(setId, poolDef or {}) then
            setIds[setId] = true
          end
          break
        end
      end
    end
  end
  return setIds
end

local function BuildPoolCacheKey(poolKey, poolDef)
  local equipSlot = poolDef.equipSlot or 0
  if poolDef.setIds then
    return poolKey .. ":setIds:" .. tos(equipSlot)
  end
  return poolKey .. ":" .. tos(poolDef.dropMechanic) .. ":"
    .. tos(poolDef.armorType or 0) .. ":" .. tos(poolDef.setType or 0) .. ":" .. tos(equipSlot)
end

function SCC.BuildPoolPieceCache()
  poolPieceCache = {}
  local libSetsReady = IsLibSetsReady()

  for poolKey, poolDef in pairs(SCC.Data.Pools) do
    local setIds

    if poolDef.setIds then
      setIds = {}
      for _, setId in ipairs(poolDef.setIds) do
        setIds[#setIds + 1] = setId
      end
    elseif poolDef.dropMechanic and libSetsReady then
      local setIdMap = GetSetIdsForDropMechanic(poolDef.dropMechanic, poolDef)
      setIds = {}
      for setId in pairs(setIdMap) do
        setIds[#setIds + 1] = setId
      end
      table.sort(setIds)
    end

    if setIds and #setIds > 0 then
      poolPieceCache[BuildPoolCacheKey(poolKey, poolDef)] = {
        label = poolDef.label,
        setIds = setIds,
        pieces = SCC.GetCollectionPiecesForSetIds(setIds, {
          equipSlot = poolDef.equipSlot,
          weaponType = poolDef.weaponType,
        }),
      }
    end
  end
end

function SCC.GetPoolCollectionSummary(poolKey)
  local poolDef = SCC.Data.Pools[poolKey]
  if not poolDef then return nil end

  local entry = poolPieceCache[BuildPoolCacheKey(poolKey, poolDef)]
  if not entry then return nil end

  return BuildCollectionSummary(entry.label, entry.setIds, entry.pieces)
end

-- ---------------------------------------------------------------------------
-- Public API
-- ---------------------------------------------------------------------------

function SCC.IsAutoResolveEnabled()
  local sv = SCC.savedVariables
  if not sv or sv.auto_resolve == nil then
    return SCC.defaultSetting.auto_resolve
  end
  return sv.auto_resolve
end

function SCC.GetContainerDefinition(itemId, itemLink)
  local def = SCC.Data.Containers[itemId]
  if def then return def end

  if not SCC.IsAutoResolveEnabled() then return nil end
  if not itemLink or itemLink == "" or not IsSetContainerItemLink(itemLink) then return nil end

  local setId, setName = ResolveSetFromContainerLink(itemLink)
  if setId and setId > 0 then
    return BuildAutoResolvedDef(setId, setName, itemLink)
  end

  return nil
end

function SCC.GetContainerCollectionSummary(containerDef)
  if containerDef.type == "pool" then
    return SCC.GetPoolCollectionSummary(containerDef.poolKey)
  end
  return BuildSummaryForSetContainer(containerDef)
end

function SCC.PrintPoolSummary(poolKey)
  local summary = SCC.GetPoolCollectionSummary(poolKey)
  if not summary then
    d(zo_strformat(GetString(SI_SCC_SLASH_POOL_UNKNOWN), poolKey))
    return
  end
  d(zo_strformat(GetString(SI_SCC_SLASH_POOL_RESULT), summary.label, summary.known, summary.total))
end

function SCC.DebugItemLink(itemLink)
  if not itemLink or itemLink == "" then
    d("[SCC] debuglink: empty itemLink")
    return
  end

  local itemId = GetItemLinkItemId(itemLink)
  local containerDef = SCC.GetContainerDefinition(itemId, itemLink)
  local summary = containerDef and SCC.GetContainerCollectionSummary(containerDef) or nil
  local resolvedSetId, resolvedSetName = ResolveSetFromContainerLink(itemLink)

  d(string.format(
    "[SCC] itemId=%s name=%s registry=%s auto=%s resolved=%s (%s) equipSlot=%s collected=%s/%s",
    tos(itemId),
    GetItemLinkName(itemLink) or "",
    tos(SCC.Data.Containers[itemId] ~= nil),
    tos(containerDef and containerDef.autoResolved or false),
    tos(resolvedSetId),
    resolvedSetName or "",
    tos(containerDef and containerDef.equipSlot or "none"),
    tos(summary and summary.known or "?"),
    tos(summary and summary.total or "?")
  ))
end

function SCC.WaitForLibSets(callback, attemptsLeft)
  attemptsLeft = attemptsLeft or 50
  if IsLibSetsReady() then
    callback()
    return
  end
  if attemptsLeft <= 0 then return end
  zo_callLater(function()
    SCC.WaitForLibSets(callback, attemptsLeft - 1)
  end, 200)
end
