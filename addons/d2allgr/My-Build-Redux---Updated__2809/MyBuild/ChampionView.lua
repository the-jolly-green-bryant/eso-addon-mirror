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
-- Part of main window to view  player's champion points information
-------------------------------------------------------------------------------

MyBuild.ChampionView = {}

-- Create main block
function MyBuild.ChampionView:Create(parent)
  MyBuild.ChampionView:SetDefaults()
  self.box = MyBuild.UI2.Box( parent, 400, 400)
  MyBuild.UI2.Offset(self.box, 430, 170)
    self.title = MyBuild.UI2.Label(MyBuild.LANG.UI_ChampionTitle, "ZoFontWinH2", self.box)
  MyBuild.UI2.Offset(self.title, 0, 0)
  self.disciplines = {}

  MyBuild.ChampionView:DisciplineBlock(2, self.box, 0, 30)
  MyBuild.ChampionView:DisciplineBlock(3, self.box, 0, 90)
  MyBuild.ChampionView:DisciplineBlock(4, self.box, 0, 150)
  MyBuild.ChampionView:DisciplineBlock(5, self.box, 0, 220)
  MyBuild.ChampionView:DisciplineBlock(6, self.box, 0, 280)
  MyBuild.ChampionView:DisciplineBlock(7, self.box, 0, 340)
  MyBuild.ChampionView:DisciplineBlock(8, self.box, 0, 410)
  MyBuild.ChampionView:DisciplineBlock(9, self.box, 0, 470)
  MyBuild.ChampionView:DisciplineBlock(1, self.box, 0, 530)
end

-- TODO Set Defaults
function MyBuild.ChampionView:SetDefaults()
  self.defs = {}
  self.defs.width = 400
  --TODO etc
end

-- Create discipline block with skill blocks inside
function MyBuild.ChampionView:DisciplineBlock(disc, parent, shiftX, shiftY)
  self.disciplines[disc] = {}
  self.disciplines[disc].title = MyBuild.UI2.Label("Discipline title", "ZoFontWinH4", parent)
  self.disciplines[disc].title:SetDimensions(400, 20)
  self.disciplines[disc].title:SetAnchor(TOPLEFT, parent, TOPLEFT, shiftX, shiftY)

  self.disciplines[disc].skills = {}
  MyBuild.ChampionView:SkillBlock(disc, 1, parent, shiftX, shiftY, 0, 20)
  MyBuild.ChampionView:SkillBlock(disc, 2, parent, shiftX, shiftY, 0, 40)
  MyBuild.ChampionView:SkillBlock(disc, 3, parent, shiftX, shiftY, 160, 20)
  MyBuild.ChampionView:SkillBlock(disc, 4, parent, shiftX, shiftY, 160, 40)
end

-- Create skill block
function MyBuild.ChampionView:SkillBlock(disc, skill, parent , shiftX, shiftY, skillShiftX, skillShiftY)
  self.disciplines[disc].skills[skill] = {}
  local s = self.disciplines[disc].skills[skill]

  s.name = MyBuild.UI2.Label("Skill title", "ZoFontGameSmall", parent)
  s.name:SetDimensions(130, 20)
  s.name:SetAnchor(TOPLEFT, parent, TOPLEFT, shiftX + skillShiftX, shiftY + skillShiftY)

  s.points = MyBuild.UI2.Label("---", "ZoFontWinH5", parent)
  s.points:SetDimensions(130, 20)
  s.points:SetAnchor(TOPLEFT, parent, TOPLEFT, shiftX + skillShiftX + 130, shiftY + skillShiftY)
end

-- Set color by attribute classification
function MyBuild.ChampionView:SetTitleColor(char, disc)
    if char.championPoints[disc].attribute == 1 then
        self.disciplines[disc].title:SetColor(1.000, 0.000, 0.000, 1) -- red
    elseif char.championPoints[disc].attribute == 2 then
        self.disciplines[disc].title:SetColor(0.255, 0.412, 0.882, 1) -- blue
    elseif char.championPoints[disc].attribute == 3 then
        self.disciplines[disc].title:SetColor(0.133, 0.545, 0.133, 1) -- green
    end
end

-- Set color by skill classification
function MyBuild.ChampionView:SetSkillColor(char, disc, skill)
    if char.championPoints[disc].skills[skill].points == 0 then
        self.disciplines[disc].skills[skill].name:SetColor(0.502, 0.502, 0.502, 0.3) --gray opacity
        self.disciplines[disc].skills[skill].points:SetColor(0.502, 0.502, 0.502, 0.3)
    end
end

-- Update view info
function MyBuild.ChampionView:UpdateCharacterInfo( char)
    --local usableCP = ""
    --local ExtraCP = ""
    --if char.totalChampionPoints >= 810 then
	--usableCP = 810
	-- ExtraCP = string.format(" +%s",char.totalChampionPoints - 810)
    --else
	--usableCP = char.totalChampionPoints
    --end
	
    self.title:SetText(MyBuild.LANG.UI_ChampionTitle..string.format("","",""))
    for d = 1, 9 do
         self.disciplines[d].title:SetText(char.championPoints[d].name)
         MyBuild.ChampionView:SetTitleColor(char, d)
         for s = 1, 4 do
           self.disciplines[d].skills[s].name:SetText(char.championPoints[d].skills[s].name)
           self.disciplines[d].skills[s].points:SetText(char.championPoints[d].skills[s].points)
           MyBuild.ChampionView:SetSkillColor(char, d, s)
         end
    end
end
