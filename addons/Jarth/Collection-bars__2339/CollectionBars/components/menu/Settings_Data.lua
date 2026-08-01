--[[
Author: Jarth
Filename: Settings_Data.lua
]] --
-------------------------------------------------------------------------------------------------
-- VARIABLES --
-------------------------------------------------------------------------------------------------
local base = CollectionBars
local texts = base.Texts

-------------------------------------------------------------------------------------------------
-- FUNCTIONS --
-------------------------------------------------------------------------------------------------

ESO_Dialogs["CB_CONFIRM_DIALOG"] = {
	mustChoose = true,
	title = {text = "Confirm <<1>>"},
	mainText = {text = "<<1>>"},
	buttons = {
		[1] = {
			text = SI_OPTIONS_RESET,
			callback = function(dialog)
				local callback = dialog and dialog.data and dialog.data.callback
				if callback ~= nil then
					callback()
				end
			end
		},
		[2] = {text = SI_DIALOG_CANCEL}
	}
}

function base.AppendMasterListTypeGeneral(self, listType)
	base:Debug("AppendMasterListTypeGeneral", self, listType)
	self:AppendRow_Checkbox(listType, {
		name = "Use account settings",
		tooltip = "When ON the account settings will be used. When OFF character settings will be used",
		funcGet = function()
			return base.Saved.UseAccountSettings
		end,
		funcSet = function(_, newValue)
			base:UpdateUseAccountSettings(newValue)
			base:SetLogsEnabled()
			base:InitializeWithSavedData()
			base:RestoreFrames()
			base:RestoreCombineLabels()
			base.Global.Settings.List:RefreshData()
		end
	})
	self:AppendRow_Button(listType, {
		name = "Remove all character settings",
		buttonName = "Remove",
		disabledFunc = base.GetCharacterSettingsDisabledState,
		confirmation = true,
		message = "ARE YOU SURE!?",
		funcSet = function()
			ZO_Dialogs_ShowDialog("CB_CONFIRM_DIALOG", {
				callback = function()
					base:RemoveCharacterSettings()
					base.Global.Settings.List:RefreshData()
				end
			}, {titleParams = {"remove all character settings"}, mainTextParams = {"It will remove all character settings, only relying on account settings."}})
		end
	})
	self:AppendRow_Button(listType, {
		name = "Reset settings",
		buttonName = "Reset",
		confirmation = true,
		message = "ARE YOU SURE!?",
		funcSet = function()
			ZO_Dialogs_ShowDialog("CB_CONFIRM_DIALOG", {
				callback = function()
					base:ResetSavedSettings()
					base:SetLogsEnabled()
					base:InitializeWithSavedData()
					base:RestoreFrames()
					base:RestoreCombineLabels()
					base.Global.Settings.List:RefreshData()
				end
			}, {titleParams = {"reset settings"}, mainTextParams = {"It will reset settings back to default."}})
		end
	})
	self:AppendRow_Title(listType, {name = "Keybindings"})
	self:AppendRow_Divider(listType, {})
	self:AppendRow_Dropdown(listType, {
		name = "Change number of keybindings",
		tooltipText = "It will change the number of keybindings in the \"Controls\" page",
		funcGet = function()
			return base.Saved.Bindings.Number
		end,
		choices = base.Global.ChoiceNumberOfBindings,
		funcSet = function(_, newValue)
			if base.Saved.Bindings.Number ~= newValue then
				ZO_Dialogs_ShowDialog("CB_CONFIRM_DIALOG", {
					callback = function()
						base.Saved.Bindings.Number = newValue
						ReloadUI("ingame")
					end
				}, {
					titleParams = {"change number of keybindings"},
					mainTextParams = {
						"Be aware when limiting the number of hotkeys, that:\n- To unbind a hotkey it is not enough to limit the number of hotkeys, you need to unbound it under \"ESO: CONTROLS > Keybindings\".\n- The addon no longer monitors hotkeys outside the desired range.\n- Bound hotkeys can be used no matter the range"
					}
				})
			end
		end
	})
	self:AppendRow_Title(listType, {name = "Position and size"})
	self:AppendRow_Divider(listType, {})
	self:AppendRow_Checkbox(listType, {
		name = "Unlock movement of bar",
		tooltipText = "When ON the bar will show the X,Y position of the top left corner, and is draggable",
		funcGet = function()
			return base.Global.IsMoveEnabled
		end,
		funcSet = function(_, newValue)
			base.Global.IsMoveEnabled = newValue
			base:RestoreFrames()
		end
	})
	self:AppendRow_Slider(listType, {
		name = "Choose snap size when moving",
		tooltipText = "Choose snap size when moving",
		funcGet = function()
			return base.Saved.Bar.SnapSize
		end,
		funcSet = function(sliderControl, newValue)
			local valueLabel = GetControl(sliderControl:GetParent(), "ValueLabel")
			if valueLabel then
				valueLabel:SetText(newValue)
			end
			base.Saved.Bar.SnapSize = newValue
			base:RestoreFrames()
		end,
		minValue = 1,
		maxValue = 10,
		valueStep = 1,
		default = base.Default.Bar.SnapSize,
		valueFormat = texts.Format.Number,
		showValue = true
	})
	self:AppendRow_Slider(listType, {
		name = "Choose max bar depth",
		tooltipText = "Choose max bar depth\n(number of inverse rows/columns)",
		funcGet = function()
			return base.Saved.Bar.Depth
		end,
		funcSet = function(sliderControl, newValue)
			local valueLabel = GetControl(sliderControl:GetParent(), "ValueLabel")

			if valueLabel then
				valueLabel:SetText(newValue)
			end

			base.Saved.Bar.Depth = newValue
			base:RestoreFrames()
		end,
		minValue = 0,
		maxValue = base.Global.HighestUnlocked,
		valueStep = 1,
		default = base.Default.Bar.Depth,
		valueFormat = texts.Format.Number,
		showValue = true
	})
	self:AppendRow_Slider(listType, {
		name = "Choose max bar height",
		tooltipText = "Choose max bar height\n(number of inverse rows/columns)",
		funcGet = function()
			return base.Saved.Bar.Width
		end,
		funcSet = function(sliderControl, newValue)
			local valueLabel = GetControl(sliderControl:GetParent(), "ValueLabel")

			if valueLabel then
				valueLabel:SetText(newValue)
			end

			base.Saved.Bar.Width = newValue
			base:RestoreFrames()
		end,
		minValue = 0,
		maxValue = base.Global.HighestUnlocked,
		valueStep = 1,
		default = base.Default.Bar.Width,
		valueFormat = texts.Format.Number,
		showValue = true
	})
	self:AppendRow_Checkbox(listType, {
		name = "Show binding's on bar",
		tooltipText = "When ON the binding's will be shown on the bar",
		funcGet = function()
			return base.Saved.Bindings.Show
		end,
		funcSet = function(_, newValue)
			base.Saved.Bindings.Show = newValue
			base:RestoreFrames()
		end
	})
	self:AppendRow_Slider(listType, {
		name = "Choose button size",
		tooltipText = "Choose button size",
		funcGet = function()
			return base.Saved.Button.Size
		end,
		funcSet = function(sliderControl, newValue)
			local valueLabel = GetControl(sliderControl:GetParent(), "ValueLabel")

			if valueLabel then
				valueLabel:SetText(newValue)
			end

			base.Saved.Button.Size = newValue
			base:RestoreFrames()
		end,
		minValue = 1,
		maxValue = 100,
		valueStep = 1,
		default = ZO_GAMEPAD_ACTION_BUTTON_SIZE,
		valueFormat = texts.Format.Number,
		showValue = true
	})

	local showBars = "Show bars "
	local whenOnTheBar = "When ON the bars will shown "
	self:AppendRow_Title(listType, {name = "Visibility"})
	self:AppendRow_Divider(listType, {})

	for _, scene in ipairs(base.Global.Scenes) do
		self:AppendRow_Checkbox(listType, {
			name = string.format(scene.Description, showBars),
			tooltipText = string.format(scene.Description, whenOnTheBar),
			funcGet = function()
				return base.Saved.Scene[scene.Name]
			end,
			funcSet = function(_, newValue)
				base.Saved.Scene[scene.Name] = newValue
				base:UpdateFragments(scene.Name)
			end
		})
	end

	self:AppendRow_Title(listType, {name = "Active and activation"})
	self:AppendRow_Divider(listType, {})
	self:AppendRow_Checkbox(listType, {
		name = "Show active and activation",
		tooltipText = "When ON the active collectibles will be highlighted, and activation animation will display",
		funcGet = function()
			return base.Saved.Button.IsActiveActivationEnabled
		end,
		funcSet = function(_, newValue)
			base.Saved.Button.IsActiveActivationEnabled = newValue
			base:RestoreFrames()
		end
	})

	self:AppendRow_Title(listType, {name = "Audio"})
	self:AppendRow_Divider(listType, {})
	self:AppendRow_Checkbox(listType, {
		name = "Play hover audio",
		tooltipText = "When ON hover events on the bar, will play audio",
		funcGet = function()
			return base.Saved.Button.IsAudioEnabled
		end,
		funcSet = function(_, newValue)
			base.Saved.Button.IsAudioEnabled = newValue
			base:RestoreFrames()
		end
	})
	self:AppendRow_Title(listType, {name = "Logging"})
	self:AppendRow_Divider(listType, {})
	self:AppendRow_Checkbox(listType, {
		name = "Enable logging",
		tooltipText = "When ON the addon will do logging\nDependsOn: LibDebugLogger",
		disabledFunc = function()
			return base.Loggers.Logger == nil
		end,
		funcGet = function()
			return base.Saved.Logging.Info
		end,
		funcSet = function(_, newValue)
			base.Saved.Logging.Info = newValue

			if not newValue then
				base.Saved.Logging.Debug = newValue
				base.Saved.Logging.Verbose = newValue
			end

			base.Global.Settings.List:RefreshData()
			base:SetLogsEnabled()
		end
	})
	self:AppendRow_Checkbox(listType, {
		name = "Enable logging debug",
		tooltipText = "When ON the addon will do logging debug\nDependsOn: LibDebugLogger\n And Enable logging ON",
		disabledFunc = function()
			return base.Loggers.Debug == nil or not base.Saved.Logging.Info
		end,
		funcGet = function()
			return base.Saved.Logging.Debug
		end,
		funcSet = function(_, newValue)
			base.Saved.Logging.Debug = newValue
			base:LogSetEnabled(base.Loggers.Debug, newValue, "Logging debug")

			if not newValue then
				base:LogSetEnabled(base.Loggers.Verbose, newValue, "Logging verbose")
			end
		end
	})
	self:AppendRow_Checkbox(listType, {
		name = "Enable logging verbose",
		tooltipText = "When ON the addon will do logging debug\nDependsOn: LibDebugLogger\n And Enable logging ON\n\nRequired: add verbose logger to the StartupConfig.lua in LibDebugLogger\nas whitelist[\"CollectionBars/verbose\"] = true",
		disabledFunc = function()
			return base.Loggers.Verbose == nil or not base.Saved.Logging.Info
		end,
		funcGet = function()
			return base.Saved.Logging.Verbose
		end,
		funcSet = function(_, newValue)
			base.Saved.Logging.Verbose = newValue
			base:LogSetEnabled(base.Loggers.Verbose, newValue, "Logging verbose")
		end
	})
