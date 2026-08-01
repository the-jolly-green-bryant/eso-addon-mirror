------------------------------------------------------------------------------
-- 					      									                --
-- 	Title:		 Tamriel Chronos                    					    --
--	Description: Tamriel Time and astronomical data                         --
--	Author: 	 Gandalf (@Gandalf2675)									    --
--               Based on https:                                            --
--               https://www.imperial-library.info/content/calendar-tamriel --
-- 					      									                --
------------------------------------------------------------------------------
 
TaChronos.hol = TaChronos.hol or {}
local hol     = TaChronos.hol  	

hol.events = { 
	{	["startDay"]    = 1, 
		["startMonth"]  = 1, 
		["endDay"]      = 1,
		["endMonth"]    = 1,
		["name"]	    = SI_TACHRONOS_New_Life,
		["date"]        = SI_TACHRONOS_New_Life_date,
		["text"]        = SI_TACHRONOS_New_Life_text,
	},
	{	["startDay"]    = 2, 
		["startMonth"]  = 1, 
		["endDay"]      = 2,
		["endMonth"]    = 1,
		["name"]	    = SI_TACHRONOS_Scour_Day,
		["date"]        = SI_TACHRONOS_Scour_Day_date,
		["text"]        = SI_TACHRONOS_Scour_Day_text,
    },
	{	["startDay"]    = 12, 
		["startMonth"]  = 1, 
		["endDay"]      = 12,
		["endMonth"]    = 1,
		["name"]	    = SI_TACHRONOS_Ovanka,
		["date"]        = SI_TACHRONOS_Ovanka_date,
		["text"]        = SI_TACHRONOS_Ovanka_text,
	},
	{	["startDay"]    = 13, 
		["startMonth"]  = 1, 
		["endDay"]      = 13,
		["endMonth"]    = 1,
		["name"]	    = SI_TACHRONOS_Meridias_Summoning,
		["date"]        = SI_TACHRONOS_Meridias_Summoning_date,
		["text"]        = SI_TACHRONOS_Meridias_Summoning_text,
	},
	{	["startDay"]    = 15, 
		["startMonth"]  = 1, 
		["endDay"]      = 15,
		["endMonth"]    = 1,
		["name"]	    = SI_TACHRONOS_South_Winds_Prayer,
		["date"]        = SI_TACHRONOS_South_Winds_Prayer_date,
		["text"]        = SI_TACHRONOS_South_Winds_Prayer_text,
	},
	{	["startDay"]    = 16, 
		["startMonth"]  = 1, 
		["endDay"]      = 16,
		["endMonth"]    = 1,
		["name"]	    = SI_TACHRONOS_The_Day_of_Lights,
		["date"]        = SI_TACHRONOS_The_Day_of_Lights_date,
		["text"]        = SI_TACHRONOS_The_Day_of_Lights_text,
	},
	{	["startDay"]    = 18, 
		["startMonth"]  = 1, 
		["endDay"]      = 18,
		["endMonth"]    = 1,
		["name"]	    = SI_TACHRONOS_Waking_Day,
		["date"]        = SI_TACHRONOS_Waking_Day_date,
		["text"]        = SI_TACHRONOS_Waking_Day_text,
	},
	{	["startDay"]    = 2, 
		["startMonth"]  = 2, 
		["endDay"]      = 2,
		["endMonth"]    = 2,
		["name"]	    = SI_TACHRONOS_Mad_Pelagius,
		["date"]        = SI_TACHRONOS_Mad_Pelagius_date,
		["text"]        = SI_TACHRONOS_Mad_Pelagius_text,
	},
	{	["startDay"]    = 5, 
		["startMonth"]  = 2, 
		["endDay"]      = 5,
		["endMonth"]    = 2,
		["name"]	    = SI_TACHRONOS_Othroktide,
		["date"]        = SI_TACHRONOS_Othroktide_date,
		["text"]        = SI_TACHRONOS_Othroktide_text,
	},
	{	["startDay"]    = 8, 
		["startMonth"]  = 2, 
		["endDay"]      = 8,
		["endMonth"]    = 2,
		["name"]	    = SI_TACHRONOS_Day_of_Release,
		["date"]        = SI_TACHRONOS_Day_of_Release_date,
		["text"]        = SI_TACHRONOS_Day_of_Release_text,
	},
	{	["startDay"]    = 16, 
		["startMonth"]  = 2, 
		["endDay"]      = 16,
		["endMonth"]    = 2,
		["name"]	    = SI_TACHRONOS_Hearts_Day,
		["date"]        = SI_TACHRONOS_Hearts_Day_date,
		["text"]        = SI_TACHRONOS_Hearts_Day_text,
	},
	{	["startDay"]    = 27, 
		["startMonth"]  = 2, 
		["endDay"]      = 27,
		["endMonth"]    = 2,
		["name"]	    = SI_TACHRONOS_Perseverance_Day,
		["date"]        = SI_TACHRONOS_Perseverance_Day_date,
		["text"]        = SI_TACHRONOS_Perseverance_Day_text,
	},
	{	["startDay"]    = 28, 
		["startMonth"]  = 2, 
		["endDay"]      = 28,
		["endMonth"]    = 2,
		["name"]	    = SI_TACHRONOS_Aduros_Nau,
		["date"]        = SI_TACHRONOS_Aduros_Nau_date,
		["text"]        = SI_TACHRONOS_Aduros_Nau_text,
	},
	{	["startDay"]    = 5, 
		["startMonth"]  = 3, 
		["endDay"]      = 5,
		["endMonth"]    = 3,
		["name"]	    = SI_TACHRONOS_Hermaeus_Moras,
		["date"]        = SI_TACHRONOS_Hermaeus_Moras_date,
		["text"]        = SI_TACHRONOS_Hermaeus_Moras_text,
	},
	{	["startDay"]    = 7, 
		["startMonth"]  = 3, 
		["endDay"]      = 7,
		["endMonth"]    = 3,
		["name"]	    = SI_TACHRONOS_First_Planting,
		["date"]        = SI_TACHRONOS_First_Planting_date,
		["text"]        = SI_TACHRONOS_First_Planting_text,
	},
	{	["startDay"]    = 9, 
		["startMonth"]  = 3, 
		["endDay"]      = 9,
		["endMonth"]    = 3,
		["name"]	    = SI_TACHRONOS_Day_of_Waiting,
		["date"]        = SI_TACHRONOS_Day_of_Waiting_date,
		["text"]        = SI_TACHRONOS_Day_of_Waiting_text,
	},
	{	["startDay"]    = 21, 
		["startMonth"]  = 3, 
		["endDay"]      = 21,
		["endMonth"]    = 3,
		["name"]	    = SI_TACHRONOS_Hogithum,
		["date"]        = SI_TACHRONOS_Hogithum_date,
		["text"]        = SI_TACHRONOS_Hogithum_text,
	},
	{	["startDay"]    = 25, 
		["startMonth"]  = 3, 
		["endDay"]      = 25,
		["endMonth"]    = 3,
		["name"]	    = SI_TACHRONOS_Flower_Day,
		["date"]	    = SI_TACHRONOS_Flower_Day_date,
		["text"]        = SI_TACHRONOS_Flower_Day_text,
	},
	{	["startDay"]    = 26, 
		["startMonth"]  = 3, 
		["endDay"]      = 26,
		["endMonth"]    = 3,
		["name"]	    = SI_TACHRONOS_Festival_of_Blades,
		["date"]	    = SI_TACHRONOS_Festival_of_Blades_date,
		["text"]        = SI_TACHRONOS_Festival_of_Blades_text,
	},
	{	["startDay"]    = 1, 
		["startMonth"]  = 4, 
		["endDay"]      = 1,
		["endMonth"]    = 4,
		["name"]	    = SI_TACHRONOS_Gardtide,
		["date"]	    = SI_TACHRONOS_Gardtide_date,
		["text"]        = SI_TACHRONOS_Gardtide_text,
	},
	{	["startDay"]    = 9, 
		["startMonth"]  = 4, 
		["endDay"]      = 9,
		["endMonth"]    = 4,
		["name"]	    = SI_TACHRONOS_Peryites_Summoning,
		["date"]	    = SI_TACHRONOS_Peryites_Summoning_date,
		["text"]        = SI_TACHRONOS_Peryites_Summoning_text,
	},
	{	["startDay"]    = 13, 
		["startMonth"]  = 4, 
		["endDay"]      = 13,
		["endMonth"]    = 4,
		["name"]	    = SI_TACHRONOS_Day_of_the_Dead,
		["date"]	    = SI_TACHRONOS_Day_of_the_Dead_date,
		["text"]        = SI_TACHRONOS_Day_of_the_Dead_text,
	},
	{	["startDay"]    = 20, 
		["startMonth"]  = 4, 
		["endDay"]      = 20,
		["endMonth"]    = 4,
		["name"]	    = SI_TACHRONOS_The_Day_of_Shame,
		["date"]	    = SI_TACHRONOS_The_Day_of_Shame_date,
		["text"]        = SI_TACHRONOS_The_Day_of_Shame_text,
	},
	{	["startDay"]    = 28, 
		["startMonth"]  = 4, 
		["endDay"]      = 28,
		["endMonth"]    = 4,
		["name"]	    = SI_TACHRONOS_Jesters_Day,
		["date"]	    = SI_TACHRONOS_Jesters_Day_date,
		["text"]        = SI_TACHRONOS_Jesters_Day_text,
	},
	{	["startDay"]    = 7, 
		["startMonth"]  = 5, 
		["endDay"]      = 7,
		["endMonth"]    = 5,
		["name"]	    = SI_TACHRONOS_Second_Planting,
		["date"]	    = SI_TACHRONOS_Second_Planting_date,
		["text"]        = SI_TACHRONOS_Second_Planting_text,
	},
	{	["startDay"]    = 9, 
		["startMonth"]  = 5, 
		["endDay"]      = 9,
		["endMonth"]    = 5,
		["name"]	    = SI_TACHRONOS_Marukhs_Day,
		["date"]	    = SI_TACHRONOS_Marukhs_Day_date,
		["text"]        = SI_TACHRONOS_Marukhs_Day_text,
	},
	{	["startDay"]    = 20, 
		["startMonth"]  = 5, 
		["endDay"]      = 20,
		["endMonth"]    = 5,
		["name"]	    = SI_TACHRONOS_The_Fire_Festival,
		["date"]	    = SI_TACHRONOS_The_Fire_Festival_date,
		["text"]        = SI_TACHRONOS_The_Fire_Festival_text,
	},
	{	["startDay"]    = 30, 
		["startMonth"]  = 5, 
		["endDay"]      = 30,
		["endMonth"]    = 5,
		["name"]	    = SI_TACHRONOS_Fishing_Day,
		["date"]	    = SI_TACHRONOS_Fishing_Day_date,
		["text"]        = SI_TACHRONOS_Fishing_Day_text,
	},
	{	["startDay"]    = 1, 
		["startMonth"]  = 6, 
		["endDay"]      = 1,
		["endMonth"]    = 6,
		["name"]	    = SI_TACHRONOS_Drigh_RZimb,
		["date"]	    = SI_TACHRONOS_Drigh_RZimb_date,
		["text"]        = SI_TACHRONOS_Drigh_RZimb_text,
	},
	{	["startDay"]    = 5, 
		["startMonth"]  = 6, 
		["endDay"]      = 5,
		["endMonth"]    = 6,
		["name"]	    = SI_TACHRONOS_Hircines_Summoning,
		["date"]	    = SI_TACHRONOS_Hircines_Summoning_date,
		["text"]        = SI_TACHRONOS_Hircines_Summoning_text,
	},
	{	["startDay"]    = 16, 
		["startMonth"]  = 6, 
		["endDay"]      = 16,
		["endMonth"]    = 6,
		["name"]	    = SI_TACHRONOS_Mid_Year_Celebration,
		["date"]	    = SI_TACHRONOS_Mid_Year_Celebration_date,
		["text"]        = SI_TACHRONOS_Mid_Year_Celebration_text,
	},
	{	["startDay"]    = 23, 
		["startMonth"]  = 6, 
		["endDay"]      = 23,
		["endMonth"]    = 6,
		["name"]	    = SI_TACHRONOS_Dancing_Day,
		["date"]	    = SI_TACHRONOS_Dancing_Day_date,
		["text"]        = SI_TACHRONOS_Dancing_Day_text,
	},
	{	["startDay"]    = 24, 
		["startMonth"]  = 6, 
		["endDay"]      = 24,
		["endMonth"]    = 6,
		["name"]	    = SI_TACHRONOS_Tibedetha,
		["date"]	    = SI_TACHRONOS_Tibedetha_date,
		["text"]        = SI_TACHRONOS_Tibedetha_text,
	},
	{	["startDay"]    = 10, 
		["startMonth"]  = 7, 
		["endDay"]      = 10,
		["endMonth"]    = 7,
		["name"]	    = SI_TACHRONOS_Merchants_Festival,
		["date"]	    = SI_TACHRONOS_Merchants_Festival_date,
		["text"]        = SI_TACHRONOS_Merchants_Festival_text,
	},
	{	["startDay"]    = 12, 
		["startMonth"]  = 7, 
		["endDay"]      = 12,
		["endMonth"]    = 7,
		["name"]	    = SI_TACHRONOS_Divad_Etept,
		["date"]	    = SI_TACHRONOS_Divad_Etept_date,
		["text"]        = SI_TACHRONOS_Divad_Etept_text,
	},
	{	["startDay"]    = 20, 
		["startMonth"]  = 7, 
		["endDay"]      = 20,
		["endMonth"]    = 7,
		["name"]	    = SI_TACHRONOS_Suns_Rest,
		["date"]	    = SI_TACHRONOS_Suns_Rest_date,
		["text"]        = SI_TACHRONOS_Suns_Rest_text,
	},
	{	["startDay"]    = 29, 
		["startMonth"]  = 7, 
		["endDay"]      = 29,
		["endMonth"]    = 7,
		["name"]	    = SI_TACHRONOS_Fiery_Night,
		["date"]	    = SI_TACHRONOS_Fiery_Night_date,
		["text"]        = SI_TACHRONOS_Fiery_Night_text,
	},
	{	["startDay"]    = 2, 
		["startMonth"]  = 8, 
		["endDay"]      = 2,
		["endMonth"]    = 8,
		["name"]	    = SI_TACHRONOS_Maiden_Katrica,
		["date"]	    = SI_TACHRONOS_Maiden_Katrica_date,
		["text"]        = SI_TACHRONOS_Maiden_Katrica_text,
	},
	{	["startDay"]    = 11, 
		["startMonth"]  = 8, 
		["endDay"]      = 11,
		["endMonth"]    = 8,
		["name"]	    = SI_TACHRONOS_Koomu_Alezeri,
		["date"]	    = SI_TACHRONOS_Koomu_Alezeri_date,
		["text"]        = SI_TACHRONOS_Koomu_Alezeri_text,
	},
	{	["startDay"]    = 14, 
		["startMonth"]  = 8, 
		["endDay"]      = 14,
		["endMonth"]    = 8,
		["name"]	    = SI_TACHRONOS_Feast_of_the_Tiger,
		["date"]	    = SI_TACHRONOS_Feast_of_the_Tiger_date,
		["text"]        = SI_TACHRONOS_Feast_of_the_Tiger_text,
	},
	{	["startDay"]    = 21, 
		["startMonth"]  = 8, 
		["endDay"]      = 12,
		["endMonth"]    = 8,
		["name"]	    = SI_TACHRONOS_Appreciation_Day,
		["date"]	    = SI_TACHRONOS_Appreciation_Day_date,
		["text"]        = SI_TACHRONOS_Appreciation_Day_text,
	},
	{	["startDay"]    = 27, 
		["startMonth"]  = 8, 
		["endDay"]      = 27,
		["endMonth"]    = 8,
		["name"]	    = SI_TACHRONOS_Harvests_End,
		["date"]	    = SI_TACHRONOS_Harvests_End_date,
		["text"]        = SI_TACHRONOS_Harvests_End_text,
	},
	{	["startDay"]    = 3, 
		["startMonth"]  = 9, 
		["endDay"]      = 3,
		["endMonth"]    = 9,
		["name"]	    = SI_TACHRONOS_Tales_and_Tallows,
		["date"]	    = SI_TACHRONOS_Tales_and_Tallows_date,
		["text"]        = SI_TACHRONOS_Tales_and_Tallows_text,
	},
	{	["startDay"]    = 6, 
		["startMonth"]  = 9, 
		["endDay"]      = 6,
		["endMonth"]    = 9,
		["name"]	    = SI_TACHRONOS_Khurat,
		["date"]	    = SI_TACHRONOS_Khurat_date,
		["text"]        = SI_TACHRONOS_Khurat_text,
	},
	{	["startDay"]    = 8, 
		["startMonth"]  = 9, 
		["endDay"]      = 8,
		["endMonth"]    = 9,
		["name"]	    = SI_TACHRONOS_Nocturnals_Summoning,
		["date"]	    = SI_TACHRONOS_Nocturnals_Summoning_date,
		["text"]        = SI_TACHRONOS_Nocturnals_Summoning_text,
	},
	{	["startDay"]    = 12, 
		["startMonth"]  = 9, 
		["endDay"]      = 12,
		["endMonth"]    = 9,
		["name"]	    = SI_TACHRONOS_Riglametha,
		["date"]	    = SI_TACHRONOS_Riglametha_date,
		["text"]        = SI_TACHRONOS_Riglametha_text,
	},
	{	["startDay"]    = 19, 
		["startMonth"]  = 9, 
		["endDay"]      = 19,
		["endMonth"]    = 9,
		["name"]	    = SI_TACHRONOS_Childrens_Day,
		["date"]	    = SI_TACHRONOS_Childrens_Day_date,
		["text"]        = SI_TACHRONOS_Childrens_Day_text,
	},
	{	["startDay"]    = 5, 
		["startMonth"]  = 10, 
		["endDay"]      = 5,
		["endMonth"]    = 10,
		["name"]	    = SI_TACHRONOS_Dirij_Tereur,
		["date"]	    = SI_TACHRONOS_Dirij_Tereur_date,
		["text"]        = SI_TACHRONOS_Dirij_Tereur_text,
	},
	{	["startDay"]    = 9, 
		["startMonth"]  = 10, 
		["endDay"]      = 9,
		["endMonth"]    = 10,
		["name"]	    = SI_TACHRONOS_Gauntlet,
		["date"]	    = SI_TACHRONOS_Gauntlet_date,
		["text"]        = SI_TACHRONOS_Gauntlet_text,
	},
	{	["startDay"]    = 13, 
		["startMonth"]  = 10, 
		["endDay"]      = 13,
		["endMonth"]    = 10,
		["name"]	    = SI_TACHRONOS_Witches_Festival,
		["date"]	    = SI_TACHRONOS_Witches_Festival_date,
		["text"]        = SI_TACHRONOS_Witches_Festival_text,
	},
	{	["startDay"]    = 23, 
		["startMonth"]  = 10, 
		["endDay"]      = 23,
		["endMonth"]    = 10,
		["name"]	    = SI_TACHRONOS_Broken_Diamonds,
		["date"]	    = SI_TACHRONOS_Broken_Diamonds_date,
		["text"]        = SI_TACHRONOS_Broken_Diamonds_text,
	},
	{	["startDay"]    = 30, 
		["startMonth"]  = 10, 
		["endDay"]      = 30,
		["endMonth"]    = 10,
		["name"]	    = SI_TACHRONOS_Emperors_Birthday,
		["date"]	    = SI_TACHRONOS_Emperors_Birthday_date,
		["text"]        = SI_TACHRONOS_Emperors_Birthday_text,
	},
	{	["startDay"]    = 3, 
		["startMonth"]  = 11, 
		["endDay"]      = 3,
		["endMonth"]    = 11,
		["name"]	    = SI_TACHRONOS_Serpents_Dance,
		["date"]	    = SI_TACHRONOS_Serpents_Dance_date,
		["text"]        = SI_TACHRONOS_Serpents_Dance_text,
	},
	{	["startDay"]    = 8, 
		["startMonth"]  = 11, 
		["endDay"]      = 8,
		["endMonth"]    = 11,
		["name"]	    = SI_TACHRONOS_Moon_Festival,
		["date"]	    = SI_TACHRONOS_Moon_Festival_date,
		["text"]        = SI_TACHRONOS_Moon_Festival_text,
	},
	{	["startDay"]    = 18, 
		["startMonth"]  = 11, 
		["endDay"]      = 18,
		["endMonth"]    = 11,
		["name"]	    = SI_TACHRONOS_Hel_Anseilak,
		["date"]	    = SI_TACHRONOS_Hel_Anseilak_date,
		["text"]        = SI_TACHRONOS_Hel_Anseilak_text,
	},
	{	["startDay"]    = 20, 
		["startMonth"]  = 11, 
		["endDay"]      = 20,
		["endMonth"]    = 11,
		["name"]	    = SI_TACHRONOS_Warriors_Festival,
		["date"]	    = SI_TACHRONOS_Warriors_Festival_date,
		["text"]        = SI_TACHRONOS_Warriors_Festival_text,
	},
	{	["startDay"]    = 15, 
		["startMonth"]  = 12, 
		["endDay"]      = 15,
		["endMonth"]    = 12,
		["name"]	    = SI_TACHRONOS_North_Winds_Prayer,
		["date"]	    = SI_TACHRONOS_North_Winds_Prayer_date,
		["text"]        = SI_TACHRONOS_North_Winds_Prayer_text,
	},
	{	["startDay"]    = 18, 
		["startMonth"]  = 12, 
		["endDay"]      = 18,
		["endMonth"]    = 12,
		["name"]	    = SI_TACHRONOS_Baranth_Do,
		["date"]	    = SI_TACHRONOS_Baranth_Do_date,
		["text"]        = SI_TACHRONOS_Baranth_Do_text,
	},
	{	["startDay"]    = 20, 
		["startMonth"]  = 12, 
		["endDay"]      = 20,
		["endMonth"]    = 12,
		["name"]	    = SI_TACHRONOS_Chila,
		["date"]	    = SI_TACHRONOS_Chila_date,
		["text"]        = SI_TACHRONOS_Chila_text,
	},
	{	["startDay"]    = 25, 
		["startMonth"]  = 12, 
		["endDay"]      = 25,
		["endMonth"]    = 12,
		["name"]	    = SI_TACHRONOS_Saturalia,
		["date"]	    = SI_TACHRONOS_Saturalia_date,
		["text"]        = SI_TACHRONOS_Saturalia_text,
	},
	{	["startDay"]    = 30, 
		["startMonth"]  = 12, 
		["endDay"]      = 30,
		["endMonth"]    = 12,
		["name"]	    = SI_TACHRONOS_Old_Life,
		["date"]	    = SI_TACHRONOS_Old_Life_date,
		["text"]        = SI_TACHRONOS_Old_Life_text,
	},
}

