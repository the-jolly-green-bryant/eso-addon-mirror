OSI.mechanic     = nil
OSI.mechanicSize = 0

-- reset mechanic icons
function OSI.ResetMechanicIcons()
    if not IsUnitGrouped( "player" ) or not IsUnitInCombat( "player" ) then
        OSI.mechanic = nil
    end
end

-- exposed function to assign mechanic icon
function OSI.SetMechanicIconForUnit( displayName, texture, size, color, offset, callback )
    if not OSI.mechanic then
        OSI.mechanic = { }
    end
    OSI.mechanic[string.lower( displayName )] = {
        ["callback"] = callback,
        ["data"]     = {
            ["texture"]     = texture,
            ["size"]        = size or OSI.GetOption( "iconsize" ),
            ["color"]       = color or OSI.BASECOLOR,
            ["offset"]      = offset or 0,
            ["displayName"] = displayName,
        }
    }
end

-- exposed function to remove mechanic icon
function OSI.RemoveMechanicIconForUnit( displayName )
    if not OSI.mechanic then
        return
    end
    OSI.mechanic[string.lower( displayName )] = nil
end

-- DEPRECATED
-- exposed function to adjust mechanic icon size
function OSI.SetMechanicIconSize( size )
    -- OSI.mechanicSize = zo_min( 32, size )
end

-- DEPRECATED
-- exposed function to reset mechanic icon size
function OSI.ResetMechanicIconSize()
    -- OSI.mechanicSize = OSI.GetOption( "iconsize" )
end
