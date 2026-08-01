JournalCompanion.Reference = {}

-- Bump to force a rescan next login when scan logic changes (e.g. new fields added).
local LATEST_SCAN_VERSION = 3

-- Reagent item IDs sourced from LibAlchemy (https://github.com/Hyperioxes/LibAlchemy),
-- cross-referenced with UESP's Online:Alchemy/Reagents page. These are facts about
-- ESO's published content; the structure, ordering, and any commentary below is
-- this addon's own.
-- To look up an item ID in-game: hover the item and run
--   /script d(GetItemLinkItemId(LINK))  where LINK is pasted from chat.
-- Wrong IDs: GetItemLinkName returns "" for unknown IDs and those entries are
-- silently skipped — incorrect IDs are harmless. Missing IDs leave gaps in
-- alchemy trait coverage for those reagents.
JournalCompanion.Reference.REAGENT_ITEM_IDS = {
  -- 34 reagents as of Update 41 / Gold Road era, sorted alphabetically.
  77583,  -- Beetle Scuttle
  30157,  -- Blessed Thistle
  30148,  -- Blue Entoloma
  30160,  -- Bugloss
  77585,  -- Butterfly Wing
  150669, -- Chaurus Egg
  139020, -- Clam Gall
  30164,  -- Columbine
  30161,  -- Corn Flower
  150672, -- Crimson Nirnroot
  150789, -- Dragon Bile
  150731, -- Dragon Blood
  150671, -- Dragon Rheum
  30162,  -- Dragonthorn
  30151,  -- Emetic Russula
  77587,  -- Fleshfly Larva
  30156,  -- Imp Stool
  30158,  -- Lady's Smock
  30155,  -- Luminous Russula
  139019, -- Mother of Pearl
  30163,  -- Mountain Flower
  77591,  -- Mudcrab Chitin
  30153,  -- Namira's Rot
  77590,  -- Nightshade
  30165,  -- Nirnroot
  77589,  -- Scrib Jelly
  77584,  -- Spider Egg
  30149,  -- Stinkhorn
  77581,  -- Torchbug Thorax
  150670, -- Vile Coagulant
  30152,  -- Violet Coprinus
  30166,  -- Water Hyacinth
  30154,  -- White Cap
  30159,  -- Wormwood
}

local function EnsureReferenceTable()
  local sv = JournalCompanion.sv
  if not sv.referenceData then
    sv.referenceData = {
      researchLines        = {},
      reagents             = {},
      scannedAtApiVersion  = nil,
      scannedAtScanVersion = nil,
    }
  end
  return sv.referenceData
end

local function ScanResearchLines(refData)
  local researchLines = {}

  local professions = {
    { key = "blacksmithing", craftingType = CRAFTING_TYPE_BLACKSMITHING    },
    { key = "clothing",      craftingType = CRAFTING_TYPE_CLOTHIER         },
    { key = "woodworking",   craftingType = CRAFTING_TYPE_WOODWORKING      },
    { key = "jewelry",       craftingType = CRAFTING_TYPE_JEWELRYCRAFTING  },
  }

  for _, prof in ipairs(professions) do
    local numLines = GetNumSmithingResearchLines(prof.craftingType)
    for lineIndex = 1, numLines do
      local name, _, numTraits = GetSmithingResearchLineInfo(prof.craftingType, lineIndex)
      researchLines[#researchLines + 1] = {
        profession = prof.key,
        index      = lineIndex,
        name       = name,
        traitCount = numTraits,
      }
    end
  end

  refData.researchLines = researchLines
end

local function ScanReagents(refData)
  -- For each reagent, capture its display name and the four canonical trait identities
  -- by slot. Trait IDENTITY (e.g. "Restore Health") is static per reagent — every
  -- player learns the same trait for slot 1 of Mountain Flower. Whether THIS player
  -- has discovered it is captured separately by Knowledge.ScanAlchemyTraits.
  local reagents = {}

  for _, itemId in ipairs(JournalCompanion.Reference.REAGENT_ITEM_IDS) do
    local link = string.format("|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId)
    local name = GetItemLinkName(link)

    if name and name ~= "" then
      local traits = {}
      for slot = 1, 4 do
        -- GetItemLinkReagentTraitInfo returns (isKnown, traitName). Discard the
        -- boolean — we want the static trait identity, not per-character discovery.
        local _, traitName = GetItemLinkReagentTraitInfo(link, slot)
        traits[slot] = traitName or ""
      end

      reagents[#reagents + 1] = {
        itemId = itemId,
        name   = name,
        traits = traits,
      }
    end
  end

  refData.reagents = reagents
end

function JournalCompanion.Reference.GetReagentItemIds()
  return JournalCompanion.Reference.REAGENT_ITEM_IDS
end

function JournalCompanion.Reference.Scan()
  local refData = EnsureReferenceTable()
  local currentApiVersion = GetAPIVersion()

  if refData.scannedAtApiVersion == currentApiVersion
     and refData.scannedAtScanVersion == LATEST_SCAN_VERSION then
    return
  end

  ScanResearchLines(refData)
  ScanReagents(refData)

  refData.scannedAtApiVersion  = currentApiVersion
  refData.scannedAtScanVersion = LATEST_SCAN_VERSION
end

function JournalCompanion.Reference.Init()
  -- Defer until fully in-world. Same pattern as Knowledge — crafting APIs are not
  -- guaranteed to be available during EVENT_ADD_ON_LOADED.
  EVENT_MANAGER:RegisterForEvent(
    JournalCompanion.name .. "_Reference",
    EVENT_PLAYER_ACTIVATED,
    function()
      EVENT_MANAGER:UnregisterForEvent(JournalCompanion.name .. "_Reference", EVENT_PLAYER_ACTIVATED)
      JournalCompanion.Reference.Scan()
    end
  )
end
