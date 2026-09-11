-- EsoAR menu: an (initially empty) gamepad list screen titled "EsoAR".
-- Opened from the "EsoAR" entry in the gamepad main menu or with /esoar menu.
-- Entries are added later, one step at a time, in EsoAR.MENU_ITEMS.

local SCENE_NAME = "EsoAR_MenuScene"

local function L(key) return (EsoAR.L and EsoAR.L[key]) or key end

-- Switches: value(true) = Arabic. `key` is the saved variable; `invert` means
-- the saved variable stores "English" so the displayed state is its opposite.
local function switch(labelKey, key, invert, apply)
  return {
    label = L(labelKey),
    icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_settings.dds",
    value = function()
      local v = EsoAR.savedVars[key]
      if invert then v = not v end
      return v and L("ON") or L("OFF")
    end,
    onSelect = function()
      EsoAR.savedVars[key] = not EsoAR.savedVars[key]
      if apply then apply() end
      PlaySound(SOUNDS.DEFAULT_CLICK)
    end,
  }
end

EsoAR.MENU_ITEMS = {
  switch("TG_TRAITS", "englishTraits", true, function() EsoAR:ApplyTraitNames() end),
  switch("TG_SETS", "englishSets", true, nil),
  switch("TG_DIGITS", "arabicDigits", false, function() EsoAR:ApplyFonts() end),
  switch("TG_ZONES", "englishZones", true, nil),
}

local Menu = ZO_Gamepad_ParametricList_Screen:Subclass()

function Menu:New(...)
  return ZO_Gamepad_ParametricList_Screen.New(self, ...)
end

function Menu:Initialize(control)
  EsoAR.menuScene = ZO_Scene:New(SCENE_NAME, SCENE_MANAGER)
  EsoAR.menuScene:AddFragment(ZO_FadeSceneFragment:New(control))
  if FRAGMENT_GROUP and FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW then
    EsoAR.menuScene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
  end
  if FRAGMENT_GROUP and FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD then
    EsoAR.menuScene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
  end
  if KEYBIND_STRIP_GAMEPAD_FRAGMENT then EsoAR.menuScene:AddFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT) end
  if GAMEPAD_MENU_SOUND_FRAGMENT then EsoAR.menuScene:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT) end

  ZO_Gamepad_ParametricList_Screen.Initialize(self, control, ZO_GAMEPAD_HEADER_TABBAR_DONT_CREATE, true, EsoAR.menuScene)
  self.headerData = { titleText = "EsoAR" }
end

function Menu:SetupList(list)
  list:AddDataTemplate("ZO_GamepadMenuEntryTemplate", ZO_SharedGamepadEntry_OnSetup, ZO_GamepadMenuEntryTemplateParametricListFunction)
  list:AddDataTemplateWithHeader("ZO_GamepadMenuEntryTemplate", ZO_SharedGamepadEntry_OnSetup, ZO_GamepadMenuEntryTemplateParametricListFunction, nil, "ZO_GamepadMenuEntryHeaderTemplate")
end

function Menu:PopulateList()
  local list = self:GetMainList()
  local selected = list:GetSelectedIndex()
  list:Clear()
  for i, item in ipairs(EsoAR.MENU_ITEMS) do
    local entry = ZO_GamepadEntryData:New(item.label, item.icon)
    entry.esoar = item
    if item.value then entry:AddSubLabel(item.value()) end
    if i == 1 then
      entry:SetHeader(L("MENU_TEXT_HINT"))
      list:AddEntryWithHeader("ZO_GamepadMenuEntryTemplate", entry)
    else
      list:AddEntry("ZO_GamepadMenuEntryTemplate", entry)
    end
  end
  list:Commit()
  if selected and selected > 0 then list:SetSelectedIndexWithoutAnimation(selected) end
end

function Menu:PerformUpdate()
  self.dirty = false
  self:PopulateList()
  ZO_GamepadGenericHeader_Refresh(self.header, self.headerData)
  KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
end

function Menu:InitializeKeybindStripDescriptors()
  self.keybindStripDescriptor = {
    alignment = KEYBIND_STRIP_ALIGN_LEFT,
    {
      name = GetString(SI_GAMEPAD_SELECT_OPTION),
      keybind = "UI_SHORTCUT_PRIMARY",
      callback = function()
        local data = self:GetMainList():GetTargetData()
        if data and data.esoar and data.esoar.onSelect then
          data.esoar.onSelect()
          self:PopulateList()
        end
      end,
      visible = function() return #EsoAR.MENU_ITEMS > 0 end,
    },
  }
  ZO_Gamepad_AddBackNavigationKeybindDescriptors(self.keybindStripDescriptor, GAME_NAVIGATION_TYPE_BUTTON)
end

function Menu:OnShowing()
  self.dirty = true
  ZO_Gamepad_ParametricList_Screen.OnShowing(self)
end

function EsoAR_Menu_OnInitialized(control)
  EsoAR.menu = Menu:New(control)
end

function EsoAR:OpenMenu()
  if not EsoAR.menuScene then return false end
  if SCENE_MANAGER:IsShowing(SCENE_NAME) then return true end
  if SCENE_MANAGER:IsShowingBaseScene() then SCENE_MANAGER:Show(SCENE_NAME) else SCENE_MANAGER:Push(SCENE_NAME) end
  return true
end

-- "EsoAR" entry in the gamepad main menu (same list the game builds from ZO_MENU_ENTRIES).
function EsoAR:AddMainMenuEntry()
  if not ZO_MENU_ENTRIES or not ZO_GamepadEntryData then return end
  for _, e in ipairs(ZO_MENU_ENTRIES) do
    if e.data and e.data.esoarMenu then return end
  end
  local data = {
    name = "EsoAR",
    icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_addons.dds",
    esoarMenu = true,
    activatedCallback = function() EsoAR:OpenMenu() end,
  }
  local entry = ZO_GamepadEntryData:New(data.name, data.icon)
  entry.data = data
  entry.id = #ZO_MENU_ENTRIES + 1
  table.insert(ZO_MENU_ENTRIES, entry)
  if MAIN_MENU_GAMEPAD and MAIN_MENU_GAMEPAD.RefreshMainList then
    pcall(function() MAIN_MENU_GAMEPAD:RefreshMainList() end)
  end
end
