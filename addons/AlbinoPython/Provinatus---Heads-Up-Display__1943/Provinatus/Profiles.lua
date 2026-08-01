ProvinatusProfiles = ZO_Object:Subclass()

function ProvinatusProfiles:New(...)
  return ZO_Object.New(self)
end

function ProvinatusProfiles:GetMenu()
  local function getProfileDropdown()
    local Profiles = {}
    for ProfileName, Settings in pairs(Provinatus.Profile.Profiles) do
      if Settings then
        table.insert(Profiles, ProfileName)
      end
    end

    return {
      type = "dropdown",
      name = PROVINATUS_SELECT_PROFILE,
      choices = Profiles,
      getFunc = function()
      end,
      setFunc = function(var)
      end,
      sort = "name-up",
      width = "full",
      scrollable = true,
      reference = "ProvProfileDropdown",
      default = ""
    }
  end

  local Menu = {
    type = "submenu",
    name = PROVINATUS_PROFILES,
    tooltip = PROVINATUS_PROFILES_TT,
    icon = "/esoui/art/menubar/gamepad/gp_playermenu_icon_character.dds",
    controls = {
      {
        type = "checkbox",
        name = PROVINATUS_ACCOUNT_WIDE,
        tooltip = PROVINATUS_ACCOUNT_WIDE_TT,
        getFunc = function()
          return Provinatus.SavedVarsAccount.AccountWideVars
        end,
        setFunc = function(value)
          Provinatus.SavedVarsAccount.AccountWideVars = value
        end,
        width = "full",
        default = ProvinatusConfig.AccountWideVars,
        requiresReload = true
      },
      {
        type = "editbox",
        name = PROVINATUS_PROFILE_NAME,
        tooltip = PROVINATUS_PROFILE_NAME_TT,
        getFunc = function()
        end,
        setFunc = function(text)
        end,
        textType = TEXT_TYPE_ALL,
        width = "half",
        reference = "ProvProfileEditBox"
      },
      {
        type = "button",
        name = PROVINATUS_SAVE_PROFILE,
        func = function()
          Provinatus.Profile.Profiles[ProvProfileEditBox.editbox:GetText()] =
            ZO_DeepTableCopy(getmetatable(Provinatus.SavedVars).__index)
          local Items = {}
          for _, Item in pairs(ProvProfileDropdown.dropdown:GetItems()) do
            table.insert(Items, Item.name)
          end
          if not Items[ProvProfileEditBox.editbox:GetText()] then
            local entry = ProvProfileDropdown.dropdown:CreateItemEntry(ProvProfileEditBox.editbox:GetText())
            entry.control = ProvProfileDropdown
            ProvProfileDropdown.dropdown:AddItem(entry)
          end
        end,
        tooltip = PROVINATUS_SAVE_PROFILE_TT,
        disabled = function()
          return ProvProfileEditBox.editbox:GetText() == ""
        end,
        width = "half",
        reference = "ProvAddProfileButton"
      },
      getProfileDropdown(),
      {
        type = "button",
        name = PROVINATUS_LOAD_PROFILE,
        func = function()
          if Provinatus.Profile.Profiles[ProvProfileDropdown.dropdown:GetSelectedItem()] then
            ZO_DeepTableCopy(
              Provinatus.Profile.Profiles[ProvProfileDropdown.dropdown:GetSelectedItem()],
              getmetatable(Provinatus.SavedVars).__index
            )

            -- TODO update other submenus so they can update their icons and whatnot.
          end
        end,
        tooltip = PROVINATUS_LOAD_PROFILE_TT,
        width = "half"
      },
      {
        type = "button",
        name = PROVINATUS_DELETE_PROFILE,
        func = function()
          Provinatus.Profile.Profiles[ProvProfileDropdown.dropdown:GetSelectedItem()] = nil
          ProvProfileDropdown.dropdown:ClearItems()
          for ProfileName, ProfileSettings in pairs(Provinatus.Profile.Profiles) do
            if ProfileSettings then
              local entry =
                ProvProfileDropdown.dropdown:CreateItemEntry(
                ProfileName,
                function(control, choiceText, choice)
                  choice.control:UpdateValue(false, choice.value or choiceText)
                end
              )
              entry.control = ProvProfileDropdown
              ProvProfileDropdown.dropdown:AddItem(entry)
            end
          end
        end,
        tooltip = PROVINATUS_DELETE_PROFILE_TT,
        width = "half"
      }
    }
  }

  return Menu
end

function ProvinatusProfiles:MenuCreated()
  local function CheckText()
    local EditBoxText = ProvProfileEditBox.editbox:GetText()
    local TooltipText = GetString(PROVINATUS_SAVE_PROFILE)
    if Provinatus.Profile.Profiles and Provinatus.Profile.Profiles[EditBoxText] then
      TooltipText = PROVINATUS_PROFILE_WARNING
    end

    ProvAddProfileButton.button.data.tooltipText = TooltipText
    ProvAddProfileButton.button:SetEnabled(EditBoxText ~= "")
  end
  ProvProfileEditBox.editbox:SetHandler("OnTextChanged", CheckText)
end
