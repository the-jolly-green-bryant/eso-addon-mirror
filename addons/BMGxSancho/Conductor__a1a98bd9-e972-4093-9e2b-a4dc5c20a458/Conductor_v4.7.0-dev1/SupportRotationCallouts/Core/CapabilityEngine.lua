local C = Conductor
C.CapabilityEngine = C.CapabilityEngine or {}
local Engine = C.CapabilityEngine

local function Normalize(value)
    return string.upper(tostring(value or "")):gsub("[^A-Z0-9]", "")
end

local function AddCapability(target, key, name, category, sourceType, sourceName, confidence, details)
    target._index = target._index or {}
    if target._index[key] then
        local existing = target._index[key]
        existing.sources = existing.sources or {}
        existing.sources[#existing.sources + 1] = {
            type = sourceType,
            name = sourceName,
            confidence = confidence or "CONFIRMED",
            details = details,
            providerKey = details and details.providerKey or nil,
        }
        return existing
    end

    local entry = {
        key = key,
        name = name,
        category = category,
        confidence = confidence or "CONFIRMED",
        sources = {
            {
                type = sourceType,
                name = sourceName,
                confidence = confidence or "CONFIRMED",
                details = details,
                providerKey = details and details.providerKey or nil,
            },
        },
    }
    target[#target + 1] = entry
    target._index[key] = entry
    return entry
end


local function FindRegistryEntryByName(collectionName, displayName)
    local target = Normalize(displayName)
    for _, entry in ipairs(Conductor.Registry:GetAll(collectionName) or {}) do
        if Normalize(entry.name) == target or Normalize(entry.displayName) == target or Normalize(entry.canonicalSetName) == target then return entry end
        for _, aliasName in ipairs(entry.aliasNames or {}) do if Normalize(aliasName) == target then return entry end end
    end
    return nil
end

local function AddRegistryProvides(interpreted, entry, sourceType, sourceName, details)
    if not entry then return end
    if Conductor.TrackingConfiguration and not Conductor.TrackingConfiguration:IsRegistryEntryEnabled(entry.registry or "PROVIDERS", entry.key) then return end
    for _, effectKey in ipairs(entry.provides or {}) do
        local effect = Conductor.Registry:Get("EFFECTS", effectKey)
        AddCapability(interpreted, effectKey, effect and effect.name or effectKey, effect and effect.effectType or "SUPPORT", sourceType, sourceName, "CONFIRMED", details)
    end
end

local GEAR_RULES = {
    MASTERARCHITECT = {
        minPieces = 5,
        capabilities = {
            { "MAJOR_SLAYER", "Major Slayer", "BUFF" },
            { "SLAYER_PROVIDER", "Slayer Provider", "RESPONSIBILITY" },
        },
    },
    WARMACHINE = {
        minPieces = 5,
        capabilities = {
            { "MAJOR_SLAYER", "Major Slayer", "BUFF" },
            { "SLAYER_PROVIDER", "Slayer Provider", "RESPONSIBILITY" },
        },
    },
    ROARINGOPPORTUNIST = {
        minPieces = 5,
        capabilities = {
            { "MAJOR_SLAYER", "Major Slayer", "BUFF" },
            { "SLAYER_PROVIDER", "Slayer Provider", "RESPONSIBILITY" },
        },
    },
    PERFECTEDROARINGOPPORTUNIST = {
        minPieces = 5,
        capabilities = {
            { "MAJOR_SLAYER", "Major Slayer", "BUFF" },
            { "SLAYER_PROVIDER", "Slayer Provider", "RESPONSIBILITY" },
        },
    },
    PILLAGERSPROFIT = {
        minPieces = 5,
        capabilities = {
            { "ULTIMATE_RESTORE", "Ultimate Restore", "SUPPORT" },
            { "PILLAGER_PROVIDER", "Pillager Provider", "RESPONSIBILITY" },
        },
    },
    PERFECTEDPILLAGERSPROFIT = {
        minPieces = 5,
        capabilities = {
            { "ULTIMATE_RESTORE", "Ultimate Restore", "SUPPORT" },
            { "PILLAGER_PROVIDER", "Pillager Provider", "RESPONSIBILITY" },
        },
    },
    TURNINGTIDE = {
        minPieces = 5,
        capabilities = {
            { "MAJOR_VULNERABILITY", "Major Vulnerability", "DEBUFF" },
            { "VULNERABILITY_PROVIDER", "Major Vulnerability Provider", "RESPONSIBILITY" },
        },
    },
    ARCHDRUIDDEVYRIC = {
        minPieces = 2,
        capabilities = {
            { "MAJOR_VULNERABILITY", "Major Vulnerability", "DEBUFF" },
            { "VULNERABILITY_PROVIDER", "Major Vulnerability Provider", "RESPONSIBILITY" },
        },
    },
    NAZARAY = {
        minPieces = 2,
        capabilities = {
            { "DEBUFF_EXTENSION", "Debuff Extension", "SUPPORT" },
            { "NAZARAY_PROVIDER", "Nazaray Provider", "RESPONSIBILITY" },
        },
    },
    POWERFULASSAULT = {
        minPieces = 5,
        capabilities = {
            { "POWERFUL_ASSAULT", "Powerful Assault", "BUFF" },
            { "POWERFUL_ASSAULT_PROVIDER", "Powerful Assault Provider", "RESPONSIBILITY" },
        },
    },
    OZEZANTHEINFERNO = {
        minPieces = 2,
        capabilities = {
            { "MINOR_VITALITY", "Minor Vitality", "BUFF" },
            { "OZEZAN_PROVIDER", "Ozezan Provider", "RESPONSIBILITY" },
        },
    },
    CLAWOFYOLNAHKRIIN = { minPieces=5, capabilities={{"MINOR_COURAGE","Minor Courage","BUFF"}} },
    SPELLPOWERCURE = { minPieces=5, capabilities={{"MAJOR_COURAGE","Major Courage","BUFF"}} },
    VESTMENTOFOLORIME = { minPieces=5, capabilities={{"MAJOR_COURAGE","Major Courage","BUFF"}} },
    NUNATAK = { minPieces=2, capabilities={{"MAJOR_BRITTLE","Major Brittle","DEBUFF"}} },
    DRAKESRUSH = { minPieces=5, capabilities={{"HEROISM","Heroism","BUFF"}} },
    VYKOSA = { minPieces=2, capabilities={{"MINOR_COWARDICE","Minor Cowardice","DEBUFF"}} },
}

local ULTIMATE_RULES = {
    AGGRESSIVEHORN = {
        { "MAJOR_FORCE", "Major Force", "BUFF" },
        { "ULT_WARHORN", "Warhorn", "ULTIMATE" },
        { "WARHORN_PROVIDER", "Warhorn Provider", "RESPONSIBILITY" },
    },
    WARHORN = {
        { "ULT_WARHORN", "Warhorn", "ULTIMATE" },
        { "WARHORN_PROVIDER", "Warhorn Provider", "RESPONSIBILITY" },
    },
    REVIVINGBARRIER = {
        { "ULT_BARRIER", "Barrier", "ULTIMATE" },
        { "BARRIER_PROVIDER", "Barrier Provider", "RESPONSIBILITY" },
    },
    BARRIER = {
        { "ULT_BARRIER", "Barrier", "ULTIMATE" },
        { "BARRIER_PROVIDER", "Barrier Provider", "RESPONSIBILITY" },
    },
    GLACIALCOLOSSUS = {
        { "MAJOR_VULNERABILITY", "Major Vulnerability", "DEBUFF" },
        { "ULT_COLOSSUS", "Colossus", "ULTIMATE" },
        { "VULNERABILITY_PROVIDER", "Major Vulnerability Provider", "RESPONSIBILITY" },
    },
    PESTILENTCOLOSSUS = {
        { "MAJOR_VULNERABILITY", "Major Vulnerability", "DEBUFF" },
        { "ULT_COLOSSUS", "Colossus", "ULTIMATE" },
        { "VULNERABILITY_PROVIDER", "Major Vulnerability Provider", "RESPONSIBILITY" },
    },
    FROZENCOLOSSUS = {
        { "MAJOR_VULNERABILITY", "Major Vulnerability", "DEBUFF" },
        { "ULT_COLOSSUS", "Colossus", "ULTIMATE" },
        { "VULNERABILITY_PROVIDER", "Major Vulnerability Provider", "RESPONSIBILITY" },
    },
    STANDARDOFMIGHT = {{"ULT_STANDARD","Standard of Might","ULTIMATE"}},
    SOLARDISTURBANCE = {{"ULT_NOVA","Nova","ULTIMATE"}},
    SOLARPRISON = {{"ULT_NOVA","Nova","ULTIMATE"}},
    ICECOMET = {{"ULT_METEOR","Meteor","ULTIMATE"}},
    SHOOTINGSTAR = {{"ULT_METEOR","Meteor","ULTIMATE"}},
    GREATERSTORMATRONACH = {{"ULT_ATRONACH","Storm Atronach","ULTIMATE"}},
    CHARGEDATRONACH = {{"ULT_ATRONACH","Storm Atronach","ULTIMATE"}},
    CRYPTCANNON = {{"ULT_CRYPTCANNON","Cryptcannon","ULTIMATE"}},
}

local SKILL_RULES = {
    FEROCIOUSROAR = {
        { "MAJOR_COURAGE", "Major Courage", "BUFF" },
        { "MAJOR_COURAGE_PROVIDER", "Major Courage Provider", "RESPONSIBILITY" },
    },
    RUNEOFTHECOLORLESSPOOL = {
        { "MINOR_BRITTLE", "Minor Brittle", "DEBUFF" },
        { "MINOR_BRITTLE_PROVIDER", "Minor Brittle Provider", "RESPONSIBILITY" },
    },
    ELEMENTALSUSCEPTIBILITY = {
        { "MAJOR_BREACH", "Major Breach", "DEBUFF" },
        { "STATUS_EFFECT_SUPPORT", "Status Effect Support", "FUNCTION" },
    },
    PIERCEARMOR = {
        { "MAJOR_BREACH", "Major Breach", "DEBUFF" },
        { "MINOR_BREACH", "Minor Breach", "DEBUFF" },
    },
    RAZORCALTROPS = {{ "MAJOR_BREACH", "Major Breach", "DEBUFF" }},
    POWEROFTHELIGHT = {{ "MINOR_BREACH", "Minor Breach", "DEBUFF" }},
    FETCHERINFECTION = {{ "MINOR_VULNERABILITY", "Minor Vulnerability", "DEBUFF" }},
    COMBATPRAYER = {
        { "MINOR_BERSERK", "Minor Berserk", "BUFF" },
        { "MINOR_RESOLVE", "Minor Resolve", "BUFF" },
    },
    EXPANSIVEFROSTCLOAK = {{ "MAJOR_RESOLVE", "Major Resolve", "BUFF" }},
    HEROICSLASH = {{ "HEROISM", "Heroism", "BUFF" }},
}

local SCRIPT_RULES = {
    HEALING = {
        { "HEALING", "Healing", "FUNCTION" },
        { "GROUP_HEAL", "Group Healing", "FUNCTION" },
    },
    RESOLVE = {
        { "RESOLVE_SUPPORT", "Resolve Support", "FUNCTION" },
    },
    CLASSFLOURISH = {
        { "CLASS_FLOURISH", "Class Flourish", "FUNCTION" },
    },
    COURAGE = {
        { "MINOR_COURAGE", "Minor Courage", "BUFF" },
    },
    MINORCOURAGE = {
        { "MINOR_COURAGE", "Minor Courage", "BUFF" },
    },
}

local function BuildScribedProviderKey(skill, scriptName)
    local grimoire = Normalize(tostring(skill.grimoireName or "") ~= "" and skill.grimoireName or skill.abilityName)
    local script = Normalize(scriptName)
    if grimoire == "" then grimoire = "UNKNOWN_GRIMOIRE" end
    if script == "" then script = "VARIABLE_SCRIPT" end
    return "SCRIBED_" .. grimoire .. "_" .. script
end

local function HumanScribedSourceName(skill, scriptName)
    local grimoire = tostring(skill.grimoireName or "")
    if grimoire == "" then grimoire = tostring(skill.abilityName or "Scribed Ability") end
    if tostring(scriptName or "") ~= "" then return grimoire .. " (" .. tostring(scriptName) .. ")" end
    return grimoire
end

local function GetScriptRule(scriptName)
    local normalized = Normalize(scriptName)
    local direct = SCRIPT_RULES[normalized]
    if direct then return direct end
    -- Localized names may contain an extra descriptor. Courage is specifically
    -- normalized to Minor Courage by ESO's Scribing affix.
    if string.find(normalized, "MINORCOURAGE", 1, true) or normalized == "COURAGE" or string.find(normalized, "COURAGESCRIPT", 1, true) then
        return SCRIPT_RULES.MINORCOURAGE
    end
    return nil
end


GEAR_RULES.ZENSREDRESS = { minPieces=5, capabilities={{"ZEN_DAMAGE_TAKEN","Touch of Z'en","DEBUFF"}} }
GEAR_RULES.ROAROFALKOSH = { minPieces=5, capabilities={{"ALKOSH_RESISTANCE_REDUCTION","Roar of Alkosh","DEBUFF"}} }
GEAR_RULES.THEMORAGTONG = { minPieces=5, capabilities={{"MORAG_TONG_AMPLIFICATION","Morag Tong","DEBUFF"}} }
GEAR_RULES.ELEMENTALCATALYST = { minPieces=5, capabilities={{"ELEMENTAL_CATALYST_AMPLIFICATION","Elemental Catalyst","DEBUFF"}} }
GEAR_RULES.WAYOFMARTIALKNOWLEDGE = { minPieces=5, capabilities={{"MARTIAL_KNOWLEDGE_AMPLIFICATION","Martial Knowledge","DEBUFF"}} }

function Engine:Interpret(capabilities)
    capabilities = capabilities or {}
    local interpreted = {}

    for _, setEntry in ipairs(capabilities.gearSets or {}) do
        local normalized = Normalize(setEntry.setName)
        local registryEntry = FindRegistryEntryByName("GEAR", setEntry.setName) or FindRegistryEntryByName("MONSTER_SETS", setEntry.setName)
        local providerAllowed = not registryEntry or not Conductor.TrackingConfiguration or Conductor.TrackingConfiguration:IsRegistryEntryEnabled(registryEntry.registry, registryEntry.key)
        local rule = GEAR_RULES[normalized]
        if providerAllowed and rule and (tonumber(setEntry.equippedPieces) or 0) >= (rule.minPieces or 1) then
            for _, item in ipairs(rule.capabilities or {}) do
                AddCapability(interpreted, item[1], item[2], item[3], "GEAR", setEntry.setName, "CONFIRMED", {
                    pieces = tonumber(setEntry.equippedPieces) or 0,
                    setId = tonumber(setEntry.setId) or 0,
                })
            end
        end
        if providerAllowed and registryEntry and (tonumber(setEntry.equippedPieces) or 0) >= (registryEntry.piecesRequired or 1) then
            AddRegistryProvides(interpreted, registryEntry, "GEAR", setEntry.setName, {pieces=tonumber(setEntry.equippedPieces) or 0,setId=tonumber(setEntry.setId) or 0})
        end
    end

    for _, gearEntry in ipairs(capabilities.gear or {}) do
        local enchantText = Normalize((gearEntry.enchantName or "") .. " " .. (gearEntry.enchantDescription or ""))
        local isCrusher = string.find(enchantText, "CRUSHER", 1, true) ~= nil
            or (string.find(enchantText, "REDUCE", 1, true) and string.find(enchantText, "PHYSICAL", 1, true) and string.find(enchantText, "SPELLRESISTANCE", 1, true))
        if isCrusher then
            AddCapability(interpreted, "CRUSHER", "Crusher", "DEBUFF", "ENCHANTMENT", gearEntry.enchantName ~= "" and gearEntry.enchantName or "Crusher Enchantment", "CONFIRMED", { slot = gearEntry.slot, enchantId = gearEntry.enchantId })
        end
    end

    for _, ultimate in ipairs(capabilities.ultimates or {}) do
        local registryUltimate = FindRegistryEntryByName("ULTIMATES", ultimate.abilityName)
        local ultimateAllowed = not registryUltimate or not Conductor.TrackingConfiguration or Conductor.TrackingConfiguration:IsRegistryEntryEnabled("ULTIMATES", registryUltimate.key)
        local rule = ULTIMATE_RULES[Normalize(ultimate.abilityName)]
        if ultimateAllowed and rule then
            for _, item in ipairs(rule) do
                AddCapability(interpreted, item[1], item[2], item[3], "ULTIMATE", ultimate.abilityName, "CONFIRMED", {
                    bar = ultimate.bar,
                    abilityId = ultimate.abilityId,
                })
            end
        end
        if ultimateAllowed then AddRegistryProvides(interpreted, registryUltimate, "ULTIMATE", ultimate.abilityName, {bar=ultimate.bar,abilityId=ultimate.abilityId}) end
    end

    for _, skill in ipairs(capabilities.skills or {}) do
        local rule = SKILL_RULES[Normalize(skill.abilityName)]
        if rule then
            for _, item in ipairs(rule) do
                AddCapability(interpreted, item[1], item[2], item[3], "SKILL", skill.abilityName, "CONFIRMED", {
                    bar = skill.bar, slot = skill.slot, abilityId = skill.abilityId,
                })
            end
        end
        AddRegistryProvides(interpreted, FindRegistryEntryByName("SKILLS", skill.abilityName), "SKILL", skill.abilityName, {bar=skill.bar,slot=skill.slot,abilityId=skill.abilityId})
    end

    for _, skill in ipairs(capabilities.scribedSkills or {}) do
        local grimoireName = tostring(skill.grimoireName or "") ~= "" and tostring(skill.grimoireName) or tostring(skill.abilityName or "Scribed Ability")
        local scribedRegistry = FindRegistryEntryByName("SCRIBED_ABILITIES", grimoireName)
        local scribedAllowed = not scribedRegistry or not Conductor.TrackingConfiguration or Conductor.TrackingConfiguration:IsRegistryEntryEnabled("SCRIBED_ABILITIES", scribedRegistry.key)
        local genericProviderKey = BuildScribedProviderKey(skill, "")
        if scribedAllowed then AddCapability(interpreted, "SCRIBED_ABILITY", "Scribed Ability", "FUNCTION", "SCRIBING", grimoireName, "CONFIRMED", {
            craftedAbilityId = skill.craftedAbilityId,
            abilityId = skill.abilityId,
            providerKey = genericProviderKey,
            grimoireName = grimoireName,
            scriptIds = skill.scriptIds,
        }) end

        local scripts = skill.scriptSlots or {}
        if #scripts == 0 then
            for index, scriptName in ipairs(skill.scriptNames or {}) do
                scripts[#scripts + 1] = { slotType = ({"FOCUS","SIGNATURE","AFFIX"})[index] or tostring(index), scriptName = scriptName, scriptId = skill.scriptIds and skill.scriptIds[index] or 0 }
            end
        end
        if scribedAllowed then for _, script in ipairs(scripts) do
            local scriptName = tostring(script.scriptName or "")
            local rule = GetScriptRule(scriptName)
            if rule then
                local providerKey = BuildScribedProviderKey(skill, scriptName)
                local sourceName = HumanScribedSourceName(skill, scriptName)
                for _, item in ipairs(rule) do
                    AddCapability(interpreted, item[1], item[2], item[3], "SCRIBING", sourceName, "CONFIRMED", {
                        skill = skill.abilityName,
                        grimoireName = grimoireName,
                        craftedAbilityId = skill.craftedAbilityId,
                        scriptId = script.scriptId,
                        scriptName = scriptName,
                        scriptSlotType = script.slotType,
                        providerKey = providerKey,
                    })
                end
            end
        end
        end
    end

    interpreted._index = nil
    capabilities.interpreted = interpreted
    capabilities.responsibilities = {}
    capabilities.effects = {}
    for _, capability in ipairs(interpreted) do
        if capability.category == "RESPONSIBILITY" then
            capabilities.responsibilities[#capabilities.responsibilities + 1] = capability
        elseif capability.category == "BUFF" or capability.category == "DEBUFF" or capability.category == "SUPPORT" then
            capabilities.effects[#capabilities.effects + 1] = capability
        end
    end
    return interpreted
end

function Engine:GetCapability(capabilities, key)
    local normalized = tostring(key or "")
    for _, entry in ipairs((capabilities and capabilities.interpreted) or {}) do
        if entry.key == normalized then return entry end
    end
    return nil
end

function Engine:BuildResponsibilityProfile(capabilities, assignments, includeOptional)
    if not capabilities then capabilities = {} end
    if not capabilities.interpreted then self:Interpret(capabilities) end
    if not Conductor.ResponsibilityEngine then return {} end
    local profile = Conductor.ResponsibilityEngine:EvaluateAll(capabilities, assignments or {}, includeOptional)
    capabilities.responsibilityProfile = profile
    return profile
end

function Engine:GetResponsibilityState(capabilities, responsibilityKey, assignment)
    if not capabilities then capabilities = {} end
    if not capabilities.interpreted then self:Interpret(capabilities) end
    if not Conductor.ResponsibilityEngine then return nil end
    return Conductor.ResponsibilityEngine:Evaluate(responsibilityKey, capabilities, assignment)
end

function Engine:Initialize()
    self.initialized = true
end
