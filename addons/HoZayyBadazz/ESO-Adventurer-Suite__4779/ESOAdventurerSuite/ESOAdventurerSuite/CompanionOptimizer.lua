-- ESO Adventurer Suite
-- Active companion ability / ultimate optimizer
local EPC = ESOProgressionCoach
EPC.CompanionOptimizer = EPC.CompanionOptimizer or {}
local C = EPC.CompanionOptimizer

local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a, b, c, d, e, f, g, h = pcall(fn, ...)
    if not ok then return fallback end
    return a, b, c, d, e, f, g, h
end

local function safeNumber(fn, fallback, ...)
    local value = safe(fn, fallback, ...)
    local n = tonumber(value)
    if n ~= nil then return n end
    return tonumber(fallback) or 0
end

local function lower(text)
    return string.lower(tostring(text or ""))
end

local function containsAny(text, words)
    local haystack = lower(text)
    for _, word in ipairs(words or {}) do
        if string.find(haystack, lower(word), 1, true) then return true end
    end
    return false
end

local function cleanName(text)
    text = tostring(text or "")

    -- ESO can return localized names with grammar metadata appended to the raw
    -- string. Format the name through ESO first when available, then keep a
    -- fallback scrub so raw grammar suffixes never leak into Suite labels.
    if text ~= "" and type(zo_strformat) == "function" then
        local ok, formatted = pcall(zo_strformat, "<<1>>", text)
        if ok and type(formatted) == "string" and formatted ~= "" then
            text = formatted
        end
    end

    text = string.gsub(text, "|c%x%x%x%x%x%x", "")
    text = string.gsub(text, "|r", "")
    text = string.gsub(text, "%^[%a%d_]+$", "")
    text = string.gsub(text, "^%s+", "")
    text = string.gsub(text, "%s+$", "")
    return text
end

local BODY_SLOTS = {
    EQUIP_SLOT_HEAD,
    EQUIP_SLOT_CHEST,
    EQUIP_SLOT_SHOULDERS,
    EQUIP_SLOT_HAND,
    EQUIP_SLOT_WAIST,
    EQUIP_SLOT_LEGS,
    EQUIP_SLOT_FEET,
}

function C:GetActiveCompanionInfo()
    local defId = safeNumber(GetActiveCompanionDefId, 0)
    local hasActive = safe(HasActiveCompanion, defId > 0) == true
    local unitExists = type(DoesUnitExist) == "function" and safe(DoesUnitExist, false, "companion") == true
    if defId <= 0 and not hasActive and not unitExists then return nil end

    local name = ""
    if defId > 0 and type(GetCompanionName) == "function" then
        name = cleanName(safe(GetCompanionName, "", defId))
    end
    if name == "" and unitExists and type(GetUnitName) == "function" then
        name = cleanName(safe(GetUnitName, "", "companion"))
    end
    if name == "" then name = "Companion" end

    local level = safeNumber(GetActiveCompanionLevelInfo, 0)
    local slots = 5
    if level > 0 and type(GetCompanionNumSlotsUnlockedForLevel) == "function" then
        local unlocked = safeNumber(GetCompanionNumSlotsUnlockedForLevel, 0, level)
        if unlocked > 0 then slots = math.max(1, math.min(5, unlocked)) end
    end

    return {
        defId = defId,
        name = name,
        level = level,
        slots = slots,
    }
end

