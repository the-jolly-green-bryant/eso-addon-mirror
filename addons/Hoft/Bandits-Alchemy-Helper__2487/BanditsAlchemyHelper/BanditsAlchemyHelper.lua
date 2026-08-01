local AddonName,AddonVersion="BanditsAlchemyHelper",1.6
local TraitsFilter,FilterTraits,AlchemyCrafting={}
local SCROLL_DATA_TYPE_SOLVENT,SCROLL_DATA_TYPE_REAGENT=1,2
local PlayerLevel,PlayerCP
local SavedVars
local SlotIcon,SlotBlank="esoui/art/actionbar/actionslot_toggledon.dds","esoui/art/buttons/plus_up.dds"
local ActiveTooltip
local QUALITY_COLOR={[0]={0,0,0,1},[1]={1,1,1,1},[2]={.17,.77,.05,1},[3]={.22,.57,1,1},[4]={.62,.18,.96,1},[5]={.80,.66,.10,1}}
local isReagent={
[ITEMTYPE_POISON_BASE]=true,
[ITEMTYPE_POTION_BASE]=true,
[ITEMTYPE_REAGENT]=true
}

local Localization={
	de={	--Provided by Saenic
		["Show unknown traits"]="Zeige Eigenschaften",
		["Solvent level filter"]="Lösungsmittel Filter",

		["Maim"]="Verkrüppeln",
		["Gradual Ravage Health"]="Langsame Lebensverwüstung",
		["Invisible"]="Unsichtbarkeit",
		["Spell Critical"]= "Kritische Magietreffer",
		["Enervation"]="Schwäche",
		["Defile"]="Schänden",
		["Restore Health"]="Leben wiederherstellen",
		["Increase Weapon Power"]="Erhöht Waffenkraft",
		["Entrapment"]="Einfangen",
		["Speed"]="Tempo",
		["Increase Spell Power"]="Erhöht Magiekraft",
		["Restore Magicka"]="Magicka wiederherstellen",
		["Vitality"]="Vitalität",
		["Weapon Critical"]="Kritische Waffentreffer",
		["Protection"]="Schutz",
		["Fracture"]="Fraktur",
		["Unstoppable"]="Sicherer Stand",
		["Detection"]="Detektion",
		["Ravage Stamina"]="Ausdauerverwüstung",
		["Restore Stamina"]="Ausdauer wiederherstellen",
		["Increase Spell Resist"]="Erhöht Magieresistenz",
		["Increase Armor"]="Erhöht Rüstung",
		["Cowardice"]="Feigheit",
		["Ravage Magicka"]="Magickaverwüstung",
		["Uncertainty"]="Ungewissheit",
		["Ravage Health"]="Lebensverwüstung",
		["Lingering Health"]="Beständige Heilung",
		["Hindrance"]="Einschränken",
		["Vulnerability"]="Verwundbarkeit",
		["Breach"]="Bruch",
		["Heroism"]="Heldentum",
	},
	ru={
		["Show unknown traits"]="Неизвестные свойства",
		["Solvent level filter"]="Фильтр растворителей",

		["Maim"]="Повреждение",
		["Gradual Ravage Health"]="Постепенное опустошение здоровья",
		["Invisible"]="Невидимость",
		["Spell Critical"]="Крит. рейтинг заклинаний",
		["Enervation"]="Бессилие",
		["Defile"]="Осквернение",
		["Restore Health"]="Восстановление здоровья",
		["Increase Weapon Power"]="Увеличение силы оружия",
		["Entrapment"]="Захват",
		["Speed"]="Скорость",
		["Increase Spell Power"]="Увеличение силы заклинаний",
		["Restore Magicka"]="Восстановление магии",
		["Vitality"]="Живучесть",
		["Weapon Critical"]="Крит. рейтинг оружия",
		["Protection"]="Защита",
		["Fracture"]="Перелом",
		["Unstoppable"]="Неудержимость",
		["Detection"]="Обнаружение",
		["Ravage Stamina"]="Опустошение стамины",
		["Restore Stamina"]="Восстановление стамины",
		["Increase Spell Resist"]="Увеличение магического сопротивления",
		["Increase Armor"]="Увеличение показателя брони",
		["Cowardice"]="Трусость",
		["Ravage Magicka"]="Опустошение магии",
		["Uncertainty"]="Неуверенность",
		["Ravage Health"]="Опустошение здоровья",
		["Lingering Health"]="Длительное исцеление",
		["Hindrance"]="Замедление",
		["Vulnerability"]="Уязвимость",
		["Breach"]="Прорыв",
		["Heroism"]="Героизм",
	},
	es={	--Provided by NecroFenix
		["Show unknown traits"]="Mostrar Efectos",
		["Solvent level filter"]="Filtrar Solventes",

		["Maim"]="Mutilación",
		["Gradual Ravage Health"]="Reducción de Salud Insidioso",
		["Invisible"]="Invisible",
		["Spell Critical"]="Crítico Mágico",
		["Enervation"]="Debilitación",
		["Defile"]="Profanación",
		["Restore Health"]="Restauración de Salud",
		["Increase Weapon Power"]="Aumento del Poder Físico",
		["Entrapment"]="Captura",
		["Speed"]="Velocidad",
		["Increase Spell Power"]="Aumento de Potencia Mágica",
		["Restore Magicka"]="Restauración de Magia",
		["Vitality"]="Vitalidad",
		["Weapon Critical"]="Crítico Físico",
		["Protection"]="Protección",
		["Fracture"]="Fractura",
		["Unstoppable"]="Imparable",
		["Detection"]="Detección",
		["Ravage Stamina"]="Reducción de Aguante",
		["Restore Stamina"]="Restauración de Aguante",
		["Increase Spell Resist"]="Aumento de Resistencia Mágica",
		["Increase Armor"]="Aumento de Armadura",
		["Cowardice"]="Cobardía",
		["Ravage Magicka"]="Reducción de Magia",
		["Uncertainty"]="Incertidumbre",
		["Ravage Health"]="Reducción de Salud",
		["Lingering Health"]="Salud Prolongada",
		["Hindrance"]="Torpeza",
		["Vulnerability"]="Vulnerabilidad",
		["Breach"]="Fisura",
		["Heroism"]="Heroismo",
	}
}

