
PinKiller = PinKiller or {}
local strings = {}

--[[
######################################################
--]]
strings.QUEST_HEADER = "Quest Pin Options"
strings.REPEATABLE_QUEST_HEADER = "Repeatable Quest Pin Options"
strings.ZONE_STORY_QUEST_HEADER = "Zone Story Quest Pin Options"

strings.COMPASS_HEADER = "Compass Pin Options"
strings.COMPASS_CHECKBOX_TOOLTIP = "Select to display \"<<1>>\" pins on the compass."
strings.AREA_ANIMATION = "Area Animation"
strings.AREA_ANIMATION_TOOLTIP = "Select to display quest areas on the compass, when you enter them."

strings.MAP_HEADER = "Map Pin Options"
strings.QUEST_PINS = "Quest Pins"
strings.QUEST_PINS_TOOLTIP = "Select to display Quest Pins on the worldmap."

strings.FLOATING_MARKER_HEADER = "Floating Pin Options"
strings.FLOATING_MARKER_CHECKBOX_TOOLTIP = "Select to display \"<<1>>\" floating pins in the world."
strings.FLOATING_MARKER_BREADCRUMB_CHECKBOX_TOOLTIP = "Select to display \"<<1>>\" floating breadcrumb pins in the world. (For example when the target is behind a door.)"

strings.PIN_TYPE_NAMES = {
	[MAP_PIN_TYPE_POI_SEEN] = "Point Of Interest",
	[MAP_PIN_TYPE_POI_COMPLETE] = "Completed Point Of Interest",
	[MAP_PIN_TYPE_TIMELY_ESCAPE_NPC] = "Timely Escape (TG passive)",
	
	[MAP_PIN_TYPE_QUEST_OFFER] = "Quest Offer",
	[MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION] = "Tracked Quest Condition",
	[MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION] = "Tracked Quest Optional Condition",
	[MAP_PIN_TYPE_ASSISTED_QUEST_ENDING] = "Tracked Quest Ending",
	[MAP_PIN_TYPE_QUEST_CONDITION] = "Secondary Quest Condition",
	[MAP_PIN_TYPE_QUEST_OPTIONAL_CONDITION] = "Secondary Quest Optional Condition",
	[MAP_PIN_TYPE_QUEST_ENDING] = "Secondary Quest Ending",
	
	[MAP_PIN_TYPE_QUEST_OFFER_REPEATABLE] = "Quest Offer",
	[MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_CONDITION] = "Tracked Quest Condition",
	[MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_OPTIONAL_CONDITION] = "Tracked Quest Optional Condition",
	[MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_ENDING] = "Tracked Quest Ending",
	[MAP_PIN_TYPE_QUEST_REPEATABLE_CONDITION] = "Secondary Quest Condition",
	[MAP_PIN_TYPE_QUEST_REPEATABLE_OPTIONAL_CONDITION] = "Secondary Quest Optional Condition",
	[MAP_PIN_TYPE_QUEST_REPEATABLE_ENDING] = "Secondary Quest Ending",
	
	[MAP_PIN_TYPE_QUEST_OFFER_ZONE_STORY] = "Quest Offer",
	[MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_CONDITION] = "Tracked Quest Condition",
	[MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_OPTIONAL_CONDITION] = "Tracked Quest Optional Condition",
	[MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_ENDING] = "Tracked Quest Ending",
	[MAP_PIN_TYPE_QUEST_ZONE_STORY_CONDITION] = "Secondary Quest Condition",
	[MAP_PIN_TYPE_QUEST_ZONE_STORY_OPTIONAL_CONDITION] = "Secondary Quest Optional Condition",
	[MAP_PIN_TYPE_QUEST_ZONE_STORY_ENDING] = "Secondary Quest Ending",
}

strings.FLOATING_NORMAL = "Normal floating pins:"
strings.FLOATING_BREADCRUMB = "Breadcrumb floating pins (e.g. behind doors):"

--[[
######################################################
--]]
PinKiller.strings = PinKiller.strings or {}
ZO_DeepTableCopy(strings, PinKiller.strings)
