local EndeavorAssistant = {
    name = "EndeavorAssistant",
    version = "1.2",
    window = nil,
    completionMessageShown = false,
    isMinimized = false
}

function EndeavorAssistant:Initialize()
    self.savedVariables = ZO_SavedVars:NewAccountWide("EndeavorAssistantSV", 1, nil, {
        showAllInfo = true,
        useWindow = false,
        windowLeft = 100,
        windowTop = 100,
        windowWidth = 300,
        windowHeight = 400,
        displayInDungeons = true,
        displayInCyroAndBGs = true,
        displayInCombat = true,
        isMinimized = false
    })

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function() self:OnPlayerActivated() end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_TIMED_ACTIVITIES_UPDATED, function() self:OnTimedActivitiesUpdated() end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, function(_, inCombat) self:OnCombatStateChanged(inCombat) end)
    SLASH_COMMANDS["/checkendeavors"] = function() self:CheckDailyEndeavors() end

    self:CreateSettingsMenu()
    self:InitializeWindow()
    self:RegisterChatToggleListener()
end

function EndeavorAssistant:CreateSettingsMenu()
    local LAM = LibAddonMenu2
    local panelData = {
        type = "panel",
        name = "Endeavor Assistant",
        displayName = "Endeavor Assistant",
        author = "YourName",
        version = self.version,
        slashCommand = "/ea",
        registerForRefresh = true,
        registerForDefaults = true,
    }
   
    local optionsData = {
        {
            type = "checkbox",
            name = "Show All Information",
            tooltip = "If enabled, shows information for all uncompleted endeavors. If disabled, only shows the highest rewarding uncompleted endeavor.",
            getFunc = function() return self.savedVariables.showAllInfo end,
            setFunc = function(value) self.savedVariables.showAllInfo = value end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Use Custom Window",
            tooltip = "If enabled, displays information in a custom window. If disabled, displays information in the chat.",
            getFunc = function() return self.savedVariables.useWindow end,
            setFunc = function(value)
                self.savedVariables.useWindow = value
                self:UpdateWindowVisibility()
                if not value then
                    self:CheckDailyEndeavors()
                end
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Display in Dungeons",
            tooltip = "If enabled, displays information in dungeons.",
            getFunc = function() return self.savedVariables.displayInDungeons end,
            setFunc = function(value) self.savedVariables.displayInDungeons = value end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Display in Cyrodiil and Battlegrounds",
            tooltip = "If enabled, displays information in Cyrodiil and Battlegrounds.",
            getFunc = function() return self.savedVariables.displayInCyroAndBGs end,
            setFunc = function(value) self.savedVariables.displayInCyroAndBGs = value end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Display in Combat",
            tooltip = "If enabled, displays information during combat.",
            getFunc = function() return self.savedVariables.displayInCombat end,
            setFunc = function(value) self.savedVariables.displayInCombat = value end,
            width = "full",
        },
    }
   
    LAM:RegisterAddonPanel("EndeavorAssistantOptions", panelData)
    LAM:RegisterOptionControls("EndeavorAssistantOptions", optionsData)
end

function EndeavorAssistant:InitializeWindow()
    self.window = EndeavorAssistantWindow
    self.windowContent = self.window:GetNamedChild("Content")
   
    self.window:ClearAnchors()
    self.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.savedVariables.windowLeft, self.savedVariables.windowTop)
    self.window:SetDimensions(self.savedVariables.windowWidth, self.savedVariables.windowHeight)
   
    self.window:SetHandler("OnMoveStop", function()
        self.savedVariables.windowLeft = self.window:GetLeft()
        self.savedVariables.windowTop = self.window:GetTop()
    end)
   
    self.window:SetHandler("OnResizeStop", function()
        self.savedVariables.windowWidth = self.window:GetWidth()
        self.savedVariables.windowHeight = self.window:GetHeight()
    end)
   
    self.window:GetNamedChild("MinimizeButton"):SetHandler("OnClicked", function()
        self:ToggleMinimize()
    end)

    local fragment = ZO_SimpleSceneFragment:New(self.window)
    HUD_SCENE:AddFragment(fragment)
    HUD_UI_SCENE:AddFragment(fragment)

    self.isMinimized = self.savedVariables.isMinimized
    self:UpdateWindowVisibility()
    self:ApplyMinimizedState()
end

function EndeavorAssistant:ToggleMinimize()
    self.isMinimized = not self.isMinimized
    self.savedVariables.isMinimized = self.isMinimized
    self:ApplyMinimizedState()
