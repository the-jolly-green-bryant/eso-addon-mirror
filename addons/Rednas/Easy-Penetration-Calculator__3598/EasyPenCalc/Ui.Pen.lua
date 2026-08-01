EPC = EPC or {}
EPC.UI = EPC.UI or {}
EPC.UI.PEN = EPC.UI.PEN or {}
EPC.GUI = EPC.GUI or {}
EPC.GUI.Summary = EPC.GUI.Summary or {}

function EPC.UI.PEN.Initialize()
	EPC.UI.PEN.InitColOne()
	EPC.UI.PEN.InitColTwo()
	EPC.UI.PEN.InitSummary()
end

function EPC.UI.PEN.InitColOne()
	local lastControl = EPC.UI.PEN.InitGroup(EPC.GUI.ColOne, EPC.GUI.ColOne)
	lastControl = EPC.UI.PEN.InitPlayer(EPC.GUI.ColOne, lastControl)
end

function EPC.UI.PEN.InitColTwo()
	local lastControl = EPC.UI.PEN.InitDebuffs(EPC.GUI.ColTwo, EPC.GUI.ColTwo)
	lastControl = EPC.UI.PEN.InitPassives(EPC.GUI.ColTwo, lastControl)
end

function EPC.UI.PEN.InitDebuffs(parentContainer, relatedTo)
	local header_Debuffs = EPC.UI.CreateWindowHeader(
		{
		parent = parentContainer,
		name = "Debuffs", 
		labelText = "Debuffs",
		anchor = {
			relativeTo = relatedTo, 
			relativePoint = TOPLEFT
			}
		})
		
	local checkbox_MajorBreach = EPC.UI.CreateCheckbutton(
		{
		parent = parentContainer,
		name = "MajorBreach", 
		default = EPC.FormFieldDefaultValue["MajorBreach"],
		labelText = "Major breach ("..EPC.Values.Pen.majorBreach..")",
		anchor = {
			relativeTo = header_Debuffs
			}
		})
	local checkbox_MinorBreach = EPC.UI.CreateCheckbutton(
		{
		parent = parentContainer, 
		name = "MinorBreach", 
		default = EPC.FormFieldDefaultValue["MinorBreach"],
		labelText = "Minor breach ("..EPC.Values.Pen.minorBreach..")",
		anchor = {
			relativeTo = checkbox_MajorBreach
			}
		})
	local checkbox_CrystalWeapon = EPC.UI.CreateCheckbutton(
		{
		parent = parentContainer, 
		name = "CrystalWeapon", 
		default = EPC.FormFieldDefaultValue["CrystalWeapon"],
		labelText = "Crystal weapon ("..EPC.Values.Pen.crystalWeapon..")",
		anchor = {
			relativeTo = checkbox_MinorBreach
			}
		})
	local combobox_RunicSunder = EPC.UI.CreateCheckbutton(
		{
		parent = parentContainer,
		name = "RunicSunder", 
		default = EPC.FormFieldDefaultValue["RunicSunder"],
		labelText = "Runic Sunder ("..EPC.Values.Pen.runicSunder..")",
		anchor = {
			relativeTo = checkbox_CrystalWeapon
			}
		})
	return combobox_RunicSunder
end

