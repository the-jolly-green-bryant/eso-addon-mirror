-- partly based on PlayedAll by DerBombo
HowLong = {
	name = "HowLong",
	author = "Muenchhausen",
	versionString = "1.0.5",
	website	= "https://www.esoui.com/downloads/info2600-HowLong.html",
	settings = {},
}

local HLsavedVariables
local HLcharName = GetUnitName("player")
local HLcharTime
local HLcharCount = 0
local HLtotalPlayed = 0
local HLforms = {GetString(SI_HOWLONG_FORMNONE), GetString(SI_HOWLONG_FORMSHORT), GetString(SI_HOWLONG_FORMLONG),}
local HLformsLookup = {[GetString(SI_HOWLONG_FORMNONE)] = 0, [GetString(SI_HOWLONG_FORMSHORT)] = 1, [GetString(SI_HOWLONG_FORMLONG)] = 2,}

local c = {
	white = "EEEEEE",
	grey = "777777",
	gold = "B39C7A",
}

function c.Color(text, color)
    if not color then color = c.grey end
    text = string.format('|c%s%s|r', color, text)
    return text
end

function HowLong.getsavedVariables()
    local username = GetDisplayName()
    local HowLongVars = _G['HowLongVars']
    if not HowLongVars then
        HowLongVars = {}
        _G['HowLongVars'] = HowLongVars
    end
    local savedVariables = HowLongVars[username]
    if not savedVariables then
        savedVariables = {}
        HowLongVars[username] = savedVariables
    end
    return savedVariables
end

function HowLong.updatePlayedTime()
    HLsavedVariables[HLcharName] = GetSecondsPlayed()
	HLcharCount = 0
	HLtotalPlayed = 0
	HLcharTime = GetSecondsPlayed()
	
    for name, time in pairs(HLsavedVariables) do
        HLcharCount = HLcharCount + 1
        HLtotalPlayed = HLtotalPlayed + time
    end
end

function HowLong.parseText(form)
	local parse = ""
	if (form == 1) then
		parse = parse .. c.Color(math.floor(HLcharTime / 3600),c.white) .. c.Color("/" .. math.floor(HLtotalPlayed / 3600) .. GetString(SI_HOWLONG_HOURSSHORT) .. " (") 
		parse = parse .. c.Color(math.floor(HLcharTime / HLtotalPlayed * 100) .. "%", c.white) .. c.Color(GetString(SI_HOWLONG_WITH))
		parse = parse .. c.Color("1",c.white) .. c.Color("/" .. HLcharCount ..")")
	elseif (form == 2) then
		parse = parse .. c.Color(HLcharName, c.white) 
		parse = parse .. c.Color(GetString(SI_HOWLONG_PLAYED1))
		parse = parse .. c.Color(math.floor(HLcharTime / 3600) .. GetString(SI_HOWLONG_HOURSLONG),c.white) 
		parse = parse .. c.Color(GetString(SI_HOWLONG_PLAYED2))
		parse = parse .. c.Color(" (")
		parse = parse .. c.Color(math.floor(HLcharTime / HLtotalPlayed * 100) .. "%", c.white) .. c.Color(GetString(SI_HOWLONG_OF))
		parse = parse .. c.Color(math.floor(HLtotalPlayed / 3600) .. GetString(SI_HOWLONG_HOURSLONG) .. GetString(SI_HOWLONG_TOTAL),c.gold)
		parse = parse .. c.Color(GetString(SI_HOWLONG_WITH) .. HLcharCount .. GetString(SI_HOWLONG_CHARS))
		parse = parse .. c.Color(")")
	end
	return parse
end

function HowLong.displayHowLong()
    HowLong.updatePlayedTime()
	d(HowLong.parseText(HowLong.settings.OptDisplayOnInvoke))

end

