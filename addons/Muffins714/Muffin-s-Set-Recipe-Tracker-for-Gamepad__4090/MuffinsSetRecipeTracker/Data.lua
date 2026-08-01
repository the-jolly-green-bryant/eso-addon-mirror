-- Create the global namespace for the addon
MuffinsSetRecipeTracker = MuffinsSetRecipeTracker or {}

-- Create a local shortcut for global
local MSRT = MuffinsSetRecipeTracker

MSRT.StyleSets = {
    ["Apocrypha Expedition"] = {
        pieces  = {},
        exclude = { topLevelIndex = { [16] = true } }, -- weapon pages are Crown Store exclusive
        renames = {
        },
    },
    ["Arkay Unending Cycle"] = {
        pieces  = {},
        exclude = { topLevelIndex = { [16] = true } }, -- weapon pages are Crown Store exclusive
        renames = {
        },
    },
    ["Ayleid Lich"] = {
        pieces  = {},
        exclude = { topLevelIndex = { [16] = true } }, -- weapon pages are Crown Store exclusive
        renames = {
        },
    },
    ["Bonemold"] = {
        pieces  = {},
        exclude = { topLevelIndex = { [16] = true } }, -- weapon pages are Crown Store exclusive
        renames = {
        },
    },
    ["Bristleback Hunter"] = {
        pieces  = {},
        exclude = { topLevelIndex = { [16] = true } }, -- weapon pages are Crown Store exclusive
        renames = {
        },
    },
    ["Cadwell's"] = {
        total   = 10,
        exclude = { topLevelIndex = { [15] = true } }, -- armor pages are Crown Store exclusive
        pieces  = {
            [6100] = "Axe",                            -- 16 = 2
            [6097] = "Battle Axe",                     -- 16 = 1
            [6101] = "Bow",                            -- 16 = 4
            [6102] = "Dagger",                         -- 16 = 1
            [6099] = "Greatsword",                     -- 16 = 1
            [6103] = "Mace",                           -- 16 = 2
            [6098] = "Maul",                           -- 16 = 1
            [6104] = "Shield",                         -- 16 = 3
            [6105] = "Staff",                          -- 16 = 5
            [6106] = "Sword",                          -- 16 = 2
        },
    },
    ["Claw-Dance Acolyte"] = {
        pieces  = {},
        exclude = { topLevelIndex = { [16] = true } }, -- weapon pages are Crown Store exclusive
        renames = {
        },
    },
    ["Crowborne Hunter"] = {
        pieces  = {},
        exclude = { topLevelIndex = { [16] = true } }, -- weapon pages are Crown Store exclusive
        renames = {
        },
    },
    ["Dapper Daredevil"] = {
        pieces  = {},
        exclude = { topLevelIndex = { [16] = true } }, -- weapon pages are Crown Store exclusive
        renames = {
        },
    },
    ["Doctrine Ordinator"] = {
        pieces  = {},
        exclude = { topLevelIndex = { [16] = true } }, -- weapon pages are Crown Store exclusive
        renames = {
        },
    },
    ["Earthbone Ayleid"] = {
        pieces  = {},
        exclude = { topLevelIndex = { [16] = true } }, -- weapon pages are Crown Store exclusive
        renames = {
        },
    },
    ["Ebonsteel Knight"] = {
        pieces  = {},
        exclude = { topLevelIndex = { [16] = true } }, -- weapon pages are Crown Store exclusive
        renames = {
        },
    },
    ["Eltheric Revenant"] = {
        pieces  = {},
        exclude = { topLevelIndex = { [16] = true } }, -- weapon pages are Crown Store exclusive
        renames = {
        },
    },
    ["Evergloam Champion"] = {
        pieces  = {},
        exclude = { topLevelIndex = { [15] = true } }, -- armor pages are Crown Store exclusive
        renames = {
        },
    },
    ["Evergreen"] = {
        pieces  = {},
        exclude = { topLevelIndex = { [16] = true } }, -- weapon pages are Crown Store exclusive
        renames = {
        },
    },
    ["Glenmoril Wyrd"] = {
        total  = 18,
        pieces = {
            [6756] = "Axe",        -- 16 = 2
            [6753] = "Battle Axe", -- 16 = 1
            [6757] = "Bow",        -- 16 = 4
            [6787] = "Chest",      -- 15 = 2
            [6794] = "Chest 2",    -- 15 = 2
            [6758] = "Dagger",     -- 16 = 2
            [6792] = "Feet",       -- 15 = 5
            [6755] = "Greatsword", -- 16 = 1
            [6793] = "Hands",      -- 15 = 6
            [6788] = "Head",       -- 15 = 1
            [6789] = "Legs",       -- 15 = 3
            [6759] = "Mace",       -- 16 = 2
            [6754] = "Maul",       -- 16 = 1
            [6760] = "Shield",     -- 16 = 3
            [6790] = "Shoulders",  -- 15 = 4
            [6761] = "Staff",      -- 16 = 5
            [6762] = "Sword",      -- 16 = 2
            [6791] = "Waist",      -- 15 = 7
        },
    },
    ["Gold Road Dragoon"] = {
        pieces  = {},
        exclude = { topLevelIndex = { [16] = true } }, -- weapon pages are Crown Store exclusive
        renames = {
        },
    },
    ["Imperial Champion"] = {
        pieces  = {},
        exclude = { topLevelIndex = { [15] = true } }, -- armor pages are Crown Store exclusive
        renames = {
        },
    },
    ["Nibenese Court Wizard"] = {
        total  = 7,
        pieces = {
            [9280] = "Chest",     -- 15 = 2
            [9284] = "Feet",      -- 15 = 5
            [9285] = "Hands",     -- 15 = 6
            [9281] = "Head",      -- 15 = 1
            [9282] = "Legs",      -- 15 = 3
            [9283] = "Shoulders", -- 15 = 4
            [9286] = "Waist",     -- 15 = 7
        },
    },
    ["Nord Carved"] = {
        pieces  = {},
        exclude = { topLevelIndex = { [16] = true } }, -- weapon pages are Crown Store exclusive
        renames = {
        },
    },
    ["Oaken Order"] = {
        pieces  = {},
        exclude = { topLevelIndex = { [16] = true } }, -- weapon pages are Crown Store exclusive
        renames = {
        },
    },
    ["Pay to Lose"] = {
        total  = 2,
        pieces = {
            [7616] = "Helm",       -- 15 = 1
            [7617] = "Two Handed", -- 16 = 1
        },
    },
    ["Regal Regalia"] = {
        pieces  = {},
        exclude = { topLevelIndex = { [16] = true } }, -- weapon pages are Crown Store exclusive
        renames = {
        },
    },

    ["Saberkeel Panoply"] = {
        pieces  = {},
        exclude = { topLevelIndex = { [16] = true } }, -- weapon pages are Crown Store exclusive
        renames = {
        },
    },

    ["Sancre Tor Sentry"] = {
        pieces  = {},
        exclude = { topLevelIndex = { [16] = true } }, -- weapon pages are Crown Store exclusive
        renames = {
        },
    },

    ["Second Legion"] = {
        pieces  = {},
        exclude = { topLevelIndex = { [16] = true } }, -- weapon pages are Crown Store exclusive
        renames = {
        },
    },
    ["Maelstrom"] = {
        total  = 10,
        pieces = {
            [3723] = "Axe",        -- 16 = 2
            [3720] = "Battle Axe", -- 16 = 1
            [3724] = "Bow",        -- 16 = 4
            [4892] = "Dagger",     -- 16 = 1
            [3722] = "Greatsword", -- 16 = 1
            [3725] = "Mace",       -- 16 = 2
            [3721] = "Maul",       -- 16 = 1
            [3726] = "Shield",     -- 16 = 3
            [3727] = "Staff",      -- 16 = 5
            [3728] = "Sword",      -- 16 = 2
        },
    },
    ["Tree-Sap Legion"] = {
        pieces  = {},
        exclude = { topLevelIndex = { [16] = true } }, -- weapon pages are Crown Store exclusive
        renames = {
        },
    },
    ["Wickerchain Soul"] = {
        pieces  = {},
        exclude = { topLevelIndex = { [16] = true } }, -- weapon pages are Crown Store exclusive
        renames = {
        },
    },

    ["Witchmother's Servant"] = {
        pieces  = {},
        exclude = { topLevelIndex = { [16] = true } }, -- weapon pages are Crown Store exclusive
        renames = {
        },
    },
    ["Worm Cult Hunter"] = {
        pieces  = {},
        exclude = { topLevelIndex = { [16] = true } }, -- weapon pages are Crown Store exclusive
        renames = {
        },
    },
    ["Y'ffre's Fallen-Wood"] = {
        pieces  = {},
        exclude = { topLevelIndex = { [16] = true } }, -- weapon pages are Crown Store exclusive
        renames = {
        },
    },
}

