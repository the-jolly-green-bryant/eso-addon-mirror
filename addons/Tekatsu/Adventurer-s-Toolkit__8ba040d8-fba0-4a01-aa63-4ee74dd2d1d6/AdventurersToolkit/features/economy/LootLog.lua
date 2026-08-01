-- ============================================
-- LOOT LOG MODULE (Always-on daily tracking)
-- ============================================

NWT.LootLog = { isOpen = false, sceneInitialized = false }

NWT.lootCurrentTab = 1

local function GetItemValue(itemId, itemLink)
    if not itemId or itemId == 0 then return 0 end
    if ATPriceDataXBNA and ATPriceDataXBNA.priceData then
        local priceStr = ATPriceDataXBNA.priceData[itemId]
        if priceStr then
            local avgPrice = tonumber(priceStr:match("^([^,]+)"))
            if avgPrice then return avgPrice end
        end
    end
    return 0
end

local function GetDayStart(timestamp)
    local secondsInDay = 86400
    return math.floor(timestamp / secondsInDay) * secondsInDay
end

function NWT.CheckLootLogDailyReset()
    if not NWT.savedVars or not NWT.savedVars.lootLog then return end
    local now = GetTimeStamp()
    local todayStart = GetDayStart(now)
    local lastReset = NWT.savedVars.lootLog.lastResetTimestamp or 0
    
    if GetDayStart(lastReset) < todayStart then
        NWT.savedVars.lootLog.today = { items = {}, goldLooted = 0, totalValue = 0, itemCount = 0 }
        NWT.savedVars.lootLog.lastResetTimestamp = now
        NWT.Debug("|c00FF00[Loot Log]|r Daily reset - new day started!")
    end
end

function NWT.OnLootReceivedForLog(eventCode, receivedBy, itemName, quantity, soundCategory, lootType, isSelf, isPickpocket, questItemIcon, itemId, isStolen)
    if not isSelf or not NWT.savedVars or not NWT.savedVars.lootLog then return end
    NWT.CheckLootLogDailyReset()
    
    local today = NWT.savedVars.lootLog.today
    local value = GetItemValue(itemId, nil) * quantity
    
    today.itemCount = today.itemCount + quantity
    today.totalValue = today.totalValue + value
    
    if not today.items[itemId] then
        today.items[itemId] = { name = itemName, quantity = 0, value = 0 }
    end
    today.items[itemId].quantity = today.items[itemId].quantity + quantity
    today.items[itemId].value = today.items[itemId].value + value
end

function NWT.OnLootGoldForLog(eventCode, newMoney, oldMoney, reason)
    if not NWT.savedVars or not NWT.savedVars.lootLog then return end
    NWT.CheckLootLogDailyReset()
    
    local validReasons = {
        [CURRENCY_CHANGE_REASON_LOOT] = true,
        [CURRENCY_CHANGE_REASON_LOOT_STOLEN] = true,
        [CURRENCY_CHANGE_REASON_PICKPOCKET] = true,
        [CURRENCY_CHANGE_REASON_QUESTREWARD] = true,
        [CURRENCY_CHANGE_REASON_REWARD] = true,
        [CURRENCY_CHANGE_REASON_MAIL] = true,
    }
    if not validReasons[reason] then return end
    
    local change = newMoney - oldMoney
    if change > 0 then
        NWT.savedVars.lootLog.today.goldLooted = NWT.savedVars.lootLog.today.goldLooted + change
    end
end

