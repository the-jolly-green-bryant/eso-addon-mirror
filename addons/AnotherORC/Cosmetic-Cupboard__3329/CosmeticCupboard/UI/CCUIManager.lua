
local CCUIManager = ZO_Object:Subclass()

function CCUIManager:New(...)
  local uiManager = ZO_Object.New(self)
  uiManager:Initialize(...)
  return uiManager
end

function CCUIManager:Initialize(sceneName, control)

  -- Predefine some variables
  control.owner = self
  self.control = control

  -- Assign our controller
  self.sceneName  = sceneName
  self.isVisable = false

  self.collectionUI = CCUICollection:New(WINDOW_MANAGER:GetControlByName("CC_Panel_Collection"))
  self.characterUI  = CCUICharacter:New(WINDOW_MANAGER:GetControlByName("CC_Panel"))

  self.profileDropdown = nil
  self.currentProfileName = nil
  self.currentProfile = {}

  self.globalControl = WINDOW_MANAGER:GetControlByName("CC_PanelSettingsPanelIsGlobal")

  -- Setup up more stuff
  self:DeferredInitializeHub()

  -- Initiate popup panels
  self:InitNewProfileDialog()
  self:InitSaveProfileDialog()
  self:InitDeleteProfileDialog()
  self:InitEditProfileDialog()
  self:InitImportProfileDialog()
end

function CCUIManager:GetCurrentProfileData()
  return self.currentProfile
end

--[[
  Register the CC scene
]]--
function CCUIManager:DeferredInitializeHub()

  -- Create a usable scene
  self.scene      = ZO_Scene:New(self.sceneName, SCENE_MANAGER)
  self.scene:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)

  self.fragment   = ZO_SimpleSceneFragment:New(self.control)
  self.fragmentCollection = ZO_SimpleSceneFragment:New(CC_Panel_Collection)

  self.scene:AddFragment(CODEX_WINDOW_SOUNDS)

  self.scene:AddFragment(MOUSE_UI_MODE_FRAGMENT)
  self.scene:AddFragment(KEYBIND_STRIP_FADE_FRAGMENT)
  self.scene:AddFragment(KEYBIND_STRIP_MUNGE_BACKDROP_FRAGMENT)
  self.scene:AddFragment(UI_SHORTCUTS_ACTION_LAYER_FRAGMENT)
  self.scene:AddFragment(CLEAR_CURSOR_FRAGMENT)
  self.scene:AddFragment(UI_COMBAT_OVERLAY_FRAGMENT)
  self.scene:AddFragment(END_IN_WORLD_INTERACTIONS_FRAGMENT)
  self.scene:AddFragment(FRAME_TARGET_STANDARD_RIGHT_PANEL_FRAGMENT)
  self.scene:AddFragment(FRAME_TARGET_BLUR_STANDARD_RIGHT_PANEL_FRAGMENT)
  self.scene:AddFragment(FRAME_PLAYER_FRAGMENT)
  self.scene:AddFragment(PLAYER_PROGRESS_BAR_FRAGMENT)
  self.scene:AddFragment(PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT)
  self.scene:AddFragment(RIGHT_BG_ITEM_PREVIEW_OPTIONS_FRAGMENT)
  self.scene:AddFragment(ITEM_PREVIEW_KEYBOARD:GetFragment())

  self.scene:AddFragment(self.fragment)
  self.scene:AddFragment(self.fragmentCollection)

  self.scene:AddFragment(TREE_UNDERLAY_FRAGMENT)
  self.scene:AddFragment(TOP_BAR_FRAGMENT)

  local categoryInfo =
  {
    descriptor = self.sceneName,
    binding = "SI_KEYBINDINGS_LAYER_GENERAL",
    callback = CCUIManager.ShowCCAction,
    visible = function() return true end,
    normal    = "CosmeticCupboard/assets/CCLogo5.1.dds",
    pressed   = "CosmeticCupboard/assets/CCLogo5.1.dds",
    highlight = "CosmeticCupboard/assets/CCLogo5.1.dds",
    disabled  = "CosmeticCupboard/assets/CCLogo5.1.dds",
  }

  ZO_MenuBar_AddButton(MAIN_MENU_KEYBOARD.categoryBar, categoryInfo)

  self:RegisterEvents()
