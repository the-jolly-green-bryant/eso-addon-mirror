-- Local instances of Global tables --
local PA = PersonalAssistant
local PAC = PA.Constants
local PACAddon = PAC.ADDON
local PARMenuChoices = PA.MenuChoices.choices.PARepair
local PARMenuChoicesValues = PA.MenuChoices.choicesValues.PARepair
local PARProfileManager = PA.ProfileManager.PARepair
local PARMenuDefaults = PA.MenuDefaults.PARepair
local PARMenuFunctions = PA.MenuFunctions.PARepair
local PAHF = PA.HelperFunctions

-- =====================================================================================================================

-- Create the LibAddonMenu2 object
PA.LAM2 = PA.LAM2 or LibAddonMenu2

local PARepairPanelData = {
    type = "panel",
    name = PACAddon.NAME_RAW.REPAIR,
    displayName = PACAddon.NAME_DISPLAY.REPAIR,
    author = PACAddon.AUTHOR,
    version = PACAddon.VERSION_DISPLAY,
    website = PACAddon.WEBSITE,
    feedback = PACAddon.FEEDBACK,
    keywords = PACAddon.KEYWORDS.REPAIR,
    slashCommand = "/par",
    registerForRefresh = true,
    registerForDefaults = true,
}

local PARepairOptionsTable = setmetatable({}, { __index = table })
local PARepairProfileSubMenuTable = setmetatable({}, { __index = table })

local PARGoldEquippedSubmenuTable = setmetatable({}, { __index = table })
local PARRepairKitSubmenuTable = setmetatable({}, { __index = table })
local PARRechargeSubmenuTable = setmetatable({}, { __index = table })

local PARGoldInventorySubmenuTable = setmetatable({}, { __index = table })
local PARBuyEquipmentRepairKitsSubmenuTable = setmetatable({}, { __index = table })
local PARBuyCyrodiilRepairKitsSubmenuTable = setmetatable({}, { __index = table })
local PARBuyFullSoulGemsSubmenuTable = setmetatable({}, { __index = table })
local PARBuyEmptySoulGemsSubmenuTable = setmetatable({}, { __index = table })
local PARBuyLockpicksSubmenuTable = setmetatable({}, { __index = table })

-- =================================================================================================================

local function insertBuySiegeItemsMenu() 
    local siegeItems = PA.Repair.SiegeWeapons[GetUnitAlliance("player")]
    for key, value in ipairs(siegeItems) do  -- keep ipairs so they display in order 
        local itemLink = "|H0:item:"..value.itemId..":1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
        if value.itemId == 	68347 then -- sigil of imperial retreat hack
            itemLink = "|H0:item:"..value.itemId..":6:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
        end
        local icon = GetItemLinkIcon(itemLink)

		local SwitchFormatedValue = {}
		      table.insert(SwitchFormatedValue, "AutoBuySiegeItems")
			  table.insert(SwitchFormatedValue, "buy"..value.settingName)
			  
		local ThresholdFormatedValue = {}
		      table.insert(ThresholdFormatedValue, "AutoBuySiegeItems")
			  table.insert(ThresholdFormatedValue, "buy"..value.settingName.."Threshold")

		local PriorityFormatedValue = {}
		      table.insert(PriorityFormatedValue, "AutoBuySiegeItems")
			  table.insert(PriorityFormatedValue, "buy"..value.settingName.."Priority")			  
			  
        local SettingsTable = setmetatable({}, { __index = table }) 
	    
		local hp = GetItemLinkSiegeMaxHP(itemLink)
		if hp > 0 then
		   hp = tostring(hp/1000).."K HP    "
		else
		    hp = ""
        end	
        
		local AP = ""
		if value.AP then
		   AP = PAHF.getFormattedCurrency(value.AP, CURT_ALLIANCE_POINTS, true).."    "
		end
		
		local gold = ""
		if value.gold then
		   gold = PAHF.getFormattedCurrency(value.gold, CURT_MONEY, true)
		end
	  
		
		SettingsTable:insert({
			type = "description",
			text = hp..AP..gold ,
			disabled = function() return PARMenuFunctions.isThisBuySiegeItemsSubmenuDisabled(SwitchFormatedValue) end,
        })
		
		SettingsTable:insert({
			type = "checkbox",
			name = string.format(GetString(SI_PA_MENU_BUY_ITEM_ENABLE), GetItemLinkName(itemLink)), 
			tooltip = string.format(GetString(SI_PA_MENU_BUY_ITEM_ENABLE_T), GetItemLinkName(itemLink)),
			getFunc = function() return PARMenuFunctions.getBuySiegeItemSetting(SwitchFormatedValue) end,
			setFunc = function(value) PARMenuFunctions.setBuySiegeItemSetting(value,SwitchFormatedValue) end,
			disabled = PARMenuFunctions.AreBuySiegeItemsSubmenusDisabled,
			default = PARMenuDefaults["AutoBuySiegeItems"]["buy"..value.settingName],
		})


		SettingsTable:insert({
			type = "slider",
			name = string.format(GetString(SI_PA_MENU_BUY_ITEM_THRESHOLD), GetItemLinkName(itemLink)),
			tooltip = string.format(GetString(SI_PA_MENU_BUY_ITEM_THRESHOLD_T), GetItemLinkName(itemLink)),
			min = 0,
			max = 200,
			step = 1,
			width = "full",
			getFunc = function() return PARMenuFunctions.getBuySiegeItemSetting(ThresholdFormatedValue) end,
			setFunc = function(value) PARMenuFunctions.setBuySiegeItemSetting(value,ThresholdFormatedValue) end,
			disabled = function() return PARMenuFunctions.isThisBuySiegeItemsSubmenuDisabled(SwitchFormatedValue) end,
			default = PARMenuDefaults["AutoBuySiegeItems"]["buy"..value.settingName.."Threshold"], 
		})
		
		if value.gold then 
			SettingsTable:insert({
				type = "dropdown",
				name = string.format(GetString(SI_PA_MENU_BUY_ITEM_PRIORITY), GetItemLinkName(itemLink)),
				tooltip = string.format(GetString(SI_PA_MENU_BUY_ITEM_PRIORITY_T), GetItemLinkName(itemLink)),
				choices = PARMenuFunctions.getCyrodiilRepairKitsPriorityList(),
				choicesValues = PARMenuFunctions.getCyrodiilRepairKitsPriorityValues(),
				width = "full",
			    getFunc = function() return PARMenuFunctions.getBuySiegeItemSetting(PriorityFormatedValue) end,
			    setFunc = function(value) PARMenuFunctions.setBuySiegeItemSetting(value,PriorityFormatedValue) end,
				disabled = function() return PARMenuFunctions.isThisBuySiegeItemsSubmenuDisabled(SwitchFormatedValue) end,
				default = PARMenuDefaults["AutoBuySiegeItems"]["buy"..value.settingName.."Priority"],
				reference = "PERSONALASSISTANT_REPAIR_"..value.settingName.."PRIORITYDROPDOWN"
			})
		end
		
		PARepairOptionsTable:insert({
			type = "submenu",
			name = string.format(GetString(SI_PA_MENU_BUY_ITEM_HEADER), GetItemLinkName(itemLink)),
			icon = GetItemLinkIcon(itemLink),
			controls = SettingsTable,
			disabledLabel = function() return PARMenuFunctions.isThisBuySiegeItemsSubmenuDisabled(SwitchFormatedValue) end,
        })
   end
