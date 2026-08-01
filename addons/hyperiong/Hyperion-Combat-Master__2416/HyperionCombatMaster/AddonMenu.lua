--[[
      Depends on LibAddonMenu (and LibStub).
--]]
-------------------------------------------------------------------------------
-- Addon Menu
-------------------------------------------------------------------------------
HCMAddon.RegisterAddonMenu = function()

  local panelData = {
     type = "panel",
     name = "Hyperion Combat Master",              -- seperate from project id
     displayName = "Hyperion Combat Master (HCM)",
     author = "HyperionG",
     version = "0.6",                -- make sure same as manifest (.txt)
     website = "https://www.esoui.com/downloads/info2416-HyperionCombatMaster.html",
     feedback = "https://www.esoui.com/downloads/info2416-HyperionCombatMaster.html#comments",
     donation = "http://paypal.me/hyperiongg",
     slashCommand = "/hcm",
     registerForRefresh = true,         -- refresh panel when changed from outside
     --registerForDefaults = true,      -- use "defaults: x" values
  }

  local abiOptions = {
    {
      type = "description",
      title = "Description",
      text = string.format("Displays %s. Can be kept near crosshairs to avoid looking away in the heat of battle and stumbling over bars.",
      HCMAddon.icons.wText.abi)
    },
    {
      type = "checkbox",
      name = "Enable Active Bar Indicator",
      tooltip = "Default: On.",
      getFunc = function() return HCMAddon.savedVariables.abi.enabled end,
      setFunc = function(value) HCMAddon.savedVariables.abi.enabled = value end,
    },
    {
      type = "checkbox",
      name = "Show swap bar button",
      tooltip = "Show the swap bar button of the stock UI. Default: On.",
      getFunc = function() return HCMAddon.savedVariables.abi.showStockBarSwap end,
      setFunc = function(value)
        HCMAddon.savedVariables.abi.showStockBarSwap = value
        HCMAddon:UpdateActionBarWeaponSwapButton()
      end,
    },
    {
      type = "checkbox",
      name = "Show only in combat",
      tooltip = "Show only when fighting, hiding the indicator outside combat. Default: Off.",
      getFunc = function() return HCMAddon.savedVariables.abi.showOnlyInCombat end,
      setFunc = function(value) HCMAddon.savedVariables.abi.showOnlyInCombat = value end,
    },
    {
      type = "checkbox",
      name = "Change color when in combat",
      tooltip = "Displays another color when in combat. Default: On.",
      getFunc = function() return HCMAddon.savedVariables.abi.changeColorInCombat end,
      setFunc = function(value) HCMAddon.savedVariables.abi.changeColorInCombat = value end,
    },
    {
      type = "editbox",
      name = "Primary bar text",
      tooltip = "Text shown when primary bar is active. Allows customizing the displayed text. Examples: 1/2 or set names.",
      getFunc = function() return HCMAddon.savedVariables.abi.bar0 end,
      setFunc = function(text) HCMAddon.savedVariables.abi.bar0 = text end, --string.sub(text,1,5)
    },
    {
      type = "editbox",
      name = "Backup bar text",
      tooltip = "Text shown when backup bar is active.",
      getFunc = function() return HCMAddon.savedVariables.abi.bar1 end,
      setFunc = function(text) HCMAddon.savedVariables.abi.bar1 = text end,
    }
  }

  local iciOptions = {
    {
      type = "description",
      title = "Description",
      text = "Displays IN COMBAT text when under attack while in menus. Helps staying alert."
    },
    {
      type = "checkbox",
      name = "Enable In Combat Indicator",
      tooltip = "Default: Off.",
      getFunc = function() return HCMAddon.savedVariables.ici.enabled end,
      setFunc = function(value) HCMAddon.savedVariables.ici.enabled = value end,
    }
  }

  local powiOptions = {
    {
      type = "description",
      title = "Description",
      text = "Displays current 'Power'. Higher power means your abilities do more damage."
    },
    {
      type = "checkbox",
      name = "Enable Power Indicator",
      tooltip = "Default: On.",
      getFunc = function() return HCMAddon.savedVariables.powi.enabled end,
      setFunc = function(value) HCMAddon.savedVariables.powi.enabled = value end,
    },
    {
      type = "checkbox",
      name = "Include critical modifier",
      tooltip = "Default: On.",
      getFunc = function() return HCMAddon.savedVariables.powi.includeCrit end,
      setFunc = function(value) HCMAddon.savedVariables.powi.includeCrit = value end,
    },
    {
      type = "checkbox",
      name = "Include penetration modifier",
      tooltip = "Default: On.",
      getFunc = function() return HCMAddon.savedVariables.powi.includePenetration end,
      setFunc = function(value) HCMAddon.savedVariables.powi.includePenetration = value end,
    },
    {
      type = "checkbox",
      name = "Include Berserk modifier",
      tooltip = "Default: On.",
      getFunc = function() return HCMAddon.savedVariables.powi.includeBerserk end,
      setFunc = function(value) HCMAddon.savedVariables.powi.includeBerserk = value end,
    },
    {
      type = "checkbox",
      name = "Include Maim modifier",
      tooltip = "Default: On.",
      getFunc = function() return HCMAddon.savedVariables.powi.includeMaim end,
      setFunc = function(value) HCMAddon.savedVariables.powi.includeMaim = value end,
    },
    {
      type = "header",
      name = "In-depth Explanation"
    },
    {
      type = "description",
      title = "Power",
      text = "Power serves as a metric to give you an overall view of all your current damage-related stats and buffs. A higher Power means your attacks do more damage. Power takes into account multiple stats and buffs that impact your damage dealt."
    },
    {
      type = "description",
      text = "Power = (Base Power) * (1+Critical Modifier) * (1+Penetration Modifier) * (1+Berserk Modifier) * (1-Maim Modifier)"
    },
    {
      type = "description",
      title = "Base Power",
      text = "Base Power is the combination of main stat and its related Damage stat. Base Power is a direct factor for (tooltip) damage numbers."
      --Eg: 30k stamina and 4k weapon damage gives 30000/10.5+4000 = 6857 power (P).
      --    50k magicka and 2k spell damage gives 50000/10.5+2000 = 6761 power (M).
    },
    {
      type = "description",
      text = string.format("Base Power = (%s or %s) / 10.5 + (Weapon or Spell) Damage",
      HCMAddon.icons.wText.stamina,
      HCMAddon.icons.wText.magicka)
    },
    {
      type = "description",
      title = "Critical",
      text = "The Critical Modifier is the average additional damage dealt with critical hits. Note that in PvP, critical resistance is commonly used to reduce Critical Damage."
    },
    {
      type = "description",
      text = "Critical Modifier = Critical Hit Chance * Critical Damage"
    },
    {
      type = "description",
      title = "Penetration",
      text = "The Penetration Modifier is the additional un-mitigated damage penetration provides. Only innate (self) penetration counts for Power. Level 50 target is chosen as baseline, so 500 Penetration counts as 1% extra damage/Power. Target reductions (debuffs) do not factor in. Also note that too high penetration can lead to overpenetrating, where no extra damage is done, but will still raise Power."
    },
    {
      type = "description",
      text = "Penetration Modifier = Penetration / (50 * 1000)"
    },
    {
      type = "description",
      title = "Berserk",
      text = string.format("The Berserk Modifier is the additional damage done provided by the %s and %s buffs.",
      HCMAddon.icons.wText.major_berserk,
      HCMAddon.icons.wText.minor_berserk)
    },
    {
      type = "description",
      text = string.format("Berserk Modifier = 25%% (for Major) + 8%% (for Minor)")
    },
    {
      type = "description",
      title = "Maim",
      text = string.format("The Maim Modifier is the reduced damage done provided by the %s and %s debuffs.",
      HCMAddon.icons.wText.major_maim,
      HCMAddon.icons.wText.minor_maim)
    },
    {
      type = "description",
      text = string.format("Maim Modifier = 30%% (for Major) + 15%% (for Minor)")
    }
  }

    local gcdiOptions = {
      {
        type = "description",
        title = "Description",
        text = string.format("Displays %s (GCD) status. Can be used for more consistent attack weaving to increase your damage potential. Can also be used to practice and get a better understanding of how cooldowns work more precisely.",
        HCMAddon.icons.wText.gcd)
      },
      {
        type = "checkbox",
        name = "Enable Global Cooldown Indicator",
        tooltip = "Default: On.",
        getFunc = function() return HCMAddon.savedVariables.gcdi.enabled end,
        setFunc = function(value) HCMAddon.savedVariables.gcdi.enabled = value end,
      },
      {
        type = "checkbox",
        name = "Show cooldown details",
        tooltip = "Show cooldown numbers (1 = 100ms). Left-side is (Type 1) mouse attack or bar swap cooldown. Right-side is (Type 2) skill cooldown. Disable for a cleaner indicator when you already understand Type 1 and Type 2 cooldowns. Default: On.",
        getFunc = function() return HCMAddon.savedVariables.gcdi.showDetailed end,
        setFunc = function(value) HCMAddon.savedVariables.gcdi.showDetailed = value end,
      },
      {
        type = "checkbox",
        name = "Show only in combat",
        tooltip = "Show only when fighting, hiding the indicator outside combat. Default: Off.",
        getFunc = function() return HCMAddon.savedVariables.gcdi.showOnlyInCombat end,
        setFunc = function(value) HCMAddon.savedVariables.gcdi.showOnlyInCombat = value end,
      },
      {
        type = "header",
        name = "In-depth Explanation"
      },
      {
        type = "description",
        title = "Global Cooldown",
        text = string.format("The %s, or GCD, is the shared cooldown for one type of action. Understanding how it works allows you to animation cancel and 'weave' your attacks efficiently. Put simply, certain actions have different shared cooldowns. Skills, which are the most impactful type of action, have a cooldown (GCD) of 1 second.",
        HCMAddon.icons.wText.gcd)
      },
      {
        type = "description",
        title = "Cooldown Details",
        text = string.format("There are two types of actions: %s is light/heavy attack. %s is using a skill. Using a %s lets you use a %s instantly. But using a %s first will trigger %s cooldown as well.",
        HCMAddon.icons.wText.gcdi,
        HCMAddon.icons.wText.gcdi2,
        HCMAddon.icons.wText.gcdi,
        HCMAddon.icons.wText.gcdi2,
        HCMAddon.icons.wText.gcdi2,
        HCMAddon.icons.wText.gcdi)
      },
      {
        type = "description",
        title = "Indicator Color",
        text = string.format("The green color means both %s and %s actions are off cooldown. Orange means one type of action is on cooldown, but can still use the other type. Red means both types are on cooldown. ",
        HCMAddon.icons.wText.gcdi,
        HCMAddon.icons.wText.gcdi2
      )
      },
      {
        type = "description",
        title = "Weaving",
        text = string.format("To weave, use a %s action, then %s, (then bar swap if needed) and repeat. For optimal weaving you want to stay in the red and weave as soon as the indicator hits orange, because this means you are using abilities as much as possible.",
        HCMAddon.icons.wText.gcdi,
        HCMAddon.icons.wText.gcdi2
        )
      }
    }

  local rmaOptions = {
    {
      type = "description",
      title = "Description",
      text = string.format("Get around faster on horse and foot. Smartly slots %s (RM) on your skill bar on bar swap. Note that you should avoid initiating combat while RM is swapped in.",
      HCMAddon.icons.wText.ability_rm)
    },
    {
      type = "checkbox",
      name = "Enable Rapid Maneuver Auto-Assist",
      tooltip = "Default: On.",
      getFunc = function() return HCMAddon.savedVariables.rma.enabled end,
      setFunc = function(value) HCMAddon.savedVariables.rma.enabled = value end,
    },
    {
      type = "checkbox",
      name = "Swap on foot",
      tooltip = "Auto-Assist while on foot. Default: On.",
      getFunc = function() return HCMAddon.savedVariables.rma.swapOnFoot end,
      setFunc = function(value) HCMAddon.savedVariables.rma.swapOnFoot = value end,
    },
    {
      type = "slider",
      name = "Ability slot to swap",
      tooltip = "The slot that will be replaced with Rapid Maneuver.",
      getFunc = function() return HCMAddon.savedVariables.rma.slotToSwap end,
      setFunc = function(value) HCMAddon.savedVariables.rma.slotToSwap = value end,
      min = 1,
      max = 5,
      step = 1,
    },
    {
      type = "slider",
      name = "Recovery time (ms)",
      tooltip = "Time in milliseconds before Rapid Maneuver is switched out when not used.",
      getFunc = function() return HCMAddon.savedVariables.rma.recoveryTimeMs end,
      setFunc = function(value) HCMAddon.savedVariables.rma.recoveryTimeMs = value end,
      min = 500,
      max = 4000,
      step = 100,
    },
    {
      type = "header",
      name = "In-depth Explanation"
    },
    {
      type = "description",
      title = "Auto-Assist",
      text = string.format("Auto-Assist will slot %s on: Bar swap or mounting.",
      HCMAddon.icons.wText.ability_rm)
    },
    {
      type = "description",
      title = "",
      text = string.format("Auto-Assist will unslot %s when: Using RM, recovery time passed, or dismounting.",
      HCMAddon.icons.wText.ability_rm)
    },
    {
      type = "description",
      title = "",
      text = string.format("Auto-Assist will not slot %s during these conditions: Not enough %s to cast, RM already slotted on either bar, mounted and %s is active, or on foot and %s is active.",
      HCMAddon.icons.wText.ability_rm,
      HCMAddon.icons.wText.stamina,
      HCMAddon.icons.wText.major_gallop,
      HCMAddon.icons.wText.major_expedition)
    }
  }

    local caaOptions = {
      {
        type = "description",
        title = "Description",
        text = "Similar to RM Auto-Assist, but lets you use your own provided skill. With this you could cast an extra buff pre-combat for an extra edge in a fight."
      },
      {
        type = "checkbox",
        name = "Enable Custom Ability Auto-Assist",
        tooltip = "Default: Off.",
        getFunc = function() return HCMAddon.savedVariables.caa.enabled end,
        setFunc = function(value) HCMAddon.savedVariables.caa.enabled = value end,
      },
      {
        type = "editbox",
        name = "Skill (ability id)",
        tooltip = "Skill you want to swap in. Provide abilityId.",
        getFunc = function() return HCMAddon.savedVariables.caa.chosenAbilityId end,
        setFunc = function(text) HCMAddon.savedVariables.caa.chosenAbilityId = text end,
      },
      {
        type = "editbox",
        name = "Skill name",
        tooltip = "Name of provided skill. Retrieved automatically if ability id is valid skill.",
        getFunc = function() return GetAbilityName(HCMAddon.savedVariables.caa.chosenAbilityId) end,
        setFunc = function(text) end,
        disabled = true
      },
      {
        type = "slider",
        name = "Ability slot to swap",
        tooltip = "The slot that will be replaced.",
        getFunc = function() return HCMAddon.savedVariables.caa.slotToSwap end,
        setFunc = function(value) HCMAddon.savedVariables.caa.slotToSwap = value end,
        min = 1,
        max = 6,
        step = 1,
      },
      {
        type = "slider",
        name = "Recovery time (ms)",
        tooltip = "Time in milliseconds before skill is switched out when not used.",
        getFunc = function() return HCMAddon.savedVariables.caa.recoveryTimeMs end,
        setFunc = function(value) HCMAddon.savedVariables.caa.recoveryTimeMs = value end,
        min = 500,
        max = 4000,
        step = 100,
      }
    }

  local optionsData = { -- main settings list
    {
      type = "header",
      name = "Settings"
    },
    {
      type = "checkbox",
      name = "Use Account Wide Profile",
      tooltip = "Use the same settings on all characters. Disable for character-specific profile.",
      getFunc = function() return HCMAddon.savedVariables.general.accountWideSettingsEnabled end,
      setFunc = function(value)
        HCMAddon.charSV.general.accountWideSettingsEnabled = value
        HCMAddon.accSV.general.accountWideSettingsEnabled = value
        HCMAddon.Initialize()
     end,
    },
    {
      type = "submenu",
      name = "Active Bar Indicator",
      controls = abiOptions
    },
    {
      type = "submenu",
      name = "In Combat Indicator",
      controls = iciOptions
    },
    {
      type = "submenu",
      name = "Power Indicator",
      controls = powiOptions
    },
    {
      type = "submenu",
      name = "Global Cooldown Indicator",
      controls = gcdiOptions
    },
    {
      type = "submenu",
      name = "Rapid Maneuver Auto-Assist",
      controls = rmaOptions
    },
    -- {
    --   type = "submenu",
    --   name = "Custom Ability Auto-Assist (Experimental)",
    --   controls = caaOptions
    -- },
    {
      type = "header",
      name = "Commands"
    },
    {
      type = "description",
      text = "/power - Posts power information. Same as clicking in the middle of power indicator."
    },
    {
      type = "description",
      text = "/critdmg - Posts critical hit damage information."
    }
  }

  local LAM2 = LibStub("LibAddonMenu-2.0")
  LAM2:RegisterAddonPanel("HCMOptions", panelData)
  LAM2:RegisterOptionControls("HCMOptions", optionsData)

end
