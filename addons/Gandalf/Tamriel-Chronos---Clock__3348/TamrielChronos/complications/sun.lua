-----------------------------------------------------------------------------
-- 					      									               --
-- 	Title:		 Tamriel Chronos                    					   --
--	Description: Tamriel Time and astronomical data                        --
--	Author: 	 Gandalf (@Gandalf2675)									   --
--               Based on https://esoclock.uesp.net/                       --
-- 					      									               --
-----------------------------------------------------------------------------

TaChronos.sun = TaChronos.sun or {}
local sun     = TaChronos.sun

-- Conversion constants
local TAMRIEL_YEAROFFSET          = TaChronos.const.TAMRIEL_YEAROFFSET  
local TAMRIEL_WEEKDAY_OFFSET      = TaChronos.const.TAMRIEL_WEEKDAY_OFFSET
local SECONDS_SINCE_START         = TaChronos.const.SECONDS_SINCE_START  
local SECONDS_PER_TAMRIEL_DAY     = TaChronos.const.SECONDS_PER_TAMRIEL_DAY
local SECONDS_PER_TAMRIEL_HOUR    = SECONDS_PER_TAMRIEL_DAY / 24
local SECONDS_PER_TAMRIEL_MINUTE  = SECONDS_PER_TAMRIEL_HOUR / 60
local SECONDS_PER_TAMRIEL_SECONDS = SECONDS_PER_TAMRIEL_MINUTE / 60

sun.earthMonths = {
	[ 1] = { name = GetString(SI_TACHRONOS_Jan), len = 31 },
	[ 2] = { name = GetString(SI_TACHRONOS_Feb), len = 28 },
	[ 3] = { name = GetString(SI_TACHRONOS_Mar), len = 31 },
	[ 4] = { name = GetString(SI_TACHRONOS_Apr), len = 30 },
	[ 5] = { name = GetString(SI_TACHRONOS_May), len = 31 },
	[ 6] = { name = GetString(SI_TACHRONOS_Jun), len = 30 },
	[ 7] = { name = GetString(SI_TACHRONOS_Jul), len = 31 },
	[ 8] = { name = GetString(SI_TACHRONOS_Aug), len = 31 },
	[ 9] = { name = GetString(SI_TACHRONOS_Sep), len = 30 },
	[10] = { name = GetString(SI_TACHRONOS_Oct), len = 31 },
	[11] = { name = GetString(SI_TACHRONOS_Nov), len = 30 },
	[12] = { name = GetString(SI_TACHRONOS_Dec), len = 31 },
}
function sun:GetEarthMonthName(monthIdx)	
	return self.earthMonths[monthIdx].name
end

sun.tamrielMonths = {
	[ 1] = { name = "Morning Star", len = 31 },
	[ 2] = { name = "Sun's Dawn",   len = 28 },
	[ 3] = { name = "First Seed",   len = 31 },
	[ 4] = { name = "Rain's Hand",  len = 30 },
	[ 5] = { name = "Second Seed",  len = 31 },
	[ 6] = { name = "Midyear",      len = 30 },
	[ 7] = { name = "Sun's Height", len = 31 },
	[ 8] = { name = "Last Seed",    len = 31 },
	[ 9] = { name = "Hearthfire",   len = 30 },
	[10] = { name = "Frostfall",    len = 31 },
	[11] = { name = "Sun's Dusk",   len = 30 },
	[12] = { name = "Evening Star", len = 31 },
}
function sun:GetTamrielMonthName(monthIdx)	
	return self.tamrielMonths[monthIdx].name
end

function sun:GetTamrielMonthLen(monthIdx)	
	return self.tamrielMonths[monthIdx].len
end

function sun:GetTamrielYearDay(m)  
	local yearDay = 0
	for i = 1, m-1 do
		yearDay = yearDay+self.tamrielMonths[i].len
	end
	return yearDay
end

function sun:GetTamrielYearDate(month,day)
	local yearDate = 0
	for i = 1,month-1 do
		yearDate = yearDate + self.tamrielMonths[month].len
	end
	return yearDate + day
end

sun.earthDays = {
	[1] = GetString(SI_TACHRONOS_Sunday),
	[2] = GetString(SI_TACHRONOS_Monday),
	[3] = GetString(SI_TACHRONOS_Tuesday),
	[4] = GetString(SI_TACHRONOS_Wednesday),
	[5] = GetString(SI_TACHRONOS_Thursday),
	[6] = GetString(SI_TACHRONOS_Friday),
	[7] = GetString(SI_TACHRONOS_Saturday), 
}
function sun:GetEarthDay(dayIdx)
    return self.earthDays[dayIdx]
