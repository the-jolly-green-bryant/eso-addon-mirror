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
-- UI: Create a bar
------------------------------------------------------------
local function CreateBar(unitId)
    local parent = MyTauntTimer.ui
    local fontSize = MyTauntTimer.saved.fontSize
    local barHeight = AutoBarHeight(fontSize)

    local bar = WINDOW_MANAGER:CreateControl(nil, parent, CT_STATUSBAR)
    bar:SetDimensions(300, barHeight)
    bar:SetMinMax(0, 1)
    bar:SetValue(1)
    bar:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)

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
-- Slash Commands
------------------------------------------------------------

local function ShowSettings()
    d("========================================")
    d("        MyTauntTimer コマンド一覧       ")
    d("========================================")
    d("/mtt")
    d("  現在の設定を表示")
    d("/tauntpos X Y")
    d("  UI の表示位置を変更")
    d("/tauntflashother on/off")
    d("  他人タウントでも明滅するか設定")
    d("/tauntflashsec <秒数>")
    d("  明滅開始秒数を設定")
    d("/tauntfontsize <数値>")
    d("  フォントサイズ変更（バー高さも自動調整）")
    d("/tauntflashrank <1〜4>")
    d("  ★ 明滅ランク閾値を変更（1〜4）")
    d("----------------------------------------")
    d("現在の設定:")
    d("  位置: X=" .. MyTauntTimer.saved.posX .. "  Y=" .. MyTauntTimer.saved.posY)
    d("  フォントサイズ: " .. MyTauntTimer.saved.fontSize)
    d("  明滅開始秒数: " .. MyTauntTimer.saved.flashThreshold .. " 秒")
    d("  他人タウント明滅: " .. (MyTauntTimer.saved.flashOnOtherTaunt and "ON" or "OFF"))
    d("  明滅ランク閾値: rank " .. MyTauntTimer.saved.flashRankThreshold)
    d("========================================")
end

local function Slash_mtt(arg)
    ShowSettings()
end

local function Slash_tauntpos(arg)
    local x, y = arg:match("^(%d+)%s+(%d+)$")
    if x and y then
        MyTauntTimer.saved.posX = tonumber(x)
        MyTauntTimer.saved.posY = tonumber(y)
        MyTauntTimer.ui:ClearAnchors()
        MyTauntTimer.ui:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, MyTauntTimer.saved.posX, MyTauntTimer.saved.posY)
        d("位置を X=" .. x .. " Y=" .. y .. " に変更しました")
    else
        d("使用方法: /tauntpos X Y")
    end
end

local function Slash_tauntflashother(arg)
    if arg == "on" then
        MyTauntTimer.saved.flashOnOtherTaunt = true
        d("他人タウント明滅: ON")
    elseif arg == "off" then
        MyTauntTimer.saved.flashOnOtherTaunt = false
        d("他人タウント明滅: OFF")
    else
        d("使用方法: /tauntflashother on/off")
    end
end

local function Slash_tauntflashsec(arg)
    local num = tonumber(arg)
    if num then
        MyTauntTimer.saved.flashThreshold = num
        d("明滅開始秒数を " .. num .. " 秒に設定しました")
    else
        d("使用方法: /tauntflashsec <秒数>")
    end
end

local function Slash_tauntfontsize(arg)
    local num = tonumber(arg)
    if num then
        MyTauntTimer.saved.fontSize = num
        RefreshAllBars()
        d("フォントサイズを " .. num .. " に設定しました（バー高さ自動調整）")
    else
        d("使用方法: /tauntfontsize <数値>")
    end
end

------------------------------------------------------------
-- ★ 新コマンド: 明滅ランク閾値
------------------------------------------------------------
local function Slash_tauntflashrank(arg)
    local num = tonumber(arg)
    if num and num >= 1 and num <= 4 then
        MyTauntTimer.saved.flashRankThreshold = num
        d("明滅ランク閾値を rank " .. num .. " に設定しました")
    else
        d("使用方法: /tauntflashrank <1〜4>")
        d("例: /tauntflashrank 3  （ボス以上で明滅）")
    end
end

SLASH_COMMANDS["/mtt"]             = Slash_mtt
SLASH_COMMANDS["/tauntpos"]        = Slash_tauntpos
SLASH_COMMANDS["/tauntflashother"] = Slash_tauntflashother
SLASH_COMMANDS["/tauntflashsec"]   = Slash_tauntflashsec
SLASH_COMMANDS["/tauntfontsize"]   = Slash_tauntfontsize
SLASH_COMMANDS["/tauntflashrank"]  = Slash_tauntflashrank   -- ★ 追加

------------------------------------------------------------
-- Init
------------------------------------------------------------
local function OnAddOnLoaded(event, addonName)
    if addonName ~= ADDON_NAME then return end

    InitSavedVars()
    CreateUI()

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_COMBAT_EVENT, OnCombatEvent)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_EFFECT_CHANGED, OnEffectChanged)
    EVENT_MANAGER:AddFilterForEvent(ADDON_NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 38254)

    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "_Update", 100, UpdateUI)

    d("MyTauntTimer Loaded")
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)