BSCAllianceRanking = BSCAllianceRanking or {}
local BSCARI = BSCAllianceRanking

-- PvP Styles view
-- UI detection is intentionally disabled. Fill BSCARI.PVP_STYLE_GROUPS manually with
-- collectible ids. Use BSCAllianceRanking:DumpPvPStyleCandidateIds() or /bscarstyleids
-- to print candidate ids grouped by Cyrodiil, Imperial City, Battleground and Veterancy.

local TAB_CYRODIIL = "cyrodiil"
local TAB_IMPERIAL_CITY = "imperialCity"
local TAB_BATTLEGROUND = "battleground"
local TAB_VETERANCY = "veterancy"

local TAB_ORDER =
{
    TAB_CYRODIIL,
    TAB_IMPERIAL_CITY,
    TAB_BATTLEGROUND,
    TAB_VETERANCY,
}

local TAB_LABELS =
{
    [TAB_CYRODIIL] = "Cyrodiil",
    [TAB_IMPERIAL_CITY] = "Imperial City",
    [TAB_BATTLEGROUND] = "Battleground",
    [TAB_VETERANCY] = "Veterancy",
}

-- Fill this table manually after using BSCAllianceRanking:DumpPvPStyleCandidateIds().
-- Format:
-- BSCAllianceRanking.PVP_STYLE_GROUPS =
-- {
--     cyrodiil =
--     {
--         { name = "Example Style", ids = { 12345, 12346, 12347 } },
--     },
--     imperialCity = {},
--     battleground = {},
--     veterancy = {},
-- }
BSCARI.PVP_STYLE_GROUPS =
{
    cyrodiil = -- Cyrodiil
    {
        { name = "Akaviri Heavy Armor", ids = { 2955, 2956, 2957, 2958, 2959, 2960, 2961 } }, -- category=heavyArmor itemStyleId=0
        { name = "Akaviri Medium Armor", ids = { 2940, 2941, 2942, 2943, 2944, 2945, 2946 } }, -- category=mediumArmor itemStyleId=0
        { name = "Akaviri Light Armor", ids = { 2947, 2948, 2949, 2950, 2951, 2952, 2953, 2954 } }, -- category=lightArmor itemStyleId=0
        { name = "Akaviri Weapons 1", ids = { 2887, 2877, 2903, 4870, 2883, 2891, 2880, 2894, 2896, 2900 } }, -- category=weapons itemStyleId=0
        { name = "Akaviri Weapons 2", ids = { 2886, 2878, 2902, 4869, 2884, 2889, 2881, 2893, 2895, 2899 } }, -- category=weapons itemStyleId=0
        { name = "Akaviri Weapons 3", ids = { 2888, 2879, 2901, 4868, 2885, 2890, 2882, 2892, 2897, 2898 } }, -- category=weapons itemStyleId=0
        { name = "Gravegrasp Signature", ids = { 11371, 11372, 11373, 11374, 11375, 11376, 11377 } }, -- category=signature itemStyleId=0
        { name = "Knight of the Circle Weapons", ids = { 7380, 7381, 7382, 7383, 7384 } }, -- category=weapons itemStyleId=0
        { name = "Knight of the Circle Signature", ids = { 7338, 7339, 7340, 7341, 7342, 7343 } }, -- category=signature itemStyleId=0
    },
    imperialCity = -- Imperial City
    {
        { name = "Aldmeri Heavy Armor", ids = { 3608, 3609, 3610, 3611, 3612, 3613, 3614 } }, -- category=heavyArmor itemStyleId=0
        { name = "Aldmeri Medium Armor", ids = { 3647, 3648, 3649, 3650, 3651, 3652, 3653 } }, -- category=mediumArmor itemStyleId=0
        { name = "Aldmeri Light Armor", ids = { 3632, 3633, 3634, 3635, 3636, 3637, 3638, 3639 } }, -- category=lightArmor itemStyleId=0
        { name = "Aldmeri Weapons", ids = { 3615, 3616, 3617, 3618, 3619, 3620, 3621, 3622, 3623, 4889 } }, -- category=weapons itemStyleId=0
        { name = "Daggerfall Heavy Armor", ids = { 3664, 3665, 3666, 3667, 3668, 3669, 3670 } }, -- category=heavyArmor itemStyleId=0
        { name = "Daggerfall Medium Armor", ids = { 3640, 3641, 3642, 3643, 3644, 3645, 3646 } }, -- category=mediumArmor itemStyleId=0
        { name = "Daggerfall Light Armor", ids = { 3624, 3625, 3626, 3627, 3628, 3629, 3630, 3631 } }, -- category=lightArmor itemStyleId=0
        { name = "Daggerfall Weapons", ids = { 3671, 3672, 3673, 3674, 3675, 3676, 3677, 3678, 3679, 4890 } }, -- category=weapons itemStyleId=0
        { name = "Ebonheart Heavy Armor", ids = { 3569, 3570, 3571, 3572, 3573, 3574, 3575 } }, -- category=heavyArmor itemStyleId=0
        { name = "Ebonheart Medium Armor", ids = { 3584, 3585, 3586, 3587, 3588, 3589, 3590 } }, -- category=mediumArmor itemStyleId=0
        { name = "Ebonheart Light Armor", ids = { 3576, 3577, 3578, 3579, 3580, 3581, 3582, 3583 } }, -- category=lightArmor itemStyleId=0
        { name = "Ebonheart Weapons", ids = { 3599, 3600, 3601, 3602, 3603, 3604, 3605, 3606, 3607, 4888 } }, -- category=weapons itemStyleId=0
        { name = "Gravegrasp Signature", ids = { 11371, 11372, 11373, 11374, 11375, 11376, 11377 } }, -- category=signature itemStyleId=0
        { name = "Nibenese Court Wizard Signature", ids = { 9280, 9281, 9282, 9283, 9284, 9285, 9286 } }, -- category=signature itemStyleId=0
        { name = "Xivkyn Heavy Armor", ids = { 3428, 3429, 3430, 3431, 3432, 3433, 3434 } }, -- category=heavyArmor itemStyleId=0
        { name = "Xivkyn Medium Armor", ids = { 3435, 3436, 3437, 3438, 3439, 3440, 3441 } }, -- category=mediumArmor itemStyleId=0
        { name = "Xivkyn Light Armor", ids = { 3442, 3443, 3444, 3445, 3446, 3447, 3448, 3449 } }, -- category=lightArmor itemStyleId=0
        { name = "Xivkyn Weapons", ids = { 3389, 3390, 3391, 3392, 3393, 3394, 3395, 3396, 3397, 4883 } }, -- category=weapons itemStyleId=0
    },
    battleground = -- Battleground
    {
        { name = "Battleground Runner Weapons", ids = { 6783, 6784, 6785 } }, -- category=weapons itemStyleId=67
        { name = "Battleground Runner Signature", ids = { 6728, 6729, 6730, 6731, 6732, 6733 } }, -- category=signature itemStyleId=0
        { name = "Eld Angavar Weapons", ids = { 12533, 12534, 12535, 12536, 12537, 12538, 12539, 12540, 12541, 12542 } }, -- category=weapons itemStyleId=0
        { name = "Fanged Worm Heavy Armor", ids = { 5370, 5371, 5372, 5373, 5374, 5375, 5376 } }, -- category=heavyArmor itemStyleId=0
        { name = "Fanged Worm Medium Armor", ids = { 5363, 5364, 5365, 5366, 5367, 5368, 5369 } }, -- category=mediumArmor itemStyleId=0
        { name = "Fanged Worm Light Armor", ids = { 5355, 5356, 5357, 5358, 5359, 5360, 5361, 5362 } }, -- category=lightArmor itemStyleId=0
        { name = "Fanged Worm Weapons", ids = { 5378, 5379, 5380, 5381, 5382, 5383, 5384, 5385, 5386, 5387 } }, -- category=weapons itemStyleId=0
        { name = "Fire Drake Heavy Armor", ids = { 5645, 5646, 5647, 5648, 5649, 5650, 5651 } }, -- category=heavyArmor itemStyleId=0
        { name = "Fire Drake Medium Armor", ids = { 12557, 12558, 12559, 12560, 12561, 12562, 12563 } }, -- category=mediumArmor itemStyleId=0
        { name = "Fire Drake Weapons", ids = { 6219, 6220, 6221, 6222, 6223, 6224, 6225, 6226, 6227, 6228 } }, -- category=weapons itemStyleId=0
        { name = "Galeskirmish Gladiator Signature", ids = { 12313, 12314, 12315, 12316, 12317, 12318, 12319 } }, -- category=signature itemStyleId=0
        { name = "Horned Dragon Heavy Armor", ids = { 5445, 5446, 5447, 5448, 5449, 5450, 5451 } }, -- category=heavyArmor itemStyleId=0
        { name = "Horned Dragon Medium Armor", ids = { 5438, 5439, 5440, 5441, 5442, 5443, 5444 } }, -- category=mediumArmor itemStyleId=0
        { name = "Horned Dragon Light Armor", ids = { 5430, 5431, 5432, 5433, 5434, 5435, 5436, 5437 } }, -- category=lightArmor itemStyleId=0
        { name = "Horned Dragon Weapons", ids = { 5420, 5421, 5422, 5423, 5424, 5425, 5426, 5427, 5428, 5429 } }, -- category=weapons itemStyleId=0
        { name = "Militant Ordinator Heavy Armor", ids = { 4490, 4491, 4492, 4493, 4494, 4495, 4509 } }, -- category=heavyArmor itemStyleId=0
        { name = "Militant Ordinator Medium Armor", ids = { 4496, 4497, 4498, 4499, 4500, 4501, 4518 } }, -- category=mediumArmor itemStyleId=0
        { name = "Militant Ordinator Light Armor", ids = { 4502, 4503, 4504, 4505, 4506, 4507, 4508, 4517 } }, -- category=lightArmor itemStyleId=0
        { name = "Militant Ordinator Weapons", ids = { 4534, 4535, 4536, 4537, 4538, 4539, 4540, 4541, 4542, 4918 } }, -- category=weapons itemStyleId=0
        { name = "Pit Daemon Heavy Armor", ids = { 5621, 5622, 5623, 5624, 5625, 5626, 5627 } }, -- category=heavyArmor itemStyleId=0
        { name = "Pit Daemon Light Armor", ids = { 12543, 12544, 12545, 12546, 12547, 12548, 12549 } }, -- category=lightArmor itemStyleId=0
        { name = "Pit Daemon Weapons", ids = { 6229, 6230, 6231, 6232, 6233, 6234, 6235, 6236, 6237, 6238 } }, -- category=weapons itemStyleId=0
        { name = "Storm Lord Heavy Armor", ids = { 5628, 5629, 5630, 5631, 5632, 5633, 5634 } }, -- category=heavyArmor itemStyleId=0
        { name = "Storm Lord Light Armor", ids = { 12550, 12551, 12552, 12553, 12554, 12555, 12556 } }, -- category=lightArmor itemStyleId=0
        { name = "Storm Lord Weapons", ids = { 6209, 6210, 6211, 6212, 6213, 6214, 6215, 6216, 6217, 6218 } }, -- category=weapons itemStyleId=0
    },
    veterancy = -- Veterancy
    {
        { name = "Brutal Mercenary Signature", ids = { 13373, 13374, 13375, 13376, 13377, 13378, 13379 } }, -- category=signature itemStyleId=0
        { name = "Fire's Torment Weapons", ids = { 14664, 14665, 14666, 14667, 14668, 14669, 14670, 14671, 14672, 14673 } }, -- category=weapons itemStyleId=0
        { name = "Torment's Cut Weapons", ids = { 9663, 9664, 9665, 9666, 9667, 9668, 9669, 9670, 9671, 9672 } }, -- category=weapons itemStyleId=0
    },
}

