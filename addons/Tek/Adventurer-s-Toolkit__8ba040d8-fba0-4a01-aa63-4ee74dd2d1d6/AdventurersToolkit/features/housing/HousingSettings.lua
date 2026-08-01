-- ============================================
-- HOUSING SETTINGS (Custom Categories)
-- ============================================
local string_format = string.format

NWT.HousingSettings = {
    isOpen = false,
    sceneInitialized = false,
    selectedCategoryIndex = 1,
    selectedHouseIndex = 1,
    categoryScrollOffset = 0,
    houseScrollOffset = 0,
    maxVisibleCategories = 10,
    maxVisibleHouses = 14,
    focusPanel = "categories",  -- "categories" or "houses"
    allHouses = {},
}

local ATK_HiddenHousingSettingsScreen = ZO_Gamepad_ParametricList_Screen:Subclass()
function ATK_HiddenHousingSettingsScreen:New(control) return ZO_Gamepad_ParametricList_Screen.New(self, control) end
function ATK_HiddenHousingSettingsScreen:Initialize(control) ZO_Gamepad_ParametricList_Screen.Initialize(self, control, false, true, HOUSING_SETTINGS_SCENE) end
function ATK_HiddenHousingSettingsScreen:PerformUpdate() end

function ATK_HiddenHousingSettingsScreen:InitializeKeybindStripDescriptors()
    self.keybindStripDescriptor = {
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, 
          name = function()
            local hs = NWT.HousingSettings
            if hs.focusPanel == "categories" then
                return "Add Category"
            else
                local house = hs.allHouses[hs.selectedHouseIndex]
                local cats = NWT.savedVars.housingCategories or {}
                local cat = cats[hs.selectedCategoryIndex]
                if house and cat then
                    local assigned = cat.houses and cat.houses[house.houseId]
                    return assigned and "Remove" or "Add"
                end
                return "Toggle"
            end
          end,
          keybind = "UI_SHORTCUT_PRIMARY",
          callback = function()
            local hs = NWT.HousingSettings
            if hs.focusPanel == "categories" then
                NWT.HousingSettingsAddCategory()
            else
                NWT.HousingSettingsToggleHouse()
            end
          end },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, name = "Rename", keybind = "UI_SHORTCUT_TERTIARY",
          callback = function() NWT.HousingSettingsRenameCategory() end,
          visible = function() return NWT.HousingSettings.focusPanel == "categories" end },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, name = "Delete", keybind = "UI_SHORTCUT_QUATERNARY",
          callback = function() NWT.HousingSettingsDeleteCategory() end,
          visible = function() return NWT.HousingSettings.focusPanel == "categories" end },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, 
          name = "< Categories",
          keybind = "UI_SHORTCUT_LEFT_SHOULDER",
          callback = function()
            local hs = NWT.HousingSettings
            if hs.focusPanel == "houses" then
                hs.focusPanel = "categories"
                NWT.SyncHiddenHousingSettingsList()
                NWT.UpdateHousingSettingsUI()
                PlaySound(SOUNDS.POSITIVE_CLICK)
                KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
            end
          end,
          visible = function() return NWT.HousingSettings.focusPanel == "houses" end },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, 
          name = "Assign Houses >",
          keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
          callback = function()
            local hs = NWT.HousingSettings
            if hs.focusPanel == "categories" then
                hs.focusPanel = "houses"
                NWT.SyncHiddenHousingSettingsList()
                NWT.UpdateHousingSettingsUI()
                PlaySound(SOUNDS.POSITIVE_CLICK)
                KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
            end
          end,
          visible = function() return NWT.HousingSettings.focusPanel == "categories" end },
    }
    ZO_Gamepad_AddBackNavigationKeybindDescriptors(self.keybindStripDescriptor, GAME_NAVIGATION_TYPE_BUTTON, 
        function() NWT.CloseHousingSettings() end)
end

