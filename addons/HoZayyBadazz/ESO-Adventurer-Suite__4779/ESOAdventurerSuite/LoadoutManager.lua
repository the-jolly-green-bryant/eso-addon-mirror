-- ESO Adventurer Suite
-- Saved character builds: gear, dual action bars, Champion profile/slots, and attribute profile.
-- Native implementation; no third-party loadout source code is included.

local EPC = ESOProgressionCoach
EPC.LoadoutManager = EPC.LoadoutManager or {}
local L = EPC.LoadoutManager
local wm = WINDOW_MANAGER

local SLOT_COUNT = 12
local EQUIP_SLOTS = {
    EQUIP_SLOT_HEAD, EQUIP_SLOT_SHOULDERS, EQUIP_SLOT_CHEST, EQUIP_SLOT_HAND,
    EQUIP_SLOT_WAIST, EQUIP_SLOT_LEGS, EQUIP_SLOT_FEET,
    EQUIP_SLOT_NECK, EQUIP_SLOT_RING1, EQUIP_SLOT_RING2,
    EQUIP_SLOT_MAIN_HAND, EQUIP_SLOT_OFF_HAND,
    EQUIP_SLOT_BACKUP_MAIN, EQUIP_SLOT_BACKUP_OFF,
    EQUIP_SLOT_POISON, EQUIP_SLOT_BACKUP_POISON,
}

local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a,b,c,d,e,f = pcall(fn, ...)
    if not ok then return fallback end
    return a,b,c,d,e,f
end

local function notify(text, good)
    if EPC and type(EPC.Print) == "function" then EPC:Print(text) end
    if type(ZO_Alert) == "function" then
        pcall(ZO_Alert, good == false and UI_ALERT_CATEGORY_ERROR or UI_ALERT_CATEGORY_ALERT, nil, text)
    end
end

local function uniqueIdString(bag, slot)
    if type(GetItemUniqueId) ~= "function" or type(Id64ToString) ~= "function" then return "" end
    local id = safe(GetItemUniqueId, nil, bag, slot)
    if not id then return "" end
    return tostring(safe(Id64ToString, "", id) or "")
end

local function itemLink(bag, slot)
    return safe(GetItemLink, "", bag, slot, LINK_STYLE_DEFAULT or 0) or ""
end

function L:EnsureSaved()
    EPC.saved = EPC.saved or {}
    -- Keep the original SavedVariables key so every existing loadout survives
    -- the upgrade from loadouts to full saved builds.
    EPC.saved.savedLoadouts = EPC.saved.savedLoadouts or {}
    for i=1,SLOT_COUNT do
        EPC.saved.savedLoadouts[i] = EPC.saved.savedLoadouts[i] or { name = "Build " .. i }
        local d = EPC.saved.savedLoadouts[i]
        if not d.name or d.name == "" then
            d.name = "Build " .. i
        elseif d.name == ("Loadout " .. i) then
            d.name = "Build " .. i
        end
    end
    return EPC.saved.savedLoadouts
end

function L:GetActionSlots()
    local first = tonumber(ACTION_BAR_FIRST_NORMAL_SLOT_INDEX) or 3
    -- ACTION_BAR_ULTIMATE_SLOT_INDEX is the logical ultimate index used by parts
    -- of the UI. The physical hotbar slot queried/assigned by GetSlotBoundId /
    -- SelectSlotAbility is one slot after it.
    local ultBase = tonumber(ACTION_BAR_ULTIMATE_SLOT_INDEX) or (first + 5)
    local ult = ultBase + 1
    return {first, first+1, first+2, first+3, first+4, ult}
end

