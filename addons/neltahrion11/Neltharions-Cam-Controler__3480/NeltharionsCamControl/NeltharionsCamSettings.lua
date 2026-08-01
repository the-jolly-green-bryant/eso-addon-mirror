local NeltharionsCamControl = NeltharionsCamControl
NeltharionsCamControl.settings = {}
NeltharionsCamControl.MenuS = {}

local LibAddonMenu = LibAddonMenu2

local quicksliederEn = true

local function AddSetting(data)
  table.insert(NeltharionsCamControl.settings, data)
end

local function AddMenuData(menu, data)
  if not NeltharionsCamControl.MenuS[menu] then
    NeltharionsCamControl.MenuS[menu] = {}
  end
  table.insert(NeltharionsCamControl.MenuS[menu],data)
end









function NeltharionsCamControl.CreateSettingsMenu()

  local savedVariables = NeltharionsCamControl.savedVariables
  local defaults = NeltharionsCamControl.DEFAULTS

  --d("SettingsMenu")
  local colorYellow = "|cFFFF22"
  local panelData = {
    type = "panel",
    name = GetString(SETTINGS_LABLE_NAME),
    displayName = "Neltharions Cam Control",
    author =NeltharionsCamControl.author,
    version = tostring(NeltharionsCamControl.version),
    website = NeltharionsCamControl.website,
    slashCommand = "/NeltharionsCamControl",
    registerForRefresh = true,
    registerForDefaults = true,
  }
  --AddSetting(savedVariables:GetLibAddonMenuAccountCheckbox())
  --local cntrlOptionsPanel = NeltharionsCamControl.LAM2:RegisterAddonPanel("NeltharionsCamControl_Options", panelData)

  --local optionsTable = setmetatable({},{ __index = table })