function spairs(t, order)
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function HowLong.buildMenu()
	local parsel = ""
	local parser = ""
	
	HowLong.updatePlayedTime()
	for name, time in spairs(HLsavedVariables, function(t,a,b) return t[b] < t[a] end) do
		parsel = parsel .. "\n" .. name .. ":"
		tab = ""
		for space = 1, (6 - string.len(math.floor(time / 3600))) do tab = tab .. "  " end
		parser = parser .. "\n" .. tab .. c.Color(math.floor(time / 3600), c.gold) .. GetString(SI_HOWLONG_HOURSLONG) .. c.Color(" (" .. math.floor(time / HLtotalPlayed * 100) .. "%)", c.grey)
	end
	local LAM = LibAddonMenu2
	local panelData = {
		type 				= 'panel',
		name 				= HowLong.name,
		displayName 		= HowLong.name,
		author 				= HowLong.author,
		version 			= HowLong.versionString,
		registerForRefresh 	= true,
		registerForDefaults = true,
		--slashCommand 		= "/HowLong",
		website             = HowLong.website,
	}
	HowLong.LAMPanel = LAM:RegisterAddonPanel(HowLong.name .. "_LAM", panelData)

	local optionsTable =
	{	
		{	type 	= "dropdown",
			name 	= GetString(SI_HOWLONG_MESSAGELOGIN),
			choices = HLforms,
			getFunc = function() return HLforms[HowLong.settings.OptDisplayOnStartup + 1] end,
			setFunc = function(value) HowLong.settings.OptDisplayOnStartup = HLformsLookup[value] end,
			default = HLforms[HowLong.settings.OptDisplayOnStartup + 1],
		},	
		{	type 	= "dropdown",
			name 	= GetString(SI_HOWLONG_MESSAGEINVOKE),
			choices = {HLforms[2], HLforms[3],},
			getFunc = function() return HLforms[HowLong.settings.OptDisplayOnInvoke + 1] end,
			setFunc = function(value) HowLong.settings.OptDisplayOnInvoke = HLformsLookup[value] end,
			default = HLforms[HowLong.settings.OptDisplayOnInvoke + 1],
		},
		{	type = "description",
			title = c.Color(GetString(SI_HOWLONG_INFO1), c.grey),
			width = "full",	
		},
		{	type = "description",
			text = c.Color(GetString(SI_HOWLONG_INFO2), c.grey),
			width = "full",	
		},
		{	type = "header",
            name = GetString(SI_HOWLONG_PREVIEW),
        },
		{	type = "description",
			title = GetString(SI_HOWLONG_FORMSHORT) .. ":",
			text = HowLong.parseText(1),
			width = "full",	
		},
		{	type = "description",
			title = GetString(SI_HOWLONG_FORMLONG) .. ":",
			text = HowLong.parseText(2),
			width = "full",	
		},
		{	type = "submenu",
			name = GetString(SI_HOWLONG_LIST),
			controls = {
				{	type = "description",
					text = parsel,
					width = "half",	
				},
				{	type = "description",
					text = parser,
					width = "half",	
				},

			},
		},
	} 
	LAM:RegisterOptionControls(HowLong.name .. "_LAM", optionsTable)
end

function HowLong.onAddOnLoaded(event, addonName)
    if addonName ~= HowLong.name then return end
    EVENT_MANAGER:UnregisterForEvent(HowLong.name, EVENT_ADD_ON_LOADED)

	local HowLongVars = _G['HowLongVars']
    if not HowLongVars then
        HowLongVars = {}
        _G['HowLongVars'] = HowLongVars
    end
    HowLong.settings = HowLongVars["settings"]
    if not HowLong.settings then
        HowLong.settings = {
			OptDisplayOnStartup = 0,
			OptDisplayOnInvoke = 2,
		}
        HowLongVars["settings"] = HowLong.settings
    end
	HLsavedVariables = HowLong.getsavedVariables()
    HowLong.updatePlayedTime()
	HowLong.buildMenu()
	
	SLASH_COMMANDS["/howlong"] = HowLong.displayHowLong
    ZO_PreHook("ReloadUI", HowLong.updatePlayedTime)
    ZO_PreHook("Logout", HowLong.updatePlayedTime)
    ZO_PreHook("SetCVar", HowLong.updatePlayedTime)
    ZO_PreHook("Quit", HowLong.updatePlayedTime)

	if (HowLong.settings.OptDisplayOnStartup > 0) then
		zo_callLater(function() d(HowLong.parseText(HowLong.settings.OptDisplayOnStartup)) end, 3000)
	end
end

EVENT_MANAGER:RegisterForEvent(HowLong.name, EVENT_ADD_ON_LOADED, HowLong.onAddOnLoaded)