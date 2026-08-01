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
local ui = AutoInviteUI

function AutoInviteUI.refresh()
    ui.fragmentEnabled.enabled:UpdateValue()
    ui.fragmentEnabled.text:UpdateValue()
    ui.fragmentOptions.cyr:UpdateValue()
    ui.fragmentOptions.restart:UpdateValue()
    ui.fragmentOptions.kick:UpdateValue()
    ui.fragmentOptions.kickTime:UpdateValue()
    ui.fragmentOptions.max:UpdateValue()
end

function AutoInviteUI.init()
    if ui.created then return end
    ui.created = true
    AutoInviteUI:CreateEnabledFragment()
    AutoInviteUI:CreateOptionFragment()
    AutoInviteUI:CreateScene()
end
