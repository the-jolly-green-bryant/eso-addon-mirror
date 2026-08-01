local ADDON_NAME  = "EisherzGuildIcons"
local MY_TEXTURES = {
    "EisherzGuildIcons/icons/Banner.dds",
    "EisherzGuildIcons/icons/Bird_Daheata.dds",
    "EisherzGuildIcons/icons/Cat_Alex.dds",
    "EisherzGuildIcons/icons/Cat_Azor.dds",
    "EisherzGuildIcons/icons/Cat_Ok.dds",
    "EisherzGuildIcons/icons/Cat_Placebo.dds",
    "EisherzGuildIcons/icons/Crabcat_head_Olivka.dds",
    "EisherzGuildIcons/icons/Crabcat_Olivka.dds",
    "EisherzGuildIcons/icons/Dog_Gam.dds",
    "EisherzGuildIcons/icons/Jesus.dds",
    "EisherzGuildIcons/icons/Joker_Dhikki.dds",
    "EisherzGuildIcons/icons/Lizard_1.dds",
    "EisherzGuildIcons/icons/Lizard_2.dds",
    "EisherzGuildIcons/icons/Lizard_3.dds",
    "EisherzGuildIcons/icons/Lizard_4.dds",
    "EisherzGuildIcons/icons/Lizard_5.dds",
    "EisherzGuildIcons/icons/Lizard_6.dds",
    "EisherzGuildIcons/icons/Lizard_7.dds",
    "EisherzGuildIcons/icons/Mush_Cat_Samo.dds",
    "EisherzGuildIcons/icons/Opossum.dds",
    "EisherzGuildIcons/icons/Penguin.dds",
    "EisherzGuildIcons/icons/Pepe_Thieffear.dds",
    "EisherzGuildIcons/icons/Shrug_Resteror.dds",
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