ArchEnhancedGamepad = ZO_Object:Subclass()

local LAM = LibStub:GetLibrary("LibAddonMenu-2.0")

function ArchEnhancedGamepad:SetupOptions()
	local addonDisplayName = "|c0066FFArch's|r Enhanced Gamepad"

	local panelData = {
		type = "panel",
		name = addonDisplayName,
		displayName = addonDisplayName,
		author = "|c0066FFArchitecture|r",
		--version = self.version,
		registerForRefresh = true,
		registerForDefaults = false,
	}
	
	local optionsTable = {
		{
			type = "header",
			name = "General Interface Enhancements",
			width = "full",
		},
		{
			type = "checkbox",
			name = "Advanced Action Slots (Context Menu)",
			tooltip = "Adds various features to the context menus. Such as allowing items to be marked as \"junk\" as a filter to automatically de-clutter the inventory.",
			getFunc = function() return self.sv.slotActionsEnabled end,
			setFunc = function(value) self.sv.slotActionsEnabled = value if (value) then self:HookSlotActions() end end,
			width = "full",
		},
		{
			type = "checkbox",
			name = "Achievements (Link in Chat)",
			tooltip = "Allows link to chat for achievements via gamepad interface",
			warning = "Requires Reload UI",
			getFunc = function() return self.sv.achievementsLinksEnabled end,
			setFunc = function(value) self.sv.achievementsLinksEnabled = value ReloadUI() end,
			width = "full",
		},
		{
			type = "checkbox",
			name = "Chat Compatibility",
			tooltip = "Ensures that the scrollbar is properly displayed upon loading the game interface.",
			warning = "Requires Reload UI",
			getFunc = function() return self.sv.pChatCompatWorkaroundEnabled end,
			setFunc = function(value) self.sv.pChatCompatWorkaroundEnabled = value ReloadUI() end,
			width = "full",
		},
		{
			type = "checkbox",
			name = "Inventory Junk Handling (Mark/Unmark as Junk)",
			tooltip = "Replaces the Destroy keybinding with Mark/Unmark as Junk within the gamepad inventory interface.",
			warning = "Requires Reload UI",
			getFunc = function() return self.sv.inventoryMarkAsJunkEnabled end,
			setFunc = function(value) self.sv.inventoryMarkAsJunkEnabled = value ReloadUI() end,
			width = "full",
		},
		{
			type = "checkbox",
			name = "Custom Item Categories",
			tooltip = "Designates whether to use optimized / customized categorization of items in inventory and bank.",
			warning = "Requires Reload UI if disabling",
			getFunc = function() return self.sv.customItemCategorizationEnabled end,
			setFunc = function(value) self.sv.customItemCategorizationEnabled = value if value then self:HookInventoryUtils() else ReloadUI() end end,
			width = "full",
		}
	}

	LAM:RegisterAddonPanel(self.name, panelData)
	LAM:RegisterOptionControls(self.name, optionsTable)
end

local function MarkAsJunkHelper(bag, index, isJunk)
	SetItemIsJunk(bag, index, isJunk)
	PlaySound(isJunk and SOUNDS.INVENTORY_ITEM_JUNKED or SOUNDS.INVENTORY_ITEM_UNJUNKED)
end

local function AEG_IsSlotLocked(inventorySlot)
	if (not inventorySlot) then
		return false
	end
	
	local slot = PLAYER_INVENTORY:SlotForInventoryControl(inventorySlot)
	if slot then
		return slot.locked
	end
end

function ArchEnhancedGamepad:HookItemActions()
	local hookFunction = GAMEPAD_INVENTORY.InitializeItemList
	GAMEPAD_INVENTORY.InitializeItemList = function(...)
		hookFunction(...)
	
		-- Faster Scrolling
		if GAMEPAD_INVENTORY.itemList.movementController ~= nil then
			GAMEPAD_INVENTORY.itemList.movementController.accumulationPerSecondForChange = 4
		end
	
	end

end

