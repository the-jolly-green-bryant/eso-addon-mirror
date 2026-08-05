--[[ 
     Protects boxes from being opened when they are on cooldown.
]]--

local addon = Unboxer
local class = addon.classes
local debug = false
local hookToolTips, returnItemLink, tooltipHook, tooltipHookGamepad
local COLOR_TOOLTIP = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_NORMAL))

class.BoxProtector = ZO_Object:Subclass()

function class.BoxProtector:New(...)
    local instance = ZO_Object.New(self)
    instance:Initialize(...)
    return instance
end

function class.BoxProtector:Initialize(unboxAll)
    self.name = addon.name .. "_BoxProtector"
    self.protectedItems = {}
    self.mainContainerIdLookup = {}
    self.mainContainerIdLookupByName = {}
    self.unboxAll = unboxAll
    
    -- Clean up expired cooldowns
    local now = GetTimeStamp()
    local containerIdsToRemove = {}
    for mainContainerItemId, cooldownEnd in pairs(addon.tracking.cooldownEnd) do
        if cooldownEnd < now then
            table.insert(containerIdsToRemove, mainContainerItemId)
        end
    end
    for _, mainContainerItemId in ipairs(containerIdsToRemove) do
        addon.tracking.cooldownEnd[mainContainerItemId] = nil
    end
    
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_LOOT_UPDATED, self:CreateLootUpdatedHandler())
    hookToolTips()
end


function class.BoxProtector:CreateLootClosedHandler()
    return function (eventCode)
        addon.Debug(self.name .. ".LootClosed("..tostring(eventCode)..")", debug)
        EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_LOOT_CLOSED)
        EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_LOOT_RECEIVED)
    end
end

function class.BoxProtector:CreateLootSceneStateChangedHandler()
    if self.lootSceneStateChangedHandler then
        return self.lootSceneStateChangedHandler
    end
    self.lootSceneStateChangedHandler = function(oldState, newState)
        if newState ~= SCENE_SHOWN then
            return
        end
        if self.showDialogData then
            local mainContainerItemId = self.showDialogData.mainContainerItemId
            self.showDialogData = nil
            self:ShowDialog(mainContainerItemId)
        end
        LOOT_SCENE:UnregisterCallback("StateChange", self.lootSceneStateChangedHandler)
    end
    return self.lootSceneStateChangedHandler
end

function class.BoxProtector:CreateLootReceivedHandler(protectedItem)
    return function(eventCode, receivedBy, itemLink, quantity, itemSound, lootType, lootedBySelf, isPickpocketLoot, questItemIcon, itemId)
        
        if addon.IsDebugEnabled(debug) then
            addon.Debug(self.name .. ".LootReceived("..tostring(eventCode)..", "..zo_strformat("<<1>>", receivedBy)..", "..tostring(itemLink)..", "..tostring(quantity)..", "..tostring(itemSound)..", "..tostring(lootType)..", "..tostring(lootedBySelf)..", "..tostring(isPickpocketLoot)..", "..tostring(questItemIcon)..", "..tostring(itemId)..")", debug)
        end
        
        if not protectedItem.lootItemIds[itemId] then
            if addon.IsDebugEnabled(debug) then
                addon.Debug(itemLink .. " is not in the list of protected loot for " .. protectedItem.containerName, debug)
            end
            return
        end
        
        EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_LOOT_CLOSED)
        EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_LOOT_RECEIVED)
        
        local now = GetTimeStamp()
        local mainContainerItemId = protectedItem.mainContainerItemId
        if addon.tracking.cooldownEnd[mainContainerItemId] and addon.tracking.cooldownEnd[mainContainerItemId] > now then
            return
        end
        
        addon.tracking.cooldownEnd[mainContainerItemId] = now + protectedItem.cooldownSeconds
        
        -- #self.unboxAll.queue on its own is always truthy in Lua (0 is truthy),
        -- so this never actually gated on "queue has items" as intended.
        if self.unboxAll and #self.unboxAll.queue > 0 and addon.tracking.cooldownProtected[mainContainerItemId] then
            self.unboxAll:DequeueByItemIds(protectedItem.containersByItemIds)
        end
    end
