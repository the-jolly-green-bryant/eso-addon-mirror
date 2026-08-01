--------------------------
-- Initialize Variables --
--------------------------

UpExperienceBar = {}
UpExperienceBar.name = "UpExperienceBar"
UpExperienceBar.configVersion = 1
UpExperienceBar.saveData = {}
UpExperienceBar.defaults = {
    enabled = true,
    showXPProgress = true,
    showXPPerHour = true,
    xpDisplayMode = "minute",  -- Default to XP per minute
    xpHistory = {},  -- Store XP history for 7 days
    trackXP = true  -- New option to enable/disable XP tracking
}

-- Variables for tracking XP gain over time
UpExperienceBar.xpStartTime = GetTimeStamp()
UpExperienceBar.xpStartValue = GetUnitXP("player")

---------------------
--  OnAddOnLoaded  --
---------------------

function OnAddOnLoaded(event, addonName)
    if addonName ~= UpExperienceBar.name then
        return
    end
    UpExperienceBar:Initialize()
end

--------------------------
--  Initialize Function --
--------------------------

function UpExperienceBar:Initialize()
    -- Handle Save Data
    self.saveData = ZO_SavedVars:New(self.name .. "Data", self.configVersion, nil, self.defaults)

    -- Ensure saved data is initialized
    self:RepairSaveData()

    -- Create settings menu
    self:CreateSettingsMenu()

    -- Handle Startup
    if self.saveData.enabled == true then
        self:Enable()
    end

    -- Unregister the addon loaded event
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
end

--------------------------
--  Repair Save Data --
--------------------------

function UpExperienceBar:RepairSaveData()
    -- Ensure saved data uses default values where necessary
    for key, value in pairs(self.defaults) do
        if self.saveData[key] == nil then
            self.saveData[key] = value
        end
    end

    -- Initialize XP history if not already present
    if not self.saveData.xpHistory then
        self.saveData.xpHistory = {}
    end
end

------------------------
-- Core Functionality --
------------------------

-- Check if the player is at level 50 and track Champion Points
function UpExperienceBar:IsChampionLevel()
    local playerLevel = GetUnitLevel("player")
    local championXP = GetPlayerChampionXP()

    if playerLevel >= 50 then
        -- If the player is level 50 or higher, track Champion Points
        return true, championXP
    else
        -- Otherwise, return the regular XP
        return false, GetUnitXP("player")
    end
end

-- Use the existing player XP or CP bar and make it visible permanently
function UpExperienceBar:UseExistingXPBar()
    -- Ensure the player progress bar exists
    if ZO_PlayerProgress then
        -- Make the XP bar permanently visible by adding it to the HUD scene
        SCENE_MANAGER:GetScene("hud"):AddFragment(PLAYER_PROGRESS_BAR_FRAGMENT)
        SCENE_MANAGER:GetScene("hud"):AddFragment(PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT)

        -- Create the XP progress label inside the XP bar
        local progressLabelName = "XPBarProgressLabel" .. tostring(GetTimeStamp())
        self.xpProgressLabel = WINDOW_MANAGER:CreateControl(progressLabelName, ZO_PlayerProgress, CT_LABEL)
        self.xpProgressLabel:SetFont("ZoFontGameLargeBold")  -- Increased font size and bold
        self.xpProgressLabel:SetColor(1, 1, 1, 1) -- White color for the main text
        self.xpProgressLabel:SetAnchor(CENTER, ZO_PlayerProgress, CENTER, 0, 0) -- Place it in the center of the XP bar
        self.xpProgressLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)  -- Align text to the center
        self.xpProgressLabel:SetText("XP: 0 / 0")
        self.xpProgressLabel:SetHidden(not self.saveData.showXPProgress)

        -- Create the XP per hour/min label beside the XP bar with the same larger font
        local xpPerHourLabelName = "XPBarPerHourLabel" .. tostring(GetTimeStamp())
        self.xpPerHourLabel = WINDOW_MANAGER:CreateControl(xpPerHourLabelName, ZO_PlayerProgress, CT_LABEL)
        self.xpPerHourLabel:SetFont("ZoFontGameLargeBold")  -- Same larger font
        self.xpPerHourLabel:SetColor(1, 1, 1, 1) -- White color
        self.xpPerHourLabel:SetAnchor(LEFT, ZO_PlayerProgress, RIGHT, 10, 0) -- Position beside the XP bar
        self.xpPerHourLabel:SetText("XP/min: 0")
        self.xpPerHourLabel:SetHidden(not self.saveData.showXPPerHour)
    end
end

-- Update the XP or Champion Points progress label
function UpExperienceBar:UpdateXPBar()
    -- Check if XP tracking is disabled
    if not self.saveData.trackXP then
        return  -- Do nothing if XP tracking is disabled
    end

    -- Check if player is at champion level
    local isChampion, currentXP = self:IsChampionLevel()

    -- Check if the label has been created
    if not self.xpProgressLabel or not self.xpPerHourLabel then
        return
    end

    -- Get current and maximum XP values
    local maxXP
    if isChampion then
        maxXP = GetPlayerChampionXPMax()
    else
        maxXP = GetUnitXPMax("player")
    end

    -- Check if values are valid
    if currentXP == nil or maxXP == nil then
        return
    end

    -- Calculate the XP percentage
    local xpPercent = (currentXP / maxXP) * 100

    -- Define the color for the percentage based on the value
    local percentageColor
    if xpPercent >= 81 then
        -- Green for 81% or higher
        percentageColor = ZO_ColorDef:New(0, 1, 0)  -- Green color (RGB: 0, 1, 0)
    else
        -- Yellow for below 80%
        percentageColor = ZO_ColorDef:New(1, 1, 0)  -- Yellow color (RGB: 1, 1, 0)
    end

    -- Format the progress label with the desired format (current XP / max XP and percentage)
    local formattedPercent = percentageColor:Colorize(string.format("%.1f%%", xpPercent))
    local progressText = zo_strformat("<<1>> / <<2>> (<<3>>)", ZO_CommaDelimitNumber(currentXP), ZO_CommaDelimitNumber(maxXP), formattedPercent)

    -- Set the progress label text with colored percentage
    self.xpProgressLabel:SetText(progressText)

    -- Update XP per hour or per minute based on user setting
    local timeElapsed = GetTimeStamp() - self.xpStartTime
    local xpGained = currentXP - self.xpStartValue

    if self.saveData.xpDisplayMode == "hour" then
        local xpPerHour = (xpGained / timeElapsed) * 3600
        self.xpPerHourLabel:SetText(string.format("XP/h: %d", xpPerHour))
    else
        local xpPerMin = (xpGained / timeElapsed) * 60
        self.xpPerHourLabel:SetText(string.format("XP/min: %d", xpPerMin))
    end

    -- Log XP gained today
    self:LogXPHistory(xpGained)
