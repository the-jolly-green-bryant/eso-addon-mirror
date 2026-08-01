-----------------------------------------------------------------------------------
-- Addon Name: Rulebased Inventory
-- Creator: TaxTalis
-- Addon Ideal: user-defined rule-based actions for inventory application
-- Addon Creation Date: September 11, 2018
--
-- File Name: Menu.lua
-- File Description: This file contains the addon menu
-- Load Order Requirements: after Loader
--
-----------------------------------------------------------------------------------

local RbI = RulebasedInventory
local ruleEnv = RbI.Import(RbI.ruleEnvironment)
local utils = RbI.Import(RbI.utils)
local evt = RbI.Import(RbI.evt)
local tasks = RbI.Import(RbI.tasks)
RbI.menu = RbI.menu or {}

local rbiMenu = {}

local dividerFullOpaque = {
	type = 'divider',
	height = 10,
	alpha = 0.5,
	width = 'full',
}
local dividerHalfInvisible = {
	type = 'divider',
	height = 10,
	alpha = 0,
	width = 'half',
}

local visibilityQueue = (function()
	local function setYOffset(control, yOffset)
		local anchor = { select(2, control:GetAnchor(0)) }
		anchor[5] = yOffset
		control:ClearAnchors()
		control:SetAnchor(unpack(anchor))
	end
	local function getYOffset(control)
		local anchor = { select(2, control:GetAnchor(0)) }
		return anchor[5]
	end
	local function LAM_SetVisibleIntern(control, value)
		if(value) then
			control:SetHidden(false)
			if(control._yOffset) then
				setYOffset(control, control._yOffset) -- LAMs default offset
			end
		else
			if(not control._yOffset) then control._yOffset = getYOffset(control) end
			control:SetHidden(true)
			setYOffset(control, -control:GetHeight())
		end
	end
	return utils.NewAbstractAsyncQueue(true,
		function(control, visibility) -- doNextFn
			if(visibility == nil) then
				LAM_SetVisibleIntern(control, not control:IsHidden())
			else
				LAM_SetVisibleIntern(control, visibility)
			end
		end,
		nil, -- equalsFn
		nil, -- finishFn
		nil, -- startFn
		function(continueFn) -- waitForNextFn
			zo_callLater(continueFn, 1)
		end
	)
end)()

local function LAM_SetVisible(control, value, instant)
	visibilityQueue.Push(control, value)
	local parent = control:GetParent()
	while(parent ~= nil and parent ~= RBISettingsPanel) do
		if(parent.data) then visibilityQueue.Push(parent) end
		parent = parent:GetParent()
	end
end
local function LAM_ToggleControl(control)
	LAM_SetVisible(control, control:IsHidden())
end
local function LAM_Submenu_SetVisible(control, value)
	control.open = value
	if(value) then
		control.animation:PlayFromStart()
	else
		control.animation:PlayFromEnd()
	end
end
local function LAM_Submenu_MakeHeadless(control)
	LAM_SetVisible(control.label, false)
	LAM_Submenu_SetVisible(control, true)
	LAM_SetVisible(control, false)
end
local function LAM_Button_SetText(control, text)
	control.button:SetText(text)
end
local function LAM_Button_SetIcon(control, uri)
	control.button:SetNormalTexture(uri)
end

local function getSelectedTaskId()
	return RbI.menu.selectedTask
end
local function getSelectedTask(taskId)
	return tasks.GetTask(taskId or getSelectedTaskId())
end
local function OnSelectedTask()
	LAM_SetVisible(RbITaskConfiguration_RevertTask, getSelectedTask().HasRevertTask())
end

local function setSelectedTaskId(taskId)
	RbI.menu.selectedTask = taskId
	RbI.menu.UpdateRuleSetChoices()
	if(RbITaskConfiguration ~= nil) then
		local task = getSelectedTask()
		OnSelectedTask()
	end
end

local function GetLexicographicallyFirst(tbl)
	local result
	for i, v in pairs(tbl) do
		if (result == nil or result > v) then
			result = v
		end
	end
	return result
end

local function getValue(optFn)
	if(type(optFn)=="function") then
		return optFn()
	else
		return optFn
	end
end

-- referenceIds-Array in first place. After "LAM-PanelControlsCreated"-event the real controls will be put in place as referenceId->control map.
local lamControls = {}

