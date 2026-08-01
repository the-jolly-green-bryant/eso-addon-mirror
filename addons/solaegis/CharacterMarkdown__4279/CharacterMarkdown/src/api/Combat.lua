-- CharacterMarkdown - API Layer - Combat
-- Abstraction for stats, attributes, power, and buffs

local CM = CharacterMarkdown
CM.api = CM.api or {}
CM.api.combat = {}

local api = CM.api.combat

-- =====================================================
-- GRANULAR GETTERS
-- =====================================================

function api.GetStat(statType)
    -- Wrapper for GetPlayerStat with safe defaults
    return CM.SafeCall(GetPlayerStat, statType, STAT_BONUS_OPTION_APPLY_BONUS) or 0
end

function api.GetAttributes()
    local health = CM.SafeCall(GetAttributeSpentPoints, ATTRIBUTE_HEALTH) or 0
    local magicka = CM.SafeCall(GetAttributeSpentPoints, ATTRIBUTE_MAGICKA) or 0
    local stamina = CM.SafeCall(GetAttributeSpentPoints, ATTRIBUTE_STAMINA) or 0
    local unspent = CM.SafeCall(GetAttributeUnspentPoints) or 0

    return {
        health = health,
        magicka = magicka,
        stamina = stamina,
        unspent = unspent,
    }
end

function api.GetPowerStats()
    -- Spell
    local spellPower = api.GetStat(STAT_SPELL_POWER)
    local spellCrit = api.GetStat(STAT_SPELL_CRITICAL)
    local spellPen = api.GetStat(STAT_SPELL_PENETRATION)

    -- Weapon (Physical)
    local weaponPower = api.GetStat(STAT_POWER)
    local weaponCrit = api.GetStat(STAT_CRITICAL_STRIKE)
    local physPen = api.GetStat(STAT_PHYSICAL_PENETRATION)

    -- Resistance
    local physResist = api.GetStat(STAT_PHYSICAL_RESIST)
    local spellResist = api.GetStat(STAT_SPELL_RESIST)
    local critResist = api.GetStat(STAT_CRITICAL_RESISTANCE)

    return {
        spell = { power = spellPower, crit = spellCrit, penetration = spellPen },
        physical = { power = weaponPower, crit = weaponCrit, penetration = physPen },
        resistance = { physical = physResist, spell = spellResist, critical = critResist },
    }
end

function api.GetRegenStats()
    local health = api.GetStat(STAT_HEALTH_REGEN_COMBAT)
    local magicka = api.GetStat(STAT_MAGICKA_REGEN_COMBAT)
    local stamina = api.GetStat(STAT_STAMINA_REGEN_COMBAT)

    -- Idle regen might be different, but usually Combat regen is the key metric
    -- Note: STAT_HEALTH_REGEN_IDLE exists but often combat is preferred display

    return {
        health = health,
        magicka = magicka,
        stamina = stamina,
    }
end

function api.GetBuffs()
    local numBuffs = CM.SafeCall(GetNumBuffs, "player") or 0
    local buffs = {}

    -- Special state tracking
    local isVampire = false
    local vampireStage = 0
    local isWerewolf = false
    local werewolfStage = 0

    for i = 1, numBuffs do
        -- GetUnitBuffInfo returns: buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, sourceUnitId, initialCooldown
        local success, buffName, _, _, _, iconFilename, _, _, _, _, abilityId =
            CM.SafeCallMulti(GetUnitBuffInfo, "player", i)

        if success and buffName then
            table.insert(buffs, {
                name = buffName,
                icon = iconFilename,
                id = abilityId,
            })

            -- Check for Vamp/WW state
            if buffName:find("Vampir") then
                isVampire = true
                -- Try to parse stage
                local stage = buffName:match("Stage (%d)")
                if stage then
                    vampireStage = tonumber(stage)
                end
                -- Fallback to stage 1 if name contains Vampire but no stage number parsed yet
                if vampireStage == 0 then
                    vampireStage = 1
                end
            end

            if buffName:find("Lycanthropy") or buffName:find("Werewolf") then
                isWerewolf = true
                werewolfStage = 1 -- Usually just on/off, or transformed state
            end
        end
    end

    return {
        list = buffs,
        special = {
            isVampire = isVampire,
            vampireStage = vampireStage,
            isWerewolf = isWerewolf,
            werewolfStage = werewolfStage,
        },
    }
end

function api.GetRole()
    local selectedRole = CM.SafeCall(GetGroupMemberSelectedRole, "player")
    local roleName = "None"
    local emoji = "❓"

    if selectedRole == LFG_ROLE_TANK then
        roleName = "Tank"
        emoji = "🛡️"
    elseif selectedRole == LFG_ROLE_HEAL then
        roleName = "Healer"
        emoji = "💚"
    elseif selectedRole == LFG_ROLE_DPS then
        roleName = "DPS"
        emoji = "⚔️"
    end

    return {
        id = selectedRole,
        name = roleName,
        emoji = emoji,
    }
