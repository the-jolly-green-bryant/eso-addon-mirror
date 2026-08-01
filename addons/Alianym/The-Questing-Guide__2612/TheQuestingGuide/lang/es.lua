local strfmt = string.format
local zStrFmt = zo_strformat
local overviewGroupTabDescFmt = "%s %s|t26:26:%s|t %s|t26:26:%s|t %s|t26:26:%s|t / |t26:26:%s|t\n\n%s\n\n%s"
local overviewGroupTabDungIcon = "/esoui/art/icons/poi/poi_groupinstance_complete.dds"
local overviewGroupTabTrialIcon = "/esoui/art/icons/poi/poi_raiddungeon_complete.dds"
local overviewGroupTabArenaIconOne = "/esoui/art/icons/poi/poi_groupinstance_complete.dds"
local overviewGroupTabArenaIconTwo = "/esoui/art/icons/poi/poi_raiddungeon_complete.dds"

local stringsES = {
	TQG_CONFIRM_QUEST_ZONE_STORY = "Misiones de historia de la zona",
	TQG_CONFIRM_QUEST_POI = "Lugares relevantes",

	SI_BINDING_NAME_TQG_INTERACT_KEY = "Activar la guía de la misión",
	SI_BINDING_NAME_TQG_INTERACT_GAMEPAD_KEY = zStrFmt("<<1>> – <<2>>", "Activar la guía de la misión", GetString(SI_GAMEPAD_SECTION_HEADER)),
	TQG_MENU_JOURNAL = "La guía de la misión",

	--TQG_OVERVIEW_CLASSIC_DESC = "The Planemeld Arc... This is the original ESO story in the Aurbis, and the tale will interweave amongst Main Story, Alliance, and Guild Storylines as you progress.\n\nAlliance Stories happen in parallel – e.g. Starter Island(s), then Auridon/Glenumbra/Stonefalls, etc. You should not feel like you have to complete every Alliance Story before reaching Coldharbour, however.\n\nThe original Alliance Story pathway was;\n – The story of your character's Alliance; then Cadwell's Silver/Gold which represented the other two Alliances, in clockwise order as a 'post-Main Quest' experience.",
	--TQG_OVERVIEW_DLC_DESC = "The DLC section covers off every major storyline since the introduction of the DLC dungeons, zones, and Chapters. The order presented defaults to the order of release.\n\nMajor Events include:\n – The Sublime Plot\n – Reforging Orsinium\n – Thieves Guild / Dark Brotherhood\n – Daedric War\n – A Lost Legacy\n – Season of the Dragon\n – Dark Heart of Skyrim\n – Gates of Oblivion\n – Legacy of the Bretons\n – Shadow Over Morrowind",
	--TQG_OVERVIEW_GROUP_DESC = strfmt(overviewGroupTabDescFmt, "The Group section includes the majority of instanced Group Content to-date.", "Dungeons: ", overviewGroupTabDungIcon, "Trials: ", overviewGroupTabTrialIcon, "Arenas: ", overviewGroupTabArenaIconOne, overviewGroupTabArenaIconTwo, "There are normal, veteran, and occasionally hard-mode versions of the content, but with the exception of Maelstrom Arena (which only requires the normal-mode quest), the Guide does not care on which difficulty you complete the quest.", "The quests are still tied to the content with which they released. E.G., Maw of Lorkhaj is in Reaper's March, but released with Thieves Guild, so it will be listed under the latter."),

	TQG_OVERVIEW_DLC_TITLE = "DLC + Capítulos",
	TQG_OVERVIEW_GROUP_TITLE = "Contenido del grupo",

	TQG_QUEST_BTN = "Clásico: Mapa de la misión",
	TQG_IC_BTN = "DLC: La sublime trama",
	TQG_ORSINIUM_BTN = "DLC: Reformar Orsinium",

	TQG_OVERVIEW_LINKS_TITLE = "Enlaces útiles",
	--TQG_OVERVIEW_LINKS_TEXT = "Due to the nature of the links, spoilers are more likely the deeper you delve. Be forewarned...",
	--TQG_OVERVIEW_OBJECTIVE_TEXT = "Required group size for the content will vary according to the individuals. Maelstrom Arena is a solo Arena–You will face it's horrors alone.\n\n(As a general rule, Dungeon quests are not repeatable, while Trial quests are repeatable weekly. You will only need to complete them once to register them.)",

	TQG_PROLOGUE = "Prólogo",
	TQG_EPILOGUE = "Epílogo",
	TQG_PREREQ = "Prerrequisito",

	TQG_ARENA = "Arena",

	TQG_ENTER = "Entrar en",
	TQG_SEEK = "Buscar",
	
	TQG_PLANEMELD = "La coalescencia",

	TQG_GUILDS_AND_GLORY = "Clanes y gloria",
	TQG_DAEDRIC_WAR = "Guerra Dédrica",
	TQG_MURKMIRE = zStrFmt("<<1>>: <<2>>", GetZoneNameById(726), "Interludio"),
	TQG_CHAPTER_ELSWEYR = "Temporada del Dragón",
	TQG_CHAPTER_SKYRIM = "Corazón oscuro de Skyrim",
	TQG_CHAPTER_BLACKWOOD = "Puertas de Oblivion",
	TQG_CHAPTER_HIGH_ISLE = "El legado de los bretones",
	TQG_CHAPTER_SHADOW_MORROWIND = "Sombras sobre Morrowind",
	TQG_CHAPTER_RECOLLECTION_ITHELIA = "Recuerdo de Ithelia",
	TQG_CHAPTER_SEASON_WORM_CULT = "Temporadas del Culto del Gusano",

	TQG_INVITATION = "La invitación",
	TQG_FIGHTERS_NAME = "Gremio de luchadores",
	--TQG_FIGHTERS_DESC = 'The Guild of Fighters was established under the section 4 of the "Guilds Act," and this charter was first confirmed under the Potentate Versidue-Shaie in the 321st year of the Second Era.',
	TQG_MAGES_NAME = "Gremio de magos",
	--TQG_MAGES_DESC = 'The Guild of Mages was established on Summerset Isle in the year 230 of the Second Era by Vanus Galerion and Rilis XII. It was later confirmed by the "Guilds Act" of Potentate Versidue-Shaie.',
	TQG_DOSHIA_LAIR = "La guarida Doshia",
	TQG_BONUS_BALMORA = "Extra: Balmora",
	--TQG_BONUS_BALMORA_DESC = 'The Morrowind government sanctioned the Morag Tong long ago during the First Era, and to this day they continue to perform tacitly legal assassinations, utilizing a system of contracts known as "honorable writs of execution."',
}

