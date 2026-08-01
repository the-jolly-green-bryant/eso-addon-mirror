local mt = {}
function mt.__index(tbl, key)
    local value = rawget(tbl, key)

    if value == nil then
        value = setmetatable({}, mt)
        rawset(tbl, key, value)
    end

    return value
end

local function AutoTable()
    return setmetatable({}, mt)
end

-- ----------------------------------------------------------------------------

local db = AutoTable()

local function fillPOIDatabase()
    local maxId = 0
    for i = 1, 3600 do  -- ~2918 in U48
        local zoneIndex, poiIndex = GetPOIIndices(i)

        if zoneIndex ~= 1 then
            db[zoneIndex][poiIndex] = i
            maxId = i
        end
    end

    -- df('Max POI id currently is %d', maxId)
end

local function getPOIId(zoneIndex, poiIndex)
    local poiId = db[zoneIndex][poiIndex]

    if type(poiId) == 'table' then return nil end

    return poiId
end

-- ----------------------------------------------------------------------------

fillPOIDatabase()

assert(ImperialCartographer)
ImperialCartographer.GetPOIId = getPOIId