local lang=GetCVar("language.2")
local function Loc(var)
	if (Localization[lang] and Localization[lang][var]) then
		return Localization[lang][var]
	end

	return var
end

local ReagentTraits={
	[30159]={[1]="Weapon Critical",[2]="Hindrance",[3]="Detection",[4]="Unstoppable"},
	[77581]={[1]="Fracture",[2]="Enervation",[3]="Detection",[4]="Vitality"},
	[30148]={[1]="Ravage Magicka",[2]="Cowardice",[3]="Restore Health",[4]="Invisible"},
	[150789]={[1]="Heroism",[2]="Vulnerability",[3]="Invisible",[4]="Vitality"},
	[30166]={[1]="Restore Health",[2]="Spell Critical",[3]="Weapon Critical",[4]="Entrapment"},
	[30151]={[1]="Ravage Health",[2]="Ravage Magicka",[3]="Ravage Stamina",[4]="Entrapment"},
	[30152]={[1]="Breach",[2]="Ravage Health",[3]="Increase Spell Power",[4]="Ravage Magicka"},
	[30153]={[1]="Spell Critical",[2]="Speed",[3]="Invisible",[4]="Unstoppable"},
	[30154]={[1]="Cowardice",[2]="Ravage Magicka",[3]="Increase Spell Resist",[4]="Detection"},
	[150731]={[1]="Lingering Health",[2]="Restore Stamina",[3]="Heroism",[4]="Defile"},
	[139020]={[1]="Increase Spell Resist",[2]="Hindrance",[3]="Vulnerability",[4]="Defile"},
	[30157]={[1]="Restore Stamina",[2]="Increase Weapon Power",[3]="Ravage Health",[4]="Speed"},
	[30158]={[1]="Increase Spell Power",[2]="Restore Magicka",[3]="Breach",[4]="Spell Critical"},
	[77583]={[1]="Breach",[2]="Increase Armor",[3]="Protection",[4]="Vitality"},
	[30160]={[1]="Increase Spell Resist",[2]="Restore Health",[3]="Cowardice",[4]="Restore Magicka"},
	[77585]={[1]="Restore Health",[2]="Uncertainty",[3]="Lingering Health",[4]="Vitality"},
	[30162]={[1]="Increase Weapon Power",[2]="Restore Stamina",[3]="Fracture",[4]="Weapon Critical"},
	[77587]={[1]="Ravage Stamina",[2]="Vulnerability",[3]="Gradual Ravage Health",[4]="Vitality"},
	[30164]={[1]="Restore Health",[2]="Restore Magicka",[3]="Restore Stamina",[4]="Unstoppable"},
	[30165]={[1]="Ravage Health",[2]="Uncertainty",[3]="Enervation",[4]="Invisible"},
	[77590]={[1]="Ravage Health",[2]="Protection",[3]="Gradual Ravage Health",[4]="Defile"},
	[77591]={[1]="Increase Spell Resist",[2]="Increase Armor",[3]="Protection",[4]="Defile"},
	[30149]={[1]="Fracture",[2]="Ravage Health",[3]="Increase Weapon Power",[4]="Ravage Stamina"},
	[77584]={[1]="Hindrance",[2]="Invisible",[3]="Lingering Health",[4]="Defile"},
	[77589]={[1]="Ravage Magicka",[2]="Speed",[3]="Vulnerability",[4]="Lingering Health"},
	[139019]={[1]="Lingering Health",[2]="Speed",[3]="Vitality",[4]="Protection"},
	[30163]={[1]="Increase Armor",[2]="Restore Health",[3]="Maim",[4]="Restore Stamina"},
	[30161]={[1]="Restore Magicka",[2]="Increase Spell Power",[3]="Ravage Health",[4]="Detection"},
	[30155]={[1]="Ravage Stamina",[2]="Maim",[3]="Restore Health",[4]="Hindrance"},
	[30156]={[1]="Maim",[2]="Ravage Stamina",[3]="Increase Armor",[4]="Enervation"}
}