function EPC.UI.PEN.InitGroup(parentContainer, relatedTo)
	local header_Group = EPC.UI.CreateWindowHeader(
		{
		parent = parentContainer,
		name = "test3", 
		labelText = "Group gear",
		anchor = {
			relativeTo = relatedTo, 
			relativePoint = TOPLEFT
			}
		})
	local checkbox_Tremorscale = EPC.UI.CreateCheckbutton(
		{
		parent = parentContainer, 
		name = "Tremorscale", 
		default = EPC.FormFieldDefaultValue["Tremorscale"],
		labelText = "Tremorscale ("..EPC.Values.Pen.tremorscale..")",
		anchor = {
			relativeTo = header_Group
			}
		})
	local checkbox_Alkosh = EPC.UI.CreateCheckbutton(
		{
		parent = parentContainer, 
		name = "Alkosh", 
		default = EPC.FormFieldDefaultValue["Alkosh"],
		labelText = "Alkosh ("..EPC.Values.Pen.alkosh..")",
		anchor = {
			relativeTo = checkbox_Tremorscale
			}
		})
	local checkbox_Crimson = EPC.UI.CreateCheckbutton(
		{
		parent = parentContainer, 
		name = "CrimsonOath", 
		default = EPC.FormFieldDefaultValue["CrimsonOath"],
		labelText = "Crimson oath ("..EPC.Values.Pen.crimsonOath..")",
		anchor = {
			relativeTo = checkbox_Alkosh
			}
		})
	local combobox_Crusher = EPC.UI.CreateCombobox(
		{
		parent = parentContainer,
		name = "Crusher", 
		default = EPC.FormFieldDefaultValue["Crusher"],
		labelText = "Crusher enchant",
		anchor = {
			relativeTo = checkbox_Crimson
			}
		},
		{
			[1] = {name = "No crusher enchant (0)"												, value = 0						, isInactive = true},
			[2] = {name = "Two-handed ("..EPC.Values.Pen.Crusher.twoHanded..")"					, value = "twoHanded"},
			[3] = {name = "Two-handed infused ("..EPC.Values.Pen.Crusher.twoHandedInfused..")"	, value = "twoHandedInfused"},
			[4] = {name = "One-handed ("..EPC.Values.Pen.Crusher.oneHanded..")"					, value = "oneHanded"},
			[5] = {name = "One-handed infused ("..EPC.Values.Pen.Crusher.oneHandedInfused..")"	, value = "oneHandedInfused"},
		})
	return combobox_Crusher
end

