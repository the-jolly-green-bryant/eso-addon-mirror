-- Lionas's Food & Drink Reminder
-- Author: Lionas

LioFADR = {
  name = "LionasFoodAndDrinkReminder",
  displayName = "Lionas's Food & Drink Reminder",
  notifyFirst = {}, -- 最初の通知済みリスト
  notifyRemain = {}, -- 残り時間通知済みリスト
  notifyClosed = {}, -- 残り時間が迫っている通知済みリスト
  notifyExpired = {}, -- 効果が切れた通知済みリスト
  default = {
    enable = true,              -- アドオン有効無効
    notifyThresholdMins = 3,  -- 通知する閾値(分)
    notifyInDungeon = true,  -- ダンジョンにいる時に通知する
    isInDungeon = false,  -- 現在ダンジョンにいるかどうか
    enableToChat = true,  -- チャット欄に通知する
    notifyByZoneChanging = true, -- ゾーン変更時に通知する
    isZoneChanged = false, -- ゾーン変更したかどうか
    cooldownSec = 60, -- クールダウン時間(秒)
    lastNotifyTime = 0, -- 最後に通知した時間
    enableNotifyAlreadyNone = true, -- 既に効果が切れている時に通知するかどうか
    enableNotifyIcon = true, -- 通知アイコンを使用するかどうか
    iconPosX = 10, -- 警告アイコンの位置X
    iconPosY = 150, -- 警告アイコンの位置Y
    useAccountWide = true, -- アカウント共有
  },
  debug = false, -- デバッグ出力用
  icon = nil, -- 警告アイコン
  notifyMessage = nil, -- 通知メッセージ
  isNeverNotify = false, -- 次の通知更新までアイコンを表示しない
  isHideScene = false, -- シーンか隠れているかどうか
  isHideReticle = false, -- 照準が隠れているかどうか
}

local PLAYER_TAG = "player"

local ADD_ON_LOADED_REGISTER_NAME = LioFADR.name .. "_OnLoad"
local PLAYER_ACTIVATED_REGISTER_NAME = LioFADR.name .. "_Player_Activate"
local PLAYER_DEACTIVATED_REGISTER_NAME = LioFADR.name .. "_Player_DeActivate"
local UPDATE_INTERVAL_REGISTER_NAME = LioFADR.name .. "_Update"
local ZONE_CHANGED_REGISTER_NAME = LioFADR.name .. "_ZoneChanged"
local SAVED_PREFS_NAME = LioFADR.name .. "_SavedPrefs"
local ICON_NAME = LioFADR.name .. "_AlertIcon"

local SAVED_PREFS_VERSION = 4

local UPDATE_INTERVAL_MSEC = 1000
local HOUR_PER_SECS = 3600
local MIN_PER_SECS = 60

local THRESHOLD_EXPIRE_SECS = 60

local EXPIRED_DUMMY_ID = -1

-- Vanilla UIメッセージの色
local BUFF_COLOR = "ff0000"
local TIME_COLOR = "ff00ff"
local ATTENTION_COLOR = "ff3DA5"

-- チャットメッセージ
local DMSG_HEADER = "[" .. LioFADR.displayName .. "] "

-- 警告アイコンのパス
local ICON_PATH = [[/esoui/art/icons/quest_food_004.dds]] -- 警告アイコンのパス
local ICON_SIZE = 64


-- Clear tables
function LioFADR:clearTables()

  LioFADRCommon.clearTable(LioFADR.notifyFirst)
  LioFADRCommon.clearTable(LioFADR.notifyRemain)
  LioFADRCommon.clearTable(LioFADR.notifyClosed)
  LioFADRCommon.clearTable(LioFADR.notifyExpired)

end


-- Initialize preferences
local function initializePrefs()

  local defaultList = {
    enable = LioFADR.default.enable,
    notifyThresholdMins = LioFADR.default.notifyThresholdMins,
    notifyInDungeon = LioFADR.default.notifyInDungeon,
    isInDungeon = LioFADR.default.isInDungeon,
    enableToChat = LioFADR.default.enableToChat,
    notifyByZoneChanging = LioFADR.default.notifyByZoneChanging,
    isZoneChanged = LioFADR.default.isZoneChanged,
    cooldownSec = LioFADR.default.cooldownSec,
    lastNotifyTime = LioFADR.default.lastNotifyTime,
    debug = LioFADR.default.debug,
    enableNotifyAlreadyNone = LioFADR.default.enableNotifyAlreadyNone,
    enableNotifyIcon = LioFADR.default.enableNotifyIcon,
    iconPosX = LioFADR.default.iconPosX,
    iconPosY = LioFADR.default.iconPosY,
    useAccountWide = LioFADR.default.useAccountWide,
  }

  LioFADR.PREFS_NAME = SAVED_PREFS_NAME
  LioFADR.savedVariables = ZO_SavedVars:NewAccountWide(SAVED_PREFS_NAME, SAVED_PREFS_VERSION, nil, defaultList)
  if(not LioFADR.savedVariables.useAccountWide) then
    LioFADR.savedVariables = ZO_SavedVars:New(SAVED_PREFS_NAME, SAVED_PREFS_VERSION, nil, defaultList)
  end

