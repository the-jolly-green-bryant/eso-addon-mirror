-------------------------------------------
-- French localization for Enchant Maker --
-------------------------------------------

SafeAddString(ENCHANTMAKER_MADE_WITH, "Créer avec: ", 1)
SafeAddString(ENCHANTMAKER_CHECK_ALL, "Tous cocher", 1)
SafeAddString(ENCHANTMAKER_UNCHECK_ALL, "Tous décocher", 1)
SafeAddString(ENCHANTMAKER_SEARCH, "Rechercher", 1)
SafeAddString(ENCHANTMAKER_SEARCH_AGAIN, "Rechercher de nouveau", 1)
SafeAddString(ENCHANTMAKER_POTENCY_HAVE, "Puissance:", 1)
SafeAddString(ENCHANTMAKER_ESSENCE_HAVE, "Essence:", 1)
SafeAddString(ENCHANTMAKER_ASPECT_HAVE, "Aspect:", 1)
SafeAddString(ENCHANTMAKER_SEARCH_RESULTS, "Rechercher des résultats", 1)
SafeAddString(ENCHANTMAKER_SHOW, "Afficher", 1)
SafeAddString(ENCHANTMAKER_NEXXT, "Suivant", 1)
SafeAddString(ENCHANTMAKER_PREVIOUS, "Précédent", 1)
SafeAddString(ENCHANTMAKER_USE_MISSING_RUNESTONES_SHORT, "Inclure les runes manquantes.", 1)
SafeAddString(ENCHANTMAKER_USE_MISSING_RUNESTONES_LONG, "Cochez ceci pour rechercher les enchantements qui utilisent des runes que vous ne possédez pas.", 1)
SafeAddString(ENCHANTMAKER_USE_MISSING_RUNESTONES_WARNING, "Activer cette option désactive l'ajout automatique des runes dans la table !", 1)
SafeAddString(ENCHANTMAKER_USE_UNKNOWN_SKILL_SHORT,"Inclure les compétences inconnues.", 1)
SafeAddString(ENCHANTMAKER_USE_UNKNOWN_SKILL_LONG,"Cochez cette option pour rechercher des enchantements dont vous ne possédez pas la compétence.", 1)
SafeAddString(ENCHANTMAKER_USE_UNKNOWN_TRAITS_SHORT, "Inclure les traductions inconnues dans les recherches.", 1)
SafeAddString(ENCHANTMAKER_USE_UNKNOWN_TRAITS_LONG, "Cocher cette option pour inclure les traductions inconnues dans vos recherches.", 1)
SafeAddString(ENCHANTMAKER_TRAINING_SHORT, "Traductions inconnues uniquement.", 1)
SafeAddString(ENCHANTMAKER_TRAINING_LONG, "Faire uniquement les enchantements qui aboutissent à de nouvelles traductions.", 1)
SafeAddString(ENCHANTMAKER_TRAINING_WARNING, "Ceci masquera tous les résultats qui n’entrainent pas l'apprentissage d'une nouvelle traduction !", 1)
SafeAddString(ENCHANTMAKER_SAME_WINDOW_COORDS_SHORT, "Même position des fenêtres.", 1)
SafeAddString(ENCHANTMAKER_SAME_WINDOW_COORDS_LONG, "Cocher cette option mettra les fenêtres de résultats et de recherche au même emplacement.", 1)
SafeAddString(ENCHANTMAKER_REQUIRES_POTENCY,"Nécessite Amélioration De Puissance",1)
SafeAddString(ENCHANTMAKER_REQUIRES_ASPECT,"Nécessite Amélioration d’Aspect",1)

