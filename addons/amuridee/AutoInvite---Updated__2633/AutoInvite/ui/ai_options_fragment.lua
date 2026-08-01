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
AutoInviteUI.fragmentOptions = {}
local ui = AutoInviteUI.fragmentOptions
local wm = WINDOW_MANAGER

function AutoInviteUI:CreateOptionFragment()
    ui.main = wm:CreateControl("AutoInviteOptions", AI_SmallGroupList, CT_CONTROL) --wm:CreateTopLevelWindow("AutoInviteOptionsFragment")

    ui.scroll = ui.main -- For using LAM controls
    ui.main:SetAnchor(TOPRIGHT, ZO_GroupList, TOPRIGHT, -40, 45)
    --ui.main:SetHidden(true)
	
    -- LAMr18 bugfix
    ui.main:SetWidth(340)
    ui.panel = ui.main
    ui.panel.data = {}
    -- End LAMr18 bugfix


    ui.max = LAMCreateControl.slider(ui.main, {
        type = "slider",
        name = GetString(SI_AUTO_INVITE_OPT_MAX_SIZE),
        tooltip = GetString(SI_AUTO_INVITE_TT_MAX_SIZE),
        min = 4,
        max = 12,
        getFunc = function() return AutoInvite.cfg.maxSize end,
        setFunc = function(val) AutoInvite.cfg.maxSize = val end,
        default = 12,
    })
    -- Was anchored to ui.text, which is never created in this file (that control
    -- only exists on AutoInviteUI.fragmentEnabled, in ai_enabled_fragment.lua --
    -- looks like a copy-paste leftover). This function is currently dead code
    -- (CreateOptionFragment() is never called), but anchoring to ui.main keeps
    -- it self-consistent if it's ever re-enabled.
    ui.max:SetAnchor(TOPLEFT, ui.main, TOPLEFT, 60, 20)

    ui.restart = LAMCreateControl.checkbox(ui.main, {
        type = "checkbox",
        name = GetString(SI_AUTO_INVITE_OPT_RESTART),
        tooltip = GetString(SI_AUTO_INVITE_TT_RESTART),
        getFunc = function() return AutoInvite.cfg.restart end,
        setFunc = function(val) AutoInvite.cfg.restart = val end,
    })
    --ui.restart.checkbox:SetAnchor(LEFT, ui.restart.container, RIGHT, -25, 0)
    ui.restart:SetAnchor(TOPLEFT, ui.max, BOTTOMLEFT, 0, 10)

    ui.cyr = LAMCreateControl.checkbox(ui.main, {
        type = "checkbox",
        name = GetString(SI_AUTO_INVITE_OPT_CYRCHECK),
        tooltip = GetString(SI_AUTO_INVITE_TT_CYRCHECK),
        getFunc = function() return AutoInvite.cfg.cyrCheck end,
        setFunc = function(val) AutoInvite.cfg.cyrCheck = val end,
    })
    --ui.cyr.checkbox:SetAnchor(LEFT, ui.cyr.container, RIGHT, -25, 0)
    ui.cyr:SetAnchor(TOPLEFT, ui.restart, BOTTOMLEFT, 0, 10)

    ui.kick = LAMCreateControl.checkbox(ui.main, {
        type = "checkbox",
        name = GetString(SI_AUTO_INVITE_OPT_KICK),
        tooltip = GetString(SI_AUTO_INVITE_TT_KICK),
        getFunc = function() return AutoInvite.cfg.autoKick end,
        setFunc = function(val) AutoInvite.cfg.autoKick = val end,
    })
    --ui.kick.checkbox:SetAnchor(LEFT, ui.kick.container, RIGHT, -25, 0)
    ui.kick:SetAnchor(TOPLEFT, ui.cyr, BOTTOMLEFT, 0, 10)

    ui.kickTime = LAMCreateControl.slider(ui.main, {
        type = "slider",
        name = GetString(SI_AUTO_INVITE_OPT_KICK_TIME),
        tooltip = GetString(SI_AUTO_INVITE_TT_KICK_TIME),
        min = 5,
        max = 600,
        getFunc = function() return AutoInvite.cfg.kickDelay end,
        setFunc = function(val) AutoInvite.cfg.kickDelay = val end,
        default = 300,
    })
    ui.kickTime:SetAnchor(TOPLEFT, ui.kick, BOTTOMLEFT, 0, 10)

    ui.regroup = wm:CreateControlFromVirtual(nil, ui.main, "ZO_DefaultButton")
    ui.regroup:SetAnchor(TOPLEFT, ui.kickTime, BOTTOMLEFT, -10, 10)
    ui.regroup:SetWidth(160)
    ui.regroup:SetText(GetString(SI_AUTO_INVITE_BTN_REFORM))
    ui.regroup:SetHandler("OnClicked", function() AutoInvite:resetGroup() end)

    ui.invite = wm:CreateControlFromVirtual(nil, ui.main, "ZO_DefaultButton")
    ui.invite:SetAnchor(LEFT, ui.regroup, RIGHT, 10, 0)
    ui.invite:SetWidth(160)
    ui.invite:SetText(GetString(SI_AUTO_INVITE_BTN_REINVITE))
    ui.invite:SetHandler("OnClicked", function() AutoInvite:inviteGroup() end)
	
	
	
	
	


	

    --AUTO_INVITE_OPTIONS_FRAGMENT = ZO_FadeSceneFragment:New(ui.main)
end
