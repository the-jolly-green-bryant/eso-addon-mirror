local SRC = SupportRotationCallouts
SRC.EncounterProfiles = SRC.EncounterProfiles or {}
local Profiles = SRC.EncounterProfiles

local function Normalize(value)
    return zo_strlower(zo_strtrim(zo_strformat("<<1>>", value or "")))
end

local OBJECTIVES = {
    learning_normal = { label = "Learning Normal", risk = "safe" },
    learning_veteran = { label = "Learning Veteran", risk = "safe" },
    first_clear = { label = "First Clear", risk = "balanced" },
    farm = { label = "Farm", risk = "balanced" },
    hardmode_trifecta = { label = "Hard Mode Trifecta", risk = "precision" },
    score_push = { label = "Score Push", risk = "aggressive" },
}

local FOUNDATION_STATES = {
    "OPENING", "ACTIVE", "MECHANIC", "TRANSITION", "RECOVERY", "FINAL_BURN", "COMPLETE"
}

local DEFAULT_RESPONSIBILITIES = {
    "RESP_MAJOR_FORCE",
    "RESP_MAJOR_SLAYER",
    "RESP_MAJOR_VULNERABILITY",
    "RESP_CRUSHER",
    "RESP_MAJOR_BRITTLE",
    "RESP_ULTIMATE_RESTORE",
    "RESP_DEBUFF_EXTENSION",
    "RESP_DEFENSIVE_ULTIMATE",
}

local function FoundationEncounter(id, label, options)
    options = options or {}
    local profile = {
        id = id,
        label = label,
        phases = options.phases or { "OPENING", "ACTIVE", "MECHANIC", "TRANSITION", "RECOVERY", "COMPLETE" },
        mechanics = options.mechanics or {},
        responsibilities = options.responsibilities or DEFAULT_RESPONSIBILITIES,
        timeline = options.timeline or { "OPENING", "ACTIVE", "MECHANIC", "TRANSITION", "RECOVERY", "COMPLETE" },
        observationSignals = options.observationSignals or {},
        strategyProfiles = options.strategyProfiles or {},
        defaultStrategy = options.defaultStrategy or "automatic",
        researchSources = options.researchSources or {},
        researchConfidence = options.researchConfidence or "foundation",
        sequence = options.sequence,
        burnWindowGuide = options.burnWindowGuide or options.burnWindows or {},
        burnWindows = options.burnWindowGuide or options.burnWindows or {},
        intelligenceDriven = options.intelligenceDriven == true,
        veteran = {
            validationOnly = true,
            profileVersion = 1,
            foundation = true,
            openingDurationMs = options.openingDurationMs or 8000,
            availabilityDebounceMs = 750,
            recoveryDurationMs = 2000,
            combatEndResetMs = 1200,
            validationCallouts = options.validationCallouts == true,
        },
        hardmode = {
            validationOnly = true,
            profileVersion = 1,
            foundation = true,
            openingDurationMs = options.openingDurationMs or 8000,
            availabilityDebounceMs = 750,
            recoveryDurationMs = 2000,
            combatEndResetMs = 1200,
            validationCallouts = options.validationCallouts == true,
        },
    }
    return profile
end

local function FoundationTrial(id, code, releaseOrder, encounters, options)
    options = options or {}
    return {
        id = id,
        code = code,
        releaseOrder = releaseOrder,
        validation = true,
        foundation = true,
        foundationVersion = 1,
        researchStatus = options.researchStatus or "RESEARCHED_PENDING_LIVE_VALIDATION",
        supportedObjectives = OBJECTIVES,
        stateCandidates = FOUNDATION_STATES,
        encounters = encounters or {},
    }
end

local function AddEncounter(encounters, encounter, ...)
    for index = 1, select("#", ...) do
        local alias = select(index, ...)
        encounters[Normalize(alias)] = encounter
    end
end

local TRIALS = {}

