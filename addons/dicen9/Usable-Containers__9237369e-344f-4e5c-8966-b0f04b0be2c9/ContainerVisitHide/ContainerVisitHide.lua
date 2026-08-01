--[[
	ContainerVisitHide
	Companion for HarvestMap (Shinni).

	Problem:
	  HarvestMap's "spawn filter" only works for craft resources (ore, wood, herbs).
	  Containers (chests, heavy sacks, etc.) cannot be detected that way, and the old
	  "hide visited nodes" timer was removed from HarvestMap for performance.

	Solution:
	  When HarvestMap records that you harvested a container node, hide that pin on
	  map / compass / 3D world for a configurable number of minutes, then show it again.
]]

ContainerVisitHide = ContainerVisitHide or {}
local CVH = ContainerVisitHide

CVH.name = "ContainerVisitHide"
CVH.version = "1.0.0"

local DEFAULTS = {
	enabled = true,
	hideMinutes = 10,
	debugChat = false,
	hideChests = true,
	hideHeavySacks = true,
	hideTroves = true,
	hideJustice = true, -- safeboxes / justice containers
	hideStashes = true, -- loose panels / tiles / stones
}

-- Coordinate snap for stable keys across session reloads (meters).
local COORD_PRECISION = 1

local function Log(fmt, ...)
	if not CVH.sv or not CVH.sv.debugChat then return end
	local msg = zo_strformat(fmt, ...)
	CHAT_ROUTER:AddSystemMessage(string.format("|c88CCFF[CVH]|r %s", msg))
end

local function RoundCoord(v)
	return zo_floor((v or 0) / COORD_PRECISION + 0.5) * COORD_PRECISION
end

local function MakeKey(map, pinTypeId, worldX, worldY)
	return string.format("%s|%d|%d|%d", map or "?", pinTypeId or 0, RoundCoord(worldX), RoundCoord(worldY))
end

---------------------------------------------------------------------------
-- Container pin types (resolved after HarvestMap loads)
---------------------------------------------------------------------------

function CVH:BuildContainerTypes()
	self.containerTypes = {}
	if not Harvest then return end

	local map = {
		{ Harvest.CHESTS, "hideChests" },
		{ Harvest.HEAVYSACK, "hideHeavySacks" },
		{ Harvest.TROVE, "hideTroves" },
		{ Harvest.JUSTICE, "hideJustice" },
		{ Harvest.STASH, "hideStashes" },
	}

	for _, entry in ipairs(map) do
		local pinTypeId, settingKey = entry[1], entry[2]
		if pinTypeId then
			self.containerTypes[pinTypeId] = settingKey
		end
	end
end

function CVH:IsContainerPinType(pinTypeId)
	local settingKey = self.containerTypes and self.containerTypes[pinTypeId]
	if not settingKey then return false end
	return self.sv[settingKey] == true
end

---------------------------------------------------------------------------
-- Hidden-node store
---------------------------------------------------------------------------

function CVH:CleanupExpired()
	if not self.sv or not self.sv.hidden then return end
	local now = GetTimeStamp()
	local removed = 0
	for key, untilTs in pairs(self.sv.hidden) do
		if type(untilTs) ~= "number" or untilTs <= now then
			self.sv.hidden[key] = nil
			removed = removed + 1
		end
	end
	if removed > 0 then
		Log("Cleaned <<1>> expired hide entries", removed)
	end
end

function CVH:GetHideKey(mapCache, nodeId)
	if not mapCache or not nodeId then return nil end
	local pinTypeId = mapCache.pinTypeId[nodeId]
	if not pinTypeId then return nil end
	return MakeKey(mapCache.map, pinTypeId, mapCache.worldX[nodeId], mapCache.worldY[nodeId])
end

function CVH:IsNodeHidden(mapCache, nodeId)
	if not self.sv or not self.sv.enabled then return false end
	if not mapCache or not nodeId then return false end

	local pinTypeId = mapCache.pinTypeId[nodeId]
	if not self:IsContainerPinType(pinTypeId) then return false end

	local key = self:GetHideKey(mapCache, nodeId)
	if not key then return false end

	local untilTs = self.sv.hidden[key]
	if not untilTs then return false end

	if untilTs <= GetTimeStamp() then
		self.sv.hidden[key] = nil
		return false
	end
	return true
end

