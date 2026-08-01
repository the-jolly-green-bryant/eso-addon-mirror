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
AutoInviteUI.fragmentEnabled = {}
local ui = AutoInviteUI.fragmentEnabled
local wm = WINDOW_MANAGER

function AutoInviteUI:CreateEnabledFragment()
    ui.main = wm:CreateControl("AutoInviteEnabled", AI_SmallGroupList, CT_CONTROL) --ui.main = wm:CreateTopLevelWindow("AutoInviteEnabledFragment")
    ui.scroll = ui.main -- For using LAM controls
    --ui.main:SetHidden(true)
    -- LAMr18 bugfix
    ui.main:SetWidth(340)
    ui.panel = ui.main
    ui.panel.data = {}
    -- End LAMr18 bugfix

    ui.refreshList = wm:CreateControlFromVirtual(nil, ui.main, "ZO_DefaultButton")
    ui.refreshList:SetAnchor(TOP, AI_SmallGroupList, TOP, -50, 30)
    ui.refreshList:SetWidth(180)
    ui.refreshList:SetText(GetString(SI_AUTO_INVITE_BTN_REFRESH))
    ui.refreshList:SetHandler("OnClicked", function() MINI_GROUP_LIST:RefreshData() end)

    ui.enabled = LAMCreateControl.checkbox(ui, {
        type = "checkbox",
        name = GetString(SI_AUTO_INVITE_OPT_ENABLED),
        tooltip = GetString(SI_AUTO_INVITE_TT_ENABLED),
        getFunc = function() return AutoInvite.listening end,
        setFunc = function(val)
            if val then AutoInvite.startListening() else AutoInvite.disable() end
        end,
    })
    ui.enabled.checkbox:SetAnchor(LEFT, ui.enabled.container, RIGHT, -25, 0)
    ui.enabled:SetAnchor(TOPRIGHT, ZO_GroupList, TOPRIGHT, -40, -45)

    --TODO: Sanity check between enable and blank string
    ui.text = LAMCreateControl.editbox(ui, {
        type = "editbox",
        name = GetString(SI_AUTO_INVITE_OPT_STRING),
        tooltip = GetString(SI_AUTO_INVITE_TT_STRING),
        getFunc = function() return AutoInvite.cfg.watchStr end,
        setFunc = function(val) AutoInvite.cfg.watchStr = string.lower(val) end,
    })
    ui.text.container:SetWidth(140)
    ui.text:SetAnchor(TOPRIGHT, ZO_GroupList, TOPRIGHT, -40, -15)

    --AUTO_INVITE_ENABLED_FRAGMENT = ZO_FadeSceneFragment:New(ui.main)
end
