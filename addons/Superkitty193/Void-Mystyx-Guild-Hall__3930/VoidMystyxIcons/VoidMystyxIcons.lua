local VoidMystyxIcon = "VoidMystyxIcon"

-- Path to the Icons
Kitty = "VoidMystyxIcons/imgs/Kitty.dds"
Seraph = "VoidMystyxIcons/imgs/Seraph.dds"
Skoggy = "VoidMystyxIcons/imgs/Skoggy.dds"
Loading = "VoidMystyxIcons/imgs/Loading.dds"
Gana = "VoidMystyxIcons/imgs/Gana.dds"
Dodo = "VoidMystyxIcons/imgs/Dodo.dds"
Idez = "VoidMystyxIcons/imgs/Idez.dds"
Chieften = "VoidMystyxIcons/imgs/Chieften.dds"
DarkSpirit = "VoidMystyxIcons/imgs/DarkSpirit.dds"

-- Table for the icon paths
local KITTYCI = {
    "VoidMystyxIcons/imgs/Kitty.dds",
    "VoidMystyxIcons/imgs/Seraph.dds",
    "VoidMystyxIcons/imgs/Skoggy.dds",
    "VoidMystyxIcons/imgs/Loading.dds",
    "VoidMystyxIcons/imgs/Gana.dds",
    "VoidMystyxIcons/imgs/Dodo.dds",
    "VoidMystyxIcons/imgs/Idez.dds",
    "VoidMystyxIcons/imgs/Chieften.dds",
    "VoidMystyxIcons/imgs/DarkSpirit.dds"
}

-- Users and their icons
local KITTYUI = {
    ["@Superkitty193"] = Kitty,
    ["@SeraphRemiel"] = Seraph,
    ["@Skogsmard"] = Skoggy,
    ["@Loading1001"] = Loading,
    ["@GanaSensei"] = Gana,
    ["@Dodococonut1234"] = Dodo,
    ["@Ivcsi"] = Idez,
    -- Void Mystyx Chieften
    ["@Bakagist"] = Chieften,
    ["@trash42"] = Chieften,
    -- Dark Spirit Donators
    ["@Lanphier"] = DarkSpirit,
    ["@Jajoze"] = DarkSpirit,
    ["@DirtyRig"] = DarkSpirit,
    ["@YarSmith"] = DarkSpirit,
    ["@SwarupDR"] = DarkSpirit,
    ["@zenxp"] = DarkSpirit,
    ["@Tinwe8"] = DarkSpirit,
    ["@xPRICEless.x"] = DarkSpirit
}

local function VoidMystyxIcon_Initialize()
    d("VoidMystyxIcons initialized.")

    if OSI then
        if OSI.AddUniqueIconPack then
            OSI.AddUniqueIconPack(KITTYUI)
            d("Added unique icon pack.")
        else
            d("OSI.AddUniqueIconPack is not available.")
        end

        if OSI.AddCustomIconPack then
            OSI.AddCustomIconPack(KITTYCI)
            d("Added custom icon pack.")
        else
            d("OSI.AddCustomIconPack is not available.")
        end
    else
        d("OSI is not available.")
    end
end

EVENT_MANAGER:RegisterForEvent(VoidMystyxIcon, EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName ~= VoidMystyxIcon then return end

    EVENT_MANAGER:UnregisterForEvent(VoidMystyxIcon, EVENT_ADD_ON_LOADED)
    
    VoidMystyxIcon_Initialize()
end)

EVENT_MANAGER:RegisterForEvent("IconsSetup", EVENT_ADD_ON_LOADED, function(...)
    VoidMystyxIcon_Initialize()
end)
