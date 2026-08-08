--[[
    BlockPooky HoT Tracker Module - Update 49 HoT Cap Support
    
    This module tracks Healing-over-Time effects on the player to monitor compliance
    with the Update 49 HoT cap (maximum 8 stacks per player).
    
    Key Features:
    - Detects healing skill casts on player via EVENT_COMBAT_EVENT
    - Tracks both stacking and non-stacking HoTs
    - Handles per-caster stacking (same caster refreshes, different casters stack)
    - Visual counter bar showing current count vs cap (8)
    - Color warnings: Green (safe) â†’ Yellow (warning) â†’ Red (at cap)
    - Movable UI with position persistence
    - Toggle on/off via settings menu (default: OFF)
    
    How It Works:
    1. DATABASE: hotDatabase contains ability IDs mapped to HoT properties
       - abilityId â†’ {name, stackable, duration}
       - Still needs to be populated with actual HoT ability list
    
    2. EVENT MONITORING: Listens to EVENT_COMBAT_EVENT
       - Filters for events where player is the TARGET
       - Matches ability IDs against hotDatabase
       - Tracks skill casts with duration from database
    
    3. TRACKING: activeHoTs table stores currently active HoTs
       - Indexed by: sourceName_abilityName (handles per-caster stacking + rank refreshes)
       - Stores: abilityId, sourceName, startTime, endTime, stackCount, isStackable
       - All ranks of same skill from same caster use same key (prevents rank stacking)
    
    4. COUNTING: GetTotalHoTCount() calculates:
       - Stackable HoTs: sum of all stackCount values
       - Non-stackable HoTs: count as 1 each (multiple casters still count)
       - Total toward 8-cap
    
    5. DISPLAY: Updates bar with total/8 and color coding
       - Green: 0-5 (safe)
       - Yellow: 6-7 (warning)
       - Red: 8+ (at cap)
--]]

--[[ basic initialization -------------------------------------------------------------------------------------------]]
BlockPooky = BlockPooky or {}
local BlockPooky = BlockPooky

--[[ HoT database definition ---------------------------------------------------------------------------------------]]

---HoT Ability Database - Extracted from ESO_HOTS CSV
---Structure: {abilityId} = {name, stackable, duration}
---
---NOTE: CSV data marks all HoTs as "Group Only (Refreshes on Self)" 
---This database marks them all as non-stackable (stackable=false) as a conservative default.
---KNOWN STACKABLE HoTs that should have stackable=true (manual override from community knowledge):
---  - Echoing Vigor (61505): CAN stack with different casters
---  - Vigor (61503): CAN stack with different casters
---  - Other stacking abilities may exist - adjust as needed based on Update 49 testing
---
---For future updates, extract with: `python extract_hots.py` from the ESO_HOTS CSV
-- HoT Database extracted from ESO_HOTS CSV
-- Generated for Update 49 HoT Cap (8 stacks)
-- IMPORTANT: ALL rank IDs are included to ensure detection of all ability casts

-- HoT Database extracted from ESO_HOTS Categorized CSV
-- Sorted by category, then name, then ability ID

-- HoT Database extracted from ESO_HOTS Categorized CSV
-- Sorted by category, then name, then ability ID

