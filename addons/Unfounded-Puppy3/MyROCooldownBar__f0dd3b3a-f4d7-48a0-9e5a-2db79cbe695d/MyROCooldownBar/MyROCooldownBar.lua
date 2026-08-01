local ADDON_NAME = "MyROCooldownBar"

------------------------------------------------------------
-- 設定
------------------------------------------------------------
local TOTAL_CD   = 22
local BAR_WIDTH  = 300
local BAR_HEIGHT = 24
local BAR_GAP    = 4

local MODE_FULL = 1
local MODE_RO   = 2

local RO_MERGE_WINDOW = 0.5

local saved = nil

------------------------------------------------------------
-- FULLモード用
------------------------------------------------------------
local unitBars = {}

------------------------------------------------------------
-- ROモード用
------------------------------------------------------------
local roBars = {}
local nextROBar = 1
local lastROTrigger = 0

------------------------------------------------------------
-- group判定
------------------------------------------------------------
local function IsGroupUnit(unitTag)
    return unitTag and string.find(unitTag, "group") ~= nil
end

------------------------------------------------------------
-- 名前整形
------------------------------------------------------------
local function CleanName(name)
    return name:gsub("%^.*", "")
end

------------------------------------------------------------
-- FULLモード バー整列
------------------------------------------------------------
local function ReanchorBars()

    local baseX = saved.x or 600
    local baseY = saved.y or 250

    local keys = {}

    for cleanName, state in pairs(unitBars) do
        if not state.ui:IsHidden() then
            table.insert(keys, cleanName)
        end
    end

    table.sort(keys)

    local i = 1
    for _, cleanName in ipairs(keys) do
        local state = unitBars[cleanName]
        local offsetY = (i - 1) * (BAR_HEIGHT + BAR_GAP)

        state.ui:SetHidden(true)
        state.ui:ClearAnchors()
        state.ui:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, baseX, baseY + offsetY)
        state.ui:SetHidden(false)

        i = i + 1
    end
end

------------------------------------------------------------
-- FULLモード バー生成
------------------------------------------------------------
local function CreateUnitBar(cleanName)

    local safeName = cleanName:gsub("%W", "_")
    local uiName = "MyROCooldownBar_UI_" .. safeName

    local ui = WINDOW_MANAGER:CreateTopLevelWindow(uiName)
    ui:SetDimensions(BAR_WIDTH, BAR_HEIGHT)
    ui:SetDrawLayer(DL_OVERLAY)
    ui:SetMouseEnabled(false)
    ui:SetMovable(false)
    ui:SetClampedToScreen(true)
    ui:SetHidden(true)

    local bar = WINDOW_MANAGER:CreateControl(nil, ui, CT_STATUSBAR)
    bar:SetDimensions(BAR_WIDTH, BAR_HEIGHT)
    bar:SetAnchor(RIGHT, ui, RIGHT, 0, 0)
    bar:SetBarAlignment(1)
    bar:SetColor(0, 0, 0, 0)
    bar:SetAlpha(0)
    bar:SetHidden(true)

    local label = WINDOW_MANAGER:CreateControl(nil, ui, CT_LABEL)
    label:SetAnchor(CENTER, ui, CENTER, 0, 0)
    label:SetFont("$(BOLD_FONT)|18|soft-shadow-thick")
    label:SetColor(1, 1, 1, 1)
    label:SetHidden(true)

    local state = {
        ui          = ui,
        bar         = bar,
        label       = label,
        cleanName   = cleanName,
        phase       = 0,
        roStart     = 0,
        redDuration = 0,
        blueDuration= 0,
        blinkState  = false,
        lastBlink   = 0,
    }

    unitBars[cleanName] = state
    return state
end

local function GetOrCreateUnitBar(cleanName)
    return unitBars[cleanName] or CreateUnitBar(cleanName)
end

------------------------------------------------------------
-- FULLモード 非表示
------------------------------------------------------------
local function HideUnitBar(cleanName)
    local state = unitBars[cleanName]
    if not state then return end

    state.ui:SetHidden(true)
    state.phase = 0

    zo_callLater(ReanchorBars, 10)
end

