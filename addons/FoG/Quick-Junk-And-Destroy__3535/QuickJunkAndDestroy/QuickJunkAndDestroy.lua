local QJAD = {}
QJAD.Name = "QuickJunkAndDestroy"
QJAD.DisplayName = "Quick Junk And Destroy"
QJAD.Author = "FoG"
QJAD.Version = "1.0.1"

local JD = {
    BagId = nil,
    SlotId = nil,
    CanBeJunked = nil,
    CanBeDestroyed = nil,
    IsItemJunk = nil,
    AddJunk = nil,
}

local Bags = {
    [BAG_BACKPACK] = true,
    [BAG_BANK] = true,
    [BAG_HOUSE_BANK_ONE] = true,
    [BAG_HOUSE_BANK_TWO] = true,
    [BAG_HOUSE_BANK_THREE] = true,
    [BAG_HOUSE_BANK_FOUR] = true,
    [BAG_HOUSE_BANK_FIVE] = true,
    [BAG_HOUSE_BANK_SIX] = true,
    [BAG_HOUSE_BANK_SEVEN] = true,
    [BAG_HOUSE_BANK_EIGHT] = true,
    [BAG_HOUSE_BANK_NINE] = true,
    [BAG_HOUSE_BANK_TEN] = true,
}

ZO_CreateStringId("SI_BINDING_NAME_QJAD_JUNK", "Junk Selected Item")
ZO_CreateStringId("SI_BINDING_NAME_QJAD_DESTROY", "Destroy Selected Item")

QJAD_Strip = ZO_Object:Subclass()

function QJAD_Strip:New(name, keybind, callback, alignment)
    local Object = ZO_Object.New(self)
    Object:Initialize(name, keybind, callback, alignment)
    
    return Object
end

function createStripDescriptor(name, keybind, callback, alignment)
    return {{alignment = alignment or KEYBIND_STRIP_ALIGN_RIGHT, name = name, keybind = keybind, callback = callback}}
end

function QJAD_Strip:Initialize(name, keybind, callback, alignment)
    self.Strip = createStripDescriptor(name, keybind, callback, alignment)
    self.wasAdded = false
end

function QJAD_Strip:IsBound()
    local Layer, Category, Action = GetActionIndicesFromName(self.Strip[1]["keybind"])
    for binding = 1, GetMaxBindingsPerAction() do
        local Keycode, _, _, _, _ = GetActionBindingInfo(Layer, Category, Action, binding)
        if (Keycode > 0) then
            return true
        end
    end

    return false
end

function QJAD_Strip:Add(onlyIfBound)
    if (not onlyIfBound or self:IsBound()) then
        KEYBIND_STRIP:AddKeybindButtonGroup(self.Strip)
        self.wasAdded = true
    end
end

function QJAD_Strip:Remove()
    if (self.wasAdded) then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(self.Strip)
        self.wasAdded = false
    end
end

local JunkStrip = QJAD_Strip:New("Junk", "QJAD_JUNK", QJAD_Junk)
local DestroyStrip = QJAD_Strip:New("Destroy", "QJAD_DESTROY", QJAD_Destroy)

QJAD.OnMouseEnter = function(control)
    if control and control.dataEntry then
        JD.BagId = control.dataEntry.data.bagId
        JD.SlotId = control.dataEntry.data.slotIndex
        
        if JD.BagId and JD.SlotId and Bags[JD.BagId] and CanItemBeMarkedAsJunk(JD.BagId, JD.SlotId) then
            JD.CanBeJunked = true
            JD.IsItemJunk = IsItemJunk(JD.BagId, JD.SlotId)
        end
        if JD.BagId and JD.SlotId then
            JD.CanBeDestroyed = true
        end

        QJAD.AddKeybinds()
    end
end

QJAD.OnMouseExit = function()
    JD.BagId = nil
    JD.SlotId = nil

    QJAD.RemoveKeybinds()
end

QJAD.AddKeybinds = function()
    if JD.CanBeJunked then
        JunkStrip:Add(true)
    end
    if JD.CanBeDestroyed then
        DestroyStrip:Add(true)
    end
end

QJAD.RemoveKeybinds = function()
    if JD.CanBeJunked then
        JD.CanBeJunked = false
        JD.IsItemJunk = false
        JunkStrip:Remove()
    end
    if JD.CanBeDestroyed then
        JD.CanBeDestroyed = false
        DestroyStrip:Remove()
    end
end

QJAD_Junk = function()
    if JD.CanBeJunked then
        SetItemIsJunk(JD.BagId, JD.SlotId, not JD.IsItemJunk)
        if JD.IsItemJunk then
            PlaySound(SOUNDS.INVENTORY_ITEM_UNJUNKED)
        else
            PlaySound(SOUNDS.INVENTORY_ITEM_JUNKED)
        end
    end
end

QJAD_Destroy = function()
    if JD.BagId == nil then return end
    if JD.CanBeDestroyed then
        DestroyItem(JD.BagId, JD.SlotId)
        PlayItemSound(itemSoundCategory, ITEM_SOUND_ACTION_DESTROY)
    end
end

QJAD.OnLoad = function(eventCode, addonName)
    if addonName ~= QJAD.Name then return end

    EVENT_MANAGER:UnregisterForEvent(QJAD.Name, EVENT_ADD_ON_LOADED)

    ZO_PreHook("ZO_InventorySlot_OnMouseEnter", function(control) QJAD.OnMouseEnter(control) end)
    ZO_PreHook("ZO_InventorySlot_OnMouseExit", function(control) QJAD.OnMouseExit(control) end)

    local function OnStateChanged(oldState, newState)
        if newState == SCENE_SHOWING then
            QJAD.AddKeybinds()
        elseif newState == SCENE_HIDDEN then
            QJAD.RemoveKeybinds()
        end
    end

    INVENTORY_FRAGMENT:RegisterCallback("StateChange", OnStateChanged)
    BANK_FRAGMENT:RegisterCallback("StateChange", OnStateChanged)
    HOUSE_BANK_FRAGMENT:RegisterCallback("StateChange", OnStateChanged)
end

EVENT_MANAGER:RegisterForEvent(QJAD.Name, EVENT_ADD_ON_LOADED, QJAD.OnLoad)