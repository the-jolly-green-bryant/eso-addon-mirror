local function OnAddOnLoaded(event, addonName)
	if addonName ~= GROUP_SYNERGIZER.name then return end
	
	--Saved Variables
	GROUP_SYNERGIZER.savedVariables = ZO_SavedVars:NewAccountWide("GroupSynergizerSavedVars", GROUP_SYNERGIZER.variableVersion, nil, GROUP_SYNERGIZER.defaults, GetWorldName()) --ZO_SavedVars:New("GroupSynergizerSavedVars", 1, nil, GROUP_SYNERGIZER.defaults)
	GROUP_SYNERGIZER.Enable 		= GROUP_SYNERGIZER.savedVariables.Enable
	GROUP_SYNERGIZER.SoundNotify 	= GROUP_SYNERGIZER.savedVariables.SoundNotify
	GROUP_SYNERGIZER.ScreenNotify 	= GROUP_SYNERGIZER.savedVariables.ScreenNotify
	GROUP_SYNERGIZER.AutoRelease 	= GROUP_SYNERGIZER.savedVariables.AutoRelease
	GROUP_SYNERGIZER.AutoAccept 	= GROUP_SYNERGIZER.savedVariables.AutoAccept
	GROUP_SYNERGIZER.NotifyDelay 	= GROUP_SYNERGIZER.savedVariables.NotifyDelay
	GROUP_SYNERGIZER.EnhanceGAF 	= GROUP_SYNERGIZER.savedVariables.EnhanceGAF
	GROUP_SYNERGIZER.SlashCommands 	= GROUP_SYNERGIZER.savedVariables.SlashCommands
	GROUP_SYNERGIZER.firstRun 		= GROUP_SYNERGIZER.savedVariables.firstRun

	--Slash Commands
	if GROUP_SYNERGIZER.SlashCommands then
		SLASH_COMMANDS["/pledges"] 		= GROUP_SYNERGIZER.DailyPledges
		SLASH_COMMANDS["/pledge"] 		= GROUP_SYNERGIZER.DailyPledges
		SLASH_COMMANDS["/pl"] 			= GROUP_SYNERGIZER.DailyPledges
		SLASH_COMMANDS["/leave"] 		= GROUP_SYNERGIZER.leaveGroup
		SLASH_COMMANDS["/lv"] 			= GROUP_SYNERGIZER.leaveGroup
	end

	--Settings
	GROUP_SYNERGIZER.CreateSettingsWindow()

	--Pledges
	GROUP_SYNERGIZER.Pledges()

	--Battlegrounds
	GROUP_SYNERGIZER.Battlegrounds()

	--Unregister Addon Load
	GROUP_SYNERGIZER.eventManager:UnregisterForEvent(GROUP_SYNERGIZER.name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(
	GROUP_SYNERGIZER.name.."_OnPlayerActivated", EVENT_PLAYER_ACTIVATED,
	function ()
		if not GROUP_SYNERGIZER.firstRun then
			GROUP_SYNERGIZER.firstRun = true
			GROUP_SYNERGIZER.savedVariables.firstRun = true
			DoCommand("/gs")
		end
		EVENT_MANAGER:UnregisterForEvent(GROUP_SYNERGIZER.name.."_OnPlayerActivated", EVENT_PLAYER_ACTIVATED)	
	end
)

-------------------------
-- Registers
-------------------------
GROUP_SYNERGIZER.eventManager:RegisterForEvent(GROUP_SYNERGIZER.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
GROUP_SYNERGIZER.eventManager:RegisterForEvent(GROUP_SYNERGIZER.name, EVENT_ACTIVITY_FINDER_STATUS_UPDATE, GROUP_SYNERGIZER.OnActivityFinderStatusUpdate)
GROUP_SYNERGIZER.eventManager:RegisterForEvent(GROUP_SYNERGIZER.name, EVENT_BATTLEGROUND_STATE_CHANGED, GROUP_SYNERGIZER.OnBattlegroundStateChanged)
DEATH_FRAGMENT:RegisterCallback("StateChange", GROUP_SYNERGIZER.OnDeathFragmentStateChange)
KEYBOARD_GROUP_MENU_SCENE:RegisterCallback("StateChange", GROUP_SYNERGIZER.groupFinderVisible)

--GROUP_SYNERGIZER.eventManager:RegisterForEvent(GROUP_SYNERGIZER.name, EVENT_ACTIVITY_FINDER_COOLDOWNS_UPDATE, GROUP_SYNERGIZER.OnCooldownsUpdate)
--ZO_ACTIVITY_FINDER_ROOT_MANAGER:RegisterCallback("OnSelectionsChanged", GROUP_SYNERGIZER.OnSelectionsChanged)
--SecurePostHook(ZO_ACTIVITY_FINDER_ROOT_MANAGER, 'SetLocationSelected', GROUP_SYNERGIZER.SetLocationSelected)
--SecurePostHook(DUNGEON_FINDER_GAMEPAD, 'OnShowing', function() GROUP_SYNERGIZER.AutoAcceptCheckbox(true) end)
--SecurePostHook(BATTLEGROUND_FINDER_GAMEPAD, 'OnShowing', function() GROUP_SYNERGIZER.AutoAcceptCheckbox(true) end)
--GROUP_SYNERGIZER.eventManager:RegisterForEvent(GROUP_SYNERGIZER.name, EVENT_CHATTER_BEGIN, function() d(GetUnitName("interact")) end)
--[[
ZO_PreHook(
	ZO_ACTIVITY_FINDER_ROOT_MANAGER,
	"ClearSelections",
	function(self)
		d("FARTas")
	end
)
]]
