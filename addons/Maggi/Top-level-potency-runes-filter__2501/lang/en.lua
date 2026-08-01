-------------------------------------------
-- German localization for Enchant Maker --
-------------------------------------------

SafeAddString(ENCHANTMAKER_MADE_WITH, "Made with: ", 1)
SafeAddString(ENCHANTMAKER_CHECK_ALL, "Check all", 1)
SafeAddString(ENCHANTMAKER_UNCHECK_ALL, "Uncheck all", 1)
SafeAddString(ENCHANTMAKER_SEARCH, "Search", 1)
SafeAddString(ENCHANTMAKER_SEARCH_AGAIN, "Search again", 1)
SafeAddString(ENCHANTMAKER_POTENCY_HAVE, "Potency:", 1)
SafeAddString(ENCHANTMAKER_ESSENCE_HAVE, "Essence:", 1)
SafeAddString(ENCHANTMAKER_ASPECT_HAVE, "Aspect:", 1)
SafeAddString(ENCHANTMAKER_SEARCH_RESULTS, "Search Results", 1)
SafeAddString(ENCHANTMAKER_SHOW, "Show", 1)
SafeAddString(ENCHANTMAKER_NEXXT, "Next", 1)
SafeAddString(ENCHANTMAKER_PREVIOUS, "Previous", 1)
SafeAddString(ENCHANTMAKER_USE_MISSING_RUNESTONES_SHORT, "Include missing runestones", 1)
SafeAddString(ENCHANTMAKER_USE_MISSING_RUNESTONES_LONG, "Check this to search for enchantments that use runestones you do not have.", 1)
SafeAddString(ENCHANTMAKER_USE_MISSING_RUNESTONES_WARNING, "Enabling this turns off automatic adding of runestones to table!", 1)
SafeAddString(ENCHANTMAKER_USE_UNKNOWN_SKILL_SHORT,"Include unknown skill", 1)
SafeAddString(ENCHANTMAKER_USE_UNKNOWN_SKILL_LONG,"Check this to search for enchantments that you lack the skill for.", 1)
SafeAddString(ENCHANTMAKER_USE_UNKNOWN_TRAITS_SHORT, "Include unknown translations in searches", 1)
SafeAddString(ENCHANTMAKER_USE_UNKNOWN_TRAITS_LONG, "Check this to include unknown translations in your searches.", 1)
SafeAddString(ENCHANTMAKER_TRAINING_SHORT, "Unknown translations only", 1)
SafeAddString(ENCHANTMAKER_TRAINING_LONG, "Only do enchanting that results in new known translations.", 1)
SafeAddString(ENCHANTMAKER_TRAINING_WARNING, "This will hide all results that do not result in learning a new translation!", 1)
SafeAddString(ENCHANTMAKER_SAME_WINDOW_COORDS_SHORT, "Windows in same positions", 1)
SafeAddString(ENCHANTMAKER_SAME_WINDOW_COORDS_LONG, "Check this to make the results window appear in the same position as the search window.", 1)
SafeAddString(ENCHANTMAKER_REQUIRES_POTENCY,"Requires Potency Improvement",1)
SafeAddString(ENCHANTMAKER_REQUIRES_ASPECT,"Requires Aspect Improvement",1)

