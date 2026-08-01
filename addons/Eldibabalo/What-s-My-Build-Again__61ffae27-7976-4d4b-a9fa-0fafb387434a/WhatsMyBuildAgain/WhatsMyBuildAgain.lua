local ADDON_NAME = "WhatsMyBuildAgain"
local REFRESH_MS = 1000

local WMBA = {
    name = ADDON_NAME,
    compatibleAddonNames = {
        ["WhatsMyBuildAgain"] = true,
        ["What's My Build Again"] = true,
        ["SuperStar"] = true,
    },
    updateHandle = ADDON_NAME .. "_Update",
    inputHandle = ADDON_NAME .. "_Input",
    closeKeybindAdded = false,
    passiveTrees = {},
    primaryPressed = false,
    negativePressed = false,
    lastPassivesToggleAt = 0,
    lastCloseToggleAt = 0,
    mainKeyHandlerBound = false,
    passivesKeyHandlerBound = false,
    scribingSignatureCache = nil,
    statCache = {},
    cpDisciplineIndex = nil,
    cpDisplayLock = { craft = 3, warfare = 1, fitness = 2 },
    burstHandle = ADDON_NAME .. "_BurstRefresh",
    refreshEventsRegistered = false,
}

local GEAR_ROWS = {
    { slot = EQUIP_SLOT_HEAD, label = "Head" },
    { slot = EQUIP_SLOT_SHOULDERS, label = "Shoulders" },
    { slot = EQUIP_SLOT_CHEST, label = "Chest" },
    { slot = EQUIP_SLOT_HAND, label = "Hands" },
    { slot = EQUIP_SLOT_WAIST, label = "Waist" },
    { slot = EQUIP_SLOT_LEGS, label = "Legs" },
    { slot = EQUIP_SLOT_FEET, label = "Feet" },
    { slot = EQUIP_SLOT_RING1, label = "Ring 1" },
    { slot = EQUIP_SLOT_RING2, label = "Ring 2" },
    { slot = EQUIP_SLOT_NECK, label = "Neck" },
    { slot = EQUIP_SLOT_MAIN_HAND, label = "Main Hand" },
    { slot = EQUIP_SLOT_OFF_HAND, label = "Off Hand" },
    { slot = EQUIP_SLOT_BACKUP_MAIN, label = "Main Hand Backup" },
    { slot = EQUIP_SLOT_BACKUP_OFF, label = "Off-Hand Backup" },
}

-- PS5 client discipline ordering observed in live testing:
-- 1 = Craft, 2 = Warfare, 3 = Fitness
local CP_DISCIPLINE_INDEX = {
    craft = 1,
    warfare = 2,
    fitness = 3,
}

local PRIMARY_ACTION_NAMES = {
    "UI_SHORTCUT_PRIMARY",
    "UI_SHORTCUT_SECONDARY",
    "UI_SHORTCUT_TERTIARY",
}

local NEGATIVE_ACTION_NAMES = {
    "UI_SHORTCUT_NEGATIVE",
    "UI_SHORTCUT_EXIT",
    "UI_SHORTCUT_BACK",
}


