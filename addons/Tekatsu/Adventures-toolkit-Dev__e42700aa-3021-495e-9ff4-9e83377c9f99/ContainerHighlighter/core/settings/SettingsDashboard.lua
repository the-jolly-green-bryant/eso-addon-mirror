-- ============================================
-- SETTINGS DASHBOARD (Gamepad)
-- ============================================
NWT.SettingsDashboard = { isOpen = false, sceneInitialized = false, selectedRow = 1, scrollOffset = 0 }
local MAX_VISIBLE_SETTINGS = 12

local SETTINGS_FEATURES = {
    { key = "netWorth", label = "Net Worth", desc = "Track your total wealth across gold, inventory, bank, craft bag, and furniture." },
    { key = "goldLedger", label = "Gold Ledger", desc = "Automatically track all gold income and expenses with daily reset." },
    { key = "guildSalesTracker", label = "Guild Sales Tracker", desc = "Analyze your guild store sales, leaderboards, and buyer data." },
    { key = "bookkeeper", label = "Guild Bookkeeper", desc = "Track member dues, deposits, and payment status for guild management." },
    { key = "guildRaffle", label = "Guild Raffle", desc = "Run raffles with ticket packs, rank bonuses, and random winner selection." },
    { key = "housingDashboard", label = "Housing Dashboard", desc = "View all houses, furniture counts, item limits, and travel instantly." },
    { key = "furnitureFinder", label = "Furniture Finder", desc = "Search for any furniture item across all your houses." },
    { key = "planBrowser", label = "Plan Browser", desc = "Browse all furnishing plans and track which you know or need." },
    { key = "planner", label = "Housing Planner", desc = "Organize furniture into project folders for decoration planning." },
    { key = "pvpDashboard", label = "PVP Tracker", desc = "Track Alliance Points, kills, deaths, and Battlegrounds stats." },
    { key = "itemFinder", label = "Item Finder", desc = "Search your inventory across all characters." },
    { key = "lootLog", label = "Loot Log", desc = "Track farming sessions with gold per hour and loot values." },
    { key = "fishingTracker", label = "Fishing Tracker", desc = "Track Master Angler achievement progress zone by zone." },
    { key = "lootRadar", label = "Loot Radar", desc = "Floating 3D pins show nearby lootable containers." },
}

local function UpdateSettingsRowStatus(rowNum)
    local ui = ATK_Settings_UI or ATK_Settings_UI
    if not ui then return end
    local leftCol = ui:GetNamedChild("LeftCol")
    local featuresCard = leftCol and leftCol:GetNamedChild("FeaturesCard")
    local list = featuresCard and featuresCard:GetNamedChild("List")
    if not list then return end
    local row = list:GetNamedChild("Row" .. rowNum)
    if not row then return end
    local sd = NWT.SettingsDashboard
    local featureIndex = rowNum + sd.scrollOffset
    local feature = SETTINGS_FEATURES[featureIndex]
    if not feature then
        row:SetHidden(true)
        return
    end
    row:SetHidden(false)
    local sv = NWT.savedVars
    if not sv.features then sv.features = {} end
    local enabled = sv.features[feature.key] ~= false
    local isSel = (featureIndex == sd.selectedRow)
    local prefix = isSel and "► " or "  "
    local status = enabled and "|c00FF00ON|r" or "|cFF0000OFF|r"
    row:SetText(prefix .. "|cFFFFFF" .. feature.label .. "|r  " .. status)
end

local function UpdateSettingsRowStatus_OLD(rowNum)
    local ui = ATK_Settings_UI
    if not ui then return end
    local panel = ui:GetNamedChild("Panel")
    if not panel then return end
    local row = panel:GetNamedChild("Row" .. rowNum)
    if not row then return end
    local statusLabel = row:GetNamedChild("Status")
    if not statusLabel then return end
    local feature = SETTINGS_FEATURES[rowNum]
    if not feature then return end
    local sv = NWT.savedVars
    if not sv.features then sv.features = {} end
    local enabled = sv.features[feature.key] ~= false
    statusLabel:SetText(enabled and "|c00FF00ON|r" or "|cFF0000OFF|r")
end

