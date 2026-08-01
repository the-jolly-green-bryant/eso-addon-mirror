RestockBankMaterials = RestockBankMaterials or {}

RestockBankMaterials.strings = {
    core = {
        restockBankButton = "Restock Bank",
        maxStackReached = "%s has reached max stack count.",
        slotsMovedPlural = "%d items were restocked.",
        slotsMovedSingular = "1 item was restocked.",
        noSlotsMoved = "No items were restocked."
    },

    settings = {
        name = "Restock Bank Materials",
        displayName = "|cfabbffRestock Bank Materials|r",
        enabled = {
            name = "Enabled"
        },
        settingsHeader = {
            name = "Settings"
        },
        allowNonMaterials = {
            name = "Allow non-materials",
            tooltip = "If false, only materials will be restocked. If true, any type of stackable item can be restocked."
        },
        autoOpenMaterials = {
            name = "Automatically open materials tab",
            tooltip = "When restocking, automatically switches to the deposit menu and opens the materials tab. Does nothing if in gamepad mode."
        },
        restockBankKeybind = {
            name = "Keybind",
            tooltip = 'Which keybind will be used to restock the bank. "Custom bind" can be set in the keybindings menu.',
            choices = {
                -- quaternary = GetString(SI_BINDING_NAME_UI_SHORTCUT_QUATERNARY),
                custom = "Custom bind"
            }
        }
    }
}

ZO_CreateStringId("SI_BINDING_NAME_RBM_RESTOCK_BANK", "Custom bind")