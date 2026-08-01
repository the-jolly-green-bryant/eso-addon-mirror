AddonCategory = AddonCategory or {}
local AddonCategory = AddonCategory

AddonCategory.name = "AddonCategory"
AddonCategory.version = "1.6.2"
AddonCategory.author = "Floliroy, fixed and updated by Baertram"
local MAJOR = AddonCategory.name

local WM = WINDOW_MANAGER
local EM = EVENT_MANAGER

local sV

local ADDON_DATA = 1
local SECTION_HEADER_DATA = 2

local IS_LIBRARY = true
local IS_ADDON = false
local libraryText
local libraryCatIndex

local AddOnManager = GetAddOnManager()

local expandedAddons = {}
local g_uniqueNamesByCharacterName = {}

local addonsListCtrl = ZO_AddOnsList

AddonCategory.indexCategories = {}
local ac_indexCategories = AddonCategory.indexCategories


local defaultCustomScrollableMenuOptions = {
--> === Dropdown general customization =================================================================================
--		number visibleRowsDropdown:optional		Number or function returning number of shown entries at 1 page of the scrollable comboBox's opened dropdown
--		number visibleRowsSubmenu:optional		Number or function returning number of shown entries at 1 page of the scrollable comboBox's opened submenus
--		number maxDropdownHeight				Number or function returning number of total dropdown's maximum height
--		boolean sortEntries:optional			Boolean or function returning boolean if items in the main-/submenu should be sorted alphabetically. !!!Attention: Default is TRUE (sorting is enabled)!!!
--		table sortType:optional					table or function returning table for the sort type, e.g. ZO_SORT_BY_NAME, ZO_SORT_BY_NAME_NUMERIC
--		boolean sortOrder:optional				Boolean or function returning boolean for the sort order ZO_SORT_ORDER_UP or ZO_SORT_ORDER_DOWN
-- 		string font:optional				 	String or function returning a string: font to use for the dropdown entries
-- 		number spacing:optional,	 			Number or function returning a Number: Spacing between the entries
--		boolean disableFadeGradient:optional	Boolean or function returning a boolean: for the fading of the top/bottom scrolled rows
--		table headerColor:optional				table (ZO_ColorDef) or function returning a color table with r, g, b, a keys and their values: for header entries
--		table normalColor:optional				table (ZO_ColorDef) or function returning a color table with r, g, b, a keys and their values: for all normal (enabled) entries
--		table disabledColor:optional 			table (ZO_ColorDef) or function returning a color table with r, g, b, a keys and their values: for all disabled entries
--		boolean highlightContextMenuOpeningControl Boolean or function returning boolean if the openingControl of a context menu should be highlighted. Only works at the contextMenu options!
--												If you set this to true you also need to set data.m_highlightTemplate at the row and provide the XML template name for the highLight, e.g. "LibScrollableMenu_Highlight_Green"
-->  ===Dropdown header/title ==========================================================================================
--		string titleText:optional				String or function returning a string: Title text to show above the dropdown entries
--		string titleFont:optional				String or function returning a font string: Title text's font. Default: "ZoFontHeader3"
--		string subtitleText:optional			String or function returning a string: Sub-title text to show below the titleText and above the dropdown entries
--		string subtitleFont:optional			String or function returning a font string: Sub-Title text's font. Default: "ZoFontHeader2"
--		number titleTextAlignment:optional		Number or function returning a number: The title's vertical alignment, e.g. TEXT_ALIGN_CENTER
--		userdata customHeaderControl:optional	Userdata or function returning Userdata: A custom control thta should be shown above the dropdown entries
--		boolean headerCollapsible			 	Boolean or function returning boolean if the header control should show a collapse/expand button
-->  === Dropdown text search & filter =================================================================================
--		boolean enableFilter:optional			Boolean or function returning boolean which controls if the text search/filter editbox at the dropdown header is shown
--		function customFilterFunc				A function returning a boolean true: show item / false: hide item. Signature of function: customFilterFunc(item, filterString)
--->  === Dropdown callback functions
-- 		function preshowDropdownFn:optional 	function function(ctrl) codeHere end: to run before the dropdown shows
--->  === Dropdown's Custom XML virtual row/entry templates ============================================================
--		boolean useDefaultHighlightForSubmenuWithCallback	Boolean or function returning a boolean if always the default ZO_ComboBox highlight XML template should be used for an entry having a submenu AND a callback function. If false the highlight 'LibScrollableMenu_Highlight_Green' will be used
    enableFilter = true,
}
local defaultLSMSubmenuEntriesSortFunc = function(a,b)
    if a.label and b.label then
        return a.label < b.label
    else
        return a.name < b.name
    end
end

local function listCategoryUniqueKeyTableSort(a, b)
    return a.uniqueKey < b.uniqueKey
end

--If an entry was moved to an index it should definately "get there" and not sorted behind another same index
local function listCategoryCustomOrderTableSortWrapper(a, b)
    return a.customSortOrder and b.customSortOrder and a.customSortOrder < b.customSortOrder
end

local function StripText(text)
    return text:gsub("|c%x%x%x%x%x%x", "")
end

local function updateAddonManagerDataIfShown()
    if ADD_ON_MANAGER.control:IsHidden() then return end
    ADD_ON_MANAGER.isDirty = true
    ADD_ON_MANAGER:RefreshData()
end

