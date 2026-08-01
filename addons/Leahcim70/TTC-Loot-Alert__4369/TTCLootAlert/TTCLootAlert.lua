local TTCLootAlert = TTCLootAlert or {}
TTCLootAlert.name = "TTCLootAlert"
TTCLootAlert.author = "@Leahcim70"

local DEFAULT_THRESHOLD_GOLD = 1000
local DEFAULT_DEBUG_ENABLED = false
local THRESHOLD_GOLD = DEFAULT_THRESHOLD_GOLD
local DEBUG_ENABLED = DEFAULT_DEBUG_ENABLED
local INVENTORY_VALUE_ICON_TEXTURE = "EsoUI/Art/Currency/currency_gold.dds"
local INVENTORY_VALUE_ICON_SIZE = 18
local inventoryValueIconHooksRegistered = false
local inventoryDebugSeen = {}
local settingsPanelRegistered = false

local function FormatGold(n)
    n = tonumber(n) or 0
    return zo_strformat("<<1>>", ZO_CommaDelimitNumber(n))
end

local function Chat(msg)
    -- "Vanilla"-Systemmessage (sauberer als d())
    if CHAT_ROUTER and CHAT_ROUTER.AddSystemMessage then
        CHAT_ROUTER:AddSystemMessage(msg)
    else
        CHAT_SYSTEM:AddMessage(msg)
    end
end

local function Debug(msg)
    if not DEBUG_ENABLED then return end
    Chat("|cFFD700[LootAlert-DBG]|r " .. tostring(msg))
end

local function DebugOnce(key, msg)
    if not DEBUG_ENABLED then return end
    if inventoryDebugSeen[key] then return end
    inventoryDebugSeen[key] = true
    Debug(msg)
end

local function ResetInventoryDebugSeen(reason)
    inventoryDebugSeen = {}
    if reason then
        Debug("Debug cache reset: " .. tostring(reason))
    end
end

local function ColorizeDebugText(text, isHighlighted)
    if isHighlighted then
        return "|c00FF88" .. tostring(text) .. "|r"
    end
    return "|cB0B0B0" .. tostring(text) .. "|r"
end

local function GetDebugItemName(bagId, slotIndex)
    if bagId == nil or slotIndex == nil then
        return "?"
    end
    if type(GetItemName) ~= "function" then
        return "?"
    end
    local name = GetItemName(bagId, slotIndex)
    if not name or name == "" then
        return "?"
    end
    return zo_strformat("<<1>>", name)
end

local missingLibPriceWarned = false
local function GetLibPriceGold(itemLink)
    if not itemLink or itemLink == "" then return nil end
    if not LibPrice or not LibPrice.ItemLinkToPriceGold then return nil end

    local gold = LibPrice.ItemLinkToPriceGold(itemLink)
    return tonumber(gold)
end

local function SetThresholdGold(value)
    local threshold = tonumber(value)
    if not threshold then
        return false
    end

    if threshold < 0 then
        threshold = 0
    end

    THRESHOLD_GOLD = threshold
    if TTCLootAlert.savedVars then
        TTCLootAlert.savedVars.threshold = threshold
    end
    return true
end

local function OnLootReceived(eventCode, lootedBy, itemLink, quantity, itemSound, lootType, lootedBySelf, isStolen)
    Debug(string.format("EVENT_LOOT_RECEIVED: self=%s item=%s qty=%s stolen=%s", tostring(lootedBySelf), tostring(itemLink), tostring(quantity), tostring(isStolen)))
    if not lootedBySelf then return end
    if not itemLink or itemLink == "" then return end

    local suggested = GetLibPriceGold(itemLink)
    if not suggested then
        if not LibPrice or not LibPrice.ItemLinkToPriceGold then
            if not missingLibPriceWarned then
                Debug("LibPrice missing or ItemLinkToPriceGold not available.")
                missingLibPriceWarned = true
            end
        else
            Debug("LibPrice returned nil for item.")
        end
        return
    end
    if suggested < THRESHOLD_GOLD then
        Debug(string.format("Below threshold: %s < %s", tostring(suggested), tostring(THRESHOLD_GOLD)))
        return
    end

    quantity = tonumber(quantity) or 1
    local total = suggested * quantity

    Chat(string.format(GetString(TTCLootAlert_LOOT_MESSAGE), itemLink, FormatGold(suggested), quantity, FormatGold(total)))
end

local function GetInventoryRowControl(slotControl)
    if not slotControl then return nil end
    local parent = slotControl.GetParent and slotControl:GetParent() or nil
    if parent and parent:GetNamedChild("Name") then
        return parent
    end
    if slotControl:GetNamedChild("Name") then
        return slotControl
    end
    return parent or slotControl
