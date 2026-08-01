ESOLanguageOverrider = {}
ESOLanguageOverrider.AddonName = "ESOLanguageOverrider"

ESOLanguageOverrider.items = {}
ESOLanguageOverrider.pociones = {}
ESOLanguageOverrider.skills = {}

local porDefecto = {}

porDefecto.estiloTooltip = 1 -- 1: Reemplaza / 2: Añade
porDefecto.traducirPociones = true
porDefecto.traducirHabilidades = true
porDefecto.traducirAlimentos = true
porDefecto.traducirGlifos = true
porDefecto.traducirEquipo = true
porDefecto.traducirMateriales = true
porDefecto.traducirOtros = true

local function itemEquipado(slot)
	return GetItemLink(BAG_WORN, slot)
end

local function obtenerLink(link)
	return link
end

local function obtenerId(id)
	return id
end

local function obtenerSkill(skillType, skillLineIndex, skillIndex)
	return GetSkillAbilityId(skillType, skillLineIndex, skillIndex, true)
end

local nombreOriginal = GetString(SI_TOOLTIP_ITEM_NAME)
ESOLanguageOverrider.entraEnSkill = ZO_Skills_AbilitySlot_OnMouseEnter
ESOLanguageOverrider.saleDeSkill = AbilitySlotOnMouseExitOrg

local function comprobarTraduccion(tipoObjeto)
	local retorno = false
	if tipoObjeto == ITEMTYPE_ARMOR or tipoObjeto == ITEMTYPE_WEAPON then
		retorno = ESOLanguageOverrider.variables.traducirEquipo
	elseif tipoObjeto == ITEMTYPE_FOOD or tipoObjeto == ITEMTYPE_DRINK then
		retorno = ESOLanguageOverrider.variables.traducirAlimentos
	elseif tipoObjeto == ITEMTYPE_GLYPH_ARMOR or tipoObjeto == ITEMTYPE_GLYPH_JEWELRY or tipoObjeto == ITEMTYPE_GLYPH_WEAPON then
		retorno = ESOLanguageOverrider.variables.traducirGlifos
	elseif tipoObjeto == ITEMTYPE_STYLE_MATERIAL or tipoObjeto == ITEMTYPE_RAW_MATERIAL or tipoObjeto == ITEMTYPE_ARMOR_TRAIT or tipoObjeto == ITEMTYPE_WEAPON_TRAIT or tipoObjeto == ITEMTYPE_JEWELRY_RAW_TRAIT or tipoObjeto == ITEMTYPE_JEWELRY_TRAIT then
		retorno = ESOLanguageOverrider.variables.traducirMateriales
	elseif tipoObjeto == ITEMTYPE_INGREDIENT or tipoObjeto == ITEMTYPE_LURE or tipoObjeto == ITEMTYPE_FURNISHING_MATERIAL then
		retorno = ESOLanguageOverrider.variables.traducirMateriales
	elseif tipoObjeto == ITEMTYPE_ENCHANTING_RUNE_ASPECT or tipoObjeto == ITEMTYPE_ENCHANTING_RUNE_ESSENCE or tipoObjeto == ITEMTYPE_ENCHANTING_RUNE_POTENCY then
		retorno = ESOLanguageOverrider.variables.traducirMateriales
	elseif tipoObjeto == ITEMTYPE_POISON_BASE or tipoObjeto == ITEMTYPE_POTION or tipoObjeto == ITEMTYPE_REAGENT then
		retorno = ESOLanguageOverrider.variables.traducirMateriales
	elseif tipoObjeto == ITEMTYPE_JEWELRYCRAFTING_BOOSTER or tipoObjeto == ITEMTYPE_JEWELRYCRAFTING_MATERIAL or tipoObjeto == ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER or tipoObjeto == ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL then
		retorno = ESOLanguageOverrider.variables.traducirMateriales
	elseif tipoObjeto == ITEMTYPE_WOODWORKING_BOOSTER or tipoObjeto == ITEMTYPE_WOODWORKING_MATERIAL or tipoObjeto == ITEMTYPE_WOODWORKING_RAW_MATERIAL then
		retorno = ESOLanguageOverrider.variables.traducirMateriales
	elseif tipoObjeto == ITEMTYPE_CLOTHIER_BOOSTER or tipoObjeto == ITEMTYPE_CLOTHIER_MATERIAL or tipoObjeto == ITEMTYPE_CLOTHIER_RAW_MATERIAL then
		retorno = ESOLanguageOverrider.variables.traducirMateriales
	elseif tipoObjeto == ITEMTYPE_BLACKSMITHING_BOOSTER or tipoObjeto == ITEMTYPE_BLACKSMITHING_MATERIAL or tipoObjeto == ITEMTYPE_BLACKSMITHING_RAW_MATERIAL then
		retorno = ESOLanguageOverrider.variables.traducirMateriales
	else
		retorno = ESOLanguageOverrider.variables.traducirOtros
	end
	return retorno
