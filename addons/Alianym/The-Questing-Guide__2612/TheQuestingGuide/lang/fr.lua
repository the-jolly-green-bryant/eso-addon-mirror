local strfmt = string.format
local zStrFmt = zo_strformat
local overviewGroupTabDescFmt = "%s %s|t26:26:%s|t %s|t26:26:%s|t %s|t26:26:%s|t / |t26:26:%s|t\n\n%s\n\n%s"
local overviewGroupTabDungIcon = "/esoui/art/icons/poi/poi_groupinstance_complete.dds"
local overviewGroupTabTrialIcon = "/esoui/art/icons/poi/poi_raiddungeon_complete.dds"
local overviewGroupTabArenaIconOne = "/esoui/art/icons/poi/poi_groupinstance_complete.dds"
local overviewGroupTabArenaIconTwo = "/esoui/art/icons/poi/poi_raiddungeon_complete.dds"

local stringsFR = {
	--TQG_CONFIRM_QUEST_ZONE_STORY = "Histoire de la zone",
	--TQG_CONFIRM_QUEST_POI = "Points d'intérêt",

	SI_BINDING_NAME_TQG_INTERACT_KEY = "Bascule Guide de Quêtes",
	SI_BINDING_NAME_TQG_INTERACT_GAMEPAD_KEY = zStrFmt("<<1>> – <<2>>", "Bascule Guide de Quêtes", GetString(SI_GAMEPAD_SECTION_HEADER)),
	TQG_MENU_JOURNAL = "Le Guide de Quêtes",

	TQG_OVERVIEW_TAB = "Général",
	TQG_OVERVIEW_CLASSIC_DESC = "L'arc de la Coalescence est l'histoire original dans l'Aurbis, le récit s'entremêlera entre l'histoire principale, les alliances et les intrigues des guildes au fûr et à mesure que vous progresserez.\n\nL'histoire des Alliances se passe en parallèle – les îles de départ, puis Auridia/La Glénumbrie/Les Éboulis etc. Il n'est cependant pas nécessaire de finir toutes les quêtes d'Alliances pour accéder à Havreglace.\n\nLe cheminement original de l'histoire des Alliances est celui-ci:\n - L'histoire de l'alliance de votre personnage, puis l'Argent et l'Or de Cadwell qui représente les deux autres alliances, ce qui peut être réalisé en tant que post-quête principale pour faire l'expérience des histoires de ces alliances.",
	TQG_OVERVIEW_DLC_DESC = "La section des DLC couvre la majorité de l'intrigue depuis l'introduction des donjons de DLC, zones et chapitres. L'ordre ci-dessous fonctionne chronologiquement à la sortie des extensions.\n\nLes évènements majeurs sont:\n – La cité impériale\n – Orsinium\n – Guilde des voleurs / Confrérie noire\n – Guerre Daedrique\n – Tourbevase\n – Saison du Dragon\n – Le Cœur noir de Bordeciel\n – Les Portes d'Oblivion\n – L’Héritage des Brétons\n – L’Ombre sur Morrowind",
	TQG_OVERVIEW_GROUP_DESC = strfmt(overviewGroupTabDescFmt, "La section des contenus de groupe inclut la majorité des instances de groupe disponible à ce jour.", "Donjons : ", overviewGroupTabDungIcon, "Raids : ", overviewGroupTabTrialIcon, "Arènes : ", overviewGroupTabArenaIconOne, overviewGroupTabArenaIconTwo, "Il y a les versions des contenus en mode normal, vétéran et occasionnellement en mode 'difficile', avec l'exception de l'Arène de Maelstrom qui requiert uniquement le mode normal. Le Guide ne se soucie pas du mode de difficulté que vous choisirez pour compléter la quête.", "Les quêtes sont cependant liées à certaines extensions. La Gueule de Lorkhaj est en Marche de la Camarde, mais est sortie avec le DLC Thieves Guild, elle sera donc listée sous celui-ci."),

	TQG_OVERVIEW_DLC_TITLE = "DLC + Chapitres",
	TQG_OVERVIEW_GROUP_TITLE = "Contenu du groupe",

	TQG_QUEST_BTN = "Classique: Carte de Quête",
	TQG_IC_BTN = "DLC: Imperial City",
	TQG_ORSINIUM_BTN = "DLC: Orsinium",

	TQG_OVERVIEW_LINKS_TITLE = "Liens utiles",
	TQG_OVERVIEW_LINKS_TEXT = "Dû à la nature des liens, des spoilers sont évidemment possibles. Vous êtes donc prévenu...",
	TQG_OVERVIEW_OBJECTIVE_TEXT = "La taille du groupe pour les contenus varie selon les individus. L'Arène de Maelstrom est une arène en solo, vous allez donc devoir faire face à ses horreurs tout seul.\n\n(En règle générale, les quêtes de Donjons ne sont pas répétables, cependant les quêtes de Raids le sont hebdomadairement.Vous aurez cependant uniquement à les compléter une fois pour les valider.)",

	TQG_PROLOGUE = "Prologue",
	TQG_EPILOGUE = "Épilogue",
	TQG_PREREQ = "Prérequis",

	TQG_ARENA = "Arène",

	TQG_ENTER = "Entrer",
	TQG_SEEK = "Trouver",

	TQG_PLANEMELD = "La Coalescence",

	TQG_GUILDS_AND_GLORY = "Guildes et gloire",
	TQG_DAEDRIC_WAR = "Guerre Daedrique",
	TQG_MURKMIRE = zStrFmt("<<1>>: <<2>>", GetZoneNameById(726), "Intermède"),
	TQG_CHAPTER_ELSWEYR = "Saison du Dragon",
	TQG_CHAPTER_SKYRIM = "Le Cœur noir de Bordeciel",
	TQG_CHAPTER_BLACKWOOD = "Les Portes d'Oblivion",
	TQG_CHAPTER_HIGH_ISLE = "L’Héritage des Brétons",
	TQG_CHAPTER_SHADOW_MORROWIND = "L’Ombre sur Morrowind",
	TQG_CHAPTER_RECOLLECTION_ITHELIA = "Souvenirs d'Ithelia",
	TQG_CHAPTER_SEASON_WORM_CULT = "Saisons du Culte du Ver",

	TQG_INVITATION = "Une Invitation",
	TQG_FIGHTERS_NAME = "Guilde des guerriers",
	TQG_FIGHTERS_DESC = "La Guilde des guerriers a été créée en vertu de l'article 4 de la « loi sur les guildes » et cette charte a été confirmée pour la première fois au cours de la 321e année de la Deuxième Ère dans le cadre du règne du potentat Versidue Shaie.",
	TQG_MAGES_NAME = "Guilde des mages",
	TQG_MAGES_DESC = "La Guilde des mages a été créée sur l'archipel du Couchant en 230 de la Deuxième Ère par Vanus Galérion et Rilis XII. Elle a ensuite été confirmée par la « loi de guilde » du Potentat Versidue-Shaie.",
	TQG_DOSHIA_LAIR = "La tanière de Doshia",
	TQG_BONUS_BALMORA = "Bonus: Balmora",
	TQG_BONUS_BALMORA_DESC = "Le gouvernement de Morrowind a autorisé la Morag Tong il y a bien longtemps, lors de la Première Ère, et à ce jour, elle continue de mener des assassinats tacitement légaux, avec un système de contrats appelés « Ordres honorables d'exécution ».",
}

