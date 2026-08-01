AllAP = AllAP or {}
AllAP.name = "AllAP"
AllAP.version = "1.3.3"
AllAP.savedVars = {}
AllAP.default = {
	["chars"] = {}
}

local alliances = { 
	{ 
		"/esoui/art/ava/ava_hud_emblem_aldmeri.dds",
		"/esoui/art/ava/ava_hud_emblem_ebonheart.dds",
		"/esoui/art/ava/ava_hud_emblem_daggerfall.dds" 
	}, {
		"e9e984",
		"d83030",
		"184a8d"
	}
}

local function comma_value(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

local function round(num, numDecimalPlaces)
  return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

function AllAP.OnLoaded(_, addonName)
    if addonName ~= AllAP.name then return end
	AllAP.savedVars = ZO_SavedVars:NewAccountWide("AllAPVars", 5, nil, AllAP.default)
    AllAP:Init()
end

function AllAP:Init()
    AllAP.SaveAP()
	
    SLASH_COMMANDS["/ap"] = function (args)
		
		AllAP.SaveAP()
		
		if args == "all" then
			AllAP.DisplayAllAP(false)
		elseif args == "all+" then
			AllAP.DisplayAllAP(true)
		elseif args == "class" then
			AllAP.DisplayClassAP(false)
		elseif args == "class+" then
			AllAP.DisplayClassAP(true)
		elseif args == "alliance" then
			AllAP.DisplayAllianceAP(false)
		elseif args == "alliance+" then
			AllAP.DisplayAllianceAP(true)
		elseif args == "" then
			AllAP.DisplayAP()
		else
			AllAP.DisplayHelp()
		end
    end
	
	SLASH_COMMANDS["/rl"] = function(a) ReloadUI() end

    EVENT_MANAGER:UnregisterForEvent(AllAP.name, EVENT_ADD_ON_LOADED)
end

function AllAP.SaveAP()
	local cls = GetUnitClassId("player")
	if cls == 4 then
		cls = 5
	elseif cls == 5 then
		cls = 6
	elseif cls == 6 then
		cls = 4
	end
    AllAP.savedVars.chars[GetCurrentCharacterId()] = { ap = GetUnitAvARankPoints("player"), rank = GetUnitAvARank("player"), class = cls, name = GetUnitName("player"), alliance = GetUnitAlliance("player") }
end

function AllAP.DisplayHelp()
	CHAT_ROUTER:AddSystemMessage("|t24:24:/esoui/art/mainmenu/menubar_journal_down.dds|t |c4abdcfAPALL HELP |t24:24:/esoui/art/mainmenu/menubar_journal_down.dds|t")
	CHAT_ROUTER:AddSystemMessage("|c333333--------")
	CHAT_ROUTER:AddSystemMessage("Available Commands:")
	CHAT_ROUTER:AddSystemMessage("  |c44cc66/ap |r- Displays AP earned overall, per hour, and needed for next rank for the current character")
	CHAT_ROUTER:AddSystemMessage("  |c44cc66/ap all |r- Displays total AP earned by all characters")
	CHAT_ROUTER:AddSystemMessage("  |c44cc66/ap all+ |r- Displays total AP earned by all characters, and lists each character's AP")
	CHAT_ROUTER:AddSystemMessage("  |c44cc66/ap class |r- Displays total AP earned by class")
	CHAT_ROUTER:AddSystemMessage("  |c44cc66/ap class+ |r- Displays total AP earned by class, and lists each character's AP under its class")
	CHAT_ROUTER:AddSystemMessage("  |c44cc66/ap alliance |r- Displays total AP earned by alliance")
	CHAT_ROUTER:AddSystemMessage("  |c44cc66/ap alliance+ |r- Displays total AP earned by alliance, and lists each character's AP under its alliance")
	CHAT_ROUTER:AddSystemMessage("|c333333--------")
	CHAT_ROUTER:AddSystemMessage("AP is not counted past reaching Grand Overlord Grade 2")
end

function AllAP.DisplayAP()
	
	local _char = AllAP.savedVars.chars[GetCurrentCharacterId()]
	local _, progress = GetAvARankProgress(_char.ap)
	local rankup = progress - _char.ap
	local aph = 3600 * _char.ap / GetSecondsPlayed()

	CHAT_ROUTER:AddSystemMessage(table.concat({"You have earned", AllAP.FormatAPText(_char.ap), "on", AllAP.FormatRankIcon(_char.rank), _char.name, "." }))
	if _char.rank < 50 then
		CHAT_ROUTER:AddSystemMessage(table.concat({"You need", AllAP.FormatAPText(rankup), "to reach", AllAP.FormatRankText(_char.rank + 1), "." }))
	else
		CHAT_ROUTER:AddSystemMessage(table.concat({"You cannot rank up beyond", AllAP.FormatRankText(50), "." }))
	end
	CHAT_ROUTER:AddSystemMessage(table.concat({"You have gained", AllAP.FormatAPText(aph), "per hour of playtime on", AllAP.FormatRankIcon(_char.rank), _char.name, "."}))
	
end

function AllAP.DisplayClassAP(ext)
	
	local totalAP = {}
	local chars = {}
	
	for i = 1, GetNumClasses() do
		totalAP[i] = 0
		chars[i] = {}
	end
	
	for k, v in pairs(AllAP.savedVars.chars) do
		totalAP[v.class] = totalAP[v.class] + v.ap
		chars[v.class][k] = v
	end
	
	for i = 1, #chars do
		CHAT_ROUTER:AddSystemMessage(table.concat({"You have earned", AllAP.FormatAPText(totalAP[i]), "on", AllAP.FormatClassText(i)}))
		if ext then
			for k, v in pairs(chars[i]) do
				CHAT_ROUTER:AddSystemMessage(table.concat({AllAP.FormatRankIcon(v.rank), v.name, " has earned ", AllAP.FormatAPText(v.ap)}))
			end
		end
	end
	
end

function AllAP.DisplayAllianceAP(ext)
	
	local totalAP = {}
	local chars = {}
	
	for i = 1, 3 do
		totalAP[i] = 0
		chars[i] = {}
	end
	
	for k, v in pairs(AllAP.savedVars.chars) do
		totalAP[v.alliance] = totalAP[v.alliance] + v.ap
		chars[v.alliance][k] = v
	end
	
	for i = 1, #chars do
		CCHAT_ROUTER:AddSystemMessage(table.concat({"You have earned", AllAP.FormatAPText(totalAP[i]), "on", AllAP.FormatAllianceText(i)}))
		if ext then
			for k,v in pairs(chars[i]) do
				CHAT_ROUTER:AddSystemMessage(table.concat({AllAP.FormatRankIcon(v.rank), v.name, " has earned ", AllAP.FormatAPText(v.ap)}))
			end
		end
	end
	
end

function AllAP.DisplayAllAP(ext)
	
	local totalAP = 0
	local chars = AllAP.savedVars.chars
	
	for k, v in pairs(AllAP.savedVars.chars) do
		totalAP = totalAP + v.ap
	end
	
    CHAT_ROUTER:AddSystemMessage(table.concat({"You have earned", AllAP.FormatAPText(totalAP), "in total"}))
	if ext then
		for k, v in pairs(chars) do
			CHAT_ROUTER:AddSystemMessage(table.concat({AllAP.FormatRankIcon(v.rank),v.name, " has earned", AllAP.FormatAPText(v.ap)}))
		end
	end
	
end


function AllAP.FormatAPText(ap)
	return table.concat({" |c44cc66",comma_value(round(ap,1)),"|r|t16:16:",GetCurrencyKeyboardIcon(2),"|t "})
end

function AllAP.FormatRankIcon(rank)
	return table.concat({"|t20:20:",GetAvARankIcon(rank),"|t"})
end

function AllAP.FormatRankText(rank)
	return table.concat({"|t20:20:",GetAvARankIcon(rank),"|t|c4abdcf",GetAvARankName(0,rank),"|r"})
end

function AllAP.FormatClassText(class)
	local x,_,_,_,_,_,i = GetClassInfo(class)
	return table.concat({"|t20:20:",i,"|t|ced2f2f",GetClassName(0,x),"|r"})
end

function AllAP.FormatAllianceText(all)
	return table.concat({"|t26:26:",alliances[1][all],"|t|c",alliances[2][all],GetAllianceName(all),"|r"})
end

EVENT_MANAGER:RegisterForEvent(AllAP.name, EVENT_ADD_ON_LOADED, AllAP.OnLoaded)
EVENT_MANAGER:RegisterForEvent(AllAP.name, EVENT_LOGOUT_DEFERRED, AllAP.SaveAP)
EVENT_MANAGER:RegisterForEvent(AllAP.name, EVENT_ALLIANCE_POINT_UPDATE, AllAP.SaveAP)