BlockPooky.hotDatabase = {
    -- Other / Special
    [28348] = {
        name = "Absorption Field",
        stackable = false,
        duration = 12.0
    },
    [28351] = {
        name = "Absorption Field",
        stackable = false,
        duration = 12.0
    },
    [29867] = {
        name = "Absorption Field",
        stackable = false,
        duration = 12.0
    },
    [29874] = {
        name = "Absorption Field",
        stackable = false,
        duration = 12.0
    },
    [29881] = {
        name = "Absorption Field",
        stackable = false,
        duration = 12.0
    },
    [47167] = {
        name = "Absorption Field",
        stackable = false,
        duration = 12.0
    },
    [47168] = {
        name = "Absorption Field",
        stackable = false,
        duration = 12.0
    },
    [80405] = {
        name = "Absorption Field",
        stackable = false,
        duration = 12.0
    },
    [248474] = {
        name = "Ancient Resolve",
        stackable = false,
        duration = 5.0
    },
    [248509] = {
        name = "Ancient Resolve",
        stackable = false,
        duration = 5.0
    },
    [248834] = {
        name = "Ancient Resolve",
        stackable = false,
        duration = 5.0
    },
    [86148] = {
        name = "Arctic Wind",
        stackable = false,
        duration = 10.0
    },
    [86149] = {
        name = "Arctic Wind",
        stackable = false,
        duration = 10.0
    },
    [86150] = {
        name = "Arctic Wind",
        stackable = false,
        duration = 10.0
    },
    [86151] = {
        name = "Arctic Wind",
        stackable = false,
        duration = 10.0
    },
    [90833] = {
        name = "Arctic Wind",
        stackable = false,
        duration = 10.0
    },
    [176426] = {
        name = "Arctic Wind",
        stackable = false,
        duration = 10.0
    },
    [223706] = {
        name = "Ash Cloud",
        stackable = false,
        duration = 8.0
    },
    [223713] = {
        name = "Ash Cloud",
        stackable = false,
        duration = 8.0
    },
    [223714] = {
        name = "Ash Cloud",
        stackable = false,
        duration = 8.0
    },
    [163684] = {
        name = "Beam of Reproach",
        stackable = false,
        duration = 8.0
    },
    [163688] = {
        name = "Beam of Reproach",
        stackable = false,
        duration = 8.0
    },
    [163689] = {
        name = "Beam of Reproach",
        stackable = false,
        duration = 8.0
    },
    [169252] = {
        name = "Beam of Reproach",
        stackable = false,
        duration = 8.0
    },
    [196044] = {
        name = "Beam of Reproach",
        stackable = false,
        duration = 8.0
    },
    [133118] = {
        name = "Bestial Frenzy",
        stackable = false,
        duration = 10.0
    },
    [211927] = {
        name = "Bestial Frenzy",
        stackable = false,
        duration = 10.0
    },
    [211952] = {
        name = "Bestial Frenzy",
        stackable = false,
        duration = 10.0
    },
    [211954] = {
        name = "Bestial Frenzy",
        stackable = false,
        duration = 10.0
    },
    [211955] = {
        name = "Bestial Frenzy",
        stackable = false,
        duration = 10.0
    },
    [212157] = {
        name = "Bestial Frenzy",
        stackable = false,
        duration = 10.0
    },
    [230506] = {
        name = "Bestial Frenzy",
        stackable = false,
        duration = 10.0
    },
    [230507] = {
        name = "Bestial Frenzy",
        stackable = false,
        duration = 10.0
    },
    [230509] = {
        name = "Bestial Frenzy",
        stackable = false,
        duration = 10.0
    },
    [157287] = {
        name = "Blood Transfusion",
        stackable = false,
        duration = 8.0
    },
    [36493] = {
        name = "Bolstering Darkness",
        stackable = false,
        duration = 13.0
    },
    [36495] = {
        name = "Bolstering Darkness",
        stackable = false,
        duration = 13.0
    },
    [36496] = {
        name = "Bolstering Darkness",
        stackable = false,
        duration = 13.0
    },
    [37734] = {
        name = "Bolstering Darkness",
        stackable = false,
        duration = 13.0
    },
    [37739] = {
        name = "Bolstering Darkness",
        stackable = false,
        duration = 13.0
    },
    [37744] = {
        name = "Bolstering Darkness",
        stackable = false,
        duration = 13.0
    },
    [85840] = {
        name = "Budding Seeds",
        stackable = false,
        duration = 6.0
    },
    [85841] = {
        name = "Budding Seeds",
        stackable = false,
        duration = 6.0
    },
    [85842] = {
        name = "Budding Seeds",
        stackable = false,
        duration = 6.0
    },
    [92214] = {
        name = "Budding Seeds",
        stackable = false,
        duration = 6.0
    },
    [92215] = {
        name = "Budding Seeds",
        stackable = false,
        duration = 6.0
    },
    [93536] = {
        name = "Budding Seeds",
        stackable = false,
        duration = 6.0
    },
    [93805] = {
        name = "Budding Seeds",
        stackable = false,
        duration = 6.0
    },
    [93806] = {
        name = "Budding Seeds",
        stackable = false,
        duration = 6.0
    },
    [93807] = {
        name = "Budding Seeds",
        stackable = false,
        duration = 6.0
    },
    [96497] = {
        name = "Budding Seeds",
        stackable = false,
        duration = 6.0
    },
    [129434] = {
        name = "Budding Seeds",
        stackable = false,
        duration = 6.0
    },
    [220801] = {
        name = "Call the Dead",
        stackable = false,
        duration = 4.0
    },
    [25411] = {
        name = "Consuming Darkness",
        stackable = false,
        duration = 10.0
    },
    [25412] = {
        name = "Consuming Darkness",
        stackable = false,
        duration = 10.0
    },
    [25444] = {
        name = "Consuming Darkness",
        stackable = false,
        duration = 10.0
    },
    [31244] = {
        name = "Consuming Darkness",
        stackable = false,
        duration = 10.0
    },
    [37686] = {
        name = "Consuming Darkness",
        stackable = false,
        duration = 11.0
    },
    [37691] = {
        name = "Consuming Darkness",
        stackable = false,
        duration = 12.0
    },
    [37696] = {
        name = "Consuming Darkness",
        stackable = false,
        duration = 13.0
    },
    [155515] = {
        name = "Crimson Font",
        stackable = false,
        duration = 16.0
    },
    [155516] = {
        name = "Crimson Font",
        stackable = false,
        duration = 16.0
    },
    [155540] = {
        name = "Crimson Font",
        stackable = false,
        duration = 16.0
    },
    [196038] = {
        name = "Crimson Font",
        stackable = false,
        duration = 16.0
    },
    [46215] = {
        name = "Damage Health",
        stackable = false,
        duration = 0.001
    },
    [61505] = {
        name = "Echoing Vigor",
        stackable = true,
        duration = 10.0
    },
    [61506] = {
        name = "Echoing Vigor",
        stackable = true,
        duration = 10.0
    },
    [63243] = {
        name = "Echoing Vigor",
        stackable = true,
        duration = 12.0
    },
    [63245] = {
        name = "Echoing Vigor",
        stackable = true,
        duration = 14.0
    },
    [63247] = {
        name = "Echoing Vigor",
        stackable = true,
        duration = 16.0
    },
    [8512] = {
        name = "Elder's Gift",
        stackable = false,
        duration = 12.0
    },
    [9432] = {
        name = "Elder's Gift",
        stackable = false,
        duration = 14.0
    },
    [10904] = {
        name = "Elder's Gift",
        stackable = false,
        duration = 12.0
    },
    [11413] = {
        name = "Elder's Gift",
        stackable = false,
        duration = 12.0
    },
    [11414] = {
        name = "Elder's Gift",
        stackable = false,
        duration = 12.0
    },
    [12102] = {
        name = "Elder's Gift",
        stackable = false,
        duration = 12.0
    },
    [12105] = {
        name = "Elder's Gift",
        stackable = false,
        duration = 12.0
    },
    [165871] = {
        name = "Entomb",
        stackable = false,
        duration = 4.0
    },
    [165906] = {
        name = "Entomb",
        stackable = false,
        duration = 4.0
    },
    [165907] = {
        name = "Entomb",
        stackable = false,
        duration = 4.0
    },
    [165908] = {
        name = "Entomb",
        stackable = false,
        duration = 4.0
    },
    [169248] = {
        name = "Entomb",
        stackable = false,
        duration = 4.0
    },
    [175540] = {
        name = "Entomb",
        stackable = false,
        duration = 4.0
    },
    [175541] = {
        name = "Entomb",
        stackable = false,
        duration = 4.0
    },
    [175542] = {
        name = "Entomb",
        stackable = false,
        duration = 4.0
    },
    [175543] = {
        name = "Entomb",
        stackable = false,
        duration = 4.0
    },
    [175544] = {
        name = "Entomb",
        stackable = false,
        duration = 4.0
    },
    [8664] = {
        name = "Focused Healing",
        stackable = false,
        duration = 2.4
    },
    [9592] = {
        name = "Focused Healing",
        stackable = false,
        duration = 2.0
    },
    [9594] = {
        name = "Focused Healing",
        stackable = false,
        duration = 2.4
    },
    [10608] = {
        name = "Focused Healing",
        stackable = false,
        duration = 2.4
    },
    [11409] = {
        name = "Focused Healing",
        stackable = false,
        duration = 2.0
    },
    [48345] = {
        name = "Focused Healing",
        stackable = false,
        duration = 2.4
    },
    [48898] = {
        name = "Focused Healing",
        stackable = false,
        duration = 2.4
    },
    [50985] = {
        name = "Focused Healing",
        stackable = false,
        duration = 2.4
    },
    [53994] = {
        name = "Focused Healing",
        stackable = false,
        duration = 2.4
    },
    [57534] = {
        name = "Focused Healing",
        stackable = false,
        duration = 2.4
    },
    [57537] = {
        name = "Focused Healing",
        stackable = false,
        duration = 2.4
    },
    [57538] = {
        name = "Focused Healing",
        stackable = false,
        duration = 2.4
    },
    [70616] = {
        name = "Focused Healing",
        stackable = false,
        duration = 2.4
    },
    [70617] = {
        name = "Focused Healing",
        stackable = false,
        duration = 2.4
    },
    [70618] = {
        name = "Focused Healing",
        stackable = false,
        duration = 2.4
    },
    [70830] = {
        name = "Focused Healing",
        stackable = false,
        duration = 2.4
    },
    [70832] = {
        name = "Focused Healing",
        stackable = false,
        duration = 2.4
    },
    [70833] = {
        name = "Focused Healing",
        stackable = false,
        duration = 2.4
    },
    [107684] = {
        name = "Focused Healing",
        stackable = false,
        duration = 2.4
    },
    [107686] = {
        name = "Focused Healing",
        stackable = false,
        duration = 2.4
    },
    [107687] = {
        name = "Focused Healing",
        stackable = false,
        duration = 2.4
    },
    [120701] = {
        name = "Focused Healing",
        stackable = false,
        duration = 2.4
    },
    [120702] = {
        name = "Focused Healing",
        stackable = false,
        duration = 2.4
    },
    [120703] = {
        name = "Focused Healing",
        stackable = false,
        duration = 2.4
    },
    [124272] = {
        name = "Focused Healing",
        stackable = false,
        duration = 2.4
    },
    [137520] = {
        name = "Focused Healing",
        stackable = false,
        duration = 2.4
    },
    [137521] = {
        name = "Focused Healing",
        stackable = false,
        duration = 2.4
    },
    [137522] = {
        name = "Focused Healing",
        stackable = false,
        duration = 2.4
    },
    [156362] = {
        name = "Focused Healing",
        stackable = false,
        duration = 2.4
    },
    [156363] = {
        name = "Focused Healing",
        stackable = false,
        duration = 2.4
    },
    [179551] = {
        name = "Focused Healing",
        stackable = false,
        duration = 2.4
    },
    [179552] = {
        name = "Focused Healing",
        stackable = false,
        duration = 2.4
    },
    [211121] = {
        name = "Focused Healing",
        stackable = false,
        duration = 2.4
    },
    [211122] = {
        name = "Focused Healing",
        stackable = false,
        duration = 2.4
    },
    [211123] = {
        name = "Focused Healing",
        stackable = false,
        duration = 2.4
    },
    [211128] = {
        name = "Focused Healing",
        stackable = false,
        duration = 2.4
    },
    [226596] = {
        name = "Focused Healing",
        stackable = false,
        duration = 2.4
    },
    [226597] = {
        name = "Focused Healing",
        stackable = false,
        duration = 2.4
    },
    [226598] = {
        name = "Focused Healing",
        stackable = false,
        duration = 2.4
    },
    [193794] = {
        name = "Glyphic of the Tides",
        stackable = false,
        duration = 15.0
    },
    [193795] = {
        name = "Glyphic of the Tides",
        stackable = false,
        duration = 15.0
    },
    [193796] = {
        name = "Glyphic of the Tides",
        stackable = false,
        duration = 15.0
    },
    [193797] = {
        name = "Glyphic of the Tides",
        stackable = false,
        duration = 15.0
    },
    [193798] = {
        name = "Glyphic of the Tides",
        stackable = false,
        duration = 15.0
    },
    [193799] = {
        name = "Glyphic of the Tides",
        stackable = false,
        duration = 15.0
    },
    [193800] = {
        name = "Glyphic of the Tides",
        stackable = false,
        duration = 15.0
    },
    [194191] = {
        name = "Glyphic of the Tides",
        stackable = false,
        duration = 15.0
    },
    [194194] = {
        name = "Glyphic of the Tides",
        stackable = false,
        duration = 15.0
    },
    [194195] = {
        name = "Glyphic of the Tides",
        stackable = false,
        duration = 15.0
    },
    [194196] = {
        name = "Glyphic of the Tides",
        stackable = false,
        duration = 15.0
    },
    [201394] = {
        name = "Glyphic of the Tides",
        stackable = false,
        duration = 15.0
    },
    [20193794] = {
        name = "Glyphic of the Tides",
        stackable = false,
        duration = 15.0
    },
    [30193794] = {
        name = "Glyphic of the Tides",
        stackable = false,
        duration = 15.0
    },
    [40193794] = {
        name = "Glyphic of the Tides",
        stackable = false,
        duration = 15.0
    },
    [28385] = {
        name = "Grand Healing",
        stackable = false,
        duration = 10.0
    },
    [28386] = {
        name = "Grand Healing",
        stackable = false,
        duration = 10.0
    },
    [41244] = {
        name = "Grand Healing",
        stackable = false,
        duration = 10.0
    },
    [41246] = {
        name = "Grand Healing",
        stackable = false,
        duration = 10.0
    },
    [41248] = {
        name = "Grand Healing",
        stackable = false,
        duration = 10.0
    },
    [70008] = {
        name = "Grand Healing",
        stackable = false,
        duration = 10.0
    },
    [70010] = {
        name = "Grand Healing",
        stackable = false,
        duration = 10.0
    },
    [70012] = {
        name = "Grand Healing",
        stackable = false,
        duration = 10.0
    },
    [125846] = {
        name = "Grand Healing",
        stackable = false,
        duration = 10.0
    },
    [176912] = {
        name = "Grand Healing",
        stackable = false,
        duration = 10.0
    },
    [214708] = {
        name = "Haze of Cinders",
        stackable = false,
        duration = 8.0
    },
    [215382] = {
        name = "Haze of Cinders",
        stackable = false,
        duration = 8.0
    },
    [215383] = {
        name = "Haze of Cinders",
        stackable = false,
        duration = 8.0
    },
    [85578] = {
        name = "Healing Seed",
        stackable = false,
        duration = 6.0
    },
    [85582] = {
        name = "Healing Seed",
        stackable = false,
        duration = 6.0
    },
    [85585] = {
        name = "Healing Seed",
        stackable = false,
        duration = 6.0
    },
    [93802] = {
        name = "Healing Seed",
        stackable = false,
        duration = 6.0
    },
    [93803] = {
        name = "Healing Seed",
        stackable = false,
        duration = 6.0
    },
    [93804] = {
        name = "Healing Seed",
        stackable = false,
        duration = 6.0
    },
    [40060] = {
        name = "Healing Springs",
        stackable = false,
        duration = 10.0
    },
    [40061] = {
        name = "Healing Springs",
        stackable = false,
        duration = 10.0
    },
    [40062] = {
        name = "Healing Springs",
        stackable = false,
        duration = 10.0
    },
    [41257] = {
        name = "Healing Springs",
        stackable = false,
        duration = 10.0
    },
    [41261] = {
        name = "Healing Springs",
        stackable = false,
        duration = 10.0
    },
    [41265] = {
        name = "Healing Springs",
        stackable = false,
        duration = 10.0
    },
    [125851] = {
        name = "Healing Springs",
        stackable = false,
        duration = 10.0
    },
    [149062] = {
        name = "Healing Springs",
        stackable = false,
        duration = 10.0
    },
    [149154] = {
        name = "Healing Springs",
        stackable = false,
        duration = 10.0
    },
    [176926] = {
        name = "Healing Springs",
        stackable = false,
        duration = 10.0
    },
    [32710] = {
        name = "Hearth and Home",
        stackable = false,
        duration = 15.0
    },
    [32711] = {
        name = "Hearth and Home",
        stackable = false,
        duration = 15.0
    },
    [32712] = {
        name = "Hearth and Home",
        stackable = false,
        duration = 15.0
    },
    [33099] = {
        name = "Hearth and Home",
        stackable = false,
        duration = 15.0
    },
    [33804] = {
        name = "Hearth and Home",
        stackable = false,
        duration = 15.0
    },
    [33810] = {
        name = "Hearth and Home",
        stackable = false,
        duration = 15.0
    },
    [33816] = {
        name = "Hearth and Home",
        stackable = false,
        duration = 15.0
    },
    [29059] = {
        name = "Hearthfire",
        stackable = false,
        duration = 15.0
    },
    [33142] = {
        name = "Hearthfire",
        stackable = false,
        duration = 15.0
    },
    [33768] = {
        name = "Hearthfire",
        stackable = false,
        duration = 15.0
    },
    [33773] = {
        name = "Hearthfire",
        stackable = false,
        duration = 15.0
    },
    [33778] = {
        name = "Hearthfire",
        stackable = false,
        duration = 15.0
    },
    [61772] = {
        name = "Hearthfire",
        stackable = false,
        duration = 15.0
    },
    [237022] = {
        name = "HoT",
        stackable = false,
        duration = 10.0
    },
    [40058] = {
        name = "Illustrious Healing",
        stackable = false,
        duration = 12.0
    },
    [40059] = {
        name = "Illustrious Healing",
        stackable = false,
        duration = 12.0
    },
    [41251] = {
        name = "Illustrious Healing",
        stackable = false,
        duration = 13.0
    },
    [41253] = {
        name = "Illustrious Healing",
        stackable = false,
        duration = 14.0
    },
    [41255] = {
        name = "Illustrious Healing",
        stackable = false,
        duration = 15.0
    },
    [91343] = {
        name = "Illustrious Healing",
        stackable = false,
        duration = 12.0
    },
    [125848] = {
        name = "Illustrious Healing",
        stackable = false,
        duration = 12.0
    },
    [176925] = {
        name = "Illustrious Healing",
        stackable = false,
        duration = 12.0
    },
    [201488] = {
        name = "Knower's Eye",
        stackable = false,
        duration = 2.0
    },
    [83850] = {
        name = "Life Giver",
        stackable = false,
        duration = 5.0
    },
    [83851] = {
        name = "Life Giver",
        stackable = false,
        duration = 5.0
    },
    [83868] = {
        name = "Life Giver",
        stackable = false,
        duration = 5.0
    },
    [83869] = {
        name = "Life Giver",
        stackable = false,
        duration = 5.0
    },
    [83870] = {
        name = "Life Giver",
        stackable = false,
        duration = 5.0
    },
    [83872] = {
        name = "Life Giver",
        stackable = false,
        duration = 5.0
    },
    [83873] = {
        name = "Life Giver",
        stackable = false,
        duration = 5.0
    },
    [83874] = {
        name = "Life Giver",
        stackable = false,
        duration = 5.0
    },
    [83877] = {
        name = "Life Giver",
        stackable = false,
        duration = 5.0
    },
    [83878] = {
        name = "Life Giver",
        stackable = false,
        duration = 5.0
    },
    [83879] = {
        name = "Life Giver",
        stackable = false,
        duration = 5.0
    },
    [86428] = {
        name = "Life Giver",
        stackable = false,
        duration = 5.0
    },
    [86441] = {
        name = "Life Giver",
        stackable = false,
        duration = 5.0
    },
    [86454] = {
        name = "Life Giver",
        stackable = false,
        duration = 5.0
    },
    [85132] = {
        name = "Light's Champion",
        stackable = false,
        duration = 5.0
    },
    [85133] = {
        name = "Light's Champion",
        stackable = false,
        duration = 5.0
    },
    [86467] = {
        name = "Light's Champion",
        stackable = false,
        duration = 5.0
    },
    [86471] = {
        name = "Light's Champion",
        stackable = false,
        duration = 5.0
    },
    [86475] = {
        name = "Light's Champion",
        stackable = false,
        duration = 5.0
    },
    [85858] = {
        name = "Nature's Embrace",
        stackable = false,
        duration = 10.0
    },
    [87074] = {
        name = "Nature's Embrace",
        stackable = false,
        duration = 10.0
    },
    [88726] = {
        name = "Nature's Embrace",
        stackable = false,
        duration = 10.0
    },
    [88729] = {
        name = "Nature's Embrace",
        stackable = false,
        duration = 10.0
    },
    [91242] = {
        name = "Nature's Embrace",
        stackable = false,
        duration = 10.0
    },
    [93938] = {
        name = "Nature's Embrace",
        stackable = false,
        duration = 10.0
    },
    [93939] = {
        name = "Nature's Embrace",
        stackable = false,
        duration = 10.0
    },
    [93940] = {
        name = "Nature's Embrace",
        stackable = false,
        duration = 10.0
    },
    [169203] = {
        name = "Nature's Embrace",
        stackable = false,
        duration = 10.0
    },
    [83552] = {
        name = "Panacea",
        stackable = false,
        duration = 5.0
    },
    [83844] = {
        name = "Panacea",
        stackable = false,
        duration = 5.0
    },
    [86421] = {
        name = "Panacea",
        stackable = false,
        duration = 5.0
    },
    [86423] = {
        name = "Panacea",
        stackable = false,
        duration = 5.0
    },
    [86425] = {
        name = "Panacea",
        stackable = false,
        duration = 5.0
    },
    [186602] = {
        name = "Perennial Bloom",
        stackable = false,
        duration = 8.0
    },
    [187110] = {
        name = "Perennial Bloom",
        stackable = false,
        duration = 8.0
    },
    [196047] = {
        name = "Perennial Bloom",
        stackable = false,
        duration = 8.0
    },
    [86152] = {
        name = "Polar Wind",
        stackable = false,
        duration = 10.0
    },
    [86153] = {
        name = "Polar Wind",
        stackable = false,
        duration = 10.0
    },
    [86154] = {
        name = "Polar Wind",
        stackable = false,
        duration = 10.0
    },
    [86155] = {
        name = "Polar Wind",
        stackable = false,
        duration = 10.0
    },
    [88776] = {
        name = "Polar Wind",
        stackable = false,
        duration = 10.0
    },
    [90835] = {
        name = "Polar Wind",
        stackable = false,
        duration = 10.0
    },
    [176422] = {
        name = "Polar Wind",
        stackable = false,
        duration = 10.0
    },
    [22226] = {
        name = "Practiced Incantation",
        stackable = false,
        duration = 5.0
    },
    [22228] = {
        name = "Practiced Incantation",
        stackable = false,
        duration = 5.0
    },
    [26383] = {
        name = "Practiced Incantation",
        stackable = false,
        duration = 5.0
    },
    [27419] = {
        name = "Practiced Incantation",
        stackable = false,
        duration = 6.0
    },
    [27423] = {
        name = "Practiced Incantation",
        stackable = false,
        duration = 7.0
    },
    [27427] = {
        name = "Practiced Incantation",
        stackable = false,
        duration = 8.0
    },
    [46111] = {
        name = "Ravage Health",
        stackable = false,
        duration = 0.001
    },
    [246156] = {
        name = "Ravage Health",
        stackable = false,
        duration = 0.001
    },
    [246160] = {
        name = "Ravage Health",
        stackable = false,
        duration = 0.001
    },
    [186234] = {
        name = "Reconstructive Domain",
        stackable = false,
        duration = 20.0
    },
    [186242] = {
        name = "Reconstructive Domain",
        stackable = false,
        duration = 20.0
    },
    [186243] = {
        name = "Reconstructive Domain",
        stackable = false,
        duration = 20.0
    },
    [192788] = {
        name = "Reconstructive Domain",
        stackable = false,
        duration = 20.0
    },
    [20186234] = {
        name = "Reconstructive Domain",
        stackable = false,
        duration = 20.0
    },
    [30186234] = {
        name = "Reconstructive Domain",
        stackable = false,
        duration = 20.0
    },
    [40186234] = {
        name = "Reconstructive Domain",
        stackable = false,
        duration = 20.0
    },
    [22229] = {
        name = "Remembrance",
        stackable = false,
        duration = 4.0
    },
    [22231] = {
        name = "Remembrance",
        stackable = false,
        duration = 4.0
    },
    [26381] = {
        name = "Remembrance",
        stackable = false,
        duration = 4.0
    },
    [27401] = {
        name = "Remembrance",
        stackable = false,
        duration = 4.0
    },
    [27407] = {
        name = "Remembrance",
        stackable = false,
        duration = 4.0
    },
    [27413] = {
        name = "Remembrance",
        stackable = false,
        duration = 4.0
    },
    [54119] = {
        name = "Remembrance",
        stackable = false,
        duration = 4.0
    },
    [54121] = {
        name = "Remembrance",
        stackable = false,
        duration = 4.0
    },
    [61507] = {
        name = "Resolving Vigor",
        stackable = false,
        duration = 5.0
    },
    [61509] = {
        name = "Resolving Vigor",
        stackable = false,
        duration = 5.0
    },
    [63249] = {
        name = "Resolving Vigor",
        stackable = false,
        duration = 5.0
    },
    [63252] = {
        name = "Resolving Vigor",
        stackable = false,
        duration = 5.0
    },
    [63255] = {
        name = "Resolving Vigor",
        stackable = false,
        duration = 5.0
    },
    [193558] = {
        name = "Resonating Glyphic",
        stackable = false,
        duration = 15.0
    },
    [193559] = {
        name = "Resonating Glyphic",
        stackable = false,
        duration = 15.0
    },
    [193560] = {
        name = "Resonating Glyphic",
        stackable = false,
        duration = 15.0
    },
    [193769] = {
        name = "Resonating Glyphic",
        stackable = false,
        duration = 15.0
    },
    [194202] = {
        name = "Resonating Glyphic",
        stackable = false,
        duration = 15.0
    },
    [194205] = {
        name = "Resonating Glyphic",
        stackable = false,
        duration = 15.0
    },
    [194207] = {
        name = "Resonating Glyphic",
        stackable = false,
        duration = 15.0
    },
    [194208] = {
        name = "Resonating Glyphic",
        stackable = false,
        duration = 15.0
    },
    [20193558] = {
        name = "Resonating Glyphic",
        stackable = false,
        duration = 15.0
    },
    [30193558] = {
        name = "Resonating Glyphic",
        stackable = false,
        duration = 15.0
    },
    [40193558] = {
        name = "Resonating Glyphic",
        stackable = false,
        duration = 15.0
    },
    [155408] = {
        name = "Reverse Entropy",
        stackable = false,
        duration = 8.0
    },
    [40237] = {
        name = "Reviving Barrier",
        stackable = false,
        duration = 30.0
    },
    [46610] = {
        name = "Reviving Barrier",
        stackable = false,
        duration = 30.0
    },
    [46612] = {
        name = "Reviving Barrier",
        stackable = false,
        duration = 30.0
    },
    [46614] = {
        name = "Reviving Barrier",
        stackable = false,
        duration = 30.0
    },
    [40169] = {
        name = "Ring of Preservation",
        stackable = false,
        duration = 10.0
    },
    [40170] = {
        name = "Ring of Preservation",
        stackable = false,
        duration = 10.0
    },
    [42536] = {
        name = "Ring of Preservation",
        stackable = false,
        duration = 10.0
    },
    [42542] = {
        name = "Ring of Preservation",
        stackable = false,
        duration = 10.0
    },
    [42548] = {
        name = "Ring of Preservation",
        stackable = false,
        duration = 10.0
    },
    [52738] = {
        name = "Ring of Preservation",
        stackable = false,
        duration = 10.0
    },
    [52739] = {
        name = "Ring of Preservation",
        stackable = false,
        duration = 10.0
    },
    [52744] = {
        name = "Ring of Preservation",
        stackable = false,
        duration = 10.0
    },
    [52745] = {
        name = "Ring of Preservation",
        stackable = false,
        duration = 10.0
    },
    [52752] = {
        name = "Ring of Preservation",
        stackable = false,
        duration = 10.0
    },
    [53236] = {
        name = "Ring of Preservation",
        stackable = false,
        duration = 10.0
    },
    [80293] = {
        name = "Ring of Preservation",
        stackable = false,
        duration = 10.0
    },
    [83839] = {
        name = "Ring of Preservation",
        stackable = false,
        duration = 10.0
    },
    [22223] = {
        name = "Rite of Passage",
        stackable = false,
        duration = 4.0
    },
    [22225] = {
        name = "Rite of Passage",
        stackable = false,
        duration = 4.0
    },
    [27388] = {
        name = "Rite of Passage",
        stackable = false,
        duration = 4.0
    },
    [27392] = {
        name = "Rite of Passage",
        stackable = false,
        duration = 4.0
    },
    [27396] = {
        name = "Rite of Passage",
        stackable = false,
        duration = 4.0
    },
    [27809] = {
        name = "Rite of Passage",
        stackable = false,
        duration = 4.0
    },
    [44328] = {
        name = "Rite of Passage",
        stackable = false,
        duration = 4.0
    },
    [44329] = {
        name = "Rite of Passage",
        stackable = false,
        duration = 4.0
    },
    [44330] = {
        name = "Rite of Passage",
        stackable = false,
        duration = 4.0
    },
    [50998] = {
        name = "Rite of Passage",
        stackable = false,
        duration = 4.0
    },
    [66002] = {
        name = "Rite of Passage",
        stackable = false,
        duration = 4.0
    },
    [66003] = {
        name = "Rite of Passage",
        stackable = false,
        duration = 4.0
    },
    [66004] = {
        name = "Rite of Passage",
        stackable = false,
        duration = 4.0
    },
    [107680] = {
        name = "Rite of Passage",
        stackable = false,
        duration = 4.0
    },
    [107681] = {
        name = "Rite of Passage",
        stackable = false,
        duration = 4.0
    },
    [107682] = {
        name = "Rite of Passage",
        stackable = false,
        duration = 4.0
    },
    [108700] = {
        name = "Rite of Passage",
        stackable = false,
        duration = 4.0
    },
    [170546] = {
        name = "Rite of Passage",
        stackable = false,
        duration = 4.0
    },
    [196782] = {
        name = "Rite of Passage",
        stackable = false,
        duration = 4.0
    },
    [211124] = {
        name = "Rite of Passage",
        stackable = false,
        duration = 4.0
    },
    [211126] = {
        name = "Rite of Passage",
        stackable = false,
        duration = 4.0
    },
    [85532] = {
        name = "Secluded Grove",
        stackable = false,
        duration = 6.0
    },
    [85533] = {
        name = "Secluded Grove",
        stackable = false,
        duration = 6.0
    },
    [85534] = {
        name = "Secluded Grove",
        stackable = false,
        duration = 6.0
    },
    [93966] = {
        name = "Secluded Grove",
        stackable = false,
        duration = 6.0
    },
    [93967] = {
        name = "Secluded Grove",
        stackable = false,
        duration = 6.0
    },
    [93968] = {
        name = "Secluded Grove",
        stackable = false,
        duration = 6.0
    },
    [186605] = {
        name = "Snow Squall",
        stackable = false,
        duration = 8.0
    },
    [187125] = {
        name = "Snow Squall",
        stackable = false,
        duration = 8.0
    },
    [192819] = {
        name = "Snow Squall",
        stackable = false,
        duration = 8.0
    },
    [36485] = {
        name = "Veil of Blades",
        stackable = false,
        duration = 13.0
    },
    [36487] = {
        name = "Veil of Blades",
        stackable = false,
        duration = 13.0
    },
    [36488] = {
        name = "Veil of Blades",
        stackable = false,
        duration = 13.0
    },
    [36490] = {
        name = "Veil of Blades",
        stackable = false,
        duration = 13.0
    },
    [37701] = {
        name = "Veil of Blades",
        stackable = false,
        duration = 13.0
    },
    [37707] = {
        name = "Veil of Blades",
        stackable = false,
        duration = 13.0
    },
    [37713] = {
        name = "Veil of Blades",
        stackable = false,
        duration = 13.0
    },
    [79064] = {
        name = "Veil of Blades",
        stackable = false,
        duration = 13.0
    },
    [79065] = {
        name = "Veil of Blades",
        stackable = false,
        duration = 13.0
    },
    [79067] = {
        name = "Veil of Blades",
        stackable = false,
        duration = 13.0
    },
    [241517] = {
        name = "Vengeance Grand Healing",
        stackable = false,
        duration = 5.0
    },
    [241518] = {
        name = "Vengeance Grand Healing",
        stackable = false,
        duration = 5.0
    },
    [20241517] = {
        name = "Vengeance Grand Healing",
        stackable = false,
        duration = 5.0
    },
    [30241517] = {
        name = "Vengeance Grand Healing",
        stackable = false,
        duration = 5.0
    },
    [40241517] = {
        name = "Vengeance Grand Healing",
        stackable = false,
        duration = 5.0
    },
    [241236] = {
        name = "Vengeance Lacerate",
        stackable = false,
        duration = 8.0
    },
    [241237] = {
        name = "Vengeance Lacerate",
        stackable = false,
        duration = 8.0
    },
    [241238] = {
        name = "Vengeance Lacerate",
        stackable = false,
        duration = 8.0
    },
    [20241236] = {
        name = "Vengeance Lacerate",
        stackable = false,
        duration = 8.0
    },
    [30241236] = {
        name = "Vengeance Lacerate",
        stackable = false,
        duration = 8.0
    },
    [40241236] = {
        name = "Vengeance Lacerate",
        stackable = false,
        duration = 8.0
    },
    [238065] = {
        name = "Vengeance Living Vines",
        stackable = false,
        duration = 5.0
    },
    [20238065] = {
        name = "Vengeance Living Vines",
        stackable = false,
        duration = 5.0
    },
    [30238065] = {
        name = "Vengeance Living Vines",
        stackable = false,
        duration = 5.0
    },
    [40238065] = {
        name = "Vengeance Living Vines",
        stackable = false,
        duration = 5.0
    },
    [247126] = {
        name = "Vengeance Remedy Cascade",
        stackable = false,
        duration = 4.0
    },
    [237994] = {
        name = "Vengeance Rite of Passage",
        stackable = false,
        duration = 3.0
    },
    [237999] = {
        name = "Vengeance Rite of Passage",
        stackable = false,
        duration = 3.0
    },
    [20237994] = {
        name = "Vengeance Rite of Passage",
        stackable = false,
        duration = 3.0
    },
    [30237994] = {
        name = "Vengeance Rite of Passage",
        stackable = false,
        duration = 3.0
    },
    [40237994] = {
        name = "Vengeance Rite of Passage",
        stackable = false,
        duration = 3.0
    },
    [238074] = {
        name = "Vengeance Secluded Grove",
        stackable = false,
        duration = 6.0
    },
    [238075] = {
        name = "Vengeance Secluded Grove",
        stackable = false,
        duration = 6.0
    },
    [20238074] = {
        name = "Vengeance Secluded Grove",
        stackable = false,
        duration = 6.0
    },
    [30238074] = {
        name = "Vengeance Secluded Grove",
        stackable = false,
        duration = 6.0
    },
    [40238074] = {
        name = "Vengeance Secluded Grove",
        stackable = false,
        duration = 6.0
    },
    [237572] = {
        name = "Vengeance Spirit Mender",
        stackable = false,
        duration = 5.0
    },
    [238265] = {
        name = "Vengeance Spirit Mender",
        stackable = false,
        duration = 5.0
    },
    [20238265] = {
        name = "Vengeance Spirit Mender",
        stackable = false,
        duration = 5.0
    },
    [30238265] = {
        name = "Vengeance Spirit Mender",
        stackable = false,
        duration = 5.0
    },
    [40238265] = {
        name = "Vengeance Spirit Mender",
        stackable = false,
        duration = 5.0
    },
    [244472] = {
        name = "Vengeance Vigor",
        stackable = false,
        duration = 6.0
    },
    [244496] = {
        name = "Vengeance Vigor",
        stackable = false,
        duration = 6.0
    },
    [244512] = {
        name = "Vengeance Vigor",
        stackable = false,
        duration = 6.0
    },
    [20244496] = {
        name = "Vengeance Vigor",
        stackable = false,
        duration = 6.0
    },
    [30244496] = {
        name = "Vengeance Vigor",
        stackable = false,
        duration = 6.0
    },
    [40244496] = {
        name = "Vengeance Vigor",
        stackable = false,
        duration = 6.0
    },
    [237592] = {
        name = "Vengeance Vitalizing Glyphic",
        stackable = false,
        duration = 6.0
    },
    [238549] = {
        name = "Vengeance Vitalizing Glyphic",
        stackable = false,
        duration = 6.0
    },
    [238551] = {
        name = "Vengeance Vitalizing Glyphic",
        stackable = false,
        duration = 6.0
    },
    [20238549] = {
        name = "Vengeance Vitalizing Glyphic",
        stackable = false,
        duration = 6.0
    },
    [30238549] = {
        name = "Vengeance Vitalizing Glyphic",
        stackable = false,
        duration = 6.0
    },
    [40238549] = {
        name = "Vengeance Vitalizing Glyphic",
        stackable = false,
        duration = 6.0
    },
    [61503] = {
        name = "Vigor",
        stackable = true,
        duration = 10.0
    },
    [61504] = {
        name = "Vigor",
        stackable = true,
        duration = 10.0
    },
    [63236] = {
        name = "Vigor",
        stackable = true,
        duration = 10.0
    },
    [63238] = {
        name = "Vigor",
        stackable = true,
        duration = 10.0
    },
    [63240] = {
        name = "Vigor",
        stackable = true,
        duration = 10.0
    },
    [178455] = {
        name = "Vitalizing Glyphic",
        stackable = false,
        duration = 15.0
    },
    [183709] = {
        name = "Vitalizing Glyphic",
        stackable = false,
        duration = 15.0
    },
    [183711] = {
        name = "Vitalizing Glyphic",
        stackable = false,
        duration = 15.0
    },
    [183712] = {
        name = "Vitalizing Glyphic",
        stackable = false,
        duration = 15.0
    },
    [184079] = {
        name = "Vitalizing Glyphic",
        stackable = false,
        duration = 15.0
    },
    [184330] = {
        name = "Vitalizing Glyphic",
        stackable = false,
        duration = 15.0
    },
    [185757] = {
        name = "Vitalizing Glyphic",
        stackable = false,
        duration = 15.0
    },
    [190647] = {
        name = "Vitalizing Glyphic",
        stackable = false,
        duration = 15.0
    },
    [190648] = {
        name = "Vitalizing Glyphic",
        stackable = false,
        duration = 15.0
    },
    [193768] = {
        name = "Vitalizing Glyphic",
        stackable = false,
        duration = 15.0
    },
    [194203] = {
        name = "Vitalizing Glyphic",
        stackable = false,
        duration = 15.0
    },
    [20183709] = {
        name = "Vitalizing Glyphic",
        stackable = false,
        duration = 15.0
    },
    [30183709] = {
        name = "Vitalizing Glyphic",
        stackable = false,
        duration = 15.0
    },
    [40183709] = {
        name = "Vitalizing Glyphic",
        stackable = false,
        duration = 15.0
    },
    [193126] = {
        name = "Zone of Recuperation",
        stackable = false,
        duration = 8.0
    },
    [193127] = {
        name = "Zone of Recuperation",
        stackable = false,
        duration = 8.0
    },
    [193128] = {
        name = "Zone of Recuperation",
        stackable = false,
        duration = 8.0
    },
    [193129] = {
        name = "Zone of Recuperation",
        stackable = false,
        duration = 8.0
    }
}

