TrialIcons = {}

function KecajTrialIcons.LoadZonePins( eventCode )
	local zoneId = GetZoneId(GetUnitZoneIndex("player"))
	if OSI and OSI.DiscardPositionIcon then
		KecajTrialIcons.DiscardOldIcons()
	end
	if zoneId == 1427 then -- SE zone ID
		KecajTrialIcons.LoadSEIcons()
	elseif zoneId == 1263 then -- RG zone ID
		KecajTrialIcons.LoadRgIcons()
	end
end

function KecajTrialIcons.GetIconSize()
	return 70
end

function KecajTrialIcons.ArrayValues(t)
	local i = 0
	return function() i = i + 1; return t[i] end
end

function KecajTrialIcons.GetAllIcons()
	return TrialIcons
end

function KecajTrialIcons.DiscardOldIcons()
	for i in KecajTrialIcons.ArrayValues(KecajTrialIcons.GetAllIcons()) do
		OSI.DiscardPositionIcon(i)
	end
end

function KecajTrialIcons.PlaceIcon(x, y, z, texture)
  	return OSI.CreatePositionIcon(x, y, z, texture, KecajTrialIcons.GetIconSize())
end