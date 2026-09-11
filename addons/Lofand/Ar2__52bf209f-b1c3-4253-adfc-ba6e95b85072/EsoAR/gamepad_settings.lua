-- EsoAR gamepad settings screen.
--
-- A ZO_Gamepad_ParametricList_Screen subclass: the exact list widget the game
-- uses for Help/Options in gamepad mode. Up/Down selects a setting, Left/Right
-- (D-pad or stick) or A / X change its value, Y resets everything, B goes back.
-- Reached from the "Arabic Localization" entry in the gamepad main menu, from
-- /esoar, or from EsoAR:OpenGamepadSettings().

local CATS = { "heading", "body", "dialogue", "tooltip", "chat", "book" }
local SIZE_STEP, SIZE_MIN, SIZE_MAX = 5, 50, 200
local WIDTH_STEP, WIDTH_MAX = 20, 1200
local SCENE_NAME = "EsoAR_GamepadSettingsScene"

local function L(key) return (EsoAR.L and EsoAR.L[key]) or key end

local Screen = ZO_Gamepad_ParametricList_Screen:Subclass()

function Screen:New(...)
  return ZO_Gamepad_ParametricList_Screen.New(self, ...)
end

function Screen:Initialize(control)
  EsoAR.gamepadScene = ZO_Scene:New(SCENE_NAME, SCENE_MANAGER)
  EsoAR.gamepadScene:AddFragment(ZO_FadeSceneFragment:New(control))
  if FRAGMENT_GROUP and FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW then
    EsoAR.gamepadScene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
  end
  if FRAGMENT_GROUP and FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD then
    EsoAR.gamepadScene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
  end
  if KEYBIND_STRIP_GAMEPAD_FRAGMENT then EsoAR.gamepadScene:AddFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT) end
  if GAMEPAD_MENU_SOUND_FRAGMENT then EsoAR.gamepadScene:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT) end

  local ACTIVATE_ON_SHOW = true
  ZO_Gamepad_ParametricList_Screen.Initialize(self, control, ZO_GAMEPAD_HEADER_TABBAR_DONT_CREATE, ACTIVATE_ON_SHOW, EsoAR.gamepadScene)

  self.headerData = { titleText = L("WIN_TITLE") }
  if ZO_MovementController and MOVEMENT_CONTROLLER_DIRECTION_HORIZONTAL then
    self.horizontal = ZO_MovementController:New(MOVEMENT_CONTROLLER_DIRECTION_HORIZONTAL)
  end
end

-- ------------------------------------------------------------------ list
function Screen:SetupList(list)
  list:AddDataTemplate("ZO_GamepadMenuEntryTemplate", ZO_SharedGamepadEntry_OnSetup, ZO_GamepadMenuEntryTemplateParametricListFunction)
  list:AddDataTemplateWithHeader("ZO_GamepadMenuEntryTemplate", ZO_SharedGamepadEntry_OnSetup, ZO_GamepadMenuEntryTemplateParametricListFunction, nil, "ZO_GamepadMenuEntryHeaderTemplate")
end

local function valueText(item)
  local sv = EsoAR.savedVars
  if item.kind == "font" then
    return L("FONT_" .. (sv.fonts[item.cat] or "noto"))
  elseif item.kind == "size" then
    return tostring(sv.scale[item.cat] or 100) .. "%"
  elseif item.kind == "width" then
    local w = sv.dialogueWidth or 0
    return w == 0 and L("DEFAULT_WIDTH") or tostring(w)
  end
  return nil
end

local function addItem(list, item, header)
  local entry = ZO_GamepadEntryData:New(item.label, item.icon)
  entry.esoar = item
  local v = valueText(item)
  if v then entry:AddSubLabel(v) end
  if header then
    entry:SetHeader(header)
    list:AddEntryWithHeader("ZO_GamepadMenuEntryTemplate", entry)
  else
    list:AddEntry("ZO_GamepadMenuEntryTemplate", entry)
  end
end

function Screen:PopulateList()
  local list = self:GetMainList()
  local selected = list:GetSelectedIndex()
  list:Clear()
  for i, cat in ipairs(CATS) do
    addItem(list, { kind = "font", cat = cat, label = L("CAT_" .. cat) }, i == 1 and L("H_FONTS") or nil)
  end
  addItem(list, { kind = "action", action = "all", label = L("APPLY_ALL") })
  for i, cat in ipairs(CATS) do
    addItem(list, { kind = "size", cat = cat, label = L("CAT_" .. cat) }, i == 1 and L("H_SIZES") or nil)
  end
  addItem(list, { kind = "width", label = L("DLG_WIDTH") }, L("H_DIALOGUE"))
  addItem(list, { kind = "action", action = "reset", label = L("RESET") }, L("H_TOOLS"))
  addItem(list, { kind = "action", action = "reload", label = L("RELOAD") })
  list:Commit()
  if selected and selected > 0 then list:SetSelectedIndexWithoutAnimation(selected) end
