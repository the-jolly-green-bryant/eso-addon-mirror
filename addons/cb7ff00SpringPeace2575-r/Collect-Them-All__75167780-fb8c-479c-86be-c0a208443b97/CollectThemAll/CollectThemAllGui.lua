-----------------------------------------------------------
-- Author: SpringPeace2575 | Version: 0.9.0
-- GUI module for CollectThemAll add-on
-----------------------------------------------------------

CollectThemAllGui = CollectThemAllGui or {}
local CTAGui = CollectThemAllGui
local CTAGuiControls = CollectThemAllGuiControls

CTAGui.PANE_FILTERS = 1
CTAGui.PANE_RESULTS = 2
CTAGui.SEARCH_DIALOG_NAME = "CTA_SEARCH_FILTER_DIALOG"
CTAGui.CATEGORY_DIALOG_NAME = "CTA_CATEGORY_DIALOG"
CTAGui.SUBCATEGORY_DIALOG_NAME = "CTA_SUBCATEGORY_DIALOG"
CTAGui.SOURCE_DIALOG_NAME = "CTA_SOURCE_DIALOG"
CTAGui.GROUP_DIALOG_NAME = "CTA_GROUP_DIALOG"

CTAGui.sv = {
    showUncollectedItemsOnly = false,
    enablePageRotation = true,
    showIcons = true,

    selectedCategory = "All",
    selectedSubcategory = "All",
    selectedSource = "All",
    selectedGroup = "All",
}

CTAGui.state = {
    guiRegistered = false,
    dialogsRegistered = false,
    menuEntryAdded = false,

    menuSceneName = "ctaMainScene",
    menuPane = nil,

    menuShowExtraItemData = false,

    menuTopLevel = nil,
    filterList = nil,
    resultsList = nil,
    categoryDropdown = nil,
}

CTAGui.RC = {
    GetStats = function() return 0, 0, 0, 0, 1, 1, 0 end,
    CalculateVisibleRows = function() end,
    GetSelectedRow = function() return nil end,
    RecreateResult = function(selectedRow) return {} end,
    RecheckUncollectedItems = function() end,
    GetOrderedByLabel = function() return "" end,
    NextOrderedBy = function() end,
    GetSources = function() return {} end,
    GetGroups = function() return {} end,
    Build = function(forced) end,

    state = {
        searchFilter = "",
        matchingPage = 1,
        matchingTotalPages = 1,
        matchingSelectedRow = nil,
        matchingPageRows = {},
    },

    callbacks = {
        RefreshFull = function() end,
    },
}

function CTAGui.Initialize(sv, ResultsController)
    if CTAGui.guiRegistered then return end

    CTAGui.sv = sv
    CTAGui.RC = ResultsController

    CTAGui.EnsureSavedVariables()
    CTAGui.EnsureState()
    CTAGui.RegisterDialogs()
    CTAGui.CreateLists()
    CTAGui.CreateScene()

    CTAGui.guiRegistered = true
end

function CTAGui.EnsureSavedVariables()
    if type(CTAGui.sv.showUncollectedItemsOnly) ~= "boolean" then CTAGui.sv.showUncollectedItemsOnly = false end
    if type(CTAGui.sv.enablePageRotation) ~= "boolean" then CTAGui.sv.enablePageRotation = true end
    if type(CTAGui.sv.showIcons) ~= "boolean" then CTAGui.sv.showIcons = true end
    if type(CTAGui.sv.selectedCategory) ~= "string" then CTAGui.sv.selectedCategory = "All" end
    if type(CTAGui.sv.selectedSubcategory) ~= "string" then CTAGui.sv.selectedSubcategory = "All" end
    if type(CTAGui.sv.selectedSource) ~= "string" then CTAGui.sv.selectedSource = "All" end
    if type(CTAGui.sv.selectedGroup) ~= "string" then CTAGui.sv.selectedGroup = "All" end
end