end

-- Log XP or Champion Points gained and maintain a 7-day history
function UpExperienceBar:LogXPHistory(xpGained)
    local today = os.date("%Y-%m-%d")

    -- Check if today's entry exists
    if not self.saveData.xpHistory[today] then
        self.saveData.xpHistory[today] = 0
    end

    -- Update today's XP gained
    self.saveData.xpHistory[today] = self.saveData.xpHistory[today] + xpGained

    -- Remove entries older than 7 days
    local cutoffTime = os.time() - (7 * 24 * 60 * 60)  -- 7 days in seconds
    for date, _ in pairs(self.saveData.xpHistory) do
        local entryTime = os.time({year=tonumber(date:sub(1,4)), month=tonumber(date:sub(6,7)), day=tonumber(date:sub(9,10))})
        if entryTime < cutoffTime then
            self.saveData.xpHistory[date] = nil
        end
    end
end

-- Reset the XP history
function UpExperienceBar:ResetXPHistory()
    self.saveData.xpHistory = {}
    d("XP history reset successfully.")
end

-- Enable the XP bar and make it visible
function UpExperienceBar:Enable()
    -- Use the existing XP or CP bar
    self:UseExistingXPBar()

    -- Update the XP bar on load
    self:UpdateXPBar()
end

-- Function to get the formatted XP history
function UpExperienceBar:GetFormattedXPHistory()
    local historyText = "XP Gained (Last 7 Days):\n"
    for date, xp in pairs(self.saveData.xpHistory) do
        historyText = historyText .. zo_strformat("<<1>>: <<2>> XP\n", date, ZO_CommaDelimitNumber(xp))
    end
    return historyText
end

----------------------
--  Create Settings Menu --
----------------------

function UpExperienceBar:CreateSettingsMenu()
    -- Create the settings panel using LibAddonMenu
    local panelData = {
        type = "panel",
        name = "Up Experience Bar Settings",
        author = "Fisicorj",
        version = "2.1",
    }

    -- Add options for enabling/disabling each label
    local optionsTable = {
        {
            type = "checkbox",
            name = "Show XP Progress",
            tooltip = "Enable/Disable the XP progress label.",
            getFunc = function() return self.saveData.showXPProgress end,
            setFunc = function(value) 
                self.saveData.showXPProgress = value
                self.xpProgressLabel:SetHidden(not value)
            end,
        },
        {
            type = "checkbox",
            name = "Show XP per Hour",
            tooltip = "Enable/Disable the XP per hour/min label.",
            getFunc = function() return self.saveData.showXPPerHour end,
            setFunc = function(value) 
                self.saveData.showXPPerHour = value
                self.xpPerHourLabel:SetHidden(not value)
            end,
        },
        {
            type = "checkbox",
            name = "Enable XP Tracking",
            tooltip = "Enable/Disable XP tracking.",
            getFunc = function() return self.saveData.trackXP end,
            setFunc = function(value)
                self.saveData.trackXP = value
                if not value then
                    d("XP tracking disabled.")
                else
                    d("XP tracking enabled.")
                    self:UpdateXPBar()  -- Update immediately if tracking is enabled again
                end
            end,
        },
        {
            type = "dropdown",
            name = "XP Display Mode",
            tooltip = "Choose whether to display XP per hour or XP per minute.",
            choices = { "hour", "minute" },
            getFunc = function() return self.saveData.xpDisplayMode end,
            setFunc = function(value)
                self.saveData.xpDisplayMode = value
                self:UpdateXPBar() -- Update the display immediately
            end,
        },
        {
            type = "description",
            text = function()
                -- Display the XP history for the last 7 days dynamically
                return UpExperienceBar:GetFormattedXPHistory()
            end,
        },
        {
            type = "button",
            name = "Reset XP History",
            tooltip = "Reset the XP history for the last 7 days.",
            func = function() 
                UpExperienceBar:ResetXPHistory() 
            end,
        },
    }

    -- Register the panel and options with LibAddonMenu
    LibAddonMenu2:RegisterAddonPanel("UpExperienceBarSettingsPanel", panelData)
    LibAddonMenu2:RegisterOptionControls("UpExperienceBarSettingsPanel", optionsTable)
end

----------------------
--  Register Events --
----------------------

-- Register the addon loaded event
EVENT_MANAGER:RegisterForEvent(UpExperienceBar.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

-- Register for XP update events to update the progress label
EVENT_MANAGER:RegisterForEvent(UpExperienceBar.name, EVENT_EXPERIENCE_UPDATE, function()
    UpExperienceBar:UpdateXPBar()
end)
