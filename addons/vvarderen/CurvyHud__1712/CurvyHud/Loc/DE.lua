--[[----------------------------------------------------------
    CurvyHud
    ----------------------------------------------------------
	Localization : /Loc/DE.lua 
	Original Author	:	Vvarderen
	Update Author 	:	Vvarderen
	Translator		:	Raghor & Eldrikh
    Version			: 	6.12
    Updated			:  	2020-06-20 (YYYY-MM-DD)
----------------------------------------------------------]]--

CurvyHud.DE = {}

local L = CurvyHud.DE
CurvyHud.avatarName	= GetUnitName("player")
-------------
-- ADDON INFO
-------------
L.CurvyHud 		= "CurvyHud"
L.CurvyHudinfo 	= "|c922BFFCurvyHud|cFFFFFF : "
L.authors 		= "|cFF0000Niocwy |cFFFFFF(Ursprünglicher Autor) & |c7B18FFVvarderen |cFFFFFF(Update Autor)"

-----------------------
-- MENU SHARED ELEMENTS
-----------------------
L.MenuEnable 	= "Aktivieren"
L.MenuDisable 	= "Deaktivieren"

L.Major 	= "Großer"
L.Minor		= "Geringer"

L.ChoiceUnit = "Wahl der Einheit"
L.PlayerUnit = "Speiler"
L.TargetUnit = "Ziel"

L.Font 		= "Schriftart"
L.FontSize 	= "Schriftgröße"

L.Reload	= "Aufladen "
L.Chrono	= "Starten Sie\\pause\\stop Stoppuhr"

---------------------
-- PROFILS MANAGEMENT
---------------------
L.ProfilsMgtHeader			=  "Profilmanager"
L.ProfilsMgtHeaderdesc 		= "Standardeinstellungen sind mit einem * markiert und können nicht überschrieben werden."
L.ProfilsMgtEndHeaderdesc 	= "Klicken Sie auf \"|c1CA8D6Laden|cFFFFFF\", um das ausgewählte Profil (neu) zu laden.\n\"|c1CA8D6Speichern|cFFFFFF\" überschreibt das ausgewählte Profil mit den aktuellen Einstellungen."
L.ProfilsMgtdefaultProfil 	= "* Standardeinstellungen"
L.ProfilsMgtBtnLoad 		= "Laden"
L.ProfilsMgtBtnLoadWarning 	= "Dies erfordert ein erneutes Laden von CurvyHud (/ reloadui im ​​Chat)!"
L.ProfilsMgtBtnSave 		= "Speichern"
L.ProfilsMgtBtnSaveWarning 	= "Die Sicherung überschreibt das ausgewählte Profil mit den aktuellen Einstellungen!"

-- New Profil
L.ProfilsMgtCreatNewProfilSubMenu = "Erstellen Sie ein neues Profil"
L.Profils 					= "Das Profil|cFF9500 "
L.ProfilsCreat 				= "|cFFFFFF wurde erstellt."
L.ProfilsSaved 				= "|cFFFFFF wurde gespeichert."
L.ProfilsLoaded 			= "|cFFFFFF wurde geladen."
L.ProfilsSelected 			= "|cFFFFFF wurde ausgewählt."
L.ProfilsMgtNewdesc 		= "Um ein neues Profil basierend auf der aktuellen Konfiguration zu erstellen, geben Sie einen Namen in das Feld ein und klicken Sie auf \"|c1CA8D6Erstellen|cFFFFFF\". Berechtigte Zeichen: |c1CA8D6briefe |cFFFFFF (min / maj)|c1CA8D6, Zahlen, _ |cFFFFFFand |c1CA8D6- |cFFFFFF \n \n |cff9544In der Nichtbeachtung der zuvor angegebenen Formierungsregeln, die Schaltfläche \"Erstellen\" Wird nicht verfügbar sein.|cFFFFFF \n"
L.ProfilsMgtBtnNew 			= "Erstellen"
L.ProfilsMgtBtnNewTooltip 	= "Erstellen Sie ein neues Profil mit dem eingegebenen Namen"
L.ProfilsMgtBtnNewWarning 	= "Dies bewirkt ein \"ReloadUI\"."
L.ProfilsMgtTextNewdesc 	= "Um den Status der Schaltfläche \"|c1CA8D6Erstellen|cFFFFFF\" zu aktualisieren, klicken Sie auf die Schaltfläche selbst oder außerhalb des Feldes, um Ihren Profilnamen zu erhalten. |cFF0000Achtung! Es ist nicht möglich, ein Profil mit einem Namen zu erstellen, der bereits existiert oder nicht die Regeln zur Namensgebung einhält!"

