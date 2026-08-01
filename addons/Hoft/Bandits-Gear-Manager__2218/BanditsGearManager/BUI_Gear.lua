local Name,AddonName="Gear Manager","BanditsGearManager"
BanditsGearManagerInProgress=false		--API state variable
local ChatOutput=true
local GEARS,PANELS,INSTANCE,INSTANCES=5,2,0,14
local SLOTSIZE=44
local SETNAMES={[1]={},[2]={},[3]={},[4]={},[5]={},[6]={},[7]={},[8]={},[9]={},[10]={},[11]={},[12]={},[13]={},[14]={},[15]={},[16]={},[17]={},[18]={},[19]={},[20]={}}
local SLOTS={
{EQUIP_SLOT_HEAD,		'Head'},
{EQUIP_SLOT_CHEST,	'Chest'},
{EQUIP_SLOT_LEGS,		'Legs','Leg'},
{EQUIP_SLOT_SHOULDERS,	'Shoulders','Shoulder'},
{EQUIP_SLOT_FEET,		'Feet','Foot'},
{EQUIP_SLOT_COSTUME,	'Costume'},

{EQUIP_SLOT_WAIST,	'Belt'},
{EQUIP_SLOT_HAND,		'Hands','Glove'},
{EQUIP_SLOT_NECK,		'Neck'},
{EQUIP_SLOT_RING1,	'Ring','Ring1'},
{EQUIP_SLOT_RING2,	'Ring','Ring2'},
{100,	'Costume'},

{EQUIP_SLOT_MAIN_HAND,	'MainHand'},
{EQUIP_SLOT_OFF_HAND,	'OffHand'},
{EQUIP_SLOT_POISON,	'Poison'},

{EQUIP_SLOT_BACKUP_MAIN,'MainHand','BackupMain'},
{EQUIP_SLOT_BACKUP_OFF,	'OffHand','BackupOff'},
{EQUIP_SLOT_BACKUP_POISON,'Poison','BackupPoison'},
}
local SLOT_POS={
[EQUIP_SLOT_HEAD]		={'Wear',1,1},
[EQUIP_SLOT_CHEST]	={'Wear',1,2},
[EQUIP_SLOT_LEGS]		={'Wear',1,3},
[EQUIP_SLOT_SHOULDERS]	={'Wear',1,4},
[EQUIP_SLOT_FEET]		={'Wear',1,5},
[EQUIP_SLOT_COSTUME]	={'Wear',1,6},
[EQUIP_SLOT_WAIST]	={'Wear',2,1},
[EQUIP_SLOT_HAND]		={'Wear',2,2},
[EQUIP_SLOT_NECK]		={'Wear',2,3},
[EQUIP_SLOT_RING1]	={'Wear',2,4},
[EQUIP_SLOT_RING2]	={'Wear',2,5},
[EQUIP_SLOT_MAIN_HAND]	={'Weap',1,1},
[EQUIP_SLOT_OFF_HAND]	={'Weap',1,2},
[EQUIP_SLOT_POISON]	={'Weap',1,3},
[EQUIP_SLOT_BACKUP_MAIN]={'Weap',2,1},
[EQUIP_SLOT_BACKUP_OFF]	={'Weap',2,2},
[EQUIP_SLOT_BACKUP_POISON]={'Weap',2,3},
}
local SLOT_TYPE={
[EQUIP_TYPE_HEAD]="Wear",
[EQUIP_TYPE_CHEST]="Wear",
[EQUIP_TYPE_LEGS]="Wear",
[EQUIP_TYPE_SHOULDERS]="Wear",
[EQUIP_TYPE_FEET]="Wear",
[EQUIP_TYPE_COSTUME]="Wear",
[EQUIP_TYPE_WAIST]="Wear",
[EQUIP_TYPE_HAND]="Wear",
[EQUIP_TYPE_NECK]="Wear",
[EQUIP_TYPE_RING]="Wear",
[EQUIP_TYPE_MAIN_HAND]="Weap",
[EQUIP_TYPE_OFF_HAND]="Weap",
[EQUIP_TYPE_ONE_HAND]="Weap",
[EQUIP_TYPE_TWO_HAND]="Weap",
[EQUIP_TYPE_POISON]="Weap",
}
local SLOT_EQUIP={
[EQUIP_TYPE_CHEST]={EQUIP_SLOT_CHEST},
[EQUIP_TYPE_COSTUME]={EQUIP_SLOT_COSTUME},
[EQUIP_TYPE_FEET]={EQUIP_SLOT_FEET},
[EQUIP_TYPE_HAND]={EQUIP_SLOT_HAND},
[EQUIP_TYPE_HEAD]={EQUIP_SLOT_HEAD},
[EQUIP_TYPE_LEGS]={EQUIP_SLOT_LEGS},
[EQUIP_TYPE_MAIN_HAND]={EQUIP_SLOT_MAIN_HAND,EQUIP_SLOT_BACKUP_MAIN},
[EQUIP_TYPE_NECK]={EQUIP_SLOT_NECK},
[EQUIP_TYPE_OFF_HAND]={EQUIP_SLOT_OFF_HAND,EQUIP_SLOT_BACKUP_OFF},
[EQUIP_TYPE_ONE_HAND]={EQUIP_SLOT_MAIN_HAND,EQUIP_SLOT_OFF_HAND,EQUIP_SLOT_BACKUP_MAIN,EQUIP_SLOT_BACKUP_OFF},
[EQUIP_TYPE_POISON]={EQUIP_SLOT_POISON,EQUIP_SLOT_BACKUP_POISON},
[EQUIP_TYPE_RING]={EQUIP_SLOT_RING1,EQUIP_SLOT_RING2},
[EQUIP_TYPE_SHOULDERS]={EQUIP_SLOT_SHOULDERS},
[EQUIP_TYPE_TWO_HAND]={EQUIP_SLOT_MAIN_HAND,EQUIP_SLOT_BACKUP_MAIN},
[EQUIP_TYPE_WAIST]={EQUIP_SLOT_WAIST},
}
local isWeapon={
[EQUIP_SLOT_MAIN_HAND]=true,
[EQUIP_SLOT_OFF_HAND]=true,
[EQUIP_SLOT_BACKUP_MAIN]=true,
[EQUIP_SLOT_BACKUP_OFF]=true,
}
local QUALITY_COLOR={[0]={.65,.65,.65,.5},[1]={1,1,1,.5},[2]={.17,.77,.05,.5},[3]={.22,.57,1,.5},[4]={.62,.18,.96,.5},[5]={.80,.66,.1,.5},[6]={1,.6,.1,.5}}
local IconBlank="/esoui/art/crafting/crafting_tooltip_glow_center.dds"
local BorderColor,EquippedColor,MissedColor,ColorBlank={.7,.7,.5,.2},{.7,.7,.5,1},{.7,.2,.2,.5},{.4,.4,.4,.2}
local DragData,SavedData,GlobalData={},{},{}
local CONTEXT={"Clear","Equip","Insert Current","Copy","Paste","Unequip all"}
local COPY,RedrawUI,ui_init,markers_init,ui_hold
local isEquipment={
[ITEMTYPE_ARMOR]=true,
[ITEMTYPE_DISGUISE]=true,
[ITEMTYPE_TABARD]=true,
[ITEMTYPE_WEAPON]=true,
[ITEMTYPE_POISON]=true,
[ITEMTYPE_COSTUME]=true,
}
local AbilityBarsDone,AnimateSwap,MouseOverDelay,SingleUseQueue
local ActiveTooltip
local LastAction=0
local Icons={
unequip="/esoui/art/vendor/vendor_tabicon_sell_up.dds",
back="/esoui/art/vendor/vendor_tabicon_buyback_up.dds",
}
local outfit_icons={
"/esoui/art/restyle/gamepad/gp_outfits_remove.dds",	--Insert
"/esoui/art/tutorial/gamepad_costumedye.dds",	--Outfit
"/esoui/art/treeicons/gamepad/gp_collectionicon_polymorphs.dds",	--Polymorphs
"/esoui/art/restyle/gamepad/gp_dyes_tabicon_outfitstyledye.dds",	--Costumes
"/esoui/art/icons/mapkey/mapkey_stables.dds",	--Mount
"/esoui/art/treeicons/gamepad/gp_collectionicon_skins.dds",	--Skins
"/esoui/art/treeicons/gamepad/gp_collectionicon_personalities.dds",	--Personalities

"/esoui/art/treeicons/gamepad/gp_collectionicon_hats.dds",	--Hats
"/esoui/art/treeicons/gamepad/gp_collectionicon_hair.dds",	--Hair style
"/esoui/art/treeicons/gamepad/gp_collectionicon_facialhair.dds",	--Facial hair
"/esoui/art/icons/adornment_female_mixed_tiarahalfcirclet.dds",	--Major adornment
"/esoui/art/tutorial/gamepad/gp_tooltip_itemslot_neck.dds",		--Minor adornment
"/esoui/art/treeicons/gamepad/gp_collectionicon_bodymarkings.dds",	--Body markings
"/esoui/art/treeicons/gamepad/gp_collectionicon_facialmarkings.dds",	--Head markings
}
local outfit_slots={
[1]=nil,
[2]=COLLECTIBLE_CATEGORY_TYPE_OUTFIT_STYLE,
[3]=COLLECTIBLE_CATEGORY_TYPE_POLYMORPH,
[4]=COLLECTIBLE_CATEGORY_TYPE_COSTUME,
[5]=COLLECTIBLE_CATEGORY_TYPE_MOUNT,
[6]=COLLECTIBLE_CATEGORY_TYPE_SKIN,
[7]=COLLECTIBLE_CATEGORY_TYPE_PERSONALITY,

[8]=COLLECTIBLE_CATEGORY_TYPE_HAT,
[9]=COLLECTIBLE_CATEGORY_TYPE_HAIR,
[10]=COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS,
[11]=COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY,
[12]=COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY,
[13]=COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING,
[14]=COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING,
}
local Localization={
	en={
	--Settings
	MenuWidth=250,
	Settings="Settings",
	Button="Show gear manager button",
	Inventory="Change player inventory",
	MarkItems="Mark gear items",
	Message="Show on-screen message",
	AddBar="Additional ability bar",
	Height="Visible gear slots: ",
	Gears="Total gear slots: ",
	SlotSize="Slot size: ",
	MarkCollect="Mark not collected set items",
	AbilityManager="beta 3.0 (auto fills backbar)",
	--Interface
	GearManager="Gear Manager",	--Proper name, do not translate.
	Gear="Gear",
	SingleUseSlot="Single use slot",
	Instance="Instance",
	SelectInstance="Select instance",
	InstanceName="Edit instance name",
	Withdraw="|c4B8BFEBGM|r: Withdraw gear items",
	--Tooltip
	Tooltip_UI1="Equip/Drag",
	Tooltip_UI2="Clear/Context menu",
	Tooltip_UI3="Shift+Drag: Copy",
	Tooltip_Outfit1="Insert current",
	Tooltip_Outfit2="Clear",
	--Buttons
	Show="Show",
	RadialMenu="radial menu",
	EquipDdPanel="Equip additional panel",
	ActivateSuS="Activate \"Single use slot\"",
	EquipGear="Equip gear",
	--Alerts
	SusAlert="Single use slot can not be used",
	NoResource="You do not have enough resource",
	AbilityAlert="Ability bar %s is not available",
	AbilCombat="Waiting for end of combat to return %s back",
	Equipping="Equipping",
	Activated="Activated",
	MenuToggle="Toggled to instance selector",
	},
	ru={
	--Settings
	MenuWidth=340,
	Settings="Настройки",
	Button="Кнопка Gear Manager-а",
	Inventory="Модернизировать окно персонажа",
	MarkItems="Помечать предметы в инвентаре",
	Message="Показывать экранные сообщения",
	AddBar="Дополнительная панель способностей",
	Height="Отображать сборок: ",
	Gears="Всего сборок: ",
	SlotSize="Размер слотов: ",
	MarkCollect="Помечать предметы не из коллекции",
	AbilityManager="Менеджер способностей 3.0 (бэта)",
	--Interface
	GearManager="Gear Manager",
	Gear="Сборка",
	SingleUseSlot="Одноразовый слот",
	Instance="Вариант",
	SelectInstance="Выбрать вариант",
	InstanceName="Изменить название варианта",
	Withdraw="|c4B8BFEBGM|r: Забрать предметы сборок",
	--Tooltip
	Tooltip_UI1="Надеть/Перетащить",
	Tooltip_UI2="Очистить/Контекстное меню",
	Tooltip_UI3="Shift+Перетаскивать: Создать копию",
	Tooltip_Outfit1="Вставить текущее",
	Tooltip_Outfit2="Очистить",
	--Buttons
	Show="Открыть",
	RadialMenu="крговое меню",
	EquipDdPanel="Экипировать доп. панель",
	ActivateSuS="Акстивировать \"Одноразовый слот\"",
	EquipGear="Экипировать сборку",
	--Alerts
	SusAlert="Одноразовый слот не доступен",
	NoResource="Не хватает ресурсов",
	AbilityAlert="Панель умений %s не доступна",
	AbilCombat="Ожидание конца поя чтоб вернуть %s назад",
	Equipping="Одевается",
	Activated="Активирован",
	MenuToggle="Переключено на меню вариантов",
	},
	fr={	--by XXXspartiateXXX
	--Settings
	MenuWidth=350,
	Settings="Paramètres",
	Button="Afficher le bouton de Gear Manager",
	Inventory="Modifier l'inventaire du joueur",
	MarkItems="Marquer les objets d'ensemble",
	Message="Afficher le message à l'écran",
	AddBar="Ajouter la barre de compétence",
	Height="Nombre d'emplacements d'ensemble visible: ",
	Gears="Nombre total d'emplacements d'ensemble: ",
	SlotSize="Taille d'un emplacement: ",
	MarkCollect="Marquer les objets d'ensemble non collectés",
	AbilityManager="Gestionnaire de compétence 3.0 (bêta)",
	--Interface
	GearManager="Gear Manager",	--Proper name, do not translate.
	Gear="Ensemble",
	SingleUseSlot="Emplacem. à usage unique",
	Instance="Modèle",
	SelectInstance="Sélectionner un modèle",
	InstanceName="Modifier le nom du modèle",
	Withdraw="|c4B8BFEBGM|r: Retirer les objets d'ensemble",
	--Tooltip
	Tooltip_UI1="Glisser/Équiper",
	Tooltip_UI2="Menu contextuel/Effacer",
	Tooltip_UI3="Maj + Glisser: Copier",
	Tooltip_Outfit1="Insérer l'actuel",
	Tooltip_Outfit2="Effacer",
	--Buttons
	Show="Afficher",
	RadialMenu="menu radial",
	EquipDdPanel="Équiper un panneau supplémentaire",
	ActivateSuS="Activer \"Emplacement à usage unique\"",
	EquipGear="Équiper l'ensemble",
	--Alerts
	SusAlert="L'emplacement à usage unique ne peut pas être utilisé",
	NoResource="Vous n'avez pas assez de ressources",
	AbilityAlert="La barre de compétence %s n'est pas disponible",
	AbilCombat="Attendre la fin du combat pour renvoyer %s",
	Equipping="Équipement",
	Activated="Activé",
	MenuToggle="Basculer au sélecteur de modèle",
	},
}
local lang=GetCVar("language.2") if not Localization[lang] then lang="en" end

--Functions
local function Loc(name)
	return Localization[lang][name] or Localization.en[name] or name
end

local function GetAbilityIndex(id)
	local hasProgression, progressionIndex=GetAbilityProgressionXPInfoFromAbilityId(id)
	if hasProgression then
		local _,morph, rank=GetAbilityProgressionInfo(progressionIndex)
		local _,_,abilityIndex=GetAbilityProgressionAbilityInfo(progressionIndex, morph, rank)
		return abilityIndex
	end
	return nil
end

local function GetBaseAbilityId(id)
	if TranslateIdToScribedId(id) then return TranslateIdToScribedId(id) end
	local _,i=GetAbilityProgressionXPInfoFromAbilityId(id)
	return GetAbilityProgressionAbilityId(i,0,1)
end

local function GetCurrentAbilityId(id)
	if TranslateIdToScribedId(id) then return TranslateIdToScribedId(id) end
	local _,i=GetAbilityProgressionXPInfoFromAbilityId(id)
	local _,morph,rank=GetAbilityProgressionInfo(i)
	return GetAbilityProgressionAbilityId(i,morph,rank)
end

local function GetKeyBind(g)
	local keyname="BUI_GEAR_"..g
	local modifier=""
	local l,c,a=GetActionIndicesFromName(keyname)
	local key,m1,m2,m3,m4=GetActionBindingInfo(l,c,a,1)
	if key~=KEY_INVALID then
		local mod={
		ZO_Keybindings_DoesKeyMatchAnyModifiers(KEY_SHIFT,m1,m2,m3,m4),
		ZO_Keybindings_DoesKeyMatchAnyModifiers(KEY_CTRL,m1,m2,m3,m4),
		ZO_Keybindings_DoesKeyMatchAnyModifiers(KEY_ALT,m1,m2,m3,m4),
		}
		if mod[1] then modifier=modifier.."Shift\n" end
		if mod[2] then modifier=modifier.."CTRL\n" end
		if mod[3] then modifier=modifier.."ALT\n" end
		return modifier..GetKeyName(key)
	end
