---------------
-- Variables --
---------------

AutoRead = {
	name = "AutoRead",
	version = 2
}

local hide = false
local yellowColor = ZO_ColorDef:New("EFFF00")

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
			hide = false
		end
	end
end

----------
-- Init --
----------

-- The 'main()' function
function AutoRead.OnAddOnLoaded(event, addonName)
	if addonName == AutoRead.name then
		-- Prevents the addon from being loaded over and over again.
		EVENT_MANAGER:UnregisterForEvent(AutoRead.name, EVENT_ADD_ON_LOADED)
		
		-- Action Event Registrations
		EVENT_MANAGER:RegisterForEvent(AutoRead.name, EVENT_SHOW_BOOK, HideBook)
		EVENT_MANAGER:RegisterForEvent(AutoRead.name, EVENT_RETICLE_HIDDEN_UPDATE, HideCursor)
		
		-- Tells the user that we're ready to go! Sometimes is called before the chat window is started, so the user sees nothing.
		Print("Initialized...")
	end
end

-----------------------------
-- Load Event Registration --
-----------------------------

-- Calls the 'main()' function
EVENT_MANAGER:RegisterForEvent(AutoRead.name, EVENT_ADD_ON_LOADED, AutoRead.OnAddOnLoaded)