--[[ runtime state --------------------------------------------------------------------------------------------------]]

---Active HoTs currently on player
---Structure: {[key] = {abilityId, sourceName, startTime, endTime, stackCount, isStackable}}
---Key format: "sourceName_abilityName" to handle per-caster stacking + rank upgrades
---All ranks of the same ability from the same caster map to the same key (refreshes, not stacks)
BlockPooky.activeHoTs = {}

---Effect-based HoT Database (for scribing skills)
---Structure: {[uid] = {name, stackable, duration}}
---Key is the uid parameter from EVENT_EFFECT_CHANGED, not effect ID
---These HoTs are tracked via EVENT_EFFECT_CHANGED instead of combat events
BlockPooky.effectTrackedHoTs = {
    -- Scribing skill effects (matched by uid from EVENT_EFFECT_CHANGED)
    -- The uid is the unique effect instance ID
    [217510] = {
        name = "genesender Bruch",
        stackable = false,
        duration = 10.0
    },
    [216941] = {
        name = "genesende Seele",
        stackable = false,
        duration = 10.0
    },
    [217652] = {
        name = "genesender Ausweichplan",
        stackable = false,
        duration = 12.0
    },
    [214987] = {
        name = "genesendes Katapultieren",
        stackable = false,
        duration = 10.0
    },
    [217192] = {
        name = "genesendes Zerschmettern",
        stackable = false,
        duration = 10.0
    },
    --[227066] = {
    --    name = "genesendes Banner",5
    --    stackable = false,
    --    duration = ??? todo
    --},
}


