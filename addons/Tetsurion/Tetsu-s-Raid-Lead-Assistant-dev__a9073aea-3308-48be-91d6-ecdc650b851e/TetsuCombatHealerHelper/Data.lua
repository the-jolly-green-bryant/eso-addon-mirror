TetsuCombatHealerHelper = TetsuCombatHealerHelper or {}
local T = TetsuCombatHealerHelper

-- Ability ids collected from morph + rank tables. First live test may add extra
-- tick-ids if a morph applies a child effect.
T.Ability = {
    -- Ground HoT family. Allies in the circle get a HoT; tick id 91342 is the
    -- live aura Combat Metrics sees, ranks are the skill itself.
    illustrious = {
        91342, 40058, 41251, 41253, 41255,
        28385,
        40060, 41244, 41247, 41250,
        41257, 41261, 41265,
    },
    -- Combat Prayer itself rarely lands as that name. Allies get Minor Berserk
    -- + Minor Resolve for 10s. Blessing of Protection / Restoration = resolve only.
    prayer = {
        40094, 41175, 41182, 41189, 41151,
        22265, 40103, 35696,
    },
    minorBerserk = {
        61735, 61687, 62175,
    },
    minorResolve = {
        61693, 61737, 61665,
    },
    -- Set: cast any Assault skill in combat -> WD/SD buff on you + 5 allies 12m 15s.
    -- 40225 is Warhorn Major Force, not this set.
    powerfulAssault = {
        61771, 61763, 61772,
    },
    -- Echoing Vigor (group HoT 15m / up to 16s). Cap 6 targets.
    echoingVigor = {
        63240, 63227, 61507, 61505, 63232, 63234, 63236,
    },
    -- Self-only morph.
    resolvingVigor = {
        63231, 61798, 63229,
    },
    vigor = {
        63240, 63227, 61507, 61505, 63232, 63234, 63236,
        63231, 61798, 63229, 61720,
    },
    radiatingRegen = {
        40079, 41278, 41283, 40066, 27062, 40069,
    },
    rapidRegen = {
        27068, 40076, 40072,
    },
    -- Olorime puddle, Spell Power Cure overheal, WW roar, etc. Same named buff.
    majorCourage = {
        61708, 109966, 142305, 147417, 121878, 121877, 62799,
    },
    energyOrb = {
        85431, 85432, 95057, 26188, 26192, 42038, 43439, 43443,
    },
    -- 40225 = Aggressive Horn Major Force (source id). 61747 = generic Major Force.
    majorForce = {
        61747, 40225,
    },
    minorForce = {
        61746,
    },
    majorSlayer = {
        93109, 121910,
    },
    minorCourage = {
        61707, 121876,
    },
    majorBerserk = {
        61736,
    },
    majorResolve = {
        61694,
    },
    majorVitality = {
        61748,
    },
    minorVitality = {
        61749,
    },
    majorBrutality = {
        61710,
    },
    minorBrutality = {
        61711,
    },
    majorSorcery = {
        61713,
    },
    minorSorcery = {
        61685,
    },
    majorProphecy = {
        61721,
    },
    minorProphecy = {
        61666,
    },
    majorSavagery = {
        61723,
    },
    minorSavagery = {
        61664,
    },
    majorIntellect = {
        61716,
    },
    minorIntellect = {
        61717,
    },
    majorEndurance = {
        61733,
    },
    minorEndurance = {
        61734,
    },
    majorHeroism = {
        61755,
    },
    minorHeroism = {
        61756,
    },
    majorBreach = {
        61743,
    },
    minorBreach = {
        79720, 34838,
    },
    majorMaim = {
        61740,
    },
    minorMaim = {
        61741,
    },
    majorVulnerability = {
        106754, 122177,
    },
    minorVulnerability = {
        79717, 61781,
    },
    majorCowardice = {
        147643, 143808,
    },
    minorCowardice = {
        147644,
    },
    majorDefile = {
        61726,
    },
    minorDefile = {
        61727,
    },
    minorMagickasteal = {
        88401, 39173, 26220,
    },
    orbLockout = {
        85434, 63512, 48052, 95924, 26869, 67717, 22270,
    },
    -- Heal cut extras (absorb / anti-heal). Defile ids live on majorDefile / minorDefile.
    healCut = {
        61742, 79851, 21927,
    },
    offBalance = {
        39077, 63003, 62988, 115001,
    },
    offBalanceImm = {
        134599, 102771,
    },
}

