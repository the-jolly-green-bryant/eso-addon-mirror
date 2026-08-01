local ADDON_NAME  = "CatSupportIcons"
local MY_TEXTURES = {
    "CatSupportIcons/icons/catangry.dds",
    "CatSupportIcons/icons/catbutt.dds",
    "CatSupportIcons/icons/catsalad.dds",
    "CatSupportIcons/icons/cathappy.dds",
    "CatSupportIcons/icons/catshook.dds",
    "CatSupportIcons/icons/catsmile.dds",
    "CatSupportIcons/icons/catspeechless.dds",
    "CatSupportIcons/icons/catstrawb.dds",
    "CatSupportIcons/icons/catsweat.dds",
    "CatSupportIcons/icons/catbanana.dds",
    "CatSupportIcons/icons/catboomer.dds",
    "CatSupportIcons/icons/catbub.dds",
    "CatSupportIcons/icons/catception.dds",
    "CatSupportIcons/icons/catchzburger.dds",
    "CatSupportIcons/icons/catcry.dds",
    "CatSupportIcons/icons/catgrumpy.dds",
    "CatSupportIcons/icons/catgun.dds",
    "CatSupportIcons/icons/catsmug.dds",
    "CatSupportIcons/icons/catwink.dds",
    "CatSupportIcons/icons/catwoah.dds",
    "CatSupportIcons/icons/catwow.dds",
    "CatSupportIcons/icons/catzen.dds",
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