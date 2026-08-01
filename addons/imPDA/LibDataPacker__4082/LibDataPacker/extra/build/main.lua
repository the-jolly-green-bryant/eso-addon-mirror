local Log = LibDataPacker_Logger()

local CLASSES_LOOKUP_TABLE = {
    1,
    2,
    3,
    4,
    5,
    6,
    117,
}

local RACES_LOOKUP_TABLE = {
    1,  -- Breton
    2,  -- Redguard
    3,  -- Orc
    4,  -- Dark Elf
    5,  -- Nord
    6,  -- Argonian
    7,  -- High Elf
    8,  -- Wood Elf
    9,  -- Khajiit
    10, -- Imperial
    -- 29,  -- Xivilai, if Xivilai become a thing
}

local BOONS_ENUM = {
    [13940] = 1,    -- Boon: The Warrior
    [13943] = 2,    -- Boon: The Mage
    [13974] = 3,    -- Boon: The Serpent
    [13975] = 4,    -- Boon: The Thief
    [13976] = 5,    -- Boon: The Lady
    [13977] = 6,    -- Boon: The Steed
    [13978] = 7,    -- Boon: The Lord
    [13979] = 8,    -- Boon: The Apprentice
    [13980] = 9,    -- Boon: The Ritual
    [13981] = 10,   -- Boon: The Lover
    [13982] = 11,   -- Boon: The Atronach
    [13984] = 12,   -- Boon: The Shadow
    [13985] = 13,   -- Boon: The Tower
    [0]     = 14,   -- no Boon
}

local WW_OR_VAMPIRE_ENUM = {
    [135397] = 1,   -- Vampirism: Stage 1
    [135399] = 2,   -- Vampirism: Stage 2
    [135400] = 3,   -- Vampirism: Stage 3
    [135402] = 4,   -- Vampirism: Stage 4
    [35658]  = 5,   -- Lycantropy
    [0]      = 6,   -- not WW/Vamp
}

local CHAMPION_SLOTTABLE_SKILLS_LOOKUP_TABLE = {
    0,  -- no CP star slotted
    2,   3,   4,   5,   8,   9,   12,  13,  23,  24,  25,  26,  27,  28,  29,  30,
    31,  32,  33,  34,  35,  46,  47,  48,  49,  51,  52,  54,  55,  56,  57,  59,
    60,  61,  62,  63,  64,  65,  66,  76,  78,  80,  82,  84,  88,  89,  92,  133,
    134, 136, 159, 160, 161, 162, 163, 259, 260, 261, 262, 263, 264, 265, 266, 267,
    268, 270, 271, 272, 273, 274, 275, 276, 277,
}

local ATTRIBUTES_LOOKUP_TABLE = {
    ATTRIBUTE_HEALTH,  -- 1
    ATTRIBUTE_MAGICKA,  -- 2
    ATTRIBUTE_STAMINA,  -- 3
}

local GEAR_SLOTS = {
    EQUIP_SLOT_HEAD,        -- 0  
    EQUIP_SLOT_CHEST,       -- 2
    EQUIP_SLOT_SHOULDERS,   -- 3
    EQUIP_SLOT_HAND,        -- 16
    EQUIP_SLOT_WAIST,       -- 6
    EQUIP_SLOT_LEGS,        -- 8
    EQUIP_SLOT_FEET,        -- 9

    EQUIP_SLOT_NECK,        -- 1
    EQUIP_SLOT_RING1,       -- 11
    EQUIP_SLOT_RING2,       -- 12

    EQUIP_SLOT_MAIN_HAND,   -- 4
    EQUIP_SLOT_OFF_HAND,    -- 5

    EQUIP_SLOT_BACKUP_MAIN, -- 20
    EQUIP_SLOT_BACKUP_OFF,  -- 21
}

