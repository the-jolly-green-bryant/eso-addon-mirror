--------------------------
-- Initialize Variables --
--------------------------

RepeatableActionTimer = {}
RepeatableActionTimer.name = "RepeatableActionTimer"
RepeatableActionTimer.version = "0.2.2"
RepeatableActionTimer.configVersion = 2
RepeatableActionTimer.controls = {}
RepeatableActionTimer.defaults = {
    shadowySupplier = true,
    stables = true,
    timers = {}
}
RepeatableActionTimer.character = {
    total = GetNumCharacters(),
    id = GetCurrentCharacterId(),
    names = {}
}
RepeatableActionTimer.GUI = {
    listHolder = nil,
    topLevel = nil,
    deadTime = "--",
    rowHeight = "24",
    highlight = "EsoUI/Art/Miscellaneous/listItem_highlight.dds"
}

---------------------
--  OnAddOnLoaded  --
---------------------

function OnAddOnLoaded(event, addonName)
    if addonName ~= RepeatableActionTimer.name then
        return
    end
    RepeatableActionTimer:Initialize(RepeatableActionTimer)
end

--------------------------
--  Initialize Function --
--------------------------

function RepeatableActionTimer:Initialize(self)
    self.saveData = ZO_SavedVars:NewAccountWide(self.name .. "Data", self.configVersion, nil, self.defaults)
    self:RepairSaveData(self)
    self:CreateSettingsWindow(self)
    self:BuildTimers(self)
    self:UpdateCharacterTimer(self)

    -- Register Key Bind Names
    ZO_CreateStringId("SI_BINDING_NAME_ACTION_TIMER_TOGGLE", "Toggle Window Visibility")

    -- System Hooks
    if (RepeatableActionTimer_GUI ~= nil) then
        SCENE_MANAGER:RegisterTopLevel(RepeatableActionTimer_GUI, false)
        self.GUI.topLevel = RepeatableActionTimer_GUI
        self.GUI.listHolder = RepeatableActionTimer_GUI_ListHolder
        self.GUI.topLevel:ClearAnchors()
        self.GUI.topLevel:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
        self.GUI.topLevel:SetHeight(self.GUI.topLevel:GetHeight() + (self.character.total * self.GUI.rowHeight))
        self:CreateListHolder(self)
    else
        d("Unable to initialize Action Timer GUI!")
    end

    -- Event Hooks
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_NEW_MOVEMENT_IN_UI_MODE, function(...)
        return self:OnPlayerMove(self, ...)
    end)
    --[[
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_QUEST_REMOVED, function(...)
        return self:OnQuestRemoved(self, ...)
    end)
    ]]
    --[[
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_RETICLE_HIDDEN_UPDATE, function(...)
        return self:OnReticleHidden(self, ...)
    end)
    ]]

    -- Release Hooks
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
end

---------------
-- Libraries --
---------------

local LibAddonMenu2 = LibStub("LibAddonMenu-2.0")
local LibAwesomeModule = LibStub('LibAwesomeModule-1.0')

--------------------
-- Awesome Events --
--------------------

local RepeatableActionEvents = LibAwesomeModule:New(RepeatableActionTimer.name)

-- title: header in settings menu
RepeatableActionEvents.title = GetString(SI_RATMOD_NAME)
-- hint: tootltip at module show/hide toggle in settings menu
RepeatableActionEvents.hint = GetString(SI_RATMOD_HINT)
-- order: default in the middle order = 40, at bottom ORDER_AWESOME_MODULE_PUSH_NOTIFICATION = 75
RepeatableActionEvents.order = ORDER_AWESOME_MODULE_PUSH_NOTIFICATION
-- enable debugging ingame via /aedebug balancing on
-- disable debugging ingame via /aedebug balancing off
-- show debugging state ingame via /aedebug balancing
RepeatableActionEvents.debug = false