end

-- =================================================================================================================	

local function _createPARepairMenu()
    PARepairOptionsTable:insert({
        type = "submenu",
        name = PARProfileManager.getProfileSubMenuHeader,
        controls = PARepairProfileSubMenuTable
    })

    PARepairOptionsTable:insert({
        type = "description",
        text = GetString(SI_PA_MENU_REPAIR_DESCRIPTION),
    })

    PARepairOptionsTable:insert({
        type = "header",
        name = PAC.COLOR.YELLOW:Colorize(GetString(SI_PA_MENU_REPAIR_EQUIPPED_HEADER))
    })

    PARepairOptionsTable:insert({
        type = "checkbox",
        name = PAC.COLOR.LIGHT_BLUE:Colorize(GetString(SI_PA_MENU_REPAIR_ENABLE)),
        getFunc = PARMenuFunctions.getAutoRepairEquippedEnabledSetting,
        setFunc = PARMenuFunctions.setAutoRepairEquippedEnabledSetting,
        disabled = PARProfileManager.isNoProfileSelected,
        default = PARMenuDefaults.autoRepairEnabled,
    })

    PARepairOptionsTable:insert({
        type = "submenu",
        name = GetString(SI_PA_MENU_REPAIR_GOLD_HEADER),
        icon = ZO_CURRENCIES_DATA[CURT_MONEY].keyboardTexture,
        controls = PARGoldEquippedSubmenuTable,
        disabledLabel = PARMenuFunctions.isRepairEquippedWithGoldMenuDisabled,
    })

    PARepairOptionsTable:insert({
        type = "submenu",
        name = GetString(SI_PA_MENU_REPAIR_REPAIRKIT_HEADER),
        icon = PAC.ICONS.ITEMS.REPAIRKIT.PATH,
        controls = PARRepairKitSubmenuTable,
        disabledLabel = PARMenuFunctions.isRepairWithRepairKitMenuDisabled,
    })

    PARepairOptionsTable:insert({
        type = "submenu",
        name = GetString(SI_PA_MENU_REPAIR_RECHARGE_HEADER),
        icon = PAC.ICONS.ITEMS.SOULGEM.PATH,
        controls = PARRechargeSubmenuTable,
        disabledLabel = PARMenuFunctions.isRechargeWithSoulGemMenuDisabled,
    })

    -- ---------------------------------------------------------------------------------------------------------

    PARepairOptionsTable:insert({
        type = "header",
        name = PAC.COLOR.YELLOW:Colorize(GetString(SI_PA_MENU_REPAIR_INVENTORY_HEADER))
    })

    PARepairOptionsTable:insert({
        type = "checkbox",
        name = PAC.COLOR.LIGHT_BLUE:Colorize(GetString(SI_PA_MENU_REPAIR_INVENTORY_ENABLE)),
        getFunc = PARMenuFunctions.getAutoRepairInventoryEnabledSetting,
        setFunc = PARMenuFunctions.setAutoRepairInventoryEnabledSetting,
        disabled = PARProfileManager.isNoProfileSelected,
        default = PARMenuDefaults.autoRepairInventoryEnabled,
    })

    PARepairOptionsTable:insert({
        type = "submenu",
        name = GetString(SI_PA_MENU_REPAIR_GOLD_HEADER),
        icon = ZO_CURRENCIES_DATA[CURT_MONEY].keyboardTexture,
        controls = PARGoldInventorySubmenuTable,
        disabledLabel = PARMenuFunctions.isRepairInventoryWithGoldMenuDisabled,
    })
	
    -- ---------------------------------------------------------------------------------------------------------

    PARepairOptionsTable:insert({
        type = "header",
        name = PAC.COLOR.YELLOW:Colorize(GetString(SI_PA_MENU_BUY_REPAIR_KITS_HEADER))
    })
	
	PARepairOptionsTable:insert({
        type = "checkbox",
        name = PAC.COLOR.LIGHT_BLUE:Colorize(GetString(SI_PA_MENU_BUY_REPAIR_KITS_ENABLE)),
        getFunc = PARMenuFunctions.getAutoBuyRepairKitsEnabledSetting,
        setFunc = PARMenuFunctions.setAutoBuyRepairKitsEnabledSetting,
        disabled = PARProfileManager.isNoProfileSelected,
        default = PARMenuDefaults.autoBuyRepairKitsEnabled,
    })
	
	PARepairOptionsTable:insert({
        type = "submenu",
        name = string.format(GetString(SI_PA_MENU_BUY_ITEM_HEADER), GetItemLinkName("|H0:item:44879:1:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h")),
        icon = GetItemLinkIcon("|H0:item:44879:1:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h"),
        controls = PARBuyEquipmentRepairKitsSubmenuTable,
        disabledLabel = PARMenuFunctions.isBuyEquipmentRepairKitsMenuDisabled,
    })
	
	PARepairOptionsTable:insert({
        type = "submenu",
        name = string.format(GetString(SI_PA_MENU_BUY_ITEM_HEADER), GetItemLinkName("|H0:item:204483:1:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h")),
        icon = GetItemLinkIcon("|H0:item:204483:1:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h"),
        controls = PARBuyCyrodiilRepairKitsSubmenuTable,
        disabledLabel = PARMenuFunctions.isBuyCyrodiilRepairKitsMenuDisabled,
    })
	
	
    -- ---------------------------------------------------------------------------------------------------------

    PARepairOptionsTable:insert({
        type = "header",
        name = PAC.COLOR.YELLOW:Colorize(GetString(SI_PA_MENU_BUY_SOUL_GEMS_HEADER))
    })
	
	PARepairOptionsTable:insert({
        type = "checkbox",
        name = PAC.COLOR.LIGHT_BLUE:Colorize(GetString(SI_PA_MENU_BUY_SOUL_GEMS_ENABLE)),
        getFunc = PARMenuFunctions.getAutoBuySoulGemsEnabledSetting,
        setFunc = PARMenuFunctions.setAutoBuySoulGemsEnabledSetting,
        disabled = PARProfileManager.isNoProfileSelected,
        default = PARMenuDefaults.autoBuySoulGemsEnabled,
    })
	
	PARepairOptionsTable:insert({
        type = "submenu",
        name = string.format(GetString(SI_PA_MENU_BUY_ITEM_HEADER), GetItemLinkName("|H0:item:33271:370:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h")),
        icon = GetItemLinkIcon("|H0:item:33271:370:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h"),
        controls = PARBuyFullSoulGemsSubmenuTable,
        disabledLabel = PARMenuFunctions.isBuyFullSoulGemsMenuDisabled,
    })
	
	PARepairOptionsTable:insert({
        type = "submenu",
        name = string.format(GetString(SI_PA_MENU_BUY_ITEM_HEADER), GetItemLinkName("|H0:item:33265:370:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h")),
        icon = GetItemLinkIcon("|H0:item:33265:370:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h"),
        controls = PARBuyEmptySoulGemsSubmenuTable,
        disabledLabel = PARMenuFunctions.isBuyEmptySoulGemsMenuDisabled,
    })	
	
	PARepairOptionsTable:insert({
        type = "submenu",
        name = string.format(GetString(SI_PA_MENU_BUY_ITEM_HEADER), GetItemLinkName("|H0:item:30357:370:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h")),
        icon = GetItemLinkIcon("|H0:item:30357:370:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h"),
        controls = PARBuyLockpicksSubmenuTable,
        disabledLabel = PARMenuFunctions.isBuyLockpicksMenuDisabled,
    })
	
    -- ---------------------------------------------------------------------------------------------------------
	
	PARepairOptionsTable:insert({
        type = "header",
        name = PAC.COLOR.YELLOW:Colorize(GetString(SI_PA_MENU_BUY_SIEGE_ITEMS_HEADER))
    })
	
	PARepairOptionsTable:insert({
        type = "checkbox",
        name = PAC.COLOR.LIGHT_BLUE:Colorize(GetString(SI_PA_MENU_BUY_SIEGE_ITEMS_ENABLE)),
        getFunc = PARMenuFunctions.getAutoBuySiegeItemsEnabledSetting,
        setFunc = PARMenuFunctions.setAutoBuySiegeItemsEnabledSetting,
        disabled = PARProfileManager.isNoProfileSelected,
        default = PARMenuDefaults.autoBuySiegeItemsEnabled,
    })
	
	insertBuySiegeItemsMenu()
	

    -- ---------------------------------------------------------------------------------------------------------

    PARepairOptionsTable:insert({
        type = "header",
        name = PAC.COLOR.YELLOW:Colorize(GetString(SI_PA_MENU_OTHER_SETTINGS_HEADER))
    })

    PARepairOptionsTable:insert({
        type = "checkbox",
        name = GetString(SI_PA_MENU_SILENT_MODE),
        getFunc = PARMenuFunctions.getSilentModeSetting,
        setFunc = PARMenuFunctions.setSilentModeSetting,
        disabled = PARMenuFunctions.isSilentModeDisabled,
        default = PARMenuDefaults.silentMode,
    })
