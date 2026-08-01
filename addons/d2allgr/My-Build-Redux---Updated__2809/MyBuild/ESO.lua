-- The MIT License (MIT)
-- Copyright (c) 2015 Eugene Aksenov (e.aksenov@gmail.com)
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
-- ESO defaults and colors
-------------------------------------------------------------------------------

MyBuild.ESO = {}

function MyBuild.ESO.Color(r, g, b, a)
    local color = {}
    color.r = r
    color.b = b
    color.g = g
    color.a = a
    return color
end

function MyBuild.ESO.RGBA(color)
    return color.r, color.g, color.b, color.a
end

MyBuild.ESO.QualityColor = {}
MyBuild.ESO.QualityColor[ITEM_QUALITY_ARCANE] = MyBuild.ESO.Color(0.227, 0.572, 1, 1)
MyBuild.ESO.QualityColor[ITEM_QUALITY_ARTIFACT] = MyBuild.ESO.Color(0.627, 0.18, 0.968, 1)
MyBuild.ESO.QualityColor[ITEM_QUALITY_LEGENDARY] = MyBuild.ESO.Color(0.933, 0.792, 0.164, 1)
MyBuild.ESO.QualityColor[ITEM_QUALITY_MAGIC] = MyBuild.ESO.Color(0.176, 0.772, 0.055, 1)
MyBuild.ESO.QualityColor[ITEM_QUALITY_NORMAL] = MyBuild.ESO.Color(1, 1, 1, 1)
MyBuild.ESO.QualityColor[ITEM_QUALITY_TRASH] = MyBuild.ESO.Color(0.764, 0.764, 0.764, 1)


MyBuild.ESO.ArmorTypeColor = {}
MyBuild.ESO.ArmorTypeColor[ARMORTYPE_HEAVY] = MyBuild.ESO.Color(0.698, 0.133, 0.133, 1)
MyBuild.ESO.ArmorTypeColor[ARMORTYPE_LIGHT] = MyBuild.ESO.Color(0.255, 0.412, 0.882, 1)
MyBuild.ESO.ArmorTypeColor[ARMORTYPE_MEDIUM] = MyBuild.ESO.Color(0.000, 0.502, 0.000, 1)
MyBuild.ESO.ArmorTypeColor[ARMORTYPE_NONE] = MyBuild.ESO.Color(1, 1, 1, 1)

MyBuild.ESO.WeaponTypeColor = {}
MyBuild.ESO.WeaponTypeColor[ARMORTYPE_HEAVY] = MyBuild.ESO.Color(0.698, 0.133, 0.133, 1)
MyBuild.ESO.WeaponTypeColor[ARMORTYPE_LIGHT] = MyBuild.ESO.Color(0.255, 0.412, 0.882, 1)
MyBuild.ESO.WeaponTypeColor[ARMORTYPE_MEDIUM] = MyBuild.ESO.Color(0.000, 0.502, 0.000, 1)
MyBuild.ESO.WeaponTypeColor[ARMORTYPE_NONE] = MyBuild.ESO.Color(1, 1, 1, 1)