function NWT.InitHousingSettingsScene()
    if NWT.HousingSettings.sceneInitialized then return end
    local ui = ATK_HousingSettings_UI
    if not ui then return end
    local hc = WINDOW_MANAGER:CreateControlFromVirtual("ATK_HiddenHousingSettingsList", GuiRoot, "ATK_HouseList_Screen")
    hc:SetHidden(true) hc:SetAlpha(0)
    HOUSING_SETTINGS_SCENE = ZO_Scene:New("housingSettingsScene", SCENE_MANAGER)
    HOUSING_SETTINGS_SCENE:AddFragment(ZO_HUDFadeSceneFragment:New(ui))
    HOUSING_SETTINGS_SCENE:AddFragment(ZO_SimpleSceneFragment:New(hc))
    HOUSING_SETTINGS_SCENE:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    HOUSING_SETTINGS_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
    NWT.HiddenHousingSettingsScreen = ATK_HiddenHousingSettingsScreen:New(hc)
    NWT.HiddenHousingSettingsList = NWT.HiddenHousingSettingsScreen:GetMainList()
    NWT.HiddenHousingSettingsList:AddDataTemplate("ZO_GamepadItemEntryTemplate", function(c, d) local l = c:GetNamedChild("Label") if l then l:SetText(d.name or "") end end, ZO_GamepadMenuEntryTemplateParametricListFunction)
    
    NWT.HiddenHousingSettingsList:SetOnSelectedDataChangedCallback(function(list, sd)
        if sd and sd.index then
            local hs = NWT.HousingSettings
            if hs.focusPanel == "categories" then
                hs.selectedCategoryIndex = sd.index
                -- Update category scroll offset
                if hs.selectedCategoryIndex <= hs.categoryScrollOffset then
                    hs.categoryScrollOffset = hs.selectedCategoryIndex - 1
                elseif hs.selectedCategoryIndex > hs.categoryScrollOffset + hs.maxVisibleCategories then
                    hs.categoryScrollOffset = hs.selectedCategoryIndex - hs.maxVisibleCategories
                end
            else
                hs.selectedHouseIndex = sd.index
                -- Update house scroll offset
                if hs.selectedHouseIndex <= hs.houseScrollOffset then
                    hs.houseScrollOffset = hs.selectedHouseIndex - 1
                elseif hs.selectedHouseIndex > hs.houseScrollOffset + hs.maxVisibleHouses then
                    hs.houseScrollOffset = hs.selectedHouseIndex - hs.maxVisibleHouses
                end
            end
            NWT.UpdateHousingSettingsUI()
        end
    end)
    
    HOUSING_SETTINGS_SCENE:RegisterCallback("StateChange", function(os, ns)
        if ns == SCENE_SHOWING then
            NWT.HousingSettings.isOpen = true
            NWT.HousingSettings.focusPanel = "categories"
            NWT.BuildHousingSettingsData()
            NWT.SyncHiddenHousingSettingsList()
            NWT.UpdateHousingSettingsUI()
            if KEYBIND_STRIP and NWT.HiddenHousingSettingsScreen then
                KEYBIND_STRIP:AddKeybindButtonGroup(NWT.HiddenHousingSettingsScreen.keybindStripDescriptor)
            end
        elseif ns == SCENE_HIDING then
            if KEYBIND_STRIP and NWT.HiddenHousingSettingsScreen then
                KEYBIND_STRIP:RemoveKeybindButtonGroup(NWT.HiddenHousingSettingsScreen.keybindStripDescriptor)
            end
        elseif ns == SCENE_HIDDEN then
            NWT.HousingSettings.isOpen = false
        end
    end)
    NWT.HousingSettings.sceneInitialized = true
end

function NWT.OpenHousingSettings()
    if NWT.HousingSettings.isOpen then return end
    if not HOUSING_SETTINGS_SCENE then NWT.InitHousingSettingsScene() end
    SCENE_MANAGER:Push("housingSettingsScene")
end

function NWT.CloseHousingSettings()
    if HOUSING_SETTINGS_SCENE then SCENE_MANAGER:Hide("housingSettingsScene") end
