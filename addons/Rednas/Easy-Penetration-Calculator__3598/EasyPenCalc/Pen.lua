EPC = EPC or {}
EPC.PEN = EPC.PEN or {}

function EPC.PEN.UpdateSummaryValues()
	local debuffValue, passivesValue, groupValue, playerValue = EPC.PEN.CalculateSelectedPen()
	local penLeftValue = EPC.Values.Pen.required - debuffValue - passivesValue - groupValue - playerValue
	local dmgLossValue = math.floor(penLeftValue/5)/100
	local dmgGainValue = math.floor(dmgLossValue/(100-dmgLossValue)*10000)/100
	EPC.PEN.SetSummaryValues(
		debuffValue, 
		passivesValue, 
		groupValue, 
		playerValue, 
		penLeftValue, 
		dmgLossValue < 0 and 0 or dmgLossValue, 
		dmgGainValue < 0 and 0 or dmgGainValue
	)
end

function EPC.PEN.CalculateSelectedPen()
	local debuffValue = EPC.PEN.CalculateSelectedDebuffValue()
	local passivesValue = EPC.PEN.CalculateSelectedPassivesValue()
	local groupValue = EPC.PEN.CalculateSelectedGroupValue()
	local playerValue = EPC.PEN.CalculateSelectedPlayerValue()
	return debuffValue, passivesValue, groupValue, playerValue
end

function EPC.PEN.SetSummaryValues(debuff, passive, group, player, penLeft, dmgLoss, dmgGain)
	EPC.GUI.Summary.Debuff.numberLabel:SetText(debuff)
	EPC.GUI.Summary.Passive.numberLabel:SetText(passive)
	EPC.GUI.Summary.Group.numberLabel:SetText(group)
	EPC.GUI.Summary.Player.numberLabel:SetText(player)
	EPC.GUI.Summary.PenLeft.numberLabel:SetText(penLeft)
	EPC.GUI.Summary.DmgLoss.numberLabel:SetText(dmgLoss)
	EPC.GUI.Summary.DmgGain.numberLabel:SetText(dmgGain)
	
	EPC.PEN.UpdateResultColors(penLeft)
end

function EPC.PEN.CalculateSelectedDebuffValue()
	local value = 0
	value = value + (EPC.FormField["MajorBreach"].value and EPC.Values.Pen.majorBreach or 0)
	value = value + (EPC.FormField["MinorBreach"].value and EPC.Values.Pen.minorBreach or 0)
	value = value + (EPC.FormField["CrystalWeapon"].value and EPC.Values.Pen.crystalWeapon or 0)
	value = value + (EPC.FormField["RunicSunder"].value and EPC.Values.Pen.runicSunder or 0)
	
	return value
end

function EPC.PEN.CalculateSelectedPassivesValue()
	local value = 0
	value = value + (EPC.FormField["NightbladePassive"].value and EPC.Values.Pen.nightbladePassive or 0)
	value = value + (EPC.FormField["NecromancerPassive"].value and EPC.Values.Pen.necromancerPassive or 0)
	value = value + (EPC.FormField["CPPassive"].value and EPC.Values.Pen.cPPassive or 0)
	value = value + (EPC.FormField["WoodElfPassive"].value and EPC.Values.Pen.woodElfPassive or 0)
	value = value +  EPC.FormField["AmountOfDebuffsForForceOfNature"].value*EPC.Values.Pen.forceOfNatureSingle
	value = value +  EPC.FormField["AmountOfSkillsSlottedForArcanistPassive"].value*EPC.Values.Pen.arcanistPassiveSingle
	value = value + (EPC.FormField["LoverMundus"].value ~= 0 and EPC.Values.Pen.loverMundus[EPC.FormField["LoverMundus"].value] or 0)
	
	return value
end

function EPC.PEN.CalculateSelectedGroupValue()
	local value = 0
	value = value + (EPC.FormField["Tremorscale"].value and EPC.Values.Pen.tremorscale or 0)
	value = value + (EPC.FormField["Alkosh"].value and EPC.Values.Pen.alkosh or 0)
	value = value + (EPC.FormField["CrimsonOath"].value and EPC.Values.Pen.crimsonOath or 0)
	value = value + (EPC.FormField["Crusher"].value ~= 0 and EPC.Values.Pen.Crusher[EPC.FormField["Crusher"].value] or 0)
	
	return value
end

function EPC.PEN.CalculateSelectedPlayerValue()
	local value = 0
	value = value + (EPC.FormField["ArenaWeapon"].value and EPC.Values.Pen.arenaWeapon or 0)
	value = value + (EPC.FormField["ShatteredFate"].value and EPC.Values.Pen.shatteredFate or 0)
	value = value + (EPC.FormField["VelothiUr"].value and EPC.Values.Pen.velothiUr or 0)
	value = value + EPC.FormField["AmountOfPenLines"].value*EPC.Values.Pen.penLine
	value = value + EPC.FormField["AmountOfLightPieces"].value*EPC.Values.Pen.lightPiece
	value = value + (EPC.FormField["Weapon"].value ~= 0 and EPC.Values.Pen.Weapon[EPC.FormField["Weapon"].value] or 0)
	value = value + (EPC.FormField["Sharpend"].value ~= 0 and EPC.Values.Pen.Sharpend[EPC.FormField["Sharpend"].value] or 0)
	
	return value
end

function EPC.PEN.UpdateResultColors(penLeft)
	local color = {r = 255, g = 0, b = 0}
	penLeft = penLeft < 0 and -penLeft or penLeft
	local colorAdjust = -(penLeft-(EPC.Values.Pen.required/2))/(EPC.Values.Pen.required/2)
	colorAdjust = EPC.Util.ClampNumber(colorAdjust, 0, 1)
	color.g = math.floor(255*colorAdjust)	
	color.r = 255-math.floor(129*colorAdjust)

	
	EPC.GUI.Summary.PenLeft.numberLabel:SetColor(color.r/255, color.g/255, color.b/255)
	EPC.GUI.Summary.DmgLoss.numberLabel:SetColor(color.r/255, color.g/255, color.b/255)
end

function EPC.PEN.ResetToDefaults()
	for k, v in pairs(EPC.FormField) do
		--Check if there is a default value
		if EPC.FormFieldDefaultValue[k] ~= nil then
			--Set value to the default (can't use v.value since it's not a reference)
			EPC.FormField[k].value = EPC.FormFieldDefaultValue[k]
			--Refresh FormField
			v:Refresh()
		end
	end
	EPC.PEN.UpdateSummaryValues()
end

