local ANTIQUITY_ID = 103
local csaTypes = {
	CENTER_SCREEN_ANNOUNCE_TYPE_ANTIQUITY_DIG_SITES_UPDATED,
	CENTER_SCREEN_ANNOUNCE_TYPE_QUEST_ADDED,
	CENTER_SCREEN_ANNOUNCE_TYPE_QUEST_CONDITION_COMPLETED,
	CENTER_SCREEN_ANNOUNCE_TYPE_QUEST_PROGRESSION_CHANGED,
}

-- skip chatter
local function PopulateChatterOption(self, controlID, _, _, optionType, _, isImportant)
	local name = GetUnitName("interact")

	if name == zo_strformat("<<1>>", GetString(SI_GABRIELLE_BENELE)) or name == zo_strformat("<<1>>", GetString(SI_VERITA_NUMIDA)) then
		if
			optionType == CHATTER_GENERIC_ACCEPT
			or optionType == CHATTER_COMPLETE_QUEST
			or optionType == CHATTER_START_NEW_QUEST_BESTOWAL
			or optionType == CHATTER_START_TALK
			or optionType == CHATTER_TALK_CHOICE
		then
			self:SelectChatterOptionByIndex(controlID)
		end
	end
end
ZO_PostHook(
	INTERACTION,
	"PopulateChatterOption",
	PopulateChatterOption
)
ZO_PostHook(
	GAMEPAD_INTERACTION,
	"PopulateChatterOption",
	PopulateChatterOption
)

-- end chatter for lore topics
local function PopulateChatterOptions(self, optionCount)
	local name = GetUnitName("interact")

	if (name == zo_strformat("<<1>>", GetString(SI_GABRIELLE_BENELE)) or name == zo_strformat("<<1>>", GetString(SI_VERITA_NUMIDA))) and optionCount ~= 1 then
		self:CloseChatter()
	end
end
ZO_PostHook(
	INTERACTION,
	"PopulateChatterOptions",
	PopulateChatterOptions
)
ZO_PostHook(
	GAMEPAD_INTERACTION,
	"PopulateChatterOptions",
	PopulateChatterOptions
)

local function SupressCSAs()
	for _, csaType in ipairs(csaTypes) do
		CENTER_SCREEN_ANNOUNCE:SupressAnnouncementByType(csaType)
	end
end
local function ResumeCSAs()
	for _, csaType in ipairs(csaTypes) do
		CENTER_SCREEN_ANNOUNCE:ResumeAnnouncementByType(csaType)
	end
end

-- supress center screen announcements
EVENT_MANAGER:RegisterForEvent(
	"PowerScry",
	EVENT_CHATTER_BEGIN,
	function()
		local name = GetUnitName("interact")

		if name == zo_strformat("<<1>>", GetString(SI_GABRIELLE_BENELE)) then
			SupressCSAs()
		elseif name == zo_strformat("<<1>>", GetString(SI_VERITA_NUMIDA)) then
			ResumeCSAs()
		end
	end
)

local function AbandonScryingQuest()
	for journalQuestIndex = 1, MAX_JOURNAL_QUESTS do
		if GetJournalQuestInfo(journalQuestIndex) == GetString(SI_ANTIQUARIANS_ART) then
			AbandonQuest(journalQuestIndex)
			return
		end
	end
end

local function HideScryingScene()
	SCENE_MANAGER:ShowBaseScene()
end

-- start scrying when ready
EVENT_MANAGER:RegisterForEvent(
	"PowerScry",
	EVENT_CHATTER_END,
	function()
		if CanScryForAntiquity(ANTIQUITY_ID) == ANTIQUITY_SCRYING_RESULT_SUCCESS then
			zo_callLater(function() ScryForAntiquity(ANTIQUITY_ID) end, 250)

			EVENT_MANAGER:RegisterForEvent(
				"PowerScry",
				EVENT_ANTIQUITY_DIGGING_GAME_OVER,
				function()
					EVENT_MANAGER:UnregisterForEvent("PowerScry", EVENT_ANTIQUITY_DIGGING_GAME_OVER)
					zo_callLater(AbandonScryingQuest, 250)
					zo_callLater(HideScryingScene, 2000)
					ResumeCSAs()
				end
			)
		end
	end
)

-- don't reveal dig site on world map
ZO_PreHook(
	WORLD_MAP_MANAGER,
	"RevealAntiquityDigSpotsOnMap",
	function(_, antiquityId)
		return antiquityId == ANTIQUITY_ID
	end
)

-- block tutorial info boxes
ZO_PreHook(
	TUTORIAL_SYSTEM.tutorialHandlers[TUTORIAL_TYPE_HUD_INFO_BOX],
	"DisplayTutorial",
	function(_, tutorialIndex)
		return tutorialIndex == 233
	end
)
ZO_PreHook(
	TUTORIAL_SYSTEM.tutorialHandlers[TUTORIAL_TYPE_UI_INFO_BOX],
	"DisplayTutorial",
	function(_, tutorialIndex)
		return
			tutorialIndex == 211
			or (tutorialIndex >= 214 and tutorialIndex ~= 216 and tutorialIndex <= 218)
			or tutorialIndex == 232
			or tutorialIndex == 234
	end
)