local function IsSendingMail()
	if MAIL_SEND and not MAIL_SEND:IsHidden() then
		return true
	elseif MAIL_MANAGER_GAMEPAD and MAIL_MANAGER_GAMEPAD:GetSend():IsAttachingItems() then
		return true
	end
	return false
end

function ArchEnhancedGamepad:HookSlotActions()
	if (self.hookSlotActionsDone ~= nil and self.hookSlotActionsDone) then return end
	self.hookSlotActionsDone = true
	
	ZO_PreHook(_G, "ZO_InventorySlot_DiscoverSlotActionsFromActionList", function(inventorySlot, slotActions)
		if ARCH_ENHANCED_GAMEPAD.sv.slotActionsEnabled then
			if not QUICKSLOT_WINDOW:AreQuickSlotsShowing()
				and not (TRADING_HOUSE and TRADING_HOUSE:IsAtTradingHouse())
				and not (ZO_Store_IsShopping and ZO_Store_IsShopping())
				and not IsSendingMail()
				and not (TRADE_WINDOW and TRADE_WINDOW:IsTrading())
				and not PLAYER_INVENTORY:IsBanking()
				and not PLAYER_INVENTORY:IsGuildBanking() then
				local bag, index = ZO_Inventory_GetBagAndIndex(inventorySlot)
				local _, isEquipped = GetEquippedItemInfo(index)
				
				if not isEquipped and inventorySlot.itemType ~= ITEMTYPE_WEAPON and inventorySlot.slotType == SLOT_TYPE_GAMEPAD_INVENTORY_ITEM --[[and not HasItemInSlot(BAG_WORN, inventorySlot)]] then
					if GAMEPAD_INVENTORY.actionMode == 3 then
						inventorySlot.slotType = SLOT_TYPE_CRAFT_BAG_ITEM
					else
						inventorySlot.slotType = SLOT_TYPE_ITEM
					end
				end
			elseif PLAYER_INVENTORY:IsBanking() and GAMEPAD_BANKING ~= nil and GAMEPAD_BANKING.mode == 1 then
				--inventorySlot.slotType = SLOT_TYPE_BANK_ITEM
			end
		end
	end)
end

