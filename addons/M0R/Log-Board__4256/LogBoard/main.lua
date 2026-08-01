LogBoard = {}
local lb = LogBoard
lb.name = "LogBoard"

local toplevel = LogBoardToplevel

toplevel:SetTransformNormalizedOriginPoint(0.5,0.5)
toplevel:SetSpace(SPACE_WORLD) -- can put in the xml, but I was testing with it in INTERFACE SPACE before moving it to WORLD SPACE

toplevel:SetTransformScale(4/400) -- meters divided by width

local boardLookups = {
	[1263] = {91000, 32698+350, 53800, -5*math.pi/8}, --rg
	[1548] = {24752, 33093, 25207, 0.99}, --oc
	[1427] = {110340, 14341, 24966, 4.02}, --se
	[975] = {4343, 50925, 32494, 4.18}, -- hof
	[1121] = {108766, 52871, 48017, 2.90}, -- ss
	[725] = {106746, 43826, 129824, 0.32}, -- mol
	[1478] = {139117, 35347, 170174, 5.31}, -- lc
	[1196] = {126987, 25387, 113082, 1.86}, -- ka
	[1051] = {153638, 30863, 72490, 4.74}, -- cr
	[1344] = {27395, 15860, 175591, 2.86}, -- dsr
	[636] = {62851, 21841, 38642, 4.58}, -- hrc
	[638] = {82741, 9822, 72890, 5.45}, -- aa
	[639] = {108271, 14978, 187756, 5.65}, -- so
	[1000] = {77592, 61818, 99526, 5.89}, -- as
	[1559] = {134243, 39538, 161748, 2.53}, -- oo
}


lb.offset=0



local function updateSync()
	local zone = GetUnitWorldPosition('player')

	local zonePositions = boardLookups[zone]

	-- If you are reading this, I did some testing on preformance. The best way to position multiple controls that I found is to do something along the lines of the below:
	--[[
	function updateMarkersCombinedOrigin()
		local sx, sy, sz = GuiRender3DPositionToWorldPosition(0,0,0)
		for i,v in pairs(testPoints) do
			local x = (v[1] - sx)/100
			local y = v[2]/100
			local z = (v[3] - sz)/100
		end
	end
	--]]

	if zonePositions then
		local x,y,z = WorldPositionToGuiRender3DPosition(zonePositions[1], zonePositions[2]+lb.offset, zonePositions[3])
		toplevel:SetTransformOffset(x, y, z)
		toplevel:SetTransformRotation(0, zonePositions[4], 0)
		--lb.UpdateSign()
		zo_callLater(lb.UpdateSign, 100)
		toplevel:SetHidden(false)
	else
		toplevel:SetHidden(true)
	end
end

EVENT_MANAGER:RegisterForEvent("LogBoardActivated", EVENT_PLAYER_ACTIVATED, updateSync)



local arcanaRaidTeam = {
	["@ShoutFinder"] = true,
	["@Spasm_OCE"] = true,
	["@Dovhesi"] = true,
	["@FatedBeginning"] = true,
	["@WashedNotSloshed"] = true,
	["@BerryBellbell"] = true,
	["@M0R_Gaming"] = true,
	["@JustAMist"] = true,
	["@Prxvokedlegend"] = true,
	["@cheadersauce"] = true,
	["@stileanima"] = true,
	["@Water_meIon"] = true,
	["@Latin"] = true,
}


local function CheckIfInArcana()
	local zone = GetUnitWorldPosition('player')
	if zone ~= 1548 then return end
	local playerName = GetUnitDisplayName("player")
	if arcanaRaidTeam[playerName] then
		local groupSize = GetGroupSize()
		local peopleInGroup = 0
		for i=1,groupSize do
			local groupUnitName = GetUnitDisplayName(GetGroupUnitTagByIndex(i))
			if arcanaRaidTeam[groupUnitName] then
				peopleInGroup = peopleInGroup + 1
			end
		end
		if (groupSize > 0) and ((peopleInGroup/groupSize) >= 0.75) then
			return true
		end
	end
	return false
end


function lb.ToggleLogging()
	local isLogging = IsEncounterLogEnabled()
	local vit = GetRaidReviveCountersRemaining()
	local totalVit = GetCurrentRaidStartingReviveCounters()
	local vitString = ""
	if vit and totalVit then
		vitString = string.format("\n(%d/%d)", vit, totalVit)
	end
	if isLogging then
		d("Turning encounter log off")
		SetEncounterLogEnabled(false)
		LogBoardToplevelText:SetText("|cFF0000You are NOT Logging|r")
		LogBoardToplevelButton:SetText("Start Logging"..vitString)
	else
		d("Turning encounter log on")
		SetEncounterLogEnabled(true)
		LogBoardToplevelText:SetText("|c00FF00You are Logging|r")
		LogBoardToplevelButton:SetText("Stop Logging"..vitString)
	end
