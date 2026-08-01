local QF = _G["QF"]

local WM = WINDOW_MANAGER

local function InitArmoryProfileLabel(control)
  local curseOutfitRow = control:GetNamedChild("ContainerCurseOutfitRow")

  -- We're hijacking the default outfit label to show the QF profile instead
  QF.Armory.outfitControl = curseOutfitRow:GetNamedChild("Outfit")
  QF.SetToolTip(QF.Armory.outfitControl, LEFT, "Profiles by |c7B68EEQuick|r |c9F00FFFashion|r")
  return false
end

function QF.UpdateArmoryProfileLabel()
  local control = QF.Armory.outfitControl:GetParent():GetParent():GetParent()
  if control.dataEntry == nil then
    return
  end
  local buildIndex = control.dataEntry.data:GetBuildIndex()
  local profileName = QF.SavedVars.Armory.Profiles[buildIndex]
  if profileName == nil or profileName == "" or profileName == "|c989898No profile|r" then
    QF.Armory.outfitControl:SetText("Profile: |c989898No profile|r")
  else
    QF.Armory.outfitControl:SetText(string.format("Profile: |cFFFFFF%s|r", profileName))
  end
end

function QF.ArmoryBuildUpdated(event, buildIndex)
  local profileName = QF.CharacterProfilesDropdown:GetSelectedItem()
  QF.SavedVars.Armory.Profiles[buildIndex] = profileName
end

function QF.InitArmory()
  ZO_PreHook("ZO_Armory_ExpandedEntry_OnInitialized", InitArmoryProfileLabel)
  -- ZO_PostHook("ZO_Armory_Keyboard_CollapsedEntry_OnMouseUp", function() d("?") end)
  ZO_PostHook(ARMORY_KEYBOARD, "RefreshBuilds", QF.UpdateArmoryProfileLabel)
end
