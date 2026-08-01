local BAG_ICON="|t16:16:/esoui/art/tooltips/icon_bag.dds|t "
local group_size,Zone,ZoneCurrent,VerboseList,NotableList,GroupMembers=0,"","",{},{},{}
local TimeZone
local notableIDs	={	--White list of notable items
	[56862]=true,	--Fortified Nirncrux
	[56863]=true,	--Potent Nirncrux
	[68342]=true,	--Hakeijo
	[135154]=true,	--Chrominum Grains
	}
local exceptionIDs={
	[64713]=true,	--Laurel
	[64690]=true,	--Malachite Shard
--	[73754]=true,[71779]=true,	--Leniency ,Pardon edict
	[87703]=true,[139669]=true,	--Warriors Coffer
	[114427]=true,	--Undaunted Plunder
	[139664]=true,[87702]=true,[139668]=true,	--Mages Coffer
	[87705]=true,[87706]=true,	--Serpent Coffer
	[74680]=true,	--Wrothgar Daily Contract Recompence
	[94089]=true,[139670]=true,	--Dro-m'Athra Coffer
	[94121]=true,[94122]=true,	--Gold Coast Contract
	[133559]=true,	--Crow Coffer
	[133225]=true,	--Soot Coffer
	[133560]=true,	--Slag Town Coffer
	[126581]=true,	--Dwarwen Construct Repair Parts
	[126033]=true,	--Justice Explorer
	[126032]=true,	--Justice Bounty
	[126030]=true,	--Huntmaster
	[126031]=true,	--Urshilaku
	[94085]=true,	--Sithis equipment
	[119561]=true,	--Thiefs goods
	[134623]=true,	--Geodge
	[138711]=true,[138712]=true,[141739]=true,[141738]=true,	--Welkynar Coffer
	[141770]=true,	--Plunder Scull
	[139674]=true,	--Saint's Coffer
	[139673]=true,	--Fabricant Coffer
	[151970]=true,	--Time-Worn Hoard
	}
local TankingSets	={	--Unique tanking sets
	"Alkosh",		--Medium Alcosh
	"Magicka Furnace",--Light Magica Furnance
	}
local PvPSets	={	--Lootable PvP sets
	"Viper",
	"Red Mountain",
	"Bone Pirate",
	"Widowmaker",
	"Spinner",
	"Spriggan",
	"Lich",
	"Rattlecage",
	"Dreugh King Slayer",
	}
local IsJewelry={
	[ITEM_TRAIT_TYPE_JEWELRY_ARCANE]=true,
	[ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY]=true,
	[ITEM_TRAIT_TYPE_JEWELRY_HARMONY]=true,
	[ITEM_TRAIT_TYPE_JEWELRY_HEALTHY]=true,
	[ITEM_TRAIT_TYPE_JEWELRY_INFUSED]=true,
	[ITEM_TRAIT_TYPE_JEWELRY_INTRICATE]=true,
	[ITEM_TRAIT_TYPE_JEWELRY_ORNATE]=true,
	[ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE]=true,
	[ITEM_TRAIT_TYPE_JEWELRY_ROBUST]=true,
	[ITEM_TRAIT_TYPE_JEWELRY_SWIFT]=true,
	[ITEM_TRAIT_TYPE_JEWELRY_TRIUNE]=true,
	}
local ItemQuality={
--	[ITEM_QUALITY_TRASH]="Trash",
	[ITEM_QUALITY_NORMAL]="Normal",
	[ITEM_QUALITY_MAGIC]="Green",
	[ITEM_QUALITY_ARCANE]="Blue",
	[ITEM_QUALITY_ARTIFACT]="Purple",
	[ITEM_QUALITY_LEGENDARY]="Gold",
}
local Defaults	={
	--Options
	Debug		=false,
	Enable	=true,
	TimeStamp	=false,
	LogLoot	=true,
	NameFormat	="@Accname",
	ExtraLang	="Disabled",
	ChatTab	="All tabs",
	BagSpace	=true,
	Icons		=true,
	Traits	=true,
	Types		=true,
	--Filters
	ShowAll	=false,
	Collectible	=false,
	Unique	=true,
	Jewelry	=ITEM_QUALITY_ARTIFACT,
	CollectedSets	=true,
	GroupFilter	=true,
	}
local SavedSettings
local lang=GetCVar("language.2")
	--Mark Filters
local WeaponTraits	=true
local LightTraits		=true
local LightTraitsPvP	=false
local MediumTraits	=true
local MediumTraitsPvP	=false
local HeavyTraits		=true
local OneHanded		=true
local TwoHanded		=false
local RestoStaff		=false
GLN	={
	Name		="GroupLootNotifier",
	DisplayName	="|c4B8BFELootNotifier|r",
	version	=2.11,
};

