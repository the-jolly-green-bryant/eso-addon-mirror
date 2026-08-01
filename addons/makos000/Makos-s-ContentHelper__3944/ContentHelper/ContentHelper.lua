ContentHelper = {}
local ContentHelper = ContentHelper

ContentHelper.name = "Makos's ContentHelper"
ContentHelper.version = "2.2.0"
ContentHelper.author = "@makos000"

-- markers on aggroed enemies
-- hover icons
-- tracking icon on person setup

function ContentHelper.LoadLGB()
	ContentHelper.LGB = LibGroupBroadcast
	ContentHelper.handler = ContentHelper.LGB:RegisterHandler("LGBContentHandler", "ContentHelperHandler")
	ContentHelper.handler:SetDisplayName("Content Helper Handler")
	ContentHelper.handler:SetDescription("Makos's Content Helper handler")

	ContentHelper.protocol = ContentHelper.handler:DeclareProtocol(101, "ContentHelperProtocol")

	ContentHelper.protocol:AddField(ContentHelper.LGB.CreateNumericField("contentNum1"))
	ContentHelper.protocol:AddField(ContentHelper.LGB.CreateNumericField("contentNum2"))
	ContentHelper.protocol:AddField(ContentHelper.LGB.CreateNumericField("contentNum3"))
	ContentHelper.protocol:AddField(ContentHelper.LGB.CreateNumericField("contentNum4"))
	ContentHelper.protocol:AddField(ContentHelper.LGB.CreateNumericField("contentNum5"))
	ContentHelper.protocol:AddField(ContentHelper.LGB.CreateStringField("contentString"))

	ContentHelper.protocol:OnData(function(unitTag, data)

		local myName = GetDisplayName()
		local senderName =  GetUnitDisplayName(unitTag)

		if myName ~= senderName then

			if ContentHelper.savedVariables.debug then
				d("Received data from " .. senderName)
				d("tag " .. tostring(unitTag))
				d("contentNum1: " .. data.contentNum1)
				d("contentNum2: " .. data.contentNum2)
				d("contentNum3: " .. data.contentNum3)
				d("contentNum4: " .. data.contentNum4)
				d("contentNum5: " .. data.contentNum5)
				d("contentString: " .. tostring(data.contentString))
			end


			if data.contentNum1 == 1 then
				if ContentHelper.savedVariables.chatNot then
					d("CD from: " .. GetUnitDisplayName(unitTag))
				end
				ContentHelper.StartCD(data.contentNum2)
			end

			if data.contentNum1 == 2 then
				if ContentHelper.savedVariables.chatNot then
					d("Marker from: " .. GetUnitDisplayName(unitTag))
				end
				ContentHelper.ReceiveMarker(data.contentNum2, data.contentNum3, data.contentNum4, data.contentNum5, data.contentString)
			end

			if data.contentNum1 == 3 then
				if IsUnitGroupLeader(unitTag) or GetUnitDisplayName(unitTag) == "@makos000" then
					ContentHelper.DisplayRW(tostring(data.contentString))
				end
			end

			if data.contentNum1 == 998 then
				if ContentHelper.savedVariables.chatNot then
					d("Clear from: " .. GetUnitDisplayName(unitTag))
				end
				ContentHelper.Clear()
			end

			if data.contentNum1 == 999 then
				if ContentHelper.savedVariables.chatNot then
					d("Clear Last from: " .. GetUnitDisplayName(unitTag))
				end
				ContentHelper.ClearLast()
			end
		end

	end)

	ContentHelper.protocol:Finalize({
		isRelevantInCombat = true,
		replaceQueuedMessages = false
	})

end


isCD = false
r = 1

isMarkerCD = false
markerCD = 700

ContentHelper.icons = {}
ContentHelper.hoverIcons = {}
ContentHelper.temp_icons = {}