end

local function GetInventoryItem(uid)
	if uid then
	for _, itemData in pairs(SHARED_INVENTORY:GenerateFullSlotData(
		function(itemData)
			if isEquipment[itemData.itemType] then
				itemData.uId=Id64ToString(itemData.uniqueId)
				return true
			end
		end,BAG_BACKPACK,BAG_WORN)) do
			if itemData.uId==uid then
				local link=GetItemLink(itemData.bagId, itemData.slotIndex)
--				for param in pairs(itemData) do d(param) end
				return itemData.iconFile,itemData.displayQuality,link,itemData.bagId==BAG_WORN,itemData.bagId,itemData.slotIndex
			end
	end
	end
	return nil,nil,nil,nil,nil,nil
end
--	/script for i, itemData in pairs(SHARED_INVENTORY:GenerateFullSlotData(nil,BAG_WORN)) do d(i) for name in pairs(itemData) do d(name) end break end
local function CheckDataStructure(gear,type,pair,slot)
	if gear and not SavedData[gear] then SavedData[gear]={} end
	if type and not SavedData[gear][type] then SavedData[gear][type]={} end
	if pair and not SavedData[gear][type][pair] then SavedData[gear][type][pair]={} end
	if slot and not SavedData[gear][type][pair][slot] then SavedData[gear][type][pair][slot]={} end
end

local function ShowTooltip(self,show)
	if show then
		if self.type=="OutfitFill" then
			ActiveTooltip="Text"
			ZO_Tooltips_ShowTextTooltip(self, RIGHT, GetString(BUI_Gear_OutfitToolTip))
		elseif self.type=="OutfitSlot" then
			ActiveTooltip="Text"
			local id=SavedData[self.gear+INSTANCE*100] and SavedData[self.gear+INSTANCE*100].wear and SavedData[self.gear+INSTANCE*100].wear[98] or nil
			local text=id==0 and "Unequip Outfit" or id and "Outfit "..id or "No Outfit"
			ZO_Tooltips_ShowTextTooltip(self, RIGHT, text)
		elseif self.type=="Outfit" then
			local uid=SavedData[self.gear+INSTANCE*100] and SavedData[self.gear+INSTANCE*100].wear and SavedData[self.gear+INSTANCE*100].wear[self.slot] or nil
			if uid and uid~=0 then
				ActiveTooltip=ItemTooltip
				InitializeTooltip(ActiveTooltip,self,LEFT,0,0,RIGHT)
				ItemTooltip:SetCollectible(uid, true, false, false)
			end
		elseif self.type=="Wear" or self.type=="Weap" then
			local uid=SavedData[self.gear+INSTANCE*100] and SavedData[self.gear+INSTANCE*100].wear and SavedData[self.gear+INSTANCE*100].wear[self.slot] or nil
			if uid and uid~=0 then
				if self.slot==100 then
					ActiveTooltip=ItemTooltip
					InitializeTooltip(ActiveTooltip,self,LEFT,0,0,RIGHT)
					ItemTooltip:SetCollectible(uid, true, false, false)
				else
--					d(string.format('Tooltip type: %s, g: %s, y: %s, x: %s, uid: %s', tostring(self.type), tostring(self.gear), tostring(self.y), tostring(self.x),tostring(uid)))
					local _,_,link,_,bagId,slotIndex=GetInventoryItem(uid)
--					d(string.format('Tooltip item: %s, uid: %s', tostring(link),tostring(uid)))
					if link then
						ActiveTooltip=ItemTooltip
						InitializeTooltip(ActiveTooltip,self,LEFT,0,0,RIGHT)
						ActiveTooltip:SetLink(link)
						ZO_ItemTooltip_ClearCondition(ActiveTooltip)
						ZO_ItemTooltip_ClearCharges(ActiveTooltip)

						local itemType=GetItemLinkItemType(link)	--Provided by Phuein
						if itemType==ITEMTYPE_TABARD then
							local creatorName=GetItemCreatorName(bagId, slotIndex)
							if creatorName then
								ActiveTooltip:AddLine(zo_strformat(SI_ITEM_FORMAT_STR_TABARD, creatorName))
							end
						end
					end
				end
			end
		elseif self.type=="Abil" then
			local id=SavedData[self.gear+INSTANCE*100] and SavedData[self.gear+INSTANCE*100].abil and SavedData[self.gear+INSTANCE*100].abil[self.pair] and SavedData[self.gear+INSTANCE*100].abil[self.pair][self.slot] or nil
			if id and id~=0 then
				--d(string.format('Tooltip type: %s, g: %s, y: %s, x: %s, id: %s, abilityId: %s', tostring(self.type), tostring(self.gear), tostring(self.y), tostring(self.x),tostring(id),tostring(GetCurrentAbilityId(id))))				
				local skillType,skillLineIndex,skillIndex=GetSpecificSkillAbilityKeysByAbilityId(GetCurrentAbilityId(id))				
				ActiveTooltip=SkillTooltip
				InitializeTooltip(ActiveTooltip,self,LEFT,0,0,RIGHT)
				if TranslateIdToScribedId(id) then
					local primaryScriptId,secondaryScriptId,tertiaryScriptId=GetCraftedAbilityActiveScriptIds(id)
					ActiveTooltip:SetCraftedAbility(id, primaryScriptId, secondaryScriptId, tertiaryScriptId)
				else	
					ActiveTooltip:SetSkillAbility(skillType,skillLineIndex,skillIndex)
				end
			end
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

local function FillGearName(g)
	local name=""
	for n in pairs(SETNAMES[g]) do
		name=name..(name~="" and " + " or "")..string.gsub(n,"%^%w+","")
	end
	_G["BUI_Gear_Name"..g]:SetText(name~="" and name or Loc("Gear").." "..g)
	_G["BUI_Gear_cName"..g]:SetText(SavedData[g+INSTANCE*100] and SavedData[g+INSTANCE*100].name or Loc("Gear").." "..g)
end

local function FillSlot(g,type,y,x)
	if type=="Wear" then
		local frame=_G["BUI_Gear_Wear"..g..y..x]
		if frame then
			local parent=frame:GetParent()
			local slot=SLOTS[(y-1)*6+x][1]
			local uid=SavedData[g+INSTANCE*100] and SavedData[g+INSTANCE*100].wear and SavedData[g+INSTANCE*100].wear[slot] or nil
			local texture,quality,link,equipped=GetInventoryItem(uid)
			if y==2 and x==6 then	--Collectible
				if uid==0 then
					texture="esoui/art/dye/dyes_tabicon_outfitstyledye_disabled.dds"
					frame:SetColor(1,.2,.2,.5)
				else
					texture=uid and GetCollectibleIcon(uid) or "esoui/art/dye/dyes_tabicon_outfitstyledye_disabled.dds"	--"esoui/art/dye/dyes_tabicon_costumedye_disabled.dds"
					quality=uid and 5
					equipped=uid==GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_COSTUME)
					if uid then frame:SetColor(1,1,1,1) else frame:SetColor(1,1,1,.5) end
				end
			else
				if uid==0 then frame:SetColor(1,.2,.2,1) else frame:SetColor(1,1,1,1) end
			end
			local color=quality and QUALITY_COLOR[quality] or ColorBlank
			parent.edge=equipped and EquippedColor or (uid and not texture) and MissedColor or BorderColor
			frame:SetTexture(texture or "/esoui/art/characterwindow/gearslot_"..SLOTS[(y-1)*6+x][2]..".dds")
			parent:SetCenterColor(unpack(color))
			parent:SetEdgeColor(unpack(parent.edge))
			frame:SetMovable(uid~=nil)
			if uid and not (y==2 and x==6) then
				local isSet,name=GetItemLinkSetInfo(link)
				if isSet then SETNAMES[g][name]=true end
			end
			return link
		end
	elseif type=="Weap" then
		local frame=_G["BUI_Gear_Weap"..g..y..x]
		if frame then
			local slot=SLOTS[12+(y-1)*3+x][1]
			local uid=SavedData[g+INSTANCE*100] and SavedData[g+INSTANCE*100].wear and SavedData[g+INSTANCE*100].wear[slot] or nil
			local texture,quality,link,equipped=GetInventoryItem(uid)
			local color=quality and QUALITY_COLOR[quality] or ColorBlank
			local parent=frame:GetParent()
			parent.edge=equipped and EquippedColor or BorderColor
			frame:SetTexture(texture or "/esoui/art/characterwindow/gearslot_"..SLOTS[12+(y-1)*3+x][2]..".dds")
			if uid==0 then frame:SetColor(1,.2,.2,1) else frame:SetColor(1,1,1,1) end
			parent:SetCenterColor(unpack(color))
			parent:SetEdgeColor(unpack(parent.edge))
			frame:SetMovable(uid~=nil)
			return link
		end
	elseif type=="Abil" then
		local frame=_G["BUI_Gear_Abil"..g..y..x]
		if frame then
			local id=SavedData[g+INSTANCE*100] and SavedData[g+INSTANCE*100].abil and SavedData[g+INSTANCE*100].abil[y] and SavedData[g+INSTANCE*100].abil[y][x] or nil			
			local texture=id and GetAbilityIcon(GetCurrentAbilityId(id)) or IconBlank
			frame:SetTexture(texture)
			frame:SetMovable(id~=nil)
		end
	end
end

local function FillOutfit(gear)
	if not BUI_Gear_Outfit then return end
	for i=1,14 do
		local id=SavedData[gear+INSTANCE*100] and SavedData[gear+INSTANCE*100].wear and SavedData[gear+INSTANCE*100].wear[i+96] or nil
		local slot=_G["BUI_Gear_Outfit_Slot_Bg"..i]
		if slot then
			slot.icon.gear=gear
			if i>=3 then
				if id and id~=0 then
					slot.icon:SetTexture(GetCollectibleIcon(id))
					slot.icon:SetColor(1,1,1,1)
					slot:SetCenterColor(unpack(QUALITY_COLOR[5]))
					local equipped=id==GetActiveCollectibleByType(outfit_slots[i])
					slot.edge=equipped and EquippedColor or BorderColor
					slot:SetEdgeColor(unpack(slot.edge))
				else
					slot.icon:SetTexture(outfit_icons[i])
					if id==0 then slot.icon:SetColor(1,.2,.2,.3) else slot.icon:SetColor(1,1,1,.3) end
					slot:SetCenterColor(.4,.4,.4,.2)
					slot:SetEdgeColor(unpack(BorderColor))
				end
			end
		end
	end
	local id=SavedData[gear+INSTANCE*100] and SavedData[gear+INSTANCE*100].wear and SavedData[gear+INSTANCE*100].wear[98] or nil
	if id==0 then
		BUI_Gear_Outfit_Label:SetText("")
		BUI_Gear_Outfit_Slot2:SetColor(1,.2,.2,.3)
	else
		BUI_Gear_Outfit_Label:SetText(id or "")
		BUI_Gear_Outfit_Slot2:SetColor(1,1,1,.3)
	end
end

local function FillAllSlots()
	for g=1,GEARS do
		SETNAMES[g]={}
		for y=1,2 do
			for x=1,6 do FillSlot(g,"Wear",y,x) end
			for x=1,3 do FillSlot(g,"Weap",y,x) end
		end
		for y=1,PANELS do
			for x=1, 6 do FillSlot(g,"Abil",y,x) end
		end
		FillGearName(g)
	end
	for x=1, 5 do FillSlot(0,"Abil",1,x) end
end

local function ScreenMessage(message,delay)
	if GlobalData.Message then
		if BUI.OnScreen then
			BUI.OnScreen.Notification(13,message,(not delay and SOUNDS.BOOK_ACQUIRED or nil),delay)
		elseif not delay then
			local messageParams=CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_MAJOR_TEXT, SOUNDS.BOOK_ACQUIRED)
			messageParams:SetText("|t42:42:/esoui/art/treeicons/gamepad/gp_collection_indexicon_upgrade.dds|t "..message)
			CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
		end
	end
end

local function SetActiveGear(gear)
	SavedData.ActiveGear=gear
	if BUI_Gear then
		for g=1,GEARS do _G["BUI_Gear_But"..g]:SetState(gear==g and BSTATE_PRESSED or BSTATE_NORMAL) end
	end
	CALLBACK_MANAGER:FireCallbacks("BUI_Gear_Equipped", INSTANCE, gear)
end

local function SetActiveInstance(instance,includeUI)
	SavedData.Instance=instance-1
	INSTANCE=instance-1
	local name=SavedData.InstanceNames and SavedData.InstanceNames[instance] and Loc("Instance")..": "..SavedData.InstanceNames[instance] or Loc("Instance").." "..instance
	BUI_Gear_Radial.instance:SetText(name)
	if includeUI then
		BUI_Gear_iBox.m_comboBox:SelectItemByIndex(instance, true)
		FillAllSlots()
	end
end

--Duplicate checks
local function CheckWeaponDuplicate(gear,slot,equipType)
	if not isWeapon[slot] then return end
	--Duplicate check
	for x in pairs(isWeapon) do
		if x~=slot then
			if SavedData[gear+INSTANCE*100].wear[x]==SavedData[gear+INSTANCE*100].wear[slot] then
				SavedData[gear+INSTANCE*100].wear[x]=nil
				FillSlot(gear,"Weap",SLOT_POS[x][2],SLOT_POS[x][3])
				ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, GetString(SI_INVENTORY_EQUIPPED_ITEM_TOOLTIP))
			end
		end
	end
	--Off hand check
	if equipType==EQUIP_TYPE_TWO_HAND then
		local x=slot==EQUIP_SLOT_MAIN_HAND and EQUIP_SLOT_OFF_HAND or EQUIP_SLOT_BACKUP_OFF
		SavedData[gear+INSTANCE*100].wear[x]=nil
		FillSlot(gear,"Weap",SLOT_POS[x][2],SLOT_POS[x][3])
		ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, GetString(SI_INVENTORY_ERROR_WEAPON_TYPE_NOT_MET_FOR_EQUIP))
	--Main hand check
	elseif slot==EQUIP_SLOT_OFF_HAND or slot==EQUIP_SLOT_BACKUP_OFF then
		local x=slot==EQUIP_SLOT_OFF_HAND and EQUIP_SLOT_MAIN_HAND or EQUIP_SLOT_BACKUP_MAIN
		local uid=SavedData[gear+INSTANCE*100] and SavedData[gear+INSTANCE*100].wear and SavedData[gear+INSTANCE*100].wear[x] or nil
		if uid then
			local _,_,link=GetInventoryItem(uid)
			local equipType=GetItemLinkEquipType(link)
			if equipType==EQUIP_TYPE_TWO_HAND then
				SavedData[gear+INSTANCE*100].wear[x]=nil
				FillSlot(gear,"Weap",SLOT_POS[x][2],SLOT_POS[x][3])
				ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, GetString(SI_INVENTORY_ERROR_WEAPON_TYPE_NOT_MET_FOR_EQUIP))
			end
		end
	end
end

local function CheckMythicDuplicate(gear,slot)
	--Mythic items Duplicates check
	if not isWeapon[slot] then
		for x in pairs(SLOT_EQUIP) do
			if x~=slot and not isWeapon[x] then
				local _,quality=GetInventoryItem(SavedData[gear+INSTANCE*100].wear[x])
				if quality==ITEM_DISPLAY_QUALITY_MYTHIC_OVERRIDE then
					SavedData[gear+INSTANCE*100].wear[x]=nil
					FillSlot(gear,"Wear",SLOT_POS[x][2],SLOT_POS[x][3])
					ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, GetString(SI_INVENTORY_ERROR_ONLY_ONE_MYTHIC))
				end
			end
		end
	end
end

local function CheckAbilityDuplicate(gear,pair,slot)
	CheckDataStructure(gear+INSTANCE*100,"abil",pair)
	for x=1,5 do
		if x~=slot then
			if gear==0 then	--Single use slot
				SavedData[gear+INSTANCE*100].abil[pair][x]=nil
				FillSlot(gear,"Abil",pair,x)
			else
				if SavedData[gear+INSTANCE*100].abil[pair][x]==SavedData[gear+INSTANCE*100].abil[pair][slot] then
					SavedData[gear+INSTANCE*100].abil[pair][x]=nil
					FillSlot(gear,"Abil",pair,x)
				end
			end
		end
	end
end

--Equip
local function UnequipSlot(slot)
	if GetItemName(BAG_WORN,slot)~="" then UnequipItem(slot) return true end
end

local function EquipGearItem(gear,slot)
	if IsUnitInCombat('player') then return end
	local uid=SavedData[gear+INSTANCE*100] and SavedData[gear+INSTANCE*100].wear and SavedData[gear+INSTANCE*100].wear[slot] or nil
	if not uid then return end
	--Unequip
	if uid==0 then
		if slot==98 then	--Outfit
			local id=GetEquippedOutfitIndex()
			if id then UnequipOutfit(0) end
			return 0
		elseif slot>=99 then	--Collectible
			local id=GetActiveCollectibleByType(outfit_slots[slot-96])
			if id and id~=0 then
				UseCollectible(id)
				return 2000
			else
				if BUI.OnScreen and BUI.OnScreen.Message[13] and BUI.OnScreen.Message[13].count then BUI.OnScreen.Message[13].count=BUI.OnScreen.Message[13].count-2000 end
				return 0
			end
		else
			uid=Id64ToString(GetItemUniqueId(BAG_WORN, slot))
			if uid~=0 and uid~="0" then UnequipSlot(slot) return 260 else return 0 end
		end
	end
	--Equip
	if slot==98 then	--Outfit
		EquipOutfit(0,uid)
		return 0
	elseif slot>=99 then	--Collectible
		local id=GetActiveCollectibleByType(outfit_slots[slot-96])
		if id~=uid then
			UseCollectible(uid)
			return 2000
		else
			if BUI.OnScreen and BUI.OnScreen.Message[13] and BUI.OnScreen.Message[13].count then BUI.OnScreen.Message[13].count=BUI.OnScreen.Message[13].count-2000 end
			return 0
		end
	else
		local _,quality,_,equipped,bagId,slotIndex=GetInventoryItem(uid)
