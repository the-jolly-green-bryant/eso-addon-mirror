if not EHT then EHT = { } end
if not EHT.Interop then EHT.Interop = { } end


local function StripCharacter( s, c, r )
	if s then
		return string.gsub( s, c, r or "" )
	end
end


---[ Interoperability : 3rd Party ]---


function EHT.Interop.GetAPIVersion()

	return 1

end


EHT.Interop.RESULT = {
	EXCEPTION = -1,
	SUCCESS = 0,
	NOT_FOUND = 1,
}


--[[
Queues the action(s) that would normally occur when
the specified trigger met its defined conditions.

ARGS:
 triggerName (string)

RETURNS:
 result (EHT.Interop.RESULT)
]]

function EHT.Interop.QueueTriggerActions( triggerName )

	assert( "string" == type( triggerName ), "Argument 'triggerName' must be of type 'string'." )

	local trigger = EHT.Data.GetTriggerByName( triggerName )
	if not trigger then
		return EHT.Interop.RESULT.NOT_FOUND
	end

	EHT.Biz.QueueSingleTriggerActions( trigger )
	return EHT.Interop.RESULT.SUCCESS

end


--[[
Queries whether any of the specified trigger's action(s)
are already queued.

ARGS:
 triggerName (string)

RETURNS:
 isQueued (boolean, nilable),
 result (EHT.Interop.RESULT)
]]

function EHT.Interop.IsTriggerQueued( triggerName )

	assert( "string" == type( triggerName ), "Argument 'triggerName' must be of type 'string'." )

	local trigger = EHT.Data.GetTriggerByName( triggerName )
	if not trigger then
		return nil, EHT.Interop.RESULT.NOT_FOUND
	end

	local isQueued = EHT.Biz.IsTriggerQueued( trigger )
	return isQueued, EHT.Interop.RESULT.SUCCESS

end


---[ Interoperability : Essential Housing Tools Saver ]---


function EHT.Interop.GetEHTSaverAPI()

	if EHTSaver and EHTSaver.Archive and EHTSaver.Archive.GetMostRecentArchive and EHTSaver.Archive.RestoreMostRecentArchive and EHTSaver.Archive.HasEHTSavedVarsReset then
		return 1
	else
		return 0
	end

end


function EHT.Interop.GetEHTSaverMostRecentArchive()

	if 1 > EHT.Interop.GetEHTSaverAPI() then return end

	local archive = EHTSaver.Archive.GetMostRecentArchive()
	return archive

end


function EHT.Interop.EHTSaverRestoreMostRecentArchive()

	if 1 > EHT.Interop.GetEHTSaverAPI() then return end

	return EHTSaver.Archive.RestoreMostRecentArchive()

end


function EHT.Interop.HasEHTSavedVarsReset()

	if 1 > EHT.Interop.GetEHTSaverAPI() then return false end

	return EHTSaver.Archive.HasEHTSavedVarsReset()

end


---[ Interoperability : DecoTrack ]---

function EHT.Interop.GetDecoTrackAPI()
	if DecoTrack and DecoTrack.Interop and DecoTrack.Interop.GetAPI then
		return DecoTrack.Interop.GetAPI() or 0
	else
		return 0
	end
end

function EHT.Interop.GetDecoTrackCountsByItemId( itemId )
	if 1 > EHT.Interop.GetDecoTrackAPI() then return nil end
	if not DecoTrack.Interop.GetCountsByItemId then return nil end
	return DecoTrack.Interop.GetCountsByItemId( itemId )
end

function EHT.Interop.SearchDecoTrack( searchText )
	if 2 > EHT.Interop.GetDecoTrackAPI() then return nil end
	if not DecoTrack.Interop.Search then return nil end
	return DecoTrack.Interop.Search( searchText )
end

function EHT.Interop.GetDecoTrackCountsByHouse()
	if 2 > EHT.Interop.GetDecoTrackAPI() then return nil end
	if not DecoTrack or not DecoTrack.Data or "table" ~= type( DecoTrack.Data.Houses ) then return nil end

	local template = { }
	local containers = DecoTrack.Data.Houses
	local counts = { }

	for limitType = HOUSING_FURNISHING_LIMIT_TYPE_MIN_VALUE, HOUSING_FURNISHING_LIMIT_TYPE_MAX_VALUE do
		template[limitType] = 0
	end

	local house, limitType

	for _, container in pairs( DecoTrack.Data.Houses ) do
		if container.HouseId then
			house = EHT.Util.CloneTable( template )
			counts[container.HouseId] = house

			for itemId, count in pairs( container.Items ) do
				limitType = EHT.Housing.GetFurnitureLimitTypeByItemId( itemId )

				if limitType then
					house[limitType] = house[limitType] + count
				end
			end
		end
	end

	return counts
end

function EHT.Interop.DoesDecoTrackSupportEnhancedSearch()
	return 3 <= EHT.Interop.GetDecoTrackAPI()
end

function EHT.Interop.DoesDecoTrackSupportBoundItems()
	return 4 <= EHT.Interop.GetDecoTrackAPI()
end