end

function Screen:PerformUpdate()
  self.dirty = false
  self:PopulateList()
  ZO_GamepadGenericHeader_Refresh(self.header, self.headerData)
  KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
end

-- ------------------------------------------------------------ behaviour
function Screen:Adjust(dir)
  local data = self:GetMainList():GetTargetData()
  local item = data and data.esoar
  if not item then return end
  local sv = EsoAR.savedVars
  if item.kind == "font" then
    local idx = 1
    for i, f in ipairs(EsoAR.FONTS) do if f.key == sv.fonts[item.cat] then idx = i end end
    idx = idx + dir
    if idx < 1 then idx = #EsoAR.FONTS elseif idx > #EsoAR.FONTS then idx = 1 end
    sv.fonts[item.cat] = EsoAR.FONTS[idx].key
  elseif item.kind == "size" then
    sv.scale[item.cat] = math.max(SIZE_MIN, math.min(SIZE_MAX, (sv.scale[item.cat] or 100) + dir * SIZE_STEP))
  elseif item.kind == "width" then
    sv.dialogueWidth = math.max(0, math.min(WIDTH_MAX, (sv.dialogueWidth or 0) + dir * WIDTH_STEP))
  elseif item.kind == "action" then
    if item.action == "all" then
      for _, cat in ipairs(CATS) do sv.fonts[cat] = sv.fonts.heading end
    elseif item.action == "reset" then
      EsoAR:ResetSettings()
    elseif item.action == "reload" then
      ReloadUI()
      return
    end
  end
  EsoAR:ApplyFonts()
  PlaySound(SOUNDS.DEFAULT_CLICK)
  self:PopulateList()
end

function Screen:InitializeKeybindStripDescriptors()
  self.keybindStripDescriptor = {
    alignment = KEYBIND_STRIP_ALIGN_LEFT,
    {
      name = L("KB_NEXT"),
      keybind = "UI_SHORTCUT_PRIMARY",
      callback = function() self:Adjust(1) end,
    },
    {
      name = L("KB_PREV"),
      keybind = "UI_SHORTCUT_SECONDARY",
      callback = function() self:Adjust(-1) end,
    },
    {
      name = L("KB_RESET"),
      keybind = "UI_SHORTCUT_TERTIARY",
      callback = function()
        EsoAR:ResetSettings()
        self:PopulateList()
      end,
    },
  }
  ZO_Gamepad_AddBackNavigationKeybindDescriptors(self.keybindStripDescriptor, GAME_NAVIGATION_TYPE_BUTTON)
end

-- Left/Right on D-pad or left stick changes the selected value.
function Screen:UpdateDirectionalInput()
  if not self.horizontal then return end
  local move = self.horizontal:CheckMovement()
  if move == MOVEMENT_CONTROLLER_MOVE_NEXT then
    self:Adjust(1)
  elseif move == MOVEMENT_CONTROLLER_MOVE_PREVIOUS then
    self:Adjust(-1)
  end
end

function Screen:OnShowing()
  self.dirty = true
  ZO_Gamepad_ParametricList_Screen.OnShowing(self)
end

function Screen:OnShow()
  ZO_Gamepad_ParametricList_Screen.OnShow(self)
  if DIRECTIONAL_INPUT and self.horizontal then DIRECTIONAL_INPUT:Activate(self, self.control) end
end

function Screen:OnHide()
  if DIRECTIONAL_INPUT and self.horizontal then DIRECTIONAL_INPUT:Deactivate(self) end
  ZO_Gamepad_ParametricList_Screen.OnHide(self)
end

-- ------------------------------------------------------------ entry points
function EsoAR_GamepadSettings_OnInitialized(control)
  EsoAR.gamepadSettings = Screen:New(control)
end

function EsoAR:OpenGamepadSettings()
  if not EsoAR.gamepadScene then return false end
  if SCENE_MANAGER:IsShowing(SCENE_NAME) then return true end
  -- Push keeps the main menu underneath so B returns to it.
  if SCENE_MANAGER:IsShowingBaseScene() then
    SCENE_MANAGER:Show(SCENE_NAME)
  else
    SCENE_MANAGER:Push(SCENE_NAME)
  end
  return true
end
