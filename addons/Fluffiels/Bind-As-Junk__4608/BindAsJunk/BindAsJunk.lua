local AddonVersion = '1.03'
local addonName = "BindAsJunk"
local LCM

ZO_CreateStringId("SI_BINDING_NAME_BINDASJUNK_BIND_JUNK_HOVERED", "Bind & Junk Hovered Item")

BindAsJunk = BindAsJunk or {}

local BAJ = {}


function BAJ.OnPluginLoaded(eventCode, name)
    if name ~= addonName then return end
    EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)

    BAJ.InitializeDialog()
	LCM = LibCustomMenu
    if LCM then
        LCM:RegisterContextMenu(BAJ.OnContextMenu, LCM.CATEGORY_LATE)
    end

    CreateDefaultActionBind("BINDASJUNK_BIND_JUNK_HOVERED", KEY_SEMICOLON, KEY_INVALID, KEY_INVALID, KEY_INVALID, KEY_INVALID)
end

function BAJ.OnContextMenu(inventorySlot, slotActions, ctrl, alt, shift, command)
    local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
    if bagId == nil or slotIndex == nil then return end
    if not BAJ.ShouldShowOption(bagId, slotIndex) then return end

    AddMenuItem("Bind as Junk", function()
        ZO_Dialogs_ShowDialog("BINDASJUNK_CONFIRM", { bagId = bagId, slotIndex = slotIndex })
    end)
end

function BindAsJunk.BindJunkHoveredItem()
    local moc = WINDOW_MANAGER:GetMouseOverControl()
    if not (moc and moc.dataEntry and moc.dataEntry.data) then return end
    local data = moc.dataEntry.data
    local bagId = data.bagId
    local slotIndex = data.slotIndex
    if not (bagId and slotIndex and bagId == BAG_BACKPACK) then return end
    if not BAJ.ShouldShowOption(bagId, slotIndex) then
		BAJ.MarkAsJunk(bagId, slotIndex)
		return
	end
    ZO_Dialogs_ShowDialog("BINDASJUNK_CONFIRM", { bagId = bagId, slotIndex = slotIndex })
end

function BAJ.ShouldShowOption(bagId, slotIndex)
    if bagId ~= BAG_BACKPACK then return false end

    local itemType = GetItemType(bagId, slotIndex)
    if not BAJ.IsGearType(itemType) then return false end

    if IsItemBound(bagId, slotIndex) then return false end

    if IsItemJunk(bagId, slotIndex) then return false end

    local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)
    if not itemLink or itemLink == "" then return false end
	
	local itemSet = GetItemLinkSetInfo (itemLink)
	if not itemSet or itemSet == "" then return false end
	
    if not IsItemLinkSetCollectionPiece(itemLink) then return false end

    local itemId = GetItemLinkItemId(itemLink)
    if IsItemSetCollectionPieceUnlocked(itemId) then return false end

    return true
end

function BAJ.MarkAsJunk(bagId, slotIndex)
    if bagId ~= BAG_BACKPACK then return false end
	if IsItemPlayerLocked(bagId, slotIndex) then return end
	if IsItemStolen(bagId, slotIndex) then return end
	
	local itemType = GetItemType(bagId, slotIndex)
    if itemType == ITEMTYPE_QUEST then return end
	
    local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)
    if not itemLink or itemLink == "" then return false end
	
	local wasJunk = IsItemJunk(bagId, slotIndex)
	SetItemIsJunk(bagId, slotIndex, not wasJunk)
	
	if wasJunk then
		PlaySound(SOUNDS.INVENTORY_ITEM_UNJUNKED)
	else
		PlaySound(SOUNDS.INVENTORY_ITEM_JUNKED)
	end
	
end

function BAJ.IsGearType(itemType)
    return itemType == ITEMTYPE_ARMOR or
           itemType == ITEMTYPE_WEAPON or
           itemType == ITEMTYPE_JEWELRY
end

function BAJ.InitializeDialog()
    ZO_Dialogs_RegisterCustomDialog("BINDASJUNK_CONFIRM",
    {
        title = {
            text = "BindAsJunk"
        },
        mainText = {
            text = "Bind and mark as junk? This cannot be undone."
        },
        buttons = {
            {
                text = SI_DIALOG_CONFIRM,
                callback = function(dialog)
                    local data = dialog.data
                    BindItem(data.bagId, data.slotIndex)
                    SetItemIsJunk(data.bagId, data.slotIndex, true)
					PlaySound(SOUNDS.HOUSING_EDITOR_RETRIEVE_ITEM)
                end,
            },
            {
                text = SI_DIALOG_CANCEL,
            },
        },
    })
end

EVENT_MANAGER:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED, BAJ.OnPluginLoaded)