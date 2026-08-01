local ov = GlByGrhmForOverview

local win = "equipment"
ov.ctrl.subHeader[win] = {}
ov.ctrl.control[win] = {}

local ctrl = {}
ctrl.texture = {}
ctrl.name = {}
ctrl.info = {}
ctrl.dividor = nil

local weaponset1 = string.format("%s-%s", GetString(SI_KEYBINDINGS_PRIMARY), GetString(SI_EQUIPSLOTVISUALCATEGORY1))
local weaponset2 = string.format("%s-%s", GetString(SI_KEYBINDINGS_SECONDARY), GetString(SI_EQUIPSLOTVISUALCATEGORY1))

function ov.createEquipment()
	ov.createSubheader("armor", win , TOPLEFT, TOPLEFT, 5, 35, GetString(SI_ITEM_FORMAT_STR_ARMOR))
	ov.backdrop("armor", win, 400, 480, 0, 30)
	ov.createSubheader("jewellery", win , TOPLEFT, TOPLEFT, 410, 35, GetString(SI_EQUIPSLOTVISUALCATEGORY3))
	ov.backdrop("jewellery", win, 400, 160, 405, 30)
	ov.createSubheader("weaponset1", win , TOPLEFT, TOPLEFT, 410, 200, weaponset1)
	ov.backdrop("weaponset1", win, 400, 155, 405, 195)
	ov.createSubheader("weaponset2", win , TOPLEFT, TOPLEFT, 410, 360, weaponset2)
	ov.backdrop("weaponset2", win, 400, 155, 405, 355)
	
	ov.ctrl.activePair1 = ov.ctrl.wm:CreateControl(string.format("OverviewActivePair1-%s", win), ov.ctrl.tlw[win], CT_LABEL )
	ov.ctrl.activePair1:SetAnchor(TOPRIGHT, ov.ctrl.control[win]["weaponset1"], TORIGHT, 0, 8)
	ov.ctrl.activePair1:SetDimensions(50, 25)
	ov.ctrl.activePair1:SetFont(ov.font.subElement)
	ov.ctrl.activePair1:SetColor(ov.getColor("white"))
	ov.ctrl.activePair1:SetWrapMode(ELLIPSIS)
	ov.ctrl.activePair1:SetText(GetString(SI_INVENTORY_SORT_TYPE_ACTIVE))
	
	ov.ctrl.activePair2 = ov.ctrl.wm:CreateControl(string.format("OverviewActivePair2-%s", win), ov.ctrl.tlw[win], CT_LABEL )
	ov.ctrl.activePair2:SetAnchor(TOPRIGHT, ov.ctrl.control[win]["weaponset2"], TORIGHT, 0, 8)
	ov.ctrl.activePair2:SetDimensions(50, 25)
	ov.ctrl.activePair2:SetFont(ov.font.subElement)
	ov.ctrl.activePair2:SetColor(ov.getColor("white"))
	ov.ctrl.activePair2:SetWrapMode(ELLIPSIS)
	ov.ctrl.activePair2:SetText(GetString(SI_INVENTORY_SORT_TYPE_ACTIVE))

	local spacerY = 0

	for i = 1, 7 do
		ctrl.texture[i] = ov.ctrl.wm:CreateControl(string.format("OverviewTexture%d-%s", i, win), ov.ctrl.tlw[win], CT_TEXTURE )
		ctrl.texture[i]:SetAnchor(TOPLEFT, ov.ctrl.control[win]["armor"], TOPLEFT, 2, 30 + spacerY) 
		ctrl.texture[i]:SetDimensions(52, 52)
		ctrl.texture[i]:SetHidden(true)
	
		ctrl.name[i] = ov.ctrl.wm:CreateControl(string.format("OverviewName%d-%s", i, win), ov.ctrl.tlw[win], CT_LABEL )
		ctrl.name[i]:SetAnchor(TOPLEFT, ctrl.texture[i], TOPRIGHT, 3, 0) 
		ctrl.name[i]:SetDimensions(345, 20)
		ctrl.name[i]:SetFont(ov.font.element)
		ctrl.name[i]:SetWrapMode(ELLIPSIS)
	
		ctrl.info[i] = ov.ctrl.wm:CreateControl(string.format("OverviewInfo%d-%s", i, win), ov.ctrl.tlw[win], CT_LABEL )
		ctrl.info[i]:SetAnchor(TOPLEFT, ctrl.texture[i], TOPRIGHT, 3, 20)
		ctrl.info[i]:SetDimensions(345, 45)
		ctrl.info[i]:SetFont(ov.font.subElement)
		ctrl.info[i]:SetColor(ov.getColor("gold"))
		ctrl.info[i]:SetWrapMode(ELLIPSIS)
		
		spacerY = spacerY + 65
	end
	
	spacerY = 0
	
	for i = 8, 10 do
		ctrl.texture[i] = ov.ctrl.wm:CreateControl(string.format("OverviewTexture%d-%s", i, win), ov.ctrl.tlw[win], CT_TEXTURE )
		ctrl.texture[i]:SetAnchor(TOPLEFT, ov.ctrl.control[win]["jewellery"], TOPLEFT, 2, 30 + spacerY) 
		ctrl.texture[i]:SetDimensions(40, 40)
		ctrl.texture[i]:SetHidden(true)
	
		ctrl.name[i] = ov.ctrl.wm:CreateControl(string.format("OverviewName%d-%s", i, win), ov.ctrl.tlw[win], CT_LABEL )
		ctrl.name[i]:SetAnchor(TOPLEFT, ctrl.texture[i], TOPRIGHT, 3, 0) 
		ctrl.name[i]:SetDimensions(350, 20)
		ctrl.name[i]:SetFont(ov.font.element)
		ctrl.name[i]:SetWrapMode(ELLIPSIS)
	
		ctrl.info[i] = ov.ctrl.wm:CreateControl(string.format("OverviewInfo%d-%s", i, win), ov.ctrl.tlw[win], CT_LABEL )
		ctrl.info[i]:SetAnchor(TOPLEFT, ctrl.texture[i], TOPRIGHT, 3, 20)
		ctrl.info[i]:SetDimensions(350, 20)
		ctrl.info[i]:SetFont(ov.font.subElement)
		ctrl.info[i]:SetColor(ov.getColor("gold"))
		ctrl.info[i]:SetWrapMode(ELLIPSIS)
		
		spacerY = spacerY + 44
	end
	
	spacerY = 0
	
	for i = 11, 12 do
		ctrl.texture[i] = ov.ctrl.wm:CreateControl(string.format("OverviewTexture%d-%s", i, win), ov.ctrl.tlw[win], CT_TEXTURE )
		ctrl.texture[i]:SetAnchor(TOPLEFT, ov.ctrl.control[win]["weaponset1"], TOPLEFT, 2, 30 + spacerY) 
		ctrl.texture[i]:SetDimensions(52, 52)
		ctrl.texture[i]:SetHidden(true)
	
		ctrl.name[i] = ov.ctrl.wm:CreateControl(string.format("OverviewName%d-%s", i, win), ov.ctrl.tlw[win], CT_LABEL )
		ctrl.name[i]:SetAnchor(TOPLEFT, ctrl.texture[i], TOPRIGHT, 3, 0) 
		ctrl.name[i]:SetDimensions(345, 20)
		ctrl.name[i]:SetFont(ov.font.element)
		ctrl.name[i]:SetWrapMode(ELLIPSIS)
	
		ctrl.info[i] = ov.ctrl.wm:CreateControl(string.format("OverviewInfo%d-%s", i, win), ov.ctrl.tlw[win], CT_LABEL )
		ctrl.info[i]:SetAnchor(TOPLEFT, ctrl.texture[i], TOPRIGHT, 3, 20)
		ctrl.info[i]:SetDimensions(345, 45)
		ctrl.info[i]:SetFont(ov.font.subElement)
		ctrl.info[i]:SetColor(ov.getColor("gold"))
		ctrl.info[i]:SetWrapMode(ELLIPSIS)
		
		spacerY = spacerY + 65
	end
	
	spacerY = 0
	
	
	for i = 13, 14 do
		ctrl.texture[i] = ov.ctrl.wm:CreateControl(string.format("OverviewTexture%d-%s", i, win), ov.ctrl.tlw[win], CT_TEXTURE )
		ctrl.texture[i]:SetAnchor(TOPLEFT, ov.ctrl.control[win]["weaponset2"], TOPLEFT, 2, 30 + spacerY) 
		ctrl.texture[i]:SetDimensions(52, 52)
		ctrl.texture[i]:SetHidden(true)
	
		ctrl.name[i] = ov.ctrl.wm:CreateControl(string.format("OverviewName%d-%s", i, win), ov.ctrl.tlw[win], CT_LABEL )
		ctrl.name[i]:SetAnchor(TOPLEFT, ctrl.texture[i], TOPRIGHT, 3, 0) 
		ctrl.name[i]:SetDimensions(340, 20)
		ctrl.name[i]:SetFont(ov.font.element)
		ctrl.name[i]:SetWrapMode(ELLIPSIS)
	
		ctrl.info[i] = ov.ctrl.wm:CreateControl(string.format("OverviewInfo%d-%s", i, win), ov.ctrl.tlw[win], CT_LABEL )
		ctrl.info[i]:SetAnchor(TOPLEFT, ctrl.texture[i], TOPRIGHT, 3, 20)
		ctrl.info[i]:SetDimensions(340, 45)
		ctrl.info[i]:SetFont(ov.font.subElement)
		ctrl.info[i]:SetColor(ov.getColor("gold"))
		ctrl.info[i]:SetWrapMode(ELLIPSIS)
		
		spacerY = spacerY + 65
	end
