-- Name: InfoDisplay
-- Version: 1.02

InfoDisplay = {}
InfoDisplay.name = "InfoDisplay"

-- Initialize the chat proxy
local chat = LibChatMessage("InfoDisplay","ID")

-- Define LAM2 object
local LAM2 = LibAddonMenu2

-- Define LAM2 panel settings
local InfoDisplay_LAM2panelData = {
    type = "panel",
    name = "InfoDisplay",
    displayName = "InfoDisplay Options",
    author = "Wheels387",
    slashCommand = "/infodisplay",
    registerForRefresh = true,
}

-- Define LAM2 option settings
local InfoDisplay_LAM2optionsData = {
    [1] = {
        type = "checkbox",
        name = "Lock Display",
        getFunc = function() return InfoDisplay.savedVariables.lockMove end,
        setFunc = function(value) InfoDisplay_SetLock(value) end,
    },
    [2] = {
        type = "checkbox",
        name = "Gear Auto Repair (with repair kits)",
        tooltip = "Enable automatic repair of gear with a repair kit when it gets below the Automatic Repair Threshold value.",
        getFunc = function() return InfoDisplay.savedVariables.autoRepairSetting end,
        setFunc = function(value) InfoDisplay.savedVariables.autoRepairSetting = value end,
    },
    [3] = {
        type = "checkbox",
        name = "Gear Auto Repair (at merchant)",
        tooltip = "Enable automatic repair of gear when visiting a merchant.",
        getFunc = function() return InfoDisplay.savedVariables.autoMerchantRepair end,
        setFunc = function(value) InfoDisplay.savedVariables.autoMerchantRepair = value end,
    },
    [4] = {
        type = "checkbox",
        name = "Weapon Auto Charge",
        tooltip = "Enable automatic charging of weapons with a soul gem when charge gets below the Automatic Charge Threshold value.",
        getFunc = function() return InfoDisplay.savedVariables.autoChargeSetting end,
        setFunc = function(value) InfoDisplay.savedVariables.autoChargeSetting = value end,
    },
    [5] = {
        type = "slider",
        name = "Automatic Repair Threshold",
        tooltip = "If Gear Auto Repair (with repair kits) is enabled, gear will automatically be repaired when it reaches this condition. Gear at a higher condition will not be repaired.",
        min = 1,
        max = 99,
        getFunc = function() return InfoDisplay.savedVariables.minAutoRepair end,
        setFunc = function(value) InfoDisplay.savedVariables.minAutoRepair = value end,
    },
    [6] = {
        type = "slider",
        name = "Manual Repair Threshold",
        tooltip = "When clicking the manual repair button, gear at this condition and lower will be repaired. Gear at a higher condition will not be repaired.",
        min = 1,
        max = 99,
        getFunc = function() return InfoDisplay.savedVariables.minRepairLevel end,
        setFunc = function(value) InfoDisplay.savedVariables.minRepairLevel = value end,
    },
    [7] = {
        type = "slider",
        name = "Automatic Charge Threshold",
        tooltip = "If Weapon Auto Charge is enabled, weapons will automatically be recharged when they reaches this charge level. Weapons at a higher charge level will not be recharged.",
        min = 1,
        max = 99,
        getFunc = function() return InfoDisplay.savedVariables.minAutoCharge end,
        setFunc = function(value) InfoDisplay.savedVariables.minAutoCharge = value end,
    },
    [8] = {
        type = "slider",
        name = "Manual Charge Threshold",
        tooltip = "When clicking the manual charge button, weapons with this charge and lower will be recharged. Weapons at a higher charge level will not be recharged.",
        min = 1,
        max = 99,
        getFunc = function() return InfoDisplay.savedVariables.minChargeLevel end,
        setFunc = function(value) InfoDisplay.savedVariables.minChargeLevel = value end,
    },
}

-- Define equipment slots so we can get repair information
local equip_slots = {
    EQUIP_SLOT_OFF_HAND,
    EQUIP_SLOT_BACKUP_OFF,
    EQUIP_SLOT_HEAD,
    EQUIP_SLOT_SHOULDERS,
    EQUIP_SLOT_CHEST,
    EQUIP_SLOT_WAIST,
    EQUIP_SLOT_LEGS,
    EQUIP_SLOT_HAND,
    EQUIP_SLOT_FEET
}

