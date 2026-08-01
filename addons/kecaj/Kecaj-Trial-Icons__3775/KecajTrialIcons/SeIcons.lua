local GetSEStackPinsCoords, GetSEG1PinsCoords, GetSEG2PinsCoords, GetSEFirstBossPinsCoordsAndTexture

function KecajTrialIcons.LoadSEIcons()
	local chat = LibChatMessage.Create("KecajTrialIcons", "KTI") -- long and short tag to identify who is printing the message
	chat:Print("Entering SE")
	if OSI and OSI.CreatePositionIcon then
		-- where to stack mobs
		for i, icon in pairs(GetSEStackPinsCoords()) do
			TrialIcons[i] = KecajTrialIcons.PlaceIcon(icon.x, icon.z, icon.y, "odysupporticons/icons/squares/square_red.dds") -- x, y, z, texture
		end
		size = #TrialIcons
		-- 1st acuity group
		for i, icon in pairs(GetSEG1PinsCoords()) do
			TrialIcons[i + size] = KecajTrialIcons.PlaceIcon(icon.x, icon.z, icon.y, "odysupporticons/icons/squares/squaretwo_green_one.dds") -- x, y, z, texture
		end
		size = #TrialIcons
		-- 2nd acuity group
		for i, icon in pairs(GetSEG2PinsCoords()) do
			TrialIcons[i + size] = KecajTrialIcons.PlaceIcon(icon.x, icon.z, icon.y, "odysupporticons/icons/squares/squaretwo_blue_two.dds") -- x, y, z, texture
		end
		size = #TrialIcons
		for i, icon in pairs(GetSEFirstBossPinsCoordsAndTexture()) do
			TrialIcons[i + size] = KecajTrialIcons.PlaceIcon(icon.x, icon.z, icon.y, icon.texture) -- x, y, z, texture
		end
		chat:Print("Icons created")
	end
end

GetSEStackPinsCoords = function ()
	return {
		-- before 1st boss
		{x = 51086, z = 16550, y = 77007},
		{x = 58980, z = 17710, y = 88186},
		{x = 68191, z = 22700, y = 91344},
		{x = 68331, z = 22677, y = 87631},
		{x = 69170, z = 22645, y = 79588},
		-- before 2nd boss
		{x = 148600, z = 27604, y = 162257},
		{x = 156520, z = 29130, y = 165797},
		{x = 156262, z = 30153, y = 176490},
		{x = 173950, z = 32803, y = 178868},
		{x = 168842, z = 31185, y = 175910},
		-- before 3rd boss
		{x = 197123, z = 35315, y = 77128},
		{x = 190521, z = 35265, y = 63981},
		{x = 193204, z = 35268, y = 62700},
		{x = 196420, z = 35245, y = 52954}
	}
end

GetSEG1PinsCoords = function ()
	return {
		-- before 1st boss
		-- {x = 52919, z = 16392, y = 73059},
		-- {x = 66524, z = 22666, y = 95466},
		-- {x = 69205, z = 22677, y = 83106},
		-- before 2nd boss
		{x = 153228, z = 28731, y = 163555},
		{x = 164814, z = 30314, y = 179873},
		-- before 3rd boss
		{x = 197245, z = 35312, y = 80233},
		{x = 196323, z = 35268, y = 57908}
	}
end

GetSEG2PinsCoords = function ()
	return {
		-- before 1st boss
		-- {x = 56946, z = 17704, y = 84197},
		-- {x = 69419, z = 22677, y = 83140},
		-- before 2nd boss
		{x = 156013, z = 30221, y = 172086},
		{x = 172142, z = 32071, y = 177024},
		-- before 3rd boss
		{x = 196416, z = 35312, y = 80308},
		{x = 195918, z = 35269, y = 57981}
	}
end

GetSEFirstBossPinsCoordsAndTexture = function ()
	return {
		-- group
		{x = 84406, z = 15140, y = 33538, texture = "KecajTrialIcons/icons/g.dds"},
		-- boss
		{x = 84144, z = 15138, y = 34134, texture = "KecajTrialIcons/icons/b.dds"},
		-- wamasu
		-- {x = 84525, z = 15138, y = 34229, texture = "KecajTrialIcons/icons/w.dds"},
		-- bombs
		{x = 84357, z = 15137, y = 35962, texture = "KecajTrialIcons/icons/bomb.dds"},
		{x = 82650, z = 15252, y = 33227, texture = "KecajTrialIcons/icons/bomb.dds"},
		-- tombs
		{x = 84157, z = 15322, y = 32679, texture = "odysupporticons/icons/squares/square_blue.dds"},
		{x = 84911, z = 15319, y = 32719, texture = "odysupporticons/icons/squares/square_blue.dds"},
	}
end