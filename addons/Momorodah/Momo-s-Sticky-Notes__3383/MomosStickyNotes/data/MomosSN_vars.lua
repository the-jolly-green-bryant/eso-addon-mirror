-- Author: Momorodah

MomosSN.anchors = {"Bottom", "bottom left", "Bottom right", "Center", "Left", "None", "Right", "Top", "Top left", "Top right",}
MomosSN.fontAlignments = {"Bottom", "Center", "Left", "Right", "Top",}
MomosSN.fonts = {"Antique", "Handwritten", "Stone Tablet",}
MomosSN.defaultBackgroundName = "Note"
MomosSN.defaultIconName = "Khajiit"
MomosSN.shownFontColour = "FFFFFF"
MomosSN.hiddenFontColour = "888888"
MomosSN.controlListLabelHeight = 20
MomosSN.icons = {
	None = {name = "None", filePath = "",},
	Altmer = {name = "Altmer", filePath = "esoui/art/charactercreate/charactercreate_altmericon_up.dds",},
	Argonian = {name = "Argonian", filePath = "esoui/art/charactercreate/charactercreate_argonianicon_up.dds",},
	Bosmer = {name = "Bosmer", filePath = "esoui/art/charactercreate/charactercreate_bosmericon_up.dds",},
	Breton = {name = "Breton", filePath = "esoui/art/charactercreate/charactercreate_bretonicon_up.dds",},
	Dunmer = {name = "Dunmer", filePath = "esoui/art/charactercreate/charactercreate_dunmericon_up.dds",},
	Imperial = {name = "Imperial", filePath = "esoui/art/charactercreate/charactercreate_imperialicon_up.dds",},
	Khajiit = {name = "Khajiit", filePath = "esoui/art/charactercreate/charactercreate_khajiiticon_up.dds",},
	Nord = {name = "Nord", filePath = "esoui/art/charactercreate/charactercreate_nordicon_up.dds",},
	Orc = {name = "Orc", filePath = "esoui/art/charactercreate/charactercreate_orcicon_up.dds",},
	Redguard = {name = "Redguard", filePath = "esoui/art/charactercreate/charactercreate_redguardicon_up.dds",},
	Aldmeri = {name = "Aldmeri", filePath = "esoui/art/charactercreate/charactercreate_aldmeriicon_up.dds",},
	Daggerfall = {name = "Daggerfall", filePath = "esoui/art/charactercreate/charactercreate_daggerfallicon_up.dds",},
	Ebonheart = {name = "Ebonheart", filePath = "esoui/art/charactercreate/charactercreate_ebonhearticon_up.dds",},
	Dragonguard = {name = "Dragonguard", filePath = "esoui/art/charactercreate/charactercreate_dragonguardicon_up.dds",},
	Nightblade = {name = "Nightblade", filePath = "esoui/art/charactercreate/charactercreate_nightbladeicon_up.dds",},
	Sorcerer = {name = "Sorcerer", filePath = "esoui/art/charactercreate/charactercreate_sorceroricon_up.dds",},
	Templar = {name = "Templar", filePath = "esoui/art/charactercreate/charactercreate_templaricon_up.dds",},
	Warden = {name = "Warden", filePath = "esoui/art/charactercreate/charactercreate_wardenicon_up.dds",},
	Necromancer = {name = "Necromancer", filePath = "esoui/art/charactercreate/charactercreate_necromancericon_up.dds",},
}
MomosSN.iconScales = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12,}
MomosSN.backgrounds = {
	Letter = {name = "Letter", filePath = "esoui/art/lorelibrary/lorelibrary_letter.dds", properWidth = 580, properHeight = 840,},
	Scroll = {name = "Scroll", filePath = "esoui/art/lorelibrary/lorelibrary_scroll.dds", properWidth = 500, properHeight = 740,},
	Note = {name = "Note", filePath = "esoui/art/lorelibrary/lorelibrary_note.dds", properWidth = 600, properHeight = 840,},
}

MomosSN.defaultSN = {
	name = "Momo's Sticky Note",
	identifier = "id:0",
	width = 250,
	height = 250,
	x = 400,
	y = 400,
	text = "Plans for today:\n- Sleep\n- Eat\n-Sleep some more\n- Stinky poop\n- Sharpen claws\n- More sleep",
	centerColor = {1, 1, 1, 1,},
	edgeColor = {0, 0, 0, 1,},
	headerFontName = "Antique",
	headerFontSize = 20,
	headerFontAlignment = "Center",
	headerFontColor = {0, 0, 0, 1,},
	contentFontName = "Handwritten",
	contentFontSize = 16,
	contentFontAlign = "Top left",
	contentFontColor = {0, 0, 0, 1,},
	backgroundName = MomosSN.defaultBackgroundName,
	backgroundEnabled = true,
	iconName = MomosSN.defaultIconName,
	iconAnchor = "Bottom right",
	iconOffsetX = -5,
	iconOffsetY = -5,
	iconScale = 6,
	iconColorEnabled = true,
	iconColor = {1, 0, 0, 1,},
	hidden = false,
}
MomosSN.defaultVariables = {
	defaultBgColor = {1, 1, 1, 1,},
	defaultWidth = 250,
	defaultHeight = 250,
	defaultX = 0,
	defaultY = 0,
	hideInCombat = true,
	SNIndex = 0,
	stickyNotes = {},
	controlListWidth = 225,
	controlListHeight = 300,
	controlListX = 400,
	controlListY = 400,
}