-- Define weapon slots so we can get charge information
local weapon_slots = {
    EQUIP_SLOT_MAIN_HAND,
    EQUIP_SLOT_OFF_HAND,
    EQUIP_SLOT_BACKUP_MAIN,
    EQUIP_SLOT_BACKUP_OFF
}

-- Inventory items
InfoDisplay_repairKitItemId = 44879
InfoDisplay_chargeKitItemId = 33271

-- Minimum levels for repair and charge buttons
local InfoDisplay_minRepairDefault = 10
local InfoDisplay_minChargeDefault = 10
local InfoDisplay_minAutoRepairDefault = 10
local InfoDisplay_minAutoChargeDefault = 10

-- AutoRepair/AutoCharge toggle
local InfoDisplay_autoRepairSettingDefault = true
local InfoDisplay_autoChargeSettingDefault = true

-- Auto Repair at merchant
local InfoDisplay_autoMerchantRepairDefault = true

-- Notifications
local InfoDisplay_NotificationFrequency = 300000
local InfoDisplay_SendRepairKitNotifications = true
local InfoDisplay_SendSoulGemNotifications = true
local InfoDisplay_SendInsufficientGoldNotifications = true

-- Colors
local COLOR_BAD = ZO_ColorDef:New("FF0000")
local COLOR_WARNING = ZO_ColorDef:New("FF9300")
local COLOR_MID = ZO_ColorDef:New("FFF700")
local COLOR_OK = ZO_ColorDef:New("36FF00")
local COLOR_GOOD = ZO_ColorDef:New("FFFFFF")

-- Counter for the async identifier
local InfoDisplay_async_identifier_counter = 1

-- Textures for the lock icon
local TextureNormalUnlocked = "/esoui/art/miscellaneous/unlocked_up.dds"
local TextureNormalUnlockedPressed = "/esoui/art/miscellaneous/unlocked_down.dds"
local TextureNormalUnlockedOver = "/esoui/art/miscellaneous/unlocked_over.dds"
local TextureNormalLocked = "/esoui/art/miscellaneous/locked_up.dds"
local TextureNormalLockedPressed = "/esoui/art/miscellaneous/locked_down.dds"
local TextureNormalLockedOver = "/esoui/art/miscellaneous/locked_over.dds"

-- Initialize the global settings, set them to defaults if they aren't already set
function InfoDisplay_InitializeDefaults()
    if InfoDisplay.savedVariables.minRepairLevel == nil then InfoDisplay.savedVariables.minRepairLevel = InfoDisplay_minRepairDefault else end
    if InfoDisplay.savedVariables.minChargeLevel == nil then InfoDisplay.savedVariables.minChargeLevel = InfoDisplay_minChargeDefault else end
    if InfoDisplay.savedVariables.minAutoRepair == nil then InfoDisplay.savedVariables.minAutoRepair = InfoDisplay_minAutoRepairDefault else end
    if InfoDisplay.savedVariables.minAutoCharge == nil then InfoDisplay.savedVariables.minAutoCharge = InfoDisplay_minAutoChargeDefault else end
    if InfoDisplay.savedVariables.autoRepairSetting == nil then InfoDisplay.savedVariables.autoRepairSetting = InfoDisplay_autoRepairSettingDefault else end
    if InfoDisplay.savedVariables.autoChargeSetting == nil then InfoDisplay.savedVariables.autoChargeSetting = InfoDisplay_autoChargeSettingDefault else end
end

-- Get repair status function, we just find the lower repair percentage and report that
function InfoDisplay_GetRepairStatus()
    local OverallCondition = 100
    for _,slot in pairs(equip_slots) do
        if DoesItemHaveDurability(BAG_WORN, slot) then
            local Condition = GetItemCondition(BAG_WORN, slot)
            if Condition < OverallCondition then OverallCondition = Condition end
        end
    end
    InfoDisplay_SetRepairStatus(OverallCondition)
end

