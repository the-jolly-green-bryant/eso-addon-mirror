function Volette.savings.UpdateSavedVariables()
    -- Will be removed in a few versions
    if Volette.savings.savedVariables.enabledFor ~= nil then
        Volette.savings.savedVariables.goldSavingsEnabledFor = Volette.savings.savedVariables.enabledFor
        Volette.savings.savedVariables.enabledFor = nil
    end
    if Volette.savings.savedVariables.enabled ~= nil then
        Volette.savings.savedVariables.goldSavingsEnabled = Volette.savings.savedVariables.enabled
        Volette.savings.savedVariables.enabled = nil
    end
end

function Volette.savings.EnableGoldSavings(enabled, enabledFor)
    local characterId = GetCurrentCharacterId()

    if enabled ~= nil then
        Volette.savings.savedVariables.goldSavingsEnabled = enabled
        enabledFor = Volette.savings.savedVariables.goldSavingsEnabledFor[characterId]
    else
        Volette.savings.savedVariables.goldSavingsEnabledFor[characterId] = enabledFor
        enabled = Volette.savings.savedVariables.goldSavingsEnabled
    end

    local isEventNeededForGold = enabled and enabledFor
    local isEventNoLongerNeededForGold = not enabled and enabledFor
    local isEventUsedElsewhere = (
        Volette.savings.savedVariables.telVarSavingsEnabled and Volette.savings.savedVariables.telVarSavingsEnabledFor[characterId]
        or
        Volette.savings.savedVariables.apSavingsEnabled and Volette.savings.savedVariables.apSavingsEnabledFor[characterId]
        or
        Volette.savings.savedVariables.voucherSavingsEnabled and Volette.savings.savedVariables.voucherSavingsEnabledFor[characterId]
    )

    if isEventNeededForGold and not isEventUsedElsewhere then
        EVENT_MANAGER:RegisterForEvent(Volette.name, EVENT_OPEN_BANK, Volette.savings.OnBankOpened)
    elseif isEventNoLongerNeededForGold and not isEventUsedElsewhere then
        EVENT_MANAGER:UnregisterForEvent(Volette.name, EVENT_OPEN_BANK)
    end
end

function Volette.savings.EnableTelVarSavings(enabled, enabledFor)
    local characterId = GetCurrentCharacterId()

    if enabled ~= nil then
        Volette.savings.savedVariables.telVarSavingsEnabled = enabled
        enabledFor = Volette.savings.savedVariables.telVarSavingsEnabledFor[characterId]
    else
        Volette.savings.savedVariables.telVarSavingsEnabledFor[characterId] = enabledFor
        enabled = Volette.savings.savedVariables.telVarSavingsEnabled
    end

    local isEventNeededForTelVar = enabled and enabledFor
    local isEventNoLongerNeededForTelVar = not enabled and enabledFor
    local isEventUsedElsewhere = (
        Volette.savings.savedVariables.goldSavingsEnabled and Volette.savings.savedVariables.goldSavingsEnabledFor[characterId]
        or
        Volette.savings.savedVariables.apSavingsEnabled and Volette.savings.savedVariables.apSavingsEnabledFor[characterId]
        or
        Volette.savings.savedVariables.voucherSavingsEnabled and Volette.savings.savedVariables.voucherSavingsEnabledFor[characterId]
    )

    if isEventNeededForTelVar and not isEventUsedElsewhere then
        EVENT_MANAGER:RegisterForEvent(Volette.name, EVENT_OPEN_BANK, Volette.savings.OnBankOpened)
    elseif isEventNoLongerNeededForTelVar and not isEventUsedElsewhere then
        EVENT_MANAGER:UnregisterForEvent(Volette.name, EVENT_OPEN_BANK)
    end
end

function Volette.savings.EnableAPSavings(enabled, enabledFor)
    local characterId = GetCurrentCharacterId()

    if enabled ~= nil then
        Volette.savings.savedVariables.apSavingsEnabled = enabled
        enabledFor = Volette.savings.savedVariables.apSavingsEnabledFor[characterId]
    else
        Volette.savings.savedVariables.apSavingsEnabledFor[characterId] = enabledFor
        enabled = Volette.savings.savedVariables.apSavingsEnabled
    end

    local isEventNeededForAP = enabled and enabledFor
    local isEventNoLongerNeededForAP = not enabled and enabledFor
    local isEventUsedElsewhere = (
        Volette.savings.savedVariables.goldSavingsEnabled and Volette.savings.savedVariables.goldSavingsEnabledFor[characterId]
        or
        Volette.savings.savedVariables.telVarSavingsEnabled and Volette.savings.savedVariables.telVarSavingsEnabledFor[characterId]
        or
        Volette.savings.savedVariables.voucherSavingsEnabled and Volette.savings.savedVariables.voucherSavingsEnabledFor[characterId]
    )

    if isEventNeededForAP and not isEventUsedElsewhere then
        EVENT_MANAGER:RegisterForEvent(Volette.name, EVENT_OPEN_BANK, Volette.savings.OnBankOpened)
    elseif isEventNoLongerNeededForAP and not isEventUsedElsewhere then
        EVENT_MANAGER:UnregisterForEvent(Volette.name, EVENT_OPEN_BANK)
    end
