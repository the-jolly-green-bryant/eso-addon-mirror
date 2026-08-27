TetsuCombatHealerHelper = TetsuCombatHealerHelper or {}
local T = TetsuCombatHealerHelper

-- Ability ids collected from morph + rank tables. First live test may add extra
-- tick-ids if a morph applies a child effect.
T.Ability = {
    illustrious = {
        40058, 41251, 41253, 41255, -- Illustrious Healing ranks
        28385,                      -- Grand Healing (base)
        40060, 41244, 41247, 41250, -- Healing Springs ranks (same puddle family)
    },
    prayer = {
        40094, 41175, 41182, 41189, -- Combat Prayer ranks
        22265,                      -- Blessing of Protection
        40103, 35696,               -- Blessing of Restoration (other morph)
    },
    minorBerserk = {
        61735, 61687,
    },
    minorResolve = {
        61693, 61737,
    },
    powerfulAssault = {
        61771, 61763, 61772,
    },
    echoingVigor = {
        63227, 61507,
    },
    resolvingVigor = {
        63231, 61798,
    },
    radiatingRegen = {
        40079, 41278, 41283, 40066, 27062,
    },
    rapidRegen = {
        27068, 40076,
    },
    majorCourage = {
        61708, 109966, 142305, 147417,
    },
    energyOrb = {
        85434, 85431, 85432, 95057,
    },
    majorForce = {
        61747,
    },
    majorSlayer = {
        93109,
    },
    minorMagickasteal = {
        88401, 39173,
    },
    orbLockout = {
        63512, 48052, 95924,
    },
}

T.PUDDLE_RADIUS_M = 8
T.PUDDLE_DURATION_MS = 15000
T.PRAYER_ARM_DELAY_MS = 4000

-- Curated extra slots. Labels come from localization only (live GetAbilityName
-- on old sample ids was returning unrelated buffs like Major Sorcery).
T.SlotCatalog = {
    { key = "off" },
    { key = "powerfulAssault" },
    { key = "echoingVigor" },
    { key = "resolvingVigor" },
    { key = "radiatingRegen" },
    { key = "rapidRegen" },
    { key = "majorCourage" },
    { key = "energyOrb" },
    { key = "majorForce" },
    { key = "majorSlayer" },
    { key = "minorMagickasteal" },
    { key = "orbLockout" },
}

