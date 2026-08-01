Rockgroover = Rockgroover or {}
local ERG = Rockgroover

local function GetProfileManagerMenu()
  -- Welcome Message with Profile
  local menu = {}
  --new
  --copy
  --rename
  local profileList = ERG.profiles.GetList()

  table.insert(menu, {
    type = "dropdown",
    name = ERG_SELECT,
    choices = ERG.profiles.GetList(),
    getFunc = function() return ERG.profiles.GetCurrentName() end,
    setFunc = function(profileName)
        for num, profile in ipairs( ERG.profiles.GetList() ) do
          if profile == profileName then
            ERG.profiles.SetCurrent( num )
            break
          end
        end
      end,
      width = "half",
      reference = "ERG_MENU_PROFILE_LIST"
  })

  table.insert(menu, {
    type = "button",
    name = ERG_PROFILE_DELETE,
    func = function()
          if #ERG.profiles.GetList() == 1 then
            ZO_Dialogs_ShowDialog(ERG.dialogs.preventLastProfileDelete)
          else
            ERG.profiles.DeleteCurrentProfile()
          end
      end,
    warning = ERG_PROFILE_DELETE_WARNING,
    isDangerous = true,
    width = "half",
  })

  table.insert(menu, {type = "divider"})

  table.insert(menu, {
    type = "editbox",
    name = "",
    getFunc = function() return ERG.profiles.editBox end,
    setFunc = function( text )
        ERG.profiles.editBox = text
     end,
    isMultiline = false,
    width = "half",
  })


  table.insert(menu, {
    type = "button",
    name = ERG_PROFILE_RENAME,
    func = function()
        if ERG.profiles.editBox == "" then
          ZO_Dialogs_ShowDialog(ERG.dialogs.preventEmptyName)
        elseif ERG.profiles.IsDuplicateName( ERG.profiles.editBox ) then
          ZO_Dialogs_ShowDialog(ERG.dialogs.preventDublicateName)
        else
          ERG.profiles.ChangeNameOfCurrent()
        end
        ERG.profiles.UpdateMenu()
      end,
    width = "half",
  })

  table.insert(menu, {
    type = "button",
    name = ERG_PROFILE_COPY,
    func = function()
      if ERG.profiles.editBox == "" then
        ZO_Dialogs_ShowDialog(ERG.dialogs.preventEmptyName)
      elseif ERG.profiles.IsDuplicateName( ERG.profiles.editBox ) then
        ZO_Dialogs_ShowDialog(ERG.dialogs.preventDublicateName)
      else
        ERG.profiles.CopyCurrent()
      end
      ERG.profiles.UpdateMenu()
      ERG.profiles.editBox = ""
      end,
    width = "half",
  })

  table.insert(menu, {
    type = "button",
    name = ERG_PROFILE_CREATE,
    func = function()
      if ERG.profiles.editBox == "" then
        ZO_Dialogs_ShowDialog(ERG.dialogs.preventEmptyName)
      elseif ERG.profiles.IsDuplicateName( ERG.profiles.editBox ) then
        ZO_Dialogs_ShowDialog(ERG.dialogs.preventDublicateName)
      else
        ERG.profiles.CreateNew( ERG.profiles.editBox )
        ERG.profiles.SetCurrent( ERG.profiles.GetNumWithName(ERG.profiles.editBox) )
        ERG.profiles.UpdateMenu()
        ERG.profiles.editBox = ""
      end

      end,
    width = "half",
  })
  return menu
end