end

-- =================================================================================================================

local function _createPARepairProfileSubMenuTable()
    PARepairProfileSubMenuTable:insert({
        type = "dropdown",
        name = GetString(SI_PA_MENU_PROFILE_ACTIVE),
        tooltip = GetString(SI_PA_MENU_PROFILE_ACTIVE_T),
        choices = PARProfileManager.getProfileList(),
        choicesValues = PARProfileManager.getProfileListValues(),
        width = "half",
        getFunc = PARProfileManager.getActiveProfile,
        setFunc = PARProfileManager.setActiveProfile,
        reference = "PERSONALASSISTANT_REPAIR_PROFILEDROPDOWN"
    })

    PARepairProfileSubMenuTable:insert({
        type = "editbox",
        name = GetString(SI_PA_MENU_PROFILE_ACTIVE_RENAME),
        maxChars = 40,
        width = "half",
        getFunc = PARProfileManager.getActiveProfileName,
        setFunc = PARProfileManager.setActiveProfileName,
        disabled = PARProfileManager.isNoProfileSelected
    })

    PARepairProfileSubMenuTable:insert({
        type = "button",
        name = GetString(SI_PA_MENU_PROFILE_CREATE_NEW),
        width = "half",
        func = PARProfileManager.createNewProfile,
        disabled = PARProfileManager.hasMaxProfileCountReached
    })

    PARepairProfileSubMenuTable:insert({
        type = "description",
        text = GetString(SI_PA_MENU_PROFILE_CREATE_NEW_DESC),
        disabled = function() return not PARProfileManager.hasMaxProfileCountReached() end
    })

    PARepairProfileSubMenuTable:insert({
        type = "divider",
        alpha = 0.5,
    })

    PARepairProfileSubMenuTable:insert({
        type = "description",
        text = GetString(SI_PA_MENU_PROFILE_COPY_FROM_DESC),
        disabled = function() return PARProfileManager.hasOnlyOneProfile() or PARProfileManager.isNoProfileSelected() end,
    })

    PARepairProfileSubMenuTable:insert({
        type = "dropdown",
        name = GetString(SI_PA_MENU_PROFILE_COPY_FROM),
        choices = PARProfileManager.getInactiveProfileList(),
        choicesValues = PARProfileManager.getInactiveProfileListValues(),
        width = "half",
        getFunc = function() return PA.Repair.selectedCopyProfile end,
        setFunc = function(value) PA.Repair.selectedCopyProfile = value end,
        disabled = function() return PARProfileManager.hasOnlyOneProfile() or PARProfileManager.isNoProfileSelected() end,
        reference = "PERSONALASSISTANT_REPAIR_PROFILEDROPDOWN_COPY"
    })

    PARepairProfileSubMenuTable:insert({
        type = "button",
        name = GetString(SI_PA_MENU_PROFILE_COPY_FROM_CONFIRM),
        width = "half",
        func = PARProfileManager.copySelectedProfile,
        isDangerous = true,
        warning = GetString(SI_PA_MENU_PROFILE_COPY_FROM_CONFIRM_W),
        disabled = PARProfileManager.isNoCopyProfileSelected
    })

    PARepairProfileSubMenuTable:insert({
        type = "divider",
        alpha = 0.5,
    })

    PARepairProfileSubMenuTable:insert({
        type = "description",
        text = GetString(SI_PA_MENU_PROFILE_DELETE_DESC),
        disabled = PARProfileManager.hasOnlyOneProfile
    })

    PARepairProfileSubMenuTable:insert({
        type = "dropdown",
        name = GetString(SI_PA_MENU_PROFILE_DELETE),
        choices = PARProfileManager.getInactiveProfileList(),
        choicesValues = PARProfileManager.getInactiveProfileListValues(),
        width = "half",
        getFunc = function() return PA.Repair.selectedDeleteProfile end,
        setFunc = function(value) PA.Repair.selectedDeleteProfile = value end,
        disabled = PARProfileManager.hasOnlyOneProfile,
        reference = "PERSONALASSISTANT_REPAIR_PROFILEDROPDOWN_DELETE"
    })

    PARepairProfileSubMenuTable:insert({
        type = "button",
        name = GetString(SI_PA_MENU_PROFILE_DELETE_CONFIRM),
        width = "half",
        func = PARProfileManager.deleteSelectedProfile,
        isDangerous = true,
        warning = GetString(SI_PA_MENU_PROFILE_DELETE_CONFIRM_W),
        disabled = PARProfileManager.isNoDeleteProfileSelected
    })
