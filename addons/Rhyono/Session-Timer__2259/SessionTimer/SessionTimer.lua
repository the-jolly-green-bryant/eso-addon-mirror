local SessionTimer = {
Name = "Session Timer",
Author = "Rhyono",
Version = 1.11,
Start = GetTimeStamp(),
}

local minute = 60
local hour = minute*60
local day = hour*24

local function pluralTime(num)
	return num == 1 and '' or 's'
end

function SessionTimer.Played()
	local seconds = GetTimeStamp()-SessionTimer.Start
	local days = math.floor(seconds/day)
	seconds = seconds-(days*day)
	local hours = math.floor(seconds/hour)
	seconds = seconds-(hours*hour)
	local minutes = math.floor(seconds/minute)
	seconds = seconds-(minutes*minute)

	local out = ""
	if days > 0 then
		out = string.format("%u day%s, %u hour%s, %u minute%s and %u second%s",days,pluralTime(days),hours,pluralTime(hours),minutes,pluralTime(minutes),seconds,pluralTime(seconds))
	elseif hours > 0 then
		out = string.format("%u hour%s, %u minute%s and %u second%s",hours,pluralTime(hours),minutes,pluralTime(minutes),seconds,pluralTime(seconds))
	elseif minutes > 0 then
		out = string.format("%u minute%s and %u second%s",minutes,pluralTime(minutes),seconds,pluralTime(seconds))
	else
		out = string.format("%u second%s",seconds,pluralTime(seconds))
	end	
	CHAT_SYSTEM:AddMessage("You have played "..GetUnitName("player").. " for " .. out .. " this session.")
end

SLASH_COMMANDS["/session"] = SessionTimer.Played
