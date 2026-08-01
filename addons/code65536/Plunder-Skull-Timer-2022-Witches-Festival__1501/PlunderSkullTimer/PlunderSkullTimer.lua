PlunderSkullTimer = {
	name = "PlunderSkullTimer",

	pollingActive = false,
	pollingInterval = 900, -- 0.9 seconds

	thresholdAutoHide = 900, -- 15 minutes
	thresholdClear = 180, -- 3 minutes
	thresholdWarn = 150, -- 2.5 minutes

	maxCombatEndAdjustment = 15, -- 15 seconds

	skullIds = {
		--[[ Deprecated
		[ 84521] = true, -- 2016 Festival
		[128358] = true, -- 2017 Festival
		[141770] = true, -- 2018 Festival
		[153502] = true, -- 2019 Festival
		[167234] = true, -- 2020 Festival
		[178686] = true, -- 2021 Festival
		--]]

		[190037] = true, -- 2021 Festival
	},

	dremoraIds = {
		--[[ Deprecated: 2018
		[141771] = true, -- Dremora Plunder Skull, Arena
		[141772] = true, -- Dremora Plunder Skull, Insurgent
		[141773] = true, -- Dremora Plunder Skull, Delve
		[141774] = true, -- Dremora Plunder Skull, Dungeon
		[141775] = true, -- Dremora Plunder Skull, Public & Sweeper
		[141776] = true, -- Dremora Plunder Skull, Trial
		[141777] = true, -- Dremora Plunder Skull, World
		--]]

		--[[ Deprecated: 2019
		[153503] = true, -- Dremora Plunder Skull, Arena
		[153504] = true, -- Dremora Plunder Skull, Insurgent
		[153505] = true, -- Dremora Plunder Skull, Delve
		[153506] = true, -- Dremora Plunder Skull, Dungeon
		[153507] = true, -- Dremora Plunder Skull, Public & Sweeper
		[153508] = true, -- Dremora Plunder Skull, Trial
		[153509] = true, -- Dremora Plunder Skull, World
		--]]

		--[[ Deprecated: 2020
		[167235] = true, -- Dremora Plunder Skull, Arena
		[167236] = true, -- Dremora Plunder Skull, Insurgent
		[167237] = true, -- Dremora Plunder Skull, Delve
		[167238] = true, -- Dremora Plunder Skull, Dungeon
		[167239] = true, -- Dremora Plunder Skull, Public & Sweeper
		[167240] = true, -- Dremora Plunder Skull, Trial
		[167241] = true, -- Dremora Plunder Skull, World
		--]]

		--[[ Deprecated: 2021
		[178687] = true, -- Dremora Plunder Skull, Arena
		[178688] = true, -- Dremora Plunder Skull, Insurgent
		[178689] = true, -- Dremora Plunder Skull, Delve
		[178690] = true, -- Dremora Plunder Skull, Dungeon
		[178691] = true, -- Dremora Plunder Skull, Public & Sweeper
		[178692] = true, -- Dremora Plunder Skull, Trial
		[178693] = true, -- Dremora Plunder Skull, World
		--]]

		[190013] = true, -- Dremora Plunder Skull, Arena
		[190014] = true, -- Dremora Plunder Skull, Incursions
		[190015] = true, -- Dremora Plunder Skull, Delve
		[190016] = true, -- Dremora Plunder Skull, Dungeon
		[190017] = true, -- Dremora Plunder Skull, Public & Sweeper
		[190018] = true, -- Dremora Plunder Skull, Trial
		[190019] = true, -- Dremora Plunder Skull, World
	},

	eventStart = 1666274400, -- 2022-10-20

	-- Default settings
	defaults = {
		left = 400,
		top = 25,
		autoHide = true,
	},

	lastLoot = 0,
	lastCombat = 0,
}

