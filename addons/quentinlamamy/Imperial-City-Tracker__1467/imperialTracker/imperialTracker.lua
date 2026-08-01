-- Main Addon File
-- @author    : Quentin Lamamy <contact@quentin-lamamy.fr>
-- @lastModif : 2016/08/30

-- Addon Namespace
imperialTrackerAddon = {}
 
-- Addon vars
imperialTrackerAddon.name    = "imperialTracker"
imperialTrackerAddon.version = 1

-- Items vars
imperialTrackerAddon.item                 = {}
imperialTrackerAddon.item.tinyClaw        = "|H1:item:64573:123:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
imperialTrackerAddon.item.planarArmor     = "|H1:item:64575:123:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
imperialTrackerAddon.item.bonesHard       = "|H1:item:64487:123:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
imperialTrackerAddon.item.darkEther       = "|H1:item:64567:123:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
imperialTrackerAddon.item.markOfTheLegion = "|H1:item:64569:123:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
imperialTrackerAddon.item.tooth           = "|H1:item:64571:123:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"

-- Addon functions

-- @namespace : imperialTrackerAddon
-- @name      : onPlayerActivated
-- @desc      : Called when EVENT_PLAYER_ACTIVATED is raised to apply the good display according to the map zone and update the ui
function imperialTrackerAddon:onPlayerActivated()
    imperialTrackerAddon:setDisplay()
    imperialTrackerAddon:updateUI()
end

-- @namespace : imperialTrakcerAddon
-- @name      : processInventoryData
-- @desc      : proces inventory and bank data to get the real count of an item
-- @arg       : <string> the item link of the item
-- @return    : <int>    the item count
function imperialTrackerAddon:processInventoryData(itemLink)
    local itemInventory, itemBank, itemCraft = GetItemLinkStacks(itemLink)
    local total = itemInventory + itemBank
    return total
end

-- @namespace : imperialTrackerAddon
-- @name      : setDisplay
-- @desc      : show or hide  the addon bar according to player map zone (impterial city or not)
-- @return    : <boolean> true if displayed or false if not
function imperialTrackerAddon:setDisplay()
    if IsInImperialCity() then
        imperialTrackerAddon:show()
        return false
    else
        imperialTrackerAddon:hide()
        return true
    end    
end

-- @namespace : imperialTrackerAddon
-- @name      : updateUI
-- @desc      : update the addon ui
function imperialTrackerAddon:updateUI()
    imperialTrackerAddon:updateStacksNumber()
end

-- @namespace : imperialTrackerAddon
-- @name      : updateStackNumber
-- @desc      : update each item count in the addon bar
function imperialTrackerAddon:updateStacksNumber()

    -- Tiny Claw
    local clawNumber   = imperialTrackerAddon:processInventoryData(imperialTrackerAddon.item.tinyClaw)
    imperialTrackerAddonContainerClawLabel:SetText(clawNumber)
    imperialTrackerAddonContainerClawLabel:SetColor(clawNumber < 60 and 1 or 0,clawNumber < 60 and 1 or 255,clawNumber < 60 and 1 or 0)

    -- Planar Armor
    local planarNumber = imperialTrackerAddon:processInventoryData(imperialTrackerAddon.item.planarArmor)
    imperialTrackerAddonContainerArmorLabel:SetText(planarNumber)
    imperialTrackerAddonContainerArmorLabel:SetColor(planarNumber < 60 and 1 or 0,planarNumber < 60 and 1 or 255,planarNumber < 60 and 1 or 0)

    -- Bones Hard
    local bonesNumber  = imperialTrackerAddon:processInventoryData(imperialTrackerAddon.item.bonesHard)
    imperialTrackerAddonContainerBonesLabel:SetText(bonesNumber)
    imperialTrackerAddonContainerBonesLabel:SetColor(bonesNumber < 60 and 1 or 0,bonesNumber < 60 and 1 or 255,bonesNumber < 60 and 1 or 0)    

    -- Dark Ether
    local etherNumber  = imperialTrackerAddon:processInventoryData(imperialTrackerAddon.item.darkEther)
    imperialTrackerAddonContainerEtherLabel:SetText(etherNumber)
    imperialTrackerAddonContainerEtherLabel:SetColor(etherNumber < 60 and 1 or 0,etherNumber < 60 and 1 or 255,etherNumber < 60 and 1 or 0)  

    -- Mark Of The Legion
    local legionNumber = imperialTrackerAddon:processInventoryData(imperialTrackerAddon.item.markOfTheLegion)
    imperialTrackerAddonContainerLegionLabel:SetText(legionNumber)
    imperialTrackerAddonContainerLegionLabel:SetColor(legionNumber < 60 and 1 or 0,legionNumber < 60 and 1 or 255,legionNumber < 60 and 1 or 0)  

    -- Tooth
    local toothNumber  = imperialTrackerAddon:processInventoryData(imperialTrackerAddon.item.tooth)
    imperialTrackerAddonContainerToothLabel:SetText(toothNumber)   
    imperialTrackerAddonContainerToothLabel:SetColor(toothNumber < 60 and 1 or 0,toothNumber < 60 and 1 or 255,toothNumber < 60 and 1 or 0)  
end

-- @namespace : imperialTrackerAddon
-- @name      : show
-- @desc show addon bar
function imperialTrackerAddon:show()
    imperialTrackerAddonContainer:SetHidden(false)
end

-- @namespace : imperialTrackerAddon
-- @name      : hide
-- @desc      : hide adddon bar
function imperialTrackerAddon:hide()
    imperialTrackerAddonContainer:SetHidden(true)
end

-- Event registration
EVENT_MANAGER:RegisterForEvent(imperialTrackerAddon.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE,  imperialTrackerAddon.updateUI)
EVENT_MANAGER:RegisterForEvent(imperialTrackerAddon.name, EVENT_PLAYER_ACTIVATED,              imperialTrackerAddon.onPlayerActivated)