end

-- =================================================================================================================

local function _createPARGoldSubmenuTable()
    PARGoldEquippedSubmenuTable:insert({
        type = "checkbox",
        name = GetString(SI_PA_MENU_REPAIR_GOLD_ENABLE),
        tooltip = GetString(SI_PA_MENU_REPAIR_GOLD_ENABLE_T),
        getFunc = PARMenuFunctions.getRepairEquippedWithGoldSetting,
        setFunc = PARMenuFunctions.setRepairEquippedWithGoldSetting,
        disabled = PARMenuFunctions.isRepairEquippedWithGoldDisabled,
        default = PARMenuDefaults.RepairEquipped.repairWithGold,
    })

    PARGoldEquippedSubmenuTable:insert({
        type = "slider",
        name = GetString(SI_PA_MENU_REPAIR_GOLD_DURABILITY),
        tooltip = GetString(SI_PA_MENU_REPAIR_GOLD_DURABILITY_T),
        min = 0,
        max = 99,
        step = 1,
        getFunc = PARMenuFunctions.getRepairEquippedWithGoldDurabilityThresholdSetting,
        setFunc = PARMenuFunctions.setRepairEquippedWithGoldDurabilityThresholdSetting,
        disabled = PARMenuFunctions.isRepairEquippedWithGoldDurabilityThresholdDisabled,
        default = PARMenuDefaults.RepairEquipped.repairWithGoldDurabilityThreshold,
    })