T.PUDDLE_RADIUS_M = 8
T.PUDDLE_DURATION_MS = 15000
T.PRAYER_ARM_DELAY_MS = 4000

-- Curated extra slots. Labels come from localization only (live GetAbilityName
-- on old sample ids was returning unrelated buffs like Major Sorcery).
T.SlotCatalog = {
    { key = "off" },
    { key = "prayer" },
    { key = "radiatingRegen" },
    { key = "rapidRegen" },
    { key = "powerfulAssault" },
    { key = "majorCourage" },
    { key = "minorCourage" },
    { key = "majorForce" },
    { key = "majorSlayer" },
    { key = "minorBerserk" },
    { key = "minorResolve" },
    { key = "minorMagickasteal" },
}

-- Name needles, lowercase. Matched against GetAbilityName(abilityId) so we do
-- not depend on a single rank/morph id being correct on console.
T.NameNeedles = {
    illustrious = {
        "illustrious healing", "healing springs", "grand healing",
        "блистательное исцеление", "блистательн", "прославленное исцеление",
        "великое исцеление", "высшее лечение",
        "исцеляющие источники", "целительные источники", "исцеляющие родник",
        "erhabene heilung", "heilende quellen", "heilendequellen", "große heilung", "grosse heilung",
        "guérison illustre", "sources de soins", "grande guérison",
        "sanación ilustre", "manantiales curativos", "gran sanación",
        "輝かしい治癒", "華麗なる治癒", "グランドヒーリング", "ヒーリングスプリング",
        "辉煌治疗", "宏伟治疗", "治疗之泉",
    },
    prayer = {
        "combat prayer", "blessing of protection", "blessing of restoration",
        "боевая молитва", "благословение защиты", "благословение восстанов",
        "kampfgebet", "segen des schutzes", "segen der wiederherstellung",
        "prière de combat", "bénédiction de protection", "bénédiction de rétablissement",
        "oración de combate", "rezo de combate", "bendición de protección", "bendición de restauración",
        "戦闘の祈り", "戦闘祈", "加護の祝福",
        "战斗祈祷", "战斗祷告", "防护祝福",
    },
    minorBerserk = {
        "minor berserk", "kleiner raserei", "kleinere raserei",
        "малая ярость", "малое ожесточение",
        "berserk mineur",
        "locura menor", "rabia menor",
        "マイナーバーサーク",
        "次级狂怒",
    },
    minorResolve = {
        "minor resolve", "kleinere entschlossenheit", "kleine entschlossenheit",
        "малая решимость",
        "résolution mineure",
        "resolución menor",
        "マイナーリゾルブ",
        "次级坚定", "次级决心",
    },
    powerfulAssault = {
        "powerful assault",
        "мощный натиск", "мощное нападение",
        "kraftvoller ansturm",
        "assaut puissant",
        "asalto poderoso",
        "強力な襲撃",
        "强力突击",
    },
    vigor = {
        "echoing vigor", "resolving vigor", "vigor",
        "гулкая бодрость", "отголосок бодрости", "эхо бодрости", "бодрость",
        "widerhallender elan", "widerhallende stärke", "lösender elan", "elan",
        "vigueur retentissante", "vigueur résolue", "vigueur",
        "vigor resonante", "vigor resolutivo",
        "反響する活力", "決意の活力",
        "回响活力", "回响的活力", "坚定活力",
    },
    echoingVigor = {
        "echoing vigor", "vigor",
        "гулкая бодрость", "отголосок бодрости", "эхо бодрости", "бодрость",
        "widerhallender elan", "widerhallende stärke", "elan",
        "vigueur retentissante", "vigueur",
        "vigor resonante",
        "反響する活力",
        "回响活力", "回响的活力",
    },
    resolvingVigor = {
        "resolving vigor",
        "крепнущая бодрость", "разрешающая бодрость",
        "lösender elan", "lösende stärke",
        "vigueur résolue",
        "vigor resolutivo",
        "決意の活力",
        "坚定活力",
    },
    radiatingRegen = {
        "radiating regeneration",
        "излучающая регенерация", "излучающее восстановление",
        "strahlende regeneration",
        "régénération rayonnante",
        "regeneración radiante",
        "放射再生",
        "辐射再生",
    },
    rapidRegen = {
        "rapid regeneration",
        "быстрая регенерация",
        "schnelle regeneration",
        "régénération rapide",
        "regeneración rápida",
        "迅速再生",
        "快速再生",
    },
    majorCourage = {
        "major courage",
        "великая храбрость", "великий мужество",
        "größerer mut", "großer mut",
        "courage majeur",
        "valentía mayor",
        "メジャーカレッジ", "大勇気",
        "强效勇气", "主要勇气",
    },
    minorCourage = {
        "minor courage",
        "малая храбрость",
        "kleinerer mut", "kleiner mut",
        "courage mineur",
        "valentía menor",
        "マイナーカレッジ",
        "次级勇气",
    },
    energyOrb = {
        "energy orb", "necrotic orb",
        "энергетическая сфера", "некротическая сфера",
        "energetische kugel", "nekrotische kugel",
        "orbe d'énergie", "orbe nécrotique",
        "orbe de energía", "orbe necrótico",
        "エネルギーオーブ",
        "能量球", "死灵球",
    },
    majorForce = {
        "major force",
        "великая сила",
        "größere kraft", "große kraft",
        "force majeure",
        "fuerza mayor",
        "メジャーフォース",
        "强效力",
    },
    majorSlayer = {
        "major slayer",
        "великий палач", "великая резня",
        "großer schlächter", "größerer schlächter",
        "tueur majeur",
        "exterminador mayor",
        "メジャースレイヤー",
        "强效杀戮",
    },
    minorMagickasteal = {
        "minor magickasteal", "minor magicka steal",
        "малое похищение магии",
        "kleiner magickaraub",
        "vol de magie mineur",
        "robo de magia menor",
        "マイナーマジカスチール",
        "次级法力偷取",
    },
    orbLockout = {
        "healing combustion", "combustion",
        "spear shards", "luminous shards",
        "исцеляющее возгорание", "возгорание", "осколки копья",
        "heilende verbrennung", "verbrennung",
        "combustion curative",
        "combustión curativa",
        "combustion curative",
    },
    healCut = {
        "major defile", "minor defile", "defile",
        "heal absorb", "healing absorb", "healing immunity", "anti-heal",
        "осквернение", "хилорез", "поглощение исцеления",
        "entweihung", "heilungsabsor",
        "souillure", "absorption de soins",
        "profanación",
    },
}

