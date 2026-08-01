--------------------------------------------------------------------------------
--                   Zolan's Auto Repair (Addon Menu)
--------------------------------------------------------------------------------

local ZAR       = Zolan_AR
local AddonMenu = ZAR.AddonMenu
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
    ZAR.debug("AddonMenu -> getBooleanOption [" .. optionName .. "]")
    return ZAR.savedVars[optionName]
end

function AddonMenu.toggleBooleanOption(optionName)
    ZAR.debug("AddonMenu -> toggleBooleanOption [" .. optionName .. "]")
    local newValue = not ZAR.savedVars[optionName]
    ZAR.savedVars[optionName] = newValue
end

function AddonMenu.initializeAddonMenu()
    ZAR.debug("AddonMenu -> initializeAddonMenu")

	AddonMenu.LAM:RegisterAddonPanel("Zolan_AutoRepair_ControlPanel", {
		type = "panel",
		name = "Auto Repair",
		version = ZAR.appVersion, author="Zolan",
		displayName = AddonMenu.Vars.header1Color .. "ZOLAN'S AUTO REPAIR"
	})
	
	AddonMenu.LAM:RegisterOptionControls("Zolan_AutoRepair_ControlPanel", {
		[1] = {
			type = "checkbox",
			name = "Enable Auto Repair",
			tooltip = "Enable or disable ALL features of Zolan's Auto Repair.",
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
		},
		[3] = {
			type = "submenu",
			name = AddonMenu.Vars.header4Color..'Manage Auto Repair Settings',
			tooltip = 'Open window for auto repair settings.',
			controls = {
				[1] = {
					type = "description",
					text = AddonMenu.Vars.header2Color.."By default this addon will ONLY repair what you have equipped. "
					.. "If you disable 'Repairr Equipped Items Only' it will, instead, repair everything in your "
					.. "inventory.",
					title = AddonMenu.Vars.header1Color.."- REPAIR SETTINGS -"
				},
				[2] = {
					type = "checkbox",
					name = "Repair Equipped Items Only",
					tooltip = "Enable or disable repairing your equipped items.",
					getFunc = function () return AddonMenu.getBooleanOption('repairEquippedOnly') end,
					setFunc = function () AddonMenu.toggleBooleanOption('repairEquippedOnly') end
				},
        [3] = {
          type = "checkbox",
          name = "Use repair kits if available",
          tooltip = "Enable or disable for using available repair kits.",
          getFunc = function () return AddonMenu.getBooleanOption('useKits') end,
          setFunc = function () AddonMenu.toggleBooleanOption('useKits') end
        }
			}
		},
		[4] = {
			type = "submenu",
			name = AddonMenu.Vars.header4Color..'Manage Receipt Settings',
			tooltip = 'Open window for settings on how auto repair notifies you about its activities.',
			controls = {
				[1] = {
					type = "description",
					text = AddonMenu.Vars.header2Color.."Settings regarding how Auto Repair notifies you of what it did.",
					title = AddonMenu.Vars.header1Color.. "- RECEIPT SETTINGS -"
				},
				[2] = {
					type = "checkbox",
					name = "Notify Upon Opening Store",
					tooltip = "Enable or disable notifications that this addon is doing something.",
					getFunc = function () return AddonMenu.getBooleanOption('repairNotify') end,
					setFunc = function () AddonMenu.toggleBooleanOption('repairNotify') end
				},
				[3] = {
					type = "checkbox",
					name = "Show Itemized List of Repairs",
					tooltip = "Enable or disable showing an itemized list of what was repaired.",
					getFunc = function () return AddonMenu.getBooleanOption('showItemized') end,
					setFunc = function () AddonMenu.toggleBooleanOption('showItemized') end
				},
				[4] = {
					type = "checkbox",
					name = "Show Summary of Repairs",
					tooltip = "Enable or disable showing a summary of what was repaired.",
					getFunc = function () return AddonMenu.getBooleanOption('showSummary') end,
					setFunc = function () AddonMenu.toggleBooleanOption('showSummary') end
				}
			}
		}
	})
end