function EPC.UI.PEN.InitPassives(parentContainer, relatedTo)
	local header_Passives = EPC.UI.CreateWindowHeader(
		{
		parent = parentContainer,
		name = "passives", 
		labelText = "Passives",
		anchor = {
			relativeTo = relatedTo, 
			offsetY = 16
			}
		})
	local combobox_CPPassive = EPC.UI.CreateCheckbutton(
		{
		parent = parentContainer,
		name = "CPPassive", 
		default = EPC.FormFieldDefaultValue["CPPassive"],
		labelText = "CP passive ("..EPC.Values.Pen.cPPassive..")",
		anchor = {
			relativeTo = header_Passives
			}
		})
	local combobox_Nightblade = EPC.UI.CreateCheckbutton(
		{
		parent = parentContainer,
		name = "NightbladePassive", 
		default = EPC.FormFieldDefaultValue["NightbladePassive"],
		labelText = "Nightblade passive ("..EPC.Values.Pen.nightbladePassive..")",
		anchor = {
			relativeTo = combobox_CPPassive
			}
		})
	local combobox_Necro = EPC.UI.CreateCheckbutton(
		{
		parent = parentContainer,
		name = "NecromancerPassive", 
		default = EPC.FormFieldDefaultValue["NecromancerPassive"],
		labelText = "Necro passive ("..EPC.Values.Pen.necromancerPassive..")",
		anchor = {
			relativeTo = combobox_Nightblade
			}
		})
	local combobox_ArcanistPassive = EPC.UI.CreateCombobox(
		{
		parent = parentContainer,
		name = "AmountOfSkillsSlottedForArcanistPassive", 
		default = EPC.FormFieldDefaultValue["AmountOfSkillsSlottedForArcanistPassive"],
		labelText = "Arcanist passive ("..EPC.Values.Pen.arcanistPassiveSingle..")",
		anchor = {
			relativeTo = combobox_Necro 
			}
		},
		{
			[1] = {name = "0 skills slotted"	, value = 0		, isInactive = true},
			[2] = {name = "1 skill slotted"		, value = 1},
			[3] = {name = "2 skills slotted"	, value = 2},
			[4] = {name = "3 skills slotted"	, value = 3},
			[5] = {name = "4 skills slotted"	, value = 4},
			[6] = {name = "5 skills slotted"	, value = 5},
			[7] = {name = "6 skills slotted"	, value = 6},
		})
	local combobox_WoodElf = EPC.UI.CreateCheckbutton(
		{
		parent = parentContainer, 
		name = "WoodElfPassive", 
		default = EPC.FormFieldDefaultValue["WoodElfPassive"],
		labelText = "Wood Elf passive ("..EPC.Values.Pen.woodElfPassive..")",
		anchor = {
			relativeTo = combobox_ArcanistPassive
			}
		})
	local combobox_ForceOfNature = EPC.UI.CreateCombobox(
		{
		parent = parentContainer,
		name = "AmountOfDebuffsForForceOfNature", 
		default = EPC.FormFieldDefaultValue["AmountOfDebuffsForForceOfNature"],
		labelText = "Force of Nature ("..EPC.Values.Pen.forceOfNatureSingle..")",
		anchor = {
			relativeTo = combobox_WoodElf 
			}
		},
		{
			[1] = {name = "0 status effects"	, value = 0		, isInactive = true},
			[2] = {name = "1 status effect"		, value = 1},
			[3] = {name = "2 status effects"	, value = 2},
			[4] = {name = "3 status effects"	, value = 3},
			[5] = {name = "4 status effects"	, value = 4},
			[6] = {name = "5 status effects"	, value = 5},
			[7] = {name = "6 status effects"	, value = 6},
			[8] = {name = "7 status effects"	, value = 7},
			[9] = {name = "8 status effects"	, value = 8},
		})
	
	local combobox_LoverMundus = EPC.UI.CreateCombobox(
		{
		parent = parentContainer,
		name = "LoverMundus", 
		default = EPC.FormFieldDefaultValue["LoverMundus"],
		labelText = "Lover Mundus",
		tooltipText = "Divines trait is calculated based on golden gear. For purple or lower, the penetration is a little less.",
		anchor = {
			relativeTo = combobox_ForceOfNature
			}
		},
		{
			[1] = {name = "No lover mundus"																			, value = 0					, isInactive = true},
			[2] = {name = "Lover Mundus, no divines ("..		EPC.Values.Pen.loverMundus.noDivines..")"			, value = "noDivines"},
			[3] = {name = "Lover Mundus, one divines ("..		EPC.Values.Pen.loverMundus.oneDivines..")"			, value = "oneDivines"},
			[4] = {name = "Lover Mundus, two divines ("..		EPC.Values.Pen.loverMundus.twoDivines..")"			, value = "twoDivines"},
			[5] = {name = "Lover Mundus, three divines ("..		EPC.Values.Pen.loverMundus.threeDivines..")"		, value = "threeDivines"},
			[6] = {name = "Lover Mundus, four divines ("..		EPC.Values.Pen.loverMundus.fourDivines..")"			, value = "fourDivines"},
			[7] = {name = "Lover Mundus, five divines ("..		EPC.Values.Pen.loverMundus.fiveDivines..")"			, value = "fiveDivines"},
			[8] = {name = "Lover Mundus, six divines ("..		EPC.Values.Pen.loverMundus.sixDivines..")"			, value = "sixDivines"},
			[9] = {name = "Lover Mundus, seven divines ("..		EPC.Values.Pen.loverMundus.sevenDivines..")"		, value = "sevenDivines"},
			[10] = {name = "Lover Mundus, eight divines ("..	EPC.Values.Pen.loverMundus.eightDivines..")"		, value = "eightDivines"},
		})
	
	return combobox_LoverMundus
end

