AutoBank_Settings = {}

function AutoBank_Settings:Initialize(core)
    self.core = core
    local LAM = LibAddonMenu2
    if not LAM then
        if self.core and self.core.Debug then
            self.core:Debug("LibAddonMenu2 not found; skipping settings panel.")
        end
        return
    end

    local panelData = {
        type = "panel",
        name = "AutoBankMats+",
        displayName = "AutoBankMats+",
        author = "Hearthcode",
        version = "1.0",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM:RegisterAddonPanel("AutoBankPanel", panelData)

    local optionsTable = {
        {
            type = "checkbox",
            name = "Enable AutoBank",
            getFunc = function()
                return core.savedVars.enabled
            end,
            setFunc = function(value)
                core.savedVars.enabled = value
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show Per-Item Alerts",
            tooltip = "Show a scrolling alert for each material auto-banked",
            getFunc = function()
                return core.savedVars.showPerItemAlerts
            end,
            setFunc = function(value)
                core.savedVars.showPerItemAlerts = value
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Debug Messages",
            getFunc = function()
                return core.savedVars.debug
            end,
            setFunc = function(value)
                core.savedVars.debug = value
            end,
            width = "full",
        },
        {
            type = "dropdown",
            name = "Material Selection Mode",
            tooltip = "Choose how to select materials for auto-banking",
            choices = {
                "Auto bank all materials",
                "Custom select your materials"
            },
            getFunc = function()
                if core.savedVars.useCustomSelection then
                    return "Custom select your materials"
                else
                    return "Auto bank all materials"
                end
            end,
            setFunc = function(value)
                local wasCustom = core.savedVars.useCustomSelection
                core.savedVars.useCustomSelection = (value == "Custom select your materials")
                
                -- If switching from auto to custom, enable all materials by default
                if not wasCustom and core.savedVars.useCustomSelection then
                    self:SetAllMaterials(true)
                end
            end,
            width = "full",
        },
        {
            type = "header",
            name = "Material Types to Auto-Deposit",
        },
        {
            type = "checkbox",
            name = "All Crafting Materials",
            tooltip = "Enable/disable all material types below",
            getFunc = function()
                return self:GetAllMaterialsEnabled()
            end,
            setFunc = function(value)
                self:SetAllMaterials(value)
            end,
            disabled = function()
                return not core.savedVars.useCustomSelection
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Style Materials",
            getFunc = function()
                return core.savedVars.materials.styleMaterials
            end,
            setFunc = function(value)
                core.savedVars.materials.styleMaterials = value
            end,
            disabled = function()
                return not core.savedVars.useCustomSelection
            end,
            width = "half",
        },
        {
            type = "checkbox",
            name = "Alchemy Materials",
            getFunc = function()
                return core.savedVars.materials.alchemyMaterials
            end,
            setFunc = function(value)
                core.savedVars.materials.alchemyMaterials = value
            end,
            disabled = function()
                return not core.savedVars.useCustomSelection
            end,
            width = "half",
        },
        {
            type = "checkbox",
            name = "Woodworking Materials",
            getFunc = function()
                return core.savedVars.materials.woodworkingMaterials
            end,
            setFunc = function(value)
                core.savedVars.materials.woodworkingMaterials = value
            end,
            disabled = function()
                return not core.savedVars.useCustomSelection
            end,
            width = "half",
        },
        {
            type = "checkbox",
            name = "Clothing Materials",
            getFunc = function()
                return core.savedVars.materials.clothingMaterials
            end,
            setFunc = function(value)
                core.savedVars.materials.clothingMaterials = value
            end,
            disabled = function()
                return not core.savedVars.useCustomSelection
            end,
            width = "half",
        },
        {
            type = "checkbox",
            name = "Blacksmithing Materials",
            getFunc = function()
                return core.savedVars.materials.blacksmithingMaterials
            end,
            setFunc = function(value)
                core.savedVars.materials.blacksmithingMaterials = value
            end,
            disabled = function()
                return not core.savedVars.useCustomSelection
            end,
            width = "half",
        },
        {
            type = "checkbox",
            name = "Provisioning Materials",
            getFunc = function()
                return core.savedVars.materials.provisioningMaterials
            end,
            setFunc = function(value)
                core.savedVars.materials.provisioningMaterials = value
            end,
            disabled = function()
                return not core.savedVars.useCustomSelection
            end,
            width = "half",
        },
        {
            type = "checkbox",
            name = "Jewelry Materials",
            getFunc = function()
                return core.savedVars.materials.jewelryMaterials
            end,
            setFunc = function(value)
                core.savedVars.materials.jewelryMaterials = value
            end,
            disabled = function()
                return not core.savedVars.useCustomSelection
            end,
            width = "half",
        },
        {
            type = "checkbox",
            name = "Furnishing Materials",
            getFunc = function()
                return core.savedVars.materials.furnishingMaterials
            end,
            setFunc = function(value)
                core.savedVars.materials.furnishingMaterials = value
            end,
            disabled = function()
                return not core.savedVars.useCustomSelection
            end,
            width = "half",
        },
        {
            type = "checkbox",
            name = "Trait Materials",
            getFunc = function()
                return core.savedVars.materials.traitMaterials
            end,
            setFunc = function(value)
                core.savedVars.materials.traitMaterials = value
            end,
            disabled = function()
                return not core.savedVars.useCustomSelection
            end,
            width = "half",
        },
        {
            type = "checkbox",
            name = "Enchantment Materials",
            getFunc = function()
                return core.savedVars.materials.enchantmentMaterials
            end,
            setFunc = function(value)
                core.savedVars.materials.enchantmentMaterials = value
            end,
            disabled = function()
                return not core.savedVars.useCustomSelection
            end,
            width = "half",
        },
    }

    LAM:RegisterOptionControls("AutoBankPanel", optionsTable)
end

function AutoBank_Settings:GetAllMaterialsEnabled()
    local materials = self.core.savedVars.materials
    return materials.styleMaterials and 
           materials.alchemyMaterials and 
           materials.woodworkingMaterials and 
           materials.clothingMaterials and 
           materials.blacksmithingMaterials and 
           materials.provisioningMaterials and 
           materials.jewelryMaterials and 
           materials.furnishingMaterials and 
           materials.traitMaterials and 
           materials.enchantmentMaterials
end

function AutoBank_Settings:SetAllMaterials(value)
    local materials = self.core.savedVars.materials
    materials.styleMaterials = value
    materials.alchemyMaterials = value
    materials.woodworkingMaterials = value
    materials.clothingMaterials = value
    materials.blacksmithingMaterials = value
    materials.provisioningMaterials = value
    materials.jewelryMaterials = value
    materials.furnishingMaterials = value
    materials.traitMaterials = value
    materials.enchantmentMaterials = value
end
