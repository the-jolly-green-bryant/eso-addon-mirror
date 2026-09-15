-- ESO Adventurer Suite
-- v0.29.505 - Repair is inventory-button-only; darker panel; tabs shifted left.

local EPC = ESOProgressionCoach
if not EPC then return end

local R = EPC.RepairCostOverlay
local T = EPC.InventoryRepairTab
if not R or not T then return end

local UPDATE_NAME = (EPC.name or "ESOAdventurerSuite") .. "_RepairButtonPresentation029505"

local function DarkenRepairPanel029505()
    if not R.bg then return end
    -- Strong near-black background so the repair information is readable over
    -- bright character/world scenes while keeping the Suite gold edge.
    if R.bg.SetCenterColor then
        pcall(R.bg.SetCenterColor, R.bg, 0.004, 0.005, 0.008, 0.985)
    end
    if R.bg.SetEdgeColor then
        pcall(R.bg.SetEdgeColor, R.bg, 0.82, 0.62, 0.26, 1)
    end
end

local function ShiftInventoryTabsLeft029505()
    local tabs = rawget(_G, "ZO_PlayerInventoryTabs")
    if not tabs or not tabs.ClearAnchors or not tabs.SetAnchor then return end
    local parent = tabs.GetParent and tabs:GetParent() or rawget(_G, "ZO_PlayerInventory")
    if not parent then return end

    -- ESO defaults this bar near TOPRIGHT at roughly -33px. Pull the entire
    -- icon row farther left while preserving its original vertical position.
    pcall(tabs.ClearAnchors, tabs)
    pcall(tabs.SetAnchor, tabs, TOPRIGHT, parent, TOPRIGHT, -105, 14)
end

local originalRefresh029505 = R.Refresh
if type(originalRefresh029505) == "function" and not R._easButtonOnlyRefresh029505 then
    R._easButtonOnlyRefresh029505 = originalRefresh029505

    R.Refresh = function(self, ...)
        -- Let the existing module calculate rows, totals, condition, charge and
        -- wallet data first. We only take ownership of presentation/visibility.
        local ok, a, b, c, d = pcall(originalRefresh029505, self, ...)

        DarkenRepairPanel029505()

        -- The old compact/always Repair HUD is redundant now that Repair has a
        -- dedicated inventory button. Keep it hidden regardless of old settings.
        if self.compactFrame then
            pcall(self.compactFrame.SetHidden, self.compactFrame, true)
        end
        if self.compactHudFragment029125 and type(self.compactHudFragment029125.SetHiddenForReason) == "function" then
            pcall(self.compactHudFragment029125.SetHiddenForReason, self.compactHudFragment029125, "EAS_REPAIR_BUTTON_ONLY_029505", true)
        end

        -- Detailed card is visible only while the Repair button itself is active.
        local selected = EPC.InventoryRepairTab and EPC.InventoryRepairTab.selected == true
        if self.frame then
            if selected then
                if EPC.InventoryRepairTab and type(EPC.InventoryRepairTab.AnchorRepairPanel) == "function" then
                    pcall(EPC.InventoryRepairTab.AnchorRepairPanel, EPC.InventoryRepairTab)
                end
                pcall(self.frame.SetHidden, self.frame, false)
            else
                pcall(self.frame.SetHidden, self.frame, true)
            end
        end

        if not ok then return nil end
        return a, b, c, d
    end
end

-- The old RestoreRepairPanel path re-anchors/re-shows according to the previous
-- Inventory/Always setting. In button-only mode closing Repair should simply hide it.
T.RestoreRepairPanel = function(self)
    local repair = EPC.RepairCostOverlay
    if type(self.GetRepairModule) == "function" then
        local ok, value = pcall(self.GetRepairModule, self)
        if ok and value then repair = value end
    end
    if repair and repair.frame then
        pcall(repair.frame.SetHidden, repair.frame, true)
    end
    if repair and repair.compactFrame then
        pcall(repair.compactFrame.SetHidden, repair.compactFrame, true)
    end
end

local function Apply029505()
    DarkenRepairPanel029505()
    ShiftInventoryTabsLeft029505()

    if R.compactFrame then R.compactFrame:SetHidden(true) end

    if T.selected then
        if type(T.ShowRepairPanel) == "function" then pcall(T.ShowRepairPanel, T) end
        DarkenRepairPanel029505()
    elseif R.frame then
        R.frame:SetHidden(true)
    end
end

EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, 250, Apply029505)

if type(zo_callLater) == "function" then
    zo_callLater(Apply029505, 300)
    zo_callLater(Apply029505, 1000)
else
    Apply029505()
end