-- user settings
RepeatableActionEvents.options = {
    showShadowySupplier = {
        type = 'checkbox',
        name = GetString(SI_RATMOD_SHADOWY_SUPPLIER),
        tooltip = GetString(SI_RATMOD_SHADOWY_SUPPLIER_HINT),
        default = true,
        order = 1,
    },
    showStables = {
        type = 'checkbox',
        name = GetString(SI_RATMOD_STABLES),
        tooltip = GetString(SI_RATMOD_STABLES_HINT),
        default = true,
        order = 1,
    },
    secondsFadeOut = {
        type = 'slider',
        name = GetString(SI_RATMOD_FADE_OUT),
        tooltip = GetString(SI_RATMOD_FADE_OUT_HINT),
        min  = 10,
        max = 120,
        default = 30,
        order = 2,
    },
}

-- fontSize: default = 1, max = 5
RepeatableActionEvents.fontSize = 5

-- override enable function
function RepeatableActionEvents:Enable(options)
    self:d('Enable')
    self.data = {
        secondsFadeOut = options.secondsFadeOut,
        visible = false
    }
end

-- override set function
function RepeatableActionEvents:Set(key, value)
    self:d('Set[' .. key .. '] ', value)
    if (key == 'secondsFadeOut') then
        self.data.secondsFadeOut = value
    end
end

-- handle labels
function RepeatableActionEvents:Update(options)
    self:d('Update')
    local labelText = ''
    if (self.data.visible) then
        --[[
        local actions = ''
        if (options.showStables) then
            actions = actions .. ''
        end
        ]]

        RepeatableActionTimer:UpdateCharacterTimer()

        local timeMin = 500
        local timeThreshold = 300
        local actions = {}
        local elapsed = nil
        for characterId, timers in pairs(RepeatableActionTimer.saveData.timers) do
            for key, value in pairs(timers) do
                elapsed = value - GetTimeStamp()
                if (elapsed <= timeThreshold) then
                    actions[characterId][key] = elapsed
                end
                if (elapsed < timeMin) then
                    timeMin = elapsed
                end
            end
        end

        if (timeMin <= timeThreshold) then
            local color = (timeMin >= 60) and COLOR_AWEVS_AVAILABLE or COLOR_AWEVS_WARNING
            local actionString = (timeMin >= 60) and 'Event(s) within 5m!' or 'Event(s) within 1m!'
            labelText = RepeatableActionEvents.Colorize(color, GetString(SI_RATMOD_NAME)) .. ': ' .. actionString
        end
    end

    self.label:SetText(labelText)
end -- RepeatableActionEvents:Update

--------------------
-- Internal Tools --
--------------------

-- allow debugging based on changes
RepeatableActionTimer.debugLog = {}
function RepeatableActionTimer:Debug(self, key, output)
    if output ~= self.debugLog[key] then
        self.debugLog[key] = output
        d(self.name .. "." .. key .. ":", output)
    end
end

function RepeatableActionTimer:RepairSaveData(self)
    for key, value in pairs(self.defaults) do
        if (self.saveData[key] == nil) then
            self.saveData[key] = value
        end
    end
end

-- Note: This is disabled in favor or ZO_FormatTime for now
--[[
function RepeatableActionTimer:Clock(self, seconds)
  local seconds = tonumber(seconds)

  if seconds <= 0 then
    return "00:00:00"
  else
    days = math.floor(seconds / 86400)
    hours = math.floor(seconds / 3600 - (days * 86400))
    mins = math.floor(seconds / 60 - (days * 86400) - (hours * 60))
    secs = math.floor(seconds - (days * 86400) - (hours * 3600) - (mins * 60))
    return days > 0 and string.format("%02.fd %02.fh %02.fm %02.fs", days, hours, mins, secs) or string.format("%02.fh %02.fm %02.fs", hours, mins, secs)
  end
end
]]

----------
-- Data --
----------

function RepeatableActionTimer:BuildTimers(self)
    for i = 1, self.character.total do
        local name, _, _, _, _, _, characterId = GetCharacterInfo(i)
        -- Register Names while transversing
        if self.character.names[characterId] == nil then
            -- Strip the grammar markup
            self.character.names[characterId] = zo_strformat("<<1>>", name)
        end
        -- Store Timers
        if self.saveData.timers[characterId] == nil then
            self.saveData.timers[characterId] = {
                stables = nil,
                shadowySupplier = nil
            }
        end
    end