local ExtraLanguages={"Disabled","ru"}
local Localisation={
	en={
	Enable	={name="Enable Loot Notifier",},
	BagSpace	={name="Show bag space icon",},
	LogLoot	={name="Enable loot history",	tooltip="Use slash command: /loot [list/listall/clear] to see and manage list of looted items."},
	NameFormat	={name="Name format",},
	TimeStamp	={name="Time stamp",},
	ExtraLang	={name="Extra language",	tooltip='Language for additianal "Beg item" and "Offer item" messages (right click on item).'},
	ChatTab	={name="Chat tab to post",},
	Icons		={name="Show icons",},
	Traits	={name="Show traits",},
	Types		={name="Show types",		tooltip="Light/Medium/Heavy/Weapon/Jewelry"},
	Filters	={name="Filters"},
	ShowAll	={name="Show all loot",},
	Collectible	={name="Show collectible",},
	Unique	={name="Show unique items",	tooltip="Option to disable Reward Coffers, Collectibles, Reciepts, Maps, Motifs, Malachite Shard, Laurel and other unique items."},
	Jewelry	={name="Jewelry quality",	tooltip="Show jewelry only if quality is equal or higher"},
	CollectedSets={name="Show collected set items",	tooltip="Disable to hide items you already collected"},
	GroupFilter	={name="Enable filters in group",	tooltip="When in group, automatically disable to log all unique items, such style items, maps, reciepts, etc."},

	Offer		={"Offer item"," need somebody?"},
	Beg		={"Beg item"," You looted "," can I get it?"},
	NotCollected=" (not collected)",
	BagSpaceAlert="You are using Info Panel add-on. Enable bag space info there.",
--	Panel		={"Chat: Loot","Group Loot Notifier"}
	},
	ru={
	Enable	={name="Включить Loot Notifier",},
	BagSpace	={name="Показывать место в инвентаре",	tooltip="Адд-он добавляет в панель производительности информацию о свободном месте в инвентаре."},
	LogLoot	={name="Вести историю лута",	tooltip="Доступны слеш команды: /loot [list/listall/clear]."},
	NameFormat	={name="Формат имени",},
	TimeStamp	={name="Метка времени",},
	ExtraLang	={name="Дополнительный язык",	tooltip='При правом щелчке мыши по предмету позволяет "просить" или "предлагать" предмет на английском или дополнительном языке.'},
	ChatTab	={name="Вкладка чата",	tooltip="Выводит сообщения о полученных игроком или группой предметах в выбранную вкладку"},
	Icons		={name="Показывать значки",},
	Traits	={name="Показывать свойства",},
	Types		={name="Показывать типы",		tooltip="Light/Medium/Heavy/Weapon/Jewelry"},
	Filters	={name="Фильтры"},
	ShowAll	={name="Показывать весь лут",},
	Collectible	={name="Показывать коллекционное",},
	Unique	={name="Показывать уникальное",	tooltip="Возможность отключить показ кофферов, рецептов, карт, кусков стилей, малахитов, лавров и прочих уникальных предметов."},
	Jewelry	={name="Качество бижутерии",		tooltip="Показывать бижутерию только равного указанному или выше качества"},
	CollectedSets={name="Показывать собранные части сетов",	tooltip="Выключите чтоб не показывать уже имеющиеся в коллекции части сетов"},
	GroupFilter	={name="Фильтр в группе",	tooltip="Автоматически отключать показ уникальных и коллекционных предметов в группе."},

	Offer		={"Предложить"," нужно кому-нибудь?"},
	Beg		={"Просить"," Тебе упало "," могу забрать?"},
	NotCollected=" (нет в коллекции)",
	BagSpaceAlert="У вас установлен адд-он Info Panel. Используйте информацию об инвентаре в нем.",
--	Panel		={"Чат: Лут","Group Loot Notifier"}
	}
}

local function OnBagSpace()
	local used,available=GetNumBagUsedSlots(1),GetBagUseableSize(1)
	local color=(used>available-5) and "|cCC2222" or "|cFFFFFF"
	GLN_BagSpace:SetText(BAG_ICON..color..used.."|cCCCCAA/"..available.."|r")
end

local function OnZoneChange()
	if not SavedSettings.LogLoot then return end
	local Zone=GetUnitZone('player')
	if (Zone=="") then
		table.insert(VerboseList, "--"..Zone)
		table.insert(NotableList, "--"..Zone)
	end
	Zone=Zone
end

local function OnGroupChanged()
	group_size=GetGroupSize()
	for i=1, group_size do
		GroupMembers[GetUnitName('group'..i)]=GetUnitDisplayName('group'..i)
	end
end

local function OnPlayerActivated()
	OnGroupChanged()
	EVENT_MANAGER:UnregisterForEvent(GLN.Name, EVENT_PLAYER_ACTIVATED)
end

local function PostMsg(msg)
	if SavedSettings.ChatTab=="First tab" then
		CHAT_SYSTEM:AddMessage(msg)
	elseif CHAT_SYSTEM.primaryContainer then
		if SavedSettings.ChatTab=="All tabs" then
			CHAT_SYSTEM.primaryContainer:AddEventMessageToContainer(msg, CHAT_CATEGORY_SYSTEM)
		elseif SavedSettings.ChatTab=="Group channel" then
			if group_size>1 then
				CHAT_SYSTEM.primaryContainer:AddEventMessageToContainer(msg, CHAT_CATEGORY_PARTY)
			else
				CHAT_SYSTEM:AddMessage(msg)
			end
		elseif SavedSettings.ChatTab=="Emote channel" then
			CHAT_SYSTEM.primaryContainer:AddEventMessageToContainer(msg, CHAT_CATEGORY_EMOTE)
		end
	end
