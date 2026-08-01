--[[
Addon:    DuelRPG - Gestion avancée des combats JDR
Author:   @neferys
File:     DuelRPGcommon.lua
]]--

-- Local variables
local str = DuelRPG.Strings[DuelRPG.GetLanguage()].TEXT
local _

-- DuelRPG Declaration
if DuelRPG == nil then DuelRPG = {} end

-- Recherche de la Race
function DuelRPG.GetRace()
	return string.gsub( GetUnitRace("player") , "%^.*", "") 
end

local race = zo_strformat(SI_RACE_NAME, GetUnitRace("player"))
local raceCode = DuelRPG.raceTable[race]

-- Recherche de la valeur de l'attribut cac de la race
function DuelRPG.GetAttrCacRace()
	return DuelRPG.CAN_RESEARCH_RACES[raceCode].cacrace
end

-- Recherche de la valeur de l'attribut dist de la race
function DuelRPG.GetAttrDisRace()
	return DuelRPG.CAN_RESEARCH_RACES[raceCode].disrace	
end

-- Recherche de la valeur de l'attribut dext de la race
function DuelRPG.GetAttrDexRace()
	return DuelRPG.CAN_RESEARCH_RACES[raceCode].dexrace	
end

-- Recherche de la valeur de l'attribut magie de la race
function DuelRPG.GetAttrMagRace()
	return DuelRPG.CAN_RESEARCH_RACES[raceCode].magrace
end

-- Recherche de la valeur de l'attribut Constitution de la race
function DuelRPG.GetAttrEndRace()
	return DuelRPG.CAN_RESEARCH_RACES[raceCode].endrace	
end

-------------------------------------------------------------------------

function DuelRPG.GetAttrTypRace(name)
	
	if name == "cac" then
		return DuelRPG.GetAttrCacRace()
	end
	
	if name == "dis" then
		return DuelRPG.GetAttrDisRace()
	end
	
	if name == "dex" then
		return DuelRPG.GetAttrDexRace()
	end
	
	if name == "mag" then
		return DuelRPG.GetAttrMagRace()
	end
	
	if name == "end" then
		return DuelRPG.GetAttrEndRace()
	end
	
end

-------------------------------------------------------------------------

-- Recherche de la valeur de l'attribut cac du personnnage
function DuelRPG.GetAttrCacPerso()
	return DuelRPG.GetAttrCacRace() + DuelRPG.settings.cacperso + 10
end

-- Recherche de la valeur de l'attribut dist du personnnage
function DuelRPG.GetAttrDisPerso()
	return DuelRPG.GetAttrDisRace() + DuelRPG.settings.disperso + 10
end

-- Recherche de la valeur de l'attribut dext du personnnage
function DuelRPG.GetAttrDexPerso()
	return DuelRPG.GetAttrDexRace() + DuelRPG.settings.dexperso + 10
end

-- Recherche de la valeur de l'attribut magie du personnnage
function DuelRPG.GetAttrMagPerso()
	return DuelRPG.GetAttrMagRace() + DuelRPG.settings.magperso + 10
end

-- Recherche de la valeur de l'attribut Constitution du personnnage
function DuelRPG.GetAttrEndPerso()
	return DuelRPG.GetAttrEndRace() + DuelRPG.settings.endperso + 10
end

-------------------------------------------------------------------------

-- Recherche le multiplicateur de l'attribut cac du personnnage
function DuelRPG.GetMultiCacPerso()
	return DuelRPG.Calcul_multi(DuelRPG.GetAttrCacPerso())
end

-- Recherche le multiplicateur de l'attribut dist du personnnage
function DuelRPG.GetMultiDisPerso()
	return DuelRPG.Calcul_multi(DuelRPG.GetAttrDisPerso())
end

-- Recherche le multiplicateur de l'attribut dext du personnnage
function DuelRPG.GetMultiDexPerso()
	return DuelRPG.Calcul_multi(DuelRPG.GetAttrDexPerso())
end

-- Recherche le multiplicateur de l'attribut magie du personnnage
function DuelRPG.GetMultiMagPerso()
	return DuelRPG.Calcul_multi(DuelRPG.GetAttrMagPerso())
end