function CTAGui.EnsureState()
    CTAGui.state.guiRegistered = CTAGui.state.guiRegistered or false
    CTAGui.state.dialogsRegistered = CTAGui.state.dialogsRegistered or false
    CTAGui.state.menuEntryAdded = CTAGui.state.menuEntryAdded or false

    CTAGui.state.menuSceneName = CTAGui.state.menuSceneName or "ctaMainScene"
    CTAGui.state.menuPane = CTAGui.state.menuPane or CTAGui.PANE_RESULTS

    CTAGui.state.menuShowExtraItemData = CTAGui.state.menuShowExtraItemData or false
end

function CTAGui.RefreshAll()
    if not CTAGui.guiRegistered or not SCENE_MANAGER:IsShowing(CTAGui.state.menuSceneName) then return end

    CTAGui.RC.CalculateVisibleRows()
    local matching, total, collectedMatching, collectedTotal, page, totalPages, neededTradeBars = CTAGui.RC.GetStats()

    CTAGuiControls.UpdateHeader(matching, total, collectedMatching, collectedTotal, page, totalPages, neededTradeBars)
    CTAGui.RefreshFilterList()
    CTAGui.RefreshResultsList()
    CTAGuiControls.SetPaneVisuals(CTAGui.state.menuPane)
    CTAGui.RefreshKeybindings()
end



----------------
-- Keybindings
----------------

CTAGui.menuKeybindStripDescriptor = {
    alignment = KEYBIND_STRIP_ALIGN_LEFT,
    {
        name = function()
            return (CTAGui.state.menuPane == CTAGui.PANE_FILTERS) and "Results Pane" or "Filters Pane"
        end,
        keybind = "UI_SHORTCUT_LEFT_SHOULDER",
        sound = SOUNDS.GAMEPAD_MENU_BACK,
        callback = function()
            CTAGui.MovePane(-1)
        end,
    },
    {
        name = function()
            return (CTAGui.state.menuPane == CTAGui.PANE_FILTERS) and "Results Pane" or "Filters Pane"
        end,
        keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
        sound = SOUNDS.GAMEPAD_MENU_FORWARD,
        callback = function()
            CTAGui.MovePane(1)
        end,
    },
    {
        name = function()
            return (CTAGui.sv.enablePageRotation and CTAGui.RC.state.matchingPage == 1) and "Last Page" or "Prev Page"
        end,
        keybind = "UI_SHORTCUT_LEFT_TRIGGER",
        sound = SOUNDS.GAMEPAD_PAGE_BACK,
        callback = function()
            if CTAGui.RC.state.matchingPage > 1 then
                CTAGui.RC.state.matchingPage = CTAGui.RC.state.matchingPage - 1
                CTAGui.RC.state.matchingSelectedRow = nil
                CTAGui.RefreshAll()
            elseif CTAGui.sv.enablePageRotation and CTAGui.RC.state.matchingPage == 1 then
                CTAGui.RC.state.matchingPage = CTAGui.RC.state.matchingTotalPages
                CTAGui.RC.state.matchingSelectedRow = nil
                CTAGui.RefreshAll()
            end
        end,
        enabled = function()
            return CTAGui.RC.state.matchingPage > 1 or CTAGui.sv.enablePageRotation
        end,
    },
    {
        name = function()
            return (CTAGui.sv.enablePageRotation and CTAGui.RC.state.matchingPage == CTAGui.RC.state.matchingTotalPages) and "First Page" or "Next Page"
        end,
        keybind = "UI_SHORTCUT_RIGHT_TRIGGER",
        sound = SOUNDS.GAMEPAD_PAGE_FORWARD,
        callback = function()
            if CTAGui.RC.state.matchingPage < CTAGui.RC.state.matchingTotalPages then
                CTAGui.RC.state.matchingPage = CTAGui.RC.state.matchingPage + 1
                CTAGui.RC.state.matchingSelectedRow = nil
                CTAGui.RefreshAll()
            elseif CTAGui.sv.enablePageRotation and CTAGui.RC.state.matchingPage == CTAGui.RC.state.matchingTotalPages then
                CTAGui.RC.state.matchingPage = 1
                CTAGui.RC.state.matchingSelectedRow = nil
                CTAGui.RefreshAll()
            end
        end,
        enabled = function()
            return CTAGui.RC.state.matchingPage < CTAGui.RC.state.matchingTotalPages or CTAGui.sv.enablePageRotation
        end,
    },
    {
        name = function()
            if CTAGui.state.menuPane == CTAGui.PANE_FILTERS then
                return "Activate"
            elseif CTAGui.state.menuPane == CTAGui.PANE_RESULTS and CTAGui.RC.GetSelectedRow() ~= nil then
                return CTAGui.state.menuShowExtraItemData and "Less Info" or "More Info"
            end
            return nil
        end,
        keybind = "UI_SHORTCUT_PRIMARY",
        visible = function()
            if CTAGui.state.menuPane == CTAGui.PANE_FILTERS then
                return true
            end
            return false -- return CTAGui.state.menuPane == CTAGui.PANE_RESULTS and CTAGui.RC.GetSelectedRow() ~= nil
        end,
        callback = function()
            if CTAGui.state.menuPane == CTAGui.PANE_FILTERS then
                CTAGui.ActivateCurrentFilter()
            elseif CTAGui.state.menuPane == CTAGui.PANE_RESULTS and CTAGui.RC.GetSelectedRow() ~= nil then
                CTAGui.ToggleExtraItemDataDetail()
            end
        end,
    },
    {
        name = GetString(SI_GAMEPAD_BACK_OPTION),
        keybind = "UI_SHORTCUT_NEGATIVE",
        callback = function()
            SCENE_MANAGER:HideCurrentScene()
        end,
    },
}

