-----------------------------------------------------------------------------------
-- Addon Name: Rulebased Inventory
-- Creator: TaxTalis
-- Addon Ideal: user-defined rule-based actions for inventory application
-- Addon Creation Date: September 11, 2018
--
-- File Name: Rule.lua
-- File Description: This file contains the functions to create, compile and evaluate user-written rules
-- Load Order Requirements: before Loader
-- 
-----------------------------------------------------------------------------------

local RbI = RulebasedInventory
local ruleEnv = RbI.ruleEnvironment
RbI.rules = RbI.rules or {}
RbI.rules.user = RbI.rules.user or {} -- for user-defined rules
RbI.rules.internal = RbI.rules.internal or {} -- for internal rules (and inverted user-defines)

-- base rule modell without saving/loading functions
function RbI.BaseRule(name, userdefined, content)
	local self = {}
	self.name = name
	self.content = nil
	self.Rule = nil
	self.CompileError = nil

	function self.Compile()
		self.Rule, self.CompileError = ruleEnv.Compile(self.content)
		if(self.CompileError) then
			self.CompileError = self.CompileError:sub(18)
		end
	end

	function self.GetName()
		return self.name
	end

	function self.Evaluate()
		local result = false
		if(self.content ~= '') then
			result = self.Rule()
		elseif(userdefined == false) then
			result = true
		end
		return result
	end

	function self.GetContent()
		return self.content
	end

	function self.SetContent(content)
		self.content = content or ''
		self.Compile()
	end

	function self.GetCompileError()
		return self.CompileError
	end

	self.SetContent(content)

	return self
end

-- extends RbI.Rule with automatic saving/loading
function RbI.PersistentRule(name, content)
	local super = RbI.BaseRule(name, true, content)

	local function SetContent(content)
		if(content ~= nil and string.find(content, "%a")) then
			super.SetContent(content)
		else
			super.content = '' --prevents rule from evaluating
		end
		RbI.account.rules[super.name] = super.content
	end
	
	local function Delete()
		RbI.rules.user[super.name:lower()] = nil
		RbI.account.rules[super.name] = nil
		RbI.RuleSet.Validate(super.name)
	end

	local function Rename(to)
		super.name = to
	end
	
	local function Initialize()
		local rules = RbI.rules.user
		local loweredName = super.name:lower()
		if(rules[loweredName] == nil) then
			SetContent(content)
			rules[loweredName] = {GetName = super.GetName
							   ,Delete = Delete
				               ,Rename = Rename
							   ,Evaluate = super.Evaluate
							   ,GetContent = super.GetContent
							   ,SetContent = SetContent
							   ,GetCompileError = super.GetCompileError
			}
		else
			rules[loweredName].SetContent(content)
		end
	end
	
	Initialize()
end


