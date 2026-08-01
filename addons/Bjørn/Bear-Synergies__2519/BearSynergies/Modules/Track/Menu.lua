local BS = BearSynergies
local T = BS.Track

function T.BuildMenu()
  local PanelData = BS.GetModulePanelData("Track")

  local OptionsTable = {
    {
      type = "header",
      name = "|cFFFACDGeneral|r",
    },
    {
      type = "dropdown",
      name = "Orientation",
      choices = {"Horizontal", "Vertical"},
      getFunc = function() return T.SavedVariables.orientation end,
      setFunc = function(var)
                  T.SavedVariables.orientation = var
                  T.UpdateUI()
                end,
    },
    {
      type = "slider",
      name = "Size",
      min = 0,
      max = 100,
      step = 1,
      getFunc = function() return T.SavedVariables.size end,
      setFunc = function(value)
                  T.SavedVariables.size = value
                  T.UpdateUI()
                end,
      default = 48,
    },
    {
      type = "submenu",
      name = "|cFFFACDSynergies|r",
      controls = {
        {
          type = "checkbox",
          name = "Shackle",
          width = "half",
          getFunc = function() return T.SavedVariables.Synergies[1] end,
          setFunc = function(value)
                      T.SavedVariables.Synergies[1] = value
                      T.UpdateUI()
                    end,
        },
        {
          type = "texture",
          width = "half",
          image = "esoui/art/icons/ability_dragonknight_006.dds",
          imageWidth = 50,
          imageHeight = 50,
        },
        {
          type = "checkbox",
          name = "Ignite",
          width = "half",
          getFunc = function() return T.SavedVariables.Synergies[2] end,
          setFunc = function(value)
                      T.SavedVariables.Synergies[2] = value
                      T.UpdateUI()
                    end,
        },
        {
          type = "texture",
          width = "half",
          image = "esoui/art/icons/ability_dragonknight_010.dds",
          imageWidth = 50,
          imageHeight = 50,
        },
        {
          type = "checkbox",
          name = "Grave Robber",
          width = "half",
          getFunc = function() return T.SavedVariables.Synergies[3] end,
          setFunc = function(value)
                      T.SavedVariables.Synergies[3] = value
                      T.UpdateUI()
                    end,
        },
        {
          type = "texture",
          width = "half",
          image = "esoui/art/icons/ability_necromancer_004.dds",
          imageWidth = 50,
          imageHeight = 50,
        },
        {
          type = "checkbox",
          name = "Pure Agony",
          width = "half",
          getFunc = function() return T.SavedVariables.Synergies[4] end,
          setFunc = function(value)
                      T.SavedVariables.Synergies[4] = value
                      T.UpdateUI()
                    end,
        },
        {
          type = "texture",
          width = "half",
          image = "esoui/art/icons/ability_necromancer_010_b.dds",
          imageWidth = 50,
          imageHeight = 50,
        },
        {
          type = "checkbox",
          name = "Hidden Refresh",
          width = "half",
          getFunc = function() return T.SavedVariables.Synergies[5] end,
          setFunc = function(value)
                      T.SavedVariables.Synergies[5] = value
                      T.UpdateUI()
                    end,
        },
        {
          type = "texture",
          width = "half",
          image = "esoui/art/icons/ability_nightblade_015.dds",
          imageWidth = 50,
          imageHeight = 50,
        },
        {
          type = "checkbox",
          name = "Soul Leech",
          width = "half",
          getFunc = function() return T.SavedVariables.Synergies[6] end,
          setFunc = function(value)
                      T.SavedVariables.Synergies[6] = value
                      T.UpdateUI()
                    end,
        },
        {
          type = "texture",
          width = "half",
          image = "esoui/art/icons/ability_nightblade_018.dds",
          imageWidth = 50,
          imageHeight = 50,
        },
        {
          type = "checkbox",
          name = "Charged Lightning",
          width = "half",
          getFunc = function() return T.SavedVariables.Synergies[7] end,
          setFunc = function(value)
                      T.SavedVariables.Synergies[7] = value
                      T.UpdateUI()
                    end,
        },
        {
          type = "texture",
          width = "half",
          image = "esoui/art/icons/ability_sorcerer_storm_atronach.dds",
          imageWidth = 50,
          imageHeight = 50,
        },
        {
          type = "checkbox",
          name = "Conduit",
          width = "half",
          getFunc = function() return T.SavedVariables.Synergies[8] end,
          setFunc = function(value)
                      T.SavedVariables.Synergies[8] = value
                      T.UpdateUI()
                    end,
        },
        {
          type = "texture",
          width = "half",
         image = "esoui/art/icons/ability_sorcerer_lightning_splash.dds",
          imageWidth = 50,
          imageHeight = 50,
        },
        {
          type = "checkbox",
          name = "Nova",
          width = "half",
          getFunc = function() return T.SavedVariables.Synergies[9] end,
          setFunc = function(value)
                      T.SavedVariables.Synergies[9] = value
                      T.UpdateUI()
                    end,
        },
        {
          type = "texture",
          width = "half",
          image = "esoui/art/icons/ability_templar_nova.dds",
          imageWidth = 50,
          imageHeight = 50,
        },
        {
          type = "checkbox",
          name = "Purify",
          width = "half",
          getFunc = function() return T.SavedVariables.Synergies[10] end,
          setFunc = function(value)
                      T.SavedVariables.Synergies[10] = value
                      T.UpdateUI()
                    end,
        },
        {
          type = "texture",
          width = "half",
          image = "esoui/art/icons/ability_templar_cleansing_ritual.dds",
          imageWidth = 50,
          imageHeight = 50,
        },
        {
          type = "checkbox",
          name = "Harvest",
          width = "half",
          getFunc = function() return T.SavedVariables.Synergies[11] end,
          setFunc = function(value)
                      T.SavedVariables.Synergies[11] = value
                      T.UpdateUI()
                    end,
        },
        {
          type = "texture",
          width = "half",
          image = "esoui/art/icons/ability_warden_007.dds",
          imageWidth = 50,
          imageHeight = 50,
        },
        {
          type = "checkbox",
          name = "Icy Escape",
          width = "half",
          getFunc = function() return T.SavedVariables.Synergies[12] end,
          setFunc = function(value)
                      T.SavedVariables.Synergies[12] = value
                      T.UpdateUI()
                    end,
        },
        {
          type = "texture",
          width = "half",
          image = "esoui/art/icons/ability_warden_005_b.dds",
          imageWidth = 50,
          imageHeight = 50,
        },
        {
          type = "checkbox",
          name = "Feeding Frenzy",
          width = "half",
          getFunc = function() return T.SavedVariables.Synergies[13] end,
          setFunc = function(value)
                      T.SavedVariables.Synergies[13] = value
                      T.UpdateUI()
                    end,
        },
        {
          type = "texture",
          width = "half",
          image = "esoui/art/icons/ability_werewolf_005_b.dds",
          imageWidth = 50,
          imageHeight = 50,
        },
        {
          type = "checkbox",
          name = "Blood Altar",
          width = "half",
          getFunc = function() return T.SavedVariables.Synergies[14] end,
          setFunc = function(value)
                      T.SavedVariables.Synergies[14] = value
                      T.UpdateUI()
                    end,
        },
        {
          type = "texture",
          width = "half",
          image = "esoui/art/icons/ability_undaunted_001.dds",
          imageWidth = 50,
          imageHeight = 50,
        },
        {
          type = "checkbox",
          name = "Spiders",
          width = "half",
          getFunc = function() return T.SavedVariables.Synergies[15] end,
          setFunc = function(value)
                      T.SavedVariables.Synergies[15] = value
                      T.UpdateUI()
                    end,
        },
        {
          type = "texture",
          width = "half",
          image = "esoui/art/icons/ability_undaunted_003.dds",
          imageWidth = 50,
          imageHeight = 50,
        },
        {
          type = "checkbox",
          name = "Radiate",
          width = "half",
          getFunc = function() return T.SavedVariables.Synergies[16] end,
          setFunc = function(value)
                      T.SavedVariables.Synergies[16] = value
                      T.UpdateUI()
                    end,
        },
        {
          type = "texture",
          width = "half",
          image = "esoui/art/icons/ability_undaunted_002.dds",
          imageWidth = 50,
          imageHeight = 50,
        },
        {
          type = "checkbox",
          name = "Bone Shield",
          width = "half",
          getFunc = function() return T.SavedVariables.Synergies[17] end,
          setFunc = function(value)
                      T.SavedVariables.Synergies[17] = value
                      T.UpdateUI()
                    end,
        },
        {
          type = "texture",
          width = "half",
          image = "esoui/art/icons/ability_undaunted_005.dds",
          imageWidth = 50,
          imageHeight = 50,
        },
        {
          type = "checkbox",
          name = "Spear Shards/Combustion",
          width = "half",
          getFunc = function() return T.SavedVariables.Synergies[18] end,
          setFunc = function(value)
                      T.SavedVariables.Synergies[18] = value
                      T.UpdateUI()
                    end,
        },
        {
          type = "texture",
          width = "half",
          image = "esoui/art/icons/ability_undaunted_004.dds",
          imageWidth = 50,
          imageHeight = 50,
        },
      },
    },
  }

  LibAddonMenu2:RegisterAddonPanel(BS.name .. "Track", PanelData)
  LibAddonMenu2:RegisterOptionControls(BS.name .. "Track", OptionsTable)
end