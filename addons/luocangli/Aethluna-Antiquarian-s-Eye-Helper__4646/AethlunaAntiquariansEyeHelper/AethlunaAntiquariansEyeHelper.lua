local ADDON_NAME = "AethlunaAntiquariansEyeHelper"

local ShortcutBtnParams = {
    point = 128,
    relativePoint = 128,
    offsetX = 0,
    offsetY = 0,
}

AethlunaAntiquariansEyeHelper = {
    info = {
        version = "1.1.1",
        author = "Aethluna",
        addonName = ADDON_NAME,
        displayName = "Aethluna Antiquarian's Eye Helper",
        website = "https://www.esoui.com/downloads/info4646-AethlunaAntiquariansEyeHelper.html#info",
    },

    params = {
        eyeID = nil,
        savedVarsName = "AAEH_SavedVariables",
        savedVarsVersion = 1,
    },

    state = {
        isUIBlocked = false,
        isUpdateActive = false,
        isLastInZone = nil,
        isCooldownEnded = false,
        isInZone = nil,
    },

    defaultSettings = {
        updateInterval = 100,
        isDragEnabled = true,
        isZoneMsgEnabled = true,
        isCDMsgEnabled = true,
        eyeBtnParams = ShortcutBtnParams,
    },
}

local aaeh = AethlunaAntiquariansEyeHelper

--------------------------------------------------
-- 初始化
--------------------------------------------------

function AethlunaAntiquariansEyeHelper:Initialize()
    local worldName = GetWorldName()

    self.settings =
        ZO_SavedVars:NewAccountWide(
            self.params.savedVarsName,
            self.params.savedVarsVersion,
            nil,
            self.defaultSettings,
            worldName
        )

    self.params.eyeID = GetAntiquityScryingToolCollectibleId()

    self.button = WINDOW_MANAGER:GetControlByName("AAEH_Button")
    self.icon   = WINDOW_MANAGER:GetControlByName("AAEH_ButtonIcon")
    self.timer  = WINDOW_MANAGER:GetControlByName("AAEH_ButtonTimer")

    self:ApplyDragState(self.settings.isDragEnabled)

    self.timer:SetFont("ZoFontGameLargeBold")

    self:SetLanguage()
    self:SetupIcon()
    self:RegisterHandlers()
    self:RegisterUIHooks()
    self:RegisterSlashCommands()
    self:RegisterSettings()

    zo_callLater(function()
        self:RestorePosition()
    end, 100)
end


--------------------------------------------------
-- 多语言本地化
--------------------------------------------------

function AethlunaAntiquariansEyeHelper:SetLanguage()
    local lang = GetCVar("language.2")
    local strings = AAEH_STRINGS[lang]
    if not strings then
        strings = AAEH_STRINGS.en
    end
    for k, v in pairs(strings) do
        ZO_CreateStringId(k, v)
    end
end

--------------------------------------------------
-- 统一使用入口
--------------------------------------------------

function AethlunaAntiquariansEyeHelper:HandleUseEye()

    if not self.params.eyeID then return end
    if self.state.isUIBlocked then return end
    if not self:IsInAntiquityMode() then return end

    UseCollectible(self.params.eyeID)
end

function AethlunaAntiquariansEyeHelper:KeybindUseEye()
    aaeh:HandleUseEye()
end

--------------------------------------------------
-- UI控制
--------------------------------------------------
function AethlunaAntiquariansEyeHelper:ShouldShow()
    return (not self.state.isUIBlocked) and self:IsInAntiquityMode()
end

function AethlunaAntiquariansEyeHelper:ApplyUIState()
    if not self.button then return end
    self.button:SetHidden(not self:ShouldShow())
end

--------------------------------------------------
-- Update控制
--------------------------------------------------

function AethlunaAntiquariansEyeHelper:StartUpdate()
    if self.state.isUpdateActive then return end

    self.state.isUpdateActive = true

    EVENT_MANAGER:RegisterForUpdate(
        ADDON_NAME .. "_Update",
        self.settings.updateInterval,
        function()
            self:Update()
        end
    )
end

function AethlunaAntiquariansEyeHelper:StopUpdate()
    if not self.state.isUpdateActive then return end

    self.state.isUpdateActive = false
    EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_Update")
end

--------------------------------------------------
-- 玩家进入大地图
--------------------------------------------------

function AethlunaAntiquariansEyeHelper:OnPlayerActivated()

    self:ApplyUIState()

    local mapType = GetMapContentType()

    local isAllowed =
        mapType ~= MAP_CONTENT_AVA and
        mapType ~= MAP_CONTENT_BATTLEGROUND and
        mapType ~= MAP_CONTENT_DUNGEON

    if isAllowed then
        self:StartUpdate()
    else
        self:StopUpdate()
        self.state.isUIBlocked = true
        self:ApplyUIState()
    end

    self.state.isInZone = self:IsInAntiquityMode()
    self.state.isLastInZone = self.state.isInZone
end

