--[[----------------------------------------------------------
    CurvyHud
    ----------------------------------------------------------
	Localization 	: 	/Loc/EN.lua 
    Original Author	:	Niocwy
	Update Author 	:	Vvarderen
	Translator		:	Vvarderen
    Version			: 	6.12
    Updated			:  	2020-06-20 (YYYY-MM-DD)
----------------------------------------------------------]]--

CurvyHud.EN = {}

local L = CurvyHud.EN
CurvyHud.avatarName	= GetUnitName("player")
-------------
-- ADDON INFO
-------------
L.CurvyHud 		= "CurvyHud"
L.CurvyHudinfo 	= "|c922BFFCurvyHud|cFFFFFF : "
L.authors 		= "|cFF0000Niocwy |cFFFFFF(original author) & |c7B18FFVvarderen |cFFFFFF(update author)"

-----------------------
-- MENU SHARED ELEMENTS
-----------------------
L.MenuEnable	= "Enable"
L.MenuDisable 	= "Disable"

L.Major 	= "Major"
L.Minor		= "Minor"

L.ChoiceUnit = "Choice of unit"
L.PlayerUnit = "Player"
L.TargetUnit = "Target"

L.Font 		= "Font"
L.FontSize 	= "Font size"

L.Reload	= "Reload "
L.Chrono	= "Start\\pause\\stop Stopwatch"

---------------------
-- PROFILS MANAGEMENT
---------------------
L.ProfilsMgtHeader 			=  "Profile Manager"
L.ProfilsMgtHeaderdesc 		= "Where the default profiles are preceded by * and can not be replaced. "
L.ProfilsMgtEndHeaderdesc 	= "Click \"|c1CA8D6Load|cFFFFFF\" to reload the interface with the parameters related to the selected profile.\n\"|c1CA8D6Save|cFFFFFF\" will replace the selected profile with the current configuration."
L.ProfilsMgtdefaultProfil 	= "* Default settings "
L.ProfilsMgtBtnLoad 		= "Load"
L.ProfilsMgtBtnLoadWarning 	= "This will require a reload of CurvyHud ( /reloadui in chat)."
L.ProfilsMgtBtnSave 		= "Save"
L.ProfilsMgtBtnSaveWarning 	= "The backup will overwrite the selected profile!"

-- New Profil
L.ProfilsMgtCreatNewProfilSubMenu = "Create a new profile"
L.Profils 				= "The profile|cFF9500 "
L.ProfilsCreat 			= "|cFFFFFF has been created."
L.ProfilsSaved 			= "|cFFFFFF has been saved."
L.ProfilsLoaded 		= "|cFFFFFF has been loaded."
L.ProfilsSelected 		= "|cFFFFFF has been selected."
L.ProfilsMgtNewdesc 	= "To create a new profile based on the current configuration, enter a name in the field provided and click on \"|c1CA8D6Create|cFFFFFF\". Authorized characters: |c1CA8D6letters |cFFFFFF(min/maj)|c1CA8D6, numbers, _ |cFFFFFFand |c1CA8D6- |cFFFFFF \n \n |cff9544In case of non respect of the rules of formatting previously given, the button \"Create\" will not be available.|cFFFFFF \n"
L.ProfilsMgtBtnNew 		= "Create"
L.ProfilsMgtBtnNewTooltip 	= "Create a new profile with the name entered"
L.ProfilsMgtBtnNewWarning 	= "This will require a \"Reloadui\", a reload of CurvyHud."
L.ProfilsMgtTextNewdesc 	= "To update the status of the \"|c1CA8D6Create|cFFFFFF\" button, click the button itself or outside the field provided to receive your profile name. |cFF0000WARNING |cFFFFFFIt will not be possible to create a profile |cFF0000With a name that already exists or does not respect the naming rule|cFFFFFF!!"