end

-- -----------------------------------------------------------------------------------------------------------------

local function _createPARRepairKitSubmenuTable()
    PARRepairKitSubmenuTable:insert({
        type = "checkbox",
        name = GetString(SI_PA_MENU_REPAIR_REPAIRKIT_ENABLE),
        tooltip = GetString(SI_PA_MENU_REPAIR_REPAIRKIT_ENABLE_T),
        getFunc = PARMenuFunctions.getRepairWithRepairKitSetting,
        setFunc = PARMenuFunctions.setRepairWithRepairKitSetting,
        disabled = PARMenuFunctions.isRepairWithRepairKitDisabled,
        default = PARMenuDefaults.RepairEquipped.repairWithRepairKit,
    })

    PARRepairKitSubmenuTable:insert({
        type = "dropdown",
        name = GetString(SI_PA_MENU_REPAIR_REPAIRKIT_DEFAULT_KIT),
        tooltip = GetString(SI_PA_MENU_REPAIR_REPAIRKIT_DEFAULT_KIT_T),
		width = "half",
        choices = PARMenuChoices.defaultRepairKit,
        choicesValues = PARMenuChoicesValues.defaultRepairKit,
        getFunc = PARMenuFunctions.getRepairDefaultRepairKitSetting,
        setFunc = PARMenuFunctions.setRepairDefaultRepairKitSetting,
        disabled = PARMenuFunctions.isRepairDefaultRepairKitDisabled,
        default = PARMenuDefaults.RepairEquipped.defaultRepairKit,
    })
	
    PARRepairKitSubmenuTable:insert({
        type = "checkbox",
        name = GetString(SI_PA_MENU_REPAIR_REPAIRKIT_GROUP),
        tooltip = GetString(SI_PA_MENU_REPAIR_REPAIRKIT_GROUP_T),
        width = "half",
        getFunc = PARMenuFunctions.getGroupRepairKitSetting,
        setFunc = PARMenuFunctions.setGroupRepairKitSetting,
        disabled = PARMenuFunctions.isGroupRepairKitDisabled,
        default = PARMenuDefaults.RepairEquipped.groupRepairKit,
    })

    PARRepairKitSubmenuTable:insert({
        type = "slider",
        name = GetString(SI_PA_MENU_REPAIR_REPAIRKIT_DURABILITY),
        tooltip = GetString(SI_PA_MENU_REPAIR_REPAIRKIT_DURABILITY_T),
        min = 0,
        max = 99,
        step = 1,
        getFunc = PARMenuFunctions.getRepairWithRepairKitDurabilityThresholdSetting,
        setFunc = PARMenuFunctions.setRepairWithRepairKitDurabilityThresholdSetting,
        disabled = PARMenuFunctions.isRepairWithRepairKitDurabilityThresholdDisabled,
        default = PARMenuDefaults.RepairEquipped.repairWithRepairKitThreshold,
    })

    PARRepairKitSubmenuTable:insert({
        type = "checkbox",
        name = GetString(SI_PA_MENU_REPAIR_REPAIRKIT_LOW_KIT_WARNING),
        tooltip = GetString(SI_PA_MENU_REPAIR_REPAIRKIT_LOW_KIT_WARNING_T),
        width = "half",
        getFunc = PARMenuFunctions.getLowRepairKitWarningSetting,
        setFunc = PARMenuFunctions.setLowRepairKitWarningSetting,
        disabled = PARMenuFunctions.isLowRepairKitWarningDisabled,
        default = PARMenuDefaults.RepairEquipped.lowRepairKitWarning,
    })

    PARRepairKitSubmenuTable:insert({
        type = "slider",
        name = GetString(SI_PA_MENU_REPAIR_REPAIRKIT_LOW_KIT_THRESHOLD),
        tooltip = GetString(SI_PA_MENU_REPAIR_REPAIRKIT_LOW_KIT_THRESHOLD_T),
        min = 0,
        max = 200,
        step = 1,
        width = "half",
        getFunc = PARMenuFunctions.getLowRepairKitThresholdSetting,
        setFunc = PARMenuFunctions.setLowRepairKitThresholdSetting,
        disabled = PARMenuFunctions.isLowRepairKitThresholdDisabled,
        default = PARMenuDefaults.RepairEquipped.lowRepairKitThreshold,
    })
end

-- -----------------------------------------------------------------------------------------------------------------