--		d(string.format('Equip item: %s (%s/%s, equipped: %s) to slot: %s', tostring(link),tostring(bagId),tostring(slotIndex),tostring(equipped),tostring(slot)))
		if slotIndex==nil then
			d(GetString(SI_EQUIPSLOT0+slot).." |cee2222was not found|r")
			return 0
		end
		if quality==ITEM_DISPLAY_QUALITY_MYTHIC_OVERRIDE then
			for x in pairs(SLOT_EQUIP) do
				if x~=slot and not isWeapon[x] then
					if GetItemDisplayQuality(BAG_WORN,x)==ITEM_DISPLAY_QUALITY_MYTHIC_OVERRIDE then
						UnequipItem(x)
						return 250
					end
				end
			end
		end
		if equipped==false then
			EquipItem(bagId,slotIndex,slot)
			return 100
		elseif slotIndex~=slot then
			UnequipItem(slotIndex)
			return 250
		end
	end
	return 0
end

local function EquipOutfitAll(gear)
	if BanditsGearManagerInProgress then return end
	local ItemsToEquip={}

	local function EquipTable()
		local slot=ItemsToEquip[1]
		if slot then
			local delay=EquipGearItem(gear,slot)
			if delay~=250 then table.remove(ItemsToEquip,1) end
			zo_callLater(EquipTable,delay)
		else
			BanditsGearManagerInProgress=false
			if BUI_Gear and BUI_Gear:IsHidden()==false then zo_callLater(function()FillSlot(gear,"Wear",2,6)end,250) end
