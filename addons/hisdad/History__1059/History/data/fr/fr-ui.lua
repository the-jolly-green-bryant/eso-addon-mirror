-- Translation by Joklix, Thankyou!
dateformat = "%d-%m-%Y, %H:%M"

Area_names={
--EP
[1]={ name="Stonefalls",Grp="Fungal Grotto", Pub="Crow's Wood"},	--1
[2]={ name="Deshaan", Grp="Darkshade Caverns", Pub="Forgotten Crypts"},	--2
[3]={ name="Shadowfen", Grp="Arx Corinum", Pub="Sanguine's Demesne"},	--3
[4]={ name="Eastmarch", Grp="Direfrost Keep", Pub="Hall of the Dead"},	--4
[5]={ name="The Rift", Grp="Blessed Crucible", Pub="Lion's Den"},	--5
--DC
[6]={ name="Glenumbra", Grp="Spindleclutch", Pub="Bad Man's Hallows"},	--6
[7]={ name="Stormhaven", Grp="Wayrest Sewers", Pub="Bonesnap Ruins"},	--7
[8]={ name="Rivenspire", Grp="Crypt of Hearts", Pub="Obsidian Scar"},	--8
[9]={ name="Alik'r Desert", Grp="Volenfell", Pub="Lost City"},	--9
[10]={ name="Bangkorai", Grp="Blackheart Haven", Pub="Razaks Wheel"},	--10
--AD
[11]={ name="Auridon", Grp="Banished Cells", Pub="Toothmall Gully"},	--11
[12]={ name="Grahtwood", Grp="Elden Hollow", Pub="Root Sunder Ruins"},	--12
[13]={ name="Greenshade", Grp="City of Ash", Pub="Rulanyil's Fall"},	--13
[14]={ name="Malabal-Tor", Grp="Tempest Island", Pub="Crimson Cove"},	--14
[15]={ name="Reaper's March", Grp="Selene's Web", Pub="The Vile Manse"},	--15
[16]={ name="Coldharbor"},
[17]={ name="Craglorn"},
[18]={ name="Wrothgar"},
[19]={ name="Hew's Bane"},
[20]={ name="Gold Coast"},
[21]={ name="Imperial City"},

[22]={ name="Murkmire"},
[23]={ name="Western Skyrim"},
[24]={ name="The Reach"},

[25]={ name="Vardenfell"},
[26]={ name="Auridon"},
[27]={ name="Summerset"},
[28]={ name="Arteum"},
[29]={ name="Clockwork City"},
[30]={ name="Northern Elsweyr"},
[31]={ name="Southern Elsweyr"},
[32]={ name="Blackwood"},
[33]={ name="Blackreach"},
[34]={ name="Blackreach:Arkthzand"},
[35]={ name="Blackreach:Greymoor"},
[36]={ name="Fargrave"},
[37]={ name="Fargrave City District"},
[38]={ name="Galen Y'ffelon"},
[39]={ name="Apocrypha"},
[40]={ name="Endless Archive"},
[41]={ name="The Deadlands"},
[42]={ name="High Isle"},
[43]={ name="Telvanni Peninsular"},
[44]={ name="West Weald"},
[45]={ name="Solstice"},
}

L = {
	-- GrpDungeon = "Grp Donjon",
	-- PubDungeon = "Pub Donjon",
	-- VetDungeon = "Vet Donjon",
	-- Leveling  = "Leveling",
	Male = "Homme",
	Female = "Femme",
	LLog = "Dernière connexion : ",
	TPlayed = "Temps joué : ",
	Hrs = "Heures.",
	-- Level = "Niveau",
	-- TimesLeveled = "Times Leveled",
	-- FirstLevel = "First Level",
	-- Visits = "Visits",
	-- FirstVisited = "First Visited",
	Created = "Créé : ",
	PTime = "Play Time (Hr)",
	Start = "Date de début",
	-- Deaths = "Deaths",
	-- APts = "Ach Points",
	-- GrpLab = "Levels are Minimum, scales to leader",
	-- PubLab = "Conqueror Achievement",
	-- VetLab = "All are V1-V12 except City of Ash which is V13-V14",
	WBLab = "",
	LogTab = "Journal système",
	TStamp = "Horodatage" ,
	title = "Historique Pour  ",
	Welcome = "Bienvenue dans la visionneuse d'historique hors ligne de HisDad.",
	-- FirstDeath = "First Death",
	SelectA = "Sélectionnez Compte",
	-- Locations = "Locations",
	-- Location = "Location",
	WBosses = "Boss mondiaux",
	Zone = "Zone",
	SkillQuests = "Quêtes de compétences",
	SkillLab = "Quêtes rapportant un point de compétence. Cliquez pour plus de détails.",
	SQ_Detail = "SQ_Detail",
	WB_Detail ="WB_Detail",
	Ach_ID = "Ach ID",
	Name = "Nom",
	Link = "Link (Click to launch)",
	Characters = "Caractère",
	Dungeons = "Donjons",
	Mode = "Affichage",
	-- Grp_TabName={},
	-- Trial_TabName={},
	-- Grp = "Groupe",
	-- Pub = "Public",
	-- Vet = "Vétéran",
	Achievements = "Réalisations",
	DLC="DLC",
	DLCLab="Contenu téléchargeable",
	Manage = "Gérer",
	Account = "Compte",
	Char = "Char",
	About = "À propos",
	Delete = "Supprimer",
	NoAccount ="Un seul compte, impossible de le supprimer.",
	ChooseAccounttoDelete = "Sélectionnez le compte à supprimer",
	ChooseChartoDelete = "Sélectionnez le caractère à supprimer",
	ChooseWorld ="Choisissez le serveur",
	YesLabel = "O",
	NoLabel = "N",
	Version = "Version",
	View_Toggle = "Masquer les éléments terminés",
	Completed = "Terminé le: ",
	Filter="Filtre",
	Detail="Détail",
}

-- These are the translations of the base game tabs.

L.box = {}
L.box["Public"] = "Public"
L.box["Trials Norm"] = "Trials Norm"
L.box["Trials Vet"] = "Trials Vet"
L.box["Trials Hard"] = "Trials Hard"

L.box["Group 1N"] = "Group 1N"
L.box["Group 1V"] = "Group 1V"
L.box["Group 1VH"] = "Group 1VH"
L.box["Group 2N"] = "Group 2N"
L.box["Group 2V"] = "Group 2V"
L.box["Group 2VH"] = "Group 2VH"
L.box["DLC Group"] = "DLC Group"

--[[ 
   Translations of the DLC, which appear under the DLC2 tab, are in the fr-DLC.lua file, which is system provided.
   to have your own private translations  of DLC2 names, create a file called  MYDLC.lua.  This file is not overwriten on upgrades


MyDLC_Names={
["Infinite Archive"] = "Archive",
["Seasons of the Worm Cult"] = "Worm Cult",
["Gold Road"] = "Fred",
}

--]]