------------------------------------------------------------
-- ROモード バー生成（透明化）
------------------------------------------------------------
local function CreateROBar(index)

    local ui = WINDOW_MANAGER:CreateTopLevelWindow("MyROCooldownBar_RO_" .. index)
    ui:SetDimensions(BAR_WIDTH, BAR_HEIGHT)
    ui:SetDrawLayer(DL_OVERLAY)
    ui:SetHidden(true)

    local bar = WINDOW_MANAGER:CreateControl(nil, ui, CT_STATUSBAR)
    bar:SetDimensions(BAR_WIDTH, BAR_HEIGHT)
    bar:SetAnchor(RIGHT, ui, RIGHT, 0, 0)
    bar:SetBarAlignment(1)
    bar:SetColor(0, 0, 0, 0)
    bar:SetAlpha(0)

    local label = WINDOW_MANAGER:CreateControl(nil, ui, CT_LABEL)
    label:SetAnchor(CENTER, ui, CENTER, 0, 0)
    label:SetFont("$(BOLD_FONT)|18|soft-shadow-thick")

    local state = {
        ui = ui,
        bar = bar,
        label = label,
        phase = 0,
        redDuration = 0,
        blueDuration = 0,
        roStart = 0,
        blinkState = false,
        lastBlink = 0,
        active = false,
    }

    roBars[index] = state
end

------------------------------------------------------------
-- ROモード配置
------------------------------------------------------------
local function ReanchorROBars()

    local baseX = saved.x or 600
    local baseY = saved.y or 250

    for i = 1, 2 do
        local state = roBars[i]

        state.ui:SetHidden(true)
        state.ui:ClearAnchors()
        state.ui:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, baseX, baseY + (i - 1) * (BAR_HEIGHT + BAR_GAP))
        state.ui:SetHidden(false)
    end
end

------------------------------------------------------------
-- ROバー開始（赤フェーズで開始）
------------------------------------------------------------
local function StartROBar(index, duration)

    local state = roBars[index]

    state.active = true
    state.phase = 1
    state.redDuration = duration
    state.blueDuration = TOTAL_CD - duration
    if state.blueDuration < 0 then state.blueDuration = 0 end

    state.roStart = GetGameTimeSeconds()
    state.blinkState = false
    state.lastBlink = state.roStart

    state.bar:SetColor(1, 0.2, 0.2, 1)
    state.bar:SetAlpha(1)
    state.bar:SetDimensions(BAR_WIDTH, BAR_HEIGHT)

    state.label:SetText("好機" .. index .. " 殺戮(強)")

    state.ui:SetHidden(false)
end

------------------------------------------------------------
-- Update（FULL = 1.0 / RO = 赤→青フェーズ追加）
------------------------------------------------------------
local function OnUpdate(_, currentFrameTime)

    local now = GetGameTimeSeconds()

    --------------------------------------------------------
    -- FULLモード
    --------------------------------------------------------
    if saved.mode == MODE_FULL then

        for cleanName, state in pairs(unitBars) do

            if state.phase == 1 then

                local elapsed = now - state.roStart
                if elapsed >= state.redDuration then

                    state.phase = 2
                    state.roStart = now

                    state.bar:SetColor(0.2, 0.5, 1, 1)
                    state.bar:SetAlpha(1)
                    state.label:SetText(state.cleanName .. " クールタイム")

                else
                    local remain = state.redDuration - elapsed
                    state.bar:SetDimensions(BAR_WIDTH * (remain / state.redDuration), BAR_HEIGHT)
                end

            elseif state.phase == 2 then

                local elapsed = now - state.roStart
                if elapsed >= state.blueDuration then

                    HideUnitBar(cleanName)

                else
                    local remain = state.blueDuration - elapsed
                    state.bar:SetDimensions(BAR_WIDTH * (remain / state.blueDuration), BAR_HEIGHT)

                    if remain <= 2 then
                        if now - state.lastBlink >= 0.2 then
                            state.blinkState = not state.blinkState
                            state.bar:SetAlpha(state.blinkState and 1 or 0.3)
                            state.lastBlink = now
                        end
                    else
                        state.bar:SetAlpha(1)
                    end
                end
            end
        end

    --------------------------------------------------------
    -- ROモード（赤→青フェーズ追加）
    --------------------------------------------------------
    else

        for i = 1, 2 do
            local state = roBars[i]

            if state.active then

                if state.phase == 1 then
                    local elapsed = now - state.roStart

                    if elapsed >= state.redDuration then
                        state.phase = 2
                        state.roStart = now

                        state.bar:SetColor(0.2, 0.5, 1, 1)
                        state.bar:SetAlpha(1)
                        state.label:SetText("好機" .. i .. " クールタイム")

                    else
                        local remain = state.redDuration - elapsed
                        state.bar:SetDimensions(BAR_WIDTH * (remain / state.redDuration), BAR_HEIGHT)
                    end

                elseif state.phase == 2 then
                    local elapsed = now - state.roStart

                    if elapsed >= state.blueDuration then
                        state.active = false
                        state.phase = 0
                        state.ui:SetHidden(true)
                        state.bar:SetAlpha(0)
                        state.bar:SetColor(0, 0, 0, 0)
                        state.bar:SetDimensions(BAR_WIDTH, BAR_HEIGHT)
                        state.blinkState = false

                    else
                        local remain = state.blueDuration - elapsed
                        state.bar:SetDimensions(BAR_WIDTH * (remain / state.blueDuration), BAR_HEIGHT)

                        if remain <= 2 then
                            if now - state.lastBlink >= 0.2 then
                                state.blinkState = not state.blinkState
                                state.bar:SetAlpha(state.blinkState and 1 or 0.3)
                                state.lastBlink = now
                            end
                        else
                            state.bar:SetAlpha(1)
                        end
                    end
                end
            end
        end
    end
