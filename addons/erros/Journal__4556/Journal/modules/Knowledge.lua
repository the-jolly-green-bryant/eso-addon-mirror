JournalCompanion.Knowledge = {}

-- Whole-book motifs: reading the book unlocks all chapters at once.
-- IsSmithingStyleKnown(styleId, 1) is reliable for these.
-- { displayName, itemStyleId }
local WHOLE_MOTIFS = {
  { "High Elf",           7   },
  { "Dark Elf",           4   },
  { "Wood Elf",           8   },
  { "Nord",               5   },
  { "Breton",             1   },
  { "Redguard",           2   },
  { "Khajiit",            9   },
  { "Orc",                3   },
  { "Argonian",           6   },
  { "Imperial",           34  },
  { "Ancient Elf",        15  },
  { "Barbaric",           17  },
  { "Primal",             19  },
  { "Daedric",            20  },
  { "Soul Shriven",       30  },
  { "Grim Harlequin",     58  },
  { "Frostcaster",        53  },
  { "Tsaesci",            38  },
  { "Hircine Bloodhunter",151 },
}

-- Chapter motifs: each of the 14 pieces is a separate drop.
-- IsSmithingStyleKnown does NOT work per-chapter for these — it only tracks whether
-- the style is usable at the crafting bench (i.e. all chapters known), not individual
-- chapter ownership. The lore book API is the correct per-chapter source.
-- { displayName, itemStyleId, achievementId }
local CHAPTER_MOTIFS = {
  { "Dwemer",               14,  1144 },
  { "Glass",                28,  1319 },
  { "Xivkyn",               29,  1181 },
  { "Akaviri",              33,  1318 },
  { "Mercenary",            26,  1348 },
  { "Yokudan",              35,  1713 },
  { "Ancient Orc",          22,  1341 },
  { "Trinimac",             21,  1411 },
  { "Malacath",             13,  1412 },
  { "Outlaw",               47,  1417 },
  { "Aldmeri Dominion",     25,  1415 },
  { "Daggerfall Covenant",  23,  1416 },
  { "Ebonheart Pact",       24,  1414 },
  { "Ra Gada",              44,  1797 },
  { "Morag Tong",           43,  1933 },
  { "Skinchanger",          42,  1676 },
  { "Abah's Watch",         41,  1422 },
  { "Thieves Guild",        11,  1423 },
  { "Assassins League",     46,  1424 },
  { "Dro-M'Athra",          45,  1659 },
  { "Dark Brotherhood",     12,  1661 },
  { "Ebony",                40,  1798 },
  { "Draugr",               31,  1715 },
  { "Minotaur",             39,  1662 },
  { "Order of the Hour",    16,  1660 },
  { "Celestial",            27,  1714 },
  { "Hollowjack",           59,  1545 },
  { "Silken Ring",          56,  1796 },
  { "Mazzatun",             57,  1795 },
  { "Buoyant Armiger",      52,  1934 },
  { "Ashlander",            54,  1932 },
  { "Militant Ordinator",   50,  1935 },
  { "Telvanni",             51,  2023 },
  { "Hlaalu",               49,  2021 },
  { "Redoran",              48,  2022 },
  { "Bloodforge",           61,  2098 },
  { "Dreadhorn",            62,  2097 },
  { "Apostle",              65,  2044 },
  { "Ebonshadow",           66,  2045 },
  { "Fang Lair",            69,  2190 },
  { "Scalecaller",          70,  2189 },
  { "Worm Cult",            55,  2120 },
  { "Psijic",               71,  2186 },
  { "Sapiarch",             72,  2187 },
  { "Dremora",              74,  2188 },
  { "Pyandonean",           75,  2285 },
  { "Huntsman",             77,  2317 },
  { "Silver Dawn",          78,  2318 },
  { "Welkynar",             73,  2319 },
  { "Honor Guard",          80,  2359 },
  { "Dead-Water",           79,  2360 },
  { "Elder Argonian",       81,  2361 },
  { "Coldsnap",             82,  2503 },
  { "Meridian",             83,  2504 },
  { "Anequina",             84,  2505 },
  { "Pellitine",            85,  2506 },
  { "Sunspire",             86,  2507 },
  { "Dragonguard",          92,  2630 },
  { "Stags of Z'en",        89,  2629 },
  { "Moongrave Fane",       93,  2628 },
  { "Refabricated",         60,  2024 },
  { "Shield of Senchal",    95,  2750 },
  { "New Moon Priest",      94,  2748 },
  { "Icereach Coven",       97,  2747 },
  { "Pyre Watch",           98,  2749 },
  { "Blackreach Vanguard",  100, 2757 },
  { "Greymoor",             101, 2761 },
  { "Sea Giant",            102, 2762 },
  { "Ancestral Nord",       103, 2763 },
  { "Ancestral Orc",        105, 2776 },
  { "Ancestral High Elf",   104, 2773 },
  { "Thorn Legion",         106, 2849 },
  { "Hazardous Alchemy",    107, 2850 },
  { "Ancestral Akaviri",    108, 2903 },
  { "Ancestral Breton",     109, 2904 },
  { "Ancestral Reach",      110, 2905 },
  { "Nighthollow",          111, 2926 },
  { "Arkthzand Armory",     112, 2938 },
  { "Wayward Guardian",     113, 2998 },
  { "House Hexos",          114, 2959 },
  { "Waking Flame",         117, 2991 },
  { "True-Sworn",           116, 2984 },
  { "Ivory Brigade",        121, 3001 },
  { "Sul-Xan",              122, 3002 },
  { "Black Fin Legion",     120, 3000 },
  { "Ancient Daedric",      119, 2999 },
  { "Crimson Oath",         123, 3094 },
  { "Silver Rose",          124, 3097 },
  { "Annihilarch's Chosen", 125, 3098 },
  { "Fargrave Guardian",    126, 3220 },
  { "Dreadsails",           128, 3228 },
  { "Ascendant Order",      129, 3229 },
  { "Syrabanic Marine",     130, 3258 },
  { "Steadfast Society",    131, 3259 },
  { "Systres Guardian",     132, 3260 },
  { "Y'ffre's Will",        135, 3422 },
  { "Drowned Mariner",      136, 3423 },
  { "Firesong",             138, 3464 },
  { "House Mornard",        139, 3465 },
  { "Blessed Inheritor",    141, 3547 },
  { "Scribes of Mora",      140, 3546 },
  { "Clan Dreamcarver",     142, 3667 },
  { "Dead Keeper",          143, 3668 },
  { "Kindred's Concord",    144, 3669 },
  { "The Recollection",     145, 3921 },
  { "Blind Path Cultist",   146, 3922 },
  { "Shardborn",            147, 3923 },
  { "West Weald Legion",    148, 3924 },
  { "Lucent Sentinel",      149, 3925 },
  { "Exile's Revenge",      153, 4159 },
  { "Militant Monk",        154, 4160 },
  { "Stirk Fellowship",     155, 4240 },
  { "Coldharbour Dominator",156, 4241 },
  { "Tide-Born",            157, 4242 },
  { "Black Soul Gem",       158, 4289 },
  { "Voskrona Guardian",    159, 4290 },
}

