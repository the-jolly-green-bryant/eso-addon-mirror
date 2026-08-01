local LAM = LibAddonMenu2

function PrismaticWarning.SettingsWindow()
  local panelData = {
    type = "panel",
    name = "Prismatic Warning",
    displayName = "Prismatic Warning",
    author = PrismaticWarning.author,
    version = PrismaticWarning.version,
    registerForRefresh = true,
    registerForDefaults = true,
  }
  
  local optionsData = {
    [1] = {
      type = "header",
      name = GetString(PRISMATICWARNING_MENU_OSA),
    },
    [2] = {
      type = "checkbox",
      name = GetString(PRISMATICWARNING_MENU_HIDE_OSA),
      tooltip = GetString(PRISMATICWARNING_MENU_HIDE_OSA_TT),
      default = PrismaticWarning.defaults.hideOnScreenAlert,
      getFunc = function() return PrismaticWarning.savedVariables.hideOnScreenAlert end,
      setFunc = function(newValue)
        PrismaticWarning.alertVisible(false, "") -- Fixes Issues #38, #39
        PrismaticWarning.savedVariables.hideOnScreenAlert = newValue
        if not newValue then
          PrismaticWarning.InitializeUI()
        end
      end,
    },
    [3] = {
      type = "checkbox",
      name = GetString(PRISMATICWARNING_MENU_SHOW_OSA),
      tooltip = GetString(PRISMATICWARNING_MENU_SHOW_OSA_TT),
      default = false,
      disabled = function() return PrismaticWarning.savedVariables.hideOnScreenAlert end,
      getFunc = function() return not PrismaticWarningWindow:IsHidden() end,
      setFunc = function(newValue)
        PrismaticWarning.alertVisible(newValue, GetString(PRISMATICWARNING_EQUIP_NOW))
      end,
    },
    [4] = {
      type = "checkbox",
      name = GetString(PRISMATICWARNING_MENU_OSA_IN_COMBAT),
      tooltip = GetString(PRISMATICWARNING_MENU_OSA_IN_COMBAT_TT),
      default = PrismaticWarning.defaults.hideOnScreenAlertInCombat,
      disabled = function() return PrismaticWarning.savedVariables.hideOnScreenAlert end,
      getFunc = function() return PrismaticWarning.savedVariables.hideOnScreenAlertInCombat end,
      setFunc = function(newValue)
        PrismaticWarning.savedVariables.hideOnScreenAlertInCombat = newValue
      end,
    },
    [5] = {
      type = "checkbox",
      name = GetString(PRISMATICWARNING_MENU_LOCK_OSA),
      tooltip = GetString(PRISMATICWARNING_MENU_LOCK_OSA_TT),
      default = PrismaticWarning.defaults.isLocked,
      disabled = function() return PrismaticWarning.savedVariables.hideOnScreenAlert end,
      getFunc = function() return PrismaticWarning.savedVariables.isLocked end,
      setFunc = function(newValue)
        PrismaticWarning.savedVariables.isLocked = newValue
        PrismaticWarningWindowLabelBG:SetMouseEnabled(not PrismaticWarning.savedVariables.isLocked)
      end,
    },
    [6] = {
      type = "dropdown",
      name = GetString(PRISMATICWARNING_MENU_FONT),
      tooltip = GetString(PRISMATICWARNING_MENU_FONT_TT),
      choices = {"Univers57", "Univers67", "FTN47", "FTN57", "FTN87", "ProseAntiquePSMT", "Handwritten_Bold", "TrajanPro-Regular"},
      default = string.match(PrismaticWarning.defaults.fontName, "([^\/.]+)\.[^.]*$"),
      disabled = function() return PrismaticWarning.savedVariables.hideOnScreenAlert end,
      getFunc = function() return string.match(PrismaticWarning.savedVariables.fontName, "([^\/.]+)\.[^.]*$") end,
      setFunc = function(newValue)
        PrismaticWarning.savedVariables.fontName = "EsoUI/Common/Fonts/" .. newValue .. ".otf"
        PrismaticWarning.updateFont()
      end,
    },
    [7] = {
      type = "slider",
      name = GetString(PRISMATICWARNING_MENU_FONT_SIZE),
      tooltip = GetString(PRISMATICWARNING_MENU_FONT_SIZE_TT),
      min = 20,
      max = 72,
      step = 1,
      default = PrismaticWarning.defaults.fontSize,
      disabled = function() return PrismaticWarning.savedVariables.hideOnScreenAlert end,
      getFunc = function() return PrismaticWarning.savedVariables.fontSize end,
      setFunc = function(newValue)
        PrismaticWarning.savedVariables.fontSize = newValue
        PrismaticWarning.updateFont()
      end,
    },
    [8] = {
      type = "slider",
      name = GetString(PRISMATICWARNING_MENU_INFO_FONT_SIZE),
      tooltip = GetString(PRISMATICWARNING_MENU_INFO_FONT_SIZE_TT),
      min = 10,
      max = 50,
      step = 1,
      default = PrismaticWarning.defaults.infoFontSize,
      disabled = function() return PrismaticWarning.savedVariables.hideOnScreenAlert end,
      getFunc = function() return PrismaticWarning.savedVariables.infoFontSize end,
      setFunc = function(newValue)
        PrismaticWarning.savedVariables.infoFontSize = newValue
        PrismaticWarning.updateFont()
      end,
    },
    [9] = {
      type = "dropdown",
      name = GetString(PRISMATICWARNING_MENU_OUTLINE),
      tooltip = GetString(PRISMATICWARNING_MENU_OUTLINE_TT),
      choices = {"thick-outline", "soft-shadow-thick", "soft-shadow-thin", "none" },
      default = PrismaticWarning.defaults.fontOutline,
      disabled = function() return PrismaticWarning.savedVariables.hideOnScreenAlert end,
      getFunc = function() return PrismaticWarning.savedVariables.fontOutline or "none" end,
      setFunc = function(newValue)
        PrismaticWarning.savedVariables.fontOutline = newValue
        PrismaticWarning.updateFont()
      end,
    },
    [10] = {
      type = "colorpicker",
      name = GetString(PRISMATICWARNING_MENU_COLOR),
      tooltip = GetString(PRISMATICWARNING_MENU_COLOR_TT),
      default = PrismaticWarning.defaults.fontColor,
      disabled = function() return PrismaticWarning.savedVariables.hideOnScreenAlert end,
      getFunc = function() return unpack(PrismaticWarning.savedVariables.fontColor) end,
      setFunc = function(r,g,b,a)
        PrismaticWarning.savedVariables.fontColor = {r, g, b, a}
        PrismaticWarningWindowLabel:SetColor(r, g, b, a)
        PrismaticWarningWindowInfo:SetColor(r, g, b, a)
      end,
    },
    [11] = {
      type = "header",
      name = GetString(PRISMATICWARNING_MENU_WHEN),
    },
    [12] = {
      type = "checkbox",
      name = GetString(PRISMATICWARNING_MENU_VET),
      tooltip = GetString(PRISMATICWARNING_MENU_VET_TT),
      default = PrismaticWarning.defaults.alertOnlyOnVet,
      getFunc = function() return PrismaticWarning.savedVariables.alertOnlyOnVet end,
      setFunc = function(newValue)
        PrismaticWarning.savedVariables.alertOnlyOnVet = newValue
        PrismaticWarning.settingsBypass = true
        PrismaticWarning.sorter()
      end,
    },
    [13] = {
      type = "checkbox",
      name = GetString(PRISMATICWARNING_MENU_DUNGEONS),
      tooltip = GetString(PRISMATICWARNING_MENU_DUNGEONS_TT),
      default = PrismaticWarning.defaults.alertInDungeons,
      getFunc = function() return PrismaticWarning.savedVariables.alertInDungeons end,
      setFunc = function(newValue)
        PrismaticWarning.savedVariables.alertInDungeons = newValue
        PrismaticWarning.settingsBypass = true
        PrismaticWarning.sorter()
      end,
    },
    [14] = {
      type = "checkbox",
      name = GetString(PRISMATICWARNING_MENU_P_DUNGEONS),
      tooltip = GetString(PRISMATICWARNING_MENU_P_DUNGEONS_TT),
      disabled = function() return not PrismaticWarning.savedVariables.alertInDungeons end,
      default = PrismaticWarning.defaults.alertInPartialDungeons,
      getFunc = function() return PrismaticWarning.savedVariables.alertInPartialDungeons end,
      setFunc = function(newValue)
        PrismaticWarning.savedVariables.alertInPartialDungeons = newValue
        PrismaticWarning.settingsBypass = true
        PrismaticWarning.sorter()
      end,
    },
    [15] = {
      type = "checkbox",
      name = GetString(PRISMATICWARNING_MENU_ARENAS),
      tooltip = GetString(PRISMATICWARNING_MENU_ARENAS_TT),
      default = PrismaticWarning.defaults.alertInArenas,
      getFunc = function() return PrismaticWarning.savedVariables.alertInArenas end,
      setFunc = function(newValue)
        PrismaticWarning.savedVariables.alertInArenas = newValue
        PrismaticWarning.settingsBypass = true
        PrismaticWarning.sorter()
      end,
    },
    [16] = {
      type = "checkbox",
      name = GetString(PRISMATICWARNING_MENU_TRIALS),
      tooltip = GetString(PRISMATICWARNING_MENU_TRIALS_TT),
      default = PrismaticWarning.defaults.alertInTrials,
      getFunc = function() return PrismaticWarning.savedVariables.alertInTrials end,
      setFunc = function(newValue)
        PrismaticWarning.savedVariables.alertInTrials = newValue
        PrismaticWarning.settingsBypass = true
        PrismaticWarning.sorter()
      end,
    },
    [17] = {
      type = "checkbox",
      name = GetString(PRISMATICWARNING_MENU_MAGDD),
      tooltip = GetString(PRISMATICWARNING_MENU_MAGDD_TT),
      default = PrismaticWarning.defaults.alertIfMagDD,
      getFunc = function() return PrismaticWarning.savedVariables.alertIfMagDD end,
      setFunc = function(newValue)
        PrismaticWarning.savedVariables.alertIfMagDD = newValue
        PrismaticWarning.settingsBypass = true
        PrismaticWarning.sorter()
      end,
    },
    [18] = {
      type = "checkbox",
      name = GetString(PRISMATICWARNING_MENU_STAMDD),
      tooltip = GetString(PRISMATICWARNING_MENU_STAMDD_TT),
      default = PrismaticWarning.defaults.alertIfStamDD,
      getFunc = function() return PrismaticWarning.savedVariables.alertIfStamDD end,
      setFunc = function(newValue)
        PrismaticWarning.savedVariables.alertIfStamDD = newValue
        PrismaticWarning.settingsBypass = true
        PrismaticWarning.sorter()
      end,
    },
    [19] = {
      type = "checkbox",
      name = GetString(PRISMATICWARNING_MENU_TANK),
      tooltip = GetString(PRISMATICWARNING_MENU_TANK_TT),
      default = PrismaticWarning.defaults.alertIfTank,
      getFunc = function() return PrismaticWarning.savedVariables.alertIfTank end,
      setFunc = function(newValue)
        PrismaticWarning.savedVariables.alertIfTank = newValue
        PrismaticWarning.settingsBypass = true
        PrismaticWarning.sorter()
      end,
    },
    [20] = {
      type = "checkbox",
      name = GetString(PRISMATICWARNING_MENU_HEAL),
      tooltip = GetString(PRISMATICWARNING_MENU_HEAL_TT),
      default = PrismaticWarning.defaults.alertIfHeal,
      getFunc = function() return PrismaticWarning.savedVariables.alertIfHeal end,
      setFunc = function(newValue)
        PrismaticWarning.savedVariables.alertIfHeal = newValue
        PrismaticWarning.settingsBypass = true
        PrismaticWarning.sorter()
      end,
    },
    [21] = {
      type = "checkbox",
      name = GetString(PRISMATICWARNING_MENU_UNDER_FIFTY),
      tooltip = GetString(PRISMATICWARNING_MENU_UNDER_FIFTY_TT),
      default = PrismaticWarning.defaults.alertIfUnderFifty,
      getFunc = function() return PrismaticWarning.savedVariables.alertIfUnderFifty end,
      setFunc = function(newValue)
        PrismaticWarning.savedVariables.alertIfUnderFifty = newValue
        PrismaticWarning.settingsBypass = true
        PrismaticWarning.sorter()
      end,
    },
    [22] = {
      type = "header",
      name = GetString(PRISMATICWARNING_MENU_OTHER),
    },
    [23] = {
      type = "checkbox",
      name = GetString(PRISMATICWARNING_MENU_CHAT),
      tooltip = GetString(PRISMATICWARNING_MENU_CHAT_TT),
      default = PrismaticWarning.defaults.alertToChat,
      getFunc = function() return PrismaticWarning.savedVariables.alertToChat end,
      setFunc = function(newValue)
        PrismaticWarning.savedVariables.alertToChat = newValue
      end,
    },
    [24] = {
      type = "slider",
      name = GetString(PRISMATICWARNING_MENU_RR),
      tooltip = GetString(PRISMATICWARNING_MENU_RR_TT),
      warning = GetString(PRISMATICWARNING_MENU_RR_WARN),
      min = 500,
      max = 5000,
      step = 100,
      default = PrismaticWarning.defaults.refreshRate,
      getFunc = function() return PrismaticWarning.savedVariables.refreshRate end,
      setFunc = function(newValue)
        PrismaticWarning.savedVariables.refreshRate = newValue
        PrismaticWarning.sorter()
      end,
    },
    [25] = {
      type = "dropdown",
      name = GetString(PRISMATICWARNING_MENU_AUTO_SWAP),
      tooltip = GetString(PRISMATICWARNING_MENU_AUTO_SWAP_TT),
      warning = GetString(PRISMATICWARNING_MENU_AUTO_SWAP_WARN),
      choices = {GetString(PRISMATICWARNING_MENU_FRONT_BAR), GetString(PRISMATICWARNING_MENU_BACK_BAR), GetString(PRISMATICWARNING_MENU_DONT)},
      default = PrismaticWarning.defaults.autoSwapTo,
      getFunc = function() return PrismaticWarning.savedVariables.autoSwapTo end,
      setFunc = function(newValue)
        PrismaticWarning.savedVariables.autoSwapTo = newValue
        if newValue == GetString(PRISMATICWARNING_MENU_FRONT_BAR) then
          PrismaticWarning.savedVariables.equipSlot = EQUIP_SLOT_MAIN_HAND
          PrismaticWarning.savedVariables.poisonSlot = EQUIP_SLOT_POISON
        elseif newValue == GetString(PRISMATICWARNING_MENU_BACK_BAR) then
          PrismaticWarning.savedVariables.equipSlot = EQUIP_SLOT_BACKUP_MAIN
          PrismaticWarning.savedVariables.poisonSlot = EQUIP_SLOT_BACKUP_POISON
        elseif newValue == GetString(PRISMATICWARNING_MENU_DONT) then
          PrismaticWarning.savedVariables.equipSlot = nil
          PrismaticWarning.savedVariables.poisonSlot = nil
        end
        PrismaticWarning.lastCall = nil
      end,
    },
    [26] = {
      type = "checkbox",
      name = GetString(PRISMATICWARNING_MENU_DEBUG),
      tooltip = GetString(PRISMATICWARNING_MENU_DEBUG_TT),
      default = PrismaticWarning.defaults.debugAlerts,
      getFunc = function() return PrismaticWarning.savedVariables.debugAlerts end,
      setFunc = function(newValue)
        PrismaticWarning.savedVariables.debugAlerts = newValue
      end,
    },
  }
  
  local panel = LAM:RegisterAddonPanel("PrismaticWarningMenu", panelData)
  local options = LAM:RegisterOptionControls("PrismaticWarningMenu", optionsData)
end