--[[
	Addon: MoneyWhere
	Author: Dawnsight
	Created by dawnsight@yahoo.com
  
  This is the language file fore English and also default
]]

local stringsEN = {
  SI_MONEYWHERE_COSTS = "Costs/Fees", -- Fees for repairs and teleporting

  SI_MONEYWHERE_TRANSACTION_INCOME = "Income", --
  SI_MONEYWHERE_TRANSACTION_EXPENSE = "Expenses", --
  SI_MONEYWHERE_TRANSACTION_NET = "Net", -- The difference between Income and Expense

  SI_MONEYWHERE_EXDISCOVERY = "Discovery", -- finding a new point of interest
  SI_MONEYWHERE_EXKILL = "Kills", --
  SI_MONEYWHERE_EXSKILLBOOK = "Skill Book", --
  SI_MONEYWHERE_EXTRADESKILL = "Trade Skill", --
  SI_MONEYWHERE_EXACHIEVEMENT = "Achieve", -- earning an achievement like Dungeon Vanquisher

  SI_MONEYWHERE_LOAD_LEDGER_ON_INIT = "Load Ledger on Initialization",
  SI_MONEYWHERE_LOAD_LEDGER_DESCRIP = "Check to load saved transaction values when character loads",
  SI_MONEYWHERE_TRACK_GOLD = "Track Gold", -- record gold income and spending
  SI_MONEYWHERE_TRACK_GOLD_DESCRIP = "Check to track gold transactions.",
  SI_MONEYWHERE_TRACK_APOINTS = "Track " .. GetString(SI_CHATCHANNELCATEGORIES48), -- record Alliance Points income and spending
  SI_MONEYWHERE_TRACK_APOINTS_DESCRIP = "Check to track " ..  GetString(SI_CHATCHANNELCATEGORIES48) .." transactions.",
  SI_MONEYWHERE_TRACK_TELVAR = "Track " .. GetString(SI_CHATCHANNELCATEGORIES46), -- record Tel Var income and spending
  SI_MONEYWHERE_TRACK_TELVAR_DESCRIP = "Check to track " .. GetString(SI_CHATCHANNELCATEGORIES46).. " transactions.",
  SI_MONEYWHERE_TRACK_EXP = "Track " .. GetString(SI_CHATCHANNELCATEGORIES45), -- record Experience earned
  SI_MONEYWHERE_TRACK_EXP_DESCRIP = "Check to track " .. GetString(SI_CHATCHANNELCATEGORIES45) .. " Sources.",
  SI_MONEYWHERE_TRACK_RATE = "Track Rate", -- record how fast currencies change
  SI_MONEYWHERE_TRACK_RATE_DESCRIP = "Check to track rates of income.",
  SI_MONEYWHERE_MINUTES_TRACKED = "Minutes Tracked", -- The number of minutes used to track rate
  SI_MONEYWHERE_MINUTES_TRACKED_DESCRIP = "Number of minutes used to calculate rate.",

  SI_MONEYWHERE_XP_NEED = "Need",
  SI_MONEYWHERE_RATE_FOR_X_MIN = "Rate for %d Minutes", -- Rate = How fast, the %d is where the number of minutes will go
}

for stringId, stringContent in pairs(stringsEN) do
    ZO_CreateStringId(stringId, stringContent)
    --SafeAddVersion(stringId, 1)
end
