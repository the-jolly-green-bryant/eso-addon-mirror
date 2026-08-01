CLOW= {
  name = "CarosLastOnlineWorkaround",
}

function CLOW:GetOfflineTime( displayName )
	local myOffTime = -1
	if CLOW.sv.guildList[displayName] ~= nil then 
		myOffTime = os.time() - CLOW.sv.guildList[displayName]
	end
	
	return myOffTime 
end

function CLOW.refreshGuilds()
	local myGuilds = {}
	for i, v in pairs(CLOW.sv.watchList) do
		if v then 
			table.insert(myGuilds, i) 
			CLOW.refreshGuild(i)
		end
	end
	CLOW.myGuildColumn:SetGuildFilter(myGuilds)
end

function CLOW.refreshGuild(guildId)
	local numGuildMembers = GetNumGuildMembers(guildId)
    local myDate = os.time()
	for guildMemberIndex = 1, numGuildMembers do
		local memberDisplayName, _, _, memberStatus = GetGuildMemberInfo(guildId, guildMemberIndex)
		if memberStatus ~= PLAYER_STATUS_OFFLINE then CLOW.sv.guildList[memberDisplayName] = myDate end
	end
end

function CLOW:Initialize()
	local svName= "CLOWSavedVariables"
	local svVersion = 1
	local svNamesSpace = nil
	local svDefaults = {
		guildList = {},
		watchList = {},
		importList = {},
	} 
	local svProfile = GetWorldName()
	CLOW.worldName = svProfile
	local svDisplayName = nil 
	
	CLOW.sv = ZO_SavedVars:NewAccountWide(svName, svVersion, svNamesSpace, svDefaults, svProfile, svDisplayName) -- savedvars account wide, server dependent
	
	CLOW.sv.guildList = CLOW.sv.guildList or {}
	if CLOW.sv.importList ~= nil then
		for i, v in pairs(CLOW.sv.importList) do
			if CLOW.sv.guildList[i] == nil or CLOW.sv.guildList[i] < v then
				CLOW.sv.guildList[i] = v			
			end
		end
	end
	CLOW.sv.importList = {}
	
	CLOW.myGuildColumn = LibGuildRoster:AddColumn({
		key = 'CLOW_Days',
		disabled = false,
		width = 42,
		beforeList = function() CLOW.refreshGuilds() end,
		header = {
			title = zo_strformat(GetString(SI_TIME_FORMAT_DAYS_DESC_COLOR), nil),
			align = TEXT_ALIGN_RIGHT
		},
		row = {

			align = TEXT_ALIGN_RIGHT,

			data = function( guildId, data, index )
				local myOffTime = CLOW:GetOfflineTime( data.displayName )
				if myOffTime >= 0 then
					return math.floor(myOffTime/3600/24)
				else 
					return 999
				end
			end,

			format = function( value )
				if value == nil or tonumber(value) == nil then return "-" end
				return zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(tonumber(value)))
			end,
			mouseEnabled = function() return true end,
			OnMouseEnter = function(guildId, data, control) CLOW.showTooltip(data.displayName, control) end,
			OnMouseExit = function() ZO_Tooltips_HideTextTooltip() end,
		}
		
	})
	
	EVENT_MANAGER:RegisterForUpdate(CLOW.name, 300000, CLOW.refreshGuilds)
	EVENT_MANAGER:UnregisterForEvent(CLOW.name, EVENT_ADD_ON_LOADED)
end

function CLOW.showTooltip(displayName, control)

	local myOffTime = CLOW:GetOfflineTime(displayName)
	local days = math.floor(myOffTime/3600/24)
	local remaining = myOffTime - days * 3600 * 24
	local hours = math.floor(remaining/3600)
	local minutes = math.floor((remaining - (hours * 3600))/60)
	days = zo_strformat(GetString(SI_TIME_FORMAT_DAYS_DESC_COLOR), days)
	local myToolTip = string.format("%s\n%s\n%02s:%02s", displayName, days, hours, minutes)
	if CLOW.sv.guildList[displayName] == nil then myToolTip = string.format("%s\nNo data", displayName) end
	ZO_Tooltips_ShowTextTooltip(control, RIGHT, myToolTip)
end


function CLOW.OnAddOnLoaded(event, addonName)
	if addonName == CLOW.name then
		EVENT_MANAGER:UnregisterForEvent(CLOW.name, EVENT_ADD_ON_LOADED)
		CLOW:Initialize()
	end
end

function CLOW.guildAdd(arg)
	if arg == nil then d('Choose a guild to watch (number 1-5)') return end
	local guildId = GetGuildId(tonumber(arg))
	local guildName = GetGuildName(guildId)
	if CLOW.sv.watchList[guildId] == nil or CLOW.sv.watchList[guildId] == false then 
		d(string.format("Started recording for '%s'", guildName))
		CLOW.sv.watchList[guildId] = true
	else
		CLOW.sv.watchList[guildId] = false 
		d(string.format("Stopped recording for '%s'", guildName)) 
		return 
	end
	CLOW.refreshGuild(guildId)
end


 SLASH_COMMANDS["/caroguild"] = CLOW.guildAdd
 
 EVENT_MANAGER:RegisterForEvent(CLOW.name, EVENT_ADD_ON_LOADED, CLOW.OnAddOnLoaded)