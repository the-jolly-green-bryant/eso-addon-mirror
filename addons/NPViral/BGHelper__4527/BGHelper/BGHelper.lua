-- BGHelper 3.0
-- Focused Battleground queue helper by @NPViral.

BGHelper = BGHelper or {}
local BGH = BGHelper

BGH.name = "BGHelper"
BGH.version = "3.0"
BGH.vars = nil
BGH.settingsPanel = nil
BGH.ownsQueue = false
BGH.readyNonce = 0
BGH.releaseNonce = 0

local defaults = {
    queue4v4 = true,
    queue8v8 = true,
    showQueueConfirmation = false,
    autoAcceptReady = true,
    readyDelayMs = 0,
    autoRelease = true,
    releaseDelayMs = 2000,
}

local TAG = "|c5BB8FF[BGHelper]|r "

local function Print(message)
    if CHAT_SYSTEM then
        CHAT_SYSTEM:AddMessage(TAG .. tostring(message))
    end
end

function BGH:GetBattlegroundLocations()
    local root = ZO_ACTIVITY_FINDER_ROOT_MANAGER
    local template = ZO_ActivityFinderTemplate_Shared
    local filterClass = ZO_ActivityFinderFilterModeData
    if not root or not template or not filterClass then return nil end

    local filter = filterClass:New(
        LFG_ACTIVITY_BATTLE_GROUND_LOW_LEVEL,
        LFG_ACTIVITY_BATTLE_GROUND_CHAMPION,
        LFG_ACTIVITY_BATTLE_GROUND_NON_CHAMPION)
    filter:SetSubmenuFilterNames(
        GetString(SI_BATTLEGROUND_FINDER_SPECIFIC_FILTER_TEXT),
        GetString(SI_BATTLEGROUND_FINDER_RANDOM_FILTER_TEXT))
    filter:SetVisibleEntryTypes(ZO_ACTIVITY_FINDER_LOCATION_ENTRY_TYPE.SET)

    local locations = {}
    for _, activityType in ipairs(filter:GetActivityTypes()) do
        local entryTypes = filter:GetVisibleEntryTypes()
        if root:GetNumLocationsByActivity(activityType, entryTypes) > 0 then
            local locked = template:GetLevelLockInfoByActivity(activityType)
            if not locked then
                for _, location in ipairs(root:GetLocationsData(activityType)) do
                    if filter:IsEntryTypeVisible(location:GetEntryType()) and location:IsActive() then
                        locations[#locations + 1] = location
                    end
                end
            end
        end
    end
    return locations
end

local function GetQueueName(location)
    if location and location.rawName then
        return zo_strlower(tostring(location.rawName))
    end
    if location and type(location.GetName) == "function" then
        local ok, name = pcall(location.GetName, location)
        if ok and name then return zo_strlower(tostring(name)) end
    end
    return ""
end

local function GetQueueFormat(location)
    local name = GetQueueName(location)
    local compactName = name:gsub("%s+", "")
    if compactName:find("4v4", 1, true) or compactName:find("4vs4", 1, true) then return "4v4" end
    if compactName:find("8v8", 1, true) or compactName:find("8vs8", 1, true) then return "8v8" end
    return nil
end

local function MatchesCurrentGroupState(location)
    if type(location.maxGroupSize) ~= "number" then return false end
    local isGrouped = IsUnitGrouped("player")
    return isGrouped and location.maxGroupSize > 1
        or not isGrouped and location.maxGroupSize <= 1
end

function BGH:QueueSelectedBattlegrounds()
    if not self.vars then return end
    if IsCurrentlySearchingForGroup() then
        Print("Already queued in Activity Finder.")
        return
    end

    if not self.vars.queue4v4 and not self.vars.queue8v8 then
        Print("|cFF5555Select at least one Battleground format.|r")
        return
    end

    local root = ZO_ACTIVITY_FINDER_ROOT_MANAGER
    local locations = self:GetBattlegroundLocations()
    if not root or not locations then
        Print("|cFF5555Activity Finder is unavailable.|r")
        return
    end

    if type(root.ClearSelections) == "function" then root:ClearSelections() end

    local selected = 0
    local recognized = 0
    local found4v4 = false
    local found8v8 = false
    for _, location in ipairs(locations) do
        local format = GetQueueFormat(location)
        if format then recognized = recognized + 1 end
        local enabled = format == "4v4" and self.vars.queue4v4
            or format == "8v8" and self.vars.queue8v8
        local usable = enabled and MatchesCurrentGroupState(location)
        location:SetSelected(usable)
        if usable then
            selected = selected + 1
            if format == "4v4" then found4v4 = true end
            if format == "8v8" then found8v8 = true end
        end
    end

    if selected == 0 then
        if recognized == 0 then
            Print("|cFF5555Could not identify ESO's 4v4 or 8v8 Battleground queues.|r")
        else
            Print("|cFF5555No selected Battleground queue is available for your current group.|r")
        end
        return
    end

    self.ownsQueue = true
    local ok, err = pcall(root.StartSearch, root)
    if not ok then
        self.ownsQueue = false
        Print("|cFF5555Could not start the queue:|r " .. tostring(err))
        return
    end


    if self.vars.showQueueConfirmation then
        if found4v4 and found8v8 then
            Print("Joined 4v4 and 8v8 queues.")
        elseif found4v4 then
            Print("Joined the 4v4 queue.")
        elseif found8v8 then
            Print("Joined the 8v8 queue.")
        end
    end
end

function BGH:CancelPendingReadyAccept()
    self.readyNonce = self.readyNonce + 1
end

function BGH:OnActivityFinderStatus(_, status)
    if not self.vars then return end

    if status == ACTIVITY_FINDER_STATUS_NONE then
        self.ownsQueue = false
        self:CancelPendingReadyAccept()
        return
    end

    if not self.ownsQueue
    or not self.vars.autoAcceptReady
    or status ~= ACTIVITY_FINDER_STATUS_READY_CHECK
    or not HasLFGReadyCheckNotification() then
        return
    end

    self.readyNonce = self.readyNonce + 1
    local nonce = self.readyNonce
    local delay = math.max(0, self.vars.readyDelayMs or 0)
    zo_callLater(function()
        if nonce ~= self.readyNonce or not self.ownsQueue then return end
        if HasLFGReadyCheckNotification() then
            AcceptLFGReadyCheckNotification()
        end
    end, delay)
end

function BGH:OnPlayerDead()
    if not self.vars or not self.vars.autoRelease or not IsActiveWorldBattleground() then return end
    self.releaseNonce = self.releaseNonce + 1
    local nonce = self.releaseNonce
    local delay = math.max(200, self.vars.releaseDelayMs or 2000)
    zo_callLater(function()
        if nonce ~= self.releaseNonce then return end
        if IsActiveWorldBattleground() and IsUnitDead("player") then Release() end
    end, delay)
end

function BGH:RefreshAutoReleaseRegistration()
    local eventName = self.name .. "_PlayerDead"
    EVENT_MANAGER:UnregisterForEvent(eventName, EVENT_PLAYER_DEAD)
    self.releaseNonce = self.releaseNonce + 1
    if self.vars and self.vars.autoRelease then
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_PLAYER_DEAD, function()
            self:OnPlayerDead()
        end)
    end
