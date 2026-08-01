local BS = BearSynergies
local B = BS.Block

function B.BuildMenu()
  local PanelData = BS.GetModulePanelData("Block")

  local OptionsTable = {
    -- General Settings
    {
      type = "header",
      name = "|cFFFACDGeneral|r",
    },
    {
      type = "checkbox",
      name = "Lokke Mode",
      width = "half",
      tooltip = "Toggling this on will prevent you from being able to use synergies if less than five pieces of Lokkestiiz is active. If no Lokke pieces equipped this setting will be ignored.",
      getFunc = function() return B.SavedVariables.isLokke end,
      setFunc = function(value) B.SavedVariables.isLokke = value end,
    },
    {
      type = "checkbox",
      name = "Alkosh Mode",
      width = "half",
      tooltip = "Toggling this on will prevent you from being able to use synergies if less than five pieces of Alkosh is active. If no Alkosh pieces equipped this setting will be ignored.",
      getFunc = function() return B.SavedVariables.isAlkosh end,
      setFunc = function(value) B.SavedVariables.isAlkosh = value end,
    },
    {
      type = "checkbox",
      name = "Resource Check",
      tooltip = "Toggling this on will prevent you from being able to use synergies if your current main resource is higher than the threshold.",
      getFunc = function() return B.SavedVariables.isResource end,
      setFunc = function(value) B.SavedVariables.isResource = value end,
    },
    {
      type = "slider",
      name = "Resource Check Threshold",
      min = 0,
      max = 100,
      step = 1,
      getFunc = function() return B.SavedVariables.resourceThreshold end,
      setFunc = function(value) B.SavedVariables.resourceThreshold = value end,
      disabled = function() return not B.SavedVariables.isResource end,
    },

    -- Class Settings
    {
      type = "submenu",
      name = "|cFFFACDClass Synergies|r",
      controls = {
        -- Dragonknight Settings
        {
          type = "header",
          name = "|cFFFACDDragonknight|",
        },
        {
          type = "checkbox",
          name = "Shackle",
          width = "half",
          tooltip = "Toggling this off will prevent you from being able to use the Shackle synergy, provided by the Dragonknight Standard skill.",
          getFunc = function() return B.SavedVariables[67717] end,
          setFunc = function(value) B.SavedVariables[67717] = value end,
        },
        {
          type = "checkbox",
          name = "Ignite",
          width = "half",
          tooltip = "Toggling this off will prevent you from being able to use the Ignite synergy, provided by the Dark Talons skill.",
          getFunc = function() return B.SavedVariables[32974] end,
          setFunc = function(value) B.SavedVariables[32974] = value end,
        },

        -- Necromancer Settings
        {
          type = "header",
          name = "|cFFFACDNecromancer|r",
        },
        {
          type = "checkbox",
          name = "Grave Robber",
          width = "half",
          tooltip = "Toggling this off will prevent you from being able to use the Grave Robber synergy, provided by the Boneyard skill.",
          getFunc = function() return B.SavedVariables[115567] end,
          setFunc = function(value) B.SavedVariables[115567] = value end,
        },
        {
          type = "checkbox",
          name = "Pure Agony",
          width = "half",
          tooltip = "Toggling this off will prevent you from being able to use the Pure Agony synergy, provided by the Agony Totem skill.",
          getFunc = function() return B.SavedVariables[118610] end,
          setFunc = function(value) B.SavedVariables[118610] = value end,
        },

        -- Nightblade Settings
        {
          type = "header",
          name = "|cFFFACDNightblade|r",
        },
        {
          type = "checkbox",
          name = "Hidden Refresh",
          width = "half",
          tooltip = "Toggling this off will prevent you from being able to use the Hidden Refresh synergy, provided by the Consuming Darkness skill.",
          getFunc = function() return B.SavedVariables[37729] end,
          setFunc = function(value) B.SavedVariables[37729] = value end,
        },
        {
          type = "checkbox",
          name = "Soul Leech",
          width = "half",
          tooltip = "Toggling this off will prevent you from being able to use the Soul Leech synergy, provided by the Soul Shred skill.",
          getFunc = function() return B.SavedVariables[25170] end,
          setFunc = function(value) B.SavedVariables[25170] = value end,
        },

        -- Sorcerer Settings
        {
          type = "header",
          name = "|cFFFACDSorcerer|r",
        },
        {
          type = "checkbox",
          name = "Charged Lightning",
          width = "half",
          tooltip = "Toggling this off will prevent you from being able to use the Charged Lightning synergy, provided by the Summon Storm Atronach skill.",
          getFunc = function() return B.SavedVariables[121059] end,
          setFunc = function(value) B.SavedVariables[121059] = value end,
        },
        {
          type = "checkbox",
          name = "Conduit",
          width = "half",
          tooltip = "Toggling this off will prevent you from being able to use the Conduit synergy, provided by the Lightning Splash skill.",
          getFunc = function() return B.SavedVariables[43769] end,
          setFunc = function(value) B.SavedVariables[43769] = value end,
        },

        -- Templar Settings
        {
          type = "header",
          name = "|cFFFACDTemplar|r",
        },
        {
          type = "checkbox",
          name = "Spear Shards",
          width = "half",
          tooltip = "Toggling this off will prevent you from being able to use the Blessed Shards and Holy Shards synergies, provided by the Spear Shards and morphs skills.",
          getFunc = function() return B.SavedVariables[94973], B.SavedVariables[95928] end,
          setFunc = function(value)
            B.SavedVariables[94973] = value
            B.SavedVariables[95928] = value
          end,
        },
        {
          type = "checkbox",
          name = "Nova",
          width = "half",
          tooltip = "Toggling this off will prevent you from being able to use the Supernova and Gravity Crush synergies, provided by the Nova and morphs skills.",
          getFunc = function() return B.SavedVariables[48939], B.SavedVariables[31603] end,
          setFunc = function(value)
            B.SavedVariables[48939] = value
            B.SavedVariables[31603] = value
          end,
        },
        {
          type = "checkbox",
          name = "Purify",
          width = "half",
          tooltip = "Toggling this off will prevent you from being able to use the Purify synergy, provided by the Cleansing Ritual skill.",
          getFunc = function() return B.SavedVariables[22270] end,
          setFunc = function(value) B.SavedVariables[22270] = value end,
        },

        -- Warden Settings
        {
          type = "header",
          name = "|cFFFACDWarden|r",
        },
        {
          type = "checkbox",
          name = "Harvest",
          width = "half",
          tooltip = "Toggling this off will prevent you from being able to use the Harvest synergy, provided by the Healing Seed skill.",
          getFunc = function() return B.SavedVariables[85572] end,
          setFunc = function(value) B.SavedVariables[85572] = value end,
        },
        {
          type = "checkbox",
          name = "Icy Escape",
          width = "half",
          tooltip = "Toggling this off will prevent you from being able to use the Icy Escape synergy, provided by the Frozen Retreat skill.",
          getFunc = function() return B.SavedVariables[88892] end,
          setFunc = function(value) B.SavedVariables[88892] = value end,
        },
      },
    },

    -- Undaunted Settings
    {
      type = "submenu",
      name = "|cFFFACDUndaunted Synergies|r",
      controls = {
        {
          type = "checkbox",
          name = "Blood Altar",
          width = "half",
          tooltip = "Toggling this off will prevent you from being able to use the Blood Funnel and Blood Feast synergies, provided by the Blood Altar and morphs skills.",
          getFunc = function() return B.SavedVariables[39519], B.SavedVariables[41966] end,
          setFunc = function(value)
            B.SavedVariables[39519] = value
            B.SavedVariables[41966] = value
          end,
        },
        {
          type = "checkbox",
          name = "Spiders",
          width = "half",
          tooltip = "Toggling this off will prevent you from being able to use the Spawn Broodlings, Black Widows and Arachnophobia synergies, provided by the Trapping Webs and morphs skills.",
          getFunc = function() return B.SavedVariables[39451], B.SavedVariables[41997], B.SavedVariables[42019] end,
          setFunc = function(value)
            B.SavedVariables[39451] = value
            B.SavedVariables[41997] = value
            B.SavedVariables[42019] = value
          end,
        },
        {
          type = "checkbox",
          name = "Radiate",
          width = "half",
          tooltip = "Toggling this off will prevent you from being able to use the Radiate synergy, provided by the Inner Fire skill.",
          getFunc = function() return B.SavedVariables[41838] end,
          setFunc = function(value) B.SavedVariables[41838] = value end,
        },
        {
          type = "checkbox",
          name = "Bone Shield",
          width = "half",
          tooltip = "Toggling this off will prevent you from being able to use the Bone Wall and Spinal Surge synergies, provided by the Bone Shield and morphs skills.",
          getFunc = function() return B.SavedVariables[39379], B.SavedVariables[42198] end,
          setFunc = function(value)
            B.SavedVariables[39379] = value
            B.SavedVariables[42198] = value
          end,
        },
        {
          type = "checkbox",
          name = "Combustion",
          width = "half",
          tooltip = "Toggling this off will prevent you from being able to use the Combustion synergy, provided by the Necrotic Orb and Mystic Orb skills.",
          getFunc = function() return B.SavedVariables[39301] end,
          setFunc = function(value) B.SavedVariables[39301] = value end,
        },
        {
          type = "checkbox",
          name = "Healing Combustion",
          width = "half",
          tooltip = "Toggling this off will prevent you from being able to use the Healing Combustion synergy, provided by the Energy Orb skill.",
          getFunc = function() return B.SavedVariables[63507] end,
          setFunc = function(value) B.SavedVariables[63507] = value end,
        },
      },
    },

    -- Arena Settings
    {
      type = "submenu",
      name = "|cFFFACDArena Synergies|r",
      controls = {
        {
          type = "checkbox",
          name = "Sigil of Defense",
          width = "half",
          tooltip = "Toggling this off will prevent you from being able to use the Sigil of Defense synergy, provided in Maelstrom Arena and Blackrose Prison.",
          getFunc = function() return B.SavedVariables[71951] end,
          setFunc = function(value) B.SavedVariables[71951] = value end,
        },
        {
          type = "checkbox",
          name = "Sigil of Haste",
          width = "half",
          tooltip = "Toggling this off will prevent you from being able to use the Sigil of Haste synergy, provided in Maelstrom Arena.",
          getFunc = function() return B.SavedVariables[71953] end,
          setFunc = function(value) B.SavedVariables[71953] = value end,
        },
        {
          type = "checkbox",
          name = "Sigil of Healing",
          width = "half",
          tooltip = "Toggling this off will prevent you from being able to use the Sigil of Healing synergy, provided in Maelstrom Arena and Blackrose Prison.",
          getFunc = function() return B.SavedVariables[71949] end,
          setFunc = function(value) B.SavedVariables[71949] = value end,
        },
        {
          type = "checkbox",
          name = "Sigil of Power",
          width = "half",
          tooltip = "Toggling this off will prevent you from being able to use the Sigil of Power synergy, provided in Maelstrom Arena.",
          getFunc = function() return B.SavedVariables[71902] end,
          setFunc = function(value) B.SavedVariables[71902] = value end,
        },
        {
          type = "checkbox",
          name = "Sigil of Resurrection",
          width = "half",
          tooltip = "Toggling this off will prevent you from being able to use the Sigil of Resurrection synergy, provided in Blackrose Prison.",
          getFunc = function() return B.SavedVariables[112909] end,
          setFunc = function(value) B.SavedVariables[112909] = value end,
        },
        {
          type = "checkbox",
          name = "Sigil of Sustain",
          width = "half",
          tooltip = "Toggling this off will prevent you from being able to use the Sigil of Sustain synergy, provided in Blackrose Prison.",
          getFunc = function() return B.SavedVariables[112872] end,
          setFunc = function(value) B.SavedVariables[112872] = value end,
        },
      },
    },

    -- Trial Settings
    {
      type = "submenu",
      name = "|cFFFACDTrial Synergies|r",
      controls = {
        -- Craglorn Settings
        {
          type = "header",
          name = "|cFFFACDCraglorn Trials|r",
        },
        {
          type = "checkbox",
          name = "Destructive Outbreak Dialog",
          tooltip = "Toggling this on will prompt a message on-screen whenever you get the fossilize mechanic, warning you of the danger it poses.",
          getFunc = function() return B.SavedVariables.blockDO end,
          setFunc = function(value) B.SavedVariables.blockDO = value end,
        },

        -- Cloudrest Settings
        {
          type = "header",
          name = "|cFFFACDCloudrest|r",
        },
        {
          type = "checkbox",
          name = "Gateway",
          tooltip = "Toggling this off will prevent you from being able to use the portal synergy.",
          getFunc = function() return B.SavedVariables[103489] end,
          setFunc = function(value) B.SavedVariables[103489] = value end,
        },
      },
    },

    -- Other
    {
      type = "submenu",
      name = "|cFFFACDMiscellaneous|r",
      controls = {
        {
          type = "checkbox",
          name = "Feeding Frenzy",
          tooltip = "Toggling this off will prevent you from being able to use the Feeding Frenzy synergy, provided by the Howl of Despair skill.",
          getFunc = function() return B.SavedVariables[58813] end,
          setFunc = function(value) B.SavedVariables[58813] = value end,
        },
      },
    },
  }

  LibAddonMenu2:RegisterAddonPanel(BS.name .. "Block", PanelData)
  LibAddonMenu2:RegisterOptionControls(BS.name .. "Block", OptionsTable)
end