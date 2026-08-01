-- Create namespace
DsRGuildLoot = {}
local DsRGuildLoot = DsRGuildLoot  or {}

DsRGuildLoot.name = "DsRGuildLoot"

DsRGuildLoot.MailStacks	= {}
DsRGuildLoot.recentLoot = {}

LootHistoryTable = {}

DsRGuildLoot.LastLockpick = nil

DsRGuildLoot.ChestNames = {
    ["en"] = "Chest",
    ["de"] = "Truhe",
    ["fr"] = "Coffre",
    ["ru"] = "Сундук",
    ["jp"] = "宝箱",
   }
DsRGuildLoot.ChestName = ""

local interactionData = {}

local clientLang = GetCVar("language.2")
DsRGuildLoot.ChestName = DsRGuildLoot.ChestNames[clientLang] or ""

SecurePostHook(FISHING_MANAGER or INTERACTIVE_WHEEL_MANAGER, "StartInteraction", function(...)
		interactionData = {}
		interactionData.action, interactionData.name, interactionData.blockedNode, interactionData.isOwned = GetGameCameraInteractableActionInfo()
	end
)

function DsRGuildLoot.OnGroupChanged()
	DsRGuildLoot.GroupNames = {}
	if IsUnitGrouped("player") then
		if DsRGuildLoot.sV.ChatGroupLoot then
			local groupSize = GetGroupSize()
			for s = 1, groupSize do
				local unitTag = GetGroupUnitTagByIndex(s)
				if (DoesUnitExist(unitTag)) then
					local displayName = zo_strformat(SI_UNIT_NAME, GetUnitDisplayName(unitTag))
					local unitName = zo_strformat(SI_UNIT_NAME, GetUnitName(unitTag))
					DsRGuildLoot.GroupNames[unitName] = displayName
				end
			end
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Output Centerscreen
-------------------------------------------------------------------------------------------------------------------------------------------------
local function announceSCREEN(quantity, itemName, colorItem, lgIconText, craftBagCount, TradingPrice)
	if DsRGuildLoot.sV.ScreenOnOff == true then return end

	local BagPackIcon     = [[esoui/art/inventory/inventory_tabicon_craftbag_up.dds]]
	local BagPackIconText = zo_iconTextFormat(BagPackIcon, 32, 32, "")
	local colorBagPack    = "|c808080"

	local params        = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT)

	local tradeIcon     = [[/DsRGuildHall/misc/tradehammer.dds]]
	local tradeIconText = zo_iconTextFormat(tradeIcon, 20, 20, "")
	local colortrade    = "|cFFAE42"

	local quantityColor = "|cA52A2A"

	BagCount = ZO_CommaDelimitNumber( craftBagCount ):gsub("%,","%.")
	
	params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_BATTLEGROUND_OBJECTIVE)
	if DsRGuildLoot.sV.ScreenTradePrice == true then
		if quantity > 1 then
			params:SetText(lgIconText .. quantityColor .. quantity .. "x " .. colorItem .. itemName .. colorBagPack .. " ( " .. BagCount .. BagPackIconText .. ") " .. colortrade .. tradeIconText ..  TradingPrice .. "g")
		else
			params:SetText(lgIconText .. colorItem .. itemName .. colorBagPack .. " ( " .. BagCount .. BagPackIconText .. ") " .. colortrade .. tradeIconText ..  TradingPrice .. "g")
		end
	else
		if quantity > 1 then
			params:SetText(lgIconText .. quantityColor .. quantity .. "x " .. colorItem .. itemName .. colorBagPack .. " ( " .. BagCount .. BagPackIconText .. ")")
		else
			params:SetText(lgIconText .. colorItem .. itemName .. colorBagPack .. " ( " .. BagCount .. BagPackIconText .. ")")
		end
	end

	CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
end
-------------------------------------------------------------------------------------------------------------------------------------------------
-- Output Chat
-------------------------------------------------------------------------------------------------------------------------------------------------
local function announceCHAT(_, receivedBy, itemLink, quantity, colorItem, lgIconText, totalCount, TradingPrice, self, itemId, itemTrait)
	if DsRGuildLoot.sV.ChatOnOff == true then return end

	local BagPackIcon     = [[esoui/art/inventory/inventory_tabicon_craftbag_up.dds]]
	local BagPackIconText = zo_iconTextFormat(BagPackIcon, 20, 20, "")
	local colorBagPack    = "|c808080"

	local tradeIcon     = [[/DsRGuildHall/misc/tradehammer.dds]]
	local tradeIconText = zo_iconTextFormat(tradeIcon, 20, 20, "")
	local colortrade    = "|cFFAE42"

	local receivedByColor = "|c7393B3"
	local WHITEcolor      = "|cFFFFFF"
	
	local colortrait = "|cf7f1c3"
	
	local traitName = ""

	if itemTrait ~= 0 then
		traitName = " [" .. GetString("SI_ITEMTRAITTYPE", itemTrait) .. "]"
	end

	BagCount = ZO_CommaDelimitNumber( totalCount ):gsub("%,","%.")

	if itemId == 56863 or itemId == 56862 or itemId == 68342 or itemId == 204881 then
		itemLink = LocalizeString("<<1>>", GetItemLinkName(itemLink))
	end

	if self then
		if DsRGuildLoot.sV.ChatTradePrice == true then
			if tonumber(quantity) > 1 then
				if DsRGuildLoot.sV.ChatTrait == true and itemTrait ~= 0 then
					d(lgIconText .. "|cA52A2A" .. quantity .. "x|r " .. colorItem .. itemLink .. colortrait .. traitName .. colorBagPack .. "    (" ..  BagCount .. BagPackIconText .. "/ " .. colortrade .. tradeIconText ..  TradingPrice .. "g" .. colorBagPack .. ")")
				else
					d(lgIconText .. "|cA52A2A" .. quantity .. "x|r " .. colorItem .. itemLink .. colorBagPack .. "    (" ..  BagCount .. BagPackIconText .. "/ " .. colortrade .. tradeIconText ..  TradingPrice .. "g" .. colorBagPack .. ")")
				end
			else
				if DsRGuildLoot.sV.ChatTrait == true  and itemTrait ~= 0 then
					d(lgIconText ..  colorItem .. itemLink .. colortrait .. traitName .. colorBagPack .. "    (" ..  BagCount .. BagPackIconText .. "/ " .. colortrade .. tradeIconText ..  TradingPrice .. "g" .. colorBagPack .. ")")
				else
					d(lgIconText ..  colorItem .. itemLink .. colorBagPack .. "    (" ..  BagCount .. BagPackIconText .. "/ " .. colortrade .. tradeIconText ..  TradingPrice .. "g" .. colorBagPack .. ")")
				end
			end
		else
			if tonumber(quantity) > 1 then
				if DsRGuildLoot.sV.ChatTrait == true and itemTrait ~= 0 then
					d(lgIconText .. "|cA52A2A" .. quantity .. "x|r " .. colorItem .. itemLink .. colortrait .. traitName .. colorBagPack .. "    (" ..  BagCount .. BagPackIconText .. colorBagPack .. ")")
				else
					d(lgIconText .. "|cA52A2A" .. quantity .. "x|r " .. colorItem .. itemLink .. colorBagPack .. "    (" ..  BagCount .. BagPackIconText .. colorBagPack .. ")")
				end
			else
				if DsRGuildLoot.sV.ChatTrait == true and itemTrait ~= 0 then
					d(lgIconText ..  colorItem .. itemLink .. colortrait .. traitName .. colorBagPack .. "    (" ..  BagCount .. BagPackIconText .. colorBagPack .. ")")
				else
					d(lgIconText ..  colorItem .. itemLink .. colorBagPack .. "    (" ..  BagCount .. BagPackIconText .. colorBagPack .. ")")	
				end
			end
		end
	elseif not self and DsRGuildLoot.sV.ChatGroupLoot == true then
		if DsRGuildLoot.GroupNames[zo_strformat(SI_UNIT_NAME, receivedBy)] == nil then return end
		ACCname  = ZO_LinkHandler_CreatePlayerLink(DsRGuildLoot.GroupNames[zo_strformat(SI_UNIT_NAME, receivedBy)])
		if DsRGuildLoot.sV.ChatTradePrice == true then
			if tonumber(quantity) > 1 then
				if DsRGuildLoot.sV.ChatTrait == true and itemTrait ~= 0 then
					d(receivedByColor .. ACCname .. WHITEcolor .. " " .. lgIconText .. "|cA52A2A" .. quantity .. "x|r " .. colorItem .. itemLink .. colortrait .. traitName .. colortrade .. "    (" .. tradeIconText ..  TradingPrice .. "g" .. colorBagPack .. ")")
				else
					d(receivedByColor .. ACCname .. WHITEcolor .. " " .. lgIconText .. "|cA52A2A" .. quantity .. "x|r " .. colorItem .. itemLink .. colortrade .. "   (" .. tradeIconText ..  TradingPrice .. "g" .. colorBagPack .. ")")
				end
			else
				if DsRGuildLoot.sV.ChatTrait == true and itemTrait ~= 0 then
					d(receivedByColor .. ACCname .. WHITEcolor .. " " .. lgIconText .. colorItem .. itemLink .. colortrait .. traitName .. colortrade .. "    (" .. tradeIconText ..  TradingPrice .. "g" .. colorBagPack .. ")")
				else
					d(receivedByColor .. ACCname .. WHITEcolor .. " " .. lgIconText .. colorItem .. itemLink .. colortrade .. "    (" .. tradeIconText ..  TradingPrice .. "g" .. colorBagPack .. ")")
				end
			end
		else
			if tonumber(quantity) > 1 then
				if DsRGuildLoot.sV.ChatTrait == true and itemTrait ~= 0 then
					d(receivedByColor .. ACCname .. WHITEcolor .. " " .. lgIconText .. "|cA52A2A" .. quantity .. "x|r " .. colorItem .. itemLink .. colortrait .. traitName)
				else
					d(receivedByColor .. ACCname .. WHITEcolor .. " " .. lgIconText .. "|cA52A2A" .. quantity .. "x|r " .. colorItem .. itemLink)
				end
			else
				if DsRGuildLoot.sV.ChatTrait == true and itemTrait ~= 0 then
					d(receivedByColor .. ACCname .. WHITEcolor .. " " .. lgIconText ..  colorItem .. itemLink .. colortrait .. traitName)
				else
					d(receivedByColor .. ACCname .. WHITEcolor .. " " .. lgIconText ..  colorItem .. itemLink)
				end
			end
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------
-- Container AutoLoot
-------------------------------------------------------------------------------------------------------------------------------------------------
local containerList = {}

local function ShouldOpenContainer(inSlot) -- returns nil for no or link to item for yes
    if FindFirstEmptySlotInBag(BAG_BACKPACK) == nil then -- Inventory full
        return nil
    end 
    local itemLink = GetItemLink(INVENTORY_BACKPACK, inSlot, LINK_STYLE_BRACKETS)

    if IsItemLinkContainer(itemLink) == false then return nil end -- We only are opening containers

    local itemId = GetItemLinkItemId(itemLink)
    local itemType, specializedItemType = GetItemType(INVENTORY_BACKPACK, inSlot)

    return itemLink -- open all other containers
