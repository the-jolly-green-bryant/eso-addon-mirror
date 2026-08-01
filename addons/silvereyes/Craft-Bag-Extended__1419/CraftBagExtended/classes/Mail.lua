local cbe   = CraftBagExtended
local util  = cbe.utility
local class = cbe.classes
class.Mail  = class.Module:Subclass()

local name = cbe.name .. "Mail"
local debug = false
local mailAttachedTransferItems = {}

function class.Mail:New(...)
    local instance = class.Module.New(self, 
        name, "mailSend", ZO_MailSend, BACKPACK_MAIL_LAYOUT_FRAGMENT)
    instance:Setup()
    return instance
end

local function OnMailAttachmentAdded(eventCode, attachmentSlotIndex)

    -- Dequeue the waiting transfer item
    local slotIndex = select(2, GetQueuedItemAttachmentInfo(attachmentSlotIndex))
    local transferQueue = util.GetTransferQueue(BAG_VIRTUAL, BAG_BACKPACK)
    local transferItem = transferQueue:Dequeue( slotIndex )
    
    -- Remember the item, so that we can know the slot index when removed
    mailAttachedTransferItems[attachmentSlotIndex] = transferItem
    
    -- Raise any pending callbacks
    if transferItem then
        transferItem:ExecuteCallback(slotIndex)
    end
end

local function OnMailAttachmentRemoved(eventCode, attachmentSlotIndex)
    
    -- Update the keybind strip command
    util.RefreshMouseOverSlot()
    
    -- Callback that the detachment succeeded
    local removed = mailAttachedTransferItems[attachmentSlotIndex]
    if not removed then
        return
    end
    
    -- Look up the slot index from the previous attached transfer item 
    -- and then forget it
    local slotIndex = removed.targetSlotIndex
    local quantity = removed.quantity
    mailAttachedTransferItems[attachmentSlotIndex] = nil
    
    -- Run any callbacks that were passed in by the cbe:MailDetach() method
    local callback
    if removed.callback then
        removed:ExecuteCallback(slotIndex)
        callback = removed.callback
    end
        
    -- Transfer mats back to craft bag
    cbe:Stow(slotIndex, quantity, callback)
end

function class.Mail:Setup()
    self.menu:SetAnchor(TOPRIGHT, ZO_MailSend, TOPLEFT, ZO_MailSendTo:GetWidth(), 22)
    self.attachedTransferItems = mailAttachedTransferItems
    
    -- Listen for mail attachment updates so that callbacks can be raised and
    -- mats can be returned to the craft bag.
    EVENT_MANAGER:RegisterForEvent(self.name, 
        EVENT_MAIL_ATTACHMENT_ADDED,
        OnMailAttachmentAdded)
    EVENT_MANAGER:RegisterForEvent(self.name, 
        EVENT_MAIL_ATTACHMENT_REMOVED,
        OnMailAttachmentRemoved)
end

--[[ Returns true if the mail send interface is currently open. Otherwise returns false. ]]
local function IsSendingMail()
    if MAIL_SEND and not MAIL_SEND:IsHidden() then
        return true
    elseif MAIL_MANAGER_GAMEPAD and MAIL_MANAGER_GAMEPAD:GetSend():IsAttachingItems() then
        return true
    end
    return false
end