end


-- Icon
function hideIcon()
  
  -- アイコンの非表示
  if(not LioFADRContainer:IsHidden()) then
    LioFADRContainer:SetHidden(true)
  end
  
  if(not LioFADR.icon:IsHidden()) then
    LioFADR.icon:SetHidden(true)
  end
  
end

function showIcon()
  
  if((not LioFADR.isHideScene or LioFADR.isHideReticle) and LioFADR.savedVariables.enableNotifyIcon) then
  
    -- アイコンの表示
    if(LioFADRContainer:IsHidden()) then
      LioFADRContainer:SetHidden(false)
    end
    
    if(LioFADR.icon:IsHidden()) then
      LioFADR.icon:SetHidden(false)
    end
    
  end

end


function OnIconMouseUp(self, mouseButton, upInside)

  if mouseButton == 2 and upInside then -- right click
    
    LioFADR.isNeverNotify = true   
    hideIcon()
    
  end

end

function OnIconMouseEnter(icon)
  
  ZO_Tooltips_ShowTextTooltip(icon, BOTTOM, LioFADR.notifyMessage)
  
end

function OnIconMouseExit()
  
  ZO_Tooltips_HideTextTooltip()
  
end

function OnIconMoveStop(icon)
  
  LioFADR.savedVariables.iconPosX = icon:GetLeft()
  LioFADR.savedVariables.iconPosY = icon:GetTop()
  
end

local function createAlertIcon()
  
  local icon = WINDOW_MANAGER:CreateControl(ICON_NAME, LioFADRContainer, CT_TEXTURE)
  LioFADR.icon = icon
  
  icon:SetHidden(true)
  icon:SetMouseEnabled(true)
  icon:SetMovable(true)
  icon:SetTexture(ICON_PATH)
  icon:SetDimensions(ICON_SIZE, ICON_SIZE)
  icon:ClearAnchors()
  icon:SetParent(LioFADRContainer)
  icon:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, LioFADR.savedVariables.iconPosX, LioFADR.savedVariables.iconPosY)
  icon:SetDrawLayer(1)

  icon:SetHandler("OnMouseUp", function(self, mouseButton, upInside) OnIconMouseUp(self, mouseButton, upInside) end)
  icon:SetHandler("OnMouseEnter", function() OnIconMouseEnter(icon) end)
  icon:SetHandler("OnMouseExit", function() OnIconMouseExit() end)
  icon:SetHandler("OnMoveStop", function() OnIconMoveStop(icon) end)
  
end


-- チャット欄への出力
local function outputChat(message)

  if(LioFADR.savedVariables.enableToChat) then
    d(DMSG_HEADER .. message)
  end

end

-- 通知
local function notify(message, buffName, icon)

  -- 通知メッセージの保存
  LioFADR.notifyMessage = message
  
  -- アイコン非表示フラグをOFF
  LioFADR.isNeverNotify = false

  -- チャット欄に通知
  outputChat(message)

  -- Vanilla UIに通知
  CENTER_SCREEN_ANNOUNCE:AddMessage(999, CSA_EVENT_COMBINED_TEXT, SOUNDS.AVA_GATE_OPENED, message, buffName, icon, nil, nil, nil, nil, 4420)

  -- 通知時間を保存
  LioFADR.savedVariables.lastNotifyTime = GetTimeStamp()
  
end


