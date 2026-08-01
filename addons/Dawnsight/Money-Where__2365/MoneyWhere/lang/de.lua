--[[
	Addon: MoneyWhere
	Author: Dawnsight
	Created by dawnsight@yahoo.com
  
  This is the language file fore German
]]

local stringsDE = {
    SI_MONEYWHERE_COSTS = "Kosten/Gebühren", -- Fees for repairs and teleporting
 
    SI_MONEYWHERE_TRANSACTION_INCOME = "Einkommen", --
    SI_MONEYWHERE_TRANSACTION_EXPENSE = "Ausgaben", --
    SI_MONEYWHERE_TRANSACTION_NET = "Netto", -- The difference between Income and Expense
 
    SI_MONEYWHERE_EXDISCOVERY = "Entdeckung", -- finding a new point of interest
    SI_MONEYWHERE_EXKILL = "Tötungen", --
    SI_MONEYWHERE_EXSKILLBOOK = "Fertigkeiten Buch", --
    SI_MONEYWHERE_EXTRADESKILL = "Handwerk", --
    SI_MONEYWHERE_EXACHIEVEMENT = "Errungenschaft", -- earning an achievement like Dungeon Vanquisher
 
    SI_MONEYWHERE_LOAD_LEDGER_ON_INIT = "Lade Hauptbuch beim Starten",
    SI_MONEYWHERE_LOAD_LEDGER_DESCRIP = "Aktivieren, um die gesicherten Transaktionen beim Laden des Charakter zu sammeln",
    SI_MONEYWHERE_TRACK_GOLD = "Verfolge Gold", -- record gold income and spending
    SI_MONEYWHERE_TRACK_GOLD_DESCRIP = "Aktivieren, um die Gold Transaktionen zu sammeln.",
    SI_MONEYWHERE_TRACK_APOINTS = "Verfolge " .. GetString(SI_CHATCHANNELCATEGORIES48),
    SI_MONEYWHERE_TRACK_APOINTS_DESCRIP = "Aktivieren, um Transaktionen mit "  .. GetString(SI_CHATCHANNELCATEGORIES48) .. " zu sammeln.",
    SI_MONEYWHERE_TRACK_TELVAR = "Verfolge " .. GetString(SI_CHATCHANNELCATEGORIES46),
    SI_MONEYWHERE_TRACK_TELVAR_DESCRIP = "Aktivieren, um Transaktionen mit ".. GetString(SI_CHATCHANNELCATEGORIES46).." zu sammeln.",
    SI_MONEYWHERE_TRACK_EXP = "Verfolge ".. GetString(SI_CHATCHANNELCATEGORIES45), -- record Experience earned
    SI_MONEYWHERE_TRACK_EXP_DESCRIP = "Aktivieren, um Transaktionen aus " .. GetString(SI_CHATCHANNELCATEGORIES45) .. " Quellen zu sammeln.",
    SI_MONEYWHERE_TRACK_RATE = "Verfolge Rate", -- record how fast currencies change
    SI_MONEYWHERE_TRACK_RATE_DESCRIP = "Aktivieren, um die Rate (wie schnell verändert sich das Einkommen) des Einkommens zu verfolgen.",
    SI_MONEYWHERE_MINUTES_TRACKED = "Minuten für Rate",
    SI_MONEYWHERE_MINUTES_TRACKED_DESCRIP = "Anzahl der Minuten welche für die Berechnung der Rate verwendet werden.",
 
    SI_MONEYWHERE_XP_NEED = "Benötigt",
    SI_MONEYWHERE_RATE_FOR_X_MIN = "Rate für %d Minuten", -- Rate = How fast, the %d is where the number of minutes will go
}

for stringId, stringContent in pairs(stringsDE) do
    SafeAddVersion(stringId, 1)
end
