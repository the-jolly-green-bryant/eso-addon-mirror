local ADDON_NAME = "MyCrystalFragmentsProcUI"

MyCrystalFragmentsProcUI = MyCrystalFragmentsProcUI or {}

------------------------------------------------------------
-- 監視する Ability ID
------------------------------------------------------------
local WATCH_LIST = {
    [203447] = true, -- Bound Armaments Proc
    [23231] = true, -- Hurricane
    [46327] = true, -- Crystal Fragments Ready
}

------------------------------------------------------------
-- 中央アイコン設定
------------------------------------------------------------
local ICON_SIZE = 90
local DISPLAY_TIME = 800 -- ms

------------------------------------------------------------
-- Bound Armaments の前回スタック数
------------------------------------------------------------
local lastBoundArmamentsStacks = 0

------------------------------------------------------------
-- 中央アイコン UI
------------------------------------------------------------
local centerIcon = nil

------------------------------------------------------------
-- 通知番号（古い通知が新しい通知を消さないように）
------------------------------------------------------------
local notificationSerial = 0


------------------------------------------------------------
-- UI作成
------------------------------------------------------------
local function CreateUI()

    local ui = WINDOW_MANAGER:CreateTopLevelWindow("MyCrystalFragmentsProcUI_CenterIcon")

    ui:SetDimensions(ICON_SIZE, ICON_SIZE)

    --------------------------------------------------------
    -- 画面中央
    --------------------------------------------------------
    ui:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)

    --------------------------------------------------------
    -- 最前面に近いレイヤー
    --------------------------------------------------------
    ui:SetDrawLayer(DL_OVERLAY)

    --------------------------------------------------------
    -- ★ 旧バージョンと同じ：親ウィンドウは常に表示
    --------------------------------------------------------
    ui:SetHidden(false)

    --------------------------------------------------------
    -- アイコン（子）
    --------------------------------------------------------
    local icon = WINDOW_MANAGER:CreateControl(
        "MyCrystalFragmentsProcUI_CenterIconTexture",
        ui,
        CT_TEXTURE
    )

    icon:SetDimensions(ICON_SIZE, ICON_SIZE)
    icon:SetAnchorFill(ui)
    icon:SetHidden(true)

    --------------------------------------------------------
    -- 描画対象は icon（CT_TEXTURE）
    --------------------------------------------------------
    centerIcon = icon
end


------------------------------------------------------------
-- 中央アイコン表示
------------------------------------------------------------
local function ShowCenterIcon(iconTexture)

    if not centerIcon then return end

    --------------------------------------------------------
    -- iconTexture が nil / 空 / 非文字列なら無視
    --------------------------------------------------------
    if not iconTexture or type(iconTexture) ~= "string" or iconTexture == "" then
        return
    end

    notificationSerial = notificationSerial + 1
    local serial = notificationSerial

    centerIcon:SetTexture(iconTexture)
    centerIcon:SetAlpha(1)
    centerIcon:SetHidden(false)

    --------------------------------------------------------
    -- DISPLAY_TIME 後に消す
    --------------------------------------------------------
    zo_callLater(function()
        if serial ~= notificationSerial then
            return
        end
        centerIcon:SetHidden(true)
    end, DISPLAY_TIME)
end


------------------------------------------------------------
-- EVENT_EFFECT_CHANGED
------------------------------------------------------------
local function OnEffectChanged(
    eventCode,
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
    sourceType
)

    --------------------------------------------------------
    -- 監視対象以外は無視
    --------------------------------------------------------
    if not WATCH_LIST[abilityId] then return end

    --------------------------------------------------------
    -- プレイヤー自身のみ
    --------------------------------------------------------
    if unitTag ~= "player" then return end


    --------------------------------------------------------
    -- Bound Armaments Proc（203447）
    --------------------------------------------------------
    if abilityId == 203447 then

        local stacks = stackCount or 0

        -- バフ消滅
        if changeType == EFFECT_RESULT_FADED then
            lastBoundArmamentsStacks = 0
            return
        end

        -- 3 → 4 の瞬間だけ通知
        if stacks >= 4 and lastBoundArmamentsStacks < 4 then
            ShowCenterIcon(iconName)
        end

        lastBoundArmamentsStacks = stacks
        return
    end


    --------------------------------------------------------
    -- Hurricane（23231）
    -- バフが切れた瞬間に通知
    --------------------------------------------------------
    if abilityId == 23231 then
        if changeType == EFFECT_RESULT_FADED then
            ShowCenterIcon(iconName)
        end
        return
    end


    --------------------------------------------------------
    -- Crystal Fragments Ready（46327）
    -- Proc 発生時に通知
    --------------------------------------------------------
    if abilityId == 46327 then
        if changeType == EFFECT_RESULT_GAINED then
            ShowCenterIcon(iconName)
        end
        return
    end
end


------------------------------------------------------------
-- AddOn Loaded
------------------------------------------------------------
local function OnAddOnLoaded(eventCode, addonName)

    if addonName ~= ADDON_NAME then return end

    CreateUI()

    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME,
        EVENT_EFFECT_CHANGED,
        OnEffectChanged
    )

    lastBoundArmamentsStacks = 0
    notificationSerial = 0

    d("MyCrystalFragmentsProcUI Loaded")
end


------------------------------------------------------------
-- AddOn Loaded 登録
------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(
    ADDON_NAME,
    EVENT_ADD_ON_LOADED,
    OnAddOnLoaded
)
