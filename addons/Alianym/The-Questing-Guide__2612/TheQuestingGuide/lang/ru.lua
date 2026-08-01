local strfmt = string.format
local zStrFmt = zo_strformat
local overviewGroupTabDescFmt = "%s %s|t26:26:%s|t %s|t26:26:%s|t %s|t26:26:%s|t / |t26:26:%s|t\n\n%s\n\n%s"
local overviewGroupTabDungIcon = "/esoui/art/icons/poi/poi_groupinstance_complete.dds"
local overviewGroupTabTrialIcon = "/esoui/art/icons/poi/poi_raiddungeon_complete.dds"
local overviewGroupTabArenaIconOne = "/esoui/art/icons/poi/poi_groupinstance_complete.dds"
local overviewGroupTabArenaIconTwo = "/esoui/art/icons/poi/poi_raiddungeon_complete.dds"

local stringsRU = {
	--TQG_CONFIRM_QUEST_ZONE_STORY = "Сюжет зоны",
	--TQG_CONFIRM_QUEST_POI = "Точки интереса",

	SI_BINDING_NAME_TQG_INTERACT_KEY = "Включает/отключает Руководство по квестам",
	SI_BINDING_NAME_TQG_INTERACT_GAMEPAD_KEY = zStrFmt("<<1>> – <<2>>", "Включает/отключает Руководство по квестам", GetString(SI_GAMEPAD_SECTION_HEADER)),
	TQG_MENU_JOURNAL = "Руководство квест",

	--TQG_OVERVIEW_CLASSIC_DESC = "The Planemeld Arc... This is the original ESO story in the Aurbis, and the tale will interweave amongst Main Story, Alliance, and Guild Storylines as you progress.\n\nAlliance Stories happen in parallel – e.g. Starter Island(s), then Auridon/Glenumbra/Stonefalls, etc. You should not feel like you have to complete every Alliance Story before reaching Coldharbour, however.\n\nThe original Alliance Story pathway was;\n – The story of your character's Alliance; then Cadwell's Silver/Gold which represented the other two Alliances, in clockwise order as a 'post-Main Quest' experience.",
	--TQG_OVERVIEW_DLC_DESC = "The DLC section covers off every major storyline since the introduction of the DLC dungeons, zones, and Chapters. The order presented defaults to the order of release.\n\nMajor Events include:\n – The Sublime Plot\n – Reforging Orsinium\n – Thieves Guild / Dark Brotherhood\n – Daedric War\n – A Lost Legacy\n – Season of the Dragon\n – Dark Heart of Skyrim\n – Gates of Oblivion",
	--TQG_OVERVIEW_GROUP_DESC = strfmt(overviewGroupTabDescFmt, "The Group section includes the majority of instanced Group Content to-date.", "Dungeons: ", overviewGroupTabDungIcon, "Trials: ", overviewGroupTabTrialIcon, "Arenas: ", overviewGroupTabArenaIconOne, overviewGroupTabArenaIconTwo, "There are normal, veteran, and occasionally hard-mode versions of the content, but with the exception of Maelstrom Arena (which only requires the normal-mode quest), the Guide does not care on which difficulty you complete the quest.", "The quests are still tied to the content with which they released. E.G., Maw of Lorkhaj is in Reaper's March, but released with Thieves Guild, so it will be listed under the latter."),

	TQG_OVERVIEW_DLC_TITLE = "Дополнение + Глава",
	TQG_OVERVIEW_GROUP_TITLE = "Групповой контент",

	--TQG_QUEST_BTN = "Classic: Quest Map",
	--TQG_IC_BTN = "DLC: The Sublime Plot",
	--TQG_ORSINIUM_BTN = "DLC: Reforging Orsinium",

	--TQG_OVERVIEW_LINKS_TITLE = "Useful Links",
	--TQG_OVERVIEW_LINKS_TEXT = "Due to the nature of the links, spoilers are more likely the deeper you delve. Be forewarned...",
	--TQG_OVERVIEW_OBJECTIVE_TEXT = "Required group size for the content will vary according to the individuals. Maelstrom Arena is a solo Arena–You will face it's horrors alone.\n\n(As a general rule, Dungeon quests are not repeatable, while Trial quests are repeatable weekly. You will only need to complete them once to register them.)",

	TQG_PROLOGUE = "Пролог",
	TQG_EPILOGUE = "эпилог",
	TQG_PREREQ = "Необходимое условие",

	TQG_ARENA = "Aренa",

	TQG_ENTER = "Ввести",
	TQG_SEEK = "Найти",

	TQG_PLANEMELD = "Слияния миров",

	TQG_GUILDS_AND_GLORY = "Гильдии и Слава",
	TQG_DAEDRIC_WAR = "Даэдрический Война",
	TQG_MURKMIRE = zStrFmt("<<1>>: <<2>>", GetZoneNameById(726), "интерлюдия"),
	TQG_CHAPTER_ELSWEYR = "Драконий Оплот",
	TQG_CHAPTER_SKYRIM = "Темное Сердце Скайрима",
	TQG_CHAPTER_BLACKWOOD = "Врата Обливиона",
	TQG_CHAPTER_HIGH_ISLE = "Бретонское наследие",
	TQG_CHAPTER_SHADOW_MORROWIND = "Тень над Морровиндом",
	TQG_CHAPTER_RECOLLECTION_ITHELIA = "Воспоминания об Ителии",
	TQG_CHAPTER_SEASON_WORM_CULT = "Сезоны культа червей",
	
	TQG_INVITATION = "Приглашение",
	TQG_FIGHTERS_NAME = "Гильдия бойцов",
	TQG_FIGHTERS_DESC = 'Гильдия воинов была создана в соответствии с разделом 4 Закона о гильдиях, и эта хартия была впервые утверждена в 321 году второй эры как часть правления Потентат Версидью-Шайе',
	TQG_MAGES_NAME = "Гильдия магов",
	TQG_MAGES_DESC = 'Гильдия Магов была основана в 230 году во второй эре Ванусом Галерионом и Рилисом XII. Основан на острове Саммерсет. Позднее это было подтверждено «Законом о гильдиях» Потентат Версидью-Шайе.',
	TQG_DOSHIA_LAIR = "Доши-х логово",
	TQG_BONUS_BALMORA = "дополнительный: Балмора",
	TQG_BONUS_BALMORA_DESC = "Правительство Морровинда санкционировало деятельность Мораг Тонг еще в Первую эру, и по сей день они продолжают совершать негласно законные убийства, используя систему контрактов, известную как «приказы о благородной казни».",
}

