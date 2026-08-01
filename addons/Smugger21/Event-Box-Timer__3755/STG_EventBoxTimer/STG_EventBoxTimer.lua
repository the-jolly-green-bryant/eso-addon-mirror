STG_EventBoxTimer = {
	name = "STG_EventBoxTimer",

	pollingActive = false,
	pollingInterval = 900, -- 00:00.9 seconds

	thresholdAutoHide = 900, -- Default: 15:00
	thresholdClear = 180, -- Default: 3:00
	thresholdWarn = 150, -- Default: 2:30
	DefaultIcon = "|H1:item:203568:123:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h",

	maxCombatEndAdjustment = 15, -- 00:15

	-- This whole part is to be re-written
	-- I need to make it in another table like something below,
	-- Which will allow for looping over the list to check the event and Item has been 

	-- Events = {
	-- 	[1] = {
	-- 		name = "Witches Festival",
	-- 		Icon = "|H0:item:84521:123:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	-- 		Timer = {
	-- 			Hide = 900, -- 15:00
	-- 			Ready = 180, -- 3:00
	-- 			Warn = 150, -- 2:30
	-- 		},
	-- 		Loot = {
	-- 			[1] = {
	-- 				id = 190037,
	-- 				quality = "Epic",
	-- 				limited = false,
	-- 				dailyLimit = -1, -- -1 = No Limit
	-- 				type = "Common",
	-- 				longName = "Plunder Skull",
	-- 				descp = "Common Plunder Skull",
	-- 			},
	-- 			[2] = {
	-- 				id = 190013,
	-- 				quality = "Legendary",
	-- 				limited = true,
	-- 				dailyLimit = 1,
	-- 				type = "Arena",
	-- 				longName = "Arena Plunder Skull",
	-- 				descp = "Dragon Star Arena",
	-- 			},
	-- 		},
	-- 	},
	-- },

	-- Event: Witches Festival
	WitchesFestival = {
		Icon = "|H0:item:84521:123:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		Timer = {
			Hide = 900, -- 15:00
			Ready = 180, -- 3:00
			Warn = 150 -- 2:30
		},
		Skulls = {
			[190037] = true -- 2021,2022, 2023 Festival
		},
		DremoraSkulls = {
			[190013] = true, -- Arena
			[190014] = true, -- Incursions
			[190015] = true, -- Delve
			[190016] = true, -- Dungeon
			[190017] = true, -- Public & Sweeper
			[190018] = true, -- Trial
			[190019] = true, -- World
			[190038] = true -- Crow (Event)
		}
	},

	-- Event: Gates of Oblivion
	GatesOfOblivion = {
		Icon = "|H1:item:203568:123:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h",
		Timer = {
			Hide = 1500, -- 25:00
			Ready = 300, -- 5:00
			Warn = 270 -- 4:30
		},
		Coffers = {
			[203568] = true, -- 2023 Blackwood
			[203569] = true -- 2023 Fargrave
		},

		GloriousCoffers = {
			[203566] = true, -- 2023 Glorious Blackwood
			[203567] = true, -- 2023 Glorious Fargrave
			[203570] = true, -- 2023 Glorious Dread Cellar
			[203571] = true, -- 2023 Glorious Red Petal Bastion
			[203572] = true, -- 2023 Glorious Black Drake Villa
			[203573] = true -- 2023 Glorious The Cauldron
		}
	},

	-- Default settings
	defaults = {
		SavedVars = {
			left = 400,
			top = 25,
			autoHide = true
		},
		icon = "|H1:item:203568:123:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h",
		thresholdAutoHide = 900, -- Default: 15:00
		thresholdClear = 180, -- Default: 3:00
		thresholdWarn = 150 -- Default: 2:30
	},

	lastLoot = 0,
	lastCombat = 0
}

function STG_EventBoxTimer.OnAddOnLoaded(eventCode, addonName)
	if (addonName ~= STG_EventBoxTimer.name) then
		return
	end

	EVENT_MANAGER:UnregisterForEvent(STG_EventBoxTimer.name, EVENT_ADD_ON_LOADED)

	STG_EventBoxTimer.vars = ZO_SavedVars:NewAccountWide("STG_EBT_Settings", 1, nil, STG_EventBoxTimer.defaults.SavedVars, nil, "$InstallationWide")
	STG_EventBoxTimer.server = string.gsub(GetWorldName(), "%s+.*", "")

	EVENT_MANAGER:RegisterForEvent(STG_EventBoxTimer.name, EVENT_LOOT_RECEIVED, STG_EventBoxTimer.OnLootReceived)
	EVENT_MANAGER:RegisterForEvent(STG_EventBoxTimer.name, EVENT_PLAYER_COMBAT_STATE, STG_EventBoxTimer.OnPlayerCombatState)

	SLASH_COMMANDS["/ebt.autohide"] = STG_EventBoxTimer.ToggleAutoHide
	SLASH_COMMANDS["/ebt.show"] = STG_EventBoxTimer.Show
	SLASH_COMMANDS["/ebt.hide"] = STG_EventBoxTimer.Hide
	SLASH_COMMANDS["/ebt.test"] = STG_EventBoxTimer.Test
	SLASH_COMMANDS["/ebt.reset"] = STG_EventBoxTimer.Reset
	SLASH_COMMANDS["/ebt.status"] = STG_EventBoxTimer.Status


	STG_EventBoxTimer.InitializeUI()
