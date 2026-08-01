-- Master Writ Core Logic - Library-Enhanced Version
-- Handles the main craftability checking functionality with library integration

local MasterWritCore = {}

-- Verbose trait debug control (set to true for detailed trait comparison output)
local VERBOSE_TRAIT_DEBUG = false

-- Clean debug control (set to true for simple MATCH FOUND/NO MATCH output)
local CLEAN_TRAIT_DEBUG = true

-- Use global DebugLog function (controlled by global debug system)
local function DebugLog(message)
    if _G.DebugLog then
        _G.DebugLog(message)
    end
end

-- Verbose debug function for detailed trait comparisons
local function VerboseDebugLog(message)
    if VERBOSE_TRAIT_DEBUG then
        DebugLog(message)
    end
end

-- Clean debug function for simple match results
local function CleanDebugLog(message)
    if CLEAN_TRAIT_DEBUG then
        DebugLog(message)
    end
end

-- Library manager reference (will be available globally)
local function GetLibraryManager()
    return _G.LibraryManager
end

-- Basic racial styles checked via Achievement 1025
local BASIC_RACIAL_STYLES = {
    "breton", "redguard", "orc", "nord", "dunmer", "argonian",
    "altmer", "bosmer", "khajiit", "imperial", "daedric"
}

-- Individual Style Master achievement names (comprehensive list from UESP)
local INDIVIDUAL_STYLE_ACHIEVEMENTS = {
    -- Basic DLC/Expansion Styles
    ["abah's watch"] = "Abah's Watch Style Master",
    ["akaviri"] = "Akaviri Style Master",
    ["aldmeri dominion"] = "Aldmeri Dominion Style Master",
    ["ancient daedric"] = "Ancient Daedric Style Master",
    ["ancient orc"] = "Ancient Orc Style Master",
    ["anequina"] = "Anequina Style Master",
    ["apostle"] = "Apostle Style Master",
    ["ascendant order"] = "Ascendant Order Style Master",
    ["ashlander"] = "Ashlander Style Master",
    ["assassins league"] = "Assassins League Style Master",
    ["buoyant armiger"] = "Buoyant Armiger Style Master",
    ["celestial"] = "Celestial Style Master",
    ["crimson oath"] = "Crimson Oath Style Master",
    ["daggerfall covenant"] = "Daggerfall Covenant Style Master",
    ["dark brotherhood"] = "Dark Brotherhood Style Master",
    ["dead-water"] = "Dead-Water Style Master",
    ["dragonguard"] = "Dragonguard Style Master",
    ["draugr"] = "Draugr Style Master",
    ["dreadhorn"] = "Dreadhorn Style Master",
    ["dreadsails"] = "Dreadsails Style Master",
    ["dremora"] = "Dremora Style Master",
    ["dro-m'athra"] = "Dro-m'Athra Style Master",
    ["dwemer"] = "Dwemer Style Master",
    ["ebonheart pact"] = "Ebonheart Pact Style Master",
    ["ebony"] = "Ebony Style Master",
    ["ebonshadow"] = "Ebonshadow Style Master",
    ["elder argonian"] = "Elder Argonian Style Master",
    ["fang lair"] = "Fang Lair Style Master",
    ["glass"] = "Glass Style Master",
    ["honor guard"] = "Honor Guard Style Master",
    ["huntsman"] = "Huntsman Style Master",
    ["malacath"] = "Malacath Style Master",
    ["mercenary"] = "Mercenary Style Master",
    ["minotaur"] = "Minotaur Style Master",
    ["morag tong"] = "Morag Tong Style Master",
    ["new moon priest"] = "New Moon Priest Style Master",
    ["order of the hour"] = "Order of the Hour Style Master",
    ["outlaw"] = "Outlaw Style Master",
    ["pellitine"] = "Pellitine Style Master",
    ["psijic"] = "Psijic Style Master",
    ["ra gada"] = "Ra Gada Style Master",
    ["refabricated"] = "Refabricated Style Master",
    ["sapiarch"] = "Sapiarch Style Master",
    ["scalecaller"] = "Scalecaller Style Master",
    ["shield of senchal"] = "Shield of Senchal Style Master",
    ["skinchanger"] = "Skinchanger Style Master",
    ["soul shriven"] = "Soul Shriven Style Master",
    ["stags of z'en"] = "Stags of Z'en Style Master",
    ["sunspire"] = "Sunspire Style Master",
    ["thieves guild"] = "Thieves Guild Style Master",
    ["trinimac"] = "Trinimac Style Master",
    ["tsaesci"] = "Tsaesci Style Master",
    ["welkynar"] = "Welkynar Style Master",
    ["worm cult"] = "Worm Cult Style Master",
    ["xivkyn"] = "Xivkyn Style Master",
    ["yokudan"] = "Yokudan Style Master",
    
    -- Morrowind/DLC Styles
    ["hlaalu"] = "Hlaalu Style Master",
    ["redoran"] = "Redoran Style Master",
    ["telvanni"] = "Telvanni Style Master",
    
    -- Ancestral Styles (Antiquities)
    ["ancestral akaviri"] = "Ancestral Akaviri Style Master",
    ["ancestral breton"] = "Ancestral Breton Style Master",
    ["ancestral high elf"] = "Ancestral High Elf Style Master",
    ["ancestral nord"] = "Ancestral Nord Style Master",
    ["ancestral orc"] = "Ancestral Orc Style Master",
    ["ancestral reach"] = "Ancestral Reach Style Master",
    
    -- Blackwood Styles
    ["black fin legion"] = "Black Fin Legion Style Master",
    ["ivory brigade"] = "Ivory Brigade Style Master",
    ["sul-xan"] = "Sul-Xan Style Master",
    
    -- Deadlands Styles
    ["annihilarch's chosen"] = "Annihilarch's Style Master",
    ["fargrave guardian"] = "Fargrave Guardian Style Master",
    ["house hexos"] = "House Hexos Style Master",
    
    -- Greymoor/Western Skyrim Styles
    ["blackreach vanguard"] = "Blackreach Vanguard Style Master",
    ["greymoor"] = "Greymoor Style Master",
    ["sea giant"] = "Sea Giant Style Master",
    ["icereach coven"] = "Icereach Coven Style Master",
    ["pyre watch"] = "Pyre Watch Style Master",
    
    -- High Isle Styles
    ["steadfast society"] = "Steadfast Society Style Master",
    ["syrabanic marine"] = "Syrabanic Marine Style Master",
    ["systres guardian"] = "Systres Guardian Style Master",
    ["ascendant order"] = "Ascendant Order Style Master",
    
    -- Galen Styles
    ["firesong"] = "Firesong Style Master",
    ["house mornard"] = "House Mornard Style Master",
    
    -- The Reach Styles
    ["arkthzand armory"] = "Arkthzand Armory Style Master",
    ["nighthollow"] = "Nighthollow Style Master",
    ["wayward guardian"] = "Wayward Guardian Style Master",
    
    -- Dungeon/Trial Styles
    ["bloodforge"] = "Bloodforge Style Master",
    ["clan dreamcarver"] = "Clan Dreamcarver Style Master",
    ["coldsnap"] = "Coldsnap Style Master",
    ["drowned mariner"] = "Drowned Mariner Style Master",
    ["hazardous alchemy"] = "Hazardous Alchemy Style Master",
    ["lucent sentinel"] = "Lucent Sentinel Style Master",
    ["mazzatun"] = "Mazzatun Style Master",
    ["meridian"] = "Meridian Style Master",
    ["moongrave"] = "Moongrave Style Master",
    ["pyandonean"] = "Pyandonean Style Master",
    ["red petal bastion"] = "Silver Rose Style Master",
    ["silken ring"] = "Silken Ring Style Master",
    ["silver dawn"] = "Silver Dawn Style Master",
    ["thorn legion"] = "Thorn Legion Style Master",
    ["true-sworn"] = "True-Sworn Style Master",
    ["waking flame"] = "Waking Flame Style Master",
    ["y'ffre's will"] = "Y'ffre's Will Style Master",
    
    -- Necrom Styles
    ["blessed inheritor"] = "Blessed Inheritor Style Master",
    ["dead keeper"] = "Dead Keeper Style Master",
    ["kindred's concord"] = "Kindred's Concord Style Master",
    ["scribes of mora"] = "Scribes of Mora Style Master",
    ["blind path cultist"] = "Blind Path Cultist Style Master",
    ["the recollection"] = "The Recollection Style Master",
    
    -- West Weald Styles
    ["shardborn"] = "Shardborn Style Master",
    ["west weald legion"] = "West Weald Legion Style Master",
    
    -- Battleground/PvP Styles
    ["militant ordinator"] = "Militant Ordinator Style Master",
    
    -- Event/Holiday Styles
    ["grim harlequin"] = "Grim Harlequin Style Master",
    ["hollowjack"] = "Happy Work For Hollowjack",
    ["horned dragon"] = "Horned Dragon Style Master",
    ["lyris's armor"] = "Lyris's Armor Style Master",
    ["silverdawn"] = "Silverdawn Style Master"
}