local function getYearDay(d,m)
	return TaChronos.sun:GetTamrielYearDay(m)+d  
end

function hol:CreateLink(event, name)
	name = name or event.name
	return ("|H1:TC_HOLIDAY:"..event.name..":"..event.date..":"..event.text.."|h["..GetString(event.name).."]|h")		
end

function hol:GetCurrentHolidays(d,m)
	local holidays = {}
	local yearDay = getYearDay(d,m)
	for k,event in pairs(self.events) do
		if yearDay >= getYearDay(event.startDay, event.startMonth) and yearDay <= getYearDay(event.endDay, event.endMonth) then
			table.insert(holidays, event)
		end
 	end
	return holidays
end

function hol:IsHoliday(d,m)
	local isholiday = false
	local yearDay = getYearDay(d,m)
	for k,event in pairs(self.events) do
		if yearDay >= getYearDay(event.startDay, event.startMonth) and yearDay <= getYearDay(event.endDay, event.endMonth) then
			isholiday = true
		end
 	end
	return isholiday
end


function hol:GetAllHolidays()
	return self.events
end

function hol:OnLayerPushed(event, layerIndex, activeLayerIndex)	
	--d("Push event: "..layerIndex.."/"..activeLayerIndex)
	if layerIndex ~= 7 and activeLayerIndex ~= 2 then 
		self.holView:SetHidden(true)
	end -- dont' close when '.'
