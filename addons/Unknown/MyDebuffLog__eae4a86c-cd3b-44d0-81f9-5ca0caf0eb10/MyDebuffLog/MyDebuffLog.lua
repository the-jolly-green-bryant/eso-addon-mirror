MyDebuffLog = {}
MyDebuffLog.name = "MyDebuffLog"
MyDebuffLog.saved = nil

local isLogging = false
local outputIndex = 1
local outputTimer = nil

------------------------------------------------------------
-- ログ保存（全引数を保存）
------------------------------------------------------------
local function AddLog(
    eventCode, changeType, effectSlot, effectName, unitTag, beginTime,
    endTime, stackCount, iconName, buffType, effectType, abilityType,
    statusEffectType, targetName, targetUnitId, abilityId, sourceUnitType
)
    if not isLogging then return end

    table.insert(MyDebuffLog.saved.logs, {
        time = GetTimeStamp(),

        eventCode = eventCode,
        changeType = changeType,
        effectSlot = effectSlot,
        effectName = effectName,
        unitTag = unitTag,
        beginTime = beginTime,
        endTime = endTime,
        stackCount = stackCount,
        iconName = iconName,
        buffType = buffType,
        effectType = effectType,
        abilityType = abilityType,
        statusEffectType = statusEffectType,
        targetName = targetName,
        targetUnitId = targetUnitId,
        abilityId = abilityId,
        sourceUnitType = sourceUnitType,
    })
end

------------------------------------------------------------
-- EVENT_EFFECT_CHANGED（デバフのみ対象）
------------------------------------------------------------
local function OnEffectChanged(
    eventCode, changeType, effectSlot, effectName, unitTag, beginTime,
    endTime, stackCount, iconName, buffType, effectType, abilityType,
    statusEffectType, targetName, targetUnitId, abilityId, sourceUnitType
)

    if sourceUnitType ~= COMBAT_UNIT_TYPE_PLAYER then return end
    if effectType ~= BUFF_EFFECT_TYPE_DEBUFF then return end
    if changeType ~= EFFECT_RESULT_GAINED then return end
    if targetName == "" then return end

    AddLog(
        eventCode, changeType, effectSlot, effectName, unitTag, beginTime,
        endTime, stackCount, iconName, buffType, effectType, abilityType,
        statusEffectType, targetName, targetUnitId, abilityId, sourceUnitType
    )
end

------------------------------------------------------------
-- beginTime を HH:MM:SS に変換する
------------------------------------------------------------
local function ConvertBeginTimeToHHMMSS(log)
    local nowGame = GetGameTimeMilliseconds() / 1000
    local nowUnix = log.time
    local beginUnix = nowUnix - (nowGame - log.beginTime)
    return os.date("%H:%M:%S", beginUnix)
end

------------------------------------------------------------
-- ログ出力（10行ずつ、0.5秒間隔）
------------------------------------------------------------
local function OutputNextChunk()
    local logs = MyDebuffLog.saved.logs
    local total = #logs

    if outputIndex > total then
        d("[MyDebuffLog] 出力完了")
        outputTimer = nil
        return
    end

    local endIndex = math.min(outputIndex + 9, total)

    for i = outputIndex, endIndex do
        local L = logs[i]

        -- beginTime → HH:MM:SS
        local beginHHMMSS = ConvertBeginTimeToHHMMSS(L)

        -- duration（小数1桁）
        local duration = L.endTime - L.beginTime

        d(string.format(
            "[%d] %s 持続時間%.1f秒 name:%s target:%s aid:%d",
            i,
            beginHHMMSS,
            duration,
            L.effectName,
            L.targetName,
            L.abilityId
        ))
    end

    outputIndex = endIndex + 1
    outputTimer = zo_callLater(OutputNextChunk, 500)
end

local function StartOutput()
    if outputTimer then
        d("[MyDebuffLog] すでに出力中です")
        return
    end

    outputIndex = 1
    d("[MyDebuffLog] ログ出力開始")
    OutputNextChunk()
end

------------------------------------------------------------
-- スラッシュコマンド
------------------------------------------------------------
local function SlashCommand(arg)
    arg = string.lower(arg or "")

    if arg == "start" then
        isLogging = true
        MyDebuffLog.saved.isLogging = true
        d("[MyDebuffLog] 記録開始")
        return
    end

    if arg == "stop" then
        isLogging = false
        MyDebuffLog.saved.isLogging = false
        d("[MyDebuffLog] 記録停止")
        return
    end

    if arg == "clear" then
        MyDebuffLog.saved.logs = {}
        d("[MyDebuffLog] ログ初期化")
        return
    end

    if arg == "show" then
        StartOutput()
        return
    end

    d("[MyDebuffLog] コマンド一覧:")
    d("/glogstart - 記録開始")
    d("/glogstop  - 記録停止")
    d("/glogclear - ログ初期化")
    d("/glogshow  - ログ出力（10行ずつ）")
end

------------------------------------------------------------
-- AddOnLoaded
------------------------------------------------------------
function MyDebuffLog.OnAddOnLoaded(event, addonName)
    if addonName ~= MyDebuffLog.name then return end

    MyDebuffLog.saved = ZO_SavedVars:NewAccountWide(
        "MyDebuffLogSaved", 1, nil,
        { logs = {}, isLogging = false }
    )

    isLogging = MyDebuffLog.saved.isLogging

    EVENT_MANAGER:RegisterForEvent(
        MyDebuffLog.name,
        EVENT_EFFECT_CHANGED,
        OnEffectChanged
    )

    SLASH_COMMANDS["/glogstart"] = function() SlashCommand("start") end
    SLASH_COMMANDS["/glogstop"]  = function() SlashCommand("stop") end
    SLASH_COMMANDS["/glogclear"] = function() SlashCommand("clear") end
    SLASH_COMMANDS["/glogshow"]  = function() SlashCommand("show") end

    d("[MyDebuffLog] Loaded (デバフのみ + beginTime秒表示 + duration小数表示)")
end

EVENT_MANAGER:RegisterForEvent(
    MyDebuffLog.name .. "_Load",
    EVENT_ADD_ON_LOADED,
    MyDebuffLog.OnAddOnLoaded
)