end

local function EnsureInventoryValueIcon(rowControl)
    if not rowControl then return nil end
    if rowControl.ttcLootAlertValueIcon then return rowControl.ttcLootAlertValueIcon end

    local valueIcon = WINDOW_MANAGER:CreateControl(nil, rowControl, CT_TEXTURE)
    valueIcon:SetTexture(INVENTORY_VALUE_ICON_TEXTURE)
    valueIcon:SetDimensions(INVENTORY_VALUE_ICON_SIZE, INVENTORY_VALUE_ICON_SIZE)
    valueIcon:SetDrawLayer(DL_CONTROLS)
    valueIcon:SetDrawTier(DT_HIGH)
    valueIcon:SetHidden(true)

    rowControl.ttcLootAlertValueIcon = valueIcon
    return valueIcon
end

local function ExtractBagAndSlotIndex(slotControl, slot)
    local slotDataArg = type(slot) == "table" and slot or nil
    local bagId = slotDataArg and slotDataArg.bagId
    local slotIndex = slotDataArg and slotDataArg.slotIndex

    if bagId ~= nil and slotIndex ~= nil then
        return bagId, slotIndex
    end

    local dataEntry = slotControl and slotControl.dataEntry
    local slotData = dataEntry and dataEntry.data
    if slotData then
        bagId = slotData.bagId
        slotIndex = slotData.slotIndex
    end

    if bagId ~= nil and slotIndex ~= nil then
        return bagId, slotIndex
    end

    local parent = slotControl and slotControl.GetParent and slotControl:GetParent()
    local parentDataEntry = parent and parent.dataEntry
    local parentSlotData = parentDataEntry and parentDataEntry.data
    if parentSlotData then
        bagId = parentSlotData.bagId
        slotIndex = parentSlotData.slotIndex
    end

    return bagId, slotIndex
end

local function GetItemLinkForInventorySlot(bagId, slotIndex, slotData)
    if type(slotData) == "table" and slotData.itemLink and slotData.itemLink ~= "" then
        return slotData.itemLink
    end
    if type(GetItemLink) == "function" and bagId ~= nil and slotIndex ~= nil and slotIndex >= 0 then
        if LINK_STYLE_DEFAULT ~= nil then
            return GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)
        end
        return GetItemLink(bagId, slotIndex)
    end
    return nil
end

local function GetInventoryLibPriceGold(bagId, slotIndex, slotData)
    local itemLink = GetItemLinkForInventorySlot(bagId, slotIndex, slotData)
    if not itemLink or itemLink == "" then
        return 0
    end
    local price = GetLibPriceGold(itemLink)
    if not price then
        return 0
    end
    if price < 0 then
        return 0
    end
    return price
end

local function IsInventoryItemBound(bagId, slotIndex)
    if bagId == nil or slotIndex == nil or slotIndex < 0 then
        return false
    end

    if type(IsItemBound) == "function" and IsItemBound(bagId, slotIndex) then
        return true
    end
    if type(IsItemBoundToAccount) == "function" and IsItemBoundToAccount(bagId, slotIndex) then
        return true
    end

    return false
end

local function ShouldShowInventoryValueIcon(bagId, slotIndex, slotData)
    if bagId == nil or slotIndex == nil then
        return false, "missing_bag_or_slot", 0
    end
    if slotIndex < 0 then
        return false, "invalid_slot_index", 0
    end
    if IsInventoryItemBound(bagId, slotIndex) then
        return false, "bound_item", 0
    end

    local libPriceValue = GetInventoryLibPriceGold(bagId, slotIndex, slotData)
    if libPriceValue <= 0 then
        return false, "libprice_missing_or_zero", libPriceValue
    end
    if libPriceValue < THRESHOLD_GOLD then
        return false, "below_alert_threshold", libPriceValue
    end

    return true, "show", libPriceValue
end

