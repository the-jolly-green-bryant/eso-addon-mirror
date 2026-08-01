ToonCash = {}
 
ToonCash.name = "ToonCash"
ToonCash.version = 1
ToonCash.default_vars = { toon_info = {}, ap_info = {}, tv_info = {}, wv_info = {}}

local CommaValue = nil

function ToonCash.OnCashUpdate (...)
    local current_gold = GetCurrentMoney()
    local character_name = GetUnitName("player")

    ToonCash.savedVariables.toon_info[character_name] = current_gold
end

function ToonCash.OnTVUpdate (...)
    local current_tv = GetCarriedCurrencyAmount(CURT_TELVAR_STONES)
    local character_name = GetUnitName("player")

    ToonCash.savedVariables.tv_info[character_name] = current_tv
end

function ToonCash.OnWVUpdate (...)
    local current_wv = GetCarriedCurrencyAmount(CURT_WRIT_VOUCHERS)
    local character_name = GetUnitName("player")

    ToonCash.savedVariables.wv_info[character_name] = current_wv
end

function ToonCash.OnAPGained (...)
    local current_ap = GetAlliancePoints()
    local character_name = GetUnitName("player")

    ToonCash.savedVariables.ap_info[character_name] = current_ap
end

function ToonCash:Initialize()
    ToonCash.savedVariables = ZO_SavedVars:NewAccountWide("ToonCash_SavedVariables", ToonCash.version, nil, ToonCash.default_vars)

    if not ToonCash.savedVariables.ap_info then
        ToonCash.savedVariables.ap_info = {}
    end

    if not ToonCash.savedVariables.tv_info then
        ToonCash.savedVariables.tv_info = {}
    end

    if not ToonCash.savedVariables.wv_info then
        ToonCash.savedVariables.wv_info = {}
    end

    if LUIE == nil then
        CommaValue = function (i) return i end
    else
        CommaValue = LUIE.CommaValue
    end

    ToonCash.OnCashUpdate()
    ToonCash.OnAPGained()
    ToonCash.OnWVUpdate()
    ToonCash.OnTVUpdate()

    EVENT_MANAGER:RegisterForEvent(ToonCash.name, EVENT_MONEY_UPDATE, ToonCash.OnCashUpdate)
    EVENT_MANAGER:RegisterForEvent(ToonCash.name, EVENT_ALLIANCE_POINT_UPDATE, ToonCash.OnAPGained)
    EVENT_MANAGER:RegisterForEvent(ToonCash.name, EVENT_TELVAR_STONE_UPDATE, ToonCash.OnTVUpdate)
    EVENT_MANAGER:RegisterForEvent(ToonCash.name, EVENT_WRIT_VOUCHER_UPDATE, ToonCash.OnWVUpdate)
end

function ToonCash.OnAddOnLoaded(event, addonName)
    if addonName == ToonCash.name then
        ToonCash:Initialize()
    end
end

function ToonCash.Interact ()
    local ti = ToonCash.savedVariables.toon_info

    local total = 0

    for k, v in pairs(ti) do
        total = total + v
        CHAT_SYSTEM:AddMessage("|c006400" .. k .. "|r: " .. CommaValue(v) .. "g")
    end

    local bank = GetBankedMoney()
    total = total + bank
    CHAT_SYSTEM:AddMessage("|c006400Bank|r: " .. CommaValue(bank) .. "g")

    if total ~= 0 then
        CHAT_SYSTEM:AddMessage("|c006400Total|r: " .. CommaValue(total) .. "g")
    else
        CHAT_SYSTEM:AddMessage("|c006400No data available for any characters!|r")
    end
end

function ToonCash.InteractAP ()
    local ti = ToonCash.savedVariables.ap_info

    local total = 0

    for k, v in pairs(ti) do
        total = total + v
        CHAT_SYSTEM:AddMessage("|c006400" .. k .. "|r: " .. CommaValue(v) .. " AP")
    end

    if total ~= 0 then
        CHAT_SYSTEM:AddMessage("|c006400Total|r: " .. CommaValue(total) .. " AP")
    else
        CHAT_SYSTEM:AddMessage("|c006400No data available for any characters!|r")
    end
end

function ToonCash.InteractWV ()
    local ti = ToonCash.savedVariables.wv_info

    local total = 0

    for k, v in pairs(ti) do
        if v ~= 0 then
            total = total + v
            CHAT_SYSTEM:AddMessage("|c006400" .. k .. "|r: " .. CommaValue(v) .. " WV")
        end
    end

    if total ~= 0 then
        CHAT_SYSTEM:AddMessage("|c006400Total|r: " .. CommaValue(total) .. " WV")
    else
        CHAT_SYSTEM:AddMessage("|c006400No data available for any characters!|r")
    end
end

function ToonCash.InteractTV ()
    local ti = ToonCash.savedVariables.tv_info

    local total = 0

    for k, v in pairs(ti) do
        if v ~= 0 then
            total = total + v
            CHAT_SYSTEM:AddMessage("|c006400" .. k .. "|r: " .. CommaValue(v) .. "TV")
        end
    end

    local bank = GetBankedCurrencyAmount(CURT_TELVAR_STONES)
    total = total + bank
    CHAT_SYSTEM:AddMessage("|c006400Bank|r: " .. CommaValue(bank) .. "TV")

    if total ~= 0 then
        CHAT_SYSTEM:AddMessage("|c006400Total|r: " .. CommaValue(total) .. "TV")
    else
        CHAT_SYSTEM:AddMessage("|c006400No data available for any characters!|r")
    end
end

SLASH_COMMANDS["/tooncash"] = ToonCash.Interact
SLASH_COMMANDS["/toonap"] = ToonCash.InteractAP
SLASH_COMMANDS["/toonwv"] = ToonCash.InteractWV
SLASH_COMMANDS["/toontv"] = ToonCash.InteractTV
 
EVENT_MANAGER:RegisterForEvent(ToonCash.name, EVENT_ADD_ON_LOADED, ToonCash.OnAddOnLoaded)
