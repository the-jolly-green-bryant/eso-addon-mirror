local MSorter = ZO_Object:Subclass()

EVENT_MANAGER:RegisterForEvent("MagicSorter", EVENT_ADD_ON_LOADED, function(event, addOnName)
	if string.lower(addOnName) == "magicsorter" then
		EVENT_MANAGER:UnregisterForEvent("MagicSorter", EVENT_ADD_ON_LOADED)
		MAGIC_SORTER = MSorter:New()
	end
end)

function MSorter:New()
	local object = ZO_Object.New(self)
	object:Initialize()
	return object
end

function MSorter:Initialize()
	if not self.initialized then
		self.initialized = true
		self.quickSortMode = false
		self:InitializeStaticData()
		self:InitializeSavedVariables()
		self:InitializeManagers()
		self:InitializeDialogs()
		self:InitializeEventHandlers()
	end
end

function MSorter:InitializeStaticData()
	self.AddonVersion = 20
	self.AddonName = "MagicSorter"
	self.AddonDev = "Architectura"
	self.EventDescriptor = "magicsorter"
	self.KeybindButtons = {alignment = KEYBIND_STRIP_ALIGN_CENTER, {name = "Magic Sorter", keybind = "UI_SHORTCUT_REPORT_PLAYER", callback = function() MAGIC_SORTER:StartStorageWizard() end, visible = function() return true end,},}
	self.KeybindId = "MAGIC_SORTER"
	self.MaxHouseId = 300
	self.MaxKeybind = 4
	self.MinKeybind = 1
	self.SavedVarsDefaults = {Data = {HouseCategories = {}}}
	self.SavedVarsFilename = "MagicSorter"
	self.SavedVarsVersion = 1

	self.InvalidParentCategoryIds = {
		[16] = true, -- Mounts
		[25] = true, -- Services
		[33] = true, -- Non-combat Pets
	}
	self.InvalidSubcategoryIds = {
		["9_90"] = true, -- Gallery, Undaunted Busts
		["9_157"] = true, -- Gallery, Undaunted Trophies
		["9_184"] = true, -- Gallery, ESO Plus
	}
end

function MSorter:CleanSavedVariables()
	local data = self:GetData()
	-- Remove any references to the master "Furniture" category.
	local houses = self:GetStorageHouses()
	for _, house in pairs(houses) do
		if house.assignedCategoryIds then
			house.assignedCategoryIds[1] = nil
		end
	end
end

function MSorter:InitializeSavedVariables()
	if not self.Vars then
		self.Vars = ZO_SavedVars:NewAccountWide(self.SavedVarsFilename, self.SavedVarsVersion, nil, self.SavedVarsDefaults)
		if not self.Vars.Config then
			self.Vars.Config = {}
		end
		if not self.Vars.Data then
			self.Vars.Data = {}
		end
		self:CleanSavedVariables()
	end
end

function MSorter:InitializeEventHandlers()
	local function OnFurnitureChanged(...)
		local manager = self:GetSortManager()
		if manager then
			manager:OnFurnitureChanged(...)
		end
	end
	local function OnActivityFinderStatusUpdate(event, status)
		if self:IsAutomaticStorageRunning() and status == ACTIVITY_FINDER_STATUS_READY_CHECK then
			self:SuspendAutomaticStorage()
			self:GetSortManager():LogAction("Ready check initiated; suspending sort operation.")
		end
	end
	EVENT_MANAGER:RegisterForEvent(self.EventDescriptor, EVENT_HOUSING_FURNITURE_PLACED, OnFurnitureChanged )
	EVENT_MANAGER:RegisterForEvent(self.EventDescriptor, EVENT_HOUSING_FURNITURE_REMOVED, OnFurnitureChanged )
	EVENT_MANAGER:RegisterForEvent(self.EventDescriptor, EVENT_ACTIVITY_FINDER_STATUS_UPDATE, OnActivityFinderStatusUpdate)
end

function MSorter:InitializeManagers()
	if not self.inventoryManager then
		self.inventoryManager = InstantiateMagicInventoryManager(self)
	end
	if not self.sortManager then
		self.sortManager = InstantiateMagicSortManager(self)
	end
end