-- Craglorn trials
local aa = {}
AddEncounter(aa, FoundationEncounter("ENCOUNTER_AA_LIGHTNING_ATRONACH", "Lightning Storm Atronach", { mechanics = { "LIGHTNING_STORM", "SPREADING_AOE" } }), "Lightning Storm Atronach")
AddEncounter(aa, FoundationEncounter("ENCOUNTER_AA_FOUNDATION_ATRONACH", "Foundation Stone Atronach", { mechanics = { "CHAIN_LIGHTNING", "GROUND_AOE" } }), "Foundation Stone Atronach")
AddEncounter(aa, FoundationEncounter("ENCOUNTER_AA_VARLARIEL", "Varlariel", { mechanics = { "CLONE_PHASE", "GROUP_SPLIT" } }), "Varlariel")
AddEncounter(aa, FoundationEncounter("ENCOUNTER_AA_MAGE", "The Mage", { mechanics = { "AXES", "CHAIN_LIGHTNING", "EXECUTE" } }), "The Mage", "Mage")
TRIALS["Aetherian Archive"] = FoundationTrial("TRIAL_AA", "AA", 1, aa)

local hrc = {}
AddEncounter(hrc, FoundationEncounter("ENCOUNTER_HRC_RA_KOTU", "Ra Kotu", { mechanics = { "WHIRLWIND", "ADDS" } }), "Ra Kotu")
AddEncounter(hrc, FoundationEncounter("ENCOUNTER_HRC_YOKEDA_ROKDUN", "Yokeda Rok'dun", { mechanics = { "GARGOYLES", "BANNER_PHASE" } }), "Yokeda Rok'dun", "Yokeda Rokdun")
AddEncounter(hrc, FoundationEncounter("ENCOUNTER_HRC_YOKEDA_KAI", "Yokeda Kai", { mechanics = { "DESTRUCTION_STAFF", "REFLECT" } }), "Yokeda Kai")
AddEncounter(hrc, FoundationEncounter("ENCOUNTER_HRC_WARRIOR", "The Warrior", { mechanics = { "SHIELD_THROW", "STARFALL", "EXECUTE" } }), "The Warrior", "Warrior")
TRIALS["Hel Ra Citadel"] = FoundationTrial("TRIAL_HRC", "HRC", 2, hrc)

local so = {}
AddEncounter(so, FoundationEncounter("ENCOUNTER_SO_MANTIKORA", "Possessed Mantikora", { mechanics = { "PORTAL", "SPEAR", "QUAKE" } }), "Possessed Mantikora", "Mantikora")
AddEncounter(so, FoundationEncounter("ENCOUNTER_SO_STONEBREAKER", "Stonebreaker", { mechanics = { "ROCK_THROW", "GROUND_SLAM" } }), "Stonebreaker", "Stonebreaker Troll")
AddEncounter(so, FoundationEncounter("ENCOUNTER_SO_OZARA", "Ozara", { mechanics = { "PIN", "POISON", "ADDS" } }), "Ozara", "Ozara Lamia")
AddEncounter(so, FoundationEncounter("ENCOUNTER_SO_SERPENT", "The Serpent", { mechanics = { "POISON_PHASE", "LAMIA_PHASE", "MANTIKORA_PHASE", "EXECUTE" } }), "The Serpent", "Serpent")
TRIALS["Sanctum Ophidia"] = FoundationTrial("TRIAL_SO", "SO", 3, so)

-- Chapter and DLC trials
local mol = {}
AddEncounter(mol, FoundationEncounter("ENCOUNTER_MOL_ZHAJHASSA", "Zhaj'hassa", { mechanics = { "PILLARS", "CURSE", "CAT_PHASE" } }), "Zhaj'hassa", "Zhajhassa")
local twins = FoundationEncounter("ENCOUNTER_MOL_TWINS", "Vashai and Skinrai", { mechanics = { "COLOR_SWAP", "GROUP_SPLIT", "PRAYER_PHASE" } })
AddEncounter(mol, twins, "Vashai", "Skinrai", "Vashai and Skinrai", "Vashai & Skinrai")
AddEncounter(mol, FoundationEncounter("ENCOUNTER_MOL_RAKKHAT", "Rakkhat", { mechanics = { "PAD_ROTATION", "RUNNER_PHASE", "LUNAR_PHASE", "EXECUTE" } }), "Rakkhat")
TRIALS["Maw of Lorkhaj"] = FoundationTrial("TRIAL_MOL", "MOL", 4, mol)

