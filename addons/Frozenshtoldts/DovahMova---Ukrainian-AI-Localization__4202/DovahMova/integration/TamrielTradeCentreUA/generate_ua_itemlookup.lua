-- DovahMova Ukrainian ItemLookUpTable Generator
-- This script generates a Ukrainian ItemLookUpTable for TamrielTradeCentre
-- using DovahMova's saved variables data and settings

-- ═══════════════════════════════════════════════════════════════════════════════
-- CONFIGURATION
-- ═══════════════════════════════════════════════════════════════════════════════
local SILENT_MODE_BY_DEFAULT = true  -- Changed back to true for normal operation
local AUTO_LOAD_FROM_SAVED_VARS = true  -- Auto-load from saved variables only

-- Debug control variables
local DEBUG_GUILD_STORE = false  -- За замовчуванням увімкнено для Guild Store
local DEBUG_INVENTORY = false   -- За замовчуванням вимкнено для інвентаря

-- ═══════════════════════════════════════════════════════════════════════════════
-- HARDCODED ITEM TRANSLATIONS
-- ═══════════════════════════════════════════════════════════════════════════════

-- Quality prefixes (Ukrainian -> English)
local GLYPH_PREFIXES = {
    ["нікчемний"] = "trifling",
    ["убогий"] = "inferior",
    ["жалюгідний"] = "petty",
    ["крихітний"] = "slight",
    ["малий"] = "minor",
    ["незначний"] = "lesser",
    ["помірний"] = "moderate",
    ["звичайний"] = "average",
    ["могутній"] = "strong",
    ["видатний"] = "major",
    ["величезний"] = "greater",
    ["грандіозний"] = "grand",
    ["славетний"] = "splendid",
    ["монументальний"] = "monumental",
    ["пречудовий"] = "superb",
    ["воістину величний"] = "truly superb"
}

-- Base glyph types (Ukrainian -> English)
local GLYPH_TYPES = {
    --броня (armor glyphs)
    ["гліф здоров'я"] = "glyph of health",
    ["гліф магіки"] = "glyph of magicka",
    ["гліф витривалості"] = "glyph of stamina",
    ["гліф призматичного захисту"] = "glyph of prismatic defense",
    --зброя (weapon glyphs)
    ["гліф поглинання здоров'я"] = "glyph of absorb health",
    ["гліф поглинання магіки"] = "glyph of absorb magicka",
    ["гліф поглинання витривалості"] = "glyph of absorb stamina",
    ["гліф розбивання"] = "glyph of crushing",
    ["гліф зниження здоров'я"] = "glyph of decrease health",
    ["гліф полум'я"] = "glyph of flame",
    ["гліф спалення"] = "glyph of foulness",
    ["гліф морозу"] = "glyph of frost",
    ["гліф затвердження"] = "glyph of hardening",
    ["гліф отрути"] = "glyph of poison",
    ["гліф сокрушаючого удару"] = "glyph of prismatic onslaught",
    ["гліф удару блискавки"] = "glyph of shock",
    ["гліф слабкості"] = "glyph of weakening",
    ["гліф зброярської шкоди"] = "glyph of weapon damage",
    --прикраси (jewelry glyphs)
    ["гліф збільшення фізичної шкоди"] = "glyph of increase physical harm",
    ["гліф збільшення магічної шкоди"] = "glyph of increase magical harm",
    ["гліф відновлення здоров'я"] = "glyph of health recovery",
    ["гліф відновлення магіки"] = "glyph of magicka recovery",
    ["гліф відновлення витривалості"] = "glyph of stamina recovery",
    ["гліф зниження вартості заклять"] = "glyph of reduce spell cost",
    ["гліф зниження вартості здібностей"] = "glyph of reduce feat cost",
    ["гліф зміцнення"] = "glyph of bracing",
    ["гліф добивання"] = "glyph of bashing",
    ["гліф зниження фізичного шкоди"] = "glyph of decrease physical harm",
    ["гліф зниження магічного шкоди"] = "glyph of decrease spell harm",
    ["гліф стійкості до полум'я"] = "glyph of flame resist",
    ["гліф стійкості до морозу"] = "glyph of frost resist",
    ["гліф стійкості до блискавки"] = "glyph of shock resist",
    ["гліф стійкості до отрути"] = "glyph of poison resist",
    ["гліф стійкості до хвороби"] = "glyph of disease resist",
    ["гліф прискорення дії зілля"] = "glyph of potion speed",
    ["гліф посилення дії зілля"] = "glyph of potion boost",
    ["гліф призматичного відновлення"] = "glyph of prismatic recovery",
    ["гліф зниження вартості навичок"] = "glyph of reduce skill cost"
}

-- Essences (standalone items)
local ESSENCES = {
    ["сутність героїзм"] = "essence of heroism",
    ["сутність швидкість"] = "essence of speed",
    ["сутність розбиття броні"] = "essence of ravage armor",
    ["сутність виснаження витривалості"] = "essence of ravage stamina",
    ["сутність виявлення"] = "essence of detection",
    ["сутність виснаження"] = "essence of enervation",
    ["сутність нерішучість"] = "essence of timidity",
    ["сутність осквернення"] = "essence of defile",
    ["сутність виснаження магіки"] = "essence of ravage magicka",
    ["сутність захист від заклинань"] = "essence of spell protection",
    ["сутність ослаблення"] = "essence of maim",
    ["сутність виснаження здоров'я"] = "essence of ravage health",
    ["сутність боягузтво"] = "essence of cowardice",
    ["сутність вразливість"] = "essence of vulnerability",
    ["сутність броня"] = "essence of armor",
    ["сутність критичний удар заклинання"] = "essence of spell critical",
    ["сутність пастка"] = "essence of entrapment",
    ["сутність поступове відновлення здоров'я"] = "essence of lingering health",
    ["сутність поступове спустошення здоров'я"] = "essence of creeping ravage health",
    ["сутність виснаження захисту від заклинань"] = "essence of ravage spell protection",
    ["сутність захист"] = "essence of protection",
    ["сутність невпевненість"] = "essence of uncertainty",
    ["сутність здоров'я"] = "essence of health",
    ["сутність магіка"] = "essence of magicka",
    ["сутність сила зброї"] = "essence of weapon power",
    ["сутність сила заклинання"] = "essence of spell power",
    ["сутність життєва сила"] = "essence of vitality",
    ["сутність гальмування"] = "essence of hindering",
    ["сутність нерухомість"] = "essence of immovability",
    ["сутність витривалість"] = "essence of stamina",
    ["сутність критичний удар зброї"] = "essence of weapon crit",
    ["сутність невидимість"] = "essence of invisibility"
}

-- Potion types for extraction and replacement
local POTION_TYPES = {
    ["сплеск"] = "effusion of",
    ["витяжка"] = "distillate of",
    ["краплина"] = "dram of",
    ["еліксир"] = "elixir of",
    ["зілля"] = "potion of",
    ["ковток"] = "sip of",
    ["настоянка"] = "tincture of",
    ["панацея"] = "panacea of",
    ["відвар"] = "solution of",
    ["сироватка"] = "serum of",
    ["трунок"] = "philter of"
}

-- Potions and draughts (standalone items)
local POTIONS = {
    ["боягузтво"] = "cowardice",
    ["броня"] = "armor",
    ["виснаження"] = "enervation",
    ["виснаження витривалості"] = "ravage stamina",
    ["виснаження захисту від заклинань"] = "ravage spell protection",
    ["виснаження здоров'я"] = "ravage health",
    ["виснаження магіки"] = "ravage magicka",
    ["витривалість"] = "stamina",
    ["виявлення"] = "detection",
    ["вразливість"] = "vulnerability",
    ["гальмування"] = "hindering",
    ["героїзм"] = "heroism",
    ["життєва сила"] = "vitality",
    ["захист"] = "protection",
    ["захист від заклинань"] = "spell protection",
    ["здоров'я"] = "health",
    ["критичний удар заклинання"] = "spell critical",
    ["критичний удар зброї"] = "weapon crit",
    ["магіка"] = "magicka",
    ["невидимість"] = "invisibility",
    ["нерухомість"] = "immovability",
    ["нерішучість"] = "timidity",
    ["осквернення"] = "defile",
    ["ослаблення"] = "maim",
    ["пастка"] = "entrapment",
    ["поступове відновлення здоров'я"] = "lingering health",
    ["поступове спустошення здоров'я"] = "creeping ravage health",
    ["розбиття броні"] = "ravage armor",
    ["сила заклинання"] = "spell power",
    ["сила зброї"] = "weapon power",
    ["швидкість"] = "speed",
}

-- Roman numerals for poison levels
local ROMAN_NUMERALS = {
    ["i"] = "I",
    ["ii"] = "II", 
    ["iii"] = "III",
    ["iv"] = "IV",
    ["v"] = "V",
    ["vi"] = "VI",
    ["vii"] = "VII",
    ["viii"] = "VIII",
    ["ix"] = "IX",
    ["x"] = "X"
}

