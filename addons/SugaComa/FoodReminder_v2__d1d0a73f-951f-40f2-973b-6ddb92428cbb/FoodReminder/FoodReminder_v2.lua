FoodReminder_v2 = {}
FoodReminder_v2.name = "FoodReminder_v2"
FoodReminder_v2.version = "2.8.1-test1"

local REMINDER_WINDOW_SEC = 30 * 60
local checkInterval = 90 * 1000
local MESSAGE_DELAY = 2000
local AUTO_REFRESH_ARM_SEC = 5 * 60
local AUTO_REFRESH_MONITOR_MS = 1000
local AUTO_REFRESH_UPDATE_NAME = "FoodReminder_v2_AutoRefreshMonitor"

local COLOR_GREEN = "|c00FF00"
local COLOR_ORANGE = "|cFFA500"
local COLOR_RED = "|cFF0000"
local COLOR_PURPLE = "|c800080"
local COLOR_END = "|r"

local reminderToken = 0
local activeReminderKey = nil
local autoRefreshToken = 0
local autoRefreshScheduledKey = nil
local autoRefreshArmedKey = nil
local autoRefreshAttemptedKey = nil
local autoRefreshSuccessCount = 0
local autoRefreshLimitNoticeShown = false
local lastMessageTime = 0
local lastActivated = 0
local foodAbilityCatalog = {}
local foodCatalogRefreshToken = 0
local SV_VERSION = 3
local SV = nil

local function ColorForRemaining(sec)
    if sec > 30 * 60 then
        return COLOR_GREEN
    elseif sec > 5 * 60 then
        return COLOR_ORANGE
    else
        return COLOR_RED
    end
end

local function CanonicalizeName(s)
    if not s or s == "" then return nil end
    s = tostring(s)
    s = s:gsub("&", "and")
    s = s:gsub("[\226\128\153\226\128\156\226\128\157]", "'")
    s = s:gsub("[\226\128\147\226\128\148]", "-")
    s = s:gsub("%^.", "")
    s = s:gsub("[^%w%s'-]", "")
    s = s:gsub("%s+", " ")
    s = s:match("^%s*(.-)%s*$") or ""
    return zo_strlower(s)
end

local function fmt_hms(total)
    local s = math.max(0, math.floor(total or 0))
    local h = math.floor(s / 3600)
    local m = math.floor((s % 3600) / 60)
    local r = s % 60
    return h, m, r
end

local function FRPrint(msg, soundId, isFinal, expectedReminderToken)
    local now = GetFrameTimeSeconds() * 1000
    local delay = math.max(0, lastMessageTime + MESSAGE_DELAY - now)
    zo_callLater(function()
        if expectedReminderToken and expectedReminderToken ~= reminderToken then return end

        local actualSound = (FoodReminder_v2.soundEnabled and soundId) or SOUNDS.NONE
        local prefix = "! "
        if SV and SV.mode == "inyourface" and isFinal then
            local CSA = CENTER_SCREEN_ANNOUNCE
            if CSA and CSA.CreateMessageParams then
                local p = CSA:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, actualSound)
                p:SetText(prefix .. tostring(msg))
                p:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_CHAMPION_POINT_GAINED)
                CSA:DisplayMessage(p)
            else
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, actualSound, prefix .. tostring(msg))
            end
        else
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, actualSound, prefix .. tostring(msg))
        end
        lastMessageTime = GetFrameTimeSeconds() * 1000
    end, delay)
end

local function FRStatus(msg)
    local text = "[FoodReminder] " .. tostring(msg)
    if CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then
        CHAT_SYSTEM:AddMessage(text)
    else
        d(text)
    end
end

-- Inventory catalogue support.
-- Primary active-food detection is now the removable-effect (canClickOff) flag from GetUnitBuffInfo.
-- These entries describe generic buff effects rather than individual recipe/item names,
-- so new foods added by future ESO updates do not require addon maintenance.
local GENERIC_FOOD_BUFF_FALLBACKS = {
    ["increase all primary stats"] = "generic all-stat food",
    ["increase all primary recovery"] = "generic all-recovery drink",
    ["increase all primary recoveries"] = "generic all-recovery drink",
    ["increase health magicka and stamina recovery"] = "generic all-recovery drink",
    ["increase health magicka stamina recovery"] = "generic all-recovery drink",
    ["increase max health"] = "generic health food",
    ["increase max magicka"] = "generic magicka food",
    ["increase max stamina"] = "generic stamina food",
    ["health recovery"] = "generic health recovery drink",
    ["magicka recovery"] = "generic magicka recovery drink",
    ["stamina recovery"] = "generic stamina recovery drink",
    ["increase max health and stamina"] = "generic health and stamina food",
    ["increase max health and magicka"] = "generic health and magicka food",
}



