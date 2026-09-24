-- PreviewAnywhereBankUtils.lua: Pure helpers for the gamepad banking screen.

local BankUtils = {}

---An entry can be previewed when it is a real item row (not the currencies
---menu entry or a currency selector row) whose bag slot the preview system
---accepts. Works for any banked bag: player bank, subscriber bank, house
---banks, and the Furnishing Vault, plus the backpack on the deposit side.
---@param entryData table|nil Target data from the banking parametric list
---@return boolean
function BankUtils.IsEntryPreviewable(entryData)
    if not entryData or ZO_GamepadBanking.IsEntryDataCurrencyRelated(entryData) then
        return false
    end

    local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(entryData)
    if not bagId or not slotIndex then
        return false
    end

    return CanInventoryItemBePreviewed(bagId, slotIndex)
end

---@param entryData table Target data bound via ZO_Inventory_BindSlot
---@return integer bagId
---@return integer slotIndex
function BankUtils.GetEntryBagAndSlot(entryData)
    return ZO_Inventory_GetBagAndIndex(entryData)
end

PreviewAnywhere.BankUtils = BankUtils
