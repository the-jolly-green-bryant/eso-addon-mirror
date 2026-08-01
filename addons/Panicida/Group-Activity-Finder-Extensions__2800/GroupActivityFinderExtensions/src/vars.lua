local defaultVars = {
  textureSize = 25,
  collapse = 1,
  autoInvite = {
    enabled = false
  },
  dungeons = {
    autoMarkPledges = false,
    dailyPledgeMarker = {
      isIcon = false
    },
    handlePledgeQuest = true,
    donePledges = {},
    randomRewards = {}
  },
  battlegrounds = {
    randomRewards = {}
  },
  autoConfirm = {
    enabled = true,
    value = false,
    delay = 1000,
    loopSound = true
  },
  autoBind = {
    enabled = false
  },
  trials = {
    chests = {}
  },
  compatibility = {
    perfectPixel = false
  },
  developerMode = false,
  beta = false,
  map = {
    favourite = 284
  },
  armory = {
    currentBuildIndex = {}
  },
  currencyTracker = {
    day = 0,
    currencies = {}
  },
  ttcPrice = {
    enabled = false
  }
}

GroupActivityFinderExtensions = {
  name = "GroupActivityFinderExtensions",
  version = 5.7,
  varsVersion = 3,
  Localization = {},
  lang = "",
  Loc = function(var)
    return GroupActivityFinderExtensions.Localization[var] or
        var
  end,
  DefaultVars = defaultVars,
  SavedVars =
      defaultVars -- Value will be overwriten in main.lua with current values.
}

local GAFE = GroupActivityFinderExtensions

GAFE.Vars = {}

local function migration2()
  -- Default saved vars for migration version target
  local newVersion = 2
  local newDefault = {
    autoConfirm = {
      enabled = true,
      value = false
    }
  }

  ZO_SavedVars:NewAccountWide(GAFE.name .. "_Vars", newVersion, nil, newDefault,
    GetWorldName())
  local savedVars = GroupActivityFinderExtensions_Vars

  -- Set up locals
  local oldSavedVars = savedVars["Default"][GetDisplayName()]["$AccountWide"]
  local newSavedVars = savedVars[GetWorldName()][GetDisplayName()]
      ["$AccountWide"]

  -- Migrate values

  local autoConfirm = oldSavedVars.autoConfirm
  newSavedVars.autoConfirm.value = autoConfirm

  -- Clear obsolete data
  savedVars["Default"] = nil
end

local function migration3()
  -- Default saved vars for migration version target
  local newVersion = 3
  local newDefault = {
    textureSize = 25,
    collapse = GAFE.Constants.CollapseMode.Group, -- FIXME
    autoInvite = {
      enabled = false
    },
    dungeons = {
      autoMarkPledges = false,
      dailyPledgeMarker = {
        isIcon = true
      },
      handlePledgeQuest = true,
      donePledges = {}
    },
    autoConfirm = {
      enabled = true,
      value = false
    },
    trials = {
      chests = {}
    },
    compatibility = {
      perfectPixel = false
    }
  }

  -- Set up locals
  local savedVars = GroupActivityFinderExtensions_Vars
  local oldSavedVars = savedVars[GetWorldName()][GetDisplayName()]
      ["$AccountWide"]
  local newSavedVars = ZO_SavedVars:NewAccountWide(GAFE.name .. "_Vars",
    newVersion, nil, newDefault, GetWorldName())

  -- Migrate values
  local autoConfirmEnabled = oldSavedVars.autoConfirm.enabled
  newSavedVars.autoConfirm.enabled = autoConfirmEnabled

  local autoConfirmValue = oldSavedVars.autoConfirm.value
  newSavedVars.autoConfirm.value = autoConfirmValue
end

local migrations = {
  [2] = migration2,
  [3] = migration3,
}

function GAFE.Vars.Migrate()
  local function GetSavedVarsVersion(savedVars)
    if savedVars["Default"] and
        savedVars["Default"][GetDisplayName()] and
        savedVars["Default"][GetDisplayName()]["$AccountWide"] and
        savedVars["Default"][GetDisplayName()]["$AccountWide"]["version"] == 1 then
      return savedVars["Default"][GetDisplayName()]["$AccountWide"]["version"]
    end

    if savedVars[GetWorldName()] and
        savedVars[GetWorldName()][GetDisplayName()] and
        savedVars[GetWorldName()][GetDisplayName()]["$AccountWide"] and
        savedVars[GetWorldName()][GetDisplayName()]["$AccountWide"]["version"] then
      return savedVars[GetWorldName()][GetDisplayName()]["$AccountWide"]
          ["version"]
    end

    return GAFE.varsVersion
  end

  -- Get old version
  local oldSavedVars = GroupActivityFinderExtensions_Vars
  local oldVersion = GetSavedVarsVersion(oldSavedVars)

  -- Apply all migrations
  for version = oldVersion + 1, GAFE.varsVersion do
    migrations[version]()
  end
end