end

function class.BoxProtector:CreateLootUpdatedHandler()
    return function(eventCode)  
        local targetName, targetType = GetLootTargetInfo()
        if targetType ~= INTERACT_TARGET_TYPE_ITEM then
            return
        end
        local targetNameLower = LocaleAwareToLower(zo_strformat("<<1>>", targetName))
        if addon.IsDebugEnabled(debug) then
            addon.Debug(self.name .. ".LootUpdated(targetNameLower=" .. targetNameLower .. ")", debug)
        end
        
        local mainContainerItemId = self.mainContainerIdLookupByName[targetNameLower]
        if not mainContainerItemId then
            if addon.IsDebugEnabled(debug) then
                addon.Debug(self.name .. " " .. targetNameLower 
                            .. " does not match any known protected container names.", debug)
            end
            return
        end
        
        local protectedItem = self.protectedItems[mainContainerItemId]
        if not protectedItem then
            return
        end
        
        -- Add cooldown confirmation dialog if any time remains on the cooldown
        if self:GetCooldownRemaining(mainContainerItemId) 
            and self:IsCooldownProtected(mainContainerItemId)
        then
            if not self.confirmedMainContainerId
               or self.confirmedMainContainerId ~= mainContainerItemId
            then
                -- Note, dialog will be opened after LOOT_SCENE is shown
                self.showDialogData = {
                    mainContainerItemId = mainContainerItemId,
                }
                local lootScene = IsInGamepadPreferredMode() and LOOT_INVENTORY_SCENE_GAMEPAD or LOOT_SCENE
                lootScene:RegisterCallback("StateChange", self:CreateLootSceneStateChangedHandler())
                return
            end
        end
        
        EVENT_MANAGER:RegisterForEvent(self.name, EVENT_LOOT_CLOSED, self:CreateLootClosedHandler())
        EVENT_MANAGER:RegisterForEvent(self.name, EVENT_LOOT_RECEIVED, self:CreateLootReceivedHandler(protectedItem))
    end
end

function class.BoxProtector:GetCooldownRemaining(itemId)
    local mainContainerItemId = self.mainContainerIdLookup[itemId] or itemId
    if not addon.tracking.cooldownEnd[mainContainerItemId] then
       return
    end
    local now = GetTimeStamp()
    if addon.tracking.cooldownEnd[mainContainerItemId] <= now then
         return
    end
    return addon.tracking.cooldownEnd[mainContainerItemId] - now, self.protectedItems[mainContainerItemId]
end

function class.BoxProtector:GetCooldownRemainingFormatted(itemId)
    local cooldownRemaining, protectedItem = self:GetCooldownRemaining(itemId)
    if not cooldownRemaining then
        return nil, protectedItem
    end
    return ZO_FormatTimeLargestTwo(cooldownRemaining, TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL), protectedItem
end

function class.BoxProtector:GetCooldownTooltip(itemId)
    local cooldownRemainingFormatted, protectedItem = self:GetCooldownRemainingFormatted(itemId)

    if not cooldownRemainingFormatted or not protectedItem then
        return
    end

    local cooldownTooltip = 
          zo_strformat(SI_UNBOXER_COOLDOWN, 
                       protectedItem.iconTexture, 
                       cooldownRemainingFormatted)
    return cooldownTooltip
end

function class.BoxProtector:IsCooldownProtected(itemId)
    local mainContainerItemId = self.mainContainerIdLookup[itemId] or itemId
    return addon.tracking.cooldownProtected[mainContainerItemId]
end

