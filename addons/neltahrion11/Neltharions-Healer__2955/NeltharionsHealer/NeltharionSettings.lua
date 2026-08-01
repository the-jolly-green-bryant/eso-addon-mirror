local NeltharionsHealer = NeltharionsHealer
NeltharionsHealer.settings = {}

local LibAddonMenu = LibAddonMenu2

local busyPlaySound = false

local function AddSetting(data)
  table.insert(NeltharionsHealer.settings, data)
end

local function SetPlaySound(sound, Vol)
  if(busyPlaySound == false) then
    busyPlaySound = true
    NeltharionsHealer.globalSoundVolume = math.floor(GetSetting(SETTING_TYPE_AUDIO,AUDIO_SETTING_UI_VOLUME))
  end
  SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME, Vol)
  PlaySound(sound)
  zo_callLater(NeltharionsHealer.SetResVol, 1000)
end


function NeltharionsHealer.SetResVol()
  busyPlaySound = false
  SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME, NeltharionsHealer.globalSoundVolume)
end




function NeltharionsHealer.CreateSettingsMenu()

  local savedVariables = NeltharionsHealer.savedVariables
  local defaults = NeltharionsHealer.DEFAULTS

  d("SettingsMenu")
  local colorYellow = "|cFFFF22"
  local colorGreen = NeltharionsHealer.cGreen
  local panelData = {
    type = "panel",
    name = GetString(LOCALES_LABLE_NAME),
    displayName = colorGreen.."Neltharions "..colorYellow..GetString(LOCALES_HEALER).."|r",
    author =NeltharionsHealer.author,
    version = tostring(NeltharionsHealer.version),
    website = NeltharionsHealer.website,
    slashCommand = "/neltharionshealer",
    registerForRefresh = true,
    registerForDefaults = true,
  }
  --AddSetting(savedVariables:GetLibAddonMenuAccountCheckbox())
  --local cntrlOptionsPanel = neltharionsHealer.LAM2:RegisterAddonPanel("neltharionsHealer_Options", panelData)

  --local optionsTable = setmetatable({},{ __index = table })


--  optionsTable:insert(
  AddSetting{
    type = "header",
    name = GetString(LOCALES_GENERAL_OP),
    registerForRefresh = true,
    registerForDefaults = true,
  }
--)

  --optionsTable:insert(
  AddSetting{
    type = "description",
    text = GetString(LOCALES_OPTION_DESCRIBTION),
  }--)



  AddSetting{
      type = "checkbox",
      name = GetString(LOCALES_ADDON_ENABLE),
      tooltip = GetString(LOCALES_ADDON_ENABLE_TP),
      default = true,
      getFunc = function() return NeltharionsHealer.savedVariables.enableAddon end,
      setFunc = function(bValue)
        PlaySound(SOUNDS.VOICE_CHAT_MENU_CHANNEL_JOINED)
        --d(bValue)
        NeltharionsHealer.savedVariables.enableAddon = bValue
        NeltharionsHealer.enableAddon = bValue
        NeltharionsHealer.AddonIsEnabled()
      end,
  }

  AddSetting(savedVariables:GetLibAddonMenuAccountCheckbox())

  AddSetting{
    type = "header",
    name = GetString(LOCALES_SETTINGS_HEADER_GRAPHIC),
    registerForRefresh = true,
    registerForDefaults = true,
  }
  --optionsTable:insert(

  AddSetting{
    type = "slider",
    name = GetString(LOCALES_HEALTH_ALERT),
    tooltip = GetString(LOCALES_HEALTH_ALERT_TP),
    min = 5,
    max = 100,
    step = 5,
    default = 50,
    getFunc = function() return NeltharionsHealer.savedVariables.userLOW_HEALTH end,
    setFunc = function(ivalue)
      PlaySound(SOUNDS.VOICE_CHAT_MENU_CHANNEL_JOINED)
      NeltharionsHealer.savedVariables.userLOW_HEALTH = ivalue
      NeltharionsHealer.CheckLOW_HEALTH(false)
    end,
  }--)

