OSI.raidlead = nil

-- data sharing base
local DATA_BASE = 440000

-- ungrouped delayed callback
local waitForCallback = false

-- reset raid icons
function OSI.ResetRaidIcons()
    if not IsUnitGrouped( "player" ) then
        if OSI.raidlead and not waitForCallback then
            -- after zone change, game sometimes
            -- claims we are not grouped for a moment
            waitForCallback = true
            zo_callLater( function()
                waitForCallback = false
                if not IsUnitGrouped( "player" ) then
                    -- d( "resetting raid icons" )
                    OSI.raidlead = nil
                    GROUP_LIST:RefreshData()
                    ZO_WorldMap_RefreshGroupPins()
                end
            end, 500 )
        end
    end
end

-- generate alphabetically sorted list of group members
local function GetSortedUnitList()
    local list = { }
    -- only 12 units since we pack id into 1 byte
    for i = 1, 12 do
        -- unit tag
        local unit = "group" .. i
        -- validate unit
        if DoesUnitExist( unit ) then --and IsUnitGrouped( unit ) then
            -- retrieve unit display name
            local displayName = string.lower( GetUnitDisplayName( unit ) )
            -- store unit display name
            table.insert( list, displayName )
        end
    end
    -- sort list
    table.sort( list )
    return list
end

-- find unitId based on displayName
local function GetCurrentUnitId( displayName )
    local name = string.lower( displayName )
    local list = GetSortedUnitList()
    for i, n in ipairs( list ) do
        if n == name then
            return i
        end
    end
    return 0
end

-- handle icon assigned by raidlead
local function SetRaidIconForUnit( unitId, textureId )
    if not OSI.raidlead then
        OSI.raidlead = { }
    end
    local unitList = GetSortedUnitList()
    local displayName = unitList[unitId]
    if displayName and displayName ~= "" then
        OSI.raidlead[displayName] = textureId > 0 and OSI.rlicons[textureId] or nil
        GROUP_LIST:RefreshData()
        ZO_WorldMap_RefreshGroupPins()
    end
end

-- handle assigning and sharing raid icons
function OSI.AssignRaidIconForUnit( displayName, texture )
    local unitId = GetCurrentUnitId( displayName )
    local textureId = 0
    for i, t in ipairs( OSI.rlicons ) do
        if t == texture then
            textureId = i
            break
        end
    end
    SetRaidIconForUnit( unitId, textureId )
end

-- remove raid icon from unit and share with group
function OSI.RemoveRaidIconForUnit( displayName )
    local unitId = GetCurrentUnitId( displayName )
    SetRaidIconForUnit( unitId, 0 )
    -- reset raidicons if no icons are assigned
    local clear = true
    for n, v in pairs( OSI.raidlead ) do
        if v then
            clear = false
            break
        end
    end
    if clear then
        OSI.raidlead = nil
    end
end

-- remove all raid icons currently assigned
function OSI.RemoveAllRaidIcons() 
    OSI.raidlead = nil
    GROUP_LIST:RefreshData()
    ZO_WorldMap_RefreshGroupPins()
end

-- handle callbacks from raid icon map pings
function OSI.CallbackForRaidIcon( tag, y )
    -- d( "callback tag=" .. tag .. " y=" .. y )
    -- remove all raid icons
    if y == DATA_BASE then
        OSI.raidlead = nil
        GROUP_LIST:RefreshData()
        ZO_WorldMap_RefreshGroupPins()
    
    -- update raid icon for unit
    elseif y > DATA_BASE and y < DATA_BASE + 4096 then
        local data = y - DATA_BASE
        local unitId = data % 16
        local textureId = zo_floor( data / 16 )
        SetRaidIconForUnit( unitId, textureId )
    end
end

-- choose raid icon for unit
function OSI.ChooseRaidIconForUnit( displayName )
    -- assign icon set
    OSI.pickicon:UpdateChoices( OSI.rlicons, { } )
    OSI.pickicon.data.choices = OSI.rlicons

    OSI.custom.raidlead    = true
    OSI.custom.displayName = displayName
    
    if OSI.raidlead and OSI.raidlead[displayName] then
        OSI.custom.texture = OSI.raidlead[displayName]
    else
        OSI.custom.texture = OSI.rlicons[1]
    end

    OSI.picklabel:SetText( "|cffff00RAIDICON FOR " .. string.upper( displayName ) .. "|r" )
    OSI.pickicon.icon:SetTexture( OSI.custom.texture )
    OSI.pick:SetHidden( false )
end
