JournalQuestLog = {}

local INDEX_TYPE = 1
local QUEST_CAT_ZONE = 1
local QUEST_CAT_OTHER = 2
local QUEST_CAT_MISC = 3
local JQL_COMPLETION_STATE_COMPLETED = 1
local JQL_COMPLETION_STATE_NOT_COMPLETED = 0
local JQL_MISSABLE_STATE_NOT_MISSABLE = 0
local JQL_MISSABLE_STATE_MISSABLE = 1
local JQL_MISSABLE_STATE_MISSED = 2

JournalQuestLog.name = "JournalQuestLog"
JournalQuestLog.version = "1.4.0"
local completedQuests = {}
local incompleteQuests = {}
local missedQuests = {}
local allQuests = {}

JournalQuestLog.varDefaults = {
	listGrouped = false,
	showMissed = true,
	showRepeatable = true,
	showUnavailable = true,

	typeMain = true,
	typeGuild = true,
	typeCrafting = true,
	typeHoliday = true,
	typeBattleground = true,
	typePrologue = true,
	typePledge = true,
	typeCompanion = true,
	typeTribute = true,
	typeScribing = true,
	typeFavor = true,
	typeTamriel = true,
	
	typeAlliance = false,
	typeDungeon = false,
	typeTrial = false,
}

JournalQuestLog.dirty = false

local LAM = LibAddonMenu2

local disabledTextColor = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS,INTERFACE_TEXT_COLOR_DISABLED))
local failedTextColor = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS,INTERFACE_TEXT_COLOR_FAILED))
local hintTextColor = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS,INTERFACE_TEXT_COLOR_HINT))
local highlightTextColor = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS,INTERFACE_TEXT_COLOR_HIGHLIGHT))
local contrastTextColor = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS,INTERFACE_TEXT_COLOR_SECOND_CONTRAST))
local normalTextColor = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS,INTERFACE_TEXT_COLOR_NORMAL))
local succeededTextColor = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS,INTERFACE_TEXT_COLOR_SUCCEEDED))
local winnerTextColor = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS,INTERFACE_TEXT_COLOR_BATTLEGROUND_WINNER))
local subtleTextColor = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS,INTERFACE_TEXT_COLOR_SUBTLE))

local repeatIcon = "/esoui/art/journal/journal_quest_repeat.dds"
local warningIcon = "/esoui/art/miscellaneous/eso_icon_warning.dds"
local newIcon = "/esoui/art/miscellaneous/new_icon.dds"
local checkIcon = "/esoui/art/cadwell/check.dds"
local bulletIcon = "/esoui/art/journal/journal_quest_selected.dds"
local disabledIcon = "/esoui/art/miscellaneous/locked_disabled.dds"
local forbiddenIcon = "/esoui/art/quest/questjournal_tracker_notsharedstepicon.dds"
local groupIcon = "/esoui/art/journal/journal_quest_group_area.dds"
local soloIcon = "/esoui/art/journal/journal_quest_instance.dds"
local publicIcon = "/esoui/art/journal/journal_quest_dungeon.dds"
local trialIcon = "/esoui/art/journal/journal_quest_trial.dds"
local battleIcon = "/esoui/art/battlegrounds/battlegrounds_scoreicon_capturepoint_neutral.dds"
local gpdelveIcon = "/esoui/art/journal/journal_quest_group_delve.dds"
local dungeonIcon = "/esoui/art/journal/journal_quest_group_instance.dds"
local delveIcon = "/esoui/art/journal/journal_quest_delve.dds"
local houseIcon = "/esoui/art/journal/journal_quest_group_housing.dds"
local storyIcon = "/esoui/art/journal/journal_quest_zonestory.dds"
local companionIcon = "/esoui/art/journal/journal_quest_companion.dds"
local infiniteIcon = "/esoui/art/journal/journal_quest_endlessdungeon.dds"
local adventureIcon = "/esoui/art/journal/journal_quest_adventurezone.dds"