end

--[[
  Register Events
]]--
do

  --[ EVENTS ]--
  function CCUIManager:OnCCShown()
    CC_CALLBACK_MANAGER:FireCallbacks(CC_ON_PANEL_OPENED)
  end

  function CCUIManager:OnCCHiden()
    CC_CALLBACK_MANAGER:FireCallbacks(CC_ON_PANEL_CLOSED)
  end

  function CCUIManager:RegisterEvents()

    ZO_CallbackObject.RegisterCallback(self.scene, "StateChange", function(oldState, newState)
      if newState == SCENE_SHOWN then
        self:OnCCShown()
      elseif newState == SCENE_HIDING then
        self:OnCCHiden()
      end
    end)
  end
end

--- Create dropdown menu.
-- Create or updates the drop down menu with the
-- current avaliable outfits
-- @param outfitName Default dropwn value to select
function CCUIManager:SetupProfileCombo()

  local function OnProfileSelected(profileName)
    self:LoadProfile(profileName)
    CC_CALLBACK_MANAGER:FireCallbacks(CC_ON_PROFILE_CHANGED, profileName)
  end

  -- List is saved profiles
  local profiles = CC.data:GetProfiles()

  local profileController = WINDOW_MANAGER:GetControlByName("CC_PanelProfilePanelProfileSelect")
  self.profileDropdown = ZO_ComboBox_ObjectFromContainer(profileController)
  self.profileDropdown:ClearItems()
  self.profileDropdown:SetSortsItems(false)

  -- Loop through profiles
  for name, _ in pairs(profiles) do
    local entry = ZO_ComboBox:CreateItemEntry(name, function(...) OnProfileSelected(name) end)
    self.profileDropdown:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
  end

  self.profileDropdown:SelectFirstItem(false)
end

function CCUIManager:NewProfile()
  self:SetCollectibleData(nil)
  self:SetQuickslotData(nil)
  self:SetTitleData(nil)
  self:SetOutfitData(nil)

  ZO_CheckButton_SetUnchecked(self.globalControl)

  self.currentProfile = {}
end

function CCUIManager:LoadProfile(profileName)

  -- Get data
  local data = CC.data:GetProfile(profileName)

  -- Check for a blank profile
  if data == nil then
    return
  end

  self:NewProfile()

  self.currentProfileName = profileName
  self.currentProfile = data

  self:SetCollectibleData(data.collectibles)
  self:SetQuickslotData(data.quickSlots)
  self:SetTitleData(data.titleData)
  self:SetOutfitData(data.outfitIndex)
  self:SetOtherSettings({isGlobal = data.isGlobal })

  -- Importing a profile means there are no changes.
  CC_CALLBACK_MANAGER:FireCallbacks(CC_ON_CHANGES_SAVED)
end

function CCUIManager:ToggleGlobalChecked(control)
  -- Is a profile selected?
  if not self.currentProfileName or self.currentProfileName == '' then
    ZO_CheckButton_SetUnchecked(self.globalControl)
    return
  end

  -- Unsaved changes!
  CC_CALLBACK_MANAGER:FireCallbacks(CC_ON_CHANGES_MADE)
end

