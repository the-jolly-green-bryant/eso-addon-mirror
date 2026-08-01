CurrencyTracker = {}

-- AddOn variables
CurrencyTracker.name = "CurrencyTracker"
CurrencyTracker.coloredName = "|ccc0000Curr|cff3300ency |cff9933Trac|cff9966ker|r"
CurrencyTracker.author = "|cff6600Infenix|r"
CurrencyTracker.version = "1.0.13"
CurrencyTracker.website = "https://github.com/ImInfenix/CurrencyTracker"

function CurrencyTracker.Initialize()
    CurrencyTracker.savedVariables = ZO_SavedVars:NewAccountWide("CurrencyTracker_SavedVariables", 1, nil, {})
    CurrencyTracker.displayAddonLoadedMessage = CurrencyTracker.savedVariables.displayAddonLoadedMessage

    -- LibAddonMenu-2.0 Initializing
    CurrencyTracker.InitializeLAM()

    -- EventTickets Initializing
    CurrencyTracker.EventTickets.Initialize()

    -- WritVouchers Initializing
    CurrencyTracker.WritVouchers.Initialize()

    EVENT_MANAGER:RegisterForEvent(CurrencyTracker.name, EVENT_PLAYER_ACTIVATED, CurrencyTracker.OnPlayerActivated)

    EVENT_MANAGER:RegisterForEvent(CurrencyTracker.name, EVENT_ACTION_LAYER_POPPED, CurrencyTracker.LayerPopped)
    EVENT_MANAGER:RegisterForEvent(CurrencyTracker.name, EVENT_ACTION_LAYER_PUSHED, CurrencyTracker.LayerPushed)
    EVENT_MANAGER:RegisterForEvent(CurrencyTracker.name, EVENT_CURRENCY_UPDATE, CurrencyTracker.OnCurrencyUpdate)
end

function CurrencyTracker.OnAddOnLoaded(eventCode, addonName)
    if (addonName ~= CurrencyTracker.name or isLoaded) then
        return
    end

    -- Unregister for load event
    EVENT_MANAGER:UnregisterForEvent(addonName, eventCode)

    CurrencyTracker.Initialize()
end

function CurrencyTracker.OnPlayerActivated(eventCode)

    -- Unregister for player activated event
    EVENT_MANAGER:UnregisterForEvent(addonName, eventCode)

    if (CurrencyTracker.displayAddonLoadedMessage) then
        d(CurrencyTracker.coloredName .. " addon loaded.")
        CurrencyTracker.displayAddonLoadedMessage = false
    end
end

function CurrencyTracker.OnCurrencyUpdate(eventCode, currencyType, currencyLocation, newAmount, oldAmount, reason)
    if (currencyType == CURT_EVENT_TICKETS) then
        CurrencyTracker.EventTickets.OnCurrencyUpdate(currencyLocation, newAmount, oldAmount, reason)
    end
    if (currencyType == CURT_WRIT_VOUCHERS) then
        CurrencyTracker.WritVouchers.OnCurrencyUpdate(currencyLocation, newAmount, oldAmount, reason)
    end
end

function CurrencyTracker.LayerPopped(eventCode, layerIndex, activeLayerIndex)
    -- Shows warning when going back to game
    CurrencyTracker.EventTickets.ShowEventTicketsWarning(activeLayerIndex == 2)
    CurrencyTracker.WritVouchers.ShowWritVouchersWarning(activeLayerIndex == 2)
end

function CurrencyTracker.LayerPushed(eventCode, layerIndex, activeLayerIndex)
    -- Hides warning when opening any menu
    CurrencyTracker.EventTickets.ShowEventTicketsWarning(activeLayerIndex == 2)
    CurrencyTracker.WritVouchers.ShowWritVouchersWarning(activeLayerIndex == 2)
end

EVENT_MANAGER:RegisterForEvent(CurrencyTracker.name, EVENT_ADD_ON_LOADED, CurrencyTracker.OnAddOnLoaded)