-- 残り時間に応じて通知するメッセージを変える
local function buildNotifyMessage(remainSec, buffName)

  if (remainSec >= HOUR_PER_SECS) then
    -- 1時間以上効果がある時は、「残りx時間x分で食事の効果が消えます」

    -- メッセージの作成
    local hours = math.floor(remainSec / HOUR_PER_SECS)
    local mins = math.floor((remainSec % HOUR_PER_SECS) / MIN_PER_SECS)

    return zo_strformat(GetString(LIO_FADR_NEAR_EXPIRE_HOUR_MIN), LioFADRCommon.getColoredString(TIME_COLOR, hours), LioFADRCommon.getColoredString(TIME_COLOR, mins))

  end

  if (remainSec >= MIN_PER_SECS) and (remainSec < HOUR_PER_SECS) then
    -- 1分以上1時間未満の効果がある時は、「残りx分で食事の効果が消えます」

    -- メッセージの作成
    local mins = math.floor(remainSec / MIN_PER_SECS)
    return zo_strformat(GetString(LIO_FADR_NEAR_EXPIRE_MIN), LioFADRCommon.getColoredString(TIME_COLOR, mins))

  end

  if (remainSec > 0) and (remainSec < MIN_PER_SECS) then
    -- 1分未満の効果がある時は、「食事の効果がまもなく消えます」
    return LioFADRCommon.getColoredString(ATTENTION_COLOR, GetString(LIO_FADR_NEAR_EXPIRE_CLOSED))

  else
    -- 食事の効果が切れました！
    -- 連続で通知しないように、通知済みテーブルに追加と削除
    LioFADRCommon.insertTable(LioFADR.notifyExpired, EXPIRED_DUMMY_ID)
    
    return LioFADRCommon.getColoredString(ATTENTION_COLOR, GetString(LIO_FADR_NEAR_EXPIRED))

  end

end


-- 残り時間を通知
local function notifyRemainTime(remainSec, abilityId)

  local buffName = GetAbilityName(abilityId)
  local buffIcon = GetAbilityIcon(abilityId)

  if (remainSec <= LioFADR.savedVariables.notifyThresholdMins * 60) and (not LioFADRCommon.isContain(abilityId, LioFADR.notifyRemain)) then
    -- 残り時間が指定時間以下になったら通知する

    LioFADRCommon.insertTable(LioFADR.notifyFirst, abilityId)

    -- 通知
    notify(buildNotifyMessage(remainSec, buffName), buffName, buffIcon)

    -- 通知済みテーブルに追加と削除
    LioFADRCommon.insertTable(LioFADR.notifyRemain, abilityId)

  elseif (remainSec < THRESHOLD_EXPIRE_SECS) and (not LioFADRCommon.isContain(abilityId, LioFADR.notifyClosed)) then
    -- 60秒を切ったら最終通知

    LioFADRCommon.insertTable(LioFADR.notifyFirst, abilityId)

    -- 通知
    notify(buildNotifyMessage(remainSec, buffName), buffName, buffIcon)

    -- 通知済みテーブルに追加と削除
    LioFADRCommon.insertTable(LioFADR.notifyClosed, abilityId)

  elseif (LioFADRCommon.getTableLength(LioFADR.notifyFirst) == 0) then
    -- 最初に必ず通知

    LioFADRCommon.insertTable(LioFADR.notifyFirst, abilityId)

    -- 通知
    notify(buildNotifyMessage(remainSec, buffName), buffName, buffIcon)

  end

end


-- 残り時間が延長されたバフがある場合は通知していないことにする
local function extendRemainTime(remainSec, abilityId)

  local notifyThresholdSecs = LioFADR.savedVariables.notifyThresholdMins * 60
  if (remainSec >= notifyThresholdSecs) and LioFADRCommon.isContain(abilityId, LioFADR.notifyRemain) then
    LioFADRCommon.removeFromTable(LioFADR.notifyRemain, abilityId)
  end

  if (remainSec >= notifyThresholdSecs) and LioFADRCommon.isContain(abilityId, LioFADR.notifyClosed) then
    LioFADRCommon.removeFromTable(LioFADR.notifyClosed, abilityId)
  end

end


-- 効果が切れたアビリティの通知
local function notifyExpiredBuffs(currentBuffs)

  local expiredBuffs = {}

  for _, id in pairs(LioFADR.notifyFirst) do

    -- 現在のバフ一覧に入っていないものはもうバフが切れているので、期限切れ一覧に追加
    if (not LioFADRCommon.isContain(id, currentBuffs)) and (not LioFADRCommon.isContain(id, expiredBuffs)) then
      LioFADRCommon.insertTable(expiredBuffs, id)
    end

  end

  for _, id in pairs(LioFADR.notifyRemain) do

    -- 現在のバフ一覧に入っていないものはもうバフが切れているので、期限切れ一覧に追加
    if (not LioFADRCommon.isContain(id, currentBuffs)) and (not LioFADRCommon.isContain(id, expiredBuffs)) then
      LioFADRCommon.insertTable(expiredBuffs, id)
    end

  end

  for _, id in pairs(LioFADR.notifyClosed) do

    -- 現在のバフ一覧に入っていないものはもうバフが切れているので、期限切れ一覧に追加
    if (not LioFADRCommon.isContain(id, currentBuffs)) and (not LioFADRCommon.isContain(id, expiredBuffs)) then
      LioFADRCommon.insertTable(expiredBuffs, id)
    end

  end

  -- 効果が切れたバフの一覧
  for _, id in pairs(expiredBuffs) do

    -- バフ一覧から削除
    LioFADRCommon.removeFromTable(LioFADR.notifyFirst, id)
    LioFADRCommon.removeFromTable(LioFADR.notifyRemain, id)
    LioFADRCommon.removeFromTable(LioFADR.notifyClosed, id)

    -- 通知
    local buffName = GetAbilityName(id)
    local buffIcon = GetAbilityIcon(id)
    notify(buildNotifyMessage(0, buffName), buffName, buffIcon)
    
    -- 食事切れアイコンの表示
    showIcon()
    
  end

