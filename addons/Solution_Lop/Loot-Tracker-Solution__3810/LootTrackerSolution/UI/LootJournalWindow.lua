LootTrackerSolution.LootJournalWindow = {}

local LJT = LootTrackerSolution.LootJournalWindow
local isFirstItem = true
local startTime = 0
local isTimerPaused = false
local currentSessionGold = 0
local pausedTime = 0
local LocalAutoLootEnabled = false
local FirstTimeAutoLoot = true

function LJT.ToggleWindow()

    if LJT.control then
        LJT.control:SetHidden(not LJT.control:IsHidden())
        if(LJT.control:IsHidden()) then
            LJT.TogglePause(LJT.control, true)
        end
    else
        LJT.CreateWindow()
    end

    LootTrackerSolution.LootStorageModule:SetGeneralSetting("MainWindowIsHidden", LJT.control:IsHidden())
end

function LJT.CalculateTotalPrice()
    local totalPrice = 0
    local scrollData = LJT.control.ScrollList.scrollData

    for _, itemData in ipairs(scrollData) do

        local price = LootTrackerSolution.TradeCenter.SelectPriceInfo(itemData.lastPrice) or 0

        local goldEarned = price * itemData.itemQuantity
        totalPrice = totalPrice + goldEarned
    end

    return totalPrice
end

function LJT:UpdateWindowItems()
    local control = LJT.control

    if #control.ScrollList.scrollData > 0 then
        currentSessionGold = LJT.CalculateTotalPrice()
        control.InfoBar.GoldLabel:SetText("|t16:16:EsoUI/Art/currency/currency_gold.dds|t " .. currentSessionGold)
    end

    local enableItemStacking = LootTrackerSolution.LootStorageModule:GetGeneralSetting("EnableItemStacking")

    local scrollData = control.ScrollList.scrollData
    if(enableItemStacking) then
        scrollData = LootTrackerSolution.LogicModule.RestructTableToItemStacking(scrollData)
    end
    scrollData = LootTrackerSolution.LogicModule.SortTable(scrollData)
    LootTrackerSolution.SolutionScrollList.UpdateScrollList(control.ScrollList, scrollData, 1)

    control:SetAlpha(LootTrackerSolution.LootStorageModule:GetGeneralSetting("MainWindowAlpha") / 10)

    control.InfoBar.InventorySpaceButton:SetAnchor(RIGHT, control.InfoBar, RIGHT, -(control.InfoBar.GoldLabel:GetWidth() + 10), 0)

    local InventorySpaceType = LootTrackerSolution.LootStorageModule:GetGeneralSetting("InventorySpaceType")
    if InventorySpaceType == 1 then
        control.InfoBar.InventorySpaceButton.label:SetText(string.format("|t20:20:LootTrackerSolution/Textures/ItemBag_Icon.dds|t %s", GetNumBagUsedSlots(BAG_BACKPACK) .. "/" .. GetBagSize(BAG_BACKPACK)))
    else
        control.InfoBar.InventorySpaceButton.label:SetText(string.format("|t20:20:LootTrackerSolution/Textures/ItemBag_Icon.dds|t %s", GetBagSize(BAG_BACKPACK) - GetNumBagUsedSlots(BAG_BACKPACK)))
    end
end

function LJT.InsertNewItem(itemData)

    local control = LJT.control
    if not control or not control.ScrollList then return end

    local newItem = {
        itemLink = itemData.itemLink,
        itemQuantity = itemData.itemQuantity,
        itemTime = GetTimeString(),
        lastPrice = itemData.itemLastPrice,
    }

    if isFirstItem then
        startTime = GetGameTimeMilliseconds()
        isFirstItem = false
        isTimerPaused = false
        LJT.UpdateTimeCounter()
        LJT:ToggleAutoLoot(true)

        control.InfoBar.RestartButton:SetHidden(false)
        control.InfoBar.PauseButton:SetHidden(false)
    else

        if isTimerPaused then
            LJT.TogglePause(control)
            LJT:ToggleAutoLoot(true)
        end
    end

    table.insert(control.ScrollList.scrollData, 1, newItem)
    LJT:UpdateWindowItems()
end

