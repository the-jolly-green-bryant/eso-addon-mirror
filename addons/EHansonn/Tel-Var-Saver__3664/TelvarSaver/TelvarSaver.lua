TelVarSaver = TelVarSaver or {}
local TVS = TelVarSaver

TVS.name = "TelVar Saver"
TVS.version = "1.9"
TVS.author = "Ehansonn"

TVS.SavedVariablesName = "TVSVars"
-- NOTE: This is the ZO_SavedVars version. Bumping it WIPES all saved settings,
-- so it intentionally stays put; upgrades are handled by TVS.HandleMigration().
TVS.SVVersion = "1.7"

-- Known campaign IDs (reference-only for dev/debug):
-- Ravenwatch=103, Greyhost=102, Blackreach=101
-- CP=95, NOCP=96, Dragonfire=119, Legion Zero=116
-- Quagmire=111, Fields of regret=112, Ashpit=106, Evergloam=105, Vengeance=124
TVS.CAMPAIGN_ID_CP = 95
TVS.CAMPAIGN_ID_NOCP = 96
TVS.CAMPAIGN_ID_DRAGONFIRE = 119
TVS.CAMPAIGN_ID_LEGION_ZERO = 116

TVS.defaults = {
	CloseLootWindow = true,
	AutoKickOffline = false,
	LastICCamp = 95,
	CustomICCamp = 95,
	AutoAcceptQueue = false,
	SkipBankDialog = true,
	AutoLootGold = false,
	AutoLootTelvar = false,
	AutoLootKeyFrags = true,
	notifications = true,
	notifyBank = false,
	notifyAutoLeave = false,
	notifyQueue = true,
	draggable = true,
	locationx = 275,
	locationy = 150,
	BankScene = true,
	AutoDepoTelvar = false,
	AutoWithdrawTelvar = false,
	DesiredTelvarAmount = 0,
	ICCamp = 95,
	EscapeCamp = 96,
	AutoQueueOut = false,
	TelvarCap = 100,
	GroupQueue = false,
	DisableKeybindInPVE = true,
	SmartQueuePicker = false,
	AllowCyrodiilCampaigns = false,
	AutoLeaveToggleShow = false,
	AutoLeaveToggleDragable = false,
	AutoLeaveToggleX = -250,
	AutoLeaveToggleY = 250,
	SigilReminderEnabled = true,
	SigilReminderHideInSafeZone = true,
	SigilReminderHideInNonSafeZone = false,
	SigilReminderThreshold = 1,
	SigilReminderDurationS = 3,
	SigilReminderColor = { 1, 0.25, 0.25, 1 },
	SigilReminderSoundEnabled = false,
	SigilReminderSound = "NEW_TIMED_NOTIFICATION",
	SigilAutoBuyEnabled = false,
	SigilDesiredAmount = 5,
	SigilMaxSpendAP = 0,
	SigilMinAPReserve = 0,
	SigilBankWithdraw = true,
	notifySigil = true,
}

-- Telvar Icon
TVS.TELVAR_CHAT_ICON = (zo_iconTextFormat("EsoUI/Art/currency/currency_telvar_32.dds", 18, 18))

TVS.SV = {}

TVS.CAMPAIGN_SELECTION_REFRESH_INTERVAL_MS = 10 * 60 * 1000 -- 10 minutes
TVS.CAMPAIGN_SELECTION_REFRESH_THROTTLE_MS = 30 * 1000 -- 30 seconds
TVS.lastCampaignSelectionQueryMS = 0

function TVS.MaybeQueryCampaignSelectionData(throttleMs)
	if type(QueryCampaignSelectionData) ~= "function" then return end

	local now = GetFrameTimeMilliseconds()
	local minDelta = throttleMs or TVS.CAMPAIGN_SELECTION_REFRESH_THROTTLE_MS
	if (now - (TVS.lastCampaignSelectionQueryMS or 0)) < minDelta then return end

	TVS.lastCampaignSelectionQueryMS = now
	QueryCampaignSelectionData()
end

function TVS.EnsureCampaignSelectionDataReady() TVS.MaybeQueryCampaignSelectionData(0) end