MSRT.StylePageIndex = {}
do
    for setName, data in pairs(MSRT.StyleSets) do
        for id, _ in pairs(data.pieces) do
            MSRT.StylePageIndex[id] = setName
        end
    end
end

---------------------------------------------------------------------------------------------
-- Undaunted style pages
---------------------------------------------------------------------------------------------
MSRT.UndauntedOverrides = {
    ["Maw of the Infernal"] = {
        total  = 2,
        pieces = {
            [8147] = "Mask",     -- 15 = 1
            [8148] = "Shoulder", -- 15 = 4
        },
    },
    ["Molag Kena"] = {
        total  = 2,
        pieces = {
            [5454] = "Mask",     -- 15 = 1
            [5455] = "Shoulder", -- 15 = 4
        },
    },
    ["Opal Scourge Harvester"] = {
        total  = 7,
        pieces = {
            [9827] = "Mask",     -- 15 = 1
            [9828] = "Shoulder", -- 15 = 4
            [9822] = "Maul",     -- 16 = 1
            [9826] = "Sword",    -- 16 = 2
            [9824] = "Shield",   -- 16 = 3
            [9823] = "Bow",      -- 16 = 4
            [9825] = "Staff",    -- 16 = 5
        },
    },
    ["Sellistrix"] = {
        total  = 2,
        pieces = {
            [5763] = "Mask",     -- 15 = 1
            [5764] = "Shoulder", -- 15 = 4
        },
    },
}

-- Undaunted tables for manual overrides
MSRT.UndauntedSets      = {}
MSRT.UndauntedIndex     = {}
do
    for setName, data in pairs(MSRT.UndauntedOverrides) do
        MSRT.UndauntedSets[setName] = data
        for id, _ in pairs(data.pieces) do
            MSRT.UndauntedIndex[id] = setName
        end
    end
end