function L:CaptureBars()
    local bars = { primary = {}, backup = {} }
    local slots = self:GetActionSlots()
    local primary = rawget(_G, "HOTBAR_CATEGORY_PRIMARY") or 0
    local backup = rawget(_G, "HOTBAR_CATEGORY_BACKUP") or 1
    for _,slot in ipairs(slots) do
        bars.primary[#bars.primary+1] = tonumber(safe(GetSlotBoundId, 0, slot, primary)) or 0
        bars.backup[#bars.backup+1] = tonumber(safe(GetSlotBoundId, 0, slot, backup)) or 0
    end
    return bars
end

function L:CaptureGear()
    local gear = {}
    for _,slot in ipairs(EQUIP_SLOTS) do
        if slot ~= nil then
            local link = itemLink(BAG_WORN, slot)
            if link ~= "" then
                gear[tostring(slot)] = {
                    uniqueId = uniqueIdString(BAG_WORN, slot),
                    link = link,
                    itemId = tonumber(safe(GetItemLinkItemId, 0, link)) or 0,
                }
            end
        end
    end
    return gear
end

function L:CaptureAttributes()
    local health = tonumber(safe(GetAttributeSpentPoints, 0, rawget(_G, "ATTRIBUTE_HEALTH") or 1)) or 0
    local magicka = tonumber(safe(GetAttributeSpentPoints, 0, rawget(_G, "ATTRIBUTE_MAGICKA") or 2)) or 0
    local stamina = tonumber(safe(GetAttributeSpentPoints, 0, rawget(_G, "ATTRIBUTE_STAMINA") or 3)) or 0
    return { health = health, magicka = magicka, stamina = stamina, total = health + magicka + stamina }
end

function L:GetChampionSlots()
    local first, last = 1, 12
    if type(GetAssignableChampionBarStartAndEndSlots) == "function" then
        local a,b = safe(GetAssignableChampionBarStartAndEndSlots, nil)
        first = tonumber(a) or first
        last = tonumber(b) or last
    end
    if last < first then first, last = 1, 12 end
    return first, last
end

function L:CaptureChampion()
    local champion = { allocations = {}, slots = {}, allocatedPoints = 0, allocationCount = 0, slottedCount = 0 }
    if type(GetNumChampionDisciplines) == "function" and type(GetNumChampionDisciplineSkills) == "function"
        and type(GetChampionSkillId) == "function" and type(GetNumPointsSpentOnChampionSkill) == "function" then
        local disciplines = tonumber(safe(GetNumChampionDisciplines, 0)) or 0
        for di=1,disciplines do
            local skillCount = tonumber(safe(GetNumChampionDisciplineSkills, 0, di)) or 0
            for si=1,skillCount do
                local id = tonumber(safe(GetChampionSkillId, 0, di, si)) or 0
                if id > 0 then
                    local points = tonumber(safe(GetNumPointsSpentOnChampionSkill, 0, id)) or 0
                    if points > 0 then
                        champion.allocations[tostring(id)] = points
                        champion.allocatedPoints = champion.allocatedPoints + points
                        champion.allocationCount = champion.allocationCount + 1
                    end
                end
            end
        end
    end
    local category = rawget(_G, "HOTBAR_CATEGORY_CHAMPION")
    if category ~= nil and type(GetSlotBoundId) == "function" then
        local first,last = self:GetChampionSlots()
        champion.firstSlot, champion.lastSlot = first,last
        for slot=first,last do
            local id = tonumber(safe(GetSlotBoundId, 0, slot, category)) or 0
            champion.slots[tostring(slot)] = id
            if id > 0 then champion.slottedCount = champion.slottedCount + 1 end
        end
    end
    return champion
end

function L:CaptureSkillProfile()
    local profile = { purchased = {}, purchasedCount = 0 }
    if type(GetNumSkillTypes) ~= "function" or type(GetNumSkillLines) ~= "function"
        or type(GetNumSkillAbilities) ~= "function" or type(GetSkillAbilityInfo) ~= "function" then return profile end
    local typeCount = tonumber(safe(GetNumSkillTypes, 0)) or 0
    for skillType=1,typeCount do
        local lineCount = tonumber(safe(GetNumSkillLines, 0, skillType)) or 0
        for skillLine=1,lineCount do
            local abilityCount = tonumber(safe(GetNumSkillAbilities, 0, skillType, skillLine)) or 0
            for abilityIndex=1,abilityCount do
                local _,_,_,passive,ultimate,purchased,progressionIndex,rank = safe(GetSkillAbilityInfo, nil, skillType, skillLine, abilityIndex)
                if purchased == true then
                    local key = string.format("%d:%d:%d", skillType, skillLine, abilityIndex)
                    local abilityId = type(GetSkillAbilityId) == "function" and (tonumber(safe(GetSkillAbilityId, 0, skillType, skillLine, abilityIndex, false)) or 0) or 0
                    profile.purchased[key] = {
                        abilityId = abilityId,
                        passive = passive == true,
                        ultimate = ultimate == true,
                        progressionIndex = tonumber(progressionIndex) or 0,
                        rank = tonumber(rank) or 0,
                    }
                    profile.purchasedCount = profile.purchasedCount + 1
                end
            end
        end
    end
    return profile
end

function L:VerifySkillProfile(profile)
    if type(profile) ~= "table" or type(profile.purchased) ~= "table" or type(GetSkillAbilityInfo) ~= "function" then return 0,0 end
    local matched, expected = 0,0
    for key,_ in pairs(profile.purchased) do
        local a,b,c = string.match(key, "^(%d+):(%d+):(%d+)$")
        a,b,c = tonumber(a),tonumber(b),tonumber(c)
        if a and b and c then
            expected = expected + 1
            local _,_,_,_,_,purchased = safe(GetSkillAbilityInfo, nil, a,b,c)
            if purchased == true then matched = matched + 1 end
        end
    end
    return matched,expected
end

function L:CaptureBuildProfile()
    return {
        version = 2,
        attributes = self:CaptureAttributes(),
        champion = self:CaptureChampion(),
        skills = self:CaptureSkillProfile(),
    }
end

function L:ApplyChampionSlots(champion)
    if type(champion) ~= "table" or type(champion.slots) ~= "table" then return 0,0 end
    local category = rawget(_G, "HOTBAR_CATEGORY_CHAMPION")
    if category == nil or type(GetSlotBoundId) ~= "function" then return 0,0 end
    if type(PrepareChampionPurchaseRequest) ~= "function" or type(AddHotbarSlotToChampionPurchaseRequest) ~= "function"
        or type(SendChampionPurchaseRequest) ~= "function" then return 0,1 end

    local changed = 0
    for slotText,wanted in pairs(champion.slots) do
        local slot = tonumber(slotText)
        if slot then
            local current = tonumber(safe(GetSlotBoundId, 0, slot, category)) or 0
            if current ~= (tonumber(wanted) or 0) then changed = changed + 1 end
        end
    end
    if changed == 0 then return 0,0 end

    local ok = pcall(PrepareChampionPurchaseRequest, false)
    if not ok then return 0,changed end
    local failed = 0
    for slotText,wanted in pairs(champion.slots) do
        local slot = tonumber(slotText)
        if slot then
            local addOk = pcall(AddHotbarSlotToChampionPurchaseRequest, slot, tonumber(wanted) or 0)
            if not addOk then failed = failed + 1 end
        end
    end
    local expected = type(GetExpectedResultForChampionPurchaseRequest) == "function" and safe(GetExpectedResultForChampionPurchaseRequest, nil) or nil
    local successConst = rawget(_G, "CHAMPION_PURCHASE_SUCCESS")
    if expected ~= nil and successConst ~= nil and expected ~= successConst then return 0,math.max(1,failed) end
    local sent, result = pcall(SendChampionPurchaseRequest)
    if not sent or result == false then return 0,math.max(1,failed) end
    return changed,failed
end

function L:VerifyChampionProfile(champion)
    if type(champion) ~= "table" then return 0,0,0,0 end
    local slotMatched, slotExpected = 0,0
    local category = rawget(_G, "HOTBAR_CATEGORY_CHAMPION")
    if category ~= nil and type(GetSlotBoundId) == "function" then
        for slotText,wanted in pairs(champion.slots or {}) do
            local slot = tonumber(slotText)
            if slot then
                slotExpected = slotExpected + 1
                local current = tonumber(safe(GetSlotBoundId, 0, slot, category)) or 0
                if current == (tonumber(wanted) or 0) then slotMatched = slotMatched + 1 end
            end
        end
    end
    local pointMatched, pointExpected = 0,0
    if type(GetNumPointsSpentOnChampionSkill) == "function" then
        for idText,wanted in pairs(champion.allocations or {}) do
            local id = tonumber(idText)
            if id then
                pointExpected = pointExpected + 1
                if (tonumber(safe(GetNumPointsSpentOnChampionSkill, 0, id)) or 0) == (tonumber(wanted) or 0) then
                    pointMatched = pointMatched + 1
                end
            end
        end
    end
    return slotMatched,slotExpected,pointMatched,pointExpected
end

function L:Save(index)
    index = tonumber(index)
    if not index or index < 1 or index > SLOT_COUNT then return false end
    if safe(IsUnitInCombat, false, "player") == true then
        notify("BUILD: leave combat before saving or changing equipment.", false)
        return false
    end
    local all = self:EnsureSaved()
    local oldName = all[index].name or ("Build " .. index)
    all[index] = {
        name = oldName,
        gear = self:CaptureGear(),
        bars = self:CaptureBars(),
        build = self:CaptureBuildProfile(),
        savedAt = safe(GetTimeStamp, 0) or 0,
    }
    notify(string.format("BUILD %d SAVED: %s", index, oldName), true)
    self:RefreshUI()
    return true
end

function L:FindSavedItem(entry, destination)
    if not entry then return nil end
    local wantedUid = tostring(entry.uniqueId or "")
    local wantedItemId = tonumber(entry.itemId) or 0

    if destination ~= nil then
        local current = itemLink(BAG_WORN, destination)
        if current ~= "" then
            if wantedUid ~= "" and uniqueIdString(BAG_WORN, destination) == wantedUid then
                return BAG_WORN, destination, true
            end
            if wantedUid == "" and wantedItemId > 0 and tonumber(safe(GetItemLinkItemId, 0, current)) == wantedItemId then
                return BAG_WORN, destination, true
            end
        end
    end

    local function scanBag(bag)
        if bag == nil then return nil end
        local size = tonumber(safe(GetBagSize, 0, bag)) or 0
        for slot=0,size-1 do
            local link = itemLink(bag, slot)
            if link ~= "" then
                if wantedUid ~= "" and uniqueIdString(bag, slot) == wantedUid then return bag, slot, false end
                if wantedUid == "" and wantedItemId > 0 and tonumber(safe(GetItemLinkItemId, 0, link)) == wantedItemId then return bag, slot, false end
            end
        end
        return nil
    end

    local bag,slot,same = scanBag(BAG_BACKPACK)
    if bag then return bag,slot,same end
    if BAG_WORN ~= nil then
        for _,slotId in ipairs(EQUIP_SLOTS) do
            if slotId ~= nil then
                local link = itemLink(BAG_WORN, slotId)
                if link ~= "" then
                    if wantedUid ~= "" and uniqueIdString(BAG_WORN, slotId) == wantedUid then return BAG_WORN, slotId, false end
                    if wantedUid == "" and wantedItemId > 0 and tonumber(safe(GetItemLinkItemId, 0, link)) == wantedItemId then return BAG_WORN, slotId, false end
                end
            end
        end
    end
    return nil
end

function L:GetSkillDataForSavedId(savedId)
    savedId = tonumber(savedId) or 0
    if savedId <= 0 then return nil end
    local mgr = rawget(_G, "SKILLS_DATA_MANAGER")
    if not mgr or type(mgr.GetSkillDataByIndices) ~= "function" then return nil end

    if type(GetSkillAbilityIndicesFromCraftedAbilityId) == "function" then
        local t,l,a = safe(GetSkillAbilityIndicesFromCraftedAbilityId, 0, savedId)
        if tonumber(t) and tonumber(t) > 0 then
            local ok, data = pcall(mgr.GetSkillDataByIndices, mgr, t,l,a)
            if ok and data then return data end
        end
    end

    if type(GetAbilityProgressionXPInfoFromAbilityId) == "function" and type(GetSkillAbilityIndicesFromProgressionIndex) == "function" then
        local hasProgression, progressionIndex = safe(GetAbilityProgressionXPInfoFromAbilityId, false, savedId)
        if hasProgression and tonumber(progressionIndex) and tonumber(progressionIndex) > 0 then
            local t,l,a = safe(GetSkillAbilityIndicesFromProgressionIndex, 0, progressionIndex)
            if tonumber(t) and tonumber(t) > 0 then
                local ok, data = pcall(mgr.GetSkillDataByIndices, mgr, t,l,a)
                if ok and data then return data end
            end
        end
    end

    -- Fallback for clients where progression lookup is stale: scan purchased skill data.
    if type(GetNumSkillTypes) == "function" and type(GetNumSkillLines) == "function" and type(GetNumSkillAbilities) == "function" then
        for t=1,(tonumber(safe(GetNumSkillTypes,0)) or 0) do
            for l=1,(tonumber(safe(GetNumSkillLines,0,t)) or 0) do
                for a=1,(tonumber(safe(GetNumSkillAbilities,0,t,l)) or 0) do
                    local abilityId = tonumber(safe(GetSkillAbilityId,0,t,l,a)) or 0
                    if abilityId == savedId then
                        local ok, data = pcall(mgr.GetSkillDataByIndices, mgr, t,l,a)
                        if ok and data then return data end
                    end
                end
            end
        end
    end
    return nil
end

function L:GetAbilityIndexForSavedId(savedId)
    savedId = tonumber(savedId) or 0
    if savedId <= 0 then return 0 end

    -- GetSlotBoundId stores the live ability id. For normal and most crafted
    -- abilities ESO can convert that id straight back to the protected API's
    -- abilityIndex.
    if type(GetAbilityIndex) == "function" then
        local idx = tonumber(safe(GetAbilityIndex, 0, savedId)) or 0
        if idx > 0 then return idx end
    end

    -- Resolve the player's current morph/rank from the ability progression.
    if type(GetAbilityProgressionXPInfoFromAbilityId) == "function"
        and type(GetAbilityProgressionInfo) == "function"
        and type(GetAbilityProgressionAbilityInfo) == "function" then
        local hasProgression, progressionIndex = safe(GetAbilityProgressionXPInfoFromAbilityId, false, savedId)
        progressionIndex = tonumber(progressionIndex) or 0
        if hasProgression and progressionIndex > 0 then
            local _, morphChoice, rank = safe(GetAbilityProgressionInfo, nil, progressionIndex)
            local _, _, idx = safe(GetAbilityProgressionAbilityInfo, nil, progressionIndex, tonumber(morphChoice) or 0, tonumber(rank) or 1)
            idx = tonumber(idx) or 0
            if idx > 0 then return idx end
        end
    end

    -- Last-resort scan for clients where a progression lookup has not been
    -- populated yet. This also gives us the purchased skill's progression.
    if type(GetNumSkillTypes) == "function" and type(GetNumSkillLines) == "function"
        and type(GetNumSkillAbilities) == "function" and type(GetSkillAbilityInfo) == "function" then
        for t=1,(tonumber(safe(GetNumSkillTypes,0)) or 0) do
            for l=1,(tonumber(safe(GetNumSkillLines,0,t)) or 0) do
                for a=1,(tonumber(safe(GetNumSkillAbilities,0,t,l)) or 0) do
                    local id = type(GetSkillAbilityId) == "function" and (tonumber(safe(GetSkillAbilityId,0,t,l,a,false)) or 0) or 0
                    if id == savedId then
                        local _,_,_,passive,_,purchased,progressionIndex,rank = safe(GetSkillAbilityInfo,nil,t,l,a)
                        if purchased == true and passive ~= true then
                            progressionIndex = tonumber(progressionIndex) or 0
                            if progressionIndex > 0 and type(GetAbilityProgressionInfo) == "function" and type(GetAbilityProgressionAbilityInfo) == "function" then
                                local _, morphChoice, currentRank = safe(GetAbilityProgressionInfo,nil,progressionIndex)
                                local _,_,idx = safe(GetAbilityProgressionAbilityInfo,nil,progressionIndex,tonumber(morphChoice) or 0,tonumber(currentRank) or tonumber(rank) or 1)
                                idx = tonumber(idx) or 0
                                if idx > 0 then return idx end
                            end
                        end
                    end
                end
            end
        end
    end
    return 0
end

function L:ApplyBar(category, saved)
    if type(saved) ~= "table" then return 0, 0 end
    if type(CallSecureProtected) ~= "function" then return 0, #saved end

    local actionSlots = self:GetActionSlots()
    local changed, failed = 0, 0
    for i=1,#actionSlots do
        local actionSlot = actionSlots[i]
        local savedId = tonumber(saved[i]) or 0
        local currentId = tonumber(safe(GetSlotBoundId, 0, actionSlot, category)) or 0

        if currentId ~= savedId then
            if savedId <= 0 then
                local ok, result = pcall(CallSecureProtected, "ClearSlot", actionSlot, category)
                if ok and result ~= false then changed = changed + 1 else failed = failed + 1 end
            else
                local abilityIndex = self:GetAbilityIndexForSavedId(savedId)
                local legal = abilityIndex > 0
                if legal and type(CanAbilityBeUsedFromHotbar) == "function" then
                    legal = safe(CanAbilityBeUsedFromHotbar, false, savedId, category) == true
                end
                if legal then
                    local ok, result = pcall(CallSecureProtected, "SelectSlotAbility", abilityIndex, actionSlot, category)
                    if ok and result ~= false then changed = changed + 1 else failed = failed + 1 end
                else
                    failed = failed + 1
                end
            end
        end
    end
    return changed, failed
end

function L:ApplyBars(bars)
    if type(bars) ~= "table" then return 0, 0 end
    local primary = rawget(_G, "HOTBAR_CATEGORY_PRIMARY") or 0
    local backup = rawget(_G, "HOTBAR_CATEGORY_BACKUP") or 1
    local c1,f1 = self:ApplyBar(primary, bars.primary or {})
    local c2,f2 = self:ApplyBar(backup, bars.backup or {})
    return c1+c2, f1+f2
end

function L:BuildGearOperations(gear)
    local ops = {}
    if type(gear) ~= "table" then return ops end
    for _,dest in ipairs(EQUIP_SLOTS) do
        if dest ~= nil and gear[tostring(dest)] then
            ops[#ops+1] = { destination = dest, entry = gear[tostring(dest)] }
        end
    end
    return ops
end

function L:ApplyGearSequential(gear, callback)
    if type(gear) ~= "table" then
        if callback then callback(0,0) end
        return
    end
    if type(RequestEquipItem) ~= "function" then
        if callback then callback(0,1) end
        return
    end

    local ops = self:BuildGearOperations(gear)
    local requested, missing = 0, 0
    local pos = 1

    local function finish()
        if callback then callback(requested, missing) end
    end

    local function step()
        if pos > #ops then finish(); return end
        local op = ops[pos]
        pos = pos + 1

        -- Re-find by unique id for every step because previous equip requests
        -- can move the replaced item into the backpack.
        local bag, slot, already = self:FindSavedItem(op.entry, op.destination)
        if already then
            if type(zo_callLater) == "function" then zo_callLater(step, 45) else step() end
            return
        end

        if bag ~= nil and slot ~= nil then
            local ok = pcall(RequestEquipItem, bag, slot, BAG_WORN, op.destination)
            if ok then requested = requested + 1 else missing = missing + 1 end
        else
            missing = missing + 1
        end

        -- Inventory/equipment updates are asynchronous. Spacing requests keeps
        -- ESO from dropping a multi-piece loadout swap when several slots move.
        if type(zo_callLater) == "function" then zo_callLater(step, 120) else step() end
    end

    step()
end

function L:Verify(index)
    local build = self:EnsureSaved()[index]
    if not build or not build.gear then return end
    local gearMatched, gearExpected = 0, 0
    for slotText,entry in pairs(build.gear) do
        local slot = tonumber(slotText)
        if slot then
            gearExpected = gearExpected + 1
            local uid = uniqueIdString(BAG_WORN, slot)
            local link = itemLink(BAG_WORN, slot)
            if (entry.uniqueId and entry.uniqueId ~= "" and uid == entry.uniqueId)
                or ((not entry.uniqueId or entry.uniqueId == "") and tonumber(entry.itemId) == tonumber(safe(GetItemLinkItemId,0,link))) then
                gearMatched = gearMatched + 1
            end
        end
    end

    local barsMatched, barsExpected = 0, 0
    local current = self:CaptureBars()
    for _,key in ipairs({"primary","backup"}) do
        for i,wanted in ipairs((build.bars and build.bars[key]) or {}) do
            barsExpected = barsExpected + 1
            if tonumber(current[key][i]) == tonumber(wanted) then barsMatched = barsMatched + 1 end
        end
    end

    local profile = build.build or {}
    local cpSlotMatched,cpSlotExpected,cpPointMatched,cpPointExpected = self:VerifyChampionProfile(profile.champion)
    local skillMatched,skillExpected = self:VerifySkillProfile(profile.skills)
    local attrs = profile.attributes
    local attrMatch = true
    local attrText = ""
    if type(attrs) == "table" then
        local now = self:CaptureAttributes()
        attrMatch = now.health == (tonumber(attrs.health) or 0) and now.magicka == (tonumber(attrs.magicka) or 0) and now.stamina == (tonumber(attrs.stamina) or 0)
        attrText = string.format(" | Attr H%d/M%d/S%d%s", tonumber(attrs.health) or 0, tonumber(attrs.magicka) or 0, tonumber(attrs.stamina) or 0, attrMatch and "" or " (profile differs)")
    end
    local cpSlotsComplete = cpSlotExpected == 0 or cpSlotMatched == cpSlotExpected
    local cpPointsComplete = cpPointExpected == 0 or cpPointMatched == cpPointExpected
    local skillsComplete = skillExpected == 0 or skillMatched == skillExpected
    local complete = gearMatched == gearExpected and barsMatched == barsExpected and cpSlotsComplete and cpPointsComplete and skillsComplete and attrMatch
    notify(string.format("BUILD %d %s: Gear %d/%d | Bars %d/%d | Skills %d/%d | CP Slots %d/%d | CP Profile %d/%d%s",
        index, complete and "CONFIRMED" or "PARTIAL", gearMatched, gearExpected, barsMatched, barsExpected, skillMatched, skillExpected,
        cpSlotMatched, cpSlotExpected, cpPointMatched, cpPointExpected, attrText), complete)
end

function L:Equip(index)
    index = tonumber(index)
    if not index or index < 1 or index > SLOT_COUNT then return false end
    if self.equipInProgress then
        notify("BUILD: another saved build is still being applied.", false)
        return false
    end
    if safe(IsUnitInCombat, false, "player") == true then
        notify("BUILD: leave combat before applying a saved build.", false)
        return false
    end
    local loadout = self:EnsureSaved()[index]
    if not loadout or not loadout.gear or not loadout.bars then
        notify(string.format("BUILD %d is empty. Save your current build first.", index), false)
        return false
    end

    self.equipInProgress = true
    notify(string.format("BUILD %d APPLYING: %s", index, tostring(loadout.name or ("Build "..index))), true)

    self:ApplyGearSequential(loadout.gear, function(gearRequested, missing)
        local function applyBarsAndVerify()
            local barChanged, barFailed = self:ApplyBars(loadout.bars)
            local cpChanged, cpFailed = self:ApplyChampionSlots(loadout.build and loadout.build.champion)
            local unavailable = missing + barFailed + cpFailed
            notify(string.format("BUILD %d: %d gear request%s | %d bar change%s | %d CP slot change%s%s",
                index,
                gearRequested, gearRequested==1 and "" or "s",
                barChanged, barChanged==1 and "" or "s",
                cpChanged, cpChanged==1 and "" or "s",
                unavailable>0 and string.format(" | %d unavailable", unavailable) or ""),
                unavailable==0)

            local function verifyDone()
                self.equipInProgress = false
                self:Verify(index)
                if EPC.GearLoadoutOverlay and type(EPC.GearLoadoutOverlay.ScheduleRefresh) == "function" then
                    EPC.GearLoadoutOverlay:ScheduleRefresh(50)
                end
                self:RefreshUI()
            end
            if type(zo_callLater) == "function" then zo_callLater(verifyDone, 750) else verifyDone() end
        end
        if type(zo_callLater) == "function" then zo_callLater(applyBarsAndVerify, 180) else applyBarsAndVerify() end
    end)
    return true
end

function L:Clear(index)
    index = tonumber(index)
    if not index or index < 1 or index > SLOT_COUNT then return false end
    local all = self:EnsureSaved()
    local name = all[index].name or ("Build " .. index)
    all[index] = { name = name }
    notify(string.format("BUILD %d CLEARED: %s", index, name), true)
    self:RefreshUI()
    return true
end

function L:SetName(index, name, silent)
    index = tonumber(index)
    if not index or index < 1 or index > SLOT_COUNT then return false end
    name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if name == "" then name = "Build " .. index end
    name = string.sub(name, 1, 28)
    local all = self:EnsureSaved()
    all[index].name = name
    if silent ~= true then
        notify(string.format("BUILD %d RENAMED: %s", index, name), true)
    end
    self:RefreshUI()
    return true
end

function L:BeginRename(index)
    index = tonumber(index)
    local c = index and self.cards and self.cards[index]
    if not c or not c.edit then return end
    self:AcquireUIMode(false)
    local function focusName()
        if not c.edit then return end
        if c.edit.SetEditEnabled then c.edit:SetEditEnabled(true) end
        c.edit:SetMouseEnabled(true)
        if c.edit.SetKeyboardEnabled then c.edit:SetKeyboardEnabled(true) end
        if c.edit.TakeFocus then c.edit:TakeFocus() end
        if c.edit.SelectAllText then c.edit:SelectAllText() end
    end
    focusName()
    if type(zo_callLater) == "function" then zo_callLater(focusName, 0) end
end

function L:EnsureWindowSaved()
    EPC.saved = EPC.saved or {}
    EPC.saved.savedLoadoutWindow = EPC.saved.savedLoadoutWindow or {}
    local s = EPC.saved.savedLoadoutWindow
    s.width = tonumber(s.width) or 840
    s.height = tonumber(s.height) or 820
    return s
end

function L:GetAbilityIconPath(savedId)
    savedId = tonumber(savedId) or 0
    if savedId <= 0 then return "" end
    local icon = ""
    if type(GetAbilityIcon) == "function" then
        icon = safe(GetAbilityIcon, "", savedId) or ""
    end
    if icon == "" then
        local data = self:GetSkillDataForSavedId(savedId)
        if data then
            if type(data.GetIcon) == "function" then
                icon = safe(data.GetIcon, "", data) or ""
            end
            if icon == "" and type(data.GetCurrentSkillProgressionKey) == "function" and type(data.GetSkillProgressionData) == "function" then
                local progressionKey = safe(data.GetCurrentSkillProgressionKey, nil, data)
                local progressionData = progressionKey and safe(data.GetSkillProgressionData, nil, data, progressionKey) or nil
                if progressionData and type(progressionData.GetIcon) == "function" then
                    icon = safe(progressionData.GetIcon, "", progressionData) or ""
                end
            end
        end
    end
    return icon or ""
end

function L:UpdateSkillIcons(iconList, barData)
    for idx,holder in ipairs(iconList or {}) do
        local savedId = tonumber((barData or {})[idx]) or 0
        if savedId > 0 then
            local icon = self:GetAbilityIconPath(savedId)
            if icon ~= "" then
                holder.icon:SetTexture(icon)
                holder.icon:SetHidden(false)
                holder.frame:SetEdgeColor(0.30, 0.56, 0.82, 0.82)
            else
                holder.icon:SetHidden(true)
                holder.frame:SetEdgeColor(0.26, 0.20, 0.20, 0.75)
            end
        else
            holder.icon:SetHidden(true)
            holder.frame:SetEdgeColor(0.18, 0.24, 0.32, 0.68)
        end
    end
end

function L:GetDefaultWindowAnchor()
    local guiW, guiH = GuiRoot:GetDimensions()
    guiW = tonumber(guiW) or 1920
    guiH = tonumber(guiH) or 1080
    local width, height = 840, 820
    local x = math.floor((guiW - width) * 0.5 + 260)
    local y = math.floor((guiH - height) * 0.5)

    local journal = EPC and EPC.Journal and EPC.Journal.window
    if journal and type(journal.IsHidden) == "function" and journal:IsHidden() == false then
        local jl, jt = tonumber(journal:GetLeft()) or 0, tonumber(journal:GetTop()) or 0
        local jw, jh = journal:GetDimensions()
        jw = tonumber(jw) or 0
        jh = tonumber(jh) or 0
        local gap = 26
        local rightX = jl + jw + gap
        local leftX = jl - width - gap
        local pad = 10
        if rightX + width <= guiW - pad then
            x = rightX
        elseif leftX >= pad then
            x = leftX
        else
            x = math.max(pad, math.min(guiW - width - pad, rightX))
        end
        y = math.max(pad, math.min(guiH - height - pad, jt))
    end

    x = math.max(10, math.min(guiW - width - 10, x))
    y = math.max(10, math.min(guiH - height - 10, y))
    return x, y
end

function L:RestoreWindowPlacement(forceReposition)
    if not self.window then return end
    local s = self:EnsureWindowSaved()
    local w = math.max(820, math.min(1400, tonumber(s.width) or 840))
    local h = math.max(780, math.min(1200, tonumber(s.height) or 820))
    self.window:SetDimensions(w, h)
    self.window:ClearAnchors()
    if forceReposition == true or not tonumber(s.left) or not tonumber(s.top) then
        local x, y = self:GetDefaultWindowAnchor()
        self.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
        s.left, s.top = x, y
    else
        self.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, tonumber(s.left) or 100, tonumber(s.top) or 100)
    end
end

local function makeBackdrop(name, parent)
    local c = wm:CreateControl(name, parent, CT_BACKDROP)
    c:SetEdgeTexture(nil, 1, 1, 1)
    return c
end

local function makeButton(name, parent, text, handler)
    local b = wm:CreateControl(name, parent, CT_BUTTON)
    b:SetFont("ZoFontGameBold")
    b:SetText(text)
    if b.SetHorizontalAlignment then b:SetHorizontalAlignment(TEXT_ALIGN_CENTER) end
    if b.SetVerticalAlignment then b:SetVerticalAlignment(TEXT_ALIGN_CENTER) end
    local border = wm:CreateControl(name .. "Border", b, CT_BACKDROP)
    border:SetAnchor(TOPLEFT, b, TOPLEFT, 1, 1)
    border:SetAnchor(BOTTOMRIGHT, b, BOTTOMRIGHT, -1, -1)
    border:SetCenterColor(0.035,0.050,0.072,0.55)
    border:SetEdgeColor(0.24,0.36,0.54,0.92)
    border:SetEdgeTexture(nil,1,1,1)
    if border.SetDrawLevel then border:SetDrawLevel(0) end
    b.easBorder = border
    if handler then b:SetHandler("OnClicked", handler) end
    return b
end

function L:CreateUI()
    if self.window then return end

    local win = wm:CreateTopLevelWindow("EAS_LoadoutManager")
    win:SetDimensions(840, 820)
    if win.SetDimensionConstraints then win:SetDimensionConstraints(820, 780, 1400, 1200) end
    if win.SetResizeHandleSize then win:SetResizeHandleSize(24) end
    -- Permit flush placement at the left/right edges and all four corners.
    win:SetClampedToScreen(false)
    win:SetMovable(true)
    win:SetMouseEnabled(true)
    win:SetHidden(true)
    win:SetDrawLayer(DL_OVERLAY)
    win:SetDrawTier(DT_HIGH)
    self.window = win
    self:RestoreWindowPlacement(false)

    local bg = makeBackdrop("EAS_LoadoutManagerBG", win)
    bg:SetAnchorFill(win)
    bg:SetCenterColor(0.012,0.018,0.028,0.97)
    bg:SetEdgeColor(0.30,0.56,0.82,0.88)
    self.bg = bg

    local title = wm:CreateControl("EAS_LoadoutManagerTitle", win, CT_LABEL)
    title:SetFont("ZoFontWinH2")
    title:SetText("SAVED BUILDS")
    title:SetAnchor(TOPLEFT, win, TOPLEFT, 18, 14)
    title:SetDimensions(420, 30)
    title:SetColor(0.94,0.97,1,1)

    local sub = wm:CreateControl("EAS_LoadoutManagerSub", win, CT_LABEL)
    sub:SetFont("ZoFontGameSmall")
    sub:SetText("Resizable build workspace. Save gear, both skill bars, Champion profile/slots, and attribute profile.")
    sub:SetAnchor(TOPLEFT, win, TOPLEFT, 19, 44)
    sub:SetDimensions(730, 20)
    sub:SetColor(0.58,0.68,0.80,1)

    local close = makeButton("EAS_LoadoutManagerClose", win, "CLOSE BUILDS", function() self:Hide() end)
    close:SetAnchor(TOPRIGHT, win, TOPRIGHT, -14, 14)
    close:SetDimensions(150, 30)
    self.closeLoadoutsButton = close

    local helper = wm:CreateControl("EAS_LoadoutManagerHelper", win, CT_LABEL)
    helper:SetFont("ZoFontGameSmall")
    helper:SetText("Each build shows both skill bars. APPLY restores gear, bars, and Champion slots; saved skill/CP/attribute profiles are verified too.")
    helper:SetAnchor(TOPLEFT, win, TOPLEFT, 19, 62)
    helper:SetDimensions(780, 18)
    helper:SetColor(0.48,0.58,0.70,1)

    self.cards = {}
    local cols, cardW, cardH, gapX, gapY = 3, 250, 154, 12, 12
    local startX, startY = 18, 92
    for i=1,SLOT_COUNT do
        local row = math.floor((i-1)/cols)
        local col = (i-1)%cols
        local card = makeBackdrop("EAS_LoadoutCard"..i, win)
        card:SetAnchor(TOPLEFT, win, TOPLEFT, startX + col*(cardW+gapX), startY + row*(cardH+gapY))
        card:SetDimensions(cardW, cardH)
        card:SetCenterColor(0.025,0.035,0.052,0.93)
        card:SetEdgeColor(0.20,0.30,0.43,0.75)

        local slot = wm:CreateControl("EAS_LoadoutSlot"..i, card, CT_LABEL)
        slot:SetFont("ZoFontGameBold")
        slot:SetText("SET "..i)
        slot:SetAnchor(TOPLEFT, card, TOPLEFT, 8, 8)
        slot:SetDimensions(58, 18)
        slot:SetColor(0.44,0.78,1,1)

        local nameBG = makeBackdrop("EAS_LoadoutNameBG"..i, card)
        nameBG:SetAnchor(TOPLEFT, card, TOPLEFT, 64, 5)
        nameBG:SetDimensions(cardW-72, 26)
        nameBG:SetCenterColor(0.018,0.026,0.038,0.90)
        nameBG:SetEdgeColor(0.24,0.38,0.54,0.72)

        local edit = wm:CreateControl("EAS_LoadoutName"..i, nameBG, CT_EDITBOX)
        edit:SetFont("ZoFontGame")
        edit:SetAnchor(TOPLEFT, nameBG, TOPLEFT, 6, 2)
        edit:SetDimensions(cardW-86, 22)
        edit:SetMaxInputChars(28)
        edit:SetColor(0.94,0.97,1,1)
        -- ESO can render a bare CT_EDITBOX without allowing it to receive
        -- clicks/keyboard input in a custom top-level overlay. Make the name
        -- field explicitly editable and focusable.
        edit:SetMouseEnabled(true)
        if edit.SetKeyboardEnabled then edit:SetKeyboardEnabled(true) end
        if edit.SetEditEnabled then edit:SetEditEnabled(true) end
        if edit.SetCopyEnabled then edit:SetCopyEnabled(true) end
        if edit.SetPasteEnabled then edit:SetPasteEnabled(true) end
        if edit.SetTextType and TEXT_TYPE_ALL then edit:SetTextType(TEXT_TYPE_ALL) end
        edit:SetHandler("OnMouseUp", function(control, button, upInside)
            if upInside ~= false and control.TakeFocus then control:TakeFocus() end
        end)
        edit:SetHandler("OnFocusGained", function(control)
            nameBG:SetEdgeColor(0.44,0.78,1.00,0.95)
        end)
        edit:SetHandler("OnFocusLost", function(control)
            nameBG:SetEdgeColor(0.24,0.38,0.54,0.72)
            self:SetName(i, control:GetText(), true)
        end)
        edit:SetHandler("OnEnter", function(control)
            self:SetName(i, control:GetText(), false)
            if control.LoseFocus then control:LoseFocus() end
        end)
        edit:SetHandler("OnEscape", function(control)
            local all = self:EnsureSaved()
            control:SetText((all[i] and all[i].name) or ("Build "..i))
            if control.LoseFocus then control:LoseFocus() end
        end)

        local status = wm:CreateControl("EAS_LoadoutStatus"..i, card, CT_LABEL)
        status:SetFont("ZoFontGameSmall")
        status:SetAnchor(TOPLEFT, card, TOPLEFT, 8, 31)
        status:SetDimensions(cardW-16, 16)
        status:SetColor(0.56,0.66,0.76,1)

        local frontLabel = wm:CreateControl("EAS_LoadoutFrontLabel"..i, card, CT_LABEL)
        frontLabel:SetFont("ZoFontGameSmall")
        frontLabel:SetText("FRONT")
        frontLabel:SetAnchor(TOPLEFT, card, TOPLEFT, 8, 53)
        frontLabel:SetDimensions(36, 14)
        frontLabel:SetColor(0.62,0.72,0.84,1)

        local backLabel = wm:CreateControl("EAS_LoadoutBackLabel"..i, card, CT_LABEL)
        backLabel:SetFont("ZoFontGameSmall")
        backLabel:SetText("BACK")
        backLabel:SetAnchor(TOPLEFT, card, TOPLEFT, 8, 83)
        backLabel:SetDimensions(36, 14)
        backLabel:SetColor(0.62,0.72,0.84,1)

        local function createIconRow(prefix, y)
            local icons = {}
            for n=1,6 do
                local holder = makeBackdrop(prefix.."Frame"..n, card)
                holder:SetAnchor(TOPLEFT, card, TOPLEFT, 46 + (n-1)*32, y)
                holder:SetDimensions(28, 28)
                holder:SetCenterColor(0.015,0.020,0.028,0.90)
                holder:SetEdgeColor(0.18,0.24,0.32,0.68)
                local tex = wm:CreateControl(prefix.."Icon"..n, holder, CT_TEXTURE)
                tex:SetAnchorFill(holder)
                tex:SetHidden(true)
                icons[n] = { frame = holder, icon = tex }
            end
            return icons
        end

        local frontIcons = createIconRow("EAS_Loadout"..i.."Front", 49)
        local backIcons = createIconRow("EAS_Loadout"..i.."Back", 79)

        local equip = makeButton("EAS_LoadoutEquip"..i, card, "APPLY", function() self:Equip(i) end)
        equip:SetAnchor(BOTTOMLEFT, card, BOTTOMLEFT, 8, -8)
        equip:SetDimensions(55, 24)
        local save = makeButton("EAS_LoadoutSave"..i, card, "SAVE", function() self:Save(i) end)
        save:SetAnchor(BOTTOMLEFT, card, BOTTOMLEFT, 68, -8)
        save:SetDimensions(55, 24)
        local rename = makeButton("EAS_LoadoutRename"..i, card, "NAME", function() self:BeginRename(i) end)
        rename:SetAnchor(BOTTOMLEFT, card, BOTTOMLEFT, 128, -8)
        rename:SetDimensions(55, 24)
        local clear = makeButton("EAS_LoadoutClear"..i, card, "CLEAR", function() self:Clear(i) end)
        clear:SetAnchor(BOTTOMLEFT, card, BOTTOMLEFT, 188, -8)
        clear:SetDimensions(54, 24)

        self.cards[i] = {
            card=card,
            nameBG=nameBG,
            edit=edit,
            status=status,
            frontIcons=frontIcons,
            backIcons=backIcons,
        }
    end

    local footer = wm:CreateControl("EAS_LoadoutFooter", win, CT_LABEL)
    footer:SetFont("ZoFontGameSmall")
    footer:SetText("Use APPLY, SAVE, NAME, and CLEAR. Skill, attribute, and full Champion respecs are saved as profiles and never paid automatically.")
    footer:SetAnchor(BOTTOMLEFT, win, BOTTOMLEFT, 18, -12)
    footer:SetDimensions(794, 18)
    footer:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    footer:SetColor(0.50,0.60,0.72,1)

    win:SetHandler("OnMoveStop", function(control)
        local s = self:EnsureWindowSaved()
        s.left, s.top = control:GetLeft(), control:GetTop()
        s.userMoved = true
    end)
    win:SetHandler("OnResizeStop", function(control)
        local s = self:EnsureWindowSaved()
        local w,h = control:GetDimensions()
        s.width, s.height = math.floor(w + 0.5), math.floor(h + 0.5)
    end)
end

function L:RefreshUI()
    if not self.cards then return end
    local all = self:EnsureSaved()
    for i=1,SLOT_COUNT do
        local c = self.cards[i]
        local d = all[i]
        if c and d then
            if not c.edit:HasFocus() then c.edit:SetText(d.name or ("Build "..i)) end
            local gearCount = 0
            for _ in pairs(d.gear or {}) do gearCount = gearCount + 1 end
            local barCount = 0
            for _,key in ipairs({"primary","backup"}) do
                for _,id in ipairs((d.bars and d.bars[key]) or {}) do if tonumber(id) and tonumber(id) > 0 then barCount = barCount + 1 end end
            end
            local cpSlots = d.build and d.build.champion and tonumber(d.build.champion.slottedCount) or 0
            local attrs = d.build and d.build.attributes
            local attrShort = attrs and string.format(" | H%d M%d S%d", tonumber(attrs.health) or 0, tonumber(attrs.magicka) or 0, tonumber(attrs.stamina) or 0) or ""
            c.status:SetText(d.gear and string.format("G%d | S%d | CP%d%s", gearCount, barCount, cpSlots, attrShort) or "EMPTY")
            self:UpdateSkillIcons(c.frontIcons, d.bars and d.bars.primary)
            self:UpdateSkillIcons(c.backIcons, d.bars and d.bars.backup)
            if d.gear then
                c.card:SetEdgeColor(0.24,0.42,0.60,0.84)
            else
                c.card:SetEdgeColor(0.20,0.30,0.43,0.75)
            end
        end
    end
end

function L:SetUIMode(active)
    active = active == true
    local changed = false
    if type(SetGameCameraUIMode) == "function" then
        local ok = pcall(SetGameCameraUIMode, active)
        changed = ok == true or changed
    end
    -- Keep the scene manager in agreement with camera UI mode. Some ESO
    -- scenes restore character control after a custom top-level window opens.
    if SCENE_MANAGER and type(SCENE_MANAGER.SetInUIMode) == "function" then
        local ok = pcall(SCENE_MANAGER.SetInUIMode, SCENE_MANAGER, active)
        changed = ok == true or changed
    end
    return changed
end

function L:AcquireUIMode(forceOwnership)
    local active = safe(IsGameCameraUIModeActive, false) == true
    if not active then
        if self:SetUIMode(true) then self.ownsUIMode = true end
    elseif forceOwnership == true then
        -- Used when the Codex hands its UI mode directly to this workspace.
        self.ownsUIMode = true
    end
end

function L:ReleaseUIMode()
    if self.ownsUIMode then self:SetUIMode(false) end
    self.ownsUIMode = false
end

function L:TransferUIModeToCodex()
    local owns = self.ownsUIMode == true
    self.ownsUIMode = false
    return owns
end


function L:UpdateToggleLabels(isOpen)
    isOpen = isOpen == true
    -- OPEN belongs on the launcher controls. CLOSE belongs on the Saved
    -- Loadouts overlay itself, so users never have to hunt another panel to
    -- dismiss the loadout workspace.
    if EPC.Journal and EPC.Journal.suiteSpreads and EPC.Journal.suiteSpreads.GEAR then
        local b = EPC.Journal.suiteSpreads.GEAR.savedLoadoutsButton
        if b and type(b.SetText) == "function" then b:SetText("OPEN BUILDS") end
    end
    if EPC.GearLoadoutOverlay and EPC.GearLoadoutOverlay.playerButton and type(EPC.GearLoadoutOverlay.playerButton.SetText) == "function" then
        EPC.GearLoadoutOverlay.playerButton:SetText(isOpen and "BUILDS OPEN" or "OPEN BUILDS")
    end
    if self.closeLoadoutsButton and type(self.closeLoadoutsButton.SetText) == "function" then
        self.closeLoadoutsButton:SetText("CLOSE BUILDS")
    end
end
function L:Show()
    self:CreateUI()

    -- Keep Live Equipment on screen while Saved Builds is open.
    if EPC.GearLoadoutOverlay and type(EPC.GearLoadoutOverlay.SetLoadoutMode) == "function" then
        EPC.GearLoadoutOverlay:SetLoadoutMode(true)
    end

    -- IMPORTANT: when the Codex was opened from normal gameplay it owns the
    -- UI/cursor mode. Transfer that ownership before hiding the Codex so its
    -- Hide() path does not return control to the character.
    local transferredFromCodex = false
    if EPC.Journal and EPC.Journal.window and not EPC.Journal.window:IsHidden() and type(EPC.Journal.Hide) == "function" then
        transferredFromCodex = EPC.Journal.ownsUIMode == true
        if transferredFromCodex then EPC.Journal.ownsUIMode = false end
        EPC.Journal:Hide()
    end

    self:AcquireUIMode(transferredFromCodex)

    -- A scene change can settle one frame after the Codex hides. Reinforce UI
    -- mode on the next tick without taking ownership when ESO itself already
    -- owned it (inventory, pause menu, etc.).
    if type(zo_callLater) == "function" then
        zo_callLater(function()
            if self.window and not self.window:IsHidden() then
                local active = safe(IsGameCameraUIModeActive, false) == true
                if not active then self:SetUIMode(true) end
            end
        end, 50)
    end

    local s = self:EnsureWindowSaved()
    self:RestoreWindowPlacement(not s.userMoved)
    self:RefreshUI()
    self.window:SetHidden(false)
    self:UpdateToggleLabels(true)

    -- While Saved Builds owns UI mode the normal general keybind can be
    -- swallowed by ESO's UI. Push a dedicated layer that inherits the exact
    -- same Suite toggle binding so pressing that key returns to the Codex.
    if not self.loadoutActionLayerPushed and type(PushActionLayerByName) == "function" then
        local ok = pcall(PushActionLayerByName, "ESOAdventurerSuiteLoadoutLayer")
        if ok then self.loadoutActionLayerPushed = true end
    end
end

function L:Hide(keepUIMode)
    if self.window then self.window:SetHidden(true) end
    self:UpdateToggleLabels(false)
    if self.loadoutActionLayerPushed and type(RemoveActionLayerByName) == "function" then
        pcall(RemoveActionLayerByName, "ESOAdventurerSuiteLoadoutLayer")
        self.loadoutActionLayerPushed = false
    end
    if EPC.GearLoadoutOverlay and type(EPC.GearLoadoutOverlay.SetLoadoutMode) == "function" then
        EPC.GearLoadoutOverlay:SetLoadoutMode(false)
    end
    if keepUIMode ~= true then self:ReleaseUIMode() end
end

function L:Toggle()
    if not self.window or self.window:IsHidden() then self:Show() else self:Hide() end
end

function L:Initialize()
    self:EnsureSaved()
    self:EnsureWindowSaved()
    self:CreateUI()
    SLASH_COMMANDS["/easloadouts"] = function() self:Toggle() end
    SLASH_COMMANDS["/easbuilds"] = function() self:Toggle() end
end
