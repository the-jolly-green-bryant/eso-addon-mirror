-------------------------------------------
-- German localization for Enchant Maker --
-------------------------------------------

SafeAddString(ENCHANTMAKER_MADE_WITH, "Hergestellt mit: ", 1)
SafeAddString(ENCHANTMAKER_CHECK_ALL, "Alle markieren", 1)
SafeAddString(ENCHANTMAKER_UNCHECK_ALL, "Alle demarkieren", 1)
SafeAddString(ENCHANTMAKER_SEARCH, "Suchen", 1)
SafeAddString(ENCHANTMAKER_SEARCH_AGAIN, "Erneut suchen", 1)
SafeAddString(ENCHANTMAKER_POTENCY_HAVE, "Macht:", 1)
SafeAddString(ENCHANTMAKER_ESSENCE_HAVE, "Essenz:", 1)
SafeAddString(ENCHANTMAKER_ASPECT_HAVE, "Aspekt:", 1)
SafeAddString(ENCHANTMAKER_SEARCH_RESULTS, "Such Ergebnisse", 1)
SafeAddString(ENCHANTMAKER_SHOW, "Anzeigen", 1)
SafeAddString(ENCHANTMAKER_NEXXT, "Nächster", 1)
SafeAddString(ENCHANTMAKER_PREVIOUS, "Vorheriger", 1)
SafeAddString(ENCHANTMAKER_USE_MISSING_RUNESTONES_SHORT, "Fehlende Runensteine einbinden.", 1)
SafeAddString(ENCHANTMAKER_USE_MISSING_RUNESTONES_LONG, "Markiere dies, um Runensteine, welche du nicht besitzst, mit in der Suche einzubinden.", 1)
SafeAddString(ENCHANTMAKER_USE_MISSING_RUNESTONES_WARNING, "Aktiviere dies, um das Automatische Hinzufügen von Runensteinen zum Verzauberungsslot auszuschalten!", 1)
SafeAddString(ENCHANTMAKER_USE_UNKNOWN_SKILL_SHORT,"Unbekannte Skills einbeziehen.", 1)
SafeAddString(ENCHANTMAKER_USE_UNKNOWN_SKILL_LONG,"Dies anhaken, um nach Verzauberungen zu suchen, für die Du nicht den erforderlichen Skill hast.", 1)
SafeAddString(ENCHANTMAKER_USE_UNKNOWN_TRAITS_SHORT, "Unbekannte Übersetzungen einbinden.", 1)
SafeAddString(ENCHANTMAKER_USE_UNKNOWN_TRAITS_LONG, "Markiere dies, um unbekannte Übersetzungen bei den Suchen mit einzubinden.", 1)
SafeAddString(ENCHANTMAKER_TRAINING_SHORT, "Nur unbekannte Übersetzungen.", 1)
SafeAddString(ENCHANTMAKER_TRAINING_LONG, "Nur Verzauberungen durchführen, welche eine neue bekannte Übersetzung ergibt.", 1)
SafeAddString(ENCHANTMAKER_TRAINING_WARNING, "Dies wird alle Ergebnisse verstecken, welche nicht zu einer neuen Übersetzunng führen!", 1)
SafeAddString(ENCHANTMAKER_SAME_WINDOW_COORDS_SHORT, "Fenster in derselben Position", 1)
SafeAddString(ENCHANTMAKER_SAME_WINDOW_COORDS_LONG, "Markiere dies, um das Ergebnisfenster an derselben Position darzustellen, wie das Suchfenster.", 1)
SafeAddString(ENCHANTMAKER_REQUIRES_POTENCY,"Benötigt Mathtverbesserung")
SafeAddString(ENCHANTMAKER_REQUIRES_ASPECT,"Benötigt Aspektverbesserung")