-- Hybrid motif checking: Achievements for racial styles, achievement search for others
local RACIAL_STYLE_ACHIEVEMENT_ID = 1025 -- "Racial Style Learned" achievement

-- Set trait requirements data (extracted from LibSets_Data_All.lua - Complete list of all 81 craftable sets)
-- Format: [setName] = traitsNeeded
local SET_TRAIT_REQUIREMENTS = {
    -- 2 traits
    ["ashen grip"] = 2,
    ["death's wind"] = 2,
    ["innate axiom"] = 2,
    ["naga shaman"] = 2,
    ["night's silence"] = 2,
    
    -- 3 traits
    ["adept rider"] = 3,
    ["armor of the seducer"] = 3,
    ["assassin's guile"] = 3,
    ["critical riposte"] = 3,
    ["daring corsair"] = 3,
    ["dauntless combatant"] = 3,
    ["hist whisperer"] = 3,
    ["old growth brewer"] = 3,
    ["order's wrath"] = 3,
    ["red eagle's fury"] = 3,
    ["spell parasite"] = 3,
    ["telvanni efficiency"] = 3,
    ["tharriker's strike"] = 3,
    ["torug's pact"] = 3,
    ["trial by fire"] = 3,
    ["twilight's embrace"] = 3,
    ["unchained aggressor"] = 3,
    ["vastarie's tutelage"] = 3,
    ["wretched vitality"] = 3,
    
    -- 4 traits
    ["fortified brass"] = 4,
    ["hist bark"] = 4,
    ["magnus' gift"] = 4,
    ["might of the lost legion"] = 4,
    ["whitestrake's retribution"] = 4,
    
    -- 5 traits
    ["alessia's bulwark"] = 5,
    ["claw of the forest wraith"] = 5,
    ["diamond's victory"] = 5,
    ["fellowship's fortitude"] = 5,
    ["highland sentinel"] = 5,
    ["iron flask"] = 5,
    ["kvatch gladiator"] = 5,
    ["noble's conquest"] = 5,
    ["senche-raht's grit"] = 5,
    ["serpent's disdain"] = 5,
    ["shared burden"] = 5,
    ["shattered fate"] = 5,
    ["song of lamae"] = 5,
    ["stuhn's favor"] = 5,
    ["tava's favor"] = 5,
    ["tide-born wildstalker"] = 5,
    ["vampire's kiss"] = 5,
    
    -- 6 traits
    ["ancient dragonguard"] = 6,
    ["hunding's rage"] = 6,
    ["law of julianos"] = 6,
    ["legacy of karth"] = 6,
    ["mechanical acuity"] = 6,
    ["night mother's gaze"] = 6,
    ["shacklebreaker"] = 6,
    ["sload's semblance"] = 6,
    ["willow's path"] = 6,
    
    -- 7 traits
    ["chimera's rebuke"] = 7,
    ["clever alchemist"] = 7,
    ["deadlands demolisher"] = 7,
    ["dragon's appetite"] = 7,
    ["druid's braid"] = 7,
    ["grave-stake collector"] = 7,
    ["heartland conqueror"] = 7,
    ["redistributor"] = 7,
    ["seeker synthesis"] = 7,
    ["threads of war"] = 7,
    ["varen's legacy"] = 7,
    
    -- 8 traits
    ["coldharbour's favorite"] = 8,
    ["daedric trickery"] = 8,
    ["eyes of mara"] = 8,
    ["kagrenac's hope"] = 8,
    ["oblivion's foe"] = 8,
    ["orgnum's scales"] = 8,
    ["shalidor's curse"] = 8,
    ["spectre's eye"] = 8,
    ["way of the arena"] = 8,
    
    -- 9 traits
    ["aetherial ascension"] = 9,
    ["armor master"] = 9,
    ["eternal hunt"] = 9,
    ["morkuldin"] = 9,
    ["new moon acolyte"] = 9,
    ["nocturnal's favor"] = 9,
    ["pelinal's aptitude"] = 9,
    ["pelinal's wrath"] = 9,
    ["twice-born star"] = 9,
}

-- 100% accurate itemType normalization for motif chapter lookup
local function NormalizeItemTypeForMotifChapter(itemType)
    if not itemType then return nil end
    local map = {
        -- Chapter 1: Helmets
        ["hat"] = "helmets", ["helmet"] = "helmets", ["helm"] = "helmets",
        -- Chapter 2: Chests
        ["cuirass"] = "chests", ["jerkin"] = "chests", ["robe"] = "chests", ["jack"] = "chests",
        -- Chapter 3: Legs
        ["greaves"] = "legs", ["guards"] = "legs", ["breeches"] = "legs",
        -- Chapter 4: Boots
        ["sabatons"] = "boots", ["shoes"] = "boots", ["boots"] = "boots",
        -- Chapter 5: Gloves
        ["gauntlets"] = "gloves", ["glove"] = "gloves", ["gloves"] = "gloves", ["bracers"] = "gloves",
        -- Chapter 6: Belts
        ["sash"] = "belts", ["belt"] = "belts", ["girdle"] = "belts",
        -- Chapter 7: Shoulders
        ["epaulets"] = "shoulders", ["pauldron"] = "shoulders", ["arm cops"] = "shoulders",
        -- Chapter 8: Shields
        ["shield"] = "shields", ["shields"] = "shields",
        -- Chapter 9: Swords
        ["sword"] = "swords", ["swords"] = "swords", ["greatsword"] = "swords", ["greatswords"] = "swords",
        -- Chapter 10: Axes
        ["axe"] = "axes", ["axes"] = "axes", ["battleaxe"] = "axes", ["battleaxes"] = "axes",
        -- Chapter 11: Maces
        ["mace"] = "maces", ["maces"] = "maces", ["maul"] = "maces",
        -- Chapter 12: Daggers
        ["dagger"] = "daggers", ["daggers"] = "daggers",
        -- Chapter 13: Bows
        ["bow"] = "bows", ["bows"] = "bows",
        -- Chapter 14: Staves
        ["lightning staff"] = "staves", ["ice staff"] = "staves", ["inferno staff"] = "staves", ["restoration staff"] = "staves",
        ["frost staff"] = "staves", ["fire staff"] = "staves", ["flame staff"] = "staves"
    }
    local key = string.lower(tostring(itemType))
    return map[key] or key
