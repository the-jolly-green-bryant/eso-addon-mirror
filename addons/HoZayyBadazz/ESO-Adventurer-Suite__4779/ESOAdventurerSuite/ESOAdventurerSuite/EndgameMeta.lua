-- ESO Adventurer Suite
-- Curated live endgame gear snapshot for every ESO class and PvE role.
-- Data is stored locally because ESO addons cannot make live web requests.
-- Snapshot checked 2026-08-27 against current live ESO.

local EPC = ESOProgressionCoach
EPC.EndgameMeta = EPC.EndgameMeta or {}
local M = EPC.EndgameMeta

M.SNAPSHOT = {
    checked = "2026-08-27",
        sourceNote = "Current high-end PvE templates checked 2026-08-27. Support gear remains group-assignment dependent.",
    sources = {
        "ZeniMax live patch notes",
        "ESO-Hub current class DPS builds",
        "ESO-Hub current tank builds",
        "ESO-Hub current healer builds",
    },
}

M.CLASSES = {
    [1] = { key = "DK", name = "Dragonknight" },
    [2] = { key = "SORC", name = "Sorcerer" },
    [3] = { key = "NB", name = "Nightblade" },
    [4] = { key = "WARDEN", name = "Warden" },
    [5] = { key = "NECRO", name = "Necromancer" },
    [6] = { key = "TEMPLAR", name = "Templar" },
    [117] = { key = "ARC", name = "Arcanist" },
}

local function normalize(value)
    value = string.lower(tostring(value or ""))
    value = string.gsub(value, "^perfected%s+", "")
    value = string.gsub(value, "[%p%s]+", " ")
    value = string.gsub(value, "^%s+", "")
    value = string.gsub(value, "%s+$", "")
    return value
end

function M:NormalizeSetName(name)
    return normalize(name)
end

function M:SameSet(a, b)
    local na = normalize(a)
    local nb = normalize(b)
    return na ~= "" and na == nb
end

local function cloneTable(source)
    if type(source) ~= "table" then return source end
    local result = {}
    for key, value in pairs(source) do result[key] = cloneTable(value) end
    return result
end

local function harmEnchant(resource)
    return resource == "MAGICKA" and "SPELL DAMAGE" or "WEAPON DAMAGE"
end

