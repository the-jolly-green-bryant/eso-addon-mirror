GP = {name = "CustomGraphicsPresets"}

GP.settingList = {

--Options_Video_AntiAliasing_Type
GRAPHICS_SETTING_ANTIALIASING_TYPE,

--Options_Video_Graphics_Quality
GRAPHICS_SETTING_PRESETS,

--Options_Video_Texture_Resolution
GRAPHICS_SETTING_MIP_LOAD_SKIP_LEVELS,

--Options_Video_DLSS_Mode
GRAPHICS_SETTING_DLSS_MODE,

--Options_Video_FSR_Mode 
GRAPHICS_SETTING_FSR_MODE,

--Options_Video_Sub_Sampling
GRAPHICS_SETTING_SUB_SAMPLING,

--Options_Video_Shadows
GRAPHICS_SETTING_SHADOWS,

--Options_Video_Screenspace_Water_Reflection_Quality
GRAPHICS_SETTING_SCREENSPACE_WATER_REFLECTION_QUALITY,

--Options_Video_Planar_Water_Reflection_Quality
GRAPHICS_SETTING_PLANAR_WATER_REFLECTION_QUALITY,

 --Options_Video_Maximum_Particle_Systems
GRAPHICS_SETTING_PFX_GLOBAL_MAXIMUM,

--Options_Video_Particle_Suppression_Distance
GRAPHICS_SETTING_PFX_SUPPRESS_DISTANCE,

--Options_Video_View_Distance
GRAPHICS_SETTING_VIEW_DISTANCE,

--Options_Video_Ambient_Occlusion
GRAPHICS_SETTING_AMBIENT_OCCLUSION_TYPE,

--Options_Video_Occlusion_Culling_Enabled
GRAPHICS_SETTING_OCCLUSION_CULLING_ENABLED,

--Options_Video_Clutter_2D_Quality
GRAPHICS_SETTING_CLUTTER_2D_QUALITY,

--Options_Video_Depth_Of_Field_Mode
GRAPHICS_SETTING_DEPTH_OF_FIELD_MODE,

--Options_Video_Bloom
GRAPHICS_SETTING_BLOOM,

--Options_Video_Distortion
GRAPHICS_SETTING_DISTORTION,

--Options_Video_God_Rays
GRAPHICS_SETTING_GOD_RAYS,

-- ?
GRAPHICS_SETTING_SHOW_ADDITIONAL_ALLY_EFFECTS,

}

local function SetAllSettings()
  local selectedPreset = nil

  for i=1, #GP.savedVariables.presets do
    if Options_Video_Graphics_PresetsDropdown.m_comboBox:GetSelectedItem() == GP.savedVariables.presets[i].name then
      selectedPreset = GP.savedVariables.presets[i]
    end
  end

  for i=1, #GP.settingList do
    if GetSetting(SETTING_TYPE_GRAPHICS, GP.settingList[i]) ~= selectedPreset.settings[1][i] then
      SetSetting(SETTING_TYPE_GRAPHICS, GP.settingList[i], selectedPreset.settings[1][i])
    end
  end

  KEYBOARD_OPTIONS:UpdateCurrentPanelOptions(SAVE_CURRENT_VALUES)
end

local function GetAllSettings()
  local settings = {}
  for i=1, #GP.settingList do

      table.insert(settings, GetSetting(SETTING_TYPE_GRAPHICS, GP.settingList[i]))

  end
  return settings
end

local function ItemCallback(self, itemName, item, selectionChanged, oldItem)
  GP.savedVariables.lastActivePreset = itemName
  SetAllSettings()
end

function GP.OverwritePreset(presetIndex)
  GP.savedVariables.presets[presetIndex].settings = { GetAllSettings() }
  for i=1, #Options_Video_Graphics_PresetsDropdown.m_comboBox.m_sortedItems do
    if string.match(GP.savedVariables.presets[presetIndex].name, Options_Video_Graphics_PresetsDropdown.m_comboBox.m_sortedItems[i].name) then
      Options_Video_Graphics_PresetsDropdown.m_comboBox:SelectItem(Options_Video_Graphics_PresetsDropdown.m_comboBox.m_sortedItems[i], true)
    end
  end
  GP.savedVariables.lastActivePreset = GP.savedVariables.presets[presetIndex].name
end

