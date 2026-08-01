-----------------------------------------------------------------------------------
-- Addon Name: Rulebased Inventory
-- Creator: TaxTalis
-- Addon Ideal: user-defined rule-based actions for inventory application
-- Addon Creation Date: September 11, 2018
--
-- File Name: Queue.lua
-- File Description: This file contains the queue on which actions of tasks are stored to be executed in a more kick-free way
-- Load Order Requirements: before Action
-- 
-----------------------------------------------------------------------------------

-- imports
local RbI = RulebasedInventory
local ruleEnv = RbI.Import(RbI.ruleEnvironment)
local utils = RbI.Import(RbI.utils)
local ctx = RbI.Import(RbI.executionEnv.ctx)
local evt = RbI.Import(RbI.evt)

local function DoFlushDeconstruct()
	-- due to a eso-bug it wants to play creations sounds. Init them here to 'none'
	if(ctx.station == CRAFTING_TYPE_ENCHANTING) then
		ENCHANTING.potencySound = SOUNDS["NONE"]
		ENCHANTING.potencyLength = 0
		ENCHANTING.essenceSound = SOUNDS["NONE"]
		ENCHANTING.essenceLength = 0
		ENCHANTING.aspectSound = SOUNDS["NONE"]
		ENCHANTING.aspectLength = 0
	end
	return evt.CanSendDeconstruct() and SendDeconstructMessage()
end