local function dpsTemplate(classKey, resource)
    local res = resource == "MAGICKA" and "MAGICKA" or "STAMINA"
    local harm = harmEnchant(res)

    if classKey == "DK" then
        return {
            label = "TRIAL / ENDGAME",
            confidence = "CURATED",
            body = {
                { set = "Sul-Xan's Torment", count = 5, armor = "MEDIUM", trait = "DIVINES", enchant = res, perfectedPreferred = true },
                { set = "Deadly Strike", count = 1, armor = "MEDIUM", trait = "DIVINES", enchant = res },
                { set = "Slimecraw", count = 1, armor = "LIGHT", trait = "DIVINES", enchant = res },
            },
            neck = { set = "Velothi Ur-Mage's Amulet", trait = "BLOODTHIRSTY", enchant = harm },
            rings = {
                { set = "Deadly Strike", trait = "BLOODTHIRSTY", enchant = harm },
                { set = "Deadly Strike", trait = "BLOODTHIRSTY", enchant = harm },
            },
            frontWeapon = { set = "Deadly Strike", weapon = "DAGGER", trait = "CHARGED", enchant = "FLAME" },
            frontOffhand = { set = "Deadly Strike", weapon = "DAGGER", trait = "CHARGED", enchant = "POISON" },
            backWeapon = { set = "Crushing Wall", weapon = "FIRE STAFF", trait = "INFUSED", enchant = "WEAPON DAMAGE", perfectedPreferred = true },
            core = {
                "Perfected Sul-Xan's Torment x5 body",
                "Deadly Strike front-bar dual daggers plus rings/body",
                "Velothi Ur-Mage's Amulet and one-piece Slimecraw",
                "Perfected Crushing Wall Flame Staff back bar",
            },
            sourceKey = "DK_DPS_LIVE",
        }
    elseif classKey == "SORC" then
        return {
            label = "TRIAL / ENDGAME",
            confidence = "CURATED",
            body = {
                { set = "Monolith of Storms", count = 5, armor = "MEDIUM", trait = "DIVINES", enchant = res },
                { set = "Mora Scribe's Thesis", count = 1, armor = "LIGHT", trait = "DIVINES", enchant = res, perfectedPreferred = true },
                { set = "Slimecraw", count = 1, armor = "MEDIUM", trait = "DIVINES", enchant = res },
            },
            neck = { set = "Mora Scribe's Thesis", trait = "BLOODTHIRSTY", enchant = harm, perfectedPreferred = true },
            rings = {
                { set = "Mora Scribe's Thesis", trait = "BLOODTHIRSTY", enchant = harm, perfectedPreferred = true },
                { set = "Shattered Paths Signet", trait = "BLOODTHIRSTY", enchant = harm },
            },
            frontWeapon = { set = "Mora Scribe's Thesis", weapon = "DAGGER", trait = "CHARGED", enchant = "FLAME", perfectedPreferred = true },
            frontOffhand = { set = "Mora Scribe's Thesis", weapon = "DAGGER", trait = "CHARGED", enchant = "POISON", perfectedPreferred = true },
            backWeapon = { set = "Merciless Charge", weapon = "GREATSWORD", trait = "INFUSED", enchant = "WEAPON DAMAGE", perfectedPreferred = true },
            core = {
                "Monolith of Storms x5 body",
                "Perfected Mora Scribe's Thesis front-bar dual daggers plus body/jewelry",
                "Shattered Paths Signet and one-piece Slimecraw",
                "Perfected Merciless Charge Greatsword back bar",
            },
            sourceKey = "SORC_DPS_LIVE",
        }
    elseif classKey == "NB" then
        return {
            label = "TRIAL / ENDGAME",
            confidence = "CURATED",
            body = {
                { set = "Slivers of the Null Arca", count = 5, armor = "MEDIUM", trait = "DIVINES", enchant = res, perfectedPreferred = true },
                { set = "Savage Werewolf", count = 1, armor = "MEDIUM", trait = "DIVINES", enchant = res },
                { set = "Slimecraw", count = 1, armor = "LIGHT", trait = "DIVINES", enchant = res },
            },
            neck = { set = "Savage Werewolf", trait = "INFUSED", enchant = harm },
            rings = {
                { set = "Savage Werewolf", trait = "INFUSED", enchant = harm },
                { set = "Shattered Paths Signet", trait = "INFUSED", enchant = harm },
            },
            frontWeapon = { set = "Savage Werewolf", weapon = "DAGGER", trait = "NIRNHONED", enchant = "FLAME" },
            frontOffhand = { set = "Savage Werewolf", weapon = "DAGGER", trait = "CHARGED", enchant = "POISON" },
            backWeapon = { set = "Merciless Charge", weapon = "GREATSWORD", trait = "INFUSED", enchant = "WEAPON DAMAGE", perfectedPreferred = true },
            core = {
                "Slivers of the Null Arca x5 body",
                "Savage Werewolf front-bar dual daggers plus jewelry/body",
                "Shattered Paths Signet and one-piece Slimecraw",
                "Perfected Merciless Charge Greatsword back bar",
            },
            sourceKey = "NB_DPS_LIVE",
        }
    elseif classKey == "WARDEN" then
        return {
            label = "TRIAL / ENDGAME",
            confidence = "CURATED",
            body = {
                { set = "Slivers of the Null Arca", count = 5, armor = "MEDIUM", trait = "DIVINES", enchant = res, perfectedPreferred = true },
                { set = "Aerie's Cry", count = 1, armor = "MEDIUM", trait = "DIVINES", enchant = res },
                { set = "Slimecraw", count = 1, armor = "LIGHT", trait = "DIVINES", enchant = res },
            },
            neck = { set = "Aerie's Cry", trait = "BLOODTHIRSTY", enchant = harm },
            rings = {
                { set = "Aerie's Cry", trait = "BLOODTHIRSTY", enchant = harm },
                { set = "Shattered Paths Signet", trait = "BLOODTHIRSTY", enchant = harm },
            },
            frontWeapon = { set = "Aerie's Cry", weapon = "DAGGER", trait = "CHARGED", enchant = "POISON" },
            frontOffhand = { set = "Aerie's Cry", weapon = "DAGGER", trait = "CHARGED", enchant = "FLAME" },
            backWeapon = { set = "Merciless Charge", weapon = "GREATSWORD", trait = "INFUSED", enchant = "FROST", perfectedPreferred = true },
            core = {
                "Perfected Slivers of the Null Arca x5 body",
                "Aerie's Cry front-bar dual daggers plus jewelry/body",
                "Shattered Paths Signet and one-piece Slimecraw",
                "Perfected Merciless Charge Greatsword back bar",
            },
            sourceKey = "WARDEN_DPS_LIVE",
        }
    elseif classKey == "NECRO" then
        return {
            label = "TRIAL / ENDGAME",
            confidence = "CURATED",
            body = {
                { set = "Slivers of the Null Arca", count = 5, armor = "MEDIUM", trait = "DIVINES", enchant = res, perfectedPreferred = true },
                { set = "Huntsman's Warmask", count = 1, armor = "MEDIUM", trait = "DIVINES", enchant = res },
                { set = "Slimecraw", count = 1, armor = "LIGHT", trait = "DIVINES", enchant = res },
            },
            neck = { set = "Corpseburster", trait = "BLOODTHIRSTY", enchant = harm },
            rings = {
                { set = "Corpseburster", trait = "BLOODTHIRSTY", enchant = harm },
                { set = "Corpseburster", trait = "BLOODTHIRSTY", enchant = harm },
            },
            frontWeapon = { set = "Corpseburster", weapon = "DAGGER", trait = "NIRNHONED", enchant = "FLAME" },
            frontOffhand = { set = "Corpseburster", weapon = "DAGGER", trait = "CHARGED", enchant = "POISON" },
            backWeapon = { set = "Merciless Charge", weapon = "GREATSWORD", trait = "INFUSED", enchant = "WEAPON DAMAGE", perfectedPreferred = true },
            core = {
                "Perfected Slivers of the Null Arca x5 body",
                "Corpseburster front-bar dual daggers plus jewelry",
                "Huntsman's Warmask and one-piece Slimecraw",
                "Perfected Merciless Charge Greatsword back bar",
            },
            sourceKey = "NECRO_DPS_LIVE",
        }
    elseif classKey == "TEMPLAR" then
        return {
            label = "TRIAL / ENDGAME",
            confidence = "CURATED",
            body = {
                { set = "Sul-Xan's Torment", count = 5, armor = "MEDIUM", trait = "DIVINES", enchant = res, perfectedPreferred = true },
                { set = "Mora's Whispers", count = 1, armor = "LIGHT", trait = "DIVINES", enchant = res },
                { set = "Slimecraw", count = 1, armor = "MEDIUM", trait = "DIVINES", enchant = res },
            },
            neck = { set = "Aetheric Lancer", trait = "BLOODTHIRSTY", enchant = harm },
            rings = {
                { set = "Aetheric Lancer", trait = "BLOODTHIRSTY", enchant = harm },
                { set = "Aetheric Lancer", trait = "BLOODTHIRSTY", enchant = harm },
            },
            frontWeapon = { set = "Aetheric Lancer", weapon = "DAGGER", trait = "NIRNHONED", enchant = "FLAME" },
            frontOffhand = { set = "Aetheric Lancer", weapon = "DAGGER", trait = "CHARGED", enchant = "POISON" },
            backWeapon = { set = "Crushing Wall", weapon = "FIRE STAFF", trait = "INFUSED", enchant = "WEAPON DAMAGE", perfectedPreferred = true },
            core = {
                "Perfected Sul-Xan's Torment x5 body",
                "Aetheric Lancer front-bar dual daggers plus jewelry",
                "Mora's Whispers and one-piece Slimecraw",
                "Perfected Crushing Wall Flame Staff back bar",
            },
            sourceKey = "TEMPLAR_DPS_LIVE",
        }
    elseif classKey == "ARC" then
        return {
            label = "TRIAL / ENDGAME",
            confidence = "CURATED",
            body = {
                { set = "Spattering Disjunction", count = 5, armor = "MEDIUM", trait = "DIVINES", enchant = res },
                { set = "Prior Thierric", count = 1, armor = "LIGHT", trait = "DIVINES", enchant = res },
                { set = "Prior Thierric", count = 1, armor = "MEDIUM", trait = "DIVINES", enchant = res },
            },
            neck = { set = "Slivers of the Null Arca", trait = "BLOODTHIRSTY", enchant = harm, perfectedPreferred = true },
            rings = {
                { set = "Slivers of the Null Arca", trait = "BLOODTHIRSTY", enchant = harm, perfectedPreferred = true },
                { set = "Slivers of the Null Arca", trait = "BLOODTHIRSTY", enchant = harm, perfectedPreferred = true },
            },
            frontWeapon = { set = "Slivers of the Null Arca", weapon = "DAGGER", trait = "NIRNHONED", enchant = "FLAME", perfectedPreferred = true },
            frontOffhand = { set = "Slivers of the Null Arca", weapon = "DAGGER", trait = "CHARGED", enchant = "POISON", perfectedPreferred = true },
            backWeapon = { set = "Merciless Charge", weapon = "GREATSWORD", trait = "INFUSED", enchant = "WEAPON DAMAGE", perfectedPreferred = true },
            core = {
                "Spattering Disjunction x5 body",
                "Perfected Slivers of the Null Arca front-bar dual daggers plus jewelry",
                "Prior Thierric two-piece",
                "Perfected Merciless Charge Greatsword back bar",
            },
            sourceKey = "ARC_DPS_LIVE",
        }
    end
    return nil
