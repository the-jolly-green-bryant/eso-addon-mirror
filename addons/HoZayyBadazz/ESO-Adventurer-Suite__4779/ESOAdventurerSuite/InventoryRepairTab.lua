-- ESO Adventurer Suite
-- Inventory Repair tab
-- v0.29.510: persistent Repair button beside the visible inventory filters.
-- No selection backdrop; closes automatically when native inventory tab changes.

local EPC = ESOProgressionCoach
if not EPC then return end

EPC.InventoryRepairTab = EPC.InventoryRepairTab or {}
local T = EPC.InventoryRepairTab
local wm = WINDOW_MANAGER

local REPAIR_ICON_UP = "EsoUI/Art/Repair/inventory_tabIcon_repair_up.dds"
local REPAIR_ICON_DOWN = "EsoUI/Art/Repair/inventory_tabIcon_repair_down.dds"
local REPAIR_ICON_OVER = "EsoUI/Art/Repair/inventory_tabIcon_repair_over.dds"
local UPDATE_NAME = (EPC.name or "ESOAdventurerSuite") .. "_InventoryRepairTab029510"

function T:IsInventoryOpen()
    if SCENE_MANAGER and type(SCENE_MANAGER.IsShowing) == "function" then
        local ok, showing = pcall(SCENE_MANAGER.IsShowing, SCENE_MANAGER, "inventory")
        if ok and showing == true then return true end
    end
    local inv = rawget(_G, "ZO_PlayerInventory")
    return inv and inv.IsHidden and not inv:IsHidden() or false
end

function T:GetRepairModule()
    return EPC.RepairCostOverlay
end

function T:GetNativeSelectedDescriptor()
    local tabs = rawget(_G, "ZO_PlayerInventoryTabs")
    local object = tabs and tabs.m_object
    if object and type(object.GetSelectedDescriptor) == "function" then
        local ok, descriptor = pcall(object.GetSelectedDescriptor, object)
        if ok then return descriptor end
    end
    return nil
end

function T:RestoreRepairPanel()
    local repair = self:GetRepairModule()
    if not repair or not repair.frame then return end
    repair.frame:SetHidden(true)
    if repair.compactFrame then repair.compactFrame:SetHidden(true) end
end

function T:AnchorRepairPanel()
    local repair = self:GetRepairModule()
    local inv = rawget(_G, "ZO_PlayerInventory")
    if not repair or not repair.frame or not inv then return false end

    local frame = repair.frame
    frame:ClearAnchors()
    frame:SetAnchor(TOPLEFT, inv, TOPRIGHT, 14, 72)
    if frame.SetDrawTier and rawget(_G, "DT_HIGH") then frame:SetDrawTier(DT_HIGH) end
    if frame.SetDrawLayer and rawget(_G, "DL_CONTROLS") then frame:SetDrawLayer(DL_CONTROLS) end
    if frame.SetDrawLevel then frame:SetDrawLevel(220) end
    return true
end

function T:ShowRepairPanel()
    local repair = self:GetRepairModule()
    if not repair then return end
    if not repair.frame and type(repair.Create) == "function" then pcall(repair.Create, repair) end
    if not repair.frame then return end
    if type(repair.Refresh) == "function" then pcall(repair.Refresh, repair) end
    self:AnchorRepairPanel()
    repair.frame:SetHidden(false)
end

function T:SetSelected(selected)
    selected = selected == true
    self.selected = selected
    if self.icon then self.icon:SetTexture(selected and REPAIR_ICON_DOWN or REPAIR_ICON_UP) end

    if selected then
        -- Remember the native tab that was active when Repair opened. Any later
        -- native tab change closes Repair automatically.
        self.nativeDescriptorAtOpen = self:GetNativeSelectedDescriptor()
        self:ShowRepairPanel()
    else
        self.nativeDescriptorAtOpen = nil
        self:RestoreRepairPanel()
    end
end

