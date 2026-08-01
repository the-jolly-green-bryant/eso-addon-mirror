--- @class (partial) AbilityIconsFramework
local AbilityIconsFramework = AbilityIconsFramework

-- Do not allow any icon pack / base-game replacement to redirect this one.
local STAGGER_STOMP_BASE_ICON = "/esoui/art/icons/ability_dragonknight_013_a_stomp.dds"

--- Retrieves the base ability id of the skill with the specified ability id.
--- @param slotIndex number The index of a given skill in the action bar.
--- @param hotbarCategory number The category of the hotbar in question.
--- @return number? baseAbilityId The base ability id of the specified skill.
function AbilityIconsFramework.GetBaseAbilityId(slotIndex, hotbarCategory)
    local abilityId = AbilityIconsFramework.GetAbilityId(slotIndex, hotbarCategory)
    if not abilityId then return nil end

    local actionType = GetSlotType(slotIndex, hotbarCategory)
    if actionType == ACTION_TYPE_CRAFTED_ABILITY then
        return GetAbilityIdForCraftedAbilityId(abilityId)
    end

    local progressionData = SKILLS_DATA_MANAGER:GetProgressionDataByAbilityId(abilityId)
    if not progressionData then return abilityId end

    local skillData = progressionData:GetSkillData()
    if not skillData.GetMorphData then return abilityId end

    local baseMorphData = skillData:GetMorphData(MORPH_SLOT_BASE)
    return baseMorphData and baseMorphData:GetAbilityId() or abilityId
end

--- Retrieves the ability id of the skill found in the specified slotIndex.
--- @param slotIndex number The index of a given skill in the action bar.
--- @param hotbarCategory number The category of the hotbar in question.
--- @return number? abilityId The ability id that corresponds to the skill in question.
function AbilityIconsFramework.GetAbilityId(slotIndex, hotbarCategory)
    local index = tonumber(slotIndex) or 0
    if index < AbilityIconsFramework.MIN_INDEX or index > AbilityIconsFramework.MAX_INDEX then
        return nil
    end

    return GetSlotBoundId(slotIndex, hotbarCategory)
end

-- Mapping of effect names in different languages
local effectTranslations = {
    ["en"] = {
        ["flame"] = "flame",
        ["frost"] = "frost",
        ["shock"] = "shock",
        ["magic"] = "magic",
        ["heal"] = "heal",
        ["resources"] = "resources",
        ["ultimate"] = "ultimate",
        ["stun"] = "stun",
        ["immobilize"] = "immobilize",
        ["knockback"] = "knockback",
        ["dispel"] = "dispel",
        ["shield"] = "shield",
        ["physical"] = "physical",
        ["multi-target"] = "multi-target",
        ["bleed"] = "bleed",
        ["trauma"] = "trauma",
        ["poison"] = "poison",
        ["disease"] = "disease",
        ["mitigation"] = "mitigation",
        ["taunt"] = "taunt",
        ["pull"] = "pull",
    },
    ["de"] = {
        ["flame"] = "flammen",
        ["frost"] = "frost",
        ["shock"] = "schock",
        ["magic"] = "magie",
        ["heal"] = "heilung",
        ["resources"] = "ressourcen",
        ["ultimate"] = "ultimativ",
        ["stun"] = "betäubung",
        ["immobilize"] = "festhalten",
        ["knockback"] = "rückstoß",
        ["dispel"] = "bannen",
        ["shield"] = "schild",
        ["physical"] = "physisch",
        ["multi-target"] = "mehrere",
        ["bleed"] = "blutung",
        ["trauma"] = "trauma",
        ["poison"] = "gift",
        ["disease"] = "seuche",
        ["mitigation"] = "mitigation",
        ["taunt"] = "verspotten",
        ["pull"] = "ziehen",
    },
    ["fr"] = {
        ["flame"] = "flamme",
        ["frost"] = "givre",
        ["shock"] = "foudre",
        ["magic"] = "magique",
        ["heal"] = "soin",
        ["resources"] = "ressources",
        ["ultimate"] = "ultime",
        ["stun"] = "étourdissement",
        ["immobilize"] = "immobiliser",
        ["knockback"] = "repousse",
        ["dispel"] = "dissiper",
        ["shield"] = "bouclier",
        ["physical"] = "physique",
        ["multi-target"] = "cible multiple",
        ["bleed"] = "saignement",
        ["trauma"] = "trauma",
        ["poison"] = "poison",
        ["disease"] = "maladie",
        ["mitigation"] = "absorption",
        ["taunt"] = "provocation",
        ["pull"] = "attraction",
    },
    ["es"] = {
        ["flame"] = "fuego",
        ["frost"] = "escarcha",
        ["shock"] = "descarga",
        ["magic"] = "mágic",
        ["heal"] = "cura",
        ["resources"] = "recursos",
        ["ultimate"] = "habilidad máxima",
        ["stun"] = "aturdimiento",
        ["immobilize"] = "inmovilizar",
        ["knockback"] = "empuj",
        ["dispel"] = "disipar",
        ["shield"] = "escudo",
        ["physical"] = "físico",
        ["multi-target"] = "multiobjetivo",
        ["bleed"] = "sangrado",
        ["trauma"] = "trauma",
        ["poison"] = "veneno",
        ["disease"] = "enfermedad",
        ["mitigation"] = "mitigación",
        ["taunt"] = "provocar",
        ["pull"] = "atracción",
    },
    ["ru"] = {
        ["flame"] = "огненный",
        ["frost"] = "мороз",
        ["shock"] = "электричество",
        ["magic"] = "магический",
        ["heal"] = "исцеление",
        ["resources"] = "ресурс",
        ["ultimate"] = "суперспособности",
        ["stun"] = "оглушение",
        ["immobilize"] = "обездвиживание",
        ["knockback"] = "отбрасывание",
        ["dispel"] = "рассеивание",
        ["shield"] = "щит",
        ["physical"] = "физический",
        ["multi-target"] = "нескольким целям",
        ["bleed"] = "кровотечения",
        ["trauma"] = "рана",
        ["poison"] = "яд",
        ["disease"] = "болезнетворный",
        ["mitigation"] = "увеличение эффективности",
        ["taunt"] = "провоцирование",
        ["pull"] = "притяжение",
    },
}