function JournalQuestLog.CreateConfigMenu()
    local panelData = {
        type                = "panel",
        name                = JournalQuestLog.name,
        displayName         = "Journal Quest Log",
        author              = "Enodoc",
        version             = JournalQuestLog.version,
        slashCommand        = nil,
        registerForRefresh  = true,
        registerForDefaults = true,
    }
	local ConfigPanel = LAM:RegisterAddonPanel(panelData.name.."Config", panelData)

	local ConfigData = {
		{
			type = "checkbox",
			name = GetString(SI_JOURNAL_QUEST_LOG_ORDER),
			tooltip = GetString(SI_JOURNAL_QUEST_LOG_ORDER_TOOLTIP),
			getFunc = function() return JournalQuestLog.vars.listGrouped end,
			setFunc = function(newValue) JournalQuestLog.vars.listGrouped = newValue end,
			default = JournalQuestLog.varDefaults.listGrouped,
			requiresReload = true,
		},
		{
			type = "checkbox",
			name = GetString(SI_JOURNAL_QUEST_LOG_SHOW_MISSED),
			tooltip = GetString(SI_JOURNAL_QUEST_LOG_SHOW_MISSED_TOOLTIP),
			getFunc = function() return JournalQuestLog.vars.showMissed end,
			setFunc = function(newValue) JournalQuestLog.vars.showMissed = newValue end,
			default = JournalQuestLog.varDefaults.showMissed,
			requiresReload = true,
		},
		{
			type = "checkbox",
			name = GetString(SI_JOURNAL_QUEST_LOG_SHOW_REPEATABLE),
			tooltip = GetString(SI_JOURNAL_QUEST_LOG_SHOW_REPEATABLE_TOOLTIP),
			getFunc = function() return JournalQuestLog.vars.showRepeatable end,
			setFunc = function(newValue) JournalQuestLog.vars.showRepeatable = newValue end,
			default = JournalQuestLog.varDefaults.showRepeatable,
			requiresReload = true,
		},
		{
			type = "checkbox",
			name = GetString(SI_JOURNAL_QUEST_LOG_SHOW_UNAVAILABLE),
			tooltip = GetString(SI_JOURNAL_QUEST_LOG_SHOW_UNAVAILABLE_TOOLTIP),
			getFunc = function() return JournalQuestLog.vars.showUnavailable end,
			setFunc = function(newValue) JournalQuestLog.vars.showUnavailable = newValue end,
			default = JournalQuestLog.varDefaults.showUnavailable,
			requiresReload = true,
		},
		{
			type = "header",
			name = GetString(SI_JOURNAL_QUEST_LOG_CATEGORIES_HEADER),
		},
		{
			type = "description",
			text = GetString(SI_JOURNAL_QUEST_LOG_CATEGORIES_DESC),
		},
		{
			type = "checkbox",
			name = GetString(SI_QUESTTYPE2),
--			tooltip = GetString(SI_JOURNAL_QUEST_LOG_TYPE_MAIN_TOOLTIP),
			getFunc = function() return JournalQuestLog.vars.typeMain end,
			setFunc = function(newValue) JournalQuestLog.vars.typeMain = newValue end,
			default = JournalQuestLog.varDefaults.typeMain,
			requiresReload = true,
			disabled = true,
			width = "half",
		},
		{
			type = "checkbox",
			name = GetString(SI_QUESTTYPE3),
--			tooltip = GetString(SI_JOURNAL_QUEST_LOG_TYPE_GUILD_TOOLTIP),
			getFunc = function() return JournalQuestLog.vars.typeGuild end,
			setFunc = function(newValue) JournalQuestLog.vars.typeGuild = newValue end,
			default = JournalQuestLog.varDefaults.typeGuild,
			requiresReload = true,
			disabled = true,
			width = "half",
		},
		{
			type = "checkbox",
			name = GetString(SI_QUESTTYPE4),
--			tooltip = GetString(SI_JOURNAL_QUEST_LOG_TYPE_CRAFTING_TOOLTIP),
			getFunc = function() return JournalQuestLog.vars.typeCrafting end,
			setFunc = function(newValue) JournalQuestLog.vars.typeCrafting = newValue end,
			default = JournalQuestLog.varDefaults.typeCrafting,
			requiresReload = true,
			disabled = true,
			width = "half",
		},
		{
			type = "checkbox",
			name = GetString(SI_QUESTTYPE5),
--			tooltip = GetString(SI_JOURNAL_QUEST_LOG_TYPE_DUNGEON_TOOLTIP),
			getFunc = function() return JournalQuestLog.vars.typeDungeon end,
			setFunc = function(newValue) JournalQuestLog.vars.typeDungeon = newValue end,
			default = JournalQuestLog.varDefaults.typeDungeon,
			requiresReload = true,
			disabled = false,
			width = "half",
		},
		{
			type = "checkbox",
			name = GetString(SI_QUESTTYPE6),
--			tooltip = GetString(SI_JOURNAL_QUEST_LOG_TYPE_TRIAL_TOOLTIP),
			getFunc = function() return JournalQuestLog.vars.typeTrial end,
			setFunc = function(newValue) JournalQuestLog.vars.typeTrial = newValue end,
			default = JournalQuestLog.varDefaults.typeTrial,
			requiresReload = true,
			disabled = false,
			width = "half",
		},
		{
			type = "checkbox",
			name = GetString(SI_QUESTTYPE7),
--			tooltip = GetString(SI_JOURNAL_QUEST_LOG_TYPE_ALLIANCE_TOOLTIP),
			getFunc = function() return JournalQuestLog.vars.typeAlliance end,
			setFunc = function(newValue) JournalQuestLog.vars.typeAlliance = newValue end,
			default = JournalQuestLog.varDefaults.typeAlliance,
			requiresReload = true,
			disabled = false,
			width = "half",
		},
		{
			type = "checkbox",
			name = GetString(SI_QUESTTYPE12),
--			tooltip = GetString(SI_JOURNAL_QUEST_LOG_TYPE_HOLIDAY_TOOLTIP),
			getFunc = function() return JournalQuestLog.vars.typeHoliday end,
			setFunc = function(newValue) JournalQuestLog.vars.typeHoliday = newValue end,
			default = JournalQuestLog.varDefaults.typeHoliday,
			requiresReload = true,
			disabled = false,
			width = "half",
		},
		{
			type = "checkbox",
			name = GetString(SI_QUESTTYPE13),
--			tooltip = GetString(SI_JOURNAL_QUEST_LOG_TYPE_BATTLEGROUND_TOOLTIP),
			getFunc = function() return JournalQuestLog.vars.typeBattleground end,
			setFunc = function(newValue) JournalQuestLog.vars.typeBattleground = newValue end,
			default = JournalQuestLog.varDefaults.typeBattleground,
			requiresReload = true,
			disabled = false,
			width = "half",
		},
		{
			type = "checkbox",
			name = GetString(SI_QUESTTYPE14),
--			tooltip = GetString(SI_JOURNAL_QUEST_LOG_TYPE_PROLOGUE_TOOLTIP),
			getFunc = function() return JournalQuestLog.vars.typePrologue end,
			setFunc = function(newValue) JournalQuestLog.vars.typePrologue = newValue end,
			default = JournalQuestLog.varDefaults.typePrologue,
			requiresReload = true,
			disabled = false,
			width = "half",
		},
		{
			type = "checkbox",
			name = GetString(SI_QUESTTYPE15),
--			tooltip = GetString(SI_JOURNAL_QUEST_LOG_TYPE_PLEDGE_TOOLTIP),
			getFunc = function() return JournalQuestLog.vars.typePledge end,
			setFunc = function(newValue) JournalQuestLog.vars.typePledge = newValue end,
			default = JournalQuestLog.varDefaults.typePledge,
			requiresReload = true,
			disabled = false,
			width = "half",
		},
		{
			type = "checkbox",
			name = GetString(SI_QUESTTYPE16),
--			tooltip = GetString(SI_JOURNAL_QUEST_LOG_TYPE_COMPANION_TOOLTIP),
			getFunc = function() return JournalQuestLog.vars.typeCompanion end,
			setFunc = function(newValue) JournalQuestLog.vars.typeCompanion = newValue end,
			default = JournalQuestLog.varDefaults.typeCompanion,
			requiresReload = true,
			disabled = false,
			width = "half",
		},
		{
			type = "checkbox",
			name = GetString(SI_QUESTTYPE17),
--			tooltip = GetString(SI_JOURNAL_QUEST_LOG_TYPE_TRIBUTE_TOOLTIP),
			getFunc = function() return JournalQuestLog.vars.typeTribute end,
			setFunc = function(newValue) JournalQuestLog.vars.typeTribute = newValue end,
			default = JournalQuestLog.varDefaults.typeTribute,
			requiresReload = true,
			disabled = false,
			width = "half",
		},
		{
			type = "checkbox",
			name = GetString(SI_QUESTTYPE18),
--			tooltip = GetString(SI_JOURNAL_QUEST_LOG_TYPE_SCRIBING_TOOLTIP),
			getFunc = function() return JournalQuestLog.vars.typeScribing end,
			setFunc = function(newValue) JournalQuestLog.vars.typeScribing = newValue end,
			default = JournalQuestLog.varDefaults.typeScribing,
			requiresReload = true,
			disabled = false,
			width = "half",
		},
		{
			type = "checkbox",
			name = GetString(SI_QUESTTYPE19),
--			tooltip = GetString(SI_JOURNAL_QUEST_LOG_TYPE_FAVOR_TOOLTIP),
			getFunc = function() return JournalQuestLog.vars.typeFavor end,
			setFunc = function(newValue) JournalQuestLog.vars.typeFavor = newValue end,
			default = JournalQuestLog.varDefaults.typeFavor,
			requiresReload = true,
			disabled = false,
			width = "half",
		},
		{
			type = "checkbox",
			name = GetString(SI_QUESTTYPE20),
--			tooltip = GetString(SI_JOURNAL_QUEST_LOG_TYPE_TAMRIEL_TOOLTIP),
			getFunc = function() return JournalQuestLog.vars.typeTamriel end,
			setFunc = function(newValue) JournalQuestLog.vars.typeTamriel = newValue end,
			default = JournalQuestLog.varDefaults.typeTamriel,
			requiresReload = true,
			disabled = false,
			width = "half",
		},
		{
			type = "description",
			text = GetString(SI_JOURNAL_QUEST_LOG_CATEGORIES_DEBUG),
		},
		{
			type = "header",
			name = GetString(SI_JOURNAL_QUEST_LOG_KEY_HEADER),
		},
		{
			type = "description",
			text = zo_iconTextFormat(newIcon, 16, 16, winnerTextColor:Colorize(GetString(SI_JOURNAL_QUEST_LOG_KEY_MISSABLE))),
		},
		{
			type = "description",
			text = "     "..GetString(SI_JOURNAL_QUEST_LOG_KEY_NORMAL),
		},
		{
			type = "description",
			text = zo_iconTextFormat(disabledIcon, 16, 16, disabledTextColor:Colorize(GetString(SI_JOURNAL_QUEST_LOG_KEY_UNAVAILABLE))),
		},
		{
			type = "description",
			text = zo_iconTextFormat(forbiddenIcon, 16, 16, failedTextColor:Colorize(GetString(SI_JOURNAL_QUEST_LOG_KEY_MISSED))),
		},
		{
			type = "description",
			text = contrastTextColor:Colorize("     "..GetString(SI_JOURNAL_QUEST_LOG_KEY_REPEATABLE)),
		},
		{
			type = "description",
			text = zo_iconTextFormat(checkIcon, 16, 16, normalTextColor:Colorize(GetString(SI_JOURNAL_QUEST_LOG_KEY_COMPLETED))),
		},
		{
			type = "description",
			text = string.format("%s |t16:16:%s|t", GetString(SI_JOURNAL_QUEST_LOG_KEY_COMPANION), companionIcon),
		},
		{
			type = "description",
			text = string.format("%s |t16:16:%s|t", GetString(SI_JOURNAL_QUEST_LOG_KEY_EVENTZONE), adventureIcon),
		},
		{
			type = "description",
			text = string.format("%s |t16:16:%s|t", GetString(SI_JOURNAL_QUEST_LOG_KEY_GROUP), groupIcon),
		},
		{
			type = "description",
			text = string.format("%s |t16:16:%s|t", GetString(SI_JOURNAL_QUEST_LOG_KEY_DUNGEON), dungeonIcon),
		},
		{
			type = "description",
			text = string.format("%s |t16:16:%s|t", GetString(SI_JOURNAL_QUEST_LOG_KEY_ARCHIVE), infiniteIcon),
		},
		{
			type = "description",
			text = string.format("%s |t16:16:%s|t", GetString(SI_JOURNAL_QUEST_LOG_KEY_PUBLIC), publicIcon),
		},
		{
			type = "description",
			text = string.format("%s |t16:16:%s|t", GetString(SI_JOURNAL_QUEST_LOG_KEY_SOLO), soloIcon),
		},
		{
			type = "description",
			text = string.format("%s |t16:16:%s|t", GetString(SI_JOURNAL_QUEST_LOG_KEY_STORY), storyIcon),
		},
		{
			type = "description",
			text = string.format("%s |t16:16:%s|t", GetString(SI_JOURNAL_QUEST_LOG_KEY_TRIAL), trialIcon),
		},
	}
	LAM:RegisterOptionControls(panelData.name.."Config", ConfigData)	