local function UpdateFeatureInfoPanel()
    local ui = ATK_Settings_UI
    if not ui then return end
    local rightCol = ui:GetNamedChild("RightCol")
    local infoCard = rightCol and rightCol:GetNamedChild("InfoCard")
    if not infoCard then return end
    local featureName = infoCard:GetNamedChild("FeatureName")
    local description = infoCard:GetNamedChild("Description")
    local feature = SETTINGS_FEATURES[NWT.SettingsDashboard.selectedRow]
    if feature then
        if featureName then featureName:SetText(feature.label) end
        if description then description:SetText(feature.desc or "") end
    end
end

local function UpdateAllSettingsRows()
    for i = 1, MAX_VISIBLE_SETTINGS do UpdateSettingsRowStatus(i) end
    -- Hide extra rows
    local ui = ATK_Settings_UI
    if ui then
        local leftCol = ui:GetNamedChild("LeftCol")
        local featuresCard = leftCol and leftCol:GetNamedChild("FeaturesCard")
        local list = featuresCard and featuresCard:GetNamedChild("List")
        if list then
            for i = MAX_VISIBLE_SETTINGS + 1, 14 do
                local row = list:GetNamedChild("Row" .. i)
                if row then row:SetHidden(true) end
            end
        end
    end
    UpdateFeatureInfoPanel()
end

-- Exact Y positions matching XML row anchors
local ROW_POSITIONS = { 20, 65, 110, 155, 200, 245, 290, 335, 380, 425 }

local function UpdateSettingsSelection()
    local ui = ATK_Settings_UI or ATK_Settings_UI
    if not ui then return end
    local leftCol = ui:GetNamedChild("LeftCol")
    local featuresCard = leftCol and leftCol:GetNamedChild("FeaturesCard")
    local list = featuresCard and featuresCard:GetNamedChild("List")
    if not list then return end
    local selFrame = list:GetNamedChild("SelectionFrame")
    local sd = NWT.SettingsDashboard
    local row = sd.selectedRow
    if row < 1 then row = 1 end
    if row > #SETTINGS_FEATURES then row = #SETTINGS_FEATURES end
    sd.selectedRow = row
    -- Calculate visible row index
    local visibleRow = row - sd.scrollOffset
    local rowCtrl = list:GetNamedChild("Row" .. visibleRow)
    if selFrame and rowCtrl and not rowCtrl:IsHidden() then
        selFrame:ClearAnchors()
        selFrame:SetAnchor(TOPLEFT, rowCtrl, TOPLEFT, -5, -2)
        selFrame:SetHidden(false)
    end
    UpdateAllSettingsRows()
end

local function ToggleSelectedFeature()
    local feature = SETTINGS_FEATURES[NWT.SettingsDashboard.selectedRow]
    if not feature then return end
    local sv = NWT.savedVars
    if not sv.features then sv.features = {} end
    local wasEnabled = sv.features[feature.key] ~= false
    sv.features[feature.key] = not wasEnabled
    PlaySound(SOUNDS.POSITIVE_CLICK)
    UpdateAllSettingsRows()
end

local ATK_HiddenSettingsListScreen = ZO_Gamepad_ParametricList_Screen:Subclass()
function ATK_HiddenSettingsListScreen:New(control) return ZO_Gamepad_ParametricList_Screen.New(self, control) end
function ATK_HiddenSettingsListScreen:Initialize(control) ZO_Gamepad_ParametricList_Screen.Initialize(self, control, false, true, SETTINGS_DASHBOARD_SCENE) end
function ATK_HiddenSettingsListScreen:PerformUpdate() end
function ATK_HiddenSettingsListScreen:InitializeKeybindStripDescriptors()
    self.keybindStripDescriptor = {
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, name = "Toggle", keybind = "UI_SHORTCUT_PRIMARY", callback = function() ToggleSelectedFeature() end },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, name = "Reload UI", keybind = "UI_SHORTCUT_SECONDARY", callback = function() ReloadUI() end },
    }
    ZO_Gamepad_AddBackNavigationKeybindDescriptors(self.keybindStripDescriptor, GAME_NAVIGATION_TYPE_BUTTON, function() NWT.CloseSettingsDashboard() end)