function T:GetRightMostNativeTab()
    local tabs = rawget(_G, "ZO_PlayerInventoryTabs")
    local object = tabs and tabs.m_object
    local buttons = object and object.m_buttons
    if type(buttons) ~= "table" then return nil end

    local best, bestRight = nil, -math.huge
    for _, entry in ipairs(buttons) do
        local control = entry and entry[1]
        if control and control.IsHidden and not control:IsHidden() and control.GetRight then
            local ok, right = pcall(control.GetRight, control)
            right = ok and tonumber(right) or nil
            if right and right > bestRight then
                best, bestRight = control, right
            end
        end
    end
    return best
end

function T:CreateButton()
    if self.button then return true end
    local inv = rawget(_G, "ZO_PlayerInventory")
    if not inv then return false end

    local button = wm:CreateControl("EAS_InventoryRepairTab029510", inv, CT_BUTTON)
    button:SetDimensions(44, 44)
    button:SetMouseEnabled(true)
    button:SetHidden(true)

    -- No selection backdrop/blue box. The selected state is shown only by the
    -- native repair pressed icon, matching the other inventory filter icons.
    local icon = wm:CreateControl("EAS_InventoryRepairTabIcon029510", button, CT_TEXTURE)
    icon:SetAnchorFill(button)
    icon:SetTexture(REPAIR_ICON_UP)
    icon:SetMouseEnabled(false)

    button:SetHandler("OnClicked", function() T:SetSelected(not T.selected) end)
    button:SetHandler("OnMouseEnter", function()
        if T.icon and not T.selected then T.icon:SetTexture(REPAIR_ICON_OVER) end
        if InformationTooltip and type(InitializeTooltip) == "function" then
            InitializeTooltip(InformationTooltip, button, BOTTOM, 0, -4, TOP)
            InformationTooltip:AddLine("Repair", "ZoFontWinH4")
            InformationTooltip:AddLine("Show armor condition, repair cost, and weapon charge details.", "ZoFontGame")
        end
    end)
    button:SetHandler("OnMouseExit", function()
        if T.icon then T.icon:SetTexture(T.selected and REPAIR_ICON_DOWN or REPAIR_ICON_UP) end
        if InformationTooltip and type(ClearTooltip) == "function" then pcall(ClearTooltip, InformationTooltip) end
    end)

    self.button, self.icon, self.highlight = button, icon, nil
    return true
end

function T:AnchorButton()
    if not self.button then return false end
    local native = self:GetRightMostNativeTab()
    local tabs = rawget(_G, "ZO_PlayerInventoryTabs")
    self.button:ClearAnchors()
    if native then
        self.button:SetAnchor(LEFT, native, RIGHT, 5, 0)
    elseif tabs then
        self.button:SetAnchor(LEFT, tabs, RIGHT, 5, 0)
    else
        return false
    end
    return true
end

function T:InstallSelectionHook()
    if self.selectionHooked or type(ZO_PreHook) ~= "function" then return end
    if type(rawget(_G, "ZO_MenuBar_SelectDescriptor")) ~= "function" then return end
    ZO_PreHook("ZO_MenuBar_SelectDescriptor", function(menuBar)
        if menuBar == rawget(_G, "ZO_PlayerInventoryTabs") and T.selected then
            T:SetSelected(false)
        end
        return false
    end)
    self.selectionHooked = true
end

function T:Refresh()
    if not self:CreateButton() then return end
    self:InstallSelectionHook()

    local open = self:IsInventoryOpen()
    self.button:SetHidden(not open)
    if not open then
        if self.selected then self:SetSelected(false) end
        return
    end

    self:AnchorButton()

    if self.selected then
        local currentDescriptor = self:GetNativeSelectedDescriptor()
        if self.nativeDescriptorAtOpen ~= nil and currentDescriptor ~= self.nativeDescriptorAtOpen then
            self:SetSelected(false)
            return
        end
        self:ShowRepairPanel()
    end
end

local function Install()
    EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
    EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, 100, function() T:Refresh() end)
    T:Refresh()
end

if type(zo_callLater) == "function" then
    zo_callLater(Install, 500)
    zo_callLater(function() T:Refresh() end, 1200)
else
    Install()
end