-- Move Mode
L.Move_ModeDiv					= "Move modus"
L.Move_ModeDesc 				= "|c1CA8D6Aktivieren|cFFFFFF oder |c1CA8D6deaktivieren|cFFFFFF Sie den Verschiebungsmodus, um die Container nach Belieben zu positionieren."
L.Move_ModeLockValues 			= "Text/Zahlen-Werte an Leisten verankern"
L.Move_ModeLockValuesTooltip 	= "Das Bewegen der Leisten wird auch die Werte verschieben. Sie können jedoch weiterhin Werte unabhängig von den Leisten verschieben."
L.Move_ModeShowAllDesc			= "|cFF0000Funktioniert nur, wenn der Fahrmodus aktiviert ist \n|c1CA8D6Aktivieren|cFFFFFF oder |c1CA8D6deaktivieren|cFFFFFF die Anzeige aller Effekte mit den zugehörigen Konfigurationen. Zur Demonstration |c00FF00wird dein Leben um eine Stufe reduziert|cFFFFFF und du hast einen |c00FF00virtuellen schilde von +4560 Punkten."
L.Move_ModeDescWarning 			= "|cFF0000Funktioniert nur, wenn der Fahrmodus aktiviert ist"
L.Move_ModeShowDesc				= "Gehen Sie zum |c1CA8D6Active Effects|cFFFFFF Untermenü und dann Demonstrate Effects|cFFFFFF oder |c1CA8D6Demonstration der Schilde|cFFFFFF, um die gewünschten Informationen zu filtern"

L.Move_targetNameplate 			= "Informationen über das Ziel"
L.Move_taunt					= "taunt"
L.Move_barContainerLeft 		= "Leisten auf der linken Seite"
L.Move_barContainerRight		= "Leisten auf der rechten Seite"
L.Move_interactionPrompt		= "Interagieren mit Objekten"
L.Move_PlayerinteractionPrompt 	= "Interaktion mit Spielern"
L.Move_healthBarText 			= "Gesundheit"
L.Move_magickaBarText 			= "Magicka"
L.Move_staminaBarText 			= "Ausdauer"
L.Move_targetBarText 			= "Ziel-Gesundheit"
L.Move_mountBarText 			= "Ausdauer des Reittieres"
L.Move_werewolfBarText 			= "Werewolf-Leiste"
L.Move_siegeBarText 			= "Gesundheit Belagerungswaffen"
L.Move_shieldText 				= "Schild"
L.Move_targetShieldText			= "Schild des Ziels"
L.Move_combatTips 				= "Combat Support"	
L.Move_LowAttributesAlert		= "Niedrige Attribute"	
L.Move_CoordsHeader 			= "Koordinaten von Containern und Leisten"
L.Move_clepsydre				= "Uhr und Chrono"

L.Move_Enable 	= "Verschieben von Containern |c00FF00aktiviert"
L.Move_Disable 	= "Verschieben von Containern |cFF0000deaktiviert"

-------
-- Demo
-------
L.Demobars			= "Zeigt ein Schild und 50% Leben"

------------------------
-- VISLUATION OF EFFECTS
------------------------
L.ShowEffectsSubMenu 	= "Visualisierung der Effekte"
L.ShowMoveModeDesc		= "Sie müssen den Move-Modus aktiviert haben, um das Ergebnis zu sehen"

