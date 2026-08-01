local Addon = LarvalTearMod

-- Keep group order. slots[1..4] positionally match SavedVariables
-- slotted[1..4] and must not be reordered.
local ChampionGroups = {
    { id = "warfare", slots = { 5, 6, 7, 8 } },
    { id = "fitness", slots = { 9, 10, 11, 12 } },
    { id = "craft", slots = { 1, 2, 3, 4 } },
}
local ChampionGroupIds = {}
for index, group in ipairs(ChampionGroups) do
    ChampionGroupIds[index] = group.id
end

-- Shared fixed domains. Consumers treat these tables as immutable.
Addon.Common.Domains = {
    AttributeTypes = {
        health = ATTRIBUTE_HEALTH,
        magicka = ATTRIBUTE_MAGICKA,
        stamina = ATTRIBUTE_STAMINA,
    },
    AttributeOrder = { "health", "magicka", "stamina" },
    EquipmentSlotIds = {
        EQUIP_SLOT_HEAD,
        EQUIP_SLOT_SHOULDERS,
        EQUIP_SLOT_CHEST,
        EQUIP_SLOT_HAND,
        EQUIP_SLOT_WAIST,
        EQUIP_SLOT_LEGS,
        EQUIP_SLOT_FEET,
        EQUIP_SLOT_NECK,
        EQUIP_SLOT_RING1,
        EQUIP_SLOT_RING2,
        EQUIP_SLOT_MAIN_HAND,
        EQUIP_SLOT_OFF_HAND,
        EQUIP_SLOT_BACKUP_MAIN,
        EQUIP_SLOT_BACKUP_OFF,
    },
    ChampionGroups = ChampionGroups,
    ChampionGroupIds = ChampionGroupIds,
    ChampionGroupByDisciplineType = {
        [CHAMPION_DISCIPLINE_TYPE_COMBAT] = "warfare",
        [CHAMPION_DISCIPLINE_TYPE_CONDITIONING] = "fitness",
        [CHAMPION_DISCIPLINE_TYPE_WORLD] = "craft",
    },
}
