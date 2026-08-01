------------------------------------------------------------------------------------------------------------------------
-- Global AlphaGear variable
------------------------------------------------------------------------------------------------------------------------
AG = AG or {}
AG.plugins = AG.plugins or {}

------------------------------------------------------------------------------------------------------------------------
-- Description
------------------------------------------------------------------------------------------------------------------------
--Integration/Plugin coding for FCOItemSaver addon.
--> Download the addon here: https://www.esoui.com/downloads/info630-FCOItemSaver.html
--> Author of this code here: Baertram
---> API functions of FCOIS, check /AddOns/FCOItemSaver/FCOIS_API.lua
---> Used function to mark an item in the inventory of the currently logged in character:
-----> FCOIS.MarkItem(bag, slot, iconId, showIcon, updateInventories)
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- Global variables
------------------------------------------------------------------------------------------------------------------------
AG.plugins.FCOIS = AG.plugins.FCOIS or {}

-- FCOIS_CON_ICON_LOCK = 1 -- defined as global constant in FCOIS
local FCOIS_CON_ICON_NONE = 0

------------------------------------------------------------------------------------------------------------------------
-- Local variables
------------------------------------------------------------------------------------------------------------------------
--Local "speed up" variables
local AGplugFCOIS = AG.plugins.FCOIS
local isAddonReady = AGplugFCOIS.isAddonReady

------------------------------------------------------------------------------------------------------------------------
-- Functions
------------------------------------------------------------------------------------------------------------------------
--Check if the addon FCOItemSaver is enabled and if the functions to mark items in the inventory are given
function AGplugFCOIS.isAddonReady()
    return (FCOIS ~= nil and FCOIS.MarkItem ~= nil) or false
end

--Check if the setting to mark inventory set parts with the FCOIS marker icons is enabled
function AGplugFCOIS.isFCOISMarkerIconsEnabled()
    local optionsSV = AG.account.option
    return optionsSV[AG_OPTION_USE_FCOIS_MARKER_ICONS]
end

-- sets a marker to an item for each build it belongs to
function AGplugFCOIS.setItemMarker(bagId, slotIndex, buildIds, updateInventory)
	if #buildIds == 0 then return end
    updateInventory = updateInventory or false


    for buildIndex = 1, #buildIds do
		local setDataSet = setData[buildIndex].Set

		local gearIconId = FCOIS_CON_ICON_LOCK
		if setDataSet["FCOIS"] ~= nil and setDataSet["FCOIS"]["icon"] ~= nil then gearIconId = setDataSet["FCOIS"]["icon"] end
		
		if gearIconId ~= FCOIS_CON_ICON_NONE then
			FCOIS.MarkItem(bagId, slotIndex, gearIconId, true, updateInventory)
		end
	end
end

-- called when an item is added to a build
--  * item belongs to a gear-set which is assigned to the build
--  * item is added to the gear-set which is assigned to a build
function AGplugFCOIS.onAddItemToBuild()
end

-- called when an item is removed from a build
--  * item belongs to a gear-set which is unassigned from the build
--  * item is removed from the gear-set which is assigned to a build
function AGplugFCOIS.onRemoveItemFromBuild()
end


-- called when the icon for a build was changed
-- set data still contains the old IconId
function AGplugFCOIS.onChangeBuildIcon(usageMap, buildId, oldIconId, newIconId)
	-- gather items from build
	local agModel = AG.setdata
    local build = agModel[buildId].Set
    local gearSetId = build.gear
	if gearSetId == 0 then return end
	
	local gearSet = agModel[gearSetId].Gear
	
	-- ignore poison slots
	for slot = 1, 14 do
		local item = gearSet[slot]
			
		if item.id ~= 0 then
			-- must be at least in this build
			local buildIds = usageMap[item.id]
			local removeOldIcon = oldIconId ~= FCOIS_CON_ICON_NONE
			local addNewIcon =  newIconId ~= FCOIS_CON_ICON_NONE

			-- if the item was in more than one build, it might be that old and new icon aren't affected
			if #buildIds > 1 then
				for _,otherBuildId in pairs(buildIds) do
					if otherBuildId ~= buildId then
						-- get iconid from other build.
						local otherBuild = agModel[otherBuildId].Set
					    
						if otherBuild["FCOIS"] ~= nil and otherBuild["FCOIS"]["icon"] ~= nil then 
							local otherIconId = otherBuild["FCOIS"]["icon"]
							
							-- if the other icon is the same as the old icon, it must remain 
							if otherIconId == oldIconId then
								removeOldIcon = false
							end
							
							-- if the other icon is the same as the new icon, it must not be added 
							if otherIconId == newIconId then
								addNewIcon = false
							end
						end
					end
					
					if not addNewIcon and not removeOldIcon then
						-- shortcut
						break
					end
				end
			end

			if removeOldIcon or addNewIcon then
				local bagId, slotIndex = AG.GetItemFromBag(item.id)
				
				if bagId then
					if removeOldIcon then
						FCOIS.MarkItem(bagId, slotIndex, oldIconId, false, false)
					end

					if addNewIcon then
						FCOIS.MarkItem(bagId, slotIndex, newIconId, true, false)
					end
				end
			end
		end
	end
