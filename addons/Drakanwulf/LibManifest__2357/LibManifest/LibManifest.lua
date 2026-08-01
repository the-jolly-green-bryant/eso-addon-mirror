--[[###############################################################################################################################

LibManifest - LibManifest builds a table of manifest directive values for the "addOnName" you specify.
	by Drakanwulf and Hawkeye1889

"Standalone" means that LibManifest should not be embedded. Please load only one instance of LibManifest from the ".../Addons/" directory and use a "##DependsOn: LibManifest" directive in the manifest file for your add-on to instruct the game to verify that LibManifest is running before the game loads your add-on.

WARNING: While this support add-on will work with WrathStone (100026), its Elsweyr values will be invalid until 100027 is released.

Manifest Table Layout:
This example illustrates a manifest table layout. The comment fields are informational asides and opinions.

	manifest = {
		-- These values are retrieved from existing manifest directives
		author,			-- From the Author: directive Without any special characters
		description,	-- From the Description: directive
		fileName,		-- The name of this add-on's folder and manifest file
		isEnabled,		-- ESO boolean value
		isOutOfDate,	-- ESO boolean value
		loadState,		-- ESO load state (i.e. loaded; not loaded)
		title,			-- From the Title: directive without any special characters

		-- These values are retrieved from 100026 manifest directives
		addOnVersion,	-- From the AddOnVersion: directive
		filePath,		-- Path to this add-on's folder/directory

		-- These values are retrieved from 100027 manifest directives
		isLibrary,		-- From the IsLibrary: directive
	}
				
###############################################################################################################################--]]

--[[-------------------------------------------------------------------------------------------------------------------------------
Local variables shared by multiple functions within this add-on.
---------------------------------------------------------------------------------------------------------------------------------]]
local ADDON_NAME = "LibManifest"

--[[-------------------------------------------------------------------------------------------------------------------------------
Bootstrap code to either load or fail this add-on.
---------------------------------------------------------------------------------------------------------------------------------]]
assert( not _G[ADDON_NAME], ADDON_NAME.. ": is already loaded. Do NOT load add-ons multiple times!" )

local addon = {}
_G[ADDON_NAME] = addon
assert( _G[ADDON_NAME], ADDON_NAME.. ". The game failed to create a global control entry!" )

--[[-------------------------------------------------------------------------------------------------------------------------------
Local functions needed to build a manifest information table.
---------------------------------------------------------------------------------------------------------------------------------]]
-- Strip colorization strings from the input text 
local function Strip( text: string )
    return text:gsub( "|c%x%x%x%x%x%x", "" )
end

-- Create a manifest table and return it to the invoker.
local AM = GetAddOnManager()
local numAddOns = AM:GetNumAddOns()
local i, search

local function Create( addOnName: string )
	-- Iterate through the add-on table entries for this character
    for i = 1, numAddOns do
        _, search = AM:GetAddOnInfo( i )
		if ( Strip( search ) == addOnName ) then						-- We found a match!
			-- Load the table with addon manifest information
			local file, name, auth, desc, enabled, state, isOOD, isLib = AM:GetAddOnInfo( i )
			local manifest = {
				-- These values are retrieved from existing manifest directives
				author = Strip( auth ) or "",	-- "auth" sans any special characters
				description = desc or "",		-- From the Description: directive
				fileName = file or "",			-- The file/folder/manifest name
				isEnabled = enabled,			-- ESO boolean value
				isOutOfDate = isOOD,			-- ESO boolean value
				loadState = state,				-- ESO load state (i.e. loaded; not loaded)
				title = Strip( name ) or "",	-- "name" sans any special characters

				-- These values are retrieved from 100026 manifest directives
				addOnVersion = AM:GetAddOnVersion( i ) or 0,			-- Must be a numeric value
				filePath = AM:GetAddOnRootDirectoryPath( i ) or "",		-- Path to the add-on file/folder

				-- These values are retrieved from 100027 manifest directives
				isLibrary = isLib or 0,			-- ESO Boolean value
			}
			
			return manifest, i
		end
	end

	return nil, 0								-- "addOnName" did not match any of our loaded add-ons!
end

--[[-------------------------------------------------------------------------------------------------------------------------------
Define LibManifest API function(s).

LibManifest:Create( addOnName: string )
	The "addOnName: string" syntax tells the Havok VM to fail the API call if "addOnName" does not contain a ,lua alphanumeric string. Then, if a global control entry for "addOnName" exists (e.g. _G["addonName"]), this function returns a table that contains manifest directive information extracted from data that the game retains about this add-on and from information returned by other game API functions; otherwise, it returns a nil value to indicate that a control entry for "addOnName" could not be found.

	Input:
		addOnName := a string, between 1 and 64 alphanumeric characters long, containing an add-on name (e.g. "LibManifest").

	Returns:
		nil, 0 := A control entry for "addOnName" could not be found in the start up information for this character.
		
		table, i := 
			table := Contains a pointer to the manifest information table for _G["addOnName"]
			i := Contains the index value into the AddOnManager add-ons table for your character so you won't have to waste time and CPU cycles searching for this add-on again.
---------------------------------------------------------------------------------------------------------------------------------]]

function LibManifest:Create( addOnName: string )
	return Create( addOnName ) or nil, 0
end
	
--[[-------------------------------------------------------------------------------------------------------------------------------
And the last thing we do in this add-on is to wait for ESO to notify us that our modules and support add-ons (i.e. libraries) have been loaded so we can retrieve our own manifest table to verify that this add-on is functioning correctly.
---------------------------------------------------------------------------------------------------------------------------------]]
local function OnAddonLoaded( event, name )
	if name ~= ADDON_NAME then
		return
	end
	EVENT_MANAGER:UnregisterForEvent( ADDON_NAME, EVENT_ADD_ON_LOADED )

	local test, index = Create( ADDON_NAME )
	assert( test ~= nil, ADDON_NAME.. ": Failed. The table return value was nil" )
	assert( index > 0, ADDON_NAME.. ": Failed. The index return value was zero" )
	
	addon.manifest = test
	_G[ADDON_NAME] = addon
end

EVENT_MANAGER:RegisterForEvent( ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded )
