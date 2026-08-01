-- Main Addon File
-- @author    : Homeo
-- @lastModif : 06/01/2017 

--------------------
---- CODE ADDON ----
--------------------

function ToggleHelmet()
	local before = GetSetting( SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM )
	SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM, 1 - before)
end

function SendGold(gold)
    SCENE_MANAGER:Show('mailSend')
    ZO_MailSendToField:SetText('@Homeopatix')
    if(gold > 0) then
	ZO_MailSendSubjectField:SetText('SwissArmyKnife Donnation')
	QueueMoneyAttachment(gold)
    else
	ZO_MailSendSubjectField:SetText('SwissArmyKnife Comment')
    end
    ZO_MailSendBodyField:TakeFocus()	
  end


function SAK.SaveLoc()
	SAK.settings.OffsetX = SwissArmyKnifeContainer:GetLeft()
	SAK.settings.OffsetY = SwissArmyKnifeContainer:GetTop()
end


function onCombatChange()
	if(IsUnitInCombat("player") == true) then
		if(SAK.settings.DISPLAYINCOMBAT == false) then
			SwissArmyKnifeContainer:SetHidden(true)
		end
	else
		if(SAK.settings.MUST_BE_SHOWN == true) then
			SwissArmyKnifeContainer:SetHidden(false)
		end

		if(SAK.settings.DISPLAY_RECHARGE == true) then
			AutoCharge()
		end
	end
end

function AtConnection(WHAT)
	local gain = GetBankedCurrencyAmount(WHAT) + GetCarriedCurrencyAmount(WHAT)
	return gain
end

function GetShownAttribute()
    local level = GetPlayerChampionPointsEarned()
    if GetUnitVeteranRank("player") ~= nil then
        level = level + 1
    end
    return GetChampionPointAttributeForRank(level)
end

function GetIcon()
    return CHAMPION_ICONS[GetShownAttribute()]
end

function OnLootReceived( eventCode, receivedBy, itemName, quantity, itemSound, lootType, self, isPickpocketLoot, questItemIcon, itemId )

	--if (lootType ~= LOOT_TYPE_ITEM and lootType ~= LOOT_TYPE_COLLECTIBLE) then return end

	local stackCountBackpack, stackCountBank, _ = GetItemLinkStacks(SAK.itemLink)
	local nbCembers = (stackCountBackpack + stackCountBank)
	local nbrKey = (nbCembers / 60)

	SetJunk()
	if(receivedBy == GetRawUnitName("player")) then
		LootDisplayer(itemName, quantity, lootType, itemId)
	end

	if(nbrKey < 100) then
		nbrKey = string.sub(nbrKey, 0, 1)
	else
		nbrKey = string.sub(nbrKey, 0, 2)
	end
	
	if (itemId == 64487) then
		if(SAK.settings.SHOW_KEY_ALL == true) then
			if(nbCembers >= 60) then
				d(string.format("|cB114FF%s|r|cFFFFFFx|r%s = %s |cFFFFFFx|r%s -> %s |cB114FF%s|r |cFFFFFFx|r %s : %s |cB114FF%s|r |cFFFFFFx|r %s",nbCembers,SAK.clefIcon,nbrKey,SAK.clefBis,SAK.bagIcon, stackCountBackpack, SAK.clefIcon, SAK.bankIcon, stackCountBank ,SAK.clefIcon))
			else				
				d(string.format("|cB114FF%s|r|cFFFFFFx|r%s -> %s |cB114FF%s|r|cFFFFFFx|r%s : %s |cB114FF%s|r |cFFFFFFx|r %s",nbCembers,SAK.clefIcon, SAK.bagIcon, stackCountBackpack, SAK.clefIcon, SAK.bankIcon, stackCountBank ,SAK.clefIcon))
			end
		end
	end
end

function LootDisplayer(itemName, quantity, lootType, itemId)

	local itemStyle
	local icon, _, _, _, itemStyle = GetItemLinkInfo(itemName)
	local color = GetItemQualityColor(GetItemLinkQuality(itemName))

	if(lootType == LOOT_TYPE_QUEST_ITEM)then
		for journalIndex, questData in pairs(SHARED_INVENTORY.questCache) do
			for itemIndex, itemData in pairs (questData) do
				if itemData.name == zo_strformat(SI_TOOLTIP_ITEM_NAME, itemLink) then
					icon = itemData.iconFile
					break
				end
			end
		end

		if ( (not icon) or (icon == '') or (icon == [[/esoui/art/icons/icon_missing.dds]])) then
			icon = [[/esoui/art/inventory/inventory_tabicon_quest_down.dds]]
		end

	end
	
	if (GetItemLinkItemType(itemName) == ITEMTYPE_TRASH) then
		if(SAK.settings.DISPLAY_JUNKED == true) then
			d(zo_strformat("|cFFFFFF<<1>>|rx |t100%:100%:<<2>>|t <<3>> --> |cFFFFFF<<4>>|r", quantity, icon, itemName, "Junk"))
		else
			d(zo_strformat("|cFFFFFF<<1>>|rx |t100%:100%:<<2>>|t <<3>>", quantity, icon, itemName))
		end
	else
		if(SAK.settings.DISPLAY_LOOT_CHAT == true) then
			d(zo_strformat("|cFFFFFF<<1>>|rx |t100%:100%:<<2>>|t <<3>>", quantity, icon, itemName))
		end
	end