end




--Mark the inventory control with the chosen FCOIS marker icon for the given set now
-- buildIds contains the ids of the builds, which use this item
function AGplugFCOIS.markInventoryItem(invControl, showIcon, updateInventory, buildIds)
    if not invControl or not AGplugFCOIS.isAddonReady() then return end
    updateInventory = updateInventory or false
    local invItemData = invControl.dataEntry.data or invControl.data
    if not invItemData then return end

	-- first phase: remove all markers which were triggerd by AG and then removed
	
	
	-- second phase: add all markers which are triggerd by AG
    local gearIconId = FCOIS_CON_ICON_LOCK
    if setDataSet["FCOIS"] ~= nil and setDataSet["FCOIS"]["icon"] ~= nil then gearIconId = setDataSet["FCOIS"]["icon"] end
	
	

    local bagId, slotIndex = invItemData.bagId, invItemData.slotIndex
    if bagId == nil or slotIndex == nil then return end
    --Check if the item is a set item from one of the AlphaGear gear sets
    local uid = Id64ToString(GetItemUniqueId(bagId, slotIndex))
    if not uid then return end
    local setData = AG.setdata
    for nr = 1, AG.MAXSLOT do
        local setDataSet = setData[nr].Set
        local gearSet = setDataSet.gear
        if gearSet > 0 then
            for equipSlot = 1, 14 do
                if setData[gearSet].Gear[equipSlot].id == uid then
                    local gearIconId = FCOIS_CON_ICON_LOCK
                    if setDataSet["FCOIS"] ~= nil and setDataSet["FCOIS"]["icon"] ~= nil then gearIconId = setDataSet["FCOIS"]["icon"] end

                    --Remove older marker icons which got changed
                    local removeWasDone = false

                    if setDataSet["FCOIS"] and setDataSet["FCOIS"]["iconRemove"] then
                        local removeOldFCOISMarkerIconsTable = setDataSet["FCOIS"]["iconRemove"]
                        if removeOldFCOISMarkerIconsTable ~= nil then
                           --Check each entry in the list and remove the icon for the entry
                            for oldFCOISmarkerIconId, removeNow in pairs(removeOldFCOISMarkerIconsTable) do
                                if removeNow and oldFCOISmarkerIconId ~= nil and oldFCOISmarkerIconId ~= 0 then
                                    --Unmark the old marker icon now
                                    FCOIS.MarkItem(invItemData.bagId, invItemData.slotIndex, oldFCOISmarkerIconId, false, false)
                                    setDataSet["FCOIS"]["iconRemove"][oldFCOISmarkerIconId] = nil
                                    removeWasDone = true
                                end
                            end
                        end
                    end
					
                    if gearIconId ~= nil and gearIconId ~= 0 then
                        --Mark/Unmark the currently selected marker icon now
                        FCOIS.MarkItem(invItemData.bagId, invItemData.slotIndex, gearIconId, showIcon, updateInventory)
                    else
                        --Update the inventory list now
                        if removeWasDone then
                            AGplugFCOIS.updateInventoryList()
                        end
                    end
					
                    return
                end
            end
        end
    end
end

--Update the shown items in the inventory list so that the marker icons will be shown/hidden properly
function AGplugFCOIS.updateInventoryList()
    if not AGplugFCOIS.isAddonReady() then return end
    FCOIS.FilterBasics(false)
end