--------------------------------------------------
-- Slash命令
--------------------------------------------------

function AethlunaAntiquariansEyeHelper:RegisterSlashCommands()

    SLASH_COMMANDS["/aaeh"] = function(msg)

        msg = (msg or ""):lower()

        if msg == "reset" then
            self.button:ClearAnchors()
            self.button:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
            self:SavePosition()
            self:Notify(GetString(SI_AAEH_RESET_MSG))
        end
    end
end

--------------------------------------------------
-- UI Hook
--------------------------------------------------

function AethlunaAntiquariansEyeHelper:RegisterUIHooks()

    local function SetBlocked(state)
        self.state.isUIBlocked = state

        if state then
            self.button:SetHidden(true)
        else
            self:ApplyUIState()
        end
    end

    local hud = SCENE_MANAGER:GetScene("hud")
    if hud then
        hud:RegisterCallback("StateChange", function(_, newState)
            if newState == SCENE_SHOWING then
                SetBlocked(false)
            elseif newState == SCENE_HIDDEN then
                SetBlocked(true)
            end
        end)
    end

    local hudui = SCENE_MANAGER:GetScene("hudui")
    if hudui then
        hudui:RegisterCallback("StateChange", function(_, newState)
            if newState == SCENE_SHOWING then
                SetBlocked(false)
            elseif newState == SCENE_HIDDEN then
                SetBlocked(true)
            end
        end)
    end
end

--------------------------------------------------
-- 通知
--------------------------------------------------

function AethlunaAntiquariansEyeHelper:Notify(msg)
    CHAT_SYSTEM:AddMessage("|c66ccff[" .. GetString(SI_AAEH_ADDON_ABBREVIATION) .. "]|r " .. msg)
end

--------------------------------------------------
-- 判断考古状态
--------------------------------------------------

function AethlunaAntiquariansEyeHelper:IsInAntiquityMode()
    if not self.params.eyeID then return false end
    return not IsCollectibleBlocked(self.params.eyeID)
end

--------------------------------------------------
-- Update
--------------------------------------------------

function AethlunaAntiquariansEyeHelper:Update()

    if self.state.isUIBlocked then return end

    self.state.isInZone = self:IsInAntiquityMode()

    if self.state.isInZone ~= self.state.isLastInZone then
        if self.settings.isZoneMsgEnabled then
            self:Notify(self.state.isInZone and GetString(SI_AAEH_ENTER_ZONE_MSG) or GetString(SI_AAEH_EXIT_ZONE_MSG))
        end
        self.state.isLastInZone = self.state.isInZone
    end

    self:ApplyUIState()

    if self.state.isInZone then
        self:UpdateCooldown()
    end

    self:CheckCooldownEnded()
end

--------------------------------------------------
-- CD结束提示
--------------------------------------------------

function AethlunaAntiquariansEyeHelper:CheckCooldownEnded()

    if not self.params.eyeID then return end

    local remaining, duration = GetCollectibleCooldownAndDuration(self.params.eyeID)

    if remaining and remaining <= 0 then
        if self.state.isLastInZone and not self.state.isCooldownEnded then
            self.state.isCooldownEnded = true

            if self.settings.isCDMsgEnabled then
                self:Notify(GetString(SI_AAEH_EYE_READY_MSG))
            end
        end
    else
        self.state.isCooldownEnded = false
    end
end

--------------------------------------------------
-- 图标
--------------------------------------------------

function AethlunaAntiquariansEyeHelper:SetupIcon()

    local data = ANTIQUITY_MANAGER:GetScryingToolCollectibleData()

    if data and self.icon then
        self.icon:SetTexture(data:GetIcon())
    end
end

--------------------------------------------------
-- 冷却显示
--------------------------------------------------

function AethlunaAntiquariansEyeHelper:UpdateCooldown()

    local remaining, duration = GetCollectibleCooldownAndDuration(self.params.eyeID)

    if remaining and duration and remaining > 0 then

        local seconds = remaining / 1000
        self.timer:SetText(string.format("%.1f", seconds))

        local p = 1 - remaining / duration
        p = math.max(0, math.min(1, p))

        self.icon:SetColor(
            0.3 + p * 0.7,
            0.3 + p * 0.7,
            0.3 + p * 0.7,
            1
        )
    else
        self.timer:SetText("")
        self.icon:SetColor(1, 1, 1, 1)
    end
end

--------------------------------------------------
-- 位置
--------------------------------------------------

function AethlunaAntiquariansEyeHelper:SavePosition()

    local _, point, anchorTargetControl, relativePoint, offsetX, offsetY = self.button:GetAnchor()

    self.settings.eyeBtnParams.point = point
    self.settings.eyeBtnParams.relativePoint = relativePoint
    self.settings.eyeBtnParams.offsetX = offsetX
    self.settings.eyeBtnParams.offsetY = offsetY
end

