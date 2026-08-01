Breadcrumbs = Breadcrumbs or {}

local InitialiseZone, CreateLinePrimitive, GetZoneId, RefreshLines, AddLineToPool, GetSavedZoneLines, sin, cos, min, pi

function Breadcrumbs.CreateLinePrimitive(x1, y1, z1, x2, y2, z2, colour --[[ Nilable --]], texture --[[ Nilable ]] )
    if x1 == nil or y1 == nil or z1 == nil or x2 == nil or y2 == nil or z2 == nil or colour == "" or texture == "" then return end
    return {
        x1 = x1,
        y1 = y1,
        z1 = z1,
        x2 = x2,
        y2 = y2,
        z2 = z2,
        colour = colour or Breadcrumbs.sV.colour or {1, 1, 1},
        texture = texture or Breadcrumbs.sV.fallbackLineStyle or 1,
    }
end

function Breadcrumbs.GetZoneId()
    return select(1, GetUnitRawWorldPosition("player")) 
end

function Breadcrumbs.CreateLineControl( name )
    local line = {}
    line.lineControl = WINDOW_MANAGER:CreateControl(name, Breadcrumbs.win, CT_CONTROL)
    line.backdrop = WINDOW_MANAGER:CreateControl("$(parent)Backdrop", line.lineControl, CT_BACKDROP)
    return {
        ["lineControl"] = line.lineControl,
        ["backdrop"] = line.backdrop,
    }
end

function Breadcrumbs.Create3DLineControl( name )
    local line = {}
    line.lineControl = WINDOW_MANAGER:CreateControl(name, Breadcrumbs.win, CT_TEXTURE)
    line.backdrop = WINDOW_MANAGER:CreateControl("$(parent)Backdrop", line.lineControl, CT_BACKDROP)
    return {
        ["lineControl"] = line.lineControl,
        ["backdrop"] = line.backdrop,
    }
end