--Get the list of marker icons defined as gear sets (5 static ones + n dyanmic ones) from FCOIS.
--Parameter: String "listType" specifies the type of list to build:
--> ListType can be one of the following one:
---> standard: A list with the marker icons, using the name from the settings, including the icon as texture (if "withIcons" = true) and disabled icons are marked red.
---> standardNonDisabled: A list with the marker icons, using the name from the settings, including the icon as texture (if "withIcons" = true) and disabled icons are not marked in any other way then enabled ones.
---> keybinds: A list with the marker icons, using the fixed name from the translations, including the icon as texture (if "withIcons" = true) and disabled icons are marked red.
---> gearSets: A list with only the gear set marker icons, using the name from the settings, including the icon as texture (if "withIcons" = true) and disabled icons are marked red.
-->Returns a table with the FCOIS marker icon ID as key and a String "name + small icon (depending on parameter "listType") as value
-- and a 2nd table with the marker icon ID as key and their marker icon ID as value as well.
--> The two tables are used for a LAM dropdown box normally.
function AGplugFCOIS.getFCOISGearSetMarkerIconsList()
    local gearMarkerIconsList, gearMarkerIconsValuesList = FCOIS.GetLAMMarkerIconsDropdown("gearSets", true)
    return gearMarkerIconsList, gearMarkerIconsValuesList
end