function C:GetCompanionEquipmentContext()
    local mainType = 0
    local offType = 0
    if BAG_COMPANION_WORN ~= nil and type(GetItemWeaponType) == "function" then
        mainType = safeNumber(GetItemWeaponType, WEAPONTYPE_NONE or 0, BAG_COMPANION_WORN, EQUIP_SLOT_MAIN_HAND)
        offType = safeNumber(GetItemWeaponType, WEAPONTYPE_NONE or 0, BAG_COMPANION_WORN, EQUIP_SLOT_OFF_HAND)
    end

    local armor = { light = 0, medium = 0, heavy = 0 }
    if BAG_COMPANION_WORN ~= nil and type(GetItemArmorType) == "function" then
        for _, slot in ipairs(BODY_SLOTS) do
            local armorType = safeNumber(GetItemArmorType, ARMORTYPE_NONE or 0, BAG_COMPANION_WORN, slot)
            if armorType == (ARMORTYPE_LIGHT or -1) then
                armor.light = armor.light + 1
            elseif armorType == (ARMORTYPE_MEDIUM or -2) then
                armor.medium = armor.medium + 1
            elseif armorType == (ARMORTYPE_HEAVY or -3) then
                armor.heavy = armor.heavy + 1
            end
        end
    end

    local isShield = offType == (WEAPONTYPE_SHIELD or -9001)
    local oneHandShield = mainType == (WEAPONTYPE_ONE_HAND_AND_SHIELD or -9002) or isShield
    local healingStaff = mainType == (WEAPONTYPE_HEALING_STAFF or -9003)

    local role = "DAMAGE"
    if oneHandShield then
        role = "TANK"
    elseif healingStaff then
        role = "HEALER"
    elseif armor.heavy >= 5 and armor.heavy > armor.medium and armor.heavy > armor.light then
        role = "TANK"
    elseif armor.light >= 5 and armor.light > armor.medium and armor.light > armor.heavy then
        -- Light armor by itself can be either ranged DPS or healing. Only call it
        -- a healer when the weapon already confirms that intent.
        role = healingStaff and "HEALER" or "DAMAGE"
    end

    return {
        role = role,
        mainWeaponType = mainType,
        offWeaponType = offType,
        armor = armor,
    }
end

function C:GetDetectedRole()
    return self:GetCompanionEquipmentContext().role or "DAMAGE"
end

function C:GetButtonLabel()
    local info = self:GetActiveCompanionInfo()
    if not info then return "BEST COMPANION ABILITIES + ULT" end
    local name = info.name
    if type(zo_strupper) == "function" then
        name = safe(zo_strupper, string.upper(name), name)
    else
        name = string.upper(name)
    end
    return "BEST " .. tostring(name) .. " ABILITIES + ULT"
end

function C:IsAvailable()
    if not self:GetActiveCompanionInfo() then return false end
    return type(GetNumCompanionSkillLines) == "function"
        and type(GetCompanionSkillLineId) == "function"
        and type(GetNumAbilitiesInCompanionSkillLine) == "function"
        and type(GetCompanionAbilityId) == "function"
        and type(IsCompanionAbilityUnlocked) == "function"
        and HOTBAR_CATEGORY_COMPANION ~= nil
end

local function abilityText(abilityId)
    local name = safe(GetAbilityName, "", abilityId, "companion")
    if not name or name == "" then name = safe(GetAbilityName, "", abilityId) end
    local description = safe(GetAbilityDescription, "", abilityId, nil, "companion")
    if not description or description == "" then description = safe(GetAbilityDescription, "", abilityId) end
    return cleanName(name), tostring(description or "")
end

local function roleFlags(abilityId)
    if type(GetAbilityRoles) ~= "function" then return false, false, false end
    local tank, healer, damage = safe(GetAbilityRoles, false, abilityId)
    return tank == true, healer == true, damage == true
end

