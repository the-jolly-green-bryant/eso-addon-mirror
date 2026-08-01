
PinKiller = PinKiller or {}

PinKiller.floatingMarkerInfoArguments = {
	
	[MAP_PIN_TYPE_QUEST_OFFER] = {"EsoUI/Art/FloatingMarkers/quest_available_icon.dds", "", true},
	[MAP_PIN_TYPE_QUEST_OFFER_REPEATABLE] = {"EsoUI/Art/FloatingMarkers/repeatableQuest_available_icon.dds", "", true},
	[MAP_PIN_TYPE_QUEST_OFFER_ZONE_STORY] = {"EsoUI/Art/FloatingMarkers/zoneStoryQuest_available_icon.dds", "", true},
	
	-- parent pin types
	[MAP_PIN_TYPE_QUEST_CONDITION] = {"EsoUI/Art/FloatingMarkers/quest_icon.dds", "EsoUI/Art/FloatingMarkers/quest_icon_door.dds"},
    [MAP_PIN_TYPE_QUEST_OPTIONAL_CONDITION] = {"EsoUI/Art/FloatingMarkers/quest_icon.dds", "EsoUI/Art/FloatingMarkers/quest_icon_door.dds"},
    [MAP_PIN_TYPE_QUEST_ENDING] = {"EsoUI/Art/FloatingMarkers/quest_icon.dds", "EsoUI/Art/FloatingMarkers/quest_icon_door.dds"},
    [MAP_PIN_TYPE_QUEST_REPEATABLE_CONDITION] = {"EsoUI/Art/FloatingMarkers/repeatableQuest_icon.dds", "EsoUI/Art/FloatingMarkers/repeatableQuest_icon_door.dds"},
    [MAP_PIN_TYPE_QUEST_REPEATABLE_OPTIONAL_CONDITION] = {"EsoUI/Art/FloatingMarkers/repeatableQuest_icon.dds", "EsoUI/Art/FloatingMarkers/repeatableQuest_icon_door.dds"},
    [MAP_PIN_TYPE_QUEST_REPEATABLE_ENDING] = {"EsoUI/Art/FloatingMarkers/repeatableQuest_icon.dds", "EsoUI/Art/FloatingMarkers/repeatableQuest_icon_door.dds"},
	[MAP_PIN_TYPE_QUEST_ZONE_STORY_CONDITION] = {"EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon.dds", "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon_door.dds"},
	[MAP_PIN_TYPE_QUEST_ZONE_STORY_OPTIONAL_CONDITION] = {"EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon.dds", "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon_door.dds"},
	[MAP_PIN_TYPE_QUEST_ZONE_STORY_ENDING] = {"EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon.dds", "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon_door.dds"},
	
	-- assisted quest pins (white icons)
	[MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION] = {"EsoUI/Art/FloatingMarkers/quest_icon_assisted.dds", "EsoUI/Art/FloatingMarkers/quest_icon_door_assisted.dds"},
	[MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION] = {"EsoUI/Art/FloatingMarkers/quest_icon_assisted.dds", "EsoUI/Art/FloatingMarkers/quest_icon_door_assisted.dds"},
	[MAP_PIN_TYPE_ASSISTED_QUEST_ENDING] = {"EsoUI/Art/FloatingMarkers/quest_icon_assisted.dds", "EsoUI/Art/FloatingMarkers/quest_icon_door_assisted.dds"},
	
	[MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_CONDITION] = {"EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon_assisted.dds", "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon_door_assisted.dds"},
	[MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_OPTIONAL_CONDITION] = {"EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon_assisted.dds", "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon_door_assisted.dds"},
	[MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_ENDING] = {"EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon_assisted.dds", "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon_door_assisted.dds"},
	
	[MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_CONDITION] = {"EsoUI/Art/FloatingMarkers/repeatableQuest_icon_assisted.dds", "EsoUI/Art/FloatingMarkers/repeatableQuest_icon_door_assisted.dds"},
	[MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_OPTIONAL_CONDITION] = {"EsoUI/Art/FloatingMarkers/repeatableQuest_icon_assisted.dds", "EsoUI/Art/FloatingMarkers/repeatableQuest_icon_door_assisted.dds"},
	[MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_ENDING] = {"EsoUI/Art/FloatingMarkers/repeatableQuest_icon_assisted.dds", "EsoUI/Art/FloatingMarkers/repeatableQuest_icon_door_assisted.dds"},
	
	-- unassisted quest pins (black icons)
	[MAP_PIN_TYPE_TRACKED_QUEST_CONDITION] = {"EsoUI/Art/FloatingMarkers/quest_icon.dds", "EsoUI/Art/FloatingMarkers/quest_icon_door.dds"},
	[MAP_PIN_TYPE_TRACKED_QUEST_OPTIONAL_CONDITION] = {"EsoUI/Art/FloatingMarkers/quest_icon.dds", "EsoUI/Art/FloatingMarkers/quest_icon_door.dds"},
	[MAP_PIN_TYPE_TRACKED_QUEST_ENDING] = {"EsoUI/Art/FloatingMarkers/quest_icon.dds", "EsoUI/Art/FloatingMarkers/quest_icon_door.dds"},
	
	[MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_CONDITION] = {"EsoUI/Art/FloatingMarkers/repeatableQuest_icon.dds", "EsoUI/Art/FloatingMarkers/repeatableQuest_icon_door.dds"},
	[MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_OPTIONAL_CONDITION] = {"EsoUI/Art/FloatingMarkers/repeatableQuest_icon.dds", "EsoUI/Art/FloatingMarkers/repeatableQuest_icon_door.dds"},
	[MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_ENDING] = {"EsoUI/Art/FloatingMarkers/repeatableQuest_icon.dds", "EsoUI/Art/FloatingMarkers/repeatableQuest_icon_door.dds"},
	
	[MAP_PIN_TYPE_TRACKED_QUEST_ZONE_STORY_CONDITION] = {"EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon.dds", "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon_door.dds"},
	[MAP_PIN_TYPE_TRACKED_QUEST_ZONE_STORY_OPTIONAL_CONDITION] = {"EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon.dds", "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon_door.dds"},
	[MAP_PIN_TYPE_TRACKED_QUEST_ZONE_STORY_ENDING] = {"EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon.dds", "EsoUI/Art/FloatingMarkers/zoneStoryQuest_icon_door.dds"},
	
	-- special types
	[MAP_PIN_TYPE_TIMELY_ESCAPE_NPC] = {"EsoUI/Art/FloatingMarkers/timely_escape_npc.dds", "EsoUI/Art/FloatingMarkers/timely_escape_npc.dds"},
	[MAP_PIN_TYPE_DARK_BROTHERHOOD_TARGET] = {"EsoUI/Art/FloatingMarkers/darkbrotherhood_target.dds", "EsoUI/Art/FloatingMarkers/darkbrotherhood_target.dds"},
}

