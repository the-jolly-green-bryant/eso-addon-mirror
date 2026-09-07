-- NOT LOADED. The manifest does not list this file, and Bindings.xml no longer declares the layer
-- it needs, so nothing here runs.
--
-- It worked: L2+L3 on the HUD walked the outgoing chat channel, by inheriting binds from
-- UI_SHORTCUT_LEFT_TRIGGER and UI_SHORTCUT_LEFT_STICK and composing the chord in Lua. What it also
-- did was shadow L2 on the HUD, so blocking stopped working -- allowFallthrough="true" with these
-- handlers returning false was not enough to keep the game's own L2 alive underneath.
--
-- Kept whole rather than deleted, because the technique is sound and only the choice of buttons is
-- not. Reviving it means finding buttons the HUD does not need, restoring the layer in
-- Bindings.xml, and putting this file back in the manifest.
--
-- Original note: L2 release detection compensates for missing binding Up events.
local NAME = "PBsChatAssistantHUDChannel"
local HOST_ADDON = "PBsChatAssistant"
local LAYER = "PBsChatAssistantHUDChannelLayer"
-- The interval decides how long the chord stays latched after the trigger is released, and
-- therefore how fast the channel can be walked. ButtonDown samples the trigger itself, so a press
-- is never missed by the loop; what the loop is for is noticing the release, and until it does,
-- the next chord is swallowed.
--
-- 100ms was tried and reported as dropping presses in play -- a tenth of a second between one
-- chord and the next is well within how fast someone cycles through channels. 50ms halves that
-- wait.
--
-- The cost that prompted slowing it down at all is dealt with where it actually was: the label is
-- built only when the channel changes, and the trigger is read only while a press is outstanding.
-- Most ticks do almost nothing however often they run.
local UPDATE_INTERVAL_MS = 50
local channel = { buttons = {} }
PBS_CHAT_ASSISTANT_HUD_CHANNEL = channel

local function GetChat()
    return type(ZO_GetChatSystem) == "function" and ZO_GetChatSystem()
end

local function IsEnabled()
    local addon = PBS_CHAT_ASSISTANT
    return addon and addon.sv and addon.sv.enabled and addon.sv.captureMode == "off"
end

function channel:ResetButtons()
    self.buttons = {}
    self.chordLatched = false
    self.triggerWasDown = false
end

-- Reads the trigger only when there is something to notice.
--
-- The loop is watching for a release, and a release only matters once a press has been seen.
-- ButtonDown samples too, so the press itself is never missed by skipping here: L2's Down handler
-- is what sets triggerWasDown in the first place.
function channel:SampleTrigger(force)
    if self.triggerUnavailable then return end
    if not force and not self.triggerWasDown then return end
    local ok, value = false, nil
    if type(GetGamepadLeftTriggerMagnitude) == "function" then
        ok, value = pcall(GetGamepadLeftTriggerMagnitude)
    end
    if not ok or type(value) ~= "number" or value ~= value or value < 0 or value > 1 then
        self.triggerUnavailable = true
        return
    end
    if value >= 0.5 then
        self.triggerWasDown = true
    elseif value <= 0.1 and self.triggerWasDown then
        self:ResetButtons()
    end
end

function channel:SetActive(active)
    if self.active == active then return end
    self.active = active
    self:ResetButtons()
    if active then
        local ok = pcall(function() self.scene:AddFragment(self.fragment) end)
        if not ok then
            self.failed = true
            self:SetActive(false)
        end
    else
        if self.fragment then self.scene:RemoveFragment(self.fragment) end
        RemoveActionLayerByName(LAYER)
        if self.window then self.window:SetHidden(true) end
    end
end

-- Nothing is built unless the channel actually changed. The old version formatted a string every
-- tick and compared the result, so the allocation happened whether or not the text differed --
-- which on console, where every add-on shares one memory pool, is the kind of per-frame garbage
-- worth not making.
function channel:RefreshLabel(force)
    local chat = GetChat()
    local id = chat and chat.currentChannel

    if id == self.lastChannelId and not force then
        return
    end
    self.lastChannelId = id

    local name = id and type(GetChannelName) == "function" and GetChannelName(id)
    self.label:SetText(string.format(GetString(SI_PBSCHATASSISTANT_CHANNEL_LABEL), tostring(name or id or "--")))
end

function channel:ButtonDown(button)
    if not self.active or not IsEnabled() or not SCENE_MANAGER:IsShowing("hud") then return false end
    self:SampleTrigger(true)
    self.buttons[button] = true
    if self.buttons.L3 and self.buttons.L2 and not self.chordLatched then
        self.chordLatched = true
        local chat = GetChat()
        if chat and type(chat.IsTextEntryOpen) == "function" and not chat:IsTextEntryOpen()
            and not (type(IsVirtualKeyboardOnScreen) == "function" and IsVirtualKeyboardOnScreen()) then
            local ok = pcall(function() PBS_CHAT_ASSISTANT:CycleChannel(1, true) end)
            if ok then
                self:RefreshLabel()
            else
                self.failed = true
                self:SetActive(false)
            end
        end
    end
    return false
end

function channel:ButtonUp(button)
    self.buttons[button] = nil
    if not self.buttons.L3 and not self.buttons.L2 then self.chordLatched = false end
    return false
end

function channel:Update()
    self:SetActive(not self.failed and not not IsEnabled())
    if not self.active then return end
    local onHUD = SCENE_MANAGER:IsShowing("hud")
    local wasOnHUD = self.onHUD
    self.onHUD = onHUD
    self.window:SetHidden(not onHUD)
    if onHUD then
        self:SampleTrigger()
        -- Forced when the HUD has just come back, since the label is stale from before the menu
        -- and the channel id alone would not say so.
        self:RefreshLabel(not wasOnHUD)
    end
end

function channel:Start()
    if self.running then return end
    if not self.window then
        self.scene = SCENE_MANAGER:GetScene("hud")
        self.fragment = ZO_ActionLayerFragment:New(LAYER)
        self.fragment:RegisterCallback("StateChange", function() self:ResetButtons() end)
        self.window = WINDOW_MANAGER:CreateTopLevelWindow(NAME .. "Status")
        self.window:SetDimensions(1100, 40)
        self.window:SetAnchor(TOP, GuiRoot, TOP, 0, 110)
        self.window:SetMouseEnabled(false)
        self.window:SetHidden(true)
        self.label = WINDOW_MANAGER:CreateControl(NAME .. "Label", self.window, CT_LABEL)
        self.label:SetAnchorFill()
        self.label:SetFont("ZoFontGame")
        self.label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    end
    self.failed = false
    self.triggerUnavailable = false
    self.running = true
    self:Update()
    EVENT_MANAGER:RegisterForUpdate(NAME, UPDATE_INTERVAL_MS, function() self:Update() end)
end

function channel:Stop()
    self.running = false
    EVENT_MANAGER:UnregisterForUpdate(NAME)
    self:SetActive(false)
end

EVENT_MANAGER:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName ~= HOST_ADDON then return end
    EVENT_MANAGER:UnregisterForEvent(NAME, EVENT_ADD_ON_LOADED)
    -- Activation recurs after loading screens; keep these callbacks registered.
    EVENT_MANAGER:RegisterForEvent(NAME, EVENT_PLAYER_ACTIVATED, function() channel:Start() end)
    EVENT_MANAGER:RegisterForEvent(NAME, EVENT_PLAYER_DEACTIVATED, function() channel:Stop() end)
end)