local DUMP_FILTERS =
{
    [TAB_CYRODIIL] = { "cyrodiil" },
    [TAB_IMPERIAL_CITY] = { "imperial city" },
    [TAB_BATTLEGROUND] = { "battleground", "battlegrounds" },
    [TAB_VETERANCY] = { "veterancy" },
}

local CATEGORY_LIGHT = "lightArmor"
local CATEGORY_MEDIUM = "mediumArmor"
local CATEGORY_HEAVY = "heavyArmor"
local CATEGORY_WEAPONS = "weapons"
local CATEGORY_UNKNOWN = "uncategorized"
local CATEGORY_SIGNATURE = "signature"

local CATEGORY_LABELS =
{
    [CATEGORY_LIGHT] = "Light Armor",
    [CATEGORY_MEDIUM] = "Medium Armor",
    [CATEGORY_HEAVY] = "Heavy Armor",
    [CATEGORY_WEAPONS] = "Weapons",
    [CATEGORY_UNKNOWN] = "Uncategorized",
    [CATEGORY_SIGNATURE] = "Signature",
}

local CATEGORY_SORT_ORDER =
{
    [CATEGORY_HEAVY] = 1,
    [CATEGORY_MEDIUM] = 2,
    [CATEGORY_LIGHT] = 3,
    [CATEGORY_WEAPONS] = 4,
    [CATEGORY_SIGNATURE] = 5,
    [CATEGORY_UNKNOWN] = 6,
}