end

function api.GetAdvancedStat(statType)
    -- GetAdvancedStatValue returns: displayFormat, flatValue, percentValue
    -- Must use SafeCallMulti because SafeCall only returns the first value!
    local success, _, flat, pct = CM.SafeCallMulti(GetAdvancedStatValue, statType)

    if not success then
        return { flat = 0, percent = 0 }
    end

    return {
        flat = flat or 0,
        percent = pct or 0,
    }
end

function api.GetCoreAbilityStats()
    -- Core ability costs using GetAbilityCost() with discovered ability IDs
    -- These IDs were found via /testconstants command
    local bashCost = GetAbilityCost(21970, COMBAT_MECHANIC_FLAGS_STAMINA) or 0
    local breakFreeCost = GetAbilityCost(16565, COMBAT_MECHANIC_FLAGS_STAMINA) or 0
    local dodgeRollCost = GetAbilityCost(28549, COMBAT_MECHANIC_FLAGS_STAMINA) or 0

    -- Block cost appears to be GetPlayerStat(6) based on scan results
    -- Value is ~1761 vs displayed 1757, close enough
    local blockCost = api.GetStat(6) or 0

    -- Use Advanced Stats for Sneak and Sprint to get accurate values (e.g. 26, 303)
    local sneakStat = api.GetAdvancedStat(ADVANCED_STAT_DISPLAY_TYPE_SNEAK_COST)
    local sprintStat = api.GetAdvancedStat(ADVANCED_STAT_DISPLAY_TYPE_SPRINT_COST)

    return {
        bashCost = bashCost,
        blockCost = blockCost,
        breakFreeCost = breakFreeCost,
        dodgeRollCost = dodgeRollCost,
        sneakCost = sneakStat.flat,
        sprintCost = sprintStat.flat,
        bashDamage = api.GetStat(STAT_BASH_DAMAGE),
        blockMitigation = api.GetStat(STAT_BLOCK_MITIGATION),
        blockSpeed = api.GetStat(STAT_BLOCK_SPEED),
        sneakSpeed = api.GetStat(STAT_SNEAK_SPEED),
        sprintSpeed = api.GetStat(STAT_SPRINT_SPEED),
    }
end

function api.GetResistances()
    return {
        flame = api.GetStat(STAT_FLAME_RESIST),
        shock = api.GetStat(STAT_SHOCK_RESIST),
        frost = api.GetStat(STAT_FROST_RESIST),
        magic = api.GetStat(STAT_MAGIC_RESIST),
        disease = api.GetStat(STAT_DISEASE_RESIST),
        poison = api.GetStat(STAT_POISON_RESIST),
        bleed = api.GetStat(STAT_BLEED_RESIST),
        physical = api.GetStat(STAT_PHYSICAL_RESIST),
        spell = api.GetStat(STAT_SPELL_RESIST),
        critical = api.GetStat(STAT_CRITICAL_RESISTANCE),
    }
end

function api.GetDamageBonuses()
    -- Helper to get flat and percent for a damage type
    -- Uses GetPlayerStat for flat (Power) and GetAdvancedStatValue for percent (Bonus)
    local function GetDamageStats(flatStat, advStatType)
        local advStat = api.GetAdvancedStat(advStatType)
        return {
            flat = api.GetStat(flatStat),
            percent = advStat.percent,
        }
    end

    local critStat = api.GetAdvancedStat(ADVANCED_STAT_DISPLAY_TYPE_CRITICAL_DAMAGE)

    return {
        -- Critical Damage is 50% base + bonus
        criticalDamage = 50 + critStat.percent,
        physical = GetDamageStats(STAT_PHYSICAL_DAMAGE, ADVANCED_STAT_DISPLAY_TYPE_PHYSICAL_DAMAGE),
        spell = GetDamageStats(STAT_SPELL_DAMAGE, ADVANCED_STAT_DISPLAY_TYPE_MAGIC_DAMAGE), -- Magic Damage covers Spell usually? Or is there a separate Spell?
        -- Note: In Advanced Stats, "Magic Damage" usually pairs with Spell Damage.
        -- "Physical Damage" pairs with Weapon Damage.

        disease = GetDamageStats(STAT_DISEASE_DAMAGE, ADVANCED_STAT_DISPLAY_TYPE_DISEASE_DAMAGE),
        poison = GetDamageStats(STAT_POISON_DAMAGE, ADVANCED_STAT_DISPLAY_TYPE_POISON_DAMAGE),
        bleed = GetDamageStats(STAT_BLEED_DAMAGE, ADVANCED_STAT_DISPLAY_TYPE_BLEED_DAMAGE),
        flame = GetDamageStats(STAT_FLAME_DAMAGE, ADVANCED_STAT_DISPLAY_TYPE_FIRE_DAMAGE),
        shock = GetDamageStats(STAT_SHOCK_DAMAGE, ADVANCED_STAT_DISPLAY_TYPE_SHOCK_DAMAGE),
        frost = GetDamageStats(STAT_FROST_DAMAGE, ADVANCED_STAT_DISPLAY_TYPE_FROST_DAMAGE), -- Assuming constant exists
        magic = GetDamageStats(STAT_MAGIC_DAMAGE, ADVANCED_STAT_DISPLAY_TYPE_MAGIC_DAMAGE),
        oblivion = GetDamageStats(STAT_OBLIVION_DAMAGE, ADVANCED_STAT_DISPLAY_TYPE_OBLIVION_DAMAGE),
        criticalResistance = api.GetStat(STAT_CRITICAL_RESISTANCE) or 0,
    }