function CCUIManager:EquipProfile()

  if not self.currentProfileName or self.currentProfileName == '' then
    CC:SendToChat('No profile is selected.')
    return
  end

  if CC_EQUIP_MANAGER:IsEquiping() then
    CC:SendToChat('Please wait until the current equip is finished.')
    return
  end

  local collectibleData = self:GetCollectibleData()
  local quickslotData = self:GetQuickSlotData()
  local title     = self:GetTitleData()
  local outfit    = self:GetOutfitData()

  CC_PLAYER_MANAGER:NewEquipCollectibles(collectibleData)
  CC_PLAYER_MANAGER:NewEquipQuickSlots(quickslotData)

  CC_EQUIP_MANAGER:EquipTitle(title)
  CC_EQUIP_MANAGER:EquipOutfit(outfit)

  -- Start the equip event
  CC_EQUIP_MANAGER:Start()
end

function CCUIManager:OpenCollectionList(collectionType)
  self.collectionUI:OpenCollectionPanel(collectionType, true)
end

--[[
  Popups
]]--

function CCUIManager:InitNewProfileDialog()

  local function SetupProfile(control)
    local ctrlContent = GetControl(control, "Content")
    local editProfileName = GetControl(ctrlContent, "ProfileName")
    editProfileName:SetText('Enter name')
  end

  local function CommitNewProfile(control)
    local contentControl     = control:GetNamedChild("Content")
    local profileNameControl = contentControl:GetNamedChild("ProfileName")

    local newProfileName = profileNameControl:GetText()
    newProfileName = CC:Trim(newProfileName)

    if not newProfileName or newProfileName == '' then
      CC:SendToChat('Invalid name')
      return
    end

    -- Trim
    newProfileName = CC:Trim(newProfileName)

    if CC.data:DoesOutfitExist(newProfileName) then
      CC:SendToChat('Outfit already exists.  Use another name.')
      return
    end

    -- Create an empty save file
    CC.data:SaveProfile(newProfileName, nil, nil, nil, nil, false)

    -- Update the
    self:SetupProfileCombo()
    self.profileDropdown:SetSelectedItemText(newProfileName, false)

    -- Display the profile
    self:LoadProfile(newProfileName)
  end

  local control = WINDOW_MANAGER:GetControlByName("CCNewProfileDialog")

  ZO_Dialogs_RegisterCustomDialog("CC_NEW_PROFILE_DIALOG",
  {
    customControl = control,
    title = { text = "New Profile" },
    setup = function() SetupProfile(control) end,
    buttons =
    {
        {
            control =   GetControl(control, "Accept"),
            text =      SI_DIALOG_ACCEPT,
            keybind =   "DIALOG_PRIMARY",
            callback =  function() CommitNewProfile(control) end,
        },
        {
            control =   GetControl(control, "Cancel"),
            text =      SI_DIALOG_CANCEL,
            keybind =   "DIALOG_NEGATIVE",
            callback =  function() end,
        },
      },
  })
end

function CCUIManager:ShowNewProfileDialog()
  ZO_Dialogs_ShowDialog("CC_NEW_PROFILE_DIALOG", {})
end

function CCUIManager:InitImportProfileDialog()

  local function CommitImport()

    if not self.currentProfileName or self.currentProfileName == '' then
      CC:SendToChat('No profile is selected.')
      return
    end

    CC.LoadProfileData()
    CC_CALLBACK_MANAGER:FireCallbacks(CC_ON_CHANGES_MADE)
  end

  local control = WINDOW_MANAGER:GetControlByName("CCImportProfileDialog")
  ZO_Dialogs_RegisterCustomDialog("CC_IMPORT_PROFILE_DIALOG",
  {
    customControl = control,
    title = { text = "Import Profile" },
    buttons =
    {
        {
            control =   GetControl(control, "Accept"),
            text =      SI_DIALOG_ACCEPT,
            keybind =   "DIALOG_PRIMARY",
            callback =  function() CommitImport() end,
        },
        {
            control =   GetControl(control, "Cancel"),
            text =      SI_DIALOG_CANCEL,
            keybind =   "DIALOG_NEGATIVE",
            callback =  function() end,
        },
      },
  })
end