end

function STG_EventBoxTimer.StartTimer(HideAt, ReadyAt, WarnAt, Icon)

	HideAt = HideAt or STG_EventBoxTimer.defaults.thresholdAutoHide
	ReadyAt = ReadyAt or STG_EventBoxTimer.defaults.thresholdClear
	WarnAt = WarnAt or STG_EventBoxTimer.defaults.thresholdWarn
	Icon = Icon or STG_EventBoxTimer.defaults.icon

	local icon = GetItemLinkInfo(Icon)
	STG_EventBoxTimerFrame:GetNamedChild("Icon"):SetTexture(icon)

	STG_EventBoxTimer.thresholdAutoHide = HideAt
	STG_EventBoxTimer.thresholdClear = ReadyAt
	STG_EventBoxTimer.thresholdWarn = WarnAt
	STG_EventBoxTimer.lastLoot = GetTimeStamp()

	if (STG_EventBoxTimer.lastLoot - STG_EventBoxTimer.lastCombat <= STG_EventBoxTimer.maxCombatEndAdjustment) then
		STG_EventBoxTimer.lastLoot = STG_EventBoxTimer.lastCombat
	end

	if (not STG_EventBoxTimer.pollingActive) then
		STG_EventBoxTimer.pollingActive = true
		EVENT_MANAGER:RegisterForUpdate(STG_EventBoxTimer.name, STG_EventBoxTimer.pollingInterval, STG_EventBoxTimer.Poll)
	end

	STG_EventBoxTimer.Poll()
	STG_EventBoxTimerFrame:SetHidden(false)

end

function STG_EventBoxTimer.OnLootReceived(eventCode, receivedBy, itemName, quantity, itemSound, lootType, self, isPickpocketLoot, questItemIcon, itemId)
	if (self and
		(STG_EventBoxTimer.WitchesFestival.Skulls[itemId] or STG_EventBoxTimer.WitchesFestival.DremoraSkulls[itemId])) then
		STG_EventBoxTimer.StartTimer(STG_EventBoxTimer.WitchesFestival.Timer.Hide, STG_EventBoxTimer.WitchesFestival.Timer.Ready, STG_EventBoxTimer.WitchesFestival.Timer.Warn, STG_EventBoxTimer.WitchesFestival.Icon)
	end

	if (self and
		(STG_EventBoxTimer.GatesOfOblivion.Coffers[itemId] or STG_EventBoxTimer.GatesOfOblivion.GloriousCoffers[itemId])) then
		STG_EventBoxTimer.StartTimer(STG_EventBoxTimer.GatesOfOblivion.Timer.Hide, STG_EventBoxTimer.GatesOfOblivion.Timer.Ready, STG_EventBoxTimer.GatesOfOblivion.Timer.Warn, STG_EventBoxTimer.GatesOfOblivion.Icon)
	end
end

function STG_EventBoxTimer.OnPlayerCombatState(eventCode, inCombat)
	if (not inCombat) then
		STG_EventBoxTimer.lastCombat = GetTimeStamp()
	end
end

function STG_EventBoxTimer.OnMoveStop()
	STG_EventBoxTimer.vars.left = STG_EventBoxTimerFrame:GetLeft()
	STG_EventBoxTimer.vars.top = STG_EventBoxTimerFrame:GetTop()
end

function STG_EventBoxTimer.Poll()
	local elapsed = GetTimeStamp() - STG_EventBoxTimer.lastLoot

	if (STG_EventBoxTimer.vars.autoHide and elapsed >= STG_EventBoxTimer.thresholdAutoHide) then
		STG_EventBoxTimer.StopAndHideTimer()
	else
		local hr = math.floor(elapsed / 3600)
		local min = math.floor(elapsed / 60) % 60
		local sec = elapsed % 60

		STG_EventBoxTimer.label:SetText((hr > 0) and string.format("%d:%02d:%02d", hr, min, sec) or string.format("%d:%02d", min, sec))

		if (elapsed < STG_EventBoxTimer.thresholdWarn) then
			STG_EventBoxTimer.label:SetColor(1, 0, 0, 1)
		elseif (elapsed < STG_EventBoxTimer.thresholdClear) then
			STG_EventBoxTimer.label:SetColor(1, 1, 0, 1)
		else
			STG_EventBoxTimer.label:SetColor(0, 1, 0, 1)
		end
	end