local VISUAL_ARMOR_TO_CATEGORY = {}
if VISUAL_ARMORTYPE_LIGHT then VISUAL_ARMOR_TO_CATEGORY[VISUAL_ARMORTYPE_LIGHT] = CATEGORY_LIGHT end
if VISUAL_ARMORTYPE_MEDIUM then VISUAL_ARMOR_TO_CATEGORY[VISUAL_ARMORTYPE_MEDIUM] = CATEGORY_MEDIUM end
if VISUAL_ARMORTYPE_HEAVY then VISUAL_ARMOR_TO_CATEGORY[VISUAL_ARMORTYPE_HEAVY] = CATEGORY_HEAVY end
if VISUAL_ARMORTYPE_SIGNATURE then VISUAL_ARMOR_TO_CATEGORY[VISUAL_ARMORTYPE_SIGNATURE] = CATEGORY_SIGNATURE end

local GEAR_SUFFIXES =
{
    -- Weapons first, longest entries before shorter entries.
    { suffix = "restoration staff", category = CATEGORY_WEAPONS },
    { suffix = "lightning staff", category = CATEGORY_WEAPONS },
    { suffix = "inferno staff", category = CATEGORY_WEAPONS },
    { suffix = "frost staff", category = CATEGORY_WEAPONS },
    { suffix = "battle axe", category = CATEGORY_WEAPONS },
    { suffix = "greatsword", category = CATEGORY_WEAPONS },
    { suffix = "shield", category = CATEGORY_WEAPONS },
    { suffix = "dagger", category = CATEGORY_WEAPONS },
    { suffix = "sword", category = CATEGORY_WEAPONS },
    { suffix = "staff", category = CATEGORY_WEAPONS },
    { suffix = "maul", category = CATEGORY_WEAPONS },
    { suffix = "mace", category = CATEGORY_WEAPONS },
    { suffix = "bow", category = CATEGORY_WEAPONS },
    { suffix = "axe", category = CATEGORY_WEAPONS },

    -- Heavy Armor
    { suffix = "pauldrons", category = CATEGORY_HEAVY },
    { suffix = "gauntlets", category = CATEGORY_HEAVY },
    { suffix = "sabatons", category = CATEGORY_HEAVY },
    { suffix = "cuirass", category = CATEGORY_HEAVY },
    { suffix = "greaves", category = CATEGORY_HEAVY },
    { suffix = "girdle", category = CATEGORY_HEAVY },
    { suffix = "helm", category = CATEGORY_HEAVY },

    -- Medium Armor
    { suffix = "arm cops", category = CATEGORY_MEDIUM },
    { suffix = "bracers", category = CATEGORY_MEDIUM },
    { suffix = "helmet", category = CATEGORY_MEDIUM },
    { suffix = "guards", category = CATEGORY_MEDIUM },
    { suffix = "boots", category = CATEGORY_MEDIUM },
    { suffix = "belt", category = CATEGORY_MEDIUM },
    { suffix = "jack", category = CATEGORY_MEDIUM },

    -- Light Armor
    { suffix = "epaulets", category = CATEGORY_LIGHT },
    { suffix = "breeches", category = CATEGORY_LIGHT },
    { suffix = "gloves", category = CATEGORY_LIGHT },
    { suffix = "jerkin", category = CATEGORY_LIGHT },
    { suffix = "shoes", category = CATEGORY_LIGHT },
    { suffix = "sash", category = CATEGORY_LIGHT },
    { suffix = "robe", category = CATEGORY_LIGHT },
    { suffix = "hat", category = CATEGORY_LIGHT },
}

