local panel              = "BUI_ExecutionPanel"

local NotificationSounds = {
  "No_Sound",
  "Ability_MorphPurchased",
  "Ability_Ultimate_Ready_Sound",
  "Ability_UpgradePurchased",
  "BG_CTF_FlagCaptured",
  "BG_CTF_FlagReturned",
  "BG_MB_BallTaken_OtherTeam",
  "Champion_PointsCommitted",
  "Collectible_On_Cooldown",
  "Console_Game_Enter",
  "CrownCrates_Card_Flipping",
  "CrownCrates_Manifest_Chosen",
  "CrownCrates_Manifest_Selected",
  "GiftInventoryView_FanfareSparks",
  "InventoryItem_ApplyEnchant",
  "Justice_PickpocketBonus",
  "Justice_StateChanged",
  "LevelUpReward_Claim",
  "Lockpicking_unlocked",
  "New_Notification",
  "Objective_Complete",
  "Outfitting_ArmorAdd_Light",
  "Outfitting_WeaponAdd_Mace",
  "Quest_Complete",
  "Raid_Trial_Failed",
  "Telvar_Gained",
  "Telvar_MultiplierMax",
  "Telvar_MultiplierUp",
  "Undaunted_Transact",
}

local function Reset()
  for var, value in pairs(BUIE.Defaults) do BUIE.Vars[var] = value end
  BUI.Menu.UpdateOptions(panel)
end

local function ShowTargetFrames()
  BUI.inMenu = true
  --Unit Frames Display
  if BUI.init.Frames then
    if BUI.Vars.TargetFrame then
      BUIE.TargetFrameShowPreview()
    end
  end
  BanditsUI:SetHidden(false)
end

local function HideTargetFrames()
  BUI.inMenu = false
  --Unit Frames Display
  if BUI.init.Frames then
    if BUI.Vars.TargetFrame then
      BUIE.TargetFrameHidePreview()
    end
  end
  BanditsUI:SetHidden(not BUI_SettingsWindow:IsHidden())
end

local function SetMenuHandlers(panelInstance)
  panelInstance:SetHandler("OnEffectivelyShown", ShowTargetFrames)
  panelInstance:SetHandler("OnEffectivelyHidden", HideTargetFrames)
end

local function Initialize()
  local panelInstance = BUI.Menu.RegisterPanel(panel,
                                               {
                                                 type        = "panel",
                                                 name        = "21. |t32:32:/esoui/art/treeicons/tutorial_idexicon_darkbrotherhood_up.dds|t" .. BUI.Loc("ExecutionPanel"),
                                                 displayName = "21. |t32:32:/esoui/art/treeicons/tutorial_idexicon_darkbrotherhood_up.dds|t" .. BUI.Loc("ExecutionPanel"),
                                               })
  local Options       = {
    { type    = "slider",
      name    = "ExecutionThreshold",
      min     = 0,
      max     = 95,
      step    = 5,
      getFunc = function() return BUIE.Vars.ExecutionThreshold end,
      setFunc = function(value) BUIE.Vars.ExecutionThreshold = value end,
    },
    { type    = "checkbox",
      name    = "ExecutionIcon",
      getFunc = function() return BUIE.Vars.ExecutionIcon end,
      setFunc = function(value) BUIE.Vars.ExecutionIcon = value end,
    },
    { type = "header",
      name = "ExecutionTargetHeader",
    },
    { type    = "checkbox",
      name    = "ExecutionChangeTargetColor",
      getFunc = function() return BUIE.Vars.ExecutionChangeTargetColor end,
      setFunc = function(value) BUIE.Vars.ExecutionChangeTargetColor = value end,
    },
    { type     = "colorpicker",
      name     = "ExecutionTargetColor",
      getFunc  = function() return unpack(BUIE.Vars.ExecutionTargetColor) end,
      setFunc  = function(r, g, b, a) BUIE.Vars.ExecutionTargetColor = { r, g, b, a } end,
      disabled = function() return not BUIE.Vars.ExecutionChangeTargetColor end,
    },
    { type = "header",
      name = "ExecutionSoundHeader",
    },
    { type    = "checkbox",
      name    = "ExecutionSound",
      getFunc = function() return BUIE.Vars.ExecutionSound end,
      setFunc = function(value) BUIE.Vars.ExecutionSound = value end,
    },
    { type     = "dropdown",
      name     = "ExecutionSoundType",
      choices  = NotificationSounds,
      getFunc  = function() return BUIE.Vars.ExecutionSoundType end,
      setFunc  = function(i, value)
        BUIE.Vars.ExecutionSoundType = value
        PlaySound(value)
      end,
      disabled = function() return not BUIE.Vars.ExecutionSound end,
    },
    { type = "button",
      name = "ExecutionReset",
      func = function()
        ZO_Dialogs_ShowPlatformDialog("BUI_RESET_CONFIRMATION",
                                      {
                                        text = BUI.Loc("ExecutionResetDesc"),
                                        func = Reset
                                      })
      end,
    }
  }
  BUI.Menu.RegisterOptions(panel, Options)
  SetMenuHandlers(panelInstance);
end

BUIE.Menu.Initialize = function()
  Initialize()
  BUIE.Log("BUI_Execution_Menu_Initialized")
end