-- ensures that every lam-control has a referenceId and will be put into local lamControls
local function createLAMControl(dataTbl)
	local referenceId = dataTbl.reference
	if(referenceId == nil) then referenceId = RbI.name.."LAMControl"..(#lamControls+1) end
	dataTbl.reference = referenceId
	lamControls[#lamControls+1] = referenceId
	if(dataTbl.rbiHelp) then
		dataTbl.helpUrl = dataTbl.rbiHelp
	end
	return dataTbl
end

-- LAM-helpUrls: description[text], dropdown[name], editbox[name], header[name], iconpicker[name], slider[name], submenu[name]
local function submenu(name, referenceId, description)
	local content = createLAMControl({
		type = 'submenu',
		name = name,
		controls = {},
		reference = referenceId,
		rbiHelp = description
	})
	return {
		add = function(entry)
			if (entry.content ~= nil) then entry = entry.content end
			table.insert(content.controls, entry)
		end,
		content = content,
	}
end
local function submenuProfiled(name, referenceId, description)
	description = description and "\n\n"..description
					or ""
	local playerProfileFn = function()
		local result = name..' - '..RbI.GetUnitName('player')
		local profileName = RbI.Profile.GetCurrentProfileName()
		if(profileName ~= nil) then
			result = result.." (Profile: "..tostring(profileName)..")"
		end
		return result
	end
	return submenu(playerProfileFn, referenceId, function() return playerProfileFn()..description.."\n\n(When linked to a profile any change in the profile will also be taken over by the character)" end)
end

local function OnProfileChange()
	for _, lamControl in pairs(lamControls) do
		if(lamControl.data.rbiProfiled) then
			lamControl:UpdateValue()
		end
	end
end

local function OnProfileContentChange()
	RbI.Profile.Save()
end


function RbI.menu.Initialize()
	local LAM2 = LibAddonMenu2

	local waitForPanel = LAM2:RegisterAddonPanel('RBISettingsPanel', {
		type = 'panel',
		name = RbI.title,
		displayName = RbI.title,
		author = RbI.author,
		version = tostring(RbI.addonVersion),
		website = RbI.website,
		slashCommand = '/rbi',
		registerForRefresh = true,
		registerForDefaults = false
	})
	LAM2:RegisterOptionControls('RBISettingsPanel', rbiMenu.createMenues())

	local function ResizeRuleContentEditBox(editBoxCtrl)
		-- minimize to standard
		editBoxCtrl.container:SetHeight(24 * 3)
		-- extend the height of container and parent to the number of not visible lines
		editBoxCtrl.container:SetHeight(editBoxCtrl.container:GetHeight() + (24 * editBoxCtrl.editbox:GetScrollExtents()))
		editBoxCtrl:SetHeight(editBoxCtrl.container:GetHeight())
	end

	local function addEditboxResizer(editBoxCtrl)
		ResizeRuleContentEditBox(editBoxCtrl)
		-- set handler to change size of the rulecontent-editbox on the go (thanks, sirinsidiator!)
		editBoxCtrl.editbox:SetHandler("OnTextChanged", function() ResizeRuleContentEditBox(editBoxCtrl) end, "RuleBasedInventory")
	end

	local function OnLAMControlUpdate(control)
		if(control.data.rbiHelp) then
			control.faqControl.data.tooltipText = getValue(control.data.rbiHelp)
		end
	end

	-- register function to customize the menu on creation
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated",
		function(panel)
			if (panel == waitForPanel) then
				waitForPanel = nil

				local lamReferenceIds = lamControls
				lamControls = {}
				for _, referenceId in pairs(lamReferenceIds) do
					local control = _G[referenceId] -- convert ids into objects
					lamControls[referenceId] = control
					if(control.faqControl) then
						control.faqControl:SetHandler("OnMouseUp", function() end)
					end
					if(control.UpdateValue) then
						local origFn = control.UpdateValue
						control.UpdateValue = function(...)
							local result = origFn(...)
							OnLAMControlUpdate(control)
							return result
						end
					end
					OnLAMControlUpdate(control) -- initial
				end

				addEditboxResizer(lamControls.RbIRuleContent)
				addEditboxResizer(lamControls.RbIConstantContent)

				RbI.menu.UpdateTaskChoices()

				LAM_Submenu_MakeHeadless(lamControls.RbITaskConfiguration)
				LAM_SetVisible(lamControls.RbIRuleSetMenu, RbI.account.settings.usingRuleSets)
				LAM_SetVisible(lamControls.RbIProfilesMenu, RbI.account.settings.usingProfiles)
				LAM_SetVisible(lamControls.RbICurrenciesMenu, RbI.account.settings.usingCurrencies)
			end
		end)
	RbI.menu.Initialize = nil
end

function rbiMenu.createMenues()
	rbiMenu.createFunctions()

	local menu = {}

	-- initialize menu-data
	-- profile
	RbI.menu.selectedProfile = RbI.Profile.GetCurrentProfileName()
	RbI.menu.newProfile = ''

	local contentCreatorClass = RbI.class.Create()
		.addProperty("selected", "", function(self, name)
									 	self:SelectContent(name)
									 end)
		.addProperty("content", "")
		.addProperty("new", "")
		.addProperty("type", "")
		.addProperty("list", "")
		.addFunctions({
			CanCancelSave = function(self)
				return self:getSelected() ~= nil and self:HasChangedContent()
			end,
			Cancel = function(self)
				self:setSelected(self:getSelected())
			end,
			CanAdd = function(self)
				local newName = self:getNew()
				return newName ~= "" and self:LoadContent(newName) == nil
			end,
			CanRename = function(self)
				local newName = self:getNew()
				return newName ~= "" and self:getSelected() ~= nil and
						((self:getSelected():lower() == newName:lower() and self:getSelected() ~= newName
								or self:LoadContent(newName) == nil))
			end,
			UpdateList = function(self, name)
				self:getDropdown():UpdateChoices(self:getList())
				self:setSelected(name or GetLexicographicallyFirst(self:getList()))
				if(self.OnUpdateList) then self:OnUpdateList() end
			end,
			RemoveFromList = function(self, name, doUpdate)
				if(name == nil) then error("No name for RemoveFromList provided!") end
				for i, current in ipairs(self:getList()) do
					if(current == name) then
						table.remove(self:getList(), i)
						break
					end
				end
				if(doUpdate ~= false) then
					self:UpdateList()
				end
			end,
			AddToList = function(self, name)
				if(name == nil) then error("No name for AddToList provided!") end
				table.insert(self:getList(), name)
				self:UpdateList(name)
			end,
			Init = function(self)
				self:setSelected(GetLexicographicallyFirst(self:getList()))
				return self
			end,
			SelectContent = function(self, name)
				if(name ~= nil) then
					self:setContent(self:LoadContent(name))
				else
					self:setContent("")
				end
			end,
			HasChangedContent = function(self)
				return self:getContent() ~= self:LoadContent(self:getSelected())
			end,
		})
	.build()

	-- rule
	local ruleNames = {}
	for name in pairs(RbI.account.rules) do
		table.insert(ruleNames, name)
	end
	RbI.menu.rule = contentCreatorClass.new({
		DoNew = function(self)
			local name = self:getNew()
			ruleEnv.CreateUserRule(name)
			self:AddToList(name)
			self:setNew("")
		end,
		DoRename = function(self)
			local newName = self:getNew()
			local oldName = self:getSelected()
			RbI.RenameRule(oldName, newName)
			self:RemoveFromList(oldName, false)
			self:AddToList(newName)
			self:setNew("")
		end,
		DoTest = function(self)
			ruleEnv.Test(self:getSelected(), self:getContent())
		end,
		getDropdown = function(self)
			return lamControls.RbIRuleDropdown
		end,
		OnUpdateList = function()
			RbI.menu.UpdateRuleSetRules()
		end,
		DoDelete = function(self)
			local name = self:getSelected()
			RbI.rules.user[name:lower()].Delete()
			self:RemoveFromList(name)
		end,
		DoSave = function(self, name)
			name = (name or self:getSelected()):lower()
			RbI.rules.user[name].SetContent(self:getContent())
		end,
		LoadContent = function(self, name)
			name = (name or self:getSelected()):lower()
			local rule = RbI.rules.user[name]
			if(rule == nil) then return nil end
			return rule.GetContent()
		end,
	}):setList(ruleNames):Init()

	-- constant
	local constantNames = {}
	for name in pairs(RbI.account.constants) do
		table.insert(constantNames, name)
	end
	RbI.menu.constant = contentCreatorClass.new({
		DoNew = function(self)
			local name = self:getNew()
			RbI.account.constants[name] = {
				content = ""
			}
			RbI.constants[name:lower()] = RbI.precompileConstant(name, "")
			self:AddToList(name)
			self:setNew("")
		end,
		DoRename = function(self)
			local newName = self:getNew()
			local oldName = self:getSelected()
			RbI.account.constants[newName] = RbI.account.constants[oldName]
			RbI.account.constants[oldName] = nil
			RbI.constants[newName:lower()] = RbI.precompileConstant(newName, self:getContent())
			RbI.constants[oldName:lower()] = nil
			self:RemoveFromList(oldName, false)
			self:AddToList(newName)
			self:setNew("")
		end,
		DoTest = function(self)
			local result, err = RbI.precompileConstant(self:getSelected(), self:getContent())
			if(err) then
				return RbI.ConstantErrorHandler(err)
			elseif(#result == 0) then
				return RbI.ConstantErrorHandler("No valid values or everything is nil. Use quotes for strings.")
			else
				for i = 1, #result do
					local value = result[i]
					if(value == nil) then
						return RbI.ConstantErrorHandler("There is a nil value in argument #"..i)
					end
				end
			end
			if(self:getType() == "CharacterNames") then
				local dataType = RbI.dataTypeStatic["charName"]
				for i = 1, #result do
					local value = result[i]
					if(type(value) ~= "string" or not dataType[value:lower()]) then
						local err = {
							message = "CharacterName"..': \'' .. tostring(value) .. '\' is not recognized.',
							ruleContent = self:getContent(),
							addition = 'Valid values are:\n' .. RbI.utils.ArrayKeysToString(dataType),
						}
						return RbI.ConstantErrorHandler(err)
					end
				end
			end
			RbI.out.msg("Constant was successfuly verified!")
		end,
		getDropdown = function(self)
			return lamControls.RbIConstantDropdown
		end,
		getTypeList = function()
			return {"Unspecified", "CharacterNames"}
		end,
		OnUpdateList = function()
		end,
		DoDelete = function(self)
			local name = self:getSelected()
			RbI.account.constants[name] = nil
			RbI.constants[name:lower()] = nil
			self:RemoveFromList(name)
		end,
		DoSave = function(self, name)
			local content = self:getContent()
			name = name or self:getSelected()
			RbI.account.constants[name].content = content
			RbI.constants[name:lower()] = RbI.precompileConstant(name, content)
		end,
		LoadContent = function(self, name)
			name = name or self:getSelected()
			local result = RbI.account.constants[name]
			if(result == nil) then return result end
			return result.content
		end,
	}):setList(constantNames):setType("Unspecified"):Init()


	-- task
	RbI.menu.selectedTask = GetLexicographicallyFirst(tasks.list)

	-- ruleSet
	RbI.menu.ruleSetList = RbI.RuleSet.GetList()
	RbI.menu.selectedRuleSet = RbI.RuleSet.GetCurrentRuleSetName(RbI.menu.selectedTask)
	RbI.menu.newRuleSet = ''
	RbI.menu.currentAllRules = RbI.RuleSet.GetRules(RbI.menu.selectedTask, RbI.FIT_ALL)
	RbI.menu.currentAnyRules = RbI.RuleSet.GetRules(RbI.menu.selectedTask, RbI.FIT_ANY)
	RbI.menu.availableAllRules = RbI.RuleSet.GetAvailableRules(RbI.menu.selectedTask, RbI.FIT_ALL)
	RbI.menu.availableAnyRules = RbI.RuleSet.GetAvailableRules(RbI.menu.selectedTask, RbI.FIT_ANY)

	table.insert(menu, rbiMenu.createProfiles())
	table.insert(menu, rbiMenu.createTasks())
	table.insert(menu, rbiMenu.createRules())
	table.insert(menu, rbiMenu.createConstants())
	table.insert(menu, rbiMenu.createCurrencies())
	table.insert(menu, rbiMenu.createSettings())

	if (RbI.class.DataDumper ~= nil) then -- only for test-environment
		for _, pair in pairs(RbI.class.DataDumper) do
			table.insert(menu, {
				type = 'button',
				name = pair[1],
				func = pair[2],
				width = 'half',
			})
		end
		table.insert(menu, {
			type = 'description',
			text = function() return "File load time: " .. (RbI.fileLoadTime / 1000) .. " secs" end,
			width = 'full',
		})
	end

	return menu
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Extern functions ----------------------------------------------------------------------
------------------------------------------------------------------------------
function rbiMenu.createFunctions()
	-- functions to update dropdowns

	-- profile
	function RbI.menu.UpdateProfileChoices()
		lamControls.RbIProfileDropdown:UpdateChoices(RbI.Profile.GetList())
	end

	function RbI.menu.SetSelectedProfile()
		RbI.menu.selectedProfile = RbI.Profile.GetCurrentProfileName()
	end

	-- ruleSet
	function RbI.menu.UpdateRuleSetRules(currentAllRule, availableAllRule, currentAnyRule, availableAnyRule)
		lamControls.RbIRuleSetAllCurrentRuleDropdown:UpdateChoices(RbI.RuleSet.GetRules(RbI.menu.selectedTask, RbI.FIT_ALL))
		lamControls.RbIRuleSetAllAvailableRuleDropdown:UpdateChoices(RbI.RuleSet.GetAvailableRules(RbI.menu.selectedTask, RbI.FIT_ALL))
		lamControls.RbIRuleSetAnyCurrentRuleDropdown:UpdateChoices(RbI.RuleSet.GetRules(RbI.menu.selectedTask, RbI.FIT_ANY))
		lamControls.RbIRuleSetAnyAvailableRuleDropdown:UpdateChoices(RbI.RuleSet.GetAvailableRules(RbI.menu.selectedTask, RbI.FIT_ANY))
		RbI.menu.ruleSetCurrentAllRule = currentAllRule
		RbI.menu.ruleSetAvailableAllRule = availableAllRule
		RbI.menu.ruleSetCurrentAnyRule = currentAnyRule
		RbI.menu.ruleSetAvailableAnyRule = availableAnyRule
	end

	function RbI.menu.UpdateRuleSetChoices(currentAllRule, availableAllRule, currentAnyRule, availableAnyRule)
		if (lamControls.RbIRuleSetDropdown ~= nil) then
			lamControls.RbIRuleSetDropdown:UpdateChoices(RbI.RuleSet.GetList())
		end
		RbI.menu.SetSelectedProfile()
		RbI.menu.selectedRuleSet = RbI.RuleSet.GetCurrentRuleSetName(RbI.menu.selectedTask)
		RbI.menu.UpdateRuleSetRules(currentAllRule, availableAllRule, currentAnyRule, availableAnyRule)
	end

	function RbI.menu.UpdateTaskChoices()
		local tooltips = {}
		local displayNames = {}
		for _, taskId in pairs(tasks.list) do
			local task = tasks.GetTask(taskId)
			tooltips[#tooltips + 1] = task.GetDescription()
			displayNames[#displayNames + 1] = task.GetDisplayName()
		end
		lamControls.RbITaskDropdown:UpdateChoices(displayNames, tasks.list, tooltips)
		lamControls.RbITaskDropdown.dropdown:SetSelectedItem(RbI.menu.selectedTask)
	end

end


------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- PROFILE -------------------------------------------------------------------
------------------------------------------------------------------------------
function rbiMenu.createProfiles()
	local profilesMenu = createLAMControl({
		type = 'submenu',
		name = 'Profiles',
		controls = {},
		description = "Within a profile all task->rule assignments can be saved and loaded.",
		reference = "RbIProfilesMenu"
	})

	-- Dropdown
	table.insert(profilesMenu.controls, createLAMControl({
		type = 'dropdown',
		choices = RbI.Profile.GetList(),
		getFunc = function() return RbI.menu.selectedProfile end,
		setFunc = function(profileName) RbI.menu.selectedProfile = profileName end,
		width = 'half',
		reference = 'RbIProfileDropdown',
		disabled = function() return #RbI.Profile.GetList() == 0 end,
		scrollable = true,
		sort = 'name-up',
	}))

	-- Delete
	table.insert(profilesMenu.controls, {
		type = 'button',
		name = 'Delete',
		func = function()
			RbI.Profile.Delete(RbI.menu.selectedProfile)
			RbI.menu.UpdateProfileChoices()
			RbI.menu.selectedProfile = nil
		end,
		width = 'half',
		disabled = function() return RbI.menu.selectedProfile == nil end,
		isDangerous = true,
		warning = 'Deleting a profile cannot be undone. Continue?',
	})

	-- Load
	table.insert(profilesMenu.controls, {
		type = 'button',
		name = 'Load',
		func = function()
			RbI.Profile.Load(RbI.menu.selectedProfile)
			RbI.menu.UpdateRuleSetChoices()
			OnProfileChange()
		end,
		width = 'half',
		disabled = function() return RbI.menu.selectedProfile == RbI.Profile.GetCurrentProfileName() end,
		isDangerous = true,
		warning = 'Loadig a profile will overwrite the current settings! This cannot be undone. Continue?',
	})

	-- Save
	table.insert(profilesMenu.controls, {
		type = 'button',
		name = 'Save',
		func = function() RbI.Profile.Save(RbI.menu.selectedProfile) end,
		width = 'half',
		disabled = function() return RbI.menu.selectedProfile==nil or (RbI.menu.selectedProfile == RbI.Profile.GetCurrentProfileName() and RbI.Profile.IsLikeCurrent(RbI.menu.selectedProfile)) end,
		isDangerous = true,
		warning = 'Selected profile will be overwritten with current settings. Continue?',
	})

	-- New
	table.insert(profilesMenu.controls, dividerFullOpaque)

	table.insert(profilesMenu.controls, {
		type = 'editbox',
		getFunc = function() return '' end,
		setFunc = function(profileName) RbI.menu.newProfile = profileName end,
		isMultiline = false,
		isExtraWide = false,
		maxChars = 100,
		width = 'half',
	})

	table.insert(profilesMenu.controls, {
		type = 'button',
		name = 'New',
		func = function()
			RbI.Profile.Save(RbI.menu.newProfile)
			RbI.menu.UpdateProfileChoices()
			RbI.menu.selectedProfile = RbI.menu.newProfile
			RbI.menu.newProfile = ''
		end,
		width = 'half',
		disabled = function() return RbI.menu.newProfile == '' or RbI.Profile.Exists(RbI.menu.newProfile) end,
		description = 'The current task->rule assignments will be directly saved into the new profile!',
	})

	return profilesMenu
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- TASK ----------------------------------------------------------------------
------------------------------------------------------------------------------
function rbiMenu.createTasks()
	local tasksMenu = submenuProfiled('Tasks')

	-- Dropdown
	tasksMenu.add(createLAMControl({
		type = 'dropdown',
		choices = tasks.list,
		getFunc = function() return RbI.menu.selectedTask end,
		setFunc = function(taskName) setSelectedTaskId(taskName) end,
		width = 'half',
		scrollable = 13,
		-- tooltip = function() return tasks.GetSelectedTask().GetDescription() end, -- currently doesn't work with LibAddonMenu
		reference = 'RbITaskDropdown',
		sort = 'name-up',
	}))

	-- Run Task
	tasksMenu.add(createLAMControl({
		type = 'button',
		name = 'Run',
		func = function()
            local task = getSelectedTask()
			tasks.Start(task)
            if (task.RunWithRevertTask()) then
				tasks.Start(task.GetOpposingTask())
            end
		end,
		width = 'half',
		disabled = function() return not RbI.RuleSet.HasRules(getSelectedTaskId()) or RbI.ActionQueue.IsRunning() or RbI.testrun or not getSelectedTask().GetDefaultAllowAction() end,
		reference = 'RbITaskRunButton',
	}))

	tasksMenu.add(createLAMControl({
		type = 'button',
		name = 'Configure',
		icon = "EsoUI\\Art\\Miscellaneous\\list_sortdown.dds",
		func = function()
			LAM_ToggleControl(lamControls.RbITaskConfiguration)
			if(lamControls.RbITaskConfiguration:IsHidden()) then
				LAM_Button_SetIcon(lamControls.RbITaskConfigurationButton, "EsoUI\\Art\\Miscellaneous\\list_sortdown.dds")
			else
				LAM_Button_SetIcon(lamControls.RbITaskConfigurationButton, "EsoUI\\Art\\Miscellaneous\\list_sortup.dds")
			end
		end,
		width = 'half',
		reference = 'RbITaskConfigurationButton'
	}))

	-- Test Task
	tasksMenu.add(createLAMControl({
		type = 'button',
		name = 'Test',
		func = function()
			tasks.Test(getSelectedTaskId())
		end,
		width = 'half',
		disabled = function() return RbI.ActionQueue.IsRunning() or RbI.testrun or (RbI.RuleSet.HasRules(RbI.menu.selectedTask) == false) end,
		tooltip = 'Checks which items would be used by this task. The task works on its standard bag.',
		reference = 'RbITaskTestButton',
	}))

	local configureMenu = submenu('Configure Task', 'RbITaskConfiguration')
	tasksMenu.add(configureMenu)

	-- Delete All Rules
	configureMenu.add({
		type = 'button',
		name = 'Remove Rule(s)',
		func = function()
			RbI.RuleSet.RemoveAllRules(RbI.menu.selectedTask)
			RbI.menu.UpdateRuleSetChoices()
		end,
		width = 'half',
		tooltip = 'Removes all assigned rules from this task. So this will deactivating the task.',
		disabled = function() return RbI.RuleSet.HasRules(RbI.menu.selectedTask) == false end,
		isDangerous = true,
		warning = 'All rule-assignments will be removed from the task!',
	})

	configureMenu.add({ type = "header", name = "Settings", width = "full" })

	configureMenu.add(createLAMControl({
		type = 'checkbox',
 		name = 'Full consistency mode - with opposite task',
		tooltip = 'Also executes the opposite task to unjunk/unmark items. When set to \'true\' RbI controls fully this state so you can not manually junk/mark items yourself, because the opposite task will always revert it.\n\nThis is a global setting, so this sets the behaviour for all your characters.',
		getFunc = function() return getSelectedTask().RunWithRevertTask() end,
		setFunc = function(value)
			local task = getSelectedTask()
			local taskId = task.GetId()
			local taskSettings = RbI.account.tasks[taskId]
			if (value) then
				if (not taskSettings) then
					taskSettings = {}
					RbI.account.tasks[taskId] = taskSettings
				end
				taskSettings.runWithRevertTask = true
			else
				taskSettings.runWithRevertTask = nil
			end
		end,
		width = 'full',
		reference = 'RbITaskConfiguration_RevertTask'
	}))


	------------------------------------------------------------------------------
	-- RULES-SET -----------------------------------------------------------------
	------------------------------------------------------------------------------

	local subtasksMenu = submenu('Ruleset - Save/Load rule assignments', 'RbIRuleSetMenu', 'Within a ruleset the current task->rule assignments can be saved and loaded.')

	-- Dropdown
	subtasksMenu.add(createLAMControl({
		type = 'dropdown',
		choices = RbI.RuleSet.GetList(),
		getFunc = function() return RbI.menu.selectedRuleSet end,
		setFunc = function(ruleSetName) RbI.menu.selectedRuleSet = ruleSetName end,
		width = 'half',
		reference = 'RbIRuleSetDropdown',
		sort = 'name-up',
		scrollable = true,
		disabled = function() return #RbI.RuleSet.GetList() == 0 end,
	}))

	-- Load
	subtasksMenu.add({
		type = 'button',
		name = 'Load',
		func = function() RbI.RuleSet.Load(RbI.menu.selectedTask, RbI.menu.selectedRuleSet)
			RbI.menu.UpdateRuleSetChoices()
		end,
		width = 'half',
		disabled = function() return RbI.menu.selectedRuleSet == nil
				or RbI.menu.selectedRuleSet == RbI.RuleSet.GetCurrentRuleSetName(RbI.menu.selectedTask)
		end,
		isDangerous = true,
		warning = 'Loadig a ruleset will overwrite the current task settings! This cannot be undone. Continue?',
	})

	-- Delete
	subtasksMenu.add({
		type = 'button',
		name = 'Delete',
		func = function() RbI.RuleSet.Delete(RbI.menu.selectedRuleSet)
			RbI.menu.UpdateRuleSetChoices()
		end,
		width = 'half',
		disabled = function() return RbI.menu.selectedRuleSet == nil end,
		isDangerous = true,
		warning = 'Deleting a ruleSet cannot be undone! Continue?',
	})

	-- Save
	subtasksMenu.add({
		type = 'button',
		name = 'Save',
		func = function() RbI.RuleSet.Save(RbI.menu.selectedTask, RbI.menu.selectedRuleSet)
			RbI.menu.UpdateRuleSetChoices()
		end,
		width = 'half',
		disabled = function() return RbI.RuleSet.IsLikeCurrent(RbI.menu.selectedTask, RbI.menu.selectedRuleSet) end,
		isDangerous = true,
		warning = 'Selected ruleSet will be overwritten with current rules. Continue?',
	})

	-- New
	subtasksMenu.add(dividerFullOpaque)
	subtasksMenu.add({
		type = 'editbox',
		getFunc = function() return '' end,
		setFunc = function(ruleSetName) RbI.menu.newRuleSet = ruleSetName end,
		isMultiline = false,
		isExtraWide = false,
		maxChars = 100,
		width = 'half',
	})

	subtasksMenu.add({
		type = 'button',
		name = 'New',
		func = function() RbI.RuleSet.Save(RbI.menu.selectedTask, RbI.menu.newRuleSet)
			RbI.menu.UpdateRuleSetChoices()
			RbI.menu.selectedRuleSet = RbI.menu.newRuleSet
			RbI.menu.newRuleSet = ''
		end,
		width = 'half',
		disabled = function() return RbI.menu.newRuleSet == ''
				or RbI.RuleSet.Exists(RbI.menu.newRuleSet)
		end,
		description = 'The current task->rule assignments will be directly saved into the new ruleset!',
	})
	configureMenu.add(subtasksMenu)

	-- Rule Selection
	local subtasksMenu = submenu('Item has to fit all of these rules')

	-- current rules dropdown
	subtasksMenu.add(createLAMControl({
		name = 'Current Rules',
		type = 'dropdown',
		choices = RbI.RuleSet.GetRules(RbI.menu.selectedTask, 1),
		getFunc = function() return RbI.menu.ruleSetCurrentAllRule end,
		setFunc = function(ruleName) RbI.menu.ruleSetCurrentAllRule = ruleName end,
		width = 'half',
		disabled = function() return #RbI.RuleSet.GetRules(RbI.menu.selectedTask, RbI.FIT_ALL) == 0 end,
		sort = 'name-up',
		scrollable = true,
		reference = 'RbIRuleSetAllCurrentRuleDropdown',
	}))

	-- delete rule from ruleSet
	subtasksMenu.add({
		type = 'button',
		name = 'Delete',
		func = function() RbI.RuleSet.RemoveRule(RbI.menu.selectedTask, RbI.menu.ruleSetCurrentAllRule)
			RbI.menu.UpdateRuleSetChoices(nil, RbI.menu.ruleSetCurrentAllRule)
		end,
		width = 'half',
		disabled = function() return RbI.menu.ruleSetCurrentAllRule == nil end,
	})

	-- add rules dropdown
	subtasksMenu.add(createLAMControl({
		type = 'dropdown',
		name = 'Available Rules',
		choices = RbI.RuleSet.GetAvailableRules(RbI.menu.selectedTask, RbI.FIT_ALL),
		getFunc = function() return RbI.menu.ruleSetAvailableAllRule end,
		setFunc = function(ruleName) RbI.menu.ruleSetAvailableAllRule = ruleName end,
		width = 'half',
		disabled = function() return #RbI.RuleSet.GetAvailableRules(RbI.menu.selectedTask, RbI.FIT_ALL) == 0 end,
		sort = 'name-up',
		scrollable = true,
		reference = 'RbIRuleSetAllAvailableRuleDropdown',
	}))

	-- add rule to ruleSet
	subtasksMenu.add({
		type = 'button',
		name = 'Add',
		func = function()
			RbI.RuleSet.AddRule(RbI.menu.selectedTask, RbI.menu.ruleSetAvailableAllRule, RbI.FIT_ALL)
			RbI.menu.UpdateRuleSetChoices(RbI.menu.ruleSetAvailableAllRule)
		end,
		width = 'half',
		disabled = function() return RbI.menu.ruleSetAvailableAllRule == nil end,
	})
	tasksMenu.add(subtasksMenu)


	local subtasksMenu = submenu('Item has to fit any of these rules')

	-- current rules dropdown
	subtasksMenu.add(createLAMControl({
		name = 'Current Rules',
		type = 'dropdown',
		choices = RbI.RuleSet.GetRules(RbI.menu.selectedTask, RbI.FIT_ANY),
		getFunc = function() return RbI.menu.ruleSetCurrentAnyRule end,
		setFunc = function(ruleName) RbI.menu.ruleSetCurrentAnyRule = ruleName end,
		width = 'half',
		disabled = function() return #RbI.RuleSet.GetRules(RbI.menu.selectedTask, RbI.FIT_ANY) == 0 end,
		sort = 'name-up',
		scrollable = true,
		reference = 'RbIRuleSetAnyCurrentRuleDropdown',
	}))

	-- delete rule from ruleSet
	subtasksMenu.add({
		type = 'button',
		name = 'Delete',
		func = function() RbI.RuleSet.RemoveRule(RbI.menu.selectedTask, RbI.menu.ruleSetCurrentAnyRule)
			RbI.menu.UpdateRuleSetChoices(nil, nil, nil, RbI.menu.ruleSetCurrentAnyRule)
		end,
		width = 'half',
		disabled = function() return RbI.menu.ruleSetCurrentAnyRule == nil end,
	})

	-- add rules dropdown
	subtasksMenu.add(createLAMControl({
		type = 'dropdown',
		name = 'Available Rules',
		choices = RbI.RuleSet.GetAvailableRules(RbI.menu.selectedTask, RbI.FIT_ANY),
		getFunc = function() return RbI.menu.ruleSetAvailableAnyRule end,
		setFunc = function(ruleName) RbI.menu.ruleSetAvailableAnyRule = ruleName end,
		width = 'half',
		disabled = function() return #RbI.RuleSet.GetAvailableRules(RbI.menu.selectedTask, RbI.FIT_ANY) == 0 end,
		sort = 'name-up',
		scrollable = true,
		reference = 'RbIRuleSetAnyAvailableRuleDropdown',
	}))

	-- add rule to ruleSet
	subtasksMenu.add({
		type = 'button',
		name = 'Add',
		func = function()
			RbI.RuleSet.AddRule(RbI.menu.selectedTask, RbI.menu.ruleSetAvailableAnyRule, RbI.FIT_ANY)
			RbI.menu.UpdateRuleSetChoices(nil, nil, RbI.menu.ruleSetAvailableAnyRule)
		end,
		width = 'half',
		disabled = function() return RbI.menu.ruleSetAvailableAnyRule == nil end,
	})
	tasksMenu.add(subtasksMenu)

	return tasksMenu.content
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- RULES ---------------------------------------------------------------------
------------------------------------------------------------------------------
function rbiMenu.createRules()
	local ctrler = RbI.menu.rule
	local rulesMenu = submenu('Rules')

	-- Dropdown
	rulesMenu.add(createLAMControl({
		type = 'dropdown',
		choices = ctrler:getList(),
		getFunc = function() return ctrler:getSelected() end,
		setFunc = function(ruleName) ctrler:setSelected(ruleName) end,
		width = 'half',
		reference = 'RbIRuleDropdown',
		scrollable = true,
		sort = 'name-up',
	}))

	-- Delete
	rulesMenu.add({
		type = 'button',
		name = 'Delete',
		func = function() ctrler:DoDelete() end,
		width = 'half',
		disabled = function() return ctrler:getSelected() == nil end,
		isDangerous = true,
		warning = 'Deleting a rule cannot be undone!',
	})

	-- Content
	rulesMenu.add(createLAMControl({
		type = 'editbox',
		getFunc = function() return ctrler:getContent() end,
		setFunc = function(content) ctrler:setContent(content) end,
		isMultiline = true,
		isExtraWide = true,
		maxChars = 2000, -- saveVariables can not save strings larger than 2000
		disabled = function() return ctrler:getSelected() == nil end,
		width = 'full',
		reference = 'RbIRuleContent',
	}))

	-- Cancel
	rulesMenu.add({
		type = 'button',
		name = 'Cancel',
		func = function() ctrler:Cancel() end,
		width = 'half',
		disabled = function() return not ctrler:CanCancelSave() end,
	})

	-- Save
	rulesMenu.add({
		type = 'button',
		name = 'Save',
		func = function() ctrler:DoSave() end,
		width = 'half',
		disabled = function() return not ctrler:CanCancelSave() end,
	})

	-- empty space
	rulesMenu.add(dividerHalfInvisible)

	-- Test Rule
	rulesMenu.add({
		type = 'button',
		name = 'Test',
		func = function() ctrler:DoTest() end,
		width = 'half',
		disabled = function() return ctrler:getSelected() == nil end,
		tooltip = 'Checks which items you have selected with this rule. Items from backpack, bank and craftbag will be checked.',
	})

	-- New
	rulesMenu.add(dividerFullOpaque)
	rulesMenu.add({
		type = 'editbox',
		getFunc = function() return '' end,
		setFunc = function(ruleName) ctrler:setNew(ruleName) end,
		isMultiline = false,
		isExtraWide = false,
		maxChars = 100,
		width = 'half',
	})

	rulesMenu.add({
		type = 'button',
		name = 'New',
		func = function() ctrler:DoNew() end,
		width = 'half',
		disabled = function() return not ctrler:CanAdd() end,
	})

	-- empty space
	rulesMenu.add(dividerHalfInvisible)

	rulesMenu.add({
		type = 'button',
		name = 'Rename',
		func = function() ctrler:DoRename() end,
		width = 'half',
		disabled = function() return not ctrler:CanRename() end,
	})

	return rulesMenu.content
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- CONSTANTS -----------------------------------------------------------------
------------------------------------------------------------------------------
function rbiMenu.createConstants()
	local ctrler = RbI.menu.constant
	local constantsMenu = submenu('Constants')

	-- Constant-Dropdown
	constantsMenu.add(createLAMControl({
		type = 'dropdown',
		choices = ctrler:getList(),
		getFunc = function() return ctrler:getSelected() end,
		setFunc = function(ruleName) ctrler:setSelected(ruleName) end,
		width = 'half',
		reference = 'RbIConstantDropdown',
		scrollable = true,
		sort = 'name-up',
	}))

	-- Constant-Delete
	constantsMenu.add({
		type = 'button',
		name = 'Delete',
		func = function() ctrler:DoDelete() end,
		width = 'half',
		disabled = function() return ctrler:getSelected() == nil end,
		isDangerous = true,
		warning = 'Deleting a constant cannot be undone!',
	})

	-- Constant-Content
	constantsMenu.add(createLAMControl({
		type = 'editbox',
		getFunc = function() return ctrler:getContent() end,
		setFunc = function(content) ctrler:setContent(content) end,
		isMultiline = true,
		isExtraWide = true,
		maxChars = 2000, -- saveVariables can not save strings larger than 2000
		disabled = function() return ctrler:getSelected() == nil end,
		width = 'full',
		reference = 'RbIConstantContent',
	}))

	-- Constant-Cancel
	constantsMenu.add({
		type = 'button',
		name = 'Cancel',
		func = function() ctrler:Cancel() end,
		width = 'half',
		disabled = function() return not ctrler:CanCancelSave() end,
	})

	-- Constant-Save
	constantsMenu.add({
		type = 'button',
		name = 'Save',
		func = function() ctrler:DoSave() end,
		width = 'half',
		disabled = function() return not ctrler:CanCancelSave() end,
	})

	-- Constant-Type
	constantsMenu.add({
		type = 'dropdown',
		choices = ctrler:getTypeList(),
		getFunc = function() return ctrler:getType() end,
		setFunc = function(value) ctrler:setType(value) end,
		width = 'half',
		scrollable = true,
		sort = 'name-up',
	})

	-- Constant-Test
	constantsMenu.add({
		type = 'button',
		name = 'Test',
		func = function() ctrler:DoTest() end,
		width = 'half',
		disabled = function() return ctrler:getSelected() == nil end,
		tooltip = 'Checks if the constant has a correct syntax.',
	})

	-- Constant-New/Rename-Name
	constantsMenu.add(dividerFullOpaque)
	constantsMenu.add({
		type = 'editbox',
		getFunc = function() return '' end,
		setFunc = function(ruleName) ctrler:setNew(ruleName) end,
		isMultiline = false,
		isExtraWide = false,
		maxChars = 100,
		width = 'half',
	})

	-- Constant-New
	constantsMenu.add({
		type = 'button',
		name = 'New',
		func = function() ctrler:DoNew() end,
		width = 'half',
		disabled = function() return not ctrler:CanAdd() end,
	})

	-- empty space
	constantsMenu.add(dividerHalfInvisible)

	-- Constant-Rename
	constantsMenu.add({
		type = 'button',
		name = 'Rename',
		func = function() ctrler:DoRename() end,
		width = 'half',
		disabled = function() return not ctrler:CanRename() end,
	})

	return constantsMenu.content
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Currencies ----------------------------------------------------------------
------------------------------------------------------------------------------
function rbiMenu.createCurrencies()
	local currenciesMenu = submenu('Currencies', 'RbICurrenciesMenu', "Transfer between backpack and bank. Just select the bag and fill in the amount, you want to hold in that bag. The rest of the currency will be transferred. Fill in '0' if you want to transfer all. Fill in '' if you don't want to use it.")

	local function currencySettings()
		return RbI.character.currencies
	end
	local currencyOrder = { "gold", "ap", "telvar", "vouchers" }
	local currencyNames = {
		gold = "Gold",
		ap = "Alliance Points",
		telvar = "Tel Var Stones",
		vouchers = "Writ Vouchers",
	}

	for _, currencyType in pairs(currencyOrder) do
		--currenciesMenu.add({ type = "description", text = currencyNames[currencyType], width = "full", })
		currenciesMenu.add({ type = "header", name = currencyNames[currencyType], width = "full" })
		currenciesMenu.add(createLAMControl({
			type = 'dropdown',
			name = 'Bag',
			choices = { 'Backpack', 'Bank' },
			choicesValues = {1, 2},
			getFunc = function() return currencySettings()[currencyType].bag end,
			setFunc = function(bag)
				currencySettings()[currencyType].bag = bag
			end,
			width = 'full',
			rbiProfiled = true,
		}))

		currenciesMenu.add(createLAMControl({
			type = 'editbox',
			name = 'Amount',
			getFunc = function() return currencySettings()[currencyType].holdMin end,
			setFunc = function(value)
				value = tonumber(value)
				currencySettings()[currencyType].holdMin = value
				currencySettings()[currencyType].holdMax = value
			end,
			textType = TEXT_TYPE_NUMERIC,
			width = 'full',
			rbiProfiled = true,
		}))
	end

	return currenciesMenu.content
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- SETTINGS ------------------------------------------------------------------
------------------------------------------------------------------------------
function rbiMenu.createSettings()
	local settings = submenu('Settings')
	--------- Settings:Additionals/Features -------------------------------------------------------------
	-- table.insert(settingsMenu.controls, { type = "header", name = "Additionals", width = "full", })

	-- Item Inspector
	settings.add({
		type = 'checkbox',
		name = 'Item Inspector Context Menu',
		tooltip = 'Adds an entry to the context menu (\'' .. RbI.CONTEXT_MENU_ENTRY .. '\') in inventory with which main item data used by RbI can be printed out. Needs LibCustomMenu addon!!!',
		getFunc = function() return (AddCustomMenuItem ~= nil) and RbI.account.settings.contextMenu end,
		setFunc = function(value) RbI.account.settings.contextMenu = value end,
		disabled = function() return (AddCustomMenuItem == nil) end,
		width = 'full',
		requiresReload = true,
	})

	-- Initial item-check
	settings.add({
		type = 'checkbox',
		name = 'Initial item-check', -- consistency check
		tooltip = 'After login all backpack items will be check for following tasks: FCOISMark (+FCOISUnmark), Junk (+UnJunk), Destroy, Use',
		getFunc = function() return RbI.account.settings.startupitemcheck end,
		setFunc = function(value) RbI.account.settings.startupitemcheck = value end,
		width = 'full',
	})

	-- case-sensitivity
	settings.add({
		type = 'checkbox',
		name = 'Rule case-sensitivity/Custom user-functions',
		tooltip = 'The default is \'false\', with lowercasing a rule completely before executing, prevent potential syntax errors. With this option this can be deactivated. So the case for function calls and operators won\'t be ignored for rule definition anymore. This has to be used to create custom user functions to call ESO-Api functions.',
		getFunc = function() return RbI.account.settings.casesensitiverules end,
		setFunc = function(value)
			RbI.account.settings.casesensitiverules = value
			RbI.precompileAll()
		end,
		width = 'full',
	})

	-- Using Profiles
	settings.add({
		type = 'checkbox',
		name = 'Using Profiles',
		tooltip = 'Within a profile all task->rule assignments can be saved and loaded.',
		getFunc = function() return RbI.account.settings.usingProfiles end,
		setFunc = function(value)
			RbI.account.settings.usingProfiles = value
			LAM_SetVisible(lamControls.RbIProfilesMenu, value)
		end,
		width = 'full',
	})

	-- Using Rulesets
	settings.add({
		type = 'checkbox',
		name = 'Using Rulesets',
		tooltip = 'Within a ruleset the current task->rule assignments can be saved and loaded.',
		getFunc = function() return RbI.account.settings.usingRuleSets end,
		setFunc = function(value)
			RbI.account.settings.usingRuleSets = value
			LAM_SetVisible(lamControls.RbIRuleSetMenu, value)
		end,
		width = 'full',
	})

	-- Using Currencies
	settings.add({
		type = 'checkbox',
		name = 'Using Currencies',
		tooltip = 'With this feature you can auto-transfer currencies from/to a bank/backpack.',
		getFunc = function() return RbI.account.settings.usingCurrencies end,
		setFunc = function(value)
			RbI.account.settings.usingCurrencies = value
			LAM_SetVisible(lamControls.RbICurrenciesMenu, value)
		end,
		width = 'full',
	})

	-- prevent auto open key
	settings.add({
		type = 'dropdown',
		name = 'Homebanking mode',
		tooltip = 'To activate homebanking target or tasks\n'..
					'\nTarget Mode: you have to specify the target bank via targetBank()-function. BankToBag/BagToBank tasks will be used for all banks.'..
					'\nTask Mode: for all banks a new task-pair HomebankXToBag/BagToHomebankX will be added',
		scrollable = true,
		choices = { "Off", "Target Mode", "Task Mode"},
		getFunc = function() return RbI.account.settings.homebankingMode end,
		setFunc = function(value)
			RbI.account.settings.homebankingMode = value
			tasks.CheckHomebankTasks()
			setSelectedTaskId(GetLexicographicallyFirst(tasks.list))
			RbI.menu.UpdateTaskChoices()
		end,
		width = 'full',
		-- requiresReload = true, -- only needed for taskMode<->other
	})

	-- Using Currencies
	settings.add({
		type = 'checkbox',
		name = 'Identify homebank #',
		tooltip = 'This will just write the homebank number in the chat, when visiting a homebank.',
		getFunc = function() return RbI.account.settings.identifyHomebank end,
		setFunc = function(value) RbI.account.settings.identifyHomebank = value end,
		width = 'full',
	})

	--------- Settings:Safety -------------------------------------------------------------
	settings.add({ type = "header", name = "Safety", width = "full", })

	-- saferule
	settings.add({
		type = 'checkbox',
		name = 'Use internal Safetyrule',
		tooltip = 'When activated the internal safetyrule is used for the tasks: Deconstruct, Extract, Fence, Sell, Destroy. \n\nSafetyrule currently defined as: \n' .. RbI.preconditionRules.Safety,
		getFunc = function() return RbI.account.settings.safetyrule end,
		setFunc = function(value) RbI.account.settings.safetyrule = value end,
		width = 'full',
	})

	-- fcois
	settings.add({
		type = 'checkbox',
		name = 'Enforce FCOIS',
		tooltip = 'Enforces that FCOItemSaver is running. Regardless of this option: when FCOIS is installed its marks will be considered. When this setting is set to \'true\' and FCOIS isn\'t installed only BagToBank, BankToBag and CraftToBag can be executed',
		getFunc = function() return RbI.account.settings.fcois end,
		setFunc = function(value) RbI.account.settings.fcois = value end,
		width = 'full',
	})

	--------- Settings:Output -------------------------------------------------------------
	settings.add({ type = "header", name = "Output", width = "full", })

	-- taskStart
	settings.add({
		type = 'checkbox',
		name = 'Task Start Message',
		tooltip = 'Only for batch tasks (BagToBank, BankToBag, Deconstruct, Extract, Refine, Fence, Launder, Sell)',
		getFunc = function() return RbI.account.settings.taskStartOutput end,
		setFunc = function(value) RbI.account.settings.taskStartOutput = value end,
		width = 'full',
	})

	-- taskOutput
	settings.add({
		type = 'checkbox',
		name = 'Task Action Output',
		tooltip = 'For all tasks',
		getFunc = function() return RbI.account.settings.taskActionOutput end,
		setFunc = function(value) RbI.account.settings.taskActionOutput = value end,
		width = 'full',
	})

	-- taskSummary
	settings.add({
		type = 'checkbox',
		name = 'Task Summary Output',
		tooltip = 'Currently only for tasks \'Sell\' and \'Fence\'',
		getFunc = function() return RbI.account.settings.taskSummaryOutput end,
		setFunc = function(value) RbI.account.settings.taskSummaryOutput = value end,
		width = 'full',
	})

	-- taskFinish
	settings.add({
		type = 'checkbox',
		name = 'Task Finish Success Message',
		tooltip = 'Only for batch tasks (BagToBank, BankToBag, Deconstruct, Extract, Refine, Fence, Launder, Sell)',
		getFunc = function() return RbI.account.settings.taskFinishOutput end,
		setFunc = function(value) RbI.account.settings.taskFinishOutput = value end,
		width = 'full',
	})

	-- color
	settings.add({
		type = 'colorpicker',
		name = 'Chat output color',
		tooltip = 'The output color for all output texts in the chat',
		getFunc = function() return ZO_ColorDef:New(RbI.account.settings.outputcolor):UnpackRGBA() end,
		setFunc = function(r, g, b, a) RbI.account.settings.outputcolor = ZO_ColorDef:New(r, g, b, a):ToHex() end,
		width = 'full',
	})

	--------- Settings:Timing -------------------------------------------------------------
	settings.add({ type = "header", name = "Timing", width = "full" })

	-- immediate execution at craftStation
	settings.add({
		type = 'checkbox',
		name = 'CraftStations Immediate Execution',
		tooltip = 'Automatically executes all deconstruction, extraction and refinement when interacting with a corresponding craftingstation, without having to open the respective tabs first. (Tasks: Deconstruct, Extract, Refine)',
		getFunc = function() return RbI.account.settings.immediateExecutionAtCraftStation end,
		setFunc = function(value) RbI.account.settings.immediateExecutionAtCraftStation = value end,
		width = 'full',
	})

	-- action delay slider
	settings.add({
		type = 'slider',
		name = 'Delay between actions',
		getFunc = function() return RbI.account.settings.actionDelay end,
		setFunc = function(value) RbI.account.settings.actionDelay = value end,
		width = 'full',
		min = 1,
		max = 200,
		step = 1,
		clampInput = true,
	})

	-- task delay slider
	settings.add({
		type = 'slider',
		name = 'Delay before tasks',
		getFunc = function() return RbI.account.settings.taskDelay end,
		setFunc = function(value) RbI.account.settings.taskDelay = value end,
		width = 'full',
		min = 0,
		max = 2000,
		step = 100,
		clampInput = true,
	})

	-- max simultaneous deconstruction
	settings.add({
		type = 'slider',
		name = 'Max simultaneous deconstruct/refine/extract.',
		getFunc = function() return RbI.account.settings.maxDeconstruct end,
		setFunc = function(value) RbI.account.settings.maxDeconstruct = value end,
		width = 'full',
		min = 1,
		max = 100,
		step = 1,
		clampInput = true,
	})
	
	--------- Settings:Auto Open ----------------------------------------------------------------
	settings.add({ type = "header", name = "Auto Open", width = "full"})
	
	-- auto open bank
	settings.add({
		type = 'dropdown',
		name = 'Auto Open The Bank',
		tooltip = 'Skip dialog at the bank.',
		getFunc = function() return RbI.account.settings.autoOpenBank end,
		setFunc = function(value) RbI.account.settings.autoOpenBank = value evt.AutoOpenEventUnRegister() end,
		choices = 
			{ "Never"
			, "On Actions Pending"
			, "Always"
			},
		choicesTooltips = 
			{ "Never automatically open the bank."
			, "Automatically open the bank if RbI will process items."
			, "Always automatically open the bank"
			},
		choicesValues =
			{ "Never"
			, "OnActions"
			, "Always"
			},
		width = 'full',
	})
		
	-- auto open shop
	settings.add({
		type = 'dropdown',
		name = 'Auto Open Shops And Fences',
		tooltip = 'Skip dialog at shops and fences.',
		getFunc = function() return RbI.account.settings.autoOpenShop end,
		setFunc = function(value) RbI.account.settings.autoOpenShop = value evt.AutoOpenEventUnRegister() end,
		choices = 
			{ "Never"
			, "When Only Dialog Option"
			, "Always"
			},
		choicesTooltips = 
			{ "Never automatically open shops and fences."
			, "Automatically open shops and fences when it's the only given dialog option."
			, "Always automatically open shops and fences."
			},
		choicesValues = 		
			{ "Never"
			, "NoDialog"
			, "Always"
			},
		width = 'full',
	})
	
	-- auto open assistants
	settings.add({
		type = 'checkbox',
		name = 'Auto Open At Assistants',
		tooltip = 'Skip dialog at assistants.',
		getFunc = function() return RbI.account.settings.autoOpenAssistants end,
		setFunc = function(value) RbI.account.settings.autoOpenAssistants = value evt.AutoOpenEventUnRegister() end,
		width = 'full',
	})
	
	-- prevent auto open key
	settings.add({
		type = 'dropdown',
		name = 'Prevent Auto Open Key',
		tooltip = 'Press and hold this key to prevent RbI from openening bank, shop or crafting.',
		scrollable = true,
		choices = {  "NOT SET"
					,"COMMAND"
					,"CONTROL"
					,"SHIFT"
					},
		choicesValues = {nil
					,KEY_COMMAND
					,KEY_CTRL
					,KEY_SHIFT
					},
		getFunc = function() return RbI.account.settings.autoOpenPreventionKey end,
		setFunc = function(value) RbI.account.settings.autoOpenPreventionKey = value end,
		width = 'full',
		disabled = function() return not(RbI.account.settings.autoOpenBank or RbI.account.settings.autoOpenShop or RbI.account.settings.autoOpenCraft) end,
	})
	
	--------- Settings:AutoClose ----------------------------------------------------------------
	settings.add({ type = "header", name = "Auto Close", width = "full" })
	-- auto close bank
	settings.add({
		type = 'dropdown',
		name = 'Auto Close Banks',
		tooltip = 'Automatically close banks.',
		getFunc = function() return RbI.account.settings.autoCloseBank end,
		setFunc = function(value) RbI.account.settings.autoCloseBank = value end,
		choices = 
			{ "Never"
			, "At Assistant"
			, "On Actions Executed"
			, "At Assistant Or On Actions Executed"
			, "Always"
			},
		choicesTooltips = 
			{ "Never automatically close banks."
			, "Automatically close banks only at assistant."
			, "Automatically close banks if RbI has processed items."
			, "Automatically close assistant (always) or banks if RbI has processed items."
			, "Always automatically close banks and assistant."
			},
		choicesValues =
			{ "Never"
			, "AtAssistant"
			, "OnActions"
			, "AtAssistantOrOnActions"
			, "Always"
			},
		width = 'full',
	})
	
	-- auto close shop
	settings.add({
		type = 'dropdown',
		name = 'Auto Close Shops',
		tooltip = 'Automatically close shops.',
		getFunc = function() return RbI.account.settings.autoCloseShop end,
		setFunc = function(value) RbI.account.settings.autoCloseShop = value end,
		choices = 
			{ "Never"
			, "At Assistant"
			, "On Actions Executed"
			, "At Assistant Or On Actions Executed"
			, "Always"
			},
		choicesTooltips = 
			{ "Never automatically close shops."
			, "Automatically close shops only at assistant."
			, "Automatically close shops if RbI has processed items."
			, "Automatically close assistant (always) or shops if RbI has processed items."
			, "Always automatically close shops and assistant."
			},
		choicesValues =
			{ "Never"
			, "AtAssistant"
			, "OnActions"
			, "AtAssistantOrOnActions"
			, "Always"
			},
		width = 'full',
	})
	
	-- auto close fence
	settings.add({
		type = 'dropdown',
		name = 'Auto Close Fences',
		tooltip = 'Automatically close fences.',
		getFunc = function() return RbI.account.settings.autoCloseFence end,
		setFunc = function(value) RbI.account.settings.autoCloseFence = value end,
		choices = 
			{ "Never"
			, "At Assistant"
			, "On Actions Executed"
			, "At Assistant Or On Actions Executed"
			, "Always"
			},
		choicesTooltips = 
			{ "Never automatically close fences."
			, "Automatically close fences only at assistant."
			, "Automatically close fences if RbI has processed items."
			, "Automatically close assistant (always) or fences if RbI has processed items."
			, "Always automatically close fences and assistant."
			},
		choicesValues =
			{ "Never"
			, "AtAssistant"
			, "OnActions"
			, "AtAssistantOrOnActions"
			, "Always"
			},
		width = 'full',
	})
	
	-- auto close craft
	settings.add({
		type = 'dropdown',
		name = 'Auto Close Crafting',
		tooltip = 'Automatically close crafting station (only available if "CraftStations Immediate Execution" is enabled) and assistant.',
		getFunc = function() return RbI.account.settings.autoCloseCraft end,
		setFunc = function(value) RbI.account.settings.autoCloseCraft = value end,
		choices = 
			{ "Never"
			, "At Assistant"
			, "On Actions Executed"
			, "At Assistant Or On Actions Executed"
			, "Always"
			},
		choicesTooltips = 
			{ "Never automatically close crafting station and assistant."
			, "Automatically close crafting only at assistant."
			, 'Automatically close crafting station (only available if "CraftStations Immediate Execution" is enabled) and assistant if RbI has processed items.'
			, 'Automatically close assistant (always) or crafting station if RbI has processed items (only available if "CraftStations Immediate Execution" is enabled).'
			, 'Always automatically close crafting station (only available if "CraftStations Immediate Execution" is enabled) and assistant.'
			},
		choicesValues =
			{ "Never"
			, "AtAssistant"
			, "OnActions"
			, "AtAssistantOrOnActions"
			, "Always"
			},
		width = 'full',
	})
	
	-- despawn assistants
	settings.add({
		type = 'checkbox',
		name = 'Despawn Assistants',
		tooltip = 'On auto closing any interface from an assistant, despawn the assistant.',
		getFunc = function() return RbI.account.settings.despawnAssistants end,
		setFunc = function(value) RbI.account.settings.despawnAssistants = value end,
		width = 'full',
		disabled = function() return not(RbI.account.settings.autoCloseBank or RbI.account.settings.autoCloseShop or RbI.account.settings.autoCloseCraft) end,
	})
	
	-- prevent auto close key
	settings.add({
		type = 'dropdown',
		name = 'Prevent Auto Close Key',
		tooltip = 'Press and hold this key to prevent RbI from closing bank, shop or crafting station.',
		scrollable = true,
		choices = {  "NOT SET"
					,"COMMAND"
					,"CONTROL"
					,"SHIFT"
					},
		choicesValues = {nil
					,KEY_COMMAND
					,KEY_CTRL
					,KEY_SHIFT
					},
		getFunc = function() return RbI.account.settings.autoClosePreventionKey end,
		setFunc = function(value) RbI.account.settings.autoClosePreventionKey = value end,
		width = 'full',
		disabled = function() return not(RbI.account.settings.autoCloseBank or RbI.account.settings.autoCloseShop or RbI.account.settings.autoCloseCraft) end,
	})

	--------- Settings:MultiCharAPI -------------------------------------------------------------
	settings.add({ type = "divider", width = "full" })
	local ext = RbI.extensions
	local description = "The ingame api doesn't allow us to get informations about other characters. So it needs an addon to track informations about the other characters."..
			" Various addons deliver various informations about other characters. After an adapter for those addons is written by us, we can use their tracked informations."..
			" Below you can see the functions which read informations for other characters.\n\nCurrently supported addons: "..table.concat(utils.GetKeys(ext.GetAllProvider()), ", ")
	local knowledgeProvider = submenu('Multi Character Knowledge Provider', nil, description)
	settings.add(knowledgeProvider.content)

	for retrievalMethod in RbI.utils.spairs(ext.GetAllRetrievalMethods()) do
		knowledgeProvider.add({
			type = 'dropdown',
			name = retrievalMethod,
			choices = ext.WhoCanProvide(retrievalMethod),
			tooltip = ext.GetDescription(retrievalMethod),
			getFunc = function() return ext.WhoProvides(retrievalMethod) end,
			setFunc = function(provider) ext.SetProvider(provider, retrievalMethod) end,
			width = 'full',
			scrollable = true,
			sort = 'name-up',
		})
	end
		
	return settings.content
end