function PlunderSkullTimer.OnAddOnLoaded( eventCode, addonName )
	if (addonName ~= PlunderSkullTimer.name) then return end

	EVENT_MANAGER:UnregisterForEvent(PlunderSkullTimer.name, EVENT_ADD_ON_LOADED)

	PlunderSkullTimer.vars = ZO_SavedVars:NewAccountWide("PlunderSkullTimerSavedVariables", 1, nil, PlunderSkullTimer.defaults, nil, "$InstallationWide")
	PlunderSkullTimer.server = string.gsub(GetWorldName(), "%s+.*", "")

	if (not PlunderSkullTimerLog2019) then
		PlunderSkullTimerLog2019 = { }
	end

	PlunderSkullTimer.DremoraLog = PlunderSkullTimerLog2019

	EVENT_MANAGER:RegisterForEvent(PlunderSkullTimer.name, EVENT_LOOT_RECEIVED, PlunderSkullTimer.OnLootReceived)
	EVENT_MANAGER:RegisterForEvent(PlunderSkullTimer.name, EVENT_PLAYER_COMBAT_STATE, PlunderSkullTimer.OnPlayerCombatState)

	SLASH_COMMANDS["/pstautohide"] = PlunderSkullTimer.ToggleAutoHide
	SLASH_COMMANDS["/pstdremora"] = PlunderSkullTimer.PrintDremoraLog

	PlunderSkullTimer.InitializeUI()
end

function PlunderSkullTimer.OnLootReceived( eventCode, receivedBy, itemName, quantity, itemSound, lootType, self, isPickpocketLoot, questItemIcon, itemId )
	if (self and (PlunderSkullTimer.skullIds[itemId] or PlunderSkullTimer.dremoraIds[itemId])) then
		PlunderSkullTimer.lastLoot = GetTimeStamp()

		if (PlunderSkullTimer.lastLoot - PlunderSkullTimer.lastCombat <= PlunderSkullTimer.maxCombatEndAdjustment) then
			PlunderSkullTimer.lastLoot = PlunderSkullTimer.lastCombat
		end

		if (not PlunderSkullTimer.pollingActive) then
			PlunderSkullTimer.pollingActive = true
			EVENT_MANAGER:RegisterForUpdate(PlunderSkullTimer.name, PlunderSkullTimer.pollingInterval, PlunderSkullTimer.Poll)
		end

		PlunderSkullTimer.Poll()
		PlunderSkullTimerFrame:SetHidden(false)
	end

	if (self and PlunderSkullTimer.dremoraIds[itemId]) then
		table.insert(PlunderSkullTimer.DremoraLog, { GetTimeStamp(), GetUnitDisplayName("player"), itemId, PlunderSkullTimer.server } )
	end
end

function PlunderSkullTimer.OnPlayerCombatState( eventCode, inCombat )
	if (not inCombat) then
		PlunderSkullTimer.lastCombat = GetTimeStamp()
	end
end

function PlunderSkullTimer.OnMoveStop( )
	PlunderSkullTimer.vars.left = PlunderSkullTimerFrame:GetLeft()
	PlunderSkullTimer.vars.top = PlunderSkullTimerFrame:GetTop()
end

function PlunderSkullTimer.Poll( )
	local elapsed = GetTimeStamp() - PlunderSkullTimer.lastLoot

	if (PlunderSkullTimer.vars.autoHide and elapsed >= PlunderSkullTimer.thresholdAutoHide) then
		PlunderSkullTimer.StopAndHideTimer()
	else
		local hr = math.floor(elapsed / 3600)
		local min = math.floor(elapsed / 60) % 60
		local sec = elapsed % 60

		PlunderSkullTimer.label:SetText((hr > 0) and string.format("%d:%02d:%02d", hr, min, sec) or string.format("%d:%02d", min, sec))

		if (elapsed < PlunderSkullTimer.thresholdWarn) then
			PlunderSkullTimer.label:SetColor(1, 0, 0, 1)
		elseif (elapsed < PlunderSkullTimer.thresholdClear) then
			PlunderSkullTimer.label:SetColor(1, 1, 0, 1)
		else
			PlunderSkullTimer.label:SetColor(0, 1, 0, 1)
		end
	end
