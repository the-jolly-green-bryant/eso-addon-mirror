local ADDON_NAME  = "PhoenixsSupportIcons"
local MY_TEXTURES = {
    "PhoenixsSupportIcons/icons/oldscythe.dds",
    "PhoenixsSupportIcons/icons/snakoramix.dds",
    "PhoenixsSupportIcons/icons/alcena.dds",
    "PhoenixsSupportIcons/icons/malacath.dds",
    "PhoenixsSupportIcons/icons/toutenos.dds",
    "PhoenixsSupportIcons/icons/nzo0.dds",

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