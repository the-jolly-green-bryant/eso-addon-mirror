--Global array with all data of this addon
if NOC == nil then NOC = {} end
local NOC = NOC

--==========================================================================================================================================
--													NOC EVENT callback functions
--==========================================================================================================================================

--==============================================================================
--==================== START EVENT CALLBACK FUNCTIONS ==========================
--==============================================================================

--Inventory slot gets updated function
local function NOC_Inv_Single_Slot_Update(_, bagId, slotId, isNewItem, itemSoundCategory, updateReason)   
	--Abort if not new item is added to inventory
	if (not isNewItem) then return end

	--Only check for normal player inventory
	if (bagId == BAG_BACKPACK) then		
        local itemLink = GetItemLink(bagId, slotId)
        if itemLink ~= "" then
            -- item is a recipe
            local itemType = GetItemLinkItemType(itemLink)			
            if itemType ~= nil then
                local itemTypesToLock = NOC.checkVars.itemTypesToLock
                local lock = itemTypesToLock[itemType] or false
                if lock then
                    --Check slightly delayed if the crafted item should be marked
                    zo_callLater(function()
						FCOIS.MarkItem(bagId, slotId, 1, true, true)					
                    end, 500)
                end
            end
        end
	end 
end

--==============================================================================
--===================== END EVENT CALLBACK FUNCTIONS============================
--==============================================================================

--==============================================================================
--   ================== BEGIN AddOn's EVENT CALLBACK FUNCTIONS ==============
--==============================================================================

-- Fires each time after addons were loaded and player is ready to move (after each zone change too)
local function NOC_Player_Activated(...)
    --Prevent this event to be fired again and again upon each zone change
    EVENT_MANAGER:UnregisterForEvent(NOC.addonVars.gAddonName, EVENT_PLAYER_ACTIVATED)
end

--Addon is now loading and building up
local function NOC_Loaded(eventCode, addOnName)	
    --Is this addon found?
    if(addOnName ~= NOC.addonVars.gAddonName) then
        return
    end	
end

--==============================================================================
--   ================== END AddOn's EVENT CALLBACK FUNCTIONS ================
--==============================================================================

--Set the callback functions for the events that can happen
function NOC.setEventCallbackFunctions()
    --==================================================================================================================================================================================================
    -- EVENTs CALLBACK FUNCTIONS
    --==================================================================================================================================================================================================
    --Register the addon's loaded callback function
    EVENT_MANAGER:RegisterForEvent(NOC.addonVars.gAddonName, EVENT_ADD_ON_LOADED, NOC_Loaded)
	--Register for the zone change/player ready event
	EVENT_MANAGER:RegisterForEvent(NOC.addonVars.gAddonName, EVENT_PLAYER_ACTIVATED, NOC_Player_Activated)
	--Register for player inventory slot update
	EVENT_MANAGER:RegisterForEvent(NOC.addonVars.gAddonName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, NOC_Inv_Single_Slot_Update)      
end