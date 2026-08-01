-- Update Addon File
-- @author    : Homeo
-- @lastModif : 23/09/2017


function Display_Armor()
	local CoutTotal, obj_1, obj_2, obj_3, obj_4, obj_5, obj_6, obj_7, arm_1, arm_2, arm_3, arm_4 = RepairCost()
	local ValRep = SAK.settings.SEUIL_REPAIR

	if(obj_1[1] ~= -1) then
		SwissArmyKnifeContainerArmorRepair1:SetTexture(obj_1[3])
		if(obj_1[1] ~= 100) then 
			SwissArmyKnifeContainerArmorRepairLabel1:SetText(obj_1[1].."%") 
		else
			SwissArmyKnifeContainerArmorRepairLabel1:SetText("")
		end
		SwissArmyKnifeContainerArmorRepairLabel1:SetColor(tonumber(obj_1[1]) > ValRep and 1 or SAK.settings.colorTexte.r,tonumber(obj_1[1]) > ValRep and 1 or SAK.settings.colorTexte.g,tonumber(obj_1[1]) > ValRep and 1 or SAK.settings.colorTexte.b)
		if(obj_1[1] == 0) then 
			SwissArmyKnifeContainerOutlineArmor1:SetColor(SAK.settings.colour.r, SAK.settings.colour.g, SAK.settings.colour.b, SAK.settings.colour.a)
		else
			local r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, obj_1[4])
			SwissArmyKnifeContainerOutlineArmor1:SetColor(r, g, b, 255)
		end
	else
		SwissArmyKnifeContainerArmorRepair1:SetTexture("esoui/art/windows/gamepad/gp_grunge_scalable.dds")
		SwissArmyKnifeContainerArmorRepairLabel1:SetText(" ")
		SwissArmyKnifeContainerArmorRepairLabel1:SetColor(0, 0, 0, 0)
		SwissArmyKnifeContainerOutlineArmor1:SetColor(0, 0, 0, 0)
	end
	if(obj_2[1] ~= -1) then
		SwissArmyKnifeContainerArmorRepair2:SetTexture(obj_2[3])
		if(obj_2[1] ~= 100) then 
			SwissArmyKnifeContainerArmorRepairLabel2:SetText(obj_2[1].."%") 
		else
			SwissArmyKnifeContainerArmorRepairLabel2:SetText("")
		end
		SwissArmyKnifeContainerArmorRepairLabel2:SetColor(tonumber(obj_2[1]) > ValRep and 1 or SAK.settings.colorTexte.r,tonumber(obj_2[1]) > ValRep and 1 or SAK.settings.colorTexte.g,tonumber(obj_2[1]) > ValRep and 1 or SAK.settings.colorTexte.b)
		if(obj_2[1] == 0) then SwissArmyKnifeContainerOutlineArmor2:SetColor(SAK.settings.colour.r, SAK.settings.colour.g, SAK.settings.colour.b, SAK.settings.colour.a)
		else
			local r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, obj_2[4])
			SwissArmyKnifeContainerOutlineArmor2:SetColor(r, g, b, 255)
		end
	else
		SwissArmyKnifeContainerArmorRepair2:SetTexture("esoui/art/windows/gamepad/gp_grunge_scalable.dds")
		SwissArmyKnifeContainerArmorRepairLabel2:SetText(" ")
		SwissArmyKnifeContainerArmorRepairLabel2:SetColor(0, 0, 0, 0)
		SwissArmyKnifeContainerOutlineArmor2:SetColor(0, 0, 0, 0)
	end
	if(obj_3[1] ~= -1) then
		SwissArmyKnifeContainerArmorRepair3:SetTexture(obj_3[3])
		if(obj_3[1] ~= 100) then 
			SwissArmyKnifeContainerArmorRepairLabel3:SetText(obj_3[1].."%") 
		else
			SwissArmyKnifeContainerArmorRepairLabel3:SetText("")
		end
		SwissArmyKnifeContainerArmorRepairLabel3:SetColor(tonumber(obj_3[1]) > ValRep and 1 or SAK.settings.colorTexte.r,tonumber(obj_3[1]) > ValRep and 1 or SAK.settings.colorTexte.g,tonumber(obj_3[1]) > ValRep and 1 or SAK.settings.colorTexte.b)
		if(obj_3[1] == 0) then SwissArmyKnifeContainerOutlineArmor3:SetColor(SAK.settings.colour.r, SAK.settings.colour.g, SAK.settings.colour.b, SAK.settings.colour.a)
		else
			local r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, obj_3[4])
			SwissArmyKnifeContainerOutlineArmor3:SetColor(r, g, b, 255)
		end
	else
		SwissArmyKnifeContainerArmorRepair3:SetTexture("esoui/art/windows/gamepad/gp_grunge_scalable.dds")
		SwissArmyKnifeContainerArmorRepairLabel3:SetText(" ")
		SwissArmyKnifeContainerArmorRepairLabel3:SetColor(0, 0, 0, 0)
		SwissArmyKnifeContainerOutlineArmor3:SetColor(0, 0, 0, 0)
	end
	if(obj_4[1] ~= -1) then
		SwissArmyKnifeContainerArmorRepair4:SetTexture(obj_4[3])
		if(obj_4[1] ~= 100) then 
			SwissArmyKnifeContainerArmorRepairLabel4:SetText(obj_4[1].."%") 
		else
			SwissArmyKnifeContainerArmorRepairLabel4:SetText("")
		end
		SwissArmyKnifeContainerArmorRepairLabel4:SetColor(tonumber(obj_4[1]) > ValRep and 1 or SAK.settings.colorTexte.r,tonumber(obj_4[1]) > ValRep and 1 or SAK.settings.colorTexte.g,tonumber(obj_4[1]) > ValRep and 1 or SAK.settings.colorTexte.b)
		if(obj_4[1] == 0) then SwissArmyKnifeContainerOutlineArmor4:SetColor(SAK.settings.colour.r, SAK.settings.colour.g, SAK.settings.colour.b, SAK.settings.colour.a)
		else
			local r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, obj_4[4])
			SwissArmyKnifeContainerOutlineArmor4:SetColor(r, g, b, 255)
		end
	else
		SwissArmyKnifeContainerArmorRepair4:SetTexture("esoui/art/windows/gamepad/gp_grunge_scalable.dds")
		SwissArmyKnifeContainerArmorRepairLabel4:SetText(" ")
		SwissArmyKnifeContainerArmorRepairLabel4:SetColor(0, 0, 0, 0)
		SwissArmyKnifeContainerOutlineArmor4:SetColor(0, 0, 0, 0)
	end
	if(obj_5[1] ~= -1) then
		SwissArmyKnifeContainerArmorRepair5:SetTexture(obj_5[3])
		if(obj_5[1] ~= 100) then 
			SwissArmyKnifeContainerArmorRepairLabel5:SetText(obj_5[1].."%") 
		else
			SwissArmyKnifeContainerArmorRepairLabel5:SetText("")
		end
		SwissArmyKnifeContainerArmorRepairLabel5:SetColor(tonumber(obj_5[1]) > ValRep and 1 or SAK.settings.colorTexte.r,tonumber(obj_5[1]) > ValRep and 1 or SAK.settings.colorTexte.g,tonumber(obj_5[1]) > ValRep and 1 or SAK.settings.colorTexte.b)
		if(obj_5[1] == 0) then SwissArmyKnifeContainerOutlineArmor5:SetColor(SAK.settings.colour.r, SAK.settings.colour.g, SAK.settings.colour.b, SAK.settings.colour.a)
		else
			local r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, obj_5[4])
			SwissArmyKnifeContainerOutlineArmor5:SetColor(r, g, b, 255)
		end
	else
		SwissArmyKnifeContainerArmorRepair5:SetTexture("esoui/art/windows/gamepad/gp_grunge_scalable.dds")
		SwissArmyKnifeContainerArmorRepairLabel5:SetText(" ")
		SwissArmyKnifeContainerArmorRepairLabel5:SetColor(0, 0, 0, 0)
		SwissArmyKnifeContainerOutlineArmor5:SetColor(0, 0, 0, 0)
	end
	if(obj_6[1] ~= -1) then
		SwissArmyKnifeContainerArmorRepair6:SetTexture(obj_6[3])
		if(obj_6[1] ~= 100) then 
			SwissArmyKnifeContainerArmorRepairLabel6:SetText(obj_6[1].."%") 
		else
			SwissArmyKnifeContainerArmorRepairLabel6:SetText("")
		end
		SwissArmyKnifeContainerArmorRepairLabel6:SetColor(tonumber(obj_6[1]) > ValRep and 1 or SAK.settings.colorTexte.r,tonumber(obj_6[1]) > ValRep and 1 or SAK.settings.colorTexte.g,tonumber(obj_6[1]) > ValRep and 1 or SAK.settings.colorTexte.b)
		if(obj_6[1] == 0) then SwissArmyKnifeContainerOutlineArmor6:SetColor(SAK.settings.colour.r, SAK.settings.colour.g, SAK.settings.colour.b, SAK.settings.colour.a)
		else
			local r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, obj_6[4])
			SwissArmyKnifeContainerOutlineArmor6:SetColor(r, g, b, 255)
		end
	else
		SwissArmyKnifeContainerArmorRepair6:SetTexture("esoui/art/windows/gamepad/gp_grunge_scalable.dds")
		SwissArmyKnifeContainerArmorRepairLabel6:SetText(" ")
		SwissArmyKnifeContainerArmorRepairLabel6:SetColor(0, 0, 0, 0)
		SwissArmyKnifeContainerOutlineArmor6:SetColor(0, 0, 0, 0)
	end
	if(obj_7[1] ~= -1) then
		SwissArmyKnifeContainerArmorRepair7:SetTexture(obj_7[3])
		if(obj_7[1] ~= 100) then 
			SwissArmyKnifeContainerArmorRepairLabel7:SetText(obj_7[1].."%") 
		else
			SwissArmyKnifeContainerArmorRepairLabel7:SetText("")
		end
		SwissArmyKnifeContainerArmorRepairLabel7:SetColor(tonumber(obj_7[1]) > ValRep and 1 or SAK.settings.colorTexte.r,tonumber(obj_7[1]) > ValRep and 1 or SAK.settings.colorTexte.g,tonumber(obj_7[1]) > ValRep and 1 or SAK.settings.colorTexte.b)
		if(obj_7[1] == 0) then SwissArmyKnifeContainerOutlineArmor7:SetColor(SAK.settings.colour.r, SAK.settings.colour.g, SAK.settings.colour.b, SAK.settings.colour.a)
		else
			local r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, obj_7[4])
			SwissArmyKnifeContainerOutlineArmor7:SetColor(r, g, b, 255)
		end
	else
		SwissArmyKnifeContainerArmorRepair7:SetTexture("esoui/art/windows/gamepad/gp_grunge_scalable.dds")
		SwissArmyKnifeContainerArmorRepairLabel7:SetText(" ")
		SwissArmyKnifeContainerArmorRepairLabel7:SetColor(0, 0, 0, 0)
		SwissArmyKnifeContainerOutlineArmor7:SetColor(0, 0, 0, 0)
	end
