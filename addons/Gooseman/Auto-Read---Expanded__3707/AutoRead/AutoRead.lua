---------------
-- Variables --
---------------

AutoRead = {
	name = "AutoRead",
	version = "3",
}

local hide = false
local yellowColor = ZO_ColorDef:New("EFFF00")

local SV
local defaults = 
{
	autoReadActive = true,
}

----------------------
-- Helper Functions --
----------------------

-- Prints the addon name before a user-defined (developer-defined?) message
local function Print(message, ...)
    df("[%s]: %s", yellowColor:Colorize(AutoRead.name), message:format(...))
end

-------------
-- Actions --
-------------

-- Hides the book by pushing the 'hudui' back onto the SCENE_MANAGER stack.
-- For some reason going straight to the 'hud' scene keeps the game in cursor mode, so we have to take an extra step.
local function HideBook(eventCode, bookTitle, body)
	SCENE_MANAGER:Push("hudui")
	Print("%s", bookTitle)
	hide = true
end

-- Moves from the 'hudui' scene (that we pushed onto the stack) to the 'hud' scene (to hide the mouse cursor)
local function HideCursor(eventCode, hidden)
	if (hide) then
		if (hidden) then
			SCENE_MANAGER:Push("hud")
			SetGameCameraUIMode(false)
			hide = false
		end
	end
end

local function SetEvents()
	if (SV.autoReadActive) then
		EVENT_MANAGER:RegisterForEvent(AutoRead.name, EVENT_SHOW_BOOK, HideBook)
		EVENT_MANAGER:RegisterForEvent(AutoRead.name, EVENT_RETICLE_HIDDEN_UPDATE, HideCursor)
	else
		EVENT_MANAGER:UnregisterForEvent(AutoRead.name, EVENT_SHOW_BOOK)
		EVENT_MANAGER:UnregisterForEvent(AutoRead.name, EVENT_RETICLE_HIDDEN_UPDATE)
	end
end

function ToggleAutoRead()
	SV.autoReadActive =  not (SV.autoReadActive)
	SetEvents()
end



local function BuildSettingsMenu()

	local panelData = {
		type = "panel",
		name = "Auto Read",
		author = ADDON_AUTHOR,
		version = ADDON_VERSION,
		registerForRefresh = true,
		registerForDefaults = true,
	}

	local optionsData = {
		{
			type = "checkbox",
			name = 'Auto Read Active',
			tooltip = 'If true, doesn\'t open books',
			getFunc = function() return SV.autoReadActive end,
			setFunc = function(value) SV.autoReadActive = value SetEvents() end,
			default = defaults.autoReadActive,
		},

	}

	local panel = LibAddonMenu2:RegisterAddonPanel("Auto_Read_Panel", panelData)
	LibAddonMenu2:RegisterOptionControls("Auto_Read_Panel", optionsData)


end
----------
-- Init --
----------

-- The 'main()' function
function AutoRead.OnAddOnLoaded(event, addonName)
	if addonName == AutoRead.name then
		-- Prevents the addon from being loaded over and over again.
		EVENT_MANAGER:UnregisterForEvent(AutoRead.name, EVENT_ADD_ON_LOADED)

		SV = ZO_SavedVars:NewAccountWide("AUTO_READ_VARS", 1, defaults)
		
		

		-- Action Event Registrations
		SetEvents()

		BuildSettingsMenu()
		


		-- Tells the user that we're ready to go! Sometimes is called before the chat window is started, so the user sees nothing.
		Print("Initialized...")

	end
end

-----------------------------
-- Load Event Registration --
-----------------------------

-- Calls the 'main()' function
EVENT_MANAGER:RegisterForEvent(AutoRead.name, EVENT_ADD_ON_LOADED, AutoRead.OnAddOnLoaded)

ZO_CreateStringId("SI_BINDING_NAME_AUTO_READ_TOGGLE", "Auto Read Toggle")