local hof = {}
local hunterKillers = FoundationEncounter("ENCOUNTER_HOF_HUNTER_KILLERS", "Hunter-Killer Negatrix and Positrox", { mechanics = { "POLARITY", "SHIELD_PHASE", "ADDS" } })
AddEncounter(hof, hunterKillers, "Hunter-Killer Negatrix", "Hunter-Killer Positrox", "Negatrix", "Positrox", "Negatrix and Positrox")
AddEncounter(hof, FoundationEncounter("ENCOUNTER_HOF_PINNACLE", "Pinnacle Factotum", { mechanics = { "CENTRIFUGAL_SPIN", "SHOCK_FIELD", "ADDS" } }), "Pinnacle Factotum")
AddEncounter(hof, FoundationEncounter("ENCOUNTER_HOF_ARCHCUSTODIAN", "Archcustodian", { mechanics = { "TERMINAL_PHASE", "SPINNING_BLADES", "SHIELD" } }), "Archcustodian")
local committee = FoundationEncounter("ENCOUNTER_HOF_REASSEMBLY", "Reassembly Committee", { mechanics = { "THREE_BOSS", "REASSEMBLY", "EXECUTE" } })
AddEncounter(hof, committee, "Reassembly Committee", "Reducer", "Reclaimer", "Reducer and Reclaimer", "Reclaimer and Reducer")
AddEncounter(hof, FoundationEncounter("ENCOUNTER_HOF_ASSEMBLY_GENERAL", "Assembly General", { mechanics = { "TERMINALS", "REFABRICATION", "EXECUTE" } }), "Assembly General")
TRIALS["Halls of Fabrication"] = FoundationTrial("TRIAL_HOF", "HOF", 5, hof)

local asylum = {}
AddEncounter(asylum, FoundationEncounter("ENCOUNTER_AS_FELMS", "Saint Felms the Bold", { mechanics = { "TELEPORT", "MAIM", "JUMP" } }), "Saint Felms the Bold", "Saint Felms", "Felms")
AddEncounter(asylum, FoundationEncounter("ENCOUNTER_AS_LLOTHIS", "Saint Llothis the Pious", { mechanics = { "POISON_CONE", "INTERRUPT", "TELEPORT" } }), "Saint Llothis the Pious", "Saint Llothis", "Llothis")
AddEncounter(asylum, FoundationEncounter("ENCOUNTER_AS_OLMS", "Saint Olms the Just", { mechanics = { "STEAM_BREATH", "KITE", "JUMPS", "EXECUTE" } }), "Saint Olms the Just", "Saint Olms", "Olms")
TRIALS["Asylum Sanctorium"] = FoundationTrial("TRIAL_AS", "AS", 6, asylum)

local cr = {}
AddEncounter(cr, FoundationEncounter("ENCOUNTER_CR_GALENWE", "Galenwe", { mechanics = { "HOARFROST", "PORTAL", "RELEASER" } }), "Galenwe", "Shade of Galenwe")
AddEncounter(cr, FoundationEncounter("ENCOUNTER_CR_RELEQUEN", "Relequen", { mechanics = { "OVERLOAD", "PORTAL", "RELEASER" } }), "Relequen", "Shade of Relequen")
AddEncounter(cr, FoundationEncounter("ENCOUNTER_CR_SIRORIA", "Siroria", { mechanics = { "ROARING_FLARE", "PORTAL", "RELEASER" } }), "Siroria", "Shade of Siroria")
AddEncounter(cr, FoundationEncounter("ENCOUNTER_CR_ZMAJA", "Z'Maja", { mechanics = { "PORTAL", "MALEVOLENT_CORE", "SHADE_PHASE", "EXECUTE" } }), "Z'Maja", "Zmaja", "Shadow of the Fallen")
TRIALS["Cloudrest"] = FoundationTrial("TRIAL_CR", "CR", 7, cr)