-- Move Mode
L.Move_ModeDiv			= "Move Mode"
L.Move_ModeDesc 		= "|c1CA8D6Activate|cFFFFFF or |c1CA8D6deactivate|cFFFFFF the displacement mode in order to position the containers as you wish."
L.Move_ModeLockValues 	= "Anchor values ​​to bars"
L.Move_ModeLockValuesTooltip = "Moving the bars will also move the values. However, you can continue to move values ​​independently of bars."
L.Move_ModeShowAllDesc	= "|cFF0000Only works when Move Mode is activated \n|c1CA8D6Activate|cFFFFFF or |c1CA8D6deactivate|cFFFFFF the display of all effects with the associated configurations. For demonstration, |c00FF00your life is reduced by one tier|cFFFFFF and you have a |c00FF00virtual shield of +4560 points."
L.Move_ModeDescWarning	= "|cFF0000Only works when Move Mode is activated"
L.Move_ModeShowDesc		= "Go to the |c1CA8D6Active Effects|cFFFFFF submenu and then |c1CA8D6Demonstrate Effects|cFFFFFF or |c1CA8D6Demonstration of Shields|cFFFFFF to filter the informations you want."

L.Move_targetNameplate 	= "Nampeplate the target"
L.Move_taunt			= "Taunt"
L.Move_barContainerLeft = "The bars on the left"
L.Move_barContainerRight= "The bars on the right"
L.Move_interactionPrompt= "Interaction with objects"
L.Move_PlayerinteractionPrompt = "Interaction with players"
L.Move_healthBarText 	= "Health"
L.Move_magickaBarText 	= "Magicka"
L.Move_staminaBarText 	= "Stamina"
L.Move_targetBarText 	= "Target Health"
L.Move_mountBarText 	= "Stamina of mount"
L.Move_werewolfBarText 	= "Werewolf Chrono"
L.Move_siegeBarText 	= "Siege Health"
L.Move_shieldText 		= "Shield"
L.Move_targetShieldText = "Shield of the target"
L.Move_combatTips 		= "Fighting aid"
L.Move_LowAttributesAlert = "Low attributs"	
L.Move_CoordsHeader 	= "Coordinates of Containers and bars"
L.Move_clepsydre		= "Clock & chrono"

L.Move_Enable 			= "Moving containers |c00FF00activated"
L.Move_Disable 			= "Moving containers |cFF0000disabled"

-------
-- Demo
-------
L.Demobars				= "Show a shield and mid-life"

------------------------
-- VISLUATION OF EFFECTS
------------------------
L.ShowEffectsSubMenu 	= "Visualization of the effects"
L.ShowMoveModeDesc		= "You must have activated the Move Mode to see the result"

-- Name of types
L.PhysicalInc			= "Increased Physical Resistances"
L.SpellInc				= "Increased Magic Resistances"
L.PhysicalDec			= "Reduced physical Resistances"
L.SpellDec				= "Reduced Magic Resistances"
L.PhysicalDual			= "Antinomic Physical Resistances"
L.SpellDual				= "Antinomic Magic Resistances"

-- Color effect
L.PhysResistIncColor	= "Augmented physical"
L.PhysResistDecColor	= "Reduced physical"
L.SpellResistIncColor	= "Augmented magic"
L.SpellResistDecColor	= "Reduced magic"
L.PhysResistDualColor	= "Antinomic physical"
L.SpellResistDualColor	= "Antinomic magical"

--------------------------------------
-- CONTAINER AND BARS GLOBAL SETTINGS
--------------------------------------
L.GlobalSettingsSubMenu = "General Settings"

-- Containers settings
L.BarStyle 				= "Style"
L.BarStyleTooltip 		= "Configures the style applied to the player and target attribute bars." 
L.Default_bar 			= "Default"
L.Flat_bar				= "Flat"
L.Oblivion_bar 			= "Oblivion"
L.Ghost_bar 			= "Ghostly"

