-- Addon
ChallengeModeSelector = ChallengeModeSelector or {}
local CMS = ChallengeModeSelector

-- Modules
CMS.EventManager = CMS.EventManager or {}
local EventManager = CMS.EventManager
local GroupMenu = CMS.GroupMenu
local SidePanel = CMS.SidePanel

-- State
EventManager.registered = false

-- Main
do
	local function RefreshUI()
		GroupMenu.Refresh()
		SidePanel.Refresh()
	end

	local function OnOverlandDifficultyChanged(_, new_difficulty_id)
		-- Check if we requested the change
		local pending_difficulty = GroupMenu.pending_difficulty
		GroupMenu.pending_difficulty = nil
		if pending_difficulty and pending_difficulty.id == new_difficulty_id then
			-- Difficulty change success
			local difficulty = pending_difficulty
			-- Play appropriate sound
			PlaySound(difficulty.sound)
			
		end
		-- Refresh UI anyway
		RefreshUI()
		-- Done
	end

	function EventManager.RegisterEvents()
		if EventManager.registered then
			return
		end
		EventManager.registered = true

		EVENT_MANAGER:RegisterForEvent(CMS.Name, EVENT_OVERLAND_DIFFICULTY_CHANGED, OnOverlandDifficultyChanged)
		EVENT_MANAGER:RegisterForEvent(CMS.Name, EVENT_PLAYER_COMBAT_STATE, RefreshUI)
		EVENT_MANAGER:RegisterForEvent(CMS.Name, EVENT_PLAYER_ACTIVATED, RefreshUI)

		EVENT_MANAGER:RegisterForEvent(CMS.Name, EVENT_ZONE_UPDATE, function(event, unit_tag)
			local is_group_unit = ZO_Group_IsGroupUnitTag(unit_tag)
			if unit_tag == "player" or is_group_unit then
				RefreshUI()
			end
		end)

		GROUP_LIST_FRAGMENT:RegisterCallback("StateChange", function(old_state, new_state)
			if new_state == SCENE_FRAGMENT_SHOWING or new_state == SCENE_FRAGMENT_SHOWN then
				RefreshUI()
			elseif new_state == SCENE_FRAGMENT_HIDDEN then
				SidePanel.RequestHide()
			end
		end)

		STATS_SCENE:RegisterCallback("StateChange", function(old_state, new_state)
			if new_state == SCENE_SHOWING then
				SidePanel.requested = false
				SidePanel.UpdateVisibility()
				zo_callLater(SidePanel.UpdateVisibility, 50)
			elseif new_state == SCENE_HIDING or new_state == SCENE_HIDDEN then
				SidePanel.UpdateVisibility()
			end
		end)
	end
end