function TVS.onLoad(eventCode, addonName)
	EVENT_MANAGER:UnregisterForEvent(TVS.name, EVENT_ADD_ON_LOADED)
	TVS.SV = ZO_SavedVars:NewAccountWide(TVS.SavedVariablesName, TVS.SVVersion, nil, TVS.defaults)

	-- Check if a SV migration is needed
	TVS.HandleMigration()

	-- Ensure campaign selection list is populated (used by settings dropdowns)
	TVS.EnsureCampaignSelectionDataReady()

	-- Keep campaign selection data reasonably fresh for queue estimates
	EVENT_MANAGER:RegisterForUpdate(
		TVS.name .. "_CampaignSelectionRefresh",
		TVS.CAMPAIGN_SELECTION_REFRESH_INTERVAL_MS,
		function() TVS.MaybeQueryCampaignSelectionData(TVS.CAMPAIGN_SELECTION_REFRESH_INTERVAL_MS) end
	)

	-- Creating LAM2 Settings (may need to wait for campaign data)
	if type(GetNumSelectionCampaigns) == "function" and GetNumSelectionCampaigns() > 0 then
		TVS.CreateSettingsMenu()
	else
		EVENT_MANAGER:RegisterForEvent(TVS.name, EVENT_CAMPAIGN_SELECTION_DATA_CHANGED, function()
			EVENT_MANAGER:UnregisterForEvent(TVS.name, EVENT_CAMPAIGN_SELECTION_DATA_CHANGED)
			TVS.CreateSettingsMenu()
		end)
	end

	-- Creating auto queue listener
	EVENT_MANAGER:RegisterForEvent(TVS.name, EVENT_CURRENCY_UPDATE, TVS.AutoQueue)

	-- Bank Scene
	EVENT_MANAGER:RegisterForEvent(TVS.name, EVENT_OPEN_BANK, TVS.DepositTelvar)
	EVENT_MANAGER:RegisterForEvent(TVS.name, EVENT_CLOSE_BANK, TVS.HideUi)
	EVENT_MANAGER:RegisterForEvent(TVS.name, EVENT_BANKED_CURRENCY_UPDATE, TVS.UpdateText)
	EVENT_MANAGER:RegisterForEvent(TVS.name, EVENT_TELVAR_STONE_UPDATE, TVS.UpdateText)

	-- Creating keybinds
	ZO_CreateStringId("SI_BINDING_NAME_QUEUETVSCAMP", "Queue into your selected campaign")
	ZO_CreateStringId("SI_BINDING_NAME_TVSTOGGLEAUTOLEAVE", "Toggle auto leave when Tel Var limit reached")
	ZO_CreateStringId("SI_BINDING_NAME_TVSUSESIGIL", "Use Sigil of Imperial Retreat")
	SLASH_COMMANDS["/tvs"] = TVS.queueCamp
	SLASH_COMMANDS["/tvsdb"] = TVS.DebugStuff

	TVS.SetupSigilReminder()

	-- Update Bank Scene UI
	TVS.UpdateAnchors()
	TVS.UpdateText()
	TVS.SetupBankCheckButtons()
	TVS.UpdateBankControls()

	-- On-screen Auto-Leave toggle button (only visible while in Imperial City)
	TVS.SetupAutoLeaveToggle()
	EVENT_MANAGER:RegisterForEvent(
		TVS.name .. "_AutoLeaveToggleVis",
		EVENT_PLAYER_ACTIVATED,
		TVS.RefreshAutoLeaveToggleVisibility
	)
	-- Refresh the button color as carried telvar crosses the queue limit
	EVENT_MANAGER:RegisterForEvent(
		TVS.name .. "_AutoLeaveToggleTelvar",
		EVENT_TELVAR_STONE_UPDATE,
		TVS.UpdateAutoLeaveToggleVisual
	)

	-- Auto loot imperial fragments
	EVENT_MANAGER:RegisterForEvent(TVS.name, EVENT_LOOT_UPDATED, TVS.OnLootUpdated)

	-- Bank chatter dialog skip
	EVENT_MANAGER:RegisterForEvent(TVS.name, EVENT_CHATTER_BEGIN, TVS.SkipBank)

	TVS.UpdateLastLocation()
	--Setting the last IC camp the player visited
	EVENT_MANAGER:RegisterForEvent(TVS.name, EVENT_PLAYER_ACTIVATED, TVS.UpdateLastLocation)
