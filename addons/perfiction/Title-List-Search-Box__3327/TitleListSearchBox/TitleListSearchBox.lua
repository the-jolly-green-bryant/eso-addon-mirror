local TitleListSearchBox = TitleListSearchBox or {}
local TLSB = TitleListSearchBox
TLSB.name = "TitleListSearchBox"

--region Shared
TLSB.searchQuery = ""
TLSB.origStatsOnShowHandler = nil
TLSB.origGamepadStatsOnShowHandler = nil

function TLSB.AddItemPreHook(self, itemEntry, updateOptions)
    if not string.find(zo_strlower(itemEntry.name), zo_strlower(TLSB.searchQuery)) then
        return true
    end
end
--endregion

--region Keyboard
function TLSB.KB_InitializeSearchBox(self, hidden)
    ZO_PostHookHandler(ZO_StatsPanelPaneScrollChildDropdownRow1.dropdown.m_dropdown, "OnEffectivelyShown", TLSB.KB_DropdownShown)
    ZO_PostHookHandler(ZO_StatsPanelPaneScrollChildDropdownRow1.dropdown.m_dropdown, "OnEffectivelyHidden", TLSB.KB_DropdownHidden)
    ZO_PostHook(ZO_StatsPanelPaneScrollChildDropdownRow1Dropdown.m_comboBox, "SetSelected", TLSB.KB_TitleSelected)
    ZO_PreHook(ZO_StatsPanelPaneScrollChildDropdownRow1Dropdown.m_comboBox, "AddItem", TLSB.AddItemPreHook)

    TLSB_KB_Container:SetAnchor(BOTTOM, ZO_StatsPanelPaneScrollChildDropdownRow1Dropdown, TOP, 0, 0)
    TLSB_KB_ContainerEditBox:SetHandler("OnTextChanged", TLSB.KB_EditBoxTextChanged)
    TLSB_KB_ContainerCloseButton:SetHandler("OnMouseUp", TLSB.KB_CloseButtonMouseUp)

    -- (ugly) workaround to prevent Kyoma's crash at LibScrollableMenu.lua#408 when ZO_ScrollList_GetData(control) returns nil
    if ZO_StatsPanelPaneScrollChildDropdownRow1.scrollHelper ~= nil then
        ZO_PreHook(ZO_StatsPanelPaneScrollChildDropdownRow1.scrollHelper, "OnMouseExit", function(self, control)
            if control == nil then return true end
            local data = ZO_ScrollList_GetData(control)
            if data == nil then return true end
        end)
    end

    if TLSB.origStatsOnShowHandler ~= nil then TLSB.origStatsOnShowHandler(self, hidden) end
    STATS.control:SetHandler("OnShow", TLSB.origStatsOnShowHandler)
    TLSB.origStatsOnShowHandler = nil
end

function TLSB.KB_DropdownShown(self, hidden)
    TLSB_KB_Container:RegisterForEvent(EVENT_GLOBAL_MOUSE_UP, TLSB.KB_GlobalMouseUp)
    TLSB_KB_Container:SetHidden(false)
    TLSB_KB_ContainerEditBox:TakeFocus()
end

function TLSB.KB_DropdownHidden(self, hidden)
    TLSB_KB_Container:UnregisterForEvent(EVENT_GLOBAL_MOUSE_UP)
    TLSB_KB_Container:SetHidden(true)
end

function TLSB.KB_EditBoxTextChanged(self)
    TLSB.searchQuery = self:GetText()
    STATS:UpdateTitleDropdownTitles(ZO_StatsPanelPaneScrollChildDropdownRow1.dropdown)
    ZO_StatsPanelPaneScrollChildDropdownRow1Dropdown.m_comboBox:ShowDropdownOnMouseUp()
end

function TLSB.KB_TitleSelected(self, index)
    TLSB_KB_ContainerEditBox:SetHandler("OnTextChanged", nil)
    TLSB.searchQuery = ""
    TLSB_KB_ContainerEditBox:SetText("")
    TLSB_KB_ContainerEditBox:SetHandler("OnTextChanged", TLSB.KB_EditBoxTextChanged)
    STATS:UpdateTitleDropdownTitles(ZO_StatsPanelPaneScrollChildDropdownRow1.dropdown)
end