end

function JournalQuestLog.OnAddOnLoaded(event, addonName)
	if addonName ~= JournalQuestLog.name then return end

	EVENT_MANAGER:UnregisterForEvent(JournalQuestLog.name, EVENT_ADD_ON_LOADED)
	JournalQuestLog.Initialize()
end

EVENT_MANAGER:RegisterForEvent(JournalQuestLog.name, EVENT_ADD_ON_LOADED, JournalQuestLog.OnAddOnLoaded)

function JournalQuestLog.Initialize()
	JournalQuestLog.control=GetControl("JQL_Window")
	control=JournalQuestLog.control
	local function InitializeRow(control, data)
		control:SetText(data.questName)--(zo_strformat(GetString(SI_JOURNAL_QUEST_LOG_ROW_ENTRY), data.questName))
	end

	JournalQuestLog.indexContainer = GetControl("JQL_WindowQuestIndex")
	JournalQuestLog.titleText = GetControl("JQL_WindowTitleText")
	ZO_ScrollList_AddDataType(JournalQuestLog.indexContainer, INDEX_TYPE, "JQL_QuestEntryTemplate", 24, InitializeRow)

	-- Votan's stuff
	local sceneName = "QuestLog"
	JQL_FRAGMENT = ZO_HUDFadeSceneFragment:New(JQL_Window)
	JQL_SCENE = ZO_Scene:New(sceneName, SCENE_MANAGER)
	JQL_SCENE:AddFragmentGroup(FRAGMENT_GROUP.PLAYER_PROGRESS_BAR_KEYBOARD_CURRENT)
	JQL_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
	JQL_SCENE:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
	JQL_SCENE:AddFragment(FRAME_TARGET_BLUR_STANDARD_RIGHT_PANEL_FRAGMENT)
	JQL_SCENE:AddFragment(FRAME_EMOTE_FRAGMENT_JOURNAL)
	JQL_SCENE:AddFragment(RIGHT_BG_FRAGMENT)
	JQL_SCENE:AddFragment(TITLE_FRAGMENT)
	JQL_SCENE:AddFragment(JOURNAL_TITLE_FRAGMENT)
	JQL_SCENE:AddFragment(TREE_UNDERLAY_FRAGMENT)
	JQL_SCENE:AddFragment(CODEX_WINDOW_SOUNDS)
	JQL_SCENE:AddFragment(JQL_FRAGMENT)

	SYSTEMS:RegisterKeyboardRootScene(sceneName, JQL_SCENE)

	local sceneGroupInfo = MAIN_MENU_KEYBOARD.sceneGroupInfo["journalSceneGroup"]
	local iconData = sceneGroupInfo.menuBarIconData
	--Override Quests default
	iconData[1] = {
		categoryName = SI_JOURNAL_QUEST_LOG_MENU_QUESTS,
		descriptor = "questJournal",
		normal = "EsoUI/Art/Journal/journal_tabIcon_quest_up.dds",
		pressed = "EsoUI/Art/Journal/journal_tabIcon_quest_down.dds",
		highlight = "EsoUI/Art/Journal/journal_tabIcon_quest_over.dds",
	}
	--Add new Log window
	iconData[#iconData + 1] = {
		categoryName = SI_JOURNAL_QUEST_LOG_MENU_HEADER,
		descriptor = sceneName,
		normal = "/esoui/art/mainmenu/menubar_journal_up.dds",
		pressed = "/esoui/art/mainmenu/menubar_journal_down.dds",
		highlight = "/esoui/art/mainmenu/menubar_journal_over.dds",
	}
	local sceneGroupBarFragment = sceneGroupInfo.sceneGroupBarFragment
	JQL_SCENE:AddFragment(sceneGroupBarFragment)

	JournalQuestLog.InitializeCategoryList(control)
--	JournalQuestLog.RefreshQuestMasterList()
--	JournalQuestLog.RefreshQuestList()
	JournalQuestLog.CreateConfigMenu()
	JournalQuestLog.vars = ZO_SavedVars:NewAccountWide("JournalQuestLog_SavedVariables", 1, nil, JournalQuestLog.varDefaults)

	-- Quest Category Overrides
--	--[[
	if ZO_IS_QUEST_TYPE_IN_OTHER_CATEGORY then
		ZO_IS_QUEST_TYPE_IN_OTHER_CATEGORY =
		{
			[QUEST_TYPE_MAIN_STORY] = JournalQuestLog.vars.typeMain,
			[QUEST_TYPE_GUILD] = JournalQuestLog.vars.typeGuild,
			[QUEST_TYPE_CRAFTING] = JournalQuestLog.vars.typeCrafting,
			[QUEST_TYPE_HOLIDAY_EVENT] = JournalQuestLog.vars.typeHoliday,
			[QUEST_TYPE_BATTLEGROUND] = JournalQuestLog.vars.typeBattleground,
			[QUEST_TYPE_PROLOGUE] = JournalQuestLog.vars.typePrologue,
			[QUEST_TYPE_UNDAUNTED_PLEDGE] = JournalQuestLog.vars.typePledge,
			[QUEST_TYPE_COMPANION] = JournalQuestLog.vars.typeCompanion,
			[QUEST_TYPE_TRIBUTE] = JournalQuestLog.vars.typeTribute,
			[QUEST_TYPE_SCRIBING] = JournalQuestLog.vars.typeScribing,
			[QUEST_TYPE_FAVOR] = JournalQuestLog.vars.typeFavor,
			[QUEST_TYPE_TAMRIEL_TALE] = JournalQuestLog.vars.typeTamriel,
			
			[QUEST_TYPE_AVA] = JournalQuestLog.vars.typeAlliance,
			[QUEST_TYPE_DUNGEON] = JournalQuestLog.vars.typeDungeon,
			[QUEST_TYPE_RAID] = JournalQuestLog.vars.typeTrial,
			[QUEST_TYPE_GROUP] = false,
			[QUEST_TYPE_NONE] = false,

			[QUEST_TYPE_AVA_GRAND] = false,
			[QUEST_TYPE_AVA_GROUP] = false,
			[QUEST_TYPE_CLASS] = false,
		}
	end
	--]]

	local scenegroup = SCENE_MANAGER:GetSceneGroup("journalSceneGroup")
	scenegroup:AddScene(sceneName)
	MAIN_MENU_KEYBOARD:AddRawScene(sceneName, MENU_CATEGORY_JOURNAL, MAIN_MENU_KEYBOARD.categoryInfo[MENU_CATEGORY_JOURNAL], "journalSceneGroup")

	JQL_SCENE:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_SHOWING and JournalQuestLog.dirty then
			JournalQuestLog.CleanCompletedQuests()
			JournalQuestLog.RefreshCompletedQuests()
			JournalQuestLog.dirty = false
			JournalQuestLog.JumpJQLSection()