end

-- -------------------------------------------------------------------------------
-- Dialog skipper stuff
-- -------------------------------------------------------------------------------

-- Used from lazy writ crafter
function TVS.SkipBank()
	if (IsInImperialCity() == false) or (TVS.SV.SkipBankDialog == false) then return end

	if GetInteractionType() ~= INTERACTION_BANK and GetInteractionType() == INTERACTION_CONVERSATION then
		for i = 1, GetChatterOptionCount() do
			local _, optiontype = GetChatterOption(i)
			if optiontype == CHATTER_START_BANK then SelectChatterOption(i) end
		end
	end
end

-- -------------------------------------------------------------------------------
-- Autoloot stuff
-- -------------------------------------------------------------------------------

-- Checking if we looted imperial fragments. Thanks smarter auto loot
function TVS.OnLootUpdated()
	local name, interactType, actionName, owned = GetLootTargetInfo()
	if IsInImperialCity() == false then return end
	if TVS.SV.AutoLootGold == true then LootMoney() end
	if TVS.SV.AutoLootTelvar == true then
		if name == "Chest" then LootCurrency(CURT_TELVAR_STONES) end
		if (name == "Medium Tel Var Sack") or (name == "Hefty Tel Var Crate") or (name == "Light Tel Var Satchel") then
			LootCurrency(CURT_TELVAR_STONES)
			zo_callLater(function()
				if GetNumLootItems() ~= 0 then return end
				local currentScene = SCENE_MANAGER:GetCurrentScene().name
				SCENE_MANAGER:Toggle(currentScene)
				if tostring(currentScene) == "inventory" then SCENE_MANAGER:Show("inventory") end
			end, 100)
		end
	end

	-- Looting Imperial Fragments
	if TVS.SV.AutoLootKeyFrags == true then LootCurrency(CURT_IMPERIAL_FRAGMENTS) end

	-- Legacy code for key frags

	-- if (TVS.SV.AutoLootKeyFrags == true) then
	--     local num = GetNumLootItems()
	--     for i = 1, num, 1 do
	--         local lootId, name, icon, quantity, quality, value, isQuest, isStolen, lootType = GetLootItemInfo(i)
	--         local link = GetLootItemLink(lootId)
	--         -- Keyfrag id 64487
	--         if (GetItemLinkItemId(link) == 64487) then
	--             TVS.LootItem(link,lootId,quantity)
	--         end
	--     end
	-- end
end

-- -- Looting the key frag
-- function TVS.LootItem(link, lootId, quantity)
--     LootItemById(lootId)
-- end

-- -------------------------------------------------------------------------------
-- Bank stuff
-- -------------------------------------------------------------------------------

--  Bank scene to help you manage your telvar. opens menu and auto depos or withdraws if enabled
function TVS.DepositTelvar()
	if IsInImperialCity() == false then
		TVS.HideUi()
		return
	end
	if TVS.SV.BankScene == true then TVS.ShowUi() end

	local currentTelvarOnChar = GetCarriedCurrencyAmount(CURT_TELVAR_STONES)
	local currentTelvarStonesInBank = GetBankedCurrencyAmount(CURT_TELVAR_STONES)

	if (currentTelvarOnChar > TVS.SV.DesiredTelvarAmount) and (TVS.SV.AutoDepoTelvar == true) then
		local amount = currentTelvarOnChar - TVS.SV.DesiredTelvarAmount
		DepositCurrencyIntoBank(CURT_TELVAR_STONES, amount)
		TVS.dtvs("auto deposited " .. "|c8080ff" .. tostring(amount) .. "|r " .. TVS.TELVAR_CHAT_ICON, "notifyBank")
		return
	end

	if (currentTelvarOnChar < TVS.SV.DesiredTelvarAmount) and (TVS.SV.AutoWithdrawTelvar == true) then
		local amount = TVS.SV.DesiredTelvarAmount - currentTelvarOnChar
		if currentTelvarStonesInBank < amount then
			TVS.dtvs("Auto withdraw failed", "notifyBank")
			return
		end
		WithdrawCurrencyFromBank(CURT_TELVAR_STONES, amount)
		TVS.dtvs("auto withdrew " .. "|c8080ff" .. tostring(amount) .. "|r " .. TVS.TELVAR_CHAT_ICON, "notifyBank")
		return
	end