-- Recherche le multiplicateur de l'attribut Constitution du personnnage
function DuelRPG.GetMultiEndPerso()
	return DuelRPG.Calcul_multi(DuelRPG.GetAttrEndPerso())
end

-------------------------------------------------------------------------

function DuelRPG.GetValAttr()

	return 15 + DuelRPG.GetLevelAttr(DuelRPG.settings.level) + DuelRPG.GetAttrCostCum(DuelRPG.settings.cacperso) + DuelRPG.GetAttrCostCum(DuelRPG.settings.disperso) + DuelRPG.GetAttrCostCum(DuelRPG.settings.dexperso) + DuelRPG.GetAttrCostCum(DuelRPG.settings.magperso) + DuelRPG.GetAttrCostCum(DuelRPG.settings.endperso)

end

-------------------------------------------------------------------------

function DuelRPG.DelAttr(name)

	if name == "cac" then
		if DuelRPG.settings.cacperso+10 > 7 then
			DuelRPG.settings.cacperso = DuelRPG.settings.cacperso - 1								
		end
	end
	if name == "dis" then
		if DuelRPG.settings.disperso+10 > 7 then
			DuelRPG.settings.disperso = DuelRPG.settings.disperso - 1							
		end
	end
	if name == "dex" then
		if DuelRPG.settings.dexperso+10 > 7 then
			DuelRPG.settings.dexperso = DuelRPG.settings.dexperso - 1							
		end
	end
	if name == "mag" then
		if DuelRPG.settings.magperso+10 > 7 then
			DuelRPG.settings.magperso = DuelRPG.settings.magperso - 1						
		end
	end
	if name == "end" then
		if DuelRPG.settings.endperso+10 > 7 then
			DuelRPG.settings.endperso = DuelRPG.settings.endperso - 1					
		end
	end	
end	

-------------------------------------------------------------------------
	
function DuelRPG.getMaxAttr()

	if DuelRPG.settings.cacperso+10 == 18 or DuelRPG.settings.disperso+10 == 18 or DuelRPG.settings.dexperso+10 == 18 or DuelRPG.settings.magperso+10==18 or DuelRPG.settings.endperso+10 == 18 then
		return 17
	else
		return 18
	end

end
	
-------------------------------------------------------------------------
	
function DuelRPG.AddAttr(name)

	if name == "cac" then
		if DuelRPG.settings.cacperso+10 < DuelRPG.getMaxAttr() and DuelRPG.GetValAttr()+DuelRPG.GetAttrCostIndAdd(DuelRPG.settings.cacperso+1) >= 0 then
			DuelRPG.settings.cacperso = DuelRPG.settings.cacperso + 1
		end
	end
	if name == "dis" then
		if DuelRPG.settings.disperso+10 < DuelRPG.getMaxAttr() and DuelRPG.GetValAttr()+DuelRPG.GetAttrCostIndAdd(DuelRPG.settings.disperso+1) >= 0 then
			DuelRPG.settings.disperso = DuelRPG.settings.disperso + 1
		end
	end
	if name == "dex" then
		if DuelRPG.settings.dexperso+10 < DuelRPG.getMaxAttr() and DuelRPG.GetValAttr()+DuelRPG.GetAttrCostIndAdd(DuelRPG.settings.dexperso+1) >= 0 then
			DuelRPG.settings.dexperso = DuelRPG.settings.dexperso + 1
		end
	end
	if name == "mag" then
		if DuelRPG.settings.magperso+10 < DuelRPG.getMaxAttr() and DuelRPG.GetValAttr()+DuelRPG.GetAttrCostIndAdd(DuelRPG.settings.magperso+1) >= 0 then
			DuelRPG.settings.magperso = DuelRPG.settings.magperso + 1
		end
	end
	if name == "end" then
		if DuelRPG.settings.endperso+10 < DuelRPG.getMaxAttr() and DuelRPG.GetValAttr()+DuelRPG.GetAttrCostIndAdd(DuelRPG.settings.endperso+1) >= 0 then
			DuelRPG.settings.endperso = DuelRPG.settings.endperso + 1
		end
	end	
end	

-------------------------------------------------------------------------