local TraitIcons={
	["Maim"]="alchemy_trait_lowerweaponpower",
	["Gradual Ravage Health"]="poison_trait_dot",
	["Invisible"]="alchemy_trait_invisible",
	["Spell Critical"]="alchemy_trait_spellcrit",
	["Enervation"]="alchemy_trait_lowerweaponcrit",
	["Defile"]="poison_trait_decreasehealing",
	["Restore Health"]="alchemy_trait_restorehealth",
	["Increase Weapon Power"]="alchemy_trait_increaseweaponpower",
	["Entrapment"]="alchemy_trait_stun",
	["Speed"]="alchemy_trait_speed",
	["Increase Spell Power"]="alchemy_trait_increasespellpower",
	["Restore Magicka"]="alchemy_trait_restoremagicka",
	["Vitality"]="poison_trait_increasehealing",
	["Weapon Critical"]="alchemy_trait_weaponcrit",
	["Protection"]="poison_trait_protection",
	["Fracture"]="alchemy_trait_lowerarmor",
	["Unstoppable"]="alchemy_trait_unstoppable",
	["Detection"]="alchemy_trait_detection",
	["Ravage Stamina"]="alchemy_trait_ravagestamina",
	["Restore Stamina"]="alchemy_trait_restorestamina",
	["Increase Spell Resist"]="alchemy_trait_increasespellresist",
	["Increase Armor"]="alchemy_trait_increasearmor",
	["Cowardice"]="alchemy_trait_lowerspellpower",
	["Ravage Magicka"]="alchemy_trait_ravagemagicka",
	["Uncertainty"]="alchemy_trait_lowerspellcrit",
	["Ravage Health"]="alchemy_trait_ravagehealth",
	["Lingering Health"]="poison_trait_hot",
	["Hindrance"]="alchemy_trait_reducespeed",
	["Vulnerability"]="poison_trait_damage",
	["Breach"]="alchemy_trait_lowerspellresist",
	["Heroism"]="alchemy_trait_increasespellresist",
}

