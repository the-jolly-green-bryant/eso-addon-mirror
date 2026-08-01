-- This file is part of AutoInvite
--
-- (C) 2016 Scott Yeskie (Sasky)
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

AutoInviteUI = AutoInviteUI or {}

--local keybindStripDescriptor =
--{
--    alignment = KEYBIND_STRIP_ALIGN_CENTER,
--
--    -- Invite to Group
--    {
--        name = GetString(SI_GROUP_WINDOW_INVITE_PLAYER),
--        keybind = "UI_SHORTCUT_PRIMARY",
--
--        callback = function()
--            ZO_Dialogs_ShowDialog("GROUP_INVITE")
--        end,
--
--        visible = function()
--            --return not self.playerIsGrouped or (self.playerIsLeader and self.groupSize < GROUP_SIZE_MAX)
--            return (GetGroupSize() <= AutoInvite.cfg.maxSize)
--        end
--    },
--
--    -- Start Search
--    {
--        name = GetString(SI_GROUPING_TOOLS_PANEL_START_SEARCH),
--        keybind = "UI_SHORTCUT_SECONDARY",
--
--        callback = function()
--            AutoInvite.startListening()
--        end,
--
--        visible = function()
--            return not AutoInvite.enabled
--        end
--    },
--
--    -- Cancel Search
--    {
--        name = GetString(SI_GROUP_WINDOW_CANCEL_SEARCH),
--        keybind = "UI_SHORTCUT_NEGATIVE",
--
--        callback = function()
--            AutoInvite.disable()
--        end,
--
--        visible = function()
--            return AutoInvite.enabled
--        end
--    },
--}
--
--local function manageKeybinds(_, newState)
--    if(newState == SCENE_SHOWING) then
--        KEYBIND_STRIP:AddKeybindButtonGroup(keybindStripDescriptor)
--    elseif(newState == SCENE_HIDDEN) then
--        KEYBIND_STRIP:RemoveKeybindButtonGroup(keybindStripDescriptor)
--    end
--end

function AutoInviteUI:CreateScene()
    --AUTO_INVITE_SCENE = ZO_Scene:New("autoInvite", SCENE_MANAGER)
    --AUTO_INVITE_SCENE:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
    --AUTO_INVITE_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
    --AUTO_INVITE_SCENE:AddFragment(RIGHT_BG_FRAGMENT)
    --AUTO_INVITE_SCENE:AddFragment(DISPLAY_NAME_FRAGMENT)
    --AUTO_INVITE_SCENE:AddFragment(TITLE_FRAGMENT)
    --AUTO_INVITE_SCENE:AddFragment(GROUP_TITLE_FRAGMENT)
    --AUTO_INVITE_SCENE:AddFragment(GROUP_MEMBERS_FRAGMENT)
    --AUTO_INVITE_SCENE:AddFragment(GROUP_WINDOW_SOUNDS)
    --AUTO_INVITE_SCENE:AddFragment(PLAYER_PROGRESS_BAR_FRAGMENT)
    --AUTO_INVITE_SCENE:AddFragment(PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT)

    --AutoInvite Fragments
    --AUTO_INVITE_SCENE:AddFragment(AI_SMALL_GROUP_LIST_FRAGMENT)
    --AUTO_INVITE_SCENE:AddFragment(AUTO_INVITE_OPTIONS_FRAGMENT)
    --AUTO_INVITE_SCENE:AddFragment(AUTO_INVITE_ENABLED_FRAGMENT)

    local data =
    {
        name = GetString(SI_AUTO_INVITE),
        categoryFragment = AI_SMALL_GROUP_LIST_FRAGMENT,
        normalIcon = "EsoUI/Art/Campaign/campaign_tabIcon_summary_up.dds",
        pressedIcon = "EsoUI/Art/Campaign/campaign_tabIcon_summary_down.dds",
        mouseoverIcon = "EsoUI/Art/Campaign/campaign_tabIcon_summary_over.dds",
    }
    GROUP_MENU_KEYBOARD:AddCategory(data)

--    local mainMenu = GetAPIVersion() <= 100012 and MAIN_MENU or MAIN_MENU_KEYBOARD
--
--    local indx = #mainMenu.sceneGroupInfo.groupSceneGroup.menuBarIconData + 1
--    mainMenu.sceneGroupInfo.groupSceneGroup.menuBarIconData[indx] = {
--        categoryName = SI_AUTO_INVITE,
--        descriptor = "autoInvite",
--        normal = "EsoUI/Art/Campaign/campaign_tabIcon_summary_up.dds",
--        pressed = "EsoUI/Art/Campaign/campaign_tabIcon_summary_down.dds",
--        highlight = "EsoUI/Art/Campaign/campaign_tabIcon_summary_over.dds",
--    }
--
--    SCENE_MANAGER:GetSceneGroup("groupSceneGroup").scenes[indx] = "autoInvite"
--    AUTO_INVITE_SCENE:AddFragment(ZO_FadeSceneFragment:New(mainMenu.sceneGroupBar))
--
----    AUTO_INVITE_SCENE:RegisterCallback("StateChange", manageKeybinds)
--
--    --TODO: Constant for the magic number?
--    mainMenu:AddRawScene("autoInvite", 6, mainMenu.categoryInfo[6], "groupSceneGroup")
end
