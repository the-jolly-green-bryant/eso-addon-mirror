local ADDON_NAME = "MyCrystalFragmentsProcUI"

MyCrystalFragmentsProcUI = MyCrystalFragmentsProcUI or {}

local WATCH_LIST = {
    [203447] = true,  -- Bound Armaments Proc (stackCount >= 4 only)
    [23231] = true,   -- Hurricane
    [46327] = true,   -- Crystal Fragments Ready
}

local BuffTable = {}   -- abilityId → buffData
local BuffBars  = {}   -- abilityId → barControl

------------------------------------------------------------
-- MyTauntTimer と同じバー高さ
------------------------------------------------------------
local function AutoBarHeight(fontSize)
    return math.floor(fontSize + 6)
end

------------------------------------------------------------
-- UI: Main container
------------------------------------------------------------
local function CreateUI()
    local ui = WINDOW_MANAGER:CreateTopLevelWindow("MyCFProcUI_UI")
    ui:SetDimensions(300, 400)
    ui:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 1200, 300)
    ui:SetDrawLayer(DL_OVERLAY)
    ui:SetHidden(false)
    MyCrystalFragmentsProcUI.ui = ui
end

------------------------------------------------------------
-- UI: Create a bar
------------------------------------------------------------
local function CreateBar(abilityId)
    local parent = MyCrystalFragmentsProcUI.ui

    local fontSize = 18
    local barHeight = AutoBarHeight(fontSize)
    local iconSize = barHeight

    local row = WINDOW_MANAGER:CreateControl(nil, parent, CT_CONTROL)
    row:SetDimensions(300, barHeight)

    local icon = WINDOW_MANAGER:CreateControl(nil, row, CT_TEXTURE)
    icon:SetDimensions(iconSize, iconSize)
    icon:SetAnchor(LEFT, row, LEFT, 0, 0)

    local bar = WINDOW_MANAGER:CreateControl(nil, row, CT_STATUSBAR)
    bar:SetDimensions(250, barHeight)
    bar:SetMinMax(0, 1)
    bar:SetValue(1)
    bar:SetAnchor(LEFT, icon, RIGHT, 4, 0)

    bar.bg = WINDOW_MANAGER:CreateControl(nil, bar, CT_BACKDROP)
    bar.bg:SetAnchorFill(bar)
    bar.bg:SetCenterColor(0, 0, 0, 0.4)
    bar.bg:SetEdgeColor(0, 0, 0, 0)

    row.icon = icon
    row.bar  = bar

    BuffBars[abilityId] = row
end

------------------------------------------------------------
-- UI: Update bar
------------------------------------------------------------
local function UpdateBar(row, data, remain)
    row.icon:SetTexture(data.icon)
    row.bar:SetValue(remain / data.duration)
end

------------------------------------------------------------
-- EVENT_EFFECT_CHANGED
------------------------------------------------------------
local function OnEffectChanged(eventCode,
    changeType,
    effectSlot,
    effectName,
    unitTag,
    beginTime,
    endTime,
    stackCount,
    iconName,
    buffType,
    effectType,
    abilityType,
    statusEffectType,
    unitName,
    unitId,
    abilityId,
    sourceType)

    d("EffectChanged: " .. tostring(abilityId))

    if unitTag ~= "player" then return end
    if not WATCH_LIST[abilityId] then return end

    -- Bound Armaments Proc: stackCount < 4 のときは非表示
    if abilityId == 203447 and stackCount < 4 then
        BuffTable[abilityId] = nil
        if BuffBars[abilityId] then
            BuffBars[abilityId]:SetHidden(true)
            BuffBars[abilityId] = nil
        end
        return
    end

    if changeType == EFFECT_RESULT_GAINED then
        BuffTable[abilityId] = {
            abilityId = abilityId,
            icon = iconName,
            beginTime = beginTime,
            endTime = endTime,
            duration = endTime - beginTime,
            stackCount = stackCount,
        }

        if not BuffBars[abilityId] then
            CreateBar(abilityId)
        end
    end

    if changeType == EFFECT_RESULT_FADED then
        BuffTable[abilityId] = nil
        if BuffBars[abilityId] then
            BuffBars[abilityId]:SetHidden(true)
            BuffBars[abilityId] = nil
        end
    end
end

------------------------------------------------------------
-- UI Update（残り時間順）
------------------------------------------------------------
local function UpdateUI()
    local now = GetFrameTimeSeconds()
    local sorted = {}

    for abilityId, data in pairs(BuffTable) do

        -- Bound Armaments Proc: stackCount < 4 のときは非表示
        if abilityId == 203447 and data.stackCount < 4 then
            BuffTable[abilityId] = nil
            if BuffBars[abilityId] then BuffBars[abilityId]:SetHidden(true) end
        else
            if now < data.endTime then
                table.insert(sorted, {abilityId=abilityId, data=data})
            else
                BuffTable[abilityId] = nil
                if BuffBars[abilityId] then BuffBars[abilityId]:SetHidden(true) end
            end
        end
    end

    table.sort(sorted, function(a, b)
        return a.data.endTime < b.data.endTime
    end)

    local y = 0
    for _, entry in ipairs(sorted) do
        local abilityId = entry.abilityId
        local data = entry.data
        local remain = data.endTime - now

        local row = BuffBars[abilityId]
        if row then
            row:SetHidden(false)
            row:ClearAnchors()
            row:SetAnchor(TOPLEFT, MyCrystalFragmentsProcUI.ui, TOPLEFT, 0, y)
            UpdateBar(row, data, remain)
            y = y + AutoBarHeight(18) + 2
        end
    end
end

------------------------------------------------------------
-- Init
------------------------------------------------------------
local function OnAddOnLoaded(event, addonName)
    if addonName ~= ADDON_NAME then return end

    CreateUI()

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_EFFECT_CHANGED, OnEffectChanged)

    -- abilityId フィルタ（OR 条件で積み上がる）
--    for id, _ in pairs(WATCH_LIST) do
--        EVENT_MANAGER:AddFilterForEvent(ADDON_NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, id)
--    end

    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "_Update", 100, UpdateUI)

    d("MyCrystalFragmentsProcUI Loaded (filters + stackCount logic)")
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