--  optionsTable:insert(
AddSetting{
    type = "checkbox",
    name = GetString(LOCALES_IGNORE_OoR),
    tooltip = GetString(LOCALES_IGNORE_OoR_TP),
    default = false,
    getFunc = function() return NeltharionsHealer.savedVariables.ignorePlayersOutOfRange end,
    setFunc = function(bValue)
      PlaySound(SOUNDS.VOICE_CHAT_MENU_CHANNEL_JOINED)
      NeltharionsHealer.savedVariables.ignorePlayersOutOfRange = bValue
      NeltharionsHealer.SetIgoreOption(false)
    end,
  }--)

  AddSetting{
    type = "checkbox",
    name = GetString(LOCALES_IGNORE_COMPANION),
    tooltip = GetString(LOCALES_IGNORE_COMPANION_TP),
    default = false,
    getFunc = function() return NeltharionsHealer.savedVariables.ignoreCompanion end,
    setFunc = function(bValue)
      PlaySound(SOUNDS.VOICE_CHAT_MENU_CHANNEL_JOINED)
      NeltharionsHealer.savedVariables.ignoreCompanion = bValue
      NeltharionsHealer.ignoreCompanion = bValue
    end,

  }

  AddSetting{
    type = "checkbox",
    name = GetString(LOCALES_ENABLE_RANDOMTEXT),
    tooltip = GetString(LOCALES_ENABLE_RANDOMTEXT_TP),
    default = false,
    getFunc = function() return NeltharionsHealer.savedVariables.randomText end,
    setFunc = function(bValue)
      PlaySound(SOUNDS.VOICE_CHAT_MENU_CHANNEL_JOINED)
      NeltharionsHealer.savedVariables.randomText = bValue
      NeltharionsHealer.randomText = bValue
    end,
  }

  AddSetting{
  type = "colorpicker",
  name = GetString(LOCALES_COLOR_WARNT),
  tooltip = GetString(LOCALES_COLOR_WARNT_TP),
  default = {r=255,b=0,g=0,a=255},
  getFunc = function() return NeltharionsHealer.warnTColor:UnpackRGBA()  end,	--(alpha is optional)
  setFunc = function(r,g,b,a)
      NeltharionsHealer.savedVariables.warnTColor = ZO_ColorDef:New(r,g,b,a)
      NeltharionsHealer.warnTColor = ZO_ColorDef:New(r,g,b,a)
   end,	--(alpha is optional)
  width = "full",	--or "half" (optional)
  --warning = "warning text",
}

AddSetting{
type = "colorpicker",
name = GetString(LOCALES_COLOR_WARNTR),
tooltip = GetString(LOCALES_COLOR_WARNTR_TP),
default = {r=255,b=255,g=0,a=255},
getFunc = function() return NeltharionsHealer.warnTRColor:UnpackRGBA()  end,	--(alpha is optional)
setFunc = function(r,g,b,a)
    NeltharionsHealer.savedVariables.warnTRColor = ZO_ColorDef:New(r,g,b,a)
    NeltharionsHealer.warnTRColor = ZO_ColorDef:New(r,g,b,a)
 end,	--(alpha is optional)
width = "full",	--or "half" (optional)
--warning = "warning text",
}

