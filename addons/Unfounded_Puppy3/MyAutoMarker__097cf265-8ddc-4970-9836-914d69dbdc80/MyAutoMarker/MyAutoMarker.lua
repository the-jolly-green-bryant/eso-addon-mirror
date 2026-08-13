-- MyAutoMarker.lua
-- Version 2.2 (自プレイヤーターゲット専用 + 競合防止)
-- Author: Hinatan (patched)

MyAutoMarker = {}
local SV

local markedEnemies = {}   -- unitTag -> { marker, name, realName, time, removed }
local enemyCount   = {}    -- cleanName (登録名) -> count

local DEFAULT_TIMEOUT = 10

---------------------------------------------------------
-- 名前正規化
---------------------------------------------------------
local function CleanName(name)
    return (name or ""):gsub("%^.*", "")
end

---------------------------------------------------------
-- 許可プレイヤー判定
---------------------------------------------------------
local function IsPlayerAllowed()
    local myName = GetUnitDisplayName("player")

    -- ソロ時は常に許可
    if GetGroupSize() == 0 then
        return true
    end

    -- グループ時は allowedPlayers に登録されているか
    return SV.allowedPlayers[myName] == true
end

---------------------------------------------------------
-- reticle が指定 unitTag の対象か判定
-- 現状 unitTag は "reticleover" を想定しているため、
-- 実際は名前比較で判定する
---------------------------------------------------------
local function IsReticleOverUnit(unitTag)
    local info = markedEnemies[unitTag]
    if not info then return false end

    local retName = GetUnitName("reticleover")
    if not retName or retName == "" then return false end

    return CleanName(retName) == info.realName or CleanName(retName) == info.name
end

---------------------------------------------------------
-- マーカー解除（安全化）
-- ・視覚解除は現在の reticle が対象のときのみ行う
-- ・二重解除を防ぐ removed フラグを導入
---------------------------------------------------------
local function RemoveMarkerForUnit(unitTag, reason)
    local info = markedEnemies[unitTag]
    if not info then return end
    if info.removed then
        -- 既に処理済みなら内部クリアして終了
        markedEnemies[unitTag] = nil
        return
    end

    -- 視覚解除は現在の reticle が対象のときだけ行う
    if IsReticleOverUnit(unitTag) then
        AssignTargetMarkerToReticleTarget(0)
        d("[MyAutoMarker] 視覚解除: " .. tostring(info.realName) .. " (reticle一致)")
    else
        d("[MyAutoMarker] 内部解除のみ: " .. tostring(info.realName) .. " (reticle不一致)")
    end

    local name = info.name
    if name and enemyCount[name] then
        enemyCount[name] = enemyCount[name] - 1
        if enemyCount[name] <= 0 then
            enemyCount[name] = nil
        end
        d("[MyAutoMarker] enemyCount 更新: " .. tostring(name) .. " -> " .. tostring(enemyCount[name] or 0))
    end

    info.removed = true
    markedEnemies[unitTag] = nil

    if reason then
        d("[MyAutoMarker] 削除理由: " .. tostring(reason))
    end
end

---------------------------------------------------------
-- SavedVars 管理
---------------------------------------------------------
local function AddEnemy(name)
    local clean = CleanName(name)
    SV.enemies[clean] = true
    d("[MyAutoMarker] 登録: " .. clean)
end

local function RemoveEnemy(name)
    local clean = CleanName(name)
    SV.enemies[clean] = nil
    d("[MyAutoMarker] 削除: " .. clean)
end

local function AllowPlayer(name)
    SV.allowedPlayers[name] = true
    d("[MyAutoMarker] 許可: " .. name)
end

local function UnallowPlayer(name)
    SV.allowedPlayers[name] = nil
    d("[MyAutoMarker] 許可解除: " .. name)
end

local function ListEnemies()
    d("=== 登録敵名 ===")
    for name,_ in pairs(SV.enemies) do
        d("- " .. name)
    end

    d("=== 許可プレイヤー ===")
    for name,_ in pairs(SV.allowedPlayers) do
        d("- " .. name)
    end

    d("自動解除秒数: " .. tostring(SV.timeoutSeconds))
end

---------------------------------------------------------
-- 時刻取得
---------------------------------------------------------
local function GetTimeSeconds()
    if GetFrameTimeSeconds then
        return GetFrameTimeSeconds()
    end
    return os.time()
end

