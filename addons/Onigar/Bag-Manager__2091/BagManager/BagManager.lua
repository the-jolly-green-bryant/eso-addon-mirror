--	----------------------------------------------------------------------
--	BagManager by Onigar
--	----------------------------------------------------------------------
-- This software is provided under the following CreativeCommons license,
--
-- Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
--
-- You are free to:
-- 	Share — copy and redistribute the material in any medium or format
-- 	Adapt — remix, transform, and build upon the material
--
-- The licensor cannot revoke these freedoms as long as you follow the
-- license terms.
--
-- Under the following terms:
--
-- 	Attribution — 	You must give appropriate credit, provide a link to the
-- 				  	license, and indicate if changes were made. You may do
--					so in any reasonable manner, but not in any way that 
--					suggests the licensor endorses you or your use.
--
-- 	NonCommercial — You may not use the material for commercial purposes.
--
-- 	ShareAlike — 	If you remix, transform, or build upon the material, 
--					you must distribute your contributions under the same 
--					license as the original.
--
-- 	No additional restrictions — 
--                  You may not apply legal terms or technological measures 
--                  that legally restrict others from doing anything the 
--                  license permits.
--
-- Notices:
-- You do not have to comply with the license for elements of the material in 
-- the public domain or where your use is permitted by an applicable exception 
-- or limitation.
--
-- No warranties are given. The license may not give you all of the permissions 
-- necessary for your intended use. For example, other rights such as publicity, 
-- privacy, or moral rights may limit how you use the material.
--
-- You can read the full license at,
-- https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode
--
--	----------------------------------------------------------------------
--
-- 	Description:	This module contains the functions required to manage
-- 					automatic handling of Bankable Items in your Bag allowing
--					your characters maintain a Bag reserve controlled by you.
--
--	Fixed:			Each time you visit a Bank interface, your character's
-- 					specific Bag Items will be set to your predefined amount.
--
--	Empty:		    For characters you choose to not keep in your bag any 
--					of a specific transferable item.
--
--	None:		    For characters you choose to not have any management for
--                  a specific transferable item.
--
--  Future:			check for TBD in comments
--					
--
--	----------------------------------------------------------------------

-- Addon Common Definitions
local ADDON_NAME 		= "BagManager"
local ADDON_AUTHOR 		= "Onigar"
local ADDON_WEBSITE		= "http://www.esoui.com/downloads/info1998-CurrencyManager.html#info"
local ADDON_VERSION		= "0.1.0"
-- Version = MajorVersion.MinorVersion.MiniFixes

local characterVar = {}
local charSettings = {}

-- Default Setting is to take no action allowing the User to define Currency Transfer Rules
local STRING_NONE = GetString(BM_CHAR_VAR_NONE)
local defaultCharacterVariables = {
		accountWide 				= false,
		soulGem_ItemLink 			= "|H1:item:33271:31:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h",
		soulGem_ItemId				= 33271,
		soulGem_ManType	 			= STRING_NONE,
		soulGem_FixedAmount			= 100,
		soulGemEmpty_ItemLink 		= "|H1:item:33265:30:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h",
		soulGemEmpty_ItemId			= 33265,
		soulGemEmpty_ManType		= STRING_NONE,
		soulGemEmpty_FixedAmount	= 200,
		debugOn						= false,
}


--GetBankItem(slotIndex, bagId)


local function findTargetSlotId(targetItemId, bagId)

    for slotId = 0, GetBagSize(bagId) do
	
        local itemId = GetItemId(bagId, slotId)
			
        if itemId == targetItemId then
		
			return slotId
		end
    end
end
 


-- TBD - will implement uncached solution first and then look at this
-- local bagCache = SHARED_INVENTORY:GetOrCreateBagCache(BAG_BACKPACK)
	-- --For each item in that bag
	-- for _, data in pairs(bagCache) do
		-- local bagId     = data.bagId
		-- local slotIndex = data.slotIndex
		-- --do your stuff here
	-- end
-- end

-- initial code development, can be tidied up and optimized after it is working TODO
-- then when working fine can be modified to a generic function
-- single item being used as an example; Soul Gems

