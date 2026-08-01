local ADDON_NAME  = "OtterSupportIcons"
local MY_TEXTURES = {
    "OtterSupportIcons/icons/ottertongue.dds",
    "OtterSupportIcons/icons/otterbacksleep.dds",
    "OtterSupportIcons/icons/ottershell.dds",
    "OtterSupportIcons/icons/2ottersholding.dds",
    "OtterSupportIcons/icons/Santa.dds",
    "OtterSupportIcons/icons/vireosa.dds",
    "OtterSupportIcons/icons/trax2.dds",
    "OtterSupportIcons/icons/trax1.dds",
    "OtterSupportIcons/icons/otterdrum.dds",
    "OtterSupportIcons/icons/Otterbubble.dds",
    "OtterSupportIcons/icons/MagDD.dds",
    "OtterSupportIcons/icons/Heal2.dds",
    "OtterSupportIcons/icons/Heal1.dds",    
    "OtterSupportIcons/icons/otterfishing.dds", 
    "OtterSupportIcons/icons/otterninja.dds", 
    "OtterSupportIcons/icons/otterpirate.dds", 
    "OtterSupportIcons/icons/ottercurl.dds", 
    "OtterSupportIcons/icons/Heal3.dds", 
    "OtterSupportIcons/icons/angryotter.dds", 
    "OtterSupportIcons/icons/floatingotter.dds", 
    "OtterSupportIcons/icons/otterbigeyes.dds", 
    "OtterSupportIcons/icons/seaotter.dds", 
    "OtterSupportIcons/icons/happyotter.dds", 
    "OtterSupportIcons/icons/otterboat2.dds", 
    "OtterSupportIcons/icons/otterboat.dds", 
    "OtterSupportIcons/icons/otterheart.dds", 
    "OtterSupportIcons/icons/otterstood.dds", 
    "OtterSupportIcons/icons/ottertank.dds", 
    "OtterSupportIcons/icons/ottertank2.dds", 
    "OtterSupportIcons/icons/Quest.dds", 
    "OtterSupportIcons/icons/Ottercorn1.dds", 
    "OtterSupportIcons/icons/Ottercorn.dds", 
    "OtterSupportIcons/icons/floathat.dds", 


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