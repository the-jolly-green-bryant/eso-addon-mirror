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

-- Loot/craft-oriented green tree: prioritizes Treasure
-- Hunter, Plentiful Harvest, etc
local GREEN_LOOT = {
    GetFlex = function(_, isHABuild, _, craftingMaxed, index, totalPoints)
        if (not craftingMaxed) then
            return 72 -- Inspiration Boost
        end
        if (index == 1) then -- Opening nodes
            -- It requires 675 in green to allocate without Inspiration Boost for this particular setup
            if (totalPoints >= 675) then
                return -1
            else
                return 72 -- Inspiration Boost
            end
        elseif (index == 2) then -- Maxing it the second time
            return -1
        end
    end,
    nodes = {
        {
            id = 74, -- Gilded Fingers (open nodes)
            stage = 1,
        },
        {
            id = 71, -- Fortune's Favor (open nodes)
            stage = 1,
        },
        {
            flex = 1, -- Inspiration Boost (open nodes)
            stage = 1,
        },
        {
            id = 83, -- Meticulous Disassembly
        },
        {
            id = 79, -- Treasure Hunter
        },
        {
            flex = 2, -- Inspiration Boost
        },
        {
            id = 78, -- Master Gatherer (open nodes)
            stage = 1,
        },
        {
            id = 81, -- Plentiful Harvest (open nodes)
            stage = 1,
        },
        {
            id = 91, -- Homemaker
        },
        {
            id = 81, -- Plentiful Harvest (maxed)
        },
        {
            id = 78, -- Master Gatherer (maxed)
        },
        {
            id = 74, -- Gilded Fingers (maxed)
        },
        {
            id = 71, -- Fortune's Favor (maxed)
        },
        {
            id = 66, -- Steed's Blessing
        },
        {
            id = 92, -- Gifted Rider
        },
        {
            id = 279, -- Discipline Artisan
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
            id = 88, -- Reel Technique
        },
        {
            id = 89, -- Angler's Instincts
        },
        {
            id = 70, -- Wanderer
        },
        {
            id = 69, -- Breakfall
        },
        {
            id = 65, -- Sustaining Shadows
        },
        {
            id = 75, -- Steadfast Enchantment (maxed)
        },
        {
            id = 87, -- Soul Reservoir
        },
        {
            id = 1, -- Professional Upkeep
        },
        {
            id = 68, -- Out of Sight
        },
        {
            id = 67, -- Fleet Phantom
        },
        {
            id = 82, -- War Mount
        },
        {
            id = 76, -- Friends in Low Places
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
            id = 80, -- Shadowstrike
        },
    },
}


-----------------------------------------------------------
-- applyFunc
-----------------------------------------------------------
function DynamicCP.SmartPresets.ApplyGreenLootGoblin(totalPoints)
    return DynamicCP.ApplySmartPreset("Green", GREEN_LOOT, totalPoints)
end
DynamicCP.TestGreen = DynamicCP.SmartPresets.ApplyGreenLootGoblin

--[[
/script DynamicCP.TestGreen(0)
/script DynamicCP.TestGreen(600)
/script DynamicCP.TestGreen(670)
/script DynamicCP.TestGreen(674)
/script DynamicCP.TestGreen(676)
/script DynamicCP.TestGreen(1000)
]]