local TraitsList={
"Restore Health",
"Ravage Health",

"Restore Magicka",
"Ravage Magicka",

"Restore Stamina",
"Ravage Stamina",

"Increase Spell Power",
"Cowardice",

"Increase Weapon Power",
"Maim",

"Spell Critical",
"Uncertainty",

"Weapon Critical",
"Enervation",

"Lingering Health",
"Gradual Ravage Health",

"Detection",
"Invisible",

"Increase Armor",
"Fracture",

"Increase Spell Resist",
"Breach",

"Speed",
"Hindrance",

"Unstoppable",
"Entrapment",

"Vitality",
"Defile",

"Protection",
"Vulnerability",

"Heroism",
}

local function GetPotionQuality(itemLink)
	local quality=0
	if itemLink then
		for i=1, GetMaxTraits() do
			local hasTraitAbility=GetItemLinkTraitOnUseAbilityInfo(itemLink, i)
			if hasTraitAbility then quality=math.max(quality+1,2) end
		end
	end
	return quality
end

local ZO_Alchemy_DoesAlchemyItemPassFilterOrig=ZO_Alchemy_DoesAlchemyItemPassFilter

ZO_Alchemy_DoesAlchemyItemPassFilter=function(bagId, slotIndex, filterType, isQuestFilterChecked, questInfo)
	local value=true

	if isQuestFilterChecked then
		if questInfo.validCombinationFound then
			local itemId = GetItemId(bagId, slotIndex)
			if (not questInfo.reagents or questInfo.reagents[itemId]==nil) and (not questInfo.solvent or questInfo.solvent.itemId~=itemId) then
				return false
			end
		end
	end

	if FilterTraits then
--		d("Custom filter")
		local reagentId=GetItemId(bagId,slotIndex)
		if ReagentTraits[reagentId] then
			for i=1,4 do
				if TraitsFilter[ ReagentTraits[reagentId][i] ] then
--					d("["..reagentId.."] Passed")
					return true
				end
			end
		end
		return false
	else
		local _, itemType=GetItemCraftingInfo(bagId, slotIndex)
		if (itemType==ITEMTYPE_POTION_BASE or itemType==ITEMTYPE_POISON_BASE) and SavedVars.LevelFilter then
			local usedInCraftingType, craftingSubItemType, rankRequirement=GetItemCraftingInfo(bagId,slotIndex)
			if not rankRequirement or rankRequirement<=GetNonCombatBonus(NON_COMBAT_BONUS_ALCHEMY_LEVEL) then
				local resultingItemLevel,requiredChampionPoints=select(4,GetItemCraftingInfo(bagId,slotIndex))
				if (resultingItemLevel or 0)+10<PlayerLevel or (PlayerLevel==50 and (requiredChampionPoints or 0)+15<PlayerCP) then
					return false
				end
			else
				return false
			end
		elseif filterType then
			if type(filterType)=="function" then value=filterType(itemType) else value=filterType==itemType end
		end
	end
	return value
end

ZO_CraftingInventory.ChangeFilter=function(self,filterData)
	if AlchemyCrafting and ZO_AlchemyTopLevelInventory_Options and filterData.normal then
		ZO_AlchemyTopLevelInventory_Options.check2:UpdateValue(false)
		SavedVars.LevelFilter=false
		for i,trait in pairs(TraitsList) do
			ZO_AlchemyTopLevelInventory_Options.traits[i]:UpdateValue(false)
			TraitsFilter[trait]=nil
		end
		FilterTraits=nil
	end

	ZO_SharedCraftingInventory.ChangeFilter(ALCHEMY.inventory, filterData)
	ZO_ScrollList_ResetToTop(ALCHEMY.inventory.list)
