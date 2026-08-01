--[[----------------------------------------------------------
    CurvyHud 
    ----------------------------------------------------------
	Localization 	: 	/Loc/FR.lua 
    Original Author	:	Niocwy
	Update Author 	:	Vvarderen
	Translator		:	Vvarderen
    Version			: 	6.12
    Updated			:  	2020-06-20 (YYYY-MM-DD)
----------------------------------------------------------]]--

CurvyHud.FR = {}

local L = CurvyHud.FR
CurvyHud.avatarName	= GetUnitName("player")
-------------
-- ADDON INFO
-------------
L.CurvyHud 		= "CurvyHud"
L.CurvyHudinfo 	= "|c922BFFCurvyHud|cFFFFFF : "
L.authors 		= "|cFF0000Niocwy |cFFFFFF(auteur original) & |c7B18FFVvarderen |cFFFFFF(auteur de mise à jour)"

-----------------------
-- MENU SHARED ELEMENTS
-----------------------
L.MenuEnable 	= "Activer"
L.MenuDisable 	= "Désactiver"

L.Major 	= "Majeures"
L.Minor		= "Mineures"

L.ChoiceUnit = "Choix de l'unité"
L.PlayerUnit = "Joueur"
L.TargetUnit = "Cible"

L.Font 		= "Police de caractères"
L.FontSize 	= "Taille de la police de caractères"

L.Reload	= "Recharger "
L.Chrono	= "Démarrer\\pause\\arrêt Chrono"

---------------------
-- PROFILS MANAGEMENT
---------------------
L.ProfilsMgtHeader 			= "Gestionnaire de Profils"
L.ProfilsMgtHeaderdesc 		= "Le ou les profils par défaut sont précédés par * et ne peuvent pas être remplacés."
L.ProfilsMgtEndHeaderdesc 	= "Cliquez sur \"|c1CA8D6Charger|cFFFFFF\" pour recharger l'interface avec les paramètres liés au profil sélectionné. \n\"|c1CA8D6Sauver|cFFFFFF\" remplacera le profil sélectionné par la configuration actuelle."
L.ProfilsMgtdefaultProfil 	= "* Profils par défaut "
L.ProfilsMgtBtnLoad 		= "Charger"
L.ProfilsMgtBtnLoadWarning 	= "Celà nécessitera rechargement de CurvyHud ( /reloadui dans le chat)!"
L.ProfilsMgtBtnSave 		= "Sauver"
L.ProfilsMgtBtnSaveWarning 	= "La sauvegarde écrasera le profil sélectionné !"

-- New Profil
L.ProfilsMgtCreatNewProfilSubMenu 	= "Créer un nouveau profile"
L.Profils 				= "Le profil|cFF9500 "
L.ProfilsCreat 			= "|cFFFFFF à été créé."
L.ProfilsSaved 			= "|cFFFFFF à été sauvé."
L.ProfilsLoaded 		= "|cFFFFFF à été chargé."
L.ProfilsSelected 		= "|cFFFFFF à été selectionné."
L.ProfilsMgtNewdesc 	= "Pour créer un nouveau profil basé sur la configuration actuelle, entrez un nom dans le champs prévu à cet effet et cliquez sur \"|c1CA8D6Créer|cFFFFFF\". Caractères autorisés : |c1CA8D6lettres |cFFFFFF(min/maj)|c1CA8D6, chiffres, _ |cFFFFFFet |c1CA8D6- |cFFFFFF \n \n |cff9544En cas de non respect des règles de formatage précédament données, le bouton \"Créer\" ne sera pas disponible.|cFFFFFF \n"
L.ProfilsMgtBtnNew 		= "Créer"
L.ProfilsMgtBtnNewTooltip 	= "Créez un nouveau profil avec le nom entré"
L.ProfilsMgtBtnNewWarning 	= "Celà nécessitera un \"Reloadui\", soit un rechargement de CurvyHud."
L.ProfilsMgtTextNewdesc 	= "Pour mettre à jour l'état du bouton \"|c1CA8D6Créer|cFFFFFF\", cliquez sur le bouton lui-même ou en dehors du champs prévu pour recevoir votre nom de profil.  |cFF0000ATTENTION |cFFFFFF il ne sera pas possible de créer un profil |cFF0000avec un nom déjà existant ou ne respectant pas la régle de nommage|cFFFFFF!!"