function CCUIManager:ShowImportProfileDialog()

  if not self.currentProfileName or self.currentProfileName == '' then
    return
  end

  ZO_Dialogs_ShowDialog("CC_IMPORT_PROFILE_DIALOG", {})
end

function CCUIManager:InitSaveProfileDialog()

  local function SetUpSaveDialog(control)
    local ctrlContent = GetControl(control, "Content")
    local nameLabel = GetControl(ctrlContent, "NameLabel")
    nameLabel:SetText(string.format('Save profile "%s"?', self.currentProfileName))
  end

  local function CommitSave()

    local collData  = self:GetCollectibleData()
    local quickData = self:GetQuickSlotData()
    local title     = self:GetTitleData()
    local outfit    = self:GetOutfitData()

    if not self.currentProfileName or self.currentProfileName == '' then
      CC:SendToChat('No profile is selected.')
      return
    end

    -- Check if it's global
    local globalStatus = ZO_CheckButton_IsChecked(self.globalControl)

    -- Save profile
    CC.data:SaveProfile(self.currentProfileName , collData, quickData, title, outfit, globalStatus)

    -- Call the save event
    CC_CALLBACK_MANAGER:FireCallbacks(CC_ON_CHANGES_SAVED)
  end

  local control = WINDOW_MANAGER:GetControlByName("CCSaveProfileDialog")

  ZO_Dialogs_RegisterCustomDialog("CC_SAVE_PROFILE_DIALOG",
  {
    customControl = control,
    title = { text = "Save Profile" },
    setup = function() SetUpSaveDialog(control) end,
    buttons =
    {
        {
            control =   GetControl(control, "Accept"),
            text =      SI_DIALOG_ACCEPT,
            keybind =   "DIALOG_PRIMARY",
            callback =  function() CommitSave() end,
        },
        {
            control =   GetControl(control, "Cancel"),
            text =      SI_DIALOG_CANCEL,
            keybind =   "DIALOG_NEGATIVE",
            callback =  function() end,
        },
      },
  })
end

function CCUIManager:ShowSaveProfileDialog()

  if not self.currentProfileName or self.currentProfileName == '' then
    return
  end

  ZO_Dialogs_ShowDialog("CC_SAVE_PROFILE_DIALOG", {})
end

function CCUIManager:InitDeleteProfileDialog()

  local function CommitDelete()

    if not self.currentProfileName or self.currentProfileName == '' then
      CC:SendToChat('No profile is selected.')
      return
    end

    CC.data:DeleteProfile(self.currentProfileName)

    self.currentProfileName = ""

    -- Reset profile
    self:NewProfile()

    -- Update the
    self:SetupProfileCombo()
  end

  local control = WINDOW_MANAGER:GetControlByName("CCDeleteProfileDialog")

  ZO_Dialogs_RegisterCustomDialog("CC_DELETE_PROFILE_DIALOG",
  {
    customControl = control,
    title = { text = "Delete Profile" },
    buttons =
    {
        {
            control =   GetControl(control, "Accept"),
            text =      SI_DIALOG_ACCEPT,
            keybind =   "DIALOG_PRIMARY",
            callback =  function() CommitDelete() end,
        },
        {
            control =   GetControl(control, "Cancel"),
            text =      SI_DIALOG_CANCEL,
            keybind =   "DIALOG_NEGATIVE",
            callback =  function() end,
        },
      },
  })
end

function CCUIManager:ShowDeleteProfileDialog()
  ZO_Dialogs_ShowDialog("CC_DELETE_PROFILE_DIALOG", {})
end