end

local equipmentSortNr = { [1] = 0, [2] = 3, [3] = 2, [4] = 16, [5] = 6, [6] = 8, [7] = 9, [8] = 1, [9] = 11, [10] = 12, [11] = 4, [12] = 5, [13] = 20, [14] = 21 }

local equipNameColor = GetItemQualityColor(1)

local equiredCP = "cp"
local equiredLv = "Lv"
local hasCharges, enchantHeader, enchantDescription = GetItemLinkEnchantInfo()
local getTraitType, traitDescription, traitSubtype, traitSubtypeName, traitSubtypeDescription = GetItemLinkTraitInfo()
local itemLink = GetItemLink()
local equipText= ""
local requiredText = ""
local enchantText = ""
local powerText = ""
local wordwrap = "\n"
local enchandFirstPartLength = 0
local enchandFirstPart = ""
local enchandSecondPart = ""


function ov.equipmentFill()

	for i = 1, 14 do
		if GetItemName(BAG_WORN, equipmentSortNr[i]) ~= "" then
			itemLink = GetItemLink(BAG_WORN, equipmentSortNr[i], LINK_STYLE_DEFAULT)
			
			hasCharges, enchantHeader, enchantDescription = GetItemLinkEnchantInfo(itemLink)
			
			getTraitType = GetItemLinkTraitInfo(itemLink)
			traitText = zo_strlower(GetString("SI_ITEMTRAITTYPE", getTraitType))
			
			if GetItemLinkRequiredChampionPoints(itemLink) ~= 0 then
				requiredText = zo_strformat("· <<1>>|cFFFFFF<<2>>|r", equiredCP, GetItemLinkRequiredChampionPoints(itemLink))
			else
				requiredText = zo_strformat("· <<1>>|cFFFFFF<<2>>|r", equiredLv, GetItemLinkRequiredLevel(itemLink))
			end
			
			if i > 0 and i < 8 then  
				equipText = zo_strformat("|cFFFFFF<<1>>|r <<C:2>> <<3>>", 
				GetString("SI_EQUIPTYPE", GetItemLinkEquipType(itemLink)), 
				GetString("SI_ARMORTYPE", GetItemLinkArmorType(itemLink)), 
				GetString(SI_ITEM_FORMAT_STR_ARMOR))
				
				powerText = zo_strformat("<<1>>: |cFFFFFF<<2>>|r", GetString(SI_ITEM_FORMAT_STR_ARMOR), GetItemLinkArmorRating(itemLink))
			end

			if i > 7 and i < 11 then 
				equipText = zo_strformat("|cFFFFFF<<1>>|r", GetString("SI_EQUIPTYPE", GetItemLinkEquipType(itemLink)))
				wordwrap = " "
				powerText = "" 
			end
	
			if i > 10 then 
				wordwrap = "\n"
				equipText = zo_strformat("|cFFFFFF<<1>>|r <<C:2>>", 
				GetString("SI_WEAPONTYPE", GetItemLinkWeaponType(itemLink)), 
				GetString("SI_EQUIPTYPE", GetItemLinkEquipType(itemLink)))
				
				if GetItemLinkWeaponType(itemLink) == WEAPONTYPE_SHIELD then
					powerText = zo_strformat("<<1>>: |cFFFFFF<<2>>|r", GetString(SI_ITEM_FORMAT_STR_ARMOR), GetItemLinkArmorRating(itemLink))
				else 
					powerText = zo_strformat("<<1>>: |cFFFFFF<<2>>|r", GetString(SI_ITEM_FORMAT_STR_DAMAGE), GetItemLinkWeaponPower(itemLink)) 
				end
			end
			equipNameColor = GetItemQualityColor(GetItemLinkDisplayQuality(itemLink))
			ctrl.name[i]:SetText(zo_strformat("<<C:1>>", GetItemLinkName(itemLink)))
			ctrl.name[i]:SetColor(equipNameColor:UnpackRGBA())
			ctrl.texture[i]:SetHidden(false)
			ctrl.texture[i]:SetTexture(GetItemLinkIcon(itemLink))
			ctrl.info[i]:SetText(zo_strformat("<<1>> · |cFFFFFF<<2>>|r <<3>><<4>><<5>> · |cFFFFFF<<6>>|r", equipText, traitText, requiredText, wordwrap, powerText, enchantHeader))
		else
			ctrl.name[i]:SetText("")
			ctrl.texture[i]:SetHidden(true)
			ctrl.info[i]:SetText("")
		end
	end
end