--  optionsTable:insert(
AddSetting{
    type = "checkbox",
    name = GetString(LOCALES_ENABLE_REPOSITION),
    tooltip = GetString(LOCALES_ENABLE_REPOSITION_TP),
    default = false,
    getFunc = function() return NeltharionsHealer.savedVariables.userVISIBLE end,
    setFunc = function(bValue)
                PlaySound(SOUNDS.VOICE_CHAT_MENU_CHANNEL_JOINED)
                NeltharionsHealer.savedVariables.userVISIBLE = bValue
                if(bValue == true) then
                  neltharionsHealerIndicator:SetHidden(false)
                else
                  neltharionsHealerIndicator:SetHidden(true)
                end
              end,
  }--)

  AddSetting{
    type = "header",
    name = GetString(LOCALES_OVERLAY_HEADER),
    registerForRefresh = true,
    registerForDefaults = true,
  }

  AddSetting{
    type = "checkbox",
    name = GetString(LOCALES_OVERLAY_ENABLE),
    tooltip = GetString(LOCALES_OVERLAY_ENABLE_TP),
    default = false,
    getFunc = function() return NeltharionsHealer.overlayEnable end,
    setFunc = function(bValue)
                PlaySound(SOUNDS.VOICE_CHAT_MENU_CHANNEL_JOINED)
                NeltharionsHealer.savedVariables.overlayEnable = bValue
                NeltharionsHealer.overlayEnable = bValue
              end,
  }

  AddSetting{
  type = "colorpicker",
  name = GetString(LOCALES_COLOR_OVERLAY),
  tooltip = GetString(LOCALES_COLOR_OVERLAY_TP),
  default = {r=255,b=0,g=0,a=128},
  getFunc = function() return NeltharionsHealer.overlayColerW:UnpackRGBA()  end,	--(alpha is optional)
  setFunc = function(r,g,b,a)
      NeltharionsHealer.savedVariables.overlayColerW = ZO_ColorDef:New(r,g,b,a)
      NeltharionsHealer.overlayColerW = ZO_ColorDef:New(r,g,b,a)
      if(NeltharionsHealer.overlayPreview == true) then
        NeltharionsHealer.displayOverlay(false, false)
        NeltharionsHealer.displayOverlay(true, false)
      end
   end,	--(alpha is optional)
  width = "full",	--or "half" (optional)
  --warning = "warning text",
  }

  AddSetting{
    type = "checkbox",
    name = GetString(LOCALES_OVERLAY_PREVIEW),
    tooltip = GetString(LOCALES_OVERLAY_PREVIEW_TP),
    default = false,
    getFunc = function() return NeltharionsHealer.overlayPreview end,
    setFunc = function(bValue)
                PlaySound(SOUNDS.VOICE_CHAT_MENU_CHANNEL_JOINED)
                NeltharionsHealer.overlayPreview = bValue
                NeltharionsHealer.displayOverlay(bValue, false)
              end,
  }

  AddSetting{
    type = "checkbox",
    name = GetString(LOCALES_OVERLAY_OR_ENABLE),
    tooltip = GetString(LOCALES_OVERLAY_OR_ENABLE_TP),
    default = false,
    getFunc = function() return NeltharionsHealer.overlayOREnable end,
    setFunc = function(bValue)
                PlaySound(SOUNDS.VOICE_CHAT_MENU_CHANNEL_JOINED)
                NeltharionsHealer.savedVariables.overlayOREnable = bValue
                NeltharionsHealer.overlayOREnable = bValue
              end,
  }

  AddSetting{
  type = "colorpicker",
  name = GetString(LOCALES_COLOR_OVERLAY),
  tooltip = GetString(LOCALES_COLOR_OVERLAY_OR_TP),
  default = {r=255,b=255,g=0,a=128},
  getFunc = function() return NeltharionsHealer.overlayColerOR:UnpackRGBA()  end,	--(alpha is optional)
  setFunc = function(r,g,b,a)
      NeltharionsHealer.savedVariables.overlayColerOR = ZO_ColorDef:New(r,g,b,a)
      NeltharionsHealer.overlayColerOR = ZO_ColorDef:New(r,g,b,a)
      if(NeltharionsHealer.overlayORPreview == true) then
        NeltharionsHealer.displayOverlay(false, true)
        NeltharionsHealer.displayOverlay(true, true)
      end
   end,	--(alpha is optional)
  width = "full",	--or "half" (optional)
  --warning = "warning text",
  }

  AddSetting{
    type = "checkbox",
    name = GetString(LOCALES_OVERLAY_OR_PREVIEW),
    tooltip = GetString(LOCALES_OVERLAY_OR_PREVIEW_TP),
    default = false,
    getFunc = function() return NeltharionsHealer.overlayORPreview end,
    setFunc = function(bValue)
                PlaySound(SOUNDS.VOICE_CHAT_MENU_CHANNEL_JOINED)
                NeltharionsHealer.overlayORPreview = bValue
                NeltharionsHealer.displayOverlay(bValue, true)
              end,
  }

  AddSetting{
    type = "header",
    name = GetString(LOCALES_SETTINGS_HEADER_SOUND),
    registerForRefresh = true,
    registerForDefaults = true,
  }
  --optionsTable:insert(
  AddSetting{
    type = "checkbox",
    name = GetString(LOCALES_SOUND_ALERT_ENABLE),
    tooltip = GetString(LOCALES_SOUND_ALERT_ENABLE_TP),
    default = false,
    getFunc = function() return NeltharionsHealer.savedVariables.warnsoundenable end,
    setFunc = function(bValue)
                PlaySound(SOUNDS.VOICE_CHAT_MENU_CHANNEL_JOINED)
                NeltharionsHealer.savedVariables.warnsoundenable = bValue
                NeltharionsHealer.warnsoundenable = NeltharionsHealer.savedVariables.warnsoundenable

              end,
  }--)

  AddSetting{
    type = "slider",
    name = GetString(LOCALES_SETTINGS_SOUND_VOLUME),
    tooltip = GetString(LOCALES_SETTINGS_SOUND_VOLUME_TP),
    min = 0,
    max = 100,
    step = 1,
    default = 50,
    getFunc = function() return NeltharionsHealer.savedVariables.soundVolumen end,
    setFunc = function(ivalue)
                NeltharionsHealer.savedVariables.soundVolumen = ivalue
                NeltharionsHealer.soundVolumen = ivalue
                SetPlaySound(NeltharionsHealer.warnsound, ivalue)
              end,

  }
  --optionsTable:insert(
  AddSetting{
    type = "dropdown",
    name = GetString(LOCALES_SOUND_ALERT),
    tooltip = GetString(LOCALES_SOUND_ALERT_TP),
    choices = soundlistALL,
    scrollable = true,
    getFunc = function() return NeltharionsHealer.savedVariables.warnsound end,
    setFunc = function(var)
      --d(var)
      NeltharionsHealer.savedVariables.warnsound = var
      NeltharionsHealer.warnsound = var
      SetPlaySound(NeltharionsHealer.warnsound, NeltharionsHealer.soundVolumen)
      --PlaySound(var)
      --NeltharionsHealer.playSounds(var)

    end,
  }--)

  --optionsTable:insert(
  AddSetting{
    type = "dropdown",
    name = GetString(LOCALES_SOUND_ALERT_OUTRANGE),
    tooltip = GetString(LOCALES_SOUND_ALERT_OUTRANGE_TP),
    choices = soundlistALL,
    scrollable = true,
    getFunc = function() return NeltharionsHealer.savedVariables.warnsoundoutR end,
    setFunc = function(var)
      --d(var)
      NeltharionsHealer.savedVariables.warnsoundoutR = var
      NeltharionsHealer.warnsoundRange = var
      SetPlaySound(var, NeltharionsHealer.soundVolumen)
      --PlaySound(var)
      --NeltharionsHealer.playSounds(var)

    end,
  }--)

  --optionsTable:insert(
  AddSetting{
    type = "button",
    name = GetString(LOCALES_SOUND_BUTTON),
    tooltip = GetString(LOCALES_SOUND_BUTTON_TP),
    func = function()
    --  d("SoundTest")

    SetPlaySound(NeltharionsHealer.warnsound, NeltharionsHealer.soundVolumen)
  end,
}--)


local globalPanelName = NeltharionsHealer.addOnName .. "LAMSettings"
LibAddonMenu:RegisterAddonPanel(globalPanelName, panelData)
LibAddonMenu:RegisterOptionControls(globalPanelName, NeltharionsHealer.settings)
--  neltharionsHealer.LAM2:RegisterOptionControls("neltharionsHealer_Options", optionsTable)
end