local function UpdateInventoryValueIcon(slotControl, slot)
    local bagId, slotIndex = ExtractBagAndSlotIndex(slotControl, slot)
    local rowControl = GetInventoryRowControl(slotControl)
    local targetControl = rowControl or slotControl

    local controlName = targetControl and targetControl.GetName and targetControl:GetName() or "nil"
    local slotArgType = type(slot)
    local slotArgBag = slotArgType == "table" and tostring(slot.bagId) or "-"
    local slotArgSlot = slotArgType == "table" and tostring(slot.slotIndex) or "-"
    local debugSlotKey = string.format("%s|bag=%s|slot=%s", tostring(controlName), tostring(bagId), tostring(slotIndex))

    DebugOnce(
        "resolve|" .. debugSlotKey,
        string.format(
            "Resolve: ctrl=%s slotArgType=%s slotArgBag=%s slotArgSlot=%s resolvedBag=%s resolvedSlot=%s",
            tostring(controlName),
            slotArgType,
            slotArgBag,
            slotArgSlot,
            tostring(bagId),
            tostring(slotIndex)
        )
    )

    local slotData = type(slot) == "table" and slot or nil
    if not slotData then
        local dataEntry = slotControl and slotControl.dataEntry
        slotData = dataEntry and dataEntry.data
    end
    if not slotData and targetControl then
        local targetDataEntry = targetControl.dataEntry
        slotData = targetDataEntry and targetDataEntry.data
    end

    local shouldShow, reason, priceValue = ShouldShowInventoryValueIcon(bagId, slotIndex, slotData)
    local debugItemName = GetDebugItemName(bagId, slotIndex)
    local coloredItemName = ColorizeDebugText(debugItemName, shouldShow)
    local coloredPriceValue = ColorizeDebugText(tostring(priceValue), shouldShow)
    DebugOnce(
        "decision|" .. debugSlotKey .. "|reason=" .. tostring(reason),
        string.format(
            "Decision: item=%s ctrl=%s bag=%s slot=%s libPrice=%s threshold=%s -> %s (%s)",
            tostring(coloredItemName),
            tostring(controlName),
            tostring(bagId),
            tostring(slotIndex),
            tostring(coloredPriceValue),
            tostring(THRESHOLD_GOLD),
            tostring(shouldShow),
            tostring(reason)
        )
    )

    local valueIcon = targetControl and targetControl.ttcLootAlertValueIcon
    if not shouldShow then
        if valueIcon then
            valueIcon:SetHidden(true)
        end
        return
    end

    valueIcon = EnsureInventoryValueIcon(targetControl)
    if not valueIcon then return end

    local nameControl = targetControl:GetNamedChild("Name")
    local anchorControl = nameControl or targetControl:GetNamedChild("Icon") or targetControl

    valueIcon:ClearAnchors()
    valueIcon:SetAnchor(LEFT, anchorControl, RIGHT, 6, 0)
    valueIcon:SetHidden(false)

    local anchorName = anchorControl and anchorControl.GetName and anchorControl:GetName() or "nil"
    DebugOnce(
        "shown|" .. debugSlotKey,
        string.format("Shown: ctrl=%s anchor=%s", tostring(controlName), tostring(anchorName))
    )
end

local function RegisterInventoryValueIconHook()
    if inventoryValueIconHooksRegistered then
        Debug("RegisterInventoryValueIconHook skipped: already registered")
        return
    end
    if type(SecurePostHook) ~= "function" then
        Debug("SecurePostHook unavailable; inventory value icon disabled.")
        return
    end

    if type(_G["ZO_PlayerInventorySlot_SetupSlot"]) == "function" then
        SecurePostHook("ZO_PlayerInventorySlot_SetupSlot", function(slotControl, slot)
            DebugOnce("hook_call|ZO_PlayerInventorySlot_SetupSlot", "Hook call observed: ZO_PlayerInventorySlot_SetupSlot")
            UpdateInventoryValueIcon(slotControl, slot)
        end)
        inventoryValueIconHooksRegistered = true
        Debug("Registered inventory value icon hook: ZO_PlayerInventorySlot_SetupSlot")
        return
    end

    Debug("Hook not found: ZO_PlayerInventorySlot_SetupSlot. Retrying in 1s.")
    EVENT_MANAGER:RegisterForUpdate(TTCLootAlert.name .. "_ValueIconHookRetry", 1000, function()
        EVENT_MANAGER:UnregisterForUpdate(TTCLootAlert.name .. "_ValueIconHookRetry")
        RegisterInventoryValueIconHook()
    end)
end