function LJT.LayoutRow(rowControl, data, scrollList)

    rowControl:SetHeight(25)
    rowControl:SetWidth(500)
    rowControl:SetHandler("OnMouseEnter", function(self)
        local pattern = "%|H0:.+%|h"
        local match = string.match(data.itemLink, pattern)

        if not match then return end
        InitializeTooltip(ItemTooltip, GuiRoot , CENTER, 0, 0, CENTER)
        ItemTooltip:SetLink(data.itemLink)
    end)
    rowControl:SetHandler("OnMouseExit", function(self)
        ClearTooltip(ItemTooltip)
    end)

    rowControl:SetHandler("OnMouseUp", function(self, button, upInside)
        if button == MOUSE_BUTTON_INDEX_RIGHT and upInside then
            StartChatInput(string.format("[%s]", data.itemLink))

            d(GetItemLinkItemId(data.itemLink))
        end
    end)

    local showTime = LootTrackerSolution.LootStorageModule:GetGeneralSetting("ShowTime")

    local itemPrice = LootTrackerSolution.TradeCenter.SelectPriceInfo(data.lastPrice) or 0

    local itemIcon, _ = GetItemLinkInfo(data.itemLink)

    local goldEarned = itemPrice * data.itemQuantity

    local labelTime = WINDOW_MANAGER:GetControlByName(rowControl:GetName() .. "Time")
    labelTime:SetAnchor(TOPLEFT, rowControl, TOPLEFT, 0, 0)
    if showTime then
        labelTime:SetText(string.format("[%s]", tostring(data.itemTime)))
    else
        labelTime:SetText("")
    end
    local widthTime, _ = labelTime:GetDimensions()

    local labelName = WINDOW_MANAGER:GetControlByName(rowControl:GetName() .. "Name")
    labelName:SetText(string.format("|t20:20:%s|t  %s", tostring(itemIcon), LootTrackerSolution.LogicModule.TrimItemLinkName(data.itemLink, 25)))
    labelName:SetAnchor(TOPLEFT, rowControl, TOPLEFT, widthTime + 10, 0)
    labelName:SetDimensionConstraints(0, 0, 260, 0)

    local labelGold = WINDOW_MANAGER:GetControlByName(rowControl:GetName() .. "Gold")
    labelGold:SetText(string.format("|t20:20:EsoUI/Art/currency/currency_gold.dds|t %s", goldEarned))
    labelGold:SetAnchor(TOPRIGHT, rowControl, TOPRIGHT, 0, 0)

    local labelLoot = WINDOW_MANAGER:GetControlByName(rowControl:GetName() .. "Loot")
    labelLoot:SetText(string.format("|t20:20:LootTrackerSolution/Textures/BagIcon.dds|t (%s)", data.itemQuantity))
    labelLoot:SetAnchor(TOPLEFT, rowControl, TOPLEFT, widthTime + 260 + 20, 0)
end

function LJT.OnRowSelect(previouslySelectedData, selectedData, reselectingDuringRebuild)

end

function LJT.UpdateTimeCounter()

    if not LJT.control or not LJT.control.InfoBar or not LJT.control.InfoBar.TimeLabel then
        return
    end

    if not isTimerPaused then
        local currentTime = GetGameTimeMilliseconds() - startTime + pausedTime
        local formattedTime = LootTrackerSolution.LogicModule.FormatTimeMilliseconds(currentTime)
        LJT.control.InfoBar.TimeLabel:SetText("Session: " .. formattedTime)
    end

    local InventorySpaceType = LootTrackerSolution.LootStorageModule:GetGeneralSetting("InventorySpaceType")
    if InventorySpaceType == 1 then
        LJT.control.InfoBar.InventorySpaceButton.label:SetText(string.format("|t20:20:LootTrackerSolution/Textures/ItemBag_Icon.dds|t %s", GetNumBagUsedSlots(BAG_BACKPACK) .. "/" .. GetBagSize(BAG_BACKPACK)))
    else
        LJT.control.InfoBar.InventorySpaceButton.label:SetText(string.format("|t20:20:LootTrackerSolution/Textures/ItemBag_Icon.dds|t %s", GetBagSize(BAG_BACKPACK) - GetNumBagUsedSlots(BAG_BACKPACK)))
    end

    zo_callLater(LJT.UpdateTimeCounter, 1000)
end

function LJT.TogglePause(control, Pause)

    if(Pause ~= nil) then
        isTimerPaused = Pause
    else
        isTimerPaused = not isTimerPaused
    end

    if isTimerPaused then
        pausedTime = pausedTime + (GetGameTimeMilliseconds() - startTime)
    else
        startTime = GetGameTimeMilliseconds()
    end

    control.InfoBar.PauseButton:SetHidden(isTimerPaused)
    control.InfoBar.ResumeButton:SetHidden(not isTimerPaused)
end

