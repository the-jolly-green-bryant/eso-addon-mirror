local ADDON_NAME = "MyTauntTimer"
local TAUNT_DURATION = 15

MyTauntTimer = MyTauntTimer or {}

------------------------------------------------------------
-- SavedVariables
------------------------------------------------------------
local function InitSavedVars()
    MyTauntTimer.saved = ZO_SavedVars:NewAccountWide("MyTauntTimer_Saved", 1, nil, {
        posX = 1000,
        posY = 250,
        flashThreshold = 5,
        flashOnOtherTaunt = true,
        fontSize = 18,
        flashRankThreshold = 3,   -- ★ 明滅ランク閾値（1〜4）
    })
end

------------------------------------------------------------
-- 自動バー高さ計算
------------------------------------------------------------
local function AutoBarHeight(fontSize)
    return math.floor(fontSize + 6)
end

local TauntTable = {}
local Bars = {}   -- unitId → barControl

------------------------------------------------------------
-- 全バー更新（フォント変更時）
------------------------------------------------------------
local function RefreshAllBars()
    local fontSize = MyTauntTimer.saved.fontSize
    local barHeight = AutoBarHeight(fontSize)

    for unitId, bar in pairs(Bars) do
        bar:SetDimensions(300, barHeight)
        bar.label:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", fontSize))
    end
end

------------------------------------------------------------
-- Settings Menu
------------------------------------------------------------
local function CreateSettingsMenu()
    local settings = LibHarvensAddonSettings:AddAddon("MyTauntTimer", {
        allowDefaults = true,
        allowRefresh = true,
        defaultsFunction = function()
            MyTauntTimer.saved.posX = 1000
            MyTauntTimer.saved.posY = 250
            MyTauntTimer.saved.flashThreshold = 5
            MyTauntTimer.saved.flashOnOtherTaunt = true
            MyTauntTimer.saved.fontSize = 18
            MyTauntTimer.saved.flashRankThreshold = 3
            RefreshAllBars()
        end,
    })

    ------------------------------------------------------------
    -- General
    ------------------------------------------------------------
    settings:AddSettings({
        {
            type = LibHarvensAddonSettings.ST_SECTION,
            label = "一般",
        },
        {
            type = LibHarvensAddonSettings.ST_SLIDER,
            label = "フォントサイズ",
            min = 10, max = 40, step = 1,
            default = 18,
            getFunction = function() return MyTauntTimer.saved.fontSize end,
            setFunction = function(value)
                MyTauntTimer.saved.fontSize = value
                MyTauntTimer.lastPreviewChange = GetFrameTimeSeconds()
                RefreshAllBars()
                MyTauntTimer.StartPreview()
            end,
        },
        {
            type = LibHarvensAddonSettings.ST_SLIDER,
            label = "画面の明滅 (秒)",
            min = 1, max = 15, step = 1,
            default = 5,
            getFunction = function() return MyTauntTimer.saved.flashThreshold end,
            setFunction = function(value)
                MyTauntTimer.saved.flashThreshold = value
            end,
        },
        {
            type = LibHarvensAddonSettings.ST_CHECKBOX,
            label = "他のプレイヤーのタウントの明滅",
            default = true,
            getFunction = function() return MyTauntTimer.saved.flashOnOtherTaunt end,
            setFunction = function(value)
                MyTauntTimer.saved.flashOnOtherTaunt = value
            end,
        },
        {
            type = LibHarvensAddonSettings.ST_SLIDER,
            label = "明滅するランクの閾値",
            min = 1, max = 4, step = 1,
            default = 3,
            getFunction = function() return MyTauntTimer.saved.flashRankThreshold end,
            setFunction = function(value)
                MyTauntTimer.saved.flashRankThreshold = value
            end,
        },
    })

    ------------------------------------------------------------
    -- Position
    ------------------------------------------------------------
    settings:AddSettings({
        {
            type = LibHarvensAddonSettings.ST_SECTION,
            label = "位置調整",
        },
        {
            type = LibHarvensAddonSettings.ST_SLIDER,
            label = "横軸",
            min = 0, max = GuiRoot:GetWidth(), step = 10,
            default = 1000,
            getFunction = function() return MyTauntTimer.saved.posX end,
            setFunction = function(value)
                MyTauntTimer.saved.posX = value
                MyTauntTimer.lastPreviewChange = GetFrameTimeSeconds()
                MyTauntTimer.ui:ClearAnchors()
                MyTauntTimer.ui:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, value, MyTauntTimer.saved.posY)
                MyTauntTimer.StartPreview()
            end,
        },
        {
            type = LibHarvensAddonSettings.ST_SLIDER,
            label = "縦軸",
            min = 0, max = GuiRoot:GetHeight(), step = 10,
            default = 250,
            getFunction = function() return MyTauntTimer.saved.posY end,
            setFunction = function(value)
                MyTauntTimer.saved.posY = value
                MyTauntTimer.lastPreviewChange = GetFrameTimeSeconds()
                MyTauntTimer.ui:ClearAnchors()
                MyTauntTimer.ui:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, MyTauntTimer.saved.posX, value)
                MyTauntTimer.StartPreview()
            end,
        },
    })