local function TransferMiscellaneous()

	local depositItems			= false
	local withdrawItems			= false
    local transferAmount 		= 0
    local itemQuantity_InBag 	= 0
    local itemQuantity_InBank 	= 0

	local bagSize 				= GetBagSize(BAG_BACKPACK)
	
	for slotId = 0, bagSize do
	
		local itemId = GetItemId(BAG_BACKPACK, slotId)
		
		-- Soul Gem Management
		if  (characterVar.soulGem_ItemId == itemId) or      						-- item is found in BAG_BACKPACK
		   ((characterVar.soulGem_ItemId ~= itemId) and (slotId == bagSize)) then   -- last slot and item is not found -- may not be useful - check/test
	
			if characterVar.soulGem_ManType ~= GetString(BM_CHAR_VAR_NONE) then

				depositItems		= false
				withdrawItems		= false
				transferAmount 		= 0
				itemQuantity_InBag 	= GetSlotStackSize(BAG_BACKPACK, slotId)
				
				if characterVar.soulGem_ManType == GetString(BM_CHAR_VAR_FIXED) then
				
					if characterVar.debugOn then
						d("fixed")
						d("soulGem_FixedAmount = " .. characterVar.soulGem_FixedAmount)
						d("itemQuantity_InBag = " .. itemQuantity_InBag)
					end

					if itemQuantity_InBag > tonumber(characterVar.soulGem_FixedAmount) then
						
						if characterVar.debugOn then
							d(1)
						end
						-- calc quantity to deposit in bank
						transferAmount = itemQuantity_InBag - characterVar.soulGem_FixedAmount
						
						if characterVar.debugOn then
							d("transferAmount = " .. transferAmount)
							d("itemQuantity_InBag = " .. itemQuantity_InBag)
						end
						
						depositItems = true
						
					elseif itemQuantity_InBag < tonumber(characterVar.soulGem_FixedAmount) then
					
						if characterVar.debugOn then
							d(2)
						end
						-- calc quantity to withdraw from Bank
						transferAmount = characterVar.soulGem_FixedAmount - itemQuantity_InBag
					
						if characterVar.debugOn then
							d("transferAmount = " .. transferAmount)
							d("itemQuantity_InBag = " .. itemQuantity_InBag)
						end

						withdrawItems = true
						
					end

				else    -- soulGem_ManType == GetString(BM_CHAR_VAR_EMPTY) -- this means "All in BAG_BACKPACK to Bank"

					if characterVar.debugOn then
						d(3)
					end
					-- calc quantity to deposit in bank
					transferAmount = itemQuantity_InBag
					
					if characterVar.debugOn then
						d("transferAmount = " .. transferAmount)
						d("itemQuantity_InBag = " .. itemQuantity_InBag)
					end
					
					if transferAmount > 0 then
					
						depositItems = true
						
					end
				end

				if transferAmount > 0 then  -- there is something to do
				
					local targetBagSlot = findTargetSlotId(itemId, BAG_BANK)  -- if not found I guess it will return "nul" - need to check

					-- also need to be sure there in space in the destination Bag/or Bank -- assumed ok for now TODO later
					
					-- ZO_InventoryManager:DoesBagHaveEmptySlot(bagId) 
					
					-- ZO_InventoryManager:IsSlotOccupied(bagId, slotIndex) 
					
					-- TryPlaceInventoryItemInEmptySlot(targetBag) 
					
					if characterVar.debugOn then
						d(4)
					end
					
					-- if item not found in Bank set to first free Bank slot. If Bank is full then "nul" is returned
					if not targetBagSlot then
						targetBagSlot = FindFirstEmptySlotInBag(BAG_BANK)
					end
					
					if characterVar.debugOn then
						d(5)
						d("slotId = " .. slotId)
						d("targetBagSlot = " .. targetBagSlot)
					end
					
					if depositItems then
				
						if targetBagSlot then  -- item is found in the bank or there is an empty slot
						
							-- This function is protected and can only be used out of combat. 
							-- RequestMoveItem(number Bag sourceBag, number sourceSlot, number Bag destBag, number destSlot, number stackCount) 

							if IsProtectedFunction("RequestMoveItem") then
								CallSecureProtected("RequestMoveItem", BAG_BACKPACK, slotId, BAG_BANK, targetBagSlot, transferAmount)
							else
								RequestMoveItem(BAG_BACKPACK, slotId, BAG_BANK, targetBagSlot, transferAmount)
							end
						else
							-- item is not found and there is no empty slot
							d("need work on this no slot condition in bank")
						
						end
						
					elseif withdrawItems then
					
						if targetBagSlot then  -- item is found in the bank (not "nul" was returned)
						
							itemQuantity_InBank = GetSlotStackSize(BAG_BANK, targetBagSlot)
						
							if itemQuantity_InBank < transferAmount then
							
								-- print chat message, "only nnn amount in bank"
								d("only " .. itemQuantity_InBank .. GetString(BM_SOUL_GEMS_POST) .. " in Bank but need " .. transferAmount)

								transferAmount = itemQuantity_InBank
								
							end
						
							if IsProtectedFunction("RequestMoveItem") then
								CallSecureProtected("RequestMoveItem", BAG_BANK, targetBagSlot, BAG_BACKPACK, slotId, transferAmount)
							else
								RequestMoveItem(BAG_BANK, targetBagSlot, BAG_BACKPACK, slotId, transferAmount)
							end
						else
							-- need to withdraw but none found in Bank
							d("need to withdraw but none found in Bank")
						
						end
					end
				end
			end
		end
	end
end


