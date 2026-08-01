JokerData = JokerData or {} -- content
JokerData.Config = JokerData.Config or {} -- content-specific config (commands, etc)
JokerL = JokerL or {} -- i18n
Joker = Joker or {} -- vars, defaults

local L = Joker.locale -- sets our locale
local Util = JokerUtilityFn or {} -- utility functions used throughout
local Data = JokerDataFn or {} -- data and content processing & display

local panelOptions = {}
local optionIndent = "   " -- Spacer/indent for submenu options
local optionIndent_Title = " " -- Spacer/indent for submenu titles
local optionIndent_Button = "" -- Spacer/indent for buttons

-- Local debugging utility
local function debugLog(message)
  if Joker and Joker.saved and Joker.saved.internal and Joker.saved.internal.showDebug and Joker.saved.internal.showDebug > 0 then
    d('Joker: ' .. message)
  end
end

-- settingsPanelMain
-- Data; Creates series of controls for main/basic options
function Data.settingsPanelMain()
  
  local thisPanelSettings = {
    {
      type			  = "checkbox",
      name			  = optionIndent .. L.Joker_Options_Periodic, -- Toggles Periodic Jokes
      tooltip			= L.Joker_Options_Periodic_Tip,
      getFunc			= function() return Joker.saved.periodic.jokes_enable > 0 end,
      setFunc			= function() 
                      Data.togglePeriodicEvents('jokes')
                      Data.runPeriodicEvents('jokes', {
                        joke = function() Joker.AnyJoke('', 1) end
                        }, 1)
                    end,
      width			  = "full",
      default			= function() return Joker.saved.periodic.jokes_enable > 0 end,
    },
    {
      type			  = "slider",
      name			  = optionIndent .. L.Joker_Options_PeriodicFrequency,
      tooltip			= L.Joker_Options_PeriodicFrequency_Tip,
      min         = 1,
      max         = 25,
      step        = 1,
      getFunc			= function() return Joker.saved.periodic.jokes_frequency end,
      setFunc			= function(value) Joker.saved.periodic.jokes_frequency = value end,
      width			  = "full",
      default			= Joker.saved.periodic.jokes_frequency,
      disabled    = function() return not Joker.saved.periodic.jokes_enable end,
    },
    {
      type			  = "checkbox",
      name			  = optionIndent .. L.Joker_Options_Periodic_Health, -- Toggles Periodic Health Reminders
      tooltip			= L.Joker_Options_Periodic_Health_Tip,
      getFunc			= function() return Joker.saved.periodic.health_enable end,
      setFunc			= function() Data.togglePeriodicEvents('health') end,
      width			  = "full",
      default			= Joker.saved.periodic.health_enable,
      disabled    = function() return true end,
    },
    {
      type			  = "checkbox",
      name			  = optionIndent .. L.Joker_Options_Rolls_PostToChat, -- Toggles Rolls being posted to chat
      tooltip			= L.Joker_Options_Rolls_PostToChat_Tooltip,
      getFunc			= function() return Joker.saved.rolls.postToChat > 0 end,
      setFunc			= function() Data.toggleRollsToChat() end,
      width			  = "full",
      default			= Joker.saved.rolls.postToChat
    },
    {
      type			  = "checkbox",
      name			  = optionIndent .. "Show Q/A Prefixes in Trivia", -- Toggles Q: and A: prefixes in trivia
      tooltip			= "When enabled, trivia will show 'Q:' and 'A:' prefixes. When disabled, shows just the question and answer.",
      getFunc			= function() return Joker.saved.enable.triviaPrefixes and Joker.saved.enable.triviaPrefixes > 0 end,
      setFunc			= function(value) 
                      if Joker.saved.enable.triviaPrefixes and Joker.saved.enable.triviaPrefixes > 0 then
                        Joker.saved.enable.triviaPrefixes = 0
                      else
                        Joker.saved.enable.triviaPrefixes = 1
                      end
                    end,
      width			  = "full",
      default			= function() return Joker.defaults.enable.triviaPrefixes > 0 end
    }
  }

  return thisPanelSettings
