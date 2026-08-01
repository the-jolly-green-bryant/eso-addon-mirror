Breadcrumbs = Breadcrumbs or {}

------------------------------------------------
-- Encoding the lines uses the following format:
-- zoneid, origin, colour table, point table, lines
--
-- Between each individual value is a semicolon
-- zoneid, origin, point table and lines are all encoded in hexadecimal
--
-- zoneid is a single value denoting the zone to which the lines belong
--
-- origin is three values (x, y, z) 
-- calculated as the lowest value of (X/Y/Z) of all the points in the point table
-- this is used to encode points as a difference from this origin to turn values
-- such as 224013 into 4013 for example, saving a lot of string length
-- also ensures that all position values in the string are positive
--
-- colour table is a table holding all the colours of all the lines
-- it is preceded by the length of the table, and is used to encode line colour as an index  
-- to save space, rather than repeating the same hex code for multiple lines
-- the colours are stored as a hex string made using rgbToHex(), such as ff00ff
--
-- point table is a table holding all the points used by the lines 
-- it is used to efficiently encode lines that connect, which should be most of them
-- it is preceded by the length of the table and is encoded as a difference to the origin
--
-- lines are encoded as a colour index, followed by the indicies of two points from the point table
-- it is preceded by the number of lines, but this just a sanity check
------------------------------------------------
-- /script Breadcrumbs.DecodeStringToZoneLines(Breadcrumbs.EncodeZoneLinesToString(1000))
function Breadcrumbs.EncodeZoneLinesToString(zoneId) -- /script d(Breadcrumbs.EncodeZoneLinesToString(1000))
    local lines = Breadcrumbs.GetSavedZoneLines(zoneId)
    if #lines == 0 then return "" end

    local colour_table = {}
    local colour_table_indexes = {}
    local points = {}
    local point_indices = {}

    local function addPoint(x, y, z)
        local key = string.format("%X,%X,%X", x, y, z)
        if point_indices[key] then
            return point_indices[key]
        else
            local index = #points + 1
            points[index] = {x = x, y = y, z = z}
            point_indices[key] = index
            return index
        end
    end

    local function rgbToHex(r,g,b)
        local rgb = (r * 0x10000) + (g * 0x100) + b
        return string.format("%06X", rgb) -- leading zeroes
    end

    local min_x, min_y, min_z = math.huge, math.huge, math.huge
    for _, line in pairs(lines) do 
        min_x = math.min(min_x, line.x1, line.x2)
        min_y = math.min(min_y, line.y1, line.y2)
        min_z = math.min(min_z, line.z1, line.z2)
    end

    for _, line in pairs(lines) do
        local dx1, dy1, dz1 = line.x1 - min_x, line.y1 - min_y, line.z1 - min_z
        addPoint(dx1, dy1, dz1)
        local dx2, dy2, dz2 = line.x2 - min_x, line.y2 - min_y, line.z2 - min_z
        addPoint(dx2, dy2, dz2)

        local colour = rgbToHex(math.floor(line.colour[1]*255), math.floor(line.colour[2]*255), math.floor(line.colour[3]*255))
        if colour_table[colour] == nil then
            colour_table[colour] = true
            table.insert(colour_table_indexes, colour)
        end
    end

    local function getColourIndex(colour)
        for i, v in pairs(colour_table_indexes) do
            if v == colour then
                return i
            end
        end
        return 1 -- shouldn't ever happen
    end

    local string = string.format("%X;%X;%X;%X;", zoneId, min_x, min_y, min_z)

    string = string .. string.format("%X;", #colour_table_indexes)
    for _, colour in pairs(colour_table_indexes) do
        string = string .. string.format("%s;", colour)
    end

    string = string .. string.format("%X;", #points)
    for _, point in pairs(points) do
        string = string .. string.format("%X;%X;%X;", point.x, point.y, point.z)
    end

    string = string .. string.format("%X;", #lines)
    for _, line in pairs(lines) do
        local dx1, dy1, dz1 = line.x1 - min_x, line.y1 - min_y, line.z1 - min_z
        local dx2, dy2, dz2 = line.x2 - min_x, line.y2 - min_y, line.z2 - min_z
        local key1 = string.format("%X,%X,%X", dx1, dy1, dz1)
        local key2 = string.format("%X,%X,%X", dx2, dy2, dz2)
        local point1 = point_indices[key1]
        local point2 = point_indices[key2]

        local colour = rgbToHex(line.colour[1]*255, line.colour[2]*255, line.colour[3]*255)
        local colour_index = getColourIndex(colour)

        string = string .. string.format("%i;%X;%X;", colour_index, point1, point2)
    end

    return string
end

------------------------------------------------
-- Example string breakdown
-- 585;6190E;FA7F;45407;3;FF0000;00FF00;0000FF;4;0;0;0;3E8;0;0;0;3E8;0;0;0;3E8;3;1;1;2;2;1;3;3;1;4;
--
-- 585;     6190E; FA7F; 45407;       3; FF0000; 00FF00; 0000FF;     4; 0;0;0; 3E8;0;0; 0;3E8;0; 0;0;3E8;        3; 1;1;2; 2;1;3; 3;1;4;
--
-- zoneid: 585 (hex) -> 1413 (decimal), which is apocrypha zone
--
-- origin: 6190E, FA7F, 45407 are the x, y, z components in hex
--
-- colour table: length 3;
---- colours are:
---- 1: #FF0000 (red)
---- 2: #00FF00 (green)
---- 3: #0000FF (blue)
--
-- point table: length 4;
---- points are:
---- 1: (0, 0, 0)
---- 2: (1000, 0, 0)
---- 3: (0, 1000, 0)
---- 4: (0, 0, 1000)
--
-- lines: length 3;
---- lines are:
---- colour index 1 (red); point 1 (origin) to point 2 (1 metre in x direction)
---- colour index 2 (green); point 1 (origin) to point 3 (1 metre in y direction)
---- colour index 3 (blue); point 1 (origin) to point 4 (1 metre in z direction)
--
-- This string creates a set of coloured 3d axis near the Writing Wastes wayshrine in Apocrypha
------------------------------------------------

local function hexToRGB(hex)
    local r = math.floor(hex / 0x10000)
    local g = math.floor((hex % 0x10000) / 0x100)
    local b = hex % 0x100
    return r, g, b
end

function Breadcrumbs.DecodeImportStringToZoneLines()
    local segments = string.gmatch(Breadcrumbs.sV.importString, "([^;]+)")

    local function nextHex()
        return tonumber(segments(), 16)
    end

    local function nextString()
        return segments()
    end

    local zoneId = nextHex()
    local min_x = nextHex()
    local min_y = nextHex()
    local min_z = nextHex()

    local colour_count = nextHex()
    local colour_table_indexes = {}
    for i = 1, colour_count do
        local hex_colour = nextString()
        local colour_hex = tonumber(hex_colour, 16)
        local r, g, b = hexToRGB(colour_hex)
        colour_table_indexes[i] = {r / 255, g / 255, b / 255}
    end

    local point_count = nextHex()
    local points = {}
    for i = 1, point_count do
        local x = nextHex()
        local y = nextHex()
        local z = nextHex()
        points[i] = {x = x, y = y, z = z}
    end

    local line_count = nextHex()
    local lines = {}
    for i = 1, line_count do
        local colour_index = nextHex()
        local point1_index = nextHex()
        local point2_index = nextHex()

        local colour = colour_table_indexes[colour_index]
        local point1 = points[point1_index]
        local point2 = points[point2_index]

        local x1 = point1.x + min_x
        local y1 = point1.y + min_y
        local z1 = point1.z + min_z
        local x2 = point2.x + min_x
        local y2 = point2.y + min_y
        local z2 = point2.z + min_z

        local line = {
            x1 = x1, y1 = y1, z1 = z1,
            x2 = x2, y2 = y2, z2 = z2,
            colour = colour
        }
        if line then 
            table.insert(lines, line)
        end
    end
    return zoneId, lines
end


function Breadcrumbs.ImportStringToLines()
    local zoneId, decodedLinesTable = Breadcrumbs.DecodeImportStringToZoneLines()
    Breadcrumbs.PopulateZoneLinesFromTable(zoneId, decodedLinesTable)
    Breadcrumbs.sV.exportString = Breadcrumbs.EncodeZoneLinesToString(zoneId)
    Breadcrumbs.sV.importString = "",
    Breadcrumbs.RefreshLines()
end

function Breadcrumbs.UpdateExportString()
    local zoneId = Breadcrumbs.GetZoneId()
    local encodedString = Breadcrumbs.EncodeZoneLinesToString(zoneId)
    Breadcrumbs.sV.exportString = encodedString
end