--[[
14:40:54] user:/AddOns/AlphaGear/plugins/FCOIS/ag_fcois.lua:65: attempt to index a nil value
stack traceback:
user:/AddOns/AlphaGear/plugins/FCOIS/ag_fcois.lua:65: in function 'AGplugFCOIS.markInventoryItem'
<Locals> invControl = ud, showIcon = true, updateInventory = true, invItemData = tbl, bagId = 1, slotIndex = 28, uid = 22997027310, setData = tbl, nr = 1, setDataSet = tbl, gearSet = 1, equipSlot = 8, gearIconId = 1 </Locals>
user:/AddOns/AlphaGear/AlphaGear.lua:1849: in function 'existingCallbackFunction'
<Locals> c = ud, slot = tbl, updateFCOISInv = false, isFCOISAddonReady = true, isFCOISMarkerIconsEnabled = true, markGearWithAG = false, markGearWithFCOIS = true, markGearWithAGAndOrFCOIS = true </Locals>
user:/AddOns/CraftingMaterialLevelDisplay/InventoryHooks.lua:219: in function 'puffer'
<Locals> rowControl = ud, slot = tbl </Locals>
user:/AddOns/CraftStoreFixedAndImproved/CraftStore.lua:815: in function '(anonymous)'
<Locals> control = ud, slot = tbl </Locals>
user:/AddOns/SousChef/Common.lua:42: in function 'setupCallback'
<Locals> rowControl = ud, slot = tbl </Locals>
EsoUI/Libraries/ZO_Templates/ScrollTemplates.lua:2210: in function 'ZO_ScrollList_UpdateScroll'
<Locals> self = ud, windowHeight = 739, activeControls = tbl, offset = 0, IS_REAL_NUMBER = false, activeIndex = 1, numActive = 0, firstInViewIndex = 1, data = tbl, visibleData = tbl, mode = 1, nextCandidateIndex = 2, visibleDataIndex = 2, dataEntry = tbl, bottomEdge = 739, controlTop = 42, uniformControlHeight = 42, dataType = tbl, controlPool = tbl, control = ud </Locals>
(tail call): ?
(tail call): ?
EsoUI/Libraries/ZO_Templates/ScrollTemplates.lua:1966: in function 'ZO_ScrollList_Commit'
<Locals> self = ud, windowHeight = 739, scrollableDistance = -529, foundSelected = false, numData = 5, i = 0 </Locals>
EsoUI/Ingame/Inventory/Inventory.lua:1061: in function 'ZO_InventoryManager:ApplySort'
<Locals> self = tbl, inventoryType = 1, inventory = tbl, list = ud, scrollData = tbl </Locals>
(tail call): ?
EsoUI/Ingame/Inventory/Inventory.lua:1470: in function 'ZO_InventoryManager:UpdateList'
<Locals> self = tbl, inventoryType = 1, inventory = tbl, list = ud, scrollData = tbl </Locals>
EsoUI/Ingame/Inventory/Inventory.lua:1156: in function 'ZO_InventoryManager:ChangeFilter'
<Locals> self = tbl, filterTab = tbl, inventoryType = 1, inventory = tbl, activeTabText = "Rüstungen", displayInventory = tbl, activeTabControl = ud, sortHeaders = tbl </Locals>
(tail call): ?
EsoUI/Ingame/Inventory/Inventory.lua:49: in function 'HandleTabSwitch'
<Locals> tabData = tbl </Locals>
EsoUI/Libraries/ZO_MenuBar/ZO_MenuBar.lua:284: in function 'MenuBarButton:Release'
<Locals> self = tbl, upInside = true, skipAnimation = false, playerDriven = true, buttonData = tbl </Locals>
EsoUI/Libraries/ZO_MenuBar/ZO_MenuBar.lua:636: in function 'ZO_MenuBarButtonTemplate_OnMouseUp'
<Locals> self = ud, button = 1, upInside = true </Locals>
ZO_MainMenuCategoryBarButton1_MouseUp:3: in function '(main chunk)'
<Locals> self = ud, button = 1, upInside = true, ctrl = false, alt = false, shift = false, command = false </Locals>
[14:40:54] user:/AddOns/AlphaGear/plugins/FCOIS/ag_fcois.lua:65: attempt to index a nil value
stack traceback:
user:/AddOns/AlphaGear/plugins/FCOIS/ag_fcois.lua:65: in function 'AGplugFCOIS.markInventoryItem'
<Locals> invControl = ud, showIcon = true, updateInventory = true, invItemData = tbl, bagId = 1, slotIndex = 28, uid = 22997027310, setData = tbl, nr = 1, setDataSet = tbl, gearSet = 1, equipSlot = 8, gearIconId = 1 </Locals>
user:/AddOns/AlphaGear/AlphaGear.lua:1849: in function 'existingCallbackFunction'
<Locals> c = ud, slot = tbl, updateFCOISInv = false, isFCOISAddonReady = true, isFCOISMarkerIconsEnabled = true, markGearWithAG = false, markGearWithFCOIS = true, markGearWithAGAndOrFCOIS = true </Locals>
user:/AddOns/CraftingMaterialLevelDisplay/InventoryHooks.lua:219: in function 'puffer'
<Locals> rowControl = ud, slot = tbl </Locals>
user:/AddOns/CraftStoreFixedAndImproved/CraftStore.lua:815: in function '(anonymous)'
<Locals> control = ud, slot = tbl </Locals>
user:/AddOns/SousChef/Common.lua:42: in function 'setupCallback'
<Locals> rowControl = ud, slot = tbl </Locals>
EsoUI/Libraries/ZO_Templates/ScrollTemplates.lua:2210: in function 'ZO_ScrollList_UpdateScroll'
<Locals> self = ud, windowHeight = 739, activeControls = tbl, offset = 0, IS_REAL_NUMBER = false, activeIndex = 1, numActive = 0, firstInViewIndex = 1, data = tbl, visibleData = tbl, mode = 1, nextCandidateIndex = 2, visibleDataIndex = 2, dataEntry = tbl, bottomEdge = 739, controlTop = 42, uniformControlHeight = 42, dataType = tbl, controlPool = tbl, control = ud </Locals>
(tail call): ?
(tail call): ?
EsoUI/Libraries/ZO_Templates/ScrollTemplates.lua:1966: in function 'ZO_ScrollList_Commit'
<Locals> self = ud, windowHeight = 739, scrollableDistance = -529, foundSelected = false, numData = 5, i = 0 </Locals>
EsoUI/Ingame/Inventory/Inventory.lua:1061: in function 'ZO_InventoryManager:ApplySort'
<Locals> self = tbl, inventoryType = 1, inventory = tbl, list = ud, scrollData = tbl </Locals>
(tail call): ?
EsoUI/Ingame/Inventory/Inventory.lua:1470: in function 'ZO_InventoryManager:UpdateList'
<Locals> self = tbl, inventoryType = 1, inventory = tbl, list = ud, scrollData = tbl </Locals>
user:/AddOns/AdvancedFilters/lib/LibFilters-2.0/LibFilters-2.0.lua:131: in function 'SafeUpdateList'
<Locals> object = tbl, isMouseVisible = false </Locals>
user:/AddOns/AdvancedFilters/lib/LibFilters-2.0/LibFilters-2.0.lua:138: in function '(anonymous)'
user:/AddOns/AdvancedFilters/lib/LibFilters-2.0/LibFilters-2.0.lua:362: in function 'Update'
[14:40:56] [AF]PLAY
 ]]