for id, stringVar in pairs(stringsRU) do
   SafeAddString(_G[id], stringVar, 2)
end

local DLCTooltipFmt = "<<1>>, <<2>>: <<3>>\n(<<4>> <<5>>)"
local function SetupDLCTooltip(str1, str2, zoneId, str4, str5)
	return zStrFmt(DLCTooltipFmt, str1, str2, GetZoneNameById(zoneId), str4, str5)
end

TQG.DLCQuestIdToTooltip = {
	[5935] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "1/1", 849, GetString(TQG_SEEK), "«Рея опакария»"),
	[6023] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "1/1", 980, GetString(TQG_SEEK), "«Донесение ордена Ока»"),
	[6097] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "1/1", 1011, GetString(TQG_SEEK), "«Ванус Галерион»"),
	[6226] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "1/2", 726, GetString(TQG_SEEK), "«Вы нужны Коллекционерам Сиродила!!»"),
	[6242] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "2/2", 726, GetString(TQG_SEEK), "«Конкордия Mercius»"),
	[6299] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "1/2", 1086, GetString(TQG_SEEK), "«Анаис Даво»"),
	[6306] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "2/2", 1086, GetString(TQG_SEEK), "«Абнур Тарн»"),
	[6395] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "1/2", 1133, GetString(TQG_SEEK), "«Xинзур»"),
	[6398] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "2/2", 1133, GetString(TQG_SEEK), "«Долина Клинков»"),
}

local groupTooltipFmt = "<<1>>: (<<2>> <<3>>)"
local function SetupGroupTooltip(str1, str2, zoneIdOrName)
	local str3

	if type(zoneIdOrName) == "number" then str3 = GetZoneNameById(zoneId)
	elseif type(zoneIdOrName) == "string" then str3 = zoneIdOrName end

	return zStrFmt(groupTooltipFmt, str1, str2, str3)
end

TQG.GroupQuestIdToTooltip = {
	[5554] = SetupGroupTooltip(GetString(TQG_TRIAL), GetString(TQG_SEEK), "Баукм"),

	[6000] = SetupGroupTooltip(GetString(TQG_TRIAL), GetString(TQG_SEEK), "Дайнилло Ретул"),
	[6193] = SetupGroupTooltip(GetString(TQG_TRIAL), GetString(TQG_SEEK), "Вандорил"),

	[6354] = SetupGroupTooltip(GetString(TQG_TRIAL), GetString(TQG_SEEK), "Натрада"),

	[6504] = SetupGroupTooltip(GetString(TQG_TRIAL), GetString(TQG_SEEK), "Тирвepa"),

	[6597] = SetupGroupTooltip(GetString(TQG_ARENA), GetString(TQG_SEEK), "Ангер"),

	[6655] = SetupGroupTooltip(GetString(TQG_TRIAL), GetString(TQG_SEEK), "Малосза"),

	[6784] = SetupGroupTooltip(GetString(TQG_TRIAL), GetString(TQG_SEEK), "Йоман Желин"),

	[7032] = SetupGroupTooltip(GetString(TQG_TRIAL), GetString(TQG_SEEK), "Исследователь Ан'Ксей"),
}