end

function RepeatableActionTimer:UpdateCharacterTimer(self)
    self.saveData.timers[self.character.id].stables = GetTimeStamp() + math.floor(GetTimeUntilCanBeTrained() / 1000)
    self.saveData.timers[self.character.id].shadowySupplier = GetTimeStamp() + GetTimeToShadowyConnectionsResetInSeconds()
end

--------------------
-- Menu Functions --
--------------------

function RepeatableActionTimer:CreateSettingsWindow(self)
    local panelData = {
        type = "panel",
        name = GetString(SI_RATMOD_NAME),
        displayName = GetString(SI_RATMOD_FULL_NAME),
        author = "Positron",
        version = self.version,
        website = "https://github.com/alexgurrola/RepeatableActionTimer",
        slashCommand = "/actiontimer",
        registerForDefaults = true,
    }
    -- local panel =
    LibAddonMenu2:RegisterAddonPanel(self.name .. "Config", panelData)
    local optionsData = {}
    optionsData[#optionsData + 1] = {
        type = "header",
        name = "Actors"
    }
    --[[
    optionsData[#optionsData + 1] = {
        type = "description",
        text = GetString(SI_RATMOD_HINT)
    }
    ]]
    --[[
    optionsData[#optionsData + 1] = {
        type = "description",
        text = "This will house settings for toggling specific timers for each character."
    }
    ]]
    --[[
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = GetString(SI_RATMOD_STABLES),
        tooltip = GetString(SI_RATMOD_STABLES_HINT),
        requiresReload = false,
        default = self.defaults.stables,
        getFunc = function()
            return self.saveData.stables
        end,
        setFunc = function(newValue)
            self.saveData.stables = newValue
        end,
    }
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = GetString(SI_RATMOD_SHADOWY_SUPPLIER),
        tooltip = GetString(SI_RATMOD_SHADOWY_SUPPLIER_HINT),
        requiresReload = false,
        default = self.defaults.shadowySupplier,
        getFunc = function()
            return self.saveData.shadowySupplier
        end,
        setFunc = function(newValue)
            self.saveData.shadowySupplier = newValue
        end,
    }
    ]]
    -- Other Actions
    optionsData[#optionsData + 1] = {
        type = "header",
        name = "Other Actions"
    }
    -- Donation Button
    optionsData[#optionsData + 1] = {
        type = "button",
        name = "Small Donation",
        tooltip = "This will compose appreciation mail for @PositronXX.  You can either accept the prompt directly or decline the transaction and mail a custom letter in the Outbox.",
        func = function()
            local wallet = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
            local tithe = math.floor(wallet / 10)
            MAIL_SEND:ClearFields()
            MAIL_SEND.to:SetText("@PositronXX")
            MAIL_SEND.subject:SetText("Donation to Action Timer")
            MAIL_SEND.body:SetText("Keep the updates coming!")
            MAIL_SEND:SetSendMoneyMode(true)
            MAIL_SEND:AttachMoney(0, tithe)
            MAIL_SEND:UpdateMoneyAttachment()
            MAIL_SEND:UpdatePostageMoney()
            SCENE_MANAGER:CallWhen("mailSend", SCENE_SHOWN, function()
                ZO_MailSendBodyField:TakeFocus()
            end)
            ZO_MainMenuSceneGroupBar.m_object:SelectDescriptor("mailSend")
            MAIL_SEND:Send()
        end,
    }
    LibAddonMenu2:RegisterOptionControls(self.name .. "Config", optionsData)
end

-------------------
-- UI/UX Actions --
-------------------