function CTAGui.AddKeybindings()
    if KEYBIND_STRIP and CTAGui.menuKeybindStripDescriptor then
        KEYBIND_STRIP:AddKeybindButtonGroup(CTAGui.menuKeybindStripDescriptor)
    end
end

function CTAGui.RefreshKeybindings()
    if KEYBIND_STRIP and CTAGui.menuKeybindStripDescriptor then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(CTAGui.menuKeybindStripDescriptor)
    end
end

function CTAGui.RemoveKeybindings()
    if KEYBIND_STRIP and CTAGui.menuKeybindStripDescriptor then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(CTAGui.menuKeybindStripDescriptor)
    end
end



-----------------
-- Filters Menu
-----------------

function CTAGui.GetFilters()
    local searchText = SPFLibUtils.SafeText(CTAGui.RC.state.searchFilter)
    if searchText == "" then searchText = "All" end

    return {
        {
            text = string.format("Category: %s", CTAGui.sv.selectedCategory),
            callback = function()
                CTAGui.OpenCategoryDialog()
            end,
        },
        {
            text = string.format("Subcategory: %s", CTAGui.sv.selectedSubcategory),
            callback = function()
                CTAGui.OpenSubategoryDialog()
            end,
        },
        {
            text = string.format("Source: %s", CTAGui.sv.selectedSource),
            callback = function()
                CTAGui.OpenSourceDialog()
            end,
        },
        {
            text = string.format("Group: %s", CTAGui.sv.selectedGroup),
            callback = function()
                CTAGui.OpenGroupDialog()
            end,
        },
        {
            text = string.format("Search Filter: %s", searchText),
            callback = function()
                CTAGui.OpenSearchFilterDialog()
            end,
        },
        {
            text = string.format("Collected Items: %s", CTAGui.sv.showUncollectedItemsOnly and "Hide" or "Show"),
            callback = function()
                CTAGui.sv.showUncollectedItemsOnly = not CTAGui.sv.showUncollectedItemsOnly
                CTAGui.RC.state.matchingPage = 1
                CTAGui.PlayClickSound()
                CTAGui.RC.callbacks.RefreshFull()
            end,
        },
        {
            text = string.format("Ordered by: %s", CTAGui.RC.GetOrderedByLabel()),
            callback = function()
                CTAGui.RC.NextOrderedBy()
                CTAGui.RC.state.matchingPage = 1
                CTAGui.PlayClickSound()
                CTAGui.RC.callbacks.RefreshFull()
            end,
        },
        {
            text = string.format("Rows Per Page: %d", CTAGui.RC.state.matchingPageSize),
            callback = function()
                local newSize = CTAGui.RC.state.matchingPageSize == 50 and 100 or 50
                CTAGui.RC.state.matchingPageSize = newSize
                CTAGui.RC.state.matchingPage = 1
                CTAGui.PlayClickSound()
                CTAGui.RefreshAll()
            end,
        },
        {
            text = "Recheck Uncollected Items",
            callback = function()
                CTAGui.PlayClickSound()
                CTAGui.RC.RecheckUncollectedItems()
            end,
        },
        {
            text = "Rebuild saved results",
            callback = function()
                CTAGui.PlayClickSound()
                CTAGui.RC.Build(true)
            end,
        },
    }
