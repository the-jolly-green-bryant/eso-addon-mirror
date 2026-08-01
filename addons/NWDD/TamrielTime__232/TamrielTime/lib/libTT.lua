--[[
Copyright (c) 2014 [NWDD]Gindar

Baseline Common Sense License(BCSL):
You may do whatever you want with this work as long as the above
copyright notice and this notice is included in the derived work.
--]]
if tt and tt.v and tt.v > 0.99 then return end
tt = { v = 0.99 }

local xday = 20976
local xyear = 365*xday
local xhour = xday/24
local xmin = xhour/60
local xsec = xmin/60

tt.xday, tt.xhour, tt.xmin, tt.xsec, tt.xyear = xday, xhour, xmin, xsec, xyear

tt.month = {"Morning Star","Sun's Dawn","First Seed","Rain's Hand","Second Seed","Midyear","Sun's Height","Last Seed","Hearthfire","Frostfall","Sun's Dusk","Evening Star"}
tt.week = {"Sundas","Morndas","Tirdas","Middas","Turdas","Fredas","Loredas"}

function tt.ordinal(number)
	if type(number) == "string" then
		number = tonumber(number)
	end
	if number then
		local last = number%10
		if last == 1 then
			return "st"
		elseif last == 2 then
			return "nd"
		elseif last == 3 then
			return "rd"
		else
			return "th"
		end
	end
end

function tt.dayofmonth(dayofyear)
	if dayofyear<30 then
		return dayofyear+1,1
	elseif dayofyear<58 then
		return dayofyear-29,2
	elseif dayofyear<89 then
		return dayofyear-57,3
	elseif dayofyear<119 then
		return dayofyear-88,4
	elseif dayofyear<150 then
		return dayofyear-118,5
	elseif dayofyear<180 then
		return dayofyear-149,6
	elseif dayofyear<211 then
		return dayofyear-179,7
	elseif dayofyear<242 then
		return dayofyear-210,8
	elseif dayofyear<272 then
		return dayofyear-241,9
	elseif dayofyear<303 then
		return dayofyear-271,10
	elseif dayofyear<333 then
		return dayofyear-302,11
	else
		return dayofyear-333,12
	end
end

function tt.newAlarm(alarmdb, alarm, callback)
	local rtimes, hour, min = alarm:match("(%??)(%d*):(%d*)")
	if min or hour then
		hour = (hour~="") and string.format("%02d",tonumber(hour)) or ""
		min = (min~="") and string.format("%02d",tonumber(min)) or ""
		alarmdb[hour..":"..min] = {times=#rtimes,shortstamp=0,cb=callback}
		alarmdb.nalarms = alarmdb.nalarms + 1
	end
end

function tt.CheckAlarms(alarmdb, DateStruct)
	local key = {DateStruct.h..":"..DateStruct.m, DateStruct.h..":", ":"..DateStruct.m }
	for i=1,#key do
		if alarmdb[key[i]] then
			local alarm = alarmdb[key[i]]
			if alarm.shortstamp < DateStruct.timestamp then
				alarm.cb(DateStruct)
				if alarm.times == 0 then
					alarmdb[key[i]] = nil
					alarmdb.nalarms = alarmdb.nalarms - 1
				else
					alarm.shortstamp = DateStruct.timestamp + xhour
				end
			end
		end
	end
	return DateStruct
end

function tt.Date(unixstamp)
	local ttime = unixstamp-1396083600
	local tesotime = ttime%xday
	local day, month = tt.dayofmonth(math.floor((ttime%xyear)/xday))
	local hour = tesotime/xhour
	return {
		timestamp = ttime,
		P = hour/24,
		W = tt.week[((math.floor(ttime/xday))%7)+1],
		D = tostring(day),
		ord = tt.ordinal(day),
		M = tt.month[month],
		dM = month,
		Y = tostring(math.floor(ttime/xyear)+582),
		h12 = string.format("%2d",((hour-1)%12)+1),
		f12 = ((hour<12) and "AM" or "PM"),
		h = string.format("%02d",math.floor(hour)),
		m = string.format("%02d",math.floor(tesotime/xmin)%60),
		s = string.format("%02d",(tesotime/xsec)%60),
		um = string.format(xday-tesotime)
	}
end
