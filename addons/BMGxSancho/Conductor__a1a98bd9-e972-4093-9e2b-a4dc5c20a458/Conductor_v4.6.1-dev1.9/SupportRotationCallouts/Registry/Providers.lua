local R = Conductor.Registry

local providers = {
    -- Ultimates and ultimate-driven effects
    { "AGGRESSIVE_HORN", "Aggressive Horn", "ULTIMATE", "Slot and cast Aggressive Horn to provide Major Force and increase group resources.", "BEST_IN_SLOT" },
    { "WAR_HORN", "War Horn", "ULTIMATE", "Slot and cast War Horn when the unmorphed version is being used.", "ALTERNATIVE" },
    { "REVIVING_BARRIER", "Reviving Barrier", "ULTIMATE", "Slot Reviving Barrier to cover the Barrier rotation and provide a defensive group shield.", "BEST_IN_SLOT" },
    { "BARRIER", "Barrier", "ULTIMATE", "Slot a Barrier morph to cover the defensive ultimate responsibility.", "COMMON" },
    { "COLOSSUS", "Colossus", "ULTIMATE", "Slot and cast a Colossus morph to apply Major Vulnerability.", "COMMON" },
    { "STANDARD_OF_MIGHT", "Standard of Might", "ULTIMATE", "Slot Standard of Might on the assigned Dragonknight damage player.", "COMMON" },
    { "NOVA", "Nova", "ULTIMATE", "Slot a Nova morph on the assigned Templar when the encounter strategy calls for it.", "ALTERNATIVE" },
    { "METEOR", "Meteor", "ULTIMATE", "Slot a Meteor morph on an assigned damage player.", "COMMON" },
    { "STORM_ATRONACH", "Storm Atronach", "ULTIMATE", "Slot a Storm Atronach morph on the assigned Sorcerer.", "COMMON" },
    { "STORM_ATRONACH_SYNERGY", "Charged Atronach Synergy", "ULTIMATE", "Use the Storm Atronach synergy to provide Major Berserk to the activating player.", "COMMON" },
    { "CRYPTCANNON", "Cryptcannon", "ULTIMATE", "Use Cryptcannon as the selected group-ultimate support strategy.", "ADVANCED" },

    -- Slayer, courage, force, and support sets
    { "MASTER_ARCHITECT", "Master Architect", "GEAR", "Equip five pieces and coordinate an ultimate cast to grant Major Slayer to nearby group members.", "BEST_IN_SLOT" },
    { "WAR_MACHINE", "War Machine", "GEAR", "Equip five pieces and coordinate an ultimate cast to grant Major Slayer to nearby group members.", "ALTERNATIVE" },
    { "ROARING_OPPORTUNIST", "Roaring Opportunist", "GEAR", "Equip five pieces and use the heavy-attack trigger to provide Major Slayer.", "COMMON" },
    { "FEROCIOUS_ROAR", "Ferocious Roar", "SKILL", "Slot and use Ferocious Roar on a Werewolf support to provide Major Courage to nearby allies.", "BEST_IN_SLOT", { candidateWerewolf=true } },
    { "SPELL_POWER_CURE", "Spell Power Cure", "GEAR", "Equip five pieces and overheal allies to provide Major Courage.", "COMMON" },
    { "OLORIME", "Vestment of Olorime", "GEAR", "Equip five pieces and place the set's ground effect so allies receive Major Courage.", "ALTERNATIVE" },
    { "OZEZAN_THE_INFERNO", "Ozezan the Inferno", "GEAR", "Equip the two-piece monster set and heal a target to provide Minor Vitality.", "COMMON" },
    { "CLAW_OF_YOLNAHKRIIN", "Claw of Yolnahkriin", "GEAR", "Equip five pieces and taunt an enemy to provide Minor Courage.", "ALTERNATIVE" },
    { "POWERFUL_ASSAULT_SET", "Powerful Assault", "GEAR", "Equip five pieces and cast an Assault ability such as Echoing Vigor to provide the group damage buff.", "BEST_IN_SLOT" },
    { "PILLAGERS_PROFIT", "Pillager's Profit", "GEAR", "Equip five pieces and cast an ultimate to restore ultimate to nearby group members.", "BEST_IN_SLOT" },
    { "NAZARAY", "Nazaray", "GEAR", "Equip the two-piece monster set and cast an ultimate while eligible debuffs are active to extend them.", "BEST_IN_SLOT" },
    { "DRAKES_RUSH", "Drake's Rush", "GEAR", "Equip five pieces and bash after blocking to provide Major Heroism to nearby group members.", "ALTERNATIVE" },

    -- Vulnerability and brittle
    { "TURNING_TIDE", "Turning Tide", "GEAR", "Equip five pieces and trigger the set with a block followed by a bash to apply Major Vulnerability.", "BEST_IN_SLOT" },
    { "ARCHDRUID_DEVYRIC", "Archdruid Devyric", "GEAR", "Equip the two-piece monster set and complete a fully charged heavy attack to apply Major Vulnerability in front of you.", "COMMON" },
    { "TUNDRAS_MAW_MASTERY", "Tundra's Maw Class Mastery", "CLASS_MASTERY", "Assign the Warden mastery. Use a frost staff, or a frost enchant on a lightning staff, with Elemental Susceptibility to apply Chilled reliably. Arctic Wind/Arctic Blast or Winter's Revenge can also improve Chilled application.", "BEST_IN_SLOT", { candidateClassIds={4} } },
    { "NUNATAK", "Nunatak", "GEAR", "Equip the Nunatak monster set to provide Major Brittle. This is supported as a legacy alternative but is rarely used in current optimized groups.", "LEGACY" },
    { "RUNE_COLORLESS_POOL", "Rune of the Colorless Pool", "SKILL", "Slot Rune of the Colorless Pool on an Arcanist support DD, healer, or tank to provide Minor Brittle. It is generally easiest to maintain on a tank or support DD.", "BEST_IN_SLOT", { candidateClassIds={117} } },

    -- Resistance and damage-taken debuffs
    { "CRUSHER_ENCHANT", "Crusher Enchantment", "ENCHANTMENT", "Apply a Crusher weapon enchantment with a reliable weapon-skill trigger to reduce enemy armor.", "BEST_IN_SLOT" },
    { "ELEMENTAL_SUSCEPTIBILITY", "Elemental Susceptibility", "SKILL", "Slot Elemental Susceptibility to provide Major Breach and repeatedly apply elemental status effects.", "BEST_IN_SLOT" },
    { "PIERCE_ARMOR", "Pierce Armor", "SKILL", "Use Pierce Armor on the tank to provide Major and Minor Breach while taunting.", "BEST_IN_SLOT" },
    { "CALTR0PS", "Razor Caltrops", "SKILL", "Use Razor Caltrops as an area source of Major Breach.", "ALTERNATIVE" },
    { "POWER_OF_THE_LIGHT", "Power of the Light", "SKILL", "Use Power of the Light as a Templar source of Minor Breach.", "ALTERNATIVE" },
    { "CONCUSSION", "Concussed Status Effect", "MECHANIC", "Apply Concussed, commonly through shock damage, to provide Minor Vulnerability.", "COMMON" },
    { "FETCHER_INFECTION", "Fetcher Infection", "SKILL", "Use Fetcher Infection as a Warden source of Minor Vulnerability.", "ALTERNATIVE" },
    { "POWER_BASH", "Power Bash Provider", "SKILL", "Use the selected Power Bash interaction when the strategy calls for Minor Cowardice.", "ALTERNATIVE" },
    { "VYKOSA", "Vykosa", "GEAR", "Equip the two-piece monster set and bash the target to apply Minor Cowardice.", "ALTERNATIVE" },
    { "LIGHTNING_WALL_CONCUSSION", "Lightning Wall with Concussion", "MECHANIC", "Apply Concussion and use a lightning Wall of Elements to set the target Off Balance.", "COMMON" },
    { "TACTICIAN_CP", "Tactician Champion Point", "CHAMPION_POINT", "Use the Tactician star when the selected strategy relies on dodge-roll Off Balance.", "NICHE" },

    -- Defensive and class support
    { "RESOLVE_SKILL", "Major Resolve Skill", "SKILL", "Slot a class or armor skill that grants Major Resolve.", "COMMON" },
    { "WARDEN_FROST_CLOAK", "Expansive Frost Cloak", "SKILL", "A Warden can slot Expansive Frost Cloak to provide Major Resolve to nearby allies.", "COMMON" },
    { "RESOLVE_SCRIPT", "Resolve Scribing Script", "SCRIPT", "Use the Resolve script on a suitable scribed support skill to provide the configured resolve effect.", "COMMON" },
    { "OBSIDIAN_SHIELD", "Obsidian Shield", "SKILL", "Use Obsidian Shield or one of its morphs to gain Major Mending.", "COMMON" },
    { "ACCELERATED_GROWTH", "Accelerated Growth", "PASSIVE", "Trigger Accelerated Growth through a qualifying Green Balance heal to gain Major Mending.", "COMMON" },
    { "ESSENCE_DRAIN", "Essence Drain", "PASSIVE", "Complete a fully charged Restoration Staff heavy attack to gain Major Mending.", "COMMON" },
    { "COMBAT_PRAYER", "Combat Prayer", "SKILL", "Use Combat Prayer to provide Minor Berserk and Minor Resolve while healing the group.", "BEST_IN_SLOT" },
    { "KINRASS_WRATH", "Kinras's Wrath", "GEAR", "Use Kinras's Wrath as an alternative source of Minor Berserk where appropriate.", "ALTERNATIVE" },
    { "SEA_SERPENTS_COIL", "Sea-Serpent's Coil", "GEAR", "Use Sea-Serpent's Coil as a personal Major Berserk source.", "NICHE" },
    { "HEROIC_SLASH", "Heroic Slash", "SKILL", "Use Heroic Slash for personal Minor Heroism and the skill's defensive utility.", "COMMON" },
    { "ARCANIST_FORCE_MASTERY", "Arcanist Force Class Mastery", "CLASS_MASTERY", "Assign the Force mastery to the Arcanist support or healer. A support DD can use Echoing Vigor with Reaving Blows in the blue Champion Point tree to trigger the package.", "BEST_IN_SLOT" },
}

for _, entry in ipairs(providers) do
    local data = {
        name = entry[2], providerType = entry[3], instructions = entry[4],
        classification = entry[5] or "COMMON",
    }
    for key, value in pairs(entry[6] or {}) do data[key] = value end
    R:Register("PROVIDERS", entry[1], data)
end