end



------------
-- Changes
------------

function CTAGui.ToggleExtraItemDataDetail()
    if CTAGui.state.menuPane ~= CTAGui.PANE_RESULTS then
        return
    end

    local selectedRow = CTAGui.RC.GetSelectedRow()
    if selectedRow == nil then
        return
    end

    CTAGui.state.menuShowExtraItemData = not CTAGui.state.menuShowExtraItemData
    CTAGuiControls.RefreshDetailPanel(CTAGui.RC.RecreateResult(selectedRow), CTAGui.state.menuShowExtraItemData)
    CTAGui.RefreshKeybindings()
end

function CTAGui.ActivateCurrentFilter()
    if not CTAGui.state.filterList then return end
    local selected = CTAGui.state.filterList:GetTargetData()
    if selected and selected.filterCallback then
        selected.filterCallback()
    end
end

function CTAGui.SetActivePane(pane)
    if pane ~= CTAGui.PANE_FILTERS and pane ~= CTAGui.PANE_RESULTS then
        pane = CTAGui.PANE_RESULTS
    end
    CTAGui.state.menuPane = pane

    if CTAGui.state.filterList and CTAGui.state.resultsList then
        if pane == CTAGui.PANE_FILTERS then
            if CTAGui.state.resultsList.Deactivate then CTAGui.state.resultsList:Deactivate() end
            if CTAGui.state.filterList.Activate then CTAGui.state.filterList:Activate() end
        else
            if CTAGui.state.filterList.Deactivate then CTAGui.state.filterList:Deactivate() end
            if CTAGui.state.resultsList.Activate then CTAGui.state.resultsList:Activate() end
        end
    end

    CTAGuiControls.SetPaneVisuals(pane == CTAGui.PANE_FILTERS, pane == CTAGui.PANE_RESULTS)
    CTAGui.RefreshKeybindings()
end

function CTAGui.MovePane(delta)
    local pane = CTAGui.state.menuPane or CTAGui.PANE_RESULTS
    pane = pane + delta
    if pane < CTAGui.PANE_FILTERS then pane = CTAGui.PANE_RESULTS end
    if pane > CTAGui.PANE_RESULTS then pane = CTAGui.PANE_FILTERS end
    CTAGui.SetActivePane(pane)
end

function CTAGui.PlayClickSound()
	if PlaySound == nil then return end
	if SOUNDS ~= nil then
		if SOUNDS.DEFAULT_CLICK ~= nil then
			PlaySound(SOUNDS.DEFAULT_CLICK)
			return
		end
	end
end



-------------
-- Controls
-------------