function RepeatableActionTimer:CreateLine(self, i, predecessor, parent)
    local row = CreateControlFromVirtual(self.name .. "_Row_", parent, self.name .. "_SlotTemplate", i)

    row.texture = row:GetNamedChild("Bg")
    row.name = row:GetNamedChild("_Name")
    row.stables = row:GetNamedChild("_TimeStables")
    row.shadowySupplier = row:GetNamedChild("_TimeShadowySupplier")

    row:SetHidden(false)
    row:SetMouseEnabled(true)
    row:SetHeight(self.GUI.rowHeight)

    if i == 1 then
        row:SetAnchor(TOPLEFT, self.GUI.listHolder, TOPLEFT, 0, 0)
        row:SetAnchor(TOPRIGHT, self.GUI.listHolder, TOPRIGHT, 0, 0)
    else
        row:SetAnchor(TOPLEFT, predecessor, BOTTOMLEFT, 0, self.GUI.listHolder.rowHeight)
        row:SetAnchor(TOPRIGHT, predecessor, BOTTOMRIGHT, 0, self.GUI.listHolder.rowHeight)
    end

    row:SetParent(self.GUI.listHolder)

    return row
end

function RepeatableActionTimer:FillLine(self, line, item)
    -- highlight current character
    if self.character.id == item.id then
        line.texture:SetTexture(self.GUI.highlight)
        line.texture:SetColor(92, 176, 252, 1)
    end
    line.name:SetText(item == nil and "Unknown" or item.name)
    line.stables:SetText(item == nil and self.GUI.deadTime or item.stables)
    line.shadowySupplier:SetText(item == nil and self.GUI.deadTime or item.shadowySupplier)
end

function RepeatableActionTimer:InitializeTimeLines(self)
    for i = 1, self.character.total do
        self:FillLine(self, self.GUI.listHolder.lines[i], self.GUI.listHolder.dataLines[i])
    end
end

function RepeatableActionTimer:CreateListHolder(self)
    self.GUI.listHolder.dataLines = {}
    self.GUI.listHolder.lines = {}
    local predecessor
    for i = 1, self.character.total do
        self.GUI.listHolder.lines[i] = self:CreateLine(self, i, predecessor, self.GUI.listHolder)
        predecessor = self.GUI.listHolder.lines[i]
    end
    self:Redraw(self)
end

function RepeatableActionTimer:EventTime(self, timeStamp)
    if timeStamp == nil then
        return self.GUI.deadTime
    end
    local elapsed = timeStamp - GetTimeStamp()
    return ZO_FormatTime(elapsed < 0 and 0 or elapsed, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_TWELVE_HOUR)
end

function RepeatableActionTimer:Redraw(self)
    self:UpdateCharacterTimer(self)
    local dataLines = {}
    for i = 1, self.character.total do
        local _, _, _, _, _, _, characterId = GetCharacterInfo(i)
        table.insert(dataLines, {
            id = characterId,
            name = self.character.names[characterId],
            shadowySupplier = self:EventTime(self, self.saveData.timers[characterId] and self.saveData.timers[characterId].shadowySupplier or nil),
            stables = self:EventTime(self, self.saveData.timers[characterId] and self.saveData.timers[characterId].stables or nil)
        })
    end
    self.GUI.listHolder.dataLines = dataLines
    self.GUI.listHolder:SetParent(self.GUI.topLevel)
    self:InitializeTimeLines(self)
end

function RepeatableActionTimer:ToggleWindow(self)
    self.active = not self.active
    if (self.active) then
        self:Redraw(self)
    end
    if (self.GUI.topLevel ~= nil) then
        self.GUI.topLevel:SetHidden(not self.active)
    end
end

--------------------
-- Event Handlers --
--------------------

--[[
function RepeatableActionTimer:OnReticleHidden(self, eventCode, retHidden)
    if (self.GUI.topLevel ~= nil and self.active) then
        self.active = retHidden
        self.GUI.topLevel:SetHidden(not retHidden)
    end
end
]]

function RepeatableActionTimer:OnPlayerMove(self, eventCode)
    -- close window if open
    if (self.active) then
        self:ToggleWindow(self)
    end
end

--[[
function RepeatableActionTimer:OnQuestRemoved(self, eventCode, isCompleted, journalIndex, questName, zoneIndex, poiIndex, questId)
    d("GCCID:", GCCId())
    d("QuestID:", questId)
    d("Completed:", isCompleted)
end
]]

function RepeatableActionTimer:OnUpdate(self)
    self:Redraw(self)
end

----------------------
--  Register Events --
----------------------

EVENT_MANAGER:RegisterForEvent(RepeatableActionTimer.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
