local LAM2      = LibAddonMenu2

-- constants for settings
PetKennel.SETTINGS = {
    WRIT_BOARD       = { ord=1 , title="Crafting Writ Boards"        }
,   CRAFTING_STATION = { ord=2 , title="Crafting Stations"           }
,   TURN_IN_CRATE    = { ord=3 , title="Writ Turn-in Crates"         }
,   BANKER           = { ord=4 , title="Banker"                      }
,   MERCHANT         = { ord=5 , title="Merchants and Guild Traders" }
,   ROLIS            = { ord=6 , title="Rolis Hlaalu"                }
,   DUNGEON          = { ord=7 , title="Dungeons & Delves"           }
,   KEY_BINDING      = { ord=8 , title="Key Binding"                 }
}
for key, row in pairs(PetKennel.SETTINGS) do
    row.key = key
end

function PetKennel:CreateSettingsUI()
    self.saved_vars.enable = self.saved_vars.enable or {}

    local lam_addon_id = "PetKennel_LAM"
    local panelData = {
        type                = "panel",
        name                = self.name,
        displayName         = self.name,
        author              = "ziggr",
        version             = self.version,
        registerForRefresh  = false,
        registerForDefaults = false,
    }
    LAM2:RegisterAddonPanel(lam_addon_id, panelData)

    local t = {}
    for key, row in pairs(PetKennel.SETTINGS) do
        t[row.ord] = row
    end

    local options_data = {  { type      = "description"
                            , text      = "Automatically dismisses pets when they could be in your or other players' way."
                            }

                         ,  { type      = "description"
                            , width     = "half"
                            , title     = "Combat Pets"
                            }
                         ,  { type      = "description"
                            , width     = "half"
                            , title     = "Non-Combat Pets"
                            }
                         }

                        -- Leading whitespace is trimmed. If we want to retain
                        -- leading whitespeace, bracket it with pointless color
                        -- codes.
    local indent = "|c000000       |r"
    for _,row in ipairs(t) do
        self.saved_vars.enable[row.key] = self.saved_vars.enable[row.key] or {}
        local cb1 = { type      = "checkbox"
                    , width     = "half"
                    , name      = indent .. row.title
                    , getFunc   = function()
                                    return self.saved_vars.enable[row.key].combat ~= false
                                  end
                    , setFunc   = function(e)
                                    self.saved_vars.enable[row.key].combat = e
                                  end
                    }
        local cb2 = { type      = "checkbox"
                    , width     = "half"
                    , getFunc   = function()
                                    return self.saved_vars.enable[row.key].non_combat ~= false
                                  end
                    , setFunc   = function(e)
                                    self.saved_vars.enable[row.key].non_combat = e
                                  end
                    }
        table.insert(options_data, cb1)
        table.insert(options_data, cb2)
    end

    LAM2:RegisterOptionControls(lam_addon_id, options_data)
end
