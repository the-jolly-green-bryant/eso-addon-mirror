local ADDON_NAME  = "WindsCustomIcons"

local MY_TEXTURES = {
    "WindsCustomIcons/icons/arrow-blue.dds",
    "WindsCustomIcons/icons/arrow-green.dds",
    "WindsCustomIcons/icons/arrow-pink.dds",
    "WindsCustomIcons/icons/arrow-red.dds",
    "WindsCustomIcons/icons/arrow-yellow.dds",
    "WindsCustomIcons/icons/arrow.dds",
    "WindsCustomIcons/icons/badger.dds",
    "WindsCustomIcons/icons/cat.dds",
    "WindsCustomIcons/icons/dog.dds",
    "WindsCustomIcons/icons/fire.dds",
    "WindsCustomIcons/icons/flake.dds",
    "WindsCustomIcons/icons/fleurdelis.dds",
    "WindsCustomIcons/icons/flower.dds",
    "WindsCustomIcons/icons/flower-yellow.dds",
    "WindsCustomIcons/icons/flower-green.dds",
    "WindsCustomIcons/icons/flower-blue.dds",
    "WindsCustomIcons/icons/leaf.dds",
    "WindsCustomIcons/icons/lighning.dds",
    "WindsCustomIcons/icons/lion.dds",
    "WindsCustomIcons/icons/lynx.dds",
    "WindsCustomIcons/icons/paw.dds",
    "WindsCustomIcons/icons/paw-blue.dds",
    "WindsCustomIcons/icons/portal.dds",
    "WindsCustomIcons/icons/roger.dds",
    "WindsCustomIcons/icons/scratch.dds",
    "WindsCustomIcons/icons/skull.dds",
    "WindsCustomIcons/icons/sparkles.dds",
    "WindsCustomIcons/icons/storm.dds",
    "WindsCustomIcons/icons/sun-red.dds",
    "WindsCustomIcons/icons/sun.dds",
    "WindsCustomIcons/icons/sword-fire.dds",
    "WindsCustomIcons/icons/sword-blue.dds",
    "WindsCustomIcons/icons/sword-rainbow.dds",
    "WindsCustomIcons/icons/sword.dds",
    "WindsCustomIcons/icons/wing.dds",
    "WindsCustomIcons/icons/wing2.dds",
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