end

local function GetFirstOpenableContainer()
  for slotIndex, link in pairs(containerList) do
      local newLink = GetItemLink(BAG_BACKPACK, slotIndex)
      if not newLink or #newLink == 0 then containerList[slotIndex] = nil
      elseif IsItemLinkContainer(newLink) == true then return slotIndex, link 
      end
  end
  return nil, nil
end

function DsRGuildLoot.OpenContainer(itemLink, itemId)
	local slotIndex = nil
	for s = 0, GetBagSize(BAG_BACKPACK) do
        containerList[s] = ShouldOpenContainer(s)
    end
	local slotIndex, link = GetFirstOpenableContainer()

    if IsProtectedFunction("UseItem") then 
      CallSecureProtected("UseItem", INVENTORY_BACKPACK, slotIndex)
    else
      UseItem(INVENTORY_BACKPACK, slotIndex) 
    end
    zo_callLater( function() LootAll() end, 100 )
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- On loot
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildLoot.OnLootReceivedContainer(eventId, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange, triggeredByCharacterName, triggeredByDisplayName, isLastUpdateForMessage, bonusDropSource) 
	local itemId     = GetItemId(bagId, slotIndex)
	local itemLink   = GetItemLink(bagId, slotIndex)

	-- PvP ImperialCity
	if itemId == 212238 and DsRGuildLoot.sV.LootContainer_ICversorger then			-- kaiserliche Versorgervorräte
		SCENE_MANAGER:HideCurrentScene()
		zo_callLater( function() DsRGuildLoot.OpenContainer(itemLink) end, 100 )
	elseif itemId == 212249 and DsRGuildLoot.sV.LootContainer_ICschmied then		-- kaiserlicher Schmiedekoffer
		SCENE_MANAGER:HideCurrentScene()
		zo_callLater( function() DsRGuildLoot.OpenContainer(itemLink) end, 100 )
	elseif itemId == 212252 and DsRGuildLoot.sV.LootContainer_ICschneider then		-- kaiserlicher Schneiderkoffer
		SCENE_MANAGER:HideCurrentScene()
		zo_callLater( function() DsRGuildLoot.OpenContainer(itemLink) end, 100 )
	elseif itemId == 212251 and DsRGuildLoot.sV.LootContainer_ICalchemi then		-- kaiserlicher alchemistischer Beutel
		SCENE_MANAGER:HideCurrentScene()
		zo_callLater( function() DsRGuildLoot.OpenContainer(itemLink) end, 100 )
	elseif itemId == 212248 and DsRGuildLoot.sV.LootContainer_ICrunen then			-- kaiserliche Runentruhe
		SCENE_MANAGER:HideCurrentScene()
		zo_callLater( function() DsRGuildLoot.OpenContainer(itemLink) end, 100 )
	elseif itemId == 212247 and DsRGuildLoot.sV.LootContainer_ICholz then			-- kaiserliche Holzkundekiste
		SCENE_MANAGER:HideCurrentScene()
		zo_callLater( function() DsRGuildLoot.OpenContainer(itemLink) end, 100 )
	end
	
	-- Endless archive
	if itemId == 203205 and DsRGuildLoot.sV.LootContainer_EAschmuck then			-- Schmuckhandwerksbeutel des Archivs
		SCENE_MANAGER:HideCurrentScene()
		zo_callLater( function() DsRGuildLoot.OpenContainer(itemLink) end, 100 )
	elseif itemId == 203212 and DsRGuildLoot.sV.LootContainer_EAversorger then		-- Versorgervorräte des Archivs
		SCENE_MANAGER:HideCurrentScene()
		zo_callLater( function() DsRGuildLoot.OpenContainer(itemLink) end, 100 )
	elseif itemId == 203200 and DsRGuildLoot.sV.LootContainer_EAschneider then		-- Schneiderkoffer des Archivs
		SCENE_MANAGER:HideCurrentScene()
		zo_callLater( function() DsRGuildLoot.OpenContainer(itemLink) end, 100 )
	elseif itemId == 203199 and DsRGuildLoot.sV.LootContainer_EAschmied then		-- Schmiedekoffer des Archivs
		SCENE_MANAGER:HideCurrentScene()
		zo_callLater( function() DsRGuildLoot.OpenContainer(itemLink) end, 100 )
	elseif itemId == 203181 and DsRGuildLoot.sV.LootContainer_EAalchemi then		-- alchemistischer Beutel des Archivs
		SCENE_MANAGER:HideCurrentScene()
		zo_callLater( function() DsRGuildLoot.OpenContainer(itemLink) end, 100 )
	elseif itemId == 203201 and DsRGuildLoot.sV.LootContainer_EArunen then			-- Runentruhe des Archivs
		SCENE_MANAGER:HideCurrentScene()
		zo_callLater( function() DsRGuildLoot.OpenContainer(itemLink) end, 100 )
	elseif itemId == 203213 and DsRGuildLoot.sV.LootContainer_EAholz then			-- Holzkunde des Archivs
		SCENE_MANAGER:HideCurrentScene()
		zo_callLater( function() DsRGuildLoot.OpenContainer(itemLink) end, 100 )
	end
end

function DsRGuildLoot.OnLootReceived(_, receivedBy, itemLink, quantity, _, lootType, self, _, questIcon, itemId) 
	local pName = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(itemLink))

	local prices = DsRGuildPrice.GetPrices(itemLink, itemId)
	if prices.bestPrice ~= nil then
		TradingPrice = prices.bestPrice
	elseif prices.originalMMPrice ~= nil then
		TradingPrice = prices.originalMMPrice
	elseif prices.originalTTCPrice ~= nil then
		TradingPrice = prices.originalTTCPrice
	elseif prices.originalATTPrice ~= nil then
		TradingPrice = prices.originalATTPrice
	end

  	if TradingPrice == nil then
		TradingPrice = 0
	end

	local itemName 	       = GetItemLinkName(itemLink)
	local itemIcon 	       = GetItemLinkIcon(itemLink)
	local itemquality      = GetItemLinkQuality(itemLink)
	local itemType		   = GetItemLinkItemType(itemLink)
	local itemqualityColor = GetItemQualityColor(itemquality)
	local _, sellPrice     = GetItemLinkInfo(itemLink)
	local itemTrait        = GetItemLinkTraitType(itemLink)

	-- PvE Open World
	if itemId == 197790 and DsRGuildLoot.sV.LootContainer_FM then 		-- Forschungsmappe
		DsRGuildLoot.OpenContainer(itemLink)
	elseif itemId == 188144 and DsRGuildLoot.sV.LootContainer_BGR then 	-- Bündel eines gefallenen Ritters
		DsRGuildLoot.OpenContainer(itemLink)
	elseif itemId == 178470 and DsRGuildLoot.sV.LootContainer_BVS then	-- Beutel mit einem versteckten Schatz
		DsRGuildLoot.OpenContainer(itemLink)
	elseif itemId == 150700 and DsRGuildLoot.sV.LootContainer_hAR then	-- Halbverdauter Abenteuerrucksack
		DsRGuildLoot.OpenContainer(itemLink)
	end

	if IA_InventoryAssistant.settings.InvOnOff == false then
		ReScanButton:SetNormalTexture("/DsRGuildHall/misc/update_need.dds")
		ReScanButton:SetMouseOverTexture("esoui/art/lfg/lfg_groupfinder_refreshsearch_over.dds")
		ReScanButton:SetHandler("OnMouseEnter", function() IA_InventoryAssistant.ShowToolTip(true) end)
		ReScanButton:SetHandler("OnMouseExit" , function() IA_InventoryAssistant.HideToolTip()     end)
	end

	if tonumber(TradingPrice) == 0 then
		TradingPrice = ZO_CommaDelimitNumber( zo_roundToNearest( sellPrice , 0.1 ) ):gsub("%,","%.")
	end
	
	TradingPrice = DsRGuildPrice_NumberFormat(TradingPrice)

	local bagCount, bankCount, craftBagCount = GetItemLinkStacks(itemLink)
	local totalCount 						 = bagCount + bankCount + craftBagCount
	
	BagCount = ZO_CommaDelimitNumber( totalCount ):gsub("%,","%.")
	table.insert(LootHistoryTable, { iLink = itemLink, iType = itemType, Price = TradingPrice, BCount = BagCount})

	local fN    = LocalizeString("<<1>>", itemName)
	local quali = LocalizeString("<<1>>", itemquality)
	
	local colorItem = zo_strformat("|c<<1>>", itemqualityColor:ToHex())

-- Centerscreen
	if self then
		if DsRGuildLoot.sV.ScreensNirn == true and itemId == 56863 then -- Potent Nirncrux ID: 56863
			local lgIconText = zo_iconTextFormat(itemIcon, 32, 32, " ")
			local colorItem  = "|cFF0000"
			announceSCREEN(quantity, fN, colorItem, lgIconText, totalCount, TradingPrice)
		elseif DsRGuildLoot.sV.ScreenfNirn == true and itemId == 56862 then -- Stable Nirncrux ID: 56862
			local lgIconText = zo_iconTextFormat(itemIcon, 32, 32, " ")
			local colorItem  = "|cFF0000"
			announceSCREEN(quantity, fN, colorItem, lgIconText, totalCount, TradingPrice)
		elseif DsRGuildLoot.sV.ScreenKuta == true and itemId == 45854 then  --  Kuta ID: 45854
			local lgIconText = zo_iconTextFormat(itemIcon, 32, 32, " ")
			announceSCREEN(quantity, fN, colorItem, lgIconText, totalCount, TradingPrice)
		elseif DsRGuildLoot.sV.ScreenHakeijo == true and itemId == 68342 then  --  Hakeijo ID: 68342
			local lgIconText = zo_iconTextFormat(itemIcon, 32, 32, " ")
			local colorItem  = "|cFFD700"
			announceSCREEN(quantity, fN, colorItem, lgIconText, totalCount, TradingPrice)
		elseif DsRGuildLoot.sV.ScreenLuminousInk == true and itemId == 204881 then  --  LuminousInk ID: 204881
			local lgIconText = zo_iconTextFormat(itemIcon, 32, 32, " ")
			local colorItem  = "|c33ABF5"
			announceSCREEN(quantity, fN, colorItem, lgIconText, totalCount, TradingPrice)
		elseif DsRGuildLoot.sV.ScreenRubyblossom == true and itemId == 171328 then  --  Rubyblossom Extract ID: 171328
			local lgIconText = zo_iconTextFormat(itemIcon, 32, 32, " ")
			local colorItem  = "|cFF0000"
			announceSCREEN(quantity, fN, colorItem, lgIconText, totalCount, TradingPrice)
		elseif DsRGuildLoot.sV.ScreenMourningdew == true and itemId == 171433 then  --  Mourning Dew ID: 171433
			local lgIconText = zo_iconTextFormat(itemIcon, 32, 32, " ")
			local colorItem  = "|cFFD700"
			announceSCREEN(quantity, fN, colorItem, lgIconText, totalCount, TradingPrice)
		elseif DsRGuildLoot.sV.ScreenPerfectRoe == true and itemId == 64222 then  --  Perfect Roe ID: 64222
			local lgIconText = zo_iconTextFormat(itemIcon, 32, 32, " ")
			local colorItem  = "|cFFD700"
			announceSCREEN(quantity, fN, colorItem, lgIconText, totalCount, TradingPrice)
		elseif DsRGuildLoot.sV.ScreenAetherialDust == true and itemId == 115026 then  --  Aetherial Dust ID: 115026
			local lgIconText = zo_iconTextFormat(itemIcon, 32, 32, " ")
			local colorItem  = "|cFFD700"
			announceSCREEN(quantity, fN, colorItem, lgIconText, totalCount, TradingPrice)
		elseif DsRGuildLoot.sV.ScreenAethericCipher == true and itemId == 115028 then  --  Aetheric Cipher ID: 115028
			local lgIconText = zo_iconTextFormat(itemIcon, 32, 32, " ")
			local colorItem  = "|cFFD700"
			announceSCREEN(quantity, fN, colorItem, lgIconText, totalCount, TradingPrice)
		elseif quali >= zo_strsub(DsRGuildLoot.sV.ScreenQualiloot , 1 , 1) then  -- Auswahlliste ab welcher QUALI
			local lgIconText = zo_iconTextFormat(itemIcon, 32, 32, " ")
			announceSCREEN(quantity, fN, colorItem, lgIconText, totalCount, TradingPrice)
		end
	end

