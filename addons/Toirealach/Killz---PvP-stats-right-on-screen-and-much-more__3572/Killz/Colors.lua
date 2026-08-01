-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Colorz: A simple API for consistent text coloring in ESO addons 
--
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Version 1.2.0 by Teebow Ganx
-- Copyright (c) 2023 Trailing Zee Productions, LLC.
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- 
-- I don't go through all the hassle of making my common objects used in all my addons be "libraries" 
-- that need to be uploaded to esoui and then downloaded and installed by every player who wants to
-- use my addon. Thats the whole DLL mess Windows got into. 
--
-- Instead I just update the version number of internal libs and the latest version will always be 
-- loaded by one of my addons that include it. 
--
-- If another addon has an older version then the newer one supercedes it always.
-- Now I manage my libraries and not push that bullshit onto players to have to download multiple
-- ZIP files just to use my addon.

local COLORZ_VERSION = 3

if not Colorz or not Colorz.version or Colorz.version < COLORZ_VERSION then

	Colorz =  {

		version	= COLORZ_VERSION,

		red 		= ZO_ColorDef:New("FF1919"), -- bright red
		bloodRed	= ZO_ColorDef:New("D70505"), -- blood red
		darkRed 	= ZO_ColorDef:New("AC0404"), -- red berry
		lightRed 	= ZO_ColorDef:New("DE5B4E"), -- light red
		orange 		= ZO_ColorDef:New("F8631D"), -- orange
		lightOrange = ZO_ColorDef:New("FF8740"), -- light orange
		tangerine 	= ZO_ColorDef:New("FF7C00"), -- tangerine
		gold 		= ZO_ColorDef:New("F1C232"), -- dark yellow 1
		yellow 		= ZO_ColorDef:New("FFFF00"), -- yellow
		lightYellow = ZO_ColorDef:New("FFFF4C"), -- light yellow
		green 		= ZO_ColorDef:New("2ADC22"), -- green
		lightGreen 	= ZO_ColorDef:New("4CFF4C"), -- light green
		teal 		= ZO_ColorDef:New("00CDCD"), -- light teal
		cyan 		= ZO_ColorDef:New("00DEFD"), -- light teal
		lightBlue 	= ZO_ColorDef:New("22ADDC"), -- light blue
		blue 		= ZO_ColorDef:New("0000FF"), -- blue
		purple 		= ZO_ColorDef:New("9900FF"), -- purple
		ltPurple    = ZO_ColorDef:New("A947FD"), -- lighter purple
		magenta 	= ZO_ColorDef:New("FF00FF"), -- magenta
		white 		= ZO_ColorDef:New("FFFFFF"), -- white
		justWhite 	= ZO_ColorDef:New("FAFAFA"), -- just white
		offWhite	= ZO_ColorDef:New("E2E0CE"), -- offWhite
		blueWhite 	= ZO_ColorDef:New("99F3F7"), -- blueWhite
		gray 		= ZO_ColorDef:New("CCCCCC"), -- gray
		darkGray 	= ZO_ColorDef:New("666666"), -- dark gray 3
		black 		= ZO_ColorDef:New("000000"), -- black
		textDefault	= ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_NORMAL), -- #C5C29E tan
		alliance_AD = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_ALLIANCE, ALLIANCE_ALDMERI_DOMINION), -- #C2AA49 dull gold
		alliance_DC = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_ALLIANCE, ALLIANCE_DAGGERFALL_COVENANT), -- #4F81BD powder blue
		alliance_EP = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_ALLIANCE, ALLIANCE_EBONHEART_PACT), -- #DE5B4E faded red
		alliancePts = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_CURRENCY, CURRENCY_COLOR_ALLIANCE_POINTS), -- #2ADC22 green
		telvar 		= ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_CURRENCY, CURRENCY_COLOR_TELVAR_STONES),  -- #5EA4FF another powder blue

		companion 	= ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_UNIT_REACTION_COLOR, UNIT_REACTION_COLOR_COMPANION), -- #EECA2A yellow
		unitDead 	= ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_UNIT_REACTION_COLOR, UNIT_REACTION_COLOR_DEAD), -- #C3C3C3 light grey
		unitDefault = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_UNIT_REACTION_COLOR, UNIT_REACTION_COLOR_DEFAULT), -- #FFFFFF white
		unitFriend 	= ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_UNIT_REACTION_COLOR, UNIT_REACTION_COLOR_FRIENDLY), -- #2ADC22 green
		unitHostile = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_UNIT_REACTION_COLOR, UNIT_REACTION_COLOR_HOSTILE), --  #FF1919 red
		unitIntract = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_UNIT_REACTION_COLOR, UNIT_REACTION_COLOR_INTERACT), -- #DCBA22 gold
		unitNeutral = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_UNIT_REACTION_COLOR, UNIT_REACTION_COLOR_NEUTRAL), -- #DCD822 yellow
		npcAlly 	= ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_UNIT_REACTION_COLOR, UNIT_REACTION_COLOR_NPC_ALLY), -- #2ADC22 green
		playerAlly 	= ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_UNIT_REACTION_COLOR, UNIT_REACTION_COLOR_PLAYER_ALLY), -- #22ADDC light blue

		GetAllianceColor = function(inWhichAlliance)
			local outColor = Colorz.textDefault
			if inWhichAlliance == ALLIANCE_ALDMERI_DOMINION then outColor = Colorz.alliance_AD
			elseif inWhichAlliance == ALLIANCE_DAGGERFALL_COVENANT then outColor = Colorz.alliance_DC
			elseif inWhichAlliance == ALLIANCE_EBONHEART_PACT then outColor = Colorz.alliance_EP
			end
			return outColor
		end,
	}
end