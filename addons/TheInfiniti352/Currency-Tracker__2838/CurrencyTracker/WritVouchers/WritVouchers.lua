-- Event Tickets tracking file
CurrencyTracker.WritVouchers = {}

function CurrencyTracker.WritVouchers.Initialize()

    if (not CurrencyTracker.savedVariables.writVouchers.tracking) then
        GUI_WritVouchersWarning:SetHidden(true)
        return
    end

    CurrencyTracker.WritVouchers.OnAmountThresholdChanged()

    CurrencyTracker.WritVouchers.ShowWritVouchersWarning(CurrencyTracker.WritVouchers.displayWarning)

    -- Writ vouchers warning restore
    local left = CurrencyTracker.savedVariables.writVouchers.GUILeft
    local top = CurrencyTracker.savedVariables.writVouchers.GUITop

    GUI_WritVouchersWarning:ClearAnchors()
    GUI_WritVouchersWarning:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function CurrencyTracker.WritVouchers.OnCurrencyUpdate(currencyLocation, newAmount, oldAmount, reason)
    if (currencyLocation == CURRENCY_LOCATION_CHARACTER) then
        -- Detects if writ vouchers quantity >= threshold
        CurrencyTracker.WritVouchers.displayWarning = (newAmount >=
                                                          CurrencyTracker.savedVariables.writVouchers.amountThreshold)
        CurrencyTracker.WritVouchers.ShowWritVouchersWarning(true)
    end
end

function CurrencyTracker.WritVouchers.OnAmountThresholdChanged()
    -- Update the message along to the treshold
    CurrencyTracker.WritVouchers.displayWarning = (GetCurrencyAmount(CURT_WRIT_VOUCHERS, CURRENCY_LOCATION_CHARACTER) >=
                                                      CurrencyTracker.savedVariables.writVouchers.amountThreshold)
end

function CurrencyTracker.WritVouchers.ShowWritVouchersWarning(show)
    local display = show and
                        (CurrencyTracker.WritVouchers.displayWarning or
                            CurrencyTracker.savedVariables.writVouchers.alwaysDisplay)
    GUI_WritVouchersWarning:SetHidden(not display)
    if (display) then
        GUI_WritVouchersWarningText:SetText(GetCurrencyAmount(CURT_WRIT_VOUCHERS, CURRENCY_LOCATION_CHARACTER))
    end
end

function CurrencyTracker.WritVouchers.OnIndicatorMoveStopWritVouchersWarning()
    CurrencyTracker.savedVariables.writVouchers.GUILeft = GUI_WritVouchersWarning:GetLeft()
    CurrencyTracker.savedVariables.writVouchers.GUITop = GUI_WritVouchersWarning:GetTop()
end