-- CHAT
	-- Option nur fehlende Stickerbuchsachen zeigen
	if (itemType==ITEMTYPE_ARMOR or itemType==ITEMTYPE_WEAPON) and DsRGuildBind.bind.Chatuncollect then
		if IsItemLinkSetCollectionPiece(itemLink) then
			if (not IsItemSetCollectionPieceUnlocked(GetItemLinkItemId(itemLink))) then
				if self then
					local lgIconText = zo_iconTextFormat(itemIcon, 20, 20, " ")  
					announceCHAT(_, receivedBy, itemLink, quantity, colorItem, lgIconText, totalCount, TradingPrice, self, itemId, itemTrait)
					return
				elseif not self and DsRGuildLoot.sV.ChatGroupLoot == true then
					local lgIconText = zo_iconTextFormat(itemIcon, 20, 20, " ")  
					announceCHAT(_, receivedBy, itemLink, quantity, colorItem, lgIconText, totalCount, TradingPrice, self, itemId, itemTrait)
					return
				end
			else
				return
			end
		else
			return
		end
	end
	
    -- normaler Loot
	if self then
		if DsRGuildLoot.sV.ChatsNirn == true and itemId == 56863 then -- Potent Nirncrux ID: 56863
			local lgIconText = zo_iconTextFormat(itemIcon, 20, 20, " ")
			local colorItem  = "|cFF0000"
			announceCHAT(_, receivedBy, itemLink, quantity, colorItem, lgIconText, totalCount, TradingPrice, self, itemId, itemTrait)
		elseif DsRGuildLoot.sV.ChatfNirn == true and itemId == 56862 then -- Stable Nirncrux ID: 56862
			local lgIconText = zo_iconTextFormat(itemIcon, 20, 20, " ")
			local colorItem  = "|cFF0000"
			announceCHAT(_, receivedBy, itemLink, quantity, colorItem, lgIconText, totalCount, TradingPrice, self, itemId, itemTrait)
		elseif DsRGuildLoot.sV.ChatKuta == true and itemId == 45854 then  --  Kuta ID: 45854
			local lgIconText = zo_iconTextFormat(itemIcon, 20, 20, " ")
			announceCHAT(_, receivedBy, itemLink, quantity, colorItem, lgIconText, totalCount, TradingPrice, self, itemId, itemTrait)
		elseif DsRGuildLoot.sV.ChatHakeijo == true and itemId == 68342 then  --  Hakeijo ID: 68342
			local lgIconText = zo_iconTextFormat(itemIcon, 20, 20, " ")
			local colorItem  = "|cFFD700"
			announceCHAT(_, receivedBy, itemLink, quantity, colorItem, lgIconText, totalCount, TradingPrice, self, itemId, itemTrait)
		elseif DsRGuildLoot.sV.ChatLuminousInk == true and itemId == 204881 then  --  LuminousInk ID: 204881
			local lgIconText = zo_iconTextFormat(itemIcon, 20, 20, " ")
			local colorItem  = "|c33ABF5"
			announceCHAT(_, receivedBy, itemLink, quantity, colorItem, lgIconText, totalCount, TradingPrice, self, itemId, itemTrait)
		elseif DsRGuildLoot.sV.ChatRubyblossom == true and itemId == 171328 then  --  Rubyblossom Extract ID: 171328
			local lgIconText = zo_iconTextFormat(itemIcon, 20, 20, " ")
			local colorItem  = "|cFF0000"
			announceCHAT(_, receivedBy, itemLink, quantity, colorItem, lgIconText, totalCount, TradingPrice, self, itemId, itemTrait)
		elseif DsRGuildLoot.sV.ChatMourningdew == true and itemId == 171433 then  --  Mourning Dew ID: 171433
			local lgIconText = zo_iconTextFormat(itemIcon, 20, 20, " ")
			local colorItem  = "|cFFD700"
			announceCHAT(_, receivedBy, itemLink, quantity, colorItem, lgIconText, totalCount, TradingPrice, self, itemId, itemTrait)
		elseif DsRGuildLoot.sV.ChatPerfectRoe == true and itemId == 64222 then  --  Perfect Roe ID: 64222
			local lgIconText = zo_iconTextFormat(itemIcon, 20, 20, " ")
			local colorItem  = "|cFFD700"
			announceCHAT(_, receivedBy, itemLink, quantity, colorItem, lgIconText, totalCount, TradingPrice, self, itemId, itemTrait)
		elseif DsRGuildLoot.sV.ChatAetherialDust == true and itemId == 115026 then  --  Aetherial Dust ID: 115026
			local lgIconText = zo_iconTextFormat(itemIcon, 20, 20, " ")
			local colorItem  = "|cFFD700"
			announceCHAT(_, receivedBy, itemLink, quantity, colorItem, lgIconText, totalCount, TradingPrice, self, itemId, itemTrait)
		elseif DsRGuildLoot.sV.ChatAethericCipher == true and itemId == 115028 then  --  Aetheric Cipher ID: 115028
			local lgIconText = zo_iconTextFormat(itemIcon, 20, 20, " ")
			local colorItem  = "|cFFD700"
			announceCHAT(_, receivedBy, itemLink, quantity, colorItem, lgIconText, totalCount, TradingPrice, self, itemId, itemTrait)
		elseif quali >= zo_strsub(DsRGuildLoot.sV.ChatQualiloot , 1 , 1) then  -- Auswahlliste ab welcher QUALI
			local lgIconText = zo_iconTextFormat(itemIcon, 20, 20, " ")  
			announceCHAT(_, receivedBy, itemLink, quantity, colorItem, lgIconText, totalCount, TradingPrice, self, itemId, itemTrait)
		end

		if itemquality >= 5 then
			PlaySound(SOUNDS.GIFT_INVENTORY_VIEW_FANFARE_SPARKS)
		end
	elseif not self and DsRGuildLoot.sV.ChatGroupLoot == true then
		if DsRGuildLoot.sV.ChatsNirn == true and itemId == 56863 then -- Potent Nirncrux ID: 56863
			local lgIconText = zo_iconTextFormat(itemIcon, 20, 20, " ")
			local colorItem  = "|cFF0000"
			announceCHAT(_, receivedBy, itemLink, quantity, colorItem, lgIconText, totalCount, TradingPrice, self, itemId, itemTrait)
		elseif DsRGuildLoot.sV.ChatfNirn == true and itemId == 56862 then -- Stable Nirncrux ID: 56862
			local lgIconText = zo_iconTextFormat(itemIcon, 20, 20, " ")
			local colorItem  = "|cFF0000"
			announceCHAT(_, receivedBy, itemLink, quantity, colorItem, lgIconText, totalCount, TradingPrice, self, itemId, itemTrait)
		elseif DsRGuildLoot.sV.ChatKuta == true and itemId == 45854 then  --  Kuta ID: 45854
			local lgIconText = zo_iconTextFormat(itemIcon, 20, 20, " ")
			announceCHAT(_, receivedBy, itemLink, quantity, colorItem, lgIconText, totalCount, TradingPrice, self, itemId, itemTrait)
		elseif DsRGuildLoot.sV.ChatHakeijo == true and itemId == 68342 then  --  Hakeijo ID: 68342
			local lgIconText = zo_iconTextFormat(itemIcon, 20, 20, " ")
			local colorItem  = "|cFFD700"
			announceCHAT(_, receivedBy, itemLink, quantity, colorItem, lgIconText, totalCount, TradingPrice, self, itemId, itemTrait)
		elseif DsRGuildLoot.sV.ChatLuminousInk == true and itemId == 204881 then  --  LuminousInk ID: 204881
			local lgIconText = zo_iconTextFormat(itemIcon, 20, 20, " ")
			local colorItem  = "|c33ABF5"
			announceCHAT(_, receivedBy, itemLink, quantity, colorItem, lgIconText, totalCount, TradingPrice, self, itemId, itemTrait)
		elseif DsRGuildLoot.sV.ChatRubyblossom == true and itemId == 171328 then  --  Rubyblossom Extract ID: 171328
			local lgIconText = zo_iconTextFormat(itemIcon, 20, 20, " ")
			local colorItem  = "|cFF0000"
			announceCHAT(_, receivedBy, itemLink, quantity, colorItem, lgIconText, totalCount, TradingPrice, self, itemId, itemTrait)
		elseif DsRGuildLoot.sV.ChatMourningdew == true and itemId == 171433 then  --  Mourning Dew ID: 171433
			local lgIconText = zo_iconTextFormat(itemIcon, 20, 20, " ")
			local colorItem  = "|cFFD700"
			announceCHAT(_, receivedBy, itemLink, quantity, colorItem, lgIconText, totalCount, TradingPrice, self, itemId, itemTrait)
		elseif DsRGuildLoot.sV.ChatPerfectRoe == true and itemId == 64222 then  --  Perfect Roe ID: 64222
			local lgIconText = zo_iconTextFormat(itemIcon, 20, 20, " ")
			local colorItem  = "|cFFD700"
			announceCHAT(_, receivedBy, itemLink, quantity, colorItem, lgIconText, totalCount, TradingPrice, self, itemId, itemTrait)
		elseif DsRGuildLoot.sV.ChatAetherialDust == true and itemId == 115026 then  --  Aetherial Dust ID: 115026
			local lgIconText = zo_iconTextFormat(itemIcon, 20, 20, " ")
			local colorItem  = "|cFFD700"
			announceCHAT(_, receivedBy, itemLink, quantity, colorItem, lgIconText, totalCount, TradingPrice, self, itemId, itemTrait)
		elseif DsRGuildLoot.sV.ChatAethericCipher == true and itemId == 115028 then  --  Aetheric Cipher ID: 115028
			local lgIconText = zo_iconTextFormat(itemIcon, 20, 20, " ")
			local colorItem  = "|cFFD700"
			announceCHAT(_, receivedBy, itemLink, quantity, colorItem, lgIconText, totalCount, TradingPrice, self, itemId, itemTrait)
		elseif quali >= zo_strsub(DsRGuildLoot.sV.ChatQualiGroupLoot , 1 , 1) then  -- Auswahlliste ab welcher QUALI
			local lgIconText = zo_iconTextFormat(itemIcon, 20, 20, " ")  
			announceCHAT(_, receivedBy, itemLink, quantity, colorItem, lgIconText, totalCount, TradingPrice, self, itemId, itemTrait)
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- MAIL loot
-------------------------------------------------------------------------------------------------------------------------------------------------
-- Wird aufgerufen wenn der Anhang entnommen wird
function DsRGuildLoot.OnMailItemLooted(mailId)
	for mailitemindex, item in pairs(DsRGuildLoot.MailStacks) do
		local itemLink = item.itemLink

		local prices = DsRGuildPrice.GetPrices(itemLink)
		if prices.bestPrice ~= nil then
			TradingPrice = prices.bestPrice
		elseif prices.originalMMPrice ~= nil then
			TradingPrice = prices.originalMMPrice
		elseif prices.originalTTCPrice ~= nil then
			TradingPrice = prices.originalTTCPrice
		elseif prices.originalATTPrice ~= nil then
			TradingPrice = prices.originalATTPrice
		end
	
		if TradingPrice == nil then
			TradingPrice = 0
		end
	  
		TradingPrice        = DsRGuildPrice_NumberFormat(TradingPrice)
	
		local quantity		   = tonumber(item.stack)
		local itemName 	       = GetItemLinkName(itemLink)
		local itemIcon 	       = GetItemLinkIcon(itemLink)
		local itemType		   = GetItemLinkItemType(itemLink)
		local itemquality      = GetItemLinkQuality(itemLink)
		local itemqualityColor = GetItemQualityColor(itemquality)
		local itemId		   = GetItemLinkItemId(itemLink)
		local itemTrait        = GetItemLinkTraitType(itemLink)
	
		local bagCount, bankCount, craftBagCount = GetItemLinkStacks(itemLink)
		local totalCount 						 = bagCount + bankCount + craftBagCount

		BagCount = ZO_CommaDelimitNumber( totalCount ):gsub("%,","%.")
		table.insert(LootHistoryTable, { iLink = itemLink, iType = itemType, Price = TradingPrice, BCount = BagCount})
			
		local fN    = LocalizeString("<<1>>", itemName)
		local quali = LocalizeString("<<1>>", itemquality)
		
		local colorItem  = zo_strformat("|c<<1>>", itemqualityColor:ToHex())
		local lgIconText = zo_iconTextFormat(itemIcon, 20, 20, " ")
		local receivedBy = ""
		local self 		 = true
	
	-- CENTERSCREEN
		if DsRGuildLoot.sV.ScreensNirn == true and itemId == 56863 then -- Potent Nirncrux ID: 56863
			local lgIconText = zo_iconTextFormat(itemIcon, 32, 32, " ")
			local colorItem  = "|cFF0000"
			announceSCREEN(quantity, fN, colorItem, lgIconText, totalCount, TradingPrice)
		elseif DsRGuildLoot.sV.ScreenfNirn == true and itemId == 56862 then -- Stable Nirncrux ID: 56862
			local lgIconText = zo_iconTextFormat(itemIcon, 32, 32, " ")
			local colorItem  = "|cFF0000"
			announceSCREEN(quantity, fN, colorItem, lgIconText, totalCount, TradingPrice)
		elseif DsRGuildLoot.sV.ScreenKuta == true and itemId == 45854 then  --  Kuta ID: 45854
			local lgIconText = zo_iconTextFormat(itemIcon, 32, 32, " ")
			announceSCREEN(quantity, fN, colorItem, lgIconText, totalCount, TradingPrice)
		elseif DsRGuildLoot.sV.ScreenHakeijo == true and itemId == 68342 then  --  Hakeijo ID: 68342
			local lgIconText = zo_iconTextFormat(itemIcon, 32, 32, " ")
			local colorItem  = "|cFFD700"
			announceSCREEN(quantity, fN, colorItem, lgIconText, totalCount, TradingPrice)
		elseif DsRGuildLoot.sV.ScreenLuminousInk == true and itemId == 204881 then  --  LuminousInk ID: 204881
			local lgIconText = zo_iconTextFormat(itemIcon, 20, 20, " ")
			local colorItem  = "|c33ABF5"
			announceSCREEN(quantity, fN, colorItem, lgIconText, totalCount, TradingPrice)
		elseif quali >= zo_strsub(DsRGuildLoot.sV.ScreenQualiloot , 1 , 1) then  -- Auswahlliste ab welcher QUALI
			local lgIconText = zo_iconTextFormat(itemIcon, 32, 32, " ")
			announceSCREEN(quantity, fN, colorItem, lgIconText, totalCount, TradingPrice)
		end
	-- CHAT
		if DsRGuildLoot.sV.ChatsNirn == true and itemId == 56863 then -- Potent Nirncrux ID: 56863
			local lgIconText = zo_iconTextFormat(itemIcon, 20, 20, " ")
			local colorItem  = "|cFF0000"
			announceCHAT(_, receivedBy, itemLink, quantity, colorItem, lgIconText, totalCount, TradingPrice, self, itemId, itemTrait)
		elseif DsRGuildLoot.sV.ChatfNirn == true and itemId == 56862 then -- Stable Nirncrux ID: 56862
			local lgIconText = zo_iconTextFormat(itemIcon, 20, 20, " ")
			local colorItem  = "|cFF0000"
			announceCHAT(_, receivedBy, itemLink, quantity, colorItem, lgIconText, totalCount, TradingPrice, self, itemId, itemTrait)
		elseif DsRGuildLoot.sV.ChatKuta == true and itemId == 45854 then  --  Kuta ID: 45854
			local lgIconText = zo_iconTextFormat(itemIcon, 20, 20, " ")
			announceCHAT(_, receivedBy, itemLink, quantity, colorItem, lgIconText, totalCount, TradingPrice, self, itemId, itemTrait)
		elseif DsRGuildLoot.sV.ChatHakeijo == true and itemId == 68342 then  --  Hakeijo ID: 68342
			local lgIconText = zo_iconTextFormat(itemIcon, 20, 20, " ")
			local colorItem  = "|cFFD700"
			announceCHAT(_, receivedBy, itemLink, quantity, colorItem, lgIconText, totalCount, TradingPrice, self, itemId, itemTrait)
		elseif DsRGuildLoot.sV.ChatLuminousInk == true and itemId == 204881 then  --  LuminousInk ID: 204881
			local lgIconText = zo_iconTextFormat(itemIcon, 20, 20, " ")
			local colorItem  = "|c33ABF5"
			announceCHAT(_, receivedBy, itemLink, quantity, colorItem, lgIconText, totalCount, TradingPrice, self, itemId, itemTrait)
		elseif quali >= zo_strsub(DsRGuildLoot.sV.ChatQualiloot , 1 , 1) then  -- Auswahlliste ab welcher QUALI
			local lgIconText = zo_iconTextFormat(itemIcon, 20, 20, " ")  
			announceCHAT(_, receivedBy, itemLink, quantity, colorItem, lgIconText, totalCount, TradingPrice, self, itemId, itemTrait)
		end

		if itemquality >= 5 then
			PlaySound(SOUNDS.GIFT_INVENTORY_VIEW_FANFARE_SPARKS)
		end
	end

	DsRGuildLoot.MailStacks = {}
	DsRGuildLoot.recentLoot = {}