end

------------------------------------------------------------
-- Effect Changed（FULL = 1.0 / RO = 赤→青フェーズ追加）
------------------------------------------------------------
local function OnEffectChanged(
    eventCode,
    changeType,
    effectSlot,
    effectName,
    unitTag,
    beginTimeRaw,
    endTime,
    stackCountRaw,
    iconName,
    deprecatedBuffType,
    effectType,
    abilityType,
    statusEffectType,
    unitNameRaw,
    unitIdRaw,
    abilityId,
    sourceType
)

    if effectName ~= "殺戮(強)" then return end
    if not IsGroupUnit(unitTag) then return end

    local now = GetGameTimeSeconds()
    local duration = endTime - now
    if duration <= 0 then return end

    --------------------------------------------------------
    -- ROモード（赤フェーズで開始）
    --------------------------------------------------------
    if saved.mode == MODE_RO then

        if (now - lastROTrigger) < RO_MERGE_WINDOW then
            return
        end

        lastROTrigger = now

        StartROBar(nextROBar, duration)

        nextROBar = nextROBar + 1
        if nextROBar > 2 then nextROBar = 1 end

        return
    end

    --------------------------------------------------------
    -- FULLモード
    --------------------------------------------------------
    local cleanName = CleanName(unitNameRaw)
    local state = GetOrCreateUnitBar(cleanName)

    state.redDuration  = duration
    state.blueDuration = TOTAL_CD - duration
    if state.blueDuration < 0 then state.blueDuration = 0 end

    state.phase   = 1
    state.roStart = now
    state.blinkState = false
    state.lastBlink  = now

    state.bar:SetColor(1, 0.2, 0.2, 1)
    state.bar:SetAlpha(1)
    state.bar:SetDimensions(BAR_WIDTH, BAR_HEIGHT)

    state.label:SetText(state.cleanName .. " 殺戮(強)")
    state.label:SetHidden(false)

    state.ui:SetHidden(false)
    state.bar:SetHidden(false)

    zo_callLater(ReanchorBars, 10)
end

------------------------------------------------------------
-- /romode
------------------------------------------------------------
local function Slash_ROMode(arg)

    arg = zo_strlower(arg or "")

    if arg == "full" then
        saved.mode = MODE_FULL
        d("MyROCooldownBar : FULLモード")

    elseif arg == "ro" then
        saved.mode = MODE_RO
        d("MyROCooldownBar : 好機モード")

    else
        d("/romode full")
        d("/romode ro")
    end
end

------------------------------------------------------------
-- /ropos
------------------------------------------------------------
local function Slash_ROPos(arg)

    local x, y = arg:match("^(%d+)%s+(%d+)$")

    if x and y then
        saved.x = tonumber(x)
        saved.y = tonumber(y)

        zo_callLater(ReanchorBars, 10)
        zo_callLater(ReanchorROBars, 10)

        d(string.format("位置変更 X=%d Y=%d", saved.x, saved.y))
    end
end

------------------------------------------------------------
-- 初期化
------------------------------------------------------------
local function Initialize()

    saved = ZO_SavedVars:NewAccountWide(
        "MyROCooldownBar_Saved",
        1,
        nil,
        {
            x = 600,
            y = 250,
            mode = MODE_RO
        }
    )

    CreateROBar(1)
    CreateROBar(2)

    ReanchorROBars()

    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME .. "_Effect",
        EVENT_EFFECT_CHANGED,
        OnEffectChanged
    )

    EVENT_MANAGER:RegisterForUpdate(
        ADDON_NAME .. "_Update",
        50,
        OnUpdate
    )

    SLASH_COMMANDS["/romode"] = Slash_ROMode
    SLASH_COMMANDS["/ropos"]  = Slash_ROPos

    d("MyROCooldownBar Loaded")
end

------------------------------------------------------------
-- AddOn Loaded
------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(
    ADDON_NAME,
    EVENT_ADD_ON_LOADED,
    function(_, addonName)
        if addonName == ADDON_NAME then
            Initialize()
        end
    end
)
