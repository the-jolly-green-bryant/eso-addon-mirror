-- CharacterMarkdown - Combat Data Collector
-- Composition logic moved from API layer

local CM = CharacterMarkdown

local math_floor = math.floor

-- =====================================================
-- COMBAT STATS
-- =====================================================

local function CollectCombatStatsData()
    -- Use API layer granular functions (composition at collector level)
    local health = CM.api.combat.GetStat(STAT_HEALTH_MAX)
    local magicka = CM.api.combat.GetStat(STAT_MAGICKA_MAX)
    local stamina = CM.api.combat.GetStat(STAT_STAMINA_MAX)
    local powerStats = CM.api.combat.GetPowerStats()
    local regenStats = CM.api.combat.GetRegenStats()

    local stats = {}

    -- ===== RESOURCES =====
    stats.health = health or 0
    stats.magicka = magicka or 0
    stats.stamina = stamina or 0

    -- ===== OFFENSIVE POWER =====
    stats.weaponPower = powerStats.physical and powerStats.physical.power or 0
    stats.spellPower = powerStats.spell and powerStats.spell.power or 0

    -- ===== CRITICAL STRIKE =====
    stats.weaponCritRating = powerStats.physical and powerStats.physical.crit or 0
    stats.spellCritRating = powerStats.spell and powerStats.spell.crit or 0

    -- Calculate crit chance percentages (ESO formula: Rating / 219 = % at CP 160+)
    stats.weaponCritChance = stats.weaponCritRating > 0 and math_floor((stats.weaponCritRating / 219) * 10) / 10 or 0
    stats.spellCritChance = stats.spellCritRating > 0 and math_floor((stats.spellCritRating / 219) * 10) / 10 or 0

    -- ===== PENETRATION =====
    stats.physicalPenetration = powerStats.physical and powerStats.physical.penetration or 0
    stats.spellPenetration = powerStats.spell and powerStats.spell.penetration or 0

    -- ===== RESISTANCES =====
    stats.physicalResist = powerStats.resistance and powerStats.resistance.physical or 0
    stats.spellResist = powerStats.resistance and powerStats.resistance.spell or 0

    -- Calculate mitigation percentage (ESO formula: Resist / (Resist + 50 * Level))
    local playerLevel = CM.api.character.GetLevel().level or 50
    local resistDivisor = 50 * playerLevel
    stats.physicalMitigation = stats.physicalResist > 0
            and math_floor((stats.physicalResist / (stats.physicalResist + resistDivisor)) * 1000) / 10
        or 0
    stats.spellMitigation = stats.spellResist > 0
            and math_floor((stats.spellResist / (stats.spellResist + resistDivisor)) * 1000) / 10
        or 0

    -- ===== RECOVERY =====
    stats.healthRecovery = regenStats.health or 0
    stats.magickaRecovery = regenStats.magicka or 0
    stats.staminaRecovery = regenStats.stamina or 0

    -- ===== COMPUTED FIELDS =====

    -- Effective Health (health with mitigation)
    local effectiveHealthPhysical = stats.health
    local effectiveHealthSpell = stats.health
    if stats.physicalMitigation > 0 then
        effectiveHealthPhysical = stats.health / (1 - (stats.physicalMitigation / 100))
    end
    if stats.spellMitigation > 0 then
        effectiveHealthSpell = stats.health / (1 - (stats.spellMitigation / 100))
    end
    stats.effectiveHealth = {
        physical = math.floor(effectiveHealthPhysical),
        spell = math.floor(effectiveHealthSpell),
        average = math.floor((effectiveHealthPhysical + effectiveHealthSpell) / 2),
    }

    -- Resource Ratios
    local totalResources = stats.health + stats.magicka + stats.stamina
    if totalResources > 0 then
        stats.resourceRatios = {
            health = math.floor((stats.health / totalResources) * 100),
            magicka = math.floor((stats.magicka / totalResources) * 100),
            stamina = math.floor((stats.stamina / totalResources) * 100),
        }
    else
        stats.resourceRatios = {
            health = 0,
            magicka = 0,
            stamina = 0,
        }
    end

    -- DPS Estimates (rough calculations based on power and crit)
    -- These are rough estimates, not exact DPS
    local weaponDPS = stats.weaponPower
    local spellDPS = stats.spellPower
    if stats.weaponCritChance > 0 then
        weaponDPS = weaponDPS * (1 + (stats.weaponCritChance / 100) * 0.5) -- Assume 50% crit damage bonus
    end
    if stats.spellCritChance > 0 then
        spellDPS = spellDPS * (1 + (stats.spellCritChance / 100) * 0.5)
    end
    stats.dpsEstimates = {
        weapon = math.floor(weaponDPS),
        spell = math.floor(spellDPS),
        average = math.floor((weaponDPS + spellDPS) / 2),
    }

    -- Advanced Stats
    local coreStats = CM.api.combat.GetCoreAbilityStats()
    local resistances = CM.api.combat.GetResistances()
    local damageBonuses = CM.api.combat.GetDamageBonuses()
    local healingBonuses = CM.api.combat.GetHealingBonuses()
    local utilityStats = CM.api.combat.GetUtilityStats()

    -- DERIVED CALCULATIONS (Fallback for missing API constants)

    -- 0. Light & Heavy Attack Damage
    -- Formulas from docs/formulas.md:
    -- Light Attack: (Max Resource * 0.04) + (Damage * 1.0)
    -- Heavy Attack: (Max Resource * 0.08) + (Damage * 2.0)
    -- Logic: Use higher of Stamina/WeaponDmg or Magicka/SpellDmg

    local stamLA = (stats.stamina * 0.04) + stats.weaponPower
    local magLA = (stats.magicka * 0.04) + stats.spellPower
    coreStats.lightAttackDamage = math_floor(math.max(stamLA, magLA))

    local stamHA = (stats.stamina * 0.08) + (stats.weaponPower * 2.0)
    local magHA = (stats.magicka * 0.08) + (stats.spellPower * 2.0)
    coreStats.heavyAttackDamage = math_floor(math.max(stamHA, magHA))

    -- 1. Bash Damage: (Max Stamina * 0.1065) + Weapon Power
    if not coreStats.bashDamage or coreStats.bashDamage == 0 then
        coreStats.bashDamage = math_floor((stats.stamina * 0.1065) + stats.weaponPower)
    end

    -- 2. Block Mitigation & Speed
    if not coreStats.blockMitigation or coreStats.blockMitigation == 0 then
        coreStats.blockMitigation = 50 -- Base 50%
    end
    if not coreStats.blockSpeed or coreStats.blockSpeed == 0 then
        coreStats.blockSpeed = 40 -- Base 40%
    end

    -- 3. Resistance Mapping & Percentage Calculation
    -- Formula: Mitigation % = Resistance / 660
    -- Matches screenshot: ~10.5k resist / 660 = ~16.0%

    local function CalculateMitigationPercent(resistValue)
        if not resistValue or resistValue <= 0 then
            return 0
        end
        local percent = resistValue / 660
        return math_floor(percent * 10) / 10 -- Round to 1 decimal
    end

    -- Map specific resistances if 0
    local physRes = stats.physicalResist
    local spellRes = stats.spellResist

    local function EnsureResist(val, fallback)
        return (val and val > 0) and val or fallback
    end

    local enhancedResistances = {
        flame = { value = EnsureResist(resistances.flame, spellRes), percent = 0 },
        shock = { value = EnsureResist(resistances.shock, spellRes), percent = 0 },
        frost = { value = EnsureResist(resistances.frost, spellRes), percent = 0 },
        magic = { value = EnsureResist(resistances.magic, spellRes), percent = 0 },
        disease = { value = EnsureResist(resistances.disease, physRes), percent = 0 },
        poison = { value = EnsureResist(resistances.poison, physRes), percent = 0 },
        bleed = { value = EnsureResist(resistances.bleed, physRes), percent = 0 },
        physical = { value = physRes, percent = 0 },
        spell = { value = spellRes, percent = 0 },
        critical = { value = resistances.critical, percent = 0 },
    }

    -- Calculate percentages for all
    for k, v in pairs(enhancedResistances) do
        if k ~= "critical" then
            v.percent = CalculateMitigationPercent(v.value)
        end
    end

    -- 4. Critical Damage Default
    if not damageBonuses.criticalDamage or damageBonuses.criticalDamage == 0 then
        damageBonuses.criticalDamage = 50 -- Base is 50% (1.5x)
    end

    stats.advanced = {
        core = coreStats,
        resistances = enhancedResistances,
        damage = damageBonuses,
        healing = healingBonuses,
        utility = utilityStats,
    }

    return stats
