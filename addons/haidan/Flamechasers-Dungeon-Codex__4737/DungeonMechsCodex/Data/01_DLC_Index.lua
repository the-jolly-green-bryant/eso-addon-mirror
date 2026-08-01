-- DLC dungeon index. Most entries are stubs so the addon can navigate the full DLC list now.
-- Full mechanics are added as separate modules, one file per dungeon.

local DMC = DungeonMechsCodex

local function stub(id, name, dlc, aliases)
    DMC.RegisterDungeon({
        id = id,
        name = name,
        aliases = aliases or {},
        dlc = dlc,
        status = "stub",
        summary = {
            full = "Dataset stub: mechanics not written yet.",
            chat = { name .. ": mechanics module not built yet." },
        },
        bosses = {},
        source = {
            status = "not_verified_yet",
            note = "Placeholder so navigation/search works while data modules are built dungeon-by-dungeon.",
        },
    })
end

stub("imperial_city_prison", "Imperial City Prison", "Imperial City")
stub("white_gold_tower", "White-Gold Tower", "Imperial City", {"White Gold Tower"})
stub("cradle_of_shadows", "Cradle of Shadows", "Shadows of the Hist")
stub("ruins_of_mazzatun", "Ruins of Mazzatun", "Shadows of the Hist")
stub("bloodroot_forge", "Bloodroot Forge", "Horns of the Reach")
stub("falkreath_hold", "Falkreath Hold", "Horns of the Reach")
stub("fang_lair", "Fang Lair", "Dragon Bones")
stub("scalecaller_peak", "Scalecaller Peak", "Dragon Bones")
stub("march_of_sacrifices", "March of Sacrifices", "Wolfhunter")
stub("moon_hunter_keep", "Moon Hunter Keep", "Wolfhunter")
stub("frostvault", "Frostvault", "Wrathstone")
stub("depths_of_malatar", "Depths of Malatar", "Wrathstone")
stub("moongrave_fane", "Moongrave Fane", "Scalebreaker")
stub("lair_of_maarselok", "Lair of Maarselok", "Scalebreaker")
stub("icereach", "Icereach", "Harrowstorm")
stub("unhallowed_grave", "Unhallowed Grave", "Harrowstorm")
stub("castle_thorn", "Castle Thorn", "Stonethorn")
stub("stone_garden", "Stone Garden", "Stonethorn")
stub("the_cauldron", "The Cauldron", "Flames of Ambition", {"Cauldron"})
stub("red_petal_bastion", "Red Petal Bastion", "Waking Flame")
stub("the_dread_cellar", "The Dread Cellar", "Waking Flame", {"Dread Cellar"})
stub("coral_aerie", "Coral Aerie", "Ascending Tide")
stub("shipwrights_regret", "Shipwright's Regret", "Ascending Tide", {"Shipwright’s Regret"})
stub("earthen_root_enclave", "Earthen Root Enclave", "Lost Depths")
stub("graven_deep", "Graven Deep", "Lost Depths")
stub("scriveners_hall", "Scrivener's Hall", "Scribes of Fate", {"Scrivener’s Hall"})
stub("bal_sunnar", "Bal Sunnar", "Scribes of Fate")
stub("oathsworn_pit", "Oathsworn Pit", "Scions of Ithelia")
stub("bedlam_veil", "Bedlam Veil", "Scions of Ithelia")
stub("exiled_redoubt", "Exiled Redoubt", "Fallen Banners")
stub("lep_seclusa", "Lep Seclusa", "Fallen Banners")
stub("black_gem_foundry", "Black Gem Foundry", "Feast of Shadows")
stub("naj_caldeesh", "Naj-Caldeesh", "Feast of Shadows", {"Naj Caldeesh"})
