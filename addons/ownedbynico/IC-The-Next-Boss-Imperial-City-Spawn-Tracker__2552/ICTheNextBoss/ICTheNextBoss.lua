ICT = ICT or {
	name = "ICTheNextBoss",
	version = "1.3.0",
	running = false,
	spawntime = 900, --Respawn after 15 minutes
	spawntimeMolag = 300, --Respawn after 5 minutes
	fallbackMaxTime = 60
}

-- Returns the colour + clock text for a district given its stored respawn
-- timestamp:
--   blue  = never killed / reset (no data)
--   red   = killed, still on respawn cooldown
--   green = we killed it and it has respawned (up again)
-- Returns: markup colour, clock text, and r,g,b (0-1) for the accent bar/icon.
function ICT.statusInfo(respawn)
	if respawn == nil or respawn == 0 then
		return "|c3399FF", "--:--", 0.20, 0.60, 1.00 -- blue
	end
	local remaining = respawn - os.time()
	if remaining > 0 then
		return "|cFF0000", ICT.secondsToClock(remaining), 1.00, 0.20, 0.20 -- red
	end
	return "|c00FF00", "00:00", 0.30, 1.00, 0.30 -- green
end

-- Picks the most useful district to show in reduced mode: a boss that's already
-- up (go now) if any, otherwise the one respawning soonest. Districts with no
-- recorded timer (blue) are ignored. Returns nil if there's nothing to show.
function ICT.getNextDistrict()
	local soonestName, soonestRemaining = nil, nil
	local upName = nil
	for i = 0, 6 do
		local name = GetString(ICT.datas[i])
		local respawn = ICT.timetable[name]
		if respawn and respawn ~= 0 then
			local remaining = respawn - os.time()
			if remaining <= 0 then
				upName = upName or name
			elseif soonestRemaining == nil or remaining < soonestRemaining then
				soonestRemaining = remaining
				soonestName = name
			end
		end
	end
	return upName or soonestName
end

function ICT.updateTimers()
	-- Follow campaign changes every tick. The campaign id can lag behind the
	-- zone-change event, so checking here (cheap + idempotent) guarantees we
	-- re-bind to the correct campaign within ~1s instead of saving one
	-- campaign's timers into another's bucket.
	ICT.bindCampaignAndRestore()
	if ICT.restored ~= true then return end -- mid-rebind / campaign not ready

	for boss, lastSeen in pairs(ICT.fallbackTimes) do
		if ICT.fallbackTimes[boss] > 0 then
			ICT.fallbackTimes[boss] = lastSeen - 1
		end
	end

	-- Map labels always reflect every district. The HUD shows either all rows
	-- (full mode) or only the next district (reduced mode). No reordering.
	local reduced = ICT.savedVariables.reduced == true
	for i = 0, 6 do
		local districtName = GetString(ICT.datas[i])
		local color, clock, r, g, b = ICT.statusInfo(ICT.timetable[districtName])

		if ICT.savedVariables.maptimers == true and ICT.ui.districts[districtName] then
			ICT.ui.districts[districtName]:SetText(color .. clock)
		end

		if not reduced and ICT.ui.rows then
			local row = ICT.ui.rows[districtName]
			if row then
				ICT.paintRow(row, districtName, color, clock, r, g, b)
			end
		end
	end

	if reduced then
		ICT.updateNextRow()
	end

	ICT.refreshAlpha() -- safety net in case a mouse enter/exit was missed
	ICT.pruneRowButtons() -- hide any hover buttons left stuck after a missed exit
	ICT.saveTimers()
end

function ICT.onMonsterDeath(_, unitTag, isDead)
	local mobName = GetUnitName(unitTag)
	if isDead == true then
		ICT.unitDead(mobName)
	end
end

