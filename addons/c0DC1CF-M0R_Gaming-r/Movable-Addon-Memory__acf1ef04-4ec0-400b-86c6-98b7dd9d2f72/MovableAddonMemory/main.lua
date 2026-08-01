MovableAddonMemory = {}
local MAM = MovableAddonMemory
local LCA = LibCombatAlerts

-- Written by M0R_Gaming

MAM.name = "MovableAddonMemory"
MAM.varversion = 1

MAM.DefaultSettings = {
	snap = 3,
	scale = 1,
}


local function playerActivated()
	if ADD_ON_MEMORY_DISPLAY.savedVars.isVisible == false then
		ADD_ON_MEMORY_DISPLAY:Toggle()
	end
	EVENT_MANAGER:UnregisterForEvent(MAM.name, EVENT_PLAYER_ACTIVATED)
end
EVENT_MANAGER:RegisterForEvent(MAM.name, EVENT_PLAYER_ACTIVATED, playerActivated)

-- The following was adapted from https://wiki.esoui.com/Circonians_Stamina_Bar_Tutorial#lua_Structure

-------------------------------------------------------------------------------------------------
--  OnAddOnLoaded  --
-------------------------------------------------------------------------------------------------
function MAM.OnAddOnLoaded(event, addonName)

	if addonName ~= MAM.name then return end

	MAM:Initialize()
end


-------------------------------------------------------------------------------------------------
--  Initialize Function --
-------------------------------------------------------------------------------------------------
function MAM:Initialize()
	MAM.vars = ZO_SavedVars:NewAccountWide("MovableAdddonMemoryVars", MAM.varversion, nil, MAM.DefaultSettings)

	local handler = LCA.MoveableControl:New(ZO_AddOnMemoryDisplay_TopLevel)
	if MAM.vars.pos then
		handler:UpdatePosition(MAM.vars.pos)
	end
	handler:SetSnap(MAM.vars.snap)

	ZO_AddOnMemoryDisplay_TopLevel:SetTransformScale(MAM.vars.scale)
	if MAM.vars.font then
		ZO_AddOnMemoryDisplay_TopLevelMemory:SetFont(MAM.vars.font)
	end
	if MAM.vars.colour then
		ZO_AddOnMemoryDisplay_TopLevelMemory:SetColor(unpack({ZO_ColorDef.HexToFloats(MAM.vars.colour or "ffffff")}))
	end

	handler:RegisterCallback("MovableAdddonMemoryMove", LCA.EVENT_CONTROL_MOVE_STOP, function(newPos)
		MAM.vars.pos = newPos
		SCENE_MANAGER:Show("hud")
	end)

	SLASH_COMMANDS["/moveaddonmemory"] = function()
		handler:ToggleGamepadMove(true)
	end
	SLASH_COMMANDS["/mamsetsnap"] = function(num)
		local snapSize = tonumber(num)
		MAM.vars.snap = snapSize
		handler:SetSnap(snapSize)
	end
	SLASH_COMMANDS["/mamsetscale"] = function(num)
		local scale = tonumber(num)
		MAM.vars.scale = scale
		ZO_AddOnMemoryDisplay_TopLevel:SetTransformScale(scale)
	end
	SLASH_COMMANDS["/mamsetfont"] = function(font)
		if font == "default" then font = nil end
		MAM.vars.font = font
		ZO_AddOnMemoryDisplay_TopLevelMemory:SetFont(MAM.vars.font or "ZoFontGamepadBold18")
	end
	SLASH_COMMANDS["/mamsetcolour"] = function(colour)
		if colour == "default" then colour = nil end
		MAM.vars.colour = colour
		ZO_AddOnMemoryDisplay_TopLevelMemory:SetColor(unpack({ZO_ColorDef.HexToFloats(MAM.vars.colour or "ffffff")}))
	end

	EVENT_MANAGER:UnregisterForEvent(MAM.name, EVENT_ADD_ON_LOADED)
end
 
-------------------------------------------------------------------------------------------------
--  Register Events --
-------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(MAM.name, EVENT_ADD_ON_LOADED, MAM.OnAddOnLoaded)
