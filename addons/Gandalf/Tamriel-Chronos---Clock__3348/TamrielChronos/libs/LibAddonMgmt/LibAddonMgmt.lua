-----------------------------------------------------------------------------
-- 					      									               --
-- 	Title:		 AddOn Management (LibAddonMgmt)                           --
--	Author: 	 Gandalf (@Gandalf2675)								  	   --
-- 					      									               --
-----------------------------------------------------------------------------

LibAddonMgmt      = LibAddonMgmt or {}
local lib         = LibAddonMgmt
lib.ADDON_NAME    = "LibAddonMgmt"
lib.ADDON_VERSION = 10105


local function GetAddonState(state)
    local AddOnLoadState = {
    	[ADDON_STATE_DEPENDENCIES_DISABLED]      = "ADDON_STATE_DEPENDENCIES_DISABLED",
    	[ADDON_STATE_DISABLED]                   = "ADDON_STATE_DISABLED",
    	[ADDON_STATE_ENABLED]                    = "ADDON_STATE_ENABLED",
    	[ADDON_STATE_ERROR_STATE_UNABLE_TO_LOAD] = "ADDON_STATE_ERROR_STATE_UNABLE_TO_LOAD",
    	[ADDON_STATE_NO_STATE]                   = "ADDON_STATE_NO_STATE",
    	[ADDON_STATE_TOC_LOADED]                 = "ADDON_STATE_TOC_LOADED",
    	[ADDON_STATE_VERSION_MISMATCH]           = "ADDON_STATE_VERSION_MISMATCH",
    }
    return AddOnLoadState[state] or "unknown state="..tostring(state)
end

local function GetAddonInfo(addOnName)
	local AM        = GetAddOnManager()
	local numAddons = AM:GetNumAddOns()
	for i = 1, numAddons do
		local name, title, author, description, enabled, state, isOutOfDate = AM:GetAddOnInfo(i)
    	if name == addOnName and enabled then
    		local version = AM:GetAddOnVersion(i)
    		local path    = AM:GetAddOnRootDirectoryPath(i)
   		 	return author, title, description, version, path
	    end
	end
	return nil
end

function lib:GetAuthor(addOnName)
	local author = GetAddonInfo(addOnName) 
	return author or ""
end

function lib:GetDescription(addOnName, format)
	local author, title, description = GetAddonInfo(addOnName) 
	return description or ""
end

function lib:GetTitle(addOnName, format)
	local author, title = GetAddonInfo(addOnName) 
	return title or ""
end

function lib:GetVersion(addOnName)
	local author, title, description, version = GetAddonInfo(addOnName) 
	if version ~= nil then
		local main = math.floor(version / 10000)
		local sub  = math.floor((version % 10000) / 100)
		local ssub = version % 100
		if ssub > 0 then
			version = string.format("v%d.%d.%d", main, sub, ssub)
		else
			version = string.format("v%d.%d", main, sub)
		end
	else
		version = ""
	end
	return version
end

function lib:GetPath(addOnName)
	local author, title, description, version, path = GetAddonInfo(addOnName) 
	return path or ""
end

function lib:IsInstalledCorrectly(addOnName)
	local path = self:GetPath(addOnName)
    assert( path ~= "", ZO_ERROR_COLOR:Colorize("*** The addon name ["..tostring(addOnName).."] is wrong, this is a developer issue ***"))
	local root = path:gsub("user:/AddOns/", "")
    assert( root == addOnName.."/", ZO_ERROR_COLOR:Colorize("*** Wrong Installation of "..addOnName.."! Path should be: user:/AddOns/"..addOnName.."/, but found: "..path.." ***"))
end

function lib:ListAddons(addOnName)
	local AM        = GetAddOnManager()
	local numAddons = AM:GetNumAddOns()
	d("*** LibAddonMgmt - List AddOns:")
	for i = 1, numAddons do
		local name, title, author, description, enabled, state, isOutOfDate = AM:GetAddOnInfo(i)
    	if (addOnName == nil or string.find(name, addOnName,1,true) ~= nil) then
    		local version = AM:GetAddOnVersion(i)
    		local path    = AM:GetAddOnRootDirectoryPath(i)
			local msg     = "[%2d] - name=[%s] - enabled=[%s] - version=[%s] - path=[%s]"    		
   		 	d(msg:format(i, name, tostring(enabled), version, path))
	    end
	end
end

function lib:ListNonRootAddons(addOnName)
	local AM        = GetAddOnManager()
	local numAddons = AM:GetNumAddOns()
	d("*** LibAddonMgmt - List Non-Root Addons:")
	for i = 1, numAddons do
		local name, title, author, description, enabled, state, isOutOfDate = AM:GetAddOnInfo(i)
   		local path = AM:GetAddOnRootDirectoryPath(i)
		local root = path:gsub("user:/AddOns/", "")
    	if (addOnName == nil or string.find(name, addOnName,1,true) ~= nil) and root ~= name.."/" then
    		local version = AM:GetAddOnVersion(i)
   			local msg     = "[%2d] - name=[%s] - enabled=[%s] - version=[%s] - path=[%s]"    		
   		 	d(msg:format(i, name, tostring(enabled), version, path))
	    end
	end
end

function lib:ListAddonsState(addOnName)
	local AM        = GetAddOnManager()
	local numAddons = AM:GetNumAddOns()
	d("*** LibAddonMgmt - List AddOns States:")
	for i = 1, numAddons do
		local name, title, author, description, enabled, state, isOutOfDate = AM:GetAddOnInfo(i)
    	if (addOnName == nil or string.find(name, addOnName,1,true) ~= nil) then
    		local version = AM:GetAddOnVersion(i)
    		local path    = AM:GetAddOnRootDirectoryPath(i)
			local msg     = "[%2d] - name=[%s] - enabled=[%s] - version=[%s] - isOutOfDate=[%s] - state=[%s]"    		
   		 	d(msg:format(i, name, tostring(enabled), version, tostring(isOutOfDate), GetAddonState(state)))
	    end
	end
end

function lib:ListNonEnabledAddons(addOnName)
	local AM        = GetAddOnManager()
	local numAddons = AM:GetNumAddOns()
	d("*** LibAddonMgmt - List AddOns in non ADDON_STATE_ENABLED state :")
	for i = 1, numAddons do
		local name, title, author, description, enabled, state, isOutOfDate = AM:GetAddOnInfo(i)
    	if (addOnName == nil or string.find(name, addOnName,1,true) ~= nil) then
    		if state ~= ADDON_STATE_ENABLED then
        		local version = AM:GetAddOnVersion(i)
        		local path    = AM:GetAddOnRootDirectoryPath(i)
    			local msg     = "[%2d] - name=[%s] - enabled=[%s] - version=[%s] - isOutOfDate=[%s] - state=[%s]"    		
       		 	d(msg:format(i, name, tostring(enabled), version, tostring(isOutOfDate), GetAddonState(state)))
   		 	end
	    end
	end
end