end

CM.collectors.CollectCombatStatsData = CollectCombatStatsData

-- =====================================================
-- ROLE
-- =====================================================

local function CollectRoleData()
    -- Use API layer for role data
    local apiRole = CM.api.combat.GetRole()

    local role = {}

    -- Transform API data to expected format (backward compatibility)
    role.selected = apiRole.name or "None"
    role.emoji = apiRole.emoji or "❓"

    return role
end

CM.collectors.CollectRoleData = CollectRoleData

-- =====================================================
-- ACTIVE BUFFS
-- =====================================================

local function CollectActiveBuffs()
    local buffs = { food = nil, potion = nil, other = {} }

    local foodKeywords = { "Food", "Drink", "Broth", "Stew", "Soup", "Meal", "Feast" }
    local potionKeywords = { "Potion", "Elixir", "Draught", "Tonic" }

    -- Use API layer for buffs
    local buffData = CM.api.combat.GetBuffs()
    if buffData and buffData.list then
        for _, buff in ipairs(buffData.list) do
            local buffName = buff.name
            if buffName and buffName ~= "" then
                local isFood = false
                local isPotion = false

                for _, keyword in ipairs(foodKeywords) do
                    if buffName:find(keyword) then
                        isFood = true
                        break
                    end
                end

                if not isFood then
                    for _, keyword in ipairs(potionKeywords) do
                        if buffName:find(keyword) then
                            isPotion = true
                            break
                        end
                    end
                end

                if isFood and not buffs.food then
                    buffs.food = buffName
                elseif isPotion and not buffs.potion then
                    buffs.potion = buffName
                elseif not isFood and not isPotion and #buffs.other < 5 then
                    local isMundus = buffName:find("^The ") or buffName:find("^Boon:")
                    if not isMundus then
                        table.insert(buffs.other, buffName)
                    end
                end
            end
        end
    end

    return buffs