-- FOOD and DRINK item types also include progression boosters such as Ambrosias.
-- FoodReminder is intended to maintain ordinary stat/resource food and drink,
-- not repeatedly consume short-duration XP/progression boosters.
--
-- Do not maintain another item-name list here.  Classify from the on-use ability
-- information exposed by ESO instead.
local function IsProgressionBoosterText(text)
    if type(text) ~= "string" or text == "" then return false end
    local n = string.lower(text)

    -- Covers normal XP boosters and progression consumables whose effect text
    -- describes experience gain.  Requiring a gain/bonus/increase term avoids
    -- treating unrelated flavour text containing the word "experience" as a hit.
    if n:find("experience", 1, true) then
        if n:find("gain", 1, true)
            or n:find("bonus", 1, true)
            or n:find("increase", 1, true)
            or n:find("boost", 1, true) then
            return true
        end
    end

    return false
end

local function IsProgressionBoosterItemLink(itemLink)
    if not itemLink or itemLink == "" then return false end

    local hasAbility, abilityHeader, abilityDescription = GetItemLinkOnUseAbilityInfo(itemLink)
    if not hasAbility then return false end

    local combined = string.format(
        "%s %s",
        tostring(abilityHeader or ""),
        tostring(abilityDescription or "")
    )
    return IsProgressionBoosterText(combined)
end

local function IsProgressionBoosterAbilityId(abilityId)
    abilityId = tonumber(abilityId) or 0
    if abilityId == 0 then return false end

    local header = ""
    local description = ""

    if GetAbilityDescriptionHeader then
        header = GetAbilityDescriptionHeader(abilityId, "player") or ""
    end
    if GetAbilityDescription then
        description = GetAbilityDescription(abilityId, nil, "player") or ""
    end

    return IsProgressionBoosterText(
        string.format("%s %s", tostring(header), tostring(description))
    )
end