local function afterSettigs()
    if sV == nil then return end

    local listCategories = sV.listCategory
    if listCategories == nil then return end

    local fixedCategories = {}

    for k, vData in ipairs(listCategories) do
        --List data is no table (format needed for LibAddonMenuOrderListBox widget's list)
        if type(vData) ~= "table" then
            fixedCategories[k] = {
                uniqueKey = k,
                value = k,
                text = vData,
            }
        else
            fixedCategories[k] = vData
        end
    end

    if #fixedCategories > 0 then
        AddonCategory.savedVariables.listCategory = ZO_ShallowTableCopy(fixedCategories)
    end
end

local function loadSV()
    --Saved Variables
    AddonCategory.savedVariables = ZO_SavedVars:NewAccountWide("AddonCategoryVariables", 1, nil, AddonCategory.defaultSV)
    sV = AddonCategory.savedVariables

    --Check if SV table structure of categories is already properly updated for LibAddonMenuOrderListBox widget's listtype
    afterSettigs()
end


local function doesSVExistYet(svSubTableName)
    sV = sV or AddonCategory.savedVariables
    if sV == nil then return false end

    if type(svSubTableName) == "string" then
        local svSubTable = sV[svSubTableName]
        if svSubTable == nil then return false end
    end
    return true
end

local function closeGapsInCategoryList(removedIndex)
    if removedIndex == nil then return end
    local newOrderedTab = {}
    --An entry got deleted?
    --Loop the category list unsorted and create a new table with the old sorting, just
    --decrease the indices after the "removedIndex" by 1 (-1)
    for oldIdx, categoryData in pairs(sV.listCategory) do
        if oldIdx > removedIndex then
            local newIndex = oldIdx - 1
            categoryData.uniqueKey = newIndex
            categoryData.value = newIndex
            newOrderedTab[newIndex] = categoryData
        else
            newOrderedTab[oldIdx] = categoryData
        end
    end
    if not ZO_IsTableEmpty(newOrderedTab) then
        sV.listCategory = newOrderedTab
    end
end

local function fixUniqueKeyInCategoryList()
    -->UniqueKey could be duplicate now! So change the uniqueKey and value to their proper index
    for idx, categoryData in ipairs(sV.listCategory) do
        categoryData.uniqueKey = idx
        categoryData.value = idx

        categoryData.customSortOrder = nil
    end
end

local function checkIfBaseCategory(selectedCategory, silent)
    silent = silent or false
    for _, name in pairs(AddonCategory.baseCategories) do
        if name == selectedCategory then
            if not silent then
                d("[" .. MAJOR .."]You can't delete category |cFFFFFF" .. selectedCategory .. "|r.\nThis is a base category!")
            end
            return true
        end
    end
    return false
end

local function checkIfAddonsInCategory(selectedCategory, silent)
    silent = silent or false
    for _, value in pairs(AddonCategory.listAddons) do
        if sV[value] == selectedCategory then
            if not silent then
                d("[" .. MAJOR .."]You can't delete category as there are still addons present in this category |cFFFFFF" .. selectedCategory .. "|r.")
            end
            return true
        end
    end
    return false
end

function AddonCategory.GetNumAddonsInCategory(categoryName, isUnassignedAddons)
    isUnassignedAddons = isUnassignedAddons or false
    local counter = 0
    local addonsTabToCheck = (isUnassignedAddons == true and AddonCategory.listNonAssigned) or AddonCategory.listAddons

    for _, value in pairs(addonsTabToCheck) do
        if sV[value] == categoryName then
            counter = counter + 1
        end
    end
    return counter
end
local getNumAddonsInCategory = AddonCategory.GetNumAddonsInCategory

function AddonCategory.GetAddonCategories(returnIndexTable, returnIndexLookupTable)
    if doesSVExistYet("listCategory") == false then return end

    returnIndexTable = returnIndexTable or false
    returnIndexLookupTable = returnIndexLookupTable or false
    local tableToReturn = {}

    for idx, data in ipairs(sV.listCategory) do
        if returnIndexLookupTable == true then
            tableToReturn[data.text] = idx
        else
            if returnIndexTable == true then
                tableToReturn[idx] = idx
            else
                tableToReturn[idx] = data.text
            end
        end
    end
    return tableToReturn
end
local GetAddonCategories = AddonCategory.GetAddonCategories

function AddonCategory.IsCustomAddonCategory(addonType)
    local customCategories = GetAddonCategories(false)
    if ZO_IsTableEmpty(customCategories) then return false end

    for _, value in pairs(customCategories) do
        if value == addonType then
            return true
        end
    end
    return false
end
local IsCustomAddonCategory = AddonCategory.IsCustomAddonCategory

--Add an addon to the base categories of AddonCategory
-->Make sure to use ## OptionalDependsOn: AddonCategory>=010600 in your addon if you want to use this API function, else sV will be nil!
function AddonCategory.AssignAddonToCategory(addonName, categoryName)
    local svLoadedOnce = false
    for _, name in pairs(AddonCategory.baseCategories) do
        if name == categoryName then
            if not sV then
                if not svLoadedOnce then
                    loadSV()
                    svLoadedOnce = true
                else
                    --SavedVariables missing -> abort
                    return
                end
            end

            if sV ~= nil and sV[addonName] == nil then
                sV[addonName] = categoryName
            end
        end
    end
end

function AddonCategory.getIndexOfCategory(categoryName)
    return ac_indexCategories[categoryName]
end
local getIndexOfCategory = AddonCategory.getIndexOfCategory
AddonCategory.GetIndexOfCategory = getIndexOfCategory


local function checkForDuplicateCategory(newCategoryName, wasSVChecked)
    wasSVChecked = wasSVChecked or false
    if not wasSVChecked and doesSVExistYet("listCategory") == false then return end

    for _, l_data in ipairs(sV.listCategory) do
        if l_data.text == newCategoryName then
            d("["..MAJOR.."]Error - Duplicate category's name |cFFFFFF" .. newCategoryName .. "|r ...")
            newCategoryName = nil
            return true
        end
    end
    return false
end
AddonCategory.CheckForDuplicateCategory = checkForDuplicateCategory

function AddonCategory.DeleteCategoryCheckFunction(selectedIndex)
    if doesSVExistYet("listCategory") == false then return end
    if selectedIndex == nil then return false end
    local selectedCategory = sV.listCategory[selectedIndex]
    if selectedCategory ~= nil then
        if checkIfBaseCategory(selectedCategory, false) == true then return false end
        if checkIfAddonsInCategory(selectedCategory, false) == true then return false end
        return true
    end
    return false
end
--local DeleteCategoryCheckFunction = AddonCategory.DeleteCategoryCheckFunction

function AddonCategory.DeleteCategory(selectedIndex, doUnassign)
    if selectedIndex == nil then return false end

    local selectedCategory = sV.listCategory[selectedIndex]
    if selectedCategory ~= nil then
        if checkIfBaseCategory(selectedCategory, false) == true then return end
        local categoryName = selectedCategory.text
        if categoryName == nil or categoryName == "" then return false end

        doUnassign = doUnassign or false
        --Are there still addons assinged to the category? Unassign them now?
        if doUnassign == true and checkIfAddonsInCategory(selectedCategory, true) == true then
            --Unassign the addons in the category
            for _, value in pairs(AddonCategory.listAddons) do
                if sV[value] == categoryName then
                    sV[value] = nil
                end
            end
        end
        --Delete the category now -> Might create a gap in the table index and entry's uniqueKey now!
        sV.listCategory[selectedIndex] = nil
        ac_indexCategories[categoryName] = nil

        --Loop the category tables and close "gaps" and fix "uniqueKey" and "value"
        closeGapsInCategoryList(selectedIndex)
        fixUniqueKeyInCategoryList()

        updateAddonManagerDataIfShown()
        return true
    end
    return false
end
local DeleteCategory = AddonCategory.DeleteCategory

local function moveListCategory(selectedIndex, newPos, moveToFirstOrLast)
    local numEntries = #sV.listCategory
    for currentOrder, categoryData in ipairs(sV.listCategory) do
        if currentOrder == selectedIndex then
            categoryData.customSortOrder = newPos
        else
            if currentOrder < newPos then
                categoryData.customSortOrder = currentOrder
            elseif currentOrder == newPos then
                if moveToFirstOrLast ~= nil then
                    if moveToFirstOrLast == true then
                        --Move this old entry to the one after first
                        categoryData.customSortOrder = 2
                    elseif moveToFirstOrLast == false then
                        --Move this old entry to the one before last
                        categoryData.customSortOrder = numEntries - 1
                    end
                else
                    categoryData.customSortOrder = currentOrder + 1
                end
            elseif currentOrder > newPos then
                categoryData.customSortOrder = currentOrder + 1
            end
        end
    end
end

function AddonCategory.MoveAddonCategory(selectedIndex, categoryName, newPos)
    if doesSVExistYet("listCategory") == false then return end
    if selectedIndex == nil or categoryName == nil or newPos == nil or selectedIndex == newPos or newPos <= 0 or newPos > #sV.listCategory then return false end
    local selectedCategory = sV.listCategory[selectedIndex]
    if selectedCategory ~= nil then

--d("AddonCategory.MoveAddonCategory-selectedIndex: " ..tostring(selectedIndex) .. ", categoryName: " ..tostring(categoryName) .. "; newPos: " ..tostring(newPos))
        --Are there still addons assinged to the category? Unassign them now?
        --Unassign the addons in the category
        local l_categoryName = selectedCategory.text
        if l_categoryName == nil or l_categoryName ~= categoryName then return false end

        local numCategories = #sV.listCategory
        local moveToFirstOrLast = nil
        if newPos == 1 then
            moveToFirstOrLast = true
        elseif newPos == numCategories then
            moveToFirstOrLast = false
        end

        --Rebuild the listCategory table and move all entries so that the newPos will be properly added
        -->Add entry's .customSortOrder for the ordering below
        moveListCategory(selectedIndex, newPos, moveToFirstOrLast)
        --Sort the table properly by their uniqueKey now
        table.sort(sV.listCategory, listCategoryCustomOrderTableSortWrapper)
        --Update the uniqueKey and value to be the proper sorted Index now
        fixUniqueKeyInCategoryList()

        updateAddonManagerDataIfShown()
        return true
    end
    return false
end
local MoveAddonCategory = AddonCategory.MoveAddonCategory

local function addButton(myAnchorPoint, relativeTo, relativePoint, offsetX, offsetY, buttonData)
    if not buttonData or not buttonData.parentControl or not buttonData.buttonName or not buttonData.callback then return end
    local button
    --Does the button already exist?
    local btnName = buttonData.parentControl:GetName() .. MAJOR .. buttonData.buttonName
    button = WM:GetControlByName(btnName, "")
    if button == nil then
        --Create the button control at the parent
        button = WM:CreateControl(btnName, buttonData.parentControl, CT_BUTTON)
    end
    --Button was created?
    if button ~= nil then
        --Set the button's size
        button:SetDimensions(buttonData.width or 32, buttonData.height or 32)

        --SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY)
        button:SetAnchor(myAnchorPoint, relativeTo, relativePoint, offsetX, offsetY)

        --Texture
        local texture

        --Check if texture exists
        texture = WM:GetControlByName(btnName, "Texture")
        if texture == nil then
            --Create the texture for the button to hold the image
            texture = WM:CreateControl(btnName .. "Texture", button, CT_TEXTURE)
        end
        texture:SetAnchorFill()

        --Set the texture for normale state now
        texture:SetTexture(buttonData.normal)

        --Do we have seperate textures for the button states?
        button.upTexture 	  = buttonData.normal
        button.mouseOver 	  = buttonData.highlight
        button.clickedTexture = buttonData.pressed

        button.tooltipText	= buttonData.tooltip
        button.tooltipAlign = TOP
        button:SetHandler("OnMouseEnter", function(self)
            self:GetChild(1):SetTexture(self.mouseOver)
            ZO_Tooltips_ShowTextTooltip(self, self.tooltipAlign, self.tooltipText)
        end)
        button:SetHandler("OnMouseExit", function(self)
            self:GetChild(1):SetTexture(self.upTexture)
            ZO_Tooltips_HideTextTooltip()
        end)
        --Set the callback function of the button
        button:SetHandler("OnClicked", function(...)
            buttonData.callback(...)
        end)
        button:SetHandler("OnMouseUp", function(butn, mouseButton, upInside)
            if upInside then
                butn:GetChild(1):SetTexture(butn.upTexture)
            end
        end)
        button:SetHandler("OnMouseDown", function(butn)
            butn:GetChild(1):SetTexture(butn.clickedTexture)
        end)

        --Show the button and make it react on mouse input
        button:SetHidden(false)
        button:SetMouseEnabled(true)

        if type(buttonData.label) == "string" then
            button.label = button.label or WM:CreateControl(btnName .. "Label", button, CT_LABEL)
            local label = button.label
            if label ~= nil then
                label:ClearAnchors()
                label:SetAnchor(RIGHT, button, LEFT, -5, 0)
                label:SetFont(buttonData.font or "ZoFontGame")
                label:SetText(buttonData.label)
                label:SetDimensionConstraints(0, 0, 50, buttonData.height or 32)

                label:SetHandler("OnMouseEnter", function(labelCtrl) button:GetChild(1):SetTexture(button.mouseOver) ZO_Tooltips_ShowTextTooltip(button, button.tooltipAlign, button.tooltipText) end)
                label:SetHandler("OnMouseExit", function(labelCtrl) button:GetChild(1):SetTexture(button.upTexture) ZO_Tooltips_HideTextTooltip() end)
                label:SetHandler("OnMouseUp", function(labelCtrl, mouseButton, upInside) if upInside then button:GetChild(1):SetTexture(button.upTexture) end end)
                label:SetHandler("OnMouseDown", function(labelCtrl) button:GetChild(1):SetTexture(button.clickedTexture) buttonData.callback(button) end)

                label:SetMouseEnabled(true)
                label:SetHidden(false)
            end
        end

        --Return the button control
        return button
    end
