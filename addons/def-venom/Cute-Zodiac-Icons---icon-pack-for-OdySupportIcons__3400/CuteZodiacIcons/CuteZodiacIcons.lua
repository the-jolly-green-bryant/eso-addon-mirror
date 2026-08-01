local ADDON_NAME  = "CuteZodiacIcons"
local MY_TEXTURES = {
    "CuteZodiacIcons/icons/cutearies.dds",
    "CuteZodiacIcons/icons/cutetaurus.dds",
    "CuteZodiacIcons/icons/cutegemini.dds",
    "CuteZodiacIcons/icons/cutecancer.dds",
    "CuteZodiacIcons/icons/cuteleo.dds",
    "CuteZodiacIcons/icons/cutevirgo.dds",
    "CuteZodiacIcons/icons/cutelibra.dds",
    "CuteZodiacIcons/icons/cutescorpio.dds",
    "CuteZodiacIcons/icons/cutesagi.dds",
    "CuteZodiacIcons/icons/cutecapricorn.dds",
    "CuteZodiacIcons/icons/cuteaquarius.dds",
    "CuteZodiacIcons/icons/cutepisces.dds",
}
EVENT_MANAGER:RegisterForEvent( ADDON_NAME, EVENT_ADD_ON_LOADED, function( _, addonName )
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent( ADDON_NAME, EVENT_ADD_ON_LOADED )
    -- check if OdySupportIcons is active and supports unique icon packs
    if OSI and OSI.AddCustomIconPack then
        -- add your list of icons
        OSI.AddCustomIconPack( MY_TEXTURES )
    end
end )