function ContentHelper.InitializeKeybinds()
	--art\icons\ability_ava_echoing_vigor.dds
	ZO_CreateStringId("SI_BINDING_NAME_MH_PLACE_MARKER", "|cEECA2APlace Marker Target|r")
	ZO_CreateStringId("SI_BINDING_NAME_MH_PLACE_MARKER_SELF", "|cEECA2APlace Marker Self|r")
	ZO_CreateStringId("SI_BINDING_NAME_MH_PLACE_MARKER_CLEAR_ALL", "|cEECA2AMarkers Clear|r")
	ZO_CreateStringId("SI_BINDING_NAME_MH_PLACE_MARKER_CLEAR_LAST", "|cEECA2AClear Marker Last|r")
	ZO_CreateStringId("SI_BINDING_NAME_MH_RW_ONE", "|cEECA2ARaid Warning 1|r")
	ZO_CreateStringId("SI_BINDING_NAME_MH_RW_TWO", "|cEECA2ARaid Warning 2|r")
	ZO_CreateStringId("SI_BINDING_NAME_MH_RW_THREE", "|cEECA2ARaid Warning 3|r")
	ZO_CreateStringId("SI_BINDING_NAME_MH_CD_THREE", "|cEECA2ACD 3|r")
	ZO_CreateStringId("SI_BINDING_NAME_MH_CD_FIVE", "|cEECA2ACD 5|r")
	ZO_CreateStringId("SI_BINDING_NAME_MH_CD_TEN", "|cEECA2ACD 10|r")
	ZO_CreateStringId("SI_BINDING_NAME_MH_CD_ONEFIVE", "|cEECA2ACD 15|r")
end

ContentHelper.isTargetCDOff = true

function ContentHelper.CombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
	local TARGET_NAME = "Fleshspawn"

	if DoesUnitExist("reticleover") and not IsUnitDead("reticleover") and ContentHelper.isTargetCDOff then
		local name = GetUnitName("reticleover")

		if name == TARGET_NAME then

			ContentHelper.PlaceTempHoverMarker()

			ContentHelper.isTargetCDOff = false

			zo_callLater(function() ContentHelper.CDOFF() end, 1500)

		end

	end
end

function ContentHelper.CDOFF()
	ContentHelper.isTargetCDOff = true
end

-----------------------------------
---------Countdown logic
-----------------------------------

function ContentHelper.SendCD(count)
	
	if (count >= 3 and count <= 25 and isCD == false) then
		ContentHelper.protocol:Send({
			contentNum1 = 1,
			contentNum2 = count,
			contentNum3 = 0,
			contentNum4 = 0,
			contentNum5 = 0,
			contentString = "CD"
		})
		ContentHelper.StartCD(count)
	end
end

function ContentHelper.StartCD(count)
	if (count >= 3 and count <= 25 and isCD == false) then
		isCD = true
		
		if isCD == true then
		ContentHelper.UpdateCD(count)
		end
	end
end

function ContentHelper.UpdateCD(count)
	CDLabel1:SetText(count)
	if count > 0 then
		ContentHelper.PlayCustomSound()
	else 
		ContentHelper.PlayCustomSound2()
	end
	
	count = count - 1
	if count < 0 then
		isCD = false
		CDLabel1:SetText("FIRE")
		zo_callLater(function() ContentHelper.ClearText() end, 1000)
	end
	
	if isCD then
		zo_callLater(function() ContentHelper.UpdateCD(count) end, 1000)
	end
	
end

-----------------------------------
---------Icon placement logic
-----------------------------------

