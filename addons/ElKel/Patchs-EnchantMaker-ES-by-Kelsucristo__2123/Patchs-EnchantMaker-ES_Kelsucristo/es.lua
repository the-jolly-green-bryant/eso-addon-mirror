-------------------------------------------
-- Spanish localization for Enchant Maker --
-------------------------------------------

SafeAddString(ENCHANTMAKER_MADE_WITH, "Hecho con: ", 1)
SafeAddString(ENCHANTMAKER_CHECK_ALL, "Marca todo", 1)
SafeAddString(ENCHANTMAKER_UNCHECK_ALL, "Desmarcar todo", 1)
SafeAddString(ENCHANTMAKER_SEARCH, "Buscar", 1)
SafeAddString(ENCHANTMAKER_SEARCH_AGAIN, "Buscar de nuevo", 1)
SafeAddString(ENCHANTMAKER_POTENCY_HAVE, "Potencia:", 1)
SafeAddString(ENCHANTMAKER_ESSENCE_HAVE, "Esencia:", 1)
SafeAddString(ENCHANTMAKER_ASPECT_HAVE, "Aspecto:", 1)
SafeAddString(ENCHANTMAKER_SEARCH_RESULTS, "Resultados de la búsqueda", 1)
SafeAddString(ENCHANTMAKER_SHOW, "Ver", 1)
SafeAddString(ENCHANTMAKER_NEXXT, "Siguiente", 1)
SafeAddString(ENCHANTMAKER_PREVIOUS, "Anterior", 1)
SafeAddString(ENCHANTMAKER_USE_MISSING_RUNESTONES_SHORT, "Incluir runas no obtenidas", 1)
SafeAddString(ENCHANTMAKER_USE_MISSING_RUNESTONES_LONG, "Marca esto para buscar encantamientos que usan piedras rúnicas que no tienes.", 1)
SafeAddString(ENCHANTMAKER_USE_MISSING_RUNESTONES_WARNING, "Al habilitar esto, se desactiva la adición automática de runas a la tabla.", 1)
SafeAddString(ENCHANTMAKER_USE_UNKNOWN_SKILL_SHORT,"Incluir habilidad desconocida", 1)
SafeAddString(ENCHANTMAKER_USE_UNKNOWN_SKILL_LONG,"Marca esto para buscar encantamientos para los que no tenga la habilidad.", 1)
SafeAddString(ENCHANTMAKER_USE_UNKNOWN_TRAITS_SHORT, "Incluir traducciones desconocidas en búsquedas", 1)
SafeAddString(ENCHANTMAKER_USE_UNKNOWN_TRAITS_LONG, "Marca esto para incluir traducciones desconocidas en tus búsquedas.", 1)
SafeAddString(ENCHANTMAKER_TRAINING_SHORT, "Solo traducciones desconocidas", 1)
SafeAddString(ENCHANTMAKER_TRAINING_LONG, "Solo haga encantadores resultados en nuevas traducciones conocidas.", 1)
SafeAddString(ENCHANTMAKER_TRAINING_WARNING, "¡Esto ocultará todos los resultados que no den como resultado el aprendizaje de una nueva traducción!", 1)
SafeAddString(ENCHANTMAKER_SAME_WINDOW_COORDS_SHORT, "Ventanas en las mismas posiciones", 1)
SafeAddString(ENCHANTMAKER_SAME_WINDOW_COORDS_LONG, "Marca esto para que la ventana de resultados aparezca en la misma posición que la ventana de búsqueda.", 1)
SafeAddString(ENCHANTMAKER_REQUIRES_POTENCY,"Requiere Mejora de Potencia",1)
SafeAddString(ENCHANTMAKER_REQUIRES_ASPECT,"Requiere Mejora de aspecto",1)