function MSorter:InitializeEventHandlers()
	if not self.initializedEventHandlers then
		self.initializedEventHandlers = true
		EVENT_MANAGER:RegisterForEvent(self.EventDescriptor, EVENT_PLAYER_ACTIVATED, function(...) self:OnPlayerActivated(...) end)
		local function OnSceneStateChange(oldState, newState)
			if newState == "shown" then
				self:UpdateKeybindStrip(true)
			elseif newState == "hidden" then
				self:UpdateKeybindStrip(false)
			end
		end
		local inventoryScene = SCENE_MANAGER:GetScene("inventory")
		if inventoryScene then
			inventoryScene:RegisterCallback("StateChange", OnSceneStateChange)
		end
		local keyboardHousingScene = SCENE_MANAGER:GetScene("keyboard_housing_furniture_scene")
		if keyboardHousingScene then
			keyboardHousingScene:RegisterCallback("StateChange", OnSceneStateChange)
		end
		local gamepadHousingScene = SCENE_MANAGER:GetScene("gamepad_housing_furniture_scene")
		if gamepadHousingScene then
			gamepadHousingScene:RegisterCallback("StateChange", OnSceneStateChange)
		end
	end
end

function MSorter:InitializeKeybinds()
	if not self.initializedKeybinds then
		self.initializedKeybinds = true
		KEYBINDING_MANAGER.IsChordingAlwaysEnabled = function()	return true end
		ZO_CreateStringId("SI_BINDING_NAME_" .. self.KeybindId, "Magic Sorter")
		self:CreateKeybind(self.KeybindId, KEY_F10, 0, 0, 0, 0)
	end
end

function MSorter:GetVersion()
	return self.AddonVersion
end

function MSorter:GetConfig()
	return self.Vars.Config
end

function MSorter:GetData()
	return self.Vars.Data
end

function MSorter:SetQuickSortMode(enabled)
	self.quickSortMode = true == enabled
end

function MSorter:IsQuickSortMode()
	return true == self.quickSortMode and not self:HaveSettingsChanged()
end

function MSorter:RotateTexture(texture, angle, centerX, centerY, scaleX, scaleY)
	angle, centerX, centerY, scaleX, scaleY = angle or 0, centerX or 0.5, centerY or 0.5, scaleX or 1, scaleY or 1
	local cosine, sine = math.cos(angle), math.sin(angle)
	local x1, y1 = -0.5 * sine + -0.5 * cosine, -0.5 * cosine - -0.5 * sine
	local x2, y2 = -0.5 * sine + 0.5 * cosine, -0.5 * cosine - 0.5 * sine
	local x3, y3 = 0.5 * sine + -0.5 * cosine, 0.5 * cosine - -0.5 * sine
	local x4, y4 = 0.5 * sine + 0.5 * cosine, 0.5 * cosine - 0.5 * sine
	texture:SetVertexUV(1, centerX + scaleX * x1, centerY + scaleY * y1)
	texture:SetVertexUV(2, centerX + scaleX * x2, centerY + scaleY * y2)
	texture:SetVertexUV(4, centerX + scaleX * x3, centerY + scaleY * y3)
	texture:SetVertexUV(8, centerX + scaleX * x4, centerY + scaleY * y4)
end

function MSorter:CreateKeybind(binding, key, modifier1, modifier2, modifier3, modifier4)
	local layer, category, action = GetActionIndicesFromName(binding)
	if GetBindingIndicesFromKeys(layer, key, modifier1, modifier2, modifier3, modifier4) then
		return
	end
	for keybind = self.MinKeybind, self.MaxKeybind do
		if GetActionBindingInfo(layer, category, action, keybind) ~= KEY_INVALID then
			return
		end
	end
	if IsProtectedFunction("BindKeyToAction") then
		CallSecureProtected("BindKeyToAction", layer, category, action, self.MinKeybind, key, modifier1, modifier2, modifier3, modifier4)
	else
		BindKeyToAction(layer, category, action, self.MinKeybind, key, modifier1, modifier2, modifier3, modifier4)
	end
end

function MSorter:InitializeDialogs()
	self.dialogs = {}
	self.dialogs["HouseSelection"] = {control = MagicSorter_HouseSelection}
	self.dialogs["CategoryAssignment"] = {control = MagicSorter_CategoryAssignment}
	self.dialogs["ThemeAssignment"] = {control = MagicSorter_ThemeAssignment}
	self.dialogs["Disclaimer"] = {control = MagicSorter_Disclaimer}
	self.dialogs["StorageProgress"] = {control = MagicSorter_StorageProgress}
	self.dialogs["Complete"] = {control = MagicSorter_Complete}
	self.dialogs["ReportInventory"] = {control = MagicSorter_ReportInventory}
	local version = string.format("Version %.1f", self:GetVersion())
	for dialogName, dialog in pairs(self.dialogs) do
		dialog.name = dialogName
		local versionLabel = dialog.control:GetNamedChild("Version")
		if versionLabel then
			versionLabel:SetText(version)
		end
	end