--			ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "Equipping outfit: Done")
		end
	end

	if SavedData[gear+INSTANCE*100] and SavedData[gear+INSTANCE*100].wear then
		for i=2,14 do
			local slot=i+96
			if SavedData[gear+INSTANCE*100].wear[slot] then table.insert(ItemsToEquip,slot) end
		end
		ScreenMessage("Equipping outfit",#ItemsToEquip*2000)
		local delay=0
		BanditsGearManagerInProgress=true
		if not ArePlayerWeaponsSheathed() then TogglePlayerWield() delay=1050 end
		zo_callLater(EquipTable,delay)
	end
end

local function EquipWear(gear)
	if BanditsGearManagerInProgress then return end
	if BUI_Gear_Button then BUI_Gear_Button.info:SetText(gear) end
	GlobalData.CurrentGear=gear
	local ItemsToEquip={}

	local function EquipTable()
		local slot=ItemsToEquip[1]
		if slot then
			local delay=EquipGearItem(gear,slot)
			if delay~=250 then table.remove(ItemsToEquip,1) end
			zo_callLater(EquipTable,delay)
		else
			BanditsGearManagerInProgress=false
			if BUI_Gear and BUI_Gear:IsHidden()==false then zo_callLater(function()FillAllSlots()end,250) end
		end
	end

	if SavedData[gear+INSTANCE*100] and SavedData[gear+INSTANCE*100].wear then
		for slot in pairs(SavedData[gear+INSTANCE*100].wear) do table.insert(ItemsToEquip,slot) end
		if #ItemsToEquip>0 then
			local delay=0
			BanditsGearManagerInProgress=true
			if not ArePlayerWeaponsSheathed() then
				TogglePlayerWield() delay=1050
			end
			zo_callLater(EquipTable,delay)
		end
	end
end

function TranslateIdToScribedId(id)
	local scribedId=0	
	local scribed = IsCraftedAbilityScribed(id)
	if scribed then
		scribedId=GetAbilityIdForCraftedAbilityId(id)
			--d('ID:' .. id .. ' SCRIBED ID:' .. scribedId .. ' NAME: ' .. GetAbilityName(scribedId))
		return scribedId
	end
	return nil
end

local function EquipAbility(gear,pair,slot)
	local currentId=GetBaseAbilityId(GetSlotBoundId(slot+2))
	local id=SavedData[gear+INSTANCE*100] and SavedData[gear+INSTANCE*100].abil and SavedData[gear+INSTANCE*100].abil[pair] and SavedData[gear+INSTANCE*100].abil[pair][slot] or nil
	if id and id~=currentId then
		local skillType,skillLineIndex,skillIndex=GetSpecificSkillAbilityKeysByAbilityId(GetCurrentAbilityId(id))
		if skillType and skillLineIndex and skillIndex then
			SlotSkillAbilityInSlot(skillType, skillLineIndex, skillIndex, slot+2)
			return true
		end

		local abilityIndex=GetAbilityIndex(id)
		if abilityIndex and abilityIndex~=0 then
			CallSecureProtected('SelectSlotAbility', abilityIndex, slot+2)
			return true
		end
	end
end

local function EquipAbilityBar_v2(gear,current)
	local animation=0
	local function SwapAnimation()
		animation=animation+1
		ZO_ActionBar1WeaponSwap:SetNormalTexture(animation%2==1 and "/esoui/art/characterwindow/swap_button_over.dds" or "/esoui/art/characterwindow/swap_button_up.dds")
		if animation>20 and animation%2~=1 then
			AnimateSwap=false
		elseif AnimateSwap or animation%2==1 then
			zo_callLater(function()SwapAnimation()end,500)
		end
	end
	local function CheckAbilityBar(gear,pair)
		for x=1,6 do
			local id=SavedData[gear+INSTANCE*100] and SavedData[gear+INSTANCE*100].abil and SavedData[gear+INSTANCE*100].abil[pair] and SavedData[gear+INSTANCE*100].abil[pair][x] or nil
			if id then return true end
		end
	end

	local pair=current or GetActiveWeaponPairInfo()
	for x=1,6 do EquipAbility(gear,pair,x) end
	CALLBACK_MANAGER:FireCallbacks("BUI_Gear_PanelChanged",pair)
	if not current and not AbilityBarsDone then
		if CheckAbilityBar(gear,(pair==1 and 2 or 1)) then
			EVENT_MANAGER:UnregisterForEvent("BUI_Gear_Event", EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
			zo_callLater(function()
				AnimateSwap=true SwapAnimation()
				CALLBACK_MANAGER:FireCallbacks("BUI_Gear_Swap")
			end,1400)
			EVENT_MANAGER:RegisterForEvent("BUI_Gear_Event", EVENT_ACTIVE_WEAPON_PAIR_CHANGED,	function()
				AbilityBarsDone=true
				AnimateSwap=false
				zo_callLater(function()
					EVENT_MANAGER:UnregisterForEvent("BUI_Gear_Event", EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
					if IsActionBarRespeccable() and not IsUnitInCombat('player') then EquipAbilityBar_v2(gear) end
				end,300)
			end)
		end
	end
	AbilityBarsDone=false
end

local function EquipAbilityBar_v3(gear,pair)
	local function EquipPanel(pair,hotbarCategory)
--		d("Equipping: "..tostring(pair).." to "..tostring(hotbarCategory))
		local hotbarData=ACTION_BAR_ASSIGNMENT_MANAGER:GetHotbar(hotbarCategory or GetActiveWeaponPairInfo()-1)
		if hotbarData then
			for slot=1,6 do
				local id=SavedData[gear+INSTANCE*100] and SavedData[gear+INSTANCE*100].abil and SavedData[gear+INSTANCE*100].abil[pair] and SavedData[gear+INSTANCE*100].abil[pair][slot] or nil
				if id then
					hotbarData:AssignSkillToSlotByAbilityId(slot+2,GetCurrentAbilityId(id))
				else
--					hotbarData:ClearSlot(slot+2)
				end
			end
		else
			d(string.format(Loc("AbilityAlert"),tostring(pair)))
		end
	end
	if pair then
		EquipPanel(pair)
	else
		for pair=1,2 do
			EquipPanel(pair,pair-1)
		end
	end
end

local function EquipAbilityBar(gear,current)
	if GlobalData.AbilityManager==3 then
		EquipAbilityBar_v3(gear,current)
	else
		EquipAbilityBar_v2(gear,current)
	end
end

local function UnequipAll()
	if BanditsGearManagerInProgress then return end
	local SlotsToUnequip={}
	local function UnequipTable()
		local slot=SlotsToUnequip[1]
		if slot then
			local delay=UnequipSlot(slot)
			table.remove(SlotsToUnequip,1)
			zo_callLater(function()UnequipTable()end,delay and 250 or 0)
		else
			BanditsGearManagerInProgress=false
			if BUI_Gear and BUI_Gear:IsHidden()==false then zo_callLater(function()FillAllSlots()end,250) end
		end
	end
	BanditsGearManagerInProgress=true
	for _,data in pairs(SLOTS) do table.insert(SlotsToUnequip,data[1]) end
	UnequipTable()
end

--Keys
function BUI_GearEquip(gear)
	if not IsActionBarRespeccable() or IsUnitInCombat('player') then ScreenMessage("|cFE2222You are in combat|r") return end
	if not SavedData[gear+INSTANCE*100] or (not SavedData[gear+INSTANCE*100].wear and not SavedData[gear+INSTANCE*100].abil) then return end
	ScreenMessage(Loc("Equipping").." "..(SavedData[gear+INSTANCE*100] and SavedData[gear+INSTANCE*100].name and "\""..SavedData[gear+INSTANCE*100].name.."\"" or Loc("Gear").." "..gear))
	EquipWear(gear)
	EquipAbilityBar(gear)
	SetActiveGear(gear)
end

function BUI_GearSingleUse()
	local now=GetGameTimeMilliseconds()
	if not IsActionBarRespeccable() or IsUnitInCombat('player') or now-LastAction<1000 then
		ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, Loc("SusAlert"))
		return
	end
	EVENT_MANAGER:UnregisterForEvent("BUI_Gear_Event", EVENT_ACTION_SLOT_ABILITY_USED)
	LastAction=now
	local Pair=GetActiveWeaponPairInfo()
	local Slot,OriginalId,SingleUseId
	local delay=500

	local function ReturnSlotBack()
		if IsUnitInCombat('player') then
			d(string.format(Loc("AbilCombat"),GetAbilityName(OriginalId)))
			EVENT_MANAGER:RegisterForEvent("BUI_Gear_Event", EVENT_PLAYER_COMBAT_STATE, ReturnSlotBack)
		else
			EVENT_MANAGER:UnregisterForEvent("BUI_Gear_Event", EVENT_PLAYER_COMBAT_STATE)
			if GlobalData.AbilityManager==3 then	--AbilityManager 3.0
				local hotbarData=ACTION_BAR_ASSIGNMENT_MANAGER:GetHotbar(Pair-1)
				if hotbarData then
					hotbarData:AssignSkillToSlotByAbilityId(Slot+2,OriginalId)
				end
				SingleUseQueue=nil
			else
				if Pair==GetActiveWeaponPairInfo() then
					EVENT_MANAGER:UnregisterForEvent("BUI_Gear_Event", EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
					local abilityIndex=GetAbilityIndex(OriginalId)
					if abilityIndex and abilityIndex~=0 then
						CallSecureProtected('SelectSlotAbility', abilityIndex, Slot+2)
					end
					SingleUseQueue=nil
				else
					EVENT_MANAGER:RegisterForEvent("BUI_Gear_Event", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, function()zo_callLater(ReturnSlotBack,300)end)
				end
			end
		end
	end
	if SingleUseQueue then Pair,Slot,OriginalId=unpack(SingleUseQueue) ReturnSlotBack() end

	local function CheckPower(id)
		local cost,powerType=GetAbilityCost(id)
		local current=GetUnitPower("player", powerType)
		return cost<=current
	end

	local function OnSlotAbilityUsed(_,slot)
		if Pair==GetActiveWeaponPairInfo() and Slot+2==slot then
			EVENT_MANAGER:UnregisterForEvent("BUI_Gear_Event", EVENT_ACTION_SLOT_ABILITY_USED)
			zo_callLater(ReturnSlotBack,delay)
		end
	end

	for x=1,5 do local id=SavedData[INSTANCE*100] and SavedData[INSTANCE*100].abil and SavedData[INSTANCE*100].abil[1] and SavedData[INSTANCE*100].abil[1][x] or nil if id then Slot=x SingleUseId=id break end end
	if Slot then
		local id=GetSlotBoundId(Slot+2)
		if id~=0 and GetBaseAbilityId(SingleUseId)~=GetBaseAbilityId(id) then
			if CheckPower(SingleUseId) then
--				ScreenMessage("Single use: "..GetAbilityName(SingleUseId))
				if ArePlayerWeaponsSheathed() then TogglePlayerWield() delay=1000 end
				OriginalId=id
				SingleUseQueue={Pair,Slot,OriginalId}
				EquipAbility(0,1,Slot)
				EVENT_MANAGER:RegisterForEvent("BUI_Gear_Event", EVENT_ACTION_SLOT_ABILITY_USED, OnSlotAbilityUsed)
			else
				ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, Loc("NoResource"))
			end
		end
	end
end

function BUI_GearAdditionalPanel()
	if not IsActionBarRespeccable() or IsUnitInCombat('player') or not SavedData.ActiveGear then return end
	local g,done,slot=SavedData.ActiveGear,nil,nil
	local pair=GetActiveWeaponPairInfo()
	for x=1,6 do local id=SavedData[g+INSTANCE*100] and SavedData[g+INSTANCE*100].abil and SavedData[g+INSTANCE*100].abil[pair] and SavedData[g+INSTANCE*100].abil[pair][x] or nil
		if id and id~=GetBaseAbilityId(GetSlotBoundId(x+2)) then slot=x break end
	end
	if slot then
		for x=1,6 do if EquipAbility(g,pair,x) then done=true end end
		if done then ScreenMessage(pair.." Bar was returned back") end
	else
		for x=1,6 do if EquipAbility(g,3,x) then done=true end end
		if done then ScreenMessage("Additional bar was equipped") end
	end
	if done then CALLBACK_MANAGER:FireCallbacks("BUI_Gear_PanelChanged",pair) end
end

function BUI_GearRadialMenu(show)
	if show then
--		BUI_Gear_Radial.Menu:StartInteraction()
		BUI_Gear_Radial.Base:ShowMenu()
	else
		BUI_Gear_Radial.Base:StopInteraction()
		BUI_Gear_Preview:SetHidden(true)
	end
end

--RadialMenu
local function FillPreview(gear)
	local SetNames,name={},""
	for y=1,2 do
		for x=1,5 do
			local frame=_G["BUI_Gear_Prev_Wear"..y..x]
			if frame then
				local parent=frame:GetParent()
				local slot=SLOTS[(y-1)*6+x][1]
				local uid=SavedData[gear+INSTANCE*100] and SavedData[gear+INSTANCE*100].wear and SavedData[gear+INSTANCE*100].wear[slot] or nil
				local texture,quality,link=GetInventoryItem(uid)
				local color=quality and QUALITY_COLOR[quality] or ColorBlank
				frame:SetTexture(texture or "/esoui/art/characterwindow/gear+INSTANCE*100slot_"..SLOTS[(y-1)*6+x][2]..".dds")
				parent:SetCenterColor(unpack(color))
				local isSet,name=GetItemLinkSetInfo(link)
				if isSet then SetNames[name]=true end
			end
		end
		for x=1,2 do
			local frame=_G["BUI_Gear_Prev_Weap"..y..x]
			if frame then
				local parent=frame:GetParent()
				local slot=SLOTS[12+(y-1)*3+x][1]
				local uid=SavedData[gear+INSTANCE*100] and SavedData[gear+INSTANCE*100].wear and SavedData[gear+INSTANCE*100].wear[slot] or nil
				local texture,quality=GetInventoryItem(uid)
				local color=quality and QUALITY_COLOR[quality] or ColorBlank
				frame:SetTexture(texture or "/esoui/art/characterwindow/gear+INSTANCE*100slot_"..SLOTS[12+(y-1)*3+x][2]..".dds")
				parent:SetCenterColor(unpack(color))
			end
		end
		for x=1, 6 do
			local frame=_G["BUI_Gear_Prev_Abil"..y..x]
			if frame then
				local id=SavedData[gear+INSTANCE*100] and SavedData[gear+INSTANCE*100].abil and SavedData[gear+INSTANCE*100].abil[y] and SavedData[gear+INSTANCE*100].abil[y][x] or nil
				local texture=id and GetAbilityIcon(GetCurrentAbilityId(id)) or IconBlank				
				frame:SetTexture(texture)
			end
		end
	end

	for n in pairs(SetNames) do
		name=name..(name~="" and " + " or "")..string.gsub(n,"%^%w+","")
	end
	BUI_Gear_Prev_Name:SetText(name~="" and name or Loc("Gear").." "..gear)
	BUI_Gear_Preview:SetHidden(false)
end

local function PrepareGearMenu(control)
	local data,slots={},{100,EQUIP_SLOT_HEAD,EQUIP_SLOT_CHEST,EQUIP_SLOT_MAIN_HAND}
	for g=1,math.min(GEARS,6) do
		local texture,quality,link,equipped
		local key=GetKeyBind(g)
		local name=(SavedData[g+INSTANCE*100] and SavedData[g+INSTANCE*100].name or Loc("Gear").." "..g)..(key and "\n["..key.."]" or "")
		for _,slot in pairs(slots) do
			local uid=SavedData[g+INSTANCE*100] and SavedData[g+INSTANCE*100].wear and SavedData[g+INSTANCE*100].wear[slot] or nil
			if uid and uid~=0 then
				if slot==100 then
					texture=GetCollectibleIcon(uid)
				else
					texture,quality,link,equipped=GetInventoryItem(uid)
--					d("["..g.."] "..slot.." "..uid.." "..tostring(link))
				end
				break
			end
		end
		if not texture then texture="/esoui/art/treeicons/gamepad/gp_collection_indexicon_upgrade.dds" end
		data[g]={
			name=name,
			func=function(self) BUI_GearEquip(self.selectedEntry.data.index) end,
			activeIcon=texture,
			inactiveIcon=texture,
			index=g,
			isGear=true,
			}
	end

	for i=1, math.min(GEARS,6) do
		if data[i] then
			control.menu:AddEntry(data[i].name,data[i].inactiveIcon,data[i].activeIcon,data[i].func,data[i])
		else
			control.menu:AddEntry(GetString(SI_QUICKSLOTS_EMPTY),"EsoUI/Art/Quickslots/quickslot_emptySlot.dds","EsoUI/Art/Quickslots/quickslot_emptySlot.dds",nil,{})
		end
	end
	control.menu:AddEntry(Loc("SelectInstance"),"esoui/art/treeicons/gamepad/achievement_categoryicon_collections.dds","esoui/art/treeicons/gamepad/achievement_categoryicon_collections.dds",nil,{switcher=true})
	control.menu:AddEntry(GetString(SI_RADIAL_MENU_CANCEL_BUTTON),"EsoUI/Art/HUD/Gamepad/gp_radialIcon_cancel_down.dds","EsoUI/Art/HUD/Gamepad/gp_radialIcon_cancel_down.dds",nil,{})
end

local function PrepareInstanceMenu(control)
	local data={}
	for i=1,INSTANCES do
		data[i]={
			name=SavedData.InstanceNames and SavedData.InstanceNames[i] or Loc("Instance").." "..i,
			func=function(self)
				ScreenMessage(Loc("Activated").." "..tostring(self.selectedEntry.data.name))
				SetActiveInstance(self.selectedEntry.data.index,true)
			end,
			activeIcon="esoui/art/treeicons/gamepad/achievement_categoryicon_collections.dds",
			inactiveIcon="esoui/art/treeicons/gamepad/achievement_categoryicon_collections.dds",
			index=i,
			}
	end

	for i=1,7 do
		control.menu:AddEntry(data[i].name,data[i].inactiveIcon,data[i].activeIcon,data[i].func,data[i])
	end
	control.menu:AddEntry(GetString(SI_RADIAL_MENU_CANCEL_BUTTON),"EsoUI/Art/HUD/Gamepad/gp_radialIcon_cancel_down.dds","EsoUI/Art/HUD/Gamepad/gp_radialIcon_cancel_down.dds",nil,{})
end

local function RadialMenu_Init(control)
	control.entryControl.SetupEntryControl=function(self,entryControl,data)
		if not data then return end
--		d("SetupEntryControl: "..tostring(data.gear))
		ZO_SetupSelectableItemRadialMenuEntryTemplate(entryControl,false,data.index)
	end

	control.entryControl.PopulateMenu=function(self,isInstance)
		if isInstance then
			PrepareInstanceMenu(self)
			control.instance:SetHidden(true)
		else
			PrepareGearMenu(self)
			control.instance:SetHidden(false)
		end
	end

	local SelectionChangedCallback=control.Base.menu.onSelectionChangedCallback
	control.Base.menu.onSelectionChangedCallback=function(selectedEntry)
		if selectedEntry then
			if selectedEntry.data.switcher then
	--			ScreenMessage(Loc("MenuToggle"))
				EVENT_MANAGER:RegisterForEvent("BGM_DirtyPatch", EVENT_LUA_ERROR, ZO_UIErrors_HideCurrent)
				control.Base.menu:ResetData()
				control.entryControl.PopulateMenu(control.Base,true)
				control.Base.menu:Refresh()
				BUI.CallLater("BGM_DirtyPatch_Remove",100,function()EVENT_MANAGER:UnregisterForEvent("BGM_DirtyPatch", EVENT_LUA_ERROR)end)
				BUI_Gear_Preview:SetHidden(true)
			else
				SelectionChangedCallback(selectedEntry)
				if selectedEntry.data.isGear then
					FillPreview(selectedEntry.data.index)
				else
					BUI_Gear_Preview:SetHidden(true)
				end
			end
		end
	end
end

local function UI_Radial_Init()
	local control=BUI.UI.TopLevelWindow("BUI_Gear_Radial", GuiRoot, {GuiRoot:GetWidth(),GuiRoot:GetHeight()}, {CENTER,CENTER,0,0}, false)
	control.menu=BUI_Gear_RadialMenu or WINDOW_MANAGER:CreateControlFromVirtual("$(parent)Menu", control, "ZO_RadialMenuTemplate")
	control.instance=BUI.UI.Label("$(parent)InstanceLabel", control.menu, {300,20}, {BOTTOM,TOP,0,-40}, "ZoFontWinH3", nil, {1,1}, Loc("Instance"))
	control.entryControl=ZO_InteractiveRadialMenuController:Subclass()
	control.Base=control.entryControl.New(control.entryControl,BUI_Gear_Radial,"ZO_SelectableItemRadialMenuEntryTemplate","DefaultRadialMenuAnimation","SelectableItemRadialMenuEntryAnimation")

	local fs,space=18,2
	local s,s1=SLOTSIZE,SLOTSIZE+space
	local w,h=s1*14,s
	local gear	=BUI.UI.Control(	"BUI_Gear_Preview",		control,	{w,h},	{TOP,CENTER,-s1/2,240},true)
	gear.name	=BUI.UI.Label(	"BUI_Gear_Prev_Name",	gear,	{w,fs*1.5},	{BOTTOMLEFT,TOPLEFT,0,0},		BUI.UI.Font("esobold",fs,true), nil, {1,1}, Loc("Gear"))
	for y=1,2 do
		--Wear
		for x=1,5 do
			local wear	=BUI.UI.Backdrop(	"BUI_Gear_Prev_Wear_Bg"..y..x,	gear,	{s,s},	{TOPLEFT,TOPLEFT,s1*x,s1*(y-1)},		{.4,.4,.4,.2}, BorderColor)
			wear.icon	=BUI.UI.Statusbar("BUI_Gear_Prev_Wear"..y..x,	wear,	{s-4,s-4},	{CENTER,CENTER,0,0},		{1,1,1,1},IconBlank)
		end
		--Weapons
		for x=1,2 do
			local weap	=BUI.UI.Backdrop(	"BUI_Gear_Prev_Weap_Bg"..y..x,	gear,	{s,s},	{TOPLEFT,TOPLEFT,s1*5.5+s1*x,s1*(y-1)},		{.4,.4,.4,.2}, BorderColor)
			weap.icon	=BUI.UI.Statusbar("BUI_Gear_Prev_Weap"..y..x,	weap,	{s-4,s-4},	{CENTER,CENTER,0,0},		{1,1,1,1},IconBlank)
		end
		--Ability
		for x=1,6 do
			local abil	=BUI.UI.Backdrop(	"BUI_Gear_Prev_Abil_Bg"..y..x,	gear,	{s,s},	{TOPLEFT,TOPLEFT,s1*8+s1*x,s1*(y-1)},		{.4,.4,.4,.2}, BorderColor)
			abil.icon	=BUI.UI.Statusbar("BUI_Gear_Prev_Abil"..y..x,	abil,	{s-4,s-4},	{CENTER,CENTER,0,0},		{1,1,1,1},IconBlank)
		end
	end

	RadialMenu_Init(control)
end

--Drag and drop
local function Highlight(on)
	local slots=DragData.type=="Wear" and 6 or DragData.type=="Weap" and 3 or DragData.type=="Abil" and 6 or 0
	local panels=DragData.type=="Abil" and 3 or 2
--	if on then d(DragData) end
	for g=1, GEARS do
		if DragData.costume then
			local alpha=on and 3 or 1
			local control=_G["BUI_Gear_Wear_Bg"..g.."26"]
			if control then
				control:SetEdgeColor(control.edge[1],control.edge[2],control.edge[3],math.min(control.edge[4]*alpha,1))
				control.icon.ready=alpha~=1
			end
		else
			for y=1,panels do
				for x=1,slots do
					local alpha=1
					local control=_G["BUI_Gear_"..DragData.type.."_Bg"..g..y..x]
					if control then
						if on then
							if DragData.type=="Abil" then
								if DragData.ult==(x==6) then alpha=3 end
							else
								for _,slot in pairs(DragData.slot) do
									if slot==control.icon.slot then alpha=3 end
								end
							end
						end
						control:SetEdgeColor(control.edge[1],control.edge[2],control.edge[3],math.min(control.edge[4]*alpha,1))
						control.icon.ready=alpha~=1
					end
				end
			end
		end
	end
	--Single use slots
	if DragData.type=="Abil" then
		for x=1,5 do
			local alpha=1
			local control=_G["BUI_Gear_Abil_Bg01"..x]
			if control then
				if on and DragData.type=="Abil" and not DragData.ult then alpha=3 end
				control:SetEdgeColor(control.edge[1],control.edge[2],control.edge[3],math.min(control.edge[4]*alpha,1))
				control.icon.ready=alpha~=1
			end
		end
	end
end

local function OnReceiveDrag(self)
	local function DropItem()
		ClearCursor()
		if self.ready then
			PlaySound('Tablet_PageTurn')
			CheckDataStructure(self.gear+INSTANCE*100,"wear")
			if DragData.control and SavedData[self.gear+INSTANCE*100].wear[self.slot] then	--Swap slots
				local drag=DragData.control
				SavedData[drag.gear+INSTANCE*100].wear[drag.slot]=SavedData[self.gear+INSTANCE*100].wear[self.slot]
				FillSlot(drag.gear,drag.type,drag.y,drag.x)
				CheckWeaponDuplicate(drag.gear,drag.slot,DragData.equipType)
			else
				DragData.done=true
			end
			SavedData[self.gear+INSTANCE*100].wear[self.slot]=DragData.uid
			FillSlot(self.gear,DragData.type,self.y,self.x)
			CheckWeaponDuplicate(self.gear,self.slot,DragData.equipType)
			if DragData.quality==ITEM_DISPLAY_QUALITY_MYTHIC_OVERRIDE then
				local drag=DragData.control	or self
				CheckMythicDuplicate(drag.gear,drag.slot)
			end
			--Mouseover highlight
			local bg=self:GetParent()
			local r,g,b,a=bg:GetCenterColor()
			bg:SetCenterColor(r,g,b,a*2)
		end
	end

	local function DropSkill()
		ClearCursor()
		if self.ready then
			PlaySound('Tablet_PageTurn')
			CheckDataStructure(self.gear+INSTANCE*100,"abil",self.pair)
			if DragData.control and SavedData[self.gear+INSTANCE*100].abil[self.pair][self.slot] then	--Swap slots
				local drag=DragData.control
				SavedData[drag.gear+INSTANCE*100].abil[drag.pair][drag.slot]=SavedData[self.gear+INSTANCE*100].abil[self.pair][self.slot]
				FillSlot(drag.gear,"Abil",drag.pair,drag.slot)
				CheckAbilityDuplicate(drag.gear,drag.pair,drag.slot)
			else
				DragData.done=true
			end
			SavedData[self.gear+INSTANCE*100].abil[self.pair][self.slot]=DragData.id
			FillSlot(self.gear,"Abil",self.pair,self.slot)
			CheckAbilityDuplicate(self.gear,self.pair,self.slot)
		end
	end

	local cursor=GetCursorContentType()
	if cursor==MOUSE_CONTENT_EMPTY then
		if DragData.id then DropSkill() elseif DragData.uid then DropItem() end
	elseif cursor==MOUSE_CONTENT_INVENTORY_ITEM or cursor==MOUSE_CONTENT_EQUIPPED_ITEM then
		DropItem()
	elseif cursor==MOUSE_CONTENT_ACTION then
		DropSkill()
	end
end

local function OnCursorPickup(self, cursorType, param1, param2, param3)
--	d(string.format('CursorPickup CT: %s, P1: %s, P2: %s, type: %s', tostring(cursorType), tostring(param1), tostring(param2), type(self)))
	if cursorType==MOUSE_CONTENT_INVENTORY_ITEM or cursorType==MOUSE_CONTENT_EQUIPPED_ITEM then
		local bag, slot
		if cursorType==MOUSE_CONTENT_INVENTORY_ITEM then
			bag=param1
			slot=param2
		else
			bag=BAG_WORN
			slot=param1
		end
		local itemType=GetItemType(bag, slot)
		if isEquipment[itemType] then
			local _,_,_,_,_,equipType,_,_,quality=GetItemInfo(bag, slot)
			DragData={
				uid=Id64ToString(GetItemUniqueId(bag, slot)),
				link=GetItemLink(bag, slot),
				slot=SLOT_EQUIP[equipType],
				type=SLOT_TYPE[equipType],
				equipType=equipType,
				quality=quality,
				}
--			StartChatInput(DragData.uid)
			Highlight(true)
		end
	elseif cursorType==MOUSE_CONTENT_ACTION then
		if type(self)=="userdata" then
			local id=self.type=="Abil" and SavedData[self.gear+INSTANCE*100] and SavedData[self.gear+INSTANCE*100].abil and SavedData[self.gear+INSTANCE*100].abil[self.pair] and SavedData[self.gear+INSTANCE*100].abil[self.pair][self.slot] or nil
			local uid=(self.type=="Wear" or self.type=="Weap") and SavedData[self.gear+INSTANCE*100] and SavedData[self.gear+INSTANCE*100].wear and SavedData[self.gear+INSTANCE*100].wear[self.slot] or nil
			local _,quality,link=GetInventoryItem(uid)
			local slot=link and SLOT_EQUIP[GetItemLinkEquipType(link)] or {}
			if id or uid then
				DragData={id=id,uid=uid,link=link,ult=self.slot==6,costume=self.slot==100,type=self.type,slot=slot,quality=quality,control=self}
				self:SetMouseEnabled(false)
				self:SetDrawTier(2)
				Highlight(true)
--				d(DragData)
			end
		else
			local sourceSlot=param2
			local abilityIndex=param3
			local abilityId=GetAbilityIdByIndex(abilityIndex)
			local craftedId=GetCraftedAbilityIdAtIndex(abilityIndex)			
			local id=TranslateIdToScribedId(abilityIndex) and abilityIndex or GetBaseAbilityId(abilityId)
			--d(string.format('Slot %d, AbilityIndex: %d, AbilityId: %d, BaseAbilityId: %d', sourceSlot, abilityIndex, abilityId, id))
			local baseSkillType, baseSkillindex, baseAbilityIndex, morphChoice=GetSpecificSkillAbilityKeysByAbilityId(id)
			if baseSkillType and baseSkillindex and baseAbilityIndex then
				local _,_,_,_, ult, purchased=GetSkillAbilityInfo(baseSkillType, baseSkillindex, baseAbilityIndex)
				if purchased or TranslateIdToScribedId(id) then
					DragData={id=id,ult=ult,type="Abil"}
					Highlight(true)
				end
			end
		end
	end
end

local function OnCursorDrop()
--	d("Drop")
	Highlight(false)
	DragData={}
end

--Context menu
local function ContextClick(c,option)
	if option==1 then		--Clear
		local function AbilClear(pair)
			CheckDataStructure(c.gear+INSTANCE*100,"abil",pair)
			SavedData[c.gear+INSTANCE*100].abil[pair]=nil
			for x=1, 6 do FillSlot(c.gear,"Abil",pair,x) end
		end
		local function WearClear()
			CheckDataStructure(c.gear+INSTANCE*100,"wear")
			SavedData[c.gear+INSTANCE*100].wear=nil
			for y=1,2 do
				for x=1,6 do FillSlot(c.gear,"Wear",y,x) end
				for x=1,3 do FillSlot(c.gear,"Weap",y,x) end
			end
			SETNAMES[c.gear]={}
			FillGearName(c.gear)
		end
		if c.type=="Pair" then
			AbilClear(c.pair)
		elseif c.type=="Section" then
			WearClear()
		elseif c.type=="Gear" then
			for y=1,2 do AbilClear(y) end
			WearClear()
		end
	elseif option==2 then		--Equip
		if c.type=="Pair" then
			EquipAbilityBar(c.gear,c.pair)
		elseif c.type=="Section" then
			EquipWear(c.gear)
		elseif c.type=="Gear" then
			BUI_GearEquip(c.gear)
		end
	elseif option==3 then	--Insert Current
		local function AbilInsert(pair)
			for x=1, 6 do
				local id=GetSlotBoundId(x+2)
				if id>0 then
					CheckDataStructure(c.gear+INSTANCE*100,"abil",pair)					
					SavedData[c.gear+INSTANCE*100].abil[pair][x]=GetBaseAbilityId(id)
					if TranslateIdToScribedId(id) then SavedData[c.gear+INSTANCE*100].abil[pair][x]=id end
					FillSlot(c.gear,"Abil",pair,x)
				end
			end
		end
		local function WearInsert()
			SETNAMES[c.gear]={}
			for y=1,2 do
				for x=1,6 do	--Wear
					local slot,uid=SLOTS[(y-1)*6+x][1]
					if y==2 and x==6 then
						uid=GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_COSTUME)
					else
						uid=Id64ToString(GetItemUniqueId(BAG_WORN, slot))
					end
					if uid~=0 and uid~="0" then
						CheckDataStructure(c.gear+INSTANCE*100,"wear",slot)
						SavedData[c.gear+INSTANCE*100].wear[slot]=uid
						FillSlot(c.gear,"Wear",y,x)
					end
				end
				for x=1,3 do	--Weapons
					local slot=SLOTS[12+(y-1)*3+x][1]
					local uid=Id64ToString(GetItemUniqueId(BAG_WORN, slot))
					if uid~="0" then
						CheckDataStructure(c.gear+INSTANCE*100,"wear",slot)
						SavedData[c.gear+INSTANCE*100].wear[slot]=uid
						FillSlot(c.gear,"Weap",y,x)
					end
				end
			end
			FillGearName(c.gear)
		end
		if c.type=="Pair" then
			AbilInsert(c.pair)
		elseif c.type=="Section" then
			WearInsert()
		elseif c.type=="Gear" then
			for y=1,2 do AbilInsert(y) end
			WearInsert()
			SetActiveGear(c.gear)
		end
	elseif option==4 then	--Copy
		COPY={type=c.type,gear=c.gear+INSTANCE*100,pair=c.pair}
	elseif option==5 and COPY then	--Paste
		local function WearPaste()
			SETNAMES[c.gear]={}
			for y=1,2 do
				for x=1,6 do	--Wear
					local slot=SLOTS[(y-1)*6+x][1]
					local uid=SavedData[COPY.gear] and SavedData[COPY.gear].wear and SavedData[COPY.gear].wear[slot] or nil
					if uid then
						CheckDataStructure(c.gear+INSTANCE*100,"wear",slot)
						SavedData[c.gear+INSTANCE*100].wear[slot]=uid
						FillSlot(c.gear,"Wear",y,x)
					end
				end
				for x=1,3 do	--Weapons
					local slot=SLOTS[12+(y-1)*3+x][1]
					local uid=SavedData[COPY.gear] and SavedData[COPY.gear].wear and SavedData[COPY.gear].wear[slot] or nil
					if uid then
						CheckDataStructure(c.gear+INSTANCE*100,"wear",slot)
						SavedData[c.gear+INSTANCE*100].wear[slot]=uid
						local link=FillSlot(c.gear,"Weap",y,x)
						CheckWeaponDuplicate(c.gear,slot,GetItemLinkEquipType(link))
					end
				end
			end
			FillGearName(c.gear)
		end
		if COPY.type=="Pair" then
			for x=1, 6 do
				local id=SavedData[COPY.gear] and SavedData[COPY.gear].abil and SavedData[COPY.gear].abil[COPY.pair] and SavedData[COPY.gear].abil[COPY.pair][x] or nil
				if id then
					CheckDataStructure(c.gear+INSTANCE*100,"abil",c.pair)
					SavedData[c.gear+INSTANCE*100].abil[c.pair][x]=id
					FillSlot(c.gear,"Abil",c.pair,x)
				end
			end
		elseif COPY.type=="Section" then
			WearPaste()
		elseif COPY.type=="Gear" then
			WearPaste()
			for y=1, 2 do
				for x=1, 6 do
					local id=SavedData[COPY.gear] and SavedData[COPY.gear].abil and SavedData[COPY.gear].abil[y] and SavedData[COPY.gear].abil[y][x] or nil
					if id then
						CheckDataStructure(c.gear+INSTANCE*100,"abil",y,x)
						SavedData[c.gear+INSTANCE*100].abil[y][x]=id
						FillSlot(c.gear,"Abil",y,x)
					end
				end
			end
		end
	elseif option==6 then	--Unequip
		UnequipAll()
	end
end

local function UI_Context_Init(parent)
	EVENT_MANAGER:UnregisterForEvent("BUI_Gear_Context",EVENT_GLOBAL_MOUSE_UP)
	local fs=18
	local space=2
	local w,h=120,#CONTEXT*fs*1.5
	local anchor=parent.type=="Gear" and {TOPLEFT,BOTTOMLEFT,SLOTSIZE+2,-2} or {TOPLEFT,TOPRIGHT,-space,0}
	local ui	=BUI.UI.TopLevelWindow("BUI_Gear_Context",	parent,	{w,h},	anchor, false)
	ui.bg		=BUI.UI.Backdrop(	"BUI_Gear_Context_Bg",		ui,		{w,h},	{TOPLEFT,TOPLEFT,0,0},	{.2,.2,.2,1}, BorderColor, nil, false)
	ui:SetDrawTier(DT_HIGH)
	ui.parent=parent
	for i,text in pairs(CONTEXT) do
		local b=BUI.UI.Button(	"BUI_Gear_Context_B"..i,	ui,		{w,fs*1.5},	{TOPLEFT,TOPLEFT,5,(i-1)*fs*1.5},	BSTATE_NORMAL, BUI.UI.Font("standard",fs,true), {0,1}, {.7,.7,.5,1}, nil, nil, false)
		b:SetText(text)
		b:SetHandler("OnClicked", function(self) ContextClick(self:GetParent().parent,i) end)
	end

	zo_callLater(function()
		EVENT_MANAGER:RegisterForEvent("BUI_Gear_Context",EVENT_GLOBAL_MOUSE_UP,function()
			BUI_Gear_Context:SetHidden(true)
			EVENT_MANAGER:UnregisterForEvent("BUI_Gear_Context",EVENT_GLOBAL_MOUSE_UP)
		end)
	end,250)
end

local function OnSectionMouseUp(self,button)
	if button==2 then			--Context menu
		UI_Context_Init(self)
	elseif button==1 then		--Equip
		if self.type=="Pair" then
			EquipAbilityBar(self.gear,self.pair)
		elseif self.type=="Section" then
			EquipWear(self.gear)
		elseif self.type=="Gear" then
			BUI_GearEquip(self.gear)
		end
	end
--	zo_callLater(function()SetGameCameraUIMode(true)end,200)
	ui_hold=true
end

--Mouse events
local function OnSlotMouseUp(self,button,upInside,ctrl,alt,shift)
	local function ClearOutfit()
		for i=2,14 do
			CheckDataStructure(self.gear+INSTANCE*100,"wear")
			SavedData[self.gear+INSTANCE*100].wear[i+96]=nil
		end
		FillOutfit(self.gear)
		FillSlot(self.gear,"Wear",2,6)
	end
	local function ClearSlot()
		if self.type=="Outfit" or self.type=="OutfitSlot" then
			CheckDataStructure(self.gear+INSTANCE*100,"wear")
			SavedData[self.gear+INSTANCE*100].wear[self.slot]=nil
			self:SetTexture(outfit_icons[self.slot-96])
			self:SetColor(1,1,1,.3)
			local parent=self:GetParent()
			parent:SetCenterColor(.4,.4,.4,.2)
			parent:SetEdgeColor(unpack(BorderColor))
			if self.slot==100 then FillSlot(self.gear,"Wear",2,6)
			elseif self.slot==98 then BUI_Gear_Outfit_Label:SetText("") BUI_Gear_Outfit_Slot2:SetColor(1,1,1,.3) end
		elseif self.type=="OutfitFill" then
			ClearOutfit()
		elseif self.type=="Wear" or self.type=="Weap" then
			if self.y==2 and self.x==6 then ClearOutfit() return end
			CheckDataStructure(self.gear+INSTANCE*100,"wear",self.slot)
			SavedData[self.gear+INSTANCE*100].wear[self.slot]=nil
			FillSlot(self.gear,self.type,self.y,self.x)
		elseif self.type=="Abil" then
			CheckDataStructure(self.gear+INSTANCE*100,"abil",self.pair)
			SavedData[self.gear+INSTANCE*100].abil[self.pair][self.slot]=nil
			FillSlot(self.gear,"Abil",self.pair,self.slot)
		end
		PlaySound("Ability_Unslotted")
	end
	self:ClearAnchors()
	self:SetAnchor(CENTER,nil,CENTER,0,0)
	if DragData.control==self then
		Highlight(false)
		self:SetMouseEnabled(true)
		self:SetDrawTier(1)
		if not shift and DragData.done then ClearSlot() end
		DragData={}
	elseif button==1 then
		if self.type=="Abil" then
			EquipAbility(self.gear,self.pair,self.slot)
		elseif self.type=="Wear" and self.y==2 and self.x==6 then
			EquipOutfitAll(self.gear)
		elseif self.type=="Wear" or self.type=="Weap" then
			local done=EquipGearItem(self.gear,self.slot)
			if done and BUI_Gear and BUI_Gear:IsHidden()==false then
				zo_callLater(function()
					for gear=1,GEARS do FillSlot(gear,self.type,self.y,self.x) end
				end,300)
			end
		elseif self.type=="OutfitFill" then
			for i=3,14 do
				local id=GetActiveCollectibleByType(outfit_slots[i])
				if id and id~=0 then
					CheckDataStructure(self.gear+INSTANCE*100,"wear")
					SavedData[self.gear+INSTANCE*100].wear[i+96]=id
				end
			end
			local id=GetEquippedOutfitIndex()
			SavedData[self.gear+INSTANCE*100].wear[98]=id
			FillOutfit(self.gear)
			FillSlot(self.gear,"Wear",2,6)
		elseif self.type=="Outfit" then
			EquipGearItem(self.gear,self.slot)
			zo_callLater(function()FillOutfit(self.gear)end,300)
		end
	elseif button==2 then
		if self.type=="Wear" or self.type=="Weap" or self.type=="Outfit" or self.type=="OutfitSlot" then
			local uid=SavedData[self.gear+INSTANCE*100] and SavedData[self.gear+INSTANCE*100].wear and SavedData[self.gear+INSTANCE*100].wear[self.slot] or nil
			if not uid and not (self.y==2 and self.x==6) and self.slot~=101 then
				self:SetColor(1,.2,.2,(self.type=="Outfit" or self.type=="OutfitSlot") and .3 or 1)
				CheckDataStructure(self.gear+INSTANCE*100,"wear")
				SavedData[self.gear+INSTANCE*100].wear[self.slot]=0	--Unequip
			else
				ClearSlot()
			end
		else
			ClearSlot()
		end
	end
--	zo_callLater(function()SetGameCameraUIMode(true)end,200)
	ui_hold=true
end

local function OnMouseOver(self,on)
	if self.outfit then
		if not MouseOverDelay then MouseOverDelay=true zo_callLater(function() OnMouseOver(self,on) MouseOverDelay=false end,10) return end
		if BUI_Gear_Outfit_Settings.over then on=true end
		if on then
			BUI_Gear_Outfit_Settings:ClearAnchors()
			BUI_Gear_Outfit_Settings:SetAnchor(BOTTOMLEFT,self,BOTTOMLEFT,2,-2)
			BUI_Gear_Outfit_Settings.gear=self.gear
			BUI_Gear_Outfit_Settings.parent=self
		end
		BUI_Gear_Outfit_Settings:SetHidden(not on)
	end
	local bg=self:GetParent()
	local r,g,b,a=bg:GetCenterColor()
	bg:SetCenterColor(r,g,b,a*(on and 2 or .5))
	ShowTooltip(self,on)
end

local function MouseHandlers(control)
	control:SetDrawTier(1)
--	control:SetClickSound('Click')
--	control:EnableMouseButton(2,true)
	control:SetMouseEnabled(true)
--	control:SetMovable(true)
	control:SetHandler('OnReceiveDrag',OnReceiveDrag)
	control:SetHandler("OnDragStart", OnCursorPickup)
	control:SetHandler("OnMouseUp", OnSlotMouseUp)
	control:SetHandler("OnMouseEnter", function(self) OnMouseOver(self,true) end)
	control:SetHandler("OnMouseExit", function(self) OnMouseOver(self,false) end)
end

local function OnBoxMouseOver(control,on)
	if BUI_Gear_Edit.over or not control then return end
	if on then
		local gear=control:GetParent().gear
		BUI_Gear_Edit:ClearAnchors()
		BUI_Gear_Edit:SetAnchor(TOPLEFT,control,TOPLEFT,0,0)
		BUI_Gear_Edit:SetAnchor(BOTTOMRIGHT,control,BOTTOMRIGHT,0,0)
		BUI_Gear_Edit.gear=gear
		BUI_Gear_Edit.eb:SetText(control:GetText())
		BUI_Gear_Edit.over=true
		BUI_Gear_Edit.label=control
	end
	BUI_Gear_Edit:SetHidden(not on)
	control:SetHidden(on)
end

--Inventory
local function AddMarkers()
	if not (GlobalData.MarkItems or GlobalData.MarkCollect) or markers_init then return end
	local function SetItemMark(self,isStorage)
		if not self then return end
		local itemData=self.dataEntry.data
		if not itemData then return end
		--Gear items
		if GlobalData.MarkItems then
			if self.BUI_Mark then self.BUI_Mark:SetHidden(true) end
			local _uid=Id64ToString(GetItemUniqueId(itemData.bagId,itemData.slotIndex))
			if not _uid then return end
			local have_item=false
			for g=1,GEARS do
				for i=0,6 do
					for _,data in pairs(SLOTS) do
						local slot=data[1]
						if slot~=100 then
							local uid=SavedData[g+i*100] and SavedData[g+i*100].wear and SavedData[g+i*100].wear[slot] or nil
							if uid==_uid then
								if self.BUI_Mark then
									self.BUI_Mark:SetHidden(false)
								else
									self.BUI_Mark=WINDOW_MANAGER:CreateControl(self:GetName()..'BUI_Mark',self,CT_TEXTURE)
									self.BUI_Mark:ClearAnchors()
									self.BUI_Mark:SetAnchor(RIGHT,self:GetNamedChild('Bg'),RIGHT,-50,0)
									self.BUI_Mark:SetDimensions(30,30)
									self.BUI_Mark:SetHidden(false)
									self.BUI_Mark:SetTexture('/esoui/art/treeicons/gamepad/gp_collection_indexicon_upgrade.dds')
									self.BUI_Mark:SetDrawLayer(3)
								end
								have_item=true
								break
							end
						end
					end
					if have_item then break end
				end
				if have_item then break end
			end
--			if isStorage and have_item then d("have_item") end
		end
		--Set items
		if GlobalData.MarkCollect then
			if IsItemSetCollectionPieceUnlocked then
				if self.BUI_Collect then self.BUI_Collect:SetHidden(true) end
				local itemLink=GetItemLink(itemData.bagId,itemData.slotIndex)
				local itemType=GetItemLinkItemType(itemLink)
				if (itemType==ITEMTYPE_ARMOR or itemType==ITEMTYPE_WEAPON) and GetItemLinkSetInfo(itemLink) then
					if not IsItemSetCollectionPieceUnlocked(GetItemLinkItemId(itemLink)) then
						if self.BUI_Collect then
							self.BUI_Collect:SetHidden(false)
						else
							self.BUI_Collect=WINDOW_MANAGER:CreateControl(self:GetName()..'BUI_Collect',self,CT_TEXTURE)
							self.BUI_Collect:ClearAnchors()
							self.BUI_Collect:SetAnchor(RIGHT,self:GetNamedChild('Bg'),RIGHT,-73,0)
							self.BUI_Collect:SetDimensions(30,30)
							self.BUI_Collect:SetHidden(false)
							self.BUI_Collect:SetTexture('/esoui/art/collections/collections_tabIcon_itemSets_down.dds')
							self.BUI_Collect:SetDrawLayer(3)
						end
					end
				end
			end
		end
	end
	local backpack={{ZO_PlayerInventoryBackpack},{ZO_PlayerBankBackpack,true},{ZO_HouseBankBackpack,true},{ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack},{ZO_SmithingTopLevelImprovementPanelInventoryBackpack}}
	for _,data in pairs(backpack) do
		local orig=data[1].dataTypes[1].setupCallback
		data[1].dataTypes[1].setupCallback=function(self,slot) orig(self,slot) SetItemMark(self,data[2]) end
	end

	EVENT_MANAGER:RegisterForEvent("BUI_Gear_Event", EVENT_ITEM_SET_COLLECTION_UPDATED, function(_,itemSetId)
		if not ZO_PlayerInventory:IsHidden() then
			SHARED_INVENTORY:RefreshInventory(BAG_BACKPACK)
		end
	end)
	markers_init=true
end

local function InventoryUpdate(_,bag,slot)
	if bag~=BAG_WORN then return end
	local Bg=_G["BUI_Inventory"..slot.."_Bg"]
	local Cond=_G["BUI_Inventory"..slot.."_Cond"]
	if GetItemInstanceId(BAG_WORN, slot) then
		local link=GetItemLink(BAG_WORN,slot)
		local color=QUALITY_COLOR[GetItemLinkQuality(link)]
		Bg:SetColor(unpack(color))
		if DoesItemHaveDurability(BAG_WORN,slot) then
			local cond=GetItemLinkCondition(link)
			local color=cond<=10 and {.8,.2,.2,1} or cond<=25 and {.8,.8,.2,1} or {.8,.8,.8,1}
			Cond:SetText(cond..'%')
			Cond:SetColor(unpack(color))
			Cond:SetHidden(false)
		else
			Cond:SetHidden(true)
		end
	else
		Bg:SetColor(unpack(ColorBlank))
		Cond:SetHidden(true)
	end
	zo_callLater(function()
		local pos=SLOT_POS[slot]
		if pos and BUI_Gear and BUI_Gear:IsHidden()==false then
			for gear=1,GEARS do
				FillSlot(gear,unpack(pos))
			end
		end
	end,300)
end

local function InventoryPrepare()
	local space=10
	local enable={
	ZO_CharacterPaperDoll=true,
--	ZO_CharacterApparelSection=true,
	ZO_CharacterAccessoriesSection=true,
	ZO_CharacterWeaponsSection=true,
	ZO_CharacterEquipmentSlotsHead={TOPLEFT,ZO_Character,TOPLEFT,5,100},
	ZO_CharacterEquipmentSlotsCostume={BOTTOMLEFT,ZO_CharacterEquipmentSlotsChest,TOPRIGHT,space,-space},
	ZO_CharacterEquipmentSlotsShoulder={TOPLEFT,ZO_CharacterEquipmentSlotsHead,BOTTOMLEFT,0,space},
	ZO_CharacterEquipmentSlotsGlove={TOPLEFT,ZO_CharacterEquipmentSlotsShoulder,BOTTOMLEFT,0,space},
	ZO_CharacterEquipmentSlotsLeg={TOPLEFT,ZO_CharacterEquipmentSlotsGlove,BOTTOMLEFT,0,space},
	ZO_CharacterEquipmentSlotsChest={TOPLEFT,ZO_CharacterEquipmentSlotsShoulder,TOPRIGHT,space,0},
	ZO_CharacterEquipmentSlotsBelt={TOPLEFT,ZO_CharacterEquipmentSlotsGlove,TOPRIGHT,space,0},
	ZO_CharacterEquipmentSlotsFoot={TOPLEFT,ZO_CharacterEquipmentSlotsLeg,TOPRIGHT,space,0},
	ZO_CharacterEquipmentSlotsNeck={TOPLEFT,ZO_CharacterEquipmentSlotsChest,TOPRIGHT,space,0},
	ZO_CharacterEquipmentSlotsRing1={TOPLEFT,ZO_CharacterEquipmentSlotsBelt,TOPRIGHT,space,0},
	ZO_CharacterEquipmentSlotsRing2={TOPLEFT,ZO_CharacterEquipmentSlotsFoot,TOPRIGHT,space,0},
	ZO_CharacterEquipmentSlotsMainHand={TOPLEFT,ZO_CharacterEquipmentSlotsLeg,BOTTOMLEFT,0,space},
	ZO_CharacterEquipmentSlotsBackupMain={TOPLEFT,ZO_CharacterEquipmentSlotsMainHand,BOTTOMLEFT,0,space},
	}
--	/script local _,p1,parent,p2,s1,s2=ZO_CharacterEquipmentSlotsBackupMain:GetAnchor() StartChatInput(string.format('{%d,%s,%d,%d,%d},', p1,parent:GetName(),p2,s1,s2))
	local disable={
	ZO_CharacterPaperDoll=true,
--	ZO_CharacterApparelSection=true,
	ZO_CharacterAccessoriesSection=true,
	ZO_CharacterWeaponsSection=true,
	ZO_CharacterEquipmentSlotsHead={1,ZO_Character,3,87,100},
	ZO_CharacterEquipmentSlotsShoulder={3,ZO_Character,3,10,156},
	ZO_CharacterEquipmentSlotsGlove={1,ZO_CharacterEquipmentSlotsShoulder,4,0,10},
	ZO_CharacterEquipmentSlotsLeg={1,ZO_CharacterEquipmentSlotsGlove,4,0,10},
	ZO_CharacterEquipmentSlotsChest={3,ZO_Character,3,124,156},
	ZO_CharacterEquipmentSlotsBelt={1,ZO_CharacterEquipmentSlotsChest,4,0,10},
	ZO_CharacterEquipmentSlotsFoot={1,ZO_CharacterEquipmentSlotsBelt,4,0,10},
	ZO_CharacterEquipmentSlotsCostume={3,ZO_Character,3,10,345},
	ZO_CharacterEquipmentSlotsNeck={2,ZO_CharacterEquipmentSlotsCostume,8,4,0},
	ZO_CharacterEquipmentSlotsRing1={2,ZO_CharacterEquipmentSlotsNeck,8,4,0},
	ZO_CharacterEquipmentSlotsRing2={2,ZO_CharacterEquipmentSlotsRing1,8,4,0},
	ZO_CharacterEquipmentSlotsMainHand={3,ZO_Character,3,10,432},
	ZO_CharacterEquipmentSlotsBackupMain={3,ZO_CharacterEquipmentSlotsMainHand,6,0,4},
	}
--	/script StartChatInput(_G['ZO_CharacterEquipmentSlotsMainHandHighlight']:GetDimensions())
	if GlobalData.Inventory then
		for name,value in pairs (enable) do
			local frame=_G[name]
			if frame then
				if value==true then
					frame:SetHidden(true)
				else
					frame:ClearAnchors()
					frame:SetAnchor(unpack(value))
				end
			end
		end
		for _,slot in pairs(SLOTS) do
			local parent=_G['ZO_CharacterEquipmentSlots'..(slot[3] or slot[2])]
			if parent then

--				parent:SetMouseOverTexture(AddonName.."/selected.dds")
--				parent:SetPressedMouseOverTexture(AddonName.."/selected.dds")
--				parent:GetNamedChild('DropCallout'):SetTexture(AddonName.."/selected.dds")
				local highlight=parent:GetNamedChild('Highlight') if highlight then
					highlight:SetTexture(AddonName.."/selected.dds")
					highlight:SetDimensions(50,50)	--parent:GetWidth(), parent:GetHeight()
				end

				local bg=BUI.UI.Texture("BUI_Inventory"..slot[1].."_Bg", parent, {50,25}, {BOTTOM,BOTTOM,0,3},AddonName.."/default.dds",false)
				bg:SetColor(unpack(QUALITY_COLOR[0]))
--				local bord=BUI.UI.Texture("BUI_Inventory"..slot[1].."_Bord", parent, {50,12.5}, {BOTTOM,BOTTOM,0,3},AddonName.."/default1.dds",false)
--				bord:SetDrawLayer(0) bord:SetAlpha(.8)
--				local icon=_G['ZO_CharacterEquipmentSlots'..(slot[3] or slot[2]).."Icon"] if icon then icon:SetDrawLayer(1) end
				local label=BUI.UI.Label("BUI_Inventory"..slot[1].."_Cond", parent, {44,10}, {TOPRIGHT,TOPRIGHT,-2,-2}, 'ZoFontGameSmall', {1,1,1,1}, {2,1}, "", true)
				label:SetDrawLayer(2)
				if ui_init then InventoryUpdate(nil,BAG_WORN,slot[1]) end
			end
		end
		ZO_PreHookHandler(ZO_PlayerInventory,'OnShow', function()
			for _,slot in pairs(SLOTS) do InventoryUpdate(nil,BAG_WORN,slot[1]) end
			EVENT_MANAGER:RegisterForEvent('BUI_Gear_Event', EVENT_INVENTORY_SINGLE_SLOT_UPDATE, InventoryUpdate)
		end)
		ZO_PreHookHandler(ZO_PlayerInventory,'OnHide', function()
			EVENT_MANAGER:UnregisterForEvent('BUI_Gear_Event', EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
		end)
	else
		for name,value in pairs (disable) do
			local frame=_G[name]
			if value==true then
				frame:SetHidden(false)
			else
				frame:ClearAnchors()
				frame:SetAnchor(unpack(value))
			end
		end
		for _,slot in pairs(SLOTS) do
			local frame=_G["BUI_Inventory"..slot[1].."_Bg"] if frame then frame:SetHidden(true) end
			local frame=_G["BUI_Inventory"..slot[1].."_Bord"] if frame then frame:SetHidden(true) end
			local frame=_G["BUI_Inventory"..slot[1].."_Cond"] if frame then frame:SetHidden(true) end
			local parent=_G['ZO_CharacterEquipmentSlots'..(slot[3] or slot[2])]
			if parent then
				local highlight=parent:GetNamedChild('Highlight') if highlight then
					highlight:SetTexture("EsoUI/Art/Quickslots/quickslot_dragSlot.dds")
					highlight:SetDimensions(90,90)
				end
			end
		end
		ZO_PreHookHandler(ZO_PlayerInventory,'OnShow', function()end)
		ZO_PreHookHandler(ZO_PlayerInventory,'OnHide', function()end)
	end
end

local function MoveGearItems()
	local sourceBag=BANK_MENU_FRAGMENT.state=="shown" and BAG_BANK	--or HOUSE_BANK_MENU_FRAGMENT.state=="shown"
	local destBag=BAG_BACKPACK
	if not sourceBag then return end
	BanditsGearManagerInProgress=true
	local QueueData={}
	local BagCache={[BAG_BACKPACK]=SHARED_INVENTORY.bagCache[BAG_BACKPACK],[BAG_BANK]=SHARED_INVENTORY.bagCache[BAG_BANK]}
	local tempBagCache={[BAG_BACKPACK]={},[BAG_BANK]={}}
	local FirstSlot={[BAG_BACKPACK]=0,[BAG_BANK]=0}
	local BagSize={[BAG_BACKPACK]=GetBagSize(BAG_BACKPACK),[BAG_BANK]=GetBagSize(BAG_BANK)}
	--Find empty slot
	local function FindEmptySlotInBag(bagId)
		for slotIndex=FirstSlot[bagId], BagSize[bagId]-1 do
			if not BagCache[bagId][slotIndex] and not tempBagCache[bagId][slotIndex] then
				tempBagCache[bagId][slotIndex]=true
				FirstSlot[bagId]=slotIndex+1
				return slotIndex
			end
		end
	end
	for slotIndex,data in pairs(BagCache[sourceBag]) do
		if not data.isJunk then
			local have_item
			local uId=Id64ToString(data.uniqueId)
			if uId then
				for g=1,GEARS do
					for i=0,6 do
						for _,data in pairs(SLOTS) do
							local slot=data[1]
							if slot~=100 then
								local uid=SavedData[g+i*100] and SavedData[g+i*100].wear and SavedData[g+i*100].wear[slot] or nil
								if uid==uId then
									have_item=true
									break
								end
							end
						end
						if have_item then break end
					end
					if have_item then break end
				end
				if have_item then
					local itemLink=GetItemLink(sourceBag,slotIndex)
					local stackCount,stackMax=GetSlotStackSize(sourceBag,slotIndex)
					table.insert(QueueData,{slotIndex,stackCount,itemLink})
				end
			end
		end
	end

	--Process prepaired queue
	local countMoved,itemsMoved,itemsMovedTotal=0,0,0
	local function MoveItem(sourceBag,sourceSlot,destBag,destSlot,stackCount)
		if IsProtectedFunction("RequestMoveItem") then
			CallSecureProtected("RequestMoveItem",sourceBag,sourceSlot,destBag,destSlot,stackCount)
		else
			RequestMoveItem(sourceBag,sourceSlot,destBag,destSlot,stackCount)
		end
		itemsMovedTotal=itemsMovedTotal+1
	end
	for _,data in pairs(QueueData) do
		if itemsMovedTotal<80 then
			local FreeSlots=GetNumBagFreeSlots(destBag)
			if FreeSlots>0 then
				local sourceSlot,stackCount,itemLink=unpack(data)
				local destSlot=FindEmptySlotInBag(destBag)	--FindFirstEmptySlotInBag(destBag)
				if destSlot then
					--Move item
					MoveItem(sourceBag,sourceSlot,destBag,destSlot,stackCount)
					countMoved=countMoved+stackCount
					itemsMoved=itemsMoved+1
					if ChatOutput then
						local itemIcon=GetItemLinkInfo(itemLink)
						d(zo_strformat("Withdrawn |t16:16:<<1>>|t<<3>> x <<t:2>>.",itemIcon,stackCount,itemLink))
					end
				end
			end
		end
	end
--[[	--Summary
	if itemsMoved>0 then
		local text=zo_strformat("Withdrawn <<1>> <<1[item/items]>>.",itemsMoved)
		ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, text)
		if ChatOutput then d(text) end
	end
--]]
	BanditsGearManagerInProgress=false
end

local function Bank_Init()
	ZO_CreateStringId("SI_KEYBIND_STRIP_BGM_WITHDRAW",Loc("Withdraw"))
	Button_Withdraw={
		alignment=KEYBIND_STRIP_ALIGN_LEFT,
		{
			name=Loc("Withdraw"),
			keybind="UI_SHORTCUT_TERTIARY",
			enabled=function() return true end,
			visible=function() return true end,
			order=101,
			callback=MoveGearItems,
		},
	}
	local data={BANK_MENU_FRAGMENT}	--,HOUSE_BANK_MENU_FRAGMENT}
	for _,fragment in pairs(data) do
		fragment:RegisterCallback("StateChange", function(oldState, newState)
			if newState==SCENE_SHOWN then
				KEYBIND_STRIP:AddKeybindButtonGroup(Button_Withdraw)
--				ChangeLabel()
			elseif newState==SCENE_HIDDEN then
				KEYBIND_STRIP:RemoveKeybindButtonGroup(Button_Withdraw)
			end
		end)
	end
