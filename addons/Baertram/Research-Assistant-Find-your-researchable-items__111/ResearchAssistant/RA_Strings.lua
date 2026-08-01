--Global variable
ResearchAssistant = {}
local RA = ResearchAssistant
------------------------------------------------------------------------------------------------------------------------
local supportedLanguages = {
    ["de"] = "de",
    ["en"] = "en",
    ["es"] = "es",
    ["fr"] = "fr",
    ["jp"] = "jp",
    ["ru"] = "ru",
    ["zh"] = "zh",
}

function RA.GetLanguage()
    local lang = GetCVar("language.2")
    --return english if not supported
    local langSupported = supportedLanguages[lang] or "en"
    return langSupported
end
--Get the language of the client
RA.lang = RA.GetLanguage()

------------------------------------------------------------------------------------------------------------------------
--The string constants
RA_Strings = {
    ["en"] = {
        SETTINGS = {
            GENERAL_HEADER = "General Options",
            COLORS_HEADER = "Color Options",
            HIDDEN_HEADER = "Hide Icon Options",
            CHARACTER_HEADER = "Tracked Character Options",

            ICON_LABEL = "Research icon",
            ICON_TOOLTIP = "Choose which icon to display as your research assistant.",

            ICON_SIZE = "Icon size",
            ICON_SIZE_TOOLTIP = "Choose the size of the research icon",

            ICON_OFFSET = "Icon position",
            ICON_OFFSET_TOOLTIP = "Choose the position of the research icon on the X-axis of inventories",
            SEPARATE_LW_LABEL = "Separate leatherworking from tailoring?",
            SEPARATE_LW_TOOLTIP = "Do you want to track medium armor and light armor research for separate characters?",

            SEPARATE_SMITH_LABEL = "Separate weaponsmithing from blacksmithing?",
            SEPARATE_SMITH_TOOLTIP = "Do you want to track weaponsmithing and armorsmithing research for separate characters?",

            RESEARCHABLE_LABEL = "Researchable trait color",
            RESEARCHABLE_TOOLTIP = "What color should the research assistant icon be if the trait is researchable?",

            DUPLICATE_LABEL = "Duplicate researchable trait color",
            DUPLICATE_TOOLTIP = "What color should the research assistant icon be if the item is researchable but there is a better candidate for research?",

            RESEARCHED_LABEL = "Already researched color",
            RESEARCHED_TOOLTIP = "What color should the research assistant icon be if the item is already researched?",

            ORNATE_LABEL = "Ornate item color",
            ORNATE_TOOLTIP = "What color should the icon be for an ornate item?",

            INTRICATE_LABEL = "Intricate item color",
            INTRICATE_TOOLTIP = "What color should the icon be for an intricate item?",

            SHOW_RESEARCHED_LABEL = "Show researched icon?",
            SHOW_RESEARCHED_TOOLTIP = "Should the icon show up for traits that you know?",

            SHOW_TRAITLESS_LABEL = "Show researched icon on traitless?",
            SHOW_TRAITLESS_TOOLTIP = "Should the icon show up for traitless equipment?",

            SHOW_ORNATE_LABEL = "Always show Ornate?",
            SHOW_ORNATE_TOOLTIP = "Should Ornate be shown for untracked skills?",

            SHOW_INTRICATE_LABEL = "Always show Intricate?",
            SHOW_INTRICATE_TOOLTIP = "Should Intricate be shown for untracked skills?",

            SHOW_TOOLTIPS_LABEL = "Show icon tooltips?",
            SHOW_TOOLTIPS_TOOLTIP = "Should tooltips tell you what they are? (recommended OFF)",

            SHOW_IN_GRID_LABEL = "Show in Grid View?",
            SHOW_IN_GRID_TOOLTIP = "Should the research assistant icon show up with Inventory Grid View toggled on? (Ignore this if you don't use Inventory Grid View)",

            WS_CHAR_LABEL = "Weaponsmithing Character",
            WS_CHAR_TOOLTIP = "Which character is your weaponsmithing character?\n\'-\' means: None",

            BS_CHAR_LABEL = "Blacksmithing Character",
            BS_CHAR_TOOLTIP = "Which character is your blacksmithing character?\n\'-\' means: None",

            LW_CHAR_LABEL = "Leatherworking Character",
            LW_CHAR_TOOLTIP = "Which character is your leatherworking character?\n\'-\' means: None",

            CL_CHAR_LABEL = "Clothier Character",
            CL_CHAR_TOOLTIP = "Which character is your clothier character?\n\'-\' means: None",

            WW_CHAR_LABEL = "Woodworking Character",
            WW_CHAR_TOOLTIP = "Which character is your woodworking character?\n\'-\' means: None",

            JC_CHAR_LABEL = "Jewelry crafting Character",
            JC_CHAR_TOOLTIP = "Which character is your jewelry crafting character?\n\'-\' means: None",

            USE_ACCOUNTWIDE_RESEARCH_CHARS      = "Account-wide same research characters",
            USE_ACCOUNTWIDE_RESEARCH_CHARS_TT   = "Attention: Change of this option will reload the UI directly!\n\nWith this option enabled all your characters of the current acocunt will use the same research characters for each crafting type (default setting).\nWith this option disabled you can specify different research characters for each crafting type at each of your characters.",
            ALLOW_NO_CHARACTER_CHOSEN_FOR_RESEARCH      = "No warning w/o research character selected",
            ALLOW_NO_CHARACTER_CHOSEN_FOR_RESEARCH_TT   = "Do not sbow a warning dialog if you have chosen no character for research of any crafting type.",
            USE_CURRENT_LOGGED_IN_CHAR_FOR_RESEARCH     = "Use logged in char for all researches",
            USE_CURRENT_LOGGED_IN_CHAR_FOR_RESEARCH_TT  = "Use the currently logged in character for all researches and crafting types.\n\nOnly works if the 'account-wide same research characters' setting is disabled!",

            PROTECTION                  = "Protection",
            SKIP_ZOS_MARKED             = "Skip ZOs marked",
            SKIP_ZOS_MARKED_TOOLTIP     = "Skip items at the researchable scans and Research Assistant markers if the item is marked with the ZOs lock icon.",
            SKIP_FCOIS_MARKED           = "Skip FCOItemSaver marked",
            SKIP_FCOIS_MARKED_TOOLTIP   = "Skip items at the researchable scans and Research Assistant markers if the item is marked with the FCOIS icons.\nExclusion: The research marker icon of FCOIS is allowed!",
            SKIP_SETS                   = "Skip set items",
            SKIP_SETS_TOOLTIP           = "Skip items which belong to a set and do not mark them with any ResearchAssistant",
            SKIP_SETS_ONLY_MAX_LEVEL    = "Skip sets: Max level only",
            SKIP_SETS_ONLY_MAX_LEVEL_TOOLTIP = "Skip the set items with the maximum level and CPs only, and mark lower levels for research.",

            ERROR_CONFIGURE_ADDON = "Please configure the addon, choose a research character in the settings!",
            ERROR_LOGIN_ALL_CHARS = "Login all your characters to read their research data.",

            HIDE_VANILLA_UI_RESEARCHABLE_TEXTURE = "Hide ZOs vanilla UI researchable texture",
            HIDE_VANILLA_UI_RESEARCHABLE_TEXTURE_TOOLTIP = "Hide the ZOs vanilla UI researchable texture at the inventory rows",

            SHOW_ICON_EVEN_IF_PROTECTED = "Show research icon if protected",
            SHOW_ICON_EVEN_IF_PROTECTED_TOOLTIP = "Always show the research icon, even though the item is protected. This way you are able to see the icon and it's tooltips. Research Assistants does not count these protected items as researchable!\n\nThis icon will respect the other settings like e.g. \'Show researched icon?\': If this is disabled and the item's trait was researched already the research assistant icon wont show!",
            SHOW_ICON_EVEN_IF_PROTECTED_EXCLUDE_NON_TRACKED = "Exclude non tracked",
            SHOW_ICON_EVEN_IF_PROTECTED_EXCLUDE_NON_TRACKED_TOOLTIP = "Do not show the protected icon if the crafting is not tracked",

            SETTINGS_HEADER_TOOLTIPS = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES1306),
            SHOW_TYPE_IN_TOOLTIP = "Show type in tooltip",
            SHOW_TYPE_IN_TOOLTIP_TOOLTIP = "Show the armor/weapon type in the tooltip text",
            SHOW_ARMORWEIGHT_IN_TOOLTIP = "Show armor weight in tooltip",
            SHOW_ARMORWEIGHT_IN_TOOLTIP_TOOLTIP = "Show the armor weight (light, medium, heavy) in the tooltip text",
            SETTINGS_HEADER_VANILLAUI = "Vanilla UI",

            BAG_PRIORITY_HEADER =   "Priority",
            BAG_PRIORITY =          "Bag priority - \'Research preferred from...\'",
            BAG_PRIORITY_TT =       "The priority/order of the bags that will be used for the research.\nPlease reload the UI after changing this order!\n\nThe bag at the top of the orderlist will be \'considered as the most priorized one\', the bag below will be the next one, and so on.",
        },
        TOOLTIPS = {
            knownBy = " \'%s\', known by:\n",
            protected = "-|cFF0000PROTECTED|r-",
            ornate = GetString(SI_ITEMTRAITTYPE10),
            intricate = GetString(SI_ITEMTRAITTYPE9),
            duplicate = "[Researcher: %s]\nDuplicate%s",
            canResearch = "[Researcher: %s]\nUnknown%s",
            alreadyResearched = "[Researcher: %s]\n"..GetString(SI_TRADINGHOUSEFEATURECATEGORY3).."%s",
            notScannedWithNeededCharYet = "|cFF0000ERROR|r: Researcher [\'%s\'] was not logged in yet!",
            notTrackedCharName = "|cFFFFFF-Not tracked-|r",
        },
        BAGS = {
            [BAG_BANK] 				= "Bank",
            [BAG_SUBSCRIBER_BANK] 	= "ESO+ bank",
            [BAG_BACKPACK] 			= "Player inventory",
            [BAG_GUILDBANK] 		= "Guild Bank",
            [BAG_HOUSE_BANK_ONE]    = "House bank 1",
            [BAG_HOUSE_BANK_TWO]    = "House bank 2",
            [BAG_HOUSE_BANK_THREE]  = "House bank 3",
            [BAG_HOUSE_BANK_FOUR]   = "House bank 4",
            [BAG_HOUSE_BANK_FIVE]   = "House bank 5",
            [BAG_HOUSE_BANK_SIX]    = "House bank 6",
            [BAG_HOUSE_BANK_SEVEN]  = "House bank 7",
            [BAG_HOUSE_BANK_EIGHT]  = "House bank 8",
            [BAG_HOUSE_BANK_NINE]   = "House bank 9",
            [BAG_HOUSE_BANK_TEN]    = "House bank 10",
        },
        armorLight = GetString(SI_VISUALARMORTYPE1),
        armorMedium = GetString(SI_VISUALARMORTYPE2),
        armorHeavy = GetString(SI_VISUALARMORTYPE3),

        weaponAxe = GetString(SI_WEAPONTYPE1),
        weaponHammer = GetString(SI_WEAPONTYPE2),
        weaponSword = GetString(SI_WEAPONTYPE3),
        weapon2hdSword = "2hd " .. GetString(SI_WEAPONTYPE4),
        weapon2hdAxe = "2hd " .. GetString(SI_WEAPONTYPE5),
        weapon2hdHammer = "2hd " .. GetString(SI_WEAPONTYPE6),
        weaponBow = GetString(SI_WEAPONTYPE8),
        weaponHealingStaff = GetString(SI_WEAPONTYPE9),
        weaponDagger = GetString(SI_WEAPONTYPE11),
        weaponFireStaff = GetString(SI_WEAPONTYPE12),
        weaponFrostStaff = GetString(SI_WEAPONTYPE13),
        weaponShield = GetString(SI_WEAPONTYPE14),
        weaponLightningStaff = GetString(SI_WEAPONTYPE15),

        equipHead = GetString(SI_EQUIPTYPE1),
        equipNeck = GetString(SI_EQUIPTYPE2),
        equipChest = GetString(SI_EQUIPTYPE3),
        equipShoulders = GetString(SI_EQUIPTYPE4),
        equipWaist = GetString(SI_EQUIPTYPE8),
        equipLegs = GetString(SI_EQUIPTYPE9),
        equipFeet = GetString(SI_EQUIPTYPE10),
        equipRing = GetString(SI_EQUIPTYPE12),
        equipHand = GetString(SI_EQUIPTYPE13),
    },
    ["de"] = {
        SETTINGS = {
            GENERAL_HEADER = "Allgemeine Einstellungen",
            COLORS_HEADER = "Farben",
            HIDDEN_HEADER = "Icon-Anzeige",
            CHARACTER_HEADER = "Handwerker-Charakter",

            ICON_LABEL = "Analyse-Icon",
            ICON_TOOLTIP = "Das Icon, das bei analysierbaren Gegenständen angezeigt wird",

            ICON_SIZE = "Icon Größe",
            ICON_SIZE_TOOLTIP = "Wähle die Größe des Analyse Icons",

            ICON_OFFSET = "Icon Position",
            ICON_OFFSET_TOOLTIP = "Wähle die Position des Analyse Icons auf der X-Achse der Inventare",
            SEPARATE_LW_LABEL = "Leder- und Stoffschneiderei trennen",
            SEPARATE_LW_TOOLTIP = "Sollen Leder- und Stoffschneiderei für zwei verschiedene Charakter verfolgt werden?",

            SEPARATE_SMITH_LABEL = "Waffen- und Rüstungsschmiedekunst trennen",
            SEPARATE_SMITH_TOOLTIP = "Sollen Waffen- und Rüstungsschmiedekunst für zwei verschiedene Charakter verfolgt werden?",

            RESEARCHABLE_LABEL = "Analysierbare Gegenstände",
            RESEARCHABLE_TOOLTIP = "Welche Farbe soll das Icon haben wenn ein Gegenstand analysierbar ist?",

            DUPLICATE_LABEL = "Doppelte Gegenstände",
            DUPLICATE_TOOLTIP = "Welche Farbe soll das Icon haben wenn ein Gegenstand analysierbar ist, aber ein besserer Kandidat für das Analysieren vorhanden ist?",

            RESEARCHED_LABEL = "Bekannte Gegenstände",
            RESEARCHED_TOOLTIP = "Welche Farbe soll das Icon haben wenn die Eigenschaft eines Gegenstands bereits analysiert wurde?",

            ORNATE_LABEL = "Hoher Verkaufspreis",
            ORNATE_TOOLTIP = "Welche Farbe soll das Icon haben wenn ein Gegenstände einen hohen Verkaufspreis erzielt?",

            INTRICATE_LABEL = "Gegenstände mit Inspiration",
            INTRICATE_TOOLTIP = "Welche Farbe soll das Icon haben wenn ein Gegenstand beim Verwerten extra Erfahrung gewährt?",

            SHOW_RESEARCHED_LABEL = "Analysierte Gegenstände",
            SHOW_RESEARCHED_TOOLTIP = "Sollen Icons für Gegenstände angezeigt werden, die bereits analysiert wurden?",

            SHOW_TRAITLESS_LABEL = "Gegenstände ohne Eigenschaften",
            SHOW_TRAITLESS_TOOLTIP = "Sollen Icons für Gegenstände angezeigt werden, die keine Eigenschaften besitzen?",

            SHOW_ORNATE_LABEL = "Hoher Verkaufspreis",
            SHOW_ORNATE_TOOLTIP = "Sollen Icons für Gegenstände mit hohem Verkaufspreis trotz deaktivierten Berufen angezeigt werden?",

            SHOW_INTRICATE_LABEL = "Inspiration",
            SHOW_INTRICATE_TOOLTIP = "Sollen Icons für Gegenstände, die beim Verwerten zusätzliche Inspiration gewähren, trotz deaktivierten Berufen angezeigt werden?",

            SHOW_TOOLTIPS_LABEL = "Tooltips verwenden",
            SHOW_TOOLTIPS_TOOLTIP = "Sollen erklärende Tooltips an den Icons angezeigt werden?",

            SHOW_IN_GRID_LABEL = "Inventory Grid View Plugin",
            SHOW_IN_GRID_TOOLTIP = "Sollen Icons auch bei Verwendung des Inventory Grid View Addons angezeigt werden?",

            WS_CHAR_LABEL = "Waffenschmiedekunst",
            WS_CHAR_TOOLTIP = "Welcher Charakter soll für die Waffenschmiedekunst verwendet werden?\n\'-\' bedeutet: Keiner",

            BS_CHAR_LABEL = "Schmiedekunst",
            BS_CHAR_TOOLTIP = "Welcher Charakter soll für die Schmiedekunst verwendet werden?\n\'-\' bedeutet: Keiner",

            CL_CHAR_LABEL = "Schneiderei",
            CL_CHAR_TOOLTIP = "Welcher Charakter soll für die Schneiderei verwendet werden?\n\'-\' bedeutet: Keiner",

            LW_CHAR_LABEL = "Lederschneiderei",
            LW_CHAR_TOOLTIP = "Welcher Charakter soll für die Lederschneiderei verwendet werden?\n\'-\' bedeutet: Keiner",

            WW_CHAR_LABEL = "Schreinerei",
            WW_CHAR_TOOLTIP = "Welcher Charakter soll für die Schreinerei verwendet werden?\n\'-\' bedeutet: Keiner",

            JC_CHAR_LABEL = "Schmuck Handwerk",
            JC_CHAR_TOOLTIP = "Welcher Charakter soll für das Schmuck Handwerk verwendet werden?\n\'-\' bedeutet: Keiner",

            USE_ACCOUNTWIDE_RESEARCH_CHARS      = "Account-weit Analyse Charaktere identisch",
            USE_ACCOUNTWIDE_RESEARCH_CHARS_TT   = "ACHTUNG: Verändern dieser Option lädt die Benutzeroberfläche sofort neu!\n\nIst diese Option aktiviert so werden für diesen Account dieselben Analyse Charaktere für alle Handwerke benutzt (Standard Einstellung).\nDeaktivierst du diese Option so kannst du je Charakter deines Accounts unterschiedliche Analyse Charaktere je Handwerk festlegen.",
            USE_CURRENT_LOGGED_IN_CHAR_FOR_RESEARCH     = "Nutze eingeloggten User für alle Analysen",
            USE_CURRENT_LOGGED_IN_CHAR_FOR_RESEARCH_TT  = "Nutzt den aktuell eingeloggten Benutzer für alle Analysen aller Handwerke.\n\nFunktioniert nur wenn die 'Account-weit Analyse Charaktere identisch' Einstellung aus ist!",

            PROTECTION                  = "Schutz",
            SKIP_ZOS_MARKED             = "ZOs markierte ausschließen",
            SKIP_ZOS_MARKED_TOOLTIP     = "Schließt durch ZOs markierte (Schloß Symbol) Gegenstände von den Research Assistant Scan und Markierungen aus.",
            SKIP_FCOIS_MARKED           = "FCOItemSaver markierte ausschließen",
            SKIP_FCOIS_MARKED_TOOLTIP   = "Schließt durch FCOItemSaver markierte Gegenstände von den Research Assistant Scan und Markierungen aus.\nAußname: Mit dem Analyse Symbol markierte werden berücksichtigt!",
            SKIP_SETS                   = "Set Gegenstände ausschließen",
            SKIP_SETS_TOOLTIP           = "Set Gegenstände mit keiner ResearchAssistant Markierung versehen.",
            SKIP_SETS_ONLY_MAX_LEVEL    = "Sets: Nur maximum Level",
            SKIP_SETS_ONLY_MAX_LEVEL_TOOLTIP = "Set Gegenstände werden nur dann nicht zur Analyse markiert, wenn diese das maximale Level & CPs besitzen. Niedrigere Level werden markiert.",

            ERROR_CONFIGURE_ADDON = "Bitte konfiguriere das AddOn, wähle einen Analyse Charakter in den Einstellungen!",
            ERROR_LOGIN_ALL_CHARS = "Logge alle Charaktere ein, um ihre Analyse Daten einzulesen.",
            ALLOW_NO_CHARACTER_CHOSEN_FOR_RESEARCH      = "Keine Warnung ohne Analyse Char. gewählt",
            ALLOW_NO_CHARACTER_CHOSEN_FOR_RESEARCH_TT   = "Zeige keine Warnung beim Einloggen an, wenn nicht wenigstens ein Analyse Charakter für ein Handwerk ausgewählt wurde.",

            HIDE_VANILLA_UI_RESEARCHABLE_TEXTURE = "Verstecke ZOs analysierbar Symbol",
            HIDE_VANILLA_UI_RESEARCHABLE_TEXTURE_TOOLTIP = "Verstecke das ZOs Vanilla UI analysierbar Symbol in den Inventar Zeilen",

            SHOW_ICON_EVEN_IF_PROTECTED = "Analyse Symbol trotz Schutz anzeigen",
            SHOW_ICON_EVEN_IF_PROTECTED_TOOLTIP = "Das Analyse Symbol wird in der Inventarzeile immer angezeigt, auch wenn der Gegenstand geschützt wird. Dadurch kann man z.B. den Tooltip auch weiterhin sehen. Der Gegenstand wird jedoch innerhalb von Research Assistant als \'geschützt\' vermerkt und damit bei Analysen nicht berücksichtigt.\n\nDieses Symbol respektiert die anderen Einstellungen wie z.B. \'Analysierte Gegenstände\': D.h. wenn diese Einstellung deaktiviert ist und die Eigenschaft am Gegenstand bereits analysiert wurde, dann wird auch kein Symbol angezeigt!",
            SHOW_ICON_EVEN_IF_PROTECTED_EXCLUDE_NON_TRACKED = "Ausnahme: Nicht überwacht",
            SHOW_ICON_EVEN_IF_PROTECTED_EXCLUDE_NON_TRACKED_TOOLTIP = "Zeige kein Analyse Symbol wenn das Handwerk nicht überwacht wird",

            SETTINGS_HEADER_TOOLTIPS = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES1306),
            SHOW_TYPE_IN_TOOLTIP = "Zeige Typ im Tooltip",
            SHOW_TYPE_IN_TOOLTIP_TOOLTIP = "Zeige den Rüstungs-/Waffen-Typ im Tooltip Text an",
            SHOW_ARMORWEIGHT_IN_TOOLTIP = "Zeige Rüstungs-Art im Tooltip",
            SHOW_ARMORWEIGHT_IN_TOOLTIP_TOOLTIP = "Zeige die Rüstungs-Art (Leight, Mittel, Schwer) im Tooltip",
            SETTINGS_HEADER_VANILLAUI = "Vanilla UI",

            BAG_PRIORITY_HEADER =   "Priorität",
            BAG_PRIORITY =          "Inventar Priorität - \'Analysiere bevorzugt aus...\'",
            BAG_PRIORITY_TT =       "Die Priorität/Reihenfolge der Inventare welche für die Analyse bevorzugt werden.\nBitte die Benutzeroberfläche neu laden nach dem Verändern der Reihenfolger!\n\nDas Inventar an der obersten Stelle der Sortierliste wird \'als bevorzugtes Inventar betrachtet\', das Inventar darunter als 2. bevorzugtes, usw.",
        },
        TOOLTIPS = {
            knownBy = " \'%s\', bekannt bei:\n",
            protected = "-|cFF0000BESCHÜTZT|r-",
            ornate = GetString(SI_ITEMTRAITTYPE10),
            intricate = GetString(SI_ITEMTRAITTYPE9),
            duplicate = "[Analysierer: %s]\nDoppelt%s",
            canResearch = "[Analysierer: %s]\nUnbekannt%s",
            alreadyResearched = "[Analysierer: %s]\n"..GetString(SI_TRADINGHOUSEFEATURECATEGORY3).."%s",
            notScannedWithNeededCharYet = "|cFF0000FEHLER|r: Analysierer [\'%s\'] wurde noch nicht eingeloggt!",
            notTrackedCharName = "|cFFFFFF-Nicht überwacht-|r",
        },
        BAGS = {
            [BAG_BANK] 				= "Bank",
            [BAG_SUBSCRIBER_BANK] 	= "ESO+ Bank",
            [BAG_BACKPACK] 			= "Spieler Inventar",
            [BAG_GUILDBANK] 		= "Gilden Bank",
            [BAG_HOUSE_BANK_ONE]    = "Haus Bank 1",
            [BAG_HOUSE_BANK_TWO]    = "Haus Bank 2",
            [BAG_HOUSE_BANK_THREE]  = "Haus Bank 3",
            [BAG_HOUSE_BANK_FOUR]   = "Haus Bank 4",
            [BAG_HOUSE_BANK_FIVE]   = "Haus Bank 5",
            [BAG_HOUSE_BANK_SIX]    = "Haus Bank 6",
            [BAG_HOUSE_BANK_SEVEN]  = "Haus Bank 7",
            [BAG_HOUSE_BANK_EIGHT]  = "Haus Bank 8",
            [BAG_HOUSE_BANK_NINE]   = "Haus Bank 9",
            [BAG_HOUSE_BANK_TEN]    = "Haus Bank 10",
        },
    },
    ["fr"] = {
        SETTINGS = {
            GENERAL_HEADER = "Options Générales",
            COLORS_HEADER = "Options pour les couleurs",
            HIDDEN_HEADER = "Options d'icônes",
            CHARACTER_HEADER = "L\'artisanat des personnages",

            ICON_LABEL = "Style des icones",
            ICON_TOOLTIP = "Choisir l\'apparence de l\'icone de ResearchAssistant.",

            ICON_SIZE = "Taille de l'icône",
            ICON_SIZE_TOOLTIP = "Choisissez la taille de l'icône de recherche",

            ICON_OFFSET = "Position de l'icône",
            ICON_OFFSET_TOOLTIP = "Choisissez la position de l'icône de recherche sur l'axe X des inventaires",
            RESEARCHABLE_LABEL = "Couleur pour la recherche",
            RESEARCHABLE_TOOLTIP = "Choisir la couleur de l\'icone qui s\'affiche lorsque le trait n\'est pas encore connu.",

            SEPARATE_LW_LABEL = "Séparer artisan du cuir et couturier",
            SEPARATE_LW_TOOLTIP = "Voulez-vous attribuer les recherches d'armures moyennes et d'armures légères à des personnages différents?",

            SEPARATE_SMITH_LABEL = "Séparer armes et armures lourdes",
            SEPARATE_SMITH_TOOLTIP = "Voulez-vous attribuer les recherches d'armes et d'armures lourdes à des personnages différents?",

            DUPLICATE_LABEL = "Couleur pour les doublons",
            DUPLICATE_TOOLTIP = "Choisir la couleur de l\'icone qui s\'affiche lorsque le trait n\'est pas encore connu mais que vous possédez un meilleur candidat à la recherche (vous possédez un autre objet, de moins bonne qualité, avec le m\195\170me trait).",

            RESEARCHED_LABEL = "Couleur des traits connus",
            RESEARCHED_TOOLTIP = "Choisir la couleur de l\'icone qui s\'affiche lorsque le trait est déjà connu.",

            ORNATE_LABEL = "Couleur du trait Orné",
            ORNATE_TOOLTIP = "Choisir la couleur de l\'icone qui s\'affiche pour les objets possédant le trait \"Orné\".",

            INTRICATE_LABEL = "Couleur du trait Complexe",
            INTRICATE_TOOLTIP = "Choisir la couleur de l\'icone qui s\'affiche pour les objets possédant le trait \"Complexe\".",

            SHOW_RESEARCHED_LABEL = "Afficher si déjà connu",
            SHOW_RESEARCHED_TOOLTIP = "Afficher l\'icone de ResearchAssistant si le trait est déjà connu.",

            SHOW_TRAITLESS_LABEL = "Afficher sur les objets sans trait",
            SHOW_TRAITLESS_TOOLTIP = "Affiche une icone même sur les équipements sans trait",

            SHOW_ORNATE_LABEL = "Afficher le trait Orné",
            SHOW_ORNATE_TOOLTIP = "Afficher l\'icone de recherche pour les objets possédant le trait \"Orné\".",

            SHOW_INTRICATE_LABEL = "Afficher le trait Complexe",
            SHOW_INTRICATE_TOOLTIP = "Afficher l\'icone de recherche pour les objets possédant le trait \"Complexe\".",

            SHOW_TOOLTIPS_LABEL = "Afficher l\'infobulle des icones",
            SHOW_TOOLTIPS_TOOLTIP = "Afficher une bulle d\'aide lorsque vous passez le curseur de la souris sur les icones de ResearchAssistant.",

            SHOW_IN_GRID_LABEL = "Afficher avec Grid View?",
            SHOW_IN_GRID_TOOLTIP = "Afficher avec Inventory Grid View Add-on?",

            WS_CHAR_LABEL = "Fabricant d\'armes",
            WS_CHAR_TOOLTIP = "Quel personnage est fabricant d\'armes?\n\'-\' signifie: Aucun",

            BS_CHAR_LABEL = "Fabricant d\'armures",
            BS_CHAR_TOOLTIP = "Quel personnage est fabricant d\'armures?\n\'-\' signifie: Aucun",

            CL_CHAR_LABEL = "Couturier",
            CL_CHAR_TOOLTIP = "Quel personnage est Couturier?\n\'-\' signifie: Aucun",

            LW_CHAR_LABEL = "Artisan du cuir",
            LW_CHAR_TOOLTIP = "Quel personnage est Artisan du cuir?\n\'-\' signifie: Aucun",

            WW_CHAR_LABEL = "Ebéniste",
            WW_CHAR_TOOLTIP = "Quel personnage est ébéniste?\n\'-\' signifie: Aucun",

            JC_CHAR_LABEL = "Fabrication de bijoux",
            JC_CHAR_TOOLTIP = "Quel personnage est bijoutier?\n\'-\' signifie: Aucun",

            USE_ACCOUNTWIDE_RESEARCH_CHARS      = "Paramètres de personnages liés au compte",
            USE_ACCOUNTWIDE_RESEARCH_CHARS_TT   = "Attention: Changer ce paramètre va recharger l\'UI immédiadement!\n\nLorsque cette option est activée, les paramètres de métiers des personnages seront appliqués à tout le compte, pour tous les métiers (paramètre par défaut).\nLorsque cette option est désactivée, vous pouvez définir des paramètres de métiers des personnages différents pour chaque personnage de votre compte.",
            ALLOW_NO_CHARACTER_CHOSEN_FOR_RESEARCH      = "No warning w/o research character selected",
            ALLOW_NO_CHARACTER_CHOSEN_FOR_RESEARCH_TT   = "Do not sbow a warning dialog if you have chosen no character for research of any crafting type.",
            USE_CURRENT_LOGGED_IN_CHAR_FOR_RESEARCH     = "Personnage actuellement connecté recherche tout",
            USE_CURRENT_LOGGED_IN_CHAR_FOR_RESEARCH_TT  = "Utilise le personnage actuellement connecté pour toutes les recherches.\n\nFonctionne seulement quand 'Paramètres de personnages liés au compte' est désactivé!",

            PROTECTION                  = "Protection",
            SKIP_ZOS_MARKED             = "Ignorer les objets verrouilés",
            SKIP_ZOS_MARKED_TOOLTIP     = "Ignore les objets marqués par l'icone du cadenas.\n\nVous pouvez verrouiler un objet depuis votre inventaire: clic droit > Verrouiller.",
            SKIP_FCOIS_MARKED           = "Ignorer les objets FCOIS",
            SKIP_FCOIS_MARKED_TOOLTIP   = "Ignore les objets marqués par une icone FCOIS.\n\nFCO Item Saver est un autre addon pour ESO.",
            SKIP_SETS                   = "Ignorer objets de set",
            SKIP_SETS_TOOLTIP           = "Les objets de set ne seront pas marqués par ResearchAssistant",
            SKIP_SETS_ONLY_MAX_LEVEL    = "Ignorer objets de set: lvl max",
            SKIP_SETS_ONLY_MAX_LEVEL_TOOLTIP = "Ignore seulement les objets de set de niveau maximum et nécessitant des CP. Les objets de niveau inférieur seront marqués.",

            ERROR_CONFIGURE_ADDON = "Veuillez configurer l'addon, choisissez un personnage de recherche dans les paramètres!",
            ERROR_LOGIN_ALL_CHARS = "Connectez-vous à tous vos personnages pour lire leurs données de recherche.",

            HIDE_VANILLA_UI_RESEARCHABLE_TEXTURE = "Masquer l'icone de recherche",
            HIDE_VANILLA_UI_RESEARCHABLE_TEXTURE_TOOLTIP = "Masque l'icone de recherche de l'interface originale.\n\nCela évite de faire doublon avec l'icone ResearchAssistant",

            SHOW_ICON_EVEN_IF_PROTECTED = "Afficher si verrouillé",
            SHOW_ICON_EVEN_IF_PROTECTED_TOOLTIP = "Affiche l'icone de ResearchAssistant, même si l'objet est verrouillé. Vous verrez une icone de cadenas et l'infobulle.\nResearchAssistant ne compte pas les objets verrouillés comme recherchables!\n\nCette icone respecte les autres paramètres d'icones, tel que \'Afficher si déjà connu\'.",
            SHOW_ICON_EVEN_IF_PROTECTED_EXCLUDE_NON_TRACKED = "Exclure verrouillé non suivi",
            SHOW_ICON_EVEN_IF_PROTECTED_EXCLUDE_NON_TRACKED_TOOLTIP = "Ne montre pas l'icone \'Verrouillé\' si le métier n'est pas suivi",

            SETTINGS_HEADER_TOOLTIPS = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES1306),
            SHOW_TYPE_IN_TOOLTIP = "Afficher le type dans l'infobulle",
            SHOW_TYPE_IN_TOOLTIP_TOOLTIP = "Montre le type de l'objet dans l'infobulle",
            SHOW_ARMORWEIGHT_IN_TOOLTIP = "Montrer le poids dans l'infobulle",
            SHOW_ARMORWEIGHT_IN_TOOLTIP_TOOLTIP = "Montre le poids (léger, moyen, lourd) de l'armure dans l'infobulle",
            SETTINGS_HEADER_VANILLAUI = "Interface d'origine",

            BAG_PRIORITY_HEADER =   "Priorité",
            BAG_PRIORITY =          "Priorité sac - \'Recherche préférée de...\'",
            BAG_PRIORITY_TT =       "La priorité/ordre des sacs qui seront utilisés pour la recherche.\nVeuillez recharger l'interface utilisateur après avoir modifié la command!\n\nLe sac en haut de la liste de commande sera \'considéré comme le sac prioritaire\', le sac en dessous sera le suivant, et ainsi de suite.",
        },
        BAGS = {
            [BAG_BANK] 				= "Banque",
            [BAG_SUBSCRIBER_BANK] 	= "Banque ESO+",
            [BAG_BACKPACK] 			= "Inventaire",
            [BAG_GUILDBANK] 		= "Banque de guilde",
            [BAG_HOUSE_BANK_ONE]    = "Banque maison 1",
            [BAG_HOUSE_BANK_TWO]    = "Banque maison 2",
            [BAG_HOUSE_BANK_THREE]  = "Banque maison 3",
            [BAG_HOUSE_BANK_FOUR]   = "Banque maison 4",
            [BAG_HOUSE_BANK_FIVE]   = "Banque maison 5",
            [BAG_HOUSE_BANK_SIX]    = "Banque maison 6",
            [BAG_HOUSE_BANK_SEVEN]  = "Banque maison 7",
            [BAG_HOUSE_BANK_EIGHT]  = "Banque maison 8",
            [BAG_HOUSE_BANK_NINE]   = "Banque maison 9",
            [BAG_HOUSE_BANK_TEN]    = "Banque maison 10",
        },
        TOOLTIPS = {
            knownBy = " \'%s\', connu par:\n",
            protected = "-|cFF0000PROTÉGÉ|r-",
            ornate = GetString(SI_ITEMTRAITTYPE10),
            intricate = GetString(SI_ITEMTRAITTYPE9),
            duplicate = "[Chercheur: %s]\nEn double%s",
            canResearch = "[Chercheur: %s]\nInconnu%s",
            alreadyResearched = "[Chercheur: %s]\n"..GetString(SI_TRADINGHOUSEFEATURECATEGORY3).."%s",
            notScannedWithNeededCharYet = "|cFF0000ERROR|r: Chercheur [\'%s\'] n'était pas encore connecté!",
            notTracked = "Non suivi%s",
            notTrackedCharName = "|cFFFFFF-Non suivi-|r",
        }
    },
    --Spanish
    ["es"] = {
        SETTINGS = {
            GENERAL_HEADER = "Opciones generales",
            COLORS_HEADER = "Parámetros de color",
            HIDDEN_HEADER = "No mostrar parámetros de icono",
            CHARACTER_HEADER = "Parámetros del personaje",

            ICON_LABEL = "Estilo de icono",
            ICON_TOOLTIP = "Elige el icono que quieres mostrar para los objetos investigables.",

            ICON_SIZE = "Tamaño de ícono",
            ICON_SIZE_TOOLTIP = "Elige el tamaño del icono de investigación",

            ICON_OFFSET = "Posición del icono",
            ICON_OFFSET_TOOLTIP = "Elige la posición del icono de investigación en el eje X de los inventarios.",
            SEPARATE_LW_LABEL = "Separar sastrería y peletería",
            SEPARATE_LW_TOOLTIP = "En caso de querer investigar armadura ligera y media por separado con personajes diferentes",

            SEPARATE_SMITH_LABEL = "Separar herrería de armas y armaduras",
            SEPARATE_SMITH_TOOLTIP = "En caso de querer investigar armas y armadura pesada por separado con personajes diferentes",

            RESEARCHABLE_LABEL = "Color para la investigación",
            RESEARCHABLE_TOOLTIP = "Elige el color del icono para los objetos cuyo rasgo no conoces",

            DUPLICATE_LABEL = "Color para objetos duplicados",
            DUPLICATE_TOOLTIP = "Elige el color del icono para los objetos cuyo rasgo no conoces pero ya posees otro candidato mejor para la investigación (objeto de menor calidad con el mismo rasgo)",

            RESEARCHED_LABEL = "Color para rasgos conocidos",
            RESEARCHED_TOOLTIP = "Elige el color del icono para los objetos cuyo rasgo ya conoces",

            ORNATE_LABEL = "Color para objetos ornamentados",
            ORNATE_TOOLTIP = "Elige el color del icono para los objetos con el rasgo ornamentado",

            INTRICATE_LABEL = "Color para objetos intrincados",
            INTRICATE_TOOLTIP = "Elige el color del icono para los objetos con el rasgo intrincado",

            SHOW_RESEARCHED_LABEL = "Mostrar investigados",
            SHOW_RESEARCHED_TOOLTIP = "Mostrar el icono para los objetos cuyo rasgo ya conoces",

            SHOW_TRAITLESS_LABEL = "Mostrar sin rasgo",
            SHOW_TRAITLESS_TOOLTIP = "Mostrar el icono para los objetos sin rasgo",

            SHOW_ORNATE_LABEL = "Mostrar ornamentado",
            SHOW_ORNATE_TOOLTIP = "Siempre mostrar el icono para los objetos ornamentados",

            SHOW_INTRICATE_LABEL = "Mostrar intrincado",
            SHOW_INTRICATE_TOOLTIP = "Siempre mostrar el icono para los objetos intrincados",

            SHOW_TOOLTIPS_LABEL = "Mostrar ayuda",
            SHOW_TOOLTIPS_TOOLTIP = "Muestra una ventana de información al pasar el cursor sobre el icono de Research Assistant del objeto (recomendado desactivar)",

            SHOW_IN_GRID_LABEL = "Mostrar con Grid View",
            SHOW_IN_GRID_TOOLTIP = "Mostrar los iconos de Research Assistant con el addon Inventory Grid View (ignorar si no usas dicho addon)",

            WS_CHAR_LABEL = "Herrero de armas",
            WS_CHAR_TOOLTIP = "Elige tu personaje fabricante de armas de metal.\n\'-\' significa: Ninguno",

            BS_CHAR_LABEL = "Herrero de armaduras pesadas",
            BS_CHAR_TOOLTIP = "Elige tu personaje fabricante de armaduras pesadas.\n\'-\' significa: Ninguno",

            LW_CHAR_LABEL = "Peletero",
            LW_CHAR_TOOLTIP = "Elige tu personaje fabricante de armaduras medias.\n\'-\' significa: Ninguno",

            CL_CHAR_LABEL = "Sastre",
            CL_CHAR_TOOLTIP = "Elige tu personaje fabricante de armaduras ligeras.\n\'-\' significa: Ninguno",

            WW_CHAR_LABEL = "Carpintero",
            WW_CHAR_TOOLTIP = "Elige tu personaje fabricante de escudos y armas de madera.\n\'-\' significa: Ninguno",

            JC_CHAR_LABEL = "Elaboración de joyas",
            JC_CHAR_TOOLTIP = "Elige tu personaje fabricante de joyería.\n\'-\' significa: Ninguno",

            USE_ACCOUNTWIDE_RESEARCH_CHARS      = "Mismos personajes de investigación en toda la cuenta",
            USE_ACCOUNTWIDE_RESEARCH_CHARS_TT   = "Atención: Cambiar este ajuste recargará la interfaz automáticamente!\n\nCon esta opción activada todos los personajes de esta cuenta tendrán los mismos personajes seleccionados para cada tipo de artesanía (opción por defecto).\nCon esta opción desactivada puedes especificar para cada personaje un conjunto de personajes diferentes para cada tipo de artesanía.",
            ALLOW_NO_CHARACTER_CHOSEN_FOR_RESEARCH      = "Desactivar aviso de artesanía sin personaje asignado",
            ALLOW_NO_CHARACTER_CHOSEN_FOR_RESEARCH_TT   = "No mostrar una ventana de aviso si no tienes seleccionado ningún personaje para algún tipo de artesanía.",
            USE_CURRENT_LOGGED_IN_CHAR_FOR_RESEARCH     = "Utilizar personaje actual para toda investigación.",
            USE_CURRENT_LOGGED_IN_CHAR_FOR_RESEARCH_TT  = "Utilizar el personaje con el que está conectado para la investigación de todas las artesanías.\n\nSolo funciona si la opción 'Mismos personajes de investigación en toda la cuenta' está desactivada.",

            PROTECTION                  = "Protección",
            SKIP_ZOS_MARKED             = "Excluir marcados por ZO",
            SKIP_ZOS_MARKED_TOOLTIP     = "Exlcuir objetos del escaneo de investigables y de los marcadores del asistente de investigación si el objeto está marcado con un icono de bloqueo ZO.",
            SKIP_FCOIS_MARKED           = "Excluir marcados por FCOItemSaver",
            SKIP_FCOIS_MARKED_TOOLTIP   = "Exlcuir objetos del escaneo de investigables y de los marcadores del asistente de investigación si el objeto está marcado con iconos FCOIS.\nExcepción: Si el icono de investigación de FCOIS está habilitado!",
            SKIP_SETS                   = "Excluir conjuntos",
            SKIP_SETS_TOOLTIP           = "Excluir objetos que forman parte de un conjunto y no marcarlos con ningún asistente de investigación",
            SKIP_SETS_ONLY_MAX_LEVEL    = "Excluir conjuntos: solo nivel máximo",
            SKIP_SETS_ONLY_MAX_LEVEL_TOOLTIP = "Excluir objetos que forman parte de un conjunto solo si son de nivel máximo y puntos de campeón, y marcar los de nivel inferior para investigación.",

            ERROR_CONFIGURE_ADDON = "¡Configura el AddOn, elige un personaje de investigación en la configuración!",
            ERROR_LOGIN_ALL_CHARS = "Inicia sesión con todos tus personajes para leer sus datos de investigación.",

            HIDE_VANILLA_UI_RESEARCHABLE_TEXTURE = "Esconder textura de interfaz vanilla de ZO.",
            HIDE_VANILLA_UI_RESEARCHABLE_TEXTURE_TOOLTIP = "No mostrar la textura de la interfaz por defecto de ZO en las líneas del inventario.",

            SHOW_ICON_EVEN_IF_PROTECTED = "Mostrar icono en objetos protegidos",
            SHOW_ICON_EVEN_IF_PROTECTED_TOOLTIP = "Mostrar siempre el icono de investigación, incluso en objetos que estén marcados como protegidos. De esta manera puedes ver el icono y su descripción emergente. Los asistentes de investigación no tienen en cuenta estos objetos como investigables!\n\nEste icono respetará otros ajustes como \'Mostrar investigados\': Si está opción está desactivada y el rasgo del objeto ya ha sido investigado, el icono del asistente no se mostrará!",
            SHOW_ICON_EVEN_IF_PROTECTED_EXCLUDE_NON_TRACKED = "Excluir no rastreados",
            SHOW_ICON_EVEN_IF_PROTECTED_EXCLUDE_NON_TRACKED_TOOLTIP = "No mostrar el icono de protegido si no se rastrea la fabricación.",

            SETTINGS_HEADER_TOOLTIPS = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES1306),
            SHOW_TYPE_IN_TOOLTIP = "Mostrar tipo en la descripción emergente",
            SHOW_TYPE_IN_TOOLTIP_TOOLTIP = "Mostrar el tipo de arma/armadura en el texto de la descripción emergente",
            SHOW_ARMORWEIGHT_IN_TOOLTIP = "Mostrar peso de la armadura en la descripción emergente",
            SHOW_ARMORWEIGHT_IN_TOOLTIP_TOOLTIP = "Mostrar el peso de la armadura (ligera, media, pesada) en el texto de la descripción emergente",
            SETTINGS_HEADER_VANILLAUI = "Interfaz Vanilla",

            BAG_PRIORITY_HEADER =   "Prioridad",
            BAG_PRIORITY =          "Prioridad de bolsa - \'Se prefiere investigación de...\'",
            BAG_PRIORITY_TT =       "El orden o prioridad de las bolsas que se utilizarán para investigación.\nPorfavor recargue la interfaz después de cambiar este orden!\n\nLa bolsa de arriba de la lista será considerada \'la más priorizada\', la segunda será la siguiente, y así en adelante.",
        },
        BAGS = {
            [BAG_BANK] 				= "Banco",
            [BAG_SUBSCRIBER_BANK] 	= "Banco ESO+",
            [BAG_BACKPACK] 			= "Inventario",
            [BAG_GUILDBANK] 		= "Banco del gremio",
            [BAG_HOUSE_BANK_ONE]    = "Banco de la casa 1",
            [BAG_HOUSE_BANK_TWO]    = "Banco de la casa 2",
            [BAG_HOUSE_BANK_THREE]  = "Banco de la casa 3",
            [BAG_HOUSE_BANK_FOUR]   = "Banco de la casa 4",
            [BAG_HOUSE_BANK_FIVE]   = "Banco de la casa 5",
            [BAG_HOUSE_BANK_SIX]    = "Banco de la casa 6",
            [BAG_HOUSE_BANK_SEVEN]  = "Banco de la casa 7",
            [BAG_HOUSE_BANK_EIGHT]  = "Banco de la casa 8",
            [BAG_HOUSE_BANK_NINE]   = "Banco de la casa 9",
            [BAG_HOUSE_BANK_TEN]    = "Banco de la casa 10",
        },
        TOOLTIPS = {
            knownBy = " \'%s\', conocido por:\n",
            protected = "-|cFF0000PROTEGIDO|r-",
            ornate = "Ornamentado",
            intricate = "Intrincado",
            duplicate = "[Investigador: %s]\nDuplicado%s",
            canResearch = "[Investigador: %s]\nDesconocido%s",
            alreadyResearched = "[Investigador: %s]\nRasgo%s",
            notScannedWithNeededCharYet = "|cFF0000ERROR|r: ¡El investigador [\'%s\'] aún no había iniciado sesión!",
            notTracked = "No rastreado%s",
            notTrackedCharName = "|cFFFFFF-No rastreado-|r",
        },
    },
    --Japanese
    ["jp"] = {
        SETTINGS = {
            GENERAL_HEADER = "General Options",
            COLORS_HEADER = "Color Options",
            HIDDEN_HEADER = "Hide Icon Options",
            CHARACTER_HEADER = "Tracked Character Options",

            ICON_LABEL = "Research icon",
            ICON_TOOLTIP = "Choose which icon to display as your research assistant.",

            ICON_SIZE = "Icon size",
            ICON_SIZE_TOOLTIP = "Choose the size of the research icon",

            ICON_OFFSET = "Icon position",
            ICON_OFFSET_TOOLTIP = "Choose the position of the research icon on the X-axis of inventories",
            SEPARATE_LW_LABEL = "Separate leatherworking from tailoring?",
            SEPARATE_LW_TOOLTIP = "Do you want to track medium armor and light armor research for separate characters?",

            SEPARATE_SMITH_LABEL = "Separate weaponsmithing from blacksmithing?",
            SEPARATE_SMITH_TOOLTIP = "Do you want to track weaponsmithing and armorsmithing research for separate characters?",

            RESEARCHABLE_LABEL = "Researchable trait color",
            RESEARCHABLE_TOOLTIP = "What color should the research assistant icon be if the trait is researchable?",

            DUPLICATE_LABEL = "Duplicate researchable trait color",
            DUPLICATE_TOOLTIP = "What color should the research assistant icon be if the item is researchable but there is a better candidate for research?",

            RESEARCHED_LABEL = "Already researched color",
            RESEARCHED_TOOLTIP = "What color should the research assistant icon be if the item is already researched?",

            ORNATE_LABEL = "Ornate item color",
            ORNATE_TOOLTIP = "What color should the icon be for an ornate item?",

            INTRICATE_LABEL = "Intricate item color",
            INTRICATE_TOOLTIP = "What color should the icon be for an intricate item?",

            SHOW_RESEARCHED_LABEL = "Show researched icon?",
            SHOW_RESEARCHED_TOOLTIP = "Should the icon show up for traits that you know?",

            SHOW_TRAITLESS_LABEL = "Show researched icon on traitless?",
            SHOW_TRAITLESS_TOOLTIP = "Should the icon show up for traitless equipment?",

            SHOW_ORNATE_LABEL = "Always show Ornate?",
            SHOW_ORNATE_TOOLTIP = "Should Ornate be shown for untracked skills?",

            SHOW_INTRICATE_LABEL = "Always show Intricate?",
            SHOW_INTRICATE_TOOLTIP = "Should Intricate be shown for untracked skills?",

            SHOW_TOOLTIPS_LABEL = "Show icon tooltips?",
            SHOW_TOOLTIPS_TOOLTIP = "Should tooltips tell you what they are? (recommended OFF)",

            SHOW_IN_GRID_LABEL = "Show in Grid View?",
            SHOW_IN_GRID_TOOLTIP = "Should the research assistant icon show up with Inventory Grid View toggled on? (Ignore this if you don't use Inventory Grid View)",

            WS_CHAR_LABEL = "Weaponsmithing Character",
            WS_CHAR_TOOLTIP = "Which character is your weaponsmithing character?\n\'-\' means: None",

            BS_CHAR_LABEL = "Blacksmithing Character",
            BS_CHAR_TOOLTIP = "Which character is your blacksmithing character?\n\'-\' means: None",

            LW_CHAR_LABEL = "Leatherworking Character",
            LW_CHAR_TOOLTIP = "Which character is your leatherworking character?\n\'-\' means: None",

            CL_CHAR_LABEL = "Clothier Character",
            CL_CHAR_TOOLTIP = "Which character is your clothier character?\n\'-\' means: None",

            WW_CHAR_LABEL = "Woodworking Character",
            WW_CHAR_TOOLTIP = "Which character is your woodworking character?\n\'-\' means: None",

            JC_CHAR_LABEL = "Jewelry crafting Character",
            JC_CHAR_TOOLTIP = "Which character is your jewelry crafting character?\n\'-\' means: None",

            USE_ACCOUNTWIDE_RESEARCH_CHARS      = "Account-wide same research characters",
            USE_ACCOUNTWIDE_RESEARCH_CHARS_TT   = "Attention: Change of this option will reload the UI directly!\n\nWith this option enabled all your characters of the current acocunt will use the same research characters for each crafting type (default setting).\nWith this option disabled you can specify different research characters for each crafting type at each of your characters.",

            PROTECTION                  = "Protection",
            SKIP_ZOS_MARKED             = "Skip ZOs marked",
            SKIP_ZOS_MARKED_TOOLTIP     = "Skip items at the researchable scans and Research Assistant markers if the item is marked with the ZOs lock icon.",
            SKIP_FCOIS_MARKED           = "Skip FCOItemSaver marked",
            SKIP_FCOIS_MARKED_TOOLTIP   = "Skip items at the researchable scans and Research Assistant markers if the item is marked with the FCOIS icons.\nExclusion: The research marker icon of FCOIS is allowed!",

            ERROR_CONFIGURE_ADDON = "Please configure the addon, choose a research character in the settings!",
            ERROR_LOGIN_ALL_CHARS = "Login all your characters to read their research data.",
        },
        BAGS = {
            [BAG_BANK] 				= "銀行",
            [BAG_SUBSCRIBER_BANK] 	= "ESO+ 銀行",
            [BAG_BACKPACK] 			= "在庫品",
            [BAG_GUILDBANK] 		= "ギルド銀行",
            [BAG_HOUSE_BANK_ONE]    = "ハウスバンク 1",
            [BAG_HOUSE_BANK_TWO]    = "ハウスバンク 2",
            [BAG_HOUSE_BANK_THREE]  = "ハウスバンク 3",
            [BAG_HOUSE_BANK_FOUR]   = "ハウスバンク 4",
            [BAG_HOUSE_BANK_FIVE]   = "ハウスバンク 5",
            [BAG_HOUSE_BANK_SIX]    = "ハウスバンク 6",
            [BAG_HOUSE_BANK_SEVEN]  = "ハウスバンク 7",
            [BAG_HOUSE_BANK_EIGHT]  = "ハウスバンク 8",
            [BAG_HOUSE_BANK_NINE]   = "ハウスバンク 9",
            [BAG_HOUSE_BANK_TEN]    = "ハウスバンク 10",
        },
        TOOLTIPS = {
            knownBy = " \'%s\',すでに知られている:\n",
            protected = "-|cFF0000保護|r-",
            ornate = GetString(SI_ITEMTRAITTYPE10),
            intricate = GetString(SI_ITEMTRAITTYPE9),
            duplicate = "[研究者: %s]\n複製%s",
            canResearch = "[研究者: %s]\n未知の%s",
            alreadyResearched = "[研究者: %s]\n"..GetString(SI_TRADINGHOUSEFEATURECATEGORY3).."%s",
            notScannedWithNeededCharYet = "|cFF0000ERROR|r: 研究者 [\'%s\'] はまだログインしていません!",
            notTracked = "追跡されていない%s",
            notTrackedCharName = "|cFFFFFF-追跡されていない-|r",
        }
    },
    --Russian
    ["ru"] = {
        SETTINGS = {
            GENERAL_HEADER = "General Options",
            COLORS_HEADER = "Color Options",
            HIDDEN_HEADER = "Hide Icon Options",
            CHARACTER_HEADER = "Tracked Character Options",

            ICON_LABEL = "Research icon",
            ICON_TOOLTIP = "Choose which icon to display as your research assistant.",

            ICON_SIZE = "Icon size",
            ICON_SIZE_TOOLTIP = "Choose the size of the research icon",

            ICON_OFFSET = "Icon position",
            ICON_OFFSET_TOOLTIP = "Choose the position of the research icon on the X-axis of inventories",
            SEPARATE_LW_LABEL = "Separate leatherworking from tailoring?",
            SEPARATE_LW_TOOLTIP = "Do you want to track medium armor and light armor research for separate characters?",

            SEPARATE_SMITH_LABEL = "Separate weaponsmithing from blacksmithing?",
            SEPARATE_SMITH_TOOLTIP = "Do you want to track weaponsmithing and armorsmithing research for separate characters?",

            RESEARCHABLE_LABEL = "Researchable trait color",
            RESEARCHABLE_TOOLTIP = "What color should the research assistant icon be if the trait is researchable?",

            DUPLICATE_LABEL = "Duplicate researchable trait color",
            DUPLICATE_TOOLTIP = "What color should the research assistant icon be if the item is researchable but there is a better candidate for research?",

            RESEARCHED_LABEL = "Already researched color",
            RESEARCHED_TOOLTIP = "What color should the research assistant icon be if the item is already researched?",

            ORNATE_LABEL = "Ornate item color",
            ORNATE_TOOLTIP = "What color should the icon be for an ornate item?",

            INTRICATE_LABEL = "Intricate item color",
            INTRICATE_TOOLTIP = "What color should the icon be for an intricate item?",

            SHOW_RESEARCHED_LABEL = "Show researched icon?",
            SHOW_RESEARCHED_TOOLTIP = "Should the icon show up for traits that you know?",

            SHOW_TRAITLESS_LABEL = "Show researched icon on traitless?",
            SHOW_TRAITLESS_TOOLTIP = "Should the icon show up for traitless equipment?",

            SHOW_ORNATE_LABEL = "Always show Ornate?",
            SHOW_ORNATE_TOOLTIP = "Should Ornate be shown for untracked skills?",

            SHOW_INTRICATE_LABEL = "Always show Intricate?",
            SHOW_INTRICATE_TOOLTIP = "Should Intricate be shown for untracked skills?",

            SHOW_TOOLTIPS_LABEL = "Show icon tooltips?",
            SHOW_TOOLTIPS_TOOLTIP = "Should tooltips tell you what they are? (recommended OFF)",

            SHOW_IN_GRID_LABEL = "Show in Grid View?",
            SHOW_IN_GRID_TOOLTIP = "Should the research assistant icon show up with Inventory Grid View toggled on? (Ignore this if you don't use Inventory Grid View)",

            WS_CHAR_LABEL = "Weaponsmithing Character",
            WS_CHAR_TOOLTIP = "Which character is your weaponsmithing character?\n\'-\' means: None",

            BS_CHAR_LABEL = "Blacksmithing Character",
            BS_CHAR_TOOLTIP = "Which character is your blacksmithing character?\n\'-\' means: None",

            LW_CHAR_LABEL = "Leatherworking Character",
            LW_CHAR_TOOLTIP = "Which character is your leatherworking character?\n\'-\' means: None",

            CL_CHAR_LABEL = "Clothier Character",
            CL_CHAR_TOOLTIP = "Which character is your clothier character?\n\'-\' means: None",

            WW_CHAR_LABEL = "Woodworking Character",
            WW_CHAR_TOOLTIP = "Which character is your woodworking character?\n\'-\' means: None",

            JC_CHAR_LABEL = "Jewelry crafting Character",
            JC_CHAR_TOOLTIP = "Which character is your jewelry crafting character?\n\'-\' means: None",

            USE_ACCOUNTWIDE_RESEARCH_CHARS      = "Account-wide same research characters",
            USE_ACCOUNTWIDE_RESEARCH_CHARS_TT   = "Attention: Change of this option will reload the UI directly!\n\nWith this option enabled all your characters of the current acocunt will use the same research characters for each crafting type (default setting).\nWith this option disabled you can specify different research characters for each crafting type at each of your characters.",
            ALLOW_NO_CHARACTER_CHOSEN_FOR_RESEARCH      = "No warning w/o research character selected",
            ALLOW_NO_CHARACTER_CHOSEN_FOR_RESEARCH_TT   = "Do not sbow a warning dialog if you have chosen no character for research of any crafting type.",
            USE_CURRENT_LOGGED_IN_CHAR_FOR_RESEARCH     = "Use logged in char for all researches",
            USE_CURRENT_LOGGED_IN_CHAR_FOR_RESEARCH_TT  = "Use the currently logged in character for all researches and crafting types.\n\nOnly works if the 'account-wide same research characters' setting is disabled!",

            PROTECTION                  = "Protection",
            SKIP_ZOS_MARKED             = "Skip ZOs marked",
            SKIP_ZOS_MARKED_TOOLTIP     = "Skip items at the researchable scans and Research Assistant markers if the item is marked with the ZOs lock icon.",
            SKIP_FCOIS_MARKED           = "Skip FCOItemSaver marked",
            SKIP_FCOIS_MARKED_TOOLTIP   = "Skip items at the researchable scans and Research Assistant markers if the item is marked with the FCOIS icons.\nExclusion: The research marker icon of FCOIS is allowed!",
            SKIP_SETS                   = "Skip set items",
            SKIP_SETS_TOOLTIP           = "Skip items which belong to a set and do not mark them with any ResearchAssistant",
            SKIP_SETS_ONLY_MAX_LEVEL    = "Skip sets: Max level only",
            SKIP_SETS_ONLY_MAX_LEVEL_TOOLTIP = "Skip the set items with the maximum level and CPs only, and mark lower levels for research.",

            ERROR_CONFIGURE_ADDON = "Please configure the addon, choose a research character in the settings!",
            ERROR_LOGIN_ALL_CHARS = "Login all your characters to read their research data.",

            HIDE_VANILLA_UI_RESEARCHABLE_TEXTURE = "Hide ZOs vanilla UI researchable texture",
            HIDE_VANILLA_UI_RESEARCHABLE_TEXTURE_TOOLTIP = "Hide the ZOs vanilla UI researchable texture at the inventory rows",

            SHOW_ICON_EVEN_IF_PROTECTED = "Show research icon if protected",
            SHOW_ICON_EVEN_IF_PROTECTED_TOOLTIP = "Always show the research icon, even though the item is protected. This way you are able to see the icon and it's tooltips. Research Assistants does not count these protected items as researchable!\n\nThis icon will respect the other settings like e.g. \'Show researched icon?\': If this is disabled and the item's trait was researched already the research assistant icon wont show!",
            SHOW_ICON_EVEN_IF_PROTECTED_EXCLUDE_NON_TRACKED = "Exclude non tracked",
            SHOW_ICON_EVEN_IF_PROTECTED_EXCLUDE_NON_TRACKED_TOOLTIP = "Do not show the protected icon if the crafting is not tracked",

            SETTINGS_HEADER_TOOLTIPS = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES1306),
            SHOW_TYPE_IN_TOOLTIP = "Show type in tooltip",
            SHOW_TYPE_IN_TOOLTIP_TOOLTIP = "Show the armor/weapon type in the tooltip text",
            SHOW_ARMORWEIGHT_IN_TOOLTIP = "Show armor weight in tooltip",
            SHOW_ARMORWEIGHT_IN_TOOLTIP_TOOLTIP = "Show the armor weight (light, medium, heavy) in the tooltip text",
            SETTINGS_HEADER_VANILLAUI = "Vanilla UI",
        },
        BAGS = {
            [BAG_BANK] 				= "Банк",
            [BAG_SUBSCRIBER_BANK] 	= "ESO+ Банк",
            [BAG_BACKPACK] 			= "Инвентарь",
            [BAG_GUILDBANK] 		= "Банк гильдии",
            [BAG_HOUSE_BANK_ONE]    = "Банк дома 1",
            [BAG_HOUSE_BANK_TWO]    = "Банк дома 2",
            [BAG_HOUSE_BANK_THREE]  = "Банк дома 3",
            [BAG_HOUSE_BANK_FOUR]   = "Банк дома 4",
            [BAG_HOUSE_BANK_FIVE]   = "Банк дома 5",
            [BAG_HOUSE_BANK_SIX]    = "Банк дома 6",
            [BAG_HOUSE_BANK_SEVEN]  = "Банк дома 7",
            [BAG_HOUSE_BANK_EIGHT]  = "Банк дома 8",
            [BAG_HOUSE_BANK_NINE]   = "Банк дома 9",
            [BAG_HOUSE_BANK_TEN]    = "Банк дома 10",
        },
        TOOLTIPS = {
            knownBy = " \'%s\', известен:\n",
            protected = "-|cFF0000Защищен|r-",
            ornate = GetString(SI_ITEMTRAITTYPE10),
            intricate = GetString(SI_ITEMTRAITTYPE9),
            duplicate = "[Изучающий: %s]\nДублирующая%s",
            canResearch = "[Изучающий: %s]\nНеизвестная%s",
            alreadyResearched = "[Изучающий: %s]\nОсобенноость%s",
            notScannedWithNeededCharYet = "|cFF0000Ошибка|r: Изучающий [\'%s\'] еще не логинился!",
            notTrackedCharName = "|cFFFFFF-Не отслеживается-|r",
        }
    },
    --Chinese
    ["zh"] = {
        SETTINGS = {
            GENERAL_HEADER = "一般选项",
            COLORS_HEADER = "颜色选项",
            HIDDEN_HEADER = "隐藏图标选项",
            CHARACTER_HEADER = "追踪角色选项",

            ICON_LABEL = "图标类型",
            ICON_TOOLTIP = "选择研究助手所显示的图标样式类型",

            ICON_SIZE = "图标尺寸",
            ICON_SIZE_TOOLTIP = "选择研究图标的大小",

            ICON_OFFSET = "图标位置",
            ICON_OFFSET_TOOLTIP = "选择研究图标在物品栏装备列表X轴上的位置",
            SEPARATE_LW_LABEL = "是否从制衣研究中区分出皮革研究？",
            SEPARATE_LW_TOOLTIP = "您是否想分别区分出轻型护甲研究和中型护甲研究的角色？",

            SEPARATE_SMITH_LABEL = "是否从锻造研究中区分出武器研究？",
            SEPARATE_SMITH_TOOLTIP = "您是否想分别区分出锻甲研究和武器研究的角色？",

            RESEARCHABLE_LABEL = "可研究特质颜色",
            RESEARCHABLE_TOOLTIP = "如果当前装备特质是可研究的，图标是什么颜色？",

            DUPLICATE_LABEL = "重复的可研究特质颜色",
            DUPLICATE_TOOLTIP = "如果当前装备特质是可研究的，并且比同类型装备特质效果更好，图标是什么颜色？",

            RESEARCHED_LABEL = "已完成研究特质颜色",
            RESEARCHED_TOOLTIP = "如果当前装备特质已经研究过，图标是什么颜色？",

            ORNATE_LABEL = "华丽物品颜色",
            ORNATE_TOOLTIP = "华丽物品的图标是什么颜色？",

            INTRICATE_LABEL = "精巧物品颜色",
            INTRICATE_TOOLTIP = "精巧物品的图标是什么颜色？",

            SHOW_RESEARCHED_LABEL = "是否显示已研究特质图标？",
            SHOW_RESEARCHED_TOOLTIP = "图标是否显示您已经研究的特质？",

            SHOW_TRAITLESS_LABEL = "是否显示无特质物品的研究助手图标？",
            SHOW_TRAITLESS_TOOLTIP = "是否显示无特质物品的研究助手图标？",

            SHOW_ORNATE_LABEL = "是否总是显示华丽物品的研究助手图标？",
            SHOW_ORNATE_TOOLTIP = "是否总是显示华丽物品的研究助手图标？",

            SHOW_INTRICATE_LABEL = "是否总是显示精巧物品的研究助手图标？",
            SHOW_INTRICATE_TOOLTIP = "是否总是显示精巧物品的研究助手图标？",

            SHOW_TOOLTIPS_LABEL = "是否显示图标提示框？",
            SHOW_TOOLTIPS_TOOLTIP = "当鼠标移至研究助手图标上时是否显示提示框？（建议关闭）",

            SHOW_IN_GRID_LABEL = "是否在物品栏网格视图中显示？",
            SHOW_IN_GRID_TOOLTIP = "研究助手图标是否应该在打开物品栏网格视图时显示？(如果您未使用Inventory Grid View插件，请忽略此选项)",

            WS_CHAR_LABEL = "武器匠角色",
            WS_CHAR_TOOLTIP = "哪个角色是您的武器研究角色？\n\'-\' 意思是: 未选择角色",

            BS_CHAR_LABEL = "锻造角色",
            BS_CHAR_TOOLTIP = "哪个角色是您的锻造研究角色？\n\'-\' 意思是: 未选择角色",

            LW_CHAR_LABEL = "皮革匠角色",
            LW_CHAR_TOOLTIP = "哪个角色是您的皮革研究角色？\n\'-\' 意思是: 未选择角色",

            CL_CHAR_LABEL = "制衣匠角色",
            CL_CHAR_TOOLTIP = "哪个角色是您的制衣研究角色？\n\'-\' 意思是: 未选择角色",

            WW_CHAR_LABEL = "木工角色",
            WW_CHAR_TOOLTIP = "哪个角色是您的木工研究角色？\n\'-\' 意思是: 未选择角色",

            JC_CHAR_LABEL = "珠宝匠角色",
            JC_CHAR_TOOLTIP = "哪个角色是您的珠宝研究角色？\n\'-\' 意思是: 未选择角色",

            USE_ACCOUNTWIDE_RESEARCH_CHARS      = "玩家账户范围内所有角色使用同一个研究角色",
            USE_ACCOUNTWIDE_RESEARCH_CHARS_TT   = "注意：更改此选项将直接重新加载用户界面！\n\n启用此选项后，您当前账户的所有角色将对每种制作类型使用相同的研究角色（默认设置）\n禁用此选项后，您可以在每个角色上为每种制作类型指定不同的研究角色。",
            ALLOW_NO_CHARACTER_CHOSEN_FOR_RESEARCH      = "未选择研究角色则不显示警告",
            ALLOW_NO_CHARACTER_CHOSEN_FOR_RESEARCH_TT   = "如果您没有选择用于任何制作类型的研究的角色，请不要打开警告对话框。",
            USE_CURRENT_LOGGED_IN_CHAR_FOR_RESEARCH     = "使玩家当前登录角色用于所有研究",
            USE_CURRENT_LOGGED_IN_CHAR_FOR_RESEARCH_TT  = "对所有研究和制作类型使用当前玩家登录的角色。\n\n仅在禁用“玩家账户范围内所有角色使用同一个研究角色”选项时才有效！",

            PROTECTION                  = "受保护",
            SKIP_ZOS_MARKED             = "跳过锁定标记",
            SKIP_ZOS_MARKED_TOOLTIP     = "如果物品标有锁定图标，则在可研究物品扫描和研究助手标记处跳过该物品。",
            SKIP_FCOIS_MARKED           = "跳过FCO Item Saver插件的标记",
            SKIP_FCOIS_MARKED_TOOLTIP   = "如果物品标有FCOIS插件的图标，则跳过可研究物品扫描和研究助手标记处的物品。\n排除：FCOIS的研究标记图标是被允许的！",
            SKIP_SETS                   = "跳过集合物品",
            SKIP_SETS_TOOLTIP           = "跳过属于一个集合的物品，不要用任何研究助手标记它们",
            SKIP_SETS_ONLY_MAX_LEVEL    = "跳过集合：仅限最高等级",
            SKIP_SETS_ONLY_MAX_LEVEL_TOOLTIP = "跳过仅具有最高等级和CP的集合物品，并标记相对较低等级物品以供研究。",

            ERROR_CONFIGURE_ADDON = "请首先配置本插件选项，在设置中选择一个研究角色！",
            ERROR_LOGIN_ALL_CHARS = "登录您账户的所有角色以读取他们的研究数据。",

            HIDE_VANILLA_UI_RESEARCHABLE_TEXTURE = "隐藏游戏默认可研究特质的图标",
            HIDE_VANILLA_UI_RESEARCHABLE_TEXTURE_TOOLTIP = "隐藏玩家物品栏装备列表中，游戏默认自带可研究特质的放大镜图标",

            SHOW_ICON_EVEN_IF_PROTECTED = "如果物品受保护是否显示研究图标？",
            SHOW_ICON_EVEN_IF_PROTECTED_TOOLTIP = "始终显示研究助手图标，即使物品受到保护。这样您就可以看到图标和它的提示框。研究助手不再将这些受保护的物品视为可研究的物品！\n\n此图标将遵守其他选项，例如\'是否显示已研究特质图标？\': 如果禁用此选项并且已经研究了物品的特质，则不会显示研究助手图标！",
            SHOW_ICON_EVEN_IF_PROTECTED_EXCLUDE_NON_TRACKED = "排除未追踪",
            SHOW_ICON_EVEN_IF_PROTECTED_EXCLUDE_NON_TRACKED_TOOLTIP = "如果未追踪制作，则不显示受保护的图标",

            SETTINGS_HEADER_TOOLTIPS = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES1306),
            SHOW_TYPE_IN_TOOLTIP = "在提示框中显示装备种类",
            SHOW_TYPE_IN_TOOLTIP_TOOLTIP = "在提示框中显示武器/护甲种类",
            SHOW_ARMORWEIGHT_IN_TOOLTIP = "在提示框中显示装备重量",
            SHOW_ARMORWEIGHT_IN_TOOLTIP_TOOLTIP = "在提示框中显示装备重量（轻型，中型，重型）",
            SETTINGS_HEADER_VANILLAUI = "默认UI",

            BAG_PRIORITY_HEADER =   "优先级",
            BAG_PRIORITY =          "背包优先级 - \'研究首选自...\'",
            BAG_PRIORITY_TT =       "用于研究的背包的优先级/顺序。\n更改此顺序后请重新加载UI！\n\n顺序列表顶部的背包将被视为\'最首要的一个\', 之后的背包将是下一个，依此类推。",
        },
        TOOLTIPS = {
            knownBy = " \'%s\', 研究自:\n",
            protected = "-|cFF0000受保护的|r-",
            ornate = GetString(SI_ITEMTRAITTYPE10),
            intricate = GetString(SI_ITEMTRAITTYPE9),
            duplicate = "[研究者: %s]\n重复的可研究特质%s",
            canResearch = "[研究者: %s]\n未研究%s",
            alreadyResearched = "[研究者: %s]\n"..GetString(SI_TRADINGHOUSEFEATURECATEGORY3).."%s",
            notScannedWithNeededCharYet = "|cFF0000错误|r: 研究者 [\'%s\'] 还没有登录！",
            notTrackedCharName = "|cFFFFFF-未追踪到-|r",
        },
        BAGS = {
            [BAG_BANK] 				= "银行",
            [BAG_SUBSCRIBER_BANK] 	= "ESO PLUS银行",
            [BAG_BACKPACK] 			= "玩家物品栏",
            [BAG_GUILDBANK] 		= "公会银行",
            [BAG_HOUSE_BANK_ONE]    = "住宅保险箱 1",
            [BAG_HOUSE_BANK_TWO]    = "住宅保险箱 2",
            [BAG_HOUSE_BANK_THREE]  = "住宅保险箱 3",
            [BAG_HOUSE_BANK_FOUR]   = "住宅保险箱 4",
            [BAG_HOUSE_BANK_FIVE]   = "住宅保险箱 5",
            [BAG_HOUSE_BANK_SIX]    = "住宅保险箱 6",
            [BAG_HOUSE_BANK_SEVEN]  = "住宅保险箱 7",
            [BAG_HOUSE_BANK_EIGHT]  = "住宅保险箱 8",
            [BAG_HOUSE_BANK_NINE]   = "住宅保险箱 9",
            [BAG_HOUSE_BANK_TEN]    = "住宅保险箱 10",
        },
        armorLight = GetString(SI_VISUALARMORTYPE1),
        armorMedium = GetString(SI_VISUALARMORTYPE2),
        armorHeavy = GetString(SI_VISUALARMORTYPE3),

        weaponAxe = GetString(SI_WEAPONTYPE1),
        weaponHammer = GetString(SI_WEAPONTYPE2),
        weaponSword = GetString(SI_WEAPONTYPE3),
        weapon2hdSword = "双手 " .. GetString(SI_WEAPONTYPE4),
        weapon2hdAxe = "双手 " .. GetString(SI_WEAPONTYPE5),
        weapon2hdHammer = "双手 " .. GetString(SI_WEAPONTYPE6),
        weaponBow = GetString(SI_WEAPONTYPE8),
        weaponHealingStaff = GetString(SI_WEAPONTYPE9),
        weaponDagger = GetString(SI_WEAPONTYPE11),
        weaponFireStaff = GetString(SI_WEAPONTYPE12),
        weaponFrostStaff = GetString(SI_WEAPONTYPE13),
        weaponShield = GetString(SI_WEAPONTYPE14),
        weaponLightningStaff = GetString(SI_WEAPONTYPE15),

        equipHead = GetString(SI_EQUIPTYPE1),
        equipNeck = GetString(SI_EQUIPTYPE2),
        equipChest = GetString(SI_EQUIPTYPE3),
        equipShoulders = GetString(SI_EQUIPTYPE4),
        equipWaist = GetString(SI_EQUIPTYPE8),
        equipLegs = GetString(SI_EQUIPTYPE9),
        equipFeet = GetString(SI_EQUIPTYPE10),
        equipRing = GetString(SI_EQUIPTYPE12),
        equipHand = GetString(SI_EQUIPTYPE13),
    },
}

--Use metatable trick to provide EN translations for missing other languages
local enStrings = RA_Strings["en"]
for lang, _ in pairs(supportedLanguages) do
    if lang ~= "en" and RA_Strings[lang] ~= nil then
        setmetatable(RA_Strings[lang], { __index = enStrings })
    end
end
