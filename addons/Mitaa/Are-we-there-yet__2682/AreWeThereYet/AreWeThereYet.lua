-- Title: Are we there yet?
-- Version: 0.6.4
-- Description: Calculates the date on which you will reach CP3600
-- APIVersion: 100034 100035
-- Author: René
-- SavedVariables: AreWeThereYetSavedVariables
-- Date: April 29, 2021

AreWeThereYet = {}
local addon = AreWeThereYet

addon.name = "AreWeThereYet"
addon.version = "0.6.4"
addon.varVersion = 2

-- constants
addon.cpMin = 10                                              -- min number of champion points
addon.cpMax = GetMaxSpendableChampionPointsInAttribute() * 3  -- max number of champion points, currently 3600 (3 x 1200)
addon.epMax = 4800000                                         -- max enlightened pool (4.8M)
addon.maxTsize = 31                                           -- max size for cpTable
addon.secDay = 86400                                          -- number of seconds in a day
addon.red = "|cFF0000"                                        -- color code for red text
addon.green = "|c00FF00"                                      -- color code for green text
addon.blue = "|c00BFFF"                                       -- color code for blue text
addon.orange = "|cFFA500"                                     -- color code for orange text
addon.orangered = "|cFF4500"                                  -- color code for orangered text
addon.noColor = "|r"                                          -- end colored text

-- variables
addon.cpEarned = GetPlayerChampionPointsEarned()              -- CP earned so far

-- tables
local tLabelsTop = {}                                         -- table for main window top (labels)
local tLabelsBottom = {}                                      -- table for main window bottom (labels)
local tValuesTop = {}                                         -- table for main window top (values)
local tValuesBottom = {}                                      -- table for main window bottom (values)
local tWeekday = {}                                           -- table for history window (weekdays)
local tMonth = {}                                             -- table for history window (months)
local tDay = {}                                               -- table for history window (days)
local tCP = {}                                                -- table for history window (champion points)
local tCalcResult = {}                                        -- table for calculator window (result)
local tLabelsCalc = {}                                        -- table for calculator window (labels)
local tValuesCalc = {}                                        -- table for calculator window (values)

-- local shortcuts
local concat = table.concat
local floor = math.floor
local format = string.format
local gsub = string.gsub
local insert = table.insert
local len = string.len

-- misc
local WindowScene = ZO_Scene:New("WindowScene", SCENE_MANAGER)
local HistoryScene = ZO_Scene:New("HistoryScene", SCENE_MANAGER)
local CalculatorScene = ZO_Scene:New("CalculatorScene", SCENE_MANAGER)

-- XP needed for next CP
function addon.xpNeeded(cp)
   local xp = GetNumChampionXPInChampionPoint(cp)  -- returns nil if CP < 0 or CP >= 3600
   return xp ~= nil and xp or 0
end

-- enlightened pool percentage
function addon.GetEnlightPool()
   local accl = GetEnlightenedPool() * (GetEnlightenedMultiplier() + 1)
   local pct = (accl * 100) / addon.epMax
   return tonumber(format("%.0f", pct))
end

-- enlightened color
function addon.SetEnlightColor()
   local pct = addon.GetEnlightPool()
   if pct == 0 then
	  AreWeThereYetWindowEnlightPoolTexture:SetColor(1, 1, 1, 1)     -- white
   elseif pct < 50 then
	  AreWeThereYetWindowEnlightPoolTexture:SetColor(0, 1, 0, 1)     -- green
   elseif pct < 75 then
	  AreWeThereYetWindowEnlightPoolTexture:SetColor(1, 0.65, 0, 1)  -- orange
   elseif pct < 100 then
	  AreWeThereYetWindowEnlightPoolTexture:SetColor(1, 0.27, 0, 1)  -- orangered
   else
	  AreWeThereYetWindowEnlightPoolTexture:SetColor(1, 0, 0, 1)     -- red
   end
end

-- text for enlightened tooltip
function addon.ShowEnlightText()
   return format("Enlightened Pool:  %d%%", addon.GetEnlightPool())
