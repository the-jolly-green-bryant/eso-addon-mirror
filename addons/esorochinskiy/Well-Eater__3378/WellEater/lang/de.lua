WellEater = WellEater or {}
local L = {
    generalSetupDescription = "Lässt es Ihnen, nach die Essen- oder Trinken-Bufffs auslaufen, im Inventar" ..
            " gefundene Gericht automatisch essen. Auch gibt es eine Waffenautoeinladung und eine automatische Reparatur",
    foodQualityHeader = "Die Qualität der suchenden Lebensmittel",
    foodQualityDescription = "Lasst die Qualität der Lebensmittel auswahlen",
    foods = {
        [ITEM_QUALITY_MAGIC] = "|c00FB00Gut|r",
        [ITEM_QUALITY_ARCANE] = "|c0077FFAusgezeichnet|r",
        [ITEM_QUALITY_ARTIFACT] = "|c9400D3Episch|r",
        [ITEM_QUALITY_LEGENDARY] = "|cFFFF00Legendär|r",
    },
    timerSetupHeader = "Abfragezeitmeter für den Charakterstatus",
    timerSetupLabel = "Zeitintervall, ms",
    timerSetupLabel_TT = "Wie oft der Charakterzustand auf Nahrungsbuffs gescannt wird" .. "Höherer Wert gibt eine" ..
            " weniger Belastung, aber eher eine" ..
            " Weile ohne Nahrung in einer kritischen Situation",

    youEat = "Sie haben <<1>> gegessen",
    youCharge = "Eingeladen <<1>> mit <<2>>",
    youChargeScreen = "Eingeladen <<1>>",
    youRepair = "Reparieren <<1>> mit <<2>>",
    youRepairScreen = "Reparieren <<1>>",
    allRepair= "Alles wird repariert mit <<1>>",
    allRepairScreen  = "Alles wird repariert",
    outputSetupHeader = "Anzeigen die Nachricht",
    outputOnScreen = "Auf den Bildschirm",
    outputSetupHeader_TT = "Wenn die Einstellung aktiviert ist, wird eine Nachricht über das gegessene Gericht" ..
            " oder die verzauberte Waffe auf dem Bildschirm angezeigt, und nicht nur zum Debug-Log",

    mealSetupHeader = "Gerichtart",
    mealSetupDescription = "Was zu verwenden: Essen oder Trinken. ACHTUNG Wenn die Beide ausgeschaltet sind," ..
            " dann wird kein Essen verwendet, denn ist es egal, der Addon ausgeschaltet wird. Schalten Sie mindestens" ..
            " einen ein",

    mealSetupFood = "Essen",
    mealSetupDrink = "Trinken",

    weaponSetupHeader = "Waffen",
    weaponSetupDescription = "Es kommt Autoeinladung der verzauberte Waffe vor, wenn die Gebühranzahl Minimal oder kleiner ist und" ..
            " ein Seelenstein im Inventar vorliegt",
    weaponSetupEnchantMainHand = "Haupthande Waffe",
    weaponSetupEnchantOffHand = "Ergänzendhande Waffe",
    weaponSetupEnchantMainHandBack = "Haupthande Waffe zweitrangig",
    weaponSetupEnchantOffHandBack = "Ergänzendhande Waffe zweitrangig",
    minCharges = "Minimalgebühranzahl",
    useCrownGemsTitle = "Kroneseelensteine benutzen",
    useCrownGemsTitle_TT = "Gefundene Kroneseelensteine benutzt werden",

    useCrownFoodTitle = "Kronessen benutzen",
    useCrownFoodTitle_TT = "Das gefundene Kronessen benutzt wird",

    repairSetupHeader = "Automatische Reparatur",
    repairSetupDescription = "Automatischereparaturbesetzung",

    repairSetupCheck = "Automatische Reparatur",
    repairSetupCheck_TT = "Sollen Sie einen Reparatursatz haben, um zu autoreparieren",
    repairPercent = "Minimum Verfall %",

    useCrownRepairTitle = "Kronreparatursatz benutzen",
    useCrownRepairTitle_TT = "Kronreparatursatz benutzen",
}

for k, v in pairs(L) do
    if type(v) ~= "table" then
        local string = "WELLEATER_" .. string.upper(k)
        ZO_CreateStringId(string, v)
    elseif k == "foods" then
        for ik, iv in pairs(v) do
            local string = "WELLEATER_FOODS_" .. ik
            ZO_CreateStringId(string, iv)
        end
    end
end

if (GetCVar('language.2') == 'de') then
    local MissingL = {}
    for k, v in pairs(WellEater:getLocale()) do
        if (not L[k]) then
            table.insert(MissingL, k)
            L[k] = v
        end
    end
    function WellEater:getLocale()
        return L
    end
    -- for debugging
    function WellEater:MissingLocale()
        df("[WellEater] Missing strings for '%s'", GetCVar('language.2'))
        d(MissingL)
    end
end
