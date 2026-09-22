local ua = UAssistant
local merchant = ua.Merchant

merchant.enchantingRuneDefinitions = {
    potency = {
        { itemId = 45855, name = "Jora", level = "1-10", polarity = "ADDITIVE" },
        { itemId = 45817, name = "Jode", level = "1-10", polarity = "SUBTRACTIVE" },
        { itemId = 45856, name = "Porade", level = "5-15", polarity = "ADDITIVE" },
        { itemId = 45818, name = "Notade", level = "5-15", polarity = "SUBTRACTIVE" },
        { itemId = 45857, name = "Jera", level = "10-20", polarity = "ADDITIVE" },
        { itemId = 45819, name = "Ode", level = "10-20", polarity = "SUBTRACTIVE" },
        { itemId = 45806, name = "Jejora", level = "15-25", polarity = "ADDITIVE" },
        { itemId = 45820, name = "Tade", level = "15-25", polarity = "SUBTRACTIVE" },
        { itemId = 45807, name = "Odra", level = "20-30", polarity = "ADDITIVE" },
        { itemId = 45821, name = "Jayde", level = "20-30", polarity = "SUBTRACTIVE" },
        { itemId = 45808, name = "Pojora", level = "25-35", polarity = "ADDITIVE" },
        { itemId = 45822, name = "Edode", level = "25-35", polarity = "SUBTRACTIVE" },
        { itemId = 45809, name = "Edora", level = "30-40", polarity = "ADDITIVE" },
        { itemId = 45823, name = "Pojode", level = "30-40", polarity = "SUBTRACTIVE" },
        { itemId = 45810, name = "Jaera", level = "35-45", polarity = "ADDITIVE" },
        { itemId = 45824, name = "Rekude", level = "35-45", polarity = "SUBTRACTIVE" },
        { itemId = 45811, name = "Pora", level = "40-50", polarity = "ADDITIVE" },
        { itemId = 45825, name = "Hade", level = "40-50", polarity = "SUBTRACTIVE" },
        { itemId = 45812, name = "Denara", level = "CP 10", polarity = "ADDITIVE" },
        { itemId = 45826, name = "Idode", level = "CP 10", polarity = "SUBTRACTIVE" },
        { itemId = 45813, name = "Rera", level = "CP 30", polarity = "ADDITIVE" },
        { itemId = 45827, name = "Pode", level = "CP 30", polarity = "SUBTRACTIVE" },
        { itemId = 45814, name = "Derado", level = "CP 50", polarity = "ADDITIVE" },
        { itemId = 45828, name = "Kedeko", level = "CP 50", polarity = "SUBTRACTIVE" },
        { itemId = 45815, name = "Rekura", level = "CP 70", polarity = "ADDITIVE" },
        { itemId = 45829, name = "Rede", level = "CP 70", polarity = "SUBTRACTIVE" },
        { itemId = 45816, name = "Kura", level = "CP 100", polarity = "ADDITIVE" },
        { itemId = 45830, name = "Kude", level = "CP 100", polarity = "SUBTRACTIVE" },
        { itemId = 64509, name = "Rejera", level = "CP 150", polarity = "ADDITIVE" },
        { itemId = 64508, name = "Jehade", level = "CP 150", polarity = "SUBTRACTIVE" },
        { itemId = 68341, name = "Repora", level = "CP 160", polarity = "ADDITIVE" },
        { itemId = 68340, name = "Itade", level = "CP 160", polarity = "SUBTRACTIVE" },
    },
    essence = {
        { itemId = 45839, name = "Dekeipa", effectKey = "RUNE_EFFECT_FROST" },
        { itemId = 45833, name = "Deni", effectKey = "RUNE_EFFECT_STAMINA" },
        { itemId = 45836, name = "Denima", effectKey = "RUNE_EFFECT_STAMINA_RECOVERY" },
        { itemId = 45842, name = "Deteri", effectKey = "RUNE_EFFECT_ARMOR" },
        { itemId = 45841, name = "Haoko", effectKey = "RUNE_EFFECT_DISEASE" },
        { itemId = 68342, name = "Hakeijo", effectKey = "RUNE_EFFECT_PRISMATIC_DEFENSE" },
        { itemId = 166045, name = "Indeko", effectKey = "RUNE_EFFECT_PRISMATIC_RECOVERY" },
        { itemId = 45849, name = "Kaderi", effectKey = "RUNE_EFFECT_SHIELD" },
        { itemId = 45837, name = "Kuoko", effectKey = "RUNE_EFFECT_POISON" },
        { itemId = 45848, name = "Makderi", effectKey = "RUNE_EFFECT_SPELL_HARM" },
        { itemId = 45832, name = "Makko", effectKey = "RUNE_EFFECT_MAGICKA" },
        { itemId = 45835, name = "Makkoma", effectKey = "RUNE_EFFECT_MAGICKA_RECOVERY" },
        { itemId = 45840, name = "Meip", effectKey = "RUNE_EFFECT_SHOCK" },
        { itemId = 45831, name = "Oko", effectKey = "RUNE_EFFECT_HEALTH" },
        { itemId = 45834, name = "Okoma", effectKey = "RUNE_EFFECT_HEALTH_RECOVERY" },
        { itemId = 45843, name = "Okori", effectKey = "RUNE_EFFECT_POWER" },
        { itemId = 45846, name = "Oru", effectKey = "RUNE_EFFECT_ALCHEMIST" },
        { itemId = 45838, name = "Rakeipa", effectKey = "RUNE_EFFECT_FLAME" },
        { itemId = 45847, name = "Taderi", effectKey = "RUNE_EFFECT_PHYSICAL_HARM" },
    },
    aspect = {
        { itemId = 45850, name = "Ta", qualityKey = "QUALITY_NORMAL" },
        { itemId = 45851, name = "Jejota", qualityKey = "QUALITY_FINE" },
        { itemId = 45852, name = "Denata", qualityKey = "QUALITY_SUPERIOR" },
        { itemId = 45853, name = "Rekuta", qualityKey = "QUALITY_EPIC" },
        { itemId = 45854, name = "Kuta", qualityKey = "QUALITY_LEGENDARY" },
    },
}