end

local function CreateAddOnFilter(characterName)
    local uniqueName = g_uniqueNamesByCharacterName[characterName]
    if not uniqueName then
        uniqueName = GetUniqueNameForCharacter(characterName)
        g_uniqueNamesByCharacterName[characterName] = uniqueName
    end
    return uniqueName
end

local function getFirstLibraryAddonListIndex()
    local firstLibData = ADD_ON_MANAGER.addonTypes[true][1]
    --local oldLibraryCatIndex = libraryCatIndex
    libraryCatIndex = firstLibData and firstLibData.sortIndex or nil
end


local function ChangeAddonCategoryAddons(categoryIndex, categoryName, addonsInCategoryTab, doNotRemoveExisting)
    --d("[AddonCategory]ChangeAddonCategoryAddons")
    if categoryIndex == nil or categoryName == nil or categoryName == "" or type(addonsInCategoryTab) ~= "table" then return end
    if doesSVExistYet("listCategory") == false then return end

    local currentCategoryData = sV.listCategory[categoryIndex]
    if currentCategoryData == nil then return end

    local newAddonsPassedIn = not ZO_IsTableEmpty(addonsInCategoryTab)

    --First remove all addons from the category unless that is skipped
    if not doNotRemoveExisting then
        local addonsList = AddonCategory.listAddons
        for key, value in pairs(addonsList) do
            if sV[value] == categoryName then
                sV[value] = nil
            end
        end
    end

    --Then re-add the passed in selected addons (checked checkboxes at the submenu)
    if newAddonsPassedIn == true then
        for key, value in pairs(addonsInCategoryTab) do
            sV[value] = categoryName
        end
    end
    updateAddonManagerDataIfShown()
end
AddonCategory.ChangeAddonCategoryAddons = ChangeAddonCategoryAddons

local function AddAddonCategoryName(newCategoryName, newSortOrderIndex)
--d("[AC]AddAddonCategoryName - newCategoryName: " ..tostring(newCategoryName) .. "; newSortOrderIndex: " ..tostring(newSortOrderIndex))
    if doesSVExistYet("listCategory") == false then return end
    if newCategoryName == nil or newCategoryName == "" or checkForDuplicateCategory(newCategoryName, true) == true then return end

    local wasAdded = false

    local listCategory = sV.listCategory

    --First add the new category at the end
    local numCategoryEntries = #listCategory
    local newIndex = numCategoryEntries + 1
    local newData = {
        uniqueKey = newIndex,
        text = newCategoryName,
        value = newIndex,
    }

    --Then check if it should be at a chosen sortIndex. Move the new entry before it
    -->If any entry needs to be moved, do that now by sorting by uniqueKey
    if newSortOrderIndex ~= nil and newSortOrderIndex > 0 and newSortOrderIndex <= numCategoryEntries then
        --Does the index exist already?
        local oldEntryAtIndex = listCategory[newSortOrderIndex]
        if oldEntryAtIndex ~= nil then
            --Insert new entry at the chosen sortIndex
            newData.uniqueKey = newSortOrderIndex
            newData.value = newSortOrderIndex
            --Move all following existing entries to +1
            for i=newSortOrderIndex, numCategoryEntries, 1 do
                local listCategoryDataAtIndex = listCategory[i]
                local nextIndex = i+1
                listCategoryDataAtIndex.uniqueKey = nextIndex
                listCategoryDataAtIndex.value = nextIndex
            end
            --Resort the whole table sV.listCategory by uniqueKey
            table.sort(sV.listCategory, listCategoryUniqueKeyTableSort)
            wasAdded = true
        else
            sV.listCategory[newIndex] = newData
            wasAdded = true
        end
    else
        sV.listCategory[newIndex] = newData
        wasAdded = true
    end

    if wasAdded == true then
        --d(">added at new index: " ..tostring(newIndex))

        --Add the new category to the addon manager's addonTypes table
        --ADD_ON_MANAGER.addonTypes[newCategoryName] = ADD_ON_MANAGER.addonTypes[newCategoryName] or {} --> Should be done automatically in BuildMasterList -> Called from updateAddonManagerDataIfShown() below

        --d(">>added new category: " .. tostring(newCategoryName) .. " / Updating AddOns list now")
        updateAddonManagerDataIfShown()
    end
    return wasAdded