EnchMaker.runes = {
    potency = {
        additive = {
            ["Jora"] = {translation = "Entwickeln", prefix = "Unbedeutende", skillRequirement = 1, minLevel = 1},
            ["Porade"] = {translation = "Hinzufügen", prefix = "Minderwertige", skillRequirement = 1, minLevel = 5},
            ["Jera"] = {translation = "Erhöhen", prefix = "Winziege", skillRequirement = 2, minLevel = 10},
            ["Jejora"] = {translation = "Zunehmen", prefix = "Schwache", skillRequirement = 2, minLevel = 15},
            ["Odra"] = {translation = "Steigern", prefix = "Meidere", skillRequirement = 3, minLevel = 20},
            ["Pojora"] = {translation = "Aufbessern", prefix = "Geringe", skillRequirement = 3, minLevel = 25},
            ["Edora"] = {translation = "Verbessern", prefix = "Moderate", skillRequirement = 4, minLevel = 30},
            ["Jaera"] = {translation = "Stärken", prefix = "Durchschnittliche", skillRequirement = 4, minLevel = 35},
            ["Pora"] = {translation = "Verstärken", prefix = "Starke", skillRequirement = 5, minLevel = 40},
            ["Denara"] = {translation = "Kräftigen", prefix = "Stärkere", skillRequirement = 5, minLevel = 60},
            ["Rera"] = {translation = "Ergänzen", prefix = "Hervorragende", skillRequirement = 6, minLevel = 80},
            ["Derado"] = {translation = "Bemächtigen", prefix = "Gewaltige", skillRequirement = 7, minLevel = 100},
            ["Rekura"] = {translation = "Vergrößern", prefix = "Vortreffliche", skillRequirement = 8, minLevel = 120},
            ["Kura"] = {translation = "Intensivieren", prefix = "Monumentale", skillRequirement = 9, minLevel = 150},
            ["Rejera"] = {translation = "Verstärken", prefix = "Prächtige", skillRequirement = 10, minLevel = 200},
            ["Repora"] = {translation = "Verdicken", prefix = "Wahrlich Prächtige", skillRequirement = 10, minLevel = 210},
        },

        subtractive = {
            ["Notade"] = {translation = "Abziehen", prefix = "Minderwertige", skillRequirement = 1, minLevel = 5},
            ["Ode"] = {translation = "Schrumpfen", prefix = "Winziege", skillRequirement = 2, minLevel = 10},
            ["Tade"] = {translation = "Verringern", prefix = "Schwache", skillRequirement = 2, minLevel = 15},
            ["Jayde"] = {translation = "Senken", prefix = "Meidere", skillRequirement = 3, minLevel = 20},
            ["Edode"] = {translation = "Wegnehmen", prefix = "Geringe", skillRequirement = 3, minLevel = 25},
            ["Pojode"] = {translation = "Verbrauchen", prefix = "Moderate", skillRequirement = 4, minLevel = 30},
            ["Rekude"] = {translation = "Schwächen", prefix = "Durchschnittliche", skillRequirement = 4, minLevel = 35},
            ["Jode"] = {translation = "Reduzieren", prefix = "Unbedeutende", skillRequirement = 1, minLevel = 1},
            ["Hade"] = {translation = "Mindern", prefix = "Starke", skillRequirement = 5, minLevel = 40},
            ["Idode"] = {translation = "Beeinträchtigen", prefix = "Stärkere", skillRequirement = 5, minLevel = 60},
            ["Pode"] = {translation = "Entfernen", prefix = "Hervorragende", skillRequirement = 6, minLevel = 80},
            ["Kedeko"] = {translation = "Aufzehren", prefix = "Gewaltige", skillRequirement = 7, minLevel = 100},
            ["Rede"] = {translation = "Entziehen", prefix = "Vortreffliche", skillRequirement = 8, minLevel = 120},
            ["Kude"] = {translation = "Negieren", prefix = "Monumentale", skillRequirement = 9, minLevel = 150},
            ["Jehade"] = {translation = "Entblößen", prefix = "Prächtige", skillRequirement = 10, minLevel = 200},
            ["Itade"] = {translation = "Plündern", prefix = "Wahrlich Prächtige", skillRequirement = 10, minLevel = 210},
        },
    },

    essence = {
        ["Dakeipa"] = {translation = "Frost"},
        ["Deni"] = {translation = "Ausdauer"},
        ["Denima"] = {translation = "Ausdauerregeneration"},
        ["Deteri"] = {translation = "Rüstung"},
   		["Hakeijo"] = {translation = "Prism"},        
        ["Haoko"] = {translation = "Seuche"},
        ["Kaderi"] = {translation = "Schild"},
        ["Kuoko"] = {translation = "Gift"},
        ["Makderi"] = {translation = "Magischer Schaden"},
        ["Makko"] = {translation = "Magicka"},
        ["Makkoma"] = {translation = "Magickaregeneration"},
        ["Meip"] = {translation = "Schock"},
        ["Oko"] = {translation = "Leben"},
        ["Okoma"] = {translation = "Lebensregeneration"},
        ["Okori"] = {translation = "Macht"},
        ["Oru"] = {translation = "Alchemist"},
        ["Rakeipa"] = {translation = "Feuer"},
        ["Taderi"] = {translation = "Körperlicher Schaden"},
	},

    aspect = {
        ["Ta"] = {translation = "Normal", quality = ITEM_QUALITY_NORMAL, skillRequirement = 1},
        ["Jejota"] = {translation = "Erlesen", quality = ITEM_QUALITY_MAGIC, skillRequirement = 1},
        ["Denata"] = {translation = "Überlegen", quality = ITEM_QUALITY_ARCANE, skillRequirement = 2},
        ["Rekuta"] = {translation = "Epos", quality = ITEM_QUALITY_ARTIFACT, skillRequirement = 3},
        ["Kuta"] = {translation = "Legendär", quality = ITEM_QUALITY_LEGENDARY, skillRequirement = 4},
    },
}