end

-- Buttons in bank scene, withdraws or depos when clicked
function TVS.TelvarButton(value)
	local currentTelvarOnChar = GetCarriedCurrencyAmount(CURT_TELVAR_STONES)
	local currentTelvarStonesInBank = GetBankedCurrencyAmount(CURT_TELVAR_STONES)

	if currentTelvarOnChar > value then
		local amount = currentTelvarOnChar - value
		DepositCurrencyIntoBank(CURT_TELVAR_STONES, amount)
		TVS.dtvs("deposited " .. "|c8080ff" .. tostring(amount) .. "|r " .. TVS.TELVAR_CHAT_ICON, "notifyBank")
		return
	end

	if currentTelvarOnChar < value then
		local amount = value - currentTelvarOnChar

		if currentTelvarStonesInBank < amount then
			TVS.dtvs("Not enough Tel Var to withdraw", "notifyBank")
			return
		end
		WithdrawCurrencyFromBank(CURT_TELVAR_STONES, amount)
		TVS.UpdateText()
		TVS.dtvs("withdrew " .. "|c8080ff" .. tostring(amount) .. "|r " .. TVS.TELVAR_CHAT_ICON, "notifyBank")
		return
	end
end

-- -------------------------------------------------------------------------------
-- Queue stuff
-- -------------------------------------------------------------------------------

function TVS.GetHomeCampaignId()
	local desired = TVS.SV.ICCamp
	local fallback = TVS.defaults.ICCamp
	return TVS.GetAvailableICCampaignId(desired, fallback)
end

function TVS.GetEscapeICCampaignId()
	local desired = TVS.SV.EscapeCamp
	local fallback = TVS.defaults.EscapeCamp
	return TVS.GetAvailableICCampaignId(desired, fallback)
end

-- Helper function to determine if a given campaign id is available for queueing
function TVS.IsCampaignIdAvailableToQueue(campaignId)
	if type(campaignId) ~= "number" then return false end
	local n = GetNumSelectionCampaigns()
	for i = 1, n do
		if
			GetSelectionCampaignId(i) == campaignId
			and (DoesTelVarAmountPreventQueuing() == false)
			and (DoesPlayerMeetCampaignRequirements(campaignId) == true)
		then
			return true
		end
	end
	return false
end

function TVS.GetAvailableICCampaignId(desiredId, fallbackId)
	if
		(type(desiredId) == "number")
		and (IsImperialCityCampaign(desiredId) == true)
		and TVS.IsCampaignIdAvailableToQueue(desiredId)
	then
		return desiredId
	end

	if
		(type(fallbackId) == "number")
		and (IsImperialCityCampaign(fallbackId) == true)
		and TVS.IsCampaignIdAvailableToQueue(fallbackId)
	then
		return fallbackId
	end

	-- Last resort: pick the first available IC campaign
	local n = GetNumSelectionCampaigns()
	for i = 1, n do
		local id = GetSelectionCampaignId(i)
		if (IsImperialCityCampaign(id) == true) and TVS.IsCampaignIdAvailableToQueue(id) then return id end
	end

	return fallbackId
end

function TVS.GetOtherICCampaignId()
	local currentId = GetCurrentCampaignId()

	local homeIC = TVS.GetHomeCampaignId()

	-- If we are not in home, always queue home first.
	if currentId ~= homeIC then return homeIC end

	-- If we are in home, use the user's preferred escape campaign.
	local escapeIC = TVS.GetEscapeICCampaignId()
	if escapeIC ~= currentId then return escapeIC end

	local cp = TVS.CAMPAIGN_ID_CP
	local nocp = TVS.CAMPAIGN_ID_NOCP
	local legionZero = TVS.CAMPAIGN_ID_LEGION_ZERO
	local dragonfire = TVS.CAMPAIGN_ID_DRAGONFIRE

	if currentId == cp then return nocp end
	if currentId == nocp then return cp end

	if currentId == legionZero then return dragonfire end
	if currentId == dragonfire then return legionZero end

	local selected = TVS.GetHomeCampaignId()
	if selected == cp then return nocp end
	if selected == nocp then return cp end

	return selected