local function RegisterSlashCommand()
    local function HandleSlashCommand(text)
        local trimmed = (text or ""):match("^%s*(.-)%s*$")
        if trimmed == "" then
            Chat(string.format(GetString(TTCLootAlert_THRESHOLD_CURRENT), FormatGold(THRESHOLD_GOLD)))
            return
        end

        if not SetThresholdGold(trimmed) then
            Chat(GetString(TTCLootAlert_INVALID_VALUE))
            return
        end
        Chat(string.format(GetString(TTCLootAlert_THRESHOLD_SET), FormatGold(THRESHOLD_GOLD)))
    end

    SLASH_COMMANDS["/ttcalert"] = HandleSlashCommand

    local function HandleDebugCommand(text)
        local trimmed = (text or ""):match("^%s*(.-)%s*$"):lower()
        if trimmed == "" then
            Chat(string.format("|cFFD700[LootAlert-DBG]|r Debug %s.", DEBUG_ENABLED and "enabled" or "disabled"))
            return
        end

        if trimmed == "on" or trimmed == "1" or trimmed == "true" then
            DEBUG_ENABLED = true
            TTCLootAlert.savedVars.debug = true
            ResetInventoryDebugSeen("debug_on")
            Chat("|cFFD700[LootAlert-DBG]|r Debug enabled.")
            RegisterInventoryValueIconHook()
            return
        end

        if trimmed == "off" or trimmed == "0" or trimmed == "false" then
            DEBUG_ENABLED = false
            TTCLootAlert.savedVars.debug = false
            Chat("|cFFD700[LootAlert-DBG]|r Debug disabled.")
            return
        end

        Chat("|cFFD700[LootAlert-DBG]|r Usage: /ttcalertdebug [on|off]")
    end

    SLASH_COMMANDS["/ttcalertdebug"] = HandleDebugCommand
end

local function RegisterSettingsPanel()
    if settingsPanelRegistered then return end
    if not LibAddonMenu2 then
        Debug("LibAddonMenu-2.0 missing; settings panel not registered.")
        return
    end

    local panelName = TTCLootAlert.name .. "_SettingsPanel"
    local panelData = {
        type = "panel",
        name = GetString(TTCLootAlert_SETTINGS_PANEL_NAME),
        displayName = GetString(TTCLootAlert_SETTINGS_PANEL_NAME),
        author = TTCLootAlert.author,
        version = "1.0.7",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LibAddonMenu2:RegisterAddonPanel(panelName, panelData)
    LibAddonMenu2:RegisterOptionControls(panelName, {
        {
            type = "description",
            text = GetString(TTCLootAlert_SETTINGS_PANEL_DESC),
            width = "full",
        },
        {
            type = "editbox",
            name = GetString(TTCLootAlert_SETTINGS_THRESHOLD_NAME),
            tooltip = GetString(TTCLootAlert_SETTINGS_THRESHOLD_TOOLTIP),
            isMultiline = false,
            width = "half",
            default = tostring(DEFAULT_THRESHOLD_GOLD),
            getFunc = function()
                return tostring(THRESHOLD_GOLD)
            end,
            setFunc = function(value)
                local trimmed = (value or ""):match("^%s*(.-)%s*$")
                if not SetThresholdGold(trimmed) then
                    Chat(GetString(TTCLootAlert_INVALID_VALUE))
                    return
                end
                Debug("Threshold set via settings: " .. tostring(THRESHOLD_GOLD))
            end,
        },
    })

    settingsPanelRegistered = true
    Debug("LibAddonMenu settings panel registered.")
end

local function OnAddOnLoaded(event, addonName)
    if addonName ~= TTCLootAlert.name then return end
    EVENT_MANAGER:UnregisterForEvent(TTCLootAlert.name, EVENT_ADD_ON_LOADED)

    TTCLootAlert.savedVars = ZO_SavedVars:NewAccountWide("TTCLootAlertSavedVariables", 1, nil, {
        threshold = DEFAULT_THRESHOLD_GOLD,
        debug = DEFAULT_DEBUG_ENABLED,
    })
    THRESHOLD_GOLD = TTCLootAlert.savedVars.threshold or DEFAULT_THRESHOLD_GOLD
    DEBUG_ENABLED = TTCLootAlert.savedVars.debug ~= false

    RegisterSlashCommand()
    RegisterSettingsPanel()
    RegisterInventoryValueIconHook()
    EVENT_MANAGER:RegisterForEvent(TTCLootAlert.name, EVENT_LOOT_RECEIVED, OnLootReceived)
    Debug(string.format("Addon loaded, events registered. LibPrice=%s", tostring(LibPrice ~= nil)))

    local function OnPlayerActivated()
        EVENT_MANAGER:UnregisterForEvent(TTCLootAlert.name, EVENT_PLAYER_ACTIVATED)
        Chat(string.format(GetString(TTCLootAlert_ADDON_LOADED), TTCLootAlert.name, FormatGold(THRESHOLD_GOLD)))
        Debug(string.format("Player activated. Threshold=%s Debug=%s", tostring(THRESHOLD_GOLD), tostring(DEBUG_ENABLED)))
    end

    EVENT_MANAGER:RegisterForEvent(TTCLootAlert.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

EVENT_MANAGER:RegisterForEvent(TTCLootAlert.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
