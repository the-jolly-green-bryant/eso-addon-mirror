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

    -- ui.refreshList = wm:CreateControlFromVirtual(nil, ui.main, "ZO_DefaultButton")
    -- ui.refreshList:SetAnchor(TOP, AI_SmallGroupList, TOP, -50, 30)
    -- ui.refreshList:SetWidth(180)
    -- ui.refreshList:SetText(GetString(SI_AUTO_INVITE_BTN_REFRESH))
    -- ui.refreshList:SetHandler("OnClicked", function() MINI_GROUP_LIST:RefreshData() end)
	
	ui.settings = wm:CreateControlFromVirtual(nil, ui.main, "ZO_DefaultButton")
    ui.settings:SetAnchor(TOP, AI_SmallGroupList, TOP, -50, 30)
    ui.settings:SetWidth(160)
    ui.settings:SetText(GetString(SI_AUTO_INVITE_OTHER_SETTINGS))
    ui.settings:SetHandler("OnClicked", function() LibAddonMenu2:OpenToPanel(AutoInvite.Pannel) end)

    ui.regroup = wm:CreateControlFromVirtual(nil, ui.main, "ZO_DefaultButton")
    ui.regroup:SetAnchor(LEFT, ui.settings, RIGHT, 10, 0)
    ui.regroup:SetWidth(160)
    ui.regroup:SetText(GetString(SI_AUTO_INVITE_BTN_REFORM))
    ui.regroup:SetHandler("OnClicked", function() AutoInvite:resetGroup() end)

    ui.invite = wm:CreateControlFromVirtual(nil, ui.main, "ZO_DefaultButton")
    ui.invite:SetAnchor(LEFT, ui.regroup, RIGHT, 10, 0)
    ui.invite:SetWidth(160)
    ui.invite:SetText(GetString(SI_AUTO_INVITE_BTN_REINVITE))
    ui.invite:SetHandler("OnClicked", function() AutoInvite:inviteGroup() end)
	

	

	
	

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
    ui.enabled:SetAnchor(TOP, ui.invite, BOTTOM, 0, 10)

    --TODO: Sanity check between enable and blank string
    ui.text = LAMCreateControl.editbox(ui, {
        type = "editbox",
        name = GetString(SI_AUTO_INVITE_OPT_STRING),
        tooltip = GetString(SI_AUTO_INVITE_TT_STRING),
        getFunc = function() return AutoInvite.cfg.watchStr end,
        setFunc = function(val) AutoInvite.cfg.watchStr = string.lower(val) end,
    })
    ui.text.container:SetWidth(140)
    ui.text:SetAnchor(TOP, ui.enabled, BOTTOM, 0, 10)
	
	
	    local slashcmds = GetString(SI_AUTO_INVITE_SLASHCMD_START) ..
            "\n" .. GetString(SI_AUTO_INVITE_SLASHCMD_HELP) ..
            "\n" .. GetString(SI_AUTO_INVITE_SLASHCMD_STOP)
    ui.note = LAMCreateControl.description(ui, {
        type = "description",
        title = GetString(SI_AUTO_INVITE_OPT_SLASHCMD),
        text = slashcmds,
    })
    ui.note:SetAnchor(TOP, ui.text, BOTTOM, 0, 10)
    ui.note.desc:SetColor(.7, .7, .7, 1)
	
	
	
	
	--AUTO_INVITE_ENABLED_FRAGMENT = ZO_FadeSceneFragment:New(ui.main)
	
	

	
	
end
