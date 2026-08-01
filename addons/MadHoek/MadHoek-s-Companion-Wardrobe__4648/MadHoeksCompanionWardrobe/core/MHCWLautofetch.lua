-- ============================================================================
-- Companion Wardrobe
-- Gear Fetch and Gear Storage Automation
--
-- Responsibilities:
-- - Fetch missing loadout gear from the bank.
-- - Store saved loadout gear into the bank.
-- - Manage queued bank operations safely through ESO restrictions.
-- - Build completion statistics and user notifications.
--
-- Notes:
-- - Gear movement is processed through delayed queues.
-- - Actual execution begins when the bank is opened.
-- - Timing is intentionally conservative for reliability.
-- ============================================================================
if MHCWL == nil then MHCWL = {} end
local MHCWL = MHCWL

function MHCWL.FindFirstEmptyBackpackSlot()
    for slot = 0, GetBagSize(BAG_BACKPACK) do
        if not HasItemInSlot(BAG_BACKPACK, slot) then
            return slot
        end
    end

    return nil
end

function MHCWL.FindSavedItemInBank(saved)
    local slot, matchType = MHCWL.FindSavedItemInBag(saved, BAG_BANK)

    if slot then
        return BAG_BANK, slot, matchType
    end

    if BAG_SUBSCRIBER_BANK then
        slot, matchType = MHCWL.FindSavedItemInBag(saved, BAG_SUBSCRIBER_BANK)

        if slot then
            return BAG_SUBSCRIBER_BANK, slot, matchType
        end
    end

    return nil, nil, nil
end

function MHCWL.HasLoadoutGearInBackpack(index)
    index = tonumber(index)

    local companionData = MHCWL.GetActiveCompanionSavedData()
    if not companionData then return false end

    local setup = companionData.setups[index]
    if not setup or not setup.gear then return false end

    for _, saved in pairs(setup.gear) do
        local slot = MHCWL.FindSavedItemInBag(saved, BAG_BACKPACK)

        if slot then
            return true
        end
    end

    return false
end

function MHCWL.FindFirstEmptyBankSlot()
    local slot = FindFirstEmptySlotInBag(BAG_BANK)

    if slot then
        return BAG_BANK, slot
    end

    if BAG_SUBSCRIBER_BANK then
        slot = FindFirstEmptySlotInBag(BAG_SUBSCRIBER_BANK)

        if slot then
            return BAG_SUBSCRIBER_BANK, slot
        end
    end

    return nil, nil
end

function MHCWL.GetItemCountText(count)
    local label =
        count == 1
        and GetString(MHCWL_NOTIFY_ITEM_SINGULAR)
        or GetString(MHCWL_NOTIFY_ITEM_PLURAL)

    return tostring(count) .. " " .. label
end

function MHCWL.BuildGearFetchResultMessage(moved, missing, failed)
    local lines = {}

    if failed > 0 then
        table.insert(
            lines,
            GetString(MHCWL_NOTIFY_BACKPACK_FULL_COULD_NOT_MOVE)
            .. MHCWL.GetItemCountText(failed)
            .. "."
        )
    end

    if missing > 0 then
        table.insert(
            lines,
            GetString(MHCWL_NOTIFY_GEAR_FETCH_MISSING)
            .. MHCWL.GetItemCountText(missing)
            .. "."
        )
    end

    if missing == 0 and failed == 0 then
        table.insert(
            lines,
            GetString(MHCWL_NOTIFY_GEAR_FETCH_COMPLETE_MOVED)
            .. MHCWL.GetItemCountText(moved)
            .. "."
        )
    else
        table.insert(
            lines,
            GetString(MHCWL_NOTIFY_GEAR_FETCH_MOVED)
            .. MHCWL.GetItemCountText(moved)
            .. "."
        )
    end

    return table.concat(lines, "\n")
end

function MHCWL.BuildGearStoreResultMessage(moved, failed)
    local lines = {}

    if failed > 0 then
        table.insert(
            lines,
            GetString(MHCWL_NOTIFY_BANK_FULL_COULD_NOT_MOVE)
            .. MHCWL.GetItemCountText(failed)
            .. "."
        )
    end

    if failed == 0 then
        table.insert(
            lines,
            GetString(MHCWL_NOTIFY_GEAR_STORE_COMPLETE_MOVED)
            .. MHCWL.GetItemCountText(moved)
            .. "."
        )
    else
        table.insert(
            lines,
            GetString(MHCWL_NOTIFY_GEAR_STORE_MOVED)
            .. MHCWL.GetItemCountText(moved)
            .. "."
        )
    end

    return table.concat(lines, "\n")
end

