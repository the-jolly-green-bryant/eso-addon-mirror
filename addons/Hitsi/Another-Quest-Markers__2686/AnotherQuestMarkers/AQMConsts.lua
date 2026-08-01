AQM = {
  Name = "Another Quest Markers",
  Version = "1.0",
  appName = "AnotherQuestMarkers",
}
AQM.PATH= {
	eso = "esoui/art/",
	ui = "AnotherQuestMarkers/",
	textures = "textures/",
}

AQM.textures = {
	quest_textures = {
		"quest_icon.dds",
		"quest_icon_door.dds",
	},
	quest_new_textures = {
		"quest_available_icon.dds",
	},
	quest_assisted_textures = {
		"quest_icon_assisted.dds",
		"quest_icon_door_assisted.dds",
	},
	repeatable_textures = {
		"repeatablequest_icon.dds",
		"repeatablequest_icon_door.dds",
	},
	repeatable_new_textures = {
		"repeatablequest_available_icon.dds",
	},
	repeatable_assisted_textures = {
		"repeatablequest_icon_assisted.dds",
		"repeatablequest_icon_door_assisted.dds",
	},
	story_textures = {
		"zonestoryquest_icon.dds",
		"zonestoryquest_icon_door.dds",
	},
	story_new_textures = {
		"zonestoryquest_available_icon.dds",
		"zonestoryquest_available_icon_door.dds",
	},
	story_assisted_textures = {
		"zonestoryquest_icon_assisted.dds",
		"zonestoryquest_icon_door_assisted.dds",
	},
	compass_quest_textures = {
		"quest_areapin.dds",
	},
	compass_quest_new_textures = {
		"quest_available_icon.dds",
	},
	compass_quest_assisted_textures = {
		"quest_assistedareapin.dds",
	},
	compass_repeatable_textures = {
		"repeatablequest_areapin.dds",
	},
	compass_repeatable_new_textures = {
		"repeatablequest_available_icon.dds",
	},
	compass_repeatable_assisted_textures = {
		"repeatablequest_assistedareapin.dds",
	},
	compass_story_textures = {
		"zonestoryquest_areapin.dds",
	},
	compass_story_new_textures = {
		"zonestoryquest_available_icon_areapin.dds",
	},
	compass_story_assisted_textures = {
		"zonestoryquest_assistedareapin.dds",
	},
}

AQM.samples = {
	story = "zonestoryquest_icon.dds",
	story_new = "zonestoryquest_available_icon.dds",
	story_assisted = "zonestoryquest_icon_assisted.dds",
	quest = "quest_icon.dds",
	quest_new = "quest_available_icon.dds",
	quest_assisted = "quest_icon_assisted.dds",
	repeatable = "repeatablequest_icon.dds",
	repeatable_new = "repeatablequest_available_icon.dds",
	repeatable_assisted = "repeatablequest_icon_assisted.dds",
}

AQM.menuitems = {
	"story",
	"story_new",
	"story_assisted",
	"quest",
	"quest_new",
	"quest_assisted",
	"repeatable",
	"repeatable_new",
	"repeatable_assisted",
}

local lpath=AQM.PATH.ui..AQM.PATH.textures
AQM.themes = {
	vanilla = {
		textures_full = lpath.."vanilla/",
	},
	aqua = {
		textures_full = lpath.."aqua/",
	},
	blue = {
		textures_full = lpath.."blue/",
	},
	fuchsia = {
		textures_full = lpath.."fuchsia/",
	},
	green = {
		textures_full = lpath.."green/",
	},
	lime = {
		textures_full = lpath.."lime/",
	},
	maroon = {
		textures_full = lpath.."maroon/",
	},
	navy = {
		textures_full = lpath.."navy/",
	},
	olive = {
		textures_full = lpath.."olive/",
	},
	purple = {
		textures_full = lpath.."purple/",
	},
	red = {
		textures_full = lpath.."red/",
	},
	teal = {
		textures_full = lpath.."teal/",
	},
	yellow = {
		textures_full = lpath.."yellow/",
	},
	old_school = {
		textures_full = lpath.."old_school/",
	},
}

AQM.defaults = {
    quest_marker_size = 32,
	quest_theme = "green",
	quest_new_theme = "vanilla",
	quest_assisted_theme = "lime",
	repeatable_theme = "blue",
	repeatable_new_theme = "teal",
	repeatable_assisted_theme = "aqua",
	story_theme = "maroon",
	story_new_theme = "red",
	story_assisted_theme = "fuchsia",
    show_on_compass = true,
}

AQM.const = {
	MinMSize = 16,
	MaxMSize = 96,
	StepMSize = 1,
	IconCol = 4,
	IconRow = 4,
	IconSize = 32,
}