function ContentHelper.PlaceTempHoverMarker()

	--ContentHelper.PlayPlaceMarker()

	local cx, cy, cz = LibAkaUtils.getCameraPositionWithOSI()
	local camVector = {x = cx, y = cy, z = cz}
	local pitch = LibAkaUtils.getCameraPitchWithOSI()
	local yaw = LibAkaUtils.getCameraYaw()
	local _, _, worldY, _ = GetUnitRawWorldPosition("player")
	local targetVector = LibAkaUtils.viewPointToTargetPointSameHeight(worldY, camVector, yaw, pitch)

	-- Manually perform the subtraction
	local directionVector = {
		x = targetVector.x - camVector.x,
		y = targetVector.y - camVector.y,
		z = targetVector.z - camVector.z
	}

	-- Scale the vector to reduce the distance (e.g., 0.8 for 80% of the original distance)
	local scalingFactor = 0.85
	directionVector.x = directionVector.x * scalingFactor
	directionVector.y = directionVector.y * scalingFactor
	directionVector.z = directionVector.z * scalingFactor

	-- New target position closer to the camera
	local closerTargetVector = {
		x = camVector.x + directionVector.x,
		y = camVector.y + directionVector.y,
		z = camVector.z + directionVector.z
	}

	-- Assign the new, closer coordinates
	tx = closerTargetVector.x
	ty = targetVector.y
	tz = closerTargetVector.z

	if ContentHelper.savedVariables.debug then
		d( "|cffffff[Target]|r x=" .. tostring(tx) .. " y=" .. tostring(ty) .. " z=" .. tostring(tz) .. " zone=" .. tostring(zone) )
	end


	local hover_icon = OSI.CreatePositionIcon(
			tx,
			ty,
			tz,
			"ContentHelper/ic/red_arrow.dds",
			180)


	hover_icon.data.baseOffset = hover_icon.data.offset or 0
	hover_icon.hover = true


	--EVENT_MANAGER:RegisterForUpdate("HoverIconOffset", 0, function()
	--	local t = GetFrameTimeSeconds()
	--	local hover = math.sin(t * 2) * 0.7
	--
	--	for _, icon2 in pairs(ContentHelper.temp_icons) do
	--		if icon2.use and icon2.data and icon2.hover then
	--			icon2.data.offset = icon2.data.baseOffset + hover
	--		end
	--	end
	--end)

	table.insert(ContentHelper.temp_icons, hover_icon)

	zo_callLater(function() ContentHelper.RemoveHoverMarker(hover_icon) end, 5000)
end

function ContentHelper.RemoveHoverMarker(icon)
	OSI.DiscardPositionIcon(icon)
end

function ContentHelper.PlaceMarker()

	ContentHelper.PlayPlaceMarker()
	
	local cx, cy, cz = LibAkaUtils.getCameraPositionWithOSI()
	local camVector = {x = cx, y = cy, z = cz}
	local pitch = LibAkaUtils.getCameraPitchWithOSI()
	local yaw = LibAkaUtils.getCameraYaw()
	local _, _, worldY, _ = GetUnitRawWorldPosition("player")
	local targetVector = LibAkaUtils.viewPointToTargetPointSameHeight(worldY, camVector, yaw, pitch)
	
	-- Manually perform the subtraction
	local directionVector = {
		x = targetVector.x - camVector.x,
		y = targetVector.y - camVector.y,
		z = targetVector.z - camVector.z
	}
	
	-- Scale the vector to reduce the distance (e.g., 0.8 for 80% of the original distance)
	local scalingFactor = 0.85
	directionVector.x = directionVector.x * scalingFactor
	directionVector.y = directionVector.y * scalingFactor
	directionVector.z = directionVector.z * scalingFactor
	
	-- New target position closer to the camera
	local closerTargetVector = {
		x = camVector.x + directionVector.x,
		y = camVector.y + directionVector.y,
		z = camVector.z + directionVector.z
	}
	
	-- Assign the new, closer coordinates
	tx = closerTargetVector.x
	ty = targetVector.y
	tz = closerTargetVector.z
	
	if ContentHelper.savedVariables.debug then
		d( "|cffffff[Target]|r x=" .. tostring(tx) .. " y=" .. tostring(ty) .. " z=" .. tostring(tz) .. " zone=" .. tostring(zone) )
	end

	local icon = OSI.CreatePositionIcon(
        tx,
        ty,
        tz,
        ContentHelper.savedVariables.texture[1],
        ContentHelper.savedVariables.iconSize)

	local hover = false
	icon.hover = false

	if ContentHelper.savedVariables.texture[2] == "hover" then
		hover = true
	end

	local animated = false

	if ContentHelper.savedVariables.texture[2] == "animated" then
		local anim = icon.anim
		anim.ctrl:SetImageData(ContentHelper.savedVariables.texture[3][2], ContentHelper.savedVariables.texture[3][3])
		anim.ctrl:SetFramerate(ContentHelper.savedVariables.texture[3][1])
		anim.timeline:PlayFromStart()
	end

	if hover then
		icon.data.baseOffset = icon.data.offset or 0
		icon.hover = true
		table.insert(ContentHelper.hoverIcons, icon)
	else
		table.insert(ContentHelper.icons, icon)
	end

	--EVENT_MANAGER:RegisterForUpdate("HoverIconOffsetX", 0, function()
	--	local t = GetFrameTimeSeconds()
	--	local hover = math.sin(t * 2) * 0.7
	--
	--	for _, icon2 in pairs(ContentHelper.hoverIcons) do
	--		if icon2.use and icon2.data and icon2.hover then
	--			icon2.data.offset = icon2.data.baseOffset + hover
	--		end
	--	end
	--end)