local function GetFeedbackSettingsMenu()
  local menu = {}
  table.insert(menu,   {
        type = "description",
        --title = "My Title",	--(optional)
        title = nil,	--(optional)
        text = ERG_FEEDBACK_INGAME_MAIL_DESCRIPTION,
        width = "half",
    } )
  table.insert(menu,   {
        type = "button",
        name = ERG_FEEDBACK_INGAME_MAIL_BUTTON,
        tooltip = "",
        func = function()
              local server = GetWorldName()
              local function PrefillMail()
                ZO_MailSendToField:SetText("@Exoy94")
                ZO_MailSendSubjectField:SetText("Rockgroover")
                ZO_MailSendBodyField:TakeFocus()
              end
              if GetWorldName() == "EU Megaserver" then
                SCENE_MANAGER:Show('mailSend')
                zo_callLater(PrefillMail, 250)
              else
                ZO_Dialogs_ShowDialog(ERG.dialogs.warningIngameMailServer)
              end
        end,
        width = "half",
    } )

  table.insert(menu, { type = "divider" } )
  table.insert(menu,   {
        type = "description",
        --title = "My Title",	--(optional)
        title = nil,	--(optional)
        text = ERG_FEEDBACK_ESOUI_DESCRIPTION,
        width = "half",
    })
  table.insert(menu,   {
        type = "button",
        name = ERG_FEEDBACK_ESOUI_BUTTON,
        tooltip = "",
        func = function()
          RequestOpenUnsafeURL( "https://www.esoui.com/downloads/info3223-ExoYsRockgroover.html" )
        end,
        width = "half",
        warning = ERG_FEEDBACK_URL_WARNING,
    } )
  table.insert(menu, { type = "divider" } )
  table.insert(menu,   {
        type = "description",
        --title = "My Title",	--(optional)
        title = nil,	--(optional)
        text = ERG_FEEDBACK_PAYPAL_DESCRIPTION,
        width = "half",
    })
  table.insert(menu,   {
        type = "button",
        name = ERG_FEEDBACK_PAYPAL_BUTTON,
        tooltip = "",
        func = function()
          RequestOpenUnsafeURL( "https://www.paypal.com/paypalme/ExoYGaming" )
        end,
        width = "half",
        warning = ERG_FEEDBACK_URL_WARNING,
    })
  return menu
end

local function GetGeneralSettingsMenu()
  local menu = {}

  table.insert(menu, {
    type = "description",
    text = ERG_GENERAL_SETTINGS_DESC,
  })
  --Minor Text
  -- Welcome Message with Profile
  -- Chat Output
  table.insert(menu, {type = "divider"})
  table.insert(menu, {
    type = "checkbox",
    name = ERG_SETTING_WELCOME,
    tooltip = ERG_SETTING_WELCOME_TT,
    getFunc = function() return ERG.SV.welcome end,
    setFunc = function(bool)
      ERG.SV.welcome = bool
     end,
  })
  table.insert(menu, {
    type = "checkbox",
    name = ERG_SETTING_SHOW_MECHANIC_NAME,
    tooltip = ERG_SETTING_SHOW_MECHANIC_NAME_TT,
    getFunc = function() return ERG.SV.showAbilityName end,
    setFunc = function(bool)
      ERG.SV.showAbilityName = bool
     end,
  })
  table.insert(menu, {
    type = "checkbox",
    name = ERG_SETTING_SHOW_ICON_WITH_ALERTS,
    tooltip = ERG_SETTING_SHOW_ICON_WITH_ALERTS_TT,
    getFunc = function() return ERG.SV.showIconWithAlerts end,
    setFunc = function(bool)
      ERG.SV.showIconWithAlerts = bool
     end,
  })

  return menu
end