end

function BGH:OpenDonationMail()
    local ok = pcall(function()
        MAIN_MENU_KEYBOARD:ShowScene("mailSend")
        ZO_MailSendToField:SetText("@NPViral")
        ZO_MailSendSubjectField:SetText("Skooma Fund")
        ZO_MailSendBodyField:SetText("Thanks for BGHelper!")
    end)
    if not ok then Print("Send donations manually to |cFFFFFF@NPViral|r.") end
end

function BGH:BuildSettingsPanel()
    if not LibAddonMenu2 then return end

    local panelName = self.name .. "Panel"
    self.settingsPanel = LibAddonMenu2:RegisterAddonPanel(panelName, {
        type = "panel",
        name = "BGHelper",
        displayName = "|c5BB8FFBGHelper|r",
        author = "@NPViral",
        version = self.version,
        slashCommand = "/bghelpersettings",
        registerForRefresh = true,
        registerForDefaults = true,
    })

    LibAddonMenu2:RegisterOptionControls(panelName, {
        { type = "description",
          text = "Join your selected Battleground formats with one button. BGHelper automatically uses the Solo or Group queue. "
              .. "Assign the queue key under Controls → Keybindings → BGHelper." },
        { type = "header", name = "Queue" },
        { type = "checkbox", name = "4v4", width = "half",
          tooltip = "Include the 4v4 Solo or Group queue.",
          getFunc = function() return self.vars.queue4v4 end,
          setFunc = function(value) self.vars.queue4v4 = value end,
          default = defaults.queue4v4 },
        { type = "checkbox", name = "8v8", width = "half",
          tooltip = "Include the 8v8 Solo or Group queue.",
          getFunc = function() return self.vars.queue8v8 end,
          setFunc = function(value) self.vars.queue8v8 = value end,
          default = defaults.queue8v8 },
        { type = "checkbox", name = "Show queue confirmation in chat", width = "full",
          tooltip = "Print a short confirmation after BGHelper starts the selected queues.",
          getFunc = function() return self.vars.showQueueConfirmation end,
          setFunc = function(value) self.vars.showQueueConfirmation = value end,
          default = defaults.showQueueConfirmation },
        { type = "button", name = "Join Selected BG Queues", width = "full",
          warning = "Immediately joins the selected Battleground formats.",
          func = function() self:QueueSelectedBattlegrounds() end },
        { type = "header", name = "Automation" },
        { type = "checkbox", name = "Auto-accept ready check", width = "full",
          tooltip = "Accept match-found ready checks only for queues started by BGHelper.",
          getFunc = function() return self.vars.autoAcceptReady end,
          setFunc = function(value)
              self.vars.autoAcceptReady = value
              if not value then self:CancelPendingReadyAccept() end
          end,
          default = defaults.autoAcceptReady },
        { type = "slider", name = "Ready-check delay (ms)", width = "full",
          tooltip = "Delay before accepting a BGHelper ready check. 0 is instant.",
          min = 0, max = 5000, step = 250,
          getFunc = function() return self.vars.readyDelayMs or 0 end,
          setFunc = function(value) self.vars.readyDelayMs = value end,
          default = defaults.readyDelayMs },
        { type = "checkbox", name = "Auto-release in Battlegrounds", width = "full",
          tooltip = "Automatically release after dying in a Battleground.",
          getFunc = function() return self.vars.autoRelease end,
          setFunc = function(value)
              self.vars.autoRelease = value
              self:RefreshAutoReleaseRegistration()
          end,
          default = defaults.autoRelease },
        { type = "slider", name = "Release delay (ms)", width = "full",
          tooltip = "Delay before releasing after death. 2000 ms is recommended.",
          min = 200, max = 2000, step = 100,
          getFunc = function() return math.max(200, self.vars.releaseDelayMs or 2000) end,
          setFunc = function(value) self.vars.releaseDelayMs = value end,
          default = defaults.releaseDelayMs },
        { type = "button", name = "Feeling generous?", width = "full",
          tooltip = "Donations keep the skooma flowing.",
          func = function() self:OpenDonationMail() end },
    })