-- Move Mode
L.Move_ModeDiv			= "Mode Déplacement"
L.Move_ModeDesc 		= "|c1CA8D6Activer|cFFFFFF ou |c1CA8D6désactiver|cFFFFFF le mode déplacement pour pouvoir positionner les containers à votre guise."
L.Move_ModeLockValues 	= "Ancrer les valeurs aux barres"
L.Move_ModeLockValuesTooltip = "Déplacer les barres déplacera aussi les valeurs. Vous pourrez toutefois continuer à déplacer les valeurs indépendamment des barres. "
L.Move_ModeShowAllDesc	= "|cFF0000Ne fonctionne que si le mode déplacement est activé \n|c1CA8D6Activer|cFFFFFF ou |c1CA8D6désactiver|cFFFFFF l'affichage de tous effets avec les configurations associés. Pour la démonstration, |c00FF00votre vie est réduite d'un tier|cFFFFFF et vous avez un |c00FF00bouclier virtuel de +4560 points."
L.Move_ModeDescWarning 	= "|cFF0000Ne fonctionne que si le mode déplacement est activé"
L.Move_ModeShowDesc		= "Portez-vous dans le sous-menu |c1CA8D6Effets actifs|cFFFFFF puis |c1CA8D6Démonstration des effets|cFFFFFF ou |c1CA8D6Démonstration des boucliers|cFFFFFF pour filtrer les infos de votre choix."

L.Move_targetNameplate 	= "Plaque informative sur la cible"
L.Move_taunt			= "Provocation"
L.Move_barContainerLeft = "Barres de gauche"
L.Move_barContainerRight= "Barres de droite"
L.Move_interactionPrompt= "Interaction avec les objets"
L.Move_PlayerinteractionPrompt 	= "Interaction avec un joueur"
L.Move_healthBarText 	= "Santé"
L.Move_magickaBarText 	= "Magie"
L.Move_staminaBarText 	= "Vigueur"
L.Move_targetBarText 	= "Santé de la Cible"
L.Move_mountBarText 	= "Vigueur de la monture"
L.Move_werewolfBarText 	= "Chrono de loup garou"
L.Move_siegeBarText 	= "Santé arme de siège"
L.Move_shieldText 		= "Bouclier"
L.Move_targetShieldText = "Bouclier de la cible"
L.Move_combatTips 		= "Aide au combat"	
L.Move_LowAttributesAlert = "Attributs faibles"	
L.Move_CoordsHeader 	= "Coordonnées des Containeurs et barres"
L.Move_clepsydre		= "Horloge & chrono"

L.Move_Enable 	= "Déplacement des containers |c00FF00activé"
L.Move_Disable 	= "Déplacement des containers |cFF0000désactivé"

-------
-- Demo
-------
L.Demobars			= "Afficher un bouclier et vie à 50%"

------------------------
-- VISLUATION OF EFFECTS
------------------------
L.ShowEffectsSubMenu 	= "Visualisation des effets"
L.ShowMoveModeDesc		= "Vous devez avoir activé le Mode Déplacement pour voir le résultat"

-- Name of types
L.PhysicalInc		= "Résistances Physiques augmentées"
L.SpellInc			= "Résistances Magiques augmentées"
L.PhysicalDec		= "Résistances Physiques réduites"
L.SpellDec			= "Résistances Magiques réduites"
L.PhysicalDual		= "Résistances Physiques antinomiques"
L.SpellDual			= "Résistances Magiques antinomiques"

-- Color effect
L.PhysResistIncColor	= "Physiques augmentées"
L.PhysResistDecColor	= "Physiques réduites"
L.SpellResistIncColor	= "Magiques augmentées"
L.SpellResistDecColor	= "Magiques réduites"
L.PhysResistDualColor	= "physiques antinomiques"
L.SpellResistDualColor	= "Magiques antinomiques"

--------------------------------------
-- CONTAINER AND BARS GLOBAL SETTINGS
--------------------------------------
L.GlobalSettingsSubMenu = "Paramètres généraux"

-- Containers settings
L.BarStyle 			= "Style"
L.BarStyleTooltip 	= "Configure le style appliqué aux barres d'attributs du joueur et de la cible." 
L.Default_bar 		= "Par défaut"
L.Oblivion_bar 		= "Oblivion"
L.Flat_bar			= "Plates"
L.Ghost_bar 		= "Fantômatique"