-- todo, replace this with ZO_ControlPool
function Breadcrumbs.AddLineToPool( x1, y1, z1, x2, y2, z2, colour --[[ Nilable --]], texture --[[ Nilable ]] )
    local line
    local linePool = Breadcrumbs.GetLinePool()
    -- try to find an unused line
    for _, i in pairs( linePool ) do
        if not i.use then
            line = i
            break
        end
    end
    -- create a new line if no unused line is available
    if not line then
        if Breadcrumbs.sV.depthMarkers then
            line = Breadcrumbs.Create3DLineControl( "BreadcrumbsLine3D" .. (#linePool+1) )
            linePool[#linePool + 1] = line
        else
            line = Breadcrumbs.CreateLineControl( "BreadcrumbsLine" .. (#linePool+1) )
            linePool[#linePool + 1] = line
        end
    end
    -- store line data
    line.use = true
    line.x1, line.y1, line.z1 = x1, y1, z1
    line.x2, line.y2, line.z2 = x2, y2, z2
    line.colour = colour or Breadcrumbs.sV.colour or {1, 1, 1}
    line.texture = texture or Breadcrumbs.sV.fallbackLineStyle or 1
    Breadcrumbs.InitialiseLine(line)
    return line
end

function Breadcrumbs.DiscardLine(line)
    line.use = false
    if Breadcrumbs.sV.depthMarkers and line.lineControl then
        line.lineControl:SetHidden(true)
    end
end

function Breadcrumbs.GetLinePool()
    return Breadcrumbs.linePool or {}
end

function Breadcrumbs.ClearLinePool()
    Breadcrumbs.linePool = {}
end

-- Lines don't simply vanish from the screen when we remove savedVariables data
-- So we set old lines to be replaced using this function.
-- This ensures their registered control names aren't trying to be overwritten uselessly
-- Avoids "Failure to create control BreadcrumbsLine0. Duplicate name." error
function Breadcrumbs.NilLinePool()
    local linePool = Breadcrumbs.GetLinePool()
    for _, line in pairs( linePool ) do
        Breadcrumbs.DiscardLine(line)
    end
end

function Breadcrumbs.GetSavedZoneLines(zoneId) -- /script Breadcrumbs.GetSavedZoneLines(Breadcrumbs.GetZoneId())
    return Breadcrumbs.sV.savedLines[zoneId] or {}
end

function Breadcrumbs.ClearSavedZoneLines(zoneId)
    Breadcrumbs.sV.savedLines[zoneId] = {}
    RefreshLines()
end

function Breadcrumbs.ClearSavedZoneLinesFromThisZone()
    local zoneId = GetZoneId()
    Breadcrumbs.ClearSavedZoneLines(zoneId)
end

function Breadcrumbs.InitialiseZone()
    local zoneId = GetZoneId()
    Breadcrumbs.sV.savedLines[zoneId] = GetSavedZoneLines(zoneId)
end

function Breadcrumbs.InitialiseExternalZone(zoneId)
    Breadcrumbs.sV.savedLines[zoneId] = GetSavedZoneLines(zoneId)
end

function Breadcrumbs.CreateSavedZoneLine(x1, y1, z1, x2, y2, z2, colour --[[ Nilable --]] )
    InitialiseZone()
    local zoneId = GetZoneId()
    local line = CreateLinePrimitive(x1, y1, z1, x2, y2, z2, colour)
    if line then 
        table.insert(Breadcrumbs.sV.savedLines[zoneId], line)
    end    
    RefreshLines()
    return zoneId
end

function Breadcrumbs.Generate3DAxisLines() -- /script Breadcrumbs.Generate3DAxisLines() 
    InitialiseZone()
    local zoneId, x, y, z = GetUnitRawWorldPosition("player")
    table.insert(Breadcrumbs.sV.savedLines[zoneId], CreateLinePrimitive(x, y, z, x + 1000, y, z, {1,0,0}))
    table.insert(Breadcrumbs.sV.savedLines[zoneId], CreateLinePrimitive(x, y, z, x, y + 1000, z, {0,1,0}))
    table.insert(Breadcrumbs.sV.savedLines[zoneId], CreateLinePrimitive(x, y, z, x, y, z + 1000, {0,0,1}))
    table.insert(Breadcrumbs.sV.savedLines[zoneId], CreateLinePrimitive(x, y, z, x - 1000, y, z, {1,1,0}))
    table.insert(Breadcrumbs.sV.savedLines[zoneId], CreateLinePrimitive(x, y, z, x, y - 1000, z, {0,1,1}))
    table.insert(Breadcrumbs.sV.savedLines[zoneId], CreateLinePrimitive(x, y, z, x, y, z - 1000, {1,0,1}))
    table.insert(Breadcrumbs.sV.savedLines[zoneId], CreateLinePrimitive(x, y, z, x + 1000, y + 1000, z + 1000, {1,1,1}))
    table.insert(Breadcrumbs.sV.savedLines[zoneId], CreateLinePrimitive(x, y, z, x - 1000, y - 1000, z - 1000, {1,1,1}))
    RefreshLines()
    return zoneId
end

function Breadcrumbs.Loc1() -- /script Breadcrumbs.Loc1()
    local _, x, y, z = GetUnitRawWorldPosition("player")
    Breadcrumbs.sV.loc1 = {
        x = x,
        y = y,
        z = z
    }
end

function Breadcrumbs.Loc1FromPos(X, Y, Z)
    if type(X) == "table" then
        local tbl = X
        X, Y, Z = tbl.x, tbl.y, tbl.z
    end
    if X and Y and Z then 
        Breadcrumbs.sV.loc1 = {
            x = X,
            y = Y,
            z = Z,
        }
    end
end

function Breadcrumbs.Loc2() -- /script Breadcrumbs.Loc2()
    local _, x, y, z = GetUnitRawWorldPosition("player")
    Breadcrumbs.sV.loc2 = {
        x = x,
        y = y,
        z = z
    }
end

function Breadcrumbs.Loc2FromPos(X, Y, Z)
    if type(X) == "table" then
        local tbl = X
        X, Y, Z = tbl.x, tbl.y, tbl.z
    end
    if X and Y and Z then 
        Breadcrumbs.sV.loc2 = {
            x = X,
            y = Y,
            z = Z,
        }
    end
end

function Breadcrumbs.CreateLineFromLocs(colour) -- /script Breadcrumbs.CreateLineFromLocs({1,0,1})
    InitialiseZone()
    local zoneId = GetZoneId()
    local loc1 = Breadcrumbs.sV.loc1
    local loc2 = Breadcrumbs.sV.loc2
    if not loc1 or not loc2 then return end
    if loc1 == loc2 then return end
    local line = CreateLinePrimitive(loc1.x, loc1.y, loc1.z, loc2.x, loc2.y, loc2.z, colour)
    if line then
        table.insert(Breadcrumbs.sV.savedLines[zoneId], line)
    end
    RefreshLines()
    return zoneId
end

function Breadcrumbs.CreatePolygon(r, n, colour)
    if n < 3 then return end
    InitialiseZone()
    local zoneId, playerX, playerY, playerZ = GetUnitRawWorldPosition("player")
    local radius = r * 100
    local _, _, heading = GetMapPlayerPosition("player")

    local points = {}
    local y = playerY
    for i = 1, n do
        local angle = heading + pi + (2 * pi / n) * (i - 1)
        if n % 2 == 0 then
            angle = angle + pi / 4
        end
        local x = playerX + radius * sin(angle)
        local z = playerZ + radius * cos(angle)

        table.insert(points, {x = x, y = y, z = z})
    end

    local line_table = {}

    for i = 1, n do
        local sP = points[i]
        local eP = points[i % n + 1]
        local line = CreateLinePrimitive(
            sP.x, sP.y, sP.z,
            eP.x, eP.y, eP.z,
            colour or Breadcrumbs.sV.colour or {1, 1, 1}
        )
        if line then
            table.insert(line_table, line)
        end
    end

    return line_table
end

function Breadcrumbs.PreviewPolygon(r, n, colour) -- /script Breadcrumbs.PreviewPolygon(Breadcrumbs.sV.polygon_radius, Breadcrumbs.sV.polygon_sides, Breadcrumbs.sV.colour)
    RefreshLines()
    local lines = Breadcrumbs.CreatePolygon(r, n, colour)
    for _, line in pairs( lines ) do
        AddLineToPool(line.x1, line.y1, line.z1, line.x2, line.y2, line.z2, line.colour)
    end
end

function Breadcrumbs.PlacePolygon(r, n, colour)
    local lines = Breadcrumbs.CreatePolygon(r, n, colour)
    for _, line in pairs( lines ) do
        Breadcrumbs.CreateSavedZoneLine(line.x1, line.y1, line.z1, line.x2, line.y2, line.z2, line.colour)
    end
    RefreshLines()
end

local function CreateTemporaryLine(line, time)
    local added_line = AddLineToPool(line.x1, line.y1, line.z1, line.x2, line.y2, line.z2, line.colour)
    zo_callLater(function() 
        Breadcrumbs.DiscardLine(added_line)
    end, time)
end 

Breadcrumbs.CreateTemporaryLine = CreateTemporaryLine

function Breadcrumbs.CreateTemporaryLines(lines, time)
    for i, line in pairs( lines ) do
        CreateTemporaryLine(line, time)
    end
end

function Breadcrumbs.PopulateZoneLinesFromTable(zoneId, lines)
    Breadcrumbs.InitialiseExternalZone(zoneId)
    for _, line in pairs(lines) do
        table.insert(Breadcrumbs.sV.savedLines[zoneId], line)
    end
end

local function squaredDistance(x1, y1, z1, x2, y2, z2)
    local dx = x2 - x1
    local dy = y2 - y1
    local dz = z2 - z1
    return dx * dx + dy * dy + dz * dz
end

function Breadcrumbs.FindNearestPoint()
    InitialiseZone()
    local zoneId, x, y, z = GetUnitRawWorldPosition("player")
    local lines = GetSavedZoneLines(zoneId)

    local closest_line_index = nil
    local min_distance = math.huge

    for index, line in pairs(lines) do
        local dist1 = squaredDistance(x, y, z, line.x1, line.y1, line.z1)
        local dist2 = squaredDistance(x, y, z, line.x2, line.y2, line.z2)
        
        local closest_dist = min(dist1, dist2)
        if closest_dist < min_distance then
            min_distance = closest_dist
            closest_line_index = index
        end
    end

    local closest_line = lines[closest_line_index]
    local dist1 = squaredDistance(x, y, z, closest_line.x1, closest_line.y1, closest_line.z1)
    local dist2 = squaredDistance(x, y, z, closest_line.x2, closest_line.y2, closest_line.z2)
    local closest_dist = min(dist1, dist2)

    if closest_dist == dist1 then 
        return {
            x = closest_line.x1,
            y = closest_line.y1,
            z = closest_line.z1,
        }
    else 
        return {
            x = closest_line.x2,
            y = closest_line.y2,
            z = closest_line.z2,
        }
    end

    return nil
end

function Breadcrumbs.RemoveClosestLine() -- /script Breadcrumbs.RemoveClosestLine()
    InitialiseZone()
    local zoneId, x, y, z = GetUnitRawWorldPosition("player")
    local lines = GetSavedZoneLines(zoneId)

    local closest_line_index = nil
    local min_distance = math.huge

    for index, line in pairs(lines) do
        local dist1 = squaredDistance(x, y, z, line.x1, line.y1, line.z1)
        local dist2 = squaredDistance(x, y, z, line.x2, line.y2, line.z2)
        
        local closest_dist = min(dist1, dist2)
        if closest_dist < min_distance then
            min_distance = closest_dist
            closest_line_index = index
        end
    end

    if closest_line_index then
        local closest_line = lines[closest_line_index]
        Breadcrumbs.DiscardLine(closest_line)
        table.remove(Breadcrumbs.sV.savedLines[zoneId], closest_line_index)
    end
    RefreshLines()
end

function Breadcrumbs.GenerateSavedLines() -- /script Breadcrumbs.GenerateSavedLines()
    local zoneId = GetZoneId()
    local lines = GetSavedZoneLines(zoneId)
    for _, line in pairs( lines ) do
        AddLineToPool(line.x1, line.y1, line.z1, line.x2, line.y2, line.z2, line.colour)
    end
end

------------------------------------------------------------------------------------------
-------------------------------- Code from @RoyalTonberry --------------------------------
------------------------------------------------------------------------------------------
local function TransformPoint(originX, originZ, distance, angle)
    local x = originX - distance * sin(angle)
    local z = originZ - distance * cos(angle)
    return x, z
end

local function GetPointLeft(originX, originZ, distance, heading)

    --the player is at (originX, originZ) and looking at (heading) [0, 2*pi) considering N=0, increasing counterclockwise
    --(originX, originZ), heading = the Normal sticking straight out from the player
    --Positive Z = South
    --Positive X = East
    return TransformPoint(originX, originZ, distance, heading + pi/2)
end

local function GetPointRight(originX, originZ, distance, heading)
    return TransformPoint(originX, originZ, distance, heading - pi/2)
end

local function GetPointStraight(originX, originZ, distance, heading)
    return TransformPoint(originX, originZ, distance, heading)
end

function Breadcrumbs.CreateRectangle(length, width, colour)
    InitialiseZone()
    local zoneId, playerX, playerY, playerZ = GetUnitRawWorldPosition("player")
    --heading is Radians with North = 0, and increasing counterclockwise (West = pi/2, South = pi, East = 3*pi/2, North = (0 or 2*pi)
    local _, _, heading = GetMapPlayerPosition("player")
    
    --compute 4 points, directly out from the player, by width/2 * 100 = width * 50 which will convert to centimeters from meters.
    --and then forward in the direction the player is looking by length * 100, which will convert to centimeters.
    --the Heading from GetMapPlayerPosition is an angle in Radians.
    local xL, zL = GetPointLeft(playerX, playerZ, width*50, heading)
    local xFL, zFL = GetPointStraight(xL, zL, length*100, heading)
    local xR, zR = GetPointRight(playerX, playerZ, width*50, heading)
    local xFR, zFR = GetPointStraight(xR, zR, length*100, heading)
    
    local line_table = {}
    local lineNear = CreateLinePrimitive(
        xL, playerY, zL,
        xR, playerY, zR,
        colour or Breadcrumbs.sV.colour or {1, 1, 1}
    )
    local lineFar = CreateLinePrimitive(
        xFL, playerY, zFL,
        xFR, playerY, zFR,
        colour or Breadcrumbs.sV.colour or {1, 1, 1}
    )
    local lineLeft = CreateLinePrimitive(
        xL, playerY, zL,
        xFL, playerY, zFL,
        colour or Breadcrumbs.sV.colour or {1, 1, 1}
    )
    local lineRight = CreateLinePrimitive(
        xR, playerY, zR,
        xFR, playerY, zFR,
        colour or Breadcrumbs.sV.colour or {1, 1, 1}
    )
    table.insert(line_table, lineNear)
    table.insert(line_table, lineFar)
    table.insert(line_table, lineLeft)
    table.insert(line_table, lineRight)
    
    return line_table
end
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

function Breadcrumbs.DrawRectangleFromSlashCommand(input)
    if not input then return end
    local length, width = string.match(input, "^%s*(%d+)%s*:%s*(%d+)%s*$")
    if length and width then
        Breadcrumbs.DrawRectangle(length, width)
    else
        d("Invalid input. Use format: length:width (e.g., 5:3)")
    end
end

function Breadcrumbs.DrawPolygonFromSlashCommand(input)
    if not input then return end
    local radius, n = string.match(input, "^%s*(%d+)%s*:%s*(%d+)%s*$")
    if radius and n then
        Breadcrumbs.DrawPolygon(radius, n)
    else
        d("Invalid input. Use format: radius:n (e.g., 8:12)")
    end
end

function Breadcrumbs.DrawRectangle(length, width, colour)
    if not length or not width then return end
    local lines = Breadcrumbs.CreateRectangle(tonumber(length), tonumber(width), colour)
    for _, line in pairs( lines ) do
        AddLineToPool(line.x1, line.y1, line.z1, line.x2, line.y2, line.z2, line.colour)
    end
end

function Breadcrumbs.SaveRectangle(length, width, colour)
    if not length or not width then return end
    local lines = Breadcrumbs.CreateRectangle(tonumber(length), tonumber(width), colour)
    for _, line in pairs( lines ) do
        Breadcrumbs.CreateSavedZoneLine(line.x1, line.y1, line.z1, line.x2, line.y2, line.z2, line.colour)
    end
end

function Breadcrumbs.DrawCircle(radius, colour)
    if not radius then return end
    local lines = Breadcrumbs.CreatePolygon(tonumber(radius), 24, colour)
    for _, line in pairs( lines ) do
        AddLineToPool(line.x1, line.y1, line.z1, line.x2, line.y2, line.z2, line.colour)
    end
end

function Breadcrumbs.DrawPolygon(radius, n, colour)
    if not radius or not n then return end
    local lines = Breadcrumbs.CreatePolygon(tonumber(radius), tonumber(n), colour)
    for _, line in pairs( lines ) do
        AddLineToPool(line.x1, line.y1, line.z1, line.x2, line.y2, line.z2, line.colour)
    end
end

Breadcrumbs.GRID_CELLS = 4
Breadcrumbs.GRID_SIZE = 5000

function Breadcrumbs.PreviewGrid(colour)
    local N = Breadcrumbs.GRID_SIZE
    local GC = Breadcrumbs.GRID_CELLS

    InitialiseZone()

    local zoneId, px, py, pz = GetUnitRawWorldPosition("player")
    local kx = math.floor(px / N + 0.5)
    local kz = math.floor(pz / N + 0.5)

    local xMin, xMax = (kx - GC) * N, (kx + GC) * N
    local zMin, zMax = (kz - GC) * N, (kz + GC) * N

    local xMid = (xMin + xMax) / 2
    local zMid = (zMin + zMax) / 2

    RefreshLines()

    for x = xMin, xMax, N do
        AddLineToPool(x, py, zMin, x, py, zMid, colour)
        AddLineToPool(x, py, zMid, x, py, zMax, colour)
    end

    for z = zMin, zMax, N do
        AddLineToPool(xMin, py, z, xMid, py, z, colour)
        AddLineToPool(xMid, py, z, xMax, py, z, colour)
    end
end

function Breadcrumbs.RefreshLines()
    Breadcrumbs.StopPolling()
    Breadcrumbs.NilLinePool()
    Breadcrumbs.GenerateSavedLines()
    Breadcrumbs.UpdateExportString()
    if Breadcrumbs.sV.enabled then 
        Breadcrumbs.StartPolling()
    else 
        Breadcrumbs.HideAllLines()
    end
end

function Breadcrumbs.FuncLinePoolLocalise()
    InitialiseZone = Breadcrumbs.InitialiseZone
    CreateLinePrimitive = Breadcrumbs.CreateLinePrimitive
    GetZoneId = Breadcrumbs.GetZoneId
    RefreshLines = Breadcrumbs.RefreshLines
    AddLineToPool = Breadcrumbs.AddLineToPool
    GetSavedZoneLines = Breadcrumbs.GetSavedZoneLines
    sin = math.sin
    cos = math.cos
    min = math.min
    pi = math.pi
end