end

function TVS.GetTargetICCampaignIdFromIC()
	local currentId = GetCurrentCampaignId()

	if TVS.SV.SmartQueuePicker == true then
		local n = GetNumSelectionCampaigns()
		local bestId = nil
		local bestWaitS = nil

		for i = 1, n do
			local id = GetSelectionCampaignId(i)
			if (id ~= nil) and (id ~= currentId) then
				local allowed = true
				if (TVS.SV.AllowCyrodiilCampaigns == false) and (IsImperialCityCampaign(id) == false) then
					allowed = false
				end

				if allowed then
					if
						(DoesPlayerMeetCampaignRequirements(id) == true)
						and (DoesTelVarAmountPreventQueuing() == false)
					then
						local waitS = GetSelectionCampaignQueueWaitTime(i)
						if (bestId == nil) or (waitS < bestWaitS) then
							bestId = id
							bestWaitS = waitS
						end
					end
				end
			end
		end

		if bestId ~= nil then
			local mins = math.floor(tonumber(bestWaitS) / 60)
			local secs = math.floor(tonumber(bestWaitS) % 60)
			local waitPretty = tostring(bestWaitS) .. "s"
			if mins > 0 then waitPretty = string.format("%dm %ds", mins, secs) end

			return bestId
		end
	end

	return TVS.GetOtherICCampaignId()
end

function TVS.CanQueueForCampaign(campaignId)
	if campaignId == nil then return false end
	if DoesTelVarAmountPreventQueuing() == true then
		TVS.dtvs("Cannot queue for [" .. tostring(GetCampaignName(campaignId)) .. "] with more than " .. tostring(GetTelVarQueueThreshold()) .. " " .. TVS.TELVAR_CHAT_ICON, "notifyQueue")
		return false
	end
	return true
end

function TVS.GetCampaignQueueWaitPretty(campaignId)
	local n = GetNumSelectionCampaigns()
	for i = 1, n do
		if GetSelectionCampaignId(i) == campaignId then
			local waitS = GetSelectionCampaignQueueWaitTime(i)
			local mins = math.floor(tonumber(waitS) / 60)
			local secs = math.floor(tonumber(waitS) % 60)
			if mins > 0 then return string.format("%dm %ds", mins, secs) end
			return tostring(waitS) .. "s"
		end
	end
	return "unknown"
end

function TVS.QueueForCampaignWithEstimate(campaignId, queueAsGroup)
	if TVS.CanQueueForCampaign(campaignId) == false then return false end

	local name = tostring(GetCampaignName(campaignId))
	local waitPretty = TVS.GetCampaignQueueWaitPretty(campaignId)
	TVS.dtvs(string.format("Queued for [%s] (estimated wait %s)", name, waitPretty), "notifyQueue")

	QueueForCampaign(campaignId, queueAsGroup)

	-- Try to refresh selection data so queue wait estimates are fresh-ish next time
	TVS.MaybeQueryCampaignSelectionData()

	return true
end

-- For when you gain telvar and exceed your cap
function TVS.AutoQueue(eventCode, currencyType, currencyLocation, newAmount, oldAmount, reason, reasonSupplementaryInfo)
	if TVS.SV.AutoQueueOut == false then return end
	if not IsInImperialCity() then return end
	if not IsInAvAZone() then return end

	if currencyType ~= CURT_TELVAR_STONES then return end
	if currencyLocation ~= CURRENCY_LOCATION_CHARACTER then return end
	if reason ~= CURRENCY_CHANGE_REASON_PVP_KILL_TRANSFER and reason ~= CURRENCY_CHANGE_REASON_LOOT then return end

	local currentTelvarOnChar = GetCarriedCurrencyAmount(CURT_TELVAR_STONES)
	if GetTelVarQueueThreshold() <= currentTelvarOnChar then return end

	if currentTelvarOnChar >= TVS.SV.TelvarCap then
		if TVS.InSafeZone() == true then return end
		local otherIC = TVS.GetTargetICCampaignIdFromIC()
		if GetCampaignQueueState(otherIC) ~= 3 then
			return
		else
			TVS.UpdateLastLocation()
			local groupQueue = TVS.GetGroupQueue()
			if groupQueue then
				if TVS.AutoKickOfflinePlayers(otherIC) ~= 0 then return end
			end

			TVS.QueueForCampaignWithEstimate(otherIC, groupQueue)
			TVS.AutoQueueControl()
		end
	end