EnchMaker.runes = {
    potency = {
        additive = {
            ["Jora"]   = {translation = "Développer", prefix = "Insignifiant", skillRequirement = 1, minLevel = 1},
            ["Porade"] = {translation = "Ajouter", prefix = "Inférieur", skillRequirement = 1, minLevel = 5},
            ["Jéra"]   = {translation = "Améliorer", prefix = "Petit", skillRequirement = 2, minLevel = 10},
            ["Jéjora"] = {translation = "Élever", prefix = "Léger", skillRequirement = 2, minLevel = 15},
            ["Odra"]   = {translation = "Gagner", prefix = "Mineur", skillRequirement = 3, minLevel = 20},
            ["Pojora"] = {translation = "Supplément", prefix = "Inférieur", skillRequirement = 3, minLevel = 25},
            ["Edora"]  = {translation = "Ajouter", prefix = "Modéré", skillRequirement = 4, minLevel = 30},
            ["Jaera"]  = {translation = "Avancer", prefix = "Moyen", skillRequirement = 4, minLevel = 35},
            ["Pora"]   = {translation = "Augmenter", prefix = "Fort", skillRequirement = 5, minLevel = 40},
            ["Dénara"] = {translation = "Renforcer", prefix = "Bon", skillRequirement = 5, minLevel = 60},
            ["Réra"]   = {translation = "Exagérer", prefix = "Majeur", skillRequirement = 6, minLevel = 80},
            ["Dérado"] = {translation = "Dynamiser", prefix = "Grandiose", skillRequirement = 7, minLevel = 100},
            ["Rekura"] = {translation = "Magnifier", prefix = "Splendide", skillRequirement = 8, minLevel = 120},
            ["Kura"]   = {translation = "Intensifier", prefix = "Monumental", skillRequirement = 9, minLevel = 150},
            ["Rejera"] = {translation = "Amplify", prefix = "Superb", skillRequirement = 10, minLevel = 200},
            ["Repora"] = {translation = "Reinforce", prefix = "Vraiment Supurb", skillRequirement = 10, minLevel = 210},
        },

        subtractive = {
            ["Jode"]   = {translation = "Réduire", prefix = "Insignifiant", skillRequirement = 1, minLevel = 1},
            ["Notade"] = {translation = "Soustraire", prefix = "Inférieur", skillRequirement = 1, minLevel = 5},
            ["Ode"]    = {translation = "Diminuer", prefix = "Petit", skillRequirement = 2, minLevel = 10},
			["Tade"]   = {translation = "Repetisser", prefix = "Léger", skillRequirement = 2, minLevel = 15},
            ["Jayde"]  = {translation = "Déduire", prefix = "Mineur", skillRequirement = 3, minLevel = 20},
            ["Edode"]  = {translation = "Abaisser", prefix = "Inférieur", skillRequirement = 3, minLevel = 25},
            ["Pojode"] = {translation = "Raccourcir", prefix = "Modéré", skillRequirement = 4, minLevel = 30},
            ["Rekudé"] = {translation = "Affaiblir", prefix = "Moyen", skillRequirement = 4, minLevel = 35},
            ["Hade"]   = {translation = "Amoundrir", prefix = "Fort", skillRequirement = 5, minLevel = 40},
            ["Idode"]  = {translation = "Entraver", prefix = "Bon", skillRequirement = 5, minLevel = 60},
            ["Pode"]   = {translation = "Rerirer", prefix = "Majeur", skillRequirement = 6, minLevel = 80},
            ["Kédéko"] = {translation = "Drainer", prefix = "Grandiose", skillRequirement = 7, minLevel = 100},
            ["Rede"]   = {translation = "Priver", prefix = "Splendide", skillRequirement = 8, minLevel = 120},
            ["Kudé"]   = {translation = "Annuler", prefix = "Monumental", skillRequirement = 9, minLevel = 150},
            ["Jehade"] = {translation = "Divest", prefix = "Superb", skillRequirement = 10, minLevel = 200},
            ["Itade"]  = {translation = "Plunder", prefix = "Vraiment Supurb", skillRequirement = 10, minLevel = 210},
        },
    },

    essence = {
        ["Dekeïpa"] = {translation = "Glace"},
        ["Deni"]    = {translation = "Vigueur"},
        ["Denima"]  = {translation = "Régénération de Vigueur"},
        ["Deteri"]  = {translation = "Armure"},
		["Hakeijo"] = {translation = "Prisme"}, 
        ["Haoko"]   = {translation = "Maladie"},
        ["Kadéri"]  = {translation = "Bouclier"},
        ["Kuoko"]   = {translation = "Poison"},
        ["Makko"]   = {translation = "Magie"},
        ["Makkoma"] = {translation = "Régénération de Magie"},
        ["Makdéri"] = {translation = "Dégâts Magiques"},
        ["Méip"]    = {translation = "Foudre"},
        ["Oko"]     = {translation = "Santé"},
        ["Okoma"]   = {translation = "Régénération de Santé"},
        ["Okori"]   = {translation = "Pouvoir"},
        ["Oru"]     = {translation = "Alchimiste"},
        ["Rakeïpa"] = {translation = "Feu"},
        ["Taderi"]  = {translation = "Dégâts Physiques"},
	["Indeko"]  = {translation = "Prismatic Regen"},
	},

    aspect = {
        ["Ta"]     = {translation = "Normal", quality = ITEM_QUALITY_NORMAL, skillRequirement = 1},
        ["Jéjota"] = {translation = "Raffiné", quality = ITEM_QUALITY_MAGIC, skillRequirement = 1},
        ["Denata"] = {translation = "Supérieur", quality = ITEM_QUALITY_ARCANE, skillRequirement = 2},
        ["Rekuta"] = {translation = "Épique", quality = ITEM_QUALITY_ARTIFACT, skillRequirement = 3},
        ["Kuta"]   = {translation = "Légendaire", quality = ITEM_QUALITY_LEGENDARY, skillRequirement = 4},
    },
}

