-- The MIT License (MIT)
-- Copyright (c) 2015 Eugene Aksenov
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
-- Part of main window to view attribute player information
-------------------------------------------------------------------------------

MyBuild.AttributeView = {}

-- Create main block
function MyBuild.AttributeView:Create(parent)
    self.box = MyBuild.UI2.Box( parent, 760, 200)
    MyBuild.UI2.Offset(self.box, 0, 40)

    MyBuild.AttributeView:AttributeBox(self.box)
    MyBuild.AttributeView:DerivativeBox(self.box)
end

function MyBuild.AttributeView:AttributeBox(parent)
    local title = MyBuild.UI2.Label(MyBuild.LANG.UI_AttributesTitle, "ZoFontWinH2", parent)
    MyBuild.UI2.Offset(title, 10, 0)

    local box = MyBuild.UI2.Box(parent, 270, 20)
    MyBuild.UI2.Offset(box, 10, 30)

    local label = MyBuild.UI2.Label(MyBuild.LANG.UI_Stat_Header_Attribute, "ZoFontGameSmall", box)
    MyBuild.UI2.Offset(label, 10, 0)

    local points = MyBuild.UI2.Label(MyBuild.LANG.UI_Stat_Header_Points, "ZoFontGameSmall", box)
    MyBuild.UI2.Offset(points, 90, 0)

    local max = MyBuild.UI2.Label(MyBuild.LANG.UI_Stat_Header_Maximum, "ZoFontGameSmall", box)
    MyBuild.UI2.Offset(max, 150, 0)

    local regen = MyBuild.UI2.Label(MyBuild.LANG.UI_Stat_Header_Recovery, "ZoFontGameSmall", box)
    MyBuild.UI2.Offset(regen, 220, 0)

    self.magicka = MyBuild.AttributeView.AttributeLine(MyBuild.LANG.UI_Stat_MagickaLabel, parent, 10, 50)
    self.health = MyBuild.AttributeView.AttributeLine(MyBuild.LANG.UI_Stat_HealthLabel, parent, 10, 70)
    self.stamina = MyBuild.AttributeView.AttributeLine(MyBuild.LANG.UI_Stat_StaminaLabel, parent, 10, 90)
end

function MyBuild.AttributeView.AttributeLine(label, parent, shiftX, shiftY)
    local line = {}

    line.box = MyBuild.UI2.Box(parent, 270, 20)
    MyBuild.UI2.Offset(line.box, shiftX, shiftY)

    line.label = MyBuild.UI2.Label(label, "ZoFontWinH4", line.box)
    MyBuild.UI2.Offset(line.label, 0, 0)

    line.points = MyBuild.UI2.Label("12", "ZoFontWinT1", line.box)
    MyBuild.UI2.Offset(line.points, 100, 0)

    line.max = MyBuild.UI2.Label("12345", "ZoFontWinT1", line.box)
    MyBuild.UI2.Offset(line.max, 160, 0)

    line.regen = MyBuild.UI2.Label("1234", "ZoFontWinT1", line.box)
    MyBuild.UI2.Offset(line.regen, 230, 0)

    return line
end


function MyBuild.AttributeView:DerivativeBox(parent)

    local box = MyBuild.UI2.Box(parent, 270, 20)
    MyBuild.UI2.Offset(box, 330, 52)

    local label = MyBuild.UI2.Label(MyBuild.LANG.UI_Header_DamageType, "ZoFontGameSmall", box)
    MyBuild.UI2.Offset(label, 5, 0)

    local power = MyBuild.UI2.Label(MyBuild.LANG.UI_Header_Damage, "ZoFontGameSmall", box)
    MyBuild.UI2.Offset(power, 100, 0)

    local critical = MyBuild.UI2.Label(MyBuild.LANG.UI_Header_Crit, "ZoFontGameSmall", box)
    MyBuild.UI2.Offset(critical, 170, 0)

    local criticalPercent = MyBuild.UI2.Label(MyBuild.LANG.UI_Header_CritPercent, "ZoFontGameSmall", box)
    MyBuild.UI2.Offset(criticalPercent, 220, 0)

    local penetration = MyBuild.UI2.Label(MyBuild.LANG.UI_Header_Penetration, "ZoFontGameSmall", box)
    MyBuild.UI2.Offset(penetration, 270, 0)

    local resist = MyBuild.UI2.Label(MyBuild.LANG.UI_Header_Resistance, "ZoFontGameSmall", box)
    MyBuild.UI2.Offset(resist, 345, 0)

    self.weapon = MyBuild.AttributeView:DerivativeLine(MyBuild.LANG.UI_Stat_Label_Weapon, parent, 330, 70)
    self.spell = MyBuild.AttributeView:DerivativeLine(MyBuild.LANG.UI_Stat_Label_Spell, parent, 330, 90)

    local mundus = MyBuild.UI2.Label(MyBuild.LANG.UI_Mundus_Label, "ZoFontWinH4", parent)
    MyBuild.UI2.Offset(mundus, 300, 5)

    self.mundus = MyBuild.UI2.Label("", "ZoFontWinT1", parent)
    MyBuild.UI2.Offset(self.mundus, 405, 5)