end






function lb.UpdateSign()
	local isLogging = IsEncounterLogEnabled()
	local vit = GetRaidReviveCountersRemaining()
	local totalVit = GetCurrentRaidStartingReviveCounters()
	local vitString = ""
	if vit and totalVit then
		vitString = string.format("\n(%d/%d)", vit, totalVit)
	end
	local text = ""
	local colour = ""
	if isLogging then
		colour = "|c00FF00"
		text = "You are Logging"

		if CheckIfInArcana() then
			local time = os.time(os.date("!*t")) - 1767424800
			local days = math.floor(time/86400)
			text = tostring(days).." Days have passed since the Zombie Incident"
			LogBoardToplevelText:SetFont("$(ANTIQUE_FONT)|35|thick-outline")
		else
			LogBoardToplevelText:SetFont("$(ANTIQUE_FONT)|40|thick-outline")
		end

		LogBoardToplevelButton:SetText("Stop Logging"..vitString)
	else
		colour = "|cFF0000"
		text = "You are NOT Logging"

		if CheckIfInArcana() then
			local time = os.time(os.date("!*t")) - 1767424800
			local days = math.floor(time/86400)
			text = tostring(days).." Days have passed since the Zombie Incident"
			LogBoardToplevelText:SetFont("$(ANTIQUE_FONT)|35|thick-outline")
		else
			LogBoardToplevelText:SetFont("$(ANTIQUE_FONT)|40|thick-outline")
		end

		LogBoardToplevelButton:SetText("Start Logging"..vitString)
	end
	LogBoardToplevelText:SetText(""..colour..text.."|r")
end



SecurePostHook(SLASH_COMMANDS, "/encounterlog", lb.UpdateSign)















function lb.OnAddOnLoaded(event, addonName)

	if addonName ~= lb.name then return end

	lb:Initialize()
end
 
-------------------------------------------------------------------------------------------------
--  Initialize Function --
-------------------------------------------------------------------------------------------------
function lb:Initialize()

	lb.vars = ZO_SavedVars:NewAccountWide("LogBoardVars", 1, nil, {minecraftSign = false})

	if lb.vars.minecraftSign then

		lb.offset = -175

		toplevel:SetTransformScale(2/400) -- meters divided by width


		LogBoardToplevelBG:SetCenterTexture("LogBoard/oakBody.dds")
		LogBoardToplevelBG:SetCenterColor(1,1,1)
		LogBoardToplevelBG:SetAlpha(1)
		LogBoardToplevelBG:SetEdgeColor(0,0,0,0.7)


		LogBoardToplevelSignPost:SetCenterTexture("LogBoard/oakStand.dds")
		LogBoardToplevelSignPost:SetCenterColor(1,1,1)
		LogBoardToplevelSignPost:SetAlpha(1)
		LogBoardToplevelSignPost:SetWidth(64)
	end

	EVENT_MANAGER:UnregisterForEvent(lb.name, EVENT_ADD_ON_LOADED)


	SLASH_COMMANDS['/lbtoggleoaksign'] = function()
		lb.vars.minecraftSign = not lb.vars.minecraftSign
		d("Oak sign has been set to "..tostring(lb.vars.minecraftSign).. ". Reload your ui to update the visuals!")
	end

	if LibAddonMenu2 then
		local panelName = "LogBoardSettingsPanel"
		local panelData = {
			type = "panel",
			name = "|cFFD700Log Board|r",
			author = "|c0DC1CF@M0R_Gaming|r"
		}
		local optionsTable = {

				{
					type = "checkbox",
					name = "Enable Minecraft Sign Mode",
					tooltip = "If this is enabled, the log boards will turn into oak signs from miencraft.",
					getFunc = function() return lb.vars.minecraftSign end,
					setFunc = function(value) lb.vars.minecraftSign = value end,
					requiresReload = true
				},
		}
		local panel = LibAddonMenu2:RegisterAddonPanel(panelName, panelData)
		LibAddonMenu2:RegisterOptionControls(panelName, optionsTable)
	end

	if GetUnitDisplayName('player') == "@M0R_Gaming" then
		SLASH_COMMANDS['/lbgetcurrentpos'] = function()
			local zone, x, y, z = GetUnitWorldPosition('player')
			local heading = GetPlayerCameraHeading()
			CHAT_SYSTEM:StartTextEntry(string.format("	[%d] = {%d, %d, %d, %.2f},", zone, x, y+350, z, heading)) --{134295, 39538, 161641, 2.66}
			boardLookups[zone] = {x, y+350, z, heading}
			updateSync()
		end
	end



end
 
-------------------------------------------------------------------------------------------------
--  Register Events --
-------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(lb.name, EVENT_ADD_ON_LOADED, lb.OnAddOnLoaded)