end

function MSorter:GetDialog(dialogName)
	return self.dialogs[dialogName]
end

function MSorter:GetDialogControl(dialogName)
	return self:GetDialog(dialogName).control
end

function MSorter:GetDialogsByVisibility(isHidden)
	local dialogs = {}
	for dialogName, dialog in pairs(self.dialogs) do
		if dialog.control:IsHidden() == isHidden then
			table.insert(dialogs, dialog)
		end
	end
	return dialogs
end

function MSorter:GetDialogName(control)
	for dialogName, dialog in pairs(self.dialogs) do
		if dialog.control == control then
			return dialogName
		end
	end
	return nil
end

function MSorter:GetDialogSettings(dialogName)
	if not dialogName or dialogName == "" then
		return nil
	end

	local settings = self:GetConfig().DialogSettings
	if not settings then
		settings = {}
		self:GetConfig().DialogSettings = settings
	end

	local dialogSettings = settings[dialogName]
	if not dialogSettings then
		dialogSettings = {}
		settings[dialogName] = dialogSettings
	end

	return dialogSettings
end

function MSorter:IsDialogHidden(dialogName)
	local control = self:GetDialogControl(dialogName)
	return control:IsHidden()
end

function MSorter:SetAllDialogsHidden()
	for dialogName, dialog in pairs(self.dialogs) do
		dialog.control:SetHidden(true)
	end
end

function MSorter:SetupAndDockReportSummaryToDialog(report, control)
	local summary = MagicSorter_ReportSummary
	local panel = summary.panel
	local slider = summary.slider
	local message = summary.message
	local container = message:GetParent()
	local reportLines = {}
	for lineIndex, line in ipairs(report) do
		if line == "" then
			break
		end
		table.insert(reportLines, line)
	end
	message:SetText(table.concat(reportLines, "\n"))
	summary:ClearAnchors()
	summary:SetAnchor(RIGHT, control, LEFT, -15)
	summary:SetHidden(false)
	zo_callLater(function()
		local height = message:GetTextHeight()
		container:SetHeight(height)
		slider:SetMinMax(0, math.max(0, height - panel:GetHeight()))
	end, 400)
end

function MSorter:RefreshReportSummaryHiddenState()
	local summary = MagicSorter_ReportSummary
	local sortManager = self:GetSortManager()
	if sortManager then
		local report = sortManager:GetLastReport()
		if "table" == type(report) and #report > 0 then
			for dialogName, dialog in pairs(self.dialogs) do
				if dialogName == "HouseSelection" or dialogName == "CategoryAssignment" then
					if not dialog.control:IsHidden() then
						self:SetupAndDockReportSummaryToDialog(report, dialog.control)
						return
					end
				end
			end
		end
	end
	summary:SetHidden(true)
	summary:ClearAnchors()
end

function MSorter:SetDialogHidden(dialogName, isHidden)
	local control = self:GetDialogControl(dialogName)
	if not isHidden then
		if control.Refresh then
			control:Refresh()
		end
		if control.backdropAnimation then
			control.backdropAnimation:PlayForward()
		end
		self:SetUIMode(true)
	end
	control:SetHidden(isHidden)
	self:RefreshReportSummaryHiddenState()
end

function MSorter:ToggleDialogHidden(dialogName)
	local hide = not self:IsDialogHidden(dialogName)
	if hide then
		self:SetDialogHidden(dialogName, true)
	else
		SCENE_MANAGER:Show("hud")
		HousingEditorRequestModeChange(HOUSING_EDITOR_MODE_DISABLED)
		local visibleDialogs = self:GetDialogsByVisibility(false)
		if not visibleDialogs or #visibleDialogs == 0 then
			self:SetDialogHidden(dialogName, false)
		end
	end
	self:RefreshReportSummaryHiddenState()
end

