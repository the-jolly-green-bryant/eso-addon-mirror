TamrielRaces = TamrielRaces or {}
local TR = TamrielRaces

TR.StartPrompt = TR.StartPrompt or {}
local StartPrompt = TR.StartPrompt

local ACCEPT_TEXT = "START RACE"
local HOLD_TEXT = "HOLD"
local HOLD_LABEL_NAME = "TamrielRacesStartPromptHoldLabel"

function StartPrompt:GetInteractionType()
    return TR.Config.startPromptInteractionType or "TAMRIEL_RACES_START_RACE"
end

function StartPrompt:IsGamepadAvailable()
    if type(IsInGamepadPreferredMode) == "function" then
        return IsInGamepadPreferredMode() == true
    end
    if type(ZO_IsConsoleOrGameCoreUI) == "function" then
        return ZO_IsConsoleOrGameCoreUI() == true
    end
    return false
end

function StartPrompt:IsEligible()
    local state = TR.State
    if type(state) ~= "table" then return false end

    local hasStartFocus = TR.CheckpointReferee
        and type(TR.CheckpointReferee.IsExpectedWayshrineInteraction) == "function"
        and TR.CheckpointReferee:IsExpectedWayshrineInteraction() == true

    return self:IsGamepadAvailable()
        and state.routeCreated == true
        and state.waitingAtStart == true
        and state.startReady == true
        and state.running ~= true
        and state.countdownActive ~= true
        and state.routeInvalid ~= true
        and hasStartFocus
end

function StartPrompt:IsQueued()
    return PLAYER_TO_PLAYER
        and type(PLAYER_TO_PLAYER.ExistsInQueue) == "function"
        and PLAYER_TO_PLAYER:ExistsInQueue(self:GetInteractionType()) == true
end

function StartPrompt:IsActiveQueueEntry()
    local queue = PLAYER_TO_PLAYER and PLAYER_TO_PLAYER.incomingQueue
    local entry = type(queue) == "table" and queue[1] or nil
    return entry ~= nil
        and entry.incomingType == self:GetInteractionType()
        and entry.pendingResponse ~= false
end

function StartPrompt:GetActionButton()
    return PLAYER_TO_PLAYER and PLAYER_TO_PLAYER.actionKeybindButton or nil
end

function StartPrompt:EnsureHoldLabel()
    local button = self:GetActionButton()
    if not button or not WINDOW_MANAGER or not CT_LABEL then return nil end
    if not button.keyLabel then return nil end

    if self.holdLabel then return self.holdLabel end

    local label = _G[HOLD_LABEL_NAME]
    if not label then
        label = WINDOW_MANAGER:CreateControl(HOLD_LABEL_NAME, button, CT_LABEL)
        label:SetFont("ZoFontGamepad34")
        label:SetDimensions(100, 40)
        label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        label:SetAnchor(RIGHT, button.keyLabel, LEFT, -10, 0)
        label:SetText(HOLD_TEXT)
        if ZO_SELECTED_TEXT and type(ZO_SELECTED_TEXT.UnpackRGBA) == "function" then
            label:SetColor(ZO_SELECTED_TEXT:UnpackRGBA())
        end
        label:SetHidden(true)
    end

    self.holdLabel = label
    return label
end

function StartPrompt:SetHoldLabelVisible(visible)
    local label = self:EnsureHoldLabel()
    if label then
        label:SetHidden(visible ~= true)
    end
end

function StartPrompt:RefreshHoldLabel()
    self:SetHoldLabelVisible(self:IsEligible() and self:IsActiveQueueEntry())
end

function StartPrompt:Remove()
    self:SetHoldLabelVisible(false)

    if not PLAYER_TO_PLAYER or type(PLAYER_TO_PLAYER.RemoveFromIncomingQueue) ~= "function" then
        self.promptData = nil
        return false
    end

    PLAYER_TO_PLAYER:RemoveFromIncomingQueue(self:GetInteractionType())
    self.promptData = nil
    return true
end

function StartPrompt:Add()
    if self:IsQueued() then
        self:RefreshHoldLabel()
        return true
    end
    if not PLAYER_TO_PLAYER or type(PLAYER_TO_PLAYER.AddPromptToIncomingQueue) ~= "function" then
        return false
    end

    local function AcceptStartRace()
        local ok, reason = TR.StartSequence:StartRace()
        if not ok then
            TR.Diagnostics:Warn("Hold Options start rejected: " .. tostring(reason or "unknown reason"))
            if zo_callLater then
                zo_callLater(function() StartPrompt:Refresh() end, 0)
            else
                StartPrompt:Refresh()
            end
        end
    end

    -- A single accept callback makes ESO use its native gamepad
    -- PLAYER_TO_PLAYER_INTERACT control: Hold Options on PlayStation.
    local promptData = PLAYER_TO_PLAYER:AddPromptToIncomingQueue(
        self:GetInteractionType(),
        nil,
        nil,
        nil,
        AcceptStartRace
    )

    if not promptData then return false end
    promptData.acceptText = ACCEPT_TEXT
    self.promptData = promptData

    if zo_callLater then
        zo_callLater(function() StartPrompt:RefreshHoldLabel() end, 0)
    else
        self:RefreshHoldLabel()
    end

    TR.Diagnostics:Log("Native Hold Options start prompt queued")
    return true
end

function StartPrompt:Refresh()
    if self:IsEligible() then
        self:Add()
        self:RefreshHoldLabel()
    else
        self:Remove()
    end
end

function StartPrompt:Initialize()
    self:Refresh()
end

function StartPrompt:OnRouteCreated()
    self:Refresh()
end

function StartPrompt:OnStartReadinessChanged()
    self:Refresh()
end

function StartPrompt:OnRaceTick()
    if TR.State.waitingAtStart or self:IsQueued() or self.holdLabel then
        self:Refresh()
    end
end

function StartPrompt:OnCountdownStarted()
    self:Remove()
end

function StartPrompt:OnRaceStarted()
    self:Remove()
end

function StartPrompt:OnRaceFinished()
    self:Remove()
end

function StartPrompt:ShutdownRace()
    self:Remove()
end

TR.Controller:RegisterModule("StartPrompt", StartPrompt)