-- Build a fetch queue for all missing gear belonging to one loadout.
-- Execution starts when the player opens a bank.
function MHCWL.QueueMissingGearFetch(index)
    index = tonumber(index)

    local companionData = MHCWL.GetActiveCompanionSavedData()
    if not companionData then return false end

    MHCWL.EnsureCompanionSetups(companionData)

    local setup = companionData.setups[index]
    if not setup then return false end

    local warnings = MHCWL.GetSetupWarnings(setup)

    if not warnings.missingGear
    or #warnings.missingGear == 0 then
        MHCWL.Notify(GetString(MHCWL_NOTIFY_NO_MISSING_GEAR))
        return false
    end

    local queue = {}

    for _, equipSlot in ipairs(warnings.missingGear) do
        local saved = setup.gear and setup.gear[equipSlot]

        if saved
        and saved.link
        and saved.link ~= "" then

            table.insert(queue, {
                equipSlot = equipSlot,
                saved = saved,
            })

            MHCWL.Debug(
                "Queued slot "
                .. tostring(equipSlot)
                .. ": "
                .. tostring(saved.link)
            )
        end
    end

    if #queue == 0 then
        MHCWL.Notify(GetString(MHCWL_NOTIFY_NO_FETCHABLE_GEAR))
        return false
    end

    MHCWL.pendingGearFetch = {
        loadoutIndex = index,
        loadoutName = setup.name,
        queue = queue,
    }

    MHCWL.Debug(
        "Queued "
        .. tostring(#queue)
        .. " items for bank fetch."
    )

    MHCWL.Notify(GetString(MHCWL_NOTIFY_GEAR_FETCH_QUEUED))

    return true
end

-- Entry point for pending fetch/store operations once bank access becomes available.
function MHCWL.OnBankOpenedForGearFetch()
    local fetch = MHCWL.pendingGearFetch

    if fetch then
        if fetch.processing then return end
        fetch.processing = true

        MHCWL.Debug("Bank opened with pending gear fetch.")

        if not fetch.queue or #fetch.queue == 0 then
            MHCWL.Notify(GetString(MHCWL_NOTIFY_GEAR_FETCH_CANCELED_EMPTY))
            MHCWL.pendingGearFetch = nil
            return
        end

        MHCWL.Debug(
            "Pending fetch for "
            .. tostring(fetch.loadoutName)
            .. ": "
            .. tostring(#fetch.queue)
            .. " item(s)."
        )

        MHCWL.ProcessGearFetchQueue(fetch, 1, 0, 0, 0)
        return
    end

    local store = MHCWL.pendingGearStore

    if store then
        if store.processing then return end
        store.processing = true

        MHCWL.Debug("Bank opened with pending gear store.")

        if not store.queue or #store.queue == 0 then
            MHCWL.Notify(GetString(MHCWL_NOTIFY_GEAR_STORE_CANCELED_EMPTY))
            MHCWL.pendingGearStore = nil
            return
        end

        MHCWL.Debug(
            "Pending store for "
            .. tostring(store.loadoutName)
            .. ": "
            .. tostring(#store.queue)
            .. " item(s)."
        )

        MHCWL.ProcessGearStoreQueue(store, 1, 0, 0)
    end
end

-- Process queued fetch operations one item at a time to avoid ESO timing issues.
function MHCWL.ProcessGearFetchQueue(fetch, index, moved, missing, failed)
    index = index or 1
    moved = moved or 0
    missing = missing or 0
    failed = failed or 0

    if not fetch or not fetch.queue then
        MHCWL.pendingGearFetch = nil
        return
    end

    if index > #fetch.queue then
        MHCWL.Debug(
            "Gear fetch finished. moved="
            .. tostring(moved)
            .. " missing="
            .. tostring(missing)
            .. " failed="
            .. tostring(failed)
        )

        MHCWL.Notify(MHCWL.BuildGearFetchResultMessage(moved, missing, failed))

        if MHCWL.window then
            MHCWL.RebuildWindowContent()
        end

        MHCWL.RefreshOpenInspectWindow()

        MHCWL.pendingGearFetch = nil
        return
    end

    local entry = fetch.queue[index]
    local saved = entry.saved
    local equipSlot = entry.equipSlot

    local bankBag, bankSlot, matchType = MHCWL.FindSavedItemInBank(saved)

    MHCWL.Debug(
        "Fetch search "
        .. MHCWL.SlotName(equipSlot)
        .. " savedId="
        .. tostring(saved.id)
        .. " itemId="
        .. tostring(saved.link and GetItemLinkItemId(saved.link) or "-")
        .. " bankBag="
        .. tostring(bankBag)
        .. " bankSlot="
        .. tostring(bankSlot)
        .. " matchType="
        .. tostring(matchType)
    )

    if bankBag and bankSlot then
        if GetNumBagFreeSlots(BAG_BACKPACK) <= 0 then
            MHCWL.Debug("Backpack full. Could not fetch: " .. tostring(saved.link))
            failed = failed + 1
        else
            local backpackSlot = MHCWL.FindFirstEmptyBackpackSlot()

            if not backpackSlot then
                MHCWL.Debug("No free backpack slot found. Could not fetch: " .. tostring(saved.link))
                failed = failed + 1
            else
                MHCWL.Debug(
                    "Fetching "
                    .. MHCWL.SlotName(equipSlot)
                    .. " from bank bag "
                    .. tostring(bankBag)
                    .. " slot "
                    .. tostring(bankSlot)
                    .. " to backpack slot "
                    .. tostring(backpackSlot)
                    .. " via "
                    .. tostring(matchType)
                    .. ": "
                    .. tostring(saved.link)
                )

                CallSecureProtected(
                    "RequestMoveItem",
                    bankBag,
                    bankSlot,
                    BAG_BACKPACK,
                    backpackSlot,
                    1
                )

                moved = moved + 1
            end
        end
    else
        MHCWL.Debug(
            "Not found in bank: "
            .. MHCWL.SlotName(equipSlot)
            .. " / "
            .. tostring(saved.link)
        )

        missing = missing + 1
    end

    zo_callLater(function()
        MHCWL.ProcessGearFetchQueue(fetch, index + 1, moved, missing, failed)
    end, MHCWL.GetDelay(MHCWL.TIMINGS.gearMoveStep))
end

-- Auto Store

-- Build a store queue for all saved gear currently found in the backpack.
function MHCWL.QueueLoadoutGearStore(index)
    index = tonumber(index)

    local companionData = MHCWL.GetActiveCompanionSavedData()
    if not companionData then return false end

    MHCWL.EnsureCompanionSetups(companionData)

    local setup = companionData.setups[index]
    if not setup or not setup.gear then return false end

    local queue = {}

    for equipSlot, saved in pairs(setup.gear) do
        local backpackSlot, matchType = MHCWL.FindSavedItemInBag(saved, BAG_BACKPACK)

        if backpackSlot then
            table.insert(queue, {
                equipSlot = equipSlot,
                saved = saved,
            })

            MHCWL.Debug(
                "Queued store "
                .. MHCWL.SlotName(equipSlot)
                .. " via "
                .. tostring(matchType)
                .. ": "
                .. tostring(saved.link)
            )
        end
    end

    if #queue == 0 then
        MHCWL.Notify(GetString(MHCWL_NOTIFY_NO_STORABLE_GEAR))
        return false
    end

    MHCWL.pendingGearStore = {
        loadoutIndex = index,
        loadoutName = setup.name,
        queue = queue,
    }

    MHCWL.Debug(
        "Queued "
        .. tostring(#queue)
        .. " items for bank store."
    )

    MHCWL.Notify(GetString(MHCWL_NOTIFY_GEAR_STORE_QUEUED))

    return true
end

-- Process queued bank storage operations one item at a time.
function MHCWL.ProcessGearStoreQueue(store, index, moved, failed)
    index = index or 1
    moved = moved or 0
    failed = failed or 0

    if not store or not store.queue then
        MHCWL.pendingGearStore = nil
        return
    end

    if index > #store.queue then
        MHCWL.Debug(
            "Gear store finished. moved="
            .. tostring(moved)
            .. " failed="
            .. tostring(failed)
        )

        MHCWL.Notify(MHCWL.BuildGearStoreResultMessage(moved, failed))

        if MHCWL.window then
            MHCWL.RebuildWindowContent()
        end

        MHCWL.RefreshOpenInspectWindow()

        MHCWL.pendingGearStore = nil
        return
    end

    local entry = store.queue[index]
    local saved = entry.saved
    local equipSlot = entry.equipSlot

    local backpackSlot, matchType = MHCWL.FindSavedItemInBag(saved, BAG_BACKPACK)

    MHCWL.Debug(
        "Store search "
        .. MHCWL.SlotName(equipSlot)
        .. " backpackSlot="
        .. tostring(backpackSlot)
        .. " matchType="
        .. tostring(matchType)
    )

    if backpackSlot then
        local bankBag, bankSlot = MHCWL.FindFirstEmptyBankSlot()

        if not bankBag or not bankSlot then
            MHCWL.Debug("Bank full. Could not store: " .. tostring(saved.link))
            failed = failed + 1
        else
            MHCWL.Debug(
                "Storing "
                .. MHCWL.SlotName(equipSlot)
                .. " from backpack slot "
                .. tostring(backpackSlot)
                .. " to bank bag "
                .. tostring(bankBag)
                .. " slot "
                .. tostring(bankSlot)
                .. " via "
                .. tostring(matchType)
                .. ": "
                .. tostring(saved.link)
            )

            CallSecureProtected(
                "RequestMoveItem",
                BAG_BACKPACK,
                backpackSlot,
                bankBag,
                bankSlot,
                1
            )

            moved = moved + 1
        end
    else
        MHCWL.Debug(
            "Not found in backpack for store: "
            .. MHCWL.SlotName(equipSlot)
            .. " / "
            .. tostring(saved.link)
        )
    end

    zo_callLater(function()
        MHCWL.ProcessGearStoreQueue(store, index + 1, moved, failed)
    end, MHCWL.GetDelay(MHCWL.TIMINGS.gearMoveStep))
end