end

function hol:Initialize()
	LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, hol.HandleChatEvent)
	LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_CLICKED_EVENT,  hol.HandleChatEvent) 
	self:CreateHolidayView()
	EVENT_MANAGER:RegisterForEvent("TaCHRONOS_CAL_PUSH", EVENT_ACTION_LAYER_PUSHED, function(...) self:OnLayerPushed(...) end)		
	self:PostCurrentHolidays()
end

function hol.HandleChatEvent(rawLink, mouseButton, linkText, linkStyle, linkType, title, date, text,...) --where ... is the data
  if linkType == "TC_HOLIDAY" then
	hol:ShowHoliday(title, date, text)
    return true
  end
end

function hol:CreateHolidayView()
	local wm  = GetWindowManager() 
	local a   = 600
	local b   = 410

	-- base: tlw and bd
	self.holView = wm:CreateTopLevelWindow("TCHolidayTLW")
	self.holView:SetDimensions(a, b)
	self.holView:SetMovable(true)
	self.holView:SetMouseEnabled(true)
	self.holView:SetClampedToScreen(true)
	self.holView:SetDrawLevel(DL_OVERLAY)
	self.holView:SetAnchor(CENTER, GuiRoot, CWNTER, 0, 0)
	self.holView.bd = CreateControlFromVirtual("TCHolidayBD", self.holView, "ZO_DefaultBackdrop")
	self.holView.bd:SetDimensions(self.holView:GetWidth(),self.holView:GetHeight())
	self.holView.bd:SetAnchor(TOPLEFT, self.holView, TOPLEFT ,0 , 0)		

	-- close button
	self.holView.close = CreateControlFromVirtual(nil, self.holView.bd, 'ZO_CloseButton')
    self.holView.close:SetHandler('OnClicked', function() self.holView:SetHidden(true) end)
    				  	 
	-- title
	self.holView.title = wm:CreateControl("TCHolidayTitle", self.holView, CT_LABEL)
	self.holView.title:SetFont("$(BOLD_FONT)|20|soft-shadow-thick") 
	self.holView.title:SetDimensions(self.holView:GetWidth(),20)
	self.holView.title:SetAnchor(TOPLEFT, self.holView, TOPLEFT, 30, 25)
	self.holView.title:SetColor(.6,.6,1,1)
		
	-- headers
	local font = "EsoUI/Common/Fonts/univers57.otf|16|soft-shadow-thin"
	self.holView.text = wm:CreateControl("TCHolidayText", self.holView, CT_LABEL)
	self.holView.text:SetFont(font) 
	self.holView.text:SetDimensions(self.holView:GetWidth()-60,self.holView:GetHeight()-25)
	self.holView.text:SetAnchor(TOPLEFT, self.holView, TOPLEFT, 30, 56)

	self.holView:SetHidden(true)
end

function hol:ShowHoliday(title, date, text)
	self.holView.title:SetText(GetString(title).." - "..GetString(date))
	self.holView.text:SetText(GetString(text))
	self.holView:SetHeight(self.holView.text:GetTextHeight()+64+20)
	self.holView:SetHidden(false)
end

function hol:PostCurrentHolidays()
	local cnf = TaChronos.cm.config
	if not cnf.showHolidays then return end
	local day, month = select(2,TaChronos.sun:GetTamrielDate())
	local holidays = TaChronos.hol:GetCurrentHolidays(day,month)
	local text = ""
	for k, event in pairs (holidays) do	
		text = text..self:CreateLink(event).." "
	end
	if text ~= "" then zo_callLater(function () d(zo_strformat(SI_TACHRONOS_TODAYS_HOLIDAYS, text)) end, 2000) end
end
