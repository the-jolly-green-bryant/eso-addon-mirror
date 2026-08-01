------------------------------------------------------------
-- MyWarningAttack - BEGIN の持続時間だけで危険攻撃を表示する軽量版
-- ★ CombatEvent の全引数をログにため込むデバッガー付き
-- ★ AddAttack と同じ条件でログ保存
------------------------------------------------------------

MyWarningAttack = MyWarningAttack or {}
MyWarningAttack.name = "MyWarningAttack"

local MIN_DURATION = 0.0
local DODGE_IFRAME = 0.6
local BAR_WIDTH = 760
local BAR_HEIGHT = 20
local BASE_Y = 350

MyWarningAttack.attacks = {}
MyWarningAttack.inCombat = false

------------------------------------------------------------
-- ★ デバッグログ（全引数保存）
------------------------------------------------------------
MyWarningAttack.debugLog = {}
local MAX_LOG = 200

local function DebugLogCombatEventFull(args)
    table.insert(MyWarningAttack.debugLog, args)
    if #MyWarningAttack.debugLog > MAX_LOG then
        table.remove(MyWarningAttack.debugLog, 1)
    end
end

------------------------------------------------------------
-- ★ COMBAT_UNIT_TYPE の定数名テーブル
------------------------------------------------------------
local UNIT_TYPE_NAME = {
    [0] = "NONE",
    [1] = "PLAYER",
    [2] = "MONSTER",
    [3] = "TARGET_DUMMY",
    [4] = "OTHER",
    [6] = "GROUP",
    [8] = "COMPANION",
}

local function PrintUnitTypeConstants()
    d("|c88FF88[MyWarningAttack] COMBAT_UNIT_TYPE 一覧|r")
    for k, v in pairs(UNIT_TYPE_NAME) do
        d(string.format("  %d = %s", k, v))
    end
end

------------------------------------------------------------
-- UI: 攻撃バーを作成
------------------------------------------------------------
local function CreateAttackUI(id)
    local ui = WINDOW_MANAGER:CreateTopLevelWindow("MyWarningAttack_UI_" .. id)
    ui:SetDimensions(800, 80)
    ui:SetDrawLayer(DL_OVERLAY)
    ui:SetMouseEnabled(false)
    ui:SetMovable(false)
    ui:SetClampedToScreen(true)
    ui:SetHidden(true)

    local bg = WINDOW_MANAGER:CreateControl(nil, ui, CT_BACKDROP)
    bg:SetAnchorFill(ui)
    bg:SetCenterColor(0, 0, 0, 0.6)
    bg:SetEdgeColor(0, 0, 0, 0)

    local bar = WINDOW_MANAGER:CreateControl(nil, ui, CT_STATUSBAR)
    bar:SetDimensions(BAR_WIDTH, BAR_HEIGHT)
    bar:SetAnchor(TOP, ui, TOP, 0, 10)
    bar:SetMinMax(0, 1)
    bar:SetValue(0)
    bar:SetColor(1, 0.4, 0.2, 1)

    local dodgeLine = WINDOW_MANAGER:CreateControl(nil, ui, CT_BACKDROP)
    dodgeLine:SetDimensions(2, BAR_HEIGHT)
    dodgeLine:SetCenterColor(1, 1, 0, 1)
    dodgeLine:SetEdgeColor(0, 0, 0, 0)

    local label = WINDOW_MANAGER:CreateControl(nil, ui, CT_LABEL)
    label:SetAnchor(BOTTOM, ui, BOTTOM, 0, -5)
    label:SetFont("$(BOLD_FONT)|36|soft-shadow-thick")
    label:SetColor(1, 0.8, 0.2, 1)

    return {
        ui = ui,
        bar = bar,
        label = label,
        dodgeLine = dodgeLine,
    }
end

------------------------------------------------------------
-- 攻撃を追加
------------------------------------------------------------
local function AddAttack(abilityName, duration)
    local now = GetFrameTimeSeconds()
    local id = GetGameTimeMilliseconds() .. "_" .. abilityName

    local attack = {
        id = id,
        abilityName = abilityName,
        beginTime = now,
        duration = duration,
        endTime = now + duration,
        ui = CreateAttackUI(id),
    }

    MyWarningAttack.attacks[id] = attack
end

------------------------------------------------------------
-- 攻撃バーの並び替え
------------------------------------------------------------
local function ReanchorBars()
    local list = {}

    for _, atk in pairs(MyWarningAttack.attacks) do
        table.insert(list, atk)
    end

    table.sort(list, function(a, b)
        return a.endTime < b.endTime
    end)

    local y = BASE_Y
    for _, atk in ipairs(list) do
        atk.ui.ui:ClearAnchors()
        atk.ui.ui:SetAnchor(TOP, GuiRoot, TOP, 0, y)
        y = y + 90
    end
end