local function _createPARRechargeSubmenuTable()
    PARRechargeSubmenuTable:insert({
        type = "checkbox",
        name = GetString(SI_PA_MENU_REPAIR_RECHARGE_ENABLE),
        tooltip = GetString(SI_PA_MENU_REPAIR_RECHARGE_ENABLE_T),
        getFunc = PARMenuFunctions.getRechargeWithSoulGemSetting,
        setFunc = PARMenuFunctions.setRechargeWithSoulGemSetting,
        disabled = PARMenuFunctions.isRechargeWithSoulGemDisabled,
        default = PARMenuDefaults.RechargeWeapons.useSoulGems,
    })

    PARRechargeSubmenuTable:insert({
        type = "dropdown",
        name = GetString(SI_PA_MENU_REPAIR_RECHARGE_DEFAULT_GEM),
        tooltip = GetString(SI_PA_MENU_REPAIR_RECHARGE_DEFAULT_GEM_T),
        choices = PARMenuChoices.defaultSoulGem,
        choicesValues = PARMenuChoicesValues.defaultSoulGem,
        getFunc = PARMenuFunctions.getRechargeDefaultSoulGemSetting,
        setFunc = PARMenuFunctions.setRechargeDefaultSoulGemSetting,
        disabled = PARMenuFunctions.isRechargeDefaultSoulGemDisabled,
        default = PARMenuDefaults.RechargeWeapons.defaultSoulGem,
    })

    PARRechargeSubmenuTable:insert({
        type = "checkbox",
        name = GetString(SI_PA_MENU_REPAIR_RECHARGE_LOW_GEM_WARNING),
        tooltip = GetString(SI_PA_MENU_REPAIR_RECHARGE_LOW_GEM_WARNING_T),
        width = "half",
        getFunc = PARMenuFunctions.getLowSoulGemWarningSetting,
        setFunc = PARMenuFunctions.setLowSoulGemWarningSetting,
        disabled = PARMenuFunctions.isLowSoulGemWarningDisabled,
        default = PARMenuDefaults.RechargeWeapons.lowSoulGemWarning,
    })

    PARRechargeSubmenuTable:insert({
        type = "slider",
        name = GetString(SI_PA_MENU_REPAIR_RECHARGE_LOW_GEM_THRESHOLD),
        tooltip = GetString(SI_PA_MENU_REPAIR_RECHARGE_LOW_GEM_THRESHOLD_T),
        min = 0,
        max = 200,
        step = 1,
        width = "half",
        getFunc = PARMenuFunctions.getLowSoulGemThresholdSetting,
        setFunc = PARMenuFunctions.setLowSoulGemThresholdSetting,
        disabled = PARMenuFunctions.isLowSoulGemThresholdDisabled,
        default = PARMenuDefaults.RechargeWeapons.lowSoulGemThreshold,
    })
end

-- -----------------------------------------------------------------------------------------------------------------

local function _createPARGoldInventorySubmenuTable()
    PARGoldInventorySubmenuTable:insert({
        type = "checkbox",
        name = GetString(SI_PA_MENU_REPAIR_GOLD_INVENTORY_ENABLE),
        tooltip = GetString(SI_PA_MENU_REPAIR_GOLD_INVENTORY_ENABLE_T),
        getFunc = PARMenuFunctions.getRepairInventoryWithGoldSetting,
        setFunc = PARMenuFunctions.setRepairInventoryWithGoldSetting,
        disabled = PARMenuFunctions.isRepairInventoryWithGoldDisabled,
        default = PARMenuDefaults.RepairInventory.repairWithGold,
    })

    PARGoldInventorySubmenuTable:insert({
        type = "slider",
        name = GetString(SI_PA_MENU_REPAIR_GOLD_INVENTORY_DURABILITY),
        tooltip = GetString(SI_PA_MENU_REPAIR_GOLD_INVENTORY_DURABILITY_T),
        min = 0,
        max = 99,
        step = 1,
        getFunc = PARMenuFunctions.getRepairInventoryWithGoldDurabilityThresholdSetting,
        setFunc = PARMenuFunctions.setRepairInventoryWithGoldDurabilityThresholdSetting,
        disabled = PARMenuFunctions.isRepairInventoryWithGoldDurabilityThresholdDisabled,
        default = PARMenuDefaults.RepairInventory.repairWithGoldDurabilityThreshold,
    })
end

-- -----------------------------------------------------------------------------------------------------------------

local function _createPARBuyEquipmentRepairKitsSubmenuTable()
    
	PARBuyEquipmentRepairKitsSubmenuTable:insert({
		type = "description",
		text = PAHF.getFormattedCurrency(420, CURT_MONEY, true),
    })
	
	PARBuyEquipmentRepairKitsSubmenuTable:insert({
        type = "checkbox",
        name = string.format(GetString(SI_PA_MENU_BUY_ITEM_ENABLE), GetItemLinkName("|H0:item:44879:1:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h")),
        tooltip = string.format(GetString(SI_PA_MENU_BUY_ITEM_ENABLE_T), GetItemLinkName("|H0:item:44879:1:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h")),
        getFunc = PARMenuFunctions.getBuyEquipmentRepairKitsSetting,
        setFunc = PARMenuFunctions.setBuyEquipmentRepairKitsSetting,
        disabled = PARMenuFunctions.isBuyEquipmentRepairKitsDisabled,
        default = PARMenuDefaults.AutoBuyRepairKits.buyEquipmentRepairKits,
    })


    PARBuyEquipmentRepairKitsSubmenuTable:insert({
        type = "slider",
        name = string.format(GetString(SI_PA_MENU_BUY_ITEM_THRESHOLD), GetItemLinkName("|H0:item:44879:1:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h")),
        tooltip = string.format(GetString(SI_PA_MENU_BUY_ITEM_THRESHOLD_T), GetItemLinkName("|H0:item:44879:1:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h")),
        min = 0,
        max = 200,
        step = 1,
        width = "full",
        getFunc = PARMenuFunctions.getBuyEquipmentRepairKitsThresholdSetting,
        setFunc = PARMenuFunctions.setBuyEquipmentRepairKitsThresholdSetting,
        disabled = PARMenuFunctions.isBuyEquipmentRepairKitsThresholdDisabled,
        default = PARMenuDefaults.AutoBuyRepairKits.buyEquipmentRepairKitsThreshold,
    })
