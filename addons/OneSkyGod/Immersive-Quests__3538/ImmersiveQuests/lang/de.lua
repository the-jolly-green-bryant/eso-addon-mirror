-- Can view this in text via;
-- /script SetCVar("language.2", "de")

-- Localized Strings unrelated to Quest Objectives

local stringsDE = {
	--IMMERSIVE_QUESTS_NAME = "Immersive Quests",
	--IMMERSIVE_QUESTS_DESCRIPTION_TITLE = "Example Description Title",
	--IMMERSIVE_QUESTS_DESCRIPTION = "Example Description",
	--IMMERSIVE_QUESTS_BUTTON_NAME = "Example Button Name",
	--IMMERSIVE_QUESTS_BUTTON_TOOLTIP = "Example Tooltip Text",
}

for id, stringVar in pairs(stringsDE) do
   ZO_CreateStringId(id, stringVar)
   SafeAddVersion(id, 2)
end

ImmersiveQuests.localization = {

-- Main Questline

	[GetQuestName(4296)] = { -- "Soul Shriven in Coldharbour"
		["Sprecht mit der verhüllten Gestalt 1"] = { 
			appendText = 
			{
				[ALLIANCE_ALDMERI_DOMINION]="near by the Vulkhel Guard wayshrine in Auridon.",
				[ALLIANCE_DAGGERFALL_COVENANT]="near by the Daggerfall city wayshrine in Glenumbra.",
				[ALLIANCE_EBONHEART_PACT]="near by the Davon's Watch city wayshrine in Stonefalls.",
			}, stepTextKey="A hooded figure wishes to speak to me. I should see what the hooded figure wants.",
		},
	},
}