end

-- For the keybind button press
function TVS.queueCamp()
	local groupQueue = TVS.GetGroupQueue()

	if not IsInAvAZone() then
		if TVS.SV.DisableKeybindInPVE == true then return end
	end

	-- New behavior:
	-- - In Cyro (or PvE if keybind is allowed): queue into selected IC campaign
	-- - In IC: queue into the *other* IC campaign instance
	if IsInImperialCity() == true then
		local otherIC = TVS.GetTargetICCampaignIdFromIC()
		if GetCampaignQueueState(otherIC) ~= 3 then
			return
		else
			if groupQueue then
				if TVS.AutoKickOfflinePlayers(otherIC) ~= 0 then return end
			end

			TVS.QueueForCampaignWithEstimate(otherIC, groupQueue)
			TVS.AutoQueueControl()
		end
	end

	local homeIC = TVS.GetHomeCampaignId()
	if (IsInCyrodiil() == true) or (IsInAvAZone() == false) then
		if GetCampaignQueueState(homeIC) ~= 3 then
			return
		else
			if groupQueue then
				if TVS.AutoKickOfflinePlayers(homeIC) ~= 0 then return end
			end

			TVS.QueueForCampaignWithEstimate(homeIC, groupQueue)
			TVS.AutoQueueControl()
		end
	end
end
-- Auto queue stuff
function TVS.AutoQueueControl()
	if TVS.SV.AutoAcceptQueue == false then
		EVENT_MANAGER:UnregisterForEvent(TVS.name, EVENT_CAMPAIGN_QUEUE_STATE_CHANGED)
		return
	end
	EVENT_MANAGER:RegisterForEvent(TVS.name, EVENT_CAMPAIGN_QUEUE_STATE_CHANGED, TVS.AutoAccept)
end

function TVS.AutoAccept(eventCode, id, isGroup, state)
	local groupQueue = TVS.GetGroupQueue()

	if state == CAMPAIGN_QUEUE_REQUEST_STATE_CONFIRMING then
		TVS.dtvs("Entering campaign [" .. tostring(GetCampaignName(id)) .. "]", "notifyQueue")
		ConfirmCampaignEntry(id, groupQueue, true)
	end
end

-- a bunch of squares that accurately contains the IC safe zones
-- x increases to the right on the map
-- y increases going down on the map
TVS.SafeZones = {
	[1] = { lowx = 263010, lowy = 177811, highx = 277158, highy = 183151 }, --right side of AD base
	[2] = { lowx = 259061, lowy = 173749, highx = 263010, highy = 183151 }, -- left side of AD base
	[3] = { lowx = 162000, lowy = 17400, highx = 181900, highy = 25000 }, -- top of EP
	[4] = { lowx = 179500, lowy = 25000, highx = 181900, highy = 29500 }, -- bottom of EP
	[5] = { lowx = 1400, lowy = 155800, highx = 5420, highy = 171000 }, -- middle of DC
	[6] = { lowx = 1400, lowy = 168700, highx = 11000, highy = 172000 }, -- bottom of DC
	[7] = { lowx = 1400, lowy = 153580, highx = 6700, highy = 159320 }, -- top of DC
}

-- Checking if the player is currently within any of the safe zones since midyear boxes give the CURRENCY_CHANGE_REASON_LOOT code
function TVS.InSafeZone()
	local zoneId, px, pz, py = GetUnitRawWorldPosition("player")
	if zoneId ~= 643 then return false end
	for i, zone in ipairs(TVS.SafeZones) do
		if (px >= zone.lowx) and (py >= zone.lowy) and (px <= zone.highx) and (py <= zone.highy) then return true end
	end
	return false
end

-- Checking if we should group queue or not
function TVS.GetGroupQueue()
	local groupQueue = false
	if (IsUnitGrouped("player") == true) and (IsUnitGroupLeader("player") == true) then
		groupQueue = TVS.SV.GroupQueue
	end
	return groupQueue