end

function PlunderSkullTimer.ToggleAutoHide( command )
	PlunderSkullTimer.vars.autoHide = not PlunderSkullTimer.vars.autoHide
	local status = GetString("SI_ADDONLOADSTATE", PlunderSkullTimer.vars.autoHide and ADDON_STATE_ENABLED or ADDON_STATE_DISABLED)
	CHAT_SYSTEM:AddMessage("[Plunder Skull Timer] Auto-Hide: " .. status)
end

function PlunderSkullTimer.PrintDremoraLog( command )
	local entries = #PlunderSkullTimer.DremoraLog
	local matched = 0

	local currentDay = PlunderSkullTimer.GetEventDay(GetTimeStamp())

	for i = 1, entries do
		local itemLink = string.format("|H0:item:%d:124:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", PlunderSkullTimer.DremoraLog[i][3])

		if (string.find(string.lower(GetItemLinkName(itemLink)), string.lower(command))) then
			local date, time = FormatAchievementLinkTimestamp(PlunderSkullTimer.DremoraLog[i][1])
			local day = PlunderSkullTimer.GetEventDay(PlunderSkullTimer.DremoraLog[i][1])
			local server = ""

			if (PlunderSkullTimer.DremoraLog[i][4] and PlunderSkullTimer.DremoraLog[i][4] ~= PlunderSkullTimer.server) then
				server = string.format("|c6699FF[%s]|r ", PlunderSkullTimer.DremoraLog[i][4])
			end

			CHAT_SYSTEM:AddMessage(string.format(
				"|c%s[Day %d]|r |c00CCFF[%s %s]|r %s%s – %s",
				currentDay > day and "999999" or "00CC00",
				day,
				date,
				time,
				server,
				PlunderSkullTimer.DremoraLog[i][2],
				itemLink
			))

			matched = matched + 1
		end
	end

	local count = (entries == matched) and string.format("%d", entries) or string.format("%d/%d", matched, entries)
	CHAT_SYSTEM:AddMessage(string.format("%s Dremora Plunder Skulls", count))
	CHAT_SYSTEM:AddMessage(string.format("Event Day %d", currentDay))
end

function PlunderSkullTimer.GetEventDay( time )
	return(math.floor((time - PlunderSkullTimer.eventStart) / 86400) + 1)
end

function PlunderSkullTimer.InitializeUI( )
	PlunderSkullTimerFrame:ClearAnchors()
	PlunderSkullTimerFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, PlunderSkullTimer.vars.left, PlunderSkullTimer.vars.top)

	local icon = GetItemLinkInfo("|H0:item:84521:123:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")
	PlunderSkullTimerFrame:GetNamedChild("Icon"):SetTexture(icon)

	PlunderSkullTimer.label = PlunderSkullTimerFrame:GetNamedChild("Label")
	PlunderSkullTimer.label:SetText("--:--")

	if (PlunderSkullTimer.vars.autoHide) then
		PlunderSkullTimerFrame:SetHidden(true)
	end
end

function PlunderSkullTimer.StopAndHideTimer( )
	if (PlunderSkullTimer.pollingActive) then
		PlunderSkullTimer.pollingActive = false
		EVENT_MANAGER:UnregisterForUpdate(PlunderSkullTimer.name)
	end

	PlunderSkullTimerFrame:SetHidden(true)
end

function PlunderSkullTimer.PostMessage( )
	StartChatInput("/g " .. PlunderSkullTimer.label:GetText() .. " elapsed since the previous Plunder Skull")
end

EVENT_MANAGER:RegisterForEvent(PlunderSkullTimer.name, EVENT_ADD_ON_LOADED, PlunderSkullTimer.OnAddOnLoaded)