-- Poisons (base types without roman numerals)
local POISONS = {
    -- Basic poison types (alphabetically sorted)
    ["отрута: боягузтво"] = "cowardice poison",
    ["отрута: втеча"] = "escapist's poison",
    ["отрута: висмоктування витривалості"] = "drain stamina poison",
    ["отрута: висмоктування жорстокості"] = "brutality-draining poison",
    ["отрута: висмоктування здоров'я"] = "drain health poison",
    ["отрута: висмоктування захисту"] = "ward-draining poison",
    ["отрута: висмоктування лютості"] = "savagery-draining poison",
    ["отрута: висмоктування магії"] = "drain magicka poison",
    ["отрута: висмоктування пророцтва"] = "prophecy-draining poison",
    ["отрута: висмоктування прихованості"] = "stealth-draining poison",
    ["отрута: висмоктування рішучості"] = "resolve-draining poison",
    ["отрута: висмоктування чарів"] = "sorcery-draining poison",
    ["отрута: висмоктування швидкості"] = "speed-draining poison",
    ["отрута: каліцтво"] = "maiming poison",
    ["отрута: невпевненість"] = "uncertainty poison",
    ["отрута: ослаблення"] = "enervating poison",
    ["отрута: пастка"] = "entrapping poison",
    ["отрута: помітність"] = "conspicuous poison",
    ["отрута: руйнування"] = "fracturing poison",
    ["отрута: сповільнення"] = "hindering poison",
    ["отрута: шкода витривалості"] = "damage stamina poison",
    ["отрута: шкода здоров'ю"] = "damage health poison",
    ["отрута: шкода магії"] = "damage magicka poison",
    
    -- Cloudy poison variants
    ["отрута для здоров'я з туманним ефектом"] = "cloudy damage health poison",
    ["хмарна стримуюча отрута"] = "cloudy hindering poison",
    ["хмарний поступовий спустошливий ефект здоров'я отрути"] = "cloudy gradual ravage health poison",
    
    -- Special poison types
    ["отрута вразливості"] = "vulnerability poison",
    ["отрута нерішучості"] = "timidity poison",
    ["отрута осквернення"] = "defiling poison",
    ["отрута виснаження життєвої сили"] = "vitality-draining poison",
    ["отрута поступового виснаження здоров'я"] = "gradual health drain poison",
    ["отрута поступового спустошення здоров'я"] = "gradual ravage health poison",
    ["отрута, що скасовує захист"] = "protection-reversing poison",
    
    -- Named poison types
    ["проривна отрута"] = "breaching poison",
    ["травматична отрута"] = "traumatic poison"
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- DUPLICATE POSTFIX DETECTION AND CLEANING
-- ═══════════════════════════════════════════════════════════════════════════════

-- Function to detect duplicated postfixes like "name (eng) (eng)"
local function HasDuplicatedPostfix(itemName)
    if not itemName or type(itemName) ~= "string" then
        return false
    end
    
    -- Check for pattern: "name (eng) (eng)"
    local match = string.match(itemName, " %([^)]+%) %([^)]+%)$")
    if match then
        local first, second = string.match(match, " %(([^)]+)%) %(([^)]+)%)$")
        return first and second and first == second
    end
    
    return false
end

-- Function to clean duplicated postfix
local function CleanDuplicatedPostfix(itemName)
    if not itemName or type(itemName) ~= "string" then
        return itemName
    end
    
    return string.gsub(itemName, " %([^)]+%) %([^)]+%)$", function(match)
        local first, second = string.match(match, " %(([^)]+)%) %(([^)]+)%)$")
        if first and second and first == second then
            return " (" .. first .. ")"
        end
        return match
    end)
end



-- ═══════════════════════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════════════

-- Function to get our saved variables (using DovahMova's saved vars)
local function GetSavedVars()
    -- Use DovahMova's saved variables since they're properly declared
    local savedVars = ZO_SavedVars:NewAccountWide("DovahMovaVariables", 1, nil, {})
    
    -- Initialize TTC integration data if it doesn't exist
    if not savedVars.TTCIntegration then
        savedVars.TTCIntegration = {
            ukrainianTable = {},
            dovahMovaItemCount = 0,
            dovahMovaDisplayMode = "",
            lastGenerated = 0,
            version = "1.0"
        }
    end
    
    return savedVars.TTCIntegration
end

-- Function to get DovahMova saved variables directly
local function GetDovahMovaSavedVars()
    local success, savedVars = pcall(function()
        return ZO_SavedVars:NewAccountWide("DovahMovaVariables", 1, nil, {})
    end)
    
    if success and savedVars and savedVars.Data and savedVars.Data.Items then
        return savedVars
    end
    return nil
end

-- Function to check table size manually (safe version)
local function GetTableSize(t)
    if not t then return 0 end
    local count = 0
    for _ in pairs(t) do
        count = count + 1
        -- Safety check to prevent infinite loops
        if count > 1000000 then
            d("WARNING: Table size check exceeded 1M items, stopping count")
            break
        end
    end
    return count
end

-- Function to check if DovahMova saved vars are available
local function IsDovahMovaDataAvailable()
    local savedVars = GetDovahMovaSavedVars()
    if not savedVars then return false end
    
    local itemCount = GetTableSize(savedVars.Data.Items)
    return itemCount > 0
end

-- Function to safely copy a table
local function SafeTableCopy(source)
    if not source then return {} end
    local copy = {}
    for k, v in pairs(source) do
        copy[k] = v
    end
    return copy
end

-- Function to check if saved Ukrainian table is still valid
local function IsSavedTableValid()
    local savedVars = GetSavedVars()
    local dovahMovaVars = GetDovahMovaSavedVars()
    
    if not savedVars or not dovahMovaVars then 
        return false 
    end
    
    -- Check if we have a saved table
    if not savedVars.ukrainianTable then
        return false
    end
    
    -- Check if the table has any content
    local savedTableSize = GetTableSize(savedVars.ukrainianTable)
    if savedTableSize == 0 then
        return false
    end
    
    -- Check if DovahMova data has changed
    local currentItemCount = GetTableSize(dovahMovaVars.Data.Items)
    local currentDisplayMode = dovahMovaVars.ShowItemsNamesTooltip or ""
    
    if savedVars.dovahMovaItemCount ~= currentItemCount then
        return false
    end
    
    if savedVars.dovahMovaDisplayMode ~= currentDisplayMode then
        return false
    end
    
    return true
end

-- Function to load Ukrainian table from saved variables
local function LoadUkrainianTableFromSavedVars(silent)
    if not AUTO_LOAD_FROM_SAVED_VARS then return false end
    
    local savedVars = GetSavedVars()
    if not savedVars or not savedVars.ukrainianTable then 
        if not silent then d("No saved Ukrainian table found") end
        return false 
    end
    
    if not IsSavedTableValid() then
        if not silent then d("Saved Ukrainian table is outdated, will regenerate") end
        return false
    end
    
    if TamrielTradeCentre and TamrielTradeCentre.ItemLookUpTable then
        -- Load the saved Ukrainian table
        TamrielTradeCentre.ItemLookUpTable = savedVars.ukrainianTable
        
        if not silent then
            d("✓ Loaded Ukrainian lookup table from saved variables")
            d("Items in table: " .. tostring(GetTableSize(savedVars.ukrainianTable)))
            d("Last generated: " .. os.date("%Y-%m-%d %H:%M:%S", savedVars.lastGenerated))
        end
        
        return true
    end
    
    if not silent then d("TTC not ready for loading") end
    return false
end

-- Function to save Ukrainian table to saved variables
local function SaveUkrainianTableToSavedVars(ukrainianTable, dovahMovaSettings, silent)
    local savedVars = GetSavedVars()
    if not savedVars then return false end
    
    -- Check if the table has any content
    local tableSizeBeforeSave = GetTableSize(ukrainianTable)
    if tableSizeBeforeSave == 0 then
        d("ERROR: Cannot save empty table!")
        return false
    end
    
    -- Save the table
    savedVars.ukrainianTable = ukrainianTable
    savedVars.dovahMovaItemCount = GetTableSize(dovahMovaSettings.Data.Items)
    savedVars.dovahMovaDisplayMode = dovahMovaSettings.ShowItemsNamesTooltip or ""
    savedVars.lastGenerated = GetTimeStamp()
    
    if not silent then
        d("✓ Saved Ukrainian lookup table to saved variables")
        d("Items saved: " .. tostring(tableSizeBeforeSave))
    end
    
    return true
end

-- Function to check what's actually in the TTC table
local function DebugTTCTable()
    if not TamrielTradeCentre or not TamrielTradeCentre.ItemLookUpTable then
        d("TTC table not available")
        return
    end
    
    local count = 0
    for itemName, itemData in pairs(TamrielTradeCentre.ItemLookUpTable) do
        if count < 10 then
            count = count + 1
        else
            break
        end
    end
    
    -- Check for specific items that should exist
    local testItems = {
        "cured kwama leggings",
        "webspinner's brace", 
        "apprentice's leggings",
        "scampstamper sabatons",
        "sommelier's gloves",
        "steel sword",
        "iron sword"
    }
    
    for _, testItem in ipairs(testItems) do
        local result = TamrielTradeCentre.ItemLookUpTable[testItem]
    end
end

-- Function to automatically cleanup duplicates (used during generation)
local function AutoCleanupDuplicates(silent)
    local savedVars = GetSavedVars()
    if not savedVars or not savedVars.ukrainianTable then
        return 0
    end
    
    local cleaned = 0
    local toRemove = {}
    local toAdd = {}
    
    -- Clean saved variables
    for key, value in pairs(savedVars.ukrainianTable) do
        if type(key) == "string" and HasDuplicatedPostfix(key) then
            local cleanKey = CleanDuplicatedPostfix(key)
            
            -- Only keep clean version if it doesn't already exist
            if not savedVars.ukrainianTable[cleanKey] and not toAdd[cleanKey] then
                toAdd[cleanKey] = value
            end
            
            toRemove[key] = true
            cleaned = cleaned + 1
        end
    end
    
    -- Apply changes to saved variables
    for key in pairs(toRemove) do
        savedVars.ukrainianTable[key] = nil
    end
    
    for key, value in pairs(toAdd) do
        savedVars.ukrainianTable[key] = value
    end
    
    -- Also clean the active TTC table
    if TamrielTradeCentre and TamrielTradeCentre.ItemLookUpTable then
        local activeToRemove = {}
        local activeToAdd = {}
        
        for key, value in pairs(TamrielTradeCentre.ItemLookUpTable) do
            if type(key) == "string" and HasDuplicatedPostfix(key) then
                local cleanKey = CleanDuplicatedPostfix(key)
                
                if not TamrielTradeCentre.ItemLookUpTable[cleanKey] and not activeToAdd[cleanKey] then
                    activeToAdd[cleanKey] = value
                end
                
                activeToRemove[key] = true
            end
        end
        
        -- Apply changes to active table
        for key in pairs(activeToRemove) do
            TamrielTradeCentre.ItemLookUpTable[key] = nil
        end
        
        for key, value in pairs(activeToAdd) do
            TamrielTradeCentre.ItemLookUpTable[key] = value
        end
    end
    
    return cleaned
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- CORE GENERATION FUNCTIONS  
-- ═══════════════════════════════════════════════════════════════════════════════

-- Generate all possible glyph combinations
local function GenerateGlyphCombinations()
    local combinations = {}
    
    -- Add essences first
    for ukEssence, enEssence in pairs(ESSENCES) do
        combinations[ukEssence] = enEssence
    end
    
    -- Add potions with all potion types
    for ukPotion, enPotion in pairs(POTIONS) do
        -- Add base potion (without type prefix)
        combinations[ukPotion] = enPotion
        
        -- Add all potion type combinations
        for ukType, enType in pairs(POTION_TYPES) do
            local ukCombination = ukType .. " " .. ukPotion
            local enCombination = enType .. " " .. enPotion
            combinations[ukCombination] = enCombination
        end
    end
    
    -- Add poisons (base versions without roman numerals)
    for ukPoison, enPoison in pairs(POISONS) do
        combinations[ukPoison] = enPoison
    end
    
    -- Add poison + roman numeral combinations
    for ukPoison, enPoison in pairs(POISONS) do
        for ukRoman, enRoman in pairs(ROMAN_NUMERALS) do
            local ukCombination = ukPoison .. " " .. ukRoman
            local enCombination = enPoison .. " " .. enRoman
            combinations[ukCombination] = enCombination
        end
    end
    
    -- Generate all prefix + glyph type combinations
    for ukPrefix, enPrefix in pairs(GLYPH_PREFIXES) do
        for ukGlyph, enGlyph in pairs(GLYPH_TYPES) do
            local ukCombination = ukPrefix .. " " .. ukGlyph
            local enCombination = enPrefix .. " " .. enGlyph
            combinations[ukCombination] = enCombination
        end
    end
    
    return combinations
end

-- Generate the complete hardcoded table
local HARDCODED_GLYPHS = GenerateGlyphCombinations()

-- ═══════════════════════════════════════════════════════════════════════════════
-- SLASH COMMANDS
-- ═══════════════════════════════════════════════════════════════════════════════

-- Command to regenerate hardcoded table (useful after adding new items)
SLASH_COMMANDS["/regenerateglyphs"] = function()
    HARDCODED_GLYPHS = GenerateGlyphCombinations()
    d("🔄 Перегенеровано " .. GetTableSize(HARDCODED_GLYPHS) .. " хардкодених записів!")
    d("Тепер включено:")
    d("  📜 Гліфи: " .. (GetTableSize(GLYPH_PREFIXES) * GetTableSize(GLYPH_TYPES)))
    d("  🧪 Сутності: " .. GetTableSize(ESSENCES))
    d("  🍶 Зілля: " .. GetTableSize(POTIONS))
    d("  ☠️ Отрути: " .. GetTableSize(POISONS))
    d("  🔢 Римські цифри: " .. GetTableSize(ROMAN_NUMERALS))
    d("  ⚗️ Комбінації отрут: " .. (GetTableSize(POISONS) * (1 + GetTableSize(ROMAN_NUMERALS))))
end

-- Debug function to show generated combinations
SLASH_COMMANDS["/showglyphs"] = function()
    d("=== GENERATED GLYPH COMBINATIONS ===")
    local count = 0
    for uk, en in pairs(HARDCODED_GLYPHS) do
        count = count + 1
        if count <= 10 then -- Show first 10 as example
            d(uk .. " -> " .. en)
        end
    end
    d("Total combinations: " .. count)
    d("Prefixes: " .. GetTableSize(GLYPH_PREFIXES))
    d("Glyph types: " .. GetTableSize(GLYPH_TYPES)) 
    d("Essences: " .. GetTableSize(ESSENCES))
    d("Potions: " .. GetTableSize(POTIONS))
    d("Poisons: " .. GetTableSize(POISONS))
    d("Roman numerals: " .. GetTableSize(ROMAN_NUMERALS))
    d("Poison combinations: " .. (GetTableSize(POISONS) * (1 + GetTableSize(ROMAN_NUMERALS))))
    d("Expected total: " .. (GetTableSize(GLYPH_PREFIXES) * GetTableSize(GLYPH_TYPES) + GetTableSize(ESSENCES) + GetTableSize(POTIONS) + GetTableSize(POISONS) * (1 + GetTableSize(ROMAN_NUMERALS))))
end

-- Test specific glyph name matching
SLASH_COMMANDS["/testglyph"] = function(args)
    local testName = args or "справді чудово гліф витривалості"
    d("=== TESTING GLYPH: '" .. testName .. "' ===")
    
    local lowerTest = string.lower(testName)
    d("Lowercase: '" .. lowerTest .. "'")
    
    local found = false
    for ukName, enName in pairs(HARDCODED_GLYPHS) do
        local lowerUk = string.lower(ukName)
        if lowerUk == lowerTest then
            d("✓ ЗНАЙДЕНО: '" .. ukName .. "' -> '" .. enName .. "'")
            found = true
            break
        end
    end
    
    if not found then
        d("✗ НЕ ЗНАЙДЕНО")
        d("Перші 5 записів для порівняння:")
        local count = 0
        for ukName, enName in pairs(HARDCODED_GLYPHS) do
            if count < 5 then
                d("  '" .. ukName .. "' -> '" .. enName .. "'")
                count = count + 1
            end
        end
    end
end

-- Deep TTC debug - check how TTC actually looks up prices
SLASH_COMMANDS["/ttcdebug"] = function(args)
    local testName = args or "справді чудово гліф витривалості"
    d("=== DEEP TTC DEBUG: '" .. testName .. "' ===")
    
    if not TamrielTradeCentre then
        d("✗ TTC недоступний!")
        return
    end
    
    local ttcTable = TamrielTradeCentre.ItemLookUpTable
    if not ttcTable then
        d("✗ TTC ItemLookUpTable недоступний!")
        return
    end
    
    -- Test different name formats
    local formats = {
        string.lower(testName),
        string.lower(zo_strformat(SI_TOOLTIP_ITEM_NAME, testName)),
        testName,
        zo_strformat(SI_TOOLTIP_ITEM_NAME, testName)
    }
    
    d("Тестуємо різні формати:")
    for i, format in ipairs(formats) do
        local result = ttcTable[format]
        d("  " .. i .. ". '" .. format .. "' -> " .. (result and ("ID: " .. tostring(result.ID)) or "НЕ ЗНАЙДЕНО"))
    end
    
    -- Check what we actually added to the table
    d("Що ми додали в таблицю (перші 10):")
    local addedCount = 0
    for key, value in pairs(ttcTable) do
        if string.find(key, "гліф") and addedCount < 10 then
            d("  '" .. key .. "' -> ID: " .. tostring(value.ID or "nil"))
            addedCount = addedCount + 1
        end
    end
    
    -- Check if our hardcoded name exists in different formats
    d("Перевірка хардкодених форматів:")
    if HARDCODED_GLYPHS[testName] then
        d("  ✓ Знайдено в HARDCODED_GLYPHS: " .. HARDCODED_GLYPHS[testName])
        local englishName = HARDCODED_GLYPHS[testName]
        local englishLower = string.lower(englishName)
        if ttcTable[englishLower] then
            d("  ✓ Англійська назва є в TTC: " .. englishLower)
        else
            d("  ✗ Англійська назва НЕ знайдена в TTC: " .. englishLower)
        end
    else
        d("  ✗ НЕ знайдено в HARDCODED_GLYPHS")
    end
    
    -- Show some working examples from TTC
    d("Приклади що працюють в TTC:")
    local count = 0
    for key, value in pairs(ttcTable) do
        if count < 5 and value.ID and not string.find(key, "гліф") then
            d("  '" .. key .. "' -> ID: " .. tostring(value.ID))
            count = count + 1
        end
    end
end

-- Check if specific item exists in TTC table
SLASH_COMMANDS["/checkttc"] = function(args)
    local itemName = args or "truly superb glyph of stamina"
    d("=== ПЕРЕВІРКА TTC: '" .. itemName .. "' ===")
    
    if not TamrielTradeCentre or not TamrielTradeCentre.ItemLookUpTable then
        d("✗ TTC недоступний!")
        return
    end
    
    local ttcTable = TamrielTradeCentre.ItemLookUpTable
    local result = ttcTable[string.lower(itemName)]
    
    if result then
        d("✓ ЗНАЙДЕНО в TTC:")
        d("  ID: " .. tostring(result.ID or "nil"))
        d("  Ключ: '" .. string.lower(itemName) .. "'")
        
        -- Show all data
        d("  ВСІ ПОЛЯ:")
        for key, value in pairs(result) do
            if type(value) ~= "table" then
                d("    " .. key .. ": " .. tostring(value))
            else
                d("    " .. key .. ": [table]")
            end
        end
        
        -- Check if this is a price entry (has numeric keys)
        local hasPrices = false
        for key, value in pairs(result) do
            if type(key) == "number" then
                hasPrices = true
                d("    ЦІНА [" .. key .. "]: " .. tostring(value))
            end
        end
        
        if not hasPrices then
            d("  ⚠️ НЕМАЄ ЦІНОВИХ ДАНИХ!")
        end
        
        -- Check if we have the English version
        if HARDCODED_GLYPHS[itemName] then
            local englishName = HARDCODED_GLYPHS[itemName]
            d("  📝 Англійська назва: '" .. englishName .. "'")
            local englishResult = ttcTable[string.lower(englishName)]
            if englishResult then
                d("  ✓ Англійський запис знайдено:")
                d("    ID: " .. tostring(englishResult.ID or "nil"))
                for key, value in pairs(englishResult) do
                    if type(value) ~= "table" and key ~= "ID" then
                        d("    " .. key .. ": " .. tostring(value))
                    end
                end
            else
                d("  ✗ Англійський запис НЕ знайдено!")
            end
        end
    else
        d("✗ НЕ ЗНАЙДЕНО в TTC")
        d("Шукали ключ: '" .. string.lower(itemName) .. "'")
        
        -- Try to find similar keys
        d("Схожі ключі:")
        local count = 0
        for key, value in pairs(ttcTable) do
            if string.find(key, "glyph") and string.find(key, "stamina") and count < 3 then
                d("  '" .. key .. "' -> ID: " .. tostring(value.ID or "nil"))
                count = count + 1
            end
        end
    end
end

-- Fix missing IDs by copying from English entries
SLASH_COMMANDS["/fixids"] = function()
    d("=== ВИПРАВЛЕННЯ ID ===")
    
    if not TamrielTradeCentre or not TamrielTradeCentre.ItemLookUpTable then
        d("✗ TTC недоступний!")
        return
    end
    
    local ttcTable = TamrielTradeCentre.ItemLookUpTable
    local fixed = 0
    
    -- Go through our hardcoded glyphs
    for ukrainianName, englishName in pairs(HARDCODED_GLYPHS) do
        local ukrainianKey = string.lower(ukrainianName)
        local englishKey = string.lower(englishName)
        
        local ukrainianEntry = ttcTable[ukrainianKey]
        local englishEntry = ttcTable[englishKey]
        
        if ukrainianEntry and englishEntry then
            -- Copy ID and other important fields from English to Ukrainian
            if englishEntry.ID and not ukrainianEntry.ID then
                ukrainianEntry.ID = englishEntry.ID
                fixed = fixed + 1
                d("✓ Скопійовано ID для: " .. ukrainianName .. " -> ID: " .. tostring(englishEntry.ID))
            end
            
            -- Copy other fields if they exist
            for field, value in pairs(englishEntry) do
                if not ukrainianEntry[field] and field ~= "ID" then
                    ukrainianEntry[field] = value
                end
            end
        end
    end
    
    d("🎉 Виправлено " .. fixed .. " записів!")
end

-- Quick fix command - generate Ukrainian entries for glyphs (ONLY Ukrainian names, no postfix)
SLASH_COMMANDS["/fixglyphs"] = function()
    d("=== ШВИДКЕ ВИПРАВЛЕННЯ ГЛІФІВ ===")
    d("Додаємо ТІЛЬКИ українські назви (без англійських постфіксів)")
    
    if not TamrielTradeCentre or not TamrielTradeCentre.ItemLookUpTable then
        d("✗ TTC недоступний!")
        return
    end
    
    local ttcTable = TamrielTradeCentre.ItemLookUpTable
    local addedCount = 0
    
    d("Обробляємо " .. GetTableSize(HARDCODED_GLYPHS) .. " гліфів...")
    
    for ukrainianName, englishName in pairs(HARDCODED_GLYPHS) do
        local formattedEnglishName = string.lower(englishName)
        
        -- Check if English name exists in TTC
        if ttcTable[formattedEnglishName] then
            local formattedUkrainianName = string.lower(ukrainianName)
            
            -- Add ONLY the Ukrainian name (without any postfix)
            if not ttcTable[formattedUkrainianName] then
                ttcTable[formattedUkrainianName] = ttcTable[formattedEnglishName]
                addedCount = addedCount + 1
                
                -- Debug: show what we're adding
                if addedCount <= 5 then
                    d("  Додано: '" .. formattedUkrainianName .. "' -> ID " .. tostring(ttcTable[formattedEnglishName].ID or "nil"))
                end
            end
        else
            -- Debug: show missing English names
            if addedCount == 0 then
                d("  Відсутня англійська: '" .. formattedEnglishName .. "'")
            end
        end
    end
    
    d("✅ Додано " .. addedCount .. " українських записів для гліфів!")
    d("Формат: тільки українська назва без постфіксу")
    d("Приклад: 'справді чудово гліф витривалості' (без '(Glyph of Stamina)')")
    d("Тепер ціни мають показуватися!")
    d("Спробуйте навести на гліф для перевірки.")
end



local function AddHardcodedGlyphs(ukrainianTable, englishTable, itemDisplayMode, silent)
    local addedCount = 0
    
    if not silent then d("Processing hardcoded glyph translations...") end
    
    for ukrainianName, englishName in pairs(HARDCODED_GLYPHS) do
        local formattedEnglishName = string.lower(englishName)
        
        -- Check if English name exists in TTC
        if englishTable[formattedEnglishName] then
            local formattedUkrainianName = string.lower(ukrainianName)
            
            -- Add different formats based on display mode
            if itemDisplayMode == "ua" then
                -- Add just the Ukrainian name (without postfix)
                ukrainianTable[formattedUkrainianName] = englishTable[formattedEnglishName]
                addedCount = addedCount + 1
            elseif itemDisplayMode == "uaen" then
                -- Add Ukrainian name without postfix first
                ukrainianTable[formattedUkrainianName] = englishTable[formattedEnglishName]
                addedCount = addedCount + 1
                
                -- Extract clean English name (remove any existing postfixes)
                local cleanEnglishName = englishName
                local pos = string.find(englishName, " %(")
                if pos then
                    cleanEnglishName = string.sub(englishName, 1, pos - 1)
                end
                
                -- Create postfix pattern ONLY if it doesn't already exist
                local postfixPattern = formattedUkrainianName .. " (" .. string.lower(cleanEnglishName) .. ")"
                if not ukrainianTable[postfixPattern] then
                    ukrainianTable[postfixPattern] = englishTable[formattedEnglishName]
                    addedCount = addedCount + 1
                end
            end
            
            if not silent and addedCount <= 10 then
                d("Added: '" .. ukrainianName .. "' -> '" .. englishName .. "'")
            end
        else
            if not silent and addedCount <= 5 then
                d("Skipped (not in TTC): '" .. englishName .. "'")
            end
        end
    end
    
    if not silent then
        d("Hardcoded glyphs processed: " .. GetTableSize(HARDCODED_GLYPHS))
        d("Successfully added: " .. addedCount)
    end
    
    return addedCount
end

local function GenerateUkrainianItemLookUpTable(silent)
    -- Use silent mode by default unless explicitly overridden
    if silent == nil then
        silent = SILENT_MODE_BY_DEFAULT
    end
    
    -- Try to get DovahMova data from saved variables first
    local dovahMovaSavedVars = GetDovahMovaSavedVars()
    local dovahMovaData = nil
    local dovahMovaSettings = nil
    
    if dovahMovaSavedVars then
        dovahMovaData = dovahMovaSavedVars.Data
        dovahMovaSettings = dovahMovaSavedVars
        if not silent then d("✓ Found DovahMova data in saved variables") end
    elseif DovahMova and DovahMova.Settings and DovahMova.Settings.Data then
        dovahMovaData = DovahMova.Settings.Data
        dovahMovaSettings = DovahMova.Settings
        if not silent then d("✓ Found DovahMova data from loaded addon") end
    else
        if not silent then 
            d("ERROR: DovahMova data not found in saved variables or loaded addon!")
            d("Make sure DovahMova has generated its translation data.")
            d("Try running /dovamova to update DovahMova's database first.")
        end
        return
    end
    
    local englishTable = {}
    local ukrainianTable = {}
    
    -- Load the English ItemLookUpTable first
    if TamrielTradeCentre and TamrielTradeCentre.ItemLookUpTable then
        englishTable = TamrielTradeCentre.ItemLookUpTable
    else
        if not silent then 
            d("ERROR: TamrielTradeCentre ItemLookUpTable not found!")
            d("Make sure TamrielTradeCentre is loaded and has initialized its lookup table.")
        end
        return
    end
    
    -- Debug the TTC table first (only if not silent)
    if not silent then DebugTTCTable() end
    
    -- Check DovahMova's item name display setting
    local itemDisplayMode = dovahMovaSettings.ShowItemsNamesTooltip or "uaen"
    if not silent then
        d("")
        d("=== Ukrainian ItemLookUpTable Generator ===")
        d("DovahMova item display mode: " .. itemDisplayMode)
        d("English items in TTC lookup table: " .. tostring(GetTableSize(englishTable)))
        d("Ukrainian items in DovahMova data: " .. tostring(GetTableSize(dovahMovaData.Items)))
        d("")
        
        -- Let's look at the actual DovahMova data structure first
        d("=== Sample DovahMova Data ===")
        local dovahMovaCount = 0
        for itemId, itemValue in pairs(dovahMovaData.Items) do
            if dovahMovaCount < 5 then
                d("DovahMova ID " .. itemId .. ": '" .. tostring(itemValue) .. "'")
                dovahMovaCount = dovahMovaCount + 1
            else
                break
            end
        end
        d("")
    end
    
    -- Start with a copy of the English table for fallback
    ukrainianTable = SafeTableCopy(englishTable)
    
    local addedCount = 0
    local processedCount = 0
    local skippedCount = 0
    local debugCount = 0
    
    if not silent then d("Processing DovahMova translation data...") end
    
    -- Process each item in DovahMova data
    for itemId, dovahMovaValue in pairs(dovahMovaData.Items) do
        processedCount = processedCount + 1
        
        -- Use DovahMova's stored English name directly (this is the original English name)
        local englishName = dovahMovaValue
        
        -- Skip items that already have duplicated postfixes to prevent further duplication
        if not HasDuplicatedPostfix(englishName) and englishName and englishName ~= "" and not string.match(englishName, "_") then
            -- Format the English name the same way TTC does for lookup
            local formattedEnglishName = string.lower(zo_strformat(SI_TOOLTIP_ITEM_NAME, englishName))
            
            -- Check if the English name exists in the original lookup table
            if englishTable[formattedEnglishName] then
                -- Get the Ukrainian name from the game (this will be the translated version)
                local itemLink = string.format("|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId)
                local ukrainianName = GetItemLinkName(itemLink)
                local formattedUkrainianName = string.lower(ukrainianName)
                
                -- Add mappings based on DovahMova's display mode
                if itemDisplayMode == "ua" then
                    -- UA only mode: just add Ukrainian name
                    ukrainianTable[formattedUkrainianName] = englishTable[formattedEnglishName]
                    addedCount = addedCount + 1
                elseif itemDisplayMode == "uaen" then
                    -- UA+EN mode: add both Ukrainian name and postfix pattern
                    ukrainianTable[formattedUkrainianName] = englishTable[formattedEnglishName]
                    
                    -- Extract clean English name (remove any existing postfixes)
                    local cleanEnglishName = englishName
                    local pos = string.find(englishName, " %(")
                    if pos then
                        cleanEnglishName = string.sub(englishName, 1, pos - 1)
                    end
                    
                    -- Add postfix pattern ONLY if it doesn't already exist: "українська назва (clean english name)"
                    local postfixPattern = formattedUkrainianName .. " (" .. string.lower(cleanEnglishName) .. ")"
                    if not ukrainianTable[postfixPattern] then
                        ukrainianTable[postfixPattern] = englishTable[formattedEnglishName]
                        addedCount = addedCount + 1
                        

                    end
                    
                    -- Add formatted version ONLY if different and doesn't exist
                    local formattedCleanEnglish = string.lower(zo_strformat(SI_TOOLTIP_ITEM_NAME, cleanEnglishName))
                    local postfixPatternFormatted = formattedUkrainianName .. " (" .. formattedCleanEnglish .. ")"
                    if postfixPatternFormatted ~= postfixPattern and not ukrainianTable[postfixPatternFormatted] then
                        ukrainianTable[postfixPatternFormatted] = englishTable[formattedEnglishName]
                        addedCount = addedCount + 1
                    end
                    
                    addedCount = addedCount + 1 -- For the base Ukrainian name
                else
                    -- EN only or other modes: just add Ukrainian name as fallback
                    ukrainianTable[formattedUkrainianName] = englishTable[formattedEnglishName]
                    addedCount = addedCount + 1
                end
            else
                skippedCount = skippedCount + 1
                
                -- Debug: Show first few skipped items to understand the issue (only if not silent)
                if not silent and debugCount < 5 then
                    d("DEBUG: Skipped item - ID: " .. itemId)
                    d("DEBUG: DovahMova EN name: '" .. englishName .. "'")
                    d("DEBUG: Formatted EN name: '" .. formattedEnglishName .. "'")
                    d("DEBUG: In TTC table: " .. tostring(englishTable[formattedEnglishName] ~= nil))
                    debugCount = debugCount + 1
                end
            end
        else
            skippedCount = skippedCount + 1

        end
        
        -- Progress indicator (only if not silent and less frequent)
        if not silent and processedCount % 10000 == 0 then
            d("Processed " .. processedCount .. " items, added " .. addedCount .. " mappings, skipped " .. skippedCount)
        end
        
        -- Stop after processing a reasonable amount for debugging
        if processedCount >= 10000 and addedCount == 0 then
            if not silent then
                d("WARNING: No mappings added after 10,000 items. Stopping for debugging.")
                d("This suggests a fundamental issue with name matching.")
            end
            break
        end
    end
    
    -- ===== ADD HARDCODED GLYPHS AND ESSENCES =====
    if not silent then d("Adding hardcoded glyphs and essences...") end
    local hardcodedAdded = AddHardcodedGlyphs(ukrainianTable, englishTable, itemDisplayMode, silent)
    addedCount = addedCount + hardcodedAdded
    
    if not silent then
        d("Hardcoded glyphs/essences added: " .. hardcodedAdded)
    end
    
    if not silent then
        d("")
        d("=== Generation Complete! ===")
        d("Total items processed: " .. processedCount)
        d("Ukrainian mappings added: " .. addedCount)
        d("Items skipped (not in TTC table): " .. skippedCount)
        d("Total items in Ukrainian table: " .. tostring(GetTableSize(ukrainianTable)))
        d("")
    end
    
    if addedCount == 0 then
        if not silent then
            d("ERROR: No Ukrainian mappings were added!")
            d("This means the Ukrainian item names from DovahMova don't match the English names in TTC.")
            d("Possible causes:")
            d("1. DovahMova's item names are not in the expected format")
            d("2. TTC's English names are formatted differently")
            d("3. Item IDs don't correspond between DovahMova and TTC")
            d("")
            d("Try running /debugua <item_name> to test a specific item lookup.")
        end
        return
    end
    
    -- CRITICAL: Replace the current ItemLookUpTable in memory immediately
    if not silent then d("Replacing TamrielTradeCentre.ItemLookUpTable with Ukrainian version...") end
    TamrielTradeCentre.ItemLookUpTable = ukrainianTable
    
    -- Save the table to saved variables
    local saveResult = SaveUkrainianTableToSavedVars(ukrainianTable, dovahMovaSettings, silent)
    if not saveResult then
        d("ERROR: Failed to save Ukrainian table to saved variables!")
        return ukrainianTable
    end
    
    -- Automatically clean up any duplicates that might have been created
    local cleanupResult = AutoCleanupDuplicates(true) -- Always run silently
    if cleanupResult > 0 and not silent then
        d("✓ Cleaned " .. cleanupResult .. " duplicate entries")
    end
    
    if not silent then 
        d("✓ ItemLookUpTable replaced successfully!")
        d("")
        d("=== IMPORTANT ===")
        d("The Ukrainian ItemLookUpTable is now active in memory!")
        d("Display mode: " .. itemDisplayMode)
        if itemDisplayMode == "ua" then
            d("Ukrainian item names should now show prices.")
        elseif itemDisplayMode == "uaen" then
            d("Ukrainian item names with postfixes should now show prices.")
        end
        d("This change is temporary - it will reset when you reload the UI.")
        d("")
        d("=== Testing Instructions ===")
        d("1. Find an item that DovahMova shows in Ukrainian")
        d("2. Hover over it to see the tooltip")
        d("3. You should now see TTC price information!")
        d("")
    end
    
    return ukrainianTable
end

-- Function to generate a permanent ItemLookUpTable_UA.lua file
local function GeneratePermanentFile()
    d("Permanent file generation not implemented yet - use the in-memory version first")
end

-- Improved auto-load function with better timing and reliability
local function AutoLoadFromSavedVars()
    if not AUTO_LOAD_FROM_SAVED_VARS then return end
    
    -- Try multiple times with increasing delays
    local attempts = 0
    local maxAttempts = 30  -- Increased to 30 attempts
    
    local function tryLoad()
        attempts = attempts + 1
        
        if TamrielTradeCentre and TamrielTradeCentre.ItemLookUpTable then
            if LoadUkrainianTableFromSavedVars(true) then -- Silent load
                if not SILENT_MODE_BY_DEFAULT then
                    d("✓ Auto-loaded Ukrainian lookup table from saved variables")
                end
                return true
            else
                -- Don't give up immediately, keep trying
                if attempts < maxAttempts then
                    local delay = 1000 + (attempts - 1) * 1000  -- 1s, 2s, 3s, etc.
                    zo_callLater(tryLoad, delay)
                else
                    if not SILENT_MODE_BY_DEFAULT then
                        d("No valid saved Ukrainian table found after " .. maxAttempts .. " attempts")
                        d("Use /generateua to create one, or /loadua to force load")
                    end
                    return false
                end
            end
        else
            if attempts < maxAttempts then
                -- Use exponential backoff: 500ms, 1000ms, 1500ms, etc.
                local delay = 500 + (attempts - 1) * 500
                zo_callLater(tryLoad, delay)
            else
                if not SILENT_MODE_BY_DEFAULT then
                    d("Failed to load Ukrainian table after " .. maxAttempts .. " attempts")
                    d("TTC may not be loaded yet. Try /generateua manually.")
                end
                return false
            end
        end
    end
    
    -- Start the first attempt after a short delay
    zo_callLater(tryLoad, 500)
end

-- Function to check if Ukrainian table is currently active
local function IsUkrainianTableActive()
    if not TamrielTradeCentre or not TamrielTradeCentre.ItemLookUpTable then
        return false
    end
    
    -- Check if the table has Ukrainian content by looking for a few known Ukrainian item names
    local ukrainianItems = 0
    local totalItems = 0
    
    for itemName, itemData in pairs(TamrielTradeCentre.ItemLookUpTable) do
        totalItems = totalItems + 1
        -- Look for Ukrainian characters (including ї, є, ґ)
        if string.find(itemName, "[а-яіїєґ]") then
            ukrainianItems = ukrainianItems + 1
        end
        -- Limit the check to first 1000 items for performance
        if totalItems > 1000 then break end
    end
    
    return ukrainianItems > 10 -- If we find more than 10 Ukrainian items, the table is likely active
end

-- Debug function to test item name lookup
local function DebugItemLookup(itemName)
    if not itemName or itemName == "" then
        d("Usage: /debugua <item_name>")
        d("Example: /debugua steel sword")
        return
    end
    
    itemName = string.lower(itemName)
    
    d("=== Debug Item Lookup ===")
    d("Looking up: '" .. itemName .. "'")
    
    if TamrielTradeCentre and TamrielTradeCentre.ItemLookUpTable then
        local result = TamrielTradeCentre.ItemLookUpTable[itemName]
        if result then
            d("✓ FOUND in ItemLookUpTable!")
            for quality, itemId in pairs(result) do
                d("  Quality " .. quality .. " = Item ID " .. itemId)
            end
        else
            d("✗ NOT FOUND in ItemLookUpTable")
            
            -- Try to find similar names
            d("Searching for similar names...")
            local found = false
            for name, data in pairs(TamrielTradeCentre.ItemLookUpTable) do
                if string.find(name, itemName) or string.find(itemName, name) then
                    d("  Similar: '" .. name .. "'")
                    found = true
                end
            end
            if not found then
                d("  No similar names found")
            end
        end
    else
        d("ERROR: TamrielTradeCentre.ItemLookUpTable not available")
    end
    
    -- Check DovahMova data
    if IsDovahMovaDataAvailable() then
        local savedVars = GetDovahMovaSavedVars()
        d("DovahMova items available: " .. tostring(GetTableSize(savedVars.Data.Items)))
        d("DovahMova display mode: " .. (savedVars.ShowItemsNamesTooltip or "unknown"))
    else
        d("DovahMova data not available")
    end
end

-- Auto-load from saved variables when TTC loads
EVENT_MANAGER:RegisterForEvent("DovahMova_TTC_LoadSaved", EVENT_ADD_ON_LOADED, function(event, addonName)
    if addonName == "TamrielTradeCentre" then
        AutoLoadFromSavedVars()
    end
end)

-- Auto-load from saved variables when player activates (after UI reload)
EVENT_MANAGER:RegisterForEvent("DovahMova_TTC_PlayerActivated", EVENT_PLAYER_ACTIVATED, function()
    if TamrielTradeCentre and TamrielTradeCentre.ItemLookUpTable then
        AutoLoadFromSavedVars()
    end
end)

-- Additional event to ensure loading after UI reload
EVENT_MANAGER:RegisterForEvent("DovahMova_TTC_UIReady", EVENT_PLAYER_ACTIVATED, function()
    -- Wait a bit longer for everything to be ready
    zo_callLater(function()
        if TamrielTradeCentre and TamrielTradeCentre.ItemLookUpTable then
            AutoLoadFromSavedVars()
        end
    end, 2000) -- Wait 2 seconds after player activation
end)

-- Export function for DovahMova settings button
DOVAHMOVA_GENERATE_TTC_UA = function()
    if IsDovahMovaDataAvailable() then
        GenerateUkrainianItemLookUpTable(true) -- Silent generation for settings button
        d("✓ Ukrainian lookup table generated successfully!")
        d("Items processed: " .. tostring(GetTableSize(GetDovahMovaSavedVars().Data.Items)))
        
        -- Try to load the table immediately after generation
        zo_callLater(function()
            if LoadUkrainianTableFromSavedVars(false) then
                d("✓ Ukrainian table loaded and is now active!")
            else
                d("⚠ Table generated but auto-load failed. Use /loadua to load manually.")
            end
        end, 1000) -- Wait 1 second after generation
    else
        d("ERROR: DovahMova data not available!")
        d("Make sure DovahMova has generated its translation data.")
        d("Try running /dovamova first to update DovahMova's database.")
    end
end

-- Test duplicate postfix detection and cleaning
SLASH_COMMANDS["/testduplicates"] = function(args)
    local testName = args or "грубий багаття, погашене (rough campfire, doused) (rough campfire, doused)"
    d("=== ТЕСТ ДУБЛІКАТІВ ПОСТФІКСІВ ===")
    d("Тестова назва: '" .. testName .. "'")
    
    local hasDuplicate = HasDuplicatedPostfix(testName)
    d("Має дублікат: " .. (hasDuplicate and "ТАК" or "НІ"))
    
    if hasDuplicate then
        local cleaned = CleanDuplicatedPostfix(testName)
        d("Очищена назва: '" .. cleaned .. "'")
    end
    
    -- Test with DovahMova Items data
    local dovahMovaVars = GetDovahMovaSavedVars()
    if dovahMovaVars and dovahMovaVars.Data and dovahMovaVars.Data.Items then
        local duplicateCount = 0
        local totalCount = 0
        
        d("Перевірка DovahMova.Data.Items...")
        for itemId, itemName in pairs(dovahMovaVars.Data.Items) do
            totalCount = totalCount + 1
            if type(itemName) == "string" and HasDuplicatedPostfix(itemName) then
                duplicateCount = duplicateCount + 1
                if duplicateCount <= 5 then
                    d("  Items дублікат: '" .. itemName .. "'")
                end
            end
        end
        
        d("Items: " .. duplicateCount .. " дублікатів з " .. totalCount .. " предметів")
    end
    
    -- Check TTC saved data
    local savedVars = GetSavedVars()
    if savedVars and savedVars.ukrainianTable then
        local ttcDuplicates = 0
        local ttcTotal = 0
        
        d("Перевірка TTC збережених даних...")
        for key, value in pairs(savedVars.ukrainianTable) do
            ttcTotal = ttcTotal + 1
            if type(key) == "string" and HasDuplicatedPostfix(key) then
                ttcDuplicates = ttcDuplicates + 1
                if ttcDuplicates <= 5 then
                    d("  TTC дублікат: '" .. key .. "'")
                end
            end
        end
        
        d("TTC: " .. ttcDuplicates .. " дублікатів з " .. ttcTotal .. " записів")
    end
    
    -- Check active TTC table
    if TamrielTradeCentre and TamrielTradeCentre.ItemLookUpTable then
        local activeDuplicates = 0
        local activeTotal = 0
        
        d("Перевірка активної TTC таблиці...")
        for key, value in pairs(TamrielTradeCentre.ItemLookUpTable) do
            activeTotal = activeTotal + 1
            if type(key) == "string" and HasDuplicatedPostfix(key) then
                activeDuplicates = activeDuplicates + 1
                if activeDuplicates <= 5 then
                    d("  Активна TTC дублікат: '" .. key .. "'")
                end
            end
        end
        
        d("Активна TTC: " .. activeDuplicates .. " дублікатів з " .. activeTotal .. " записів")
    end
    
    d("===============================")
end

-- Clean existing duplicates from TTC saved data
SLASH_COMMANDS["/cleanduplicates"] = function()
    d("=== ОЧИЩЕННЯ ДУБЛІКАТІВ ===")
    
    local savedVars = GetSavedVars()
    if not savedVars or not savedVars.ukrainianTable then
        d("✗ TTC збережені дані недоступні!")
        return
    end
    
    local cleaned = 0
    local toRemove = {}
    local toAdd = {}
    
    d("Сканування " .. GetTableSize(savedVars.ukrainianTable) .. " записів...")
    
    for key, value in pairs(savedVars.ukrainianTable) do
        if type(key) == "string" and HasDuplicatedPostfix(key) then
            local cleanKey = CleanDuplicatedPostfix(key)
            
            -- Only keep clean version if it doesn't already exist
            if not savedVars.ukrainianTable[cleanKey] and not toAdd[cleanKey] then
                toAdd[cleanKey] = value

            end
            
            toRemove[key] = true
            cleaned = cleaned + 1
        end
    end
    
    -- Remove duplicates
    for key in pairs(toRemove) do
        savedVars.ukrainianTable[key] = nil
    end
    
    -- Add clean versions
    for key, value in pairs(toAdd) do
        savedVars.ukrainianTable[key] = value
    end
    
    -- Also clean the active TTC table
    if TamrielTradeCentre and TamrielTradeCentre.ItemLookUpTable then
        local activeCleaned = 0
        local activeToRemove = {}
        local activeToAdd = {}
        
        for key, value in pairs(TamrielTradeCentre.ItemLookUpTable) do
            if type(key) == "string" and HasDuplicatedPostfix(key) then
                local cleanKey = CleanDuplicatedPostfix(key)
                
                if not TamrielTradeCentre.ItemLookUpTable[cleanKey] and not activeToAdd[cleanKey] then
                    activeToAdd[cleanKey] = value
                end
                
                activeToRemove[key] = true
                activeCleaned = activeCleaned + 1
            end
        end
        
        -- Clean active table
        for key in pairs(activeToRemove) do
            TamrielTradeCentre.ItemLookUpTable[key] = nil
        end
        
        for key, value in pairs(activeToAdd) do
            TamrielTradeCentre.ItemLookUpTable[key] = value
        end
        
        d("Очищено активну TTC таблицю: " .. activeCleaned .. " дублікатів")
    end
    
    d("🎉 Очищення завершено!")
    d("  Видалено дублікатів: " .. cleaned)
    d("  Додано чистих записів: " .. GetTableSize(toAdd))
    d("  Нових розмір TTC таблиці: " .. GetTableSize(savedVars.ukrainianTable))
    d("Запустіть /testduplicates для перевірки результату")
end

-- Enhanced test for hardcoded glyphs with diagnostic info
SLASH_COMMANDS["/testglyphs"] = function(args)
    d("=== Enhanced Hardcoded Glyphs Test ===")
    
    if not TamrielTradeCentre or not TamrielTradeCentre.ItemLookUpTable then
        d("✗ TTC not available")
        return
    end
    
    local ttcTable = TamrielTradeCentre.ItemLookUpTable
    local foundCount = 0
    local totalCount = 0
    local missingEnglish = {}
    local missingUkrainian = {}
    local workingItems = {}
    
    d("Checking hardcoded glyphs against TTC table...")
    d("")
    
    for ukrainianName, englishName in pairs(HARDCODED_GLYPHS) do
        totalCount = totalCount + 1
        local formattedEnglish = string.lower(englishName)
        local formattedUkrainian = string.lower(ukrainianName)
        
        -- Check if English name exists in TTC
        local englishExists = ttcTable[formattedEnglish] ~= nil
        -- Check if Ukrainian name was added to TTC
        local ukrainianExists = ttcTable[formattedUkrainian] ~= nil
        local ukrainianWithPostfix = ttcTable[formattedUkrainian .. " (" .. englishName .. ")"] ~= nil
        
        if englishExists then 
            foundCount = foundCount + 1 
            if ukrainianExists or ukrainianWithPostfix then
                table.insert(workingItems, ukrainianName)
            else
                table.insert(missingUkrainian, ukrainianName .. " -> " .. englishName)
            end
        else
            table.insert(missingEnglish, englishName)
        end
        
        -- Show detailed info for first 5 items or if args = "verbose"
        if totalCount <= 5 or args == "verbose" then
            d("'" .. ukrainianName .. "' -> '" .. englishName .. "'")
            d("  English '" .. formattedEnglish .. "': " .. (englishExists and "✓" or "✗"))
            d("  Ukrainian '" .. formattedUkrainian .. "': " .. (ukrainianExists and "✓" or "✗"))
            d("  Ukrainian+postfix: " .. (ukrainianWithPostfix and "✓" or "✗"))
            d("")
        end
    end
    
    d("=== RESULTS SUMMARY ===")
    d("Total hardcoded glyphs: " .. totalCount)
    d("English names found in TTC: " .. foundCount .. "/" .. totalCount)
    d("Working items (prices should show): " .. #workingItems)
    d("")
    
    if #workingItems > 0 then
        d("✅ WORKING ITEMS (should show prices):")
        for i = 1, math.min(#workingItems, 5) do
            d("  " .. workingItems[i])
        end
        if #workingItems > 5 then
            d("  ... and " .. (#workingItems - 5) .. " more")
        end
        d("")
    end
    
    if #missingUkrainian > 0 then
        d("⚠ NEEDS GENERATION (English in TTC, but Ukrainian missing):")
        for i = 1, math.min(#missingUkrainian, 5) do
            d("  " .. missingUkrainian[i])
        end
        if #missingUkrainian > 5 then
            d("  ... and " .. (#missingUkrainian - 5) .. " more")
        end
        d("→ Run /generateua to add these!")
        d("")
    end
    
    if #missingEnglish > 0 then
        d("❌ MISSING FROM TTC (need to fix English names):")
        for i = 1, math.min(#missingEnglish, 3) do
            d("  '" .. missingEnglish[i] .. "'")
        end
        if #missingEnglish > 3 then
            d("  ... and " .. (#missingEnglish - 3) .. " more")
        end
        d("→ These English names don't exist in TTC database")
        d("")
    end
    
    d("=== NEXT STEPS ===")
    if #workingItems > 0 then
        d("1. Test working items now - they should show prices!")
    end
    if #missingUkrainian > 0 then
        d("2. Run /generateua to add missing Ukrainian entries")
    end
    if #missingEnglish > 0 then
        d("3. Fix English names in HARDCODED_GLYPHS table")
    end
    d("Use '/testglyphs verbose' for detailed output")
    d("=====================================")
end

-- Simple hover debug system
local hoverDebugEnabled = false

SLASH_COMMANDS["/hoverdebug"] = function()
    hoverDebugEnabled = not hoverDebugEnabled
    if hoverDebugEnabled then
        d("✓ Hover debug ENABLED - наведіть на предмети для логів")
        d("Тестуємо хук...")
    else
        d("✗ Hover debug DISABLED")
    end
end

-- Test command to check if we can capture item names
SLASH_COMMANDS["/testitem"] = function(args)
    if not args or args == "" then
        d("Використання: /testitem <назва предмета>")
        d("Приклад: /testitem сутність здоров'я")
        return
    end
    
    local testName = string.lower(args)
    d("=== Тест предмета ===")
    d("Введено: '" .. args .. "'")
    d("Форматовано: '" .. testName .. "'")
    
    if TamrielTradeCentre and TamrielTradeCentre.ItemLookUpTable then
        local found = TamrielTradeCentre.ItemLookUpTable[testName] ~= nil
        d("В TTC таблиці: " .. (found and "✓ ТАК" or "✗ НІ"))
        
        -- Check postfix version
        local withPostfix = testName .. " (" .. args .. ")"
        local foundWithPostfix = TamrielTradeCentre.ItemLookUpTable[withPostfix] ~= nil
        d("З постфіксом '" .. withPostfix .. "': " .. (foundWithPostfix and "✓ ТАК" or "✗ НІ"))
    else
        d("✗ TTC недоступний")
    end
    d("==================")
end

-- Enhanced hover debug with guild store support
local function SetupHoverDebug()
    if not ItemTooltip then 
        return 
    end
    
    -- Common debug function
    local function DebugItemName(itemName, source)
        if itemName and itemName ~= "" then
            d("🔍 HOVER DEBUG (" .. source .. "):")
            d("  Назва: '" .. itemName .. "'")
            
            -- Check if it contains glyph/essence/potion/poison keywords
            if string.find(itemName, "гліф") or string.find(itemName, "Гліф") or 
               string.find(itemName, "сутність") or string.find(itemName, "Сутність") or 
               string.find(itemName, "отрута") or string.find(itemName, "Отрута") or 
               string.find(itemName, "зілля") or string.find(itemName, "Зілля") then
                
                local formattedName = string.lower(zo_strformat(SI_TOOLTIP_ITEM_NAME, itemName))
                d("  Форматовано: '" .. formattedName .. "'")
                
                -- Remove postfix (everything in parentheses) and trim
                local nameWithoutPostfix = string.gsub(itemName, "%s*%([^)]*%)%s*$", "")
                nameWithoutPostfix = string.gsub(nameWithoutPostfix, "^%s*(.-)%s*$", "%1") -- trim
                local lowerWithoutPostfix = string.lower(nameWithoutPostfix)
                d("  Без постфіксу: '" .. nameWithoutPostfix .. "'")
                d("  Lowercase: '" .. lowerWithoutPostfix .. "'")
                
                -- Check if it matches our hardcoded items
                local matchFound = false
                local matchedEnglish = ""
                
                -- Debug: show how many items we're checking
                local totalHardcoded = 0
                for _ in pairs(HARDCODED_GLYPHS) do
                    totalHardcoded = totalHardcoded + 1
                end
                d("  Перевіряємо " .. totalHardcoded .. " хардкодених записів...")
                
                for ukrainianName, englishName in pairs(HARDCODED_GLYPHS) do
                    local hardcodedLower = string.lower(string.gsub(ukrainianName, "^%s*(.-)%s*$", "%1"))
                    if hardcodedLower == lowerWithoutPostfix then
                        matchFound = true
                        matchedEnglish = englishName
                        d("  ✓ ЗНАЙДЕНО В ХАРДКОДІ: " .. englishName)
                        break
                    end
                end
                
                if not matchFound then
                    d("  ✗ НЕ ЗНАЙДЕНО В ХАРДКОДІ")
                    -- Show a few examples for debugging
                    local count = 0
                    for ukrainianName, englishName in pairs(HARDCODED_GLYPHS) do
                        if string.find(ukrainianName, "гліф") and count < 3 then
                            d("    Приклад: '" .. ukrainianName .. "' -> '" .. englishName .. "'")
                            count = count + 1
                        end
                    end
                end
                
                -- Check TTC table
    if TamrielTradeCentre and TamrielTradeCentre.ItemLookUpTable then
                    local ttcTable = TamrielTradeCentre.ItemLookUpTable
                    
                    -- Check if full formatted name (with postfix) is in TTC
                    local foundWithPostfix = ttcTable[formattedName] ~= nil
                    
                    -- Check if Ukrainian name without postfix is in TTC
                    local foundUkrainianOnly = ttcTable[lowerWithoutPostfix] ~= nil
                    
                    -- If we found it in hardcoded, check if the English version is in TTC
                    if matchFound and matchedEnglish ~= "" then
                        local englishInTTC = ttcTable[string.lower(matchedEnglish)] ~= nil
                    end
                    
                    -- Show final result
                    if foundUkrainianOnly or foundWithPostfix then
                    else
                    end
                else
                end
            end
    end
end

    -- Hook inventory items
    local originalSetBagItem = ItemTooltip.SetBagItem
    if originalSetBagItem then
        ItemTooltip.SetBagItem = function(self, bagId, slotIndex)
            local result = originalSetBagItem(self, bagId, slotIndex)
            
            if hoverDebugEnabled then
                local itemLink = GetItemLink(bagId, slotIndex)
                if itemLink and itemLink ~= "" then
                    local itemName = GetItemLinkName(itemLink)
                    DebugItemName(itemName, "INVENTORY")
                end
            end
            
            return result
        end
    else
    end
    
    -- Hook guild store items (try multiple methods)
    local originalSetGuildStoreItem = ItemTooltip.SetGuildStoreItem
    if originalSetGuildStoreItem then
        ItemTooltip.SetGuildStoreItem = function(self, guildStoreIndex)
            local result = originalSetGuildStoreItem(self, guildStoreIndex)
            
            if hoverDebugEnabled then
                local itemLink = GetGuildStoreItemLink(guildStoreIndex)
                if itemLink and itemLink ~= "" then
                    local itemName = GetItemLinkName(itemLink)
                    DebugItemName(itemName, "GUILD STORE")
    end
end

            return result
        end
    else
        
        -- Try alternative guild store hooks
        if ItemTooltip.SetStoreItem then
            local originalSetStoreItem = ItemTooltip.SetStoreItem
            ItemTooltip.SetStoreItem = function(self, storeIndex)
                local result = originalSetStoreItem(self, storeIndex)
                
                if hoverDebugEnabled then
                    local itemLink = GetStoreItemLink(storeIndex)
                    if itemLink and itemLink ~= "" then
                        local itemName = GetItemLinkName(itemLink)
                        DebugItemName(itemName, "STORE")
                end
            end

                return result
            end
        end
        
        -- Try hooking PopupTooltip for guild store
        if PopupTooltip and PopupTooltip.SetGuildStoreItem then
            local originalPopupSetGuildStoreItem = PopupTooltip.SetGuildStoreItem
            PopupTooltip.SetGuildStoreItem = function(self, guildStoreIndex)
                local result = originalPopupSetGuildStoreItem(self, guildStoreIndex)
                
                if hoverDebugEnabled then
                    local itemLink = GetGuildStoreItemLink(guildStoreIndex)
                    if itemLink and itemLink ~= "" then
                        local itemName = GetItemLinkName(itemLink)
                        DebugItemName(itemName, "GUILD STORE (POPUP)")
                    end
                end
                
                return result
            end
                end
            end
            
    -- Hook trading house items
    local originalSetTradingHouseListing = ItemTooltip.SetTradingHouseListing
    if originalSetTradingHouseListing then
        ItemTooltip.SetTradingHouseListing = function(self, tradingHouseIndex, ...)
            local result = originalSetTradingHouseListing(self, tradingHouseIndex, ...)
            
            if hoverDebugEnabled then
                local itemLink = GetTradingHouseListingItemLink(tradingHouseIndex)
                if itemLink and itemLink ~= "" then
                    local itemName = GetItemLinkName(itemLink)
                    DebugItemName(itemName, "TRADING HOUSE")
                end
            end
            
            return result
        end
    else
    end
    
    -- Hook loot items
    local originalSetLootItem = ItemTooltip.SetLootItem
    if originalSetLootItem then
        ItemTooltip.SetLootItem = function(self, lootId)
            local result = originalSetLootItem(self, lootId)
            
            if hoverDebugEnabled then
                local itemLink = GetLootItemLink(lootId)
                if itemLink and itemLink ~= "" then
                    local itemName = GetItemLinkName(itemLink)
                    DebugItemName(itemName, "LOOT")
    end
end

            return result
        end
    else
                end
            end

-- Auto-add glyphs when TTC loads
local function AutoAddGlyphs()
    if not TamrielTradeCentre or not TamrielTradeCentre.ItemLookUpTable then
        -- TTC not ready yet, try again later
        zo_callLater(AutoAddGlyphs, 2000)
        return
    end
    
    local ttcTable = TamrielTradeCentre.ItemLookUpTable
    local addedCount = 0
    
    -- Auto-add Ukrainian glyph names
    for ukrainianName, englishName in pairs(HARDCODED_GLYPHS) do
        local formattedEnglishName = string.lower(englishName)
        
        -- Check if English name exists in TTC
        if ttcTable[formattedEnglishName] then
            -- TTC uses multiple formats, so we need to add ALL possible variants:
            
            -- 1. Simple lowercase Ukrainian name
            local formattedUkrainianName = string.lower(ukrainianName)
            if not ttcTable[formattedUkrainianName] then
                ttcTable[formattedUkrainianName] = ttcTable[formattedEnglishName]
                addedCount = addedCount + 1
            end
            
            -- 2. zo_strformat version of Ukrainian name
            local zosFormattedUkrainian = string.lower(zo_strformat(SI_TOOLTIP_ITEM_NAME, ukrainianName))
            if not ttcTable[zosFormattedUkrainian] and zosFormattedUkrainian ~= formattedUkrainianName then
                ttcTable[zosFormattedUkrainian] = ttcTable[formattedEnglishName]
                addedCount = addedCount + 1
            end
            
            -- 3. Original case Ukrainian name (as GetItemLinkName might return)
            if not ttcTable[ukrainianName] then
                ttcTable[ukrainianName] = ttcTable[formattedEnglishName]
                addedCount = addedCount + 1
            end
            
            -- 4. zo_strformat with original case
            local zosOriginalCase = zo_strformat(SI_TOOLTIP_ITEM_NAME, ukrainianName)
            if not ttcTable[zosOriginalCase] and zosOriginalCase ~= ukrainianName then
                ttcTable[zosOriginalCase] = ttcTable[formattedEnglishName]
                addedCount = addedCount + 1
            end
        end
    end
    
    -- Now copy IDs from English entries
    local fixedIds = 0
    for ukrainianName, englishName in pairs(HARDCODED_GLYPHS) do
        local ukrainianKey = string.lower(ukrainianName)
        local englishKey = string.lower(englishName)
        
        local ukrainianEntry = ttcTable[ukrainianKey]
        local englishEntry = ttcTable[englishKey]
        
        if ukrainianEntry and englishEntry and englishEntry.ID and not ukrainianEntry.ID then
            ukrainianEntry.ID = englishEntry.ID
            -- Copy other important fields
            for field, value in pairs(englishEntry) do
                if not ukrainianEntry[field] and field ~= "ID" then
                    ukrainianEntry[field] = value
                end
            end
            fixedIds = fixedIds + 1
        end
    end
    
    -- Also add clean names (without postfix) for TTC compatibility
    local cleanAdded = 0
    for ukrainianName, englishName in pairs(HARDCODED_GLYPHS) do
        -- Remove postfix from Ukrainian name
        local cleanUkrainianName = string.gsub(ukrainianName, " %([^)]+%)$", "")
        local cleanUkrainianKey = string.lower(cleanUkrainianName)
        local englishKey = string.lower(englishName)
        
        -- Get English entry for copying data
        local englishEntry = ttcTable[englishKey]
        
        if englishEntry and not ttcTable[cleanUkrainianKey] then
            -- Create new entry with clean Ukrainian name
            ttcTable[cleanUkrainianKey] = {}
            
            -- Copy all data from English entry
            for field, value in pairs(englishEntry) do
                ttcTable[cleanUkrainianKey][field] = value
            end
            
            cleanAdded = cleanAdded + 1
        end
    end
end

-- Setup with longer delay and more debug
zo_callLater(function()
    SetupHoverDebug()
    
    -- Auto-add glyphs after a delay
    zo_callLater(AutoAddGlyphs, 5000)
end, 3000)

-- Add entries WITHOUT postfix for TTC compatibility
SLASH_COMMANDS["/addcleannames"] = function()
    d("=== ДОДАВАННЯ ЧИСТИХ НАЗВ ===")
    
    if not TamrielTradeCentre or not TamrielTradeCentre.ItemLookUpTable then
        d("✗ TTC недоступний!")
        return
    end
    
    local ttcTable = TamrielTradeCentre.ItemLookUpTable
    local added = 0
    
    -- Add clean Ukrainian names (without postfix)
    for ukrainianName, englishName in pairs(HARDCODED_GLYPHS) do
        -- Remove postfix from Ukrainian name
        local cleanUkrainianName = string.gsub(ukrainianName, " %([^)]+%)$", "")
        local cleanUkrainianKey = string.lower(cleanUkrainianName)
        local englishKey = string.lower(englishName)
        
        -- Get English entry for copying data
        local englishEntry = ttcTable[englishKey]
        
        if englishEntry and not ttcTable[cleanUkrainianKey] then
            -- Create new entry with clean Ukrainian name
            ttcTable[cleanUkrainianKey] = {}
            
            -- Copy all data from English entry
            for field, value in pairs(englishEntry) do
                ttcTable[cleanUkrainianKey][field] = value
            end
            
            added = added + 1
            d("✓ Додано: '" .. cleanUkrainianName .. "' -> ID: " .. tostring(englishEntry.ID or "nil"))
        end
    end
    
    d("🎉 Додано " .. added .. " чистих українських назв!")
    d("Тепер TTC має знайти ціни для українських гліфів!")
end

-- Test what name TTC actually uses for price lookup
SLASH_COMMANDS["/testttcname"] = function(args)
    local testName = args or "справді чудово гліф витривалості"
    d("=== ТЕСТ НАЗВИ TTC: '" .. testName .. "' ===")
    
    if not TamrielTradeCentre then
        d("✗ TTC недоступний!")
        return
    end
    
    -- Simulate what happens when TTC tries to get price
    local itemName = zo_strformat(SI_TOOLTIP_ITEM_NAME, testName)
    local cleanName = string.lower(itemName)
    
    d("Оригінальна назва: '" .. testName .. "'")
    d("Після zo_strformat: '" .. itemName .. "'")
    d("Після string.lower: '" .. cleanName .. "'")
    
    local ttcTable = TamrielTradeCentre.ItemLookUpTable
    local result = ttcTable[cleanName]
    
    if result then
        d("✓ ЗНАЙДЕНО в TTC з ключем: '" .. cleanName .. "'")
        if result.ID then
            d("  ID: " .. tostring(result.ID))
        else
            d("  ID: nil")
        end
    else
        d("✗ НЕ ЗНАЙДЕНО в TTC")
        
        -- Try without postfix
        local nameWithoutPostfix = string.gsub(testName, " %([^)]+%)$", "")
        local cleanWithoutPostfix = string.lower(zo_strformat(SI_TOOLTIP_ITEM_NAME, nameWithoutPostfix))
        d("Спроба без постфіксу: '" .. cleanWithoutPostfix .. "'")
        
        local resultWithoutPostfix = ttcTable[cleanWithoutPostfix]
        if resultWithoutPostfix then
            d("✓ ЗНАЙДЕНО БЕЗ ПОСТФІКСУ!")
            if resultWithoutPostfix.ID then
                d("  ID: " .. tostring(resultWithoutPostfix.ID))
            end
        else
            d("✗ НЕ ЗНАЙДЕНО і без постфіксу")
        end
    end
end

-- Find items with actual IDs in TTC table
SLASH_COMMANDS["/findids"] = function()
    d("=== ПОШУК ЗАПИСІВ З ID ===")
    
    if not TamrielTradeCentre or not TamrielTradeCentre.ItemLookUpTable then
        d("✗ TTC недоступний!")
        return
    end
    
    local ttcTable = TamrielTradeCentre.ItemLookUpTable
    local foundWithId = 0
    local foundWithoutId = 0
    
    d("Записи з ID (перші 10):")
    for key, value in pairs(ttcTable) do
        if value.ID and foundWithId < 10 then
            d("  '" .. key .. "' -> ID: " .. tostring(value.ID))
            foundWithId = foundWithId + 1
        elseif not value.ID then
            foundWithoutId = foundWithoutId + 1
        end
    end
    
    d("📊 Статистика:")
    d("  З ID: " .. foundWithId .. "+")
    d("  Без ID: " .. foundWithoutId)
    
    -- Check structure of first few entries
    d("Структура записів (перші 3):")
            local count = 0
    for key, value in pairs(ttcTable) do
        if count < 3 then
            d("  '" .. key .. "':")
            for field, fieldValue in pairs(value) do
                local valueType = type(fieldValue)
                if valueType == "table" then
                    d("    " .. field .. ": [table with " .. (#fieldValue > 0 and #fieldValue or "unknown") .. " entries]")
                else
                    d("    " .. field .. ": " .. tostring(fieldValue) .. " (" .. valueType .. ")")
                end
            end
                count = count + 1
        end
    end
    
    -- Check our specific glyphs
    d("Наші гліфи:")
    local glyphCount = 0
    for ukrainianName, englishName in pairs(HARDCODED_GLYPHS) do
        if glyphCount < 5 then
            local englishKey = string.lower(englishName)
            local englishEntry = ttcTable[englishKey]
            if englishEntry then
                d("  '" .. englishName .. "' -> ID: " .. tostring(englishEntry.ID or "nil"))
                glyphCount = glyphCount + 1
            end
        end
    end
end

-- Test how TTC actually gets prices
SLASH_COMMANDS["/testttcprice"] = function(args)
    local itemName = args or "справді чудово гліф витривалості"
    d("=== ТЕСТ ЦІНИ TTC: '" .. itemName .. "' ===")
    
    if not TamrielTradeCentre then
        d("✗ TTC недоступний!")
        return
    end
    
    -- Try TTC's own functions
    if TamrielTradeCentre.GetPriceInfo then
        d("Спроба через GetPriceInfo:")
        local priceInfo = TamrielTradeCentre.GetPriceInfo(itemName)
        if priceInfo then
            d("  ✓ Результат: " .. tostring(priceInfo))
        else
            d("  ✗ Результат: nil")
        end
    else
        d("GetPriceInfo недоступний")
    end
    
    if TamrielTradeCentre.GetItemInfo then
        d("Спроба через GetItemInfo:")
        local itemInfo = TamrielTradeCentre.GetItemInfo(itemName)
        if itemInfo then
            d("  ✓ Результат:")
            for key, value in pairs(itemInfo) do
                d("    " .. key .. ": " .. tostring(value))
            end
        else
            d("  ✗ Результат: nil")
        end
    else
        d("GetItemInfo недоступний")
    end
    
    -- Check if TTC has price functions
    d("Доступні TTC функції:")
    for key, value in pairs(TamrielTradeCentre) do
        if type(value) == "function" and string.find(string.lower(key), "price") then
            d("  ✓ " .. key)
        end
    end
    
    -- Try direct table lookup with different formats
    local ttcTable = TamrielTradeCentre.ItemLookUpTable
    if ttcTable then
        local testKeys = {
            string.lower(itemName),
            string.lower(zo_strformat(SI_TOOLTIP_ITEM_NAME, itemName)),
            itemName,
            zo_strformat(SI_TOOLTIP_ITEM_NAME, itemName)
        }
        
        d("Пряма перевірка таблиці:")
        for i, key in ipairs(testKeys) do
            local result = ttcTable[key]
            if result then
                d("  " .. i .. ". '" .. key .. "' -> ЗНАЙДЕНО")
                -- Check if it has price data
                local hasPrice = false
                for field, value in pairs(result) do
                    if type(field) == "number" then
                        d("    Ціна [" .. field .. "]: " .. tostring(value))
                        hasPrice = true
                    end
                end
                if not hasPrice then
                    d("    ⚠️ Немає цінових даних")
                end
            else
                d("  " .. i .. ". '" .. key .. "' -> НЕ ЗНАЙДЕНО")
            end
        end
    end
end

-- Add real item names to TTC table when they're detected
local function AddRealNameToTTC(realName, baseKey)
    if not TamrielTradeCentre or not TamrielTradeCentre.ItemLookUpTable then
        return false
    end
    
    local ttcTable = TamrielTradeCentre.ItemLookUpTable
    local cleanRealName = string.lower(zo_strformat(SI_TOOLTIP_ITEM_NAME, realName))
    
    -- Don't add if already exists
    if ttcTable[cleanRealName] then
        return false
    end
    
    -- Find base data to copy from
    local baseData = ttcTable[baseKey]
    if not baseData then
        return false
    end
    
    -- Copy data to real name
    ttcTable[cleanRealName] = {}
    for field, value in pairs(baseData) do
        ttcTable[cleanRealName][field] = value
    end
    
    return true
end

-- Custom tooltip hook to show TTC prices for Ukrainian items
local function AddTTCPriceToTooltip(tooltip, itemName, context)
    context = context or "unknown"
    
    -- Debug log when function is called (only if debug is enabled)
    local shouldDebugCall = (context == "guild_store" and DEBUG_GUILD_STORE) or (context == "inventory" and DEBUG_INVENTORY)
    
    if not TamrielTradeCentre or not TamrielTradeCentre.ItemLookUpTable then
        if (context == "guild_store" and DEBUG_GUILD_STORE) or (context == "inventory" and DEBUG_INVENTORY) then
            d("DEBUG [" .. context .. "]: TTC недоступний")
        end
        return
    end
    
    local ttcTable = TamrielTradeCentre.ItemLookUpTable
    local cleanName = string.lower(zo_strformat(SI_TOOLTIP_ITEM_NAME, itemName))
    
    local shouldDebug = (context == "guild_store" and DEBUG_GUILD_STORE) or (context == "inventory" and DEBUG_INVENTORY)
    
    if shouldDebug then
        d("DEBUG [" .. context .. "]: Шукаємо ціну для '" .. itemName .. "' -> '" .. cleanName .. "'")
    end
    
    -- Try to find price data directly
    local priceData = ttcTable[cleanName]
    
    if priceData then
        if shouldDebug then
            d("DEBUG [" .. context .. "]: Знайдено дані в TTC!")
        end
        -- Find the price (usually in field 1000 or other numeric fields)
        local price = nil
        for field, value in pairs(priceData) do
            if type(field) == "number" and type(value) == "number" then
                price = value
                if shouldDebug then
                    d("DEBUG [" .. context .. "]: Знайдено ціну: " .. price)
                end
                break
            end
        end
        
        if price then
            -- Add TTC price line to tooltip
            tooltip:AddLine("💰 TTC: " .. price .. " gold", 1, 1, 0)
            if shouldDebug then
                d("DEBUG [" .. context .. "]: Додано ціну в tooltip: " .. price .. " gold")
            end
        else
            if shouldDebug then
                d("DEBUG [" .. context .. "]: Ціну не знайдено в даних")
    end
        end
    else
        if shouldDebug then
            d("DEBUG [" .. context .. "]: Дані не знайдено в TTC для '" .. cleanName .. "'")
        end
        
        -- Try to find a matching base name and auto-add
        if _G.AUTO_ADD_REAL_NAMES then
            -- Check if this looks like a glyph with postfix
            local baseNamePattern = "^(.+) %((.+)%)$"
            local baseName, englishName = string.match(itemName, baseNamePattern)
            
            if baseName and englishName then
                if shouldDebug then
                    d("DEBUG [" .. context .. "]: Спроба знайти базову назву: '" .. baseName .. "' для англійської '" .. englishName .. "'")
                end
                
                -- Try to find existing data for base name or English name
                local baseKey = string.lower(baseName)
                local englishKey = string.lower(englishName)
                
                local baseData = ttcTable[baseKey] or ttcTable[englishKey]
                if baseData then
                    if shouldDebug then
                        d("DEBUG [" .. context .. "]: Знайдено базові дані, додаємо реальну назву...")
                    end
                    local sourceKey = (baseData == ttcTable[baseKey]) and baseKey or englishKey
                    if AddRealNameToTTC(itemName, sourceKey) then
                        -- Try again with the newly added name
                        local newPriceData = ttcTable[cleanName]
                        if newPriceData then
                            local price = nil
                            for field, value in pairs(newPriceData) do
                                if type(field) == "number" and type(value) == "number" then
                                    price = value
                                    break
                                end
                            end
                            if price then
                                tooltip:AddLine("TTC Price: " .. price .. " gold", 1, 1, 0)
                                if shouldDebug then
                                    d("DEBUG [" .. context .. "]: Додано ціну після автододавання!")
                                end
                            end
                        end
                    end
                end
            end
        end
        
        -- Try alternative formats
        if shouldDebug then
            local altFormats = {
                string.lower(itemName),
                itemName,
                zo_strformat(SI_TOOLTIP_ITEM_NAME, itemName)
            }
            
            for i, altName in ipairs(altFormats) do
                local altData = ttcTable[altName]
                if altData then
                    d("DEBUG [" .. context .. "]: Знайдено альтернативний формат " .. i .. ": '" .. altName .. "'")
                    break
                end
            end
        end
    end
end

-- Hook into ItemTooltip
local function SetupTTCTooltipHook()
    if not ItemTooltip then
        return false
    end
    
    -- Hook the SetBagItem function
    local originalSetBagItem = ItemTooltip.SetBagItem
    if originalSetBagItem then
        ItemTooltip.SetBagItem = function(self, bagId, slotIndex, ...)
            local result = originalSetBagItem(self, bagId, slotIndex, ...)
            
            -- Get item name and add TTC price
            local itemName = GetItemName(bagId, slotIndex)
            if DEBUG_INVENTORY then
                d("DEBUG [inventory]: SetBagItem викликано для '" .. tostring(itemName) .. "'")
            end
            if itemName and itemName ~= "" then
                AddTTCPriceToTooltip(self, itemName, "inventory")
            else
                if DEBUG_INVENTORY then
                    d("DEBUG [inventory]: Порожня назва предмета")
                end
            end
            
            return result
        end
        if DEBUG_INVENTORY then
            d("DEBUG [inventory]: SetBagItem hook встановлено")
        end
    else
        if DEBUG_INVENTORY then
            d("DEBUG [inventory]: SetBagItem недоступний")
    end
end

    -- Hook the SetLink function for chat links
    local originalSetLink = ItemTooltip.SetLink
    if originalSetLink then
        ItemTooltip.SetLink = function(self, itemLink, ...)
            local result = originalSetLink(self, itemLink, ...)
            
            -- Extract item name from link
            local itemName = GetItemLinkName(itemLink)
            if itemName and itemName ~= "" then
                AddTTCPriceToTooltip(self, itemName, "link")
            end
            
            return result
        end
    end
    
    -- Hook Guild Store/Trading House specifically
    zo_callLater(function()
        -- Hook Trading House search results
        if TRADING_HOUSE and TRADING_HOUSE.searchResultsList then
            local searchResultsList = TRADING_HOUSE.searchResultsList
            if searchResultsList.dataTypes and searchResultsList.dataTypes[1] then
                local originalSetupCallback = searchResultsList.dataTypes[1].setupCallback
                if originalSetupCallback then
                    searchResultsList.dataTypes[1].setupCallback = function(control, data, ...)
                        local result = originalSetupCallback(control, data, ...)
                        
                        -- Hook mouse enter for guild store items
                        if control and data then
                            local itemName = data.name or GetItemLinkName(data.itemLink or "")
                            if itemName and itemName ~= "" then
                                local originalOnMouseEnter = control:GetHandler("OnMouseEnter")
                                control:SetHandler("OnMouseEnter", function(self)
                                    if originalOnMouseEnter then
                                        originalOnMouseEnter(self)
                                    end
                                    
                                    -- Add our debug for guild store
                                    
                                    -- Try to add TTC price to tooltip
                                    zo_callLater(function()
                                        if ItemTooltip and not ItemTooltip:IsHidden() then
                                            AddTTCPriceToTooltip(ItemTooltip, itemName, "guild_store")
                                        else
                                        end
                                    end, 50)
                                end)
                            end
                        end
                        
                        return result
                    end
                    
                else
                end
            else
            end
        else
        end
        
        -- Hook SetTradingHouseItem if it exists
        if ItemTooltip and ItemTooltip.SetTradingHouseItem then
            local originalSetTradingHouseItem = ItemTooltip.SetTradingHouseItem
            ItemTooltip.SetTradingHouseItem = function(self, tradingHouseIndex, ...)
                local result = originalSetTradingHouseItem(self, tradingHouseIndex, ...)
                
                -- Safely get item name from trading house data
                local success, icon, itemName, displayQuality, stackCount, sellerName, timeRemaining, purchasePrice = pcall(GetTradingHouseSearchResultItemInfo, tradingHouseIndex)
                
                -- If we didn't get a proper name, try getting it from item link
                if not (success and itemName and itemName ~= "" and not string.find(itemName, "%.dds")) then
                    local linkSuccess, itemLink = pcall(GetTradingHouseSearchResultItemLink, tradingHouseIndex)
                    if linkSuccess and itemLink then
                        itemName = GetItemLinkName(itemLink)
                        if DEBUG_GUILD_STORE then
                        end
                    end
                end
                
                if itemName and itemName ~= "" and not string.find(itemName, "%.dds") then
        zo_callLater(function()
                        AddTTCPriceToTooltip(self, itemName, "guild_store")
                    end, 100)
                elseif DEBUG_GUILD_STORE then
                    if success and icon then
                    end
                end
                
                return result
            end
        else
        end
        
        -- Hook SetTradingHouseListing if it exists
        if ItemTooltip and ItemTooltip.SetTradingHouseListing then
            local originalSetTradingHouseListing = ItemTooltip.SetTradingHouseListing
            ItemTooltip.SetTradingHouseListing = function(self, listingIndex, ...)
                local result = originalSetTradingHouseListing(self, listingIndex, ...)
                
                -- Safely get item name from listing data
                local success, icon, itemName, displayQuality, stackCount, timeRemaining, purchasePrice = pcall(GetTradingHouseListingItemInfo, listingIndex)
                if success and itemName and itemName ~= "" then
                    zo_callLater(function()
                        AddTTCPriceToTooltip(self, itemName, "guild_store")
                    end, 100)
                elseif DEBUG_GUILD_STORE then
                    if success and icon then
                    end
                end
                
                return result
            end
        else
        end
    end, 2000)
    
    return true
end

-- Setup TTC tooltip hook
SLASH_COMMANDS["/setupttctooltip"] = function()
    d("=== НАЛАШТУВАННЯ TTC TOOLTIP ===")
    
    if SetupTTCTooltipHook() then
        d("✅ TTC tooltip hook встановлено!")
        d("Тепер ціни TTC мають показуватися для українських предметів.")
    else
        d("❌ Не вдалося встановити TTC tooltip hook")
    end
end

-- Test tooltip function manually
SLASH_COMMANDS["/testtooltip"] = function(args)
    local itemName = args or "справді чудово гліф витривалості"
    d("=== ТЕСТ TOOLTIP ===")
    d("Тестуємо tooltip для: '" .. itemName .. "'")
    
    -- Create a fake tooltip object for testing
    local fakeTooltip = {
        AddLine = function(self, text, r, g, b)
            d("TOOLTIP: " .. text .. " (color: " .. r .. "," .. g .. "," .. b .. ")")
        end
    }
    
    AddTTCPriceToTooltip(fakeTooltip, itemName)
end

-- Auto-add real names when detected in tooltip
SLASH_COMMANDS["/autoaddrealnames"] = function()
    d("=== АВТОДОДАВАННЯ РЕАЛЬНИХ НАЗВ ===")
    d("Тепер при наведенні на гліфи будуть автоматично додаватися реальні назви в TTC")
    
    -- Enable auto-adding in tooltip hook
    _G.AUTO_ADD_REAL_NAMES = true
end

-- Universal debug control command
-- Test new hardcoded glyphs
-- Test new potions and essences
-- Test poison + roman numeral combinations
SLASH_COMMANDS["/testpoisons"] = function()
    if not TamrielTradeCentre or not TamrielTradeCentre.ItemLookUpTable then
        d("❌ TTC недоступний")
        return
    end
    
    local ttcTable = TamrielTradeCentre.ItemLookUpTable
    
    d("=== ТЕСТ ОТРУТ З РИМСЬКИМИ ЦИФРАМИ ===")
    local found = 0
    local total = 0
    
    -- Test a few poison + roman combinations
    local testPoisons = {
        "отрута: шкода здоров'ю",
        "отрута: каліцтво",
        "отрута: втеча"
    }
    
    local testRomans = {"ix", "x", "viii"}
    
    for _, poison in ipairs(testPoisons) do
        for _, roman in ipairs(testRomans) do
            local combination = poison .. " " .. roman
            total = total + 1
            
            if HARDCODED_GLYPHS[combination] then
                local englishName = HARDCODED_GLYPHS[combination]
                local englishKey = string.lower(englishName)
                
                if ttcTable[englishKey] then
                    d("✅ " .. combination .. " -> " .. englishName)
                    found = found + 1
                else
                    d("❌ " .. combination .. " -> " .. englishName .. " (НЕ ЗНАЙДЕНО В TTC)")
                end
            else
                d("⚠️ " .. combination .. " НЕ ЗНАЙДЕНО В HARDCODED_GLYPHS")
            end
        end
    end
    
    d("📊 Результат: " .. found .. "/" .. total .. " комбінацій знайдено в TTC")
    d("Загальна кількість отрут: " .. GetTableSize(POISONS))
    d("Загальна кількість римських цифр: " .. GetTableSize(ROMAN_NUMERALS))
    d("Загальна кількість комбінацій: " .. (GetTableSize(POISONS) * GetTableSize(ROMAN_NUMERALS)))
end

SLASH_COMMANDS["/testnewpotions"] = function()
    if not TamrielTradeCentre or not TamrielTradeCentre.ItemLookUpTable then
        d("❌ TTC недоступний")
        return
    end
    
    local ttcTable = TamrielTradeCentre.ItemLookUpTable
    local newItems = {
        -- New essences
        "сутність критичний удар зброї",
        "сутність невидимість",
        -- New potions
        "зілля спритної втечі",
        "зілля спритного приховування",
        "добродійний зілля заклинань альянсу",
        -- New poisons
        "отрута: шкода здоров'ю",
        "отрута: висмоктування здоров'я",
        "отрута: сповільнення",
        "отрута: втеча",
        "отрута: висмоктування чарів",
        "отрута: висмоктування жорстокості",
        "отрута: каліцтво",
        "хмарна стримуюча отрута",
        "отрута для здоров'я з туманним ефектом",
        "хмарний поступовий спустошливий ефект здоров'я отрути"
    }
    
    d("=== ТЕСТ НОВИХ ЗІЛЛЬ, СУТНОСТЕЙ ТА ОТРУТ ===")
    local found = 0
    local total = #newItems
    
    for _, itemName in ipairs(newItems) do
        if HARDCODED_GLYPHS[itemName] then
            local englishName = HARDCODED_GLYPHS[itemName]
            local englishKey = string.lower(englishName)
            
            if ttcTable[englishKey] then
                d("✅ " .. itemName .. " -> " .. englishName)
                found = found + 1
            else
                d("❌ " .. itemName .. " -> " .. englishName .. " (НЕ ЗНАЙДЕНО В TTC)")
            end
        else
            d("⚠️ " .. itemName .. " НЕ ЗНАЙДЕНО В HARDCODED_GLYPHS")
        end
    end
    
    d("📊 Результат: " .. found .. "/" .. total .. " предметів знайдено в TTC")
    d("Тепер запустіть /reloadui та перевірте ціни в Guild Store!")
end

SLASH_COMMANDS["/testnewglyphs"] = function()
    if not TamrielTradeCentre or not TamrielTradeCentre.ItemLookUpTable then
        d("❌ TTC недоступний")
        return
    end
    
    local ttcTable = TamrielTradeCentre.ItemLookUpTable
    local newGlyphs = {
        "гліф зменшення фізичної шкоди",
        "гліф змішування", 
        "гліф ослаблення",
        "гліф збільшення магічної шкоди",
        "гліф удару",
        "гліф загартовування", 
        "гліф отрути",
        "гліф зілля швидкості",
        "гліф відновлення призматичної енергії",
        "гліф захист від призми",
        "гліф відсилування зілля",
        "гліф поглинання витривалості",
        "гліф стійкість до шоку",
        "гліф стійкість до хвороб",
        "гліф зменшення вартості навички",
        "гліф сморід",
        "гліф зміцнення"
    }
    
    d("=== ТЕСТ НОВИХ ГЛІФІВ ===")
    local found = 0
    local total = #newGlyphs
    
    for _, glyphType in ipairs(newGlyphs) do
        if HARDCODED_GLYPHS[glyphType] then
            local englishName = HARDCODED_GLYPHS[glyphType]
            local englishKey = string.lower(englishName)
            
            if ttcTable[englishKey] then
                d("✅ " .. glyphType .. " -> " .. englishName)
                found = found + 1
            else
                d("❌ " .. glyphType .. " -> " .. englishName .. " (НЕ ЗНАЙДЕНО В TTC)")
            end
        else
            d("⚠️ " .. glyphType .. " НЕ ЗНАЙДЕНО В HARDCODED_GLYPHS")
        end
    end
    
    d("📊 Результат: " .. found .. "/" .. total .. " гліфів знайдено в TTC")
    d("Тепер запустіть /reloadui та перевірте ціни в Guild Store!")
end

SLASH_COMMANDS["/hoverlog"] = function(args)
    if args == "on" or args == "1" or args == "true" then
        DEBUG_GUILD_STORE = true
        DEBUG_INVENTORY = true
        d("🔍 ВСІ HOVER ЛОГИ УВІМКНЕНО")
        d("  🏪 Guild Store: УВІМКНЕНО")
        d("  🎒 Inventory: УВІМКНЕНО")
    elseif args == "off" or args == "0" or args == "false" then
        DEBUG_GUILD_STORE = false
        DEBUG_INVENTORY = false
        d("🔇 ВСІ HOVER ЛОГИ ВИМКНЕНО")
        d("  🏪 Guild Store: ВИМКНЕНО")
        d("  🎒 Inventory: ВИМКНЕНО")
    elseif args == "guild" or args == "guildstore" then
        DEBUG_GUILD_STORE = not DEBUG_GUILD_STORE
        DEBUG_INVENTORY = false
        d("🏪 ТІЛЬКИ Guild Store логи: " .. (DEBUG_GUILD_STORE and "УВІМКНЕНО" or "ВИМКНЕНО"))
    elseif args == "inv" or args == "inventory" then
        DEBUG_INVENTORY = not DEBUG_INVENTORY
        DEBUG_GUILD_STORE = false
        d("🎒 ТІЛЬКИ Inventory логи: " .. (DEBUG_INVENTORY and "УВІМКНЕНО" or "ВИМКНЕНО"))
    else
        -- Toggle both
        local newState = not (DEBUG_GUILD_STORE or DEBUG_INVENTORY)
        DEBUG_GUILD_STORE = newState
        DEBUG_INVENTORY = newState
        d("🔄 ВСІ HOVER ЛОГИ: " .. (newState and "УВІМКНЕНО" or "ВИМКНЕНО"))
        d("  🏪 Guild Store: " .. (DEBUG_GUILD_STORE and "УВІМКНЕНО" or "ВИМКНЕНО"))
        d("  🎒 Inventory: " .. (DEBUG_INVENTORY and "УВІМКНЕНО" or "ВИМКНЕНО"))
    end
    
    d("Використання:")
    d("  /hoverlog - перемкнути всі")
    d("  /hoverlog on/off - увімкнути/вимкнути всі")
    d("  /hoverlog guild - тільки Guild Store")
    d("  /hoverlog inv - тільки Inventory")
end

-- Keep old commands for compatibility
SLASH_COMMANDS["/debugguildstore"] = function(args)
    if args == "on" or args == "1" or args == "true" then
        DEBUG_GUILD_STORE = true
        d("🔍 Guild Store debug УВІМКНЕНО")
    elseif args == "off" or args == "0" or args == "false" then
        DEBUG_GUILD_STORE = false
        d("🔇 Guild Store debug ВИМКНЕНО")
    else
        DEBUG_GUILD_STORE = not DEBUG_GUILD_STORE
        d("🔄 Guild Store debug: " .. (DEBUG_GUILD_STORE and "УВІМКНЕНО" or "ВИМКНЕНО"))
    end
end

SLASH_COMMANDS["/debuginventory"] = function(args)
    if args == "on" or args == "1" or args == "true" then
        DEBUG_INVENTORY = true
        d("🔍 Inventory debug УВІМКНЕНО")
    elseif args == "off" or args == "0" or args == "false" then
        DEBUG_INVENTORY = false
        d("🔇 Inventory debug ВИМКНЕНО")
    else
        DEBUG_INVENTORY = not DEBUG_INVENTORY
        d("🔄 Inventory debug: " .. (DEBUG_INVENTORY and "УВІМКНЕНО" or "ВИМКНЕНО"))
    end
end

-- Debug status command
SLASH_COMMANDS["/debugstatus"] = function()
    if TRADING_HOUSE then
    end
end

-- Auto-setup TTC tooltip hook
zo_callLater(function()
    if SetupTTCTooltipHook() then
        -- Enable auto-adding by default
        _G.AUTO_ADD_REAL_NAMES = true
    else
    end
end, 5000)