end

local function ChangeAddonCategoryName(categoryToChangeIndex, categoryName, newCategoryName)
    if doesSVExistYet("listCategory") == false then return end
    if categoryToChangeIndex == nil or categoryName == nil or categoryName == "" or newCategoryName == nil or newCategoryName == "" or checkForDuplicateCategory(newCategoryName, true) == true then return end

    local currentCategoryData = sV.listCategory[categoryToChangeIndex]
    if currentCategoryData ~= nil then
        local l_key = currentCategoryData.uniqueKey
        local newData = {
            uniqueKey = l_key,
            text = newCategoryName,
            value = l_key,
        }
        sV.listCategory[categoryToChangeIndex] = newData


        local addonsList = AddonCategory.listAddons
        for _, value in pairs(addonsList) do
            if sV[value] == categoryName then
                sV[value] = newCategoryName
            end
        end

        updateAddonManagerDataIfShown()

        return true
    end
    return false
end
AddonCategory.ChangeAddonCategoryName = ChangeAddonCategoryName

local function scrollAddonsScrollBarToIndex(index, animateInstantly)
    if ADD_ON_MANAGER ~= nil and ADD_ON_MANAGER.list ~= nil and ADD_ON_MANAGER.list.scrollbar ~= nil then
        --ADDON_MANAGER_OBJECT.list.scrollbar:SetValue((ADDON_MANAGER_OBJECT.list.uniformControlHeight-0.9)*index)
        --ZO_Scroll_ScrollAbsolute(self, value)
        local onScrollCompleteCallback = function() end
        animateInstantly = animateInstantly or false
        --Jump up to addons?
        if index <= 0 then
            index = 1
        end
        ZO_ScrollList_ScrollDataIntoView(ADD_ON_MANAGER.list, index, onScrollCompleteCallback, animateInstantly)
    end
end

function AddonCategory.JumpToAddonCategory(addonCategoryName, categoryIndexInAddonList)
    if categoryIndexInAddonList == nil then return end
    if categoryIndexInAddonList ~= -1 and AddonSelectorGlobal and AddonSelectorGlobal.ScrollAddonsScrollBarToIndex then
        AddonSelectorGlobal.ScrollAddonsScrollBarToIndex(categoryIndexInAddonList)
    else
        scrollAddonsScrollBarToIndex(categoryIndexInAddonList, false)
    end
end
local JumpToAddonCategory = AddonCategory.JumpToAddonCategory

local function showAddAddonCategoryNameDialog()
    --Show dialog where one enters the category name
    if ESO_Dialogs["ADDONCATEGORY_ADD_NEW_CATEGORY_NAME_DIALOG"] == nil then
        ESO_Dialogs["ADDONCATEGORY_ADD_NEW_CATEGORY_NAME_DIALOG"] =
        {
            title =
            {
                text = "Add new category",
            },
            mainText =
            {
                text = "Enter new category name",
            },
            editBox =
            {
                --matchingString = GetString(SI_DESTROY_ITEM_CONFIRMATION)
            },
            noChoiceCallback =  function()

            end,
            buttons =
            {
                {
                    requiresTextInput = true,
                    text =      "Save",
                    callback =  function(dialog)
                        local newCategoryName = ZO_Dialogs_GetEditBoxText(dialog)
                        --Category name
                        if newCategoryName ~= nil and newCategoryName ~= "" then
                            --todo Maybe also show a sort order slider here?
                            local newSortOrderIndex
                            return AddAddonCategoryName(newCategoryName, newSortOrderIndex)
                        end
                    end,
                },
                {
                    text = SI_DIALOG_CANCEL,
                    callback = function(dialog)
                    end,
                }
            }
        }
    end
    ZO_Dialogs_ShowPlatformDialog("ADDONCATEGORY_ADD_NEW_CATEGORY_NAME_DIALOG", { })
end


local function showChangeAddonCategoryNameDialog(categoryToChangeIndex, categoryName)
    --Show dialog where one enters the category name
    if ESO_Dialogs["ADDONCATEGORY_CHANGE_CATEGORY_NAME_DIALOG"] == nil then
        ESO_Dialogs["ADDONCATEGORY_CHANGE_CATEGORY_NAME_DIALOG"] =
        {
            title =
            {
                text = "Change category \'"..categoryName.."\'",
            },
            mainText =
            {
                text = "Enter new category name",
            },
            editBox =
            {
                --matchingString = GetString(SI_DESTROY_ITEM_CONFIRMATION)
            },
            noChoiceCallback =  function()

            end,
            buttons =
            {
                {
                    requiresTextInput = true,
                    text =      "Save",
                    callback =  function(dialog)
                        local newCategoryName = ZO_Dialogs_GetEditBoxText(dialog)
                        if newCategoryName ~= nil and newCategoryName ~= "" then
--d(">new category name: " .. tostring(newCategoryName))
                            return ChangeAddonCategoryName(dialog.data.categoryToChangeIndex, dialog.data.categoryName, newCategoryName)
                        end
                    end,
                },
                {
                    text = SI_DIALOG_CANCEL,
                    callback = function(dialog)
                    end,
                }
            }
        }
    end
--d(">categoryToChangeIndex: " .. tostring(categoryToChangeIndex) .. ", categoryName: " .. tostring(categoryName))
    ZO_Dialogs_ShowPlatformDialog("ADDONCATEGORY_CHANGE_CATEGORY_NAME_DIALOG", { categoryToChangeIndex = categoryToChangeIndex, categoryName = categoryName })
end

local function showDeleteAddonCategoryDialog(categoryToChangeIndex, categoryName)
    if ESO_Dialogs["ADDONCATEGORY_DELETE_CATEGORY_DIALOG"] == nil then
        ESO_Dialogs["ADDONCATEGORY_DELETE_CATEGORY_DIALOG"] =
        {
            title =
            {
                text = "Delete category \'"..categoryName.."\'",
            },
            mainText =
            {
                text = "Assigned AddOns will be unassigned.\nDo you want to delete the category now?",
            },
            noChoiceCallback =  function()

            end,
            buttons =
            {
                {
                    --requiresTextInput = true,
                    text =      "Delete",
                    callback =  function(dialog)
                        DeleteCategory(dialog.data.categoryToChangeIndex, true)
                    end,
                },
                {
                    text = SI_DIALOG_CANCEL,
                    callback = function(dialog)
                    end,
                }
            }
        }
    end
--d(">categoryToChangeIndex: " .. tostring(categoryToChangeIndex) .. ", categoryName: " .. tostring(categoryName))
    ZO_Dialogs_ShowPlatformDialog("ADDONCATEGORY_DELETE_CATEGORY_DIALOG", { categoryToChangeIndex = categoryToChangeIndex, categoryName = categoryName })
end

local submenuSaveButtons = {}
local function updateLSMAssignAddOnsSubmenuSaveButtonEnabledState(p_comboBox, newEnabledState)
    if p_comboBox == nil then return end
    --local dropdownBaseObject = p_comboBox.openingControl and p_comboBox.openingControl or p_comboBox --> that#s the parent submenu!
    local dropdownBaseObject = p_comboBox --that's the current nested submenu of the parent submenu (Addon list, of addons which are in the category)

    --Change enabled state of the save buttons in submenus
    if ZO_IsTableEmpty(submenuSaveButtons[p_comboBox]) then return end
    for _, submenuPacksSaveButtonData in pairs(submenuSaveButtons[p_comboBox]) do
        submenuPacksSaveButtonData.enabled = newEnabledState

        dropdownBaseObject.m_dropdownObject:Refresh(submenuPacksSaveButtonData)
    end
