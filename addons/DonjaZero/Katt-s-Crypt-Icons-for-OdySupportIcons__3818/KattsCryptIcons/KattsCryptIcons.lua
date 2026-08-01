local ADDON_NAME  = "KattsCryptIcons"
local MY_TEXTURES = {
    "KattsCryptIcons/icons/KCAdmo.dds",
    "KattsCryptIcons/icons/KCBanHammer.dds",
    "KattsCryptIcons/icons/KCBladeOfWoe.dds",
    "KattsCryptIcons/icons/KCBlue.dds",
    "KattsCryptIcons/icons/KCCHICKEN.dds",
    "KattsCryptIcons/icons/KCCozy.dds",
    "KattsCryptIcons/icons/KCDLJ.dds",
    "KattsCryptIcons/icons/KCDank.dds",
    "KattsCryptIcons/icons/KCFart.dds",
    "KattsCryptIcons/icons/KCFine.dds",
    "KattsCryptIcons/icons/KCHealer.dds",
    "KattsCryptIcons/icons/KCHeart.dds",
    "KattsCryptIcons/icons/KCHearts.dds",
    "KattsCryptIcons/icons/KCHype.dds",
    "KattsCryptIcons/icons/KCJeffrey.dds",
    "KattsCryptIcons/icons/KCKattAvatar.dds",
    "KattsCryptIcons/icons/KCKittyCute.dds",
    "KattsCryptIcons/icons/KCKris.dds",
    "KattsCryptIcons/icons/KCLOL.dds",
    "KattsCryptIcons/icons/KCLOVE.dds",
    "KattsCryptIcons/icons/KCPinkHeart.dds",
    "KattsCryptIcons/icons/KCRage.dds",
    "KattsCryptIcons/icons/KCSwannie.dds",
    "KattsCryptIcons/icons/KCTank.dds",
    "KattsCryptIcons/icons/KCWitch.dds",
    "KattsCryptIcons/icons/KCXim.dds",
    "KattsCryptIcons/icons/KCRaven.dds",
    "KattsCryptIcons/icons/KCHBELogo.dds",
    "KattsCryptIcons/icons/KCHBELogoPride.dds",
    "KattsCryptIcons/icons/KCKrisFace.dds",
    "KattsCryptIcons/icons/KCRainbow.dds",
    "KattsCryptIcons/icons/KCV.dds",
    "KattsCryptIcons/icons/KCVenger.dds",
}

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    -- check if OdySupportIcons is active and supports unique icon packs
    if OSI and OSI.AddCustomIconPack then
        -- add your list of icons
        OSI.AddCustomIconPack(MY_TEXTURES)
    end
end)
