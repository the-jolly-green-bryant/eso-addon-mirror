local MP = Mephisto
MP.zones[ "SE" ] = {}
local SE = MP.zones[ "SE" ]

SE.name = GetString( MP_SE_NAME )
SE.tag = "SE"
SE.icon = "/esoui/art/icons/achievement_u38_vtrial_meta.dds"
SE.priority = 12
SE.id = 1427
SE.node = 534
SE.bosses = {
    [ 1 ] = {
        name = GetString( MP_TRASH ),
    },
    [ 2 ] = {
        name = GetString( MP_SE_DESCENDER ), -- Appears randomly, therefore no postition saved
    },
    [ 3 ] = {
        name = GetString( MP_SE_YASEYLA ),
    },
    [ 4 ] = {
        name = GetString( MP_SE_TWELVANE ), --
    },
    [ 5 ] = {
        name = GetString( MP_SE_ANSUUL ),
    },

}

SE.LOCATIONS = {
    YASEYLA = {
        x1 = 81530,
        x2 = 87530,
        y1 = 14637,
        y2 = 15637,
        z1 = 33077,
        z2 = 42277,
    },
    TWELVANE = {
        x1 = 181951,
        x2 = 187951,
        y1 = 39840,
        y2 = 40840,
        z1 = 216024,
        z2 = 225224,
    },
    ANSUUL = {
        x1 = 196953,
        x2 = 202953,
        y1 = 29699,
        y2 = 30699,
        z1 = 33632,
        z2 = 42832,
    },
}

function SE.Init()
    EVENT_MANAGER:UnregisterForEvent( MP.name, EVENT_BOSSES_CHANGED )
    EVENT_MANAGER:RegisterForUpdate( MP.name .. SE.tag .. "MovementLoop", 2000, SE.OnMovement )
    EVENT_MANAGER:RegisterForEvent( MP.name .. SE.tag, EVENT_PLAYER_COMBAT_STATE, SE.OnCombatChange )
end

function SE.Reset()
    EVENT_MANAGER:UnregisterForEvent( MP.name .. SE.tag, EVENT_PLAYER_COMBAT_STATE )
    EVENT_MANAGER:UnregisterForUpdate( MP.name .. SE.tag .. "MovementLoop" )
    EVENT_MANAGER:RegisterForEvent( MP.name, EVENT_BOSSES_CHANGED, MP.OnBossChange )
end

function SE.OnCombatChange( _, inCombat )
    if inCombat then
        EVENT_MANAGER:UnregisterForUpdate( MP.name .. SE.tag .. "MovementLoop" )
    else
        EVENT_MANAGER:RegisterForUpdate( MP.name .. SE.tag .. "MovementLoop", 2000, SE.OnMovement )
    end
end

function SE.OnMovement()
    local bossName = SE.GetBossByLocation()
    if not bossName then return end
    MP.OnBossChange( _, true, bossName )
end

function SE.GetBossByLocation()
    local zone, x, y, z = GetUnitWorldPosition( "player" )

    if zone ~= SE.id then return nil end

    if x > SE.LOCATIONS.YASEYLA.x1 and x < SE.LOCATIONS.YASEYLA.x2
        and y > SE.LOCATIONS.YASEYLA.y1 and y < SE.LOCATIONS.YASEYLA.y2
        and z > SE.LOCATIONS.YASEYLA.z1 and z < SE.LOCATIONS.YASEYLA.z2 then
        return GetString( MP_SE_YASEYLA )
    elseif x > SE.LOCATIONS.TWELVANE.x1 and x < SE.LOCATIONS.TWELVANE.x2
        and y > SE.LOCATIONS.TWELVANE.y1 and y < SE.LOCATIONS.TWELVANE.y2
        and z > SE.LOCATIONS.TWELVANE.z1 and z < SE.LOCATIONS.TWELVANE.z2 then
        return GetString( MP_SE_TWELVANE )
    elseif x > SE.LOCATIONS.ANSUUL.x1 and x < SE.LOCATIONS.ANSUUL.x2
        and y > SE.LOCATIONS.ANSUUL.y1 and y < SE.LOCATIONS.ANSUUL.y2
        and z > SE.LOCATIONS.ANSUUL.z1 and z < SE.LOCATIONS.ANSUUL.z2 then
        return GetString( MP_SE_ANSUUL )
    else
        return GetString( MP_TRASH )
    end
end

function SE.OnBossChange( bossName )
    MP.conditions.OnBossChange( bossName )
end
