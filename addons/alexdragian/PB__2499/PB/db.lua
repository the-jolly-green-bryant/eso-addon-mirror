function PB.LoadDatabase()
  local PBGuildVarDefaults = {
    options = {
      mapFlags = {
        homePreviewsZone = false,
        homePreviews = false,
        ownedHomes = true,
        dungeons = true,
        trials = true,
        waypoints = true
      },
      optionFlags = {
        hideMapHomePreview = true,
        hideMapDungeons = false
      },
      vendor = {
        hideCrafted = false,
        hideUnsellable = false,
        hideTransmutation = false,
        hideReconstruction = false
      },
      deconstruct = {
        hideCrafted = false,
        hideTransmutation = false,
        hideReconstruction = false
      }
    }
  }

  local PBGuildRosterDefaults = {
    options = {
      guilds = {}
    },
    guildData = {}
  }

  PB.db = {
    roster = ZO_SavedVars:NewAccountWide("PB_SavedRosterData", 4, nil, PBGuildRosterDefaults ),
    default = ZO_SavedVars:NewAccountWide("PB_SavedVariables", 9, nil, PBGuildVarDefaults ),
  }
end