end


-- show / hide icon
local function setIconVisibility()
  
  if(((LioFADRCommon.getTableLength(LioFADR.notifyRemain) > 0) or 
     (LioFADRCommon.getTableLength(LioFADR.notifyClosed) > 0) or
     (LioFADRCommon.getTableLength(LioFADR.notifyExpired)> 0)) and
     not LioFADR.isNeverNotify) then
    
    showIcon()
    
  else
    
    hideIcon()
  end
  
end


-- Scan buffs
local function scanBuffs()

  -- 「食べ物」と「飲み物」の効果があるかどうかのチェック
  local buffsNum = GetNumBuffs(PLAYER_TAG)
  local currentBuffs = {}
  local notifyIntervalSec = 1

  -- 不具合報告用
  if(LioFADR.savedVariables.debug) then
    d(DMSG_HEADER .. "(debug) Time = "..GetTimeStamp())
  end

  -- 現在のバフ数ループ
  for i = 1, buffsNum do

    -- バフを1つずつ取り出す
    local buffName, 
    timeStarted, 
    timeEnding, 
    buffSlot, 
    stackCount, 
    iconFilename, 
    buffType, 
    effectType, 
    abilityType, 
    statusEffectType, 
    abilityId, 
    canClickOff = GetUnitBuffInfo(PLAYER_TAG, i)

    -- 不具合報告用
    if(LioFADR.savedVariables.debug) then
      d(DMSG_HEADER .. "(debug) AbilityId = "..abilityId..", Buff's name = "..buffName)
    end

    -- 有効なバフかどうかのチェック
    if(LioFADRFoods.isContain(abilityId)) then

      -- Expired通知の削除
      if(LioFADRCommon.isContain(EXPIRED_DUMMY_ID, LioFADR.notifyExpired)) then
        LioFADRCommon.removeFromTable(LioFADR.notifyExpired, EXPIRED_DUMMY_ID)
      end

      -- 現在のバフリストに追加
      LioFADRCommon.insertTable(currentBuffs, abilityId)

      -- 残り時間の算出
      local remainSec = math.floor(timeEnding - (GetGameTimeMilliseconds() / 1000))

      -- 残り時間が延長されたバフがある場合は通知していないことにする
      extendRemainTime(remainSec, abilityId)

      -- 残り時間の通知
      notifyRemainTime(remainSec, abilityId)

    end	

  end

  -- 効果が切れたバフの通知
  notifyExpiredBuffs(currentBuffs)

  -- 効果がない時で、戦闘中でない場合、「食事の効果がありません」のメッセージをVanilla UI上で表示する
  if (LioFADR.savedVariables.enableNotifyAlreadyNone and 
      LioFADRCommon.getTableLength(currentBuffs) == 0) and
      (not IsUnitInCombat(PLAYER_TAG)) and
      (not LioFADRCommon.isContain(EXPIRED_DUMMY_ID, LioFADR.notifyExpired)) then

    -- 通知
    local message = GetString(LIO_FADR_SHOULD_EAT_DRINK)
    
    notify(LioFADRCommon.getColoredString(ATTENTION_COLOR, message), nil, nil)

    -- 通知済みテーブルに追加と削除
    LioFADRCommon.insertTable(LioFADR.notifyExpired, EXPIRED_DUMMY_ID)

  end

  -- アイコンの表示判断
  setIconVisibility()

end

-- Cooldown check
local function isCooldown()
  
  return (GetTimeStamp() < LioFADR.savedVariables.lastNotifyTime + LioFADR.savedVariables.cooldownSec)
  
end


