-- Local instances of Global tables --
local PA = PersonalAssistant
local PAR = PA.Repair
local PAMF = PA.MenuFunctions
local PAEM = PA.EventManager
local PARProfileManager = PA.ProfileManager.PARepair

-- =====================================================================================================================

local isNoProfileSelected = PARProfileManager.isNoProfileSelected

local function getValue(...)
    if isNoProfileSelected() then return end
    return PAMF.getValue(PAR.SavedVars, ...)
end

local function setValue(value, ...)
    if isNoProfileSelected() then return end
    PAMF.setValue(PAR.SavedVars, value, ...)
end

local function setValueAndRefreshEvents(value, ...)
    setValue(value, ...)
    PAEM.RefreshEventRegistration.PARepair()
end

local function isDisabled(...)
    if isNoProfileSelected() then return true end
    return PAMF.isDisabled(PAR.SavedVars, ...)
end

local function isDisabledAll(...)
    if isNoProfileSelected() then return true end
    return PAMF.isDisabledAll(PAR.SavedVars, ...)
end

-- =================================================================================================================

local PARepairMenuFunctions = {
    -- -----------------------------------------------------------------------------------
    -- REPAIR EQUIPPED
    -- -----------------------------
    getAutoRepairEquippedEnabledSetting = function() return getValue({"autoRepairEnabled"}) end,
    setAutoRepairEquippedEnabledSetting = function(value) setValueAndRefreshEvents(value, {"autoRepairEnabled"}) end,

    -- Repair with Gold --
    isRepairEquippedWithGoldMenuDisabled = function() return isDisabled({"autoRepairEnabled"}, {"RepairEquipped", "repairWithGold"}) end,
    isRepairEquippedWithGoldDisabled = function() return isDisabled({"autoRepairEnabled"}) end,
    getRepairEquippedWithGoldSetting = function() return getValue({"RepairEquipped", "repairWithGold"}) end,
    setRepairEquippedWithGoldSetting = function(value) setValueAndRefreshEvents(value, {"RepairEquipped", "repairWithGold"}) end,

    isRepairEquippedWithGoldDurabilityThresholdDisabled = function() return isDisabled({"autoRepairEnabled"}, {"RepairEquipped", "repairWithGold"}) end,
    getRepairEquippedWithGoldDurabilityThresholdSetting = function() return getValue({"RepairEquipped", "repairWithGoldDurabilityThreshold"}) end,
    setRepairEquippedWithGoldDurabilityThresholdSetting = function(value) setValue(value, {"RepairEquipped", "repairWithGoldDurabilityThreshold"}) end,

    -- Repair with Repair Kits --
    isRepairWithRepairKitMenuDisabled = function() return isDisabled({"autoRepairEnabled"}, {"RepairEquipped", "repairWithRepairKit"}) end,
    isRepairWithRepairKitDisabled = function() return isDisabled({"autoRepairEnabled"}) end,
    getRepairWithRepairKitSetting = function() return getValue({"RepairEquipped", "repairWithRepairKit"}) end,
    setRepairWithRepairKitSetting = function(value) setValueAndRefreshEvents(value, {"RepairEquipped", "repairWithRepairKit"}) end,

    isRepairDefaultRepairKitDisabled = function() return isDisabled({"autoRepairEnabled"}, {"RepairEquipped", "repairWithRepairKit"}) end,
    getRepairDefaultRepairKitSetting = function() return getValue({"RepairEquipped", "defaultRepairKit"}) end,
    setRepairDefaultRepairKitSetting = function(value) setValueAndRefreshEvents(value, {"RepairEquipped", "defaultRepairKit"}) end,
	
    isGroupRepairKitDisabled = function() return isDisabled({"autoRepairEnabled"}, {"RepairEquipped", "repairWithRepairKit"}) end,
    getGroupRepairKitSetting = function() return getValue({"RepairEquipped", "groupRepairKit"}) end,
    setGroupRepairKitSetting = function(value) setValue(value, {"RepairEquipped", "groupRepairKit"}) end,

    isRepairWithRepairKitDurabilityThresholdDisabled = function() return isDisabled({"autoRepairEnabled"}, {"RepairEquipped", "repairWithRepairKit"}) end,
    getRepairWithRepairKitDurabilityThresholdSetting = function() return getValue({"RepairEquipped", "repairWithRepairKitThreshold"}) end,
    setRepairWithRepairKitDurabilityThresholdSetting = function(value) setValue(value, {"RepairEquipped", "repairWithRepairKitThreshold"}) end,

    isLowRepairKitWarningDisabled = function() return isDisabled({"autoRepairEnabled"}, {"RepairEquipped", "repairWithRepairKit"}) end,
    getLowRepairKitWarningSetting = function() return getValue({"RepairEquipped", "lowRepairKitWarning"}) end,
    setLowRepairKitWarningSetting = function(value) setValue(value, {"RepairEquipped", "lowRepairKitWarning"}) end,

    isLowRepairKitThresholdDisabled = function() return isDisabled({"autoRepairEnabled"}, {"RepairEquipped", "repairWithRepairKit"}, {"RepairEquipped", "lowRepairKitWarning"}) end,
    getLowRepairKitThresholdSetting = function() return getValue({"RepairEquipped", "lowRepairKitThreshold"}) end,
    setLowRepairKitThresholdSetting = function(value) setValue(value, {"RepairEquipped", "lowRepairKitThreshold"}) end,

    -- Recharge with Soul Gems --
    isRechargeWithSoulGemMenuDisabled = function() return isDisabled({"autoRepairEnabled"}, {"RechargeWeapons", "useSoulGems"}) end,
    isRechargeWithSoulGemDisabled = function() return isDisabled({"autoRepairEnabled"}) end,
    getRechargeWithSoulGemSetting = function() return getValue({"RechargeWeapons", "useSoulGems"}) end,
    setRechargeWithSoulGemSetting = function(value) setValueAndRefreshEvents(value, {"RechargeWeapons", "useSoulGems"}) end,

    isRechargeDefaultSoulGemDisabled = function() return isDisabled({"autoRepairEnabled"}, {"RechargeWeapons", "useSoulGems"}) end,
    getRechargeDefaultSoulGemSetting = function() return getValue({"RechargeWeapons", "defaultSoulGem"}) end,
    setRechargeDefaultSoulGemSetting = function(value) setValueAndRefreshEvents(value, {"RechargeWeapons", "defaultSoulGem"}) end,

    isLowSoulGemWarningDisabled = function() return isDisabled({"autoRepairEnabled"}, {"RechargeWeapons", "useSoulGems"}) end,
    getLowSoulGemWarningSetting = function() return getValue({"RechargeWeapons", "lowSoulGemWarning"}) end,
    setLowSoulGemWarningSetting = function(value) setValue(value, {"RechargeWeapons", "lowSoulGemWarning"}) end,

    isLowSoulGemThresholdDisabled = function() return isDisabled({"autoRepairEnabled"}, {"RechargeWeapons", "useSoulGems"}, {"RechargeWeapons", "lowSoulGemWarning"}) end,
    getLowSoulGemThresholdSetting = function() return getValue({"RechargeWeapons", "lowSoulGemThreshold"}) end,
    setLowSoulGemThresholdSetting = function(value) setValue(value, {"RechargeWeapons", "lowSoulGemThreshold"}) end,


    -- -----------------------------------------------------------------------------------
    -- REPAIR INVENTORY
    -- -----------------------------
    getAutoRepairInventoryEnabledSetting = function() return getValue({"autoRepairInventoryEnabled"}) end,
    setAutoRepairInventoryEnabledSetting = function(value) setValueAndRefreshEvents(value, {"autoRepairInventoryEnabled"}) end,

    -- Repair with Gold --
    isRepairInventoryWithGoldMenuDisabled = function() return isDisabled({"autoRepairInventoryEnabled"}, {"RepairInventory", "repairWithGold"}) end,
    isRepairInventoryWithGoldDisabled = function() return isDisabled({"autoRepairInventoryEnabled"}) end,
    getRepairInventoryWithGoldSetting = function() return getValue({"RepairInventory", "repairWithGold"}) end,
    setRepairInventoryWithGoldSetting = function(value) setValueAndRefreshEvents(value, {"RepairInventory", "repairWithGold"}) end,

    isRepairInventoryWithGoldDurabilityThresholdDisabled = function() return isDisabled({"autoRepairInventoryEnabled"}, {"RepairInventory", "repairWithGold"}) end,
    getRepairInventoryWithGoldDurabilityThresholdSetting = function() return getValue({"RepairInventory", "repairWithGoldDurabilityThreshold"}) end,
    setRepairInventoryWithGoldDurabilityThresholdSetting = function(value) setValue(value, {"RepairInventory", "repairWithGoldDurabilityThreshold"}) end,


    -- -----------------------------------------------------------------------------------
    -- BUY EQUIPMENT REPAIR KITS
    -- -----------------------------
    getAutoBuyRepairKitsEnabledSetting = function() return getValue({"autoBuyRepairKitsEnabled"}) end,	
    setAutoBuyRepairKitsEnabledSetting = function(value) setValueAndRefreshEvents(value, {"autoBuyRepairKitsEnabled"}) end,
	
	-- Buy Equipment Repair kits -- 
    isBuyEquipmentRepairKitsMenuDisabled = function() return isDisabled({"autoBuyRepairKitsEnabled"}, {"AutoBuyRepairKits", "buyEquipmentRepairKits"}) end,
	isBuyEquipmentRepairKitsDisabled = function() return isDisabled({"autoBuyRepairKitsEnabled"}) end,
	getBuyEquipmentRepairKitsSetting = function() return getValue({"AutoBuyRepairKits", "buyEquipmentRepairKits"}) end,
    setBuyEquipmentRepairKitsSetting = function(value) setValueAndRefreshEvents(value, {"AutoBuyRepairKits", "buyEquipmentRepairKits"}) end,

    isBuyEquipmentRepairKitsThresholdDisabled = function() return isDisabled({"autoBuyRepairKitsEnabled"}, {"AutoBuyRepairKits", "buyEquipmentRepairKits"}) end,
	getBuyEquipmentRepairKitsThresholdSetting = function() return getValue({"AutoBuyRepairKits", "buyEquipmentRepairKitsThreshold"}) end,
    setBuyEquipmentRepairKitsThresholdSetting = function(value) setValueAndRefreshEvents(value, {"AutoBuyRepairKits", "buyEquipmentRepairKitsThreshold"}) end,

	-- Buy Cyrodiil Repair kits -- 
    isBuyCyrodiilRepairKitsMenuDisabled = function() return isDisabled({"autoBuyRepairKitsEnabled"}, {"AutoBuyRepairKits", "buyCyrodiilRepairKits"}) end,
	
	isBuyCyrodiilRepairKitsDisabled = function() return isDisabled({"autoBuyRepairKitsEnabled"}) end,
	getBuyCyrodiilRepairKitsSetting = function() return getValue({"AutoBuyRepairKits", "buyCyrodiilRepairKits"}) end,
    setBuyCyrodiilRepairKitsSetting = function(value) setValueAndRefreshEvents(value, {"AutoBuyRepairKits", "buyCyrodiilRepairKits"}) end,

    isBuyCyrodiilRepairKitsThresholdDisabled = function() return isDisabled({"autoBuyRepairKitsEnabled"}, {"AutoBuyRepairKits", "buyCyrodiilRepairKits"}) end,
	getBuyCyrodiilRepairKitsThresholdSetting = function() return getValue({"AutoBuyRepairKits", "buyCyrodiilRepairKitsThreshold"}) end,
    setBuyCyrodiilRepairKitsThresholdSetting = function(value) setValueAndRefreshEvents(value, {"AutoBuyRepairKits", "buyCyrodiilRepairKitsThreshold"}) end,

    isBuyCyrodiilRepairKitsPriorityDisabled = function() return isDisabled({"autoBuyRepairKitsEnabled"}, {"AutoBuyRepairKits", "buyCyrodiilRepairKits"}) end,
	getBuyCyrodiilRepairKitsPrioritySetting = function() return getValue({"AutoBuyRepairKits", "buyCyrodiilRepairKitsPriority"}) end,
    setBuyCyrodiilRepairKitsPrioritySetting = function(value) setValueAndRefreshEvents(value, {"AutoBuyRepairKits", "buyCyrodiilRepairKitsPriority"}) end,
    getCyrodiilRepairKitsPriorityList = function() return { GetString(SI_ABANDON_HOME_CAMPAIGN_USE_ALLIANCE_POINTS).." -> "..GetString(SI_ABANDON_HOME_CAMPAIGN_USE_GOLD),GetString(SI_ABANDON_HOME_CAMPAIGN_USE_GOLD).." -> "..GetString(SI_ABANDON_HOME_CAMPAIGN_USE_ALLIANCE_POINTS) ,GetString(SI_ABANDON_HOME_CAMPAIGN_USE_ALLIANCE_POINTS), GetString(SI_ABANDON_HOME_CAMPAIGN_USE_GOLD) } end,
    getCyrodiilRepairKitsPriorityValues = function() return {"AP->GOLD","GOLD->AP","AP","GOLD"} end,
	
	-- Buy Cyrodiil Repair kits -- 
    isBuyBridgeAndMilegateRepairKitsMenuDisabled = function() return isDisabled({"autoBuyRepairKitsEnabled"}, {"AutoBuyRepairKits", "buyBridgeAndMilegateRepairKits"}) end,
	
	isBuyBridgeAndMilegateRepairKitsDisabled = function() return isDisabled({"autoBuyRepairKitsEnabled"}) end,
	getBuyBridgeAndMilegateRepairKitsSetting = function() return getValue({"AutoBuyRepairKits", "buyBridgeAndMilegateRepairKits"}) end,
    setBuyBridgeAndMilegateRepairKitsSetting = function(value) setValueAndRefreshEvents(value, {"AutoBuyRepairKits", "buyBridgeAndMilegateRepairKits"}) end,

    isBuyBridgeAndMilegateRepairKitsThresholdDisabled = function() return isDisabled({"autoBuyRepairKitsEnabled"}, {"AutoBuyRepairKits", "buyBridgeAndMilegateRepairKits"}) end,
	getBuyBridgeAndMilegateRepairKitsThresholdSetting = function() return getValue({"AutoBuyRepairKits", "buyBridgeAndMilegateRepairKitsThreshold"}) end,
    setBuyBridgeAndMilegateRepairKitsThresholdSetting = function(value) setValueAndRefreshEvents(value, {"AutoBuyRepairKits", "buyBridgeAndMilegateRepairKitsThreshold"}) end,

    isBuyBridgeAndMilegateRepairKitsPriorityDisabled = function() return isDisabled({"autoBuyRepairKitsEnabled"}, {"AutoBuyRepairKits", "buyBridgeAndMilegateRepairKits"}) end,
	getBuyBridgeAndMilegateRepairKitsPrioritySetting = function() return getValue({"AutoBuyRepairKits", "buyBridgeAndMilegateRepairKitsPriority"}) end,
    setBuyBridgeAndMilegateRepairKitsPrioritySetting = function(value) setValueAndRefreshEvents(value, {"AutoBuyRepairKits", "buyBridgeAndMilegateRepairKitsPriority"}) end,
    getBridgeAndMilegateRepairKitsPriorityList = function() return { GetString(SI_ABANDON_HOME_CAMPAIGN_USE_ALLIANCE_POINTS).." -> "..GetString(SI_ABANDON_HOME_CAMPAIGN_USE_GOLD),GetString(SI_ABANDON_HOME_CAMPAIGN_USE_GOLD).." -> "..GetString(SI_ABANDON_HOME_CAMPAIGN_USE_ALLIANCE_POINTS) ,GetString(SI_ABANDON_HOME_CAMPAIGN_USE_ALLIANCE_POINTS), GetString(SI_ABANDON_HOME_CAMPAIGN_USE_GOLD) } end,
    getBridgeAndMilegateRepairKitsPriorityValues = function() return {"AP->GOLD","GOLD->AP","AP","GOLD"} end,	
	
    -- -----------------------------------------------------------------------------------
    -- BUY SOUL GEMS & LOCKPICKS
    -- -----------------------------
    getAutoBuySoulGemsEnabledSetting = function() return getValue({"autoBuySoulGemsEnabled"}) end,	
    setAutoBuySoulGemsEnabledSetting = function(value) setValueAndRefreshEvents(value, {"autoBuySoulGemsEnabled"}) end,
	
	-- Buy Full Soul Gems -- 
    isBuyFullSoulGemsMenuDisabled = function() return isDisabled({"autoBuySoulGemsEnabled"}, {"AutoBuySoulGems", "buyFullSoulGems"}) end,
	isBuyFullSoulGemsDisabled = function() return isDisabled({"autoBuySoulGemsEnabled"}) end,
	getBuyFullSoulGemsSetting = function() return getValue({"AutoBuySoulGems", "buyFullSoulGems"}) end,
    setBuyFullSoulGemsSetting = function(value) setValueAndRefreshEvents(value, {"AutoBuySoulGems", "buyFullSoulGems"}) end,

    isBuyFullSoulGemsThresholdDisabled = function() return isDisabled({"autoBuySoulGemsEnabled"}, {"AutoBuySoulGems", "buyFullSoulGems"}) end,
	getBuyFullSoulGemsThresholdSetting = function() return getValue({"AutoBuySoulGems", "buyFullSoulGemsThreshold"}) end,
    setBuyFullSoulGemsThresholdSetting = function(value) setValueAndRefreshEvents(value, {"AutoBuySoulGems", "buyFullSoulGemsThreshold"}) end,

	
	-- Buy Empty Soul Gems -- 
    isBuyEmptySoulGemsMenuDisabled = function() return isDisabled({"autoBuySoulGemsEnabled"}, {"AutoBuySoulGems", "buyEmptySoulGems"}) end,
	isBuyEmptySoulGemsDisabled = function() return isDisabled({"autoBuySoulGemsEnabled"}) end,
	getBuyEmptySoulGemsSetting = function() return getValue({"AutoBuySoulGems", "buyEmptySoulGems"}) end,
    setBuyEmptySoulGemsSetting = function(value) setValueAndRefreshEvents(value, {"AutoBuySoulGems", "buyEmptySoulGems"}) end,

    isBuyEmptySoulGemsThresholdDisabled = function() return isDisabled({"autoBuySoulGemsEnabled"}, {"AutoBuySoulGems", "buyEmptySoulGems"}) end,
	getBuyEmptySoulGemsThresholdSetting = function() return getValue({"AutoBuySoulGems", "buyEmptySoulGemsThreshold"}) end,
    setBuyEmptySoulGemsThresholdSetting = function(value) setValueAndRefreshEvents(value, {"AutoBuySoulGems", "buyEmptySoulGemsThreshold"}) end,

	-- Buy Lockpicks -- 
    isBuyLockpicksMenuDisabled = function() return isDisabled({"autoBuySoulGemsEnabled"}, {"AutoBuySoulGems", "buyLockpicks"}) end,
	isBuyLockpicksDisabled = function() return isDisabled({"autoBuySoulGemsEnabled"}) end,
	getBuyLockpicksSetting = function() return getValue({"AutoBuySoulGems", "buyLockpicks"}) end,
    setBuyLockpicksSetting = function(value) setValueAndRefreshEvents(value, {"AutoBuySoulGems", "buyLockpicks"}) end,

    isBuyLockpicksThresholdDisabled = function() return isDisabled({"autoBuySoulGemsEnabled"}, {"AutoBuySoulGems", "buyLockpicks"}) end,
	getBuyLockpicksThresholdSetting = function() return getValue({"AutoBuySoulGems", "buyLockpicksThreshold"}) end,
    setBuyLockpicksThresholdSetting = function(value) setValueAndRefreshEvents(value, {"AutoBuySoulGems", "buyLockpicksThreshold"}) end,

    -- -----------------------------------------------------------------------------------
    -- BUY SIEGE ITEMS
    -- -----------------------------
    getAutoBuySiegeItemsEnabledSetting = function() return getValue({"autoBuySiegeItemsEnabled"}) end,	
    setAutoBuySiegeItemsEnabledSetting = function(value) setValueAndRefreshEvents(value, {"autoBuySiegeItemsEnabled"}) end,

    AreBuySiegeItemsSubmenusDisabled = function() return isDisabled({"autoBuySiegeItemsEnabled"}) end,
	getBuySiegeItemSetting = function(formatedValue) return getValue(formatedValue) end, 
	setBuySiegeItemSetting = function(value, formatedValue) setValue(value, formatedValue) end,
	isThisBuySiegeItemsSubmenuDisabled = function(formatedValue) return isDisabled({"autoBuySiegeItemsEnabled"}, formatedValue) end,
	





	
    -- -----------------------------------------------------------------------------------
    -- SILENT MODE
    -- -----------------------------
    isSilentModeDisabled = function() return isDisabledAll({"autoRepairEnabled"}, {"autoRepairInventoryEnabled"}) end,
    getSilentModeSetting = function() return getValue({"silentMode"}) end,
    setSilentModeSetting = function(value) setValue(value, {"silentMode"}) end,

}

-- =====================================================================================================================
-- Export
PAMF.PARepair = PARepairMenuFunctions