--[[ Returns the index of the attachment slot that's bound to a given inventory slot, 
     or nil if it's not attached. ]]
local function GetAttachmentSlotIndex(bag, slotIndex)
    if (bag) then
        for i = 1, MAIL_MAX_ATTACHED_ITEMS do
            local bagId, attachmentIndex = GetQueuedItemAttachmentInfo(i)
            if bagId == bag and attachmentIndex == slotIndex then
                return i
            end
        end
    end
end

local function GetNextEmptyMailAttachmentIndex()
    for i = 1, MAIL_MAX_ATTACHED_ITEMS do
        local queuedFromBag = GetQueuedItemAttachmentInfo(i)
        if queuedFromBag == 0 then
            return i
        end
    end
end

--[[ Returns true if a given inventory slot is attached to the sending mail. 
     Otherwise, returns false. ]]
local function IsAttached(bag, slotIndex)
    local attachmentSlotIndex = GetAttachmentSlotIndex(bag, slotIndex)
    if attachmentSlotIndex then
        return GetQueuedItemAttachmentInfo(attachmentSlotIndex) ~= 0
    end
end

--[[ Called after a Retrieve operation successfully retrieves a craft bag item 
     to the backpack. Responsible for executing the "Add to Mail" part of the operation. ]]
local function RetrieveCallback(transferItem)

    if not IsSendingMail() then return end
    
    local errorStringId = nil
    
    -- Find the first empty attachment slot
    local emptyAttachmentSlotIndex = GetNextEmptyMailAttachmentIndex()
    
    -- There were no empty attachment slots left
    if not emptyAttachmentSlotIndex then
        errorStringId = SI_MAIL_ATTACHMENTS_FULL
    
    -- Empty attachment slot found.
    else
        -- Attempt the attachment
        transferItem:Requeue()
        local result = QueueItemAttachment(transferItem.targetBag, transferItem.targetSlotIndex, emptyAttachmentSlotIndex)

        -- Assign error messages to different results
        if(result == MAIL_ATTACHMENT_RESULT_ALREADY_ATTACHED) then
            errorStringId = SI_MAIL_ALREADY_ATTACHED
        elseif(result == MAIL_ATTACHMENT_RESULT_BOUND) then
            errorStringId = SI_MAIL_BOUND
        elseif(result == MAIL_ATTACHMENT_RESULT_ITEM_NOT_FOUND) then
            errorStringId = SI_MAIL_ITEM_NOT_FOUND
        elseif(result == MAIL_ATTACHMENT_RESULT_LOCKED) then
            errorStringId = SI_MAIL_LOCKED
        elseif(result == MAIL_ATTACHMENT_RESULT_STOLEN) then
            errorStringId = SI_STOLEN_ITEM_CANNOT_MAIL_MESSAGE
        end
    end
    
    -- If there is an error adding the attachment, output it as an alert and return the mats
    -- back to the craft bag.
    if errorStringId then
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, GetString(errorStringId))
        -- undo the enqueue
        transferItem:Dequeue()
        -- send the mats back to the craft bag
        cbe:Stow(transferItem.targetSlotIndex)
        return
    end
end

local function ValidateCanAttach()
    -- Find the first empty attachment slot
    local emptyAttachmentSlotIndex = GetNextEmptyMailAttachmentIndex()
    
    -- There were no empty attachment slots left
    if not emptyAttachmentSlotIndex then
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, GetString(SI_MAIL_ATTACHMENTS_FULL))
        return false
    end
    
    -- Don't transfer if you don't have a free proxy slot in your backpack
    if util.GetSlotsAvailable(INVENTORY_BACKPACK) < 1 then
        ZO_AlertEvent(EVENT_INVENTORY_IS_FULL, 1, 0)
        return false
    end
    
    return true
end

--[[ Adds mail-specific inventory slot crafting bag actions ]]
function class.Mail:AddSlotActions(slotInfo)
    
    if not IsSendingMail() then return end
    
    local slotIndex = slotInfo.slotIndex
    
    -- For attachment slots, check the actual entry slot for the fromCraftBag flag
    if slotInfo.slotType == SLOT_TYPE_MAIL_QUEUED_ATTACHMENT then
        local inventoryType = PLAYER_INVENTORY.bagToInventoryType[slotInfo.bag]
        local slots = PLAYER_INVENTORY.inventories[inventoryType].slots[slotInfo.bag]
        local slot = slots[slotIndex]
        slotInfo.fromCraftBag = slot and slot.fromCraftBag
    end
    
    if IsAttached(slotInfo.bag, slotIndex) then
        if slotInfo.fromCraftBag then
            --[[ Remove from Mail ]]
            table.insert(slotInfo.slotActions, {
                SI_ITEM_ACTION_MAIL_DETACH, 
                function() cbe:MailDetach(slotIndex) end, 
                "primary"
            })
        end
        
    elseif slotInfo.slotType == SLOT_TYPE_CRAFT_BAG_ITEM then
        --[[ Add to Mail ]]
        table.insert(slotInfo.slotActions, {
            SI_ITEM_ACTION_MAIL_ATTACH, 
            function() cbe:MailAttach(slotIndex) end, 
            "primary"
        })
        --[[ Add Quantity ]]
        table.insert(slotInfo.slotActions, {
            SI_CBE_CRAFTBAG_MAIL_ATTACH, 
            function() cbe:MailAttachDialog(slotIndex) end, 
            "keybind4"
        })
    end