function EHT.Interop.HasDecoTrackVisitedAllOwnedHomes()
	if 0 < EHT.Interop.GetDecoTrackAPI() and DecoTrack.Interop.HasVisitedAllOwnedHomes then
		return DecoTrack.Interop.HasVisitedAllOwnedHomes()
	end
	return true
end

function EHT.Interop.DecoTrackVisitAllHomes()
	if 0 < EHT.Interop.GetDecoTrackAPI() and DecoTrack.UpdateAllHouses then
		DecoTrack.UpdateAllHouses()
		return true
	end
	return false
end

---[ Interoperability : Furniture Snap ]---


EHT.Interop.FurnSnapCallbackId = 0
EHT.Interop.FurnSnapSuspended = false


function EHT.Interop.SuspendFurnitureSnap()

	if FurnSnap then
		EHT.Interop.FurnSnapSuspended = true

		if FurnSnap.SuspendSnapping then
			FurnSnap.SuspendSnapping()
		else
			EHT.FurnSnapEnabled = FurnSnap.Enabled
			FurnSnap.Enabled = false
		end
	end

end


function EHT.Interop.ResumeFurnitureSnap()

	if FurnSnap then
		EHT.Interop.FurnSnapSuspended = false

		if FurnSnap.ResumeSnapping then
			EHT.Interop.FurnSnapCallbackId = zo_callLater( function( id )
				if id ~= EHT.Interop.FurnSnapCallbackId or EHT.Interop.FurnSnapSuspended then
					return
				end
				FurnSnap.ResumeSnapping()
			end, 500 )
		else
			EHT.Interop.FurnSnapCallbackId = zo_callLater( function( id )
				if id ~= EHT.Interop.FurnSnapCallbackId or EHT.Interop.FurnSnapSuspended then
					return
				end
				FurnSnap.Enabled = EHT.FurnSnapEnabled
			end, 500 )
		end
	end

end


---[ Interoperability : Oops, I Did It Again ]---


function EHT.Interop.DisableOopsI()

	if OopsI and OopsI.ADDON_NAME and not OopsI.DisabledByEHT then

		OopsI.DisabledByEHT = true

		EVENT_MANAGER:UnregisterForEvent( OopsI.ADDON_NAME, EVENT_ADD_ON_LOADED )
		EVENT_MANAGER:UnregisterForEvent( OopsI.ADDON_NAME, EVENT_GAME_CAMERA_UI_MODE_CHANGED )
		EVENT_MANAGER:UnregisterForEvent( OopsI.ADDON_NAME, EVENT_HOUSING_EDITOR_MODE_CHANGED )
		EVENT_MANAGER:UnregisterForEvent( OopsI.ADDON_NAME, EVENT_HOUSING_FURNITURE_PLACED )
		EVENT_MANAGER:UnregisterForEvent( OopsI.ADDON_NAME, EVENT_HOUSING_FURNITURE_REMOVED )

		SLASH_COMMANDS[ "/oops" ] = nil
		SLASH_COMMANDS[ "/redo" ] = nil
		SLASH_COMMANDS[ "/undo" ] = nil
		SLASH_COMMANDS[ "/undohist" ] = nil
		SLASH_COMMANDS[ "/undoclear" ] = nil

		if not EHT.SavedVars.SuppressOopsIDidItAgainWarning then
			d( "'Essential Housing Tools' now includes Undo and Redo functionality and has replaced my earlier add-on 'Oops I Did It Again'." )
			d( "You may uninstall 'Oops I Did It Again' at your earliest convenience." )

			EHT.SavedVars.SuppressOopsIDidItAgainWarning = true
		end

	end

end

---[ Interoperability : Tamriel Trade Centre ]---

function EHT.Interop.IsTradingPriceInfoAvailable()
	return TamrielTradeCentrePrice ~= nil and TamrielTradeCentrePrice.GetPriceInfo ~= nil
end

--[[
Returns
	If no price data is available:
		nil
	If price data is available:
		Avg
		Min
		Max
		EntryCount
		AmountCount
		SuggestedPrice
]]
function EHT.Interop.GetItemLinkTradingPriceInfo( itemLink )
	if not EHT.Interop.IsTradingPriceInfoAvailable() then
		return
	end

	local priceInfo = TamrielTradeCentrePrice:GetPriceInfo( itemLink )
	if priceInfo then
		if priceInfo.SuggestedPrice then
			priceInfo.Resale = priceInfo.SuggestedPrice
		elseif priceInfo.Avg then
			priceInfo.Resale = priceInfo.Avg
		elseif priceInfo.Min and priceInfo.Max then
			priceInfo.Resale = 0.5 * ( priceInfo.Min + priceInfo.Max )
		end
	end
	return priceInfo
end

---[ Interoperability : Inbound Events ]---

function EHT.Interop.FurnitureChangedEvent( furnitureId, x, y, z, pitch, yaw, roll )
	if furnitureId then
		EHT.Handlers.OnFurnitureChanged( { furnitureId, x or 0, y or 0, z or 0, pitch or 0, yaw or 0, roll or 0 } )
	end
end

function EHT.Interop.SuppressFurnitureChange( furnitureId )
	if furnitureId then
		EHT.Handlers.SuppressFurnitureChange( furnitureId )
	end
end

EHT.Modules = ( EHT.Modules or { } ) EHT.Modules.Interop = true