function class.BoxProtector:Protect(containerItemIds, lootItemIds, cooldownSeconds, icon)
  
    if #containerItemIds == 0 or #lootItemIds == 0 then
        return
    end
    local mainContainerItemId = containerItemIds[1]
    local itemLinkFormat = GetString(SI_UNBOXER_ITEMLINK_FORMAT)
    local containerItemLink = string.format(itemLinkFormat, mainContainerItemId)
    local mainLootItemId = lootItemIds[1]
    local mainLootItemLink = string.format(itemLinkFormat, mainLootItemId)
    if not icon then
        icon = GetItemLinkIcon(mainLootItemLink)
    end
    addon.Debug(self.name .. ":Protect( {'" .. containerItemLink .. "' ...}, {'"..mainLootItemLink.."' ...}, "
                .. tostring(cooldownSeconds) .. ", '" .. icon .. "' )", debug)
    local data = addon:GetItemLinkData(containerItemLink)
    local containerName = GetItemLinkTradingHouseItemSearchName(containerItemLink)
    local lowerContainerName = LocaleAwareToLower(containerName)
    
    local lootByItemIds = {}
    for _, itemId in ipairs(lootItemIds) do
        lootByItemIds[itemId] = true
    end
    
    local containersByItemIds = {}
    for _, itemId in ipairs(containerItemIds) do
        containersByItemIds[itemId] = true
    end
    
    local protectedItem = {
        mainContainerItemId = mainContainerItemId,
        lootItemIds   = lootByItemIds,
        containersByItemIds = containersByItemIds,
        containerName = containerName,
        lowerContainerName = lowerContainerName,
        cooldownSeconds = cooldownSeconds,
        data = data,
        iconTexture = "|t100%:100%:" .. icon .. "|t",
    }
	
    self.protectedItems[mainContainerItemId] = protectedItem
    self.mainContainerIdLookupByName[lowerContainerName] = mainContainerItemId
    
    for i=2,#containerItemIds do
        self.mainContainerIdLookup[containerItemIds[i]] = mainContainerItemId
    end
    
    if not data.rule then
        return
    end
    
    local optionsTable = data.rule:CreateLAM2Options()
    local optionName = zo_strformat(GetString(SI_UNBOXER_PROTECT), containerName)
    optionName = protectedItem.iconTexture .. " " .. optionName
    local optionTooltip = zo_strformat(GetString(SI_UNBOXER_PROTECT_TOOLTIP), containerItemLink, protectedItem.iconTexture)
    
    table.insert(optionsTable,
        {
            type     = "checkbox",
            name     = optionName,
            tooltip  = optionTooltip,
            getFunc  = function() return self:IsCooldownProtected(mainContainerItemId) end,
            setFunc  = function(value) self:SetCooldownProtected(mainContainerItemId, value) end,
            disabled = false,
            default  = true,
        })
    if self:IsCooldownProtected(mainContainerItemId) == nil then
        self:SetCooldownProtected(mainContainerItemId, true)
    end
end

function class.BoxProtector:RegisterDialog()
    if self.isDialogRegistered then
        return
    end
    local title = GetString(SI_UNBOXER_COOLDOWN_DIALOG_TITLE)
    local message = GetString(SI_UNBOXER_COOLDOWN_DIALOG_TEXT)
    local cancelCallback = function()
        EndLooting()
        ZO_Loot:SetHidden(true)
    end
    local confirmDialog = 
    {
        title = { text = title },
        mainText = { text = message },
        buttons = 
        {
            {
                text = GetString(SI_DIALOG_ACCEPT)
            },
            {
                text = GetString(SI_DIALOG_CANCEL),
                callback = cancelCallback,
            },
        },
        gamepadInfo =
        {
            dialogType = GAMEPAD_DIALOGS.BASIC,
        },
        noChoiceCallback = cancelCallback
    }
    ZO_Dialogs_RegisterCustomDialog(self.name .. "Dialog", confirmDialog)
    self.isDialogRegistered = true
end