function ArchEnhancedGamepad:HookInventoryUtils()
	local function GetCategoryFromItemType(itemType)
		-- Alchemy
		if      ITEMTYPE_REAGENT == itemType or
			ITEMTYPE_POTION_BASE == itemType or
			ITEMTYPE_POISON_BASE == itemType then
			return GAMEPAD_ITEM_CATEGORY_ALCHEMY
			
			-- Bait
		elseif  ITEMTYPE_LURE == itemType then
			return GAMEPAD_ITEM_CATEGORY_BAIT
			
			-- Blacksmith
		elseif  ITEMTYPE_BLACKSMITHING_RAW_MATERIAL == itemType or
			ITEMTYPE_BLACKSMITHING_MATERIAL == itemType or
			ITEMTYPE_BLACKSMITHING_BOOSTER == itemType then
			return GAMEPAD_ITEM_CATEGORY_BLACKSMITH
			
			-- Clothier
		elseif  ITEMTYPE_CLOTHIER_RAW_MATERIAL == itemType or
			ITEMTYPE_CLOTHIER_MATERIAL == itemType or
			ITEMTYPE_CLOTHIER_BOOSTER == itemType then
			return GAMEPAD_ITEM_CATEGORY_CLOTHIER
			
			-- Consumable
		elseif  ITEMTYPE_DRINK == itemType or
			ITEMTYPE_FOOD == itemType then
			return GAMEPAD_ITEM_CATEGORY_CONSUMABLE
			
			-- Constume
		elseif  ITEMTYPE_COSTUME == itemType then
			return GAMEPAD_ITEM_CATEGORY_COSTUME
			
			-- Enchanting
		elseif  ITEMTYPE_ENCHANTING_RUNE_POTENCY == itemType or
			ITEMTYPE_ENCHANTING_RUNE_ASPECT == itemType or
			ITEMTYPE_ENCHANTING_RUNE_ESSENCE == itemType then
			return GAMEPAD_ITEM_CATEGORY_ENCHANTING
			
			-- Glyphs
		elseif  ITEMTYPE_GLYPH_WEAPON == itemType or
			ITEMTYPE_GLYPH_ARMOR == itemType or
			ITEMTYPE_GLYPH_JEWELRY == itemType then
			return GAMEPAD_ITEM_CATEGORY_GLYPHS
			
			-- Potion
		elseif  ITEMTYPE_POTION == itemType then
			return GAMEPAD_ITEM_CATEGORY_POTION
			
			-- Provisioning
		elseif  ITEMTYPE_INGREDIENT == itemType or
			ITEMTYPE_ADDITIVE == itemType or
			ITEMTYPE_SPICE == itemType or
			ITEMTYPE_FLAVORING == itemType then
			return GAMEPAD_ITEM_CATEGORY_PROVISIONING
			
			-- Siege
		elseif  ITEMTYPE_SIEGE == itemType or
			ITEMTYPE_AVA_REPAIR == itemType then
			return GAMEPAD_ITEM_CATEGORY_SIEGE
			
			-- Spellcrafting
		elseif  ITEMTYPE_SPELLCRAFTING_TABLET == itemType then
			return GAMEPAD_ITEM_CATEGORY_SPELLCRAFTING
			
			-- Style Material
		elseif  ITEMTYPE_STYLE_MATERIAL == itemType then
			return GAMEPAD_ITEM_CATEGORY_STYLE_MATERIAL
			
			-- Soul Gem
		elseif  ITEMTYPE_SOUL_GEM == itemType then
			return GAMEPAD_ITEM_CATEGORY_SOUL_GEM
			
			-- Tool
		elseif  ITEMTYPE_LOCKPICK == itemType or
			ITEMTYPE_TOOL == itemType then
			return GAMEPAD_ITEM_CATEGORY_TOOL
			
			-- Trait Gem
		elseif  ITEMTYPE_ARMOR_TRAIT == itemType or
			ITEMTYPE_WEAPON_TRAIT == itemType then
			return GAMEPAD_ITEM_CATEGORY_TRAIT_GEM
			
			-- Trophy
		elseif  ITEMTYPE_TROPHY == itemType then
			return GAMEPAD_ITEM_CATEGORY_TROPHY
			
			-- Woodworking
		elseif  ITEMTYPE_WOODWORKING_RAW_MATERIAL == itemType or
			ITEMTYPE_WOODWORKING_MATERIAL == itemType or
			ITEMTYPE_WOODWORKING_BOOSTER == itemType then
			return GAMEPAD_ITEM_CATEGORY_WOODWORKING
		end
	end
	
	local function GetCategoryFromWeapon(itemData)
		local weaponType
		if itemData.bagId and itemData.slotIndex then
			weaponType = GetItemWeaponType(itemData.bagId, itemData.slotIndex)
		else
			weaponType = GetItemLinkWeaponType(itemData.itemLink)
		end
		
		-- Axe
		if WEAPONTYPE_AXE == weaponType or WEAPONTYPE_TWO_HANDED_AXE == weaponType then
			return GAMEPAD_ITEM_CATEGORY_AXE
			
			-- Bow
		elseif WEAPONTYPE_BOW == weaponType then
			return GAMEPAD_ITEM_CATEGORY_BOW
			
			-- Dagger
		elseif WEAPONTYPE_DAGGER == weaponType then
			return GAMEPAD_ITEM_CATEGORY_DAGGER
			
			-- Hammer
		elseif WEAPONTYPE_HAMMER == weaponType or WEAPONTYPE_TWO_HANDED_HAMMER == weaponType then
			return GAMEPAD_ITEM_CATEGORY_HAMMER
			
			-- Shield
		elseif WEAPONTYPE_SHIELD == weaponType then
			return GAMEPAD_ITEM_CATEGORY_SHIELD
			
			-- Staff
		elseif WEAPONTYPE_HEALING_STAFF == weaponType or WEAPONTYPE_FIRE_STAFF == weaponType or
			WEAPONTYPE_FROST_STAFF == weaponType or WEAPONTYPE_LIGHTNING_STAFF == weaponType then
			return GAMEPAD_ITEM_CATEGORY_STAFF
			
			-- Sword
		elseif weaponType == WEAPONTYPE_SWORD or weaponType == WEAPONTYPE_TWO_HANDED_SWORD then
			return GAMEPAD_ITEM_CATEGORY_SWORD
		end
	end
	
	local function GetCategoryFromArmor(itemData)
		local equipType = itemData.equipType
		
		-- Chest
		if      EQUIP_TYPE_CHEST == equipType then
			return GAMEPAD_ITEM_CATEGORY_CHEST
			
			-- Feet
		elseif  EQUIP_TYPE_FEET == equipType then
			return GAMEPAD_ITEM_CATEGORY_FEET
			
			-- Hand
		elseif  EQUIP_TYPE_HAND == equipType then
			return GAMEPAD_ITEM_CATEGORY_HANDS
			
			-- Head
		elseif  EQUIP_TYPE_HEAD == equipType then
			return GAMEPAD_ITEM_CATEGORY_HEAD
			
			-- Legs
		elseif  EQUIP_TYPE_LEGS == equipType then
			return GAMEPAD_ITEM_CATEGORY_LEGS
			
			-- Ring
		elseif  EQUIP_TYPE_RING == equipType then
			return GAMEPAD_ITEM_CATEGORY_RING
			
			-- Shoulders
		elseif  EQUIP_TYPE_SHOULDERS == equipType then
			return GAMEPAD_ITEM_CATEGORY_SHOULDERS
			
			-- Waist
		elseif  EQUIP_TYPE_WAIST == equipType then
			return GAMEPAD_ITEM_CATEGORY_WAIST
		end
	end

	local function IsCustomCategoryItemType(itemType)
		return itemType == ITEMTYPE_RACIAL_STYLE_MOTIF or
			itemType == ITEMTYPE_RECIPE
	end

	--GAMEPAD_INVENTORY.categorizationFunction = function(itemData)
	local function categorizationFunctionGetBestItemCategoryDescription(itemData)
		local category = nil
		--itemData.itemType
	
		if itemData.equipType == EQUIP_TYPE_RING then
			category = GAMEPAD_ITEM_CATEGORY_RING
		elseif itemData.itemType == ITEMTYPE_WEAPON then
			category = GetCategoryFromWeapon(itemData)
		elseif itemData.itemType == ITEMTYPE_ARMOR then
			category = GetCategoryFromArmor(itemData)
		else
			category = GetCategoryFromItemType(itemData.itemType)
		end
		
		if category then
			return GetString("SI_GAMEPADITEMCATEGORY", category)
		end
		
		-- New check / transformation
		if IsCustomCategoryItemType(itemData.itemType) then
			return GetString("SI_ARCHGP_CUSTOM_ITEM_CAT", itemData.itemType)
		end
		
		return zo_strformat(SI_INVENTORY_HEADER, GetString("SI_ITEMTYPE", itemData.itemType))
	end
	
	GAMEPAD_INVENTORY.categorizationFunction = categorizationFunctionGetBestItemCategoryDescription
	
	GAMEPAD_BANKING_SCENE:RegisterCallback("StateChange", function(oldState, newState)
		--SharedStateChangeCallback(oldState, newState)
		
		if newState == SCENE_SHOWING then
			GAMEPAD_BANKING.lists.deposit.categorizationFunction = categorizationFunctionGetBestItemCategoryDescription
			GAMEPAD_BANKING.lists.withdraw.categorizationFunction = categorizationFunctionGetBestItemCategoryDescription
		end
	end)
	--GAMEPAD_BANKING.lists.deposit.categorizationFunction = GAMEPAD_INVENTORY.categorizationFunction
	--GAMEPAD_BANKING.lists.withdraw.categorizationFunction = GAMEPAD_INVENTORY.categorizationFunction

	--[[local hookFunction = ZO_InventoryUtils_Gamepad_GetBestItemCategoryDescription
	ZO_InventoryUtils_Gamepad_GetBestItemCategoryDescription = function(itemData)
		local itemCategoryDescription = hookFunction(itemData)
		
		if itemData.isJunk ~= nil and itemData.isJunk then
			return ITEMFILTERTYPE_JUNK
		end
		
		return itemCategoryDescription
	end]]