EnchMaker.enchants = {
    additivePotency = {
        Makko = "Der Magicka",
        Oko = "Des Lebens",
        Deni = "Der Ausdauer",
        Dakeipa = "Des Frosts",
        Hakeijo = "Der Prismatischen Verteidigung",
        Haoko = "Der Fäulnis",
        Kuoko = "Des Gifts",
        Meip = "Des Schocks",
        Okori = "Des Waffenschadens",
        Rakeipa = "Der Flamme",
        Deteri = "Der Abhärtung",
        Taderi = "Des Erhöhten Physischen Schadens",
        Okoma = "Der Lebensregeneration",
        Makkoma = "Der Magickaregeneration",
        Kaderi = "Des Einschlagens",
        Denima = "Der Ausdauerregeneration",
        Oru = "Der Trankverbesserung",
        Makderi = "Des Erhöhten Magischen Schadens",
    },
    subtractivePotency = {
        Makko = "Der Magickaabsorption",
        Oko = "Der Lebensabsorption",
        Okoma = "Der Lebensminderung",
        Okori = "Der Schwächung",
        Deni = "Der Ausdauerabsorption",
        Deteri = "Des Zerschmetterns",
        Dakeipa = "Der Frostresistenz",
        Hakeijo = "Des Prismatischen Ansturms",
        Kuoko = "Der Giftresistenz",
        Makderi = "Des Verringerten Magischen Schadens",
        Taderi = "Des Verringerten Physischen Schadens",
        Denima = "Der Fähigkeitenkostenminderung",
        Haoko = "Der Seuchenresistenz",
        Kaderi = "Des Abschirmens",
        Makkoma = "Der Zauberkostenminderung",
        Meip = "Der Schockresistenz",
        Oru = "Des Tranktempos",
        Rakeipa = "Der Flammenresistenz",
    }
}

------------------------------------------------------------------------
-- Column Positions in the dialog
------------------------------------------------------------------------
EnchMaker.Dialog = {
    Width = 700,
    Potency = 20,
    Essence = 260,
    Aspect = 520,
}

------------------------------------------------------------------------
-- Construct the Glyph name for the specific language
------------------------------------------------------------------------
function EnchMaker.LangGlyphName(prefix,essence)
    --d(string.format("Prefix:[%s]  Essence:[%s]",prefix,essence))
	return string.format("%s Glyphe %s",prefix,essence)
end