-- Get charge status function, we just find the lowest charge percentage and report that
function InfoDisplay_GetChargeStatus()
    local OverallCharge = 100
    for _,slot in pairs(weapon_slots) do
        if IsItemChargeable(BAG_WORN, slot) then
            local currentChargeRaw,maxCharge = GetChargeInfoForItem(BAG_WORN, slot)
            local currentCharge = math.floor((currentChargeRaw/maxCharge)*100)
            if currentCharge < OverallCharge then OverallCharge = currentCharge end
        end
    end
    InfoDisplay_SetChargeStatus(OverallCharge)
end

-- Get gold on character
function InfoDisplay_GetCharacterGold()
    local cGold = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
    InfoDisplay_SetCharacterGold(cGold)
end

-- Get gold in bank
function InfoDisplay_GetBankGold()
    local pGold = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_BANK)
    InfoDisplay_SetBankGold(pGold)
end

-- Get mount training time cooldown
function InfoDisplay_GetMountTrainingTime()
    -- GetTimeUntilCanBeTrained() returns ms
    local mountTrainingTimeRaw = GetTimeUntilCanBeTrained()
    mountTrainingTimeRaw = mountTrainingTimeRaw / 1000
    local hours = math.floor(math.mod(mountTrainingTimeRaw, 86400)/3600)
    local minutes = math.floor(math.mod(mountTrainingTimeRaw, 3600)/60)
    InfoDisplay_SetMountTrainingTime(hours,minutes)
end

-- Get inventory space on character
function InfoDisplay_GetCharacterInventorySpace()
    local cBagUsed = GetNumBagUsedSlots(BAG_BACKPACK)
    local cBagAvailable = GetBagUseableSize(BAG_BACKPACK)
    InfoDisplay_SetCharacterInventorySpace(cBagUsed,cBagAvailable)
end

-- Get character's bank space
function InfoDisplay_GetCharacterBankSpace()
    local cBankUsed = GetNumBagUsedSlots(BAG_BANK)
    local cBankAvailable = GetBagUseableSize(BAG_BANK)
	if IsESOPlusSubscriber() then
		cBankUsed=cBankUsed+GetNumBagUsedSlots(BAG_SUBSCRIBER_BANK)
		cBankAvailable=cBankAvailable+GetBagUseableSize(BAG_SUBSCRIBER_BANK)
	end
    InfoDisplay_SetCharacterBankSpace(cBankUsed,cBankAvailable)
end

-- Format character gold and update UI
function InfoDisplay_SetCharacterGold(gold)
    if gold > 0 then 
        InfoDisplay_Indicator_txtPg:SetColor(COLOR_GOOD:UnpackRGBA())
        InfoDisplay_Indicator_txtPg:SetText(gold)
    else
        InfoDisplay_Indicator_txtPg:SetColor(COLOR_BAD:UnpackRGBA())
        InfoDisplay_Indicator_txtPg:SetText(gold)
    end      
end

-- Format bank gold and update UI
function InfoDisplay_SetBankGold(gold)
    if gold > 0 then 
        InfoDisplay_Indicator_txtBg:SetColor(COLOR_GOOD:UnpackRGBA())
        InfoDisplay_Indicator_txtBg:SetText(gold)
    else
        InfoDisplay_Indicator_txtBg:SetColor(COLOR_BAD:UnpackRGBA())
        InfoDisplay_Indicator_txtBg:SetText(gold)      
    end  
end

-- Format character inventory space and update UI
function InfoDisplay_SetCharacterInventorySpace(used,avail)
    local UsedPercentage = used / avail
    if UsedPercentage == 1.00 then InfoDisplay_Indicator_txtBagSpace:SetColor(COLOR_BAD:UnpackRGBA())
    elseif UsedPercentage >= 0.66 then InfoDisplay_Indicator_txtBagSpace:SetColor(COLOR_WARNING:UnpackRGBA())
    elseif UsedPercentage >= 0.33 then InfoDisplay_Indicator_txtBagSpace:SetColor(COLOR_MID:UnpackRGBA())
    else InfoDisplay_Indicator_txtBagSpace:SetColor(COLOR_OK:UnpackRGBA())
    end
    InfoDisplay_Indicator_txtBagSpace:SetText(used .. "/" .. avail)
end

