--[[
Author: Ayantir
Updated by Lykeion
Filename: fr.lua
Version: 6.0.0
]]--

local strings = {
SI_BINDING_NAME_SUPERSTAR_SHOW_PANEL=		"Toggle SuperStar",
	
SUPERSTAR_RESPECFAV_SP=							"Réattribuer les Compétences",
SUPERSTAR_RESPECFAV_CP=							"Réattribuer les Points Champion",
SUPERSTAR_SAVEFAV=									"Enregistrer le favori",
SUPERSTAR_VIEWFAV=									"Voir les compétences",
SUPERSTAR_VIEWHASH=								"Voir le favori",
SUPERSTAR_UPDATEHASH=                                 "Mettre à jour le favori",

SUPERSTAR_REMFAV=									"Supprimer le favori",
SUPERSTAR_FAVNAME=									"Nom du favori",
	
SUPERSTAR_CSA_RESPECDONE_TITLE=				"Archétype changé",
SUPERSTAR_CSA_RESPECDONE_POINTS=				"<<1>> compétences assignées",
SUPERSTAR_CSA_RESPEC_INPROGRESS=				"Réattribution des points en cours",
SUPERSTAR_CSA_RESPEC_TIME=						"L'opération prendra environ <<1>> <<1[minutes/minute/minutes]>>",

SUPERSTAR_RESPEC_SPTITLE=						"Vous allez réattribuer vos |cFF0000compétences|r avec l'archétype suivant :\n\n <<1>>",
SUPERSTAR_RESPEC_CPTITLE=						"Vous allez réattribuer vos |cFF0000points champion|r avec l'archétype suivant :\n\n <<1>>",

SUPERSTAR_RESPEC_ERROR1=							"Impossible de réattribuer les points, Classe invalide",
SUPERSTAR_RESPEC_ERROR2=							"Attention: Les points de compétence actuels sont inférieurs aux exigences du modèle. La respec peut être incomplète",
SUPERSTAR_RESPEC_ERROR3=							"Attention: La race définie dans l'archétype n'est pas la vôtre, les points raciaux ne seront pas définis",
SUPERSTAR_RESPEC_ERROR5=							"Impossible de réattribuer les points champion, vous n'êtes pas un Champion",
SUPERSTAR_RESPEC_ERROR6=							"Impossible de réattribuer les points champion, pas assez de points champion",

SUPERSTAR_RESPEC_SKILLLINES_MISSING=			"Attention: Les lignes de compétence suivantes ne sont pas débloquées et ne seront pas définies",
SUPERSTAR_RESPEC_CPREQUIRED=					"Cet archétype définira <<1>> Points Champion",

SUPERSTAR_RESPEC_INPROGRESS1=					"Compétences de classe définies",
SUPERSTAR_RESPEC_INPROGRESS2=					"Compétences d'arme définies",
SUPERSTAR_RESPEC_INPROGRESS3=					"Compétences d'armure définies",
SUPERSTAR_RESPEC_INPROGRESS4=					"Compétences du monde définies",
SUPERSTAR_RESPEC_INPROGRESS5=					"Compétences de guilde définies",
SUPERSTAR_RESPEC_INPROGRESS6=					"Compétences de guerre d'alliance définies",
SUPERSTAR_RESPEC_INPROGRESS7=					"Compétences de race définies",
SUPERSTAR_RESPEC_INPROGRESS8=					"Compétences d'artisanat définies",

SUPERSTAR_IMPORT_MENU_TITLE=					"Importer",
SUPERSTAR_FAVORITES_MENU_TITLE=				"Favoris",
SUPERSTAR_RESPEC_MENU_TITLE=					"Respec",
SUPERSTAR_SCRIBING_MENU_TITLE				= "Écriture Simulateur",

SUPERSTAR_XML_BUTTON_SHARE				= "Partager SuperStar (/sss)",
SUPERSTAR_XML_BUTTON_SHARE_LINK				= "Partager avec les liens du jeu (/ssl)",

SUPERSTAR_DIALOG_SPRESPEC_TITLE=				"Set skill points",
SUPERSTAR_DIALOG_SPRESPEC_TEXT=				"Set skill points according to the template selected ?",

SUPERSTAR_DIALOG_REINIT_SKB_ATTR_CP_TITLE=	"Réinitialiser le Simulateur",
SUPERSTAR_DIALOG_REINIT_SKB_ATTR_CP_TEXT=	"Vous êtes sur le point de réinitialiser le Simulateur de compétences qui contient des points d'attribut et/ou des points champion.\n\nFaire ceci réinitialisera également ces valeurs.\n\nSi vous souhaitez réinitialiser une compétence, faites simplement un clic droit sur son icône.",

SUPERSTAR_DIALOG_CPRESPEC_NOCOST_TEXT=		"Vous êtes sur le point de réattribuer vos Points Champion.\n\nCe changement sera gratuit",


	
SUPERSTAR_QUEUE_SCRIBING						= "File d'attente pour l'Écriture",
SUPERSTAR_CLEAR_QUEUE							= "Vider la file d'attente",

SUPERSTAR_DIALOG_QUEUE_REJECTED_TITLE			= "File d'attente Rejeté",
SUPERSTAR_DIALOG_QUEUE_REJECTED_TEXT			= "La compétence en attente sera fabriquée automatiquement la prochaine fois que vous utiliserez Autel d'Écriture\nLes anciennes compétences en attente seront écrasées par les nouvelles compétences utilisant le même grimoire\n\nCertaines des compétences actuellement choisies ne sont pas encore débloquées, vous ne pouvez pas les ajouter à la file d'attente d'Écriture",
SUPERSTAR_DIALOG_QUEUE_FOR_SCRIBING_TEXT		= "La compétence en attente sera fabriquée automatiquement la prochaine fois que vous utiliserez Autel d'Écriture\nLes anciennes compétences en attente seront écrasées par les nouvelles compétences utilisant le même grimoire\n\nVous êtes sur le point de mettre en file d'attente les compétences que vous avez choisies pour être fabriquées",
SUPERSTAR_DIALOG_CLEAR_QUEUE_TEXT		        = "Vous êtes sur le point d'effacer les compétences qui ont été ajoutées à la file d'attente de l'Écriture\n\nAucune compétence ne sera fabriquée automatiquement la prochaine fois que vous utiliserez Autel d'Écriture.",
SUPERSTAR_DIALOG_MAJOR_UPDATE_TEXT              = "SuperStar a été mis à jour pour la mise à jour 50 !\n\nL'addon prend désormais en charge l'affichage <<1>>.\nLa fonction de lien de partage SuperStar a également été réécrite. Elle est maintenant plus stable et prête pour les refontes de classes à venir.",

-- Chatbox Info:
SUPERSTAR_CHATBOX_PRINT			        		= "Cliquez pour voir",
SUPERSTAR_CHATBOX_QUEUE_INFO			        = "|c215895[Super|cCC922FStar]|r <<1>> compétences dans la file d'attente, <<2>> Ink attendues pour être consommées, propre <<3>>",
SUPERSTAR_CHATBOX_QUEUE_WARN			        = "|c215895[Super|cCC922FStar]|r <<1>> compétences dans la file d'attente, <<2>> Ink attendues pour être consommées, propre <<3>>",
SUPERSTAR_CHATBOX_QUEUE_ABORTED		            = "|c215895[Super|cCC922FStar]|r Auto Écriture a été abandonné en raison d'une interruption. La file d'attente a été vidée",
SUPERSTAR_CHATBOX_QUEUE_CANCELED		        = "|c215895[Super|cCC922FStar]|r Auto Écriture a été annulé par manque d'encre. Besoin <<1>>, propre <<2>>",
SUPERSTAR_CHATBOX_TEMPLATE_OUTDATED		        = "|c215895[Super|cCC922FStar]|r Le modèle est obsolète, veuillez le recréer",
SUPERSTAR_CHATBOX_SUPERSTAR_OUTDATED		    = "|c215895[Super|cCC922FStar]|r Liens SuperStar non résolus. Il est possible que vous ou l'autre partie n'utilisiez pas la dernière version de SuperStar, ou que certains caractères du lien aient été bloqués par le système de censure du chat",

SUPERSTAR_XML_SKILL_BUILD				= 		"Constructeur de compétences",
SUPERSTAR_XML_SKILL_BUILD_EXPLAIN				= "Commencez votre build de compétences en sélectionnant votre race ici.Vous pouvez sauvegarder ce build comme modèle pour vos futurs respecs.\n\nClasse secondaire entièrement supporté! Ajoutez n'importe quelle branche de compétences de classe à votre build. SuperStar détecte et applique automatiquement toutes vos compétences disponibles lors du respec.",
SUPERSTAR_SCENE_SKILL_RACE_LABEL=				"Race",

SUPERSTAR_XML_CUSTOMIZABLE=						"Personnalisable",
SUPERSTAR_XML_GRANTED=							"Débloqués",
SUPERSTAR_XML_TOTAL=								"Total",
SUPERSTAR_XML_BUTTON_FAV=						"Favori",
SUPERSTAR_XML_BUTTON_FAV_WITH_CP				= "Sauvegarder avec CP",
SUPERSTAR_XML_BUTTON_REINIT=					"Réinitialiser",
SUPERSTAR_XML_BUTTON_EXPORT=					"Export",
SUPERSTAR_XML_NEWBUILD=							"Nouvel archétype :",
SUPERSTAR_XML_BUTTON_RESPEC=					"Respec",
SUPERSTAR_XML_BUTTON_START=					"Start",

SUPERSTAR_XML_IMPORT_EXPLAIN=					"Importer d'autres builds avec ce formulaire\n\nLes builds peuvent contenir des points champion, des points de compétence et des points d'attribut.",
SUPERSTAR_XML_FAVORITES_EXPLAIN=				"Vous pouvez utiliser des modèles sauvegardés pour vous respectez automatiquement. Il est recommandé de sauvegarder à l'avance un modèle de base dans l'arsenal afin de pouvoir appliquer un modèle différent à chaque fois. \n\nVeuillez noter que si la réinitialisation inclut un point de champion, elle coûtera de l'or.",

SUPERSTAR_XML_SKILLPOINTS=						"Points de compétence",
SUPERSTAR_XML_CHAMPIONPOINTS=					"Points champion",

--SUPERSTAR_MAELSTROM_WEAPON=						"Maelström",
SUPERSTAR_DESC_ENCHANT_MAX=						" maximale",

SUPERSTAR_DESC_ENCHANT_SEC=						" secondes",
SUPERSTAR_DESC_ENCHANT_SEC_SHORT=				" secs",

SUPERSTAR_DESC_ENCHANT_MAGICKA_DMG=			" dégâts de Magie",
SUPERSTAR_DESC_ENCHANT_MAGICKA_DMG_SHORT=	" dégâts Magie",

SUPERSTAR_DESC_ENCHANT_BASH=					" Percussion",
SUPERSTAR_DESC_ENCHANT_BASH_SHORT=			" Percu",

SUPERSTAR_DESC_ENCHANT_REDUCE=					" et réduit le coût",
SUPERSTAR_DESC_ENCHANT_REDUCE_SHORT=			" et",

SUPERSTAR_IMPORT_ATTR_DISABLED=				"Incl. Attributs",
SUPERSTAR_IMPORT_ATTR_ENABLED=					"Supppr. Attributs",
SUPERSTAR_IMPORT_SP_DISABLED=					"Incl. Compétences",
SUPERSTAR_IMPORT_SP_ENABLED=					"Supppr. Compétences",
SUPERSTAR_IMPORT_CP_DISABLED=					"Incl. Points Champion",
SUPERSTAR_IMPORT_CP_ENABLED=					"Supppr. Points Champion",
SUPERSTAR_IMPORT_BUILD_OK=						"Build Valide, le voir !",
SUPERSTAR_IMPORT_BUILD_NO_SKILLS=				"Ce Build n'a pas de compétences associées",
SUPERSTAR_IMPORT_BUILD_NOK=						"Build Incorrect, Vérifiez votre Hash",
SUPERSTAR_IMPORT_BUILD_LABEL=					"Importer un build : coller le hash",
SUPERSTAR_IMPORT_MYBUILD=						"Mon Build",

--SUPERSTAR_XML_SWITCH_PLACEHOLDER=				"Switchez d'armes pour la 2nde barre",

SUPERSTAR_XML_FAVORITES_HEADER_NAME				= "Name",
SUPERSTAR_XML_FAVORITES_HEADER_CP				= "CP",
SUPERSTAR_XML_FAVORITES_HEADER_SP				= "SP",
SUPERSTAR_XML_FAVORITES_HEADER_ATTR				= "Attr",
SUPERSTAR_EQUIP_SET_BONUS= "Set",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end


ZO_CreateStringId("SUPERSTAR_SLOTNAME20",						"Alt. main droite", 1) -- No EN
ZO_CreateStringId("SUPERSTAR_SLOTNAME21",						"Alt. main gauche", 1) -- No EN

ZO_CreateStringId("SUPERSTAR_CHAMPION_SKILL2NAME1",		"Armure lourde", 1) -- No EN
ZO_CreateStringId("SUPERSTAR_CHAMPION_SKILL3NAME1",		"Armure légère", 1) -- No EN
ZO_CreateStringId("SUPERSTAR_CHAMPION_SKILL4NAME1",		"Armure moyenne", 1) -- No EN
ZO_CreateStringId("SUPERSTAR_CHAMPION_SKILL6NAME1",		"Exp CàC", 1) -- No EN