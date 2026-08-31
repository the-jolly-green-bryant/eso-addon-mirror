TetsuCombatHealerHelper = TetsuCombatHealerHelper or {}
local T = TetsuCombatHealerHelper

-- Raid-wide named Major/Minor pairs. One settings toggle per pair.
T.RaidBuffPairs = {
    { id = "slayer",     keysMaj = { "majorSlayer" },               keysMin = { "minorSlayer" } },
    { id = "force",      keysMaj = { "majorForce" },                keysMin = { "minorForce" } },
    { id = "berserk",    keysMaj = { "majorBerserk" },              keysMin = { "minorBerserk" } },
    { id = "resolve",    keysMaj = { "majorResolve" },              keysMin = { "minorResolve" } },
    { id = "vitality",   keysMaj = { "majorVitality" },             keysMin = { "minorVitality" } },
    { id = "wdspd",      keysMaj = { "majorSorcery", "majorBrutality" }, keysMin = { "minorSorcery", "minorBrutality" } },
    { id = "crit",       keysMaj = { "majorProphecy", "majorSavagery" }, keysMin = { "minorProphecy", "minorSavagery" } },
    { id = "recover",    keysMaj = { "majorIntellect", "majorEndurance" }, keysMin = { "minorIntellect", "minorEndurance" } },
    { id = "heroism",    keysMaj = { "majorHeroism" },              keysMin = { "minorHeroism" } },
}

-- Boss named pairs. Off-Balance uses Active | Immune instead of Mj | Mn.
T.BossDebuffPairs = {
    { id = "breach",         keysMaj = { "majorBreach" },         keysMin = { "minorBreach" } },
    { id = "vulnerability",  keysMaj = { "majorVulnerability" }, keysMin = { "minorVulnerability" } },
    { id = "brittle",        keysMaj = { "majorBrittle" },        keysMin = { "minorBrittle" } },
    { id = "offbalance",     keysMaj = { "offBalance" },          keysMin = { "offBalanceImm" }, ob = true },
    { id = "defile",         keysMaj = { "majorDefile" },         keysMin = { "minorDefile" } },
    { id = "fracture",       keysMaj = { "majorFracture" },       keysMin = { "minorFracture" } },
    { id = "cowardice",      keysMaj = { "majorCowardice" },      keysMin = { "minorCowardice" } },
    { id = "maim",           keysMaj = { "majorMaim" },           keysMin = { "minorMaim" } },
}

T.NameNeedles = T.NameNeedles or {}
T.PairNeedles = {
    minorSlayer = { "minor slayer", "малый палач", "kleiner schlächter" },
    minorForce = { "minor force", "малая сила", "kleine kraft", "force mineure" },
    majorBerserk = { "major berserk", "великая ярость", "großer berserker", "berserk majeur" },
    majorResolve = { "major resolve", "великая решимость", "große entschlossenheit" },
    majorVitality = { "major vitality", "великая жизненная сила", "große vitalität" },
    minorVitality = { "minor vitality", "малая жизненная сила", "kleine vitalität" },
    majorBrutality = { "major brutality", "великая жестокость", "große brutalität" },
    minorBrutality = { "minor brutality", "малая жестокость" },
    majorSorcery = { "major sorcery", "великое колдовство", "große zauberei" },
    minorSorcery = { "minor sorcery", "малое колдовство" },
    majorProphecy = { "major prophecy", "великое пророчество" },
    minorProphecy = { "minor prophecy", "малое пророчество" },
    majorSavagery = { "major savagery", "великая свирепость" },
    minorSavagery = { "minor savagery", "малая свирепость" },
    majorIntellect = { "major intellect", "великий интеллект" },
    minorIntellect = { "minor intellect", "малый интеллект" },
    majorEndurance = { "major endurance", "великая выносливость" },
    minorEndurance = { "minor endurance", "малая выносливость" },
    majorHeroism = { "major heroism", "великий героизм" },
    minorHeroism = { "minor heroism", "малый героизм" },
    majorBreach = { "major breach", "великий прорыв", "großer durchbruch" },
    minorBreach = { "minor breach", "малый прорыв", "kleiner durchbruch" },
    majorFracture = { "major fracture", "великий перелом" },
    minorFracture = { "minor fracture", "малый перелом" },
    majorVulnerability = { "major vulnerability", "великая уязвимость" },
    minorVulnerability = { "minor vulnerability", "малая уязвимость" },
    majorBrittle = { "major brittle", "великая хрупкость" },
    minorBrittle = { "minor brittle", "малая хрупкость" },
    majorCowardice = { "major cowardice", "великая трусость" },
    minorCowardice = { "minor cowardice", "малая трусость" },
    majorMaim = { "major maim", "великое калечение" },
    minorMaim = { "minor maim", "малое калечение" },
    majorDefile = { "major defile", "великое осквернение" },
    minorDefile = { "minor defile", "малое осквернение" },
    offBalanceImm = {
        "off balance immunity", "off-balance immunity", "offbalance immunity",
        "иммунитет к потере равновесия", "невосприимчивость к потере равновесия",
        "gleichgewichtsimmun",
    },
    offBalance = {
        "off-balance", "off balance", "offbalance",
        "потеря равновесия", "без равновесия",
        "aus dem gleichgewicht", "unausgeglichen",
    },
}

for key, list in pairs(T.PairNeedles) do
    T.NameNeedles[key] = list
end
if T.BuildLookupIndex then
    T.BuildLookupIndex()
end

local function Lower(s)
    if not s then return "" end
    return zo_strlower(tostring(s):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("%^.*", ""))
end

function T.MatchPairKey(abilityId, effectName)
    if T.LookupKeyForAbilityId then
        return T.LookupKeyForAbilityId(abilityId, effectName)
    end
    return nil
end

function T.PairEnabled(kind, id)
    local vars = T.savedVars
    if not vars then return true end
    local k = (kind == "buff" and "buffPair_" or "debuffPair_") .. id
    return vars[k] ~= false
end