function MSorter:SetUIMode(enabled)
	if enabled then
		zo_callLater(function()
			if not IsGameCameraUIModeActive() then
				SetGameCameraUIMode(true)
			end
		end, 50)
	else
		zo_callLater(function()
			if IsGameCameraUIModeActive() then
				SetGameCameraUIMode(false)
			end
		end, 50)
	end
end

function MSorter:ShowCompleteDialog()
	if self:GetData().showCompleteDialog then
		self:SetDialogHidden("Complete", false)
	end
end

function MSorter:StartStorageWizard()
	local visibleDialogs = self:GetDialogsByVisibility(false)
	if visibleDialogs and #visibleDialogs > 0 and not self:IsAutomaticStorageRunning() then
		self:SetAllDialogsHidden()
	else
		self:ToggleDialogHidden("HouseSelection")
	end
end

function MSorter:OnDialogMoved(control)
	--self:SaveDialogSettings(control)
end

function MSorter:OnDialogShow(control)
	--self:RestoreDialogSettings(control)
end

function MSorter:OnSettingsChanged()
	self:GetConfig().dirty = true
end

function MSorter:OnSortCompleted(report)
	self:GetData().lastReport = report
	self:GetConfig().dirty = false
end

function MSorter:HaveSettingsChanged()
	return true == self:GetConfig().dirty
end

function MSorter:SaveDialogSettings(control)
	local settings = self:GetDialogSettings(self:GetDialogName(control))
	if settings then
		local left, top, right, bottom = control:GetScreenRect()
		settings.left = left or settings.left
		settings.top = top or settings.top
		settings.right = right or settings.right
		settings.bottom = bottom or settings.bottom
	end
end

function MSorter:RestoreDialogSettings(control)
	if not control.restoredDialogSettings then
		control.restoredDialogSettings = true
		local settings = self:GetDialogSettings(self:GetDialogName(control))
		if settings then
			local left, top, right, bottom = control:GetScreenRect()
			left = settings.left or left
			top = settings.top or top
			right = settings.right or right
			bottom = settings.bottom or bottom
			local width, height = right - left, bottom - top
			control:ClearAnchors()
			control:SetDimensions(width, height)
			control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
			if control.Refresh then
				control:Refresh()
			end
		end
	end
end

function MSorter:GetMouseOverControl(controls)
	local mouseX, mouseY = GetUIMousePosition()
	for key, control in pairs(controls) do
		if not control:IsHidden() then
			local minX, minY, maxX, maxY = control:GetScreenRect()
			if mouseX >= minX and mouseX <= maxX and mouseY >= minY and mouseY <= maxY then
				return control, key
			end
		end
	end
	return nil
end

function MSorter:SetOrganizationEnabled(enabled)
	if nil ~= enabled then
		self:GetConfig().isOrganizationEnabled = enabled
	end
end

function MSorter:IsOrganizationEnabled()
	local enabled = self:GetConfig().isOrganizationEnabled
	if nil == enabled then
		return true
	else
		return enabled
	end
end

function MSorter:GetOwnedHouses()
	local houses = {}
	for houseId = 1, self.MaxHouseId do
		local collectibleId = GetCollectibleIdForHouse(houseId)
		local owned = IsCollectibleUnlocked(collectibleId)
		if owned then
			local houseName = GetCollectibleName(collectibleId)
			local _, _, houseIcon = GetCollectibleInfo(collectibleId)
			local houseImage = GetHousePreviewBackgroundImage(houseId)
			local house = {collectibleId = collectibleId, houseId = houseId, houseName = houseName, houseIcon = houseIcon, houseImage = houseImage, assignedCategoryIds = {}, assignedThemeIds = {}}
			table.insert(houses, house)
		end
	end
	table.sort(houses, function(houseA, houseB) return houseA.houseName < houseB.houseName end)
	return houses
end

function MSorter:SetStorageHouses(houses)
	if houses then
		local previousHouses = {}
		for houseId in pairs(self:GetData().StorageHouses or {}) do
			previousHouses[houseId] = true
		end
		local houseData = {}
		for _, house in pairs(houses) do
			houseData[house.houseId] = house
		end
		self:GetData().StorageHouses = houseData
		local changed = false
		for houseId in pairs(houseData) do
			if not previousHouses[houseId] then
				changed = true
				break
			end
			previousHouses[houseId] = nil
		end
		if changed or NonContiguousCount(previousHouses) ~= 0 then
			self:OnSettingsChanged()
		end
		return true
	end
	return false
end

