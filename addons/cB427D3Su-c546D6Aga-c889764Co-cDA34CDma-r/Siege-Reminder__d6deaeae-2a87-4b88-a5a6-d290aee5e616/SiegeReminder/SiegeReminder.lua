--------------------------------------------------------------
-- SiegeReminder.lua — Stand-alone v1.0.0 (Siege Marshal Update)
-- Author: SugaComa
--------------------------------------------------------------
local ADDON_NAME = "SiegeReminder"
local EM = EVENT_MANAGER
local CHECK_INTERVAL_MS = 120000 -- 2 min recheck while low
local lastCheck = 0

local isAtSiegeMerchant = false
local isLowOnSiege = false
local remindTimerActive = false
local bankSessionRunning = false

--------------------------------------------------------------
-- Helpers
--------------------------------------------------------------
local function chat(msg)
	if CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then
		CHAT_SYSTEM:AddMessage("|cFFD700[Siege Marshal]|r " .. msg)
	else
		d("|cFFD700[Siege Marshal]|r " .. msg)
	end
end

local function debugBank(msg)
	if SiegeReminder.SV and SiegeReminder.SV.debug then
		chat("[Bank] " .. tostring(msg))
	end
end

--------------------------------------------------------------
-- Notifications (Chat / Alert / Full Screen)
--------------------------------------------------------------
local function Notify(msg)
	local mode = (SiegeReminder.SV and SiegeReminder.SV.reminderType) or "Chat"
	local sound = SOUNDS.GENERAL_ALERT_ERROR
	local prefix = "|cFFD700[Siege Marshal]|r "

	if mode == "Chat" then
		chat(msg)

	elseif mode == "Alert" then
		local CSA = CENTER_SCREEN_ANNOUNCE
		if CSA and CSA.CreateMessageParams then
			local p = CSA:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, sound)
			p:SetText(prefix .. tostring(msg))
			p:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_CHAMPION_POINT_GAINED)
			CSA:DisplayMessage(p)
		else
			ZO_Alert(UI_ALERT_CATEGORY_ALERT, sound, prefix .. tostring(msg))
		end

	elseif mode == "Full Screen" then
		local CSA = CENTER_SCREEN_ANNOUNCE
		if CSA and CSA.CreateMessageParams then
			local p = CSA:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, sound)
			p:SetText(prefix .. tostring(msg))
			p:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_CHAMPION_POINT_GAINED)
			CSA:DisplayMessage(p)
		else
			ZO_Alert(UI_ALERT_CATEGORY_ALERT, sound, prefix .. tostring(msg))
		end
	end
end



--------------------------------------------------------------
-- Safe AVA Detection
--------------------------------------------------------------
local function IsInAvA()
	-- Always check for the function and handle nil gracefully
	local inAvA = false

	if IsInAvAZone and IsInAvAZone() then
		inAvA = true
	elseif IsPlayerInAvAWorld and IsPlayerInAvAWorld() then
		inAvA = true
	elseif GetCurrentSubZoneName and type(GetCurrentSubZoneName) == "function" then
		local zone = GetCurrentSubZoneName()
		if zone and type(zone) == "string" and zone:lower():find("imperial city") then
			inAvA = true
		end
	end

	return inAvA
end

local function IsInCyrodiil()
	return IsInAvA()
end


--------------------------------------------------------------
-- Siege Merchant Detection (safe)
--------------------------------------------------------------
local function OnStoreOpen()
	local name = (GetStoreName and GetStoreName()) or ""
	name = name:lower()
	if name ~= "" and (name:find("siege") or name:find("quartermaster")) then
		isAtSiegeMerchant = true
		if SiegeReminder.SV.debugMode then
			chat(string.format("Merchant opened: %s (siege vendor)", name))
		end
	else
		isAtSiegeMerchant = false
	end
end

local function OnStoreClose()
	if isAtSiegeMerchant and SiegeReminder.SV.debugMode then
		chat("Merchant closed — resuming checks.")
	end
	isAtSiegeMerchant = false