function NWT.OnMailItemTakenForLog(eventCode, mailId)
    if not NWT.savedVars or not NWT.savedVars.lootLog then return end
    NWT.CheckLootLogDailyReset()
    
    local today = NWT.savedVars.lootLog.today
    local numAttachments = GetMailAttachmentInfo(mailId)
    
    for i = 1, numAttachments do
        local itemLink = GetAttachedItemLink(mailId, i, LINK_STYLE_DEFAULT)
        if itemLink and itemLink ~= "" then
            local itemId = GetItemLinkItemId(itemLink)
            local itemName = GetItemLinkName(itemLink)
            local _, stackCount = GetAttachedItemInfo(mailId, i)
            stackCount = stackCount or 1
            
            local value = GetItemValue(itemId, itemLink) * stackCount
            
            today.itemCount = today.itemCount + stackCount
            today.totalValue = today.totalValue + value
            
            if not today.items[itemId] then
                today.items[itemId] = { name = itemName, quantity = 0, value = 0 }
            end
            today.items[itemId].quantity = today.items[itemId].quantity + stackCount
            today.items[itemId].value = today.items[itemId].value + value
        end
    end
end

function NWT.ResetLootLogToday()
    if not NWT.savedVars or not NWT.savedVars.lootLog then return end
    NWT.savedVars.lootLog.today = { items = {}, goldLooted = 0, totalValue = 0, itemCount = 0 }
    NWT.savedVars.lootLog.lastResetTimestamp = GetTimeStamp()
    NWT.Debug("|cFFD700[Loot Log]|r Manual reset!")
    PlaySound(SOUNDS.POSITIVE_CLICK)
end

function NWT.UpdateLootLogView()
    local ui = ATK_LootLog_UI or ATK_LootLog_UI
    if not ui then return end
    NWT.CheckLootLogDailyReset()
    local colors = NWT.GetColors()
    local today = NWT.savedVars.lootLog.today
    local tot = today.goldLooted + today.totalValue
    
    -- Check for new UI structure
    local rightCol = ui:GetNamedChild("RightCol")
    local sessionCard = rightCol and rightCol:GetNamedChild("SessionCard")
    
    if sessionCard then
        -- New ATK_LootLog_UI structure
        local header = ui:GetNamedChild("Header")
        if header then
            local subtitle = header:GetNamedChild("Subtitle")
            if subtitle then subtitle:SetText("|c00FF00Always Tracking|r") end
        end
        
        -- Today's stats
        local totalItems = sessionCard:GetNamedChild("TotalItems")
        local totalValue = sessionCard:GetNamedChild("TotalValue")
        local goldLooted = sessionCard:GetNamedChild("GoldLooted")
        local durationLabel = sessionCard:GetNamedChild("Duration")
        local goldPerHour = sessionCard:GetNamedChild("GoldPerHour")
        local itemsPerHour = sessionCard:GetNamedChild("ItemsPerHour")
        local bestItem = sessionCard:GetNamedChild("BestItem")
        
        if totalItems then totalItems:SetText("|c888888Items:|r  |cFFFFFF" .. today.itemCount .. "|r") end
        if totalValue then totalValue:SetText("|c888888Value:|r  |c00FF00" .. NWT.FormatGoldLedger(today.totalValue) .. "g|r") end
        if goldLooted then goldLooted:SetText("|c888888Gold:|r  |cFFD700" .. NWT.FormatGoldLedger(today.goldLooted) .. "g|r") end
        if durationLabel then durationLabel:SetText("|c888888Total:|r  |cFFD700" .. NWT.FormatGoldLedger(tot) .. "g|r") end
        if goldPerHour then goldPerHour:SetHidden(true) end
        if itemsPerHour then itemsPerHour:SetHidden(true) end
        
        -- Top items
        local sorted = {}
        for id, data in pairs(today.items or {}) do table.insert(sorted, { name = data.name, quantity = data.quantity, value = data.value }) end
        table.sort(sorted, function(a, b) return a.value > b.value end)
        
        if bestItem and sorted[1] then bestItem:SetText("|c888888Best:|r  |cFFD700" .. sorted[1].name .. "|r") end
        
        local topItemsCard = rightCol:GetNamedChild("TopItemsCard")
        if topItemsCard then
            for i = 1, 8 do
                local label = topItemsCard:GetNamedChild("Item" .. i)
                if label then
                    local item = sorted[i]
                    if item then label:SetText(string.format("|cFFFFFF%d.|r %s x%d |c00FF00%sg|r", i, item.name, item.quantity, NWT.FormatGoldLedger(item.value)))
                    else label:SetText("") end
                end
            end
        end
        
        local footer = ui:GetNamedChild("Footer")
        if footer then footer:SetText("|c888888[X] Reset Today  [B] Back|r") end
    else
        -- Old ATK_LootLog_UI structure
        local lp, rp = ui:GetNamedChild("LeftPanel"), ui:GetNamedChild("RightPanel")
        if lp and rp then
            lp:GetNamedChild("Header"):SetText("|c00FF00TODAY'S LOOT|r")
            lp:GetNamedChild("Total"):SetText("|cFFFFFF" .. today.itemCount .. " items|r")
            lp:GetNamedChild("Gold"):SetText("  Gold Received: |c" .. colors.positive .. NWT.FormatGoldLedger(today.goldLooted) .. "g|r")
            lp:GetNamedChild("Inventory"):SetText("  Items Looted: |cFFFFFF" .. today.itemCount .. "|r")
            lp:GetNamedChild("Bank"):SetText("  Items Value: |c" .. colors.positive .. NWT.FormatGoldLedger(today.totalValue) .. "g|r")
            lp:GetNamedChild("FurnitureVault"):SetText("  |cFFD700TOTAL VALUE: " .. NWT.FormatGoldLedger(tot) .. "g|r")
            lp:GetNamedChild("Housing"):SetText("")
            
            local sorted = {}
            for id, data in pairs(today.items or {}) do table.insert(sorted, { name = data.name, quantity = data.quantity, value = data.value }) end
            table.sort(sorted, function(a, b) return a.value > b.value end)
            
            for i = 1, 10 do
                local label = rp:GetNamedChild("Item" .. i)
                if label then
                    local item = sorted[i]
                    if item then label:SetText(string.format("|cFFFFFF%d.|r %s x%d |c%s%sg|r", i, item.name, item.quantity, colors.positive, NWT.FormatGoldLedger(item.value)))
                    else label:SetText("") end
                end
            end
            ui:GetNamedChild("Title"):SetText("|cFFD700TODAY'S LOOT|r")
            ui:GetNamedChild("Updated"):SetText("|c00FF00Always tracking - resets daily|r")
        end
    end