-- Format character bank space and update UI
function InfoDisplay_SetCharacterBankSpace(used,avail)
    local UsedPercentage = used / avail
    if UsedPercentage == 1.00 then InfoDisplay_Indicator_txtBankSpace:SetColor(COLOR_BAD:UnpackRGBA())
    elseif UsedPercentage >= 0.66 then InfoDisplay_Indicator_txtBankSpace:SetColor(COLOR_WARNING:UnpackRGBA())
    elseif UsedPercentage >= 0.33 then InfoDisplay_Indicator_txtBankSpace:SetColor(COLOR_MID:UnpackRGBA())
    else InfoDisplay_Indicator_txtBankSpace:SetColor(COLOR_OK:UnpackRGBA())
    end
    InfoDisplay_Indicator_txtBankSpace:SetText(used .. "/" .. avail)
end

-- Format character repair status and update UI
function InfoDisplay_SetRepairStatus(repairStatus)
    if repairStatus == 0 then InfoDisplay_Indicator_txtRepairStatus:SetColor(COLOR_BAD:UnpackRGBA())
    elseif repairStatus <= 33 then InfoDisplay_Indicator_txtRepairStatus:SetColor(COLOR_WARNING:UnpackRGBA())
    elseif repairStatus <= 66 then InfoDisplay_Indicator_txtRepairStatus:SetColor(COLOR_MID:UnpackRGBA())
    else InfoDisplay_Indicator_txtRepairStatus:SetColor(COLOR_OK:UnpackRGBA())
    end
    InfoDisplay_Indicator_txtRepairStatus:SetText(repairStatus .. "%")
end

-- Format character charge status and update UI
function InfoDisplay_SetChargeStatus(chargeStatus)
    if chargeStatus == 0 then InfoDisplay_Indicator_txtChargeStatus:SetColor(COLOR_BAD:UnpackRGBA())
    elseif chargeStatus <= 33 then InfoDisplay_Indicator_txtChargeStatus:SetColor(COLOR_WARNING:UnpackRGBA())
    elseif chargeStatus <= 66 then InfoDisplay_Indicator_txtChargeStatus:SetColor(COLOR_MID:UnpackRGBA())
    else InfoDisplay_Indicator_txtChargeStatus:SetColor(COLOR_OK:UnpackRGBA())
    end
    InfoDisplay_Indicator_txtChargeStatus:SetText(chargeStatus .. "%")
end

-- Format character remaining mount training time and update UI
function InfoDisplay_SetMountTrainingTime(hours,minutes)
    if (hours == 0 and minutes == 0) then 
         InfoDisplay_Indicator_txtMountTimer:SetColor(COLOR_OK:UnpackRGBA())
         InfoDisplay_Indicator_txtMountTimer:SetText("READY")
     else 
         InfoDisplay_Indicator_txtMountTimer:SetColor(COLOR_GOOD:UnpackRGBA())
         InfoDisplay_Indicator_txtMountTimer:SetText(hours .. "h " .. minutes .. "m")
     end
end

-------------- DISPLAY LOCK FUNCTIONS --------------
-- Toggle display lock
function InfoDisplay_ToggleLock()
    if InfoDisplay.savedVariables.lockMove == true then InfoDisplay_UnlockPosition() 
    else InfoDisplay_LockPosition()
    end
end

-- Explicitly set a display lock value
function InfoDisplay_SetLock(lockValue)
    if lockValue == true then InfoDisplay_LockPosition()
    else InfoDisplay_UnlockPosition()
    end
end

-- Actually lock the position of the UI element, update the lockMove variable, and update the texture on the UI lock/unlock button
function InfoDisplay_LockPosition()
    InfoDisplay_Indicator:SetMovable(false)
    InfoDisplay.savedVariables.lockMove = true
    InfoDisplay_SetLockTexture(1)
end

-- Actually unlock the position of the UI element, update the lockMove variable, and update the texture on the UI lock/unlock button
function InfoDisplay_UnlockPosition()
    InfoDisplay_Indicator:SetMovable(true) 
    InfoDisplay.savedVariables.lockMove = false
    InfoDisplay_SetLockTexture(0)
end

-- Restore the lock status on initialization
function InfoDisplay_RestoreLock()
    if InfoDisplay.savedVariables.lockMove == true then 
        InfoDisplay_Indicator:SetMovable(false)
        InfoDisplay_SetLockTexture(1)
    else 
        InfoDisplay.savedVariables.lockMove = false
        InfoDisplay_Indicator:SetMovable(true)
        InfoDisplay_SetLockTexture(0)
    end