end

--------------------------------------------------------------
-- Siege Inventory
--------------------------------------------------------------
local function IsSiegeItem(bagId, slotIndex)
	local itemType = GetItemType(bagId, slotIndex)
	return itemType == ITEMTYPE_SIEGE or itemType == ITEMTYPE_AVA_REPAIR
end

local function GetFreeSlotInBag(bagId)
	if FindFirstEmptySlotInBag then
		return FindFirstEmptySlotInBag(bagId)
	end
	for slot = 0, GetBagSize(bagId) - 1 do
		local itemType = GetItemType(bagId, slot)
		if itemType == ITEMTYPE_NONE then
			return slot
		end
	end
	return nil
end

local function GetSiegeTypeKey(itemName)
	if not SiegeReminder.SV or not SiegeReminder.SV.siegeTypes then return nil end
	local name = tostring(itemName or "")
	if name == "" then return nil end
	name = name:lower()
	for typeKey in pairs(SiegeReminder.SV.siegeTypes) do
		if name:find(typeKey:lower(), 1, true) then
			return typeKey
		end
	end
	return nil
end

local function CountSiegeByType(bagId)
	local counts = {}
	for slot = 0, GetBagSize(bagId) - 1 do
		if IsSiegeItem(bagId, slot) then
			local itemName = GetItemName(bagId, slot)
			local key = GetSiegeTypeKey(itemName)
			if key then
				counts[key] = (counts[key] or 0) + GetSlotStackSize(bagId, slot)
			end
		end
	end
	return counts
end