for id, stringVar in pairs(stringsFR) do
   SafeAddString(_G[id], stringVar, 2)
end

local DLCTooltipFmt = "<<1>>, <<2>>: <<3>>\n(<<4>> <<5>>)"
local function SetupDLCTooltip(str1, str2, zoneId, str4, str5)
	return zStrFmt(DLCTooltipFmt, str1, str2, GetZoneNameById(zoneId), str4, str5)
end

TQG.DLCQuestIdToTooltip = {
	[5935] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "1/1", 849, GetString(TQG_SEEK), "'Rhéa Opacarius'"),
	[6023] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "1/1", 980, GetString(TQG_SEEK), "'La Dépêche de l'Ordre de l'œil'"),
	[6097] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "1/1", 1011, GetString(TQG_SEEK), "'Vanus Galérion'"),
	[6226] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "1/2", 726, GetString(TQG_SEEK), "'Les Conservateurs Cyrodiiliaques ont besoin de vous !'"),
	[6242] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "2/2", 726, GetString(TQG_SEEK), "'Concordia Mercius'"),
	[6299] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "1/2", 1086, GetString(TQG_SEEK), "'Anais Davaux'"),
	[6306] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "2/2", 1086, GetString(TQG_SEEK), "'Abnur Tharn'"),
	[6395] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "1/2", 1133, GetString(TQG_SEEK), "'Hinzuur'"),
	[6398] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "2/2", 1133, GetString(TQG_SEEK), "'La vallée des lames'"),
}

local groupTooltipFmt = "<<1>>: (<<2>> <<3>>)"
local function SetupGroupTooltip(str1, str2, zoneIdOrName)
	local str3

	if type(zoneIdOrName) == "number" then str3 = GetZoneNameById(zoneId)
	elseif type(zoneIdOrName) == "string" then str3 = zoneIdOrName end

	return zStrFmt(groupTooltipFmt, str1, str2, str3)
end

TQG.GroupQuestIdToTooltip = {
	[5554] = SetupGroupTooltip(GetString(TQG_TRIAL), GetString(TQG_SEEK), "Bakhum"),

	[6000] = SetupGroupTooltip(GetString(TQG_TRIAL), GetString(TQG_SEEK), "Daynillo Rethul"),
	[6193] = SetupGroupTooltip(GetString(TQG_TRIAL), GetString(TQG_SEEK), "Vandoril"),

	[6354] = SetupGroupTooltip(GetString(TQG_TRIAL), GetString(TQG_SEEK), "Natrada"),

	[6504] = SetupGroupTooltip(GetString(TQG_TRIAL), GetString(TQG_SEEK), "Tyrvera"),

	[6597] = SetupGroupTooltip(GetString(TQG_ARENA), GetString(TQG_SEEK), "Angair"),

	[6655] = SetupGroupTooltip(GetString(TQG_TRIAL), GetString(TQG_SEEK), "Malosza"),

	[6784] = SetupGroupTooltip(GetString(TQG_TRIAL), GetString(TQG_SEEK), "L’yéoman Géline"),

	[7032] = SetupGroupTooltip(GetString(TQG_TRIAL), GetString(TQG_SEEK), "Le chercheur An'Xeh"),
}