end

-- Update the textures for the UI lock/unlock button
function InfoDisplay_SetLockTexture(state) 
    -- 0 = unlocked
    -- 1 = locked
    if state == 0 then 
        InfoDisplay_Indicator_btnToggleLock:SetNormalTexture(TextureNormalUnlocked)
        InfoDisplay_Indicator_btnToggleLock:SetPressedTexture(TextureNormalUnlockedPressed)
        InfoDisplay_Indicator_btnToggleLock:SetMouseOverTexture(TextureNormalUnlockedOver)
    else 
        InfoDisplay_Indicator_btnToggleLock:SetNormalTexture(TextureNormalLocked)
        InfoDisplay_Indicator_btnToggleLock:SetPressedTexture(TextureNormalLockedPressed)
        InfoDisplay_Indicator_btnToggleLock:SetMouseOverTexture(TextureNormalLockedOver)
    end
end
----------------------------------------------

-------------- REPAIR FUNCTIONS --------------
-- Repair at merchant if enabled
function InfoDisplay_MerchantRepair()
    if InfoDisplay.savedVariables.autoMerchantRepair == false then return end
    if CanStoreRepair() == true then
        if GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER) >= GetRepairAllCost() then RepairAll()
        else 
            InfoDisplay_MissingItemNotifications('gold')
            return
        end
    end
end

-- Repair with a repair kit, we check if this is enabled elsewhere
function InfoDisplay_Repair(bagId,slotId) 
    local repairKitId = InfoDisplay_ScanInventoryForKit(1)
    if repairKitId == nil then 
        InfoDisplay_MissingItemNotifications('repairKit')
        return
    else
        RepairItemWithRepairKit(bagId,slotId,BAG_BACKPACK,repairKitId)
    end
end

-- Charge with a soul gem, we check if this is enabled elsewhere
function InfoDisplay_Charge(bagId,slotId)
    local chargeKitId = InfoDisplay_ScanInventoryForKit(2)
    if chargeKitId == nil then 
        InfoDisplay_MissingItemNotifications('soulGem')
        return
    else
        ChargeItemWithSoulGem(bagId,slotId,BAG_BACKPACK,chargeKitId)
    end
end

-- Search inventory for repair kit or soul gem
function InfoDisplay_ScanInventoryForKit(type) 
    -- 1 = repairKit
    -- 2 = soulGem
    local PlayerInventory = SHARED_INVENTORY:GenerateFullSlotData(nil,BAG_BACKPACK)
    for _,data in pairs(PlayerInventory) do
        if (GetItemId(data.bagId,data.slotIndex) == InfoDisplay_repairKitItemId and type == 1) then return data.slotIndex
        elseif (GetItemId(data.bagId,data.slotIndex) == InfoDisplay_chargeKitItemId and type == 2) then return data.slotIndex
        else
        end
    end
end

-- Manual repair 
function InfoDisplay_OnRepairClickEvent()
    for _,slot in pairs(equip_slots) do
        if DoesItemHaveDurability(BAG_WORN, slot) then
            local condition = GetItemCondition(BAG_WORN, slot)
            if condition <= InfoDisplay.savedVariables.minRepairLevel then 
                InfoDisplay_Repair(BAG_WORN, slot)
            end
        end
    end
    InfoDisplay_GetRepairStatus()
end

-- Manual charge
function InfoDisplay_OnChargeClickEvent()
    for _,slot in pairs(weapon_slots) do
        if IsItemChargeable(BAG_WORN, slot) then
            local currentChargeRaw,maxCharge = GetChargeInfoForItem(BAG_WORN, slot)
            local currentCharge = math.floor((currentChargeRaw/maxCharge)*100)
            if currentCharge <= InfoDisplay.savedVariables.minChargeLevel then 
               InfoDisplay_Charge(BAG_WORN, slot) 
            end
        end
    end
    InfoDisplay_GetChargeStatus()
end