function GP.DeletePreset()
  local selectedItem = Options_Video_Graphics_PresetsDropdown.m_comboBox:GetSelectedItemData()
  if selectedItem ~= nil then
    table.remove(Options_Video_Graphics_PresetsDropdown.m_comboBox:GetItems(), selectedItem.m_index)
    for i=1, #GP.savedVariables.presets do
      if GP.savedVariables.presets[i].name == selectedItem.name then
        table.remove(GP.savedVariables.presets, i)
        break
      end
    end
    Options_Video_Graphics_PresetsDropdown.m_comboBox.m_selectedItemData = nil
    Options_Video_Graphics_PresetsDropdown.m_comboBox:SetSelectedItemText("")
    GP.savedVariables.lastActivePreset = ""
  end
end

function GP.AddPreset(name)
  if #GP.savedVariables.presets >= GP.savedVariables.maxPresets then
    ZO_Dialogs_ShowDialog("GraphicsPresetsLimitExceeded")
    return
  end

  local data = {name = name, settings = { GetAllSettings() }}
  table.insert(GP.savedVariables.presets, data)
  local entry = Options_Video_Graphics_PresetsDropdown.m_comboBox:CreateItemEntry(name, ItemCallback, true)
  local item = Options_Video_Graphics_PresetsDropdown.m_comboBox:AddItem(entry)
  Options_Video_Graphics_PresetsDropdown.m_comboBox:SelectItem(entry, true)
  GP.savedVariables.lastActivePreset = name
end

function GP.InitPresets()
  local itemEntries = {}

  for i=1, #GP.savedVariables.presets do
    local entry = Options_Video_Graphics_PresetsDropdown.m_comboBox:CreateItemEntry(GP.savedVariables.presets[i].name, ItemCallback, true)
    table.insert(itemEntries, entry)
    if GP.savedVariables.lastActivePreset ~= "" and GP.savedVariables.presets[i].name == GP.savedVariables.lastActivePreset then
      Options_Video_Graphics_PresetsDropdown.m_comboBox:SelectItem(entry, true)
    end
  end
    Options_Video_Graphics_PresetsDropdown.m_comboBox:AddItems(itemEntries)
end

function GP.Initialize()
  GP.savedVariables = ZO_SavedVars:NewAccountWide("GPSavedVariables", 1, nil, {presets = {}, lastActivePreset = "", maxPresets = 10})

  GP.InitAddonMenu()

  for i=1, #KEYBOARD_OPTIONS.controlTable[1] do
    if(KEYBOARD_OPTIONS.controlTable[1][i]:GetName():find("Header3")) then
      local _isValidAnchor_, _point_, _relativeTo_, _relativePoint_, _offsetX_, _offsetY_, _anchorConstrains_ = KEYBOARD_OPTIONS.controlTable[1][i+1]:GetAnchor(0)
      if _isValidAnchor_ then
        KEYBOARD_OPTIONS.controlTable[1][i+1]:SetAnchorOffsets(_offsetX_, _offsetY_+70, 1)
      end
    end
  end

  GP.InitPresets()

  local submenu = CreateControl("GraphicsPresetsSubmenu", ZO_OptionsWindowSettingsScrollChild, CT_CONTROL)
  submenu:ClearAnchors()
  submenu:SetAnchor(TOPLEFT, KEYBOARD_OPTIONS.controlTable[1][#KEYBOARD_OPTIONS.controlTable[1]-1], TOPLEFT, 0, 50)
  submenu:SetWidth(570)
  submenu:SetHeight(40)

  local panel = GP.RegisterAddonPanel(submenu, "GraphicsPresetsSubmenuPanel", { type = "panel",
  name = "",
  displayName = "",
  registerForRefresh = true,
  registerForDefaults = true	})

  table.insert(KEYBOARD_OPTIONS.controlTable[1], panel)

  panel.scroll = nil

  GP.CreateOptions(panel, GP.usersettings)

  for i=2, #panel.controlsToRefresh do
    if panel.controlsToRefresh[i].data.default == nil then
      panel.controlsToRefresh[i].data.default = GP.usersettings[1].controls[i-1].default
    end
  end

  panel.ForceDefaults(panel)
  panel:SetHidden(false)
end

function GP.OnAddOnLoaded(event, addonName)
  if addonName == GP.name then
    GP.Initialize()
    EVENT_MANAGER:UnregisterForEvent(GP.name..'OnLoaded', EVENT_ADD_ON_LOADED)
  end
end

EVENT_MANAGER:RegisterForEvent(GP.name..'OnLoaded', EVENT_ADD_ON_LOADED, GP.OnAddOnLoaded)