end

local function tankTemplate(classKey)
    local baseNote = "Trial tank gear is a group-support assignment, not a universal fixed BiS. BEST ENDGAME uses this current class baseline; your raid lead may assign different support sets for a specific group or encounter."

    if classKey == "DK" then
        return {
            label = "TRIAL TANK / ENDGAME", confidence = "CURATED",
            body = {
                { set = "Lucent Echoes", count = 5, armor = "HEAVY", trait = "REINFORCED", enchant = "PRISMATIC DEFENSE", perfectedPreferred = true },
                { set = "Baron Zaudrus", count = 1, armor = "LIGHT", trait = "STURDY", enchant = "PRISMATIC DEFENSE" },
                { set = "Baron Zaudrus", count = 1, armor = "MEDIUM", trait = "REINFORCED", enchant = "PRISMATIC DEFENSE" },
            },
            neck = { set = "Pearlescent Ward", trait = "INFUSED", enchant = "REDUCE SPELL COST", perfectedPreferred = true },
            rings = {
                { set = "Pearlescent Ward", trait = "INFUSED", enchant = "REDUCE SPELL COST", perfectedPreferred = true },
                { set = "Pearlescent Ward", trait = "INFUSED", enchant = "REDUCE SPELL COST", perfectedPreferred = true },
            },
            frontWeapon = { set = "Pearlescent Ward", weapon = "SWORD", trait = "DECISIVE", enchant = "FROST", perfectedPreferred = true },
            frontOffhand = { set = "Pearlescent Ward", weapon = "SHIELD", trait = "STURDY", enchant = "PRISMATIC DEFENSE", perfectedPreferred = true },
            backWeapon = { set = "Pearlescent Ward", weapon = "FROST STAFF", trait = "INFUSED", enchant = "CRUSHING", perfectedPreferred = true },
            core = { "Perfected Lucent Echoes x5 heavy body", "Perfected Pearlescent Ward weapons and jewelry", "Sword + Shield front bar; Frost Staff back bar", "Baron Zaudrus two-piece" },
            note = baseNote, sourceKey = "DK_TANK_LIVE",
        }
    elseif classKey == "SORC" then
        return {
            label = "TRIAL TANK / ENDGAME", confidence = "CURATED",
            body = {
                { set = "Crimson Oath's Rive", count = 5, armor = "HEAVY", trait = "STURDY", enchant = "PRISMATIC DEFENSE" },
                { set = "Nazaray", count = 1, armor = "HEAVY", trait = "STURDY", enchant = "PRISMATIC DEFENSE" },
                { set = "Nazaray", count = 1, armor = "HEAVY", trait = "STURDY", enchant = "PRISMATIC DEFENSE" },
            },
            neck = { set = "Saxhleel Champion", trait = "INFUSED", enchant = "MAGICKA RECOVERY" },
            rings = {
                { set = "Saxhleel Champion", trait = "INFUSED", enchant = "MAGICKA RECOVERY" },
                { set = "Saxhleel Champion", trait = "INFUSED", enchant = "MAGICKA RECOVERY" },
            },
            frontWeapon = { set = "Saxhleel Champion", weapon = "SWORD", trait = "DECISIVE", enchant = "HARDENING" },
            frontOffhand = { set = "Saxhleel Champion", weapon = "SHIELD", trait = "STURDY", enchant = "PRISMATIC DEFENSE" },
            backWeapon = { set = "Saxhleel Champion", weapon = "FROST STAFF", trait = "INFUSED", enchant = "CRUSHING" },
            core = { "Crimson Oath's Rive x5 heavy body", "Saxhleel Champion weapons and jewelry", "Sword + Shield front bar; Frost Staff back bar", "Nazaray two-piece" },
            note = baseNote, sourceKey = "SORC_TANK_LIVE",
        }
    elseif classKey == "NB" then
        return {
            label = "TRIAL MAIN TANK / ENDGAME", confidence = "CURATED",
            body = {
                { set = "Pearlescent Ward", count = 5, armor = "HEAVY", trait = "STURDY", enchant = "PRISMATIC DEFENSE", perfectedPreferred = true },
                { set = "Tremorscale", count = 1, armor = "LIGHT", trait = "STURDY", enchant = "PRISMATIC DEFENSE" },
                { set = "Tremorscale", count = 1, armor = "MEDIUM", trait = "REINFORCED", enchant = "PRISMATIC DEFENSE" },
            },
            neck = { set = "Roar of Alkosh", trait = "INFUSED", enchant = "REDUCE SPELL COST" },
            rings = {
                { set = "Roar of Alkosh", trait = "INFUSED", enchant = "REDUCE SPELL COST" },
                { set = "Roar of Alkosh", trait = "INFUSED", enchant = "REDUCE SPELL COST" },
            },
            frontWeapon = { set = "Roar of Alkosh", weapon = "SWORD", trait = "INFUSED", enchant = "CRUSHING" },
            frontOffhand = { set = "Roar of Alkosh", weapon = "SHIELD", trait = "REINFORCED", enchant = "PRISMATIC DEFENSE" },
            backWeapon = { set = "Roar of Alkosh", weapon = "FROST STAFF", trait = "INFUSED", enchant = "WEAKENING" },
            core = { "Perfected Pearlescent Ward x5 heavy body", "Roar of Alkosh weapons and jewelry", "Sword + Shield front bar; Frost Staff back bar", "Tremorscale two-piece" },
            note = baseNote, sourceKey = "NB_TANK_LIVE",
        }
    elseif classKey == "WARDEN" then
        return {
            label = "TRIAL TANK / ENDGAME", confidence = "CURATED",
            body = {
                { set = "Frozen Watcher", count = 5, armor = "HEAVY", trait = "STURDY", enchant = "HEALTH" },
                { set = "Cryptcanon Vestments", count = 1, armor = "LIGHT", trait = "STURDY", enchant = "HEALTH" },
                { set = "Lord Warden", count = 1, armor = "HEAVY", trait = "REINFORCED", enchant = "HEALTH" },
            },
            neck = { set = "Lucent Echoes", trait = "INFUSED", enchant = "REDUCE SPELL COST", perfectedPreferred = true },
            rings = {
                { set = "Lucent Echoes", trait = "INFUSED", enchant = "REDUCE SPELL COST", perfectedPreferred = true },
                { set = "Lucent Echoes", trait = "INFUSED", enchant = "REDUCE SPELL COST", perfectedPreferred = true },
            },
            frontWeapon = { set = "Lucent Echoes", weapon = "FROST STAFF", trait = "DECISIVE", enchant = "ABSORB HEALTH", perfectedPreferred = true },
            backWeapon = { set = "Lucent Echoes", weapon = "FROST STAFF", trait = "INFUSED", enchant = "CRUSHING", perfectedPreferred = true },
            core = { "Frozen Watcher x5 heavy body", "Perfected Lucent Echoes double-barred with jewelry", "Frost Staff front and back bars", "Cryptcanon Vestments plus one-piece Lord Warden" },
            note = baseNote, sourceKey = "WARDEN_TANK_LIVE",
        }
    elseif classKey == "NECRO" then
        return {
            label = "TRIAL TANK / ENDGAME", confidence = "CURATED",
            body = {
                { set = "Claw of Yolnahkriin", count = 5, armor = "HEAVY", trait = "STURDY", enchant = "HEALTH", perfectedPreferred = true },
                { set = "Nazaray", count = 1, armor = "LIGHT", trait = "STURDY", enchant = "MAGICKA" },
                { set = "Nazaray", count = 1, armor = "MEDIUM", trait = "STURDY", enchant = "STAMINA" },
            },
            neck = { set = "Saxhleel Champion", trait = "HEALTHY", enchant = "HEALTH RECOVERY", perfectedPreferred = true },
            rings = {
                { set = "Saxhleel Champion", trait = "HEALTHY", enchant = "HEALTH RECOVERY", perfectedPreferred = true },
                { set = "Saxhleel Champion", trait = "HEALTHY", enchant = "HEALTH RECOVERY", perfectedPreferred = true },
            },
            frontWeapon = { set = "Void Bash", weapon = "SWORD", trait = "CHARGED", enchant = "ABSORB HEALTH", perfectedPreferred = true },
            frontOffhand = { set = "Void Bash", weapon = "SHIELD", trait = "STURDY", enchant = "HEALTH", perfectedPreferred = true },
            backWeapon = { set = "Saxhleel Champion", weapon = "FROST STAFF", trait = "INFUSED", enchant = "CRUSHING", perfectedPreferred = true },
            core = { "Perfected Claw of Yolnahkriin x5 heavy body", "Perfected Saxhleel Champion jewelry plus Frost Staff back bar", "Perfected Void Bash Sword + Shield front bar", "Nazaray two-piece" },
            note = baseNote, sourceKey = "NECRO_TANK_LIVE",
        }
    elseif classKey == "TEMPLAR" then
        return {
            label = "TRIAL TANK / ENDGAME", confidence = "CURATED",
            body = {
                { set = "Crimson Oath's Rive", count = 5, armor = "HEAVY", trait = "REINFORCED", enchant = "PRISMATIC DEFENSE" },
                { set = "Magma Incarnate", count = 1, armor = "HEAVY", trait = "STURDY", enchant = "PRISMATIC DEFENSE" },
                { set = "Magma Incarnate", count = 1, armor = "HEAVY", trait = "STURDY", enchant = "PRISMATIC DEFENSE" },
            },
            neck = { set = "The Saint and the Seducer", trait = "INFUSED", enchant = "PRISMATIC RECOVERY" },
            rings = {
                { set = "Lucent Echoes", trait = "INFUSED", enchant = "PRISMATIC RECOVERY" },
                { set = "Lucent Echoes", trait = "INFUSED", enchant = "PRISMATIC RECOVERY" },
            },
            frontWeapon = { set = "Puncturing Remedy", weapon = "MACE", trait = "INFUSED", enchant = "CRUSHING", perfectedPreferred = true },
            frontOffhand = { set = "Puncturing Remedy", weapon = "SHIELD", trait = "INFUSED", enchant = "PRISMATIC DEFENSE", perfectedPreferred = true },
            backWeapon = { set = "Crushing Wall", weapon = "FROST STAFF", trait = "DECISIVE", enchant = "CRUSHING" },
            core = { "Crimson Oath's Rive x5 heavy body", "Perfected Puncturing Remedy Mace + Shield front bar", "Lucent Echoes rings plus Saint and Seducer necklace", "Magma Incarnate two-piece and Frost Staff back bar" },
            note = baseNote, sourceKey = "TEMPLAR_TANK_LIVE",
        }
    elseif classKey == "ARC" then
        return {
            label = "TRIAL TANK / ENDGAME", confidence = "CURATED",
            body = {
                { set = "Pearlescent Ward", count = 5, armor = "HEAVY", trait = "REINFORCED", enchant = "HEALTH" },
                { set = "Armor of the Trainee", count = 1, armor = "HEAVY", trait = "STURDY", enchant = "MAGICKA" },
                { set = "Syrabane's Ward", count = 1, armor = "HEAVY", trait = "STURDY", enchant = "PRISMATIC DEFENSE" },
            },
            neck = { set = "Lucent Echoes", trait = "TRIUNE", enchant = "BRACING" },
            rings = {
                { set = "Lucent Echoes", trait = "TRIUNE", enchant = "BRACING" },
                { set = "Lucent Echoes", trait = "TRIUNE", enchant = "BRACING" },
            },
            frontWeapon = { set = "Lucent Echoes", weapon = "SWORD", trait = "INFUSED", enchant = "WEAKENING" },
            frontOffhand = { set = "Lucent Echoes", weapon = "SHIELD", trait = "STURDY", enchant = "STAMINA" },
            backWeapon = { set = "Lucent Echoes", weapon = "FROST STAFF", trait = "INFUSED", enchant = "CRUSHING" },
            core = { "Pearlescent Ward x5 heavy body", "Lucent Echoes weapons and jewelry", "Sword + Shield front bar; Frost Staff back bar", "Armor of the Trainee plus Syrabane's Ward flex pieces" },
            note = baseNote, sourceKey = "ARC_TANK_LIVE",
        }
    end
    return nil
