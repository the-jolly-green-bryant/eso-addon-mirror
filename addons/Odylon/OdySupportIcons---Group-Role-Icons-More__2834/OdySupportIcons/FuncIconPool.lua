local posIcons  = { } -- world position icons
local iconPool  = { } -- group member icons
local unitLUT   = { } -- group member reference
local companion = nil -- companion icon

local function CreateIcon( name )
    local size = OSI.GetOption( "iconsize" )
    local icon = OSI.window:CreateControl( name, OSI.win, CT_TEXTURE )
    icon:ClearAnchors()
    icon:SetAnchor( BOTTOM, OSI.win, CENTER, 0, 0 )
    icon:SetDimensions( size, size )
    icon:SetPixelRoundingEnabled( false )
    icon:SetHidden( true )

    local timeline = ANIMATION_MANAGER:CreateTimeline()
    timeline:SetPlaybackType( ANIMATION_PLAYBACK_LOOP, LOOP_INDEFINITELY )
    timeline:SetHandler( "OnStop", function() icon:SetTextureCoords( 0, 1, 0, 1 ) end )

    return {
        ["use"]  = false,
        ["name"] = nil,
        ["tex"]  = nil,
        ["col"]  = OSI.BASECOLOR,
        ["ctrl"] = icon,
        ["anim"] = {
            ["timeline"] = timeline,
            ["ctrl"]     = timeline:InsertAnimation( ANIMATION_TEXTURE, icon ),
        },
    }
end

local function GetUnusedIcon( name )
    for i = 1, GROUP_SIZE_MAX do
        local icon = iconPool[i]
        if not icon.use then
            icon.name = name
            icon.use  = true
            return icon
        end
    end
    return nil
end

-- exposed function to retrieve the icon size defined by the player
function OSI.GetIconSize()
    return OSI.GetOption( "iconsize" )
end

-- exposed function to print current player position
function OSI.PrintMyPosition()
    local zone, wX, wY, wZ = GetUnitRawWorldPosition( "player" )
    d( "|cffffff[OSI]|r x=" .. wX .. " y=" .. wY .. " z=" .. wZ .. " zone=" .. zone )
end

-- exposed function to create an icon to mark the given position
function OSI.CreatePositionIcon( x, y, z, texture, size, color, offset, callback )
    local icon = nil
    -- try to find an unused icon
    for _, i in pairs( posIcons ) do
        if not i.use then
            icon = i
            break
        end
    end
    -- create a new icon if no unused icon is available
    if not icon then
        icon                    = CreateIcon( "OSIPosIcon" .. #posIcons )
        posIcons[#posIcons + 1] = icon
    end
    -- store icon data
    icon.use               = true
    icon.x, icon.y, icon.z = x, y, z
    icon.callback          = callback
    icon.data              = icon.data or { }
    icon.data.texture      = texture
    icon.data.size         = size or OSI.GetOption( "iconsize" )
    icon.data.color        = color or OSI.BASECOLOR
    icon.data.offset       = offset or 0
    -- update icon data              
    OSI.UpdateIconData( icon, texture, icon.data.color, nil )
    return icon
end

-- exposed function to discard an icon used to mark a position
function OSI.DiscardPositionIcon( icon )
    icon.use = false
end

function OSI.GetPositionIcons()
    return posIcons
end

function OSI.GetIconForPlayer( name )
    return unitLUT[name]
end

function OSI.GetIconForCompanion()
    return companion
end

function OSI.UpdateIconData( icon, texture, color, hodor )
    local anim = icon.anim
    -- update icon color
    if color then
        icon.ctrl:SetColor( color[1], color[2], color[3], 1 )
        icon.col = color
    end
    -- update icon texture
    if icon.tex ~= texture then
        icon.ctrl:SetTexture( texture )
        icon.tex = texture

        if hodor then
            anim.ctrl:SetImageData( hodor[2], hodor[3] )
            anim.ctrl:SetFramerate( hodor[4] )
            anim.timeline:PlayFromStart()
        elseif anim.timeline:IsPlaying() then
            anim.timeline:Stop()
        end
    end
end

function OSI.CreateIconPool()
    -- create group icons
    for i = 1, GROUP_SIZE_MAX do
        iconPool[i] = CreateIcon( "OSI3DIcon" .. i )
    end
    -- create companion icon
    companion = CreateIcon( "OSI3DIconCompanion" )
end

function OSI.ResetIcons()
    local unitTable = { }
    -- create new unit lut and hide icons
    for i = 1, GROUP_SIZE_MAX do
        local name = GetUnitDisplayName( "group" .. i )
        if name and name ~= "" then
            unitTable[name] = true
        end
        iconPool[i].ctrl:SetHidden( true )
    end
    -- release unused icons
    for unit, icon in pairs( unitLUT ) do
        if not unitTable[unit] then
            icon.use = false
        end
    end
    -- assign icons to units
    for unit, _ in pairs( unitTable ) do
        unitTable[unit] = unitLUT[unit] or GetUnusedIcon( unit )
    end
    -- update unit lut
    unitLUT = unitTable
    -- hide companion icon
    companion.ctrl:SetHidden( true )
end