local ROW_WIDTH_FALLBACK = 750
local ROW_BG_HEIGHT = 37
local ICON_SIZE = 50
local ICON_TEXTURE_SIZE = 45
local ICON_STEP = 52
local ICON_START_X = 4
local ICON_START_Y = 39
local ROW_PADDING_BOTTOM = 8

local function Chat(text)
    if CHAT_SYSTEM then
        CHAT_SYSTEM:AddMessage(text)
    else
        d(text)
    end
end

local function SafeLower(value)
    if value == nil then return "" end
    return zo_strlower(tostring(value))
end

local function SafeCall(methodOwner, methodName, fallback)
    if not methodOwner or type(methodOwner[methodName]) ~= "function" then
        return fallback
    end

    local ok, result = pcall(methodOwner[methodName], methodOwner)
    if ok then
        return result
    end

    return fallback
end

local function EscapeLuaString(value)
    value = tostring(value or "")
    value = value:gsub("\\", "\\\\")
    value = value:gsub('"', '\\"')
    return value
end

local function TextContainsAny(text, keywords)
    text = SafeLower(text)
    if text == "" then return false end

    for _, keyword in ipairs(keywords) do
        if string.find(text, keyword, 1, true) then
            return true
        end
    end

    return false
end

local function IsOutfitStylesCategory(categoryData)
    return categoryData and type(categoryData.IsOutfitStylesCategory) == "function" and categoryData:IsOutfitStylesCategory()
end

local function IsOutfitStyleCollectible(collectibleData)
    return collectibleData and type(collectibleData.IsOutfitStyle) == "function" and collectibleData:IsOutfitStyle()
end