end
-------------------------------------------------------------------------------
-- Wenn eine Nachricht gelesen wird
function DsRGuildLoot.OnMailReadable(mailId)
	local numAttachments = GetMailAttachmentInfo(mailId)

	DsRGuildLoot.MailStacks = {}

	for attachIndex = 1, numAttachments do
		DsRGuildLoot.MailStacks[attachIndex] = {}
		local icon, stack, _, _, _, _, itemStyle, quality = GetAttachedItemInfo( mailId, attachIndex)
		local mailitemlink                                = GetAttachedItemLink( mailId, attachIndex, LINK_STYLE_DEFAULT)
		local mailitemName                                = GetItemLinkName(mailitemlink)
		DsRGuildLoot.MailStacks[attachIndex].icon         = icon
		DsRGuildLoot.MailStacks[attachIndex].stack        = stack
		DsRGuildLoot.MailStacks[attachIndex].itemLink     = mailitemlink
		DsRGuildLoot.MailStacks[attachIndex].itemName     = zo_strformat(SI_TOOLTIP_ITEM_NAME, mailitemName)
		DsRGuildLoot.MailStacks[attachIndex].tType        = GetItemLinkItemType(mailitemlink)
		DsRGuildLoot.MailStacks[attachIndex].quality      = quality
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- XP update
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildLoot.OnXPUpdated( _, level, previousExperience, currentExperience, championPoints )
	if not DsRGuildLoot.sV.ChatXP then return end
	
	local gain = currentExperience - previousExperience
	if (gain <= 0) then return end
	if tonumber(gain) < tonumber(DsRGuildLoot.sV.ChatXPtxt) then return end

	local maxLevel = GetMaxLevel()
	local realLevel = "Rang "..tostring(level)

	if level == 50 then realLevel = zo_iconTextFormatNoSpace("esoui/art/champion/champion_icon_32.dds",18,18,"")..championPoints end	
	
	local xpForLevelUp
	
	if level < maxLevel then
		xpForLevelUp  = GetNumExperiencePointsInLevel(level)
	else
		local cPoints = GetNumChampionXPInChampionPoint(championPoints)
		xpForLevelUp  = (cPoints ~= nil) and cPoints or 0
	end
	
	local levelProgress   = tostring(math.floor(100*(currentExperience/xpForLevelUp))).."%"
	local lgIconText      = zo_iconTextFormat("/DsRGuildHall/misc/DsR_XP.dds", 20, 20, " ")

	local WHITEcolor      = "|cFFFFFF"
	local GREYcolor	      = "|c808080"
	local YELLOWcolor	  = "|cFFFF00"

	d(lgIconText .. WHITEcolor .. "+" .. ZO_CommaDelimitNumber( gain ):gsub("%,","%.") .. YELLOWcolor .. GetString(DsRGuildLoot_experience) .. WHITEcolor .. realLevel .. GREYcolor .. "  ->  " .. ZO_CommaDelimitNumber( currentExperience ):gsub("%,","%.") .. "/" .. ZO_CommaDelimitNumber( xpForLevelUp ):gsub("%,","%.") .. " ( " .. levelProgress .. " )")
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Money loot
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildLoot.OnMoneyUpdated( newMoney, oldMoney, reason )
	if reason == CURRENCY_CHANGE_REASON_PLAYER_INIT then return end
	if not DsRGuildLoot.sV.ChatGold then return end
	
	local gain = newMoney - oldMoney
	if (gain == 0) then return end
	if tonumber(gain) < tonumber(DsRGuildLoot.sV.ChatGoldtxt) then return end

	local WHITEcolor      = "|cFFFFFF"
	local GREYcolor	      = "|c808080"
	local REDcolor	      = "|cFF0000"
	local YELLOWcolor	  = "|cFFFF00"

	if not IsBankOpen() then
		if gain < 0 then
			d(REDcolor .. ZO_CommaDelimitNumber( gain ):gsub("%,","%.") .. " " .. YELLOWcolor .. DsR.Localization[DsR.language].DsRGuildLoot_gold_gain .. GREYcolor .. " ( " .. ZO_CommaDelimitNumber( newMoney ):gsub("%,","%.") .. " )")
		else
			d(WHITEcolor .. "+" .. ZO_CommaDelimitNumber( gain ):gsub("%,","%.") .. " " .. YELLOWcolor .. DsR.Localization[DsR.language].DsRGuildLoot_gold_gain .. GREYcolor .. " ( " .. ZO_CommaDelimitNumber( newMoney ):gsub("%,","%.") .. " )")
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Loot Undaunted, Transmute, etickets, endeavor, endless
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildLoot.AccountCurrencies()
	local undaunted          = DsRGuildLoot.sV.ChatUnerschrocken
	local transmute          = DsRGuildLoot.sV.ChatTransmut
	-- local eticket            = DsRGuildLoot.sV.Chatetickets
	local endeavor           = DsRGuildLoot.sV.ChatBestrebung
	local endless            = DsRGuildLoot.sV.ChatEndless
	local ImperialFragements = DsRGuildLoot.sV.ChatIMPfragments
	local TomeChallenge 	 = DsRGuildLoot.sV.ChatTomeChallenge
	local TomePoints 		 = DsRGuildLoot.sV.ChatTomePoints
	local TomePointCach 	 = DsRGuildLoot.sV.ChatTomePointCach
	local TomeToken 		 = DsRGuildLoot.sV.ChatTomeToken
	local TradeBars 		 = DsRGuildLoot.sV.ChatTradeBars

	-- if ( undaunted ) or ( transmute ) or ( endeavor ) or ( eticket ) or ( endless ) or ( ImperialFragements ) or ( TomeChallenge ) or ( TomePoints ) or ( TomePointCach ) or ( TomeToken ) or ( TradeBars ) then
	if ( undaunted ) or ( transmute ) or ( endeavor ) or ( endless ) or ( ImperialFragements ) or ( TomeChallenge ) or ( TomePoints ) or ( TomePointCach ) or ( TomeToken ) or ( TradeBars ) then
		EVENT_MANAGER:RegisterForEvent(DsRGuildLoot.name, EVENT_CURRENCY_UPDATE, function( _, ... ) DsRGuildLoot.OnCurrencyUpdate( ... ) end )
	else
		EVENT_MANAGER:UnregisterForEvent( EVENT_CURRENCY_UPDATE )
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildLoot.OnCurrencyUpdate(currencyType, currencyLocation, newAmount, oldAmount, reason)
	if reason == CURRENCY_CHANGE_REASON_PLAYER_INIT then return end

	if currencyType == CURT_UNDAUNTED_KEYS and DsRGuildLoot.sV.ChatUnerschrocken == true then
		DsRGuildLoot.OnUndauntedUpdate( newAmount, oldAmount )
	elseif currencyType == CURT_CHAOTIC_CREATIA and DsRGuildLoot.sV.ChatTransmut == true then
		DsRGuildLoot.OnTransmuteUpdate( newAmount, oldAmount )
	-- elseif currencyType == CURT_EVENT_TICKETS and DsRGuildLoot.sV.Chatetickets == true then
		-- DsRGuildLoot.OnETicketUpdate( newAmount, oldAmount )
	elseif currencyType == CURT_SEALS and ( DsRGuildLoot.sV.ChatBestrebung == true or DsRGuildLoot.sV.ScreenBestrebung == true ) then
		DsRGuildLoot.OnEndeavorUpdate( newAmount, oldAmount )
	elseif currencyType == CURT_ENDLESS_DUNGEON and DsRGuildLoot.sV.ChatEndless == true then
		DsRGuildLoot.OnEndlessUpdate( newAmount, oldAmount )
	elseif currencyType == CURT_IMPERIAL_FRAGMENTS and DsRGuildLoot.sV.ChatIMPfragments == true then
		DsRGuildLoot.OnImperialFragmentsUpdate( newAmount, oldAmount )


	elseif currencyType == CURT_TOME_CHALLENGE_REROLLS and DsRGuildLoot.sV.ChatTomeChallenge == true then
		DsRGuildLoot.OnTomeChallengeUpdate( newAmount, oldAmount )
	elseif currencyType == CURT_TOME_POINTS and DsRGuildLoot.sV.ChatTomePoints == true then
		DsRGuildLoot.OnTomePointsUpdate( newAmount, oldAmount )
	elseif currencyType == CURT_TOME_POINT_CACHES and DsRGuildLoot.sV.ChatTomePointCach == true then
		DsRGuildLoot.OnTomePointCachUpdate( newAmount, oldAmount )
	elseif currencyType == CURT_TOME_TOKENS and DsRGuildLoot.sV.ChatTomeToken == true then
		DsRGuildLoot.OnTomeTokenUpdate( newAmount, oldAmount )
	elseif currencyType == CURT_TRADE_BARS and DsRGuildLoot.sV.ChatTradeBars == true then
		DsRGuildLoot.OnTradeBarsUpdate( newAmount, oldAmount )
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildLoot.OnUndauntedUpdate( newUndaunted, oldUndaunted )
	if not DsRGuildLoot.sV.ChatUnerschrocken then return end

	local gain = newUndaunted - oldUndaunted
	if (gain == 0) then return end

	local ACCIconText   = zo_iconTextFormat("/esoui/art/inventory/inventory_currencytab_accountwide_up.dds", 22, 22, " ")

	local WHITEcolor      = "|cFFFFFF"
	local GREYcolor	      = "|c808080"
	local GREENcolor	  = "|c35fc38"
	local YELLOWcolor	  = "|cFFFF00"

	d(GREENcolor .. " +" .. ZO_CommaDelimitNumber( gain ):gsub("%,","%.") .. " " .. YELLOWcolor .. DsR.Localization[DsR.language].DsRGuildLoot_undauntedkeys .. GREYcolor .. " ( " .. ACCIconText .. ZO_CommaDelimitNumber( newUndaunted ):gsub("%,","%.") .. " )")