end

local function IsInventorySlotLockedOrJunk(targetData)
	local bag, index = ZO_Inventory_GetBagAndIndex(targetData)
	return (not IsItemPlayerLocked(bag, index) or IsItemJunk(bag, index))
end

function ArchEnhancedGamepad:HookInventory()
	--local initKeybindStripOrig = GAMEPAD_INVENTORY.InitializeKeybindStrip
	--GAMEPAD_INVENTORY.InitializeKeybindStrip = function(...)
		--initKeybindStripOrig(...)
	ZO_PreHook(GAMEPAD_INVENTORY, "SwitchActiveList", function(...)
		if (GAMEPAD_INVENTORY.itemFilterKeybindStripDescriptor ~= nil) then
			GAMEPAD_INVENTORY.itemFilterKeybindStripDescriptor[3] = {
				name = function()
					if (true) then
						if (GAMEPAD_INVENTORY.selectedItemUniqueId ~= nil) then
							local targetData = GAMEPAD_INVENTORY.itemList:GetTargetData()
							local bag, index = ZO_Inventory_GetBagAndIndex(targetData)
							if (IsItemJunk(bag, index)) then
								return GetString(SI_ITEM_ACTION_UNMARK_AS_JUNK)
							end
						end
						
						return GetString(SI_ITEM_ACTION_MARK_AS_JUNK)
					end
					
					return GetString(SI_ITEM_ACTION_STACK_ALL)
					
					--local selectedData = GAMEPAD_INVENTORY.categoryList.selectedData
					--return (selectedData.filterType == ITEMFILTERTYPE_JUNK) and GetString(SI_ITEM_ACTION_UNMARK_AS_JUNK) or
					--		GetString(SI_ITEM_ACTION_MARK_AS_JUNK)
				end,
				--name = GetString(SI_ITEM_ACTION_DESTROY),
				keybind = "UI_SHORTCUT_RIGHT_STICK",
				order = 2000,
				disabledDuringSceneHiding = true,
				
				visible = function()
					if (true) then
						if (GAMEPAD_INVENTORY.selectedItemUniqueId ~= nil) then
							--*--if self.selectedItemUniqueId ~= nil then
							local targetData = GAMEPAD_INVENTORY.itemList:GetTargetData()
							return IsInventorySlotLockedOrJunk(targetData)
							--*--return ZO_InventorySlot_CanDestroyItem(targetData)
						else
							local targetData = GAMEPAD_INVENTORY.itemList:GetTargetData()
							if (targetData ~= nil) then
								return IsInventorySlotLockedOrJunk(targetData)
								--*--return true
							end
						end
						
						return false
					end
					
					return true
				end,
				
				callback = function()
					if (true) then
						if (GAMEPAD_INVENTORY.selectedItemUniqueId ~= nil) then
							local targetData = GAMEPAD_INVENTORY.itemList:GetTargetData()
							local bag, index = ZO_Inventory_GetBagAndIndex(targetData)
							local isJunk = not IsItemJunk(bag, index)
							if (not IsItemPlayerLocked(bag, index) or (IsItemPlayerLocked(bag, index) and not isJunk)) then
								SetItemIsJunk(bag, index, isJunk)
								PlaySound(isJunk and SOUNDS.INVENTORY_ITEM_JUNKED or SOUNDS.INVENTORY_ITEM_UNJUNKED)
							end
						end
					else
						-- Stack All Items
						StackBag(BAG_BACKPACK)
					end
				end
			}
			
			KEYBIND_STRIP:UpdateKeybindButtonGroup(GAMEPAD_INVENTORY.itemFilterKeybindStripDescriptor)
		end
	end)