local function GetStyleName(collectibleData)
    local styleName = SafeCall(collectibleData, "GetOutfitStyleItemStyleName", "")
    if not styleName or styleName == "" then
        styleName = SafeCall(collectibleData, "GetName", "")
    end
    return zo_strformat("<<1>>", styleName or "")
end

local function GetCandidateText(collectibleData)
    return table.concat(
    {
        GetStyleName(collectibleData),
        SafeCall(collectibleData, "GetName", "") or "",
        SafeCall(collectibleData, "GetCategoryName", "") or "",
        SafeCall(collectibleData, "GetDescription", "") or "",
        SafeCall(collectibleData, "GetHint", "") or "",
    }, " ")
end

local function GetOutfitStyleCollectibles()
    if not ZO_COLLECTIBLE_DATA_MANAGER or type(ZO_COLLECTIBLE_DATA_MANAGER.GetAllCollectibleDataObjects) ~= "function" then
        return nil, "Collections manager is not ready."
    end

    local ok, allCollectibles = pcall(function()
        return ZO_COLLECTIBLE_DATA_MANAGER:GetAllCollectibleDataObjects({ IsOutfitStylesCategory }, nil, false)
    end)

    if not ok or not allCollectibles then
        return nil, "Could not read outfit styles from Collections."
    end

    return allCollectibles, nil
end

local function Trim(value)
    value = tostring(value or "")
    value = value:gsub("^%s+", "")
    value = value:gsub("%s+$", "")
    return value
end

local function GetApiCategory(collectibleData)
    local isWeapon = SafeCall(collectibleData, "IsWeaponStyle", false)
    if isWeapon then
        return CATEGORY_WEAPONS
    end

    local isArmor = SafeCall(collectibleData, "IsArmorStyle", false)
    if isArmor then
        local visualArmorType = SafeCall(collectibleData, "GetVisualArmorType", nil)
        if visualArmorType and VISUAL_ARMOR_TO_CATEGORY[visualArmorType] then
            return VISUAL_ARMOR_TO_CATEGORY[visualArmorType]
        end
    end

    return nil
end