end

local function resetCategoryAddonsSubmenuSaveButtons(p_comboBox)
    submenuSaveButtons[p_comboBox] = {}
end

--Get the save button in the category's addon submenu
local function getCategoryAddonsSubmenuSaveButtons(p_comboBox, p_item, entriesFound)
    resetCategoryAddonsSubmenuSaveButtons(p_comboBox)

    --Loop the normal entries and get the save buttons
    for k, v in ipairs(entriesFound) do
        local name = v.label or v.name
    --d(">name of entry: " .. tostring(name).. ", isSaveButton: " .. tostring(v.isSaveButton))
        if v.isSaveButton then
            submenuSaveButtons[p_comboBox][v] = v
        end
    end
end

local function onCheckboxInAddonCategoryListClicked(p_comboBox, rowControl, itemName, checked)
    --LSM 2.21 compatibility
    if p_comboBox == nil then
        p_comboBox = rowControl.m_owner
    end
    updateLSMAssignAddOnsSubmenuSaveButtonEnabledState(p_comboBox, true)
end


local function saveUpdatedCategoryAddonsCallbackFuncSubmenu(p_comboBox, p_item, entriesFound, categoryIndex, categoryName, doNotRemoveExisting) --... will be filled with customParams
--d("[AddonCategory]saveUpdatedCategoryAddonsCallbackFuncSubmenu - doNotRemoveExisting: " ..tostring(doNotRemoveExisting))
    --Loop the checkboxes and get their current state
    doNotRemoveExisting = doNotRemoveExisting or false

    local addonsInCategoryChanged = 0
    local addonsInCategoryTab     = {}

    for _, v in ipairs(entriesFound) do
        local name = v.name
        local isCheckedNow = v.checked

        if isCheckedNow == true then
            table.insert(addonsInCategoryTab, name)
        end
        addonsInCategoryChanged = addonsInCategoryChanged + 1
    end
    if addonsInCategoryChanged > 0 then
        ChangeAddonCategoryAddons(categoryIndex, categoryName, addonsInCategoryTab, doNotRemoveExisting)
    end
end

local cptToolbar = 0
local sectionsHeader = {}
local sectionsEnable = {}

local function CreateButtonData(l_toolBar, l_categoryName, tooltipString, nb, icon, functionCallback, identifier, isContextMenuButton)
    isContextMenuButton = isContextMenuButton or false
    local categoryIsLibrary = l_categoryName == libraryText and true or false
    return {
        activeTabText = l_categoryName,
        categoryName = l_categoryName,
        CustomTooltipFunction = function(tooltip)
            SetTooltipText(tooltip, tooltipString .. (((identifier == "collapse" or identifier == "edit") and " category ") or " all " .. (categoryIsLibrary and "libraries" or "addons") .. " of ") .. l_categoryName)
        end,
        tooltip = "tooltip",
        alwaysShowTooltip = true,
        descriptor = nb,
        normal = "esoui/art/buttons/" .. icon .. "_up.dds",
        pressed = "esoui/art/buttons/" .. icon .. "_up.dds",
        highlight = "esoui/art/buttons/" .. icon .. "_over.dds",
        disabled = "esoui/art/buttons/" .. icon .. "_down.dds",
        callback = function(tabData)
            functionCallback(tabData, l_toolBar, l_categoryName)

            ZO_MenuBar_ClearSelection(l_toolBar)
            if not isContextMenuButton then
                l_toolBar:SetHidden(true)
                ADD_ON_MANAGER:RefreshData()
                PlaySound(SOUNDS.DEFAULT_CLICK)
            end
        end
    }
end

local function callbackEnableDisable(tabData, doEnable, l_categoryName)
    doEnable = doEnable or false
    if sectionsEnable[l_categoryName] == nil then
        sectionsEnable[l_categoryName] = false
    end
    local textTrueFalse = "false"
    if sectionsEnable[l_categoryName] == true then
        textTrueFalse = "true"
    end

    if l_categoryName == libraryText then
        for key, value in pairs(AddonCategory.listLibraries) do
            AddOnManager:SetAddOnEnabled(key, doEnable)
        end
    else
        for key, value in pairs(AddonCategory.listAddons) do
            if sV[value] == l_categoryName then
                AddOnManager:SetAddOnEnabled(key, doEnable)
            end
        end
    end
    sectionsEnable[l_categoryName] = not sectionsEnable[l_categoryName]
    ADD_ON_MANAGER.isDirty = true
    --ADD_ON_MANAGER:RefreshMultiButton()
end
local function callbackEnable(tabData, l_toolBar, l_categoryName)
    callbackEnableDisable(tabData, true, l_categoryName)
end
local function callbackDisable(tabData, l_toolBar, l_categoryName)
    callbackEnableDisable(tabData, false, l_categoryName)
end

local function callbackShowHide(tabData, l_toolBar, l_categoryName)
    if sV.sectionsOpen[l_categoryName] == nil then
        sV.sectionsOpen[l_categoryName] = true
    end
    sV.sectionsOpen[l_categoryName] = not sV.sectionsOpen[l_categoryName]

    local isCollapsed = sV.sectionsOpen[l_categoryName]
    ZO_MenuBar_SetDescriptorEnabled(l_toolBar, "setEnabled", not isCollapsed)
    ZO_MenuBar_SetDescriptorEnabled(l_toolBar, "setDisabled", not isCollapsed)
end

local function getAddonCategoryMoreOptionsSettingsMenuContents()
    AddCustomScrollableMenuHeader("Settings")
    AddCustomScrollableMenuEntry("Open settings menu", function()
        AddonCategory.OpenLAMSettingsMenu()
    end)
end

local function getAddonCategoryMoreOptionsMenuContents()
    AddCustomScrollableMenuHeader("Categories")
    AddCustomScrollableMenuEntry("Add category", function()
        showAddAddonCategoryNameDialog()
    end)

    getFirstLibraryAddonListIndex()

    local categoryJumpEntries = {}
    local indexCategories = ac_indexCategories
    if not ZO_IsTableEmpty(indexCategories) then
        local indexLookupTableForCategory = GetAddonCategories(nil, true)

        for addonCategoryName, categoryIndexInAddonList in pairs(indexCategories) do
            if addonCategoryName ~= libraryText then
                local categoryOrderNo = indexLookupTableForCategory[addonCategoryName]
                local addonCategoryAndOrderName = addonCategoryName
                if categoryOrderNo ~= nil and categoryOrderNo > 0 then
                    addonCategoryAndOrderName = addonCategoryAndOrderName .. " (#" .. tostring(categoryOrderNo) .. ")"
                end
                categoryJumpEntries[#categoryJumpEntries + 1] = {
                    label = addonCategoryAndOrderName,
                    name = addonCategoryName,
                    categoryIndexInAddonList = categoryIndexInAddonList,
                    categoryOrderNo = categoryOrderNo,
                    callback = function(comboBox, itemName, item)
                        JumpToAddonCategory(addonCategoryName, categoryIndexInAddonList)
                    end,
                }
            end
        end
        table.sort(categoryJumpEntries, defaultLSMSubmenuEntriesSortFunc)

        if not ZO_IsTableEmpty(categoryJumpEntries) then
            table.insert(categoryJumpEntries, 1, {
                label = "-AddOns-",
                name =  "-AddOns-",
                categoryIndexInAddonList = -1,
                callback = function(comboBox, itemName, item)
                    JumpToAddonCategory("-AddOns-", -1)
                end,
            })

            if libraryCatIndex ~= nil then
                table.insert(categoryJumpEntries, 2, {
                    label = "-".. libraryText .. "-",
                    name =  "-".. libraryText .. "-",
                    categoryIndexInAddonList = libraryCatIndex,
                    callback = function(comboBox, itemName, item)
                        JumpToAddonCategory("-".. libraryText .. "-", libraryCatIndex)
                    end,
                })
            end
            AddCustomScrollableSubMenuEntry("Jump to category", categoryJumpEntries)
        end
    end