local function CreateSettingsMenu()

	local LAM = LibStub("LibAddonMenu-2.0")

	local panelData = {
		type = "panel",
		-- name = the title you see in the list of addons when displayed by "Settings, Addons" 
		name = "Oni's " .. GetString(BM_ADDON_LONG_NAME),
		-- displayName = the title at the top of the addon panel
		displayName = "|c4a9300" .. GetString(BM_ADDON_LONG_NAME) .. "|r",
		author = ADDON_AUTHOR,
		version = ADDON_VERSION,
		registerForRefresh = true,
		registerForDefaults = true,
		website = ADDON_WEBSITE
	}
	LAM:RegisterAddonPanel("BagManagerPanel", panelData)

	local optionsData = {
		
		{
            type = "description",
			text = ZO_HIGHLIGHT_TEXT:Colorize(GetString(BM_ADDON_DESCRIPTION)),
            width = "full"
        },
		
		
		-- Account Wide Settings
		-- divider
        {	type = "divider", width = "full" },
		{
			type = "checkbox",
			name = GetString(BM_ACCOUNT_WIDE_TITLE),
			tooltip = GetString(BM_ACCOUNT_WIDE_TIP),
			default = defaultCharacterVariables.accountWide,
			getFunc = 	function() 
							return charSettings.byAccount.accountWide
						end,
			setFunc = 	function(value) 
							charSettings.byAccount.accountWide = value 
						end,
			requiresReload = true,
		},
		
		-- -- TBD - add expandable header for "Miscellaneous" Items
		
		-- Soul Gem Management
		-- divider
        {	type = "divider", width = "full" },
		{
			type = "dropdown",
			name = "|cffff24" .. GetString(BM_SOUL_GEMS_TITLE_PRE) .. "|r" .. GetString(BM_MAN_TYPE_POST),
			tooltip = GetString(BM_MAN_TYPE_TIP),
			default = defaultCharacterVariables.soulGem_ManType,
			choices = {GetString(BM_CHAR_VAR_FIXED), GetString(BM_CHAR_VAR_EMPTY), GetString(BM_CHAR_VAR_NONE)},
		 
			getFunc = 	function()
							return characterVar.soulGem_ManType 
						end,
			setFunc = 	function(choice)
							characterVar.soulGem_ManType = choice
						end,
		},
		{
			type = "editbox",
			name = "|cffff24" .. GetString(BM_SOUL_GEMS_TITLE_PRE) .. "|r" .. GetString(BM_FIXED_AMOUNT_POST),
			tooltip = GetString(BM_SOUL_GEMS_FIXED_AMOUNT_TIP),
			default = defaultCharacterVariables.soulGem_FixedAmount,
			
			getFunc = 	function() 
							return characterVar.soulGem_FixedAmount 
						end,
			setFunc = 	function(choice)
							characterVar.soulGem_FixedAmount = choice
						end,
		},
		
		-- Show Debug Messages
		-- divider
        {	type = "divider", width = "full" },
		{
			type = "checkbox",
			name = GetString(BM_SHOW_DEBUG_MESSAGES),
			tooltip = GetString(BM_SHOW_DEBUG_MESSAGES_TIP),
			default = defaultCharacterVariables.debugOn,
			getFunc = 	function() 
							return characterVar.debugOn
						end,
			setFunc = 	function(value) 
							characterVar.debugOn = value 
						end,
			requiresReload = true,
		},
	}
	LAM:RegisterOptionControls("BagManagerPanel", optionsData)
end


local function OnBankOpen(event, bagId)

	if IsHouseBankBag(bagId) then
		-- House Storage Coffer, it has no interface for currency transfer
		return
	else
		TransferMiscellaneous()
	end
end


local function getSettings()
	if charSettings.byAccount.accountWide then
		return charSettings.byAccount
	else
		return charSettings.byChar
	end
end


local function Initialize()
	--	Connect with Account Wide saved Variables
	--  ZO_SavedVars:NewAccountWide(savedVariableTable, version, namespace, defaults, profile, displayName) 
	charSettings.byAccount = ZO_SavedVars:NewAccountWide("BagManagerSettings", 3, nil, defaultCharacterVariables)

	--	Connect with Character Based saved Variables
	--  ZO_SavedVars:NewCharacterNameSettings(savedVariableTable, version, namespace, defaults, profile)
	--  ZO_SavedVars:NewCharacterIdSettings(savedVariableTable, version, namespace, defaults, profile)
	--  Note: 
	--  NewCharacterNameSettings saves readable char name in the addon saved var file
	--  NewCharacterIdSettings saves a numeric id instead of the char name in the addon saved var file
	charSettings.byChar = ZO_SavedVars:NewCharacterNameSettings("BagManagerSettings", 3, nil, defaultCharacterVariables)

	-- Use Character or Account Wide Settings
	characterVar = getSettings()

	--	Generate Settings Menu
	CreateSettingsMenu()

	--	Register listener(s) for event(s)
	EVENT_MANAGER:RegisterForEvent("BagManagerBankOpen", EVENT_OPEN_BANK, OnBankOpen)

	--	Cleanup:
	--	After our event has loaded, do not need to listen for further calls.
	EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

end


local function OnAddOnLoaded(event, addonLoading)
	if addonLoading == ADDON_NAME then
		Initialize()
	end
end
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
