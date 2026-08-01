local HARDCORE = HARDCORE

local ID = "NoPotions"
local NS = "HARDCORE_NoPotions"

local ICON_NO_POTIONS = "/esoui/art/tradinghouse/tradinghouse_potions_potionsolvent_up.dds"

local Rule = {
    id = ID,
    title = "No Potions: alchemy is forbidden",
    icon = ICON_NO_POTIONS,
    defaultEnabled = false
}

Rule.active = false

local function IsHardcoreActive()
    return HARDCORE and HARDCORE.saved and HARDCORE.saved.isActive
end

local function FailForPotion()
    if HARDCORE and HARDCORE.FailChallenge then
        HARDCORE.FailChallenge("HARDCORE: Challenge failed. You used a potion.")
    end
end

local function OnInventoryItemUsed(_, itemSoundCategory)
    if Rule.active and IsHardcoreActive() and itemSoundCategory == ITEM_SOUND_CATEGORY_POTION then
        FailForPotion()
    end
end

local function RegisterEvents()
    EVENT_MANAGER:UnregisterForEvent(NS .. "_USED", EVENT_INVENTORY_ITEM_USED)
    EVENT_MANAGER:RegisterForEvent(NS .. "_USED", EVENT_INVENTORY_ITEM_USED, OnInventoryItemUsed)
end

local function UnregisterEvents()
    EVENT_MANAGER:UnregisterForEvent(NS .. "_USED", EVENT_INVENTORY_ITEM_USED)
end

function Rule:OnEnable()
    self.active = true
    RegisterEvents()
end

function Rule:OnDisable()
    self.active = false
    UnregisterEvents()
end

HARDCORE.RuleManager:RegisterRule(Rule)