end
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildLoot.OnTransmuteUpdate( newTransmute, oldTransmute )
	if not DsRGuildLoot.sV.ChatTransmut then return end

	local gain = newTransmute - oldTransmute
	if (gain == 0) then return end

	local max 			= GetMaxPossibleCurrency(CURT_CHAOTIC_CREATIA, CURRENCY_LOCATION_ACCOUNT)
	local ACCIconText   = zo_iconTextFormat("/esoui/art/inventory/inventory_currencytab_accountwide_up.dds", 22, 22, " ")

	local WHITEcolor      = "|cFFFFFF"
	local GREYcolor	      = "|c808080"
	local GREENcolor	  = "|c35fc38"
	local REDcolor	      = "|cFF0000"
	local YELLOWcolor	  = "|cFFFF00"
	local TRANScolor	  = "|c5C6BFF"

	if gain < 0 then
		d(REDcolor .. ZO_CommaDelimitNumber( gain ):gsub("%,","%.") .. " " .. TRANScolor .. DsR.Localization[DsR.language].DsRGuildLoot_transmute_crystals .. GREYcolor .. " ( " .. ACCIconText .. ZO_CommaDelimitNumber( newTransmute ):gsub("%,","%.") .. " / " .. ZO_CommaDelimitNumber( max ):gsub("%,","%.") .. " )")
	else
		d(GREENcolor .. "+" .. ZO_CommaDelimitNumber( gain ):gsub("%,","%.") .. " " .. TRANScolor .. DsR.Localization[DsR.language].DsRGuildLoot_transmute_crystals .. GREYcolor .. " ( " .. ACCIconText .. ZO_CommaDelimitNumber( newTransmute ):gsub("%,","%.") .. " / " .. ZO_CommaDelimitNumber( max ):gsub("%,","%.") .. " )")
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildLoot.OnEndeavorUpdate( newEndeavor, oldEndeavor )
	local gain = newEndeavor - oldEndeavor
	if (gain == 0) then return end

	local ACCIconText       = zo_iconTextFormat("/esoui/art/inventory/inventory_currencytab_accountwide_up.dds", 22, 22, " ")

	local WHITEcolor      = "|cFFFFFF"
	local GREYcolor	      = "|c808080"
	local GREENcolor	  = "|c35fc38"
	local REDcolor	      = "|cFF0000"
	local YELLOWcolor	  = "|cFFFF00"
	local ENDEAVORcolor	  = "|cA52A2A"

	if DsRGuildLoot.sV.ChatBestrebung then
		if gain < 0 then
			d(REDcolor .. ZO_CommaDelimitNumber( gain ):gsub("%,","%.") .. " " .. ENDEAVORcolor .. DsR.Localization[DsR.language].DsRGuildLoot_endeavor .. GREYcolor .. " ( " .. ACCIconText .. ZO_CommaDelimitNumber( newEndeavor ):gsub("%,","%.") .. " )")
		else
			d(GREENcolor .. "+" .. ZO_CommaDelimitNumber( gain ):gsub("%,","%.") .. " " .. ENDEAVORcolor .. DsR.Localization[DsR.language].DsRGuildLoot_endeavor .. GREYcolor .. " ( " .. ACCIconText .. ZO_CommaDelimitNumber( newEndeavor ):gsub("%,","%.") .. " )")
		end
	end

	if DsRGuildLoot.sV.ScreenBestrebung then
		local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT)
		params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_BATTLEGROUND_OBJECTIVE)
		if gain < 0 then
			params:SetText(REDcolor .. ZO_CommaDelimitNumber( gain ):gsub("%,","%.") .. " " .. ENDEAVORcolor .. DsR.Localization[DsR.language].DsRGuildLoot_endeavor .. GREYcolor .. " ( " .. ACCIconText .. ZO_CommaDelimitNumber( newEndeavor ):gsub("%,","%.") .. " )" )
		else
			params:SetText(WHITEcolor .. "+" .. ZO_CommaDelimitNumber( gain ):gsub("%,","%.") .. " " .. ENDEAVORcolor .. DsR.Localization[DsR.language].DsRGuildLoot_endeavor .. GREYcolor .. " ( " .. ACCIconText .. ZO_CommaDelimitNumber( newEndeavor ):gsub("%,","%.") .. " )" )
		end
		CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildLoot.OnEndlessUpdate( newEndless, oldEndless )
	if not DsRGuildLoot.sV.ChatEndless then return end

	local gain = newEndless - oldEndless
	if (gain == 0) then return end

	local WHITEcolor      = "|cFFFFFF"
	local GREYcolor	      = "|c808080"
	local GREENcolor	  = "|c35fc38"
	local REDcolor	      = "|cFF0000"
	local YELLOWcolor	  = "|cFFFF00"

	if gain < 0 then
		d(REDcolor .. ZO_CommaDelimitNumber( gain ):gsub("%,","%.") .. " " .. YELLOWcolor .. DsR.Localization[DsR.language].DsRGuildLoot_archival_fortunes .. GREYcolor .. " ( " .. ZO_CommaDelimitNumber( newEndless ):gsub("%,","%.") .. " )")
	else
		d(GREENcolor .. "+" .. ZO_CommaDelimitNumber( gain ):gsub("%,","%.") .. " " .. YELLOWcolor .. DsR.Localization[DsR.language].DsRGuildLoot_archival_fortunes .. GREYcolor .. " ( " .. ZO_CommaDelimitNumber( newEndless ):gsub("%,","%.") .. " )")
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildLoot.OnImperialFragmentsUpdate( newImperialFragments, oldImperialFragments )
	if not DsRGuildLoot.sV.ChatIMPfragments then return end

	local gain = newImperialFragments - oldImperialFragments
	if (gain == 0) then return end

	local WHITEcolor      = "|cFFFFFF"
	local GREYcolor	      = "|c808080"
	local GREENcolor	  = "|c35fc38"
	local REDcolor	      = "|cFF0000"
	local YELLOWcolor	  = "|cFFFF00"
	local BLUEcolor       = "|c005b96"

	if gain < 0 then
		d(REDcolor .. ZO_CommaDelimitNumber( gain ):gsub("%,","%.") .. " " .. BLUEcolor .. DsR.Localization[DsR.language].DsRGuildLoot_imperial_fragments .. GREYcolor .. " ( " .. ZO_CommaDelimitNumber( newImperialFragments ):gsub("%,","%.") .. " )")
	else
		d(GREENcolor .. "+" .. ZO_CommaDelimitNumber( gain ):gsub("%,","%.") .. " " .. BLUEcolor .. DsR.Localization[DsR.language].DsRGuildLoot_imperial_fragments .. GREYcolor .. " ( " .. ZO_CommaDelimitNumber( newImperialFragments ):gsub("%,","%.") .. " )")
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildLoot.OnTomeChallengeUpdate( newTomeChallenge, oldTomeChallenge )
	if not DsRGuildLoot.sV.ChatTomeChallenge then return end

	local gain = newTomeChallenge - oldTomeChallenge
	if (gain == 0) then return end

	local WHITEcolor      = "|cFFFFFF"
	local GREYcolor	      = "|c808080"
	local GREENcolor	  = "|c35fc38"
	local REDcolor	      = "|cFF0000"
	local YELLOWcolor	  = "|cFFFF00"
	local BLUEcolor       = "|c005b96"

	if gain < 0 then
		d(REDcolor .. ZO_CommaDelimitNumber( gain ):gsub("%,","%.") .. " " .. BLUEcolor .. DsR.Localization[DsR.language].DsRGuildBarMenu_TomeChallenge .. GREYcolor .. " ( " .. ZO_CommaDelimitNumber( newTomeChallenge ):gsub("%,","%.") .. " )")
	else
		d(GREENcolor .. "+" .. ZO_CommaDelimitNumber( gain ):gsub("%,","%.") .. " " .. BLUEcolor .. DsR.Localization[DsR.language].DsRGuildBarMenu_TomeChallenge .. GREYcolor .. " ( " .. ZO_CommaDelimitNumber( newTomeChallenge ):gsub("%,","%.") .. " )")
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildLoot.OnTomePointsUpdate( newTomePoints, oldTomePoints )
	if not DsRGuildLoot.sV.ChatTomePoints then return end

	local gain = newTomePoints - oldTomePoints
	if (gain == 0) then return end

	local WHITEcolor      = "|cFFFFFF"
	local GREYcolor	      = "|c808080"
	local GREENcolor	  = "|c35fc38"
	local REDcolor	      = "|cFF0000"
	local YELLOWcolor	  = "|cFFFF00"
	local BLUEcolor       = "|c005b96"

	if gain < 0 then
		d(REDcolor .. ZO_CommaDelimitNumber( gain ):gsub("%,","%.") .. " " .. BLUEcolor .. DsR.Localization[DsR.language].DsRGuildBarMenu_TomePoints .. GREYcolor .. " ( " .. ZO_CommaDelimitNumber( newTomePoints ):gsub("%,","%.") .. " )")
	else
		d(GREENcolor .. "+" .. ZO_CommaDelimitNumber( gain ):gsub("%,","%.") .. " " .. BLUEcolor .. DsR.Localization[DsR.language].DsRGuildBarMenu_TomePoints .. GREYcolor .. " ( " .. ZO_CommaDelimitNumber( newTomePoints ):gsub("%,","%.") .. " )")
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildLoot.OnTomePointCachUpdate( newTomePointCach, oldTomePointCach )
	if not DsRGuildLoot.sV.ChatTomePointCach then return end

	local gain = newTomePointCach - oldTomePointCach
	if (gain == 0) then return end

	local WHITEcolor      = "|cFFFFFF"
	local GREYcolor	      = "|c808080"
	local GREENcolor	  = "|c35fc38"
	local REDcolor	      = "|cFF0000"
	local YELLOWcolor	  = "|cFFFF00"
	local BLUEcolor       = "|c005b96"

	if gain < 0 then
		d(REDcolor .. ZO_CommaDelimitNumber( gain ):gsub("%,","%.") .. " " .. BLUEcolor .. DsR.Localization[DsR.language].DsRGuildBarMenu_TomePointCach .. GREYcolor .. " ( " .. ZO_CommaDelimitNumber( newTomePointCach ):gsub("%,","%.") .. " )")
	else
		d(GREENcolor .. "+" .. ZO_CommaDelimitNumber( gain ):gsub("%,","%.") .. " " .. BLUEcolor .. DsR.Localization[DsR.language].DsRGuildBarMenu_TomePointCach .. GREYcolor .. " ( " .. ZO_CommaDelimitNumber( newTomePointCach ):gsub("%,","%.") .. " )")
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildLoot.OnTomeTokenUpdate( newTomeToken, oldTomeToken )
	if not DsRGuildLoot.sV.ChatTomeToken then return end

	local gain = newTomeToken - oldTomeToken
	if (gain == 0) then return end

	local WHITEcolor      = "|cFFFFFF"
	local GREYcolor	      = "|c808080"
	local GREENcolor	  = "|c35fc38"
	local REDcolor	      = "|cFF0000"
	local YELLOWcolor	  = "|cFFFF00"
	local BLUEcolor       = "|c005b96"

	if gain < 0 then
		d(REDcolor .. ZO_CommaDelimitNumber( gain ):gsub("%,","%.") .. " " .. BLUEcolor .. DsR.Localization[DsR.language].DsRGuildBarMenu_TomeToken .. GREYcolor .. " ( " .. ZO_CommaDelimitNumber( newTomeToken ):gsub("%,","%.") .. " )")
	else
		d(GREENcolor .. "+" .. ZO_CommaDelimitNumber( gain ):gsub("%,","%.") .. " " .. BLUEcolor .. DsR.Localization[DsR.language].DsRGuildBarMenu_TomeToken .. GREYcolor .. " ( " .. ZO_CommaDelimitNumber( newTomeToken ):gsub("%,","%.") .. " )")
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildLoot.OnTradeBarsUpdate( newTradeBars, oldTradeBars )
	if not DsRGuildLoot.sV.ChatTradeBars then return end

	local gain = newTradeBars - oldTradeBars
	if (gain == 0) then return end

	local WHITEcolor      = "|cFFFFFF"
	local GREYcolor	      = "|c808080"
	local GREENcolor	  = "|c35fc38"
	local REDcolor	      = "|cFF0000"
	local YELLOWcolor	  = "|cFFFF00"
	local BLUEcolor       = "|c005b96"

	if gain < 0 then
		d(REDcolor .. ZO_CommaDelimitNumber( gain ):gsub("%,","%.") .. " " .. BLUEcolor .. DsR.Localization[DsR.language].DsRGuildBarMenu_TradeBars .. GREYcolor .. " ( " .. ZO_CommaDelimitNumber( newTradeBars ):gsub("%,","%.") .. " )")
	else
		d(GREENcolor .. "+" .. ZO_CommaDelimitNumber( gain ):gsub("%,","%.") .. " " .. BLUEcolor .. DsR.Localization[DsR.language].DsRGuildBarMenu_TradeBars .. GREYcolor .. " ( " .. ZO_CommaDelimitNumber( newTradeBars ):gsub("%,","%.") .. " )")
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Achievement
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildLoot.AchievementComplete(name, points, id, link)
	if not DsRGuildLoot.sV.ChatArchivments then return end

	local _, _, _, icon = GetAchievementInfo(id)
	local aLink 		= GetAchievementLink(id)
	local GREENcolor	= "|c008000"
	local GREYcolor	    = "|c808080"

	local lgIconText    = zo_iconTextFormat(icon, 20, 20, " ")
	
	d(lgIconText .. " " .. aLink .. GREENcolor .. " " .. GetString(DsRGuildLoot_cAchievementsTxt) .. GREYcolor .. " ( " .. ZO_CommaDelimitNumber( points ):gsub("%,","%.") .. " )")