end

--UI
local function UI_Outfit_Init(gear)
	--GetEquippedOutfitIndex()
	--EquipOutfit(*luaindex* _outfitIndex_)
	local fs,space=18,2
	local s,s1=SLOTSIZE,SLOTSIZE+space

	if BUI_Gear_Outfit then
		if BUI_Gear_Outfit:IsHidden()==false then
			BUI_Gear_Outfit:SetHidden(true)
			return
		else
			BUI_Gear_Outfit:SetHidden(false) FillOutfit(gear) return
		end
	end

	local w,h=10+s*2+space,35+s1*7
	local ui	=BUI.UI.TopLevelWindow("BUI_Gear_Outfit",	BUI_Gear,	{w,h},	{CENTER,CENTER,0,0}, false)
	ui:SetDrawTier(DT_HIGH)
	ui:SetMouseEnabled(true)
	ui:SetMovable(true)
	ui:SetHandler("OnMouseUp", function() ui_hold=true end)
	ui.bg		=BUI.UI.Backdrop(	"BUI_Gear_Outfit_Bg",		ui,		{w,h},		{TOPLEFT,TOPLEFT,0,0},	{0,0,0,1}, BorderColor, nil, false)
	--Top
	ui.top	=BUI.UI.Statusbar("BUI_Gear_Outfit_Top",			ui,		{w,30},	{TOPLEFT,TOPLEFT,0,0},		{.65,.65,.5,.2}, nil, false)
	ui.close	=BUI.UI.Button(	"BUI_Gear_Outfit_Close",		ui.top,	{34,34},	{TOPRIGHT,TOPRIGHT,5,5},	BSTATE_NORMAL, nil, nil, nil, nil, nil, false)
	ui.close:SetNormalTexture('/esoui/art/buttons/closebutton_up.dds')
	ui.close:SetMouseOverTexture('/esoui/art/buttons/closebutton_mouseover.dds')
	ui.close:SetHandler("OnClicked", function() PlaySound("Click") BUI_Gear_Outfit:SetHidden(true) end)
	ui.box	=BUI.UI.Button(	"BUI_Gear_Outfit_Box",			ui.top,	{36,36},	{LEFT,LEFT,0,0},			BSTATE_NORMAL, nil, nil, nil, nil, nil, false)
	ui.box:SetNormalTexture('/esoui/art/dye/dyes_tabicon_outfitstyledye_up.dds')
	ui.box:SetMouseOverTexture('/esoui/art/dye/dyes_tabicon_outfitstyledye_over.dds')
	ui.title	=BUI.UI.Label(	"BUI_Gear_Outfit_Title",		ui.top,	{w,30},	{LEFT,LEFT,40,0},			BUI.UI.Font("esobold",fs,true), {1,1,1,1}, {0,1}, "Outfit", false)
	--Body
	for i=1,14 do
		local icon=outfit_icons[i]
		local slot		=BUI.UI.Backdrop(	"BUI_Gear_Outfit_Slot_Bg"..i,	ui,	{s,s},	{TOPLEFT,TOPLEFT,5+math.floor((i-1)/7)*s1,30+space+(i-1)%7*s1},	{.4,.4,.4,.2}, BorderColor, nil, false)
		slot.edge=BorderColor
		slot.icon		=BUI.UI.Statusbar("BUI_Gear_Outfit_Slot"..i,	slot,	{s-4,s-4},	{CENTER,CENTER,0,0},		{1,1,1,.3},icon, false)
		slot.icon.type=i==1 and "OutfitFill" or i==2 and "OutfitSlot" or "Outfit"
		slot.icon.slot=96+i
		MouseHandlers(slot.icon)
		if i==2 then
			slot.label	=BUI.UI.Label(	"BUI_Gear_Outfit_Label",	slot,	{s,s},	{CENTER,CENTER,0,0},		BUI.UI.Font("esobold",fs+4,true), {1,1,1,1}, {1,1}, "", false)
			slot.label:SetDrawTier(2)
		end
	end

	FillOutfit(gear)