end

local function ResetupScrollData()
	if not ALCHEMY.inventory.list.dataTypes[SCROLL_DATA_TYPE_REAGENT] then d("AlchemyHelper is outdated") return end
	local defaultSetup=ALCHEMY.inventory:GetDefaultTemplateSetupFunction()

	local function ReagentSetup(rowControl, data)
		defaultSetup(rowControl, data)
		local locked=ALCHEMY.inventory:IsLocked(data.bagId, data.slotIndex)
		for i, traitControl in ipairs(rowControl.traits) do
			if i>4 then
				traitControl:SetHidden(true)
			else
				traitControl:SetHidden(false)
				local traitName, normalTraitIcon, traitMatchIcon, _, traitConflictIcon=select(i*5-4,GetAlchemyItemTraits(data.bagId, data.slotIndex))
				if traitName and traitName~="" then
					traitControl.label:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_TOOLTIP, ITEM_TOOLTIP_COLOR_ACCENT))
					traitControl.label:SetText(Loc(traitName))

					ALCHEMY:SetupTraitIcon(traitControl.icon, traitName, normalTraitIcon, traitMatchIcon, traitConflictIcon)
					ZO_ItemSlot_SetupIconUsableAndLockedColor(traitControl.icon, true, locked)
					traitControl.icon:SetHidden(false)

--[[					--Make reagent database
					local reagentId=GetItemId(data.bagId, data.slotIndex)
					if not GlobalVars.ReagentTraits[reagentId] then GlobalVars.ReagentTraits[reagentId]={} end
					GlobalVars.ReagentTraits[reagentId][i]=traitName
					GlobalVars.TraitIcons[traitName]=normalTraitIcon
--]]
				else
					traitControl.label:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_TOOLTIP, ITEM_TOOLTIP_COLOR_INACTIVE_BONUS))
					if SavedVars.ShowUnknown then
						local reagentId=GetItemId(data.bagId, data.slotIndex)
						if ReagentTraits[reagentId] then
							traitName=ReagentTraits[reagentId][i]
							traitControl.label:SetText(Loc(traitName))
							traitControl.icon:SetTexture('/esoui/art/icons/alchemy/crafting_' .. TraitIcons[traitName] .. '.dds')
							traitControl.icon:SetHidden(false)
							traitControl.icon:SetAlpha(.5)
						else
							traitControl.label:SetText(GetString(SI_CRAFTING_UNKNOWN_NAME))
							traitControl.icon:SetHidden(true)
						end
					else
						traitControl.label:SetText(GetString(SI_CRAFTING_UNKNOWN_NAME))
						traitControl.icon:SetHidden(true)
					end
				end
				if TraitsFilter[traitName] then traitControl.icon:SetColor(.2,1,.2,1) else traitControl.icon:SetColor(1,1,1,1) end
				ZO_ItemSlot_SetupTextUsableAndLockedColor(traitControl.label, true, locked)
			end
		end
	end

	ALCHEMY.inventory.list.dataTypes[SCROLL_DATA_TYPE_REAGENT].setupCallback=ReagentSetup
end