end

local function LogItem(itemName, itemType, quantity, receivedBy, itemId)
	local formattedRecipient
	local formattedQuantity	=""
	local formattedTrait	=""
	local formattedType	=""
	local alert			=""
	local ArmorType		=GetItemLinkArmorType(itemName)
	local EquipType		=GetItemLinkEquipType(itemName)
	local trash_jewelry	=false
	local traitType		=GetItemLinkTraitInfo(itemName);
	local traitName		=GetString("SI_ITEMTRAITTYPE", traitType)
	if receivedBy=="" then
		formattedRecipient="You";
	else
		receivedBy=(SavedSettings.NameFormat=="Name") and receivedBy or ((GroupMembers[receivedBy]) and GroupMembers[zo_strformat(SI_UNIT_NAME,receivedBy)] or receivedBy)
		--Create a character link to make it easier to contact the recipient
		formattedRecipient=string.format("|H0:character:%s|h%s|h", receivedBy, receivedBy:gsub("%^%a+$", "", 1));
	end

	if quantity>1 then formattedQuantity=string.format("|cFFFFFFx%d|r", quantity) end

		--Types
	if SavedSettings.Types then
		if ArmorType==ARMORTYPE_LIGHT then
			formattedType="|cFFFFFFLight|r "
		elseif ArmorType==ARMORTYPE_MEDIUM then
			formattedType="|cFFFFFFMedium|r "
		elseif ArmorType==ARMORTYPE_HEAVY then
			formattedType="|cFFFFFFHeavy|r "
		elseif IsJewelry[traitType] then
			formattedType="|cFFFFFFJewelry|r "
		elseif itemType==ITEMTYPE_WEAPON_TRAIT or itemType==ITEMTYPE_WEAPON then
			formattedType="|cFFFFFFWeapon|r "
			if GetItemLinkWeaponType(itemName)==WEAPONTYPE_SHIELD then formattedType="|cFFFFFFShield|r " end
		end
	end

	if traitType~=ITEM_TRAIT_TYPE_NONE and itemType~=ITEMTYPE_ARMOR_TRAIT and itemType~=ITEMTYPE_WEAPON_TRAIT then
		--Mark good trait items
			--Light
		if LightTraits and ArmorType==ARMORTYPE_LIGHT then
			if traitType==ITEM_TRAIT_TYPE_ARMOR_DIVINES then alert="!!!"
			elseif (EquipType==EQUIP_TYPE_CHEST or EquipType==EQUIP_TYPE_LEGS) then
				if traitType==ITEM_TRAIT_TYPE_ARMOR_INFUSED then alert="!!!" end
			end
			--Medium
		elseif MediumTraits and ArmorType==ARMORTYPE_MEDIUM then
			if traitType==ITEM_TRAIT_TYPE_ARMOR_DIVINES then alert="!!!"