end

function Volette.savings.EnableVoucherSavings(enabled, enabledFor)
    local characterId = GetCurrentCharacterId()

    if enabled ~= nil then
        Volette.savings.savedVariables.voucherSavingsEnabled = enabled
        enabledFor = Volette.savings.savedVariables.voucherSavingsEnabledFor[characterId]
    else
        Volette.savings.savedVariables.voucherSavingsEnabledFor[characterId] = enabledFor
        enabled = Volette.savings.savedVariables.voucherSavingsEnabled
    end

    local isEventNeededForVoucher = enabled and enabledFor
    local isEventNoLongerNeededForVoucher = not enabled and enabledFor
    local isEventUsedElsewhere = (
        Volette.savings.savedVariables.goldSavingsEnabled and Volette.savings.savedVariables.goldSavingsEnabledFor[characterId]
        or
        Volette.savings.savedVariables.telVarSavingsEnabled and Volette.savings.savedVariables.telVarSavingsEnabledFor[characterId]
        or
        Volette.savings.savedVariables.apSavingsEnabled and Volette.savings.savedVariables.apSavingsEnabledFor[characterId]
    )

    if isEventNeededForVoucher and not isEventUsedElsewhere then
        EVENT_MANAGER:RegisterForEvent(Volette.name, EVENT_OPEN_BANK, Volette.savings.OnBankOpened)
    elseif isEventNoLongerNeededForVoucher and not isEventUsedElsewhere then
        EVENT_MANAGER:UnregisterForEvent(Volette.name, EVENT_OPEN_BANK)
    end
end

function Volette.savings.CheckAmount(currencyType, minCurrencyAmount, maxCurrencyAmount)
    local currentCurrencyAmount = GetCurrencyAmount(currencyType, CURRENCY_LOCATION_CHARACTER)
    if currentCurrencyAmount > maxCurrencyAmount then  -- Check if we need a deposit
        local depositAmount
        local baseDeposit = maxCurrencyAmount - minCurrencyAmount
        if baseDeposit == 0 then
            depositAmount = currentCurrencyAmount - maxCurrencyAmount
        else
            local factor = math.floor((currentCurrencyAmount - maxCurrencyAmount) / baseDeposit) + 1
            depositAmount = factor * baseDeposit
        end
        DepositCurrencyIntoBank(currencyType, depositAmount)
        local extraOptions =
        {
            iconInheritColor = true,
        }
        local formattedDepositAmount = zo_strformat(
            SI_NUMBER_FORMAT,
            ZO_Currency_FormatKeyboard(
                currencyType,
                depositAmount,
                ZO_CURRENCY_FORMAT_AMOUNT_ICON,
                extraOptions
            )
        )
        d(Volette.GetText(VOLETTE_SAVINGS_DEPOSIT, formattedDepositAmount))
    elseif currentCurrencyAmount < minCurrencyAmount then  -- Check if we need a withdrawal
        local withdrawalAmount
        local baseWithdrawal = maxCurrencyAmount - minCurrencyAmount
        if baseWithdrawal == 0 then
            withdrawalAmount = minCurrencyAmount - currentCurrencyAmount
        else
            local factor = math.floor((minCurrencyAmount - currentCurrencyAmount) / baseWithdrawal) + 1
            withdrawalAmount = factor * baseWithdrawal
        end
        if withdrawalAmount ~= 0 and (withdrawalAmount + currentCurrencyAmount == maxCurrencyAmount) then
            withdrawalAmount = minCurrencyAmount
        end
        local currencyAmountInBank = GetCurrencyAmount(currencyType, CURRENCY_LOCATION_BANK)
        local extraOptions =
        {
            iconInheritColor = true,
        }
        local formattedWithdrawalAmount = zo_strformat(
            SI_NUMBER_FORMAT,
            ZO_Currency_FormatKeyboard(
                currencyType,
                withdrawalAmount,
                ZO_CURRENCY_FORMAT_AMOUNT_ICON,
                extraOptions
            )
        )
        if withdrawalAmount <= currencyAmountInBank then  -- Check if we have enough to withdraw
            WithdrawCurrencyFromBank(currencyType, withdrawalAmount)

            d(Volette.GetText(VOLETTE_SAVINGS_WITHDRAWAL, formattedWithdrawalAmount))
        else
            d(Volette.GetText(VOLETTE_SAVINGS_NOT_ENOUGH_CURRENCIES, formattedWithdrawalAmount))
        end
    end
