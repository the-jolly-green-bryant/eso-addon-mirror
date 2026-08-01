-----------------------------------------------------------------------------------
-- Addon Name: Rulebased Inventory
-- Creator: TaxTalis
-- Addon Ideal: user-defined rule-based actions for inventory application
-- Addon Creation Date: September 11, 2018
--
-- File Name: Rule.lua
-- File Description: This file contains the functions to create, edit and delete set of rules
-- Load Order Requirements: after Rules, before Task, before Profile
-- 
-----------------------------------------------------------------------------------

local RbI = RulebasedInventory
local ruleEnv = RbI.ruleEnvironment

function RbI.RuleSet()
	local self = {}
	self.currents = nil
	self.ruleSets = nil
	-- currents = {[taskName] = {ruleSetName = '', ruleSet = {[ruleName] = level, ...}}, ...}
	-- ruleSets = {[ruleSetName] = {[ruleName] = level, ...}, ...}
	
	local function GetCurrentRuleSetName(taskName)
		local ruleSetName
		if(self.currents[taskName] ~= nil) then
			ruleSetName = self.currents[taskName].ruleSetName
		end
		return ruleSetName
	end
	
	local function GetList()
		local list = {}
		for ruleSetName in pairs(self.ruleSets) do
			table.insert(list, ruleSetName)
		end
		return list
	end
	
	local function Exists(ruleSetName)
		return self.ruleSets[ruleSetName] ~= nil or self.ruleSets[string.lower(ruleSetName)] ~= nil
	end
	
	local function Comparator(ruleSet1, ruleSet2)
		if(type(ruleSet1) ~= type(ruleSet2)) then
			return false
		end
		if(ruleSet1~=nil) then
			for ruleName, level in pairs(ruleSet1) do
				if(ruleSet2[ruleName] ~= level) then
					return false
				end
			end
		end
		return true
	end
	
	local function IsLikeCurrent(taskName, ruleSetName)
		if(not self.currents[taskName]) then
			return false
		end
		if(self.currents[taskName].ruleSetName == ruleSetName) then
			return true
		end
		
		return Comparator(self.currents[taskName].ruleSet, self.ruleSets[ruleSetName]) 
		  and Comparator(self.ruleSets[ruleSetName], self.currents[taskName].ruleSet)
	end
	
	
	-- make a complete copy of the ruleSet data, overwriting destination with source
	-- without erasing the pointer of the original destination
	local function Copy(source, destination)
		for ruleName in pairs(destination) do
			destination[ruleName] = nil
		end
		for ruleName, level in pairs(source or {}) do
			destination[ruleName] = level
		end
	end
	
	-- loads the ruleSet to be the currently active settings for task
	local function Load(taskName, ruleSetName)
		if(taskName ~= nil and ruleSetName ~= nil) then
			self.currents[taskName] = self.currents[taskName] or {}
			self.currents[taskName].ruleSetName = ruleSetName
			self.currents[taskName].ruleSet = self.currents[taskName].ruleSet or {}
			local source, destination = self.ruleSets[ruleSetName], self.currents[taskName].ruleSet
			Copy(source, destination)
			RbI.Profile.Save()
		end
	end
	
	-- saves the currently active settings into the ruleSet (possibly create new one)
	local function Save(taskName, ruleSetName)
		if(taskName ~= nil) then
			self.currents[taskName] = self.currents[taskName] or {}
			self.currents[taskName].ruleSetName = ruleSetName
			if(ruleSetName ~= nil) then
				self.ruleSets[ruleSetName] = self.ruleSets[ruleSetName] or {}
				local source, destination = self.currents[taskName].ruleSet, self.ruleSets[ruleSetName]
				Copy(source, destination)
			end
		end
	end
	
	local function Delete(ruleSetName)
		self.ruleSets[ruleSetName] = nil
		RbI.Profile.Validate(ruleSetName)
	end
	
	local function AddRule(taskName, ruleName, level)
		self.currents[taskName] = self.currents[taskName] or {}
		self.currents[taskName].ruleSetName = nil
		self.currents[taskName].ruleSet = self.currents[taskName].ruleSet or {}
		self.currents[taskName].ruleSet[ruleName] = level or 1
		RbI.Profile.Save()
	end

	local function RemoveRule(taskName, ruleName)
		if(self.currents[taskName] ~= nil
		  and self.currents[taskName].ruleSet ~= nil) then
			self.currents[taskName].ruleSetName = nil
			self.currents[taskName].ruleSet[ruleName] = nil
			RbI.Profile.Save()
		end
	end
	
	local function RemoveAllRules(taskName)
		if(self.currents[taskName] ~= nil
		  and self.currents[taskName].ruleSet ~= nil) then
			for ruleName in pairs(self.currents[taskName].ruleSet) do
				RemoveRule(taskName, ruleName)
			end
		end
	end

	local function GetAvailableRules(taskName, selectedLevel)
		local rules = {}
		for ruleName in pairs(RbI.account.rules) do
			if(self.currents[taskName] == nil
			  or self.currents[taskName].ruleSet == nil
			  or self.currents[taskName].ruleSet[ruleName] == nil 
			  or selectedLevel == nil 
			  or self.currents[taskName].ruleSet[ruleName] ~= selectedLevel) then
				table.insert(rules, ruleName)
			end
		end
		return rules
	end
	
	local function GetRules(taskName, selectedLevel)
		local rules = {}
		if(self.currents[taskName] ~= nil 
		  and self.currents[taskName].ruleSet ~= nil) then
			for ruleName, level in pairs(self.currents[taskName].ruleSet) do
				if(selectedLevel == nil or selectedLevel == level) then
					table.insert(rules, ruleName)
				end
			end
		end
		return rules
	end

	local function IsImplicitOppositeTask(taskId)
		return not RbI.tasks.GetTask(taskId).IsUserTask()
	end
	
	local function HasRules(taskId)
		return (#GetRules(taskId) > 0) or IsImplicitOppositeTask(taskId)
	end
	
	local function RenameRuleReferences(ruleName, ruleNameRename)
		for taskName, ruleSetData in pairs(self.currents) do
			if(ruleSetData.ruleSet ~= nil) then
				RbI.rename(ruleSetData.ruleSet, ruleName, ruleNameRename)
			end
		end
		for ruleSetName, ruleSet in pairs(self.ruleSets) do
			RbI.rename(ruleSet, ruleName, ruleNameRename)
		end
	end

	local function DeleteRuleReferences(ruleName)
		RenameRuleReferences(ruleName, nil)
	end

    -- checks the rulesets for lost references
	local function ValidateCheck()
		for taskName, ruleSetData in pairs(self.currents) do
			if(ruleSetData.ruleSet ~= nil) then
				for ruleName in pairs(ruleSetData.ruleSet) do
					if(RbI.rules.user[ruleName:lower()] == nil) then
						self.currents[taskName].ruleSet[ruleName] = nil
					end
				end
			end
		end
		for ruleSetName, ruleSet in pairs(self.ruleSets) do
			for ruleName in pairs(ruleSet) do
				if(RbI.rules.user[ruleName:lower()] == nil) then
					self.ruleSets[ruleSetName][ruleName] = nil
				end
			end
		end
	end

	local function Validate(ruleName)
		if(ruleName ~= nil) then
			DeleteRuleReferences(ruleName)
		else
			ValidateCheck()
		end
		RbI.Profile.Validate(nil, ruleName)
	end

	-- @return status: boolean. 'false' if an error occured (from the task or a potential opposingTask)
	-- @return result: boolean. The result for this item.
	local function Evaluate(taskName, bag, slot, itemLink)
		if(IsImplicitOppositeTask(taskName)) then
			return true, true
		end
		if(self.currents[taskName] == nil
		  or HasRules(taskName) == false) then
			return true, false
		end
		local status = true
		local result = false
		for ruleName, level in pairs(self.currents[taskName].ruleSet) do
			if(level == RbI.FIT_ALL) then
				status, result = ruleEnv.RunRuleWithItem(RbI.rules.user[ruleName:lower()], bag, slot, itemLink, taskName)
				if(status == false or result == false) then
					-- an error occured in a rule
					-- or the rule failed
					return status, result
				end
			end
		end
		result = true -- if no rules in level 2 return true
		for ruleName, level in pairs(self.currents[taskName].ruleSet) do
			if(level == RbI.FIT_ANY) then
				status, result = ruleEnv.RunRuleWithItem(RbI.rules.user[ruleName:lower()], bag, slot, itemLink, taskName)
				if(status == false or result) then
					return status, result
				end
			end
		end
		-- status is true otherwise would have been returned by now
		-- result is either true from "no rules for level 2" or false from last iteration in level 2
		return status, result
	end
	
	local function Initialize(characterRuleSets, accountRuleSets)
		self.currents = characterRuleSets
		for taskName in pairs(RbI.tasks.GetAllTasks()) do
			self.currents[taskName] = self.currents[taskName] or {}
		end
		
		self.ruleSets = accountRuleSets
		return {Save = Save
			   ,Load = Load
			   ,Exists = Exists
			   ,Delete = Delete
			   ,GetList = GetList
			   ,AddRule = AddRule
			   ,HasRules = HasRules
			   ,Validate = Validate
			   ,GetRules = GetRules
			   ,Evaluate = Evaluate
			   ,RemoveRule = RemoveRule
			   ,IsLikeCurrent = IsLikeCurrent
			   ,RemoveAllRules = RemoveAllRules
			   ,GetAvailableRules = GetAvailableRules
			   ,GetCurrentRuleSetName = GetCurrentRuleSetName
			, RenameRuleReferences = RenameRuleReferences
		}
	end
	
	return {Initialize = Initialize}
end