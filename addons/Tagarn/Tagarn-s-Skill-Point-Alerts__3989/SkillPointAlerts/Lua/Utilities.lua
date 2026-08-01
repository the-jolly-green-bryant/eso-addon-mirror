-- Copyright (c) 2025 by Tagarn

-- This add-on may be copied, shared, and used as-is while playing Elder
-- Scrolls Online, provided this notice is left intact. However, this
-- add-on, in part or in full, may not be used in the creation of other
-- add-ons without the express written consent of Tagarn.

-- The Elder Scrolls Online add-on provided by Tagarn ("we," "us," or "our")
-- is for entertainment purposes only. UNDER NO CIRCUMSTANCE SHALL WE HAVE ANY
-- LIABILITY TO YOU FOR ANY LOSS OR DAMAGE OF ANY KIND INCURRED AS A RESULT OF
-- THE USE OF OUR ADD-ON. YOUR USE OF OUR ADD-ON IS SOLELY AT YOUR OWN RISK.

SkillPointAlerts = SkillPointAlerts or {}
local SPA = SkillPointAlerts

local Utilities = {}

-- From: https://stackoverflow.com/a/26367080
function Utilities.DeepCopy(obj, seen)
	if type(obj) ~= 'table' then 
		return obj 
	end

	if (seen and seen[obj]) then
		return seen[obj] 
	end

	local s = seen or {}
	local res = setmetatable({}, getmetatable(obj))
	s[obj] = res

	for k, v in pairs(obj) do 
		res[Utilities.DeepCopy(k, s)] = Utilities.DeepCopy(v, s) 
	end

	return res
  end

  function Utilities.IsInTable(object, table)
	for k, v in pairs(table) do
		if ( object == v ) then
			return true
		end
	end
	return false
  end

  SkillPointAlerts.U = Utilities