-- Bars stairway
L.ContainerDiv 			= "Mode escalier"
L.ContainerLeftForm 	= "Container de gauche"
L.ContainerRightForm 	= "Container de droite"
L.ContainerStyleNormal 	= "Normal"
L.ContainerStyleStairway= "Escalier"

-- Global settings of bars
L.BarDiv 	= "Configuration des barres"
L.BarSpacing= "Espacement"
L.BarWidth 	= "Largeur"
L.BarHeight = "Hauteur"

-- Opacity settings
L.OpacityDiv 			= "Opcaité des barres"
L.OpacityOoc 			= "Hors du combat (vous)"
L.OpacityAttributeUsed 	= "Attributs en utilisation (vous)"
L.OpacityCombat 		= "En combat (toutes barres)"
L.OpacityTargetOoc 		= "Cible hors combat"
L.OpacityTargetinCombat = "Cible en combat"

----------------------
-- GENERAL TEXT FORMAT
----------------------
L.FormatDiv				= "Paramètres des valeurs des barres"
L.FormatDecSep			= "Afficher le séparateur décimal"
L.FormatDecPer			= "Afficher un chiffre après la virgule"

---------------------
-- NAMEPLATE SETTINGS
---------------------
L.NameplateSubMenu 		= "Plaque de la cible"

-- General settings
L.NamePlateDiv 			= "Paramètres de base"
L.NamePlateFontSizeTooltip = "Modifi la taille de tous les élements contenus dans les infos de la cible"

L.NampletePlayer 		= "Identification : "
L.NameplateAvatar 		= "Personnage"
L.NameplateAccount 		= "Compte"
L.NameplateAllone 		= "Personnage et compte"
L.NameplateAlltow 		= "Compte et personnage" 

-- Icons on nameplate and colors
L.NamePlateIconDiv 	= "Paramètres des icônes"
L.NamePlateClass 	= "Afficher la classe"
L.NamePlateLevel	= "Afficher le niveau des joueurs"
L.NamePlateRace 	= "Afficher la race"
L.NamePlateRank 	= "Afficher le grade JcJ"
L.NamePlateAlliance = "Afficher l'alliance"
L.NamePlateCaption	= "Afficher le titre des joueurs"

L.NamePlateIconColor = "Couleur des icônes"
L.Julianos 	= "Blanc"
L.Gold 		= "Or"
L.Silver 	= "Argent"
L.Alliance 	= "Alliance"

-- Boss and guards on nameplate
L.BossStyle = "Style des icônes des boss"

L.Default_boss 	= "Par défaut"
L.Star_boss 	= "Etoile"
L.Dsword_boss 	= "Epées croisées"
L.Obli_boss 	= "Oblivion"
L.Skull_boss 	= "Crâne"
L.NoneIcon_boss = "Aucun icône"

L.GuardColor 	= "Couleur des îcones des gardes"

-- Critters & deaths
L.NamePlateCrittersDiv 	= "Afficher les morts & bestioles"
L.ShowCrittersTooltip	= "Afficher les bestioles"
L.ShowDeadsTooltip		= "Afficher les morts"

-----------------------------------
-- DIFERENTIATION OF THE TARGET BAR
-----------------------------------
L.diffOfTargetsSubMenu = "Différenciation de la barre des cibles"

-- friendly health bar
L.AllyColorBarDiv 	= "Joueur allié"
L.AllyColorBarDesc 	= "Permet de colorer automatiquement la barre de la cible en bleu (par défaut) si la cible est un joueur ou en jaune (contre rouge par défaut) si cible est un PNJ neutre." 

-- Neutral NPC
L.NeutralTragetDiv 		= "PNJ neutre"
L.NeutralTragetTooltip 	= "Si activé, la barre de vie des PNJ neutres sera de la couleur de leur réaction (jaune). En revenche, les gardes et autres monstres élites auraont une barre de vie rouge même si ils sont neutres."

-------
-- BARS
-------
L.BarsSubMenu = "Paramètres des barres"

-- Choice of bar
L.SelectedBarDiv 			= "Configuration"
L.SelectedBar 				= "Choix de la barre"
L.SelectedBarShowTooltip 	= "Désactiver la barre CurvyHud selectionnée affichera la barre Zenimax par défaut correspondante à la place."