-- Bars stairway
L.ContainerDiv 			= "Stairway mode"
L.ContainerLeftForm 	= "Left Container"
L.ContainerRightForm 	= "Right Container"
L.ContainerStyleNormal 	= "Normal"
L.ContainerStyleStairway= "Stairway"

-- Global settings of bars
L.BarDiv 				= "Bar configuration"
L.BarSpacing 			= "Spacing"
L.BarWidth 				= "Width"
L.BarHeight 			= "Height"

-- Opacity settings
L.OpacityDiv 			= "Opacity"
L.OpacityOoc 			= "Out of combat (you)"
L.OpacityAttributeUsed 	= "Attributes in use (you)"
L.OpacityCombat 		= "In combat (all bars)"
L.OpacityTargetOoc 		= "Target out of combat"
L.OpacityTargetinCombat = "Target in combat"

----------------------
-- GENERAL TEXT FORMAT
----------------------
L.FormatDiv				= "Paramètres des valeurs des barres"
L.FormatDecSep			= "Afficher le séparateur décimal"
L.FormatDecPer			= "Afficher un chiffre après la virgule"

---------------------
-- NAMEPLATE SETTINGS
---------------------
L.NameplateSubMenu 		= "Target nameplate"

-- General settings
L.NamePlateDiv 				= "Basic parameters"
L.NamePlateFontSizeTooltip 	= "Changes the size of all elements contained in the target information"

L.NampletePlayer 		= "Display the name of the"
L.NameplateAvatar 		= "Character"
L.NameplateAccount 		= "Account"
L.NameplateAllone 		= "Character and account"
L.NameplateAlltow 		= "Account and character"

-- Icons on nameplate and colors
L.NamePlateIconDiv 		= "Icons settings"
L.NamePlateClass 		= "Show class"
L.NamePlateRace 		= "Show race"
L.NamePlateLevel		= "Show players levels"
L.NamePlateRank 		= "Show PvP grade"
L.NamePlateAlliance 	= "Show Alliance"
L.NamePlateCaption		= "Show players titles"

L.NamePlateIconColor 	= "Color of icons"
L.Julianos 				= "White"
L.Gold 					= "Gold"
L.Silver 				= "Silver"
L.Alliance 				= "Alliance"

-- Boss and guards on nameplate
L.BossStyle = "Boss icon style"

L.Default_boss 			= "By default"
L.Star_boss 			= "Star"
L.Dsword_boss 			= "Crossed Swords"
L.Obli_boss 			= "Oblivion"
L.Skull_boss 			= "Skull"
L.NoneIcon_boss 		= "No icon"

L.GuardColor 			= "Color of icons of difficulty of NPCs \"Guards\""

-- Critters & deads
L.NamePlateCrittersDiv 	= "Show the critters & deads" 
L.ShowCrittersTooltip	= "Show the critters"
L.ShowDeadsTooltip		= "Show the deads"

-----------------------------------
-- DIFERENTIATION OF THE TARGET BAR
-----------------------------------
L.diffOfTargetsSubMenu = "Differentiation of the target bar"

-- friendly health bar
L.AllyColorBarDiv 	= "Allied player health bar"
L.AllyColorBarDesc 	= "Automatically color the target bar in blue (default) if the target is a player or yellow (against red by default) if Target is a neutral NPC." 

-- Neutral NPC
L.NeutralTragetDiv 		= "NPC neutral"
L.NeutralTragetTooltip 	= "If activated, the neutral NPC life bar will be the color of their reaction (yellow). In return, the guards and other elite monsters will have a red life bar even if they are neutral."

-------
-- BARS
-------
L.BarsSubMenu = "Parameters of bars"

-- Choice of bar
L.SelectedBarDiv 			= "Configuration"
L.SelectedBar 				= "Selection of the bar"
L.SelectedBarShowTooltip 	= "Disabling the selected CurvyHud bar will display the corresponding default Zenimax bar instead."