end


function ContentHelper.PlaceMarkerOnSelf()
	
	ContentHelper.PlayPlaceMarker()
	
	local zone, mx, my, mz = GetUnitRawWorldPosition( "player" )
	if ContentHelper.savedVariables.debug then
		d( "|cffffff[Player]|r x=" .. tostring(mx) .. " y=" .. tostring(my) .. " z=" .. tostring(mz) .. " zone=" .. tostring(zone) )
	end
	
	
	local icon = OSI.CreatePositionIcon( 
        mx,
        my,
        mz,
        ContentHelper.savedVariables.texture[1],
        ContentHelper.savedVariables.iconSize)

	local hover = false
	icon.hover = false

	if ContentHelper.savedVariables.texture[2] == "hover" then
		hover = true
	end

	if ContentHelper.savedVariables.texture[2] == "animated" then
		local anim = icon.anim
		anim.ctrl:SetImageData(ContentHelper.savedVariables.texture[3][2], ContentHelper.savedVariables.texture[3][3])
		anim.ctrl:SetFramerate(ContentHelper.savedVariables.texture[3][1])
		anim.timeline:PlayFromStart()
	end

	if hover then
		icon.data.baseOffset = icon.data.offset or 0
		icon.hover = true
		table.insert(ContentHelper.hoverIcons, icon)
	else
		table.insert(ContentHelper.icons, icon)
	end

	--EVENT_MANAGER:RegisterForUpdate("HoverIconOffsetX", 0, function()
	--	local t = GetFrameTimeSeconds()
	--	local hover = math.sin(t * 2) * 0.7
	--
	--	for _, icon2 in pairs(ContentHelper.hoverIcons) do
	--		if icon2.use and icon2.data and icon2.hover then
	--			icon2.data.offset = icon2.data.baseOffset + hover
	--		end
	--	end
	--end)
end

function ContentHelper.Clear()
	for i, v in ipairs(ContentHelper.icons) do
		--d(v)
		OSI.DiscardPositionIcon(v)
	end

	for i, v in ipairs(ContentHelper.hoverIcons) do
		--d(v)
		OSI.DiscardPositionIcon(v)
	end
	
	ContentHelper.icons = {}
	ContentHelper.hoverIcons = {}

end