end

function NWT.SyncHiddenSettingsList()
    if not NWT.HiddenSettingsList then return end
    NWT.HiddenSettingsList:Clear()
    for i, feature in ipairs(SETTINGS_FEATURES) do
        local entryData = ZO_GamepadEntryData:New(feature.label)
        entryData.index, entryData.feature = i, feature
        NWT.HiddenSettingsList:AddEntry("ZO_GamepadItemEntryTemplate", entryData)
    end
    NWT.HiddenSettingsList:Commit()
    if NWT.SettingsDashboard.selectedRow and NWT.SettingsDashboard.selectedRow <= #SETTINGS_FEATURES then
        NWT.HiddenSettingsList:SetSelectedIndexWithoutAnimation(NWT.SettingsDashboard.selectedRow)
    end
end

function NWT.InitSettingsDashboardScene()
    if NWT.SettingsDashboard.sceneInitialized then return end
    local ui = ATK_Settings_UI or ATK_Settings_UI
    if not ui then return end
    local hiddenControl = WINDOW_MANAGER:CreateControlFromVirtual("ATK_HiddenSettingsList", GuiRoot, "ATK_HouseList_Screen")
    hiddenControl:SetHidden(true)
    hiddenControl:SetAlpha(0)
    SETTINGS_DASHBOARD_SCENE = ZO_Scene:New("settingsDashboardScene", SCENE_MANAGER)
    local settingsFragment = ZO_HUDFadeSceneFragment:New(ui)
    local hiddenFragment = ZO_SimpleSceneFragment:New(hiddenControl)
    SETTINGS_DASHBOARD_SCENE:AddFragment(settingsFragment)
    SETTINGS_DASHBOARD_SCENE:AddFragment(hiddenFragment)
    SETTINGS_DASHBOARD_SCENE:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    SETTINGS_DASHBOARD_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
    NWT.HiddenSettingsListScreen = ATK_HiddenSettingsListScreen:New(hiddenControl)
    NWT.HiddenSettingsList = NWT.HiddenSettingsListScreen:GetMainList()
    local function SetupHiddenEntry(control, data, selected) local label = control:GetNamedChild("Label") if label then label:SetText(data.name or "") end end
    NWT.HiddenSettingsList:AddDataTemplate("ZO_GamepadItemEntryTemplate", SetupHiddenEntry, ZO_GamepadMenuEntryTemplateParametricListFunction)
    NWT.HiddenSettingsList:SetOnSelectedDataChangedCallback(function(list, selectedData)
        if selectedData and selectedData.index then
            local idx = selectedData.index
            if idx < 1 then idx = 1 end
            if idx > #SETTINGS_FEATURES then idx = #SETTINGS_FEATURES end
            local sd = NWT.SettingsDashboard
            sd.selectedRow = idx
            -- Adjust scroll to keep selection visible
            if idx <= sd.scrollOffset then
                sd.scrollOffset = idx - 1
            elseif idx > sd.scrollOffset + MAX_VISIBLE_SETTINGS then
                sd.scrollOffset = idx - MAX_VISIBLE_SETTINGS
            end
            UpdateSettingsSelection()
        end
    end)
    SETTINGS_DASHBOARD_SCENE:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_SHOWING then
            NWT.SettingsDashboard.isOpen = true
            NWT.SettingsDashboard.selectedRow = 1
            NWT.SettingsDashboard.scrollOffset = 0
            UpdateAllSettingsRows()
            UpdateSettingsSelection()
            NWT.SyncHiddenSettingsList()
        elseif newState == SCENE_HIDDEN then
            NWT.SettingsDashboard.isOpen = false
        end
    end)
    NWT.SettingsDashboard.sceneInitialized = true
end

function NWT.OpenSettingsDashboard()
    if NWT.SettingsDashboard.isOpen then return end
    if not SETTINGS_DASHBOARD_SCENE then NWT.InitSettingsDashboardScene() end
    SCENE_MANAGER:Push("settingsDashboardScene")
end

function NWT.CloseSettingsDashboard()
    if SETTINGS_DASHBOARD_SCENE then SCENE_MANAGER:Hide("settingsDashboardScene") end
end
