local ADDON_NAME  = "OkiesCustomIcons"

local MY_TEXTURES = {
    "OkiesCustomIcons/icons/razorback.dds",
    "OkiesCustomIcons/icons/bear.dds",
    "OkiesCustomIcons/icons/canary.dds",
    "OkiesCustomIcons/icons/rhino.dds",
    "OkiesCustomIcons/icons/badger.dds",
    "OkiesCustomIcons/icons/cheetah.dds",
    "OkiesCustomIcons/icons/eagle.dds",
    "OkiesCustomIcons/icons/elephant.dds",
    "OkiesCustomIcons/icons/lion.dds",
    "OkiesCustomIcons/icons/moose.dds",
    "OkiesCustomIcons/icons/tiger.dds",
    "OkiesCustomIcons/icons/wolf.dds",
    "OkiesCustomIcons/icons/wolverine.dds",
    "OkiesCustomIcons/icons/armadillo.dds",
    "OkiesCustomIcons/icons/bison.dds",
    "OkiesCustomIcons/icons/giraffe.dds",
    "OkiesCustomIcons/icons/gorilla.dds",
    "OkiesCustomIcons/icons/hyena.dds",
    "OkiesCustomIcons/icons/llama.dds",
    "OkiesCustomIcons/icons/opossum.dds",
    "OkiesCustomIcons/icons/ostrich.dds",
    "OkiesCustomIcons/icons/porcupine.dds",
    "OkiesCustomIcons/icons/raccoon.dds",
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
