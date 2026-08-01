local addon = {}

addon.name = 'IMP_STATS_MENU'

local Log = IMP_STATS_Logger('IMP_STATS_MENU')

local LMM = LibMainMenu2
LMM:Init()

local CATEGORIES = {
	{
		name = SI_IMP_PVP_METER_BATTLEGROUNS_TAB_TITLE,
		container = IMP_STATS_MATCHES,
		icons = {
			normal = 'EsoUI/Art/Battlegrounds/battlegrounds_tabIcon_battlegrounds_up.dds',
			pressed = 'EsoUI/Art/Battlegrounds/battlegrounds_tabIcon_battlegrounds_down.dds',
			highlight = 'EsoUI/Art/Battlegrounds/battlegrounds_tabIcon_battlegrounds_over.dds',
		},
	},
	{
		name = SI_IMP_PVP_METER_DUELS_TAB_TITLE,
		container = IMP_STATS_DUELS,
		icons = {
			normal = "EsoUI/Art/Journal/journal_tabIcon_leaderboard_up.dds",
			pressed = "EsoUI/Art/Journal/journal_tabIcon_leaderboard_down.dds",
			highlight = "EsoUI/Art/Journal/journal_tabIcon_leaderboard_over.dds",
		},
	},
	{
		name = SI_IMP_PVP_METER_TOT_TAB_TITLE,
		container = IMP_STATS_TRIBUTE,
		icons = {
			normal = 'EsoUI/Art/Tribute/tribute_tabicon_tribute_up.dds',
			pressed = 'EsoUI/Art/Tribute/tribute_tabicon_tribute_down.dds',
			highlight = 'EsoUI/Art/Tribute/tribute_tabicon_tribute_over.dds',
		},
	}
}

function addon:Initialize(initBGs, initDuels, initTOT)
	IMP_STATS_TITLE_FRAGMENT = ZO_SetTitleFragment:New(SI_IMP_PVP_METER_MAIN_MENU_TITLE)
	-- TODO: subtitle

	local SUBMENU = {}

	self.scenes = {}

    local RIGHT_PANEL = ZO_SimpleSceneFragment:New(IMP_STATS_RightPanel)

	local function CreateScene(sceneName, container)
		local scene = ZO_Scene:New(sceneName, SCENE_MANAGER)

        scene:AddFragment(RIGHT_PANEL)

		scene:AddFragmentGroup(FRAGMENT_GROUP.PLAYER_PROGRESS_BAR_KEYBOARD_CURRENT)
		scene:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
		scene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
		scene:AddFragment(RIGHT_BG_FRAGMENT)

		scene:AddFragment(TITLE_FRAGMENT)
		scene:AddFragment(IMP_STATS_TITLE_FRAGMENT)

		local fragment = ZO_SimpleSceneFragment:New(container)
		scene:AddFragment(fragment)

		self.scenes[sceneName] = container

		return scene
	end

	local scenes = {}
	local function InitializeCategory(index)
		local category = CATEGORIES[index]
		local sceneName = addon.name .. category.name .. 'Scene'
		CreateScene(sceneName, category.container)
		table.insert(SUBMENU, {
			categoryName = category.name,
			descriptor = sceneName,
			normal = category.icons.normal,
			pressed = category.icons.pressed,
			highlight = category.icons.highlight,
		})
		table.insert(scenes, sceneName)
	end

	local arg = {initBGs, initDuels, initTOT}
	for i, doInit in ipairs(arg) do
		if doInit then InitializeCategory(i) end
        Log('%s panel initialized', CATEGORIES[i].name)
	end

	local MENU_CATEGORY = {
		categoryName = SI_IMP_PVP_METER_MAIN_MENU_TITLE,
		binding = IMP_STATS_TOGGLE_PANEL,
		-- descriptor = 19,
		-- normal = 'EsoUi/Art/journal/journal_tabicon_achievements_up.dds',
		-- pressed = 'EsoUi/Art/journal/journal_tabicon_achievements_down.dds',
		-- highlight = 'EsoUi/Art/journal/journal_tabicon_achievements_over.dds',
		normal = 'EsoUi/Art/campaign/campaignbrowser_indexicon_normal_up.dds',
		pressed = 'EsoUi/Art/campaign/campaignbrowser_indexicon_normal_down.dds',
		highlight = 'EsoUi/Art/campaign/campaignbrowser_indexicon_normal_over.dds',
		callback = function()
			self:Show()
		end,
	}
	IMP_STATS_MENU_CATEGORY = LMM:AddCategory(MENU_CATEGORY)

	local IMP_STATS_SCENE_GROUP_NAME = addon.name .. 'SceneGroup'
	self.sceneGroup = ZO_SceneGroup:New(unpack(scenes))
	SCENE_MANAGER:AddSceneGroup(IMP_STATS_SCENE_GROUP_NAME, self.sceneGroup)

	LMM:AddSceneGroup(IMP_STATS_MENU_CATEGORY, IMP_STATS_SCENE_GROUP_NAME, SUBMENU)
	LMM:AddMenuItem(IMP_STATS_SCENE_GROUP_NAME, MENU_CATEGORY)
end

-- TODO: refactor ?
function addon:Show()
	if not self.sceneGroup:IsShowing() then
		LMM:ToggleCategory(IMP_STATS_MENU_CATEGORY)
	end
end

function IMP_STATS_TogglePanel()
	LMM:ToggleCategory(IMP_STATS_MENU_CATEGORY)
	-- TODO: highlight button in the menu itself
	-- :RefreshCategoryIndicators()
	-- :Update()
	-- ZO_MenuBar_ClearSelection(MAIN_MENU_KEYBOARD.categoryBar)
end

IMP_STATS_MENU = addon