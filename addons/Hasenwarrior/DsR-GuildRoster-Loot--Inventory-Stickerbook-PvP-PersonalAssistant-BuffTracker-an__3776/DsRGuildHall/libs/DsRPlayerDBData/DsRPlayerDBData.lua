local libName, libVersion = "DsRPlayerDBData", 100
local lib    = {}

lib.libName  = libName
lib.playerDB = {}

local function Initialize()
  if not DsRPlayerDBData_SV then DsRPlayerDBData_SV = lib.playerDB end
end

local function OnAddOnLoaded(eventCode, addonName)
  if addonName == lib.libName then
    Initialize()
  end
end

EVENT_MANAGER:RegisterForEvent(lib.libName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

DsRPlayerDBData_SV = lib