T.Textures = {
    circle = "EsoUI/Art/ActionBar/abilityHighlight_mage_med.dds",
    square = "EsoUI/Art/Buttons/swatchFrame_white_notselected.dds",
    fallbackSquare = "EsoUI/Art/Miscellaneous/timerbar_genericFill.dds",
    prayer = "EsoUI/Art/Buttons/Decline_up.dds",
}

local function BuildLookup(list)
    local t = {}
    for i = 1, #list do
        t[list[i]] = true
    end
    return t
end

T.IsIllustrious = BuildLookup(T.Ability.illustrious)
T.IsPrayer = BuildLookup(T.Ability.prayer)

function T.AbilityName(abilityId)
    if not abilityId or abilityId == 0 or not GetAbilityName then return "" end
    local ok, name = pcall(GetAbilityName, abilityId)
    if not ok or not name then return "" end
    return zo_strlower(name)
end

function T.NameMatches(abilityId, key)
    local needles = T.NameNeedles and T.NameNeedles[key]
    if not needles then return false end
    local name = T.AbilityName(abilityId)
    if name == "" then return false end
    for i = 1, #needles do
        if name:find(needles[i], 1, true) then
            return true
        end
    end
    return false
end

function T.IsIllustriousAbility(abilityId)
    return abilityId and T.IsIllustrious and T.IsIllustrious[abilityId] and true or false