end

local function sobreEscribirToolTip(tt, fn, obtenerObjeto)
	local base = tt[fn]
	tt[fn] = function(control, ...)
		local itemLink = obtenerObjeto(...)
		local modificado = false
		
		local formato
		
		if (GetItemLinkItemId(itemLink) ~= nil) then
			local tipoObjeto = GetItemLinkItemType(itemLink)
			if tipoObjeto == ITEMTYPE_POTION then
				if ESOLanguageOverrider.variables.traducirPociones then
					local traduccionPocion = ESOLanguageOverrider.pociones[GetItemLinkItemId(itemLink)]
					if traduccionPocion ~= nil then
						local nivel = GetItemLinkRequiredChampionPoints(itemLink)+GetItemLinkRequiredLevel(itemLink)
						local valor = 0
						if nivel > 0 then
							for v in pairs(traduccionPocion) do 
								if nivel < v and (valor == 0 or valor > v) then
									valor = v
								end
							end
							if valor ~= 0 then				
								if ESOLanguageOverrider.variables.estiloTooltip == 2 then
									formato = string.format(nombreOriginal .. "\n[" .. traduccionPocion[valor] .. "]")
								else
									formato = string.format(traduccionPocion[valor])
								end
								
								SafeAddString(SI_TOOLTIP_ITEM_NAME, formato, 2)
							end 
						else
							if ESOLanguageOverrider.variables.estiloTooltip == 2 then
								formato = string.format(nombreOriginal .. "\n[" .. traduccionPocion[valor] .. "]")
							else
								formato = string.format(traduccionPocion[0])
							end
							
							SafeAddString(SI_TOOLTIP_ITEM_NAME, formato, 2)
						end
						modificado = true
					end
				end 
			else
				if comprobarTraduccion(tipoObjeto) then
					local traduccionItem = ESOLanguageOverrider.items[GetItemLinkItemId(itemLink)]
					if traduccionItem ~= nil then
						if ESOLanguageOverrider.variables.estiloTooltip == 2 then
							traduccionItem = nombreOriginal .. "\n[" .. traduccionItem .. "]"
						end
						formato = string.format(traduccionItem)
						SafeAddString(SI_TOOLTIP_ITEM_NAME, formato, 2)
						modificado = true
					end
				end 
			end
		end
			
		if modificado then			
			local resultado = base(control, ...)
			SafeAddString(SI_TOOLTIP_ITEM_NAME, "<<1>>", 2)
			return resultado
		else
			return base(control, ...)
		end
	end
end

local function comparativa(tooltip, tipo, ...)
	if tipo == TOOLTIP_GAME_DATA_EQUIPPED_INFO and ESOLanguageOverrider.variables.traducirEquipo then
		local itemLink = itemEquipado(...)
		
		if (GetItemLinkItemId(itemLink) ~= nil) then
			local traduccionItem = ESOLanguageOverrider.items[GetItemLinkItemId(itemLink)]
			if (traduccionItem ~= nil) then
				if ESOLanguageOverrider.variables.estiloTooltip == 2 then
					traduccionItem = nombreOriginal .. "\n[" .. traduccionItem .. "]"
				end
				local formato = string.format(traduccionItem)
				SafeAddString(SI_TOOLTIP_ITEM_NAME, formato, 2)
			else
				SafeAddString(SI_TOOLTIP_ITEM_NAME, nombreOriginal, 2)
			end
		else
			SafeAddString(SI_TOOLTIP_ITEM_NAME, nombreOriginal, 2)
		end
	elseif tipo == TOOLTIP_GAME_DATA_STOLEN then
		SafeAddString(SI_TOOLTIP_ITEM_NAME, nombreOriginal, 2)
	end