end

-- Enhanced Master Writ parsing function with library integration
function MasterWritCore.ParseMasterWritRequirements(itemName, itemLink)
    local requirements = {
        style = nil,
        trait = nil,
        set = nil,
        quality = nil,
        item = nil,
        itemType = nil,
        craftType = nil,
        recipe = nil,  -- NEW: For provisioning recipes
        ingredients = nil  -- NEW: For provisioning ingredients
    }

    if not itemName then return requirements end

    -- Determine craft type from item name
    local nameLower = string.lower(itemName)
    if string.find(nameLower, "blacksmith") then
        requirements.craftType = "blacksmithing"
    elseif string.find(nameLower, "cloth") then
        requirements.craftType = "clothier"
    elseif string.find(nameLower, "wood") then
        requirements.craftType = "woodworking"
    elseif string.find(nameLower, "jewel") then
        requirements.craftType = "jewelry"
    elseif string.find(nameLower, "provision") then
        requirements.craftType = "provisioning"
    end

    -- Try enhanced parsing via GenerateMasterWritBaseText (our existing method)
    if itemLink and GenerateMasterWritBaseText then
        local success, baseText = pcall(GenerateMasterWritBaseText, itemLink)
        if success and baseText and baseText ~= "" then
            -- Parse the structured format: "Craft a Rubedite Helm; Quality: Epic; Trait: Nirnhoned; Set: Night Mother's Gaze; Style: Soul Shriven"

            -- Extract style
            local styleMatch = string.match(baseText, "Style:%s*([^;]+)")
            if styleMatch then
                requirements.style = string.lower(string.gsub(styleMatch, "^%s*(.-)%s*$", "%1"))
            end

            -- Extract trait
            local traitMatch = string.match(baseText, "Trait:%s*([^;]+)")
            if traitMatch then
                requirements.trait = string.lower(string.gsub(traitMatch, "^%s*(.-)%s*$", "%1"))
            end

            -- Extract set
            local setMatch = string.match(baseText, "Set:%s*([^;]+)")
            if setMatch then
                requirements.set = string.lower(string.gsub(setMatch, "^%s*(.-)%s*$", "%1"))
            end

            -- Extract quality
            local qualityMatch = string.match(baseText, "Quality:%s*([^;]+)")
            if qualityMatch then
                requirements.quality = string.lower(string.gsub(qualityMatch, "^%s*(.-)%s*$", "%1"))
            end

            -- Extract item type from the craft line
            -- Handle both "Craft a" and "Craft an" patterns properly
            local itemMatch = string.match(baseText, "Craft an?%s+([^;]+)")
            if itemMatch then
                requirements.item = string.lower(string.gsub(itemMatch, "^%s*(.-)%s*$", "%1"))
                requirements.itemType = MasterWritCore.ParseItemType(requirements.item, requirements.craftType)
            end

            -- NEW: Provisioning-specific parsing
            if requirements.craftType == "provisioning" then
                -- For provisioning, the "item" is actually the recipe name
                if requirements.item then
                    requirements.recipe = requirements.item
                    requirements.itemType = "recipe"  -- Provisioning doesn't have style/trait/set requirements
                end
            end
        end
    end

    return requirements
end

-- Direct item type extraction - returns exact research line names
function MasterWritCore.ParseItemType(itemName, craftType)
    if not itemName then return nil end

    local itemLower = string.lower(itemName)
    
    -- Handle staff types specifically (they have separate research lines)
    if string.find(itemLower, "staff") then
        if string.find(itemLower, "lightning") or string.find(itemLower, "shock") then
            return "Lightning Staff"
        elseif string.find(itemLower, "frost") or string.find(itemLower, "ice") then
            return "Ice Staff"  -- FIXED: Use correct ESO research line name
        elseif string.find(itemLower, "flame") or string.find(itemLower, "fire") or string.find(itemLower, "inferno") then
            return "Inferno Staff"  -- FIXED: Use correct ESO research line name
        elseif string.find(itemLower, "restoration") or string.find(itemLower, "healing") then
            return "Restoration Staff"
        else
            -- Generic staff - we'll need to determine which type from context
            DebugLog("ParseItemType: Generic staff detected, cannot determine specific type from: " .. itemName)
            return "Lightning Staff"  -- Default fallback to most common
        end
    end
    
    -- Handle shoulder armor distinction (Arm Cops vs Pauldron)
    if string.find(itemLower, "cops") or (string.find(itemLower, "shoulder") and not string.find(itemLower, "guard")) then
        -- "Rubedo Leather Arm Cops" = Medium armor shoulders
        return "Arm Cops"
    end
    
    -- Extract item type directly from Master Writ text
    -- Master Writs use exact research line names with only Robe/Jerkin exception
    local itemType = nil
    
    -- Find the item type word in the item name
    -- Typically format: "Craft a [Material] [ItemType]"
    local words = {}
    for word in string.gmatch(itemLower, "%S+") do
        table.insert(words, word)
    end
    
    -- Look for item type in the words (usually the last meaningful word)
    for i = #words, 1, -1 do
        local word = words[i]
        -- Skip common non-item words
        if word ~= "writ" and word ~= "master" and word ~= "sealed" then
            -- Handle special plural cases for motif chapter mapping
            if word == "shield" then
                itemType = "Shields"  -- CRITICAL FIX: Shield → Shields for motif chapter mapping
            -- Handle jewelry items
            elseif word == "ring" then
                itemType = "Ring"
            elseif word == "necklace" or word == "neck" then
                itemType = "Necklace"
            else
                -- Capitalize first letter to match research line names
                itemType = string.upper(string.sub(word, 1, 1)) .. string.sub(word, 2)
            end
            break
        end
    end

    return itemType
end

-- Enhanced Master Writ tooltip parsing
function MasterWritCore.ParseMasterWritTooltip(itemLink)
    if not itemLink then return nil end

    local itemName = GetItemLinkName(itemLink)
    return MasterWritCore.ParseMasterWritRequirements(itemName, itemLink)
end