local function GetEncounterMenu( encounter )
  local notificationList = ERG[encounter].GetNotificationList()
  local mechanicData = ERG[encounter].GetMechanicData()

  local encounterMenu = {}

  local function AddSpecificNotificationEntry(menu, id, notification, warning)
    table.insert(menu, {
      type = "checkbox",
      name = ERG.GetNotificationDesignationList()[notification],
      getFunc = function() return ERG.store[encounter][id][notification] end,
      setFunc = function(bool)
          ERG.store[encounter][id][notification] = bool
       end,
      width = "half",
      tooltip = ERG.GetTooltip(id),
      warning = warning,
    })
    -- TODO bannerAlert und textAlert gleicher text, cast alert -> action text
    table.insert(menu, {
      type = "editbox",
      name = ERG_TEXT,
      getFunc = function() return ERG.store[encounter][id][notification.."Text"] end,
      setFunc = function(text)
          ERG.store[encounter][id][notification.."Text"] = text
       end,
      isMultiline = false,
      width = "half"
    })
  end

  local function AddBasicNotificationEntry(menu, id)
    table.insert(menu, {type = "divider"} )
    table.insert(menu, {
      type = "colorpicker",
      name = ERG_COLOR,
      getFunc = function() return unpack( ERG.store[encounter][id].color ) end,
      setFunc = function(r,g,b) ERG.store[encounter][id].color = {r,g,b,1} end,
      width = "half",
    })
    table.insert(menu, {
      type = "dropdown",
      name = ERG_SOUND,
      choices = ERG.GetSoundList(),
      getFunc = function() return ERG.store[encounter][id].sound end,
      setFunc = function(select)
            ERG.store[encounter][id].sound = select
            PlaySound(SOUNDS[select])
      end,
      width = "half",
    })
  end


  local hasPanels = ERG[encounter].GetPanelMenus and true or false

  if ERG[encounter].GetPanelMenus then
    for _, entry in ipairs( ERG[encounter].GetPanelMenus() ) do
      table.insert(encounterMenu, entry )
    end
  end

  local popupMenu = {}
  if not hasPanels then popupMenu = encounterMenu end

  for id, specificNotificationList in pairs(notificationList) do
    table.insert(popupMenu, { type = "header", name = ERG.GetMenuAbilityName(id, mechanicData) })

    for notification, data in pairs(specificNotificationList) do
      AddSpecificNotificationEntry(popupMenu, id, notification)
    end
  AddBasicNotificationEntry(popupMenu, id)
  end

  if ERG[encounter].GetAdditionalNotificationMenu then
    for id, entry in pairs( ERG[encounter].GetAdditionalNotificationMenu() ) do
      table.insert(popupMenu, { type = "header", name = entry.header })
      AddSpecificNotificationEntry(popupMenu, id, entry.notification, entry.warning)
      AddBasicNotificationEntry(popupMenu, id)
    end
  end


  if ERG[encounter].Get_CCA_Settings then
    table.insert(popupMenu, {type = "header", name = ""})
    for mechanic, settings in pairs( ERG[encounter].Get_CCA_Settings() ) do

      local refId = 1
      if settings.id then
        refId = settings.id
      elseif settings.refId then
        refId = settings.refId
      elseif type(ERG.CCA_Data[mechanic]) == "number" then
        refId = ERG.CCA_Data[mechanic]
      end

      table.insert(popupMenu, {
        type = "checkbox",
        name = ERG.AddIconToString(settings.name or ERG.GetFormattedAbilityName(refId), settings.icon or refId, 32, true),
        getFunc = function() return ERG.store[encounter].CCA_Settings[mechanic] end,
        setFunc = function(bool)
          ERG.store[encounter].CCA_Settings[mechanic] = bool
          ERG.Update_CCA_Settings()
        end,
        warning = ERG_CCA_WARNING,
        tooltip = settings.tooltip
      })
    end
  end

  if hasPanels then
    table.insert(encounterMenu, {type = "submenu", name = ERG.AddIconToString(ERG_POPUP, "esoui/art/icons/achievement_u24_teaser_2.dds", 32 ,true), controls = popupMenu} )
    return encounterMenu
  else
    return popupMenu
  end
end


