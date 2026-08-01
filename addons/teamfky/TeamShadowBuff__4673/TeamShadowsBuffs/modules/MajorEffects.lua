TeamShadowsBuffs = TeamShadowsBuffs or {}

local TSB = TeamShadowsBuffs
local EM = EVENT_MANAGER
local MODULE_NAME = "MajorEffects"
local EVENT_PREFIX = TSB.name .. MODULE_NAME
local SCAN_UPDATE = EVENT_PREFIX .. "ScanUpdate"

local Module = {
    name = MODULE_NAME,
    abilityIds = {},
    active = {
        player = {},
        boss = {},
    },
    cooldowns = {}, -- timers de proc/cooldown (clé d'effet -> {endTime,duration,...}), NON effacé par Scan
}

-- Les effets viennent désormais du catalogue (TeamShadowsBuffsCatalog.lua),
-- groupés par cible. "player" -> buffs joueur ; "target" -> debuffs cible/boss.
-- Repli sur l'ancien set minimal si le catalogue n'est pas chargé.
local effects = { playerBuffs = {}, bossDebuffs = {} }
if TSB.GetCatalogByTarget then
    local player, target = TSB.GetCatalogByTarget()
    effects.playerBuffs = player or {}
    effects.bossDebuffs = target or {}
else
    effects.playerBuffs = {
        { key = "major_slayer", shortName = "TM", name = "Tueur majeur", ids = { 93109, 93120, 93442 }, color = { r = 0.2, g = 0.72, b = 0.32 }, defaultEnabled = true },
        { key = "major_courage", shortName = "CM", name = "Courage majeur", ids = { 109966 }, color = { r = 0.22, g = 0.56, b = 0.96 }, defaultEnabled = true },
    }
    effects.bossDebuffs = {
        { key = "major_vulnerability", shortName = "VM", name = "Vulnerabilite", ids = { 106754, 122389, 122177 }, color = { r = 0.82, g = 0.18, b = 0.22 }, defaultEnabled = true },
        { key = "off_balance", shortName = "DE", name = "Desequilibre", ids = { 39077, 63003, 102771 }, color = { r = 0.95, g = 0.86, b = 0.18 }, defaultEnabled = true },
    }
    if TSB.Chat then TSB.Chat("Catalogue absent: charge TeamShadowsBuffsCatalog.lua AVANT MajorEffects dans le .txt.") end
end

local effectsByKey = {}

local effectById = {}

local function NormalizeName(value)
    value = string.lower(tostring(value or ""))
    value = value:gsub("é", "e"):gsub("è", "e"):gsub("ê", "e"):gsub("ë", "e")
    value = value:gsub("à", "a"):gsub("â", "a")
    value = value:gsub("î", "i"):gsub("ï", "i")
    value = value:gsub("ô", "o")
    value = value:gsub("ù", "u"):gsub("û", "u")
    value = value:gsub("ç", "c")
    return value
end

local function FindEffectByName(effectName)
    local normalized = NormalizeName(effectName)
    if normalized == "" then return nil end

    if normalized:find("desequilibre", 1, true) or normalized:find("quilibre", 1, true) or normalized:find("off balance", 1, true) then
        return effectsByKey.off_balance
    end

    return nil
end

local function CopyColor(color)
    color = color or {}
    return {
        r = color.r or 1,
        g = color.g or 1,
        b = color.b or 1,
        a = color.a or 1,
    }
end

function TSB.GetMajorEffectDefinitions()
    return effects
end

function TSB.GetMajorEffectByKey(key)
    return effectsByKey[key]
end

function TSB.GetEffectSettings(key)
    if not TSB.savedVars then return {} end
    TSB.savedVars.effectSettings = TSB.savedVars.effectSettings or {}
    TSB.savedVars.effectSettings[key] = TSB.savedVars.effectSettings[key] or {}
    return TSB.savedVars.effectSettings[key]
end

function TSB.ResetEffectSettings(key)
    if not TSB.savedVars or not TSB.savedVars.effectSettings then return end
    TSB.savedVars.effectSettings[key] = nil
    TSB.NotifyDisplayChanged()
end

function TSB.ResetAllEffectSettings()
    if not TSB.savedVars then return end
    TSB.savedVars.effectSettings = {}
    TSB.NotifyDisplayChanged()
end

function TSB.EnsureEffectSettingsDefaults()
    if not TSB.savedVars then return end
    TSB.savedVars.effectSettings = TSB.savedVars.effectSettings or {}
end

local function GetEffectColor(effect)
    local settings = TSB.GetEffectSettings and TSB.GetEffectSettings(effect.key) or {}
    if settings.color then
        return CopyColor(settings.color)
    end
    return CopyColor(effect.color)
end

local function IsEffectEnabled(effect)
    local settings = TSB.GetEffectSettings and TSB.GetEffectSettings(effect.key) or {}
    if settings.enabled ~= nil then return settings.enabled end
    -- pas de choix utilisateur : seul le set d'origine est ON par défaut
    return effect.defaultEnabled == true
end

-- exposé pour l'UI (même logique de défaut)
function TSB.IsEffectEnabledByKey(key)
    local effect = effectsByKey[key]
    if not effect then return false end
    return IsEffectEnabled(effect)
end

local function GetEffectName(effect)
    local settings = TSB.GetEffectSettings and TSB.GetEffectSettings(effect.key) or {}
    if type(settings.name) == "string" and settings.name ~= "" then
        return settings.name
    end
    return effect.name
end

local function GetEffectShortName(effect)
    local settings = TSB.GetEffectSettings and TSB.GetEffectSettings(effect.key) or {}
    if type(settings.shortName) == "string" and settings.shortName ~= "" then
        return settings.shortName
    end
    return effect.shortName
end

local function GetDisplayName(effect)
    local name = GetEffectName(effect)
    name = name:gsub("majeure", "MAJ")
    name = name:gsub("majeur", "MAJ")
    return name
end

local function GetEffectIcon(effect)
    if effect.icon then
        return effect.icon
    end
    if GetAbilityIcon then
        for _, abilityId in ipairs(effect.ids or {}) do
            local icon = GetAbilityIcon(abilityId)
            if type(icon) == "string" and icon ~= "" then
                effect.icon = icon
                return icon
            end
        end
    end
    return nil
end

local function IndexEffect(effect, targetType)
    effect.targetType = targetType
    effectsByKey[effect.key] = effect
    for _, abilityId in ipairs(effect.ids or {}) do
        if not effectById[abilityId] then
            table.insert(Module.abilityIds, abilityId)
        end
        effectById[abilityId] = effect
    end
end

for _, effect in ipairs(effects.playerBuffs) do
    IndexEffect(effect, "player")
end

for _, effect in ipairs(effects.bossDebuffs) do
    IndexEffect(effect, "boss")
end

local function IsPlayerUnitTag(unitTag)
    if unitTag == "player" then return true end
    if unitTag and AreUnitsEqual then
        return AreUnitsEqual("player", unitTag)
    end
    return false
end

local function IsBossUnitTag(unitTag)
    return unitTag == "reticleover" or (type(unitTag) == "string" and unitTag:find("boss", 1, true) == 1)
end

local function GetBucket(targetType)
    Module.active[targetType] = Module.active[targetType] or {}
    return Module.active[targetType]
end

local function Forget(effect)
    GetBucket(effect.targetType)[effect.key] = nil
end

local function Remember(effect, effectName, unitTag, abilityId, beginTime, endTime, iconName, stackCount)
    local unitName = unitTag and DoesUnitExist(unitTag) and GetUnitName(unitTag) or nil
    local now = GetGameTimeSeconds and GetGameTimeSeconds() or 0
    beginTime = tonumber(beginTime) or 0
    endTime = tonumber(endTime) or 0
    if endTime <= now then
        Forget(effect)
        return
    end

    local previous = GetBucket(effect.targetType)[effect.key]
    local duration = beginTime > 0 and endTime > beginTime and (endTime - beginTime) or nil
    duration = duration or (previous and previous.duration) or (endTime - now)
    GetBucket(effect.targetType)[effect.key] = {
        effect = effect,
        effectName = effectName,
        unitTag = unitTag,
        unitName = unitName,
        abilityId = abilityId,
        beginTime = beginTime,
        endTime = endTime,
        duration = duration,
        icon = iconName,
        stackCount = tonumber(stackCount) or 0,
    }
end

-- set/proc à cooldown : on lance un décompte manuel de `effect.cooldown` secondes,
-- indépendant de l'aura. Stocké dans Module.cooldowns (jamais effacé par Scan).
local function StartCooldown(effect, stackCount)
    local cd = tonumber(effect.cooldown) or 0
    if cd <= 0 then return end
    local now = GetGameTimeSeconds and GetGameTimeSeconds() or 0
    local existing = Module.cooldowns[effect.key]
    if existing and existing.endTime and existing.endTime > now then return end -- déjà en cooldown
    Module.cooldowns[effect.key] = {
        effect = effect,
        beginTime = now,
        endTime = now + cd,
        duration = cd,
        icon = GetEffectIcon(effect),
        stackCount = tonumber(stackCount) or 0,
    }
end

-- DÉTECTION VIA JOURNAL DE COMBAT : pour les procs de dégâts purs (Wrath of
-- Elements, etc.) qui ne posent AUCUNE aura, EVENT_EFFECT_CHANGED ne se déclenche
-- jamais. On écoute donc l'event de combat (du jeu de base, comme Combat Metrics) :
-- si une ability du joueur correspond à un proc à cooldown du catalogue, on lance
-- son cooldown. EVENT_COMBAT_EVENT, abilityId = dernier argument.
local seenDmg = {}
local function OnCombatEvent(_, _, _, abilityName, _, _, _, _, _, _, _, _, _, _, _, _, abilityId)
    if not abilityId or abilityId == 0 then return end
    local effect = effectById[abilityId]
    if effect and effect.cooldown and effect.cooldown > 0 then
        StartCooldown(effect, 0)
        TSB.NotifyDisplayChanged()
    end
    -- debug : liste DÉDUPLIQUÉE des abilities de dégâts du joueur, pour récupérer
    -- les IDs manquants (ex. Wrath of Elements). Une ligne par ability, pas de flood.
    if TSB.savedVars and TSB.savedVars.debug and not seenDmg[abilityId] then
        seenDmg[abilityId] = true
        TSB.Chat(string.format("[dmg] %s | id=%s%s", tostring(abilityName), tostring(abilityId),
            effect and (" | catalogue=" .. tostring(effect.key)) or ""))
    end
end

local function OnEffectChanged(_, changeType, _, effectName, unitTag, beginTime, endTime, stackCount, iconName, _, _, _, _, _, _, abilityId)
    local effect = (abilityId and effectById[abilityId]) or FindEffectByName(effectName)
    if not effect then return end

    -- DEBUG : logge tout effet du catalogue détecté, AVANT les filtres de cible.
    -- Révèle si l'ID proc bien et sur quelle unité (player vs reticleover/boss...).
    if TSB.savedVars and TSB.savedVars.debug then
        local typ = (changeType == EFFECT_RESULT_GAINED and "GAINED")
            or (changeType == EFFECT_RESULT_FADED and "FADED")
            or (changeType == EFFECT_RESULT_UPDATED and "UPDATED") or tostring(changeType)
        TSB.Chat(string.format("[detect] %s | id=%s | unit=%s | attendu=%s | %s",
            tostring(effect.key), tostring(abilityId), tostring(unitTag), tostring(effect.targetType), typ))
    end

    -- PROC À COOLDOWN : traité AVANT le filtre d'unité strict.
    -- Les procs remontent très souvent avec un unitTag vide (cf. sellistrix id=80545
    -- unit= dans les logs). On accepte donc le tag vide, le tag attendu, mais on
    -- écarte un tag d'unité clairement autre (ex. group1 = proc d'un coéquipier).
    if effect.cooldown and effect.cooldown > 0 then
        if changeType == EFFECT_RESULT_GAINED then
            local okUnit = (unitTag == nil or unitTag == "")
                or (effect.targetType == "player" and IsPlayerUnitTag(unitTag))
                or (effect.targetType == "boss" and IsBossUnitTag(unitTag))
            if okUnit then StartCooldown(effect, stackCount) end
        end
        TSB.NotifyDisplayChanged()
        return
    end

    -- effets d'aura classiques : filtres d'unité stricts.
    -- (le Scan 500ms lit directement les buffs de player/boss, donc il rattrape
    --  les events qui arrivent avec un tag vide — pas de perte pour les auras.)
    if effect.targetType == "player" and not IsPlayerUnitTag(unitTag) then return end
    if effect.targetType == "boss" and not IsBossUnitTag(unitTag) then return end
    if Module.savedVars and Module.savedVars.trackPlayerBuffs == false and effect.targetType == "player" then return end
    if Module.savedVars and Module.savedVars.trackBossDebuffs == false and effect.targetType == "boss" then return end

    if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
        Remember(effect, effectName, unitTag, abilityId, beginTime, endTime, iconName, stackCount)
    elseif changeType == EFFECT_RESULT_FADED then
        Forget(effect)
    end

    TSB.NotifyDisplayChanged()
