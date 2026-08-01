--------------------------------------------------------------------------------
-- UI CONFIGURATION - DEFINES THE STRUCTURE OF ALL MODULES
--------------------------------------------------------------------------------

-- Centralized configuration for all UI modules
local UIModuleConfig = {
    -- Scale configuration
    DEFAULT_SCALE = 20,
    SCALE_FORMULA = {
        MIN_SCALE = 0.75,   -- Minimum Scale (customScale = 0)
        MAX_SCALE = 1.5,    -- Maximum Scale (customScale = 100)
        DEFAULT_VALUE = 20  -- Value that corresponds to 1.0x
    },

    -- Available layout types
    LAYOUTS = {
        SINGLE_RIGHT = "single_right",         -- 1 value + label on the right
        SINGLE_LEFT = "single_left",           -- 1 value + label on the left  
        DUAL_HORIZONTAL = "dual_horizontal",   -- 2 values side by side
        DUAL_STACKED = "dual_stacked"          -- 2 values stacked
    },

    -- Standard spacing
    SPACING = {
        LABEL_VALUE = 5,    -- space between label and value
        DUAL_VALUES = 15,   -- space between two values
        MARGIN = 8          -- margin from the edges
    },

    -- Configuration for each module
    MODULES = {
        armorskull = {
            layout = "dual_horizontal",
            baseSize = { w = 205, h = 45 },
            fields = {
                { name = "SpellResist", label = "SR", position = "left" },
                { name = "PhysicalResist", label = "PR", position = "right" }
            }
        },

        hybridarmorskull = {
            layout = "single_right", 
            baseSize = { w = 120, h = 45 },
            fields = {
                { name = "Resist", label = "???", dynamic_label = true }
            }
        },

        powerskull = {
            layout = "single_right",
            baseSize = { w = 120, h = 45 },
            fields = {
                { name = "Power", label = "PWR" }
            }
        },

        critskull = {
            layout = "dual_horizontal",
            baseSize = { w = 205, h = 45 },
            fields = {
                { name = "CritChance", label = "CC", position = "left" },
                { name = "CritDamage", label = "CD", position = "right" }
            }
        },

        penskull = {
            layout = "single_right",
            baseSize = { w = 120, h = 45 },
            fields = {
                { name = "Penetration", label = "PEN" }
            }
        },

        healthskull = {
            layout = "single_right",
            baseSize = { w = 120, h = 45 },
            fields = {
                { name = "Recovery", label = "HR" }
            }
        },

        magskull = {
            layout = "single_right", 
            baseSize = { w = 120, h = 45 },
            fields = {
                { name = "Recovery", label = "MR" }
            }
        },

        stamskull = {
            layout = "single_right",
            baseSize = { w = 120, h = 45 },
            fields = {
                { name = "Recovery", label = "SR" }
            }
        },

        critresiskull = {
            layout = "dual_stacked",
            baseSize = { w = 100, h = 90 },
            fields = {
                { name = "CritResistValue", label = "CR", position = "top" },
                { name = "CritResistPercent", label = "  ", position = "bottom" }
            }
        }
    }
}

-- Export configuration globally
_G.UILayoutConfig = UIModuleConfig
_G.ModuleUIConfig = UIModuleConfig.MODULES

return UIModuleConfig