end

function base.AppendMasterListTypeCategories(self, listType)
	base:Debug("AppendMasterListTypeCategories", self, listType)
	self:AppendRow_Title(listType, {name = "Categories"})
	self:AppendRow_Divider(listType, {})

	for _, category in ipairs(base.CategoriesOrdered or {}) do
		local toolTipText = ""
		local icon

		if category.HasChildren then
			toolTipText = string.format("Click to toggle subcategories for\n%s", category.Name)
			icon = base.ToggleButtonIcon[base.Global.ShowChildren[category.Name] == base.ToggleButtonState.OPEN]
		else
			toolTipText = string.format("When ON the collection category:\n%s will enabled\n\nPress the 'cog' to display collectible in the tabs: 'Collectibles' and 'Category'\n and Right click wil also change the tab", category.Name)
			icon = category.Icon
		end

		local data = {
			cId = category.Id,
			icon = icon,
			name = string.format("Show %s", category.Name),
			hasChildren = category.HasChildren,
			parentKey = category.ParentKey,
			tooltipText = toolTipText,
			funcGet = function()
				return category.Saved.Enabled
			end,
			disabledFunc = function()
				return category.Disabled
			end,
			funcSet = function(_, newValue)
				category.Saved.Enabled = newValue

				if newValue then
					base:InitializeCategory(category)
				else
					base:RemoveLabel(category)
					base:RemoveFrame(category)
					if self.category == category then
						self.category = nil
						base:UpdateSettingsType(true, nil)
					end
				end

				if category.Saved.Bar.IsCombined then
					base:RestoreCombineLabels()
				end

				base.Global.Settings.List:RefreshData()
			end,
			funcCog = function(button)
				self.category = category
				base:UpdateSettingsType(true, category)
				base.Global.Settings.List:RefreshData()

				if button == MOUSE_BUTTON_INDEX_RIGHT then
					base.Global.Settings.List.masterListType = "Collectibles"
					base.Global.Settings.List:RefreshFilters()
				end
			end
		}

		if category.HasChildren then
			data.name = category.Name
			self:AppendRow_Category_Title(listType, data)
		else
			self:AppendRow_Category_Checkbox(listType, data)
		end
	end
