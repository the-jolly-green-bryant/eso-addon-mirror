local GetRgPinsCoordsAndTexture

function KecajTrialIcons.LoadRgIcons()
	local chat = LibChatMessage.Create("KecajTrialIcons", "KTI") -- long and short tag to identify who is printing the message
	chat:Print("Entering RG")
	if OSI and OSI.CreatePositionIcon then
		for i, icon in pairs(GetRgPinsCoordsAndTexture()) do
			TrialIcons[i] = KecajTrialIcons.PlaceIcon(icon.x, icon.z, icon.y, icon.texture) -- x, y, z, texture
		end
		chat:Print("Icons created")
	end
end


GetRgPinsCoordsAndTexture = function ()
	return {
        -- trash
        {x = 101489, z = 33244, y = 57714, texture = "odysupporticons/icons/squares/marker_lightblue.dds"},
        {x = 101104, z = 33276, y = 56832, texture = "KecajTrialIcons/icons/g.dds"},
        {x = 114581, z = 33727, y = 60432, texture = "odysupporticons/icons/squares/marker_lightblue.dds"},
        {x = 93157, z = 35851, y = 73601, texture = "odysupporticons/icons/squares/marker_lightblue.dds"},        
        {x = 48406, z = 22156, y = 72635, texture = "odysupporticons/icons/squares/marker_lightblue.dds"},
        {x = 40461, z = 22912, y = 78417, texture = "odysupporticons/icons/squares/marker_lightblue.dds"},
        {x = 40414, z = 23573, y = 85224, texture = "odysupporticons/icons/squares/marker_lightblue.dds"},
        {x = 49035, z = 24076, y = 83848, texture = "odysupporticons/icons/squares/marker_lightblue.dds"},
        {x = 48056, z = 24700, y = 95758, texture = "odysupporticons/icons/squares/marker_lightblue.dds"},
		-- Oax
		{x = 91091, z = 35819, y = 81892, texture = "KecajTrialIcons/icons/b.dds"},
		{x = 91400, z = 35848, y = 81129, texture = "odysupporticons/icons/squares/squaretwo_pink.dds"},
        {x = 91031, z = 35840, y = 81563, texture = "odysupporticons/icons/squares/squaretwo_green_two.dds"},
        {x = 91697, z = 35832, y = 80988, texture = "odysupporticons/icons/squares/squaretwo_green_one.dds"},
        {x = 89703, z = 35848, y = 81130, texture = "odysupporticons/icons/squares/squaretwo_yellow.dds"},
        -- Bahsei
        {x = 99968, z = 42750, y = 100768, texture = "KecajTrialIcons/icons/b.dds"},
        {x = 99988, z = 42750, y = 100440, texture = "odysupporticons/icons/squares/square_red_MT.dds"},
        {x = 99518, z = 42750, y = 100878, texture = "odysupporticons/icons/squares/square_orange_OT.dds"},
	}
end