local FOOD_LOOKUP_TABLE = {
    0,

    17407, 17577, 17581, 17608, 17614,

    61218, 61221, 61246, 61252, 61253, 61255, 61257, 61259, 61260, 61261, 61264, 61265, 61276, 61277, 61278, 61287, 61288, 61290, 61291,
    61293, 61294, 61296, 61297, 61298, 61301, 61302, 61303, 61304, 61305, 61307, 61308, 61309, 61310, 61313, 61314, 61315, 61316, 61322,
    61325, 61328, 61335, 61340, 61345, 61350, 61357, 61358, 61359, 61361, 61365, 61367, 61368, 65523, 65528, 65534, 65535, 65536, 66124,
    66125, 66127, 66128, 66129, 66130, 66131, 66132, 66136, 66137, 66140, 66141, 66550, 66551, 66565, 66566, 66568, 66569, 66570, 66572,
    66576, 66577, 66578, 66580, 66584, 66585, 66586, 66589, 66590, 66593, 66594, 66597, 68411, 68412, 68413, 68414, 68416,

    72816, 72819, 72822, 72824, 72952, 72956, 72957, 72958, 72959, 72960, 72961, 72962, 72963, 72964, 72965, 72968, 72971, 72974, 72975,
    73539, 73540, 73551, 73553,

    84678, 84679, 84681, 84682, 84683, 84700, 84701, 84702, 84704, 84705, 84706, 84707, 84709, 84710, 84711, 84720, 84722, 84723, 84725,
    84728, 84729, 84731, 84732, 84733, 84734, 84735, 84736, 84737, 85484, 85485, 85486, 85487, 85497, 86558, 86559, 86560, 86669, 86673,
    86674, 86676, 86677, 86678, 86745, 86746, 86747, 86748, 86749, 86750, 86785, 86786, 86787, 86788, 86789, 86790, 86791, 89919, 89921,
    89939, 89953, 89954, 89955, 89956, 89957, 89958, 89959, 89971, 89972, 89973,

    92432, 92433, 92434, 92435, 92436, 92437, 92473, 92474, 92475, 92476, 92477, 92478,

    100483, 100485, 100487, 100488, 100498, 100502, 107748, 107749, 107789, 107793, 107794,

    127530, 127531, 127537, 127571, 127572, 127578, 127595, 127596, 127602, 127619, 127736,

    140793, 148632, 148633,

    245302,
}

local FOOD_ENUM = {}
do
    for i = 1, #FOOD_LOOKUP_TABLE do
        FOOD_ENUM[FOOD_LOOKUP_TABLE[i]] = i
    end
end

local SKILL_LINES_LOOKUP_TABLE = {
    22,  -- Aedric Spear
    27,  -- Dawn's Wrath
    28,  -- Restoring Light

    35,  -- Ardent Flame
    36,  -- Draconic Power
    37,  -- Earthen Heart

    38,  -- Assassination
    39,  -- Shadow
    40,  -- Siphoning

    41,  -- Dark Magic
    42,  -- Daedric Summoning
    43,  -- Storm Calling

    127,  -- Animal Companions
    128,  -- Green Balance
    129,  -- Winter's Embrace

    131,  -- Grave Lord
    132,  -- Bone Tyrant
    133,  -- Living Death

    218,  -- Herald of the Tome
    219,  -- Soldier of Apocrypha
    220,  -- Curative Runeforms

    297,  -- Vengeance Ardent Flame
    298,  -- Vengeance Draconic Power
    299,  -- Vengeance Earthen Heart
    300,  -- Vengeance Assassination
    301,  -- Vengeance Shadow
    302,  -- Vengeance Siphoning
    303,  -- Vengeance Aedric Spear
    304,  -- Vengeance Dawn's Wrath
    305,  -- Vengeance Restoring Light
    306,  -- Vengeance Daedric Summoning
    307,  -- Vengeance Dark Magic
    308,  -- Vengeance Storm Calling
    309,  -- Vengeance Animal Companions
    310,  -- Vengeance Green Balance
    311,  -- Vengeance Winter's Embrace
    312,  -- Vengeance Grave Lord
    313,  -- Vengeance Bone Tyrant
    314,  -- Vengeance Living Death
    315,  -- Vengeance Curative Runeforms
    316,  -- Vengeance Soldier of Apocrypha
    317,  -- Vengeance Herald of the Tome
}

-- 351-357 - Class Mastery
-- 351 - Dragonknight
-- 352 - Arcanist
-- 353 - Necromancer
-- 354 - Warden
-- 355 - Templar
-- 356 - Nightblade
-- 357 - Sorcerer