end

function base.AppendMasterListTypeCombined(self, listType)
	base:Debug("AppendMasterListTypeCombined", self, listType)
	self:AppendRow_Title(listType, {name = "Display names and labels"})
	self:AppendRow_Divider(listType, {})
	self:AppendRow_Slider(listType, {
		name = "Display name offset horizontal",
		tooltipText = "Display name offset horizontal\n(X)",
		funcGet = function()
			return base.Saved.Combine.Label.Offset.X
		end,
		funcSet = function(sliderControl, newValue)
			local valueLabel = GetControl(sliderControl:GetParent(), "ValueLabel")

			if valueLabel then
				valueLabel:SetText(newValue)
			end

			base.Saved.Combine.Label.Offset.X = newValue
			base:RestoreCombineLabels()
		end,
		minValue = -500,
		maxValue = 500,
		valueStep = 1,
		default = base.Default.Combine.Label.Offset.X,
		valueFormat = texts.Format.Number,
		showValue = true
	})
	self:AppendRow_Slider(listType, {
		name = "Display name offset vertical",
		tooltipText = "Display name offset vertical\n(Y)",
		funcGet = function()
			return base.Saved.Combine.Label.Offset.Y
		end,
		funcSet = function(sliderControl, newValue)
			local valueLabel = GetControl(sliderControl:GetParent(), "ValueLabel")

			if valueLabel then
				valueLabel:SetText(newValue)
			end

			base.Saved.Combine.Label.Offset.Y = newValue
			base:RestoreCombineLabels()
		end,
		minValue = -500,
		maxValue = 500,
		valueStep = 1,
		default = base.Default.Combine.Label.Offset.Y,
		valueFormat = texts.Format.Number,
		showValue = true
	})
	self:AppendRow_Dropdown(listType, {
		name = "Display name anchor position on button",
		tooltipText = "Select display name anchor position on the button",
		funcGet = function()
			return base:GetLocationText(base.Saved.Combine.Label.PositionTarget)
		end,
		choices = base.Global.ChoiceLocations,
		funcSet = function(_, newValue)
			base.Saved.Combine.Label.PositionTarget = base:GetLocationValue(newValue)
			base:RestoreCombineLabels()
		end
	})
	self:AppendRow_Dropdown(listType, {
		name = "Display name anchor position on label",
		tooltipText = "Select display name anchor position on the label",
		funcGet = function()
			return base:GetLocationText(base.Saved.Combine.Label.Position)
		end,
		choices = base.Global.ChoiceLocations,
		funcSet = function(_, newValue)
			base.Saved.Combine.Label.Position = base:GetLocationValue(newValue)
			base:RestoreCombineLabels()
		end
	})
	self:AppendRow_Title(listType, {name = "Position and size"})
	self:AppendRow_Divider(listType, {})
	self:AppendRow_Slider(listType, {
		name = "Choose default bar depth",
		tooltipText = "Choose default bar depth\n(number of rows/columns)",
		funcGet = function()
			return base.Saved.Combine.Bar.Depth
		end,
		funcSet = function(sliderControl, newValue)
			local valueLabel = GetControl(sliderControl:GetParent(), "ValueLabel")

			if valueLabel then
				valueLabel:SetText(newValue)
			end

			base.Saved.Combine.Bar.Depth = newValue
			base:RestoreFrames()
		end,
		minValue = 0,
		maxValue = base.Global.HighestUnlocked,
		valueStep = 1,
		default = base.Default.Bar.Depth,
		valueFormat = texts.Format.Number,
		showValue = true
	})
	self:AppendRow_Slider(listType, {
		name = "Choose max bar height",
		tooltipText = "Choose max bar height\n(number of inverse rows/columns)",
		funcGet = function()
			return base.Saved.Combine.Bar.Width
		end,
		funcSet = function(sliderControl, newValue)
			local valueLabel = GetControl(sliderControl:GetParent(), "ValueLabel")

			if valueLabel then
				valueLabel:SetText(newValue)
			end

			base.Saved.Combine.Bar.Width = newValue
			base:RestoreFrames()
		end,
		minValue = 0,
		maxValue = base.Global.HighestUnlocked,
		valueStep = 1,
		default = base.Default.Bar.Width,
		valueFormat = texts.Format.Number,
		showValue = true
	})
