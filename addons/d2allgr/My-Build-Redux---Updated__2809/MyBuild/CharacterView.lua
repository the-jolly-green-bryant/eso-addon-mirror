-- The MIT License (MIT)
-- Copyright (c) 2015 Eugene Aksenov (e.aksenov@gmail.com)
-- Copyright (c) 2016 Eugene Aksenov, @Dr_Z (ESO NA Server)
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

-------------------------------------------------------------------------------
-- Part of main window to view main player information
-------------------------------------------------------------------------------

MyBuild.CharacterView = {}

local WM = WINDOW_MANAGER

function MyBuild.CharacterView:Create(parent)
    self.box = MyBuild.UI2.Box(parent, 400, 27)
    WM:CreateControlFromVirtual("NameBackdrop", self.box, "ZO_DefaultBackdrop")
    self.box:SetAnchor(TOP, parent, TOP, 0, -10)

    self.name = MyBuild.UI2.Label("Character's name it may be long", "ZoFontWinH1",  self.box)
    self.name:SetAnchor(TOP, self.box, TOP, 0, -5)

    self.info = MyBuild.UI2.Label("- - - - - -", "ZoFontWinH4", self.box)
    self.info:SetAnchor(TOP, self.box, BOTTOM, 0, 7)
end

function MyBuild.CharacterView:UpdateCharacterInfo(char)
    self.name:SetText(char.name)
    self.name:SetColor(1, 0.98, 0.8,1)

    local level = ""
--    local cpRank = ""

    if char.isVeteran then
--	if char.veteranRank >= 561 then
--	     cpRank = 561
--	     level = "|t24:24:" ..GetChampionPointsIcon().. "|t"..cpRank.." -"
--	else
	     level = "|t24:24:" ..GetChampionPointsIcon().. "|t"..char.veteranRank.." -"
--	end
    else
        level = ""..char.level.." -"
    end

    local supernatural = ""
    if char.werewolf then
      supernatural = "- "..MyBuild.LANG.Werewolf
    elseif char.vampire then
      supernatural = "- "..MyBuild.LANG.Vampire
    end

    self.info:SetText(string.format("%s  %s  %s  %s", level, char.class, char.race, supernatural))
    self.info:SetColor(1, 0.98, 0.8,1)

end