-- Name of types
L.PhysicalInc		= "Erhöhte physikalische Widerstände"
L.SpellInc			= "Erhöhte Magieresistenz"
L.PhysicalDec		= "Reduzierter physischer Widerstand"
L.SpellDec			= "Reduzierte Magieresistenz"
L.PhysicalDual		= "Antinomische physikalische Widerstände"
L.SpellDual			= "Antinomische Magieresistenz"

-- Color effect
L.PhysResistIncColor	= "Erhöhter körperlicher"
L.PhysResistDecColor	= "Reduzierter körperlicher"
L.SpellResistIncColor	= "Erhöhter Magieresistenz"
L.SpellResistDecColor	= "Reduzierter Magieresistenz"
L.PhysResistDualColor	= "antinomische körperlicher"
L.SpellResistDualColor	= "antinomische Magieresistenz"

--------------------------------------
-- CONTAINER AND BARS GLOBAL SETTINGS
--------------------------------------
L.GlobalSettingsSubMenu = "Allgemeine Einstellungen"

-- Containers settings
L.BarStyle 			= "Stil"
L.BarStyleTooltip 	= "Konfiguriert den Stil, der auf die Spieler- und Zielattributleisten angewendet wird." 
L.Default_bar 		= "Standard"
L.Flat_bar			= "Flache"
L.Oblivion_bar 		= "Oblivion"
L.Ghost_bar 		= "Gespenstisch"

-- Bars stairway
L.ContainerDiv 				= "Modus Treppe"
L.ContainerLeftForm 		= "Linker Container"
L.ContainerRightForm 		= "Rechter Container"
L.ContainerStyleNormal 		= "Normal"
L.ContainerStyleStairway	= "Treppe"

-- Global settings of bars
L.BarDiv 		= "Konfigurieren Bars"
L.BarSpacing	= "Leistenab"
L.BarWidth 		= "Breite"
L.BarHeight 	= "Höhen"

-- Opacity settings
L.OpacityDiv 			= "Deckkraft"
L.OpacityOoc 			= "Außerhalb eines Kampfes (sie)"
L.OpacityAttributeUsed 	= "Der Leisten genutzter Ressourcen (sir)"
L.OpacityCombat 		= "Im Kampf (alle Bars)"
L.OpacityTargetOoc 		= "Ziel aus dem Kampf"
L.OpacityTargetinCombat = "Ziel im Kampf"

----------------------
-- GENERAL TEXT FORMAT
----------------------
L.FormatDiv				= "Paramètres des valeurs des barres"
L.FormatDecSep			= "Afficher le séparateur décimal"
L.FormatDecPer			= "Afficher un chiffre après la virgule"

---------------------
-- NAMEPLATE SETTINGS
---------------------
L.NameplateSubMenu 		= "Zielinformationen"

-- General settings
L.NamePlateDiv 				= "Eckwerte"
L.NamePlateFontSizeTooltip 	= "Ändert die Größe aller in den Zielinformationen enthaltenen Elemente"

L.NampletePlayer 	= "Zeigen Sie den Namen der"
L.NameplateAvatar 	= "Charakter"
L.NameplateAccount 	= "Konto"
L.NameplateAllone 	= "Charakter und Konto"
L.NameplateAlltow 	= "Konto und Charakter" 

-- Icons on nameplate and colors
L.NamePlateIconDiv 	= "Symbol"
L.NamePlateClass 	= "Klass zeigen"
L.NamePlateRace 	= "Zucht zeigen"
L.NamePlateLevel	= "Zeige Spieler Level"
L.NamePlateRank 	= "PvP-Rang anzeigen"
L.NamePlateAlliance = "Allianz zeigen"
L.NamePlateCaption	= "Zeige Spielertitel"

L.NamePlateIconColor 	= "Farbe der Ikonen"
L.Julianos 				= "Weiß"
L.Gold 					= "Gold"
L.Silver 				= "Geld"
L.Alliance 				= "Allianz"

-- Boss and guards on nameplate
L.BossStyle 	= "Boss-Symbole"

