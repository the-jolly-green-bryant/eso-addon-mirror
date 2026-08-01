--[[
	Addon: Taos Group Tools
	Author: TProg Taonnor
	Created by @Taonnor
]]--

--[[
	===============================
    Contains all tracked food buffs
    ===============================
]]--
FOOD_BUFFS = {
    -- Standard Food
    [61259] = {}, -- Increase Max Health (Meat Dishes)
    [61260] = {}, -- Increase Max Magicka (Fruit Dishes)
    [61261] = {}, -- Increase Max Stamina (Vegetable Dishes)
    [61257] = {}, -- Increase Max Health & Magicka (Savouries)
    [61255] = {}, -- Increase Max Health & Stamina (Ragout)
    [61294] = {}, -- Increase Max Magicka & Stamina (Entremet)
    [61218] = {}, -- Increase All Primary Stats (Gourmet)

    -- Standard Drink
    [61322] = {}, -- Health Recovery (Alcoholic Drinks)
    [61325] = {}, -- Magicka Recovery (Tea)
    [61328] = {}, -- Stamina Recovery (Tonics)
    [61335] = {}, -- Health & Magicka Recovery (Liqueurs)
    [61340] = {}, -- Health & Stamina Recovery (Tinctures)
    [61345] = {}, -- Magicka & Stamina Recovery (Cordial Teas)
    [61350] = {}, -- All Primary Stat Recovery (Distillates)

    -- Single Stat Food
    [66551] = {}, -- Increase Max Health
    [66568] = {}, -- Increase Max Magicka
    [66576] = {}, -- Increase Max Stamina

    -- Single Stat Drink
    [66586] = {}, -- Health Recovery
    [66590] = {}, -- Magicka Recovery
    [66594] = {}, -- Stamina Recovery

    -- Orsinium
    [72816] = {}, -- Increase Max Health & Magicka (Orzorga's Red Frothgar)
    [72819] = {}, -- Increase Max Health & Stamina (Orzorga's Tripe Trifle Pocket)
    [72822] = {}, -- Increase Max Health & Health R (Orzorga's Blood Price Pie)
    [72824] = {}, -- Increase Max Health & Health, (Orzorga's Smoked Bear Haunch)

    -- Festivals (Witchmother & New Life
    [84678] = {}, -- Increase Max Magicka (Old Aldmeri Orphan Gruel, Sweet Sanguine Apples)
    [84681] = {}, -- Snack Skewer (Crisp and Crunchy Pumpkin Snack Skewer)
    [84709] = {}, -- Increase Magicka (Crunchy Spider Skewer)
    [84725] = {}, -- The Brains! (Frosted Brains)
    [84720] = {}, -- Eye Scream (Ghastly Eye Bowl)
    [84700] = {}, -- "Eyeballs" (Bowl of "Peeled Eyeballs")
    [84731] = {}, -- Witchmother's Potent Brew (Witchmother's Potent Brew)
    [84704] = {}, -- Party Punch (Witchmother's Party Punch)
    [84735] = {}, -- Bloody Bloody Mara (Double Bloody Mara)
    [86789] = {}, -- Increase Max Health (Alcaire Festival Sword-Pie)
    [86787] = {}, -- Increase Max Stamina (Rajhin's Sugar Claws)
    [86749] = {}, -- Mud Ball (Jagga-Drenched "Mud Ball")
    [86673] = {}, -- Lava Foot Soup & Saltrice (Lava Foot Soup-and-Saltrice)
    [86791] = {}, -- Increase Stamina Recovery (Snow Bear Glow-Wine)
    [86746] = {}, -- Betnikh Spiked Ale (Betnikh Twice-Spiked Ale)
    [86677] = {}, -- Warning Fire (Bergama Warning Fire)
    [86559] = {}, -- Fish Eye (Hissmir Fish-Eye Rye)

    -- Cyrodilic Food & Drink
    [72961] = {}, -- Max Stamina and Magicka (Cyrodilic Field Bar)
    [72956] = {}, -- Max Health and Stamina (Cyrodilic Field Tack)
    [72959] = {}, -- Max Health and Magicka (Cyrodilic Field Treat)
    [72965] = {}, -- Health and Stamina Recovery (Cyrodilic Field Brew)
    [72968] = {}, -- Health and Magicka Recovery (Cyrodilic Field Tea)
    [72971] = {}, -- Magicka and Stamina Recovery (Cyrodilic Field Tonic)

    -- Crown Food & Drink
    [68411] = {}, -- Increase All Primary Stats (Crown Fortifying Meal)
    [68416] = {}, -- All Primary Stat Recovery (Crown Refreshing Drink)

    -- Others
    [100498] = {}, -- Clockwork citrone filet (Max-Life/Magicka, Life-Reg/Magicka-Reg)
    [89957] =  {}, -- Camoran-Thron (Max-Life/Stamina, Stamina-Reg)
}

--[[
	==========================
    Contains all tracked buffs
    ==========================
]]--
-- Unique Buffs for specific trackers
EARTHGORE_ICON_ID = 97857  -- Earthgore
DETONATON_ICON_ID = 61500  -- Detonation
SPEEDBUFF_ICON_ID = 101169 -- Speedbuff

TRACKED_BUFFS = { -- IconName: To identify if from multiple sources // IconId: To save for user settings
    [1] =  { ["IconName"] = "esoui/art/icons/ability_buff_major_berserk.dds",    ["IconId"] = 36973 },
    [2] =  { ["IconName"] = "esoui/art/icons/ability_buff_major_brutality.dds",  ["IconId"] = 23673 },
    [3] =  { ["IconName"] = "esoui/art/icons/ability_buff_major_evasion.dds",    ["IconId"] = 63015 },
    [4] =  { ["IconName"] = "esoui/art/icons/ability_buff_major_expedition.dds", ["IconId"] = 23216 },
    [5] =  { ["IconName"] = "esoui/art/icons/ability_buff_major_force.dds",      ["IconId"] = 40225 },
    [6] =  { ["IconName"] = "esoui/art/icons/ability_buff_major_fortitude.dds",  ["IconId"] = 45222 },
    [7] =  { ["IconName"] = "esoui/art/icons/ability_buff_major_heroism.dds",    ["IconId"] = 65133 },
    [8] =  { ["IconName"] = "esoui/art/icons/ability_buff_major_intellect.dds",  ["IconId"] = 45224 },
    [9] =  { ["IconName"] = "esoui/art/icons/ability_buff_major_mending.dds",    ["IconId"] = 55033 },
    [10] = { ["IconName"] = "esoui/art/icons/ability_buff_major_prophecy.dds",   ["IconId"] = 62747 },
    [11] = { ["IconName"] = "esoui/art/icons/ability_buff_major_protection.dds", ["IconId"] = 22233 },
    [12] = { ["IconName"] = "esoui/art/icons/ability_buff_major_resolve.dds",    ["IconId"] = 22236 },
    [13] = { ["IconName"] = "esoui/art/icons/ability_buff_major_savagery.dds",   ["IconId"] = 26795 },
    [14] = { ["IconName"] = "esoui/art/icons/ability_buff_major_sorcery.dds",    ["IconId"] = 62062 },
    [15] = { ["IconName"] = "esoui/art/icons/ability_buff_major_vitality.dds",   ["IconId"] = 42197 },
    [16] = { ["IconName"] = "esoui/art/icons/ability_buff_major_ward.dds",       ["IconId"] = 40443 },
    [17] = { ["IconName"] = "esoui/art/icons/ability_mage_045.dds",              ["IconId"] = 66902 }, -- Spellpower Cure / Olorime
    [18] = { ["IconName"] = "esoui/art/icons/ability_buff_minor_berserk.dds",    ["IconId"] = 62636 },
    [19] = { ["IconName"] = "esoui/art/icons/ability_buff_minor_brutality.dds",  ["IconId"] = 61798 },
    [20] = { ["IconName"] = "esoui/art/icons/ability_buff_minor_evasion.dds",    ["IconId"] = 87861 },
    [21] = { ["IconName"] = "esoui/art/icons/ability_buff_minor_expedition.dds", ["IconId"] = 40219 },
    [22] = { ["IconName"] = "esoui/art/icons/ability_buff_minor_force.dds",      ["IconId"] = 68595 },
    [23] = { ["IconName"] = "esoui/art/icons/ability_buff_minor_fortitude.dds",  ["IconId"] = 26213 },
    [24] = { ["IconName"] = "esoui/art/icons/ability_buff_minor_heroism.dds",    ["IconId"] = 38746 },
    [25] = { ["IconName"] = "esoui/art/icons/ability_buff_minor_intellect.dds",  ["IconId"] = 26216 },
    [26] = { ["IconName"] = "esoui/art/icons/ability_buff_minor_mending.dds",    ["IconId"] = 29096 },
    [27] = { ["IconName"] = "esoui/art/icons/ability_buff_minor_prophecy.dds",   ["IconId"] = 62319 },
    [28] = { ["IconName"] = "esoui/art/icons/ability_buff_minor_protection.dds", ["IconId"] = 35739 },
    [29] = { ["IconName"] = "esoui/art/icons/ability_buff_minor_resolve.dds",    ["IconId"] = 31818 },
    [30] = { ["IconName"] = "esoui/art/icons/ability_buff_minor_savagery.dds",   ["IconId"] = 61882 },
    [31] = { ["IconName"] = "esoui/art/icons/ability_buff_minor_sorcery.dds",    ["IconId"] = 62799 },
    [32] = { ["IconName"] = "esoui/art/icons/ability_buff_minor_vitality.dds",   ["IconId"] = 37027 },
    [33] = { ["IconName"] = "esoui/art/icons/ability_buff_minor_ward.dds",       ["IconId"] = 61862 },
    [34] = { ["IconName"] = "esoui/art/icons/achievement_031.dds",               ["IconId"] = 40222 },
    [35] = { ["IconName"] = "",                                                  ["IconId"] = 76936 }, -- Transmutation
    [36] = { ["IconName"] = "",                                                  ["IconId"] = 65706 }, -- Meritorus
}