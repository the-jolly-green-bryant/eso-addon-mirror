-- ============================================================================
-- ResourceRadar - Localizzazione Italiana
-- Parte di TraduzioneItalianaESO
-- ============================================================================

local Localization = {
    description = "L'addon ResourceRadar mostra i nodi di raccolta vicini sulla mappa, sulla bussola e li evidenzia nel mondo 3D.",

    map = "Segnaposti sulla mappa",
    displayNodesOnMap = "Mostra i nodi sulla mappa",
    mapPinSize = "Dimensione dei segnaposti sulla mappa",

    compass = "Segnaposti sulla bussola",
    displayNodesOnCompass = "Mostra i nodi sulla bussola",
    compassPinSize = "Dimensione dei segnaposti sulla bussola",

    worldPins = "Marcatori fluttuanti",
    displayNodesInWorld = "Mostra i marcatori fluttuanti nel mondo 3D",
    worldPinsDescription = "Le impostazioni scelte qui influenzeranno tutti i marcatori fluttuanti. Lo stile (colore/icona) non può essere impostato singolarmente per ogni tipo di risorsa.",
    worldPinSize = "Dimensione dei marcatori fluttuanti",
    worldPinPulse = "Animazione pulsante per i marcatori fluttuanti",
    worldPinTexture = "Icona del marcatore fluttuante",

    pinTexture = "Icona segnaposto bussola/mappa",
    pinColor = "Colore segnaposto bussola/mappa",
    pinTypeOptions = "Tipi di risorsa",
    removeOnDetection = "Rimuovi segnaposto bussola/mappa quando rilevato",
    removeOnDetectionTooltip = "Il segnaposto su bussola/mappa verrà rimosso quando viene rilevato come questo tipo di risorsa.",

    pinType1 = "Fabbro e Gioielleria",
    pinType2 = "Sartoria",
    pinType3 = "Falegnameria",
    pinType4 = "Rune",
    pinType5 = "Funghi",
    pinType6 = "Erbe e Fiori",
    pinType7 = "Erbe acquatiche",
    pinType8 = "Solventi",
    pinType100 = "Sconosciuto",
}

-- Se ResourceRadar non è installato/attivo, non fare nulla
if not ResourceRadar then return end

-- Se una stringa non è disponibile, usa il valore inglese predefinito
local metaTable = {
    __index = function(tbl, key)
        return ResourceRadar.localizationDefault[key]
    end
}
setmetatable(Localization, metaTable)

ResourceRadar:RegisterModule("localization", Localization)
