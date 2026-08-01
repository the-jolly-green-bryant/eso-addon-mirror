local ShowMotifs = _G['ShowMotifs']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- French (Thanks to ESOUI.com user lexo1000 for the translation!)
-- Non-indented lines still need human translation and may not make sense.
------------------------------------------------------------------------------------------------------------------

-- Addon Setting Strings
    L.GENERAL                   = "Général"
    L.ICON_THEME                = "Style des symboles"
    L.ICON_THEME_TOOLTIP        = "Détermine l'apparence des icônes affichées à côté du nom des objets dans l'inventaire."
    L.ICON_SIZE                 = "Taille des symboles de motif"
    L.ICON_SIZE_TOOLTIP         = "Détermine la dimension des icônes de motifs raciaux."
    L.ARMOR_ICON_SIZE           = "Taille des symboles de type d'armure"
    L.ARMOR_ICON_SIZE_TOOLTIP   = "Détermine la taille des icônes de type d'armure."
    L.II_POSITION               = "Position des symboles dans l'inventaire"
    L.II_POSITION_TOOLTIP       = "Détermine la position relative des icônes dans l'inventaire."
    L.GSS_POSITION              = "Position des symboles dans le magasin de guilde"
    L.GSS_POSITION_TOOLTIP      = "Détermine la position relative des icônes dans les résultats de recherche des magasins de guilde."
    L.GSL_POSITION              = "Position des symboles dans la liste de guilde"
    L.GSL_POSITION_TOOLTIP      = "Détermine la position relative des icônes sur le panneau d'annonce des magasins de guilde."
    L.RACIAL                    = "Afficher les symboles de motifs raciaux"
    L.RACIAL_TOOLTIP            = "Active l'affichage des symboles de motifs raciaux."
    L.ARMOR                     = "Afficher les symboles de type d'armure"
    L.ARMOR_TOOLTIP             = "Active l'affichage des symboles de type d'armure."
    L.LETTER                    = "Utiliser des lettres"
    L.LETTER_TOOLTIP            = "Affiche des lettres à la place des symboles pour représenter le type d'armure.\n\n(L)ight  -  armure légère\n(M)edium  -  armure moyenne\n(H)eavy  -  armure lourde"
    L.COLOR                     = "Colorer les symboles"
    L.COLOR_TOOLTIP             = "Affiche les symboles en couleur selon la qualité de l'objet."
    L.TOOLTIP                   = "Afficher les infobulles"
    L.TOOLTIP_TOOLTIP           = "Affiche une infobulle lorsque le curseur de la souris est placé sur un symbole."

------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'fr') then -- overwrite GetLanguage for new language
	for k, v in pairs(ShowMotifs:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function ShowMotifs:GetLanguage() -- set new language return
		return L
	end
end
