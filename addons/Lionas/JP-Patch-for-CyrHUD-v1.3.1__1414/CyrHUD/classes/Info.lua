-- This file is part of CyrHUD
--
-- (C) 2015 Scott Yeskie (Sasky)
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

CyrHUD = CyrHUD or {}

local AD = ALLIANCE_ALDMERI_DOMINION
local DC = ALLIANCE_DAGGERFALL_COVENANT
local EP = ALLIANCE_EBONHEART_PACT

CyrHUD.colors = {}
local colors = CyrHUD.colors
--Transparent BG colors
colors.blackTrans = ZO_ColorDef:New(0, 0, 0, .3)
colors.greenTrans = ZO_ColorDef:New(.2, .5, .2, .6)
colors.greyTrans = ZO_ColorDef:New(.5, .5, .5, .3)
colors.invisible = ZO_ColorDef:New(0,0,0,0)
colors.redTrans = ZO_ColorDef:New(.5, 0, 0, .3)
colors.blue = ZO_ColorDef:New(.408, .560, .698, 1)
colors.green = ZO_ColorDef:New(.6222, .7, .4532, 1)
colors.orange = ZO_ColorDef:New(.9, .65, .3, 1)
colors.purple = ZO_ColorDef:New(.7, .4, .73, 1)
colors.red = ZO_ColorDef:New(.871, .361, .310, 1)
colors.white = ZO_ColorDef:New(.8, .8, .8, 1)
colors.yellow = ZO_ColorDef:New(.765, .667, .290, 1)

CyrHUD.info = {}
CyrHUD.info.underAttack = "/esoui/art/mappins/ava_attackburst_64.dds"
CyrHUD.info.defendedColor = colors.greenTrans
CyrHUD.info.newAttackColor = colors.redTrans
CyrHUD.info.endAttackColor = colors.greyTrans
CyrHUD.info.defaultBGColor = colors.blackTrans
CyrHUD.info.invisColor = colors.invisible
CyrHUD.info.fontMain = GetString(SI_CYRHUD_FONT)
CyrHUD.info[ALLIANCE_NONE] = {}
CyrHUD.info[ALLIANCE_NONE].color = colors.white
CyrHUD.info[AD] = {}
CyrHUD.info[AD].color = colors.yellow
CyrHUD.info[AD].opcolor = colors.purple
CyrHUD.info[AD].flag = "/esoui/art/ava/ava_allianceflag_aldmeri.dds"
CyrHUD.info[DC] = {}
CyrHUD.info[DC].color = colors.blue
CyrHUD.info[DC].opcolor = colors.orange
CyrHUD.info[DC].flag = "/esoui/art/ava/ava_allianceflag_daggerfall.dds"
CyrHUD.info[EP] = {}
CyrHUD.info[EP].color = colors.red
CyrHUD.info[EP].opcolor = colors.green
CyrHUD.info[EP].flag = "/esoui/art/ava/ava_allianceflag_ebonheart.dds"
CyrHUD.icons = {}
CyrHUD.icons[KEEPTYPE_KEEP] = "/esoui/art/mappins/ava_largekeep_neutral.dds"
CyrHUD.icons[KEEPTYPE_OUTPOST] = "/esoui/art/mappins/ava_outpost_neutral.dds"
CyrHUD.icons[KEEPTYPE_IMPERIAL_CITY_DISTRICT] = "/esoui/art/mappins/ava_imperialdistrict_neutral.dds"
CyrHUD.icons[10 + RESOURCETYPE_FOOD] = "/esoui/art/mappins/ava_farm_neutral.dds"
CyrHUD.icons[10 + RESOURCETYPE_ORE] = "/esoui/art/mappins/ava_mine_neutral.dds"
CyrHUD.icons[10 + RESOURCETYPE_WOOD] = "/esoui/art/mappins/ava_lumbermill_neutral.dds"
--For no icon fallback
setmetatable(CyrHUD.icons, {__index = function(_,k)
    CyrHUD:error("Bad icon lookup: " .. k)
    return "/esoui/art/mappins/ava_largekeep_neutral.dds"
end})
--/esoui/art/campaign/overview_scrollicon_aldmeri.dds
--/esoui/art/campaign/overview_scrollicon_daggefall.dds
--/esoui/art/campaign/overview_scrollicon_ebonheart.dds