function MSorter:GetStorageHouses()
	local houses = self:GetData().StorageHouses
	if not houses then
		houses = {}
		self:GetData().StorageHouses = houses
	end
	return houses
end

function MSorter:GetStorageHouse(houseId)
	return self:GetStorageHouses()[houseId]
end

function MSorter:OnSubmitStorageHouses(houses)
	local storageHouses = {}
	local numHouses = 0
	for _, house in ipairs(houses) do
		local storageHouse = self:GetStorageHouse(house.houseId)
		if not storageHouse then
			storageHouse = house
		end
		storageHouses[house.houseId] = storageHouse
		numHouses = numHouses + 1
	end
	if numHouses == 0 then
		return nil
	end
	return self:SetStorageHouses(storageHouses)
end

function MSorter:OnSubmitCategoryAssignments()
	for _, house in pairs(self:GetStorageHouses()) do
		if house.assignedCategoryIds then
			for categoryId in pairs(house.assignedCategoryIds) do
				return true
			end
		end
	end
	return false
end

function MSorter:AddFurnitureCategory(categoryId, parentCategoryId, parentCategoryName)
	-- Ignore the master "Furniture" category.
	if categoryId and categoryId ~= 0 and categoryId ~= 1 then
		local category = self.furnitureCategories[categoryId]
		if category then
			return category
		else
			local categoryName = GetFurnitureCategoryName(categoryId)
			local displayName
			if parentCategoryId and parentCategoryName then
				displayName = string.format("%s, %s", parentCategoryName, categoryName)
			else
				displayName = string.format("%s, All", categoryName)
			end
			local category = {id = categoryId, parentId = parentCategoryId or 0, name = categoryName, displayName = displayName, assignedHouseIds = {}}
			self.furnitureCategories[categoryId] = category
			return category
		end
	end
end

function MSorter:IsValidFurnitureCategory(categoryId, subcategoryId)
	if not subcategoryId then
		return not self.InvalidParentCategoryIds[categoryId]
	else
		return not self.InvalidSubcategoryIds[string.format("%d_%d", categoryId, subcategoryId)]
	end
end

function MSorter:GetFurnitureCategories()
	if not self.furnitureCategories then
		self.furnitureCategories = {}
		local numCategories = GetNumFurnitureCategories()
		for categoryIndex = 1, numCategories do
			local categoryId = GetFurnitureCategoryId(categoryIndex)
			if self:IsValidFurnitureCategory(categoryId) then
				local category = self:AddFurnitureCategory(categoryId)
				if category then
					local categoryId = category.id
					local categoryName = category.name
					local numSubcategories = GetNumFurnitureSubcategories(categoryId)
					for subcategoryIndex = 1, numSubcategories do
						local subcategoryId = GetFurnitureSubcategoryId(categoryIndex, subcategoryIndex)
						if self:IsValidFurnitureCategory(categoryId, subcategoryId) then
							self:AddFurnitureCategory(subcategoryId, categoryId, categoryName)
						end
					end
				end
			end
		end
	end
	return self.furnitureCategories
end

function MSorter:GetFurnitureSubcategories(categoryId)
	local categories = self:GetFurnitureCategories()
	local subcategories = {}
	for _, category in pairs(categories) do
		if category.parentId == categoryId then
			table.insert(subcategories, category)
		end
	end
	return subcategories
end

function MSorter:GetFurnitureCategory(categoryId)
	local categories = self:GetFurnitureCategories()
	return categories[categoryId]
end

function MSorter:GetCategoryHouseAssignments(categoryId)
	local assignedHouses = {}
	local houses = self:GetStorageHouses()
	for _, house in pairs(houses) do
		if house.assignedCategoryIds and house.assignedCategoryIds[categoryId] then
			table.insert(assignedHouses, house)
		end
	end
	return assignedHouses
end

function MSorter:GetNumCategoryHouseAssignments(categoryId)
	local assignedHouses = self:GetCategoryHouseAssignments(categoryId)
	return #assignedHouses
end

function MSorter:GetHouseCategoryAssignments(houseId)
	local categories = self:GetFurnitureCategories()
	local assignedCategories = {}
	local house = self:GetStorageHouse(houseId)
	if house and house.assignedCategoryIds then
		for categoryId in pairs(house.assignedCategoryIds) do
			local category = categories[categoryId]
			if category then
				table.insert(assignedCategories, category)
			end
		end
	end
	return assignedCategories
end

