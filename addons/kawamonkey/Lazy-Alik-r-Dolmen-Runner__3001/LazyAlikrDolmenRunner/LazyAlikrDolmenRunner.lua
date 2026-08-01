local savedVars

local function ToggleProgressBar()
	if savedVars.enabled then
		SCENE_MANAGER:GetScene("hud"):AddFragment(PLAYER_PROGRESS_BAR_FRAGMENT)
		SCENE_MANAGER:GetScene("hud"):AddFragment(PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT)
		SCENE_MANAGER:GetScene("hudui"):AddFragment(PLAYER_PROGRESS_BAR_FRAGMENT)
		SCENE_MANAGER:GetScene("hudui"):AddFragment(PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT)
	else
		SCENE_MANAGER:GetScene("hud"):RemoveFragment(PLAYER_PROGRESS_BAR_FRAGMENT)
		SCENE_MANAGER:GetScene("hud"):RemoveFragment(PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT)
		SCENE_MANAGER:GetScene("hudui"):RemoveFragment(PLAYER_PROGRESS_BAR_FRAGMENT)
		SCENE_MANAGER:GetScene("hudui"):RemoveFragment(PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT)
	end
end

SLASH_COMMANDS[GetString(SI_LADR_COMTOGGLE)] = function ()
	savedVars.enabled = not savedVars.enabled

	ToggleProgressBar()

	if savedVars.enabled then
		savedVars.dialogueVolume = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME)
		savedVars.npcSubtitles = GetSetting(SETTING_TYPE_SUBTITLES, SUBTITLE_SETTING_ENABLED_FOR_NPCS)
		savedVars.showQuestTracker = GetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_QUEST_TRACKER)
		savedVars.showQuestBestowerIndicators = GetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_QUEST_BESTOWER_INDICATORS)
		savedVars.compassActiveQuests = GetSetting(SETTING_TYPE_UI, UI_SETTING_COMPASS_ACTIVE_QUESTS)

		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME, 0)
		SetSetting(SETTING_TYPE_SUBTITLES, SUBTITLE_SETTING_ENABLED_FOR_NPCS, 1)
		SetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_QUEST_TRACKER, 0)
		SetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_QUEST_BESTOWER_INDICATORS, 0)
		SetSetting(SETTING_TYPE_UI, UI_SETTING_COMPASS_ACTIVE_QUESTS, COMPASS_ACTIVE_QUESTS_CHOICE_OFF)

		d(zo_strformat(SI_LADR_ENABLED))
	else
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME, savedVars.dialogueVolume)
		SetSetting(SETTING_TYPE_SUBTITLES, SUBTITLE_SETTING_ENABLED_FOR_NPCS, savedVars.npcSubtitles)
		SetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_QUEST_TRACKER, savedVars.showQuestTracker)
		SetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_QUEST_BESTOWER_INDICATORS, savedVars.showQuestBestowerIndicators)
		SetSetting(SETTING_TYPE_UI, UI_SETTING_COMPASS_ACTIVE_QUESTS, savedVars.compassActiveQuests)

		d(zo_strformat(SI_LADR_DISABLED))
	end
end

SLASH_COMMANDS[GetString(SI_LADR_COMDIR)] = function ()
	if savedVars.ccw then
		savedVars.ccw = false
		d(zo_strformat(SI_LADR_CWDIR))
	else
		savedVars.ccw = true
		d(zo_strformat(SI_LADR_CCWDIR))
	end
end

local function TryHandlingInteraction(interactionPossible)
	if interactionPossible and savedVars.enabled then
		local additionalInfo = select(5, GetGameCameraInteractableActionInfo())

		return additionalInfo == ADDITIONAL_INTERACT_INFO_FISHING_NODE
	end
end

local function OnFastTravelInteraction(eventCode, nodeIndex)
	-- 59: Aswala Stables
	-- 60: Shrikes' Aerie
	-- 155: Goat's Head Oasis

	if not savedVars.enabled then return end

	if savedVars.ccw then
		if (nodeIndex == 59) then -- Aswala Stables to Goat's Head Oasis
			FastTravelToNode(155)
		elseif (nodeIndex == 155) then -- Goat's Head Oasis to Shrikes' Aerie
			FastTravelToNode(60)
		elseif (nodeIndex == 60) then -- Shrikes' Aerie to Aswala Stables
			FastTravelToNode(59)
		end
	else
		if (nodeIndex == 59) then -- Aswala Stables to Shrikes' Aerie
			FastTravelToNode(60)
		elseif (nodeIndex == 60) then -- Shrikes' Aerie to Goat's Head Oasis
			FastTravelToNode(155)
		elseif (nodeIndex == 155) then -- Goat's Head Oasis to Aswala Stables
			FastTravelToNode(59)
		end
	end
end

local function OnAddOnLoaded(eventCode, addonName)
	if addonName == "LazyAlikrDolmenRunner" then
		savedVars = ZO_SavedVars:NewAccountWide("LazyAlikrDolmenRunner", 1, nil, {ccw = false, enabled = true})

		-- listen for wayshrine interaction
		EVENT_MANAGER:RegisterForEvent("LazyAlikrDolmenRunner", EVENT_START_FAST_TRAVEL_INTERACTION, OnFastTravelInteraction)

		-- toggle progress bar
		ToggleProgressBar()
	end
end

EVENT_MANAGER:RegisterForEvent("LazyAlikrDolmenRunner", EVENT_ADD_ON_LOADED, OnAddOnLoaded)

-- disable interaction with fishing holes
ZO_PreHook(RETICLE, "TryHandlingInteraction", TryHandlingInteraction)