local ss = {}
AddEncounter(ss, FoundationEncounter("ENCOUNTER_SS_LOKKESTIIZ", "Lokkestiiz", { mechanics = { "FLIGHT_PHASE", "ICE_TOMB", "ATRO_PHASE" } }), "Lokkestiiz")
AddEncounter(ss, FoundationEncounter("ENCOUNTER_SS_YOLNAHKRIIN", "Yolnahkriin", { mechanics = { "FLIGHT_PHASE", "FIRE_ATRONACH", "CATACLYSM" } }), "Yolnahkriin")
AddEncounter(ss, FoundationEncounter("ENCOUNTER_SS_NAHVIINTAAS", "Nahviintaas", { mechanics = { "PORTAL", "TIME_BREACH", "EXECUTE" } }), "Nahviintaas")
TRIALS["Sunspire"] = FoundationTrial("TRIAL_SS", "SS", 8, ss)

local ka = {}
AddEncounter(ka, FoundationEncounter("ENCOUNTER_KA_YANDIR", "Yandir the Butcher", { mechanics = { "ANIMAL_PHASE", "TOTEMS", "EXECUTE" } }), "Yandir the Butcher", "Yandir")
AddEncounter(ka, FoundationEncounter("ENCOUNTER_KA_VROL", "Captain Vrol", { mechanics = { "BOAT_PHASE", "TOTEMS", "CONDUITS" } }), "Captain Vrol", "Vrol")
AddEncounter(ka, FoundationEncounter("ENCOUNTER_KA_FALGRAVN", "Lord Falgravn", { mechanics = { "BLOOD_PHASE", "FLOOR_TRANSITION", "EXECUTE" } }), "Lord Falgravn", "Falgravn")
TRIALS["Kyne's Aegis"] = FoundationTrial("TRIAL_KA", "KA", 9, ka)