local function SplitStyleNameAndCategory(name)
    name = Trim(name)
    local lowerName = SafeLower(name)

    if string.find(lowerName, "signature", 1, true) then
        return name, CATEGORY_SIGNATURE
    end

    for _, suffixData in ipairs(GEAR_SUFFIXES) do
        local suffix = suffixData.suffix
        if lowerName == suffix then
            return name, suffixData.category
        end

        local searchSuffix = " " .. suffix
        if lowerName:sub(-#searchSuffix) == searchSuffix then
            local baseName = Trim(name:sub(1, #name - #searchSuffix))
            if baseName ~= "" then
                return baseName, suffixData.category
            end
        end
    end

    return name, nil
end

local function GetStyleBaseNameAndCategory(collectibleData)
    local styleName = GetStyleName(collectibleData)
    local collectibleName = zo_strformat("<<1>>", SafeCall(collectibleData, "GetName", styleName) or styleName)

    local styleBaseName, suffixCategory = SplitStyleNameAndCategory(styleName)
    local collectibleBaseName, collectibleSuffixCategory = SplitStyleNameAndCategory(collectibleName)

    local category = GetApiCategory(collectibleData) or suffixCategory or collectibleSuffixCategory or CATEGORY_UNKNOWN

    -- For many PvP outfit pages GetOutfitStyleItemStyleName() returns the full page name
    -- and itemStyleId is 0. Prefer the stripped collectible name when it found a gear suffix.
    local baseName = styleBaseName
    if collectibleSuffixCategory and collectibleBaseName ~= "" then
        baseName = collectibleBaseName
    end

    if baseName == "" then
        baseName = collectibleName ~= "" and collectibleName or "Unknown Style"
    end

    return baseName, category
end

local function AddCandidate(bucket, baseName, category, styleId, collectibleId, sortOrder)
    category = category or CATEGORY_UNKNOWN
    local key = SafeLower(baseName) .. "::" .. category
    local group = bucket[key]
    if not group then
        group =
        {
            styleName = baseName,
            category = category,
            label = CATEGORY_LABELS[category] or CATEGORY_LABELS[CATEGORY_UNKNOWN],
            styleId = styleId or 0,
            ids = {},
            order = sortOrder or 0,
        }
        bucket[key] = group
    end

    table.insert(group.ids, collectibleId)
end

local function BuildCandidateBuckets()
    local allCollectibles, errorText = GetOutfitStyleCollectibles()
    local buckets =
    {
        [TAB_CYRODIIL] = {},
        [TAB_IMPERIAL_CITY] = {},
        [TAB_BATTLEGROUND] = {},
        [TAB_VETERANCY] = {},
    }

    if not allCollectibles then
        return buckets, errorText
    end

    for _, collectibleData in ipairs(allCollectibles) do
        if IsOutfitStyleCollectible(collectibleData)
            and (type(collectibleData.IsHiddenFromCollection) ~= "function" or not collectibleData:IsHiddenFromCollection()) then
            local text = GetCandidateText(collectibleData)
            local collectibleId = SafeCall(collectibleData, "GetId", 0) or 0
            local styleId = SafeCall(collectibleData, "GetOutfitStyleItemStyleId", 0) or 0
            local baseName, category = GetStyleBaseNameAndCategory(collectibleData)
            local sortOrder = SafeCall(collectibleData, "GetSortOrder", 0) or 0

            if collectibleId and collectibleId > 0 then
                for tabKey, keywords in pairs(DUMP_FILTERS) do
                    if TextContainsAny(text, keywords) then
                        AddCandidate(buckets[tabKey], baseName, category, styleId, collectibleId, sortOrder)
                    end
                end
            end
        end
    end

    return buckets, nil
end
function BSCARI:DumpPvPStyleCandidateIds()
    local buckets, errorText = BuildCandidateBuckets()
    if errorText then
        Chat("|cFF3333[BSCs-AllianceRanking] " .. errorText .. "|r")
        return
    end

    Chat("|cE9C62A[BSCs-AllianceRanking] PvP style candidate ids. Copy into BSCARI.PVP_STYLE_GROUPS.|r")
    Chat("BSCAllianceRanking.PVP_STYLE_GROUPS =")
    Chat("{")

    for _, tabKey in ipairs(TAB_ORDER) do
        local label = TAB_LABELS[tabKey]
        local groups = {}
        for _, group in pairs(buckets[tabKey]) do
            table.sort(group.ids)
            table.insert(groups, group)
        end

        table.sort(groups, function(left, right)
            local leftName = SafeLower(left.styleName)
            local rightName = SafeLower(right.styleName)
            if leftName ~= rightName then
                return leftName < rightName
            end

            local leftCategoryOrder = CATEGORY_SORT_ORDER[left.category or CATEGORY_UNKNOWN] or 99
            local rightCategoryOrder = CATEGORY_SORT_ORDER[right.category or CATEGORY_UNKNOWN] or 99
            if leftCategoryOrder ~= rightCategoryOrder then
                return leftCategoryOrder < rightCategoryOrder
            end

            return (left.styleId or 0) < (right.styleId or 0)
        end)

        Chat(string.format("    %s = -- %s", tabKey, label))
        Chat("    {")
        if #groups == 0 then
            Chat("        -- no candidates found")
        else
            for _, group in ipairs(groups) do
                local rowName = string.format("%s %s", group.styleName or "Unknown Style", group.label or CATEGORY_LABELS[CATEGORY_UNKNOWN])
                Chat(string.format('        { name = "%s", ids = { %s } }, -- category=%s itemStyleId=%s', EscapeLuaString(rowName), table.concat(group.ids, ", "), tostring(group.category or CATEGORY_UNKNOWN), tostring(group.styleId or 0)))
            end
        end
        Chat("    },")
    end

    Chat("}")
end

SLASH_COMMANDS["/bscarstyleids"] = function()
    BSCARI:DumpPvPStyleCandidateIds()
end

local function NormalizeGroups(tabKey)
    local configured = BSCARI.PVP_STYLE_GROUPS and BSCARI.PVP_STYLE_GROUPS[tabKey]
    if type(configured) ~= "table" then
        return {}
    end

    local result = {}
    for _, group in ipairs(configured) do
        if type(group) == "table" and type(group.ids) == "table" then
            table.insert(result,
            {
                name = group.name or group.styleName or "Unknown Style",
                ids = group.ids,
            })
        end
    end
    return result
end

local function GetConfiguredTotals(tabKey)
    local unlocked = 0
    local total = 0
    for _, group in ipairs(NormalizeGroups(tabKey)) do
        for _, collectibleId in ipairs(group.ids) do
            total = total + 1
            if IsCollectibleUnlocked(collectibleId) then
                unlocked = unlocked + 1
            end
        end
    end
    return unlocked, total
end

AlliancePvPStylesView_Keyboard = ZO_InitializingObject:Subclass()

function AlliancePvPStylesView_Keyboard:Initialize(control)
    self.control = control
    self.header = control:GetNamedChild("Header")
    self.headerTitle = self.header and self.header:GetNamedChild("Title")
    self.headerInfo = self.header and self.header:GetNamedChild("Info")
    self.tabButtons =
    {
        [TAB_CYRODIIL] = self.header and self.header:GetNamedChild("Cyrodiil"),
        [TAB_IMPERIAL_CITY] = self.header and self.header:GetNamedChild("ImperialCity"),
        [TAB_BATTLEGROUND] = self.header and self.header:GetNamedChild("Battleground"),
        [TAB_VETERANCY] = self.header and self.header:GetNamedChild("Veterancy"),
    }
    self.panel = control:GetNamedChild("Panel")
    self.scrollChild = self.panel and self.panel:GetNamedChild("ScrollChild")
    self.stylesRoot = self.scrollChild and self.scrollChild:GetNamedChild("Styles")
    self.rows = {}
    self.selectedTab = TAB_CYRODIIL

    for tabKey, button in pairs(self.tabButtons) do
        if button then
            button:SetText(TAB_LABELS[tabKey])
            button:SetHandler("OnClicked", function()
                self:SelectTab(tabKey)
            end)
        end
    end

    BSCARI.ALLIANCE_PVPSTYLEVIEW = self
    BSCARI.ALLIANCE_PVPSTYLEVIEW_FRAGMENT = ZO_FadeSceneFragment:New(control)
    BSCARI.ALLIANCE_PVPSTYLEVIEW_FRAGMENT:RegisterCallback("StateChange", function(_, newState)
        if newState == SCENE_FRAGMENT_SHOWING then
            self:Refresh()
        end
    end)
end

function AlliancePvPStylesView_Keyboard:GetAvailableWidth()
    local width = self.panel and self.panel:GetWidth() or 0
    if width <= 0 then
        width = self.control and self.control:GetWidth() or 0
    end
    if width <= 0 then
        width = ROW_WIDTH_FALLBACK
    end
    return zo_max(ROW_WIDTH_FALLBACK, zo_floor(width - 18))
end

function AlliancePvPStylesView_Keyboard:SelectTab(tabKey)
    if not TAB_LABELS[tabKey] then
        tabKey = TAB_CYRODIIL
    end

    self.selectedTab = tabKey
    self:Refresh()
end

function AlliancePvPStylesView_Keyboard:UpdateTabButtons()
    for tabKey, button in pairs(self.tabButtons) do
        if button then
            local text = TAB_LABELS[tabKey]
            if tabKey == self.selectedTab then
                button:SetText("|cE9C62A> " .. text .. "|r")
            else
                button:SetText(text)
            end
        end
    end
end

function AlliancePvPStylesView_Keyboard:AcquireRow(index)
    local row = self.rows[index]
    if row then
        return row
    end

    local WM = WINDOW_MANAGER
    row = WM:CreateControl("BSCARIPvPStyleRow" .. index, self.stylesRoot, CT_CONTROL)
    row.bg = WM:CreateControl("BSCARIPvPStyleRow" .. index .. "BG", row, CT_BACKDROP)
    row.bg:SetAnchor(TOPLEFT, row, TOPLEFT, 0, 0)
    row.bg:SetDimensions(ROW_WIDTH_FALLBACK, ROW_BG_HEIGHT)
    row.bg:SetCenterColor(0, 0, 0, 0.20)
    row.bg:SetEdgeColor(1, 1, 1, 0)

    row.title = WM:CreateControl("BSCARIPvPStyleRow" .. index .. "Title", row, CT_LABEL)
    row.title:SetAnchor(LEFT, row.bg, LEFT, 10, 0)
    row.title:SetDimensions(520, 32)
    row.title:SetFont("ZoFontGameBold")
    row.title:SetColor(0.91, 0.78, 0.16, 1)
    row.title:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    row.title:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    row.title:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)

    row.summary = WM:CreateControl("BSCARIPvPStyleRow" .. index .. "Summary", row, CT_LABEL)
    row.summary:SetAnchor(RIGHT, row.bg, RIGHT, -10, 0)
    row.summary:SetDimensions(240, 32)
    row.summary:SetFont("ZoFontGameBold")
    row.summary:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    row.summary:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    row.icons = {}
    self.rows[index] = row
    return row
end

function AlliancePvPStylesView_Keyboard:AcquireIcon(row, iconIndex)
    local icon = row.icons[iconIndex]
    if icon then
        return icon
    end

    local WM = WINDOW_MANAGER
    icon = WM:CreateControl(row:GetName() .. "Button" .. iconIndex, row, CT_BUTTON)
    icon:SetDimensions(ICON_SIZE, ICON_SIZE)
    icon:SetMouseEnabled(true)

    icon.texture = WM:CreateControl(icon:GetName() .. "Texture", icon, CT_TEXTURE)
    icon.texture:SetAnchor(CENTER, icon, CENTER, 0, 0)
    icon.texture:SetDimensions(ICON_TEXTURE_SIZE, ICON_TEXTURE_SIZE)

    row.icons[iconIndex] = icon
    return icon
end

function AlliancePvPStylesView_Keyboard:ApplyIconData(icon, collectibleId)
    local name, description, iconPath, deprecatedLockedIcon, unlocked = GetCollectibleInfo(collectibleId)
    icon:SetHidden(false)
    icon.collectibleId = collectibleId

    if icon.texture then
        icon.texture:SetTexture(iconPath or "EsoUI/Art/Icons/icon_missing.dds")
        if unlocked then
            icon.texture:SetColor(1, 1, 1, 1)
            icon.texture:SetDesaturation(0)
        else
            icon.texture:SetColor(1, 0, 0, 1)
            icon.texture:SetDesaturation(0)
        end
    end

    icon:SetHandler("OnMouseEnter", function(control)
        ClearTooltip(ItemTooltip)
        InitializeTooltip(ItemTooltip, control, RIGHT, -5, 0, LEFT)
        local SHOW_NICKNAME = true
        local SHOW_PURCHASABLE_HINT = false
        local SHOW_BLOCK_REASON = true
        ItemTooltip:SetCollectible(collectibleId, SHOW_NICKNAME, SHOW_PURCHASABLE_HINT, SHOW_BLOCK_REASON)
        ItemTooltip:SetHidden(false)
    end)
    icon:SetHandler("OnMouseExit", function()
        ClearTooltip(ItemTooltip)
        ItemTooltip:SetHidden(true)
    end)

    return unlocked == true
end

function AlliancePvPStylesView_Keyboard:LayoutRow(row, group, previousRow, width)
    local ids = group.ids or {}
    local iconsPerRow = zo_max(1, zo_floor((width - ICON_START_X * 2) / ICON_STEP))
    local iconRows = zo_max(1, zo_ceil(#ids / iconsPerRow))
    local height = ICON_START_Y + iconRows * ICON_STEP + ROW_PADDING_BOTTOM

    row:ClearAnchors()
    if previousRow then
        row:SetAnchor(TOPLEFT, previousRow, BOTTOMLEFT, 0, 0)
    else
        row:SetAnchor(TOPLEFT, self.stylesRoot, TOPLEFT, 0, 3)
    end
    row:SetDimensions(width, height)
    row:SetHidden(false)
    row.bg:SetDimensions(width, ROW_BG_HEIGHT)

    local unlockedCount = 0
    for i, collectibleId in ipairs(ids) do
        local icon = self:AcquireIcon(row, i)
        local zeroBased = i - 1
        local col = zeroBased % iconsPerRow
        local line = zo_floor(zeroBased / iconsPerRow)
        icon:ClearAnchors()
        icon:SetAnchor(TOPLEFT, row, TOPLEFT, ICON_START_X + col * ICON_STEP, ICON_START_Y + line * ICON_STEP)
        if self:ApplyIconData(icon, collectibleId) then
            unlockedCount = unlockedCount + 1
        end
    end

    for i = #ids + 1, #row.icons do
        row.icons[i]:SetHidden(true)
    end

    row.title:SetText(group.name or "Unknown Style")
    local missing = #ids - unlockedCount
    if #ids == 0 then
        row.summary:SetText("|c999999No IDs|r")
    elseif missing == 0 then
        row.summary:SetText(zo_strformat("|c00FF00Complete|r <<1>>/<<2>>", unlockedCount, #ids))
    else
        row.summary:SetText(zo_strformat("|cFF3333Missing <<1>>|r |cE9C62A<<2>>/<<3>>|r", missing, unlockedCount, #ids))
    end

    return row
end

function AlliancePvPStylesView_Keyboard:Refresh()
    if not self.stylesRoot then return end

    self:UpdateTabButtons()

    local groups = NormalizeGroups(self.selectedTab)
    local width = self:GetAvailableWidth()
    local previousRow = nil

    for index, group in ipairs(groups) do
        local row = self:AcquireRow(index)
        previousRow = self:LayoutRow(row, group, previousRow, width)
    end

    for index = #groups + 1, #self.rows do
        self.rows[index]:SetHidden(true)
    end

    local unlockedTotal, itemTotal = GetConfiguredTotals(self.selectedTab)
    if self.headerInfo then
        if itemTotal > 0 then
            local percent = unlockedTotal / itemTotal * 100
            self.headerInfo:SetText(string.format("%.1f%% unlocked [%s / %s]", percent, ZO_CommaDelimitDecimalNumber(unlockedTotal), ZO_CommaDelimitDecimalNumber(itemTotal)))
        else
            self.headerInfo:SetText("No IDs configured")
        end
    end

end

function AlliancePvPStylesView_Keyboard_OnInitialize(control)
    AlliancePvPStylesView_Keyboard:New(control)
end
