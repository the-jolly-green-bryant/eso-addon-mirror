-- All code here was been adapted from the Port to Friend's House addon.
RollplayIntegration = {}

RollplayIntegration.name = "RollplayIntegration"
RollplayIntegration.hacks = {}
RollplayIntegration.hacks.callbackName = "RollplayIntegration.ContextMenuHack"
RollplayIntegration.hacks.callbackInterval = 500

function RollplayIntegration.Initialize()
end

function RollplayIntegration.OnAddOnLoaded(event, addonName)
  if addonName == RollplayIntegration.name then
    RollplayIntegration:Initialize()
	
	--Shissus ContextMenu Hack as he failed to implement this properly
	EVENT_MANAGER:RegisterForUpdate(RollplayIntegration.hacks.callbackName, RollplayIntegration.hacks.callbackInterval, RollplayIntegration.ContextMenuHackOnUpdate)
  end
end

function RollplayIntegration.LaunchProfile(displayName)
	local url = "https://eso-rollplay.net/profile.html?character=" .. displayName
	RequestOpenUnsafeURL(url)
end

--Shissus ContextMenu Hack as he failed to implement this properly
function RollplayIntegration.ContextMenuHackOnUpdate()
	if RollplayIntegration.hacks.contextMenuHackUpdated == nil then
		RollplayIntegration.hacks.contextMenuHackUpdated = true
		--d("first")
	else
		--d("second")
		RollplayIntegration.AdjustContextMenus()
		EVENT_MANAGER:UnregisterForUpdate(RollplayIntegration.hacks.callbackName)
	end
end

function RollplayIntegration.AdjustContextMenus()
	local ShowPlayerContextMenu = CHAT_SYSTEM.ShowPlayerContextMenu
	CHAT_SYSTEM.ShowPlayerContextMenu = function(self, displayName, rawName)
		ShowPlayerContextMenu(self, displayName, rawName)

		if string.sub(displayName, 1, 1) ~= "@" then
			AddCustomMenuItem("View Rollplay Profile", function() RollplayIntegration.LaunchProfile(displayName) end )
		end
		--d("DisplayName: " .. displayName)
		if ZO_Menu_GetNumMenuItems() > 0 then 
			ShowMenu() 
		end
	end
end
 
EVENT_MANAGER:RegisterForEvent(RollplayIntegration.name, EVENT_ADD_ON_LOADED, RollplayIntegration.OnAddOnLoaded)