local omr = OneMorRockgrove




function omr.activateOax()
	if omr.vars.enableRedIndicator then
		omr.EnableSafeIndicator()
	end
	if omr.vars.showSafeBorders then
		omr.createSafeBorders()
	end
end

function omr.deactivateOax()
	omr.DisableSafeIndicator()
	omr.destroySafeBorders()
end

-- note for self for later - add option to make borders create on boss activated not just combat started


omr.bossRegistry[1] = omr.activateOax







-- Points obtained from the elms markers created by zbzszzzt123
local safePoly = {
	{93481,80597}, {93320,80506}, {93058,80375},
	{92807,80290}, {92525,80080}, {92063,80107},
	{91857,80115}, {91622,80264}, {91190,80491},
	{90868,80797}, {90586,81282}, {90448,81795},
	{90379,82321}, {90439,82758}, {90654,83091},
	{90880,83294}, {93481,83294}
}

-- Points recorded via a testing run with me, @Chrissy-T, @jowoll, @Jess182, @PyroFD3S
-- a few points need a bit of refining, will do in a later run
local safeEntranceLeftPoly = {
	{90081,76844}, {90027,77513}, {90146,77961},
	{90250,78353}, {90316,78674}, {90378,78945},
	{90558,79167}, {90729,79381}, {91101,79579},
	{91425,79726}, {91821,79778}, {92224,79852},
	{92647,79746}, {93020,79595}, {93287,79379},
	{93481,79206}, {93481,76844}
}


-- Points recorded via a testing run with me, @livelifesimply, @RinBC, @Jess182, @Sandman2055, @Trent-Alexios
-- 58 min oax pulls are draining, especially when you accidentally delete half the markers.
local safeExitRightPoly = {
	{86732,80207}, {87066,80213}, {87380,80139},
	{87585,80122}, {87784,80211}, {88003,80216},
	{88212,80372}, {88386,80377}, {88652,80510},
	{88784,80738}, {88947,80843}, {89155,81030},
	{89292,81244}, {89318,81455}, {89398,81668},
	{89523,81878}, {89508,82175}, {89525,82439},
	{89494,82718}, {89369,83000}, {89187,83244},
	{89115,83448}, {86732,83448}
}

omr.safeZones = {}
omr.safeZones.entranceLeft = safeEntranceLeftPoly
omr.safeZones.exitLeft = safePoly
omr.safeZones.exitRight = safeExitRightPoly




function omr.isUnitInSafeZone(unitTag) 
	local world, px, py, pz = GetUnitWorldPosition(unitTag)
	return omr.insidePolygon(safePoly,{px,pz}) or omr.insidePolygon(safeEntranceLeftPoly,{px,pz}) or omr.insidePolygon(safeExitRightPoly,{px,pz})
end











local red = omr.vars.reverseRed -- originally false, but made to be reverse red since behaviour is reversed
-- OAX POISON SAFE ZONE
function omr.EnableSafeIndicator()
	EVENT_MANAGER:RegisterForUpdate("OMR Safe Zone", 50, function()
		if not omr.isUnitInSafeZone('player') then
			if not red then
				omr.border("OMR Safe Zone", nil, 0xFF00001A, not omr.vars.reverseRed)
				red = true
			end
		else
			if red then
				omr.border("OMR Safe Zone", nil, 0xFF00001A, omr.vars.reverseRed)
				red = false
			end
		end
	end)
end





function omr.DisableSafeIndicator()
	EVENT_MANAGER:UnregisterForUpdate("OMR Safe Zone")
	omr.border("OMR Safe Zone", nil, 0xFF00001A, false)
	red = omr.vars.reverseRed
end





omr.markersEntranceLeft = {}
omr.markersExitLeft = {}
omr.markersExitRight = {}

