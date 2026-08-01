LootHound.ItemData = {}
local D = LootHound.ItemData

D.QUALITY_ANY = 0

-- Maps internal ESO quality constants to readable labels and hex colors
D.QUALITIES = {
    { id = 0,                              label = "Any Quality",  colour = "AAAAAA" },
    { id = ITEM_QUALITY_NORMAL,            label = "Normal",       colour = "FFFFFF" },
    { id = ITEM_QUALITY_MAGIC,             label = "Fine",         colour = "2DC50E" },
    { id = ITEM_QUALITY_ARCANE,            label = "Superior",     colour = "5999FF" },
    { id = ITEM_QUALITY_ARTIFACT,          label = "Epic",         colour = "A02EF7" },
    { id = ITEM_QUALITY_LEGENDARY,         label = "Legendary",    colour = "C5A800" },
}

-- Traits
-- Maps internal ESO trait constants. Split by category so the UI 
D.TRAITS = {
    -- Weapon traits
    { id = ITEM_TRAIT_TYPE_WEAPON_POWERED,      label = "Powered",      category = "weapon" },
    { id = ITEM_TRAIT_TYPE_WEAPON_CHARGED,      label = "Charged",      category = "weapon" },
    { id = ITEM_TRAIT_TYPE_WEAPON_PRECISE,      label = "Precise",      category = "weapon" },
    { id = ITEM_TRAIT_TYPE_WEAPON_INFUSED,      label = "Infused",      category = "weapon" },
    { id = ITEM_TRAIT_TYPE_WEAPON_DEFENDING,    label = "Defending",    category = "weapon" },
    { id = ITEM_TRAIT_TYPE_WEAPON_TRAINING,     label = "Training",     category = "weapon" },
    { id = ITEM_TRAIT_TYPE_WEAPON_SHARPENED,    label = "Sharpened",    category = "weapon" },
    { id = ITEM_TRAIT_TYPE_WEAPON_DECISIVE,     label = "Decisive",     category = "weapon" },
    { id = ITEM_TRAIT_TYPE_WEAPON_NIRNHONED,    label = "Nirnhoned",    category = "weapon" },
    
    -- Armour traits
    { id = ITEM_TRAIT_TYPE_ARMOR_STURDY,        label = "Sturdy",       category = "armor" },
    { id = ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE,  label = "Impenetrable", category = "armor" },
    { id = ITEM_TRAIT_TYPE_ARMOR_REINFORCED,    label = "Reinforced",   category = "armor" },
    { id = ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED,   label = "Well-Fitted",  category = "armor" },
    { id = ITEM_TRAIT_TYPE_ARMOR_TRAINING,      label = "Training",     category = "armor" },
    { id = ITEM_TRAIT_TYPE_ARMOR_INFUSED,       label = "Infused",      category = "armor" },
    { id = ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS,    label = "Prosperous",   category = "armor" },
    { id = ITEM_TRAIT_TYPE_ARMOR_DIVINES,       label = "Divines",      category = "armor" },
    { id = ITEM_TRAIT_TYPE_ARMOR_NIRNHONED,     label = "Nirnhoned",    category = "armor" },
    
    -- Jewellery traits
    { id = ITEM_TRAIT_TYPE_JEWELRY_ARCANE,      label = "Arcane",       category = "jewelry" },
    { id = ITEM_TRAIT_TYPE_JEWELRY_HEALTHY,     label = "Healthy",      category = "jewelry" },
    { id = ITEM_TRAIT_TYPE_JEWELRY_ROBUST,      label = "Robust",       category = "jewelry" },
    { id = ITEM_TRAIT_TYPE_JEWELRY_TRIUNE,      label = "Triune",       category = "jewelry" },
    { id = ITEM_TRAIT_TYPE_JEWELRY_INFUSED,     label = "Infused",      category = "jewelry" },
    { id = ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE,  label = "Protective",   category = "jewelry" },
    { id = ITEM_TRAIT_TYPE_JEWELRY_SWIFT,       label = "Swift",        category = "jewelry" },
    { id = ITEM_TRAIT_TYPE_JEWELRY_HARMONY,     label = "Harmony",      category = "jewelry" },
    { id = ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY,label = "Bloodthirsty", category = "jewelry" },
}
D.TRAIT_ANY = -1  -- Sentinel value meaning "I don't care what trait it is"

-- Weapon & Armour Types
D.WEAPON_ANY = 0
D.WEAPON_TYPES = {
    { id = D.WEAPON_ANY,                  label = "Any Weapon Type" },
    { id = WEAPONTYPE_DAGGER,             label = "Dagger" },
    { id = WEAPONTYPE_SWORD,              label = "Sword (1H)" },
    { id = WEAPONTYPE_AXE,                label = "Axe (1H)" },
    { id = WEAPONTYPE_MACE,               label = "Mace (1H)" },
    { id = WEAPONTYPE_TWO_HANDED_SWORD,   label = "Greatsword" },
    { id = WEAPONTYPE_TWO_HANDED_AXE,     label = "Battle Axe" },
    { id = WEAPONTYPE_TWO_HANDED_MAUL,    label = "Maul" },
    { id = WEAPONTYPE_BOW,                label = "Bow" },
    { id = WEAPONTYPE_FIRE_STAFF,         label = "Inferno Staff" },
    { id = WEAPONTYPE_LIGHTNING_STAFF,    label = "Lightning Staff" },
    { id = WEAPONTYPE_FROST_STAFF,        label = "Ice Staff" },
    { id = WEAPONTYPE_HEALING_STAFF,      label = "Restoration Staff" },
    { id = WEAPONTYPE_SHIELD,             label = "Shield" },
}

D.ARMOUR_ANY = 0
D.ARMOUR_TYPES = {
    { id = D.ARMOUR_ANY,             label = "Any Armour Type" },
    { id = ARMORTYPE_LIGHT,          label = "Light" },
    { id = ARMORTYPE_MEDIUM,         label = "Medium" },
    { id = ARMORTYPE_HEAVY,          label = "Heavy" },
}

-- Helper Methods

-- Returns the hex color string for a given quality level
function D:GetQualityColour(qualityId)
    for _, q in ipairs(self.QUALITIES) do
        if q.id == qualityId then return q.colour end
    end
    return "FFFFFF"
end

-- Returns the readable string name for a given trait ID
function D:GetTraitLabel(traitId)
    if traitId == self.TRAIT_ANY then return "Any Trait" end
    for _, t in ipairs(self.TRAITS) do
        if t.id == traitId then return t.label end
    end
    return "Unknown"
end

-- Checks if a specific item link belongs to a gear set and returns its Set ID
function D:GetSetInfo(itemLink)
    local hasSet, setName, _, _, _, setId = GetItemLinkSetInfo(itemLink)
    return hasSet, setId, setName
end

-- Checks the player's Collection (Sticker Book) to see if they've acquired this item before
function D:IsAlreadyCollected(itemLink)
    local itemId = GetItemLinkItemId(itemLink)
    return IsItemSetCollectionSlotUnlocked(itemId)
end