--- Maps the given scriptName and defaultIcon to their corresponding custom icon.
--- @param scriptName string The name of the focus script based on which the custom icon will be applied.
--- @param defaultIcon string The path of the base game icon to be replaced with our own.
--- @return string? abilityIcon The path of the icon to be applied to the skill in question.
function MapScriptToIcon(scriptName, defaultIcon)
    local customIcons = AbilityIconsFramework.CUSTOM_ABILITY_ICONS[defaultIcon]
    if not customIcons then
        return nil
    end

    local currentLang = GetCVar("Language.2")
    scriptName = string.lower(scriptName)
    local translations = effectTranslations[currentLang] or effectTranslations["en"]

    for key, value in pairs(customIcons) do
        local translatedEffect = translations[key]
        if translatedEffect and string.find(scriptName, translatedEffect, 1, true) then
            return value
        end
    end

    return customIcons[AbilityIconsFramework.DEFAULT]
end

--- Calls RedirectTexture to replace an existing skill icon with a different one.
function AbilityIconsFramework.ReplaceMismatchedIcons()
    local doReplace = AbilityIconsFramework:GetSettings().replaceMismatchedBaseIcons

    for key, value in pairs(AbilityIconsFramework.BASE_GAME_ICONS_TO_REPLACE) do
        -- Never redirect the stagger stomp icon, and skip scribing icons here.
        if key ~= STAGGER_STOMP_BASE_ICON and AbilityIconsFramework.CUSTOM_ABILITY_ICONS[key] == nil then
            if doReplace then
                RedirectTexture(key, value)
            else
                RedirectTexture(key, key)
            end
        end
    end

    -- Safety: always restore it (even if something else attempted to redirect it earlier).
    RedirectTexture(STAGGER_STOMP_BASE_ICON, STAGGER_STOMP_BASE_ICON)
end

function AbilityIconsFramework.UpdateDefaultScribingIcons()
    local EffectsList = AbilityIconsFramework.GetEffectsList()
    if EffectsList == nil then return end

    for BaseIcon, IconDataList in pairs(AbilityIconsFramework.CUSTOM_ABILITY_ICONS) do
        local CustomDefaultIcon = IconDataList[EffectsList.DEFAULT]
        local CustomScribedIcon = nil

        if IsCraftedAbilityScribed(IconDataList[AbilityIconsFramework.SCRIBING_ID_KEY]) then
            local primaryScriptId = GetCraftedAbilityActiveScriptIds(IconDataList[AbilityIconsFramework.SCRIBING_ID_KEY])
            local scriptName = GetCraftedAbilityScriptDisplayName(primaryScriptId)
            CustomScribedIcon = MapScriptToIcon(scriptName, BaseIcon) or nil
        end

        if CustomScribedIcon ~= nil and AbilityIconsFramework:GetSettings().showCustomScribeIcons then
            RedirectTexture(BaseIcon, CustomScribedIcon)
        elseif CustomDefaultIcon ~= nil and AbilityIconsFramework:GetSettings().showCustomScribeIcons then
            RedirectTexture(BaseIcon, CustomDefaultIcon)
        else
            RedirectTexture(BaseIcon, BaseIcon)
        end
    end
end

-- Custom iteration function going over icon pack data in their load order.
local packSortFunc = function(t, a, b) return t[b].loadOrder < t[a].loadOrder end

function AbilityIconsFramework.packPairs()
    local settings = AbilityIconsFramework:GetSettings()

    local keys = {}
    for k, _ in pairs(settings.iconPacksData) do
        -- Iterate only over currently enabled icon packs
        if AbilityIconsFramework.ENABLED_ICON_PACKS[k] ~= nil then
            keys[#keys + 1] = k
        end
    end

    table.sort(keys, function(a, b) return packSortFunc(settings.iconPacksData, a, b) end)

    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], settings.iconPacksData[keys[i]]
        end
    end
end

function AbilityIconsFramework.ResetAllTextureRedirects()
    for key, _ in pairs(AbilityIconsFramework.BASE_GAME_ICONS_TO_REPLACE) do
        RedirectTexture(key, key)
    end

    -- Extra safety
    RedirectTexture(STAGGER_STOMP_BASE_ICON, STAGGER_STOMP_BASE_ICON)
end