local function SetupCraftWindow()
	local parent=ZO_AlchemyTopLevelInventory
	local control=ZO_AlchemyTopLevelInventory_Options
	if control or not parent then return end
	control=WINDOW_MANAGER:CreateControl("$(parent)_Options", parent, CT_CONTROL)
	control:SetDimensions(200,64)
	control:SetAnchor(TOPLEFT,parent,TOPLEFT,50,0)
	control.traits={}
	--Show unknown
	local label=WINDOW_MANAGER:CreateControl("$(parent)_UnknownLabel", control, CT_LABEL)
	label:SetDimensions(180,26)
	label:SetAnchor(TOPLEFT,control,TOPLEFT,30,5)
	label:SetFont("ZoFontWinH4")
	label:SetColor(.8,.8,.6,1)
	label:SetHorizontalAlignment(0)
	label:SetVerticalAlignment(1)
	label:SetText(Loc("Show unknown traits"))
	control.check1=BUI.UI.CheckBox("$(parent)_UnknownBox", label, {26,26}, {TOPLEFT,TOPLEFT,-30,0}, SavedVars.ShowUnknown, function(value)
		SavedVars.ShowUnknown=value
		ALCHEMY.inventory:ChangeFilter({activeTabText=value and "Unknown Traits" or ""})
	end)
	--Solvent level filter
	local label=WINDOW_MANAGER:CreateControl("$(parent)_LevelFilterLabel", control, CT_LABEL)
	label:SetDimensions(180,26)
	label:SetAnchor(TOPLEFT,control,TOPLEFT,30,28)
	label:SetFont("ZoFontWinH4")
	label:SetColor(.8,.8,.6,1)
	label:SetHorizontalAlignment(0)
	label:SetVerticalAlignment(1)
	label:SetText(Loc("Solvent level filter"))
	control.check2=BUI.UI.CheckBox("$(parent)_LevelFilterBox", label, {26,26}, {TOPLEFT,TOPLEFT,-30,0}, SavedVars.LevelFilter, function(value)
		SavedVars.LevelFilter=value
		ALCHEMY.inventory:ChangeFilter({})
	end)
--	check:SetDisabled(true)
--[[	--Hide known
	BUI.UI.CheckBox("$(parent)_HideKnownBox", control, {26,26}, {TOPLEFT,TOPLEFT,150,28}, HideKnown, function(value)
		HideKnown=value
	end)

	local label=WINDOW_MANAGER:CreateControl("$(parent)_HideKnownLabel", control, CT_LABEL)
	label:SetDimensions(120,26)
	label:SetAnchor(TOPLEFT,control,TOPLEFT,180,28)
	label:SetFont("ZoFontWinH4")
	label:SetColor(.8,.8,.6,1)
	label:SetHorizontalAlignment(0)
	label:SetVerticalAlignment(1)
	label:SetText("Hide known")

	--Add filter button
	ZO_MenuBar_AddButton(ZO_AlchemyTopLevelInventoryTabs,{
	activeTabText="Properties",
	tooltipText="Properties",
	descriptor=FilterFunction,
	normal="esoui/art/worldmap/map_indexicon_filters_up.dds",
	pressed="esoui/art/worldmap/map_indexicon_filters_down.dds",
	highlight="esoui/art/worldmap/map_indexicon_filters_over.dds",
	disabled="esoui/art/worldmap/map_indexicon_filters_up.dds",
	callback=function(tabData)
--		ALCHEMY.inventory:Refresh(ZO_ScrollList_GetDataList(ALCHEMY.inventory.list))
--		ZO_InventorySlot_OnPoolReset()
		ALCHEMY.inventory:ChangeFilter(tabData)
	end,	})
--]]
	--Traits filter
	local size=22
	for i,name in pairs(TraitsList) do
		control.traits[i]=BUI.UI.CheckBox("$(parent)_Trait_"..i, control, {size,size}, {TOPRIGHT,TOPLEFT,-30,(i-1)*size}, false,
		function(value,shift)
			TraitsFilter[name]=value or nil
			if value and not shift then
				for n,trait in pairs(TraitsList) do
					if trait~=name then
						control.traits[n]:UpdateValue(false)
						TraitsFilter[trait]=nil
					end
				end
			end
			FilterTraits=nil
			for name in pairs(TraitsFilter) do FilterTraits=true break end
			ALCHEMY.inventory:ChangeFilter({activeTabText=FilterTraits and "Traits Filter" or ""})
		end, Loc(name), false, '/esoui/art/icons/alchemy/crafting_' .. TraitIcons[name] .. '.dds')
	end