L.Health 	= "Health Bar"
L.Stamina 	= "Stamina Bar"
L.Magicka 	= "Magicka Bar"
L.Target 	= "Target's Health Bar"
L.Mount 	= "Mount Stamina bar"
L.Siege 	= "Siege Health Bar"
L.Werewolf 	= "Werewolf chrono Bar"

-- bars and containers
L.BarPosition 	= "Container"
L.Left 			= "Left"
L.Right 		= "Right"
L.Index 		= "Index"
L.IndexTooltip 	= "Index in the container. 1 is closest to the center of the screen"
L.BarColorMax 	= "Maximum bar color"
L.BarColorLow 	= "Minimum bar color"
L.Border	 	= " the borders of the bar"
L.BarBkgrdColor = "Color of Background"

-- Color of attributes
L.TextBar 			= " the text of the selected bar"
L.TextFormat 		= "Format of text values of "
L.TextFormatTooltip = "{val} / {max} - {per}% will display all values. \n {val} / {max} will show everything except the percentage. \n {per}% will only show the percentage."

-- Color text of the attribute
L.TextColor 	= "Color of text value"
L.DefaultColor 	= "Default color"
L.AttibuteColor = "Attribute color"

----------------------------------------------------	
-- INCREASE / DECREASE RESISTANCES and TAUNT EFFECTS
----------------------------------------------------
L.EffectsSettingsSubMenu = "Resistance Effects and taunting"

-- Effect
L.MajorIncEffect 	= " the major positive effects"
L.MajorDecEffect 	= " the major negative effects"
L.MinorIncEffect 	= " the minor positive effects"
L.MinorDecEffect 	= " the minor negative effects"
L.DualEffect		= " the antinomic effects"
L.DualEffectTooltip	= "Replaces the reduction and augmentation effects of the same type with another effect for clarity. Example: if you are under \"major resolution\" and you suffer \"major fracture\", the two bars will be replaced by the physical antinomic bar."

-- Taunt effect
L.TauntEffectDiv 	= "Taunting"

-----------------------------------	
-- REGEN / DEGEN and SHIELD EFFECTS
-----------------------------------
L.VisualsSettingsSubMenu = "Regen/Degen and Shield"

-- Regen/Degen
L.RegenDiv 			= "Regen and degen"

-- Shield
L.ShieldDiv 		= "Shield"
L.ShieldColor 		= "Color of the shield"
L.ShieldTextShow 	= "View Shield Values"
L.ShieldTextColor 	= "Color of shield values"

----------------
-- COMBAT HELPER
----------------
L.CombatHelperSubMenu = "Combat Support & Combat Assistance"

-- Low attributes
L.LowAttribDiv 		= "Low attributes"
L.LowAttribHealth 	= "Low Health!"
L.LowAttribStamina 	= "Low Endurance!"
L.LowAttribMagicka 	= "Low magicka!"
L.LowAttribTrigger 	= "Alert threshold"

-- Combat tips
L.TipsDiv 			= "Combat Support"
L.TipsTooltip 		= "If activated, the combat aid is displayed on the screen to warn you of the actions of your enemy."
L.TipsZoTips 		= "Hide icons Zenimax"
L.TipsBloc 			= "Block!"
L.TipsExploit 		= "Exploit!"
L.TipsInterrupt 	= "Interrupt!"
L.TipsDodge 		= "Dodge!"

----------------------------------
-- COMBAT STATE, COMPASS & RETICLE
----------------------------------
L.CompassSubMenu 		= "Compass, reticle and alert"
L.InfoTooltip			= "Red in combat, green when disguised, orange when danger, yellow when to detect without combat."

-- Combat state
L.CombatStateDiv 		= "Combat and disguise mode"
L.CombatCompass		 	= "Compass : takes the color of the current state"
L.CombatVisibility 		= "Hight visibility of color \"in combat state\""