local rg = {}
AddEncounter(rg, FoundationEncounter("ENCOUNTER_RG_OAXILTSO", "Oaxiltso", {
    validationCallouts = true,
    mechanics = { "HAVOCREL", "POISON", "METEOR", "EXECUTE" },
    researchConfidence = "live_validation",
    intelligenceDriven = true,
    strategyProfiles = {
        automatic = { label="Automatic", goal="Infer the safest burn windows from observed mechanics." },
        learning = { label="Learning", conservative=true, holdDuring={"POISON","HAVOCREL"} },
        trifecta = { label="Trifecta", conservative=false, preserveRecovery=true },
    },
    burnWindowGuide = {
        { id="RG_OAX_OPENING", type="FULL_BURN", label="OPENING BURN", trigger={type="ENCOUNTER_STATE",state="OPENING"}, confidence="FOUNDATION" },
        { id="RG_OAX_POISON_HOLD", type="HOLD", label="HOLD FOR POISON", trigger={type="SIGNAL",key="POISON"}, confidence="LIVE_VALIDATION" },
        { id="RG_OAX_EXECUTE_WINDOW", type="EXECUTE", label="EXECUTE", trigger={type="BOSS_HEALTH",percent=25}, confidence="VERIFIED_THRESHOLD_CLASS" },
    },
    observationSignals = {
        health = {
            { id="RG_OAX_EXECUTE", key="EXECUTE", label="Execute", percent=25, state="FINAL_BURN", confidence="verified_threshold_class" },
        },
    },
    researchSources = { "CrutchAlerts", "Code's Combat Alerts", "ESO encounter guides", "Conductor live capture" },
}), "Oaxiltso")
AddEncounter(rg, FoundationEncounter("ENCOUNTER_RG_BAHSEI", "Flame-Herald Bahsei", {
    validationCallouts = true,
    mechanics = { "CURSE", "ABOMINATION", "PORTAL", "CONE", "EXECUTE" },
    researchConfidence = "live_validation",
    intelligenceDriven = true,
    strategyProfiles = {
        automatic = { label="Automatic", portalCount="infer" },
        two_portal = { label="Two Portal", portalCount=2 },
        three_portal = { label="Three Portal", portalCount=3 },
        learning = { label="Learning", conservative=true },
        trifecta = { label="Trifecta", conservative=false },
    },
    burnWindowGuide = {
        { id="RG_BAHSEI_OPENING", type="FULL_BURN", label="OPENING BURN", trigger={type="ENCOUNTER_STATE",state="OPENING"}, confidence="FOUNDATION" },
        { id="RG_BAHSEI_CURSE_HOLD", type="HOLD", label="HOLD FOR CURSES", trigger={type="SIGNAL",key="CURSE"}, confidence="LIVE_VALIDATION" },
        { id="RG_BAHSEI_EXECUTE_WINDOW", type="EXECUTE", label="EXECUTE", trigger={type="BOSS_HEALTH",percent=25}, confidence="VERIFIED_THRESHOLD_CLASS" },
    },
    observationSignals = {
        health = {
            { id="RG_BAHSEI_EXECUTE", key="EXECUTE", label="Execute", percent=25, state="FINAL_BURN", confidence="verified_threshold_class" },
        },
        combat = {
            { id="RG_BAHSEI_CURSE", key="CURSE", label="Curse cycle", abilityNames={"Curse"}, repeatable=true, blocksBurn=false, confidence="name_fallback_pending_id_validation" },
        },
    },
    researchSources = { "CrutchAlerts Bahsei implementation", "Code's Combat Alerts", "ESO encounter guides", "Conductor live capture" },
}), "Flame-Herald Bahsei", "Bahsei")
AddEncounter(rg, FoundationEncounter("ENCOUNTER_RG_XALVAKKA", "Xalvakka", {
    validationCallouts = true,
    mechanics = { "PORTAL", "FLOOR_TRANSITION", "BEHEMOTH", "DEADSTAR", "EXECUTE" },
    researchConfidence = "live_validation",
    intelligenceDriven = true,
    strategyProfiles = {
        automatic = { label="Automatic", inferFloor=true },
        learning = { label="Learning", conservative=true, preserveDefensiveUltimate=true },
        trifecta = { label="Trifecta", conservative=false, preserveDefensiveUltimate=true },
    },
    burnWindowGuide = {
        { id="RG_XALVAKKA_OPENING", type="FULL_BURN", label="OPENING BURN", trigger={type="ENCOUNTER_STATE",state="OPENING"}, confidence="FOUNDATION" },
        { id="RG_XALVAKKA_TRANSITION", type="HOLD", label="HOLD FOR FLOOR", trigger={type="SIGNAL",key="FLOOR_TRANSITION"}, confidence="LIVE_VALIDATION" },
        { id="RG_XALVAKKA_EXECUTE_WINDOW", type="EXECUTE", label="FINAL BURN", trigger={type="BOSS_HEALTH",percent=20}, confidence="LIVE_VALIDATION" },
    },
    observationSignals = {
        health = {
            { id="RG_XALVAKKA_EXECUTE", key="EXECUTE", label="Final floor execute", percent=20, state="FINAL_BURN", confidence="live_validation_required" },
        },
    },
    researchSources = { "CrutchAlerts", "Code's Combat Alerts", "ESO encounter guides", "Conductor live capture" },
}), "Xalvakka")
TRIALS["Rockgrove"] = FoundationTrial("TRIAL_RG", "RG", 10, rg, { researchStatus = "FOUNDATION_LIVE_VALIDATION_ACTIVE" })

