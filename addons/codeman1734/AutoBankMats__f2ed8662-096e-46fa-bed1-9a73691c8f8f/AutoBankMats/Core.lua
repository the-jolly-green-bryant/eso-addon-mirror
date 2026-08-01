AutoBank = {}
AutoBank.name = "AutoBank"

function AutoBank:Initialize()
    self.savedVars = ZO_SavedVars:NewAccountWide("AutoBankSavedVars", 2, nil, {
        enabled = true,
        debug = false,  -- Debug back to false
        showPerItemAlerts = true,
        useCustomSelection = false,
        materials = {
            styleMaterials = true,
            alchemyMaterials = true,
            woodworkingMaterials = true,
            clothingMaterials = true,
            blacksmithingMaterials = true,
            provisioningMaterials = true,
            jewelryMaterials = true,
            furnishingMaterials = true,
            traitMaterials = true,
            enchantmentMaterials = true,
        }
    })

    -- Runtime fallback for users upgrading from older savedVars
    if self.savedVars.showPerItemAlerts == nil then
        self.savedVars.showPerItemAlerts = true
    end

    AutoBank_Events:Initialize(self)
    AutoBank_TransferQueue:Initialize(self)
    AutoBank_Settings:Initialize(self)

    -- Radial menu toggle (optional - only registers if LibRadialMenu is installed)
    -- if LibRadialMenu then
    --     LibRadialMenu:RegisterAddon("AUTOBANK", "AutoBank")
    --     LibRadialMenu:RegisterEntry(
    --         "AUTOBANK",
    --         function()
    --             if self.savedVars.enabled then
    --                 return "Disable AutoBank"
    --             else
    --                 return "Enable AutoBank"
    --             end
    --         end,
    --         1,
    --         "/esoui/art/icons/mapkey_bank.dds",
    --         function()
    --             self.savedVars.enabled = not self.savedVars.enabled
    --             if self.savedVars.enabled then
    --                 ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "AutoBank: Enabled")
    --             else
    --                 ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "AutoBank: Disabled")
    --             end
    --         end,
    --         "Toggle AutoBank on or off"
    --     )
    -- end

    self:Debug("Initialized.")
end

function AutoBank:ProcessBackpack()
    self:Debug("Starting to process backpack...")
    
    local bankSlots = GetNumBagFreeSlots(BAG_BANK)
    self:Debug("Available bank slots: " .. bankSlots)
    
    local queued = 0

    for slot = 0, GetBagSize(BAG_BACKPACK) - 1 do
        if AutoBank_Filters:ShouldDeposit(BAG_BACKPACK, slot, self) then
            local itemName = GetItemName(BAG_BACKPACK, slot)
            self:Debug("Queueing item: " .. (itemName or "Unknown"))
            AutoBank_TransferQueue:Queue(BAG_BACKPACK, slot)
            queued = queued + 1
        end
    end

    self:Debug("Queued " .. queued .. " items.")
    
    if queued > 0 then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "AutoBank: Attempting to transfer " .. queued .. " items to bank.")
        AutoBank_TransferQueue:Start()
    else
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "AutoBank: No crafting materials found to transfer.")
    end
end

-- Startup
local function OnAddonLoaded(event, addonName)
    if addonName == AutoBank.name then
        EVENT_MANAGER:UnregisterForEvent(AutoBank.name, EVENT_ADD_ON_LOADED)
        AutoBank:Initialize()
    end
end

EVENT_MANAGER:RegisterForEvent(AutoBank.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