------------------------------------------------------------
-- Update（全攻撃バー更新）
------------------------------------------------------------
local function OnUpdate()
    if not MyWarningAttack.inCombat then return end

    local now = GetFrameTimeSeconds()

    for id, atk in pairs(MyWarningAttack.attacks) do
        local remain = atk.endTime - now

        if remain <= 0 then
            atk.ui.ui:SetHidden(true)
            MyWarningAttack.attacks[id] = nil
        else
            local progress = (now - atk.beginTime) / atk.duration
            atk.ui.bar:SetValue(progress)

            atk.ui.label:SetText(atk.abilityName)

            local dodgePoint = atk.duration - DODGE_IFRAME
            if dodgePoint < 0 then dodgePoint = 0 end

            local x = (dodgePoint / atk.duration) * BAR_WIDTH
            atk.ui.dodgeLine:ClearAnchors()
            atk.ui.dodgeLine:SetAnchor(TOPLEFT, atk.ui.bar, TOPLEFT, x, 0)

            atk.ui.ui:SetHidden(false)
        end
    end

    ReanchorBars()
end

------------------------------------------------------------
-- CombatEvent（BEGIN の持続時間だけでフィルタ）
------------------------------------------------------------
local function OnCombatEvent(eventCode, result, isError, abilityName,
    abilityGraphic, abilityActionSlotType, sourceName, sourceType,
    targetName, targetType, hitValue, powerType, damageType,
    log, sourceUnitId, targetUnitId, abilityId)

    if result == ACTION_RESULT_BEGIN and targetType == COMBAT_UNIT_TYPE_PLAYER then
        local duration = hitValue / 1000

        if duration >= MIN_DURATION then
            DebugLogCombatEventFull({
                ["01_eventCode"] = eventCode,
                ["02_result"] = result,
                ["03_isError"] = isError,
                ["04_abilityName"] = abilityName,
                ["05_abilityGraphic"] = abilityGraphic,
                ["06_abilityActionSlotType"] = abilityActionSlotType,
                ["07_sourceName"] = sourceName,
                ["08_sourceType"] = sourceType,
                ["09_targetName"] = targetName,
                ["10_targetType"] = targetType,
                ["11_hitValue"] = hitValue,
                ["12_powerType"] = powerType,
                ["13_damageType"] = damageType,
                ["14_log"] = log,
                ["15_sourceUnitId"] = sourceUnitId,
                ["16_targetUnitId"] = targetUnitId,
                ["17_abilityId"] = abilityId,
            })

            AddAttack(abilityName, duration)
        end
    end
end

------------------------------------------------------------
-- 戦闘状態管理
------------------------------------------------------------
local function OnCombatState(event, inCombat)
    MyWarningAttack.inCombat = inCombat

    if not inCombat then
        for id, atk in pairs(MyWarningAttack.attacks) do
            atk.ui.ui:SetHidden(true)
        end
        MyWarningAttack.attacks = {}
    end
end

------------------------------------------------------------
-- ★ abilityId 重複除外＋全引数を1件ずつ出力（0.5秒間隔）
------------------------------------------------------------
local function ShowMWLogFullChunked(list, index)
    if index > #list then
        d("[MyWarningAttack] ログ表示完了")
        return
    end

    local e = list[index]
    d(string.format("[MyWarningAttack] --- Log %d ---", index))

    -- 全引数をソートして出力
    local keys = {}
    for k in pairs(e) do table.insert(keys, k) end
    table.sort(keys)

    for _, k in ipairs(keys) do
        d(string.format("%s = %s", k, tostring(e[k])))
    end

    zo_callLater(function()
        ShowMWLogFullChunked(list, index + 1)
    end, 500)
end

SLASH_COMMANDS["/mwlog"] = function()
    if #MyWarningAttack.debugLog == 0 then
        d("[MyWarningAttack] ログは空です。")
        return
    end

    -- abilityId 重複除外
    local seen = {}
    local unique = {}

    for _, e in ipairs(MyWarningAttack.debugLog) do
        local id = e["17_abilityId"]
        if id and not seen[id] then
            seen[id] = true
            table.insert(unique, e)
        end
    end

    d(string.format("[MyWarningAttack] abilityId 重複除外後: %d 件", #unique))
    d("[MyWarningAttack] 1件ずつ全引数を出力します...")

    ShowMWLogFullChunked(unique, 1)
end

------------------------------------------------------------
-- ★ デバッグログクリア
------------------------------------------------------------
local function Slash_mwclear()
    MyWarningAttack.debugLog = {}
    d("MyWarningAttack debug log cleared.")
end

SLASH_COMMANDS["/mwclear"] = Slash_mwclear

------------------------------------------------------------
-- AddOn Loaded
------------------------------------------------------------
local function OnAddOnLoaded(event, addonName)
    if addonName ~= MyWarningAttack.name then return end

    EVENT_MANAGER:RegisterForEvent("MyWarningAttack_Combat", EVENT_COMBAT_EVENT, OnCombatEvent)
    EVENT_MANAGER:RegisterForEvent("MyWarningAttack_CombatState", EVENT_PLAYER_COMBAT_STATE, OnCombatState)
    EVENT_MANAGER:RegisterForUpdate("MyWarningAttack_Update", 20, OnUpdate)

    PrintUnitTypeConstants()

    d("MyWarningAttack Loaded")
end

EVENT_MANAGER:RegisterForEvent(MyWarningAttack.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)