end



function processInventoryData()
	local stackCountBackpack, stackCountBank, _ = GetItemLinkStacks(SAK.itemLink)

	local nbCembers = (stackCountBackpack + stackCountBank)
    return stackCountBackpack, stackCountBank
end

function processInventoryDataForKey()
	local clefBag, clefBank = processInventoryData()
	local clefRest = 0

	local nbrKey = ((clefBag + clefBank) / 60)
	if(nbrKey < 100) then
		nbrKey = string.sub(nbrKey, 0, 1)
	else
		nbrKey = string.sub(nbrKey, 0, 2)
	end
	
	clefRest = ((clefBag + clefBank) - (nbrKey*60))

    return nbrKey, clefRest
end

function UpdateVars()
	if(SAK.settings.ALL_CHAR == true) then
		SAK.settings = ZO_SavedVars:NewAccountWide("SwissArmyKnife_Save", 1, nil, DefaultSettings())
	else
		SAK.settings = ZO_SavedVars:New("SwissArmyKnife_Save", 1, nil, DefaultSettings())
	end
end

function CheckZone()
	if IsInImperialCity() then
		SAK.settings.DISPLAY_DEADRIC = true
		SAK.settings.DISPLAY_POTION = false
		SAK.settings.DISPLAY_SOULGEM = false
		SAK.settings.DISPLAY_WRIT = false
		SAK.settings.Display_Bandeau = 1
	end
end

function setDisplay()
	if IsInImperialCity() then
		SAK.settings.DISPLAY_DEADRIC = true
		SAK.settings.DISPLAY_POTION = false
		SAK.settings.DISPLAY_SOULGEM = false
		SAK.settings.DISPLAY_WRIT = false
		SAK.settings.Display_Bandeau = 1
	end

	UpdateVars()

	if(SAK.settings.MUST_BE_SHOWN == false) then
		if IsInCyrodiil() then
			if IsInImperialCity() then
				ShowKey()
    			else
        			HideKey()
   			end
			ShowKey()
		end
	else
		ShowKey()
	end   
end

function Hide()
	SwissArmyKnifeContainer:SetHidden(true)
end

function Show()
	SwissArmyKnifeContainer:SetHidden(false)
end


function updateUI()
	local heat = GetInfoBounty()
	local bntyTmp = GetBounty()
	local RestToSold = SAK.settings.TOTALSELL - SAK.settings.SELLUSED

	BountyCheck()
	updateStacksNumber()
	GetMails()
	if(ZO_CraftingUtils_IsCraftingWindowOpen() == false)then
		LookingForGroup()
	end
	if(SAK.settings.bounty > 0)then
		DisplayWantedInWindowHelper(SAK.settings.bounty, SAK.GoldIcon, SAK.timerIcon, SAK.settings.bounty_timer, bntyTmp, SAK.heatIcon, heat, SAK.stolenIcon, SAK.settings.totalNumberStolen, RestToSold, SAK.settings.totalValue, SAK.GoldIcon)
	end
end

