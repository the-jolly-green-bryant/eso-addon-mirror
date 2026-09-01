local function RegisterNecroCatIcons()
    if not Harvest or not Harvest.settings or not Harvest.settings.RegisterPreset then return end
    if Harvest.settings.presets and Harvest.settings.presets["NecroCat Icons"] then return end

    Harvest.settings:RegisterPreset(
        "NecroCat Icons",
        {
            [Harvest.UNKNOWN]     = { texture = "esoui/art/icons/poi/poi_crafting_complete.dds" },
            [Harvest.BLACKSMITH]  = { texture = "NecroCat/imgs/harvest/mining.dds" },
            [Harvest.CLOTHING]    = { texture = "NecroCat/imgs/harvest/clothing.dds" },
            [Harvest.WOODWORKING] = { texture = "NecroCat/imgs/harvest/wood.dds" },
            [Harvest.ENCHANTING]  = { texture = "NecroCat/imgs/harvest/enchanting.dds" },
            [Harvest.MUSHROOM]    = { texture = "NecroCat/imgs/harvest/mushroom.dds" },
            [Harvest.FLOWER]      = { texture = "NecroCat/imgs/harvest/flower.dds" },
            [Harvest.WATERPLANT]  = { texture = "NecroCat/imgs/harvest/waterplant.dds" },
            [Harvest.CRIMSON]     = { texture = "NecroCat/imgs/harvest/waterplant.dds" },
            [Harvest.HERBALIST]   = { texture = "NecroCat/imgs/harvest/alchemy.dds" },
            [Harvest.WATER]       = { texture = "NecroCat/imgs/harvest/solvent.dds" },
            [Harvest.FISHING]     = { texture = "NecroCat/imgs/harvest/fish.dds" },
            [Harvest.HEAVYSACK]   = { texture = "NecroCat/imgs/harvest/heavysack.dds" },
            [Harvest.CLAM]        = { texture = "NecroCat/imgs/harvest/clam.dds" },
            [Harvest.CHESTS]      = { texture = "NecroCat/imgs/harvest/chest.dds" },
            [Harvest.TROVE]       = { texture = "NecroCat/imgs/harvest/trove.dds" },
            [Harvest.JUSTICE]     = { texture = "NecroCat/imgs/harvest/justice.dds" },
            [Harvest.STASH]       = { texture = "NecroCat/imgs/harvest/stash.dds" },
            worldBase             = { texture = "NecroCat/imgs/harvest/worldMarker.dds" },
        }
    )
end

-- Регистрируем пресет при входе в мир
EVENT_MANAGER:RegisterForEvent("NecroCat_HarvestInit", EVENT_PLAYER_ACTIVATED, function()
    EVENT_MANAGER:UnregisterForEvent("NecroCat_HarvestInit", EVENT_PLAYER_ACTIVATED)
    RegisterNecroCatIcons()
end)