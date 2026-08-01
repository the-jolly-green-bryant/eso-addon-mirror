LootLog = LootLog or {}
local LL = LootLog

LL.name = "LootLog"
LL.savedVarsName = "LootLogSavedVars"
LL.savedVarsVersion = 1

local function OnAddonLoaded(_, addonName)
    if addonName ~= LL.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(LL.name, EVENT_ADD_ON_LOADED)

    LL.saved = ZO_SavedVars:NewAccountWide(
        LL.savedVarsName,
        LL.savedVarsVersion,
        nil,
        {
            lifetime = { items = {}, currencyByReason = {}, instances = {}, startedAt = 0, currencyStartedAt = 0 },
            manual = { items = {}, currencyByReason = {}, instances = {}, startedAt = 0, currencyStartedAt = 0 },
            settings = { debug = false, eventProbe = false, uiScale = 1.0 },
        }
    )
    local migrationResult = LL.EnsureSaved()
    LL.EnsureSession()
    if LL.saved and LL.saved.settings and LL.saved.settings.uiScale ~= nil then
        LL.SetUIScale(LL.saved.settings.uiScale)
    end
    if migrationResult and migrationResult.didReset then
        LL.Print("Data format changed, so saved data was reset. Sorry for the wipe. We try to keep this to a minimum, even during beta.")
    elseif migrationResult and migrationResult.didSimplifyInteractionTotals then
        LL.Print("Saved interaction data was updated to the new total-only format.")
    elseif migrationResult and migrationResult.didResetCurrencyTotals then
        LL.Print("Saved currency totals were reset so new currency data can be tracked by reason.")
    end

    if EVENT_LOOT_RECEIVED ~= nil then
        EVENT_MANAGER:RegisterForEvent(LL.name, EVENT_LOOT_RECEIVED, LL.OnLootReceived)
    end
    if EVENT_LOOT_CLOSED ~= nil then
        EVENT_MANAGER:RegisterForEvent(LL.name, EVENT_LOOT_CLOSED, LL.OnLootClosed)
    end
    if EVENT_LOOT_UPDATED ~= nil then
        EVENT_MANAGER:RegisterForEvent(LL.name, EVENT_LOOT_UPDATED, LL.OnLootUpdated)
    end
    if EVENT_LOOT_TARGET_UPDATED ~= nil then
        EVENT_MANAGER:RegisterForEvent(LL.name, EVENT_LOOT_TARGET_UPDATED, LL.OnLootTargetUpdated)
    end
    if EVENT_LOOT_ITEM_FAILED ~= nil then
        EVENT_MANAGER:RegisterForEvent(LL.name, EVENT_LOOT_ITEM_FAILED, LL.OnLootItemFailed)
    end
    if EVENT_PLAYER_DEAD ~= nil then
        EVENT_MANAGER:RegisterForEvent(LL.name, EVENT_PLAYER_DEAD, LL.OnPlayerDead)
    end
    if EVENT_INVENTORY_SINGLE_SLOT_UPDATE ~= nil then
        EVENT_MANAGER:RegisterForEvent(LL.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, LL.OnInventorySingleSlotUpdate)
    end
    if EVENT_INVENTORY_FULL_UPDATE ~= nil then
        EVENT_MANAGER:RegisterForEvent(LL.name, EVENT_INVENTORY_FULL_UPDATE, LL.OnInventoryFullUpdate)
    end
    if EVENT_CURRENCY_UPDATE ~= nil then
        EVENT_MANAGER:RegisterForEvent(LL.name, EVENT_CURRENCY_UPDATE, LL.OnCurrencyUpdate)
    end
    if EVENT_PENDING_CURRENCY_REWARD_CACHED ~= nil then
        EVENT_MANAGER:RegisterForEvent(LL.name, EVENT_PENDING_CURRENCY_REWARD_CACHED, LL.OnPendingCurrencyRewardCached)
    end

    SLASH_COMMANDS["/lootlog"] = LL.HandleSlashCommand
    SLASH_COMMANDS["/ll"] = LL.HandleSlashCommand

    LL.RegisterAddonMenu()
    LL.RegisterRadialMenu()

    LL.Print("Loaded. Open the Loot Log window via addon settings, the radial menu, or /lootlog ui.")
end

EVENT_MANAGER:RegisterForEvent(LL.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