end

local function GetInventoryItem(id)
	if id then
		for _, itemData in pairs(SHARED_INVENTORY:GenerateFullSlotData(
			function(itemData)
				if isReagent[itemData.itemType] then
					itemData.Id=GetItemId(itemData.bagId,itemData.slotIndex)
					return true
				end
			end,BAG_BACKPACK,BAG_BANK,BAG_VIRTUAL)) do
			if itemData.Id==id then
				return itemData.bagId,itemData.slotIndex
			end
		end
	end
end

local function OnSlotClick(slot,button)
	PlaySound("Click")
	if button==1 then
		local item=SavedVars[slot.index]
		if item then
			for i,id in pairs(item.reagents) do
				if i==1 then ALCHEMY:SetSolventItem(nil) else ALCHEMY:SetReagentItem(i-1, nil) end
				local bagId,slotIndex=GetInventoryItem(id)
--				d("["..id.."] "..item.itemLink.." ("..tostring(bagId)..", "..tostring(slotIndex)..")")
--				if bagId==BAG_SUBSCRIBER_BANK then d("Using subscriber bank") elseif bagId==BAG_VIRTUAL then d("Using virtial bank") end
				if bagId and slotIndex then
					if i==1 then ALCHEMY:SetSolventItem(bagId,slotIndex) else ALCHEMY:SetReagentItem(i-1,bagId,slotIndex) end
				end
			end
		else
			local solvent=ALCHEMY.solventSlot.items[1]
			if solvent then
				local items={[1]=solvent}
				for i=1,3 do
					table.insert(items,ALCHEMY.reagentSlots[i].items[1])
				end
				if #items>=3 then
					local itemLink=GetAlchemyResultingItemLink(	--GetAlchemyResultingItemInfo
					items[1].bagId,items[1].slotIndex,
					items[2].bagId,items[2].slotIndex,
					items[3].bagId,items[3].slotIndex,
					items[4] and items[4].bagId,items[4] and items[4].slotIndex)
					if itemLink and itemLink~="" then
						local itemIcon=GetItemLinkInfo(itemLink)
						slot.icon:SetTexture(itemIcon)
						slot:SetColor(unpack(QUALITY_COLOR[GetPotionQuality(itemLink)]))
						local reagents={}
						for i,data in pairs(items) do
							reagents[i]=GetItemId(data.bagId,data.slotIndex)
						end
						SavedVars[slot.index]={itemLink=itemLink,itemIcon=itemIcon,reagents=reagents}
					end
				end
			end
		end
	elseif button==2 then
		slot.icon:SetTexture(SlotBlank)
		slot:SetColor(unpack(QUALITY_COLOR[0]))
		SavedVars[slot.index]=nil
	end
end

local function ShowTooltip(self,show)
	if show then
		if SavedVars[self.index] and SavedVars[self.index].itemLink then
			ActiveTooltip=ItemTooltip
			InitializeTooltip(ActiveTooltip,self,BOTTOM,0,0,TOP)
			ActiveTooltip:SetLink(SavedVars[self.index].itemLink)
		else
			ActiveTooltip="Text"
			ZO_Tooltips_ShowTextTooltip(self, TOP, GetString(BUI_AlchemySlotTooltip))
		end
	else
		if ActiveTooltip=="Text" then
			ZO_Tooltips_HideTextTooltip()
			ActiveTooltip=nil
		elseif ActiveTooltip then
			ClearTooltip(ActiveTooltip)
			ActiveTooltip=nil
		end
	end