L.Default_boss 	= "Standard"
L.Star_boss 	= "Stern"
L.Dsword_boss 	= "Gekreuzte Schwerter"
L.Obli_boss 	= "Oblivion"
L.Skull_boss 	= "Schädel"
L.NoneIcon_boss = "Kein Symbol"

L.GuardColor = "Farbe der Ikonen der Schwierigkeiten der NPCs (Nicht-Spieler-Charaktere) \"Wächter\""

-- Critters & deaths
L.NamePlateCrittersDiv 	= "Siehe der Toten & die Lebewesen"
L.ShowCrittersTooltip	= "Lebewesen zeigen"
L.ShowDeadsTooltip		= "Lebewesen Toten"

-----------------------------------
-- DIFERENTIATION OF THE TARGET BAR
-----------------------------------
L.diffOfTargetsSubMenu = "Differenzierung der Zielleiste"

-- friendly health bar
L.AllyColorBarDiv 	= "Allied Life Speiler Bar"
L.AllyColorBarDesc 	= "Färben Sie automatisch die Zielleiste in blau (Standard), wenn das Ziel ein Spieler oder gelb ist (standardmäßig gegen Rot), wenn das Ziel ein neutraler NPC ist." 

-- Neutral NPC
L.NeutralTragetDiv		= "NPC neutral"
L.NeutralTragetTooltip 	= "Wenn aktiviert, ist die neutrale NPC-Lebensleiste die Farbe ihrer Reaktion (gelb). Im Gegenzug haben die Wachen und andere Elite-Monster eine rote Lebe-Bar, auch wenn sie neutral sind."

-------
-- BARS
-------
L.BarsSubMenu 	= "Leisten-Einstellungen"

-- Choice of bar
L.SelectedBarDiv			= "Konfiguration"
L.SelectedBar 				= "Wahl der Bar"
L.SelectedBarShowTooltip 	= "Wenn Sie die ausgewählte CurvyHud-Leiste deaktivieren, wird stattdessen die entsprechende Standard-Zenimax-Leiste angezeigt."

L.Health 		= "Leben"
L.Stamina 		= "Ausdauer"
L.Magicka 		= "Magicka"
L.Target 		= "Leben (Ziel)"
L.Mount 		= "Ausdauer (Reittier)"
L.Siege 		= "Leben (Belagerungswaffe)"
L.Werewolf 		= "Werwolfleiste"

-- bars and containers
L.BarPosition 	= "Container"
L.Left 			= "Links"
L.Right 		= "Rechts"
L.Index 		= "Index"
L.IndexTooltip 	= "Index im Container. 1 ist der Mitte des Bildschirms am nächsten"
L.BarColorMax 	= "Leistenfarbe MAX"
L.BarColorLow 	= "Leistenfarbe MIN"
L.Border		= " die Grenzen der Bar"
L.BarBkgrdColor	= "Farbe des Hintergrundes"

-- Texts of attributes
L.TextBar 		= " text der ausgewählten Leiste"
L.TextFormat 	= "Format der Textwerte"
L.TextFormatTooltip = "{val} / {max} - {per}% werden alle Werte angezeigt. \n {val} / {max} wird alles zeigen, außer dem prozentualen. \n {per}% wird nur den Prozentsatz anzeigen."

-- Color text of the attribute
L.TextColor 	= "Farbe des Textwertes"
L.DefaultColor 	= "Standardfarbe"
L.AttibuteColor = "Farbe der Attribute"

----------------------------------------------------	
-- INCREASE / DECREASE RESISTANCES and TAUNT EFFECTS
----------------------------------------------------
L.EffectsSettingsSubMenu = "Resistenz-Effekte und Verspottung"

-- Effect
L.MajorIncEffect 	= " die positiven Haupteffekte"
L.MajorDecEffect 	= " die negativen Haupteffekte"
L.MinorIncEffect 	= " die positiven kleinerEffekt"
L.MinorDecEffect 	= " die negativen kleinerEffekt"
L.DualEffect		= " die antinomischen Effekte"
L.DualEffectTooltip	= "Ersetzt die Reduktions- und Vergrösserungseffekte desselben Typs durch einen anderen Effekt, der Klarheit halber. Beispiel: Wenn Sie unter \"Hauptauflösung\" sind und Sie \"große Fraktur\" erleiden, werden die beiden Balken durch den physischen Antinomic-Balken ersetzt."