end

function MyBuild.AttributeView:DerivativeLine(label, parent, shiftX, shiftY)
    local line = {}
    line.box = MyBuild.UI2.Box(parent, 270, 20)
    MyBuild.UI2.Offset(line.box, shiftX, shiftY)

    line.label = MyBuild.UI2.Label(label, "ZoFontWinH4", line.box)
    MyBuild.UI2.Offset(line.label, 0, 0)

    line.power = MyBuild.UI2.Label("1234", "ZoFontWinT1", line.box)

    MyBuild.UI2.Offset(line.power, 100, 0)

    line.critical = MyBuild.UI2.Label("12345", "ZoFontWinT1", line.box)
    MyBuild.UI2.Offset(line.critical, 160, 0)

    line.criticalPercent = MyBuild.UI2.Label("12%", "ZoFontWinT1", line.box)
    MyBuild.UI2.Offset(line.criticalPercent, 220, 0)

    line.penetration = MyBuild.UI2.Label("12345", "ZoFontWinT1", line.box)
    MyBuild.UI2.Offset(line.penetration, 290, 0)

    line.resist = MyBuild.UI2.Label("12345", "ZoFontWinT1", line.box)
    MyBuild.UI2.Offset(line.resist, 350, 0)

    return line
end

function MyBuild.AttributeView:UpdateCharacterInfo(char)
    self.health.points:SetText(char.healthPoints)
    self.health.points:SetColor(1.000, 0.000, 0.000, 1)
    self.health.max:SetText(char.healthMax)
    self.health.max:SetColor(1.000, 0.000, 0.000, 1)
    self.health.regen:SetText(char.healthRegenCombat)
    self.health.regen:SetColor(1.000, 0.000, 0.000, 1)

    self.stamina.points:SetText(char.staminaPoints)
    self.stamina.points:SetColor(0.133, 0.545, 0.133, 1)
    self.stamina.max:SetText(char.staminaMax)
    self.stamina.max:SetColor(0.133, 0.545, 0.133, 1)
    self.stamina.regen:SetText(char.staminaRegenCombat)
    self.stamina.regen:SetColor(0.133, 0.545, 0.133, 1)

    self.magicka.points:SetText(char.magickaPoints)
    self.magicka.points:SetColor(0.255, 0.412, 0.882, 1)
    self.magicka.max:SetText(char.magickaMax)
    self.magicka.max:SetColor(0.255, 0.412, 0.882, 1)
    self.magicka.regen:SetText(char.magickaRegenCombat)
    self.magicka.regen:SetColor(0.255, 0.412, 0.882, 1)

    self.weapon.power:SetText(char.power)
    self.weapon.power:SetColor(0.133, 0.545, 0.133, 1)
    self.weapon.critical:SetText(char.criticalStrike)
    self.weapon.critical:SetColor(0.133, 0.545, 0.133, 1)
    self.weapon.criticalPercent:SetText(string.format("%.1f", char.weaponCriticalChance))
    self.weapon.criticalPercent:SetColor(0.133, 0.545, 0.133, 1)
    self.weapon.penetration:SetText(char.physicalPenetration)
    self.weapon.penetration:SetColor(0.133, 0.545, 0.133, 1)
    self.weapon.resist:SetText(char.physicalResist)
    self.weapon.resist:SetColor(0.133, 0.545, 0.133, 1)

    self.spell.power:SetText(char.spellPower)
    self.spell.power:SetColor(0.255, 0.412, 0.882, 1)
    self.spell.critical:SetText(char.spellCritical)
    self.spell.critical:SetColor(0.255, 0.412, 0.882, 1)
    self.spell.criticalPercent:SetText(string.format("%.1f", char.spellCriticalChance))
    self.spell.criticalPercent:SetColor(0.255, 0.412, 0.882, 1)
    self.spell.penetration:SetText(char.spellPenetration)
    self.spell.penetration:SetColor(0.255, 0.412, 0.882, 1)
    self.spell.resist:SetText(char.spellResist)
    self.spell.resist:SetColor(0.255, 0.412, 0.882, 1)

    self.mundus:SetText(char.mundus)
end