end

------------------------------------------------------------
-- Utility
------------------------------------------------------------
local function CleanName(name)
    return (name or ""):gsub("%^.*", "")
end

local function ColorNameByRank(name, rank)
    if rank == 3 or rank == 4 then
        return "|cFF4444" .. name .. "|r"
    elseif rank == 2 then
        return "|cFFAA44" .. name .. "|r"
    else
        return name
    end
end

------------------------------------------------------------
-- UI: Main container
------------------------------------------------------------
local function CreateUI()
    local ui = WINDOW_MANAGER:CreateTopLevelWindow("MyTauntTimer_UI")
    ui:SetDimensions(400, 300)
    ui:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, MyTauntTimer.saved.posX, MyTauntTimer.saved.posY)
    ui:SetDrawLayer(DL_OVERLAY)
    ui:SetMouseEnabled(false)
    ui:SetMovable(false)
    ui:SetHidden(false)
    MyTauntTimer.ui = ui

    ------------------------------------------------------------
    -- Preview Mode 初期化
    ------------------------------------------------------------
    MyTauntTimer.previewActive = false

    ------------------------------------------------------------
    -- 画面全体フラッシュ用オーバーレイ
    ------------------------------------------------------------
    local overlay = WINDOW_MANAGER:CreateTopLevelWindow("MyTauntTimer_FlashOverlay")
    overlay:SetAnchorFill(GuiRoot)
    overlay:SetDrawLayer(DL_FULLSCREEN_EFFECT)
    overlay:SetHidden(true)

    overlay.bg = WINDOW_MANAGER:CreateControl(nil, overlay, CT_BACKDROP)
    overlay.bg:SetAnchorFill(overlay)
    overlay.bg:SetCenterColor(1, 1, 0, 0)
    overlay.bg:SetEdgeColor(0, 0, 0, 0)

    MyTauntTimer.overlay = overlay
end

------------------------------------------------------------
-- Preview Mode
------------------------------------------------------------
function MyTauntTimer.StartPreview()
    MyTauntTimer.lastPreviewChange = GetFrameTimeSeconds()
    MyTauntTimer.previewActive = true

    -- 既存バーは非表示＋親解除のみ
    for _, bar in pairs(Bars) do
        bar:SetHidden(true)
        bar:SetParent(nil)
    end

    Bars = {}
    TauntTable = {}

    -- ダミー生成（既存があれば再利用）
    for i = 1, 3 do
        local id = 900000 + i
        CreateBar(id)
        TauntTable[id] = {
            name = "Dummy Target " .. i,
            endTime = GetFrameTimeSeconds() + 99999,
            rank = 3,
            isSelf = true,
        }
    end
end

------------------------------------------------------------
-- EndPreview
------------------------------------------------------------
function MyTauntTimer.EndPreview()
    MyTauntTimer.previewActive = false

    -- 非表示＋親解除のみ
    for _, bar in pairs(Bars) do
        bar:SetHidden(true)
        bar:SetParent(nil)
    end

    Bars = {}
    TauntTable = {}
end