end

function base.AppendMasterListTypeCollectibles(self, listType)
	base:Debug("AppendMasterListTypeCollectibles", self, listType)
	self:AppendRow_Title(listType, {name = "Collectibles"})
	self:AppendRow_Divider(listType, {})
	self:AppendRow_Checkbox(listType, {
		name = string.format("Show disabled %s", self.category.Name),
		tooltipText = string.format("When ON disabled elements will be shown for %s", self.category.Name),
		funcGet = function()
			return self.category.Saved.Menu.ShowDisabled
		end,
		funcSet = function(_, newValue)
			self.category.Saved.Menu.ShowDisabled = newValue
			base:CreateCategory(self.category)
			base.Global.Settings.List:RefreshData()
		end
	})
	self:AppendRow_Divider(listType, {})
	self:AppendRow_Checkbox(listType, {
		name = string.format("Auto select all %s", self.category.Name),
		tooltipText = string.format("When pressed all %s will be available", self.category.Name),
		funcGet = function()
			return self.category.Saved.AutoSelectAll
		end,
		funcSet = function(_, newValue)
			self.category.Saved.AutoSelectAll = newValue
			base:AutoSelectAll(self.category, newValue)
			base:RestoreFrame(self.category)
			base:RestoreCombineLabels()
			base.Global.Settings.List:RefreshData()
		end
	})
	self:AppendRow_Divider(listType, {})
	self:AppendRow_Checkbox(listType, {
		name = string.format("Select all %s", self.category.Name),
		tooltipText = string.format("When pressed all %s will either be selected or deselected", self.category.Name),
		disabledFunc = function()
			return self.category.Saved.AutoSelectAll
		end,
		funcGet = function()
			return base:IsAllSelected(self.category)
		end,
		funcSet = function(_, newValue)
			base:SelectAll(self.category, newValue)
			base:RestoreFrame(self.category)
			base:RestoreCombineLabels()
			base.Global.Settings.List:RefreshData()
		end
	})
	self:AppendRow_Divider(listType, {})
	for _, collectible in ipairs(self.category.CollectionOrdered) do
		if not collectible.Disabled or self.category.Saved.Menu.ShowDisabled and collectible.Disabled then
			self:AppendRow_Checkbox(listType, {
				cId = collectible.Id,
				name = string.format("Show %s", collectible.Name),
				tooltipText = collectible.Tooltip,
				funcGet = function()
					return self.category.Saved.Selected[collectible.Id]
				end,
				disabledFunc = function()
					return collectible.Disabled or self.category.Saved.AutoSelectAll
				end,
				funcSet = function(checkBoxControl, newValue)
					local control = checkBoxControl:GetParent()

					if not (control.data.disabledFunc and control.data.disabledFunc()) then
						if newValue == true then
							self.category.Saved.Selected[control.data.cId] = newValue
						else
							self.category.Saved.Selected[control.data.cId] = nil
						end

						base:RestoreFrame(self.category)
						base:RestoreCombineLabels()
						base.Global.Settings.List:RefreshData()
					end
				end

			})
		end
	end
