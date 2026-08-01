-- Create namespace
DsRGuildUnknownMenu = {}
local DsRGuildUnknownMenu = DsRGuildUnknownMenu  or {}

DsRGuildUnknownMenu.name = "DsRGuildUnknownMenu"

local LAM = LibAddonMenu2

local DsRIcon = DsRglobals:HolidayIconLoad()

local MenuOptions,MenuPanel,MenuHandlers={},{},{}
local MenuOptionsChar,MenuPanelChar,MenuHandlersChar={},{},{}
local Settings,SettingsCHAR={},{}

-------------------------------------------------------------------------------------------------------------------------------------------------
local Localization={

	en={
		GUILD     = "ESOUI Addon",
		DONATION  = "Donation",
		GUILDINFO = "Chatlink",
		GUILDN    = "Guild",
	},
	de={
		GUILD     = "ESOUI Addon",
		DONATION  = "Spende",
		GUILDINFO = "Chatlink",
		GUILDN    = "Gilde",
	},
}

-------------------------------------------------------------------------------------------------------------------------------------------------
local function UnknownSettingsGEN()
  local SettingsTEMP = {}

  table.insert(SettingsTEMP, {type="subheader",name="DsRGuildUnknown_MenuInvIcon",})
  table.insert(SettingsTEMP, {type="checkbox",name="SI_SCRIBING_TITLE",warning=false,
                              getFunc=function() return DsRGuildUnknownOpts.displayScribing end,
                              setFunc=function(value) DsRGuildUnknownOpts.displayScribing=value end,
                              disabled=function() return DsRGuildUnknownOpts.TrackerOnOff end,})
  table.insert(SettingsTEMP, {type="checkbox",name="SI_ITEMTYPE8",warning=false,
                              getFunc=function() return DsRGuildUnknownOpts.displayMotifs end,
                              setFunc=function(value) DsRGuildUnknownOpts.displayMotifs=value end,
                              disabled=function() return DsRGuildUnknownOpts.TrackerOnOff end,})
  table.insert(SettingsTEMP, {type="checkbox",name="SI_ITEMTYPE29",warning=false,
                              getFunc=function() return DsRGuildUnknownOpts.displayRecipes end,
                              setFunc=function(value) DsRGuildUnknownOpts.displayRecipes=value end,
                              disable=function() return DsRGuildUnknownOpts.TrackerOnOff end,})
  table.insert(SettingsTEMP, {type="checkbox",name="SI_ITEMTYPE61",warning=false,
                              getFunc=function() return DsRGuildUnknownOpts.displayFurnishings end,
                              setFunc=function(value) DsRGuildUnknownOpts.displayFurnishings=value end,
                              disabled=function() return DsRGuildUnknownOpts.TrackerOnOff end,})
  table.insert(SettingsTEMP, {type="checkbox",name="SI_SPECIALIZEDITEMTYPE82",warning=false,
                              getFunc=function() return DsRGuildUnknownOpts.displayStylepages end,
                              setFunc=function(value) DsRGuildUnknownOpts.displayStylepages=value end,
                              disabled=function() return DsRGuildUnknownOpts.TrackerOnOff end,})
  table.insert(SettingsTEMP, {type="checkbox",name="DsRGuildUnknown_Runeboxes",warning=false,
                              getFunc=function() return DsRGuildUnknownOpts.displayRuneboxes end,
                              setFunc=function(value) DsRGuildUnknownOpts.displayRuneboxes=value end,
                              disabled=function() return DsRGuildUnknownOpts.TrackerOnOff end,})
  table.insert(SettingsTEMP, {type="subheader",name="DsRGuildUnknown_ToolChat",})
  table.insert(SettingsTEMP, {type="checkbox",name="DsRGuildUnknown_TooltipShow",warning=false,
                              getFunc=function() return DsRGuildUnknownOpts.displayTooltip end,
                              setFunc=function(value) DsRGuildUnknownOpts.displayTooltip=value end,
                              disabled=function() return DsRGuildUnknownOpts.TrackerOnOff end,})
  table.insert(SettingsTEMP, {type="checkbox",name="DsRGuildUnknown_ChatShow",warning="ReloadUiWarn1",
                              getFunc=function() return DsRGuildUnknownOpts.displayChat end,
                              setFunc=function(value) DsRGuildUnknownOpts.displayChat=value end,
                              disabled=function() return DsRGuildUnknownOpts.TrackerOnOff end,})
  table.insert(SettingsTEMP, {type="checkbox",name="DsRGuildUnknown_InventarShow",warning="ReloadUiWarn1",
                              getFunc=function() return DsRGuildUnknownOpts.displayInventory end,
                              setFunc=function(value) DsRGuildUnknownOpts.displayInventory=value end,
                              disabled=function() return DsRGuildUnknownOpts.TrackerOnOff end,})
  table.insert(SettingsTEMP, {type="subheader",name="DsRGuildUnknown_MenuIcon",})
  table.insert(SettingsTEMP, {type="dropdown",name="DsRGuildUnknown_PositionTP",
                              choices	 ={DsRGuildUnknown_LEFT, DsRGuildUnknown_CORNER, DsRGuildUnknown_RIGHT},
                              choicesValue={1, 2, 3},
                              getFunc	 =function() return DsRGuildUnknownOpts.inventoryIconPosition end,
                              setFunc	 =function(var) DsRGuildUnknownOpts.inventoryIconPosition = var
                                  if var == 2 then 
                                    DsRGuildUnknownOpts.iconSize = 24
                                    DsRGuildUnknownOpts.iconXOffset = -14
                                    DsRGuildUnknownOpts.iconYOffset = 8
                                  else
                                    DsRGuildUnknownOpts.iconSize = 32
                                    DsRGuildUnknownOpts.iconXOffset = 0
                                    DsRGuildUnknownOpts.iconYOffset = 0
                                  end
                              end,
                              disabled=function() return DsRGuildUnknownOpts.TrackerOnOff end,})
  table.insert(SettingsTEMP, {type="dropdown",name="DsRGuildUnknown_IconArt",
                              choices	 =DsRGuildUnknownDefaults.ICON_STYLES_CHOICES,
                              choicesValue=DsRGuildUnknownDefaults.ICON_STYLE_VALUES,
                              getFunc	 =function() return DsRGuildUnknownOpts.inventoryIconStyle end,
                              setFunc	 =function(var) DsRGuildUnknownOpts.inventoryIconStyle = var end,
                              disabled=function() return DsRGuildUnknownOpts.TrackerOnOff or DsRGuildUnknownOpts.MultiIconUseOnOff end,})
  table.insert(SettingsTEMP, {type="checkbox",name="DsRGuildUnknown_IconMulti",warning=false,
                              getFunc=function() return DsRGuildUnknownOpts.MultiIconUseOnOff end,
                              setFunc=function(value) DsRGuildUnknownOpts.MultiIconUseOnOff=value end,
                              disabled=function() return DsRGuildUnknownOpts.TrackerOnOff end,})
  table.insert(SettingsTEMP, {type="checkbox",name="DsRGuildUnknown_IconOnlyUnknownINV",warning=false,
                              getFunc=function() return DsRGuildUnknownOpts.displayOnlyIfUnknownINV end,
                              setFunc=function(value) DsRGuildUnknownOpts.displayOnlyIfUnknownINV=value end,
                              disabled=function() return DsRGuildUnknownOpts.TrackerOnOff end,})
  table.insert(SettingsTEMP, {type="checkbox",name="DsRGuildUnknown_IconOnlyUnknownCHAT",warning=false,
                              getFunc=function() return DsRGuildUnknownOpts.displayOnlyIfUnknownCHAT end,
                              setFunc=function(value) DsRGuildUnknownOpts.displayOnlyIfUnknownCHAT=value end,
                              disabled=function() return DsRGuildUnknownOpts.TrackerOnOff end,})
  table.insert(SettingsTEMP, {type="colorpicker",name="DsRGuildUnknown_ColorUnknown",warning=false,
                              getFunc=function() return DsRGuildUnknownUtility:ConvertHexToRGBA(DsRGuildUnknownOpts.unknownColour) end,
                              setFunc=function(r, g, b, a) DsRGuildUnknownOpts.unknownColour = DsRGuildUnknownUtility:ConvertRGBAToHex(r, g, b, a) end,
                              disabled=function() return DsRGuildUnknownOpts.TrackerOnOff end,})
  table.insert(SettingsTEMP, {type="colorpicker",name="DsRGuildUnknown_ColorUnknownOther",warning=false,
                              getFunc=function() return DsRGuildUnknownUtility:ConvertHexToRGBA(DsRGuildUnknownOpts.knownBySomeColour) end,
                              setFunc=function(r, g, b, a) DsRGuildUnknownOpts.knownBySomeColour = DsRGuildUnknownUtility:ConvertRGBAToHex(r, g, b, a) end,
                              disabled=function() return DsRGuildUnknownOpts.TrackerOnOff end,})
  table.insert(SettingsTEMP, {type="colorpicker",name="DsRGuildUnknown_ColorKnownAll",warning=false,
                              getFunc=function() return DsRGuildUnknownUtility:ConvertHexToRGBA(DsRGuildUnknownOpts.knownByAllColour) end,
                              setFunc=function(r, g, b, a) DsRGuildUnknownOpts.knownByAllColour = DsRGuildUnknownUtility:ConvertRGBAToHex(r, g, b, a) end,
                              disabled=function() return DsRGuildUnknownOpts.TrackerOnOff end,})
  table.insert(SettingsTEMP, {type="subheader",name="DsRGuildUnknown_axesOffset",})
  table.insert(SettingsTEMP, {type="slider",name="DsRGuildUnknown_XaxesOffset",warning=false,
                              -- clampIn=true,
                              -- clampFnc=function(value, min, max) return math.max(math.min(value, max), min) end,
                              getFunc=function() return DsRGuildUnknownOpts.iconXOffset end,
                              setFunc=function(value) DsRGuildUnknownOpts.iconXOffset = value end,
                              min=-100,max=100,step=1,
                              disabled=function() return DsRGuildUnknownOpts.TrackerOnOff end,})
  table.insert(SettingsTEMP, {type="slider",name="DsRGuildUnknown_XaxesOffset",warning=false,
                              -- clampIn=true,
                              -- clampFnc=function(value, min, max) return math.max(math.min(value, max), min) end,
                              getFunc=function() return DsRGuildUnknownOpts.iconYOffset end,
                              setFunc=function(value) DsRGuildUnknownOpts.iconYOffset = value end,
                              min=-50,max=50,step=1,
                              disabled=function() return DsRGuildUnknownOpts.TrackerOnOff end,})
  table.insert(SettingsTEMP, {type="slider",name="DsRGuildUnknown_IconSize",warning=false,
                              -- clampIn=true,
                              -- clampFnc=function(value, min, max) return math.max(math.min(value, max), min) end,
                              getFunc=function() return DsRGuildUnknownOpts.iconSize end,
                              setFunc=function(value) DsRGuildUnknownOpts.iconSize = value end,
                              min=16,max=48,step=4,
                              disabled=function() return DsRGuildUnknownOpts.TrackerOnOff end,})
  table.insert(SettingsTEMP, {type="slider",name="DsRGuildUnknown_Layer",warning=false,
                              -- clampIn=true,
                              -- clampFnc=function(value, min, max) return math.max(math.min(value, max), min) end,
                              getFunc=function() return DsRGuildUnknownOpts.iconDrawLevel end,
                              setFunc=function(value) DsRGuildUnknownOpts.iconDrawLevel = value end,
                              min=1,max=10,step=1,
                              disabled=function() return DsRGuildUnknownOpts.TrackerOnOff end,})

  return 	SettingsTEMP[1],  SettingsTEMP[2],  SettingsTEMP[3],  SettingsTEMP[4],  SettingsTEMP[5],  SettingsTEMP[6],  SettingsTEMP[7],  SettingsTEMP[8],  SettingsTEMP[9],  SettingsTEMP[10],
          SettingsTEMP[11], SettingsTEMP[12], SettingsTEMP[13], SettingsTEMP[14], SettingsTEMP[15], SettingsTEMP[16], SettingsTEMP[17], SettingsTEMP[18], SettingsTEMP[19], SettingsTEMP[20],
          SettingsTEMP[21], SettingsTEMP[22], SettingsTEMP[23], SettingsTEMP[24], SettingsTEMP[25], SettingsTEMP[26], SettingsTEMP[27], SettingsTEMP[28], SettingsTEMP[29], SettingsTEMP[30],
          SettingsTEMP[31], SettingsTEMP[32], SettingsTEMP[33], SettingsTEMP[34], SettingsTEMP[35], SettingsTEMP[36], SettingsTEMP[37], SettingsTEMP[38], SettingsTEMP[39], SettingsTEMP[40],
          SettingsTEMP[41], SettingsTEMP[42], SettingsTEMP[43], SettingsTEMP[44], SettingsTEMP[45], SettingsTEMP[46], SettingsTEMP[47], SettingsTEMP[48], SettingsTEMP[49], SettingsTEMP[50]             
