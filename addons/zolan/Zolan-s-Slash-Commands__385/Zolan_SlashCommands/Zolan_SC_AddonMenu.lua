--------------------------------------------------------------------------------
--                   Zolan's Slash Commands (Addon Menu)
--------------------------------------------------------------------------------

local ZSC       = Zolan_SC
local AddonMenu = ZSC.AddonMenu
AddonMenu.Vars  = {}

-- Localize as much as we can to avoid global lookups.
local LibStub   = LibStub

AddonMenu.colors = {
    ["gold"]       = "|cFFD700", -- Gold
    ["faded_gold"] = "|c998100", -- Faded Gold
    ["light_blue"] = "|c88DDDD", -- Light Blue
    ["faded_blue"] = "|c44AAAA"  -- Faded Blue
}

AddonMenu.Vars.titleColor   = AddonMenu.colors.gold
AddonMenu.Vars.header1Color = AddonMenu.colors.gold
AddonMenu.Vars.header2Color = AddonMenu.colors.faded_gold
AddonMenu.Vars.header3Color = AddonMenu.colors.faded_blue
AddonMenu.Vars.header4Color = AddonMenu.colors.light_blue

AddonMenu.LAM = LibStub("LibAddonMenu-2.0")

function AddonMenu.getBooleanOption(optionName)
    ZSC.debug("AddonMenu -> getBooleanOption [" .. optionName .. "]")
    return ZSC.savedVars[optionName]
end

function AddonMenu.toggleBooleanOption(optionName)
    ZSC.debug("AddonMenu -> toggleBooleanOption [" .. optionName .. "]")
    local newValue = not ZSC.savedVars[optionName]
    ZSC.savedVars[optionName] = newValue
end

function AddonMenu.initializeAddonMenu()
    ZSC.debug("AddonMenu -> initializeAddonMenu")

	AddonMenu.LAM:RegisterAddonPanel("Zolan_SlashCommands_ControlPanel", {
		type = "panel",
		name = "Slash Commands",
		author = "Zolan",
		version = ZSC.appVersion,
		displayName = AddonMenu.Vars.header1Color .. "ZOLAN'S SLASH COMMANDS",
	})
	
	AddonMenu.LAM:RegisterOptionControls("Zolan_SlashCommands_ControlPanel", {
		[1] = {
			type = "checkbox",
			name = "Enable Slash Commands",
			tooltip = "Enable or disable ALL features of Zolan's Slash Commands.",
			getFunc = function () return AddonMenu.getBooleanOption('enabled') end,
			setFunc = function () AddonMenu.toggleBooleanOption('enabled') end
		},
		[2] = {
			type = "checkbox",
			name = "Enable Debugging",
			tooltip = "You almost certainly want this disabled. Enabling it will "
			.. "cause a massive amount of text in your chat box.",
			getFunc = function () return AddonMenu.getBooleanOption('debug') end,
			setFunc = function () AddonMenu.toggleBooleanOption('debug') end
		}
	})
end
