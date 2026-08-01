--------------------------------------------------------------
-- Companion: Bastian Hallix — Default Wardrobe
--------------------------------------------------------------
Seamstress = Seamstress or {}
Seamstress.Companions = Seamstress.Companions or {}

local C = {
    id        = 1,
    name      = "Bastian Hallix",
    nickname  = "Bastian",
    defaults  = {
        [EQUIP_SLOT_HEAD]       = { link = "empty", trait = "empty", weight = "empty", quality = 0, name = "Head" },
        [EQUIP_SLOT_NECK]       = { link = "empty", trait = "empty", weight = "empty", quality = 0, name = "Neck" },
        [EQUIP_SLOT_CHEST]      = { link = "empty", trait = "empty", weight = "empty", quality = 0, name = "Chest" },
        [EQUIP_SLOT_SHOULDERS]  = { link = "empty", trait = "empty", weight = "empty", quality = 0, name = "Shoulders" },
        [EQUIP_SLOT_MAIN_HAND]  = { link = "empty", trait = "empty", weight = "empty", quality = 0, name = "MainHand" },
        [EQUIP_SLOT_OFF_HAND]   = { link = "empty", trait = "empty", weight = "empty", quality = 0, name = "OffHand" },
        [EQUIP_SLOT_LEGS]       = { link = "empty", trait = "empty", weight = "empty", quality = 0, name = "Legs" },
        [EQUIP_SLOT_HAND]       = { link = "empty", trait = "empty", weight = "empty", quality = 0, name = "Hands" },
        [EQUIP_SLOT_WAIST]      = { link = "empty", trait = "empty", weight = "empty", quality = 0, name = "Waist" },
        [EQUIP_SLOT_FEET]       = { link = "empty", trait = "empty", weight = "empty", quality = 0, name = "Feet" },
        [EQUIP_SLOT_RING1]      = { link = "empty", trait = "empty", weight = "empty", quality = 0, name = "Ring1" },
        [EQUIP_SLOT_RING2]      = { link = "empty", trait = "empty", weight = "empty", quality = 0, name = "Ring2" },
    },
}

Seamstress.Companions[C.nickname] = C