end

-- -----------------------------------------------------------------------------------------------------------------

local function _createPARBuyCyrodiilRepairKitsSubmenuTable() 
	PARBuyCyrodiilRepairKitsSubmenuTable:insert({
		type = "description",
		text = PAHF.getFormattedCurrency(250, CURT_ALLIANCE_POINTS, true).."    "..PAHF.getFormattedCurrency(90, CURT_MONEY, true),
    })
	
	PARBuyCyrodiilRepairKitsSubmenuTable:insert({
        type = "checkbox",
        name = string.format(GetString(SI_PA_MENU_BUY_ITEM_ENABLE), GetItemLinkName("|H0:item:204483:1:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h")),
        tooltip = string.format(GetString(SI_PA_MENU_BUY_ITEM_ENABLE_T), GetItemLinkName("|H0:item:204483:1:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h")),
        getFunc = PARMenuFunctions.getBuyCyrodiilRepairKitsSetting,
        setFunc = PARMenuFunctions.setBuyCyrodiilRepairKitsSetting,
        disabled = PARMenuFunctions.isBuyCyrodiilRepairKitsDisabled,
        default = PARMenuDefaults.AutoBuyRepairKits.buyCyrodiilRepairKits,
    })


    PARBuyCyrodiilRepairKitsSubmenuTable:insert({
        type = "slider",
        name = string.format(GetString(SI_PA_MENU_BUY_ITEM_THRESHOLD), GetItemLinkName("|H0:item:204483:1:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h")),
        tooltip = string.format(GetString(SI_PA_MENU_BUY_ITEM_THRESHOLD_T), GetItemLinkName("|H0:item:204483:1:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h")),
        min = 0,
        max = 200,
        step = 1,
        width = "full",
        getFunc = PARMenuFunctions.getBuyCyrodiilRepairKitsThresholdSetting,
        setFunc = PARMenuFunctions.setBuyCyrodiilRepairKitsThresholdSetting,
        disabled = PARMenuFunctions.isBuyCyrodiilRepairKitsThresholdDisabled,
        default = PARMenuDefaults.AutoBuyRepairKits.buyCyrodiilRepairKitsThreshold,
    })
	
    PARBuyCyrodiilRepairKitsSubmenuTable:insert({
        type = "dropdown",
        name = string.format(GetString(SI_PA_MENU_BUY_ITEM_PRIORITY), GetItemLinkName("|H0:item:204483:1:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h")),
        tooltip = string.format(GetString(SI_PA_MENU_BUY_ITEM_PRIORITY_T), GetItemLinkName("|H0:item:204483:1:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h")),
        choices = PARMenuFunctions.getCyrodiilRepairKitsPriorityList(),
        choicesValues = PARMenuFunctions.getCyrodiilRepairKitsPriorityValues(),
        width = "full",
        getFunc = PARMenuFunctions.getBuyCyrodiilRepairKitsPrioritySetting,
        setFunc = PARMenuFunctions.setBuyCyrodiilRepairKitsPrioritySetting,
        disabled = PARMenuFunctions.isBuyCyrodiilRepairKitsPriorityDisabled,
        default = PARMenuDefaults.AutoBuyRepairKits.buyCyrodiilRepairKitsPriority,
        reference = "PERSONALASSISTANT_REPAIR_CYROPRIORITYDROPDOWN"
    })
end


-- -----------------------------------------------------------------------------------------------------------------

local function _createPARBuyFullSoulGemsSubmenuTable()
    		
	PARBuyFullSoulGemsSubmenuTable:insert({
		type = "description",
		text = PAHF.getFormattedCurrency(750, CURT_ALLIANCE_POINTS, true).."(PvP)    "..PAHF.getFormattedCurrency(500, CURT_MONEY, true).."(PvE)" ,
    })
	
	PARBuyFullSoulGemsSubmenuTable:insert({
        type = "checkbox",
        name = string.format(GetString(SI_PA_MENU_BUY_ITEM_ENABLE), GetItemLinkName("|H0:item:33271:370:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h")),
        tooltip = string.format(GetString(SI_PA_MENU_BUY_ITEM_ENABLE_T), GetItemLinkName("|H0:item:33271:370:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h")),
        getFunc = PARMenuFunctions.getBuyFullSoulGemsSetting,
        setFunc = PARMenuFunctions.setBuyFullSoulGemsSetting,
        disabled = PARMenuFunctions.isBuyFullSoulGemsDisabled,
        default = PARMenuDefaults.AutoBuySoulGems.buyFullSoulGems,
    })


    PARBuyFullSoulGemsSubmenuTable:insert({
        type = "slider",
        name = string.format(GetString(SI_PA_MENU_BUY_ITEM_THRESHOLD), GetItemLinkName("|H0:item:33271:370:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h")),
        tooltip = string.format(GetString(SI_PA_MENU_BUY_ITEM_THRESHOLD_T), GetItemLinkName("|H0:item:33271:370:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h")),
        min = 0,
        max = 200,
        step = 1,
        width = "full",
        getFunc = PARMenuFunctions.getBuyFullSoulGemsThresholdSetting,
        setFunc = PARMenuFunctions.setBuyFullSoulGemsThresholdSetting,
        disabled = PARMenuFunctions.isBuyFullSoulGemsThresholdDisabled,
        default = PARMenuDefaults.AutoBuySoulGems.buyFullSoulGemsThreshold,
    })
