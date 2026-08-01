
--Register LAM with LibStub
local LIBRARY_NAME = "LibLoadedAddons"
local MAJOR, MINOR = LIBRARY_NAME, 1
local lla, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not lla then return end	--the same or newer version of this lib is already loaded into memory 

local loadedAddons = {}

------------------------------------------------------------------------
-- 	General Functions  --
------------------------------------------------------------------------
function lla:RegisterAddon(uniqueAddonName, versionNumber)
	if type(versionNumber) ~= "number" then 
		return false, "Version number must be a number."
	end
	
	local version = loadedAddons[uniqueAddonName]
	
	if version then
		if version == 0 then
			loadedAddons[uniqueAddonName] = versionNumber
			return true
		else
			return false, "Version number already set for this addon"
		end
	end
	return false, "Addon not loaded, addon name not found."
end

function lla:UnregisterAddon(uniqueAddonName)
	if loadedAddons[uniqueAddonName] then
		loadedAddons[uniqueAddonName] = nil
		return true
	end
	return false, "Addon name was not registered"
end

function lla:IsAddonLoaded(uniqueAddonName)
	if loadedAddons[uniqueAddonName] then
		return true, loadedAddons[uniqueAddonName]
	end
	return false
end

local function OnPlayerActivated()
	EVENT_MANAGER:UnregisterForEvent(LIBRARY_NAME, EVENT_ADD_ON_LOADED)
end

local function OnAddOnLoaded(_event, addonName)
	loadedAddons[addonName] = 0
end
---------------------------------------------------------------------------------
--  Register Events --
---------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(LIBRARY_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(LIBRARY_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)