end

sun.tamrielDays = {
	[1] = "Sundas",
	[2] = "Morndas",
	[3] = "Tirdas",
	[4] = "Middas",
	[5] = "Turdas",
	[6] = "Fredas",
	[7] = "Loredas" 
}
function sun:GetTamrielDay(dayIdx)
    return self.tamrielDays[dayIdx]
end

function sun:IsTamrielToday(dd, mo)
     day, month = select(2,self:GetTamrielDate())
    return dd == day and mo == month
end

function sun:GetEarthTimestamp(hour, minute, second, day, month, year)
    local dt             = os.date("*t")
    year, month,  day    = year or dt.year, month  or dt.month, day    or dt.day
    hour, minute, second = hour or dt.hour, minute or dt.min,   second or dt.sec
    return os.time({year=year, month=month, day=day, hour=hour, min=minute, sec=second})
end

function sun:GetTamrielTimestamp(hour, minute, second, day, month, year)
	
	local function GetTs(hh, mm, ss, dd, mo, yy)
        local monthseconds = { 
        						[01] = 31*24*3600,  
        						[02] = 28*24*3600,  
        						[03] = 31*24*3600,  
        						[04] = 30*24*3600,  
        						[05] = 31*24*3600,  
        						[06] = 30*24*3600,  
        						[07] = 31*24*3600,  
        						[08] = 31*24*3600,  
        						[09] = 30*24*3600,  
        						[10] = 31*24*3600,  
        						[11] = 30*24*3600,  
        						[12] = 31*24*3600
        					 }
        local timestamp = (yy-TAMRIEL_YEAROFFSET)*365*24*3600
        for i=1, mo-1 do timestamp = timestamp + monthseconds[i] end
        timestamp = timestamp + 24*3600*(dd-1) + 3600*hh + 60*mm + ss
        return timestamp
    end
 
    local hTn,  mTn,  sTn  = select(2,self:GetTamrielTime())
	local ddTn, moTn, yyTn = select(2,self:GetTamrielDate())
	local deltaT = GetDiffBetweenTimeStamps( GetTs(hour, minute, second, day, month, year), GetTs(hTn, mTn, sTn, ddTn, moTn, yyTn))
	local deltaE = deltaT*SECONDS_PER_TAMRIEL_SECONDS
	local timestamp = zo_round(GetTimeStamp()+ deltaE)
	return timestamp
end

function sun:testTimeStamp()
	local tsSys = GetTimeStamp()
	local tsTC  = self:GetEarthTimestamp()
	local d     = os.date("*t")
	local tsOS  = os.time({year=d.year, month=d.month, day = d.day, hour=d.hour, min=d.min, sec=d.sec})
	return { ["tsSys"] = tsSys, ["tsTC"] = tsTC, ["tsOS"] = tsOS, ["delta"] = tsSys-tsOS, ["date"]=d }
end

function sun:GetTamrielDate(timeStamp)
	timeStamp = timeStamp or  GetTimeStamp()
	local offsetTime         = GetDiffBetweenTimeStamps(timeStamp, SECONDS_SINCE_START)
	local secondsTamrielYear = SECONDS_PER_TAMRIEL_DAY * 365
	local year               = math.floor(offsetTime / secondsTamrielYear) + TAMRIEL_YEAROFFSET
	local yearDay            = math.floor((offsetTime % secondsTamrielYear) / SECONDS_PER_TAMRIEL_DAY)
	local day                = 0
	local month              = 0
	if (yearDay < 31) then
		day = yearDay + 1
		month = 1
	elseif (yearDay < 59) then
		day = yearDay - 30
		month = 2
	elseif (yearDay < 90) then
		day = yearDay - 58
		month = 3
	elseif (yearDay < 120) then
		day = yearDay - 89
		month = 4
	elseif (yearDay < 151) then
		day = yearDay - 119
		month = 5
	elseif (yearDay < 181) then
		day = yearDay - 150
		month = 6
	elseif (yearDay < 212) then
		day = yearDay - 180
		month = 7
	elseif (yearDay < 243) then
		day = yearDay - 211
		month = 8
	elseif (yearDay < 273) then
		day = yearDay - 242
		month = 9
	elseif (yearDay < 304) then
		day = yearDay - 272
		month = 10
	elseif (yearDay < 334) then
		day = yearDay - 303
		month = 11
	else 
		day = yearDay - 333
		month = 12
	end
	
	local weekDay = math.floor(((offsetTime / SECONDS_PER_TAMRIEL_DAY) + TAMRIEL_WEEKDAY_OFFSET)) % 7 + 1

	return self:GetTamrielDay(weekDay)..", "..self:GetTamrielMonthName(month).." "..day..", 2E "..year, day, month, year, weekDay