end

CM.collectors.CollectActiveBuffs = CollectActiveBuffs

-- =====================================================
-- MUNDUS STONE
-- =====================================================

local function CollectMundusData()
    local data = { active = false, name = nil }

    local mundusStones = {
        ["The Apprentice"] = true,
        ["The Atronach"] = true,
        ["The Lady"] = true,
        ["The Lord"] = true,
        ["The Lover"] = true,
        ["The Mage"] = true,
        ["The Ritual"] = true,
        ["The Serpent"] = true,
        ["The Shadow"] = true,
        ["The Steed"] = true,
        ["The Thief"] = true,
        ["The Tower"] = true,
        ["The Warrior"] = true,
        ["Boon: The Apprentice"] = "The Apprentice",
        ["Boon: The Atronach"] = "The Atronach",
        ["Boon: The Lady"] = "The Lady",
        ["Boon: The Lord"] = "The Lord",
        ["Boon: The Lover"] = "The Lover",
        ["Boon: The Mage"] = "The Mage",
        ["Boon: The Ritual"] = "The Ritual",
        ["Boon: The Serpent"] = "The Serpent",
        ["Boon: The Shadow"] = "The Shadow",
        ["Boon: The Steed"] = "The Steed",
        ["Boon: The Thief"] = "The Thief",
        ["Boon: The Tower"] = "The Tower",
        ["Boon: The Warrior"] = "The Warrior",
    }

    -- Use API layer for buffs
    local buffData = CM.api.combat.GetBuffs()
    if buffData and buffData.list then
        for _, buff in ipairs(buffData.list) do
            if buff.name then
                local mundusMatch = mundusStones[buff.name]
                if mundusMatch then
                    data.active = true
                    data.name = type(mundusMatch) == "string" and mundusMatch or buff.name
                    break
                end
            end
        end
    end

    return data
end

CM.collectors.CollectMundusData = CollectMundusData

CM.DebugPrint("COLLECTOR", "Combat collector module loaded")