end

local function ScanUnit(unitTag, targetType)
    if not GetNumBuffs or not GetUnitBuffInfo or not DoesUnitExist(unitTag) then return end

    for i = 1, GetNumBuffs(unitTag) or 0 do
        local effectName, beginTime, endTime, _, stackCount, iconName, _, _, _, _, abilityId = GetUnitBuffInfo(unitTag, i)
        local effect = (abilityId and effectById[abilityId]) or FindEffectByName(effectName)
        if effect and effect.targetType == targetType and not (effect.cooldown and effect.cooldown > 0) then
            Remember(effect, effectName, unitTag, abilityId, beginTime, endTime, iconName, stackCount)
        end
    end
end

function Module:Scan()
    self.active = { player = {}, boss = {} }

    if self.savedVars.trackPlayerBuffs ~= false then
        ScanUnit("player", "player")
    end

    if self.savedVars.trackBossDebuffs ~= false then
        for i = 1, 6 do
            ScanUnit("boss" .. tostring(i), "boss")
        end
        ScanUnit("reticleover", "boss")
    end

    TSB.NotifyDisplayChanged()
end

local function RemainingSeconds(state)
    if not state or not state.endTime or state.endTime <= 0 or not GetGameTimeSeconds then return nil end
    local remaining = state.endTime - GetGameTimeSeconds()
    return remaining > 0 and remaining or 0
