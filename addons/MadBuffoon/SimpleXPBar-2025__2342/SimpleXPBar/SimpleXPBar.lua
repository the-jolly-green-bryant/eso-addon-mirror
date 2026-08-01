SimpleXPBar = {
	name = "SimpleXPBar",
	author = "Madbuffoon",
	version = "2.2",
	debug_mode = false,

	last_mob_xp = nil,
	previousExp = 0,
}
function format_int(number)

  local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')

  -- reverse the int-string and append a comma to all blocks of 3 digits
  int = int:reverse():gsub("(%d%d%d)", "%1,")

  -- reverse the int-string back remove an optional comma and put the 
  -- optional minus and fractional part back
  return minus .. int:reverse():gsub("^,", "") .. fraction
end
function SimpleXPBar.EVENT_ADD_ON_LOADED(event, addonName)
	if addonName ~= SimpleXPBar.name then return end
	-- add to scenes
	SimpleXPBar.SIMPLEXPBAR_FRAGMENT = ZO_SimpleSceneFragment:New(SimpleXPBarWindow, true, 150)
	SCENE_MANAGER:GetScene("hud"):AddFragment(SimpleXPBar.SIMPLEXPBAR_FRAGMENT)
	SCENE_MANAGER:GetScene("hudui"):AddFragment(SimpleXPBar.SIMPLEXPBAR_FRAGMENT)
	SCENE_MANAGER:GetScene("skills"):AddFragment(SimpleXPBar.SIMPLEXPBAR_FRAGMENT)
	SCENE_MANAGER:GetScene("stats"):AddFragment(SimpleXPBar.SIMPLEXPBAR_FRAGMENT)

	-- slash commands
	SLASH_COMMANDS["/xpbar"] = function(arg)
		if arg == "debug" then
			SimpleXPBar.debug_mode = not SimpleXPBar.debug_mode
			d("SimpleXPBar DEBUG_MODE= " .. tostring(SimpleXPBar.debug_mode))
		else
			d("SimpleXPBar v" .. SimpleXPBar.version)
			if GetString(SXPB_TRANS_AUTHOR) ~= "" then
				d(GetString(SXPB_TRANS_BY) .. " " .. GetString(SXPB_TRANS_AUTHOR))
			end
		end
	end

	local function SetupEvents()
		EVENT_MANAGER:RegisterForEvent(SimpleXPBar.name, EVENT_PLAYER_COMBAT_STATE, SimpleXPBar.EVENT_PLAYER_COMBAT_STATE)
		EVENT_MANAGER:RegisterForEvent(SimpleXPBar.name, EVENT_EXPERIENCE_GAIN, SimpleXPBar.EVENT_EXPERIENCE_GAIN)
		EVENT_MANAGER:RegisterForEvent(SimpleXPBar.name, EVENT_VETERAN_POINTS_GAIN, SimpleXPBar.EVENT_EXPERIENCE_GAIN)
		for i,v in ipairs{
			EVENT_VETERAN_RANK_UPDATE, EVENT_VETERAN_POINTS_UPDATE,
			EVENT_CHAMPION_POINT_GAINED, EVENT_LEVEL_UPDATE,
			EVENT_DISCOVERY_EXPERIENCE, EVENT_STATS_UPDATED
		} do
			EVENT_MANAGER:RegisterForEvent(SimpleXPBar.name, v, SimpleXPBar.EVENT_GENERIC_UPDATE)
		end
	end

	EVENT_MANAGER:RegisterForEvent("SimpleXPBar.EVENT_PLAYER_ACTIVATED", EVENT_PLAYER_ACTIVATED, function()
			SimpleXPBar:LoadSettings()
			SimpleXPBar:UpdateData()
			SetupEvents()
			Terril_lib.IsAddonOutOfDate(SimpleXPBar, true)
			--d(SimpleXPBar.name .. " v" .. SimpleXPBar.version .. " Loaded.")
			EVENT_MANAGER:UnregisterForEvent("SimpleXPBar.EVENT_PLAYER_ACTIVATED", EVENT_PLAYER_ACTIVATED)
		end)

	EVENT_MANAGER:UnregisterForEvent(SimpleXPBar.name, EVENT_ADD_ON_LOADED)
end
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------


function SimpleXPBar.GetPlayerStat(stat)
	local level=GetUnitLevel('player')

	if level>=50 then
		if stat == "xp" then
			return GetPlayerChampionXP()
		elseif stat == "xpmax" then
				level=GetPlayerChampionPointsEarned()
			return GetNumChampionXPInChampionPoint(level)
		elseif stat == "level" then
			return GetPlayerChampionPointsEarned()
		elseif stat == "xpen" then
			return GetEnlightenedPool()
		elseif stat == 'lvlstr' then
			return GetString(SXPB_TAG_LVLSTR_CHAMP)
		elseif stat == 'xpstr' then
			return GetString(SXPB_TAG_XPSTR_CHAMP)
		elseif stat == 'lvlcpstr' then
			return GetString(SXPB_TAG_LVLCPSTR_CHAMP)
		end
	else
		if stat == "xp" then
			return GetUnitXP("player")
		elseif stat == "xpmax" then
			return GetUnitXPMax("player")
		elseif stat == "level" then
			return GetUnitLevel("player")
		elseif stat == 'lvlstr' then
			return GetString(SXPB_TAG_LVLSTR_NORM)
		elseif stat == 'xpstr' then
			return GetString(SXPB_TAG_XPSTR_NORM)
		elseif stat == "xpen" then
			return GetEnlightenedPool()
		elseif stat == 'lvlcpstr' then
			return GetString(SXPB_TAG_LVLCPSTR_NORM)
		end
	end