function CVH:HideNode(mapCache, nodeId)
	if not self.sv or not self.sv.enabled then return end
	if not mapCache or not nodeId then return end

	local pinTypeId = mapCache.pinTypeId[nodeId]
	if not self:IsContainerPinType(pinTypeId) then return end

	local key = self:GetHideKey(mapCache, nodeId)
	if not key then return end

	local minutes = zo_max(1, zo_min(120, self.sv.hideMinutes or DEFAULTS.hideMinutes))
	local untilTs = GetTimeStamp() + (minutes * 60)
	self.sv.hidden[key] = untilTs

	Log("Hiding pinType <<1>> node <<2>> for <<3>> min (map <<4>>)",
		pinTypeId, nodeId, minutes, mapCache.map or "?")

	self:RemoveVisiblePins(mapCache, nodeId, pinTypeId)

	-- Optional: notify HarvestMap listeners (event exists but is unused in stock HM)
	if Harvest and Harvest.callbackManager and Harvest.events and Harvest.events.CHANGED_NODE_HIDDEN_STATE then
		Harvest.callbackManager:FireCallbacks(Harvest.events.CHANGED_NODE_HIDDEN_STATE, mapCache, nodeId, true)
	end
end

function CVH:RemoveVisiblePins(mapCache, nodeId, pinTypeId)
	-- Map pins
	if Harvest and Harvest.pinController and Harvest.pinController.RemovePinForNodeId then
		pcall(function()
			Harvest.pinController:RemovePinForNodeId(pinTypeId, nodeId)
		end)
	end

	-- Compass / 3D world pins
	local inRange = Harvest and Harvest.InRangePins
	if inRange and mapCache and mapCache.map then
		local map = mapCache.map
		if inRange.compassKeys and inRange.compassKeys[map] then
			local key = inRange.compassKeys[map][nodeId]
			if key and inRange.compassControlPool then
				inRange.compassControlPool:ReleaseObject(key)
				inRange.compassKeys[map][nodeId] = nil
			end
		end
		if inRange.worldKeys and inRange.worldKeys[map] then
			local key = inRange.worldKeys[map][nodeId]
			if key and inRange.worldControlPool then
				inRange.worldControlPool:ReleaseObject(key)
				inRange.worldKeys[map][nodeId] = nil
			end
		end
		if inRange.lastUpdate and inRange.lastUpdate[map] then
			inRange.lastUpdate[map][nodeId] = nil
		end
	end
end

---------------------------------------------------------------------------
-- Hooks into HarvestMap pin drawing
---------------------------------------------------------------------------

function CVH:InstallHooks()
	if self.hooksInstalled then return end
	if not Harvest then return end

	-- Map pins: skip creation while hidden
	if Harvest.pinController and Harvest.pinController.CreatePinForNodeId then
		ZO_PreHook(Harvest.pinController, "CreatePinForNodeId", function(pinController, pinTypeId, nodeId)
			local mapCache = nil
			local managers = pinController.pinTypeManagers
			if managers and managers[pinTypeId] then
				mapCache = managers[pinTypeId].mapCache
			end
			if not mapCache and Harvest.mapPins then
				mapCache = Harvest.mapPins.mapCache
			end
			if mapCache and CVH:IsNodeHidden(mapCache, nodeId) then
				return true -- abort original
			end
		end)
	end

	-- Compass / 3D: skip update while hidden; drop existing controls
	if Harvest.InRangePins and Harvest.InRangePins.UpdatePin then
		ZO_PreHook(Harvest.InRangePins, "UpdatePin", function(self, mapCache, nodeId, lastUpdate, compassKeys, worldKeys)
			if not CVH:IsNodeHidden(mapCache, nodeId) then return end

			if lastUpdate then
				lastUpdate[nodeId] = nil
			end
			if compassKeys and compassKeys[nodeId] and self.compassControlPool then
				self.compassControlPool:ReleaseObject(compassKeys[nodeId])
				compassKeys[nodeId] = nil
			end
			if worldKeys and worldKeys[nodeId] and self.worldControlPool then
				self.worldControlPool:ReleaseObject(worldKeys[nodeId])
				worldKeys[nodeId] = nil
			end
			return true -- abort original
		end)
	end

	-- When HarvestMap records a harvest (loot / lockpick start for chests)
	if Harvest.callbackManager and Harvest.events and Harvest.events.NODE_HARVESTED then
		Harvest.callbackManager:RegisterCallback(Harvest.events.NODE_HARVESTED, function(event, mapCache, nodeId)
			CVH:HideNode(mapCache, nodeId)
		end)
	else
		d("[ContainerVisitHide] Could not register NODE_HARVESTED — is HarvestMap fully loaded?")
	end

	self.hooksInstalled = true
	Log("Hooks installed on HarvestMap")
