--
-- Calamath's Shortcut Pie Menu [CSPM]
--
-- Copyright (c) 2021 Calamath
--
-- This software is released under the Artistic License 2.0
-- https://opensource.org/licenses/Artistic-2.0
--

if not LibCPieMenu then return end
local LCPM = LibCPieMenu:SetSharedEnvironment()
-- ---------------------------------------------------------------------------------------
local L = GetString
local LAM = LibAddonMenu2

-- ---------------------------------------------------------------------------------------
-- Adjustable Initializing Object Template Class                                 rel.1.0.2
-- ---------------------------------------------------------------------------------------
-- In general, object attributes should be closed internally. This template class is an exception, as it is adjustable through an external attribute table.
-- The intended use is that the external attribute table is a subset of the internal attribute table and is primarily stored within the save data variables.

CT_AdjustableInitializingObject = ZO_InitializingObject:Subclass()
function CT_AdjustableInitializingObject:Initialize(overriddenAttrib)
	self._attrib = self._attrib or {}
	self._overriddenAttrib = overriddenAttrib or {}
	self._hasOverriddenAttrib = overriddenAttrib ~= nil
end
--[[
function CT_AdjustableInitializingObject:RegisterOverriddenAttributeTable(overriddenAttrib)
	-- If the external attribute table not be specified in the constructor, it could be registered with this method only once.
	if self._hasOverriddenAttrib or type(overriddenAttrib) ~= "table" then
		return false
	else
		self._overriddenAttrib = overriddenAttrib
		self._hasOverriddenAttrib = true
		return true
	end
end
]]
function CT_AdjustableInitializingObject:GetAttribute(key)
	if self._overriddenAttrib[key] ~= nil then
		return self._overriddenAttrib[key]
	else
		return self._attrib[key]
	end
end

function CT_AdjustableInitializingObject:SetAttribute(key, value)
	if self._overriddenAttrib[key] ~= nil then
		self._overriddenAttrib[key] = value
	else
		self._attrib[key] = value
	end
end

function CT_AdjustableInitializingObject:SetAttributes(attributeTable)
	if type(attributeTable) ~= "table" then return end
	for k, v in pairs(attributeTable) do
		self:SetAttribute(k, v)
	end
end

function CT_AdjustableInitializingObject:ResetAttributeToDefault(key)
	if self._attrib[key] and self._overriddenAttrib[key] then
		self._overriddenAttrib[key] = self._attrib[k]
	end
end

function CT_AdjustableInitializingObject:ResetAllAttributesToDefaults()
	for k, v in pairs(self._overriddenAttrib) do
		if self._attrib[k] then
			self._overriddenAttrib[k] = self._attrib[k]
		end
	end
end

