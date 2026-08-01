local version = 1
local LAM2 = LibAddonMenu2
local mateName

local function settingsMenu()
	local panelData = {
		type = "panel",
		name = "Slash Mate",
		displayName = "Slash Mate Settings",
		author = "Circuitous",
		version = version,
	}
	
	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("SM_Settings", panelData)
	
	local optionsData = {
		[1] = {
			type = "header",
			name = "Set Your Mate",
		},
		
		[2] = {
			type = "description",
			text = "Make sure their @username is correct, and that they're on your friends list!",
		},
		
		[3] = {
			type = "editbox",
			name = "Mate",
			getFunc = 
				function()
					if mateName then
						return mateName
					elseif SMData.mateName then
						return SMData.mateName
					end
				end,
			setFunc = 
				function(val)
					mateName = val
					SMData.mateName = val
				end,
			tooltip = "Enter an @username from your friends list.",
			isMultiline = false,
			isExtraWide = false,
			width = "full",
		},
	}
		
	LAM2:RegisterOptionControls("SM_Settings", optionsData)
end

local function handleSettings()
	if SMData.mateName then mateName = SMData.mateName end
end

function SlashMate(mate)
	if mate == "" then mate = mateName end
	if IsFriend(mate) then
		JumpToFriend(mate)
		d("Attempting to teleport to your mate, " .. mate .. "...")
	else
		d("You and your mate, " .. mate .. ", aren't friends!")
	end
end

local function onLoad(eventCode, addOnName)
	if addOnName ~= "SlashMate" then return end
	SLASH_COMMANDS["/mate"] = SlashMate
	EVENT_MANAGER:UnregisterForEvent("SlashMate", EVENT_ADD_ON_LOADED)
	
	-- load some dang variables
	SMData = ZO_SavedVars:New("SlashMate_Data", version)
	
	-- make the menu or something
	settingsMenu()
	handleSettings()
end

EVENT_MANAGER:RegisterForEvent("SlashMate", EVENT_ADD_ON_LOADED, onLoad)