merchant.enchantingRuneGroupsByItemId = {}

for groupName, definitions in pairs(merchant.enchantingRuneDefinitions) do
    for _, definition in ipairs(definitions) do
        merchant.enchantingRuneGroupsByItemId[definition.itemId] = groupName
    end
end

local function CreateDefaults()
    return {
        enabled = false,
        maxQuality = ITEM_QUALITY_NORMAL,
        potencyRunesEnabled = false,
        potencyRunes = {},
        essenceRunesEnabled = false,
        essenceRunes = {},
        aspectRunesEnabled = false,
        aspectRunes = {},
    }
end

local function InitializeProfile(profile)
    for groupName, definitions in pairs(merchant.enchantingRuneDefinitions) do
        local field = groupName .. "Runes"
        if type(profile[field]) ~= "table" then
            profile[field] = {}
        end
        for _, definition in ipairs(definitions) do
            if profile[field][definition.itemId] == nil then
                profile[field][definition.itemId] = false
            end
        end
    end
end

local function IsSelectedRune(profile, itemLink)
    local itemId = GetItemLinkItemId(itemLink)
    local groupName = merchant.enchantingRuneGroupsByItemId[itemId]
    if not groupName then
        return false
    end
    local enabledField = groupName .. "RunesEnabled"
    local selectionField = groupName .. "Runes"
    local selectedRunes = profile[selectionField]
    return profile[enabledField] == true
        and type(selectedRunes) == "table"
        and selectedRunes[itemId] == true
end

merchant.RegisterProfile("enchanting", CreateDefaults, InitializeProfile)

local function IsGlyph(itemLink)
    local itemType = GetItemLinkItemType(itemLink)

    return itemType == ITEMTYPE_GLYPH_ARMOR
        or itemType == ITEMTYPE_GLYPH_JEWELRY
        or itemType == ITEMTYPE_GLYPH_WEAPON
end

merchant.RegisterCategory("enchanting", function(profile, bagId, slotIndex, itemLink)
    if IsSelectedRune(profile, itemLink) then
        return true
    end

    if not profile.enabled or not IsGlyph(itemLink) then
        return false
    end

    local quality = merchant.GetItemQuality(bagId, slotIndex)

    if not quality or quality > profile.maxQuality then
        return false
    end

    return true
end)
