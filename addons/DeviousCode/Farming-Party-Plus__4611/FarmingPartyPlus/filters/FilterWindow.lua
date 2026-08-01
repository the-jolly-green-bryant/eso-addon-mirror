local listContainer
local Settings
local CATEGORY_ORDER = { 'ore', 'wood', 'cloth', 'jewelry', 'alchemy', 'enchanting', 'provisioning', 'recipes', 'fishing', 'furnishing' }
local RECIPE_VALUE_MIN = 100
local RECIPE_VALUE_MAX = 50000
local RECIPE_BAR_WIDTH = 300
local LOAD_PROFILE_DIALOG_NAME = 'FarmingPartyPlusLoadWhitelistProfileDialog'
local Addon = FarmingPartyPlus

local function GetRecipeValueThumbOffset(value)
  local normalized = (zo_clamp(tonumber(value) or RECIPE_VALUE_MIN, RECIPE_VALUE_MIN, RECIPE_VALUE_MAX) - RECIPE_VALUE_MIN) / (RECIPE_VALUE_MAX - RECIPE_VALUE_MIN)
  return zo_floor(normalized * RECIPE_BAR_WIDTH)
end

local function GetRecipeValueFromBarOffset(offset)
  local normalized = zo_clamp((tonumber(offset) or 0) / RECIPE_BAR_WIDTH, 0, 1)
  local rawValue = RECIPE_VALUE_MIN + ((RECIPE_VALUE_MAX - RECIPE_VALUE_MIN) * normalized)
  local roundedValue = zo_clamp(zo_roundToNearest(rawValue, 100), RECIPE_VALUE_MIN, RECIPE_VALUE_MAX)
  if normalized <= 0.01 then
    return RECIPE_VALUE_MIN
  end
  if normalized >= 0.99 then
    return RECIPE_VALUE_MAX
  end
  return roundedValue
end

local function TrimText(text)
  return zo_strgsub(zo_strgsub(text or '', '^%s+', ''), '%s+$', '')
end

local function SanitizeProfileName(text)
  return zo_strgsub(text or '', '[^%a]', '')
end

local FilterWindow = ZO_Object:Subclass()
Addon.Classes.FilterWindow = FilterWindow

local function UpdateItemButton(button, itemData)
  local isEnabled = Settings:IsWhitelistedItem(itemData.key)
  button.itemData = itemData
  button:SetHidden(false)
  button:SetText((isEnabled and '[ON] ' or '[OFF] ') .. itemData.name)
  if isEnabled then
    button:SetNormalFontColor(0.20, 0.90, 0.45, 1)
    button:SetMouseOverFontColor(0.45, 1.00, 0.65, 1)
    button:SetPressedFontColor(0.16, 0.75, 0.38, 1)
  else
    button:SetNormalFontColor(1.00, 0.62, 0.62, 1)
    button:SetMouseOverFontColor(1.00, 0.74, 0.74, 1)
    button:SetPressedFontColor(0.88, 0.50, 0.50, 1)
  end
end

function FilterWindow:New()
  local obj = ZO_Object.New(self)
  obj:Initialize()
  return obj
end

function FilterWindow:Initialize()
  Settings = FarmingPartyPlus.Settings
  listContainer = FarmingPartyPlusItemFilterWindow:GetNamedChild('List')
  self.selectedProfileName = nil

  FarmingPartyPlusItemFilterWindow:ClearAnchors()
  FarmingPartyPlusItemFilterWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, Settings:FilterWindow().positionLeft, Settings:FilterWindow().positionTop)
  FarmingPartyPlusItemFilterWindow:SetDimensions(Settings:FilterWindow().width, Settings:FilterWindow().height)
  FarmingPartyPlusItemFilterWindow:SetHandler('OnMoveStop', function()
    self:SavePosition()
  end)
  FarmingPartyPlusItemFilterWindow:SetHandler('OnResizeStop', function(...)
    self:WindowResizeHandler(...)
  end)

  self:RegisterDialogs()
  self:SetupScrollList()
  self:RefreshModeLabel()
  self:RefreshProfileControls()
  self:UpdateScrollList()
end

function FilterWindow:Finalize()
  self:SavePosition()
end

function FilterWindow:SavePosition()
  Settings:FilterWindow().positionLeft = FarmingPartyPlusItemFilterWindow:GetLeft()
  Settings:FilterWindow().positionTop = FarmingPartyPlusItemFilterWindow:GetTop()
  Settings:FilterWindow().width = FarmingPartyPlusItemFilterWindow:GetWidth()
  Settings:FilterWindow().height = FarmingPartyPlusItemFilterWindow:GetHeight()