-- Automatic repair
function InfoDisplay_AutomaticRepairEvent()
    for _,slot in pairs(equip_slots) do
        if DoesItemHaveDurability(BAG_WORN, slot) then
            local condition = GetItemCondition(BAG_WORN, slot)
            if condition <= InfoDisplay.savedVariables.minAutoRepair then 
                InfoDisplay_Repair(BAG_WORN, slot)
            end
        end
    end
end

-- Automatic charge
function InfoDisplay_AutomaticChargeEvent()
    for _,slot in pairs(weapon_slots) do
        if IsItemChargeable(BAG_WORN, slot) then
            local currentChargeRaw,maxCharge = GetChargeInfoForItem(BAG_WORN, slot)
            local currentCharge = math.floor((currentChargeRaw/maxCharge)*100)
            if currentCharge <= InfoDisplay.savedVariables.minAutoCharge then 
               InfoDisplay_Charge(BAG_WORN, slot) 
            end
        end
    end
end

-- Function to send notifications to the player about insufficient soul gems / gold / repair kits. Had it in the repair/charge main functions but it was a bit spammy.
function InfoDisplay_MissingItemNotifications(notificationType) 
    --notificationType should be 'gold','repairKit',or 'soulGem'
    if notificationType == 'gold' then 
        if InfoDisplay_SendInsufficientGoldNotifications == true then
            chat:Print("Insufficient gold to repair items.")
            InfoDisplay_SendInsufficientGoldNotifications = false
            zo_callLater(function() InfoDisplay_ResetNotification('gold') end, InfoDisplay_NotificationFrequency)
        end
    end
    if notificationType == 'repairKit' then 
        if InfoDisplay_SendRepairKitNotifications == true then
            chat:Print("No repair kits available to repair items.")
            InfoDisplay_SendRepairKitNotifications = false
            zo_callLater(function() InfoDisplay_ResetNotification('repairKit') end, InfoDisplay_NotificationFrequency)
        end
    end
    if notificationType == 'soulGem' then 
        if InfoDisplay_SendSoulGemNotifications == true then
            chat:Print("No soul gems available to recharge items.")
            InfoDisplay_SendSoulGemNotifications = false
            zo_callLater(function() InfoDisplay_ResetNotification('soulGem') end, InfoDisplay_NotificationFrequency)
        end
    end
end

function InfoDisplay_ResetNotification(notificationType)
    --notificationType should be 'gold','repairKit',or 'soulGem'
    if notificationType == 'gold' then InfoDisplay_SendInsufficientGoldNotifications = true end
    if notificationType == 'repairKit' then InfoDisplay_SendRepairKitNotifications = true end
    if notificationType == 'soulGem' then InfoDisplay_SendSoulGemNotifications = true end
end
----------------------------------------------

-- detect gear change
function InfoDisplay_OnGearChange()
    if InfoDisplay.savedVariables.autoRepairSetting == true then InfoDisplay_AutomaticRepairEvent() end
    if InfoDisplay.savedVariables.autoChargeSetting == true then InfoDisplay_AutomaticChargeEvent() end
    InfoDisplay_GetRepairStatus()
    InfoDisplay_GetChargeStatus()
end

-- async updater -- runs every 5 seconds
-- I had to put the get status commands here, the detect gear change is a bit flaky for some reason..
function InfoDisplay_async_Update()
    InfoDisplay_GetMountTrainingTime()
    InfoDisplay_GetRepairStatus()
    InfoDisplay_GetChargeStatus()    
    InfoDisplay_async_identifier_counter = InfoDisplay_async_identifier_counter + 1
end

-- Combat watcher - triggers when the player leaves combat
function InfoDisplay_PostCombatChecks()
    if IsUnitInCombat("player") == false then 
        if InfoDisplay.savedVariables.autoRepairSetting == true then InfoDisplay_AutomaticRepairEvent() end
        if InfoDisplay.savedVariables.autoChargeSetting == true then InfoDisplay_AutomaticChargeEvent() end
        InfoDisplay_GetRepairStatus()
        InfoDisplay_GetChargeStatus()
    end
end

-- Save the position of the UI 
function InfoDisplay_OnIndicatorMoveStop()
    InfoDisplay.savedVariables.left = InfoDisplay_Indicator:GetLeft()
    InfoDisplay.savedVariables.top = InfoDisplay_Indicator:GetTop()