function class.BoxProtector:SetCooldownProtected(mainContainerItemId, value)
    addon.tracking.cooldownProtected[mainContainerItemId] = value
end

function class.BoxProtector:ShowDialog(mainContainerItemId)
    
    addon.Debug(self.name .. ":ShowDialog(" .. tostring(mainContainerItemId) .. ")", debug)
    if not mainContainerItemId then
        addon.Debug(self.name .. " mainContainerItemId is NIL!", debug)
        return
    end
    
    local protectedItem = self.protectedItems[mainContainerItemId]
    if not protectedItem then
        addon.Debug(self.name .. " "..tostring(mainContainerItemId) .. " is not a protected container.", debug)
        return
    end
    
    self:RegisterDialog()
    
    local itemLinkFormat = GetString(SI_UNBOXER_ITEMLINK_FORMAT)
    local mainContainerItemLink = string.format(itemLinkFormat, mainContainerItemId)
    
    local dialogParams = 
    {
        warningParams = 
            {
                mainContainerItemLink
            },
        mainTextParams = 
            {
                mainContainerItemLink,
                protectedItem.iconTexture,
                self:GetCooldownRemainingFormatted(mainContainerItemId)
            },
    }
    ZO_Dialogs_ShowPlatformDialog(self.name .. "Dialog", {}, dialogParams)
end

function hookToolTips()
    tooltipHook(ItemTooltip, "SetBagItem", GetItemLink)
    tooltipHook(ItemTooltip, "SetLink", returnItemLink)
    tooltipHook(PopupTooltip, "SetLink", returnItemLink)
    tooltipHook(ItemTooltip, "SetLootItem", GetLootItemLink)
    tooltipHook(ItemTooltip, "SetAttachedMailItem", GetAttachedItemLink)
    --tooltipHookGamepad(GAMEPAD_TOOLTIPS.tooltips[GAMEPAD_LEFT_TOOLTIP].control.container.tip.tooltip, "AddItemTitle", returnItemLink) -- was causing errors 22/08/2023
	tooltipHookGamepad(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP), "AddItemTitle", returnItemLink) -- test 22/08/2023
    -- Uncomment the following if any containers other than Rewards for the Worthy ever get cooldowns
    --[[TooltipHook(ItemTooltip, "SetTradeItem", GetTradeItemLink)
    TooltipHook(ItemTooltip, "SetBuybackItem", GetBuybackItemLink)
    TooltipHook(ItemTooltip, "SetStoreItem", GetStoreItemLink)
    TooltipHook(ItemTooltip, "SetTradingHouseItem", GetTradingHouseSearchResultItemLink)
    TooltipHook(ItemTooltip, "SetTradingHouseListing", GetTradingHouseListingItemLink)]]
end

function returnItemLink(itemLink)
	return itemLink
end

function tooltipHook(tooltipControl, method, linkFunc)
    ZO_PreHook(tooltipControl, method, function(control, ...)
        local self = addon
        local itemLink = linkFunc(...)
        local itemId = GetItemLinkItemId(itemLink)
        local cooldownTooltip = self.protector:GetCooldownTooltip(itemId)
        if not cooldownTooltip then
            return
        end
        control:AddHeaderLine(cooldownTooltip, "ZoFontWinT2", 1, TOOLTIP_HEADER_SIDE_LEFT, COLOR_TOOLTIP:UnpackRGB())
    end)
end

function tooltipHookGamepad(tooltipControl, method, linkFunc)
    ZO_PreHook(tooltipControl, method, function(control, ...)
        local self = addon
        local itemLink = linkFunc(...)
        local itemId = GetItemLinkItemId(itemLink)
        local cooldownTooltip = self.protector:GetCooldownTooltip(itemId)
        if not cooldownTooltip then
            return
        end
        local cooldownSection = control:AcquireSection(control:GetStyle("topSection"))
        cooldownSection:AddLine(cooldownTooltip)
        control:AddSection(cooldownSection)
    end)
end