------------------------------------------------------------
-- UI: Create a bar
------------------------------------------------------------
function CreateBar(unitId)
    local parent = MyTauntTimer.ui
    local fontSize = MyTauntTimer.saved.fontSize
    local barHeight = AutoBarHeight(fontSize)

    local name = "MyTauntTimer_Bar_" .. unitId

    -- 既存コントロールがあれば再利用
    local bar = GetControl(name)
    if bar then
        bar:SetParent(parent)
        bar:SetHidden(false)
    else
        -- 初回のみ CreateControl
        bar = WINDOW_MANAGER:CreateControl(name, parent, CT_STATUSBAR)

        bar:SetDimensions(300, barHeight)
        bar:SetMinMax(0, 1)
        bar:SetValue(1)

        bar.bg = WINDOW_MANAGER:CreateControl(nil, bar, CT_BACKDROP)
        bar.bg:SetAnchorFill(bar)
        bar.bg:SetCenterColor(0, 0, 0, 0.4)
        bar.bg:SetEdgeColor(0, 0, 0, 0)

        local label = WINDOW_MANAGER:CreateControl(nil, bar, CT_LABEL)
        label:SetAnchor(CENTER, bar, CENTER, 0, 0)
        label:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", fontSize))
        label:SetColor(1, 1, 1, 1)
        label:SetText("")

        bar.label = label
    end

    Bars[unitId] = bar
end

------------------------------------------------------------
-- UI: Update bar
------------------------------------------------------------
local function UpdateBar(bar, data, remain)
    bar:SetValue(remain / TAUNT_DURATION)
    bar.label:SetText(data.name)
end

------------------------------------------------------------
-- EVENT_COMBAT_EVENT
------------------------------------------------------------
local function OnCombatEvent(eventCode, result, isError, abilityName,
    abilityGraphic, abilityActionSlotType, sourceName, sourceType,
    targetName, targetType, hitValue, powerType, damageType,
    log, sourceUnitId, targetUnitId, abilityId)

    if result == ACTION_RESULT_TAUNTED then
        local now = GetFrameTimeSeconds()
        local cleanSource = CleanName(sourceName)
        local isSelf = (cleanSource == CleanName(GetUnitName("player")))
        local sourceLabel = isSelf and cleanSource or "Group Member"

        TauntTable[targetUnitId] = {
            target = "",
            source = cleanSource,
            name = "(Unknown) (" .. sourceLabel .. ")",
            endTime = now + TAUNT_DURATION,
            rank = 1,
            isSelf = isSelf,
            flashAlpha = 1,
            flashDir = -1,
        }

        if not Bars[targetUnitId] then
            CreateBar(targetUnitId)
        end
    end

    if result == ACTION_RESULT_DIED
    or result == ACTION_RESULT_DIED_XP
    or result == ACTION_RESULT_DIED_COMPANION then
        TauntTable[targetUnitId] = nil
        if Bars[targetUnitId] then
            Bars[targetUnitId]:SetHidden(true)
            Bars[targetUnitId] = nil
        end
    end
end

------------------------------------------------------------
-- EVENT_EFFECT_CHANGED
------------------------------------------------------------
local function OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag,
    beginTime, endTime, stackCount, iconName, deprecatedBuffType,
    effectType, abilityType, statusEffectType, unitName, unitId,
    abilityId, sourceType)

    if abilityId ~= 38254 then return end
    if not TauntTable[unitId] then return end

    local data = TauntTable[unitId]
    local cleanTarget = CleanName(unitName)
    data.target = cleanTarget

    local rank = GetUnitDifficulty(unitTag)
    if rank then data.rank = rank end

    local sourceName = data.isSelf and data.source or "Group Member"
    data.name = ColorNameByRank(cleanTarget, data.rank) .. " (" .. sourceName .. ")"
end