--			d("JQL Show")
		elseif newState == SCENE_SHOWING then
			JournalQuestLog.JumpJQLSection()
--		elseif newState == SCENE_HIDING then
--			JournalQuestLog.CleanCompletedQuests()
--			d("JQL Hide")
		end
	end )

	EVENT_MANAGER:RegisterForEvent("JournalQuestLog", EVENT_QUEST_COMPLETE, JournalQuestLog.OnCompleteQuest)
--	EVENT_MANAGER:RegisterForEvent("JournalQuestLog", EVENT_ZONE_CHANGED, JournalQuestLog.JumpJQLSection)
	
	JournalQuestLog.RefreshCompletedQuests()
--	d("JQL Initialized")

end

function JournalQuestLog.OnCompleteQuest(eventCode, _)
	JournalQuestLog.dirty = true
end

function JournalQuestLog.JumpJQLSection()
-- Thanks to Alianym for the basis this code!
	local zoneId = GetUnitWorldPosition("player")
	local parentZoneId = GetParentZoneId(zoneId)
	
	if zoneId == 1161 then zoneId = 1160 end
	if zoneId == 1282 then zoneId = 1286 end
	if zoneId == 1414 then zoneId = 1413 end
	if parentZoneId == 1161 then parentZoneId = 1160 end
	if parentZoneId == 1282 then parentZoneId = 1286 end
	if parentZoneId == 1414 then parentZoneId = 1413 end
	
	local zoneName = GetZoneNameById(zoneId)
	local parentZoneName = GetZoneNameById(parentZoneId)
	
	local selectedData = JournalQuestLog.navigationTree:GetSelectedData()
	local control = GetControl("JQL_WindowNavigationContainerScrollChildContainer2")

	local function UpdateJQLZone(targetControl)
		ZO_TreeEntry_OnMouseUp(targetControl, true)

		local scrollCtrl = GetControl("JQL_WindowNavigationContainer")
		ZO_Scroll_ScrollControlIntoCentralView(scrollCtrl, targetControl, true)
	end

	for i=1, control:GetNumChildren() do
		local childControl = control:GetChild(i)
		if childControl:GetText() == zoneName then
			UpdateJQLZone(childControl)
			break
		elseif childControl:GetText() == parentZoneName then
			UpdateJQLZone(childControl)
			break
		end
	end
end