function OnLoaded(eventType, addonName)
	if(addonName ~= SAK.name) then return end
		
	EVENT_MANAGER:UnregisterForEvent(SAK.name, EVENT_ADD_ON_LOADED)
	SAK.settings = {}
	UpdateVars()
	SAK.settings.ShowStart = true
	CreateMenu()
	SAK.activated = false
	SAK.settings.CONNECTED_TIME = GetTimeStamp()
	SAK.settings.BASE_HOME = ReturnHomePrincipale()
	EVENT_MANAGER:RegisterForEvent(SAK.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

function SaveMailCash()
	local _,gainMail = GoldPerHour()

	SAK.settings.SAVE_MAIL = gainMail
end

function ReloadMailCash()
	local bank = GetBankedMoney()
	local bag = GetCurrentMoney()
	local goldTotal = bank + bag
	local goldToCheck = goldTotal - SAK.settings.SAVE_MAIL

	if(SAK.settings.GOLD_CONNECTED ~= goldToCheck) then
		SAK.settings.GOLD_CONNECTED = (bank + bag) - SAK.settings.SAVE_MAIL
	end
end

function OnPlayerActivated()
	if SAK.activated then return end
	SAK.activated = true
	
	EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED)
	if(SAK.settings.ShowStart == true) then
		SAK.settings.CONNECTED_TIME = GetTimeStamp()
		UpdateVars()
		Initialize()
		SAK.settings.bounty_timer = 0
		SAK.settings.bounty = 0
		SAK.settings.bounty_display = 0
		SAK.settings.ShowStart = true
		SAK.settings.SAVE_MAIL = 0

		SwissArmyKnifeContainer:ClearAnchors()
		SwissArmyKnifeContainer:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SAK.settings.OffsetX, SAK.settings.OffsetY)

		WritDisplayHide()
		WritDisplayer:ClearAnchors()
		WritDisplayer:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SAK.settings.OffsetWritX, SAK.settings.OffsetWritY)
	end

	setDisplay()
    	updateUI()

	ZO_PlayerInventoryBackpack:RegisterForEvent(EVENT_INVENTORY_SINGLE_SLOT_UPDATE, updateUI)
	ZO_PlayerInventoryBackpack:RegisterForEvent(EVENT_ACTIVE_WEAPON_PAIR_CHANGED, updateUI)
	EVENT_MANAGER:RegisterForEvent(SAK.name, EVENT_MONEY_UPDATE, updateUI)
	EVENT_MANAGER:RegisterForEvent(SAK.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, updateUI)
	EVENT_MANAGER:RegisterForEvent(SAK.name, EVENT_LOOT_RECEIVED, OnLootReceived)

	if(SAK.settings.USE_BANK == true) then
		EVENT_MANAGER:RegisterForEvent(SAK.name, EVENT_OPEN_BANK, DepositSavings)
	end

	EVENT_MANAGER:RegisterForEvent(SAK.name, EVENT_PLAYER_COMBAT_STATE, onCombatChange)
	--testage
	EVENT_MANAGER:RegisterForEvent(SAK.name, EVENT_EXPERIENCE_UPDATE, updateUI)

	-- HIDE ADDON EVENT
	if(SAK.settings.OffsetX ~= 0 or SAK.settings.OffsetY ~= 0) then
		EVENT_MANAGER:RegisterForEvent(SAK.name, EVENT_ACTION_LAYER_PUSHED, Hide)
    		EVENT_MANAGER:RegisterForEvent(SAK.name, EVENT_ACTION_LAYER_POPPED, setDisplay)
	end

	EVENT_MANAGER:RegisterForEvent(SAK.name, EVENT_OPEN_STORE, AutoActions)
	EVENT_MANAGER:RegisterForEvent(SAK.name, EVENT_NEW_MOVEMENT_IN_UI_MODE, updateUI)
	EVENT_MANAGER:RegisterForEvent(SAK.name, EVENT_MAIL_OPEN_MAILBOX, SaveMailCash)
	EVENT_MANAGER:RegisterForEvent(SAK.name, EVENT_MAIL_CLOSE_MAILBOX, ReloadMailCash)

	EVENT_MANAGER:RegisterForEvent(SAK.name, EVENT_ZONE_CHANGED, setDisplay)
	EVENT_MANAGER:RegisterForEvent(SAK.name, EVENT_ZONE_UPDATE, CheckZone)
	
	-- Addon activation
	EVENT_MANAGER:RegisterForEvent(SAK.name, EVENT_JUSTICE_INFAMY_UPDATED, BountyCheck)

	-- New addon
	EVENT_MANAGER:RegisterForEvent(SAK.name, EVENT_CLOSE_BANK, GetWrit)
	EVENT_MANAGER:RegisterForEvent(SAK.name, EVENT_CRAFT_COMPLETED, GetWrit)
	EVENT_MANAGER:RegisterForEvent(SAK.name, EVENT_END_CRAFTING_STATION_INTERACT, WritDisplayHide)
	EVENT_MANAGER:RegisterForEvent(SAK.name, EVENT_EXPERIENCE_GAIN, GetWrit)
	EVENT_MANAGER:RegisterForEvent(SAK.name, EVENT_QUEST_ADDED, GetWrit)
	EVENT_MANAGER:RegisterForEvent(SAK.name, EVENT_QUEST_COMPLETE, GetWrit)
	EVENT_MANAGER:RegisterForEvent(SAK.name, EVENT_SKILL_XP_UPDATE, GetWrit)
	EVENT_MANAGER:RegisterForEvent(SAK.name, EVENT_SMITHING_TRAIT_RESEARCH_STARTED, GetWrit)
	
	--EVENT_MANAGER:RegisterForEvent(SAK.name, EVENT_LOOT_CLOSED, SetJunk)

	-- for the writ displayer
	EVENT_MANAGER:RegisterForEvent(SAK.name, EVENT_CRAFTING_STATION_INTERACT, GetWrit)
  	EVENT_MANAGER:RegisterForEvent(SAK.name, EVENT_QUEST_ADDED, GetWrit)
  	EVENT_MANAGER:RegisterForEvent(SAK.name, EVENT_QUEST_COMPLETE, GetWrit)
  	EVENT_MANAGER:RegisterForEvent(SAK.name, EVENT_QUEST_REMOVED, GetWrit)
  	EVENT_MANAGER:RegisterForEvent(SAK.name, EVENT_QUEST_CONDITION_COUNTER_CHANGED, GetWrit)

	--EVENT_MANAGER:RegisterForEvent(SAK.name, EVENT_ACTIVITY_FINDER_COOLDOWNS_UPDATE, LookingForGroup)
end

EVENT_MANAGER:RegisterForEvent(SAK.name, EVENT_ADD_ON_LOADED, OnLoaded)



 
