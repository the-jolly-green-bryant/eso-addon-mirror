LootTrackerSolution.LootSettingsWindow = {}

local LSW = LootTrackerSolution.LootSettingsWindow

function LSW:InsertNewItem(label, type, value, options)
    if not LSW.window.ScrollList then return end

    local newItem = {
        label = label,
        type = type,
        value = value,
        options = options
    }

    table.insert(LSW.window.ScrollList.scrollData, newItem)
end

function LSW.LayoutRow(rowControl, rowData)

    local label = WINDOW_MANAGER:CreateControl(nil, rowControl, CT_LABEL)
    label:SetAnchor(TOPLEFT, rowControl, TOPLEFT, 10, 10)
    label:SetFont("ZoFontWinH4")
    label:SetText(rowData.label)
    label:SetDimensions(400, 30)

    if rowData.type == "checkbox" then
        local control = WINDOW_MANAGER:CreateControlFromVirtual(nil, rowControl, "CheckBoxControl")
        control:SetAnchor(TOPRIGHT, rowControl, TOPRIGHT, -10, 10)
        control:SetDimensions(24, 24)

        local state = LootTrackerSolution.LootStorageModule:GetGeneralSetting(tostring(rowData.value))
        control:SetNormalTexture(state and "LootTrackerSolution/Textures/CheckBoxTrueIcon.dds" or "LootTrackerSolution/Textures/CheckBoxFalseIcon.dds")

        control:SetHandler("OnMouseUp", function ()
            state = not state
            LootTrackerSolution.LootStorageModule:SetGeneralSetting(rowData.value, state)     
            control:SetNormalTexture(state and "LootTrackerSolution/Textures/CheckBoxTrueIcon.dds" or "LootTrackerSolution/Textures/CheckBoxFalseIcon.dds")
        end)
    elseif rowData.type == "dropdown" or rowData.type == "dropdownSound" then
        local itemSetDropdown = Solution_GetOrCreateControlFromVirtual(rowControl, rowData.value .. "_DropDown", "Solution_DropDown")
        if itemSetDropdown == nil then return end

        itemSetDropdown:SetDimensions(250, 25)
        itemSetDropdown:ClearAnchors()
        itemSetDropdown:SetAnchor(TOPRIGHT, rowControl, TOPRIGHT, -10, 10)
        itemSetDropdown.m_comboBox:SetSortsItems(false)
        itemSetDropdown.m_comboBox:SetFont("ZoFontWinH5")
        local dropdown = ZO_ComboBox_ObjectFromContainer(itemSetDropdown)

        for i, option in ipairs(rowData.options) do
            local entry = dropdown:CreateItemEntry(option, function()
                LootTrackerSolution.LootStorageModule:SetGeneralSetting(rowData.value, i)

                if rowData.type == "dropdownSound" then
                    local soundName = option
                    PlaySound(soundName)
                end
            end)
            dropdown:AddItem(entry)
        end

        local selectedItem = LootTrackerSolution.LootStorageModule:GetGeneralSetting(rowData.value)
        dropdown:SetSelectedItem(rowData.options[selectedItem])
    elseif rowData.type == "slider" then
        local slider = WINDOW_MANAGER:CreateControlFromVirtual(nil, rowControl, "ZO_Slider")
        slider:SetAnchor(TOPRIGHT, rowControl, TOPRIGHT, -10, 10)
        slider:SetMinMax(tonumber(rowData.options[1]), tonumber(rowData.options[2]))
        slider:SetDimensions(200, 25)

        local label = WINDOW_MANAGER:CreateControl(nil, rowControl, CT_LABEL)
        label:SetAnchor(TOPRIGHT, rowControl, TOPRIGHT, -220, 10)
        label:SetFont("ZoFontWinH5")
        label:SetText(string.format("%s%%", LootTrackerSolution.LootStorageModule:GetGeneralSetting(rowData.value) * 10))

        slider:SetHandler("OnValueChanged", function() 
            LootTrackerSolution.LootStorageModule:SetGeneralSetting(rowData.value, math.floor(slider:GetValue()))
            label:SetText(string.format("%s%%", LootTrackerSolution.LootStorageModule:GetGeneralSetting(rowData.value) * 10))
        end)

        local sliderSettings = LootTrackerSolution.LootStorageModule:GetGeneralSetting(rowData.value)
        slider:SetValue(sliderSettings)
    end
end

