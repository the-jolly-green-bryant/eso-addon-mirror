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

RbI.taskItemCheckerNew = function(task)
	local taskId = task.GetId()

	-- @return status: boolean. 'false' if an error occured (from the task or a potential opposingTask)
	-- @return result: boolean. The result for this item.
	-- @return resultInv: boolean. The result of the opposingTask for this item.
	local function Evaluate(bag, slot, itemLink)
		local status = true
		local result = false

		ctx.item = {
			bag = bag,
			slot = slot,
			link = itemLink
		}
		-- Precondition rule verification
		status, result = ruleEnv.RunRuleWithItem(RbI.rules.internal[taskId], bag, slot, itemLink, task.GetDisplayName())
		if(status == false or result == false) then
			-- d("internal " .. ruleName .. " false")
			return status, result
		end
		if(task.IsUseSafetyRule() and RbI.account.settings.safetyrule) then
			status, result = ruleEnv.RunRuleWithItem(RbI.rules.internal['Safety'], bag, slot, itemLink, task.GetDisplayName())
			if(status == false or result == false) then
				return status, result
			end
		end
		
		local statusInv = true
		local resultInv = false
		if(task.GetBlockerTaskId() ~= nil) then
			statusInv, resultInv = RbI.RuleSet.Evaluate(task.GetBlockerTaskId(), bag, slot, itemLink)
		end
		if(statusInv) then
			status, result = RbI.RuleSet.Evaluate(taskId, bag, slot, itemLink)
		end
		--d("Evaluate "..taskId.." "..itemLink.." => "..tostring((status and statusInv)).." "..tostring(result)" "..tostring(resultInv))
		return (status and statusInv), result, resultInv
	end
	
	-- result holds an amount to each bag/slot found in given slots which shall be taken action on
	-- GetSlotDatas' returned table (here child-table-of-tables: slotDatas) must not be written to!
	local function GetSlotFromDatas(slotDatas, bagTo, bagToCount)
		
		local slotFromDatas = {}
		-- we assume that with the masked itemLink used for sorting, 
		-- that the count returned by GetItemLinkStacks is true for all slotDatas
		local bagCount = {}
		for	bag, count in pairs(slotDatas.count) do
			bagCount[bag] = count
		end
		local status = true
		local itemLink, bagFrom
		
		local tmpSlotDatas = {}
		-- GetSlotDatas' returned table (here child-table-of-tables: slotDatas) must not be written to!
		-- clear! slotData is a table, which ipairs does a copy of, no linked tables inside slotData.
		local count = 0
		for i, slotData in ipairs(slotDatas) do
			table.insert(tmpSlotDatas, slotData)
			count = count + 1
		end
		
		local index
		while(count > 0) do
			for i, slotData in pairs(tmpSlotDatas) do
				if(index == nil or tmpSlotDatas[index].stack > slotData.stack) then
					index = i
				end
			end
			
			-- d(index)
			
			local slotData = tmpSlotDatas[index]
			tmpSlotDatas[index] = nil
			index = nil
			count = count - 1
			
			bagFrom = slotData.bag
			if(bagFrom == BAG_SUBSCRIBER_BANK) then bagFrom = BAG_BANK end
			
			ctx.amountHelper = {}
			ctx.amountHelper.count = {}
			ctx.amountHelper.count[bagFrom] = bagCount[bagFrom]
			if(bagTo ~= nil) then
				ctx.amountHelper.count[bagTo] = bagToCount
			end
			
			if bagFrom == 'VENDOR' then
				ctx.buyInfo = {
					currency = slotData.currency,
					stackPrice = slotData.stackPrice,
					stackCount = slotData.stack,
					stackCountMax = slotData.stackMax,
				}
			end

			local resultSelf, resultInv
			status, resultSelf, resultInv = Evaluate(slotData.bag, slotData.slot, slotData.itemLink)

			if(status) then
				if(resultSelf) then	
					local remainingCount = bagCount[bagFrom]
					local amountHelpers = {}
					for amountHelper in pairs(ctx.amountHelper[bagFrom] or {}) do
						amountHelpers[amountHelper] = true
					end
					amountHelpers[0] = true --try moving all
					if(bagTo ~= nil) then
						for amountHelper in pairs(ctx.amountHelper[bagTo] or {}) do
							if(0 <= amountHelper and amountHelper >= bagToCount) then
								amountHelpers[bagCount[bagFrom] + (bagToCount - amountHelper)] = true
							end
						end
					end
					-- local cnt = 0
					local amountHelper = table.maxn(amountHelpers)
					while (true) do
						-- d("-----AMOUNT-------")
						-- d(amountHelper)
						-- d(amountHelpers)
						-- d("------------")
						amountHelpers[amountHelper] = nil	
						if(amountHelper <= remainingCount) then	
							ctx.amountHelper.count = {}
							ctx.amountHelper.count[bagFrom] = amountHelper
							if(bagTo ~= nil) then
								ctx.amountHelper.count[bagTo] = bagToCount + (bagCount[bagFrom] - amountHelper)
							end
							status, resultSelf, resultInv = Evaluate(slotData.bag, slotData.slot, slotData.itemLink)
							if(status) then
								if(resultSelf) then
									-- rule tells to do something
									if(resultInv) then
										-- invert tells opposide side would do something
										-- d("(1) remainingCount set: " .. remainingCount)
										break
									else
										-- inverted has nothing against this move
										remainingCount = amountHelper
										-- d("(2) remainingCount set: " .. remainingCount)
									end
								else 
									-- this is the first time rule has failed, 
									-- then this is the remainingCount we want to keep
									-- if not the other side would do something
									
									if(resultInv) then
										-- invert tells opposide side would do something
										-- d("(3) remainingCount set: " .. remainingCount)
									else
										-- inverted has nothing against this move
										remainingCount = amountHelper
										-- d("(4) remainingCount set: " .. remainingCount)
									end
									
									break
								end
							else
								-- an error occured in a rule
								break
							end
						end
						if(amountHelper == 0) then
							-- d("????????????????????????????????????")
							break
						end
						amountHelper = table.maxn(amountHelpers)
						-- cnt = cnt + 1
						-- if(cnt == 10) then
							-- d("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
						-- end
					end
					-- d("+++++++++++++++")
					if(remainingCount < bagCount[bagFrom]) then
						-- slotData is a table, which ipairs does a copy of, no linked tables inside slotData.
						slotData.stackCountChange = -math.min((bagCount[bagFrom] - remainingCount), slotData.stack)
						if(bagTo ~= nil) then
							bagToCount = bagToCount - slotData.stackCountChange
						end
						bagCount[bagFrom] = bagCount[bagFrom] + slotData.stackCountChange
						table.insert(slotFromDatas, slotData)
						-- d("counts")
						-- d(bagCount[bagFrom])
						-- d(bagToCount)
						-- d("......")
					end
				end	
			else
				-- an error occured in a rule
				break
			end
		end
		ctx.buyInfo = nil

		-- d("#####")
		-- d(slotFromDatas)
		-- slotFromDatas = {}
		return status, slotFromDatas
	end
	
	local function Finish(singleItemLink, status, finished)
		local start = false
		local success = true
		local final
		if(singleItemLink == nil) then
			if(status) then
				if(finished ~= nil or RbI.testrun) then
					start = true
					if(finished == nil or finished) then
						final = 'finished'
					else
						if(taskId ~= 'Fence' and taskId ~= 'Launder') then
							final = 'halted: Target Bag is full!'
							success = false
						else
							final = 'halted: Daily Limit reached!'
							success = false
						end
					end
				end
			else
				final = 'canceled: An error ocurred!'
				success = false
			end
		end
		RbI.ActionQueue.Run(taskId, RbI.testrun, start, final, success)
	end
	
	local function CheckByItemLink(optionalSingleItemRef, bagFrom, bagTo, checkProgress)
		local status = true
		local finished
		local actionCount = 0
		local checkProgress = checkProgress or {}

		local bagFrom = bagFrom or task.GetBagFrom()
		local bagTo = bagTo or task.GetBagTo()
		-- just so, when needed later on, the lookup will not be cleared before this task has finished
		local lookupBagFrom = RbI.GetLookup(bagFrom, true)
		local lookupBagTo = RbI.GetLookup(bagTo, true)
		local mayOverrideBagToVirtual = (bagTo == BAG_BACKPACK and bagFrom ~= BAG_VIRTUAL and HasCraftBagAccess() and (GetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_ADD_TO_CRAFT_BAG) == "1"))
		local lookupBagToVirtual = (mayOverrideBagToVirtual and RbI.GetLookup(BAG_VIRTUAL, true)) or nil

		local optionalSingleItemLink = optionalSingleItemRef and optionalSingleItemRef:GetItemLink()

		if(RbI.RuleSet.HasRules(taskId)) then
			finished = true
			-- GetSlotDatas' returned table must not be written to!
			local bagFromOccupied = lookupBagFrom.GetSlotDatas(optionalSingleItemLink)
			local bagToOccupied, bagToOccupiedOverride = {}, nil
			if(lookupBagTo ~= nil) then 
				bagToOccupied = lookupBagTo.GetSlotDatas(optionalSingleItemLink)
				if mayOverrideBagToVirtual then
					bagToOccupiedOverride = lookupBagToVirtual.GetSlotDatas(optionalSingleItemLink)
				end
			end

			-- slotDatas is still linked to bagFromOccupied, this potentially has <unforseen consequences>
			-- GetSlotDatas' returned table (here child-table-of-tables: slotDatas) must not be written to!
			for itemLinkForSorting, slotDatas in pairs(bagFromOccupied) do
				local overrideToVirtual = mayOverrideBagToVirtual and CanItemLinkBeVirtual(itemLinkForSorting)
				local finalBagTo = (overrideToVirtual and BAG_VIRTUAL) or bagTo
				local finalBagToOccupied = (overrideToVirtual and bagToOccupiedOverride) or bagToOccupied
				-- d(taskId)
				-- slotDatas.count can be nil when the craftBag sucks the item after laundering out of the bag
				if(checkProgress[itemLinkForSorting] == nil and slotDatas.count~=nil) then
					local bagToCount = {}
					if(finalBagToOccupied[itemLinkForSorting] ~= nil) then
						-- d('bagToCalc')
						-- d(finalBagToOccupied[itemLinkForSorting])
						bagToCount = finalBagToOccupied[itemLinkForSorting].count or {}
					end
					bagToCount = bagToCount[finalBagTo] or 0
					-- GetSlotDatas' returned table (here child-table-of-tables: slotDatas) must not be written to!
					local slotFromDatas
					status, slotFromDatas = GetSlotFromDatas(slotDatas, finalBagTo, bagToCount)
					if(status) then
						-- d("1+++++" .. itemLinkForSorting)
						-- d(slotFromDatas)
						-- d("2+++++" .. itemLinkForSorting)
						-- d(slotDatas)
						-- d("3+++++" .. itemLinkForSorting)
						-- d(bagFromOccupied[itemLinkForSorting])
						-- d("4+++++" .. itemLinkForSorting)
						for i, slotFromData in pairs(slotFromDatas) do
							local authorizedAmount = -slotFromData.stackCountChange
							if(RbI.testrun == false) then
								local remainingAmount = task.DoAction(taskId, itemLinkForSorting, slotFromData, bagFrom, finalBagTo)
								if(remainingAmount < authorizedAmount) then
									--d(taskId .. " executed " .. (authorizedAmount - remainingAmount) .. 'x ' .. slotFromData.itemLink)
									actionCount = actionCount + 1
								end
								if(remainingAmount > 0 and (remainingAmount > 10 or taskId ~= 'Refine')) then
									-- bagTo is full, suspend this task, look for other task
									--d(taskId .. " bagTo is full...")
									finished = false
									break
								else
									-- if itemLink has been successful checked, skip it next time if self call happens
									checkProgress[itemLinkForSorting] = true
								end
							else
								RbI.AddMessageToQueue('Task ' .. taskId, taskId, RbI.testrun, slotFromData.itemLink, authorizedAmount, false)
								if(authorizedAmount > 0) then
									actionCount = actionCount + 1
								end
							end
						end
					else
						-- an error occured in a rule
						break
					end
				end
			end
		else
			actionCount = 0
		end
		-- clear up
		RbI.ClearLookup(bagFrom)
		RbI.ClearLookup(bagTo)
		Finish(optionalSingleItemLink, status, finished)
		return status, finished, actionCount
	end

	local function CheckBySlot(itemRef, stackCountChange)
		local status = true
		local actionCount = 0
		local bag = itemRef.bag
		local slot = itemRef.slot
		local itemLink = itemRef:GetItemLink()

		if(RbI.RuleSet.HasRules(taskId)) then
			local itemLinkForSorting = itemRef:GetItemLinkForSorting()
			local result, resultInv
			status, result, resultInv = Evaluate(bag, slot, itemLink)
			if(status and result and not resultInv) then
				local stackCount = GetSlotStackSize(bag, slot)
				stackCountChange = -(stackCountChange or stackCount)
				local slotFromData = {stackCountChange = stackCountChange, itemLink = itemLink, bag = bag, slot = slot, stack = stackCount}
				task.DoAction(taskId, itemLinkForSorting, slotFromData, bag)
				actionCount = actionCount + 1
			end
		end
		local finished = true
		Finish(itemLink, status, finished)
		return status, finished, actionCount
	end

	return {
		CheckBySlot = CheckBySlot,
		CheckByItemLink = CheckByItemLink,
	}
end