function ICT.onMonsterReticle(_)
	local unitName = GetUnitNameHighlightedByReticle()
	local isDead = IsUnitDead('reticleover')
	if unitName == nil or unitName == "" then return end
	
	if ICT.savedVariables.chatdebug == true then
		local link = "|H1:icdebug:" .. unitName .. "|h[" .. unitName .. "]|h"
		d(link)
	end
	
	-- Guard against the fallbackTimes / locations / timetable key sets drifting
	-- out of sync (e.g. a boss added to one table but not another): never index
	-- with a nil district or subtract from a nil timer.
	local district = ICT.locations[unitName]
	if ICT.fallbackTimes[unitName] == nil or district == nil then return end
	local respawn = ICT.timetable[district]
	if respawn ~= nil and (respawn - os.time()) > 0 then return end

	if isDead == true then
		if ICT.fallbackTimes[unitName] > 0 then
			ICT.unitDead(unitName)
		end
	else
		ICT.fallbackTimes[unitName] = ICT.fallbackMaxTime
	end
end

function ICT.unitDead(unitName)
	if ICT.locations[unitName] ~= nil then
		local district = ICT.locations[unitName]
		if unitName == GetString(SI_ICTHENEXTBOSS_MOLAG) then 
			ICT.startTimer(district, ICT.spawntimeMolag, true)
		else
			ICT.startTimer(district, ICT.spawntime, true)
		end
		ICT.fallbackTimes[unitName] = 0
		if ICT.savedVariables.chatdebug == true then
			d(unitName .. " died. (in the last " .. ICT.fallbackMaxTime .. "s)")
		end
	end
end

