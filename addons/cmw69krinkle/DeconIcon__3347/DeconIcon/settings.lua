IIT_Settings = ZO_Object:Subclass()

local LAM = LibAddonMenu2

--
-- IIT_Settings constructor
--
function IIT_Settings:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function IIT_Settings:Initialize()
end

--
-- Create the Options panel with LibAddonMenu-2.0
--
function IIT_Settings:CreatePanel()
    self.LoadSavedVars()

    local OptionsName = "IITOptions"

    local panelData = {
        type = "panel",
        name = "DeconIcon",
        displayName = "|cff8800Krinkle's DeconIcon|r",
        author = "cmw69krinkle",
        version = DeconIconAddon.addonVersion,
        registerForRefresh = true,
        registerForDefaults = true,
        website = "http://www.esoui.com/"
    }

    LAM:RegisterAddonPanel(OptionsName, panelData)

    local optionsData = {
        {
            type = "header",
            name = "|c3f7fff DeconIcon Settings|r"
        },
        {
            type = "checkbox",
            name = "Show Bank Icon",
            tooltip = "If set this will show the bank icon on the decon list.",
            getFunc = function() return DeconIconAddon.settings.showBankIcon end,
            setFunc = function(value) DeconIconAddon.settings.showBankIcon = value end,
            default = true,
        },
        {
            type = "checkbox",
            name = "Show Bag Icon",
            tooltip = "If set this will show the bag icon on the decon list. This indicates that the item to deconstruct is in the backpack.",
            getFunc = function() return DeconIconAddon.settings.showBagIcon end,
            setFunc = function(value) DeconIconAddon.settings.showBagIcon = value end,
            default = true,
        }
    }

    LAM:RegisterOptionControls(OptionsName, optionsData)
end

function IIT_Settings:LoadSavedVars()
    local defaults = {
        showBankIcon = true,
        showBagIcon = true
    }

    DeconIconAddon.settings = ZO_SavedVars:NewAccountWide("DeconIconSV", 2.1, nil, defaults)
end