function TLSB.KB_CloseButtonMouseUp(self, button, upInside)
    if button == MOUSE_BUTTON_INDEX_LEFT and upInside == true then
        TLSB_KB_ContainerEditBox:SetText("")
        ZO_StatsPanelPaneScrollChildDropdownRow1Dropdown.m_comboBox:HideDropdown()
    end
end

function TLSB.KB_GlobalMouseUp(eventCode, button)
    if not TLSB_KB_Container:IsHidden() then
        if button == MOUSE_BUTTON_INDEX_LEFT and not MouseIsOver(TLSB_KB_Container) then
            TLSB.KB_CloseButtonMouseUp(TLSB_KB_ContainerCloseButton, MOUSE_BUTTON_INDEX_LEFT, true)
        end
    end
end
--endregion

--region Gamepad
function TLSB.GP_InitializeSearchBox(self, hidden)
    --Gamepad UI uses ZO_ComboBox_Gamepad_Dropdown singleton (which can be used for other purposes) to show title list, better not use its show and hide handlers
    ZO_PostHook(GAMEPAD_STATS.currentTitleDropdown, "Activate", TLSB.GP_DropdownShown)
    ZO_PostHook(GAMEPAD_STATS.currentTitleDropdown, "Deactivate", TLSB.GP_DropdownHidden)
    ZO_PostHook(GAMEPAD_STATS.currentTitleDropdown, "SelectHighlightedItem", TLSB.GP_TitleSelected)
    ZO_PreHook(GAMEPAD_STATS.currentTitleDropdown, "AddItem", TLSB.AddItemPreHook)

    TLSB_GP_Container:SetAnchor(BOTTOM, ZO_ComboBox_Gamepad_Dropdown, TOP, 0, -17)
    TLSB_GP_ContainerEditBox:SetHandler("OnTextChanged", TLSB.GP_EditBoxTextChanged)

    if TLSB.origGamepadStatsOnShowHandler ~= nil then TLSB.origGamepadStatsOnShowHandler(self, hidden) end
    GAMEPAD_STATS.control:SetHandler("OnShow", TLSB.origGamepadStatsOnShowHandler)
    TLSB.origGamepadStatsOnShowHandler = nil
end

function TLSB.GP_DropdownShown()
    TLSB_GP_Container:SetHidden(false)
    TLSB_GP_ContainerEditBox:TakeFocus()
    if TLSB.searchQuery ~= "" and TLSB.textChanged ~= true then
        zo_callLater(function() GAMEPAD_STATS.currentTitleDropdown:SetHighlightedItem(1) end, 25)
    end
end

function TLSB.GP_DropdownHidden()
    TLSB_GP_Container:SetHidden(true)
end

function TLSB.GP_EditBoxTextChanged(self)
    if self.oldText == self:GetText() then return end
    TLSB.searchQuery = self:GetText()
    TLSB.textChanged = true
    GAMEPAD_STATS:UpdateTitleDropdownTitles(GAMEPAD_STATS.currentTitleDropdown)
    GAMEPAD_STATS.currentTitleDropdown:Deactivate()
    GAMEPAD_STATS.currentTitleDropdown:Activate()
    TLSB.textChanged = nil
end

function TLSB.GP_TitleSelected(control, data)
    TLSB_GP_ContainerEditBox:SetHandler("OnTextChanged", nil)
    TLSB.searchQuery = ""
    TLSB_GP_ContainerEditBox:SetText("")
    TLSB_GP_ContainerEditBox:SetHandler("OnTextChanged", TLSB.GP_EditBoxTextChanged)
    GAMEPAD_STATS:UpdateTitleDropdownTitles(GAMEPAD_STATS.currentTitleDropdown)
end
--endregion

function TLSB.OnAddonLoaded(event, addonName)
    if addonName ~= TLSB.name then return end

    TLSB.origStatsOnShowHandler = STATS.control:GetHandler("OnShow")
    STATS.control:SetHandler("OnShow", TLSB.KB_InitializeSearchBox)

    TLSB.origGamepadStatsOnShowHandler = GAMEPAD_STATS.control:GetHandler("OnShow")
    GAMEPAD_STATS.control:SetHandler("OnShow", TLSB.GP_InitializeSearchBox)

    EVENT_MANAGER:UnregisterForEvent(TLSB.name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(TLSB.name, EVENT_ADD_ON_LOADED, TLSB.OnAddonLoaded)