--[[ UI initialization -------------------------------------------------------------------------------------------]]

function BlockPooky.InitHoTBarUI()
    -- Create the main bar control
    if not BlockPooky.hotBar then
        BlockPooky.hotBar = CreateControl(BlockPooky.name .. "HoTBar", GuiRoot, CT_TOPLEVELCONTROL)
        if not BlockPooky.hotBar then
            return
        end
        BlockPooky.hotBar:SetDimensions(200, 40)
        BlockPooky.hotBar:SetAnchor(CENTER, GuiRoot, CENTER, 0, -20)
        BlockPooky.hotBar:SetHidden(true)
        BlockPooky.hotBar:SetMovable(true)
        BlockPooky.hotBar:SetMouseEnabled(true)

        -- Event for position saving when moved
        BlockPooky.hotBar:SetHandler("OnMoveStop", function()
            BlockPooky.SaveHoTBarPosition()
        end)
    end

    -- Create the label
    if not BlockPooky.hotLabel then
        BlockPooky.hotLabel = CreateControl(BlockPooky.name .. "HoTLabel", BlockPooky.hotBar, CT_LABEL)
        if not BlockPooky.hotLabel then
            return
        end
        BlockPooky.hotLabel:SetFont("ZoFontWinH4")
        BlockPooky.hotLabel:SetColor(0, 1, 0, 1)  -- Green by default
        BlockPooky.hotLabel:SetText("")
        BlockPooky.hotLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        BlockPooky.hotLabel:SetAnchor(TOP, BlockPooky.hotBar, TOP, 0, 0)
        BlockPooky.hotLabel:SetHidden(false)
    end

    -- Create the status bar
    if not BlockPooky.hotStatusBar then
        BlockPooky.hotStatusBar = CreateControl(BlockPooky.name .. "HoTStatus", BlockPooky.hotBar, CT_STATUSBAR)
        if not BlockPooky.hotStatusBar then
            return
        end
        BlockPooky.hotStatusBar:SetDimensions(200, 20)
        BlockPooky.hotStatusBar:SetAnchor(BOTTOM, BlockPooky.hotBar, BOTTOM, 0, 0)
        BlockPooky.hotStatusBar:SetMinMax(0, 1)  -- Will be updated dynamically
        BlockPooky.hotStatusBar:SetValue(0)
        BlockPooky.hotStatusBar:SetColor(0, 1, 0, 1)  -- Green by default
        BlockPooky.hotStatusBar:SetHidden(false)
    end

    BlockPooky.LoadHoTBarPosition()

    -- NOTE: The HoT display is updated via the main tick (UpdateHoTDisplay) and on
    -- HoT events, NOT via a control OnUpdate handler. Control OnUpdate only fires
    -- while the control is visible, which made the bar unreliable in repositioning mode.
