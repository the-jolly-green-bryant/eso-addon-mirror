local AQM = AQM

local function RedirectTextures(old_folder, new_folder, textures_table)
	local paths=AQM.PATH
    local old_textures_folder = paths.eso .. old_folder
    local new_textures_folder = new_folder
    for i = 1, #textures_table do
        RedirectTexture(old_textures_folder .. textures_table[i], new_textures_folder .. textures_table[i])
    end
end

local function getTooltip(str)
	local Lng = AQM.i18n
	local result=""
	
	if (Lng.themes[str]) then
		return Lng.themes[str]
	end
	
	str=string.gsub(str, "_", " ")
	for word in string.gmatch(str, "%a+") do 
		word=word:gsub("^%l", string.upper)
		result=result..word.." "
	end
	result = result:sub(1, -2)
    return result
end

function AQM.getPathFromTheme(str)
	local themes=AQM.themes
	if (themes[str] and themes[str].textures_full) then
		return themes[str].textures_full
	end
	return AQM.getPathFromTheme("vanilla")
end

function AQM.OnAddOnLoaded(eventCode, addOnName)
    if addOnName ~= AQM.appName then
        return
    end
	local paths=AQM.PATH
	local textures_table=AQM.textures
	local themes=AQM.themes
	local icon_themes = {}
	
	for idx,val in pairs(themes) do
		local tooltip=getTooltip(idx)
		local path=val.textures_full
		local theme={theme = idx, tooltip = tooltip}
		table.insert(icon_themes, theme)
	end
    AQM.SV = ZO_SavedVars:NewAccountWide("AnotherQuestMarkers_SavedVariables", AQM.Version, AQM.defaults, nil)
    AQM:CreateOptionsPanel(icon_themes)
    if AQM.SV.show_on_compass then
		local SV=AQM.SV
		local tables_name=AQM.samples
		for idx,val in pairs(tables_name) do
			local theme=idx.."_theme"
			local textures_name=idx.."_textures"
			local compass_textures="compass_"..idx.."_textures"
			local theme=SV[theme]
			local theme_path=AQM.getPathFromTheme(theme)
			RedirectTextures("floatingmarkers/", theme_path, textures_table[textures_name])
			RedirectTextures("compass/", theme_path, textures_table[textures_name])
			RedirectTextures("compass/", theme_path, textures_table[compass_textures])
		end
    end
end

