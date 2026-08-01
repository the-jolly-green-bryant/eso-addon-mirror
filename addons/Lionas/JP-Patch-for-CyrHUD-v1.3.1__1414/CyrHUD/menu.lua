-- This file is part of CyrHUD
--
-- (C) 2015 Scott Yeskie (Sasky)
--
-- This p.rogram is free software; you can redistribute it and/or modify
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

CyrHUD = CyrHUD or {}
CyrHUD.menuPanel = {
    type = "panel",
    name = "CyrHUD",
    author = "Sasky",
    version = "1.1.0",
}

CyrHUD.menuOptions = {
    {
        type = "checkbox",
        name = GetString(SI_CYRHUD_QT_DEFAULT),
        tooltip = GetString(SI_CYRHUD_QT_TOOLTIP),
        getFunc = function() return CyrHUD.cfg.zosTrackerDisable or false end,
        setFunc = function(v) CyrHUD.cfg.zosTrackerDisable = v end
    },
    {
        type = "checkbox",
        name = GetString(SI_CYRHUD_QT_WYKKYD),
        tooltip = GetString(SI_CYRHUD_QT_TOOLTIP),
        getFunc = function() return CyrHUD.cfg.trackerDisable or false end,
        setFunc = function(v) CyrHUD.cfg.trackerDisable = v end
    },
    {
        type = "checkbox",
        name = GetString(SI_CYRHUD_POPBAR),
        tooltip = GetString(SI_CYRHUD_POPBAR_INFO),
        getFunc = function() return CyrHUD.cfg.showPopBars or false end,
        setFunc = function(v) CyrHUD.cfg.showPopBars = v; CyrHUD:reconfigureLabels() end,
    },
    {
        type = "checkbox",
        name = GetString(SI_CYRHUD_HIDE_IC),
        tooltip = GetString(SI_CYRHUD_HIDE_IC_INFO),
        getFunc = function() return CyrHUD.cfg.hideImpBattles or false end,
        setFunc = function(v) CyrHUD.cfg.hideImpBattles = v; CyrHUD:reconfigureLabels() end
    },
    {
        type = "description",
        title = GetString(SI_CYRHUD_KEYBIND_HEADER),
        text = GetString(SI_CYRHUD_KEYBIND_DESC)
    }
}