function EPC.UI.PEN.InitPlayer(parentContainer, relatedTo)
	local header_Player = EPC.UI.CreateWindowHeader(
		{
		parent = parentContainer,
		name = "test4", 
		labelText = "Player's gear",
		anchor = {
			relativeTo = relatedTo, 
			offsetY = 16
			}
		})
	local combobox_LightArmor = EPC.UI.CreateCombobox(
		{
		parent = parentContainer,
		name = "AmountOfLightPieces", 
		default = EPC.FormFieldDefaultValue["AmountOfLightPieces"],
		labelText = "Light armor ("..EPC.Values.Pen.lightPiece..")",
		anchor = {
			relativeTo = header_Player 
			}
		},
		{
			[1] = {name = "0 pieces"	, value = 0		, isInactive = true},
			[2] = {name = "1 piece"		, value = 1},
			[3] = {name = "2 pieces"	, value = 2},
			[4] = {name = "3 pieces"	, value = 3},
			[5] = {name = "4 pieces"	, value = 4},
			[6] = {name = "5 pieces"	, value = 5},
			[7] = {name = "6 pieces"	, value = 6},
			[8] = {name = "7 pieces"	, value = 7},
		})
	local combobox_PenLine = EPC.UI.CreateCombobox(
		{
		parent = parentContainer, 
		name = "AmountOfPenLines", 
		default = EPC.FormFieldDefaultValue["AmountOfPenLines"],
		labelText = "Penetration line ("..EPC.Values.Pen.penLine..")*",
		tooltipText = "Gear can have a set bonus, one of these bonusses can be a buff to your passive penetration. In this addon a set bonus that gives penetration is called \"Penetration line\".",
		anchor = {
			relativeTo = combobox_LightArmor 
			}
		},
		{
			[1] = {name = "0 lines"	, value = 0		, isInactive = true},
			[2] = {name = "1 line"	, value = 1},
			[3] = {name = "2 lines"	, value = 2},
			[4] = {name = "3 lines"	, value = 3},
			[5] = {name = "4 lines"	, value = 4},
			[6] = {name = "5 lines"	, value = 5},
			[7] = {name = "6 lines"	, value = 6},
			[8] = {name = "7 lines"	, value = 7},
		})
	local checkbox_ArenaWeapon = EPC.UI.CreateCheckbutton(
		{
		parent = parentContainer, 
		name = "ArenaWeapon", 
		default = EPC.FormFieldDefaultValue["ArenaWeapon"],
		labelText = "Arena weapon ("..EPC.Values.Pen.arenaWeapon..")*",
		tooltipText = "Some arena weapons have a perfected bonus, this bonus is a bit different than a standard penetration line on a gear piece. For an example you can check the maelstrom perfected destruction staff.",
		anchor = {
			relativeTo = combobox_PenLine
			}
		})
	local combobox_Sharpend = EPC.UI.CreateCombobox(
		{
		parent = parentContainer,
		name = "Sharpend", 
		default = EPC.FormFieldDefaultValue["Sharpend"],
		labelText = "Sharpend trait",
		anchor = {
			relativeTo = checkbox_ArenaWeapon
			}
		},
		{
			[1] = {name = "No sharpend trait (0)"											, value = 0				, isInactive = true},
			[2] = {name = "One-handed Sharpend ("..EPC.Values.Pen.Sharpend.oneHanded..")"	, value = "oneHanded"},
			[3] = {name = "Two-handed Sharpend ("..EPC.Values.Pen.Sharpend.twoHanded..")"	, value = "twoHanded"},
		})
	local combobox_Weapon = EPC.UI.CreateCombobox(
		{
		parent = parentContainer,
		name = "Weapon", 
		default = EPC.FormFieldDefaultValue["Weapon"],
		labelText = "Weapon (Mace/Maul)",
		anchor = {
			relativeTo = combobox_Sharpend
			}
		},
		{
			[1] = {name = "Neither (0)"									, value = 0			, isInactive = true},
			[2] = {name = "Mace ("..EPC.Values.Pen.Weapon.mace..")"		, value = "mace"},
			[3] = {name = "Maul ("..EPC.Values.Pen.Weapon.maul..")"		, value = "maul"},
		})
	local checkbox_VelothiUr = EPC.UI.CreateCheckbutton(
		{
		parent = parentContainer, 
		name = "VelothiUr", 
		default = EPC.FormFieldDefaultValue["VelothiUr"],
		labelText = "Velothi-Ur Mythic ("..EPC.Values.Pen.velothiUr..")*",
		anchor = {
			relativeTo = combobox_Weapon
			}
		})
	local checkbox_ShatteredFate = EPC.UI.CreateCheckbutton(
		{
		parent = parentContainer, 
		name = "ShatteredFate", 
		default = EPC.FormFieldDefaultValue["ShatteredFate"],
		labelText = "Shattered Fate ("..EPC.Values.Pen.shatteredFate..")*",
		anchor = {
			relativeTo = checkbox_VelothiUr
			}
		})
	return checkbox_ShatteredFate