end

function Volette.savings.OnBankOpened()
    local characterId = GetCurrentCharacterId()
    if Volette.savings.savedVariables.goldSavingsEnabled and Volette.savings.savedVariables.goldSavingsEnabledFor[characterId] then
        Volette.savings.CheckAmount(  -- Check gold
            CURT_MONEY,
            Volette.savings.savedVariables.minimumGoldAmount,
            Volette.savings.savedVariables.maximumGoldAmount
        )
    end
    if Volette.savings.savedVariables.telVarSavingsEnabled and Volette.savings.savedVariables.telVarSavingsEnabledFor[characterId] then
        Volette.savings.CheckAmount(  -- Check Tel Var
            CURT_TELVAR_STONES,
            Volette.savings.savedVariables.minimumTelVarAmount,
            Volette.savings.savedVariables.maximumTelVarAmount
        )
    end
    if Volette.savings.savedVariables.apSavingsEnabled and Volette.savings.savedVariables.apSavingsEnabledFor[characterId] then
        Volette.savings.CheckAmount(  -- Check Alliance Points
            CURT_ALLIANCE_POINTS,
            Volette.savings.savedVariables.minimumAPAmount,
            Volette.savings.savedVariables.maximumAPAmount
        )
    end
    if Volette.savings.savedVariables.voucherSavingsEnabled and Volette.savings.savedVariables.voucherSavingsEnabledFor[characterId] then
        Volette.savings.CheckAmount(  -- Check Writ Vouchers
            CURT_WRIT_VOUCHERS,
            Volette.savings.savedVariables.minimumVoucherAmount,
            Volette.savings.savedVariables.maximumVoucherAmount
        )
    end
end

-- Functions for dynamic settings

function Volette.savings.GetMinimumGoldAmount()
    local minValue = math.min(
        Volette.savings.savedVariables.minimumGoldAmount,
        Volette.savings.savedVariables.maximumGoldAmount
    )
    Volette.savings.savedVariables.minimumGoldAmount = minValue
    return minValue
end

function Volette.savings.SetMinimumGoldAmount(value)
    Volette.savings.savedVariables.minimumGoldAmount = value
    if value > Volette.savings.savedVariables.maximumGoldAmount then
        Volette.savings.savedVariables.maximumGoldAmount = value
    end
end

function Volette.savings.GetMinimumTelVarAmount()
    local minValue = math.min(
        Volette.savings.savedVariables.minimumTelVarAmount,
        Volette.savings.savedVariables.maximumTelVarAmount
    )
    Volette.savings.savedVariables.minimumTelVarAmount = minValue
    return minValue
end

function Volette.savings.SetMinimumTelVarAmount(value)
    Volette.savings.savedVariables.minimumTelVarAmount = value
    if value > Volette.savings.savedVariables.maximumTelVarAmount then
        Volette.savings.savedVariables.maximumTelVarAmount = value
    end
end

function Volette.savings.GetMinimumAPAmount()
    local minValue = math.min(
        Volette.savings.savedVariables.minimumAPAmount,
        Volette.savings.savedVariables.maximumAPAmount
    )
    Volette.savings.savedVariables.minimumAPAmount = minValue
    return minValue
end

function Volette.savings.SetMinimumAPAmount(value)
    Volette.savings.savedVariables.minimumAPAmount = value
    if value > Volette.savings.savedVariables.maximumAPAmount then
        Volette.savings.savedVariables.maximumAPAmount = value
    end
end

function Volette.savings.GetMinimumVoucherAmount()
    local minValue = math.min(
        Volette.savings.savedVariables.minimumVoucherAmount,
        Volette.savings.savedVariables.maximumVoucherAmount
    )
    Volette.savings.savedVariables.minimumVoucherAmount = minValue
    return minValue
end

function Volette.savings.SetMinimumVoucherAmount(value)
    Volette.savings.savedVariables.minimumVoucherAmount = value
    if value > Volette.savings.savedVariables.maximumVoucherAmount then
        Volette.savings.savedVariables.maximumVoucherAmount = value
    end
end