end

function NWT.BuildHousingSettingsData()
    local hs = NWT.HousingSettings
    local stats = NWT.ScanAllHouses()
    hs.allHouses = {}
    for id, data in pairs(stats) do table.insert(hs.allHouses, data) end
    table.sort(hs.allHouses, function(a, b) return a.name < b.name end)
    
    -- Initialize categories if needed
    if not NWT.savedVars.housingCategories then
        NWT.savedVars.housingCategories = {
            { name = "Favorites", color = "FFD700", houses = {} },
        }
    end
end

function NWT.SyncHiddenHousingSettingsList()
    if not NWT.HiddenHousingSettingsList then return end
    local hs = NWT.HousingSettings
    NWT.HiddenHousingSettingsList:Clear()
    
    if hs.focusPanel == "categories" then
        local cats = NWT.savedVars.housingCategories or {}
        for i, cat in ipairs(cats) do
            local ed = ZO_GamepadEntryData:New(cat.name)
            ed.index = i
            NWT.HiddenHousingSettingsList:AddEntry("ZO_GamepadItemEntryTemplate", ed)
        end
        -- Add "New Category" option
        local newEd = ZO_GamepadEntryData:New("+ New Category")
        newEd.index = #cats + 1
        newEd.isNew = true
        NWT.HiddenHousingSettingsList:AddEntry("ZO_GamepadItemEntryTemplate", newEd)
    else
        for i, house in ipairs(hs.allHouses) do
            local ed = ZO_GamepadEntryData:New(house.name)
            ed.index = i
            ed.houseId = house.houseId
            NWT.HiddenHousingSettingsList:AddEntry("ZO_GamepadItemEntryTemplate", ed)
        end
    end
    NWT.HiddenHousingSettingsList:Commit()
end

