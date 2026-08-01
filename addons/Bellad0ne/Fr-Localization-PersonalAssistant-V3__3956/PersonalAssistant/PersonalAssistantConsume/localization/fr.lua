local PAC = PersonalAssistant.Constants
local PACOStrings = {
    -- =================================================================================================================
	-- Language specific texts that need to be translated --

	-- =================================================================================================================
	-- == MENU/PANEL TEXTS == --
	-- -----------------------------------------------------------------------------------------------------------------
	-- PAConsume Menu --
	SI_PA_MENU_CONSUME_DESCRIPTION = "PAConsume peut appliquer du poison ou consommer de la nourriture/boisson et des parchemins d'EXP",

	-- auto poison --
	SI_PA_MENU_CONSUME_POISON_HEADER = "Application automatique de poison",
	SI_PA_MENU_CONSUME_POISON_ENABLE = "Activer l'application automatique de poison",
	SI_PA_MENU_CONSUME_POISON_ENABLE_T = "Applique automatiquement votre poison le plus empilé après un combat s'il n'y en a plus sur l'arme",

	-- auto consume food & exp --
	SI_PA_MENU_CONSUME_FOOD_HEADER = "Consommation automatique de nourriture/boisson",
	SI_PA_MENU_CONSUME_EXP_HEADER = "Consommation automatique de parchemins d'EXP",
	SI_PA_MENU_CONSUME_CURRENT_FOOD_BUFF = "Buff de nourriture actuel pour ce personnage : ",
	SI_PA_MENU_CONSUME_CURRENT_EXP_BUFF = "Buff d'EXP actuel pour ce personnage : ",
	SI_PA_MENU_CONSUME_LABEL_ON = "Consommer automatiquement",
	SI_PA_MENU_CONSUME_LABEL_OFF = "Arrêter la consommation automatique",
	SI_PA_MENU_CONSUME_USE_NUMBER_FOOD = "Tampon (secondes avant)",
	SI_PA_MENU_CONSUME_USE_NUMBER_FOOD_T = "Secondes avant la fin du buff actuel pour utiliser un buff de nourriture. Utilisez un nombre entre 0 et 600 secondes pour modifier le temps tampon.",
	SI_PA_MENU_CONSUME_USE_NUMBER_EXP = "Tampon (secondes après)",
	SI_PA_MENU_CONSUME_USE_NUMBER_EXP_T = "Secondes après l'expiration du buff actuel pour utiliser un buff d'EXP. Utilisez un nombre entre 0 et 600 secondes pour modifier le temps tampon.",
	SI_PA_MENU_CONSUME_TURN_OFF_FOOD = "Suspendre",
	SI_PA_MENU_CONSUME_TURN_OFF_FOOD_T = "Arrêter temporairement la consommation de cette nourriture/boisson",
	SI_PA_MENU_CONSUME_TURN_OFF_EXP = "Suspendre",
	SI_PA_MENU_CONSUME_TURN_OFF_EXP_T = "Arrêter temporairement la consommation de ce buff d'EXP",

    -- =================================================================================================================
    -- == CHAT OUTPUTS == --
    -- -----------------------------------------------------------------------------------------------------------------
	-- PAConsume poison--
    SI_PA_CHAT_CONSUME_POISON_MAIN = "L'arme principale a été imprégnée de ",
    SI_PA_CHAT_CONSUME_POISON_BACKUP = "L'arme de secours a été imprégnée de ",
    
	-- PAConsume food & exp--
	SI_PA_CHAT_CONSUME_NO_FOOD = "Aucune nourriture n'a encore été sélectionnée. Ouvrez l'inventaire, faites un clic droit sur la pile de nourriture ou de boisson souhaitée, et choisissez l'option Consommer automatiquement.",
	SI_PA_CHAT_CONSUME_AUTO_EATING_OFF_BUT = "La consommation automatique est désactivée. Mais vous avez sélectionné <<1>> comme votre nourriture préférée.",
	SI_PA_CHAT_CONSUME_TO_ENABLE_EATING = "Pour activer la consommation automatique pour ce personnage, ouvrez l'inventaire, faites un clic droit sur la nourriture ou la boisson souhaitée, et choisissez l'option Consommer automatiquement.",
	SI_PA_CHAT_CONSUME_LOOKS_LIKE = "Il semble que <<1>> soit au menu.",
	SI_PA_CHAT_CONSUME_THIS_FOOD_WILL_BE_MINUTES = "Ceci sera consommé <<1[quand/$d minute avant/$d minutes avant]>> que votre nourriture actuelle expire.",
	SI_PA_CHAT_CONSUME_THIS_FOOD_WILL_BE_SECONDS = "Ceci sera consommé <<1[quand/$d seconde avant/$d secondes avant]>> que votre nourriture actuelle expire.",
	SI_PA_CHAT_CONSUME_YOU_HAVE_ONLY = "Il ne vous reste que <<1>> dans votre sac.", -- "Il vous reste <<1[$d/seulement $d/seulement $d]>> dans votre sac."
	SI_PA_CHAT_CONSUME_YOU_HAVE = "Il vous reste <<1>> dans votre sac.",
	SI_PA_CHAT_CONSUME_WISH_STOP_EATING = "Si vous souhaitez arrêter la consommation automatique pour ce personnage, utilisez le menu PAconsume.",
    
	SI_PA_CHAT_CONSUME_NO_EXP = "Aucun buff d'EXP n'a encore été sélectionné. Ouvrez l'inventaire, faites un clic droit sur la pile de parchemins d'EXP souhaitée, et choisissez l'option Consommer automatiquement.",
	SI_PA_CHAT_CONSUME_AUTO_EXPING_OFF_BUT = "La consommation automatique de buff d'EXP est désactivée. Mais vous avez sélectionné <<1>> comme votre buff d'EXP préféré.",
	SI_PA_CHAT_CONSUME_TO_ENABLE_EXPING = "Pour activer la consommation de buff d'EXP pour ce personnage, ouvrez l'inventaire, faites un clic droit sur la nourriture ou la boisson souhaitée, et choisissez l'option Consommer automatiquement.",
	SI_PA_CHAT_CONSUME_THIS_EXP_WILL_BE_MINUTES = "Cela sera consommé <<1[quand/$d minute après/$d minutes après]>> que votre buff d'EXP actuel expire.",
	SI_PA_CHAT_CONSUME_THIS_EXP_WILL_BE_SECONDS = "Cela sera consommé <<1[quand/$d seconde après/$d secondes après]>> que votre buff d'EXP actuel expire.",
	SI_PA_CHAT_CONSUME_WISH_STOP_EXPING = "Si vous souhaitez arrêter la consommation automatique du buff d'EXP pour ce personnage, utilisez le menu PAconsume.",
    
	SI_PA_CHAT_CONSUME_FOOD_WILL_BE_CONSUMED = "La nourriture sera consommée <<1>> secondes avant l'expiration de la nourriture actuelle.",
	SI_PA_CHAT_CONSUME_EXP_WILL_BE_CONSUMED = "Le buff d'EXP sera consommé <<1>> secondes après l'expiration du buff d'EXP actuel.",
    
	SI_PA_CHAT_CONSUME_HAS_BEEN_AUTOMATICALLY_CONSUMED = " a été consommé automatiquement.",
	SI_PA_CHAT_CONSUME_BUT_HAVE_ZERO = "Vous avez configuré <<1>> pour être consommé automatiquement mais vous en avez 0 dans votre sac.",
    
	SI_PA_CHAT_CONSUME_FOOD_EXPIRE_SECONDS = "Votre nourriture actuelle expirera dans <<1[$d secondes./$d seconde./$d secondes.]>>",
	SI_PA_CHAT_CONSUME_FOOD_EXPIRE_MINUTES = "Votre nourriture actuelle expirera dans <<1[$d minutes./$d minute./$d minutes.]>>",
	SI_PA_CHAT_CONSUME_EXP_EXPIRE_SECONDS = "Votre buff d'EXP actuel expirera dans <<1[$d secondes./$d seconde./$d secondes.]>>",
	SI_PA_CHAT_CONSUME_EXP_EXPIRE_MINUTES = "Votre buff d'EXP actuel expirera dans <<1[$d minutes./$d minute./$d minutes.]>>",

}

for key, value in pairs(PACOStrings) do
    SafeAddString(_G[key], value, 1)
end