L.Health 	= "Barre de Santé"
L.Stamina 	= "Barre de Vigueur"
L.Magicka 	= "Barre de Magie"
L.Target 	= "Barre de Santé de la cible"
L.Mount 	= "Barre de Vigueur de la monture"
L.Siege 	= "Barre de Santé de l'arme de siége"
L.Werewolf 	= "Barre de Chrono de loup-garou"

-- bars and containers
L.BarPosition 	= "Conteneur"
L.Left 			= "Gauche"
L.Right 		= "Droit"
L.Index 		= "Position"
L.IndexTooltip 	= "Position dans le conteneur. 1 est le plus proche du centre de l'écran"
L.BarColorMax 	= "Couleur de la barre au maximum"
L.BarColorLow 	= "Couleur de la barre au minimum"
L.Border		= " les bordures de la barre"
L.BarBkgrdColor	= "Couleur de l'arrière plan"

-- texts of attributes
L.TextBar 		= " le texte de la barre sélectionnée"
L.TextFormat 	= "Format de la valeur du texte"
L.TextFormatTooltip = "{val} / {max} - {per}% affichera toutes les valeurs. \n {val} / {max} affichera tout sauf le pourcentage. \n {per}% affichera uniquement le pourcentage."

-- Color text of the attribute
L.TextColor 	= "Couleur de la valeur du texte"
L.DefaultColor 	= "Couleur par défaut"
L.AttibuteColor = "Couleur de l'attribut"

----------------------------------------------------	
-- INCREASE / DECREASE RESISTANCES and TAUNT EFFECTS
----------------------------------------------------
L.EffectsSettingsSubMenu = "Effets de Résistance et provocation"

-- Major/minor Effects
L.MajorIncEffect = " les effets majeurs positifs"
L.MajorDecEffect = " les effets majeurs negatifs"
L.MinorIncEffect = " les effets mineurs positifs"
L.MinorDecEffect = " les effets mineurs negatifs"
L.DualEffect		= " les effets antinomiques"
L.DualEffectTooltip	= "Remplace les effets de réduction et d'augmentation d'un même type par un autre effet à des fins de clareté. Exemple : si vous êtres sous \"résolution majeure\" et que vous subissez  \"fracture majeure\", les deux barres seront remplacées par la barre antinomique physique."

-- Taunt effect
L.TauntEffectDiv 	= "Provocation"

-----------------------------------	
-- REGEN / DEGEN and SHIELD EFFECTS
-----------------------------------
L.VisualsSettingsSubMenu = "Regen/Degen et bouclier"

-- Regen/Degen
L.RegenDiv 			= "Regen et Degen"

-- Shield
L.ShieldDiv 		= "Bouclier"
L.ShieldColor 		= "Couleur du bouclier"
L.ShieldTextShow 	= "Afficher les valeurs du bouclier"
L.ShieldTextColor 	= "Couleur des valeurs du bouclier"

----------------
-- COMBAT HELPER
----------------
L.CombatHelperSubMenu = "Attributs faibles & Aide au combat"

-- Low attributes
L.LowAttribDiv 		= "Attributs faibles"
L.LowAttribHealth 	= "Santé faible!"
L.LowAttribStamina 	= "Endurance faible!"
L.LowAttribMagicka 	= "Magie faible!"
L.LowAttribTrigger 	= "Seuil d'alerte"

-- Combat tips
L.TipsDiv 		= "Aide au combat"
L.TipsTooltip 	= "Si activé, l'aide au combat est afficher à l'écran pour vous prévenir des actions de votre ennemi."
L.TipsZoTips 	= "Masquer les icônes Zenimax"
L.TipsBloc 		= "Bloquez!"
L.TipsExploit 	= "Exploitez!"
L.TipsInterrupt = "Interrompez!"
L.TipsDodge 	= "Esquivez!"

----------------------------------
-- COMBAT STATE, COMPASS & RETICLE
----------------------------------
L.CompassSubMenu 		= "Boussole, réticule et alerte"
L.InfoTooltip			= "Rouge en combat, vert quand déguisé, orange quand danger, jaune quand détecter sans combat."

-- Combat state
L.CombatStateDiv 		= "Etat en combat et déguisé"
L.CombatCompass		 	= "Boussole : prend la couleur de l'état en cours"
L.CombatVisibility 		= "Haute visibilté de l'état \"en combat\""