------------------------------------------------------------
-- UI Update (bars + screen flash)
------------------------------------------------------------
local function UpdateUI()
    local now = GetFrameTimeSeconds()

    -- ★ 3秒間変更なしならプレビュー終了
    if MyTauntTimer.previewActive and MyTauntTimer.lastPreviewChange then
        if now - MyTauntTimer.lastPreviewChange >= 3 then
            MyTauntTimer.EndPreview()
        end
    end

    local selfBoss = {}
    local selfOthers = {}
    local others = {}

    for unitId, data in pairs(TauntTable) do
        if now >= data.endTime then
            TauntTable[unitId] = nil
            if Bars[unitId] then Bars[unitId]:SetHidden(true) end
        else
            if data.isSelf then
                if data.rank >= 3 then
                    table.insert(selfBoss, {unitId=unitId, data=data})
                else
                    table.insert(selfOthers, {unitId=unitId, data=data})
                end
            else
                table.insert(others, {unitId=unitId, data=data})
            end
        end
    end

    local function SortRemain(a, b)
        return a.data.endTime < b.data.endTime
    end

    table.sort(selfBoss, SortRemain)
    table.sort(selfOthers, SortRemain)
    table.sort(others, SortRemain)

    local sorted = {}
    for _, v in ipairs(selfBoss)   do table.insert(sorted, v) end
    for _, v in ipairs(selfOthers) do table.insert(sorted, v) end
    for _, v in ipairs(others)     do table.insert(sorted, v) end

    ------------------------------------------------------------
    -- フラッシュ判定
    ------------------------------------------------------------
    local overlay = MyTauntTimer.overlay
    local flashColor = nil
    local rankThreshold = MyTauntTimer.saved.flashRankThreshold

    -- 自分タウント
    for _, entry in ipairs(selfBoss) do
        local data = entry.data
        local remain = data.endTime - now
        if data.rank >= rankThreshold and remain <= MyTauntTimer.saved.flashThreshold then
            flashColor = {1, 1, 0}
            break
        end
    end

    -- 他人タウント
    if MyTauntTimer.saved.flashOnOtherTaunt and not flashColor then
        for _, entry in ipairs(others) do
            local data = entry.data
            local remain = data.endTime - now
            if data.rank >= rankThreshold and remain <= MyTauntTimer.saved.flashThreshold then
                flashColor = {0.4, 0.6, 1}
                break
            end
        end
    end

    ------------------------------------------------------------
    -- フラッシュ処理
    ------------------------------------------------------------
    if flashColor then
        overlay:SetHidden(false)

        MyTauntTimer.flashAlpha = (MyTauntTimer.flashAlpha or 1)
        MyTauntTimer.flashDir   = (MyTauntTimer.flashDir or -1)

        MyTauntTimer.flashAlpha = MyTauntTimer.flashAlpha + MyTauntTimer.flashDir * 0.015

        if MyTauntTimer.flashAlpha <= 0.05 then
            MyTauntTimer.flashAlpha = 0.05
            MyTauntTimer.flashDir = 1
        elseif MyTauntTimer.flashAlpha >= 0.35 then
            MyTauntTimer.flashAlpha = 0.35
            MyTauntTimer.flashDir = -1
        end

        overlay.bg:SetCenterColor(
            flashColor[1],
            flashColor[2],
            flashColor[3],
            MyTauntTimer.flashAlpha
        )
    else
        overlay:SetHidden(true)
        MyTauntTimer.flashAlpha = 1
        MyTauntTimer.flashDir = -1
    end

    ------------------------------------------------------------
    -- バー更新
    ------------------------------------------------------------
    local fontSize = MyTauntTimer.saved.fontSize
    local barHeight = AutoBarHeight(fontSize)

    local y = 0
    for _, entry in ipairs(sorted) do
        local unitId = entry.unitId
        local data = entry.data
        local remain = math.floor(data.endTime - now + 0.5)

        local bar = Bars[unitId]
        if bar then
            bar:SetHidden(false)
            bar:ClearAnchors()
            bar:SetAnchor(TOPLEFT, MyTauntTimer.ui, TOPLEFT, 0, y)
            UpdateBar(bar, data, remain)

            if data.isSelf and data.rank >= 3 then
                bar:SetColor(1, 0.2, 0.2, 1)
            elseif data.isSelf then
                bar:SetColor(1, 0.9, 0.3, 1)
            else
                bar:SetColor(0.3, 0.5, 1, 1)
            end

            y = y + (barHeight + 2)
        end
    end
end

------------------------------------------------------------
-- Init
------------------------------------------------------------
local function OnAddOnLoaded(event, addonName)
    if addonName ~= ADDON_NAME then return end

    InitSavedVars()
    CreateUI()
    CreateSettingsMenu()

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_COMBAT_EVENT, OnCombatEvent)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_EFFECT_CHANGED, OnEffectChanged)
    EVENT_MANAGER:AddFilterForEvent(ADDON_NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 38254)

    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "_Update", 100, UpdateUI)

    d("MyTauntTimer Loaded")
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
