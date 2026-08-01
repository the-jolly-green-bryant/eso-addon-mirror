  -------------------------------------------------------
  -- Idle Animations - Main File
  -- Stratejacket (Tierney11290) & @senorblackbean - 2017 & @FischyJones (FranklyBatman) 2020
  -------------------------------------------------------


local LAM2 = LibStub('LibAddonMenu-2.0')

function IA.CreateSettingsMenu()
  local panelData = {
    type = "panel",
    name = "Idle Animations Continued",
    displayName = ZO_HIGHLIGHT_TEXT:Colorize("Idle Animations Continued"),
    author = "Stratejacket (Tierney11290) & @senorblackbean - 2017 & @FischyJones (FranklyBatman) 2020",
    version = "1.5.4",
    slashCommand = "/iamenu",
    registerForRefresh = true,
    registerForDefaults = true,
  }
  local cntrlOptionsPanel = LAM2:RegisterAddonPanel("IdleAnimations_Options", panelData)

  local optionsTable = setmetatable({}, { __index = table })

  optionsTable:insert({
    type = "header",
    name = "General Options",
    registerForRefresh = true,
    registerForDefaults = true,
  })

  optionsTable:insert({
    type = "checkbox",
    name = "Enabled",
    tooltip = "Turns this addon on or off.",
    default = true,
    getFunc = function() return IA.SVC.Enabled end,
    setFunc = function(val) IA.SVC.Enabled = val end,
  })
  
  -- dynamically update dropdown
  profileTable = {} 
  for i, k in ipairs(Keys(emotes)) do
    profileTable[i] = k
  end
    
  optionsTable:insert({
    type = "dropdown",
    name = "Idle Animations Continued",
    tooltip = "Choose desired Idle Animation style.",
    choices = profileTable,
    width = "full",
    sort = "name-up",
    default = "Normal",
    getFunc = function() return IA.SVC.IdleProfile end,
    setFunc = function(val) IA.SVC.IdleProfile = val end,
  })

  optionsTable:insert({
    type = "checkbox",
    name = "Prevent Camera Spin",
    tooltip = "Prevents the Camera Spin when opening a menu.  HIGHLY recommended but not required.",
    default = true,
    getFunc = function() return IA.SVA.noCameraSpin end,
    setFunc = function(val) IA.SVA.noCameraSpin = val
      IA.noCameraSpin()
    end,
  })
  
  optionsTable:insert({
    type = "slider",
    name = "Idle Time",
    tooltip = "Adjusts how many seconds before idle animations begin.",
    min = 5,
    max = 60,
    step = 1,
    default = 25,
    warning = "Click Reload UI button for changes to take effect.",
    getFunc = function() 
      -- / 1000 to convert it to seconds
      return (IA.SVC.IdleTime / 1000) 
    end,
    setFunc = function(val) 
      -- * 1000 to convert it to milliseconds
      IA.SVC.IdleTime = (val * 1000)   
    end,
  })

  optionsTable:insert({
    type = "slider",
    name = "Time to run animations",
    tooltip = "Adjusts how many seconds should be spent doing an animation.",
    min = 20,
    max = 60,
    step = 1,
    default = 30,
    warning = "Click Reload UI button for changes to take effect.",
    getFunc = function() return (IA.SVC.AnimTime / 1000) end,
    setFunc = function(val) IA.SVC.AnimTime = (val * 1000) end,
  })

  optionsTable:insert({
    type = "slider",
    name = "Time between new animations",
    tooltip = "Adjusts how many seconds to pause between different animations (by animation time allotted).",
    min = 0,
    max = 60,
    step = 1,
    default = 0,
    warning = "Click Reload UI button for changes to take effect.",
    getFunc = function() return (IA.SVC.AnimPause / 1000) end,
    setFunc = function(val) IA.SVC.AnimPause = (val * 1000) end,
  })

  optionsTable:insert({
    type = "button",
    name = "Reload UI",
    tooltip = "Click to reload the UI.",
    width = "full",
    func = function() 
      ReloadUI("ingame")
    end,
  })

  optionsTable:insert({
    type = "submenu",
    name = "Event Animations",
    tooltip = "Animations Performed During Specific Events",
    width = "full",
		controls = setmetatable({}, { __index = table })
  })

  local optionsSubMenu = optionsTable[#optionsTable].controls

  optionsSubMenu:insert({
    type = "checkbox",
    name = "Level Up",
    tooltip = "Perform animation after Level Up",
    default = true,
    getFunc = function() return IA.SVA.LevelUp end,
    setFunc = function(val) IA.SVA.LevelUp = val
      IA.LevelUp()
    end,
  })

  optionsSubMenu:insert({
    type = "checkbox",
    name = "Cyrodiil Rank Increase",
    tooltip = "Perform animation after Cyrodiil Rank Increase",
    default = true,
    getFunc = function() return IA.SVA.AvARankUp end,
    setFunc = function(val) IA.SVA.AvARankUp = val
      IA.AvARankUp()
    end,
  })

  optionsSubMenu:insert({
    type = "checkbox",
    name = "Lore Book Collection",
    tooltip = "Perform animation after Completing a Lore Book Collection",
    default = true,
    getFunc = function() return IA.SVA.LoreBookCollection end,
    setFunc = function(val) IA.SVA.LoreBookCollection = val
      IA.LoreBookCollection()
    end,
  })

  optionsSubMenu:insert({
    type = "checkbox",
    name = "Lore Book",
    tooltip = "Perform animation after obtaining a Lore Book",
    default = true,
    getFunc = function() return IA.SVA.LoreBook end,
    setFunc = function(val) IA.SVA.LoreBook = val
      IA.LoreBook()
    end,
  })

  optionsSubMenu:insert({
    type = "checkbox",
    name = "Champion Point",
    tooltip = "Perform animation after Champion Point increase",
    default = true,
    getFunc = function() return IA.SVA.ChampionPoint end,
    setFunc = function(val) IA.SVA.ChampionPoint = val
      IA.ChampionPoint()
    end,
  })

  optionsSubMenu:insert({
    type = "checkbox",
    name = "Pledge of Mara Offer",
    tooltip = "Perform animation after Pledge of Mara Offering",
    default = true,
    getFunc = function() return IA.SVA.PledgeMaraOffer end,
    setFunc = function(val) IA.SVA.PledgeMaraOffer = val
      IA.PledgeMaraOffer()
    end,
  })

  optionsSubMenu:insert({
    type = "checkbox",
    name = "Pledge of Mara Result",
    tooltip = "Perform animation after Pledge of Mara Completion",
    default = true,
    getFunc = function() return IA.SVA.PledgeMaraResult end,
    setFunc = function(val) IA.SVA.PledgeMaraResult = val
      IA.PledgeMaraResult()
    end,
  })

  optionsSubMenu:insert({
    type = "checkbox",
    name = "Bank Space Purchase",
    tooltip = "Perform animation after Purchasing Bank Space",
    default = true,
    getFunc = function() return IA.SVA.BankBought end,
    setFunc = function(val) IA.SVA.BankBought = val
      IA.BankBought()
    end,
  })

  optionsSubMenu:insert({
    type = "checkbox",
    name = "Bag Space Purchase",
    tooltip = "Perform animation after Purchasing Bag Space",
    default = true,
    getFunc = function() return IA.SVA.BagBought end,
    setFunc = function(val) IA.SVA.BagBought = val
      IA.BagBought()
    end,
  })

  optionsSubMenu:insert({
    type = "checkbox",
    name = "Avenging Kill",
    tooltip = "Perform animation after an Avenging Kill",
    default = true,
    getFunc = function() return IA.SVA.Avenge end,
    setFunc = function(val) IA.SVA.Avenge = val
      IA.Avenge()
    end,
  })

  for i, profileName in ipairs(Keys(emotes)) do
    optionsTable:insert({
      type = "submenu",
      name = "Profile: " .. profileName,
      tooltip = "Manages specific emotes in the " .. profileName .. "  profile.",
      width = "full",
  		controls = setmetatable({}, { __index = table })
    })

    local optionsSubMenu = optionsTable[#optionsTable].controls
    for i, emoteset in ipairs(Keys(emotes[profileName])) do
      optionsSubMenu:insert({
        type = "checkbox",
        name = emoteset,
        tooltip = "Enables or disables this emote set.",
		width = "half",
        default = true,
        getFunc =
          function()
            -- Emoteset only exists in DisabledEmotesets if it is disabled, otherwise enabled.
            local option = true
            for k1, v in pairs(IA.SVA.DisabledEmotesets) do
              if k1 == profileName then
                for k2, v in pairs(IA.SVA.DisabledEmotesets[profileName]) do
                  if k2 == emoteset then
                    -- Exists therefore it is disabled.
                    option = false
                  end
                end
              end
            end
            return option
          end,
        setFunc =
          function(val)
            if val == false then
              local found = false
              for k, v in pairs(IA.SVA.DisabledEmotesets) do
                if k == profileName then
                  found = true
                  break
                end
              end
              if found == false then
                -- If this is the first disabled emote in this profile, create a table for it.
                IA.SVA.DisabledEmotesets[profileName] = {}
              end

              local found = false
              for k, v in pairs(IA.SVA.DisabledEmotesets[profileName]) do
                if k == emoteset then
                  found = true
                  break
                end
              end
              if found == false then
                -- This declares the emoteset to be disabled.
                IA.SVA.DisabledEmotesets[profileName][emoteset] = true
              end
            else
              for _, k1 in ipairs(Keys(IA.SVA.DisabledEmotesets)) do
                if k1 == profileName then
                  for _, k2 in ipairs(Keys(IA.SVA.DisabledEmotesets[profileName])) do
                    if k2 == emoteset then
                      -- table.remove() does nothing!  set to nil to remove it instead
                      IA.SVA.DisabledEmotesets[profileName][emoteset] = nil
                      break
                    end
                  end
                  if next(IA.SVA.DisabledEmotesets[profileName]) == nil then
                    -- If the profile has no disablements, remove it from configuration.
                    IA.SVA.DisabledEmotesets[profileName] = nil
                  end
                  break
                end
              end
            end
            return
          end,
      })
    end
  end

  LAM2:RegisterOptionControls("IdleAnimations_Options", optionsTable)
end