function C:CollectUnlockedAbilities()
    local out = {}
    if not self:IsAvailable() then return out end
    if type(AreCompanionSkillsInitialized) == "function" and safe(AreCompanionSkillsInitialized, false) ~= true then
        return out
    end

    local maxSkillType = safeNumber(GetNumSkillTypes, 8)
    local enumMax = tonumber(rawget(_G, "SKILL_TYPE_MAX_VALUE")) or 0
    if enumMax > maxSkillType then maxSkillType = enumMax end
    if maxSkillType <= 0 then maxSkillType = 8 end

    for skillType = 1, maxSkillType do
        local lineCount = safeNumber(GetNumCompanionSkillLines, 0, skillType)
        for lineIndex = 1, lineCount do
            local lineId = safeNumber(GetCompanionSkillLineId, 0, skillType, lineIndex)
            if lineId > 0 then
                local lineRank, active, discovered = safe(GetCompanionSkillLineDynamicInfo, 0, lineId)
                local usableLine = active ~= false and discovered ~= false
                if usableLine then
                    local lineName = cleanName(safe(GetCompanionSkillLineNameById, "", lineId))
                    local abilityCount = safeNumber(GetNumAbilitiesInCompanionSkillLine, 0, lineId)
                    for abilityIndex = 1, abilityCount do
                        local abilityId = safeNumber(GetCompanionAbilityId, 0, lineId, abilityIndex)
                        if abilityId > 0 and safe(IsCompanionAbilityUnlocked, false, abilityId) == true then
                            local passive = type(IsAbilityPassive) == "function" and safe(IsAbilityPassive, false, abilityId) == true
                            if not passive then
                                local canUse = true
                                if type(CanAbilityBeUsedFromHotbar) == "function" then
                                    canUse = safe(CanAbilityBeUsedFromHotbar, true, abilityId, HOTBAR_CATEGORY_COMPANION) ~= false
                                end
                                if canUse then
                                    local name, description = abilityText(abilityId)
                                    local tank, healer, damage = roleFlags(abilityId)
                                    local ultimate = type(IsAbilityUltimate) == "function" and safe(IsAbilityUltimate, false, abilityId) == true
                                    local cooldown = safeNumber(GetAbilityCooldown, 0, abilityId, "companion")
                                    out[#out + 1] = {
                                        abilityId = abilityId,
                                        name = name ~= "" and name or ("Ability " .. tostring(abilityId)),
                                        description = description,
                                        lineName = lineName,
                                        lineId = lineId,
                                        lineRank = tonumber(lineRank) or 0,
                                        skillType = skillType,
                                        tank = tank,
                                        healer = healer,
                                        damage = damage,
                                        ultimate = ultimate,
                                        cooldown = cooldown,
                                    }
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return out
end

function C:ScoreAbility(entry, role)
    role = role or "DAMAGE"
    local score = 0
    local text = lower((entry.name or "") .. " " .. (entry.description or "") .. " " .. (entry.lineName or ""))

    if role == "TANK" then
        if entry.tank then score = score + 1200 end
        if entry.healer then score = score + 340 end
        if entry.damage then score = score + 120 end
        if containsAny(text, {"taunt", "forces an enemy to attack", "force an enemy to attack", "provoke", "challenge"}) then score = score + 1500 end
        if containsAny(text, {"damage shield", "resistance", "armor", "block", "reduces damage", "reduce damage", "heal", "health"}) then score = score + 520 end
        if containsAny(text, {"stun", "immobil", "fear", "snare", "pull", "grip"}) then score = score + 260 end
    elseif role == "HEALER" then
        if entry.healer then score = score + 1250 end
        if entry.tank then score = score + 180 end
        if entry.damage then score = score + 140 end
        if containsAny(text, {"heal", "healing", "restores", "restore", "health", "regeneration"}) then score = score + 950 end
        if containsAny(text, {"damage shield", "ward", "resistance", "reduce damage", "reduces damage"}) then score = score + 420 end
        if containsAny(text, {"increase", "major", "minor", "empower", "buff"}) then score = score + 180 end
        if containsAny(text, {"taunt", "forces an enemy to attack"}) then score = score - 700 end
    else
        if entry.damage then score = score + 1250 end
        if entry.healer then score = score + 150 end
        if entry.tank then score = score + 90 end
        if containsAny(text, {"damage", "deals", "strike", "attack", "burn", "bleed", "poison", "shock", "frost"}) then score = score + 440 end
        if containsAny(text, {"increase damage", "critical", "vulnerability", "breach", "off balance"}) then score = score + 260 end
        if containsAny(text, {"heal", "healing", "damage shield"}) then score = score + 120 end
        if containsAny(text, {"taunt", "forces an enemy to attack"}) then score = score - 650 end
    end

    if entry.skillType == SKILL_TYPE_CLASS then score = score + 140 end
    if entry.skillType == SKILL_TYPE_WEAPON then score = score + 110 end
    score = score + math.min(100, math.max(0, tonumber(entry.lineRank) or 0) * 4)

    local cooldownSeconds = (tonumber(entry.cooldown) or 0) / 1000
    if not entry.ultimate and cooldownSeconds > 0 then
        score = score + math.max(0, 120 - math.min(120, cooldownSeconds * 5))
    end

    return score