end

local function healerTemplate(classKey)
    local baseNote = "Trial healer gear is a group-support assignment, not a universal fixed BiS. BEST ENDGAME uses this current class baseline; the second healer, raid lead, or encounter may require a different buff-set assignment."

    if classKey == "DK" then
        return {
            label = "TRIAL HEALER / ENDGAME", confidence = "CURATED",
            body = {
                { set = "Master Architect", count = 5, armor = "LIGHT", trait = "DIVINES", enchant = "MAGICKA" },
                { set = "Symphony of Blades", count = 1, armor = "MEDIUM", trait = "DIVINES", enchant = "MAGICKA" },
                { set = "Symphony of Blades", count = 1, armor = "HEAVY", trait = "DIVINES", enchant = "MAGICKA" },
            },
            neck = { set = "Vestment of Olorime", trait = "ARCANE", enchant = "PRISMATIC RECOVERY", perfectedPreferred = true },
            rings = {
                { set = "Vestment of Olorime", trait = "ARCANE", enchant = "PRISMATIC RECOVERY", perfectedPreferred = true },
                { set = "Vestment of Olorime", trait = "ARCANE", enchant = "PRISMATIC RECOVERY", perfectedPreferred = true },
            },
            frontWeapon = { set = "Grand Rejuvenation", weapon = "RESTORATION STAFF", trait = "POWERED", enchant = "ABSORB MAGICKA", perfectedPreferred = true },
            backWeapon = { set = "Vestment of Olorime", weapon = "LIGHTNING STAFF", trait = "INFUSED", enchant = "ABSORB MAGICKA", perfectedPreferred = true },
            core = { "Master Architect x5 light body", "Perfected Vestment of Olorime back bar plus jewelry", "Perfected Grand Rejuvenation Restoration Staff front bar", "Symphony of Blades two-piece" },
            note = baseNote, sourceKey = "DK_HEAL_LIVE",
        }
    elseif classKey == "SORC" then
        return {
            label = "TRIAL HEALER / ENDGAME", confidence = "CURATED",
            body = {
                { set = "Master Architect", count = 5, armor = "LIGHT", trait = "DIVINES", enchant = "MAGICKA" },
                { set = "Powerful Assault", count = 1, armor = "MEDIUM", trait = "DIVINES", enchant = "MAGICKA" },
                { set = "Spaulder of Ruin", count = 1, armor = "LIGHT", trait = "DIVINES", enchant = "MAGICKA" },
            },
            neck = { set = "Blessing of the Potentates", trait = "INFUSED", enchant = "POTION SPEED" },
            rings = {
                { set = "Powerful Assault", trait = "INFUSED", enchant = "POTION SPEED" },
                { set = "Powerful Assault", trait = "INFUSED", enchant = "POTION SPEED" },
            },
            frontWeapon = { set = "Powerful Assault", weapon = "RESTORATION STAFF", trait = "DECISIVE", enchant = "WEAPON DAMAGE" },
            backWeapon = { set = "Blessing of the Potentates", weapon = "LIGHTNING STAFF", trait = "INFUSED", enchant = "WEAKENING" },
            core = { "Master Architect x5 light body", "Powerful Assault front bar plus rings/body", "Blessing of the Potentates back bar plus necklace", "Spaulder of Ruin flex mythic" },
            note = baseNote, sourceKey = "SORC_HEAL_LIVE",
        }
    elseif classKey == "NB" then
        return {
            label = "TRIAL HEALER / ENDGAME", confidence = "CURATED",
            body = {
                { set = "Spell Power Cure", count = 5, armor = "LIGHT", trait = "DIVINES", enchant = "MAGICKA" },
                { set = "Magma Incarnate", count = 1, armor = "LIGHT", trait = "DIVINES", enchant = "MAGICKA" },
                { set = "Spaulder of Ruin", count = 1, armor = "LIGHT", trait = "DIVINES", enchant = "MAGICKA" },
            },
            neck = { set = "Powerful Assault", trait = "INFUSED", enchant = "SPELL DAMAGE" },
            rings = {
                { set = "Powerful Assault", trait = "INFUSED", enchant = "SPELL DAMAGE" },
                { set = "Powerful Assault", trait = "INFUSED", enchant = "SPELL DAMAGE" },
            },
            frontWeapon = { set = "Grand Rejuvenation", weapon = "RESTORATION STAFF", trait = "POWERED", enchant = "WEAPON DAMAGE", perfectedPreferred = true },
            backWeapon = { set = "Powerful Assault", weapon = "LIGHTNING STAFF", trait = "INFUSED", enchant = "WEAKENING" },
            core = { "Spell Power Cure x5 light body", "Powerful Assault back bar plus jewelry", "Perfected Grand Rejuvenation Restoration Staff front bar", "Magma Incarnate plus Spaulder of Ruin support pieces" },
            note = baseNote, sourceKey = "NB_HEAL_LIVE",
        }
    elseif classKey == "WARDEN" then
        return {
            label = "TRIAL HEALER / ENDGAME", confidence = "CURATED",
            body = {
                { set = "Serpent's Disdain", count = 5, armor = "LIGHT", trait = "DIVINES", enchant = "MAGICKA" },
                { set = "Ozezan the Inferno", count = 1, armor = "LIGHT", trait = "DIVINES", enchant = "MAGICKA" },
                { set = "Ozezan the Inferno", count = 1, armor = "LIGHT", trait = "DIVINES", enchant = "MAGICKA" },
            },
            neck = { set = "Pillager's Profit", trait = "INFUSED", enchant = "SPELL DAMAGE", perfectedPreferred = true },
            rings = {
                { set = "Pillager's Profit", trait = "INFUSED", enchant = "SPELL DAMAGE", perfectedPreferred = true },
                { set = "Pillager's Profit", trait = "INFUSED", enchant = "SPELL DAMAGE", perfectedPreferred = true },
            },
            frontWeapon = { set = "Grand Rejuvenation", weapon = "RESTORATION STAFF", trait = "POWERED", enchant = "ABSORB MAGICKA", perfectedPreferred = true },
            backWeapon = { set = "Pillager's Profit", weapon = "FROST STAFF", trait = "CHARGED", enchant = "WEAKENING", perfectedPreferred = true },
            core = { "Serpent's Disdain x5 light body", "Perfected Pillager's Profit back bar plus jewelry", "Perfected Grand Rejuvenation Restoration Staff front bar", "Ozezan the Inferno two-piece" },
            note = baseNote, sourceKey = "WARDEN_HEAL_LIVE",
        }
    elseif classKey == "NECRO" then
        return {
            label = "TRIAL HEALER / ENDGAME", confidence = "CURATED",
            body = {
                { set = "Master Architect", count = 5, armor = "LIGHT", trait = "DIVINES", enchant = "MAGICKA" },
                { set = "Nazaray", count = 1, armor = "LIGHT", trait = "DIVINES", enchant = "MAGICKA" },
                { set = "Nazaray", count = 1, armor = "MEDIUM", trait = "DIVINES", enchant = "MAGICKA" },
            },
            neck = { set = "Powerful Assault", trait = "INFUSED", enchant = "SPELL DAMAGE" },
            rings = {
                { set = "Powerful Assault", trait = "ARCANE", enchant = "SPELL DAMAGE" },
                { set = "Powerful Assault", trait = "ARCANE", enchant = "SPELL DAMAGE" },
            },
            frontWeapon = { set = "Grand Rejuvenation", weapon = "RESTORATION STAFF", trait = "DECISIVE", enchant = "WEAPON DAMAGE", perfectedPreferred = true },
            backWeapon = { set = "Powerful Assault", weapon = "FIRE STAFF", trait = "INFUSED", enchant = "WEAKENING" },
            core = { "Master Architect x5 light body", "Powerful Assault back bar plus jewelry", "Perfected Grand Rejuvenation Restoration Staff front bar", "Nazaray two-piece" },
            note = baseNote, sourceKey = "NECRO_HEAL_LIVE",
        }
    elseif classKey == "TEMPLAR" then
        return {
            label = "TRIAL MAIN HEALER / ENDGAME", confidence = "CURATED",
            body = {
                { set = "Spell Power Cure", count = 3, armor = "LIGHT", trait = "DIVINES", enchant = "MAGICKA" },
                { set = "Pillager's Profit", count = 1, armor = "LIGHT", trait = "DIVINES", enchant = "MAGICKA", perfectedPreferred = true },
                { set = "Ozezan the Inferno", count = 1, armor = "MEDIUM", trait = "DIVINES", enchant = "MAGICKA" },
                { set = "Ozezan the Inferno", count = 1, armor = "HEAVY", trait = "DIVINES", enchant = "MAGICKA" },
                { set = "Cryptcanon Vestments", count = 1, armor = "LIGHT", trait = "DIVINES", enchant = "MAGICKA" },
            },
            neck = { set = "Pillager's Profit", trait = "INFUSED", enchant = "SPELL DAMAGE", perfectedPreferred = true },
            rings = {
                { set = "Pillager's Profit", trait = "INFUSED", enchant = "SPELL DAMAGE", perfectedPreferred = true },
                { set = "Pillager's Profit", trait = "INFUSED", enchant = "SPELL DAMAGE", perfectedPreferred = true },
            },
            frontWeapon = { set = "Spell Power Cure", weapon = "RESTORATION STAFF", trait = "PRECISE", enchant = "WEAPON DAMAGE" },
            backWeapon = { set = "Pillager's Profit", weapon = "FIRE STAFF", trait = "INFUSED", enchant = "WEAKENING", perfectedPreferred = true },
            core = { "Spell Power Cure front bar plus three body pieces", "Perfected Pillager's Profit back bar plus jewelry/body", "Ozezan the Inferno two-piece", "Cryptcanon Vestments flex mythic" },
            note = baseNote, sourceKey = "TEMPLAR_HEAL_LIVE",
        }
    elseif classKey == "ARC" then
        return {
            label = "TRIAL HEALER / ENDGAME", confidence = "CURATED",
            body = {
                { set = "Pillager's Profit", count = 5, armor = "LIGHT", trait = "DIVINES", enchant = "MAGICKA", perfectedPreferred = true },
                { set = "Ozezan the Inferno", count = 1, armor = "LIGHT", trait = "DIVINES", enchant = "MAGICKA" },
                { set = "Ozezan the Inferno", count = 1, armor = "MEDIUM", trait = "DIVINES", enchant = "MAGICKA" },
            },
            neck = { set = "Xoryn's Masterpiece", trait = "INFUSED", enchant = "SPELL DAMAGE", perfectedPreferred = true },
            rings = {
                { set = "Xoryn's Masterpiece", trait = "INFUSED", enchant = "SPELL DAMAGE", perfectedPreferred = true },
                { set = "Xoryn's Masterpiece", trait = "INFUSED", enchant = "SPELL DAMAGE", perfectedPreferred = true },
            },
            frontWeapon = { set = "Xoryn's Masterpiece", weapon = "RESTORATION STAFF", trait = "PRECISE", enchant = "ABSORB HEALTH", perfectedPreferred = true },
            backWeapon = { set = "Xoryn's Masterpiece", weapon = "LIGHTNING STAFF", trait = "PRECISE", enchant = "ABSORB HEALTH", perfectedPreferred = true },
            core = { "Perfected Pillager's Profit x5 light body", "Perfected Xoryn's Masterpiece double-barred plus jewelry", "Restoration Staff front bar; Lightning Staff back bar", "Ozezan the Inferno two-piece" },
            note = baseNote, sourceKey = "ARC_HEAL_LIVE",
        }
    end
    return nil