-- Taunt effect
L.TauntEffectDiv 	= "Verspottung"

-----------------------------------	
-- REGEN / DEGEN and SHIELD EFFECTS
-----------------------------------
L.VisualsSettingsSubMenu = "Regen/Degen und Schild"

-- Regen/Degen
L.RegenDiv 			= "Regen und Degen"

-- Shield
L.ShieldDiv 		= "Schild"
L.ShieldColor 		= "Farbe des Schild"
L.ShieldTextShow 	= "Textwerte für Schilde anzeigen"
L.ShieldTextColor 	= "Farbe der Textwerte für Schild"

----------------
-- COMBAT HELPER
----------------
L.CombatHelperSubMenu = "Kampfunterstützung & Kampfhilfe"

-- Low attributes
L.LowAttribDiv 		= "Niedrige Attribute"
L.LowAttribHealth 	= "schlechte Gesundheit!"
L.LowAttribStamina 	= "geringe Ausdauer!"
L.LowAttribMagicka 	= "niedrige Magie!"
L.LowAttribTrigger 	= "Alarmschwelle"

-- Combat tips
L.TipsDiv 			= "Kampfunterstützung"
L.TipsTooltip 		= "Wenn aktiviert, wird die Kampfhilfe auf dem Bildschirm angezeigt, um dich vor den Handlungen deines Feindes zu warnen."
L.TipsZoTips 		= "Symbole ausblenden Zenimax"
L.TipsBloc 			= "Block!"
L.TipsExploit 		= "Verwenden!"
L.TipsInterrupt 	= "Stop!"
L.TipsDodge 		= "Ausweichen!"

----------------------------------
-- COMBAT STATE, COMPASS & RETICLE
----------------------------------
L.CompassSubMenu	= "Kompass, Absehen und Alarm"
L.InfoTooltip		= "Rot im Kampf, grün, wenn es verkleidet ist, orange bei Gefahr, gelb, wenn es ohne Kampf erkannt werden soll."

-- Combat state
L.CombatStateDiv 	= "Kampf und Verkleidungsmodus"
L.CombatCompass		= "Kompass: Nimmt die Farbe des aktuellen Zustands an"
L.CombatVisibility 	= "Ermöglicht hoch Sichtbarkeit"

-- Compass
L.CompassDiv 		= "Kompasses"
L.CompassTexture	= "Deaktiviert die Textur"
L.CompassBoss 		= "Aktivieren Bossbar"

-- Reticle
L.ReticleDiv 			= "Absehen"
L.ReticleStealthText	= "Zustand Versteckter/Entdeckter ausblenden"
L.ReticleTexture		= "Absehen Textur"
L.ReticleDefault		= "Default"
L.ReticleCurvyHUD		= "CurvyHud"
L.ReticleColor			= "Reaktionsfarbe"
L.ReticleColorAlert		= "Absehen: nimmt die Farbe des aktuellen Zustands an"
L.ReticleAlertColorTooltip	= "Zustand des Tages in Farbe : rot im Kampf, grün wenn verkleidet, gelb wenn die Abrechnung nicht mehr funktioniert, orange wenn Gefahr besteht die Tarnung zu verlieren."

------
--CHAT
------
L.ChatSubMenu			= "INFOCHAT"
L.CombatChat 			= "Ermöglicht die \"IM KAMPF-Status-Anzeige\" im Chat"
L.CovertChat			= "Statuswechsel \"abgedeckt\" im Chat"
L.gMateArrival			= "Der Spieler|cFF9500 "
L.gMateOnLine			= "|cFFFFFF ist |c00FF00online."
L.gMateOffLine			= "|cFFFFFF ist |cFF0000offline."
L.gMateNotDisturb		= "|cFFFFFF ist in |cFF0000\"nicht stören\"."
L.gMateABS				= "|cFFFFFF ist |cFFFF00abwesend."
L.ChatDiv				= "Guilden"
L.gOne					= "G1 : "
L.gTow					= "G2 : "
L.gThree				= "G3 : "
L.gFour					= "G4 : "
L.gFive					= "G5 : "
L.GuildWarning 			= "Wenn du kürzlich dieser Gilde beigetreten bist oder sie verlassen hast, muss CurvyHud (/ reloadui) neu geladen werden."