end

-- generateRandomPoolOptions
-- Data; Creates series of controls for random pool (auto-gens based on available options)
function Data.settingsPanelPool()
  
  local thisPanelSettings = {
  }

  -- Description Part A
  table.insert(thisPanelSettings, {
    type = "description",
    text = L.Joker_Options_Categories_Description_A,
    width = "full",
  })

  -- Divider
  table.insert(thisPanelSettings, {
    type = "divider",
    width = "full",
  })

  -- Description Part B
  table.insert(thisPanelSettings, {
    type = "description",
    text = L.Joker_Options_Categories_Description_B,
    width = "full",
  })

  -- Sort pool alphabetically
  table.sort(Joker.saved.randomPool.enabledCategories, function(a,b) return a < b end)

  for _, categoryName in ipairs(Joker.saved.randomPool.enabledCategories) do
    -- Don't add specific things
    if categoryName ~= 'ReadyChecks' and categoryName ~= 'CustomReadyChecks' and categoryName ~= 'CustomJokes' then
      table.insert(thisPanelSettings, {
        type			  = "checkbox",
        name			  = optionIndent .. Util.colorize((Joker.saved.activeJokes[categoryName] or 'Unknown Category')) .. Data.isNSFW(categoryName, true) .. ' (' .. Joker.saved.count.categories[categoryName] ..' ' .. L.Joker_Items .. ')', -- Category name + number of items in category
        tooltip			= L.Joker_Options_Categories_ItemTooltip .. JokerData.Config[categoryName].command,
        getFunc			= function() return Data.randomPoolGet(categoryName) end,
        setFunc			= function() Data.randomPoolSet(categoryName) end,
        width			  = "full",
        default			= function() return Util.setContainsValue(Joker.defaults.randomPool.enabledCategories, categoryName) and not Util.setContainsValue(Joker.defaults.randomPool.blacklist, categoryName) end,
        disabled    = function() return not Joker.saved.activeJokes[categoryName] end,
      })
    end
    
  end

  table.insert(thisPanelSettings, {
    type			  = "button",
    name			  = optionIndent_Button .. "Reset to defaults", -- Reset random pool blacklist to default
    func			  = function () Data.randomPoolSetDefault() end,
    width			  = "half",
  })

  return thisPanelSettings
end

-- generateRandomPoolTriviaOptions
-- Data; Creates series of controls for trivia random pool (auto-gens based on available options)
function Data.settingsPanelPoolTrivia()
  
  local thisPanelSettings = {
  }

  -- Description Part A
  table.insert(thisPanelSettings, {
    type = "description",
    text = "Choose which trivia categories can appear when using /trivia (without specifying a category).",
    width = "full",
  })

  -- Divider
  table.insert(thisPanelSettings, {
    type = "divider",
    width = "full",
  })

  -- Description Part B
  table.insert(thisPanelSettings, {
    type = "description",
    text = "You can still use category-specific commands (like /trivia-eso) even if a category is disabled here.",
    width = "full",
  })

  -- Sort pool alphabetically
  table.sort(Joker.saved.randomPoolTrivia.enabledCategories, function(a,b) return a < b end)

  for _, categoryName in ipairs(Joker.saved.randomPoolTrivia.enabledCategories) do
    -- Add all trivia categories
    if categoryName ~= 'CustomTrivia' then
      table.insert(thisPanelSettings, {
        type			  = "checkbox",
        name			  = optionIndent .. Util.colorize((Joker.saved.activeTrivia[categoryName] or 'Unknown Category')) .. ' (' .. Joker.saved.count.triviaCategories[categoryName] ..' items)', -- Category name + number of items in category
        tooltip			= "Use /" .. JokerData.Config[categoryName].command .. " to get trivia from this category",
        getFunc			= function() return Data.randomPoolTriviaGet(categoryName) end,
        setFunc			= function() Data.randomPoolTriviaSet(categoryName) end,
        width			  = "full",
        default			= function() return Util.setContainsValue(Joker.defaults.randomPoolTrivia.enabledCategories, categoryName) and not Util.setContainsValue(Joker.defaults.randomPoolTrivia.blacklist, categoryName) end,
        disabled    = function() return not Joker.saved.activeTrivia[categoryName] end,
      })
    end
    
  end

  table.insert(thisPanelSettings, {
    type			  = "button",
    name			  = optionIndent_Button .. "Reset to defaults", -- Reset random pool blacklist to default
    func			  = function () Data.randomPoolTriviaSetDefault() end,
    width			  = "half",
  })

  return thisPanelSettings
