local ADDON_NAME  = "ScapegoatIconPack"
local MY_TEXTURES = {
    "ScapegoatIconPack/icons/you128.dds",
    "ScapegoatIconPack/icons/cptlemon128.dds",
    "ScapegoatIconPack/icons/blush128.dds",
    "ScapegoatIconPack/icons/facepalm128.dds",
    "ScapegoatIconPack/icons/Gold128.dds",
    "ScapegoatIconPack/icons/hear128.dds",
    "ScapegoatIconPack/icons/see128.dds",
    "ScapegoatIconPack/icons/speak128.dds",
    "ScapegoatIconPack/icons/lol128.dds",
    "ScapegoatIconPack/icons/Love128.dds",
    "ScapegoatIconPack/icons/Metal128.dds",
    "ScapegoatIconPack/icons/Nah128.dds",
    "ScapegoatIconPack/icons/nut128.dds",
    "ScapegoatIconPack/icons/Plat128.dds",
    "ScapegoatIconPack/icons/Rage128.dds",
    "ScapegoatIconPack/icons/think128.dds",
    "ScapegoatIconPack/icons/wave128.dds",
    "ScapegoatIconPack/icons/Druid128.dds",
    "ScapegoatIconPack/icons/Bambina128.dds",
    "ScapegoatIconPack/icons/Taff128.dds",
    "ScapegoatIconPack/icons/Kel128.dds",
    "ScapegoatIconPack/icons/goo128.dds",
    "ScapegoatIconPack/icons/wildlife128.dds",
    "ScapegoatIconPack/icons/smeg128.dds",
    "ScapegoatIconPack/icons/Myles128.dds",
    "ScapegoatIconPack/icons/Garish128.dds",
    "ScapegoatIconPack/icons/DJ_Drifter128.dds",
    "ScapegoatIconPack/icons/Belgarath128.dds",

    
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