local ArcanumGuildHall = _G["ArcanumGuildHall"]

local function isDst()
    return os.date("*t").isdst and true or false
end

local function getDstOffset()
    return isDst() and 1 or 0
end

local function getLocalUtcOffsetHours()
    local offset = os.date("%z")
    local sign, hours, minutes = offset:match("([+-])(%d%d)(%d%d)")

    hours = tonumber(hours) or 0
    minutes = tonumber(minutes) or 0

    local result = hours + (minutes / 60)
    if sign == "-" then
        result = -result
    end

    return result
end

local function getUtc()
    local utcDate = os.date("!*t")
    utcDate.isdst = isDst()
    return os.time(utcDate)
end

function ArcanumGuildHall:GetTimezone()
    return getLocalUtcOffsetHours() - getDstOffset()
end

function ArcanumGuildHall:GetTimeOffset()
    return ((self.db.clockDst and getDstOffset() or 0) + self.db.clockTimezone) * 3600
end

function ArcanumGuildHall:GetTimeString()
    return os.date("%H:%M", getUtc() + self:GetTimeOffset())
end

ArcanumGuildHall.defaults.clockTimezone = ArcanumGuildHall:GetTimezone()