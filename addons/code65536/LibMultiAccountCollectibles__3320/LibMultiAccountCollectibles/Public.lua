local LCCC = LibCodesCommonCode
local Internal = LibMultiAccountCollectiblesInternal
local Public = LibMultiAccountCollectibles


--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------

-- Callback events
Public.EVENT_COLLECTION_UPDATED = 1


--------------------------------------------------------------------------------
-- General
--------------------------------------------------------------------------------

function Public.GetServerAndAccountList( alwaysIncludeCurrentAccount )
	local results = { }
	for _, server in ipairs(LCCC.GetSortedKeys(Internal.data, Internal.server)) do
		local accounts = LCCC.GetSortedKeys(Internal.data[server], Internal.account)
		if (#accounts > 0) then
			table.insert(results, { server = server, accounts = accounts })
		end
	end
	if (alwaysIncludeCurrentAccount) then
		if (not results[1] or results[1].server ~= Internal.server) then
			table.insert(results, 1, { server = Internal.server, accounts = { Internal.account } })
		elseif (results[1].accounts[1] ~= Internal.account) then
			table.insert(results[1].accounts, 1, Internal.account)
		end
	end
	return results
end

function Public.IsCollectibleOwnedByAccount( server, account, collectibleId )
	if (not server or server == "") then server = Internal.server end
	if (not account or account == "") then account = Internal.account end

	if (server == Internal.server and account == Internal.account) then
		return Internal.IsCollectibleOwned(collectibleId)
	elseif (Internal.data[server] and Internal.data[server][account]) then
		return Internal.ReadId(Internal.data[server][account], collectibleId)
	else
		return false
	end
end

function Public.GetLastScanTime( server, account )
	if (not server or server == "") then server = Internal.server end
	if (not account or account == "") then account = Internal.account end

	if (server == Internal.server and account == Internal.account) then
		return Internal.ReadTimeStamp(currentData)
	elseif (Internal.data[server] and Internal.data[server][account]) then
		return Internal.ReadTimeStamp(Internal.data[server][account])
	else
		return 0
	end
end

function Public.GetMaxCollectibleId( )
	return Internal.vars and Internal.vars.maxId or 0
end


--------------------------------------------------------------------------------
-- Callbacks
--------------------------------------------------------------------------------

Internal.callbacks = {
	[Public.EVENT_COLLECTION_UPDATED] = { },
}

function Public.RegisterForCallback( name, eventCode, callback )
	if (type(name) == "string" and type(eventCode) == "number" and type(callback) == "function" and Internal.callbacks[eventCode]) then
		Internal.callbacks[eventCode][name] = callback
		return true
	end
	return false
end

function Public.UnregisterForCallback( name, eventCode )
	if (type(name) == "string" and type(eventCode) == "number" and Internal.callbacks[eventCode]) then
		Internal.callbacks[eventCode][name] = nil
		return true
	end
	return false
end

function Internal.FireCallbacks( eventCode, ... )
	for _, callback in pairs(Internal.callbacks[eventCode]) do
		callback(eventCode, ...)
	end
end