EnchMaker.enchants = {
    additivePotency = {
        ["Dekeïpa"] = "Givré",
        ["Deni"]    = "Vigoureux",
        ["Denima"]  = "Revigorant",
        ["Deteri"]  = "Robuste",
	["Hakeijo"] = "De Défense Prismatique",
        ["Haoko"]   = "Odieux",
        ["Kadéri"]  = "Percutant",
        ["Kuoko"]   = "Empoisonné",
        ["Méip"]    = "Étourdissant",
        ["Makdéri"] = "De Puissance Magique",
        ["Makko"]   = "Magique",
        ["Makkoma"] = "Régénérant",
        ["Oko"]     = "Vital",
        ["Okoma"]   = "Revivifiant",
        ["Okori"]   = "De Dégâts D'Arme",
        ["Oru"]     = "De L'Alchimiste",
        ["Rakeïpa"] = "Ardent",
        ["Taderi"]  = "De Puissance Physique",
        ["Indeko"]  = "Récupération prismatique",
    },
    subtractivePotency = {
        ["Dekeïpa"] = "De Résistance Au Givre",
        ["Deni"]    = "D'Absorption De Vigueur",
        ["Denima"]  = "Du Virtuose",
        ["Deteri"]  = "Contondant",
       	["Hakeijo"] = "D'Assaut Prismatique",
        ["Haoko"]   = "De Résistance Á La Maladie",
        ["Kadéri"]  = "Blindé",
        ["Kuoko"]   = "De Résistance Au Poison",
        ["Méip"]    = "Isolé",
        ["Makdéri"] = "De Résistance Magique",
        ["Makko"]   = "D'Absorption De Magie",
        ["Makkoma"] = "Du Mage",
        ["Oko"]     = "Sangsue",
        ["Okoma"]   = "De Santé Déclinante",
        ["Okori"]   = "Affaibissant",
        ["Oru"]     = "D'Accélération Des Potions",
        ["Rakeïpa"] = "Ignifugé",
        ["Taderi"]  = "De Résistance Physique",
	["Indeko"]  = "Réduction du coût de compétences",
    }
}

------------------------------------------------------------------------
-- Column Positions in the dialog
------------------------------------------------------------------------
EnchMaker.Dialog = {
    Width = 700,
    Potency = 20,
    Essence = 250,
    Aspect = 520,
}

------------------------------------------------------------------------
-- Construct the Glyph name for the specific language
------------------------------------------------------------------------
function EnchMaker.LangGlyphName(prefix,essence)
	local PreStr = "Petit,Bon"
    local PostPrefix = "Vraiment Supurb"

	if PreStr:find(prefix) then
		return string.format("%s Glyphe %s",prefix,essence)
	elseif PostPrefix:find(prefix) then
        return string.format("Glyphe %s %s",essence,prefix)
    else
		return string.format("Glyphe %s %s",prefix,essence)
	end
end