------------
-- CLEPSYDRE
------------
L.ClepsydreSubMenu		= "Uhr und Stoppuhr"
L.ClepsydreShowTooltip	= "Zeigen oder nicht die Uhr"
L.ClepdyreOpacity		= "Deckkraft der Uhr"
L.ClepsydreColor		= "Farbe der Schrift"
L.ClepsydreChronoRAZ1	= "|cFF0000/!\\ |cFF9900Warten Sie, bis das Stoppuhr-Logo |cFFFF00gelb|cFF9900 wird, um es zurückzusetzen |cFF0000/!\\"
L.ClepsydreChronoRAZ	= "Stoppuhr |cFF0000auf Null gestellt|cFFFFFF"
L.ClepsydreChronoStart	= "Stoppuhr |c00FF00gestartet!"
L.ClepsydreChronoResult = " Dauer des Stoppuhr : |cFF9500"
L.clepsydreChronoAuto	= " - im |cFF9500automatischen Modus|cFFFFFF."
L.clepsydreChronoMano	= " - im |cFF9500manuellen Modus|cFFFFFF."
L.clepsydreChronoSP		= " - im |cFF9500SpeedRun Modus|cFFFFFF."

-----------------
-- ACKNOWLEDGMENT
-----------------
L.AcknowledgmentDiv 		= "Vielen Dank"
L.AcknowledgmentAuthor 		= "Dank an |cFF0000Niocwy |cFFFFFFfür die anfängliche Entwicklung von |c7B18FFCurvyHud|cFFFFFF."
L.AcknowledgmentSubMenu 	= "Entwickler, Tester und Mitwirkende"
L.AcknowledgmentThank		= "Dank an : "
L.AcknowledgmentText 		= "|c1CA8D6Seerah|cFFFFFF für die Schaffung und Entwicklung von|cFFFF57 \"LibAddonMenu 2.0\" |cFFFFFF. \n|c1CA8D6Phinix, Garkin, Kith, silentgecko|cFFFFFF für die Schaffung und Entwicklung von|cFFFF57Srendarr|cFFFFFF.\n|c1CA8D6Agade|cFFFFFF für die Schaffung |cFFFF57\"GG Frames Fix\"|cFFFFFF.\n|c1CA8D6Harven|cFFFFFF für die Schaffung |cFFFF57\"Harven's Bag Space\"|cFFFFFF. \n|c1CA8D6GetBackYouPansy |cFFFFFF für das Erstellen von|cFFFF57 \"PL Combat Indicator\"|cFFFFFF."
L.AcknowledgmentTextTwo		= "|c1CA8D6CaptainBlagbird |cFFFFFFum mir zu erlauben, einige seiner Add-ons zu integrieren."
L.AcknowledgmentTextThree 	= "|c8bf4e8Cedric D. |cFFFFFF für die Hilfe bei den Texturdateien." 
L.AcknowledgmentTextFour	= "|c1CA8D6Raghor|cFFFFFF & |c1CA8D6Eldrikh |cFFFFFFfür die deutsche Übersetzung. \n|c8bf4e8BloodEagle &|cFFFFFF, |c8bf4e8Aprilm |cFFFFFF, |c8bf4e8Caerdon |cFFFFFFund |c8bf4e8Xantaria |cFFFFFFFür für ihre vielen Renditen.\n\nBesonderer Dank geht an |c1CA8D6Eldrikh |cFFFFFF& |c1CA8D6Teboral|cFFFFFF."
-----------------
-- SLASH COMMANDS
-----------------
L.CurvySlashCmd	 	= "/curvyhud"
L.CurvySlash 		= "\n \/curvyhud|cFFFFFF öffnet das |c922BFFCurvyHud-Menü. \n \/curvy_move on |cFFFFFF gibt die einzelnen Elemente zum Verschieben frei. \n \/curvy_move off|cFFFFFF sperrt die einzelnen Elemente. \n \/curvy_raz |cFFFFFF: setzt die Todeszählung auf Null zurück."
L.CurvySlashTow	= "\/curvy_chrono mano|cFFFFFF: Aktivieren Sie den Chrono-Handmodus. \n \/curvy_chrono auto |cFFFFFF: Aktivieren Sie den Timer, wenn Sie in einen Bosskampf eintreten. \n \/curvy_chrono sp |cFFFFFF: Aktiviere den Timer, wenn du einen Schlachtzug und/oder einen Dungeon betrittst."
L.CurvyChat 		= "Um die möglichen Befehle anzuzeigen, geben Sie |c00FF00 \/curvy ?|cFFFFFF im Chat ein."
L.CurvyCmdErr 		= "Dies ist ungültiger Befehl!"
L.CurvyInf 			= " Hinzufügen \"|cFF9500 on|cFFFFFF\" oder \"|cFF9500 off|cFFFFFF\" für die Befehl gültig zu sein."
L.CurvyInfo 		= " Hinzufügen \"|cFF9500 ?|cFFFFFF\" für die Befehl gültig zu sein."
L.CurvyInftwo		= " Ajouter \"|cFF9500 mano|cFFFFFF\" ou \"|cFF9500 auto|cFFFFFF\" pour que la commande soit valide."
L.CurvyCombatOn 	= "|cFF0000 IM KAMPF|cFFFFFF  "
L.CurvyCombatOff	= "|c00FF00 AUS DEM KAMPF|cFFFFFF "
L.CurvyFrames 		= "|cFFFF00*** LISTE DER BEFEHLE *** \n |cFFFFFF Sie auch zuweisen |cFF0000eine Tastenkombination|cFFFFFF um die Auffrischung zu erzwingen im Falle des plötzlichen Verschwindens einer Stange."