local dsr = {}
local twinsDsr = FoundationEncounter("ENCOUNTER_DSR_LYLANAR_TURLASSIL", "Lylanar and Turlassil", {
    mechanics = { "FIRE_ICE", "DOME", "SWAP", "IMMUNITY", "EXECUTE" },
    validationCallouts = true,
    researchConfidence = "live_validation",
    intelligenceDriven = true,
    strategyProfiles = {
        automatic = { label="Automatic", inferActiveBoss=true },
        learning = { label="Learning", conservative=true, holdDuring={"DOME","SWAP"} },
        swashbuckler = { label="Swashbuckler", conservative=false, preserveRecovery=true },
    },
    burnWindowGuide = {
        { id="DSR_TWINS_OPENING", type="FULL_BURN", label="OPENING BURN", trigger={type="ENCOUNTER_STATE",state="OPENING"}, confidence="FOUNDATION" },
        { id="DSR_TWINS_SWAP_HOLD", type="HOLD", label="HOLD FOR SWAP", trigger={type="SIGNAL",key="SWAP"}, confidence="LIVE_VALIDATION" },
        { id="DSR_TWINS_EXECUTE_WINDOW", type="EXECUTE", label="EXECUTE", trigger={type="BOSS_HEALTH",percent=25}, confidence="LIVE_VALIDATION" },
    },
    observationSignals = {
        health = {
            { id="DSR_TWINS_EXECUTE", key="EXECUTE", label="Combined execute", percent=25, state="FINAL_BURN", confidence="live_validation_required" },
        },
    },
    researchSources = { "CrutchAlerts Dreadsail Reef implementation", "Code's Combat Alerts", "ESO encounter guides", "Conductor Swash live capture" },
})
AddEncounter(dsr, twinsDsr, "Lylanar", "Turlassil", "Lylanar and Turlassil", "Lylanar & Turlassil")
AddEncounter(dsr, FoundationEncounter("ENCOUNTER_DSR_REEF_GUARDIAN", "Reef Guardian", {
    mechanics = { "SPLIT", "HEARTS", "BRIDGES", "IMMUNITY", "EXECUTE" },
    validationCallouts = true,
    researchConfidence = "live_validation",
    intelligenceDriven = true,
    strategyProfiles = {
        automatic = { label="Automatic", inferSplit=true },
        learning = { label="Learning", conservative=true },
        swashbuckler = { label="Swashbuckler", conservative=false },
    },
    burnWindowGuide = {
        { id="DSR_REEF_OPENING", type="FULL_BURN", label="OPENING BURN", trigger={type="ENCOUNTER_STATE",state="OPENING"}, confidence="FOUNDATION" },
        { id="DSR_REEF_SPLIT_HOLD", type="HOLD", label="HOLD FOR SPLIT", trigger={type="SIGNAL",key="SPLIT"}, confidence="LIVE_VALIDATION" },
        { id="DSR_REEF_EXECUTE_WINDOW", type="EXECUTE", label="EXECUTE", trigger={type="BOSS_HEALTH",percent=25}, confidence="LIVE_VALIDATION" },
    },
    observationSignals = {
        health = {
            { id="DSR_REEF_EXECUTE", key="EXECUTE", label="Execute", percent=25, state="FINAL_BURN", confidence="live_validation_required" },
        },
    },
    researchSources = { "CrutchAlerts Dreadsail Reef implementation", "Code's Combat Alerts", "ESO encounter guides", "Conductor Swash live capture" },
}), "Reef Guardian")
AddEncounter(dsr, FoundationEncounter("ENCOUNTER_DSR_TALERIA", "Tideborn Taleria", {
    mechanics = { "MAELSTROM", "BRIDGE", "WINTER_STORM", "MAGE", "WAVE", "EXECUTE" },
    validationCallouts = true,
    researchConfidence = "live_validation",
    intelligenceDriven = true,
    strategyProfiles = {
        automatic = { label="Automatic", inferBridgeAndMage=true },
        learning = { label="Learning", conservative=true, holdDuring={"MAELSTROM","BRIDGE","WINTER_STORM"} },
        swashbuckler = { label="Swashbuckler", conservative=false, mageBurnPriority=true },
    },
    burnWindowGuide = {
        { id="DSR_TALERIA_OPENING", type="FULL_BURN", label="OPENING BURN", trigger={type="ENCOUNTER_STATE",state="OPENING"}, confidence="FOUNDATION" },
        { id="DSR_TALERIA_HOLD_55", type="HOLD", label="HOLD AT 55%", trigger={type="BOSS_HEALTH",percent=55}, targetHealth=55, confidence="COMMUNITY_STRATEGY" },
        { id="DSR_TALERIA_POST_MAELSTROM", type="FULL_BURN", label="BURN AFTER MAELSTROM", trigger={type="SIGNAL",key="MAELSTROM_COMPLETED"}, targetHealth=50, confidence="LIVE_VALIDATION" },
        { id="DSR_TALERIA_EXECUTE_WINDOW", type="EXECUTE", label="EXECUTE", trigger={type="BOSS_HEALTH",percent=25}, confidence="LIVE_VALIDATION" },
    },
    observationSignals = {
        health = {
            { id="DSR_TALERIA_EXECUTE", key="EXECUTE", label="Execute", percent=25, state="FINAL_BURN", confidence="live_validation_required" },
        },
    },
    researchSources = { "CrutchAlerts Dreadsail Reef implementation", "Code's Combat Alerts", "ESO-Hub Dreadsail Reef guide", "Conductor Swash live capture" },
}), "Tideborn Taleria", "Taleria")
AddEncounter(dsr, FoundationEncounter("ENCOUNTER_DSR_BOW_BREAKER", "Bow Breaker", { mechanics = { "SIDE_BOSS" } }), "Bow Breaker")
AddEncounter(dsr, FoundationEncounter("ENCOUNTER_DSR_SAIL_RIPPER", "Sail Ripper", { mechanics = { "SIDE_BOSS" } }), "Sail Ripper")
TRIALS["Dreadsail Reef"] = FoundationTrial("TRIAL_DSR", "DSR", 11, dsr)