function AethlunaAntiquariansEyeHelper:RestorePosition()

    self.button:ClearAnchors()

    self.button:SetAnchor(
        self.settings.eyeBtnParams.point or CENTER,
        GuiRoot,
        self.settings.eyeBtnParams.relativePoint or CENTER,
        self.settings.eyeBtnParams.offsetX or 0,
        self.settings.eyeBtnParams.offsetY or 0
    )
end

--------------------------------------------------
-- 鼠标
--------------------------------------------------

function AethlunaAntiquariansEyeHelper:RegisterHandlers()

    self.button:SetHandler("OnMouseDown", function(_, btn)

        if btn == MOUSE_BUTTON_INDEX_LEFT then
            self:HandleUseEye()

        elseif btn == MOUSE_BUTTON_INDEX_RIGHT then
            if self.settings.isDragEnabled then
                self.button:StartMoving()
            else
                self.button:StopMovingOrResizing()
            end
        end
    end)

    self.button:SetHandler("OnMoveStop", function()
        self:SavePosition()
    end)
end

--------------------------------------------------
-- 设置界面
--------------------------------------------------

function AethlunaAntiquariansEyeHelper:RegisterSettings()

    local LAM = LibAddonMenu2

    local panelData = {
        type = "panel",
        name = "Aethluna Antiquarian's Eye Helper",
        displayName = "|c66ccff" .. GetString(SI_AAEH_ADDON_NAME) .. "|r",
        author = "|c66ccff" .. GetString(SI_AAEH_ADDON_AUTHOR) .. "|r",
        version = self.info.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsData = {
        {
            type = "description",
            text = GetString(SI_AAEH_SETTING_ADDON_INTRO),
        },

        {
            type = "header",
            name = GetString(SI_AAEH_SETTING_FUNCTION_SETTING_TITLE),
        },

        {
            type = "slider",
            name = GetString(SI_AAEH_SETTING_UPDATE_INTERVAL),
            min = 50,
            max = 1000,
            step = 10,
            getFunc = function()
                return self.settings.updateInterval
            end,
            setFunc = function(value)
                self:ApplyUpdateInterval(value)
            end,
            default = 100,
        },


        {
            type = "checkbox",
            name = GetString(SI_AAEH_SETTING_EYE_BTN_DRAG_ENABLE),
            getFunc = function()
                return self.settings.isDragEnabled
            end,

            setFunc = function(value)
                self:ApplyDragState(value)
            end,
            default = true,
        },

        {
            type = "checkbox",
            name = GetString(SI_AAEH_SETTING_ZONE_MSG_ENABLE),
            getFunc = function()
                return self.settings.isZoneMsgEnabled
            end,

            setFunc = function(value)
                self.settings.isZoneMsgEnabled = value
            end,
            default = true,
        },


        {
            type = "checkbox",
            name = GetString(SI_AAEH_SETTING_READY_MSG_ENABLE),
            getFunc = function()
                return self.settings.isCDMsgEnabled
            end,

            setFunc = function(value)
                self.settings.isCDMsgEnabled = value
            end,
            default = true,
        },

        {
            type = "header",
            name = GetString(SI_AAEH_SETTING_ADDON_DESC_TITLE),
        },

        {
            type = "description",
            text = GetString(SI_AAEH_SETTING_ADDON_DESC),
        },

        {
            type = "header",
            name = GetString(SI_AAEH_SETTING_COMMAND_TITLE),
        },

        {
            type = "description",
            text = GetString(SI_AAEH_SETTING_COMMAND),
        },
    }

    LAM:RegisterAddonPanel("AAEH_Settings", panelData)
    LAM:RegisterOptionControls("AAEH_Settings", optionsData)
end

--------------------------------------------------
-- 动态更新 interval
--------------------------------------------------

function AethlunaAntiquariansEyeHelper:ApplyUpdateInterval(value)

    value = tonumber(value)
    if not value then return end

    value = math.max(50, math.min(1000, value))

    self.settings.updateInterval = value

    if self.state.isUpdateActive then
        self:StopUpdate()
        self:StartUpdate()
    end

    self:Notify(GetString(SI_AAEH_BUTTON_RESET_MSG) .. value .. "ms")
end

function AethlunaAntiquariansEyeHelper:ApplyDragState(value)
    value = (value == true)

    self.settings.isDragEnabled = value

    self.button:SetMovable(value)

    if not value then
        self.button:StopMovingOrResizing()
    end
end

--------------------------------------------------
-- Keybind string
--------------------------------------------------

ZO_CreateStringId("SI_BINDING_NAME_AAEH_USE_EYE", GetString(SI_BINDING_NAME_AAEH_USE_EYE))

--------------------------------------------------
-- 加载入口
--------------------------------------------------

local function OnLoaded(eventCode, addonName)

    if addonName ~= ADDON_NAME then return end

    aaeh:Initialize()

    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME,
        EVENT_PLAYER_ACTIVATED,
        function()
            aaeh:OnPlayerActivated()
        end
    )

    EVENT_MANAGER:UnregisterForEvent(
        ADDON_NAME,
        EVENT_ADD_ON_LOADED
    )
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnLoaded)