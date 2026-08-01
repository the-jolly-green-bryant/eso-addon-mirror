-- DungeonStrats - browse dungeon and trial boss strategies in-game.
-- Slash: /dungeonstrats or /ds

DungeonStrats = DungeonStrats or {}
local ds = DungeonStrats
local ADDON_NAME = "DungeonStrats"

local currentCategory  -- "dungeons" or "trials"
local currentDungeon   -- name string
local currentBossIndex -- integer

-- ---------------------------------------------------------------------------
-- Helpers

local function getSortedNames(dataTable)
    local list = {}
    for name, info in pairs(dataTable) do
        list[#list + 1] = { name = name, order = info.order }
    end
    table.sort(list, function(a, b) return a.order < b.order end)
    return list
end

-- ---------------------------------------------------------------------------
-- Strategy text display (mirrors DungeonGear detail-window pattern)

local function showStrategy(text)
    local label = ds._textLabel
    if not label then return end
    local scroll = DungeonStratsWindowScroll
    local scrollWidth = (scroll and scroll:GetWidth()) or 640
    local textWidth = scrollWidth - 40
    label:SetDimensions(textWidth, 0)
    label:SetText(text or "")
    local scrollChild = scroll and scroll:GetNamedChild("ScrollChild")
    if scrollChild and label.GetTextHeight then
        local h = label:GetTextHeight() + 16
        if h < 100 then h = 100 end
        scrollChild:SetDimensions(textWidth + 8, h)
    end
    if scroll and ZO_Scroll_OnExtentsChanged then
        ZO_Scroll_OnExtentsChanged(scroll)
    end
end

-- ---------------------------------------------------------------------------
-- Cascading dropdown logic

function ds.OnBossSelected(index)
    currentBossIndex = index
    local data = ds.Data[currentCategory]
    local dungeon = data and data[currentDungeon]
    local boss = dungeon and dungeon.bosses and dungeon.bosses[index]
    if boss then
        local combo = ZO_ComboBox_ObjectFromContainer(DungeonStratsWindowBossCombo)
        if combo then combo:SetSelectedItemText(boss.name) end
        showStrategy(boss.strategy)
    end
end

function ds.OnDungeonSelected(dungeonName)
    currentDungeon = dungeonName
    -- Update dungeon combo display
    local dCombo = ZO_ComboBox_ObjectFromContainer(DungeonStratsWindowDungeonCombo)
    if dCombo then dCombo:SetSelectedItemText(dungeonName) end

    -- Populate boss combo
    local bCombo = ZO_ComboBox_ObjectFromContainer(DungeonStratsWindowBossCombo)
    if not bCombo then return end
    bCombo:SetSortsItems(false)
    bCombo:ClearItems()

    local data = ds.Data[currentCategory]
    local dungeon = data and data[dungeonName]
    if not dungeon or not dungeon.bosses then return end

    for i, boss in ipairs(dungeon.bosses) do
        local idx = i -- capture for closure
        local entry = bCombo:CreateItemEntry(boss.name, function()
            ds.OnBossSelected(idx)
        end)
        bCombo:AddItem(entry, ZO_COMBOBOX_SUPPRESS_UPDATE)
    end
    bCombo:UpdateItems()

    -- Auto-select first boss
    if #dungeon.bosses > 0 then
        ds.OnBossSelected(1)
    end
end

function ds.OnCategorySelected(category)
    currentCategory = category
    -- Update label text for dungeon label
    local lbl = DungeonStratsWindowDungeonLabel
    if lbl then
        lbl:SetText(category == "trials" and "Trial:" or "Dungeon:")
    end

    local data = ds.Data[category]
    if not data then return end

    local sorted = getSortedNames(data)

    -- Populate dungeon combo
    local dCombo = ZO_ComboBox_ObjectFromContainer(DungeonStratsWindowDungeonCombo)
    if not dCombo then return end
    dCombo:SetSortsItems(false)
    dCombo:ClearItems()

    for _, info in ipairs(sorted) do
        local name = info.name
        local entry = dCombo:CreateItemEntry(name, function()
            ds.OnDungeonSelected(name)
        end)
        dCombo:AddItem(entry, ZO_COMBOBOX_SUPPRESS_UPDATE)
    end
    dCombo:UpdateItems()

    -- Auto-select first dungeon
    if #sorted > 0 then
        ds.OnDungeonSelected(sorted[1].name)
    end
end

-- ---------------------------------------------------------------------------
-- Init

function ds.InitUI()
    -- Create text label inside scroll container
    local scroll = DungeonStratsWindowScroll
    if not scroll then return end
    local scrollChild = scroll:GetNamedChild("ScrollChild")
    if not scrollChild then return end
    local label = WINDOW_MANAGER:CreateControl(
        "DungeonStratsText", scrollChild, CT_LABEL)
    label:SetFont("ZoFontGame")
    label:SetColor(0.93, 0.93, 0.93, 1)
    label:SetWrapMode(TEXT_WRAP_MODE_WRAP)
    label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    label:SetVerticalAlignment(TEXT_ALIGN_TOP)
    label:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, 4, 4)
    ds._textLabel = label

    -- Category combo
    local cCombo = ZO_ComboBox_ObjectFromContainer(DungeonStratsWindowCategoryCombo)
    if cCombo then
        cCombo:ClearItems()
        local dungeonEntry = cCombo:CreateItemEntry("Dungeons", function()
            ds.OnCategorySelected("dungeons")
        end)
        local trialEntry = cCombo:CreateItemEntry("Trials", function()
            ds.OnCategorySelected("trials")
        end)
        cCombo:AddItem(dungeonEntry, ZO_COMBOBOX_SUPPRESS_UPDATE)
        cCombo:AddItem(trialEntry, ZO_COMBOBOX_SUPPRESS_UPDATE)
        cCombo:UpdateItems()

        -- Default to Dungeons
        cCombo:SetSelectedItemText("Dungeons")
        ds.OnCategorySelected("dungeons")
    end
end

-- ---------------------------------------------------------------------------
-- Show / Hide / Toggle

function ds.Show()
    DungeonStratsWindow:SetHidden(false)
    if not IsGameCameraUIModeActive() then
        SetGameCameraUIMode(true)
    end
end

function ds.Hide()
    DungeonStratsWindow:SetHidden(true)
end

function ds.Toggle()
    if DungeonStratsWindow:IsHidden() then
        ds.Show()
    else
        ds.Hide()
    end
end

-- ---------------------------------------------------------------------------
-- Bootstrap

local function onLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    ds.InitUI()

    SLASH_COMMANDS["/dungeonstrats"] = function() ds.Toggle() end
    SLASH_COMMANDS["/ds"] = function() ds.Toggle() end

    ZO_CreateStringId("SI_BINDING_NAME_DUNGEONSTRATS_TOGGLE", "Toggle DungeonStrats")
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, onLoaded)