local function CharacterKey()
  return GetUnitName("player")
end

local function EnsureChar(key)
  local sv = JournalCompanion.sv
  if not sv.characters[key] then
    sv.characters[key] = { knownRecipes = {}, knownMotifs = {} }
  end
  return sv.characters[key]
end

local function ScanRecipes(charData)
  local known = {}
  local numLists = GetNumRecipeLists()
  for i = 1, numLists do
    local _, numRecipes = GetRecipeListInfo(i)
    for j = 1, numRecipes do
      local isKnown, name, _, specialIngredientType = GetRecipeInfo(i, j)
      if isKnown and name and name ~= "" then
        known[#known + 1] = {
          name = name,
          plan = (specialIngredientType == PROVISIONER_SPECIAL_INGREDIENT_TYPE_FURNISHING),
        }
      end
    end
  end
  charData.knownRecipes = known
end

-- Chapter motifs store individual chapters as lore books. The achievement linked to
-- each motif style points at a lore book collection whose entries map 1:1 to chapters.
-- IsSmithingStyleKnown only returns true once ALL chapters are known (bench-usable),
-- so it cannot distinguish partial completion per chapter.
local function IsMotifChapterKnown(achievementId, chapter)
  local collId = GetAchievementLinkedBookCollectionId(achievementId)
  if not collId or collId == 0 then return false end
  local catIdx, collIdx = GetLoreBookCollectionIndicesFromCollectionId(collId)
  if not catIdx or catIdx == 0 then return false end
  local _, _, known = GetLoreBookInfo(catIdx, collIdx, chapter)
  return known == true
end