end

function EPC.UI.PEN.InitSummary()
	EPC.GUI.Summary.Needed = EPC.UI.CreateSummaryLine(
		{
		parent = EPC.GUI.SummaryContainer,
		name = "Needed",
		labelText = "Pen needed*",
		labelNumber = EPC.Values.Pen.required,
		numberColor = EPC.GUI.Color.red,
		tooltipText = "The penetration required for trial and dungeon. This guarantees the maximum damage you can deal.\n\nFor overland content this is actually half ("..EPC.Values.Pen.requiredOverland.." penetration).",
		anchor = {
			relativeTo = EPC.GUI.SummaryContainer, 
			relativePoint = TOPLEFT,
			offsetY = 25, 
			offsetX = 5
			}
		})
	EPC.GUI.Summary.Debuff = EPC.UI.CreateSummaryLine(
		{
		parent = EPC.GUI.SummaryContainer, 
		name = "FromDebuff", 
		labelText = "Debuffs", 
		numberColor = EPC.GUI.Color.green,
		anchor = {
			relativeTo = EPC.GUI.Summary.Needed
			}
		})
	EPC.GUI.Summary.Passive = EPC.UI.CreateSummaryLine(
		{
		parent = EPC.GUI.SummaryContainer, 
		name = "FromPassive", 
		labelText = "Passives", 
		numberColor = EPC.GUI.Color.green,
		anchor = {
			relativeTo = EPC.GUI.Summary.Debuff
			}
		})
	EPC.GUI.Summary.Group = EPC.UI.CreateSummaryLine(
		{
		parent = EPC.GUI.SummaryContainer, 
		name = "FromGroup", 
		labelText = "Group gear", 
		numberColor = EPC.GUI.Color.green,
		anchor = {
			relativeTo = EPC.GUI.Summary.Passive
			}
		})
	EPC.GUI.Summary.Player = EPC.UI.CreateSummaryLine(
		{
		parent = EPC.GUI.SummaryContainer, 
		name = "FromPlayer", 
		labelText = "Player's gear", 
		numberColor = EPC.GUI.Color.green,
		anchor = {
			relativeTo = EPC.GUI.Summary.Group
			}
		})
	local summary_Divider = EPC.UI.CreateSummaryDivider(
		EPC.GUI.Summary.Player
		)
	EPC.GUI.Summary.PenLeft = EPC.UI.CreateSummaryLine(
		{
		parent = EPC.GUI.SummaryContainer, 
		name = "PenLeft", 
		labelText = "Needed for cap*",
		tooltipText = "The penetration you still need to reach the cap. A negative number means you are over the cap.",
		anchor = {
			relativeTo = summary_Divider,
			offsetX = 40
			}
		})
	EPC.GUI.Summary.DmgLoss = EPC.UI.CreateSummaryLine(
		{
		parent = EPC.GUI.SummaryContainer, 
		name = "DmgLoss", 
		labelText = "% dmg loss*", 
		tooltipText = "The damage loss you have when you lack this amount of damage.\nThis is the % you need to subtract from the damage you see in the tooltip of a skill.\n\nFor example 10.000 damage in the tooltip, and 25% damage loss means the skills does 7.500 damage (2.500 damage less).",
		anchor = {
			relativeTo = EPC.GUI.Summary.PenLeft
			}
		})
	local summary_Divider2 = EPC.UI.CreateSummaryDivider(
		EPC.GUI.Summary.DmgLoss
		)
	EPC.GUI.Summary.DmgGain = EPC.UI.CreateSummaryLine(
		{
		parent = EPC.GUI.SummaryContainer, 
		name = "DmgGain", 
		labelText = "% dmg gain at cap*", 
		tooltipText = "The reverse calculation of damage loss.\nThis displayes the damage you gain if you would increase your penetration to the cap.\n\nFor example you can gain 25% at cap and you skill does 8.000 damage (not the damage in the tooltip), it would do 10.000 damage if you reach the cap.",
		anchor = {
			relativeTo = summary_Divider2,
			offsetX = 40
			}
		})
end