function LJT.RestartTimer()

    pausedTime = 0
    startTime = 0
    currentSessionGold = 0
    isTimerPaused = true
    isFirstItem = true

    LJT.control.InfoBar.GoldLabel:SetText("")
    LJT.control.InfoBar.TimeLabel:SetText("")
    LJT.control.InfoBar.PauseButton:SetHidden(true)
    LJT.control.InfoBar.ResumeButton:SetHidden(true)
    LJT.control.InfoBar.RestartButton:SetHidden(true)
    LJT.control.ScrollList.scrollData = {}
    LootTrackerSolution.SolutionScrollList.ClearList(LJT.control.ScrollList)
    LJT.control.InfoBar.InventorySpaceButton:SetAnchor(RIGHT, LJT.control.InfoBar, RIGHT, -(LJT.control.InfoBar.GoldLabel:GetWidth() + 10), 0)

end

function LJT:ToggleAutoLoot(toggle)
    local AutoLootAfterStart = LootTrackerSolution.LootStorageModule:GetGeneralSetting("AutoLootAfterStart")
    local control = LJT.control
    local localization = LootTrackerSolution.Localization.translation

    if toggle == nil then
        LocalAutoLootEnabled = not LocalAutoLootEnabled
    elseif not AutoLootAfterStart then
        return
    else
        LocalAutoLootEnabled = toggle
    end

    if FirstTimeAutoLoot then

        LootTrackerSolution.LootStorageModule:SetGeneralSetting("AutoLootDefault", ((GetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT)) == "1"))
        FirstTimeAutoLoot = false
    end

    control.AutoLoot:SetNormalTexture(LocalAutoLootEnabled and "LootTrackerSolution/Textures/AutoLootIcon_Enabled.dds" or "LootTrackerSolution/Textures/AutoLootIcon.dds")

    SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT, LocalAutoLootEnabled and "1" or "0")
    ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.GENERAL_ALERT_ERROR, LocalAutoLootEnabled and localization["AutoLootEnabled"] or localization["AutoLootDisabled"])
end

