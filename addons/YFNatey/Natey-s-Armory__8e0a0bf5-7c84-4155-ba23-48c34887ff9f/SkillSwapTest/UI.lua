--=============================================================================
-- ENHANCED GEAR ANALYSIS FOR SET DISPLAY
--=============================================================================
function ArmoryM:AnalyzeGearSets(gearData)
    if not gearData then return {} end

    local setCounts = {}
    local setNames = {}

    -- All gear slots including jewelry and weapons
    local allSlots = { 0, 1, 2, 3, 4, 5, 6, 8, 9, 11, 12, 16, 20, 21 }

    for _, slot in ipairs(allSlots) do
        local itemData = gearData[slot]
        if itemData and itemData.itemLink then
            local setName = GetItemLinkSetInfo(itemData.itemLink)
            -- Check if setName is a valid string (not false/nil) and not empty
            if setName and type(setName) == "string" and setName ~= "" then
                -- Clean up set name (remove any extra spaces)
                setName = string.gsub(setName, "^%s*(.-)%s*$", "%1")

                if not setCounts[setName] then
                    setCounts[setName] = 0
                    setNames[setName] = setName
                end
                setCounts[setName] = setCounts[setName] + 1
            end
        end
    end

    return setCounts, setNames
end

function ArmoryM:GetTopSets(setCounts, maxSets)
    maxSets = maxSets or 5

    -- Convert to array and sort by count
    local sortedSets = {}
    for setName, count in pairs(setCounts) do
        table.insert(sortedSets, { name = setName, count = count })
    end

    -- Sort by count (highest first)
    table.sort(sortedSets, function(a, b) return a.count > b.count end)

    -- Return top sets
    local topSets = {}
    for i = 1, math.min(maxSets, #sortedSets) do
        table.insert(topSets, sortedSets[i])
    end

    return topSets
end

--=============================================================================
-- SLOT DISPLAY FUNCTIONS
--=============================================================================

function ArmoryM:GetSlotNumberForPanel(panelIndex)
    local baseSlot = (self.savedVars.currentPage - 1) * 4
    return baseSlot + panelIndex
end

function ArmoryM:ChangePage(newPage)
    if newPage < 1 or newPage > 3 then return end

    self.savedVars.currentPage = newPage

    -- Update page title FIRST
    self:UpdatePageTitle()

    -- Update panel titles
    for panelIndex = 1, 4 do
        local panelData = self.buildSlotsDisplay.panels[panelIndex]
        if panelData and panelData.title then
            local actualSlotNumber = self:GetSlotNumberForPanel(panelIndex)
            panelData.title:SetText(actualSlotNumber)
        end
    end

    -- Refresh all displays
    self:UpdateSlotsDisplay()

    local startSlot = ((newPage - 1) * 4 + 1)
    local endSlot = (newPage * 4)
    ArmoryM:DebugPrint("Switched to page " .. newPage .. " (Slots " .. startSlot .. "-" .. endSlot .. ")")
end

function ArmoryM:CreateSlotsDisplay()
    -- check if XML elements exists
    if not LoadoutManager_BuildPanel1 or not LoadoutManager_BuildPanel2 or
        not LoadoutManager_BuildPanel3 or not LoadoutManager_BuildPanel4 then
        return
    end

    -- initialize self.buildSlotsDisplay table with references to XML elements (ONLY ONCE)
    self.buildSlotsDisplay = {
        window = LoadoutManager_BuildPanelsWindow,             -- Main container window
        pageTitle = LoadoutManager_BuildPanelsWindowPageTitle, -- Page title reference
        panels = {}
    }

    -- set up panel data structure for all 4 panels
    for panelIndex = 1, 4 do
        local panelName = "LoadoutManager_BuildPanel" .. panelIndex
        local panel = _G[panelName]

        if panel then
            local panelData = {
                panel = panel,
                title = _G[panelName .. "Title"],
                skillDisplay = {
                    buildTitle = _G[panelName .. "SkillDisplayBuildTitle"],
                    frontBarButtons = {},
                    backBarButtons = {}
                },
                gearDisplay = {
                    gearLine1 = _G[panelName .. "GearDisplayGearLine1"],
                    gearLine2 = _G[panelName .. "GearDisplayGearLine2"],
                    gearLine3 = _G[panelName .. "GearDisplayGearLine3"],
                    gearLine4 = _G[panelName .. "GearDisplayGearLine4"],
                    gearLine5 = _G[panelName .. "GearDisplayGearLine5"],
                    gearLine6 = _G[panelName .. "GearDisplayGearLine6"],
                    gearLine7 = _G[panelName .. "GearDisplayGearLine7"]
                },
                slotControls = {}
            }

            -- Set up skill button references for this panel
            for i = 1, 6 do
                local frontBarName = panelName .. "SkillDisplayFrontBarSkill" .. i
                local backBarName = panelName .. "SkillDisplayBackBarSkill" .. i

                panelData.skillDisplay.frontBarButtons[i] = _G[frontBarName]
                panelData.skillDisplay.backBarButtons[i] = _G[backBarName]
            end

            -- Set panel title to show actual slot number
            if panelData.title then
                local actualSlotNumber = self:GetSlotNumberForPanel(panelIndex)
                panelData.title:SetText(actualSlotNumber)
            end

            self.buildSlotsDisplay.panels[panelIndex] = panelData
        end
    end

    -- Apply saved UI settings
    if self.buildSlotsDisplay and self.buildSlotsDisplay.window then
        -- Determine initial visibility based on keepUIOpen setting
        local shouldShow = self.savedVars.keepUIOpen or false
        self.buildSlotsDisplay.window:SetHidden(not shouldShow)
        self.savedVars.windowVisible = shouldShow

        -- Apply saved scale
        local scale = self.savedVars.uiScale or 1.0
        self.buildSlotsDisplay.window:SetScale(scale)

        -- Apply saved position
        local x = self.savedVars.windowX or 0
        local y = self.savedVars.windowY or 0
        self.buildSlotsDisplay.window:ClearAnchors()
        self.buildSlotsDisplay.window:SetAnchor(CENTER, GuiRoot, CENTER, x, y)
    end

    -- Force update the page title immediately after setup
    if self.buildSlotsDisplay.pageTitle then
        local currentPage = self.savedVars.currentPage or 1
        local titleKey = "pageTitle" .. currentPage
        local title = self.savedVars[titleKey] or ("Page " .. currentPage)
        self.buildSlotsDisplay.pageTitle:SetText(title)
    end

    -- Apply layout and update displays
    self:UpdatePanelLayout()
    self:UpdateSlotsDisplay()
end

function ArmoryM:UpdatePageTitle()
    if not self.buildSlotsDisplay or not self.buildSlotsDisplay.pageTitle then
        return
    end

    local currentPage = self.savedVars.currentPage or 1
    local titleKey = "pageTitle" .. currentPage
    local title = self.savedVars[titleKey] or ("Page " .. currentPage)

    self.buildSlotsDisplay.pageTitle:SetText(title)
end

function ArmoryM:UpdatePanelGearDisplay(panelIndex, currentBuild)
    local panelData = self.buildSlotsDisplay.panels[panelIndex]
    if not panelData or not panelData.gearDisplay then
        return
    end

    -- Clear all lines first
    local lines = {
        panelData.gearDisplay.gearLine1,
        panelData.gearDisplay.gearLine2,
        panelData.gearDisplay.gearLine3,
        panelData.gearDisplay.gearLine4,
        panelData.gearDisplay.gearLine5,
        panelData.gearDisplay.gearLine6,
        panelData.gearDisplay.gearLine7
    }

    for i, line in ipairs(lines) do
        if line then line:SetText("") end
    end

    -- Use the helper function to get the actual slot number
    local panelSlotNumber = self:GetSlotNumberForPanel(panelIndex)
    local panelBuildName = self:GetSlotName(panelSlotNumber)

    if panelBuildName and panelBuildName ~= "" then
        local slotData = self.savedVars.slots[panelSlotNumber]
        if slotData and slotData.gear then
            -- Analyze gear for sets
            local setCounts, setNames = self:AnalyzeGearSets(slotData.gear)
            local topSets = self:GetTopSets(setCounts, 7) -- Max 7 lines available

            -- Display each set on its own line
            for i, setInfo in ipairs(topSets) do
                local line = lines[i]
                if line then
                    local displayText = string.format("%s %d/5", setInfo.name, setInfo.count)
                    line:SetText(displayText)

                    -- Color coding based on set completion
                    if setInfo.count >= 5 then
                        line:SetColor(0, 1, 0, 1)       -- Green for 5+ pieces
                    elseif setInfo.count >= 3 then
                        line:SetColor(1, 1, 0, 1)       -- Yellow for 3-4 pieces
                    elseif setInfo.count >= 2 then
                        line:SetColor(1, 0.5, 0, 1)     -- Orange for 2 pieces
                    else
                        line:SetColor(0.8, 0.8, 0.8, 1) -- Gray for 1 piece
                    end
                end
            end

            -- If no sets found, show a message
            if #topSets == 0 and lines[1] then
                lines[1]:SetText("")
                lines[1]:SetColor(0.6, 0.6, 0.6, 1)
            end
        end
    else
        -- Slot is empty
        if lines[1] then
            lines[1]:SetText("Empty Slot")
            lines[1]:SetColor(0.5, 0.5, 0.5, 1)
        end
    end
end

function ArmoryM:ShowNotification(text, duration)
    if not ArmoryM_NotificationWindow then return end
    ArmoryM_NotificationWindowText:SetText(text)
    ArmoryM_NotificationWindow:SetHidden(false)
    EVENT_MANAGER:RegisterForUpdate("ArmoryM_Notification", duration or 1500, function()
        ArmoryM_NotificationWindow:SetHidden(true)
        EVENT_MANAGER:UnregisterForUpdate("ArmoryM_Notification")
    end)
end

function ArmoryM:UpdateSlotsDisplay()
    -- check if display exists
    if not self.buildSlotsDisplay or not self.buildSlotsDisplay.panels then
        return
    end
    local currentBuild = self.savedVars.currentBuild

    -- loop through all 4 panels
    for panelIndex = 1, 4 do
        local panelData = self.buildSlotsDisplay.panels[panelIndex]
        if panelData then -- Only process if panel exists
            -- Update skill display for this panel if it shows the current build
            self:UpdatePanelSkillDisplay(panelIndex, currentBuild)

            -- loop through slots in this panel
            for slotIndex = 1, 3 do
                if slotData then -- Only process if slot exists
                    local globalSlotNumber = slotData.slotNumber

                    -- for each slot, get build name using GetSlotName()
                    local buildName = self:GetSlotName(globalSlotNumber)

                    if buildName then
                        -- update slot labels to show "Slot X: Build Name"
                        if slotData.nameLabel then
                            slotData.nameLabel:SetText(string.format("Slot %d: %s", globalSlotNumber, buildName))

                            -- highlight currently active build if any
                            if buildName == currentBuild then
                                slotData.nameLabel:SetColor(0, 1, 0, 1) -- Green for active build
                            else
                                slotData.nameLabel:SetColor(1, 1, 1, 1) -- White for other builds
                            end
                        end

                        -- update button states (enabled for occupied slots)
                        if slotData.loadButton then
                            slotData.loadButton:SetState(BSTATE_NORMAL)
                            slotData.loadButton:SetText("Load")
                        end
                    else
                        -- update slot labels to show "Slot X: Empty"
                        if slotData.nameLabel then
                            slotData.nameLabel:SetText(string.format("Slot %d: Empty", globalSlotNumber))
                            slotData.nameLabel:SetColor(0.6, 0.6, 0.6, 1) -- Gray for empty
                        end

                        -- update button states (disabled for empty slots)
                        if slotData.loadButton then
                            slotData.loadButton:SetState(BSTATE_DISABLED)
                            slotData.loadButton:SetText("Empty")
                        end
                    end
                end
            end
        end
    end
end

function ArmoryM:UpdatePanelSkillDisplay(panelIndex, currentBuild)
    local panelData = self.buildSlotsDisplay.panels[panelIndex]
    if not panelData or not panelData.skillDisplay then
        return
    end

    -- Use the helper function to get the actual slot number
    local panelSlotNumber = self:GetSlotNumberForPanel(panelIndex)
    local panelBuildName = self:GetSlotName(panelSlotNumber)
    local skillData = nil

    -- Update build title to show this panel's specific build
    if panelData.skillDisplay.buildTitle then
        if panelBuildName and panelBuildName ~= "" then
            panelData.skillDisplay.buildTitle:SetText(panelBuildName)
            -- Highlight if this is the currently active build
            if panelBuildName == currentBuild then
                panelData.skillDisplay.buildTitle:SetColor(0, 1, 0, 1) -- Green for active
            else
                panelData.skillDisplay.buildTitle:SetColor(1, 1, 1, 1) -- White for inactive
            end
        else
            panelData.skillDisplay.buildTitle:SetText("No Build in Slot " .. panelSlotNumber)
            panelData.skillDisplay.buildTitle:SetColor(0.8, 0.8, 0.8, 1) -- Light gray
        end
    end

    -- Get skill data for this panel's specific build
    if panelBuildName and panelBuildName ~= "" then
        for slotNumber, slotData in pairs(self.savedVars.slots or {}) do
            if slotData.name == panelBuildName then
                skillData = slotData.skills
                break
            end
        end
    end

    -- Update front bar skills for this specific build
    if panelData.skillDisplay.frontBarButtons then
        local frontBarSkills = skillData and skillData[1] or {}
        for i = 1, 6 do
            local button = panelData.skillDisplay.frontBarButtons[i]
            if button then
                local skill = frontBarSkills[i]
                if skill then
                    self:SetSkillIcon(button, skill, i)
                else
                    self:ClearSkillButton(button, i)
                end
            end
        end
    end

    -- Update back bar skills for this specific build
    if panelData.skillDisplay.backBarButtons then
        local backBarSkills = skillData and skillData[2] or {}
        for i = 1, 6 do
            local button = panelData.skillDisplay.backBarButtons[i]
            if button then
                local skill = backBarSkills[i]
                if skill then
                    self:SetSkillIcon(button, skill, i)
                else
                    self:ClearSkillButton(button, i)
                end
            end
        end
    end

    self:UpdatePanelGearDisplay(panelIndex, currentBuild)
end

function ArmoryM:OnSlotLoadButtonClicked(slotNumber)
    local buildName = self:GetSlotName(slotNumber)

    if buildName then
        -- Load the build from this slot
        self:LoadBuildFromSlot(slotNumber)


        -- Update the display to show the new active build
        self:UpdateSlotsDisplay()
    else
        ArmoryM:DebugPrint(string.format("Slot %d is empty - nothing to load", slotNumber))
    end
end

-- Get all occupied slots
function ArmoryM:GetOccupiedSlots()
    local occupiedSlots = {}
    if self.savedVars.slots then
        for slotNumber, slotData in pairs(self.savedVars.slots) do
            occupiedSlots[slotNumber] = slotData.name
        end
    end
    return occupiedSlots
end

-- Check if a slot is empty
function ArmoryM:IsSlotEmpty(slotNumber)
    return not (self.savedVars.slots and self.savedVars.slots[slotNumber])
end

function ArmoryM:ToggleBuildSlots()
    if not self.buildSlotsDisplay then
        self:CreateSlotsDisplay()
    end

    if self.buildSlotsDisplay and self.buildSlotsDisplay.window then
        local isHidden = self.buildSlotsDisplay.window:IsHidden()
        self.buildSlotsDisplay.window:SetHidden(not isHidden)

        -- Update both visibility settings
        self.savedVars.windowVisible = not isHidden

        -- If manually closing, also disable keepUIOpen
        if not isHidden then -- If we're hiding it
            self.savedVars.keepUIOpen = false
        end

        if isHidden then
            self:UpdateSlotsDisplay()
        end
    end
end

--=============================================================================
-- UI SKILL DISPLAY FUNCTIONS
--=============================================================================
function ArmoryM:SetSkillIcon(button, skill, slotIndex)
    local abilityId = nil
    local iconPath = nil
    local skillName = nil

    if type(skill) == "number" then
        -- Normal skill
        abilityId = skill
        iconPath = GetAbilityIcon(abilityId)
        skillName = GetAbilityName(abilityId)
    elseif type(skill) == "string" then
        -- Crafted ability - parse the format "C:craftedId:realId"
        local craftedId, realId = string.match(skill, "C:(%d+):(%d+)")
        if realId then
            abilityId = tonumber(realId)
            iconPath = GetAbilityIcon(abilityId)
            skillName = GetAbilityName(abilityId)
        end
    end

    if iconPath and skillName then
        -- Set the skill icon
        button:SetNormalTexture(iconPath)
        button:SetAlpha(1.0)

        -- Store tooltip info
        button.skillName = skillName
        button.abilityId = abilityId
        button.slotIndex = slotIndex
    else
        self:ClearSkillButton(button, slotIndex)
    end
end

function ArmoryM:ClearSkillButton(button, slotIndex)
    -- Set empty slot appearance
    button:SetNormalTexture("/esoui/art/actionbar/quickslotbg.dds")
    button:SetAlpha(0.5)

    -- Clear stored data
    button.skillName = nil
    button.abilityId = nil
    button.slotIndex = slotIndex
end

function ArmoryM:UpdateSkillBar(barId, buttonArray)
    local currentBuild = self.savedVars.currentBuild
    local skillBar = nil

    if currentBuild and currentBuild ~= "" then
        -- Search through slots to find the one with this build name
        for slotNumber, slotData in pairs(self.savedVars.slots or {}) do
            if slotData.name == currentBuild then
                skillBar = slotData.skills[barId]
                break
            end
        end
    end

    -- Update each skill button
    for i = 1, 6 do
        local button = buttonArray[i]
        local skill = skillBar and skillBar[i]

        if skill then
            self:SetSkillIcon(button, skill, i)
        else
            self:ClearSkillButton(button, i)
        end
    end
end

--=============================================================================
-- UI UPDATE FUNCTIONS
--=============================================================================
function ArmoryM:UpdateSkillDisplay()
    if not self.skillDisplay then return end

    -- Update title
    local currentBuild = self.savedVars.currentBuild
    if currentBuild and currentBuild ~= "" then
        self.skillDisplay.title:SetText("Build: " .. currentBuild)
    else
        self.skillDisplay.title:SetText("No Build Selected")
    end

    -- Update both skill bars
    self:UpdateSkillBar(1, self.skillDisplay.frontBarButtons) -- Front bar
    self:UpdateSkillBar(2, self.skillDisplay.backBarButtons)  -- Back bar
end

function ArmoryM:CreateSkillDisplay()
    -- Check if XML exists first
    if not LoadoutManager_SkillDisplay then
        ArmoryM:DebugPrint("Skill Display XML not found!")
        return
    end

    -- Initialize the skill display
    self.skillDisplay = {
        window = LoadoutManager_SkillDisplay,
        title = LoadoutManager_SkillDisplayTitle,
        frontBarButtons = {
            LoadoutManager_SkillDisplayFrontBarSkill1,
            LoadoutManager_SkillDisplayFrontBarSkill2,
            LoadoutManager_SkillDisplayFrontBarSkill3,
            LoadoutManager_SkillDisplayFrontBarSkill4,
            LoadoutManager_SkillDisplayFrontBarSkill5,
            LoadoutManager_SkillDisplayFrontBarSkill6,
        },
        backBarButtons = {
            LoadoutManager_SkillDisplayBackBarSkill1,
            LoadoutManager_SkillDisplayBackBarSkill2,
            LoadoutManager_SkillDisplayBackBarSkill3,
            LoadoutManager_SkillDisplayBackBarSkill4,
            LoadoutManager_SkillDisplayBackBarSkill5,
            LoadoutManager_SkillDisplayBackBarSkill6,
        }
    }

    -- Initially hide the window
    self.buildSlotsDisplay.window:SetHidden(not self.savedVars.windowVisible)

    -- Set up initial display
    self:UpdateSkillDisplay()

    ArmoryM:DebugPrint("Skill Display created successfully")
end

function ArmoryM:UpdatePanelLayout()
    if not self.buildSlotsDisplay or not self.buildSlotsDisplay.panels then
        return
    end

    local isVertical = self.savedVars.layoutVertical

    -- Position panels first
    for panelIndex = 1, 4 do
        local panelData = self.buildSlotsDisplay.panels[panelIndex]
        if panelData and panelData.panel then
            local panel = panelData.panel
            panel:ClearAnchors()

            if isVertical then
                local titleOffset = 40 -- Space for title above
                local offsetY = titleOffset + (panelIndex - 1) * 220
                panel:SetAnchor(TOPLEFT, LoadoutManager_BuildPanelsWindow, TOPLEFT, 20, offsetY)
            else
                local offsetX = 20 + (panelIndex - 1) * 260
                panel:SetAnchor(TOPLEFT, LoadoutManager_BuildPanelsWindow, TOPLEFT, offsetX, 20)
            end
        end
    end

    -- Position the page title based on layout
    if self.buildSlotsDisplay.pageTitle then
        self.buildSlotsDisplay.pageTitle:SetHidden(false) -- Always show
        self.buildSlotsDisplay.pageTitle:ClearAnchors()

        if isVertical then
            -- Vertical: title at top
            self.buildSlotsDisplay.pageTitle:SetAnchor(TOP, LoadoutManager_BuildPanelsWindow, TOP, 0, 10)
        else
            -- Horizontal: title at bottom center
            self.buildSlotsDisplay.pageTitle:SetAnchor(BOTTOM, LoadoutManager_BuildPanelsWindow, BOTTOM, 0, -10)
        end
    end

    self:UpdateWindowSize()
end

function ArmoryM:UpdateWindowSize()
    if not self.buildSlotsDisplay or not self.buildSlotsDisplay.window then
        return
    end

    local window = self.buildSlotsDisplay.window
    local isVertical = self.savedVars.layoutVertical
    local padding = 40
    local panelSpacing = 20
    local titleHeight = 35

    if isVertical then
        -- Vertical: title at top, so add to height
        local width = 240 + padding
        local height = titleHeight + (200 * 4) + (panelSpacing * 3) + padding
        window:SetDimensions(width, height)
    else
        -- Horizontal: title at bottom, so add to height
        local width = (240 * 4) + (panelSpacing * 3) + padding
        local height = 200 + titleHeight + padding -- Panel height + title space + padding
        window:SetDimensions(width, height)
    end
end