-- Enhanced style checking using LibCharacterKnowledge first, then fallback systems
function MasterWritCore.IsStyleKnown(styleName)
    if not styleName then return false end

    local normalizedStyle = string.lower(styleName)
    DebugLog("=== STYLE CHECK START: " .. styleName .. " ===")

    -- First try LibCharacterKnowledge for comprehensive style detection
    local libManager = GetLibraryManager()

    if libManager and libManager.IsLibCharacterKnowledgeLoaded() then
        DebugLog("LibCharacterKnowledge is available - checking...")
        local success, styleId = pcall(function()
            return libManager.GetStyleIdFromName(styleName)
        end)

        if success and styleId then
            DebugLog("Found styleId: " .. tostring(styleId) .. " for " .. styleName)
            -- Now check if we know this style using the direct LCK API
            local LCK = _G.LibCharacterKnowledge
            if LCK and LCK.GetMotifKnowledgeForCharacter then
                -- Check if we know any motif page for this style
                local knownChapters = 0
                local totalChapters = 0
                for chapterId = 1, 14 do -- Standard motif chapters
                    totalChapters = totalChapters + 1
                    local knowledge = LCK.GetMotifKnowledgeForCharacter(styleId, chapterId)
                    if knowledge == LCK.KNOWLEDGE_KNOWN then
                        knownChapters = knownChapters + 1
                    end
                end
                DebugLog("LibCharacterKnowledge result: " .. knownChapters .. "/" .. totalChapters .. " chapters known")
                if knownChapters > 0 then
                    DebugLog("=== STYLE CHECK RESULT: TRUE (LibCharacterKnowledge) ===")
                    return true
                else
                    DebugLog("=== STYLE CHECK RESULT: FALSE (LibCharacterKnowledge - 0 chapters known) ===")
                    return false
                end
            end
        else
            DebugLog("LibCharacterKnowledge could not find styleId for: " .. styleName)
        end
    else
        DebugLog("LibCharacterKnowledge not available")
    end

    -- Check if this is a basic racial style
    local isRacialStyle = false
    for _, basicStyle in ipairs(BASIC_RACIAL_STYLES) do
        if normalizedStyle == string.lower(basicStyle) then
            isRacialStyle = true
            break
        end
    end

    if isRacialStyle then
        DebugLog("Detected as racial style - checking Achievement 1025")
        -- Use Achievement 1025 for racial styles
        if IsAchievementComplete then
            local result = IsAchievementComplete(RACIAL_STYLE_ACHIEVEMENT_ID)
            DebugLog("=== STYLE CHECK RESULT: " .. tostring(result) .. " (Achievement 1025) ===")
            return result
        end
        DebugLog("=== STYLE CHECK RESULT: FALSE (Achievement API unavailable) ===")
        return false
    else
        DebugLog("Detected as advanced style - checking individual achievements")
        -- Check for individual Style Master achievements first
        local achievementName = INDIVIDUAL_STYLE_ACHIEVEMENTS[normalizedStyle]
        if achievementName then
            DebugLog("Found achievement name: " .. achievementName .. " - searching...")
            if GetAchievementInfo and IsAchievementComplete then
                -- Search for this achievement
                for achievementId = 1, 5000 do
                    local name = GetAchievementInfo(achievementId)
                    if name == achievementName then
                        local result = IsAchievementComplete(achievementId)
                        DebugLog("Found achievement ID " .. achievementId .. " for " .. achievementName .. " - Complete: " .. tostring(result))
                        DebugLog("=== STYLE CHECK RESULT: " .. tostring(result) .. " (Achievement " .. achievementId .. ") ===")
                        return result
                    end
                end
                DebugLog("Achievement not found in ID range 1-5000: " .. achievementName)
            end
        else
            DebugLog("No achievement mapping found for: " .. normalizedStyle)
        end

        DebugLog("Falling back to ESO API check...")
        -- Fallback to ESO API for advanced motifs
        if IsItemStyleKnown and GetItemStyleName then
            for styleId = 1, 200 do
                local styleName_api = GetItemStyleName(styleId)
                if styleName_api and string.lower(styleName_api) == normalizedStyle then
                    local success, isKnown = pcall(IsItemStyleKnown, styleId)
                    DebugLog("ESO API found styleId " .. styleId .. " for " .. styleName .. " - Known: " .. tostring(isKnown))
                    DebugLog("=== STYLE CHECK RESULT: " .. tostring(success and isKnown) .. " (ESO API) ===")
                    return success and isKnown
                end
            end
            DebugLog("ESO API could not find style in range 1-200: " .. styleName)
        end
        DebugLog("=== STYLE CHECK RESULT: FALSE (all methods failed) ===")
        return false
    end
end

-- Check if player knows a specific motif page for a given style and item type
function MasterWritCore.IsMotifPageKnown(styleName, itemType)
    if not styleName then return false end

    DebugLog("=== MOTIF PAGE CHECK: " .. styleName .. " for " .. tostring(itemType) .. " ===")

    local libManager = GetLibraryManager()
    if libManager and libManager.IsLibCharacterKnowledgeLoaded() then
        DebugLog("LibCharacterKnowledge available for motif page check")
        local success, styleId = pcall(function()
            return libManager.GetStyleIdFromName(styleName)
        end)

        if success and styleId then
            DebugLog("Found styleId: " .. tostring(styleId) .. " for " .. styleName)
            local LCK = _G.LibCharacterKnowledge
            if LCK and LCK.GetMotifKnowledgeForCharacter and LCK.GetMotifChapterNames then
                -- Build dynamic chapter mapping from LibCharacterKnowledge
                local chapterMap = {}
                local chapterNames = LCK.GetMotifChapterNames()
                
                if chapterNames then
                    DebugLog("Building chapter mapping from LibCharacterKnowledge...")
                    for _, chapter in ipairs(chapterNames) do
                        if chapter.name and chapter.id then
                            local normalizedName = string.lower(chapter.name)
                            chapterMap[normalizedName] = chapter.id
                            DebugLog("  Mapped '" .. normalizedName .. "' -> chapterId: " .. tostring(chapter.id))
                        end
                    end
                else
                    DebugLog("Error: Could not get chapter names from LibCharacterKnowledge")
                    return false
                end

                local normalizedItemType = NormalizeItemTypeForMotifChapter(itemType)
                local chapterId = chapterMap[normalizedItemType]
                DebugLog("Mapped itemType '" .. tostring(itemType) .. "' (normalized: '" .. normalizedItemType .. "') to chapterId: " .. tostring(chapterId))
                
                if not chapterId then
                    DebugLog("No chapter mapping found for itemType: " .. tostring(itemType))
                    return false
                end

                local knowledge = LCK.GetMotifKnowledgeForCharacter(styleId, chapterId)
                local isKnown = knowledge == LCK.KNOWLEDGE_KNOWN
                DebugLog("LibCharacterKnowledge motif page result: " .. tostring(isKnown) .. " (knowledge=" .. tostring(knowledge) .. ")")
                DebugLog("=== MOTIF PAGE CHECK RESULT: " .. tostring(isKnown) .. " (LCK) ===")
                return isKnown
            end
        else
            DebugLog("LibCharacterKnowledge could not find styleId for: " .. styleName)
        end
    else
        DebugLog("LibCharacterKnowledge not available for motif page check")
    end

    -- Fallback to overall style knowledge if library not available
    DebugLog("Falling back to overall style knowledge check")
    local fallbackResult = MasterWritCore.IsStyleKnown(styleName)
    DebugLog("=== MOTIF PAGE CHECK RESULT: " .. tostring(fallbackResult) .. " (fallback) ===")
    return fallbackResult
end

-- Enhanced trait knowledge checking for specific item types
function MasterWritCore.IsTraitKnown(traitName, craftType, itemType)
    if not traitName then return true end

    DebugLog("IsTraitKnown called with: trait=" ..
    tostring(traitName) .. ", craftType=" .. tostring(craftType) .. ", itemType=" .. tostring(itemType))

    -- If we have specific item type, check only that research line
    if itemType and craftType then
        return MasterWritCore.IsTraitKnownForItemType(traitName, craftType, itemType)
    end

    -- Fallback to checking all lines (original behavior)
    return MasterWritCore.IsTraitKnownAllLines(traitName, craftType)
end