end

local function BuildLine(targetType, label, definitions)
    local parts = {}
    local active = GetBucket(targetType)

    for _, effect in ipairs(definitions or {}) do
        local state = active[effect.key]
        if state then
            local remaining = RemainingSeconds(state)
            if remaining then
                table.insert(parts, string.format("%s %.1fs", effect.name, remaining))
            else
                table.insert(parts, effect.name)
            end
        end
    end

    if #parts == 0 then
        return label .. " : aucun"
    end

    return label .. " : " .. table.concat(parts, " / ")
end

local function ParseOrder(orderText, fallback)
    local result = {}
    local seen = {}

    for key in tostring(orderText or ""):gmatch("[^,%s]+") do
        if effectsByKey[key] and not seen[key] then
            table.insert(result, key)
            seen[key] = true
        end
    end

    for _, effect in ipairs(fallback or {}) do
        if not seen[effect.key] then
            table.insert(result, effect.key)
            seen[effect.key] = true
        end
    end

    return result
end

local function BuildDisplayItems(targetType, orderText, fallback)
    local items = {}
    local active = GetBucket(targetType)
    local now = GetGameTimeSeconds and GetGameTimeSeconds() or 0

    for _, key in ipairs(ParseOrder(orderText, fallback)) do
        local effect = effectsByKey[key]
        local isCooldown = effect and effect.cooldown and effect.cooldown > 0
        -- source de la donnée : timer de cooldown (séparé) ou aura (active)
        local state = isCooldown and Module.cooldowns[key] or active[key]
        if state and effect and IsEffectEnabled(effect) then
            local remaining = RemainingSeconds(state)
            if remaining and remaining > 0 then
                local duration = tonumber(state.duration) or remaining or 0
                local ratio = duration > 0 and (remaining / duration) or 1
                table.insert(items, {
                    key = key,
                    name = GetDisplayName(effect),
                    shortName = GetEffectShortName(effect),
                    color = GetEffectColor(effect),
                    icon = state.icon or GetEffectIcon(effect),
                    remaining = remaining,
                    endTime = state.endTime,
                    duration = duration,
                    ratio = ratio,
                    targetType = targetType,
                    stacks = tonumber(state.stackCount) or 0,
                    isCooldown = isCooldown or nil,
                    maxStacks = effect.maxStacks,
                })
            else
                if isCooldown then Module.cooldowns[key] = nil else active[key] = nil end
            end
        end
    end

    return items