local originalSetFloatingMarkerInfo = SetFloatingMarkerInfo
function SetFloatingMarkerInfo(pinType, ...)
	if PinKiller.floatingMarkerInfoArguments[pinType] then return end
	originalSetFloatingMarkerInfo(pinType, ...)
end

function PinKiller:RefreshFloatingMarkerInfo(pinType)
	local arguments = self.floatingMarkerInfoArguments[pinType]
	local texture, breadcrumbTexture, isPulsing = unpack(arguments)
	
	local isEnabled = self:IsFloatingMarkerEnabled(pinType)
	if not isEnabled then
		texture = "PinKiller/empty.dds"
	end
	
	local isEnabled = self:IsFloatingMarkerBreadcrumbEnabled(pinType)
	if not isEnabled then
		breadcrumbTexture = "PinKiller/empty.dds"
	end
	
	originalSetFloatingMarkerInfo(pinType, 32, texture, breadcrumbTexture, isPulsing)
end

local function OnPlayerActivated()
	for pinType in pairs(PinKiller.floatingMarkerInfoArguments) do
		PinKiller:RefreshFloatingMarkerInfo(pinType)
	end
end

EVENT_MANAGER:RegisterForEvent("PinKiller-FloatingMarkers", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
EVENT_MANAGER:UnregisterForEvent("ZO_FloatingMarkers", EVENT_PLAYER_ACTIVATED)


