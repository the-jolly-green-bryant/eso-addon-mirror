local GST = GroupSynergyTracker

GST.defaults = {
     growth_direction = "Down",
     cooldownBars = true,
     frame_scale = 1,
     offsetX = GuiRoot:GetWidth() / 2,
     offsetY = GuiRoot:GetHeight() / 2,
     customPlayer = "",
     showTanks = false,
     showHealers = false,
     showDPS = true,
     useHodorReflexes = true,
     alternateFrameColors = true,
     tankColor = {120/255, 0/255, 0/255},
     healerColor = {36/255, 135/255, 137/255},
     dpsColor = {0, 0, 0},

     trackedSynergies = {
          [1] = "",
          [2] = "",
          [3] = "",
          [4] = "",
          [5] = "",
          [6] = "",
          [7] = "",
          [8] = "",
     },
     blacklist = {
          [1] = "|c513DEBClick to View Blacklist|r"
     },

     debug = {
          showCountdowns = false,
          unitIndexing = false,
          showTakenSynergies = {
               orbs = {
                    active = false,
                    color = "87C750",
               },
               conduit = {
                    active = false,
                    color = "507BC7",
               },
               harvest = {
                    active = false,
                    color = "9F53CF",
               },
               purify = {
                    active = false,
                    color = "FFF200",
               },
               boneyard = {
                    active = false,
                    color = "FF9100",
               },
               pure_agony = {
                    active = false,
                    color = "C2139F",
               },
               bone_shield = {
                    active = false,
                    color = "13C2B0",
               },
               altar = {
                    active = false,
                    color = "C22B13",
               },
               spiders = {
                    active = false,
                    color = "6B8E23"
               }
          },
     },
}