local function NewActionQueue(instant)
	local self = {
		output = {},
		messageSize = 0,
	}

	local function Output()
		for i, taskName in ipairs(self.output) do
			self.output[i] = nil
			RbI.PrintQueue('Task ' .. taskName)
			self.output[taskName] = false
		end
	end

	local function AddCancelFinalMessage(taskId)
		if(self.output[taskId]) then
			RbI.AddMessageToQueueFinal('Task ' .. taskId, taskId, false, 'canceled.', true, false)
		end
	end

	local function queueCancel()
		AddCancelFinalMessage("Deconstruct")
		AddCancelFinalMessage("Refine")
		AddCancelFinalMessage("Extract")
	end
	local function queueVerify()
		RbI.VerifyAllPriorMessages('Task ' .. "Deconstruct")
		RbI.VerifyAllPriorMessages('Task ' .. "Refine")
		RbI.VerifyAllPriorMessages('Task ' .. "Extract")
	end

	local asyncQueue

	local waitForCraftCompleteName = RbI.name .. 'WaitForDeconstructMessageToBeRead'
	local function waitForCraftComplete(fn)
		asyncQueue.Pause(true)
		EVENT_MANAGER:RegisterForEvent(waitForCraftCompleteName, EVENT_CRAFT_COMPLETED, function(eventCode, station)
			EVENT_MANAGER:UnregisterForEvent(waitForCraftCompleteName, EVENT_CRAFT_COMPLETED)
			if(evt.CanSendDeconstruct()) then
				queueVerify()
			else
				queueCancel()
			end
			if(fn) then fn() end
			asyncQueue.Run(true)
		end)
	end

	local function FlushDeconstruct()
		self.messageSize = 0
		local running = asyncQueue.IsRunning()
		if(DoFlushDeconstruct()) then
			if(running) then -- queue haven't finished yet
				waitForCraftComplete()
			elseif(evt.CanRefine()) then -- within queue.finishFn
				waitForCraftComplete(function()
					RbI.tasks.Start('Refine')
				end)
			else -- within queue.finishFn
				waitForCraftComplete()
			end
		elseif(not running) then
			queueCancel()
			Output()
		end
	end
	asyncQueue = utils.NewAsyncQueue(instant, RbI.account.settings.actionDelay,
		function(entry) -- Next
			local taskName = entry.taskName
			local itemLink = entry.itemLink
			local amount = entry.amount
			local func = entry.func
			local isDeconstruct = taskName == 'Deconstruct' or taskName == 'Refine' or taskName == 'Extract'
			if(RbI.allowAction[taskName] or taskName == 'DestroyMove') then
				if(taskName ~= 'DestroyMove' and not instant) then
					-- d(taskName, itemLink, amount)
					-- d(".....")
					RbI.AddMessageToQueue('Task ' .. taskName, taskName, false, itemLink, amount, isDeconstruct)
					-- d(".....")
				end

				if(isDeconstruct and self.messageSize == 0) then
					PrepareDeconstructMessage()
				end
				if(instant) then -- instant action messages
					local result, optMsg = func()
					if(type(result) == 'string') then
						RbI.out.msg("Usage of "..itemLink.." failed! ("..result..")")
					else
						if(result) then -- result==nil will be requeue
							RbI.out.msg("Used "..itemLink..(optMsg or ''))
						elseif(result == false) then
							RbI.out.msg("Usage of "..itemLink.." failed!")
						end
					end
				else
					func() -- execute queued action
				end

				if(isDeconstruct) then
					if(self.messageSize >= (RbI.account.settings.maxDeconstruct - 1)) then
						FlushDeconstruct()
					else
						self.messageSize = self.messageSize + 1
					end
				end
			else
				RbI.AddMessageToQueueFinal('Task ' .. taskName, taskName, false, 'canceled.', isDeconstruct, false)
			end
		end,
		nil, -- EqualsFn
		function() -- Finish
			--d("queueFinish")
			if(RbITaskTestButton ~= nil and RbITaskRunButton ~= nil) then
				zo_callLater(function() RbITaskTestButton:UpdateDisabled() RbITaskRunButton:UpdateDisabled() end, 2000)
			end
			if(self.messageSize > 0) then
				FlushDeconstruct() -- will handle also the output itself
				return
			end

			Output()
		end
	)

	local function Run(taskId, testrun, start, final, success)
		if(taskId ~= nil and not instant and taskId ~= 'DestroyMove') then
			if(start) then
				RbI.AddMessageToQueueStart('Task ' .. taskId, taskId, testrun)
			end
			if(not self.output[taskId]) then
				self.output[taskId] = true
				table.insert(self.output, taskId)
			end
			RbI.AddMessageToQueueFinal('Task ' .. taskId, taskId, testrun, final, nil, success)
		end
		asyncQueue.Run()
	end
	
	local function Push(taskName, itemLink, amount, func, delay)
		asyncQueue.Push({
			taskName = taskName,
			itemLink = itemLink,
			amount = amount,
			func = func
		}, delay)
	end

	return {
		Run = Run,
		Push = Push,
		AddFinishCallback = asyncQueue.AddFinishCallback,
		AddStartCallback = asyncQueue.AddStartCallback,
		RemoveStartCallback = asyncQueue.RemoveStartCallback,
		RemoveFinishCallback = asyncQueue.RemoveFinishCallback,
		IsRunning = function()
			return asyncQueue.IsRunning()
		end
	}
end

local actionQueue
local actionQueueInstant
local function getQueue(taskName)
	if(taskName == 'Use') then
		return actionQueueInstant
	else
		return actionQueue
	end
end
RbI.ActionQueue = {
	Run = function(taskName, testrun, start, final, success)
		return getQueue(taskName).Run(taskName, testrun, start, final, success)
	end,
	Push = function(taskName, itemLink, amount, func, delay)
		return getQueue(taskName).Push(taskName, itemLink, amount, func, delay)
	end,
	IsRunning = function(taskName)
		if(taskName == nil) then
			return actionQueue.IsRunning() or actionQueueInstant.IsRunning()
		end
		return getQueue(taskName).IsRunning()
	end,
	AddFinishCallback = function(taskName, callback)
		getQueue(taskName).AddFinishCallback(callback)
	end,
	AddStartCallback = function(taskName, callback)
		getQueue(taskName).AddStartCallback(callback)
	end,
	RemoveStartCallback = function(taskName, callback)
		getQueue(taskName).RemoveStartCallback(callback)
	end,
	RemoveFinishCallback = function(taskName, callback)
		getQueue(taskName).RemoveFinishCallback(callback)
	end,

}
RbI.addInitialize(function()
	actionQueue = NewActionQueue(false)
	actionQueueInstant = NewActionQueue(true)
end)