end

local function BuildPreviewItems(targetType, orderText, fallback)
    local items = {}
    local now = GetGameTimeSeconds and GetGameTimeSeconds() or 0
    local offset = 0

    for _, key in ipairs(ParseOrder(orderText, fallback)) do
        local effect = effectsByKey[key]
        if effect and IsEffectEnabled(effect) then
            local duration = effect.cooldown and effect.cooldown > 0 and effect.cooldown or 16
            local remaining = duration - (offset % 5) * (duration * 0.12)
            if remaining < duration * 0.25 then remaining = duration * 0.25 end
            local stacks = 0
            if effect.maxStacks then stacks = 1 + (offset % effect.maxStacks) end
            table.insert(items, {
                key = key,
                name = GetDisplayName(effect),
                shortName = GetEffectShortName(effect),
                color = GetEffectColor(effect),
                icon = GetEffectIcon(effect),
                remaining = remaining,
                endTime = now + remaining,
                duration = duration,
                ratio = remaining / duration,
                targetType = targetType,
                stacks = stacks,
                isCooldown = (effect.cooldown and effect.cooldown > 0) or nil,
                maxStacks = effect.maxStacks,
                preview = true,
            })
            offset = offset + 1
        end
    end

    return items
end

function Module:GetDisplayItems()
    local player = BuildDisplayItems("player", TSB.savedVars and TSB.savedVars.playerOrder, effects.playerBuffs)
    local boss = BuildDisplayItems("boss", TSB.savedVars and TSB.savedVars.bossOrder, effects.bossDebuffs)
    local combined = {}

    for _, item in ipairs(player) do
        table.insert(combined, item)
    end
    for _, item in ipairs(boss) do
        table.insert(combined, item)
    end

    return {
        player = player,
        boss = boss,
        combined = combined,
    }
