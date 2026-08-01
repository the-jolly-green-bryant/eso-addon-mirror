local MBQ = {}
MBQ.name = "MiatsBattegroundsQueue"
MBQ.version = "0.01"


local function OnActivityFinderStatusUpdate(eventCode, status)
	if not MBQ.doAutoQueue or IsActiveWorldBattleground() or MBQ.delayedActivated then return end

	if status == ACTIVITY_FINDER_STATUS_READY_CHECK and HasLFGReadyCheckNotification() then
		AcceptLFGReadyCheckNotification()
	end
	
	if MBQ.pedingQueueStart and status == ACTIVITY_FINDER_STATUS_QUEUED then
		MBQ.pedingQueueStart = false
		ZO_BattlegroundFinder_KeyboardQueueButton:SetText('Join Queue')
		EVENT_MANAGER:UnregisterForUpdate(MBQ.name)
	end
	
	if status == ACTIVITY_FINDER_STATUS_NONE and not IsCurrentlySearchingForGroup() then
		StartAutoBGQueue()
	end
end

local function OnUpdateQueue()
	if not MBQ.delayedActivated and MBQ.doAutoQueue and not IsActiveWorldBattleground() and not IsCurrentlySearchingForGroup() and GetLFGCooldownTimeRemainingSeconds(6) == 0 then
		StartGroupFinderSearch()
	end
end

function StartAutoBGQueue()
	CancelGroupSearches(true)
	MBQ.doAutoQueue = true
	AddActivityFinderSetSearchEntry(1)
	MBQ.pedingQueueStart = true
	ZO_BattlegroundFinder_KeyboardQueueButton:SetText('Auto Queue Pending')
	EVENT_MANAGER:RegisterForEvent(MBQ.name, EVENT_ACTIVITY_FINDER_STATUS_UPDATE, OnActivityFinderStatusUpdate)
	EVENT_MANAGER:RegisterForUpdate(MBQ.name, 250, OnUpdateQueue)
end

function StopAutoBGQueue()
	MBQ.doAutoQueue = false
	MBQ.pedingQueueStart = false
	if IsCurrentlySearchingForGroup() then
		CancelGroupSearches(true)
	end
	EVENT_MANAGER:UnregisterForEvent(MBQ.name, EVENT_ACTIVITY_FINDER_STATUS_UPDATE)
	EVENT_MANAGER:UnregisterForUpdate(MBQ.name)
	ZO_BattlegroundFinder_KeyboardQueueButton:SetText('Join Queue')
	-- end
end

function IsAutoBGQueueRunning()
	return MBQ.doAutoQueue
end

local function GroupFinderPreHook()
	if ZO_BattlegroundFinder_KeyboardQueueButton:IsHidden() then return false end
	
	if not MBQ.doAutoQueue then 
		StartAutoBGQueue()
		return true
	else
		return false
	end
	
	
end

local function OnPlayerActivated()
	if MBQ.doAutoQueue and IsActiveWorldBattleground() then StopAutoBGQueue() end
	
	if MBQ.doAutoQueue then MBQ.delayedActivated = zo_callLater (function() MBQ.delayedActivated = nil end, 25) end
	
end

local function CancelGroupSearchesPreHook(isThisAddon)
	if not isThisAddon then
		StopAutoBGQueue()
		return true
	else
		return false
	end
end

local function OnLoaded(eventCode, addonName)
	if addonName~=MBQ.name then return end
	EVENT_MANAGER:UnregisterForEvent(MBQ.name, EVENT_ADD_ON_LOADED)

	ZO_PreHook(ZO_ACTIVITY_FINDER_ROOT_MANAGER, 'StartSearch', GroupFinderPreHook)
	ZO_PreHook('CancelGroupSearches', CancelGroupSearchesPreHook)

	EVENT_MANAGER:RegisterForEvent(MBQ.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

EVENT_MANAGER:RegisterForEvent(MBQ.name, EVENT_ADD_ON_LOADED, OnLoaded)