end

local function UI_Button_Init()
	if GlobalData.Button then
		local button=BUI.UI.Button(	"BUI_Gear_Button",	ActionButton7,	{50,50},	{LEFT,RIGHT,0,0},	BSTATE_NORMAL, nil, nil, nil, nil, nil, false)
		button:SetNormalTexture('/esoui/art/treeicons/collection_indexicon_upgrade_up.dds')
		button:SetMouseOverTexture('/esoui/art/treeicons/collection_indexicon_upgrade_over.dds')
		button:SetHandler("OnClicked", BUI_GearShow)
		button.info=BUI.UI.Label(	"BUI_Gear_Button_Info",			button,	{50,50},	{LEFT,LEFT,0,0},	BUI.UI.Font("standard",20,true), nil, {1,1}, GlobalData.CurrentGear or "1")
	elseif BUI_Gear_Button then
		BUI_Gear_Button:SetHidden(true)
	end
end

local function UI_Settings_Init()
	local on,off="/esoui/art/cadwell/checkboxicon_checked.dds","esoui/art/cadwell/checkboxicon_unchecked.dds"
	local function Prepare()
		BUI_Gear_Settings_Height:UpdateValue(GlobalData.Height)
		BUI_Gear_Settings_Slots:UpdateValue(GlobalData.Gears)
		BUI_Gear_Settings_Size:UpdateValue(GlobalData.SlotSize)
		BUI_Gear_Settings_But:SetNormalTexture(GlobalData.Button and on or off)
		BUI_Gear_Settings_Message:SetNormalTexture(GlobalData.Message and on or off)
		BUI_Gear_Settings_Add:SetNormalTexture(GlobalData.AddBar and on or off)
		BUI_Gear_Settings_Inventory:SetNormalTexture(GlobalData.Inventory and on or off)
		BUI_Gear_Settings_Mark:SetNormalTexture(GlobalData.MarkItems and on or off)
		BUI_Gear_Settings_Collect:SetNormalTexture(GlobalData.MarkCollect and on or off)
		BUI_Gear_Settings_Beta:SetNormalTexture(GlobalData.AbilityManager and on or off)
		zo_callLater(function()
			EVENT_MANAGER:RegisterForEvent("BUI_Gear_Settings",EVENT_GLOBAL_MOUSE_UP,function()
			BUI_Gear_Settings:SetHidden(true)
			EVENT_MANAGER:UnregisterForEvent("BUI_Gear_Settings",EVENT_GLOBAL_MOUSE_UP)
			end)
		end,250)
	end

	local function UpdateUI()
		if GlobalData.Height~=BUI_Gear_Settings_Height.value
		or GlobalData.Gears~=BUI_Gear_Settings_Slots.value
		or GlobalData.SlotSize~=BUI_Gear_Settings_Size.value
		then
			GlobalData.Height=BUI_Gear_Settings_Height.value
			GlobalData.Gears=BUI_Gear_Settings_Slots.value GEARS=GlobalData.Gears
			GlobalData.SlotSize=BUI_Gear_Settings_Size.value SLOTSIZE=GlobalData.SlotSize
			RedrawUI()
		end
	end

	if BUI_Gear_Settings then
		if BUI_Gear_Settings:IsHidden()==false then
			BUI_Gear_Settings:SetHidden(true)
			EVENT_MANAGER:UnregisterForEvent("BUI_Gear_Settings",EVENT_GLOBAL_MOUSE_UP)
			return
		else
			BUI_Gear_Settings:SetHidden(false) Prepare() return
		end
	end
	local fs=18
	local space=2
	local w,h=Localization[lang].MenuWidth or 250,13*fs*1.5+20
	local ui	=BUI.UI.TopLevelWindow("BUI_Gear_Settings",	BUI_Gear_Top,	{w,h},	{TOPRIGHT,BOTTOMRIGHT,-16,2}, false)
	ui:SetDrawTier(DT_HIGH)
	ui:SetMouseEnabled(true)
	ui.bg		=BUI.UI.Backdrop(	"BUI_Gear_Settings_Bg",		ui,		{w,h},		{TOPLEFT,TOPLEFT,0,0},	{.2,.2,.2,1}, BorderColor, nil, false)
	--Show button
	ui.but	=BUI.UI.Button(	"BUI_Gear_Settings_But",	ui,		{fs*1.5,fs*1.5},	{TOPLEFT,TOPLEFT,5,10},	BSTATE_NORMAL, nil, nil, nil, nil, nil, false)
	ui.but:SetHandler("OnClicked", function() GlobalData.Button=not GlobalData.Button UI_Button_Init() end)
	ui.but_l	=BUI.UI.Label(	"BUI_Gear_Settings_BLabel",	ui.but,	{w,fs*1.5},		{LEFT,RIGHT,0,0},	BUI.UI.Font("standard",fs,true), {.7,.7,.5,1}, {0,2}, Loc("Button"),	false)
	--Message
	ui.mes	=BUI.UI.Button(	"BUI_Gear_Settings_Message",	ui,	{fs*1.5,fs*1.5},		{TOPLEFT,TOPLEFT,5,10+fs*1.5*1},	BSTATE_NORMAL, nil, nil, nil, nil, nil, false)
	ui.mes:SetHandler("OnClicked", function() GlobalData.Message=not GlobalData.Message end)
	ui.meslabel	=BUI.UI.Label(	"BUI_Gear_Settings_MLabel",	ui.mes,	{w,fs*1.5},		{LEFT,RIGHT,0,0},	BUI.UI.Font("standard",fs,true), {.7,.7,.5,1}, {0,2}, Loc("Message"),	false)
	--Additional bar
	ui.add	=BUI.UI.Button(	"BUI_Gear_Settings_Add",	ui,	{fs*1.5,fs*1.5},		{TOPLEFT,TOPLEFT,5,10+fs*1.5*2},	BSTATE_NORMAL, nil, nil, nil, nil, nil, false)
	ui.add:SetHandler("OnClicked", function() GlobalData.AddBar=not GlobalData.AddBar PANELS=GlobalData.AddBar and 3 or 2 RedrawUI() end)
	ui.add_l	=BUI.UI.Label(	"BUI_Gear_Settings_ALabel",	ui.add,	{w,fs*1.5},		{LEFT,RIGHT,0,0},	BUI.UI.Font("standard",fs,true), {.7,.7,.5,1}, {0,2}, Loc("AddBar"),	false)

	--Player Inventory
	ui.inv	=BUI.UI.Button(	"BUI_Gear_Settings_Inventory",	ui,	{fs*1.5,fs*1.5},	{TOPLEFT,TOPLEFT,5,10+fs*1.5*3},	BSTATE_NORMAL, nil, nil, nil, nil, nil, false)
	ui.inv:SetHandler("OnClicked", function() GlobalData.Inventory=not GlobalData.Inventory InventoryPrepare() end)
	ui.inv_l	=BUI.UI.Label(	"BUI_Gear_Settings_ILabel",	ui.inv,	{w,fs*1.5},		{LEFT,RIGHT,0,0},	BUI.UI.Font("standard",fs,true), {.7,.7,.5,1}, {0,2}, Loc("Inventory"),	false)
	--Mark items
	ui.mark	=BUI.UI.Button(	"BUI_Gear_Settings_Mark",	ui,	{fs*1.5,fs*1.5},		{TOPLEFT,TOPLEFT,5,10+fs*1.5*4},	BSTATE_NORMAL, nil, nil, nil, nil, nil, false)
	ui.mark:SetHandler("OnClicked", function() GlobalData.MarkItems=not GlobalData.MarkItems AddMarkers() end)
	ui.mark_l	=BUI.UI.Label(	"BUI_Gear_Settings_MkLabel",	ui.mark,	{w,fs*1.5},		{LEFT,RIGHT,0,0},	BUI.UI.Font("standard",fs,true), {.7,.7,.5,1}, {0,2}, Loc("MarkItems"),	false)

	ui.collect	=BUI.UI.Button(	"BUI_Gear_Settings_Collect",	ui,	{fs*1.5,fs*1.5},		{TOPLEFT,TOPLEFT,5,10+fs*1.5*5},	BSTATE_NORMAL, nil, nil, nil, nil, nil, false)
	ui.collect:SetHandler("OnClicked", function() GlobalData.MarkCollect=not GlobalData.MarkCollect AddMarkers() end)
	ui.collect_l=BUI.UI.Label(	"BUI_Gear_Settings_CtLabel",	ui.collect,	{w,fs*1.5},		{LEFT,RIGHT,0,0},	BUI.UI.Font("standard",fs,true), {.7,.7,.5,1}, {0,2}, Loc("MarkCollect"),	false)
	--Beta function
	ui.beta	=BUI.UI.Button(	"BUI_Gear_Settings_Beta",	ui,	{fs*1.5,fs*1.5},		{TOPLEFT,TOPLEFT,5,10+fs*1.5*6},	BSTATE_NORMAL)
	ui.beta:SetHandler("OnClicked", function() GlobalData.AbilityManager=not GlobalData.AbilityManager and 3 or nil end)
	ui.beta_l	=BUI.UI.Label(	"BUI_Gear_Settings_BetaLabel",	ui.beta,	{w,fs*1.5},		{LEFT,RIGHT,0,0},	BUI.UI.Font("standard",fs,true), {.7,.7,.5,1}, {0,2}, Loc("AbilityManager"),	false)

	--Window height
	ui.heightlabel	=BUI.UI.Label(	"BUI_Gear_Settings_HLabel",	ui,	{w,fs*1.5},		{TOPLEFT,TOPLEFT,10,10+fs*1.5*7},	BUI.UI.Font("standard",fs,true), {.7,.7,.5,1}, {0,2}, Loc("Height")..(GlobalData.Height or 4),	false)
	ui.height		=BUI.UI.Slider(	"BUI_Gear_Settings_Height",	ui,	{w-10,fs},		{TOPLEFT,TOPLEFT,10,10+fs*1.5*8},	false, function()UpdateUI()end, {2,8,1}, false, function(value)BUI_Gear_Settings_HLabel:SetText(Loc("Height")..value)end)
	--Show slots
	ui.slotslabel	=BUI.UI.Label(	"BUI_Gear_Settings_SLabel",	ui,	{w,fs*1.5},		{TOPLEFT,TOPLEFT,10,10+fs*1.5*9},	BUI.UI.Font("standard",fs,true), {.7,.7,.5,1}, {0,2}, Loc("Gears")..(GlobalData.Gears or 5),	false)
	ui.slots		=BUI.UI.Slider(	"BUI_Gear_Settings_Slots",	ui,	{w-10,fs},		{TOPLEFT,TOPLEFT,10,10+fs*1.5*10},	false, function()UpdateUI()end, {3,20,1}, false, function(value)BUI_Gear_Settings_SLabel:SetText(Loc("Gears")..value)end)
	--Slot size
	ui.sizelabel	=BUI.UI.Label(	"BUI_Gear_Settings_SzLabel",	ui,	{w,fs*1.5},		{TOPLEFT,TOPLEFT,10,10+fs*1.5*11},	BUI.UI.Font("standard",fs,true), {.7,.7,.5,1}, {0,2}, Loc("SlotSize")..(GlobalData.SlotSize or 40),	false)
	ui.size		=BUI.UI.Slider(	"BUI_Gear_Settings_Size",	ui,	{w-10,fs},		{TOPLEFT,TOPLEFT,10,10+fs*1.5*12},	false, function()UpdateUI()end, {26,54,2}, false, function(value)BUI_Gear_Settings_SzLabel:SetText(Loc("SlotSize")..value)end)

	Prepare()
