AUI.ReloadUIHelper = {}

local isLoaded = false

function AUI.ReloadUIHelper.Load()
	if isLoaded then
		return
	end
	
	SLASH_COMMANDS["/rl"] = ReloadUI
	
	isLoaded = true
end

function AUI.ReloadUIHelper.ReloadUI()
	ReloadUI()
end