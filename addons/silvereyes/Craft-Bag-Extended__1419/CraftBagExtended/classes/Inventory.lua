local cbe       = CraftBagExtended
local util      = cbe.utility
local class     = cbe.classes
local name      = cbe.name .. "Inventory"
class.Inventory = class.Module:Subclass()

function class.Inventory:New(...)        
    local instance = class.Module.New(self, name, "inventory")
    instance:Setup()
    return instance
end

function class.Inventory:Setup()
    self.debug = false
    self.retrieveQueue = util.GetTransferQueue( BAG_VIRTUAL, BAG_BACKPACK )
    self.stowQueue = util.GetTransferQueue( BAG_BACKPACK, BAG_VIRTUAL )
end

--[[ Adds normal inventory screen crafting bag slot actions ]]
function class.Inventory:AddSlotActions(slotInfo)
    local slotIndex = slotInfo.slotIndex
    local isShown = self:IsSceneShown()
    if slotInfo.bag == BAG_BACKPACK and cbe.hasCraftBagAccess
       and CanItemBeVirtual(slotInfo.bag, slotIndex) 
       and not IsItemStolen(slotInfo.bag, slotIndex)
       and not slotInfo.slotData.locked
       and slotInfo.slotType == SLOT_TYPE_ITEM
    then
        
        --[[ Stow ]]--
        table.insert(slotInfo.slotActions, {
            SI_ITEM_ACTION_ADD_ITEMS_TO_CRAFT_BAG,  
            function() cbe:Stow(slotIndex) end,
            (isShown and "primary") or "secondary"
        })
        --[[ Stow quantity ]]--
        -- Note the lack of a "keybind4" assignment. This is to avoid conflicts
        -- with the actual quickslot keybind from the inventory panel.
        table.insert(slotInfo.slotActions, {
            SI_CBE_CRAFTBAG_STOW_QUANTITY,  
            function() cbe:StowDialog(slotIndex) end,
            "secondary"
        })
        
    elseif slotInfo.bag == BAG_VIRTUAL then
        --[[ Retrieve ]]--
        table.insert(slotInfo.slotActions, {
            SI_ITEM_ACTION_REMOVE_ITEMS_FROM_CRAFT_BAG,  
            function()
                cbe.noAutoReturn = true
                cbe:Retrieve(slotIndex) 
            end,
            (isShown and "primary") or "secondary"
        })
        --[[ Retrieve quantity ]]--
        table.insert(slotInfo.slotActions, {
            SI_CBE_CRAFTBAG_RETRIEVE_QUANTITY,  
            function() 
                cbe.noAutoReturn = true
                cbe:RetrieveDialog(slotIndex)
            end,
            (isShown and "keybind4") or "secondary"
        })

    end
end