end

function DsRGuildLoot.AchievementUpdated(id, preview)
	if not DsRGuildLoot.sV.ChatArchivmentsStatus then return end

	local name, _, _, icon, completed = GetAchievementInfo(id)
	local nCrit = GetAchievementNumCriteria(id)
	local aLink = GetAchievementLink(id)
	local cText = ""

	if nCrit > 1 then
		local cTotal = 0
		for i = 1, nCrit do
			local cDesc, cCom, cReq = GetAchievementCriterion(id, i)
			if cCom >= cReq then cTotal = cTotal + 1 end
		end
		cText = ' (' .. tostring(cTotal) .. '/' .. tostring(nCrit) .. ')'
	else
		local cDesc, cCom, cReq = GetAchievementCriterion(id, 1)
		cText = ' (' .. tostring(cCom) .. '/' .. tostring(cReq) .. ')'
	end

	local WHITEcolor      = "|cFFFFFF"
	local GREYcolor	      = "|c808080"

	local lgIconText = zo_iconTextFormat(icon, 20, 20, " ")

	d("|cA52A2AUpdate: |r" .. lgIconText .. " " .. aLink .. WHITEcolor .. " " .. GetString(DsRGuildLoot_pAchievementsTxt) .. GREYcolor .. cText)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Books
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildLoot.OnLoreBookLearned(categoryIndex, collectionIndex, bookIndex, guildIndex, isMaxRank)
	if not DsRGuildLoot.sV.ChatBookLoot then return end

	local collectionName, collectionDescription, numKnownBooks, totalBooks, hidden, gamepadIcon, collectionId = GetLoreCollectionInfo(categoryIndex, collectionIndex)
	local bookTitle, bookIcon, bookKnown, bookId = GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex)
	local quantitiesTxt = ""

	if totalBooks ~= nil and totalBooks > 0 then
		quantitiesTxt = zo_strformat(" |c808080(<<1>>/<<2>>)|r", numKnownBooks, totalBooks)
	end
	local collectionIcon = zo_iconTextFormat("esoui/art/journal/journal_tabicon_lorelibrary_down.dds", 20, 20, " ")

	local lgIconText = zo_iconTextFormat(bookIcon, 20, 20, " ")

	local WHITEcolor  = "|cFFFFFF"
	local GREYcolor	  = "|c808080"
	if numKnownBooks ~= totalBooks then
		d(lgIconText .. bookTitle .. " " .. collectionIcon .. " " .. WHITEcolor  .. collectionName .. GREYcolor .. quantitiesTxt)
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------
-- XP Skills
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildLoot:OnSkillXPUpdated( eventId,  skillType,  skillIndex,  reason,  rank,  previousXP,  currentXP)
	local skillLineData = SKILLS_DATA_MANAGER:GetSkillLineDataByIndices(skillType, skillIndex)

	local lastSkillXP, nextSkillXP, currentSkillXP
	local skillName, skillRank
	local CraftType
	local icon 		 = "/esoui/art/skillsadvisor/indicator_abilitymorph.dds"
	local cSkillName = ""

	local WHITEcolor    = "|cFFFFFF"
	local GREYcolor	    = "|c808080"
	local REDcolor	  	= "|cFF0000"
	local YELLOWcolor 	= "|cFFFF00"
	local GREENcolor	= "|c35fc38"

	lastSkillXP, nextSkillXP, currentSkillXP = GetSkillLineXPInfo(skillType, skillIndex)
	skillName, skillRank          	         = GetSkillLineInfo(skillType, skillIndex)

	isActive = skillLineData:IsActive() and true or false

	local maxedSkill = (nextSkillXP == 0)

	--Skill Xp from craft
	if (( skillType == SKILL_TYPE_TRADESKILL ) and (reason == PROGRESS_REASON_TRADESKILL)) then
		if not DsRGuildLoot.sV.ChatXPcrafting then return end
		CraftType  = GetCraftingInteractionType()
		cSkillName = '|c'..DsRGuildLoot.num2hex({[1]=0,[2]=1,[3]=0.39,[4]=1})..skillName..'|r' or '|c6BB5FF'..skillName..'|r'
		
		if (CraftType == CRAFTING_TYPE_BLACKSMITHING) and DsRGuildLoot.sV.ChatXPblacksmithing == true then
			icon  = "/esoui/art/icons/skilllinexp_blacksmithing.dds"
		elseif (CraftType == CRAFTING_TYPE_CLOTHIER) and DsRGuildLoot.sV.ChatXPclothier == true then
			icon    = "/esoui/art/icons/skilllinexp_clothier.dds"
		elseif (CraftType == CRAFTING_TYPE_ENCHANTING) and DsRGuildLoot.sV.ChatXPenchanting == true then
			icon    = "/esoui/art/icons/skilllinexp_enchanting.dds"
		elseif (CraftType == CRAFTING_TYPE_ALCHEMY) and DsRGuildLoot.sV.ChatXPalchemy == true then
			icon    = "/esoui/art/icons/skilllinexp_alchemy.dds"
		elseif (CraftType == CRAFTING_TYPE_PROVISIONING) and DsRGuildLoot.sV.ChatXPprovisioner == true then
			icon    = "/esoui/art/icons/skilllinexp_provisioner.dds"
		elseif (CraftType == CRAFTING_TYPE_WOODWORKING) and DsRGuildLoot.sV.ChatXPwoodworking == true then
			icon    = "/esoui/art/icons/skilllinexp_woodworking.dds"
		elseif (CraftType == CRAFTING_TYPE_JEWELRYCRAFTING) and DsRGuildLoot.sV.ChatXPjewelrymaking == true then
			icon    = "/esoui/art/icons/skilllinexp_jewelrymaking.dds"
		else -- craft book
			local craftTable = {
				[1] = {icon = "/esoui/art/icons/skilllinexp_alchemy.dds"},		
				[2] = {icon = "/esoui/art/icons/skilllinexp_blacksmithing.dds"},	
				[3] = {icon = "/esoui/art/icons/skilllinexp_clothier.dds"},		
				[4] = {icon = "/esoui/art/icons/skilllinexp_enchanting.dds"},	
				[5] = {icon = "/esoui/art/icons/skilllinexp_jewelrymaking.dds"},	
				[6] = {icon = "/esoui/art/icons/skilllinexp_provisioner.dds"},	
				[7] = {icon = "/esoui/art/icons/skilllinexp_woodworking.dds"},	
			}
			icon  = (craftTable[skillIndex] ~= nil) and craftTable[skillIndex].icon or "esoui/art/mainmenu/menubar_journal_up.dds"
		end