function ERG.CreateMenu()
  local panelData = {
    type = "panel",
    name = ERG.displayName,
    displayName = ERG.displayNameWithIcon,
    author = ERG.author,
    version = ERG.version,
    registerForRefresh = true,
    --registerForDefaults = true,
  }

  ERG.InitializeMenuDialogs()

  -- welcome
  local optionsData = {}

  -- Feedback and Donation
  table.insert(optionsData, {type = "submenu", name = ERG.AddIconToString(ERG_FEEDBACK_SETTINGS, "esoui/art/icons/achievement_update11_dungeons_004.dds", 36, true) , controls = GetFeedbackSettingsMenu() } )
  -- General Settings
  table.insert(optionsData, {type = "submenu", name = ERG.AddIconToString(ERG_GENERAL_SETTINGS, "esoui/art/icons/achievement_u30_mainquest_2.dds", 36, true) , controls = GetGeneralSettingsMenu() } )

  table.insert(optionsData, {type = "divider"})

  -- Profile
  local function SetProfileSubmenuName()
    local submenuName = zo_strformat("<<1>>: <<2>>", ERG_PROFILE, ERG.profiles.GetCurrentName() )
    return ERG.AddIconToString(submenuName, "esoui/art/icons/achievement_u31_dun1_hard_mode_boss2.dds", 36, true)
  end
  table.insert(optionsData, {type = "submenu", name = function() return SetProfileSubmenuName() end, controls = GetProfileManagerMenu() } )
  table.insert(optionsData, {type = "divider"})

  -- Encounter
  for _, encounter in ipairs( ERG.GetEncounterList() ) do
    table.insert(optionsData, {type = "submenu", name = ERG.AddIconToString(encounter, ERG.GetEncounterIcons()[encounter], 36, true), controls = GetEncounterMenu(encounter) } )
  end

  LibAddonMenu2:RegisterAddonPanel("ERG_Menu", panelData)
  LibAddonMenu2:RegisterOptionControls("ERG_Menu", optionsData)
end


function ERG.GetBasicPanelMenu( encounter, panelName, ResizeFunc)
  local panel = ERG[encounter][panelName].panel

  local panelMenu = {}
  table.insert(panelMenu, {
    type = "checkbox",
    name = ERG_ENABLE_PANEL,
    getFunc = function() return ERG.store[encounter][panelName].enabled end,
    setFunc = function(bool)
      ERG.store[encounter][panelName].enabled = bool
      ERG.ClearArena()
      ERG.AnalyseBossSituation()
    end,
    width = "half",
  })
  table.insert(panelMenu, {
    type = "slider",
    name = ERG_SIZE,
    min = 1,
    max = 9,
    step = 1,
    getFunc = function() return ERG.store[encounter][panelName].size end,
    setFunc = function(value)
      ERG.store[encounter][panelName].size = value
      ResizeFunc()
    end,
    width = "half",
  })
  table.insert(panelMenu, {
    type = "checkbox",
    name = ERG_BACKGROUND,
    getFunc = function() return ERG.store[encounter][panelName].back.enabled end,
    setFunc = function(bool)
      ERG.store[encounter][panelName].back.enabled = bool
      panel.back:SetHidden(not bool)
    end,
    width = "half",
  })
  table.insert(panelMenu, {
    type = "slider",
    name = ERG_OPACITY,
    min = 0,
    max = 10,
    step = 1,
    getFunc = function() return 10*ERG.store[encounter][panelName].back.opacity end,
    setFunc = function(value)
      ERG.store[encounter][panelName].back.opacity = value / 10
      panel.back:SetCenterColor(0,0,0, value/10)
    end,
    width = "half",
  })
  return panelMenu
end



function ERG.InitializeMenuDialogs()
  ERG.dialogs = {
    preventEmptyName = "Rockgroover_Profile_PreventEmptyName",
    preventDublicateName = "Rockgroover_Profile_PreventDublicateName",
    preventLastProfileDelete = "Rockgroover_Profile_PreventLastProfileDelete",
    warningIngameMailServer = "Rockgroover_Menu_WarningIngameMailServer",
  }

  local dialogText = {
      preventEmptyName = ERG_DIALOG_PREVENT_EMPTY_NAME,
      preventDublicateName = ERG_DIALOG_PREVENT_DUPLICATE_NAME,
      preventLastProfileDelete = ERG_DIALOG_PREVENT_LAST_PROFILE_DELETE,
      warningIngameMailServer = ERG_DIALOG_WARNING_INGAME_MAIL_SERVER,

  }
  for key, identifier in pairs(ERG.dialogs) do
      ESO_Dialogs[identifier] = {
        canQueue = true,
        uniqueIdentifier = identifier,
        title = {text = ERG.displayNameWithIcon},
        mainText = {text = dialogText[key] },
        buttons = {
            [1] = {
                text = ERG_OK,
                callback = function() end
            },
        },
      }
  end
end