-- NEW: Check trait knowledge for specific item type only
function MasterWritCore.IsTraitKnownForItemType(traitName, craftType, itemType)
    local skillTypes = {
        ["blacksmithing"] = CRAFTING_TYPE_BLACKSMITHING,
        ["clothier"] = CRAFTING_TYPE_CLOTHIER,
        ["woodworking"] = CRAFTING_TYPE_WOODWORKING,
        ["jewelry"] = CRAFTING_TYPE_JEWELRYCRAFTING
    }

    local skillType = skillTypes[craftType] or CRAFTING_TYPE_BLACKSMITHING
    local targetTraitName = string.lower(tostring(traitName))
    
    -- Direct mapping to research line names - only handle special cases
    local targetLineName = itemType
    
    -- Handle special cases where motif names differ from research line names
    if string.lower(itemType) == "robe" or string.lower(itemType) == "jerkin" then
        targetLineName = "Robe & Jerkin"
    elseif string.lower(itemType) == "shields" then
        targetLineName = "Shield"  -- Research line is "Shield" (singular), motif is "Shields" (plural)
    end

    if not GetNumSmithingResearchLines or not GetSmithingResearchLineInfo then 
        return false 
    end

    local numLines = GetNumSmithingResearchLines(skillType)
    
    -- Find the specific research line
    for lineIndex = 1, numLines do
        local lineName, icon, numTraits = GetSmithingResearchLineInfo(skillType, lineIndex)
        if lineName and lineName == targetLineName then
            -- Found the specific research line - now check if trait is researched
            local lineResearchedTraits = 0
            local traitFound = false
            local traitResearched = false
            
            if numTraits and numTraits > 0 then
                -- Count researched traits and check for specific trait
                for traitIndex = 1, numTraits do
                    local traitType, traitDescription, known = GetSmithingResearchLineTraitInfo(skillType, lineIndex, traitIndex)
                    
                    if traitType and traitType > 0 then
                        if known == true then
                            lineResearchedTraits = lineResearchedTraits + 1
                        end
                        
                        local traitName_api = GetString("SI_ITEMTRAITTYPE", traitType)
                        if traitName_api then
                            local apiTraitName = string.lower(tostring(traitName_api))
                            if apiTraitName == targetTraitName then
                                traitFound = true
                                traitResearched = known == true
                            end
                        end
                    end
                end
            end
            
            -- Show summary for this specific research line
            CleanDebugLog("Checking Research Line - " .. tostring(lineName) .. ": " .. 
                         (traitFound and "MATCH FOUND" or "NO MATCH") .. 
                         " - Researched: |c3A92FF" .. lineResearchedTraits .. "|r")
            
            if traitFound then
                return traitResearched
            else
                CleanDebugLog("Trait '" .. targetTraitName .. "' not found in " .. tostring(lineName) .. " research line")
                return false
            end
        end
    end
    
    -- No matching research line found - show available lines for debugging
    CleanDebugLog("Research line '" .. tostring(targetLineName) .. "' not found for " .. tostring(craftType))
    VerboseDebugLog("Available research lines for " .. tostring(craftType) .. ":")
    for lineIndex = 1, numLines do
        local lineName = GetSmithingResearchLineInfo(skillType, lineIndex)
        if lineName then
            VerboseDebugLog("  - '" .. lineName .. "'")
        end
    end
    
    return false
end

-- NEW: Original function for checking all lines (fallback)
function MasterWritCore.IsTraitKnownAllLines(traitName, craftType)
    local skillTypes = {
        ["blacksmithing"] = CRAFTING_TYPE_BLACKSMITHING,
        ["clothier"] = CRAFTING_TYPE_CLOTHIER,
        ["woodworking"] = CRAFTING_TYPE_WOODWORKING,
        ["jewelry"] = CRAFTING_TYPE_JEWELRYCRAFTING
    }

    local skillType = craftType and skillTypes[craftType] or CRAFTING_TYPE_BLACKSMITHING
    local targetTraitName = string.lower(tostring(traitName))

    if not GetNumSmithingResearchLines then
        return false
    end

    local numLines = GetNumSmithingResearchLines(skillType)
    if not numLines then
        return false
    end

    -- Check all research lines for the trait
    for lineIndex = 1, numLines do
        local lineName, icon, numTraits = GetSmithingResearchLineInfo(skillType, lineIndex)
        
        if numTraits and numTraits > 0 then
            for traitIndex = 1, numTraits do
                local traitType, traitDescription, known = GetSmithingResearchLineTraitInfo(skillType, lineIndex, traitIndex)

                if traitType and traitType > 0 then
                    local traitName_api = GetString("SI_ITEMTRAITTYPE", traitType)
                    if traitName_api then
                        local apiTraitName = string.lower(tostring(traitName_api))
                        if apiTraitName == targetTraitName and known == true then
                            return true
                        end
                    end
                end
            end
        end
    end

    return false
end