end

-- If the player is in a group, is group leader, and has an offline member in the group,
-- Kick them and then queue again after x ms
function TVS.AutoKickOfflinePlayers(campaignID)
	if (TVS.SV.AutoKickOffline == false) or (TVS.GetGroupQueue() == false) then return 0 end
	local size = GetGroupSize()
	local count = 0
	if size < 1 then return count end

	for player = size, 1, -1 do
		local unitTag = GetGroupUnitTagByIndex(player)
		if not (IsUnitOnline(unitTag)) then
			local name = GetUnitName(unitTag)
			GroupKick(unitTag)
			count = count + 1
			TVS.dtvs("Kicking " .. name, "notifyQueue")
		end
	end

	if count > 0 then
		zo_callLater(function()
			local newGroupQueue = TVS.GetGroupQueue()
			TVS.QueueForCampaignWithEstimate(campaignID, newGroupQueue)
			TVS.AutoQueueControl()
		end, 200)
	end
	return count
end

-- -------------------------------------------------------------------------------
-- misc stuff
-- -------------------------------------------------------------------------------

function TVS.UpdateLastLocation()
	if IsInImperialCity() == true then
		TVS.SV.LastICCamp = GetCurrentCampaignId()
		return
	end
end

function TVS.HandleMigration()
	local SVVersion = TVS.SV.version
	if SVVersion == TVS.version then return end

	-- Ensure newer campaign fields exist for old saved vars
	if TVS.SV.ICCamp == nil or type(TVS.SV.ICCamp) ~= "number" then TVS.SV.ICCamp = TVS.defaults.ICCamp end
	if TVS.SV.EscapeCamp == nil or type(TVS.SV.EscapeCamp) ~= "number" then
		TVS.SV.EscapeCamp = TVS.defaults.EscapeCamp
	end

	-- The "dragable" setting was renamed to "draggable"; carry over the old value.
	if TVS.SV.dragable ~= nil then
		TVS.SV.draggable = TVS.SV.dragable
		TVS.SV.dragable = nil
	end

	TVS.SV.version = TVS.version
end

-- value: the message to print.
-- category: optional saved-var key (e.g. "notifyBank") for a per-category toggle.
--           When given, the message is suppressed if that category is disabled.
--           "notifications" remains the master on/off switch for everything.
function TVS.dtvs(value, category)
	if TVS.SV.notifications == false then return end
	if (category ~= nil) and (TVS.SV[category] == false) then return end
	if value == nil then return end

	d("|c8080ffTelVar Saver:|r " .. value)
end

function TVS.DebugLogSelectionCampaigns()
	local n = GetNumSelectionCampaigns()
	d("Selection campaigns (" .. tostring(n) .. "):")
	for i = 1, n do
		local id = GetSelectionCampaignId(i)
		local isIC = IsImperialCityCampaign(id)
		local meetsReq = DoesPlayerMeetCampaignRequirements(id)
		local telvarBlocked = DoesTelVarAmountPreventQueuing()
		local waitS = GetSelectionCampaignQueueWaitTime(i)
		local newfunc = GetTelVarQueueThreshold()
		d(
			tostring(i)
				.. ") "
				.. tostring(id)
				.. " - "
				.. tostring(GetCampaignName(id))
				.. " (IC="
				.. tostring(isIC)
				.. ", meetsReq="
				.. tostring(meetsReq)
				.. ", telvarBlocked="
				.. tostring(telvarBlocked)
				.. ", waitS="
				.. tostring(waitS)
				.. ", newfunc="
				.. tostring(newfunc)
				.. ")"
		)
	end
end

function TVS.DebugStuff()
    TVS.MaybeQueryCampaignSelectionData()

	local currentCampaignId = GetCurrentCampaignId()
	TVS.dtvs("You are in campaign id: " .. tostring(currentCampaignId))
	d("...")
	d(TVS.GetHomeCampaignId())

    TVS.DebugLogSelectionCampaigns()
end


EVENT_MANAGER:RegisterForEvent(TVS.name, EVENT_ADD_ON_LOADED, TVS.onLoad)