end

function sun:GetTamrielTime(secs, timeStamp)
	timeStamp = timeStamp or GetTimeStamp()
	local offsetTime     = timeStamp - SECONDS_SINCE_START 
	local tamrielDayTime = offsetTime % SECONDS_PER_TAMRIEL_DAY 
	local h              = math.floor(tamrielDayTime / SECONDS_PER_TAMRIEL_HOUR) % 24
	local m              = math.floor(tamrielDayTime / SECONDS_PER_TAMRIEL_MINUTE) % 60
	local s              = math.floor(tamrielDayTime / SECONDS_PER_TAMRIEL_SECONDS) % 60
	local t              = ""
	if secs then 
		t = string.format("%02d:%02d:%02d", h, m, s)
	else
		t = string.format("%02d:%02d", h, m)
	end	
	return t, h, m, s
end

function sun:GetEarthTime(secs, timestamp)

	local dt = os.date("*t", timestamp)	
	local h  = dt.hour
	local m  = dt.min
	local s  = dt.sec
	local yy = dt.year
	local mo = dt.month
	local dd = dt.day
	local t  = ""	
	if secs then 
		t = string.format("%02d:%02d:%02d", h, m, s)
	else
		t = string.format("%02d:%02d", h, m)
	end
	return t, h, m, s, dd, mo, yy
end

function sun:GetData(timestamp)
	local f              = 24*3600/SECONDS_PER_TAMRIEL_DAY
	local strTS, h, m, s = self:GetTamrielTime(nil,timestamp)	
	-- sunset
	local secTa          = (22*3600) - (h*3600+m*60+s)
	if h >=22 then secTa = (24*3600) - (h*3600+m*60+s) + 22*3600 end
	local secSet         = secTa/f
	local sunsetTa       = ZO_FormatTime(secSet, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_TWELVE_HOUR_NO_SECONDS)	
	-- sunrise
	local secTa          = (24*3600) - (h*3600+m*60+s) + 3*3600
	if h <3 then secTa = (3*3600) - (h*3600+m*60+s) end
	local secRise        = secTa/f
	local sunriseTa      = ZO_FormatTime(secRise, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_TWELVE_HOUR_NO_SECONDS)	
	
	local day0000   = "TamrielChronos/complications/dds/TC_0000.dds"
	local day2103   = "TamrielChronos/complications/dds/TC_2103.dds"
	local day2202   = "TamrielChronos/complications/dds/TC_2202.dds"
	local day2301   = "TamrielChronos/complications/dds/TC_2301.dds"
	local day2400   = "TamrielChronos/complications/dds/TC_2400.dds"

	if h >= 21 and h < 22 then
		daylight = day2103 
	elseif h >= 22 and h < 23 then
		daylight = day2202 
	elseif h >= 23 and h < 24 then
		daylight = day2301 
	elseif h >= 00 and h < 01 then
		daylight = day2400 	
	elseif h >= 01 and h < 02 then
		daylight = day2301 
	elseif h >= 02 and h < 03 then
		daylight = day2202 
	elseif h >= 03 and h < 04 then
		daylight = day2103 
	else	
		daylight = day0000 
	end
	
	return sunsetTa, sunriseTa, secSet, secRise, daylight
end

function sun:Conv2TST(timestamp)
	local timeT, hT,  mT,  sT           = select(1, self:GetTamrielTime(nil, timestamp))
	local dateT, ddT, moT, yyT, weekday = select(1, self:GetTamrielDate(timestamp))
	local daylight                      = select(5, self:GetData(timestamp))
	return hT, mT, sT, ddT, moT, yyT, dateT.." - "..timeT, daylight, weekday
end

function sun:Conv2EST(timestamp)
	local hE, mE, sE, ddE, moE, yyE = select(2,self:GetEarthTime(nil,timestamp))
	return hE, mE, sE, ddE, moE, yyE
end