-- NEW: Check if a provisioning recipe is known
function MasterWritCore.IsProvisioningRecipeKnown(recipeName)
    if not recipeName then return false end
    
    DebugLog("=== PROVISIONING RECIPE CHECK: " .. recipeName .. " ===")
    
    -- First try LibCharacterKnowledge if available
    local libManager = GetLibraryManager()
    if libManager and libManager.IsLibCharacterKnowledgeLoaded() then
        DebugLog("LibCharacterKnowledge available - checking recipe knowledge...")
        local LCK = _G.LibCharacterKnowledge
        if LCK and LCK.GetItemKnowledgeForCharacter then
            -- Get all provisioning recipe items and find matching name
            if LCK.GetItemIdsForCategory and LCK.ITEM_CATEGORY_RECIPE then
                local success, recipeIds = pcall(LCK.GetItemIdsForCategory, LCK.ITEM_CATEGORY_RECIPE)
                if success and recipeIds then
                    DebugLog("Found " .. #recipeIds .. " provisioning recipes to check")
                    
                    -- Search through all recipe IDs to find matching name
                    for _, recipeId in ipairs(recipeIds) do
                        local recipeItemName = LCK.GetItemName(recipeId)
                        if recipeItemName then
                            -- Remove "Recipe: " prefix if present and normalize
                            local cleanRecipeName = string.gsub(recipeItemName, "^Recipe:%s*", "")
                            local normalizedRecipeName = string.lower(string.gsub(cleanRecipeName, "^%s*(.-)%s*$", "%1"))
                            local normalizedSearchName = string.lower(string.gsub(recipeName, "^%s*(.-)%s*$", "%1"))
                            
                            if normalizedRecipeName == normalizedSearchName then
                                DebugLog("Found matching recipe ID: " .. recipeId .. " for '" .. recipeName .. "'")
                                DebugLog("Full recipe name: '" .. recipeItemName .. "'")
                                
                                -- Check if this character knows this recipe
                                local knowledge = LCK.GetItemKnowledgeForCharacter(recipeId)
                                local isKnown = knowledge == LCK.KNOWLEDGE_KNOWN
                                
                                DebugLog("LibCharacterKnowledge: Recipe '" .. recipeName .. "' knowledge state: " .. tostring(knowledge) .. " (known: " .. tostring(isKnown) .. ")")
                                return isKnown
                            end
                        end
                    end
                    
                    DebugLog("Recipe '" .. recipeName .. "' not found in LibCharacterKnowledge recipe database")
                else
                    DebugLog("Failed to get recipe IDs from LibCharacterKnowledge")
                end
            else
                DebugLog("LibCharacterKnowledge GetItemIdsForCategory not available")
            end
        else
            DebugLog("LibCharacterKnowledge GetItemKnowledgeForCharacter not available")
        end
    else
        DebugLog("LibCharacterKnowledge not available")
    end
    
    -- Try LibLazyCrafting if available as fallback
    if libManager and libManager.IsLibLazyCraftingLoaded() then
        DebugLog("LibLazyCrafting available - checking recipe...")
        local canCraft, message = libManager.CanCraftProvisioningRecipe(recipeName)
        if canCraft ~= nil then
            DebugLog("LibLazyCrafting: Recipe " .. recipeName .. " craftable: " .. tostring(canCraft))
            return canCraft
        else
            DebugLog("LibLazyCrafting: " .. (message or "Error checking recipe"))
        end
    else
        DebugLog("LibLazyCrafting not available")
    end
    
    -- Final fallback: Always return false if we can't determine recipe knowledge
    DebugLog("No library available to check provisioning recipe knowledge - returning false")
    return false
end

-- NEW: Check if player has sufficient provisioning skill levels
function MasterWritCore.IsProvisioningSkillSufficient(recipeName, recipeQuality)
    DebugLog("=== PROVISIONING SKILL CHECK: " .. (recipeName or "unknown") .. " ===")
    
    -- CRITICAL: Ensure skill system is fully initialized before proceeding
    if not IsPlayerActivated() then
        DebugLog("Player not yet activated - skill system unavailable")
        return false, {"Player not activated yet"}
    end
    
    -- Verify essential skill API functions are available (only the ones we actually use)
    if not (AreSkillsInitialized and GetSkillLineIndicesFromSkillLineId and GetNumSkillAbilities and GetSkillAbilityInfo) then
        DebugLog("Essential skill API functions not available - missing required functions")
        return false, {"Required skill API functions not loaded"}
    end
    
    -- CONSOLE-COMPATIBLE: Use AreSkillsInitialized() check first
    if not AreSkillsInitialized() then
        DebugLog("Skills not yet initialized - using LibLazyCrafting fallback")
        return false, {"Skills not initialized yet"}
    end
    
    -- CONSOLE-COMPATIBLE: Use skill line ID for Provisioning (ID = 76)
    local PROVISIONING_SKILL_LINE_ID = 76
    local skillType, provisioningSkillLineIndex = GetSkillLineIndicesFromSkillLineId(PROVISIONING_SKILL_LINE_ID)
    
    if not skillType or not provisioningSkillLineIndex then
        DebugLog("Could not find Provisioning skill line (ID: " .. PROVISIONING_SKILL_LINE_ID .. ")")
        return false, {"Provisioning skill line not found"}
    end
    
    DebugLog("Found Provisioning skill line - skillType: " .. tostring(skillType) .. ", index: " .. tostring(provisioningSkillLineIndex))
    
    -- First, we need to find the recipe and get its actual requirements
    local recipeRequirements = MasterWritCore.GetRecipeSkillRequirements(recipeName)
    if not recipeRequirements then
        DebugLog("Could not determine recipe skill requirements")
        return false, {"Could not determine recipe skill requirements"}
    end
    
    DebugLog("Recipe requires - Recipe Improvement: " .. (recipeRequirements.recipeImprovement or "none") .. ", Recipe Quality: " .. (recipeRequirements.recipeQuality or "none"))
    
    local missingSkills = {}
    
    -- Find the specific passive abilities and check their ranks
    local recipeImprovementAbilityIndex = nil
    local recipeQualityAbilityIndex = nil
    
    local numAbilities = GetNumSkillAbilities(skillType, provisioningSkillLineIndex)
    if not numAbilities or numAbilities <= 0 then
        DebugLog("No abilities available for provisioning skill line")
        return false, {"No abilities available"}
    end
    
    for abilityIndex = 1, numAbilities do
        local abilityName = GetSkillAbilityInfo(skillType, provisioningSkillLineIndex, abilityIndex)
        if abilityName then
            local lowerName = string.lower(abilityName)
            if string.find(lowerName, "recipe improvement") then
                recipeImprovementAbilityIndex = abilityIndex
                DebugLog("Found Recipe Improvement at ability index: " .. abilityIndex)
            elseif string.find(lowerName, "recipe quality") then
                recipeQualityAbilityIndex = abilityIndex
                DebugLog("Found Recipe Quality at ability index: " .. abilityIndex)
            end
        end
    end
    
    -- Check Recipe Improvement rank  
    if recipeRequirements.recipeImprovement and recipeRequirements.recipeImprovement > 0 then
        if recipeImprovementAbilityIndex then
            -- CONSOLE-COMPATIBLE: Use correct GetSkillAbilityInfo return values
            local abilityName, _, earnedRank, passive, ultimate, purchased, progressionIndex, currentRank = GetSkillAbilityInfo(skillType, provisioningSkillLineIndex, recipeImprovementAbilityIndex)
            currentRank = currentRank or 0  -- Use the actual rank parameter
            DebugLog("Recipe Improvement - current rank: " .. currentRank .. ", required: " .. recipeRequirements.recipeImprovement .. ", purchased: " .. tostring(purchased))
            
            if currentRank < recipeRequirements.recipeImprovement then
                table.insert(missingSkills, "RECIPE IMPROVEMENT " .. recipeRequirements.recipeImprovement .. " (CURRENT: " .. currentRank .. ")")
            end
        else
            DebugLog("Recipe Improvement passive not found")
            table.insert(missingSkills, "Recipe Improvement passive not found")
        end
    end
    
    -- Check Recipe Quality rank
    if recipeRequirements.recipeQuality and recipeRequirements.recipeQuality > 0 then
        if recipeQualityAbilityIndex then
            -- CONSOLE-COMPATIBLE: Use correct GetSkillAbilityInfo return values
            local abilityName, _, earnedRank, passive, ultimate, purchased, progressionIndex, currentRank = GetSkillAbilityInfo(skillType, provisioningSkillLineIndex, recipeQualityAbilityIndex)
            currentRank = currentRank or 0  -- Use the actual rank parameter
            DebugLog("Recipe Quality - current rank: " .. currentRank .. ", required: " .. recipeRequirements.recipeQuality .. ", purchased: " .. tostring(purchased))
            
            if currentRank < recipeRequirements.recipeQuality then
                table.insert(missingSkills, "RECIPE QUALITY " .. recipeRequirements.recipeQuality .. " (CURRENT: " .. currentRank .. ")")
            end
        else
            DebugLog("Recipe Quality passive not found")
            table.insert(missingSkills, "Recipe Quality passive not found")
        end
    end
    
    local skillsSufficient = #missingSkills == 0
    DebugLog("Provisioning skills sufficient: " .. tostring(skillsSufficient))
    
    return skillsSufficient, missingSkills
end

-- NEW: Get skill requirements for a specific recipe
function MasterWritCore.GetRecipeSkillRequirements(recipeName)
    if not recipeName then return nil end
    
    DebugLog("=== GETTING RECIPE SKILL REQUIREMENTS: " .. recipeName .. " ===")
    
    -- Try to find the recipe using LibCharacterKnowledge
    local libManager = GetLibraryManager()
    if libManager and libManager.IsLibCharacterKnowledgeLoaded() then
        local LCK = _G.LibCharacterKnowledge
        if LCK and LCK.GetItemIdsForCategory and LCK.ITEM_CATEGORY_RECIPE then
            local success, recipeIds = pcall(LCK.GetItemIdsForCategory, LCK.ITEM_CATEGORY_RECIPE)
            if success and recipeIds then
                -- Find the matching recipe
                for _, recipeId in ipairs(recipeIds) do
                    local recipeItemName = LCK.GetItemName(recipeId)
                    if recipeItemName then
                        local cleanRecipeName = string.gsub(recipeItemName, "^Recipe:%s*", "")
                        local normalizedRecipeName = string.lower(string.gsub(cleanRecipeName, "^%s*(.-)%s*$", "%1"))
                        local normalizedSearchName = string.lower(string.gsub(recipeName, "^%s*(.-)%s*$", "%1"))
                        
                        if normalizedRecipeName == normalizedSearchName then
                            DebugLog("Found recipe ID: " .. recipeId .. " for skill requirement checking")
                            
                            -- Get recipe item link and check its tooltip for skill requirements
                            local recipeLink = string.format("|H1:item:%d:3:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", recipeId)
                            
                            -- Try to extract skill requirements from recipe
                            return MasterWritCore.ParseRecipeSkillRequirements(recipeLink, recipeId)
                        end
                    end
                end
            end
        end
    end
    
    DebugLog("Could not find recipe for skill requirement checking")
    return nil
end

-- NEW: Parse skill requirements from recipe item
function MasterWritCore.ParseRecipeSkillRequirements(recipeLink, recipeId)
    DebugLog("Parsing skill requirements for recipe ID: " .. tostring(recipeId))
    
    -- Try to use ESO API to get recipe requirements
    local requirements = {
        recipeImprovement = 0,
        recipeQuality = 0
    }
    
    -- Method 1: Try to get recipe info if we know it
    local recipeListIndex, recipeIndex = GetItemLinkGrantedRecipeIndices(recipeLink)
    if recipeListIndex and recipeIndex then
        DebugLog("Found recipe indices: " .. recipeListIndex .. ", " .. recipeIndex)
        
        -- Get recipe info including quality requirement
        local isKnown, resultItemName, numIngredients, provisionerLevelReq, qualityReq = GetRecipeInfo(recipeListIndex, recipeIndex)
        if qualityReq then
            DebugLog("Recipe quality requirement from ESO API: " .. tostring(qualityReq))
            
            -- Convert quality requirement to skill requirements
            -- Based on ESO provisioning skill requirements:
            -- Quality 1 (white) = no skills needed  
            -- Quality 2 (green) = Recipe Improvement 1, Recipe Quality 1
            -- Quality 3 (blue) = Recipe Improvement 6, Recipe Quality 3  
            -- Quality 4 (purple) = Recipe Improvement 6, Recipe Quality 4
            -- Quality 5 (gold) = Recipe Improvement 6, Recipe Quality 4 (max rank)
            
            if qualityReq == 1 then
                requirements.recipeImprovement = 0
                requirements.recipeQuality = 0
            elseif qualityReq == 2 then
                requirements.recipeImprovement = 1
                requirements.recipeQuality = 1
            elseif qualityReq == 3 then
                requirements.recipeImprovement = 6
                requirements.recipeQuality = 3
            elseif qualityReq >= 4 then  -- Quality 4+ recipes need Recipe Quality 4 (max rank)
                requirements.recipeImprovement = 6
                requirements.recipeQuality = 4
            end
            
            DebugLog("Calculated skill requirements - Recipe Improvement: " .. requirements.recipeImprovement .. ", Recipe Quality: " .. requirements.recipeQuality)
            return requirements
        end
    end
    
    -- Method 2: Fallback - assume minimum requirements based on recipe name/type
    -- Most gourmet recipes require at least some skill
    requirements.recipeImprovement = 1
    requirements.recipeQuality = 1
    
    DebugLog("Using fallback skill requirements - Recipe Improvement: " .. requirements.recipeImprovement .. ", Recipe Quality: " .. requirements.recipeQuality)
    return requirements
end

-- Comprehensive Master Writ craftability check
function MasterWritCore.CanCraftMasterWrit(itemLink, directRequirements)
    local requirements
    
    if directRequirements then
        -- Use provided requirements directly (for testing)
        requirements = directRequirements
    elseif itemLink then
        -- Parse from item link
        requirements = MasterWritCore.ParseMasterWritTooltip(itemLink)
    else
        return false, { "Invalid parameters" }
    end
    
    if not requirements then
        return false, { "Unable to parse Master Writ requirements" }
    end

    local missingRequirements = {}
    local isJewelry = requirements.craftType == "jewelry"
    local isProvisioning = requirements.craftType == "provisioning"

    -- For jewelry and provisioning writs, style checking is not applicable
    local styleKnown = true
    local motifPageKnown = true
    
    if not isJewelry and not isProvisioning then
        -- Only check style for non-jewelry writs
        if not requirements.style then
            return false, { "Unable to parse Master Writ requirements" }
        end
        
        -- Check style knowledge
        styleKnown = MasterWritCore.IsStyleKnown(requirements.style)
        if not styleKnown then
            table.insert(missingRequirements, "Style: " .. (requirements.style or "Unknown"))
        end

        -- Check motif page knowledge
        if requirements.itemType then
            motifPageKnown = MasterWritCore.IsMotifPageKnown(requirements.style, requirements.itemType)
            if not motifPageKnown then
                table.insert(missingRequirements,
                    "Motif Page: " .. (requirements.style or "Unknown") .. " " .. (requirements.itemType or "Unknown"))
            end
        end
    end

    -- Check trait knowledge
    local traitKnown = true
    if requirements.trait and not isProvisioning then
        traitKnown = MasterWritCore.IsTraitKnown(requirements.trait, requirements.craftType, requirements.itemType)
        if not traitKnown then
            table.insert(missingRequirements, "Trait: " .. (requirements.trait or "Unknown"))
        end
    end

    -- NEW: Check provisioning recipe knowledge
    local recipeKnown = true
    local skillsSufficient = true
    if isProvisioning and requirements.recipe then
        recipeKnown = MasterWritCore.IsProvisioningRecipeKnown(requirements.recipe)
        if not recipeKnown then
            table.insert(missingRequirements, "Recipe: " .. (requirements.recipe or "Unknown"))
        end
        
        -- Check provisioning skill levels (Recipe Improvement, Recipe Quality)
        local skillsOk, missingSkills = MasterWritCore.IsProvisioningSkillSufficient(requirements.recipe, requirements.quality)
        if not skillsOk then
            skillsSufficient = false
            for _, skill in ipairs(missingSkills) do
                table.insert(missingRequirements, "Skill: " .. skill)
            end
        end
    end

    -- NEW: Check set craftability
    local setCraftable = true
    local setStatus = nil
    if requirements.set then
        setCraftable, setStatus = MasterWritCore.IsSetCraftable(requirements.set, requirements.itemType, requirements.craftType)
        if setCraftable == nil then
            -- Error case - show try again later
            table.insert(missingRequirements, "Set: " .. (setStatus or "Try Again Later"))
            setCraftable = false
        elseif not setCraftable then
            table.insert(missingRequirements, "Set: Need more traits (" .. (setStatus or "unknown") .. ")")
        end
    end

    local canCraft = styleKnown and motifPageKnown and traitKnown and setCraftable and recipeKnown and skillsSufficient
    return canCraft, missingRequirements
end

-- Check if an item is a Master Writ using multiple detection patterns
function MasterWritCore.IsMasterWrit(itemLink, itemName)
    if itemLink and GetItemLinkItemType and ITEMTYPE_MASTER_WRIT then
        return GetItemLinkItemType(itemLink) == ITEMTYPE_MASTER_WRIT
    end

    if itemName then
        return string.find(itemName, "Master") and string.find(itemName, "Writ")
    end

    return false
end

-- NEW: Get set trait requirement for a set by name
function MasterWritCore.GetSetTraitRequirement(setName)
    if not setName then return nil end
    
    -- Try exact match first
    local traits = SET_TRAIT_REQUIREMENTS[setName]
    if traits then return traits end
    
    -- Try case-insensitive match
    local lowerSetName = string.lower(setName)
    for name, traitsNeeded in pairs(SET_TRAIT_REQUIREMENTS) do
        if string.lower(name) == lowerSetName then
            return traitsNeeded
        end
    end
    
    return nil
end

-- NEW: Get total number of sets in database
function MasterWritCore.GetSetDatabaseSize()
    local count = 0
    for _ in pairs(SET_TRAIT_REQUIREMENTS) do
        count = count + 1
    end
    return count
end

-- NEW: Check if player can craft a specific set (has enough traits researched)
function MasterWritCore.IsSetCraftable(setName, itemType, craftType)
    if not setName then 
        return nil, "Try Again Later"
    end

    local traitsNeeded = MasterWritCore.GetSetTraitRequirement(setName)
    if not traitsNeeded then
        CleanDebugLog("Set '" .. setName .. "' not found in database")
        return nil, "Try Again Later"
    end

    -- Use targeted trait counting for specific item type
    local traitsResearched = 0
    if craftType and itemType then
        local success, result = pcall(MasterWritCore.GetTraitsForItemType, itemType, craftType)
        
        if success and result then
            traitsResearched = result
        else
            -- Fallback to max traits approach
            local fallbackSuccess, fallbackResult = pcall(MasterWritCore.GetMaxTraitsForCraftType, craftType)
            if fallbackSuccess and fallbackResult then
                traitsResearched = fallbackResult
            end
        end
    else
        local success, result = pcall(MasterWritCore.GetMaxTraitsForCraftType, craftType or "blacksmithing")
        if success and result then
            traitsResearched = result
        end
    end

    local canCraft = traitsResearched >= traitsNeeded
    CleanDebugLog("Can craft? " .. (canCraft and "|c00FF00TRUE|r" or "|cFF0000FALSE|r") .. " Traits Known: |c3A92FF" .. traitsResearched .. "/" .. traitsNeeded .. "|r")

    return canCraft, traitsResearched .. "/" .. traitsNeeded .. " traits"
end

-- NEW: Simplified trait counting - count by craft type and research line index
function MasterWritCore.CountResearchedTraitsSimple(craftType, lineIndex)
    if not craftType or not lineIndex then 
        return 0 
    end

    local skillTypes = {
        ["blacksmithing"] = CRAFTING_TYPE_BLACKSMITHING,
        ["clothier"] = CRAFTING_TYPE_CLOTHIER,
        ["woodworking"] = CRAFTING_TYPE_WOODWORKING,
        ["jewelry"] = CRAFTING_TYPE_JEWELRYCRAFTING
    }

    local skillType = skillTypes[craftType] or CRAFTING_TYPE_BLACKSMITHING
    
    if not GetNumSmithingResearchLines or not GetSmithingResearchLineInfo or not GetSmithingResearchLineTraitInfo then 
        return 0 
    end

    local numLines = GetNumSmithingResearchLines(skillType)
    if not numLines or lineIndex > numLines then 
        return 0 
    end

    local lineName, icon, numTraits = GetSmithingResearchLineInfo(skillType, lineIndex)

    if not numTraits or numTraits == 0 then 
        return 0 
    end
    
    local researchedCount = 0
    for traitIndex = 1, numTraits do
        local traitType, traitDescription, known = GetSmithingResearchLineTraitInfo(skillType, lineIndex, traitIndex)
        
        if traitType and traitType > 0 and known == true then
            researchedCount = researchedCount + 1
        end
    end
    
    VerboseDebugLog("CountResearchedTraitsSimple: " .. researchedCount .. "/" .. numTraits .. " traits researched for " .. tostring(lineName))
    return researchedCount
end

-- NEW: Get traits researched for specific item type (using exact ESO research line names)
function MasterWritCore.GetTraitsForItemType(itemType, craftType)
    if not itemType or not craftType then 
        DebugLog("GetTraitsForItemType: Missing parameters")
        return 0 
    end

    local skillTypes = {
        ["blacksmithing"] = CRAFTING_TYPE_BLACKSMITHING,
        ["clothier"] = CRAFTING_TYPE_CLOTHIER,
        ["woodworking"] = CRAFTING_TYPE_WOODWORKING,
        ["jewelry"] = CRAFTING_TYPE_JEWELRYCRAFTING
    }

    local skillType = skillTypes[craftType] or CRAFTING_TYPE_BLACKSMITHING
    
    -- Direct mapping to research line names - only handle special cases
    local targetLineName = itemType
    
    -- Handle the ONLY exception: Robe and Jerkin both map to "Robe & Jerkin"
    if string.lower(itemType) == "robe" or string.lower(itemType) == "jerkin" then
        targetLineName = "Robe & Jerkin"
    end
    if not targetLineName then
        DebugLog("GetTraitsForItemType: No itemType provided")
        return MasterWritCore.GetMaxTraitsForCraftType(craftType)
    end

    DebugLog("GetTraitsForItemType: Looking for research line: " .. targetLineName)

    if not GetNumSmithingResearchLines or not GetSmithingResearchLineInfo then 
        return 0 
    end

    local numLines = GetNumSmithingResearchLines(skillType)
    
    -- Find the specific research line and count its traits
    for lineIndex = 1, numLines do
        local lineName, icon, numTraits = GetSmithingResearchLineInfo(skillType, lineIndex)
        if lineName and lineName == targetLineName then
            DebugLog("GetTraitsForItemType: Found matching research line: " .. lineName)
            return MasterWritCore.CountResearchedTraitsSimple(craftType, lineIndex)
        end
    end
    
    -- No matching research line found - show available lines for debugging
    DebugLog("GetTraitsForItemType: Research line not found, falling back to max traits")
    VerboseDebugLog("Available research lines for " .. tostring(craftType) .. ":")
    for lineIndex = 1, numLines do
        local lineName = GetSmithingResearchLineInfo(skillType, lineIndex)
        if lineName then
            VerboseDebugLog("  - '" .. lineName .. "'")
        end
    end
    
    return MasterWritCore.GetMaxTraitsForCraftType(craftType)
end

-- NEW: Get maximum traits researched across all research lines for a craft type  
function MasterWritCore.GetMaxTraitsForCraftType(craftType)
    local skillTypes = {
        ["blacksmithing"] = CRAFTING_TYPE_BLACKSMITHING,
        ["clothier"] = CRAFTING_TYPE_CLOTHIER,
        ["woodworking"] = CRAFTING_TYPE_WOODWORKING,
        ["jewelry"] = CRAFTING_TYPE_JEWELRYCRAFTING
    }

    local skillType = skillTypes[craftType] or CRAFTING_TYPE_BLACKSMITHING
    
    if not GetNumSmithingResearchLines or not GetSmithingResearchLineInfo then 
        return 0 
    end

    local numLines = GetNumSmithingResearchLines(skillType)
    local maxTraits = 0
    
    for lineIndex = 1, numLines do
        local traitCount = MasterWritCore.CountResearchedTraitsSimple(craftType, lineIndex)
        if traitCount > maxTraits then
            maxTraits = traitCount
        end
    end
    
    DebugLog("GetMaxTraitsForCraftType: Max traits for " .. craftType .. ": " .. maxTraits)
    return maxTraits
end

-- Export globally for ESO addon system
_G.MasterWritCore = MasterWritCore

return MasterWritCore