end

local function makePresets(base, role)
    if not base then return {} end
    local roleNote = role == "DAMAGE"
        and "Encounter-specific add-pull, support-DD, mythic, and subclass variants can outperform this baseline."
        or "Support sets are frequently assigned at group level; do not overwrite a raid-lead assignment just to match this baseline."
    base.note = tostring(base.note or "") .. " " .. roleNote
    return {
        TRIAL = base,
        SINGLE_TARGET = { inherit = "TRIAL", label = role == "DAMAGE" and "SINGLE TARGET" or "BOSS / SINGLE TARGET" },
        AOE_TRASH = { inherit = "TRIAL", label = "AOE / TRASH", note = tostring(base.note or "") .. " The current class/role core is retained when no stronger verified encounter-specific current variant is encoded." },
        SOLO = { inherit = "TRIAL", label = "SOLO", note = tostring(base.note or "") .. (role == "DAMAGE" and " Solo survivability may justify a defensive flex piece." or " For solo play, switch the role override to DAMAGE if your goal is personal DPS rather than support gear.") },
    }
end

M.PROFILES = {}
for classId, classData in pairs(M.CLASSES) do
    for _, resource in ipairs({ "MAGICKA", "STAMINA" }) do
        local dps = dpsTemplate(classData.key, resource)
        local suffix = resource == "MAGICKA" and "MAG" or "STAM"
        M.PROFILES["DAMAGE_" .. classData.key .. "_" .. suffix] = {
            label = resource == "MAGICKA" and ("Magicka " .. classData.name .. " PvE DPS") or ("Stamina " .. classData.name .. " PvE DPS"),
            classId = classId, role = "DAMAGE", resource = resource,
            presets = makePresets(dps, "DAMAGE"),
        }
    end

    M.PROFILES["TANK_" .. classData.key] = {
        label = classData.name .. " PvE Tank",
        classId = classId, role = "TANK", resource = "SUPPORT",
        presets = makePresets(tankTemplate(classData.key), "TANK"),
    }

    M.PROFILES["HEALER_" .. classData.key] = {
        label = classData.name .. " PvE Healer",
        classId = classId, role = "HEALER", resource = "MAGICKA",
        presets = makePresets(healerTemplate(classData.key), "HEALER"),
    }