end

function NWT.InitLootLogScene()
    if NWT.LootLog.sceneInitialized then return end
    local ui = ATK_LootLog_UI or ATK_LootLog_UI
    if not ui then return end
    LOOT_LOG_SCENE = ZO_Scene:New("lootLogScene", SCENE_MANAGER)
    LOOT_LOG_SCENE:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    LOOT_LOG_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
    LOOT_LOG_SCENE:AddFragment(ZO_SimpleSceneFragment:New(ui))
    
    NWT.LootLogKeybinds = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        { name = "Refresh", keybind = "UI_SHORTCUT_SECONDARY", callback = function() NWT.RefreshLootCurrentTab() PlaySound(SOUNDS.POSITIVE_CLICK) end },
        { name = "Prev Tab", keybind = "UI_SHORTCUT_LEFT_SHOULDER", callback = function() NWT.SwitchLootTab("left") end },
        { name = "Next Tab", keybind = "UI_SHORTCUT_RIGHT_SHOULDER", callback = function() NWT.SwitchLootTab("right") end },
        { name = "Reset Today", keybind = "UI_SHORTCUT_TERTIARY", callback = function() NWT.ResetLootLogToday() NWT.RefreshLootCurrentTab() end },
    }
    ZO_Gamepad_AddBackNavigationKeybindDescriptors(NWT.LootLogKeybinds, GAME_NAVIGATION_TYPE_BUTTON, function() NWT.CloseLootLog() end)
    
    LOOT_LOG_SCENE:RegisterCallback("StateChange", function(os, ns)
        if ns == SCENE_SHOWING then
            if KEYBIND_STRIP then KEYBIND_STRIP:AddKeybindButtonGroup(NWT.LootLogKeybinds) end
            NWT.LootLog.isOpen = true NWT.UpdateLootLogView()
        elseif ns == SCENE_HIDDEN then
            if KEYBIND_STRIP then KEYBIND_STRIP:RemoveKeybindButtonGroup(NWT.LootLogKeybinds) end
            NWT.LootLog.isOpen = false
        end
    end)
    NWT.LootLog.sceneInitialized = true