function DuelRPG.GetMultiArmor()
	local num_multi
	
	if DuelRPG.GetArmor() == "Sans armure" or DuelRPG.GetArmor() == "Armure légère" then
		num_multi = DuelRPG.GetMultiDexPerso()
	end
	
	if DuelRPG.GetArmor() == "Armure intermédiaire" then		
		if DuelRPG.GetMultiDexPerso() > 2 then
			num_multi = 2
		else
			num_multi = DuelRPG.GetMultiDexPerso()
		end
	end
	
	if DuelRPG.GetArmor() == "Armure lourde" then
		num_multi = 0
	end
	
	if num_multi < 0 then
		num_multi = 0
	end
	
	return num_multi

end

-------------------------------------------------------------------------

function DuelRPG.Reset()
	DuelRPG.settings.cacperso = 0
	DuelRPG.settings.disperso = 0
	DuelRPG.settings.dexperso = 0
	DuelRPG.settings.magperso = 0
	DuelRPG.settings.endperso = 0
	DuelRPG.settings.endcurrent = 0
	DuelRPG.settings.level = 1
	DuelRPG.settings.lifem = 0
	timestamp = GetTimeStamp()
end

-------------------------------------------------------------------------

function DuelRPG.Updatelevel(value)
	DuelRPG.settings.cacperso = 0
	DuelRPG.settings.disperso = 0
	DuelRPG.settings.dexperso = 0
	DuelRPG.settings.magperso = 0
	DuelRPG.settings.endperso = 0
	DuelRPG.settings.level = value
end

-------------------------------------------------------------------------

function DuelRPG.GetTotArmor()
		
	return 10 + DuelRPG.GetMultiArmor() + DuelRPG.CAN_RESEARCH_COMBATS_OPTIONS_ARMOR[DuelRPG.GetArmor()].defearmor + DuelRPG.CAN_RESEARCH_COMBATS_OPTIONS_WEAPON[DuelRPG.GetMainWeapon()].armoweapon + DuelRPG.CAN_RESEARCH_COMBATS_OPTIONS_WEAPON[DuelRPG.GetOffWeapon()].armoweapon

end

-------------------------------------------------------------------------

function DuelRPG.GetMaxLife()

	return (10 + DuelRPG.GetAttrEndPerso() + DuelRPG.GetMultiEndPerso())

end

-------------------------------------------------------------------------

function DuelRPG.GetLife()
	return (10 + DuelRPG.GetAttrEndPerso() + DuelRPG.GetMultiEndPerso()) - DuelRPG.settings.lifem

end

-- Vérification des attributs
function DuelRPG.Checkatb()	
	if DuelRPG.GetValAttr() > 0 then
		d(str.strprefix..DuelRPG.GetValAttr()..str.strpointscheck)
	end
end

function DuelRPG.GetWeaponType(bagId,slotId)
    local icon = GetItemInfo(bagId,slotId)
    
    if (string.find(icon, "1hsword")) then
      return "Epée"
    elseif string.find(icon,"2hsword") then
        return "Epée à deux mains"
    elseif string.find(icon,"1haxe") then
        return "Hache"
    elseif string.find(icon,"2haxe") then
        return "Hache à deux mains"
    elseif string.find(icon,"1hhammer") then
        return "Marteau"
    elseif string.find(icon,"2hhammer") then
        return "Marteau à deux mains"
    elseif string.find(icon,"dagger") then
        return "Dague"
    elseif string.find(icon,"shield") then
        return "Bouclier"
    elseif string.find(icon,"bow") then
        return "Arc"
    elseif string.find(icon,"staff") then
        return "Bâton"
    else
        return "Main nue"
    end
end

function DuelRPG.GetArmorType(bagId,slotId)
    local icon = GetItemInfo(bagId,slotId)
    if (string.find(icon, "heavy")) then
      return "Armure lourde"
    elseif string.find(icon,"medium") then
        return "Armure intermédiaire"
    elseif string.find(icon,"light") then
        return "Armure légère"
    else
        return "Sans armure"
    end
end

function DuelRPG.GetArmor()
	return DuelRPG.GetArmorType(BAG_WORN, EQUIP_SLOT_CHEST)
end

function DuelRPG.GetMainWeapon()
	return DuelRPG.GetWeaponType(BAG_WORN, EQUIP_SLOT_MAIN_HAND)
end

function DuelRPG.GetOffWeapon()
	return DuelRPG.GetWeaponType(BAG_WORN, EQUIP_SLOT_OFF_HAND)
end