-- Timers are stored per campaign id, because the CP and no-CP Imperial City
-- campaigns are separate instances with independent boss spawns. A campaign id
-- of 0 means we are not in a campaign (e.g. inside an IC DLC dungeon, or the
-- value simply isn't ready yet right after a zone load) -- in that case we never
-- read or write, so unrelated zones can no longer wipe the saved timers.
function ICT.getTimerBucket(create)
	local campaignId = GetCurrentCampaignId()
	if campaignId == nil or campaignId == 0 then return nil end
	local buckets = ICT.savedVariables.saved_timers
	if buckets[campaignId] == nil then
		if not create then return nil end
		buckets[campaignId] = {}
	end
	return buckets[campaignId]
end

function ICT.clearTimetable()
	for i = 0,6,1 do
		ICT.timetable[GetString(ICT.datas[i])] = 0
	end
end

function ICT.saveTimers()
	-- Never persist until a successful restore has run. This prevents the 1s
	-- update loop from writing a freshly-cleared (all-zero) timetable over good
	-- saved data during the window after entering IC but before the campaign id
	-- is assigned and restoreTimers() has executed.
	if ICT.restored ~= true then return end
	local bucket = ICT.getTimerBucket(true)
	if bucket == nil then return end
	for i = 0,6,1 do
		local district = GetString(ICT.datas[i])
		bucket[district] = ICT.timetable[district]
	end
end

function ICT.restoreTimers()
	local bucket = ICT.getTimerBucket(false)
	if bucket == nil then return end
	for i = 0,6,1 do
		local district = GetString(ICT.datas[i])
		local respawn = bucket[district]
		if respawn and respawn > os.time() then
			ICT.timetable[district] = respawn
		end
	end
end

-- Bind the in-memory timetable to the current campaign's saved bucket, restoring
-- its timers. This must run not only when first entering IC, but every time the
-- campaign changes -- e.g. travelling directly from no-CP IC to CP IC keeps
-- running == true, so without re-binding the previous campaign's timers would
-- stay on screen (and get saved into the new campaign's bucket). The campaign id
-- can momentarily read 0 right after a zone load, so we retry until it resolves.
function ICT.bindCampaignAndRestore()
	if ICT.running ~= true then return end
	local campaignId = GetCurrentCampaignId()

	-- Already bound to this campaign and restored: nothing to do.
	if campaignId ~= 0 and ICT.boundCampaign == campaignId and ICT.restored == true then
		return
	end

	-- Not correctly bound yet: block saves so the update loop can't write the
	-- stale/cleared timetable into a bucket while we resolve the campaign.
	ICT.restored = false

	if campaignId == 0 then
		if ICT.savedVariables.chatdebug == true then d("[ICT] campaign id not ready, retrying restore...") end
		zo_callLater(ICT.bindCampaignAndRestore, 500)
		return
	end

	ICT.clearTimetable()
	ICT.restoreTimers()
	ICT.boundCampaign = campaignId
	ICT.restored = true -- saves are now allowed
	if ICT.savedVariables.chatdebug == true then d("[ICT] bound + restored timers for campaign " .. tostring(campaignId)) end
end

-- One-time migration from the old single-slot format
-- (saved_timers[district] + saved_timers["data"] = campaignId) to the new
-- per-campaign format (saved_timers[campaignId][district]).
function ICT.migrateSavedTimers()
	local st = ICT.savedVariables.saved_timers
	if st == nil then
		ICT.savedVariables.saved_timers = {}
		return
	end
	if st["data"] == nil then return end -- already migrated or fresh install
	local oldCampaign = st["data"]
	st["data"] = nil
	local bucket = {}
	for i = 0,6,1 do
		local district = GetString(ICT.datas[i])
		if st[district] ~= nil then
			bucket[district] = st[district]
			st[district] = nil
		end
	end
	if oldCampaign and oldCampaign ~= 0 then
		st[oldCampaign] = bucket
	end
end

SLASH_COMMANDS["/ictnb"] = function (arg)
	if arg == "reset" then
		ICT.savedVariables.saved_timers = {}
		ICT.boundCampaign = nil
		ICT.clearTimetable()
		d("[ICT] all saved timers cleared")
		return
	end
	local districtId = tonumber(arg)
	if districtId == nil then
		ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "Error")
		return
	end
	ICT.markDistrict(districtId)
end

function ICT.markDistrict(districtId)
	local district = ICT.datas[districtId]
	if district == nil then return end
	ICT.markDead(district)
end

function ICT.getDistrictID(district)
	local districtId = 0
	for index = 0,6,1 do 
		local districtString = ICT.datas[index]
		if district == GetString(districtString) then 
			districtId = index
		end
	end
	return districtId
end

function ICT.markDead(districtString)
	local district = GetString(districtString)
	if ICT.savedVariables.chatdebug == true then d(district) end
	if ICT.timetable[district] ~= nil then
		if districtString == SI_ICTHENEXTBOSS_CAN then
			ICT.startTimer(district, ICT.spawntimeMolag, true)
		else
			ICT.startTimer(district, ICT.spawntime, true)
		end
	end
end

function ICT.startTimer(district, spawntime, share)
	ICT.timetable[district] = os.time() + spawntime
	if share == true then
		ICT.shareKill(district) -- broadcast the actual remaining time
	end
end

-- Clear a single district's timer (used by the per-row reset buttons). Setting
-- the in-memory value to 0 makes it blue again; the save loop persists it.
function ICT.resetDistrict(district)
	if district == nil then return end
	ICT.timetable[district] = 0
	local bucket = ICT.getTimerBucket(false)
	if bucket then bucket[district] = nil end
end

function ICT.onZoneChange(_, _)
	local zone, x, y, z = GetUnitWorldPosition("player")

	if ICT.savedVariables and ICT.savedVariables.chatdebug == true then
		local cid = GetCurrentCampaignId()
		local rid = (type(GetCampaignRulesetId) == "function") and GetCampaignRulesetId(cid) or "n/a"
		local rtype = (type(GetCampaignRulesetType) == "function" and type(rid) == "number") and GetCampaignRulesetType(rid) or "n/a"
		d("[ICT] zone=" .. tostring(zone) ..
		  " campaign=" .. tostring(cid) ..
		  " ruleset=" .. tostring(rid) ..
		  " rtype=" .. tostring(rtype) ..
		  " running=" .. tostring(ICT.running))
	end

	if zone == 584 or zone == 643 then
		if ICT.running == false then
			-- Player joined IC
			ICT.enable()
		else
			-- Already in IC, but the campaign may have changed (e.g. travelled
			-- straight from no-CP IC to CP IC). Re-bind to the current campaign.
			ICT.showTimetable()
			ICT.bindCampaignAndRestore()
		end
	else
		ICT.disable()
	end
end

function ICT.editSpawnTime()
	if ICT.savedVariables.eventtimers == true then
		ICT.spawntime = 420
	else
		ICT.spawntime = 900
	end
end

function ICT.enable()
	EVENT_MANAGER:RegisterForEvent(ICT.name, EVENT_UNIT_DEATH_STATE_CHANGED, ICT.onMonsterDeath)
	EVENT_MANAGER:RegisterForEvent(ICT.name, EVENT_RETICLE_TARGET_CHANGED, ICT.onMonsterReticle)
	EVENT_MANAGER:RegisterForEvent(ICT.name, EVENT_PLAYER_COMBAT_STATE, ICT.onCombatState)
	EVENT_MANAGER:RegisterForUpdate(ICT.name .. "_loop", 1000, ICT.updateTimers)
	EVENT_MANAGER:RegisterForUpdate(ICT.name .. "_move", 100, ICT.checkMovement)
	ICT.inCombat = IsUnitInCombat("player")
	ICT.isMoving = false
	ICT.applyDisplayMode()
	ICT.showTimetable()
	ICT.restored = false -- block saves until bindCampaignAndRestore() succeeds
	ICT.boundCampaign = nil -- force a fresh bind/restore
	ICT.clearTimetable()
	ICT.running = true
	ICT.bindCampaignAndRestore()
end

function ICT.disable()
	local zone, x, y, z = GetUnitWorldPosition("player")
	if zone ~= 181 then	EVENT_MANAGER:UnregisterForUpdate(ICT.name .. "_loop") end -- Cyrodiil escape ;D
	EVENT_MANAGER:UnregisterForEvent(ICT.name, EVENT_UNIT_DEATH_STATE_CHANGED)
	EVENT_MANAGER:UnregisterForEvent(ICT.name, EVENT_RETICLE_TARGET_CHANGED)
	EVENT_MANAGER:UnregisterForEvent(ICT.name, EVENT_PLAYER_COMBAT_STATE)
	EVENT_MANAGER:UnregisterForUpdate(ICT.name .. "_move")
	ICTTimeTable:SetHidden(true)
	HUD_SCENE:RemoveFragment(ICT.ui.timetable)
	HUD_UI_SCENE:RemoveFragment(ICT.ui.timetable)
	ICT.running = false
end

function ICT.showTimetable()
	if ICT.savedVariables.timetable == true then
		HUD_SCENE:AddFragment(ICT.ui.timetable)
		HUD_UI_SCENE:AddFragment(ICT.ui.timetable)
	end
	ICT.updateBox(true)
end

function ICT.HandleClickEvent(rawLink, mouseButton, linkText, linkStyle, linkType, data)
	-- icdebug links are only ever produced by us while debug mode is on. Ignore
	-- them otherwise, so a crafted icdebug link pasted into chat by someone else
	-- can't pop open the local chat entry pre-filled with their text.
	if linkType == "icdebug" and ICT.savedVariables and ICT.savedVariables.chatdebug == true then
		CHAT_SYSTEM.textEntry:Open(data)
		return true
	end
end

-- Broadcast a district's current remaining respawn time to the group. Sending
-- the remaining seconds (not just "it died now") keeps every receiver's
-- countdown in sync with the killer's. Send() only does anything while grouped.
-- Any group member may share their own kills: the "later respawn wins" merge on
-- the receiving end dedups duplicate kills, so there is no need to elect a single
-- broadcaster (and doing so used to silently drop every non-leader's kills).
function ICT.shareKill(district)
	if ICT.protocol == nil then return end
	local districtId = ICT.getDistrictID(district)
	local remaining = (ICT.timetable[district] or 0) - os.time()
	if remaining < 0 then remaining = 0 end
	if remaining > 900 then remaining = 900 end
	ICT.protocol:Send({
		districtId = districtId,
		remaining = remaining,
	})
end

-- LibGroupBroadcast delivers (unitTag, data); data holds our declared fields.
-- Shared timers come from other players, so treat them as untrusted: only adopt
-- them while we are actively tracking IC (so stray data can't seed timers in
-- unrelated zones/campaigns), and defensively re-clamp the value even though the
-- protocol already bounds it.
function ICT.onShareReceived(unitTag, data)
	if ICT.running ~= true or ICT.restored ~= true then return end
	if data == nil or data.districtId == nil then return end
	local key = ICT.datas[data.districtId]
	if key == nil then return end
	local remaining = data.remaining or 0
	if remaining < 0 then remaining = 0 end
	if remaining > 900 then remaining = 900 end
	local district = GetString(key)
	local newRespawn = os.time() + remaining
	-- Adopt the later respawn so a fresher local/remote kill is never overwritten
	-- by older shared data.
	if (ICT.timetable[district] or 0) < newRespawn then
		ICT.timetable[district] = newRespawn
	end
end

function ICT.OnAddOnLoaded(event, addonName)
	if addonName ~= ICT.name then return end
	
	EVENT_MANAGER:RegisterForEvent(ICT.name, EVENT_PLAYER_ACTIVATED, ICT.onZoneChange)
	
	LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, ICT.HandleClickEvent)
	LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_CLICKED_EVENT, ICT.HandleClickEvent)
	
	ICT.initializeSettingsMenu()
	ICT.migrateSavedTimers()
	ICT.buildRows()
	ICT.initSceneVisibility()
	ICT.restoreUIPosition()
	ICT.onMapOpen()
	ICT.disableMapMouseWheelZoom()
	ICTMapTimers:SetDrawTier(DT_HIGH) --Draw above WorldMap
	
	if LibGroupBroadcast ~= nil then
		-- Group sharing is optional. Register it defensively so that a future
		-- LibGroupBroadcast API change can only disable sharing, never abort the
		-- whole addon load (leaving ICT.protocol nil makes shareKill a no-op).
		local ok, err = pcall(function()
			local handler = LibGroupBroadcast:RegisterHandler("ICTdataShare")
			handler:SetDisplayName("IC The Next Boss")
			handler:SetDescription("Shares boss respawn timers with your group")
			-- LibGroupBroadcast serializes the protocol id in 9 bits, so it MUST be
			-- 0-511 (4135 overflowed -> "Value is too large for 9 bits" on Send).
			-- Ids 1-10 are reserved by the library's control messages. This id must
			-- be unique across all LGB addons -- register it on the LibGroupBroadcast
			-- protocol-id list before any public release.
			local protocol = handler:DeclareProtocol(415, "ICTShareProtocol")
			protocol:AddField(LibGroupBroadcast.CreateNumericField("districtId", {
				minValue = 0,
				maxValue = 6,
			}))
			protocol:AddField(LibGroupBroadcast.CreateNumericField("remaining", {
				minValue = 0,
				maxValue = 900,
			}))
			protocol:OnData(ICT.onShareReceived)
			if not protocol:Finalize({
				isRelevantInCombat = false,
				replaceQueuedMessages = false
			}) then
				error("finalize returned false")
			end
			ICT.handler = handler
			ICT.protocol = protocol
		end)
		if not ok then
			ICT.handler = nil
			ICT.protocol = nil
			d("[ICT] group sharing disabled (LibGroupBroadcast setup failed: " .. tostring(err) .. ")")
		end
	end
	
	ICT.editSpawnTime()
	
	ICT.running = false
end

EVENT_MANAGER:RegisterForEvent(ICT.name, EVENT_ADD_ON_LOADED, ICT.OnAddOnLoaded)