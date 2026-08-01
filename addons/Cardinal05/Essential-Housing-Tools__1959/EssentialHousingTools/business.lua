if not EHT then EHT = { } end
if not EHT.Biz then EHT.Biz = { } end

local RAD45, RAD90, RAD180, RAD270, RAD360 = math.rad( 45 ), math.rad( 90 ), math.rad( 180 ), math.rad( 270 ), math.rad( 360 )
local ceil, floor, min, max, cos, sin, rad, deg = math.ceil, math.floor, math.min, math.max, math.cos, math.sin, math.rad, math.deg
local round = function( n, d ) if nil == d then return zo_roundToZero( n ) else return zo_roundToNearest( n, 1 / ( 10 ^ d ) ) end end
math.roundIntLarger = function( n ) return 0 <= n and math.ceil( n ) or math.floor( n ) end
math.roundIntSmaller = function( n ) return 0 <= n and math.floor( n ) or math.ceil( n ) end

EHT.SnapFurnitureCallbackId = nil
EHT.PendingFurnitureOperations =
{
	[EHT.CONST.MOVE_OP] = 0,
	[EHT.CONST.PLACE_OP] = 0,
	[EHT.CONST.REMOVE_OP] = 0,
	[EHT.CONST.MOVE_PATH_NODE_OP] = 0,
	[EHT.CONST.PLACE_PATH_NODE_OP] = 0,
	[EHT.CONST.REMOVE_PATH_NODE_OP] = 0,
}
local OPERATION_NAMES =
{
	[EHT.CONST.MOVE_OP] = "Move",
	[EHT.CONST.PLACE_OP] = "Place",
	[EHT.CONST.REMOVE_OP] = "Remove",
	[EHT.CONST.MOVE_PATH_NODE_OP] = "Move Path Node",
	[EHT.CONST.PLACE_PATH_NODE_OP] = "Place Path Node",
	[EHT.CONST.REMOVE_PATH_NODE_OP] = "Remove Path Node",
}
local PENDING_FURNITURE_OPS_THRESHOLD = 10

local BACKUP_FIELDS =
{
	"Id",
	"ItemId",
	"X",
	"Y",
	"Z",
	"Pitch",
	"Yaw",
	"Roll",
	"EffectType",
	"SizeX",
	"SizeY",
	"SizeZ",
	"Color",
	"Alpha",
	"MetaData",
	"Groups",
	"Contrast",
	"Speed",
	"DelayTime",
}

---[ Operations : Process Management ]---

function EHT.Biz.CallLater( func, delay, funcName )
	if nil == func then return end
	if nil == delay or 1 > delay then
		delay = 1
	end

	if EHT.DEBUG_MODE then
		local caller = EHT.Util.GetCallerFunctionName()
		df( "[%.3f] %s queued '%s' in %.3fs", GetGameTimeMilliseconds() / 1000, caller or "(anonymous)", funcName or "(anonymous)", delay / 1000 )
	end

	return zo_callLater(func, delay)
end

function EHT.Biz.GetProcess()
	return EHT.Process, EHT.ProcessId
end

function EHT.Biz.IsProcessRunning(suppressMessage)
	if nil ~= EHT.Process then
		if not suppressMessage then
			df("'%s' is running. Please wait.", EHT.Biz.GetProcess())
			EHT.UI.PlaySoundFailure()
		end
		return true
	else
		return false
	end
end

function EHT.Biz.IsUninterruptableProcessRunning(suppressMessage)
	local SUPPRESS_MESSAGE = true
	if EHT.Biz.IsProcessRunning(SUPPRESS_MESSAGE) then
		local processName = EHT.Biz.GetProcess()
		if processName ~= EHT.PROCESS_NAME.ADJUST_SELECTED_GROUP and processName ~= EHT.PROCESS_NAME.BUILD then
			if not suppressMessage then EHT.Biz.IsProcessRunning() end
			return true
		end
	end

	return false
end

function EHT.Biz.StartProcess(processName)
	EHT.Process = processName
	EHT.ProcessId = nil
	EHT.ProcessRollingBack = EHT.IsRollingBackProcess
	EHT.ProcessData =
	{
		StartFrameTime = GetFrameTimeMilliseconds(),
	}

	EHT.Biz.ClearPendingFurnitureOperations()
	EHT.Interop.SuspendFurnitureSnap()
	EHT.UI.RefreshSelection()
	EHT.UI.UpdateKeybindStrip()

	local ui = EHT.UI.ToolDialog
	if ui then
		ui.ProcessName:SetText(processName)
		ui.ProcessProgressBar:SetAnchor(BOTTOMRIGHT, nil, nil, -1, -1)
		local separateBar = EHT.GetSetting("ShowSeparateProgressBar")
		ui.ProcessProgressBarContainer:SetHidden(true == separateBar)
		ui.ProcessCancel:SetHidden(true == EHT.ProcessRollingBack)
	end

	if processName ~= EHT.PROCESS_NAME.ADJUST_SELECTED_GROUP and processName ~= EHT.PROCESS_NAME.BUILD then
		EHT.UI.DisableToolDialog()
	end

	EHT.UI.UpdateProgressIndicator(processName, 0)
end

function EHT.Biz.EndProcess()
	EHT.Process = nil
	EHT.ProcessId = nil
	EHT.ProcessData = nil

	EHT.Biz.ClearPendingFurnitureOperations()
	EHT.Interop.ResumeFurnitureSnap()
	EHT.UI.RefreshSelection()
	EHT.UI.RefreshHistory()
	EHT.UI.RefreshAnimationDialog()
	EHT.UI.EnableToolDialog()
	EHT.UI.UpdateKeybindStrip()

	local ui = EHT.UI.ToolDialog
	if nil ~= ui then
		ui.ProcessProgressBarContainer:SetHidden(true)
	end

	EHT.UI.HideProgressIndicatorDialog()
end

function EHT.Biz.CancelProcess()
	if not EHT.ProcessRollingBack then
		if EHT.ProcessData and not EHT.ProcessData.CancelProcess then
			EHT.ProcessData.CancelProcess = true
		else
			EHT.Biz.CancelProcessCallback(true)
		end
	end
end

do
	local followUpProcessMap

	function GetFollowUpProcess(processName)
		if not followUpProcessMap then
			followUpProcessMap =
			{
				[EHT.PROCESS_NAME.ADD_FROM_INVENTORY] = EHT.Biz.Undo,
				[EHT.PROCESS_NAME.ADJUST_SELECTED_GROUP] = EHT.Biz.Undo,
				[EHT.PROCESS_NAME.BUILD] = EHT.Biz.Undo,
				[EHT.PROCESS_NAME.CHANGE_FURNITURE_STATE] = nil,
				[EHT.PROCESS_NAME.CUT_GROUP_TO_INVENTORY] = EHT.Biz.Undo,
				[EHT.PROCESS_NAME.DISMISS_KIOSK] = EHT.Biz.SummonKiosk,
				[EHT.PROCESS_NAME.LINK_GROUP] = EHT.Biz.UnlinkGroup,
				[EHT.PROCESS_NAME.MEASURE_DIMENSIONS] = nil,
				[EHT.PROCESS_NAME.PASTE_CLIPBOARD_FROM_HOUSE] = EHT.Biz.Undo,
				[EHT.PROCESS_NAME.PASTE_CLIPBOARD_FROM_INVENTORY] = EHT.Biz.Undo,
				[EHT.PROCESS_NAME.PLAY_SCENE] = nil,
				[EHT.PROCESS_NAME.REDO] = EHT.Biz.Undo,
				[EHT.PROCESS_NAME.REPLACE_MISSING_ITEMS] = EHT.Biz.Undo,
				[EHT.PROCESS_NAME.RESET_FURNITURE] = nil,
				[EHT.PROCESS_NAME.SUMMON_KIOSK] = EHT.Biz.DismissKiosk,
				[EHT.PROCESS_NAME.UNDO] = EHT.Biz.Redo,
				[EHT.PROCESS_NAME.UNLINK_GROUP] = EHT.Biz.LinkGroup,
			}
		end

		return followUpProcessMap[processName]
	end

	function EHT.Biz.CancelProcessCallback(forceCancel)
		local data = EHT.ProcessData
		local followUpProcess
		if "table" == type(data) and not forceCancel then
			followUpProcess = GetFollowUpProcess(EHT.Process)
		end

		EHT.Biz.EndProcess()

		if followUpProcess then
			zo_callLater(function()
				EHT.IsRollingBackProcess = true
				followUpProcess()
				EHT.IsRollingBackProcess = nil
			end, 200)
		end
	end
end

function EHT.Biz.SetProcessProgress( percent )
	local ui = EHT.UI.ToolDialog
	local separateBar = EHT.GetSetting( "ShowSeparateProgressBar" )

	if nil ~= ui then
		local maxWidth = ui.ProcessProgressBarBkg:GetWidth()
		local width = math.ceil((maxWidth - 6) * percent)
		ui.ProcessProgressBar:SetAnchor(BOTTOMRIGHT, nil, nil, -(maxWidth - width), -3)
		ui.ProcessProgressBarContainer:SetHidden(true == separateBar)
	end

	EHT.UI.UpdateProgressIndicator( EHT.Process, percent )
end
--[[
function EHT.Biz.ScheduleProcessActivity( func, delay, initialFrameTime )
	local data = EHT.ProcessData
	if data and data.CancelProcess then
		EHT.Biz.CancelProcessCallback()
		return
	end

	delay = delay or 100
	if EHT.Biz.HasPendingFurnitureOperations() then
		zo_callLater( function() EHT.Biz.ScheduleProcessActivity( func, delay, initialFrameTime or GetFrameTimeMilliseconds() ) end, 1 )
		return
	end

	if initialFrameTime then
		local elapsed = GetFrameTimeMilliseconds() - tonumber( initialFrameTime )
		delay = math.max( 0, delay - elapsed )
	end

	if 0 >= delay then
		EHT.ProcessId = GetGameTimeMilliseconds()
		func( EHT.ProcessId )
	else
		EHT.ProcessId = zo_callLater( func, delay or EHT.Setup.GetEditDelay() )
	end
end
]]
function EHT.Biz.ScheduleProcessActivity( func, delayMS, initialFrameTimeMS )
	local waitUntilMS = ( initialFrameTimeMS or GetGameTimeMilliseconds() ) + ( delayMS or 100 )
	return EHT.Biz.InternalScheduleProcessActivity( func, waitUntilMS )
end

function EHT.Biz.InternalScheduleProcessActivity( func, waitUntilMS )
	local data = EHT.ProcessData
	if data and data.CancelProcess and not EHT.ProcessRollingBack then
		EHT.Biz.CancelProcessCallback()
		return
	end

	local gameTimeMS = GetGameTimeMilliseconds()
	local timeElapsed = gameTimeMS >= waitUntilMS
	local pendingOperation = EHT.Biz.HasPendingFurnitureOperations()
	if not timeElapsed or pendingOperation then
		zo_callLater( function() EHT.Biz.InternalScheduleProcessActivity( func, waitUntilMS ) end, 1 )
		return
	end

	EHT.ProcessId = gameTimeMS
	func( gameTimeMS )
end

function EHT.Biz.CheckCurrentProcessActivity( id )
	local data = EHT.ProcessData
	if data and data.CancelProcess and not EHT.ProcessRollingBack then
		EHT.Biz.CancelProcessCallback()
		return false
	end

	if id == EHT.ProcessId then
		EHT.ProcessId = nil
		return true
	else
		return false
	end
end

function EHT.Biz.ClearPendingFurnitureOperations( operation )
	if operation then
		EHT.PendingFurnitureOperations[operation] = 0
	else
		for operation, count in pairs( EHT.PendingFurnitureOperations ) do
			EHT.PendingFurnitureOperations[operation] = 0
		end
	end
end

function EHT.Biz.IncrementPendingFurnitureOperations( operation, count )
	local previousCount = EHT.PendingFurnitureOperations[operation]
	local updatedCount = previousCount + ( count or 1 )

	EHT.PendingFurnitureOperations[operation] = updatedCount
	EHT.Biz.OnFurnitureOperationQueueChanged( operation, updatedCount, previousCount )
end

function EHT.Biz.DecrementPendingFurnitureOperations( operation, count )
	local previousCount = EHT.PendingFurnitureOperations[operation]
	local updatedCount = math.max( 0, previousCount - ( count or 1 ) )

	EHT.PendingFurnitureOperations[operation] = updatedCount
	EHT.Biz.OnFurnitureOperationQueueChanged( operation, updatedCount, previousCount )
end

function EHT.Biz.SetPendingFurnitureOperations( operation, count )
	local previousCount = EHT.PendingFurnitureOperations[operation]
	local updatedCount = math.max( 0, count )

	EHT.PendingFurnitureOperations[operation] = updatedCount
	EHT.Biz.OnFurnitureOperationQueueChanged( operation, updatedCount, previousCount )
end

function EHT.Biz.GetPendingFurnitureOperations( operation )
	if operation then
		return EHT.PendingFurnitureOperations[operation]
	else
		local total = 0
		for operation, count in pairs( EHT.PendingFurnitureOperations ) do
			total = total + count
		end
		return total
	end
end

function EHT.Biz.HasPendingFurnitureOperations( operation )
	if operation then
		return EHT.PendingFurnitureOperations[operation] > 0
	else
		for operation, count in pairs( EHT.PendingFurnitureOperations ) do
			if count > 0 then
				return true
			end
		end
		return false
	end
end

do
	local registry = { }
	local nextRegistryId = 1

	function EHT.Biz.OnFurnitureOperationQueueChanged( operation, updatedCount, previousCount )
		for registryEntryId, registryEntry in pairs( registry ) do
			if registryEntry.operation == operation and registryEntry.targetCount == updatedCount then
				local registryId = registryEntryId
				local registryOperation = operation
				local callback = registryEntry.callback
				callback( registryId, registryOperation, updatedCount, previousCount )
			end
		end
	end
	
	function EHT.Biz.StopWaiting( registryId )
		if not registryId then
			return false
		end

		local registryEntry = registry[ registryId ]
		if not registryEntry then
			return false
		end

		registry[ registryId ] = nil
		return true
	end

	function EHT.Biz.WaitFor( operation, targetCount, callback, callbackName )
		if "function" ~= type( callback ) then
			return nil
		end
		callbackName = callbackName or EHT.Util.GetCallstackFunctionNamesString() -- EHT.Util.GetCallerFunctionName()

		local registryId = nextRegistryId
		nextRegistryId = nextRegistryId + 1

		local registryEntry =
		{
			operation = operation,
			targetCount = targetCount,
			callback = callback,
			callbackName = callbackName,
		}
		registry[ registryId ] = registryEntry

		return registryId
	end

	function EHT.Biz.WaitForStart( operation, callback )
		local callbackName = EHT.Util.GetCallstackFunctionNamesString() -- EHT.Util.GetCallerFunctionName()
		local targetCount = EHT.Biz.GetPendingFurnitureOperations( operation )
		return EHT.Biz.WaitFor( operation, targetCount, callback, callbackName )
	end

	function EHT.Biz.WaitForFinish( operation, callback )
		local callbackName = EHT.Util.GetCallstackFunctionNamesString() -- EHT.Util.GetCallerFunctionName()
		local targetCount = EHT.Biz.GetPendingFurnitureOperations( operation )
		return EHT.Biz.WaitFor( operation, targetCount, callback, callbackName )
	end
end

do
	local REQUEST_COOLDOWN = 50
	local MAX_REQUESTS = 65

	function EHT.Biz.SubmitRequest( request, options )
		if not options then
			options = { }
		end

		options.requestCooldown = options.requestCooldown or REQUEST_COOLDOWN
		options.maxRequests = options.maxRequests or MAX_REQUESTS

		if not options.totalRequests then
			options.totalRequests = 0

			zo_callLater( function()
				EHT.Biz.SubmitRequest( request, options )
			end, options.requestCooldown )

			return nil
		end

		options.totalRequests = options.totalRequests + 1

		local result = request( options )
		if true == result then
			-- A true return value signals to complete the request.
			if options.callback then
				zo_callLater( function()
					options.callback( true, options )
				end, options.requestCooldown )
			end

			return true
		elseif false == result then
			-- A false return value signals to abort the request.
			if options.callback then
				zo_callLater( function()
					options.callback( false, options )
				end, options.requestCooldown )
			end

			return false
		else
			-- A non-boolean return value signals to queue another request attempt or occurence.
			if options.totalRequests >= options.maxRequests then
				if options.callback then
					options.callback( false, options )
				end

				return nil
			end

			zo_callLater( function()
				EHT.Biz.SubmitRequest( request, options )
			end, options.requestCooldown )
		end
	end
end

---[ Operations : Open Houses ]---

function EHT.Biz.GetInaccessibleHouses()
	local inaccessibleHouses = EHT.SavedVars.InaccessibleHouses
	if not inaccessibleHouses then
		inaccessibleHouses = { }
		EHT.SavedVars.InaccessibleHouses = inaccessibleHouses
	end
	return inaccessibleHouses
end

function EHT.Biz.GetInaccessibleHouse( owner, houseId )
	if type(owner) ~= "string" or type(houseId) ~= "number" or owner == "" or houseId <= 0 then
		return
	end
	
	local inaccessibleHouses = EHT.Biz.GetInaccessibleHouses()
	local key = string.format( "%d%s", houseId, string.lower( owner ) )
	local house = inaccessibleHouses[key]

	if house and type(house.publishedDate) == "number" then
		local openHouse = EssentialHousingHub:GetOpenHouse( houseId, owner )
		if openHouse and type(openHouse.publishedDate) == "number" then
			if openHouse.publishedDate > house.publishedDate then
				-- The open house has since been republished by the owner;
				-- therefore we can effectively clear the inaccessible flag
				-- in order to give them another chance.
				inaccessibleHouses[key] = nil
				return nil, key
			end
		end
	end

	return inaccessibleHouses[key], key
end

function EHT.Biz.SetHouseInaccessibleFlag( owner, houseId, isInaccessible )
	local house, key = EHT.Biz.GetInaccessibleHouse( owner, houseId )
	if not key then
		return
	end

	local inaccessibleHouses = EHT.Biz.GetInaccessibleHouses()
	if isInaccessible then
		local openHouse = EssentialHousingHub:GetOpenHouse( houseId, owner )
		inaccessibleHouses[key] = { attemptedDate = EHT.Util.GetDate(), publishedDate = openHouse and openHouse.publishedDate }
	else
		inaccessibleHouses[key] = nil
	end
end

---[ Operations : Assistants ]---

EHT.ASSISTANT_COLLECTIBLES =
{
	-- Banker Assistants
	[267] =
	{
		id = 267,
		key = "Tythis the Banker",
	},
	[6376] =
	{
		id = 6376,
		key = "Ezabi the Banker",
	},
	[8994] =
	{
		id = 8994,
		key = "Baron Jangleplume, the Banker",
	},
	[9743] =
	{
		id = 9743,
		key = "Factotum Property Steward",
	},

	-- Merchant Assistants
	[301] =
	{
		id = 301,
		key = "Nuzhimeh the Merchant",
	},
	[6378] =
	{
		id = 6378,
		key = "Fezez the Merchant",
	},
	[8995] =
	{
		id = 8995,
		key = "Peddler of Prizes, the Merchant",
	},
	[9744] =
	{
		id = 9744,
		key = "Factotum Commerce Delegate",
	},

	-- Smuggler Assistants
	[300] =
	{
		id = 300,
		key = "Pirharri the Smuggler",
	},

	-- Armory Assistants
	[9745] =
	{
		id = 9745,
		key = "Ghrasharog, Armory Assistant",
	},

	-- Companions
	[9245] =
	{
		id = 9245,
		key = "Bastian Hallix",
	},
	[9353] =
	{
		id = 9353,
		key = "Mirri Elendis",
	},
}

function EHT.Biz.GetAssistantCollectibleDataByLink(link)
	if "string" ~= type(link) then
		return
	end

	local collectibleId = tonumber(string.sub(link, 17, -5))
	if not collectibleId then
		return
	end
	
	local collectibleData = EHT.ASSISTANT_COLLECTIBLES[collectibleId]
	return collectibleData
end

function EHT.Biz.CanSummonDismissAssistant(collectibleData)
	if not collectibleData then
		return false
	end

	local collectibleId, key = collectibleData.id, collectibleData.key
	if not (collectibleId and key) then
		return false, nil
	end

	if not IsOwnerOfCurrentHouse() then
		return false, "Assistants may only be summoned in one of your own homes."
	end

	if not EHT.SavedVars.SummonAssistants then
		return false, "Assistant summoning is not enabled. Enable 'Summon/Dismiss Assistants with Quickslots' under Settings > Essential Housing Tools to use this feature."
	end

	local house = EHT.Data.GetCurrentHouse()
	if not house then
		return false, "Cannot access housing data record."
	end

	return true
end

function EHT.Biz.SummonDismissAssistantByAssistantData(collectibleData)
	if not EHT.Biz.CanSummonDismissAssistant(collectibleData) then
		return false
	end

	local collectibleId, key = collectibleData.id, collectibleData.key
	local house = EHT.Data.GetCurrentHouse()
	local assistant = house[key]

	if not assistant then
		local x, y, z, yaw = GetPlayerWorldPositionInHouse()
		local id = GetFurnitureIdFromCollectibleId(collectibleId)
		
		x, z = x - math.sin(yaw) * 100, z - math.cos(yaw) * 100
		yaw = (yaw + RAD180) % RAD360
		assistant = EHT.Data.CreateFurniture(id)
		house[key] = assistant

		if nil == assistant then
			if EHT.Housing.PlaceCollectible(collectibleId, x, y, z, 0, yaw, 0) == HOUSING_REQUEST_RESULT_SUCCESS then
				assistant = { AutoPlaced = true }
				house[key] = assistant
			end
		else
			EHT.Housing.SetFurniturePositionAndOrientation(id, x, y + 8, z, 0, yaw, 0)
		end

		if house[key] then
			df("%s summoned.", key)
		else
			df("Failed to place %s.", key)
			EHT.UI.PlaySoundFailure()
		end
	else
		local id = GetFurnitureIdFromCollectibleId(collectibleId)
		if nil == id or 0 == id then
			df("No %s found to dismiss.", key)
			EHT.UI.PlaySoundFailure()
		else
			if assistant.AutoPlaced then
				EHT.Housing.RemoveFurniture(id)
			else
				EHT.Housing.SetFurniturePositionAndOrientation(id, assistant.X, assistant.Y, assistant.Z, assistant.Pitch, assistant.Yaw, assistant.Roll)
			end
			df("%s dismissed.", key)
		end

		house[key] = nil
	end

	EHT.SummonAssistantCooldownTimeS = GetFrameTimeSeconds() + 2
	return true
end

do
	local queuedCollectibleData = nil

	local function OnQueueUpdate()
		EVENT_MANAGER:UnregisterForUpdate("EHT.QueueSummonDismissAssistant")

		local collectibleData = queuedCollectibleData
		queuedCollectibleData = nil
		EHT.Biz.SummonDismissAssistantByAssistantData(collectibleData)
	end

	function EHT.Biz.QueueSummonDismissAssistantData(collectibleData, delayS)
		queuedCollectibleData = collectibleData
		EVENT_MANAGER:RegisterForUpdate("EHT.QueueSummonDismissAssistant", delayS * 1000, OnQueueUpdate)
	end
end

function EHT.Biz.SummonDismissAssistant(link)
	local collectibleData = EHT.Biz.GetAssistantCollectibleDataByLink(link)
	local canSummon, failureMessage = EHT.Biz.CanSummonDismissAssistant(collectibleData)
	if not canSummon then
		if failureMessage then
			d(failureMessage)
		end
		return false
	end

	local frameTimeS = GetFrameTimeSeconds()
	local cooldownTimeS = tonumber(EHT.SummonAssistantCooldownTimeS)
	if cooldownTimeS and cooldownTimeS >= frameTimeS then
		EHT.Biz.QueueSummonDismissAssistantData(collectibleData, cooldownTimeS - frameTimeS)
		return true
	end

	EHT.SummonAssistantCooldownTimeS = nil
	EHT.Biz.SummonDismissAssistantByAssistantData(collectibleData)
end

---[ Operations : Item Locks ]---

function EHT.Biz.LockItems( items )
	if nil == items then _, items = EHT.Data.GetCurrentHouse() end
	if nil == items then return end

	PlaySound( SOUNDS.LOCKPICKING_CHAMBER_LOCKED ) 

	EHT.Data.SetLocks( items, true )
	EHT.UI.RefreshLockedIndicators()
	EHT.UI.RefreshSelection()
end

function EHT.Biz.UnlockItems( items )
	if nil == items then _, items = EHT.Data.GetCurrentHouse() end
	if nil == items then return end

	PlaySound( SOUNDS.LOCKPICKING_UNLOCKED )

	EHT.Data.SetLocks( items, false )
	EHT.UI.RefreshLockedIndicators()
	EHT.UI.RefreshSelection()
end

function EHT.Biz.LockUnlockItems( items )
	if nil == items then _, items = EHT.Data.GetCurrentHouse() end
	if nil == items then return end

	local allLocked = EHT.Data.AreAllLocked( items )
	local status

	if allLocked then
		PlaySound( SOUNDS.LOCKPICKING_UNLOCKED )
		status = "|c00ff00unlocked"
	else
		PlaySound( SOUNDS.LOCKPICKING_CHAMBER_LOCKED )
		status = "|cff0000locked"
	end

	EHT.Data.SetLocks( items, not allLocked )
	EHT.UI.RefreshLockedIndicators()
	EHT.UI.RefreshSelection()
	EHT.UI.DisplayNotification( string.format( "|cffffffItems are now %s|cffffff.", status ) )
end

function EHT.Biz.CheckItemLock( furnitureId )
	if nil ~= furnitureId and EHT.Data.IsLocked( furnitureId ) then
		EHT.UI.PlaySoundFailure()
		EHT.UI.SetPersistentNotification( "ItemLocked", "Item is locked.", 1000 )
		EHT.UI.DisplayNotification( "Item is locked." )
		EHT.Biz.UpdateItemStates( furnitureId )

		return true
	end

	return false
end

function EHT.Biz.UpdateItemStates( id )
	local house = EHT.Data.GetCurrentHouseRecord()
	if nil == house then return end

	id = EHT.Housing.FindFurnitureId( id )
	local idString = string.fromId64( id )

	local x, y, z = EHT.Housing.GetFurniturePosition( id )
	local pitch, yaw, roll = EHT.Housing.GetFurnitureOrientation( id )

	if nil ~= house.Groups then
		local group = house.Groups[ EHT.CONST.GROUP_DEFAULT ]
		if nil ~= group then
			for _, item in ipairs( group ) do
				if idString == item.Id then
					item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll = x, y, z, pitch, yaw, roll
					break
				end
			end
		end
	end
end

---[ Operations : Editing ]---

function EHT.Biz.GetEditorHeading()
	if EHT.Biz.DoesRelativePositionUseUnitHeading() then
		local _, _, _, heading = GetPlayerWorldPositionInHouse()
		return heading
	else
		return GetPlayerCameraHeading()
	end
end

---[ Operations : Guidelines ]---

function EHT.Biz.AreGuidelinesSnapped()
	local h, v = EHT.Biz.AreGuidelinesEnabled()
	if not h and not v then
		return false, false, false
	else
		return EHT.SavedVars.SnapToGuidelinesHorizontal, EHT.SavedVars.SnapToGuidelinesVertical, EHT.SavedVars.SnapRotationToGuidelines
	end
end

function EHT.Biz.ToggleGuidelinesSnapHorizontal()
	EHT.SavedVars.SnapToGuidelinesHorizontal = not EHT.SavedVars.SnapToGuidelinesHorizontal
	EHT.Biz.SetGuidelinesSettingsChanged()
	return EHT.SavedVars.SnapToGuidelinesHorizontal
end

function EHT.Biz.ToggleGuidelinesSnapVertical()
	EHT.SavedVars.SnapToGuidelinesVertical = not EHT.SavedVars.SnapToGuidelinesVertical
	EHT.Biz.SetGuidelinesSettingsChanged()
	return EHT.SavedVars.SnapToGuidelinesVertical
end

function EHT.Biz.ToggleGuidelinesSnapRotation()
	EHT.SavedVars.SnapRotationToGuidelines = not EHT.SavedVars.SnapRotationToGuidelines
	EHT.Biz.SetGuidelinesSettingsChanged()
	return EHT.SavedVars.SnapRotationToGuidelines
end

function EHT.Biz.AreGuidelinesEnabled()
	return EHT.SavedVars.ShowGuidelines, EHT.SavedVars.ShowGuidelines and EHT.SavedVars.ShowGuidelinesVertical
end

function EHT.Biz.ToggleGuidelines( horizontal, vertical )
	if horizontal then
		EHT.SavedVars.ShowGuidelines = not EHT.SavedVars.ShowGuidelines
	end
	if vertical then
		EHT.SavedVars.ShowGuidelinesVertical = not EHT.SavedVars.ShowGuidelinesVertical
	end
	EHT.Biz.SetGuidelinesSettingsChanged()
	return EHT.SavedVars.ShowGuidelines
end

function EHT.Biz.AreGuidelinesLocked()
	return EHT.Pointers.AreGuidelinesLocked()
end

function EHT.Biz.ToggleGuidelinesLock()
	EHT.Pointers.LockGuidelines( not EHT.Biz.AreGuidelinesLocked() )
	EHT.Biz.SetGuidelinesSettingsChanged()
	return EHT.Pointers.AreGuidelinesLocked()
end

function EHT.Biz.IsSelectionBoxEnabled()
	local enabled = EHT.SavedVars.ShowSelectionBoxIndicator
	return true == enabled or nil == enabled
end

function EHT.Biz.ToggleSelectionBox( enabled )
	if nil == enabled then enabled = not EHT.Biz.IsSelectionBoxEnabled() end
	EHT.SavedVars.ShowSelectionBoxIndicator = enabled
	EHT.Pointers.SetGroupOutlineHidden( not enabled )
	return enabled
end

function EHT.Biz.AreSelectionIndicatorsEnabled()
	local enabled = EHT.SavedVars.ShowSelectionIndicators
	return true == enabled or nil == enabled
end

function EHT.Biz.ToggleSelectionIndicators( enabled )
	if nil == enabled then enabled = not EHT.Biz.AreSelectionIndicatorsEnabled() end
	EHT.SavedVars.ShowSelectionIndicators = enabled
	EHT.Pointers.SetGroupedHidden( not enabled )
	return enabled
end

function EHT.Biz.AreGuidelineBoundaryHighlightsEnabled()
	local enabled = EHT.SavedVars.ShowGuidelinesBoundaryHighlights
	return true == enabled or nil == enabled
end

function EHT.Biz.GetGuidelinesAlpha()
	return EHT.SavedVars.GuidelinesAlpha or 1
end

function EHT.Biz.SetGuidelinesSettingsChanged()
	EHT.GuidelinesSettingsChanged = true
	EHT.UI.RefreshAdjustGuidelinesDialog()
	EHT.Pointers.FlashGuidelines()
end

function EHT.Biz.GetGuidelinesUnits()
	return EHT.SavedVars.GuidelinesUnits or 1
end

function EHT.Biz.GetGuidelinesYaw()
	local house = EHT.Data.GetCurrentHouseRecord()
	local yaw = 0
	if house and house.Guidelines then
		yaw = (house.Guidelines.Yaw or 0) % RAD90
	end
	return yaw
end

function EHT.Biz.HaveGuidelinesSettingsChanged( reset )
	local changed = EHT.GuidelinesSettingsChanged
	if reset and changed then EHT.GuidelinesSettingsChanged = false end
	return changed
end

function EHT.Biz.GetGuidelinesSettings()
	local enabled = EHT.SavedVars.ShowGuidelines
	if nil == enabled then enabled = true end

	local originX, originY, originZ, originYaw = 0, 0, 0, 0
	local units = EHT.SavedVars.GuidelinesUnits or 1
	local radius = EHT.SavedVars.GuidelinesRadius or 10
	local maxDistance = 2 * units
	local alpha = EHT.SavedVars.GuidelinesAlpha or 1

	local house = EHT.Data.GetCurrentHouseRecord()
	if nil ~= house then
		if nil == house.Guidelines then house.Guidelines = { X = 0, Y = 0, Z = 0, Yaw = 0 } end
		originX, originY, originZ, originYaw = house.Guidelines.X, house.Guidelines.Y, house.Guidelines.Z, house.Guidelines.Yaw
	end

	return enabled, originX, originY, originZ, originYaw, units, radius, maxDistance, alpha 
end

function EHT.Biz.SetGuidelinesSettings( enabled, originX, originY, originZ, originYaw, units, radius, alpha )
	EHT.Pointers.ShowGuidelinesArrows( false )

	if "boolean" == type( enabled ) then EHT.SavedVars.ShowGuidelines = enabled end
	if "number" == type( units ) then EHT.SavedVars.GuidelinesUnits = zo_clamp( units, 10, 1000 ) end
	if "number" == type( radius ) then EHT.SavedVars.GuidelinesRadius = zo_clamp( math.floor( radius ), 1, 40 ) end
	if "number" == type( alpha ) then EHT.SavedVars.GuidelinesAlpha = zo_clamp( alpha, 0, 1 ) end

	local house = EHT.Data.GetCurrentHouseRecord()
	if house then
		if not house.Guidelines then house.Guidelines = { X = 0, Y = 0, Z = 0, Yaw = 0 } end
		if "number" == type( originX ) then house.Guidelines.X = originX end
		if "number" == type( originY ) then house.Guidelines.Y = originY end
		if "number" == type( originZ ) then house.Guidelines.Z = originZ end
		if "number" == type( originYaw ) then
			originYaw = math.rad( round( math.deg( originYaw ), 1 ) )
			if -RAD45 >= originYaw then originYaw = RAD45
			elseif RAD45 < originYaw then originYaw = -RAD45 end
			house.Guidelines.Yaw = originYaw
		end
	end

	EHT.Biz.SetGuidelinesSettingsChanged()
end

---[ Operations : Place From Inventory ]---

function EHT.Biz.IsPlaceableBag( bagId )
	for _, validBagId in pairs( EHT.CONST.BAG_IDS ) do
		if validBagId == bagId then return true end
	end

	return false
end

function EHT.Biz.AddInventoryContextMenuCallback(bag, slotIndex, link)
	local stackSize = GetSlotStackSize(bag, slotIndex)
	if 0 < stackSize then
		local itemDesc
		if 1 < stackSize then
			itemDesc = "these " .. tostring(stackSize) .. " items"
		else
			itemDesc = "this item"
		end

		do
			local menuOption = "Place and select " .. itemDesc
			local callback = function()
				local SELECT_ITEMS = true
				EHT.Biz.AddItemsFromInventory(bag, slotIndex, link, SELECT_ITEMS)
			end
			AddMenuItem(menuOption, callback, MENU_ADD_OPTION_LABEL)
		end

		do
			local menuOption = "Place " .. itemDesc
			local callback = function()
				local DO_NOT_SELECT_ITEMS = false
				EHT.Biz.AddItemsFromInventory(bag, slotIndex, link, DO_NOT_SELECT_ITEMS)
			end
			AddMenuItem(menuOption, callback, MENU_ADD_OPTION_LABEL)
		end

		ShowMenu(self)
	end
end

function EHT.Biz.AddItemsFromInventory( bag, slotIndex, link, selectItems )
	if EHT.Biz.IsProcessRunning() then return end

	local stackSize, _ = GetSlotStackSize( bag, slotIndex )
	local slotLink = GetItemLink( bag, slotIndex )

	if link ~= slotLink then
		d( "Your inventory has changed. Please retry adding your furnishings." )
		return false
	end

	local house, group = EHT.Data.GetCurrentHouse()
	if nil == house or nil == group then return false end

	EHT.Biz.StartProcess( EHT.PROCESS_NAME.ADD_FROM_INVENTORY )

	local data = EHT.ProcessData
	data.Bag = bag
	data.SlotIndex = slotIndex
	data.Link = link
	data.StackSize = stackSize
	data.Processed = 0
	data.Group = group
	data.SelectItems = selectItems
	data.LastMeasuredLink = nil

	local x, y, z = GetPlayerWorldPositionInHouse()
	local heading = GetPlayerCameraHeading()
	data.PlaceSine, data.PlaceCosine = -math.sin(heading), -math.cos(heading)
	data.X, data.Y, data.Z, data.Heading = x + 200 * data.PlaceSine, y, z + 200 * data.PlaceCosine, heading
	data.History = { Op = EHT.CONST.CHANGE_TYPE.PLACE, Id = 0, Link = 1 < stackSize and "Multiple Items" or link, Batch = { } }

	EHT.UI.ShowToolTab( EHT.CONST.TOOL_TABS.SELECT )
	EHT.Biz.ScheduleProcessActivity( EHT.Biz.AddItemsFromInventoryProcess )

	return true
end

function EHT.Biz.CanPlaceAllItems()
	if 0 >= GetCurrentZoneHouseId() or not IsOwnerOfCurrentHouse() then return false end

	local bag = BAG_BACKPACK
	local numSlots = GetBagSize( bag )
	local link

	for index = 1, numSlots do
		link = GetItemLink( bag, index )
		if IsItemLinkPlaceableFurniture( link ) then return true end
	end

	return false
end

function EHT.Biz.AddAllItemsFromInventory( bag, selectItems )
	if EHT.Biz.IsProcessRunning() then return end

	local house, group = EHT.Data.GetCurrentHouse()
	if nil == house or nil == group then return false end

	EHT.Biz.StartProcess( EHT.PROCESS_NAME.ADD_FROM_INVENTORY )

	local data = EHT.ProcessData
	data.Bag = bag
	data.SlotIndex = 1
	data.Processed = 0
	data.Group = group
	data.SelectItems = selectItems
	data.LastMeasuredLink = nil

	local x, y, z = GetPlayerWorldPositionInHouse()
	local heading = GetPlayerCameraHeading()
	data.PlaceSine, data.PlaceCosine = -math.sin(heading), -math.cos(heading)
	data.X, data.Y, data.Z, data.Heading = x + 300 * data.PlaceSine, y, z + 300 * data.PlaceCosine, heading
	data.History = { Op = EHT.CONST.CHANGE_TYPE.PLACE, Id = 0, Link = "Multiple Items", Batch = { } }

	do
		local bag = data.Bag
		local numSlots = GetBagSize( bag )
		local total = 0

		for slotIndex = 1, numSlots do
			local slotLink = GetItemLink( bag, slotIndex )

			if IsItemLinkPlaceableFurniture( slotLink ) then
				local stackSize, _ = GetSlotStackSize( bag, slotIndex )
				total = total + stackSize
			end
		end

		data.TotalItems = total
	end

	EHT.UI.ShowToolTab( EHT.CONST.TOOL_TABS.SELECT )
	EHT.Biz.ScheduleProcessActivity( EHT.Biz.AddItemsFromInventoryProcess )

	return true
end

function EHT.Biz.AddItemsFromInventoryComplete()
	local data = EHT.ProcessData
	if nil ~= data and nil ~= data.History then EHT.CT.AddHistory( data.History ) end

	EHT.Biz.EndProcess()
	EHT.UI.ShowToolTab( EHT.CONST.TOOL_TABS.SELECT )
	EHT.UI.RefreshSelection()
	EHT.UI.RefreshHistory()
end

function EHT.Biz.SetFurniturePositionsByRelativeOffset(items, originX, originY, originZ, normalizedOffsetX, normalizedOffsetY, normalizedOffsetZ, yaw)
	if "table" ~= type(items) then
		return false
	end

	normalizedOffsetX, normalizedOffsetY, normalizedOffsetZ = normalizedOffsetX or 0, normalizedOffsetY or 0, normalizedOffsetZ or 0
	if not originX then
		originX, originY, originZ = GetPlayerWorldPositionInHouse()
	end

	for itemIndex, item in ipairs(items) do
		if "table" == type(item) then
			local id = item.Id
			local centerX, centerY, centerZ = EHT.Housing.GetFurnitureCenterFromEdge(id, normalizedOffsetX, normalizedOffsetY, normalizedOffsetZ, originX, originY, originZ, 0, yaw, 0, 0, 0, 0)
			item.X, item.Y, item.Z = EHT.Housing.GetFurniturePositionFromCenter(id, centerX, centerY, centerZ, 0, yaw, 0)
		end
	end
end

function EHT.Biz.AddItemsFromInventoryCallback(furnitureId)
	local data = EHT.ProcessData
	if nil ~= data and furnitureId then
		local furniture = EHT.Data.CreateFurniture(furnitureId)

		data.LastFurnitureId = furnitureId
		if data.LastFurnitureLink ~= data.LastMeasuredLink then
			local yaw = data.Heading
			local normalizedOffsetX, normalizedOffsetY, normalizedOffsetZ = data.PlaceSine, -1, data.PlaceCosine

			EHT.Biz.SetFurniturePositionsByRelativeOffset({furniture}, data.X, data.Y, data.Z, normalizedOffsetX, normalizedOffsetY, normalizedOffsetZ, yaw)
			EHT.Housing.SetFurniturePosition(furnitureId, furniture.X, furniture.Y, furniture.Z)

			data.PlaceX, data.PlaceY, data.PlaceZ = furniture.X, furniture.Y, furniture.Z
			data.LastMeasuredLink = data.LastFurnitureLink
		end

		if nil ~= data.History then
			table.insert(data.History.Batch, EHT.CT.CreateHistory(EHT.CONST.CHANGE_TYPE.PLACE, nil, furniture))
		end

		if data.SelectItems and nil ~= data.Group then
			EHT.Data.AddGroupFurniture(furnitureId, data.Group)
		end
	end

	EHT.Biz.ScheduleProcessActivity(EHT.Biz.AddItemsFromInventoryProcess)
end

function EHT.Biz.AddItemsFromInventoryProcess( processId )
	local data = EHT.ProcessData
	if not EHT.Biz.CheckCurrentProcessActivity( processId ) or nil == data then
		EHT.Biz.EndProcess()
		return nil
	end

	local bag, slotIndex, link, stackSize, group, processed, selectItems, totalItems = data.Bag, data.SlotIndex, data.Link, data.StackSize, data.Group, data.Processed, data.SelectItems, data.TotalItems
	local x, y, z = data.X, data.Y, data.Z
	local numSlots = GetBagSize( bag )

	if nil == link then
		while slotIndex <= numSlots do
			link = GetItemLink( bag, slotIndex )
			if IsItemLinkPlaceableFurniture( link ) then
				break
			else
				slotIndex = slotIndex + 1
				data.SlotIndex = slotIndex
			end
		end

		if slotIndex > numSlots then
			EHT.Biz.AddItemsFromInventoryComplete()
			return
		end
	else
		local currentStackSize, _ = GetSlotStackSize( bag, slotIndex )
		local slotLink = GetItemLink( bag, slotIndex )

		if processed >= stackSize or nil == currentStackSize or 0 >= currentStackSize or slotLink ~= link then
			EHT.Biz.AddItemsFromInventoryComplete()
			return
		end
	end

	local furnitureDataId = GetItemLinkFurnitureDataId( link )
	local _, _, _, furnitureLimitType = GetFurnitureDataInfo( furnitureDataId )

	if not data.MaxedLimits or not data.MaxedLimits[furnitureLimitType] then
		data.LastFurnitureLink = link
		local placeX, placeY, placeZ = data.PlaceX or x, data.PlaceY or y, data.PlaceZ or z
		local result = EHT.Housing.PlaceItem( bag, slotIndex, placeX, placeY, placeZ, 0, data.Heading, 0 )

		if HOUSING_REQUEST_RESULT_SUCCESS ~= result then
			if HOUSING_REQUEST_RESULT_LOW_IMPACT_ITEM_PLACE_LIMIT == result or HOUSING_REQUEST_RESULT_LOW_IMPACT_COLLECTIBLE_PLACE_LIMIT == result or HOUSING_REQUEST_RESULT_HIGH_IMPACT_ITEM_PLACE_LIMIT == result or HOUSING_REQUEST_RESULT_HIGH_IMPACT_COLLECTIBLE_PLACE_LIMIT == result then
				data.MaxedLimits = data.MaxedLimits or { }
				data.MaxedLimits[furnitureLimitType] = true
				d( "Cannot place additional furnishings: Item limit reached." )
			else
				df( "Failed to place furniture item. (Error code: %s)", tostring( result ) )
			end

			EHT.Biz.EndProcess()
			return nil
		end
	end

	data.Processed = data.Processed + 1

	if totalItems then
		EHT.Biz.SetProcessProgress(	data.Processed / totalItems )
	elseif stackSize then
		EHT.Biz.SetProcessProgress(	data.Processed / stackSize )
	else
		EHT.Biz.SetProcessProgress(	slotIndex / numSlots )
	end
end

---[ Operations : Group Selection ]---
 
function EHT.Biz.GetClipboard()
	if nil == EHT.SavedVars.Clipboard then
		EHT.SavedVars.Clipboard = { }
	end

	return EHT.SavedVars.Clipboard
end

function EHT.Biz.GetGroupSize()
	local _, group = EHT.Data.GetCurrentHouse()
	return group and #group or 0
end

function EHT.Biz.GetClipboardSize()
	return #EHT.Biz.GetClipboard()
end

function EHT.Biz.IsSelectedFurnitureGrouped()
	local furnitureId = HousingEditorGetSelectedFurnitureId()
	if nil ~= furnitureId then
		local x, y, z = EHT.Housing.GetFurniturePosition( furnitureId )
		if 0 ~= x and 0 ~= y and 0 ~= z then
			return nil ~= EHT.Data.GetGroupFurniture( furnitureId )
		end
	end

	return false
end

function EHT.Biz.RefreshGroupState()
	local _, group = EHT.Data.GetCurrentHouse()
	if nil == group then return end

	for index, item in pairs( group ) do
		item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll = EHT.Housing.GetFurniturePositionAndOrientation( item.Id )
	end
end

function EHT.Biz.ResetSelection()
	local house, group = EHT.Data.GetCurrentHouse()
	if nil == house or nil == group then return end

	for index = #group, 1, -1 do
		table.remove( group, index )
	end
	group.Paths = nil

	house.CurrentGroupName = EHT.CONST.GROUP_DEFAULT
	EHT.UI.RefreshSelectionList()
--	EHT.UI.QueueCheckForProtractedSelection()

	return group
end

function EHT.Biz.SelectAll( exceptions )
	local house, group = EHT.Data.GetCurrentHouse()
	if nil == house or nil == group then return end

	for index = #group, 1, -1 do
		table.remove( group, index )
	end

	local excludeEffects, excludeStations = false, nil

	if "table" == type( exceptions ) then
		excludeEffects = exceptions.effects

		if exceptions.stations then
			local stations = EHT.Housing.GetAllCraftingStations()
			if stations then
				excludeStations = { }
				for _, station in ipairs( stations ) do
					excludeStations[ string.fromId64( station.Id ) ] = true
				end
			end
		end
	end

	local furnitureIds = { }
	local id = nil

	repeat
		id = EHT.Housing.GetNextFurnitureId( id )
		if nil ~= id then
			if ( not excludeEffects or not EHT.Housing.IsEffectId( id ) ) and
			   ( not excludeStations or not excludeStations[ string.fromId64( id ) ] ) then
				table.insert( furnitureIds, id )
			end
		end
	until nil == id

	if 0 == #furnitureIds then
		EHT.UI.ShowAlertDialog( "", "No items or effects were found." )
	end

	--EHT.Data.AddGroupFurniture( furnitureIds )
	EHT.Biz.OnGroupUngroupFurniture( furnitureIds, true )
	EHT.UI.RefreshSelection()

	return group
end

function EHT.Biz.SelectAllEffects()
	local house, group = EHT.Data.GetCurrentHouse()
	if nil == house or nil == group then return end

	for index = #group, 1, -1 do
		table.remove( group, index )
	end

	local furnitureIds = { }
	local id = nil

	repeat
		id = EHT.Housing.GetNextFurnitureId( id )
		if nil ~= id and EHT.Housing.IsEffectId( id ) then table.insert( furnitureIds, id ) end
	until nil == id

	if 0 == #furnitureIds then
		EHT.UI.ShowAlertDialog( "", "No effects were found." )
	end

	--EHT.Data.AddGroupFurniture( furnitureIds )
	EHT.Biz.OnGroupUngroupFurniture( furnitureIds, true )
	EHT.UI.RefreshSelection()

	return group
end

function EHT.Biz.SelectAllStations()
	local house, group = EHT.Data.GetCurrentHouse()
	if nil == house or nil == group then return end

	local furnitureIds = { }
	local craftingStationIds = EHT.Housing.GetAllCraftingStations()

	for index, item in pairs( craftingStationIds) do
		table.insert( furnitureIds, item.Id )
	end

	if 0 == #furnitureIds then
		EHT.UI.ShowAlertDialog( "", "No stations were found." )
	end

	--EHT.Data.AddGroupFurniture( furnitureIds )
	EHT.Biz.OnGroupUngroupFurniture( furnitureIds, true )
	EHT.UI.RefreshSelection()

	return group
end

function EHT.Biz.AddGroupToCurrentGroup( group )
	if "table" == type( group ) then
		local furnitureIds = { }
		for index, item in ipairs( group ) do
			if item.Id then
				table.insert( furnitureIds, item.Id )
			end
		end

		EHT.Data.AddGroupFurniture( furnitureIds )
		EHT.UI.RefreshSelection()
	end
end

function EHT.Biz.RemoveGroupFromCurrentGroup( group )
	if "table" == type( group ) then
		local furnitureIds = { }
		for index, item in ipairs( group ) do
			if item.Id then
				table.insert( furnitureIds, item.Id )
			end
		end

		EHT.Data.RemoveGroupFurniture( furnitureIds )
		EHT.UI.RefreshSelection()
	end
end

function EHT.Biz.GroupUngroupFurnitureById( furnitureId, suppressMessage )
	local furniture = EHT.Data.GetGroupFurniture( furnitureId )
	local added

	if nil == furniture then
		furniture = EHT.Data.AddGroupFurniture( furnitureId )

		if furniture then
			EHT.Biz.OnGroupUngroupFurniture( furnitureId, true )
			added = true
		end
	else
		furniture = EHT.Data.RemoveGroupFurniture( furnitureId )

		if furniture then
			EHT.Biz.OnGroupUngroupFurniture( furnitureId, false )
			added = false
		end
	end

	if nil ~= added then
		EHT.UI.RefreshSelection()
	end

	return furniture, added
end

do
	local instructions_default = "Use the mouse to expand the radius, then press |c00ffffGroup Select|r again"
	local instructions_qam = "Use the mouse to expand the radius, then press |c00ffffOrganize|r again"
	local id, oX, oY, oZ, radius, add, homogenous, instructions
	local items, itemIndex, nextItemHighlight, nextItemUpdate, lastItemHighlighted
	local modeReady = false

	function EHT.Biz.IsRadiusSelecting()
		return nil ~= id
	end

	function EHT.Biz.BeginRadiusSelection( furnitureId, isAdd, isHomogenous, fromQuickActions )
		oX, oY, oZ = EHT.Housing.GetFurnitureCenter( furnitureId )
		id, add, homogenous, radius, modeReady = furnitureId, isAdd, isHomogenous, 1, false
		items, itemIndex, nextItemHighlight, nextItemUpdate, lastItemHighlighted = nil, nil, 0, 0, nil

		if fromQuickActions then
			instructions = instructions_qam
		else
			instructions = instructions_default
		end
		EHT.UI.ShowHint( instructions )

		EVENT_MANAGER:RegisterForUpdate( "EHT.Biz.OnRadiusSelectionUpdate", 50, EHT.Biz.OnRadiusSelectionUpdate )
	end

	function EHT.Biz.EndRadiusSelection( cancel )
		EVENT_MANAGER:UnregisterForUpdate( "EHT.Biz.OnRadiusSelectionUpdate" )
		EHT.Pointers.ClearSphere()
		EHT.UI.HideHint()
		ResetHousingEditorTrackedFurnitureId()

		if not cancel and id then
			local furnitureIds = EHT.Housing.FindNearbyFurniture( id, radius * 100, homogenous )
			EHT.Biz.OnGroupUngroupFurniture( furnitureIds, add )
		end

		id, modeReady = nil, false
	end

	function EHT.Biz.OnRadiusSelectionUpdate()
		if not modeReady then
			if EHT.Housing.IsSelectionMode() then
				modeReady = true
			end
		elseif not EHT.Housing.IsSelectionMode() then
			EHT.Biz.EndRadiusSelection( true )
			return
		end

		if not EHT.Biz.IsRadiusSelecting() then
			EHT.Biz.EndRadiusSelection()
			return
		end

		radius = zo_clamp( EHT.World:GetMinReticleDistance( oX, oY, oZ ) / 35, 0.25, 100 )
		EHT.Pointers.SetSphere( radius,		oX + 2, oY + 2, oZ + 2,		add and 0.2 or 1, add and 1 or 0.2, 0.2, EHT.GetSetting( "SelectionSphereAlpha" ) / 100 )

		local gt = GetGameTimeMilliseconds()

		if not items or not nextItemUpdate or nextItemUpdate < gt then
			items = EHT.Housing.FindNearbyFurniture( id, radius * 100, homogenous )
			items = EHT.Housing.OrderItemIdsByPosition( items )
			local count = #items

			local processTime = zo_clamp( GetGameTimeMilliseconds() - gt, 10, 500 )
			nextItemUpdate = gt + ( processTime * 5 )

			EHT.UI.ShowHint( string.format( "%s\n|cffff00%d item%s|r will be %s", instructions, count, 1 == count and "" or "s", add and "|c99ff99selected|r" or "|cff9999unselected|r" ) )
		end

		if items and ( not nextItemHighlight or nextItemHighlight < gt ) then
			nextItemHighlight = gt + 130

			local numItems = #items
			itemIndex = itemIndex or numItems

			if itemIndex < 1 or itemIndex > numItems then
				itemIndex = numItems
			end

			if 0 < itemIndex then
				local highlightItem = items[itemIndex]
				if lastItemHighlighted ~= highlightItem then
					SetHousingEditorTrackedFurnitureId( highlightItem )
					lastItemHighlighted = highlightItem
				end

				itemIndex = itemIndex - 1
			end
		end
	end
end

function EHT.Biz.OnGroupUngroupFurniture( furnitureIds, isAdd, suppressMessage )
	local count = 0

	if "number" == type( furnitureIds ) or "string" == type( furnitureIds ) then
		furnitureIds = { furnitureIds }
	end

	local _, group = EHT.Data.GetCurrentHouse()

	if "table" == type( furnitureIds ) then
		local showMessage = not suppressMessage and EHT.SavedVars.ShowSelectionInChat and 100 >= #furnitureIds

		if isAdd then
			for _, furnitureId in ipairs( furnitureIds ) do
				furniture = EHT.Data.AddGroupFurniture( furnitureId, group )

				if furniture then
					count = count + 1
					if showMessage then
						df( "Added '%s' to selection.", furniture.Link )
						EHT.UI.RefreshSelection()
					end
				end
			end
		else
			for _, furnitureId in ipairs( furnitureIds ) do
				furniture = EHT.Data.RemoveGroupFurniture( furnitureId, group )

				if furniture then
					count = count + 1
					if showMessage then
						df( "Removed '%s' from selection.", furniture.Link )
						EHT.UI.RefreshSelection()
					end
				end
			end
		end
	end

	if not suppressMessage then
		EHT.UI.DisplaySelectionChangeNotification( count, isAdd )
	end
	
	if not EHT.DirectionalIndicators:IsHidden() then
		if "table" == type( group ) then
			local groupSize = #group
			if 0 == groupSize then
				EHT.DirectionalIndicators:SetHidden( true )
			end
		end
	end

	EHT.UI.UpdateKeybindStrip()
	EHT.UI.ShowToolDialog()
end

function EHT.Biz.GroupUngroupFurniture()
	if EHT.Biz.IsProcessRunning() then return nil end

	local house, group = EHT.Data.GetCurrentHouse()
	if nil == house or nil == group then return end

	if EHT.Biz.IsRadiusSelecting() then
		EHT.Biz.EndRadiusSelection()
		return
	end

	local currentEditorMode = GetHousingEditorMode()
	local furnitureId = EHT.Housing.GetSelectedFurnitureAndNode()

	if currentEditorMode == HOUSING_EDITOR_MODE_PLACEMENT then
		if nil == EHT.Housing.FindFurnitureId( string.fromId64( furnitureId ) ) then
			if HOUSING_REQUEST_RESULT_SUCCESS == HousingEditorRequestSelectedPlacement() then
				EHT.SelectNextPlacedItem = true
			end

			return
		end

		return EHT.Biz.GroupUngroupFurnitureById( furnitureId )
	elseif currentEditorMode == HOUSING_EDITOR_MODE_SELECTION then
		local effect, _, effectDistance = EHT.World:GetReticleTargetEffect()

		local pathIndex
		furnitureId, pathIndex = HousingEditorGetTargetInfo()
		if 0 == furnitureId then
			furnitureId = nil
		end
		if pathIndex == EHT.INVALID_PATH_NODE then
			pathIndex = nil
		elseif furnitureId and pathIndex then
			furnitureId = EHT.Housing.GetFurniturePathNodeId( furnitureId, pathIndex )
		end

		if effect and not furnitureId then
			furnitureId = effect:GetRecordId()
		elseif effect and furnitureId then
			local x, y, z = EHT.Housing.GetFurniturePosition( furnitureId )
			local pX, pY, pZ = EHT.World:GetPlayerPosition()
			if effectDistance < zo_distance3D( x, y, z, pX, pY, pZ ) then
				furnitureId = effect:GetRecordId()
			end
		end

		if nil == furnitureId then
			EHT.UI.DisplayNotification( "Target an item" )
			EHT.UI.PlaySoundFailure()
			return
		end
	else
		EHT.UI.DisplayNotification( "Must be in Housing Editor mode" )
		return
	end

	local furniture = EHT.Data.GetGroupFurniture( furnitureId, group )
	local furnitureIds
	local isAdd = ( nil == furniture )
	local selectionMode = EHT.SavedVars.SelectionMode

	if EHT.SavedVars.SelectionModifierAlt and IsAltKeyDown() then
		selectionMode = EHT.SavedVars.SelectionModifierAlt
	elseif EHT.SavedVars.SelectionModifierCtrl and IsControlKeyDown() then
		selectionMode = EHT.SavedVars.SelectionModifierCtrl
	elseif EHT.SavedVars.SelectionModifierShift and IsShiftKeyDown() then
		selectionMode = EHT.SavedVars.SelectionModifierShift
	end

	if selectionMode == EHT.CONST.SELECTION_MODE.RADIUS then
		EHT.Biz.BeginRadiusSelection( furnitureId, isAdd, false )
		return
	elseif selectionMode == EHT.CONST.SELECTION_MODE.RADIUS_HOMOGENEOUS then
		EHT.Biz.BeginRadiusSelection( furnitureId, isAdd, true )
		return
	elseif selectionMode == EHT.CONST.SELECTION_MODE.LINKED then
		furnitureIds = EHT.Housing.FindLinked( furnitureId )
	elseif selectionMode == EHT.CONST.SELECTION_MODE.LINKED_CHILDREN then
		furnitureIds = EHT.Housing.FindLinkedChildren( furnitureId )
	elseif selectionMode == EHT.CONST.SELECTION_MODE.CONNECTED then
		furnitureIds = EHT.Housing.FindAdjacentFurniture( furnitureId, EHT.SavedVars.SelectionRadius, false, true )
	elseif selectionMode == EHT.CONST.SELECTION_MODE.CONNECTED_HOMOGENEOUS then
		furnitureIds = EHT.Housing.FindAdjacentFurniture( furnitureId, EHT.SavedVars.SelectionRadius, true, true )
	elseif selectionMode == EHT.CONST.SELECTION_MODE.RELATED_PATH_NODES then
		furnitureIds = EHT.Housing.FindPathNodes( furnitureId )
	elseif selectionMode == EHT.CONST.SELECTION_MODE.ALL_STATIONS_HOMOGENEOUS then
		furnitureIds = EHT.Housing.GetAllCraftingStations( furnitureId )
		if nil ~= furnitureIds then
			for index, item in ipairs( furnitureIds ) do furnitureIds[ index ] = item.Id end
		end
	elseif selectionMode == EHT.CONST.SELECTION_MODE.ALL_HOMOGENEOUS then
		furnitureIds = EHT.Housing.FindAdjacentFurniture( furnitureId, 999999999, true, false )
	else
		furnitureIds = { furnitureId }
	end

	EHT.Biz.OnGroupUngroupFurniture( furnitureIds, isAdd )
end

function EHT.Biz.GroupFurnitureByLimitType( limitType )
	local ids = EHT.Housing.GetFurnitureIdsByLimitType( limitType )
	if ids and 0 < #ids then
		EHT.Biz.OnGroupUngroupFurniture( ids, true )
	else
		EHT.UI.DisplaySelectionChangeNotification( 0, true )
	end
end

---[ Operations : Clipboard ]---

local CLIPBOARD_VERSION = 4
local CLIPBOARD_EOR = "!"
local CLIPBOARD_EOC = "\""
local CLIPBOARD_BEG = string.rep( CLIPBOARD_EOC, 10 )
local CLIPBOARD_PART_HEADER = "Clipboard Part "
local CLIPBOARD_PART_HEADER_FORMAT = CLIPBOARD_PART_HEADER .. "%d\n%s"
local CLIPBOARD_PRE_INSTRUCTIONS = "This is an Essential Housing Tools clipboard export.\n\nBELOW ARE THE ITEMS THAT YOU WILL NEED...\n\n"
local CLIPBOARD_POST_INSTRUCTIONS = "" ..
	"\n" ..
	"\n" ..
	"TO PASTE THE ABOVE ITEMS, OR THEIR LAYOUT, INTO YOUR HOME...\n" ..
	"\n" ..
	"[1] Gather the items shown in the list above.\n" ..
	"\n" ..
	"[2] Do ONE of the following:\n" ..
	"\n" ..
	" - Leave these items in your Inventory, Personal Bank and/or in Storage Coffers/Chests that are placed within your home\n" ..
	" OR\n" ..
	" - Stack these items very close together in your home and stand on/within/near to the stacked items\n" ..
	"   (Optionally, you may click \"Place & Select All Furniture\" [at the bottom-left corner of the game's Inventory screen] to quickly place all inventory furnishings)\n" ..
	"\n" ..
	"[3] Click the \"EHT\" button [at the bottom-right corner of the screen by default] to open Essential Housing Tools.\n" ..
	"[4] Click \"Copy & Paste\".\n" ..
	"[5] Click \"Import & Export\".\n" ..
	"[6] Copy and Paste the DATA (found below these instructions) into the \"Clipboard Import\" text box.\n" ..
	"[7] Click \"Import\".\n" ..
	"\n" ..
	"[8] Do ONE of the following:\n" ..
	"\n" ..
	" - If you gathered the items in your Inventory, Personal Bank and/or Storage Coffers/Chests, then click \"Paste from Inventory\".\n" ..
	" OR\n" ..
	" - If you stacked the items in your home, then click \"Paste to House Items\".\n" ..
	"\n" ..
	"NOTE: The Pasting process may take a few seconds to a few minutes, depending on the total number of items.\n" ..
	"\n" ..
	"COPY THE DATA BELOW INTO THE CLIPBOARD IMPORT TEXT BOX...\n\n"

local CLIPBOARD_INVALID_FORMAT = "Invalid clipboard data: %s"
local CLIPBOARD_INVALID_EOC_FORMAT = "Invalid clipboard data: Missing end-of-column identifier for column: %s"
local CLIPBOARD_INVALID_EOR_FORMAT = "Invalid clipboard data: Missing end-of-record identifier for column: %s"
local CLIPBOARD_INVALID_EFFECT_TYPE = "Invalid clipboard data: Undefined effect type index: %s"

function EHT.Biz.ValidateClipboard( data )
	if nil == data then return false, "No data." end

	for index, item in ipairs( data ) do
		if nil == item then return false, string.format( "Item #%d has no data.", index ) end
		if nil == item.Link or "" == item.Link then return false, string.format( "Item #%d has no Item Link.", index ) end
		if nil == item.X then return false, string.format( "Item #%d has an invalid X coordinate.", index ) end
		if nil == item.Y then return false, string.format( "Item #%d has an invalid Y coordinate.", index ) end
		if nil == item.Z then return false, string.format( "Item #%d has an invalid Z coordinate.", index ) end
		if nil == item.Pitch then return false, string.format( "Item #%d has an invalid Pitch.", index ) end
		if nil == item.Yaw then return false, string.format( "Item #%d has an invalid Yaw.", index ) end
		if nil == item.Roll then return false, string.format( "Item #%d has an invalid Roll.", index ) end
	end

	return true, nil
end

function EHT.Biz.GetItemizedList( group, separateBoundItems )
	local listBuffer = { }
	local items = { }
	local sortedItems = { }
	local item, link, quantity

	if nil ~= group and 0 < #group then
		for index, item in ipairs( group ) do
			if item.Link then
				quantity = items[ item.Link ]
				if nil == quantity then quantity = 1 else quantity = quantity + 1 end
				items[ item.Link ] = quantity
			end
		end

		for link, quantity in pairs( items ) do
			item = { Link = link, Name = EHT.Housing.GetFurnitureLinkName( link ), Quantity = quantity, Bound = ( IsItemLinkBound( link ) or GetCollectibleIdFromLink( link ) ) }
			table.insert( sortedItems, item )
		end

		table.sort( sortedItems, function( itemA, itemB ) return itemA.Name < itemB.Name end )
		local category

		for index, item in ipairs( sortedItems ) do
			if separateBoundItems then
				if not category then
					if item.Bound then
						category = "Bound"
						table.insert( listBuffer, "[ CANNOT Be Traded ]" )
						table.insert( listBuffer, "" )
					else
						category = "Unbound"
					end
				else
					if not item.Bound and "Bound" == category then
						table.insert( listBuffer, "" )
						table.insert( listBuffer, "[ Can Be Traded ]" )
						table.insert( listBuffer, "" )
					end
				end
			end

			if item.Bound then
				table.insert( listBuffer, string.format( "%3.0f x %-50s (Bound)", item.Quantity, item.Name ) )
			else
				table.insert( listBuffer, string.format( "%3.0f x %-50s", item.Quantity, item.Name ) )
			end
		end
	end

	return table.concat( listBuffer, "\n" )
end

function EHT.Biz.SerializeClipboard()
	local shortFloat = function( f, decimals )
		local s = string.format( "%." .. tostring( decimals ) .. "f", f )

		if nil == s or "" == s then return s end
		if nil == string.find( s, "." ) and nil == string.find( s, "," ) then return s end

		local lastIndex = string.len( s )
		for i = lastIndex, 1, -1 do
			if "0" == string.sub( s, i, i ) then
				lastIndex = i - 1
			elseif "." == string.sub( s, i, i ) or "," == string.sub( s, i, i ) then
				lastIndex = i - 1
				break
			else
				break
			end
		end

		if 0 < lastIndex then return string.sub( s, 1, lastIndex ) else return "0" end
	end

	local group = EHT.SavedVars.Clipboard
	local sBuffer = { }

	table.insert( sBuffer, CLIPBOARD_PRE_INSTRUCTIONS )
	table.insert( sBuffer, EHT.Biz.GetItemizedList( group, false ) )
	table.insert( sBuffer, CLIPBOARD_POST_INSTRUCTIONS )
	table.insert( sBuffer, string.format( "\n\n%sV%s%s", CLIPBOARD_BEG, CLIPBOARD_VERSION, CLIPBOARD_EOR ) )

	for index, item in ipairs( group ) do
		if nil ~= item then
			local itemId = item.ItemId
			if nil == itemId then itemId = EHT.Housing.GetFurnitureLinkItemId( item.Link ) end
			if nil ~= itemId then
				if EHT.Housing.IsEffectItemId( itemId ) then
					table.insert( sBuffer,
						string.format( "%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s",
							EHT.Util.IntToBase88( itemId ),
							CLIPBOARD_EOC,
							EHT.Util.IntToBase88( item.X or 0 ),
							CLIPBOARD_EOC,
							EHT.Util.IntToBase88( item.Y or 0 ),
							CLIPBOARD_EOC,
							EHT.Util.IntToBase88( item.Z or 0 ),
							CLIPBOARD_EOC,
							EHT.Util.IntToBase88( math.deg( item.Pitch or 0 ) % 360 * 100 ),
							CLIPBOARD_EOC,
							EHT.Util.IntToBase88( math.deg( item.Yaw or 0 ) % 360 * 100 ),
							CLIPBOARD_EOC,
							EHT.Util.IntToBase88( math.deg( item.Roll or 0 ) % 360 * 100 ),
							CLIPBOARD_EOC,
							EHT.Util.IntToBase88( item.SizeX or 0 ),
							CLIPBOARD_EOC,
							EHT.Util.IntToBase88( item.SizeY or 0 ),
							CLIPBOARD_EOC,
							EHT.Util.IntToBase88( item.SizeZ or 0 ),
							CLIPBOARD_EOC,
							EHT.Util.IntToBase88( item.Color or 0 ),
							CLIPBOARD_EOC,
							EHT.Util.IntToBase88( item.Alpha or 1 ),
							CLIPBOARD_EOC,
							EHT.Util.IntToBase88( item.Contrast or 1 ),
							CLIPBOARD_EOR ) )
				else
					table.insert( sBuffer,
						string.format( "%s%s%s%s%s%s%s%s%s%s%s%s%s%s",
							EHT.Util.IntToBase88( itemId ),
							CLIPBOARD_EOC,
							EHT.Util.IntToBase88( item.X or 0 ),
							CLIPBOARD_EOC,
							EHT.Util.IntToBase88( item.Y or 0 ),
							CLIPBOARD_EOC,
							EHT.Util.IntToBase88( item.Z or 0 ),
							CLIPBOARD_EOC,
							EHT.Util.IntToBase88( math.deg( item.Pitch or 0 ) % 360 * 100 ),
							CLIPBOARD_EOC,
							EHT.Util.IntToBase88( math.deg( item.Yaw or 0 ) % 360 * 100 ),
							CLIPBOARD_EOC,
							EHT.Util.IntToBase88( math.deg( item.Roll or 0 ) % 360 * 100 ),
							CLIPBOARD_EOR ) )
				end
			end
		end
	end

	local data = { }
	local dataString = table.concat( sBuffer, "" )
	local maxPartLength = EHT.CONST.MAX_CLIPBOARD_LENGTH - #CLIPBOARD_PART_HEADER

	while #dataString > 0 do
		local dataPart
		if maxPartLength < #dataString then
			dataPart = string.sub( dataString, 1, EHT.CONST.MAX_CLIPBOARD_LENGTH )
		else
			dataPart = dataString
		end
		dataString = string.sub( dataString, #dataPart + 1 )

		if #data > 0 then
			dataPart = string.format( CLIPBOARD_PART_HEADER_FORMAT, #data + 1, dataPart )
		end
		table.insert( data, dataPart .. "\n" )
	end

	return data
end

function EHT.Biz.ConcatenateClipboardParts( parts )
	local finalParts = ""

	for _, part in ipairs( parts ) do
		local startIndex = 1
		local _, headerIndex = string.find( part, CLIPBOARD_PART_HEADER )
		if headerIndex then
			local _, newLineIndex = string.find( part, "\n", headerIndex + 1 )
			if newLineIndex then
				startIndex = newLineIndex + 1
			end
		end
		
		local partLength = #part
		local endIndex = partLength
		if startIndex <= partLength then
			while endIndex >= startIndex do
				local asc = string.byte( string.sub( part, endIndex, endIndex ) )
				if asc >= 33 then
					break
				end
				endIndex = endIndex - 1
			end
		end
		
		if startIndex <= partLength and endIndex >= startIndex then
			finalParts = finalParts .. string.sub( part, startIndex, endIndex )
		end
	end

	return finalParts
end

function EHT.Biz.DeserializeClipboard( textOrTable )
	local s
	if "table" == type( textOrTable ) then
		s = EHT.Biz.ConcatenateClipboardParts( textOrTable )
	else
		s = textOrTable
	end

	local group = { }
	if nil == s or "" == s then return true, group end

	local item = nil
	local indexStart, indexEnd, indexEnd2 = 1, 1, 1
	local effectType, isEffect = nil, false
	local sLen = #s

	while indexStart < sLen do
		if 33 <= string.byte( string.sub( s, indexStart, indexStart ) ) then break end
		indexStart = indexStart + 1
	end

	local version = CLIPBOARD_VERSION

	-- Automatically skip any accidentally copied instructional text.

	local _, beginTagIndex = string.find( s, CLIPBOARD_BEG, indexStart )
	if nil ~= beginTagIndex then
		indexStart = beginTagIndex + 1
	end

	local indexVersion = string.find( s, "V", indexStart )
	if indexVersion then
		local indexVersionEnd = string.find( s, CLIPBOARD_EOR, indexVersion )
		if indexVersionEnd then
			version = string.sub( s, indexVersion + 1, indexVersionEnd - 1 )
			if version and "" ~= version then
				version = tonumber( version )
			end
		end
	end

	indexStart = string.find( s, CLIPBOARD_EOR, indexStart )
	if nil == indexStart then return false, string.format( CLIPBOARD_INVALID_FORMAT, "First record not found." ) end
	indexStart = indexStart + 1

	if indexStart >= sLen then return true, group end

	while nil ~= indexStart do
		item = { }
		isEffect = false

		indexEnd = string.find( s, CLIPBOARD_EOC, indexStart )
		if nil == indexEnd then return false, string.format( CLIPBOARD_INVALID_EOC_FORMAT, "Item ID" ) end
		item.ItemId = EHT.Util.Base88ToInt( string.sub( s, indexStart, indexEnd - 1 ) )
		if nil == item.ItemId then return false, string.format( CLIPBOARD_INVALID_EOC_FORMAT, "Item ID" ) end
		item.Link = EHT.Housing.GetFurnitureItemIdLink( item.ItemId )

		indexStart = indexEnd + 1
		indexEnd = string.find( s, CLIPBOARD_EOC, indexStart )
		if nil == indexEnd then return false, string.format( CLIPBOARD_INVALID_EOC_FORMAT, "X" ) end
		item.X = EHT.Util.Base88ToInt( string.sub( s, indexStart, indexEnd - 1 ) )
		if nil == item.X then return false, string.format( CLIPBOARD_INVALID_EOC_FORMAT, "X" ) end

		indexStart = indexEnd + 1
		indexEnd = string.find( s, CLIPBOARD_EOC, indexStart )
		if nil == indexEnd then return false, string.format( CLIPBOARD_INVALID_EOC_FORMAT, "Y" ) end
		item.Y = EHT.Util.Base88ToInt( string.sub( s, indexStart, indexEnd - 1 ) )
		if nil == item.Y then return false, string.format( CLIPBOARD_INVALID_EOC_FORMAT, "Y" ) end

		indexStart = indexEnd + 1
		indexEnd = string.find( s, CLIPBOARD_EOC, indexStart )
		if nil == indexEnd then return false, string.format( CLIPBOARD_INVALID_EOC_FORMAT, "Z" ) end
		item.Z = EHT.Util.Base88ToInt( string.sub( s, indexStart, indexEnd - 1 ) )
		if nil == item.Z then return false, string.format( CLIPBOARD_INVALID_EOC_FORMAT, "Z" ) end

		indexStart = indexEnd + 1
		indexEnd = string.find( s, CLIPBOARD_EOC, indexStart )
		if nil == indexEnd then return false, string.format( CLIPBOARD_INVALID_EOC_FORMAT, "Pitch" ) end
		item.Pitch = EHT.Util.Base88ToInt( string.sub( s, indexStart, indexEnd - 1 ) )
		if nil == item.Pitch then return false, string.format( CLIPBOARD_INVALID_EOC_FORMAT, "Pitch" ) end
		item.Pitch = math.rad( item.Pitch / 100 )

		indexStart = indexEnd + 1
		indexEnd = string.find( s, CLIPBOARD_EOC, indexStart )
		if nil == indexEnd then return false, string.format( CLIPBOARD_INVALID_EOC_FORMAT, "Yaw" ) end
		item.Yaw = EHT.Util.Base88ToInt( string.sub( s, indexStart, indexEnd - 1 ) )
		if nil == item.Yaw then return false, string.format( CLIPBOARD_INVALID_EOC_FORMAT, "Yaw" ) end
		item.Yaw = math.rad( item.Yaw / 100 )

		indexStart = indexEnd + 1
		indexEnd = string.find( s, CLIPBOARD_EOR, indexStart )
		indexEnd2 = string.find( s, CLIPBOARD_EOC, indexStart )
		if nil == indexEnd2 and nil == indexEnd then return false, string.format( CLIPBOARD_INVALID_EOR_FORMAT, "Roll" ) end
		if indexEnd2 and ( not indexEnd or indexEnd2 < indexEnd ) then
			isEffect = true
			indexEnd = indexEnd2
		end
		item.Roll = EHT.Util.Base88ToInt( string.sub( s, indexStart, indexEnd - 1 ) )
		item.Roll = math.rad( item.Roll / 100 )

		if isEffect then
			indexStart = indexEnd + 1
			indexEnd = string.find( s, CLIPBOARD_EOC, indexStart )
			if nil == indexEnd then return false, string.format( CLIPBOARD_INVALID_EOC_FORMAT, "SizeX" ) end
			item.SizeX = EHT.Util.Base88ToInt( string.sub( s, indexStart, indexEnd - 1 ) )
			if nil == item.SizeX then return false, string.format( CLIPBOARD_INVALID_EOC_FORMAT, "SizeX" ) end

			indexStart = indexEnd + 1
			indexEnd = string.find( s, CLIPBOARD_EOC, indexStart )
			if nil == indexEnd then return false, string.format( CLIPBOARD_INVALID_EOC_FORMAT, "SizeY" ) end
			item.SizeY = EHT.Util.Base88ToInt( string.sub( s, indexStart, indexEnd - 1 ) )
			if nil == item.SizeY then return false, string.format( CLIPBOARD_INVALID_EOC_FORMAT, "SizeY" ) end

			indexStart = indexEnd + 1
			indexEnd = string.find( s, CLIPBOARD_EOC, indexStart )
			if nil == indexEnd then return false, string.format( CLIPBOARD_INVALID_EOC_FORMAT, "SizeZ" ) end
			item.SizeZ = EHT.Util.Base88ToInt( string.sub( s, indexStart, indexEnd - 1 ) )
			if nil == item.SizeZ then return false, string.format( CLIPBOARD_INVALID_EOC_FORMAT, "SizeZ" ) end

			indexStart = indexEnd + 1
			indexEnd = string.find( s, CLIPBOARD_EOC, indexStart )
			if nil == indexEnd then return false, string.format( CLIPBOARD_INVALID_EOC_FORMAT, "Color" ) end
			item.Color = EHT.Util.Base88ToInt( string.sub( s, indexStart, indexEnd - 1 ) )
			if nil == item.Color then return false, string.format( CLIPBOARD_INVALID_EOC_FORMAT, "Color" ) end

			if version < 3 then
				indexStart = indexEnd + 1
				indexEnd = string.find( s, CLIPBOARD_EOR, indexStart )
				if nil == indexEnd then return false, string.format( CLIPBOARD_INVALID_EOR_FORMAT, "Alpha" ) end
				item.Alpha = EHT.Util.Base88ToInt( string.sub( s, indexStart, indexEnd - 1 ) )
				if nil == item.Alpha then return false, string.format( CLIPBOARD_INVALID_EOR_FORMAT, "Alpha" ) end
			else
				indexStart = indexEnd + 1
				indexEnd = string.find( s, CLIPBOARD_EOC, indexStart )
				if nil == indexEnd then return false, string.format( CLIPBOARD_INVALID_EOC_FORMAT, "Alpha" ) end
				item.Alpha = EHT.Util.Base88ToInt( string.sub( s, indexStart, indexEnd - 1 ) )
				if not item.Alpha then item.Alpha = 1 end

				indexStart = indexEnd + 1
				indexEnd = string.find( s, CLIPBOARD_EOR, indexStart )
				if nil == indexEnd then return false, string.format( CLIPBOARD_INVALID_EOR_FORMAT, "Contrast" ) end
				item.Contrast = EHT.Util.Base88ToInt( string.sub( s, indexStart, indexEnd - 1 ) )
				if not item.Contrast or 0 == item.Contrast then item.Contrast = 1 end
			end

			effectType = EHT.Housing.GetItemIdEffectType( item.ItemId )
			if not effectType then return false, string.format( CLIPBOARD_INVALID_EFFECT_TYPE, tostring( item.ItemId ) or "nil" ) end
			item.EffectType = effectType.Index
		end

		table.insert( group, item )
		indexStart = indexEnd + 1

		while indexStart and indexStart > 0 and indexStart < sLen do
			if 33 <= string.byte( string.sub( s, indexStart, indexStart ) ) then break end
			indexStart = indexStart + 1
		end

		if indexStart >= sLen then break end
	end

	return true, group
end

function EHT.Biz.ImportClipboard( clipboardString )
	local success, response = EHT.Biz.DeserializeClipboard( clipboardString )

	if not success then
		response = "Invalid clipboard import data:\n" .. ( response or "Unspecified exception." )
	else
		local valid = ""
		success, valid = EHT.Biz.ValidateClipboard( response )

		if not success then
			response = "Invalid clipboard import data:\n" .. ( valid or "Unspecified exception." )
		else
			EHT.SavedVars.Clipboard = response
			EHT.UI.QueueRefreshClipboard()
			response = nil
		end
	end
	
	return success, response
end

function EHT.Biz.ClipboardCount()
	return nil ~= EHT.SavedVars.Clipboard and #EHT.SavedVars.Clipboard or 0
end

function EHT.Biz.IsClipboardEmpty()
	return nil == EHT.SavedVars.Clipboard or 0 >= #EHT.SavedVars.Clipboard
end

function EHT.Biz.ResetClipboard()
	EHT.SavedVars.Clipboard = { }
	EHT.UI.QueueRefreshClipboard()
end

function EHT.Biz.MoveGroupCenterTo( group, x, y, z )
	local origin = EHT.Housing.CalculateFurnitureOrigin( group )
	if origin then
		local deltaX, deltaY, deltaZ = x - origin.X, y - origin.Y, z - origin.Z
		for _, item in ipairs( group ) do
			if item.X then
				item.X, item.Y, item.Z = item.X + deltaX, item.Y + deltaY, item.Z + deltaZ
			end
		end
	end
end

function EHT.Biz.CopyGroupToClipboard( group )
	if nil == group then
		_, group = EHT.Data.GetCurrentHouse()
		if nil == group then return nil end
	end

	EHT.SavedVars.Clipboard = EHT.Util.CloneTable( group )
	local REFRESH_PATH_INFO = true
	EHT.Data.ValidateGroupPathables( EHT.SavedVars.Clipboard, REFRESH_PATH_INFO )

	EHT.UI.UpdateKeybindStrip()
	EHT.UI.QueueRefreshClipboard()

	return #EHT.SavedVars.Clipboard
end

function EHT.Biz.CutGroupToInventory( preserveClipboard )
	if EHT.Biz.IsProcessRunning() then return end

	if true ~= preserveClipboard then
		EHT.Biz.CopyGroupToClipboard()
	end

	local house, group = EHT.Data.GetCurrentHouse()

	EHT.Biz.StartProcess( EHT.PROCESS_NAME.CUT_GROUP_TO_INVENTORY )
	EHT.ProcessData.Group = group
	EHT.ProcessData.Total = #group
	EHT.ProcessData.Cut = 0
	EHT.ProcessData.Index = #group
	EHT.ProcessData.Iteration = 1

	local history = { Op = EHT.CONST.CHANGE_TYPE.REMOVE, Id = 0, Link = "Multiple Items", Batch = { } }
	local historyBatch = history.Batch

	for _, item in ipairs( group ) do
		table.insert( historyBatch, EHT.CT.CreateHistory( EHT.CONST.CHANGE_TYPE.REMOVE, item, nil ) )
	end

	if nil ~= history and nil ~= historyBatch and 0 < #historyBatch then
		EHT.CT.AddHistory( history )
		EHT.ProcessData.History = history
		EHT.Pointers.ShowGuidelinesArrows( false )
		EHT.Biz.ScheduleProcessActivity( EHT.Biz.CutGroupToInventoryProcess )
	end
end

function EHT.Biz.CutGroupToInventoryProcess( processId )
	local data = EHT.ProcessData
	if not EHT.Biz.CheckCurrentProcessActivity( processId ) or nil == data then EHT.Biz.EndProcess() return nil end

	local index, iteration, group, total = data.Index, data.Iteration, data.Group, data.Total or 1
	local item
	if nil ~= group then item = group[ index ] end

	if nil == group or nil == item then
		if data.Cut < data.Total then
			df( "Removed %s of %s items to inventory.", tostring( data.Cut ), tostring( data.Total ) )

			EHT.UI.ShowAlertDialog( "Operation Failed", string.format( "Removed %d of %d items.\nNote: One or more items failed to be removed.\n\nYou may undo these changes from the Undo tab if you wish to put the removed items back into the house.", data.Cut or 0, data.Total or 0 ) )
			EHT.UI.PlaySoundFailure()
		else
			EHT.Biz.ResetSelection( true )
		end

		EHT.Biz.EndProcess()
		EHT.UI.RefreshHistory()
		EHT.UI.RefreshSelection()

		return nil
	end

	EHT.Biz.SetProcessProgress(	( total - iteration ) / total )

	local success = false
	local isEffect = false
	local id = EHT.Housing.FindFurnitureId( item.Id )
	if nil ~= id then
		if EHT.Housing.IsEffectId( id ) then
			isEffect = true
		end

		local link = EHT.Housing.GetFurnitureLink( id )
		local result = EHT.Housing.RemoveFurniture( id )

		if result == HOUSING_REQUEST_RESULT_SUCCESS then
			table.remove( group, index )
			data.Cut = data.Cut + 1
			success = true
		else
			EHT.CT.ChangeFailed( data.History, id )
			if result == HOUSING_REQUEST_RESULT_ITEM_REMOVE_FAILED_INVENTORY_FULL then
				df( "Failed to remove item - your inventory is full." )
			else
				df( "Failed to remove item: %s (Code %s)", ( nil == link or "" == link ) and "(no link)" or link, tostring( result ) or "Unknown" )
			end
		end
	end

	index = index - 1
	data.Index = index
	data.Iteration = iteration + 1

	EHT.Biz.ScheduleProcessActivity( EHT.Biz.CutGroupToInventoryProcess, success and (isEffect and EHT.CONST.FX_REQUEST_DELAY or EHT.CONST.HOUSING_REMOVE_DELAY) or 1 )
end

function EHT.Biz.MatchAndUpdateFurniture( updateTable, sourceTable )
	if nil == updateTable or 0 >= #updateTable then return { } end

	local updates = EHT.Util.CloneTable( updateTable )
	local id, item, itemId = nil, nil, nil
	local items, matches = { }, { }
	local pX, pY, pZ = GetPlayerWorldPositionInHouse()

	-- Tag FX items.

	for index = #updates, 1, -1 do
		local item = updates[index]

		if item then
			if item.Link and EHT.Housing.IsEffectItemLink( item.Link ) then
				item.IsEffect = true
			else
				item.IsEffect = false
			end
		end
	end

	-- Preparse the Item Ids for the updated items.

	for updateIndex, updateItem in ipairs( updates ) do
		if updateItem.Link then
			if not updateItem.ItemId then updateItem.ItemId = EHT.Housing.GetFurnitureLinkItemId( updateItem.Link ) end
			if not updateItem.Name then updateItem.Name = EHT.Housing.GetFurnitureLinkName( updateItem.Link ) end
		end
	end

	if nil == sourceTable then
		-- Create the Items for the house inventory, including Item Id and Distance from player.
		repeat
			id = EHT.Housing.GetNextFurnitureId( id )

			if nil ~= id then
				item = EHT.Data.CreateFurniture( id )

				if nil ~= item then
					if nil == item.ItemId then item.ItemId = EHT.Housing.GetFurnitureItemId( id ) end
					if nil == item.Name then item.Name = EHT.Housing.GetFurnitureLinkName( item.Link ) end
					item.Distance = zo_distance3D( item.X, item.Y, item.Z, pX, pY, pZ )

					table.insert( items, item )
				end
			end
		until nil == id
	else
		-- Create the Items for the specified Group, including Item Id and Distance from player.
		sourceTable = EHT.Util.CloneTable( sourceTable )

		for index, item in ipairs( sourceTable ) do
			if nil == item.ItemId then item.ItemId = EHT.Housing.GetFurnitureItemId( id ) end
			if nil == item.Name then item.Name = EHT.Housing.GetFurnitureLinkName( item.Link ) end
			item.Distance = zo_distance3D( item.X, item.Y, item.Z, pX, pY, pZ )

			table.insert( items, item )
		end
	end

	-- Sort house inventory Items by Distance from player (ascending).

	table.sort( items, function( itemA, itemB ) return itemA.Distance < itemB.Distance end )

	-- Match house inventory Items to Update Items.

	local matched

	for updateIndex, updateItem in ipairs( updates ) do
		matched = false

		if EHT.Housing.IsFurniturePathNodeId( updateItem.Id ) then
			for itemIndex, item in ipairs( items ) do
				if updateItem.Id == item.Id then
					item.Match = updateItem
					item.Distance = nil
					matched = true

					table.insert( matches, item )
					table.remove( items, itemIndex )
					break
				end
			end
		else
			for itemIndex, item in ipairs( items ) do
				if string.lower( updateItem.Name ) == string.lower( item.Name ) then
					item.Match = updateItem
					item.Distance = nil
					matched = true

					table.insert( matches, item )
					table.remove( items, itemIndex )
					break
				end
			end

			if not matched and updateItem.IsEffect then
				updateItem.Match = nil
				updateItem.IsEffect = nil

				table.insert( matches, updateItem )
			end
		end
	end

	return matches
end

local function OnAdjustPastedFurniture( item )
	if nil == item then
		return
	end

	if EHT.Housing.IsEffectItemLink( item.Link ) then
		local data = item
		local e = EHT.Data.RestoreEffectRecord( item.Id, data.EffectType, data.X, data.Y, data.Z, data.Pitch, data.Yaw, data.Roll, data.SizeX, data.SizeY, data.SizeZ, data.Color, data.Alpha, data.Groups )

		if e and e.Id then
			local eItem = EHT.Data.CreateFurniture( e.Id )

			if eItem then
				for k, v in pairs( eItem ) do
					item[k] = v
				end
			end
		end
	else
		local m = item.Match
		if m then
			local x, y, z, pitch, yaw, roll = m.X, m.Y, m.Z, m.Pitch, m.Yaw, m.Roll
			pitch, yaw, roll = EHT.Housing.CorrectGimbalLock( pitch, yaw, roll, false, item.Id )
			item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll = x, y, z, pitch, yaw, roll
			item.Groups = m.Groups or item.Groups or 0
			item.Speed, item.DelayTime = m.Speed, m.DelayTime
		end
	end

	item.Distance, item.IsEffect, item.Match = nil, nil, nil
end

function EHT.Biz.ApplyGroupItemMatching( group )
	for _, item in ipairs( group ) do
		OnAdjustPastedFurniture( item )
	end
end

function EHT.Biz.PasteClipboardFromSelection( rotateWithPlayer, skipMissingItems )
	if nil == rotateWithPlayer then rotateWithPlayer = IsShiftKeyDown() end
	if nil == skipMissingItems then skipMissingItems = false end

	local house, group = EHT.Data.GetCurrentHouse()
	if nil == house or nil == group then
		EHT.UI.ShowAlertDialog( "Must be in a House", "You must be in a house to paste the clipboard." )
		return
	end

	local clipboard = EHT.SavedVars.Clipboard
	if nil == clipboard or 0 >= #clipboard then
		EHT.UI.ShowAlertDialog( "Clipboard Empty", "The clipboard is empty." )
		return
	end

	local matches = EHT.Biz.MatchAndUpdateFurniture( clipboard, group )
	local total = #clipboard
	local failed = total - #matches

	if not skipMissingItems and 0 < failed then
		if failed < total then
			EHT.UI.ShowConfirmationDialog(
				"Missing Items",
				string.format( "WARNING:\n%d of the %d clipboard items could not be matched to any items in the current selection.\n\nDo you wish to continue with a partial paste?", failed, total ),
				function()
					EHT.Biz.PasteClipboardFromSelection( rotateWithPlayer, true )
				end )
		else
			EHT.UI.ShowAlertDialog(
				"Missing Items",
				string.format( "ERROR:\nNone of the %d clipboard items could be matched to any items in the current selection.", total ) )
		end

		return
	end

	group = EHT.Biz.ResetSelection( true )

	for index, item in ipairs( matches ) do
		table.insert( group, item )
	end

	if clipboard.Paths then
		group.Paths = EHT.Util.CloneTable( clipboard.Paths )
	end
	
	EHT.Biz.ApplyGroupItemMatching( group )
	EHT.UI.RefreshSelection()
	EHT.UI.ConfirmPasteLocation( group, function()
		EHT.Biz.CustomAdjustSelectedFurniture( EHT.PROCESS_NAME.PASTE_CLIPBOARD_FROM_HOUSE ) --, OnAdjustPastedFurniture )
		EssentialHousingHub:IncUMTD("n_spas", 1)
	end )
end

function EHT.Biz.PasteClipboardFromHouse( rotateWithPlayer, skipMissingItems )
	if nil == rotateWithPlayer then rotateWithPlayer = IsShiftKeyDown() end
	if nil == skipMissingItems then skipMissingItems = false end

	local house, group = EHT.Data.GetCurrentHouse()
	if nil == house or nil == group then
		EHT.UI.ShowAlertDialog( "Must be in a House", "You must be in a house to paste the clipboard." )
		return
	end

	local clipboard = EHT.SavedVars.Clipboard
	if nil == clipboard or 0 >= #clipboard then
		EHT.UI.ShowAlertDialog( "Clipboard Empty", "The clipboard is empty." )
		return
	end

	local matches = EHT.Biz.MatchAndUpdateFurniture( clipboard )
	local total = #clipboard
	local failed = total - #matches

	if not skipMissingItems and 0 < failed then
		if failed < total then
			EHT.UI.ShowConfirmationDialog(
				"Missing Items",
				string.format( "WARNING:\n%d of the %d clipboard items could not be matched to any items in the house.\n\nDo you wish to continue with a partial paste?", failed, total ),
				function()
					EHT.Biz.PasteClipboardFromHouse( rotateWithPlayer, true )
				end )
		else
			EHT.UI.ShowAlertDialog(
				"Missing Items",
				string.format( "ERROR:\nNone of the %d clipboard items could be matched to any items in the house.", total ) )
		end

		return
	end

	group = EHT.Biz.ResetSelection( true )

	for index, item in ipairs( matches ) do
		table.insert( group, item )
	end

	if clipboard.Paths then
		group.Paths = EHT.Util.CloneTable( clipboard.Paths )
	end

	EHT.Biz.ApplyGroupItemMatching( group )
	EHT.UI.RefreshSelection()
	EHT.UI.ConfirmPasteLocation( group, function()
		EHT.Biz.CustomAdjustSelectedFurniture( EHT.PROCESS_NAME.PASTE_CLIPBOARD_FROM_HOUSE ) --, OnAdjustPastedFurniture )
		EssentialHousingHub:IncUMTD("n_spas", 1)
	end )
end

function EHT.Biz.PrevalidatePasteClipboardFromInventory( rotateWithPlayer, skipMissingItems )
	if EHT.Biz.IsProcessRunning() then return false end

	local house, group = EHT.Data.GetCurrentHouse()
	if nil == house or nil == group then return false end

	local clipboard = EHT.SavedVars.Clipboard
	if nil == clipboard or 0 >= #clipboard then
		d( "Clipboard is empty." )
		EHT.UI.PlaySoundFailure()
		return false
	end

	local bagCounts = EHT.Housing.GetBagFurnitureCounts( nil, true )
	local clipCounts = EHT.Housing.GetListFurnitureCounts( clipboard, false )

	if clipCounts then
		local exceededLimits = EHT.Housing.PrevalidateItemLimits( clipCounts )
		if exceededLimits and 0 < #exceededLimits then
			if not suppressMessage then
				local msg = "Pasting this clipboard would require additional item slots:\n"

				for index, limit in ipairs( exceededLimits ) do
					msg = msg .. string.format( "\n* %s (x%d)", limit.Name or "n/a", -1 * ( limit.Amount or 0 ) )
				end

				d( msg )
				EHT.UI.PlaySoundFailure()
				EHT.UI.ShowAlertDialog( "", msg )
			end

			return false
		end
	end

	if not skipMissingItems and bagCounts and clipCounts then
		local missing = 0

		for link, count in pairs( clipCounts ) do
			local itemName = EHT.Housing.GetFurnitureLinkName( link )
			local bagCount = bagCounts[ itemName ] or 0
			local itemCount = count - bagCount

			if 0 < itemCount then
				df( "Missing %s x %s %s.", tostring( itemCount ), zo_iconFormat( GetItemLinkIcon( link ) ), link )
				missing = missing + itemCount
			end
		end

		if 0 < missing then
			EHT.UI.PlaySoundFailure()
			EHT.UI.ShowConfirmationDialog(
				"Paste Failed",
				string.format(
					"%d of the %d clipboard items cannot be found in your inventory, bank or storage containers.\n" ..
					"Review your Chat window for details.\n\n" ..
					"Continue with a partial paste?", missing or 0, #clipboard or 0 ),
				function() EHT.Biz.PasteClipboardFromInventory( rotateWithPlayer, true ) end
			)

			return false
		end
	end

	return true
end

function EHT.Biz.PasteClipboardFromInventory( rotateWithPlayer, skipMissingItems )
	if not EHT.Biz.PrevalidatePasteClipboardFromInventory( rotateWithPlayer, skipMissingItems ) then return nil end
	if nil == rotateWithPlayer then rotateWithPlayer = IsShiftKeyDown() end

	local house, group = EHT.Data.GetCurrentHouse()
	local clipboard = EHT.Util.CloneTable( EHT.SavedVars.Clipboard )
	group = EHT.Biz.ResetSelection( true )

	EHT.Biz.StartProcess( EHT.PROCESS_NAME.PASTE_CLIPBOARD_FROM_INVENTORY )
	local data = EHT.ProcessData
	data.Index = 0
	data.Group = group
	data.Clipboard = clipboard
	data.Total = #clipboard
	data.Pasted = 0
	data.Failed = 0
	data.FailedItems = { }
	data.Rotate = rotateWithPlayer
	data.History = { Op = EHT.CONST.CHANGE_TYPE.PLACE, Id = 0, Link = "Multiple Items", Batch = { } }

--	EHT.Biz.ApplyGroupItemMatching( clipboard )
	EHT.UI.RefreshSelection()
	EHT.UI.ConfirmPasteLocation( clipboard, function()
		EHT.Biz.ScheduleProcessActivity( EHT.Biz.PasteClipboardFromInventoryProcess )
		EssentialHousingHub:IncUMTD("n_spas", 1)
	end )
end

function EHT.Biz.PasteClipboardFromInventoryComplete()
	local data = EHT.ProcessData or { }

	do
		local updatedPaths = data.UpdatedPaths
		if updatedPaths then
			local id, info = nil, nil

			local function UpdatePathSettings()
				id, info = next( updatedPaths, id )
				if not id or not info then
					EVENT_MANAGER:UnregisterForUpdate( "EHT.PasteClipboardFromInventoryComplete" )
					data.UpdatedPaths = nil
					EHT.Biz.PasteClipboardFromInventoryComplete()
				end

				EHT.Housing.SetFurniturePathInfo( id, info )
			end

			EVENT_MANAGER:RegisterForUpdate( "EHT.PasteClipboardFromInventoryComplete", 200, UpdatePathSettings )
			return
		end
	end

	if data.Pasted >= data.Total and 0 == #data.FailedItems then
		df( "Pasted %s items.", tostring( data.Pasted ) )
	else
		for index, item in ipairs( data.FailedItems ) do
			if item and item.Link then
				df( "%s. %s not found in your inventory, bank or storage containers.", tostring( index ), item.Link )
			end
		end

		if 0 < data.Failed then EHT.UI.PlaySoundFailure() end
		EHT.UI.ShowAlertDialog( "Paste Complete", string.format( "Pasted %d of %d item(s).\n\n%d item(s) cannot be found in your inventory, bank or storage containers.\nReview your Chat window for details.", data.Pasted or 0, data.Total or 0, #data.FailedItems ) )
	end

	local historyBatch = data.History.Batch
	if nil ~= historyBatch and 0 < #historyBatch then EHT.CT.AddHistory( data.History ) end

	EHT.UI.ShowToolDialog()
	EHT.UI.RefreshHistory()
	EHT.Biz.EndProcess()
end

function EHT.Biz.PasteClipboardFromInventoryProcess( processId )
	local data = EHT.ProcessData
	if not EHT.Biz.CheckCurrentProcessActivity( processId ) or nil == data then
		EHT.Biz.EndProcess()
		return nil
	end

	local clipboard = data.Clipboard
	if nil == clipboard or 0 >= #clipboard then
		d( "Clipboard is empty." )
		EHT.Biz.EndProcess()
		return nil
	end

	local updatedPaths = data.UpdatedPaths
	if not updatedPaths then
		updatedPaths = { }
		data.UpdatedPaths = updatedPaths
	end

	local paths = clipboard.Paths

	repeat
		local index = ( data.Index or 0 ) + 1
		if index > #clipboard then
			EHT.Biz.PasteClipboardFromInventoryComplete()
			return nil
		end

		EHT.Biz.SetProcessProgress(	index / data.Total )

		local item = clipboard[ index ]
		local bagId, slotId = nil, nil
		local isEffect = nil ~= item.EffectType
		local pathFurnitureId, pathIndex = EHT.Housing.GetFurnitureIdInfo( item.Id )
		data.Index = index

		if nil == pathIndex and nil == item.CollectibleId and not isEffect then
			bagId, slotId = EHT.Housing.FindInventoryFurniture( item.Link )

			if not bagId or not slotId then
				data.Failed = data.Failed + 1
				table.insert( data.FailedItems, item )
			end
		end

		if isEffect or item.CollectibleId or slotId or pathIndex then
			local x, y, z, pitch, yaw, roll = item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll
			local effectType, groups, metaData = item.EffectType, item.Groups, item.MetaData
			local sizeX, sizeY, sizeZ = item.SizeX, item.SizeY, item.SizeZ
			local color, alpha, contrast = item.Color, item.Alpha, item.Contrast
			local speed, delayTime = item.Speed, item.DelayTime
			local result = nil
			local newEffect = nil

			pitch, yaw, roll = EHT.Housing.CorrectGimbalLock( pitch, yaw, roll, false, item.Id )

			if nil ~= pathFurnitureId and nil ~= pathIndex then
				local sFurnitureId = string.fromId64( pathFurnitureId )
				updatedPaths[ sFurnitureId ] = paths and paths[ sFurnitureId ] or nil

				local function onComplete()
					EHT.Biz.ScheduleProcessActivity( EHT.Biz.PasteClipboardFromInventoryProcess, 1 )
				end

				local result = EHT.Housing.SetOrPlaceFurnitureAndPathNode( onComplete, pathFurnitureId, pathIndex, x, y, z, yaw, speed, delayTime )
				if result ~= HOUSING_REQUEST_RESULT_SUCCESS then
					data.Failed = data.Failed + 1
					table.insert( data.FailedItems, item )
				end
				
				return
			else
				if isEffect then
					newEffect = EHT.Data.RestoreEffectRecord( nil, effectType, x, y, z, pitch, yaw, roll, sizeX, sizeY, sizeZ, color, alpha or 1, groups, metaData, contrast or 1 )
					result = ( nil ~= newEffect ) and HOUSING_REQUEST_RESULT_SUCCESS or nil
				elseif nil == item.CollectibleId then
					result = EHT.Housing.PlaceItem( bagId, slotId, x, y, z, pitch, yaw, roll )
				else
					result = EHT.Housing.PlaceCollectible( item.CollectibleId, x, y, z, pitch, yaw, roll )
				end

				if result ~= HOUSING_REQUEST_RESULT_SUCCESS then
					data.Failed = data.Failed + 1
					table.insert( data.FailedItems, item )
					EHT.Biz.ScheduleProcessActivity( EHT.Biz.PasteClipboardFromInventoryProcess, EHT.CONST.HOUSING_REMOVE_DELAY )
				end
			end

			return
		end
	until 1 == 0
end

---[ Operations : Scene Management ]---

function EHT.Biz.OnAnimationChanged()
	EHT.Biz.UpdateSceneNotification()

	if nil ~= EHT.UI.ToolDialog and not EHT.UI.ToolDialog.Window:IsHidden() and EHT.UI.GetCurrentToolTab() == EHT.CONST.TOOL_TABS.ANIMATE then
		EHT.UI.ShowToolTab( EHT.CONST.TOOL_TABS.ANIMATE )
		EHT.UI.EnableToolDialog()
		EHT.UI.UpdateKeybindStrip()
		EHT.UI.RefreshSelection()
	end
end

function EHT.Biz.StopSceneRecording()
	if EHT.RecordingSceneFrames then
		EVENT_MANAGER:UnregisterForUpdate( EHT.STATE_CHECK_ID )
		EHT.RecordingSceneFrames = false
		EHT.UI.ClearPersistentNotification( "SceneRecording" )
		EHT.Biz.OnAnimationChanged()
		EHT.UI.ShowAlertDialog( "Recording Stopped", "Animation scene recording has stopped.", function() end )
	end
end

function EHT.Biz.ResetScene()
	EHT.Biz.StopSceneRecording()
	EHT.Data.ResetScene()
	EHT.Biz.OnAnimationChanged()
end

function EHT.Biz.CheckForMissingSceneItems( scene )
	if nil == scene then _, _, scene = EHT.Data.GetCurrentHouse() end
	if nil == scene or nil == scene.Group then return end

	local missing = 0

	for _, furniture in ipairs( scene.Group ) do
		if nil ~= furniture and nil ~= furniture.Id and not EHT.Housing.IsValidFurnitureId( furniture.Id, nil, furniture.Link ) then
			missing = missing + 1
		end
	end

	if 0 < missing then
		EHT.UI.ShowWarning( string.format( "%d item(s) missing.", missing ) )
	else
		EHT.UI.ClearWarning()
	end
end

function EHT.Biz.LoadScene( sceneName )
	EHT.Biz.StopSceneRecording()

	if nil == sceneName then EHT.UI.ShowAlertDialog( "Invalid Scene Name", "Scene Name is empty or invalid.", function() end ) return nil end
	sceneName = string.lower( EHT.Util.Trim( sceneName ) )
	if "" == sceneName then EHT.UI.ShowAlertDialog( "Invalid Scene Name", "Scene Name is empty or invalid.", function() end ) return nil end
	if sceneName == EHT.CONST.SCENE_DEFAULT then EHT.UI.ShowAlertDialog( "Invalid Scene Name", "Scene Name is invalid.", function() end ) return nil end

	local house = EHT.Data.GetCurrentHouse()
	if nil == house then return nil end

	local scene = EHT.Data.GetScene( sceneName )
	if nil == scene then return nil end

	scene = EHT.Util.CloneTable( scene )
	scene.FrameIndex = 1
	house.Scenes[ EHT.CONST.SCENE_DEFAULT ] = scene

	EHT.Biz.PlayScene( scene.FrameIndex, true )

	return scene
end

function EHT.Biz.SaveScene( sceneName )
	EHT.Biz.StopSceneRecording()

	if nil == sceneName then EHT.UI.ShowAlertDialog( "Invalid Scene Name", "Scene Name is empty or invalid.", function() end ) return nil end
	sceneName = string.lower( EHT.Util.Trim( sceneName ) )
	if "" == sceneName then EHT.UI.ShowAlertDialog( "Invalid Scene Name", "Scene Name is empty or invalid.", function() end ) return nil end
	if sceneName == EHT.CONST.SCENE_DEFAULT then EHT.UI.ShowAlertDialog( "Invalid Scene Name", "Scene Name is invalid.", function() end ) return nil end

	local house, _, scene = EHT.Data.GetCurrentHouse()
	if nil == house or nil == scene then return nil end

	scene.Name = sceneName
	
	local isNewScene = not house.Scenes[sceneName]
	house.Scenes[ sceneName ] = EHT.Util.CloneTable( scene )
	if isNewScene then
		EssentialHousingHub:IncUMTD("n_scc", 1)
	end

	EHT.Biz.OnAnimationChanged()

	return scene
end

function EHT.Biz.SetupNewScene()
	EHT.Biz.StopSceneRecording()
	EHT.Data.ResetScene()

	local house, group, scene = EHT.Data.GetCurrentHouse()
	if nil ~= group and nil ~= scene then
		local frame = EHT.Data.CreateFrame()
	end

	EHT.Biz.OnAnimationChanged()
	return scene
end

function EHT.Biz.SetupSceneFromCurrentGroup()
	EHT.Biz.StopSceneRecording()
	EHT.Data.ResetScene()

	local house, group, scene = EHT.Data.GetCurrentHouse()
	if nil ~= group and nil ~= scene then
		for index, item in ipairs( group ) do
			scene.Group[ index ] = EHT.Util.CloneFurniture( item )
		end

		local frame = EHT.Data.CreateFrame()
	end

	EHT.Biz.OnAnimationChanged()
	return scene
end

function EHT.Biz.AddToSceneFromCurrentGroup()
	EHT.Biz.StopSceneRecording()

	local house, group, scene = EHT.Data.GetCurrentHouse()
	if nil ~= group and nil ~= scene then

		if nil == scene.Group then scene.Group = { } end
		if nil == scene.Frames then scene.Frames = { } end

		for gIndex, gItem in ipairs( group ) do
			local matched = false

			for sIndex, sItem in ipairs( scene.Group ) do

				if sItem.Id == gItem.Id then
					matched = true
					break
				end

			end

			if not matched then
				scene.Group[ #scene.Group + 1 ] = EHT.Util.CloneFurniture( gItem )
			end
		end

		for frameIndex = 1, #scene.Frames do
			local frameState = scene.Frames[ frameIndex ].State

			for gIndex, gItem in ipairs( group ) do
				local matched = false

				for fIndex, fItem in ipairs( frameState ) do
					if fItem.Id == gItem.Id then
						matched = true
						break
					end
				end

				if not matched then
					frameState[ #frameState + 1 ] = EHT.Util.CloneSceneFrameFurniture( gItem )
				end
			end
		end

		EHT.Biz.UpdateSceneFrame()
	end

	return scene
end

function EHT.Biz.RemoveCurrentGroupFromScene()
	EHT.Biz.StopSceneRecording()

	local house, group, scene = EHT.Data.GetCurrentHouse()
	if nil ~= group and nil ~= scene then
		if nil == scene.Group then scene.Group = { } end
		if nil == scene.Frames then scene.Frames = { } end

		for gIndex, gItem in ipairs( group ) do
			local matchedIndex = 0

			for sIndex, sItem in ipairs( scene.Group ) do
				if sItem.Id == gItem.Id then
					matchedIndex = sIndex
					break
				end
			end

			if 0 < matchedIndex then
				table.remove( scene.Group, matchedIndex )
			end
		end

		for frameIndex = 1, #scene.Frames do
			local frameState = scene.Frames[ frameIndex ].State

			for gIndex, gItem in ipairs( group ) do
				local matchedIndex = 0

				for fIndex, fItem in ipairs( frameState ) do
					if fItem.Id == gItem.Id then
						matchedIndex = fIndex
						break
					end
				end

				if 0 < matchedIndex then
					table.remove( frameState, matchedIndex )
				end
			end
		end

		EHT.Biz.UpdateSceneFrame()
	end

	return scene
end

function EHT.Biz.SetupGroupFromCurrentScene()
	EHT.Biz.StopSceneRecording()

	local house, group, scene = EHT.Data.GetCurrentHouse()
	if nil ~= house and nil ~= scene and nil ~= scene.Group then

		EHT.Biz.ResetSelection( true )
		for index, item in ipairs( scene.Group ) do
			table.insert( group, EHT.Util.CloneFurniture( item ) )
		end

		EHT.UI.ShowToolTab( EHT.CONST.TOOL_TABS.SELECT )
	end

	return group
end

do
	local suppressRecursion = false

	function EHT.Biz.SuppressSceneFrameSound(suppress)
		suppressRecursion = suppress
	end

	function EHT.Biz.UpdateSceneFrameSound()
		if suppressRecursion then return false end
		if not EHT.UI.CanEditAnimation() then return false end

		local _, _, _, frame = EHT.Data.GetCurrentHouse()
		if nil == frame then return false end

		EHT.Biz.SuppressSceneFrameSound( true )

		local soundId = EHT.UI.GetSelectedFrameSound()
		frame.Sound = soundId

		if nil ~= soundId then
			PlaySound( soundId )
			if EHT.UI.AddRecentFrameSound( soundId ) then
				EHT.UI.ToolDialog.FrameSound:SetSelectedItem( string.format( "    %s", soundId ) )
			end
		end

		EHT.Biz.SuppressSceneFrameSound( false )

		return true
	end
end

function EHT.Biz.UpdateSceneFrame()
	local _, _, scene, frame = EHT.Data.GetCurrentHouse()
	if nil ~= scene and nil ~= scene.Group and nil ~= frame and nil ~= frame.State then
		-- Create Frame.State table entries for any newly added Furniture items.
		for index, furniture in ipairs( scene.Group ) do
			if index > #frame.State or frame.State[ index ].Id ~= furniture.Id then
				local matched = false

				for index2, f in ipairs( frame.State ) do
					if f.Id == furniture.Id then
						matched = true
						break
					end
				end

				if not matched then
					frame.State[ #frame.State + 1 ] = EHT.Util.CloneSceneFrameFurniture( furniture )
				end
			end
		end

		for index, furniture in ipairs( frame.State ) do
			if nil ~= furniture then
				local id = EHT.Housing.FindFurnitureId( furniture.Id )
				if nil ~= id then
					furniture.X, furniture.Y, furniture.Z, furniture.Pitch, furniture.Yaw, furniture.Roll = EHT.Housing.GetFurniturePositionAndOrientation( id )

					if EHT.Housing.IsEffectId( id ) then
						local effect = EHT.Data.GetEffectByRecordId( id )
						if effect then
							furniture.SizeX, furniture.SizeY, furniture.SizeZ = effect:GetSize()
							furniture.Color, furniture.Alpha = effect:GetCompressedColor()
						end
					else
						furniture.State = EHT.Housing.GetFurnitureState( id )
					end
				end
			end
		end

		EHT.UI.SetPersistentNotification( "SceneFrameUpdated", string.format( "Scene Frame %d Updated", scene.FrameIndex or 0 ), 2000 )
		EHT.Biz.SceneFrameNotification()
	end
end

function EHT.Biz.UpdateAllSubsequentFrameDurations()
	local _, _, scene, frame = EHT.Data.GetCurrentHouse()

	if nil ~= scene and nil ~= frame then
		local duration = frame.Duration
		if nil == duration then
			frame.Duration = EHT.CONST.SCENE_FRAME_DURATION_DEFAULT
			duration = frame.Duration
		end

		local startIndex = scene.FrameIndex + 1

		if startIndex <= #scene.Frames then
			for index = startIndex, #scene.Frames do
				scene.Frames[ index ].Duration = duration
			end
		end
	end
end

function EHT.Biz.InsertSceneFrame( index, isBefore )
	local newFrame = nil
	local house, group, scene, frame = EHT.Data.GetCurrentHouse()

	if nil ~= group and nil ~= scene then
		if nil == index then index = scene.FrameIndex end

		if index < 1 or index > #scene.Frames then
			index = 1
		elseif not isBefore then
			index = index + 1
		end

		if nil ~= frame then
			newFrame = EHT.Data.CreateFrame( nil, index, frame.Duration )
		else
			newFrame = EHT.Data.CreateFrame( nil, index )
		end

		scene.FrameIndex = index

		EHT.Biz.OnAnimationChanged()
	end

	return newFrame
end

function EHT.Biz.DeleteAllSceneFrames()
	if EHT.Biz.IsProcessRunning( true ) then
		if EHT.Biz.GetProcess() == EHT.PROCESS_NAME.PLAY_SCENE then
			EHT.Biz.EndProcess()
		else
			EHT.UI.PlaySoundFailure()
			return false
		end
	end

	local house, group, scene, frame = EHT.Data.GetCurrentHouse()
	if nil ~= scene then
		scene.Frames = { }
		EHT.Data.CreateFrame()
		scene.FrameIndex = 1
	end
	
	return true
end

function EHT.Biz.DeleteSceneFrame( index )
	if EHT.Biz.IsProcessRunning( true ) then
		if EHT.Biz.GetProcess() == EHT.PROCESS_NAME.PLAY_SCENE then
			EHT.Biz.EndProcess()
		else
			EHT.UI.PlaySoundFailure()
			return false
		end
	end

	local house, group, scene, frame = EHT.Data.GetCurrentHouse()
	if nil ~= group and nil ~= scene then
		if nil == index then index = scene.FrameIndex end
		if index < 1 or index > #scene.Frames then index = 1 end

		if index <= #scene.Frames then
			table.remove(scene.Frames, index)

			if 0 >= #scene.Frames then
				EHT.Data.CreateFrame()
				scene.FrameIndex = 1
			elseif 1 < index and index > #scene.Frames then
				scene.FrameIndex = scene.FrameIndex - 1
			end

			EHT.Biz.PlayScene( nil, true )
		end
	end

	return true
end

function EHT.Biz.MergeScenes( sceneName1, sceneName2, finalSceneName, loopFrames, callback, overwrite )

	if nil == callback then callback = function() end end

	EHT.Biz.StopSceneRecording()

	if nil == sceneName1 then sceneName1 = EHT.CONST.SCENE_DEFAULT end
	if nil == sceneName1 or nil == sceneName2 then callback( nil, string.format( "Two scenes must be specified." ) ) return nil end
	if nil == finalSceneName then callback( nil, string.format( "Scene Name must be specified." ) ) return nil end

	local house, group = EHT.Data.GetCurrentHouse()
	if nil == group and nil == scene then callback( nil, string.format( "You must be in a house." ) ) return nil end

	finalSceneName = string.lower( EHT.Util.Trim( finalSceneName ) )
	sceneName1 = string.lower( EHT.Util.Trim( sceneName1 ) )
	sceneName2 = string.lower( EHT.Util.Trim( sceneName2 ) )

	if "" == finalSceneName then callback( nil, string.format( "Scene Name cannot be blank." ) ) return nil end
	if "" == sceneName1 or "" == sceneName2 then callback( nil, string.format( "Scene Name cannot be blank." ) ) return nil end

	local scene1, scene2 = EHT.Data.GetScene( sceneName1 ), EHT.Data.GetScene( sceneName2 )
	if nil == scene1 then callback( nil, string.format( "Scene \"%s\" does not exist.", sceneName1 ) ) return nil end
	if nil == scene2 then callback( nil, string.format( "Scene \"%s\" does not exist.", sceneName2 ) ) return nil end

	if 0 >= #scene1.Frames then callback( nil, string.format( "Scene \"%s\" has no Frames.", sceneName1 ) ) return nil end
	if 0 >= #scene2.Frames then callback( nil, string.format( "Scene \"%s\" has no Frames.", sceneName2 ) ) return nil end

	local duplicates = { }

	for itemIndex1, item1 in ipairs( scene1.Group ) do
		for itemIndex2, item2 in ipairs( scene2.Group ) do
			if item1.Id == item2.Id then
				table.insert( duplicates, item1.Link )
			end
		end
	end

	if 0 < #duplicates then callback( nil, string.format( "Scenes share %d furniture item(s) and cannot be merged.", #duplicates ), duplicates ) return nil end
	duplicates = nil

	if overwrite then
		house.Scenes[ finalSceneName ] = nil
	else
		if nil ~= house.Scenes[ finalSceneName ] then
			EHT.UI.ShowConfirmationDialog(
				"Overwrite Target Scene?",
				string.format( "The target Scene \"%s\" already exists.\nOverwrite this Scene?", finalSceneName ),
				function()
					EHT.Biz.MergeScenes( sceneName1, sceneName2, finalSceneName, callback, true )
				end,
				function()
					callback( nil, "Target scene already exists." )
				end )
			return nil
		end
	end

	local scene = EHT.Data.CreateScene( finalSceneName )
	if nil == scene then callback( nil, string.format( "Failed to create target Scene." ) ) return nil end

	for _, item in ipairs( scene1.Group ) do
		table.insert( scene.Group, EHT.Util.CloneFurniture( item ) )
	end

	for _, item in ipairs( scene2.Group ) do
		table.insert( scene.Group, EHT.Util.CloneFurniture( item ) )
	end

	local maxFrame1, maxFrame2 = #scene1.Frames, #scene2.Frames
	local frameIndex, frameIndex1, frameIndex2 = 1, 1, 1
	local frameTime, frameTime1, frameTime2 = 0, 0, 0
	local frameMerged1, frameMerged2 = false, false
	local frame, frame1, frame2
	local prevFrameTime

	local frameStateIndex1, frameStateIndex2
	local maxFrameState1, maxFrameState2

	local sceneEnded1, sceneEnded2 = false, false

	while not sceneEnded1 or not sceneEnded2 do -- frameIndex1 <= maxFrame1 or frameIndex2 <= maxFrame2 do

		frame1, frame2 = scene1.Frames[ frameIndex1 ], scene2.Frames[ frameIndex2 ]
		if nil == frame1 and nil == frame2 then break end

		frameStateIndex1, frameStateIndex2 = 1, 1
		if nil ~= frame1 then maxFrameState1 = #frame1.State else maxFrameState1 = -1 end
		if nil ~= frame2 then maxFrameState2 = #frame2.State else maxFrameState2 = -1 end

		frame = { Duration = 0, State = { } }
		table.insert( scene.Frames, frameIndex, frame )

		while ( nil ~= frame1 and frameTime >= frameTime1 and frameStateIndex1 <= maxFrameState1 ) or ( nil ~= frame2 and frameTime >= frameTime2 and frameStateIndex2 <= maxFrameState2 ) do

			if nil ~= frame1 and frameTime >= frameTime1 and frameStateIndex1 <= maxFrameState1 then
				table.insert( frame.State, EHT.Util.CloneSceneFrameFurniture( frame1.State[ frameStateIndex1 ] ) )
				frameStateIndex1 = frameStateIndex1 + 1
			end

			if nil ~= frame2 and frameTime >= frameTime2 and frameStateIndex2 <= maxFrameState2 then
				table.insert( frame.State, EHT.Util.CloneSceneFrameFurniture( frame2.State[ frameStateIndex2 ] ) )
				frameStateIndex2 = frameStateIndex2 + 1
			end

		end

		frame.Sound = nil
		if nil ~= frame1 and nil ~= frame1.Sound then
			frame.Sound = frame1.Sound
		elseif nil ~= frame2 and nil ~= frame2.Sound then
			frame.Sound = frame2.Sound
		end

		if nil ~= frame1 and frameTime >= frameTime1 then
			frameTime1 = frameTime1 + frame1.Duration
			frameIndex1 = frameIndex1 + 1
		end

		if nil ~= frame2 and frameTime >= frameTime2 then
			frameTime2 = frameTime2 + frame2.Duration
			frameIndex2 = frameIndex2 + 1
		end

		prevFrameTime = frameTime

		if nil ~= frame1 then
			if nil ~= frame2 then
				frameTime = math.min( frameTime1, frameTime2 )
			else
				frameTime = frameTime1
			end
		else
			frameTime = frameTime2
		end

		frame.Duration = frameTime - prevFrameTime

		if frameIndex1 > maxFrame1 then
			sceneEnded1 = true
			if loopFrames then frameIndex1 = 1 end
		end

		if frameIndex2 > maxFrame2 then
			sceneEnded2 = true
			if loopFrames then frameIndex2 = 1 end
		end

		frameIndex = frameIndex + 1

	end

	if 0 < #scene.Frames then
		scene.Frames[ #scene.Frames ].Duration = frameTime - prevFrameTime
	end

	callback( scene )

end


function EHT.Biz.AppendScenes( sceneName1, sceneName2, finalSceneName, callback, overwrite )

	if nil == callback then callback = function() end end

	EHT.Biz.StopSceneRecording()

	if nil == sceneName1 then sceneName1 = EHT.CONST.SCENE_DEFAULT end
	if nil == sceneName1 or nil == sceneName2 then callback( nil, string.format( "Two scenes must be specified." ) ) return nil end
	if nil == finalSceneName then callback( nil, string.format( "Scene Name must be specified." ) ) return nil end

	local house, group = EHT.Data.GetCurrentHouse()
	if nil == group and nil == scene then callback( nil, string.format( "You must be in a house." ) ) return nil end

	finalSceneName = string.lower( EHT.Util.Trim( finalSceneName ) )
	sceneName1 = string.lower( EHT.Util.Trim( sceneName1 ) )
	sceneName2 = string.lower( EHT.Util.Trim( sceneName2 ) )

	if "" == finalSceneName then callback( nil, string.format( "Scene Name cannot be blank." ) ) return nil end
	if "" == sceneName1 or "" == sceneName2 then callback( nil, string.format( "Scene Name cannot be blank." ) ) return nil end

	local scene1, scene2 = EHT.Data.GetScene( sceneName1 ), EHT.Data.GetScene( sceneName2 )
	if nil == scene1 then callback( nil, string.format( "Scene \"%s\" does not exist.", sceneName1 ) ) return nil end
	if nil == scene2 then callback( nil, string.format( "Scene \"%s\" does not exist.", sceneName2 ) ) return nil end

	if 0 >= #scene1.Frames then callback( nil, string.format( "Scene \"%s\" has no Frames.", sceneName1 ) ) return nil end
	if 0 >= #scene2.Frames then callback( nil, string.format( "Scene \"%s\" has no Frames.", sceneName2 ) ) return nil end

	if overwrite then
		house.Scenes[ finalSceneName ] = nil
	else
		if nil ~= house.Scenes[ finalSceneName ] then
			EHT.UI.ShowConfirmationDialog(
				"Overwrite Target Scene?",
				string.format( "The target Scene \"%s\" already exists.\nOverwrite this Scene?", finalSceneName ),
				function()
					EHT.Biz.MergeScenes( sceneName1, sceneName2, finalSceneName, callback, true )
				end,
				function()
					callback( nil, "Target scene already exists." )
				end )
			return nil
		end
	end

	local duplicates = { }

	for itemIndex1, item1 in ipairs( scene1.Group ) do
		for itemIndex2, item2 in ipairs( scene2.Group ) do
			if item1.Id == item2.Id then
				duplicates[ item2.Id ] = true
			end
		end
	end

	local scene = EHT.Data.CreateScene( finalSceneName )
	if nil == scene then callback( nil, string.format( "Failed to create target Scene." ) ) return nil end

	for _, item in ipairs( scene1.Group ) do
		table.insert( scene.Group, EHT.Util.CloneFurniture( item ) )
	end

	for _, item in ipairs( scene2.Group ) do
		if not duplicates[ item.Id ] then
			table.insert( scene.Group, EHT.Util.CloneFurniture( item ) )
		end
	end

	local cframe, cstate

	for index, frame in ipairs( scene1.Frames ) do
		table.insert( scene.Frames, EHT.Util.CloneTable( frame ) )
	end

	for index, frame in ipairs( scene2.Frames ) do
		table.insert( scene.Frames, EHT.Util.CloneTable( frame ) )
	end

	callback( scene )

end


function EHT.Biz.CloneScene( houseId, sourceSceneName, finalSceneName, callback, overwrite )

	if nil == callback then callback = function() end end

	EHT.Biz.StopSceneRecording()

	if nil == houseId or nil == sourceSceneName then callback( nil, string.format( "Original Scene must be specified." ) ) return nil end
	if nil == finalSceneName then callback( nil, string.format( "New Scene Name must be specified." ) ) return nil end

	sourceSceneName = string.lower( EHT.Util.Trim( sourceSceneName ) )
	finalSceneName = string.lower( EHT.Util.Trim( finalSceneName ) )

	local sourceHouse = EHT.Data.GetHouseById( houseId )
	if nil == sourceHouse then callback( nil, string.format( "Source House not found." ) ) return nil end
	if nil == sourceHouse.Scenes or nil == sourceHouse.Scenes[ sourceSceneName ] then callback( nil, string.format( "Source Scene not found." ) ) return nil end

	local sourceScene = sourceHouse.Scenes[ sourceSceneName ]

	local house, group = EHT.Data.GetCurrentHouse()
	if nil == group then callback( nil, string.format( "You must be in a house." ) ) return nil end

	if overwrite then
		house.Scenes[ finalSceneName ] = nil
	else
		if nil ~= house.Scenes[ finalSceneName ] then
			EHT.UI.ShowConfirmationDialog(
				"Overwrite Target Scene?",
				string.format( "The target Scene \"%s\" already exists.\nOverwrite this Scene?", finalSceneName ),
				function()
					EHT.Biz.CopyScene( houseId, sourceSceneName, finalSceneName, callback, true )
				end,
				function()
					callback( nil, "Target scene already exists." )
				end )
			return nil
		end
	end

	local scene = EHT.Data.CreateScene( finalSceneName )
	if nil == scene then callback( nil, string.format( "Failed to create target Scene." ) ) return nil end

	scene.Group = EHT.Util.CloneTable( sourceScene.Group )
	scene.Frames = EHT.Util.CloneTable( sourceScene.Frames )

	-- Create a unique set of definitely not used furnitureIds to substitute for those referenced by the original Scene.

	local substIds = { }
	local substId = 0

	for _, item in ipairs( scene.Group ) do
		substId = substId - 1
		substIds[ item.Id ] = tostring( substId )
	end

	-- Substitute the mapped, unique furnitureIds through the cloned Scene's Group and Frames' States.

	for _, item in ipairs( scene.Group ) do
		item.Id = substIds[ item.Id ]
	end

	for _, frame in ipairs( scene.Frames ) do
		for _, state in pairs( frame.State ) do
			state.Id = substIds[ state.Id ]
		end
	end

	local x, y, z = EHT.Housing.InFrontOfPlayer()
	EHT.Biz.MoveScene( scene, x, y, z )

	callback( scene )
end

function EHT.Biz.MoveScene( scene, x, y, z )
	if nil == scene or nil == scene.Frames or ( nil == x and nil == y and nil == z ) then return nil end

	local origin = EHT.Housing.CalculateSceneOrigin( scene )
	if nil == origin then return nil end

	for frameIndex, frame in ipairs( scene.Frames ) do
		if nil ~= frame.State then
			for stateIndex, state in pairs( frame.State ) do
				if x then state.X = state.X - origin.X + x end
				if y then state.Y = state.Y - origin.Y + y end
				if z then state.Z = state.Z - origin.Z + z end
			end
		end
	end

	return scene
end

function EHT.Biz.ReverseSceneFrames()
	local _, group, scene = EHT.Data.GetCurrentHouse()
	if nil == scene or 0 >= #scene.Group then return false end

	local frames = { }
	for frameIndex = #scene.Frames, 1, -1 do
		table.insert( frames, scene.Frames[ frameIndex ] )
	end

	scene.Frames = frames
	return true
end

------[[ Operations : Scene Playback ]]------

function EHT.Biz.SceneFrameNotification()
	local _, _, scene = EHT.Data.GetCurrentHouse()
	if nil ~= scene then
		EHT.UI.SetPersistentNotification( "SceneFrame", string.format( "Scene Frame: %d of %d", scene.FrameIndex or 0, #scene.Frames or 0 ), 5 )
	else
		EHT.UI.ClearPersistentNotification( "SceneFrame" )
	end
end

function EHT.Biz.InsertPreScenePlaybackHistory( scene, singleFrame )
	if nil == scene then return false end

	local items

	if singleFrame then
		if nil == scene.FrameIndex or 1 > scene.FrameIndex or scene.FrameIndex > #scene.Frames then
			scene.FrameIndex = 1
		end
		if scene.FrameIndex > #scene.Frames then return false end

		items = EHT.Util.CloneTable( scene.Frames[ scene.FrameIndex ].State )
	else
		items = EHT.Util.CloneTable( scene.Group )
	end

	local history = { Op = EHT.CONST.CHANGE_TYPE.CHANGE, Id = 0, Link = "Multiple Items", Batch = { } }
	local historyBatch = history.Batch
	local itemHistory

	for index, item in ipairs( items ) do
		if nil ~= item then
			itemHistory = EHT.Data.CreateFurniture( item.Id )

			if nil ~= itemHistory then
				table.insert( historyBatch, EHT.CT.CreateHistory( EHT.CONST.CHANGE_TYPE.CHANGE, itemHistory, itemHistory, true ) )
			end
		end
	end

	if 0 < #historyBatch then
		EHT.CT.AddHistory( history )
	end

	return true
end

function EHT.Biz.UpdateSceneNotification()
	if EHT.RecordingSceneFrames then
		EHT.UI.SetPersistentNotification( "SceneRecording", "Recording Scene" )
	else
		EHT.UI.ClearPersistentNotification( "SceneRecording" )
	end

	EHT.Biz.SceneFrameNotification()
end

function EHT.Biz.RecordScene()
	if not EHT.RecordingSceneFrames then
		local _, _, scene = EHT.Data.GetCurrentHouse()
		if nil ~= scene then
			EHT.RecordingSceneFrames = true
			EHT.Biz.OnAnimationChanged()
			EHT.UI.ShowAlertDialog( "Recording Started", "Recording has started.\n\nClick [ Stop ] when you have finished." )

			return true
		end
	end

	return false
end

function EHT.Biz.StopScene()
	EHT.Biz.StopSceneRecording()

	if EHT.Biz.GetProcess() == EHT.PROCESS_NAME.PLAY_SCENE then
		EHT.ProcessData.Stop = true
		return true
	end

	return false
end

function EHT.Biz.RewindScene()
	EHT.Biz.StopSceneRecording()

	local isPlaying = EHT.Biz.GetProcess() == EHT.PROCESS_NAME.PLAY_SCENE
	if isPlaying then EHT.Biz.EndProcess() end

	local house, group, scene = EHT.Data.GetCurrentHouse()
	if nil == scene then return false end

	EHT.Biz.PlayScene( 1, not isPlaying )
	return true
end

function EHT.Biz.PlayNamedScene( sceneName, index, singleFrame, completeCallback )
	EHT.Biz.StopSceneRecording()

	if EHT.Biz.IsProcessRunning( true ) then return false end

	local house = EHT.Data.GetCurrentHouse()
	if nil == house then return false end

	local scene = EHT.Data.GetScene( sceneName )
	if nil == scene then return false end

	if nil == scene.FrameIndex or 1 > scene.FrameIndex then scene.FrameIndex = 1 end

	if nil ~= index and 1 <= index and #scene.Frames >= index then
		if #scene.Frames < index then return false end
		scene.FrameIndex = index
	else
		if #scene.Frames < scene.FrameIndex then return false end
	end

	EHT.Biz.StartProcess( EHT.PROCESS_NAME.PLAY_SCENE )
	EHT.ProcessData.HouseId = house.HouseId
	EHT.ProcessData.Scene = scene
	EHT.ProcessData.FrameStateIndex = 1
	EHT.ProcessData.FrameStateChanges = 0
	EHT.ProcessData.FrameStateDeferredDelay = 0
	EHT.ProcessData.SingleFrame = singleFrame
	EHT.ProcessData.Callback = completeCallback

	EHT.Biz.InsertPreScenePlaybackHistory( scene, singleFrame )
	EHT.Biz.ScheduleProcessActivity( EHT.Biz.PlaySceneProcess )
	EHT.Biz.OnAnimationChanged()
	
	return true
end

function EHT.Biz.PlayScene( index, singleFrame )
	EHT.Biz.StopSceneRecording()

	if EHT.Biz.IsProcessRunning( true ) then return false end

	local house, group, scene = EHT.Data.GetCurrentHouse()
	if nil == scene then return false end

	if nil == scene.FrameIndex or 1 > scene.FrameIndex then scene.FrameIndex = 1 end

	if nil ~= index and 1 <= index and #scene.Frames >= index then
		if #scene.Frames < index then return false end
		scene.FrameIndex = index
	else
		if #scene.Frames < scene.FrameIndex then return false end
	end

	if singleFrame and EHT.UI.ToolDialog and not ZO_CheckButton_IsChecked( EHT.UI.ToolDialog.PreviewToggle ) then
		EHT.Biz.OnAnimationChanged()
		return false
	end

	EHT.Biz.StartProcess( EHT.PROCESS_NAME.PLAY_SCENE )
	EHT.ProcessData.HouseId = house.HouseId
	EHT.ProcessData.Scene = scene
	EHT.ProcessData.FrameStateIndex = 1
	EHT.ProcessData.FrameStateChanges = 0
	EHT.ProcessData.FrameStateDeferredDelay = 0
	EHT.ProcessData.SingleFrame = singleFrame
	EHT.ProcessData.Stop = false

	EHT.Biz.InsertPreScenePlaybackHistory( scene, singleFrame )
	EHT.Biz.ScheduleProcessActivity( EHT.Biz.PlaySceneProcess )
	EHT.Biz.OnAnimationChanged()
	
	return true
end

function EHT.Biz.PlaySceneProcessComplete()
	local data = EHT.ProcessData
	if data then
		local callback, callbackData
		if data.Callback then
			callback, callbackData = data.Callback, data
		end

		EHT.Biz.EndProcess()
		EHT.Biz.OnAnimationChanged()

		if callback then
			callback( callbackData )
		end
	end
end

function EHT.Biz.PlaySceneProcess( processId )
	local data = EHT.ProcessData
	if not EHT.Biz.CheckCurrentProcessActivity( processId ) or nil == data then return nil end

	local scene = data.Scene
	if GetCurrentZoneHouseId() ~= data.HouseId or nil == scene or nil == scene.Frames or nil == scene.FrameIndex then
		EHT.Biz.PlaySceneProcessComplete()
		return nil
	end

	local updatedFurniture, stateChange, positionChange, effectChange = false, false, false, false

	if nil == data.FrameStateChanges then data.FrameStateChanges = 0 end
	if nil == data.FrameStateDeferredDelay then data.FrameStateDeferredDelay = 0 end
	
	if data.PathNodeOperationPending then
		if EHT.Biz.HasPendingFurnitureOperations() then
			EHT.Biz.ScheduleProcessActivity( EHT.Biz.PlaySceneProcess, 1 )
			return nil
		end

		data.PathNodeOperationPending = false
	end

	repeat
		local frame = scene.Frames[ scene.FrameIndex ]
		if nil == frame then
			EHT.Biz.PlaySceneProcessComplete()
			return nil
		end

		if 1 == data.FrameStateIndex then
			if frame.Sound then
				PlaySound( frame.Sound )
--[[
				local soundIndex = EHT.Sounds[ frame.Sound ]
				if soundIndex then
					EHT.Mapcast.BroadcastPlaySound( soundIndex )
				end
]]
			end
		end

		while data.FrameStateIndex <= #frame.State do
			local furniture = frame.State[ data.FrameStateIndex ]

			if nil == furniture then
				break
			else
				local id = furniture.Id
				local existingId = EHT.Housing.FindFurnitureId( id )

				if nil ~= existingId then
					if EHT.Housing.IsEffectId( id ) then
						effectChange = true
						positionChange = false
						stateChange = false
					else
						--local x, y, z, pitch, yaw, roll = EHT.Housing.GetKnownFurniturePositionAndOrientation( id )
						local x, y, z, pitch, yaw, roll = EHT.Housing.GetFurniturePositionAndOrientation( id )
						effectChange = false
						positionChange = EHT.Housing.HasFurnitureChanged( x, y, z, pitch, yaw, roll, nil, nil, nil, nil, nil, furniture.X, furniture.Y, furniture.Z, furniture.Pitch, furniture.Yaw, furniture.Roll, nil, nil, nil, nil, nil )
						stateChange = nil ~= furniture.State and EHT.Housing.GetFurnitureState( id ) ~= furniture.State
					end

					if effectChange then
						updatedFurniture = true
						EHT.Housing.SetFurniturePositionAndOrientation( id, furniture.X, furniture.Y, furniture.Z, furniture.Pitch, furniture.Yaw, furniture.Roll )

						local effect = EHT.Data.GetEffectByRecordId( id )
						if effect then
							if furniture.SizeX or furniture.SizeY or furniture.SizeZ then
								effect:SetSize( furniture.SizeX, furniture.SizeY, furniture.SizeZ )
							end
							if furniture.Color and furniture.Alpha then
								effect:SetCompressedColor( furniture.Color, furniture.Alpha )
							end
						end

						EHT.Handlers.OnFurnitureChanged( furniture )
					elseif positionChange or stateChange then
						if positionChange then
							updatedFurniture = true
							EHT.Housing.SetFurniturePositionAndOrientation( id, furniture.X, furniture.Y, furniture.Z, furniture.Pitch, furniture.Yaw, furniture.Roll )
							EHT.Handlers.OnFurnitureChanged( furniture )

							if EHT.Housing.IsFurniturePathNodeId( id ) then
								data.PathNodeOperationPending = true
							end

							data.FrameStateChanges = data.FrameStateChanges + 1
							data.FrameStateDeferredDelay = data.FrameStateDeferredDelay + EHT.CONST.HOUSING_REQUEST_DELAY_MIN
						end

						if stateChange then
							updatedFurniture = true
							EHT.Housing.SetFurnitureState( id, furniture.State )

							data.FrameStateChanges = data.FrameStateChanges + 1
							data.FrameStateDeferredDelay = data.FrameStateDeferredDelay + EHT.CONST.HOUSING_STATE_REQUEST_DELAY_MIN
						end

						if data.PathNodeOperationPending or data.FrameStateDeferredDelay >= EHT.Setup.GetMaxDeferredEditDelay() then
							data.FrameStateIndex = data.FrameStateIndex + 1
							break
						end
					end
				end
			end

			data.FrameStateIndex = data.FrameStateIndex + 1
		end

		if updatedFurniture then -- and data.FrameStateIndex < #frame.State 
			EHT.Biz.ScheduleProcessActivity( EHT.Biz.PlaySceneProcess, data.FrameStateDeferredDelay )
			data.FrameStateDeferredDelay = 0
			return nil
		elseif data.SingleFrame or data.Stop then
			EHT.Biz.CallLater( EHT.Biz.PlaySceneProcessComplete, data.FrameStateDeferredDelay )
			data.FrameStateDeferredDelay = 0
			return nil
		else
			if nil == frame.Duration or 0 >= frame.Duration then frame.Duration = EHT.CONST.SCENE_FRAME_DURATION_DEFAULT end
			local frameDuration = math.floor( frame.Duration ) - ( EHT.CONST.HOUSING_REQUEST_DELAY_MIN * data.FrameStateChanges ) + data.FrameStateDeferredDelay
			if 0 > frameDuration then frameDuration = 0 end

			data.FrameStateChanges = 0
			data.FrameStateIndex = 1
			data.FrameStateDeferredDelay = 0

			if ( scene.FrameIndex + 1 ) <= #scene.Frames then
				scene.FrameIndex = scene.FrameIndex + 1
			else
				if scene.Loop then
					scene.FrameIndex = 1
				else
					EHT.Biz.PlaySceneProcessComplete()
					return nil
				end
			end

			EHT.Biz.OnAnimationChanged()
			if 0 < frameDuration then
				EHT.Biz.ScheduleProcessActivity( EHT.Biz.PlaySceneProcess, frameDuration )
				return nil
			end
		end
	until updatedFurniture

	EHT.Biz.PlaySceneProcessComplete()
end

---[ Operations : Group Management ]---

function EHT.Biz.GetInvalidGroupItemList( group )
	local invalidItems = { }

	if "table" == type( group ) then
		for index, item in ipairs( group ) do
			if not EHT.Housing.IsFurniturePathNodeId( item.Id ) and not EHT.Housing.IsValidFurnitureId( item.Id, item.ItemId, item.Link ) then
				local link = ( item.Link and "" ~= item.Link ) and item.Link or EHT.Housing.GetFurnitureItemIdLink( item.ItemId )
				if link then
					local count = invalidItems[ link ] or 0
					invalidItems[ link ] = count + 1
				end
			end
		end
	end

	return invalidItems
end

function EHT.Biz.SubstituteFurnitureId( house, oldId, newId )
	local house = EHT.Data.GetCurrentHouse()
	if nil == house then return nil end
	local replacements = 0
--d("SubstituteFurnitureId")
--df("old: %s (%s)", tostring( oldId ), type( oldId ))
--df("new: %s (%s)", tostring( newId ), type( newId ))
	for groupName, group in pairs( house.Groups ) do
		for index, item in ipairs( group ) do
			if item.Id == oldId then
--df("Group: %s (%s)", groupName, tostring( item.Id ))
				item.Id = newId
				replacements = replacements + 1
				break
			end
		end
	end

	for backupIndex, backup in pairs( house.Backups ) do
		for index, backupItem in ipairs( backup.Items ) do
			local item = EHT.Biz.DeserializeBackupItem( backupItem )
			if item.Id == oldId then
--df("Backup: %s (%s)", tostring( backupIndex ), tostring( item[1] ))
				item.Id = newId
				backup.Items[index] = EHT.Biz.SerializeBackupItem( item )
				replacements = replacements + 1
				break
			end
		end
	end

	for sceneName, scene in pairs( house.Scenes ) do
		for _, furniture in ipairs( scene.Group ) do
			if furniture.Id == oldId then
--df("Scene: %s (%s)", tostring( sceneName ), tostring( furniture.Id ))
				furniture.Id = newId
				replacements = replacements + 1
				break
			end
		end

		for _, frame in ipairs( scene.Frames ) do
			for _, furniture in ipairs( frame.State ) do
				if furniture.Id == oldId then
					furniture.Id = newId
					replacements = replacements + 1
					break
				end
			end
		end
	end

	local triggers = EHT.Data.GetTriggers()

	if nil ~= triggers then
		for index, trigger in pairs( triggers ) do
			if trigger.Condition.FurnitureId == oldId then
				trigger.Condition.FurnitureId = newId
				replacements = replacements + 1
			end
		end
	end

	return replacements
end

function EHT.Biz.ReplaceMissingItems( group, callback, useInventoryItems, useHouseItems )
	if nil == useInventoryItems then
		useInventoryItems = true
	end
	if nil == useHouseItems then
		useHouseItems = false
	end
	if EHT.Biz.IsProcessRunning() then
		return false
	end

	local currentTab = EHT.UI.GetCurrentToolTab()
	if nil == group and currentTab ~= EHT.CONST.TOOL_TABS.SELECT and currentTab ~= EHT.CONST.TOOL_TABS.ANIMATE then return false end

	EHT.Biz.StartProcess( EHT.PROCESS_NAME.REPLACE_MISSING_ITEMS )
	local data = EHT.ProcessData
	data.HouseId = EHT.Housing.GetHouseId()
	data.HouseOwner = EHT.Housing.GetHouseOwner()
	data.Index = 1
	data.Missing = 0
	data.Replaced = 0
	data.UseHouseItems = useHouseItems
	data.UseInventoryItems = useInventoryItems
	data.Callback = callback

	if "table" ~= type( group ) then
		local house, cGroup, cScene = EHT.Data.GetCurrentHouse()
		if currentTab == EHT.CONST.TOOL_TABS.SELECT then
			data.Group = cGroup
			data.ReplaceForGroup = true
		elseif currentTab == EHT.CONST.TOOL_TABS.ANIMATE then
			data.Scene = cScene
			data.Group = cScene.Group
			data.ReplaceForScene = true
		end
	else
		data.Group = group
		data.ReplaceForCustomGroup = true
	end

	local group = data.Group
	local validIds = { }
	data.ValidIds = validIds

	for _, item in pairs( group ) do
		local sid = string.fromId64( item.Id )
		if EHT.Housing.IsFurniturePathNodeId( item.Id ) or EHT.Housing.IsValidFurnitureId( sid, item.ItemId, item.Link ) then
			validIds[ sid ] = true
		end
	end

	data.Total = #data.Group
	data.HistoryChanges = { Op = EHT.CONST.CHANGE_TYPE.CHANGE, Id = 0, Link = "Multiple Items", Batch = { } }
	data.HistoryPlacements = { Op = EHT.CONST.CHANGE_TYPE.PLACE, Id = 0, Link = "Multiple Items", Batch = { } }

	EHT.Biz.ScheduleProcessActivity( EHT.Biz.ReplaceMissingItemsProcess )
	return true
end

function EHT.Biz.ReplaceMissingItemsProcess( processId )
	local data = EHT.ProcessData
	if not EHT.Biz.CheckCurrentProcessActivity( processId ) or not data then
		return nil
	end

	if not data.Group or EHT.Housing.GetHouseId() ~= data.HouseId or EHT.Housing.GetHouseOwner() ~= data.HouseOwner then
		EHT.Biz.EndProcess()
		return nil
	end

	local index, group, validIds = data.Index, data.Group, data.ValidIds
	local pX, pY, pZ = GetPlayerWorldPositionInHouse()

	while index <= #group do
		local item = group[ index ]
		local percentComplete = index / data.Total
		EHT.Biz.SetProcessProgress(	percentComplete )

		if item and item.Id and ( item.ItemId or item.Link ) then
			local sid = string.fromId64( item.Id )
			local itemId = item.ItemId
			local link = item.Link

			if not itemId then
				itemId = EHT.Housing.GetFurnitureLinkItemId( link )
			elseif not link or link == "" then
				link = EHT.Housing.GetFurnitureItemIdLink( itemId )
			end

			if not validIds[ sid ] then
				data.Missing = data.Missing + 1
				data.Index = index

				if EHT.Housing.IsEffectId( item.Id ) then
					local effectRecord = EHT.Data.RestoreEffectRecord( item.Id, item.EffectType, item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll, item.SizeX, item.SizeY, item.SizeZ, item.Color, item.Alpha, item.Groups, item.MetaData, item.Contrast )
					if effectRecord and effectRecord.Id then
						local matchSid = string.fromId64( effectRecord.Id )
						validIds[ matchSid ] = true
						-- item.Id = matchSid
						-- EHT.Biz.SubstituteFurnitureId( house, sid, matchSid )

						data.Index = index + 1
						data.Replaced = data.Replaced + 1
						EHT.Biz.ScheduleProcessActivity( EHT.Biz.ReplaceMissingItemsProcess )
						return
					end
				else
					local x, y, z, pitch, yaw, roll = item.X, item.Y, item.Z, item.Pitch or 0, item.Yaw or 0, item.Roll or 0
					if not x or not y or not z or 0 == x or 0 == y or 0 == z then
						x, y, z = pX, pY, pZ
					end

					if EHT.Housing.IsItemLinkCollectible( link ) or EHT.Housing.IsItemIdCollectible( itemId ) then
						local collectibleId = GetCollectibleIdFromLink( link )

						if collectibleId and "" ~= collectibleId and 0 ~= collectibleId then
							local result = EHT.Housing.PlaceCollectible( collectibleId, x, y, z, pitch, yaw, roll )
							if result == HOUSING_REQUEST_RESULT_SUCCESS then
								return
							end
						end

						local result = EHT.Housing.PlaceCollectible( itemId, x, y, z, pitch, yaw, roll )
						if result == HOUSING_REQUEST_RESULT_SUCCESS then
							return
						end
					else
						if data.UseHouseItems then
							local matches = EHT.Housing.FindFurnitureByProximity( itemId, x, y, z, nil, validIds )

							if matches and matches[1] and matches[1][1] then
								local id = matches[1][1]
								local matchSid = string.fromId64( id )
								local cx, cy, cz, cpitch, cyaw, croll = EHT.Housing.GetFurniturePositionAndOrientation( id )

								if EHT.Housing.HasFurnitureChanged( x, y, z, pitch, yaw, roll, nil, nil, nil, nil, nil, cx, cy, cz, cpitch, cyaw, croll, nil, nil, nil, nil, nil ) then
									EHT.Housing.SetFurniturePositionAndOrientation( id, x, y, z, pitch, yaw, roll )
									table.insert( EHT.ProcessData.HistoryChanges.Batch, EHT.CT.CreateHistory( EHT.CONST.CHANGE_TYPE.CHANGE, { Id = matchSid, X = cx, Y = cy, Z = cz, Pitch = cpitch, Yaw = cyaw, Roll = croll }, { Id = sid, X = x, Y = y, Z = z, Pitch = pitch, Yaw = yaw, Roll = roll } ) )
								end

								validIds[ matchSid ] = true
								item.Id = matchSid
								EHT.Biz.SubstituteFurnitureId( house, sid, matchSid )

								data.Index = index + 1
								data.Replaced = data.Replaced + 1
								EHT.Biz.ScheduleProcessActivity( EHT.Biz.ReplaceMissingItemsProcess )
								return
							end
						end

						if data.UseInventoryItems then
							local bagId, slotId = EHT.Housing.FindInventoryFurniture( link )

							if bagId and slotId and 0 ~= bagId then
								local result = EHT.Housing.PlaceItem( bagId, slotId, x, y, z, pitch, yaw, roll )

								if result == HOUSING_REQUEST_RESULT_SUCCESS then
									return
								end
							end
						end
					end
				end
			end
		end

		index = index + 1
	end

	if index > #group then
		local missing, replaced = data.Missing or 0, data.Replaced or 0
		local isCustomGroup, isGroup, isScene = data.ReplaceForCustomGroup, data.ReplaceForGroup, data.ReplaceForScene

		if EHT.ProcessData.HistoryPlacements and 0 < #EHT.ProcessData.HistoryPlacements.Batch then
			EHT.CT.AddHistory( EHT.ProcessData.HistoryPlacements )
		end

		if EHT.ProcessData.HistoryChanges and 0 < #EHT.ProcessData.HistoryChanges.Batch then
			EHT.CT.AddHistory( EHT.ProcessData.HistoryChanges )
		end

		EHT.UI.RefreshHistory()

		EHT.Biz.EndProcess()

		if isCustomGroup and data.Callback then
			data.Callback( group, missing, replaced )
			return
		end

		EHT.UI.ShowAlertDialog( "Missing Item Status", string.format( "Matched and replaced %d item(s) out of %d total missing item(s).", replaced, missing ) )

		if isGroup then
			EHT.UI.RefreshSelection()
		elseif isScene then
			data.Scene.FrameIndex = 1
			EHT.Biz.PlayScene( 1, true )
		end

		return
	end

	data.Index = index
	EHT.Biz.ScheduleProcessActivity( EHT.Biz.ReplaceMissingItemsProcess )
end

function EHT.Biz.SortGroup( ascending )
	local _, group = EHT.Data.GetCurrentHouse()
	if nil == group then return nil end

	local name
	for _, item in ipairs( group ) do
		if nil ~= item.ItemId then
			name = EHT.Housing.GetFurnitureItemIdName( item.ItemId )
		else
			name = EHT.Housing.GetFurnitureLinkName( item.Link )
		end
		item.Name = name
	end

	table.sort( group, function( itemA, itemB )
		if ascending then
			return itemA.Name < itemB.Name
		else
			return itemA.Name > itemB.Name
		end
	end )

	for _, item in ipairs( group ) do
		item.Name = nil
	end

	EHT.UI.RefreshSelection()
end

function EHT.Biz.SortGroupByDistance( ascending )
	local _, group = EHT.Data.GetCurrentHouse()
	if nil == group then return nil end

	local px, py, pz = GetPlayerWorldPositionInHouse()
	for _, item in ipairs( group ) do
		local x, y, z = EHT.Housing.GetFurnitureCenter( item.Id )
		item._distance = zo_distance3D( px, py, pz, x, y, z )
	end

	if ascending then
		table.sort( group, function( itemA, itemB )
			return itemA._distance < itemB._distance
		end )
	else
		table.sort( group, function( itemA, itemB )
			return itemA._distance > itemB._distance
		end )
	end

	for _, item in ipairs( group ) do
		item._distance = nil
	end

	EHT.UI.RefreshSelection()
end

function EHT.Biz.AlternateGroup( ascending )
	local _, group = EHT.Data.GetCurrentHouse()
	if nil == group then return nil end

	local nameGroups, nameGroup = { }, nil
	local name

	for _, item in ipairs( group ) do

		if nil ~= item.ItemId then
			name = EHT.Housing.GetFurnitureItemIdName( item.ItemId )
		else
			name = EHT.Housing.GetFurnitureLinkName( item.Link )
		end

		if nil == name then name = "_NIL_" end
		nameGroup = nameGroups[ name ]

		if nil == nameGroup then
			nameGroup = { }
			nameGroups[ name ] = nameGroup
		end

		table.insert( nameGroup, item )

	end

	local sortedNames = { }
	for nameKey, _ in pairs( nameGroups ) do
		table.insert( sortedNames, nameKey )
	end

	if ascending then
		table.sort( sortedNames, function( k1, k2 ) return k1 < k2 end )
	else
		table.sort( sortedNames, function( k1, k2 ) return k1 > k2 end )
	end

	local done, item = false, nil

	while nil ~= group[1] do
		table.remove( group, 1 )
	end

	repeat
		done = true
		for _, nameKey in ipairs( sortedNames ) do

			item = nameGroups[ nameKey ][ 1 ]
			if nil ~= item then
				table.remove( nameGroups[ nameKey ], 1 )
				table.insert( group, item )
				done = false
			end

		end
	until done

	EHT.UI.RefreshSelection()
end

function EHT.Biz.GetCurrentStateVersusGroupDeltas( groupName )
	local changed, groupOnly, houseOnly, unchanged = {}, {}, {}, {}
	local group = EHT.Data.GetGroup( groupName )

	if group then
		local houseItems, groupItems = {}, EHT.Util.CloneTable( group )
		local furnitureId = EHT.Housing.GetNextFurnitureId()
		while furnitureId do
			table.insert( houseItems, EHT.Data.CreateFurniture( furnitureId ) )
			furnitureId = EHT.Housing.GetNextFurnitureId( furnitureId )
		end

		for houseIndex = #houseItems, 1, -1 do
			local houseItem = houseItems[houseIndex]

			for groupIndex = #groupItems, 1, -1 do
				local groupItem = groupItems[groupIndex]

				if EHT.Housing.AreFurnitureIdsEqual( groupItem.Id, houseItem.Id ) then
					if not EHT.CT.AreStatesEqual( houseItem, groupItem ) then
						table.insert( changed, { house = houseItem, group = groupItem } )
					else
						table.insert( unchanged, groupItem )
					end

					table.remove( houseItems, houseIndex )
					table.remove( groupItems, groupIndex )
					break
				end
			end
		end

		groupOnly = groupItems
		houseOnly = houseItems
	end

	return changed, groupOnly, houseOnly, unchanged
end

function EHT.Biz.LoadGroup( groupName, loadPositions )
	if EHT.Biz.IsProcessRunning() then return nil end

	local house, group = EHT.Data.GetCurrentHouse()
	if nil == house or nil == group then return nil end

	if nil == groupName or "" == groupName then
		EHT.UI.ShowAlertDialog( "Choose a Selection", "Please choose a selection to load." )
		EHT.UI.PlaySoundFailure()
		return nil
	end

	local loadGroup = EHT.Data.GetGroup( groupName )
	if nil == loadGroup then
		df( "Saved selection not found: %s", tostring( groupName or "" ) )
		EHT.UI.PlaySoundFailure()
		return nil
	end

	EHT.Biz.ResetSelection( true )

	for key, item in pairs( loadGroup ) do
		if "table" == type( item ) then
			group[ key ] = EHT.Util.CloneTable( item )
		end
	end

	house.CurrentGroupName = groupName

	if loadPositions then
		local missing = 0

		for index, item in ipairs( group ) do
			if item.Id and not EHT.Housing.IsEffectId( item.Id ) and not EHT.Housing.IsFurniturePathNodeId( item.Id ) and not EHT.Housing.IsValidFurnitureId( item.Id, item.ItemId, item.Link ) then
				missing = missing + 1
			end
		end

		if 0 < missing then
			local msg = string.format( "|cff0000Warning: |cffff00%d |cffffffitem%s not found.\nClick |c9977ffFix Now|cffffff to replace these items.", missing, 1 == missing and "" or "s" )
			EHT.UI.DisplayNotification( msg )
		end

		EHT.Biz.AdjustSelectedFurniture( { X = 0, SkipUnchanged = true, }, 1 )
	else
		EHT.Data.UpdateGroupFurniture()
	end

	EHT.UI.RefreshSelection()

	return group
end

function EHT.Biz.RestoreGroup( group, callback )
	local house = EHT.Data.GetCurrentHouse()

	if nil == house or nil == group or "table" ~= type( group ) then
		if nil ~= callback then callback() end
		return false
	end

	return EHT.Biz.CustomAdjustFurniture( group, nil, nil, callback )
end

function EHT.Biz.RemoveGroup( groupName )
	if EHT.Biz.IsProcessRunning() then return nil end

	local ui = EHT.UI.ToolDialog
	if nil == ui then return end

	local house, group = EHT.Data.GetCurrentHouse()
	if nil == house or nil == group then return nil end

	local deletedGroup = EHT.Data.RemoveGroup( groupName )
	if nil == deletedGroup then
		EHT.UI.PlaySoundFailure()
		EHT.UI.ShowAlertDialog( "Choose a Selection", "Please choose a selection to delete." )
		return nil
	end

	EHT.Biz.ResetSelection()
	EHT.UI.TriggerChanged()
	EHT.UI.RefreshSelectionList()

	return deletedGroup
end

function EHT.Biz.SaveGroup( groupName, suppressDialogs, forceSave )
	if not forceSave and EHT.Biz.IsProcessRunning() then return nil end

	local house, group = EHT.Data.GetCurrentHouse()
	if nil == house or nil == group then return nil end

	if nil == groupName then groupName = EHT.UI.ToolDialog.SelectionName:GetText() end
	groupName = EHT.Util.Trim( groupName )

	if nil == groupName or "" == groupName then
		if not suppressDialogs then
			EHT.UI.PlaySoundFailure()
			EHT.UI.ShowAlertDialog( "Selection Name Required", "Please enter a selection name." )
		end

		return nil
	end

	EHT.Data.UpdateGroupFurniture()

	for previousGroupName, _ in pairs( house.Groups ) do
		if EHT.Util.CompareText( previousGroupName, groupName ) then
			house.Groups[ previousGroupName ] = nil
			break
		end
	end

	house.Groups[ groupName ] = EHT.Data.SerializeGroup( group )
	house.CurrentGroupName = groupName

	if not suppressDialogs then
		EHT.UI.ShowAlertDialog( "Selection Saved", string.format( "Saved selection as \"%s\".", tostring( groupName ) ) )
	end

	EHT.UI.RefreshSelectionList()
	EHT.UI.TriggerChanged()

	return group
end

function EHT.Biz.GetCurrentGroupName()
	local house = EHT.Data.GetCurrentHouse()
	if nil == house then return nil end

	return house.CurrentGroupName or ""
end

---[ Operations : Group Measurements ]---

function EHT.Biz.MeasureDimensions( group, callback, suppressMessage )
	if callback then
		zo_callLater( callback, 1 )
	end
	return true
end
--[[
	if EHT.Biz.IsProcessRunning( suppressMessage ) then return false end
	if nil == group then _, group = EHT.Data.GetCurrentHouse() end
	if nil == group or 0 >= #group then return false end
	if nil == EHT.SavedVars.Dimensions then EHT.SavedVars.Dimensions = { } end

	local dimensions = EHT.SavedVars.Dimensions
	local skipMeasurement = true

	for index, item in pairs( group ) do
		if not EHT.Housing.IsEffectId( item.Id ) then
			local itemId = EHT.Housing.GetFurnitureItemId( item.Id )

			if nil == itemId or nil == dimensions[ itemId ] then
				skipMeasurement = false
				break
			end
		end
	end

	if skipMeasurement then
		if nil ~= callback then
			zo_callLater( function() callback( dimensions ) end, 50 )
		end

		return true
	end

	group = EHT.Util.CloneTable( group )
	EHT.ProcessData.Index = 1
	EHT.ProcessData.Group = group
	EHT.ProcessData.Total = #group
	EHT.ProcessData.Callback = callback
	EHT.ProcessData.Dimensions = dimensions

	EHT.Biz.ScheduleProcessActivity( EHT.Biz.MeasureDimensionsProcess )

	return true
end
]]
--[[
	EHT.Biz.StartProcess( EHT.PROCESS_NAME.MEASURE_DIMENSIONS )

	group = EHT.Util.CloneTable( group )
	EHT.ProcessData.Index = 1
	EHT.ProcessData.Group = group
	EHT.ProcessData.Total = #group
	EHT.ProcessData.Callback = callback
	EHT.ProcessData.Dimensions = dimensions

	EHT.Biz.ScheduleProcessActivity( EHT.Biz.MeasureDimensionsProcess )

	return true
end

function EHT.Biz.MeasureDimensionsProcessComplete()
	local data = EHT.ProcessData

	if nil == data then
		EHT.Biz.EndProcess()
	else
		local callback, dimensions = data.Callback, data.Dimensions
		--if nil ~= dimensions then EHT.Util.MergeTables( dimensions, EHT.SavedVars.Dimensions ) end
		EHT.Biz.EndProcess()
		if nil ~= callback then callback( dimensions ) end
	end

	return nil
end

function EHT.Biz.MeasureDimensionsProcess( processId )
	local data = EHT.ProcessData
	if not EHT.Biz.CheckCurrentProcessActivity( processId ) or nil == data then return nil end

	local dimensions, group = data.Dimensions, data.Group
	if nil == group or 0 >= #group or nil == dimensions then
		EHT.Biz.MeasureDimensionsProcessComplete()
		return nil
	end

	local index, id, item = data.Index or 1, nil, nil
	local prevIndex, prevIndexCount = data.PrevIndex or 0, data.PrevIndexCount or 0

	repeat
		if index > #group or nil == group[ index ] then
			EHT.Biz.MeasureDimensionsProcessComplete()
			return nil
		end

		EHT.Biz.SetProcessProgress(	index / data.Total )

		if nil == data.PrevIndex or data.PrevIndex ~= index then
			data.PrevIndex = index
			data.PrevIndexCount = 1
		else
			data.PrevIndexCount = data.PrevIndexCount + 1

			if 10 < data.PrevIndexCount then
				index = index + 1
				data.Index = index
				data.PrevIndex = index
				data.PrevIndexCount = 1
			end
		end

		item = group[ index ]

		if nil ~= item and item.Id and not EHT.Housing.IsEffectId( item.Id ) then
			id = EHT.Housing.FindFurnitureId( item.Id )

			if nil ~= id and 0 ~= id then
				local itemId = EHT.Housing.GetFurnitureItemId( id )

				if nil ~= itemId and nil == dimensions[ itemId ] then
					local pitch, yaw, roll = EHT.Housing.GetFurnitureOrientation( id )

					if nil ~= pitch and nil ~= yaw and nil ~= roll then
						-- Avoid the strange -0 issue.
						if 0 ~= round( math.abs( pitch % math.rad( 360 ) ), 1 ) or 0 ~= round( math.abs( yaw % math.rad( 360 ) ), 1 ) or 0 ~= round( math.abs( roll % math.rad( 360 ) ), 1 ) then
							item.Pitch, item.Yaw, item.Roll = pitch, yaw, roll
							EHT.Housing.SetFurnitureOrientation( id, 0, 0, 0 )

							data.Index = index
							EHT.Biz.ScheduleProcessActivity( EHT.Biz.MeasureDimensionsProcess )

							return nil
						else
							local x, y, z = EHT.Housing.GetFurniturePosition( id )
							local minX, minY, minZ, maxX, maxY, maxZ = EHT.Housing.GetFurnitureWorldBounds( id )

							-- Avoid the strange -0 issue.
							x, y, z = math.abs( x ), math.abs( y ), math.abs( z )
							minX, minY, minZ, maxX, maxY, maxZ = math.abs( minX ), math.abs( minY ), math.abs( minZ ), math.abs( maxX ), math.abs( maxY ), math.abs( maxZ )

							if ( 0 ~= minX or 0 ~= maxX ) and ( 0 ~= minY or 0 ~= maxY ) and ( 0 ~= minZ or 0 ~= maxZ ) then
								local dim = { }

								dim[EHT.CONST.DIMENSION.X] = round( maxX - minX, 1 )
								dim[EHT.CONST.DIMENSION.Y] = round( maxY - minY, 1 )
								dim[EHT.CONST.DIMENSION.Z] = round( maxZ - minZ, 1 )
								dim[EHT.CONST.DIMENSION.OFFSET_X] = round( x - ( ( maxX + minX ) / 2 ), 1 )
								dim[EHT.CONST.DIMENSION.OFFSET_Y] = round( y - ( ( maxY + minY ) / 2 ), 1 )
								dim[EHT.CONST.DIMENSION.OFFSET_Z] = round( z - ( ( maxZ + minZ ) / 2 ), 1 )
								dimensions[ itemId ] = dim
							end

							if item.Pitch and item.Yaw and item.Roll then
								EHT.Housing.SetFurnitureOrientation( id, item.Pitch, item.Yaw, item.Roll )
							end

							data.Index = index + 1
							EHT.Biz.ScheduleProcessActivity( EHT.Biz.MeasureDimensionsProcess )

							return nil
						end
					end
				end
			end
		end

		index = index + 1
		data.Index = index
	until index > #group

	EHT.Biz.MeasureDimensionsProcessComplete()
end
]]
---[ Operations : Group Linking ]---

function EHT.Biz.LinkGroup( group, callback, suppressMessages )
	if "table" ~= type( group ) then
		_, group = EHT.Data.GetCurrentHouse()
		if nil == group or 0 >= #group then
			if not suppressMessages then
				EHT.UI.PlaySoundFailure()
				EHT.UI.ShowAlertDialog( "Link Group", "Selection is empty." )
			end

			return
		end
	end

	local furnitureGroup = {}
	for index, item in ipairs(group) do
		if "table" == type(item) and not EHT.Housing.IsEffectId(item.Id) then
			table.insert(furnitureGroup, item)
		end
	end

	if nil == furnitureGroup or 0 >= #furnitureGroup then
		if not suppressMessages then
			EHT.UI.PlaySoundFailure()
			EHT.UI.ShowAlertDialog( "Link Group", "Selection does not contain any furnishings." )
		end

		return
	end

	EHT.Biz.StartProcess(EHT.PROCESS_NAME.LINK_GROUP)

	EHT.ProcessData.Index = 0
	EHT.ProcessData.Group = furnitureGroup
	EHT.ProcessData.Total = #furnitureGroup

	EHT.Housing.LinkGroup(
		function(index, item)
			local data = EHT.ProcessData
			if "table" ~= type(data) then
				EHT.Biz.EndProcess()
				return false
			end
			
			if data.CancelProcess and not EHT.ProcessRollingBack then
				EHT.Biz.CancelProcessCallback()
				return false
			end

			if "number" == type(index) and "number" == type(data.Total) then
				EHT.Biz.SetProcessProgress(index / data.Total)
				return true
			end

			EHT.Biz.EndProcess()
			return false
		end,
		function()
			EHT.Biz.EndProcess()
			if "function" == type(callback) then
				callback()
			end
		end,
		furnitureGroup
	)
end

function EHT.Biz.UnlinkGroup( group, callback, suppressMessages )
	if "table" ~= type( group ) then
		_, group = EHT.Data.GetCurrentHouse()
		if nil == group or 0 >= #group then
			if not suppressMessages then
				EHT.UI.PlaySoundFailure()
				EHT.UI.ShowAlertDialog( "Unlink Group", "Selection is empty." )
			end

			return
		end
	end

	local furnitureGroup = { }
	for index, item in ipairs( group ) do
		if not EHT.Housing.IsEffectId( item.Id ) then
			table.insert( furnitureGroup, item )
		end
	end

	if nil == furnitureGroup or 0 >= #furnitureGroup then
		if not suppressMessages then
			EHT.UI.PlaySoundFailure()
			EHT.UI.ShowAlertDialog( "Link Group", "Selection does not contain any furnishings." )
		end

		return
	end

	EHT.Biz.StartProcess(EHT.PROCESS_NAME.UNLINK_GROUP)

	EHT.ProcessData.Index = 0
	EHT.ProcessData.Group = furnitureGroup
	EHT.ProcessData.Total = #furnitureGroup

	EHT.Housing.UnlinkGroup(
		function(index, item)
			local data = EHT.ProcessData
			if "table" ~= type(data) then
				EHT.Biz.EndProcess()
				return false
			end
			
			if data.CancelProcess and not EHT.ProcessRollingBack then
				EHT.Biz.CancelProcessCallback()
				return false
			end

			if "number" == type(index) and "number" == type(data.Total) then
				EHT.Biz.SetProcessProgress((data.Total - index) / data.Total)
				return true
			end

			EHT.Biz.EndProcess()
			return false
		end,
		function()
			EHT.Biz.EndProcess()
			if "function" == type(callback) then
				callback()
			end
		end,
		furnitureGroup
	)
end

---[ Operations : Group Editing ]---

function EHT.Biz.IsCardinalPositionMode()
	if EHT.SavedVars then
		return EHT.SavedVars.EditMode == EHT.CONST.EDIT_MODE.ABSOLUTE
	end
	return true
end

function EHT.Biz.DoesRelativePositionUseUnitHeading()
	return EHT.GetSetting( "EditorUsesUnitHeading" ) == true
end

function EHT.Biz.ToggleDirectionalPositionMode()
	if EHT.Biz.IsCardinalPositionMode() then
		EHT.SavedVars.EditMode = EHT.CONST.EDIT_MODE.RELATIVE
	else
		EHT.SavedVars.EditMode = EHT.CONST.EDIT_MODE.ABSOLUTE
	end
	EHT.DirectionalIndicators:RefreshSettings()
	EHT.UI.RefreshDirectionalPad( true )
end

function EHT.Biz.ToggleSelectionLinkItemsMode()
	local enabled = not ( EHT.SavedVars.SelectionLinkItems == true )
	EHT.SavedVars.SelectionLinkItems = enabled
	EHT.Data.UpdateGroupFurniture( true, true )
	EHT.UI.RefreshSelectionLinkItemsMode( true )
end

function EHT.Biz.DeselectAlternateItems( startIndex )
	local house, group = EHT.Data.GetCurrentHouse()
	if nil == house or nil == group or 0 >= #group then return end

	local index = startIndex
	while index <= #group do
		table.remove( group, index )
		index = index + 1
	end

	EHT.UI.RefreshSelection()
end

function EHT.Biz.RandomlyOrderItems()
	local house, group = EHT.Data.GetCurrentHouse()
	if nil == house or nil == group or 0 >= #group then return end

	local list = EHT.Util.CloneTable( group )

	for index = #group, 1, -1 do
		table.remove( group, index )
	end

	while 0 < #list do
		table.insert( group, table.remove( list, math.random( 1, #list ) ) )
	end

	EHT.UI.RefreshSelection()
end

function EHT.Biz.ReverseOrderItems()
	local house, group = EHT.Data.GetCurrentHouse()
	if nil == house or nil == group or 0 >= #group then return end

	local total = #group
	local temp, altIndex

	for index = 1, math.floor( 0.5 * total ) do
		altIndex, temp = 1 + total - index, group[index]
		group[index] = group[altIndex]
		group[altIndex] = temp
	end

	EHT.UI.RefreshSelection()
end

function EHT.Biz.StackSelectedFurniture( numStacks, measured )
	local house, group = EHT.Data.GetCurrentHouse()
	if nil == house or nil == group or 0 >= #group then return end

	if nil == numStacks or 1 > numStacks then numStacks = 1 end
--[[
	if not measured and not EHT.Housing.AreAllItemDimensionsCached( group ) then
		if EHT.Biz.MeasureDimensions( group, function() EHT.Biz.StackSelectedFurniture( numStacks, true ) end ) then return end
	end
]]
	local centerX, centerY, centerZ, yaw = EHT.Housing.InFrontOfPlayer()
	local stacks = { }

	if 1 == numStacks then
		table.insert( stacks, { centerX, centerY, centerZ } )
	else
		local distance = math.max( EHT.Housing.GetMinMaxItemDimensions( group ) ) + 200

		for i = 0, numStacks - 1 do
			table.insert( stacks, { centerX + ( distance * math.cos( math.rad( 360 ) * i / numStacks ) ), centerY, centerZ + ( distance * math.sin( math.rad( 360 ) * i / numStacks ) ) } )
		end
	end

	local itemIndex = 0

	EHT.Biz.CustomAdjustSelectedFurniture( nil, function( item )
		local stack = stacks[ ( itemIndex % numStacks ) + 1 ]
		item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll = stack[1], stack[2], stack[3], 0, 0, 0
		itemIndex = itemIndex + 1
	end )
end

function EHT.Biz.AdjustRelativeFurniture( itemAfter, itemBefore, relativeFurnitureId, group )
	if EHT.Biz.IsUninterruptableProcessRunning() then return nil end

	if EHT.SnapToGridState then
		if not EHT.Housing.AreFurnitureIdsEqual( relativeFurnitureId, EHT.SnapToGridState.Id ) then
			EHT.Pointers.ShowGuidelinesArrows( false )
		elseif EHT.SavedVars.DirectionalControlsFocusPositionEditor and EHT.Housing.AreFurnitureIdsEqual( EHT.PositionItemId, EHT.SnapToGridState.Id ) then
			EHT.Pointers.ShowGuidelinesArrows( false )
		end
	end

	local deferredDelay = 0
	if nil ~= EHT.ProcessData then deferredDelay = EHT.ProcessData.DeferredDelay or 0 end

	local house

	if nil == group then
		house, group = EHT.Data.GetCurrentHouse()
	else
		house = EHT.Data.GetCurrentHouse()
	end

	if nil == house or nil == group or 0 >= #group then return end

	local relX, relY, relZ = itemAfter.X, itemAfter.Y, itemAfter.Z
	local offX, offY, offZ = itemAfter.X - itemBefore.X, itemAfter.Y - itemBefore.Y, itemAfter.Z - itemBefore.Z
	local relPitch, relYaw, relRoll = itemBefore.Pitch, itemBefore.Yaw, itemBefore.Roll
	local offPitch, offYaw, offRoll = itemAfter.Pitch, itemAfter.Yaw, itemAfter.Roll

	if EHT.UI.GetCurrentToolTab() == EHT.CONST.TOOL_TABS.BUILD and
	   ( ( offX and 0 ~= offX ) or ( offY and 0 ~= offY ) or ( offZ and 0 ~= offZ ) --[[ or ( offPitch and relPitch ~= offPitch ) or ( offYaw and relYaw ~= offYaw ) or ( offRoll and relRoll ~= offRoll ) ]] ) then
		local delta = {
			X = itemAfter.X - itemBefore.X,
			Y = itemAfter.Y - itemBefore.Y,
			Z = itemAfter.Z - itemBefore.Z,
		}

		EHT.Biz.AdjustBuild( delta, 1, 1 )
		return
	end

	local x, y, z, pitch, yaw, roll
	local history = { Op = EHT.CONST.CHANGE_TYPE.CHANGE, Id = 0, Link = "Multiple Items", Batch = { } }
	local historyBatch = history.Batch

	local updateSizeX = itemAfter.SizeX and itemBefore.SizeX and itemAfter.SizeX ~= itemBefore.SizeX and itemAfter.SizeX
	local updateSizeY = itemAfter.SizeY and itemBefore.SizeY and itemAfter.SizeY ~= itemBefore.SizeY and itemAfter.SizeY
	local updateSizeZ = itemAfter.SizeZ and itemBefore.SizeZ and itemAfter.SizeZ ~= itemBefore.SizeZ and itemAfter.SizeZ
	local updateColor = itemAfter.Color and itemBefore.Color and itemAfter.Color ~= itemBefore.Color and itemAfter.Color
	local updateAlpha = itemAfter.Alpha and itemBefore.Alpha and itemAfter.Alpha ~= itemBefore.Alpha and itemAfter.Alpha

	for index, item in ipairs( group ) do
		local itemHistory
		itemHistory = EHT.Util.CloneTable( item )

		x, y, z, pitch, yaw, roll = item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll
		x, y, z = EHT.Housing.GetFurnitureCenter( item.Id, x, y, z, pitch, yaw, roll )
		-- x, y, z, pitch, yaw, roll = EHT.Housing.GetFurniturePositionAndOrientation( item.Id )

		-- Translate item using related item's change offset.
		if 0 ~= offX or 0 ~= offY or 0 ~= offZ then
			x, y, z = EHT.Housing.TranslatePoint( x, y, z, offX, offY, offZ )
		end

		if nil ~= offPitch and nil ~= offYaw and nil ~= offRoll then
			pitch, yaw, roll, x, y, z = EHT.Housing.CalculateRotation( offPitch, offYaw, offRoll, pitch, yaw, roll, x, y, z, relPitch, relYaw, relRoll, relX, relY, relZ )
		end

		item.X, item.Y, item.Z = EHT.Housing.GetFurniturePositionFromCenter( item.Id, x, y, z, pitch, yaw, roll )
		item.Pitch, item.Yaw, item.Roll = pitch, yaw, roll
		if updateSizeX and item.SizeX then item.SizeX = updateSizeX end
		if updateSizeY and item.SizeY then item.SizeY = updateSizeY end
		if updateSizeZ and item.SizeZ then item.SizeZ = updateSizeZ end
		if updateColor and item.Color then item.Color = updateColor end
		if updateAlpha and item.Alpha then item.Alpha = updateAlpha end

		local link = EHT.Housing.GetFurnitureLink( item.Id )
		if nil == item.Link then item.Link = link end
		if nil == itemHistory.Link then itemHistory.Link = link end

		table.insert( historyBatch, EHT.CT.CreateHistory( EHT.CONST.CHANGE_TYPE.CHANGE, itemHistory, item ) )
		EHT.Housing.AddCachedFurniture( item.Id, item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll )
	end

	EHT.Biz.StartProcess( EHT.PROCESS_NAME.ADJUST_SELECTED_GROUP )

	if nil ~= history and nil ~= historyBatch and 0 < #historyBatch then EHT.CT.AddHistory( history ) end
	EHT.UI.RefreshHistory()

	EHT.ProcessData.Index = 0
	EHT.ProcessData.Group = group
	EHT.ProcessData.Total = #group
	EHT.ProcessData.DeferredDelay = deferredDelay
	EHT.ProcessData.UseTrueCenter = false

	EHT.Biz.ScheduleProcessActivity( EHT.Biz.AdjustSelectedFurnitureProcess, deferredDelay )
end

function EHT.Biz.CustomAdjustSelectedFurniture( processName, updateItemFunc, callbackFunc )
	local house, group
	local f = EHT.QuickActionMenu.Furniture

	if f and f.Id and 0 ~= f.Id then
		group = { { Id = f.Id, X = f.X, Y = f.Y, Z = f.Z, Pitch = f.Pitch, Yaw = f.Yaw, Roll = f.Roll, Speed = f.Speed, DelayTime = f.DelayTime, } }

		for k in pairs( f ) do
			f[k] = nil
		end
	else
		house, group = EHT.Data.GetCurrentHouse()
	end

	if nil == group or 0 >= #group then return end

	return EHT.Biz.CustomAdjustFurniture( group, processName, updateItemFunc, callbackFunc )
end

function EHT.Biz.CustomAdjustFurniture( group, processName, updateItemFunc, callbackFunc )
	if EHT.Biz.IsUninterruptableProcessRunning() then return end
	if nil == processName then processName = EHT.PROCESS_NAME.ADJUST_SELECTED_GROUP end

	local house = EHT.Data.GetCurrentHouse()
	if nil == house or nil == group or 0 >= #group then return end

	local history = { Op = EHT.CONST.CHANGE_TYPE.CHANGE, Id = 0, Link = "Multiple Items", Batch = { } }
	local historyBatch = history.Batch

	for index, item in ipairs( group ) do
		local itemHistory
		if updateItemFunc then
			itemHistory = EHT.Util.CloneTable( item )
			updateItemFunc( item )
		else
			itemHistory = EHT.Data.CreateFurniture( item.Id )
		end

		if itemHistory then
			if nil == item.Link or nil == itemHistory.Link then
				local link = EHT.Housing.GetFurnitureLink( item.Id )
				if nil == item.Link then item.Link = link end
				if nil == itemHistory.Link then itemHistory.Link = link end
			end

			table.insert( historyBatch, EHT.CT.CreateHistory( EHT.CONST.CHANGE_TYPE.CHANGE, itemHistory, item ) )
		end
	end

	if nil ~= history and nil ~= historyBatch and 0 < #historyBatch then
		EHT.CT.AddHistory( history )
		EHT.UI.RefreshHistory()

		EHT.Biz.StartProcess( processName )
		local data = EHT.ProcessData
		data.History = historyBatch
		data.Index = 0
		data.Group = group
		data.Total = #group
		data.Callback = callbackFunc

		EHT.Biz.ScheduleProcessActivity( EHT.Biz.AdjustSelectedFurnitureProcess )
		return true
	end
end

function EHT.Biz.GetPrecisionIncrements( precision )
	if 2 == precision then
		return 5, math.rad( 1 )
	elseif 3 == precision then
		return 10, math.rad( 5 )
	elseif 4 == precision then
		return 50, math.rad( 15 )
	elseif 5 == precision then
		return 200, math.rad( 30 )
	elseif 6 == precision then
		return 1000, math.rad( 90 )
	end

	return 1, math.rad( 0.1 )
end

function EHT.Biz.AdjustSelectedOrPositionedFurniture( delta, ... )
	if nil ~= delta and EHT.SavedVars.DirectionalControlsFocusPositionEditor and nil ~= EHT.PositionItemId and EHT.Housing.IsValidFurnitureId( EHT.PositionItemId ) then
		delta.Group = { EHT.Data.CreateFurniture( EHT.PositionItemId ) }
	end

	if "table" ~= type( delta.Group ) then
		local house, group = EHT.Data.GetCurrentHouse()
		delta.Group = group
	end

	if "table" ~= type( delta.Group ) or 0 == #delta.Group then
		EHT.UI.DisplayNotification( "|c88ffffFirst target and select items with the\n|cffff00Group Select|c88ffff key or click |cffff00EHT|c888800 || |cffff00Housing Tools" )
		return
	end

	if nil ~= delta then
		delta.UseTrueCenter = true
	end

	return EHT.Biz.AdjustSelectedFurniture( delta, ... )
end

local adjustSelectedFurnitureCompleteCallbackId

function EHT.Biz.AdjustSelectedFurniture( delta, precision )
	if EHT.Biz.IsUninterruptableProcessRunning() then
		return nil
	end

	local deferredDelay = 0
	if EHT.ProcessData then
		deferredDelay = EHT.ProcessData.DeferredDelay or 0
	end

	local house, group = EHT.Data.GetCurrentHouse()

	if delta and delta.Group then
		group = delta.Group
	end

	if nil == delta or nil == house or nil == group or 0 >= #group then
		return nil
	end

	if EHT.UI.SnapFurnitureDialog and not EHT.UI.SnapFurnitureDialog.Window:IsHidden() then
		EHT.UI.HideSnapFurnitureDialog()
	end

	local origin = EHT.Housing.CalculateFurnitureOrigin( group, true )

	if nil == precision or 1 > precision or 5 < precision then
		if IsShiftKeyDown() then
			precision = 5
		elseif IsAltKeyDown() then
			precision = 1
		else
			precision = EHT.SavedVars.SelectionPrecision or 3
			precision = tonumber( precision )
		end
	end

	local anglePrecision, coordPrecision
	if true == EHT.SavedVars.SelectionPrecisionUseCustom then
		anglePrecision = math.rad(EHT.SavedVars.SelectionPrecisionRotateCustom)
		coordPrecision = EHT.SavedVars.SelectionPrecisionMoveCustom
	else
		coordPrecision, anglePrecision = EHT.Biz.GetPrecisionIncrements(precision)
	end

	if nil == coordPrecision or 0 >= coordPrecision then coordPrecision = 1 end
	if nil == anglePrecision or 0 >= anglePrecision then anglePrecision = math.rad(1) end

	if delta.Forward or delta.Left then
		local heading = EHT.Biz.GetEditorHeading()

		if nil ~= delta.Forward then
			local coeff = delta.Forward * -1
			delta.X = coeff * math.sin( heading )
			delta.Z = coeff * math.cos( heading )
		end

		if nil ~= delta.Left then
			local coeff = delta.Left
			heading = ( heading - math.rad( 90 ) ) % math.rad( 360 )
			delta.X = coeff * math.sin( heading )
			delta.Z = coeff * math.cos( heading )
		end
	end

	adjustSelectedFurnitureCompleteCallbackId = nil

	if EHT.UI.GetCurrentToolTab() == EHT.CONST.TOOL_TABS.BUILD then
		EHT.Biz.AdjustBuild( delta, coordPrecision, anglePrecision )
		return
	end

	if nil ~= delta.Pitch or nil ~= delta.Yaw or nil ~= delta.Roll then
		local before = { X = origin.X, Y = origin.Y, Z = origin.Z, Pitch = 0, Yaw = 0, Roll = 0 }
		local after = EHT.Util.CloneTable( before )

		if nil ~= delta.Pitch then after.Pitch = after.Pitch + ( delta.Pitch * anglePrecision ) end
		if nil ~= delta.Yaw then after.Yaw = after.Yaw + ( delta.Yaw * anglePrecision ) end
		if nil ~= delta.Roll then after.Roll = after.Roll + ( delta.Roll * anglePrecision ) end
		after.UseTrueCenter = delta.UseTrueCenter

		EHT.Biz.AdjustRelativeFurniture( after, before, nil, group )
		return
	end

	if delta.X then delta.X = delta.X * coordPrecision end
	if delta.Y then delta.Y = delta.Y * coordPrecision end
	if delta.Z then delta.Z = delta.Z * coordPrecision end

	coordPrecision = 1

	if delta.X and delta.Z then
		local sx, sz = 0 > delta.X and -1 or 1, 0 > delta.Z and -1 or 1
		delta.X, delta.Z = math.abs( delta.X ), math.abs( delta.Z )

		local half = 0.498 * ( delta.X + delta.Z )
		if delta.X >= half then
			delta.X = math.roundIntLarger( delta.X )
		else
			delta.X = math.roundIntSmaller( delta.X )
		end
		if delta.Z >= half then
			delta.Z = math.roundIntLarger( delta.Z )
		else
			delta.Z = math.roundIntSmaller( delta.Z )
		end

		delta.X, delta.Z = delta.X * sx, delta.Z * sz
	end

	local history = { Op = EHT.CONST.CHANGE_TYPE.CHANGE, Id = 0, Link = "Multiple Items", Batch = { } }
	local historyBatch = history.Batch

	local x, y, z, pitch, yaw, roll
	local itemBefore

	for index, item in ipairs( group ) do
		if nil == item.Link then item.Link = EHT.Housing.GetFurnitureLink( item.Id ) end

		if delta.X and 0 == delta.X then
			itemBefore = EHT.Data.CreateFurniture( item.Id )
		else
			itemBefore = EHT.Util.CloneTable( item )
		end

		x, y, z, pitch, yaw, roll = item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll

		if not x or not y or not z or not pitch or not yaw or not roll then
			local _x, _y, _z, _pitch, _yaw, _roll = EHT.Housing.GetFurniturePositionAndOrientation( item.Id )
			x, y, z, pitch, yaw, roll = x or _x or 0, y or _y or 0, z or _z or 0, pitch or _pitch or 0, yaw or _yaw or 0, roll or _roll or 0
		end

		if nil ~= delta.X then x = x + ( delta.X * coordPrecision ) end
		if nil ~= delta.Y then y = y + ( delta.Y * coordPrecision ) end
		if nil ~= delta.Z then z = z + ( delta.Z * coordPrecision ) end

		if nil ~= delta.MirrorHorizontal then x, y, z, pitch, yaw, roll = EHT.Housing.HorizontalMirrorPoint( origin, x, y, z, pitch, yaw, roll ) end
		if nil ~= delta.MirrorVertical then x, y, z, pitch, yaw, roll = EHT.Housing.VerticalMirrorPoint( origin, x, y, z, pitch, yaw, roll ) end

		if nil ~= delta.StaticX then x = delta.StaticX end
		if nil ~= delta.StaticY then y = delta.StaticY end
		if nil ~= delta.StaticZ then z = delta.StaticZ end
		if nil ~= delta.StaticPitch then pitch = delta.StaticPitch end
		if nil ~= delta.StaticYaw then yaw = delta.StaticYaw end
		if nil ~= delta.StaticRoll then roll = delta.StaticRoll end

		item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll = math.floor( x ), math.floor( y ), math.floor( z ), pitch, yaw, roll

		table.insert( historyBatch, EHT.CT.CreateHistory( EHT.CONST.CHANGE_TYPE.CHANGE, itemBefore, item ) )
		EHT.Housing.AddCachedFurniture( item.Id, item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll )
	end

	EHT.Biz.StartProcess( EHT.PROCESS_NAME.ADJUST_SELECTED_GROUP )
	EHT.ProcessData.Index = 0
	EHT.ProcessData.Group = group
	EHT.ProcessData.Total = #group
	EHT.ProcessData.Callback = delta.Callback
	EHT.ProcessData.CreateMissingPathNodes = delta.CreateMissingPathNodes
	EHT.ProcessData.DeferredDelay = 0
	EHT.ProcessData.UseTrueCenter = delta.UseTrueCenter and 1 == #group
	EHT.ProcessData.SkipUnchanged = delta.SkipUnchanged

	if nil ~= history and nil ~= historyBatch and 0 < #historyBatch then
		EHT.ProcessData.History = history
	end

	if EHT.ProcessData.History then
		EHT.CT.AddHistory( EHT.ProcessData.History )
		EHT.UI.RefreshHistory()
	end

	EHT.Biz.ScheduleProcessActivity( EHT.Biz.AdjustSelectedFurnitureProcess, 1 )
end

function EHT.Biz.AdjustSelectedFurnitureComplete( processId )
	local data = EHT.ProcessData
	if not data or not EHT.Biz.CheckCurrentProcessActivity( processId ) then return end

	if EHT.RecordingSceneFrames then
		local hasSceneItem = false
		local group = data.Group

		for _, item in ipairs( group ) do
			if nil ~= item and nil ~= item.Id and nil ~= EHT.Data.GetSceneFurniture( item.Id ) then
				hasSceneItem = true
				break
			end
		end

		if hasSceneItem then EHT.Biz.InsertSceneFrame() end
	end

	local callback, callbackData
	if data and data.Callback then
		callback, callbackData = data.Callback, data
	end

	EHT.Biz.EndProcess()

	if callback then
		callback( callbackData.Group )
	end
end

function EHT.Biz.AdjustSelectedFurnitureProcess( processId )
	local data = EHT.ProcessData
	if not data or not EHT.Biz.CheckCurrentProcessActivity( processId ) then return nil end

	-- Remove parent items from the change set to avoid conflicts.
	if not data.SortedDependentList then
		data.Group = EHT.Housing.RemoveAllDependents( data.Group )
		data.SortedDependentList = true
	end

	local group = data.Group
	if nil == group or 0 >= #group then
		d( "Selection is empty." )
		EHT.UI.PlaySoundFailure()
		EHT.Biz.EndProcess()
		return nil
	end
	
	local updatedPaths = data.UpdatedPaths
	if not updatedPaths then
		updatedPaths = { }
		data.UpdatedPaths = updatedPaths
	end

	local paths = group.Paths
	local info = data.UpdatePathInfo
	if info then
		data.UpdatePathInfo = nil

		local id = string.fromId64( info.Id )
		if not updatedPaths[ id ] then
			updatedPaths[ id ] = true

			if EHT.Housing.SetFurniturePathInfo( id, info ) then
				EHT.Biz.ScheduleProcessActivity( EHT.Biz.AdjustSelectedFurnitureProcess, EHT.Setup.GetEditDelay() )
				return
			end
		end
	end

	repeat
		local index = ( data.Index or 0 ) + 1
		data.Index = index

		if index > #group then
			EHT.Biz.ScheduleProcessActivity( EHT.Biz.AdjustSelectedFurnitureComplete, 0 )
			return
		end

		local item = group[ index ]
		if item then
			local id = item.Id
			local pathFurnitureId, pathIndex = EHT.Housing.GetFurnitureIdInfo( id )

			if pathFurnitureId and pathIndex then
				if not paths then
					paths = { }
					group.Paths = paths
				end

				local function callback()
if EHT.DebugPathNodes then d(" Operation complete") end
					EHT.Biz.SetProcessProgress(	index / data.Total )
					EHT.Biz.ScheduleProcessActivity( EHT.Biz.AdjustSelectedFurnitureProcess, EHT.Setup.GetEditDelay() )
				end

				local currentX = EHT.Housing.GetFurniturePathNodeInfo( pathFurnitureId, pathIndex )
				if currentX and 0 ~= currentX then
					data.UpdatePathInfo = paths[ string.fromId64( pathFurnitureId ) ]
					local result = EHT.Housing.SetFurniturePathNodeInfo( pathFurnitureId, pathIndex, item.X, item.Y, item.Z, item.Yaw, item.Speed, item.DelayTime )
if EHT.DebugPathNodes then df("SetFurniturePathNodeInfo(%s, %d) returned %d", string.fromId64( pathFurnitureId ), pathIndex, result) end
					callback()
				else -- if data.CreateMissingPathNodes then
					data.UpdatePathInfo = paths[ string.fromId64( pathFurnitureId ) ]
					local result = EHT.Housing.PlaceFurnitureAndPathNode( callback, pathFurnitureId, pathIndex, item.X, item.Y, item.Z, item.Yaw, item.Speed, item.DelayTime )
if EHT.DebugPathNodes then df("PlaceFurnitureAndPathNode(%s, %d) returned %d", string.fromId64( pathFurnitureId ), pathIndex, result) end
				end

				return
			else
				local changed = ( not data.SkipUnchanged ) or EHT.Housing.HasFurnitureIdChanged( id, item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll, item.SizeX, item.SizeY, item.SizeZ, item.Color, item.Alpha, item.Groups )
				if changed then
					local effect, result

					if ( item.SizeX or item.SizeY or item.SizeZ or item.Color or item.Alpha ) and EHT.Housing.IsEffectId( id ) then
						effect = EHT.Effect:GetByRecordId( id )

						if effect then
							if item.Color then
								local r, g, b = EHT.Util.DecompressColor( item.Color )
								effect:SetColor( r, g, b, item.Alpha )
							elseif item.Alpha then
								effect:SetColor( nil, nil, nil, item.Alpha )
							end

							if item.SizeX or item.SizeY or item.SizeZ then
								effect:SetSize( item.SizeX, item.SizeY, item.SizeZ )
							end
						end
					end

					EHT.Biz.SetProcessProgress(	index / data.Total )
					result = EHT.Housing.SetFurniturePositionAndOrientation( id, item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll )

					if effect then
						effect:UpdateRecord()
					end

					if EHT.Housing.IsEffectId( id ) then
						EHT.Setup.GetEditDelay()
						EHT.Biz.ScheduleProcessActivity( EHT.Biz.AdjustSelectedFurnitureProcess, 1 )
						return
					end
				
					if result == HOUSING_REQUEST_RESULT_SUCCESS then
						EHT.Handlers.OnFurnitureChanged( item )
						EHT.Biz.ScheduleProcessActivity( EHT.Biz.AdjustSelectedFurnitureProcess, EHT.Setup.GetEditDelay() )
					elseif nil ~= data.History then
						EHT.CT.ChangeFailed( data.History, id )
						EHT.Biz.ScheduleProcessActivity( EHT.Biz.AdjustSelectedFurnitureProcess, 1 )
					else
						EHT.Biz.ScheduleProcessActivity( EHT.Biz.AdjustSelectedFurnitureComplete, 0 )
					end

					return
				end
			end
		end
	until 1 == 0
end

---[ Operations : Build ]---

local pendingBuild, pendingBuildId, pendingBuildCallback

function EHT.Biz.LoadBuild( name )
	local build, index = EHT.Data.GetBuild( name )
	if nil ~= build then
		EHT.UI.SetUnsavedToolChanges( false )
		EHT.Data.SetBuild( nil, build )
	end

	return build
end

function EHT.Biz.SaveBuild( name, build )
	if nil == name or "" == name then return false end

	if nil == build then build = EHT.Data.GetBuild() end
	if nil ~= build then
		EHT.UI.SetUnsavedToolChanges( false )
		return EHT.Data.SetBuild( name, build )
	end

	return false
end

function EHT.Biz.RemoveBuild( name )
	if nil ~= name and "" ~= name then
		return EHT.Data.RemoveBuild( name )
	else
		return false
	end
end

function EHT.Biz.CleanBuildValues( build )
	if nil == build then return end

	if nil == build.TemplateName or "" == build.TemplateName then build.TemplateName = EHT.CONST.BUILD_TEMPLATE_DEFAULT end
	
	local defaultItemPitch = 0
	if build.TemplateName == EHT.CONST.BUILD_TEMPLATE.DOME or build.TemplateName == EHT.CONST.BUILD_TEMPLATE.SPHERE then
		defaultItemPitch = 90
	end

	if nil == build.Pitch then build.Pitch = 0 end
	if nil == build.Yaw then build.Yaw = 0 end
	if nil == build.Roll then build.Roll = 0 end

	if nil == build.ArcLength then build.ArcLength = 360 end
	if nil == build.Circumference then build.Circumference = 5 end

	if nil == build.Radius then build.Radius = 500 end
	if nil == build.RadiusX then build.RadiusX = build.Radius end
	if nil == build.RadiusY then build.RadiusY = build.Radius end
	if nil == build.RadiusZ then build.RadiusZ = build.Radius end
	if nil == build.RadiusStart then build.RadiusStart = build.Radius end
	if nil == build.RadiusEnd then build.RadiusEnd = build.Radius end

	if nil == build.ItemPitch then build.ItemPitch = defaultItemPitch end
	if nil == build.ItemYaw then build.ItemYaw = 0 end
	if nil == build.ItemRoll then build.ItemRoll = 0 end

	if nil == build.ItemHeight then build.ItemHeight = 100 end
	if nil == build.ItemLength then build.ItemLength = 100 end
	if nil == build.ItemWidth then build.ItemWidth = 100 end

	if nil == build.AutoSpacing then build.AutoSpacing = true end
	if nil == build.ItemSpacingHeight then build.ItemSpacingHeight = 0 end
	if nil == build.ItemSpacingLength then build.ItemSpacingLength = 0 end
	if nil == build.ItemSpacingWidth then build.ItemSpacingWidth = 0 end

	if nil == build.Length then build.Length = 2 end
	if nil == build.Width then build.Width = 2 end
	if nil == build.Height then build.Height = 1 end
	
	if nil == build.CharacterSpacing then build.CharacterSpacing = 50 end
	if nil == build.LineSpacing then build.LineSpacing = 80 end

	build.Pitch = build.Pitch % 360
	build.Yaw = build.Yaw % 360
	build.Roll = build.Roll % 360

	build.ItemPitch = build.ItemPitch % 360
	build.ItemYaw = build.ItemYaw % 360
	build.ItemRoll = build.ItemRoll % 360

	if nil ~= build.X then build.X = math.abs( build.X ) end
	if nil ~= build.Y then build.Y = math.abs( build.Y ) end
	if nil ~= build.Z then build.Z = math.abs( build.Z ) end

	build.ArcLength = tonumber( build.ArcLength ) % 361
	build.Circumference = math.abs( tonumber( build.Circumference ) )

	build.Radius = math.abs( tonumber( build.Radius ) )
	build.RadiusX = math.abs( tonumber( build.RadiusX ) )
	build.RadiusY = math.abs( tonumber( build.RadiusY ) )
	build.RadiusZ = math.abs( tonumber( build.RadiusZ ) )
	build.RadiusStart = math.abs( tonumber( build.RadiusStart ) )
	build.RadiusEnd = math.abs( tonumber( build.RadiusEnd ) )

	build.Height = math.abs( tonumber( build.Height ) )
	build.Length = math.abs( tonumber( build.Length ) )
	build.Width = math.abs( tonumber( build.Width ) )

	build.ItemHeight = math.abs( tonumber( build.ItemHeight ) )
	build.ItemLength = math.abs( tonumber( build.ItemLength ) )
	build.ItemWidth = math.abs( tonumber( build.ItemWidth ) )

	build.ItemSpacingHeight = tonumber( build.ItemSpacingHeight ) or 0
	build.ItemSpacingLength = tonumber( build.ItemSpacingLength ) or 0
	build.ItemSpacingWidth = tonumber( build.ItemSpacingWidth ) or 0
end

function EHT.Biz.RecallBuild()
	local house = EHT.Data.GetCurrentHouseRecords()
	if nil == house then return end

	local build = EHT.Data.GetBuild()
	if nil == build then return end

	local x, y, z = EHT.Housing.InFrontOfPlayer()
	build.X, build.Y, build.Z = x, y, z

	EHT.UI.RefreshBuild()
	EHT.Biz.Build( build )
end

function EHT.Biz.CheckBuildState()
	local ui = EHT.UI.ToolDialog
	if not ui or not ui.BuildParams then return end

	local house, group = EHT.Data.GetCurrentHouseRecords()
	if nil == house then return end

	local build = EHT.Data.GetBuild()
	if nil == build then return end

	if nil == build.X or nil == build.Y or nil == build.Z then return end

	local x, y, z = GetPlayerWorldPositionInHouse()
	local heading = EHT.Biz.GetEditorHeading()
	local distance = zo_distance3D( build.X, build.Y, build.Z, x, y, z )

	if build.SelectionChanged then
		build.ItemCount = #group
		if EHT.UI.ToolDialog then
			EHT.SuppressSliderFunctions = true
			EHT.UI.ToolDialog.BuildParams.ItemCount:SetValue( build.ItemCount )
			EHT.SuppressSliderFunctions = false
		end
	end

	local ui = EHT.UI.ToolDialog
	if ui then
		if build.SelectionChanged and nil ~= group and 0 < #group then
			build.SelectionChanged = false
			EHT.UI.HideTooltip()
			EHT.UI.ShowTooltip( InformationTooltip, ui.BuildMeasureButton, "|cffff33The item selection has changed.|r\n\nClick |cffff33Measure|r to remeasure the selected items and adjust the Item Dimensions.", RIGHT, -20, 0, LEFT )
		elseif distance > EHT.CONST.BUILD_DISTANCE_WARNING then
			EHT.UI.HideTooltip()
			EHT.UI.ShowTooltip( InformationTooltip, ui.ArrangeBuildDropdown:GetControl(), "|cffff33The build is currently far away.|r\n\nSelect |cffff33Bring To Me|r to move the build to your current location.", RIGHT, -20, 0, LEFT )
		end
	end
end

function EHT.Biz.AdjustBuild( delta, coordPrecision, anglePrecision )
	if nil == delta then return end

	local _, group, _, _, build = EHT.Data.GetCurrentHouse()
	if nil == build or nil == group or 0 >= #group then return end

	if nil == build.X or 0 == build.X or nil == build.Y or 0 == build.Y or nil == build.Z or 0 == build.Z then
		local x, y, z = EHT.Housing.InFrontOfPlayer()
		if nil == build.X or 0 == build.X then build.X = x end
		if nil == build.Y or 0 == build.Y then build.Y = y end
		if nil == build.Z or 0 == build.Z then build.Z = z end
	end

	if nil ~= delta.X then build.X = build.X + ( coordPrecision * delta.X ) end
	if nil ~= delta.Y then build.Y = build.Y + ( coordPrecision * delta.Y ) end
	if nil ~= delta.Z then build.Z = build.Z + ( coordPrecision * delta.Z ) end

	if nil ~= delta.ItemPitch then build.ItemPitch = ( build.ItemPitch or 0 ) + math.deg( delta.ItemPitch * anglePrecision ) end
	if nil ~= delta.ItemYaw then build.ItemYaw = ( build.ItemYaw or 0 ) + math.deg( delta.ItemYaw * anglePrecision ) end
	if nil ~= delta.ItemRoll then build.ItemRoll = ( build.ItemRoll or 0 ) + math.deg( delta.ItemRoll * anglePrecision ) end

	if nil ~= delta.Pitch then build.Pitch = ( build.Pitch or 0 ) + math.deg( delta.Pitch * anglePrecision ) end
	if nil ~= delta.Yaw then build.Yaw = ( build.Yaw or 0 ) + math.deg( delta.Yaw * anglePrecision ) end
	if nil ~= delta.Roll then build.Roll = ( build.Roll or 0 ) + math.deg( delta.Roll * anglePrecision ) end

	EHT.Biz.CleanBuildValues( build )
	EHT.UI.RefreshBuild()
	EHT.UI.SetUnsavedToolChanges( true )

	zo_callLater( EHT.Biz.QueuedBuild, EHT.CONST.BUILD_START_DELAY )
end

function EHT.Biz.ResetBuild( measureOnly, skipBuild )
	local house, group = EHT.Data.GetCurrentHouse()
	if nil == house or nil == group or 0 >= #group then return false end

	local templateName

	if not measureOnly then
		if nil ~= EHT.SavedVars.Build then
			templateName = EHT.SavedVars.Build.TemplateName
			EHT.SavedVars.Build = nil
		end
	end

	local build = EHT.Data.GetBuild()
	if nil ~= templateName then build.TemplateName = templateName end

	local minX, minY, minZ, maxX, maxY, maxZ = EHT.Housing.GetMinMaxItemDimensions( group )
	build.ItemLength, build.ItemHeight, build.ItemWidth = maxX, maxY, maxZ

	if not measureOnly then
		build.X, build.Y, build.Z = EHT.Housing.InFrontOfPlayer()

		if build.TemplateName ~= EHT.CONST.BUILD_TEMPLATE.CRAFTING_STATIONS_PODS and build.TemplateName ~= EHT.CONST.BUILD_TEMPLATE.CRAFTING_STATIONS_ROWS then
			build.Y = build.Y + build.ItemHeight / 2
		end
	end

	EHT.UI.RefreshBuild()

	if not skipBuild then
		EHT.Biz.Build( build )
	end
	
	EHT.IsNewBuild = true
end

function EHT.Biz.Build( build, callback )
	local process = EHT.Biz.GetProcess()
	if nil ~= process and process ~= EHT.PROCESS_NAME.BUILD and EHT.Biz.IsProcessRunning() then return nil end

	local buildDelay = EHT.CONST.BUILD_START_DELAY

	if EHT.Biz.IsRandomizingBuild() then
		callback = EHT.Biz.RandomizeBuildCallback
		buildDelay = 50
	end

	EHT.Biz.QueuedBuild( EHT.Data.GetBuild(), callback, buildDelay )
	
	if EHT.IsNewBuild then
		EssentialHousingHub:IncUMTD("n_bld", 1)
		EHT.IsNewBuild = false
	end
end

function EHT.Biz.QueuedBuild( build, callback, buildDelay )
	if "table" ~= type( build ) then
		build = EHT.Data.GetBuild()
	end

	EHT.Biz.EndProcess()
	EHT.Biz.StartProcess( EHT.PROCESS_NAME.BUILD )

	EHT.CurrentBuild = EHT.PreviousBuild
	EHT.PreviousBuild = EHT.Util.CloneTable( build )

	pendingBuild = build
	pendingBuildCallback = callback

	local function defaultTo( v, def )
		if nil ~= v and "" ~= v then
			return tonumber( v )
		else
			return def
		end
	end

	local ui = EHT.UI.ToolDialog
	local house, group, scene, frame = EHT.Data.GetCurrentHouse()
	if nil == build or nil == house or nil == group or 0 >= #group then
		EHT.Biz.EndProcess()
		return
	end

	local history = { Op = EHT.CONST.CHANGE_TYPE.CHANGE, Id = 0, Link = "Build", Batch = { } }
	local historyBatch = history.Batch
	local totalItems, itemBefore, item = #group, nil, nil
	local x, y, z, pitch, yaw, roll
	local updates = { }
	local angle

	if build.ItemCount and 0 < build.ItemCount then totalItems = build.ItemCount end

	if not build.X or 0 == build.X or not build.Y or 0 == build.Y or not build.Z or 0 == build.Z then
		local origin = EHT.Housing.CalculateFurnitureOrigin( group, false )
		if nil == build.X or 0 == build.X then build.X = origin.X end
		if nil == build.Y or 0 == build.Y then build.Y = origin.Y end
		if nil == build.Z or 0 == build.Z then build.Z = origin.Z end
	end

	for index, item in ipairs( group ) do
		if nil == item.Link then item.Link = EHT.Housing.GetFurnitureLink( item.Id ) end
	end

	local originX, originY, originZ = build.X, build.Y, build.Z
	local shapePitch, shapeYaw, shapeRoll = math.rad( defaultTo( build.Pitch, 0 ) ), math.rad( defaultTo( build.Yaw, 0 ) ), math.rad( defaultTo( build.Roll, 0 ) )
	local itemPitch, itemYaw, itemRoll = math.rad( defaultTo( build.ItemPitch, 0 ) ), math.rad( defaultTo( build.ItemYaw, 0 ) ), math.rad( defaultTo( build.ItemRoll, 0 ) )
	local length, height, width = defaultTo( build.Length, 1 ), defaultTo( build.Height, 1 ), defaultTo( build.Width, 1 )
	local originalItemLength, originalItemWidth, originalItemHeight = defaultTo( build.ItemLength, 1 ), defaultTo( build.ItemWidth, 1 ), defaultTo( build.ItemHeight, 1 )
	local circum, radius, radiusStart, radiusEnd = defaultTo( build.Circumference, 1 ), defaultTo( build.Radius, 1 ), defaultTo( build.RadiusStart, 1 ), defaultTo( build.RadiusEnd, 1 )
	local radiusX, radiusY, radiusZ = defaultTo( build.RadiusX, 1 ), defaultTo( build.RadiusY, 1 ), defaultTo( build.RadiusZ, 1 )
	local arcLength = defaultTo( build.ArcLength, 360 )
	local autoSpacing, checkerPattern, ellipse, reverseSort = build.AutoSpacing, build.CheckerPattern, build.Ellipse, build.ReverseSort
	local message = build.Message or ""
	local charSpacing, lineSpacing = build.CharacterSpacing or 1, build.LineSpacing or 1

	if not ellipse and not EHT.Util.IsListValue( { EHT.CONST.BUILD_TEMPLATE.BRIDGE, EHT.CONST.BUILD_TEMPLATE.SCATTER_POSITION, EHT.CONST.BUILD_TEMPLATE.SCATTER_ORIENTATION }, build.TemplateName ) then
		radiusX, radiusY, radiusZ = radius, radius, radius
	end

	_, _, _, itemLength, itemHeight, itemWidth = EHT.Housing.CalculateRotation( itemPitch, itemYaw, itemRoll, 0, 0, 0, originalItemLength / 2, originalItemHeight / 2, originalItemWidth / 2, nil, nil, nil, 0, 0, 0 )
	itemLength, itemHeight, itemWidth = math.abs( itemLength * 2 ), math.abs( itemHeight * 2 ), math.abs( itemWidth * 2 )
	local orientedItemLength, orientedItemHeight, orientedItemWidth = itemLength, itemHeight, itemWidth

	local itemSpacingLength, itemSpacingHeight, itemSpacingWidth = build.ItemSpacingLength or 0, build.ItemSpacingHeight or 0, build.ItemSpacingWidth or 0
	itemLength, itemHeight, itemWidth = itemLength + itemSpacingLength, itemHeight + itemSpacingHeight, itemWidth + itemSpacingWidth

	_, _, _, orientedItemSpacingLength, orientedItemSpacingHeight, orientedItemSpacingWidth = EHT.Housing.CalculateRotation( itemPitch, itemYaw, itemRoll, 0, 0, 0, 0.5 * itemSpacingLength, 0.5 * itemSpacingHeight, 0.5 * itemSpacingWidth, nil, nil, nil, 0, 0, 0 )
	orientedItemSpacingLength, orientedItemSpacingHeight, orientedItemSpacingWidth = orientedItemSpacingLength * 2, orientedItemSpacingHeight * 2, orientedItemSpacingWidth * 2

	local autoStackExcess = EHT.SavedVars.AutoStackExcessBuildMaterials
	local index, itemIndex = 0, 0
	local maxItemIndex = #group

	if 0 == itemLength then itemLength = 0.01 end
	if 0 == itemWidth then itemWidth = 0.01 end
	if 0 == itemHeight then itemHeight = 0.01 end

	local function getNextItem( finite )
		if 0 >= maxItemIndex or itemIndex >= totalItems then return nil, nil end
		if finite and itemIndex >= maxItemIndex then return nil, nil end

		local item = group[ ( itemIndex % maxItemIndex ) + 1 ]
		itemIndex = itemIndex + 1

		return item, itemIndex
	end

	local function offsetItem( item )
		if item and item.Id then
			item.X, item.Y, item.Z = EHT.Housing.GetFurniturePositionFromCenter( item.Id, item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll )
		end
	end

	if build.TemplateName == EHT.CONST.BUILD_TEMPLATE.BRIDGE then
		local heightRatio = radiusY / radiusZ
		local arcAngle = math.rad( 179.98 )
		local circum = math.pow( radiusZ + radiusY, 2 ) * ( math.sqrt( -3 * ( math.pow( radiusZ - radiusY, 2 ) / math.pow( radiusZ + radiusY, 2 ) ) + 4 ) + 10 )
		circum = 3 * ( math.pow( radiusZ - radiusY, 2 ) / circum ) + 1
		circum = math.pi * ( radiusZ + radiusY ) * circum
		circum = circum * ( arcAngle / ( 2 * math.pi ) )
		local circumItems = 2 + math.unnan( math.floor( circum / itemWidth ) )
		local unitAngle = math.unnan( arcAngle / circumItems )
		local percent = 0

		if autoSpacing then
			unitAngle = math.unnan( arcAngle / totalItems )
		end

		repeat
			item = getNextItem()
			if nil ~= item then
				itemBefore = EHT.Util.CloneTable( item )

				if autoSpacing then
					percent = ( index + 0.5 ) / totalItems
					angle = arcAngle * EHT.Util.EaseOutIn( percent, 0.8 )
					pitch = itemPitch + math.rad( 90 ) * -1 * ( -1 + 2 * EHT.Util.EaseOutIn( percent, heightRatio ) )
				else
					percent = zo_clamp( EHT.Util.EaseOutIn( ( ( 0.5 + index ) * unitAngle ) / arcAngle, 0.8 ), 0.02, 0.98 )
					angle = arcAngle * percent
					pitch = itemPitch + math.rad( 90 ) * -1 * ( -1 + 2 * EHT.Util.EaseOutIn( percent, heightRatio ) )
				end

				yaw, roll = itemYaw, itemRoll
				x, y, z = 0, radiusY * math.sin( angle ), radiusZ * math.cos( angle )

				pitch, yaw, roll, x, y, z = EHT.Housing.CalculateRotation( shapePitch, shapeYaw, shapeRoll,			pitch, yaw, roll,		x, y, z,	nil, nil, nil,		0, 0, 0 )
				x, y, z = x + originX, y + originY, z + originZ

				item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll = math.unnan( x ), math.unnan( y ), math.unnan( z ), math.unnan( pitch ), math.unnan( yaw ), math.unnan( roll )
				offsetItem( item )

				table.insert( updates, EHT.Util.CloneTable( item ) )
				table.insert( historyBatch, EHT.CT.CreateHistory( EHT.CONST.CHANGE_TYPE.CHANGE, itemBefore, item ) )
				index = index + 1

				if percent >= 1 then break end
			end
		until nil == item
	elseif build.TemplateName == EHT.CONST.BUILD_TEMPLATE.CIRCLE then
		radiusX = radiusX + itemWidth / 2
		radiusZ = radiusZ + itemWidth / 2

		local arcAngle = math.rad( arcLength )
		local circum = math.pow( radiusX + radiusZ, 2 ) * ( math.sqrt( -3 * ( math.pow( radiusX - radiusZ, 2 ) / math.pow( radiusX + radiusZ, 2 ) ) + 4 ) + 10 )
		circum = 3 * ( math.pow( radiusX - radiusZ, 2 ) / circum ) + 1
		circum = math.pi * ( radiusX + radiusZ ) * circum
		local circumItems = math.unnan( math.floor( circum * ( arcAngle / RAD360 ) / itemLength ) )
		local unitAngle = math.unnan( math.rad( 360 / circumItems  ) )

		if autoSpacing then
			unitAngle = math.rad( arcLength / totalItems )
		end

		repeat
			item = getNextItem()
			if nil ~= item then
				itemBefore = EHT.Util.CloneTable( item )

				angle = ( 0.5 * unitAngle ) + ( unitAngle * index )
				if arcAngle < angle then break end

				x, y, z = radiusX * math.sin( angle ), 0, radiusZ * math.cos( angle )

				pitch, yaw, roll = itemPitch, ( itemYaw + angle ) % RAD360, itemRoll
				pitch, yaw, roll, x, y, z = EHT.Housing.CalculateRotation( shapePitch, shapeYaw, shapeRoll,			pitch, yaw, roll,		x, y, z,	nil, nil, nil,		0, 0, 0 )

				x, y, z = x + originX, y + originY, z + originZ
				item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll = x, y, z, pitch, yaw, roll
				offsetItem( item )

				table.insert( updates, EHT.Util.CloneTable( item ) )
				table.insert( historyBatch, EHT.CT.CreateHistory( EHT.CONST.CHANGE_TYPE.CHANGE, itemBefore, item ) )
				index = index + 1

				if autoSpacing and angle >= arcAngle then break end
			end
		until nil == item
	elseif build.TemplateName == EHT.CONST.BUILD_TEMPLATE.CRAFTING_STATIONS_PODS or build.TemplateName == EHT.CONST.BUILD_TEMPLATE.CRAFTING_STATIONS_ROWS or build.TemplateName == EHT.CONST.BUILD_TEMPLATE.CRAFTING_STATIONS_COLS then
		local setStations, stationNames = { }, { }
		local stations, setName, itemName, itemName2, indexInsert, indexParen1, indexParen2
		local usePods = build.TemplateName == EHT.CONST.BUILD_TEMPLATE.CRAFTING_STATIONS_PODS
		local useRows = not usePods
		local byColumn = build.TemplateName == EHT.CONST.BUILD_TEMPLATE.CRAFTING_STATIONS_COLS
		autoStackExcess = false

		-- Identify and group the stations by armor set.

		for index, item in ipairs( group ) do
			setName = EHT.Housing.GetFurnitureLinkSetName( item.Link )
			if nil ~= setName then
				itemName = EHT.Housing.GetFurnitureLinkName( item.Link )

				stations = setStations[ setName ]
				if nil == stations then
					stations = { }
					setStations[ setName ] = stations
				end

				indexInsert = #stations + 1
				for stationIndex, stationItem in ipairs( stations ) do
					itemName2 = GetItemLinkName( stationItem.Link )
					if itemName < itemName2 then
						indexInsert = stationIndex
						break
					end
				end

				table.insert( stations, indexInsert, item )
			end
		end

		-- Sort the stations by set name, ascending.

		for stationName, _ in pairs( setStations ) do
			table.insert( stationNames, stationName )
		end

		if reverseSort then
			table.sort( stationNames, function ( stationA, stationB ) return stationB < stationA end )
		else
			table.sort( stationNames )
		end

		local numSets = #stationNames
		if 0 >= numSets then
			d( "No attuned stations selected." )
			EHT.Biz.EndProcess()
			return
		end

		local itemDim, itemDimX, itemDimY, itemDimZ, itemId, itemMaxX, itemMaxY, itemMaxZ
		local setMinLengthX, setMinLengthZ

		if usePods then
			setMinLengthX, setMinLengthZ = 450, 450
		elseif useRows then
			setMinLengthX, setMinLengthZ = 800, 360
		end

		local setLengthX, setLengthZ = setMinLengthX + itemSpacingLength, setMinLengthZ + itemSpacingWidth
		local setRowSize = math.min( width, #stationNames )
		local setRows = math.ceil( #stationNames / setRowSize )
		local setOffsetX, setOffsetZ = -0.5 * setRows * setLengthX, -0.5 * setRowSize * setLengthZ
		local setRow, setRowIndex = 0, 0
		local setX, setZ = 0, 0

		for setIndex, stationName in ipairs( stationNames ) do
			stations = setStations[ stationName ]
			itemMaxX, itemMaxY, itemMaxZ = 0, 0, 0

			-- Measure for the maximum X- and Z-dimension of the set's stations.

			for _, item in ipairs( stations ) do
				itemId = EHT.Housing.GetFurnitureItemId( item.Id )
				if nil ~= itemId then
					itemDim = EHT.SavedVars.Dimensions[ itemId ]
					if nil ~= itemDim then
						if itemMaxX < itemDim[EHT.CONST.DIMENSION.X] then itemMaxX = itemDim[EHT.CONST.DIMENSION.X] end
						if itemMaxZ < itemDim[EHT.CONST.DIMENSION.Z] then itemMaxZ = itemDim[EHT.CONST.DIMENSION.Z] end
					end
				end
			end

			if useRows then
				itemMaxX = itemMaxX + 10
			end

			-- Calculate the center point for the set's stations.

			if byColumn then
				setX = ( setLengthX * setRowIndex ) + setOffsetX + ( setLengthX / 2 )
				setZ = ( setLengthZ * setRow ) + setOffsetZ + ( setLengthZ / 2 )
			else
				setX = ( setLengthX * setRow ) + setOffsetX + ( setLengthX / 2 )
				setZ = ( setLengthZ * setRowIndex ) + setOffsetZ + ( setLengthZ / 2 )
			end

			setRowIndex = setRowIndex + 1
			if setRowIndex >= setRowSize then
				setRowIndex = 0
				setRow = setRow + 1
			end

			for stationIndex, item in ipairs( stations ) do
				itemDimX, itemDimY, itemDimZ = 0, 0, 0
				itemId = EHT.Housing.GetFurnitureItemId( item.Id )

				if nil ~= itemId then
					itemDim = EHT.SavedVars.Dimensions[ itemId ]
					if nil ~= itemDim then
						itemDimX, itemDimY, itemDimZ = itemDim[EHT.CONST.DIMENSION.X], itemDim[EHT.CONST.DIMENSION.Y], itemDim[EHT.CONST.DIMENSION.Z]
					end
				end

				itemBefore = EHT.Util.CloneTable( item )
				pitch, yaw, roll = 0, 0, 0

				-- Arrange armor set's stations in aisles.

				y = 3 + itemDimY / 2

				if usePods then
					if 0 == math.abs( itemYaw ) then
						if 1 == stationIndex then
							x, z =  ( itemMaxX / 2 ) + ( setLengthX * 0.08 ),  ( itemMaxZ / 2 )
							yaw = RAD270
						elseif 2 == stationIndex then
							x, z = -( itemMaxX / 2 ) - ( setLengthX * 0.045 ),  ( itemMaxZ / 2 )
							yaw = RAD90
						elseif 3 == stationIndex then
							x, z =  ( itemMaxX / 2 ) + ( setLengthX * 0.1 ), -( itemMaxZ / 2 )
							yaw = RAD270
						else
							x, z = -( itemMaxX / 2 ) - ( setLengthX * 0.1 ), -( itemMaxZ / 2 )
							yaw = RAD90
						end
					else
						if 1 == stationIndex then
							x, z =  ( itemMaxX / 2 ) ,  ( itemMaxZ / 2 )
							yaw = RAD270
						elseif 2 == stationIndex then
							x, z = -( itemMaxX / 2 ) ,  ( itemMaxZ / 2 )
							yaw = RAD90
						elseif 3 == stationIndex then
							x, z =  ( itemMaxX / 2 ) , -( itemMaxZ / 2 )
							yaw = RAD270
						else
							x, z = -( itemMaxX / 2 ) , -( itemMaxZ / 2 )
							yaw = RAD90
						end
					end

					local localYaw = itemYaw > 0 and RAD180 or 0
					yaw = ( yaw + localYaw ) % RAD360
					x, z = x + setX, z + setZ
				elseif useRows then
					yaw = ( math.floor( itemYaw / RAD90 ) * RAD90 ) % RAD360

					if yaw == RAD90 or yaw == RAD270 then
						x, z =  -( itemMaxZ / 2 ),  ( itemMaxX * ( stationIndex - 1 ) ) - ( setLengthX * 0.5 ) + ( itemMaxX * 0.5 )
						x, z = x + setZ, z + setX
					else
						z, x =  -( itemMaxZ / 2 ),  ( itemMaxX * ( stationIndex - 1 ) ) - ( setLengthX * 0.5 ) + ( itemMaxX * 0.5 )
						x, z = x + setX, z + setZ
					end
				end

				pitch, yaw, roll, x, y, z = EHT.Housing.CalculateRotation( shapePitch, shapeYaw, shapeRoll,		pitch, yaw, roll,		x, y, z,		nil, nil, nil,	0, 0, 0 )
				x, y, z = x + originX, y + originY, z + originZ
				item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll = x, y, z, pitch, yaw, roll
				offsetItem( item )

				table.insert( updates, EHT.Util.CloneTable( item ) )
				table.insert( historyBatch, EHT.CT.CreateHistory( EHT.CONST.CHANGE_TYPE.CHANGE, itemBefore, item ) )
			end

			setIndex = setIndex + 1
		end
	elseif build.TemplateName == EHT.CONST.BUILD_TEMPLATE.CYLINDER then
		radius = radius + itemWidth / 2
		local arcPercent = arcLength / 360
		local circumItems
		local indexAngle, indexHeight = 0, 0
		local unitAngle
		local checkerRow = false

		if not autoSpacing then
			circum = 2 * math.pi * radius * arcPercent
			circumItems = math.unnan( math.floor( circum / itemLength ) )
			unitAngle = math.unnan( math.rad( arcLength / circumItems  ) )
		else
			if nil == circum or 1 > circum then circum = 1 end
			circumItems = circum
			unitAngle = math.unnan( math.rad( 360 * arcPercent ) / circum )
		end

		repeat
			item = getNextItem()
			if nil ~= item then
				itemBefore = EHT.Util.CloneTable( item )

				x, y, z = 0, itemHeight * indexHeight, radius
				angle = ( unitAngle / 2 ) + unitAngle * indexAngle
				if checkerPattern and checkerRow then angle = angle + 0.5 * unitAngle end

				pitch, yaw, roll, x, y, z = EHT.Housing.CalculateRotation( 0, angle, 0,							itemPitch, itemYaw, itemRoll,	x, y, z,	nil, nil, nil,	0, 0, 0 )
				pitch, yaw, roll, x, y, z = EHT.Housing.CalculateRotation( shapePitch, shapeYaw, shapeRoll,		pitch, yaw, roll,				x, y, z,	nil, nil, nil,	0, 0, 0 )

				x, y, z = x + originX, y + originY, z + originZ
				item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll = x, y, z, pitch, yaw, roll
				offsetItem( item )

				table.insert( updates, EHT.Util.CloneTable( item ) )
				table.insert( historyBatch, EHT.CT.CreateHistory( EHT.CONST.CHANGE_TYPE.CHANGE, itemBefore, item ) )

				indexAngle = indexAngle + 1
				if indexAngle >= circumItems then
					indexAngle, indexHeight = 0, indexHeight + 1
					checkerRow = not checkerRow
				end
			end
		until nil == item
	elseif build.TemplateName == EHT.CONST.BUILD_TEMPLATE.CONE then
		if nil == circum or 1 > circum then circum = 1 end
		local adjustedCircum = circum
		local radius = radiusStart
		local angle, columnIndex, h, heightIndex = 0, 0, 0, 0
		local unitAngle = math.unnan( RAD360 / circum )

		repeat
			item = getNextItem()
			if nil ~= item then
				itemBefore = EHT.Util.CloneTable( item )
				x, y, z = 0, h, radius

				pitch, yaw, roll, x, y, z = EHT.Housing.CalculateRotation( 0, angle, 0,								itemPitch, itemYaw, itemRoll,	x, y, z,	nil, nil, nil,	0, 0, 0 )
				pitch, yaw, roll, x, y, z = EHT.Housing.CalculateRotation( shapePitch, shapeYaw, shapeRoll,			pitch, yaw, roll,				x, y, z,	nil, nil, nil,	0, 0, 0 )

				x, y, z = x + originX, y + originY, z + originZ
				item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll = x, y, z, pitch, yaw, roll
				offsetItem( item )

				table.insert( updates, EHT.Util.CloneTable( item ) )
				table.insert( historyBatch, EHT.CT.CreateHistory( EHT.CONST.CHANGE_TYPE.CHANGE, itemBefore, item ) )

				angle = angle + unitAngle
				columnIndex = columnIndex + 1

				if columnIndex >= adjustedCircum then
					h = h + itemHeight
					heightIndex = heightIndex + 1
					if heightIndex >= height then break end

					local radiusPercent = radius / radiusStart
					-- adjustedCircum = math.unnan( math.ceil( circum * radiusPercent ) )
					-- if 1 > adjustedCircum then adjustedCircum = 1 end

					radius = radiusStart + math.unnan( ( radiusEnd - radiusStart ) * ( heightIndex / height ) )
					--unitAngle = math.unnan( RAD360 / adjustedCircum )
					columnIndex = 0
					angle = 0
				end
			end
		until nil == item
	elseif build.TemplateName == EHT.CONST.BUILD_TEMPLATE.PYRAMID then
		local originalLength, originalHeight, originalWidth = length, height, width
		local offsetLength, offsetHeight, offsetWidth = 0, 0, 0 -- ( itemLength * 0.5 ), ( itemHeight * 0.5 ), ( itemWidth * 0.5 )
		local shapeLength, shapeHeight, shapeWidth = ( itemLength * length ), ( itemHeight * height ), ( itemWidth * width )
		local midX, midY, midZ = shapeLength * 0.5 - itemLength * 0.5, shapeHeight * 0.5, shapeWidth * 0.5
		local baseLength, baseWidth = 0, 0
		local heightPercent

		local addItem = function( coeff1X, coeff2X, coeffY, coeff1Z, coeff2Z, offsetYaw )
			item = getNextItem()
			if item then
				itemBefore = EHT.Util.CloneTable( item )

				yaw = ( itemYaw + offsetYaw ) % math.rad( 360 )
				x, y, z = coeff1X * itemLength + coeff2X * itemWidth - offsetLength - midX, coeffY * itemHeight - offsetHeight - midY, coeff1Z * itemLength + coeff2Z * itemWidth - offsetLength - midZ

				pitch, yaw, roll, x, y, z = EHT.Housing.CalculateRotation( 0, 0, 0,								itemPitch, yaw, itemRoll,	x, y, z,	nil, nil, nil,	0, 0, 0 )
				pitch, yaw, roll, x, y, z = EHT.Housing.CalculateRotation( shapePitch, shapeYaw, shapeRoll,		pitch, yaw, roll,			x, y, z,	nil, nil, nil,	0, 0, 0 )

				item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll = x + originX, y + originY, z + originZ, pitch, yaw, roll
				offsetItem( item )

				table.insert( updates, EHT.Util.CloneTable( item ) )
				table.insert( historyBatch, EHT.CT.CreateHistory( EHT.CONST.CHANGE_TYPE.CHANGE, itemBefore, item ) )
			end
		end

		for indexY = 1, height do
			for indexX = baseLength + 0.5, length - 0.5 do
				addItem( indexX, 0, indexY, baseWidth, 0.5, math.rad( 180 ) )
				addItem( indexX, 0, indexY, width, -0.5, math.rad( 0 ) )
			end

			for indexZ = baseWidth + 0.5, width - 0.5 do
				addItem( baseLength, -0.5, indexY, indexZ, 0, math.rad( 270 ) )
				addItem( length, 0.5, indexY, indexZ, 0, math.rad( 90 ) )
			end

			if indexY ~= height then
				heightPercent = ( height - indexY ) / height
				length, width = math.max( 1, math.floor( originalLength * heightPercent ) ), math.max( 1, math.floor( originalWidth * heightPercent ) )
				baseLength, baseWidth = ( originalLength - length ) / 2, ( originalWidth - width ) / 2
				length, width = length + baseLength, width + baseWidth
			end
		end
	elseif build.TemplateName == EHT.CONST.BUILD_TEMPLATE.RECTANGLE_OUTLINE or build.TemplateName == EHT.CONST.BUILD_TEMPLATE.CUBE then
		local offsetLength, offsetHeight, offsetWidth  = ( itemLength * 0.5 ), ( itemHeight * 0.5 ), ( itemWidth * 0.5 )
		local shapeLength, shapeHeight, shapeWidth = ( itemLength * length ), ( itemHeight * height ), ( itemWidth * width )
		local midX, midY, midZ = shapeLength * 0.5 - itemLength * 0.5, shapeHeight * 0.5, shapeWidth * 0.5
		if build.TemplateName ~= EHT.CONST.BUILD_TEMPLATE.CUBE then height = 1 end

		local addItem = function( coeff1X, coeff2X, coeffY, coeff1Z, coeff2Z, offsetYaw )
			item = getNextItem()
			if item then
				itemBefore = EHT.Util.CloneTable( item )

				yaw = ( itemYaw + offsetYaw ) % math.rad( 360 )
				x, y, z = coeff1X * itemLength + coeff2X * itemWidth - offsetLength - midX, coeffY * itemHeight - offsetHeight - midY, coeff1Z * itemLength + coeff2Z * itemWidth - offsetLength - midZ

				pitch, yaw, roll, x, y, z = EHT.Housing.CalculateRotation( 0, 0, 0,								itemPitch, yaw, itemRoll,	x, y, z,	nil, nil, nil,	0, 0, 0 )
				pitch, yaw, roll, x, y, z = EHT.Housing.CalculateRotation( shapePitch, shapeYaw, shapeRoll,		pitch, yaw, roll,			x, y, z,	nil, nil, nil,	0, 0, 0 )

				item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll = x + originX, y + originY, z + originZ, pitch, yaw, roll
				offsetItem( item )

				table.insert( updates, EHT.Util.CloneTable( item ) )
				table.insert( historyBatch, EHT.CT.CreateHistory( EHT.CONST.CHANGE_TYPE.CHANGE, itemBefore, item ) )
			end
		end

		for indexY = 1, height do
			for indexX = 0.5, length - 0.5 do
				addItem( indexX, 0, indexY, 0, 0.5, math.rad( 180 ) )
				addItem( indexX, 0, indexY, width, -0.5, math.rad( 0 ) )
			end

			for indexZ = 0.5, width - 0.5 do
				addItem( 0, -0.5, indexY, indexZ, 0, math.rad( 270 ) )
				addItem( length, 0.5, indexY, indexZ, 0, math.rad( 90 ) )
			end
		end
	elseif build.TemplateName == EHT.CONST.BUILD_TEMPLATE.RECTANGLE or build.TemplateName == EHT.CONST.BUILD_TEMPLATE.FLOOR then
		local itemDimX, itemDimZ = itemLength, itemWidth
		local countX, countZ = length, width
		local dimX, dimZ = countX * itemDimX, countZ * itemDimZ
		local offsetX, offsetZ = -1 * dimX / 2 + itemDimX / 2, -1 * dimZ / 2 + itemDimZ / 2
		local xIndex, zIndex = 0, 0, 0

		repeat
			item = getNextItem()
			if item then
				itemBefore = EHT.Util.CloneTable( item )

				x, y, z = offsetX, 0, offsetZ
				x, y, z = x + xIndex * itemDimX, 0, z + zIndex * itemDimZ
				if checkerPattern and 0 == zIndex % 2 then x = x + 0.25 * itemDimX else x = x - 0.25 * itemDimX end

				pitch, yaw, roll, x, y, z = EHT.Housing.CalculateRotation( 0, 0, 0,									itemPitch, itemYaw, itemRoll,	x, y, z,	nil, nil, nil,	0, 0, 0 )
				pitch, yaw, roll, x, y, z = EHT.Housing.CalculateRotation( shapePitch, shapeYaw, shapeRoll,			pitch, yaw, roll,				x, y, z,	nil, nil, nil,	0, 0, 0 )

				x, y, z = x + originX, y + originY, z + originZ
				item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll = x, y, z, pitch, yaw, roll
				offsetItem( item )

				table.insert( updates, EHT.Util.CloneTable( item ) )
				table.insert( historyBatch, EHT.CT.CreateHistory( EHT.CONST.CHANGE_TYPE.CHANGE, itemBefore, item ) )

				xIndex = xIndex + 1
				if xIndex >= countX then
					xIndex = 0
					zIndex = zIndex + 1
				end
			end
		until nil == item
	elseif build.TemplateName == EHT.CONST.BUILD_TEMPLATE.STAIRS then
		local itemDimX, itemDimY, itemDimZ = itemLength, itemHeight, itemWidth
		local dimZ = width * itemDimZ
		local xIndex, yIndex, zIndex = 0, 0, 0

		repeat
			item = getNextItem()
			if item then
				itemBefore = EHT.Util.CloneTable( item )

				x, y, z = 0, 0, -0.5 * itemDimZ
				x, y, z = x + xIndex * itemDimX, y + yIndex * itemDimY, z + zIndex * itemDimZ

				pitch, yaw, roll,	x, y, z = EHT.Housing.CalculateRotation( 0, 0, 0,							itemPitch, itemYaw, itemRoll,	x, y, z,	nil, nil, nil,		0, 0, 0 )
				pitch, yaw, roll,	x, y, z = EHT.Housing.CalculateRotation( shapePitch, shapeYaw, shapeRoll,	pitch, yaw, roll,				x, y, z,	nil, nil, nil,		0, 0, 0 )

				x, y, z = x + originX, y + originY, z + originZ
				item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll = x, y, z, pitch, yaw, roll
				offsetItem( item )

				table.insert( updates, EHT.Util.CloneTable( item ) )
				table.insert( historyBatch, EHT.CT.CreateHistory( EHT.CONST.CHANGE_TYPE.CHANGE, itemBefore, item ) )

				zIndex = zIndex + 1
				if zIndex >= width then
					zIndex = 0
					xIndex = xIndex + 1
					yIndex = yIndex + 1
				end
			end
		until nil == item
	elseif build.TemplateName == EHT.CONST.BUILD_TEMPLATE.WALL then
		local itemDimX, itemDimY = itemLength, itemHeight
		local countX, countY = length, height
		local dimX, dimY = countX * itemDimX, countY * itemDimY
		local offsetX, offsetY = -1 * dimX / 2 + itemDimX / 2, -1 * dimY / 2 + itemDimY / 2
		local xIndex, yIndex = 0, 0, 0

		repeat
			item = getNextItem()
			if nil ~= item then
				itemBefore = EHT.Util.CloneTable( item )

				x, y, z = offsetX, offsetY, 0
				x, y, z = x + xIndex * itemDimX, y + yIndex * itemDimY, 0
				if checkerPattern and 0 == yIndex % 2 then x = x + 0.25 * itemDimX else x = x - 0.25 * itemDimX end

				pitch, yaw, roll, x, y, z = EHT.Housing.CalculateRotation( 0, 0, 0,									itemPitch, itemYaw, itemRoll,	x, y, z,	nil, nil, nil,	0, 0, 0 )
				pitch, yaw, roll, x, y, z = EHT.Housing.CalculateRotation( shapePitch, shapeYaw, shapeRoll,			pitch, yaw, roll,				x, y, z,	nil, nil, nil,	0, 0, 0 )

				x, y, z = x + originX, y + originY, z + originZ
				item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll = x, y, z, pitch, yaw, roll
				offsetItem( item )

				table.insert( updates, EHT.Util.CloneTable( item ) )
				table.insert( historyBatch, EHT.CT.CreateHistory( EHT.CONST.CHANGE_TYPE.CHANGE, itemBefore, item ) )

				xIndex = xIndex + 1
				if xIndex >= countX then
					xIndex = 0
					yIndex = yIndex + 1
				end
			end
		until nil == item
	elseif build.TemplateName == EHT.CONST.BUILD_TEMPLATE.SPIRAL then
		local startCircum = 2 * math.pi * radiusStart
		local radius = radiusStart
		local angle = 0
		local unitRadius = math.unnan( ( radiusEnd - radiusStart ) / totalItems )
		local h = 0

		repeat
			item = getNextItem()
			if item then
				itemBefore = EHT.Util.CloneTable( item )
				x, y, z = 0, h, radius

				pitch, yaw, roll, x, y, z = EHT.Housing.CalculateRotation( 0, angle, 0,								itemPitch, itemYaw, itemRoll,	x, y, z,	nil, nil, nil,	0, 0, 0 )
				pitch, yaw, roll, x, y, z = EHT.Housing.CalculateRotation( shapePitch, shapeYaw, shapeRoll,			pitch, yaw, roll,				x, y, z,	nil, nil, nil,	0, 0, 0 )

				x, y, z = x + originX, y + originY, z + originZ
				item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll = x, y, z, pitch, yaw, roll
				offsetItem( item )

				table.insert( updates, EHT.Util.CloneTable( item ) )
				table.insert( historyBatch, EHT.CT.CreateHistory( EHT.CONST.CHANGE_TYPE.CHANGE, itemBefore, item ) )

				radius = radius + unitRadius
				local circumPercent = math.unnan( 2 * math.pi * radius / startCircum )
				local unitAngle = math.unnan( math.rad( 360 ) / ( circum * circumPercent ) )

				angle = angle + unitAngle
				h = h + itemHeight
			end
		until nil == item
	elseif build.TemplateName == EHT.CONST.BUILD_TEMPLATE.DOME or build.TemplateName == EHT.CONST.BUILD_TEMPLATE.SPHERE then
		radius = radius + itemWidth / 2

		local isSphere = build.TemplateName == EHT.CONST.BUILD_TEMPLATE.SPHERE
		local unitsVertical, unitsHorizontal, countHorizontal = 0, 0, 0
		local radiusH, radiusV = radius, 0.65 * radius
		local origCircum = 2 * math.pi * radiusH
		local checkerRow = false
		local counter = 0
		-- TODO: Add these parameters
		local verticalScale, maxVerticalAngleDegrees, startAngleDegrees

		if nil == arcLength or 0 >= arcLength then arcLength = 360 end
-- /script VERTICAL_CIRCUM, MAX_VERTICAL_ANGLE, MAX_ANGLE, START_ANGLE = 0.5, 90, 90, -42
-- /script VERTICAL_CIRCUM, MAX_VERTICAL_ANGLE, MAX_ANGLE, START_ANGLE = 0.5, 70, 70, -42
		if autoSpacing then
			local circumVert = circum * ( verticalScale or 1 )
			countHorizontal = circum
			unitsHorizontal = math.unnan( math.rad( arcLength / countHorizontal ) )

			if isSphere then
				unitsVertical = math.unnan( math.rad( 180 / math.ceil( totalItems / circumVert ) ) )
			else
				unitsVertical = math.unnan( math.rad( ( maxVerticalAngleDegrees or 90 ) / math.ceil( totalItems / circumVert ) ) )
			end
		else
			circum = 2 * math.pi * radiusV
			unitsVertical = math.unnan( math.rad( 360 / math.ceil( circum / itemHeight ) ) )

			circum = 2 * math.pi * radiusH * ( arcLength / 360 )
			countHorizontal = math.ceil( circum / itemLength )
			unitsHorizontal = math.unnan( math.rad( arcLength / countHorizontal ) )
		end

		local indexHorizontal, indexVertical = 0, 0
		local angleHorizontal, angleVertical = 0, 0

		repeat
			item = getNextItem()
			if nil ~= item then
				angleHorizontal, angleVertical = indexHorizontal * unitsHorizontal, math.rad( startAngleDegrees or 0 ) + ( -1 * indexVertical ) * unitsVertical
				if checkerPattern and checkerRow then angleHorizontal = angleHorizontal + 0.5 * unitsHorizontal end

				itemBefore = EHT.Util.CloneTable( item )
				x, y, z = 0, 0, radiusH

				pitch, yaw, roll, x, y, z = EHT.Housing.CalculateRotation( angleVertical, 0, 0,						itemPitch, itemYaw, itemRoll,	x, y, z,	nil, nil, nil,	0, 0, 0 )
				pitch, yaw, roll, x, y, z = EHT.Housing.CalculateRotation( 0, angleHorizontal, 0,					pitch, yaw, roll,				x, y, z,	nil, nil, nil,	0, 0, 0 )
				pitch, yaw, roll, x, y, z = EHT.Housing.CalculateRotation( shapePitch, shapeYaw, shapeRoll,			pitch, yaw, roll,				x, y, z,	nil, nil, nil,	0, 0, 0 )

				x, y, z = x + originX, y + originY, z + originZ
				item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll = x, y, z, pitch, yaw, roll
				offsetItem( item )

				table.insert( updates, EHT.Util.CloneTable( item ) )
				table.insert( historyBatch, EHT.CT.CreateHistory( EHT.CONST.CHANGE_TYPE.CHANGE, itemBefore, item ) )
				counter = counter + 1
			end

			if isSphere and 0 ~= indexVertical then
				item = getNextItem()
				if item then
					angleHorizontal, angleVertical = indexHorizontal * unitsHorizontal, indexVertical * unitsVertical
					if checkerPattern and checkerRow then angleHorizontal = angleHorizontal + 0.5 * unitsHorizontal end

					itemBefore = EHT.Util.CloneTable( item )
					x, y, z = 0, 0, radiusH

					pitch, yaw, roll, x, y, z = EHT.Housing.CalculateRotation( angleVertical, 0, 0,						itemPitch, itemYaw, itemRoll,	x, y, z,	nil, nil, nil,	0, 0, 0 )
					pitch, yaw, roll, x, y, z = EHT.Housing.CalculateRotation( 0, angleHorizontal, 0,					pitch, yaw, roll,				x, y, z,	nil, nil, nil,	0, 0, 0 )
					pitch, yaw, roll, x, y, z = EHT.Housing.CalculateRotation( shapePitch, shapeYaw, shapeRoll,			pitch, yaw, roll,				x, y, z,	nil, nil, nil,	0, 0, 0 )

					x, y, z = x + originX, y + originY, z + originZ
					item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll = x, y, z, pitch, yaw, roll
					offsetItem( item )

					table.insert( updates, EHT.Util.CloneTable( item ) )
					table.insert( historyBatch, EHT.CT.CreateHistory( EHT.CONST.CHANGE_TYPE.CHANGE, itemBefore, item ) )
					counter = counter + 1
				end
			end

			indexHorizontal = indexHorizontal + 1
			if ( indexHorizontal * unitsHorizontal ) >= math.rad( arcLength ) then
				if checkerPattern then checkerRow = not checkerRow end

				indexHorizontal = 0
				indexVertical = indexVertical + 1

				if ( indexVertical * unitsVertical ) >= math.rad( maxVerticalAngleDegrees or 90 ) then break end

				if not autoSpacing then
					circum = 2 * math.pi * radiusH * ( arcLength / 360 ) * math.cos( ( indexVertical - 1 ) * unitsVertical )

					local newCountHorizontal = math.ceil( circum / itemLength )
					countHorizontal = newCountHorizontal

					unitsHorizontal = math.unnan( math.rad( arcLength / countHorizontal ) )
				end
			end
		until nil == item
	elseif build.TemplateName == EHT.CONST.BUILD_TEMPLATE.DISC then
		local countHorizontal, unitsHorizontal = 0, 0
		local radiusH = radius
		local origCircum = 2 * math.pi * radiusH
		local checkerRow = false

		if nil == arcLength or 0 >= arcLength then arcLength = 360 end

		radiusH = radiusH + ( 0.5 * itemWidth )
		if autoSpacing then
			unitsHorizontal = math.unnan( math.rad( arcLength / totalItems ) )
		else
			circum = ( 2 * math.pi * ( radiusH + itemWidth ) ) * ( arcLength / 360 )
			countHorizontal = math.ceil( circum / itemLength )
			unitsHorizontal = math.unnan( math.rad( arcLength / countHorizontal ) )
		end

		local angleHorizontal, indexHorizontal, indexRing = 0, 0, 0

		repeat
			item = getNextItem()
			if item then
				angleHorizontal = indexHorizontal * unitsHorizontal
				if checkerPattern and checkerRow then angleHorizontal = angleHorizontal + 0.5 * unitsHorizontal end

				itemBefore = EHT.Util.CloneTable( item )
				x, y, z = 0, 0, radiusH

				pitch, yaw, roll, x, y, z = EHT.Housing.CalculateRotation( 0, angleHorizontal, 0,					itemPitch, itemYaw, itemRoll,	x, y, z,	nil, nil, nil,	0, 0, 0 )
				pitch, yaw, roll, x, y, z = EHT.Housing.CalculateRotation( shapePitch, shapeYaw, shapeRoll,			pitch, yaw, roll,				x, y, z,	nil, nil, nil,	0, 0, 0 )

				x, y, z = x + originX, y + originY, z + originZ
				item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll = x, y, z, pitch, yaw, roll
				offsetItem( item )

				table.insert( updates, EHT.Util.CloneTable( item ) )
				table.insert( historyBatch, EHT.CT.CreateHistory( EHT.CONST.CHANGE_TYPE.CHANGE, itemBefore, item ) )
			end

			indexHorizontal = indexHorizontal + 1
			if ( indexHorizontal * unitsHorizontal ) >= math.rad( arcLength ) then
				if checkerPattern then checkerRow = not checkerRow end
				indexHorizontal = 0
				indexRing = indexRing + 1

				radiusH = radius + ( 0.5 * itemWidth ) - ( itemWidth * indexRing )
				if radiusH <= 0 then break end

				if not autoSpacing then
					circum = ( 2 * math.pi * ( radiusH + itemWidth ) ) * ( arcLength / 360 )
					countHorizontal = math.ceil( circum / itemLength )
					unitsHorizontal = math.unnan( math.rad( arcLength / countHorizontal ) )
				end
			end
		until nil == item
	elseif build.TemplateName == EHT.CONST.BUILD_TEMPLATE.TEXT then
		local c, cIndex, lens, columns, rows, messageLen = nil, 1, nil, 1, 1, #message

		for index = 1, messageLen do
			c = string.sub( message, index, index )
			if "\n" == c then
				if cIndex > columns then columns = cIndex end
				cIndex = 1
				rows = rows + 1
			else
				cIndex = cIndex + 1
			end
		end
		if cIndex > columns then columns = cIndex end

		cIndex = 1
		local itemDimX, itemDimY, itemDimZ = orientedItemLength + orientedItemSpacingLength, orientedItemHeight + orientedItemSpacingHeight, orientedItemWidth + orientedItemSpacingWidth
		local charDimX, charDimY, charDimZ = 1 * itemDimX, 2 * itemDimY + 2 * itemDimZ + lineSpacing, itemDimY + 2 * itemDimZ + charSpacing
		local dimX, dimY, dimZ = charDimX, charDimY * rows, charDimZ * columns
		local offsetX, offsetY, offsetZ, offsetPitch, offsetYaw, offsetRoll
		local carriageReturnZ = -0.5 * dimZ
		local cursorX, cursorY, cursorZ = 0, 0.5 * dimY - 0.5 * lineSpacing, carriageReturnZ
		local basePitch = math.rad( 0 )

		local _, _, _, itemDimX45, itemDimY45, itemDimZ45 = EHT.Housing.CalculateRotation( math.rad( 45 ), 0, 0, 0, 0, 0, orientedItemLength, orientedItemHeight, orientedItemWidth, nil, nil, nil, 0, 0, 0 )
		itemDimX45, itemDimY45, itemDimZ45 = math.abs( itemDimX45 * 2 ), math.abs( itemDimY45 * 2 ), math.abs( itemDimZ45 * 2 )

		while cIndex <= messageLen do
			c = string.lower( string.sub( message, cIndex, cIndex ) )
			leds = EHT.CONST.LED_CHARS[ c ]

			if leds then
				for ledIndex, ledBit in ipairs( leds ) do
					if 0 < ledBit then
						item = getNextItem( true )
						if item then
							itemBefore = EHT.Util.CloneTable( item )
							x, y, z, offsetPitch, offsetYaw, offsetRoll = 0, 0, 0, basePitch, 0, 0

							if 1 == ledIndex then
								y, z		=  0.5 * itemDimY - 0.0 * itemDimZ, -0.5 * itemDimY - 0.5 * itemDimZ
							end

							if 2 == ledIndex then
								y, z		= -0.5 * itemDimY - 0.0 * itemDimZ, -0.5 * itemDimY - 0.5 * itemDimZ
							end

							if 3 == ledIndex then
								y, z		=  0.5 * itemDimY - 0.0 * itemDimZ, -0.0 * itemDimY - 0.0 * itemDimZ

								if 3 == ledBit then
									y, z		=  0.3 * itemDimY + 0.0 * itemDimZ,   0.3 * itemDimY + 0.0 * itemDimZ
									offsetPitch	= basePitch + math.rad( 45 )
								end
							end

							if 4 == ledIndex then
								y, z		= -0.5 * itemDimY - 0.0 * itemDimZ, -0.0 * itemDimY - 0.0 * itemDimZ

								if 2 == ledBit then
									y, z		= -0.3 * itemDimY - 0.0 * itemDimZ,  -0.3 * itemDimY + 0.0 * itemDimZ
									offsetPitch	= basePitch + math.rad( 45 )
								end
							end

							if 5 == ledIndex then
								y, z		=  0.5 * itemDimY - 0.0 * itemDimZ,  0.5 * itemDimY + 0.5 * itemDimZ
							end

							if 6 == ledIndex then
								y, z		= -0.5 * itemDimY - 0.0 * itemDimZ,  0.5 * itemDimY + 0.5 * itemDimZ
							end

							if 7 == ledIndex then
								y, z		=  1.0 * itemDimY - 0.2 * itemDimZ,  0.0 * itemDimY + 0.0 * itemDimZ
								offsetPitch	= basePitch + math.rad( 90 )
							end

							if 8 == ledIndex then
								y, z		=  0.0 * itemDimY - 0.0 * itemDimZ,  0.0 * itemDimY + 0.0 * itemDimZ
								offsetPitch	= basePitch + math.rad( 90 )

								if 3 == ledBit then
									y, z		=  0.0 * itemDimY + 0.0 * itemDimZ,   0.5 * itemDimY + 0.0 * itemDimZ
								end
								if 5 == ledBit then
									offsetPitch	= basePitch + math.rad( 45 )
									y, z		=  0.0 * itemDimY - 0.0 * itemDimZ,  -0.0 * itemDimY + 0.0 * itemDimZ
								end
							end

							if 9 == ledIndex then
								y, z		= -1.0 * itemDimY + 0.2 * itemDimZ,  0.0 * itemDimY + 0.0 * itemDimZ
								offsetPitch	= basePitch + math.rad( 90 )
							end

							if 10 == ledIndex then
								y, z		=  0.3 * itemDimY + 0.0 * itemDimZ,  -0.3 * itemDimY + 0.0 * itemDimZ
								offsetPitch	= basePitch - math.rad( 45 )

								if 2 == ledBit or 4 == ledBit then
									offsetPitch	= basePitch + math.rad( 45 )
								end
								if 3 == ledBit or 4 == ledBit then
									y = y + 0.2 * itemDimY
									z = z - 0.1 * itemDimY 
								end
								if 5 == ledBit then
									offsetPitch	= basePitch + math.rad( 90 )
									y, z		=  1.0 * itemDimY - 0.2 * itemDimZ,  -0.3 * itemDimY + 0.0 * itemDimZ
								end
							end

							if 11 == ledIndex then
								y, z		=  0.3 * itemDimY + 0.0 * itemDimZ,   0.3 * itemDimY + 0.0 * itemDimZ
								offsetPitch	= basePitch + math.rad( 45 )

								if 2 == ledBit or 4 == ledBit then
									offsetPitch	= basePitch - math.rad( 45 )
								end
								if 3 == ledBit or 4 == ledBit then
									y = y + 0.2 * itemDimY
									z = z + 0.1 * itemDimY 
								end
								if 5 == ledBit then
									offsetPitch	= basePitch + math.rad( 90 )
									y, z		=  1.0 * itemDimY - 0.2 * itemDimZ,   0.3 * itemDimY + 0.0 * itemDimZ
								end
							end

							if 12 == ledIndex then
								y, z		= -0.3 * itemDimY - 0.0 * itemDimZ,  -0.3 * itemDimY + 0.0 * itemDimZ
								offsetPitch	= basePitch + math.rad( 45 )

								if 2 == ledBit or 4 == ledBit then
									offsetPitch	= basePitch - math.rad( 45 )
								end
								if 3 == ledBit or 4 == ledBit then
									y = y - 0.2 * itemDimY
									z = z - 0.1 * itemDimY 
								end
								if 5 == ledBit then
									offsetPitch	= basePitch + math.rad( 90 )
									y, z		= -1.0 * itemDimY + 0.2 * itemDimZ,  -0.3 * itemDimY + 0.0 * itemDimZ
								end
							end

							if 13 == ledIndex then
								y, z		= -0.3 * itemDimY - 0.0 * itemDimZ,   0.3 * itemDimY + 0.0 * itemDimZ
								offsetPitch	= basePitch - math.rad( 45 )

								if 2 == ledBit or 4 == ledBit then
									offsetPitch	= basePitch + math.rad( 45 )
								end
								if 3 == ledBit or 4 == ledBit then
									y = y - 0.2 * itemDimY
									z = z + 0.1 * itemDimY 
								end
								if 5 == ledBit then
									offsetPitch	= basePitch + math.rad( 90 )
									y, z		= -1.0 * itemDimY + 0.2 * itemDimZ,   0.3 * itemDimY + 0.0 * itemDimZ
								end
							end

--		 777777777777777
--		1 10    3    11 5
--		1  10   3   11  5
--		1   10  3  11   5
--		1    10 3 11    5
--		 888888888888888
--		2    12 4 13    6
--		2   12  4  13   6
--		2  12   4   13  6
--		2 12    4    13 6
--		 999999999999999

							pitch, yaw, roll, offsetX, offsetY, offsetZ =	EHT.Housing.CalculateRotation( offsetPitch, offsetYaw, offsetRoll,	itemPitch, itemYaw, itemRoll,	0, 0, 0,																	nil, nil, nil,	0, 0, 0 )
							pitch, yaw, roll, x, y, z = 					EHT.Housing.CalculateRotation( shapePitch, shapeYaw, shapeRoll,		pitch, yaw, roll,				x + 0 * offsetX + cursorX, y + offsetY + cursorY, z + offsetZ + cursorZ,	nil, nil, nil,	0, 0, 0 )

							x, y, z = x + originX, y + originY, z + originZ
							item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll = x, y, z, pitch, yaw, roll
							offsetItem( item )

							table.insert( updates, EHT.Util.CloneTable( item ) )
							table.insert( historyBatch, EHT.CT.CreateHistory( EHT.CONST.CHANGE_TYPE.CHANGE, itemBefore, item ) )
						end
					end
				end
			end

			if "\n" ~= c then
				cursorZ = cursorZ + charDimZ
			else
				cursorZ = carriageReturnZ
				cursorY = cursorY - charDimY
			end

			cIndex = cIndex + 1
			if nil == item then break end
		end
	elseif build.TemplateName == EHT.CONST.BUILD_TEMPLATE.WAVE then
		local angle, circumference, circumferenceItems, unitAngle
		circumference = math.pow( radiusX + radiusZ, 2 ) * ( math.sqrt( -3 * ( math.pow( radiusX - radiusZ, 2 ) / math.pow( radiusX + radiusZ, 2 ) ) + 4 ) + 10 )
		circumference = 3 * ( math.pow( radiusX - radiusZ, 2 ) / circumference ) + 1
		circumference = math.pi * ( radiusX + radiusZ ) * circumference

		if autoSpacing then
			circumferenceItems = circum
		else
			circumferenceItems = math.unnan( math.ceil( circumference / itemWidth ) )
		end
		unitAngle = math.unnan( ( 2 * math.pi ) / circumferenceItems )

		local xRatio = zo_clamp( itemWidth / radiusX, 0, 1 )
		local zRatio = zo_clamp( itemLength / radiusZ, 0, 1 )

		repeat
			item = getNextItem()
			if item then
				itemBefore = EHT.Util.CloneTable( item )

				angle = ( 2 * math.pi * ( 1 / circumferenceItems ) * index ) % ( 2 * math.pi )
				x = 2 * radiusX * ( index / circumferenceItems )
				z = radiusZ * math.sin( angle )
				y = 0

				pitch, yaw, roll = itemPitch, itemYaw + ( ( angle < math.pi ) and angle or ( ( 2 * math.pi ) - angle ) ), itemRoll
				pitch, yaw, roll, x, y, z = EHT.Housing.CalculateRotation( shapePitch, shapeYaw, shapeRoll,			pitch, yaw, roll,		x, y, z,	nil, nil, nil,		0, 0, 0 )

				x, y, z = x + originX, y + originY, z + originZ
				item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll = x, y, z, pitch, yaw, roll
				offsetItem( item )

				table.insert( updates, EHT.Util.CloneTable( item ) )
				table.insert( historyBatch, EHT.CT.CreateHistory( EHT.CONST.CHANGE_TYPE.CHANGE, itemBefore, item ) )
				index = index + 1
			end
		until nil == item
	elseif build.TemplateName == EHT.CONST.BUILD_TEMPLATE.SCATTER_POSITION then
		local widthX, widthY, widthZ = 2 * radiusX, 2 * radiusY, 2 * radiusZ
		local cellCount = totalItems
		local cellX, cellY, cellZ = math.ceil( widthX / 3 ), math.ceil( widthY / 3 ), math.ceil( widthZ / 3 )
		local cellOffsetX, cellOffsetY, cellOffsetZ = 0.5 * cellX, 0.5 * cellY, 0.5 * cellZ
		local cells = { }

		for cellIndexX = 0, 2 do
			for cellIndexY = 0, 2 do
				for cellIndexZ = 0, 2 do
					table.insert( cells, {
						-radiusX + ( cellX * cellIndexX ), -radiusY + ( cellY * cellIndexY ), -radiusZ + ( cellZ * cellIndexZ ),
						-radiusX + cellX + ( cellX * cellIndexX ), -radiusY + cellY + ( cellY * cellIndexY ), -radiusZ + cellZ + ( cellZ * cellIndexZ ) } )
				end
			end
		end

		local cellsRandom = { }
		while 0 < #cells do
			local index = 1
			if 1 < #cells then
				index = math.random( 1, #cells )
			end
			table.insert( cellsRandom, table.remove( cells, index ) )
		end
		cells = cellsRandom

		local cellIndex = 0
		repeat
			item = getNextItem()
			if item then
				itemBefore = EHT.Util.CloneTable( item )
				local cell = cells[( cellIndex % 27 ) + 1]
				cellIndex = cellIndex + 1

				pitch, yaw, roll = item.Pitch, item.Yaw, item.Roll
				x = cell[1] + ( cell[4] - cell[1] ) * math.random()
				y = cell[2] + ( cell[5] - cell[2] ) * math.random()
				z = cell[3] + ( cell[6] - cell[3] ) * math.random()

				_, _, _, x, y, z = EHT.Housing.CalculateRotation( shapePitch, shapeYaw, shapeRoll,			pitch, yaw, roll,				x, y, z,	nil, nil, nil,	0, 0, 0 )
				x, y, z = x + originX, y + originY, z + originZ
				item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll = x, y, z, pitch, yaw, roll
				offsetItem( item )

				table.insert( updates, EHT.Util.CloneTable( item ) )
				table.insert( historyBatch, EHT.CT.CreateHistory( EHT.CONST.CHANGE_TYPE.CHANGE, itemBefore, item ) )
			end
		until not item
	elseif build.TemplateName == EHT.CONST.BUILD_TEMPLATE.SCATTER_ORIENTATION then
		radiusX, radiusY, radiusZ = math.pi, math.pi, math.pi
		local widthX, widthY, widthZ = 2 * math.pi, 2 * math.pi, 2 * math.pi
		local cellCount = totalItems
		local cellX, cellY, cellZ = math.ceil( widthX / 3 ), math.ceil( widthY / 3 ), math.ceil( widthZ / 3 )
		local cellOffsetX, cellOffsetY, cellOffsetZ = 0.5 * cellX, 0.5 * cellY, 0.5 * cellZ
		local cells = { }

		for cellIndexX = 0, 2 do
			for cellIndexY = 0, 2 do
				for cellIndexZ = 0, 2 do
					table.insert( cells, {
						-radiusX + ( cellX * cellIndexX ), -radiusY + ( cellY * cellIndexY ), -radiusZ + ( cellZ * cellIndexZ ),
						-radiusX + cellX + ( cellX * cellIndexX ), -radiusY + cellY + ( cellY * cellIndexY ), -radiusZ + cellZ + ( cellZ * cellIndexZ ) } )
				end
			end
		end

		local cellsRandom = { }
		while 0 < #cells do
			local index = 1
			if 1 < #cells then
				index = math.random( 1, #cells )
			end
			table.insert( cellsRandom, table.remove( cells, index ) )
		end
		cells = cellsRandom

		local cellIndex = 0
		repeat
			item = getNextItem()
			if item then
				itemBefore = EHT.Util.CloneTable( item )
				local cell = cells[( cellIndex % 27 ) + 1]
				cellIndex = cellIndex + 1

				local cx, cy, cz = EHT.Housing.GetFurnitureCenter( item.Id, item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll )
				pitch = cell[1] + ( cell[4] - cell[1] ) * math.random()
				yaw = cell[2] + ( cell[5] - cell[2] ) * math.random()
				roll = cell[3] + ( cell[6] - cell[3] ) * math.random()
				item.Pitch, item.Yaw, item.Roll = pitch, yaw, roll
				item.X, item.Y, item.Z = EHT.Housing.GetFurniturePositionFromCenter( item.Id, cx, cy, cz, item.Pitch, item.Yaw, item.Roll )

				table.insert( updates, EHT.Util.CloneTable( item ) )
				table.insert( historyBatch, EHT.CT.CreateHistory( EHT.CONST.CHANGE_TYPE.CHANGE, itemBefore, item ) )
			end
		until not item
	end

	if itemIndex < #group and autoStackExcess then
		itemIndex = itemIndex + 1
		local alreadyStacked = true
		local stackX, stackY, stackZ

		for excessItemIndex = itemIndex, maxItemIndex do
			local item = group[ excessItemIndex ]
			if item then
				if not stackX then
					stackX, stackY, stackZ = item.X, item.Y, item.Z
				elseif stackX ~= item.X or stackY ~= item.Y or stackZ ~= item.Z then
					alreadyStacked = false
					break
				end
			end
		end

		if not alreadyStacked then
			--local origin = EHT.Housing.CalculateFurnitureOrigin( group, 1, itemIndex - 1 )
			--local stackX, stackY, stackZ = originX, originY, originZ + 2000
			--if nil ~= origin then stackX, stackY, stackZ = origin.MaxX + 1000, origin.Y, origin.MaxZ end
			--stackX, stackY, stackZ = zo_roundToNearest( stackX, 1000 ), zo_roundToNearest( stackY, 1000 ), zo_roundToNearest( stackZ, 1000 )
			stackX, stackY, stackZ = GetPlayerWorldPositionInHouse()
			stackX = stackX - 500

			while itemIndex <= maxItemIndex do
				local item = group[ itemIndex ]
				if item then
					itemBefore = EHT.Util.CloneTable( item )
					item.X, item.Y, item.Z = stackX, stackY, stackZ
					item.Pitch, item.Yaw, item.Roll = 0, 0, 0
					table.insert( updates, EHT.Util.CloneTable( item ) )
					table.insert( historyBatch, EHT.CT.CreateHistory( EHT.CONST.CHANGE_TYPE.CHANGE, itemBefore, item ) )
				end
				itemIndex = itemIndex + 1
			end
		end
	end

	if nil ~= history and nil ~= historyBatch and 0 < #historyBatch then
		EHT.CT.AddHistory( history )
		EHT.UI.RefreshHistory()
	end

	EHT.ProcessData.Index = 0
	EHT.ProcessData.Group = group
	EHT.ProcessData.Updates = updates
	EHT.ProcessData.Total = #updates
	EHT.ProcessData.Callback = callback

	EHT.Biz.ScheduleProcessActivity( EHT.Biz.BuildProcess, buildDelay )
end

function EHT.Biz.BuildProcess( processId )
	local data = EHT.ProcessData
	if not data or not EHT.Biz.CheckCurrentProcessActivity( processId ) then return nil end

	-- Move parent items before linked children to avoid positional desyncs.
	if not data.SortedDependentList then
		data.Updates = EHT.Housing.SortDependents( data.Updates )
		data.SortedDependentList = true
	end

	local group = data.Updates
	if nil == group or 0 >= #group then
		d( "Selection is empty." )
		EHT.UI.PlaySoundFailure()
		EHT.Biz.EndProcess()
		return nil
	end

	local index, item, id, gItem = nil, nil, nil, nil
	if nil == data.DeferredDelay then data.DeferredDelay = 0 end

	repeat
		index = ( data.Index or 0 ) + 1
		if index > #group then
			EHT.Biz.ScheduleProcessActivity( EHT.Biz.AdjustSelectedFurnitureComplete, data.DeferredDelay )
			return nil
		end

		item = group[ index ]

		if nil ~= item then
			id = EHT.Housing.FindFurnitureId( item.Id )

			if EHT.Housing.HasFurnitureIdChanged( id, item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll, item.SizeX, item.SizeY, item.SizeZ, item.Color, item.Alpha, item.Groups ) then
				if EHT.RecordingSceneFrames then
					gItem = EHT.Data.GetSceneFurniture( item.Id )

					if nil ~= gItem then
						gItem.X, gItem.Y, gItem.Z, gItem.Pitch, gItem.Yaw, gItem.Roll = item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll
						EHT.Biz.InsertSceneFrame()
					end
				end

				gItem = EHT.Data.GetGroupFurniture( item.Id )

				if nil ~= gItem then
					gItem.X, gItem.Y, gItem.Z, gItem.Pitch, gItem.Yaw, gItem.Roll = item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll
					EHT.Housing.SetFurniturePositionAndOrientation( id, item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll )
					EHT.Handlers.OnFurnitureChanged( item )
					EHT.Biz.SetProcessProgress(	index / data.Total )
					data.Index = index

					if not EHT.Housing.IsEffectId( item.Id ) then
						--data.DeferredDelay = data.DeferredDelay + EHT.Setup.GetEditDelay()
						--if data.DeferredDelay >= EHT.Setup.GetMaxDeferredEditDelay() then
						EHT.Biz.ScheduleProcessActivity( EHT.Biz.BuildProcess, data.DeferredDelay )
						--data.DeferredDelay = 0
						return
						--end
					end
				end
			end
		end

		data.Index = index
	until 1 == 0
end

---[ Operations : Undo Last Change ]---

function EHT.Biz.Undo()
	if EHT.Biz.IsUninterruptableProcessRunning() then return nil end

	local house = EHT.Data.GetCurrentHouse()
	if nil == house or nil == house.History then return end

	local historyIndex = house.HistoryIndex or 1
	if historyIndex < 1 then historyIndex = 1 end

	local history = EHT.Util.CloneTable( EHT.Data.DeserializeHistoryRecord( house.History[ historyIndex ] ) )
	if nil == history then
		EHT.UI.ChangeTrackingAlert( "No more changes to undo" )
		EHT.UI.PlaySoundFailure()
		return
	end

	if history and history.Batch then
		if history.Op == EHT.CONST.CHANGE_TYPE.CHANGE then
			for index = #history.Batch, 1, -1 do
				local batchItem = history.Batch[index]
				if "table" == type(batchItem) then
					local state = batchItem.O
					if "table" == type(state) then
						if not EHT.Housing.HasFurnitureIdChanged( batchItem.Id, state[1], state[2], state[3], state[4], state[5], state[6], state[7], state[8], state[9], state[10], state[11], state[14] ) then
							table.remove( history.Batch, index )
						end
					end
				end
			end
		end
	end

	local total = 1
	if "table" == type( history.Batch ) then total = #history.Batch end

	EHT.Pointers.ShowGuidelinesArrows( false )
	EHT.Biz.StartProcess( EHT.PROCESS_NAME.UNDO )
	EHT.ProcessData.BatchIndex = 1
	EHT.ProcessData.House = house
	EHT.ProcessData.History = history
	EHT.ProcessData.HistoryIndex = historyIndex
	EHT.ProcessData.Successes = 0
	EHT.ProcessData.Failures = 0
	EHT.ProcessData.Total = total
	EHT.ProcessData.Messages = { }

	EHT.Biz.ScheduleProcessActivity( EHT.Biz.UndoProcess )
end

function EHT.Biz.UndoProcess( processId )
	local data = EHT.ProcessData
	if not EHT.Biz.CheckCurrentProcessActivity( processId ) or nil == data or nil == data.History then return nil end

	local history, historyRecord = data.History, data.History
	local batchSize = nil == history.Batch and -1 or #history.Batch

	repeat
		if -1 ~= batchSize then
			historyRecord = nil
			local batchIndex = data.BatchIndex

			if nil ~= batchIndex and batchIndex <= batchSize then
				historyRecord = history.Batch[ batchIndex ]
				EHT.Biz.SetProcessProgress(	batchIndex / batchSize )
			else
				EHT.Biz.ScheduleProcessActivity( EHT.Biz.UndoProcessComplete )
				return
			end

			data.BatchIndex = data.BatchIndex + 1
		end

		local success, message = EHT.CT.UndoInt( historyRecord )

		if success then
			data.Successes = data.Successes + 1
			return
		else
			if false == success then
				data.Failures = data.Failures + 1
				table.insert( data.Messages, message )
			else
				data.Successes = data.Successes + 1
			end
		end
	until 0 >= batchSize or data.BatchIndex > batchSize

	EHT.Biz.ScheduleProcessActivity( EHT.Biz.UndoProcessComplete )
end

function EHT.Biz.UndoProcessCallback( processId )
	local data = EHT.ProcessData
	if not EHT.Biz.CheckCurrentProcessActivity( processId ) or nil == data or nil == data.History then return nil end

	local history, historyRecord = data.History, data.History
	if nil ~= history.Batch then
		local batchIndex = data.BatchIndex

		if nil ~= batchIndex and batchIndex <= #history.Batch then
			EHT.Biz.ScheduleProcessActivity( EHT.Biz.UndoProcess )
		else
			EHT.Biz.ScheduleProcessActivity( EHT.Biz.UndoProcessComplete )
		end
	else
		EHT.Biz.ScheduleProcessActivity( EHT.Biz.UndoProcessComplete )
	end
end

function EHT.Biz.UndoProcessComplete( processId )
	local data = EHT.ProcessData
	if not EHT.Biz.CheckCurrentProcessActivity( processId ) or nil == data or nil == data.History then return nil end

	data.House.HistoryIndex = ( data.House.HistoryIndex or 0 ) + 1

	if data.Successes ~= data.Total then
		if 0 < data.Failures then EHT.UI.PlaySoundFailure() end
		df( "Undo: %d changes: %d undone, %d failed.", data.Total, data.Successes, data.Failures )

		if 0 < #data.Messages then
			d( data.Messages[1] )

			if 1 < #data.Messages then
				df( "(%d additional messages suppressed)", ( #data.Messages - 1 ) )
			end
		end
	end

	EHT.UI.RefreshPositionDialog()
	EHT.Biz.EndProcess()
end

---[ Operations : Redo Last Change ]---

function EHT.Biz.Redo()
	if EHT.Biz.IsUninterruptableProcessRunning() then return nil end

	local house = EHT.Data.GetCurrentHouse()
	if nil == house or nil == house.History then return end

	local historyIndex = house.HistoryIndex or 1
	if 1 >= historyIndex then
		EHT.UI.ChangeTrackingAlert( "No more changes to redo" )
		EHT.UI.PlaySoundFailure()
		return
	end

	historyIndex = historyIndex - 1
	house.HistoryIndex = historyIndex

	if historyIndex > #house.History then
		EHT.UI.ChangeTrackingAlert( "No more changes to redo" )
		EHT.UI.PlaySoundFailure()
		return
	end

	local history = EHT.Util.CloneTable( EHT.Data.DeserializeHistoryRecord( house.History[ historyIndex ] ) )

	if nil == history then
		EHT.UI.ChangeTrackingAlert( "No more changes to redo" )
		EHT.UI.PlaySoundFailure()
		return
	end

	if history and history.Batch then
		if history.Op == EHT.CONST.CHANGE_TYPE.CHANGE then
			for index = #history.Batch, 1, -1 do
				local batchItem = history.Batch[index]
				if "table" == type(batchItem) then
					local state = batchItem.N
					if "table" == type(state) then
						if not EHT.Housing.HasFurnitureIdChanged( batchItem.Id, state[1], state[2], state[3], state[4], state[5], state[6], state[7], state[8], state[9], state[10], state[11], state[14] ) then
							table.remove( history.Batch, index )
						end
					end
				end
			end
		end
	end

	EHT.Pointers.ShowGuidelinesArrows( false )

	EHT.Biz.StartProcess( EHT.PROCESS_NAME.REDO )
	EHT.ProcessData.BatchIndex = 1
	EHT.ProcessData.House = house
	EHT.ProcessData.History = history
	EHT.ProcessData.HistoryIndex = historyIndex
	EHT.ProcessData.Successes = 0
	EHT.ProcessData.Failures = 0
	EHT.ProcessData.Total = 0
	EHT.ProcessData.Messages = { }

	EHT.Biz.ScheduleProcessActivity( EHT.Biz.RedoProcess )
end

function EHT.Biz.RedoProcess( processId )
	local data = EHT.ProcessData
	if not EHT.Biz.CheckCurrentProcessActivity( processId ) or nil == data or nil == data.History then return nil end

	local history, historyRecord = data.History, data.History
	local batchSize = nil == history.Batch and -1 or #history.Batch

	repeat

		if -1 ~= batchSize then
			historyRecord = nil
			local batchIndex = data.BatchIndex

			if nil ~= batchIndex and batchIndex <= batchSize then
				historyRecord = history.Batch[ batchIndex ]
				EHT.Biz.SetProcessProgress(	batchIndex / batchSize )
			else
				EHT.Biz.ScheduleProcessActivity( EHT.Biz.RedoProcessComplete )
				return
			end

			data.BatchIndex = data.BatchIndex + 1
		end

		if historyRecord then data.Total = data.Total + 1 end
		local success, message = EHT.CT.RedoInt( historyRecord )

		if success then
			data.Successes = data.Successes + 1
			return
		else
			if false == success then
				data.Failures = data.Failures + 1
				table.insert( data.Messages, message )
			else
				data.Successes = data.Successes + 1
			end
		end
--[[
		if success then
			data.Successes = data.Successes + 1

			if EHT.Housing.IsEffectId( historyRecord.Id ) then
				EHT.Biz.ScheduleProcessActivity( EHT.Biz.RedoProcessCallback, 0 )
			end

			return
		else
			if false == success then
				data.Failures = data.Failures + 1
				table.insert( data.Messages, message )
			else
				data.Successes = data.Successes + 1
			end
		end
]]
	until 0 >= batchSize or data.BatchIndex > batchSize

	EHT.Biz.ScheduleProcessActivity( EHT.Biz.RedoProcessComplete )
end

function EHT.Biz.RedoProcessCallback( processId )
	local data = EHT.ProcessData
	if not EHT.Biz.CheckCurrentProcessActivity( processId ) or nil == data or nil == data.History then return nil end

	local history = data.History
	if nil ~= history.Batch then
		local batchIndex = data.BatchIndex

		if nil ~= batchIndex and batchIndex <= #history.Batch then
			EHT.Biz.ScheduleProcessActivity( EHT.Biz.RedoProcess )
		else
			EHT.Biz.ScheduleProcessActivity( EHT.Biz.RedoProcessComplete )
		end
	else
		EHT.Biz.ScheduleProcessActivity( EHT.Biz.RedoProcessComplete )
	end
end

function EHT.Biz.RedoProcessComplete( processId )
	local data = EHT.ProcessData
	if not EHT.Biz.CheckCurrentProcessActivity( processId ) or nil == data or nil == data.History then return nil end

	if data.Successes ~= data.Total then
		if 0 < data.Failures then EHT.UI.PlaySoundFailure() end
		df( "Redo: %d changes: %d redone, %d failed.", data.Total, data.Successes, data.Failures )

		if 0 < #data.Messages then

			d( data.Messages[1] )

			if 1 < #data.Messages then
				df( "(%d additional messages suppressed)", ( #data.Messages - 1 ) )
			end

		end
	end

	EHT.UI.RefreshPositionDialog()
	EHT.Biz.EndProcess()
end

---[ Operations : Snap to Guidelines ]---

function EHT.Biz.GetSnapToGuidelinesOrientation( id, yaw, offsetYaw )
	if nil == yaw then
		_, yaw, _ = EHT.Housing.GetFurnitureOrientation( id )
	end
	local gridYaw = EHT.Biz.GetGuidelinesYaw()

	return EHT.Housing.NearestRightAngle( yaw + ( offsetYaw or 0 ), gridYaw or 0 )
end

function EHT.Biz.GetSnapToGuidelinesVertex( id, x, y, z, pitch, yaw, roll, offsetX, offsetY, offsetZ )
	offsetX, offsetY, offsetZ = offsetX or 0, offsetY or 0, offsetZ or 0
	local noOffset = 0 == offsetX and 0 == offsetY and 0 == offsetZ

	local s = EHT.SnapToGridState
	if nil == s then s = { } EHT.SnapToGridState = s end

	local curX, curY, curZ = s.X, s.Y, s.Z
	local originX, originY, originZ, baseY = EHT.Pointers.GetLocalGridOrigin()
	if nil == originX or nil == originY or nil == originZ then return curX, curY, curZ end

	local minX, minY, minZ, maxX, maxY, maxZ, offX, offY, offZ = EHT.Housing.GetFurnitureWorldBoundsAndOffset( id, x, y, z, pitch, yaw, roll )
	local centerX, centerY, centerZ = 0.5 * ( minX + maxX ), 0.5 * ( minY + maxY ), 0.5 * ( minZ + maxZ )
	local units = EHT.Biz.GetGuidelinesUnits() or 1
	local x, y, z, yOverride, vertex

	if noOffset and 0.5 * units >= math.abs( minY - baseY ) then
		yOverride = baseY - offY + ( centerY - minY )
	elseif noOffset and 0.5 * units >= math.abs( maxY - baseY ) then
		yOverride = baseY - offY - ( maxY - centerY )
	else
		yOverride = nil
	end

	local dM

	x, y, z = EHT.Pointers.FindLocalGridVertex( centerX, centerY, centerZ, offsetX, offsetY, offsetZ )
	if nil ~= x then
		dM = zo_distance3D( centerX, centerY, centerZ, x, y, z )
		EHT.D( "dist(min): %f (%d, %d, %d)", dM, x, y, z )
	else
		dM = 9999999999
	end

	local function CompareVertex( cX, cY, cZ )
		local tX, tY, tZ = EHT.Pointers.FindLocalGridVertex( cX, cY, cZ, offsetX, offsetY, offsetZ )
		if nil ~= tX then
			local dT = zo_distance3D( cX, cY, cZ, tX, tY, tZ )
			if dT < dM then
				x, y, z, dM = centerX + ( tX - cX ), centerY + ( tY - cY ), centerZ + ( tZ - cZ ), dT
			end
		end
	end
--[[
	CompareVertex( minX, centerY, centerZ )
	CompareVertex( maxX, centerY, centerZ )
	CompareVertex( centerX, centerY, minZ )
	CompareVertex( centerX, centerY, maxZ )
	CompareVertex( minX, centerY, minZ )
	CompareVertex( minX, centerY, maxZ )
	CompareVertex( maxX, centerY, minZ )
	CompareVertex( maxX, centerY, maxZ )

	CompareVertex( minX, minY, centerZ )
	CompareVertex( maxX, minY, centerZ )
	CompareVertex( centerX, minY, minZ )
	CompareVertex( centerX, minY, maxZ )
	CompareVertex( minX, minY, minZ )
	CompareVertex( minX, minY, maxZ )
	CompareVertex( maxX, minY, minZ )
	CompareVertex( maxX, minY, maxZ )

	CompareVertex( minX, maxY, centerZ )
	CompareVertex( maxX, maxY, centerZ )
	CompareVertex( centerX, maxY, minZ )
	CompareVertex( centerX, maxY, maxZ )
	CompareVertex( minX, maxY, minZ )
	CompareVertex( minX, maxY, maxZ )
	CompareVertex( maxX, maxY, minZ )
	CompareVertex( maxX, maxY, maxZ )
]]
	if nil == x then return nil end

	x, y, z = x - offX, y - offY, z - offZ
	if yOverride then y = yOverride end

	local horizontal, vertical = EHT.Biz.AreGuidelinesSnapped()
	if not horizontal then x, z = curX, curZ end
	if not vertical then y = curY end

	return x, y, z, offX, offY, offZ
end

function EHT.Biz.SnapToGuidelines( idOrItem, itemBefore, offsetX, offsetY, offsetZ, offsetYaw )
	local s = EHT.SnapToGridState
	if nil == s then
		s = { }
		EHT.SnapToGridState = s
	end

	local id, item, x, y, z, pitch, yaw, roll
	if "table" ~= type( idOrItem ) then
		id = idOrItem
		x, y, z, pitch, yaw, roll = EHT.Housing.GetFurniturePositionAndOrientation( id )
	else
		id = item.Id
		item = idOrItem
		x, y, z, pitch, yaw, roll = item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll
	end

	local link = EHT.Housing.GetFurnitureLink( id )
	local horizontal, vertical, rotation = EHT.Biz.AreGuidelinesSnapped()
	local gridYaw = EHT.Biz.GetGuidelinesYaw()
	if nil == itemBefore then
		itemBefore = { Id = id, Link = link, X = curX, Y = curY, Z = curZ, Pitch = pitch, Yaw = yaw, Roll = roll }
		local sine, cosine = math.sin( gridYaw ), math.cos( gridYaw )
		local offX, offY, offZ = 0, 0, 0

		if offsetX and 0 ~= offsetX then
			offX, offZ = offX + cosine * offsetX, offZ + sine * offsetX
		end

		if offsetZ and 0 ~= offsetZ then
			offX, offZ = offX + sine * offsetZ, offZ + cosine * offsetZ
		end

		if offsetY and 0 ~= offsetY then
			offY = offY + offsetY
		end
		
		if offsetYaw then
			yaw = yaw + offsetYaw
		end

		x, y, z = x + offX, y + offY, z + offZ
	else
		if rotation then
			yaw = EHT.Biz.GetSnapToGuidelinesOrientation( id, yaw )
		end

		x, y, z = EHT.Biz.GetSnapToGuidelinesVertex( id, x, y, z, pitch, yaw, roll )
	end

	s.Id = id
	EHT.SnappedItemId = id
	EHT.Housing.SetFurniturePositionAndOrientation( id, x, y, z, pitch, yaw, roll )
	EHT.Biz.ShowSnapToGuidelinesArrows( id, x, y, z )
	local SNAPPED = true
	EHT.Handlers.OnFurnitureEditCommitted( { Id = id, Link = link, X = x, Y = y, Z = z, Pitch = pitch, Yaw = yaw, Roll = roll }, itemBefore, SNAPPED )

	return x, y, z, pitch, yaw, roll
end

function EHT.Biz.ShowSnapToGuidelinesArrows( id, x, y, z )
	if nil == id or nil == EHT.UI.Guidelines then
		return
	end

	if nil == x or nil == y or nil == z then
		x, y, z = EHT.Housing.GetFurniturePosition( id )
		x, y, z = x or 0, y or 0, z or 0
	end

	EHT.SnapToGridId = id
	EHT.SnapToGridLink = EHT.Housing.GetFurnitureLink( id )

	local yaw = EHT.Biz.GetGuidelinesYaw()
	local arrows = EHT.UI.Guidelines.Arrows
	local arrow, aX, aY, aZ

	aX, aY, aZ = EHT.Housing.RotateAroundOrigin( 150, 0, 0, 0, yaw, 0 )
	aX, aY, aZ = EHT.World:Get3DPosition( x + aX, y + aY, z + aZ )
	arrow = arrows[1]
	arrow:Set3DRenderSpaceOrientation( 0, yaw, 0 )
	arrow:Set3DRenderSpaceOrigin( aX, aY, aZ )

	aX, aY, aZ = EHT.Housing.RotateAroundOrigin( -150, 0, 0, 0, yaw, 0 )
	aX, aY, aZ = EHT.World:Get3DPosition( x + aX, y + aY, z + aZ )
	arrow = arrows[2]
	arrow:Set3DRenderSpaceOrientation( 0, yaw + math.pi, 0 )
	arrow:Set3DRenderSpaceOrigin( aX, aY, aZ )

	aX, aY, aZ = EHT.Housing.RotateAroundOrigin( 0, 0, -150, 0, yaw, 0 )
	aX, aY, aZ = EHT.World:Get3DPosition( x + aX, y + aY, z + aZ )
	arrow = arrows[3]
	arrow:Set3DRenderSpaceOrientation( 0, yaw + 0.5 * math.pi, 0 )
	arrow:Set3DRenderSpaceOrigin( aX, aY, aZ )

	aX, aY, aZ = EHT.Housing.RotateAroundOrigin( 0, 0, 150, 0, yaw, 0 )
	aX, aY, aZ = EHT.World:Get3DPosition( x + aX, y + aY, z + aZ )
	arrow = arrows[4]
	arrow:Set3DRenderSpaceOrientation( 0, yaw + 1.5 * math.pi, 0 )
	arrow:Set3DRenderSpaceOrigin( aX, aY, aZ )

	aX, aY, aZ = EHT.Housing.RotateAroundOrigin( 0, 150, 0, 0, yaw, 0 )
	aX, aY, aZ = EHT.World:Get3DPosition( x + aX, y + aY, z + aZ )
	arrow = arrows[5]
	arrow:Set3DRenderSpaceOrientation( 0, 0, 0.5 * math.pi )
	arrow:Set3DRenderSpaceOrigin( aX, aY, aZ )

	aX, aY, aZ = EHT.Housing.RotateAroundOrigin( 0, -150, 0, 0, yaw, 0 )
	aX, aY, aZ = EHT.World:Get3DPosition( x + aX, y + aY, z + aZ )
	arrow = arrows[6]
	arrow:Set3DRenderSpaceOrientation( 0, 0, 1.5 * math.pi )
	arrow:Set3DRenderSpaceOrigin( aX, aY, aZ )

	aX, aY, aZ = EHT.Housing.RotateAroundOrigin( -150, -150, -150, 0, 0.5 * math.pi, 0 )
	aX, aY, aZ = EHT.World:Get3DPosition( x + aX, y + aY, z + aZ )
	arrow = arrows[7]
	arrow:Set3DRenderSpaceOrientation( 0.5 * math.pi, 0, 0 )
	arrow:Set3DRenderSpaceOrigin( aX, aY, aZ )

	aX, aY, aZ = EHT.Housing.RotateAroundOrigin( 150, -150, 150, 0, 0.5 * math.pi, 0 )
	aX, aY, aZ = EHT.World:Get3DPosition( x + aX, y + aY, z + aZ )
	arrow = arrows[8]
	arrow:Set3DRenderSpaceOrientation( 0.5 * math.pi, 0, 0 )
	arrow:Set3DRenderSpaceOrigin( aX, aY, aZ )

	EHT.Pointers.ShowGuidelinesArrows( true )
end

function EHT.Biz.SnapToGuidelinesArrowOnClick( index )
	local s = EHT.SnapToGridState
	if nil == s then s = { } EHT.SnapToGridState = s end

	local c = ( EHT.Biz.GetGuidelinesUnits() or 10 ) * 0.5
	local x, y, z, yaw = 0, 0, 0, 0
	if IsShiftKeyDown() or IsControlKeyDown() then c = 1 end

	if 1 == index then
		x = c * 1
	elseif 2 == index then
		x = c * -1
	elseif 3 == index then
		z = c * -1
	elseif 4 == index then
		z = c * 1
	elseif 5 == index then
		y = c * 1
	elseif 6 == index then
		y = c * -1
	elseif 7 == index then
		yaw = math.rad( -90 )
	elseif 8 == index then
		yaw = math.rad( -90 )
	end

	EHT.Biz.SnapToGuidelines( s.Id, nil, x, y, z, yaw )
end

---[ Operations : Selection Arrangement ]---

function EHT.Biz.IsDefaultGroupOperation( option )
	option = EHT.Util.Trim( string.lower( option ) )

	if "" == option or string.lower( EHT.CONST.GROUP_OPERATIONS.DEFAULT ) == option then return true end

	for _, options in pairs( EHT.CONST.GROUP_OPERATIONS ) do
		if "table" == type( options ) and string.lower( options.DEFAULT ) == option then return true end
	end

	return false
end

function EHT.Biz.IsDefaultSceneOperation( option )
	option = EHT.Util.Trim( string.lower( option ) )

	if "" == option or string.lower( EHT.CONST.SCENE_OPERATIONS.DEFAULT ) == option then return true end

	for _, options in pairs( EHT.CONST.SCENE_OPERATIONS ) do
		if "table" == type( options ) and string.lower( options.DEFAULT ) == option then return true end
	end

	return false
end

function EHT.Biz.IsDefaultOperation( option )
	if EHT.Biz.IsDefaultGroupOperation( option ) then return true end
	if EHT.Biz.IsDefaultSceneOperation( option ) then return true end
	return false
end

function EHT.Biz.ArrangeBringToMe()
	if EHT.Biz.IsProcessRunning() then return end

	local _, group = EHT.Data.GetCurrentHouse()
	if nil == group then return end

	local x, y, z = GetPlayerWorldPositionInHouse()
	if nil == x or 0 == x then return end

	if EHT.UI.GetCurrentToolTab() == EHT.CONST.TOOL_TABS.BUILD then
		local build = EHT.Data.GetBuild()
		if nil ~= build then
			build.X, build.Y, build.Z = x, y, z
			EHT.UI.RefreshBuild()
			EHT.Biz.Build( build )
			return
		end
	end

	if EHT.UI.GetCurrentToolTab() == EHT.CONST.TOOL_TABS.ANIMATE then
		local _, _, scene = EHT.Data.GetCurrentHouse()
		if nil ~= scene then
			EHT.Biz.MoveScene( scene, x, y, z )
			return
		end
	end

	local origin = EHT.Housing.CalculateFurnitureBoundsOrigin( group )
	if nil ~= origin and nil ~= origin.X and nil ~= origin.MinY and nil ~= origin.Z then
		local delta = EHT.Housing.DeltaToPlayer( origin )
		EHT.Biz.AdjustSelectedFurniture( delta, 1 )
	end
end

function EHT.Biz.ArrangeCenterOnTarget( targetFurnitureId, callback )
	if EHT.Biz.IsProcessRunning() then return end

	local centerTargetX, centerTargetY, centerTargetZ = EHT.Housing.GetFurnitureCenter( targetFurnitureId )
	if nil == centerTargetX or 0 == centerTargetX then return end

	if EHT.UI.GetCurrentToolTab() == EHT.CONST.TOOL_TABS.ANIMATE then
		local _, _, scene = EHT.Data.GetCurrentHouse()
		if nil ~= scene then
			EHT.Biz.MoveScene( scene, centerTargetX, centerTargetY, centerTargetZ )
		end

		return
	end

	local house, group = EHT.Data.GetCurrentHouse()
	if nil == house or nil == group or 0 >= #group then return end

	local origin = EHT.Housing.CalculateFurnitureBoundsOrigin( group )
	if nil == origin or nil == origin.MinX or 0 == origin.MinX then return end

	if EHT.UI.GetCurrentToolTab() == EHT.CONST.TOOL_TABS.BUILD then
		local build = EHT.Data.GetBuild()
		if nil ~= build then
			build.X, build.Y, build.Z = centerTargetX, centerTargetY, centerTargetZ
			EHT.UI.RefreshBuild()
			EHT.Biz.Build( build )

			return
		end
	end

	local centerX, centerY, centerZ = 0.5 * ( origin.MinX + origin.MaxX ), 0.5 * ( origin.MinY + origin.MaxY ), 0.5 * ( origin.MinZ + origin.MaxZ )
	local adjustX, adjustY, adjustZ = centerTargetX - centerX, centerTargetY - centerY, centerTargetZ - centerZ

	EHT.Biz.CustomAdjustSelectedFurniture( nil, function( item )
		item.X, item.Y, item.Z = item.X + adjustX, item.Y + adjustY, item.Z + adjustZ
	end )
end

function EHT.Biz.ArrangeCenterBetweenTargets( targetFurnitureId1, targetFurnitureId2, callback )
	if EHT.Biz.IsProcessRunning() then return end

	local centerTarget1X, centerTarget1Y, centerTarget1Z = EHT.Housing.GetFurnitureCenter( targetFurnitureId1 )
	if nil == centerTarget1X or 0 == centerTarget1X then return end

	local centerTarget2X, centerTarget2Y, centerTarget2Z = EHT.Housing.GetFurnitureCenter( targetFurnitureId2 )
	if nil == centerTarget2X or 0 == centerTarget2X then return end

	local centerTargetX, centerTargetY, centerTargetZ = 0.5 * ( centerTarget1X + centerTarget2X ), 0.5 * ( centerTarget1Y + centerTarget2Y ), 0.5 * ( centerTarget1Z + centerTarget2Z )

	if EHT.UI.GetCurrentToolTab() == EHT.CONST.TOOL_TABS.ANIMATE then
		local _, _, scene = EHT.Data.GetCurrentHouse()
		if nil ~= scene then
			EHT.Biz.MoveScene( scene, centerTargetX, centerTargetY, centerTargetZ )
		end

		return
	end

	local house, group = EHT.Data.GetCurrentHouse()
	if nil == house or nil == group or 0 >= #group then return end

	if EHT.UI.GetCurrentToolTab() == EHT.CONST.TOOL_TABS.BUILD then
		local build = EHT.Data.GetBuild()
		if nil ~= build then
			build.X, build.Y, build.Z = centerTargetX, centerTargetY, centerTargetZ
			EHT.UI.RefreshBuild()
			EHT.Biz.Build( build )

			return
		end
	end

	local origin = EHT.Housing.CalculateFurnitureBoundsOrigin( group )
	if nil == origin or nil == origin.MinX or 0 == origin.MinX then return end

	local centerX, centerY, centerZ = 0.5 * ( origin.MinX + origin.MaxX ), 0.5 * ( origin.MinY + origin.MaxY ), 0.5 * ( origin.MinZ + origin.MaxZ )
	local adjustX, adjustY, adjustZ = centerTargetX - centerX, centerTargetY - centerY, centerTargetZ - centerZ

	EHT.Biz.CustomAdjustSelectedFurniture( nil, function( item )
		item.X, item.Y, item.Z = item.X + adjustX, item.Y + adjustY, item.Z + adjustZ
	end )
end

function EHT.Biz.FlipSelectedFurniture( axis )
	if EHT.Biz.IsProcessRunning() then return end
	if nil == axis then return end

	local house, group = EHT.Data.GetCurrentHouse()
	if nil == house or nil == group or 0 >= #group then return end

	EHT.Biz.FlipSelectedFurnitureCallback( axis )
	return true
	--if not EHT.Biz.MeasureDimensions( group, function( dimensions ) EHT.Biz.FlipSelectedFurnitureCallback( axis, dimensions ) end ) then return false end
end

function EHT.Biz.FlipSelectedFurnitureCallback( axis )
	if EHT.Biz.IsProcessRunning() then return end
	if nil == axis then return end

	local house, group = EHT.Data.GetCurrentHouse()
	if nil == house or nil == group or 0 >= #group then return end
--[[
	if not EHT.Housing.AreAllItemDimensionsCached( group ) then
		df( "Failed to measure the dimensions of one or more selected items." )
		return
	end
]]
	local origin = EHT.Housing.CalculateFurnitureBoundsOrigin( group )
	if nil == origin or nil == origin.X or 0 == origin.X then return end

	EHT.Biz.CustomAdjustSelectedFurniture( nil, function( item )
		local x, y, z, pitch, yaw, roll = EHT.Housing.GetFurniturePositionAndOrientation( item.Id )
		local itemId = EHT.Housing.GetFurnitureItemId( item.Id )
		if nil ~= x and 0 ~= x then

			local offsetX, offsetY, offsetZ = EHT.Housing.GetFurnitureWorldOffsetByItemId( itemId, pitch, yaw, roll )
			x, y, z = x + offsetX, y + offsetY, z + offsetZ

			x, y, z = EHT.Housing.TranslatePoint( x, y, z, -origin.X, -origin.Y, -origin.Z )

			if axis == EHT.CONST.AXIS.X then
				x = x * -1
				yaw = EHT.Housing.MirrorAngle( yaw, 0 )
				roll = EHT.Housing.MirrorAngle( roll, 0 )
			elseif axis == EHT.CONST.AXIS.Y then
				y = y * -1
				pitch = EHT.Housing.MirrorAngle( pitch, 0 )
				roll = EHT.Housing.MirrorAngle( roll, RAD90 )
			elseif axis == EHT.CONST.AXIS.Z then
				z = z * -1
				yaw = EHT.Housing.MirrorAngle( yaw, RAD90 )
				roll = EHT.Housing.MirrorAngle( roll, 0 )
			end

			x, y, z = EHT.Housing.TranslatePoint( x, y, z, origin.X, origin.Y, origin.Z )

			offsetX, offsetY, offsetZ = EHT.Housing.GetFurnitureWorldOffsetByItemId( itemId, pitch, yaw, roll )
			x, y, z = x - offsetX, y - offsetY, z - offsetZ

			item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll = x, y, z, pitch, yaw, roll
		end
	end )
end

function EHT.Biz.ArrangeStraightenItem( callback )
	if EHT.Biz.IsProcessRunning() then return end

	local id = EHT.QuickActionMenu:GetSelectedFurnitureId()
	if not id then
		return
	end

	EHT.Biz.CustomAdjustSelectedFurniture( nil, function( item )
		local pitch, roll = item.Pitch or 0, item.Roll or 0
		item.Pitch, item.Roll = EHT.Housing.NearestRightAngle( pitch ), EHT.Housing.NearestRightAngle( roll )
	end, callback )
end

function EHT.Biz.CenterOnItem( targetFurnitureId, callback )
	local id = EHT.QuickActionMenu:GetSelectedFurnitureId()
	if not id then
		return
	end

	local f = EHT.QuickActionMenu.Furniture

	if targetFurnitureId then
		local tX, tY, tZ = EHT.Housing.GetFurnitureCenter( targetFurnitureId )
		if tX and tY and tZ then
			local before = EHT.Data.CreateFurniture( id )
			if not before then
				return
			end

			local after = EHT.Util.CloneTable( before )
			local x, y, z = EHT.Housing.GetFurniturePositionFromCenter( id, tX, tY, tZ, f.Pitch, f.Yaw, f.Roll )

			after.X, after.Y, after.Z = x, y, z
			EHT.Housing.SetFurniturePosition( id, x, y, z )
			EHT.Biz.AddChangeHistory( before, after )
		end
	end

	if callback then callback() end
end

function EHT.Biz.CenterBetweenItems( id1, id2, callback )
	local id = EHT.QuickActionMenu:GetSelectedFurnitureId()
	if not id then
		return
	end

	local f = EHT.QuickActionMenu.Furniture

	if id1 and id2 and id1 ~= id2 then
		local x1, y1, z1 = EHT.Housing.GetFurnitureCenter( id1 )
		local x2, y2, z2 = EHT.Housing.GetFurnitureCenter( id2 )

		if x1 and x2 and y1 and y2 and z1 and z2 then
			local cx, cy, cz = x2 - ( 0.5 * ( x2 - x1 ) ), y2 - ( 0.5 * ( y2 - y1 ) ), z2 - ( 0.5 * ( z2 - z1 ) )

			if cx and cy and cz then
				local before = EHT.Data.CreateFurniture( id )
				local after = EHT.Util.CloneTable( before )
				local x, y, z = EHT.Housing.GetFurniturePositionFromCenter( id, cx, cy, cz, f.Pitch, f.Yaw, f.Roll )
				--local ox, oy, oz = EHT.Housing.GetFurnitureWorldOffset( id, f.Pitch, f.Yaw, f.Roll )
				--local x, y, z = cx + ( ox or 0 ), cy + ( oy or 0 ), cz + ( oz or 0 )
				after.X, after.Y, after.Z = x, y, z
				EHT.Housing.SetFurniturePosition( id, x, y, z )
				EHT.Biz.AddChangeHistory( before, after )
			end
		end
	end

	if callback then callback() end
end

function EHT.Biz.AlignWithItem( targetFurnitureId, callback )
	if EHT.Biz.IsProcessRunning() then return end
	if not EHT.QuickActionMenu:GetSelectedFurnitureId() then return end

	local f = EHT.QuickActionMenu.Furniture
	if "table" ~= type(f) then return end

	local pos = { }
	local fX, fY, fZ = EHT.Housing.GetFurnitureCenter( f.Id, f.X, f.Y, f.Z, f.Pitch, f.Yaw, f.Roll )
	local tX, tY, tZ = EHT.Housing.GetFurnitureCenter( targetFurnitureId )
	local distance = zo_distance3D( tX, tY, tZ, fX, fY, fZ )
	local tPitch, tYaw, tRoll = EHT.Housing.GetFurnitureOrientation( targetFurnitureId )

	for pitch = -RAD180, RAD180, RAD90 do
		for yaw = -RAD180, RAD180, RAD90 do
			for roll = -RAD180, RAD180, RAD90 do
				local dPitch, dYaw, dRoll = EHT.Housing.TransformOrientation( pitch, yaw, roll, tPitch, tYaw, tRoll )
				local x, y, z = EHT.Housing.RotateAroundOrigin( distance, 0, 0, dPitch, dYaw, dRoll )
				x, y, z = tX + x, tY + y, tZ + z
				table.insert( pos, { zo_distance3D( x, y, z, fX, fY, fZ ), x, y, z, dPitch, dYaw, dRoll } )
			end
		end
	end

	table.sort( pos, function( a, b ) return a[1] < b[1] end )
	local x, y, z = pos[1][2], pos[1][3], pos[1][4]
	local before = EHT.Data.CreateFurniture( f.Id )
	local after = EHT.Util.CloneTable( before )

	x, y, z = EHT.Housing.GetFurniturePositionFromCenter( f.Id, x, y, z, f.Pitch, f.Yaw, f.Roll )
	after.X, after.Y, after.Z = x, y, z
	EHT.Housing.SetFurniturePosition( f.Id, x, y, z )
	EHT.Biz.AddChangeHistory( before, after )

	if "function" == type( callback ) then
		zo_callLater( function() callback() end, 100 )
	end
end

function EHT.Biz.OrientWithItem( targetFurnitureId, callback )
	if EHT.Biz.IsProcessRunning() then return end

	if not EHT.QuickActionMenu:GetSelectedFurnitureId() then
		return
	end

	local tPitch, tYaw, tRoll = EHT.Housing.GetFurnitureOrientation( targetFurnitureId )
	if not tPitch or not tYaw or not tRoll then return end

	EHT.Biz.CustomAdjustSelectedFurniture( nil, function( item )
		if not EHT.Housing.AreFurnitureIdsEqual( item.Id, targetFurnitureId ) then
			local pitch, yaw, roll = item.Pitch, item.Yaw, item.Roll
			item.Pitch, item.Yaw, item.Roll = EHT.Housing.NearestRightAngle( pitch, tPitch ), EHT.Housing.NearestRightAngle( yaw, tYaw ), EHT.Housing.NearestRightAngle( roll, tRoll )
		end
	end, callback )
end

function EHT.Biz.ArrangeLevelEachWithTarget( targetFurnitureId, callback )
	if EHT.Biz.IsProcessRunning() then return end
	local centerX, centerY, centerZ = EHT.Housing.GetFurnitureCenter( targetFurnitureId )
	local _, targetY = EHT.Housing.GetFurnitureEdgeFromCenter( targetFurnitureId, 0, -1, 0, centerX, centerY, centerZ )
	if nil == targetY or 0 == targetY then return end

	if not EHT.QuickActionMenu:GetSelectedFurnitureId() then
		local house, group = EHT.Data.GetCurrentHouse()
		if nil == house or nil == group or 0 >= #group then return end

		if EHT.UI.GetCurrentToolTab() == EHT.CONST.TOOL_TABS.BUILD then
			local build = EHT.Data.GetBuild()
			if nil ~= build then
				build.Y = targetY
				EHT.UI.RefreshBuild()
				EHT.Biz.Build( build )
				return
			end
		end
	end

	EHT.Biz.CustomAdjustSelectedFurniture( nil, function( item )
		if not EHT.Housing.AreFurnitureIdsEqual( item.Id, targetFurnitureId ) then
			local pitch, yaw, roll = EHT.Housing.LevelOrientation( item.Pitch, item.Yaw, item.Roll )
			local x, y, z = EHT.Housing.GetFurniturePositionFromEdge( item.Id, 0, -1, 0, item.X, targetY, item.Z, pitch, yaw, roll )
			item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll = x, y, z, pitch, yaw, roll
		end
	end, callback )
end

function EHT.Biz.ArrangeLevelGroupWithTarget( targetFurnitureId )
	if EHT.Biz.IsProcessRunning() then return end

	local _, minTargetY, _, _, _, _ = EHT.Housing.GetFurnitureWorldBounds( targetFurnitureId )
	if nil == minTargetY or 0 == minTargetY then return end

	local house, group = EHT.Data.GetCurrentHouse()
	if nil == house or nil == group or 0 >= #group then return end

	if EHT.UI.GetCurrentToolTab() == EHT.CONST.TOOL_TABS.BUILD then
		local build = EHT.Data.GetBuild()
		if nil ~= build then
			build.Y = minTargetY
			EHT.UI.RefreshBuild()
			EHT.Biz.Build( build )

			return
		end
	end

	local origin = EHT.Housing.CalculateFurnitureBoundsOrigin( group )
	if nil == origin or nil == origin.MinY or 0 == origin.MinY then return end

	local adjustY = minTargetY - origin.MinY

	EHT.Biz.CustomAdjustSelectedFurniture( nil, function( item )
		item.Y = item.Y + adjustY
	end )
end

function EHT.Biz.ArrangeAlignEachWithTargetAxis( targetFurnitureId, xAxis, yAxis, zAxis )
	if EHT.Biz.IsProcessRunning() then return end

	local targetX, targetY, targetZ = EHT.Housing.GetFurnitureCenter( targetFurnitureId )
	if nil == targetX or 0 == targetX then return end

	local house, group = EHT.Data.GetCurrentHouse()
	if nil == house or nil == group or 0 >= #group then return end

	EHT.Biz.CustomAdjustSelectedFurniture( nil, function( item )
		local offsetX, offsetY, offsetZ = EHT.Housing.GetFurnitureWorldOffset( item.Id, item.Pitch, item.Yaw, item.Roll )
		local x, y, z = item.X - offsetX, item.Y - offsetY, item.Z - offsetZ
		local yaw = EHT.Biz.GetGuidelinesYaw() or 0

		if xAxis then
			x, y, z = EHT.Housing.RotateAroundOrigin( x - targetX, y - targetY, z - targetZ, 0, -yaw, 0 )
			x = 0
			x, y, z = EHT.Housing.RotateAroundOrigin( x, y, z, 0, yaw, 0 )
			x, y, z = x + targetX + offsetX, y + targetY + offsetY, z + targetZ + offsetZ
			item.X, item.Y, item.Z = x, y, z
		elseif zAxis then
			x, y, z = EHT.Housing.RotateAroundOrigin( x - targetX, y - targetY, z - targetZ, 0, -yaw, 0 )
			z = 0
			x, y, z = EHT.Housing.RotateAroundOrigin( x, y, z, 0, yaw, 0 )
			x, y, z = x + targetX + offsetX, y + targetY + offsetY, z + targetZ + offsetZ
			item.X, item.Y, item.Z = x, y, z
		elseif yAxis then
			item.Y = targetY + offsetY
		end
	end )
end

function EHT.Biz.ArrangeAlignGroupWithTargetAxis( targetFurnitureId, xAxis, yAxis, zAxis )
	if EHT.Biz.IsProcessRunning() then return end

	local targetX, targetY, targetZ = EHT.Housing.GetFurnitureCenter( targetFurnitureId )
	if nil == targetX or 0 == targetX then return end

	local house, group = EHT.Data.GetCurrentHouse()
	if nil == house or nil == group or 0 >= #group then return end

	if EHT.UI.GetCurrentToolTab() == EHT.CONST.TOOL_TABS.ANIMATE then
		local _, _, scene = EHT.Data.GetCurrentHouse()
		if nil ~= scene then

			local centerX, centerY, centerZ = nil, nil, nil
			if xAxis then centerX = targetX end
			if yAxis then centerY = targetY end
			if zAxis then centerZ = targetZ end

			EHT.Biz.MoveScene( scene, centerX, centerY, centerZ )

		end

		return
	end

	local origin = EHT.Housing.CalculateFurnitureOrigin( group, true, nil )
	if nil == origin or nil == origin.X or 0 == origin.X then return end

	if EHT.UI.GetCurrentToolTab() == EHT.CONST.TOOL_TABS.BUILD then
		local build = EHT.Data.GetBuild()
		if nil ~= build then
			if xAxis then build.X = targetX end
			if yAxis then build.Y = targetY end
			if zAxis then build.Z = targetZ end

			EHT.UI.RefreshBuild()
			EHT.Biz.Build( build )

			return
		end
	end

	EHT.Biz.CustomAdjustSelectedFurniture( nil, function( item )
		local offsetX, offsetY, offsetZ = EHT.Housing.GetFurnitureWorldOffset( item.Id, item.Pitch, item.Yaw, item.Roll )
		local itemX, itemY, itemZ = item.X - origin.X, item.Y - origin.Y, item.Z - origin.Z
		local x, y, z = origin.X, origin.Y, origin.Z
		local yaw = EHT.Biz.GetGuidelinesYaw() or 0

		if xAxis then
			x, y, z = EHT.Housing.RotateAroundOrigin( x - targetX, y - targetY, z - targetZ, 0, -yaw, 0 )
			x = 0
			x, y, z = EHT.Housing.RotateAroundOrigin( x, y, z, 0, yaw, 0 )
			x, y, z = x + targetX + itemX, y + targetY + itemY, z + targetZ + itemZ
			item.X, item.Y, item.Z = x, y, z
		elseif zAxis then
			x, y, z = EHT.Housing.RotateAroundOrigin( x - targetX, y - targetY, z - targetZ, 0, -yaw, 0 )
			z = 0
			x, y, z = EHT.Housing.RotateAroundOrigin( x, y, z, 0, yaw, 0 )
			x, y, z = x + targetX + itemX, y + targetY + itemY, z + targetZ + itemZ
			item.X, item.Y, item.Z = x, y, z
		elseif yAxis then
			y = y - targetY
			item.Y = item.Y - y
		end
	end )
end

function EHT.Biz.ArrangeMatchTargetOrientation( targetFurnitureId )
	if EHT.Biz.IsProcessRunning() then return end

	local targetX, targetY, targetZ, targetPitch, targetYaw, targetRoll = EHT.Housing.GetFurniturePositionAndOrientation( targetFurnitureId )
	if nil == targetX or 0 == targetX then return end

	local house, group = EHT.Data.GetCurrentHouse()
	if nil == house or nil == group or 0 >= #group then return end

	EHT.Biz.CustomAdjustSelectedFurniture( nil, function( item )
		item.Pitch, item.Yaw, item.Roll = targetPitch, targetYaw, targetRoll
	end )
end

function EHT.Biz.ArrangeResetEachOrientation()
	if EHT.Biz.IsProcessRunning() then return end

	local house, group = EHT.Data.GetCurrentHouse()
	if nil == house or nil == group or 0 >= #group then return end

	EHT.Biz.CustomAdjustSelectedFurniture( nil, function( item )
		item.Pitch, item.Yaw, item.Roll = 0, 0, 0
	end )
end

---[ Operations : Snap Furniture ]---

function EHT.Biz.SnapFurniture()
	local sfi = EHT.SnapFurnitureItem
	if not sfi then return false end

	local id = sfi.Id
	if not id then return false end

	local o = sfi.Orientations[ sfi.OrientationIndex ]
	if "table" ~= type( o ) then return false end

	local pitch, yaw, roll = sfi.Pitch, sfi.Yaw, sfi.Roll
	local ax, ay, az = sfi.AdjX, sfi.AdjY, sfi.AdjZ
	local x, y, z = o[1], o[2], o[3]

	local m = EHT.SnapFurnitureMargins
	if m then x, y, z = x + ( m.X or 0 ), y + ( m.Y or 0 ), z + ( m.Z or 0 ) end

	EHT.Interop.SuspendFurnitureSnap()

	EHT.Housing.SetFurnitureCenter( id, x, y, z, pitch, yaw, roll )
	EHT.Handlers.OnFurnitureEditCommitted( { Id = id, X = x, Y = y, Z = z, Pitch = pitch, Yaw = yaw, Roll = roll }, sfi.ItemBefore )

	EHT.Pointers.ClearSelected()
	if ax and ay and az then EHT.Pointers.SetSelected( ax, ay, az, 2, 1, 1, 1 ) end

	EHT.Interop.ResumeFurnitureSnap()
end

function EHT.Biz.CalculateSnapAdjacentOrientations()
	local sfi = EHT.SnapFurnitureItem
	if not sfi then return false end

	local items = sfi.AdjacentItems
	if not items then return false end

	local item = items[ sfi.AdjacentItemIndex ]
	if nil == item then return false end

	local id, adjId = sfi.Id, sfi.AdjId
	if not id or not adjId then return false end

	sfi.Orientations = EHT.Housing.GetFurnitureSnapPositions( id, adjId, sfi.X, sfi.Y, sfi.Z, sfi.Pitch, sfi.Yaw, sfi.Roll )
	sfi.OrientationIndex = 0
end

function EHT.Biz.ResetSnapFurniture()
	EHT.SnapFurnitureItem = { }
end

function EHT.Biz.InitSnapFurniture()
	local sfi = EHT.SnapFurnitureItem
	if not sfi then
		sfi = { }
		EHT.SnapFurnitureItem = sfi
	end

	local id = sfi.Id
	local items = sfi.AdjacentItems
	if nil == id or nil == items then
		return false
	end

	local sid = string.fromId64( id )

	for index, item in pairs( items ) do
		if item.Id == sid then
			table.remove( sfi.AdjacentItems, index )
			break
		end
	end

	local x, y, z, pitch, yaw, roll = sfi.X, sfi.Y, sfi.Z, sfi.Pitch, sfi.Yaw, sfi.Roll
	if x and y and z and pitch and yaw and roll then
		sfi.ItemBefore = EHT.Data.CreateFurniture( id, x, y, z, pitch, yaw, roll )
		--EHT.Handlers.OnFurnitureChanged( { Id = id, X = x, Y = y, Z = z, Pitch = pitch, Yaw = yaw, Roll = roll } )
	end

	EHT.UI.ShowSnapFurnitureDialog()
	EHT.Biz.SnapFurnitureNextItem()
end

function EHT.Biz.RefreshSnapFurnitureMargins()
	local sfi = EHT.SnapFurnitureItem
	if nil == sfi then return false end

	local ui = EHT.UI.SnapFurnitureDialog
	if nil == ui then return false end

	local m = EHT.SnapFurnitureMargins
	ui.XMarginValue:SetText( tostring( round( m.X ) ) .. " cm" )
	ui.YMarginValue:SetText( tostring( round( m.Y ) ) .. " cm" )
	ui.ZMarginValue:SetText( tostring( round( m.Z ) ) .. " cm" )
end

function EHT.Biz.GetSnapFurnitureAdjacentItemInfo()
	local sfi = EHT.SnapFurnitureItem
	if nil == sfi then return false end

	local ui = EHT.UI.SnapFurnitureDialog
	if nil == ui then return false end

	local hideUI = true
	local deadlockCounter = 0

	while 10 > deadlockCounter and 0 < sfi.AdjacentItemIndex and #sfi.AdjacentItems >= sfi.AdjacentItemIndex do
		local item = sfi.AdjacentItems[ sfi.AdjacentItemIndex ]
		if nil == item then break end

		sfi.AdjId, sfi.AdjLink, sfi.AdjIcon = item.Id, item.Link, zo_iconFormat( item.Icon )
		sfi.AdjX, sfi.AdjY, sfi.AdjZ = EHT.Housing.GetFurnitureCenter( sfi.AdjId )
		sfi.AdjPitch, sfi.AdjYaw, sfi.AdjRoll = item.Pitch, item.Yaw, item.Roll

		sfi.Pitch, sfi.Yaw, sfi.Roll = EHT.Housing.CalculateSnapOrientation( sfi.Pitch, sfi.Yaw, sfi.Roll, sfi.AdjPitch, sfi.AdjYaw, sfi.AdjRoll )
		sfi.Orientations = EHT.Housing.GetFurnitureSnapPositions( sfi.Id, sfi.AdjId, sfi.X, sfi.Y, sfi.Z, sfi.Pitch, sfi.Yaw, sfi.Roll )
		sfi.OrientationIndex = 1

		EHT.Biz.CalculateSnapAdjacentOrientations()

		if nil ~= sfi.Orientations and 0 < #sfi.Orientations then
			ui.ItemLabel:SetText( sfi.ItemLabel .. " to " .. ( nil ~= sfi.AdjIcon and sfi.AdjIcon or "Item" ) )
			EHT.Biz.RefreshSnapFurnitureMargins()
			hideUI = false
			break
		end

		table.remove( sfi.AdjacentItems, sfi.AdjacentItemIndex )
		if #sfi.AdjacentItems < sfi.AdjacentItemIndex then sfi.AdjacentItemIndex = #sfi.AdjacentItems end
		deadlockCounter = deadlockCounter + 1
	end

	if hideUI then
		EHT.UI.DisplayNotification( "No items are close enough to snap to." )
		EHT.UI.HideSnapFurnitureDialog()
		return false
	else
		return true
	end
end

function EHT.Biz.AdjustSnapFurnitureMargin( margin, delta )
	local m = EHT.SnapFurnitureMargins

	if "X" == margin then
		m.X = m.X + delta
	elseif "Y" == margin then
		m.Y = m.Y + delta
	elseif "Z" == margin then
		m.Z = m.Z + delta
	end

	if m.X > EHT.CONST.SNAP_MARGIN.MAX_X then m.X = EHT.CONST.SNAP_MARGIN.MAX_X end
	if m.X < EHT.CONST.SNAP_MARGIN.MIN_X then m.X = EHT.CONST.SNAP_MARGIN.MIN_X end

	if m.Y > EHT.CONST.SNAP_MARGIN.MAX_Y then m.Y = EHT.CONST.SNAP_MARGIN.MAX_Y end
	if m.Y < EHT.CONST.SNAP_MARGIN.MIN_Y then m.Y = EHT.CONST.SNAP_MARGIN.MIN_Y end

	if m.Z > EHT.CONST.SNAP_MARGIN.MAX_Z then m.Z = EHT.CONST.SNAP_MARGIN.MAX_Z end
	if m.Z < EHT.CONST.SNAP_MARGIN.MIN_Z then m.Z = EHT.CONST.SNAP_MARGIN.MIN_Z end

	EHT.Biz.SnapFurnitureSameItem()
end

function EHT.Biz.SnapFurnitureSameItem()
	local sfi = EHT.SnapFurnitureItem
	if nil == sfi then return false end

	local orientationIndex = sfi.OrientationIndex
	sfi.OrientationIndex = orientationIndex

	EHT.Biz.SnapFurniture()
	EHT.Biz.RefreshSnapFurnitureMargins()
end

function EHT.Biz.SnapFurniturePreviousItem()
	local sfi = EHT.SnapFurnitureItem
	if nil == sfi then return false end

	sfi.AdjacentItemIndex = sfi.AdjacentItemIndex - 1
	if 0 >= sfi.AdjacentItemIndex then sfi.AdjacentItemIndex = #sfi.AdjacentItems end

	-- Skip origin item Id.
	if sfi.AdjacentItems[ sfi.AdjacentItemIndex ].Id == string.fromId64( sfi.Id ) then
		sfi.AdjacentItemIndex = sfi.AdjacentItemIndex - 1
		if 0 >= sfi.AdjacentItemIndex then sfi.AdjacentItemIndex = #sfi.AdjacentItems end
	end

	if not EHT.Biz.GetSnapFurnitureAdjacentItemInfo() then return false end
	EHT.Biz.SnapFurnitureNextOrientation()

	local ui = EHT.UI.SnapFurnitureDialog
	if nil ~= ui then
		ui.SnapItemCount:SetText( string.format( "%d / %d", sfi.AdjacentItemIndex, #sfi.AdjacentItems ) )
	end
end

function EHT.Biz.SnapFurnitureNextItem()
	local sfi = EHT.SnapFurnitureItem
	if nil == sfi then return false end

	sfi.AdjacentItemIndex = sfi.AdjacentItemIndex + 1
	if sfi.AdjacentItemIndex > #sfi.AdjacentItems then sfi.AdjacentItemIndex = 1 end

	-- Skip origin item Id.
	if sfi.AdjacentItems[ sfi.AdjacentItemIndex ].Id == string.fromId64( sfi.Id ) then
		sfi.AdjacentItemIndex = sfi.AdjacentItemIndex + 1
		if sfi.AdjacentItemIndex > #sfi.AdjacentItems then sfi.AdjacentItemIndex = 1 end
	end

	if not EHT.Biz.GetSnapFurnitureAdjacentItemInfo() then return false end
	EHT.Biz.SnapFurnitureNextOrientation()

	local ui = EHT.UI.SnapFurnitureDialog
	if nil ~= ui then
		ui.SnapItemCount:SetText( string.format( "%d / %d", sfi.AdjacentItemIndex, #sfi.AdjacentItems ) )
	end
end

function EHT.Biz.SnapFurniturePreviousOrientation()
	local sfi = EHT.SnapFurnitureItem
	if nil == sfi or nil == sfi.Orientations or 0 >= #sfi.Orientations then return false end

	sfi.OrientationIndex = sfi.OrientationIndex - 1
	if 0 >= sfi.OrientationIndex then sfi.OrientationIndex = #sfi.Orientations end

	EHT.Biz.SnapFurniture()

	local ui = EHT.UI.SnapFurnitureDialog
	if nil ~= ui then
		ui.SnapOrientationCount:SetText( string.format( "%d / %d", sfi.OrientationIndex, #sfi.Orientations ) )
	end
end

function EHT.Biz.SnapFurnitureNextOrientation()
	local sfi = EHT.SnapFurnitureItem
	if nil == sfi or nil == sfi.Orientations or 0 >= #sfi.Orientations then return false end

	sfi.OrientationIndex = sfi.OrientationIndex + 1
	if sfi.OrientationIndex > #sfi.Orientations then sfi.OrientationIndex = 1 end

	EHT.Biz.SnapFurniture()

	local ui = EHT.UI.SnapFurnitureDialog
	if nil ~= ui then
		ui.SnapOrientationCount:SetText( string.format( "%d / %d", sfi.OrientationIndex, #sfi.Orientations ) )
	end
end

---[ Operations : Furniture States ]---

function EHT.Biz.SetFurnitureStates( state, callback, group, itemId )
	if nil == state or EHT.Biz.IsProcessRunning( true ) then return false end

	EHT.Biz.StartProcess( EHT.PROCESS_NAME.CHANGE_FURNITURE_STATE )

	local data = EHT.ProcessData
	data.State = state
	data.Callback = callback
	data.Group = group
	data.ItemId = tonumber( itemId )
	data.CurrentIndex = nil
	data.Count = 0
	data.Total = EHT.Housing.GetNumPlacedStatefulFurniture( group )

	EHT.Biz.ScheduleProcessActivity( EHT.Biz.SetFurnitureStatesProcess, EHT.CONST.HOUSING_STATE_REQUEST_DELAY_MIN )

	return true
end
EHT.SFSS = EHT.Biz.SetFurnitureStates

local function GetNextSetFurnitureStates( data )
	local data = EHT.ProcessData
	local index = data.CurrentIndex
	local id = nil

	if nil == data.Group then
		repeat
			id = EHT.Housing.GetNextFurnitureId( data.CurrentIndex )
			data.CurrentIndex = id

			if nil ~= id and 0 < EHT.Housing.GetFurnitureNumStates( id ) then
				break
			end
		until nil == id
	else
		while nil == id do
			if nil == index then
				data.CurrentIndex = 1
			else
				data.CurrentIndex = index + 1
			end
			index = data.CurrentIndex

			local item = data.Group[ index ]
			if not item then break end

			id = EHT.Housing.FindFurnitureId( item.Id )
			if nil ~= id and 0 >= EHT.Housing.GetFurnitureNumStates( id ) then
				id = nil
			end
		end
	end

	return id
end

function EHT.Biz.SetFurnitureStatesProcess( processId )
	local data = EHT.ProcessData
	if nil == data or not EHT.Biz.CheckCurrentProcessActivity( processId ) then return end

	local match = true
	local id = GetNextSetFurnitureStates()

	while nil ~= id do
		data.Count = data.Count + 1
		EHT.Biz.SetProcessProgress(	data.Count / data.Total )

		if nil ~= data.ItemId then
			local itemId = EHT.Housing.GetFurnitureItemId( id )
			if itemId ~= data.ItemId then match = false end
		end

		if match then
			if nil ~= EHT.Housing.SetFurnitureState( id, data.State ) then
				EHT.Biz.ScheduleProcessActivity( EHT.Biz.SetFurnitureStatesProcess, EHT.CONST.HOUSING_STATE_REQUEST_DELAY_MIN )
				return
			end
		end

		match = true
		id = GetNextSetFurnitureStates()
	end

	EHT.Biz.SetFurnitureStatesComplete()
end

function EHT.Biz.SetFurnitureStatesComplete()
	local data = EHT.ProcessData
	local callback, callbackData

	local callback, callbackData
	if data and data.Callback then
		callback, callbackData = data.Callback, data
	end

	EHT.Biz.EndProcess()

	if callback then
		callback( callbackData )
	end
end

function EHT.Biz.ToggleAll( state )
	local _, numItems = EHT.Housing.GetStatefulFurnitureConditionally( state, false )
	local callback

	if 0 == numItems then
		d( "No items require an update." )
		return
	end

	if 6 < numItems then
		local estTime = ( ( EHT.CONST.HOUSING_STATE_REQUEST_DELAY_MIN or 500 ) * numItems ) / 1000
		df( "Updating %d items (approx %d sec)...", numItems, tonumber( estTime ) )
	end

	callback = function()
		df( "Updated %d items.", numItems )
	end

	EHT.Biz.SetFurnitureStates( state, callback )
end

------[[ Operations : Reset Furniture ]]------

function EHT.Biz.ResetFurniture( group, callback )
	local _, _, isOwner = EHT.Housing.GetHouseInfo()
	if not isOwner then
		df( "You must be the owner of the house." )
		return false
	end

	if EHT.Biz.IsProcessRunning() then return false end

	if nil ~= callback and "function" ~= callback then callback = nil end

	if nil == group or 0 >= #group then
		if callback then callback() end
		return true
	end

	EHT.Biz.StartProcess( EHT.PROCESS_NAME.RESET_FURNITURE )

	local data = EHT.ProcessData
	data.Callback = callback
	data.Group = group
	data.CurrentIndex = 0
	data.Count = 0
	data.Total = #group

	EHT.Biz.ScheduleProcessActivity( EHT.Biz.ResetFurnitureProcess )

	return true
end

function EHT.Biz.ResetFurnitureCallback( processId )
	local data = EHT.ProcessData
	if nil == data or not EHT.Biz.CheckCurrentProcessActivity( processId ) then return end

	local item = data.CurrentItem
	local bagId, slotIndex = EHT.Housing.FindInventoryFurniture( item.Link )

	if nil == bagId or nil == slotIndex then
		df( "Failed to find replacement item in inventory. Operation aborted." )
		df( "Reset %s items.", tostring( data.Count - 1 ) )

		EHT.UI.ShowAlertDialog( "Operation Failed", string.format( "Reset %d items.\nNote: One or more items failed to be reset.", data.Count - 1 ) )
		EHT.Biz.EndProcess()
		EHT.UI.PlaySoundFailure()

		return
	end

	EHT.CT.ReplacedFurnitureHistory = { Id = item.Id }

	local result = EHT.Housing.PlaceItem( bagId, slotIndex, item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll )
	if result ~= HOUSING_REQUEST_RESULT_SUCCESS then
		df( "Failed to replace item from inventory. Operation aborted." )
		df( "Reset %s items.", tostring( data.Count - 1 ) )

		EHT.UI.ShowAlertDialog( "Operation Failed", string.format( "Reset %d items.\nNote: One or more items failed to be reset.", data.Count - 1 ) )
		EHT.Biz.EndProcess()
		EHT.UI.PlaySoundFailure()

		return
	end
end

function EHT.Biz.ResetFurnitureProcess( processId )
	local data = EHT.ProcessData
	if nil == data or not EHT.Biz.CheckCurrentProcessActivity( processId ) then return end

	data.CurrentIndex = data.CurrentIndex + 1

	local item = data.Group[ data.CurrentIndex ]
	if nil == item then

		if nil ~= data.Callback then data.Callback() end
		EHT.Biz.EndProcess()
		return

	end

	data.Count = data.Count + 1
	EHT.Biz.SetProcessProgress(	data.Count / data.Total )

	local id = item.Id
	local i = { }

	data.CurrentItem = i
	i.Id = id
	i.Link = EHT.Housing.GetFurnitureLink( id )
	i.X, i.Y, i.Z, i.Pitch, i.Yaw, i.Roll = EHT.Housing.GetFurniturePositionAndOrientation( id )

	id = EHT.Housing.FindFurnitureId( id )
	local result = EHT.Housing.RemoveFurniture( id )
	if result ~= HOUSING_REQUEST_RESULT_SUCCESS then
		df( "Failed to remove item to inventory. Operation aborted." )
		df( "Reset %s items.", tostring( data.Count - 1 ) )

		EHT.UI.ShowAlertDialog( "Operation Failed", string.format( "Reset %d items.\nNote: One or more items failed to be reset.", data.Count - 1 ) )
		EHT.Biz.EndProcess()
		EHT.UI.PlaySoundFailure()

		return
	end
end

---[ Operations : Trigger Queue ]---

function EHT.Biz.AreTriggersDisabled()
	return EHT.SavedVars.DisableTriggers or 0 >= GetCurrentZoneHouseId() or not HasAnyEditingPermissionsForCurrentHouse()
end

function EHT.Biz.SetDisableTriggers( disabled )
	EHT.SavedVars.DisableTriggers = disabled

	if disabled then
		if EHT.TriggerQueue and 0 < #EHT.TriggerQueue then
			EHT.UI.SetPersistentNotification( "TriggerQueueSize", string.format( "Cleared %d queued trigger action(s).", #EHT.TriggerQueue ), 4000 )
		end
		EHT.TriggerQueue = { }
		EHT.UI.ClearPersistentNotification( "TriggerExecution" )
		EHT.UI.SetPersistentNotification( "DisabledTriggers", "Triggers are currently disabled." )
	else
		EHT.UI.ClearPersistentNotification( "DisabledTriggers" )
	end
end

function EHT.Biz.ResetTrigger()
	local ui = EHT.UI.ToolDialog
	if nil == ui then return end

	ui.TriggerIndex = nil
	ui.TriggerName:SetText( "" )
	ZO_CheckButton_SetCheckState( ui.TriggerRecursion, false )
	ui.TriggerActionTriggerList:SetSelectedItem( EHT.CONST.TRIGGER_DEFAULT_TRIGGER )

	local conditions = ui.Conditions

	for index, condition in ipairs( conditions ) do
		if 1 == index then
			condition.TriggerConditionList:SetSelectedItem( EHT.CONST.TRIGGER_CONDITION.FURNITURE_STATE )
		else
			condition.TriggerConditionList:SetSelectedItem( EHT.CONST.TRIGGER_CONDITION.NONE )
		end

		condition.TriggerConditionDayTime = nil
		condition.TriggerConditionNightTime = nil

		condition.TriggerConditionItemFurnitureId = nil
		condition.TriggerConditionItemIcon:SetText( "" )
		condition.TriggerConditionItem:SetText( "" )
		condition.TriggerConditionStateList:SetSelectedItem( EHT.STATE.ON )
		EHT.Biz.ChooseTriggerItem( index, nil )

		condition.TriggerConditionPositionX = nil
		condition.TriggerConditionPositionY = nil
		condition.TriggerConditionPositionZ = nil
		condition.TriggerConditionPosition:SetText( "" )
		condition.TriggerConditionRadius:SetText( "" )

		condition.TriggerConditionEmoteList:SetSelectedItem( "" )

		condition.TriggerConditionQuickslotLink:SetText( "" )

		condition.TriggerConditionInteractTarget:SetText( "" )
	end

	ui.TriggerActionGroupList:SetSelectedItem( EHT.CONST.TRIGGER_DEFAULT_GROUP )
	ui.TriggerActionGroupStateList:SetSelectedItem( EHT.STATE.ON )
	ui.TriggerActionSceneList:SetSelectedItem( EHT.CONST.TRIGGER_DEFAULT_SCENE )
end

function EHT.Biz.GetNumTriggerConditions( trigger )
	local numConditions = 0

	if nil ~= trigger.Condition.FurnitureId then
		numConditions = numConditions + 1
	end

	if nil ~= trigger.Condition.FurnitureId2 then
		numConditions = numConditions + 1
	end

	if true == trigger.Condition.DayTime or true == trigger.Condition.DayTime2 then
		numConditions = numConditions + 1
	elseif true == trigger.Condition.NightTime or true == trigger.Condition.NightTime2 then
		numConditions = numConditions + 1
	end

	if nil ~= trigger.Condition.Phrase then
		numConditions = numConditions + 1
	end

	if nil ~= trigger.Condition.Emote then
		numConditions = numConditions + 1
	end

	if nil ~= trigger.Condition.QuickslotItem then
		numConditions = numConditions + 1
	end

	if nil ~= trigger.Condition.InteractTarget then
		numConditions = numConditions + 1
	end

	if nil ~= trigger.Condition.InCombat then
		numConditions = numConditions + 1
	end

	if nil ~= trigger.Condition.PopulationChange then
		numConditions = numConditions + 1
	end

	if nil ~= trigger.Condition.X and nil ~= trigger.Condition.Y and nil ~= trigger.Condition.Z then
		numConditions = numConditions + 1
	end

	if nil ~= trigger.Condition.X2 and nil ~= trigger.Condition.Y2 and nil ~= trigger.Condition.Z2 then
		numConditions = numConditions + 1
	end

	return numConditions
end

function EHT.Biz.CreateTrigger()
	EHT.Biz.ResetTrigger()

	zo_callLater( EHT.UI.TriggerChanged, 10 )
	EHT.UI.QueueRefreshTriggers()
end

function EHT.Biz.LoadTrigger( index )
	EHT.Biz.ResetTrigger()

	local ui = EHT.UI.ToolDialog
	if nil == ui then return false end

	local triggers = EHT.Data.GetTriggers()
	if nil == triggers then return false end

	local trigger = triggers[index]
	if nil == trigger then return false end

	ui.TriggerIndex = index
	ui.TriggerName:SetText( trigger.Name )
	ZO_CheckButton_SetCheckState( ui.TriggerRecursion, trigger.Recursion )
	ui.TriggerActionTriggerList:SetSelectedItem( tonumber( trigger.TriggerIdAfter ) )

	local conditionIndex = 1
	local condition = ui.Conditions[conditionIndex]
	local handledFurniture1, handledFurniture2 = false, false

	if nil ~= trigger.Condition.FurnitureId2 and trigger.Condition.State2 == EHT.STATE.TOGGLE then
		condition.TriggerConditionList:SetSelectedItem( EHT.CONST.TRIGGER_CONDITION.FURNITURE_STATE )

		local itemLink = EHT.Housing.GetFurnitureItemIdLink( trigger.Condition.ItemId2 )
		local itemIcon = EHT.Housing.GetFurnitureLinkIcon( itemLink )
		EHT.Biz.ChooseTriggerItem( conditionIndex, trigger.Condition.FurnitureId2, itemLink, itemIcon )
		condition.TriggerConditionStateList:SetSelectedItem( trigger.Condition.State2 )

		if not EHT.Housing.IsValidFurnitureId( trigger.Condition.FurnitureId2, trigger.Condition.ItemId2 ) then
			condition.TriggerConditionItem:SetText( condition.TriggerConditionItem:GetText() .. " |cff3333(Missing)|r" )
		end

		conditionIndex = conditionIndex + 1
		if conditionIndex <= #ui.Conditions then condition = ui.Conditions[conditionIndex] else condition = nil end

		handledFurniture2 = true
	elseif nil ~= trigger.Condition.FurnitureId and trigger.Condition.State == EHT.STATE.TOGGLE then
		condition.TriggerConditionList:SetSelectedItem( EHT.CONST.TRIGGER_CONDITION.FURNITURE_STATE )

		local itemLink = EHT.Housing.GetFurnitureItemIdLink( trigger.Condition.ItemId )
		local itemIcon = EHT.Housing.GetFurnitureLinkIcon( itemLink )
		EHT.Biz.ChooseTriggerItem( conditionIndex, trigger.Condition.FurnitureId, itemLink, itemIcon )
		condition.TriggerConditionStateList:SetSelectedItem( trigger.Condition.State )

		if not EHT.Housing.IsValidFurnitureId( trigger.Condition.FurnitureId, trigger.Condition.ItemId ) then
			condition.TriggerConditionItem:SetText( condition.TriggerConditionItem:GetText() .. " |cff3333(Missing)|r" )
		end

		conditionIndex = conditionIndex + 1
		if conditionIndex <= #ui.Conditions then condition = ui.Conditions[conditionIndex] else condition = nil end

		handledFurniture1 = true
	end

	if true == trigger.Condition.DayTime then
		condition.TriggerConditionDayTime = true
		condition.TriggerConditionList:SetSelectedItem( EHT.CONST.TRIGGER_CONDITION.DAY_TIME )

		conditionIndex = conditionIndex + 1
		if conditionIndex <= #ui.Conditions then condition = ui.Conditions[conditionIndex] else condition = nil end
	elseif true == trigger.Condition.NightTime then
		condition.TriggerConditionNightTime = true
		condition.TriggerConditionList:SetSelectedItem( EHT.CONST.TRIGGER_CONDITION.NIGHT_TIME )

		conditionIndex = conditionIndex + 1
		if conditionIndex <= #ui.Conditions then condition = ui.Conditions[conditionIndex] else condition = nil end
	end

	if nil ~= trigger.Condition.Phrase then
		condition.TriggerConditionList:SetSelectedItem( EHT.CONST.TRIGGER_CONDITION.PHRASE )
		condition.TriggerConditionPhrase:SetText( trigger.Condition.Phrase )

		conditionIndex = conditionIndex + 1
		if conditionIndex <= #ui.Conditions then condition = ui.Conditions[conditionIndex] else condition = nil end
	end

	if nil ~= trigger.Condition.Emote then
		condition.TriggerConditionList:SetSelectedItem( EHT.CONST.TRIGGER_CONDITION.EMOTE )
		condition.TriggerConditionEmoteList:SetSelectedItem( trigger.Condition.Emote )

		conditionIndex = conditionIndex + 1
		if conditionIndex <= #ui.Conditions then condition = ui.Conditions[conditionIndex] else condition = nil end
	end

	if nil ~= trigger.Condition.QuickslotItem then
		condition.TriggerConditionList:SetSelectedItem( EHT.CONST.TRIGGER_CONDITION.QUICKSLOT )
		condition.TriggerConditionQuickslotLink:SetText( trigger.Condition.QuickslotItem )

		conditionIndex = conditionIndex + 1
		if conditionIndex <= #ui.Conditions then condition = ui.Conditions[conditionIndex] else condition = nil end
	end

	if nil ~= trigger.Condition.InteractTarget then
		condition.TriggerConditionList:SetSelectedItem( EHT.CONST.TRIGGER_CONDITION.INTERACT_TARGET )
		condition.TriggerConditionInteractTarget:SetText( trigger.Condition.InteractTarget )

		conditionIndex = conditionIndex + 1
		if conditionIndex <= #ui.Conditions then condition = ui.Conditions[conditionIndex] else condition = nil end
	end

	if nil ~= trigger.Condition.InCombat then
		if trigger.Condition.InCombat then
			condition.TriggerConditionList:SetSelectedItem( EHT.CONST.TRIGGER_CONDITION.ENTER_COMBAT )
		else
			condition.TriggerConditionList:SetSelectedItem( EHT.CONST.TRIGGER_CONDITION.LEAVE_COMBAT )
		end

		conditionIndex = conditionIndex + 1
		if conditionIndex <= #ui.Conditions then condition = ui.Conditions[conditionIndex] else condition = nil end
	end

	if nil ~= trigger.Condition.PopulationChange then
		if 0 < trigger.Condition.PopulationChange then
			condition.TriggerConditionList:SetSelectedItem( EHT.CONST.TRIGGER_CONDITION.GUEST_ARRIVES )
		else
			condition.TriggerConditionList:SetSelectedItem( EHT.CONST.TRIGGER_CONDITION.GUEST_DEPARTS )
		end

		conditionIndex = conditionIndex + 1
		if conditionIndex <= #ui.Conditions then condition = ui.Conditions[conditionIndex] else condition = nil end
	end

	if nil ~= trigger.Condition.X and nil ~= trigger.Condition.Y and nil ~= trigger.Condition.Z then
		if nil ~= trigger.Condition.RadiusEnter then
			condition.TriggerConditionList:SetSelectedItem( EHT.CONST.TRIGGER_CONDITION.ENTER_POSITION )
			condition.TriggerConditionRadius:SetText( string.format( "%.2f", trigger.Condition.RadiusEnter ) )
		elseif nil ~= trigger.Condition.RadiusExit then
			condition.TriggerConditionList:SetSelectedItem( EHT.CONST.TRIGGER_CONDITION.LEAVE_POSITION )
			condition.TriggerConditionRadius:SetText( string.format( "%.2f", trigger.Condition.RadiusExit ) )
		end

		EHT.Biz.ChooseTriggerPosition( conditionIndex, false, trigger.Condition.X, trigger.Condition.Y, trigger.Condition.Z )

		conditionIndex = conditionIndex + 1
		if conditionIndex <= #ui.Conditions then condition = ui.Conditions[conditionIndex] else condition = nil end
	end

	if nil ~= trigger.Condition.X2 and nil ~= trigger.Condition.Y2 and nil ~= trigger.Condition.Z2 then
		if nil ~= trigger.Condition.RadiusEnter2 then
			condition.TriggerConditionList:SetSelectedItem( EHT.CONST.TRIGGER_CONDITION.ENTER_POSITION )
			condition.TriggerConditionRadius:SetText( string.format( "%.2f", trigger.Condition.RadiusEnter2 ) )
		elseif nil ~= trigger.Condition.RadiusExit then
			condition.TriggerConditionList:SetSelectedItem( EHT.CONST.TRIGGER_CONDITION.LEAVE_POSITION )
			condition.TriggerConditionRadius:SetText( string.format( "%.2f", trigger.Condition.RadiusExit2 ) )
		end

		EHT.Biz.ChooseTriggerPosition( conditionIndex, false, trigger.Condition.X2, trigger.Condition.Y2, trigger.Condition.Z2 )

		conditionIndex = conditionIndex + 1
		if conditionIndex <= #ui.Conditions then condition = ui.Conditions[conditionIndex] else condition = nil end
	end

	if not handledFurniture1 and nil ~= trigger.Condition.FurnitureId then
		condition.TriggerConditionList:SetSelectedItem( EHT.CONST.TRIGGER_CONDITION.FURNITURE_STATE )

		local itemLink = EHT.Housing.GetFurnitureItemIdLink( trigger.Condition.ItemId )
		local itemIcon = EHT.Housing.GetFurnitureLinkIcon( itemLink )
		EHT.Biz.ChooseTriggerItem( conditionIndex, trigger.Condition.FurnitureId, itemLink, itemIcon )
		condition.TriggerConditionStateList:SetSelectedItem( trigger.Condition.State )

		if not EHT.Housing.IsValidFurnitureId( trigger.Condition.FurnitureId, trigger.Condition.ItemId ) then
			condition.TriggerConditionItem:SetText( condition.TriggerConditionItem:GetText() .. " |cff3333(Missing)|r" )
		end

		conditionIndex = conditionIndex + 1
		if conditionIndex <= #ui.Conditions then condition = ui.Conditions[conditionIndex] else condition = nil end
	end

	if not handledFurniture2 and nil ~= trigger.Condition.FurnitureId2 then
		condition.TriggerConditionList:SetSelectedItem( EHT.CONST.TRIGGER_CONDITION.FURNITURE_STATE )

		local itemLink = EHT.Housing.GetFurnitureItemIdLink( trigger.Condition.ItemId2 )
		local itemIcon = EHT.Housing.GetFurnitureLinkIcon( itemLink )
		EHT.Biz.ChooseTriggerItem( conditionIndex, trigger.Condition.FurnitureId2, itemLink, itemIcon )
		condition.TriggerConditionStateList:SetSelectedItem( trigger.Condition.State2 )

		if not EHT.Housing.IsValidFurnitureId( trigger.Condition.FurnitureId2, trigger.Condition.ItemId2 ) then
			condition.TriggerConditionItem:SetText( condition.TriggerConditionItem:GetText() .. " |cff3333(Missing)|r" )
		end

		conditionIndex = conditionIndex + 1
		if conditionIndex <= #ui.Conditions then condition = ui.Conditions[conditionIndex] else condition = nil end
	end

	if true == trigger.Condition.DayTime2 then
		condition.TriggerConditionDayTime = true
		condition.TriggerConditionList:SetSelectedItem( EHT.CONST.TRIGGER_CONDITION.DAY_TIME )

		conditionIndex = conditionIndex + 1
		if conditionIndex <= #ui.Conditions then condition = ui.Conditions[conditionIndex] else condition = nil end
	elseif true == trigger.Condition.NightTime2 then
		condition.TriggerConditionNightTime = true
		condition.TriggerConditionList:SetSelectedItem( EHT.CONST.TRIGGER_CONDITION.NIGHT_TIME )

		conditionIndex = conditionIndex + 1
		if conditionIndex <= #ui.Conditions then condition = ui.Conditions[conditionIndex] else condition = nil end
	end

	if 2 == conditionIndex then condition.TriggerConditionList:SetSelectedItem( EHT.CONST.TRIGGER_CONDITION.NONE ) end

	if nil ~= trigger.Action.GroupName then
		ui.TriggerActionGroupList:SetSelectedItem( trigger.Action.GroupName )
		ui.TriggerActionGroupStateList:SetSelectedItem( trigger.Action.GroupState )
	end

	if nil ~= trigger.Action.SceneName then
		ui.TriggerActionSceneList:SetSelectedItem( trigger.Action.SceneName )
	end

	zo_callLater( EHT.UI.TriggerChanged, 10 )
	EHT.UI.QueueRefreshTriggers()
end

function EHT.Biz.DeleteTrigger()
	local ui = EHT.UI.ToolDialog
	if nil == ui then return end

	local triggers = EHT.Data.GetTriggers()
	if nil == triggers then
		EHT.UI.ShowAlertDialog( "Delete Failed", "You must be in a house that you own." )
		return
	end

	local index = ui.TriggerIndex
	if nil == index or 0 >= index or index > #triggers then
		EHT.UI.ShowAlertDialog( "Select A Trigger", "Select a trigger to delete." )
		return
	end

	table.remove( triggers, index )
	ui.TriggerIndex = nil

	EHT.Biz.CreateTrigger()
end

function EHT.Biz.SaveTrigger()
	local ui = EHT.UI.ToolDialog
	if nil == ui then return end

	local saveData = { }
	local trigger, triggerIndex, message

	local name = ui.TriggerName:GetText()
	local allowRecursion = ZO_CheckButton_IsChecked( ui.TriggerRecursion )
	local triggerIdAfter = ui.TriggerActionTriggerList:GetSelectedItemValue()
	local groupName = ui.TriggerActionGroupList:GetSelectedItem()
	local groupState = ui.TriggerActionGroupStateList:GetSelectedItem()
	local sceneName = ui.TriggerActionSceneList:GetSelectedItem()

	for index, condition in ipairs( ui.Conditions ) do
		local conditionType = EHT.Util.Trim( condition.TriggerConditionList:GetSelectedItem() )
		local phrase = nil
		local inCombat = nil
		local dayTime, dayTime2 = nil, nil
		local nightTime, nightTime2 = nil, nil
		local populationChange = nil
		local furnitureId = condition.TriggerConditionItemFurnitureId
		local state = condition.TriggerConditionStateList:GetSelectedItem()
		local position = nil
		local radiusEnter, radiusExit = nil
		local emoteSlashName = condition.TriggerConditionEmoteList:GetSelectedItem()
		local quickslotItem = condition.TriggerConditionQuickslotLink:GetText()
		local interactTarget = condition.TriggerConditionInteractTarget:GetText()

		if "" == emoteSlashName then emoteSlashName = nil end
		if "" == quickslotItem or nil ~= string.find( quickslotItem, "No item selected" ) then quickslotItem = nil end
		if "" == interactTarget or nil ~= string.find( interactTarget, "No target selected" ) then interactTarget = nil end

		if conditionType == EHT.CONST.TRIGGER_CONDITION.DAY_TIME then
			if 1 == index then
				dayTime = true
			elseif 2 == index then
				dayTime2 = true
			end
		elseif conditionType == EHT.CONST.TRIGGER_CONDITION.NIGHT_TIME then
			if 1 == index then
				nightTime = true
			elseif 2 == index then
				nightTime2 = true
			end
		end

		if conditionType == EHT.CONST.TRIGGER_CONDITION.ENTER_COMBAT or conditionType == EHT.CONST.TRIGGER_CONDITION.LEAVE_COMBAT then
			inCombat = conditionType == EHT.CONST.TRIGGER_CONDITION.ENTER_COMBAT
		end

		if conditionType == EHT.CONST.TRIGGER_CONDITION.GUEST_ARRIVES or conditionType == EHT.CONST.TRIGGER_CONDITION.GUEST_DEPARTS then
			populationChange = conditionType == EHT.CONST.TRIGGER_CONDITION.GUEST_ARRIVES and 1 or -1
		end

		if conditionType == EHT.CONST.TRIGGER_CONDITION.PHRASE then
			phrase = EHT.Util.Trim( condition.TriggerConditionPhrase:GetText() )
		end

		if conditionType == EHT.CONST.TRIGGER_CONDITION.ENTER_POSITION or conditionType == EHT.CONST.TRIGGER_CONDITION.LEAVE_POSITION then
			if nil ~= condition.TriggerConditionPositionX and nil ~= condition.TriggerConditionPositionY and nil ~= condition.TriggerConditionPositionZ then
				position = { X = condition.TriggerConditionPositionX, Y = condition.TriggerConditionPositionY, Z = condition.TriggerConditionPositionZ }
			end

			if conditionType == EHT.CONST.TRIGGER_CONDITION.ENTER_POSITION then
				radiusEnter = tonumber( condition.TriggerConditionRadius:GetText() )
			else
				radiusExit = tonumber( condition.TriggerConditionRadius:GetText() )
			end

			if nil ~= radiusEnter then radiusEnter = math.abs( radiusEnter ) end
			if nil ~= radiusExit then radiusExit = math.abs( radiusExit ) end
		end

		if dayTime then
			saveData.dayTime = true
		elseif dayTime2 then
			saveData.dayTime2 = true
		elseif nightTime then
			saveData.nightTime = true
		elseif nightTime2 then
			saveData.nightTime2 = true
		elseif furnitureId then
			if not saveData.furnitureId then
				saveData.furnitureId, saveData.state = furnitureId, state
			else
				saveData.furnitureId2, saveData.state2 = furnitureId, state
			end
		elseif phrase then
			if saveData.phrase then
				message = "Only one Phrase condition may be used."
				break
			else
				saveData.phrase = phrase
			end
		elseif position then
			if not saveData.position then
				saveData.position, saveData.radiusEnter, saveData.radiusExit = position, radiusEnter, radiusExit
			else
				saveData.position2, saveData.radiusEnter2, saveData.radiusExit2 = position, radiusEnter, radiusExit
			end
		elseif emoteSlashName then
			if saveData.emoteSlashName then
				message = "Only one Emote condition may be used."
				break
			else
				saveData.emoteSlashName = emoteSlashName
			end
		elseif quickslotItem then
			if saveData.quickslotItem then
				message = "Only one Quickslot Item condition may be used."
				break
			else
				saveData.quickslotItem = quickslotItem
			end
		elseif interactTarget then
			if saveData.interactTarget then
				message = "Only one Interaction Target condition may be used."
				break
			else
				saveData.interactTarget = interactTarget
			end
		elseif populationChange then
			if saveData.populationChange then
				message = "Only one Population Change condition may be used."
				break
			else
				saveData.populationChange = populationChange
			end
		elseif nil ~= inCombat then
			if nil ~= saveData.inCombat then
				message = "Only one Combat State condition may be used."
				break
			else
				saveData.inCombat = inCombat
			end
		end
	end

	if groupName == EHT.CONST.TRIGGER_DEFAULT_GROUP then groupName = nil end
	if sceneName == EHT.CONST.TRIGGER_DEFAULT_SCENE then sceneName = nil end

	if nil == message then
		trigger, triggerIndex, message = EHT.Data.SaveTrigger(
			ui.TriggerIndex, name, allowRecursion, triggerIdAfter,

			saveData.furnitureId, saveData.state,
			saveData.furnitureId2, saveData.state2,
			saveData.position, saveData.radiusEnter, saveData.radiusExit,
			saveData.position2, saveData.radiusEnter2, saveData.radiusExit2,
			saveData.emoteSlashName,
			saveData.quickslotItem,
			saveData.interactTarget,
			saveData.inCombat,
			saveData.populationChange,
			saveData.phrase,
			saveData.dayTime, saveData.dayTime2,
			saveData.nightTime, saveData.nightTime2,

			groupName, groupState,
			sceneName )
	end

	if nil == message then
		ui.TriggerIndex = triggerIndex

		EHT.UI.QueueRefreshTriggers()
		EHT.UI.TriggerChanged()

		EHT.UI.ShowAlertDialog( "Trigger Saved", "Trigger saved." )
	else
		EHT.UI.ShowAlertDialog( "Trigger Save Failed", string.format( "Failed to save trigger:\n%s", message or "Unknown error." ) )
	end
end

function EHT.Biz.ChooseTriggerItem( index, furnitureId, link, icon )
	local ui = EHT.UI.ToolDialog
	if nil == ui then return end

	local uic = ui.Conditions[index]

	if ( nil == link or nil == icon ) and nil ~= furnitureId then
		if 0 >= EHT.Housing.GetFurnitureNumStates( furnitureId ) then
			EHT.UI.PlaySoundFailure()
			EHT.UI.ShowAlertDialog( "Invalid Item", "The selected item cannot be toggled on or off." )
			return
		end

		link = EHT.Housing.GetFurnitureLink( furnitureId )
		icon = EHT.Housing.GetFurnitureLinkIcon( link )
	end

	if nil ~= link and "" ~= link then
		--if not EHT.Housing.IsValidFurnitureId( furnitureId, nil, link ) then link = string.format( "%s |cff0000(Missing!)|r", link ) end
		uic.TriggerConditionItemFurnitureId = furnitureId
		uic.TriggerConditionItemIcon:SetText( icon )
		uic.TriggerConditionItemIcon:SetDimensions( 25, 25 )
		uic.TriggerConditionItem:SetText( link )
		uic.TriggerConditionItem:SetHeight( 25 )
	else
		uic.TriggerConditionItemFurnitureId = nil
		uic.TriggerConditionItemIcon:SetText( "" )
		uic.TriggerConditionItemIcon:SetDimensions( 0, 0 )
		uic.TriggerConditionItem:SetText( "" )
		uic.TriggerConditionItem:SetHeight( 0 )
	end

	zo_callLater( EHT.UI.TriggerChanged, 10 )
	EHT.UI.ShowTriggerPointers()
end

function EHT.Biz.ChooseTriggerPosition( index, useCurrent, x, y, z )
	local ui = EHT.UI.ToolDialog
	if nil == ui then return end

	local uic = ui.Conditions[index]

	if useCurrent then
		x, y, z = GetPlayerWorldPositionInHouse()
	end

	if nil == x or nil == y or nil == z or 0 == x or 0 == y or 0 == z then
		uic.TriggerConditionPositionX = nil
		uic.TriggerConditionPositionY = nil
		uic.TriggerConditionPositionZ = nil
		uic.TriggerConditionPosition:SetText( "" )
	else
		uic.TriggerConditionPositionX = x
		uic.TriggerConditionPositionY = y
		uic.TriggerConditionPositionZ = z
		uic.TriggerConditionPosition:SetText( string.format( "X: %d, Y: %d, Z: %d", x, y, z ) )

		if nil == tonumber( uic.TriggerConditionRadius:GetText() or "" ) then
			uic.TriggerConditionRadius:SetText( "3.0" )
		end
	end

	zo_callLater( EHT.UI.TriggerChanged, 10 )
	EHT.UI.ShowTriggerPointers()
end

function EHT.Biz.OnHousePopulationChanged( population, isArrival )
	if EHT.Biz.AreTriggersDisabled() then return end

	local triggers = EHT.Data.GetTriggers()
	if nil == triggers then return end

	triggers = EHT.Biz.MatchTriggersByPopulationChange( population, isArrival )
	EHT.Biz.QueueTriggerActions( triggers, isArrival and EHT.CONST.TRIGGER_CONDITION.GUEST_ARRIVES or EHT.CONST.TRIGGER_CONDITION.GUEST_DEPARTS )
end

function EHT.Biz.MatchTriggersByTimeOfDay( isDayTime )
	local results = nil
	local triggers = EHT.Data.GetTriggers()

	for index, trigger in pairs( triggers ) do
		if trigger.Condition.DayTime then
			if isDayTime then
				if not trigger.ConditionMet then
					trigger.ConditionMet = true

					if nil == results then results = { } end
					table.insert( results, trigger )
				end
			else
				trigger.ConditionMet = false
			end
		end
		
		if trigger.Condition.NightTime then
			if not isDayTime then
				if not trigger.ConditionMet then
					trigger.ConditionMet = true

					if nil == results then results = { } end
					table.insert( results, trigger )
				end
			else
				trigger.ConditionMet = false
			end
		end

		if trigger.Condition.DayTime2 then
			if isDayTime then
				if not trigger.Condition2Met then
					trigger.Condition2Met = true

					if nil == results then results = { } end
					table.insert( results, trigger )
				end
			else
				trigger.Condition2Met = false
			end
		end

		if trigger.Condition.NightTime2 then
			if not isDayTime then
				if not trigger.Condition2Met then
					trigger.Condition2Met = true

					if nil == results then results = { } end
					table.insert( results, trigger )
				end
			else
				trigger.Condition2Met = false
			end
		end
	end

	return results
end

function EHT.Biz.MatchTriggersByFurnitureState( furnitureId, state, oldState )
	if nil == furnitureId then return nil end
	if nil == state or not EHT.Util.IsListValue( EHT.STATE, state ) then return nil end

	local idString = "string" == type( furnitureId ) and furnitureId or string.fromId64( furnitureId )
	if nil == idString or "" == idString then return nil end

	local results = nil
	local triggers = EHT.Data.GetTriggers()
	if not triggers then return nil end
--if EHT.IsDev then df("Evaluating triggers for furniture id: %s", idString) end

	for index, trigger in pairs( triggers ) do
		local added = false
--if EHT.IsDev then df("Evaluating trigger %d: furnitureId1=%s (%s) furnitureId2=%s (%s)", index, tostring(trigger.Condition.FurnitureId) or "nil", trigger.Condition.State or "nil", tostring(trigger.Condition.FurnitureId2) or "nil", trigger.Condition.State2 or "nil") end
		if idString == trigger.Condition.FurnitureId then
			if state == trigger.Condition.State or ( state ~= oldState and trigger.Condition.State == EHT.STATE.TOGGLE ) then
				trigger.ConditionMet = true
				if nil == results then results = { } end
				table.insert( results, trigger )
				added = true
			else
				trigger.ConditionMet = false
			end
		end

		if idString == trigger.Condition.FurnitureId2 then
			if state == trigger.Condition.State2 then
				trigger.Condition2Met = true
				if not added then
					if nil == results then results = { } end
					table.insert( results, trigger )
				end
			else
				trigger.Condition2Met = false
			end
		end
	end

	return results
end

function EHT.Biz.IsAnyUnitInRadius( x, y, z, radius, units )
	if nil == units then units = EHT.Housing.GetUnitPositions() end
	if nil == units then return false end
	if nil == x or nil == y or nil == z then return false end

	local unit, uX, uY, uZ

	for unitIndex = 0, GROUP_SIZE_MAX do
		unit = units[unitIndex]
		uX, uY, uZ = unit[1], unit[2], unit[3]

		if nil ~= uX and nil ~= uZ and 0 ~= uX and 0 ~= uZ then
			if	radius >= zo_distance3D( uX, uY, uZ, x, y, z ) or
				radius >= zo_distance3D( uX, uY + 100, uZ, x, y, z ) or
				radius >= zo_distance3D( uX, uY + 200, uZ, x, y, z ) then
				return true
			end
		end
	end

	return false
end

function EHT.Biz.MatchTriggersByPosition()
	local units = EHT.Housing.GetUnitPositions()
	if nil == units then return end

	local results = nil
	local triggers = EHT.Data.GetTriggers()
	local distance, tX, tY, tZ, radiusEnter, radiusExit
	local x, y, z, unit
	local inserted

	for index, trigger in pairs( triggers ) do
		inserted = false

		tX, tY, tZ = trigger.Condition.X, trigger.Condition.Y, trigger.Condition.Z
		if nil ~= tX and nil ~= tY and nil ~= tZ then
			if not trigger.ConditionMet then
				if		( trigger.Condition.RadiusEnter and EHT.Biz.IsAnyUnitInRadius( tX, tY, tZ, trigger.Condition.RadiusEnter * 100, units ) )
					or	( trigger.Condition.RadiusExit and not EHT.Biz.IsAnyUnitInRadius( tX, tY, tZ, trigger.Condition.RadiusExit * 100, units ) ) then
					trigger.ConditionMet = true
					if not inserted then
						if nil == results then results = { } end
						table.insert( results, trigger )
						inserted = true
					end
				end
			else
				if		( trigger.Condition.RadiusEnter and not EHT.Biz.IsAnyUnitInRadius( tX, tY, tZ, trigger.Condition.RadiusEnter * 100, units ) )
					or	( trigger.Condition.RadiusExit and EHT.Biz.IsAnyUnitInRadius( tX, tY, tZ, trigger.Condition.RadiusExit * 100, units ) ) then
					trigger.ConditionMet = false
				end
			end
		end

		tX, tY, tZ = trigger.Condition.X2, trigger.Condition.Y2, trigger.Condition.Z2
		if nil ~= tX and nil ~= tY and nil ~= tZ then
			if not trigger.Condition2Met then
				if		( trigger.Condition.RadiusEnter2 and EHT.Biz.IsAnyUnitInRadius( tX, tY, tZ, trigger.Condition.RadiusEnter2 * 100, units ) )
					or	( trigger.Condition.RadiusExit2 and not EHT.Biz.IsAnyUnitInRadius( tX, tY, tZ, trigger.Condition.RadiusExit2 * 100, units ) ) then
					trigger.Condition2Met = true
					if not inserted then
						if nil == results then results = { } end
						table.insert( results, trigger )
						inserted = true
					end
				end
			else
				if		( trigger.Condition.RadiusEnter2 and not EHT.Biz.IsAnyUnitInRadius( tX, tY, tZ, trigger.Condition.RadiusEnter2 * 100, units ) )
					or	( trigger.Condition.RadiusExit2 and EHT.Biz.IsAnyUnitInRadius( tX, tY, tZ, trigger.Condition.RadiusExit2 * 100, units ) ) then
					trigger.Condition2Met = false
				end
			end
		end
	end

	return results
end

function EHT.Biz.MatchTriggersByPhrase( text )
	if nil == text or nil == EHT.TriggerPhrases then return nil end
	text = string.lower( text )

	local matched, phrases = false, EHT.TriggerPhrases

	for index = 1, #phrases do
		if string.find( text, phrases[index], 1, true ) then
			matched = true
			break
		end
	end

	if not matched then return nil end

	local triggers = EHT.Data.GetTriggers()
	if nil == triggers or 0 >= #triggers then return nil end

	local results, phrase = nil, nil

	for index, trigger in pairs( triggers ) do
		phrase = trigger.Condition.Phrase
		if nil ~= phrase and string.find( text, string.lower( phrase ), 1, true ) then
			if nil == results then results = { } end
			table.insert( results, trigger )
		end
	end

	return results
end

function EHT.Biz.MatchTriggersByEmote( slashName )
	if nil == slashName then return nil end

	local triggers = EHT.Data.GetTriggers()
	if nil == triggers or 0 >= #triggers then return nil end

	local results = nil
	local emote

	for index, trigger in pairs( triggers ) do
		emote = trigger.Condition.Emote
		if emote == slashName then
			if nil == results then results = { } end
			table.insert( results, trigger )
		end
	end

	return results
end

function EHT.Biz.MatchTriggersByQuickslotItem( link )
	if nil == link then return nil end

	local triggers = EHT.Data.GetTriggers()
	if nil == triggers or 0 >= #triggers then return nil end

	local results = nil
	local collectibleId = GetCollectibleIdFromLink( link )
	local itemName = GetItemLinkName( link )

	if "" == collectibleId then collectibleId = nil end
	if "" == itemName then itemName = nil end

	for index, trigger in pairs( triggers ) do
		if nil ~= trigger.Condition.QuickslotItem then
			if ( nil ~= collectibleId and collectibleId == GetCollectibleIdFromLink( trigger.Condition.QuickslotItem ) ) or
			   ( nil ~= itemName and itemName == GetItemLinkName( trigger.Condition.QuickslotItem ) ) then

				if nil == results then results = { } end
				table.insert( results, trigger )

			end
		end
	end

	return results
end

function EHT.Biz.MatchTriggersByInteractTarget( interactTarget )
	if nil == interactTarget then return nil end
	interactTarget = string.lower( interactTarget )

	local triggers = EHT.Data.GetTriggers()
	if nil == triggers or 0 >= #triggers then return nil end

	local results = nil
	local target

	for index, trigger in pairs( triggers ) do
		target = trigger.Condition.InteractTarget
		if nil ~= target and string.lower( target ) == interactTarget then
			if nil == results then results = { } end
			table.insert( results, trigger )
		end
	end

	return results
end

function EHT.Biz.MatchTriggersByCombatState( inCombat )
	if nil == inCombat then return nil end

	local triggers = EHT.Data.GetTriggers()
	if nil == triggers or 0 >= #triggers then return nil end

	local results = nil
	local state

	for index, trigger in pairs( triggers ) do
		state = trigger.Condition.InCombat
		if nil ~= state and state == inCombat then
			if nil == results then results = { } end
			table.insert( results, trigger )
		end
	end

	return results
end

function EHT.Biz.MatchTriggersByPopulationChange( population, isArrival )
	if nil == isArrival then isArrival = true end

	local triggers = EHT.Data.GetTriggers()
	if nil == triggers or 0 >= #triggers then return nil end

	local results = nil

	for index, trigger in pairs( triggers ) do
		EHT.D( string.format( "Population: %d, Arrival: %s, Trigger Pop Change: %s", population, tostring( isArrival ), nil == trigger.Condition.PopulationChange and "nil" or tostring( trigger.Condition.PopulationChange ) ) )

		if ( isArrival and 1 == trigger.Condition.PopulationChange ) or ( not isArrival and -1 == trigger.Condition.PopulationChange ) then
			if nil == results then results = { } end
			table.insert( results, trigger )

			EHT.D( "Trigger matched." )
		end
	end

	return results
end

function EHT.Biz.IsTriggerQueued( trigger )
	local queue = EHT.TriggerQueue
	if nil == queue or nil == trigger then return false end

	for index, task in ipairs( queue ) do
		if task.Trigger.Name == trigger.Name then return true end
	end

	return false
end

function EHT.Biz.ProcessTriggersByQuickslotItem(link)
	if EHT.Biz.AreTriggersDisabled() then
		return
	end

	local triggers = EHT.Biz.MatchTriggersByQuickslotItem(link)
	if nil ~= triggers and 0 < #triggers then 
		EHT.Biz.QueueTriggerActions(triggers, EHT.CONST.TRIGGER_CONDITION.QUICKSLOT)
	end
end

function EHT.Biz.QueueTriggeredGroup( trigger, group, state )
	local queue = EHT.TriggerQueue
	if nil == queue then queue = { } EHT.TriggerQueue = queue end

	if nil == trigger or nil == group or nil == state then return false end

	if #queue >= EHT.TRIGGER_QUEUE_MAX_ITEMS then
		df( "Failed to queue Trigger: Maximum queue size reached (%d)", EHT.TRIGGER_QUEUE_MAX_ITEMS )
		return nil
	end

	local task = { }
	task.TaskType = EHT.TASK_TYPE.SET_GROUP_STATE
	task.Trigger = trigger
	task.TriggerString = EHT.Data.GetTriggerString( trigger )
	task.Group = group
	task.State = state

	table.insert( queue, task )
	EHT.Handlers.OnTriggerQueueChanged( queue )

	return task
end

function EHT.Biz.QueueTriggeredScene( trigger, sceneName )
	local queue = EHT.TriggerQueue
	if nil == queue then queue = { } EHT.TriggerQueue = queue end

	if nil == trigger or nil == sceneName then return false end

	if #queue >= EHT.TRIGGER_QUEUE_MAX_ITEMS then
		df( "Failed to queue Trigger: Maximum queue size reached (%d)", EHT.TRIGGER_QUEUE_MAX_ITEMS )
		return nil
	end

	local task = { }
	task.TaskType = EHT.TASK_TYPE.PLAY_SCENE
	task.Trigger = trigger
	task.TriggerString = EHT.Data.GetTriggerString( trigger )
	task.SceneName = sceneName

	table.insert( queue, task )
	EHT.Handlers.OnTriggerQueueChanged( queue )

	return task
end

function EHT.Biz.QueueTriggeredTrigger( trigger, nextTrigger )
	local queue = EHT.TriggerQueue
	if nil == queue then queue = { } EHT.TriggerQueue = queue end

	if nil == trigger or nil == nextTrigger then return false end

	if #queue >= EHT.TRIGGER_QUEUE_MAX_ITEMS then
		df( "Failed to queue Trigger: Maximum queue size reached (%d)", EHT.TRIGGER_QUEUE_MAX_ITEMS )
		return nil
	end

	local task = { }
	task.TaskType = EHT.TASK_TYPE.ACTIVATE_TRIGGER
	task.Trigger = trigger
	task.TriggerString = EHT.Data.GetTriggerString( trigger )
	task.NextTrigger = nextTrigger
	task.NextTriggerString = EHT.Data.GetTriggerString( nextTrigger )

	table.insert( queue, task )
	EHT.Handlers.OnTriggerQueueChanged( queue )

	return task
end

function EHT.Biz.QueueTriggerActions( triggers, ... )
	if nil == triggers then
		return
	end

	local group
	local triggerAfter

	for index, trigger in pairs( triggers ) do
		if trigger.Recursion or not EHT.Biz.IsTriggerQueued( trigger ) then
			if EHT.Biz.DoesTriggerMeetSecondaryCriteria( trigger, ... ) then
				EHT.Biz.QueueSingleTriggerActions( trigger )
			end
		end
	end
end

function EHT.Biz.QueueSingleTriggerActions( trigger )
	if not trigger then
		return
	end
	
	local numConditions = EHT.Biz.GetNumTriggerConditions( trigger )

	if not trigger.Condition.RadiusEnter and not trigger.Condition.RadiusExit and not trigger.Condition.DayTime and not trigger.Condition.NightTime then
		trigger.ConditionMet = false
	end

	if not trigger.Condition.RadiusEnter2 and not trigger.Condition.RadiusExit2 and not trigger.Condition.DayTime2 and not trigger.Condition.NightTime2 then
		trigger.Condition2Met = false
	end

	if nil ~= trigger.Action.GroupName and nil ~= trigger.Action.GroupState then
		local group = EHT.Data.GetGroup( trigger.Action.GroupName )
		if nil ~= group then
			EHT.Biz.QueueTriggeredGroup( trigger, group, trigger.Action.GroupState )
		end
	end

	if nil ~= trigger.Action.SceneName then
		if nil ~= EHT.Data.GetScene( trigger.Action.SceneName ) then
			EHT.Biz.QueueTriggeredScene( trigger, trigger.Action.SceneName )
		end
	end

	if nil ~= trigger.TriggerIdAfter then
		local triggerAfter = EHT.Data.GetTriggerByUniqueId( trigger.TriggerIdAfter )
		if nil ~= triggerAfter then
			EHT.Biz.QueueTriggeredTrigger( trigger, triggerAfter )
		end
	end
end

function EHT.Biz.DoesTriggerMeetSecondaryCriteria( trigger, metCondition )
	if nil == trigger or nil == trigger.Condition then return false end

	if nil ~= trigger.Condition.FurnitureId and metCondition ~= EHT.CONST.TRIGGER_CONDITION.FURNITURE_STATE then
		if EHT.Housing.GetFurnitureState( trigger.Condition.FurnitureId ) ~= trigger.Condition.State then
			return false
		end
	end

	if nil ~= trigger.Condition.FurnitureId then
		local state = EHT.Housing.GetFurnitureState( trigger.Condition.FurnitureId )
		local conditionMet = trigger.ConditionMet

		if trigger.Condition.State == EHT.STATE.TOGGLE then
			trigger.ConditionMet = false
		end

		if not conditionMet and EHT.Housing.GetFurnitureState( trigger.Condition.FurnitureId ) ~= trigger.Condition.State then
			return false
		end
	end

	if nil ~= trigger.Condition.FurnitureId2 then
		local state = EHT.Housing.GetFurnitureState( trigger.Condition.FurnitureId2 )
		local conditionMet = trigger.Condition2Met

		if not conditionMet and EHT.Housing.GetFurnitureState( trigger.Condition.FurnitureId2 ) ~= trigger.Condition.State2 then
			return false
		end
	end

	if nil ~= trigger.Condition.X and nil ~= trigger.Condition.Y and nil ~= trigger.Condition.Z then
		if		( trigger.Condition.RadiusEnter and not EHT.Biz.IsAnyUnitInRadius( trigger.Condition.X, trigger.Condition.Y, trigger.Condition.Z, trigger.Condition.RadiusEnter * 100 ) )
			or	( trigger.Condition.RadiusExit and EHT.Biz.IsAnyUnitInRadius( trigger.Condition.X, trigger.Condition.Y, trigger.Condition.Z, trigger.Condition.RadiusExit * 100 ) ) then
			return false
		end
	end

	if nil ~= trigger.Condition.X2 and nil ~= trigger.Condition.Y2 and nil ~= trigger.Condition.Z2 then
		if		( trigger.Condition.RadiusEnter2 and not EHT.Biz.IsAnyUnitInRadius( trigger.Condition.X2, trigger.Condition.Y2, trigger.Condition.Z2, trigger.Condition.RadiusEnter2 * 100) )
			or	( trigger.Condition.RadiusExit2 and EHT.Biz.IsAnyUnitInRadius( trigger.Condition.X2, trigger.Condition.Y2, trigger.Condition.Z2, trigger.Condition.RadiusExit2 * 100 ) ) then
			return false
		end
	end

	if nil ~= trigger.Condition.InCombat and metCondition ~= EHT.CONST.TRIGGER_CONDITION.ENTER_COMBAT then
		local inCombat = IsUnitInCombat( "player" )

		if ( trigger.Condition.InCombat and not inCombat ) or ( not trigger.Condition.InCombat and inCombat ) then
			return false
		end
	end

	if nil ~= trigger.Condition.PopulationChange and metCondition ~= EHT.CONST.TRIGGER_CONDITION.GUEST_ARRIVES and metCondition ~= EHT.CONST.TRIGGER_CONDITION.GUEST_DEPARTS then
		return false
	end

	if nil ~= trigger.Condition.Phrase and metCondition ~= EHT.CONST.TRIGGER_CONDITION.PHRASE then
		return false
	end

	if nil ~= trigger.Condition.Emote and metCondition ~= EHT.CONST.TRIGGER_CONDITION.EMOTE then
		return false
	end

	if nil ~= trigger.Condition.QuickslotItem and metCondition ~= EHT.CONST.TRIGGER_CONDITION.QUICKSLOT then
		return false
	end

	if nil ~= trigger.Condition.InteractTarget and metCondition ~= EHT.CONST.TRIGGER_CONDITION.INTERACT_TARGET then
		return false
	end

	if true == trigger.Condition.DayTime or true == trigger.Condition.NightTime then -- and metCondition ~= EHT.CONST.TRIGGER_CONDITION.DAY_TIME and metCondition ~= EHT.CONST.TRIGGER_CONDITION.NIGHT_TIME then
		return trigger.ConditionMet
	end

	if true == trigger.Condition.DayTime2 or true == trigger.Condition.NightTime2 then -- and metCondition ~= EHT.CONST.TRIGGER_CONDITION.DAY_TIME and metCondition ~= EHT.CONST.TRIGGER_CONDITION.NIGHT_TIME then
		return trigger.Condition2Met
	end

	return true
end

function EHT.Biz.TriggerQueueUpdate()
	if 0 >= GetCurrentZoneHouseId() then
		-- We are not even in a house?
		return
	end

	local queue = EHT.TriggerQueue
	if nil == queue then
		queue = { }
		EHT.TriggerQueue = queue
	end

	local task = queue[1]
	if nil == task then
		EHT.UI.ClearPersistentNotification( "TriggerExecution" )
	else
		if task.Started then
			if 1 < #queue then
				if task.TaskType == EHT.TASK_TYPE.PLAY_SCENE then
					if EHT.ProcessData and EHT.ProcessData.Scene and EHT.ProcessData.Scene.Loop then
						if EHT.SavedVars.ShowTriggersInChat then
							df( "Looped scene playback for the trigger \"%s\" has been interrupted to process other queued trigger actions.", task.Trigger.Name )
						end

						EHT.Biz.StopScene()
					end
				end
			end

			return
		else
			local SUPPRESS_MESSAGE = true
			if EHT.Biz.IsProcessRunning( SUPPRESS_MESSAGE ) then
				-- Wait for the current batch process to complete.
				return
			end
		end

		if task.TaskType == EHT.TASK_TYPE.SET_GROUP_STATE then
			if nil ~= task.State and nil ~= task.Group then
				local groupName = ( task.Trigger.Action and task.Trigger.Action.GroupName ) and task.Trigger.Action.GroupName or "(nil)"

				if EHT.SavedVars.ShowTriggersInChat then
					df( "The trigger \"%s\" is %s the saved selection \"%s\".", task.Trigger.Name, task.State == EHT.STATE.RESTORE and "restoring" or "changing item state(s) for", groupName )
				end

				if task.State == EHT.STATE.RESTORE then
					if not EHT.Biz.RestoreGroup( task.Group, EHT.Biz.TriggerQueueTaskCompleted ) then
						df( "The trigger \"%s\" failed to restore the saved selection \"%s\".", task.Trigger.Name, groupName )
						zo_callLater( EHT.Biz.TriggerQueueTaskCompleted, 500 )
					end
				else
					if not EHT.Biz.SetFurnitureStates( task.State, EHT.Biz.TriggerQueueTaskCompleted, task.Group, nil ) then
						df( "The trigger \"%s\" failed to change item state(s) for the saved selection \"%s\".", task.Trigger.Name, groupName )
						zo_callLater( EHT.Biz.TriggerQueueTaskCompleted, 500 )
					end
				end

				task.Started = true
				EHT.UI.SetPersistentNotification( "TriggerExecution", string.format( "Running Trigger: %s", task.Trigger.Name ) )
			end
		elseif task.TaskType == EHT.TASK_TYPE.PLAY_SCENE then
			if nil ~= task.SceneName then
				if EHT.SavedVars.ShowTriggersInChat then
					df( "The trigger \"%s\" is playing the scene \"%s\".", task.Trigger.Name, task.SceneName )
				end

				if not EHT.Biz.PlayNamedScene( task.SceneName, 1, nil, EHT.Biz.TriggerQueueTaskCompleted ) then
					df( "The trigger \"%s\" failed to play the scene \"%s\".", task.Trigger.Name, task.SceneName )
					zo_callLater( EHT.Biz.TriggerQueueTaskCompleted, 500 )
				end

				EHT.UI.SetPersistentNotification( "TriggerExecution", string.format( "Running Trigger: %s", task.Trigger.Name ) )
				task.Started = true
			end
		elseif task.TaskType == EHT.TASK_TYPE.ACTIVATE_TRIGGER then
			if nil ~= task.NextTrigger then
				if EHT.SavedVars.ShowTriggersInChat then
					df( "The trigger \"%s\" is queuing the trigger \"%s\".", task.Trigger.Name, task.NextTrigger.Name )
				end

				EHT.Biz.QueueSingleTriggerActions( task.NextTrigger )

				-- Auto-remove this task and proceed to the next item in the queue on the next update.
				task.Started = false
			end
		end

		if not task.Started then
			table.remove( queue, 1 )
		end

		EHT.Handlers.OnTriggerQueueChanged( queue )
	end
end

function EHT.Biz.TriggerQueueTaskCompleted()
	local queue = EHT.TriggerQueue
	if nil == queue then queue = { } EHT.TriggerQueue = queue end

	local task = table.remove( queue, 1 )
	if task then
		EHT.Biz.TriggerQueueUpdate()
	end

	EssentialHousingHub:IncUMTD("n_trgact", 1)
	EHT.Handlers.OnTriggerQueueChanged( queue )
end

---[ Operations : Auto-Backup ]---

EHT.Biz.PreBackupLinks = { }

function EHT.Biz.SaveLinkRelationships()
	local map = EHT.Housing.GetAllDescendantsByParent()
	local links = { }

	for sParentId, children in pairs( map ) do
		local parentId = EHT.Housing.FindFurnitureId( sParentId )
	end
end

function EHT.Biz.SerializeBackupItem( item )
	if not item or item.S then
		return item
	else
		local backupItem = { }
		local s = ""

		for index = 1, 20 do
			if index ~= 1 then
				s = s .. ";"
			end

			local value = item[BACKUP_FIELDS[index]]
			if nil ~= value then
				if "table" ~= type( value ) then
					s = s .. tostring( value )
				else
					backupItem[index] = EHT.Util.CloneTable( value )
				end
			else
				s = s .. "_"
			end
		end

		backupItem.S = s
		return backupItem
	end
end

function EHT.Biz.DeserializeBackupItem( backupItem )
	if backupItem and backupItem.S then
		local item = { }
		local values = { SplitString( ";", backupItem.S ) }

		for index = 1, 20 do
			local backupValue = backupItem[index]
			local fieldName = BACKUP_FIELDS[index]
			if nil ~= backupValue then
				if "table" ~= type( backupValue ) then
					item[fieldName] = backupValue
				else
					item[fieldName] = EHT.Util.CloneTable( backupValue )
				end
			else
				local stringValue = values[index]
				if nil ~= stringValue and stringValue ~= "" and stringValue ~= "_" then
					if string.len( stringValue ) < 10 then
						local num = tonumber( stringValue )
						if num then
							item[fieldName] = num
						else
							item[fieldName] = stringValue
						end
					else
						item[fieldName] = stringValue
					end
				end
			end
		end

		return item
	else
		return backupItem
	end
end

function EHT.Biz.AreBackupsEqual( backup1, backup2 )
	if nil == backup1 and nil == backup2 then return true end
	if nil == backup1 and nil ~= backup2 then return false end
	if nil ~= backup1 and nil == backup2 then return false end

	local items1, items2 = backup1.Items, backup2.Items
	if nil == items1 and nil == items2 then return true end
	if nil == items1 and nil ~= items2 then return false end
	if nil ~= items1 and nil == items2 then return false end
	if #items1 ~= #items2 then return false end

	local paths1, paths2 = backup1.Items.Paths, backup2.Items.Paths
	if nil == paths1 and nil ~= paths2 then return false end
	if nil ~= paths1 and nil == paths2 then return false end

	if paths1 and paths2 then
		if NonContiguousCount( paths1 ) ~= NonContiguousCount( paths2 ) then
			return false
		end

		for id, path1 in pairs( paths1 ) do
			local path2 = paths2[ id ]
			if "table" == type( path1 ) then
				if not path2 or "table" ~= type( path2 ) then
					return false
				end

				for pathKey, pathValue in pairs( path1 ) do
					if pathValue ~= path2[ pathKey ] then
						return false
					end
				end
			end
		end
	end

	for index = 1, #items1 do
		local item1, item2 = EHT.Biz.DeserializeBackupItem( items1[ index ] ), EHT.Biz.DeserializeBackupItem( items2[ index ] )

		if not item1 or not item2 then
			return false
		end

		for index = 1, #BACKUP_FIELDS do
			local fieldName = BACKUP_FIELDS[index]
			if item1[fieldName] ~= item2[fieldName] then
				return false
			end
		end

		local metaData1, metaData2 = item1.MetaData, item2.MetaData
		if ( nil ~= metaData1 and nil == metaData2 ) or ( nil == metaData1 and nil ~= metaData2 ) then
			return false
		end

		if "table" == type( metaData1 ) and "table" == type( metaData2 ) then
			for key, value in pairs( metaData1 ) do
				if metaData2[key] ~= value then
					return false
				end
			end
		end
	end

	return true
end

function EHT.Biz.CreateBackup( isPreRestore, manuallyRequested )
	local house = nil

	if EHT.Housing.IsOwner() or ( manuallyRequested and EHT.IsDev ) then
		house = EHT.Data.GetCurrentHouse( true )
	end

	if not house then
		return false, "You may only create backups of your own homes."
	end

	local items = { }
	local id, item, itemId, i

	repeat
		id = EHT.Housing.GetNextFurnitureId( id )
		if nil ~= id then
			i = EHT.Data.CreateFurniture( id )
			if nil ~= i then
				itemId = EHT.Housing.GetFurnitureItemId( id )
				item = {
					Id = string.fromId64( id ),
					ItemId = itemId,
					X = math.floor( i.X ),
					Y = math.floor( i.Y ),
					Z = math.floor( i.Z ),
					Pitch = tostring( round( i.Pitch or 0, 4 ) ),
					Yaw = tostring( round( i.Yaw or 0, 4 ) ),
					Roll = tostring( round( i.Roll or 0, 4 ) ),
					EffectType = i.EffectType,
					SizeX = i.SizeX,
					SizeY = i.SizeY,
					SizeZ = i.SizeZ,
					Color = i.Color,
					Alpha = i.Alpha,
					MetaData = EHT.Util.CloneTable( i.MetaData ),
					Groups = i.Groups,
					Contrast = i.Contrast,
					Speed = i.Speed,
					DelayTime = i.DelayTime,
				}
				table.insert( items, item )
			end
		end
	until nil == id

	local REFRESH_PATH_INFO = true
	EHT.Data.ValidateGroupPathables( items, REFRESH_PATH_INFO )

	if 0 >= #items then return false, "No furniture has been placed." end

	for index = 1, #items do
		items[index] = EHT.Biz.SerializeBackupItem( items[index] )
	end

	local tstamp = GetTimeStamp()
	local backupDate, backupTime = FormatAchievementLinkTimestamp( tstamp )
	local backups = house.Backups

	if isPreRestore and nil ~= backups and nil ~= backups.PreRestore then
		if EHT.CONST.MAX_HOUSE_PRE_RESTORE_BACKUP_AGE >= GetDiffBetweenTimeStamps( tstamp, backups.PreRestore.Timestamp ) then
			return false, "A recent Pre-Restore backup already exists."
		end
	end

	local backup = {
		Timestamp = tstamp,
		BDate = backupDate,
		BTime = backupTime,
		Items = items,
		IsPreRestore = isPreRestore
	}

	if nil == backups then
		backups = { }
		house.Backups = backups
	else
		local prevBackup = backups[ 1 ]
		if nil ~= prevBackup then
			if EHT.Biz.AreBackupsEqual( prevBackup, backup ) then
				return false, "No changes have been made since the last backup."
			end
		end
	end

	if isPreRestore then
		backups.PreRestore = backup
	else
		table.insert( backups, 1, backup )

		if 1 < #backups then
			while EHT.CONST.MAX_HOUSE_BACKUPS < #backups do
				table.remove( backups, #backups )
			end

			if nil ~= backups.PreRestore and EHT.CONST.MAX_HOUSE_PRE_RESTORE_BACKUP_AGE < GetDiffBetweenTimeStamps( GetTimeStamp(), backups.PreRestore.Timestamp ) then
				backups.PreRestore = nil
			end
		end
	end

	if false ~= EHT.SavedVars.ShowBackupNotifications then
		EHT.UI.DisplayNotification( "A new backup of your furniture and FX has been saved." )
	end

	EHT.UI.QueueRefreshBackups()

	GetAddOnManager():RequestAddOnSavedVariablesPrioritySave( EHT.ADDON_NAME )

	return true, string.format( "Backup has been successfully created.\n\n" ..
		"PLEASE NOTE:\n" ..
		"A maximum of %d backups are retained - the oldest backups are discarded as new ones are created.\n\n" ..
		"If you wish to save a PERMANENT backup of your house, please create a New selection from the Select tab, " ..
		"Select All items in the house, and save that Selection with a meaningful name like 'Backup as of <date>'." , EHT.CONST.MAX_HOUSE_BACKUPS )
end

function EHT.Biz.RestoreBackup( index )
	local house = EHT.Data.GetCurrentHouse()
	if nil == house then
		d( "You must be in a house to restore a backup." )
		return false
	end

	local backups = house.Backups
	if nil == backups then
		d( "No backups have been saved for this house." )
		return false
	end

	local backup = EHT.Util.CloneTable( backups[ index ] )
	if nil == backup then
		d( "Backup does not exist or is invalid." )
		return false
	end

	-- Create a pre-restore backup first.
	if EHT.Biz.CreateBackup( true ) then
		d( "Created pre-restore backup..." )
	end

	local backupDesc = string.format( "%s %s", tostring( backup.BDate ) or "", tostring( backup.BTime ) or "" ) or "nil"
	local group = { }

	for itemIndex, backupItem in ipairs( backup.Items ) do
		local item = EHT.Biz.DeserializeBackupItem( backupItem )
		if not item or not item.Id or "" == item.Id or not item.ItemId or not item.X or not item.Y or not item.Z then
			d( string.format( "Skipping Backup \"%s\" Item #%d. Record is corrupt or invalid.", backupDesc, itemIndex or -1 ) )
		else
			local link = EHT.Housing.GetFurnitureItemIdLink( item.ItemId )
			local icon = EHT.Housing.GetFurnitureLinkIconFile( link )
			local collectibleId = nil
			if EHT.Housing.IsItemIdCollectible( item.ItemId ) then collectibleId = item.ItemId end

			if not link then
				d( string.format( "Skipping Backup \"%s\" Item #%d. Record is corrupt or invalid.", backupDesc, itemIndex or -1 ) )
			else
				item.EffectType = tonumber( item.EffectType )
				item.SizeX = tonumber( item.SizeX )
				item.SizeY = tonumber( item.SizeY )
				item.SizeZ = tonumber( item.SizeZ )
				item.Color = tonumber( item.Color )
				item.Alpha = tonumber( item.Alpha or 1 )
				item.MetaData = EHT.Util.CloneTable( item.MetaData )
				item.Groups = tonumber( item.Groups )
				item.Contrast = tonumber( item.Contrast or 1 )
				item.Speed = tonumber( item.Speed )
				item.DelayTime = tonumber( item.DelayTime )
				table.insert( group, item )

				if item.EffectType then
					EHT.Data.RestoreEffectRecord( item.Id, item.EffectType, item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll, item.SizeX, item.SizeY, item.SizeZ, item.Color, item.Alpha, item.Groups, item.MetaData, item.Contrast )
				end
			end
		end
	end

	if backup.Items.Paths then
		group.Paths = EHT.Util.CloneTable( backup.Items.Paths )
	end

	EHT.Data.ValidateGroupPathables( group )
	EHT.Data.SortGroupPathables( group )

	df( "Restoring backup \"%s\" containing %d item(s)...", backupDesc, #group )
	EHT.UI.UpdateRestoreStatus( "Replacing removed items..." )
	EHT.Biz.ReplaceMissingItems( group, EHT.Biz.RestoreBackupItemsReplaced, true, true )
	EHT.UI.QueueRefreshBackups()

	return true
end

function EHT.Biz.RestoreBackupItemsReplaced( group, total, replaced )
	EHT.UI.UpdateRestoreStatus( nil )

	if nil == group then
		df( "RestoreBackupCallback failed: Group is nil." )
		return false
	end

	total, replaced = total or 0, replaced or 0
	local missing = total - replaced
	local groupItems = group

	local nextFunc = function()
		df( "Unlinking all items to prevent linked items from moving during the restore process..." )
		EHT.UI.UpdateRestoreStatus( "Unlinking items..." )
		EHT.Biz.UnlinkGroup( groupItems, function()
			EHT.Biz.RestoreBackupItemsUnlinked( groupItems )
		end, true )
	end

	if 0 < missing then
		local invalidItems = EHT.Biz.GetInvalidGroupItemList( group )
		local invalidItemsList = EHT.UI.BuildItemQuantityList( invalidItems )
		df( "The following items could not be found:\n%s", invalidItemsList )

		EHT.UI.ShowConfirmationDialog(
			"Missing Backed Up Items",
			string.format(
				"|cffffffSome of the backed up items are missing and cannot be found in your inventory, bank or house storage containers.\n\n" ..
				"%d of the %d missing items could not be found.\n|cffff00Check the chat window for details.|cffffff\n\n" ..
				"Continue with Restore process?", missing, total ),
			function() nextFunc() end )

		EHT.UI.QueueRefreshBackups()
		return
	end

	nextFunc()
end

function EHT.Biz.RestoreBackupItemsUnlinked( group )
	EHT.UI.UpdateRestoreStatus( nil )

	if nil == group then
		df( "RestoreBackupCallback failed: Group is nil." )
		return false
	end

	df( "Restoring %d backup items...", ( group and #group or 0 ) )
	EHT.UI.UpdateRestoreStatus( "Restoring backup..." )
	EHT.Biz.AdjustSelectedFurniture( { Callback = EHT.Biz.RestoreBackupComplete, SkipUnchanged = true, CreateMissingPathNodes = true, Group = group, X = 0 }, 1 )
	EHT.UI.QueueRefreshBackups()
end

function EHT.Biz.RestoreBackupComplete( group )
	EHT.UI.UpdateRestoreStatus( nil )
	EHT.UI.HideBackupsDialog()

	if nil ~= group then
		d( "Restore operation completed." )
		EHT.UI.ShowAlertDialog( "Restore Complete", string.format( "Restore is complete.\n%d item(s) have been restored.", #group ) )
		EssentialHousingHub:IncUMTD("n_bkrs", 1)
	else
		EHT.UI.ShowAlertDialog( "Restore Error", "Restore completed with an unknown exception." )
	end

	EHT.UI.QueueRefreshBackups()
end

---[ Operations : Randomize Build ]---

local isRandomizingBuild = false
local randomizingParams

function EHT.Biz.IsRandomizingBuild()
	return isRandomizingBuild
end

function EHT.Biz.CancelRandomizeBuild()
	isRandomizingBuild = false
	randomizingParams = nil

	local ui = EHT.UI.ToolDialog
	if ui and ui.RandomizeBuildButton then
		ui.RandomizeBuildButton:SetText( "Randomize" )
	end
end

function EHT.Biz.RandomizeBuild()
	local ui = EHT.UI.ToolDialog
	if nil == ui then return end
	ZO_CheckButton_SetCheckState( ui.BuildParams.ItemSpacingAuto.AutoSpacing, true )
	zo_callLater( EHT.Biz.RandomBuildStartCallback, 500 )
end

function EHT.Biz.RandomBuildStartCallback()
	local ui = EHT.UI.ToolDialog
	if nil == ui then return end

	isRandomizingBuild = true
	local params = { }
	randomizingParams = params

	for key, p in pairs( ui.BuildParams ) do
		if p.IsParam and p.IsHidden and not p:IsHidden() and p.GetEnabled and p:GetEnabled() and p.RandomUnit then
			table.insert( params, p )
		end
	end

	EHT.Biz.RandomizeBuildCallback()

	local ui = EHT.UI.ToolDialog
	if nil ~= ui then ui.RandomizeBuildButton:SetText( "Stop Randomize" ) end
end

function EHT.Biz.RandomizeBuildCallback()
	if not isRandomizingBuild or nil == randomizingParams then return end

	local build = EHT.Data.GetBuild()
	local ui = EHT.UI.ToolDialog

	if nil == build or nil == ui or nil == ui.BuildParams then
		CancelRandomizeBuild()
		return
	end

	local params = randomizingParams

	if 0 >= #params then
		CancelRandomizeBuild()
		return
	end

	local pIndex = math.floor( ( math.random() * #params ) + 1 )
	local p = params[ pIndex ]
	local v = p:GetValue()
	local coeff = 0.5 <= math.random() and -1 or 1
	v = v + coeff * p.RandomUnit

	local vMin, vMax = p:GetMinMax()
	if p.RandomMin then vMin = p.RandomMin end
	if p.RandomMax then vMax = p.RandomMax end

	if v > vMax then v = v - 2 * p.RandomUnit end
	if v < vMin then v = v + 2 * p.RandomUnit end

	p:SetValue( v )
	EHT.Biz.Build( build, EHT.Biz.RandomizeBuildCallback )
end

---[ Operations : Reporting ]---

function EHT.Biz.ReportHouseItems( criteria )

	local body = { }

	if nil == criteria or nil == criteria.HouseId then
		return "Please select a House to report on."
	end

	local house = EHT.Data.GetHouseById( criteria.HouseId )

	if nil == house then
		return "No records found for the selected House."
	end

	table.insert( body, "***  Report:  Items by House  ***" )
	table.insert( body, string.format( " Created on %s at %s", GetDateStringFromTimestamp( GetTimeStamp() ), GetTimeString() ) )
	table.insert( body, string.format( " House Name: %s", house.Name or "(nil)" ) )
	table.insert( body, string.format( " House Id: %s", house.HouseId or "(nil)" ) )
	table.insert( body, "" )

	table.insert( body, "" )
	table.insert( body, "[[ Automatic / Manual Backups ]]" )
	table.insert( body, "" )

	if not house.Backups or "table" ~= type( house.Backups ) or 0 >= #house.Backups then
		table.insert( body, "No automatic or manual backups have been saved." )
	else
		local id, itemId, link, name

		for backupIndex, backup in ipairs( house.Backups ) do
			table.insert( body, string.format( "- Backup #%d of %d, created %s at %s -", backupIndex, #house.Backups, backup.BDate or "(nil)", backup.BTime or "(nil)" ) )
			table.insert( body, "" )

			for itemIndex, item in ipairs( backup.Items ) do
				id = item[1]
				itemId = item[2]
				link = EHT.Housing.GetFurnitureItemIdLink( itemId )
				name = EHT.Housing.GetFurnitureLinkName( link )

				table.insert( body, string.format( "%d. %s  (Item #%s, Id %s)", itemIndex or 0, name or "(nil)", tostring( itemId or "(nil)" ), id or "(nil)" ) )
			end

			table.insert( body, string.format( "%d total item(s)", ( nil ~= backup.Items ) and #backup.Items or 0 ) )
			table.insert( body, "" )
		end
	end

	table.insert( body, "" )
	table.insert( body, "[[ Saved Selections ]]" )
	table.insert( body, "" )

	if not house.Groups or "table" ~= type( house.Groups ) or 0 >= EHT.Util.TableCount( house.Groups ) then
		table.insert( body, "No saved selections." )
	else
		local id, itemId, link, name

		for groupName, group in pairs( house.Groups ) do
			table.insert( body, string.format( "- Selection : %s -", groupName ) )
			table.insert( body, "" )

			for itemIndex, item in ipairs( group ) do
				id = item.Id
				link = item.Link
				itemId = EHT.Housing.GetFurnitureLinkItemId( link )
				name = EHT.Housing.GetFurnitureLinkName( link )

				if nil ~= name and "" ~= name then
					table.insert( body, string.format( "%d. %s  (Item #%s, Id %s)", itemIndex or 0, name or "(nil)", tostring( itemId or "(nil)" ), id or "(nil)" ) )
				end
			end

			table.insert( body, string.format( "%d total item(s)", #group ) )
			table.insert( body, "" )
		end
	end

	table.insert( body, "" )
	table.insert( body, "[[ Recently Placed Items ]]" )
	table.insert( body, "" )

	if not house.History or "table" ~= type( house.History ) or 0 >= #house.History then
		table.insert( body, "No change history available." )
	else
		local id, itemId, link, name

		for historyIndex, item in ipairs( house.History ) do
			if "P" == item.Op then
				item = EHT.Data.DeserializeHistoryRecord( item )
				id = item.Id
				link = item.Link
				itemId = EHT.Housing.GetFurnitureLinkItemId( link )
				name = EHT.Housing.GetFurnitureLinkName( link )

				if nil ~= name and "" ~= name then
					table.insert( body, string.format( "Placed %s  (Item #%s, Id %s)", name or "(nil)", tostring( itemId or "(nil)" ), id or "(nil)" ) )
				end
			end
		end
	end

	table.insert( body, "" )
	return table.concat( body, "\n" )
end

------[[ Operations : Miscellaneous ]]------

function EHT.Biz.ShowMyLocation()
	local _, x, y, z = EHT.GetPlayerPosition( "player" )
	local yaw = EHT.Biz.GetEditorHeading()

	df( "X (east/west): %d\nY (up/down): %d\nZ (north/south): %d\nHeading: %.2f degrees", x, y, z, math.deg( yaw ) )
end

function EHT.Biz.ReportMovementSpeed()
	local ms = EHT.MovementSpeed
	if nil == ms then return end

	ms.EndTime = GetGameTimeMilliseconds()
	local duration = ( ms.EndTime - ms.StartTime ) / 1000
	local distance = ms.Distance / 100
	local velocity = distance / duration

	df( "Duration: %.2f sec\nDistance: %.2f m\nVelocity: %.2f m/sec", duration, distance, velocity )
end

function EHT.Biz.MonitorMovementSpeed()
	local ms = EHT.MovementSpeed
	if nil == ms then return end

	local _, x, y, z = EHT.GetPlayerPosition( "player" )

	if nil == ms.Position then
		ms.Position = { x, y, z }
	else
		local p = ms.Position
		ms.Distance = ms.Distance + zo_distance3D( p[1], p[2], p[3], x, y, z )
		p[1], p[2], p[3] = x, y, z
	end

	zo_callLater( EHT.Biz.MonitorMovementSpeed, 100 )
end

function EHT.Biz.ClockMovementSpeed()
	local ms = EHT.MovementSpeed
	if nil ~= ms then
		EHT.Biz.ReportMovementSpeed()
		EHT.MovementSpeed = nil
	else
		d( "\nBegin moving forward now..." )

		zo_callLater( function()
			EHT.MovementSpeed = {
				StartTime = GetGameTimeMilliseconds(),
				Distance = 0
			}
			zo_callLater( EHT.Biz.MonitorMovementSpeed, 100 )
			zo_callLater( EHT.Biz.ClockMovementSpeed, 6000 )
		end, 2000 )
	end
end

function EHT.Biz.ShowItemDimensions()
	local id = EHT.PositionItemId

	if nil == id then
		d( "Select an item for positioning." )
		return
	end

	local x, y, z = EHT.Housing.GetFurniturePosition( id )
	local pitch, yaw, roll = EHT.Housing.GetFurnitureOrientation( id )
	local x1, y1, z1, x2, y2, z2 = EHT.Housing.GetFurnitureWorldBounds( id )

	d( " " )
	df( "Orientation: %.2f, %.2f, %.2f", math.deg( pitch ), math.deg( yaw ), math.deg( roll ) )
	df( "Position: %d, %d, %d", x, y, z )
	df( "Center: %.1f, %.1f, %.1f", ( x1 + x2 ) / 2, ( y1 + y2 ) / 2, ( z1 + z2 ) / 2 )
	df( "Offset: %.1f, %.1f, %.1f", ( ( x1 + x2 ) / 2 ) - x, ( ( y1 + y2 ) / 2 ) - y, ( ( z1 + z2 ) / 2 ) - z )
	df( "Min Position: %d, %d, %d", x1, y1, z1 )
	df( "Max Position: %d, %d, %d", x2, y2, z2 )
	df( "Dimensions: %d, %d, %d", math.abs( x2 - x1 ), math.abs( y2 - y1 ), math.abs( z2 - z1 ) )
end

function EHT.Biz.ShowSelectionOrigin()
	local _, group = EHT.Data.GetCurrentHouse()
	if nil == group or 0 >= #group then d( "Selection is empty." ) return end

	local o = EHT.Housing.CalculateFurnitureOrigin( group, true, nil )
	df( "\nCenter: %d, %d, %d\nMin: %d, %d, %d\nMax: %d, %d, %d", o.X, o.Y, o.Z, o.MinX, o.MinY, o.MinZ, o.MaxX, o.MaxY, o.MaxZ )
end

function EHT.Biz.ResetDimensions()
	EHT.SavedVars.Dimensions = { }
	df( "Furniture Dimensions cache has been cleared." )
end

function EHT.Biz.SlashCommandVersion()
	df( "You currently have %s installed.", EHT.ADDON_TITLE_LONG )
end

function EHT.Biz.SlashCommandResetHome()
	local msg = "The |cffffff/home|r command will now return |cffffff%s|r to your primary home|cffffff%s|r."
	df( " " )

	local charName = GetUnitName( "player" )
	local primaryHouses = EHT.SavedVars.PrimaryHouses or { }
	EHT.SavedVars.PrimaryHouses = primaryHouses

	primaryHouses[ charName ] = nil
	local houseId = GetHousingPrimaryHouse()
	local house = EHT.Housing.GetHouseById( houseId )

	if nil == house then
		df( msg, charName, "" )
	else
		df( msg, charName, " " .. ( house.Description or "?" ) )
	end

	return true
end

function EHT.Biz.SlashCommandSetHome( houseName )
	local msg = "The |cffffff/home|r command will now return |cffffff%s|r to |cffffff%s|r."
	df( " " )

	local charName = GetUnitName( "player" )
	local primaryHouses = EHT.SavedVars.PrimaryHouses or { }
	EHT.SavedVars.PrimaryHouses = primaryHouses
	local house = nil

	houseName = string.trim( houseName or "" )

	if "" == houseName then
		local houseId = GetCurrentZoneHouseId()
		house = EHT.Housing.GetHouseById( houseId )

		if nil == house then
			df( "You must be in a house that you own, or you must specify a house name." )
			return false
		end
	end

	if nil == house then
		local matches = EHT.Housing.FindHousesByName( houseName )

		if nil == matches or 0 >= #matches then
			df( "No houses match '%s'.", houseName )
			return false
		elseif 1 < #matches then
			df( "Matched %d houses to '%s':", #matches, houseName )
			for houseId, house in pairs( matches ) do df( "%s", house.Description ) end
			df( "Please be more specific." )
			return false
		end

		house = matches[1]
		if not house.Collected then
			df( "You do not own |cffffff%s|r.", house.Name )
			return false
		end
	end

	primaryHouses[ charName ] = house.Id
	df( msg, charName, house.Description )

	return true
end

function EHT.Biz.SlashCommandListFavHouses()
	local favHouses = EHT.SavedVars.FavoriteHouses or { }
	EHT.SavedVars.FavoriteHouses = favHouses

	local showEllipses = false
	local favHouse
	local count = 0

	d( " " )
	d( "Favorite Houses:" )

	for index = 1, EHT.CONST.MAX_FAV_HOUSES do
		favHouse = favHouses[ index ]

		if nil == favHouse then
			showEllipses = true
		else
			count = count + 1

			if showEllipses then
				df( "..." )
				showEllipses = false
			end

			local house = EHT.Housing.GetHouseById( favHouse.HouseId )

			if nil == favHouse.Owner then
				if nil ~= house then
					df( "|cffffff%d|r. |cffffff%s|r", index, house.Description )
				end
			else
				if nil == house then
					df( "|cffffff%d|r. |cffffffPrimary house|r of |cffffff%s|r", index, favHouse.Owner )
				else
					df( "|cffffff%d|r. |cffffff%s|r owned by |cffffff%s|r", index, house.Name, favHouse.Owner )
				end
			end
		end
	end
end

function EHT.Biz.SlashCommandSetFavHouse( command )
	d( " " )
	local msgHelp = "For more information, use: |cffffff/setfavhouse|r"
	local msgSuccess = "Set Favorite House |cffffff%d|r to |cffffff%s|r"

	local favHouses = EHT.SavedVars.FavoriteHouses or { }
	EHT.SavedVars.FavoriteHouses = favHouses

	local favIndex, houseOwner, houseId, houseName = nil, nil, nil, nil
	local spaceIndex
	command = string.trim( command or "" )

	if "" ~= command then
		spaceIndex = string.find( command, " " )
		if nil == spaceIndex then
			df( "Invalid parameters specified." )
			df( msgHelp )
			return false
		end

		favIndex = tonumber( string.sub( command, 1, spaceIndex - 1 ) )
		if nil == favIndex or 1 > favIndex or favIndex > EHT.CONST.MAX_FAV_HOUSES then
			df( "Invalid Favorite Index. Please use 1 through %d.", EHT.CONST.MAX_FAV_HOUSES )
			df( msgHelp )
			return false
		end

		command = string.trim( string.sub( command, spaceIndex + 1 ) )

		if "@" == string.sub( command, 1, 1 ) then
			spaceIndex = string.find( command, " " )
			if nil == spaceIndex then
				houseOwner = command
				houseName = ""
			else
				houseOwner = string.sub( command, 1, spaceIndex - 1 )
				houseName = string.trim( string.sub( command, spaceIndex + 1 ) )
			end
		else
			houseName = command
		end

		if nil == houseOwner and "" == houseName then
			df( "Invalid Player or House Name specified." )
			df( msgHelp )
			return false
		end

		if houseOwner then houseOwner = EHT.Util.Trim( string.lower( houseOwner ) ) end

		if "" ~= houseName then
			local matches = EHT.Housing.FindHousesByName( houseName, nil == houseOwner )
			if nil == matches or 0 >= #matches then
				df( "Invalid House Name specified: %s", houseName )
				df( msgHelp )
				return false
			end

			if 1 < #matches then
				df( "%d houses match '%s':", #matches, houseName )
				for houseId, house in ipairs( matches ) do df( " %s", ( nil == houseOwner and house.Description or house.Name ) ) end
				df( "Please be more specific." )
				df( msgHelp )
				return false
			end

			houseId = matches[1].Id
			houseName = matches[1].Name
		end

		if nil ~= favIndex and ( nil ~= houseOwner or nil ~= houseId ) then
			favHouses[ favIndex ] = { Owner = houseOwner, HouseId = houseId }

			if nil == houseOwner then
				df( msgSuccess, favIndex, houseName )
			else
				if nil == houseId then
					df( msgSuccess, favIndex, string.format( "Primary house of %s", houseOwner ) )
				else
					df( msgSuccess, favIndex, string.format( "%s owned by %s", houseName, houseOwner ) )
				end
			end

			EHT.UI.RefreshHousingHub()
			return true
		end
	end

	df( "Commands to set a Favorite House:\n" )
	df( "|cffffff/setfavhouse Index House|r" )
	df( "|cffffff/setfavhouse Index @Player House|r" )
	df( "Valid Favorite House indexes are |cffffff1|r through |cffffff%d|r.", EHT.CONST.MAX_FAV_HOUSES )

	return false
end

function EHT.Biz.SlashCommandHome( houseName )
	local charName = GetUnitName( "player" )
	local primaryHouses = EHT.SavedVars.PrimaryHouses or { }
	EHT.SavedVars.PrimaryHouses = primaryHouses

	houseName = string.trim( houseName or "" )

	if "" == houseName then
		local isPersonalHouse = true
		local houseId = primaryHouses[ charName ]

		if nil == houseId then
			houseId = GetHousingPrimaryHouse()
			isPersonalHouse = false
		end

		d( " " )

		if nil == houseId or 0 == houseId then
			df( "You do not have a primary house set up." )
			df( "Consider using the |cffffff/house|r command to jump to a specific house," )
			df( "or use the |cffffff/sethome|r command to choose a personal home for this character." )
		else
			local house = EHT.Housing.GetHouseById( houseId )

			if nil ~= house then
				df( "Jumping to your %s home, |cffffff%s|r...", isPersonalHouse and "personal" or "primary", house.Description )
			else
				df( "Jumping to %s house...", isPersonalHouse and "personal" or "primary" )
			end

			RequestJumpToHouse( houseId )
		end
	else
		EHT.Biz.SlashCommandHouse( houseName )
	end
end

function EHT.Biz.SlashCommandHouse( houseName, accountName )
	if nil == houseName then
		return false
	end

	houseName = string.trim( houseName )
	accountName = string.trim( accountName )
	local originalHouseName = houseName
	local houseIndex = tonumber( houseName )

	local favHouses = EHT.SavedVars.FavoriteHouses or { }
	EHT.SavedVars.FavoriteHouses = favHouses

	d( " " )

	if "" == houseName then 
		df( "%s can quickly teleport you to any house, including another player's...\n", EHT.ADDON_TITLE )
		df( "Commands:" )
		df( "|cffffff/home|r" )
		df( "|cffffff/house House|r" )
		df( "|cffffff/house @Player|r" )
		df( "|cffffff/house @Player House|r\n" )
		df( "|cffffff/house FavoriteIndex|r" )
		df( "       (such as |cffffff/house 8|r)" )

		return false
	end

	if nil ~= houseIndex then

		houseIndex = math.floor( houseIndex )

		if 1 > houseIndex or houseIndex > EHT.CONST.MAX_FAV_HOUSES then
			df( "Specify a valid Favorite House using |cffffff1|r through |cffffff%d|r.", EHT.CONST.MAX_FAV_HOUSES )
			return false
		end

		local favHouse = favHouses[ houseIndex ]

		if nil == favHouse or ( nil == favHouse.HouseId and "" == ( favHouse.Owner or "" ) ) then
			df( "Favorite House %d has not been set.", houseIndex )
			return false
		end

		local houseId = favHouse.HouseId
		local houseOwner = favHouse.Owner
		local house = EHT.Housing.GetHouseById( houseId )

		if nil ~= houseId and nil == house then
			df( "Favorite House |cffffff%d|r is set to an invalid House Id. Please set it again.", houseIndex )
			return false
		end

		if "" == ( houseOwner or "" ) then
			df( "Jumping to Favorite House |cffffff%d|r: |cffffff%s|r", houseIndex, house.Description )
			RequestJumpToHouse( houseId )
		else
			if nil == house then
				df( "Jumping to Favorite House |cffffff%d|r: |cffffffPrimary house|r of |cffffff%s|r", houseIndex, houseOwner )
				JumpToHouse( houseOwner )
			else
				df( "Jumping to Favorite House |cffffff%d|r: |cffffff%s|r owned by |cffffff%s|r", houseIndex, house.Description, houseOwner )
				JumpToSpecificHouse( houseOwner, houseId )
			end
		end

		return true

	end

	if nil == accountName and "@" == string.sub( houseName, 1, 1 ) then
		local nameIndex = string.find( houseName, " " )
		accountName = string.trim( string.sub( houseName, 1, nameIndex ) )

		if nil ~= nameIndex then
			houseName = string.trim( string.sub( houseName, nameIndex + 1 ) )
		else
			houseName = ""
		end
	end

	local matches = EHT.Housing.FindHousesByName( houseName )
	local numMatches = #matches

	if "" ~= houseName and 0 >= numMatches then
		if originalHouseName == houseName then
			df( "No house names or nicknames match '%s'.", houseName )
		else
			df( "No house names or nicknames match '%s' or '%s'", houseName, originalHouseName )
		end

		return false
	elseif 1 < numMatches then
		df( "%d houses match '%s':", numMatches, houseName )

		for houseId, house in ipairs( matches ) do
			df( " %s", house.Description )
		end

		d( "Please be more specific." )

		return false
	end

	if 1 == numMatches then
		local house = matches[1]
		df( "Jumping to %s%s...", nil ~= accountName and string.format( "%s's ", accountName ) or "", nil == accountName and house.Description or house.Name )

		if nil == accountName then
			RequestJumpToHouse( house.Id )
		else
			JumpToSpecificHouse( accountName, house.Id )
		end
	else
		df( "Jumping to %s's primary house...", accountName )
		JumpToHouse( accountName )
	end

	return true
end

function EHT.Biz.SlashCommandPlayScene( sceneName )
	if EHT.Biz.IsProcessRunning() then
		return false
	end

	sceneName = string.trim( sceneName or "" )

	if "" ~= sceneName then
		if not EHT.Biz.PlayNamedScene( sceneName ) then
			df( "Scene not found: %s", sceneName )
			return false
		end

		df( "Playing Scene \"%s\".", sceneName )
		return true
	else
		if not EHT.Biz.PlayScene() then
			df( "Cannot play current Scene." )
			return false
		end

		df( "Playing current Scene." )
		return true
	end
end

function EHT.Biz.SlashCommandStopScene()
	if not EHT.Biz.StopScene() then
		df( "No Scene is playing." )
		return false
	end

	df( "Stopping Scene playback." )
	return true
end

function EHT.Biz.SlashCommandRewindScene()
	if not EHT.Biz.RewindScene() then
		df( "Cannot rewind Scene." )
		return false
	end

	df( "Rewinding Scene." )
	return true
end

do
	local offeredHelp = false
	local adjustedRandomSeed = false

	function EHT.Biz.RollDice( cmd, args )
		cmd = string.lower( cmd or "" )
		args = string.lower( EHT.Util.Trim( args or "" ) )

		if not adjustedRandomSeed then
			adjustedRandomSeed = true
			math.randomseed( GetTimeStamp() )
			math.random()
		end

		if ( not offeredHelp and "" == args ) then
			offeredHelp = true
			df( "For help, type |c00ffff/%s help", cmd )
		end

		if "?" == args or "h" == args or "help" == args then
			d( "A few examples ..." )
			df( "|c00ffff/%s 20", cmd )
			d( " You rolled 7 with 1d20" )
			df( "|c00ffff/%s 100", cmd )
			d( " You rolled 83 with 1d100" )
			df( "|c00ffff/%s 2d20", cmd )
			d( " You rolled 22 with 2d20 (9, 13)" )
			df( "|c00ffff/%s 2d20:8", cmd )
			d( " Success. You rolled 22 with 2d20 (9, 13)" )
			df( "|c00ffff/%s 2d20:30", cmd )
			d( " Failed. You rolled 22 with 2d20 (9, 13)" )
			df( "|c00ffff/%s|r reuses the previous roll's options", cmd )

			return
		end

		if "emote" == args or "emotes" == args or "use emotes" == args then
			EHT.SavedVars.DiceUseEmotes = false == EHT.SavedVars.DiceUseEmotes
			df( "Emotes %s be used for success/fail rolls.", EHT.SavedVars.DiceUseEmotes and "will" or "will not" )

			return
		end

		local num, sides, threshold

		if "" == args then
			args = EHT.SavedVars.DicePreviousOptions or ""
		end

		if string.find( args, "d" ) then
			num, sides, threshold = string.match( args, "(%d*)d?(%d+):?(%d*)" )
		else
			sides, threshold = string.match( args, "(%d+):?(%d*)" )
			num = 1
		end

		num, sides, threshold = tonumber( num ), tonumber( sides ), tonumber( threshold )

		if not sides and "" == args then
			sides = 20
		end

		local warnings = { }

		if not num then
			table.insert( warnings, "Invalid number of dice." )
		elseif 1 > num or 10 < num then
			table.insert( warnings, "You may roll 1 to 10 dice" )
		end

		if not sides then
			table.insert( warnings, "Invalid number of sides." )
		elseif 2 > sides or 1000 < sides then
			table.insert( warnings, "Each dice may have 2 to 1000 sides." )
		end

		if 0 < #warnings then
			d( table.concat( warnings, "\n" ) )
			EHT.Biz.RollDice( cmd, "help" )

			return
		end

		local sDice, sSuccess, sRoll, roll
		local total, rolls = 0, { }

		for index = 1, num do
			roll = math.random( 1, sides )
			total = total + roll
			table.insert( rolls, tostring( roll ) )
		end

		sDice = string.format( "%dd%d", num, sides )
		sSuccess = threshold and string.format( "%s. ", threshold <= total and "|c00ff00Success|r" or "|cff0000Failed|r" ) or ""
		sRoll = 1 == #rolls and string.format( "You rolled |c00ffff%d|r with |c00ffff%s", total, sDice ) or string.format( "You rolled |c00ffff%d|r with |c00ffff%s|r (|c00ffff%s|r)|cffffff", total, sDice, table.concat( rolls, ", " ) )

		df( "%s%s", sSuccess, sRoll )

		if threshold and false ~= EHT.SavedVars.DiceUseEmotes then
			local emoteIndex

			if threshold <= total then
				emoteIndex = EHT.Util.GetEmoteIndexBySlashName( "/thumbsup" )
			else
				emoteIndex = EHT.Util.GetEmoteIndexBySlashName( "/thumbsdown" )
			end

			if emoteIndex then
				PlayEmoteByIndex( emoteIndex )
			end
		end

		EHT.SavedVars.DicePreviousOptions = args
	end
end

---[ Add Change History Macro ]---

function EHT.Biz.AddChangeHistory( before, after )
	if not before or not after then
		return false
	end

	if not before.Link then
		before.Link = EHT.Housing.GetFurnitureLink( before.Id )
	end

	local history = EHT.CT.CreateHistory( EHT.CONST.CHANGE_TYPE.CHANGE, before, after )
	local result = EHT.CT.AddHistory( history )

	if result then
		EHT.UI.RefreshHistory()
	end

	return result
end

---[ Kiosks ]---

do
	local currentActive
	local currentHouseId
	local currentKiosk
	local currentName

	function EHT.Biz.IsKioskInUse()
		return EHT.Housing.IsOwner() and currentHouseId and currentHouseId == EHT.Housing.GetHouseId()
	end

	function EHT.Biz.GetCurrentKioskName()
		return currentName
	end

	local function GetAndLockKiosk( filter )
		if not EHT.Housing.IsOwner() then
			return nil
		end

		local houseId = EHT.Housing.GetHouseId()

		if currentHouseId and currentHouseId == houseId then
			return nil
		end

		local kiosk = EHT.Data.GetHouseKiosk( filter )
		currentActive = true
		currentHouseId = houseId
		currentKiosk = kiosk
		currentName = filter

		return kiosk
	end

	local function MoveKioskItem( item, x, y, z, pitch, yaw, roll )
		if not item then
			return
		end

		local collectibleId, id = item.CollectibleId, nil
		if collectibleId then
			id = GetFurnitureIdFromCollectibleId( collectibleId )
		else
			id = EHT.Housing.FindFurnitureId( item.Id )
		end

		local cX, cY, cZ, cPitch, cYaw, cRoll = EHT.Housing.GetFurniturePositionAndOrientation( id )
		if x and y and z and ( 0 ~= cX or 0 ~= cY or 0 ~= cZ ) then
			item.Original = string.serializeNumbers( { cX, cY, cZ, cPitch, cYaw, cRoll } )
			item.InUse = true
			EHT.Housing.SetFurniturePositionAndOrientation( id, x, y, z, pitch, yaw, roll )
		end
	end

	local function ResetKioskItem( item )
		if not item or not item.InUse then
			return
		end

		if item.Original then
			local state = string.deserializeNumbers( item.Original )
			MoveKioskItem( item, unpack( state ) )
		end

		item.InUse = false
		item.Original = nil
	end

	function EHT.Biz.DismissKioskProcess( processId )
		local data = EHT.ProcessData

		if not data or data.Index < 1 then
			EVENT_MANAGER:UnregisterForUpdate( "EHT.Biz.DismissKioskProcess" )
			currentHouseId, currentKiosk, currentName = nil, nil, nil
			EHT.Biz.EndProcess()
			return nil
		end

		EHT.Biz.SetProcessProgress(	data.Index / #data.Items )
		local item = data.Items[data.Index]
		data.Index = data.Index - 1

		ResetKioskItem( item )
	end

	function EHT.Biz.DismissKiosk()
		local SUPPRESS_MESSAGE = true
		if EHT.Biz.IsProcessRunning( SUPPRESS_MESSAGE ) then
			EHT.UI.DisplayNotification( "A process is already running" )
			return false
		end

		if not EHT.Housing.IsOwner() or not currentHouseId or currentHouseId ~= EHT.Housing.GetHouseId() then
			currentHouseId, currentKiosk, currentName = nil, nil, nil
			return false
		end

		if not currentActive then
			return false
		end

		currentActive = false

		EHT.Biz.StartProcess( EHT.PROCESS_NAME.DISMISS_KIOSK )
		EHT.ProcessData.Items = currentKiosk
		EHT.ProcessData.Index = #currentKiosk
		EVENT_MANAGER:RegisterForUpdate( "EHT.Biz.DismissKioskProcess", 250, EHT.Biz.DismissKioskProcess )

		return true
	end

	function EHT.Biz.SummonKioskProcess( processId )
		local data = EHT.ProcessData

		if not data or not data.Index or data.Index > #data.Items then
			EVENT_MANAGER:UnregisterForUpdate( "EHT.Biz.SummonKioskProcess" )
			currentActive = true
			EHT.Biz.EndProcess()
			return nil
		end

		EHT.Biz.SetProcessProgress(	data.Index / #data.Items )
		local item = data.Items[data.Index]
		data.Index = data.Index + 1

		MoveKioskItem( item[1], item[2], item[3], item[4], item[5], item[6], item[7] )
	end

	function EHT.Biz.SummonStorageKiosk()
		local kiosk = GetAndLockKiosk( "Storage & Assistants" )

		if not kiosk then
			EHT.UI.DisplayNotification( "Kiosk could not be initialized" )
			return nil
		end

		if 0 == #kiosk then
			EHT.UI.DisplayNotification( "No assistants or storage have been placed" )
			return nil
		end

		local pX, pY, pZ = GetPlayerWorldPositionInHouse()
		local theta = EHT.Biz.GetEditorHeading()
		local hCoeff, hOffset, vOffset, assistant, dist, width = 0.75, 0, 0, 0, 240, 200
		local pitch, yaw, roll = 0, theta, 0
		local sizeX, sizeY, sizeZ, x, y, z
		local maxItems = #kiosk
		local items = { }

		for index, item in ipairs( kiosk ) do
			if "assistant" == item.Type then
				yaw = theta - RAD180
				assistant = assistant + 1
				vOffset = 0
				dist = 160

				if 1 == assistant then
					if index == maxItems then
						hOffset = 0
					else
						hOffset = -0.6 * item.Z
					end
				elseif 2 == assistant then
					hOffset = 0.6 * item.Z
				elseif 3 == assistant then
					hOffset = 0
					dist = 120
				elseif 4 == assistant then
					hOffset = -0.4 * item.Z
					dist = 100
				elseif 5 == assistant then
					hOffset = 0.4 * item.Z
					dist = 100
				end
			else
				if 0.75 == hCoeff and index >= 3 then
					hCoeff = -0.75
					vOffset = 0
				elseif -0.75 == hCoeff and index >= 5 then
					hCoeff = 1.5
					vOffset = 0
				elseif 1.5 == hCoeff and index >= 7 then
					hCoeff = -1.5
					vOffset = 0
				end

				hOffset = hCoeff * width
				pitch, yaw, roll = 0, theta, 0
			end

			x = pX - dist * math.sin( theta ) + hOffset * math.sin( theta + 0.5 * math.pi )
			y = pY + vOffset
			z = pZ - dist * math.cos( theta ) + hOffset * math.cos( theta + 0.5 * math.pi )
			vOffset = vOffset + item.Y

			table.insert( items, { item, x, y, z, pitch, yaw, roll } )
		end

		EHT.Biz.StartProcess( EHT.PROCESS_NAME.SUMMON_KIOSK )
		EHT.ProcessData.Items = items
		EHT.ProcessData.Index = 1
		EVENT_MANAGER:RegisterForUpdate( "EHT.Biz.SummonKioskProcess", 250, EHT.Biz.SummonKioskProcess )

		return true
	end

	function EHT.Biz.SummonCraftingKiosk()
		local kiosk = GetAndLockKiosk( "Crafting Stations" )

		if not kiosk then
			EHT.UI.DisplayNotification( "Kiosk could not be initialized" )
			return nil
		end

		if 0 == #kiosk then
			EHT.UI.DisplayNotification( "No standard crafting stations have been placed" )
			return nil
		end

		local pX, pY, pZ = GetPlayerWorldPositionInHouse()
		local theta = EHT.Biz.GetEditorHeading()
		local maxItems = #kiosk
		local baseRadius = 50
		local items = { }
		local yawOffset = EHT.Biz.GetEditorHeading()

		for index, item in ipairs( kiosk ) do
			local theta = yawOffset + ( index / maxItems ) * 2 * math.pi
			local c, s = math.cos( theta ), math.sin( theta )
			local effRadius = baseRadius + math.max( item.X, item.Z ) + 200 * ( index % 2 ) + ( item.RadiusOffset or 0 )
			local baseX, baseY, baseZ = pX + effRadius * s, pY + item.Y * 0.5, pZ + effRadius * c
			local pitch, yaw, roll = 0, theta + ( item.FlipY and math.pi or 0 ), 0
			local x, y, z = EHT.Housing.GetFurniturePositionFromCenter( item.Id,	baseX, baseY, baseZ,	pitch, yaw, roll )

			table.insert( items, { item, x, y + ( item.YOffset or 0 ), z, pitch, yaw, roll } )
		end

		EHT.Biz.StartProcess( EHT.PROCESS_NAME.SUMMON_KIOSK )
		EHT.ProcessData.Items = items
		EHT.ProcessData.Index = 1
		EVENT_MANAGER:RegisterForUpdate( "EHT.Biz.SummonKioskProcess", 250, EHT.Biz.SummonKioskProcess )

		return true
	end
end

EHT.Modules = ( EHT.Modules or { } ) EHT.Modules.Business = true