local function BuildSiegeSlotsByType(bagId)
	local map = {}
	for slot = 0, GetBagSize(bagId) - 1 do
		if IsSiegeItem(bagId, slot) then
			local itemName = GetItemName(bagId, slot)
			local key = GetSiegeTypeKey(itemName)
			if key then
				map[key] = map[key] or {}
				map[key][#map[key] + 1] = { slot = slot, stack = GetSlotStackSize(bagId, slot) }
			end
		end
	end
	for _, list in pairs(map) do
		table.sort(list, function(a, b) return (a.stack or 0) > (b.stack or 0) end)
	end
	return map
end

local function GetSiegeInventory()
	local total, list = 0, {}
	for _, bagId in ipairs({ BAG_BACKPACK, BAG_WORN }) do
		for slot = 0, GetBagSize(bagId) - 1 do
			if IsSiegeItem(bagId, slot) then
				local itemName = GetItemName(bagId, slot)
				local stack = GetSlotStackSize(bagId, slot)
				total = total + stack
				list[itemName] = (list[itemName] or 0) + stack
			end
		end
	end
	return total, list
end

local function PrintSiegeBreakdown()
	if not SiegeReminder.SV.debugMode then return end
	local total, list = GetSiegeInventory()
	chat(string.format("Debug: Total siege items = %d", total))
	for name, count in pairs(list) do
		chat(string.format("  %s: %d", name, count))
	end
end

--------------------------------------------------------------
-- Bank Move Queue
--------------------------------------------------------------
local function QueueMove(queue, bagFrom, slotFrom, bagTo, slotTo, qty)
	queue[#queue + 1] = {
		bagFrom = bagFrom,
		slotFrom = slotFrom,
		bagTo = bagTo,
		slotTo = slotTo,
		qty = qty,
	}
end

local function SafeRequestMoveItem(bagFrom, slotFrom, bagTo, slotTo, qty)
	if CallSecureProtected then
		CallSecureProtected("RequestMoveItem", bagFrom, slotFrom, bagTo, slotTo, qty)
	elseif RequestMoveItem then
		RequestMoveItem(bagFrom, slotFrom, bagTo, slotTo, qty)
	end
end

local function RunQueue(handleName, queue, delayMs, onDone)
	if not queue or #queue == 0 then
		if onDone then onDone(0, nil) end
		return
	end

	local moved = 0
	local index = 1
	local delay = tonumber(delayMs) or 700

	EM:UnregisterForUpdate(handleName)
	EM:RegisterForUpdate(handleName, delay, function()
		if not bankSessionRunning then
			EM:UnregisterForUpdate(handleName)
			if onDone then onDone(moved, "closed") end
			return
		end

		local move = queue[index]
		if not move then
			EM:UnregisterForUpdate(handleName)
			if onDone then onDone(moved, nil) end
			return
		end

		local slotTo = move.slotTo
		if not slotTo then
			slotTo = GetFreeSlotInBag(move.bagTo)
		end
		if not slotTo then
			EM:UnregisterForUpdate(handleName)
			if onDone then onDone(moved, "full") end
			return
		end

		if SafeRequestMoveItem then
			SafeRequestMoveItem(move.bagFrom, move.slotFrom, move.bagTo, slotTo, move.qty)
			moved = moved + (move.qty or 0)
		end

		index = index + 1
	end)
end

--------------------------------------------------------------
-- Bank Automation
--------------------------------------------------------------
local function WithdrawToCarryMax()
	if not SiegeReminder.SV or not SiegeReminder.SV.siegeTypes then return end

	local carried = CountSiegeByType(BAG_BACKPACK)
	for key, count in pairs(CountSiegeByType(BAG_WORN)) do
		carried[key] = (carried[key] or 0) + count
	end

	local bankSlots = BuildSiegeSlotsByType(BAG_BANK)
	local queue = {}

	for typeKey, cfg in pairs(SiegeReminder.SV.siegeTypes) do
		if cfg and cfg.enabled then
			local maxCarry = tonumber(cfg.maxCarry) or 0
			if maxCarry > 0 then
				local have = carried[typeKey] or 0
				local need = maxCarry - have
				if need > 0 then
					local slots = bankSlots[typeKey] or {}
					for i = 1, #slots do
						if need <= 0 then break end
						local entry = slots[i]
						local qty = math.min(entry.stack, need)
						QueueMove(queue, BAG_BANK, entry.slot, BAG_BACKPACK, nil, qty)
						need = need - qty
					end
				end
			end
		end
	end

	RunQueue("SIEGE_BANK_WITHDRAW", queue, SiegeReminder.SV.bankMoveDelayMs, function(moved, reason)
		if moved > 0 then
			Notify("Topped up siege from bank (Cyrodiil).")
		end
		if reason == "full" then
			Notify("Backpack full. Siege withdraw stopped.")
		end
	end)
end

local function DepositAllSiege()
	if not SiegeReminder.SV or SiegeReminder.SV.depositAllOutsideAvA ~= true then return end
	local queue = {}
	local slotsByType = BuildSiegeSlotsByType(BAG_BACKPACK)
	for _, slots in pairs(slotsByType) do
		for i = 1, #slots do
			local entry = slots[i]
			QueueMove(queue, BAG_BACKPACK, entry.slot, BAG_BANK, nil, entry.stack)
		end
	end

	RunQueue("SIEGE_BANK_DEPOSIT", queue, SiegeReminder.SV.bankMoveDelayMs, function(moved, reason)
		if moved > 0 then
			Notify("Deposited all siege to bank (outside Cyrodiil).")
		end
		if reason == "full" then
			Notify("Bank full. Siege deposit stopped.")
		end
	end)
end

local function OnBankOpened(_, bag)
	if not SiegeReminder.SV or SiegeReminder.SV.enabledBankAutomation ~= true then return end
	if bag ~= BAG_BANK and bag ~= BAG_SUBSCRIBER_BANK then return end
	if bankSessionRunning then return end

	bankSessionRunning = true
	debugBank("Bank opened. Running automation.")

	zo_callLater(function()
		if not bankSessionRunning then return end
	if IsInCyrodiil() then
		WithdrawToCarryMax()
	else
		DepositAllSiege()
	end
end, 250)
end

local function OnBankClosed()
	if not bankSessionRunning then return end
	bankSessionRunning = false
	EM:UnregisterForUpdate("SIEGE_BANK_WITHDRAW")
	EM:UnregisterForUpdate("SIEGE_BANK_DEPOSIT")
	debugBank("Bank closed. Queue cleared.")
end

--------------------------------------------------------------
-- Core Check Logic
--------------------------------------------------------------
local function CheckSiegeStock()
	if not IsInAvA() then return end

	local _, list = GetSiegeInventory()
	local lowDetected = false

	for siegeName, data in pairs(SiegeReminder.SV.siegeTypes) do
		if data.enabled then
			local have = 0
			for name, qty in pairs(list) do
				if name:lower():find(siegeName:lower()) then
					have = have + qty
				end
			end
			if have < (tonumber(data.minCarry) or 0) then
				lowDetected = true
				if SiegeReminder.SV.debugMode then
					chat(string.format("[DEBUG] Low: %s (%d/%d)", siegeName, have, tonumber(data.minCarry) or 0))
				end
			end
		end
	end

	if lowDetected then
		if not isLowOnSiege then
			Notify(" You are running low on siege supplies — restock before heading out!")
			isLowOnSiege = true
		end
	else
		if isLowOnSiege then
			chat(" All siege stock replenished!")
		end
		isLowOnSiege = false
	end
end

--------------------------------------------------------------
-- Continuous Reminder Loop
--------------------------------------------------------------
local function StartReminderLoop()
	if remindTimerActive then return end
	remindTimerActive = true

	local function Loop()
		if not IsInAvA() then
			remindTimerActive = false
			return
		end

		CheckSiegeStock()

		if isLowOnSiege and not isAtSiegeMerchant then
			Notify(" You are still running low on siege — visit a merchant to restock!")
		end

		if not isLowOnSiege then
			remindTimerActive = false
			if SiegeReminder.SV.debugMode then
				chat("All siege levels OK — reminder loop stopped.")
			end
			return
		end

		zo_callLater(Loop, CHECK_INTERVAL_MS)
	end

	zo_callLater(Loop, CHECK_INTERVAL_MS)
end

--------------------------------------------------------------
-- Helper: GetLowSiegeList()
--------------------------------------------------------------
local function GetLowSiegeList()
	local _, list = GetSiegeInventory()
	local lowList = {}

	for siegeName, data in pairs(SiegeReminder.SV.siegeTypes) do
		if data.enabled then
			local have = 0
			for name, qty in pairs(list) do
				if name:lower():find(siegeName:lower()) then
					have = have + qty
				end
			end
			if have < (tonumber(data.minCarry) or 0) then
				table.insert(lowList, string.format("%s (%d/%d)", siegeName, have, tonumber(data.minCarry) or 0))
			end
		end
	end
	return lowList
end

--------------------------------------------------------------
-- OnPlayerActivated (quiet but informative)
--------------------------------------------------------------
local function OnPlayerActivated()
	if not IsInAvA() then return end
	zo_callLater(function()
		CheckSiegeStock()

		-- gather shortages
		local lowList = GetLowSiegeList()
		if #lowList > 0 then
			local msg = "You are running low on siege: " .. table.concat(lowList, ", ") .. "."
			chat(msg)
		elseif SiegeReminder.SV.debugMode then
			local total = select(1, GetSiegeInventory())
			chat(string.format("Debug: Ready check — carrying |cFFFFFF%d|r siege items.", total))
			PrintSiegeBreakdown()
		end

		StartReminderLoop()
	end, 2000)
end

local function OnZoneChanged()
	if IsInAvA() then
		zo_callLater(function()
			CheckSiegeStock()
			StartReminderLoop()
		end, 2000)
	end
end

local function OnInventoryUpdate(_, bagId, slotId)
	if bagId ~= BAG_BACKPACK and bagId ~= BAG_WORN then return end
	if not IsSiegeItem(bagId, slotId) then return end
	CheckSiegeStock()
	if isLowOnSiege then StartReminderLoop() end
end

--------------------------------------------------------------
-- Slash Commands
--------------------------------------------------------------
local function ToggleDebug()
	SiegeReminder.SV.debugMode = not SiegeReminder.SV.debugMode
	if SiegeReminder.SV.debugMode then
		chat("Debug mode |c00FF00ENABLED|r — siege details will print.")
	else
		chat("Debug mode |cFF0000DISABLED|r.")
	end
end

local function ManualCheck()
	CheckSiegeStock()
end

SLASH_COMMANDS["/sgrdebug"] = ToggleDebug
SLASH_COMMANDS["/sgrcheck"] = ManualCheck


--------------------------------------------------------------
-- LHAS Menu
--------------------------------------------------------------
local function CreateSettingsMenu()
	if not LibHarvensAddonSettings then return end
	local LHAS = LibHarvensAddonSettings
	local options = { allowDefaults = true, allowRefresh = true }
	local settings = LHAS:AddAddon("Siege Reminder", options)
	if not settings then return end

	settings:AddSetting({
		type = LHAS.ST_CHECKBOX,
		label = "Enable Debug Mode",
		tooltip = "Print siege inventory breakdowns in chat.",
		default = false,
		getFunction = function() return SiegeReminder.SV.debugMode end,
		setFunction = function(val) SiegeReminder.SV.debugMode = val end,
	})

	settings:AddSetting({ type = LHAS.ST_SECTION, label = "Notification Mode" })
	settings:AddSetting({
		type = LHAS.ST_DROPDOWN,
		label = "Display Alerts As",
		tooltip = "Select how SiegeReminder displays alerts.",
		default = "Chat",
		getFunction = function() return SiegeReminder.SV.reminderType end,
		setFunction = function(_, name) SiegeReminder.SV.reminderType = name end,
		items = {
			{ name = "Chat", data = "Chat" },
			{ name = "Alert", data = "Alert" },
			{ name = "Full Screen", data = "Full Screen" },
		},
	})

	settings:AddSetting({ type = LHAS.ST_SECTION, label = "Bank Automation" })
	settings:AddSetting({
		type = LHAS.ST_CHECKBOX,
		label = "Enable Bank Automation",
		tooltip = "Auto withdraw in AvA and deposit outside AvA when bank opens.",
		default = true,
		getFunction = function() return SiegeReminder.SV.enabledBankAutomation end,
		setFunction = function(val) SiegeReminder.SV.enabledBankAutomation = val end,
	})
	settings:AddSetting({
		type = LHAS.ST_CHECKBOX,
		label = "Deposit Siege Outside AvA",
		tooltip = "When not in Cyrodiil, deposit all siege to bank on open.",
		default = true,
		getFunction = function() return SiegeReminder.SV.depositAllOutsideAvA end,
		setFunction = function(val) SiegeReminder.SV.depositAllOutsideAvA = val end,
	})
	settings:AddSetting({
		type = LHAS.ST_EDIT,
		label = "Move Delay (ms)",
		tooltip = "Delay between each bank move action.",
		default = "700",
		getFunction = function() return tostring(SiegeReminder.SV.bankMoveDelayMs or 700) end,
		setFunction = function(val)
			local v = tonumber(val) or 700
			if v < 200 then v = 200 end
			SiegeReminder.SV.bankMoveDelayMs = v
		end,
	})
	settings:AddSetting({
		type = LHAS.ST_CHECKBOX,
		label = "Enable Bank Debug",
		tooltip = "Print bank automation debug output.",
		default = false,
		getFunction = function() return SiegeReminder.SV.debug end,
		setFunction = function(val) SiegeReminder.SV.debug = val end,
	})

	-- ------------------------------------------------------------
	-- Siege type slider ranges (per type)
	-- ------------------------------------------------------------
	local SIEGE_RANGES = {
		["Battering Ram"] = { minMin = 0,  minMax = 10,  minDef = 3,  maxMin = 1,  maxMax = 10,  maxDef = 10 },
		["Ballista"]      = { minMin = 0,  minMax = 20,  minDef = 3,  maxMin = 1,  maxMax = 20,  maxDef = 20 },
		["Catapult"]      = { minMin = 0,  minMax = 20,  minDef = 3,  maxMin = 1,  maxMax = 20,  maxDef = 20 },
		["Trebuchet"]     = { minMin = 0,  minMax = 20,  minDef = 3,  maxMin = 1,  maxMax = 20,  maxDef = 20 },
		["Flaming Oil"]   = { minMin = 0,  minMax = 20,  minDef = 3,  maxMin = 1,  maxMax = 20,  maxDef = 20 },
		["Forward Camp"]  = { minMin = 0,  minMax = 10,  minDef = 1,  maxMin = 1,  maxMax = 10,  maxDef = 5 },
		["Repair Kit"]    = { minMin = 20, minMax = 100, minDef = 50, maxMin = 50, maxMax = 200, maxDef = 200 },
	}

	local function GetRangeForType(typeName)
		return SIEGE_RANGES[typeName] or { minMin = 0, minMax = 20, minDef = 3, maxMin = 1, maxMax = 20, maxDef = 20 }
	end

	settings:AddSetting({ type = LHAS.ST_SECTION, label = "Carry Levels (per siege type)" })

	for siegeName, data in pairs(SiegeReminder.SV.siegeTypes) do
		local r = GetRangeForType(siegeName)

		settings:AddSetting({
			type = LHAS.ST_SLIDER,
			label = siegeName .. " Carry Min",
			tooltip = "Reminder threshold: warn when carried amount falls below this.",
			min = r.minMin, max = r.minMax, step = 1, format = "%d",
			getFunction = function() return tonumber(SiegeReminder.SV.siegeTypes[siegeName].minCarry) or r.minDef end,
			setFunction = function(val) SiegeReminder.SV.siegeTypes[siegeName].minCarry = tonumber(val) or r.minDef end,
			default = data.minCarry or r.minDef,
		})

		settings:AddSetting({
			type = LHAS.ST_SLIDER,
			label = siegeName .. " Carry Max",
			tooltip = "Cyrodiil bank top-up: withdraw from your bank up to this carried amount.",
			min = r.maxMin, max = r.maxMax, step = 1, format = "%d",
			getFunction = function() return tonumber(SiegeReminder.SV.siegeTypes[siegeName].maxCarry) or r.maxDef end,
			setFunction = function(val) SiegeReminder.SV.siegeTypes[siegeName].maxCarry = tonumber(val) or r.maxDef end,
			default = data.maxCarry or r.maxDef,
		})

		settings:AddSetting({
			type = LHAS.ST_CHECKBOX,
			label = "Enable " .. siegeName .. " Alerts",
			tooltip = "Enable or disable reminders for " .. siegeName .. ".",
			default = (data.enabled ~= false),
			getFunction = function() return SiegeReminder.SV.siegeTypes[siegeName].enabled ~= false end,
			setFunction = function(state) SiegeReminder.SV.siegeTypes[siegeName].enabled = (state == true) end,
		})
	end

	settings:AddSetting({
		type = LHAS.ST_LABEL,
		label = "|cFFD700SiegeReminder|r\nBuilt on tea, toast and ADHD – tested live on PS5.",
	})
end

--------------------------------------------------------------
-- Init
--------------------------------------------------------------
local function OnAddOnLoaded(_, addonName)
	if addonName ~= ADDON_NAME then return end

	local defaults = {
		siegeTypes = {
			["Battering Ram"] = { minCarry = 3, maxCarry = 10, enabled = true },
			["Ballista"] = { minCarry = 3, maxCarry = 20, enabled = true },
			["Catapult"] = { minCarry = 3, maxCarry = 20, enabled = true },
			["Trebuchet"] = { minCarry = 3, maxCarry = 20, enabled = true },
			["Flaming Oil"] = { minCarry = 3, maxCarry = 20, enabled = true },
			["Forward Camp"] = { minCarry = 1, maxCarry = 5, enabled = true },
			["Repair Kit"] = { minCarry = 20, maxCarry = 200, enabled = true },
		},
		reminderType = "Chat",
		debugMode = false,
		enabledBankAutomation = true,
		bankMoveDelayMs = 700,
		depositAllOutsideAvA = true,
		debug = false,
	}

	SiegeReminder = SiegeReminder or {}
	SiegeReminder.SV = ZO_SavedVars:NewAccountWide("SiegeReminder_SV", 1, nil, defaults)
SiegeReminder.SV.siegeTypes = SiegeReminder.SV.siegeTypes or SiegeReminder.SV.siege or {}
local SIEGE_RANGES = {
	["Battering Ram"] = { minMin = 0,  minMax = 10,  minDef = 3,  maxMin = 1,  maxMax = 10,  maxDef = 10 },
	["Ballista"]      = { minMin = 0,  minMax = 20,  minDef = 3,  maxMin = 1,  maxMax = 20,  maxDef = 20 },
	["Catapult"]      = { minMin = 0,  minMax = 20,  minDef = 3,  maxMin = 1,  maxMax = 20,  maxDef = 20 },
	["Trebuchet"]     = { minMin = 0,  minMax = 20,  minDef = 3,  maxMin = 1,  maxMax = 20,  maxDef = 20 },
	["Flaming Oil"]   = { minMin = 0,  minMax = 20,  minDef = 3,  maxMin = 1,  maxMax = 20,  maxDef = 20 },
	["Forward Camp"]  = { minMin = 0,  minMax = 10,  minDef = 1,  maxMin = 1,  maxMax = 10,  maxDef = 5 },
	["Repair Kit"]    = { minMin = 20, minMax = 100, minDef = 50, maxMin = 50, maxMax = 200, maxDef = 200 },
}

local function GetRangeForType(typeName)
	return SIEGE_RANGES[typeName] or { minMin = 0, minMax = 20, minDef = 3, maxMin = 1, maxMax = 20, maxDef = 20 }
end

local function Clamp(v, lo, hi)
	v = tonumber(v)
	if not v then return lo end
	if v < lo then return lo end
	if v > hi then return hi end
	return v
end

for key, data in pairs(SiegeReminder.SV.siegeTypes) do
	local r = GetRangeForType(key)
	data.minCarry = data.minCarry or data.min or r.minDef
	data.maxCarry = data.maxCarry or data.max or r.maxDef
	if data.enabled == nil then data.enabled = true end

	data.minCarry = Clamp(data.minCarry, r.minMin, r.minMax)
	data.maxCarry = Clamp(data.maxCarry, r.maxMin, r.maxMax)

	if data.maxCarry < data.minCarry then
		data.maxCarry = data.minCarry
	end
end
	SiegeReminder.SV.siege = SiegeReminder.SV.siegeTypes

	EM:RegisterForEvent(ADDON_NAME.."_PlayerActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
	EM:RegisterForEvent(ADDON_NAME.."_Zone", EVENT_ZONE_CHANGED, OnZoneChanged)
	EM:RegisterForEvent(ADDON_NAME.."_Inv", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventoryUpdate)
	EM:RegisterForEvent(ADDON_NAME.."_StoreOpen", EVENT_OPEN_STORE, OnStoreOpen)
	EM:RegisterForEvent(ADDON_NAME.."_StoreClose", EVENT_CLOSE_STORE, OnStoreClose)
	EM:RegisterForEvent(ADDON_NAME.."_BankOpen", EVENT_OPEN_BANK, OnBankOpened)
	EM:RegisterForEvent(ADDON_NAME.."_BankClose", EVENT_CLOSE_BANK, OnBankClosed)

	CreateSettingsMenu()
	
	chat("SiegeReminder v1.7.0 active — Siege Marshal online.")
end



EM:RegisterForEvent(ADDON_NAME.."_Loaded", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
