local STLLang = Stylich.Lang
STLLang.msg = STLLang.msg or {}
local m = STLLang.msg

-- Libellés de catégories d'apparence
m.CATEGORY_TYPE_COSTUME = 'Costume'
m.CATEGORY_TYPE_POLYMORPH = 'Polymorphe'
m.CATEGORY_TYPE_SKIN = 'Peau'
m.CATEGORY_TYPE_PERSONALITY = 'Personnalité'
m.CATEGORY_TYPE_HAT = 'Chapeau'
m.CATEGORY_TYPE_HAIR = 'Coiffure'
m.CATEGORY_TYPE_FACIAL_HAIR_HORNS = 'Pilosité faciale'
m.CATEGORY_TYPE_FACIAL_ACCESSORY = 'Ornements majeurs'
m.CATEGORY_TYPE_PIERCING_JEWELRY = 'Ornements mineurs'
m.CATEGORY_TYPE_HEAD_MARKING = 'Marquage de tête'
m.CATEGORY_TYPE_BODY_MARKING = 'Marquage corporel'
m.CATEGORY_TYPE_VANITY_PET = 'Familier'
m.CATEGORY_TYPE_MOUNT = 'Monture'
m.GEAR_APPEARANCE = 'Apparence (arme)'

-- Libellés de champs / sections
m.STYLE = 'Style'
m.OUTFIT = 'Tenue'
m.TITLE = 'Titre'
m.HOTKEY = 'Raccourci'
m.MEMENTO = 'Mémento'
m.REVEAL = 'Délai'
m.COMPANION = 'Compagnon'
m.COMPANION_NONE = '- Aucun -'
m.COMPANION_KEEP = '- Ne pas toucher -'
m.WEAPONS = 'Armes'
m.APPLY_SECTION = "À L'APPLICATION"
m.OPTIONS = 'Options'

-- Entrées de listes déroulantes
m.SLOT = 'Slot'
m.HOTKEY_NONE = '- Aucun -'
m.MEMENTO_NONE = '- Aucun -'
m.NO_OUTFIT = '- Aucune tenue -'
m.NO_TITLE = '- Aucun titre -'
m.WEAPON_UNEQUIP = 'Emplacement vide (déséquipe)'
m.WEAPON_NONE = "Garder l'arme actuelle (cet emplacement n'est pas modifié)"

-- Panneau d'options
m.OPT_SHOW_BUTTON = 'Afficher le bouton flottant'
m.OPT_SHOW_DROPDOWN = 'Afficher la liste de changement rapide'
m.OPT_LOCK_BUTTON = 'Verrouiller la position du bouton flottant'
m.OPT_PLAY_MEMENTOS = "Jouer les mémentos d'entrée à l'application d'un style"
m.OPT_HIDE_ON_MENUS = "Masquer Stylich quand un menu est ouvert"
m.OPT_CLOSE_COMBAT = "Fermer la fenêtre en entrant en combat"
m.OPT_HELP =
	"|cFFAA33Créer un style|r\n"..
	"- Compose ton look en jeu, puis clique sur Mettre à jour pour le capturer.\n"..
	"- Ou glisse une arme depuis ton inventaire sur un emplacement d'arme.\n"..
	"- Clic droit sur un emplacement d'arme pour alterner : vide (déséquipe) ou ne pas toucher (garde ton arme).\n"..
	"- Choisis une Tenue, un Titre et un Mémento d'entrée dans les listes.\n\n"..
	"|cFFAA33Mémento d'entrée|r\n"..
	"Quand tu appliques un style, son mémento se joue pour masquer le changement - ton nouveau look se révèle à la fin de l'animation. Si le mémento est encore en récupération, le style ne change pas (pour que la révélation ait toujours lieu)."

-- Dialogues de confirmation
m.CONFIRM_UPDATE_TITLE = 'Mettre à jour le style'
m.CONFIRM_UPDATE_TEXT = "Écraser « <<1>> » avec ton apparence actuelle ?"
m.CONFIRM_DELETE_TITLE = 'Supprimer le style'
m.CONFIRM_DELETE_TEXT = "Supprimer le style « <<1>> » ?"

-- Infobulles des boutons
m.TT_NEW = 'Nouveau style'
m.TT_RENAME = 'Renommer / propriétés'
m.TT_UPDATE = "Mettre à jour depuis l'apparence actuelle"
m.TT_APPLY = 'Appliquer le style'
m.TT_DELETE = 'Supprimer le style'
m.TT_OPTIONS = 'Options'
m.TT_REVEAL = "Délai avant que ton nouveau look apparaisse sous le mémento d'entrée. Court = révélation rapide ; long = le mémento masque le changement plus longtemps. À caler selon la durée de ton mémento."

-- Libellés des raccourcis
m.BIND_SHOW = 'Ouvrir/fermer la fenêtre'
m.BIND_SLOT = 'Appliquer le style du slot'

-- Messages du chat
m.MSG_NO_STYLE_SLOT = "Stylich : aucun style n'est assigné au slot <<1>>."
m.MSG_CREATED = "Stylich : « <<1>> » créé."
m.MSG_MEMENTO_COOLDOWN = "Stylich : mémento d'entrée pas prêt (<<1>>s) - style non appliqué."
m.MSG_WEAPON_NOT_FOUND = "Stylich : arme introuvable : <<1>>."
m.MSG_WEAPON_DUP = "Stylich : cette arme est déjà assignée à un autre emplacement."
m.MSG_WEAPON_ONLY = "Stylich : seules les armes peuvent être déposées ici."
m.MSG_NO_SPACE = "Stylich : pas assez de place dans le sac pour déséquiper <<1>>."
m.MSG_COMBAT_WEAPONS = "Stylich : impossible de changer d'armes en combat."