end

local function UnknownSettingsACC(accountName, v)
  local CHARnameTEMP = {}
  table.insert(CHARnameTEMP, {type="checkbox",name=(zo_strformat ( "|cff9029<<1>>|r", accountName )),warning=false,
                              getFunc=function() return v.isEnabled end,
                              setFunc=function(value) v.isEnabled = value DsRGuildUnknown:BuildCharacterList() DsRGuildUnknown:RefreshViews() end,
                              disabled=function() return DsRGuildUnknownOpts.TrackerOnOff end,})

  for i = 1, #v.characters do
    local Char = DsRglobals:CharDetails(v.characters[i].name, i)
    table.insert(CHARnameTEMP, {type="subheader",name=tostring(Char),})
    table.insert(CHARnameTEMP, {type="dropdown",name="DsRGuildUnknown_MenuTrack",
                                choices={DsRGuildUnknown_LEARNING, DsRGuildUnknown_NOT_LEARNING},
                                choicesValue={1, 2},
                                getFunc=function() return v.characters[i].setting end,
                                setFunc=function(value) v.characters[i].setting = value DsRGuildUnknown:BuildCharacterList() DsRGuildUnknown:RefreshViews() end,
                                disabled=function() return not v.isEnabled or DsRGuildUnknownOpts.TrackerOnOff end})
    table.insert(CHARnameTEMP, {type="dropdown",name="DsRGuildUnknown_MenuPrio",
                                choices={1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20},
                                choicesValue={1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20},
                                getFunc=function() return v.characters[i].settingPrio end,
                                setFunc=function(value) v.characters[i].settingPrio = value DsRGuildUnknown:BuildCharacterList() DsRGuildUnknown:RefreshViews() end,
                                disabled=function() return not v.isEnabled or DsRGuildUnknownOpts.TrackerOnOff end})
  end

  return 	CHARnameTEMP[1],  CHARnameTEMP[2],  CHARnameTEMP[3],  CHARnameTEMP[4],  CHARnameTEMP[5],  CHARnameTEMP[6],  CHARnameTEMP[7],  CHARnameTEMP[8],  CHARnameTEMP[9],  CHARnameTEMP[10],
          CHARnameTEMP[11], CHARnameTEMP[12], CHARnameTEMP[13], CHARnameTEMP[14], CHARnameTEMP[15], CHARnameTEMP[16], CHARnameTEMP[17], CHARnameTEMP[18], CHARnameTEMP[19], CHARnameTEMP[20],
          CHARnameTEMP[21], CHARnameTEMP[22], CHARnameTEMP[23], CHARnameTEMP[24], CHARnameTEMP[25], CHARnameTEMP[26], CHARnameTEMP[27], CHARnameTEMP[28], CHARnameTEMP[29], CHARnameTEMP[30],
          CHARnameTEMP[31], CHARnameTEMP[32], CHARnameTEMP[33], CHARnameTEMP[34], CHARnameTEMP[35], CHARnameTEMP[36], CHARnameTEMP[37], CHARnameTEMP[38], CHARnameTEMP[39], CHARnameTEMP[40],
          CHARnameTEMP[41], CHARnameTEMP[42], CHARnameTEMP[43], CHARnameTEMP[44], CHARnameTEMP[45], CHARnameTEMP[46], CHARnameTEMP[47], CHARnameTEMP[48], CHARnameTEMP[49], CHARnameTEMP[50]
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildUnknownMenu:SetupMenueSettings()
  local DsRMenu=DsR and DsR.InternalMenu
  
  local MenuPanel={
      type        ="panel",
      name        =(DsRMenu and "|c9fb6cd11.|r |t30:30:/esoui/art/menubar/menubar_help_down.dds|t" or "")..DsR.Localization[DsR.language].IndexTrackerGeneral,
      displayName =(DsRMenu and "|c9fb6cd11.|r |t30:30:/esoui/art/menubar/menubar_help_down.dds|t" or "")..DsR.Localization[DsR.language].IndexTrackerGeneral,
      author      ="|cD8F781Has|r|cF3F781enw|r|cF5DA81arr|r|cF7BE81ior|r",
  }
  local MenuOptions={}

  table.insert(MenuOptions, {type="checkbox",name="DsRGuildUnknown_TrackerOnOff",warning="ReloadUiWarn2",
                              getFunc=function() return DsRGuildUnknownOpts.TrackerOnOff end,
                              setFunc=function(value) DsRGuildUnknownOpts.TrackerOnOff = value DsR.Menu.HandleReloadUIPressed() end,})
  table.insert(MenuOptions, {type="submenu",name="DsRGuildUnknown_TrackerACCSettings",controls={UnknownSettingsGEN()}})

  for accountName, v in pairs(DsRGuildUnknownChars["trackedCharacters"][GetWorldName()]) do
    table.insert(MenuOptions, {type="submenu",name=tostring(accountName),controls={UnknownSettingsACC(accountName, v)}})
  end

  DsR.Menu.RegisterPanel("DsRUnknownPanel_Menu_1", MenuPanel)
  DsR.Menu.RegisterOptions("DsRUnknownPanel_Menu_1", MenuOptions) 
end