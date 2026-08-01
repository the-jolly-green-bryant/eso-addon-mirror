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
-- Part of main window to view player's worn equipment
-------------------------------------------------------------------------------

MyBuild.EquipmentView = {}

function MyBuild.EquipmentView:Create(parent)
    self.box = MyBuild.UI2.Box(parent, 400, 630)
    MyBuild.UI2.Offset(self.box, 0, 170)
    self.title = MyBuild.UI2.Label(MyBuild.LANG.UI_Equipment_Title, "ZoFontWinH2",  self.box)
    MyBuild.UI2.Offset(self.title, 10, 0)

    self.head = self.ItemBlock(MyBuild.LANG.UI_Equipment_HeadLabel,  self.box, 10, 30)
    self.shoulders = self.ItemBlock(MyBuild.LANG.UI_Equipment_ShouldersLabel, self.box, 10, 70)
    self.chest = self.ItemBlock(MyBuild.LANG.UI_Equipment_ChestLabel,  self.box, 10, 110)
    self.hands = self.ItemBlock(MyBuild.LANG.UI_Equipment_HandsLabel, self.box, 10, 150)
    self.waist = self.ItemBlock(MyBuild.LANG.UI_Equipment_WaistLabel, self.box, 10, 190)
    self.legs = self.ItemBlock(MyBuild.LANG.UI_Equipment_LegsLabel, self.box, 10, 230)
    self.feet = self.ItemBlock(MyBuild.LANG.UI_Equipment_FeetLabel, self.box, 10, 270)

    self.neck = self.ItemBlock(MyBuild.LANG.UI_Equipment_Neck, self.box, 10, 320)
    self.ring1 = self.ItemBlock(MyBuild.LANG.UI_Equipment_Ring1, self.box, 10, 360)
    self.ring2 = self.ItemBlock(MyBuild.LANG.UI_Equipment_Ring2, self.box, 10, 400)

    self.main1 = self.ItemBlock(MyBuild.LANG.UI_Equipment_WeaponMain1, self.box, 10, 450)
    self.off1 = self.ItemBlock(MyBuild.LANG.UI_Equipment_WeaponOff1, self.box, 10, 490)
    self.main2 = self.ItemBlock(MyBuild.LANG.UI_Equipment_WeaponMain2, self.box, 10, 530)
    self.off2 = self.ItemBlock(MyBuild.LANG.UI_Equipment_WeaponOff2, self.box, 10, 570)
end

function MyBuild.EquipmentView.ItemBlock(title, parent, shiftX, shiftY)
    local item = {}

    item.box = MyBuild.UI2.Box(parent, 400, 100)
    MyBuild.UI2.Offset(item.box, shiftX, shiftY)

    item.label = MyBuild.UI2.Label(title, "ZoFontWinH4",  item.box)
    MyBuild.UI2.Offset(item.label, 0, 0)

    item.type = MyBuild.UI2.Label("item type", "ZoFontGameSmall", item.box)
    MyBuild.UI2.Offset(item.type, 5, 20)

    item.level = MyBuild.UI2.Label("----", "ZoFontWinT1",item.box)
    MyBuild.UI2.Offset(item.level, 100, 0)

    item.name = MyBuild.UI2.Label("Item Very Long, Long, Long, Long Name  ", "ZoFontWinT1", item.box, 280, 20)
    MyBuild.UI2.Offset(item.name, 144, 0)

    item.trait = MyBuild.UI2.Label("Item trait", "ZoFontGameSmall",  item.box)
    MyBuild.UI2.Offset(item.trait, 144, 20)

    item.enchantment = MyBuild.UI2.Label("Item enchantment", "ZoFontGameSmall",  item.box, 190, 20)
    MyBuild.UI2.Offset(item.enchantment, 220, 20)
    return item
end

function MyBuild.EquipmentView.UpdateItemInfo(item, itemview)

    itemview.name:SetText(item.name)
    itemview.name:SetColor(MyBuild.ESO.RGBA(MyBuild.ESO.QualityColor[item.quality]))

    itemview.level:SetText(MyBuild.Char.ItemLevelText(item))
    itemview.level:SetColor(MyBuild.ESO.RGBA(MyBuild.ESO.QualityColor[item.quality]))


    if item.armortype ~= 0 then
        itemview.type:SetText(MyBuild.LANG.ESO.Armor[item.armortype])
        itemview.type:SetColor(MyBuild.ESO.RGBA(MyBuild.ESO.ArmorTypeColor[item.armortype]))
    elseif item.weapontype ~= 0 then
        itemview.type:SetText(MyBuild.LANG.ESO.Weapon[item.weapontype])
        itemview.type:SetColor(0.502, 0.502, 0.502, 1)
    else
        itemview.type:SetText("")
    end

    itemview.trait:SetText(MyBuild.LANG.ESO.Trait[item.trait])
    itemview.trait:SetColor(0.502, 0.502, 0.502, 1)

    itemview.enchantment:SetText(item.enchantment)
    itemview.enchantment:SetColor(0.502, 0.502, 0.502, 1)

end

function MyBuild.EquipmentView:UpdateCharacterInfo(char)
    self.UpdateItemInfo(char.head, self.head)
    self.UpdateItemInfo(char.shoulders, self.shoulders)
    self.UpdateItemInfo(char.chest, self.chest)
    self.UpdateItemInfo(char.hand, self.hands)
    self.UpdateItemInfo(char.waist, self.waist)
    self.UpdateItemInfo(char.legs, self.legs)
    self.UpdateItemInfo(char.feet, self.feet)

    self.UpdateItemInfo(char.neck, self.neck)
    self.UpdateItemInfo(char.ring1, self.ring1)
    self.UpdateItemInfo(char.ring2, self.ring2)

    self.UpdateItemInfo(char.mainHand, self.main1)
    self.UpdateItemInfo(char.offHand, self.off1)
    self.UpdateItemInfo(char.backupMain, self.main2)
    self.UpdateItemInfo(char.backupOff, self.off2)

    self.title:SetText(MyBuild.LANG.UI_Equipment_Title.."   "..self.EquipmentSummary(char))
end

function MyBuild.EquipmentView.EquipmentSummary(char)
  local h = 0
  local m = 0
  local l = 0
  local items = {char.head, char.shoulders, char.chest, char.hand, char.waist, char.legs, char.feet}
  for _, iitem in ipairs(items) do
    if iitem.armortype == ARMORTYPE_HEAVY then
      h = h + 1
    end
    if iitem.armortype == ARMORTYPE_MEDIUM then
      m = m + 1
    end
    if iitem.armortype == ARMORTYPE_LIGHT then
      l = l + 1
    end
  end
  return string.format("(|cB22222 %d|r, |c008000 %d|r, |c4169E1 %d|r )", h,m,l)
end
