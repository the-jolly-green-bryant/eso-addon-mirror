
PinKiller = PinKiller or {}

PinKiller.floatingMarkerInfoArguments = {
	
	[MAP_PIN_TYPE_QUEST_OFFER] = {32, "EsoUI/Art/FloatingMarkers/quest_available_icon.dds", "", true},
	[MAP_PIN_TYPE_QUEST_OFFER_REPEATABLE] = {32, "EsoUI/Art/FloatingMarkers/repeatableQuest_available_icon.dds", "", true},
	[MAP_PIN_TYPE_QUEST_OFFER_ZONE_STORY] = {32, "EsoUI/Art/FloatingMarkers/zoneStoryQuest_available_icon.dds", "", true},
	
	-- parent pin types
	[MAP_PIN_TYPE_QUEST_CONDITION] = {32, "EsoUI/Art/FloatingMarkers/quest_icon.dds", "EsoUI/Art/FloatingMarkers/quest_icon_door.dds"},
    [MAP_PIN_TYPE_QUEST_OPTIONAL_CONDITION] = {32, "EsoUI/Art/FloatingMarkers/quest_icon.dds", "EsoUI/Art/FloatingMarkers/quest_icon_door.dds"},
    [MAP_PIN_TYPE_QUEST_ENDING] = {32, "EsoUI/Art/FloatingMarkers/quest_icon.dds", "EsoUI/Art/FloatingMarkers/quest_icon_door.dds"},
    [MAP_PIN_TYPE_QUEST_REPEATABLE_CONDITION] = {32, "EsoUI/Art/FloatingMarkers/repeatableQuest_icon.dds", "EsoUI/Art/FloatingMarkers/repeatableQuest_icon_door.dds"},
    [MAP_PIN_TYPE_QUEST_REPEATABLE_OPTIONAL_CONDITION] = {32, "EsoUI/Art/FloatingMarkers/repeatableQuest_icon.dds", "EsoUI/Art/FloatingMarkers/repeatableQuest_icon_door.dds"},
    [MAP_PIN_TYPE_QUEST_REPEATABLE_ENDING] = {32, "EsoUI/Art/FloatingMarkers/repeatableQuest_icon.dds", "EsoUI/Art/FloatingMarkers/repeatableQuest_icon_door.dds"},
	[MAP_PIN_TYPE_QUEST_ZONE_STORY_CONDITION] = {32, "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon.dds", "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon_door.dds"},
	[MAP_PIN_TYPE_QUEST_ZONE_STORY_OPTIONAL_CONDITION] = {32, "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon.dds", "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon_door.dds"},
	[MAP_PIN_TYPE_QUEST_ZONE_STORY_ENDING] = {32, "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon.dds", "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon_door.dds"},
	
	-- assisted quest pins (white icons)
	[MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION] = {32, "EsoUI/Art/FloatingMarkers/quest_icon_assisted.dds", "EsoUI/Art/FloatingMarkers/quest_icon_door_assisted.dds"},
	[MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION] = {32, "EsoUI/Art/FloatingMarkers/quest_icon_assisted.dds", "EsoUI/Art/FloatingMarkers/quest_icon_door_assisted.dds"},
	[MAP_PIN_TYPE_ASSISTED_QUEST_ENDING] = {32, "EsoUI/Art/FloatingMarkers/quest_icon_assisted.dds", "EsoUI/Art/FloatingMarkers/quest_icon_door_assisted.dds"},
	
	[MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_CONDITION] = {32, "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon_assisted.dds", "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon_door_assisted.dds"},
	[MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_OPTIONAL_CONDITION] = {32, "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon_assisted.dds", "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon_door_assisted.dds"},
	[MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_ENDING] = {32, "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon_assisted.dds", "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon_door_assisted.dds"},
	
	[MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_CONDITION] = {32, "EsoUI/Art/FloatingMarkers/repeatableQuest_icon_assisted.dds", "EsoUI/Art/FloatingMarkers/repeatableQuest_icon_door_assisted.dds"},
	[MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_OPTIONAL_CONDITION] = {32, "EsoUI/Art/FloatingMarkers/repeatableQuest_icon_assisted.dds", "EsoUI/Art/FloatingMarkers/repeatableQuest_icon_door_assisted.dds"},
	[MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_ENDING] = {32, "EsoUI/Art/FloatingMarkers/repeatableQuest_icon_assisted.dds", "EsoUI/Art/FloatingMarkers/repeatableQuest_icon_door_assisted.dds"},
	
	-- unassisted quest pins (black icons)
	[MAP_PIN_TYPE_TRACKED_QUEST_CONDITION] = {32, "EsoUI/Art/FloatingMarkers/quest_icon.dds", "EsoUI/Art/FloatingMarkers/quest_icon_door.dds"},
	[MAP_PIN_TYPE_TRACKED_QUEST_OPTIONAL_CONDITION] = {32, "EsoUI/Art/FloatingMarkers/quest_icon.dds", "EsoUI/Art/FloatingMarkers/quest_icon_door.dds"},
	[MAP_PIN_TYPE_TRACKED_QUEST_ENDING] = {32, "EsoUI/Art/FloatingMarkers/quest_icon.dds", "EsoUI/Art/FloatingMarkers/quest_icon_door.dds"},
	
	[MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_CONDITION] = {32, "EsoUI/Art/FloatingMarkers/repeatableQuest_icon.dds", "EsoUI/Art/FloatingMarkers/repeatableQuest_icon_door.dds"},
	[MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_OPTIONAL_CONDITION] = {32, "EsoUI/Art/FloatingMarkers/repeatableQuest_icon.dds", "EsoUI/Art/FloatingMarkers/repeatableQuest_icon_door.dds"},
	[MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_ENDING] = {32, "EsoUI/Art/FloatingMarkers/repeatableQuest_icon.dds", "EsoUI/Art/FloatingMarkers/repeatableQuest_icon_door.dds"},
	
	[MAP_PIN_TYPE_TRACKED_QUEST_ZONE_STORY_CONDITION] = {32, "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon.dds", "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon_door.dds"},
	[MAP_PIN_TYPE_TRACKED_QUEST_ZONE_STORY_OPTIONAL_CONDITION] = {32, "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon.dds", "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon_door.dds"},
	[MAP_PIN_TYPE_TRACKED_QUEST_ZONE_STORY_ENDING] = {32, "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon.dds", "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon_door.dds"},
	
	-- special types
	[MAP_PIN_TYPE_TIMELY_ESCAPE_NPC] = {32, "EsoUI/Art/FloatingMarkers/timely_escape_npc.dds", "EsoUI/Art/FloatingMarkers/timely_escape_npc.dds"},
	[MAP_PIN_TYPE_DARK_BROTHERHOOD_TARGET] = {32, "EsoUI/Art/FloatingMarkers/darkbrotherhood_target.dds", "EsoUI/Art/FloatingMarkers/darkbrotherhood_target.dds"},
}

local originalSetFloatingMarkerInfo = SetFloatingMarkerInfo
function SetFloatingMarkerInfo(pinType, size, texture, breadCrumpTexture, ...)
	if PinKiller.floatingMarkerInfoArguments[pinType] then
		PinKiller.floatingMarkerInfoArguments[pinType] = {size, texture, breadCrumpTexture, ...}
		if not PinKiller:IsFloatingMarkerEnabled(pinType) then
			texture = "PinKiller/empty.dds" -- "" or nil makes the breadcrumb invisible too, "nonexisting.dds" is a white square, "blank.dds" 0 byte file is a black square.
		end
		if not PinKiller:IsFloatingMarkerBreadcrumbEnabled(pinType) then
			breadCrumpTexture = ""
		end
	end
	return originalSetFloatingMarkerInfo(pinType, size, texture, breadCrumpTexture, ...)
end

function PinKiller:RefreshFloatingMarkerInfo(pinType)
	local arguments = self.floatingMarkerInfoArguments[pinType]
	assert(arguments, "Pin Type " .. tostring(pinType) .. " is unkown.")
	SetFloatingMarkerInfo(pinType, unpack(arguments))
end