end

if DEVMODE then
	local gpv_old = SimpleXPBar.GetPlayerStat
	SimpleXPBar.GetPlayerStat = function(stat)
		assert(type(stat) == 'string', 'SimpleXPBar.GetPlayerStat(stat) -> stat isnt string')
		assert(#stat > 0, 'SimpleXPBar.GetPlayerStat(stat) -> stat is empty')
		local returner = gpv_old(stat)
		assert(type(returner) == 'string' or type(returner) == 'number', 'SimpleXPBar.GetPlayerStat -> returned invalid value')
		return returner
	end
end

function SimpleXPBar:UpdateData()
	local tag_values = {
		[GetString(SXPB_TAG_XPSTR_TAG)]		= self.GetPlayerStat('xpstr'),
		[GetString(SXPB_TAG_LVLCPSTR_TAG)]		= self.GetPlayerStat('lvlcpstr'),
		[GetString(SXPB_TAG_XP_TAG)]		= format_int(self.GetPlayerStat("xp")),		
		[GetString(SXPB_TAG_XPEN_TAG)]		= format_int(self.GetPlayerStat("xpen")),
		[GetString(SXPB_TAG_XPMAX_TAG)]		= format_int(self.GetPlayerStat("xpmax")),
		[GetString(SXPB_TAG_LVLSTR_TAG)]	= self.GetPlayerStat('lvlstr'),
		[GetString(SXPB_TAG_LVL_TAG)]		= self.GetPlayerStat("level"),
		[GetString(SXPB_TAG_NEXTLVL_TAG)]	= self.GetPlayerStat("level") + 1,

		[GetString(SXPB_TAG_MOBS_TAG)]		= SimpleXPBar.CharSV.last_mob_xp and math.ceil((self.GetPlayerStat('xpmax') - self.GetPlayerStat('xp')) / SimpleXPBar.CharSV.last_mob_xp) or GetString(SXPB_TAG_UNKNOWN),
		[GetString(SXPB_TAG_PERC_TAG)]		= math.floor((self.GetPlayerStat('xp') / self.GetPlayerStat('xpmax')) * 100),
		[GetString(SXPB_TAG_XPNEED_TAG)]	= format_int(math.floor((self.GetPlayerStat('xpmax') - self.GetPlayerStat('xp')))),
	}

	if not SimpleXPBarWindow:IsHidden() then
		SimpleXPBarWindowLabel:SetText(string.gsub(SimpleXPBar.CurSV.textbar.text, "<%w+>", tag_values))
		SimpleXPBarWindowAltLabel:SetText(tag_values[GetString(SXPB_TAG_LVL_TAG)])
		SimpleXPBarWindowStatusBar:SetValue(tag_values[GetString(SXPB_TAG_PERC_TAG)])
	end
end
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
--Events
function SimpleXPBar.EVENT_PLAYER_COMBAT_STATE(eventCode, inCombat)
	if SimpleXPBar.debug_mode then d("EVENT_PLAYER_COMBAT_STATE( " .. eventCode .. ", " .. tostring(inCombat) .. ")") end
	if inCombat and not SimpleXPBar.isInCombat then
		SimpleXPBar.previousExp = SimpleXPBar.GetPlayerStat("xp")
	end
	SimpleXPBar.isInCombat = inCombat
end

function SimpleXPBar.EVENT_EXPERIENCE_GAIN(eventCode, reason, level, previousExperience, currentExperience)
	if SimpleXPBar.debug_mode then d("EVENT_EXPERIENCE_GAIN( " .. eventCode .. ", " .. reason .. ", " .. level .. ", " .. previousExperience .. ", " .. currentExperience .. ")") end
	if reason == 0 or reason == 24 then
		SimpleXPBar.CharSV.last_mob_xp = (SimpleXPBar.GetPlayerStat("xp") - SimpleXPBar.previousExp)
		SimpleXPBar.previousExp = SimpleXPBar.GetPlayerStat("xp") --just incase we dont leave combat before next event
	end
	SimpleXPBar:UpdateData()
end

function SimpleXPBar.EVENT_GENERIC_UPDATE()
	SimpleXPBar:UpdateData()
end
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(SimpleXPBar.name, EVENT_ADD_ON_LOADED, SimpleXPBar.EVENT_ADD_ON_LOADED)