end

function C:BuildBestAbilityView()
    local info = self:GetActiveCompanionInfo()
    local equipment = self:GetCompanionEquipmentContext()
    local role = equipment.role or "DAMAGE"
    local pool = self:CollectUnlockedAbilities()
    local normal = {}
    local ultimates = {}

    for _, entry in ipairs(pool) do
        local row = { ability = entry, score = self:ScoreAbility(entry, role) }
        if entry.ultimate then
            ultimates[#ultimates + 1] = row
        else
            normal[#normal + 1] = row
        end
    end

    local function sorter(a, b)
        if a.score == b.score then return lower(a.ability.name) < lower(b.ability.name) end
        return a.score > b.score
    end
    table.sort(normal, sorter)
    table.sort(ultimates, sorter)

    local slotCount = info and info.slots or 5
    local chosen = {}
    for i = 1, math.min(slotCount, #normal) do
        chosen[#chosen + 1] = normal[i].ability
    end

    return {
        info = info,
        equipment = equipment,
        role = role,
        abilities = chosen,
        ultimate = ultimates[1] and ultimates[1].ability or nil,
        unlockedCount = #pool,
    }
end

function C:GetCompanionAssignmentHotbar()
    local manager = rawget(_G, "ACTION_BAR_ASSIGNMENT_MANAGER")
    if manager == nil or type(manager.GetHotbar) ~= "function" or HOTBAR_CATEGORY_COMPANION == nil then
        return nil
    end

    local ok, hotbar = pcall(manager.GetHotbar, manager, HOTBAR_CATEGORY_COMPANION)
    if not ok or hotbar == nil or type(hotbar.AssignSkillToSlotByAbilityId) ~= "function" then
        return nil
    end
    return hotbar
end

function C:PendingSlotMatches(hotbar, slot, abilityId)
    if hotbar == nil or type(hotbar.GetSlotData) ~= "function" then return false end
    local ok, action = pcall(hotbar.GetSlotData, hotbar, slot)
    if not ok or action == nil then return false end

    if type(action.GetEffectiveAbilityId) == "function" then
        local idOk, effectiveId = pcall(action.GetEffectiveAbilityId, action)
        if idOk and tonumber(effectiveId) == tonumber(abilityId) then return true end
    end
    if type(action.GetActionId) == "function" then
        local idOk, actionId = pcall(action.GetActionId, action)
        if idOk and tonumber(actionId) == tonumber(abilityId) then return true end
    end
    return false
end

function C:PlaceAbility(abilityId, slot, hotbar)
    abilityId = tonumber(abilityId) or 0
    slot = tonumber(slot)
    if abilityId <= 0 or slot == nil then return false end

    if self:SlotMatches(slot, abilityId) then return true end
    hotbar = hotbar or self:GetCompanionAssignmentHotbar()
    if not hotbar then return false end
    if self:PendingSlotMatches(hotbar, slot, abilityId) then return true end

    -- Do not use ESO's protected companion cursor-pickup API here. The native
    -- Skills UI exposes companion
    -- assignment through ACTION_BAR_ASSIGNMENT_MANAGER instead; assigning through
    -- this hotbar object marks the normal SkillsAndActionBarManager dirty and lets
    -- ESO submit the pending slot changes through its own secure update flow.
    local ok, changed = pcall(hotbar.AssignSkillToSlotByAbilityId, hotbar, slot, abilityId)
    if not ok then return false end
    if changed == true then return true end
    return self:PendingSlotMatches(hotbar, slot, abilityId)
end

function C:SlotMatches(slot, abilityId)
    if type(GetSlotBoundId) ~= "function" then return false end
    local bound = safeNumber(GetSlotBoundId, 0, slot, HOTBAR_CATEGORY_COMPANION)
    if bound == abilityId then return true end
    if bound > 0 and type(GetEffectiveAbilityIdForAbilityOnHotbar) == "function" then
        local effective = safeNumber(GetEffectiveAbilityIdForAbilityOnHotbar, abilityId, abilityId, HOTBAR_CATEGORY_COMPANION)
        if effective > 0 and effective == bound then return true end
    end
    return false
end

function C:EquipBestAbilities()
    local info = self:GetActiveCompanionInfo()
    if not info then
        if EPC and EPC.GearOptimizer and EPC.GearOptimizer.NotifyResult then
            EPC.GearOptimizer:NotifyResult("COMPANION ABILITIES: summon a companion first.", false)
        elseif EPC and EPC.Print then EPC:Print("COMPANION ABILITIES: summon a companion first.") end
        return false
    end

    if safe(IsUnitInCombat, false, "player") == true then
        if EPC and EPC.GearOptimizer and EPC.GearOptimizer.NotifyResult then
            EPC.GearOptimizer:NotifyResult("COMPANION ABILITIES: leave combat before changing the companion bar.", false)
        end
        return false
    end

    if type(AreCompanionSkillsInitialized) == "function" and safe(AreCompanionSkillsInitialized, false) ~= true then
        if EPC and EPC.GearOptimizer and EPC.GearOptimizer.NotifyResult then
            EPC.GearOptimizer:NotifyResult("COMPANION ABILITIES: ESO has not finished loading the active companion's skills yet. Try again in a moment.", false)
        end
        return false
    end

    local hotbar = self:GetCompanionAssignmentHotbar()
    if not hotbar then
        if EPC and EPC.GearOptimizer and EPC.GearOptimizer.NotifyResult then
            EPC.GearOptimizer:NotifyResult("COMPANION ABILITIES: ESO's companion action-bar assignment manager is unavailable. Open the Companion menu once, then try again.", false)
        end
        return false
    end

    local skillsManager = rawget(_G, "SKILLS_AND_ACTION_BAR_MANAGER")
    if skillsManager and type(skillsManager.DoesSkillPointAllocationModeBatchSave) == "function" then
        local ok, batchSave = pcall(skillsManager.DoesSkillPointAllocationModeBatchSave, skillsManager)
        if ok and batchSave == true then
            if EPC and EPC.GearOptimizer and EPC.GearOptimizer.NotifyResult then
                EPC.GearOptimizer:NotifyResult("COMPANION ABILITIES: finish or cancel the current skill respec before applying a companion build.", false)
            end
            return false
        end
    end

    local view = self:BuildBestAbilityView()
    if #(view.abilities or {}) == 0 then
        if EPC and EPC.GearOptimizer and EPC.GearOptimizer.NotifyResult then
            EPC.GearOptimizer:NotifyResult("COMPANION ABILITIES: no unlocked active companion abilities are currently usable with this companion's equipment.", false)
        end
        return false
    end

    -- The exported ACTION_BAR_* slot constants are historically 0-indexed,
    -- while the action-bar assignment manager works with the 1-indexed slot API.
    -- Prefer ESO's live assignable range when available and otherwise convert.
    local first, ultimateSlot
    if type(GetAssignableAbilityBarStartAndEndSlots) == "function" then
        local ok, startSlot, endSlot = pcall(GetAssignableAbilityBarStartAndEndSlots)
        if ok then
            first = tonumber(startSlot)
            ultimateSlot = tonumber(endSlot)
        end
    end
    if not first then first = (tonumber(ACTION_BAR_FIRST_NORMAL_SLOT_INDEX) or 2) + 1 end
    if not ultimateSlot then ultimateSlot = (tonumber(ACTION_BAR_ULTIMATE_SLOT_INDEX) or 7) + 1 end

    local requested = {}
    local assignmentFailures = 0

    for i, ability in ipairs(view.abilities or {}) do
        local slot = first + i - 1
        if i <= (info.slots or 5) then
            if not self:PlaceAbility(ability.abilityId, slot, hotbar) then
                assignmentFailures = assignmentFailures + 1
            end
            requested[#requested + 1] = { slot = slot, ability = ability, label = tostring(i) }
        end
    end

    if view.ultimate then
        if not self:PlaceAbility(view.ultimate.abilityId, ultimateSlot, hotbar) then
            assignmentFailures = assignmentFailures + 1
        end
        requested[#requested + 1] = { slot = ultimateSlot, ability = view.ultimate, label = "ULT" }
    end

    if #requested == 0 then
        if EPC and EPC.GearOptimizer and EPC.GearOptimizer.NotifyResult then
            EPC.GearOptimizer:NotifyResult("COMPANION ABILITIES: no unlocked abilities could be assigned yet.", false)
        end
        return false
    end

    local function verify(attempt)
        local matched = 0
        local labels = {}
        for _, row in ipairs(requested) do
            if self:SlotMatches(row.slot, row.ability.abilityId) then matched = matched + 1 end
            labels[#labels + 1] = row.label .. "=" .. tostring(row.ability.name)
        end

        -- Give the normal SkillsAndActionBarManager/server round trip one more
        -- chance before reporting a failure on a slower connection.
        if matched < #requested and (attempt or 1) == 1 and type(zo_callLater) == "function" then
            zo_callLater(function() verify(2) end, 1400)
            return
        end

        local message
        local success = matched > 0
        if matched == #requested and #requested > 0 then
            message = string.format("COMPANION BUILD CONFIRMED: %s | %s | %s", tostring(info.name), tostring(view.role), table.concat(labels, " | "))
        elseif matched > 0 then
            message = string.format("COMPANION BUILD PARTIAL: %s | %d/%d slots confirmed. %s", tostring(info.name), matched, #requested, table.concat(labels, " | "))
        else
            local interactionHint = ""
            if type(IsInteractingWithMyCompanion) == "function" and safe(IsInteractingWithMyCompanion, false) ~= true then
                interactionHint = " Open the Companion menu once and try again if ESO has not initialized the companion bar yet."
            end
            local failureHint = assignmentFailures > 0 and (" " .. tostring(assignmentFailures) .. " slot request(s) were rejected before submission.") or ""
            message = "COMPANION BUILD: ESO did not confirm the requested hotbar changes." .. failureHint .. interactionHint
        end

        if EPC and EPC.GearOptimizer and EPC.GearOptimizer.NotifyResult then
            EPC.GearOptimizer:NotifyResult(message, success)
        elseif EPC and EPC.Print then EPC:Print(message) end
        if EPC and EPC.RequestRefresh then EPC:RequestRefresh("companion-ability-optimizer") end
    end

    if type(zo_callLater) == "function" then zo_callLater(function() verify(1) end, 1100) else verify(2) end
    return true
end

function C:RequestGearRefresh()
    if EPC and EPC.RequestRefresh then EPC:RequestRefresh("companion-optimizer-state") end
    if EPC and EPC.Journal and type(EPC.Journal.RefreshSuitePage) == "function" then
        pcall(EPC.Journal.RefreshSuitePage, EPC.Journal, "GEAR")
    end
end

function C:Initialize()
    if self.initialized then return end
    self.initialized = true
    local prefix = (EPC and EPC.name or "ESOAdventurerSuite") .. "_CompanionOptimizer"

    local events = {
        EVENT_ACTIVE_COMPANION_STATE_CHANGED,
        EVENT_COMPANION_ACTIVATED,
        EVENT_COMPANION_DEACTIVATED,
        EVENT_COMPANION_SKILLS_FULL_UPDATE,
    }
    local seen = {}
    for _, eventId in ipairs(events) do
        if eventId and not seen[eventId] then
            seen[eventId] = true
            EVENT_MANAGER:RegisterForEvent(prefix .. "_" .. tostring(eventId), eventId, function()
                self:RequestGearRefresh()
            end)
        end
    end

    if BAG_COMPANION_WORN ~= nil and EVENT_INVENTORY_SINGLE_SLOT_UPDATE and REGISTER_FILTER_BAG_ID then
        local invName = prefix .. "_Equipment"
        EVENT_MANAGER:RegisterForEvent(invName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function()
            self:RequestGearRefresh()
        end)
        EVENT_MANAGER:AddFilterForEvent(invName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_COMPANION_WORN)
    end
end