end

local function UI_Init(show)
	local fs,space=18,2
	local s,s1=SLOTSIZE,SLOTSIZE+space
	local sa1=GlobalData.AddBar and (s+space)*2/3 or s+space
	local sa=sa1-space
	local h1,h2=(s+space)*2,		fs*1.5+space
	local w,w1,h=s1*10.6+sa1*6+14*2,	s1*10.6+sa1*6-2,	GlobalData.Height*(h1+h2)+space*2
	local ui	=BUI.UI.TopLevelWindow("BUI_Gear",			GuiRoot,	{w,h+60},		{TOP,TOP,0,ZO_Compass:GetBottom()}, not show)
	ui:SetMouseEnabled(true) ui:SetMovable(true)
	ui:SetHandler("OnMouseUp", function() ui_hold=true end)
	ui.bg		=BUI.UI.Backdrop(	"BUI_Gear_Backdrop",		ui,		{w,h+60},		{CENTER,CENTER,0,0},		{0,0,0,1}, {0,0,0,1})
	--Top
	ui.top	=BUI.UI.Statusbar("BUI_Gear_Top",			ui,		{w,30},		{TOPLEFT,TOPLEFT,0,0},		{.5,.5,.5,.7})
	ui.top:SetGradientColors(0.4,0.4,0.4,0.7,0,0,0,0)
	ui.close	=BUI.UI.Button(	"BUI_Gear_Close",			ui.top,	{34,34},		{TOPRIGHT,TOPRIGHT,5,5},	BSTATE_NORMAL)
	ui.close:SetNormalTexture('/esoui/art/buttons/closebutton_up.dds')
	ui.close:SetMouseOverTexture('/esoui/art/buttons/closebutton_mouseover.dds')
	ui.close:SetHandler("OnClicked", function() PlaySound("Click") BUI_GearShow() end)
	ui.help	=BUI.UI.SimpleButton("BUI_Gear_Help",	ui.top,		{26,26},		{CENTER,RIGHT,-45,0},		"/esoui/art/miscellaneous/help_icon.dds", false, nil, GetString(BUI_GearToolTip))
	ui.settings	=BUI.UI.SimpleButton("BUI_Gear_Settings_Icon",	ui.top,	{22,22},		{CENTER,RIGHT,-75,0},		"/esoui/art/tutorial/gamepad/gp_playermenu_icon_settings.dds", false, function() PlaySound("Click") UI_Settings_Init() end, Loc("Settings"))
	ui.box	=BUI.UI.Button(	"BUI_Gear_Box",			ui.top,	{36,36},		{LEFT,LEFT,0,0},			BSTATE_NORMAL)
	ui.box:SetNormalTexture('/esoui/art/treeicons/collection_indexicon_upgrade_up.dds')
	ui.box:SetMouseOverTexture('/esoui/art/treeicons/collection_indexicon_upgrade_over.dds')
	ui.title	=BUI.UI.Label(	"BUI_Gear_Title",			ui.top,	{w,30},		{LEFT,LEFT,40,0},			BUI.UI.Font("esobold",fs,true), {1,1,1,1}, {0,1}, Loc("GearManager"))
	--Instance
	local function GetArray() local array={} for i=1,INSTANCES do array[i]=SavedData.InstanceNames and SavedData.InstanceNames[i] or Loc("Instance").." "..i end return array end
--	ui.ilabel	=BUI.UI.Label(	"BUI_Gear_iLabel",		ui.top,	{80,30},		{RIGHT,CENTER,-5,0},		BUI.UI.Font("standard",fs,true), {1,1,1,1}, {2,1}, Loc("Instance"))
	ui.ibox	=BUI.UI.ComboBox(	"BUI_Gear_iBox",			ui.top,	{160,28},		{CENTER,CENTER,5,0},		GetArray(), INSTANCE+1, function(i) SetActiveInstance(i) FillAllSlots() end)
	ui.iedit	=BUI.UI.TextBox("BUI_Gear_iEdit", ui.top, {160,26}, {TOPLEFT,TOPLEFT,0,2,ui.ibox}, 16, nil, function(val)
		if val~="" then
			SavedData.InstanceNames[INSTANCE+1]=val
			ui.ibox:UpdateValues(GetArray(),INSTANCE+1)
		end
		ui.ibox:SetHidden(false) ui.iedit:SetHidden(true)
	end, true)
	ui.ibut	=BUI.UI.SimpleButton("BUI_Gear_iBut",		ui.top,	{26,26},		{LEFT,CENTER,85,0},			"/esoui/art/tutorial/tutorial_illo_edit.dds", false,
	function()
		if ui.ibox:IsHidden() then
			ui.ibox:SetHidden(false) ui.iedit:SetHidden(true)
		else
			ui.ibox:SetHidden(true) ui.iedit:SetHidden(false)
			local text=SavedData.InstanceNames and SavedData.InstanceNames[INSTANCE+1] or Loc("Instance").." "..INSTANCE+1
			ui.iedit.eb:SetText(text)
		end
	end, Loc("InstanceName"))
	--Body
	ui.cont	=BUI.UI.Control(	"BUI_Gear_Content",		ui.top,	{w,h},		{TOPLEFT,BOTTOMLEFT,0,0})