end

function Display_Weapon()
	local CoutTotal, obj_1, obj_2, obj_3, obj_4, obj_5, obj_6, obj_7, arm_1, arm_2, arm_3, arm_4 = RepairCost()
	local ValRep_arm = SAK.settings.SEUIL_REPAIR_ARM

	if(arm_1[1] ~= -1) then  
		SwissArmyKnifeContainerWeaponRepair1:SetTexture(arm_1[3]) 
		if(arm_1[1] ~= 100) then
			SwissArmyKnifeContainerWeaponRepairLabel1:SetText(arm_1[1].."%")
		else
			SwissArmyKnifeContainerWeaponRepairLabel1:SetText("")
		end
		SwissArmyKnifeContainerWeaponRepairLabel1:SetColor(tonumber(arm_1[1]) > ValRep_arm and 1 or SAK.settings.colorTexte_arm.r,tonumber(arm_1[1]) > ValRep_arm and 1 or SAK.settings.colorTexte_arm.g,tonumber(arm_1[1]) > ValRep_arm and 1 or SAK.settings.colorTexte_arm.b)
		if(arm_1[1] == 0) then SwissArmyKnifeContainerOutlineWeapon1:SetColor(SAK.settings.colour_arm.r, SAK.settings.colour_arm.g, SAK.settings.colour_arm.b, SAK.settings.colour_arm.a)
		else
			local r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, arm_1[4])
			SwissArmyKnifeContainerOutlineWeapon1:SetColor(r, g, b, 255)
		end
	else
		SwissArmyKnifeContainerWeaponRepair1:SetTexture("esoui/art/windows/gamepad/gp_grunge_scalable.dds") 
		SwissArmyKnifeContainerWeaponRepairLabel1:SetText(" ")
		SwissArmyKnifeContainerWeaponRepairLabel1:SetColor(0, 0, 0, 0)
		SwissArmyKnifeContainerOutlineWeapon1:SetColor(0, 0, 0, 0)
	end
	if(arm_2[1] ~= -1) then  
		SwissArmyKnifeContainerWeaponRepair2:SetTexture(arm_2[3]) 
		if(arm_2[1] ~= 100) then
			SwissArmyKnifeContainerWeaponRepairLabel2:SetText(arm_2[1].."%")
		else
			SwissArmyKnifeContainerWeaponRepairLabel2:SetText("")
		end
		SwissArmyKnifeContainerWeaponRepairLabel2:SetColor(tonumber(arm_2[1]) > ValRep_arm and 1 or SAK.settings.colorTexte_arm.r,tonumber(arm_2[1]) > ValRep_arm and 1 or SAK.settings.colorTexte_arm.g,tonumber(arm_2[1]) > ValRep_arm and 1 or SAK.settings.colorTexte_arm.b)
		if(arm_2[1] == 0) then SwissArmyKnifeContainerOutlineWeapon2:SetColor(SAK.settings.colour_arm.r, SAK.settings.colour_arm.g, SAK.settings.colour_arm.b, SAK.settings.colour_arm.a)
		else
			local r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, arm_2[4])
			SwissArmyKnifeContainerOutlineWeapon2:SetColor(r, g, b, 255)
		end
	else
		SwissArmyKnifeContainerWeaponRepair2:SetTexture("esoui/art/windows/gamepad/gp_grunge_scalable.dds") 
		SwissArmyKnifeContainerWeaponRepairLabel2:SetText(" ")
		SwissArmyKnifeContainerWeaponRepairLabel2:SetColor(0, 0, 0, 0)
		SwissArmyKnifeContainerOutlineWeapon2:SetColor(0, 0, 0, 0)
	end
	if(arm_3[1] ~= -1) then 
		SwissArmyKnifeContainerWeaponRepair3:SetTexture(arm_3[3]) 
		if(arm_3[1] ~= 100) then
			SwissArmyKnifeContainerWeaponRepairLabel3:SetText(arm_3[1].."%")
		else
			SwissArmyKnifeContainerWeaponRepairLabel3:SetText("")
		end 
		SwissArmyKnifeContainerWeaponRepairLabel3:SetColor(tonumber(arm_3[1]) > ValRep_arm and 1 or SAK.settings.colorTexte_arm.r,tonumber(arm_3[1]) > ValRep_arm and 1 or SAK.settings.colorTexte_arm.g,tonumber(arm_3[1]) > ValRep_arm and 1 or SAK.settings.colorTexte_arm.b)
		if(arm_3[1] == 0) then SwissArmyKnifeContainerOutlineWeapon3:SetColor(SAK.settings.colour_arm.r, SAK.settings.colour_arm.g, SAK.settings.colour_arm.b, SAK.settings.colour_arm.a)
		else
			local r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, arm_3[4])
			SwissArmyKnifeContainerOutlineWeapon3:SetColor(r, g, b, 255)
		end
	else
		SwissArmyKnifeContainerWeaponRepair3:SetTexture("esoui/art/windows/gamepad/gp_grunge_scalable.dds") 
		SwissArmyKnifeContainerWeaponRepairLabel3:SetText(" ")
		SwissArmyKnifeContainerWeaponRepairLabel3:SetColor(0, 0, 0, 0)
		SwissArmyKnifeContainerOutlineWeapon3:SetColor(0, 0, 0, 0)
	end
	if(arm_4[1] ~= -1) then  
		SwissArmyKnifeContainerWeaponRepair4:SetTexture(arm_4[3]) 
		if(arm_4[1] ~= 100) then
			SwissArmyKnifeContainerWeaponRepairLabel4:SetText(arm_4[1].."%")
		else
			SwissArmyKnifeContainerWeaponRepairLabel4:SetText("")
		end
		SwissArmyKnifeContainerWeaponRepairLabel4:SetColor(tonumber(arm_4[1]) > ValRep_arm and 1 or SAK.settings.colorTexte_arm.r,tonumber(arm_4[1]) > ValRep_arm and 1 or SAK.settings.colorTexte_arm.g,tonumber(arm_4[1]) > ValRep_arm and 1 or SAK.settings.colorTexte_arm.b)
		if(arm_4[1] == 0) then SwissArmyKnifeContainerOutlineWeapon4:SetColor(SAK.settings.colour_arm.r, SAK.settings.colour_arm.g, SAK.settings.colour_arm.b, SAK.settings.colour_arm.a)
		else
			local r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, arm_4[4])
			SwissArmyKnifeContainerOutlineWeapon4:SetColor(r, g, b, 255)
		end
	else
		SwissArmyKnifeContainerWeaponRepair4:SetTexture("esoui/art/windows/gamepad/gp_grunge_scalable.dds") 
		SwissArmyKnifeContainerWeaponRepairLabel4:SetText(" ")
		SwissArmyKnifeContainerWeaponRepairLabel4:SetColor(0, 0, 0, 0)
		SwissArmyKnifeContainerOutlineWeapon4:SetColor(0, 0, 0, 0)
	end
end