function JournalQuestLog.InitializeCategoryList(control)
	JournalQuestLog.navigationTree = ZO_Tree:New(control:GetNamedChild("NavigationContainerScrollChild"), 40, -10, 385)

    local function TreeHeaderSetup(node, control, completionState, open)
        control:SetModifyTextType(MODIFY_TEXT_TYPE_UPPERCASE)
        control:SetText(GetString("SI_JOURNAL_QUEST_LOG_NAVIGATION", completionState))
        
        ZO_LabelHeader_Setup(control, open)
    end

    local function TreeHeaderEquality(left, right)
        return left.completionState == right.completionState
    end
	
    JournalQuestLog.navigationTree:AddTemplate("ZO_LabelHeader", TreeHeaderSetup, nil, TreeHeaderEquality, nil, 0)

    local function TreeEntrySetup(node, control, data, open)
        control:SetText(zo_strformat("<<1>>", data.name))
        local counter = control:GetNamedChild("CounterText")
		counter:SetText(zo_strformat("<<2>>/<<1>>", #data.quests-data.missed, data.completed))
		GetControl(control, "CompletedIcon"):SetHidden(not data.allCompleted)
        control:SetSelected(false)
    end
    local function TreeEntryOnSelected(control, data, selected, reselectingDuringRebuild)
        control:SetSelected(selected)
        if selected and not reselectingDuringRebuild then
            JournalQuestLog.RefreshCategory()
        end
    end
    local function TreeEntryEquality(left, right)
        return left.name == right.name
    end
    JournalQuestLog.navigationTree:AddTemplate("JQL_NavigationEntry", TreeEntrySetup, TreeEntryOnSelected, TreeEntryEquality)

    JournalQuestLog.navigationTree:SetExclusive(true)
    JournalQuestLog.navigationTree:SetOpenAnimation("ZO_TreeOpenAnimation")
--	d("JQL Navigation Initialized")
end

function JournalQuestLog.RefreshCompletedQuests()

	local questId = 0
	local i = 0
	local j = 0
	local k = 0
	while questId < 10000 do
		questId = GetNextCompletedQuestId(questId)
		if questId == nil then break end
		i = i + 1
		local questName, questType = GetCompletedQuestInfo(questId)
		local zoneName, objectiveName, zoneIndex, poiIndex = GetCompletedQuestLocationInfo(questId)
		questType, zoneName = JournalQuestLog.GetCustomOverride(questId, questType, zoneName)
		local categoryName, categoryType = QUEST_JOURNAL_MANAGER:GetQuestCategoryNameAndType(questType, zoneName)
		local completionState = JQL_COMPLETION_STATE_COMPLETED
		local isAvailable = 1
		local repeatType = LibUespQuestData:GetUespQuestRepeatType(questId)
		local displayType = LibUespQuestData:GetUespQuestInstanceDisplayType(questId)
		local isRepeatable
		local isMissable = 0
		
		if repeatType > 0 then
			isRepeatable = true
		else
			isRepeatable = false
		end
		
		if questName == "" then
			questName = zo_strformat(SI_JOURNAL_QUEST_LOG_UNKNOWN_QUEST_NAME, questId)
		end
		
		completedQuests[i] = {questId=questId, questName=questName, questType=questType, zoneName=zoneName, objectiveName=objectiveName, zoneIndex=zoneIndex, poiIndex=poiIndex, categoryName=categoryName, categoryType=categoryType, completionState=completionState, isAvailable=isAvailable, isRepeatable=isRepeatable, isMissable=isMissable, displayType=displayType}
		
		if (not JournalQuestLog.vars.showRepeatable and isRepeatable) then
			completedQuests[i] = nil
			i = i - 1
		end
		
	end
	
	for questId,questData in next, LibUespQuestData.quests do
--		local questId = tonumber(questIdString)
		if GetCompletedQuestInfo(questId) == "" then
			j = j + 1
			local questName, questType, zoneName, objectiveName = LibUespQuestData:GetUespQuestInfo(questId)
--			questType = tonumber(questType)
			questType, zoneName = JournalQuestLog.GetCustomOverride(questId, questType, zoneName)
			local categoryName, categoryType = QUEST_JOURNAL_MANAGER:GetQuestCategoryNameAndType(questType, zoneName)
			local completionState = JQL_COMPLETION_STATE_NOT_COMPLETED
			local journalZone = zo_strformat(SI_QUEST_JOURNAL_ZONE_FORMAT, zoneName)
			local isAvailable
			local repeatType = LibUespQuestData:GetUespQuestRepeatType(questId)
			local displayType = LibUespQuestData:GetUespQuestInstanceDisplayType(questId)
			local isRepeatable
			local isMissable = JournalQuestLog.GetIsMissable(questId)
			local skipCyrodiil = JournalQuestLog.GetSkipCyrodiil(questId)
			local skipSpecial = JournalQuestLog.GetSkipSpecial(questId)
			
			if repeatType > 0 then
				isRepeatable = true
			else
				isRepeatable = false
			end

			if questName == "" then
				questName = zo_strformat(SI_JOURNAL_QUEST_LOG_UNKNOWN_QUEST_NAME, questId)
			end
			
			-- Collectible IDs indexed under 18173141; Zone IDs indexed under 162658389
			if (journalZone ==  GetZoneNameById(584) or objectiveName == GetString(SI_JOURNAL_QUEST_LOG_DUNGEON_IMPERIAL1) or objectiveName == GetString(SI_JOURNAL_QUEST_LOG_DUNGEON_IMPERIAL2)) and not IsCollectibleUnlocked(154) then isAvailable = false	--Imperial City
			elseif (journalZone == GetZoneNameById(684)) and not IsCollectibleUnlocked(215) then isAvailable = false		--Orsinium
			elseif (journalZone == GetZoneNameById(816) or journalZone == GetZoneNameById(767) or journalZone == GetZoneNameById(771) or journalZone == GetZoneNameById(763) or journalZone == GetZoneNameById(770) or journalZone == GetZoneNameById(764) or journalZone == GetZoneNameById(725)) and not IsCollectibleUnlocked(254) then isAvailable = false	--Thieves Guild
			elseif (journalZone == GetZoneNameById(823) or journalZone == GetZoneNameById(769) or journalZone == GetZoneNameById(765) or journalZone == GetZoneNameById(766) or questName == string.match(questName,GetString(SI_JOURNAL_QUEST_LOG_QUEST_DARK_CONTRACT))) and not IsCollectibleUnlocked(306) then isAvailable = false	--Dark Brotherhood
			elseif (journalZone == GetZoneNameById(849) or journalZone == GetZoneNameById(975)) and not IsCollectibleUnlocked(593) then isAvailable = false												--Morrowind
			elseif (journalZone == GetZoneNameById(980) or journalZone == GetZoneNameById(1000)) and not IsCollectibleUnlocked(1240) then isAvailable = false											--Clockwork City
			elseif (journalZone == GetZoneNameById(1011) or journalZone == GetZoneNameById(1051)) and not IsCollectibleUnlocked(5107) then isAvailable = false											--Summerset
			elseif (journalZone == GetZoneNameById(726)) and not IsCollectibleUnlocked(5755) then isAvailable = false																					--Murkmire
			elseif (journalZone == GetZoneNameById(1086) or journalZone == GetZoneNameById(1121)) and not IsCollectibleUnlocked(5843) then isAvailable = false											--Elsweyr
			elseif (journalZone == GetZoneNameById(1133)) and not IsCollectibleUnlocked(6920) then isAvailable = false																					--Dragonhold
			elseif (journalZone == GetZoneNameById(1160) or journalZone == GetZoneNameById(1161) or journalZone == GetZoneNameById(1196)) and not IsCollectibleUnlocked(7466) then isAvailable = false	--Greymoor
			elseif (journalZone == GetZoneNameById(1207) or journalZone == GetZoneNameById(1208)) and not IsCollectibleUnlocked(8388) then isAvailable = false											--Markarth
			elseif (journalZone == GetZoneNameById(1261) or journalZone == GetZoneNameById(1263)) and not IsCollectibleUnlocked(8659) then isAvailable = false											--Blackwood
			elseif (journalZone == GetZoneNameById(1286) or journalZone == GetZoneNameById(1282)) and not IsCollectibleUnlocked(9365) then isAvailable = false											--Deadlands
			elseif (journalZone == GetZoneNameById(1318) or journalZone == GetZoneNameById(1344)) and not IsCollectibleUnlocked(10053) then isAvailable = false											--High Isle
			elseif (journalZone == GetZoneNameById(1383)) and not IsCollectibleUnlocked(10660) then isAvailable = false																					--Firesong
			elseif (journalZone == GetZoneNameById(1413) or journalZone == GetZoneNameById(1414) or journalZone == GetZoneNameById(1427)) and not IsCollectibleUnlocked(10475) then isAvailable = false	--Necrom
			elseif (journalZone == GetZoneNameById(1443) or journalZone == GetZoneNameById(1463) or journalZone == GetZoneNameById(1478)) and not IsCollectibleUnlocked(11871) then isAvailable = false	--Gold Road
			elseif (journalZone == GetZoneNameById(1502) or journalZone == GetZoneNameById(1548)) and not IsCollectibleUnlocked(13439) then isAvailable = false											--Solstice
			elseif ((objectiveName == GetString(SI_JOURNAL_QUEST_LOG_DUNGEON_SHADOWS1)) or journalZone == GetZoneNameById(843)) and not IsCollectibleUnlocked(375) then isAvailable = false				--Ruins of Mazzatun
			elseif ((objectiveName == GetString(SI_JOURNAL_QUEST_LOG_DUNGEON_SHADOWS2)) or journalZone == GetZoneNameById(848)) and not IsCollectibleUnlocked(491) then isAvailable = false				--Cradle of Shadows
			elseif ((objectiveName == GetString(SI_JOURNAL_QUEST_LOG_DUNGEON_HORNS1)) or journalZone == GetZoneNameById(973)) and not IsCollectibleUnlocked(1165) then isAvailable = false				--Bloodroot Forge
			elseif ((objectiveName == GetString(SI_JOURNAL_QUEST_LOG_DUNGEON_HORNS2)) or journalZone == GetZoneNameById(974)) and not IsCollectibleUnlocked(1355) then isAvailable = false				--Falkreath Hold
			elseif ((objectiveName == GetString(SI_JOURNAL_QUEST_LOG_DUNGEON_BONES1)) or journalZone == GetZoneNameById(1009)) and not IsCollectibleUnlocked(1331) then isAvailable = false				--Fang Lair
			elseif ((objectiveName == GetString(SI_JOURNAL_QUEST_LOG_DUNGEON_BONES2)) or journalZone == GetZoneNameById(1010)) and not IsCollectibleUnlocked(4703) then isAvailable = false				--Scalecaller Peak
			elseif ((objectiveName == GetString(SI_JOURNAL_QUEST_LOG_DUNGEON_WOLFHUNTER1)) or journalZone == GetZoneNameById(1055)) and not IsCollectibleUnlocked(5009) then isAvailable = false		--March of Sacrifices
			elseif ((objectiveName == GetString(SI_JOURNAL_QUEST_LOG_DUNGEON_WOLFHUNTER2)) or journalZone == GetZoneNameById(1052)) and not IsCollectibleUnlocked(5008) then isAvailable = false		--Moon Hunter Keep
			elseif ((objectiveName == GetString(SI_JOURNAL_QUEST_LOG_DUNGEON_WRATHSTONE1)) or journalZone == GetZoneNameById(1081)) and not IsCollectibleUnlocked(5474) then isAvailable = false		--Depths of Malatar
			elseif ((objectiveName == GetString(SI_JOURNAL_QUEST_LOG_DUNGEON_WRATHSTONE2)) or journalZone == GetZoneNameById(1080)) and not IsCollectibleUnlocked(5473) then isAvailable = false		--Frostvault
			elseif ((objectiveName == GetString(SI_JOURNAL_QUEST_LOG_DUNGEON_SCALEBREAKER1)) or journalZone == GetZoneNameById(1122)) and not IsCollectibleUnlocked(6040) then isAvailable = false		--Moongrave Fane
			elseif ((objectiveName == GetString(SI_JOURNAL_QUEST_LOG_DUNGEON_SCALEBREAKER2)) or journalZone == GetZoneNameById(1123)) and not IsCollectibleUnlocked(6041) then isAvailable = false		--Lair of Maarselok
			elseif ((objectiveName == GetString(SI_JOURNAL_QUEST_LOG_DUNGEON_HARROWSTORM1)) or journalZone == GetZoneNameById(1152)) and not IsCollectibleUnlocked(6646) then isAvailable = false		--Icereach
			elseif ((objectiveName == GetString(SI_JOURNAL_QUEST_LOG_DUNGEON_HARROWSTORM2)) or journalZone == GetZoneNameById(1153)) and not IsCollectibleUnlocked(6647) then isAvailable = false		--Unhallowed Grave
			elseif ((objectiveName == GetString(SI_JOURNAL_QUEST_LOG_DUNGEON_STONETHORN1)) or journalZone == GetZoneNameById(1197)) and not IsCollectibleUnlocked(7430) then isAvailable = false		--Stone Garden
			elseif ((objectiveName == GetString(SI_JOURNAL_QUEST_LOG_DUNGEON_STONETHORN2)) or journalZone == GetZoneNameById(1201))and not IsCollectibleUnlocked(7431) then isAvailable = false			--Castle Thorn
			elseif ((objectiveName == GetString(SI_JOURNAL_QUEST_LOG_DUNGEON_FLAMES1)) or journalZone == GetZoneNameById(1228)) and not IsCollectibleUnlocked(8216) then isAvailable = false			--Black Drake Villa
			elseif ((objectiveName == GetString(SI_JOURNAL_QUEST_LOG_DUNGEON_FLAMES2)) or journalZone == GetZoneNameById(1229)) and not IsCollectibleUnlocked(8217) then isAvailable = false			--The Cauldron
			elseif ((objectiveName == GetString(SI_JOURNAL_QUEST_LOG_DUNGEON_WAKING1)) or journalZone == GetZoneNameById(1267)) and not IsCollectibleUnlocked(9374) then isAvailable = false			--Red Petal Bastion
			elseif ((objectiveName == GetString(SI_JOURNAL_QUEST_LOG_DUNGEON_WAKING2)) or journalZone == GetZoneNameById(1268)) and not IsCollectibleUnlocked(9375) then isAvailable = false			--The Dread Cellar
			elseif ((objectiveName == GetString(SI_JOURNAL_QUEST_LOG_DUNGEON_ASCENDING1)) or journalZone == GetZoneNameById(1301)) and not IsCollectibleUnlocked(9651) then isAvailable = false			--Coral Aerie
			elseif ((objectiveName == GetString(SI_JOURNAL_QUEST_LOG_DUNGEON_ASCENDING2)) or journalZone == GetZoneNameById(1302)) and not IsCollectibleUnlocked(9652) then isAvailable = false			--Shripwright's Regret
			elseif ((objectiveName == GetString(SI_JOURNAL_QUEST_LOG_DUNGEON_DEPTHS1)) or journalZone == GetZoneNameById(1360)) and not IsCollectibleUnlocked(10400) then isAvailable = false			--Earthen Root Enclave
			elseif ((objectiveName == GetString(SI_JOURNAL_QUEST_LOG_DUNGEON_DEPTHS2)) or journalZone == GetZoneNameById(1361)) and not IsCollectibleUnlocked(10401) then isAvailable = false			--Graven Deep
			elseif ((objectiveName == GetString(SI_JOURNAL_QUEST_LOG_DUNGEON_SCRIBES1)) or journalZone == GetZoneNameById(1389)) and not IsCollectibleUnlocked(10838) then isAvailable = false			--Bal Sunnar
			elseif ((objectiveName == GetString(SI_JOURNAL_QUEST_LOG_DUNGEON_SCRIBES2)) or journalZone == GetZoneNameById(1390)) and not IsCollectibleUnlocked(10839) then isAvailable = false			--Scrivener's Hall
			elseif ((objectiveName == GetString(SI_JOURNAL_QUEST_LOG_DUNGEON_SCIONS1)) or journalZone == GetZoneNameById(1470)) and not IsCollectibleUnlocked(11650) then isAvailable = false			--Oathsworn Pit
			elseif ((objectiveName == GetString(SI_JOURNAL_QUEST_LOG_DUNGEON_SCIONS2)) or journalZone == GetZoneNameById(1471)) and not IsCollectibleUnlocked(11651) then isAvailable = false			--Bedlam Veil
			elseif ((objectiveName == GetString(SI_JOURNAL_QUEST_LOG_DUNGEON_BANNERS1)) or journalZone == GetZoneNameById(1496)) and not IsCollectibleUnlocked(12699) then isAvailable = false			--Exiled Redoubt
			elseif ((objectiveName == GetString(SI_JOURNAL_QUEST_LOG_DUNGEON_BANNERS2)) or journalZone == GetZoneNameById(1497)) and not IsCollectibleUnlocked(12700) then isAvailable = false			--Lep Seclusa
			elseif ((objectiveName == GetString(SI_JOURNAL_QUEST_LOG_DUNGEON_FEAST1)) or journalZone == GetZoneNameById(1551)) and not IsCollectibleUnlocked(13556) then isAvailable = false			--Naj-Caldeesh
			elseif ((objectiveName == GetString(SI_JOURNAL_QUEST_LOG_DUNGEON_FEAST2)) or journalZone == GetZoneNameById(1552)) and not IsCollectibleUnlocked(13557) then isAvailable = false			--Black Gem Foundry
			else isAvailable = true
			end
			
			incompleteQuests[j] = {questId=questId, questName=questName, questType=questType, zoneName=zoneName, objectiveName=objectiveName, zoneIndex="", poiIndex="", categoryName=categoryName, categoryType=categoryType, completionState=completionState, isAvailable=isAvailable, isRepeatable=isRepeatable, isMissable = isMissable, displayType=displayType}
			
			if isMissable == JQL_MISSABLE_STATE_MISSED then
				k = k + 1
				missedQuests[k] = {questId=questId, questName=questName, questType=questType, zoneName=zoneName, objectiveName=objectiveName, zoneIndex="", poiIndex="", categoryName=categoryName, categoryType=categoryType, completionState=completionState, isAvailable=isAvailable, isRepeatable=isRepeatable, isMissable = isMissable, displayType=displayType}
			end
			
			if (not JournalQuestLog.vars.showMissed and isMissable == JQL_MISSABLE_STATE_MISSED) or (not JournalQuestLog.vars.showUnavailable and not isAvailable) or (not JournalQuestLog.vars.showRepeatable and isRepeatable) or (skipCyrodiil) or (skipSpecial) then
				incompleteQuests[j] = nil
				if isMissable == JQL_MISSABLE_STATE_MISSED then
					missedQuests[k] = nil
					k = k - 1
				end
				j = j - 1
			end
		end
	end
	
	local duplicateQuests = JournalQuestLog.DuplicateManager()
	
	for i = 1, #duplicateQuests do
		incompleteQuests[#incompleteQuests+1] = duplicateQuests[i]
	end
		

	local function QuestEntryComparator(leftScrollData, rightScrollData)
		local leftName = leftScrollData.questName
		local rightName = rightScrollData.questName
		
		return leftName < rightName
	end
	
	table.sort(completedQuests,QuestEntryComparator)
	table.sort(incompleteQuests,QuestEntryComparator)
	
	--make combined table
	for i = 1, #completedQuests do
		allQuests[i] = completedQuests[i]
	end
	for i = 1, #incompleteQuests do
		allQuests[i+#completedQuests] = incompleteQuests[i]
	end
	
	if not JournalQuestLog.vars.listGrouped then table.sort(allQuests,QuestEntryComparator) end

	for i = 1, #allQuests do
--		if allQuests[i].displayType > 0 then
			local displayIcon
			if allQuests[i].displayType == ZONE_DISPLAY_TYPE_SOLO then displayIcon = soloIcon
			elseif allQuests[i].displayType == ZONE_DISPLAY_TYPE_DUNGEON then displayIcon = dungeonIcon
			elseif allQuests[i].displayType == ZONE_DISPLAY_TYPE_RAID then displayIcon = trialIcon
			elseif allQuests[i].displayType == ZONE_DISPLAY_TYPE_GROUP_DELVE then displayIcon = gpdelveIcon
			elseif allQuests[i].displayType == ZONE_DISPLAY_TYPE_GROUP_AREA then displayIcon = groupIcon
			elseif allQuests[i].displayType == ZONE_DISPLAY_TYPE_PUBLIC_DUNGEON then displayIcon = publicIcon
			elseif allQuests[i].displayType == ZONE_DISPLAY_TYPE_DELVE then displayIcon = delveIcon
			elseif allQuests[i].displayType == ZONE_DISPLAY_TYPE_HOUSING then displayIcon = houseIcon
			elseif allQuests[i].displayType == ZONE_DISPLAY_TYPE_BATTLEGROUND then displayIcon = battleIcon
			elseif allQuests[i].displayType == ZONE_DISPLAY_TYPE_ZONE_STORY then displayIcon = storyIcon
			elseif allQuests[i].displayType == ZONE_DISPLAY_TYPE_COMPANION then displayIcon = companionIcon
			elseif allQuests[i].displayType == ZONE_DISPLAY_TYPE_ENDLESS_DUNGEON then displayIcon = infiniteIcon
			elseif allQuests[i].displayType == ZONE_DISPLAY_TYPE_ADVENTURE_ZONE then displayIcon = adventureIcon
			elseif allQuests[i].questType == QUEST_TYPE_GROUP then displayIcon = groupIcon
			end
			if displayIcon then allQuests[i].questName = string.format("%s |t16:16:%s|t", allQuests[i].questName, displayIcon) end
--		elseif allQuests[i].questType == QUEST_TYPE_GROUP then allQuests[i].questName = string.format("%s |t16:16:%s|t", allQuests[i].questName, displayIcon)
--		end
		if not allQuests[i].isAvailable then allQuests[i].questName = disabledTextColor:Colorize(allQuests[i].questName)
		elseif allQuests[i].isRepeatable then allQuests[i].questName = contrastTextColor:Colorize(allQuests[i].questName)
		elseif allQuests[i].completionState == JQL_COMPLETION_STATE_COMPLETED then allQuests[i].questName = normalTextColor:Colorize(allQuests[i].questName)
		elseif allQuests[i].isMissable == JQL_MISSABLE_STATE_MISSABLE then allQuests[i].questName = winnerTextColor:Colorize(allQuests[i].questName)
		elseif allQuests[i].isMissable == JQL_MISSABLE_STATE_MISSED then allQuests[i].questName = failedTextColor:Colorize(allQuests[i].questName)
		end
		
		if not allQuests[i].isAvailable then allQuests[i].questName = "zzw_"..zo_iconTextFormat(disabledIcon, 16, 16, allQuests[i].questName)
		elseif allQuests[i].completionState == JQL_COMPLETION_STATE_COMPLETED then allQuests[i].questName = "zzz_"..zo_iconTextFormat(checkIcon, 16, 16, allQuests[i].questName)
		elseif allQuests[i].isMissable == JQL_MISSABLE_STATE_MISSABLE then allQuests[i].questName = "aaa_"..zo_iconTextFormat(newIcon, 16, 16, allQuests[i].questName)
		elseif allQuests[i].isMissable == JQL_MISSABLE_STATE_MISSED then allQuests[i].questName = "zzx_"..zo_iconTextFormat(forbiddenIcon, 16, 16, allQuests[i].questName)
		else allQuests[i].questName = "aab_     "..allQuests[i].questName end
		--else allQuests[i].questName = zo_iconTextFormat(bulletIcon, 16, 16, allQuests[i].questName) end
		
		if allQuests[i].isRepeatable then allQuests[i].questName = "zzy_"..allQuests[i].questName end

	end
	
	if JournalQuestLog.vars.listGrouped then table.sort(allQuests,QuestEntryComparator) end
	
	for i = 1, #allQuests do
		allQuests[i].questName = string.gsub(allQuests[i].questName,"aaa_","")
		allQuests[i].questName = string.gsub(allQuests[i].questName,"aab_","")
		allQuests[i].questName = string.gsub(allQuests[i].questName,"zzw_","")
		allQuests[i].questName = string.gsub(allQuests[i].questName,"zzx_","")
		allQuests[i].questName = string.gsub(allQuests[i].questName,"zzy_","")
		allQuests[i].questName = string.gsub(allQuests[i].questName,"zzz_","")
	end

	-- the strings corresponding to the keys for data held in completedQuests[i]
	local questInfoFields = { "questId", "questName", "questType", "zoneName", "objectiveName", "zoneIndex", "poiIndex", "categoryName", "categoryType", "completionState", }
	local dataCatName = { }
	local data = { }

	--[[
			table structure is roughly: data = { [1] = { name = "category1 by name", quests = { [1] = quest1, [2] = quest2, ... } }, [2] = { name="category2 by name", quests = { [1] = quest3, [2] = quest4, ...} }, ...}
			where dataCatName = { ["category1 by name"] = data[1], ["category2 by name"] = data[2], ...}
	--]]
	for i = 1, #allQuests do
		local questInfo = { }
		-- fill out the current quest info into our data format
		for _, field in pairs(questInfoFields) do
			questInfo[tostring(field)] = allQuests[i][tostring(field)]
		end

		local pos = 1
		local categoryName = allQuests[i].categoryName
		-- if the category doesn't exist yet, create it
		if not dataCatName[categoryName] then
			-- save by name as the key, because I want to be able to find this using the category name to quickly associate quests with their category table
			dataCatName[categoryName] = { name = categoryName }
			-- but also create an iterative key version of the category names, using keys 1 to n, since it makes it easier to sort and use generically when we care less about the name
			if #data > 0 then
				for i = 1, #data do
					-- find the first spot where the new category is lower down the alphabet, and keep going until the end of the table or the first time its no longer lower
					-- more reliable in practice than table.sort, which wasn't providing the correct order
					if tostring(categoryName) > tostring(data[i].name)then pos = i+1 end
				end
			end
			-- insert into pos 1 if the table is empty or the category precedes all the others alphabetically, else place it (after the first miss) into the spot it belongs
			table.insert(data, pos, dataCatName[categoryName])
		end

		local dcn = dataCatName[categoryName]
		-- make sure this category has room to hold quests
		if not dcn.quests then dcn.quests = { } end
		if not dcn.completed then dcn.completed = 0 end
		if not dcn.missed then dcn.missed = 0 end
		local questName = allQuests[i].questName

		-- if this quest isn't in the category yet, add it
		--if not dcn.quests[questName] then dcn.quests[questName]  = { } end
		local k = #dcn.quests + 1
		dcn.quests[k] = { }
		if allQuests[i].completionState == JQL_COMPLETION_STATE_COMPLETED then dcn.completed = dcn.completed + 1 end
		if allQuests[i].isMissable == JQL_MISSABLE_STATE_MISSED then dcn.missed = dcn.missed + 1 end

		-- copy the quest info to the table
		for field, value in pairs(questInfo) do
			dcn.quests[k][tostring(field)] = value
		end
	end

--[[
--	local data2CatName = { }
--	local data2 = { }

	for i = 1, #incompleteQuests do
		local questInfo = { }
		-- fill out the current quest info into our data2 format
		for _, field in pairs(questInfoFields) do
			questInfo[tostring(field)] = incompleteQuests[i][tostring(field)]
		end

		local pos = 1
		local categoryName = incompleteQuests[i].categoryName
		-- if the category doesn't exist yet, create it
		if not dataCatName[categoryName] then
			-- save by name as the key, because I want to be able to find this using the category name to quickly associate quests with their category table
			dataCatName[categoryName] = { name = categoryName }
			-- but also create an iterative key version of the category names, using keys 1 to n, since it makes it easier to sort and use generically when we care less about the name
			if #data > 0 then
				for i = 1, #data do
					-- find the first spot where the new category is lower down the alphabet, and keep going until the end of the table or the first time its no longer lower
					-- more reliable in practice than table.sort, which wasn't providing the correct order
					if tostring(categoryName) > tostring(data[i].name)then pos = i+1 end
				end
			end
			-- insert into pos 1 if the table is empty or the category precedes all the others alphabetically, else place it (after the first miss) into the spot it belongs
			table.insert(data, pos, dataCatName[categoryName])
		end

		local dcn = dataCatName[categoryName]
		-- make sure this category has room to hold quests
		if not dcn.quests then dcn.quests = { } end
		if not dcn.completed then dcn.completed = 0 end
		local questName = incompleteQuests[i].questName

		-- if this quest isn't in the category yet, add it
		--if not dcn.quests[questName] then dcn.quests[questName]  = { } end
		local k = #dcn.quests + 1
		dcn.quests[k] = { }

		-- copy the quest info to the table
		for field, value in pairs(questInfo) do
			dcn.quests[k][tostring(field)] = value
		end
	end
--]]
	
	JournalQuestLog.navigationTree:Reset()
	
	local categories = {}
	
	local completionState = JQL_COMPLETION_STATE_COMPLETED
	
		local parent = JournalQuestLog.navigationTree:AddNode("ZO_LabelHeader", completionState, nil, SOUNDS.CADWELL_BLADE_SELECTED)

		for i = 1, #data do
			local category = data[i]
			local quests = {}
			for _, quest in pairs(category.quests) do
--				if quest.completionState == completionState then
					table.insert(quests, {name = quest.questName})
--				end
			end
			local allCompleted
			if #quests-category.missed == category.completed then
				allCompleted = true
			else
				allCompleted = false
			end
			table.insert(categories, {name = category.name, quests = quests, parent = parent, completed = category.completed, missed = category.missed, allCompleted = allCompleted})
		end
	
--[[
	local completionState2 = JQL_COMPLETION_STATE_NOT_COMPLETED
	
		local parent2 = JournalQuestLog.navigationTree:AddNode("ZO_LabelHeader", completionState2, nil, SOUNDS.CADWELL_BLADE_SELECTED)

		for i = 1, #data2 do
			local category = data2[i]
			local quests = {}
			for _, quest in pairs(category.quests) do
				if quest.completionState == completionState2 then
					table.insert(quests, {name = quest.questName})
				end
			end
			table.insert(categories, {name = category.name, quests = quests, parent = parent2})
		end
--]]
		
	for i = 1, #categories do
		local category = categories[i]
		local parent = category.parent
		JournalQuestLog.navigationTree:AddNode("JQL_NavigationEntry", category, parent, SOUNDS.CADWELL_ITEM_SELECTED)
	end

	JournalQuestLog.navigationTree:Commit()
	
	--[[
	
	-- color the zone names/categories
	local color = ZO_ColorDef:New()
	color:SetRGBA(0.5, 0.5, 0.5, 1)
	for i = 1, #data do
		local category = data[i]
		-- add the zone name/category with a blank line above it
		scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(INDEX_TYPE, {questName = ""})
		scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(INDEX_TYPE, {questName = color:Colorize(category.name)})
		for _, quest in pairs(category.quests) do
			-- add the quests to each category, in alphabetical order from before
			scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(INDEX_TYPE, {questName = quest.questName})
		end
	end

	ZO_ScrollList_Commit(JournalQuestLog.indexContainer)
	
	--]]

	local QuestCounter = GetControl("JQL_WindowQuestCount")
	QuestCounter:SetText(zo_strformat(GetString(SI_JOURNAL_QUEST_LOG_COMPLETED),#completedQuests,#completedQuests+#incompleteQuests-#missedQuests))
	
	JournalQuestLog.RefreshCategory()
--	d("JQL Refreshed")

end

function JournalQuestLog.RefreshCategory()
	local scrollData = ZO_ScrollList_GetDataList(JournalQuestLog.indexContainer)
	ZO_ScrollList_Clear(JournalQuestLog.indexContainer)

--	if JournalQuestLog.selectedNode then
--		JournalQuestLog.navigationTree:SelectNode(JournalQuestLog.selectedNode, true, true)
--		JournalQuestLog.selectedNode = nil
--	end

    local selectedData = JournalQuestLog.navigationTree:GetSelectedData()
	if type(selectedData) == "table" then
		if not selectedData or not selectedData.quests then
			JournalQuestLog.indexContainer:SetHidden(true)
			return
		else
			JournalQuestLog.indexContainer:SetHidden(false)
		end
	else
		JournalQuestLog.indexContainer:SetHidden(true)
		return
	end
	
	for i = 1, #selectedData.quests do
		local quests = selectedData.quests[i]
		scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(INDEX_TYPE, {questName = quests.name})
	end
	JournalQuestLog.titleText:SetText(zo_strformat(selectedData.name))
	ZO_ScrollList_Commit(JournalQuestLog.indexContainer)
--	d("JQL Quest List Updated")	
end

function JournalQuestLog.CleanCompletedQuests()

--	JournalQuestLog.selectedNode = JournalQuestLog.navigationTree:GetSelectedNode()
	local scrollData = ZO_ScrollList_GetDataList(JournalQuestLog.indexContainer)
	ZO_ScrollList_Clear(JournalQuestLog.indexContainer)
	JournalQuestLog.navigationTree:Reset()

	completedQuests = {}
	incompleteQuests = {}
	missedQuests = {}

--	d("JQL Cleaned")
end

-- // questJournal Manager overrides //
--[[ This was for the Active Quests override - it doesn't work right now

function JournalQuestLog.RefreshQuestMasterList()
    local quests, categories = QUEST_JOURNAL_MANAGER:GetQuestListData()
	local questJournalObject = SYSTEMS:GetObject("questJournal")
    questJournalObject.questMasterList = {
        quests = quests,
        categories = categories,
--      seenCategories = seenCategories,
    }
end

function JournalQuestLog:RefreshQuestList()
	local questJournalObject = SYSTEMS:GetObject("questJournal")
--  local quests = questJournalObject.questMasterList.quests
--  local categories = questJournalObject.questMasterList.categories

    questJournalObject.questIndexToTreeNode = {}

    ClearTooltip(InformationTooltip)

    -- Add items to the tree
    questJournalObject.navigationTree:Reset()

    local categoryNodes = {}
    local categories = QUEST_JOURNAL_MANAGER:GetQuestCategories()
    for i, categoryInfo in ipairs(categories) do
        categoryNodes[categoryInfo.name] = questJournalObject.navigationTree:AddNode("ZO_QuestJournalHeader", categoryInfo.name)
    end

    local firstNode
    local lastNode
    local assistedNode
    local questList = QUEST_JOURNAL_MANAGER:GetQuestList()
    for i, questInfo in ipairs(questList) do
        local parent = categoryNodes[questInfo.categoryName]
        local questNode = questJournalObject.navigationTree:AddNode("ZO_QuestJournalNavigationEntry", questInfo, parent)
        firstNode = firstNode or questNode
        questJournalObject.questIndexToTreeNode[questInfo.questIndex] = questNode

        if lastNode then
            lastNode.nextNode = questNode
        end

        if i == #questList then
            questNode.nextNode = firstNode
        end

        if assistedNode == nil and GetTrackedIsAssisted(TRACK_TYPE_QUEST, questInfo.questIndex) then
            assistedNode = questNode
        end

        lastNode = questNode
    end

    questJournalObject.navigationTree:Commit(assistedNode)

    questJournalObject:RefreshDetails()

    questJournalObject.listDirty = false
end
--]]