--------------------------------
-- STEALTHSTATE & DISGUISE STATE
--------------------------------
L.CurvyDisguiseOn 			= "Du bist |c00FF00verkleidet|cFFFFFF."
L.CurvyDisguiseDanger 		= "Sie sind |cFF9500in Gefahr|cFFFFFF, entdeckt zu werden und Ihre Verkleidung zu verlieren!"
L.CurvyDisguiseDangerOff	= "Wenn Sie |cD25032getroffen|cFFFFFF werden, verlieren Sie Ihre Deckung."
L.CurvyDisguiseOff 			= "Du bist |cFFFF00nicht|cFFFFFF abgedeckt."
L.CurvyDiscovered 			= "Du bist |cFFFF00nicht|cFFFFFF mehr bedeckt."
L.CurvyDisguiseImpossible 	= "Du kannst dich |cFF0000nicht|cFFFFFF selbst abdecken."

-----------------------
-- WELCOME INFORMATIONS
-----------------------
L.CurvyWelcome 			= "willkommen|cFF9500 " 
L.CurvyWelcomeEnd 		= "|cFFFFFF, viel Spaß beim Spielen."
L.WelcomeBegin			= "|cFFFFFF Du spielst mit |cFF9500"
L.WelcomeTimeWithAvatar	= " |cFFFFFFseit|cFF9500 "
L.WelcomeDays			= "|cFFFFFF Tagen,|cFF9500 "
L.WelcomeHours			= "|cFFFFFF Stunden, und|cFF9500 "
L.WelcomeMinutes		= "|cFFFFFF Minuten."

-----------------------------------------
-- DEATH INFORMATION & DUNGEON DIFFICULTY
-----------------------------------------
L.TrollEnable		= "Trollage im Chat aktivieren."

