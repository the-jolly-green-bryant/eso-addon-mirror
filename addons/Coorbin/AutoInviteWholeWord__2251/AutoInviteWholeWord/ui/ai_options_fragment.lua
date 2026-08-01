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

    ui.max = LAMCreateControl.slider(ui, {
        type = "slider",
        name = GetString(SI_AUTO_INVITE_OPT_MAX_SIZE),
        tooltip = GetString(SI_AUTO_INVITE_TT_MAX_SIZE),
        min = 4,
        max = 24,
        getFunc = function() return AutoInvite.cfg.maxSize end,
        setFunc = function(val) AutoInvite.cfg.maxSize = val end,
        default = 24,
    })
    ui.max:SetAnchor(TOPRIGHT, ui.main, TOPRIGHT, 0, 15)

    ui.restart = LAMCreateControl.checkbox(ui, {
        type = "checkbox",
        name = GetString(SI_AUTO_INVITE_OPT_RESTART),
        tooltip = GetString(SI_AUTO_INVITE_TT_RESTART),
        getFunc = function() return AutoInvite.cfg.restart end,
        setFunc = function(val) AutoInvite.cfg.restart = val end,
    })
    ui.restart.checkbox:SetAnchor(LEFT, ui.restart.container, RIGHT, -25, 0)
    ui.restart:SetAnchor(TOPLEFT, ui.max, BOTTOMLEFT, 0, 15)

    ui.cyr = LAMCreateControl.checkbox(ui, {
        type = "checkbox",
        name = GetString(SI_AUTO_INVITE_OPT_CYRCHECK),
        tooltip = GetString(SI_AUTO_INVITE_TT_CYRCHECK),
        getFunc = function() return AutoInvite.cfg.cyrCheck end,
        setFunc = function(val) AutoInvite.cfg.cyrCheck = val end,
    })
    ui.cyr.checkbox:SetAnchor(LEFT, ui.cyr.container, RIGHT, -25, 0)
    ui.cyr:SetAnchor(TOPLEFT, ui.restart, BOTTOMLEFT, 0, 15)

    ui.kick = LAMCreateControl.checkbox(ui, {
        type = "checkbox",
        name = GetString(SI_AUTO_INVITE_OPT_KICK),
        tooltip = GetString(SI_AUTO_INVITE_TT_KICK),
        getFunc = function() return AutoInvite.cfg.autoKick end,
        setFunc = function(val) AutoInvite.cfg.autoKick = val end,
    })
    ui.kick.checkbox:SetAnchor(LEFT, ui.kick.container, RIGHT, -25, 0)
    ui.kick:SetAnchor(TOPLEFT, ui.cyr, BOTTOMLEFT, 0, 15)

    ui.kickTime = LAMCreateControl.slider(ui, {
        type = "slider",
        name = GetString(SI_AUTO_INVITE_OPT_KICK_TIME),
        tooltip = GetString(SI_AUTO_INVITE_TT_KICK_TIME),
        min = 5,
        max = 600,
        getFunc = function() return AutoInvite.cfg.kickDelay end,
        setFunc = function(val) AutoInvite.cfg.kickDelay = val end,
        default = 300,
    })
    ui.kickTime:SetAnchor(TOPLEFT, ui.kick, BOTTOMLEFT, 0, 15)

    ui.regroup = wm:CreateControlFromVirtual(nil, ui.main, "ZO_DefaultButton")
    ui.regroup:SetAnchor(TOPLEFT, ui.kickTime, BOTTOMLEFT, 70, 70)
    ui.regroup:SetWidth(160)
    ui.regroup:SetText(GetString(SI_AUTO_INVITE_BTN_REFORM))
    ui.regroup:SetHandler("OnClicked", function() AutoInvite:resetGroup() end)

    ui.invite = wm:CreateControlFromVirtual(nil, ui.main, "ZO_DefaultButton")
    ui.invite:SetAnchor(TOPLEFT, ui.kickTime, BOTTOMLEFT, 70, 105)
    ui.invite:SetWidth(160)
    ui.invite:SetText(GetString(SI_AUTO_INVITE_BTN_REINVITE))
    ui.invite:SetHandler("OnClicked", function() AutoInvite:inviteGroup() end)

    local slashcmds = GetString(SI_AUTO_INVITE_SLASHCMD_START) ..
            "\n" .. GetString(SI_AUTO_INVITE_SLASHCMD_HELP) ..
            "\n" .. GetString(SI_AUTO_INVITE_SLASHCMD_STOP)
    ui.note = LAMCreateControl.description(ui, {
        type = "description",
        title = GetString(SI_AUTO_INVITE_OPT_SLASHCMD),
        text = slashcmds,
    })
    ui.note:SetAnchor(BOTTOMRIGHT, ZO_GroupList, BOTTOMRIGHT, 0, -40)
    ui.note.desc:SetColor(.7, .7, .7, 1)

    --AUTO_INVITE_OPTIONS_FRAGMENT = ZO_FadeSceneFragment:New(ui.main)
end