local se = {}
AddEncounter(se, FoundationEncounter("ENCOUNTER_SE_YASEYLA", "Exarchanic Yaseyla", { mechanics = { "ARCHERS", "HORROR", "WAMASU", "EXECUTE" } }), "Exarchanic Yaseyla", "Yaseyla")
local chimera = FoundationEncounter("ENCOUNTER_SE_TWELVANE_CHIMERA", "Archwizard Twelvane and Chimera", { mechanics = { "THREE_ASPECTS", "SPLIT", "EXECUTE" } })
AddEncounter(se, chimera, "Archwizard Twelvane", "Chimera", "Archwizard Twelvane and Chimera")
AddEncounter(se, FoundationEncounter("ENCOUNTER_SE_ANSUUL", "Ansuul the Tormentor", { mechanics = { "MAZE", "MEMORY", "PORTAL", "EXECUTE" } }), "Ansuul the Tormentor", "Ansuul")
TRIALS["Sanity's Edge"] = FoundationTrial("TRIAL_SE", "SE", 12, se)

local lc = {}
local ryelaz = FoundationEncounter("ENCOUNTER_LC_RYELAZ_ZILYESSIT", "Count Ryelaz and Zilyesset", { mechanics = { "LIGHT_DARK", "MIRRORMOOR", "EXECUTE" } })
AddEncounter(lc, ryelaz, "Count Ryelaz", "Zilyesset", "Count Ryelaz and Zilyesset", "Count Ryelaz & Zilyesset")
AddEncounter(lc, FoundationEncounter("ENCOUNTER_LC_CAVOT_AGNAN", "Cavot Agnan", { mechanics = { "MINIBOSS", "ADDS" } }), "Cavot Agnan")
AddEncounter(lc, FoundationEncounter("ENCOUNTER_LC_ORPHIC_SHARD", "Orphic Shattered Shard", { mechanics = { "MIRRORS", "ARCANE_KNOT", "MINIONS" } }), "Orphic Shattered Shard")
AddEncounter(lc, FoundationEncounter("ENCOUNTER_LC_XORYN", "Xoryn", { mechanics = { "ARCANE_KNOT", "CURRENT_SWAP", "EXECUTE" } }), "Xoryn")
TRIALS["Lucent Citadel"] = FoundationTrial("TRIAL_LC", "LC", 13, lc)