end

function FilterWindow:WindowResizeHandler(control)
  self:SavePosition()
  ZO_ScrollList_Commit(listContainer)
end

function FilterWindow:RefreshModeLabel()
  local modeLabel = FarmingPartyPlusItemFilterWindow:GetNamedChild('ModeValue')
  modeLabel:SetText(Settings:UseWhitelistMode() and 'Whitelist On' or 'Whitelist Off')
end

function FilterWindow:RegisterDialogs()
  if self.dialogsRegistered then
    return
  end

  ZO_Dialogs_RegisterCustomDialog(LOAD_PROFILE_DIALOG_NAME, {
    title = {
      text = 'Load Whitelist Profile'
    },
    mainText = {
      text = function(dialog)
        return string.format('Load whitelist profile "%s"? This will reload the UI.', dialog.data.profileName or '')
      end
    },
    buttons = {
      {
        text = SI_DIALOG_ACCEPT,
        callback = function(dialog)
          if Settings:LoadWhitelistProfile(dialog.data.profileName) then
            ReloadUI()
          end
        end
      },
      {
        text = SI_DIALOG_CANCEL
      }
    }
  })

  self.dialogsRegistered = true
end

function FilterWindow:GetProfileNameInput()
  return FarmingPartyPlusItemFilterWindow:GetNamedChild('ProfileNameBox'):GetNamedChild('Input')
end

function FilterWindow:ValidateProfileNameInput(editBox)
  if editBox == nil then
    return
  end

  local sanitized = SanitizeProfileName(editBox:GetText())
  if sanitized ~= editBox:GetText() then
    editBox:SetText(sanitized)
  end
end

function FilterWindow:RefreshProfileControls()
  local selectButton = FarmingPartyPlusItemFilterWindow:GetNamedChild('ProfileSelectButton')
  local deleteButton = FarmingPartyPlusItemFilterWindow:GetNamedChild('ProfileDeleteButton')
  selectButton:SetText(self.selectedProfileName or 'Select Saved Profile')
  deleteButton:SetEnabled(self.selectedProfileName ~= nil)
end

function FilterWindow:SaveCurrentProfile()
  local profileName = SanitizeProfileName(TrimText(self:GetProfileNameInput():GetText()))
  self:GetProfileNameInput():SetText(profileName)
  if profileName == '' then
    d('[Farming Party Plus]: Enter a profile name using letters only.')
    return
  end

  if Settings:SaveWhitelistProfile(profileName) then
    self.selectedProfileName = profileName
    self:GetProfileNameInput():SetText('')
    self:RefreshProfileControls()
    d(string.format('[Farming Party Plus]: Saved whitelist profile "%s".', profileName))
  end
end

function FilterWindow:ShowProfileMenu(control)
  ClearMenu()

  local profileNames = Settings:GetWhitelistProfileNames()
  if #profileNames == 0 then
    AddCustomMenuItem('No saved profiles', function()
    end, MENU_ADD_OPTION_LABEL)
  else
    for _, profileName in ipairs(profileNames) do
      AddCustomMenuItem(profileName, function()
        self:SelectProfile(profileName)
      end, MENU_ADD_OPTION_LABEL)
    end
  end

  ShowMenu(control)
end

function FilterWindow:SelectProfile(profileName)
  self.selectedProfileName = profileName
  self:RefreshProfileControls()
  ZO_Dialogs_ShowDialog(LOAD_PROFILE_DIALOG_NAME, {
    profileName = profileName
  })
end

function FilterWindow:DeleteSelectedProfile()
  if self.selectedProfileName == nil then
    return
  end

  local deletedProfileName = self.selectedProfileName
  if Settings:DeleteWhitelistProfile(deletedProfileName) then
    self.selectedProfileName = nil
    self:RefreshProfileControls()
    d(string.format('[Farming Party Plus]: Deleted whitelist profile "%s".', deletedProfileName))
  end
end

function FilterWindow:ToggleWhitelistMode()
  Settings:SetWhitelistMode(not Settings:UseWhitelistMode())
  self:RefreshModeLabel()
end

function FilterWindow:ToggleWindow()
  FarmingPartyPlusItemFilterWindow:SetHidden(not FarmingPartyPlusItemFilterWindow:IsHidden())
end

function FilterWindow:OpenWindow()
  FarmingPartyPlusItemFilterWindow:SetHidden(false)
end

function FilterWindow:ToggleItem(itemKey)
  Settings:SetWhitelistedItem(itemKey, not Settings:IsWhitelistedItem(itemKey))
  self:UpdateScrollList()
end

