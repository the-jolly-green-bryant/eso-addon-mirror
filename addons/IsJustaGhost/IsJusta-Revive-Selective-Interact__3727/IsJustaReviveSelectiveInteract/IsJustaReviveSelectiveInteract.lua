--[[
- - -1.2.1
○ fixed a typo causing an error.

- - -1.2
○ fixed error from extra )
○ added check to EVENT_UNIT_DEATH_STATE_CHANGED to ensure it only tracks group members
○ unregisters EVENT_PLAYER_ACTIVATED

- - -1.1 
○ fixed typo in manifest
○ will now check for dead group members on player activated.
]]

local name = 'IsJustaReviveSelectiveInteract'
local revivePending = {}

ZO_PreHook(PLAYER_TO_PLAYER, 'StartInteraction', function(self)
	if not IsUnitGrouped("player") then return end
	if IsUnitInCombat("player") and not self.resurrectable then
		for unitTag, isDead in pairs(revivePending) do
			if isDead and IsUnitInGroupSupportRange(unitTag) then
				return true
			end
		end
	end
end)

EVENT_MANAGER:RegisterForEvent(name, EVENT_UNIT_DEATH_STATE_CHANGED, function(_, unitTag, isDead)
	-- Make sure the unit is in your group
    if UNIT_FRAMES:GetFrame(unitTag) then
		revivePending[unitTag] = isDead or nil
    end
end)

EVENT_MANAGER:RegisterForEvent(name, EVENT_PLAYER_ACTIVATED, function()
	EVENT_MANAGER:UnregisterForEvent(name, EVENT_PLAYER_ACTIVATED)
	for i = 1, MAX_GROUP_SIZE_THRESHOLD do
		local unitTag = ZO_Group_GetUnitTagForGroupIndex(i)
		if DoesUnitExist(unitTag) then
			revivePending[unitTag] = IsUnitDead(unitTag) or nil
		end
	end
end)