end

function base.AppendMasterListTypeCategory(self, listType)
	base:Debug("AppendMasterListTypeCategory", self, listType)
	local disabledWhenTooltipIsHidden = "Disabled when tooltip is not shown"
	local disabledWhenLabelIsHidden = "Disabled when label is not shown"
	local disabledWhenCombined = "Disabled when Collection is included in combine bar"

	self:AppendRow_Title(listType, {name = "Tooltip"})
	self:AppendRow_Divider(listType, {})
	self:AppendRow_Checkbox(listType, {
		name = "Show tooltip",
		tooltipText = "When ON tooltips will be shown, when hovering buttons on the bar",
		funcGet = function()
			return self.category.Saved.Tooltip.Show
		end,
		funcSet = function(_, newValue)
			self.category.Saved.Tooltip.Show = newValue
			base:SetupButtons(self.category)
			base.Global.Settings.List:RefreshData()
		end
	})
	self:AppendRow_Dropdown(listType, {
		name = "Show tooltip anchor position",
		tooltipText = string.format("Select tooltip anchor position\n%s", disabledWhenTooltipIsHidden),
		choices = base.Global.ChoiceLocations,
		disabledFunc = function()
			return not self.category.Saved.Tooltip.Show
		end,
		funcGet = function()
			return base:GetLocationText(self.category.Saved.Tooltip.Position)
		end,
		funcSet = function(_, newValue)
			self.category.Saved.Tooltip.Position = base:GetLocationValue(newValue)
			base:SetupButtons(self.category)
		end
	})

	self:AppendRow_Title(listType, {name = "Display name and label"})
	self:AppendRow_Divider(listType, {})
	self:AppendRow_Checkbox(listType, {
		name = "Include in combine bar",
		tooltipText = "When ON will be attached to a combined bar",
		funcGet = function()
			return self.category.Saved.Bar.IsCombined
		end,
		funcSet = function(_, newValue)
			self.category.Saved.Bar.IsCombined = newValue
			base:RestoreFrame(self.category)
			base:RestoreCombineLabels()
			base.Global.Settings.List:RefreshData()
		end
	})
	self:AppendRow_Divider(listType, {})
	self:AppendRow_Checkbox(listType, {
		name = "Enable hide/toggle visibility of the label",
		tooltipText = string.format("When enabled a +/- at the end of the label indicates if the label is hidden or shown\n%s", disabledWhenCombined),
		disabledFunc = function()
			return self.category.Saved.Bar.IsCombined
		end,
		funcGet = function()
			return self.category.Saved.Bar.IsCombined or self.category.Saved.Label.EnableHideAll
		end,
		funcSet = function(_, newValue)
			if (not newValue) then
				self.category.Saved.Bar.HideAll = newValue
				base:RestoreFrame(self.category)
			end
			self.category.Saved.Label.EnableHideAll = newValue
			self.category.Saved.Label.Show = true
			base:SetupLabel(self.category)
			base:RestoreLabel(self.category)
			base.Global.Settings.List:RefreshData()
		end
	})
	self:AppendRow_Checkbox(listType, {
		name = "Show label",
		tooltipText = string.format("%s or hide/toggle visibility is enabled", disabledWhenCombined),
		disabledFunc = function()
			return self.category.Saved.Label.EnableHideAll or self.category.Saved.Bar.IsCombined
		end,
		funcGet = function()
			return self.category.Saved.Label.Show or self.category.Saved.Bar.IsCombined
		end,
		funcSet = function(_, newValue)
			self.category.Saved.Label.Show = newValue
			base:SetupLabel(self.category)
			base:RestoreLabel(self.category)
			base.Global.Settings.List:RefreshData()
		end
	})
	self:AppendRow_EditBox(listType, {
		name = "Display name",
		tooltipText = string.format("Change displayname used on the label\n%s", disabledWhenLabelIsHidden),
		disabledFunc = function()
			return not self.category.Saved.Label.Show
		end,
		funcGet = function()
			return tostring(self.category.Saved.Label.Display)
		end,
		funcSet = function(control)
			self.category.Saved.Label.Display = control:GetText() or ""
			base:RestoreFrame(self.category)
			base:RestoreCombineLabels()
		end
	})
	self:AppendRow_Dropdown(listType, {
		name = "Display name font",
		tooltipText = string.format("Change display name font\n%s", disabledWhenLabelIsHidden),
		disabledFunc = function()
			return not self.category.Saved.Label.Show
		end,
		choices = base.Global.AvailableFonts,
		funcGet = function()
			return self.category.Saved.Label.Font
		end,
		funcSet = function(_, newValue)
			self.category.Saved.Label.Font = newValue
			base:RestoreFrame(self.category)
			base:RestoreCombineLabels()
		end
	})
	self:AppendRow_Slider(listType, {
		name = "Display name height",
		tooltipText = string.format("Change display name height\n%s", disabledWhenLabelIsHidden),
		disabledFunc = function()
			return not self.category.Saved.Label.Show
		end,
		funcGet = function()
			return self.category.Saved.Label.Height
		end,
		funcSet = function(sliderControl, newValue)
			local valueLabel = GetControl(sliderControl:GetParent(), "ValueLabel")

			if valueLabel then
				valueLabel:SetText(newValue)
			end

			self.category.Saved.Label.Height = newValue
			base:RestoreFrame(self.category)
			base:RestoreCombineLabels()
		end,
		minValue = 0,
		maxValue = 100,
		valueStep = 1,
		default = base.Default.Categories[self.category.Id].Label.Height,
		valueFormat = texts.Format.Number,
		showValue = true
	})
	self:AppendRow_Slider(listType, {
		name = "Display name width",
		tooltipText = string.format("Change display name width\n%s", disabledWhenLabelIsHidden),
		disabledFunc = function()
			return not self.category.Saved.Label.Show
		end,
		funcGet = function()
			return self.category.Saved.Label.Width
		end,
		funcSet = function(sliderControl, newValue)
			local valueLabel = GetControl(sliderControl:GetParent(), "ValueLabel")

			if valueLabel then
				valueLabel:SetText(newValue)
			end

			self.category.Saved.Label.Width = newValue
			base:RestoreFrame(self.category)
			base:RestoreCombineLabels()
		end,
		minValue = 0,
		maxValue = 500,
		valueStep = 1,
		default = base.Default.Categories[self.category.Id].Label.Width,
		valueFormat = texts.Format.Number,
		showValue = true
	})
	self:AppendRow_Slider(listType, {
		name = "Display name offset horizontal",
		tooltipText = string.format("Display name offset horizontal\n(X)\n%s", disabledWhenLabelIsHidden),
		disabledFunc = function()
			return not self.category.Saved.Label.Show
		end,
		funcGet = function()
			return self.category.Saved.Label.Offset.X
		end,
		funcSet = function(sliderControl, newValue)
			local valueLabel = GetControl(sliderControl:GetParent(), "ValueLabel")

			if valueLabel then
				valueLabel:SetText(newValue)
			end

			self.category.Saved.Label.Offset.X = newValue
			base:RestoreFrame(self.category)
			base:RestoreCombineLabels()
		end,
		minValue = -500,
		maxValue = 500,
		valueStep = 1,
		default = base.Default.Categories[self.category.Id].Label.Offset.X,
		valueFormat = texts.Format.Number,
		showValue = true
	})
	self:AppendRow_Slider(listType, {
		name = "Display name offset vertical",
		tooltipText = string.format("Display name offset vertical\n(y)\n%s", disabledWhenLabelIsHidden),
		disabledFunc = function()
			return not self.category.Saved.Label.Show
		end,
		funcGet = function()
			return self.category.Saved.Label.Offset.Y
		end,
		funcSet = function(sliderControl, newValue)
			local valueLabel = GetControl(sliderControl:GetParent(), "ValueLabel")

			if valueLabel then
				valueLabel:SetText(newValue)
			end

			self.category.Saved.Label.Offset.Y = newValue
			base:RestoreFrame(self.category)
			base:RestoreCombineLabels()
		end,
		minValue = -500,
		maxValue = 500,
		valueStep = 1,
		default = base.Default.Categories[self.category.Id].Label.Offset.Y,
		valueFormat = texts.Format.Number,
		showValue = true
	})
	self:AppendRow_Dropdown(listType, {
		name = "Display name anchor position on button",
		tooltipText = string.format("Select display name anchor position on the button\n%s\n or Collection is included in combine bar", disabledWhenLabelIsHidden),
		disabledFunc = function()
			return not self.category.Saved.Label.Show or self.category.Saved.Bar.IsCombined
		end,
		funcGet = function()
			local text = self.category.Saved.Label.PositionTarget

			if self.category.Saved.Bar.IsCombined then
				text = base.Saved.Combine.Label.PositionTarget
			end

			return base:GetLocationText(text)
		end,
		choices = base.Global.ChoiceLocations,
		funcSet = function(_, newValue)
			self.category.Saved.Label.PositionTarget = base:GetLocationValue(newValue)
			base:RestoreFrame(self.category)
			base:RestoreCombineLabels()
		end
	})
	self:AppendRow_Dropdown(listType, {
		name = "Display name anchor position on label",
		tooltipText = string.format("Select display name anchor position on the label\n%s\n or Collection is included in combine bar", disabledWhenLabelIsHidden),
		disabledFunc = function()
			return not self.category.Saved.Label.Show or self.category.Saved.Bar.IsCombined
		end,
		funcGet = function()
			local text = self.category.Saved.Label.Position

			if self.category.Saved.Bar.IsCombined then
				text = base.Saved.Combine.Label.Position
			end

			return base:GetLocationText(text)
		end,
		choices = base.Global.ChoiceLocations,
		funcSet = function(_, newValue)
			self.category.Saved.Label.Position = base:GetLocationValue(newValue)
			base:RestoreFrame(self.category)
			base:RestoreCombineLabels()
		end
	})

	self:AppendRow_Title(listType, {name = "Position and size"})
	self:AppendRow_Divider(listType, {})
	self:AppendRow_Slider(listType, {
		name = "Choose bar depth",
		tooltipText = string.format("Choose bar depth\n(number of rows/columns)\n%s", disabledWhenCombined),
		disabledFunc = function()
			return self.category.Saved.Bar.IsCombined
		end,
		funcGet = function()
			return self.category.Saved.Bar.Depth
		end,
		funcSet = function(sliderControl, newValue)
			local valueLabel = GetControl(sliderControl:GetParent(), "ValueLabel")

			if valueLabel then
				valueLabel:SetText(newValue)
			end

			self.category.Saved.Bar.Depth = newValue
			base:RestoreFrame(self.category)
			base:RestoreCombineLabels()
		end,
		minValue = 0,
		maxValue = self.category.Unlocked,
		valueStep = 1,
		default = base.Default.Categories[self.category.Id].Bar.Depth,
		valueFormat = texts.Format.Number,
		showValue = true
	})
	self:AppendRow_Slider(listType, {
		name = "Choose max bar height",
		tooltipText = string.format("Choose bar height\n(number of inverse rows/columns)\n%s", disabledWhenCombined),
		disabledFunc = function()
			return self.category.Saved.Bar.IsCombined
		end,
		funcGet = function()
			return self.category.Saved.Bar.Width
		end,
		funcSet = function(sliderControl, newValue)
			local valueLabel = GetControl(sliderControl:GetParent(), "ValueLabel")

			if valueLabel then
				valueLabel:SetText(newValue)
			end

			self.category.Saved.Bar.Width = newValue
			base:RestoreFrame(self.category)
			base:RestoreCombineLabels()
		end,
		minValue = 0,
		maxValue = self.category.Unlocked,
		valueStep = 1,
		default = base.Default.Categories[self.category.Id].Bar.Width,
		showValue = true
	})
	self:AppendRow_Checkbox(listType, {
		name = "Bar orientation horizontal",
		tooltipText = string.format("Bar orientation horizontal\n%s", disabledWhenCombined),
		disabledFunc = function()
			return self.category.Saved.Bar.IsCombined
		end,
		funcGet = function()
			return self.category.Saved.Bar.Horizontal
		end,
		funcSet = function(_, newValue)
			self.category.Saved.Bar.Horizontal = newValue
			base:RestoreFrame(self.category)
			base:RestoreCombineLabels()
		end
	})
end

function base.AppendMasterListTypeNoCategory(self, listType)
	base:Debug("AppendMasterListTypeNoCategory", self, listType)
	self:AppendRow_Title(listType, {name = "Select a category"})
	self:AppendRow_Divider(listType, {})
end
