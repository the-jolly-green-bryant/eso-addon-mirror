function InventorySpaceWarning.InitializeSettings()
  local LAM = LibAddonMenu2
  local constants = InventorySpaceWarning.Constants
  local savedVars = InventorySpaceWarning.savedVariables

  local panelData = {
    type = "panel",
    name = "Inventory Space Warning",
    author = "Pachvara",
    slashCommand = "/inventorySpaceWarning",
    registerForRefresh = true,
    registerForDefaults = false,
  }

  local createIcon, icon

  createIcon = function(panel)
    InventorySpaceWarning.logger:Debug("Recieved callback: %s", panel)
    if panel == InventorySpaceWarningSettingsPanel then
      icon = WINDOW_MANAGER:CreateControl(nil, panel.controlsToRefresh[4], CT_TEXTURE)
      icon:SetColor(1, 0, 0, 1)
      icon:SetAnchor(RIGHT, panel.controlsToRefresh[4].combobox, LEFT, -10, 0)
      icon:SetTexture(constants.iconsValues[savedVars.icon])
      icon:SetDimensions(40, 40)

      CALLBACK_MANAGER:UnregisterCallback("LAM-PanelControlsCreated", createIcon)
    end
  end

  CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", createIcon)

  local optionsTable = {
    [1] = {
      type = "checkbox",
      name = "Always show",
      tooltip = "Indicator will be always shown on the screen. It is useful if you want to always be aware of free space left.",
      getFunc = function() return savedVars.alwaysShow end,
      setFunc = function(value) InventorySpaceWarning.UpdateAlwaysShowState(value) end,
      width = "full"
    },
    [2] = {
      type = "slider",
      name = "Warn at",
      tooltip = "Red indicator will be shown when this amount of the inventory space is left",
      min = 1,
      max = 210,
      step = 1,
      getFunc = function() return savedVars.spaceLimit end,
      setFunc = function(value) InventorySpaceWarning.UpdateSpaceLimit(value) end,
    },
    [3] = {
      type = "checkbox",
      name = "Show Label",
      getFunc = function() return savedVars.labelVisibility end,
      setFunc = function(value) InventorySpaceWarning.UpdateLabelVisibility(value) end,
      width = "full"
    },
    [4] = {
      type = "header",
      name = "Icon Settings",
      width = "full",
    },
    [5] = {
      type = "dropdown",
      name = "Icon",
      choices = constants.iconsKeys,
      choicesValues = constants.iconsKeys,
      getFunc = function() return savedVars.icon end,
      setFunc = function(value)
        icon:SetTexture(constants.iconsValues[value])
        InventorySpaceWarning.UpdateIcon(value)
      end
    },
    [6] = {
      type = "slider",
      name = "Icon size",
      min = 20,
      max = 100,
      step = 1,
      getFunc = function() return savedVars.iconSize end,
      setFunc = function(value) InventorySpaceWarning.UpdateIconSize(value) end,
    },
  }
  LAM:RegisterAddonPanel(constants.settingPanelName, panelData)
  LAM:RegisterOptionControls(constants.settingPanelName, optionsTable)
end