-- Compass
L.CompassDiv 			= "Compass"
L.CompassTexture		= "Disables the texture"
L.CompassBoss 			= "Enable Boss bar"

-- Reticle
L.ReticleDiv 			= "Reticle"
L.ReticleStealthText	= "Hide Hidden/Discovered state"
L.ReticleTexture		= "Reticle's texture"
L.ReticleDefault		= "Default"
L.ReticleCurvyHUD		= "CurvyHud"
L.ReticleColor			= "Reaction color"
L.ReticleColorAlert		= "Reticle : takes the color of the current state"
L.ReticleAlertColorTooltip	= "State of the day put in color : red in combat, green when disguised, yellow when the billing no longer works, orange when in danger of losing the camouflage."

------
--CHAT
------
L.ChatSubMenu			= "INFOCHAT"
L.CombatChat 			= "Enables the \"in combat state\" in chat"
L.CovertChat			= "State change \"covered \"in chat"
L.gMateArrival			= "The player|cFF9500 "
L.gMateOnLine			= "|cFFFFFF is |c00FF00online."
L.gMateOffLine			= "|cFFFFFF is |cFF0000offline."
L.gMateNotDisturb		= "|cFFFFFF is in |cFF0000\"not distrub\"."
L.gMateABS				= "|cFFFFFF is |cFFFF00absent."
L.ChatDiv				= "Guilds"
L.gOne					= "G1 : "
L.gTow					= "G2 : "
L.gThree				= "G3 : "
L.gFour					= "G4 : "
L.gFive					= "G5 : "
L.GuildWarning 			= "if you have recently joined or left this guild, this will require a reload of CurvyHud (/ reloadui)."

------------
-- CLEPSYDRE
------------
L.ClepsydreSubMenu		= "Clock & Stopwatch"
L.ClepsydreShowTooltip	= "Show or not the Clock"
L.ClepdyreOpacity		= "Opacity of the Clock"
L.ClepsydreColor		= "Color of the font"
L.ClepsydreChronoRAZ1	= "|cFF0000/!\\ |cFF9900Wait for the Stopwatch logo to turn |cFFFF00yellow|cFF9900 to reset it |cFF0000/!\\"
L.ClepsydreChronoRAZ	= "Stopwatch set to |cFF0000zero|cFFFFFF"
L.ClepsydreChronoStart	= "Stopwatch |c00FF00launched|cFFFFFF!"
L.ClepsydreChronoResult = " Duration of the Stopwatch : |cFF9500"
L.clepsydreChronoAuto	= " - in |cFF9500auto mode|cFFFFFF."
L.clepsydreChronoMano	= " - in |cFF9500manual mode|cFFFFFF."
L.clepsydreChronoSP		= " - in |cFF9500SpeedRun mode|cFFFFFF."

