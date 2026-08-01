local KD = KyzderpsDerps
KD.GroupLoot = {
    name = KD.name .. "GroupLoot",
}
local GL = KD.GroupLoot


---------------------------------------------------------------------
local YUGE_LOOT = {
    [133550] = "POLY POLY POLY", -- Runebox: Clockwork Reliquary
}

---------------------------------------------------------------------
-- * EVENT_LOOT_RECEIVED (*string* _receivedBy_, *string* _itemName_, *integer* _quantity_, *[ItemUISoundCategory|#ItemUISoundCategory]* _soundCategory_, *[LootItemType|#LootItemType]* _lootType_, *bool* _self_, *bool* _isPickpocketLoot_, *string* _questItemIcon_, *integer* _itemId_, *bool* _isStolen_)
local function OnLootReceived(_, receivedBy, itemName, quantity, _, lootType, self, _, _, itemId, isStolen)
    local text = YUGE_LOOT[itemId]
    if (not text) then return end

    CrutchAlerts.DisplayProminentSpin(text, {1, 0, 0}, 1)
    CrutchAlerts.DisplayProminentSpin(text, {0, 1, 0}, 2)
    CrutchAlerts.DisplayProminentSpin(text, {0, 0, 1}, 3)
end


---------------------------------------------------------------------
function GL.Initialize()
    if (not CrutchAlerts or not CrutchAlerts.DisplayProminentSpin) then return end
    EVENT_MANAGER:UnregisterForEvent(GL.name, EVENT_LOOT_RECEIVED)
    if (KD.savedOptions.groupLoot.obnoxiousHighValue) then
        EVENT_MANAGER:RegisterForEvent(GL.name, EVENT_LOOT_RECEIVED, OnLootReceived)
    end
end


---------------------------------------------------------------------
-- Settings
---------------------------------------------------------------------
function GL.GetSettings()
    return {
        type = "checkbox",
        name = "Alert high-value group loot",
        tooltip = "When a group member loots a high value item, for now just the Clockwork Reliquary polymorph, displays obnoxious text and plays obnoxious sounds. Requires CrutchAlerts",
        default = false,
        getFunc = function() return KD.savedOptions.groupLoot.obnoxiousHighValue end,
        setFunc = function(value)
            KD.savedOptions.groupLoot.obnoxiousHighValue = value
            GL.Initialize()
        end,
        width = "full",
    }
end
