-- Data: non-drop recipes, "where to buy" as records
--
--  vendor row {
--    source = <ItemSources>, version = <Versioning>,
--    vendor = <NpcIds>, location = <ZoneIds>, place = <PlaceIds>,
--    itemPrice = <integer>, currency = <CurrencyType>,
--    achievement = <achievementId>, partOf = <folio itemId>,
--    skillLine = <SkillLineIds>, skillRank = <integer>,
--    note = <string id or literal>
-- }
--      Everything except `vendor` is optional
--      `location` is a game zone, `place` is a zone we have no id for
--          (we take place only if we don't have a location)
--      `note` adds details and is concatenated to a location
--      A row that names a `source` is scanned into the DB and must carry a `version` too
--          (writ vendor rows name none, because FurC.Rolis/FurC.Faustina already do)
--          TODO: make this more generic so we don't have to think of special cases and exceptions
--
--   quest row   { quest = true, daily = <boolean>, locations = { <ZoneIds>, ... } }
--   event row   { event = <EventIds> }, for a recipe that only drops during an event
--NOTE: Event-only recipe drops not encountered in the wild yet, except for maybe during Writhing Wall. But shortly after the recipes were made available as regular container drops. A recipe that drops normally the rest of the year needs no row at all. Whether the furnishing itself also dropped is a separate question, and its answer goes in EventItems
--

local LFC = LibFurnitureCatalogue
local npcIds = LFC.Internal.Constants.NpcIds
local placeIds = LFC.Internal.Constants.PlaceIds
local skillIds = LFC.Internal.Constants.SkillLineIds
local src = LFC.Internal.Constants.ItemSources
local ver = LFC.Internal.Constants.Versioning
local zoneIds = LFC.Internal.Constants.ZoneIds

local artaeum = zoneIds.ARTAEUM
local nalirsewen = npcIds.PSIJIC_NALIRSEWEN
local skillPsijic = skillIds.PSIJIC

---Psijic trader row: bought for gold on Artaeum, requires Psijic Order rank
local function psijic(price, rank)
  return {
    source = src.VENDOR,
    version = ver.ALTMER,
    vendor = nalirsewen,
    location = artaeum,
    itemPrice = price,
    skillLine = skillPsijic,
    skillRank = rank,
  }
end

-- one of its kind, custom solution for now
local daily_reward_elswhere = {
  source = src.QUEST,
  version = ver.KITTY,
  quest = true,
  daily = true,
  locations = { zoneIds.NELSWEYR, zoneIds.SELSWEYR },
}

FurC.RecipeSources = {
  [139489] = psijic(5000, 2), -- Blueprint: Psijic Chair, Arched
  [139490] = psijic(10000, 3), -- Blueprint: Psijic Table, Small
  [139493] = psijic(10000, 6), -- Pattern: Psijic Banner
  [139496] = psijic(20000, 9), -- Pattern: Psijic Banner, Large
  [141901] = psijic(25000, 9), -- Pattern: Psijic Banner, Long
  [139487] = psijic(5000, 1), -- Praxis: Book Row, Levitating
  [139488] = psijic(5000, 1), -- Praxis: Book Stack, Levitating
  [139495] = psijic(20000, 8), -- Praxis: Psijic Lighting Globe, Large
  [139491] = psijic(10000, 4), -- Praxis: Psijic Lighting Globe, Small
  [139497] = psijic(100000, 10), -- Praxis: Psijic Table, Grand
  [139492] = psijic(20000, 5), -- Praxis: Psijic Table, Scalloped
  [139494] = psijic(20000, 7), -- Praxis: Psijic Table, Six-Fold Symmetry
  [121203] = daily_reward_elswhere, -- Praxis: Khajiit Brazier, Enchanted
}

for versionNo, rolisRecipes in pairs(FurC.RolisRecipes) do
  FurC.Rolis = FurC.Rolis or {}
  FurC.Rolis[versionNo] = FurC.Rolis[versionNo] or {}
  for recipeId, itemPrice in pairs(rolisRecipes) do
    FurC.RecipeSources[recipeId] = {
      vendor = npcIds.ROLIS,
      place = placeIds.ANY_CAPITAL,
      itemPrice = itemPrice,
      currency = CURT_WRIT_VOUCHERS,
    }
    -- Price lookup by blueprint: scanner resolves to furnishing
    FurC.Rolis[versionNo][recipeId] = itemPrice
  end
end

for versionNo, faustinaRecipes in pairs(FurC.FaustinaRecipes) do
  FurC.Faustina = FurC.Faustina or {}
  FurC.Faustina[versionNo] = FurC.Faustina[versionNo] or {}
  for recipeId, itemPrice in pairs(faustinaRecipes) do
    FurC.RecipeSources[recipeId] = {
      vendor = npcIds.FAUSTINA,
      place = placeIds.ANY_CAPITAL,
      itemPrice = itemPrice,
      currency = CURT_WRIT_VOUCHERS,
      achievement = 1801,
    }
    -- Price lookup by blueprint: scanner resolves to furnishing
    FurC.Faustina[versionNo][recipeId] = itemPrice
  end
end

for folioId, folioData in pairs(FurC.FurnishingFolios) do
  if folioData.contents then
    FurC.Faustina[folioData.version] = FurC.Faustina[folioData.version] or {}
    FurC.Recipes[folioData.version] = FurC.Recipes[folioData.version] or {}
    for _, recipeId in ipairs(folioData.contents) do
      FurC.RecipeSources[recipeId] = {
        vendor = npcIds.FAUSTINA,
        place = placeIds.ANY_CAPITAL,
        itemPrice = folioData.price,
        currency = CURT_WRIT_VOUCHERS,
        partOf = folioId,
      }
      -- Store as table so getRolisSource can access both price and folio
      FurC.Faustina[folioData.version][recipeId] = { itemPrice = folioData.price, partOf = folioId }
      table.insert(FurC.Recipes[folioData.version], recipeId)
    end
  end
end
