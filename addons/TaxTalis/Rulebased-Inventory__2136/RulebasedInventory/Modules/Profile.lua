-----------------------------------------------------------------------------------
-- Addon Name: Rulebased Inventory
-- Creator: TaxTalis
-- Addon Ideal: user-defined rule-based actions for inventory application
-- Addon Creation Date: September 11, 2018
--
-- File Name: Profile.lua
-- File Description: This file contains the functions to save and set profiles
-- Load Order Requirements: after Rule, after RuleSet, after Task, before Loader
-- 
-----------------------------------------------------------------------------------

local RbI = RulebasedInventory
local utils = RbI.Import(RbI.utils)

function RbI.Profile()
	local self = {}
	self.current = nil
	self.profiles = nil
	-- current = {profileName = '', profile = {[taskName] = {ruleSetName = '', ruleSet = {[ruleName] = level}}, ...}}
	-- profiles = {[profileName] = {taskName = {ruleSetName = '', ruleSet = {[ruleName] = level}}, ...}}
	
	local function GetCurrentProfileName()
		return self.current.profileName
	end
	
	local function GetList()
		local list = {}
		for profileName in pairs(self.profiles) do
			table.insert(list, profileName)
		end
		return list
	end
	
	local function Exists(profileName)
		return self.profiles[profileName] ~= nil or self.profiles[string.lower(profileName)] ~= nil
	end
	
	local function Comparator(profile1, profile2)
		for taskName in pairs(RbI.tasks.GetAllTasks()) do
			if(type(profile1[taskName]) ~= type(profile2[taskName])) then
				return false
			end
			if(profile1[taskName] ~= nil) then
				if(profile1[taskName].ruleSetName ~= profile2[taskName].ruleSetName) then
					return false
				elseif(profile1[taskName].ruleSetName == nil) then
					if(type(profile1[taskName].ruleSet) ~= type(profile2[taskName].ruleSet)) then
						return false
					end
					if(profile1[taskName].ruleSet ~= nil) then
						for ruleName, level in pairs(profile1[taskName].ruleSet) do
							if(profile2[taskName].ruleSet[ruleName] ~= level) then
								return false
							end
						end
					end
				end
			end
		end
		return true
	end
	
	local function IsLikeCurrent(profileName)
		if(self.current.profileName == profileName) then return true end
		
		return Comparator(self.current.profile, self.profiles[profileName]) 
		  and Comparator(self.profiles[profileName], self.current.profile)
	end
	
	-- make a complete copy of the profile data, overwriting destination with source
	-- without erasing the pointer of the original destination
	local function Copy(source, destination)
		utils.clear(destination)
		utils.cloneDeep(source, destination)
	end
	
	-- loads the profile to be the currently active settings
	local function Load(profileName)
		if(profileName ~= nil) then
			local source, destination = self.profiles[profileName], self.current.profile
			Copy(source, destination)
			for taskName, ruleSetData in pairs(source) do
				if(ruleSetData.ruleSetName ~= nil) then
					RbI.RuleSet.Load(taskName, ruleSetData.ruleSetName)
				end
			end
			self.current.profileName = profileName
		else -- reload current profile from ruleSet if exists
			for taskName, ruleSetData in pairs(self.current.profile) do
				if(ruleSetData.ruleSetName ~= nil) then
					RbI.RuleSet.Load(taskName, ruleSetData.ruleSetName)
				end
			end
		end
	end
	
	-- saves the currently active settings into the profile (possibly create new one)
	local function Save(profileName)
		self.current.profileName = profileName
		if(profileName ~= nil) then
			self.profiles[profileName] = self.profiles[profileName] or {}
			local source, destination = self.current.profile, self.profiles[profileName]
			Copy(source, destination)
		end
	end
	
	local function Delete(profileName)
		if(self.current.profileName == profileName) then
			self.current.profileName = nil
		end
		self.profiles[profileName] = nil
	end

	local function DeleteRuleSetReferences(ruleSetName)
		for taskName, ruleSetData in pairs(self.current.profile) do
			if(ruleSetData.ruleSetName == ruleSetName) then
				self.current.profile[taskName].ruleSetName = nil
			end
		end
		for profileName, profile in pairs(self.profiles) do
			for taskName, ruleSetData in pairs(profile) do
				if(ruleSetData.ruleSetName == ruleSetName) then
					self.profiles[profileName][taskName].ruleSetName = nil
				end
			end
		end
	end

	local function RenameRuleReferences(ruleName, ruleNameNew)
		RbI.class.CharacterSetting.New(nil, nil, self.current).RenameRule(ruleName, ruleNameNew)
		for _, profile in pairs(self.profiles) do
			RbI.class.CharacterSetting.New(nil, nil, {profile=profile}).RenameRule(ruleName, ruleNameNew)
		end
	end

	local function DeleteRuleReferences(ruleName)
		RenameRuleReferences(ruleName, nil)
	end

	local function ValidateCheck()
		for taskName, ruleSetData in pairs(self.current.profile) do
			if(RbI.RuleSet.Exists(ruleSetData.ruleSetName) == false) then
				self.current.profile[taskName].ruleSetName = nil
			end
			for ruleName in pairs(ruleSetData.ruleSet or {}) do
				if(RbI.rules.user[ruleName:lower()] == nil) then
					self.current.profile[taskName].ruleSet[ruleName] = nil
				end
			end
		end

		for profileName, profile in pairs(self.profiles) do
			for taskName, ruleSetData in pairs(profile) do
				if(RbI.RuleSet.Exists(ruleSetData.ruleSetName) == false) then
					self.profiles[profileName][taskName].ruleSetName = nil
				end
				for ruleName in pairs(ruleSetData.ruleSet or {}) do
					if(RbI.rules.user[ruleName:lower()] == nil) then
						self.profiles[profileName][taskName].ruleSet[ruleName] = nil
					end
				end
			end
		end
	end

	local function Validate(ruleSetName, ruleName)
		if(ruleSetName == nil and ruleName == nil) then
			ValidateCheck()
		elseif(ruleSetName ~= nil) then
			DeleteRuleSetReferences(ruleSetName)
		else
			DeleteRuleReferences(ruleName)
		end
	end

	local function Initialize(characterProfile, accountProfiles)
		self.current = characterProfile
		self.profiles = accountProfiles
		return {Save = Save
			   ,Load = Load
			   ,Exists = Exists
			   ,Delete = Delete
			   ,GetList = GetList
			   ,Validate = Validate
			   ,IsLikeCurrent = IsLikeCurrent
			   ,GetCurrentProfileName = GetCurrentProfileName
			, RenameRuleReferences = RenameRuleReferences
		}
	end
	
	return {Initialize = Initialize}
end