-----------------
-- ACKNOWLEDGMENT
-----------------
L.AcknowledgmentDiv 		= "thanks"
L.AcknowledgmentAuthor 		= "Thank |cFF0000Niocwy |cFFFFFFfor initially developing of |c7B18FFCurvyHud|cFFFFFF."
L.AcknowledgmentSubMenu 	= "Developers, testers and contributors"
L.AcknowledgmentThank		= "Thanks to : "
L.AcknowledgmentText 		= "|c1CA8D6Seerah|cFFFFFF for creating and developing|cFFFF57 \"LibAddonMenu 2.0\" |cFFFFFF. \n|c1CA8D6Phinix, Garkin, Kith, silentgecko|cFFFFFF for creating and develmopping |cFFFF57Srendarr|cFFFFFF.\n|c1CA8D6Agade|cFFFFFF for creating |cFFFF57\"GG Frames Fix\"|cFFFFFF.\n|c1CA8D6Harven|cFFFFFF for creating |cFFFF57\"Harven's Bag Space\"|cFFFFFF.\n|c1CA8D6GetBackYouPansy |cFFFFFF for creating|cFFFF57 \"PL Combat Indicator\"|cFFFFFF."
L.AcknowledgmentTextTwo		= "|c1CA8D6CaptainBlagbird |cFFFFFFfor allowing me to integrate several of his add-ons."
L.AcknowledgmentTextThree	= "|c8bf4e8Cedric D. |cFFFFFF for help with texture files."
L.AcknowledgmentTextFour	= "|c1CA8D6Raghor |cFFFFFF& |c1CA8D6Eldrikh|cFFFFFF for german translation. \n|c8bf4e8BloodEagle |cFFFFFF, |c8bf4e8Aprilm |cFFFFFF, |c8bf4e8Caerdon |cFFFFFFand  |c8bf4e8Xantaria |cFFFFFF for thier many returns.\n\nSpecial Thanks to |c1CA8D6Eldrikh |cFFFFFF& |c1CA8D6Teboral|cFFFFFF."
-----------------
-- SLASH COMMANDS
-----------------
L.CurvySlashCmd = "/curvyhud"
L.CurvySlash 	= "\n \/ curvyhud|cFFFFFF: access the |c922BFFCurvyHud menu. \n \/curvy_move on |cFFFFFF: Enables the movement of containers. \n \/curvy_move off|cFFFFFF: disable the movement of containers.  \n \/curvy_raz |cFFFFFF: Puts the deathmeter back to zero."
L.CurvySlashTow	= "\/curvy_chrono mano|cFFFFFF: activate the chrono manual mode. \n \/curvy_chrono auto |cFFFFFF: activate the timer when you enter a boss fight. \n \/curvy_chrono sp |cFFFFFF: activate the timer when you enter a raid and/or a dungeon."
L.CurvyChat 	= "To view the commands, type |c00FF00 \/curvy ?|cFFFFFF in chat."
L.CurvyCmdErr 	= "This is invalid command!"
L.CurvyInf 		= " Add \"|cFF9500 on|cFFFFFF\" or \"|cFF9500 off|cFFFFFF\" for the command to be valid."
L.CurvyInfo 	= " Add \"|cFF9500 ?|cFFFFFF\" for the command to be valid."
L.CurvyInftwo	= " Ajouter \"|cFF9500 mano|cFFFFFF\" ou \"|cFF9500 auto|cFFFFFF\" pour que la commande soit valide."
L.CurvyCombatOn = "You are|cFF0000 in Combat"
L.CurvyCombatOff= "You are|c00FF00 out of the Combat"
L.CurvyFrames 	= "|cFFFF00*** COMMANDS LIST *** \n |cFFFFFF You can assign |cFF0000a keyboard shortcut key |cFFFFFF to force the refresh in case of sudden disappearance of a bar."

--------------------------------
-- STEALTHSTATE & DISGUISE STATE
--------------------------------
L.CurvyDisguiseOn 			= "You are |c00FF00disguised|cFFFFFF."
L.CurvyDisguiseDanger		= "You are |cFF9500in danger|cFFFFFF of being discovered and losing your disguise!"
L.CurvyDisguiseDangerOff	= "If you are |cD25032hit|cFFFFFF you will lose your coverage."
L.CurvyDisguiseOff 			= "You are |cFFFF00not|cFFFFFF covered."
L.CurvyDiscovered 			= "You are |cFFFF00no longer|cFFFFFF covered."
L.CurvyDisguiseImpossible 	= "You |cFF0000can't|cFFFFFF cover yourself."

-----------------------
-- WELCOME INFORMATIONS
-----------------------
L.CurvyWelcome 			= "Welcome|cFF9500 " 
L.CurvyWelcomeEnd 		= "|cFFFFFF, good game session."
L.WelcomeBegin			= "|cFFFFFF You play with |cFF9500"
L.WelcomeTimeWithAvatar	= " |cFFFFFFsince|cFF9500 "
L.WelcomeDays			= "|cFFFFFF days,|cFF9500 "
L.WelcomeHours			= "|cFFFFFF hours, and|cFF9500 "
L.WelcomeMinutes		= "|cFFFFFF minutes."

