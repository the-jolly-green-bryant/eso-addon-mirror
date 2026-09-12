local CMA = CraftMaterialAssistant

-- Build the Settings Panel interface via LibAddonMenu-2.0
function CMA:CreateSettingsMenu()
    local LAM = LibAddonMenu2
    if not LAM then
        self:SendChatMessage("Missing dependency LibAddonMenu-2.0")
        return
    end

    local panelData = {
        type = "panel",
        name = "Craft Material Assistant",
        displayName = "|cFFD700Craft Material Assistant|r",
        author = "Lesse83",
        version = self.version,
        registerForRefresh = true
    }
    LAM:RegisterAddonPanel("Craft Material Assistant", panelData)

    local optionsData = {
        {
            type = "checkbox",
            name = "Enable Craft Material Assistant",
            tooltip = "Enable or disable all functionality of this addon.",
            getFunc = function() return self.db.enableAddon end,
            setFunc = function(v) self.db.enableAddon = v end
        },
        {
            type = "submenu",
            name = "General Options",
            controls = {
                {
                    type = "checkbox",
                    name = "Vendor not banked materials",
                    tooltip = "Mark all craft materials that are not banked as trash to be vendored.",
                    getFunc = function() return self.db.markAsTrashIfNotBanked end,
                    setFunc = function(v) self.db.markAsTrashIfNotBanked = v end,
                    disabled = function() return not self.db.enableAddon end
                },
                {
                    type = "checkbox",
                    name = "Auto sell items marked as junk",
                    tooltip = "Automatically sell all items marked as junk when opening a vendor.",
                    getFunc = function() return self.db.autoSellJunk end,
                    setFunc = function(v) self.db.autoSellJunk = v end,
                    disabled = function() return not self.db.enableAddon end
                },
                {
                    type = "checkbox",
                    name = "Show banking message",
                    tooltip = "Toggles chat message when materials are moved to the bank vault.",
                    getFunc = function() return self.db.showBankAlerts end,
                    setFunc = function(v) self.db.showBankAlerts = v end,
                    disabled = function() return not self.db.enableAddon end
                },
                {
                    type = "checkbox",
                    name = "Show junked message",
                    tooltip = "Toggles chat message when materials that are not banked are marked as junk.",
                    getFunc = function() return self.db.showJunkAlerts end,
                    setFunc = function(v) self.db.showJunkAlerts = v end,
                    disabled = function() return not self.db.enableAddon end,
                },
                {
                    type = "checkbox",
                    name = "Show Vendor Sales Message",
                    tooltip = "Toggles chat message showing items sold and gold earned. Needs to have 'Auto sell' enabled.",
                    getFunc = function() return self.db.showVendorAlerts end,
                    setFunc = function(v) self.db.showVendorAlerts = v end,
                    disabled = function() return (not self.db.enableAddon) or (not self.db.autoSellJunk) end
                },
                                {
                    type = "editbox",
                    name = "Delay before start (Milliseconds)",
                    tooltip = "To not conflict with other addons doing banking processes the start of the operations can be delayed by the given amount of milliseconds (seconds * 1000).",
                    textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
                    maxChars = 5,
                    getFunc = function() return self.db.initialDelayInMs end,
                    setFunc = function(v) self.db.initialDelayInMs = v end,
                    disabled = function() return (not self.db.enableAddon) end,
                    width = "half"
                }
            }
        },
        {
            type = "submenu",
            name = "Blacksmithing",
            controls = {
                {
                    type = "checkbox",
                    name = "Enable banking",
                    tooltip = "Enable banking of Blacksmithing materials.",
                    getFunc = function() return self.db.bankBlacksmithing end,
                    setFunc = function(v) self.db.bankBlacksmithing = v end,
                    disabled = function() return not self.db.enableAddon end,
                    width = "half"
                },
                {
                    type = "dropdown",
                    name = "Temper quality threshold",
                    tooltip = "Minimum quality of Blacksmithing Tempers to be banked.",
                    choices = self.qualityDropdownChoices,
                    getFunc = function() return self.db.bankQualityThresholdBlacksmithing end,
                    setFunc = function(v) self.db.bankQualityThresholdBlacksmithing = v end,
                    disabled = function() return (not self.db.enableAddon) or (not self.db.bankBlacksmithing) end,
                    width = "half"
                },
                {
                    type = "slider",
                    name = "Material tier level",
                    tooltip = "Blacksmithing Ores and Ingots meeting this tier requirement will be banked.\n" .. self.blacksmithingTierInfo,
                    min = 1, max = 11, step = 1,
                    getFunc = function() return self.db.bankTierThresholdBlacksmithing end,
                    setFunc = function(v) self.db.bankTierThresholdBlacksmithing = v end,
                    disabled = function() return (not self.db.enableAddon) or (not self.db.bankBlacksmithing) end,
                    width = "half"
                }
            }
        },
        {
            type = "submenu",
            name = "Clothing",
            controls = {
                {
                    type = "checkbox",
                    name = "Enable banking",
                    tooltip = "Enable banking of Clothing materials.",
                    getFunc = function() return self.db.bankClothing end,
                    setFunc = function(v) self.db.bankClothing = v end,
                    disabled = function() return not self.db.enableAddon end,
                    width = "half"
                },
                {
                    type = "dropdown",
                    name = "Tannin quality threshold",
                    tooltip = "Minimum quality of Clothing Tannins to be banked.",
                    choices = self.qualityDropdownChoices,
                    getFunc = function() return self.db.bankQualityThresholdClothing end,
                    setFunc = function(v) self.db.bankQualityThresholdClothing = v end,
                    disabled = function() return (not self.db.enableAddon) or (not self.db.bankClothing) end,
                    width = "half"
                },
                {
                    type = "slider",
                    name = "Material tier level",
                    tooltip = "Clothing Materials and Raw Materials meeting this tier requirement will be banked.\n" .. self.clothingTierInfo,
                    min = 1, max = 11, step = 1,
                    getFunc = function() return self.db.bankTierThresholdClothing end,
                    setFunc = function(v) self.db.bankTierThresholdClothing = v end,
                    disabled = function() return (not self.db.enableAddon) or (not self.db.bankClothing) end,
                    width = "half"
                }
            }
        },
        {
            type = "submenu",
            name = "Woodworking",
            controls = {
                {
                    type = "checkbox",
                    name = "Enable banking",
                    tooltip = "Enable banking of Woodworking materials.",
                    getFunc = function() return self.db.bankWoodworking end,
                    setFunc = function(v) self.db.bankWoodworking = v end,
                    disabled = function() return not self.db.enableAddon end,
                    width = "half"
                },
                {
                    type = "dropdown",
                    name = "Resin quality threshold",
                    tooltip = "Minimum quality of Woodworking Resins to be banked.",
                    choices = self.qualityDropdownChoices,
                    getFunc = function() return self.db.bankQualityThresholdWoodworking end,
                    setFunc = function(v) self.db.bankQualityThresholdWoodworking = v end,
                    disabled = function() return (not self.db.enableAddon) or (not self.db.bankWoodworking) end,
                    width = "half"
                },
                {
                    type = "slider",
                    name = "Material tier level",
                    tooltip = "Rough and Sanded Woodworking materials meeting this tier requirement will be banked.\n" .. self.woodworkingTierInfo,
                    min = 1, max = 11, step = 1,
                    getFunc = function() return self.db.bankTierThresholdWoodworking end,
                    setFunc = function(v) self.db.bankTierThresholdWoodworking = v end,
                    disabled = function() return (not self.db.enableAddon) or (not self.db.bankWoodworking) end,
                    width = "half"
                }
            }
        },
        {
            type = "submenu",
            name = "Jewelry",
            controls = {
                {
                    type = "checkbox",
                    name = "Enable banking",
                    tooltip = "Enable banking of Jewelry materials.",
                    getFunc = function() return self.db.bankJewelry end,
                    setFunc = function(v) self.db.bankJewelry = v end,
                    disabled = function() return not self.db.enableAddon end,
                    width = "half"
                },
                {
                    type = "checkbox",
                    name = "Bank Raw Jewelry Traits",
                    tooltip = "Enable banking of Pulverized items (Raw Jewelry Traits)",
                    getFunc = function() return self.db.bankRawJewelryTraits end,
                    setFunc = function(v) self.db.bankRawJewelryTraits = v end,
                    disabled = function() return (not self.db.enableAddon) or (not self.db.bankJewelry) end,
                    width = "half"
                },
                {
                    type = "dropdown",
                    name = "Plating quality threshold",
                    tooltip = "Minimum quality of Jewelry Platings to be banked.",
                    choices = self.qualityDropdownChoices,
                    getFunc = function() return self.db.bankQualityThresholdJewelry end,
                    setFunc = function(v) self.db.bankQualityThresholdJewelry = v end,
                    disabled = function() return (not self.db.enableAddon) or (not self.db.bankJewelry) end,
                    width = "half"
                },
                {
                    type = "slider",
                    name = "Material tier level",
                    tooltip = "Jewelry Ounces and Dust meeting this tier requirement will be banked.\n" .. self.jewelryTierInfo,
                    min = 1, max = 6, step = 1,
                    getFunc = function() return self.db.bankTierThresholdJewelry end,
                    setFunc = function(v) self.db.bankTierThresholdJewelry = v end,
                    disabled = function() return (not self.db.enableAddon) or (not self.db.bankJewelry) end,
                    width = "half"
                }
            }
        },
        {
            type = "submenu",
            name = "Enchanting",
            controls = {
                {
                    type = "checkbox",
                    name = "Enable banking",
                    tooltip = "Enable banking of Enchanting materials.",
                    getFunc = function() return self.db.bankEnchanting end,
                    setFunc = function(v) self.db.bankEnchanting = v end,
                    disabled = function() return not self.db.enableAddon end,
                    width = "half"
                },
                {
                    type = "dropdown",
                    name = "Aspect Rune quality threshold",
                    tooltip = "Minimum quality of Aspect Runes to be banked.",
                    choices = self.qualityDropdownChoices,
                    getFunc = function() return self.db.bankQualityThresholdEnchanting end,
                    setFunc = function(v) self.db.bankQualityThresholdEnchanting = v end,
                    disabled = function() return (not self.db.enableAddon) or (not self.db.bankEnchanting) end,
                    width = "half"
                },
                {
                    type = "slider",
                    name = "Minimum Potency Improvement level",
                    tooltip = "Potency Runes meeting this Improvement level will be banked.\n" .. self.enchantingTierInfo,
                    min = 1, max = 11, step = 1,
                    getFunc = function() return self.db.bankImprovementThresholdPotencyRunes end,
                    setFunc = function(v) self.db.bankImprovementThresholdPotencyRunes = v end,
                    disabled = function() return (not self.db.enableAddon) or (not self.db.bankEnchanting) end,
                    width = "half"
                },
                {
                    type = "checkbox",
                    name = "Enable banking of Essence Runes",
                    tooltip = "Enable banking of Essence Runes.",
                    getFunc = function() return self.db.bankEssenceRunes end,
                    setFunc = function(v) self.db.bankEssenceRunes = v end,
                    disabled = function() return (not self.db.enableAddon) or (not self.db.bankEnchanting) end,
                    width = "half"
                }
            }
        },
        {
            type = "submenu",
            name = "Alchemy",
            controls = {
                {
                    type = "checkbox",
                    name = "Enable banking",
                    tooltip = "Enable banking of Alchemy materials.",
                    getFunc = function() return self.db.bankAlchemy end,
                    setFunc = function(v) self.db.bankAlchemy = v end,
                    disabled = function() return not self.db.enableAddon end,
                    width = "half"
                },
                {
                    type = "slider",
                    name = "Minimum Solvent Proficiency",
                    tooltip = "Solvents meeting this Proficiency level will be banked.\n" .. self.alchemyTierInfo,
                    min = 1, max = 9, step = 1,
                    getFunc = function() return self.db.bankProficiencyThresholdAlchemyBases end,
                    setFunc = function(v) self.db.bankProficiencyThresholdAlchemyBases = v end,
                    disabled = function() return (not self.db.enableAddon) or (not self.db.bankAlchemy) end,
                    width = "half"
                },
                {
                    type = "checkbox",
                    name = "Enable banking of Reagents",
                    tooltip = "Enable banking of Alchemy Reagents.",
                    getFunc = function() return self.db.bankAlchemyReagents end,
                    setFunc = function(v) self.db.bankAlchemyReagents = v end,
                    disabled = function() return (not self.db.enableAddon) or (not self.db.bankAlchemy) end,
                    width = "half"
                }
            }
        },
        {
            type = "submenu",
            name = "Provisioning",
            controls = {
                {
                    type = "checkbox",
                    name = "Enable banking",
                    tooltip = "Enable banking of Provisioning materials.",
                    getFunc = function() return self.db.bankProvisioning end,
                    setFunc = function(v) self.db.bankProvisioning = v end,
                    disabled = function() return not self.db.enableAddon end,
                    width = "half"
                },
                {
                    type = "checkbox",
                    name = "Bank only Writ Ingredients",
                    tooltip = "When banking Provisioning Ingredients only keep those needed by top-level Daily Writs.",
                    getFunc = function() return self.db.bankProvisioningWritIngredientsOnly end,
                    setFunc = function(v) self.db.bankProvisioningWritIngredientsOnly = v end,
                    disabled = function() return (not self.db.enableAddon) or (not self.db.bankProvisioning) end,
                    width = "half"
                },
                {
                    type = "dropdown",
                    name = "Rare quality threshold",
                    tooltip = "Minimum quality of Rare Provisioning Ingredients to be banked.",
                    choices = self.qualityDropdownChoices,
                    getFunc = function() return self.db.bankQualityThresholdProvisioning end,
                    setFunc = function(v) self.db.bankQualityThresholdProvisioning = v end,
                    disabled = function() return (not self.db.enableAddon) or (not self.db.bankProvisioning) end,
                    width = "half"
                },

                {
                    type = "checkbox",
                    name = "Sell known Provisioning Recipes",
                    tooltip = "Sell known Provisioning Recipes which do not meet the defined quality threshold.",
                    getFunc = function() return self.db.bankProvisioningSellKnownRecipe end,
                    setFunc = function(v) self.db.bankProvisioningSellKnownRecipe = v end,
                    disabled = function() return (not self.db.enableAddon) or (not self.db.bankProvisioning) end,
                    width = "half"
                },
                {
                    type = "dropdown",
                    name = "Recipe sell quality threshold",
                    tooltip = "Only sell Provisioning Recipes if they are below the set threshold quality.",
                    choices = self.qualityDropdownChoices,
                    getFunc = function() return self.db.bankQualityThresholdProvisioningRecipe end,
                    setFunc = function(v) self.db.bankQualityThresholdProvisioningRecipe = v end,
                    disabled = function() return (not self.db.enableAddon) or (not self.db.bankProvisioning) or (not self.db.bankProvisioningSellKnownRecipe) end,
                    width = "half"
                }

            }
        },
        {
            type = "submenu",
            name = "Scribing",
            controls = {
                {
                    type = "checkbox",
                    name = "Enable banking",
                    tooltip = "Enable banking of Blacksmithing materials.",
                    getFunc = function() return self.db.bankScribingMaterials end,
                    setFunc = function(v) self.db.bankScribingMaterials = v end,
                    disabled = function() return not self.db.enableAddon end,
                    width = "half"
                },
                {
                    type = "dropdown",
                    name = "Banking of Ink",
                    tooltip = "Bank: Move to the bank.\nSell: Mark as junk to be sold at the vendor.\nIgnore: Don't do anything.",
                    choices = self.simpleMaterialChoices,
                    getFunc = function() return self.db.bankInk end,
                    setFunc = function(v) self.db.bankInk = v end,
                    disabled = function() return (not self.db.enableAddon) or not(self.db.bankScribingMaterials) end,
                    width = "half"
                },
                {
                    type = "checkbox",
                    name = "Bank unknown Scripts",
                    tooltip = "REQUIRES LibCharacterKnowledge!\n\nBanks Scripts as long as they are learnable and there are not enough copies for all characters.\n\nOtherwise markes the script as trash to be auto vendored.\n\nAlso writes a chat message who is able to learn it.",
                    getFunc = function() return self.db.bankUnknownScripts end,
                    setFunc = function(v) self.db.bankUnknownScripts = v end,
                    disabled = function() return not (self.db.enableAddon) or not(self.db.bankScribingMaterials) end,
                    width = "half"
                },
                 {
                    type = "dropdown",
                    name = "Banking of Unbound Scripts",
                    tooltip = "Bank: Move to the bank.\nSell: Mark as junk to be sold at the vendor.\nIgnore: Don't do anything.",
                    choices = self.simpleMaterialChoices,
                    getFunc = function() return self.db.bankUnboundScripts end,
                    setFunc = function(v) self.db.bankUnboundScripts = v end,
                    disabled = function() return (not self.db.enableAddon) or not(self.db.bankScribingMaterials) end,
                    width = "half"
                },
            }
        },
        {
            type = "submenu",
            name = "Style Materials",
            controls = {
                {
                    type = "dropdown",
                    name = "Banking of Style Materials",
                    tooltip = "Bank: Move to the bank.\nSell: Mark as junk to be sold at the vendor.\nIgnore: Don't do anything.",
                    choices = self.simpleMaterialChoices,
                    getFunc = function() return self.db.bankStyleMaterials end,
                    setFunc = function(v) self.db.bankStyleMaterials = v end,
                    disabled = function() return (not self.db.enableAddon) end,
                    width = "half"
                },
                {
                    type = "checkbox",
                    name = "Limit banked amount",
                    tooltip = "Limit the banked amount of each Style Material by the number entered in the text control below.",
                    getFunc = function() return self.db.limitStyleMaterialByCount end,
                    setFunc = function(v) self.db.limitStyleMaterialByCount = v end,
                    disabled = function() return (not self.db.enableAddon) or (not self.db.bankStyleMaterials) end,
                    width = "half"
                },
                {
                    type = "editbox",
                    name = "Bank until number owned",
                    tooltip = "A specific Style Material will be banked until owning that total amount of it (across the bank, craft bag and house banks).",
                    textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
                    maxChars = 5,
                    getFunc = function() return self.db.bankMinimumNumberStyleMaterial end,
                    setFunc = function(v) self.db.bankMinimumNumberStyleMaterial = v end,
                    disabled = function() return (not self.db.enableAddon) or (not self.db.bankStyleMaterials) or (not self.db.limitStyleMaterialByCount) end,
                    width = "half"
                }
            }
        },
        {
            type = "submenu",
            name = "Trait Materials",
            controls = {
                {
                    type = "dropdown",
                    name = "Banking of Trait Materials",
                    tooltip = "Bank: Move to the bank.\nSell: Mark as junk to be sold at the vendor.\nIgnore: Don't do anything.",
                    choices = self.simpleMaterialChoices,
                    getFunc = function() return self.db.bankTraitMaterials end,
                    setFunc = function(v) self.db.bankTraitMaterials = v end,
                    disabled = function() return (not self.db.enableAddon) end,
                    width = "half"
                },
                {
                    type = "checkbox",
                    name = "Limit banked amount",
                    tooltip = "Limit the banked amount of each Trait Material by the number entered in the text control below.",
                    getFunc = function() return self.db.limitTraitMaterialByCount end,
                    setFunc = function(v) self.db.limitTraitMaterialByCount = v end,
                    disabled = function() return (not self.db.enableAddon) or (self.db.bankTraitMaterials ~= "Bank") end,
                    width = "half"
                },
                {
                    type = "editbox",
                    name = "Bank until number owned",
                    tooltip = "A specific Trait Material will be banked until owning that total amount of it (across the bank, craft bag and house banks).",
                    textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
                    maxChars = 5,
                    getFunc = function() return self.db.bankMinimumNumberTraitMaterial end,
                    setFunc = function(v) self.db.bankMinimumNumberTraitMaterial = v end,
                    disabled = function() return (not self.db.enableAddon) or (self.db.bankTraitMaterials ~= "Bank") or (not self.db.limitTraitMaterialByCount) end,
                    width = "half"
                }
            }
        },
        {
            type = "submenu",
            name = "Other Material Types",
            controls = {
                {
                    type = "dropdown",
                    name = "Banking of Furnishing Materials",
                    tooltip = "Bank: Move to the bank.\nSell: Mark as junk to be sold at the vendor.\nIgnore: Don't do anything.",
                    choices = self.simpleMaterialChoices,
                    getFunc = function() return self.db.bankFurnishingMaterials end,
                    setFunc = function(v) self.db.bankFurnishingMaterials = v end,
                    disabled = function() return (not self.db.enableAddon) end,
                    width = "half"
                },
                {
                    type = "dropdown",
                    name = "Banking of Bait Items",
                    tooltip = "Bank: Move to the bank.\nSell: Mark as junk to be sold at the vendor.\nIgnore: Don't do anything.",
                    choices = self.simpleMaterialChoices,
                    getFunc = function() return self.db.bankBait end,
                    setFunc = function(v) self.db.bankBait = v end,
                    disabled = function() return (not self.db.enableAddon) end,
                    width = "half"
                },
                {
                    type = "dropdown",
                    name = "Banking of Raw Materials",
                    tooltip = "Bank: Move to the bank.\nSell: Mark as junk to be sold at the vendor.\nIgnore: Don't do anything.",
                    choices = self.simpleMaterialChoices,
                    getFunc = function() return self.db.bankRawMaterials end,
                    setFunc = function(v) self.db.bankRawMaterials = v end,
                    disabled = function() return (not self.db.enableAddon) end,
                    width = "half"
                }
            }
        }
    }
    LAM:RegisterOptionControls("Craft Material Assistant", optionsData)
end