-- Name needles, lowercase. Matched against GetAbilityName(abilityId) so we do
-- not depend on a single rank/morph id being correct on console.
T.NameNeedles = {
    illustrious = {
        "illustrious healing", "healing springs", "grand healing",
        "блистательн", "исцеляющие родник", "великое исцеление",
    },
    prayer = {
        "combat prayer", "blessing of protection", "blessing of restoration",
        "боевая молитва", "благословение защиты", "благословение восстанов",
    },
    minorBerserk = {
        "minor berserk", "малое ожесточение", "kleiner berserker",
    },
    minorResolve = {
        "minor resolve", "малая решимость", "geringe entschlossenheit",
    },
    powerfulAssault = {
        "powerful assault", "мощный натиск",
    },
    echoingVigor = {
        "echoing vigor", "раздающаяся бодрость", "эхо бодрости",
    },
    resolvingVigor = {
        "resolving vigor", "крепнущая бодрость",
    },
    radiatingRegen = {
        "radiating regeneration", "излучающая регенерация",
        "излучающее восстановление",
    },
    rapidRegen = {
        "rapid regeneration", "быстрая регенерация",
    },
    majorCourage = {
        "major courage", "великая храбрость",
    },
    energyOrb = {
        "energy orb", "necrotic orb", "энергетическая сфера", "некротическая сфера",
    },
    majorForce = {
        "major force", "великая сила",
    },
    majorSlayer = {
        "major slayer", "великая решимость убийцы",
    },
    minorMagickasteal = {
        "minor magickasteal", "малое похищение магии",
    },
    orbLockout = {
        "healing combustion", "spear shards",
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
    if not abilityId then return false end
    if T.IsIllustrious and T.IsIllustrious[abilityId] then return true end
    return T.NameMatches(abilityId, "illustrious")
end

function T.TextMatchesNeedles(text, key)
    local needles = T.NameNeedles and T.NameNeedles[key]
    if not needles or not text or text == "" then return false end
    local name = zo_strlower(text)
    for i = 1, #needles do
        if name:find(needles[i], 1, true) then
            return true
        end
    end
    return false
end

local INTERNAL_KEYS = { "prayer", "illustrious", "minorBerserk", "minorResolve" }

function T.LookupKeyForAbilityId(abilityId, effectName)
    for i = 1, #INTERNAL_KEYS do
        local k = INTERNAL_KEYS[i]
        if T.TextMatchesNeedles(effectName, k) then
            return k
        end
    end
    if abilityId then
        if T.IsPrayer and T.IsPrayer[abilityId] then return "prayer" end
        if T.IsIllustrious and T.IsIllustrious[abilityId] then return "illustrious" end
        for i = 1, #INTERNAL_KEYS do
            local k = INTERNAL_KEYS[i]
            local ids = T.Ability[k]
            if ids then
                for j = 1, #ids do
                    if ids[j] == abilityId then return k end
                end
            end
            if T.NameMatches(abilityId, k) then return k end
        end
        for _, entry in ipairs(T.SlotCatalog) do
            if entry.key ~= "off" then
                local ids = T.Ability[entry.key]
                if ids then
                    for i = 1, #ids do
                        if ids[i] == abilityId then
                            return entry.key
                        end
                    end
                end
                if T.TextMatchesNeedles(effectName, entry.key) then
                    return entry.key
                end
                if T.NameMatches(abilityId, entry.key) then
                    return entry.key
                end
            end
        end
    else
        for _, entry in ipairs(T.SlotCatalog) do
            if entry.key ~= "off" and T.TextMatchesNeedles(effectName, entry.key) then
                return entry.key
            end
        end
    end
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

function T.SlotLabel(key)
    local L = T.L or {}
    if key == "off" or not key then
        return L.SLOT_OFF or "Off"
    end
    local map = {
        powerfulAssault = L.SLOT_PA or "Powerful Assault",
        echoingVigor    = L.SLOT_VIGOR_ECHO or "Echoing Vigor",
        resolvingVigor  = L.SLOT_VIGOR_RES or "Resolving Vigor",
        radiatingRegen  = L.SLOT_RAD_REGEN or "Radiating Regeneration",
        rapidRegen      = L.SLOT_RAPID_REGEN or "Rapid Regeneration",
        majorCourage    = L.SLOT_COURAGE or "Major Courage",
        energyOrb          = L.SLOT_ORB or "Energy Orb",
        majorForce         = L.SLOT_FORCE or "Major Force",
        majorSlayer        = L.SLOT_SLAYER or "Major Slayer",
        minorMagickasteal  = L.SLOT_MSTEAL or "Minor Magickasteal",
        orbLockout         = L.SLOT_ORB_LOCK or "Orb synergy lock",
        illustrious        = L.SLOT_IH or "Illustrious Healing",
        prayer             = L.SLOT_PRAYER or "Combat Prayer",
    }
    return map[key] or key
end

function T.SlotShort(key)
    local L = T.L or {}
    local map = {
        off               = "",
        powerfulAssault   = L.SHORT_PA or "PA",
        echoingVigor      = L.SHORT_VE or "EVig",
        resolvingVigor    = L.SHORT_VR or "RVig",
        radiatingRegen    = L.SHORT_RAD or "RadR",
        rapidRegen        = L.SHORT_RAP or "RapR",
        majorCourage      = L.SHORT_CRG or "Cour",
        energyOrb         = L.SHORT_ORB or "Orb",
        majorForce        = L.SHORT_FRC or "Forc",
        majorSlayer       = L.SHORT_SLY or "Slay",
        minorMagickasteal = L.SHORT_MS or "MStl",
        orbLockout        = L.SHORT_OLK or "Lock",
        illustrious       = L.SHORT_IH or "IH",
        prayer            = L.SHORT_PR or "Pray",
    }
    return map[key] or zo_strsub(T.SlotLabel(key) or key, 1, 4)
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
    local myZone, mx = GetUnitRawWorldPosition("player")
    local theirZone, tx = GetUnitRawWorldPosition(unitTag)
    if myZone and theirZone and myZone ~= theirZone then
        return false
    end
    if GetUnitZoneIndex and GetUnitZoneIndex("player") and GetUnitZoneIndex(unitTag) then
        if GetUnitZoneIndex("player") ~= GetUnitZoneIndex(unitTag) then
            return false
        end
    end
    if not tx or (tx == 0 and select(3, GetUnitRawWorldPosition(unitTag)) == 0) then
        if unitTag ~= "player" then
            return false
        end
    end
    return true
end

function T.EachGroupTag(callback)
    local seenName = {}
    local function emit(tag)
        if not tag or not DoesUnitExist or not DoesUnitExist(tag) then
            return
        end
        if T.UnitHere and not T.UnitHere(tag) then
            return
        end
        local name = GetUnitDisplayName(tag) or GetUnitName(tag) or tag
        if seenName[name] then return end
        seenName[name] = true
        callback(tag)
    end
    emit("player")
    local n = GetGroupSize and GetGroupSize() or 0
    for i = 1, n do
        emit(GetGroupUnitTagByIndex and GetGroupUnitTagByIndex(i))
    end
end
