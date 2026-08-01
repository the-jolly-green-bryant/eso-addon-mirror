local lib = _G[LFDB_LIB_IDENTIFIER]

-- internal strings
SafeAddString(SI_LIB_FOOD_DRINK_BUFF_LIB_ASYNC_NEEDED, "Erreur: La bibliothèque \'LibAsync\' ne pas été chargée!", 0)

SafeAddString(SI_LIB_FOOD_DRINK_BUFF_EXPORT_START, "La recherche de nourriture / boisson a commencée. Cela peut prendre quelques secondes...", 0)
SafeAddString(SI_LIB_FOOD_DRINK_BUFF_EXPORT_FINISH, "Le recherche est terminée. Aucune nourriture ou boisson ont été exporté.", 0)
SafeAddString(SI_LIB_FOOD_DRINK_BUFF_ARGUMENT_MISSING, "<<1>>!\nParamètre manquant pour for |cFFFFFF/dumpfdb|r!\nUtilisez |cFFFFFFall|r - exporte la liste complète ou\n|cFFFFFFnew|r - exporte seulement la nourriture / boisson", 0)
SafeAddString(SI_LIB_FOOD_DRINK_BUFF_NO_BUFFS, "Il n'y a pas de buff actif.", 0)

SafeAddString(SI_LIB_FOOD_DRINK_BUFF_DIALOG_MAINTEXT, "<<1>> nourritures / boissons trouvé(s).\n\nVous devez recharger l'interface pour mettre à jour le fichier SavedVariables.\n\nRecharger l'interface maintenant?", 0)

-- API
SafeAddString(SI_LIB_FOOD_DRINK_BUFF_GENERAL_NO_BUFF_ACTIVE, "Aucun buff de nourriture ou de boisson actif.", 0)
SafeAddString(SI_LIB_FOOD_DRINK_BUFF_GENERAL_EXPIRES_SOON, "Votre buff de nourriture/boisson expire bientôt.", 0)
SafeAddString(SI_LIB_FOOD_DRINK_BUFF_GENERAL_EXPIRES_SOON_TIME, "Votre buff de nourriture/boisson expire dans  <<X:1>>.", 0)
SafeAddString(SI_LIB_FOOD_DRINK_BUFF_GENERAL_REMAINING, "<<X:1>> restant pour le buff de nourriture/boisson.", 0)
SafeAddString(SI_LIB_FOOD_DRINK_BUFF_CUSTOM_NO_BUFF_ACTIVE, "<<C:1>> n'est pas actif.", 0)
SafeAddString(SI_LIB_FOOD_DRINK_BUFF_CUSTOM_EXPIRES_SOON, "<<C:1>> va bientôt expirer.", 0)
SafeAddString(SI_LIB_FOOD_DRINK_BUFF_CUSTOM_EXPIRES_SOON_TIME, "<<C:1>> va expirer dans <<X:2>>.", 0)
SafeAddString(SI_LIB_FOOD_DRINK_BUFF_CUSTOM_REMAINING, "<<C:1>> restant pour <<X:2>>.", 0)

-- Blacklist
lib.BLACKLIST_STRING_PATTERN =
{
	"Invocation d'âme",
	"Expérience",
	"Bonus EXP",
	"Pélinal",
	"MillionHealth",
	"Ambroisie",
	"compétence d'alliance",
}