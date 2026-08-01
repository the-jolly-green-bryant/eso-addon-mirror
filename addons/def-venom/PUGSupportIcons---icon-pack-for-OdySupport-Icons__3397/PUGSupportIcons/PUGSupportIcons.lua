local ADDON_NAME  = "PUGSupportIcons"
local MY_TEXTURES = {
    "PUGSupportIcons/icons/coolpug.dds",
    "PUGSupportIcons/icons/tonguepug.dds",
    "PUGSupportIcons/icons/donutpug.dds",
    "PUGSupportIcons/icons/starpug.dds",
    "PUGSupportIcons/icons/pugpower.dds",
    "PUGSupportIcons/icons/pugamen.dds",
    "PUGSupportIcons/icons/pugalien.dds",
    "PUGSupportIcons/icons/pugfather.dds",
    "PUGSupportIcons/icons/pugcurious.dds",
    "PUGSupportIcons/icons/pugsweaty.dds",
    "PUGSupportIcons/icons/pugcrown.dds",
    "PUGSupportIcons/icons/pugdapper.dds",
    "PUGSupportIcons/icons/pugparty.dds",
    "PUGSupportIcons/icons/goodpug.dds",
    "PUGSupportIcons/icons/judgeypug.dds",
    "PUGSupportIcons/icons/laughingpug.dds",
    "PUGSupportIcons/icons/ohshitpug.dds",
    "PUGSupportIcons/icons/sadpug.dds",
    "PUGSupportIcons/icons/stoicpug.dds",
    "PUGSupportIcons/icons/wildpug.dds",
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