end

function M:GetProfileKey(classId, magicka, role)
    local classData = self.CLASSES[tonumber(classId)]
    if not classData then return nil end
    role = string.upper(tostring(role or "DAMAGE"))
    if role == "TANK" then return "TANK_" .. classData.key end
    if role == "HEALER" then return "HEALER_" .. classData.key end
    return "DAMAGE_" .. classData.key .. "_" .. (magicka == true and "MAG" or "STAM")
end

function M:GetProfileLabel(classId, magicka, role)
    local key = self:GetProfileKey(classId, magicka, role)
    local profile = key and self.PROFILES[key] or nil
    return profile and profile.label or nil
end

function M:GetTemplate(profile, presetKey)
    profile = profile or {}
    local profileKey = profile.metaKey or self:GetProfileKey(profile.classId, profile.magicka, profile.role)
    local data = profileKey and self.PROFILES[profileKey] or nil
    if not data then return nil end

    presetKey = tostring(presetKey or "TRIAL")
    local raw = data.presets and data.presets[presetKey] or nil
    if not raw then return nil end
    if raw.inherit then
        local base = data.presets[raw.inherit]
        if not base then return nil end
        local merged = cloneTable(base)
        for key, value in pairs(raw) do
            if key ~= "inherit" then merged[key] = cloneTable(value) end
        end
        merged.profileKey = profileKey
        merged.profileLabel = data.label
        merged.presetKey = presetKey
        return merged
    end

    local result = cloneTable(raw)
    result.profileKey = profileKey
    result.profileLabel = data.label
    result.presetKey = presetKey
    return result
