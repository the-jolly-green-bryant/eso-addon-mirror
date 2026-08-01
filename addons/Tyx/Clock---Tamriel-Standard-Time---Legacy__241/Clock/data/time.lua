-------------------------------------------
-- time
-------------------------------------------
cl.tm = {}

local tm = cl.tm

------------------
-- Calc Time
------------------
function tm.ChangeDoubletoHMS(tst)
    local h = math.floor(tst)
    tst = (tst - h) * 60
    local m = math.floor(tst)
    tst = (tst - m) * 60
    local s = math.floor(tst)

    return { h, m, s }
end

function tm.ChangeSToHMS(s)
    local h = 0
    while s > 3599 do
        h = h + 1
        s = s - 3600
    end
    local m = 0
    while s > 59 do
        m = m + 1
        s = s - 60
    end
    return { h, m, s }
end

function tm.ChangeHMSToS(h, m, s)
    local sec = h * 3600 + m * 60 + s
    return sec
end

------------------
-- returns the UNIX stamp for midnight
------------------
function tm.CreateMidnight()
    local tSinceStart = cl.st.GetTime("start")
    local name = cl.st.GetTime("name")
    local dayT = cl.st.GetTime("daytime")
    local night = cl.st.GetTime("night")
    local midToRise = night / 2
    local riseToSet = dayT - night
    if name == "sunrise" then
        tSinceStart = tSinceStart - midToRise
    elseif name == "noon" then
        tSinceStart = tSinceStart - midToRise - riseToSet / 2
    elseif name == "sunset" then -- sunset
        tSinceStart = tSinceStart - midToRise - riseToSet
    end -- midnight can be ignored because that is the one we want

    return tSinceStart
end

------------------
-- returns table {h,m,s} in 24h format
------------------
function tm.GetTST(osT)
    -- Time since saved midnight
    local tSinceMidnight = tm.CreateMidnight()
    tSinceMidnight = osT - tSinceMidnight
    --[[
      Idea.
        dayT = length of a day in ms
        daysPast = how many days have past * length of a day in ms
        ms since save midnight (calc back) = Time since saved midnight - how many days have past
        tst = length of a real day * percentage of day past in Tamriel
    ]] --
    local dayT = cl.st.GetTime("daytime")
    local daysPast = dayT * math.floor(tSinceMidnight / dayT)

    local s = tSinceMidnight - daysPast

    local tst = 24 * s / dayT
    return tm.ChangeDoubletoHMS(tst)
end

------------------
-- returns table {h,m,s} in 24h format
-- IMPORTANT: Will work as a cross Addon function
------------------
function GetTST()
    local osT = GetTimeStamp()
    local tst = tm.GetTST(osT)
    return tst
end

------------------
-- time calculator
-- returns false if wrong name
------------------
function tm.CreateNewStart(name, t) -- maybe have to create new time and save which time was set to work with. Calc noon to midnight might make problems if you change the lenght of a day
    name = name:lower()

    cl.st.SetTime("start", t)
    cl.st.SetTime("name", name)

    return true
end


------------------
-- Date calculator
------------------
local function CalcStartTime(gameStart)
    local start = tm.CreateMidnight()
    local t = start - gameStart
    local day = cl.st.GetTime("daytime")

    while t - day > 0 do
        t = t - day
    end

    return gameStart + t
end

function tm.GetLoreDate()
    -- Eso Release  04.04.2014  UNIX: 1396569600
    -- Lore Year 2E 582
    -- Lore Month 4 Rain's Hand
    -- Lore Day 4 Fredas
    local yearStart = 582
    local monthStart = 1
    local length = {
        day = cl.st.GetTime("daytime"),
        month = {
            [1] = 31,
            [2] = 28,
            [3] = 31,
            [4] = 30,
            [5] = 31,
            [6] = 30,
            [7] = 31,
            [8] = 31,
            [9] = 30,
            [10] = 31,
            [11] = 30,
            [12] = 31,
        },
    }
    local gameStart = CalcStartTime(1396569600)
    gameStart = gameStart - 4 * length.day -- 4 days before was a monday
    gameStart = gameStart - (30 + 28 + 31) * length.day -- 3 lore month before was the beginnung of the year when we think that 4.4 in RT is the same in Tamriel
    local tSinceStart = GetTimeStamp() - gameStart
    length.year = length.day * 365
    -- YEAR
    local year = math.floor(tSinceStart / length.year)
    tSinceStart = tSinceStart - year * length.year
    year = yearStart + year
    -- MONTH
    local month = monthStart
    while tSinceStart - (length.month[month] * length.day) > 0 do
        tSinceStart = tSinceStart - (length.month[month] * length.day)
        if month + 1 > 12 then
            month = 1
        else
            month = month + 1
        end
    end
    -- WEEK DAY
    local day = math.ceil(tSinceStart / length.day)

    return year, month, day
end

local tmpWD = {
    day = 0,
    month = 0,
    yearShort = 0,
    weekDay = 0,
}

function tm.GetRealWeekDay(day, month, yearShort)
    -- Algorithm will only run if not run already at the current day
    if tmpWD.day ~= day or tmpWD.month ~= month or tmpWD.yearShort ~= yearShort then
        local m = {
            [1] = 31,
            [2] = 28,
            [3] = 31,
            [4] = 30,
            [5] = 31,
            [6] = 30,
            [7] = 31,
            [8] = 31,
            [9] = 30,
            [10] = 31,
            [11] = 30,
            [12] = 31,
        }

        local dd = 31
        local mm = 3
        local yy = 14

        local x = 0

        while dd < day or mm < month or yy < yearShort do
            if (yy % 4) == 0 then
                m[2] = 29
            else
                m[2] = 28
            end

            if dd + 1 > m[mm] then
                if mm + 1 > 12 then
                    dd = 1
                    mm = 1
                    yy = yy + 1
                else
                    dd = 1
                    mm = mm + 1
                end
            else
                dd = dd + 1
            end

            x = x + 1
        end

        tmpWD.weekDay = (x % 7) + 1
        tmpWD.day = day
        tmpWD.month = month
        tmpWD.yearShort = yearShort
    end

    return tmpWD.weekDay
end