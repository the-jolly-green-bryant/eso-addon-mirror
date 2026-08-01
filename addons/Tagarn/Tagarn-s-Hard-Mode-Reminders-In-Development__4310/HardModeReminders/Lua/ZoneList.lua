-- Copyright (c) 2025 by Tagarn

-- This add-on may be copied, shared, and used as-is while playing Elder
-- Scrolls Online, provided this notice is left intact. However, this
-- add-on, in part or in full, may not be used in the creation of other
-- add-ons without the express written consent of Tagarn.

-- The Elder Scrolls Online add-on provided by Tagarn ("we," "us," or "our")
-- is for entertainment purposes only. UNDER NO CIRCUMSTANCE SHALL WE HAVE ANY
-- LIABILITY TO YOU FOR ANY LOSS OR DAMAGE OF ANY KIND INCURRED AS A RESULT OF
-- THE USE OF OUR ADD-ON. YOUR USE OF OUR ADD-ON IS SOLELY AT YOUR OWN RISK.

ZoneList = ZoneList or {}
local ZL = ZoneList
local HMR = HardModeReminders



function ZL:New(control)
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o:Initialize(control)
	return o
end

function ZL:Initialize(control)
	self.control = control

	self:InitializeZoneList()
end

function ZL:InitializeZoneList()
    ZO_ScrollList_AddDataType(self.control, 1, "TSUB_Skills_AbilityWithMorphs", HMR.ZONE_LIST_HEIGHT, function(control, data)

	end)
    ZO_ScrollList_AddDataType(self.control, 1, "ZO_Skills_AbilityTypeHeader", HMR.ZONE_LIST_HEIGHT, function(control, data)
---@diagnostic disable-next-line: undefined-field
		control:GetNamedChild("Label"):SetText(data.headerText)
    end)
end