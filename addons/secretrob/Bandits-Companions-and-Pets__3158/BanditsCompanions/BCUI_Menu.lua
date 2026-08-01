local panel              = "BCUI_CompanionPanel"
BCUI.Menu.AllCompanions = 2

local function Reset()
  for var, value in pairs(BCUI.Defaults) do BCUI.Vars[var] = value end
  if BUI.Vars.BCUI_CompanionFrame then BUI.Vars["BCUI_CompanionFrame"] = nil end
  if BUI.DefaultFrames.BCUI_CompanionFrame then BUI.DefaultFrames["BCUI_CompanionFrame"] = nil end
  BUI.Menu.UpdateOptions(panel)
  BCUI.Menu.Refresh()
end

local function ShowTargetFrames()
  BUI.inMenu = true
  --Unit Frames Display
  if BUI.init.Frames then    
    BCUI.TargetFrameShowPreview()    
  end
  BanditsUI:SetHidden(false)
end

local function HideTargetFrames()
  BUI.inMenu = false
  --Unit Frames Display
  if BUI.init.Frames then
    BCUI.TargetFrameHidePreview()
  end
  BanditsUI:SetHidden(not BUI_SettingsWindow:IsHidden())
end

local function SetMenuHandlers(panelInstance)
  panelInstance:SetHandler("OnEffectivelyShown", ShowTargetFrames)
  panelInstance:SetHandler("OnEffectivelyHidden", HideTargetFrames)
end