end

function ArchEnhancedGamepad:HookBanking()
	--local initKeybindStripOrig = GAMEPAD_BANKING.InitializeKeybindStrip
	--GAMEPAD_BANKING.InitializeKeybindStrip = function(...)
	--initKeybindStripOrig(...)
	--GAMEPAD_BANKING_FRAGMENT.Show = function()
	ZO_PreHook(GAMEPAD_BANKING_FRAGMENT, "Show", function(...)
		if (GAMEPAD_BANKING.mainKeybindStripDescriptor ~= nil) then
			GAMEPAD_BANKING.mainKeybindStripDescriptor[1] = {
				name = function()
					if (true) then
						if (GAMEPAD_BANKING.withdrawList ~= nil and GAMEPAD_BANKING.depositList ~= nil) then
							local targetData
							if (GAMEPAD_BANKING.mode == GAMEPAD_BANKING.withdrawList.mode and GAMEPAD_BANKING.withdrawList.list.active) then
								targetData = GAMEPAD_BANKING.withdrawList.list.dataList[GAMEPAD_BANKING.withdrawList.list.targetSelectedIndex]
							elseif (GAMEPAD_BANKING.mode == GAMEPAD_BANKING.depositList.mode and GAMEPAD_BANKING.depositList.list.active) then
								targetData = GAMEPAD_BANKING.depositList.list.dataList[GAMEPAD_BANKING.depositList.list.targetSelectedIndex]
							end
							
							if (targetData ~= nil) then
								local bag, index = ZO_Inventory_GetBagAndIndex(targetData)
								if (IsItemJunk(bag, index)) then
									return GetString(SI_ITEM_ACTION_UNMARK_AS_JUNK)
								end
							end
						end
						
						return GetString(SI_ITEM_ACTION_MARK_AS_JUNK)
					end
					
					return GetString(SI_ITEM_ACTION_STACK_ALL) --MISNOMER
					
					--local selectedData = GAMEPAD_BANKING.categoryList.selectedData
					--return (selectedData.filterType == ITEMFILTERTYPE_JUNK) and GetString(SI_ITEM_ACTION_UNMARK_AS_JUNK) or
					--		GetString(SI_ITEM_ACTION_MARK_AS_JUNK)
				end,
				--name = GetString(SI_ITEM_ACTION_DESTROY),
				keybind = "UI_SHORTCUT_RIGHT_STICK",
				order = 2000,
				alignment = KEYBIND_STRIP_ALIGN_RIGHT,
				disabledDuringSceneHiding = true,
				
				visible = function()
					if (true) then
						if (GAMEPAD_BANKING.withdrawList ~= nil and GAMEPAD_BANKING.depositList ~= nil) then
							--*--if self.selectedItemUniqueId ~= nil then
							local targetData
							if (GAMEPAD_BANKING.mode == GAMEPAD_BANKING.withdrawList.mode and GAMEPAD_BANKING.withdrawList.list.active) then
								targetData = GAMEPAD_BANKING.withdrawList.list.dataList[GAMEPAD_BANKING.withdrawList.list.targetSelectedIndex]
							elseif (GAMEPAD_BANKING.mode == GAMEPAD_BANKING.depositList.mode and GAMEPAD_BANKING.depositList.list.active) then
								targetData = GAMEPAD_BANKING.depositList.list.dataList[GAMEPAD_BANKING.depositList.list.targetSelectedIndex]
							end
							
							if (targetData ~= nil) then
								return IsInventorySlotLockedOrJunk(targetData)
							end
							
							--*--return ZO_InventorySlot_CanDestroyItem(targetData)
						else
							--local targetData = GAMEPAD_BANKING.itemList:GetTargetData()
							--if (targetData ~= nil) then
							--	return IsInventorySlotLockedOrJunk(targetData)
								--*--return true
							--end
						end
						
						return false
					end
					
					return true
				end,
				
				callback = function()
					if (true) then
						if (GAMEPAD_BANKING.withdrawList ~= nil and GAMEPAD_BANKING.depositList ~= nil) then
							local targetData
							if (GAMEPAD_BANKING.mode == GAMEPAD_BANKING.withdrawList.mode and GAMEPAD_BANKING.withdrawList.list.active) then
								targetData = GAMEPAD_BANKING.withdrawList.list.dataList[GAMEPAD_BANKING.withdrawList.list.targetSelectedIndex]
							elseif (GAMEPAD_BANKING.mode == GAMEPAD_BANKING.depositList.mode and GAMEPAD_BANKING.depositList.list.active) then
								targetData = GAMEPAD_BANKING.depositList.list.dataList[GAMEPAD_BANKING.depositList.list.targetSelectedIndex]
							end
							
							if (targetData ~= nil) then
								local bag, index = ZO_Inventory_GetBagAndIndex(targetData)
								local isJunk = not IsItemJunk(bag, index)
								if (not IsItemPlayerLocked(bag, index) or (IsItemPlayerLocked(bag, index) and not isJunk)) then
									SetItemIsJunk(bag, index, isJunk)
									PlaySound(isJunk and SOUNDS.INVENTORY_ITEM_JUNKED or SOUNDS.INVENTORY_ITEM_UNJUNKED)
								end
							end
						end
					else
						-- Stack All Items (replace with preview)
						StackBag(BAG_BACKPACK)
					end
				end
			}
			
			KEYBIND_STRIP:UpdateKeybindButtonGroup(GAMEPAD_BANKING.mainKeybindStripDescriptor)
		end
		
		--SCENE_MANAGER:Show(SCENE_MANAGER.scenes.gamepad_banking.name)
	end)
