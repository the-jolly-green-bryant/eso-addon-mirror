function ESOCalendar_ScrInit()
	EVENT_MANAGER:RegisterForEvent("ESOCalendarScr", EVENT_ACTION_LAYER_PUSHED, ESOCalendar_ScrHide)
	EVENT_MANAGER:RegisterForEvent("ESOCalendarScr", EVENT_ACTION_LAYER_POPPED, ESOCalendar_ScrShow)
end

function ESOCalendar_ScrUpdateDate()
	if (date_computed == true) then
		ESOCalendarScrDate:SetText(string.format("%s, %d of the %s 2E %d", day[current_inweek_day], current_day, month[current_month], ig_year,
			current_day, current_month, current_year))
		ESOCalendarScr:SetDimensions(ESOCalendarScrDate:GetWidth(), ESOCalendarScrDate:GetHeight()+ESOCalendarScrHour:GetHeight());
	end
end

function ESOCalendar_ScrUpdateHour()
	ESOCalendarScrHour:SetText(GetTimeString())
end

function ESOCalendar_ScrHide(eventCode, layerIndex, activeLayerIndex)
	if activeLayerIndex > 2 then
		ESOCalendarScr:SetHidden(true)
	else
		ESOCalendarScr:SetHidden(false)
	end
end

function ESOCalendar_ScrShow(eventCode, layerIndex, activeLayerIndex)
	if activeLayerIndex > 2 then
		ESOCalendarScr:SetHidden(true)
	else
		ESOCalendarScr:SetHidden(false)
	end
end