--			BUI.UI.Label(	"BUI_Gear_Text",			ui.cont,	{w,h},		{TOPLEFT,TOPLEFT,0,0},		BUI.UI.Font("standard",fs,true), {1,1,1,1}, {1,1}, "|t"..fs..":"..fs..":/esoui/art/journal/journal_quest_repeat.dds|t First time interface prepare", false)
	local scroll=BUI.UI.Scroll(ui.cont)
	--Bottom
	ui.bot	=BUI.UI.Statusbar("BUI_Gear_Bottom",		ui.cont,	{w,30},		{TOPLEFT,BOTTOMLEFT,0,0},	{.65,.65,.5,.2})
	for x=1,5 do
		local abil	=BUI.UI.Backdrop(	"BUI_Gear_Abil_Bg01"..x,	ui.bot,	{26,26},	{TOPLEFT,TOPLEFT,14+(sa-26)/2+s1*10+s*.6+space+sa1*(x-1),2},	{.4,.4,.4,.2}, BorderColor, nil, false)
		abil.edge=BorderColor
		abil.icon	=BUI.UI.Statusbar("BUI_Gear_Abil01"..x,	abil,		{26-4,26-4},	{CENTER,CENTER,0,0},		{1,1,1,1},IconBlank)
		abil.icon.type="Abil" abil.icon.gear=0 abil.icon.pair=1 abil.icon.slot=x
		MouseHandlers(abil.icon)
	end
	ui.info	=BUI.UI.Label(	"BUI_Gear_Info",			ui.bot,	{200,fs*1.5},	{RIGHT,LEFT,15+s1*10+s*.6-space,0},	BUI.UI.Font("standard",fs,true), {.7,.7,.5,1}, {2,1}, Loc("SingleUseSlot"), false)
	--Outfit settings
	local button=BUI.UI.SimpleButton("BUI_Gear_Outfit_Settings", scroll, {s/3,s/3}, {BOTTOMLEFT,BOTTOMLEFT,2,-2}, "/esoui/art/guild/gamepad/gp_guild_menuicon_customization.dds", true,function(self) UI_Outfit_Init(self.gear) if self.parent then ShowTooltip(self.parent) end end)
	button:SetDrawTier(2)
	--Rename control
	ui.edit	=BUI.UI.TextBox("BUI_Gear_Edit", ui, {w1/3-s,fs*1.5}, {TOPLEFT,TOPLEFT,0,0}, 20, nil, function(val)
		if val~="" then
			local gear=BUI_Gear_Edit.gear
			CheckDataStructure(gear+INSTANCE*100)
			SavedData[gear+INSTANCE*100].name=val
			BUI_Gear_Edit.label:SetText(val)
		end
	end, true)
	ui.edit.eb:SetHandler("OnMouseExit", function(self) BUI_Gear_Edit.over=nil OnBoxMouseOver(BUI_Gear_Edit.label,false) end)
	--Content
	for g=1,GEARS do
		local gear	=BUI.UI.Control(	"BUI_Gear_Bg"..g,		scroll,	{w,h1+space},	{TOPLEFT,TOPLEFT,14,space+(h2+s1*2)*(g-1)})
		--Title
		gear.tbg	=BUI.UI.Backdrop(	"BUI_Gear_NameBg"..g,	gear,		{w1,fs*1.5},	{TOPLEFT,TOPLEFT,0,0},		{.4,.4,.4,.5}, BorderColor)
		gear.tbg.type="Gear"
		gear.tbg.gear=g
		gear.tbg:SetDrawTier(DT_HIGH)
		gear.tbg:SetDrawLayer(DL_CONTROLS)
		gear.tbg:SetMouseEnabled(true)
		gear.tbg:SetHandler("OnMouseUp", OnSectionMouseUp)
		gear.tbg:SetHandler("OnMouseEnter", function(self) local r,g,b,a=self:GetCenterColor() self:SetCenterColor(r,g,b,a*2) end)
		gear.tbg:SetHandler("OnMouseExit", function(self) local r,g,b,a=self:GetCenterColor() self:SetCenterColor(r,g,b,a*.5) end)
		gear.but	=BUI.UI.Button(	"BUI_Gear_But"..g,	gear.tbg,	{fs*1.5,fs*1.5},	{LEFT,LEFT,s/2-fs*.75,0},	SavedData.ActiveGear==g and BSTATE_PRESSED or BSTATE_NORMAL)
		gear.but:SetNormalTexture("/esoui/art/cadwell/checkboxicon_unchecked.dds")
		gear.but:SetPressedTexture("/esoui/art/cadwell/checkboxicon_checked.dds")
		gear.but:SetHandler("OnClicked", function(self) PlaySound("Click") SetActiveGear(g) end)
		gear.name	=BUI.UI.Label(	"BUI_Gear_Name"..g,	gear.tbg,	{w1*2/3-s,fs*1.5},	{LEFT,LEFT,s,0},		BUI.UI.Font("esobold",fs-2,true), {.7,.7,.5,1}, {0,1}, Loc("Gear").." "..g, false)
		gear.cname	=BUI.UI.Label(	"BUI_Gear_cName"..g,	gear.tbg,	{w1/3-s,fs*1.5},		{LEFT,LEFT,w1*2/3+s,0},	BUI.UI.Font("esobold",fs-2,true), {.7,.7,.5,1}, {0,1}, Loc("Gear").." "..g, false)
		gear.cname:SetMouseEnabled(true)
		gear.cname:SetHandler("OnMouseEnter", function(self) OnBoxMouseOver(self,true) end)
		--Section
		gear.bg	=BUI.UI.Backdrop(	"BUI_Gear_NumBg"..g,	gear,		{s,s*2+space},	{TOPLEFT,TOPLEFT,0,h2},		{.4,.4,.4,.5}, BorderColor)
		gear.bg.type="Section"
		gear.bg.gear=g
		gear.bg:SetDrawTier(DT_HIGH)
		gear.bg:SetDrawLayer(DL_CONTROLS)
		gear.bg:SetMouseEnabled(true)
		gear.bg:SetHandler("OnMouseUp", OnSectionMouseUp)
		gear.bg:SetHandler("OnMouseEnter", function(self) local r,g,b,a=self:GetCenterColor() self:SetCenterColor(r,g,b,a*2) end)
		gear.bg:SetHandler("OnMouseExit", function(self) local r,g,b,a=self:GetCenterColor() self:SetCenterColor(r,g,b,a*.5) end)
		gear.num	=BUI.UI.Label(	"BUI_Gear_Num"..g,	gear.bg,	{s,s*2},		{CENTER,CENTER,0,0},		BUI.UI.Font("esobold",fs-2,true), {.7,.7,.5,1}, {1,1}, g)
		for y=1,2 do
			--Wear
			for x=1,6 do
				local wear		=BUI.UI.Backdrop(	"BUI_Gear_Wear_Bg"..g..y..x,	gear,	{s,s},	{TOPLEFT,TOPLEFT,s1*x,h2+s1*(y-1)},		{.4,.4,.4,.2}, BorderColor)
				wear.edge=BorderColor
				wear.icon		=BUI.UI.Statusbar("BUI_Gear_Wear"..g..y..x,	wear,	{s-4,s-4},	{CENTER,CENTER,0,0},		{1,1,1,1},IconBlank)
				wear.icon.type="Wear" wear.icon.gear=g wear.icon.slot=SLOTS[(y-1)*6+x][1] wear.icon.y=y wear.icon.x=x
				MouseHandlers(wear.icon)
				if y==2 and x==6 then wear.icon.outfit=true end
			end
			--Weapons
			for x=1,3 do
				local weap	=BUI.UI.Backdrop(	"BUI_Gear_Weap_Bg"..g..y..x,	gear,	{s,s},	{TOPLEFT,TOPLEFT,s1*6+s1*x,h2+s1*(y-1)},		{.4,.4,.4,.2}, BorderColor)
				weap.edge=BorderColor
				weap.icon		=BUI.UI.Statusbar("BUI_Gear_Weap"..g..y..x,	weap,	{s-4,s-4},	{CENTER,CENTER,0,0},		{1,1,1,1},IconBlank)
				weap.icon.type="Weap" weap.icon.gear=g weap.icon.slot=SLOTS[12+(y-1)*3+x][1] weap.icon.y=y weap.icon.x=x
				MouseHandlers(weap.icon)
			end
		end
		for y=1,PANELS do
			--Action bars
			local pair		=BUI.UI.Backdrop(	"BUI_Gear_Panel"..g..y,	gear,	{s*.6,sa},	{TOPLEFT,TOPLEFT,s1*10,h2+sa1*(y-1)},		{.4,.4,.4,.5}, BorderColor)
			pair.type="Pair" pair.gear=g pair.pair=y
			pair:SetMouseEnabled(true)
			pair:SetDrawTier(DT_HIGH)
			pair:SetDrawLayer(DL_CONTROLS)
			pair:SetHandler("OnMouseUp", OnSectionMouseUp)
			pair:SetHandler("OnMouseEnter", function(self) local r,g,b,a=self:GetCenterColor() self:SetCenterColor(r,g,b,a*2) end)
			pair:SetHandler("OnMouseExit", function(self) local r,g,b,a=self:GetCenterColor() self:SetCenterColor(r,g,b,a*.5) end)
			pair.num		=BUI.UI.Label(	"BUI_Gear_Panel_Num"..g..y,	pair,	{s*.6,sa},	{CENTER,CENTER,0,0},		BUI.UI.Font("esobold",fs-2,true), {.7,.7,.5,1}, {1,1}, (y==3 and "AD" or y))
			for x=1,6 do
				local abil	=BUI.UI.Backdrop(	"BUI_Gear_Abil_Bg"..g..y..x,	pair,	{sa,sa},	{TOPLEFT,TOPRIGHT,space+sa1*(x-1),0},	{.4,.4,.4,.2}, BorderColor)
				abil.edge=BorderColor
				abil.icon	=BUI.UI.Statusbar("BUI_Gear_Abil"..g..y..x,	abil,	{sa-4,sa-4},	{CENTER,CENTER,0,0},		{1,1,1,1},IconBlank)
				abil.icon.type="Abil" abil.icon.gear=g abil.icon.pair=y abil.icon.slot=x
				MouseHandlers(abil.icon)
			end
		end
		--Hide excess
		if not GlobalData.AddBar then
			local frame=_G["BUI_Gear_Panel"..g.."3"] if frame then frame:SetHidden(true) end
		end
	end
	--Hide excess
	for g=GEARS+1,20 do
		local frame=_G["BUI_Gear_Bg"..g] if frame then frame:SetHidden(true) end
	end
--	BUI_Gear_Text:SetHidden(true)
--	end
--	zo_callLater(DrawElements,100)
end

function BUI_GearShow(show)
	if BUI_Gear and BUI_Gear:IsHidden()==false then
		ShowTooltip(nil,false)	--Hide tooltip
		BUI_Gear:SetHidden(true)
		if BUI_Gear_Context then BUI_Gear_Context:SetHidden(true) end
		if BUI_Gear_Settings then BUI_Gear_Settings:SetHidden(true) end
		if BUI_Gear_Outfit then BUI_Gear_Outfit:SetHidden(true) end
		EVENT_MANAGER:UnregisterForEvent('BUI_Gear_Event', EVENT_CURSOR_PICKUP)
		EVENT_MANAGER:UnregisterForEvent('BUI_Gear_Event', EVENT_CURSOR_DROPPED)
		EVENT_MANAGER:UnregisterForEvent("BUI_Gear_Event", EVENT_ACTION_LAYER_POPPED)
		EVENT_MANAGER:UnregisterForEvent("BUI_Gear_Event", EVENT_ACTION_LAYER_PUSHED)
		EVENT_MANAGER:UnregisterForEvent("BUI_Gear_Event", EVENT_RETICLE_HIDDEN_UPDATE)
		BUI_Gear:UnregisterForEvent(EVENT_NEW_MOVEMENT_IN_UI_MODE)
		return
	else
		if show==false then return
		elseif not BUI_Gear then
			UI_Init()
		else
			BUI_Gear:SetHidden(false)
		end
	end

	if ZO_SharedRightBackground:IsHidden()==false then
		BUI_Gear:ClearAnchors()
		BUI_Gear:SetAnchor(TOPRIGHT,ZO_SharedRightBackground,TOPLEFT,-5,-80)
	end

--	zo_callLater(function()
		FillAllSlots()
		--Keybindings
		for g=1,GEARS do _G["BUI_Gear_Num"..g]:SetText(GetKeyBind(g) or g) end
--	end,120)
	--Cursor Events
	EVENT_MANAGER:RegisterForEvent('BUI_Gear_Event', EVENT_CURSOR_PICKUP, OnCursorPickup)
	EVENT_MANAGER:RegisterForEvent('BUI_Gear_Event', EVENT_CURSOR_DROPPED, OnCursorDrop)
	if not ui_init then
--		local frames={"ZO_CollectionsBook_TopLevel","ZO_Skills","ZO_MailInbox","ZO_GroupList","ZO_QuestJournal"}
		local frames={"ZO_SharedRightBackground"}
		for _,name in pairs(frames) do
			ZO_PreHookHandler(_G[name],'OnShow', function()
				if BUI_Gear and BUI_Gear:IsHidden()==false then
					BUI_Gear:ClearAnchors()
					BUI_Gear:SetAnchor(TOPRIGHT,_G[name],TOPLEFT,-5,-80)
				end end)
			ZO_PreHookHandler(_G[name],'OnHide', function()
				if BUI_Gear and BUI_Gear:IsHidden()==false then
					BUI_Gear:ClearAnchors()
					BUI_Gear:SetAnchor(TOP,ZO_Compass,BOTTOM,0,0)
				end end)
		end
	end

	--UI Events
	EVENT_MANAGER:RegisterForEvent("BUI_Gear_Event", EVENT_RETICLE_HIDDEN_UPDATE, function(_,visible)
		if not visible then
			zo_callLater(function()
				if ui_hold then ui_hold=false SetGameCameraUIMode(true) return end
				visible=IsGameCameraUIModeActive()
				if not visible then BUI_GearShow(false) end
			end, 50)
		end
	end)

	BUI_Gear:RegisterForEvent(EVENT_NEW_MOVEMENT_IN_UI_MODE,function() if not BUI_Gear:IsHidden() then BUI_GearShow(false) end end)

	if not ui_init then
		SCENE_MANAGER:GetScene("gameMenuInGame"):RegisterCallback("StateChange", function(oldState, newState)
			if newState==SCENE_SHOWING then
				if BUI_Gear and BUI_Gear:IsHidden()==false then
					BUI_GearShow(false)
					SCENE_MANAGER:ShowBaseScene()
				end
			end
		end)
	end

	ui_init=true
	SetGameCameraUIMode(true)
end

--Initialization
local function OnAddOnLoaded(_, addonName)
	if addonName~=AddonName then return end
	EVENT_MANAGER:UnregisterForEvent("BUI_Gear_Event", EVENT_ADD_ON_LOADED)
	SavedData=ZO_SavedVars:New("BUI_CharData", 1, nil, {InstanceNames={}})
	GlobalData=ZO_SavedVars:NewAccountWide("BUI_GlobalData", 1, nil, {Button=true,MarkItems=true,SlotSize=44,Gears=5,Height=4})
	GEARS=GlobalData.Gears
	INSTANCE=tonumber(SavedData.Instance or 0)
	PANELS=GlobalData.AddBar and 3 or 2
	SLOTSIZE=GlobalData.SlotSize

	--Generate strings
	local base=BUI.name=="BanditsUserInterface"
	ZO_CreateStringId("BUI_GearToolTip",
		(base and '|t16:16:/BanditsUserInterface/textures/lmb.dds|t' or "LMB:").." "..Loc("Tooltip_UI1").."\n"
	..	(base and '|t16:16:/BanditsUserInterface/textures/rmb.dds|t' or "RMB:").." "..Loc("Tooltip_UI2").."\n"
	..	Loc("Tooltip_UI3"))
	ZO_CreateStringId("BUI_Gear_OutfitToolTip",
		(base and '|t16:16:/BanditsUserInterface/textures/lmb.dds|t' or "LMB:").." "..Loc("Tooltip_Outfit1").."\n"
	..	(base and '|t16:16:/BanditsUserInterface/textures/rmb.dds|t' or "RMB:").." "..Loc("Tooltip_Outfit2"))
	ZO_CreateStringId('SI_BINDING_NAME_BUI_SHOW_GEAR', Loc("Show").." "..Loc("GearManager"))
	ZO_CreateStringId('SI_BINDING_NAME_BUI_SHOW_GEAR_RADIAL_MENU', Loc("GearManager").." "..Loc("RadialMenu"))
	ZO_CreateStringId('SI_BINDING_NAME_BUI_GEAR_A', Loc("EquipDdPanel"))
	ZO_CreateStringId('SI_BINDING_NAME_BUI_GEAR_0', Loc("ActivateSuS"))
	for i=1, GEARS do ZO_CreateStringId('SI_BINDING_NAME_BUI_GEAR_'..i, Loc("EquipGear").." "..i) end

	--Prepare UI
	UI_Init()
	UI_Button_Init()
	UI_Radial_Init()
	AddMarkers()
	Bank_Init()
	SetActiveInstance(INSTANCE+1)
	if GlobalData.Inventory then zo_callLater(InventoryPrepare,1000) end
	RedrawUI=function()UI_Init(true) FillAllSlots() for g=1,GEARS do _G["BUI_Gear_Num"..g]:SetText(GetKeyBind(g) or g) end end
end

EVENT_MANAGER:RegisterForEvent("BUI_Gear_Event", EVENT_ADD_ON_LOADED, OnAddOnLoaded)