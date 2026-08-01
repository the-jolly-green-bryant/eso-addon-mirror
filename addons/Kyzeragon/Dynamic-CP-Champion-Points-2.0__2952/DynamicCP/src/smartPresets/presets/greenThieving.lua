-----------------------------------------------------------
-- Role presets
-----------------------------------------------------------
-- If stage is not specified, the star will be maxed out
-- If flex is specified, it uses the index in the flex data
-- If passive is specified, it uses the index in the respective data
-- If deprioritizeSlotting is specified, only slot it if there is still space after allocating all
-----------------------------------------------------------

-- I thought about conditional Discipline Artisan, but it'd
-- be infeasible to assume whether the user has lines they
-- want to level

-- Thieving-oriented green tree
local GREEN_THIEVING = {
    GetFlex = function(_, isHABuild, _, craftingMaxed, index, totalPoints)
        if (not craftingMaxed) then
            return 72 -- Inspiration Boost
        end
        return -1
    end,
    nodes = {
        {
            id = 68, -- Out of Sight (open nodes)
            stage = 1,
        },
        {
            id = 76, -- Friends in Low Places
            deprioritizeSlotting = true, -- TODO
        },
        {
            id = 77, -- Infamous
        },
        {
            id = 84, -- Fade Away
        },
        {
            id = 90, -- Cutpurse's Art
        },
        {
            id = 74, -- Gilded Fingers
        },
        {
            id = 78, -- Master Gatherer (open nodes)
            stage = 1,
        },
        {
            id = 79, -- Treasure Hunter
        },
        {
            id = 81, -- Plentiful Harvest (open nodes)
            stage = 1,
        },
        {
            id = 91, -- Homemaker
        },
        {
            id = 68, -- Out of Sight (maxed)
        },
        {
            id = 71, -- Fortune's Favor
        },
        {
            id = 83, -- Meticulous Disassembly
        },
        {
            id = 66, -- Steed's Blessing
        },
        {
            id = 67, -- Fleet Phantom
        },
        {
            id = 65, -- Sustaining Shadows
        },
        {
            id = 80, -- Shadowstrike
        },
        {
            id = 81, -- Plentiful Harvest (maxed)
        },
        {
            id = 75, -- Steadfast Enchantment (open nodes)
            stage = 1,
        },
        {
            id = 85, -- Rationer (open nodes)
            stage = 1,
        },
        {
            id = 86, -- Liquid Efficiency
        },
        {
            id = 85, -- Rationer (maxed)
        },
        {
            id = 279, -- Discipline Artisan
        },
        {
            id = 69, -- Breakfall
        },
        {
            flex = 1, -- Inspiration Boost
        },
        {
            id = 92, -- Gifted Rider
        },
        {
            id = 78, -- Master Gatherer (maxed)
        },
        {
            id = 1, -- Professional Upkeep
        },
        {
            id = 70, -- Wanderer
        },
        {
            id = 82, -- War Mount
        },
        {
            id = 87, -- Soul Reservoir
        },
        {
            id = 88, -- Reel Technique
        },
        {
            id = 89, -- Angler's Instincts
        },
    },
}


-----------------------------------------------------------
-- applyFunc
-----------------------------------------------------------
function DynamicCP.SmartPresets.ApplyGreenThieving()
    return DynamicCP.ApplySmartPreset("Green", GREEN_THIEVING)
end