function LSW:FillWindow()
    local localization = LootTrackerSolution.Localization.translation
    LSW:InsertNewItem(localization["DisplayTime"], "checkbox", "ShowTime")
    LSW:InsertNewItem(localization["ItemStacking"], "checkbox", "EnableItemStacking")
    LSW:InsertNewItem(localization["PriceDataSource"], "dropdown", "PriceSource", { "Tamriel Trade Centre", "Vendor" })
    LSW:InsertNewItem(localization["PriceCalculationMethod"], "dropdown", "PriceType", { localization["PriceTypeAvarage"], localization["PriceTypeMin"], localization["PriceTypeMax"], localization["PriceTypeSuggested"] } )
    LSW:InsertNewItem(localization["NotifyOnLegendary"], "checkbox", "NotifyOnLegendary")
    LSW:InsertNewItem(localization["NotifyOnNirncrux"], "checkbox", "NotifyOnSalt")
    LSW:InsertNewItem(localization["TextNotify"], "checkbox", "TextNotify")
    LSW:InsertNewItem(localization["AutoLootAfterStart"], "checkbox", "AutoLootAfterStart")
    LSW:InsertNewItem(localization["NotificationSound"], "dropdownSound", "NotificationSound", { "Console_Game_Enter", "Endeavor_Complete", "New_Notification", "Defer_Notification", "CodeRedemption_Success", "Fence_Item_Laundered", "Market_CrownsSpent", "None" })
    LSW:InsertNewItem(localization["SortListParametr"], "dropdown", "SortListParametr", {  localization["Time"], localization["Price"], localization["Amount"]})
    LSW:InsertNewItem(localization["SortListDirection"], "dropdown", "SortListDirection", { localization["SortListDirectionAsc"], localization["SortListDirectionDesc"] })
    LSW:InsertNewItem(localization["InventorySpaceType"], "dropdown", "InventorySpaceType", { string.format("|t20:20:LootTrackerSolution/Textures/ItemBag_Icon.dds|t %s", GetNumBagUsedSlots(BAG_BACKPACK) .. "/" .. GetBagSize(BAG_BACKPACK)), string.format("|t20:20:LootTrackerSolution/Textures/ItemBag_Icon.dds|t %s", GetBagSize(BAG_BACKPACK) - GetNumBagUsedSlots(BAG_BACKPACK)) })
    LSW:InsertNewItem(localization["SetLootWindowAlpha"], "slider", "MainWindowAlpha", { "3", "10" })

    LootTrackerSolution.SolutionScrollList.UpdateScrollList(LSW.window.ScrollList, LSW.window.ScrollList.scrollData, 1)
end

function LSW:ToggleOrCreateWindow()
    if not LSW.window then
        LSW:CreateWindow()
        LSW.window:SetHidden(true)
    end
    local isHidden = LSW.window:IsHidden()
    LSW.window:SetHidden(not isHidden)
end

function LSW:CreateWindow()
    if LSW.window then return end

    local localization = LootTrackerSolution.Localization.translation

    local window = WINDOW_MANAGER:CreateTopLevelWindow("LootSettingsWindow")
    window:SetDimensions(800, 600)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetMouseEnabled(true)
    window:SetMovable(true)
    window:SetResizeHandleSize(0)
    window:SetClampedToScreen(true)

    window.Title = WINDOW_MANAGER:CreateControlFromVirtual("Solution_LootSettingsTitle", window, "Solution_LootSettingsTitle")
    window.Title:SetDimensions(window:GetWidth() - 30, 30)

    window.Close = WINDOW_MANAGER:CreateControlFromVirtual("Solution_LootSettingsClose", window, "Solution_LootSettingsClose")
    window.Close:SetAnchor(TOPRIGHT, window, TOPRIGHT, -20, 20)

    window.Close:SetHandler("OnMouseUp", function()
        window:SetHidden(true)
        LootTrackerSolution.LootJournalWindow:UpdateWindowItems()

    end)

    window.Donate = WINDOW_MANAGER:CreateControl("Solution_LootSettingsDonate", window, CT_BUTTON)
    window.Donate:SetDimensions(200, 30)
    window.Donate:SetAnchor(RIGHT, window, BOTTOMRIGHT, -15, -15)
    window.Donate:SetHandler("OnMouseUp", function()
        if MAIL_SEND:IsHidden() then
            MAIL_SEND:ComposeMailTo("@Solution_Lop")
          else
            MAIL_SEND:SetReply("@Solution_Lop")
          end
          LSW:ToggleOrCreateWindow()
    end)

    window.Donate.label = WINDOW_MANAGER:CreateControl("Solution_LootSettingsDonateLabel", window.Donate, CT_LABEL)
    window.Donate.label:SetAnchorFill()
    window.Donate.label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    window.Donate.label:SetFont("ZoFontWinH5")
    window.Donate.label:SetText(string.format("%s |t20:20:LootTrackerSolution/Textures/LoveIcon.dds|t", localization["Donate"]))

    window.Author = WINDOW_MANAGER:CreateControl("Solution_LootSettingsAuthor", window, CT_LABEL)
    window.Author:SetDimensions(200, 30)
    window.Author:SetAnchor(LEFT, window, BOTTOMLEFT, 15, -15)
    window.Author:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    window.Author:SetFont("ZoFontWinH5")
    window.Author:SetText(localization["Author"] .. ": @Solution_Lop")

    window.ScrollList = LootTrackerSolution.SolutionScrollList.CreateScrollList("Solution_SettingsList", window, LSW.LayoutRow, LSW.OnRowSelect, "Solution_RowSettings", 36)
    window.ScrollList:SetDimensions(window:GetWidth() - 25, window:GetHeight() - 60)
    window.ScrollList:SetAnchor(TOPLEFT, window, TOPLEFT, 20, 40)
    LSW.window = window

    local background = WINDOW_MANAGER:CreateControl(nil, LSW.window, CT_BACKDROP)
    background:SetDimensions(LSW.window:GetWidth(), LSW.window:GetHeight())
    background:SetAnchor(CENTER, LSW.window, CENTER, 0, 0)
    background:SetEdgeTexture("EsoUI/Art/Miscellaneous/progressbar_ebb_divider.dds", 1, 1, 2)
    background:SetCenterColor(0, 0, 0, 0.7)
    background:SetEdgeColor(0, 0, 0, 1)

    LSW:FillWindow()
end