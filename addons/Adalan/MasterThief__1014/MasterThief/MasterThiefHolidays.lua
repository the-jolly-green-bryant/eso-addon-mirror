--[[
MasterThief - Seasonal Label Overrides
Replaces stat window labels on specific dates using the local system clock.
Loaded after localization files so overrides always win.
Supports: en, de, fr
--]]

local function GetLocalDate()
    if os and os.date then
        local t = os.date("*t")
        return t.month, t.day
    end
    return 0, 0  -- safe fallback: no holiday active
end

local function GetClientLanguage()
    return GetCVar("language.2") or "en"
end

local HOLIDAY_LABELS = {

    april_fools = {
        active = function(m, d) return m == 4 and d == 1 end,
        overrides = {
            en = {
                MT_STATS_ITEMS_LOOTED         = "Totally Legit Acquisitions:",
                MT_STATS_ITEMS_SKIPPED        = "\"I Meant To Take That\":",
                MT_STATS_MOTIFS_LOOTED        = "Fashion Crimes:",
                MT_STATS_RECIPES_LOOTED       = "Questionable Snacks:",
                MT_STATS_FURNISHING_PLANS     = "Dubious Designs:",
                MT_STATS_FURNISHINGS          = "Clown Decor:",
                MT_STATS_HIDDEN_WALLETS       = "Definitely Not Stolen:",
                MT_STATS_RESEARCH_PORTFOLIOS  = "\"Important Papers\":",
                MT_STATS_EDICTS               = "Official Nonsense:",
                MT_STATS_PICKPOCKETS          = "Smooth Criminal Moments:",
                MT_STATS_SAFEBOXES            = "Totally Legal Openings:",
                MT_STATS_DOORS                = "\"They Left It Open\":",
				MT_STATS_LOCKPICK_BREAKS_PREVENTED = "Somehow That Worked:",
                MT_STATS_BOW_KILLS            = "Oopsies:",
                MT_STATS_GUARD_DEATHS         = "Skill Issue:",
                MT_STATS_TROVES               = "Jackpot (Trust Me):",
                MT_STATS_GOLD_FENCED          = "Completely Honest Earnings:",
                MT_STATS_GOLD_LAUNDERED       = "Not Suspicious Spending:",
                MT_STATS_HIGHEST_BOUNTY       = "Oops Meter:",
                MT_STATS_LIFETIME_BOUNTY_PAID = "\"Fines\":",
                MT_STATS_HIGHEST_VALUE        = "Probably Worth Something:",
            },
            de = {
                MT_STATS_ITEMS_LOOTED         = "Völlig Legale Mitnahmen:",
                MT_STATS_ITEMS_SKIPPED        = "\"Das Wollte Ich So\":",
                MT_STATS_MOTIFS_LOOTED        = "Modeverbrechen:",
                MT_STATS_RECIPES_LOOTED       = "Fragwürdige Rezepte:",
                MT_STATS_FURNISHING_PLANS     = "Zwielichtige Pläne:",
                MT_STATS_FURNISHINGS          = "Clown-Einrichtung:",
                MT_STATS_HIDDEN_WALLETS       = "Definitiv Nicht Geklaut:",
                MT_STATS_RESEARCH_PORTFOLIOS  = "\"Wichtige Dokumente\":",
                MT_STATS_EDICTS               = "Offizieller Unsinn:",
                MT_STATS_PICKPOCKETS          = "Reibungslose Gaunermomente:",
                MT_STATS_SAFEBOXES            = "Völlig Legale Öffnungen:",
                MT_STATS_DOORS                = "\"War Schon Offen\":",
				MT_STATS_LOCKPICK_BREAKS_PREVENTED = "Hat Irgendwie Geklappt:",
                MT_STATS_BOW_KILLS            = "Hoppala:",
                MT_STATS_GUARD_DEATHS         = "Skill-Problem:",
                MT_STATS_TROVES               = "Jackpot (Vertrau Mir):",
                MT_STATS_GOLD_FENCED          = "Ehrlich Verdientes Gold:",
                MT_STATS_GOLD_LAUNDERED       = "Völlig Unverdächtiger Einkauf:",
                MT_STATS_HIGHEST_BOUNTY       = "Peinlichkeits-Anzeige:",
                MT_STATS_LIFETIME_BOUNTY_PAID = "\"Gebühren\":",
                MT_STATS_HIGHEST_VALUE        = "Wahrscheinlich Wertvoll:",
            },
            fr = {
                MT_STATS_ITEMS_LOOTED         = "Acquisitions Tout à Fait Légales:",
                MT_STATS_ITEMS_SKIPPED        = "\"C'était Intentionnel\":",
                MT_STATS_MOTIFS_LOOTED        = "Crimes de la Mode:",
                MT_STATS_RECIPES_LOOTED       = "Recettes Douteuses:",
                MT_STATS_FURNISHING_PLANS     = "Plans Suspects:",
                MT_STATS_FURNISHINGS          = "Déco de Clown:",
                MT_STATS_HIDDEN_WALLETS       = "Pas du Tout Volé:",
                MT_STATS_RESEARCH_PORTFOLIOS  = "\"Documents Importants\":",
                MT_STATS_EDICTS               = "Absurdités Officielles:",
                MT_STATS_PICKPOCKETS          = "Moments de Génie Criminel:",
                MT_STATS_SAFEBOXES            = "Ouvertures Tout à Fait Légales:",
                MT_STATS_DOORS                = "\"C'était Déjà Ouvert\":",
				MT_STATS_LOCKPICK_BREAKS_PREVENTED = "Ça a Marché, Mystérieusement:",
                MT_STATS_BOW_KILLS            = "Petits Accidents:",
                MT_STATS_GUARD_DEATHS         = "Problème de Compétence:",
                MT_STATS_TROVES               = "Jackpot (Faites-Moi Confiance):",
                MT_STATS_GOLD_FENCED          = "Gains Parfaitement Honnêtes:",
                MT_STATS_GOLD_LAUNDERED       = "Dépenses Pas Suspectes du Tout:",
                MT_STATS_HIGHEST_BOUNTY       = "Compteur de Bévues:",
                MT_STATS_LIFETIME_BOUNTY_PAID = "\"Amendes\":",
                MT_STATS_HIGHEST_VALUE        = "Vaut Probablement Quelque Chose:",
            },
        },
    },

    halloween = {
        active = function(m, d) return m == 10 and d == 31 end,
        overrides = {
            en = {
                MT_STATS_ITEMS_LOOTED         = "Candy Collected:",
                MT_STATS_ITEMS_SKIPPED        = "Tricks Left Behind:",
                MT_STATS_MOTIFS_LOOTED        = "Grimoires:",
                MT_STATS_RECIPES_LOOTED       = "Witch's Recipes:",
                MT_STATS_FURNISHING_PLANS     = "Haunted Blueprints:",
                MT_STATS_FURNISHINGS          = "Stolen Relics:",
                MT_STATS_HIDDEN_WALLETS       = "Bat Wing Stashes:",
                MT_STATS_RESEARCH_PORTFOLIOS  = "Occult Tomes:",
                MT_STATS_EDICTS               = "Cursed Decrees:",
                MT_STATS_PICKPOCKETS          = "Ghostly Grabs:",
                MT_STATS_SAFEBOXES            = "Coffins Unsealed:",
                MT_STATS_DOORS                = "Crypts Opened:",
				MT_STATS_LOCKPICK_BREAKS_PREVENTED = "Curses Avoided:",
                MT_STATS_BOW_KILLS            = "Midnight Sacrifices:",
                MT_STATS_GUARD_DEATHS         = "Claimed by the Night:",
                MT_STATS_TROVES               = "Pumpkin Hoards:",
                MT_STATS_GOLD_FENCED          = "Blood Money:",
                MT_STATS_GOLD_LAUNDERED       = "Purified Curse Coin:",
                MT_STATS_HIGHEST_BOUNTY       = "Most Wanted Monster:",
                MT_STATS_LIFETIME_BOUNTY_PAID = "Offerings to the Dark:",
                MT_STATS_HIGHEST_VALUE        = "Most Cursed Treasure:",
            },
            de = {
                MT_STATS_ITEMS_LOOTED         = "Gesammeltes Süßzeug:",
                MT_STATS_ITEMS_SKIPPED        = "Zurückgelassene Streiche:",
                MT_STATS_MOTIFS_LOOTED        = "Grimoires:",
                MT_STATS_RECIPES_LOOTED       = "Hexenrezepte:",
                MT_STATS_FURNISHING_PLANS     = "Verfluchte Baupläne:",
                MT_STATS_FURNISHINGS          = "Gestohlene Relikte:",
                MT_STATS_HIDDEN_WALLETS       = "Fledermausflügel-Verstecke:",
                MT_STATS_RESEARCH_PORTFOLIOS  = "Okkulte Schriften:",
                MT_STATS_EDICTS               = "Verfluchte Erlasse:",
                MT_STATS_PICKPOCKETS          = "Geisterhafte Griffe:",
                MT_STATS_SAFEBOXES            = "Geöffnete Särge:",
                MT_STATS_DOORS                = "Geöffnete Gruften:",
				MT_STATS_LOCKPICK_BREAKS_PREVENTED = "Flüche Abgewendet:",
                MT_STATS_BOW_KILLS            = "Mitternachtsopfer:",
                MT_STATS_GUARD_DEATHS         = "Von der Nacht Geholt:",
                MT_STATS_TROVES               = "Kürbishorte:",
                MT_STATS_GOLD_FENCED          = "Blutgeld:",
                MT_STATS_GOLD_LAUNDERED       = "Gereinigte Fluchmünzen:",
                MT_STATS_HIGHEST_BOUNTY       = "Meistgesuchtes Monster:",
                MT_STATS_LIFETIME_BOUNTY_PAID = "Opfergaben an die Dunkelheit:",
                MT_STATS_HIGHEST_VALUE        = "Verfluchstes Schatzstück:",
            },
            fr = {
                MT_STATS_ITEMS_LOOTED         = "Bonbons Récoltés:",
                MT_STATS_ITEMS_SKIPPED        = "Farces Abandonnées:",
                MT_STATS_MOTIFS_LOOTED        = "Grimoires:",
                MT_STATS_RECIPES_LOOTED       = "Recettes de Sorcière:",
                MT_STATS_FURNISHING_PLANS     = "Plans Hantés:",
                MT_STATS_FURNISHINGS          = "Reliques Volées:",
                MT_STATS_HIDDEN_WALLETS       = "Cachettes d'Ailes de Chauve-Souris:",
                MT_STATS_RESEARCH_PORTFOLIOS  = "Tomes Occultes:",
                MT_STATS_EDICTS               = "Décrets Maudits:",
                MT_STATS_PICKPOCKETS          = "Vols Fantomatiques:",
                MT_STATS_SAFEBOXES            = "Cercueils Descellés:",
                MT_STATS_DOORS                = "Cryptes Ouvertes:",
				MT_STATS_LOCKPICK_BREAKS_PREVENTED = "Malédictions Évitées:",
                MT_STATS_BOW_KILLS            = "Sacrifices de Minuit:",
                MT_STATS_GUARD_DEATHS         = "Emporté par la Nuit:",
                MT_STATS_TROVES               = "Trésors de Citrouille:",
                MT_STATS_GOLD_FENCED          = "Argent du Sang:",
                MT_STATS_GOLD_LAUNDERED       = "Pièces Maudites Purifiées:",
                MT_STATS_HIGHEST_BOUNTY       = "Monstre le Plus Recherché:",
                MT_STATS_LIFETIME_BOUNTY_PAID = "Offrandes aux Ténèbres:",
                MT_STATS_HIGHEST_VALUE        = "Trésor le Plus Maudit:",
            },
        },
    },

    christmas = {
        active = function(m, d) return m == 12 and (d >= 24 and d <= 26) end,
        overrides = {
            en = {
                MT_STATS_ITEMS_LOOTED         = "Presents Acquired:",
                MT_STATS_ITEMS_SKIPPED        = "Coal:",
                MT_STATS_MOTIFS_LOOTED        = "Santa's Style Notes:",
                MT_STATS_RECIPES_LOOTED       = "Grandma's Secret Recipes:",
                MT_STATS_FURNISHING_PLANS     = "Workshop Blueprints:",
                MT_STATS_FURNISHINGS          = "Stolen Decorations:",
                MT_STATS_HIDDEN_WALLETS       = "Stuffed Stockings:",
                MT_STATS_RESEARCH_PORTFOLIOS  = "Naughty/Nice Records:",
                MT_STATS_EDICTS               = "Santa's Decrees:",
                MT_STATS_PICKPOCKETS          = "Sleigh-Hand Successes:",
                MT_STATS_SAFEBOXES            = "Gift Boxes Unwrapped:",
                MT_STATS_DOORS                = "Chimneys Entered:",
				MT_STATS_LOCKPICK_BREAKS_PREVENTED = "Christmas Miracle:",
                MT_STATS_BOW_KILLS            = "Silent Night Takedowns:",
                MT_STATS_GUARD_DEATHS         = "Caught by the Elves:",
                MT_STATS_TROVES               = "Hidden Gift Stashes:",
                MT_STATS_GOLD_FENCED          = "Holiday Spending Cash:",
                MT_STATS_GOLD_LAUNDERED       = "Cleaned Winter Coin:",
                MT_STATS_HIGHEST_BOUNTY       = "Most Wanted Naughty List:",
                MT_STATS_LIFETIME_BOUNTY_PAID = "Bribes to the Elves:",
                MT_STATS_HIGHEST_VALUE        = "Best Gift of the Season:",
            },
            de = {
                MT_STATS_ITEMS_LOOTED         = "Geschenke Eingesammelt:",
                MT_STATS_ITEMS_SKIPPED        = "Kohle:",
                MT_STATS_MOTIFS_LOOTED        = "Nikolaus' Stilnotizen:",
                MT_STATS_RECIPES_LOOTED       = "Omas Geheimrezepte:",
                MT_STATS_FURNISHING_PLANS     = "Werkstattpläne:",
                MT_STATS_FURNISHINGS          = "Gestohlener Weihnachtsschmuck:",
                MT_STATS_HIDDEN_WALLETS       = "Gefüllte Strümpfe:",
                MT_STATS_RESEARCH_PORTFOLIOS  = "Artig/Unartig-Register:",
                MT_STATS_EDICTS               = "Nikolaus' Erlasse:",
                MT_STATS_PICKPOCKETS          = "Schlitten-Fingerfertigkeit:",
                MT_STATS_SAFEBOXES            = "Geschenkpakete Geöffnet:",
                MT_STATS_DOORS                = "Kamine Betreten:",
				MT_STATS_LOCKPICK_BREAKS_PREVENTED = "Weihnachtswunder:",
                MT_STATS_BOW_KILLS            = "Stille-Nacht-Ausschaltungen:",
                MT_STATS_GUARD_DEATHS         = "Von Elfen Erwischt:",
                MT_STATS_TROVES               = "Versteckte Geschenkvorräte:",
                MT_STATS_GOLD_FENCED          = "Weihnachtsgeld:",
                MT_STATS_GOLD_LAUNDERED       = "Gewaschene Wintermünzen:",
                MT_STATS_HIGHEST_BOUNTY       = "Meistgesuchter Unbrave:",
                MT_STATS_LIFETIME_BOUNTY_PAID = "Bestechungsgelder an Elfen:",
                MT_STATS_HIGHEST_VALUE        = "Bestes Geschenk der Saison:",
            },
            fr = {
                MT_STATS_ITEMS_LOOTED         = "Cadeaux Récupérés:",
                MT_STATS_ITEMS_SKIPPED        = "Charbon:",
                MT_STATS_MOTIFS_LOOTED        = "Notes de Style du Père Noël:",
                MT_STATS_RECIPES_LOOTED       = "Recettes Secrètes de Grand-Mère:",
                MT_STATS_FURNISHING_PLANS     = "Plans de l'Atelier:",
                MT_STATS_FURNISHINGS          = "Décorations Volées:",
                MT_STATS_HIDDEN_WALLETS       = "Chaussettes Bien Remplies:",
                MT_STATS_RESEARCH_PORTFOLIOS  = "Registre Sage/Pas Sage:",
                MT_STATS_EDICTS               = "Décrets du Père Noël:",
                MT_STATS_PICKPOCKETS          = "Tours de Main en Traîneau:",
                MT_STATS_SAFEBOXES            = "Paquets Cadeaux Ouverts:",
                MT_STATS_DOORS                = "Cheminées Empruntées:",
				MT_STATS_LOCKPICK_BREAKS_PREVENTED = "Miracle de Noël:",
                MT_STATS_BOW_KILLS            = "Éliminations de Nuit Silencieuse:",
                MT_STATS_GUARD_DEATHS         = "Attrapé par les Lutins:",
                MT_STATS_TROVES               = "Cachettes de Cadeaux:",
                MT_STATS_GOLD_FENCED          = "Budget Fêtes:",
                MT_STATS_GOLD_LAUNDERED       = "Pièces d'Hiver Blanchies:",
                MT_STATS_HIGHEST_BOUNTY       = "Liste Noire du Père Noël:",
                MT_STATS_LIFETIME_BOUNTY_PAID = "Pots-de-Vin aux Lutins:",
                MT_STATS_HIGHEST_VALUE        = "Meilleur Cadeau de la Saison:",
            },
        },
    },
}

local function ApplyHolidayLabels()
    local month, day = GetLocalDate()
    local lang = GetClientLanguage()

    for _, holiday in pairs(HOLIDAY_LABELS) do
        if holiday.active(month, day) then
            -- Fall back to English if this language isn't translated
            local strings = holiday.overrides[lang] or holiday.overrides["en"]
            for stringId, newValue in pairs(strings) do
                ZO_CreateStringId(stringId, newValue)
                SafeAddVersion(stringId, 2)
            end
            return  -- only one holiday active at a time
        end
    end
end

ApplyHolidayLabels()