end

function BGH:OpenSettings()
    if LibAddonMenu2 and self.settingsPanel then
        LibAddonMenu2:OpenToPanel(self.settingsPanel)
    else
        Print("Settings are unavailable.")
    end
end

function BGH:RegisterSlashCommands()
    SLASH_COMMANDS["/bgq"] = function() self:QueueSelectedBattlegrounds() end
    SLASH_COMMANDS["/bghelpersettings"] = function() self:OpenSettings() end
    SLASH_COMMANDS["/bgh"] = function(argument)
        local command = zo_strlower(zo_strtrim(argument or ""))
        if command == "queue" then
            self:QueueSelectedBattlegrounds()
        elseif command == "settings" then
            self:OpenSettings()
        else
            Print("Commands: queue, settings")
        end
    end
end

function BGH:Initialize()
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
    self.vars = ZO_SavedVars:NewAccountWide("BGHelperSavedVars", 1, nil, defaults)

    self:RegisterSlashCommands()
    self:BuildSettingsPanel()
    self:RefreshAutoReleaseRegistration()

    EVENT_MANAGER:RegisterForEvent(
        self.name .. "_QueueStatus",
        EVENT_ACTIVITY_FINDER_STATUS_UPDATE,
        function(eventCode, status) self:OnActivityFinderStatus(eventCode, status) end)

    EVENT_MANAGER:RegisterForEvent(
        self.name .. "_Activated",
        EVENT_PLAYER_ACTIVATED,
        function()
            if IsActiveWorldBattleground() then
                self.ownsQueue = false
                self:CancelPendingReadyAccept()
            elseif not IsCurrentlySearchingForGroup() then
                self.ownsQueue = false
                self:CancelPendingReadyAccept()
            end
        end)

    ZO_CreateStringId("SI_BINDING_NAME_BGH_QUEUE_SELECTED", "Join Selected Battleground Queues")
end

function BGH.OnAddonLoaded(_, addonName)
    if addonName == BGH.name then BGH:Initialize() end
end

function BGHelper_QueueSelected()
    BGH:QueueSelectedBattlegrounds()
end

EVENT_MANAGER:RegisterForEvent(BGH.name, EVENT_ADD_ON_LOADED, BGH.OnAddonLoaded)