end

function ESOLanguageOverrider.crearMenu()
	local LAM = LibStub("LibAddonMenu-2.0")

	local panelInfo = {
		type = "panel",
		name = "ESO Languate Overrider",
		displayName = "ESO Language Overrider",
		author = "Hevnokaaz",
		version = "1.04",
		registerForRefresh = true
	}

	LAM:RegisterAddonPanel(ESOLanguageOverrider.AddonName .. "_Opciones", panelInfo)

	local opciones = {
		{
			type = "header",
			name = "Opciones",
		},
		{
			type = "checkbox",
			name = "Show both languages",
			tooltip = "If checked, tooltip titles will show both current and [english] names",
			getFunc = function() if ESOLanguageOverrider.variables.estiloTooltip == 2 then return true else return false end end,
			setFunc = function(value)
				if value then
					ESOLanguageOverrider.variables.estiloTooltip = 2
				else
					ESOLanguageOverrider.variables.estiloTooltip = 1
				end
			end,
		},
		{
			type = "checkbox",
			name = "Translate equipment",
			tooltip = "If checked, equipment names will be translated",
			getFunc = function() return ESOLanguageOverrider.variables.traducirEquipo end,
			setFunc = function(value)
					ESOLanguageOverrider.variables.traducirEquipo = value
			end,
		},
		{
			type = "checkbox",
			name = "Translate skills",
			tooltip = "If checked, skill names will be translated",
			getFunc = function() return ESOLanguageOverrider.variables.traducirHabilidades end,
			setFunc = function(value)
					ESOLanguageOverrider.variables.traducirHabilidades = value
			end,
		},
		{
			type = "checkbox",
			name = "Translate food/drink",
			tooltip = "If checked, foot and drink names will be translated",
			getFunc = function() return ESOLanguageOverrider.variables.traducirAlimentos end,
			setFunc = function(value)
					ESOLanguageOverrider.variables.traducirAlimentos = value
			end,
		},
		{
			type = "checkbox",
			name = "Translate glyphs",
			tooltip = "If checked, glyphs names will be translated",
			getFunc = function() return ESOLanguageOverrider.variables.traducirGlifos end,
			setFunc = function(value)
					ESOLanguageOverrider.variables.traducirGlifos = value
			end,
		},
		{
			type = "checkbox",
			name = "Translate materials",
			tooltip = "If checked, materials names will be translated",
			getFunc = function() return ESOLanguageOverrider.variables.traducirMateriales end,
			setFunc = function(value)
					ESOLanguageOverrider.variables.traducirMateriales = value
			end,
		},
		{
			type = "checkbox",
			name = "Translate potions",
			tooltip = "If checked, potion names will be translated",
			getFunc = function() return ESOLanguageOverrider.variables.traducirPociones end,
			setFunc = function(value)
					ESOLanguageOverrider.variables.traducirPociones = value
			end,
		},
		{
			type = "checkbox",
			name = "Translate other items",
			tooltip = "If checked, other items names will be translated",
			getFunc = function() return ESOLanguageOverrider.variables.traducirOtros end,
			setFunc = function(value)
					ESOLanguageOverrider.variables.traducirOtros = value
			end,
		}
	}

	LAM:RegisterOptionControls(ESOLanguageOverrider.AddonName .. "_Opciones", opciones)
end