end

function STG_EventBoxTimer.ToggleAutoHide(command)
	STG_EventBoxTimer.vars.autoHide = not STG_EventBoxTimer.vars.autoHide
	local status = GetString("SI_ADDONLOADSTATE", STG_EventBoxTimer.vars.autoHide and ADDON_STATE_ENABLED or ADDON_STATE_DISABLED)
	CHAT_SYSTEM:AddMessage("[Event Box Timer] Auto-Hide: " .. status)
	if (STG_EventBoxTimer.vars.autoHide == false) then
		STG_EventBoxTimer.Show()
	else
		local elapsed = GetTimeStamp() - STG_EventBoxTimer.lastLoot
		if (STG_EventBoxTimer.label:GetText() == "--:--" or elapsed >= STG_EventBoxTimer.thresholdAutoHide) then
			STG_EventBoxTimer.Hide()
		end
	end
end

function STG_EventBoxTimer.InitializeUI()
	STG_EventBoxTimerFrame:ClearAnchors()
	STG_EventBoxTimerFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, STG_EventBoxTimer.vars.left, STG_EventBoxTimer.vars.top)

	local icon = GetItemLinkInfo(STG_EventBoxTimer.DefaultIcon)
	STG_EventBoxTimerFrame:GetNamedChild("Icon"):SetTexture(icon)

	STG_EventBoxTimer.label = STG_EventBoxTimerFrame:GetNamedChild("Label")
	STG_EventBoxTimer.label:SetText("--:--")

	if (STG_EventBoxTimer.vars.autoHide) then
		STG_EventBoxTimerFrame:SetHidden(true)
	end
end

function STG_EventBoxTimer.StopAndHideTimer()
	if (STG_EventBoxTimer.pollingActive) then
		STG_EventBoxTimer.pollingActive = false
		EVENT_MANAGER:UnregisterForUpdate(STG_EventBoxTimer.name)
		STG_EventBoxTimer.label:SetText("--:--")
	end

	STG_EventBoxTimerFrame:SetHidden(true)
end

function STG_EventBoxTimer.PostMessage()
	StartChatInput("/g " .. STG_EventBoxTimer.label:GetText() .. " elapsed since the previous Event Box")
end

function STG_EventBoxTimer.Show()
	STG_EventBoxTimerFrame:SetHidden(false)
end

function STG_EventBoxTimer.Hide()
	STG_EventBoxTimerFrame:SetHidden(true)
end

function STG_EventBoxTimer.Test()
	STG_EventBoxTimer.StartTimer()
end

function STG_EventBoxTimer.Reset()
	STG_EventBoxTimerFrame:ClearAnchors()
	STG_EventBoxTimerFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, STG_EventBoxTimer.defaults.SavedVars.left, STG_EventBoxTimer.defaults.SavedVars.top)
	STG_EventBoxTimer.StopAndHideTimer()
	STG_EventBoxTimer.vars.autoHide = STG_EventBoxTimer.defaults.SavedVars.autoHide
	STG_EventBoxTimer.vars.left = STG_EventBoxTimer.defaults.SavedVars.left
	STG_EventBoxTimer.vars.top = STG_EventBoxTimer.defaults.SavedVars.top
end

function STG_EventBoxTimer.Status()
	local OutputStatus = "...\n"
	OutputStatus = OutputStatus .. "[Event Box Timer] >" .. "\n"
	OutputStatus = OutputStatus .. "    Auto Hide: " .. tostring(STG_EventBoxTimer.vars.autoHide) .. "\n"
	OutputStatus = OutputStatus .. "    Active: " .. tostring(STG_EventBoxTimer.pollingActive) .. "\n"
	OutputStatus = OutputStatus .. "    Current Time: " .. STG_EventBoxTimer.label:GetText() .. "\n"
	OutputStatus = OutputStatus .. "    Displayed: " .. tostring(not STG_EventBoxTimerFrame:IsHidden()) .. "\n"
	OutputStatus = OutputStatus .. "    Position > " .. "\n"
	OutputStatus = OutputStatus .. "        Left: " .. tostring(STG_EventBoxTimer.vars.left) .. "\n"
	OutputStatus = OutputStatus .. "        Top: " .. tostring(STG_EventBoxTimer.vars.top)
	d(OutputStatus)
end

EVENT_MANAGER:RegisterForEvent(STG_EventBoxTimer.name, EVENT_ADD_ON_LOADED, STG_EventBoxTimer.OnAddOnLoaded)
