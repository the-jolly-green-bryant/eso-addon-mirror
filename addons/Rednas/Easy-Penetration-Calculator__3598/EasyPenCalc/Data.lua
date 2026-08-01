EPC = EPC or {}

--Basic values
EPC.name = "EasyPenCalc"
EPC.fullName = "Easy Penetration Calculator"
EPC.version = "0.9.6"

--GUI values
EPC.GUI = {}
EPC.GUI.Main = EPC_GUI
EPC.GUI.ColOne = EPC_GUIColOne
EPC.GUI.ColTwo = EPC_GUIColTwo
EPC.GUI.SummaryContainer = EPC_GUISummary

--Color values
EPC.GUI.Color = {}
EPC.GUI.Color.white = {r = 255, g = 255, b = 255}
EPC.GUI.Color.grey = {r = 100, g = 100, b = 100}
EPC.GUI.Color.red = {r = 255, g = 0, b = 0}
EPC.GUI.Color.orange = {r = 255, g = 129, b = 0}
EPC.GUI.Color.green = {	r = 126, g = 255, b = 0}
EPC.GUI.Color.checkButtonActive = {r = 197, g = 194, b = 158}
EPC.GUI.Color.checkButtonActiveHighlight = {r = 239, g = 235, b = 190}
EPC.GUI.Color.checkButtonInactive = {r = 197-100, g = 194-100, b = 158-100}
EPC.GUI.Color.checkButtonInactiveHighlight = {r = 239-100, g = 235-100, b = 190-100}

-----------------------------------------------------------------------------
-- GAME VALUES
-----------------------------------------------------------------------------
EPC.Values = {}
EPC.Values.infusedWeapon = 0.3 --30%
EPC.Values.divines = 0.091 --9.1%%


EPC.Values.Pen = {}
EPC.Values.Pen.required = 18200
EPC.Values.Pen.requiredOverland = EPC.Values.Pen.required/2

--Pen Debuff
EPC.Values.Pen.majorBreach = 5948
EPC.Values.Pen.minorBreach = 2974
EPC.Values.Pen.crystalWeapon = 1000
EPC.Values.Pen.runicSunder = 2200
--Pen Group sets/gear
EPC.Values.Pen.Crusher = {}
EPC.Values.Pen.Crusher.twoHanded = 1622
EPC.Values.Pen.Crusher.twoHandedInfused = math.floor(EPC.Values.Pen.Crusher.twoHanded*(1+EPC.Values.infusedWeapon))
EPC.Values.Pen.Crusher.oneHanded = EPC.Values.Pen.Crusher.twoHanded/2
EPC.Values.Pen.Crusher.oneHandedInfused = math.floor(EPC.Values.Pen.Crusher.oneHanded*(1+EPC.Values.infusedWeapon))
EPC.Values.Pen.tremorscale = 2400
EPC.Values.Pen.alkosh = 6000
EPC.Values.Pen.crimsonOath = 3541
--Pen Passives
EPC.Values.Pen.nightbladePassive = 2974
EPC.Values.Pen.necromancerPassive = 1500
EPC.Values.Pen.cPPassive = 700
EPC.Values.Pen.woodElfPassive = 950
EPC.Values.Pen.forceOfNatureSingle = 660
EPC.Values.Pen.arcanistPassiveSingle = 991
EPC.Values.Pen.loverMundus = {}
EPC.Values.Pen.loverMundus.noDivines 	= 2744
EPC.Values.Pen.loverMundus.oneDivines 	= math.floor(EPC.Values.Pen.loverMundus.noDivines * (1+(EPC.Values.divines * 1 )))
EPC.Values.Pen.loverMundus.twoDivines 	= math.floor(EPC.Values.Pen.loverMundus.noDivines * (1+(EPC.Values.divines * 2 )))
EPC.Values.Pen.loverMundus.threeDivines = math.floor(EPC.Values.Pen.loverMundus.noDivines * (1+(EPC.Values.divines * 3 )))
EPC.Values.Pen.loverMundus.fourDivines 	= math.floor(EPC.Values.Pen.loverMundus.noDivines * (1+(EPC.Values.divines * 4 )))
EPC.Values.Pen.loverMundus.fiveDivines 	= math.floor(EPC.Values.Pen.loverMundus.noDivines * (1+(EPC.Values.divines * 5 )))
EPC.Values.Pen.loverMundus.sixDivines 	= math.floor(EPC.Values.Pen.loverMundus.noDivines * (1+(EPC.Values.divines * 6 )))
EPC.Values.Pen.loverMundus.sevenDivines	= math.floor(EPC.Values.Pen.loverMundus.noDivines * (1+(EPC.Values.divines * 7 )))
EPC.Values.Pen.loverMundus.eightDivines	= math.floor(EPC.Values.Pen.loverMundus.noDivines * (1+(EPC.Values.divines * 8 )))
--Pen Player Gear
EPC.Values.Pen.penLine = 1487
EPC.Values.Pen.lightPiece = 939
EPC.Values.Pen.Weapon = {}
EPC.Values.Pen.Weapon.mace = 1650
EPC.Values.Pen.Weapon.maul = EPC.Values.Pen.Weapon.mace*2
EPC.Values.Pen.Sharpend = {}
EPC.Values.Pen.Sharpend.oneHanded = 1638
EPC.Values.Pen.Sharpend.twoHanded = EPC.Values.Pen.Sharpend.oneHanded*2
EPC.Values.Pen.arenaWeapon = 1190
EPC.Values.Pen.velothiUr = 1650
EPC.Values.Pen.shatteredFate = 7918

-----------------------------------------------------------------------------
-- FORM FIELD DEFAULT VALUES
-----------------------------------------------------------------------------

EPC.FormFieldDefaultValue = {}
--For the checkboxes
EPC.FormFieldDefaultValue["MajorBreach"] = true
EPC.FormFieldDefaultValue["MinorBreach"] = true
EPC.FormFieldDefaultValue["RunicSunder"] = false
EPC.FormFieldDefaultValue["Tremorscale"] = false
EPC.FormFieldDefaultValue["Alkosh"] = false
EPC.FormFieldDefaultValue["CrimsonOath"] = false
EPC.FormFieldDefaultValue["CrystalWeapon"] = false
EPC.FormFieldDefaultValue["NightbladePassive"] = false
EPC.FormFieldDefaultValue["NecromancerPassive"] = false
EPC.FormFieldDefaultValue["CPPassive"] = true
EPC.FormFieldDefaultValue["WoodElfPassive"] = false
EPC.FormFieldDefaultValue["VelothiUr"] = false
EPC.FormFieldDefaultValue["ShatteredFate"] = false
EPC.FormFieldDefaultValue["ArenaWeapon"] = false
--Dropdown
EPC.FormFieldDefaultValue["Crusher"] = "twoHandedInfused" --0 none
EPC.FormFieldDefaultValue["AmountOfPenLines"] = 0
EPC.FormFieldDefaultValue["AmountOfLightPieces"] = 0
EPC.FormFieldDefaultValue["AmountOfDebuffsForForceOfNature"] = 0
EPC.FormFieldDefaultValue["AmountOfSkillsSlottedForArcanistPassive"] = 0
EPC.FormFieldDefaultValue["Weapon"] = 0 --0 none
EPC.FormFieldDefaultValue["Sharpend"] = 0 --0 none
EPC.FormFieldDefaultValue["LoverMundus"] = 0

--The table to save the form data in
EPC.FormField = {}