end

function Module:GetPreviewDisplayItems()
    local player = BuildPreviewItems("player", TSB.savedVars and TSB.savedVars.playerOrder, effects.playerBuffs)
    local boss = BuildPreviewItems("boss", TSB.savedVars and TSB.savedVars.bossOrder, effects.bossDebuffs)
    local combined = {}

    for _, item in ipairs(player) do
        table.insert(combined, item)
    end
    for _, item in ipairs(boss) do
        table.insert(combined, item)
    end

    return {
        player = player,
        boss = boss,
        combined = combined,
    }
end

function TSB.GetDisplayItems()
    if TSB.modules.MajorEffects and TSB.modules.MajorEffects.GetDisplayItems then
        return TSB.modules.MajorEffects:GetDisplayItems()
    end
    return { player = {}, boss = {}, combined = {} }
end

function TSB.GetPreviewDisplayItems()
    if TSB.modules.MajorEffects and TSB.modules.MajorEffects.GetPreviewDisplayItems then
        return TSB.modules.MajorEffects:GetPreviewDisplayItems()
    end
    return { player = {}, boss = {}, combined = {} }
end

function Module:PrintStatus()
    self:Scan()
    TSB.Chat(BuildLine("player", "Buffs joueur", effects.playerBuffs))
    TSB.Chat(BuildLine("boss", "Debuffs boss", effects.bossDebuffs))