-- Cyclic check
local function onUpdate()

  -- ダンジョンを出入りしたら初回表示を有効にする
  if(IsUnitInDungeon(PLAYER_TAG) and (not LioFADR.savedVariables.isInDungeon)) then
    
    LioFADRCommon.clearTable(LioFADR.notifyFirst)
    LioFADR.savedVariables.isInDungeon = true

  elseif((not IsUnitInDungeon(PLAYER_TAG)) and (LioFADR.savedVariables.isInDungeon)) then
    
    LioFADRCommon.clearTable(LioFADR.notifyFirst)
    LioFADR.savedVariables.isInDungeon = false
  end

  -- ゾーンを移動したら初回表示を有効にする
  if(LioFADR.savedVariables.notifyByZoneChanging and LioFADR.savedVariables.isZoneChanged) then

    if(not isCooldown()) then
      LioFADRCommon.clearTable(LioFADR.notifyFirst)
    end
    
    LioFADR.savedVariables.isZoneChanged = false
  
  end

  if((LioFADR.savedVariables.notifyInDungeon and LioFADR.savedVariables.isInDungeon) or -- ダンジョンで通知するが有効でダンジョン内にいる時
     (not LioFADR.savedVariables.isInDungeon) -- ダンジョン内にいない時
    ) then 

    scanBuffs()

  end

end


-- 通知を有効にする
function LioFADR:setEnable()

    outputChat(GetString(LIO_FADR_ENABLE))
    EVENT_MANAGER:RegisterForUpdate(UPDATE_INTERVAL_REGISTER_NAME, UPDATE_INTERVAL_MSEC, onUpdate)

end


-- 通知を無効にする
function LioFADR:setDisableWithoutUnregister()

    outputChat(GetString(LIO_FADR_DISABLE))

end

function LioFADR:setDisable()

    LioFADR.setDisableWithoutUnregister()
    EVENT_MANAGER:UnregisterForUpdate(UPDATE_INTERVAL_REGISTER_NAME)

end


-- 有効無効スイッチ
function toggleEnable()

  LioFADR.savedVariables.enable = not LioFADR.savedVariables.enable

  -- addon start or not
  if(LioFADR.savedVariables.enable) then
    LioFADR.setEnable()
  else
    LioFADR.setDisable()
  end

end


-- zone changed
function LioFADR:onZoneChanged()
  
  LioFADR.savedVariables.isZoneChanged = true
  
end


-- player activated
local function onPlayerActivated()

  -- unregist event handler
  EVENT_MANAGER:UnregisterForEvent(PLAYER_ACTIVATED_REGISTER_NAME, EVENT_PLAYER_ACTIVATED)

  -- load Menu Settings
  LioFADRMenu.LoadLAM2Panel()

  -- addon start or not
  if(LioFADR.savedVariables.enable) then
    LioFADR.setEnable()
  else
    LioFADR.setDisableWithoutUnregister()
  end

end


local function initializeIcon()
  
  local fragment = ZO_FadeSceneFragment:New(LioFADRContainer, nil, 0)
	HUD_SCENE:AddFragment(fragment)
	HUD_UI_SCENE:AddFragment(fragment)
  
  -- auto hide UI
  HUD_SCENE:RegisterCallback("StateChange", 
    function(oldState, newState)
    
      if(newState == SCENE_SHOWING) then
        LioFADR.isHideScene = false
      end
      
      if(newState == SCENE_HIDDEN) then
        LioFADR.isHideScene = true
      end
      
      -- アイコンの表示判断
      setIconVisibility()

    end
  )
  HUD_UI_SCENE:RegisterCallback("StateChange", 
    function(oldState, newState)
    
      if(newState == SCENE_SHOWING) then
        LioFADR.isHideReticle = true
      end
      
      if(newState == SCENE_HIDDEN) then
        LioFADR.isHideReticle = false
      end
      
      -- アイコンの表示判断
      setIconVisibility()
      
    end
  )
  
  -- craeteIcon
  createAlertIcon()

end


-- OnLoad
local function onLoad(event, addon)

  if(addon ~= LioFADR.name) then
    return
  end

  -- 保存領域の初期化
  initializePrefs()

  -- 警告アイコンの初期化
  initializeIcon()

  -- regist & unregist handler
  EVENT_MANAGER:RegisterForEvent(PLAYER_ACTIVATED_REGISTER_NAME, EVENT_PLAYER_ACTIVATED, onPlayerActivated)  
  EVENT_MANAGER:RegisterForEvent(ZONE_CHANGED_REGISTER_NAME, EVENT_ZONE_CHANGED, LioFADR.onZoneChanged)  
  EVENT_MANAGER:UnregisterForEvent(ADD_ON_LOADED_REGISTER_NAME, EVENT_ADD_ON_LOADED)

end


-- Regist event handler
EVENT_MANAGER:RegisterForEvent(ADD_ON_LOADED_REGISTER_NAME, EVENT_ADD_ON_LOADED, onLoad)