end

function M:GetTemplateSetNames(template)
    local result, seen = {}, {}
    local function add(name)
        local key = normalize(name)
        if key ~= "" and not seen[key] then
            seen[key] = true
            result[#result + 1] = tostring(name)
        end
    end
    if type(template) ~= "table" then return result end
    for _, entry in ipairs(template.body or {}) do add(entry.set) end
    if template.neck then add(template.neck.set) end
    for _, entry in ipairs(template.rings or {}) do add(entry.set) end
    if template.frontWeapon then add(template.frontWeapon.set) end
    if template.frontOffhand then add(template.frontOffhand.set) end
    if template.backWeapon then add(template.backWeapon.set) end
    if template.backOffhand then add(template.backOffhand.set) end
    return result
end

function M:GetSummaryLines(profile, presetKey)
    local template = self:GetTemplate(profile, presetKey)
    local snapshot = self.SNAPSHOT or {}
    if not template then
        return {
            "Meta: Current",
            "Checked: " .. tostring(snapshot.checked or "Unknown"),
            "Curated template: unavailable for this class/role/preset",
            "BEST ENDGAME falls back to the Suite's local gear scoring and configured target sets.",
        }
    end

    local lines = {
        "Meta: Current",
        "Checked: " .. tostring(snapshot.checked or "Unknown"),
        "Profile: " .. tostring(template.profileLabel or "Endgame PvE"),
        "Preset: " .. tostring(template.label or presetKey or "TRIAL"),
    }
    for _, line in ipairs(template.core or {}) do lines[#lines + 1] = tostring(line) end
    if template.note and template.note ~= "" then lines[#lines + 1] = tostring(template.note) end
    lines[#lines + 1] = "BEST ENDGAME compares worn + backpack gear to the current template and reports missing or trait/weight improvements."
    return lines
end
