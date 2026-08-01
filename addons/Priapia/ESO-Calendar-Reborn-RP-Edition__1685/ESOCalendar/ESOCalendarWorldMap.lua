function ESOCalendar_WMInit()
	ESOCalendarWM:SetParent(ZO_WorldMap)
	
end

function ESOCalendar_WMUpdateDate()
	if (date_computed == true) then
		ESOCalendarWMDate:SetText(string.format("          %s, %d of the %s 2E %d - Constellation: %s", day[current_inweek_day], current_day, month[current_month], ig_year,
			constellation[current_month], current_day, current_month, current_year))
		local holiday = ""
		local daedric_day = ""
		local index = math.floor(current_day*100+current_month)
		local check_holiday = holidays[index]
		if (check_holiday ~= nil and check_holiday ~= "") then
			holiday = string.format("Holiday: %s", check_holiday)
		end
		
		check_holiday = daedric_days[index]
		if (check_holiday ~= nil and check_holiday ~= "") then
			daedric_day = string.format("Daedric Summoning Day: %s", check_holiday)
		end
		
		ESOCalendarWMHoliday:SetText(holiday)
		ESOCalendarWMDaedricday:SetText(daedric_day)
	end
end