end

function NWT.OpenLootLog()
    if NWT.LootLog.isOpen then return end
    if not NWT.LootLog.sceneInitialized then NWT.InitLootLogScene() end
    NWT.UpdateLootLogView()
    SCENE_MANAGER:Push("lootLogScene")
end

function NWT.CloseLootLog() if LOOT_LOG_SCENE then SCENE_MANAGER:Hide("lootLogScene") end end
function NWT.UpdateLootRadarView()
    local ui = ATK_LootLog_UI or ATK_LootLog_UI
    if not ui then return end
    
    NWT.UpdateNearbyContainers()
    
    local colors = NWT.GetColors()
    local leftPanel = ui:GetNamedChild("LeftPanel")
    local rightPanel = ui:GetNamedChild("RightPanel")
    
    -- Left Panel - Radar Stats
    leftPanel:GetNamedChild("Header"):SetText("|c00FF00LOOT RADAR|r")
    leftPanel:GetNamedChild("Total"):SetText(string.format("|cFFFFFF%d|r discovered", NWT.savedVars.lootRadar.discoveryCount))
    
    leftPanel:GetNamedChild("Gold"):SetText(string.format("  Nearby: |c%s%d|r", colors.positive, #NWT.nearbyContainers))
    leftPanel:GetNamedChild("Inventory"):SetText("")
    leftPanel:GetNamedChild("Bank"):SetText("")
    leftPanel:GetNamedChild("CraftBag"):SetText("")
    leftPanel:GetNamedChild("FurnitureVault"):SetText("")
    leftPanel:GetNamedChild("Housing"):SetText("")
    leftPanel:GetNamedChild("GuildBanks"):SetText("")
    
    -- Right Panel - Nearby Containers
    rightPanel:GetNamedChild("Header"):SetText("|cFFD700Nearby Containers|r")
    
    for i = 1, 10 do
        local label = rightPanel:GetNamedChild("Item" .. i)
        if label then
            local container = NWT.nearbyContainers[i]
            if container then
                local color = container.isOwned and colors.negative or colors.positive
                label:SetText(string.format("|cFFFFFF%d.|r %s (|c%s%.1fm|r)", i, container.name, color, container.distance))
            else
                label:SetText("")
            end
        end
    end
    
    ui:GetNamedChild("Title"):SetText("|cFFD700LOOT RADAR|r")
    ui:GetNamedChild("Updated"):SetText("|c888888Detecting nearby lootable objects...|r")
end
function NWT.SwitchLootTab(direction)
    local oldTab = NWT.lootCurrentTab
    
    if direction == "left" then
        NWT.lootCurrentTab = NWT.lootCurrentTab - 1
        if NWT.lootCurrentTab < 1 then NWT.lootCurrentTab = 2 end
    else
        NWT.lootCurrentTab = NWT.lootCurrentTab + 1
        if NWT.lootCurrentTab > 2 then NWT.lootCurrentTab = 1 end
    end
    
    if oldTab ~= NWT.lootCurrentTab then
        PlaySound(SOUNDS.HORIZONTAL_LIST_TRACK_SELECTED)
        NWT.RefreshLootCurrentTab()
    end
end

function NWT.RefreshLootCurrentTab()
    if NWT.lootCurrentTab == 1 then
        NWT.UpdateLootLogView()
    else
        NWT.UpdateLootRadarView()
    end
    
    -- Update controls hint
    local ui = ATK_LootLog_UI
    if ui then
        local tabName = NWT.lootCurrentTab == 1 and "Loot Log" or "Loot Radar"
        ui:GetNamedChild("Controls"):SetText(string.format("|c888888[LB/RB] %s  [X] Reset  [B] Back|r", tabName))
    end
end