end

function BlockPooky.SaveHoTBarPosition()
    if BlockPooky.config and BlockPooky.hotBar then
        local left, top = BlockPooky.hotBar:GetLeft(), BlockPooky.hotBar:GetTop()
        BlockPooky.config.hotBarPosition = {left = left, top = top}
    end
end

function BlockPooky.LoadHoTBarPosition()
    if not BlockPooky.hotBar then
        return
    end
    
    if BlockPooky.hotBar:GetAnchor() ~= nil then
        BlockPooky.hotBar:ClearAnchors()
    end
    
    -- Load saved position if available, otherwise use default
    if BlockPooky.config and BlockPooky.config.hotBarPosition then
        BlockPooky.hotBar:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BlockPooky.config.hotBarPosition.left, BlockPooky.config.hotBarPosition.top)
    else
        -- Default position
        BlockPooky.hotBar:SetAnchor(CENTER, GuiRoot, CENTER, 0, -20)
    end
end

function BlockPooky.ResetHoTBarPosition()
    if BlockPooky.hotBar then
        if BlockPooky.hotBar:GetAnchor() ~= nil then
            BlockPooky.hotBar:ClearAnchors()
        end
        BlockPooky.hotBar:SetAnchor(CENTER, GuiRoot, CENTER, 0, -20)
        BlockPooky.SaveHoTBarPosition()
    end