end

-- -----------------------------------------------------------------------------------------------------------------

local function _createPARBuyEmptySoulGemsSubmenuTable()
	PARBuyEmptySoulGemsSubmenuTable:insert({
		type = "description",
		text = PAHF.getFormattedCurrency(156, CURT_MONEY, true),
    })
	
	PARBuyEmptySoulGemsSubmenuTable:insert({
        type = "checkbox",
        name = string.format(GetString(SI_PA_MENU_BUY_ITEM_ENABLE), GetItemLinkName("|H0:item:33265:370:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h")),
        tooltip = string.format(GetString(SI_PA_MENU_BUY_ITEM_ENABLE_T), GetItemLinkName("|H0:item:33265:370:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h")),
        getFunc = PARMenuFunctions.getBuyEmptySoulGemsSetting,
        setFunc = PARMenuFunctions.setBuyEmptySoulGemsSetting,
        disabled = PARMenuFunctions.isBuyEmptySoulGemsDisabled,
        default = PARMenuDefaults.AutoBuySoulGems.buyEmptySoulGems,
    })


    PARBuyEmptySoulGemsSubmenuTable:insert({
        type = "slider",
        name = string.format(GetString(SI_PA_MENU_BUY_ITEM_THRESHOLD), GetItemLinkName("|H0:item:33265:370:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h")),
        tooltip = string.format(GetString(SI_PA_MENU_BUY_ITEM_THRESHOLD_T), GetItemLinkName("|H0:item:33265:370:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h")),
        min = 0,
        max = 200,
        step = 1,
        width = "full",
        getFunc = PARMenuFunctions.getBuyEmptySoulGemsThresholdSetting,
        setFunc = PARMenuFunctions.setBuyEmptySoulGemsThresholdSetting,
        disabled = PARMenuFunctions.isBuyEmptySoulGemsThresholdDisabled,
        default = PARMenuDefaults.AutoBuySoulGems.buyEmptySoulGemsThreshold,
    })
end


-- -----------------------------------------------------------------------------------------------------------------

local function _createPARBuyLockpicksSubmenuTable()
	PARBuyLockpicksSubmenuTable:insert({
		type = "description",
		text = PAHF.getFormattedCurrency(9, CURT_MONEY, true),
    })
	
	PARBuyLockpicksSubmenuTable:insert({
        type = "checkbox",
        name = string.format(GetString(SI_PA_MENU_BUY_ITEM_ENABLE), GetItemLinkName("|H0:item:30357:370:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h")),
        tooltip = string.format(GetString(SI_PA_MENU_BUY_ITEM_ENABLE_T), GetItemLinkName("|H0:item:30357:370:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h")),
        getFunc = PARMenuFunctions.getBuyLockpicksSetting,
        setFunc = PARMenuFunctions.setBuyLockpicksSetting,
        disabled = PARMenuFunctions.isBuyLockpicksDisabled,
        default = PARMenuDefaults.AutoBuySoulGems.buyLockpicks,
    })


    PARBuyLockpicksSubmenuTable:insert({
        type = "slider",
        name = string.format(GetString(SI_PA_MENU_BUY_ITEM_THRESHOLD), GetItemLinkName("|H0:item:30357:370:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h")),
        tooltip = string.format(GetString(SI_PA_MENU_BUY_ITEM_THRESHOLD_T), GetItemLinkName("|H0:item:30357:370:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h")),
        min = 0,
        max = 200,
        step = 1,
        width = "full",
        getFunc = PARMenuFunctions.getBuyLockpicksThresholdSetting,
        setFunc = PARMenuFunctions.setBuyLockpicksThresholdSetting,
        disabled = PARMenuFunctions.isBuyLockpicksThresholdDisabled,
        default = PARMenuDefaults.AutoBuySoulGems.buyLockpicksThreshold,
    })
end


-- =================================================================================================================

local function createOptions()
    _createPARepairMenu()

    _createPARepairProfileSubMenuTable()

    _createPARGoldSubmenuTable()
    _createPARRepairKitSubmenuTable()
    _createPARRechargeSubmenuTable()

    _createPARGoldInventorySubmenuTable()
	
	_createPARBuyEquipmentRepairKitsSubmenuTable()
	_createPARBuyCyrodiilRepairKitsSubmenuTable()
	
	_createPARBuyFullSoulGemsSubmenuTable()
	_createPARBuyEmptySoulGemsSubmenuTable()
	_createPARBuyLockpicksSubmenuTable()


    PA.LAM2:RegisterAddonPanel("PersonalAssistantRepairAddonOptions", PARepairPanelData)
    PA.LAM2:RegisterOptionControls("PersonalAssistantRepairAddonOptions", PARepairOptionsTable)
end

-- =====================================================================================================================
-- Export
PA.Repair = PA.Repair or {}
PA.Repair.createOptions = createOptions