function NWT.UpdateHousingSettingsUI()
    local ui = ATK_HousingSettings_UI
    if not ui then return end
    local hs = NWT.HousingSettings
    local cats = NWT.savedVars.housingCategories or {}
    
    -- Update left column (categories)
    local leftCol = ui:GetNamedChild("LeftCol")
    if leftCol then
        local card = leftCol:GetNamedChild("CategoriesCard")
        local list = card and card:GetNamedChild("List")
        local bg = card and card:GetNamedChild("BG")
        local glow = card and card:GetNamedChild("FocusGlow")
        
        if hs.focusPanel == "categories" then
            if bg then bg:SetEdgeColor(1, 0, 1, 1) end
            if glow then glow:SetHidden(false) end
        else
            if bg then bg:SetEdgeColor(0.3, 0.3, 0.3, 1) end
            if glow then glow:SetHidden(true) end
        end
        
        if list then
            for i = 1, hs.maxVisibleCategories do
                local label = list:GetNamedChild("Cat" .. i)
                if label then
                    local cat = cats[i]
                    if cat then
                        local prefix = (i == hs.selectedCategoryIndex and hs.focusPanel == "categories") and "|cFFD700> |r" or ""
                        local houseCount = 0
                        if cat.houses then for _ in pairs(cat.houses) do houseCount = houseCount + 1 end end
                        label:SetText(string_format("%s|c%s%s|r |c888888(%d)|r", prefix, cat.color or "FFFFFF", cat.name, houseCount))
                    elseif i == #cats + 1 then
                        local prefix = (i == hs.selectedCategoryIndex and hs.focusPanel == "categories") and "|cFFD700> |r" or ""
                        label:SetText(prefix .. "|c00FF00+ Add New Category|r")
                    else
                        label:SetText("")
                    end
                end
            end
        end
        
        local instr = card and card:GetNamedChild("Instructions")
        if instr then instr:SetText("|c888888[A] Add  [X] Rename  [Y] Delete|r") end
    end
    
    -- Update center column (houses in selected category)
    local centerCol = ui:GetNamedChild("CenterCol")
    if centerCol then
        local card = centerCol:GetNamedChild("HousesCard")
        local list = card and card:GetNamedChild("List")
        local bg = card and card:GetNamedChild("BG")
        local glow = card and card:GetNamedChild("FocusGlow")
        local header = card and card:GetNamedChild("Header")
        
        if hs.focusPanel == "houses" then
            if bg then bg:SetEdgeColor(1, 0, 1, 1) end
            if glow then glow:SetHidden(false) end
        else
            if bg then bg:SetEdgeColor(0.3, 0.3, 0.3, 1) end
            if glow then glow:SetHidden(true) end
        end
        
        local selectedCat = cats[hs.selectedCategoryIndex]
        if header then
            header:SetText(selectedCat and ("|cFFFFAAHOUSES: " .. selectedCat.name .. "|r") or "|cFFFFAAHOUSES|r")
        end
        
        if list then
            local offset = hs.houseScrollOffset or 0
            for i = 1, hs.maxVisibleHouses do
                local label = list:GetNamedChild("House" .. i)
                if label then
                    local dataIndex = i + offset
                    local house = hs.allHouses[dataIndex]
                    if house then
                        local prefix = (dataIndex == hs.selectedHouseIndex and hs.focusPanel == "houses") and "|cFFD700> |r" or ""
                        local inCat = selectedCat and selectedCat.houses and selectedCat.houses[house.houseId]
                        local check = inCat and "|c00FF00[X]|r " or "|c444444[ ]|r "
                        label:SetText(prefix .. check .. "|cFFFFFF" .. house.name .. "|r")
                    else
                        label:SetText("")
                    end
                end
            end
        end
    end
    
    -- Update info panel
    local rightCol = ui:GetNamedChild("RightCol")
    if rightCol then
        local infoCard = rightCol:GetNamedChild("InfoCard")
        local info1 = infoCard and infoCard:GetNamedChild("Info1")
        if info1 then
            local selectedCat = cats[hs.selectedCategoryIndex]
            if selectedCat then
                local houseCount = 0
                if selectedCat.houses then for _ in pairs(selectedCat.houses) do houseCount = houseCount + 1 end end
                info1:SetText(string_format("|cFFFFFFCategory:|r %s\n|cFFFFFFHouses:|r %d\n\n|c888888Press [RB] to assign houses to this category.\n\nCategories appear in the Housing filter menu.|r", selectedCat.name, houseCount))
            else
                info1:SetText("|c888888Select a category or create a new one.\n\nCategories let you organize your houses into groups like:\n- Halloween\n- Main Homes\n- Crafting\n- Storage|r")
            end
        end
    end
    
    if KEYBIND_STRIP and NWT.HiddenHousingSettingsScreen then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenHousingSettingsScreen.keybindStripDescriptor)
    end
end

function NWT.HousingSettingsAddCategory()
    local hs = NWT.HousingSettings
    if not hs.editBox then
        local eb = WINDOW_MANAGER:CreateControl("HousingSettingsEditBox", ATK_HousingSettings_UI, CT_EDITBOX)
        eb:SetDimensions(400, 50) eb:SetAnchor(CENTER, ATK_HousingSettings_UI, CENTER, 0, 0)
        eb:SetFont("ZoFontGamepad34") eb:SetMaxInputChars(30) eb:SetVirtualKeyboardType(VIRTUAL_KEYBOARD_TYPE_DEFAULT)
        eb:SetHandler("OnEnter", function(self)
            local txt = self:GetText()
            if txt and txt ~= "" then
                if not NWT.savedVars.housingCategories then NWT.savedVars.housingCategories = {} end
                table.insert(NWT.savedVars.housingCategories, { name = txt, color = "FF00FF", houses = {} })
NWT.Debug("|cFF00FF[Housing]|r Created category: " .. txt)
                PlaySound(SOUNDS.POSITIVE_CLICK)
                NWT.SyncHiddenHousingSettingsList()
                NWT.UpdateHousingSettingsUI()
                NWT.RebuildHousingFilterModes()
            end
            self:SetHidden(true) self:LoseFocus() self:SetText("")
        end)
        eb:SetHandler("OnEscape", function(self) self:SetHidden(true) self:LoseFocus() self:SetText("") end)
        hs.editBox = eb
    end
    hs.editBox:SetHidden(false) hs.editBox:TakeFocus() hs.editBox:SetText("")