end

local function showAddonCategoryMoreOptionsMenu(parentCtrl)
    --d("showAddonCategoryMoreOptionsMenu")
    ClearCustomScrollableMenu()

    getAddonCategoryMoreOptionsMenuContents()
    getAddonCategoryMoreOptionsSettingsMenuContents()

    ShowCustomScrollableMenu(nil, { })
end

local function callbackEdit(tabData, l_toolBar, l_categoryName)
    ClearCustomScrollableMenu()

    local categoriesTab = GetAddonCategories(false)
    local categoryToChangeIndex = ZO_IndexOfElementInNumericallyIndexedTable(categoriesTab, l_categoryName)
    if l_categoryName == nil or l_categoryName == "" or categoryToChangeIndex == nil then return end
    local categoryIsLibrary = l_categoryName == libraryText and true or false

    local listCategory = sV.listCategory

    getAddonCategoryMoreOptionsMenuContents()

    if categoryIsLibrary == false then
        local catIndex = categoryToChangeIndex
        local catName = l_categoryName
        AddCustomScrollableMenuEntry("Edit category name", function()
            showChangeAddonCategoryNameDialog(catIndex, catName)
        end)

        if checkIfBaseCategory(l_categoryName, true) == false then
            AddCustomScrollableMenuEntry("Delete category", function()
                showDeleteAddonCategoryDialog(catIndex, catName)
            end)
        end

        local addonCategoriesOrderSubmenu = {}
        for pos, listcategoryData in ipairs(listCategory) do
            local positionText = "Set as position #" .. tostring(pos) .. " (current: \'" .. tostring(listcategoryData.text) .. "\')"
            addonCategoriesOrderSubmenu[#addonCategoriesOrderSubmenu + 1] = {
                name = positionText,
                label = positionText,
                callback = function(comboBox, itemName, item)
                    MoveAddonCategory(catIndex, catName, pos)
                end,
                --entryType = LSM_ENTRY_TYPE_NORMAL,
            }
        end
        if not ZO_IsTableEmpty(addonCategoriesOrderSubmenu) then
            AddCustomScrollableSubMenuEntry("Order addon category", addonCategoriesOrderSubmenu)
        end
    end

    AddCustomScrollableMenuHeader("Assigned addons")
    local assignedAddonsSubmenu = {}
    local addonsList = AddonCategory.listAddons
    for key, addonName in pairs(addonsList) do
        if sV[addonName] == l_categoryName then
            assignedAddonsSubmenu[#assignedAddonsSubmenu + 1] = {
                name = addonName,
                label = addonName,
                callback = function(comboBox, itemName, item, checked)
                    RunCustomScrollableMenuItemsCallback(comboBox, item, getCategoryAddonsSubmenuSaveButtons, { LSM_ENTRY_TYPE_BUTTON }, false)
                    onCheckboxInAddonCategoryListClicked(comboBox, item, itemName, checked)
                end,
                entryType = LSM_ENTRY_TYPE_CHECKBOX,
                checked = true,
            }
        end
    end
    if #assignedAddonsSubmenu > 0 then
        local catIndex = categoryToChangeIndex
        local catName = l_categoryName
        table.sort(assignedAddonsSubmenu, defaultLSMSubmenuEntriesSortFunc)
        table.insert(assignedAddonsSubmenu, 1, {
            name = "Update addons in category",
            label = "Update addons in category",
            callback = function(comboBox, itemName, item, selectionChanged, oldItem)
                --d("Apply changes to category \'" .. tostring(categoryName) .."\'")
                RunCustomScrollableMenuItemsCallback(comboBox, item, saveUpdatedCategoryAddonsCallbackFuncSubmenu, { LSM_ENTRY_TYPE_CHECKBOX }, false, catIndex, catName)
                resetCategoryAddonsSubmenuSaveButtons(comboBox)
                ClearCustomScrollableMenu()
            end,
            entryType = LSM_ENTRY_TYPE_BUTTON,
            enabled = false,--will get enabled by the checkbox's callback
            isSaveButton = true,
            buttonTemplate = 'ZO_DefaultButton',
            doNotFilter = function() return true end,
        })

        AddCustomScrollableSubMenuEntry("Edit assigned addons", assignedAddonsSubmenu)
    end

    AddCustomScrollableMenuHeader("Unassigned addons")
    local unAssignedAddonsSubmenu = {}
    local unAssignedAddonsList = AddonCategory.listNonAssigned
    for key, addonName in pairs(unAssignedAddonsList) do
        unAssignedAddonsSubmenu[#unAssignedAddonsSubmenu + 1] = {
            name = addonName,
            label = addonName,
            callback = function(comboBox, itemName, item, checked)
                RunCustomScrollableMenuItemsCallback(comboBox, item, getCategoryAddonsSubmenuSaveButtons, { LSM_ENTRY_TYPE_BUTTON }, false)
                onCheckboxInAddonCategoryListClicked(comboBox, item, itemName, checked)
            end,
            entryType = LSM_ENTRY_TYPE_CHECKBOX,
            checked = false,
        }
    end
    if #unAssignedAddonsSubmenu > 0 then
        local catIndex = categoryToChangeIndex
        local catName = l_categoryName
        table.sort(unAssignedAddonsSubmenu, defaultLSMSubmenuEntriesSortFunc)
        table.insert(unAssignedAddonsSubmenu, 1, {
            name = "Update addons in category",
            label = "Update addons in category",
            callback = function(comboBox, itemName, item, selectionChanged, oldItem)
                --d("Apply changes to category \'" .. tostring(categoryName) .."\'")
                RunCustomScrollableMenuItemsCallback(comboBox, item, saveUpdatedCategoryAddonsCallbackFuncSubmenu, { LSM_ENTRY_TYPE_CHECKBOX }, false, catIndex, catName, true)
                resetCategoryAddonsSubmenuSaveButtons(comboBox)
                ClearCustomScrollableMenu()
            end,
            entryType = LSM_ENTRY_TYPE_BUTTON,
            enabled = false,--will get enabled by the checkbox's callback
            isSaveButton = true,
            buttonTemplate = 'ZO_DefaultButton',
            doNotFilter = function() return true end,
        })

        AddCustomScrollableSubMenuEntry("Edit unassigned addons", unAssignedAddonsSubmenu)
    end

    getAddonCategoryMoreOptionsSettingsMenuContents()

    ShowCustomScrollableMenu(nil, defaultCustomScrollableMenuOptions)
end



------------------------------------------------------------------------------------------------------------------------
-- AddOnManager - ScrollList replacement functions
------------------------------------------------------------------------------------------------------------------------
local _AddAddonTypeSection = ADD_ON_MANAGER.AddAddonTypeSection
local _SetupSectionHeaderRow = ADD_ON_MANAGER.SetupSectionHeaderRow
------------------------------------------------------------------------------------------------------------------------