end

local function CleanName(text)
    if not text or text == "" then return "" end
    text = tostring(text)
    text = text:gsub("|c%x%x%x%x%x%x%x%x", "")
    text = text:gsub("|r", "")
    text = text:gsub("|t.-|t", "")
    return zo_strlower(text)
end

function T.TextMatchesNeedles(text, key)
    local needles = T.NameNeedles and T.NameNeedles[key]
    if not needles then return false end
    local name = CleanName(text)
    if name == "" then return false end
    for i = 1, #needles do
        if name:find(needles[i], 1, true) then
            return true
        end
    end
    return false
end

local INTERNAL_KEYS = { "prayer", "illustrious", "minorBerserk", "minorResolve", "healCut" }

local function AliasKey(key)
    if key == "echoingVigor" or key == "resolvingVigor" then
        return "vigor"
    end
    return key
end

-- O(1) after first sighting. The old scanner allocated dozens of strings
-- per EVENT_EFFECT_CHANGED and ran on every combat tick.
local idToKey = {}
local nameToKey = {}
local needleList = {}

function T.BuildLookupIndex()
    needleList = {}
    idToKey = {}
    local deferred = {
        healCut = true,
        vigor = true,
        echoingVigor = true,
        resolvingVigor = true,
    }
    local function assign(key, ids)
        if type(ids) ~= "table" then return end
        local mapped = AliasKey(key)
        for i = 1, #ids do
            local id = ids[i]
            if id and idToKey[id] == nil then
                idToKey[id] = mapped
            end
        end
    end
    if T.Ability then
        for key, ids in pairs(T.Ability) do
            if not deferred[key] then
                assign(key, ids)
            end
        end
        for key, ids in pairs(T.Ability) do
            if deferred[key] then
                assign(key, ids)
            end
        end
    end
    local function addNeedles(key, list)
        if not list then return end
        local mapped = AliasKey(key)
        for i = 1, #list do
            needleList[#needleList + 1] = { list[i], mapped }
        end
    end
    if T.NameNeedles then
        for key, list in pairs(T.NameNeedles) do
            addNeedles(key, list)
        end
    end
    if T.PairNeedles then
        for key, list in pairs(T.PairNeedles) do
            addNeedles(key, list)
        end
    end
end

T.BuildLookupIndex()

function T.LookupKeyForAbilityId(abilityId, effectName)
    if abilityId and abilityId ~= 0 then
        local cached = idToKey[abilityId]
        if cached ~= nil then
            if cached == false then return nil end
            return cached
        end
        if T.IsPrayer and T.IsPrayer[abilityId] then
            idToKey[abilityId] = "prayer"
            return "prayer"
        end
        if T.IsIllustrious and T.IsIllustrious[abilityId] then
            idToKey[abilityId] = "illustrious"
            return "illustrious"
        end
    end
    local name = CleanName(effectName)
    if name ~= "" then
        local cached = nameToKey[name]
        if cached ~= nil then
            if abilityId and abilityId ~= 0 then idToKey[abilityId] = cached end
            if cached == false then return nil end
            return cached
        end
        if name:find("immun", 1, true) and (name:find("off", 1, true) or name:find("равновес", 1, true) or name:find("gleichgewicht", 1, true)) then
            nameToKey[name] = "offBalanceImm"
            if abilityId and abilityId ~= 0 then idToKey[abilityId] = "offBalanceImm" end
            return "offBalanceImm"
        end
        local hitKey, hitLen = nil, 0
        for i = 1, #needleList do
            local needle = needleList[i][1]
            if needle ~= "" and name:find(needle, 1, true) and #needle > hitLen then
                hitKey = needleList[i][2]
                hitLen = #needle
            end
        end
        if hitKey then
            nameToKey[name] = hitKey
            if abilityId and abilityId ~= 0 and idToKey[abilityId] == nil then
                idToKey[abilityId] = hitKey
            end
            return hitKey
        end
        nameToKey[name] = false
    end
    -- Never negative-cache an abilityId when the name was empty. Combat log
    -- often arrives with id only; a later EFFECT_CHANGED still needs to learn it.
    return nil
end

function T.SlotIndexByKey(key)
    for i = 1, #T.SlotCatalog do
        if T.SlotCatalog[i].key == key then
            return i
        end
    end
    return 1
end

function T.SlotKeyByIndex(index)
    local entry = T.SlotCatalog[index]
    return entry and entry.key or "off"
end

T.EnglishName = {
    off = "Off",
    prayer = "Combat Prayer",
    illustrious = "Illustrious Healing",
    radiatingRegen = "Radiating Regeneration",
    rapidRegen = "Rapid Regeneration",
    powerfulAssault = "Powerful Assault",
    majorCourage = "Major Courage",
    minorCourage = "Minor Courage",
    majorForce = "Major Force",
    majorSlayer = "Major Slayer",
    minorBerserk = "Minor Berserk",
    minorResolve = "Minor Resolve",
    minorMagickasteal = "Minor Magickasteal",
    slayer = "Slayer",
    force = "Force",
    berserk = "Berserk",
    resolve = "Resolve",
    vitality = "Vitality",
    wdspd = "Sorcery/Brutality",
    crit = "Prophecy/Savagery",
    recover = "Intellect/Endurance",
    heroism = "Heroism",
    breach = "Breach",
    fracture = "Fracture",
    vulnerability = "Vulnerability",
    brittle = "Brittle",
    cowardice = "Cowardice",
    maim = "Maim",
    defile = "Defile",
    offbalance = "Off Balance",
}

-- Healer HUD default (no custom text): drop Major/Minor prefix.
T.HudBareName = {
    majorCourage = "Courage",
    minorCourage = "Courage",
    majorForce = "Force",
    majorSlayer = "Slayer",
    minorBerserk = "Berserk",
    minorResolve = "Resolve",
    minorMagickasteal = "Magickasteal",
}

function T.WorldHudVisible()
    if SCENE_MANAGER and SCENE_MANAGER.IsShowing then
        if SCENE_MANAGER:IsShowing("hud") or SCENE_MANAGER:IsShowing("hudui") then
            return true
        end
        return false
    end
    if HUD_SCENE and HUD_SCENE.IsShowing and HUD_SCENE:IsShowing() then return true end
    if HUD_UI_SCENE and HUD_UI_SCENE.IsShowing and HUD_UI_SCENE:IsShowing() then return true end
    return true
end

T.DotColors = {
    green  = { 0.12, 1.00, 0.32 },
    blue   = { 0.25, 0.55, 1.00 },
    red    = { 1.00, 0.22, 0.18 },
    yellow = { 1.00, 0.82, 0.18 },
    orange = { 1.00, 0.55, 0.12 },
    purple = { 0.78, 0.38, 1.00 },
    cyan   = { 0.20, 0.92, 0.95 },
    white  = { 0.92, 0.94, 0.96 },
}

function T.ColumnColor(index)
    local vars = T.savedVars
    local name = vars and vars["hudColColor" .. index]
    local rgb = name and T.DotColors[name]
    if rgb then return rgb end
    local fallback = { "green", "yellow", "cyan", "orange", "purple" }
    return T.DotColors[fallback[index] or "green"]
end

-- Console zo_strlen / zo_strsub count UTF-8 bytes, not letters.
-- "Луч" is 3 letters / 6 bytes; a 4-byte clip becomes "Лу".
local function Utf8Next(s, i)
    local c = s:byte(i)
    if not c then return nil end
    if c < 0x80 then return i + 1 end
    if c < 0xE0 then return i + 2 end
    if c < 0xF0 then return i + 3 end
    return i + 4
end

function T.Utf8Len(s)
    if not s or s == "" then return 0 end
    s = tostring(s)
    local n, i, lim = 0, 1, #s
    while i <= lim do
        local nxt = Utf8Next(s, i)
        if not nxt then break end
        n = n + 1
        i = nxt
    end
    return n
end

function T.Utf8Sub(s, from, to)
    if not s or s == "" then return "" end
    s = tostring(s)
    from = from or 1
    if from < 1 then from = 1 end
    local i, n, startb, lim = 1, 0, nil, #s
    while i <= lim do
        local nxt = Utf8Next(s, i)
        if not nxt then break end
        n = n + 1
        if n == from then startb = i end
        if to and n == to then
            return s:sub(startb or 1, nxt - 1)
        end
        i = nxt
    end
    if startb then return s:sub(startb) end
    return ""
end

function T.ClipLabel(text, maxLen)
    if not text then return "" end
    text = tostring(text):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    if not maxLen or maxLen < 1 then return text end
    if T.Utf8Len(text) <= maxLen then return text end
    return T.Utf8Sub(text, 1, maxLen)
end

function T.GetCustomLabel(key)
    local vars = T.savedVars
    if vars and vars.customLabel and type(vars.customLabel[key]) == "string" then
        local raw = vars.customLabel[key]:gsub("^%s+", ""):gsub("%s+$", "")
        if raw ~= "" then
            return raw
        end
    end
    return nil
end

function T.DisplayBaseName(key)
    if not key or key == "off" then return "" end
    if T.HudBareName and T.HudBareName[key] then
        return T.HudBareName[key]
    end
    return T.EnglishName[key] or key
end

function T.HudLabel(key, maxLen)
    if not key or key == "off" then return "" end
    local text = T.GetCustomLabel(key) or T.DisplayBaseName(key)
    return T.ClipLabel(text, maxLen)
end

function T.SlotLabel(key)
    if key == "off" or not key then
        return "Off"
    end
    return T.EnglishName[key] or key
end

T.HudShortName = {
    prayer = "Pray",
    powerfulAssault = "PA",
    majorCourage = "Cour",
    minorCourage = "mCou",
    radiatingRegen = "Rad",
    rapidRegen = "Rap",
    majorForce = "Forc",
    majorSlayer = "Slay",
    minorBerserk = "Bers",
    minorResolve = "Res",
    minorMagickasteal = "MStl",
    slayer = "Slay",
    force = "Forc",
    berserk = "Bers",
    resolve = "Res",
    vitality = "Vit",
    wdspd = "WdSd",
    crit = "Crit",
    recover = "Rec",
    heroism = "Hero",
    breach = "Brch",
    fracture = "Frac",
    vulnerability = "Vuln",
    brittle = "Brit",
    cowardice = "Cow",
    maim = "Maim",
    defile = "Def",
    offbalance = "OB",
}

T.PairLocaleKey = {
    slayer = "PAIR_SLAYER",
    force = "PAIR_FORCE",
    berserk = "PAIR_BERSERK",
    resolve = "PAIR_RESOLVE",
    vitality = "PAIR_VITALITY",
    wdspd = "PAIR_WDSPD",
    crit = "PAIR_CRIT",
    recover = "PAIR_RECOVER",
    heroism = "PAIR_HEROISM",
    breach = "PAIR_BREACH",
    fracture = "PAIR_FRACTURE",
    vulnerability = "PAIR_VULNERABILITY",
    brittle = "PAIR_BRITTLE",
    cowardice = "PAIR_COWARDICE",
    maim = "PAIR_MAIM",
    defile = "PAIR_DEFILE",
    offbalance = "PAIR_OFFBALANCE",
}

function T.SlotShort(key)
    if not key or key == "off" then return "" end
    local custom = T.GetCustomLabel(key)
    if custom then return T.ClipLabel(custom, 4) end
    if T.HudShortName and T.HudShortName[key] then
        return T.HudShortName[key]
    end
    return T.ClipLabel(T.DisplayBaseName(key), 4)
end

function T.PairPanelLabel(id)
    if not id then return "" end
    local custom = T.GetCustomLabel(id)
    if custom then return T.ClipLabel(custom, 8) end
    local L = T.L
    local loc = T.PairLocaleKey and T.PairLocaleKey[id]
    if L and loc and L[loc] and L[loc] ~= "" then
        return T.ClipLabel(L[loc], 8)
    end
    if T.HudShortName and T.HudShortName[id] then
        return T.HudShortName[id]
    end
    return T.ClipLabel((T.EnglishName and T.EnglishName[id]) or id, 8)
end

function T.ResolveSlotKey(val)
    if not val or val == "off" then return "off" end
    if val == "energyOrb" or val == "orbLockout" then return "off" end
    local catalog = T.SlotCatalog or {}
    for i = 1, #catalog do
        if catalog[i].key == val then
            return val
        end
    end
    local vars = T.savedVars
    for i = 1, #catalog do
        local key = catalog[i].key
        if key and key ~= "off" then
            if T.EnglishName[key] == val then return key end
            if T.HudBareName and T.HudBareName[key] == val then return key end
            if vars and vars.customLabel and vars.customLabel[key] == val then return key end
        end
    end
    return "off"
end

function T.WorldToRender(worldX, worldY, worldZ)
    -- Raw world units are centimetres. This API returns render-space metres.
    -- Do NOT fall back to raw/100 here: that origin is "off the map".
    if type(WorldPositionToGuiRender3DPosition) ~= "function" then
        return nil
    end
    if type(worldX) ~= "number" then return nil end
    local ok, rx, ry, rz = pcall(WorldPositionToGuiRender3DPosition, worldX, worldY, worldZ)
    if ok and type(rx) == "number" and type(ry) == "number" and type(rz) == "number" then
        return rx, ry, rz
    end
    return nil
end

function T.IsSelf(unitTag)
    if not unitTag then return false end
    if unitTag == "player" then return true end
    if AreUnitsEqual then
        local ok, eq = pcall(AreUnitsEqual, "player", unitTag)
        if ok and eq then return true end
    end
    return false
end

function T.StableUnitKey(unitTag)
    if not unitTag then return nil end
    if T.IsSelf(unitTag) then return "player" end
    if GetUnitDisplayName then
        local n = GetUnitDisplayName(unitTag)
        if n and n ~= "" then return n end
    end
    if GetUnitName then
        local n = GetUnitName(unitTag)
        if n and n ~= "" then return n end
    end
    return unitTag
end

function T.GetUnitMeters(unitTag)
    if not unitTag then return nil end
    if DoesUnitExist and not DoesUnitExist(unitTag) then return nil end
    local ok, zoneId, worldX, worldY, worldZ = pcall(GetUnitRawWorldPosition, unitTag)
    if not ok then return nil end
    if not worldX or (worldX == 0 and worldY == 0 and worldZ == 0) then
        return nil
    end
    return worldX / 100, worldY / 100, worldZ / 100, zoneId
end

function T.GetUnitRaw(unitTag)
    if not unitTag then return nil end
    if DoesUnitExist and not DoesUnitExist(unitTag) then return nil end
    local ok, zoneId, worldX, worldY, worldZ = pcall(GetUnitRawWorldPosition, unitTag)
    if not ok then return nil end
    if not worldX or (worldX == 0 and worldY == 0 and worldZ == 0) then
        return nil
    end
    return worldX, worldY, worldZ, zoneId
end

function T.UnitHere(unitTag)
    if not unitTag then return false end
    if DoesUnitExist and not DoesUnitExist(unitTag) then return false end
    if IsUnitOnline and unitTag ~= "player" and not IsUnitOnline(unitTag) then
        return false
    end
    return true
end

local seenName = {}

function T.EachGroupTag(callback)
    for k in pairs(seenName) do
        seenName[k] = nil
    end
    local function emit(tag)
        if not tag or tag == "" then return end
        if DoesUnitExist and not DoesUnitExist(tag) then return end
        if IsUnitOnline and tag ~= "player" and not IsUnitOnline(tag) then return end
        local name = tag
        if GetUnitDisplayName then
            name = GetUnitDisplayName(tag) or name
        end
        if seenName[name] then return end
        seenName[name] = true
        callback(tag)
    end
    emit("player")
    local n = GetGroupSize and GetGroupSize() or 0
    for i = 1, n do
        if GetGroupUnitTagByIndex then
            emit(GetGroupUnitTagByIndex(i))
        end
    end
end