-----------------------------------------
-- DEATH INFORMATION & DUNGEON DIFFICULTY
-----------------------------------------
L.TrollEnable	= "Activate trollage in chat."

L.DeadCountRAZ 	= "|cFFFFFFYour deadometer has been |c00FF00reset|cFFFFFF."
L.Deathbegin	= "|cFFFFFF Number of times you |cFF0000died|cFFFFFF : |cffff00 "
-- in dungeon
L.DeadDungeonA	= "|cFFFFFF in front of the |cFF9500whole party|cFFFFFF... Pull yourself together ! "
L.DeadDungeonB	= "|cFFFFFF you're disturbingly |cFF9500lousy|cFFFFFF, you know..."
L.DeadDungeonC	= "|cFFFFFF having a |cFF9500hard time|cFFFFFF,"..CurvyHud.avatarName.."?"
L.DeadDungeonD	= "|cFFFFFF dude, it ain't no |cFF9500fungal grotto|cFFFFFF here |cFF9500"..CurvyHud.avatarName.."|cFFFFFF!"
L.DeadDungeonE	= "|cFFFFFF next time, bring back |cFF9500some more friends|cFFFFFF."
L.DeadDungeonF	= "|cFFFFFF it seems you're |cFF9500weakening|cFFFFFF..."
L.DeadDungeonG	= "|cFFFFFF Is it |cFF9500hatred|cFFFFFF in your eyes?"
L.DeadDungeonH	= "|cFF9500"..CurvyHud.avatarName.."|cFFFFFF, you should probably pull your |cFF9500mittens|cFFFFFF off, don't you think?"
L.DeadDungeonI	= "|cFFFFFF you know |cFF9500Red zones|cFFFFFF on the floor |cFF9500aren't buffs|cFFFFFF, right !?"
L.DeadDungeonJ	= "|cFFFFFF Looks like the |cFF9500end of the road|cFFFFFF for your party... what a pity!"
L.DeadDungeonK	= "|cFFFFFF Maybe you should have a |cFF9500little snack |cFFFFFFbefore you get killed again."
-- in world
L.DeadInWorldA	= "|cFFFFFF hat was an |cFF9500incredibly|cFFFFFF high performance!"
L.DeadInWorldB	= "|cFFFFFF can you feel the |cFF9500frustration|cFFFFFF ?"
L.DeadInWorldC	= "|cFFFFFF |cFF9500pathetic "..CurvyHud.avatarName.."|cFFFFFF..."
L.DeadInWorldD	= "|cFFFFFF one more |cFF9500ridicule death|cFFFFFF to your deadometer!"
L.DeadInWorldE	= "|cFF9500"..CurvyHud.avatarName.."|cFFFFFF you really did take a proper |cFF9500beating|cFFFFFF!"
L.DeadInWorldF	= "|cFFFFFF That's |cFF9500too bad|cFFFFFF!"
L.DeadInWorldG	= "|cFFFFFF that's |cFF9500one more time|cFFFFFF, right? "
L.DeadInWorldH	= "|cFFFFFF  well done |cFF9500"..CurvyHud.avatarName.."|cFFFFFF!"
L.DeadInWorldI	= "|cFFFFFF your skill really |cFF9500sucks|cFFFFFF!"
L.DeadInWorldJ	= "|cFFFFFF and you're certainly not |cFF9500to blame|cFFFFFF..."
-- dungeaon diff
L.Dungeonbegin 		= "|cFFFFFF This dungeon has been set to : " 
L.DungeonNormalDiff = "|cFF9500normal mode|cFFFFFF."
L.DungeonVetDiff	= "|cFF9500veteran mode|cFFFFFF."
-- stuff
L.Repair		= "|cFFFFFF you should think about |cFF9500repairing|cFFFFFF your gear"