end

--[[ HoT tracking and counting --------------------------------------------------------------------------------------]]

---Check if an ability ID is a known HoT
---@param abilityId number the ability ID to check
---@return boolean true if ability is in HoT database
function BlockPooky.IsKnownHoT(abilityId)
    return BlockPooky.hotDatabase[abilityId] ~= nil
end

---Create unique key for tracking HoT by source and ability
---Uses ability NAME not ID to handle rank upgrades properly:
---  - All ranks of same ability from same caster = same key (refreshes)
---  - Different casters = different keys (stacks)
---@param sourceName string the player who cast the HoT
---@param abilityId number the HoT ability ID
---@return string unique tracking key (sourceName_abilityName)
function BlockPooky.GetHoTTrackingKey(sourceName, abilityId)
    local hotInfo = BlockPooky.hotDatabase[abilityId]
    if hotInfo then
        return BlockPooky.CleanupName(sourceName) .. "_" .. hotInfo.name
    end
    -- Fallback if ability not in database
    return BlockPooky.CleanupName(sourceName) .. "_" .. abilityId
end

---Track a new HoT cast on player
---@param sourceName string player who cast the HoT
---@param abilityId number the HoT ability ID
---@param startTime number game time when cast began
---@param duration number HoT duration in seconds
function BlockPooky.TrackHoT(sourceName, abilityId, startTime, duration)
    local key = BlockPooky.GetHoTTrackingKey(sourceName, abilityId)
    local hotInfo = BlockPooky.hotDatabase[abilityId]
    
    if hotInfo then
        local newEndTime = startTime + duration
        local existing = BlockPooky.activeHoTs[key]
        
        -- If the same HoT already exists, use whichever endTime is later (refresh behavior)
        local finalEndTime = newEndTime
        if existing and existing.endTime > newEndTime then
            finalEndTime = existing.endTime
        end
        
        BlockPooky.activeHoTs[key] = {
            abilityId = abilityId,
            sourceName = BlockPooky.CleanupName(sourceName),
            startTime = startTime,
            endTime = finalEndTime,
            duration = duration,
            stackCount = 1,
            isStackable = hotInfo.stackable
        }
    end
