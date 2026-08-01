local ov = GlByGrhmForOverview

local win = "potionAndPoison"
ov.ctrl.subHeader[win] = {}
ov.ctrl.control[win] = {}

local ctrl = {}

function ov.createPotionAndPoison()

	ov.backdrop("potion", win, 350, 100, 0, 30)
	ov.backdrop("poison", win, 350, 100, 0, -3, "potion", TOPLEFT, BOTTOMLEFT)
	
	
	ctrl.potionIcon = ov.ctrl.wm:CreateControl(string.format("OverviewPotionIcon-%s", win), ov.ctrl.tlw[win], CT_TEXTURE )
	ctrl.potionIcon:SetAnchor(TOPLEFT, ov.ctrl.control[win]["potion"], TOPLEFT, 5, 8) 
	ctrl.potionIcon:SetDimensions(36, 36)
	ctrl.potionIcon:SetHidden(true)
	
	ctrl.potionName = ov.ctrl.wm:CreateControl(string.format("OverviewPotionName-%s", win), ov.ctrl.tlw[win], CT_LABEL )
	ctrl.potionName:SetAnchor(TOP, ov.ctrl.control[win]["potion"], TOP, 0, 10)
	ctrl.potionName:SetWidth(280)
	ctrl.potionName:SetFont(ov.font.element)
	ctrl.potionName:SetWrapMode(ELLIPSIS)
	ctrl.potionName:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	
	ctrl.potionText = ov.ctrl.wm:CreateControl(string.format("OverviewPotionText-%s", win), ov.ctrl.tlw[win], CT_LABEL )
	ctrl.potionText:SetAnchor(TOP, ctrl.potionName, BOTTOM, 0, 5)
	ctrl.potionText:SetWidth(345)
	ctrl.potionText:SetFont(ov.font.subElement)
	ctrl.potionText:SetWrapMode(ELLIPSIS)
	ctrl.potionText:SetColor(ov.getColor("gold"))
	ctrl.potionText:SetHorizontalAlignment(TEXT_ALIGN_CENTER)


	ctrl.poisonIcon = ov.ctrl.wm:CreateControl(string.format("OverviewPoisonIcon-%s", win), ov.ctrl.tlw[win], CT_TEXTURE )
	ctrl.poisonIcon:SetAnchor(TOPLEFT, ov.ctrl.control[win]["poison"], TOPLEFT, 5, 8) 
	ctrl.poisonIcon:SetDimensions(36, 36)
	ctrl.poisonIcon:SetHidden(true)
	
	ctrl.poisonName = ov.ctrl.wm:CreateControl(string.format("OverviewPoisonName-%s", win), ov.ctrl.tlw[win], CT_LABEL )
	ctrl.poisonName:SetAnchor(TOP, ov.ctrl.control[win]["poison"], TOP, 0, 10)
	ctrl.poisonName:SetWidth(300)
	ctrl.poisonName:SetFont(ov.font.element)
	ctrl.poisonName:SetWrapMode(ELLIPSIS)
	ctrl.poisonName:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	
	ctrl.poisonText = ov.ctrl.wm:CreateControl(string.format("OverviewPoisonText-%s", win), ov.ctrl.tlw[win], CT_LABEL )
	ctrl.poisonText:SetAnchor(TOP, ctrl.poisonName, BOTTOM, 0, 5)
	ctrl.poisonText:SetWidth(345)
	ctrl.poisonText:SetFont(ov.font.subElement)
	ctrl.poisonText:SetWrapMode(ELLIPSIS)
	ctrl.poisonText:SetColor(ov.getColor("gold"))
	ctrl.poisonText:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
end