end

function ArchEnhancedGamepad:HookAchievements()
	if (ACHIEVEMENTS_GAMEPAD.keybindStripDescriptor ~= nil) then
		ACHIEVEMENTS_GAMEPAD.keybindStripDescriptor[6] = {
			name = function()
				return GetString(SI_ITEM_ACTION_LINK_TO_CHAT)
			end,
			keybind = "UI_SHORTCUT_LEFT_STICK",
			alignment = KEYBIND_STRIP_ALIGN_LEFT,
			callback = function()
				if ACHIEVEMENTS_GAMEPAD.recentAchievementFocus ~= nil and ACHIEVEMENTS_GAMEPAD.recentAchievementFocus.active then
					ZO_LinkHandler_InsertLink(ZO_LinkHandler_CreateChatLink(GetAchievementLink, ACHIEVEMENTS_GAMEPAD.recentAchievementFocus:GetFocusItem().control.achievementId))
				elseif ACHIEVEMENTS_GAMEPAD.chainFocus ~= nil and ACHIEVEMENTS_GAMEPAD.chainFocus.active then
					ZO_LinkHandler_InsertLink(ZO_LinkHandler_CreateChatLink(GetAchievementLink, ACHIEVEMENTS_GAMEPAD.chainFocus:GetFocusItem().control.achievementId))
				elseif ACHIEVEMENTS_GAMEPAD.itemList ~= nil and ACHIEVEMENTS_GAMEPAD.itemList.active and ACHIEVEMENTS_GAMEPAD.itemList.selectedData ~= nil then
					ZO_LinkHandler_InsertLink(ZO_LinkHandler_CreateChatLink(GetAchievementLink, ACHIEVEMENTS_GAMEPAD.itemList.selectedData.achievementId))
				end
				
			end,
			enabled = true
		}
		
		KEYBIND_STRIP:UpdateKeybindButtonGroup(ACHIEVEMENTS_GAMEPAD.keybindStripDescriptor)
	end