for id, stringVar in pairs(stringsES) do
   ZO_CreateStringId(id, stringVar)
   SafeAddVersion(id, 1)
end

local DLCTooltipFmt = "<<1>>, <<2>>: <<3>>\n(<<4>> <<5>>)"
local function SetupDLCTooltip(str1, str2, zoneId, str4, str5)
	return zStrFmt(DLCTooltipFmt, str1, str2, GetZoneNameById(zoneId), str4, str5)
end

TQG.DLCQuestIdToTooltip = {
	[5935] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "1/1", 849, GetString(TQG_SEEK), "'Rhea Opacarius'"),
	[6023] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "1/1", 980, GetString(TQG_SEEK), "'Expedición de la Orden del Ojo'"),
	[6097] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "1/1", 1011, GetString(TQG_SEEK), "'Vano Galerion'"),
	[6226] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "1/2", 726, GetString(TQG_SEEK), "'¡El Anticuario Cyrodílico te necesita!'"),
	[6242] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "2/2", 726, GetString(TQG_SEEK), "'Concordia Mercio'"),
	[6299] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "1/2", 1086, GetString(TQG_SEEK), "'Anais Davaux'"),
	[6306] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "2/2", 1086, GetString(TQG_SEEK), "'Abnur Tharn'"),
	[6395] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "1/2", 1133, GetString(TQG_SEEK), "'Hinzuur'"),
	--[6398] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "2/2", 1133, "Visit", "'Valley of Blades'"),
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

	[6784] = SetupGroupTooltip(GetString(TQG_TRIAL), GetString(TQG_SEEK), "El ayudante Geline"),

	[7032] = SetupGroupTooltip(GetString(TQG_TRIAL), GetString(TQG_SEEK), "Investigador An'Xeh"),
}