EnchMaker.runes = {
    potency = {
        additive = {
            Jora = {translation = "Develop", prefix = "Trifling", skillRequirement = 1, minLevel = 1},
            Porade = {translation = "Add", prefix = "Inferior", skillRequirement = 1, minLevel = 5},
            Jera = {translation = "Increase", prefix = "Petty", skillRequirement = 2, minLevel = 10},
            Jejora = {translation = "Raise", prefix = "Slight", skillRequirement = 2, minLevel = 15},
            Odra = {translation = "Gain", prefix = "Minor", skillRequirement = 3, minLevel = 20},
            Pojora = {translation = "Supplement", prefix = "Lesser", skillRequirement = 3, minLevel = 25},
            Edora = {translation = "Boost", prefix = "Moderate", skillRequirement = 4, minLevel = 30},
            Jaera = {translation = "Advance", prefix = "Average", skillRequirement = 4, minLevel = 35},
            Pora = {translation = "Augment", prefix = "Strong", skillRequirement = 5, minLevel = 40},
            Denara = {translation = "Strenghten", prefix = "Major", skillRequirement = 5, minLevel = 60},
            Rera = {translation = "Exaggerate", prefix = "Greater", skillRequirement = 6, minLevel = 80},
            Derado = {translation = "Empower", prefix = "Grand", skillRequirement = 7, minLevel = 100},
            Recura = {translation = "Magnify", prefix = "Splendid", skillRequirement = 8, minLevel = 120},
            Cura = {translation = "Intensify", prefix = "Monumental", skillRequirement = 9, minLevel = 150},
            Rejera = {translation = "Amplify", prefix = "Superb", skillRequirement = 10, minLevel = 200},
            Repora = {translation = "Reinforce", prefix = "Truly Supurb", skillRequirement = 10, minLevel = 210},
        },

        subtractive = {
            Jode = {translation = "Reduce", prefix = "Trifling", skillRequirement = 1, minLevel = 1},
            Notade = {translation = "Subtract", prefix = "Inferior", skillRequirement = 1, minLevel = 5},
            Ode = {translation = "Shrink", prefix = "Petty", skillRequirement = 2, minLevel = 10},
            Tade = {translation = "Decrease", prefix = "Slight", skillRequirement = 2, minLevel = 15},
            Jayde = {translation = "Deduct", prefix = "Minor", skillRequirement = 3, minLevel = 20},
            Edode = {translation = "Lower", prefix = "Lesser", skillRequirement = 3, minLevel = 25},
            Pojode = {translation = "Diminish", prefix = "Moderate", skillRequirement = 4, minLevel = 30},
            Rekude = {translation = "Weaken", prefix = "Average", skillRequirement = 4, minLevel = 35},
            Hade = {translation = "Lessen", prefix = "Strong", skillRequirement = 5, minLevel = 40},
            Idode = {translation = "Impair", prefix = "Major", skillRequirement = 5, minLevel = 60},
            Pode = {translation = "Remove", prefix = "Greater", skillRequirement = 6, minLevel = 80},
            Kedeko = {translation = "Drain", prefix = "Grand", skillRequirement = 7, minLevel = 100},
            Rede = {translation = "Deprive", prefix = "Splendid", skillRequirement = 8, minLevel = 120},
            Kude = {translation = "Negate", prefix = "Monumental", skillRequirement = 9, minLevel = 150},
            Jehade = {translation = "Divest", prefix = "Superb", skillRequirement = 10, minLevel = 200},
            Itade = {translation = "Plunder", prefix = "Truly Supurb", skillRequirement = 10, minLevel = 210},
        },
    },

    essence = {
        Dekeipa = {translation = "Frost"},
        Deni = {translation = "Stamina"},
        Denima = {translation = "Stamina Regen"},
        Deteri = {translation = "Armor"},
   		Hakeijo = {translation = "Prism"},        
        Haoko = {translation = "Disease"},
        Kaderi = {translation = "Shield"},
        Kuoko = {translation = "Poison"},
        Makderi = {translation = "Spell Harm"},
        Makko = {translation = "Magicka"},
        Makkoma = {translation = "Magicka Regen"},
        Meip = {translation = "Shock"},
        Oko = {translation = "Health"},
        Okoma = {translation = "Health Regen"},
        Okori = {translation = "Power"},
        Oru = {translation = "Alchemist"},
        Rakeipa = {translation = "Fire"},
        Taderi = {translation = "Physical Harm"},
	},

    aspect = {
        Ta = {translation = "Normal", quality = ITEM_QUALITY_NORMAL, skillRequirement = 1},
        Jejota = {translation = "Fine", quality = ITEM_QUALITY_MAGIC, skillRequirement = 1},
        Denata = {translation = "Superior", quality = ITEM_QUALITY_ARCANE, skillRequirement = 2},
        Rekuta = {translation = "Epic", quality = ITEM_QUALITY_ARTIFACT, skillRequirement = 3},
        Kuta = {translation = "Legendary", quality = ITEM_QUALITY_LEGENDARY, skillRequirement = 4},
    },
}

EnchMaker.enchants = {
    additivePotency = {
        Dekeipa = "Frost",
        Deni = "Stamina",
        Denima = "Stamina Recovery",
        Deteri = "Hardening",
        Hakeijo = "Prismatic Defence",
        Haoko = "Foulness",
        Kaderi = "Bashing",
        Kuoko = "Poison",
        Makderi = "Increase Magical Harm",
        Makko = "Magicka",
        Makkoma = "Magicka Recovery",
        Meip = "Shock",
        Oko = "Health",
        Okoma = "Health Recovery",
        Okori = "Rage",
        Oru = "Potion Boost",
        Rakeipa = "Flame",
        Taderi = "Increase Physical Harm",
    },
    subtractivePotency = {
        Dekeipa = "Frost Resist",
        Deni = "Absorb Stamina",
        Denima = "Reduce Feat Cost",
        Deteri = "Crushing",
        Hakeijo = "Prismatic Onslaught",
        Haoko = "Disease Resist",
        Kaderi = "Shielding",
        Kuoko = "Poison Resist",
        Makderi = "Decrease Spell Harm",
        Makko = "Absorb Magicka",
        Makkoma = "Reduce Spell Cost",
        Meip = "Shock Resist",
        Oko = "Absorb Health",
        Okoma = "Decrease Health",
        Okori = "Weakening",
        Oru = "Potion Speed",
        Rakeipa = "Fire Resist",
        Taderi = "Decrease Physical Harm",
    }
}

------------------------------------------------------------------------
-- Column Positions in the dialog
------------------------------------------------------------------------
EnchMaker.Dialog = {
    Width = 600,
    Potency = 20,
    Essence = 215,
    Aspect = 415,
}

------------------------------------------------------------------------
-- Construct the Glyph name for the specific language
------------------------------------------------------------------------
function EnchMaker.LangGlyphName(prefix,essence)
	return string.format("%s Glyph of %s",prefix,essence)
end