end

---------------------------------------------------------------------------
-- Periodic refresh: when timers expire, redraw map pins
---------------------------------------------------------------------------

function CVH:OnTick()
	if not self.sv or not self.sv.enabled then return end
	if not self.sv.hidden then return end

	local now = GetTimeStamp()
	local anyExpired = false
	for key, untilTs in pairs(self.sv.hidden) do
		if type(untilTs) ~= "number" or untilTs <= now then
			self.sv.hidden[key] = nil
			anyExpired = true
		end
	end

	if anyExpired and Harvest and Harvest.mapPins and Harvest.mapPins.RedrawPins then
		Harvest.mapPins:RedrawPins()
		Log("Respawn timers expired — map pins redrawn")
	end
end

---------------------------------------------------------------------------
-- Settings (LibAddonMenu if present; slash commands always)
---------------------------------------------------------------------------

function CVH:RegisterSettings()
	local LAM = LibAddonMenu2
	if not LAM then
		Log("LibAddonMenu-2.0 not found; use /cvh for settings")
		return
	end

	local panelData = {
		type = "panel",
		name = "Container Visit Hide",
		displayName = "Container Visit Hide",
		author = "Community",
		version = CVH.version,
		registerForRefresh = true,
		registerForDefaults = true,
	}

	local options = {
		{
			type = "description",
			text = "Hides HarvestMap container pins after you loot them (chests, heavy sacks, thieves troves, safeboxes, stashes). Resource nodes (ore/wood/herbs) are left to HarvestMap's spawn filter.",
		},
		{
			type = "checkbox",
			name = "Enable",
			getFunc = function() return CVH.sv.enabled end,
			setFunc = function(v) CVH.sv.enabled = v end,
			default = DEFAULTS.enabled,
		},
		{
			type = "slider",
			name = "Hide duration (minutes)",
			tooltip = "How long to hide a container pin after you loot it. Match roughly to expected respawn time.",
			min = 1,
			max = 60,
			step = 1,
			getFunc = function() return CVH.sv.hideMinutes end,
			setFunc = function(v) CVH.sv.hideMinutes = v end,
			default = DEFAULTS.hideMinutes,
		},
		{
			type = "checkbox",
			name = "Hide chests",
			getFunc = function() return CVH.sv.hideChests end,
			setFunc = function(v) CVH.sv.hideChests = v end,
			default = DEFAULTS.hideChests,
		},
		{
			type = "checkbox",
			name = "Hide heavy sacks",
			getFunc = function() return CVH.sv.hideHeavySacks end,
			setFunc = function(v) CVH.sv.hideHeavySacks = v end,
			default = DEFAULTS.hideHeavySacks,
		},
		{
			type = "checkbox",
			name = "Hide thieves troves",
			getFunc = function() return CVH.sv.hideTroves end,
			setFunc = function(v) CVH.sv.hideTroves = v end,
			default = DEFAULTS.hideTroves,
		},
		{
			type = "checkbox",
			name = "Hide safeboxes (justice)",
			getFunc = function() return CVH.sv.hideJustice end,
			setFunc = function(v) CVH.sv.hideJustice = v end,
			default = DEFAULTS.hideJustice,
		},
		{
			type = "checkbox",
			name = "Hide stashes (loose panels/tiles)",
			getFunc = function() return CVH.sv.hideStashes end,
			setFunc = function(v) CVH.sv.hideStashes = v end,
			default = DEFAULTS.hideStashes,
		},
		{
			type = "checkbox",
			name = "Debug chat messages",
			getFunc = function() return CVH.sv.debugChat end,
			setFunc = function(v) CVH.sv.debugChat = v end,
			default = DEFAULTS.debugChat,
		},
		{
			type = "button",
			name = "Clear all hidden pins",
			func = function()
				CVH.sv.hidden = {}
				if Harvest and Harvest.mapPins and Harvest.mapPins.RedrawPins then
					Harvest.mapPins:RedrawPins()
				end
				d("|c88CCFF[ContainerVisitHide]|r Cleared all temporary hides.")
			end,
			width = "full",
		},
	}

	LAM:RegisterAddonPanel("ContainerVisitHidePanel", panelData)
	LAM:RegisterOptionControls("ContainerVisitHidePanel", options)
