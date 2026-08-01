-----------------------------------------------------------------------------------
-- Addon Name: Rulebased Inventory
-- Creator: TaxTalis
-- Addon Ideal: user-defined rule-based actions for inventory application
-- Addon Creation Date: September 11, 2018
--
-- File Name: Task.lua
-- File Description: This file contains the definition of tasks (e.g. BagToBank)
-- Load Order Requirements: after Rule, after RuleSet, before Profile, before Loader
-- 
-----------------------------------------------------------------------------------

-- imports
local RbI = RulebasedInventory
local ruleEnv = RbI.Import(RbI.ruleEnvironment)
local ctx = RbI.Import(RbI.executionEnv.ctx)
local utils = RbI.Import(RbI.utils)

local tasks = {}
RbI.tasks = tasks
tasks.list = {} -- for menu dropdown names
local registeredTasks = {}

local preconditionRules = {}
RbI.preconditionRules = preconditionRules
-- hard game preconditions that a task/action can be executed at all.
preconditionRules.BagToBank 	= 'not (stolen() or bindType("characterbound") or (unique() and countbank(">", 0)) or type("container"))'
preconditionRules.BankToBag 	= 'not (unique() and countbackpack(">", 0))'
preconditionRules.CraftToBag    = ''
preconditionRules.Deconstruct	= 'fcoispermission() and canDeconstruct() and not locked()'
preconditionRules.Destroy		= 'fcoispermission() and not locked()'
preconditionRules.Extract		= 'fcoispermission() and canExtract() and not locked()'
preconditionRules.Fence 		= 'fcoispermission() and stolen() and not locked()'
preconditionRules.Junk 			= 'fcoispermission() and not junked() and not locked() and not companion()' -- junking is not possible with ingame lock in place (though locked also returnes fcoisLock...)
preconditionRules.Launder 		= preconditionRules.Fence
preconditionRules.Notify 		= ''
preconditionRules.Refine		= 'fcoispermission() and canRefine() and not locked()'
preconditionRules.Sell 			= 'fcoispermission() and not stolen() and not locked() and sellinformation() ~= 4' -- 4 = ITEM_SELL_INFORMATION_CANNOT_SELL
preconditionRules.Buy  			= ''
-- not locked used for: Deconstruct, Destroy, Extract, Fence, Junk, Refine, Sell
preconditionRules.UnJunk 		= 'junked()'
preconditionRules.Use 		    = 'usable()'
preconditionRules.Safety		= 'not (\n  quality("legendary")\n  or trait("weapon_nirnhoned")\n  or price(0, true) > 10000\n  or crownCrate()\n)'
-- Safety rule is currently used for: Deconstruct, Destroy, Extract, Fence, Sell (no need for 'not locked()' because it's already in all internal task rules)

local function registerTask(nameFn, isForUser, defaultAllowAction, hasRevertTask, bagFrom, actionName, bagTo, useSafetyRule, blockerTaskId, description)
	local self = {}
	local id = nameFn()
	self.id = id
	self.defaultAllowAction = defaultAllowAction
	self.bagFrom = bagFrom
	self.bagTo = bagTo
	self.Action = RbI.actions[actionName]
	self.description = description or false
	if(description ~= nil and preconditionRules[id]~=nil and preconditionRules[id]~='') then
		self.description = self.description..' \n\nInternal precondition:\n'..preconditionRules[id]
	end
	
	local function GetDefaultAllowAction()
		return defaultAllowAction
	end
	
	local function GetBagFrom()
		local bag = self.bagFrom
		if(type(bag) == "function") then
			return bag()
		end
		return bag
	end

	local function GetBagTo()
		local bag = self.bagTo
		if(type(bag) == "function") then
			return bag()
		end
		return bag
	end

	local function GetId()
		return self.id
	end

	local function RunWithRevertTask()
		local taskSettings = RbI.account.tasks[GetId()]
		if(taskSettings) then
			return taskSettings.runWithRevertTask
		end
		return false
	end

	local function HasRevertTask()
		return hasRevertTask
	end

	local function GetOpposingTask()
		if(blockerTaskId) then
			return registeredTasks[blockerTaskId]
		else
			for _, task in pairs(registeredTasks) do
				local optBlockerTask = task.GetBlockerTask()
				if(optBlockerTask ~= nil and optBlockerTask.GetId() == self.id) then
					return task
				end
			end
		end
	end
	
	local function GetBlockerTask()
		if(blockerTaskId) then
			return registeredTasks[blockerTaskId]
		end
	end

	local function GetDisplayName()
		local _, displayName = nameFn()
		return displayName
	end

	-- add taskName to list for menu dropdown names
	-- as tasks are only created once, we can add them straigt on
	-- and we do not need functionality to delete them later
	if(isForUser) then
		table.insert(tasks.list, self.id)
	end

	local task
	task = { GetId = GetId
			,GetDisplayName = GetDisplayName
			,GetDefaultAllowAction = GetDefaultAllowAction
			,GetOpposingTask = GetOpposingTask
			,GetBlockerTask = GetBlockerTask
			,IsUserTask = function() return isForUser end
			,IsUseSafetyRule = function() return useSafetyRule end
			,GetBagFrom = GetBagFrom
			,GetBagTo = GetBagTo
			,GetDescription = function() return self.description end
			,RunWithRevertTask = RunWithRevertTask
			,HasRevertTask = HasRevertTask
			,GetBlockerTaskId = function() return blockerTaskId end
			,DoAction = function(...) return self.Action(...) end
			,withOptions = function(self, opt)
				if(self ~= task) then error("You have to use ':' for the withOptions-function call") end
				local result
				result = {
					task=task,
					opt=opt or {},
					withOptions = function(self, opt)
						if(self ~= result) then error("You have to use ':' for the withOptions-function call") end
						for key, value in pairs(opt) do
							if(result.opt[key] == nil) then
								result.opt[key] = value
							end
						end
						return result
					end
				}
				return result
			end
	}
	task.checker = RbI.taskItemCheckerNew(task)
	registeredTasks[id] = task
	return task
end

function RbI.tasks.GetTask(id)
	return registeredTasks[id]
end

function RbI.tasks.GetAllTasks()
	return registeredTasks
end

local function addTask(nameFn, isForUser, defaultAllowAction, hasRevertTask, bagFrom, actionName, bagTo, useSafetyRule, blockerTaskId, description)
	local id, displayName = nameFn()
	local internalRule = preconditionRules[id]
	if(internalRule == nil) then error("Internal rule for task: '"..displayName.."' isn't defined!") end
	ruleEnv.RegisterInternalRule(id, preconditionRules[id])
	local task = registerTask(nameFn, isForUser, defaultAllowAction, hasRevertTask, bagFrom, actionName, bagTo, useSafetyRule, blockerTaskId, description)
	RbI.allowAction[id] = task.GetDefaultAllowAction()
end
local function removeTask(taskId)
	registeredTasks[taskId] = nil
	ruleEnv.UnregisterInternalRule(taskId)
end
local function rebuildTaskList()
	utils.clear(tasks.list)
	for taskId, task in pairs(registeredTasks) do
		if(task.IsUserTask()) then
			table.insert(tasks.list, taskId)
		end
	end
end

local nameFn = function(name) return function() return name, name end end

function RbI.tasks.Initialize()
	local stationFn = function(testDefault) return function() return ctx.station or testDefault end end
	local storeFn = function(testDefault) return function() return ctx.store or testDefault end end
	addTask(nameFn('BagToBank'), true, false, false, BAG_BACKPACK, 'MoveItem', stationFn(BAG_BANK), false, 'BankToBag', 'Puts items from your backpack in your bank.')
	addTask(nameFn('BankToBag'), true, false, false, stationFn(BAG_BANK), 'MoveItem', BAG_BACKPACK, false, nil, 'Puts items from your bank in your backpack')
	addTask(nameFn('CraftToBag'), true, true, false, BAG_VIRTUAL, 'MoveItem', BAG_BACKPACK, false, nil, 'Puts items from your craftbag into your backpack')
	addTask(nameFn('Deconstruct'), true, false, false, 'DECONSTRUCTION', 'DeconstructItem', nil, true, nil, 'Deconstructs items at crafting station or deconstruction assistant')
	addTask(nameFn('Destroy'), true, true, false, BAG_BACKPACK, 'DestroyItem', nil, true, nil, 'Destroys items')
	addTask(nameFn('Extract'), true, false, false, 'EXTRACTION', 'DeconstructItem', nil, true, nil, 'Extracts items at enchanting crafting station or deconstruction assistant')
	addTask(nameFn('Fence'), true, false, false, BAG_BACKPACK, 'FenceItem', nil, true, nil, 'Sells items at the fence-store')  -- sell
	addTask(nameFn('Junk'), true, true, true, BAG_BACKPACK, 'JunkItem', nil, false, nil, 'Marks items as junk')
	addTask(nameFn('Launder'), true, false, false, BAG_BACKPACK, 'LaunderItem', nil, false, nil, 'Launders the item, removing the stolen marker') -- remove stolen marker
	addTask(nameFn('Notify'), true, true, false, BAG_BACKPACK, 'Notify', nil, false, nil, 'Prints a notify message in the chat including price')
	addTask(nameFn('Refine'), true, false, false, 'REFINEMENT', 'DeconstructItem', nil, false, nil, 'Refines items at woodworking/blacksmithing/clothier/jewelry crafting station')
	addTask(nameFn('Sell'), true, false, false, BAG_BACKPACK, 'SellItem', nil, true, nil, 'Sells items at vendor-store')
	addTask(nameFn('Buy'), true, false, false, storeFn(BAG_VIRTUAL), 'BuyItem', BAG_BACKPACK, false, nil, 'Buys items at vendor-store')
	addTask(nameFn('Use'), true, true, false, BAG_BACKPACK, 'UseItem', nil, false, nil, 'Uses the items')

	addTask(nameFn('UnJunk'), false, true, false, BAG_BACKPACK, 'UnJunkItem', nil, false, 'Junk')
	-- addTask('BagToCraft'] = {BAG_BACKPACK, 'MoveItem', BAG_VIRTUAL, false)

	if(FCOIS and RbI.FcoisControllerUICheck()) then -- when not RbI.FcoisControllerUICheck(): maxIconNr retrieval will fail
		local languageData = {}
		RbI.collectedData["fcoisMark"] = languageData
		-- local numFilterIcons = FCOIS.numVars.gFCONumFilterIcons
		local maxIconNr = FCOIS.mappingVars.dynamicToIcon[FCOIS.settingsVars.settings.numMaxDynamicIconsUsable]
		for iconNr=FCOIS_CON_ICON_LOCK, maxIconNr do
			local iconId = RbI.dataTypeStatic["fcoisMarkIds"][iconNr]
			RbI.RenameTask('FCOISMark:'..iconNr, 'FCOISMark:'..iconId) -- will be copied only if it exists todo: remove in a further version
			languageData[RbI.fcois.getNameByNr(iconNr)] = iconNr
			local taskId = 'FCOISMark:'..iconId
			preconditionRules[taskId] = 'not fcoismarker('.."'"..iconId.."'"..')'
			addTask(function() return taskId, 'FCOISMark: '..RbI.fcois.getNameByNr(iconNr) end, true, true, true, BAG_BACKPACK, 'FCOIS_MarkItem', nil, false, nil, 'Marks items using FCO ItemSaver addon. FCOIS provides itself also an automatic marking functionality. Please ensure that there are no contradictions.')

			local taskIdOpp = 'FCOISUnmark:'..iconId
			preconditionRules[taskIdOpp] = 'fcoismarker('.."'"..iconId.."'"..')'
			addTask(function() return taskIdOpp, 'FCOISUnmark: '..RbI.fcois.getNameByNr(iconNr) end, false, true, false, BAG_BACKPACK, 'FCOIS_UnmarkItem', nil, false, taskId, 'Unmarks items using FCO ItemSaver addon')
		end
		-- merge to dataType
		local targetEnumDataType = RbI.dataType["fcoisMark"]
		for key, value in pairs(languageData) do
			local loweredKey = key:lower()
			if(not targetEnumDataType[loweredKey]) then
				RbI.dataTypeHandler.addData(targetEnumDataType, loweredKey, value)
			end
		end
	end

	for postFixName in pairs(RbI.data.getHomeBanks()) do
		preconditionRules['BagToHomebank'..postFixName] = preconditionRules['BagToBank']
		preconditionRules['Homebank'..postFixName..'ToBag'] = preconditionRules['BankToBag']
	end
	tasks.CheckHomebankTasks(true)

	ruleEnv.RegisterInternalRule('Safety', preconditionRules['Safety'])
end

local function addHomebankTask(postFixName, bagId)
	if(not tasks.GetTask('BagToHomebank'..postFixName)) then
		addTask(nameFn('BagToHomebank'..postFixName), true, false, false, BAG_BACKPACK, 'MoveItem', bagId, false, 'Homebank'..postFixName..'ToBag', 'Puts items from your backpack in your homebank.')
		addTask(nameFn('Homebank'..postFixName..'ToBag'), true, false, false, bagId, 'MoveItem', BAG_BACKPACK, false, nil, 'Puts items from your homebank in your backpack')
	end
end
function tasks.CheckHomebankTasks(initial)
	local homebankingMode = RbI.account.settings.homebankingMode
	if(homebankingMode == "Task Mode") then
		for postFixName, bagId in pairs(RbI.data.getHomeBanks()) do
			addHomebankTask(postFixName, bagId)
		end
	elseif(not initial) then
		for postFixName in pairs(RbI.data.getHomeBanks()) do
			removeTask('BagToHomebank'..postFixName)
			removeTask('Homebank'..postFixName..'ToBag')
		end
	end
	if(not initial) then rebuildTaskList() end
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Task Start functions ------------------------------------------------------
------------------------------------------------------------------------------

local function TasksFinished(TaskRun1, TaskRun2)
	ctx.task = nil

	if(RbI.testrun) then
		zo_callLater(function() RbI.testrun = false
								if(RbITaskTestButton ~= nil) then
									RbITaskTestButton:UpdateDisabled()
									RbITaskRunButton:UpdateDisabled()
								end
					end, 2000)
	end

	RbI.ClearLookup(TaskRun1.task.GetBagFrom())
	RbI.ClearLookup(TaskRun1.task.GetBagTo())
	if(TaskRun2.task) then
		RbI.ClearLookup(TaskRun2.task.GetBagFrom())
		RbI.ClearLookup(TaskRun2.task.GetBagTo())
	end
end

local function Interleave(TaskRun1, TaskRun2, checkProgress)
	-- executing task cannot have finished == true as it would not have been called again
	checkProgress = checkProgress or {}
	if(TaskRun1.result.status and TaskRun2.result.status) then
		-- status of both tasks is ok
		if(TaskRun1.result.actionCount == nil or TaskRun2.result.actionCount > 0) then
			-- this task has not yet been run, or the last task has done something
			local s, f, a = TaskRun1.task.checker.CheckByItemLink(nil, TaskRun1.opt.bag, TaskRun2.opt and TaskRun2.opt.bag, checkProgress)
			TaskRun1.result.status = s
			TaskRun1.result.finished = f
			TaskRun1.result.actionCount = a
			TaskRun1.result.totalActionCount = TaskRun1.result.totalActionCount + a

			if(TaskRun2.result.finished == false) then
				-- interleaved did not finish, call it again
				Interleave(TaskRun2, TaskRun1, checkProgress)
			else
				-- interleaved task already did finish, no need for calling it again, selfcall just finished, everything possible should be done by now
				TasksFinished(TaskRun1, TaskRun2)
			end
		else
			-- last task did not finish but could not process any items, abort execution, there are no slots left
			TasksFinished(TaskRun1, TaskRun2)
		end
	else
		-- an error occured during execution, abort execution
		TasksFinished(TaskRun1, TaskRun2)
	end
end

local function initiateTaskRun(taskRun)
	if(taskRun ~= nil) then
		taskRun = taskRun:withOptions() -- ensure that taskRun.task exists
		taskRun.result = {status = true, finished = false, actionCount = nil, totalActionCount = 0 }
		if(not RbI.testrun and not RbI.allowAction[taskRun.task.GetId()]) then
			-- error(taskRun.task.GetId().." isn't allowed to start!") -- only for testing purposes
			return -- Task isn't allowed to start
		end
		return taskRun
	else
		return {
			result = {status = true, finished = true, actionCount = nil, totalActionCount = 0}
		}
	end
end

function tasks.Start(TaskRun1, TaskRun2)
	if(type(TaskRun1)=="string") then TaskRun1 = registeredTasks[TaskRun1] end
	if(type(TaskRun2)=="string") then TaskRun2 = registeredTasks[TaskRun2] end
	ctx.task = {}
	TaskRun1 = initiateTaskRun(TaskRun1)
	TaskRun2 = initiateTaskRun(TaskRun2)
	if(TaskRun1 and TaskRun2) then
		RbI.GetLookup(TaskRun1.task.GetBagFrom(), true)
		RbI.GetLookup(TaskRun1.task.GetBagTo(), true)
		if(TaskRun2.task) then
			RbI.GetLookup(TaskRun2.task.GetBagFrom(), true)
			RbI.GetLookup(TaskRun2.task.GetBagTo(), true)
		end
		Interleave(TaskRun1, TaskRun2)
		return {result = TaskRun1.result}, {result = TaskRun2.result}
	end
	return {result = {status = true, finished = true, actionCount = nil, totalActionCount = 0}},
		   {result = {status = true, finished = true, actionCount = nil, totalActionCount = 0}}
end

function tasks.Test(taskName)
	RbI.testrun = true
	local task = registeredTasks[taskName]
	tasks.Start(task)
	if (task.RunWithRevertTask()) then
		tasks.Start(task.GetOpposingTask())
	end
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Single item backpack check ------------------------------------------------
------------------------------------------------------------------------------

local function checkItemBySlot(task, itemRef)
	local status, finished, actionCount = task.checker.CheckBySlot(itemRef)
	return actionCount
end
local function checkItemByLink(task, itemRef)
	local status, finished, actionCount = task.checker.CheckByItemLink(itemRef)
	return actionCount
end

local function checkFCOISMarks(itemRef)
	for taskId, task in pairs(registeredTasks) do
		if(utils.startsWith(taskId, 'FCOISMark')) then
			local result = checkItemBySlot(task, itemRef)
			if(result > 0) then return result end
			local oppTask
			if(task.RunWithRevertTask() and RbI.RuleSet.HasRules(taskId)) then
				result = checkItemBySlot(task.GetOpposingTask(), itemRef)
				if(result > 0) then return result end
			end
		end
	end
	return 0
end

local isJunkBag = RbI.data.isJunkBag
-- bank: FCOISMark, junk
-- backpack: FCOISMark, junk, use, destroy
-- else: FCOISMark
function RbI.CheckItemInBag(itemRef)
	local bag = itemRef.bag
	RbI.GetLookup(bag, true)
	local result = checkFCOISMarks(itemRef)
	if(isJunkBag(bag)) then
		if(result == 0) then
			local junkTask = registeredTasks['Junk']
			result = checkItemBySlot(junkTask, itemRef)
			if(result == 0 and junkTask.RunWithRevertTask() and RbI.RuleSet.HasRules('Junk')) then
				result = checkItemBySlot(junkTask.GetOpposingTask(), itemRef)
			end
		end
		if(bag == BAG_BACKPACK) then
			if(result == 0) then
				result = checkItemBySlot(registeredTasks['Use'], itemRef)
				--d("UseResult: "..tostring(result))
				if(result == 0) then
					-- checkItemByLink because we want to watch on all stacks to destroy the smallest ones first
					result = checkItemByLink(registeredTasks['Destroy'], itemRef)
					--d("DestroyResult: "..tostring(result))
				end
			end
		end
	end
	RbI.ClearLookup(bag)
end

function tasks.NeedToRun(taskName1, taskName2)
	RbI.allowAction["StartMessage"] = false
	RbI.allowAction["FinalMessage"] = false
	RbI.allowAction["ActionMessage"] = false
	RbI.allowAction["SummaryMessage"] = false
	RbI.testrun = true

	local TaskRun1, TaskRun2 = tasks.Start(taskName1, taskName2)

	RbI.allowAction["StartMessage"] = true
	RbI.allowAction["FinalMessage"] = true
	RbI.allowAction["ActionMessage"] = true
	RbI.allowAction["SummaryMessage"] = true
	RbI.testrun = false --needed as async TasksFinished is too slow to set this for this purpose

	return TaskRun1.result.totalActionCount > 0 or TaskRun2.result.totalActionCount > 0
end


------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Full item backpack check --------------------------------------------------
------------------------------------------------------------------------------

function tasks.StartWithCallback(task, finishFn)
	local added = false
	local startFn = function() added = true end
	local taskId = task.GetId()
	RbI.ActionQueue.AddStartCallback(taskId, startFn)
	RbI.ActionQueue.AddFinishCallback(taskId, finishFn) -- d("finish:"..taskId)
	tasks.Start(task)
	if(not added) then -- finish directly, removing all callbacks
		RbI.ActionQueue.RemoveStartCallback(taskId, startFn)
		RbI.ActionQueue.RemoveFinishCallback(taskId, finishFn)
	end
end

-- is a bit slower than StartWithCallback, but I don't know why :/
function tasks.StartWithCallback2(task, finishFn)
	if(tasks.Start(task) > 0) then
		RbI.ActionQueue.AddFinishCallback(task.GetId(), finishFn) -- d("RunTaskEnd "..task.GetId())
	else
		finishFn()
	end
end

function tasks.StartAllTasks(tasksToRun) -- one task after another
	local startTime = GetGameTimeMilliseconds()
	RbI.allowAction["StartMessage"] = false
	RbI.allowAction["FinalMessage"] = false
	local curI = 1
	local next
	next = function()
		local curTask = tasksToRun[curI]
		if(curTask) then
			curI = curI + 1
			tasks.StartWithCallback(curTask, next)
		else
			RbI.out.msg("Finished items check! "..((GetGameTimeMilliseconds()-startTime)/1000).." secs")
			RbI.allowAction["StartMessage"] = true
			RbI.allowAction["FinalMessage"] = true
		end
	end
	next()
end

-- much faster than queueing all items
function tasks.CheckAllItems(bag, withOpposite)
	local tasksToRun = {}
	local junkTask = registeredTasks['Junk']
	tasksToRun[#tasksToRun+1] = junkTask
	if(withOpposite and junkTask.RunWithRevertTask() and RbI.RuleSet.HasRules('Junk')) then tasksToRun[#tasksToRun+1] = junkTask.GetOpposingTask() end -- Unjunk
	tasksToRun[#tasksToRun+1] = registeredTasks['Destroy']
	for taskId, task in pairs(registeredTasks) do
		if(utils.startsWith(taskId, 'FCOISMark')) then
			tasksToRun[#tasksToRun+1] = task
			if(withOpposite and task.RunWithRevertTask() and RbI.RuleSet.HasRules(taskId)) then tasksToRun[#tasksToRun+1] = task.GetOpposingTask() end -- Unmark
		end
	end
	tasksToRun[#tasksToRun+1] = registeredTasks['Use']
	tasks.StartAllTasks(tasksToRun)
end
