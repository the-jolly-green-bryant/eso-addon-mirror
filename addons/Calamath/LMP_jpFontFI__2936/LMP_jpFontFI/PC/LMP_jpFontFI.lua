--
-- LMP_jpFontFI
--
-- Copyright (c) 2021 Calamath
--
-- This software is released under the Artistic License 2.0
-- https://opensource.org/licenses/Artistic-2.0
-- The bundled fonts conform to the license specified in the file in each sub-folder containing the fonts.
--

-- ---------------------------------------------------------------------------------------
-- CT_MinimalAddonFramework: Minimal Add-on Framework Template Class            rel.1.1.12
-- ---------------------------------------------------------------------------------------
local CT_MinimalAddonFramework = ZO_Object:Subclass()
function CT_MinimalAddonFramework:New(...)
	local newObject = setmetatable({}, self)
	newObject:Initialize(...)
	newObject:ConfigDebug()
	newObject:OnInitialized(...)
	return newObject
end
function CT_MinimalAddonFramework:Initialize(name, attributes)
	if type(name) ~= "string" or name == "" then return end
	self._name = name
	self._isInitialized = false
	if type(attributes) == "table" then
		for k, v in pairs(attributes) do
			if self[k] == nil then
				self[k] = v
			end
		end
	end
	self._external = {
		name = self.name or self._name, 
		version = self.version, 
		author = self.author, 
	}
	assert(not _G[name], name .. " is already loaded.")
	_G[name] = self._external
	EVENT_MANAGER:RegisterForEvent(self._name, EVENT_ADD_ON_LOADED, function(event, addonName)
		if addonName ~= self._name then return end
		EVENT_MANAGER:UnregisterForEvent(self._name, EVENT_ADD_ON_LOADED)
		self:OnAddOnLoaded(event, addonName)
		self._isInitialized = true
	end)
end
function CT_MinimalAddonFramework:ConfigDebug()
	local Dummy = function() end
	self.LDL = { Verbose = Dummy, Debug = Dummy, Info = Dummy, Warn = Dummy, Error = Dummy, }
	self._isDebugMode = false
end
function CT_MinimalAddonFramework:OnInitialized(name, attributes)
--  Available when overridden in an inherited class
end
function CT_MinimalAddonFramework:OnAddOnLoaded(event, addonName)
--  Should be Overridden
end


-- ---------------------------------------------------------------------------------------
-- LMP_jpFontFI
-- ---------------------------------------------------------------------------------------
local FontAddonFramework = CT_MinimalAddonFramework:Subclass()
function FontAddonFramework:OnInitialized()
	local LMP = LibMediaProvider
	if LMP then
		LMP:Register("font", "DotGothic16-R", "$(DOTGOTHIC16_R_FONT)")		-- DotGothic16-Regular
--		LMP:Register("font", "KleeOne-R", "$(KLEE_ONE_R_FONT)")				-- KleeOne-Regular
		LMP:Register("font", "KleeOne-B", "$(KLEE_ONE_B_FONT)")				-- KleeOne-SemiBold
--		LMP:Register("font", "RampartOne-R", "$(RAMPART_ONE_R_FONT)")		-- RampartOne-Regular
		LMP:Register("font", "ReggaeOne-R", "$(REGGAE_ONE_R_FONT)")			-- ReggaeOne-Regular
		LMP:Register("font", "RocknRollOne-R", "$(ROCKNROLL_ONE_R_FONT)")	-- RocknRollOne-Regular
		LMP:Register("font", "Stick-R", "$(STICK_R_FONT)")					-- Stick-Regular
--		LMP:Register("font", "TrainOne-R", "$(TRAIN_ONE_R_FONT)")			-- TrainOne-Regular
	end
end

local JP_FONT_FI = FontAddonFramework:New("LMP_jpFontFI", {
	name = "LMP_jpFontFI", 
	version = "2.2.0", 
	author = "Calamath", 
--	authority = {2973583419,210970542}, 
})