--  optionsTable:insert(
  AddSetting{
    type = "header",
    name = GetString(SETTINGS_SAVE),
    registerForRefresh = true,
    registerForDefaults = true,
  }
--)


  AddSetting(savedVariables:GetLibAddonMenuAccountCheckbox())



  AddSetting{
    type = "header",
    name = GetString(SETTINGS_ZOOM_HEADER),
  }
  AddSetting{
      type = "checkbox",
      name = GetString(SETTINGS_ZOOM_ENABLE),
      tooltip = GetString(SETTINGS_ZOOM_ENABLE_TP),
      default = true,
      getFunc = function() return NeltharionsCamControl.savedVariables.zoomEnabled end,
      setFunc = function(bValue)
        PlaySound(SOUNDS.VOICE_CHAT_MENU_CHANNEL_JOINED)
        --d(bValue)
        NeltharionsCamControl.savedVariables.zoomEnabled = bValue
      end,
  }

  AddSetting{
      type = "checkbox",
      name = GetString(SETTINGS_FPERSON_ENABLE),
      tooltip = GetString(SETTINGS_FPERSON_ENABLE_TP),
      default = true,
      getFunc = function() return NeltharionsCamControl.savedVariables.firstPersonEn end,
      setFunc = function(bValue)
        PlaySound(SOUNDS.VOICE_CHAT_MENU_CHANNEL_JOINED)
        --d(bValue)
        NeltharionsCamControl.savedVariables.firstPersonEn = bValue
      end,
  }

  AddSetting{
    type = "header",
    name = GetString(SETTINGS_HEAD_QUICKSLOT),--"QuickSlot Einstellungen",
  }

  AddSetting{
    type="description",
    text=GetString(SETTINGS_DISCR_QUICKSLOT),--"Hier kannst du die Verschieden QuickSlots über das Menü verwalten.",
  }






  for i = 1, 8, 1 do
    local menum = tostring(i)

    if not NeltharionsCamControl.savedVariables.QuickSlot then
      NeltharionsCamControl.savedVariables.QuickSlot = {}
    end
    if not NeltharionsCamControl.savedVariables.QuickSlot[menum] then
      NeltharionsCamControl.savedVariables.QuickSlot[menum] = {}
    end
    AddMenuData(menum,{
      type = "slider",
      name = GetString(SETTINGS_HORIZ_SETT),--"Horizontale Einstellung",
      tooltip = GetString(SETTINGS_HORIZ_SETT_TP),--"Horizontale Einstellung",
      min = -100,
      max = 100,
      step = 1,
      decimals=2,
      default = 50,
      getFunc = function() return NeltharionsCamControl.savedVariables.QuickSlot[menum].Horizontal * 100  end,
      setFunc = function(ivalue)
        PlaySound(SOUNDS.VOICE_CHAT_MENU_CHANNEL_JOINED)
        NeltharionsCamControl.savedVariables.QuickSlot[menum].Horizontal = ivalue/100
        --NeltharionsCamControl.savedVariables.QuickSlot[menum].Horizontal = ivalue
        --hd=NeltharionsCamControl.savedVariables.QuickSlot[menum].Horizontal*100
        --hod=NeltharionsCamControl.savedVariables.QuickSlot[menum].HorizontalOffset*100
        --vd=NeltharionsCamControl.savedVariables.QuickSlot[menum].Vertical*200
        --fd=NeltharionsCamControl.savedVariables.QuickSlot[menum].Fieldview
        --d("Horizontal: "..hd)
        --d("Horizontaloff: "..hod)
        --d("Vertikale: "..vd)
        --d("Fieldview: "..fd)


      end,
    })

    AddMenuData(menum,{
      type = "slider",
      name = GetString(SETTINGS_HORIZ_OFFS_SETT),--"Horizontale Offset Einstellung",
      tooltip = GetString(SETTINGS_HORIZ_OFFS_SETT_TP),--"Horizontale Offset Einstellung",
      min = -100,
      max = 100,
      step = 1,
      decimals=2,
      default = 50,
      getFunc = function() return NeltharionsCamControl.savedVariables.QuickSlot[menum].HorizontalOffset * 100  end,
      setFunc = function(ivalue)
        PlaySound(SOUNDS.VOICE_CHAT_MENU_CHANNEL_JOINED)
        --NeltharionsCamControl.savedVariables.QuickSlot[menum].Horizontal = ivalue
        NeltharionsCamControl.savedVariables.QuickSlot[menum].HorizontalOffset = ivalue/100

      end,
    })

    AddMenuData(menum,{
      type = "slider",
      name = GetString(SETTINGS_VERT_SETT),--"Vertikale Einstellung",
      tooltip = GetString(SETTINGS_VERT_SETT_TP),--"Vertikale Einstellung",
      min = -60,
      max = 100,
      step = 1,
      decimals=2,
      default = 50,
      getFunc = function() return NeltharionsCamControl.savedVariables.QuickSlot[menum].Vertical * 200 end,
      setFunc = function(ivalue)
        PlaySound(SOUNDS.VOICE_CHAT_MENU_CHANNEL_JOINED)
        --NeltharionsCamControl.savedVariables.QuickSlot[menum].Horizontal = ivalue
        NeltharionsCamControl.savedVariables.QuickSlot[menum].Vertical = ivalue/200

      end,
    })
    AddMenuData(menum,{
      type = "slider",
      name = GetString(SETTINGS_FIELDVIEW_SETT),--"Fieldview Einstellung",
      tooltip = GetString(SETTINGS_FIELDVIEW_SETT_TP),--"Fieldview Einstellung",
      min = 35,
      max = 65,
      step = 1,
      default = 50,
      decimals=2,
      getFunc = function() return NeltharionsCamControl.savedVariables.QuickSlot[menum].Fieldview end,
      setFunc = function(ivalue)
        PlaySound(SOUNDS.VOICE_CHAT_MENU_CHANNEL_JOINED)
      --NeltharionsCamControl.savedVariables.QuickSlot[menum].Horizontal = ivalue
      NeltharionsCamControl.savedVariables.QuickSlot[menum].Vertical = ivalue

      end,
    })



    AddSetting{
      type="submenu",
      name="Quickslot: "..menum,
      tooltip=GetString(SETTINGS_QUICK_SETT),--"Einstellungen der Quickslots",
      controls=NeltharionsCamControl.MenuS[menum],

    }

  end









local globalPanelName = NeltharionsCamControl.addOnName .. "LAMSettings"
LibAddonMenu:RegisterAddonPanel(globalPanelName, panelData)
LibAddonMenu:RegisterOptionControls(globalPanelName, NeltharionsCamControl.settings)
--  NeltharionsCamControl.LAM2:RegisterOptionControls("NeltharionsCamControl_Options", optionsTable)
end