end

function NWT.HousingSettingsRenameCategory()
    local hs = NWT.HousingSettings
    local cats = NWT.savedVars.housingCategories or {}
    local cat = cats[hs.selectedCategoryIndex]
    if not cat then return end
    
    if not hs.renameBox then
        local eb = WINDOW_MANAGER:CreateControl("HousingSettingsRenameBox", ATK_HousingSettings_UI, CT_EDITBOX)
        eb:SetDimensions(400, 50) eb:SetAnchor(CENTER, ATK_HousingSettings_UI, CENTER, 0, 0)
        eb:SetFont("ZoFontGamepad34") eb:SetMaxInputChars(30) eb:SetVirtualKeyboardType(VIRTUAL_KEYBOARD_TYPE_DEFAULT)
        eb:SetHandler("OnEnter", function(self)
            local txt = self:GetText()
            if txt and txt ~= "" then
                local oldName = cat.name
                cat.name = txt
NWT.Debug("|cFF00FF[Housing]|r Renamed \"" .. oldName .. "\" to \"" .. txt .. "\"")
                PlaySound(SOUNDS.POSITIVE_CLICK)
                NWT.UpdateHousingSettingsUI()
                NWT.RebuildHousingFilterModes()
            end
            self:SetHidden(true) self:LoseFocus() self:SetText("")
        end)
        eb:SetHandler("OnEscape", function(self) self:SetHidden(true) self:LoseFocus() self:SetText("") end)
        hs.renameBox = eb
    end
    hs.renameBox:SetHidden(false) hs.renameBox:TakeFocus() hs.renameBox:SetText(cat.name)
end

function NWT.HousingSettingsDeleteCategory()
    local hs = NWT.HousingSettings
    local cats = NWT.savedVars.housingCategories or {}
    local cat = cats[hs.selectedCategoryIndex]
    if not cat then return end
    
    local name = cat.name
    table.remove(cats, hs.selectedCategoryIndex)
    if hs.selectedCategoryIndex > #cats then hs.selectedCategoryIndex = math.max(1, #cats) end
NWT.Debug("|cFF00FF[Housing]|r Deleted category: " .. name)
    PlaySound(SOUNDS.NEGATIVE_CLICK)
    NWT.SyncHiddenHousingSettingsList()
    NWT.UpdateHousingSettingsUI()
    NWT.RebuildHousingFilterModes()
end

function NWT.HousingSettingsToggleHouse()
    local hs = NWT.HousingSettings
    local cats = NWT.savedVars.housingCategories or {}
    local cat = cats[hs.selectedCategoryIndex]
    local house = hs.allHouses[hs.selectedHouseIndex]
    if not cat or not house then return end
    
    if not cat.houses then cat.houses = {} end
    
    if cat.houses[house.houseId] then
        cat.houses[house.houseId] = nil
NWT.Debug("|cFF00FF[Housing]|r Removed " .. house.name .. " from " .. cat.name)
    else
        cat.houses[house.houseId] = true
NWT.Debug("|cFF00FF[Housing]|r Added " .. house.name .. " to " .. cat.name)
    end
    
    PlaySound(SOUNDS.POSITIVE_CLICK)
    NWT.UpdateHousingSettingsUI()
    if KEYBIND_STRIP and NWT.HiddenHousingSettingsScreen then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenHousingSettingsScreen.keybindStripDescriptor)
    end
end

function NWT.RebuildHousingFilterModes()
    local hd = NWT.HousingDashboard
    hd.filterModes = {"All Houses", "Favorites"}
    local cats = NWT.savedVars.housingCategories or {}
    for _, cat in ipairs(cats) do
        table.insert(hd.filterModes, cat.name)
    end
end