function CTAGui.CreateLists()
    local leftPaneList = CTAGuiControls.GetLeftPaneList()
    if not leftPaneList then return end
    CTAGui.state.filterList = ZO_GamepadVerticalItemParametricScrollList:New(leftPaneList)
    CTAGui.state.filterList:AddDataTemplate("CTAFilterRowTemplate", CTAGuiControls.FilterEntrySetup, ZO_GamepadMenuEntryTemplateParametricListFunction)
    CTAGui.state.filterList:SetOnSelectedDataChangedCallback(function(list, selectedData)
        CTAGui.RefreshKeybindings()
    end)

    local centerPaneList = CTAGuiControls.GetCenterPaneList()
    if not centerPaneList then return end
    CTAGui.state.resultsList = ZO_GamepadVerticalItemParametricScrollList:New(centerPaneList)
    CTAGui.state.resultsList:AddDataTemplate("CTAResultRowTemplate", CTAGuiControls.ResultEntrySetup, ZO_GamepadMenuEntryTemplateParametricListFunction)
    CTAGui.state.resultsList:SetOnSelectedDataChangedCallback(function(list, selectedData)
        if selectedData and selectedData.row then
            CTAGui.RC.state.matchingSelectedRow = selectedData.row
            CTAGuiControls.RefreshDetailPanel(CTAGui.RC.RecreateResult(selectedData.row), CTAGui.state.menuShowExtraItemData)
        else
            CTAGui.RC.state.matchingSelectedRow = nil
            CTAGuiControls.RefreshDetailPanel(nil, CTAGui.state.menuShowExtraItemData)
        end
        CTAGui.RefreshKeybindings()
    end)
end

function CTAGui.CreateScene()
    local root = CTAGuiControls.GetRoot()
    if not root then return end

    local scene = SCENE_MANAGER:GetScene(CTAGui.state.menuSceneName)
    if not scene then
        scene = ZO_Scene:New(CTAGui.state.menuSceneName, SCENE_MANAGER)
    end

    local fragment = ZO_FadeSceneFragment:New(root)
    scene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    scene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD_OPTIONS)
    scene:AddFragment(MINIMIZE_CHAT_FRAGMENT)
    scene:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT)
    scene:AddFragment(fragment)

    scene:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_SHOWING then
            CTAGui.RefreshAll()
            CTAGui.AddKeybindings()
            CTAGui.SetActivePane(CTAGui.state.menuPane or CTAGui.PANE_RESULTS)
        elseif newState == SCENE_HIDDEN then
            if CTAGui.state.filterList and CTAGui.state.filterList.Deactivate then CTAGui.state.filterList:Deactivate() end
            if CTAGui.state.resultsList and CTAGui.state.resultsList.Deactivate then CTAGui.state.resultsList:Deactivate() end
            CTAGui.RemoveKeybindings()
        end
    end)

    CTAGui.state.menuScene = scene
    CTAGui.state.menuTopLevel = root
end

function CTAGui.RefreshFilterList()
    if not CTAGui.state.filterList then return end
    CTAGui.state.filterList:Clear()

    local filters = CTAGui.GetFilters()

    for _, filter in ipairs(filters) do
        local entry = ZO_GamepadEntryData:New(filter.text)
        entry.filterCallback = filter.callback
        CTAGui.state.filterList:AddEntry("CTAFilterRowTemplate", entry)
    end

    CTAGui.state.filterList:Commit()
end

local function Mem(label)
    d(string.format("[CTA]: %s: %.1f KB", label, collectgarbage("count")))
end

function CTAGui.RefreshResultsList()
    if not CTAGui.state.resultsList then return end

    -- Mem("Mem before clear")
    CTAGui.state.resultsList:Clear()
    -- more collectgarbage calls can help, because some objects become garbage during previous pass
    collectgarbage("collect")
    -- collectgarbage("collect")
    -- collectgarbage("collect")
    -- Mem("Mem after clear")

    for _, row in ipairs(CTAGui.RC.state.matchingPageRows) do
        local result = CTAGui.RC.RecreateResult(row)

        local type = SPFLibUtils.SafeText(result.typeName)
        local category = SPFLibUtils.SafeText(result.categoryName)
        local subcategory = SPFLibUtils.SafeText(result.subcategoryName)
        local categorySubcategoryName = category
        if subcategory ~= "" then
            categorySubcategoryName = string.format("%s - %s", category, subcategory)
        end

        local entry = ZO_GamepadEntryData:New("")
        entry.collectibleText = result.collectibleName
        entry.categoryText = category
        entry.subcategoryText = subcategory
        entry.categorySubcategoryText = categorySubcategoryName
        entry.typeText = type
        entry.collectibleId = result.collectibleId
        entry.row = row
        entry.showLearnIcon = result.isUncollected
        entry.showItemIcon = CTAGui.sv.showIcons

        CTAGui.state.resultsList:AddEntry("CTAResultRowTemplate", entry)
    end

    CTAGui.state.resultsList:Commit()

    local row = CTAGui.RC.GetSelectedRow()
    if not row and CTAGui.RC.state.matchingPageRows[1] then
        row = CTAGui.RC.state.matchingPageRows[1]
        
    end
    CTAGui.RC.state.matchingSelectedRow = row
    CTAGuiControls.RefreshDetailPanel(CTAGui.RC.RecreateResult(row), CTAGui.state.menuShowExtraItemData)