end

--[[ Retrieves a given quantity of mats from a given craft bag slot index, 
     and then automatically attaches the stack onto the pending mail.
     If quantity is nil, then the max stack is deposited.
     If no attachment slots remain an alert is raised and no mats leave the craft bag.
     An optional callback can be raised both when the mats arrive in the backpack
     and/or when they have been attached. ]]
function class.Mail:Attach(slotIndex, quantity, backpackCallback, attachedCallback)
    if not ValidateCanAttach() then return false end
    local callback = { util.WrapFunctions(backpackCallback, RetrieveCallback) }
    table.insert(callback, attachedCallback)
    return cbe:Retrieve(slotIndex, quantity, callback)
end

--[[ Opens a retrieve dialog for a given craft bag slot index, 
     and then automatically attaches the selected quantity onto pending mail.
     If no attachment slots remain an alert is raised and no dialog is shown.
     An optional callback can be raised both when the mats arrive in the backpack
     and/or when they have been attached. ]]
function class.Mail:AttachDialog(slotIndex, backpackCallback, attachedCallback)
    if not ValidateCanAttach() then return false end
    local callback = { util.WrapFunctions(backpackCallback, RetrieveCallback) }
    table.insert(callback, attachedCallback)
    return cbe:RetrieveDialog(slotIndex, SI_CBE_CRAFTBAG_MAIL_ATTACH, SI_ITEM_ACTION_MAIL_ATTACH, callback)
end

--[[ Detaches the stack at the given backpack slot index and returns it to the
     craft bag.  If the stack is not attached, returns false.  Optionally
     raises a callback after the stack is detached and/or after the stack is
     returned to the craft bag. ]]
function class.Mail:Detach(slotIndex, detachedCallback, stowedCallback)

    local attachmentSlotIndex = 
        GetAttachmentSlotIndex(BAG_BACKPACK, slotIndex)
    if not attachmentSlotIndex then
        return false
    end
    
    if stowedCallback and not detachedCallback then
        detachedCallback = 1
    end
    local callback = { detachedCallback, stowedCallback }
    
    if not mailAttachedTransferItems[attachmentSlotIndex]  then
        local transferQueue = util.GetTransferQueue(BAG_VIRTUAL, BAG_BACKPACK)
        local transferItem = 
            class.TransferItem:New(transferQueue, GetItemId(BAG_BACKPACK, slotIndex), 
                                   GetSlotStackSize(BAG_BACKPACK, slotIndex), 
                                   callback)
        transferItem.targetSlotIndex = slotIndex
        transferItem.location = cbe.constants.LOCATION.TARGET_BAG
        mailAttachedTransferItems[attachmentSlotIndex] = transferItem
    else
        mailAttachedTransferItems[attachmentSlotIndex].callback = callback
    end
    
    RemoveQueuedItemAttachment(attachmentSlotIndex)
    
    return true
end

function class.Mail:FilterSlot(inventoryManager, inventory, slot)
    if not IsSendingMail() then 
        return 
    end
    
    -- Exclude protected slots
    if util.IsSlotProtected(slot) then 
        return true 
    end
end