function CCUIManager:InitEditProfileDialog()

  local function SetUpEditNameDialog(control)
    local ctrlContent = GetControl(control, "Content")
    local editProfileName = GetControl(ctrlContent, "ProfileName")
    local name = self.currentProfileName

    if name then editProfileName:SetText(name) end
  end

  local function CommitEditName(control)

    if not self.currentProfileName or self.currentProfileName == '' then
      CC:SendToChat('No profile is selected.')
      return
    end

    local ctrlContent = GetControl(control, "Content")
    local editProfileName = GetControl(ctrlContent, "ProfileName")

    local newName = editProfileName:GetText()
    local oldName = self.currentProfileName

    -- Trim
    newName = CC:Trim(newName)

    -- Make sure name is valid
    if not newName or newName == '' or newName == oldName then
      CC:SendToChat('Invalid name.  Please make sure the new name is different.')
      return
    end

    -- Make sure outfit does not exist
    if CC.data:DoesOutfitExist(newName) then
      CC:SendToChat('Outfit already exists.  Use another name.')
      return
    end

    CC.data:RenameOutfit(oldName, newName)
    self.currentProfileName = newName

    -- Create the outfit dropdown
    self:SetupProfileCombo()
    self.profileDropdown:SetSelectedItemText(newName, false)

    -- Load the profile again
    self:LoadProfile(newName)
  end

  local control = WINDOW_MANAGER:GetControlByName("CCEditProfileDialog")

  ZO_Dialogs_RegisterCustomDialog("CC_EDIT_PROFILE_DIALOG",
  {
    customControl = control,
    title = { text = "Profile Properties" },
    setup = function() SetUpEditNameDialog(control) end,
    buttons =
    {
        {
            control =   GetControl(control, "Accept"),
            text =      SI_DIALOG_ACCEPT,
            keybind =   "DIALOG_PRIMARY",
            callback =  function(dialog) CommitEditName(dialog) end,
        },
        {
            control =   GetControl(control, "Cancel"),
            text =      SI_DIALOG_CANCEL,
            keybind =   "DIALOG_NEGATIVE",
            callback =  function() end,
        },
      },
  })
end

function CCUIManager:ShowEditProfileDialog()

  if not self.currentProfileName or self.currentProfileName == '' then
    return
  end

  ZO_Dialogs_ShowDialog("CC_EDIT_PROFILE_DIALOG", {})
end


--[[
  Getter / Setters
]]
do

  function CCUIManager:IsProfileSelected()
    return not (not self.currentProfileName or self.currentProfileName == '')
  end

  function CCUIManager:SetCollectibleData(collectibleData)
    self.characterUI:SetCollectibleData(collectibleData)
  end

  function CCUIManager:SetQuickslotData(quickslotData)
    self.characterUI:SetQuickSlotData(quickslotData)
  end

  function CCUIManager:SetTitleData(titleIndex)
    self.characterUI:SetTitle(titleIndex)
  end

  function CCUIManager:SetOutfitData(outfitIndex)
    self.characterUI:SetOutfit(outfitIndex)
  end

  function CCUIManager:SetOtherSettings(settings)
    if settings.isGlobal == true then
      ZO_CheckButton_SetChecked(self.globalControl)

    else
      ZO_CheckButton_SetUnchecked(self.globalControl)
    end
  end

  function CCUIManager:GetCollectibleData()
    return self.characterUI:GetCollectibleData()
  end

  function CCUIManager:GetQuickSlotData()
    return self.characterUI:GetQuickSlotData()
  end

  function CCUIManager:GetTitleData()
    return self.characterUI:GetTitle()
  end

  function CCUIManager:GetOutfitData()
    return self.characterUI:GetOutfit()
  end
end

--[ CONTROLS ] --

function CCUIManager:IsVisable()
  return self.isVisable
end

function CCUIManager:Show()
  if not self.scene then return end
  SCENE_MANAGER:Show(self.sceneName)
  self.isVisable = true
end

function CCUIManager:Hide()
  if not self.scene then return end
  SCENE_MANAGER:Hide(self.sceneName)
  self.isVisable = false
end

function CCUIManager.ShowCCAction()
  CC_UI_MANAGER:Show()
end

CC_UI_MANAGER = CCUIManager:New(CC.name, WINDOW_MANAGER:GetControlByName("CC_Panel"))