-- Compass
L.CompassDiv 			= "Boussole"
L.CompassTexture 		= "Désactiver la texture"
L.CompassBoss 			= "Activer la barre de boss"

-- Reticle
L.ReticleDiv 			= "Réticule"
L.ReticleStealthText 	= "Masquer l'état Caché/Découvert"
L.ReticleTexture		= "Texture du réticule"
L.ReticleDefault		= "Par défaut"
L.ReticleCurvyHUD		= "CurvyHud"
L.ReticleColor			= "Couleur de réaction"
L.ReticleColorAlert		= "Réticule : prend la couleur de l'état en cours"
L.ReticleAlertColor		= "Etat du jour mis en couleur : rouge en combat, vert quand déguisé, jaune quand le couflage ne fonctionne plus, orange quand en danger de perdre le camouflage."

------
--CHAT
------
L.ChatSubMenu			= "INFOCHAT"
L.CombatChat 			= "Etat \"en combat\" dans le chat"
L.CovertChat			= "Changements d'état \"couvert\" dans le chat"
L.gMateArrival			= "Le joueur|cFF9500 "
L.gMateOnLine			= "|cFFFFFF est |c00FF00en ligne."
L.gMateOffLine			= "|cFFFFFF est |cFF0000hors ligne."
L.gMateNotDisturb		= "|cFFFFFF est en |cFF0000\"ne pas derranger\"."
L.gMateABS				= "|cFFFFFF est |cFFFF00absent."
L.ChatDiv				= "Status des membres de Guildes"
L.gOne					= "G1 : "
L.gTow					= "G2 : "
L.gThree				= "G3 : "
L.gFour					= "G4 : "
L.gFive					= "G5 : "
L.GuildWarning 			= "Si vous avez récement intégré ou quitté cette guilde, celà nécessitera un rechargement de CurvyHud (/reloadui)."

------------
-- CLEPSYDRE
------------
L.ClepsydreSubMenu		= "Horloge & Chronomètre"
L.ClepsydreShowTooltip	= "Afficher ou non l'Horloge"
L.ClepdyreOpacity		= "Opacité de l'Horloge"
L.ClepsydreColor		= "Couleur de la police de caractères"
L.ClepsydreChronoRAZ1	= "|cFF0000/!\\ |cFF9900Attendez que le logo du chrono devienne |cFFFF00jaune|cFF9900 pour le remettre à zéro |cFF0000/!\\"
L.ClepsydreChronoRAZ	= "Chrono à |cFF0000zéro|cFFFFFF"
L.ClepsydreChronoStart	= "Chrono |c00FF00lancé|cFFFFFF!"
L.ClepsydreChronoResult = " Durée du Chrono : |cFF9500"
L.clepsydreChronoAuto	= " - mode |cFF9500automatique|cFFFFFF."
L.clepsydreChronoMano	= " - mode |cFF9500manuel|cFFFFFF."
L.clepsydreChronoSP		= " - mode |cFF9500SpeedRun|cFFFFFF."

-----------------
-- ACKNOWLEDGMENT
-----------------
L.AcknowledgmentDiv 		= "Remerciements"
L.AcknowledgmentAuthor 		= "Merci à |cFF0000Niocwy |cFFFFFFpour avoir développé initialement |c7B18FFCurvyHud|cFFFFFF."
L.AcknowledgmentSubMenu 	= "Développeurs, testeurs et contributeurs"
L.AcknowledgmentThank		= "Merci à : "
L.AcknowledgmentText 		= "|c1CA8D6Seerah|cFFFFFF pour avoir créé et développé |cFFFF57\"LibAddonMenu 2.0\"|cFFFFFF. \n|c1CA8D6Phinix, Garkin, Kith, silentgecko|cFFFFFF pour avoir développé |cFFFF57Srendarr|cFFFFFF.\n|c1CA8D6Agade|cFFFFFF pour avoir créé et développé |cFFFF57\"GG Frames Fix\"|cFFFFFF.\n|c1CA8D6Harven|cFFFFFF pour avoir créé et développé |cFFFF57\"Harven's Bag Space\"|cFFFFFF. \n|c1CA8D6GetBackYouPansy|cFFFFFF pour avoir créé |cFFFF57\"PL Combat Indicator\"|cFFFFFF."
L.AcknowledgmentTextTwo		= "|c1CA8D6CaptainBlagbird|cFFFFFF pour m'avoir permis d'intégrer plusieurs de ses add-ons."
L.AcknowledgmentTextThree 	= "|c8bf4e8Cédric D. |cFFFFFFpour son aide sur les fichiers de textures."
L.AcknowledgmentTextFour 	= "|c1CA8D6Raghor |cFFFFFF&|c1CA8D6 Eldrikh|cFFFFFF pour la traduction allemande. \n|c8bf4e8BloodEagle |cFFFFFF, |c8bf4e8Aprilm |cFFFFFF, |c8bf4e8Caerdon |cFFFFFFet |c8bf4e8Xantaria |cFFFFFFpour leurs nombreux retours.\n\nRemerciements spéciaux à |c1CA8D6Eldrikh |cFFFFFF& |c1CA8D6Teboral|cFFFFFF." 

