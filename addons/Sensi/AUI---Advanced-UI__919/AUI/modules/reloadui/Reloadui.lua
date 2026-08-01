AUI.ReloadUIHelper = {}

local g_isInit = false

function AUI.ReloadUIHelper.Load()
	if g_isInit then
		return
	end
	
	g_isInit = true	
	
	SLASH_COMMANDS["/rl"] = ReloadUI
end

function AUI.ReloadUIHelper.ReloadUI()
	ReloadUI()
end