end
--	/script ALCHEMY.control:SetHidden(false)
local function SetupCraftSlots()
	local SlotContainer=ALCHEMY.control:GetNamedChild("SlotContainer")
	local theme_color=BUI.Vars and (BUI.Vars.Theme==6 and {1,204/255,248/255,1} or BUI.Vars.Theme==7 and BUI.Vars.AdvancedThemeColor or BUI.Vars.Theme>3 and BUI.Vars.CustomEdgeColor or {0,0,.1,1}) or {0,0,.1,1}
	local size=38
	for i=1,6 do
		local edge=BUI.UI.Texture("BUI_AlchemySlotEdge"..i, SlotContainer, {size,size}, {TOPLEFT,TOPLEFT,(i<4 and 10 or 10-size-2),110+i%3*(size+2)}, BUI.abilityframe or "/esoui/art/actionbar/abilityframe64_up.dds", false, 2)
		edge:SetColor(unpack(theme_color))
		local slot=BUI.UI.Texture("BUI_AlchemySlot"..i, edge, {size-4,size-4}, {CENTER,CENTER,0,0}, SlotIcon, false, 0)
		slot:SetColor(unpack(QUALITY_COLOR[GetPotionQuality(SavedVars[i] and SavedVars[i].itemLink or nil)]))
		slot.icon=BUI.UI.Texture("BUI_AlchemySlotIcon"..i, edge, {size-4,size-4}, {CENTER,CENTER,0,0}, SavedVars[i] and SavedVars[i].itemIcon or SlotBlank, false, 1)
		slot.index=i
		slot:SetMouseEnabled(true)
		slot:SetHandler("OnMouseDown", OnSlotClick)
		slot:SetHandler("OnMouseEnter", function(self) ShowTooltip(self,true) end)
		slot:SetHandler("OnMouseExit", function(self) ShowTooltip(self,false) end)
	end
end

local function OnAddOnLoaded(_,addonName)
	if addonName~=AddonName then return end
	EVENT_MANAGER:UnregisterForEvent("BUI_AlchemyHelper", EVENT_ADD_ON_LOADED)
	SavedVars=ZO_SavedVars:New("BAH_GlobalVars",1,nil,{})
	PlayerLevel=GetUnitLevel('player')
	PlayerCP=math.min(GetPlayerChampionPointsEarned(),160)
	SetupCraftWindow()
	ResetupScrollData()
	zo_callLater(SetupCraftSlots,1000)

	EVENT_MANAGER:RegisterForEvent("BUI_AlchemyHelper", EVENT_CRAFTING_STATION_INTERACT, function(eventCode,craftSkill)
		if craftSkill==CRAFTING_TYPE_ALCHEMY then
			AlchemyCrafting=true
			PlayerLevel=GetUnitLevel('player')
			PlayerCP=math.min(GetPlayerChampionPointsEarned(),160)
		end
	end)
	EVENT_MANAGER:RegisterForEvent("BUI_AlchemyHelper", EVENT_END_CRAFTING_STATION_INTERACT, function(eventCode,craftSkill)
		if craftSkill==CRAFTING_TYPE_ALCHEMY then
			AlchemyCrafting=nil
		end
	end)

	--Generate strings
	local base=BUI.name=="BanditsUserInterface"
	ZO_CreateStringId("BUI_AlchemySlotTooltip",GetString(SI_UNIT_FRAME_EMPTY_SLOT).."\n"
	..	(base and '|t16:16:/BanditsUserInterface/textures/lmb.dds|t' or "LMB:").." "..GetString(SI_KEYCODE18).."\n"
	..	(base and '|t16:16:/BanditsUserInterface/textures/rmb.dds|t' or "RMB:").." "..GetString(SI_MAIL_SEND_CLEAR))
end

EVENT_MANAGER:RegisterForEvent("BUI_AlchemyHelper", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
--[[
/script for _, itemData in pairs(SHARED_INVENTORY:GenerateFullSlotData(nil,BAG_BACKPACK)) do
d(itemData.name)
if GetItemId(itemData.bagId,itemData.slotIndex)==7070 then
d(itemData.itemType)
break
end
end
--]]