function AQM.OnPlayerActivated()
	local SV=AQM.SV
	local menuitems=AQM.menuitems
	local paths={}
	for i = 1, #menuitems do
		local menuitem=menuitems[i]
		local varname=menuitems[i].."_theme"
		local theme=SV[varname]
		local path=AQM.getPathFromTheme(theme)
		paths[menuitem]=path
	end
	-- assisted --
    SetFloatingMarkerInfo(MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION, SV.quest_marker_size, paths["quest_assisted"] .. "/quest_icon_assisted.dds", paths["quest_assisted"] .. "/quest_icon_door_assisted.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION, SV.quest_marker_size, paths["quest_assisted"] .. "/quest_icon_assisted.dds", paths["quest_assisted"] .. "/quest_icon_door_assisted.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_ASSISTED_QUEST_ENDING, SV.quest_marker_size, paths["quest_assisted"] .. "/quest_icon_assisted.dds", paths["quest_assisted"] .. "/quest_icon_door_assisted.dds")
	-- story --
	SetFloatingMarkerInfo(MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_CONDITION, SV.quest_marker_size, paths["story_assisted"] .. "/zoneStoryQuest_icon_assisted.dds", paths["story_assisted"] .. "/zoneStoryQuest_icon_door_assisted.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_OPTIONAL_CONDITION, SV.quest_marker_size, paths["story_assisted"] .. "/zoneStoryQuest_icon_assisted.dds", paths["story_assisted"] .. "/zoneStoryQuest_icon_door_assisted.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_ENDING, SV.quest_marker_size, paths["story_assisted"] .. "/zoneStoryQuest_icon_assisted.dds", paths["story_assisted"] .. "/zoneStoryQuest_icon_door_assisted.dds")
	
	-- repeat assisted --
    SetFloatingMarkerInfo(MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_CONDITION, SV.quest_marker_size, paths["repeatable_assisted"] .. "/repeatableQuest_icon_assisted.dds", paths["repeatable_assisted"] .. "/repeatableQuest_icon_door_assisted.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_OPTIONAL_CONDITION, SV.quest_marker_size, paths["repeatable_assisted"] .. "/repeatableQuest_icon_assisted.dds", paths["repeatable_assisted"] .. "/repeatableQuest_icon_door_assisted.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_ENDING, SV.quest_marker_size, paths["repeatable_assisted"] .. "/repeatableQuest_icon_assisted.dds", paths["repeatable_assisted"] .. "/repeatableQuest_icon_door_assisted.dds")
	
	-- tracked quest --
    SetFloatingMarkerInfo(MAP_PIN_TYPE_TRACKED_QUEST_CONDITION, SV.quest_marker_size, paths["quest"] .. "/quest_icon.dds", paths["quest"] .. "/quest_icon_door.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_TRACKED_QUEST_OPTIONAL_CONDITION, SV.quest_marker_size, paths["quest"] .. "/quest_icon.dds", paths["quest"] .. "/quest_icon_door.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_TRACKED_QUEST_ENDING, SV.quest_marker_size, paths["quest"] .. "/quest_icon.dds", paths["quest"] .. "/quest_icon_door.dds")
	
	-- story --
	SetFloatingMarkerInfo(MAP_PIN_TYPE_TRACKED_QUEST_ZONE_STORY_CONDITION, SV.quest_marker_size, paths["story"] .. "/zoneStoryQuest_icon.dds", paths["story"] .. "/zoneStoryQuest_icon_door.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_TRACKED_QUEST_ZONE_STORY_OPTIONAL_CONDITION, SV.quest_marker_size, paths["story"] .. "/zoneStoryQuest_icon.dds", paths["story"] .. "/zoneStoryQuest_icon_door.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_TRACKED_QUEST_ZONE_STORY_ENDING, SV.quest_marker_size, paths["story"] .. "/zoneStoryQuest_icon.dds", paths["story"] .. "/zoneStoryQuest_icon_door.dds")
	
	-- repeatable tracked quest --
    SetFloatingMarkerInfo(MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_CONDITION, SV.quest_marker_size, paths["repeatable"] .. "/repeatableQuest_icon.dds", paths["repeatable"] .. "/repeatableQuest_icon_door.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_OPTIONAL_CONDITION, SV.quest_marker_size, paths["repeatable"] .. "/repeatableQuest_icon.dds", paths["repeatable"] .. "/repeatableQuest_icon_door.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_ENDING, SV.quest_marker_size, paths["repeatable"] .. "/repeatableQuest_icon.dds", paths["repeatable"] .. "/repeatableQuest_icon_door.dds")

	-- quest --
    SetFloatingMarkerInfo(MAP_PIN_TYPE_QUEST_CONDITION, SV.quest_marker_size, paths["quest"] .. "/quest_icon.dds", paths["quest"] .. "/quest_icon_door.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_QUEST_OPTIONAL_CONDITION, SV.quest_marker_size, paths["quest"] .. "/quest_icon.dds", paths["quest"] .. "/quest_icon_door.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_QUEST_ENDING, SV.quest_marker_size, paths["quest"] .. "/quest_icon.dds", paths["quest"] .. "/quest_icon_door.dds")
	
	-- story --
    SetFloatingMarkerInfo(MAP_PIN_TYPE_QUEST_ZONE_STORY_CONDITION, SV.quest_marker_size, paths["story"] .. "/zoneStoryQuest_icon.dds", paths["story"] .. "/zoneStoryQuest_icon_door.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_QUEST_ZONE_STORY_OPTIONAL_CONDITION, SV.quest_marker_size, paths["story"] .. "/zoneStoryQuest_icon.dds", paths["story"] .. "/zoneStoryQuest_icon_door.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_QUEST_ZONE_STORY_ENDING, SV.quest_marker_size, paths["story"] .. "/zoneStoryQuest_icon.dds", paths["story"] .. "/zoneStoryQuest_icon_door.dds")
	
	-- repeatable tracked quest --
	SetFloatingMarkerInfo(MAP_PIN_TYPE_QUEST_REPEATABLE_CONDITION, SV.quest_marker_size, paths["repeatable"] .. "/repeatableQuest_icon.dds", paths["repeatable"] .. "/repeatableQuest_icon_door.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_QUEST_REPEATABLE_OPTIONAL_CONDITION, SV.quest_marker_size, paths["repeatable"] .. "/repeatableQuest_icon.dds", paths["repeatable"] .. "/repeatableQuest_icon_door.dds")
    SetFloatingMarkerInfo(MAP_PIN_TYPE_QUEST_REPEATABLE_ENDING, SV.quest_marker_size, paths["repeatable"] .. "/repeatableQuest_icon.dds", paths["repeatable"] .. "/repeatableQuest_icon_door.dds")

    SetFloatingMarkerInfo(MAP_PIN_TYPE_TRACKED_QUEST_OFFER_ZONE_STORY, SV.quest_marker_size, paths["quest"] .. "/zoneStoryQuest_available_icon.dds", paths["quest"] .. "/zoneStoryQuest_available_icon_door.dds", PULSES)

    -- SetFloatingMarkerInfo(MAP_PIN_TYPE_TIMELY_ESCAPE_NPC, SV.quest_marker_size, paths["quest_new"] .. "/timely_escape_npc.dds", paths["quest_new"] .. "/timely_escape_npc.dds")
    -- SetFloatingMarkerInfo(MAP_PIN_TYPE_DARK_BROTHERHOOD_TARGET, SV.quest_marker_size, paths["quest_new"] .. "/darkbrotherhood_target.dds", paths["quest_new"] .. "/darkbrotherhood_target.dds")

    local PULSES = true
    SetFloatingMarkerInfo(MAP_PIN_TYPE_QUEST_OFFER, SV.quest_marker_size, paths["quest_new"] .. "/quest_available_icon.dds", "", PULSES)
    SetFloatingMarkerInfo(MAP_PIN_TYPE_QUEST_OFFER_REPEATABLE, SV.quest_marker_size, paths["repeatable_new"] .. "/repeatableQuest_available_icon.dds", "", PULSES)
    SetFloatingMarkerInfo(MAP_PIN_TYPE_QUEST_OFFER_ZONE_STORY, SV.quest_marker_size, paths["story_new"] .. "/zoneStoryQuest_available_icon.dds", "", PULSES)
end

EVENT_MANAGER:RegisterForEvent(AQM.appName, EVENT_ADD_ON_LOADED, AQM.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(AQM.appName, EVENT_PLAYER_ACTIVATED, AQM.OnPlayerActivated)