-----------------
-- SLASH COMMANDS
-----------------
L.CurvySlashCmd = "/curvyhud"
L.CurvySlash 	= "\n \/curvyhud |cFFFFFF: accéde au menu de |c922BFFCurvyHud. \n \/curvy_move on |cFFFFFF: active le déplacement des containers. \n \/curvy_move off |cFFFFFF: désactiver le déplacement des containers. \n \/curvy_raz |cFFFFFF: remet le compteur de mort à zéro."
L.CurvySlashTow	= "\n \/curvy_chrono mano|cFFFFFF: active le mode manuel du chrono. \n \/curvy_chrono auto |cFFFFFF: active le chrono quand vous entrez en combat contre un boss. \n \/curvy_chrono sp |cFFFFFF: active le chrono quand vous entrez dans un raid et/ou un donjon."
L.CurvyChat 	= "Pour visualiser les commandes, tapez |c00FF00\/curvy ?|cFFFFFF dans le chat."
L.CurvyCmdErr 	= "Cette commande est invalide!"
L.CurvyInf 		= " Ajoutez \"|cFF9500 on|cFFFFFF\" ou \"|cFF9500 off|cFFFFFF\" pour que la commande soit valide."
L.CurvyInfo 	= " Ajouter \"|cFF9500 ?|cFFFFFF\" pour que la commande soit valide."
L.CurvyInftwo	= " Ajouter \"|cFF9500 mano|cFFFFFF\" ou \"|cFF9500 auto|cFFFFFF\" ou \"|cFF9500?|cFFFFFF\" pour que la commande soit valide."
L.CurvyCombatOn = "Vous êtes|cFF0000 en Combat"
L.CurvyCombatOff= "Vous êtes |c00FF00sorti du Combat"
L.CurvyFrames 	= "|cFFFF00*** LISTE DES COMMANDES *** \n |cFFFFFF Vous pouvez assigner |cFF0000une touche de raccoucis clavier |cFFFFFF pour forcer le rafraichissement en cas de disparition soudaine d'une barre."

--------------------------------
-- STEALTHSTATE & DISGUISE STATE
--------------------------------
L.CurvyDisguiseOn 			= "Vous êtes |c00FF00couvert|cFFFFFF."
L.CurvyDisguiseDanger 		= "Vous êtes |cFF9500en danger|cFFFFFF de perdre votre couverture!"
L.CurvyDisguiseDangerOff	= "Si vous êtes |cD25032frappé|cFFFFFF vous perdrez votre couverture."
L.CurvyDisguiseOff 			= "Vous n'êtes |cFFFF00pas|cFFFFFF couvert."
L.CurvyDiscovered 			= "Vous n'êtes |cFFFF00plus|cFFFFFF couvert."
L.CurvyDisguiseImpossible 	= "Il vous est |cFF0000impossible|cFFFFFF de vous couvrir."

-----------------------
-- WELCOME INFORMATIONS
-----------------------
L.CurvyWelcome 			= "|cFFFFFF Bienvenue|cFF9500 " 
L.CurvyWelcomeEnd 		= "|cFFFFFF, bonne session de jeu."
L.WelcomeBegin			= "|cFFFFFF Vous jouez avec |cFF9500"
L.WelcomeTimeWithAvatar	= " |cFFFFFFdepuis|cFF9500 "
L.WelcomeDays			= "|cFFFFFF jours,|cFF9500 "
L.WelcomeHours			= "|cFFFFFF heures, et|cFF9500 "
L.WelcomeMinutes		= "|cFFFFFF minutes."