function FilterWindow:SetAll(value)
  Settings:ToggleAllWhitelistItems(value)
  self:UpdateScrollList()
end

function FilterWindow:SetCategory(categoryKey, value)
  Settings:ToggleWhitelistCategory(categoryKey, value)
  self:UpdateScrollList()
end

function FilterWindow:SetupScrollList()
  ZO_ScrollList_AddResizeOnScreenResize(listContainer)
  ZO_ScrollList_AddDataType(listContainer, FarmingPartyPlus.DataTypes.FILTER_HEADER, 'FarmingPartyPlusFilterHeaderRow', 28, function(control, data)
    self:SetupHeaderRow(control, data)
  end)
  ZO_ScrollList_AddDataType(listContainer, FarmingPartyPlus.DataTypes.FILTER_RECIPE_VALUE, 'FarmingPartyPlusFilterRecipeValueRow', 64, function(control, data)
    self:SetupRecipeValueRow(control, data)
  end)
  ZO_ScrollList_AddDataType(listContainer, FarmingPartyPlus.DataTypes.FILTER_ROW, 'FarmingPartyPlusFilterItemRow', 30, function(control, data)
    self:SetupItemRow(control, data)
  end)
end

function FilterWindow:UpdateScrollList()
  local scrollData = ZO_ScrollList_GetDataList(listContainer)
  ZO_ScrollList_Clear(listContainer)

  local grouped = FarmingPartyPlus.ItemCatalog:GetGroupedItems()
  for _, categoryKey in ipairs(CATEGORY_ORDER) do
    scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(FarmingPartyPlus.DataTypes.FILTER_HEADER, {
        title = FarmingPartyPlus.ItemCatalog.categories[categoryKey],
      categoryKey = categoryKey
    })

    if categoryKey == 'recipes' then
      scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(FarmingPartyPlus.DataTypes.FILTER_RECIPE_VALUE, {
        categoryKey = categoryKey
      })
    end

    local items = grouped[categoryKey]
    for index = 1, #items, 3 do
      local rowItems = {}
      rowItems[#rowItems + 1] = items[index]
      rowItems[#rowItems + 1] = items[index + 1]
      rowItems[#rowItems + 1] = items[index + 2]
      scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(FarmingPartyPlus.DataTypes.FILTER_ROW, { items = rowItems })
    end
  end

  self:RefreshModeLabel()
  self:RefreshProfileControls()
  ZO_ScrollList_Commit(listContainer)
end

function FilterWindow:SetupHeaderRow(control, data)
  control:GetNamedChild('Title'):SetText(data.title)
  control:GetNamedChild('Enable'):SetHandler('OnClicked', function()
    self:SetCategory(data.categoryKey, true)
  end)
  control:GetNamedChild('Disable'):SetHandler('OnClicked', function()
    self:SetCategory(data.categoryKey, false)
  end)
end

function FilterWindow:SetupRecipeValueRow(control)
  local valueLabel = control:GetNamedChild('Value')
  local currentValue = Settings:MinimumRecipeValue()
  valueLabel:SetText(string.format('Track recipes worth %sg or more', ZO_CommaDelimitNumber(currentValue)))
  local barArea = control:GetNamedChild('BarArea')
  local fill = barArea:GetNamedChild('Fill')
  local thumb = barArea:GetNamedChild('Thumb')
  local thumbOffset = GetRecipeValueThumbOffset(currentValue)
  fill:SetWidth(zo_max(thumbOffset + 5, 0))
  thumb:ClearAnchors()
  thumb:SetAnchor(TOPLEFT, barArea, TOPLEFT, thumbOffset - 5, 3)
end

function FilterWindow:SetMinimumRecipeValue(value)
  Settings:SetMinimumRecipeValue(value)
  self:UpdateScrollList()
end

function FilterWindow:RecipeBarClicked(control, upInside)
  if not upInside then
    return
  end

  local x = GetUIMousePosition()
  local left = control:GetLeft()
  local width = control:GetWidth()
  if x == nil or left == nil then
    return
  end

  local offset = zo_clamp(x - left, 0, width or RECIPE_BAR_WIDTH)
  self:SetMinimumRecipeValue(GetRecipeValueFromBarOffset(offset))
end

function FilterWindow:SetupItemRow(control, data)
  for i = 1, 3 do
    local button = control:GetNamedChild('Item' .. i)
    local itemData = data.items[i]
    if itemData == nil then
      button:SetHidden(true)
    else
      UpdateItemButton(button, itemData)
      button:SetHandler('OnClicked', function()
        self:ToggleItem(itemData.key)
      end)
    end
  end
end