function ov.potionFill()

	local potionHeight = 5
	local potionNameColor = GetItemQualityColor(1)
	local potionName = ""
	local potionText = ""

	local potionIcon = ""
	local potionIconHidden = true
	local itemType, _ = GetItemLinkItemType(GetSlotItemLink(GetCurrentQuickslot())) 
	if itemType == ITEMTYPE_POTION then
		potionNameColor = GetItemQualityColor(GetSlotItemQuality(GetCurrentQuickslot()))
		potionName = zo_strformat("<<C:1>>", GetSlotName(GetCurrentQuickslot()))
		for i = 1, 4 do
			_, potionTrait = GetItemLinkTraitOnUseAbilityInfo(GetSlotItemLink(GetCurrentQuickslot()), i)
			if potionTrait ~= "" and i == 1 then 
				potionText = string.format("%s", potionTrait)
			elseif potionTrait ~= "" then
				potionText = string.format("%s\n%s", potionText, potionTrait)
			end
		end
		if potionText == "" then potionText = GetAbilityDescription(GetSlotBoundId(GetCurrentQuickslot())) end
		
		potionIcon ,_ ,_ = GetSlotTexture(GetCurrentQuickslot())
		potionIconHidden = false
	else
		potionName = zo_strformat("<<z:1>>", GetString(SI_GAMEPAD_INVENTORY_EMPTY_TOOLTIP))
		potionNameColor = GetItemQualityColor(0)
		potionText = ""
		potionIcon = nil
		potionIconHidden = true
	end
	
	ctrl.potionName:SetText(potionName)
	ctrl.potionName:SetColor(potionNameColor:UnpackRGBA())
	ctrl.potionText:SetText(zo_strformat("<<1>><<2>>", potionText))

	ctrl.potionIcon:SetTexture(potionIcon)
	ctrl.potionIcon:SetHidden(potionIconHidden)
	
	potionHeight = ctrl.potionName:GetHeight() + ctrl.potionText:GetHeight() + 23
	ov.ctrl.control[win]["potion"]:SetHeight(potionHeight)
end

function ov.poisonFill()

	local avtivePair = GetActiveWeaponPairInfo()
	
	local poisenHeight = 5
	local poisonName = ""
	local poisonNameColor = GetItemQualityColor(0)
	local poisonTrait = ""
	local poisonText = ""
	local poisonIcon = ""
	local poisonIconHidden = true
	
	local itemLink = GetItemLink(BAG_WORN, 12+avtivePair, LINK_STYLE_DEFAULT)
	if itemLink ~= "" then
		poisonNameColor = GetItemQualityColor(GetItemLinkDisplayQuality(itemLink))
		poisonName = zo_strformat("<<C:1>>", GetItemLinkName(itemLink))
		
		for i = 1, 4 do
			_, poisonTrait = GetItemLinkTraitOnUseAbilityInfo(itemLink, i)
			if poisonTrait ~= "" and i == 1 then 
				poisonText = string.format("%s", poisonTrait)
			elseif poisonTrait ~= "" then
				poisonText = string.format("%s\n%s", poisonText, poisonTrait)
			end
		end
		if poisonText == "" then _, _, poisonText = GetItemLinkOnUseAbilityInfo(itemLink) end
		
		poisonIcon = GetItemLinkIcon(itemLink)
		poisonIconHidden = false
	else
		poisonName = zo_strformat("<<z:1>>", GetString(SI_GAMEPAD_INVENTORY_EMPTY_TOOLTIP))
		poisonNameColor = GetItemQualityColor(0)
		poisonText = ""
		poisonIcon = nil
		poisonIconHidden = true
	end
		ctrl.poisonName:SetText(poisonName)
		ctrl.poisonName:SetColor(poisonNameColor:UnpackRGBA())
		ctrl.poisonText:SetText(zo_strformat("<<1>><<2>>", poisonText))

		ctrl.poisonIcon:SetTexture(poisonIcon)
		ctrl.poisonIcon:SetHidden(poisonIconHidden)
		
		poisonHeight = ctrl.poisonName:GetHeight() + ctrl.poisonText:GetHeight() + 23
		ov.ctrl.control[win]["poison"]:SetHeight(poisonHeight)
end