local ADDON_NAME  = "NirnIcons"
local MY_TEXTURES = {
    "NirnIcons/icons/Alkhyom.dds",
    "NirnIcons/icons/Buzz.dds",
    "NirnIcons/icons/chat.dds",
    "NirnIcons/icons/Clem.dds",
    "NirnIcons/icons/kaolie.dds",
    "NirnIcons/icons/pika.dds",
    "NirnIcons/icons/vegeta.dds",
    "NirnIcons/icons/moshu.dds",
    "NirnIcons/icons/brutal.dds",
    "NirnIcons/icons/medic.dds",
    "NirnIcons/icons/Weyland.dds",
    "NirnIcons/icons/Xeno.dds",
    "NirnIcons/icons/Scrat.dds",
    "NirnIcons/icons/weed.dds",
    "NirnIcons/icons/Doomguy.dds",
    "NirnIcons/icons/LordS.dds",
    "NirnIcons/icons/Facepalm.dds",
    "NirnIcons/icons/BuzzSnake.dds",


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