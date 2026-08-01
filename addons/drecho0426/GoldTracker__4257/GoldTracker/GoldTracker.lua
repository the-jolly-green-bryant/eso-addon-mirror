local function GetTotalGold()
    local totalGold = 0

    local goldTable = GoldTrackerSaved.default and GoldTrackerSaved.default.goldByChar or {}
    for charName, gold in pairs(goldTable) do
        if type(gold) == "number" then
            totalGold = totalGold + gold
            d(charName .. " has " .. gold .. " gold")
        else
            d("Skipping non-numeric entry: " .. tostring(charName))
        end
    end

    local bankGold = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_BANK)
    totalGold = totalGold + bankGold
    d("Bank has " .. bankGold .. " gold")

    return totalGold
end

local function UpdateGoldDisplay()
    local totalGold = GetTotalGold()
    GoldTrackerLabel:SetText("Total Gold: " .. ZO_Currency_FormatPlatform(CURT_MONEY, totalGold, ZO_CURRENCY_FORMAT_AMOUNT_ICON))
end

local function OnAddonLoaded(event, addonName)
    if addonName == "GoldTracker" then
        d("GoldTracker loaded!")

        GoldTrackerSaved = ZO_SavedVars:NewAccountWide("GoldTrackerSaved", 1, "default", {
            goldByChar = {}
        })

        GoldTrackerWindow:SetHidden(false)
    end
end

local function OnPlayerActivated()
    local currentCharName = GetUnitName("player")
    local currentGold = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)

    GoldTrackerSaved.default.goldByChar = GoldTrackerSaved.default.goldByChar or {}
    GoldTrackerSaved.default.goldByChar[currentCharName] = currentGold
    GoldTrackerSaved.default.lastUpdated = GetTimeStamp()

    d(currentCharName .. " activated with " .. currentGold .. " gold")

    UpdateGoldDisplay()

    -- Show donation message in red
    CHAT_SYSTEM:AddMessage("|cFF0000I work hard to keep addons up to date and working properly. Donations are welcome! You can mail donations to @XxDrEchoxX.|r")
end

local function OnGoldChanged(eventCode, newGold, oldGold, reason)
    local currentCharName = GetUnitName("player")

    GoldTrackerSaved.default.goldByChar = GoldTrackerSaved.default.goldByChar or {}
    GoldTrackerSaved.default.goldByChar[currentCharName] = newGold
    GoldTrackerSaved.default.lastUpdated = GetTimeStamp()

    d(currentCharName .. " gold changed: " .. oldGold .. " → " .. newGold)

    UpdateGoldDisplay()
end

EVENT_MANAGER:RegisterForEvent("GoldTracker", EVENT_ADD_ON_LOADED, OnAddonLoaded)
EVENT_MANAGER:RegisterForEvent("GoldTracker_Activated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
EVENT_MANAGER:RegisterForEvent("GoldTracker_GoldChanged", EVENT_MONEY_UPDATE, OnGoldChanged)