end


-- Compile Addon Settings menu.
function Joker.LoadSettings()
    debugLog('Running Joker.LoadSettings()')
    local LAM = LibAddonMenu2

    local panelData = {
        type = "panel",
        name = L.Joker_Title,
        displayName = Util.colorize(L.Joker_Title),
        author = Util.colorize(Joker.author, "AA00FF"),
        version = Util.colorize(Joker.version, "AA00FF"),
        slashCommand = "/joker",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    --[[
      Intro Section
    ]]
    table.insert(panelOptions, {
      type = "description",
      text = L.Joker_Intro_Status_Prefix .. Util.colorize(Util.formatNumber(Joker.saved.count.seenAllTime or 0)) .. " " .. L.Joker_Intro_Status_Middle .. " " .. Util.colorize(Util.formatNumber(Joker.saved.count.loaded)) .. " " .. L.Joker_Intro_Status_Suffix,
      width = "full",
    })


    --[[
      Main Settings: Periodic Events, Toggle NSFW, & Other Options
    ]]
    local settingsPanelMain = Data.settingsPanelMain()
    table.insert(panelOptions, {
      type = "submenu",
      name = optionIndent_Title .. L.Joker_Options_Title,
      tooltip = L.Joker_Options_Title_Tooltip,
      controls = settingsPanelMain
    })


    --[[
      Random Pool Settings: Periodic Events, Toggle NSFW, & Other Options
    ]]
    local settingsPanelPool = Data.settingsPanelPool()
    table.insert(panelOptions, {
      type = "submenu",
      name = optionIndent_Title .. L.Joker_Options_Categories,
      controls = settingsPanelPool
    })

    --[[
      Trivia Random Pool Settings
    ]]
    local settingsPanelPoolTrivia = Data.settingsPanelPoolTrivia()
    table.insert(panelOptions, {
      type = "submenu",
      name = optionIndent_Title .. "Trivia Categories",
      controls = settingsPanelPoolTrivia
    })

    -- Quick Commands Submenu
    table.insert(panelOptions, {
      type = "submenu",
      name = optionIndent_Title .. L.Joker_Quick_Title,
      tooltip	= "",
      controls		= {
        {
          type			  = "header",
          name			  = optionIndent .. L.Joker_Quick_Subtitle, 
          width			  = "full",
        },
        {
          type			  = "description",
          text			  = optionIndent .. L.Joker_Quick_Desc, 
          width			  = "full",
        },
        {
          type			  = "button",
          name			  = optionIndent_Button .. L.Joker_Quick_Btn_Joke, -- Random /joke
          tooltip			= L.Joker_Quick_Btn_Joke_Tip,
          func			  = function (context) Joker.AnyJoke() end,
          width			  = "half",
        },
        {
          type			  = "button",
          name			  = optionIndent_Button .. "Random Trivia", -- Random /trivia
          tooltip			= "Get a random trivia question from any enabled category",
          func			  = function (context) Joker.AnyTrivia() end,
          width			  = "half",
        },
        {
          type = "divider"
        },
        {
          type			  = "header",
          name			  = optionIndent .. "Trivia Categories",
          width			  = "full",
        },
        {
          type			  = "button",
          name			  = optionIndent_Button .. "ESO Trivia",
          tooltip			= "Get Elder Scrolls trivia (ESO, Skyrim, Oblivion, Morrowind, and more)",
          func			  = function (context) Joker.Trivia('TriviaESO') end,
          width			  = "half",
        },
        {
          type			  = "button",
          name			  = optionIndent_Button .. "Celebrity Trivia",
          tooltip			= "Get celebrity, movies, TV, music, and pop culture trivia",
          func			  = function (context) Joker.Trivia('TriviaCelebrity') end,
          width			  = "half",
        },
        {
          type			  = "button",
          name			  = optionIndent_Button .. "Geography Trivia",
          tooltip			= "Get geography and world trivia",
          func			  = function (context) Joker.Trivia('TriviaGeography') end,
          width			  = "half",
        },
        {
          type			  = "button",
          name			  = optionIndent_Button .. "Science Trivia",
          tooltip			= "Get science trivia (chemistry, biology, physics, astronomy, and more)",
          func			  = function (context) Joker.Trivia('TriviaScience') end,
          width			  = "half",
        },
        {
          type = "divider"
        },
        {
          type			  = "header",
          name			  = optionIndent .. "Joke Categories",
          width			  = "full",
        },
        {
          type			  = "button",
          name			  = optionIndent_Button .. L.Joker_Quick_Btn_JokeESO, -- Random ESO
          tooltip			= L.Joker_Quick_Btn_JokeESO_Tip,
          func			  = function (context) Joker.Joke('ESO') end,
          width			  = "half",
        },
        {
          type			  = "button",
          name			  = optionIndent_Button .. L.Joker_Quick_Btn_JokeDad, -- Random Dad
          tooltip			= L.Joker_Quick_Btn_JokeDad_Tip,
          func			  = function (context) Joker.Joke('Dad') end,
          width			  = "half",
        },
        {
          type			  = "button",
          name			  = optionIndent_Button .. L.Joker_Quick_Btn_JokeEdgy, -- Random Edgy
          tooltip			= L.Joker_Quick_Btn_JokeEdgy_Tip,
          func			  = function (context) Joker.Joke('Edgy') end,
          width			  = "half",
        },
        {
          type			  = "button",
          name			  = optionIndent_Button .. L.Joker_Quick_Btn_JokeWisdom, -- Random Wisdom
          tooltip			= L.Joker_Quick_Btn_JokeWisdom_Tip,
          func			  = function (context) Joker.Joke('Wisdom') end,
          width			  = "half",
        },
        {
          type			  = "button",
          name			  = optionIndent_Button .. L.Joker_Quick_Btn_JokeNews, -- Random News
          tooltip			= L.Joker_Quick_Btn_JokeNews_Tip,
          func			  = function (context) Joker.Joke('News') end,
          width			  = "half",
        },
        {
          type			  = "button",
          name			  = optionIndent_Button .. L.Joker_Quick_Btn_JokeNorris, -- Random Norris
          tooltip			= L.Joker_Quick_Btn_JokeNorris_Tip,
          func			  = function (context) Joker.Joke('Norris') end,
          width			  = "half",
        },
        {
          type			  = "button",
          name			  = optionIndent_Button .. L.Joker_Quick_Btn_JokePokemon, -- Random Pokemon
          tooltip			= L.Joker_Quick_Btn_JokePokemon_Tip,
          func			  = function (context) Joker.Joke('Pokemon') end,
          width			  = "half",
        },
        {
          type			  = "button",
          name			  = optionIndent_Button .. L.Joker_Quick_Btn_JokePickup, -- Random pickup
          tooltip			= L.Joker_Quick_Btn_JokePickup_Tip,
          func			  = function (context) Joker.Joke('PickupLines') end,
          width			  = "half",
        },
        {
          type			  = "button",
          name			  = optionIndent_Button .. L.Joker_Quick_Btn_JokePickupHP, -- Random HP pickup
          tooltip			= L.Joker_Quick_Btn_JokePickupHP_Tip,
          func			  = function (context) Joker.Joke('PickupLinesHP') end,
          width			  = "half",
        },
        {
          type			  = "button",
          name			  = optionIndent_Button .. L.Joker_Quick_Btn_JokePickupPokemon, -- Random Pokemon pickup
          tooltip			= L.Joker_Quick_Btn_JokePickupPokemon_Tip,
          func			  = function (context) Joker.Joke('PickupLinesPokemon') end,
          width			  = "half",
        },
        {
          type			  = "button",
          name			  = optionIndent_Button .. L.Joker_Quick_Btn_JokePickupXXX, -- Random adult pickup
          tooltip			= L.Joker_Quick_Btn_JokePickupXXX_Tip,
          func			  = function (context) Joker.Joke('PickupLinesXXX') end,
          width			  = "half",
        },
        {
          type			  = "button",
          name			  = optionIndent_Button .. L.Joker_Quick_Btn_JokeBurn, -- Random burn
          tooltip			= L.Joker_Quick_Btn_JokeBurn_Tip,
          func			  = function (context) Joker.Joke('Burns') end,
          width			  = "half",
        },
        {
          type = "divider"
        },
        {
          type			  = "description",
          text			  = optionIndent .. L.Joker_QuickPop_Desc,
          width			  = "full",
        },
        {
          type			  = "button",
          name			  = optionIndent_Button .. L.Joker_Quick_Btn_JokeGoT, -- Random GoT
          tooltip			= L.Joker_Quick_Btn_JokeGoT_Tip,
          func			  = function (context) Joker.Joke('GameOfThrones') end,
          width			  = "half",
        },
        {
          type			  = "button",
          name			  = optionIndent_Button .. L.Joker_Quick_Btn_JokeStarWars, -- Random StarWars
          tooltip			= L.Joker_Quick_Btn_JokeStarWars_Tip,
          func			  = function (context) Joker.Joke('StarWars') end,
          width			  = "half",
        },
        {
          type = "divider"
        },
        {
          type			  = "description",
          text			  = optionIndent .. L.Joker_QuickUtil_Desc,
          width			  = "full",
        },
        {
          type			  = "button",
          name			  = optionIndent_Button .. L.Joker_Quick_Btn_Joke8Ball, -- 8ball
          tooltip			= L.Joker_Quick_Btn_Joke8Ball_Tip,
          func			  = function () Data.eightBall() end,
          width			  = "half",
        },
        {
          type			  = "button",
          name			  = optionIndent_Button .. L.Joker_Quick_Btn_JokeTwister, -- Random Twister
          tooltip			= L.Joker_Quick_Btn_JokeTwister_Tip,
          func			  = function (context) Joker.Joke('Twisters') end,
          width			  = "half",
        },
        {
          type			  = "button",
          name			  = optionIndent_Button .. L.Joker_Quick_Btn_JokeCatFact, -- Random CatFact
          tooltip			= L.Joker_Quick_Btn_JokeCatFact_Tip,
          func			  = function (context) Joker.Joke('Cat') end,
          width			  = "half",
        },
        {
          type			  = "button",
          name			  = optionIndent_Button .. L.Joker_Quick_Btn_JokeReady, -- Random /joke
          tooltip			= L.Joker_Quick_Btn_JokeReady_Tip,
          func			  = function () Data.readyCheck() end,
          width			  = "half",
        },
        {
          type = "divider",
        },
        {
          type = "description",
          text = L.Joker_More_Desc,
          title = Util.colorize(L.Joker_More_Title),
        }
      }
    })

    -- Legal
    table.insert(panelOptions, {
      type = "submenu",
      name = optionIndent_Title .. L.Joker_Legal_Title,
      tooltip	= "",
      controls		= {
        [1] = {
          type			  = "description",
          text			  = L.Joker_Legal_Desc
        }
      }
    })
    
    LAM:RegisterAddonPanel("Joker_Panel", panelData)
    LAM:RegisterOptionControls("Joker_Panel", panelOptions)
end