function LJT.CreateWindow()

    local control = WINDOW_MANAGER:GetControlByName("Solution_LootTable", "")

    if control then
        return
    end

    local MainWindowPosition = LootTrackerSolution.LootStorageModule:GetGeneralSetting("MainWindowPosition")

    control = WINDOW_MANAGER:CreateTopLevelWindow("Solution_LootTable")
    control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, MainWindowPosition[1], MainWindowPosition[2])
    control:SetDimensions(500, 325)
    control:SetMouseEnabled(true)
    control:SetMovable(true)
    control:SetResizeHandleSize(0)
    control:SetClampedToScreen(true)
    control:SetDimensionConstraints(300, 100, 700, 500)
    control:SetDrawLayer(DL_BACKGROUND)
    control:SetDrawLevel(0)
    control:SetAlpha(LootTrackerSolution.LootStorageModule:GetGeneralSetting("MainWindowAlpha") / 10)
    control:SetHandler("OnMoveStop", function()
        LootTrackerSolution.LootStorageModule:SetGeneralSetting("MainWindowPosition",{control:GetLeft(), control:GetTop()})
    end)

    control.Title = WINDOW_MANAGER:CreateControlFromVirtual("Solution_LootWindowTitle", control, "Solution_LootWindowTitle")
    control.Title:SetDimensions(control:GetWidth() - 30, 30)

    control.SettingsButton = WINDOW_MANAGER:CreateControlFromVirtual("Solution_LootWindowSettings", control, "Solution_LootWindowSettings")
    control.SettingsButton:SetHandler("OnClicked", function() LootTrackerSolution.LootSettingsWindow:ToggleOrCreateWindow() end)

    control.StatisticButton = WINDOW_MANAGER:CreateControlFromVirtual("Solution_LootWindowStatistic", control, "Solution_LootWindowStatistic")
    control.StatisticButton:SetHandler("OnClicked", function() LootTrackerSolution.LootStatisticsWindow:CreateOrToggleWindow() end)
    control.StatisticButton:SetAnchor(TOPLEFT, control.SettingsButton, TOPLEFT, -30, 0)

    control.AutoLoot = WINDOW_MANAGER:CreateControlFromVirtual("Solution_LootWindowAutoLoot", control, "Solution_LootWindowAutoLoot")
    control.AutoLoot:SetHandler("OnClicked", function() LJT:ToggleAutoLoot() end)
    control.AutoLoot:SetAnchor(TOPLEFT, control.StatisticButton, TOPLEFT, -30, 0)

    local background = WINDOW_MANAGER:CreateControl(nil, control, CT_BACKDROP)
    background:SetDimensions(control:GetWidth(), control:GetHeight())
    background:SetAnchor(CENTER, control, CENTER, 0, 0)
    background:SetEdgeTexture("EsoUI/Art/Miscellaneous/progressbar_ebb_divider.dds", 1, 1, 2)
    background:SetCenterColor(0, 0, 0, 0.7)
    background:SetEdgeColor(0, 0, 0, 1)

    control.InfoBar = WINDOW_MANAGER:CreateControl("Solution_InfoBar", control, CT_CONTROL)
    control.InfoBar:SetDimensions(control:GetWidth() - 30, 25)
    control.InfoBar:SetAnchor(BOTTOM, control, BOTTOM, 0, -5)

    local infoBar = control.InfoBar 
    infoBar.TimeLabel = WINDOW_MANAGER:CreateControlFromVirtual("Solution_InfoBarTimeLabel", infoBar, "Solution_InfoBarTimeLabel")
    infoBar.TimeLabel:SetAnchor(LEFT, infoBar, LEFT, 0, 0)

    infoBar.PauseButton = WINDOW_MANAGER:CreateControl("Solution_InfoBarPauseButton", infoBar, CT_BUTTON)
    infoBar.PauseButton:SetDimensions(22, 22)
    infoBar.PauseButton:SetHidden(true)
    infoBar.PauseButton:SetAnchor(LEFT, infoBar.TimeLabel, RIGHT, 10, -1)
    infoBar.PauseButton:SetNormalTexture("LootTrackerSolution/Textures/PauseIcon.dds")
    infoBar.PauseButton:SetHandler("OnClicked", function() LJT.TogglePause(control) end)

    infoBar.ResumeButton = WINDOW_MANAGER:CreateControl("Solution_InfoBarResumeButton", infoBar, CT_BUTTON)
    infoBar.ResumeButton:SetDimensions(22, 22)
    infoBar.ResumeButton:SetAnchor(LEFT, infoBar.TimeLabel, RIGHT, 10, 0)
    infoBar.ResumeButton:SetHidden(true)
    infoBar.ResumeButton:SetNormalTexture("LootTrackerSolution/Textures/ResumeIcon.dds")
    infoBar.ResumeButton:SetHandler("OnClicked", function() LJT.TogglePause(control) end)

    infoBar.RestartButton = WINDOW_MANAGER:CreateControl("Solution_InfoBarRestartButton", infoBar, CT_BUTTON)
    infoBar.RestartButton:SetDimensions(26, 26)
    infoBar.RestartButton:SetHidden(true)
    infoBar.RestartButton:SetAnchor(LEFT, infoBar.PauseButton, RIGHT, 0, 0)
    infoBar.RestartButton:SetNormalTexture("LootTrackerSolution/Textures/StopIcon.dds")
    infoBar.RestartButton:SetHandler("OnClicked", function() LJT.RestartTimer() end)

    infoBar.GoldLabel = WINDOW_MANAGER:CreateControlFromVirtual("Solution_InfoBarGoldLabel", infoBar, "Solution_InfoBarGoldLabel")
    infoBar.GoldLabel:SetAnchor(RIGHT, infoBar, RIGHT, 0, 0)

    infoBar.InventorySpaceButton = WINDOW_MANAGER:CreateControl("Solution_InfoBarInventorySpaceButton", infoBar, CT_BUTTON)
    infoBar.InventorySpaceButton:SetDimensions(100, 25) 
    infoBar.InventorySpaceButton:SetAnchor(RIGHT, infoBar, RIGHT, -(infoBar.GoldLabel:GetWidth()), 0)
    infoBar.InventorySpaceButton:SetHandler("OnMouseUp", function() SCENE_MANAGER:Toggle("inventory") end)

    infoBar.InventorySpaceButton.label = WINDOW_MANAGER:CreateControl(nil, infoBar.InventorySpaceButton, CT_LABEL)
    infoBar.InventorySpaceButton.label:SetFont("ZoFontWinH4")
    infoBar.InventorySpaceButton.label:SetAnchorFill()
    infoBar.InventorySpaceButton.label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

    local InventorySpaceType = LootTrackerSolution.LootStorageModule:GetGeneralSetting("InventorySpaceType")
    if InventorySpaceType == 1 then
        infoBar.InventorySpaceButton.label:SetText(string.format("|t20:20:LootTrackerSolution/Textures/ItemBag_Icon.dds|t %s", GetNumBagUsedSlots(BAG_BACKPACK) .. "/" .. GetBagSize(BAG_BACKPACK)))
    else
        infoBar.InventorySpaceButton.label:SetText(string.format("|t20:20:LootTrackerSolution/Textures/ItemBag_Icon.dds|t %s", GetBagSize(BAG_BACKPACK) - GetNumBagUsedSlots(BAG_BACKPACK)))
    end

    control.ScrollList = LootTrackerSolution.SolutionScrollList.CreateScrollList("Solution_LootList", control, LJT.LayoutRow, LJT.OnRowSelect, "Solution_RowT", 25)

    LJT.control = control
end