local function SafeCall(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a = pcall(fn, ...)
    if ok then return a end
    return nil
end

local function SafeNum(v, fallback)
    local n = tonumber(v)
    if n == nil then return fallback or 0 end
    return n
end

local function SetText(control, value)
    if control then control:SetText(tostring(value or "")) end
end

local function SetIcon(control, iconPath)
    if not control then return end
    if type(iconPath) == "string" and iconPath ~= "" then
        control:SetTexture(iconPath)
        control:SetHidden(false)
    else
        control:SetHidden(true)
    end
end

local function ReadPlayerStatRaw(statType)
    if type(GetPlayerStat) ~= "function" or type(statType) ~= "number" then
        return nil
    end
    local ok, a, b, c = pcall(GetPlayerStat, statType)
    if not ok then
        return nil
    end
    if type(a) == "number" then return a end
    if type(b) == "number" then return b end
    if type(c) == "number" then return c end
    return tonumber(a)
end

local function ReadUnitPowerMaxRaw(powerType)
    if type(GetUnitPowerMax) ~= "function" or type(powerType) ~= "number" then
        return nil
    end
    local ok, v = pcall(GetUnitPowerMax, "player", powerType)
    if ok and type(v) == "number" then
        return v
    end
    return nil
end

local function ReadAttributePoints(attributeType)
    if type(GetAttributeSpentPoints) == "function" and type(attributeType) == "number" then
        return SafeNum(SafeCall(GetAttributeSpentPoints, attributeType), 0)
    end
    return 0
end

function WMBA:GetStableValue(cacheKey, value)
    self.statCache = self.statCache or {}
    local n = tonumber(value)
    if n ~= nil and n >= 0 then
        self.statCache[cacheKey] = n
        return n
    end
    return tonumber(self.statCache[cacheKey]) or 0
end

function WMBA:ClearStatCache()
    self.statCache = {}
    self.cpDisciplineIndex = nil
end

function WMBA:QueueBurstRefresh(durationMs, intervalMs)
    local root = _G["WMBA_Window"]
    local ms = SafeNum(durationMs, 5000)
    local step = SafeNum(intervalMs, 150)
    if type(EVENT_MANAGER) ~= "table" then
        if root and not root:IsHidden() then
            self:RefreshWindow()
        end
        return
    end
    local startedAt = SafeNum(SafeCall(GetFrameTimeMilliseconds), 0)
    local endsAt = startedAt + ms
    EVENT_MANAGER:UnregisterForUpdate(self.burstHandle)
    EVENT_MANAGER:RegisterForUpdate(self.burstHandle, step, function()
        local wnd = _G["WMBA_Window"]
        if not wnd or wnd:IsHidden() then
            EVENT_MANAGER:UnregisterForUpdate(self.burstHandle)
            return
        end
        self:RefreshWindow()
        local now = SafeNum(SafeCall(GetFrameTimeMilliseconds), 0)
        if now >= endsAt then
            EVENT_MANAGER:UnregisterForUpdate(self.burstHandle)
        end
    end)

    -- Trigger one immediate refresh as soon as burst starts.
    if root and not root:IsHidden() then
        self:RefreshWindow()
    end
end

function WMBA:HandleBuildChanged(reason)
    self:ClearStatCache()
    self:QueueBurstRefresh(6000, 150)
end

function WMBA:RegisterOptionalEvent(eventName, callback)
    local eventId = _G[eventName]
    if type(eventId) == "number" then
        EVENT_MANAGER:RegisterForEvent(self.name .. "_" .. eventName, eventId, callback)
    end
end

function WMBA:RegisterReactiveRefreshEvents()
    if self.refreshEventsRegistered then
        return
    end
    self.refreshEventsRegistered = true

    -- Armory-specific hooks (only registered if present on this client build).
    local armoryEvents = {
        "EVENT_ARMORY_BUILD_RESTORE_RESPONSE",
        "EVENT_ARMORY_BUILD_SAVE_RESPONSE",
        "EVENT_ARMORY_BUILD_UPDATED",
        "EVENT_ARMORY_BUILD_CHANGED",
    }
    for _, eventName in ipairs(armoryEvents) do
        self:RegisterOptionalEvent(eventName, function()
            self:HandleBuildChanged(eventName)
        end)
    end

    -- Fallback hooks used when swapping loadouts modifies equipment/weapon bars.
    self:RegisterOptionalEvent("EVENT_ACTIVE_WEAPON_PAIR_CHANGED", function()
        self:HandleBuildChanged("EVENT_ACTIVE_WEAPON_PAIR_CHANGED")
    end)
    self:RegisterOptionalEvent("EVENT_CHAMPION_POINT_UPDATE", function()
        self:HandleBuildChanged("EVENT_CHAMPION_POINT_UPDATE")
    end)
    self:RegisterOptionalEvent("EVENT_PLAYER_ACTIVATED", function()
        self:HandleBuildChanged("EVENT_PLAYER_ACTIVATED")
    end)
    self:RegisterOptionalEvent("EVENT_INVENTORY_SINGLE_SLOT_UPDATE", function(...)
        local args = { ... }
        for _, v in ipairs(args) do
            if v == BAG_WORN then
                self:HandleBuildChanged("EVENT_INVENTORY_SINGLE_SLOT_UPDATE")
                return
            end
        end
    end)
end

local function ToHexColorFromQuality(link, bagId, slotIndex)
    local quality = nil
    if type(GetItemQuality) == "function" and type(bagId) == "number" and type(slotIndex) == "number" then
        quality = GetItemQuality(bagId, slotIndex)
    end
    if quality == nil then quality = SafeCall(GetItemLinkDisplayQuality, link) end
    if quality == nil then quality = SafeCall(GetItemLinkQuality, link) end
    quality = SafeNum(quality, ITEM_QUALITY_NORMAL or 1)

    local qColor = SafeCall(GetItemQualityColor, quality)
    local r, g, b = 0.9, 0.95, 1.0
    if type(qColor) == "table" then
        if type(qColor.UnpackRGB) == "function" then
            local ur, ug, ub = qColor:UnpackRGB()
            r, g, b = SafeNum(ur, r), SafeNum(ug, g), SafeNum(ub, b)
        elseif qColor.r and qColor.g and qColor.b then
            r, g, b = SafeNum(qColor.r, r), SafeNum(qColor.g, g), SafeNum(qColor.b, b)
        end
    end
    return string.format("%02X%02X%02X", math.floor(r * 255 + 0.5), math.floor(g * 255 + 0.5), math.floor(b * 255 + 0.5))
end

local function BuildSetText(itemLink, bagId, slotIndex)
    local hasSet = false
    local numBonuses = 0
    local numNormalEquipped = 0
    local maxEquipped = 0
    local numPerfectedEquipped = 0

    if type(GetItemSetInfo) == "function" and type(bagId) == "number" and type(slotIndex) == "number" then
        local ok1, h1, _, b1, e1, m1 = pcall(GetItemSetInfo, bagId, slotIndex)
        if ok1 then
            hasSet = h1 and true or false
            numBonuses = SafeNum(b1, 0)
            numNormalEquipped = SafeNum(e1, 0)
            maxEquipped = SafeNum(m1, 0)
        end
    end

    if not hasSet and type(GetItemLinkSetInfo) == "function" then
        local ok2, h2, _, b2, e2, m2, _, p2 = pcall(GetItemLinkSetInfo, itemLink, false)
        if not (ok2 and h2) then
            ok2, h2, _, b2, e2, m2, _, p2 = pcall(GetItemLinkSetInfo, itemLink, true)
        end
        if ok2 then
            hasSet = h2 and true or false
            numBonuses = math.max(numBonuses, SafeNum(b2, 0))
            numNormalEquipped = math.max(numNormalEquipped, SafeNum(e2, 0))
            maxEquipped = math.max(maxEquipped, SafeNum(m2, 0))
            numPerfectedEquipped = math.max(numPerfectedEquipped, SafeNum(p2, 0))
        end
    end

    if not hasSet then return "" end
    local eq = SafeNum(numNormalEquipped, 0) + SafeNum(numPerfectedEquipped, 0)
    local mx = SafeNum(maxEquipped, 0)
    if mx <= 0 then
        mx = SafeNum(numBonuses, 0)
    end
    if eq <= 0 or mx <= 0 then return "" end
    return string.format("Set %d/%d", eq, mx)
end

local function BuildRequiredCPSuffix(itemLink)
    local requiredCP = SafeNum(SafeCall(GetItemLinkRequiredChampionPoints, itemLink), 0)
    if requiredCP <= 0 then return "" end
    return string.format(" |cD3D0B6CP%d|r", requiredCP)
end

local function ShortEnchantText(text)
    local s = tostring(text or "")
    if s == "" then return "" end
    s = s:gsub("\n", " ")
    s = s:gsub("^Boon:%s*", "")
    s = s:gsub("^Glyph of%s+", "")
    s = s:gsub("%s+[Oo]f%s+", " ")
    return s
end

local function BuildEnchantText(itemLink)
    if type(GetItemLinkEnchantInfo) ~= "function" then return "" end
    local hasCharges, enchantHeader, enchantDescription = nil, nil, nil
    local ok1, hc, eh, ed = pcall(GetItemLinkEnchantInfo, itemLink)
    if ok1 then
        hasCharges, enchantHeader, enchantDescription = hc, eh, ed
    end
    if (hasCharges == nil and enchantHeader == nil and enchantDescription == nil) and type(GetItemLinkOnUseAbilityInfo) == "function" then
        local ok2, _, h2, d2 = pcall(GetItemLinkOnUseAbilityInfo, itemLink)
        if ok2 then
            enchantHeader = enchantHeader or h2
            enchantDescription = enchantDescription or d2
        end
    end
    local txt = ShortEnchantText(enchantHeader)
    if txt == "" then
        txt = ShortEnchantText(enchantDescription)
    end
    if txt == "" then return "" end
    return txt
end

local function BuildTraitText(itemLink)
    if type(GetItemLinkTraitInfo) ~= "function" then return "" end
    local traitType, traitDescription = SafeCall(GetItemLinkTraitInfo, itemLink)
    local tt = SafeNum(traitType, 0)
    if tt == 0 or tt == SafeNum(_G["ITEM_TRAIT_TYPE_NONE"], -1) or tt == SafeNum(_G["ITEM_TRAIT_TYPE_SPECIAL_STAT"], -2) then
        return ""
    end

    local traitName = ""
    if type(GetString) == "function" then
        traitName = tostring(SafeCall(GetString, "SI_ITEMTRAITTYPE", tt) or "")
    end
    if traitName == "" then
        traitName = tostring(traitDescription or "")
    end
    traitName = traitName:gsub("\n", " "):gsub("^%s+", ""):gsub("%s+$", "")
    if traitName == "" then return "" end
    return traitName
end

local function CritPercentFromRating(rating)
    local r = SafeNum(rating, 0)
    -- SuperStar-like conversion from crit rating to percent display.
    local pct = r / 219.0
    return string.format("%.1f%%", pct)
end

local function CritDamagePercentText()
    local statCandidates = {
        _G["STAT_CRITICAL_DAMAGE"],
        _G["STAT_CRITICAL_DAMAGE_BONUS"],
        _G["STAT_BONUS_CRITICAL_DAMAGE"],
    }
    local raw = 0
    for _, statType in ipairs(statCandidates) do
        if type(statType) == "number" then
            raw = SafeNum(SafeCall(GetPlayerStat, statType), 0)
            if raw > 0 then break end
        end
    end
    -- API can return scaled values depending on client/platform.
    local pct = raw
    if pct <= 0 then
        pct = 50.0
    elseif pct > 1000 then
        pct = pct / 100
    elseif pct > 100 then
        pct = pct / 10
    end
    return string.format("%.1f%%", pct)
end

local function FillChampionSection(root, prefix, disciplineIndex, titleText)
    local total = 0
    local rows = {}
    local skillCount = SafeNum(SafeCall(GetNumChampionDisciplineSkills, disciplineIndex), 0)
    for i = 1, skillCount do
        local skillId = SafeCall(GetChampionSkillId, disciplineIndex, i)
        if skillId then
            local points = SafeNum(SafeCall(GetNumPointsSpentOnChampionSkill, skillId), 0)
            total = total + points
            if points > 0 then
                local rawName = SafeCall(GetChampionSkillName, skillId) or SafeCall(GetAbilityName, skillId) or tostring(skillId)
                if type(zo_strformat) == "function" and type(SI_CHAMPION_STAR_NAME) ~= "nil" and rawName ~= nil then
                    rawName = zo_strformat(SI_CHAMPION_STAR_NAME, rawName)
                end
                if rawName == "?" or rawName == "" then
                    rawName = "Skill " .. tostring(skillId)
                end
                table.insert(rows, { name = tostring(rawName), points = points, id = SafeNum(skillId, 0) })
            end
        end
    end
    table.sort(rows, function(a, b)
        if a.points ~= b.points then
            return a.points > b.points
        end
        local aName = type(zo_strlower) == "function" and zo_strlower(tostring(a.name or "")) or tostring(a.name or "")
        local bName = type(zo_strlower) == "function" and zo_strlower(tostring(b.name or "")) or tostring(b.name or "")
        if aName ~= bName then
            return aName < bName
        end
        return SafeNum(a.id, 0) < SafeNum(b.id, 0)
    end)

    SetText(root:GetNamedChild(prefix .. "Hdr"), string.format("%s %d", titleText, total))
    for i = 1, 4 do
        local label = root:GetNamedChild(prefix .. i)
        local row = rows[i]
        if row then
            local nameText = tostring(row.name or "")
            if string.len(nameText) > 22 then
                nameText = string.sub(nameText, 1, 22) .. "..."
            end
            -- Put points first so they remain visible even when text clips on PS5.
            SetText(label, string.format("%d  %s", row.points, nameText))
        else
            SetText(label, "-")
        end
    end
    return total, #rows
end

local CP_TREE_NAME_ORDER = {
    craft = { "warmount", "breakfall", "disciplineartisan", "fortunesfavor" },
    warfare = { "bulwark", "duelistsrebuff", "focusedmending", "ironclad" },
    fitness = { "boundlessvitality", "bracinganchor", "celerity", "expertevasion" },
}

local CP_NAME_DISPLAY = {
    warmount = "War Mount",
    breakfall = "Breakfall",
    disciplineartisan = "Discipline Artisan",
    fortunesfavor = "Fortune's Favor",
    bulwark = "Bulwark",
    duelistsrebuff = "Duelist's Rebuff",
    focusedmending = "Focused Mending",
    ironclad = "Ironclad",
    boundlessvitality = "Boundless Vitality",
    bracinganchor = "Bracing Anchor",
    celerity = "Celerity",
    expertevasion = "Expert Evasion",
}

local CP_NAME_TREE_LOOKUP = {}
for bucket, names in pairs(CP_TREE_NAME_ORDER) do
    for _, norm in ipairs(names) do
        CP_NAME_TREE_LOOKUP[norm] = bucket
    end
end

local function NormalizeCpName(name)
    local s = tostring(name or "")
    if type(zo_strlower) == "function" then
        s = zo_strlower(s)
    else
        s = string.lower(s)
    end
    s = s:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
    s = s:gsub("[^%w]", "")
    return s
end

local function CollectActiveChampionSlotRows(strictSlotTypeFilter)
    local rows = {}
    if type(GetAssignableChampionBarStartAndEndSlots) ~= "function" then
        return rows
    end
    local barStart, barEnd = SafeCall(GetAssignableChampionBarStartAndEndSlots)
    barStart = SafeNum(barStart, 0)
    barEnd = SafeNum(barEnd, 0)
    if barStart <= 0 or barEnd <= 0 then
        return rows
    end

    local championHotbar = _G["HOTBAR_CATEGORY_CHAMPION"] or 2
    local championActionType = _G["ACTION_TYPE_CHAMPION_SKILL"]
    local strictFilter = (strictSlotTypeFilter ~= false)
    local seen = {}
    for slotIndex = barStart, barEnd do
        local slotType = nil
        if type(GetSlotType) == "function" then
            slotType = SafeCall(GetSlotType, slotIndex, championHotbar)
            if slotType == nil then
                slotType = SafeCall(GetSlotType, slotIndex)
            end
        end
        local isChampionSlot = true
        if strictFilter and championActionType ~= nil and slotType ~= nil and slotType ~= championActionType then
            isChampionSlot = false
        end

        if isChampionSlot then
            local skillId = SafeNum(SafeCall(GetSlotBoundId, slotIndex, championHotbar), 0)
            if skillId <= 0 then
                skillId = SafeNum(SafeCall(GetSlotBoundId, slotIndex), 0)
            end
            if skillId > 0 and not seen[skillId] then
                local points = SafeNum(SafeCall(GetNumPointsSpentOnChampionSkill, skillId), 0)
                if points > 0 then
                    local rawName = SafeCall(GetChampionSkillName, skillId) or SafeCall(GetAbilityName, skillId) or tostring(skillId)
                    if type(zo_strformat) == "function" and type(SI_CHAMPION_STAR_NAME) ~= "nil" and rawName ~= nil then
                        rawName = zo_strformat(SI_CHAMPION_STAR_NAME, rawName)
                    end
                    local reqDiscipline = SafeNum(SafeCall(GetRequiredChampionDisciplineIdForSlot, slotIndex, championHotbar), 0)
                    if reqDiscipline <= 0 then
                        reqDiscipline = SafeNum(SafeCall(GetRequiredChampionDisciplineIdForSlot, slotIndex), 0)
                    end
                    table.insert(rows, {
                        id = skillId,
                        points = points,
                        name = tostring(rawName),
                        norm = NormalizeCpName(rawName),
                        requiredDiscipline = reqDiscipline,
                        slotIndex = slotIndex,
                    })
                    seen[skillId] = true
                end
            end
        end
    end
    return rows
end

local function FillChampionSectionsFromActiveSlots(root, cpMap)
    local buckets = {
        craft = {},
        warfare = {},
        fitness = {},
    }
    local totals = {
        craft = 0,
        warfare = 0,
        fitness = 0,
    }
    local overrideHits = {}

    local activeRows = CollectActiveChampionSlotRows(true)
    if #activeRows == 0 then
        -- PS5 client variants may report slot types that do not match ACTION_TYPE_CHAMPION_SKILL.
        -- Fallback keeps reading from champion bar slots without hard slot-type filtering.
        activeRows = CollectActiveChampionSlotRows(false)
    end
    for _, row in ipairs(activeRows) do
        local bucket = CP_NAME_TREE_LOOKUP[row.norm]
        if bucket then
            table.insert(overrideHits, string.format("%s -> %s", row.name, bucket))
        else
            if row.requiredDiscipline == SafeNum(cpMap.craft, 0) then
                bucket = "craft"
            elseif row.requiredDiscipline == SafeNum(cpMap.warfare, 0) then
                bucket = "warfare"
            elseif row.requiredDiscipline == SafeNum(cpMap.fitness, 0) then
                bucket = "fitness"
            end
        end
        if bucket and buckets[bucket] then
            table.insert(buckets[bucket], row)
            totals[bucket] = totals[bucket] + SafeNum(row.points, 0)
        end
    end

    local function render(prefix, title, bucketName)
        local rows = buckets[bucketName] or {}
        table.sort(rows, function(a, b)
            if a.points ~= b.points then
                return a.points > b.points
            end
            return tostring(a.name or "") < tostring(b.name or "")
        end)
        SetText(root:GetNamedChild(prefix .. "Hdr"), string.format("%s %d", title, SafeNum(totals[bucketName], 0)))
        for i = 1, 4 do
            local label = root:GetNamedChild(prefix .. i)
            local row = rows[i]
            if row then
                local nameText = tostring(row.name or "")
                if string.len(nameText) > 22 then
                    nameText = string.sub(nameText, 1, 22) .. "..."
                end
                SetText(label, string.format("%d  %s", SafeNum(row.points, 0), nameText))
            else
                SetText(label, "-")
            end
        end
    end

    render("CPCraft", "Craft", "craft")
    render("CPWarfare", "Warfare", "warfare")
    render("CPFitness", "Fitness", "fitness")
    return overrideHits
end

local function BuildChampionSkillDisplayDisciplineMap(numDisciplines)
    local map = {}
    local disciplines = SafeNum(numDisciplines, 0)
    if disciplines <= 0 then
        disciplines = SafeNum(SafeCall(GetNumChampionDisciplines), 0)
    end
    if disciplines <= 0 then
        return map
    end

    -- Direct pass: skill belongs to its real discipline index.
    for displayIndex = 1, disciplines do
        local skillCount = SafeNum(SafeCall(GetNumChampionDisciplineSkills, displayIndex), 0)
        for i = 1, skillCount do
            local skillId = SafeNum(SafeCall(GetChampionSkillId, displayIndex, i), 0)
            if skillId > 0 then
                map[skillId] = displayIndex
            end
        end
    end

    return map
end

local function CollectSlottedChampionRowsForDiscipline(disciplineIndex, skillToDisciplineMap)
    local rows = {}
    if type(GetAssignableChampionBarStartAndEndSlots) ~= "function" then
        return rows, 0
    end
    if type(GetSlotBoundId) ~= "function" then
        return rows, 0
    end
    if type(GetNumPointsSpentOnChampionSkill) ~= "function" then
        return rows, 0
    end

    local barStart, barEnd = SafeCall(GetAssignableChampionBarStartAndEndSlots)
    barStart = SafeNum(barStart, 0)
    barEnd = SafeNum(barEnd, 0)
    if barStart <= 0 or barEnd <= 0 then
        return rows, 0
    end

    local seen = {}
    local total = 0
    local championHotbar = _G["HOTBAR_CATEGORY_CHAMPION"] or 2
    for slotIndex = barStart, barEnd do
        local skillId = SafeNum(SafeCall(GetSlotBoundId, slotIndex, championHotbar), 0)
        if skillId <= 0 then
            -- Fallback signature.
            skillId = SafeNum(SafeCall(GetSlotBoundId, slotIndex), 0)
        end
        if skillId > 0 and not seen[skillId] then
            local mappedDiscipline = type(skillToDisciplineMap) == "table" and skillToDisciplineMap[skillId] or nil
            local belongsToRequested = false
            if mappedDiscipline ~= nil then
                belongsToRequested = (mappedDiscipline == disciplineIndex)
            elseif type(GetRequiredChampionDisciplineIdForSlot) == "function" then
                local reqDiscipline = SafeNum(SafeCall(GetRequiredChampionDisciplineIdForSlot, slotIndex, championHotbar), 0)
                if reqDiscipline <= 0 then
                    reqDiscipline = SafeNum(SafeCall(GetRequiredChampionDisciplineIdForSlot, slotIndex), 0)
                end
                belongsToRequested = (reqDiscipline == disciplineIndex)
            end

            if belongsToRequested then
                local points = SafeNum(SafeCall(GetNumPointsSpentOnChampionSkill, skillId), 0)
                if points > 0 then
                    local rawName = SafeCall(GetChampionSkillName, skillId) or SafeCall(GetAbilityName, skillId) or ("Skill " .. tostring(skillId))
                    if type(zo_strformat) == "function" and type(SI_CHAMPION_STAR_NAME) ~= "nil" and rawName ~= nil then
                        rawName = zo_strformat(SI_CHAMPION_STAR_NAME, rawName)
                    end
                    table.insert(rows, {
                        name = tostring(rawName),
                        points = points,
                        id = skillId,
                    })
                    seen[skillId] = true
                    total = total + points
                end
            end
        end
    end

    table.sort(rows, function(a, b)
        local aId = SafeNum(a.id, 0)
        local bId = SafeNum(b.id, 0)
        return aId < bId
    end)
    return rows, total
end

local function FillChampionSectionSlottedFirst(root, prefix, disciplineIndex, titleText, skillToDisciplineMap)
    local slottedRows, slottedTotal = CollectSlottedChampionRowsForDiscipline(disciplineIndex, skillToDisciplineMap)
    if #slottedRows > 0 then
        SetText(root:GetNamedChild(prefix .. "Hdr"), string.format("%s %d", titleText, slottedTotal))
        for i = 1, 4 do
            local label = root:GetNamedChild(prefix .. i)
            local row = slottedRows[i]
            if row then
                local nameText = tostring(row.name or "")
                if string.len(nameText) > 22 then
                    nameText = string.sub(nameText, 1, 22) .. "..."
                end
                SetText(label, string.format("%d  %s", SafeNum(row.points, 0), nameText))
            else
                SetText(label, "-")
            end
        end
        return slottedTotal, #slottedRows
    end
    return FillChampionSection(root, prefix, disciplineIndex, titleText)
end

local function FillChampionSectionWithRotationFallback(root, prefix, disciplineIndex, titleText, skillToDisciplineMap)
    local total, count = FillChampionSectionSlottedFirst(root, prefix, disciplineIndex, titleText, skillToDisciplineMap)
    if SafeNum(count, 0) > 0 then
        return total, count
    end

    return FillChampionSection(root, prefix, disciplineIndex, titleText)
end

local function BuildChampionDisciplineMap()
    local resolved = {}

    local numDisciplines = SafeNum(SafeCall(GetNumChampionDisciplines), 0)
    if numDisciplines <= 0 then
        return resolved
    end

    for i = 1, numDisciplines do
        local rawName = type(GetChampionDisciplineName) == "function" and tostring(SafeCall(GetChampionDisciplineName, i) or "") or ""
        local name = type(zo_strlower) == "function" and zo_strlower(rawName) or string.lower(rawName)
        if name:find("craft", 1, true) then
            resolved.craft = i
        elseif name:find("warfare", 1, true) or name:find("combat", 1, true) then
            resolved.warfare = i
        elseif name:find("fitness", 1, true) or name:find("condition", 1, true) then
            resolved.fitness = i
        end
    end

    -- Final fallback to legacy PS5 ordering if one entry is still unresolved.
    resolved.craft = resolved.craft or CP_DISCIPLINE_INDEX.craft
    resolved.warfare = resolved.warfare or CP_DISCIPLINE_INDEX.warfare
    resolved.fitness = resolved.fitness or CP_DISCIPLINE_INDEX.fitness

    return resolved
end

local function GetAbilityOrItemIcon(slotIndex, hotbarCategory)
    local slotTexture = SafeCall(GetSlotTexture, slotIndex, hotbarCategory)
    if type(slotTexture) == "string" and slotTexture ~= "" then
        return slotTexture
    end
    local bound = SafeCall(GetSlotBoundId, slotIndex, hotbarCategory)
    if type(bound) == "number" and bound > 0 then
        return SafeCall(GetAbilityIcon, bound)
    end
    if type(bound) == "string" and bound ~= "" then
        return bound
    end
    return nil
end

local function GetWeaponIcon(mainSlot, offSlot)
    local mainLink = SafeCall(GetItemLink, BAG_WORN, mainSlot)
    if type(mainLink) == "string" and mainLink ~= "" then
        local mainIcon = SafeCall(GetItemLinkIcon, mainLink)
        if type(mainIcon) == "string" and mainIcon ~= "" then return mainIcon end
    end
    local offLink = SafeCall(GetItemLink, BAG_WORN, offSlot)
    if type(offLink) == "string" and offLink ~= "" then
        local offIcon = SafeCall(GetItemLinkIcon, offLink)
        if type(offIcon) == "string" and offIcon ~= "" then return offIcon end
    end
    return nil
end

local function IsNegativeCloseKey(keyCode)
    if keyCode == nil then return false end
    local candidates = {
        134, -- PS5 observed Circle/Back keycode
        _G.KEY_GAMEPAD_BUTTON_2,
        _G.KEY_GAMEPAD_CIRCLE,
        _G.KEY_GAMEPAD_BACK,
        _G.KEY_ESCAPE,
    }
    for _, candidate in ipairs(candidates) do
        if type(candidate) == "number" and keyCode == candidate then
            return true
        end
    end
    return false
end

local function IsPrimaryToggleKey(keyCode)
    if keyCode == nil then return false end
    local candidates = {
        133, -- PS5 observed X/Cross keycode
        _G.KEY_GAMEPAD_BUTTON_1,
        _G.KEY_GAMEPAD_CROSS,
        _G.KEY_GAMEPAD_X,
    }
    for _, candidate in ipairs(candidates) do
        if type(candidate) == "number" and keyCode == candidate then
            return true
        end
    end
    return false
end

local function IsAnyActionPressed(actionNames)
    if type(IsActionPressed) ~= "function" then return false, nil end
    for _, actionName in ipairs(actionNames or {}) do
        local pressed = SafeCall(IsActionPressed, actionName)
        if pressed then
            return true, actionName
        end
    end
    return false, nil
end

local function GetNowMs()
    if type(GetFrameTimeMilliseconds) == "function" then
        return SafeNum(SafeCall(GetFrameTimeMilliseconds), 0)
    end
    return 0
end

local function IsDebounced(lastAt, cooldownMs)
    local now = GetNowMs()
    if now <= 0 then return false, now end
    if (now - SafeNum(lastAt, 0)) < SafeNum(cooldownMs, 0) then
        return true, now
    end
    return false, now
end

function WMBA:HandlePrimaryRequest()
    local root = _G["WMBA_Window"]
    local pw = _G["WMBA_PassivesWindow"]
    local mainOpen = root and not root:IsHidden()
    local passivesOpen = pw and not pw:IsHidden()
    if not mainOpen and not passivesOpen then return false end
    local blocked, now = IsDebounced(self.lastPassivesToggleAt, 220)
    if blocked then return true end
    self.lastPassivesToggleAt = now
    self:TogglePassivesView()
    return true
end

function WMBA:HandleNegativeRequest()
    local root = _G["WMBA_Window"]
    local pw = _G["WMBA_PassivesWindow"]
    local mainOpen = root and not root:IsHidden()
    local passivesOpen = pw and not pw:IsHidden()
    if not mainOpen and not passivesOpen then return false end
    local blocked, now = IsDebounced(self.lastCloseToggleAt, 220)
    if blocked then return true end
    self.lastCloseToggleAt = now
    if passivesOpen then
        pw:SetHidden(true)
        if root then
            root:SetHidden(false)
        end
        self:RefreshWindow()
    else
        self:ToggleWindow()
    end
    return true
end

function WMBA:HandleInputKey(keyCode)
    if IsNegativeCloseKey(keyCode) then
        return self:HandleNegativeRequest()
    end
    if IsPrimaryToggleKey(keyCode) then
        return self:HandlePrimaryRequest()
    end
    return false
end

function WMBA:SafeHandleInputKey(keyCode)
    local ok, handled = pcall(function()
        return self:HandleInputKey(keyCode)
    end)
    if not ok then
        -- Swallow key-handler faults to prevent PS5 UI error popup loops.
        return true
    end
    return handled and true or false
end

local function GetSkillLineDisplayName(skillType, skillLineIndex)
    local lsf = _G["LSF"] or _G["LibSkillsFactory"]
    if type(lsf) == "table" and type(lsf.GetSkillLineName) == "function" then
        local lsfName = SafeCall(lsf.GetSkillLineName, lsf, skillType, skillLineIndex)
        if type(lsfName) == "string" and lsfName ~= "" then
            if type(zo_strformat) == "function" and type(SI_SKILLS_ENTRY_NAME_FORMAT) ~= "nil" then
                return zo_strformat(SI_SKILLS_ENTRY_NAME_FORMAT, lsfName)
            end
            return lsfName
        end
    end

    if type(GetSkillLineId) == "function" and type(GetSkillLineNameById) == "function" then
        local skillLineId = SafeNum(SafeCall(GetSkillLineId, skillType, skillLineIndex), 0)
        if skillLineId > 0 then
            local byIdName = SafeCall(GetSkillLineNameById, skillLineId)
            if type(byIdName) == "string" and byIdName ~= "" then
                if type(zo_strformat) == "function" and type(SI_SKILLS_ENTRY_NAME_FORMAT) ~= "nil" then
                    return zo_strformat(SI_SKILLS_ENTRY_NAME_FORMAT, byIdName)
                end
                return byIdName
            end
        end
    end

    local raw = nil
    if type(GetSkillLineDynamicInfo) == "function" then
        local ok, a, b, c, d = pcall(GetSkillLineDynamicInfo, skillType, skillLineIndex)
        if ok then
            if type(a) == "string" and a ~= "" then raw = a
            elseif type(b) == "string" and b ~= "" then raw = b
            elseif type(c) == "string" and c ~= "" then raw = c
            elseif type(d) == "string" and d ~= "" then raw = d end
        end
    end
    if (raw == nil or raw == "") and type(GetSkillLineInfo) == "function" then
        local ok, a, b, c, d, e = pcall(GetSkillLineInfo, skillType, skillLineIndex)
        if ok then
            if type(a) == "string" and a ~= "" then raw = a
            elseif type(b) == "string" and b ~= "" then raw = b
            elseif type(c) == "string" and c ~= "" then raw = c
            elseif type(d) == "string" and d ~= "" then raw = d
            elseif type(e) == "string" and e ~= "" then raw = e end
        end
    end
    if type(raw) ~= "string" or raw == "" then
        return string.format("SkillType %d / Line %d", SafeNum(skillType, 0), SafeNum(skillLineIndex, 0))
    end
    if type(zo_strformat) == "function" and type(SI_SKILLS_ENTRY_NAME_FORMAT) ~= "nil" then
        return zo_strformat(SI_SKILLS_ENTRY_NAME_FORMAT, raw)
    end
    return raw
end

local function GetAbilitySpentPoints(skillType, skillLineIndex, abilityIndex)
    if type(GetSkillAbilityInfo) ~= "function" then return nil end
    local ok, abilityName, abilityIcon, _, isPassive, _, isPurchased, progressionIndex = pcall(GetSkillAbilityInfo, skillType, skillLineIndex, abilityIndex)
    if not ok then return nil end
    if (type(abilityIcon) ~= "string" or abilityIcon == "") and type(GetSkillAbilityId) == "function" and type(GetAbilityIcon) == "function" then
        local abilityId = SafeNum(SafeCall(GetSkillAbilityId, skillType, skillLineIndex, abilityIndex, true), 0)
        if abilityId <= 0 then
            abilityId = SafeNum(SafeCall(GetSkillAbilityId, skillType, skillLineIndex, abilityIndex), 0)
        end
        if abilityId > 0 then
            abilityIcon = SafeCall(GetAbilityIcon, abilityId)
        end
    end
    if not isPurchased then return 0, isPassive, abilityName, abilityIcon end

    local spentIn = 0
    if progressionIndex and type(GetAbilityProgressionInfo) == "function" then
        local okProg, _, morph = pcall(GetAbilityProgressionInfo, progressionIndex)
        if okProg then
            spentIn = math.min(SafeNum(morph, 0) + 1, 2)
        end
    else
        if type(GetSkillAbilityUpgradeInfo) == "function" then
            local okPassive, passiveLevel = pcall(GetSkillAbilityUpgradeInfo, skillType, skillLineIndex, abilityIndex)
            if okPassive then
                spentIn = SafeNum(passiveLevel, 1)
            else
                spentIn = 1
            end
        else
            spentIn = 1
        end
    end

    if type(IsSkillAbilityAutoGrant) == "function" then
        local okAuto, isAuto = pcall(IsSkillAbilityAutoGrant, skillType, skillLineIndex, abilityIndex)
        if okAuto and isAuto then
            spentIn = spentIn - 1
        end
    end

    if spentIn < 0 then spentIn = 0 end
    return spentIn, isPassive, abilityName, abilityIcon
end

local function CollectSkillSpendAndPassives()
    local spentPoints = 0
    local passiveTrees = {}

    local maxSkillTypes = math.max(
        SafeNum(_G["SKILLTYPES_IN_SKILLBUILDER"], 0),
        SafeNum(SafeCall(GetNumSkillTypes), 0)
    )
    if maxSkillTypes <= 0 then
        maxSkillTypes = 12
    end

    for skillType = 1, maxSkillTypes do
        local numLines = SafeNum(SafeCall(GetNumSkillLines, skillType), 0)
        for skillLineIndex = 1, numLines do
            local lineName = GetSkillLineDisplayName(skillType, skillLineIndex)
            local lineRows = {}
            local numAbilities = SafeNum(SafeCall(GetNumSkillAbilities, skillType, skillLineIndex), 0)
            for abilityIndex = 1, numAbilities do
                local spentIn, isPassive, abilityName, abilityIcon = GetAbilitySpentPoints(skillType, skillLineIndex, abilityIndex)
                if spentIn and spentIn > 0 then
                    spentPoints = spentPoints + spentIn
                    if isPassive then
                        local rawName = tostring(abilityName or "")
                        if rawName == "" or rawName == "?" then
                            rawName = string.format("Passive %d", abilityIndex)
                        end
                        table.insert(lineRows, {
                            name = rawName,
                            points = spentIn,
                            icon = abilityIcon,
                        })
                    end
                end
            end
            if #lineRows > 0 then
                table.insert(passiveTrees, {
                    name = tostring(lineName),
                    rows = lineRows,
                })
            end
        end
    end

    return spentPoints, passiveTrees
end

local function BuildPassiveColumns(passiveTrees)
    local columns = { {}, {}, {} }
    local currentCol = 1
    local currentLines = 0
    local maxLines = 40

    for _, tree in ipairs(passiveTrees or {}) do
        local rows = tree.rows or {}
        local needed = 1 + #rows
        if currentLines + needed > maxLines and currentCol < 3 then
            currentCol = currentCol + 1
            currentLines = 0
        end
        table.insert(columns[currentCol], string.format("|cE3D39B%s|r", tostring(tree.name or "Unknown Tree")))
        currentLines = currentLines + 1
        for _, row in ipairs(rows) do
            local text = tostring(row.name or "")
            if string.len(text) > 36 then
                text = string.sub(text, 1, 36) .. "..."
            end
            local iconTag = ""
            if type(row.icon) == "string" and row.icon ~= "" then
                iconTag = string.format("|t16:16:%s|t ", row.icon)
            end
            table.insert(columns[currentCol], string.format("%d  %s%s", SafeNum(row.points, 0), iconTag, text))
            currentLines = currentLines + 1
        end
    end

    for i = 1, 3 do
        if #columns[i] == 0 then
            columns[i][1] = "-"
        end
    end
    return table.concat(columns[1], "\n"), table.concat(columns[2], "\n"), table.concat(columns[3], "\n")
end

local function BuildAvaRankText(rank)
    local rankNum = SafeNum(rank, 0)
    local rankName = nil
    if type(GetAvARankName) == "function" then
        local gender = 0
        if type(GetUnitGender) == "function" then
            gender = SafeNum(SafeCall(GetUnitGender, "player"), 0)
        end
        rankName = SafeCall(GetAvARankName, gender, rankNum)
    end
    if type(rankName) == "string" and rankName ~= "" then
        if type(zo_strformat) == "function" and type(SI_STAT_RANK_NAME_FORMAT) ~= "nil" then
            return zo_strformat(SI_STAT_RANK_NAME_FORMAT, rankName)
        end
        return string.format("%s %d", rankName, rankNum)
    end
    return tostring(rankNum)
end

local MUNDUS_BOONS = {
    [13940] = true, -- Warrior
    [13943] = true, -- Mage
    [13974] = true, -- Serpent
    [13975] = true, -- Thief
    [13976] = true, -- Lady
    [13977] = true, -- Steed
    [13978] = true, -- Lord
    [13979] = true, -- Apprentice
    [13980] = true, -- Ritual
    [13981] = true, -- Lover
    [13982] = true, -- Atronach
    [13984] = true, -- Shadow
    [13985] = true, -- Tower
}

local function BuildMundusText()
    if type(GetPlayerActiveMundusStone) == "function" then
        local stoneIndex = SafeNum(SafeCall(GetPlayerActiveMundusStone), 0)
        if stoneIndex > 0 and type(GetString) == "function" then
            local stoneName = SafeCall(GetString, "SI_MUNDUSSTONE", stoneIndex)
            if type(stoneName) == "string" and stoneName ~= "" then
                return stoneName
            end
        end
    end

    if type(GetNumBuffs) ~= "function" or type(GetUnitBuffInfo) ~= "function" then
        return "-"
    end
    local numBuffs = SafeNum(SafeCall(GetNumBuffs, "player"), 0)
    local boons = {}
    for i = 1, numBuffs do
        local abilityId = nil
        local ok, _, _, _, _, _, _, _, _, _, _, aid = pcall(GetUnitBuffInfo, "player", i)
        if ok then
            abilityId = aid
        end
        if MUNDUS_BOONS[SafeNum(abilityId, 0)] then
            local boonName = SafeCall(GetAbilityName, abilityId)
            if type(boonName) == "string" and boonName ~= "" then
                if type(zo_strformat) == "function" and type(SI_ABILITY_TOOLTIP_NAME) ~= "nil" then
                    boonName = zo_strformat(SI_ABILITY_TOOLTIP_NAME, boonName)
                end
                table.insert(boons, tostring(boonName))
            end
        elseif type(GetAbilityName) == "function" then
            local fallbackName = tostring(SafeCall(GetAbilityName, abilityId) or "")
            if fallbackName:find("Boon", 1, true) then
                table.insert(boons, fallbackName)
            end
        end
    end
    if #boons == 0 then return "-" end
    if #boons == 1 then return boons[1] end
    return string.format("%s / %s", boons[1], boons[2])
end

local function NormalizeText(s)
    local t = tostring(s or ""):lower()
    t = t:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
    t = t:gsub("[%p%c%s]+", "")
    return t
end

local function BuildScribingSignatureCache()
    if WMBA.scribingSignatureCache then return WMBA.scribingSignatureCache end
    local cache = {}
    local maxId = SafeNum(SafeCall(GetMaxCraftedAbilityScriptId), 0)
    if maxId <= 0 then
        WMBA.scribingSignatureCache = cache
        return cache
    end
    local signatureSlot = _G["SCRIBING_SLOT_SIGNATURE"] or 2
    for scriptId = 1, maxId do
        local slot = SafeNum(SafeCall(GetCraftedAbilityScriptScribingSlot, scriptId), -1)
        if slot == signatureSlot then
            local name = SafeCall(GetCraftedAbilityScriptDisplayName, scriptId)
            if type(name) == "string" and name ~= "" then
                table.insert(cache, { id = scriptId, name = name, norm = NormalizeText(name) })
            end
        end
    end
    WMBA.scribingSignatureCache = cache
    return cache
end

local function ResolveCraftedAbilityId(abilityId)
    local id = SafeNum(abilityId, 0)
    if id <= 0 then return 0 end

    local resolverNames = {
        "GetCraftedAbilityIdFromAbilityId",
        "GetCraftedAbilityIdForAbilityId",
        "GetCraftedAbilityIdByAbilityId",
    }
    for _, fnName in ipairs(resolverNames) do
        local fn = _G[fnName]
        if type(fn) == "function" then
            local resolved = SafeNum(SafeCall(fn, id), 0)
            if resolved > 0 then
                return resolved
            end
        end
    end

    if type(GetSkillTypeForCraftedAbilityId) == "function" then
        local st = SafeNum(SafeCall(GetSkillTypeForCraftedAbilityId, id), 0)
        if st ~= SafeNum(_G["SKILL_TYPE_NONE"], 0) and st > 0 then
            return id
        end
    end
    return 0
end

local function CollectActiveScribingSignatureRows()
    if type(GetCraftedAbilityScriptDisplayName) ~= "function" or type(GetSlotBoundId) ~= "function" then
        return {}
    end

    local cache = BuildScribingSignatureCache()
    if #cache == 0 then return {} end

    local rows = {}
    local seen = {}
    local bars = { HOTBAR_CATEGORY_PRIMARY, HOTBAR_CATEGORY_BACKUP }
    for _, hotbar in ipairs(bars) do
        for slot = 3, 8 do
            local abilityId = SafeNum(SafeCall(GetSlotBoundId, slot, hotbar), 0)
            if abilityId > 0 then
                local craftedAbilityId = ResolveCraftedAbilityId(abilityId)
                if craftedAbilityId > 0 then
                    local abilityName = tostring(SafeCall(GetAbilityName, abilityId) or ("Ability " .. tostring(abilityId)))
                    local abilityDesc = tostring(SafeCall(GetAbilityDescription, abilityId) or "")
                    local normDesc = NormalizeText(abilityDesc)
                    local signatures = {}
                    for _, sc in ipairs(cache) do
                        local compatible = true
                        if type(IsCraftedAbilityScriptCompatibleWithSelections) == "function" then
                            compatible = SafeCall(IsCraftedAbilityScriptCompatibleWithSelections, sc.id, craftedAbilityId) and true or false
                        end
                        if compatible and sc.norm ~= "" and normDesc:find(sc.norm, 1, true) then
                            table.insert(signatures, sc.name)
                        end
                    end
                    if #signatures > 0 then
                        local key = abilityName .. "::" .. table.concat(signatures, "|")
                        if not seen[key] then
                            seen[key] = true
                            table.insert(rows, string.format("%s: %s", abilityName, table.concat(signatures, ", ")))
                        end
                    end
                end
            end
        end
    end
    return rows
end

function WMBA:RefreshPassivesWindow(passiveTrees)
    local pw = _G["WMBA_PassivesWindow"]
    if not pw or pw:IsHidden() then return end
    pw:SetAlpha(1)
    local bg = pw:GetNamedChild("BG")
    if bg then
        bg:SetAlpha(1)
        if type(bg.SetColor) == "function" then
            bg:SetColor(0, 0, 0, 1)
        end
    end
    local frame = pw:GetNamedChild("Frame")
    if frame and type(frame.SetCenterColor) == "function" then
        frame:SetCenterColor(0, 0, 0, 1)
    end

    local col1, col2, col3 = BuildPassiveColumns(passiveTrees)
    SetText(pw:GetNamedChild("Column1"), col1)
    SetText(pw:GetNamedChild("Column2"), col2)
    SetText(pw:GetNamedChild("Column3"), col3)
    SetText(pw:GetNamedChild("Title"), string.format("PASSIVES (%d TREES)", #(passiveTrees or {})))
end

function WMBA:PollGamepadActions()
    local root = _G["WMBA_Window"]
    local pw = _G["WMBA_PassivesWindow"]
    local mainOpen = root and not root:IsHidden()
    local passivesOpen = pw and not pw:IsHidden()
    if not mainOpen and not passivesOpen then
        self.primaryPressed = false
        self.negativePressed = false
        return
    end

    local negativeDown = IsAnyActionPressed(NEGATIVE_ACTION_NAMES)
    self.primaryPressed = false

    if negativeDown and not self.negativePressed then
        pcall(function()
            self:HandleNegativeRequest()
        end)
    end
    self.negativePressed = negativeDown
end

local function EnsureOpaqueWindow(root)
    if not root then return end
    root:SetAlpha(1)
    local bg = root:GetNamedChild("BG")
    if bg then
        bg:SetAlpha(1)
        if type(bg.SetColor) == "function" then
            bg:SetColor(0, 0, 0, 1)
        end
    end
    local tr = root:GetNamedChild("TopRightOpaqueBG")
    if tr then
        tr:SetAlpha(1)
        if type(tr.SetColor) == "function" then
            tr:SetColor(0, 0, 0, 1)
        end
    end
    local frame = root:GetNamedChild("Frame")
    if frame and type(frame.SetCenterColor) == "function" then
        frame:SetCenterColor(0, 0, 0, 1)
    end
end

function WMBA:RefreshWindow()
    local root = _G["WMBA_Window"]
    if not root then return end
    EnsureOpaqueWindow(root)

    local level = SafeNum(SafeCall(GetUnitLevel, "player"), 0)
    local cpRank = SafeNum(SafeCall(GetUnitChampionPoints, "player"), 0)
    local className = SafeCall(GetUnitClass, "player") or "Unknown Class"
    local raceName = SafeCall(GetUnitRace, "player") or "Unknown Race"
    local avaRank = SafeNum(SafeCall(GetUnitAvARank, "player"), 0)
    local spentSkillPoints, passiveTrees = CollectSkillSpendAndPassives()

    local levelText = cpRank > 0 and string.format("CP %d", cpRank) or string.format("Lv %d", level)
    SetText(root:GetNamedChild("LevelValue"), levelText)
    SetText(root:GetNamedChild("ClassRaceValue"), string.format("%s / %s", tostring(raceName), tostring(className)))
    SetText(root:GetNamedChild("AvaRankValue"), BuildAvaRankText(avaRank))
    SetText(root:GetNamedChild("MundusValue"), BuildMundusText())
    SetText(root:GetNamedChild("NameTop"), tostring(SafeCall(GetUnitName, "player") or "-"))
    SetText(root:GetNamedChild("SkillPointsLabel"), "Skill Spent")
    SetText(root:GetNamedChild("SkillPointsValue"), spentSkillPoints)
    local scribingRows = CollectActiveScribingSignatureRows()
    SetText(root:GetNamedChild("ScribingHdr"), "Scribing Signatures")
    for i = 1, 3 do
        local row = scribingRows[i]
        if row then
            SetText(root:GetNamedChild("ScribingRow" .. i), row)
        else
            SetText(root:GetNamedChild("ScribingRow" .. i), "-")
        end
    end
    local cpLabel = root:GetNamedChild("ChampionPointsLabel")
    local cpValue = root:GetNamedChild("ChampionPointsValue")
    if cpLabel then cpLabel:SetHidden(true) end
    if cpValue then cpValue:SetHidden(true) end

    local magMax = ReadUnitPowerMaxRaw(_G["POWERTYPE_MAGICKA"]) or ReadPlayerStatRaw(STAT_MAGICKA_MAX)
    local hpMax = ReadUnitPowerMaxRaw(_G["POWERTYPE_HEALTH"]) or ReadPlayerStatRaw(STAT_HEALTH_MAX)
    local stamMax = ReadUnitPowerMaxRaw(_G["POWERTYPE_STAMINA"]) or ReadPlayerStatRaw(STAT_STAMINA_MAX)
    local magAttr = ReadAttributePoints(_G["ATTRIBUTE_MAGICKA"])
    local hpAttr = ReadAttributePoints(_G["ATTRIBUTE_HEALTH"])
    local stamAttr = ReadAttributePoints(_G["ATTRIBUTE_STAMINA"])
    local magRegen = ReadPlayerStatRaw(STAT_MAGICKA_REGEN_COMBAT)
    local hpRegen = ReadPlayerStatRaw(STAT_HEALTH_REGEN_COMBAT)
    local stamRegen = ReadPlayerStatRaw(STAT_STAMINA_REGEN_COMBAT)

    SetText(root:GetNamedChild("MagLabel"), SafeNum(magAttr, 0))
    SetText(root:GetNamedChild("HpLabel"), SafeNum(hpAttr, 0))
    SetText(root:GetNamedChild("StamLabel"), SafeNum(stamAttr, 0))
    SetText(root:GetNamedChild("MagValue"), SafeNum(magMax, 0))
    SetText(root:GetNamedChild("HpValue"), SafeNum(hpMax, 0))
    SetText(root:GetNamedChild("StamValue"), SafeNum(stamMax, 0))
    SetText(root:GetNamedChild("MagRegenValue"), SafeNum(magRegen, 0))
    SetText(root:GetNamedChild("HpRegenValue"), SafeNum(hpRegen, 0))
    SetText(root:GetNamedChild("StamRegenValue"), SafeNum(stamRegen, 0))

    local dmgMag = SafeNum(ReadPlayerStatRaw(STAT_SPELL_POWER), 0)
    local dmgStam = SafeNum(ReadPlayerStatRaw(STAT_POWER), 0)
    local critMagRating = SafeNum(ReadPlayerStatRaw(STAT_SPELL_CRITICAL), 0)
    local critStamRating = SafeNum(ReadPlayerStatRaw(STAT_CRITICAL_STRIKE), 0)
    local critMag = CritPercentFromRating(critMagRating)
    local critStam = CritPercentFromRating(critStamRating)
    local critDamage = CritDamagePercentText()
    local peneMag = critDamage
    local peneStam = critDamage
    local resistMag = SafeNum(ReadPlayerStatRaw(STAT_SPELL_RESIST), 0)
    local resistStam = SafeNum(ReadPlayerStatRaw(STAT_PHYSICAL_RESIST), 0)

    SetText(root:GetNamedChild("DmgMagValue"), dmgMag)
    SetText(root:GetNamedChild("DmgStamValue"), dmgStam)
    SetText(root:GetNamedChild("CritMagValue"), critMag)
    SetText(root:GetNamedChild("CritStamValue"), critStam)
    SetText(root:GetNamedChild("PeneMagValue"), peneMag)
    SetText(root:GetNamedChild("PeneStamValue"), peneStam)
    SetText(root:GetNamedChild("ResMagValue"), resistMag)
    SetText(root:GetNamedChild("ResStamValue"), resistStam)

    SetIcon(root:GetNamedChild("PrimaryWeapon"), GetWeaponIcon(EQUIP_SLOT_MAIN_HAND, EQUIP_SLOT_OFF_HAND))
    SetIcon(root:GetNamedChild("BackupWeapon"), GetWeaponIcon(EQUIP_SLOT_BACKUP_MAIN, EQUIP_SLOT_BACKUP_OFF))

    for i = 1, 6 do
        SetIcon(root:GetNamedChild("PrimarySkill" .. i), GetAbilityOrItemIcon(i + 2, HOTBAR_CATEGORY_PRIMARY))
        SetIcon(root:GetNamedChild("BackupSkill" .. i), GetAbilityOrItemIcon(i + 2, HOTBAR_CATEGORY_BACKUP))
    end

    for i, entry in ipairs(GEAR_ROWS) do
        local row = root:GetNamedChild("GearRow" .. i)
        local meta = root:GetNamedChild("GearMeta" .. i)
        local icon = root:GetNamedChild("GearIcon" .. i)
        if row then
            local link = SafeCall(GetItemLink, BAG_WORN, entry.slot)
            local name = (type(link) == "string" and link ~= "") and (SafeCall(GetItemLinkName, link) or "") or ""
            if name == "" then
                SetText(row, "-")
                SetText(meta, "-")
                SetIcon(icon, nil)
            else
                local hex = ToHexColorFromQuality(link, BAG_WORN, entry.slot)
                local setText = BuildSetText(link, BAG_WORN, entry.slot)
                local cpSuffix = BuildRequiredCPSuffix(link)
                local enchantText = BuildEnchantText(link)
                local traitText = BuildTraitText(link)

                SetText(row, string.format("|c%s%s|r%s", hex, name, cpSuffix))

                local metaParts = {}
                if traitText ~= "" then table.insert(metaParts, string.format("|cFFD27A%s|r", traitText)) end
                if enchantText ~= "" then table.insert(metaParts, string.format("|cC7B8FF%s|r", enchantText)) end
                if setText ~= "" then table.insert(metaParts, string.format("|c9FD2FF%s|r", setText)) end
                if #metaParts > 0 then
                    SetText(meta, table.concat(metaParts, " | "))
                else
                    SetText(meta, "-")
                end

                SetIcon(icon, SafeCall(GetItemLinkIcon, link))
            end
        end
    end

    self.passiveTrees = passiveTrees
    self:RefreshPassivesWindow(passiveTrees)
    local cpMap = self.cpDisplayLock or { craft = 3, warfare = 1, fitness = 2 }
    self.cpDisciplineIndex = cpMap

    -- Build from active champion bar slots, then apply name-based tree override.
    self.lastCpOverrideHits = FillChampionSectionsFromActiveSlots(root, cpMap)
end

function WMBA:PrintChampionDiagnostics()
    if type(d) ~= "function" then return end
    local numDisc = SafeNum(SafeCall(GetNumChampionDisciplines), 0)
    d(string.format("[WMBA][CPDiag] disciplines=%d", numDisc))
    local cpMap = self.cpDisciplineIndex or BuildChampionDisciplineMap()
    d(string.format("[WMBA][CPDiag] map craft=%d warfare=%d fitness=%d", SafeNum(cpMap.craft, 0), SafeNum(cpMap.warfare, 0), SafeNum(cpMap.fitness, 0)))

    local skillMap = BuildChampionSkillDisplayDisciplineMap(numDisc)
    local barStart, barEnd = SafeCall(GetAssignableChampionBarStartAndEndSlots)
    barStart = SafeNum(barStart, 0)
    barEnd = SafeNum(barEnd, 0)
    local championHotbar = _G["HOTBAR_CATEGORY_CHAMPION"] or 2
    local championActionType = _G["ACTION_TYPE_CHAMPION_SKILL"]
    for slotIndex = barStart, barEnd do
        local slotType = nil
        if type(GetSlotType) == "function" then
            slotType = SafeCall(GetSlotType, slotIndex, championHotbar)
            if slotType == nil then
                slotType = SafeCall(GetSlotType, slotIndex)
            end
        end
        local isChampionSlot = true
        if championActionType ~= nil and slotType ~= nil and slotType ~= championActionType then
            isChampionSlot = false
            d(string.format("[WMBA][CPDiag] slot=%d ignored slotType=%s", slotIndex, tostring(slotType)))
        end

        if isChampionSlot then
            local skillId = SafeNum(SafeCall(GetSlotBoundId, slotIndex, championHotbar), 0)
            if skillId <= 0 then
                skillId = SafeNum(SafeCall(GetSlotBoundId, slotIndex), 0)
            end
            if skillId > 0 then
                local points = SafeNum(SafeCall(GetNumPointsSpentOnChampionSkill, skillId), 0)
                local name = tostring(SafeCall(GetChampionSkillName, skillId) or SafeCall(GetAbilityName, skillId) or ("Skill " .. tostring(skillId)))
                local bucket = SafeNum(skillMap[skillId], 0)
                d(string.format("[WMBA][CPDiag] slot=%d id=%d points=%d bucket=%d name=%s", slotIndex, skillId, points, bucket, name))
            end
        end
    end
    if type(self.lastCpOverrideHits) == "table" and #self.lastCpOverrideHits > 0 then
        d("[WMBA][CPDiag] override hits:")
        for _, row in ipairs(self.lastCpOverrideHits) do
            d("[WMBA][CPDiag]  " .. tostring(row))
        end
    end
end

function WMBA:TogglePassivesView()
    local blocked, now = IsDebounced(self.lastPassivesToggleAt, 220)
    if blocked then return end
    self.lastPassivesToggleAt = now
    local root = _G["WMBA_Window"]
    local pw = _G["WMBA_PassivesWindow"]
    if pw then
        local willShow = pw:IsHidden()
        pw:SetHidden(not willShow)
        if root then
            root:SetHidden(willShow)
        end
    end
    self:RefreshWindow()
end

function WMBA:StartUpdates()
    EVENT_MANAGER:UnregisterForUpdate(self.updateHandle)
    EVENT_MANAGER:RegisterForUpdate(self.updateHandle, REFRESH_MS, function()
        self:RefreshWindow()
    end)
    EVENT_MANAGER:UnregisterForUpdate(self.inputHandle)
    EVENT_MANAGER:RegisterForUpdate(self.inputHandle, 80, function()
        self:PollGamepadActions()
    end)
end

function WMBA:StopUpdates()
    EVENT_MANAGER:UnregisterForUpdate(self.updateHandle)
    EVENT_MANAGER:UnregisterForUpdate(self.inputHandle)
    EVENT_MANAGER:UnregisterForUpdate(self.burstHandle)
    self.primaryPressed = false
    self.negativePressed = false
    self.lastPassivesToggleAt = 0
    self.lastCloseToggleAt = 0
end

function WMBA:ToggleWindow()
    local root = _G["WMBA_Window"]
    if not root then return end
    local pw = _G["WMBA_PassivesWindow"]
    local hidden = root:IsHidden()
    root:SetHidden(not hidden)
    if hidden then
        self:SetupCloseFallback()
        if pw then pw:SetHidden(true) end
        EnsureOpaqueWindow(root)
        self:RefreshWindow()
        self:StartUpdates()
        if KEYBIND_STRIP and not self.closeKeybindAdded then
            self.closeKeybindDescriptor = {
                alignment = KEYBIND_STRIP_ALIGN_CENTER,
                {
                    name = "Passives (X)",
                    keybind = "UI_SHORTCUT_PRIMARY",
                    callback = function()
                        pcall(function()
                            self:TogglePassivesView()
                        end)
                    end,
                },
                {
                    name = "Close",
                    keybind = "UI_SHORTCUT_NEGATIVE",
                    callback = function()
                        pcall(function()
                            self:ToggleWindow()
                        end)
                    end,
                },
            }
            KEYBIND_STRIP:AddKeybindButtonGroup(self.closeKeybindDescriptor)
            self.closeKeybindAdded = true
        end
    else
        if pw then pw:SetHidden(true) end
        self:StopUpdates()
        if KEYBIND_STRIP and self.closeKeybindAdded and self.closeKeybindDescriptor then
            KEYBIND_STRIP:RemoveKeybindButtonGroup(self.closeKeybindDescriptor)
            self.closeKeybindAdded = false
        end
    end
end

function WMBA:SetupCloseFallback()
    local root = _G["WMBA_Window"]
    local pw = _G["WMBA_PassivesWindow"]
    if root and not self.mainKeyHandlerBound then
        root:SetHandler("OnKeyDown", function(_, keyCode)
            return self:SafeHandleInputKey(keyCode)
        end)
        self.mainKeyHandlerBound = true
    end
    if pw and not self.passivesKeyHandlerBound then
        pw:SetHandler("OnKeyDown", function(_, keyCode)
            return self:SafeHandleInputKey(keyCode)
        end)
        self.passivesKeyHandlerBound = true
    end
end

function WMBA:OnAddonLoaded(addonName)
    if not self.compatibleAddonNames[tostring(addonName or "")] then return end
    ZO_CreateStringId("SI_BINDING_NAME_WMBA_SHOW_PANEL", "Toggle What's My Build Again")
    self:SetupCloseFallback()
    self:RegisterReactiveRefreshEvents()
    SLASH_COMMANDS["/wmba"] = function() self:ToggleWindow() end
    SLASH_COMMANDS["/whatsmybuildagain"] = function() self:ToggleWindow() end
    SLASH_COMMANDS["/wmbapassives"] = function() self:TogglePassivesView() end
    SLASH_COMMANDS["/wmbarefresh"] = function()
        self:HandleBuildChanged("slash")
    end
    SLASH_COMMANDS["/wmbacpdiag"] = function()
        self:PrintChampionDiagnostics()
    end
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
end

function WMBA_ToggleWindow()
    WMBA:ToggleWindow()
end

-- Backward-compatible callback name used by older bindings
function SuperStar_ToggleSuperStarPanel()
    WMBA:ToggleWindow()
end

local function OnAddonLoaded(_, addonName)
    WMBA:OnAddonLoaded(addonName)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