end

function Module:Load(savedVars)
    self.savedVars = savedVars or {}
    self.active = { player = {}, boss = {} }
    self.cooldowns = {}
    seenDmg = {}

    for _, abilityId in ipairs(self.abilityIds or {}) do
        local eventName = EVENT_PREFIX .. tostring(abilityId)
        EM:RegisterForEvent(eventName, EVENT_EFFECT_CHANGED, function(...)
            TSB.SafeCall(MODULE_NAME, "OnEffectChanged", OnEffectChanged, ...)
        end)
        EM:AddFilterForEvent(eventName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityId)
    end

    -- journal de combat : détecte les procs de dégâts purs sans aura + alimente le
    -- logger debug [dmg]. On écoute la source JOUEUR *et* ses FAMILIERS/INVOCATIONS,
    -- car certains sets (Maarselok, etc.) infligent leurs dégâts via une invocation
    -- dont la source n'est pas le joueur directement.
    local combatSources = { COMBAT_UNIT_TYPE_PLAYER, COMBAT_UNIT_TYPE_PLAYER_PET }
    for i, srcType in ipairs(combatSources) do
        if srcType ~= nil then
            local cn = EVENT_PREFIX .. "Combat" .. tostring(i)
            EM:RegisterForEvent(cn, EVENT_COMBAT_EVENT, function(...)
                TSB.SafeCall(MODULE_NAME, "OnCombatEvent", OnCombatEvent, ...)
            end)
            EM:AddFilterForEvent(cn, EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, srcType)
        end
    end

    EM:RegisterForEvent(EVENT_PREFIX .. "Bosses", EVENT_BOSSES_CHANGED, function()
        TSB.SafeCall(MODULE_NAME, "Scan", function() self:Scan() end)
    end)

    EM:RegisterForEvent(EVENT_PREFIX .. "Reticle", EVENT_RETICLE_TARGET_CHANGED, function()
        TSB.SafeCall(MODULE_NAME, "Scan", function() self:Scan() end)
    end)

    EM:RegisterForUpdate(SCAN_UPDATE, 500, function()
        TSB.SafeCall(MODULE_NAME, "Scan", function() self:Scan() end)
    end)

    zo_callLater(function()
        TSB.SafeCall(MODULE_NAME, "Scan", function() self:Scan() end)
    end, 800)

    if TSB.savedVars and TSB.savedVars.debug then
        TSB.Chat(string.format("détection debug ACTIVE : %d IDs surveillés. Tape sur une vraie cible (le MODE TEST n'en génère pas).", #(self.abilityIds or {})))
    end
end

function Module:Unload()
    for _, abilityId in ipairs(self.abilityIds or {}) do
        EM:UnregisterForEvent(EVENT_PREFIX .. tostring(abilityId), EVENT_EFFECT_CHANGED)
    end
    EM:UnregisterForEvent(EVENT_PREFIX .. "Bosses", EVENT_BOSSES_CHANGED)
    EM:UnregisterForEvent(EVENT_PREFIX .. "Reticle", EVENT_RETICLE_TARGET_CHANGED)
    EM:UnregisterForEvent(EVENT_PREFIX .. "Combat1", EVENT_COMBAT_EVENT)
    EM:UnregisterForEvent(EVENT_PREFIX .. "Combat2", EVENT_COMBAT_EVENT)
    EM:UnregisterForUpdate(SCAN_UPDATE)
    self.active = { player = {}, boss = {} }
    self.cooldowns = {}
    TSB.NotifyDisplayChanged()
end

TSB.RegisterModule(Module)