end

-- set constellation button alpha
function addon.SetConstellationAlpha(attribute, control)
   local cp = GetNumUnspentChampionPoints(attribute)
   control:SetAlpha(cp == 0 and 0.25 or 1)
end

-- text for unspent tooltip
function addon.ShowUnspentText(attribute, constellation)
   local cp = GetNumUnspentChampionPoints(attribute)
   return format("%s:  %d unspent Champion %s", constellation, cp, cp == 1 and "Point" or "Points")
end

-- keypad button clicked (champion points)
function addon.OnClickedButtonCP(text)
   local cp = AreWeThereYetCalculatorKeypadCPResult:GetText()
   local avg = AreWeThereYetCalculatorKeypadAvgResult:GetText()
   if text == "C" then
      AreWeThereYetCalculatorKeypadCPResult:SetText(nil)
   elseif text == "=" then
      if cp ~= "" and avg ~= "" then  -- apparently, GetText() returns an empty string instead of nil
         addon.UpdateCalculator(addon.cpGoal(cp), tonumber(avg) > addon.cpMax and addon.cpMax or avg)
      end
   else
	  cp = len(cp) < 4 and cp .. text or text
      AreWeThereYetCalculatorKeypadCPResult:SetText(cp)
   end
end

-- keypad button clicked (average CP/day)
function addon.OnClickedButtonAvg(text)
   local cp = AreWeThereYetCalculatorKeypadCPResult:GetText()
   local avg = AreWeThereYetCalculatorKeypadAvgResult:GetText()
   if text == "C" then
      AreWeThereYetCalculatorKeypadAvgResult:SetText(nil)
   elseif text == "=" then
      if cp ~= "" and avg ~= "" then  -- apparently, GetText() returns an empty string instead of nil
         addon.UpdateCalculator(addon.cpGoal(cp), tonumber(avg) > addon.cpMax and addon.cpMax or avg)
      end
   else
	  avg = len(avg) < 4 and avg .. text or text
      AreWeThereYetCalculatorKeypadAvgResult:SetText(avg)
   end
end

-- thousands separator
function addon.thousands(n)
  local strNumber = format("%.0f", n)
  local subs = 1
  while subs > 0 do
    strNumber, subs = gsub(strNumber, "^(-?%d+)(%d%d%d)", '%1,%2')
  end
  return strNumber
end

-- CP goal
function addon.cpGoal(cp)
   local numCP = tonumber(cp)
   if numCP < addon.cpEarned then
      return addon.cpEarned
   elseif numCP > addon.cpMax then
      return addon.cpMax
   else
      return numCP
   end
end

-- format number with two decimals and strip trailing zeroes
function addon.format(n)
   local number = tonumber(format("%.2f", n))
   return tostring(number)
end

-- date at 12:00
function addon.date(t)
   return os.time{year=t.year, month=t.month, day=t.day, hour=12, min=0, isdst=false}   -- adding secDay will not yield the expected result: the time will always be set to 12:00
end

-- average of all number values in a table
function addon.avg(t)
   local sum = 0
   local count = 0
   for key, value in pairs(t) do
      if type(value) == 'number' then
         sum = sum + value
         count = count + 1
      end
   end
   return count == 0 and 0 or sum / count   -- empty table = 0/0 = division by zero = NaN = possible client crash
end

-- count number of key/value pairs in a table
function addon.getTableSize(t)
   local count = 0
   for key, value in pairs(t) do
      count = count + 1
   end
   return count
end