function ContentHelper.ClearLast()
	
	if next(ContentHelper.icons) == nil then
		--
	else
		local lastItem = ContentHelper.icons[#ContentHelper.icons]
		--d(lastItem.x)
		--d(lastItem.y)
		--d(lastItem.z)
		table.remove(ContentHelper.icons, #ContentHelper.icons)
		OSI.DiscardPositionIcon(lastItem)
	end
	
end

function ContentHelper.SendMarker()
	if isMarkerCD == false then

		ContentHelper.PlaceMarker()
		
		local index = ContentHelper.FindIndex(ContentHelper.textures, ContentHelper.savedVariables.texture[1])

		if index then
			--d("The texture is at index: " .. index)
		else
			--d("Texture not found in the table.")
			index = 1
		end
		
		if next(ContentHelper.icons) == nil then
			--
		else
			local lastItem = ContentHelper.icons[#ContentHelper.icons]
			local cx = math.floor(lastItem.x)
			local cy = math.floor(lastItem.y)
			local cz = math.floor(lastItem.z)

			ContentHelper.protocol:Send({
				contentNum1 = 2,
				contentNum2 = cx,
				contentNum3 = cy,
				contentNum4 = cz,
				contentNum5 = index,
				contentString = ContentHelper.savedVariables.texture[2] .. "target"
			})

			if ContentHelper.savedVariables.debug then
				d("cx: " .. tostring(cx))
				d("cy: " .. tostring((cy * 100) + index))
				d("cz: " .. tostring(cz))
			end
		end
		isMarkerCD = true
		zo_callLater(function() ContentHelper.MarkerOffCD() end, markerCD)
		
		if index == 92 then 
			local lastItem = ContentHelper.icons[#ContentHelper.icons]
			local cx = math.floor(lastItem.x)
			local cy = math.floor(lastItem.y)
			local cz = math.floor(lastItem.z)
			ContentHelper.ClearLast()
			ContentHelper.iconCreate(cx, cy, cz)
			
		end
		
	end
end

function ContentHelper.iconCreate(x, y, z)
	local icon = OSI.CreatePositionIcon( 
        x,
        y,
        z,
        "ContentHelper/ic/beacon/Beam13.dds",
        5000)
		
		table.insert(ContentHelper.icons, icon)
end

function ContentHelper.SendMarkerSelf()
	if isMarkerCD == false then
		ContentHelper.PlaceMarkerOnSelf()
		
		local index = ContentHelper.FindIndex(ContentHelper.textures, ContentHelper.savedVariables.texture[1])

		if index then
			--d("The texture is at index: " .. index)
		else
			--d("Texture not found in the table.")
			index = 1
		end
			
		if next(ContentHelper.icons) == nil then
			--
		else
			local lastItem = ContentHelper.icons[#ContentHelper.icons]
			local cx = math.floor(lastItem.x)
			local cy = math.floor(lastItem.y)
			local cz = math.floor(lastItem.z)

			ContentHelper.protocol:Send({
				contentNum1 = 2,
				contentNum2 = cx,
				contentNum3 = cy,
				contentNum4 = cz,
				contentNum5 = index,
				contentString = ContentHelper.savedVariables.texture[2] .. "self"
			})

			if ContentHelper.savedVariables.debug then
				d("cx: " .. tostring(cx))
				d("cy: " .. tostring((cy * 100) + index))
				d("cz: " .. tostring(cz))
			end
		end
		isMarkerCD = true
		zo_callLater(function() ContentHelper.MarkerOffCD() end, markerCD)
		
		if index == 92 then 
			local lastItem = ContentHelper.icons[#ContentHelper.icons]
			local cx = math.floor(lastItem.x)
			local cy = math.floor(lastItem.y)
			local cz = math.floor(lastItem.z)
			ContentHelper.ClearLast()
			ContentHelper.iconCreate(cx, cy, cz)
			
		end
	end
end

function ContentHelper.SendClearAll()

	if isMarkerCD == false then
		ContentHelper.Clear()

		ContentHelper.protocol:Send({
			contentNum1 = 998,
			contentNum2 = 0,
			contentNum3 = 0,
			contentNum4 = 0,
			contentNum5 = 0,
			contentString = "ClearAll"
		})
		isMarkerCD = true
		zo_callLater(function() ContentHelper.MarkerOffCD() end, markerCD)
	end
	
	
end

function ContentHelper.SendClearLast()
	
	if isMarkerCD == false then
		ContentHelper.ClearLast()

		ContentHelper.protocol:Send({
			contentNum1 = 999,
			contentNum2 = 0,
			contentNum3 = 0,
			contentNum4 = 0,
			contentNum5 = 0,
			contentString = "ClearLast"
		})

		isMarkerCD = true
		zo_callLater(function() ContentHelper.MarkerOffCD() end, markerCD)
	end
	
end

function ContentHelper.ReceiveMarker(cx, cy, cz, tex, type)

	cx = cx
	cy = cy
	cz = cz

	ContentHelper.PlayPlaceMarker()

	local iconlocalstring = ContentHelper.textures[1][1]
	if ContentHelper.textures and ContentHelper.textures[tex] and ContentHelper.textures[tex][1] then
		iconlocalstring = ContentHelper.textures[tex][1]
	end

	if ContentHelper.savedVariables.debug then


		d("texture is: " .. iconlocalstring)
	end


	local icon = OSI.CreatePositionIcon(
			cx,
			cy,
			cz,
			iconlocalstring,
			ContentHelper.savedVariables.iconSize)



	if tex == 92 then
		ContentHelper.ClearLast()
		ContentHelper.iconCreate(cx, cy, cz)

	end

	icon.hover = false

	if type == "hovertarget" or type == "hoverself" then
		hover = true
	else
		table.insert(ContentHelper.icons, icon)
	end

	if type == "animatedtarget" or type == "animatedself" then
		local anim = icon.anim
		anim.ctrl:SetImageData(ContentHelper.textures[tex][3][2], ContentHelper.textures[tex][3][3])
		anim.ctrl:SetFramerate(ContentHelper.textures[tex][3][1])
		anim.timeline:PlayFromStart()
	end

	if hover then
		icon.data.baseOffset = icon.data.offset or 0
		icon.hover = true
		table.insert(ContentHelper.hoverIcons, icon)
	end

--[[	EVENT_MANAGER:RegisterForUpdate("HoverIconOffsetX", 0, function()
		local t = GetFrameTimeSeconds()
		local hover = math.sin(t * 2) * 0.7

		for _, icon2 in pairs(ContentHelper.hoverIcons) do
			if icon2.use and icon2.data and icon2.hover then
				icon2.data.offset = icon2.data.baseOffset + hover
			end
		end
	end)]]

end

-----------------------------------
---------Raid Warning
-----------------------------------

function ContentHelper.DisplayRW(mString)

	ContentHelper.PlayRWSound()
	
	CDLabel1:SetText(string.upper(mString))
	zo_callLater(function() ContentHelper.ClearText() end, 4000)
end

function ContentHelper.SendRW(mString)
	if IsUnitGroupLeader('player') or GetUnitDisplayName('player') == "@makos000" then

		ContentHelper.DisplayRW(mString)
		
		if isMarkerCD == false then
			ContentHelper.protocol:Send({
				contentNum1 = 3,
				contentNum2 = 0,
				contentNum3 = 0,
				contentNum4 = 0,
				contentNum5 = 0,
				contentString = mString
			})
			isMarkerCD = true
			zo_callLater(function() ContentHelper.MarkerOffCD() end, markerCD)
		end
	end
end

-----------------------------------
---------Slash commands
-----------------------------------
 
SLASH_COMMANDS["/mcd"] = function(duration)
	ContentHelper.SendCD(tonumber(duration))
end

SLASH_COMMANDS["/mplaceself"] = function()
	ContentHelper.SendMarkerSelf()
end

SLASH_COMMANDS["/mplacetarget"] = function()
	ContentHelper.SendMarker()
end

SLASH_COMMANDS["/mclear"] = function()
	ContentHelper.SendClearAll()
end

SLASH_COMMANDS["/mclearlast"] = function()
	ContentHelper.SendClearLast()
end

SLASH_COMMANDS["/mrw"] = function(mString)
	ContentHelper.SendRW(tostring(mString))
end

SLASH_COMMANDS["/mdebug"] = function()
	ContentHelper.Debug()
end

function ContentHelper.LoadedMessage()
	d("Makos's ContentHelper loaded")
end

function ContentHelper.InitialLoop()

	SetFloatingMarkerInfo(MAP_PIN_TYPE_AGGRO, ContentHelper.savedVariables.enemyMarkerSize, "ContentHelper/ic/target/skull_arrow.dds")
	if ContentHelper.savedVariables.isMarkerEnemy then
		SetFloatingMarkerGlobalAlpha(1)
	else
		SetFloatingMarkerGlobalAlpha(0)
	end

	zo_callLater(function() ContentHelper.InitialLoop() end, 3000)
end

function ContentHelper.OnAddOnLoaded()

	ContentHelper.savedVariables = ZO_SavedVars:NewAccountWide("ContentHelperSavedVariables", 1, nil, {})

	zo_callLater(function() ContentHelper.LoadedMessage() end, 7000)
	zo_callLater(function() ContentHelper.LoadLGB() end, 50)
	zo_callLater(function() ContentHelper.CreateTextureGrid() end, 50)

	EVENT_MANAGER:RegisterForEvent(ContentHelper.name, EVENT_COMBAT_EVENT, ContentHelper.CombatEvent)

	ContentHelper.SavedVars()

	ContentHelper.InitializeKeybinds()
	ContentHelper.InitialLoop()
	ContentHelper.AddonMenu()

	
	EVENT_MANAGER:UnregisterForEvent(ContentHelper.name, EVENT_ADD_ON_LOADED)

end

EVENT_MANAGER:RegisterForEvent(ContentHelper.name, EVENT_ADD_ON_LOADED, ContentHelper.OnAddOnLoaded)