--			elseif EquipType==EQUIP_TYPE_CHEST or EquipType==EQUIP_TYPE_LEGS or EquipType==EQUIP_TYPE_HEAD then
--				if traitType==ITEM_TRAIT_TYPE_ARMOR_INFUSED then alert="!!!" end
			end
			--Heavy
		elseif HeavyTraits and ArmorType==ARMORTYPE_HEAVY then
			if EquipType==EQUIP_TYPE_FEET or EquipType==EQUIP_TYPE_HAND or EquipType==EQUIP_TYPE_WAIST or EquipType==EQUIP_TYPE_SHOULDERS then
				if traitType==ITEM_TRAIT_TYPE_ARMOR_STURDY then alert="!!!" end
			elseif EquipType==EQUIP_TYPE_CHEST or EquipType==EQUIP_TYPE_LEGS or EquipType==EQUIP_TYPE_HEAD then
				if traitType==ITEM_TRAIT_TYPE_ARMOR_INFUSED then alert="!!!" end
			end
			--Jewelry
		elseif IsJewelry[traitType] and GetItemLinkQuality(itemName)<SavedSettings.Jewelry then trash_jewelry=true
			--Weapons
		elseif ArmorType==ARMORTYPE_NONE then
			local WeaponType=GetItemLinkWeaponType(itemName)
			if	WeaponTraits and
				(WeaponType~=WEAPONTYPE_HEALING_STAFF and WeaponType~=WEAPONTYPE_SHIELD and WeaponType~=WEAPONTYPE_TWO_HANDED_AXE and WeaponType~=WEAPONTYPE_TWO_HANDED_HAMMER and WeaponType~=WEAPONTYPE_TWO_HANDED_SWORD and
				(traitType==ITEM_TRAIT_TYPE_WEAPON_INFUSED or traitType==ITEM_TRAIT_TYPE_WEAPON_NIRNHONED or traitType==ITEM_TRAIT_TYPE_WEAPON_PRECISE or traitType==ITEM_TRAIT_TYPE_WEAPON_SHARPENED))
				then alert="!!!" end
			--OneHanded
			if OneHanded then
				if (WeaponType==WEAPONTYPE_SHIELD and (traitType==ITEM_TRAIT_TYPE_ARMOR_INFUSED)) then alert="!!!" end
				if (WeaponType==WEAPONTYPE_AXE or WeaponType==WEAPONTYPE_DAGGER or WeaponType==WEAPONTYPE_HAMMER or WeaponType==WEAPONTYPE_SWORD or WeaponType==WEAPONTYPE_FROST_STAFF) and traitType==ITEM_TRAIT_TYPE_WEAPON_INFUSED then alert="!!!" end
			end
			--TwoHanded
			if TwoHanded and (WeaponType==WEAPONTYPE_TWO_HANDED_AXE or WeaponType==WEAPONTYPE_TWO_HANDED_HAMMER or WeaponType==WEAPONTYPE_TWO_HANDED_SWORD) and (traitType==ITEM_TRAIT_TYPE_WEAPON_INFUSED or traitType==ITEM_TRAIT_TYPE_WEAPON_NIRNHONED) then alert="!!!" end
			--Healing Staff
			if RestoStaff and WeaponType==WEAPONTYPE_HEALING_STAFF and (traitType==ITEM_TRAIT_TYPE_WEAPON_POWERED or traitType==ITEM_TRAIT_TYPE_WEAPON_INFUSED) then alert="!!!" end
		end
			--Unique tanking sets
		if HeavyTraits and (EquipType==EQUIP_TYPE_WAIST or EquipType==EQUIP_TYPE_HAND) and traitType==11 then
			local _name=GetItemLinkName(itemName)
			for i in pairs(TankingSets) do
				if string.match(_name,TankingSets[i])~=nil then alert="!!!" break end
			end
		end
			--PvP armor
		if (LightTraitsPvP and ArmorType==ARMORTYPE_LIGHT) or (MediumTraitsPvP and ArmorType==ARMORTYPE_MEDIUM) then
			if EquipType==EQUIP_TYPE_FEET or EquipType==EQUIP_TYPE_HAND or EquipType==EQUIP_TYPE_WAIST then
				if traitType==ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE then alert="!!!" end
			elseif EquipType==EQUIP_TYPE_CHEST or EquipType==EQUIP_TYPE_LEGS then
				if traitType==ITEM_TRAIT_TYPE_ARMOR_INFUSED then alert="!!!" end
			end
		end
			--Collection
		if (itemType==ITEMTYPE_ARMOR or itemType==ITEMTYPE_WEAPON) and GetItemLinkSetInfo(itemName) then
			if IsItemSetCollectionPieceUnlocked then
				if IsItemSetCollectionPieceUnlocked(GetItemLinkItemId(itemName)) then
					if not SavedSettings.CollectedSets then return end
				else
					alert=Localisation[lang].NotCollected
				end
			end
		end

		formattedTrait=(SavedSettings.Traits) and string.format(" |cFFFFFF(%s)|r", traitName) or ""
	end

	itemName=itemName:gsub("^|H0", "|H1", 1)
	itemName=itemName:gsub("|h|h",":by:"..(receivedBy=="" and "You" or receivedBy).."|h|h",1)

		--Item Icon
	local icon=""
	if (SavedSettings.Icons) then
		if itemType==LOOT_TYPE_COLLECTIBLE then
			local collectibleId=GetCollectibleIdFromLink(itemName)
			local _,_,collectibleIcon=GetCollectibleInfo(collectibleId)
			icon=collectibleIcon
		else
			icon=GetItemLinkInfo(itemName)
		end
		icon=(icon and icon~="") and "|t18:18:"..icon.."|t" or " "
	end

	local msg=
		icon..string.format(
		"%s%s%s%s%s → |c%06X%s|r",
		formattedType,
		itemName,
		formattedQuantity,
		formattedTrait,
		alert,
		HashString(formattedRecipient) % 0xAAAAAA + 0x505050,	--Use the hash of the name for the color so that is random, but consistent
		formattedRecipient
		)

	if SavedSettings.LogLoot then
		if ZoneCurrent~=Zone then
			if (string.sub(VerboseList[#VerboseList],1,1)~="[") then VerboseList[#VerboseList]="--"..Zone
			else table.insert(VerboseList, "--"..Zone) end
			if (string.sub(NotableList[#NotableList],1,1)~="[") then NotableList[#NotableList]="--"..Zone
			else table.insert(NotableList, "--"..Zone) end
			ZoneCurrent=Zone
		end
		table.insert(VerboseList, "["..string.sub(GetTimeString(),1,5).."]"..msg)
	end
--	if (SavedSettings.TrashTraits or (SavedSettings.GroupFilter and group_size>1)) and ((not jewelry) and (alert=="" or exceptionIDs[itemId])) then return
	if not SavedSettings.ShowAll and (trash_jewelry or (exceptionIDs[itemId] and ((SavedSettings.GroupFilter and group_size>1) or not SavedSettings.Unique))) then
		return
	else
		local stamp=FormatTimeSeconds(GetTimeStamp()+TimeZone*60*60,TIME_FORMAT_STYLE_CLOCK_TIME,TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR)
		if SavedSettings.LogLoot then table.insert(NotableList, "["..stamp.."]"..msg) end
		if SavedSettings.TimeStamp then stamp="|cBBBBBB"..stamp.."|r " else stamp="" end
		PostMsg(stamp.."Loot:"..msg)
	end
end

local function NotableListPost()
	if SavedSettings.LogLoot then
		if (#NotableList==1) then
			PostMsg(GLN.DisplayName..": Notable items list is empty")
		else
			PostMsg("============"..GLN.DisplayName.."============")
			for i in pairs(NotableList) do PostMsg(NotableList[i]) end
			PostMsg("==================================")
		end
	else
		PostMsg(GLN.DisplayName..": Looted items list is now disabled (enable it in option menu)")
	end
end

local function VerboseListPost()
	if SavedSettings.LogLoot then
		if (#VerboseList==1) then
			PostMsg(GLN.DisplayName..": Looted items list is empty")
		else
			PostMsg("============"..GLN.DisplayName.."============")
			for i in pairs(VerboseList) do PostMsg(VerboseList[i]) end
			PostMsg("==================================")
		end
	else
		PostMsg(GLN.DisplayName..": Looted items list is now disabled (enable it in option menu)")
	end
end

local function ClearList()
	PostMsg(GLN.DisplayName..": GLN.Items list cleared")
	VerboseList,NotableList,Zone={},{},""
	OnZoneChange()
end

local function ChatButtonHandler(button)
	if button==1 then NotableListPost()
	elseif button==2 then VerboseListPost()
	elseif button==3 then ClearList()
	end
end

local function OnLootReceived(eventCode, receivedBy, itemName, quantity, itemSound, lootType, self, isPickpocketLoot, questItemIcon, itemId)
	if SavedSettings.Debug then StartChatInput(tostring(eventCode)..",'"..tostring(receivedBy).."','"..tostring(itemName).."',"..tostring(quantity)..","..tostring(itemSound)..","..tostring(lootType)..","..tostring(self)..","..tostring(isPickpocketLoot)..",'"..tostring(questItemIcon).."',"..tostring(itemId)) end

	if not SavedSettings.Enable then return end
	if IsItemLinkBound(itemName) and not self then return end

	--Notable items are: any set items, any purple+ items, blue+ special items (e.g., treasure maps)
	if lootType~=LOOT_TYPE_ITEM and lootType~=LOOT_TYPE_COLLECTIBLE then return end
	OnBagSpace()
	local itemType, specializedItemType=GetItemLinkItemType(itemName)
	local itemQuality=GetItemLinkQuality(itemName)
	local itemIsSet=GetItemLinkSetInfo(itemName)
	local itemIsConsumable=IsItemLinkConsumable(itemName)
	local noTrait=GetItemLinkTraitInfo(itemName)==ITEM_TRAIT_TYPE_NONE

	--Workaround for a ZOS bug: Daedric Embers are not flagged in-game as key fragments
	if itemId==69059 or itemId==64487 then specializedItemType=SPECIALIZED_ITEMTYPE_TROPHY_KEY_FRAGMENT end

	local itemIsKeyFragment=(itemType==ITEMTYPE_TROPHY and specializedItemType==SPECIALIZED_ITEMTYPE_TROPHY_KEY_FRAGMENT)
	local itemIsSpecial=(itemType==ITEMTYPE_TROPHY and not itemIsKeyFragment) or itemType==ITEMTYPE_COLLECTIBLE or itemIsConsumable
	local UniqueIsOn=SavedSettings.Unique and not (SavedSettings.GroupFilter and group_size>1)

	if SavedSettings.ShowAll
	or itemIsSet
--	or string.match(GetItemLinkName(itemName),"Master")~=nil
	or (itemQuality>=ITEM_QUALITY_ARTIFACT and itemIsConsumable)
	or (SavedSettings.Collectible and lootType==LOOT_TYPE_COLLECTIBLE)
	or	(	(UniqueIsOn
				and (notableIDs[itemId]
				or (itemQuality>=ITEM_QUALITY_ARCANE and itemIsSpecial)
				or (itemQuality>=ITEM_QUALITY_ARTIFACT and noTrait)
				)
			)
			and (not exceptionIDs[itemId])
		)
	then
		LogItem(itemName, itemType, quantity, self and "" or zo_strformat(SI_UNIT_NAME,receivedBy), itemId)
	end
end

local function BagSpace_Init()
	if SavedSettings.BagSpace then
		if InfoPanel then
			SavedSettings.BagSpace=false
			if CHAT_SYSTEM.primaryContainer then CHAT_SYSTEM:Maximize() CHAT_SYSTEM.primaryContainer:FadeIn() end
			d(Localisation[lang].BagSpaceAlert)
			return
		end
		ZO_PerformanceMeters:SetWidth(215)
		ZO_PerformanceMetersBg:SetWidth(345)
		ZO_PerformanceMetersFramerateMeter:ClearAnchors()
		ZO_PerformanceMetersFramerateMeter:SetAnchor(LEFT,ZO_PerformanceMeters,LEFT,10,0)
		ZO_PerformanceMetersLatencyMeter:ClearAnchors()
		ZO_PerformanceMetersLatencyMeter:SetAnchor(LEFT,ZO_PerformanceMetersFramerateMeter,RIGHT,-3,0)
	else
		if InfoPanel then return end
		ZO_PerformanceMeters:SetWidth(173)
		ZO_PerformanceMetersBg:SetWidth(256)
		ZO_PerformanceMetersFramerateMeter:ClearAnchors()
		ZO_PerformanceMetersFramerateMeter:SetAnchor(RIGHT,ZO_PerformanceMeters,CENTER,0,0)
		ZO_PerformanceMetersLatencyMeter:ClearAnchors()
		ZO_PerformanceMetersLatencyMeter:SetAnchor(LEFT,ZO_PerformanceMeters,CENTER,0,0)
	end
	GLN_BagSpace:SetHidden(not SavedSettings.BagSpace)
end

local function UI_Init()
	local ToolTip=	'|t16:16:/GroupLootNotifier/lmb.dds|t'	.."|c4B8BFE".." Post notable items list\n"
				..	'|t16:16:/GroupLootNotifier/rmb.dds|t'	.."|c4B8BFE".." Post all looted items list\n"
				..	'|t16:16:/GroupLootNotifier/mmb.dds|t'	.."|c4B8BFE".." Clear looted items list"
	--ChatButton
	local button=WINDOW_MANAGER:CreateControl("GLN_ToogleButton", ZO_ChatWindow, CT_BUTTON)
	button:SetDimensions(28,28)
	button:ClearAnchors()
	button:SetAnchor(RIGHT,ZO_ChatWindowOptions,RIGHT,-36,0)
	button:SetState(BSTATE_NORMAL)
	button:SetNormalTexture('/esoui/art/tradinghouse/tradinghouse_listings_tabicon_up.dds')
	button:SetMouseOverTexture('/esoui/art/tradinghouse/tradinghouse_listings_tabicon_over.dds')
	button:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOPRIGHT, ToolTip) end)
	button:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip() end)
	button:SetHandler("OnMouseUp", function(self,button) ChatButtonHandler(button) end)
	button:SetFont("/EsoUI/Common/Fonts/univers57.otf|16|soft-shadow-thick")
	button:SetHidden(not (SavedSettings.LogLoot and SavedSettings.Enable))
--[[	--Bag Space
	local label=WINDOW_MANAGER:CreateControl("GLN_BagSpace", ZO_ChatWindow, CT_LABEL)
	label:SetDimensions(65,16)
	label:ClearAnchors()
	label:SetAnchor(RIGHT,GLN_ToogleButton,LEFT,-5,-3)
	label:SetFont("/EsoUI/Common/Fonts/univers57.otf|16|soft-shadow-thick")
	label:SetColor(1,1,1,1)
	label:SetHorizontalAlignment(2)
	label:SetVerticalAlignment(1)
	label:SetText("")
	label:SetHidden(not SavedSettings.BagSpace)
--]]
	--Bag Space
	local label=WINDOW_MANAGER:CreateControl("GLN_BagSpace", ZO_PerformanceMeters, CT_LABEL)
	label:SetDimensions(75,40)
	label:ClearAnchors()
	label:SetAnchor(LEFT,ZO_PerformanceMetersLatencyMeter,RIGHT,-10,0)
	label:SetFont("ZoFontWinT2")
	label:SetColor(1,1,1,1)
	label:SetHorizontalAlignment(0)
	label:SetVerticalAlignment(1)
	label:SetText("")
	label:SetHidden(true)
	if SavedSettings.BagSpace then BagSpace_Init() end
end

local function HandleSlashCommand(command)
	if (command=="all") then
		SavedSettings.ShowAll=not SavedSettings.ShowAll
		if (SavedSettings.ShowAll) then
			PostMsg(GLN.DisplayName..": Show all loot enabled")
		else
			PostMsg(GLN.DisplayName..": Show all loot disabled")
		end
	elseif (command=="on") then
		SavedSettings.LootLog=true
		PostMsg(GLN.DisplayName..": enabled")
	elseif (command=="off") then
		SavedSettings.LootLog=false
		PostMsg(GLN.DisplayName..": disabled")
	elseif (command=="trash") then
		SavedSettings.TrashTraits=not SavedSettings.TrashTraits
		if (SavedSettings.TrashTraits) then
			PostMsg("Logging trash-trait equipment is enabled")
		else
			PostMsg("Logging trash-trait equipment is disabled")
		end
	elseif (command=="list") then NotableListPost()
	elseif (command=="listall") then VerboseListPost()
	elseif (command=="clear") then ClearList()
	else
		PostMsg(GLN.DisplayName.." usage: /loot [option]\r\n(options: on/off/all/trash/list/listall/clear)")
	end
end

local function Events_Init()
	if SavedSettings.Enable then
		EVENT_MANAGER:RegisterForEvent(GLN.Name, EVENT_LOOT_RECEIVED,		OnLootReceived)
		EVENT_MANAGER:RegisterForEvent(GLN.Name, EVENT_GROUP_MEMBER_JOINED,	OnGroupChanged)
		EVENT_MANAGER:RegisterForEvent(GLN.Name, EVENT_PLAYER_ACTIVATED,		OnPlayerActivated)
	else
		EVENT_MANAGER:UnregisterForEvent(GLN.Name, EVENT_LOOT_RECEIVED)
		EVENT_MANAGER:UnregisterForEvent(GLN.Name, EVENT_GROUP_MEMBER_JOINED)
		EVENT_MANAGER:UnregisterForEvent(GLN.Name, EVENT_PLAYER_ACTIVATED)
	end
	if SavedSettings.LogLoot then
		EVENT_MANAGER:RegisterForEvent(GLN.Name, EVENT_PLAYER_ACTIVATED,		OnZoneChange)
	else
		EVENT_MANAGER:UnregisterForEvent(GLN.Name, EVENT_PLAYER_ACTIVATED)
	end
	if SavedSettings.BagSpace then
		EVENT_MANAGER:RegisterForEvent(GLN.Name, EVENT_CLOSE_BANK,			OnBagSpace)
		EVENT_MANAGER:RegisterForEvent(GLN.Name, EVENT_CLOSE_GUILD_BANK,		OnBagSpace)
		EVENT_MANAGER:RegisterForEvent(GLN.Name, EVENT_CLOSE_STORE,			OnBagSpace)
		EVENT_MANAGER:RegisterForEvent(GLN.Name, EVENT_CLOSE_TRADING_HOUSE,	OnBagSpace)
	else
		EVENT_MANAGER:UnregisterForEvent(GLN.Name, EVENT_CLOSE_BANK)
		EVENT_MANAGER:UnregisterForEvent(GLN.Name, EVENT_CLOSE_GUILD_BANK)
		EVENT_MANAGER:UnregisterForEvent(GLN.Name, EVENT_CLOSE_STORE)
		EVENT_MANAGER:UnregisterForEvent(GLN.Name, EVENT_CLOSE_TRADING_HOUSE)
	end
end

local function Menu_Init()
	local BanditsMenu=BUI and BUI.InternalMenu
	if not BanditsMenu and not LibAddonMenu2 then return end
	local MenuOptions={
		{type="checkbox",	param="Enable",		func=function() Events_Init() GLN_ToogleButton:SetHidden(not SavedSettings.Enable) end},
		{type="checkbox",	param="TimeStamp"},
		{type="checkbox",	param="BagSpace",		func=function() Events_Init() BagSpace_Init() end},
		{type="checkbox",	param="LogLoot"},
		{type="dropdown",	param="NameFormat",	choices={"@Accname","Name"}},
		{type="dropdown",	param="ExtraLang",	choices=ExtraLanguages},
		{type="dropdown",	param="ChatTab",		choices={"First tab","Group channel","Emote channel","All tabs"}},
		{type="checkbox",	param="Icons"},
		{type="checkbox",	param="Traits"},
		{type="checkbox",	param="Types"},
		{type="header",	param="Filters"},
		{type="checkbox",	param="ShowAll"},
		{type="checkbox",	param="Collectible"},
		{type="checkbox",	param="Unique"},
		{type="dropdown",	param="Jewelry",		choices=ItemQuality},
		{type="checkbox",	param="CollectedSets"},
		{type="checkbox",	param="GroupFilter"},
		}
	local Panel={
		type="panel",
		name=BanditsMenu and "16. |t32:32:/esoui/art/tutorial/menubar_inventory_up.dds|tChat: Loot" or "Group Loot Notifier",
		displayName="|c4B8BFEGroup Loot Notifier|r",
		author="|c4B8BFEHoft|r",
		version=tostring(GLN.version),
		}
	local Options,i,var={},0,0
	for _,option in pairs(MenuOptions) do
		if not option.condition or SavedSettings[option.condition] then
		--Localisation
		local name=Localisation[lang] and Localisation[lang][option.param].name or Localisation["en"][option.param].name
		local tooltip=Localisation[lang] and Localisation[lang][option.param].tooltip or Localisation["en"][option.param].tooltip
		for _,dup in pairs(option.dup and option.dup or {1}) do
			if not option.dup or (option.dup and (type(option.param)~="table" or (type(option.param)=="table" and option.param[dup]))) then
			i=i+1;Options[i]={}
			Options[i].type			=option.type
			if name then
				Options[i].name		=(option.icon and "|t32:32:"..option.icon.."|t " or "")..
								(option.dup and (type(name)=="table" and dup.." "..name[dup] or dup.." "..name) or name)
			end
			if tooltip then
				Options[i].tooltip	=tooltip
			end
			if option.text then
				Options[i].text		=option.text
			end
			if option.warning then
				Options[i].warning	=option.warning
			end
			if option.type=="slider" then
				Options[i].min		=1
				Options[i].max		=10
				Options[i].step		=1
			end
			if option.choices then
				Options[i].choices	=option.choices
				if option.param=="Jewelry" then Options[i].choicesValues={1,2,3,4,5} end
			end
			if option.func then
				Options[i].func		=option.func
			end
			if option.width then
				Options[i].width		=option.width
			end
			if option.param then
				Options[i].getFunc	=function()
					local var
					if option.dup then
						if type(option.param)=="table" then var=SavedSettings[ option.param[dup] ]
						else var=SavedSettings[option.param][dup] end
					else var=SavedSettings[option.param] end
					return var
					end
				Options[i].setFunc	=function(value,text)
					if option.dup then
						if type(option.param)=="table" then SavedSettings[ option.param[dup] ]=value
						else SavedSettings[option.param][dup]=value end
					else
						if BanditsMenu and option.type=="dropdown" and option.param~="Jewelry" then value=text end
						SavedSettings[option.param]=value
					end
					if option.func then local function func(value) option.func(value) end func(value) end
					end
				if option.dup then
					if type(option.param)=="table" then var=Defaults[ option.param[dup] ]
					else var=Defaults[option.param][dup] end
				else var=Defaults[option.param] end
				Options[i].default	=var
			end
			end
		end
		end
	end

	if BanditsMenu then
		BUI.Menu.RegisterPanel("GLN_Menu",Panel)
		BUI.Menu.RegisterOptions("GLN_Menu", Options)

	else
		LibAddonMenu2:RegisterAddonPanel("GLN_Menu",Panel)
		LibAddonMenu2:RegisterOptionControls("GLN_Menu", Options)
	end
end

local function OnLoad(eventCode, addonName)
	if addonName~=GLN.Name then return end
	EVENT_MANAGER:UnregisterForEvent(GLN.Name, EVENT_ADD_ON_LOADED)
	SLASH_COMMANDS["/loot"]=HandleSlashCommand
	SavedSettings=ZO_SavedVars:NewAccountWide("GLN_Settings", 2, nil, Defaults)
	TimeZone=24-tonumber(string.sub(FormatTimeSeconds(GetTimeStamp()-GetSecondsSinceMidnight(),TIME_FORMAT_STYLE_CLOCK_TIME,TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR),1,2))

	if not Localisation[lang] then lang="en" end

	Events_Init()
	Menu_Init()
	UI_Init()
	OnBagSpace()

	local function IsValidLink(link)
		if type(link)=="string" then
			local linkStyle,data,text=link:match("|H(.-):(.-)|h(.-)|h")
			data={SplitString(":",data)}
			local n=table.maxn(data)
			local pref=data[n-1]
			local looter=data[n]
--			d(tostring(looter).." "..data[1].." ("..table.concat(data,",")..")")
			return (data[1]=="item" and pref=="by") and looter or false
		end
		return false
	end

	local ZO_Func=ZO_LinkHandler_OnLinkMouseUp
	ZO_LinkHandler_OnLinkMouseUp=function(link, button, control)
		ZO_Func(link, button, control)
		local looter=IsValidLink(link)
		if button~=MOUSE_BUTTON_INDEX_RIGHT or not looter then return end
		if looter=="You" then
			local trait=GetItemLinkTraitInfo(link)
			AddMenuItem("Offer item", function() StartChatInput("/p "..link..(trait~=0 and " ("..GetString("SI_ITEMTRAITTYPE",trait)..")" or "").." need somebody?") end)
			if SavedSettings.ExtraLang~="Disabled" then
				local str=Localisation[SavedSettings.ExtraLang].Offer
				AddMenuItem(str[1], function() StartChatInput("/p "..link..(trait~=0 and " ("..GetString("SI_ITEMTRAITTYPE",trait)..")" or "")..str[2]) end)
			end
		else
			AddMenuItem("Beg item", function() StartChatInput("/w "..looter.." You looted "..link.." can I get it?") end)
			if SavedSettings.ExtraLang~="Disabled" then
				local str=Localisation[SavedSettings.ExtraLang].Beg
				AddMenuItem(str[1], function() StartChatInput("/w "..looter..str[2]..link..str[3]) end)
			end
		end
		ShowMenu(control)
	end
end

EVENT_MANAGER:RegisterForEvent(GLN.Name, EVENT_ADD_ON_LOADED, OnLoad)

--[[
/script OnLootReceived(131183,"Dyta^Fx","|H1:item:55992:363:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:500:0|h|h",1,21,1,true,false,"",45098)
,/script for i=55964, 55999 do d("["..i.."] |H1:item:"..i..":363:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:500:0|h|h") end
55934-55939	--Powered 55964-55999
--]]