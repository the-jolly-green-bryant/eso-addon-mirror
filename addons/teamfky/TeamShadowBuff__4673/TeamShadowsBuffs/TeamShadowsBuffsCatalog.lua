-- =====================================================================
--  Team Shadows Buffs - Catalogue d'effets
-- ---------------------------------------------------------------------
--  Donnée brute (catégories / noms / ids / couleurs / cible / méta),
--  normalisée pour le reste de l'addon :
--    color {r,g,b,a} tableau  ->  { r=, g=, b=, a= }
--    target "Yourself"/"Current Target"  ->  targetType "player"/"target"
--  Les champs maxStacks / cooldown / source sont conservés comme méta
--  (affichés dans l'UI ; le décompte en combat n'est pas encore géré).
--
--  Charger AVANT modules/MajorEffects.lua dans le .txt :
--      TeamShadowsBuffsCatalog.lua
--      modules/MajorEffects.lua
-- =====================================================================

TeamShadowsBuffs = TeamShadowsBuffs or {}
local TSB = TeamShadowsBuffs

-- catégories d'origine = activées par défaut (comportement historique).
-- toutes les autres = désactivées par défaut (sinon l'écran serait noyé).
-- Tous les trackers sont désactivés par défaut : l'utilisateur active ce qu'il veut
-- (ou importe une config partagée). Aucune catégorie n'est activée d'office.
local CORE_CATEGORIES = {}

local rawCategories = {
    {
        key = "major_buffs", name = "Buffs majeurs joueur",
        entries = {
            { key = "major_slayer", shortName = "TM", name = "Tueur majeur", ids = { 93109, 93120, 93442 }, color = { 0.20, 0.72, 0.32, 1 }, target = "Yourself" },
            { key = "major_courage", shortName = "CM", name = "Courage majeur", ids = { 109966 }, color = { 0.22, 0.56, 0.96, 1 }, target = "Yourself" },
            { key = "major_force", shortName = "FM", name = "Force majeure", ids = { 46539, 61747, 40224 }, icon = "/esoui/art/icons/ability_buff_major_force.dds", color = { 0.88, 0.72, 0.20, 1 }, target = "Yourself" },
            { key = "major_berserk", shortName = "BK", name = "Berserk majeur", ids = { 62195 }, color = { 0.80, 0.20, 0.24, 1 }, target = "Yourself" },
            { key = "major_sorcery", shortName = "SO", name = "Sorcellerie majeure", ids = { 61687, 92507, 92503, 92512 }, color = { 0.48, 0.34, 0.92, 1 }, target = "Yourself" },
            { key = "major_brutality", shortName = "BR", name = "Brutalite majeure", ids = { 61665 }, color = { 0.80, 0.32, 0.10, 1 }, target = "Yourself" },
            { key = "major_savagery", shortName = "SV", name = "Sauvagerie majeure", ids = { 61667 }, color = { 0.10, 0.72, 0.48, 1 }, target = "Yourself" },
            { key = "major_prophecy", shortName = "PR", name = "Prophetie majeure", ids = { 61689 }, color = { 0.42, 0.72, 1.00, 1 }, target = "Yourself" },
            { key = "major_resolve", shortName = "RS", name = "Resolution majeure", ids = { 61694, 86224, 88758, 88761 }, color = { 0.64, 0.64, 0.72, 1 }, target = "Yourself" },
            { key = "major_heroism", shortName = "HE", name = "Heroisme majeur", ids = { 61709 }, color = { 0.95, 0.55, 0.18, 1 }, target = "Yourself" },
            { key = "major_expedition", shortName = "EX", name = "Expedition majeure", ids = { 61736, 101161, 101169, 101178 }, color = { 0.18, 0.76, 0.86, 1 }, target = "Yourself" },
        },
    },
    {
        key = "boss_debuffs", name = "Debuffs boss",
        entries = {
            { key = "major_vulnerability", shortName = "VM", name = "Vulnerabilite", ids = { 106754, 122389, 122177 }, color = { 0.82, 0.18, 0.22, 1 }, target = "Current Target" },
            { key = "major_breach", shortName = "BRc", name = "Breche", ids = { 61743, 53881, 62775, 62787 }, color = { 0.82, 0.34, 0.10, 1 }, target = "Current Target" },
            { key = "major_brittle", shortName = "FG", name = "Fragilite", ids = { 145977 }, color = { 0.62, 0.25, 0.82, 1 }, target = "Current Target" },
            { key = "major_cowardice", shortName = "LC", name = "Lachete", ids = { 147643 }, color = { 0.34, 0.45, 0.86, 1 }, target = "Current Target" },
            { key = "major_maim", shortName = "MM", name = "Mutilation", ids = { 133292 }, color = { 0.62, 0.18, 0.18, 1 }, target = "Current Target" },
            { key = "off_balance", shortName = "DE", name = "Desequilibre", ids = { 39077, 63003, 102771 }, color = { 0.95, 0.86, 0.18, 1 }, target = "Current Target" },
        },
    },
    {
        key = "set_stacks", name = "Sets a stacks",
        entries = {
            { key = "twice_fanged_serpent", shortName = "TFS", name = "Serpent a deux crocs", ids = { 51176 }, maxStacks = 5, color = { 0.24, 0.78, 0.42, 1 }, target = "Yourself", source = "Bandits UI" },
            { key = "berserking_warrior", shortName = "AY", name = "Yokeda implacable", ids = { 50978 }, maxStacks = 5, color = { 0.92, 0.38, 0.16, 1 }, target = "Yourself", source = "Bandits UI" },
            { key = "siroria_boon", shortName = "SI", name = "Faveur de Siroria", ids = { 110118, 110142 }, maxStacks = 20, color = { 0.92, 0.62, 0.18, 1 }, target = "Yourself", source = "Bandits UI" },
            { key = "arms_relequen", shortName = "RL", name = "Relequen - vents nuisibles", ids = { 110504 }, maxStacks = 20, color = { 0.30, 0.72, 0.96, 1 }, target = "Current Target", source = "Bandits UI" },
            { key = "tzogvin_precision", shortName = "TZ", name = "Tzogvin - precision", ids = { 116742 }, maxStacks = 10, color = { 0.34, 0.82, 0.92, 1 }, target = "Yourself", source = "Bandits UI" },
            { key = "kinras_wrath", shortName = "KI", name = "Courroux de Kinras", ids = { 150750 }, maxStacks = 5, color = { 0.92, 0.24, 0.12, 1 }, target = "Yourself", source = "ExoYs Proc Set Timer" },
            { key = "zens_redress", shortName = "ZEN", name = "Reparation de Z'en", ids = { 126597 }, maxStacks = 5, cooldown = 22, color = { 0.14, 0.56, 0.94, 1 }, target = "Current Target", source = "Combat Metrics / LibCombat / ExoYs Proc Set Timer" },
            { key = "elemental_catalyst", shortName = "EC", name = "Catalyseur elementaire", ids = { 142610, 142653, 142652, 181606 }, maxStacks = 3, color = { 0.70, 0.34, 0.94, 1 }, target = "Current Target", source = "Combat Metrics" },
        },
    },
    {
        key = "set_procs", name = "Sets a proc et cooldown",
        entries = {
            { key = "burning_spellweave", shortName = "BSW", name = "Toile d'araignee brulante", ids = { 61459 }, color = { 0.95, 0.28, 0.08, 1 }, target = "Yourself", source = "Bandits UI" },
            { key = "scathing_mage", shortName = "SM", name = "Mage cruel", ids = { 67288 }, color = { 0.68, 0.30, 0.92, 1 }, target = "Yourself", source = "Bandits UI" },
            { key = "ravager", shortName = "RV", name = "Ravageur", ids = { 34872 }, color = { 0.82, 0.18, 0.18, 1 }, target = "Yourself", source = "Bandits UI" },
            { key = "clever_alchemist", shortName = "CA", name = "Alchimiste astucieux", ids = { 75746 }, color = { 0.20, 0.82, 0.54, 1 }, target = "Yourself", source = "Bandits UI" },
            { key = "powerful_assault", shortName = "PA", name = "Assaut puissant", ids = { 61771 }, color = { 0.28, 0.68, 0.96, 1 }, target = "Yourself", source = "Bandits UI" },
            { key = "mechanical_acuity", shortName = "MA", name = "Acuite mecanique", ids = { 99204 }, cooldown = 29, maxStacks = 5, color = { 0.92, 0.72, 0.24, 1 }, target = "Yourself", source = "Bandits UI / ExoYs Proc Set Timer" },
            { key = "olorime", shortName = "OL", name = "Vestment d'Olorime", ids = { 107141, 109084, 109994, 110020 }, cooldown = 10, color = { 0.92, 0.78, 0.30, 1 }, target = "Yourself", source = "Bandits UI" },
            { key = "hollowfang", shortName = "HF", name = "Soif de la Gueule creuse", ids = { 126924 }, cooldown = 9, color = { 0.58, 0.18, 0.78, 1 }, target = "Yourself", source = "Bandits UI / ExoYs Proc Set Timer" },
            { key = "maarselok", shortName = "MR", name = "Maarselok", ids = { 126941 }, cooldown = 10, color = { 0.32, 0.72, 0.24, 1 }, target = "Current Target", source = "Bandits UI" },
            { key = "sentinel_rkugamz", shortName = "SR", name = "Sentinelle de Rkugamz", ids = { 81036 }, cooldown = 15, color = { 0.72, 0.62, 0.26, 1 }, target = "Yourself", source = "Bandits UI" },
            { key = "spell_strategist", shortName = "SS", name = "Strategiste magique", ids = { 113382 }, color = { 0.42, 0.64, 0.96, 1 }, target = "Current Target", source = "Combat Metrics" },
            { key = "crimson_oath", shortName = "CO", name = "Serment ecarlate", ids = { 159288 }, color = { 0.82, 0.16, 0.18, 1 }, target = "Current Target", source = "Combat Metrics" },
            { key = "tremorscale", shortName = "TRs", name = "Ecaille de Trembleterre", ids = { 80866 }, color = { 0.72, 0.52, 0.28, 1 }, target = "Current Target", source = "Combat Metrics" },
            { key = "alkosh", shortName = "AL", name = "Rugissement d'Alkosh", ids = { 76667, 75753, 120018 }, color = { 0.90, 0.68, 0.22, 1 }, target = "Current Target", source = "Combat Metrics / LibCombat" },
            { key = "pillagers_profit_cd", shortName = "PPc", name = "Profit du pillard - cooldown", ids = { 172055, 172056 }, cooldown = 45, color = { 0.34, 0.72, 0.98, 1 }, target = "Yourself", source = "BuffTheGroup" },
            { key = "spaulder_ruin", shortName = "SRU", name = "Spalliere de ruine", ids = { 163401 }, color = { 0.70, 0.26, 0.22, 1 }, target = "Yourself", source = "BuffTheGroup" },
        },
    },
    {
        key = "skill_stacks", name = "Competences a stacks et charges",
        entries = {
            { key = "arcanist_crux", shortName = "CR", name = "Crux", ids = { 184220 }, maxStacks = 3, color = { 0.18, 0.86, 0.52, 1 }, target = "Yourself", source = "ExoYs Crux Tracker / Combat Metronome" },
            { key = "grim_focus", shortName = "GF", name = "Concentration impitoyable", ids = { 61902, 122585 }, maxStacks = 5, color = { 0.74, 0.18, 0.26, 1 }, target = "Yourself", source = "LibCombat / Fancy Action Bar" },
            { key = "merciless_resolve", shortName = "MRc", name = "Resolution impitoyable", ids = { 61919, 122586 }, maxStacks = 5, color = { 0.56, 0.16, 0.78, 1 }, target = "Yourself", source = "LibCombat / Fancy Action Bar" },
            { key = "relentless_focus", shortName = "RF", name = "Concentration acharnee", ids = { 61927, 122587 }, maxStacks = 5, color = { 0.24, 0.64, 0.92, 1 }, target = "Yourself", source = "LibCombat / Fancy Action Bar" },
            { key = "bound_armaments", shortName = "BA", name = "Armements lies", ids = { 24165, 203447, 130291 }, maxStacks = 4, color = { 0.46, 0.28, 0.86, 1 }, target = "Yourself", source = "Bandits UI / Fancy Action Bar" },
            { key = "seething_fury", shortName = "SF", name = "Fureur bouillonnante", ids = { 122658 }, maxStacks = 3, color = { 0.94, 0.26, 0.08, 1 }, target = "Yourself", source = "Bandits UI" },
            { key = "stone_giant_stagger", shortName = "ST", name = "Chancellement du Geant de pierre", ids = { 134336 }, maxStacks = 3, color = { 0.72, 0.58, 0.34, 1 }, target = "Current Target", source = "Fancy Action Bar" },
        },
    },
    {
        key = "skill_procs", name = "Competences pretes et procs",
        entries = {
            { key = "assassins_will", shortName = "AW", name = "Volonte de l'assassin", ids = { 61907, 61930 }, color = { 0.76, 0.18, 0.34, 1 }, target = "Yourself", source = "LibCombat" },
            { key = "assassins_scourge", shortName = "AS", name = "Fleau de l'assassin", ids = { 61932 }, color = { 0.28, 0.60, 0.96, 1 }, target = "Yourself", source = "LibCombat" },
            { key = "crystal_fragments_proc", shortName = "CF", name = "Fragments de cristal prets", ids = { 46327, 114716 }, color = { 0.46, 0.20, 0.92, 1 }, target = "Yourself", source = "LibCombat / Fancy Action Bar" },
            { key = "blastbones_stalking", shortName = "BBs", name = "Archer squelette pret", ids = { 117749, 117773 }, color = { 0.42, 0.72, 0.34, 1 }, target = "Yourself", source = "Combat Metrics" },
            { key = "blastbones_blighted", shortName = "BBb", name = "Squelette explosif pret", ids = { 117690, 117693 }, color = { 0.30, 0.68, 0.22, 1 }, target = "Yourself", source = "Combat Metrics" },
            { key = "misery_knife", shortName = "MK", name = "Couteau de misere", ids = { 217353 }, color = { 0.66, 0.18, 0.70, 1 }, target = "Current Target", source = "Combat Metrics" },
        },
    },
    {
        key = "support_debuffs", name = "Debuffs de raid et support",
        entries = {
            { key = "minor_breach", shortName = "mBR", name = "Breche mineure", ids = { 61742 }, color = { 0.92, 0.52, 0.18, 1 }, target = "Current Target", source = "Combat Metrics" },
            { key = "minor_vulnerability", shortName = "mVM", name = "Vulnerabilite mineure", ids = { 79717 }, color = { 0.82, 0.34, 0.34, 1 }, target = "Current Target", source = "Combat Metrics" },
            { key = "minor_brittle", shortName = "mFG", name = "Fragilite mineure", ids = { 145975 }, color = { 0.52, 0.30, 0.86, 1 }, target = "Current Target", source = "Combat Metrics" },
            { key = "crusher", shortName = "CRu", name = "Enchantement ecraseur", ids = { 17906, 120007 }, color = { 0.78, 0.54, 0.24, 1 }, target = "Current Target", source = "Combat Metrics" },
            { key = "engulfing_flames", shortName = "EF", name = "Flammes devorantes", ids = { 120011, 31102 }, color = { 0.96, 0.26, 0.06, 1 }, target = "Current Target", source = "Combat Metrics / Fancy Action Bar" },
            { key = "minor_magickasteal", shortName = "mMS", name = "Vol de magie mineur", ids = { 88401 }, color = { 0.32, 0.48, 0.94, 1 }, target = "Current Target", source = "Combat Metrics" },
            { key = "infallible_aether", shortName = "IA", name = "Ether infaillible", ids = { 81519 }, color = { 0.66, 0.46, 0.92, 1 }, target = "Current Target", source = "Bandits UI" },
            { key = "crystal_weapon", shortName = "CW", name = "Arme cristalline", ids = { 143808 }, color = { 0.38, 0.72, 0.96, 1 }, target = "Current Target", source = "Combat Metrics" },
            { key = "runic_sunder", shortName = "RSu", name = "Fracture runique", ids = { 187742 }, color = { 0.20, 0.84, 0.68, 1 }, target = "Current Target", source = "Combat Metrics" },
        },
    },
    {
        key = "status_effects", name = "Effets de statut",
        entries = {
            { key = "status_overcharged", shortName = "OV", name = "Surcharge", ids = { 178118 }, color = { 0.58, 0.34, 0.94, 1 }, target = "Current Target", source = "Combat Metrics" },
            { key = "status_burning", shortName = "BU", name = "Brulure", ids = { 18084 }, color = { 0.96, 0.24, 0.04, 1 }, target = "Current Target", source = "Combat Metrics" },
            { key = "status_chilled", shortName = "CH", name = "Glace", ids = { 95136 }, color = { 0.30, 0.72, 0.96, 1 }, target = "Current Target", source = "Combat Metrics" },
            { key = "status_concussed", shortName = "COc", name = "Commotion", ids = { 95134 }, color = { 0.88, 0.76, 0.18, 1 }, target = "Current Target", source = "Combat Metrics" },
            { key = "status_sundered", shortName = "SU", name = "Fissure", ids = { 178123 }, color = { 0.74, 0.50, 0.28, 1 }, target = "Current Target", source = "Combat Metrics" },
            { key = "status_poisoned", shortName = "PO", name = "Empoisonnement", ids = { 21929 }, color = { 0.34, 0.76, 0.18, 1 }, target = "Current Target", source = "Combat Metrics" },
            { key = "status_diseased", shortName = "DI", name = "Maladie", ids = { 178127 }, color = { 0.48, 0.64, 0.20, 1 }, target = "Current Target", source = "Combat Metrics" },
            { key = "status_hemorrhage", shortName = "HEM", name = "Hemorragie", ids = { 148801 }, color = { 0.78, 0.10, 0.16, 1 }, target = "Current Target", source = "Combat Metrics" },
        },
    },
    {
        key = "monster_sets", name = "Sets de monstre a proc",
        entries = {
            { key = "grothdarr", shortName = "GR", name = "Grothdarr", ids = { 84504 }, cooldown = 10, color = { 0.96, 0.28, 0.06, 1 }, target = "Yourself", source = "ExoYs Proc Set Timer" },
            { key = "bogdan_nightflame", shortName = "BO", name = "Bogdan la Flamme nocturne", ids = { 59590 }, cooldown = 10, color = { 0.42, 0.82, 0.34, 1 }, target = "Yourself", source = "ExoYs Proc Set Timer" },
            { key = "earthgore", shortName = "EG", name = "Sangreterre", ids = { 97855 }, cooldown = 20, color = { 0.76, 0.18, 0.18, 1 }, target = "Yourself", source = "ExoYs Proc Set Timer" },
            { key = "tremorscale_proc", shortName = "TRp", name = "Ecaille de Trembleterre - proc", ids = { 80865 }, cooldown = 10, color = { 0.72, 0.52, 0.28, 1 }, target = "Current Target", source = "ExoYs Proc Set Timer" },
            { key = "infernal_guardian", shortName = "IG", name = "Gardien infernal", ids = { 83405 }, cooldown = 6, color = { 0.94, 0.32, 0.08, 1 }, target = "Yourself", source = "ExoYs Proc Set Timer" },
            { key = "iceheart", shortName = "IH", name = "Coeur-de-glace", ids = { 80562 }, cooldown = 6, color = { 0.28, 0.72, 0.96, 1 }, target = "Yourself", source = "ExoYs Proc Set Timer" },
            { key = "lady_thorn", shortName = "LT", name = "Dame Ronce", ids = { 141905, 141971, 141927 }, cooldown = 20, color = { 0.68, 0.18, 0.24, 1 }, target = "Yourself", source = "ExoYs Proc Set Timer" },
            { key = "sellistrix", shortName = "SE", name = "Sellistrix", ids = { 80545 }, cooldown = 6, color = { 0.62, 0.48, 0.30, 1 }, target = "Current Target", source = "ExoYs Proc Set Timer" },
            { key = "encratis", shortName = "EN", name = "Behemoth d'Encratis", ids = { 151033 }, cooldown = 15, color = { 0.88, 0.22, 0.10, 1 }, target = "Yourself", source = "ExoYs Proc Set Timer" },
            { key = "zaan", shortName = "ZA", name = "Zaan", ids = { 110997, 102136, 102142 }, cooldown = 20, color = { 0.96, 0.30, 0.06, 1 }, target = "Current Target", source = "ExoYs Proc Set Timer" },
        },
    },
    {
        key = "dungeon_proc_sets", name = "Sets de donjon a proc",
        entries = {
            { key = "caluurion", shortName = "CL", name = "Heritage de Caluurion", ids = { 102032 }, cooldown = 10, color = { 0.48, 0.34, 0.90, 1 }, target = "Current Target", source = "ExoYs Proc Set Timer" },
            { key = "hitis_hearth", shortName = "HH", name = "Foyer de Hiti", ids = { 133210 }, cooldown = 12, color = { 0.34, 0.82, 0.48, 1 }, target = "Yourself", source = "ExoYs Proc Set Timer" },
            { key = "spell_power_cure", shortName = "SPC", name = "Remede du pouvoir curatif", ids = { 66902 }, cooldown = 5, color = { 0.90, 0.78, 0.30, 1 }, target = "Yourself", source = "ExoYs Proc Set Timer" },
            { key = "icy_conjuror", shortName = "IC", name = "Invocateur glacial", ids = { 117666 }, cooldown = 10, color = { 0.28, 0.66, 0.94, 1 }, target = "Current Target", source = "ExoYs Proc Set Timer" },
            { key = "drakes_rush", shortName = "DR", name = "Ruee du Drake", ids = { 150974 }, cooldown = 18, color = { 0.86, 0.38, 0.14, 1 }, target = "Yourself", source = "ExoYs Proc Set Timer" },
            { key = "crimson_twilight", shortName = "CT", name = "Crepuscule ecarlate", ids = { 141638 }, cooldown = 8, color = { 0.78, 0.12, 0.20, 1 }, target = "Yourself", source = "ExoYs Proc Set Timer" },
            { key = "plague_slinger", shortName = "PS", name = "Lance-peste", ids = { 102106 }, cooldown = 8, color = { 0.42, 0.70, 0.20, 1 }, target = "Current Target", source = "ExoYs Proc Set Timer" },
            { key = "scorions_feast", shortName = "SFe", name = "Festin de Scorion", ids = { 159237, 159236 }, cooldown = 20, color = { 0.54, 0.26, 0.84, 1 }, target = "Yourself", source = "ExoYs Proc Set Timer" },
            { key = "rush_of_agony", shortName = "RA", name = "Ruee de l'agonie", ids = { 159279, 159276, 159277, 159275 }, cooldown = 8, color = { 0.72, 0.18, 0.28, 1 }, target = "Current Target", source = "ExoYs Proc Set Timer" },
            { key = "crimson_oath_proc", shortName = "COp", name = "Serment ecarlate - proc", ids = { 159291, 159288 }, cooldown = 12, color = { 0.82, 0.16, 0.18, 1 }, target = "Current Target", source = "ExoYs Proc Set Timer / Combat Metrics" },
            { key = "thunder_caller", shortName = "TC", name = "Invocateur de tonnerre", ids = { 159249 }, cooldown = 12, color = { 0.82, 0.72, 0.18, 1 }, target = "Current Target", source = "ExoYs Proc Set Timer" },
            { key = "turning_tide", shortName = "TT", name = "Maree renversee", ids = { 167350 }, cooldown = 15, color = { 0.24, 0.68, 0.86, 1 }, target = "Current Target", source = "ExoYs Proc Set Timer" },
            { key = "glacial_guardian", shortName = "GG", name = "Gardien glacial", ids = { 167114 }, cooldown = 12, color = { 0.34, 0.74, 0.96, 1 }, target = "Current Target", source = "ExoYs Proc Set Timer" },
            { key = "gryphons_reprisal", shortName = "GRe", name = "Represailles du griffon", ids = { 167043 }, cooldown = 20, color = { 0.86, 0.62, 0.24, 1 }, target = "Current Target", source = "ExoYs Proc Set Timer" },
            { key = "spriggans_vigor", shortName = "SVi", name = "Vigueur du spriggan", ids = { 167058 }, maxStacks = 10, color = { 0.24, 0.78, 0.34, 1 }, target = "Yourself", source = "ExoYs Proc Set Timer" },
            { key = "maligaligs_maelstrom", shortName = "MMa", name = "Maelstrom de Maligalig", ids = { 167040, 168019 }, cooldown = 10, color = { 0.24, 0.58, 0.94, 1 }, target = "Current Target", source = "ExoYs Proc Set Timer" },
        },
    },
    {
        key = "overland_crafted_pvp_procs", name = "Sets zone, craft et JcJ",
        entries = {
            { key = "briarheart", shortName = "BH", name = "Roncecoeur", ids = { 71107 }, cooldown = 15, color = { 0.58, 0.18, 0.24, 1 }, target = "Yourself", source = "ExoYs Proc Set Timer" },
            { key = "venomous_smite", shortName = "VS", name = "Frappe venimeuse", ids = { 135690 }, cooldown = 15, color = { 0.36, 0.76, 0.16, 1 }, target = "Current Target", source = "ExoYs Proc Set Timer" },
            { key = "red_mountain", shortName = "RM", name = "Montagne ecarlate", ids = { 97806 }, cooldown = 8, color = { 0.94, 0.30, 0.06, 1 }, target = "Current Target", source = "ExoYs Proc Set Timer" },
            { key = "mad_tinkerer", shortName = "MT", name = "Bricoleur fou", ids = { 92982 }, cooldown = 8, color = { 0.62, 0.38, 0.84, 1 }, target = "Current Target", source = "ExoYs Proc Set Timer" },
            { key = "martial_knowledge", shortName = "MK2", name = "Connaissance martiale", ids = { 127070 }, cooldown = 8, color = { 0.84, 0.68, 0.22, 1 }, target = "Current Target", source = "ExoYs Proc Set Timer" },
            { key = "meritorious_service", shortName = "MS", name = "Service meritoire", ids = { 65706 }, color = { 0.30, 0.68, 0.94, 1 }, target = "Yourself", source = "ExoYs Proc Set Timer" },
            { key = "dark_convergence", shortName = "DC", name = "Convergence noire", ids = { 159388, 160317 }, cooldown = 25, color = { 0.54, 0.18, 0.76, 1 }, target = "Current Target", source = "ExoYs Proc Set Timer" },
            { key = "hrothgars_chill", shortName = "HC", name = "Froid de Hrothgar", ids = { 159713, 159740, 159793 }, cooldown = 7, color = { 0.30, 0.70, 0.94, 1 }, target = "Current Target", source = "ExoYs Proc Set Timer" },
            { key = "nunatak", shortName = "NU", name = "Nunatak", ids = { 167682 }, cooldown = 15, color = { 0.28, 0.74, 0.96, 1 }, target = "Current Target", source = "ExoYs Proc Set Timer" },
        },
    },
    {
        key = "mythic_stacks", name = "Mythiques a stacks et effets",
        entries = {
            { key = "thrassian_stranglers", shortName = "TS", name = "Etrangleurs thrassiens", ids = { 136123 }, maxStacks = 50, color = { 0.38, 0.74, 0.28, 1 }, target = "Yourself", source = "ExoYs Proc Set Timer" },
            { key = "harpooners_kilt", shortName = "HK", name = "Kilt de pataugeur de Harponeur", ids = { 155150 }, maxStacks = 10, color = { 0.24, 0.72, 0.92, 1 }, target = "Yourself", source = "ExoYs Proc Set Timer" },
            { key = "death_dealers_fete", shortName = "DF", name = "Fete du marchand de mort", ids = { 155176 }, maxStacks = 30, color = { 0.82, 0.24, 0.34, 1 }, target = "Yourself", source = "ExoYs Proc Set Timer" },
            { key = "bloodlords_embrace", shortName = "BE", name = "Etreinte du seigneur de sang", ids = { 139903 }, color = { 0.72, 0.12, 0.18, 1 }, target = "Current Target", source = "ExoYs Proc Set Timer" },
            { key = "sea_serpents_coil", shortName = "SC", name = "Spire du serpent de mer", ids = { 172865 }, cooldown = 10, color = { 0.22, 0.68, 0.78, 1 }, target = "Yourself", source = "ExoYs Proc Set Timer" },
        },
    },
    {
        key = "trial_proc_sets", name = "Sets d'epreuve a proc",
        entries = {
            { key = "whorl_depths", shortName = "WD", name = "Tourbillon des profondeurs", ids = { 172671 }, cooldown = 18, color = { 0.18, 0.58, 0.92, 1 }, target = "Current Target", source = "ExoYs Proc Set Timer" },
            { key = "pillagers_profit", shortName = "PP", name = "Profit du pillard", ids = { 172055, 172056 }, cooldown = 45, color = { 0.30, 0.70, 0.96, 1 }, target = "Yourself", source = "ExoYs Proc Set Timer / BuffTheGroup" },
            { key = "force_overflow", shortName = "FO", name = "Debordement de force", ids = { 147875 }, cooldown = 10, color = { 0.78, 0.42, 0.90, 1 }, target = "Yourself", source = "ExoYs Proc Set Timer" },
            { key = "elemental_wrath", shortName = "EW", name = "Courroux elementaire", ids = { 147843 }, cooldown = 10, color = { 0.92, 0.36, 0.14, 1 }, target = "Current Target", source = "ExoYs Proc Set Timer" },
            { key = "void_bash", shortName = "VB", name = "Coup du neant", ids = { 147747 }, cooldown = 13, color = { 0.42, 0.22, 0.76, 1 }, target = "Current Target", source = "ExoYs Proc Set Timer" },
            { key = "destructive_impact", shortName = "DIm", name = "Impact destructeur", ids = { 140334 }, color = { 0.86, 0.32, 0.12, 1 }, target = "Current Target", source = "ExoYs Proc Set Timer" },
        },
    },
}

-- normalisation -------------------------------------------------------
local function NormTarget(t)
    if t == "Current Target" then return "target" end
    return "player"
end

local function NormColor(c)
    c = c or {}
    return { r = c[1] or 1, g = c[2] or 1, b = c[3] or 1, a = c[4] or 1 }
end

local categories, seenKeys = {}, {}
for _, cat in ipairs(rawCategories) do
    local entries = {}
    for _, e in ipairs(cat.entries) do
        if seenKeys[e.key] then
            -- clé déjà prise ailleurs : on saute pour éviter d'écraser (ids partagés)
        else
            seenKeys[e.key] = true
            entries[#entries + 1] = {
                key = e.key,
                shortName = e.shortName,
                name = e.name,
                ids = e.ids,
                color = NormColor(e.color),
                icon = e.icon,
                targetType = NormTarget(e.target),
                maxStacks = e.maxStacks,
                cooldown = e.cooldown,
                source = e.source,
                categoryKey = cat.key,
                categoryName = cat.name,
                defaultEnabled = CORE_CATEGORIES[cat.key] == true,
            }
        end
    end
    categories[#categories + 1] = { key = cat.key, name = cat.name, entries = entries }
end

TSB.effectCatalog = { categories = categories }

function TSB.GetEffectCatalog()
    return TSB.effectCatalog
end

-- Listes à plat groupées par cible (consommées par MajorEffects)
function TSB.GetCatalogByTarget()
    local player, target = {}, {}
    for _, cat in ipairs(categories) do
        for _, e in ipairs(cat.entries) do
            if e.targetType == "player" then player[#player + 1] = e else target[#target + 1] = e end
        end
    end
    return player, target
end
