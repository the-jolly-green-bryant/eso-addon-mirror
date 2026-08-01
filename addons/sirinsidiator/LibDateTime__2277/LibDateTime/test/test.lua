-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

if not Taneth then return end
local lib = LibDateTime

Taneth("LibDateTime", function()
    describe("Test the leap year calculation", function()
        -- from http://www.miniwebtool.com/leap-years-list/?start_year=1600&end_year=2200
        local leapYears = {1600, 1604, 1608, 1612, 1616, 1620, 1624, 1628, 1632, 1636, 1640, 1644, 1648, 1652, 1656, 1660, 1664, 1668, 1672, 1676, 1680, 1684, 1688, 1692, 1696, 1704, 1708, 1712, 1716, 1720, 1724, 1728, 1732, 1736, 1740, 1744, 1748, 1752, 1756, 1760, 1764, 1768, 1772, 1776, 1780, 1784, 1788, 1792, 1796, 1804, 1808, 1812, 1816, 1820, 1824, 1828, 1832, 1836, 1840, 1844, 1848, 1852, 1856, 1860, 1864, 1868, 1872, 1876, 1880, 1884, 1888, 1892, 1896, 1904, 1908, 1912, 1916, 1920, 1924, 1928, 1932, 1936, 1940, 1944, 1948, 1952, 1956, 1960, 1964, 1968, 1972, 1976, 1980, 1984, 1988, 1992, 1996, 2000, 2004, 2008, 2012, 2016, 2020, 2024, 2028, 2032, 2036, 2040, 2044, 2048, 2052, 2056, 2060, 2064, 2068, 2072, 2076, 2080, 2084, 2088, 2092, 2096, 2104, 2108, 2112, 2116, 2120, 2124, 2128, 2132, 2136, 2140, 2144, 2148, 2152, 2156, 2160, 2164, 2168, 2172, 2176, 2180, 2184, 2188, 2192, 2196}
        local isLeapYear = {}
        for i = 1, #leapYears do isLeapYear[leapYears[i]] = true end
    
        it("for every year between 1600 and 2200", function()
            for year = 1600, 2200 do
                local expected = (isLeapYear[year] == true)
                local actual = lib:IsLeapYear(year)
                assert.equals(actual, expected, year)
            end
        end)
    end)
    
    describe("Test the month and day calculation", function()
        local daysPerMonth =       {31, 28, 31, 30,  31,  30,  31,  31,  30,  31,  30,  31}
        local startDayNormalYear = { 1, 32, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335}
        local startDayLeapYear =   { 1, 32, 61, 92, 122, 153, 183, 214, 245, 275, 306, 336}
    
        local function TestDay(dayOfYear, expectedMonth, expectedDay, actualMonth, actualDay)
            local message = string.format("dayOfYear: %d, expected: %d-%d, actual: %d-%d", dayOfYear, expectedMonth, expectedDay, actualMonth, actualDay)
            assert.equals(actualMonth, expectedMonth, message .. " (month)")
            assert.equals(actualDay, expectedDay, message .. " (day)")
        end
    
        it("for a negative day value", function()
            local month, day = lib:CalculateMonthAndDayFromDayOfYear(-1)
            assert.is_nil(month)
            assert.is_nil(day)
        end)
    
        it("for leap day value of a regular year", function()
            local year = 2019
            local dayOfYear = 60
            local expectedMonth = 3
            local expectedDay = 1
            local actualMonth, actualDay = lib:CalculateMonthAndDayFromDayOfYear(year, dayOfYear)
            TestDay(dayOfYear, expectedMonth, expectedDay, actualMonth, actualDay)
        end)
    
        it("for last day value of a year", function()
            local year = 2019
            local dayOfYear = 365
            local expectedMonth = 12
            local expectedDay = 31
            local actualMonth, actualDay = lib:CalculateMonthAndDayFromDayOfYear(year, dayOfYear)
            TestDay(dayOfYear, expectedMonth, expectedDay, actualMonth, actualDay)
        end)
    
        it("for a day value beyond a year", function()
            local year = 2019
            local month, day = lib:CalculateMonthAndDayFromDayOfYear(year, 366)
            assert.is_nil(month)
            assert.is_nil(day)
        end)
    
        it("for leap day value of a leap year", function()
            local year = 2020
            local dayOfYear = 60
            local expectedMonth = 2
            local expectedDay = 29
            local actualMonth, actualDay = lib:CalculateMonthAndDayFromDayOfYear(year, dayOfYear)
            TestDay(dayOfYear, expectedMonth, expectedDay, actualMonth, actualDay)
        end)
    
        it("for last day value of a leap year", function()
            local year = 2020
            local dayOfYear = 366
            local expectedMonth = 12
            local expectedDay = 31
            local actualMonth, actualDay = lib:CalculateMonthAndDayFromDayOfYear(year, dayOfYear)
            TestDay(dayOfYear, expectedMonth, expectedDay, actualMonth, actualDay)
        end)
    
        it("for a day value beyond a leap year", function()
            local year = 2020
            local month, day = lib:CalculateMonthAndDayFromDayOfYear(year, 367)
            assert.is_nil(month)
            assert.is_nil(day)
        end)
    
        it("for regular years", function()
            local year = 2019
            for expectedMonth = 1, #daysPerMonth do
                local startDay = startDayNormalYear[expectedMonth]
                local endDay = startDay + daysPerMonth[expectedMonth] - 1
                for dayOfYear = startDay, endDay do
                    local expectedDay = dayOfYear - startDay + 1
    
                    local actualMonth, actualDay = lib:CalculateMonthAndDayFromDayOfYear(year, dayOfYear)
                    TestDay(dayOfYear, expectedMonth, expectedDay, actualMonth, actualDay)
                end
            end
        end)
    
        it("for leap years", function()
            local year = 2020
            for expectedMonth = 1, #daysPerMonth do
                local startDay = startDayLeapYear[expectedMonth]
                local endDay = startDay + daysPerMonth[expectedMonth] - 1
                for dayOfYear = startDay, endDay do
                    local expectedDay = dayOfYear - startDay + 1
    
                    local actualMonth, actualDay = lib:CalculateMonthAndDayFromDayOfYear(year, dayOfYear)
                    TestDay(dayOfYear, expectedMonth, expectedDay, actualMonth, actualDay)
                end
            end
        end)
    end)

    describe("Test the timestamp calculation", function()
        local SECONDS_PER_DAY = 60 * 60 * 24
        it("for each day between 1970-01-02 and 2030-01-01", function()
            for timestamp = SECONDS_PER_DAY, 1893456000, SECONDS_PER_DAY do
                local date = os.date("!*t", timestamp)
                assert.is_not_nil(date, timestamp)
                local result = lib:CalculateTimeStamp(date.year, date.month, date.day)
                assert.equals(timestamp, result)
            end
        end)

        it("for every second on 1970-01-02", function()
            for timestamp = SECONDS_PER_DAY, SECONDS_PER_DAY * 2 - 1 do
                local date = os.date("!*t", timestamp)
                assert.is_not_nil(date, timestamp)
                local result = lib:CalculateTimeStamp(1970, 1, 2, date.hour, date.min, date.sec)
                assert.equals(timestamp, result)
            end
        end)
    end)

    describe("Test the iso week difference calculation", function()
        it("for same week", function()
            local thisYear, thisWeek = 2017, 1
            local thatYear, thatWeek = 2017, 1
            local result = lib:CalculateIsoWeekDifference(thisYear, thisWeek, thatYear, thatWeek)
            assert.equals(result, 0)
        end)
        it("for a week in the past in same year", function()
            local thisYear, thisWeek = 2017, 2
            local thatYear, thatWeek = 2017, 1
            local result = lib:CalculateIsoWeekDifference(thisYear, thisWeek, thatYear, thatWeek)
            assert.equals(result, -1)
        end)
        it("for a week in the future in same year", function()
            local thisYear, thisWeek = 2017, 30
            local thatYear, thatWeek = 2017, 31
            local result = lib:CalculateIsoWeekDifference(thisYear, thisWeek, thatYear, thatWeek)
            assert.equals(result, 1)
        end)
        it("for a week in the previous year", function()
            local thisYear, thisWeek = 2017, 5
            local thatYear, thatWeek = 2016, 31
            local result = lib:CalculateIsoWeekDifference(thisYear, thisWeek, thatYear, thatWeek)
            assert.equals(result, -26)
        end)
        it("for a week in the next year", function()
            local thisYear, thisWeek = 2017, 5
            local thatYear, thatWeek = 2018, 31
            local result = lib:CalculateIsoWeekDifference(thisYear, thisWeek, thatYear, thatWeek)
            assert.equals(result, 78)
        end)
        it("for a week some years in the past", function()
            local thisYear, thisWeek = 2017, 5
            local thatYear, thatWeek = 2014, 31
            local result = lib:CalculateIsoWeekDifference(thisYear, thisWeek, thatYear, thatWeek)
            assert.equals(result, -131)
        end)
        it("for a week some years in the future", function()
            local thisYear, thisWeek = 2017, 5
            local thatYear, thatWeek = 2022, 31
            local result = lib:CalculateIsoWeekDifference(thisYear, thisWeek, thatYear, thatWeek)
            assert.equals(result, 287)
        end)
    end)
end)