--Skill Xp GUILD
	elseif ( skillType == SKILL_TYPE_GUILD ) then
		if maxedSkill then return end
		if not DsRGuildLoot.sV.ChatXPguild then return end
		cSkillName = '|c'..DsRGuildLoot.num2hex({[1]=0,[2]=1,[3]=1,[4]=1})..skillName..'|r' or '|c6BB5FF'..skillName..'|r'
		-- 1 = Dark Brotherhood // 2 = Fighters Guild // 3 = Mages Guild // 4 = Psijic Order // 5 = Thieves Guild // 6 = Undaunted
		if (skillIndex == 1) or (skillIndex == 2) or (skillIndex == 3) or (skillIndex == 4) or (skillIndex == 5) or (skillIndex == 6) then
			icon    = skillLineData:GetAnnounceIcon()
		else
			icon    = "/esoui/art/icons/poi/poi_groupinstance_complete.dds"
		end
--Skill Xp WORLD
	elseif ( skillType == SKILL_TYPE_WORLD ) then
		if maxedSkill or not isActive then return end
		cSkillName = '|c'..DsRGuildLoot.num2hex({[1]=0,[2]=1,[3]=1,[4]=1})..skillName..'|r' or '|c6BB5FF'..skillName..'|r'
		if skillIndex == 1 then -- Excavation
			if not DsRGuildLoot.sV.ChatXPexcavation == true then return end
			icon  = "/esoui/art/icons/skilllinexp_digging.dds"
		elseif skillIndex == 2 then -- Legerdemain
			if not DsRGuildLoot.sV.ChatXPlegerdemain == true then return end
			icon  = "/esoui/art/icons/skilllinexp_ledgermain.dds"
		elseif skillIndex == 3 then -- Scrying
			if not DsRGuildLoot.sV.ChatXPscrying == true then return end
			icon  = "/esoui/art/icons/skilllinexp_scrying.dds"
		elseif skillIndex == 4 then -- Soul Magic
			if not DsRGuildLoot.sV.ChatXPsoulmagic == true then return end
			icon  = "/esoui/art/icons/soulgem_006_filled.dds"
		elseif skillIndex == 5 then -- Vampire
			if not DsRGuildLoot.sV.ChatXPvampire == true then return end
			icon  = "/esoui/art/icons/ability_vampire_007.dds"
		elseif skillIndex == 6 then -- Werewolf
			if not DsRGuildLoot.sV.ChatXPwerewolf == true then return end
			icon  = "/esoui/art/icons/ability_werewolf_010.dds"
		end
--Skill Xp WEAPON PROGRESS
	elseif ( skillType == SKILL_TYPE_WEAPON ) then
		if maxedSkill or not isActive then return end
		if not DsRGuildLoot.sV.ChatXPweapon then return end
		cSkillName = '|c'..DsRGuildLoot.num2hex({[1]=1,[2]=0.78,[3]=0.39,[4]=1})..skillName..'|r' or '|c6BB5FF'..skillName..'|r'
		if skillIndex == 1 then -- Two-Handed
			icon  = "/esoui/art/icons/icon_2handed.dds"
		elseif skillIndex == 2 then -- 1-Hand & Shield
			icon  = "/esoui/art/icons/icon_1handed.dds"
		elseif skillIndex == 3 then -- Dual Wield
			icon  = "/esoui/art/icons/icon_dualwield.dds"
		elseif skillIndex == 4 then -- Bow
			icon  = "/esoui/art/icons/icon_bows.dds"
		elseif skillIndex == 5 then -- Destruction Staff
			icon  = "/esoui/art/icons/icon_firestaff.dds"
		elseif skillIndex == 6 then -- Restoration Staff
			icon  = "/esoui/art/icons/progression_tabicon_healstaff_up.dds"
		end
--Skill Xp ARMOR PROGRESS
	elseif ( skillType == SKILL_TYPE_ARMOR ) then
		if maxedSkill or not isActive then return end
		if not DsRGuildLoot.sV.ChatXParmor then return end
		cSkillName = '|c'..DsRGuildLoot.num2hex({[1]=0.78,[2]=0.6,[3]=1,[4]=1})..skillName..'|r' or '|c6BB5FF'..skillName..'|r'
		if skillIndex == 1 then -- Light Armor
			icon  = "/esoui/art/icons/progression_tabicon_armorlight_up.dds"
		elseif skillIndex == 2 then	-- Medium Armor
			icon  = "/esoui/art/icons/progression_tabicon_armormedium_up.dds"
		elseif skillIndex == 3 then -- Heavy Armor
			icon  = "/esoui/art/icons/progression_tabicon_armorheavy_up.dds"
		end
--Skill Xp AvA PROGRESS
	elseif ( skillType == SKILL_TYPE_AVA ) then
		if maxedSkill or not isActive then return end
		if not DsRGuildLoot.sV.ChatXPava then return end
		cSkillName = '|c'..DsRGuildLoot.num2hex({[1]=1,[2]=0.39,[3]=0.39,[4]=1})..skillName..'|r' or '|c6BB5FF'..skillName..'|r'
		if skillIndex == 1 then -- Assault
			icon  = "/esoui/art/compass/ava_largekeep_neutral.dds"
		elseif skillIndex == 2 then	-- Emperor
			icon  = "/esoui/art/campaign/gamepad/gp_overview_menuicon_emperor.dds"
		elseif skillIndex == 3 then -- Support
			icon  = "/esoui/art/compass/ava_outpost_neutral.dds"
		end