local function BuildMasterList(addOnManagerObject)
--d("[AddonCategory]ADDON_MANAGER:BuildMasterlist()")
    addOnManagerObject.listAddons             = {}
    addOnManagerObject.listLibraries          = {}
    addOnManagerObject.listNonAssigned        = {}


    --Add all addon types:
    --true = libraries
    --false = addons
    --other = categories
    addOnManagerObject.addonTypes             = {}
    addOnManagerObject.addonTypes[IS_LIBRARY] = {}
    addOnManagerObject.addonTypes[IS_ADDON]   = {}
    --Add the categories as new addonType subtale entry
    for key, value in ipairs(GetAddonCategories(false)) do
        addOnManagerObject.addonTypes[value] = {}
    end

    if addOnManagerObject.selectedCharacterEntry and not addOnManagerObject.selectedCharacterEntry.allCharacters then
        addOnManagerObject.isAllFilterSelected = false
        AddOnManager:SetAddOnFilter(CreateAddOnFilter(addOnManagerObject.selectedCharacterEntry.name))
    else
        addOnManagerObject.isAllFilterSelected = true
        AddOnManager:RemoveAddOnFilter()
    end


    for i = 1, AddOnManager:GetNumAddOns() do
        local name, title, author, description, enabled, state, isOutOfDate, isLibrary = AddOnManager:GetAddOnInfo(i)
        --Normal addons
        if isLibrary ~= IS_LIBRARY then
            addOnManagerObject.listAddons[i] = name
        else
            --Libraries
            addOnManagerObject.listLibraries[i] = name
        end

        local entryData = {
            index = i,
            addOnFileName = name,
            addOnName = title,
            strippedAddOnName = StripText(title),
            addOnDescription = description,
            addOnEnabled = enabled,
            addOnState = state,
            isOutOfDate = isOutOfDate,
            isLibrary = isLibrary,
            isCustomCategory = false,
            dependsOn = {}
        }

        --Check if addon was assigned to a category -> in SavedVariables
        local savedVarsAddonsCategory = sV[name]
        if savedVarsAddonsCategory ~= nil and addOnManagerObject.addonTypes[savedVarsAddonsCategory] ~= nil then
            entryData.isCustomCategory = true
            entryData.customCategory = savedVarsAddonsCategory
        elseif isLibrary ~= IS_LIBRARY then
            --"Not yet assigned to any category" addons
            table.insert(addOnManagerObject.listNonAssigned, name)
        end

        --Author
        if author ~= "" then
            local strippedAuthor = StripText(author)
            entryData.addOnAuthorByLine = zo_strformat(SI_ADD_ON_AUTHOR_LINE, author)
            entryData.strippedAddOnAuthorByLine = zo_strformat(SI_ADD_ON_AUTHOR_LINE, strippedAuthor)
        else
            entryData.addOnAuthorByLine = ""
            entryData.strippedAddOnAuthorByLine = ""
        end

        --Dependencies
        local dependencyText = ""
        for j = 1, AddOnManager:GetAddOnNumDependencies(i) do
            local dependencyName, dependencyExists, dependencyActive, dependencyMinVersion, dependencyVersion = AddOnManager:GetAddOnDependencyInfo(i, j)
            local dependencyTooLowVersion = dependencyVersion < dependencyMinVersion

            local dependencyInfoLine = dependencyName
            if not addOnManagerObject.isAllFilterSelected and (not dependencyActive or not dependencyExists or dependencyTooLowVersion) then
                entryData.hasDependencyError = true
                if not dependencyExists then
                    dependencyInfoLine = zo_strformat(SI_ADDON_MANAGER_DEPENDENCY_MISSING, dependencyName)
                elseif not dependencyActive then
                    dependencyInfoLine = zo_strformat(SI_ADDON_MANAGER_DEPENDENCY_DISABLED, dependencyName)
                elseif dependencyTooLowVersion then
                    dependencyInfoLine = zo_strformat(SI_ADDON_MANAGER_DEPENDENCY_TOO_LOW_VERSION, dependencyName)
                end
                dependencyInfoLine = ZO_ERROR_COLOR:Colorize(dependencyInfoLine)
            end
            dependencyText = string.format("%s\n    %s  %s", dependencyText, GetString(SI_BULLET), dependencyInfoLine)
        end
        entryData.addOnDependencyText = dependencyText

        entryData.expandable = (description ~= "") or (dependencyText ~= "")

        --Add the addons to the categories now
        if entryData.isCustomCategory == true then
            if savedVarsAddonsCategory ~= nil then
                if not addOnManagerObject.addonTypes[savedVarsAddonsCategory] then
                    addOnManagerObject.addonTypes[savedVarsAddonsCategory] = {}
                end
                table.insert(addOnManagerObject.addonTypes[savedVarsAddonsCategory], entryData)
            end
        else
            table.insert(addOnManagerObject.addonTypes[isLibrary], entryData)
        end
    end
end

--Called from TO_AddOnManager:SortScrollList()
local function AddAddonTypeSection(addOnManagerObject, isLibraryBoolOrCategoryName, sectionTitleText)
--d("[AC]AddAddonTypeSection")

    --Sort the addons in the list:
    --1 Non assigned addons
    --2 Assigned addons with the order of the custom categories
    --3 Libraries

    --Check for custom categories to show them below nonAssigned addons
    local customCategory = IsCustomAddonCategory(isLibraryBoolOrCategoryName)
    local customCategoryOrLibrary = isLibraryBoolOrCategoryName == true and true or customCategory

    --A custom category was found?
    if customCategoryOrLibrary == true or isLibraryBoolOrCategoryName == true then
        local addonEntries = addOnManagerObject.addonTypes[isLibraryBoolOrCategoryName]
        table.sort(addonEntries, addOnManagerObject.sortCallback)

        local titleText = isLibraryBoolOrCategoryName
        --Libraries headline/category?
        if isLibraryBoolOrCategoryName == true then
            titleText = sectionTitleText --.. " (#" .. tostring(#AddonCategory.listLibraries) .. ")"
            libraryText = sectionTitleText
        --else
            --titleText = titleText .. " (#" .. tostring(getNumAddonsInCategory(isLibraryBoolOrCategoryName, false)) .. ")"
        end

        local sectionsOpenOfTitle = sV.sectionsOpen[sectionTitleText]

        local scrollData = ZO_ScrollList_GetDataList(addOnManagerObject.list)
        scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(SECTION_HEADER_DATA, { isLibrary = isLibraryBoolOrCategoryName, text = titleText, isCustomCategory = customCategoryOrLibrary })
        for _, entryData in ipairs(addonEntries) do
            if sectionsOpenOfTitle == nil or sectionsOpenOfTitle == true then
                if entryData.expandable and expandedAddons[entryData.index] then
                    entryData.expanded = true

                    local useHeight, typeId = addOnManagerObject:SetupTypeId(entryData.addOnDescription, entryData.addOnDependencyText)

                    entryData.height = useHeight
                    scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(typeId, entryData)
                else
                    entryData.height = ZO_ADDON_ROW_HEIGHT
                    scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(ADDON_DATA, entryData)
                end
            end
        end
    else
        --For normal addons call the vanilla AddAddonTypeSection ZOs code
        _AddAddonTypeSection(addOnManagerObject, isLibraryBoolOrCategoryName, sectionTitleText)  --.. " (#" .. tostring(getNumAddonsInCategory(sectionTitleText, true)) .. ")")
    end
end