-----------------------------------------
-- DEATH INFORMATION & DUNGEON DIFFICULTY
-----------------------------------------
L.TrollEnable	= "Activer le trollage dans le chat."

L.DeadCountRAZ 	= "|cFFFFFFCompteur de mort mis à |c00FF00zéro|cFFFFFF."
L.Deathbegin	= "|cFFFFFF Vous êtes |cFF0000mort|cFFFFFF déjà|cffff00 "
-- in dungeon
L.DeadDungeonA	= "|cFFFFFF fois, et tout ça devant tout le |cFF9500groupe|cFFFFFF. Reprenez-vous!"
L.DeadDungeonB	= "|cFFFFFF fois, c'est |cFF9500inquiétant|cFFFFFF d'être aussi |cFF9500mauvais|cFFFFFF."
L.DeadDungeonC	= "|cFFFFFF fois, coup dur pour |cFF9500"..CurvyHud.avatarName.."|cFFFFFF."
L.DeadDungeonD	= "|cFFFFFF fois, ici ce n'est pas la |cFF9500champi "..CurvyHud.avatarName.."|cFFFFFF."
L.DeadDungeonE	= "|cFFFFFF fois, la prochaine fois, ramène |cFF9500plus|cFFFFFF d'amis!."
L.DeadDungeonF	= "|cFFFFFF fois, visiblement vous |cFF9500faiblissez|cFFFFFF."
L.DeadDungeonG	= "|cFFFFFF fois, c'est la |cFF9500haine|cFFFFFF qui vous aveugle."
L.DeadDungeonH	= "|cFFFFFF fois, |cFF9500"..CurvyHud.avatarName.."|cFFFFFF enlevez les |cFF9500moufles|cFFFFFF!"
L.DeadDungeonI	= "|cFFFFFF fois, les zones |cFF9500rouges|cFFFFFF au sol ne sont pas des |cFF9500buffs|cFFFFFF!"
L.DeadDungeonJ	= "|cFFFFFF fois, c'est |cFF9500lamentable|cFFFFFF, votre groupe sent le |cFF9500sapin|cFFFFFF."
L.DeadDungeonK	= "|cFFFFFF fois, vous devriez peut-être |cFF9500manger un bout|cFFFFFF avant de recommencer ?"
-- in world
L.DeadInWorldA	= "|cFFFFFF fois, quelle |cFF9500incroyable|cFFFFFF performance!"
L.DeadInWorldB	= "|cFFFFFF fois, c'est |cFF9500frustrant|cFFFFFF."
L.DeadInWorldC	= "|cFFFFFF fois, |cFF9500pitoyable "..CurvyHud.avatarName.."|cFFFFFF ..."
L.DeadInWorldD	= "|cFFFFFF fois, encore une mort |cFF9500ridicule|cFFFFFF de plus à votre compteur!"
L.DeadInWorldE	= "|cFFFFFF fois, |cFF9500"..CurvyHud.avatarName.."|cFFFFFF, quelle |cFF9500raclée|cFFFFFF!"
L.DeadInWorldF	= "|cFFFFFF fois, quel |cFF9500dommage|cFFFFFF..."
L.DeadInWorldG	= "|cFFFFFF fois, une de |cFF9500plus|cFFFFFF..."
L.DeadInWorldH	= "|cFFFFFF fois, bravo |cFF9500"..CurvyHud.avatarName.."|cFFFFFF!"
L.DeadInWorldI	= "|cFFFFFF fois, vraiment votre skill |cFF9500suxx|cFFFFFF!"
L.DeadInWorldJ	= "|cFFFFFF fois, ce n'est |cFF9500certainement|cFFFFFF pas de votre faute..."
L.DeadInWorldK 	= "|cFFFFFF fois, sans commentaire..."
-- dungeaon diff
L.Dungeonbegin 		= "|cFFFFFF Le donjon est en mode : " 
L.DungeonNormalDiff = "|cFF9500Normal|cFFFFFF."
L.DungeonVetDiff	= "|cFF9500Vétéran|cFFFFFF."
-- stuff
L.Repair		= "|cFFFFFF fois, |cFF9500"..CurvyHud.avatarName.."|cFFFFFF il va falloir penser à |cFF9500réparer|cFFFFFF votre équipement..."