local oc = {}
AddEncounter(oc, FoundationEncounter("ENCOUNTER_OC_SHAPERS", "Shapers of Flesh", { mechanics = { "FLESH_SHAPING", "PORTALS", "ADDS" } }), "Shapers of Flesh", "The Shapers of Flesh")
local jynorah = FoundationEncounter("ENCOUNTER_OC_JYNORAH_SKORKHIF", "Jynorah and Skorkhif", { mechanics = { "DUAL_BOSS", "CARRION_PORTALS", "TITAN_PHASE", "EXECUTE" } })
AddEncounter(oc, jynorah, "Jynorah", "Skorkhif", "Jynorah and Skorkhif", "Jynorah & Skorkhif")
AddEncounter(oc, FoundationEncounter("ENCOUNTER_OC_KAZPIAN", "Overfiend Kazpian", { mechanics = { "CISTA", "ABDUCTORS", "PORTALS", "EXECUTE" } }), "Overfiend Kazpian", "Kazpian")
TRIALS["Ossein Cage"] = FoundationTrial("TRIAL_OC", "OC", 14, oc, { researchStatus = "NEWEST_TRIAL_RESEARCHED_PENDING_EXTENSIVE_VALIDATION" })

local function Copy(source)
    local result = {}
    for key, value in pairs(source or {}) do result[key] = value end
    return result
end

function Profiles:GetTrial(zoneName)
    local normalized = Normalize(zoneName)
    for name, definition in pairs(TRIALS) do
        if Normalize(name) == normalized then
            local result = definition
            result.name = name
            return result
        end
    end
    return nil
end

function Profiles:GetEncounter(trial, bossName, difficulty)
    if not trial then return nil end
    local normalizedBoss = Normalize(bossName)
    local source = trial.encounters and trial.encounters[normalizedBoss] or nil
    if not source then
        return {
            id = "ENCOUNTER_PROVISIONAL_" .. string.upper((trial.code or "UNKNOWN") .. "_" .. string.gsub(normalizedBoss, "[^%w]+", "_")),
            label = bossName ~= "" and bossName or "Boss Encounter",
            trialId = trial.id,
            trialCode = trial.code,
            difficulty = difficulty,
            validationOnly = true,
            foundation = true,
            confidence = "provisional",
            researchStatus = "UNRECOGNIZED_BOSS_PENDING_CAPTURE",
            phases = { "OPENING", "ACTIVE", "MECHANIC", "TRANSITION", "RECOVERY", "COMPLETE" },
            mechanics = {},
            responsibilities = DEFAULT_RESPONSIBILITIES,
            timeline = { "OPENING", "ACTIVE", "MECHANIC", "TRANSITION", "RECOVERY", "COMPLETE" },
            burnWindows = {},
        }
    end

    local selected = source[difficulty] or source.veteran or {}
    local result = Copy(selected)
    result.id = source.id
    result.label = source.label or bossName
    result.trialId = trial.id
    result.trialCode = trial.code
    result.difficulty = difficulty
    result.confidence = "research_foundation"
    result.researchStatus = trial.researchStatus
    result.phases = source.phases or {}
    result.mechanics = source.mechanics or {}
    result.responsibilities = source.responsibilities or DEFAULT_RESPONSIBILITIES
    result.timeline = source.timeline or {}
    -- Preserve the authored execution guidance. Earlier builds copied only the
    -- legacy burnWindows field, which silently discarded burnWindowGuide and
    -- left the Timeline with zero encounter steps.
    result.burnWindowGuide = source.burnWindowGuide or source.burnWindows or {}
    result.burnWindows = result.burnWindowGuide
    result.observationSignals = source.observationSignals or {}
    result.researchSources = source.researchSources or {}
    result.researchConfidence = source.researchConfidence
    result.intelligenceDriven = source.intelligenceDriven == true
    result.validationCallouts = source.validationCallouts == true
    result.supportedObjectives = trial.supportedObjectives or OBJECTIVES
    result.stateCandidates = trial.stateCandidates or FOUNDATION_STATES
    result.strategyProfiles = source.strategyProfiles or {}
    if SRC.EncounterKnowledgeRegistry and SRC.EncounterKnowledgeRegistry.DecorateEncounter then
        result = SRC.EncounterKnowledgeRegistry:DecorateEncounter(trial, source, result)
    end
    return result
end

function Profiles:GetObjectives()
    return OBJECTIVES
end

function Profiles:GetTrials()
    return TRIALS
end