end



------------
-- Dialogs
------------

local function ReleaseDialog(dialogName)
    if ZO_Dialogs_ReleaseDialogOnButtonPress then
        ZO_Dialogs_ReleaseDialogOnButtonPress(dialogName)
    end
end

local function SetupRequestEntry(control, data, selected, reselectingDuringRebuild, enabled, active)
    if ZO_SharedGamepadEntry_OnSetup then
        ZO_SharedGamepadEntry_OnSetup(control, data, selected, reselectingDuringRebuild, enabled, active)
    end
end

function CTAGui.RegisterSearchDialog()
    -- local parametricDialog = ZO_GenericGamepadDialog_GetControl and ZO_GenericGamepadDialog_GetControl(GAMEPAD_DIALOGS.PARAMETRIC) or nil
    ZO_Dialogs_RegisterCustomDialog(CTAGui.SEARCH_DIALOG_NAME,
    {
        gamepadInfo =
        {
            dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
        },
        title =
        {
            text = "Search Filter",
        },
        setup = function(dialog)
            dialog.info.parametricList =
            {
                {
                    template = "ZO_Gamepad_GenericDialog_Parametric_TextFieldItem",
                    templateData = {
                        nameField = true,
                        textChangedCallback = function(control)
                            if dialog.data then
                                dialog.data.filterText = control:GetText()
                            end
                        end,
                        setup = function(control, data, selected, reselectingDuringRebuild, enabled, active)
                            control.highlight:SetHidden(not selected)
                            control.editBoxControl.textChangedCallback = data.textChangedCallback
                            if control.editBoxControl.SetMaxInputChars then
                                control.editBoxControl:SetMaxInputChars(100)
                            end
                            if control.editBoxControl.SetDefaultText then
                                control.editBoxControl:SetDefaultText("All")
                            end
                            control.editBoxControl:SetText((dialog.data and dialog.data.filterText) or "")
                            data.control = control
                        end,
                        callback = function(dialogRef)
                            local targetData = dialogRef.entryList:GetTargetData()
                            if targetData and targetData.control and targetData.control.editBoxControl and targetData.control.editBoxControl.TakeFocus then
                                targetData.control.editBoxControl:TakeFocus()
                            end
                        end,
                        narrationText = ZO_GetDefaultParametricListEditBoxNarrationText,
                    },
                },
                {
                    template = "ZO_GamepadTextFieldSubmitItem",
                    templateData = {
                        text = "Apply Filter",
                        setup = SetupRequestEntry,
                        callback = function(dialogRef)
                            CTAGui.RC.state.searchFilter = SPFLibUtils.SafeText(dialogRef.data and dialogRef.data.filterText)
                            CTAGui.RC.state.matchingPage = 1
                            CTAGui.RC.state.matchingSelectedRow = nil
                            CTAGui.RefreshAll()
                            ReleaseDialog(CTAGui.SEARCH_DIALOG_NAME)
                        end,
                    },
                },
                {
                    template = "ZO_GamepadTextFieldSubmitItem",
                    templateData = {
                        text = "Clear Filter",
                        setup = SetupRequestEntry,
                        callback = function(dialogRef)
                            CTAGui.RC.state.searchFilter = ""
                            CTAGui.RC.state.matchingPage = 1
                            CTAGui.RC.state.matchingSelectedRow = nil
                            CTAGui.RefreshAll()
                            ReleaseDialog(CTAGui.SEARCH_DIALOG_NAME)
                        end,
                    },
                },
            }
            dialog:setupFunc()
        end,
        blockDialogReleaseOnPress = true,
        buttons =
        {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_GAMEPAD_SELECT_OPTION,
                callback = function(dialog)
                    local targetData = dialog.entryList:GetTargetData()
                    if targetData and targetData.callback then
                        targetData.callback(dialog)
                    end
                end,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_DIALOG_CANCEL,
                callback = function()
                    ReleaseDialog(CTAGui.SEARCH_DIALOG_NAME)
                end,
            },
        },
    })