-- ----------------------------------------------------------------------------

local function GetAlliance()    return GetUnitAlliance('player')        end
local function GetAvARank()     return GetUnitAvARank('player')         end
local function GetRace()        return GetUnitRaceId('player')          end
local function GetClass()       return GetUnitClassId('player')         end
local function GetLevel()       return GetUnitLevel('player')           end
local function GetCP()          return GetUnitChampionPoints('player')  end

local function GetSkills()
    local skills = {}

    for category = HOTBAR_CATEGORY_PRIMARY, HOTBAR_CATEGORY_BACKUP do
        skills[category] = {}
        for slot = 3, 8 do
            local slotBoundId = GetSlotBoundId(slot, category)
            if GetSlotType(slot, category) == ACTION_TYPE_CRAFTED_ABILITY then
                local script1, script2, script3 = GetCraftedAbilityActiveScriptIds(slotBoundId)
                skills[category][slot] = {
                    slotBoundId,
                    script1,
                    script2,
                    script3,
                }
            else
                skills[category][slot] = slotBoundId  -- or 0 if no skill in slot
            end
        end
    end

    return skills
end

local function GetBoon(index)
    local numBuffs = GetNumBuffs('player')
    if numBuffs == 0 then return end

    local boons = {}

    for i = 1, numBuffs do
        local _, _, _, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo('player', i)
        if BOONS_ENUM[abilityId] then
            boons[#boons+1] = abilityId
        end
    end

    table.sort(boons)

    return boons[index]
end

local function GetWWorVampireBuff()
    local numBuffs = GetNumBuffs('player')
    if numBuffs == 0 then return end

    for i = 1, numBuffs do
        local _, _, _, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo('player', i)
        if WW_OR_VAMPIRE_ENUM[abilityId] then
            return abilityId
        end
    end
end

local function GetAttributes()
    local attributes = {}

    for i = 1, #ATTRIBUTES_LOOKUP_TABLE do
        attributes[i] = GetAttributeSpentPoints(ATTRIBUTES_LOOKUP_TABLE[i])
    end

    return attributes
end

local STATS_LOOKUP_TABLE = {
    STAT_HEALTH_MAX,    -- 7
    STAT_MAGICKA_MAX,   -- 4
    STAT_STAMINA_MAX,   -- 29

    STAT_HEALTH_REGEN_COMBAT,   -- 8
    STAT_MAGICKA_REGEN_COMBAT,  -- 5
    STAT_STAMINA_REGEN_COMBAT,  -- 30

    STAT_POWER,         -- 35
    STAT_SPELL_POWER,   -- 25

    STAT_CRITICAL_STRIKE,   -- 16
    STAT_SPELL_CRITICAL,    -- 23

    STAT_PHYSICAL_PENETRATION,  -- 33
    STAT_SPELL_PENETRATION,     -- 34

    STAT_PHYSICAL_RESIST,   -- 22
    STAT_SPELL_RESIST,      -- 13
}

local function GetStats()
    local stats = {}

    local stat
    for i = 1, #STATS_LOOKUP_TABLE do
        stat = STATS_LOOKUP_TABLE[i]
        stats[STATS_LOOKUP_TABLE[i]] = GetPlayerStat(stat)
    end

    return stats
end

local function GetItemLinkEnchantId(itemLink)
    return tonumber(itemLink:match('|H[^:]+:item:[^:]+:[^:]+:[^:]+:([^:]+):'))
end

local function GetGearSlot(slot)
    local itemLink = GetItemLink(BAG_WORN, slot)
    if not itemLink or itemLink == '' then return {0, 0, 0, 0} end

    Log(itemLink)

    local itemId = GetItemLinkItemId(itemLink)
    local itemQuality = GetItemLinkDisplayQuality(itemLink)
    local itemTrait = GetItemLinkTraitInfo(itemLink)
    local itemEnchantId = GetItemLinkEnchantId(itemLink)  -- GetItemLinkAppliedEnchantId(itemLink)
    -- local itemEnchantQuality = GetEnchantQuality(itemLink)

    Log(GetItemLinkFinalEnchantId(itemLink))

    return {itemId, itemQuality, itemTrait, itemEnchantId}
end

local function GetGear()
    local gear = {}

    local slot
    for i = 1, #GEAR_SLOTS do
        slot = GEAR_SLOTS[i]
        gear[slot] = GetGearSlot(slot)
    end

    return gear
end

local function GetConstellations()
    local constellations = {}

    for i = 1, 12 do
        constellations[i] = GetSlotBoundId(i, HOTBAR_CATEGORY_CHAMPION)
    end

    return constellations
end

local function GetFood()
    local numBuffs = GetNumBuffs('player')
    if numBuffs == 0 then return end

    for i = 1, numBuffs do
        local _, _, _, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo('player', i)
        if FOOD_ENUM[abilityId] then
            return abilityId
        end
    end
end

-- TODO: find boons, food, etc. in one loop

local function GetClassSkillLines()
    local skillLines = {}

    for i = 1, GetNumSkillLines(SKILL_TYPE_CLASS) do
        local currentRank, isAdvised, isActive, isDiscovered, isAccountSkill, isInTraining, isClassMastery = GetSkillLineDynamicInfo(SKILL_TYPE_CLASS, i)
        local skillLineId = GetSkillLineId(SKILL_TYPE_CLASS, i)

        if isActive and not isClassMastery then
            table.insert(skillLines, skillLineId)
        end
    end

    return skillLines
end

local function GetClassMastery()
    local classMastery = {}

    for skillLineIndex = GetNumSkillLines(SKILL_TYPE_CLASS), 1, -1 do
        local currentRank, isAdvised, isActive, isDiscovered, isAccountSkill, isInTraining, isClassMastery = GetSkillLineDynamicInfo(SKILL_TYPE_CLASS, skillLineIndex)

        -- local skillLineId = GetSkillLineId(SKILL_TYPE_CLASS, i)
        -- local skillLineName = GetSkillLineNameById(skillLineId)
        if isClassMastery then
            for skillIndex = 1, GetNumSkillAbilities(SKILL_TYPE_CLASS, skillLineIndex) do
                local name, texture, earnedRank, passive, ultimate, purchased, progressionIndex, rank = GetSkillAbilityInfo(SKILL_TYPE_CLASS, skillLineIndex, skillIndex)
                if purchased then
                    local abilityId = GetSkillAbilityId(SKILL_TYPE_CLASS, skillLineIndex, skillIndex)
                    classMastery[#classMastery+1] = abilityId
                end
            end
        end
    end

    return classMastery
end

--[[
local function _printSkillLinesDebug()
    for i = 1, GetNumSkillLines(SKILL_TYPE_CLASS) do
        local currentRank, isAdvised, isActive, isDiscovered, isAccountSkill, isInTraining, isClassMastery = GetSkillLineDynamicInfo(SKILL_TYPE_CLASS, i)
        local skillLineId = GetSkillLineId(SKILL_TYPE_CLASS, i)
        local skillLineName = GetSkillLineNameById(skillLineId)

        df('%d %s (%d) - active: %s, isClassMastery: %s', currentRank, skillLineName, skillLineId, tostring(isActive), tostring(isClassMastery))
    end
end
IMP_GLOBAL_PRINT_SKILL_LINES_DEBUG = _printSkillLinesDebug
--]]

-- ---------------------------------------------------------------------------

local LDP = LibDataPacker

local Field = LDP.Field
local BaseField = LDP.BaseField

local IGNORE_NAMES = true

-- ----------------------------------------------------------------------------

--- @class Skill : Field
--- @field __index Skill
local Skill = setmetatable({}, { __index = BaseField })
Skill.__index = Skill

--- Creates a new Skill field
--- @param name string|nil The field name
--- @param ignoreNames boolean|nil
--- @return Skill @The new Skills field
function Skill.New(name, ignoreNames)
    --- @class (partial) Skill
    local o = setmetatable(BaseField.New(name, 0), Skill)

    o.isCrafted = Field.Bool(nil)

    -- U45
    -- craftedAbilityId - 12 max
    -- scriptId - 70 max

    local craftedAbility = Field.Table(nil, {
        Field.Number('craftedSkillId', 6),
        Field.Number('script1', 7),
        Field.Number('script2', 7),
        Field.Number('script3', 7),
    }, ignoreNames)
    o.ignoreNames = ignoreNames

    o.ability = Field.Number(nil, 20)
    o.craftedAbility = craftedAbility

    return o
end

--- Handles a boolean value
--- @param data any The data to handle
function Skill:Serialize(data, binaryBuffer)
    if type(data) == 'table' then
        self.isCrafted:Serialize(true, binaryBuffer)
        self.craftedAbility:Serialize(data, binaryBuffer)
    else
        self.isCrafted:Serialize(false, binaryBuffer)
        self.ability:Serialize(data, binaryBuffer)
    end
end

function Skill:Unserialize(dataBuffer)
    local isCrafted = self.isCrafted:Unserialize(dataBuffer)

    if isCrafted then
        return self.craftedAbility:Unserialize(dataBuffer)
    else
        return self.ability:Unserialize(dataBuffer)
    end
end

function Skill:GetMaxBitLength()
    return self.isCrafted:GetMaxBitLength() + self.craftedAbility:GetMaxBitLength()
end

-- ----------------------------------------------------------------------------

local Skills = Field.Array('skills', 12, Skill.New(nil, true))

local MAX_SKILLS = 12
local MAX_CRAFTED_SKILLS = 10

function Skills:GetMaxBitLength()
    -- all crafted but ultimates
    return (1 + 27) * MAX_CRAFTED_SKILLS + 20 * (MAX_SKILLS - MAX_CRAFTED_SKILLS)
    -- return (1 + 27) * MAX_SKILLS
end

local Stats = Field.Table('stats', {
    Field.Number(STAT_HEALTH_MAX,   16),
    Field.Number(STAT_MAGICKA_MAX,  16),
    Field.Number(STAT_STAMINA_MAX,  16),

    Field.Number(STAT_HEALTH_REGEN_COMBAT,  14),
    Field.Number(STAT_MAGICKA_REGEN_COMBAT, 14),
    Field.Number(STAT_STAMINA_REGEN_COMBAT, 14),

    Field.Number(STAT_POWER,        14),
    Field.Number(STAT_SPELL_POWER,  14),

    Field.Number(STAT_CRITICAL_STRIKE,  15),
    Field.Number(STAT_SPELL_CRITICAL,   15),

    Field.Number(STAT_PHYSICAL_PENETRATION, 16),
    Field.Number(STAT_SPELL_PENETRATION,    16),

    Field.Number(STAT_PHYSICAL_RESIST,  17),
    Field.Number(STAT_SPELL_RESIST,     17),
})

local Item = Field.Table('item', {
    Field.Number('id',              20),
    Field.Number('quality',         3),
    Field.Number('trait',           6),
    Field.Number('enchantmentId',   20),
}, IGNORE_NAMES)

local Build = Field.Table(nil, {
    Field.Number('alliance',        2),
    Field.Number('avaRank',         6),

    Field.Enum('race', RACES_LOOKUP_TABLE, true),
    Field.Enum('class', CLASSES_LOOKUP_TABLE, true),

    -- Field.Number('skillPoints',     10),

    Field.Number('level', 6),
    Field.Number('CP', 12),

    Skills,

    Field.Enum('boon1', BOONS_ENUM),
    Field.Enum('boon2', BOONS_ENUM),

    Field.Enum('WWorVampire', WW_OR_VAMPIRE_ENUM),

    Field.Array('attributes',   3,  Field.Number(nil, 7)),

    Stats,

    Field.Array('gear', 14, Item),

    Field.Array('constellations', 12, Field.Enum(nil, CHAMPION_SLOTTABLE_SKILLS_LOOKUP_TABLE, true)),

    Field.Enum('food', FOOD_ENUM, nil, 10),

    Field.Array('skillLines', 3, Field.Enum(nil, SKILL_LINES_LOOKUP_TABLE, true)),

    Field.Array('classMastery', 2, Field.Optional(Skill.New(nil, true)))
}, IGNORE_NAMES)

local SHORT_BUILD_SCHEME = Build:ShallowCopy({
    'race',
    'class',
    'skills',
    'boon1',
    'boon2',
    'WWorVampire',
    'gear',
    'constellations',
    'food',
    'skillLines',
    'classMastery',
})
GLOBAL_SHORT_BUILD_SCHEME = SHORT_BUILD_SCHEME

-- ----------------------------------------------------------------------------

local function convertToArray(table, lookupTable)
    local array = {}

    for i = 1, #lookupTable do
        array[i] = table[lookupTable[i]] or error(('Element #%d was not found'):format(lookupTable[i]))
    end

    return array
end

local function convertToIndexedTable(array, lookupTable)
    local indexedTable = {}

    for i = 1, #array do
        indexedTable[lookupTable[i]] = array[i]
    end

    return indexedTable
end

local function flattenSkills(skillsTable)
    local flatArray = {}

    for hotbar = HOTBAR_CATEGORY_PRIMARY, HOTBAR_CATEGORY_BACKUP do
        for index = 3, 8 do
            flatArray[#flatArray+1] = skillsTable[hotbar][index]
        end
    end

    return flatArray
end

local function unflattenSkills(flatArray)
    local skillsTable = {
        [HOTBAR_CATEGORY_PRIMARY] = {},
        [HOTBAR_CATEGORY_BACKUP] = {},
    }

    for i, skill in ipairs(flatArray) do
        skillsTable[math.floor(i / 7)][(i - 1) % 6 + 3] = skill
    end

    return skillsTable
end

-- ----------------------------------------------------------------------------

local ALLIANCE          = 1
local AVA_RANK          = 2
local RACE              = 3
local CLASS             = 4
local LEVEL             = 5
local CP                = 6
local SKILLS            = 7
local FIRST_BOON        = 8
local SECOND_BOON       = 9
local WW_VAMP_BUFF      = 10
local ATTRIBUTES        = 11
local STATS             = 12
local GEAR              = 13
local CONSTELLATIONS    = 14
local FOOD              = 15
local CLASS_SKILL_LINES = 16
local CLASS_MASTERY     = 17

local BUILD = {
    [ALLIANCE]          = GetAlliance,
    [AVA_RANK]          = GetAvARank,
    [RACE]              = GetRace,
    [CLASS]             = GetClass,
    [LEVEL]             = GetLevel,
    [CP]                = GetCP,
    [SKILLS]            = GetSkills,
    [FIRST_BOON]        = function() return GetBoon(1) end,
    [SECOND_BOON]       = function() return GetBoon(2) end,
    [WW_VAMP_BUFF]      = GetWWorVampireBuff,
    [ATTRIBUTES]        = GetAttributes,
    [STATS]             = GetStats,
    [GEAR]              = GetGear,
    [CONSTELLATIONS]    = GetConstellations,
    [FOOD]              = GetFood,
    [CLASS_SKILL_LINES] = GetClassSkillLines,
    [CLASS_MASTERY]     = GetClassMastery,
}

local SHORT_BUILD = {}
do
    local parts = {
        --[[ 1]]RACE,
        --[[ 2]]CLASS,
        --[[ 3]]SKILLS,
        --[[ 4]]FIRST_BOON,
        --[[ 5]]SECOND_BOON,
        --[[ 6]]WW_VAMP_BUFF,
        --[[ 7]]GEAR,
        --[[ 8]]CONSTELLATIONS,
        --[[ 9]]FOOD,
        --[[10]]CLASS_SKILL_LINES,
        --[[11]]CLASS_MASTERY,
    }
    for _, part in pairs(parts) do
        SHORT_BUILD[part] = BUILD[part]
    end
end

local function GetSlotType(build, slot, hotbar)
    if hotbar ~= HOTBAR_CATEGORY_PRIMARY and hotbar ~= HOTBAR_CATEGORY_BACKUP then
        error(('Wrong hotbar category: "%s"'):format(GetString('SI_HOTBARCATEGORY', hotbar)))
    end

    return type(build[SKILLS][hotbar][slot]) == 'table' and ACTION_TYPE_CRAFTED_ABILITY or ACTION_TYPE_ABILITY
end

local function GetSlotBoundId(build, slot, hotbar)
    if hotbar == HOTBAR_CATEGORY_PRIMARY or hotbar == HOTBAR_CATEGORY_BACKUP then
        local skill = build[SKILLS][hotbar][slot]
        if type(skill) == 'table' then
            return skill[1]
        else
            return skill
        end
    elseif hotbar == HOTBAR_CATEGORY_CHAMPION then
        return build[CONSTELLATIONS][slot]
    else
        error(('Wrong hotbar category: "%s"'):format(GetString('SI_HOTBARCATEGORY', hotbar)))
    end
end

local function GetSlotScriptIds(build, slot, hotbar)
    if GetSlotType(build, slot, hotbar) ~= ACTION_TYPE_CRAFTED_ABILITY then return end

    local skill = build[SKILLS][hotbar][slot]

    return skill[2], skill[3], skill[4]
end

local function GetPlayerStat(build, stat)
    return build[STATS][stat]
end

local mt = {
    __index = {
        GetSlotType = GetSlotType,
        GetSlotBoundId = GetSlotBoundId,
        GetPlayerStat = GetPlayerStat,
        GetSlotScriptIds = GetSlotScriptIds,
    },
}

-- ----------------------------------------------------------------------------

local BUILD_SCHEME = Build
local BUILD_BASE = LDP.Base.Base64LinkSafe

local function GetLocalPlayerBuild()
    local build = {}

    for i = 1, #BUILD do
        build[i] = BUILD[i]()
    end

    setmetatable(build, mt)

    return build
end

local function PackBuild(build)
    build[SKILLS] = flattenSkills(build[SKILLS])
    build[FIRST_BOON] = build[FIRST_BOON] or 0
    build[SECOND_BOON] = build[SECOND_BOON] or 0
    build[WW_VAMP_BUFF] = build[WW_VAMP_BUFF] or 0
    build[GEAR] = convertToArray(build[GEAR], GEAR_SLOTS)
    build[FOOD] = build[FOOD] or 0

    return LDP.Pack(build, BUILD_SCHEME, BUILD_BASE)
end

local function GetPackedLocalPlayerBuild()
    return PackBuild(GetLocalPlayerBuild())
end

local function UnpackBuild(packedBuild)
    local build = LDP.Unpack(packedBuild, BUILD_SCHEME, BUILD_BASE)

    build[SKILLS] = unflattenSkills(build[SKILLS])
    build[FIRST_BOON] = build[FIRST_BOON] ~= 0 and build[FIRST_BOON] or nil
    build[SECOND_BOON] = build[SECOND_BOON] ~= 0 and build[SECOND_BOON] or nil
    build[WW_VAMP_BUFF] = build[WW_VAMP_BUFF] ~= 0 and build[WW_VAMP_BUFF] or nil
    build[GEAR] = convertToIndexedTable(build[GEAR], GEAR_SLOTS)
    build[FOOD] = build[FOOD] ~= 0 and build[FOOD] or nil

    setmetatable(build, mt)

    return build
end

-- ----------------------------------------------------------------------------

local function GetLocalPlayerShortBuild()
    local build = {}

    for index, factoryFunction in pairs(SHORT_BUILD) do
        build[index] = factoryFunction()
    end

    setmetatable(build, mt)

    return build
end

local indexing = {}
do
    for k, v in pairs(SHORT_BUILD) do
        indexing[#indexing+1] = k
    end
    table.sort(indexing)
end

local function reIndexShortBuild(tbl)
    local newTbl = {}

    for i = 1, #indexing do
        newTbl[i] = tbl[indexing[i]]
    end

    return newTbl
end

local function reIndexShortBuildBack(tbl)
    local newTbl = {}

    for i = 1, #indexing do
        newTbl[indexing[i]] = tbl[i]
    end

    return newTbl
end

local function PackShortBuild(shortBuild)
    shortBuild[SKILLS] = flattenSkills(shortBuild[SKILLS])
    shortBuild[FIRST_BOON] = shortBuild[FIRST_BOON] or 0
    shortBuild[SECOND_BOON] = shortBuild[SECOND_BOON] or 0
    shortBuild[WW_VAMP_BUFF] = shortBuild[WW_VAMP_BUFF] or 0
    shortBuild[GEAR] = convertToArray(shortBuild[GEAR], GEAR_SLOTS)
    shortBuild[FOOD] = shortBuild[FOOD] or 0

    shortBuild = reIndexShortBuild(shortBuild)

    return LDP.Pack(shortBuild, SHORT_BUILD_SCHEME, BUILD_BASE)
end

local function GetPackedLocalPlayerShortBuild()
    return PackShortBuild(GetLocalPlayerShortBuild())
end

local function UnpackShortBuild(packedShortBuild)
    local shortBuild = LDP.Unpack(packedShortBuild, SHORT_BUILD_SCHEME, BUILD_BASE)

    shortBuild = reIndexShortBuildBack(shortBuild)

    shortBuild[SKILLS] = unflattenSkills(shortBuild[SKILLS])
    shortBuild[FIRST_BOON] = shortBuild[FIRST_BOON] ~= 0 and shortBuild[FIRST_BOON] or nil
    shortBuild[SECOND_BOON] = shortBuild[SECOND_BOON] ~= 0 and shortBuild[SECOND_BOON] or nil
    shortBuild[WW_VAMP_BUFF] = shortBuild[WW_VAMP_BUFF] ~= 0 and shortBuild[WW_VAMP_BUFF] or nil
    shortBuild[GEAR] = convertToIndexedTable(shortBuild[GEAR], GEAR_SLOTS)
    shortBuild[FOOD] = shortBuild[FOOD] ~= 0 and shortBuild[FOOD] or nil

    setmetatable(shortBuild, mt)

    return shortBuild
end

-- ----------------------------------------------------------------------------

LDP.Extra = LDP.Extra or {}
LDP.Extra.Build = {
    ALLIANCE            = ALLIANCE,
    AVA_RANK            = AVA_RANK,
    RACE                = RACE,
    CLASS               = CLASS,
    LEVEL               = LEVEL,
    CP                  = CP,
    SKILLS              = SKILLS,
    FIRST_BOON          = FIRST_BOON,
    SECOND_BOON         = SECOND_BOON,
    WW_VAMP_BUFF        = WW_VAMP_BUFF,
    ATTRIBUTES          = ATTRIBUTES,
    STATS               = STATS,
    GEAR                = GEAR,
    CONSTELLATIONS      = CONSTELLATIONS,
    FOOD                = FOOD,
    CLASS_SKILL_LINES   = CLASS_SKILL_LINES,
    CLASS_MASTERY       = CLASS_MASTERY,

    GEAR_SLOTS          = GEAR_SLOTS,

    GetLocalPlayerBuild = GetLocalPlayerBuild,
    GetPackedLocalPlayerBuild = GetPackedLocalPlayerBuild,
    PackBuild = PackBuild,
    UnpackBuild = UnpackBuild,
    -- GetSlotType = GetSlotType,

    MaxLength = LDP.Diagnostics.MaxLength(BUILD_SCHEME, BUILD_BASE),

    GetLocalPlayerShortBuild = GetLocalPlayerShortBuild,
    GetPackedLocalPlayerShortBuild = GetPackedLocalPlayerShortBuild,

    PackShortBuild = PackShortBuild,
    UnpackShortBuild = UnpackShortBuild,
}

--[[ little self test
local Log = LibDataPacker_Logger()
if LIB_FOOD_DRINK_BUFF then
    local enum = {}

    for i, buffId in ipairs(FOOD_LOOKUP_TABLE) do
        enum[buffId] = i
    end

    local function exists(element)
        if enum[element] then return true end
    end

    for drinkId, _ in pairs(LIB_FOOD_DRINK_BUFF.DRINK_BUFF_ABILITIES) do
        if not exists(drinkId) then Log('Extra id (drink) found in LibFoodDrinkBuff: %d', drinkId) end
    end

    for foodId, _ in pairs(LIB_FOOD_DRINK_BUFF.FOOD_BUFF_ABILITIES) do
        if not exists(foodId) then Log('Extra id (food) found in LibFoodDrinkBuff: %d', foodId) end
    end
end

do
    Log('Max length of Build string:', LDP.Diagnostics.MaxLength(Build, LDP.Base.Base64LinkSafe))
end
--]]