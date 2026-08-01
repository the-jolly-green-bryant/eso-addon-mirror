local ADDON_NAME  = "VariheimSupportIcons"
local MY_TEXTURES = {
	"VariheimSupportIcons/icons/ducklebread.dds",
	"VariheimSupportIcons/icons/heavysack.dds",
	"VariheimSupportIcons/icons/scrib.dds",
	"VariheimSupportIcons/icons/skyshard.dds",
	"VariheimSupportIcons/icons/ragnar.dds",
	"VariheimSupportIcons/icons/sloth.dds",
	"VariheimSupportIcons/icons/elmo.dds",	
	"VariheimSupportIcons/icons/plushie.dds",	
	"VariheimSupportIcons/icons/batman.dds",
	"VariheimSupportIcons/icons/toothless1.dds",
	"VariheimSupportIcons/icons/toothless2.dds",
	"VariheimSupportIcons/icons/MordSmileStare.dds",
	"VariheimSupportIcons/icons/ragingbread.dds",	
	"ChlebikSupportIcons/icons/blackcat.dds",	
	"ChlebikSupportIcons/icons/egg.dds",	
	"ChlebikSupportIcons/icons/otter.dds"


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