local function RefreshFoodAbilityCatalog()
    local catalog = {}
    local bagSize = GetBagSize(BAG_BACKPACK) or 0

    if SV and type(SV.knownFoodAbilities) ~= "table" then
        SV.knownFoodAbilities = {}
    end

    for slotIndex = 0, bagSize - 1 do
        local itemType = GetItemType(BAG_BACKPACK, slotIndex)
        if itemType == ITEMTYPE_FOOD or itemType == ITEMTYPE_DRINK then
            local stack = GetSlotStackSize(BAG_BACKPACK, slotIndex) or 0
            if stack > 0 then
                local itemLink = GetItemLink(BAG_BACKPACK, slotIndex, LINK_STYLE_DEFAULT)
                if itemLink and itemLink ~= "" then
                    local abilityId = GetItemLinkOnUseAbilityId(itemLink) or 0
                    if abilityId ~= 0 then
                        local itemName = GetItemName(BAG_BACKPACK, slotIndex)
                            or GetItemLinkName(itemLink)
                            or "Food/Drink"

                        local entry = catalog[abilityId]
                        if not entry then
                            entry = {
                                name = itemName,
                                itemType = itemType,
                                count = 0,
                                slots = {},
                                isProgressionBooster = IsProgressionBoosterItemLink(itemLink),
                            }
                            catalog[abilityId] = entry
                        end

                        entry.count = entry.count + stack
                        entry.slots[#entry.slots + 1] = slotIndex

                        -- Remember abilities we have actually seen on real FOOD/DRINK items.
                        -- This lets an already-active buff remain identifiable even if the
                        -- final copy is later consumed.
                        if SV and SV.knownFoodAbilities then
                            SV.knownFoodAbilities[tostring(abilityId)] = {
                                name = itemName,
                                itemType = itemType,
                                isProgressionBooster = entry.isProgressionBooster == true,
                            }
                        end
                    end
                end
            end
        end
    end

    foodAbilityCatalog = catalog
end

local function QueueFoodAbilityCatalogRefresh()
    foodCatalogRefreshToken = foodCatalogRefreshToken + 1
    local token = foodCatalogRefreshToken
    zo_callLater(function()
        if token ~= foodCatalogRefreshToken then return end
        RefreshFoodAbilityCatalog()
    end, 250)
end

local function GetCatalogFoodInfo(abilityId)
    abilityId = tonumber(abilityId) or 0
    if abilityId == 0 then return nil end

    local live = foodAbilityCatalog[abilityId]
    if live then
        return live.name, live.itemType, live.count, live.isProgressionBooster == true
    end

    if SV and type(SV.knownFoodAbilities) == "table" then
        local known = SV.knownFoodAbilities[tostring(abilityId)]
        if type(known) == "table" then
            local isBooster = known.isProgressionBooster
            if isBooster == nil then
                -- Migration path for ability IDs learned by Test 3-5 before
                -- progression-booster classification existed.
                isBooster = IsProgressionBoosterAbilityId(abilityId)
                known.isProgressionBooster = isBooster == true
            end
            return known.name, known.itemType, 0, isBooster == true
        end
    end

    return nil
end


local CountBackpackItemsByAbilityId

local function GetLearnedBuffFoodInfo(buffAbilityId)
    buffAbilityId = tonumber(buffAbilityId) or 0
    if buffAbilityId == 0 or not SV or type(SV.knownBuffToFood) ~= "table" then
        return nil
    end

    local learned = SV.knownBuffToFood[tostring(buffAbilityId)]
    if type(learned) ~= "table" then return nil end
    return learned.itemAbilityId, learned.name
end

local function RememberBuffFoodMapping(buffAbilityId, itemAbilityId, itemName)
    buffAbilityId = tonumber(buffAbilityId) or 0
    itemAbilityId = tonumber(itemAbilityId) or 0
    if buffAbilityId == 0 or itemAbilityId == 0 or not SV then return end

    if type(SV.knownBuffToFood) ~= "table" then
        SV.knownBuffToFood = {}
    end

    SV.knownBuffToFood[tostring(buffAbilityId)] = {
        itemAbilityId = itemAbilityId,
        name = itemName or "Food/Drink",
    }
end

local function FindFoodByItemAbilityId(itemAbilityId)
    itemAbilityId = tonumber(itemAbilityId) or 0
    if itemAbilityId == 0 then return nil end

    local bagSize = GetBagSize(BAG_BACKPACK) or 0
    for slotIndex = 0, bagSize - 1 do
        local itemType = GetItemType(BAG_BACKPACK, slotIndex)
        if itemType == ITEMTYPE_FOOD or itemType == ITEMTYPE_DRINK then
            local stack = GetSlotStackSize(BAG_BACKPACK, slotIndex) or 0
            if stack > 0 then
                local itemLink = GetItemLink(BAG_BACKPACK, slotIndex, LINK_STYLE_DEFAULT)
                if itemLink and itemLink ~= ""
                    and not IsProgressionBoosterItemLink(itemLink)
                    and (GetItemLinkOnUseAbilityId(itemLink) or 0) == itemAbilityId then
                    local itemName = GetItemName(BAG_BACKPACK, slotIndex)
                        or GetItemLinkName(itemLink)
                        or "Food/Drink"
                    return slotIndex, itemAbilityId, itemName, CountBackpackItemsByAbilityId(itemAbilityId)
                end
            end
        end
    end

    return nil
end

local function FindUniqueInventoryFoodNameMatch(buffName)
    local buffCanon = CanonicalizeName(buffName)
    if not buffCanon or buffCanon == "" then return nil end

    local match = nil
    local bagSize = GetBagSize(BAG_BACKPACK) or 0

    for slotIndex = 0, bagSize - 1 do
        local itemType = GetItemType(BAG_BACKPACK, slotIndex)
        if itemType == ITEMTYPE_FOOD or itemType == ITEMTYPE_DRINK then
            local stack = GetSlotStackSize(BAG_BACKPACK, slotIndex) or 0
            if stack > 0 then
                local itemLink = GetItemLink(BAG_BACKPACK, slotIndex, LINK_STYLE_DEFAULT)
                if itemLink and itemLink ~= "" and not IsProgressionBoosterItemLink(itemLink) then
                    local itemName = GetItemName(BAG_BACKPACK, slotIndex)
                        or GetItemLinkName(itemLink)
                        or "Food/Drink"
                    local itemCanon = CanonicalizeName(itemName)
                    if itemCanon and (
                        itemCanon == buffCanon
                        or itemCanon:find(buffCanon, 1, true)
                        or buffCanon:find(itemCanon, 1, true)
                    ) then
                        local itemAbilityId = GetItemLinkOnUseAbilityId(itemLink) or 0
                        local candidate = {
                            slotIndex = slotIndex,
                            itemAbilityId = itemAbilityId,
                            itemName = itemName,
                            count = CountBackpackItemsByAbilityId(itemAbilityId),
                        }

                        -- Only trust this heuristic when exactly one distinct food/drink
                        -- item name matches the removable buff name.
                        if match and CanonicalizeName(match.itemName) ~= itemCanon then
                            return nil
                        end
                        match = candidate
                    end
                end
            end
        end
    end

    if match then
        return match.slotIndex, match.itemAbilityId, match.itemName, match.count
    end
    return nil
end

CountBackpackItemsByAbilityId = function(abilityId)
    abilityId = tonumber(abilityId) or 0
    if abilityId == 0 then return 0 end

    local total = 0
    local bagSize = GetBagSize(BAG_BACKPACK) or 0
    for slotIndex = 0, bagSize - 1 do
        local itemType = GetItemType(BAG_BACKPACK, slotIndex)
        if itemType == ITEMTYPE_FOOD or itemType == ITEMTYPE_DRINK then
            local itemLink = GetItemLink(BAG_BACKPACK, slotIndex, LINK_STYLE_DEFAULT)
            if itemLink and itemLink ~= "" and GetItemLinkOnUseAbilityId(itemLink) == abilityId then
                total = total + (GetSlotStackSize(BAG_BACKPACK, slotIndex) or 0)
            end
        end
    end
    return total
end

local function IsFoodByBuffName(buffName)
    local n = CanonicalizeName(buffName)
    if not n then return false end

    local generic = GENERIC_FOOD_BUFF_FALLBACKS[n]
    if generic then
        return true, generic
    end

    -- Broad last-resort check for dual/tri-stat max-resource food wording.
    if n:find("increase max health")
        and (n:find("stamina") or n:find("magicka")) then
        return true, "generic food/drink buff"
    end

    return false
end

local function QueryFood()
    local now = GetFrameTimeSeconds()

    for i = 1, GetNumBuffs("player") do
        local buffName, _, finish, _, _, _, _, _, _, _, abilityId, canClickOff =
            GetUnitBuffInfo("player", i)

        abilityId = abilityId or 0

        -- ESO exposes the same removable-effect flag used by the Character Sheet's
        -- "REMOVE EFFECT" action.  Normal food/drink buffs are both removable AND timed.
        -- Some temporary world-event perks (for example Stendarr's Gift) are removable
        -- but have no expiry timer, so finish == 0 must not be treated as expired food.
        local remaining = math.max(0, (tonumber(finish) or 0) - now)
        local hasExpiryTimer = (tonumber(finish) or 0) > 0
        local isLongDurationEffect = remaining > 60
        if canClickOff == true and hasExpiryTimer and isLongDurationEffect then
            -- Safety only: progression boosters observed in testing are not removable,
            -- but never treat one as normal food if ESO changes that later.
            if not IsProgressionBoosterAbilityId(abilityId) then
                local label = buffName or "Food/Drink"
                local itemAbilityId = nil

                -- 1. Some items (e.g. Crown foods) use the same ability ID as the buff.
                local catalogName, _, _, isProgressionBooster = GetCatalogFoodInfo(abilityId)
                if catalogName and not isProgressionBooster then
                    label = catalogName
                    itemAbilityId = abilityId
                else
                    -- 2. Use a relationship learned during an earlier scan/refresh.
                    local learnedItemAbilityId, learnedName = GetLearnedBuffFoodInfo(abilityId)
                    if learnedItemAbilityId then
                        label = learnedName or label
                        itemAbilityId = learnedItemAbilityId
                    else
                        -- 3. Resolve mismatched names dynamically from the inventory scan.
                        -- Example: "Blood Price Pie" -> "Orzorga's Blood Price Pie".
                        local _, matchedAbilityId, matchedName =
                            FindUniqueInventoryFoodNameMatch(buffName)
                        if matchedAbilityId and matchedAbilityId ~= 0 then
                            itemAbilityId = matchedAbilityId
                            label = matchedName or label
                            RememberBuffFoodMapping(abilityId, matchedAbilityId, matchedName)
                        end
                    end
                end

                return true, label, remaining, abilityId, CanonicalizeName(buffName), finish or 0, itemAbilityId
            end
        end
    end

    return false, nil, 0, 0, nil, 0, nil
end

local function MakeFoodKey(abilityId, finish)
    return string.format("%d:%d", tonumber(abilityId) or 0, math.floor(tonumber(finish) or 0))
end

local function StopAutoRefreshMonitor()
    EVENT_MANAGER:UnregisterForUpdate(AUTO_REFRESH_UPDATE_NAME)
    autoRefreshArmedKey = nil
end

local function CancelAutoRefreshSchedule()
    autoRefreshToken = autoRefreshToken + 1
    autoRefreshScheduledKey = nil
    StopAutoRefreshMonitor()
end

local function IsSafeToConsume()
    if IsUnitInCombat and IsUnitInCombat("player") then
        return false
    end
    if IsUnitDeadOrReincarnating and IsUnitDeadOrReincarnating("player") then
        return false
    elseif IsUnitDead and IsUnitDead("player") then
        return false
    end
    if IsMounted and IsMounted() then
        return false
    end
    if IsUnitSwimming and IsUnitSwimming("player") then
        return false
    end
    if IsPlayerMoving and IsPlayerMoving() then
        return false
    end
    return true
end

local function FindMatchingFoodSlot(activeAbilityId, canonicalBuffName, resolvedItemAbilityId, displayLabel)
    -- Preferred: QueryFood already resolved the active removable buff to a FOOD/DRINK
    -- item ability using a direct match or a learned relationship.
    if resolvedItemAbilityId and resolvedItemAbilityId ~= 0 then
        local slotIndex, itemAbilityId, itemName, count =
            FindFoodByItemAbilityId(resolvedItemAbilityId)
        if slotIndex then
            return slotIndex, itemAbilityId, itemName, count
        end
    end

    -- Try an existing learned buff -> item relationship.
    local learnedItemAbilityId = GetLearnedBuffFoodInfo(activeAbilityId)
    if learnedItemAbilityId then
        local slotIndex, itemAbilityId, itemName, count =
            FindFoodByItemAbilityId(learnedItemAbilityId)
        if slotIndex then
            return slotIndex, itemAbilityId, itemName, count
        end
    end

    -- Same ability ID remains valid for foods where ESO exposes identical item/buff IDs.
    local directSlot, directAbilityId, directName, directCount =
        FindFoodByItemAbilityId(activeAbilityId)
    if directSlot then
        return directSlot, directAbilityId, directName, directCount
    end

    -- Last dynamic fallback: compare the removable buff name to all ordinary FOOD/DRINK
    -- item names in the backpack.  This deliberately allows a prefix/suffix difference
    -- such as "Blood Price Pie" vs "Orzorga's Blood Price Pie", but only if the match
    -- is unique.
    local buffLabel = displayLabel or canonicalBuffName
    local slotIndex, itemAbilityId, itemName, count =
        FindUniqueInventoryFoodNameMatch(buffLabel)

    if slotIndex and itemAbilityId and itemAbilityId ~= 0 then
        RememberBuffFoodMapping(activeAbilityId, itemAbilityId, itemName)
        return slotIndex, itemAbilityId, itemName, count
    end

    return nil
end

local function GetAutoRefreshSessionLimit()
    local limit = 2
    if SV then
        limit = tonumber(SV.maxAutoRefreshesPerSession) or limit
    elseif FoodReminder_v2.maxAutoRefreshesPerSession then
        limit = tonumber(FoodReminder_v2.maxAutoRefreshesPerSession) or limit
    end

    limit = math.floor(limit)
    if limit < 1 then limit = 1 end
    if limit > 10 then limit = 10 end
    return limit
end

local function HasReachedAutoRefreshSessionLimit()
    return autoRefreshSuccessCount >= GetAutoRefreshSessionLimit()
end

local function AnnounceAutoRefreshLimitOnce()
    if autoRefreshLimitNoticeShown then return end
    autoRefreshLimitNoticeShown = true
    FRStatus(string.format(
        "Auto-refresh limit reached for this session (%d/%d). Further food must be consumed manually.",
        autoRefreshSuccessCount,
        GetAutoRefreshSessionLimit()
    ))
end

local function AttemptAutoRefresh(label, abilityId, canonicalBuffName, finish, resolvedItemAbilityId)
    if not SV or not SV.autoRefreshFood then return false end

    -- Safety backstop: even if a progression booster somehow reaches this path,
    -- never automatically consume it.
    local _, _, _, isProgressionBooster = GetCatalogFoodInfo(abilityId)
    if isProgressionBooster or IsProgressionBoosterAbilityId(abilityId) then
        return false
    end

    if HasReachedAutoRefreshSessionLimit() then
        AnnounceAutoRefreshLimitOnce()
        return false
    end

    local key = MakeFoodKey(abilityId, finish)
    if autoRefreshAttemptedKey == key then return false end
    autoRefreshAttemptedKey = key

    local slotIndex, matchedAbilityId, itemName, beforeCount =
        FindMatchingFoodSlot(abilityId, canonicalBuffName, resolvedItemAbilityId, label)

    if slotIndex == nil then
        FRStatus(string.format(
            "Auto-refresh could not find the same %s in your backpack.",
            tostring(label or "food/drink")
        ))
        return false
    end

    local usable, usableOnlyFromActionSlot = IsItemUsable(BAG_BACKPACK, slotIndex)
    if not usable or usableOnlyFromActionSlot then
        FRStatus(string.format(
            "%s could not be auto-consumed. Use it manually.",
            tostring(itemName or label or "Food/Drink")
        ))
        return false
    end

    local callOk, secureSuccess = pcall(CallSecureProtected, "UseItem", BAG_BACKPACK, slotIndex)
    if not callOk or secureSuccess ~= true then
        FRStatus(string.format(
            "ESO blocked auto-consuming %s. Use it manually.",
            tostring(itemName or label or "Food/Drink")
        ))
        return false
    end

    -- The protected call may return before inventory and buff state update.
    -- Verify rather than claiming success immediately.
    zo_callLater(function()
        local afterCount = CountBackpackItemsByAbilityId(matchedAbilityId)
        local found, _, newRemaining = QueryFood()
        local refreshed =
            (afterCount < (beforeCount or 0))
            or (found and newRemaining > (AUTO_REFRESH_ARM_SEC + 60))

        if refreshed then
            RememberBuffFoodMapping(abilityId, matchedAbilityId, itemName)
            autoRefreshSuccessCount = autoRefreshSuccessCount + 1
            FRStatus(string.format(
                "%s refreshed — %d remaining. Auto-refreshes this session: %d/%d.",
                tostring(itemName or label or "Food/Drink"),
                afterCount,
                autoRefreshSuccessCount,
                GetAutoRefreshSessionLimit()
            ))

            if HasReachedAutoRefreshSessionLimit() then
                AnnounceAutoRefreshLimitOnce()
            end
        else
            FRStatus(string.format(
                "Tried to refresh %s, but ESO did not consume it. Use it manually.",
                tostring(itemName or label or "Food/Drink")
            ))
        end
    end, 1500)

    return true
end

local function StartSafeStateMonitor(key, resolvedItemAbilityId)
    if autoRefreshArmedKey == key then return end

    StopAutoRefreshMonitor()
    autoRefreshArmedKey = key

    EVENT_MANAGER:RegisterForUpdate(AUTO_REFRESH_UPDATE_NAME, AUTO_REFRESH_MONITOR_MS, function()
        if not SV or not SV.autoRefreshFood then
            StopAutoRefreshMonitor()
            return
        end

        local found, label, remaining, abilityId, canonicalBuffName, finish, currentResolvedItemAbilityId = QueryFood()
        if not found or remaining <= 0 then
            StopAutoRefreshMonitor()
            return
        end

        local currentKey = MakeFoodKey(abilityId, finish)
        if currentKey ~= key then
            -- Food was manually refreshed or replaced while we were waiting.
            StopAutoRefreshMonitor()
            return
        end

        if autoRefreshAttemptedKey == key then
            StopAutoRefreshMonitor()
            return
        end

        if HasReachedAutoRefreshSessionLimit() then
            StopAutoRefreshMonitor()
            AnnounceAutoRefreshLimitOnce()
            return
        end

        -- Once armed, wait silently for a conservative safe state:
        -- out of combat, alive, unmounted, not swimming and stationary.
        if IsSafeToConsume() then
            StopAutoRefreshMonitor()
            AttemptAutoRefresh(
                label,
                abilityId,
                canonicalBuffName,
                finish,
                currentResolvedItemAbilityId or resolvedItemAbilityId
            )
        end
    end)
end

local function ScheduleAutoRefresh(found, label, remaining, abilityId, canonicalBuffName, finish, resolvedItemAbilityId)
    if not SV or not SV.autoRefreshFood or not found or remaining <= 0 then
        CancelAutoRefreshSchedule()
        return
    end

    if HasReachedAutoRefreshSessionLimit() then
        CancelAutoRefreshSchedule()
        AnnounceAutoRefreshLimitOnce()
        return
    end

    local key = MakeFoodKey(abilityId, finish)
    if autoRefreshAttemptedKey == key then
        StopAutoRefreshMonitor()
        return
    end

    -- Already inside the five-minute window: arm immediately and wait for safety.
    if remaining <= AUTO_REFRESH_ARM_SEC then
        autoRefreshScheduledKey = nil
        StartSafeStateMonitor(key, resolvedItemAbilityId)
        return
    end

    if autoRefreshScheduledKey == key then
        return
    end

    StopAutoRefreshMonitor()
    autoRefreshToken = autoRefreshToken + 1
    autoRefreshScheduledKey = key
    local myToken = autoRefreshToken
    local delaySec = math.max(0, remaining - AUTO_REFRESH_ARM_SEC)

    zo_callLater(function()
        if myToken ~= autoRefreshToken or autoRefreshScheduledKey ~= key then return end
        autoRefreshScheduledKey = nil

        local currentFound, currentLabel, currentRemaining, currentAbilityId,
            currentCanonicalBuffName, currentFinish, currentResolvedItemAbilityId = QueryFood()
        if not currentFound then return end
        if MakeFoodKey(currentAbilityId, currentFinish) ~= key then return end

        -- Timing margin in case the callback fires fractionally early.
        if currentRemaining > AUTO_REFRESH_ARM_SEC + 2 then
            ScheduleAutoRefresh(
                currentFound,
                currentLabel or label,
                currentRemaining,
                currentAbilityId,
                currentCanonicalBuffName or canonicalBuffName,
                currentFinish,
                currentResolvedItemAbilityId or resolvedItemAbilityId
            )
            return
        end

        StartSafeStateMonitor(key, currentResolvedItemAbilityId or resolvedItemAbilityId)
    end, math.floor(delaySec * 1000))
end

local CheckFoodBuff

local function StopReminders()
    reminderToken = reminderToken + 1
    activeReminderKey = nil
end

local function StartReminders(abilityId, finish)
    local key = MakeFoodKey(abilityId, finish)
    if activeReminderKey == key then return end

    local myToken = reminderToken + 1
    reminderToken = myToken
    activeReminderKey = key

    local function tick()
        if myToken ~= reminderToken or activeReminderKey ~= key then return end

        local found, label, remaining, currentAbilityId, _, currentFinish = QueryFood()
        if not found then
            StopReminders()
            FRPrint("No active food or drink buff!")
            return
        end
        if remaining <= 0 then
            StopReminders()
            FRPrint("Food expired!", SOUNDS.NEGATIVE_CLICK, true)
            return
        end
        if remaining > REMINDER_WINDOW_SEC then
            StopReminders()
            return
        end

        local currentKey = MakeFoodKey(currentAbilityId, currentFinish)
        if currentKey ~= key then
            StopReminders()
            CheckFoodBuff()
            return
        end

        local h, m, s = fmt_hms(remaining)
        local timerColor = ColorForRemaining(remaining)
        local finalStage = (SV and SV.finalStageMin or 3) * 60
        local interval = math.max(1, (SV and SV.finalStageInterval or 15))
        local mode = (SV and SV.mode) or "subtle"
        local alertSound = (SV and SV.finalStageSound) or SOUNDS.DUEL_WON
        local isFinal = (remaining <= finalStage)
        FRPrint(
            string.format("%s%s%s — %s%02dh %02dm %02ds%s left",
                COLOR_PURPLE, label, COLOR_END,
                timerColor, h, m, s, COLOR_END),
            isFinal and alertSound or SOUNDS.NONE,
            (mode == "inyourface" and isFinal),
            myToken
        )

        local nextMs
        if remaining > (finalStage + 60) then
            nextMs = math.min(5 * 60, math.max(1, remaining - (finalStage + 60))) * 1000
        elseif remaining > finalStage then
            nextMs = math.min(60, math.max(1, remaining - finalStage)) * 1000
        else
            nextMs = interval * 1000
        end
        zo_callLater(tick, math.floor(nextMs))
    end

    tick()
end

CheckFoodBuff = function()
    local found, label, remaining, abilityId, canonicalBuffName, finish, resolvedItemAbilityId = QueryFood()
    if not found then
        StopReminders()
        CancelAutoRefreshSchedule()
        return
    end

    ScheduleAutoRefresh(
        found,
        label,
        remaining,
        abilityId,
        canonicalBuffName,
        finish,
        resolvedItemAbilityId
    )

    if remaining <= REMINDER_WINDOW_SEC then
        StartReminders(abilityId, finish)
    else
        StopReminders()
    end
end

FoodReminder_v2.RefreshAutoRefreshSchedule = CheckFoodBuff

local function ResumePolling()
    EVENT_MANAGER:UnregisterForUpdate("FoodReminder_v2_CheckBuff")
    EVENT_MANAGER:RegisterForUpdate("FoodReminder_v2_CheckBuff", checkInterval, CheckFoodBuff)
end

local function SenseCheckFood()
    local found, label, remaining, abilityId, _, finish = QueryFood()
    if not found then FRPrint("No active food or drink buff!") StopReminders() return end
    local h, m, s = fmt_hms(remaining)
    local timerColor = ColorForRemaining(remaining)
    FRPrint(string.format("%s%s%s — %s%02dh %02dm %02ds%s left",
        COLOR_PURPLE, label, COLOR_END,
        timerColor, h, m, s, COLOR_END))
    if remaining <= REMINDER_WINDOW_SEC then StartReminders(abilityId, finish) else StopReminders() end
end

local function OnPlayerActivated()
    local now = GetFrameTimeSeconds()
    if now - lastActivated < 10 then return end
    lastActivated = now
    RefreshFoodAbilityCatalog()
    ResumePolling()
    EVENT_MANAGER:UnregisterForEvent(FoodReminder_v2.name, EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:RegisterForEvent(FoodReminder_v2.name, EVENT_EFFECT_CHANGED,
        function(_, _, _, _, unitTag) if unitTag == "player" then CheckFoodBuff() end end)
    CheckFoodBuff()
end

FoodReminder_v2.soundEnabled = true

local function InitializeSavedVars()
    local defaults = {
        mode = "subtle",
        finalStageMin = 3,
        finalStageInterval = 15,
        soundEnabled = true,
        finalStageSound = SOUNDS.DUEL_WON,
        autoRefreshFood = false,
        maxAutoRefreshesPerSession = 2,
        knownFoodAbilities = {},
        knownBuffToFood = {},
    }
    local ok, sv = pcall(function()
        return ZO_SavedVars:NewAccountWide("FoodReminder_v2_SV", SV_VERSION, nil, defaults)
    end)
    if not ok or type(sv) ~= "table" then
        sv = ZO_DeepTableCopy(defaults)
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK,
            "[FoodReminder_v2] SavedVariables failed, using defaults.")
    end
    SV = sv
    if type(SV.knownFoodAbilities) ~= "table" then
        SV.knownFoodAbilities = {}
    end
    if type(SV.knownBuffToFood) ~= "table" then
        SV.knownBuffToFood = {}
    end
    FoodReminder_v2.SV = SV
    FoodReminder_v2.mode = SV.mode
    FoodReminder_v2.finalStageMin = SV.finalStageMin
    FoodReminder_v2.finalStageInterval = SV.finalStageInterval
    FoodReminder_v2.soundEnabled = SV.soundEnabled
    FoodReminder_v2.autoRefreshFood = (SV.autoRefreshFood == true)
    FoodReminder_v2.maxAutoRefreshesPerSession = tonumber(SV.maxAutoRefreshesPerSession) or 2
end

local function SaveState()
    if not SV then return end
    SV.mode = FoodReminder_v2.mode
    SV.finalStageMin = FoodReminder_v2.finalStageMin
    SV.finalStageInterval = FoodReminder_v2.finalStageInterval
    SV.soundEnabled = FoodReminder_v2.soundEnabled
    SV.autoRefreshFood = (FoodReminder_v2.autoRefreshFood == true)
    SV.maxAutoRefreshesPerSession = tonumber(FoodReminder_v2.maxAutoRefreshesPerSession) or 2
end

local function ToggleSound()
    FoodReminder_v2.soundEnabled = not FoodReminder_v2.soundEnabled
    if SV then SV.soundEnabled = FoodReminder_v2.soundEnabled end
    local msg = FoodReminder_v2.soundEnabled and "Sound alerts ENABLED." or "Sound alerts DISABLED."
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, "! " .. msg)
end

SLASH_COMMANDS["/food"] = SenseCheckFood
SLASH_COMMANDS["/fmute"] = ToggleSound

local function OnAddonLoaded(_, addonName)
    if addonName ~= FoodReminder_v2.name then return end
    EVENT_MANAGER:UnregisterForEvent(FoodReminder_v2.name, EVENT_ADD_ON_LOADED)
    InitializeSavedVars()
    RefreshFoodAbilityCatalog()

    EVENT_MANAGER:RegisterForEvent(
        FoodReminder_v2.name .. "_Inventory",
        EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        function(_, bagId)
            if bagId == BAG_BACKPACK then
                QueueFoodAbilityCatalogRefresh()
            end
        end
    )

    EVENT_MANAGER:RegisterForEvent(FoodReminder_v2.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(FoodReminder_v2.name, EVENT_PLAYER_DEACTIVATED, SaveState)
    EVENT_MANAGER:RegisterForEvent(FoodReminder_v2.name, EVENT_PLAYER_LOGOUT, SaveState)
    local function TryAttachFRMenu()
        if FRMenu and FRMenu.Setup then
            zo_callLater(function() FRMenu.Setup(FoodReminder_v2) end, 3000)
        else
            zo_callLater(TryAttachFRMenu, 4000)
        end
    end
    zo_callLater(TryAttachFRMenu, 5000)
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE,
        string.format("[FoodReminder] v%s loaded — Sound %s.",
            FoodReminder_v2.version,
            FoodReminder_v2.soundEnabled and "|c00FF00ON|r" or "|cFF0000OFF|r"))
end

EVENT_MANAGER:RegisterForEvent(FoodReminder_v2.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)