end

---Remove expired HoTs from tracking
function BlockPooky.CleanExpiredHoTs()
    local now = GetGameTimeSeconds()
    for key, hotData in pairs(BlockPooky.activeHoTs) do
        if now >= hotData.endTime then
            BlockPooky.activeHoTs[key] = nil
        end
    end
end

---Get total HoT count on player (accounts for stacking rules)
---@return number total HoT count toward 8-cap
function BlockPooky.GetTotalHoTCount()
    BlockPooky.CleanExpiredHoTs()
    
    local total = 0
    for key, hotData in pairs(BlockPooky.activeHoTs or {}) do
        if hotData.isStackable then
            -- Stackable HoTs: count all stacks
            total = total + hotData.stackCount
        else
            -- Non-stackable HoTs: count as 1 regardless of caster
            total = total + 1
        end
    end
    
    return total
end

---Get detailed HoT breakdown (total, stackable count, non-stackable count)
---@return number total, number stackableCount, number nonStackableCount
function BlockPooky.GetHoTBreakdown()
    BlockPooky.CleanExpiredHoTs()
    
    local total = 0
    local stackableCount = 0
    local nonStackableCount = 0
    
    for _, hotData in pairs(BlockPooky.activeHoTs) do
        if hotData.isStackable then
            stackableCount = stackableCount + hotData.stackCount
            total = total + hotData.stackCount
        else
            nonStackableCount = nonStackableCount + 1
            total = total + 1
        end
    end
    
    return total, stackableCount, nonStackableCount
end

--[[ display update ------------------------------------------------------------------------------------------------]]

---Update HoT bar display based on current count
function BlockPooky.UpdateHoTDisplay()
    if not BlockPooky.hotBar then
        return
    end

    -- While the UI is in repositioning mode (lockedUI = true), keep the bar
    -- visible regardless of HoT count or feature toggle so the player can move it.
    if BlockPooky.config and BlockPooky.config.lockedUI then
        BlockPooky.hotBar:SetHidden(false)
        -- Render a visible label so the bar is easy to find and move in repositioning mode
        if BlockPooky.hotLabel then
            BlockPooky.hotLabel:SetText("HoT")
        end
        return
    end

    if not BlockPooky.config or not BlockPooky.config.showHoTCounter then 
        if BlockPooky.hotBar then BlockPooky.hotBar:SetHidden(true) end
        return 
    end
    
    local total = BlockPooky.GetTotalHoTCount()
    
    if total == 0 then
        BlockPooky.hotBar:SetHidden(true)
        return
    end
    
    BlockPooky.hotBar:SetHidden(false)
    
    -- Determine color based on count
    local color
    if total >= 8 then
        color = {1, 0, 0, 1}  -- Red: at cap
    elseif total >= 6 then
        color = {1, 1, 0, 1}  -- Yellow: warning
    else
        color = {0, 1, 0, 1}  -- Green: safe
    end
    
    -- Update label and status bar
    if not BlockPooky.hotLabel then return end
    if not BlockPooky.hotStatusBar then return end
    
    BlockPooky.hotLabel:SetColor(unpack(color))
    BlockPooky.hotLabel:SetText(total .. "/8")
    
    -- Dynamically set max to accommodate values above 8
    local maxValue = math.max(8, total)
    BlockPooky.hotStatusBar:SetMinMax(0, maxValue)
    BlockPooky.hotStatusBar:SetColor(unpack(color))
    BlockPooky.hotStatusBar:SetValue(total)
end

--[[ event handling ------------------------------------------------------------------------------------------------]]