end

function ArchEnhancedGamepad:DefineColors()
	self.color = {}
	self.color.yellow = "|cFFFF00"
	self.color.lightYellow = "|cFFFFCC"
	self.color.green = "|c00FF00"
	self.color.magenta = "|cFF00FF"
	self.color.red = "|cFF0000"
	self.color.darkOrange = "|cFFA500"
	self.color.iconYellow = "|cFFFF33"
	self.color.iconOrange = "|cFF6600"
	self.color.grey = "|c626255"
	self.color.brightOrange = "|cE68A00"
end

function ArchEnhancedGamepad:Initialize(addonName)
	self:DefineColors()
	
	ZO_CreateStringId("SI_BINDING_NAME_ARCHGP_GUILD_HOME_SHOW", self.color.darkOrange .. "Guild|r " .. self.color.magenta .. "- Opens the keyboard version of the Guild home interface|r")
	
	ZO_CreateStringId("SI_BINDING_NAME_ARCHGP_GUILD_BANK_SHOW", self.color.darkOrange .. "Guild Bank|r " .. self.color.magenta .. "- Opens the keyboard version of the Guild Bank interface|r")
	
	ZO_CreateStringId("SI_BINDING_NAME_ARCHGP_MAIL", self.color.darkOrange .. "Mail|r " .. self.color.magenta .. "- Toggle the keyboard version of the Mail (Inbox) interface|r")

	ZO_CreateStringId("SI_BINDIANG_NAME_ARCHGP_GAME_MENU", self.color.darkOrange .. "System Game Menu|r " .. self.color.magenta .. "- Toggle system game menu|r")
	
	ZO_CreateStringId("SI_BINDING_NAME_ARCHGP_RELOAD_UI", self.color.darkOrange .. "Reload UI|r " .. self.color.magenta .. "- Yet another Reload UI binding|r")
	
	-- Gamepad item categories
	ZO_CreateStringId("SI_ARCHGP_CUSTOM_ITEM_CAT" .. ITEMTYPE_RACIAL_STYLE_MOTIF, "Crafting Motif")
	ZO_CreateStringId("SI_ARCHGP_CUSTOM_ITEM_CAT" .. ITEMTYPE_RECIPE, "Crafting Recipe")
	--ZO_CreateStringId("SI_ARCHGP_CUSTOM_ITEM_CATSURVEY", "Survey Report")

	self.name = addonName

	self.sv = {}
	
	local defaults = {
		slotActionsEnabled = false,
		achievementsLinksEnabled = true,
		inventoryMarkAsJunkEnabled = true,
		pChatCompatWorkaroundEnabled = false,
		customItemCategorizationEnabled = true
	}

	self.sv = ZO_SavedVars:NewAccountWide(self.name.."_SavedVariables", 1, nil, defaults)
	
	self:SetupOptions(self.name)
	
	--self:HookItemActions()

	if (self.sv.slotActionsEnabled) then
		self:HookSlotActions()
	end

	if (self.sv.achievementsLinksEnabled) then
		self:HookAchievements()
	end
	
	if (self.sv.inventoryMarkAsJunkEnabled) then
		self:HookInventory()
		self:HookBanking()
	end
	
	if (self.sv.pChatCompatWorkaroundEnabled) then
		zo_callLater(ZO_ARCH_ENHANCED_GP_TMP_RESIZE_CHAT, 1000)
		--zo_callLater(ZO_ARCH_ENHANCED_GP_TMP_RESIZE_CHAT, 6000)
	end
	
	if self.sv.customItemCategorizationEnabled then
		self:HookInventoryUtils()
	end
end

function ZO_ARCH_ENHANCED_GP_TMP_RESIZE_CHAT()
	--local w, h = ZO_ChatWindow:GetWidth(), ZO_ChatWindow:GetHeight()
	--ZO_ChatWindow:SetDimensions( w , h )
	if ZO_ChatWindow.container ~= nil then
		ZO_ChatWindow.container:PerformLayout()
	end
end

ARCH_ENHANCED_GAMEPAD = ArchEnhancedGamepad:New()

local function ArchEnhancedGamepad_Init(eventType, addonName)
	if addonName ~= "ArchEnhancedGamepad" then
		return
	end
	
	ARCH_ENHANCED_GAMEPAD:Initialize(addonName)
end

EVENT_MANAGER:RegisterForEvent("ArchEnhancedGamepadInit", EVENT_ADD_ON_LOADED, ArchEnhancedGamepad_Init)