end

-- Restore the position of the UI on initialization
function InfoDisplay_RestorePosition()
    InfoDisplay_Indicator:ClearAnchors()
    InfoDisplay_Indicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, InfoDisplay.savedVariables.left, InfoDisplay.savedVariables.top)
end

-- Hide the UI when the HUD fades out (e.g. when you open a menu)
local fragment = ZO_HUDFadeSceneFragment:New(InfoDisplay_Indicator,nil,0)
HUD_SCENE:AddFragment(fragment)
HUD_UI_SCENE:AddFragment(fragment)

-- Main initialization function
function InfoDisplay_Initialize()
    -- Restore saved variables and position
    InfoDisplay.savedVariables = ZO_SavedVars:NewAccountWide("InfoDisplay_SavedVariables",1,nil,{})
    InfoDisplay_RestorePosition()
    InfoDisplay_RestoreLock()
    InfoDisplay_InitializeDefaults()

    -- Initialize LAM2 addon menu and options
    LAM2:RegisterAddonPanel("InfoDisplayAddonOptions", InfoDisplay_LAM2panelData)
    LAM2:RegisterOptionControls("InfoDisplayAddonOptions", InfoDisplay_LAM2optionsData)

    -- Set the draw levels to prevent the table from blocking stuff
    InfoDisplay_Indicator:SetDrawLevel(0)
    InfoDisplay_Indicator:SetDrawLayer(0)
    InfoDisplay_Indicator:SetDrawTier(0)

    -- Initial population of the data elements
    InfoDisplay_GetCharacterGold()
    InfoDisplay_GetBankGold()
    InfoDisplay_GetCharacterInventorySpace()
    InfoDisplay_GetCharacterBankSpace()
    InfoDisplay_GetMountTrainingTime()
    InfoDisplay_GetRepairStatus()
    InfoDisplay_GetChargeStatus()

    -- Create the asynchronous updater to run every 5 seconds
    local InfoDisplay_async_identifier = "InfoDisplay_async_identifier-" .. InfoDisplay_async_identifier_counter
    EVENT_MANAGER:RegisterForUpdate(InfoDisplay_async_identifier, 5000, InfoDisplay_async_Update)

    -- Register for events
    EVENT_MANAGER:RegisterForEvent("InfoDisplay_BagSpaceChangeEvent", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, InfoDisplay_GetCharacterInventorySpace)
    EVENT_MANAGER:RegisterForEvent("InfoDisplay_BankSpaceChangeEvent", EVENT_CLOSE_BANK, InfoDisplay_GetCharacterBankSpace)
    EVENT_MANAGER:RegisterForEvent("InfoDisplay_BankSpaceChangeEvent", EVENT_END_CRAFTING_STATION_INTERACT,	InfoDisplay_GetCharacterBankSpace)
    EVENT_MANAGER:RegisterForEvent("InfoDisplay_CurrencyUpdate", EVENT_CARRIED_CURRENCY_UPDATE, InfoDisplay_GetCharacterGold)
    EVENT_MANAGER:RegisterForEvent("InfoDisplay_CurrencyUpdate", EVENT_BANKED_CURRENCY_UPDATE, InfoDisplay_GetBankGold)
    EVENT_MANAGER:RegisterForEvent("InfoDisplay_MerchantRepair", EVENT_OPEN_STORE, InfoDisplay_MerchantRepair)
    EVENT_MANAGER:RegisterForEvent("InfoDisplay_CombatWatcher", EVENT_PLAYER_COMBAT_STATE, InfoDisplay_PostCombatChecks)
    EVENT_MANAGER:RegisterForEvent("InfoDisplay_EquipmentWatcher", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, InfoDisplay_OnGearChange)
    EVENT_MANAGER:AddFilterForEvent("InfoDisplay_EquipmentWatcher", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
end

-- Main UI load event function
function InfoDisplay_OnAddOnLoaded(event, addonName)
    if addonName == InfoDisplay.name then
        InfoDisplay_Initialize()
    end
end

-- Event register for add on loading
EVENT_MANAGER:RegisterForEvent(InfoDisplay.name, EVENT_ADD_ON_LOADED, InfoDisplay_OnAddOnLoaded)