EnchMaker.runes = {
    potency = {
        additive = {
            Jora = {translation = "Ampliar", prefix = "Mediocre", skillRequirement = 1, minLevel = 1},
            Porade = {translation = "Mejora", prefix = "Inferior", skillRequirement = 1, minLevel = 5},
            Jera = {translation = "Avanza", prefix = "Insignificante", skillRequirement = 2, minLevel = 10},
            Jejora = {translation = "Aumento", prefix = "Leve", skillRequirement = 2, minLevel = 15},
            Odra = {translation = "Ganancia", prefix = "Menor", skillRequirement = 3, minLevel = 20},
            Pojora = {translation = "Suplemento", prefix = "Minusculo", skillRequirement = 3, minLevel = 25},
            Edora = {translation = "Aumentar", prefix = "Moderado", skillRequirement = 4, minLevel = 30},
            Jaera = {translation = "Avanzar", prefix = "Medio", skillRequirement = 4, minLevel = 35},
            Pora = {translation = "Aumentar", prefix = "Fuerte", skillRequirement = 5, minLevel = 40},
            Denara = {translation = "Fortalecer", prefix = "Mayor", skillRequirement = 5, minLevel = 60},
            Rera = {translation = "Exagerar", prefix = "Superior", skillRequirement = 6, minLevel = 80},
            Derado = {translation = "Autorizar", prefix = "Grande", skillRequirement = 7, minLevel = 100},
            Recura = {translation = "Magnificar", prefix = "Esplendido", skillRequirement = 8, minLevel = 120},
            Cura = {translation = "Intensificar", prefix = "Monumental", skillRequirement = 9, minLevel = 150},
            Rejera = {translation = "Amplificar", prefix = "Soberbio", skillRequirement = 10, minLevel = 200},
            Repora = {translation = "Fortalece", prefix = "Real. Soberbio", skillRequirement = 10, minLevel = 210},
        },

        subtractive = {
            Jode = {translation = "Reduce", prefix = "Mediocre", skillRequirement = 1, minLevel = 1},
            Notade = {translation = "Sustrae", prefix = "Inferior", skillRequirement = 1, minLevel = 5},
            Ode = {translation = "Encoger", prefix = "Insignificante", skillRequirement = 2, minLevel = 10},
            Tade = {translation = "Disminución", prefix = "Leve", skillRequirement = 2, minLevel = 15},
            Jayde = {translation = "Deducir", prefix = "Menor", skillRequirement = 3, minLevel = 20},
            Edode = {translation = "Inferior", prefix = "Minusculo", skillRequirement = 3, minLevel = 25},
            Pojode = {translation = "Disminuir", prefix = "Moderado", skillRequirement = 4, minLevel = 30},
            Rekude = {translation = "Debilitar", prefix = "Medio", skillRequirement = 4, minLevel = 35},
            Hade = {translation = "Reducir", prefix = "Fuerte", skillRequirement = 5, minLevel = 40},
            Idode = {translation = "Perjudicar", prefix = "Mayor", skillRequirement = 5, minLevel = 60},
            Pode = {translation = "retirar", prefix = "Superior", skillRequirement = 6, minLevel = 80},
            Kedeko = {translation = "Desagüe", prefix = "Grande", skillRequirement = 7, minLevel = 100},
            Rede = {translation = "Privar", prefix = "Esplendido", skillRequirement = 8, minLevel = 120},
            Kude = {translation = "Negar", prefix = "Monumental", skillRequirement = 9, minLevel = 150},
            Jehade = {translation = "Despojar", prefix = "Soberbio", skillRequirement = 10, minLevel = 200},
            Itade = {translation = "Saquear", prefix = "Real. Soberbio", skillRequirement = 10, minLevel = 210},
        },
    },

    essence = {
        Dekeipa = {translation = "Escarcha"},
        Deni = {translation = "Aguante"},
        Denima = {translation = "Regen. de Aguante"},
        Deteri = {translation = "Armadura"},
   		Hakeijo = {translation = "Prisma"},       
        Haoko = {translation = "Enfermedad"},
        Kaderi = {translation = "Escudo"},
        Kuoko = {translation = "Veneno"},
        Makderi = {translation = "Daño mágico"},
        Makko = {translation = "Magia"},
        Makkoma = {translation = "Regen. de Magia"},
        Meip = {translation = "Relámpago"},
        Oko = {translation = "Vida"},
        Okoma = {translation = "Regen. de Vida"},
        Okori = {translation = "Poder"},
        Oru = {translation = "Alquimista"},
        Rakeipa = {translation = "Fuego"},
        Taderi = {translation = "Daño Físico"},
	},

    aspect = {
        Ta = {translation = "Base", quality = ITEM_QUALITY_NORMAL, skillRequirement = 1},
        Jejota = {translation = "Bueno", quality = ITEM_QUALITY_MAGIC, skillRequirement = 1},
        Denata = {translation = "Superior", quality = ITEM_QUALITY_ARCANE, skillRequirement = 2},
        Rekuta = {translation = "Epico", quality = ITEM_QUALITY_ARTIFACT, skillRequirement = 3},
        Kuta = {translation = "Legendario", quality = ITEM_QUALITY_LEGENDARY, skillRequirement = 4},
    },
}

EnchMaker.enchants = {
    additivePotency = {
        Dekeipa = "Hielo",
        Deni = "Aguante",
        Denima = "Regen. de Aguante",
        Deteri = "Robustez",
        Hakeijo = "Defensa Prismática",
        Haoko = "Podredumbre",
        Kaderi = "Percutante",
        Kuoko = "Veneno",
        Makderi = "Aumento de Daño mágico",
        Makko = "Magia",
        Makkoma = "Regen. de Magia",
        Meip = "Descarga",
        Oko = "Vida",
        Okoma = "Regen. de Vida",
        Okori = "Daño Físico",
        Oru = "Alquimista",
        Rakeipa = "Fuego",
        Taderi = "Aumento de Daño Físico",
    },
    subtractivePotency = {
        Dekeipa = "Resistencia al frio",
        Deni = "Absorción de Aguante",
        Denima = "Virtuosidad",
        Deteri = "Aplastamiento",
        Hakeijo = "Asalto Prismático",
        Haoko = "Resistencia a la Enfermedad",
        Kaderi = "Protección",
        Kuoko = "Resistencia a al Veneno",
        Makderi = "Resistencia al Daño Mágico",
        Makko = "Absorción de Magia",
        Makkoma = "Brujería",
        Meip = "Resistencia a la Electricidad",
        Oko = "Absorción de Vida",
        Okoma = "Disminución de Vida",
        Okori = "Debilidad",
        Oru = "Aceleración de posiciones",
        Rakeipa = "Resistencia al Fuego",
        Taderi = "Resistencia al Daño Físico",
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
	return string.format(" Glifo %s de %s",prefix,essence)
end