L.DeadCountRAZ 		= "|cFFFFFFDein deathmeter wurde |c00FF00zurückgesetzt|cFFFFFF."
L.Deathbegin		= "|cFFFFFF Anzahl der |cFF0000Todesfälle|cFFFFFF :|cffff00 "
-- in dungeon
L.DeadDungeonA		= "|cFFFFFF vor der ganzen |cFF9500Gruppe|cFFFFFF... Reiß dich zusammen!"
L.DeadDungeonB		= "|cFFFFFF Du bist |cFF9500nervtötend lausig|cFFFFFF, weißt du..."
L.DeadDungeonC		= "|cFFFFFF Hast ne |cFF9500harte|cFFFFFF Zeit, |cFF9500"..CurvyHud.avatarName.."|cFFFFFF ?"
L.DeadDungeonD		= "|cFFFFFF |cFF9500"..CurvyHud.avatarName.."|cFFFFFF, das ist hier nicht die |cFF9500Pilzgrotte|cFFFFFF!"
L.DeadDungeonE		= "|cFFFFFF Beim nächsten Mal, bring ein paar |cFF9500mehr Freunde|cFFFFFF mit!"
L.DeadDungeonF		= "|cFFFFFF Es sieht aus als würdest |cFF9500du schwächeln|cFFFFFF... Erschöpfung vielleicht?"
L.DeadDungeonG		= "|cFFFFFF Ist das etwa |cFF9500Hass|cFFFFFF in deinen Augen?"
L.DeadDungeonH		= "|cFF9500"..CurvyHud.avatarName.."|cFFFFFF, Meinst du nicht du solltest deine |cFF9500Fäustlinge|cFFFFFF ausziehen ?"
L.DeadDungeonI		= "|cFFFFFF Du weißt schon das |cFF9500rote Zonen|cFFFFFF auf dem Boden keine Buffs sind, oder ?"
L.DeadDungeonJ		= "|cFFFFFF Sieht aus wie |cFF9500das Ende|cFFFFFF deiner Gruppe... wie Schade !"
L.DeadDungeonK		= "|cFFFFFF Du solltest kurz was essen bevor du wieder |cFF9500getötet wirst|cFFFFFF."
-- in world
L.DeadInWorldA		= "|cFFFFFF Das war eine Vorstellung auf |cFF9500unglaublich|cFFFFFF hohem Niveau !"
L.DeadInWorldB		= "|cFFFFFF Fühlst du die |cFF9500Frustration|cFFFFFF?"
L.DeadInWorldC		= "|cFFFFFF |cFF9500Pathetisch "..CurvyHud.avatarName.."|cFFFFFF..."
L.DeadInWorldD		= "|cFFFFFF Ein weiterer |cFF9500lächerlicher|cFFFFFF Tod auf deinem deathmeter!"
L.DeadInWorldE		= "|cFF9500"..CurvyHud.avatarName.."|cFFFFFF, du hast |cFF9500wirklich ordentlich|cFFFFFF was aufs Mal bekommen."
L.DeadInWorldF		= "|cFFFFFF Autsch... das ist |cFF9500zu schlecht|cFFFFFF."
L.DeadInWorldG		= "|cFFFFFF Und |cFF9500noch einmal|cFFFFFF!"
L.DeadInWorldH		= "|cFFFFFF Gut gemacht |cFF9500"..CurvyHud.avatarName.."|cFFFFFF!"
L.DeadInWorldI		= "|cFFFFFF Dein Skill |cFF9500geht garnicht|cFFFFFF..."
L.DeadInWorldJ		= "|cFFFFFF man kann dir dafür noch |cFF9500nicht einen Vorwurf|cFFFFFF machen..."
-- dungeaon diff
L.Dungeonbegin 		= "|cFFFFFF Dieser Dungeon wurde zurückgesetzt auf : " 
L.DungeonNormalDiff = "|cFF9500normal Modus|cFFFFFF."
L.DungeonVetDiff	= "|cFF9500Veteran Modus|cFFFFFF."
-- stuff
L.Repair			= "|cFFFFFF Du solltest darüber nachdenken deine Ausrüstung |cFF9500reparieren zu lassen|cFFFFFF..."