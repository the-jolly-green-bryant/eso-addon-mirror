GuildEventsUI = GuildEventsUI or {}

function GuildEventsUI:CreateScene()
    GUILD_EVENTS_SCENE = ZO_Scene:New("guildEvents", SCENE_MANAGER)

    GUILD_EVENTS_SCENE:AddFragment(GUILD_SELECTOR_FRAGMENT)
    GUILD_EVENTS_SCENE:AddFragment(RIGHT_BG_FRAGMENT)
    GUILD_EVENTS_SCENE:AddFragment(TREE_UNDERLAY_FRAGMENT)
    GUILD_EVENTS_SCENE:AddFragment(DISPLAY_NAME_FRAGMENT)
    GUILD_EVENTS_SCENE:AddFragment(GUILD_SHARED_INFO_FRAGMENT)
    GUILD_EVENTS_SCENE:AddFragment(GUILD_WINDOW_SOUNDS)
    GUILD_EVENTS_SCENE:AddFragment(FRAME_EMOTE_FRAGMENT_SOCIAL)
    GUILD_EVENTS_SCENE:AddFragment(GUILD_SELECTOR_ACTION_LAYER_FRAGMENT)
    GUILD_EVENTS_SCENE:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
    GUILD_EVENTS_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)

    --GuildEvents Fragments
    GUILD_EVENTS_SCENE:AddFragment(GUILD_EVENTS_EVENTS_FRAGMENT)
    GUILD_EVENTS_SCENE:AddFragment(GUILD_EVENTS_CREATE_FRAGMENT)

    local mainMenu = GetAPIVersion() <= 100012 and MAIN_MENU or MAIN_MENU_KEYBOARD
    local indx = #mainMenu.sceneGroupInfo.guildsSceneGroup.menuBarIconData + 1

    mainMenu.sceneGroupInfo.guildsSceneGroup.menuBarIconData[indx] = {
        categoryName = SI_GUILD_EVENTS,
        descriptor = "guildEvents",
        normal = "/esoui/art/inventory/inventory_tabicon_quest_up.dds",
        pressed = "/esoui/art/inventory/inventory_tabicon_quest_down.dds",
        highlight = "/esoui/art/inventory/inventory_tabicon_quest_over.dds",
    }

    SCENE_MANAGER:GetSceneGroup("guildsSceneGroup").scenes[indx] = "guildEvents"
    GUILD_EVENTS_SCENE:AddFragment(ZO_FadeSceneFragment:New(mainMenu.sceneGroupBar))
    mainMenu:AddRawScene("guildEvents", 11, mainMenu.categoryInfo[11], "guildsSceneGroup")
end
