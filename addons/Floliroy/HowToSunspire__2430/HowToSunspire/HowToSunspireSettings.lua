HowToSunspire = HowToSunspire or {}

local HowToSunspire 						= HowToSunspire
local LAM 											= LibAddonMenu2
local WM 												= WINDOW_MANAGER
----------------------------------------------------------------------------------------------------------
---------------------------------------------[ 		PANEL    ]----------------------------------------------
----------------------------------------------------------------------------------------------------------
function HowToSunspire.CreateSettingsWindow()
  local panelData = {
    type 									= "panel",
    name 									= "HowToSunspire",
    displayName 					= "HowTo|cffbf00Sunspire|r",
    author 								= "Floliroy, @nogetrandom [PC EU]",
    version 							= HowToSunspire.version,
    slashCommand 					= "/HowToSunspire",
    registerForRefresh 		= true,
    registerForDefaults 	= true,
  }

  local cntrlOptionsPanel = LAM:RegisterAddonPanel("HowToSunspire_Settings", panelData)
  local Unlock = {
    Alerts 					= false,

    HA 							= false,
    Block 					= false,
    Leap 						= false,
    Shield 					= false,
    Comet 					= false,
    MeteorNames     = false,
    Spit 						= false,
    Geyser 					= false,
    -- Flare 					= false,
    Breath 					= false,
    SweepBreath 		= false,
    Thrash 					= false,
    SoulTear 				= false,
    PowerfulSlam 		= false,
    -- HailOfStone 		= false,
    Negate 					= false,
    GlacialFist			= false,
    Stonefist				= false,
    ------------------------
    Timers 					= false,

    IceTomb 				= false,
    LaserLokke 			= false,
    HP		 					= false,
    Landing					= false,
    Atro 						= false,
    Cata 						= false,
    NextFlare 			= false,
    Storm 					= false,
    Portal 					= false,
    Wipe 						= false,
    NextMeteor 			= false,
  }

  local sV = HowToSunspire.savedVariables
  local optionsData = {
    {	type = "header",      name = "User Interface",
    },
    { type = "checkbox",    name = "Enable Notification Sounds",
      tooltip = "Enable or disable sounds when you get an alert.",
      getFunc = function() return sV.Enable.Sound end,
      setFunc = function(newValue)
        sV.Enable.Sound = newValue
      end,
    },
    {	type = "header",      name = "Notification Sizes and Positions",
    },
    { type = "submenu",     name = "Alerts",
      controls = {
        {	type = "description",
          text = "Alerts from immediate incoming attacks. Unlock to adjust their position below.",
        },
        {	type = "checkbox",    name = "Unlock all Alerts",
          tooltip = "Adjust the position of all alerts from immediate attacks.",
          default = false,
          getFunc = function() return Unlock.Alerts end,
          setFunc = function(newValue)
            Unlock.Alerts = newValue

            Unlock.HA = newValue
            Hts_Ha:SetHidden(not newValue)
            Unlock.Block = newValue
            Hts_Block:SetHidden(not newValue)
            Unlock.Leap = newValue
            Hts_Leap:SetHidden(not newValue)
            Unlock.Shield = newValue
            Hts_Shield:SetHidden(not newValue)
            Unlock.Comet = newValue
            Hts_Comet:SetHidden(not newValue)
            Unlock.MeteorNames = newValue
            Hts_MeteorNames:SetHidden(not newValue)
            Unlock.Spit = newValue
            Hts_GlacialFist:SetHidden(not newValue)
            Unlock.GlacialFist = newValue
            Hts_Stonefist:SetHidden(not newValue)
            Unlock.Stonefist = newValue
            Hts_Spit:SetHidden(not newValue)
            Unlock.Geyser = newValue
            Hts_Geyser:SetHidden(not newValue)
            -- Unlock.Flare = newValue
            -- Hts_Flare:SetHidden(not newValue)
            Unlock.Breath = newValue
            Hts_Breath:SetHidden(not newValue)
            Unlock.SweepBreath = newValue
            Hts_Sweep:SetHidden(not newValue)
            Unlock.Thrash = newValue
            Hts_Thrash:SetHidden(not newValue)
            Unlock.SoulTear = newValue
            Hts_SoulTear:SetHidden(not newValue)
            Unlock.PowerfulSlam = newValue
            Hts_PowerfulSlam:SetHidden(not newValue)
            -- Unlock.HailOfStone = newValue
            -- Hts_HailOfStone:SetHidden(not newValue)
            Unlock.Negate = newValue
            Hts_Negate:SetHidden(not newValue)
          end,
          width = "half",
        },
        {	type = "slider",      name = "Alert Size",
          tooltip = "Choose the size of alerts from immediate attacks.",
          getFunc = function() return sV.AlertSize end,
          setFunc = function(newValue)
            sV.AlertSize = newValue
            HowToSunspire.SetFontSize(Hts_Ha_Label, newValue)
            HowToSunspire.SetFontSize(Hts_Block_Label, newValue)
            HowToSunspire.SetFontSize(Hts_Leap_Label, newValue)
            HowToSunspire.SetFontSize(Hts_Shield_Label, newValue)
            HowToSunspire.SetFontSize(Hts_Comet_Label, newValue)
            HowToSunspire.SetMeteorNameSize()
            HowToSunspire.SetFontSize(Hts_Spit_Label, newValue)
            HowToSunspire.SetFontSize(Hts_Geyser_Label, newValue)
            -- HowToSunspire.SetFontSize(Hts_Flare_Label, newValue)
            HowToSunspire.SetFontSize(Hts_Breath_Label, newValue)
            HowToSunspire.SetFontSize(Hts_Sweep_Label, newValue)
            HowToSunspire.SetFontSize(Hts_Thrash_Label, newValue)
            HowToSunspire.SetFontSize(Hts_SoulTear_Label, newValue)
            HowToSunspire.SetFontSize(Hts_PowerfulSlam_Label, newValue)
            -- HowToSunspire.SetFontSize(Hts_HailOfStone_Label, newValue)
            HowToSunspire.SetFontSize(Hts_Negate_Label, newValue)
            HowToSunspire.SetFontSize(Hts_GlacialFist_Label, newValue)
            HowToSunspire.SetFontSize(Hts_Stonefist_Label, newValue)
          end,
          min = 24,
          max = 56,
          step = 2,
          default = 40,
          width = "half",
        },
        { type = "divider",
        },
        {	type = "checkbox",    name = "Heavy Attacks",
          tooltip = "Adjust the position of the Heavy Attacks timer text from various enemies.",
          default = false,
          getFunc = function() return Unlock.HA end,
          setFunc = function(newValue)
            Unlock.HA = newValue
            Hts_Ha:SetHidden(not newValue)
          end,
          width = "half",
        },
        {	type = "checkbox",    name = "Jode´s Fire-Fang Jump",
          tooltip = "Adjust the position of the Block text.",
          default = false,
          getFunc = function() return Unlock.Block end,
          setFunc = function(newValue)
            Unlock.Block = newValue
            Hts_Block:SetHidden(not newValue)
          end,
          width = "half",
        },
        {	type = "checkbox",    name = "Vigil Statue's Ground Slam",
          tooltip = "Adjust the position of the Ground Slam text.",
          default = false,
          getFunc = function() return Unlock.PowerfulSlam end,
          setFunc = function(newValue)
            Unlock.PowerfulSlam = newValue
            Hts_PowerfulSlam:SetHidden(not newValue)
          end,
          width = "half",
        },

        -- {	type = "checkbox",
        --   name = "Vigil Statue's Hail of Stones",
        --   tooltip = "Adjust the position of the Hail of Stones text.",
        --   default = false,
        --   getFunc = function() return Unlock.HailOfStone end,
        --   setFunc = function(newValue)
        --     Unlock.HailOfStone = newValue
        --     Hts_HailOfStone:SetHidden(not newValue)
        --   end,
        --   width = "half",
        -- },

        {	type = "checkbox",    name = "Glacial Fist",
          tooltip = "Adjust the position of the alert from Ice Atronarch's Glacial Fist.",
          default = false,
          getFunc = function() return Unlock.GlacialFist end,
          setFunc = function(newValue)
            Unlock.Fist = newValue
            Hts_GlacialFist:SetHidden(not newValue)
          end,
          width = "half",
        },
        {	type = "checkbox",    name = "Stonefist",
          tooltip = "Adjust the position of the alert from Vigil Statue's Stonefist.",
          default = false,
          getFunc = function() return Unlock.Stonefist end,
          setFunc = function(newValue)
            Unlock.Fist = newValue
            Hts_Stonefist:SetHidden(not newValue)
          end,
          width = "half",
        },
        {	type = "checkbox",    name = "Leap",
          tooltip = "Adjust the position of the Leap text.",
          default = false,
          getFunc = function() return Unlock.Leap end,
          setFunc = function(newValue)
            Unlock.Leap = newValue
            Hts_Leap:SetHidden(not newValue)
          end,
          width = "half",
        },
        {	type = "checkbox",    name = "Comet / Meteor",
          tooltip = "Adjust the position of the Comet and Meteor notifications.",
          default = false,
          getFunc = function() return Unlock.Comet end,
          setFunc = function(newValue)
            Unlock.Comet = newValue
            Hts_Comet:SetHidden(not newValue)
          end,
          width = "half",
        },
        {	type = "checkbox",    name = "Meteor Targets",
          tooltip = "Adjust the position of the Meteor Target notifications.",
          default = false,
          getFunc = function() return Unlock.MeteorNames end,
          setFunc = function(newValue)
            Unlock.MeteorNames = newValue
            Hts_MeteorNames:SetHidden(not newValue)
          end,
          width = "half",
        },
        {	type = "checkbox",    name = "Shield Charge",
          tooltip = "Adjust the position of the Shield Charge alert.",
          default = false,
          getFunc = function() return Unlock.Shield end,
          setFunc = function(newValue)
            Unlock.Shield = newValue
            Hts_Shield:SetHidden(not newValue)
          end,
          width = "half",
        },
        {	type = "checkbox",    name = "Fire Spit",
          tooltip = "Adjust the position of Fire Spit.",
          default = false,
          getFunc = function() return Unlock.Spit end,
          setFunc = function(newValue)
            Unlock.Spit = newValue
            Hts_Spit:SetHidden(not newValue)
          end,
          width = "half",
        },
        {	type = "checkbox",    name = "Lava Geyser",
          tooltip = "Adjust the position of the Lava Geyser notification.",
          default = false,
          getFunc = function() return Unlock.Geyser end,
          setFunc = function(newValue)
            Unlock.Geyser = newValue
            Hts_Geyser:SetHidden(not newValue)
          end,
          width = "half",
        },
        {	type = "checkbox",    name = "Breath",
          tooltip = "Adjust the position of Breath.\n|cff0000Note|r: This includes all bosses.",
          default = false,
          getFunc = function() return Unlock.SweepBreath end,
          setFunc = function(newValue)
            Unlock.Breath = newValue
            Hts_Breath:SetHidden(not newValue)
          end,
          width = "half",
        },
        {	type = "checkbox",    name = "Sweeping Breath",
          tooltip = "Adjust the position of Sweeping Breath.",
          default = false,
          getFunc = function() return Unlock.SweepBreath end,
          setFunc = function(newValue)
            Unlock.SweepBreath = newValue
            Hts_Sweep:SetHidden(not newValue)
          end,
          width = "half",
        },
        {	type = "checkbox",    name = "Thrash",
          tooltip = "Adjust the position of Thrash.",
          default = false,
          getFunc = function() return Unlock.Thrash end,
          setFunc = function(newValue)
            Unlock.Thrash = newValue
            Hts_Thrash:SetHidden(not newValue)
          end,
          width = "half",
        },
        {	type = "checkbox",    name = "Soul Tear",
          tooltip = "Adjust the position of Soul Tear.",
          default = false,
          getFunc = function() return Unlock.SoulTear end,
          setFunc = function(newValue)
            Unlock.SoulTear = newValue
            Hts_SoulTear:SetHidden(not newValue)
          end,
          width = "half",
        },
        {	type = "checkbox",    name = "Negate",
          tooltip = "Adjust the position of Negate from the Eternal Servant in Nahviintas's portal.",
          default = false,
          getFunc = function() return Unlock.Negate end,
          setFunc = function(newValue)
            Unlock.Negate = newValue
            Hts_Negate:SetHidden(not newValue)
          end,
          width = "half",
        },

        -- {	type = "checkbox",
        --   name = "Flare",
        --   tooltip = "Adjust the position of fire atro light attack alert.",
        --   default = false,
        --   getFunc = function() return Unlock.Flare end,
        --   setFunc = function(newValue)
        --     Unlock.Flare = newValue
        --     Hts_Flare:SetHidden(not newValue)
        --   end,
        --   width = "half",
        -- },

      },
    },
    { type = "submenu",     name = "Timers and Updates",
      controls = {
        {	type = "description",
          text = "Countdowns for timed mechanics and general encounter updates. Unlock to adjust their position below.",
        },
        {	type = "checkbox",    name = "Unlock all Timers",
          tooltip = "Adjust the position of all timed mechanics.",
          default = false,
          getFunc = function() return Unlock.Timers end,
          setFunc = function(newValue)
            Unlock.Timers = newValue

            Unlock.IceTomb = newValue
            Hts_Ice:SetHidden(not newValue)
            Unlock.LaserLokke = newValue
            Hts_Laser:SetHidden(not newValue)
            Unlock.HP = newValue
            Hts_HP:SetHidden(not newValue)
            Unlock.Landing = newValue
            Hts_Landing:SetHidden(not newValue)
            Unlock.Atro = newValue
            Hts_Atro:SetHidden(not newValue)
            Unlock.Cata = newValue
            Hts_Cata:SetHidden(not newValue)
            Unlock.NextFlare = newValue
            Hts_NextFlare:SetHidden(not newValue)
            Unlock.Storm = newValue
            Hts_Storm:SetHidden(not newValue)
            Unlock.Portal = newValue
            Hts_Portal:SetHidden(not newValue)
            Unlock.Wipe = newValue
            Hts_Wipe:SetHidden(not newValue)
            Unlock.NextMeteor = newValue
            Hts_NextMeteor:SetHidden(not newValue)

          end,
          width = "half",
        },
        {	type = "slider",      name = "Timer Size",
          tooltip = "Choose the size of all timed mechanics.",
          getFunc = function() return sV.TimerSize end,
          setFunc = function(newValue)
            sV.TimerSize = newValue
            HowToSunspire.SetIceSize()
            HowToSunspire.SetFontSize(Hts_Laser_Label, newValue)
            HowToSunspire.SetFontSize(Hts_HP_Label, newValue)
            HowToSunspire.SetFontSize(Hts_Landing_Label, newValue)
            HowToSunspire.SetFontSize(Hts_Atro_Label, newValue)
            HowToSunspire.SetFontSize(Hts_NextFlare_Label, newValue)
            HowToSunspire.SetFontSize(Hts_Cata_Label, newValue)
            HowToSunspire.SetFontSize(Hts_Portal_Label, newValue)
            HowToSunspire.SetFontSize(Hts_Wipe_Label, newValue)
            HowToSunspire.SetFontSize(Hts_Storm_Label, newValue)
            HowToSunspire.SetFontSize(Hts_NextMeteor_Label, newValue)
          end,
          min = 24,
          max = 56,
          step = 2,
          default = 40,
          width = "half",
        },
        { type = "divider",
        },
        {	type = "checkbox",    name = "Boss HP Tracker",
          tooltip = "Adjust the position of the boss flying / landing notification.",
          default = false,
          getFunc = function() return Unlock.HP end,
          setFunc = function(newValue)
            Unlock.HP = newValue
            Hts_HP:SetHidden(not newValue)
          end,
          width = "half",
        },
        {	type = "checkbox",    name = "Boss Landing Tracker",
          tooltip = "Adjust the position of the boss flying / landing notification.",
          default = false,
          getFunc = function() return Unlock.Landing end,
          setFunc = function(newValue)
            Unlock.Landing = newValue
            Hts_Landing:SetHidden(not newValue)
          end,
          width = "half",
        },
        {	type = "checkbox",    name = "Ice Tomb",
          tooltip = "Adjust the position of the Ice Tomb timer.",
          default = false,
          getFunc = function() return Unlock.IceTomb end,
          setFunc = function(newValue)
            Unlock.IceTomb = newValue
            Hts_Ice:SetHidden(not newValue)
          end,
          width = "half",
        },
        {	type = "checkbox",    name = "Laser",
          tooltip = "Adjust the position of the Lokkestiiz Laser.",
          default = false,
          getFunc = function() return Unlock.LaserLokke end,
          setFunc = function(newValue)
            Unlock.LaserLokke = newValue
            Hts_Laser:SetHidden(not newValue)
          end,
          width = "half",
        },
        {	type = "checkbox",    name = "Fire Atro Spawn",
          tooltip = "Adjust the position of the Fire Atro spawn text.",
          default = false,
          getFunc = function() return Unlock.Atro end,
          setFunc = function(newValue)
            Unlock.Atro = newValue
            Hts_Atro:SetHidden(not newValue)
          end,
          width = "half",
        },
        {	type = "checkbox",    name = "Cataclysm",
          tooltip = "Adjust the position of Cataclysm.",
          default = false,
          getFunc = function() return Unlock.Cata end,
          setFunc = function(newValue)
            Unlock.Cata = newValue
            Hts_Cata:SetHidden(not newValue)
          end,
          width = "half",
        },
        {	type = "checkbox",    name = "Next Flare",
          tooltip = "Adjust the position of the Next Flare timer.",
          default = false,
          getFunc = function() return Unlock.NextFlare end,
          setFunc = function(newValue)
            Unlock.NextFlare = newValue
            Hts_NextFlare:SetHidden(not newValue)
          end,
          width = "half",
        },
        {	type = "checkbox",    name = "Fire Storm",
          tooltip = "Adjust the position of Fire Storm.",
          default = false,
          getFunc = function() return Unlock.Storm end,
          setFunc = function(newValue)
            Unlock.Storm = newValue
            Hts_Storm:SetHidden(not newValue)
          end,
          width = "half",
        },
        {	type = "checkbox",    name = "Portal Timers",
          tooltip = "Adjust the position of the Portal Timers.\n|cff0000Note|r: This includes Portal Open, Pins and Interrupt countdowns.",
          default = false,
          getFunc = function() return Unlock.Portal end,
          setFunc = function(newValue)
            Unlock.Portal = newValue
            Hts_Portal:SetHidden(not newValue)
          end,
          width = "half",
        },
        {	type = "checkbox",    name = "Wipe Countdown",
          tooltip = "Adjust the position of the Wipe countdown.",
          default = false,
          getFunc = function() return Unlock.Wipe end,
          setFunc = function(newValue)
            Unlock.Wipe = newValue
            Hts_Wipe:SetHidden(not newValue)
          end,
          width = "half",
        },
        {	type = "checkbox",    name = "Next Meteor",
          tooltip = "Adjust the position of the Next Meteor timer.",
          default = false,
          getFunc = function() return Unlock.NextMeteor end,
          setFunc = function(newValue)
            Unlock.NextMeteor = newValue
            Hts_NextMeteor:SetHidden(not newValue)
          end,
          width = "half",
        },
      },
    },
    {	type = "description", text = "Choose which mechanics to track.",
    },
    {	type = "submenu",     name = "Global Notifications",
      controls = {
        {	type = "description",
          text = "Mechanics from various adds throughout the trial.",
        },
        {	type = "checkbox",
          name = "Heavy Attack Alerts",
          tooltip = "Tracks all Heavy Attacks including bosses and the Eternal Servant.",
          default = true,
          getFunc = function() return sV.Enable.HA end,
          setFunc = function(newValue)
            sV.Enable.HA = newValue
          end,
          width = "half",
        },
        {	type = "checkbox",
          name = "Jode´s Fire-Fang Jump",
          tooltip = "Alerts you when the red cats pounce.",
          default = true,
          getFunc = function() return sV.Enable.Block end,
          setFunc = function(newValue)
            sV.Enable.Block = newValue
          end,
          width = "half",
        },
        {	type = "checkbox",
          name = "Leap",
          tooltip = "Alerts you when a Fury of Alkosh is leaping.",
          default = true,
          getFunc = function() return sV.Enable.Leap end,
          setFunc = function(newValue)
            sV.Enable.Leap = newValue
          end,
          width = "half",
        },
        {	type = "checkbox",
          name = "Shield Charge",
          tooltip = "Alerts you if the 1H & Shield adds are targeting you with Shield Charge.",
          default = true,
          getFunc = function() return sV.Enable.Shield end,
          setFunc = function(newValue)
            sV.Enable.Shield = newValue
          end,
          width = "half",
        },
        {	type = "checkbox",
          name = "Comet / Meteor",
          tooltip = "Tracks ALL Meteors and Comets in the trial including Nahvintaas's Molten Meteor.",
          default = true,
          getFunc = function() return sV.Enable.Comet end,
          setFunc = function(newValue)
            sV.Enable.Comet = newValue
          end,
          width = "half",
        },
        {	type = "checkbox",
          name = "Fire Spit",
          tooltip = "Alerts you when you are the target of Fire Spit, which summons an AoE and then an atronach.\n|cff0000Note:|r Tracks this mechanic in both Lokkestiiz and Nahviintaas encounters.",
          default = true,
          getFunc = function() return sV.Enable.Spit end,
          setFunc = function(newValue)
            sV.Enable.Spit = newValue
          end,
          width = "half",
        },
        {	type = "checkbox",
          name = "Lava Geyser",
          tooltip = "Alerts you when a Lava Geyser is about to hit near to you.\n|cff0000Note:|r Tracks this mechanic throughout all fights in Sunspire.",
          default = true,
          getFunc = function() return sV.Enable.Geyser end,
          setFunc = function(newValue)
            sV.Enable.Geyser = newValue
          end,
          width = "half",
        },
      },
    },
    { type = "submenu",	    name = "Bosses Common Mechanics",
      controls = {
        {	type = "checkbox",
          name = "Breath",
          tooltip = "Alerts you when you are the target of Breath from either of the 3 bosses.",
          default = true,
          getFunc = function() return sV.Enable.Breath end,
          setFunc = function(newValue)
            sV.Enable.Breath = newValue
          end,
          width = "full",
        },
        { type = "divider",
        },
        {	type = "description",
          text = "The Landing trackers can be slighty inaccurate due to boss animation desyncs.\nWill try to improve them.",
        },
        { type = "divider",
        },
        {	type = "checkbox",
          name = "Lokkestiiz HP Tracker",
          tooltip = "Displays a notification to let you know when Lokkestiiz is about to fly.",
          default = true,
          getFunc = function() return sV.Enable.hpLokke end,
          setFunc = function(newValue)
            sV.Enable.hpLokke = newValue
          end,
          width = "half",
        },
        {	type = "checkbox",
          name = "Lokkestiiz Landing Tracker",
          tooltip = "Displays a notification to let you know when Lokkestiiz is about to land.",
          default = true,
          getFunc = function() return sV.Enable.landingLokke end,
          setFunc = function(newValue)
            sV.Enable.landingLokke = newValue
          end,
          width = "half",
        },
        {	type = "checkbox",
          name = "Yolnahkriin HP Tracker",
          tooltip = "Displays a notification to let you know when Yolnahkriin is about to fly.",
          default = true,
          getFunc = function() return sV.Enable.hpYolna end,
          setFunc = function(newValue)
            sV.Enable.hpYolna = newValue
          end,
          width = "half",
        },
        {	type = "checkbox",
          name = "Yolnahkriin Landing Tracker",
          tooltip = "Displays a notification to let you know when Yolnahkriin is about to land.",
          default = true,
          getFunc = function() return sV.Enable.landingYolna end,
          setFunc = function(newValue)
            sV.Enable.landingYolna = newValue
          end,
          width = "half",
        },
        {	type = "checkbox",
          name = "Nahviintaas HP Tracker",
          tooltip = "Displays a notification to let you know when Nahviintaas is about to fly.",
          default = true,
          getFunc = function() return sV.Enable.hpNahvii end,
          setFunc = function(newValue)
            sV.Enable.hpNahvii = newValue
          end,
          width = "half",
        },
        {	type = "checkbox",
          name = "Nahviintaas Landing Tracker",
          tooltip = "Displays a notification to let you know when Nahviintaas is about to land.",
          default = true,
          getFunc = function() return sV.Enable.landingNahvii end,
          setFunc = function(newValue)
            sV.Enable.landingNahvii = newValue
          end,
          width = "half",
        },
        { type = "divider",
        },
        {	type = "slider",
          name = "% Before Flying to Show",
          tooltip = "Choose how many % before boss can fly to make the display visible.",
          getFunc = function() return sV.hpShowPercent end,
          setFunc = function(newValue)
            sV.hpShowPercent = newValue
          end,
          min = 2,
          max = 10,
          step = 1,
          default = 5,
          width = "half",
        },
        {	type = "slider",
          name = "Seconds Before Landing to Show",
          tooltip = "Set how many seconds before landing to make the display visible.",
          getFunc = function() return sV.timeBeforeLanding end,
          setFunc = function(newValue)
            sV.timeBeforeLanding = newValue
          end,
          min = 2,
          max = 10,
          step = 1,
          default = 5,
          width = "half",
        },
        -- {	type = "checkbox",
        -- 	name = "Show HP% left until Flying",
        -- 	tooltip = "On = display % left until flying.\nOff = display active % of boss HP.",
        -- 	default = true,
        -- 	getFunc = function() return sV.Enable.PercentToFly end,
        -- 	setFunc = function(newValue)
        --     sV.Enable.PercentToFly = newValue
        --   end,
        --   width = "half",
        -- },
      },
    },
    {	type = "submenu",     name = "Lokkestiiz Notifications",
      controls = {
        { type = "divider",
        },
        {	type = "checkbox",
          name = "Ice Tomb",
          tooltip = "Tracks the Ice Tombs spawn and remaining time left to enter.",
          default = true,
          getFunc = function() return sV.Enable.IceTomb end,
          setFunc = function(newValue)
            sV.Enable.IceTomb = newValue
          end,
          width = "half",
        },
        {	type = "checkbox",
          name = "Laser",
          tooltip = "Counts down the remaining time until Lokkestiiz´s beam attack.",
          default = true,
          getFunc = function() return sV.Enable.LaserLokke end,
          setFunc = function(newValue)
            sV.Enable.LaserLokke = newValue
          end,
          width = "half",
        },
        {	type = "checkbox",
          name = "Glacial Fist",
          tooltip = "Tracks frontal cone attack from Ice Atronarchs.",
          default = true,
          getFunc = function() return sV.Enable.GlacialFist end,
          setFunc = function(newValue)
            sV.Enable.GlacialFist = newValue
          end,
          width = "half",
        },
      },
    },
    { type = "submenu",     name = "Yolnahkriin Notifications",
      controls = {
        { type = "divider",
        },
        {	type = "checkbox",
          name = "Fire Atro Spawn",
          tooltip = "Tracks the Fire Atro spawn.",
          default = true,
          getFunc = function() return sV.Enable.Atro end,
          setFunc = function(newValue)
            sV.Enable.Atro = newValue
          end,
          width = "half",
        },
        {	type = "checkbox",
          name = "Next Flare",
          tooltip = "Countdown until next Flare.",
          default = true,
          getFunc = function() return sV.Enable.NextFlare end,
          setFunc = function(newValue)
            sV.Enable.NextFlare = newValue
          end,
          width = "half",
        },
        {	type = "checkbox",
          name = "Cataclysm",
          tooltip = "Counts down the remaining time until Cataclysm ends.",
          default = true,
          getFunc = function() return sV.Enable.Cata end,
          setFunc = function(newValue)
            sV.Enable.Cata = newValue
          end,
          width = "half",
        },
        -- {	type = "checkbox",
        -- 	name = "Flame Atronarch Aggro",
        -- 	tooltip = "Alerts you when you are the target of a Flame Atronarch's attacks.\n|cff0000Note:|r This alert will only activate on Veteran Hard Mode and is meant to alert dd's using Simmering Frenzy of incoming attacks.",
        -- 	default = true,
        -- 	getFunc = function() return sV.Enable.Flare end,
        -- 	setFunc = function(newValue)
        --   		sV.Enable.Flare = newValue
        --   	end,
        --   	width = "half",
        -- },
      },
    },
    {	type = "submenu",     name = "Nahviintaas Notifications",
      controls = {
        { type = "divider",
        },
        {	type = "checkbox",    name = "Sweeping Breath",
          tooltip = "Alerts you about Sweeping Breath and its direction.",
          default = true,
          getFunc = function() return sV.Enable.SweepBreath end,
          setFunc = function(newValue)
            sV.Enable.SweepBreath = newValue
          end,
          width = "half",
        },
        {	type = "checkbox",    name = "Thrash",
          tooltip = "Alerts you about Nahviintaas's Thrash mechanic.",
          default = true,
          getFunc = function() return sV.Enable.Thrash end,
          setFunc = function(newValue)
            sV.Enable.Thrash = newValue
          end,
          width = "half",
        },
        {	type = "checkbox",    name = "Soul Tear",
          tooltip = "Alerts you about Nahviintaas's Soul Tear mechanic.",
          default = true,
          getFunc = function() return sV.Enable.SoulTear end,
          setFunc = function(newValue)
            sV.Enable.SoulTear = newValue
          end,
          width = "half",
        },
        {	type = "checkbox",    name = "Next Meteor",
          tooltip = "Will show you a countdown to the next Meteor once you reach the last stage of the fight.",
          default = true,
          getFunc = function() return sV.Enable.NextMeteor end,
          setFunc = function(newValue)
            sV.Enable.NextMeteor = newValue
          end,
          width = "half",
        },
        {	type = "checkbox",    name = "Vigil Statue's Ground Slam",
          tooltip = "Alerts you if you are the target of a Vigil Statue's ground attack.",
          default = true,
          getFunc = function() return sV.Enable.PowerfulSlam end,
          setFunc = function(newValue)
            sV.Enable.PowerfulSlam = newValue
          end,
          width = "half",
        },
        {	type = "checkbox",    name = "Vigil Statue's Hail of Stones",
          tooltip = "Alerts you if a Vigil Statue is channeling.",
          default = true,
          getFunc = function() return sV.Enable.HailOfStone end,
          setFunc = function(newValue)
            sV.Enable.HailOfStone = newValue
          end,
          width = "half",
        },
        {	type = "checkbox",    name = "Vigil Statue's Stonefist",
          tooltip = "Alerts you if you are the target of a Vigil Statue's Stonefist attack.",
          default = true,
          getFunc = function() return sV.Enable.Stonefist end,
          setFunc = function(newValue)
            sV.Enable.Stonefist = newValue
          end,
          width = "half",
        },
        { type = "divider",
        },
        {	type = "description", text = "Display a message with directions to help Damage Dealers place meteors in seperate locations during execute on Hard Mode.\nThe directions are relative to when you are facing the boss and your back is facing towards the entrance.",
        },
        {	type = "checkbox",    name = "Meteor Targets",
          tooltip = "Will show you the names of the players who are targeted by Meteors in execute (will only show targets with the dd role).",
          default = true,
          getFunc = function() return sV.Enable.MeteorNames end,
          setFunc = function(newValue)
            sV.Enable.MeteorNames = newValue
          end,
          width = "half",
        },
        {	type = "checkbox",    name = "Meteor Targets Self Only",
          tooltip = "Names will only show if you are one of the targets.",
          default = true,
          getFunc = function() return sV.MeteorSelfOnly end,
          setFunc = function(newValue)
            sV.MeteorSelfOnly = newValue
          end,
          width = "half",
        },
        { type = "divider",
        },
        {	type = "checkbox",    name = "Fire Storm",
          tooltip = "Tracks Nahviintaas's arena-sized AoE. Also notifies players in portal if you have the Data Sending option enabled.",
          default = true,
          getFunc = function() return sV.Enable.Storm end,
          setFunc = function(newValue)
            sV.Enable.Storm = newValue
          end,
          width = "half",
        },
        {	type = "checkbox",    name = "Enable Data Sending",
          tooltip = "Enable map pings to tell the portal group when Fire Storm is coming.",
          default = false,
          getFunc = function() return sV.Enable.Sending end,
          setFunc = function(newValue)
            sV.Enable.Sending = newValue
          end,
          warning = "|cff0000Note:|r Only one person who is not in the portal is needed.\nMake sure to have someone enabling it.",
          disabled = function()
            if LibGPS3 and LibMapPing then
              return false --not disabled
            else
              return true --disabled
            end
          end,
          width = "half",
        },
        { type = "header",      name = "Portal Notifications",
        },
        {	type = "description", text = "All mechanics involving the portal during Nahviintaas bossfight.",
        },
        { type = "divider",
        },
        {	type = "checkbox",
          name = "Portal Active",
          tooltip = "Tracks the Portal spawn aswell as the remaining time until it expires.",
          default = true,
          getFunc = function() return sV.Enable.Portal end,
          setFunc = function(newValue)
            sV.Enable.Portal = newValue
          end,
          width = "half",
        },
        {	type = "checkbox",
          name = "Portal Bash Countdown",
          tooltip = "Counts down the remaining time to Interrupt the Eternal Servant.",
          default = true,
          getFunc = function() return sV.Enable.Interrupt end,
          setFunc = function(newValue)
            sV.Enable.Interrupt = newValue
          end,
          width = "half",
        },
        {	type = "checkbox",
          name = "Pins Tracking",
          tooltip = "Counts down the remaining time until the next Pins.",
          default = true,
          getFunc = function() return sV.Enable.Pins end,
          setFunc = function(newValue)
            sV.Enable.Pins = newValue
          end,
          width = "half",
        },
        {	type = "checkbox",
          name = "Negate Field",
          tooltip = "Alerts you when you are targeted by the Negate Field.",
          default = true,
          getFunc = function() return sV.Enable.Negate end,
          setFunc = function(newValue)
            sV.Enable.Negate = newValue
          end,
          width = "half",
        },
        { type = "divider",
        },
        {	type = "checkbox",
          name = "Wipe Countdown",
          tooltip = "Tracks the remaining time you have to kill the Eternal Servant.",
          default = true,
          getFunc = function() return sV.Enable.Wipe end,
          setFunc = function(newValue)
            sV.Enable.Wipe = newValue
          end,
          width = "half",
        },
        {	type = "slider",
          name = "Start of Countdown",
          tooltip = "Seconds left until portal wipe before displaying countdown.",
          getFunc = function() return sV.wipeCallLater end,
          setFunc = function(newValue)
            sV.wipeCallLater = newValue
          end,
          min = 10,
          max = 90,
          step = 1,
          default = 90,
          width = "half",
        },
      },
    },
  }

  LAM:RegisterOptionControls("HowToSunspire_Settings", optionsData)
end
