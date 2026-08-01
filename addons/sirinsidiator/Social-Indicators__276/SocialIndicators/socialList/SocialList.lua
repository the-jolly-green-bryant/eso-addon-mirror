local function InitSocialList(db, saveData)
    local socialListFragment = SocialIndicators.SocialListFragment:New(db)
    SocialIndicators.SocialListRow_OnMouseEnter = function(control)
        socialListFragment:OnRowEnter(control)
    end
    SocialIndicators.SocialListRow_OnMouseExit = function(control)
        socialListFragment:OnRowExit(control)
    end
    SocialIndicators.SocialListRow_OnMouseUp = function(control, button, upInside)
        local data = ZO_ScrollList_GetData(control)
        CALLBACK_MANAGER:FireCallbacks("SocialIndicatorsPlayerChanged", data.player)
        CALLBACK_MANAGER:FireCallbacks("SocialIndicatorsCharacterChanged", data.character)
        MAIN_MENU_KEYBOARD:ShowScene("playerDetails")
    end
    SocialIndicators.SocialListRowNote_OnMouseEnter = function(control)
    -- show note tooltip
    end
    SocialIndicators.SocialListRowNote_OnMouseExit = function(control)
    -- hide note tooltip
    end
    SocialIndicators.SocialListRowNote_OnClicked = function(control)
    -- open note editor
    end
    SocialIndicators.slf = socialListFragment

    local playersOnline = SocialIndicators.PlayersOnlineFragment:New(socialListFragment)

    local sceneName = "socialList"
    local SOCIAL_LIST_SCENE = ZO_Scene:New(sceneName, SCENE_MANAGER)
    SOCIAL_LIST_SCENE:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
    SOCIAL_LIST_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
    SOCIAL_LIST_SCENE:AddFragmentGroup(FRAGMENT_GROUP.PLAYER_PROGRESS_BAR_KEYBOARD_CURRENT)
    SOCIAL_LIST_SCENE:AddFragment(RIGHT_BG_FRAGMENT)
    SOCIAL_LIST_SCENE:AddFragment(socialListFragment.fragment)
    SOCIAL_LIST_SCENE:AddFragment(DISPLAY_NAME_FRAGMENT)
    SOCIAL_LIST_SCENE:AddFragment(TITLE_FRAGMENT)
    SOCIAL_LIST_SCENE:AddFragment(CONTACTS_TITLE_FRAGMENT)
    SOCIAL_LIST_SCENE:AddFragment(FRAME_EMOTE_FRAGMENT_SOCIAL)
    SOCIAL_LIST_SCENE:AddFragment(CONTACTS_WINDOW_SOUNDS)
    SOCIAL_LIST_SCENE:AddFragment(playersOnline.fragment)

    SOCIAL_LIST_SCENE:RegisterCallback("StateChange",  function(oldState, newState)
        if(newState == SCENE_SHOWING) then
            socialListFragment:RefreshData()
        end
    end)

    SocialIndicators.InjectContactsMenuTab(sceneName, SI_GAMEPAD_WORLD_MAP_TOOLTIP_CATEGORY_PLAYERS, "EsoUI/Art/Guild/tabIcon_roster_%s.dds")
end

SocialIndicators.InitSocialList = InitSocialList