end

function CTAGui.RegisterSingleSelectDialog(dialogName)
    ZO_Dialogs_RegisterCustomDialog(dialogName,
    {
        gamepadInfo =
        {
            dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
        },
        title =
        {
            text = "",
        },
        setup = function(dialog)
            local data = dialog.data or {}
            local selectedValue = data.selectedValue
            local selectedIndex = 1
            local options = data.options or {}

            if dialog.info and dialog.info.title then
                dialog.info.title.text = data.title or "Select"
            end

            dialog.info.parametricList = {}

            for i, option in ipairs(options) do
                local isCurrent = (option.value == selectedValue)

                if isCurrent then
                    selectedIndex = i
                end

                table.insert(dialog.info.parametricList,
                {
                    template = "ZO_GamepadMenuEntryTemplate",
                    templateData =
                    {
                        text = option.name,
                        baseText = option.name,
                        value = option.value,
                        isCurrent = isCurrent,
                        setup = function(control, data, selected, reselectingDuringRebuild, enabled, active)
                            ZO_SharedGamepadEntry_OnSetup(control, data, selected, reselectingDuringRebuild, enabled, active)

                            local label = control.label or (control.GetNamedChild and control:GetNamedChild("Label"))
                            if not label then return end

                            local text = data.baseText or data.text or ""

                            if data.isCurrent then
                                text = zo_iconTextFormat("EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_equipped.dds", 24, 24, text)
                            end

                            label:SetText(text)
                        end,
                        callback = function(dialogRef)
                            if data.onSelect then
                                data.onSelect(option, dialogRef)
                            end
                            ReleaseDialog(dialogName)
                        end,
                    },
                })
            end

            dialog:setupFunc()

            if dialog.entryList then
                if dialog.entryList.SetTargetIndex then
                    dialog.entryList:SetTargetIndex(selectedIndex)
                elseif dialog.entryList.SetSelectedIndexWithoutAnimation then
                    dialog.entryList:SetSelectedIndexWithoutAnimation(selectedIndex)
                end
            end
        end,
        blockDialogReleaseOnPress = true,
        buttons =
        {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_GAMEPAD_SELECT_OPTION,
                callback = function(dialog)
                    local targetData = dialog.entryList:GetTargetData()
                    if targetData and targetData.callback then
                        targetData.callback(dialog)
                    end
                end,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_DIALOG_CANCEL,
                callback = function()
                    ReleaseDialog(dialogName)
                end,
            },
        },
    })
end

function CTAGui.RegisterDialogs()
    if CTAGui.state.dialogsRegistered then return end
    CTAGui.state.dialogsRegistered = true

    CTAGui.RegisterSearchDialog()
    CTAGui.RegisterSingleSelectDialog(CTAGui.CATEGORY_DIALOG_NAME)
    CTAGui.RegisterSingleSelectDialog(CTAGui.SUBCATEGORY_DIALOG_NAME)
    CTAGui.RegisterSingleSelectDialog(CTAGui.SOURCE_DIALOG_NAME)
    CTAGui.RegisterSingleSelectDialog(CTAGui.GROUP_DIALOG_NAME)
end

function CTAGui.OpenSearchFilterDialog()
    CTAGui.RegisterDialogs()
    ZO_Dialogs_ShowGamepadDialog(CTAGui.SEARCH_DIALOG_NAME, { filterText = SPFLibUtils.SafeText(CTAGui.RC.state.searchFilter) })
end