function omr.createSafeBorders()
	local y = 35850 -- 35727 previously
	local entranceLeft = omr.safeZones.entranceLeft
	local exitLeft = omr.safeZones.exitLeft
	local exitRight = omr.safeZones.exitRight

	if Breadcrumbs then
		-- potentially fixes a bug where lines dont load
		Breadcrumbs.RefreshLines()
	end


	

	
	for i,v in ipairs(entranceLeft) do
		local p = {
			pos = {v[1],y,v[2]},
			color = 0xb2ffff, -- /script d(string.format("%x", LibCodesCommonCode.RGBAToInt32(0,0.7,1,1)))
			texture = "world-pointer-down",
			disableDepthBuffers = true,
			playerFacing = true,
			size = 30,
		}
		omr.markersEntranceLeft[#omr.markersEntranceLeft+1] = omr.worldIcons:PlaceTexture(p)
		--omr.markersEntranceLeft[#omr.markersEntranceLeft+1] = OSI.CreatePositionIcon(v[1], y, v[2], "OdySupportIcons/icons/squares/marker_lightblue.dds", 50, {0,0.7,1})
		
		if omr.vars.breadcrumbsOaxLines then
			if i < #entranceLeft-1 then
				local w = entranceLeft[i+1]
				Breadcrumbs.AddLineToPool(v[1], y, v[2], w[1], y, w[2], {0,0.62,0.58})
			end
		end
	end
	for i,v in ipairs(exitLeft) do

		local p = {
			pos = {v[1],y,v[2]},
			color = 0xff00ff, -- /script d(string.format("%x", LibCodesCommonCode.RGBAToInt32(0,1,0,1)))
			texture = "world-pointer-down",
			disableDepthBuffers = true,
			playerFacing = true,
			size = 30,
		}
		omr.markersExitLeft[#omr.markersExitLeft+1] = omr.worldIcons:PlaceTexture(p)

		--omr.markersExitLeft[#omr.markersExitLeft+1] = OSI.CreatePositionIcon(v[1], y, v[2], "OdySupportIcons/icons/squares/marker_lightblue.dds", 50, {0,1,0})
		
		if omr.vars.breadcrumbsOaxLines then
			if i < #exitLeft-1 then
				local w = exitLeft[i+1]
				Breadcrumbs.AddLineToPool(v[1], y, v[2], w[1], y, w[2], {0,1,0})
			end
		end
	end
	for i,v in ipairs(exitRight) do

		local p = {
			pos = {v[1],y,v[2]},
			color = 0xff66ffff, -- /script d(string.format("%x", LibCodesCommonCode.RGBAToInt32(1,0.4,1,1)))
			texture = "world-pointer-down",
			disableDepthBuffers = true,
			playerFacing = true,
			size = 30,
		}
		omr.markersExitRight[#omr.markersExitRight+1] = omr.worldIcons:PlaceTexture(p)

		--omr.markersExitRight[#omr.markersExitRight+1] = OSI.CreatePositionIcon(v[1], y, v[2], "OdySupportIcons/icons/squares/marker_lightblue.dds", 50, {1,0.4,1})
		
		if omr.customLines then
			omr.worldIcons:RemoveElement(omr.customLines)
			omr.customLines = nil
		end

		if omr.vars.breadcrumbsOaxLines then
			if i < #exitRight-1 then
				local w = exitRight[i+1]
				Breadcrumbs.AddLineToPool(v[1], y, v[2], w[1], y, w[2], {0,0.5,0.86})
			end
		elseif omr.vars.customOaxLines then
			local p = {
				pos = {90108, y, 80146},
				texture = "OneMorRockgrove/OaxPosions.dds",
				disableDepthBuffers = false, -- maybe
				playerFacing = false,
				size = {6752, 6604},
			}
			omr.customLines = omr.worldIcons:PlaceTexture(p)
		end
	end
end

function omr.destroySafeBorders()
	for i,v in pairs(omr.markersEntranceLeft) do
		--OSI.DiscardPositionIcon(v)
		omr.worldIcons:RemoveElement(v)
	end
	for i,v in pairs(omr.markersExitLeft) do
		--OSI.DiscardPositionIcon(v)
		omr.worldIcons:RemoveElement(v)
	end

	for i,v in pairs(omr.markersExitRight) do
		--OSI.DiscardPositionIcon(v)
		omr.worldIcons:RemoveElement(v)
	end
	omr.markersEntranceLeft = {}
	omr.markersExitLeft = {}
	omr.markersExitRight = {}
	if Breadcrumbs then
		Breadcrumbs.RefreshLines()
	end
	if omr.customLines then
		omr.worldIcons:RemoveElement(omr.customLines)
		omr.customLines = nil
	end
end




SLASH_COMMANDS['/showoaxborders'] = omr.createSafeBorders
SLASH_COMMANDS['/hideoaxborders'] = omr.destroySafeBorders
--[[
SLASH_COMMANDS['/enableoaxred'] = omr.EnableSafeIndicator
SLASH_COMMANDS['/disableoaxred'] = omr.DisableSafeIndicator

SLASH_COMMANDS['/swapoaxred'] = function()
	omr.vars.reverseRed = not omr.vars.reverseRed
	d("One Mor Rockgrove: Reverse Red is now: "..tostring(omr.vars.reverseRed))
end
SLASH_COMMANDS['/swapoaxborders'] = function()
	omr.vars.showSafeBorders = not omr.vars.showSafeBorders
	d("One Mor Rockgrove: Show Safe Borders is now: "..tostring(omr.vars.showSafeBorders))
end
--]]