end

function api.GetHealingBonuses()
    local healingDone = api.GetAdvancedStat(ADVANCED_STAT_DISPLAY_TYPE_HEALING_DONE)
    local healingTaken = api.GetAdvancedStat(ADVANCED_STAT_DISPLAY_TYPE_HEALING_TAKEN)
    local critHealing = api.GetAdvancedStat(ADVANCED_STAT_DISPLAY_TYPE_CRITICAL_HEALING)

    return {
        healingDone = {
            flat = healingDone.flat,
            percent = healingDone.percent,
        },
        healingTaken = {
            flat = healingTaken.flat,
            percent = healingTaken.percent,
        },
        -- Critical Healing is Base (50%) + Bonus
        criticalHealing = 50 + critHealing.percent,
    }
end

function api.GetUtilityStats()
    -- GetRidingStats: inventoryBonus, maxInventoryBonus, staminaBonus, maxStaminaBonus, speedBonus, maxSpeedBonus
    local inventoryBonus, maxInventoryBonus, staminaBonus, maxStaminaBonus, speedBonus, maxSpeedBonus =
        GetRidingStats()

    return {
        riding = {
            speed = speedBonus or 0,
            maxSpeed = maxSpeedBonus or 0,
            stamina = staminaBonus or 0,
            maxStamina = maxStaminaBonus or 0,
            inventory = inventoryBonus or 0,
            maxInventory = maxInventoryBonus or 0,
        },
    }
end

-- Composition functions moved to collector level

-- =====================================================
-- COMPREHENSIVE ADVANCED STATS (API 101049+)
-- =====================================================

-- Aggregate all available advanced stats into a single lookup
function api.GetAllAdvancedStats()
    -- Define all known ADVANCED_STAT_DISPLAY_TYPE constants
    -- These provide more accurate values than raw STAT_ constants
    local advancedStatTypes = {
        { key = "sneakCost", type = ADVANCED_STAT_DISPLAY_TYPE_SNEAK_COST },
        { key = "sprintCost", type = ADVANCED_STAT_DISPLAY_TYPE_SPRINT_COST },
        { key = "criticalDamage", type = ADVANCED_STAT_DISPLAY_TYPE_CRITICAL_DAMAGE },
        { key = "criticalHealing", type = ADVANCED_STAT_DISPLAY_TYPE_CRITICAL_HEALING },
        { key = "healingDone", type = ADVANCED_STAT_DISPLAY_TYPE_HEALING_DONE },
        { key = "healingTaken", type = ADVANCED_STAT_DISPLAY_TYPE_HEALING_TAKEN },
        { key = "physicalDamage", type = ADVANCED_STAT_DISPLAY_TYPE_PHYSICAL_DAMAGE },
        { key = "magicDamage", type = ADVANCED_STAT_DISPLAY_TYPE_MAGIC_DAMAGE },
        { key = "fireDamage", type = ADVANCED_STAT_DISPLAY_TYPE_FIRE_DAMAGE },
        { key = "shockDamage", type = ADVANCED_STAT_DISPLAY_TYPE_SHOCK_DAMAGE },
        { key = "frostDamage", type = ADVANCED_STAT_DISPLAY_TYPE_FROST_DAMAGE },
        { key = "diseaseDamage", type = ADVANCED_STAT_DISPLAY_TYPE_DISEASE_DAMAGE },
        { key = "poisonDamage", type = ADVANCED_STAT_DISPLAY_TYPE_POISON_DAMAGE },
        { key = "bleedDamage", type = ADVANCED_STAT_DISPLAY_TYPE_BLEED_DAMAGE },
        { key = "oblivionDamage", type = ADVANCED_STAT_DISPLAY_TYPE_OBLIVION_DAMAGE },
    }

    local stats = {}
    for _, statDef in ipairs(advancedStatTypes) do
        if statDef.type then
            local advStat = api.GetAdvancedStat(statDef.type)
            stats[statDef.key] = {
                flat = advStat.flat,
                percent = advStat.percent,
            }
        end
    end

    CM.DebugPrint("COMBAT_API", string.format("Collected %d advanced stats", #advancedStatTypes))
    return stats
end

CM.DebugPrint("API", "Combat API module loaded")