function CTAGui.GetAvailableCategories()
    local options = {
        { name = "All", value = "All" },
    }
    for categoryIndex = 1, GetNumCollectibleCategories() do
        local nameC, numSC, u3, unlockedC, totalC, u6 = GetCollectibleCategoryInfo(categoryIndex)
        -- TODO: exclude some categories
        options[#options + 1] = { name = nameC, value = nameC }
    end
    return options
end

function CTAGui.GetAvailableSubcategories()
    local options = {
        { name = "All", value = "All" },
    }
    for categoryIndex = 1, GetNumCollectibleCategories() do
        local nameC, numSC, u3, unlockedC, totalC, u6 = GetCollectibleCategoryInfo(categoryIndex)
        -- TODO: exclude some categories
        if nameC == CTAGui.sv.selectedCategory then
            for subcategoryIndex = 1, GetNumSubcategoriesInCollectibleCategory(categoryIndex) do
                local nameSC, v2, unlockedSC, totalSC = GetCollectibleSubCategoryInfo(categoryIndex, subcategoryIndex)
                options[#options + 1] = { name = nameSC, value = nameSC }
            end
        end
    end
    return options
end

function CTAGui.GetSimpleOptions(values)
    local options = {
        { name = "All", value = "All" },
    }
    for _, value in ipairs(values) do
        options[#options + 1] = { name = value, value = value }
    end
    return options
end

function CTAGui.OpenCategoryDialog()
    CTAGui.RegisterDialogs()
    ZO_Dialogs_ShowGamepadDialog(CTAGui.CATEGORY_DIALOG_NAME, {
        title = "Category",
        selectedValue = CTAGui.sv.selectedCategory,
        options = CTAGui.GetAvailableCategories(),
        onSelect = function(option)
            CTAGui.sv.selectedCategory = option.value
            CTAGui.sv.selectedSubcategory = "All"
            CTAGui.RC.state.matchingPage = 1
            CTAGui.RC.state.matchingSelectedRow = nil
            CTAGui.RefreshAll()
        end,
    })
end

function CTAGui.OpenSubategoryDialog()
    CTAGui.RegisterDialogs()
    ZO_Dialogs_ShowGamepadDialog(CTAGui.SUBCATEGORY_DIALOG_NAME, {
        title = "Subcategory",
        selectedValue = CTAGui.sv.selectedSubcategory,
        options = CTAGui.GetAvailableSubcategories(),
        onSelect = function(option)
            CTAGui.sv.selectedSubcategory = option.value
            CTAGui.RC.state.matchingPage = 1
            CTAGui.RC.state.matchingSelectedRow = nil
            CTAGui.RefreshAll()
        end,
    })
end

function CTAGui.OpenSourceDialog()
    CTAGui.RegisterDialogs()
    ZO_Dialogs_ShowGamepadDialog(CTAGui.SOURCE_DIALOG_NAME, {
        title = "Source",
        selectedValue = CTAGui.sv.selectedSource,
        options = CTAGui.GetSimpleOptions(CTAGui.RC.GetSources()),
        onSelect = function(option)
            CTAGui.sv.selectedSource = option.value
            CTAGui.sv.selectedGroup = "All"
            CTAGui.RC.state.matchingPage = 1
            CTAGui.RC.state.matchingSelectedRow = nil
            CTAGui.RefreshAll()
        end,
    })
end

function CTAGui.OpenGroupDialog()
    CTAGui.RegisterDialogs()
    ZO_Dialogs_ShowGamepadDialog(CTAGui.GROUP_DIALOG_NAME, {
        title = "Group",
        selectedValue = CTAGui.sv.selectedGroup,
        options = CTAGui.GetSimpleOptions(CTAGui.RC.GetGroups()),
        onSelect = function(option)
            CTAGui.sv.selectedGroup = option.value
            CTAGui.RC.state.matchingPage = 1
            CTAGui.RC.state.matchingSelectedRow = nil
            CTAGui.RefreshAll()
        end,
    })
end

function CTAGui.GetSelectedRowFromUI()
    -- TODO: check resultsList
    if CTAGui.resultsList and CTAGui.resultsList.GetTargetData then
        local selected = CTAGui.resultsList:GetTargetData()
        if selected and selected.row then
            return selected.row
        end
    end
    return nil
end
