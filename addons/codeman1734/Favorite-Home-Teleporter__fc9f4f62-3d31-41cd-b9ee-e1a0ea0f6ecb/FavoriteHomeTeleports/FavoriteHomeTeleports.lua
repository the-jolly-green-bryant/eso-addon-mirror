FavoriteHomeTeleports = {}
FavoriteHomeTeleports.name = "FavoriteHomeTeleports"

local function JumpToHouse(houseId, outside)
    RequestJumpToHouse(houseId, outside)
end

function FavoriteHomeTeleports:Initialize()

    if LibRadialMenu then
        LibRadialMenu:RegisterAddon("FHT", "Favorite Home Teleports")

        -- Hall of the Lunar Champion (INSIDE)
        LibRadialMenu:RegisterEntry(
            "FHT",
            "Hall of the Lunar Champion",
            1,
            "/esoui/art/icons/housing_elswyerhallofkhunzarri001.dds",
            function() JumpToHouse(70, false) end,
            "Port to Hall of the Lunar Champion"
        )

        -- Humblemud (OUTSIDE)
        LibRadialMenu:RegisterEntry(
            "FHT",
            "Humblemud",
            2,
            "/esoui/art/icons/housing_argonian_small.dds",
            function() JumpToHouse(10, true) end,
            "Port to Humblemud"
        )

        -- Flaming Nix Deluxe Garret (OUTSIDE)
        LibRadialMenu:RegisterEntry(
            "FHT",
            "Flaming Nix Deluxe Garret",
            3,
            "/esoui/art/icons/housing_ep_apartment.dds",
            function() JumpToHouse(6, true) end,
            "Port to Flaming Nix Deluxe Garret"
        )

        LibRadialMenu:RegisterEntry(
            "FHT",
            "The Golden Gryphon",
            4,
            "/esoui/art/icons/housing_sum_summersetinn.dds",
            function() JumpToHouse(58, true) end,
            "Port to The Golden Gryphon"
        )

        LibRadialMenu:RegisterEntry(
            "FHT",
            "Saint Delyn Penthouse",
            5,
            "/esoui/art/icons/housing_viveccityinn_01.dds",
            function() JumpToHouse(42, true) end,
            "Port to Saint Delyn Penthouse"
        )

        LibRadialMenu:RegisterEntry(
            "FHT",
            "Sugar Bowl Suite",
            6,
            "/esoui/art/icons/housing_elswyerinn001.dds",
            function() JumpToHouse(68, true) end,
            "Port to Sugar Bowl Suite"
)

        LibRadialMenu:RegisterEntry(
            "FHT",
            "Snugpod",
            7,
            "/esoui/art/icons/housing_bosmer_small.dds",
            function() JumpToHouse(13, true) end,
            "Port to Snugpod"
)
    end
end

function FavoriteHomeTeleports.OnAddOnLoaded(event, addonName)
    if addonName == FavoriteHomeTeleports.name then
        FavoriteHomeTeleports:Initialize()
    end
end

EVENT_MANAGER:RegisterForEvent(
    FavoriteHomeTeleports.name,
    EVENT_ADD_ON_LOADED,
    FavoriteHomeTeleports.OnAddOnLoaded
)