-- difference between two dates in years, months, weeks and days
-- this function will work for abouit 80 years, and will fail on March 1st, 2100
function addon.timeDiff(oldTime, newTime)
   local old = os.date("*t", oldTime)
   local new = os.date("*t", newTime)
   local days = {31, new.year % 4 > 0 and 28 or 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
   local yearDiff = new.year - old.year
   local monthDiff = new.month - old.month
   local dayDiff = new.day - old.day
   local result = ""
   if dayDiff < 0 then
      local month = new.month == 1 and 12 or new.month - 1
      monthDiff = monthDiff - 1
	  dayDiff = old.day >= days[month] and new.day or dayDiff + days[month]
   end
   if monthDiff < 0 then
      yearDiff = yearDiff - 1
      monthDiff = monthDiff + 12
   end
   local weeks = floor(dayDiff / 7)
   local days = dayDiff % 7
   if yearDiff > 0 then
      result = result .. yearDiff .. (yearDiff == 1 and " year" or " years")
   end
   if monthDiff > 0 then
      if result ~= "" then result = result .. (weeks + days > 0 and ", " or " and ") end
      result = result .. monthDiff .. (monthDiff == 1 and " month" or " months")
   end
   if weeks > 0 then
      if result ~= "" then result = result .. (days > 0 and ", " or " and ") end
      result = result .. weeks .. (weeks == 1 and " week" or " weeks")
   end
   if days > 0 then
      if result ~= "" then result = result .. " and " end
      result = result .. days .. (days == 1 and " day" or " days")
   end
   return result ~= "" and result or "0 days"
end

-- fill missing days with zero (not played or no CP earned)
-- including today
function addon.FillDays(d)
   if addon.savedVars.lastCPdate < d then
	  for i = addon.savedVars.lastCPdate + addon.secDay, d, addon.secDay do
	     addon.savedVars.cpTable[i] = 0
	  end
	  addon.savedVars.lastCPdate = d
      for key, value in pairs(addon.savedVars.cpTable) do
         if key < d - addon.secDay * (addon.maxTsize - 1) then   -- remove anything over a month old
		    addon.savedVars.cpTable[key] = nil
		 end
      end
   end
end

-- triggered whenever a champion point is earned
function addon.OnGainCP()
   local cpNew = GetPlayerChampionPointsEarned()                              -- total CP earned
   local cpEarned = cpNew - addon.cpEarned                                    -- CP earned in this event
   local date = addon.date(os.date("*t"))                                     -- date at 12:00
   addon.FillDays(date)                                                       -- fill missing days with zero
   addon.savedVars.cpTable[date] = addon.savedVars.cpTable[date] + cpEarned   -- add to existing table entry
   addon.cpEarned = cpNew                                                     -- update CP earned with new value
end

-- update main window
function addon.PrepareWindow(cp,avg)
   local cpMax = cp == 0 and addon.cpMax or cp                                                              -- max CP, or user-entered (calculator)
   local cpAvg = avg == 0 and addon.avg(addon.savedVars.cpTable) or avg                                     -- average CP/day, or user-entered (calculator)
   local dateTable = os.date("*t")                                                                          -- get date/time in table
   local date = addon.date(dateTable)                                                                       -- date at 12:00
   addon.FillDays(date)                                                                                     -- fill missing days with zero
   local tableSize = addon.getTableSize(addon.savedVars.cpTable)                                            -- size of cpTable
   local cpTodo = cpMax - addon.cpEarned                                                                    -- how many CP left
   local cpToday = addon.savedVars.cpTable[date]                                                            -- CP earned today
   local labelAvg = format("Average CP in the last %s", tableSize == 1 and "day" or tableSize .. " days")   -- average CP window label
   local valueAvg = addon.format(cpAvg)                                                                     -- average CP window value
   local xpMin = addon.xpNeeded(addon.cpMin - 1)                                                            -- XP needed for the very first CP
   local xpMax = addon.xpNeeded(cpMax - 1)                                                                  -- XP needed for the very last CP
   local xp = addon.xpNeeded(addon.cpEarned - 1)                                                            -- XP needed for current CP
   local xpNext = addon.xpNeeded(addon.cpEarned)                                                            -- XP needed for next CP
   local maxPctIncr = (xpMax - xpMin) / xpMin * 100                                                         -- maximum increase percentage
   local curPctIncr = (xp - xpMin) / xpMin * 100                                                            -- cumulative increase percentage
   local futPctIncr = ((xpMax - xp) / xp * 100) / 2                                                         -- average future increase percentage
   local cpDays = cpAvg == 0 and 0 or cpTodo / cpAvg                                                        -- how many days left
   local endDate = date + cpDays * addon.secDay                                                             -- end date
   local endTable = os.date("*t", endDate)                                                                  -- end date in table
   local strDate = ""                                                                                       -- formatted end date
   local timeLeft = ""                                                                                      -- time left
   if cpTodo == 0 then
      strDate = "none"
	  timeLeft = "none"
   elseif cpAvg == 0 or endTable.day == -1 then                                                             -- year 2038 problem (32-bit client), see https://en.wikipedia.org/wiki/Year_2038_problem
      strDate = "unknown"
	  timeLeft = "unknown"
   else
      strDate = os.date("%A, %B %d, %Y", endDate)
      timeLeft = addon.timeDiff(date, endDate)
   end
   -- fill tables for main window
   tLabelsTop = {
      "Champion Points earned",
      "Champion Points left",
      "Champion Points earned today",
      labelAvg,
      "",
      "Minimum Champion Points",
      "Maximum Champion Points",
      "Minimum XP needed",
      "Maximum XP needed",
      "XP needed for next Champion Point",
      "",
      "Cumulative decrease in CP gain",
      "Maximum decrease in CP gain",
      "Average future decrease in CP gain"
   }
   tLabelsBottom = {
      "Estimated end date",   -- shared with calculator window
      "Time left"             -- shared with calculator window
   }
   tValuesTop = {
      addon.cpEarned,
      cpTodo,
      cpToday,
      valueAvg,
      "",
      addon.cpMin,
      cpMax,
	  addon.thousands(xpMin),
	  addon.thousands(xpMax),
	  addon.thousands(xpNext),
      "",
      format("%s%%", addon.thousands(curPctIncr)),
	  format("%s%%", addon.thousands(maxPctIncr)),
	  format("%s%%", addon.thousands(futPctIncr))
   }
   tValuesBottom = {
      strDate,                -- shared with calculator window
      timeLeft                -- shared with calculator window
   }
   -- fill tables for calculator window
   tCalcResult = {
      ["cp"] = cpMax,
	  ["avg"] = valueAvg
   }
   tLabelsCalc = {
      "Maximum XP needed",
      "Maximum decrease in CP gain",
      "Average future decrease in CP gain"
   }
   tValuesCalc = {
	  addon.thousands(xpMax),
      format("%s%%", addon.thousands(maxPctIncr)),
	  format("%s%%", addon.thousands(futPctIncr))
   }
end

-- update history window
function addon.PrepareHistory()
   local date
   local tableSize = addon.getTableSize(addon.savedVars.cpTable)
   tWeekday = {}
   tMonth = {}
   tDay = {}
   tCP = {}
   for i = tableSize - 1, 0, -1 do
      date = addon.savedVars.lastCPdate - addon.secDay * i
      if addon.savedVars.cpTable[date] ~= nil then
	     insert(tWeekday, os.date("%A", date))
		 insert(tMonth, os.date("%B", date))
		 insert(tDay, tonumber(os.date("%d", date)))
		 insert(tCP, addon.savedVars.cpTable[date])
      else
	     d(format("%s: Unable to find key for %s", addon.name, os.date("%c", date)))
	  end
   end
   if tableSize > addon.maxTsize then
      d(format("%s%s: History table has %d entries%s", addon.red, addon.name, tableSize, addon.noColor))
   end
end

function addon.UpdateWindow()
   addon.PrepareWindow(0,0)
   addon.SetEnlightColor()
   addon.SetConstellationAlpha(ATTRIBUTE_HEALTH, AreWeThereYetWindowWarfareButton)
   addon.SetConstellationAlpha(ATTRIBUTE_MAGICKA, AreWeThereYetWindowFitnessButton)
   addon.SetConstellationAlpha(ATTRIBUTE_STAMINA, AreWeThereYetWindowCraftButton)
   AreWeThereYetWindowTitle:SetText(format("%sAre%sWe%sThere%sYet", addon.green, addon.blue, addon.orangered, addon.noColor))
   AreWeThereYetWindowLabels1:SetText(concat(tLabelsTop, "\n"))
   AreWeThereYetWindowValues1:SetText(concat(tValuesTop, "\n"))
   AreWeThereYetWindowLabels2:SetText(concat(tLabelsBottom, "\n"))
   AreWeThereYetWindowValues2:SetText(concat(tValuesBottom, "\n"))
end

function addon.UpdateHistory()
   addon.PrepareHistory()
   AreWeThereYetHistoryTitle:SetText(format("%sAre%sWe%sThere%sYet  History", addon.green, addon.blue, addon.orangered, addon.noColor))
   AreWeThereYetHistoryWeekday:SetText(concat(tWeekday, "\n"))
   AreWeThereYetHistoryMonth:SetText(concat(tMonth, "\n"))
   AreWeThereYetHistoryDay:SetText(concat(tDay, "\n"))
   AreWeThereYetHistoryCP:SetText(concat(tCP, "\n"))
end

function addon.UpdateCalculator(cp,avg)
   addon.PrepareWindow(cp,avg)
   AreWeThereYetCalculatorTitle:SetText(format("%sAre%sWe%sThere%sYet  Calculator", addon.green, addon.blue, addon.orangered, addon.noColor))
   AreWeThereYetCalculatorKeypadCPResult:SetText(tCalcResult.cp)
   AreWeThereYetCalculatorKeypadAvgResult:SetText(tCalcResult.avg)
   AreWeThereYetCalculatorLabels1:SetText(concat(tLabelsCalc, "\n"))
   AreWeThereYetCalculatorValues1:SetText(concat(tValuesCalc, "\n"))
   AreWeThereYetCalculatorLabels2:SetText(concat(tLabelsBottom, "\n"))
   AreWeThereYetCalculatorValues2:SetText(concat(tValuesBottom, "\n"))
end

function addon.ToggleWindow()
   local fragment = ZO_SimpleSceneFragment:New(AreWeThereYetWindow)
   WindowScene:AddFragment(fragment)
   if not SCENE_MANAGER:IsShowing("WindowScene") then
      addon.UpdateWindow()
   end
   SCENE_MANAGER:Toggle("WindowScene")
end

function addon.ToggleHistory()
   local fragment = ZO_SimpleSceneFragment:New(AreWeThereYetHistory)
   HistoryScene:AddFragment(fragment)
   if not SCENE_MANAGER:IsShowing("HistoryScene") then
      addon.UpdateHistory()
   end
   SCENE_MANAGER:Toggle("HistoryScene")
end

function addon.ToggleCalculator()
   local fragment = ZO_SimpleSceneFragment:New(AreWeThereYetCalculator)
   CalculatorScene:AddFragment(fragment)
   if not SCENE_MANAGER:IsShowing("CalculatorScene") then
      addon.UpdateCalculator(0,0)
   end
   SCENE_MANAGER:Toggle("CalculatorScene")
end

function addon:Initialize()
   local date = self.date(os.date("*t"))
   self.defaults = {
      lastCPdate = date,
	  cpTable = { [date] = 0 }
   }
   self.savedVars = ZO_SavedVars:NewAccountWide("AreWeThereYetSavedVariables", self.varVersion, nil, self.defaults)
   EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CHAMPION_POINT_GAINED, self.OnGainCP)
   ZO_CreateStringId("SI_BINDING_NAME_ARE_WE_THERE_YET_TOGGLE", "Show/Hide Window")
   SLASH_COMMANDS["/arewethereyet"] = self.ToggleWindow
   EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
end

function addon.OnAddOnLoaded(event, addonName)
   if addonName == addon.name then
      addon:Initialize()
   end
end

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, addon.OnAddOnLoaded)
