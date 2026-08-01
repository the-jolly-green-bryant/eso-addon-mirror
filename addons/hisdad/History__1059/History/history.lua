hist = {
	name = "history",
	version = 94,
	initialised = false,
	SV={},
	L={},
	me = {},
	playerName = "",	-- might change
	playerID = "",  	-- Unique through renames
	tz_offset =0,
	debug = false
}
--GetWorldName()
local function log_truncate(max)
	--Limit log to max
	for _ = max, (#hist.SV.log-1)  do
		table.remove(hist.SV.log,1)
		if hist.debug then
		d("Truncated log.  Size now:  " .. tostring(#hist.SV.log))
		end
	end
end


local function log(text)

table.insert(hist.SV.log,{["TimeStamp"]=GetTimeStamp(),
	["text"] = text,
	["Char"] = hist.playerName,
	["CharID"] = hist.playerID,
	["world"] = GetWorldName(),
	})
end

local function log_me(text)	-- per char log

table.insert(hist.me.log,{["TimeStamp"]=GetTimeStamp(),
["text"] = text,
})
end

local Keep_Achievement = function (id) -- is this an achievement we want to save?
	if hist.IDs[id] then
		return true
	else
		return false
	end
end

local function get_start ()	-- get better start date from Achievements
	-- Check Achievements
	local earliest_time = 0
	local earliest_Achievement
	for id, ach in pairs(hist.me.ach) do
		if earliest_time == 0 then
		earliest_time = ach.time
		earliest_Achievement = id
		elseif earliest_time > ach.time then
		earliest_time = ach.time
		end
	end

	if earliest_time == 0 then	-- No Achievements
		earliest_time = GetTimeStamp()
	end

	if hist.me.Created == nil	then
		hist.me.Created = earliest_time
		if hist.debug then
				d("Start Time Reset for " .. hist.playerName)
		end
	end

end

local function Achievement(_, name, points, id, link)
	if Keep_Achievement(id)  then
		hist.me.ach[id] = {}
		hist.me.ach[id].name=name
		hist.me.ach[id].time = GetTimeStamp()
	--	hist.me.ach[id].link = link
		-- local numCriteria= GetAchievementNumCriteria(id)
		-- if numCriteria > 0  then
			-- hist.me.ach[id]["Criteria"]= {}
			-- for Criteria = 1, numCriteria do
				-- local c_Description, c_completed, c_required = GetAchievementCriterion(id, Criteria)
				-- hist.me.ach[id].Criteria[Criteria]={}
				-- hist.me.ach[id].Criteria[Criteria].Description=c_Description
				-- hist.me.ach[id].Criteria[Criteria].completed = c_completed
				-- hist.me.ach[id].Criteria[Criteria].required=c_required
			-- end
		-- end

		if hist.debug then
			d("Achievement Awarded:.. ")
			d(hist.me.ach[id])
		end
	end
end

local function  log_clear()
hist.SV.log = {}
log("Cleared")
end


function load_history()
-- load up  Achievements.
-- Note some achievements like "Level 40 Hero" have become obsolete. CategoryID is nil
	if hist.debug then
		log("Request to load  Dungeon Achievements")
	end
	--local name,points,description,completed,adate,atime
	local count = 0
	local reject = 0
	local flag = 0

	hist.me.ach = {}		-- Delete existing a load from scratch- Updates old formats


	for i,_ in pairs (hist.IDs) do

			local name,description,points,_,completed,adate,atime= GetAchievementInfo(i)
			if completed then
					if hist.me.ach[i] == nil then

						hist.me.ach[i] = {}
						hist.me.ach[i].name =name
						-- hist.me.ach[i].description=description
						hist.me.ach[i].time = (luatz_esodate(adate .. " " .. atime)+ hist.tz_offset)
					--	hist.me.ach[i].link = GetAchievementLink(i)
						-- local numCriteria= GetAchievementNumCriteria(i)
						-- if numCriteria > 1  then
							-- hist.me.ach[i].numCriteria = numCriteria
							-- hist.me.ach[i].Criteria={}
							-- for Criteria = 1, numCriteria do
								-- local c_Description, c_completed, c_required = GetAchievementCriterion(i, Criteria)
								-- hist.me.ach[i].Criteria[Criteria]= {}
								-- hist.me.ach[i].Criteria[Criteria].Description=c_Description
								-- hist.me.ach[i].Criteria[Criteria].completed = c_completed
								-- hist.me.ach[i].Criteria[Criteria].required=c_required
							-- end
						-- end
						count = count + 1
					end
			end --Keep
	end	--for
	if count > 0 then
		log("Added " .. tostring(count) .. " achievements.")
	end
end




local function gendertext()
	if (GetUnitGender("player") == GENDER_MALE)
		then return "M"
	end

	if (GetUnitGender("player") == GENDER_FEMALE)
		then return "F"
	end
	return "U"
end

local function setup_char()
	log("Set up: " .. hist.playerName )
	hist.SV.data[hist.playerID] = {}		-- initialise data for current char, using unique GUID
	hist.me = hist.SV.data[hist.playerID]
	hist.me.name=hist.playerName

	hist.me.Class = zo_strformat("<<C:1>>",GetUnitClass("player"))
	hist.me.Race = zo_strformat("<<C:1>>",GetUnitRace("player"))
	hist.me.Gender = gendertext()
	hist.me.level = GetUnitLevel("player")

	hist.me.world = GetWorldName()
	hist.me.Alliance = zo_strformat("<<C:1>>",GetAllianceName(GetUnitAlliance("player")))
	hist.me.ach={}
	hist.me.log={}

	hist.me["LoadTime"] = GetTimeStamp()
	load_history()
	get_start()
	log_me("Started")
end





function hist.Initialise(_, addOnName)
if (hist.name ~= addOnName) then return end

	-- find computed time difference.
	local now = GetTimeStamp()
	hist.datestr = GetDateStringFromTimestamp(now)
	hist.timestr = GetTimeString()
	hist.luatz_ts = luatz_esodate(hist.datestr .." " .. hist.timestr)
	hist.tz_offset = now - hist.luatz_ts



	hist.playerName = GetUnitName("player")
	hist.playerID = GetCurrentCharacterId()

	-- Load the saved variables
	hist.SV = ZO_SavedVars:NewAccountWide("History_SV", 1, nil, nil)


	if hist.SV.log == nil then
	hist.SV.log = {}
	log("hist.SV.log created")
	end

	if hist.debug then
		log("debug is on")
		log("now: " .. now)
		log("hist.datestr: " .. hist.datestr)
		log("hist.timestr: " .. hist.timestr)
		log("hist.luatz_ts: " .. hist.luatz_ts)
		log("hist.tz_offset: " ..hist.tz_offset)
	end

	-- if hist.SV.worlds == nil then
	-- hist.SV.worlds = {}
	-- end

	-- if hist.SV.worlds[GetWorldName()] == nil then
	-- hist.SV.worlds[GetWorldName()] = {}
	-- end

	-- hist.world = hist.SV.worlds[GetWorldName()]




	if (hist.SV.data == nil ) then
	hist.SV.data = {}
	log("hist.SV.data  created")
	end



	if (hist.SV.start_version  == nil ) then
	hist.SV.start_version = hist.version
	end




	--- hist.SV.version    -- Used by ZOS System, dont touch

	if hist.SV.data[hist.playerID] == nil then
		if hist.debug then
		log("No data found for PlayerID")
		end
	-- Ok playerID may be nil, but we might still have data under player name
	-- In which case we rename it, otherwise it is a new char.

		if hist.SV.data[hist.playerName] == nil then
		--No name, no ID, must be new.
			setup_char()
		end
	end

	hist.me = hist.SV.data[hist.playerID]


	hist.me.level = GetUnitLevel("player")

	hist.me.world = GetWorldName()



	if hist.me.log == nil then	-- special events we want to keep, like name changes
	hist.me.log = {}
	end

	if hist.me.IDVersion == nil then
		hist.me.IDVersion = ""
	end

	if hist.me.timeplayed == nil then
		hist.me.timeplayed = 0
	end

	if hist.debug then
		log_truncate(5000)
	else
		log_truncate(50)
	end

	hist.SV.lang=GetCVar("language.2")	-- For offline use

	if hist.me.logins == nil then
		hist.me.logins = 0
	end
	hist.me.logins = hist.me.logins +1		-- count them.

	hist.me["LoginTime"] = GetTimeStamp()

	if hist.me["ReloadTime"] == nil then
		hist.me["ReloadTime"] = GetTimeStamp()
	end

	if  hist.me["ReloadTime"] + 80080 <= GetTimeStamp() then	 --  23 hours or more have past
		load_history()		-- pickup anything that might be missed
		hist.me["ReloadTime"] = GetTimeStamp()
		if hist.debug then
			log ("Startup: Timed check on missed achievements.")
		end
	end


	if hist.me.IDVersion ~= hist.IDVersion then
		log ("ID file version was " .. hist.me.IDVersion .. ", now " .. hist.IDVersion .. "  loading")
		hist.me.IDVersion = hist.IDVersion
		load_history()
	end


	if hist.me.name ~= hist.playerName then
		log_me("Changed Name, Was " ..  hist.me.name)
		hist.me.name = hist.playerName
	end

	if 	hist.me.Race ~= zo_strformat("<<C:1>>",GetUnitRace("player")) then
		log_me("Changed Race, Was " .. hist.me.Race)
		hist.me.Race = zo_strformat("<<C:1>>",GetUnitRace("player"))
	end

	if 	hist.me.Gender ~= gendertext() then
		log_me("Changed Gender, Was " .. hist.me.Gender)
		hist.me.Gender = gendertext()
	end

	if (hist.SV.this_version == nil) then
		hist.SV.this_version = hist.version
	end

	if (type(hist.SV.this_version) == "string") then
		hist.SV.this_version = tonumber(hist.SV.this_version)
	end

-- erase maps and levels

	-- hist.me.levels = nil
	-- hist.me.maps = nil
	
	-- hist.world.CP = nil


	-- hist.me.craft = nil
	-- hist.SV.old = nil
	-- hist.SV.cleaned1 = nil

	hist.SV.worlds = nil  -- v94

	-- Old data from veteran days
	-- hist.me.veteran_level = nil

	hist.SV.this_version = hist.version


	EVENT_MANAGER:RegisterForEvent(hist.name, EVENT_ACHIEVEMENT_AWARDED, Achievement)
	hist.initialised = true

end



SLASH_COMMANDS["/histload"] = load_history
SLASH_COMMANDS["/histclear"] = log_clear
SLASH_COMMANDS["/histstart"] = get_start

EVENT_MANAGER:RegisterForEvent(hist.name, EVENT_ADD_ON_LOADED, hist.Initialise)
