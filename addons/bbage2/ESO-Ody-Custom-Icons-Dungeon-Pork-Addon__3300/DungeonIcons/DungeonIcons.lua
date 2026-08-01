local ADDON_NAME  = "DungeonIcons"

local MY_TEXTURES = {
    ["@CorroCatTails"]   = "DungeonIcons/Icons/Corro.dds",
    ["@WolfessVixen"]    = "DungeonIcons/Icons/vixen.dds",
    ["@bbage1"]          = "odysupporticons/Icons/donut.dds",
    ["@spazzmanspiff4"]  = "DungeonIcons/Icons/spazz.dds",
    ["@Dr.H2O"]          = "DungeonIcons/Icons/h20.dds",
    ["@ormarrgilde"]     = "DungeonIcons/Icons/ormarr.dds",
    ["@Drazaena_Iamdraz"] = "DungeonIcons/Icons/draz.dds",
    ["@Light174"]        = "DungeonIcons/Icons/light.dds",
    ["@SourceofFire"]   = "DungeonIcons/Icons/Source.dds",
    ["@M4L4CH1T3"]      = "DungeonIcons/icons/M4.dds",    
    ["@japandah"]       = "DungeonIcons/icons/japanda.dds",
    ["@NormalToad"]     = "DungeonIcons/icons/toad.dds",
}
EVENT_MANAGER:RegisterForEvent( ADDON_NAME, EVENT_ADD_ON_LOADED, function( _, addonName )
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent( ADDON_NAME, EVENT_ADD_ON_LOADED )
    -- check if OdySupportIcons is active and supports unique icon packs
    if OSI and OSI.AddUniqueIconPack then
        -- add your list of icons
        OSI.AddUniqueIconPack( MY_TEXTURES )
    end
end )