function ESOLanguageOverrider:Init()

	ESOLanguageOverrider.variables = ZO_SavedVars:NewCharacterIdSettings("ESOLanguageOverriderVariables", 1, nil, porDefecto)

	sobreEscribirToolTip(ItemTooltip, "SetAttachedMailItem", GetAttachedItemLink)
	sobreEscribirToolTip(ItemTooltip, "SetBagItem", GetItemLink)
	sobreEscribirToolTip(ItemTooltip, "SetBuybackItem", GetBuybackItemLink)
	sobreEscribirToolTip(ItemTooltip, "SetLootItem", GetLootItemLink)
	sobreEscribirToolTip(ItemTooltip, "SetTradeItem", GetTradeItemLink)
	sobreEscribirToolTip(ItemTooltip, "SetStoreItem", GetStoreItemLink)
	sobreEscribirToolTip(ItemTooltip, "SetTradingHouseListing", GetTradingHouseListingItemLink)
	sobreEscribirToolTip(ItemTooltip, "SetWornItem", itemEquipado)
	sobreEscribirToolTip(ItemTooltip, "SetQuestReward", GetQuestRewardItemLink)
	sobreEscribirToolTip(PopupTooltip, "SetLink", obtenerLink)
	sobreEscribirToolTip(ItemTooltip, "SetTradingHouseItem", GetTradingHouseSearchResultItemLink)
	sobreEscribirToolTip(ItemTooltip, "SetLink", obtenerLink)
	
	 

	ZO_PreHookHandler(ComparativeTooltip1, "OnAddGameData", comparativa)
	ZO_PreHookHandler(ComparativeTooltip2, "OnAddGameData", comparativa)
	
	local SkillsAbilitySlotOnMouseEnterOriginal = ZO_Skills_AbilitySlot_OnMouseEnter
	ZO_Skills_AbilitySlot_OnMouseEnter = function(control)
		local skillType, skillLineIndex, skillIndex = control.skillProgressionData:GetIndices()
		local ability = control:GetParent()
		local idHabilidad = GetSkillAbilityId(skillType, skillLineIndex, skillIndex)
		local nombreHabilidad, texturaHabilidad, rangoHabilidad, esPasivaHabilidad, esUltimateHabilidad, compradaHabilidad, progresionHabilidad, rangoMaximoHabilidad =  GetSkillAbilityInfo(skillType, skillLineIndex, skillIndex)
		local miRango = ""
			if rangoMaximoHabilidad > 0 and not esPasivaHabilidad then
				if rangoMaximoHabilidad == 1 then
					miRango = " I"
				elseif rangoMaximoHabilidad == 2 then
					miRango = " II"
				elseif rangoMaximoHabilidad == 3 then
					miRango = " III"
				else
					miRango = " IV"
				end
			else
				miRango = ""
			end
		if ESOLanguageOverrider.variables.traducirHabilidades then
			local traduccionHabilidad = ESOLanguageOverrider.skills[idHabilidad]
			if (traduccionHabilidad ~= nil) then
				if ESOLanguageOverrider.variables.estiloTooltip == 2 then
					traduccionHabilidad = nombreHabilidad .. miRango .. "\n[" .. traduccionHabilidad .. miRango .. "]"
				end
				local formato = string.format(traduccionHabilidad)
				if esPasivaHabilidad then
					SafeAddString(SI_ABILITY_TOOLTIP_NAME, formato, 1)
				elseif compradaHabilidad then
					SafeAddString(SI_ABILITY_NAME_AND_RANK, formato, 1)
				elseif progresionHabilidad ~= nil then
					SafeAddString(SI_ABILITY_NAME_AND_RANK, formato, 1)
				else
					SafeAddString(SI_ABILITY_TOOLTIP_NAME, formato, 1)
				end
			else
				if esPasivaHabilidad then
					SafeAddString(SI_ABILITY_TOOLTIP_NAME, nombreHabilidad .. miRango, 1)
				elseif compradaHabilidad then
					SafeAddString(SI_ABILITY_NAME_AND_RANK, nombreHabilidad .. miRango, 1)
				elseif progresionHabilidad ~= nil then
					SafeAddString(SI_ABILITY_NAME_AND_RANK, nombreHabilidad .. miRango, 1)
				else
					SafeAddString(SI_ABILITY_TOOLTIP_NAME, nombreHabilidad .. miRango, 1)
				end
			end
		end 
		SkillsAbilitySlotOnMouseEnterOriginal(control)
		SafeAddString(SI_ABILITY_NAME_AND_RANK, "<<1>>" .. miRango, 1)
		SafeAddString(SI_ABILITY_TOOLTIP_NAME, "<<1>>", 1)
	end	
	
	local SkillsAdvisorOnMouseEnterOriginal = ZO_SkillsAdvisor_OnMouseEnter
	ZO_SkillsAdvisor_OnMouseEnter = function(control)
		local skillType, skillLineIndex, skillIndex = control.skillProgressionData:GetIndices()
		local ability = control:GetParent()
		local idHabilidad = GetSkillAbilityId(skillType, skillLineIndex, skillIndex)
		local nombreHabilidad, texturaHabilidad, rangoHabilidad, esPasivaHabilidad, esUltimateHabilidad, compradaHabilidad, progresionHabilidad, rangoMaximoHabilidad =  GetSkillAbilityInfo(skillType, skillLineIndex, skillIndex)
		local miRango = ""
			if rangoMaximoHabilidad > 0 and not esPasivaHabilidad then
				if rangoMaximoHabilidad == 1 then
					miRango = " I"
				elseif rangoMaximoHabilidad == 2 then
					miRango = " II"
				elseif rangoMaximoHabilidad == 3 then
					miRango = " III"
				else
					miRango = " IV"
				end
			else
				miRango = ""
			end
		if ESOLanguageOverrider.variables.traducirHabilidades then
			local traduccionHabilidad = ESOLanguageOverrider.skills[idHabilidad]
			if (traduccionHabilidad ~= nil) then
				if ESOLanguageOverrider.variables.estiloTooltip == 2 then
					traduccionHabilidad = nombreHabilidad .. miRango .. "\n[" .. traduccionHabilidad .. miRango .. "]"
				end
				local formato = string.format(traduccionHabilidad)
				if esPasivaHabilidad then
					SafeAddString(SI_ABILITY_TOOLTIP_NAME, formato, 1)
				elseif compradaHabilidad then
					SafeAddString(SI_ABILITY_NAME_AND_RANK, formato, 1)
				elseif progresionHabilidad ~= nil then
					SafeAddString(SI_ABILITY_NAME_AND_RANK, formato, 1)
				else
					SafeAddString(SI_ABILITY_TOOLTIP_NAME, formato, 1)
				end
			else
				if esPasivaHabilidad then
					SafeAddString(SI_ABILITY_TOOLTIP_NAME, nombreHabilidad .. miRango, 1)
				elseif compradaHabilidad then
					SafeAddString(SI_ABILITY_NAME_AND_RANK, nombreHabilidad .. miRango, 1)
				elseif progresionHabilidad ~= nil then
					SafeAddString(SI_ABILITY_NAME_AND_RANK, nombreHabilidad .. miRango, 1)
				else
					SafeAddString(SI_ABILITY_TOOLTIP_NAME, nombreHabilidad .. miRango, 1)
				end
			end
		end 
		SkillsAdvisorOnMouseEnterOriginal(control)
		SafeAddString(SI_ABILITY_NAME_AND_RANK, "<<1>>" .. miRango, 1)
		SafeAddString(SI_ABILITY_TOOLTIP_NAME, "<<1>>", 1)
	end		

	ESOLanguageOverrider:cargarItems()
	ESOLanguageOverrider:cargarPociones()
	ESOLanguageOverrider:cargarSkills()
	
	ESOLanguageOverrider.crearMenu()


end

local function OnAddOnLoaded(eventCode, addOnName)
    if(addOnName ~= ESOLanguageOverrider.AddonName) then
	return
    end

	EVENT_MANAGER:UnregisterForEvent(ESOLanguageOverrider.AddonName, EVENT_ADD_ON_LOADED)

	ESOLanguageOverrider:Init()
end

EVENT_MANAGER:RegisterForEvent(ESOLanguageOverrider.AddonName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

function ELOestilo(valor) 
	ESOLanguageOverrider.estiloTooltip = valor
end