end

function EndeavorAssistant:ApplyMinimizedState()
    if self.isMinimized then
        self.window:SetHeight(50) -- Adjust this value as needed
        self.windowContent:SetHidden(true)
    else
        self.window:SetHeight(self.savedVariables.windowHeight)
        self.windowContent:SetHidden(false)
    end
end

function EndeavorAssistant:RegisterChatToggleListener()
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CHAT_SYSTEM_CHANNEL_SWITCH, function()
        self:UpdateWindowVisibility()
    end)
end

function EndeavorAssistant:CheckDailyEndeavors()
    if not self:ShouldDisplay() then
        self.window:SetHidden(true)
        return
    end

    local numActivities = GetNumTimedActivities()
    local maxReward = 0
    local maxRewardNames = {}
    local hasUncompletedEndeavors = false
    local completedCount = 0
    local output = {}

    for index = 1, numActivities do
        if GetTimedActivityType(index) == TIMED_ACTIVITY_TYPE_DAILY then
            local name = GetTimedActivityName(index)
            local _, quantity = GetTimedActivityRewardInfo(index, 1)
            local progress = GetTimedActivityProgress(index)
            local maxProgress = GetTimedActivityMaxProgress(index)
           
            if progress >= maxProgress then
                completedCount = completedCount + 1
            else
                hasUncompletedEndeavors = true
               
                if self.savedVariables.showAllInfo then
                    table.insert(output, string.format("Daily endeavor: %s - Reward: %d - Progress: %d/%d", name, quantity, progress, maxProgress))
                else
                    if quantity > maxReward then
                        maxReward = quantity
                        maxRewardNames = {name}
                    elseif quantity == maxReward then
                        table.insert(maxRewardNames, name)
                    end
                end
            end
        end
    end

    if hasUncompletedEndeavors and completedCount < 3 then
        if not self.savedVariables.showAllInfo and #maxRewardNames > 0 then
            table.insert(output, string.format("Highest rewarding uncompleted Daily Endeavor(s) with %d Seals of Endeavor:", maxReward))
            for _, name in ipairs(maxRewardNames) do
                table.insert(output, "- " .. name)
            end
        end
    else
        output = {"Endeavors for today have been completed"}
    end

    self:DisplayOutput(output)
end

function EndeavorAssistant:DisplayOutput(output)
    if self.savedVariables.useWindow then
        local content = table.concat(output, "\n")
        self.windowContent:SetText(content)
        self:UpdateWindowVisibility()
    else
        self.window:SetHidden(true)
        if not self.completionMessageShown or output[1] ~= "Endeavors for today have been completed" then
            for _, line in ipairs(output) do
                CHAT_SYSTEM:AddMessage("|cFFFFFF[Endeavor Assistant]|r " .. line)
            end
            if output[1] == "Endeavors for today have been completed" then
                self.completionMessageShown = true
            end
        end
    end
end

function EndeavorAssistant:UpdateWindowVisibility()
    local shouldBeVisible = self.savedVariables.useWindow and self:ShouldDisplay()
    self.window:SetHidden(not shouldBeVisible)
end

function EndeavorAssistant:ShouldDisplay()
    if not self.savedVariables.displayInDungeons and IsUnitInDungeon("player") then
        return false
    end
    if not self.savedVariables.displayInCyroAndBGs and (IsPlayerInAvAWorld() or IsActiveWorldBattleground()) then
        return false
    end
    if not self.savedVariables.displayInCombat and IsUnitInCombat("player") then
        return false
    end
    return true
end

function EndeavorAssistant:OnTimedActivitiesUpdated()
    self.completionMessageShown = false
    self:CheckDailyEndeavors()
end

function EndeavorAssistant:OnCombatStateChanged(inCombat)
    self:CheckDailyEndeavors()
end

function EndeavorAssistant:OnPlayerActivated()
    zo_callLater(function()
        self:CheckDailyEndeavors()
    end, 5000)  -- 5 second delay
end

function EndeavorAssistant.OnAddOnLoaded(event, addonName)
    if addonName == EndeavorAssistant.name then
        EndeavorAssistant:Initialize()
        EVENT_MANAGER:UnregisterForEvent(EndeavorAssistant.name, EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent(EndeavorAssistant.name, EVENT_ADD_ON_LOADED, EndeavorAssistant.OnAddOnLoaded)