-- Fence skill line
	elseif (reason == PROGRESS_REASON_JUSTICE_SKILL_EVENT) then
		cSkillName = '|c'..DsRGuildLoot.num2hex({[1]=0.78,[2]=0.78,[3]=0.39,[4]=1})..skillName..'|r' or '|c6BB5FF'..skillName..'|r'
		icon 	   = "/esoui/art/icons/skilllinexp_ledgermain.dds"
--Skill XP from books in library
	elseif (reason == PROGRESS_REASON_SKILL_BOOK or reason == PROGRESS_REASON_BOOK_COLLECTION_COMPLETE) then
		cSkillName = '|c'..DsRGuildLoot.num2hex({[1]=0,[2]=0.39,[3]=1,[4]=1})..skillName..'|r' or '|c6BB5FF'..skillName..'|r'
		icon 	   = "/esoui/art/mainmenu/menubar_journal_up.dds"
	else
		return
	end

	local RealGain
	local SkillXp
	local SkillXpTotal

	SkillXp      = ( currentSkillXP - lastSkillXP ) -- levelCurrent
	SkillXpTotal = SkillXp
	if ( not maxedSkill ) then
		SkillXpTotal = nextSkillXP - lastSkillXP -- levelCap
	end

	RealGain = currentXP - previousXP

	local pccurrent=0
	if (SkillXpTotal > 0) then
		pccurrent = DsRGuildLoot.FormatAmount(math.floor(100*(SkillXp/SkillXpTotal)))
	end
	
	local sLevel = "Rank ".. tostring(skillRank)
	local progressMin = zo_strformat( '(<<1>>%)', pccurrent )
	local progressFull = zo_strformat( '<<1>>/<<2>> (<<3>>%)', DsRGuildLoot.FormatAmount(SkillXp), DsRGuildLoot.FormatAmount(SkillXpTotal), pccurrent )
	local lProg = ((skillLevel) and (true) and (true)) and progressFull or ((skillLevel) and (true)) and progressMin or ""

	local pctexts = ""

	if (( skillType == SKILL_TYPE_GUILD ) and ( skillIndex == 4 )) then
		pctexts = zo_strformat( '<<1>>', sLevel )
	else
		pctexts = zo_strformat( '<<1>> <<2>>', sLevel, lProg )
	end

	local lgIconText = zo_iconTextFormat(tostring(icon), 22, 22, " ")
	local OutputTXT  = zo_strformat( '|c6BB5FF+<<1>> <<2>>|r <<t:3>>  |c6BB5FF<<4>>|r |c736F6E<<5>>|r ', DsRGuildLoot.FormatAmount(RealGain), zo_iconTextFormat("/DsRGuildHall/misc/DsR_XP.dds", 18, 18), cSkillName, pctexts, progressFull )
	
	CHAT_SYSTEM:AddMessage(lgIconText .. OutputTXT)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Treasure found
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildLoot.StartLockpick(event) 
    if not IsUnitInDungeon("player") 		 then return end
	if not IsPlayerInGroup(GetDisplayName()) then return end

	if interactionData.name ~= DsRGuildLoot.ChestName then
		interactionData = {}
		return
	end
	
	local messageTextFormatted = ""

	if DsRGuildLoot.LastLockpick ~= nil then
		exp_sec = DsRGuildLoot.LastLockpick + 90
	end

	if DsRGuildLoot.LastLockpick == nil or exp_sec <= os.time() then
		LockQuality = GetLockQuality()
        if clientLang == "de" and not DsRGuildLoot.sV.ChestFoundOnlyEN then
            messageTextFormatted = string.format("Truhe gefunden!! (Qualität: %s )", DsRGuildLoot.sV.de_chestDifficultyName[LockQuality])
        else
            messageTextFormatted = string.format("Chest found!! (quality: %s )", DsRGuildLoot.sV.en_chestDifficultyName[LockQuality])
        end

		CHAT_SYSTEM:StartTextEntry(messageTextFormatted, CHAT_CHANNEL_PARTY)

		DsRGuildLoot.LastLockpick = os.time()
	end
end

function DsRGuildLoot.LockpickSuccess(event)
	if DsRGuildLoot.LastLockpick ~= nil then
		DsRGuildLoot.LastLockpick = nil	
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Format change
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildLoot.FormatAmount( amount, prefix )
	local tVal = ""
	local flipVal = (amount < 0) and amount * -1 or amount

	tVal = ZO_CommaDelimitNumber( flipVal ):gsub("%,","%.")

	if (prefix) then
		tVal = (amount < 0) and "-"..tVal or "+"..tVal
	end

	return tVal
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- num 2 hex
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildLoot.num2hex(ntable)
	local cstring = ""
	for i = 1, 3, 1 do
		local colornum = ntable[i] * 255
		local hexstr = "0123456789abcdef"
		local s = ""
		while colornum > 0 do
			local mod = math.fmod(colornum, 16)
			s = string.sub(hexstr, mod+1, mod+1) .. s
			colornum = math.floor(colornum / 16)
		end
		if #s == 1 then s = "0" .. s end
		if s == "" then s = "00" end
		cstring = cstring .. s
	end
	return cstring
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- On addon loaded
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildLoot.OnAddonLoaded(event, name)

	EVENT_MANAGER:RegisterForEvent(DsRGuildLoot.name, EVENT_LOOT_RECEIVED, DsRGuildLoot.OnLootReceived)

	EVENT_MANAGER:RegisterForEvent(DsRGuildLoot.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, DsRGuildLoot.OnLootReceivedContainer)

	EVENT_MANAGER:RegisterForEvent(DsRGuildLoot.name, EVENT_MAIL_READABLE, function( _, ... )  DsRGuildLoot.OnMailReadable( ... ) end)
	EVENT_MANAGER:RegisterForEvent(DsRGuildLoot.name, EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS, function( _, ... ) DsRGuildLoot.OnMailItemLooted( ... )    end)

	if DsRGuildLoot.sV.ChatXP then
		EVENT_MANAGER:RegisterForEvent(DsRGuildLoot.name, EVENT_EXPERIENCE_GAIN, function( _, ... ) DsRGuildLoot.OnXPUpdated( ... ) end )
	else
		EVENT_MANAGER:UnregisterForEvent(DsRGuildLoot.name, EVENT_EXPERIENCE_GAIN )
	end
	if DsRGuildLoot.sV.ChatXPskills then
		EVENT_MANAGER:RegisterForEvent(DsRGuildLoot.name, EVENT_SKILL_XP_UPDATE, function( ... ) DsRGuildLoot:OnSkillXPUpdated( ... ) end )
	else
		EVENT_MANAGER:UnregisterForEvent(DsRGuildLoot.name, EVENT_SKILL_XP_UPDATE )
	end
	if DsRGuildLoot.sV.ChatGold then
		EVENT_MANAGER:RegisterForEvent(DsRGuildLoot.name, EVENT_MONEY_UPDATE, function( _, ... ) DsRGuildLoot.OnMoneyUpdated( ... )  end )
	else
		EVENT_MANAGER:UnregisterForEvent(DsRGuildLoot.name, EVENT_MONEY_UPDATE )
	end

	DsRGuildLoot.AccountCurrencies()

	if DsRGuildLoot.sV.ChatGroupLoot then
		EVENT_MANAGER:RegisterForEvent(DsRGuildLoot.name, EVENT_GROUP_TYPE_CHANGED, function( _, ... ) DsRGuildLoot.OnGroupChanged( ... ) end )
		EVENT_MANAGER:RegisterForEvent(DsRGuildLoot.name, EVENT_GROUP_MEMBER_JOINED, function( _, ... ) DsRGuildLoot.OnGroupChanged( ... ) end )
		EVENT_MANAGER:RegisterForEvent(DsRGuildLoot.name, EVENT_GROUP_MEMBER_LEFT, function( _, ... ) DsRGuildLoot.OnGroupChanged( ... ) end )
		EVENT_MANAGER:RegisterForEvent(DsRGuildLoot.name, EVENT_GROUP_UPDATE, function( _, ... ) DsRGuildLoot.OnGroupChanged( ... ) end )
		DsRGuildLoot.OnGroupChanged()
	else
		EVENT_MANAGER:UnregisterForEvent(DsRGuildLoot.name, EVENT_GROUP_TYPE_CHANGED )
		EVENT_MANAGER:UnregisterForEvent(DsRGuildLoot.name, EVENT_GROUP_MEMBER_JOINED )
		EVENT_MANAGER:UnregisterForEvent(DsRGuildLoot.name, EVENT_GROUP_MEMBER_LEFT )
		EVENT_MANAGER:UnregisterForEvent(DsRGuildLoot.name, EVENT_GROUP_UPDATE )
	end
	if DsRGuildLoot.sV.ChatArchivments then
		EVENT_MANAGER:RegisterForEvent(DsRGuildLoot.name, EVENT_ACHIEVEMENT_AWARDED, function(_, ... ) DsRGuildLoot.AchievementComplete(...) end )
	else
		EVENT_MANAGER:UnregisterForEvent(DsRGuildLoot.name, EVENT_ACHIEVEMENT_AWARDED )
	end
	if DsRGuildLoot.sV.ChatArchivmentsStatus then
		EVENT_MANAGER:RegisterForEvent(DsRGuildLoot.name, EVENT_ACHIEVEMENT_UPDATED, function(_, ... ) DsRGuildLoot.AchievementUpdated(...) end )
	else
		EVENT_MANAGER:UnregisterForEvent(DsRGuildLoot.name, EVENT_ACHIEVEMENT_UPDATED )
	end
	if DsRGuildLoot.sV.ChatBookLoot then
		EVENT_MANAGER:RegisterForEvent(DsRGuildLoot.name, EVENT_LORE_BOOK_LEARNED, function( _, ... ) DsRGuildLoot.OnLoreBookLearned( ... ) end )
	else
		EVENT_MANAGER:UnregisterForEvent(DsRGuildLoot.name, EVENT_LORE_BOOK_LEARNED )
	end

    if DsRGuildLoot.sV.ChestFoundOnOff then
		EVENT_MANAGER:RegisterForEvent(DsRGuildLoot.name, EVENT_BEGIN_LOCKPICK, DsRGuildLoot.StartLockpick)
		EVENT_MANAGER:RegisterForEvent(DsRGuildLoot.name, EVENT_LOCKPICK_SUCCESS, DsRGuildLoot.LockpickSuccess)
	else
		EVENT_MANAGER:UnregisterForEvent(DsRGuildLoot.name, EVENT_BEGIN_LOCKPICK )
		EVENT_MANAGER:UnregisterForEvent(DsRGuildLoot.name, EVENT_LOCKPICK_SUCCESS )
	end

	EVENT_MANAGER:UnregisterForEvent(DsRGuildLoot.name, EVENT_ADD_ON_LOADED)
end