local function SetupSectionHeaderRow(self, control, data)

    local isLibraryEntry = data.isLibrary
    local customCategory = isLibraryEntry == true and true or IsCustomAddonCategory(isLibraryEntry)

    if customCategory == true or isLibraryEntry == true then
        local categoryName = data.text
        --local categoryIsLibrary = categoryName == libraryText and true or false

        --local previousText = control.textControl:GetText()
        control.textControl:SetText(data.text)
        control.checkboxControl:SetHidden(true)

        --Create new ZO_Menu toolbar with buttons to collapse/expand, show context menu to change the catgeory and it's addons or add a new category
        cptToolbar = cptToolbar + 1
        control.toolBar = CreateControlFromVirtual("$(parent)ToolBar" .. cptToolbar, control, "ZO_MenuBarTemplate")
        local toolBar = control.toolBar
        toolBar:ClearAnchors()
        toolBar:SetAnchor(BOTTOMRIGHT, control.textControl, BOTTOMRIGHT, 132, 4) -- increase offsetX by ~32 for each new toolbar button!
        ZO_MenuBar_OnInitialized(toolBar)
        local barData = {
            buttonPadding = -4,
            normalSize = 28,
            downSize = 28,
            animationDuration = DEFAULT_SCENE_TRANSITION_TIME,
            buttonTemplate = "ZO_MenuBarTooltipButton"
        }
        ZO_MenuBar_SetData(toolBar, barData)
        ZO_MenuBar_SetClickSound(toolBar, "DEFAULT_CLICK")

        local iconCollapseExpand   = "large_uparrow"
        local stringCollapseExpand = "Collapse"
        if sV.sectionsOpen[categoryName] == false then
            iconCollapseExpand   = "large_downarrow"
            stringCollapseExpand = "Expand"
        end
        local iconEnable = "accept"
        local stringEnable = "Enable"
        local iconDisable = "edit_cancel"
        local stringDisable = "Disable"

        local iconEdit = "edit"
        local stringEdit = "Edit"

        ZO_MenuBar_AddButton(toolBar, CreateButtonData(toolBar, categoryName, stringCollapseExpand, "collapseToggle", iconCollapseExpand, callbackShowHide, "collapse", false))
        ZO_MenuBar_AddButton(toolBar, CreateButtonData(toolBar, categoryName, stringEnable, "setEnabled", iconEnable, callbackEnable, "enable", false))
        ZO_MenuBar_AddButton(toolBar, CreateButtonData(toolBar, categoryName, stringDisable, "setDisabled", iconDisable, callbackDisable, "disable", false))
        ZO_MenuBar_AddButton(toolBar, CreateButtonData(toolBar, categoryName, stringEdit, "editCategory", iconEdit, callbackEdit, "edit", true))

        toolBar:SetHidden(false)
        local rowNb = control:GetName():gsub("ZO_AddOnsList2Row", "")
        if sectionsHeader[rowNb] ~= nil then
            sectionsHeader[rowNb]:SetHidden(true)
        end
        sectionsHeader[rowNb] = toolBar

        ZO_MenuBar_ClearSelection(toolBar)

    else
        --Normal AddOns - Hide the toolbar at the reused pool controls and then use vanilla code to setup the section header
        if control.toolBar then
            control.toolBar:SetHidden(true)
        end
        _SetupSectionHeaderRow(self, control, data)
    end
end

local function SortScrollList(addOnManagerObject)
--d("[AC]SortScrollList")
    libraryCatIndex = nil

    addOnManagerObject:ResetDataTypes()
    local scrollData = ZO_ScrollList_GetDataList(addOnManagerObject.list)
    ZO_ClearNumericallyIndexedTable(scrollData)

    --First add addons header
    addOnManagerObject:AddAddonTypeSection(IS_ADDON, GetString(SI_WINDOW_TITLE_ADDON_MANAGER))

    --Then add the custom categories header
    for listCategoryKey, listCategoryData in ipairs(sV.listCategory) do
        for key, value in pairs(AddonCategory.listAddons) do
            local listCategoryNameAtIndex = listCategoryData.text
            --Even add the category to the output list if it is empty so one can use it's toolbar context menu toa ssign addons
            --if sV[value] == listCategoryNameAtIndex then
                addOnManagerObject:AddAddonTypeSection(listCategoryNameAtIndex, listCategoryNameAtIndex)
                break
            --end
        end
    end

    --And finally add the libraries header
    addOnManagerObject:AddAddonTypeSection(IS_LIBRARY, GetString(SI_ADDON_MANAGER_SECTION_LIBRARIES))

    --Update the indices of the entries in the lists
    local newScrollData = ZO_ScrollList_GetDataList(addOnManagerObject.list)
    for key, value in pairs(newScrollData) do
        local isLibrary = (value.data and value.data.isLibrary) or nil
        for listCategoryKey, listCategoryData in ipairs(sV.listCategory) do
            local listCategoryNameAtIndex = listCategoryData.text
            if listCategoryNameAtIndex == isLibrary then
                ac_indexCategories[listCategoryNameAtIndex] = key
            end
        end
        if IS_LIBRARY == isLibrary then
            ac_indexCategories[GetString(SI_ADDON_MANAGER_SECTION_LIBRARIES)] = key
        end
    end

    getFirstLibraryAddonListIndex()
end

local function OnExpandButtonClicked(self, row)
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    local data = ZO_ScrollList_GetData(row)

    if expandedAddons[data.index] then
        expandedAddons[data.index] = false

        data.expanded = false
        data.height = ZO_ADDON_ROW_HEIGHT
        scrollData[data.sortIndex] = ZO_ScrollList_CreateDataEntry(ADDON_DATA, data)
    else
        expandedAddons[data.index] = true

        local useHeight, typeId = self:SetupTypeId(data.addOnDescription, data.addOnDependencyText)

        data.expanded = true
        data.height = useHeight
        scrollData[data.sortIndex] = ZO_ScrollList_CreateDataEntry(typeId, data)
    end

    self:CommitScrollList()
end
------------------------------------------------------------------------------------------------------------------------
ADD_ON_MANAGER.BuildMasterList = BuildMasterList
ADD_ON_MANAGER.AddAddonTypeSection = AddAddonTypeSection
ADD_ON_MANAGER.SetupSectionHeaderRow = SetupSectionHeaderRow
ADD_ON_MANAGER.SortScrollList = SortScrollList
ADD_ON_MANAGER.OnExpandButtonClicked = OnExpandButtonClicked
------------------------------------------------------------------------------------------------------------------------



local function alterAddonManagerControl()
    addonsListCtrl = addonsListCtrl or ZO_AddOnsList

    local addonCategorySettingsButtonData = {
        label           = "AC",
        font            = "ZoFontHeader2",
        buttonName      = "AddonListSettings",
        parentControl   = addonsListCtrl,
        tooltip         = "["..MAJOR .. "]Show more options",
        callback        = function(...)
            showAddonCategoryMoreOptionsMenu(...)
        end,
        width           = 20,
        height          = 20,
        normal          = "/esoui/art/buttons/dropbox_arrow_normal.dds",
        pressed         = "/esoui/art/buttons/dropbox_arrow_mousedown.dds",
        highlight       = "/esoui/art/buttons/dropbox_arrow_mouseover.dds",
        disabled        = "/esoui/art/buttons/dropbox_arrow_disabled.dds",
    }
    addButton(TOPRIGHT, addonsListCtrl, TOPRIGHT, -10, -40, addonCategorySettingsButtonData)
end


----------
-- INIT --
----------
function AddonCategory.Initialize()
	EM:UnregisterForEvent(MAJOR .. "_EVENT_ADD_ON_LOADED", EVENT_ADD_ON_LOADED)

    loadSV()

    --Add buttons to addon manager control
    alterAddonManagerControl()

	--LAM settings menu
    ADD_ON_MANAGER.BuildMasterList(AddonCategory)
	AddonCategory.CreateSettingsWindow()
end

function AddonCategory.OnAddOnLoaded(event, addonName)
	if addonName ~= MAJOR then return end
    AddonCategory.Initialize()
end

EM:RegisterForEvent(MAJOR .. "_EVENT_ADD_ON_LOADED", EVENT_ADD_ON_LOADED, AddonCategory.OnAddOnLoaded)