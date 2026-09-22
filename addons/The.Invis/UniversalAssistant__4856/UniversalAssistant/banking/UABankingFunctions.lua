local ua = UAssistant
ua.Banking = ua.Banking or {}
local banking = ua.Banking

function banking.GetGameString(stringId, fallback)
    if ua.GetLanguageCode() == "ua" and fallback then
        return fallback
    end

    if stringId then
        local value = GetString(stringId)

        if value and value ~= "" then
            return zo_strformat("<<C:1>>", value)
        end
    end

    return fallback
end

function banking.GetItemTypeName(itemType, fallback)
    if ua.GetLanguageCode() == "ua" and fallback then
        return fallback
    end

    local value = GetString("SI_ITEMTYPE", itemType)

    if value and value ~= "" then
        return zo_strformat("<<C:1>>", value)
    end

    return fallback or tostring(itemType)
end

function banking.GetSpecializedItemTypeName(specializedItemType, fallback)
    if ua.GetLanguageCode() == "ua" and fallback then
        return fallback
    end

    local value = GetString("SI_SPECIALIZEDITEMTYPE", specializedItemType)

    if value and value ~= "" then
        return zo_strformat("<<C:1>>", value)
    end

    return fallback or tostring(specializedItemType)
end

function banking.GetBankModeChoices()
    return {
        ua.GetString("BANKING_MODE_NONE"),
        banking.GetGameString(SI_BANK_DEPOSIT, ua.GetString("BANKING_MODE_DEPOSIT")),
        banking.GetGameString(SI_BANK_WITHDRAW, ua.GetString("BANKING_MODE_WITHDRAW")),
    }
end

function banking.Initialize()
    banking.Currencies.Initialize()
    banking.AutoBanking.Initialize()
end