---------------------------------------------------------
-- マーカー付与（reticleover 専用）
-- 改良点:
-- ・既に同一 unitTag が登録済みなら time を更新して延長する
-- ・markedEnemies に realName を保存して reticle 比較に使う
---------------------------------------------------------
local function AssignMarkerToEnemy(unitTag, rawName)
    local name = CleanName(rawName)
    if name == "" then return end

    local info = markedEnemies[unitTag]
    if info then
        -- 既にマーク済みならタイムスタンプをリセットして延長
        info.time = GetTimeSeconds()
        d("[MyAutoMarker] 再照準で延長: " .. tostring(info.realName) .. " time reset")
        return
    end

    local count = enemyCount[name] or 0
    local markerIndex

    if count == 0 then
        markerIndex = 8 -- ドクロ
    elseif count == 1 then
        markerIndex = 7 -- 剣
    else
        d("[MyAutoMarker] 付与スキップ (3体目以降): " .. tostring(name))
        return -- 3体目以降は付与しない
    end

    AssignTargetMarkerToReticleTarget(markerIndex)
    d("[MyAutoMarker] マーカー付与: " .. tostring(name) .. " -> marker " .. tostring(markerIndex))

    markedEnemies[unitTag] = {
        marker = markerIndex,
        name   = name,            -- 登録名（または正規化名）
        realName = name,         -- 実際のターゲット名（現状同じ）
        time   = GetTimeSeconds(),
        removed = false,
    }
    enemyCount[name] = count + 1
    d("[MyAutoMarker] enemyCount 更新: " .. tostring(name) .. " -> " .. tostring(enemyCount[name]))
end

---------------------------------------------------------
-- 自プレイヤーがターゲットした時の処理
---------------------------------------------------------
local function OnReticleChanged()
    -- グループ時は許可プレイヤーのみ
    if not IsPlayerAllowed() then return end

    local rawName = GetUnitName("reticleover")
    local name    = CleanName(rawName)
    if name == "" then return end

    -- 登録されていない敵は無視
    if not SV.enemies[name] then return end

    AssignMarkerToEnemy("reticleover", rawName)
end

---------------------------------------------------------
-- 死亡時の自動解除
---------------------------------------------------------
local function OnUnitDeathStateChanged(_, unitTag, isDead)
    if isDead and markedEnemies[unitTag] then
        RemoveMarkerForUnit(unitTag, "death")
    end
end

---------------------------------------------------------
-- 時間経過で自動解除
---------------------------------------------------------
local function CleanupExpiredMarkers()
    local now     = GetTimeSeconds()
    local timeout = SV.timeoutSeconds

    for unitTag, info in pairs(markedEnemies) do
        if info and not info.removed and (now - info.time) >= timeout then
            d("[MyAutoMarker] タイムアウト検出: " .. tostring(info.realName) .. " (経過 " .. tostring(now - info.time) .. "s)")
            RemoveMarkerForUnit(unitTag, "timeout")
        end
    end
end

---------------------------------------------------------
-- 初期化
---------------------------------------------------------
local function OnAddonLoaded(_, addonName)
    if addonName ~= "MyAutoMarker" then return end

    local myName = GetUnitDisplayName("player")

    SV = ZO_SavedVars:NewAccountWide("MyAutoMarkerSaved", 1, nil, {
        enemies        = {},
        allowedPlayers = { [myName] = true }, -- グループ時デフォルトは自分のみ
        timeoutSeconds = DEFAULT_TIMEOUT,
    })

    SLASH_COMMANDS["/mymarker"] = function(text)
        local cmd, arg = text:match("^(%S+)%s*(.*)$")

        if cmd == "add" and arg ~= "" then
            AddEnemy(arg)

        elseif cmd == "remove" and arg ~= "" then
            RemoveEnemy(arg)

        elseif cmd == "allow" and arg ~= "" then
            AllowPlayer(arg)

        elseif cmd == "unallow" and arg ~= "" then
            UnallowPlayer(arg)

        elseif cmd == "list" then
            ListEnemies()

        elseif cmd == "timeout" and tonumber(arg) then
            SV.timeoutSeconds = tonumber(arg)
            d("[MyAutoMarker] 自動解除秒数を " .. arg .. " に設定しました")

        else
            d("MyAutoMarker コマンド:")
            d("/mymarker add <敵名>        - 敵名を登録")
            d("/mymarker remove <敵名>     - 登録を削除")
            d("/mymarker allow <@name>     - 許可プレイヤー追加")
            d("/mymarker unallow <@name>   - 許可プレイヤー削除")
            d("/mymarker list              - 登録敵名と許可プレイヤー一覧")
            d("/mymarker timeout <秒>      - マーカー自動解除秒数設定")
        end
    end

    EVENT_MANAGER:RegisterForEvent("MyAutoMarkerReticle", EVENT_RETICLE_TARGET_CHANGED, OnReticleChanged)
    EVENT_MANAGER:RegisterForEvent("MyAutoMarkerDeath",   EVENT_UNIT_DEATH_STATE_CHANGED, OnUnitDeathStateChanged)
    EVENT_MANAGER:RegisterForUpdate("MyAutoMarkerCleanup", 1000, CleanupExpiredMarkers)

    d("[MyAutoMarker] 初期化完了 (timeout=" .. tostring(SV.timeoutSeconds) .. "s)")
end

EVENT_MANAGER:RegisterForEvent("MyAutoMarkerLoad", EVENT_ADD_ON_LOADED, OnAddonLoaded)