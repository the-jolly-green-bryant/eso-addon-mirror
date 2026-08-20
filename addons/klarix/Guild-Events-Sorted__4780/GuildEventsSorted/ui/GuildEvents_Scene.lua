GuildEventsUI = GuildEventsUI or {}
local sceneName = "guildEvents"

function GuildEventsUI:CreateScene()
	GUILD_EVENTS_SCENE = ZO_Scene:New(sceneName, SCENE_MANAGER)
	GUILD_EVENTS_FRAGMENT = ZO_HUDFadeSceneFragment:New(self.control)

	GUILD_EVENTS_SCENE:AddFragment(RIGHT_BG_FRAGMENT)
	GUILD_EVENTS_SCENE:AddFragment(TREE_UNDERLAY_FRAGMENT)
	GUILD_EVENTS_SCENE:AddFragment(GUILD_WINDOW_SOUNDS)
	GUILD_EVENTS_SCENE:AddFragment(FRAME_TARGET_BLUR_STANDARD_RIGHT_PANEL_FRAGMENT)
	GUILD_EVENTS_SCENE:AddFragment(FRAME_TARGET_STANDARD_RIGHT_PANEL_FRAGMENT)
	GUILD_EVENTS_SCENE:AddFragment(GUILD_SELECTOR_FRAGMENT)
	GUILD_EVENTS_SCENE:AddFragment(DISPLAY_NAME_FRAGMENT)
	GUILD_EVENTS_SCENE:AddFragment(GUILD_SHARED_INFO_FRAGMENT)
	GUILD_EVENTS_SCENE:AddFragment(FRAME_EMOTE_FRAGMENT_SOCIAL)
	GUILD_EVENTS_SCENE:AddFragment(FRAME_PLAYER_FRAGMENT)
	GUILD_EVENTS_SCENE:AddFragment(PLAYER_PROGRESS_BAR_FRAGMENT)
	GUILD_EVENTS_SCENE:AddFragment(PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT)
	GUILD_EVENTS_SCENE:AddFragment(GUILD_SELECTOR_ACTION_LAYER_FRAGMENT)

    --GuildEvents Fragments
	GUILD_EVENTS_SCENE:AddFragment(GUILD_EVENTS_EVENTS_FRAGMENT)
	GUILD_EVENTS_SCENE:AddFragment(GUILD_EVENTS_CREATE_FRAGMENT)

	local sceneGroupInfo = MAIN_MENU_KEYBOARD.sceneGroupInfo["guildsSceneGroup"]
	local iconData = sceneGroupInfo.menuBarIconData

	iconData[#iconData + 1] = {
		categoryName = SI_GUILD_EVENTS,
		descriptor = sceneName,
		normal = "esoui/art/Contacts/tabIcon_friends_up.dds",
		pressed = "esoui/art/Contacts/tabIcon_friends_down.dds",
		highlight = "esoui/art/Contacts/tabIcon_friends_over.dds",
	}

	local sceneGroupBarFragment = sceneGroupInfo.sceneGroupBarFragment
	GUILD_EVENTS_SCENE:AddFragment(sceneGroupBarFragment)

	local scenegroup = SCENE_MANAGER:GetSceneGroup("guildsSceneGroup")
	scenegroup:AddScene(sceneName)

	MAIN_MENU_KEYBOARD:AddRawScene(sceneName, MENU_CATEGORY_GUILDS, MAIN_MENU_KEYBOARD.categoryInfo[MENU_CATEGORY_GUILDS], "guildsSceneGroup")
end