local function ScanMotifs(charData)
  local known = {}

  -- Whole-book motifs: a single read unlocks all 14 chapters simultaneously.
  -- Checking chapter 1 is sufficient since all chapters are always known together.
  for _, m in ipairs(WHOLE_MOTIFS) do
    if IsSmithingStyleKnown(m[2], 1) then
      known[m[1]] = true
    end
  end

  -- Chapter motifs: each of the 14 gear-slot chapters is a separate drop.
  -- Chapters: 1=Axes 2=Belts 3=Boots 4=Bows 5=Chest 6=Daggers 7=Gloves
  --           8=Helmet 9=Legs 10=Mace 11=Shield 12=Shoulders 13=Staves 14=Swords
  for _, m in ipairs(CHAPTER_MOTIFS) do
    local achievementId = m[3]
    local chapters = {}
    local anyKnown = false
    for ch = 1, 14 do
      if IsMotifChapterKnown(achievementId, ch) then
        chapters[ch] = true
        anyKnown = true
      end
    end
    if anyKnown then
      known[m[1]] = chapters
    end
  end

  charData.knownMotifs = known
end

local function ScanResearch(charData)
  local research = {}

  local professions = {
    { key = "blacksmithing", craftingType = CRAFTING_TYPE_BLACKSMITHING    },
    { key = "clothing",      craftingType = CRAFTING_TYPE_CLOTHIER         },
    { key = "woodworking",   craftingType = CRAFTING_TYPE_WOODWORKING      },
    { key = "jewelry",       craftingType = CRAFTING_TYPE_JEWELRYCRAFTING  },
  }

  for _, prof in ipairs(professions) do
    local lines = {}
    local numLines = GetNumSmithingResearchLines(prof.craftingType)
    for lineIndex = 1, numLines do
      local lineName, _, numTraits = GetSmithingResearchLineInfo(prof.craftingType, lineIndex)

      local lineData = { name = lineName, traits = {}, researching = {} }

      for traitIndex = 1, numTraits do
        -- traitType is the ITEM_TRAIT_TYPE_* constant — used as the key so the web
        -- side maps directly to item_trait_types.id without positional translation.
        -- This mirrors how Prices.lua already stores trait identity.
        local traitType, _, known = GetSmithingResearchLineTraitInfo(
          prof.craftingType, lineIndex, traitIndex
        )

        if known then
          lineData.traits[traitType] = "known"
        else
          -- GetSmithingResearchLineTraitTimes returns (totalDurationSecs, timeRemainingSecs).
          -- Absolute end time = now + timeRemaining, correct regardless of upload delay.
          local _, timeRemaining = GetSmithingResearchLineTraitTimes(
            prof.craftingType, lineIndex, traitIndex
          )
          if timeRemaining and timeRemaining > 0 then
            lineData.researching[traitType] = GetTimeStamp() + timeRemaining
          end
        end
      end

      lines[lineIndex] = lineData
    end
    research[prof.key] = lines
  end

  charData.research = research
end

local function ScanAlchemyTraits(charData)
  local alchemyTraits = {}

  -- REAGENT_ITEM_IDS is a static constant defined on module load — always available
  -- since Reference.lua loads before Knowledge.lua in the manifest.
  local reagentUniverse = JournalCompanion.Reference and
                          JournalCompanion.Reference.GetReagentItemIds() or {}

  for _, itemId in ipairs(reagentUniverse) do
    local link = string.format("|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId)
    local discovered = {}
    local hasAny = false
    for slot = 1, 4 do
      -- GetItemLinkReagentTraitInfo returns (isKnown, traitName) — only 2 values.
      local known = GetItemLinkReagentTraitInfo(link, slot)
      if known then
        discovered[slot] = true
        hasAny = true
      end
    end
    if hasAny then
      alchemyTraits[itemId] = discovered
    end
  end

  charData.alchemyTraits = alchemyTraits
end

function JournalCompanion.Knowledge.Scan()
  local key      = CharacterKey()
  local charData = EnsureChar(key)
  ScanRecipes(charData)
  ScanMotifs(charData)
  ScanResearch(charData)
  ScanAlchemyTraits(charData)
  charData.lastScanned = GetTimeStamp()
  JournalCompanion.sv.lastUpdated = GetTimeStamp()
end

function JournalCompanion.Knowledge.Init()
  -- Remove stale entries written under @AccountName before per-character keying was fixed
  local sv = JournalCompanion.sv
  for key in pairs(sv.characters) do
    if key:sub(1, 1) == "@" then
      sv.characters[key] = nil
    end
  end

  -- Defer scan until the player is fully in-world so the crafting style and
  -- recipe systems are ready. EVENT_ADD_ON_LOADED fires too early for this.
  EVENT_MANAGER:RegisterForEvent(
    JournalCompanion.name .. "_Knowledge",
    EVENT_PLAYER_ACTIVATED,
    function()
      EVENT_MANAGER:UnregisterForEvent(JournalCompanion.name .. "_Knowledge", EVENT_PLAYER_ACTIVATED)
      JournalCompanion.Knowledge.Scan()
    end
  )
end
