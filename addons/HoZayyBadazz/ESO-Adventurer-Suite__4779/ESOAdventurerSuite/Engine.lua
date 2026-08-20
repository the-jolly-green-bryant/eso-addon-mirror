-- ESO Adventurer Suite
-- Copyright (c) 2026 HoZayyBadazz. All Rights Reserved.
-- Proprietary source. Unauthorized redistribution, republication, rebranding,
-- or public distribution of modified/derivative versions is prohibited.
-- Private personal-use modifications are permitted. See LICENSE.txt.

local EPC = ESOProgressionCoach
EPC.Engine = EPC.Engine or {}
local E = EPC.Engine

local function push(t, item)
    t[#t + 1] = item
end

local function addUnique(items, seen, text)
    if not text or text == "" or seen[text] or #items >= 3 then return end
    seen[text] = true
    items[#items + 1] = text
end

local function categoryRecommendations(recommendations, category)
    local result = {}
    for i = 1, #recommendations do
        local recommendation = recommendations[i]
        if recommendation.category == category then
            result[#result + 1] = recommendation
        end
    end
    return result
end

local function formatNumber(value)
    local number = math.floor(tonumber(value) or 0)
    local sign = number < 0 and "-" or ""
    local digits = tostring(math.abs(number))
    local parts = {}

    while #digits > 3 do
        table.insert(parts, 1, string.sub(digits, -3))
        digits = string.sub(digits, 1, -4)
    end
    table.insert(parts, 1, digits)
    return sign .. table.concat(parts, ",")
end

function E:GetUnitResource(powerType)
    local current, maximum = EPC:Safe(GetUnitPower, 0, "player", powerType)
    return tonumber(current) or 0, tonumber(maximum) or 0
end

function E:DetectRole()
    local _, magickaMaximum = self:GetUnitResource(POWERTYPE_MAGICKA)
    local _, staminaMaximum = self:GetUnitResource(POWERTYPE_STAMINA)
    if magickaMaximum >= staminaMaximum then return "MAGICKA" end
    return "STAMINA"
end

function E:GetEquippedSummary()
    local summary = {
        light = 0,
        medium = 0,
        heavy = 0,
        armorCount = 0,
        weaponCount = 0,
        equippedCount = 0,
        weapons = {},
        qualityTotal = 0,
        qualityCount = 0,
        averageQuality = 0,
        goldQualityCount = 0,
        enchantedCount = 0,
        traitCount = 0,
        traitCounts = {},
        sets = {},
        setOrder = {},
        completeSetCount = 0,
    }

    local slots = {}
    local function addSlot(slot)
        if slot ~= nil then slots[#slots + 1] = slot end
    end

    addSlot(EQUIP_SLOT_HEAD)
    addSlot(EQUIP_SLOT_CHEST)
    addSlot(EQUIP_SLOT_SHOULDERS)
    addSlot(EQUIP_SLOT_HAND)
    addSlot(EQUIP_SLOT_WAIST)
    addSlot(EQUIP_SLOT_LEGS)
    addSlot(EQUIP_SLOT_FEET)
    addSlot(EQUIP_SLOT_NECK)
    addSlot(EQUIP_SLOT_RING1)
    addSlot(EQUIP_SLOT_RING2)
    addSlot(EQUIP_SLOT_MAIN_HAND)
    addSlot(EQUIP_SLOT_OFF_HAND)
    addSlot(EQUIP_SLOT_BACKUP_MAIN)
    addSlot(EQUIP_SLOT_BACKUP_OFF)

    local qualityFunction = GetItemLinkDisplayQuality or GetItemLinkQuality
    local normalQuality = ITEM_DISPLAY_QUALITY_NORMAL or 1
    local legendaryQuality = ITEM_DISPLAY_QUALITY_LEGENDARY or ITEM_QUALITY_LEGENDARY or 5

    for i = 1, #slots do
        local slot = slots[i]
        local link = EPC:Safe(GetItemLink, "", BAG_WORN, slot, LINK_STYLE_DEFAULT)
        if link and link ~= "" then
            summary.equippedCount = summary.equippedCount + 1

            local armorType = EPC:Safe(GetItemLinkArmorType, ARMORTYPE_NONE, link)
            if armorType == ARMORTYPE_LIGHT then
                summary.light = summary.light + 1
                summary.armorCount = summary.armorCount + 1
            elseif armorType == ARMORTYPE_MEDIUM then
                summary.medium = summary.medium + 1
                summary.armorCount = summary.armorCount + 1
            elseif armorType == ARMORTYPE_HEAVY then
                summary.heavy = summary.heavy + 1
                summary.armorCount = summary.armorCount + 1
            end

            local weaponType = EPC:Safe(GetItemLinkWeaponType, WEAPONTYPE_NONE, link)
            if weaponType and weaponType ~= WEAPONTYPE_NONE then
                summary.weaponCount = summary.weaponCount + 1
                summary.weapons[weaponType] = (summary.weapons[weaponType] or 0) + 1
            end

            local quality = tonumber(EPC:Safe(qualityFunction, normalQuality, link)) or normalQuality
            summary.qualityTotal = summary.qualityTotal + quality
            summary.qualityCount = summary.qualityCount + 1
            if quality >= legendaryQuality then summary.goldQualityCount = summary.goldQualityCount + 1 end

            if type(GetItemLinkTraitInfo) == "function" then
                local traitType = EPC:Safe(GetItemLinkTraitInfo, ITEM_TRAIT_TYPE_NONE or 0, link)
                if traitType and traitType ~= (ITEM_TRAIT_TYPE_NONE or 0) then
                    local traitName = EPC:Safe(GetString, "", "SI_ITEMTRAITTYPE", traitType)
                    if not traitName or traitName == "" then traitName = "Trait " .. tostring(traitType) end
                    summary.traitCount = summary.traitCount + 1
                    summary.traitCounts[traitName] = (summary.traitCounts[traitName] or 0) + 1
                end
            end

            if type(GetItemLinkFinalEnchantId) == "function" then
                local enchantId = tonumber(EPC:Safe(GetItemLinkFinalEnchantId, 0, link)) or 0
                if enchantId > 0 then summary.enchantedCount = summary.enchantedCount + 1 end
            end

            if type(GetItemLinkSetInfo) == "function" then
                local hasSet, setName, numBonuses, numNormalEquipped, maxEquipped, setId, numPerfectedEquipped = EPC:Safe(
                    GetItemLinkSetInfo, false, link, true
                )
                if hasSet and setName and setName ~= "" then
                    local key = tonumber(setId) or setName
                    if not summary.sets[key] then
                        summary.sets[key] = {
                            id = tonumber(setId) or 0,
                            name = setName,
                            equipped = tonumber(numNormalEquipped) or 0,
                            perfectedEquipped = tonumber(numPerfectedEquipped) or 0,
                            maxEquipped = tonumber(maxEquipped) or 0,
                            numBonuses = tonumber(numBonuses) or 0,
                        }
                        summary.setOrder[#summary.setOrder + 1] = key
                    end
                end
            end
        end
    end

    if summary.qualityCount > 0 then summary.averageQuality = summary.qualityTotal / summary.qualityCount end

    table.sort(summary.setOrder, function(a, b)
        local sa, sb = summary.sets[a], summary.sets[b]
        local ea = (sa and (sa.equipped + sa.perfectedEquipped)) or 0
        local eb = (sb and (sb.equipped + sb.perfectedEquipped)) or 0
        if ea ~= eb then return ea > eb end
        return tostring(sa and sa.name or "") < tostring(sb and sb.name or "")
    end)

    for i = 1, #summary.setOrder do
        local set = summary.sets[summary.setOrder[i]]
        local equipped = set.equipped + set.perfectedEquipped
        -- Most full combat sets unlock their defining bonus by 5 pieces; smaller sets
        -- such as monster/arena sets use a lower max equipped count. This is only a
        -- completeness signal, not a claim that the set is optimal for the build.
        local target = set.maxEquipped > 0 and math.min(5, set.maxEquipped) or 5
        if equipped >= target then summary.completeSetCount = summary.completeSetCount + 1 end
    end

    return summary
end

function E:GetWeaponSummary(weapons)
    local labels = {}

    for weaponType, count in pairs(weapons or {}) do
        local label = EPC:Safe(GetString, "", "SI_WEAPONTYPE", weaponType)
        if not label or label == "" then
            label = EPC.Data.weaponNames and EPC.Data.weaponNames[weaponType] or nil
        end
        if not label or label == "" then
            label = string.format("Weapon type %d", tonumber(weaponType) or 0)
        end
        if count > 1 then
            label = string.format("%s x%d", label, count)
        end
        labels[#labels + 1] = label
    end

    table.sort(labels)
    if #labels == 0 then return "None detected" end
    return table.concat(labels, ", ")
end

function E:BuildSnapshot()
    local level = tonumber(EPC:Safe(GetUnitLevel, 1, "player")) or 1
    local championPoints = tonumber(EPC:Safe(GetPlayerChampionPointsEarned, 0)) or 0
    local classId = tonumber(EPC:Safe(GetUnitClassId, 0, "player")) or 0
    local raceId = tonumber(EPC:Safe(GetUnitRaceId, 0, "player")) or 0
    local skillPoints = tonumber(EPC:Safe(GetAvailableSkillPoints, 0)) or 0
    local role = self:DetectRole()
    local magicka, magickaMaximum = self:GetUnitResource(POWERTYPE_MAGICKA)
    local stamina, staminaMaximum = self:GetUnitResource(POWERTYPE_STAMINA)
    local health, healthMaximum = self:GetUnitResource(POWERTYPE_HEALTH)
    local characterName = EPC:Safe(GetUnitName, "", "player")
    local zoneName = EPC:Safe(GetUnitZone, "", "player")
    local activeWeaponPair = EPC:Safe(GetActiveWeaponPairInfo, ACTIVE_WEAPON_PAIR_NONE)
    local activeWeaponBarLabel = "Unavailable"

    if activeWeaponPair == ACTIVE_WEAPON_PAIR_MAIN then
        activeWeaponBarLabel = "Front (main)"
    elseif activeWeaponPair == ACTIVE_WEAPON_PAIR_BACKUP then
        activeWeaponBarLabel = "Back (backup)"
    end

    if not characterName or characterName == "" then
        characterName = "Player"
    end

    if not zoneName or zoneName == "" then
        zoneName = "Unknown zone"
    end

    local derivedStats = EPC.Endgame and EPC.Endgame.GetDerivedStats and EPC.Endgame:GetDerivedStats() or {}

    return {
        characterName = characterName,
        level = level,
        championPoints = championPoints,
        classId = classId,
        className = EPC.Data.classNames[classId] or "Adventurer",
        raceId = raceId,
        raceName = EPC.Data.raceNames[raceId] or "Unknown Race",
        role = role,
        resourceRole = role,
        combatRole = EPC.Role and EPC.Role:GetRole() or "DAMAGE",
        roleLabel = EPC.Role and EPC.Role:GetDisplayLabel(role) or EPC.Data.roleProfiles[role].label,
        skillPoints = skillPoints,
        magicka = magicka,
        magickaMax = magickaMaximum,
        stamina = stamina,
        staminaMax = staminaMaximum,
        health = health,
        healthMax = healthMaximum,
        zoneName = zoneName,
        activeWeaponPair = activeWeaponPair,
        activeWeaponBarLabel = activeWeaponBarLabel,
        gear = self:GetEquippedSummary(),
        derivedStats = derivedStats,
    }
end

function E:ComputeGearScore(snapshot)
    local score = 45
    local combatRole = snapshot.combatRole or (EPC.Role and EPC.Role:GetRole()) or "DAMAGE"
    local profile = EPC.Data.roleProfiles[snapshot.role]
    local armorCount = 0
    local preferredWeaponFound = false

    if combatRole == "TANK" then
        armorCount = snapshot.gear.heavy or 0
        for weaponType in pairs(snapshot.gear.weapons or {}) do
            if (WEAPONTYPE_FROST_STAFF ~= nil and weaponType == WEAPONTYPE_FROST_STAFF)
                or (WEAPONTYPE_SHIELD ~= nil and weaponType == WEAPONTYPE_SHIELD)
                or (WEAPONTYPE_ONE_HANDED_SWORD ~= nil and weaponType == WEAPONTYPE_ONE_HANDED_SWORD)
                or (WEAPONTYPE_ONE_HANDED_AXE ~= nil and weaponType == WEAPONTYPE_ONE_HANDED_AXE)
                or (WEAPONTYPE_ONE_HANDED_HAMMER ~= nil and weaponType == WEAPONTYPE_ONE_HANDED_HAMMER) then
                preferredWeaponFound = true
                break
            end
        end
    elseif combatRole == "HEALER" then
        armorCount = snapshot.gear.light or 0
        for weaponType in pairs(snapshot.gear.weapons or {}) do
            if WEAPONTYPE_HEALING_STAFF ~= nil and weaponType == WEAPONTYPE_HEALING_STAFF then
                preferredWeaponFound = true
                break
            end
        end
    else
        armorCount = (profile.preferredArmor == ARMORTYPE_LIGHT and snapshot.gear.light)
            or (profile.preferredArmor == ARMORTYPE_MEDIUM and snapshot.gear.medium)
            or snapshot.gear.heavy
        for weaponType in pairs(snapshot.gear.weapons) do
            if profile.preferredWeaponTypes[weaponType] then preferredWeaponFound = true break end
        end
    end

    score = score + math.min(28, armorCount * 4)
    if preferredWeaponFound then score = score + 18 end

    if snapshot.gear.qualityCount > 0 then
        local averageQuality = snapshot.gear.qualityTotal / snapshot.gear.qualityCount
        score = score + math.min(9, math.floor(averageQuality * 2))
    end

    if snapshot.level >= 50 then
        local completeSets = tonumber(snapshot.gear.completeSetCount) or 0
        if completeSets > 0 then score = score + math.min(12, completeSets * 6) else score = score - 8 end
        local enchanted = tonumber(snapshot.gear.enchantedCount) or 0
        if enchanted >= 10 then score = score + 4 end
    end

    return EPC:Clamp(math.floor(score), 0, 100)
end

function E:ComputeBuildScore(snapshot, gearScore)
    local score = 50
    local combatRole = snapshot.combatRole or "DAMAGE"
    if combatRole == "DAMAGE" then
        if snapshot.classId == 2 and snapshot.role == "MAGICKA" then score = score + 14 end
        if snapshot.raceId == 1 and snapshot.role == "MAGICKA" then score = score + 7 end
    elseif combatRole == "HEALER" then
        if snapshot.magickaMax >= snapshot.staminaMax then score = score + 12 end
        if snapshot.healthMax >= 18000 then score = score + 5 end
    elseif combatRole == "TANK" then
        if snapshot.healthMax >= 25000 then score = score + 14 elseif snapshot.healthMax >= 20000 then score = score + 8 end
        if (snapshot.gear.heavy or 0) >= 5 then score = score + 7 end
    end
    local skillPointReadiness = math.max(0, 8 - math.min(8, snapshot.skillPoints * 2))
    score = score + skillPointReadiness
    score = score + math.floor((gearScore - 50) * 0.32)
    return EPC:Clamp(score, 0, 100)
end

function E:GenerateRecommendations(snapshot, gearScore, buildScore)
    local recommendations = {}
    local profile = EPC.Data.roleProfiles[snapshot.role]
    local endgame = snapshot.level >= 50

    if snapshot.skillPoints > 0 then
        push(recommendations, {
            priority = 100,
            title = string.format("Spend %d available skill point%s", snapshot.skillPoints, snapshot.skillPoints == 1 and "" or "s"),
            category = "SKILLS",
            reason = "Unspent skill points are immediate progression. Prioritize active skills you use, then passives that multiply your primary build.",
        })
    end

    local combatRole = snapshot.combatRole or "DAMAGE"
    if combatRole == "TANK" then
        if snapshot.gear.heavy < 5 then
            push(recommendations, { priority = 90, title = "Review your tank armor mix", category = "GEAR", reason = string.format("You currently have %d Heavy Armor pieces. Tank setups commonly lean on Heavy Armor and defensive passives, but the exact mix depends on encounter and build.", snapshot.gear.heavy) })
        end
    elseif combatRole == "HEALER" then
        if snapshot.gear.light < 5 then
            push(recommendations, { priority = 88, title = "Review your healer armor mix", category = "GEAR", reason = string.format("You currently have %d Light Armor pieces. Many Magicka healer setups use Light Armor for sustain and spell support, though exact builds vary.", snapshot.gear.light) })
        end
    elseif snapshot.role == "MAGICKA" and snapshot.gear.light < 5 then
        push(recommendations, { priority = 88, title = "Move toward 5 or more pieces of Light Armor", category = "GEAR", reason = string.format("You currently have %d Light Armor pieces equipped. Match armor weight to the passives and role you are actually using.", snapshot.gear.light) })
    elseif snapshot.role == "STAMINA" and snapshot.gear.medium < 5 then
        push(recommendations, { priority = 88, title = "Move toward 5 or more pieces of Medium Armor", category = "GEAR", reason = string.format("You currently have %d Medium Armor pieces equipped. Match armor weight to the passives and role you are actually using.", snapshot.gear.medium) })
    end

    local preferredWeaponFound = false
    for weaponType in pairs(snapshot.gear.weapons) do
        if combatRole == "HEALER" then
            preferredWeaponFound = preferredWeaponFound or (WEAPONTYPE_HEALING_STAFF ~= nil and weaponType == WEAPONTYPE_HEALING_STAFF)
        elseif combatRole == "TANK" then
            preferredWeaponFound = preferredWeaponFound or (WEAPONTYPE_FROST_STAFF ~= nil and weaponType == WEAPONTYPE_FROST_STAFF) or (WEAPONTYPE_SHIELD ~= nil and weaponType == WEAPONTYPE_SHIELD)
        elseif profile.preferredWeaponTypes[weaponType] then
            preferredWeaponFound = true
        end
        if preferredWeaponFound then break end
    end

    if not preferredWeaponFound then
        local weaponTitle = combatRole == "HEALER" and "Consider a Restoration Staff for group healing" or combatRole == "TANK" and "Review your tank weapon setup" or (snapshot.role == "MAGICKA" and "Equip and level a Destruction Staff" or "Equip a stamina-oriented weapon")
        push(recommendations, { priority = 84, title = weaponTitle, category = "GEAR", reason = endgame and "Your equipped weapon profile does not match the strongest signal for your selected combat role. Verify this is intentional for your build." or "Keeping the weapon skill line for your intended role advancing avoids progression bottlenecks later." })
    end

    if snapshot.classId == 2 then
        local tips = endgame and (EPC.Data.sorcererEndgameTips or {}) or EPC.Data.sorcererTips
        for i = 1, #tips do
            local tip = tips[i]
            local minLevel = tip.minLevel or 1
            local maxLevel = tip.maxLevel
            if snapshot.level >= minLevel and (not maxLevel or snapshot.level <= maxLevel) then
                push(recommendations, {
                    priority = endgame and tip.priority or (tip.priority - math.floor((snapshot.level - minLevel) * 0.25)),
                    title = tip.title,
                    category = tip.category or "BUILD",
                    reason = tip.reason,
                })
            end
        end
    else
        push(recommendations, {
            priority = 80,
            title = "Keep class abilities from key skill lines slotted",
            category = "BUILD",
            reason = endgame and "Keep the class tools that support your current role available and fully progressed." or "Leveling class skill lines while earning XP prevents progression bottlenecks later.",
        })
    end

    if snapshot.level >= 15 and snapshot.classId ~= 2 and not endgame then
        push(recommendations, {
            priority = 76,
            title = "Give the front and back weapon bars different jobs",
            category = "BUILD",
            reason = "A useful leveling pattern is a front bar for frequent direct damage and a back bar for buffs, damage-over-time, healing, or utility rather than duplicating every ability.",
        })
    end

    if gearScore < 65 then
        push(recommendations, {
            priority = 74,
            title = "Replace mismatched gear as it drops",
            category = "GEAR",
            reason = endgame and "Your current gear profile is below the coach target. Review complete set bonuses, traits, enchantments, weapon pairing, and armor weights." or "Your current gear profile is below the coach target. While leveling, correct armor and weapon progression matters more than chasing perfect set pieces.",
        })
    end

    table.sort(recommendations, function(a, b)
        return a.priority > b.priority
    end)

    return recommendations
end

function E:BuildTabViews(snapshot, gearScore, buildScore, recommendations, championSummary, preparationScores)
    local endgame = snapshot.level >= 50
    local buildRecommendations = categoryRecommendations(recommendations, "BUILD")
    local gearRecommendations = categoryRecommendations(recommendations, "GEAR")
    local skillRecommendations = categoryRecommendations(recommendations, "SKILLS")
    local weaponSummary = self:GetWeaponSummary(snapshot.gear.weapons)
    local averageQuality = snapshot.gear.averageQuality or (snapshot.gear.qualityCount > 0 and (snapshot.gear.qualityTotal / snapshot.gear.qualityCount) or 0)
    local cp = championSummary or { available = false, totalSlots = 0, slottedCount = 0, emptySlots = 0, slotted = {} }
    local focusAdvice = endgame and EPC.Endgame and EPC.Endgame:GetFocusAdvice(snapshot, gearScore, buildScore, cp, preparationScores) or nil
    local lastFight = EPC.Combat and EPC.Combat:GetDisplayFight() or nil
    local rolePriorities = EPC.Role and EPC.Role:GetRolePriorities(snapshot) or { build = {}, gear = {}, skills = {}, activity = {}, combat = {} }

    local buildTop = buildRecommendations[1]
    local buildItems, buildSeen = {}, {}
    for i = 1, math.min(1, #(rolePriorities.build or {})) do addUnique(buildItems, buildSeen, rolePriorities.build[i]) end
    if focusAdvice then
        for i = 1, #(focusAdvice.items or {}) do addUnique(buildItems, buildSeen, focusAdvice.items[i]) end
    else
        for i = 2, #buildRecommendations do addUnique(buildItems, buildSeen, buildRecommendations[i].title) end
        addUnique(buildItems, buildSeen, "Keep class abilities slotted from every skill line you want to advance")
        addUnique(buildItems, buildSeen, snapshot.role == "MAGICKA" and "Keep Magicka as your primary resource focus while leveling" or "Keep Stamina as your primary resource focus while leveling")
        addUnique(buildItems, buildSeen, snapshot.level >= 15 and "Give the front and back weapon bars different jobs" or "Your back weapon bar unlocks at level 15")
    end

    local gearTop = gearRecommendations[1]
    local gearItems, gearSeen = {}, {}
    for i = 1, math.min(2, #(rolePriorities.gear or {})) do addUnique(gearItems, gearSeen, rolePriorities.gear[i]) end
    if endgame then
        for i = 1, math.min(2, #(snapshot.gear.setOrder or {})) do
            local set = snapshot.gear.sets[snapshot.gear.setOrder[i]]
            if set then
                local equipped = (set.equipped or 0) + (set.perfectedEquipped or 0)
                local target = set.maxEquipped and set.maxEquipped > 0 and math.min(5, set.maxEquipped) or 5
                addUnique(gearItems, gearSeen, string.format("%s: %d / %d equipped", set.name, equipped, target))
            end
        end
        addUnique(gearItems, gearSeen, string.format("Traits detected on %d pieces; enchants detected on %d", snapshot.gear.traitCount or 0, snapshot.gear.enchantedCount or 0))
        addUnique(gearItems, gearSeen, "Review set bonuses, traits, enchants, weapon pairing, and quality together before upgrading")
    else
        for i = 2, #gearRecommendations do addUnique(gearItems, gearSeen, gearRecommendations[i].title) end
        addUnique(gearItems, gearSeen, snapshot.role == "MAGICKA" and "Keep at least five Light Armor pieces equipped while leveling" or "Keep at least five Medium Armor pieces equipped while leveling")
        addUnique(gearItems, gearSeen, snapshot.role == "MAGICKA" and "Keep a Destruction Staff progressing on one of your weapon bars" or "Keep a stamina weapon progressing on one of your weapon bars")
        addUnique(gearItems, gearSeen, "Replace leveling pieces when stronger useful drops become available")
    end

    local skillTop = skillRecommendations[1]
    local skillItems, skillSeen = {}, {}
    for i = 1, math.min(2, #(rolePriorities.skills or {})) do addUnique(skillItems, skillSeen, rolePriorities.skills[i]) end
    if endgame then
        if cp.emptySlots and cp.emptySlots > 0 then
            addUnique(skillItems, skillSeen, string.format("Fill %d empty Champion slottable slot%s", cp.emptySlots, cp.emptySlots == 1 and "" or "s"))
        end
        for i = 1, math.min(3, #(cp.slotted or {})) do
            local star = cp.slotted[i]
            addUnique(skillItems, skillSeen, string.format("CP: %s (%d points)", star.name or "Champion Skill", star.points or 0))
        end
        addUnique(skillItems, skillSeen, string.format("Review %s morphs and passives for your current focus", snapshot.className))
        addUnique(skillItems, skillSeen, "Champion advice is a slot audit; it will not spend or move Champion Points for you")
    else
        for i = 2, #skillRecommendations do addUnique(skillItems, skillSeen, skillRecommendations[i].title) end
        addUnique(skillItems, skillSeen, snapshot.level >= 15 and string.format("Slot a %s ability on both your front and back weapon bars", snapshot.className) or string.format("Keep a %s ability slotted on your current weapon bar", snapshot.className))
        addUnique(skillItems, skillSeen, snapshot.role == "MAGICKA" and "Review Destruction Staff and Light Armor passives as their lines advance" or "Review weapon and Medium Armor passives as their lines advance")
        addUnique(skillItems, skillSeen, "Prioritize morphs and passives tied to abilities you actually use")
    end

    local buildPrimaryResourceLabel = snapshot.role == "MAGICKA" and "MAX MAGICKA" or "MAX STAMINA"
    local buildPrimaryResourceValue = snapshot.role == "MAGICKA" and snapshot.magickaMax or snapshot.staminaMax
    local weaponBarStatus = snapshot.level >= 15 and "Front + back unlocked" or "Back unlocks at 15"
    local progressionValue = endgame and ("CP " .. tostring(snapshot.championPoints)) or ("Level " .. tostring(snapshot.level))
    local skillDescription = skillTop and skillTop.reason or "Your skill points are currently spent. Continue leveling the class, weapon, and armor lines that support the abilities you use."

    local buildView
    if endgame and focusAdvice then
        local cpSlotText = cp.totalSlots > 0 and string.format("%d / %d", cp.slottedCount or 0, cp.totalSlots) or "Unavailable"
        local lastDps = lastFight and formatNumber(lastFight.dps) or "No sample"
        buildView = {
            header = "ENDGAME COACH  /  " .. (focusAdvice.focusLabel or "FOCUS"),
            title = focusAdvice.title,
            description = focusAdvice.description,
            stats = {
                { label = "BUILD SCORE", value = string.format("%d / 100", buildScore) },
                { label = "GEAR SCORE", value = string.format("%d / 100", gearScore) },
                { label = "CP SLOTS", value = cpSlotText },
                { label = "LAST DPS", value = lastDps },
            },
            listHeader = "FOCUS PRIORITIES",
            items = buildItems,
            focus = focusAdvice.focus,
            focusLabel = focusAdvice.focusLabel,
        }
    else
        buildView = {
            header = "BUILD GUIDE",
            title = buildTop and buildTop.title or "Build profile looks balanced",
            description = buildTop and buildTop.reason or "No urgent build mismatch was detected. Keep your class, weapon, and primary resource progression moving together.",
            stats = {
                { label = "BUILD SCORE", value = string.format("%d / 100", buildScore) },
                { label = "ROLE", value = snapshot.roleLabel },
                { label = buildPrimaryResourceLabel, value = formatNumber(buildPrimaryResourceValue) },
                { label = "MAX HEALTH", value = formatNumber(snapshot.healthMax) },
            },
            listHeader = "BUILD PRIORITIES",
            items = buildItems,
        }
    end

    local gearDescription
    if endgame then
        gearDescription = string.format("%s role audit: %d complete equipped set bonus%s, %d trait-bearing pieces, and %d enchanted pieces. This is a structural signal, not a universal best-in-slot claim.", snapshot.roleLabel, snapshot.gear.completeSetCount or 0, (snapshot.gear.completeSetCount or 0) == 1 and "" or "es", snapshot.gear.traitCount or 0, snapshot.gear.enchantedCount or 0)
    else
        gearDescription = gearTop and gearTop.reason or string.format("Current armor mix: %d Light, %d Medium, and %d Heavy. No urgent armor or weapon mismatch was detected.", snapshot.gear.light, snapshot.gear.medium, snapshot.gear.heavy)
    end

    local combatView
    local combatRole = snapshot.combatRole or "DAMAGE"
    local combatRoleLabel = snapshot.roleLabel or "Damage"
    if lastFight then
        local combatItems = {}
        local contributors = lastFight.contributors or {}
        if #contributors > 1 then
            local damageLeader = contributors[1]
            local healingLeader = nil
            for i = 1, #contributors do
                local entry = contributors[i]
                if not healingLeader or (entry.healing or 0) > (healingLeader.healing or 0) then healingLeader = entry end
            end
            local selfEntry = nil
            for i = 1, #contributors do if contributors[i].isSelf then selfEntry = contributors[i] break end end
            if combatRole == "HEALER" then
                if healingLeader and (healingLeader.healing or 0) > 0 then
                    combatItems[#combatItems + 1] = string.format("Healing leader: %s - %s observed HPS", healingLeader.name or "Unknown", formatNumber(healingLeader.hps or 0))
                end
                combatItems[#combatItems + 1] = string.format("Damage leader: %s - %s observed DPS", damageLeader.name or "Unknown", formatNumber(damageLeader.dps or 0))
            else
                combatItems[#combatItems + 1] = string.format("Damage leader: %s - %s observed DPS", damageLeader.name or "Unknown", formatNumber(damageLeader.dps or 0))
                if healingLeader and (healingLeader.healing or 0) > 0 then combatItems[#combatItems + 1] = string.format("Healing leader: %s - %s observed HPS", healingLeader.name or "Unknown", formatNumber(healingLeader.hps or 0)) end
            end
            if selfEntry then
                combatItems[#combatItems + 1] = string.format("You: %s DPS / %s HPS / %.1f%% crit", formatNumber(selfEntry.dps or 0), formatNumber(selfEntry.hps or 0), selfEntry.critPercent or 0)
            end
        else
            for i = 1, math.min(3, #(rolePriorities.combat or {})) do combatItems[#combatItems + 1] = rolePriorities.combat[i] end
            if combatRole == "DAMAGE" then
                for i = 1, math.min(3 - #combatItems, #(lastFight.abilities or {})) do
                    local ability = lastFight.abilities[i]
                    local pct = lastFight.totalDamage > 0 and ((ability.damage or 0) / lastFight.totalDamage * 100) or 0
                    combatItems[#combatItems + 1] = string.format("%s: %s damage (%.1f%%)", ability.name or "Unknown", formatNumber(ability.damage or 0), pct)
                end
            end
        end

        local groupNote = #contributors > 1 and " Group/raid rankings use only combat events ESO exposes to this client, so they are observed estimates rather than an authoritative full-raid parse." or ""
        local personalBest = EPC.Combat and EPC.Combat:GetPersonalBest(combatRole) or 0
        if personalBest and personalBest > 0 and #combatItems < 3 then
            if combatRole == "HEALER" then
                combatItems[#combatItems + 1] = "Personal best: " .. formatNumber(personalBest) .. " HPS"
            elseif combatRole == "TANK" then
                combatItems[#combatItems + 1] = string.format("Personal best blocked-hit rate: %.1f%%", personalBest)
            else
                combatItems[#combatItems + 1] = "Personal best: " .. formatNumber(personalBest) .. " DPS"
            end
        end
        local stats
        local title
        if combatRole == "HEALER" then
            title = string.format(lastFight.live and "Live healer: %s HPS" or "Last fight: %s HPS", formatNumber(lastFight.hps or 0))
            stats = {
                { label = "HPS", value = formatNumber(lastFight.hps or 0) },
                { label = "TOTAL HEAL", value = formatNumber(lastFight.totalHealing or 0) },
                { label = "CRIT HEALS", value = string.format("%.1f%%", lastFight.criticalHealPercent or 0) },
                { label = "DPS", value = formatNumber(lastFight.dps or 0) },
            }
        elseif combatRole == "TANK" then
            title = string.format(lastFight.live and "Live tank: %s damage taken/s" or "Last fight: %s damage taken/s", formatNumber(lastFight.dtps or 0))
            stats = {
                { label = "DTPS", value = formatNumber(lastFight.dtps or 0) },
                { label = "DAMAGE TAKEN", value = formatNumber(lastFight.incomingDamage or 0) },
                { label = "BLOCKED HITS", value = string.format("%.1f%%", lastFight.blockPercent or 0) },
                { label = "HPS", value = formatNumber(lastFight.hps or 0) },
            }
        else
            title = string.format(lastFight.live and "Live DPS: %s" or "Last fight: %s DPS", formatNumber(lastFight.dps or 0))
            stats = {
                { label = "DPS", value = formatNumber(lastFight.dps or 0) },
                { label = "TOTAL DAMAGE", value = formatNumber(lastFight.totalDamage or 0) },
                { label = "CRIT EVENTS", value = string.format("%.1f%%", lastFight.criticalEventPercent or 0) },
                { label = "HPS", value = formatNumber(lastFight.hps or 0) },
            }
        end
        combatView = {
            header = "COMBAT ANALYSIS  /  " .. string.upper(combatRoleLabel),
            title = title,
            description = string.format((lastFight.live and "Live sample: " or "Completed sample: ") .. "role-aware combat metrics over %.1f seconds.%s", lastFight.duration or 0, groupNote),
            stats = stats,
            listHeader = #contributors > 1 and "OBSERVED GROUP / RAID" or "ROLE PRIORITIES",
            items = combatItems,
        }
    else
        combatView = {
            header = "COMBAT ANALYSIS  /  " .. string.upper(combatRoleLabel),
            title = "Complete a fight to create a role-aware combat sample",
            description = "The coach changes its combat metrics for Damage, Healer, or Tank. Auto mode follows your ESO preferred Group Finder role when available. It never automates combat.",
            stats = {
                { label = combatRole == "HEALER" and "HPS" or combatRole == "TANK" and "DTPS" or "DPS", value = "No sample" },
                { label = combatRole == "HEALER" and "TOTAL HEAL" or combatRole == "TANK" and "DAMAGE TAKEN" or "TOTAL DAMAGE", value = "-" },
                { label = combatRole == "HEALER" and "CRIT HEALS" or combatRole == "TANK" and "BLOCKED HITS" or "CRIT EVENTS", value = "-" },
                { label = combatRole == "TANK" and "HPS" or "SECONDARY", value = "-" },
            },
            listHeader = "ROLE PRIORITIES",
            items = rolePriorities.combat or {},
        }
    end

    return {
        BUILD = buildView,
        GEAR = {
            header = endgame and "ADVANCED GEAR AUDIT" or "GEAR GUIDE",
            title = gearTop and gearTop.title or (endgame and string.format("%d complete set bonus%s detected", snapshot.gear.completeSetCount or 0, (snapshot.gear.completeSetCount or 0) == 1 and "" or "es") or "Gear profile matches your detected role"),
            description = gearDescription,
            stats = {
                { label = "GEAR SCORE", value = string.format("%d / 100", gearScore) },
                { label = endgame and "COMPLETE SETS" or "ARMOR MIX", value = endgame and tostring(snapshot.gear.completeSetCount or 0) or string.format("%dL / %dM / %dH", snapshot.gear.light, snapshot.gear.medium, snapshot.gear.heavy) },
                { label = endgame and "ENCHANTED" or "WEAPONS", value = endgame and string.format("%d / %d", snapshot.gear.enchantedCount or 0, snapshot.gear.equippedCount or 0) or weaponSummary },
                { label = "AVG QUALITY", value = string.format("%.1f across %d", averageQuality, snapshot.gear.qualityCount) },
            },
            listHeader = endgame and "SET / TRAIT / ENCHANT SIGNALS" or "GEAR PRIORITIES",
            items = gearItems,
        },
        SKILLS = {
            header = endgame and "SKILLS & CHAMPION" or "SKILL GUIDE",
            title = endgame and (cp.emptySlots and cp.emptySlots > 0 and string.format("%d Champion slottable slot%s empty", cp.emptySlots, cp.emptySlots == 1 and " is" or "s are") or "Champion slottable bar detected") or (skillTop and skillTop.title or "No unspent skill points"),
            description = endgame and "Champion Point analysis reads your currently slotted Champion skills and spent points. It recommends review targets but never spends, unslots, or changes Champion Points." or skillDescription,
            stats = {
                { label = "SKILL POINTS", value = tostring(snapshot.skillPoints) },
                { label = endgame and "CHAMPION POINTS" or "ACTIVE BAR", value = endgame and tostring(snapshot.championPoints) or snapshot.activeWeaponBarLabel },
                { label = endgame and "CP SLOTTABLES" or "WEAPON BARS", value = endgame and (cp.totalSlots > 0 and string.format("%d / %d", cp.slottedCount or 0, cp.totalSlots) or "Unavailable") or weaponBarStatus },
                { label = endgame and "ACTIVE BAR" or "LEVEL", value = endgame and snapshot.activeWeaponBarLabel or progressionValue },
            },
            listHeader = endgame and "CHAMPION & SKILL PRIORITIES" or "SKILL PRIORITIES",
            items = skillItems,
        },
        COMBAT = combatView,
        ACTIVITY = {
            header = endgame and ("ENDGAME ACTIVITY  /  " .. string.upper(snapshot.roleLabel)) or "LEVELING PROFIT & XP",
            title = "Scanning current activities",
            description = endgame and ("Activity ranking keeps your selected XP/gold goal, while role awareness adds context for " .. snapshot.roleLabel .. " progression and group practice.") or "The planner ranks visible quests and repeatable activities for XP, gold, or a balanced route.",
            stats = {
                { label = "MODE", value = endgame and "ENDGAME" or "LEVELING" },
                { label = "GOAL", value = "BALANCED" },
                { label = "QUESTS SCANNED", value = "Loading" },
                { label = "STATUS", value = "Ready" },
            },
            listHeader = "BEST ACTIVITIES",
            items = {},
        },
        MAP = {
            header = "MAP AND TRAVEL",
            title = "Travel from " .. snapshot.zoneName,
            description = "Choose a discovered wayshrine or an online friend, guild member, or group member. Select a destination, then press TRAVEL.",
            stats = {
                { label = "TRAVEL MODE", value = "Wayshrines" },
                { label = "AVAILABLE", value = "Loading" },
                { label = "SELECTED", value = "Choose below" },
                { label = "STATUS", value = "Select a destination" },
            },
            listHeader = "TRAVEL DESTINATIONS",
            items = {},
        },
        TOOLS = {
            header = "UTILITY COMMAND CENTER",
            title = "Inventory, research, collections, and daily value",
            description = "Open TOOLS to scan the current character and surface account snapshots, crafting research, zone completion, Sticker Book progress, and daily routines.",
            stats = {
                { label = "STATUS", value = "READY" },
                { label = "MODE", value = "OVERVIEW" },
                { label = "SAFETY", value = "ADVISORY" },
                { label = "AUTOMATION", value = "NONE" },
            },
            listHeader = "UTILITY PRIORITIES",
            items = {
                "Inventory intelligence and cross-character saved snapshots",
                "Trait research, target-set collection, and zone completion",
                "Daily / weekly routines connected to ACTIVITY planning",
            },
        },
    }
end

function E:Evaluate(snapshot)
    local championSummary = EPC.Endgame and EPC.Endgame:GetChampionSummary(snapshot) or { available = false, totalSlots = 0, slottedCount = 0, emptySlots = 0, slotted = {} }
    snapshot.champion = championSummary

    local gearScore = self:ComputeGearScore(snapshot)
    local buildScore = self:ComputeBuildScore(snapshot, gearScore)
    if snapshot.level >= 50 and championSummary.totalSlots > 0 then
        local coverage = championSummary.slottedCount / championSummary.totalSlots
        buildScore = EPC:Clamp(math.floor(buildScore + (coverage * 8)), 0, 100)
    end

    local recommendations = self:GenerateRecommendations(snapshot, gearScore, buildScore)
    local preparationScores = EPC.Endgame and EPC.Endgame:ComputePreparationScores(snapshot, gearScore, buildScore, championSummary) or {}

    local model = {
        snapshot = snapshot,
        gearScore = gearScore,
        buildScore = buildScore,
        champion = championSummary,
        preparationScores = preparationScores,
        recommendations = recommendations,
        tabs = self:BuildTabViews(snapshot, gearScore, buildScore, recommendations, championSummary, preparationScores),
    }
    if EPC.TargetBuild then
        model.targetBuild = EPC.TargetBuild:Evaluate(snapshot, model)
    end
    if EPC.Advisor and EPC.saved and EPC.saved.smartCoach ~= false then
        local move = EPC.Advisor:GetNextBestMove(model)
        model.nextBestMove = move
        if move and model.tabs and model.tabs.BUILD then
            local build = model.tabs.BUILD
            build.header = "NEXT BEST MOVE  /  " .. string.upper(move.focusLabel or "GUIDE")
            build.title = move.title or build.title
            build.description = move.reason or build.description
            build.stats[4] = { label = "SMART FOCUS", value = move.focusLabel or "GUIDE" }
            build.listHeader = "WHY THIS IS NEXT"
            local prior = build.items or {}
            build.items = {
                "Value: " .. tostring(move.value or "PROGRESSION") .. " — chosen from your build, role, activity, and progression context",
                prior[1] or "Review the highest-impact recommendation before spending resources",
                prior[2] or "Use the matching tab for deeper details",
            }
        end
    end
    if model.targetBuild and model.tabs and model.tabs.BUILD then
        local tb = model.targetBuild
        local build = model.tabs.BUILD
        build.stats[3] = { label = "TARGET BUILD", value = string.format("%d%% %s", tb.score or 0, tb.status or "") }
        local prior = build.items or {}
        local targetItems = {}
        targetItems[#targetItems + 1] = string.format("Target profile: %s — completion %d%%", tb.profileLabel or "AUTO", tb.score or 0)
        if tb.nextGap then targetItems[#targetItems + 1] = "Next target gap: " .. tb.nextGap end
        if #tb.targetSets > 0 then targetItems[#targetItems + 1] = "Target sets: " .. table.concat(tb.targetSets, " + ") end
        for i=1,#prior do
            if #targetItems >= 4 then break end
            targetItems[#targetItems + 1] = prior[i]
        end
        build.items = targetItems
        build.listHeader = "TARGET BUILD ROADMAP"
    end
    return model
end