---EVENT_COMBAT_EVENT handler for HoT skill detection
---Detects when healing skills are cast on the player
---@param eventCode any
---@param result any
---@param isError any
---@param abilityName any
---@param abilityGraphic any
---@param abilityActionSlotType any
---@param sourceName any
---@param sourceType any
---@param targetName any
---@param targetType any
---@param hitValue any
---@param powerType any
---@param damageType any
---@param combat_log any
---@param sourceUnitId any
---@param targetUnitId any
---@param abilityId any
function BlockPooky.OnHoTSkillCast(
    eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType,
    sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType,
    combat_log, sourceUnitId, targetUnitId, abilityId)
    
    -- Only process if we are the target (healing applied TO us, not FROM us)
    if targetType ~= COMBAT_UNIT_TYPE_PLAYER then return end
    
    -- Only process if it's a skill in our HoT database
    if not BlockPooky.IsKnownHoT(abilityId) then return end

    -- Track the HoT
    local hotInfo = BlockPooky.hotDatabase[abilityId]
    BlockPooky.TrackHoT(sourceName, abilityId, GetGameTimeSeconds(), hotInfo.duration)
    
    -- Update display
    BlockPooky.UpdateHoTDisplay()
end

---EVENT_EFFECT_CHANGED handler for effect-based HoT detection (e.g., scribing skills)
---Detects when effect-based HoTs are gained/removed
---@param eventCode any
---@param unitTag any - unit tag of who the effect is on
---@param effectSlot any - which effect slot
---@param effectName any - name of the effect
---@param beginTime any - when effect began
---@param endTime any - when effect ends
---@param unitName any - name of the unit the effect is on
---@param iconPath any
---@param buffType any
---@param effectType any
---@param statusEffectType any
---@param uid any - unique effect ID
---@param isStackable any - can it stack
---@param stackCount any - how many stacks
function BlockPooky.OnHoTEffectChanged(
    eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount,
    iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    
    -- Only process if on player
    if unitTag ~= "player" then return end
    
    -- Check if this abilityId is a known effect-based HoT
    local effectInfo = BlockPooky.effectTrackedHoTs[abilityId]
    
    if not effectInfo then
        -- Not a tracked effect, skip
        return
    end
    
    -- Only track when effect is gained, not faded
    if changeType ~= EFFECT_RESULT_GAINED then
        return
    end
    
    local now = GetGameTimeSeconds()
    local timeRemaining = endTime - now
    
    -- Only track effects that have time remaining (not expired)
    if now >= endTime then
        return
    end
    
    -- Effect is active and in our tracked list, add it
    local key = "Effect_" .. abilityId
    local existing = BlockPooky.activeHoTs[key]
    
    -- If the same effect already exists, use whichever endTime is later
    local finalEndTime = endTime
    if existing and existing.endTime > endTime then
        finalEndTime = existing.endTime
    end
    
    BlockPooky.activeHoTs[key] = {
        abilityId = abilityId,
        sourceName = "Effect",
        startTime = beginTime,
        endTime = finalEndTime,
        duration = finalEndTime - beginTime,
        stackCount = stackCount or 1,
        isStackable = effectInfo.stackable
    }
    
    -- Update display
    BlockPooky.UpdateHoTDisplay()
end
function BlockPooky.InitHoTTracker()
    d("[HoT Tracker Init] showHoTCounter = " .. tostring(BlockPooky.config.showHoTCounter))
    if BlockPooky.config.showHoTCounter then
        -- Combat event tracking (skill-based HoTs)
        d("[HoT Tracker] Registering EVENT_COMBAT_EVENT")
        EVENT_MANAGER:RegisterForEvent(BlockPooky.name .. "HoTTracker", EVENT_COMBAT_EVENT,
                                       function(...) BlockPooky.OnHoTSkillCast(...) end)
        EVENT_MANAGER:AddFilterForEvent(BlockPooky.name .. "HoTTracker", EVENT_COMBAT_EVENT,
                                        REGISTER_FILTER_UNIT_TAG, "player")  -- WE are the target
        EVENT_MANAGER:AddFilterForEvent(BlockPooky.name .. "HoTTracker", EVENT_COMBAT_EVENT,
                                        REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)  -- HoT applied
        
        -- Effect tracking (scribing skill HoTs) - no filter to test if event fires at all
        EVENT_MANAGER:RegisterForEvent(BlockPooky.name .. "HoTEffectTracker", EVENT_EFFECT_CHANGED,
                                       function(...) BlockPooky.OnHoTEffectChanged(...) end)
        EVENT_MANAGER:AddFilterForEvent(BlockPooky.name .. "HoTEffectTracker", EVENT_EFFECT_CHANGED,
                                        REGISTER_FILTER_UNIT_TAG, "player")
    end
end

---Update HoT event registration based on config
function BlockPooky.HoTEventRegisterUpdate()
    if BlockPooky.config.showHoTCounter then
        -- Combat event tracking
        EVENT_MANAGER:RegisterForEvent(BlockPooky.name .. "HoTTracker", EVENT_COMBAT_EVENT,
                                       function(...) BlockPooky.OnHoTSkillCast(...) end)
        EVENT_MANAGER:AddFilterForEvent(BlockPooky.name .. "HoTTracker", EVENT_COMBAT_EVENT,
                                        REGISTER_FILTER_UNIT_TAG, "player")
        EVENT_MANAGER:AddFilterForEvent(BlockPooky.name .. "HoTTracker", EVENT_COMBAT_EVENT, 
                                        REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
        
        -- Effect tracking
        EVENT_MANAGER:RegisterForEvent(BlockPooky.name .. "HoTEffectTracker", EVENT_EFFECT_CHANGED,
                                       function(...) BlockPooky.OnHoTEffectChanged(...) end)
        EVENT_MANAGER:AddFilterForEvent(BlockPooky.name .. "HoTEffectTracker", EVENT_EFFECT_CHANGED,
                                        REGISTER_FILTER_UNIT_TAG, "player")
    else
        EVENT_MANAGER:UnregisterForEvent(BlockPooky.name .. "HoTTracker")
        EVENT_MANAGER:UnregisterForEvent(BlockPooky.name .. "HoTEffectTracker")
        BlockPooky.hotBar:SetHidden(true)
    end
end

--[[ debug/testing functions ---------------------------------------------------------------------------------------]]

---Test function to manually add HoT to tracking (for testing)
---@param abilityId number ability ID to test
---@param duration number duration in seconds
function BlockPooky.TestAddHoT(abilityId, duration)
    if BlockPooky.IsKnownHoT(abilityId) then
        BlockPooky.TrackHoT("TestCaster", abilityId, GetGameTimeSeconds(), duration)
        BlockPooky.UpdateHoTDisplay()
        BlockPooky_chat:Print("Test HoT added. Total count: " .. BlockPooky.GetTotalHoTCount())
    else
        BlockPooky_chat:Print("Ability ID " .. abilityId .. " not in HoT database")
    end
end

---Test function to manually add effect-based HoT (for testing scribing skills)
---@param effectId number the effect ID to test
---@param effectName string the effect name
---@param duration number duration in seconds
function BlockPooky.TestAddEffect(effectId, effectName, duration)
    local now = GetGameTimeSeconds()
    BlockPooky.OnHoTEffectChanged(
        EVENT_EFFECT_CHANGED,
        "player",  -- unitTag
        1,  -- effectSlot
        effectName,  -- effectName
        now,  -- beginTime
        now + duration,  -- endTime
        "TestPlayer",  -- unitName
        "",  -- iconPath
        0,  -- buffType
        0,  -- effectType
        0,  -- statusEffectType
        effectId,  -- uid
        false,  -- isStackable
        1  -- stackCount
    )
    BlockPooky_chat:Print("Test effect added: " .. effectName .. " (" .. duration .. "s)")
end

---Print active HoT list to chat (for debugging)
function BlockPooky.PrintActiveHoTs()
    local total = BlockPooky.GetTotalHoTCount()
    BlockPooky_chat:Print("=== Active HoTs (" .. total .. "/8) ===")
    
    if total == 0 then
        BlockPooky_chat:Print("No active HoTs")
        return
    end
    
    BlockPooky.CleanExpiredHoTs()
    for key, hotData in pairs(BlockPooky.activeHoTs) do
        local remaining = math.floor((hotData.endTime - GetGameTimeSeconds()) * 10) / 10
        local stacks = hotData.isStackable and (" x" .. hotData.stackCount) or ""
        BlockPooky_chat:Print(hotData.sourceName .. ": " .. hotData.name .. stacks .. " (" .. remaining .. "s)")
    end
end
