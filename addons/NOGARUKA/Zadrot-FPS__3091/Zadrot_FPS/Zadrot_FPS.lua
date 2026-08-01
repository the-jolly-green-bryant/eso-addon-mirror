local Name = "Zadrot_FPS"
local foreground = 65
local background = 20

local function Load()
	if Zadrot_FPS_Saved and Zadrot_FPS_Saved[1] and Zadrot_FPS_Saved[1] > 0 then foreground = Zadrot_FPS_Saved[1] end
	if Zadrot_FPS_Saved and Zadrot_FPS_Saved[2] and Zadrot_FPS_Saved[2] > 0 then background = Zadrot_FPS_Saved[2] end
end

local function Set(active)
	if active then SetCVar("MinFrameTime.2", 1 / foreground)
	else SetCVar("MinFrameTime.2", 1 / background) end
end

EVENT_MANAGER:RegisterForEvent(
	Name,
	EVENT_ADD_ON_LOADED,
	function(_, loadedAddon)
		if loadedAddon == Name then
			EVENT_MANAGER:UnregisterForEvent(Name, EVENT_ADD_ON_LOADED)
			Load()
			--Set(DoesGameHaveFocus())
			Set(true)
		end
	end
)

EVENT_MANAGER:RegisterForEvent(
	Name .. "FocusChanged",
	EVENT_GAME_FOCUS_CHANGED,
	function(_, focus)
		Set(focus)
	end
)

local function ZadrotSC(args)
	Zadrot_FPS_Saved = {}
	for d in string.gmatch(args, "%d+") do
		table.insert(Zadrot_FPS_Saved, tonumber(d))
	end
	Load()
	d("Foreground = " .. foreground .. ", Background = " .. background)
	Set(DoesGameHaveFocus())
end
SLASH_COMMANDS["/zfps"] = ZadrotSC