function MSorter:GetHouseCategoryAssigmentsString(houseId)
	local list = {}
	local houseCategories = self:GetHouseCategoryAssignments(houseId)
	if houseCategories then
		local categoryIds = {}
		local categories = {}
		ZO_DeepTableCopy(houseCategories, categories)
		table.sort(categories, function(categoryA, categoryB) return categoryA.parentId < categoryB.parentId end)
		for _, category in ipairs(categories) do
			categoryIds[category.id] = true
			if category.parentId == 0 or not categoryIds[category.parentId] then
				table.insert(list, category.displayName)
			end
		end
		table.sort(list)
	end
	return table.concat(list, "\n")
end

function MSorter:AssignCategoryToHouse(houseId, category)
	local house = self:GetStorageHouse(houseId)
	if not house or not category then
		return false
	end
	if not house.assignedCategoryIds then
		house.assignedCategoryIds = {}
	end
	house.assignedCategoryIds[category.id] = true
	local subcategories = self:GetFurnitureSubcategories(category.id)
	for _, subcategory in pairs(subcategories) do
		house.assignedCategoryIds[subcategory.id] = true
	end
	self:OnSettingsChanged()
	return true
end

function MSorter:UnassignCategoryFromHouse(houseId, categoryId)
	local house = self:GetStorageHouse(houseId)
	if not house or not categoryId then
		return false
	end
	if not house.assignedCategoryIds then
		house.assignedCategoryIds = {}
	end
	house.assignedCategoryIds[categoryId] = nil
	local subcategories = self:GetFurnitureSubcategories(categoryId)
	for _, subcategory in pairs(subcategories) do
		house.assignedCategoryIds[subcategory.id] = nil
	end
	self:OnSettingsChanged()
	return true
end

function MSorter:GetInventoryManager()
	return self.inventoryManager
end

function MSorter:GetSortManager()
	return self.sortManager
end

function MSorter:IsAutomaticStorageRunning()
	return self:GetSortManager():IsRunning()
end

function MSorter:StartAutomaticStorage()
	self:GetSortManager():Start()
end

function MSorter:CancelAutomaticStorage()
	self:GetSortManager():Cancel()
end

function MSorter:SuspendAutomaticStorage()
	self:GetSortManager():Suspend()
end

function MSorter:ResumeAutomaticStorage()
	self:GetSortManager():Resume()
end

function MSorter:UpdateKeybindStrip(addKeybinds)
	if addKeybinds then
		KEYBIND_STRIP:AddKeybindButtonGroup(self.KeybindButtons)
	else
		KEYBIND_STRIP:RemoveKeybindButtonGroup(self.KeybindButtons)
	end
end

function MSorter:OnSortManagerStateChanged(eventType, event, eventMessage)
	local sortProgress = MagicSorter_StorageProgress
	local isRunning = self:IsAutomaticStorageRunning()
	sortProgress:SetMessage(eventMessage)
	sortProgress:SetState(isRunning)
	if eventType == "STATE" then
		if event == "COMPLETE" then
			sortProgress:SetComplete(true)
		else
			sortProgress:SetComplete(false)
		end
	end
end

function MSorter:OnDropCategoryTag(control)
	local houseBoxes = MagicSorter_CategoryAssignment.houseBoxes
	local dropTargetControl = self:GetMouseOverControl(houseBoxes)
	if control and control.category and dropTargetControl and dropTargetControl.house then
		self:AssignCategoryToHouse(dropTargetControl.house.houseId, control.category)
		MagicSorter_CategoryAssignment:Refresh()
	end
end

function MSorter:OnPlayerActivated(...)
	self:InitializeKeybinds()
	self:GetSortManager():OnPlayerActivated(...)
	self:ShowCompleteDialog()
end

--[[
function MSorter:AutoConfigure()
	local categoryCounts = {}
	local houses = self:GetOwnedHouses()
	for _, house in ipairs(houses) do
		
	end
end

SLASH_COMMANDS["/automagic"] = function()
	MAGIC_SORTER:AutoConfigure()
end
]]
-- /script MagicSorter_ReportInventory:ShowReport( { { "Conservatory", "Boulders", "125" } } )

SLASH_COMMANDS["/resetmagicsort"] = function()
	MAGIC_SORTER:GetConfig().dirty = false
	d("Quick Sort mode is now ready.")
end
SLASH_COMMANDS["/re"]=ReloadUI