local function Initialize()
  local companions = {
    [1]=BUI.GetIcon('esoui/art/contacts/tabicon_ignored_up.dds',32).." Disabled",
    [2]=BUI.GetIcon(BCUI.Vars.CompanionIcon,32).." All"
  }
  for i, data in pairs(BCUI.CompanionInfo) do
    if i~="activeId" and BCUI.CompanionInfo[i].unlocked then companions[BCUI.CompanionInfo[i].index]=BUI.GetIcon(BCUI.CompanionInfo[i].icon,32).." "..BCUI.CompanionInfo[i].name end
  end
  
  local panelInstance = BUI.Menu.RegisterPanel(panel,
                                               {
                                                 type        = "panel",
                                                 name        = "25. |t32:32:"..BCUI.Vars.CompanionIcon.."|t" .. BUI.Loc("Companions"),
                                                 displayName = "25. |t32:32:"..BCUI.Vars.CompanionIcon.."|t" .. BUI.Loc("Companions"),
                                               })
  local Options       = {
    { type    = "checkbox",
      name    = BCUI.Loc("ShowCompanionWhenSolo"),
      getFunc = function() return BCUI.Vars.ShowCompanionWhenSolo end,
      setFunc = function(value) BCUI.Vars.ShowCompanionWhenSolo = value BCUI.Menu.Refresh() end,
    },
    { type    = "checkbox",
      name    = BCUI.Loc("ShowCompanionWhenInGroup"),
      getFunc = function() return BCUI.Vars.ShowCompanionWhenInGroup end,
      setFunc = function(value) BCUI.Vars.ShowCompanionWhenInGroup = value BCUI.Menu.Refresh() end,
    },
    { type    = "checkbox",
      name    = BCUI.Loc("CompanionCompact"),
      getFunc = function() return BCUI.Vars.CompanionCompact end,
      setFunc = function(value) BCUI.Vars.CompanionCompact = value BCUI.Menu.Refresh() end,
    },        
    { type    ="dropdown",
      name    =BCUI.Loc("CompanionNameFormat"),
      choices =BCUI.Loc("CompanionNameFormatChoices"),
      getFunc =function() return BCUI.Vars.CompanionNameFormat end,
      setFunc =function(i,value) BCUI.Vars.CompanionNameFormat=i BCUI.Menu.Refresh() end,
    },    
    { type    = "checkbox",
      name    = BCUI.Loc("CompanionLevels"),
      getFunc = function() return BCUI.Vars.CompanionLevels end,
      setFunc = function(value) BCUI.Vars.CompanionLevels = value BCUI.Menu.Refresh() end,
    },
    {
      type    = "dropdown",
      name    = BCUI.Loc("SidebarCompanion"),
      choices = companions,
      getFunc = function() return BCUI.Vars.SidebarCompanion end,
      setFunc = function(i,value) 
        local prev=BCUI.Vars.SidebarCompanion 
        BCUI.Vars.SidebarCompanion=i 
        BCUI.Menu.Refresh() 
        if i==BCUI.Menu.AllCompanions or (prev==BCUI.Menu.AllCompanions and i~=BCUI.Menu.AllCompanions) then BUI.OnScreen.Notification(8,"Reloading UI") BUI.CallLater("ReloadUI",1000,ReloadUI) end end,
    },
    { type    = "header",
      name    = BCUI.Loc("FramesHeader"),
    },
    { type = "button",
      name = BCUI.Loc("MoveFrames"),
      func = function()
        BCUI.MoveFrames()
      end,
    },
    { type    = "checkbox",
      name    = BCUI.Loc("DetachFrameGroup"),
      getFunc = function() return BCUI.Vars.DetachFrameGroup end,
      setFunc = function(value) BCUI.Vars.DetachFrameGroup = value BCUI.Menu.Refresh() end,
    },
    { type    = "checkbox",
      name    = BCUI.Loc("DetachFrameSolo"),
      getFunc = function() return BCUI.Vars.DetachFrameSolo end,
      setFunc = function(value) BCUI.Vars.DetachFrameSolo = value BCUI.Menu.Refresh() end,
    },
    { type    = "slider",
      name    = BCUI.Loc("CompanionWidth"),
      min     = 100,
      max     = 500,
      step    = 20,
      getFunc = function() return BCUI.Vars.CompanionWidth end,
      setFunc = function(value) BCUI.Vars.CompanionWidth = value BCUI.Menu.Refresh() end,
    },
    { type    = "slider",
      name    = BCUI.Loc("CompanionHeight"),
      min     = 16,
      max     = 40,
      step    = 10,
      getFunc = function() return BCUI.Vars.CompanionHeight end,
      setFunc = function(value) BCUI.Vars.CompanionHeight = value BCUI.Menu.Refresh() end,
    },
    { type    = "slider",
      name    = BCUI.Loc("CompanionFontSize"),
      min     = 8,
      max     = 24,
      step    = 1,
      getFunc =function() return BCUI.Vars.CompanionFontSize end,
      setFunc =function(value) BCUI.Vars.CompanionFontSize = value BCUI.Menu.Refresh() end,      
    },
    { type     = "colorpicker",
      name    = BCUI.Loc("FrameCompanionColor"),
      getFunc  = function() return unpack(BCUI.Vars.FrameCompanionColor) end,
      setFunc  = function(r, g, b, a) BCUI.Vars.FrameCompanionColor = { r, g, b, a } BCUI.Menu.Refresh() end,
      disabled = function() return not BCUI.Vars.FrameCompanionColor end,
    },
    { type    = "checkbox",
      name    = BCUI.Loc("CompanionNameColor"),
      getFunc = function() return BCUI.Vars.CompanionNameColor end,
      setFunc = function(value) BCUI.Vars.CompanionNameColor = value BCUI.Menu.Refresh() end,
    },
    { type    = "checkbox",
      name    = BCUI.Loc("AutoHide"),
      getFunc = function() return BCUI.Vars.AutoHide end,
      setFunc = function(value) BCUI.Vars.AutoHide=value end,
    },
    { type    = "checkbox",
      name    = BCUI.Loc("CompanionAutoDismiss"),
      getFunc = function() return BCUI.Vars.CompanionAutoDismiss end,
      setFunc = function(value) BCUI.Vars.CompanionAutoDismiss=value end,
    },
    { type    = "header",
      name    = BCUI.Loc("PetsHeader"),
    },    
    { type    = "checkbox",
      name    = BCUI.Loc("AddPetsToCompanionList"),
      getFunc = function() return BCUI.Vars.AddPetsToCompanionList end,
      setFunc = function(value) BCUI.Vars.AddPetsToCompanionList = value BCUI.Menu.Refresh() end,
    },
    { type    = "checkbox",
      name    = BCUI.Loc("ShowAllPetsAbilites"),
      getFunc = function() return BCUI.Vars.ShowAllPetsAbilites end,
      setFunc = function(value) BCUI.Vars.ShowAllPetsAbilites = value BCUI.Menu.Refresh() end,
    },
    { type = "button",
      name = "Reset",
      func = function()
        ZO_Dialogs_ShowDialog("BUI_RESET_CONFIRMATION",
                                      {
                                        text = "Reset to defaults ?",
                                        func = Reset
                                      })
      end,
    }
  }
  BUI.Menu.RegisterOptions(panel, Options)
  SetMenuHandlers(panelInstance);
  BCUI.Menu.Refresh()
end

function BCUI.Menu.Refresh()
  BUI.CallLater("Refresh",500,function() 
    BCUI.Frames.Initialize()
  end)
end

BCUI.Menu.Initialize = function()
  Initialize()
  --d("BCUI_Companion_Menu_Initialized")
end