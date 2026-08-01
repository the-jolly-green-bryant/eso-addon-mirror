rgbaoe = rgbaoe or { }
local r = rgbaoe
local EM = GetEventManager()
local format = string.format -- gotta save those precious cpu cycles (this one's for you andy)
local min = math.min
local max = math.max

r.name = "RGBAOE"
r.version = "2.3"
local red = 255
local green = 0
local blue = 0

r.defaults = {
	["defaultColor"] = GetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENEMY_COLOR),
	["enabled"] = false,
	["speed"] = 50,
	["turbo"] = 1,
}

function r.cycle()
	-- yikes.png
	local turbo = r.savedVars.turbo
	if ( red == 255 ) and ( green < 255) and ( blue == 0 ) then
		green = min((green + (5*turbo)), 255)
	elseif ( red > 0 ) and ( green == 255) and ( blue == 0 ) then
		red = max((red - (5*turbo)), 0)
	elseif ( red == 0 ) and ( green == 255 ) and ( blue < 255 ) then
		blue = min((blue + (5*turbo)), 255)
	elseif ( red == 0 ) and ( green > 0 ) and ( blue == 255 ) then
		green = max((green - (5*turbo)), 0)
	elseif ( red < 255 ) and ( green == 0 ) and ( blue == 255 ) then
		red = min((red + (5*turbo)), 255)
	elseif (red == 255 ) and ( green == 0 ) and ( blue > 0 ) then
		blue = max((blue - (5*turbo)), 0)
	end
	SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENEMY_COLOR, format("%02x%02x%02x", red, green, blue))
end

function r.setState(state, message)
	if state then
		if message then
			d("RGBAOE Enabled")
		end
		EM:RegisterForUpdate(r.name.."Cycle", r.savedVars.speed, r.cycle)
	else
		if message then
			d("RGBAOE Disabled")
		end
		EM:UnregisterForUpdate(r.name.."Cycle")
		SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENEMY_COLOR, r.savedVars.defaultColor)
	end
end

function r.slash()
	r.savedVars.enabled = not r.savedVars.enabled
	r.setState(r.savedVars.enabled, true)
end

function r.init(event, addon)
	if addon ~= r.name then return end
	EM:UnregisterForEvent(r.name.."Load", EVENT_ADD_ON_LOADED)
	r.savedVars = ZO_SavedVars:NewCharacterIdSettings("RGBAOESavedVariables", 2, "RGBAOE", r.defaults, GetWorldName())
	--r.savedVars = ZO_SavedVars:NewAccountWide("RGBAOESavedVariables", 2, "RGBAOE", r.defaults, GetWorldName()) -- maybe in the future
	SLASH_COMMANDS["/rgbaoe"] = r.slash
	r.setState(r.savedVars.enabled, false)
	r.buildMenu()
end

EM:RegisterForEvent(r.name.."Load", EVENT_ADD_ON_LOADED, r.init)
