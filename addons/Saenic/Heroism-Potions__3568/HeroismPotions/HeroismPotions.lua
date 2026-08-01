HeroismPotions = {
    name = "HeroismPotions",
    addonName = "Heroism Potions",
    author = "Saenic",
    version = "1.0.1",

    potionItemIds = {
        [54340] = true, -- All Magicka Pots
        [54341] = true -- All Stamina Pots
    },
    potionEffects = {
        [197919] = true, -- Restore Magicka + Restore Stamina + Heroism
        [335616] = true -- Restore Stamina + Heroism
    },
    potions = {
        [3] = { name = GetString(HP_POTION_NAME_3), icon = '/HeroismPotions/art/potion_type_001.dds' },
        [10] = { name = GetString(HP_POTION_NAME_10), icon = '/HeroismPotions/art/potion_type_001.dds' },
        [20] = { name = GetString(HP_POTION_NAME_20), icon = '/HeroismPotions/art/potion_type_002.dds' },
        [30] = { name = GetString(HP_POTION_NAME_30), icon = '/HeroismPotions/art/potion_type_003.dds' },
        [40] = { name = GetString(HP_POTION_NAME_40), icon = '/HeroismPotions/art/potion_type_004.dds' },
        [60] = { name = GetString(HP_POTION_NAME_CP10), icon = '/HeroismPotions/art/potion_type_005.dds' },
        [100] = { name = GetString(HP_POTION_NAME_CP50), icon = '/HeroismPotions/art/potion_type_005.dds' },
        [150] = { name = GetString(HP_POTION_NAME_CP100), icon = '/HeroismPotions/art/potion_type_005.dds' },
        [200] = { name = GetString(HP_POTION_NAME_CP150), icon = '/HeroismPotions/art/potion_type_005.dds' }
    },
    isStationInteract = false
}

local EVENT_MANAGER = EVENT_MANAGER

function HeroismPotions:Initialize()
    self:InitializeHooks()
    self:InitializeTooltipHooks()

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CRAFTING_STATION_INTERACT, function(...) isStationInteract = true end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_END_CRAFTING_STATION_INTERACT, function(...) isStationInteract = false end)
end

function HeroismPotions.OnAddOnLoaded(_, addon)
    if addon == HeroismPotions.name then
        HeroismPotions:Initialize()
        EVENT_MANAGER:UnregisterForEvent(HeroismPotions.name, EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent(HeroismPotions.name, EVENT_ADD_ON_LOADED, HeroismPotions.OnAddOnLoaded)