end

function CVH:RegisterSlashCommands()
	SLASH_COMMANDS["/cvh"] = function(args)
		args = zo_strtrim(args or "")
		local cmd, rest = args:match("^(%S+)%s*(.*)$")
		cmd = cmd and zo_strlower(cmd) or "help"

		if cmd == "help" or cmd == "" then
			d("|c88CCFFContainerVisitHide|r commands:")
			d("  /cvh on | off  — enable/disable")
			d("  /cvh time <minutes>  — hide duration (1-60)")
			d("  /cvh clear  — show all hidden pins again")
			d("  /cvh status  — print current settings")
			d("  /cvh debug  — toggle debug chat")
			return
		end

		if cmd == "on" then
			self.sv.enabled = true
			d("|c88CCFF[CVH]|r Enabled")
		elseif cmd == "off" then
			self.sv.enabled = false
			d("|c88CCFF[CVH]|r Disabled")
		elseif cmd == "time" then
			local n = tonumber(rest)
			if not n then
				d("|c88CCFF[CVH]|r Usage: /cvh time 10")
				return
			end
			self.sv.hideMinutes = zo_max(1, zo_min(60, zo_floor(n)))
			d(string.format("|c88CCFF[CVH]|r Hide duration: %d minutes", self.sv.hideMinutes))
		elseif cmd == "clear" then
			self.sv.hidden = {}
			if Harvest and Harvest.mapPins and Harvest.mapPins.RedrawPins then
				Harvest.mapPins:RedrawPins()
			end
			d("|c88CCFF[CVH]|r Cleared all temporary hides")
		elseif cmd == "status" then
			local count = 0
			for _ in pairs(self.sv.hidden or {}) do count = count + 1 end
			d(string.format("|c88CCFF[CVH]|r enabled=%s minutes=%d hidden=%d",
				tostring(self.sv.enabled), self.sv.hideMinutes, count))
		elseif cmd == "debug" then
			self.sv.debugChat = not self.sv.debugChat
			d(string.format("|c88CCFF[CVH]|r debug=%s", tostring(self.sv.debugChat)))
		else
			d("|c88CCFF[CVH]|r Unknown command. Try /cvh help")
		end
	end
end

---------------------------------------------------------------------------
-- Init
---------------------------------------------------------------------------

function CVH:Initialize()
	self.sv = ZO_SavedVars:NewAccountWide("ContainerVisitHide_SavedVars", 1, nil, {
		enabled = DEFAULTS.enabled,
		hideMinutes = DEFAULTS.hideMinutes,
		debugChat = DEFAULTS.debugChat,
		hideChests = DEFAULTS.hideChests,
		hideHeavySacks = DEFAULTS.hideHeavySacks,
		hideTroves = DEFAULTS.hideTroves,
		hideJustice = DEFAULTS.hideJustice,
		hideStashes = DEFAULTS.hideStashes,
		hidden = {},
	})

	if type(self.sv.hidden) ~= "table" then
		self.sv.hidden = {}
	end

	self:BuildContainerTypes()
	self:CleanupExpired()
	self:InstallHooks()
	self:RegisterSettings()
	self:RegisterSlashCommands()

	-- Check expired hides every 30s and redraw map if needed
	EVENT_MANAGER:RegisterForUpdate(self.name .. "Tick", 30000, function()
		CVH:OnTick()
	end)

	d(string.format("|c88CCFF[ContainerVisitHide]|r v%s loaded. Settings: ESC → Add-Ons → Container Visit Hide (or /cvh help)", self.version))
end

local function OnAddOnLoaded(event, addonName)
	if addonName ~= CVH.name then return end
	EVENT_MANAGER:UnregisterForEvent(CVH.name, EVENT_ADD_ON_LOADED)

	-- HarvestMap should already be present due to DependsOn; still guard.
	if not Harvest then
		d("|cFF6666[ContainerVisitHide]|r HarvestMap not found. Enable HarvestMap first.")
		return
	end

	CVH:Initialize()
end

EVENT_MANAGER:RegisterForEvent(CVH.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
