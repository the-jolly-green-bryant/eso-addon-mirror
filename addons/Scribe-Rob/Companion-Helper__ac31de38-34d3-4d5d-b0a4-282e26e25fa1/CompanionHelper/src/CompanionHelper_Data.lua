-- CompanionHelper_Data.lua
local CH = CompanionHelper

CH.companions = {
    {
        id = 1,
        file_name = "Bastion.lua"
    },
    {
        id = 2,
        file_name = "Mirri.lua"
    },
    {
        id = 5,
        file_name = "Ember.lua"
    },
    {
        id = 6,
        file_name = "Isobel.lua"
    },
    {
        id = 8,
        file_name = "Sharp.lua"
    },
    {
        id = 9,
        file_name = "Azandar.lua"
    },
    {
        id = 12,
        file_name = "Tanlorin.lua"
    },
    {
        id = 13,
        file_name = "Zerith.lua"
    }

}

CH.status = {
    disdainful = {
        min = -5000,
        max = -4000,
    },
    irritated = {
        min = -3999,
        max = -2500,
    },
    wary = {
        min = -2499,
        max = 749,
    },
    cordial = {
        min = 750,
        max = 999,
    },
    friendly = {
        min = 1000,
        max = 1999,
    },
    close = {
        min = 2000,
        max = 2999,
    },
    allied = {
        min = 3000,
        max = 3999,
    },
    companion = {
        min = 4000,
        max = 5500,
    }
}