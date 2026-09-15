-- ESO Adventurer Suite
-- v0.29.663 - bank lock indicator visibility.
-- Adds ESO's lock icon to Suite bank cells and drives visibility from the live
-- IsItemPlayerLocked(bag, slot) state so lock/unlock changes are visible.

local EPC = ESOProgressionCoach
if not EPC or not WINDOW_MANAGER then return end

local U = EPC.BankGridUnifiedV2
if not U then return end

local wm = WINDOW_MANAGER
local LOCK_ICON_TEXTURE = (type(rawget(_G, "ZO_KEYBOARD_LOCKED_ICON")) == "string" and rawget(_G, "ZO_KEYBOARD_LOCKED_ICON")) or "EsoUI/Art/Miscellaneous/status_locked.dds"

local function liveLocked(item)
    if not item or item.bag == nil or item.slot == nil then return false end
    if type(IsItemPlayerLocked) == "function" then
        local ok, value = pcall(IsItemPlayerLocked, item.bag, item.slot)
        if ok then return value == true end
    end
    return item.locked == true
end

local function ensureLockIcon(cell)
    if not cell then return nil end
    if cell._easBankLockIcon029663 then return cell._easBankLockIcon029663 end

    local icon = wm:CreateControl(nil, cell, CT_TEXTURE)
    icon:SetDimensions(16, 16)
    icon:SetAnchor(TOPLEFT, cell, TOPLEFT, 2, 2)
    icon:SetTexture(LOCK_ICON_TEXTURE)
    icon:SetColor(1, 1, 1, 1)
    if type(icon.SetDrawTier) == "function" and rawget(_G, "DT_HIGH") ~= nil then icon:SetDrawTier(DT_HIGH) end
    if type(icon.SetDrawLayer) == "function" and rawget(_G, "DL_OVERLAY") ~= nil then icon:SetDrawLayer(DL_OVERLAY) end
    if type(icon.SetDrawLevel) == "function" then icon:SetDrawLevel(980) end
    icon:SetMouseEnabled(false)
    icon:SetHidden(true)

    cell._easBankLockIcon029663 = icon
    cell.lockIcon = icon
    return icon
end

if type(U.GetCell) == "function" and not U._easBankLockCells029663 then
    U._easBankLockCells029663 = true
    local baseGetCell = U.GetCell
    function U:GetCell(index)
        local cell = baseGetCell(self, index)
        ensureLockIcon(cell)
        return cell
    end
end

if type(U.Render) == "function" and not U._easBankLockRender029663 then
    U._easBankLockRender029663 = true
    local baseRender = U.Render
    function U:Render(info, ...)
        local shown = baseRender(self, info, ...)
        for _, cell in ipairs(self.cells or {}) do
            if cell then
                local icon = ensureLockIcon(cell)
                local item = cell.item
                local hidden = true
                if item and type(cell.IsHidden) == "function" and cell:IsHidden() == false then
                    local locked = liveLocked(item)
                    item.locked = locked
                    hidden = not locked
                end
                if icon then icon:SetHidden(hidden) end
            end
        end
        return shown
    end
end

EPC.bankLockIndicatorFix029663 = true
