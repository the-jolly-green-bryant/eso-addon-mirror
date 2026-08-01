function ArmoryM:CreateSettingsMenu()
    local LAM = LibAddonMenu2
    local buildName = ""
    local saveSlot = 1
    local loadSlot = 1
    local deleteSlot = 1

    local panelData = {
        type = "panel",
        name = "Swap Builds",
        displayName = "Swap Builds",
        author = "YFNatey",
        version = "1.0",
    }

    local optionsData = {
        {
            type = "header",
            name = "Equip"
        },
        {
            type = "slider",
            name = "Select Build",
            min = 1,
            max = 12,
            step = 1,
            getFunc = function() return loadSlot end,
            setFunc = function(value)
                loadSlot = value

                -- Auto-show and refresh the window when slider changes
                if self.buildSlotsDisplay and self.buildSlotsDisplay.window then
                    self:UpdateSlotsDisplay()
                elseif not self.buildSlotsDisplay then
                    -- Create and show if it doesn't exist
                    self:CreateSlotsDisplay()
                end
            end,
        },
        {
            type = "button",
            name = function()
                local slotName = self:GetSlotName(loadSlot)
                if slotName then
                    return "|cFF8C42Equip All|r"
                else
                    return "|cFF8C42Equip All|r"
                end
            end,
            func = function()
                local slotName = self:GetSlotName(loadSlot)
                if slotName then
                    self:LoadBuildFromSlot(loadSlot)
                    self:ShowNotification("Equipped '" .. slotName .. "'")
                    if self.UpdateSlotsDisplay then
                        self:UpdateSlotsDisplay()
                    end
                else
                    ArmoryM:DebugPrint("|cFF0000Slot " .. loadSlot .. " is empty|r")
                end
            end,
            disabled = function() return not self:GetSlotName(loadSlot) end,
        },
        -- New buttons for loading gear/skills separately
        {
            type = "button",
            name = function()
                local status = self:GetSlotSaveStatus(loadSlot)
                return status.hasGear and "|cFF8C42Equip Gear Only|r" or "|c888888Equip Gear Only|r"
            end,
            func = function()
                local slotName = self:GetSlotName(loadSlot)
                if slotName then
                    local status = self:GetSlotSaveStatus(loadSlot)
                    if status.hasGear then
                        self:LoadGearFromSlot(loadSlot)
                        self:ShowNotification("Equipped gear from '" .. slotName .. "'")
                        if self.UpdateSlotsDisplay then
                            self:UpdateSlotsDisplay()
                        end
                    else
                        ArmoryM:DebugPrint("|cFF0000No gear saved in slot " .. loadSlot .. "|r")
                    end
                else
                    ArmoryM:DebugPrint("|cFF0000Slot " .. loadSlot .. " is empty|r")
                end
            end,
            disabled = function()
                local status = self:GetSlotSaveStatus(loadSlot)
                return not status.name or not status.hasGear
            end,
        },
        {
            type = "button",
            name = function()
                local status = self:GetSlotSaveStatus(loadSlot)
                local hasSkills = status.hasSkills and (status.hasSkills[1] or status.hasSkills[2])
                return hasSkills and "|cFF8C42Equip Skills Only|r" or "|c888888Equip Skills Only|r"
            end,
            func = function()
                local slotName = self:GetSlotName(loadSlot)
                if slotName then
                    local status = self:GetSlotSaveStatus(loadSlot)
                    if status.hasSkills and (status.hasSkills[1] or status.hasSkills[2]) then
                        self:LoadAllSkillsFromSlot(loadSlot)
                        self:ShowNotification("Equipped skills from '" .. slotName .. "'")
                    else
                        ArmoryM:DebugPrint("|cFF0000No skills saved in slot " .. loadSlot .. "|r")
                    end
                else
                    ArmoryM:DebugPrint("|cFF0000Slot " .. loadSlot .. " is empty|r")
                end
            end,
            disabled = function()
                local status = self:GetSlotSaveStatus(loadSlot)
                return not status.name or not (status.hasSkills and (status.hasSkills[1] or status.hasSkills[2]))
            end,
        },
        {
            type = "button",
            name = "Toggle UI",
            func = function()
                self:ToggleBuildSlots()
            end,
            width = "full"
        },
        {
            type = "dropdown",
            name = "Select Page",
            tooltip = "Switch between different sets of build slots",
            choices = { "Page 1", "Page 2", "Page 3" },
            choicesValues = { 1, 2, 3 },
            getFunc = function() return self.savedVars.currentPage end,
            setFunc = function(value)
                self.savedVars.currentPage = value
                self:ChangePage(value)
                -- Force an additional update just to be sure
                zo_callLater(function()
                    self:UpdatePageTitle()
                end, 100)
            end,
            width = "full",
            default = 1,
        },
        -- UI SECTION
        {
            type = "header",
            name = "Save"
        },
        {
            type = "editbox",
            name = "Build Name",
            getFunc = function() return buildName end,
            setFunc = function(value) buildName = value or "" end,
        },
        {
            type = "slider",
            name = "Save to Slot",
            min = 1,
            max = 12,
            step = 1,
            getFunc = function() return saveSlot end,
            setFunc = function(value) saveSlot = value end,
        },
        -- Save All Button (Original)
        {
            type = "button",
            name = function()
                local slotName = self:GetSlotName(saveSlot)
                if slotName then
                    return "Save All to Slot " .. saveSlot .. " (will overwrite '" .. slotName .. "')"
                else
                    return "Save All to Slot " .. saveSlot .. " (empty)"
                end
            end,
            func = function()
                if buildName and buildName ~= "" then
                    self:SaveBuildToSlot(buildName, saveSlot)
                    self:ShowNotification("Saved '" .. buildName .. "'")

                    self:UpdateSlotsDisplay()
                else
                    ArmoryM:DebugPrint("|cFF0000Build name cannot be empty|r")
                end
            end,
            disabled = function() return buildName == "" end,
            width = "full",
        },
        -- New Save Gear Only Button
        {
            type = "button",
            name = function()
                local slotName = self:GetSlotName(saveSlot)
                if slotName then
                    return "Save Gear Only to Slot " .. saveSlot
                else
                    return "Save Gear Only to Slot " .. saveSlot
                end
            end,
            func = function()
                local name = buildName
                if name == "" then
                    local slotName = self:GetSlotName(saveSlot)
                    name = slotName or ("Build " .. saveSlot)
                end

                self:SaveGearToSlot(name, saveSlot)
                self:ShowNotification("Saved gear to slot " .. saveSlot)

                self:UpdateSlotsDisplay()
            end,
            disabled = function()
                -- Allow saving gear if there's already a name in the slot, or if user provided a name
                local slotName = self:GetSlotName(saveSlot)
                return not slotName and buildName == ""
            end,
            width = "half",
        },
        -- New Save Skills Only Button
        {
            type = "button",
            name = function()
                local slotName = self:GetSlotName(saveSlot)
                if slotName then
                    return "Save Skills Only to Slot " .. saveSlot
                else
                    return "Save Skills Only to Slot " .. saveSlot
                end
            end,
            func = function()
                local name = buildName
                if name == "" then
                    local slotName = self:GetSlotName(saveSlot)
                    name = slotName or ("Build " .. saveSlot)
                end

                self:SaveSkillsToSlot(name, saveSlot)
                self:ShowNotification("Saved skills to slot " .. saveSlot)

                self:UpdateSlotsDisplay()
            end,
            disabled = function()
                -- Allow saving skills if there's already a name in the slot, or if user provided a name
                local slotName = self:GetSlotName(saveSlot)
                return not slotName and buildName == ""
            end,
            width = "half",
        },
        {
            type = "button",
            name = "Toggle UI",
            func = function()
                self:ToggleBuildSlots()
            end,
        },
        {
            type = "description",
            text = "Tutorials",
            tooltip = [[*Save both bars
1. Close this menu
2. Swap bars
3. Done!]]
        },
        -- DELETE
        {
            type = "header",
            name = "Delete"
        },
        {
            type = "slider",
            name = "Delete from Slot",
            min = 1,
            max = 12,
            step = 1,
            getFunc = function() return deleteSlot end,
            setFunc = function(value) deleteSlot = value end,
        },
        {
            type = "button",
            name = function()
                local slotName = self:GetSlotName(deleteSlot)
                if slotName then
                    return "Delete"
                else
                    return "Delete"
                end
            end,
            func = function()
                local slotName = self:GetSlotName(deleteSlot)
                if slotName then
                    self:DeleteBuildFromSlot(deleteSlot)
                    self:ShowNotification("Deleted '" .. slotName .. "'")
                    self:UpdateSlotsDisplay()
                else
                    ArmoryM:DebugPrint("|cFF0000Slot " .. deleteSlot .. " is already empty|r")
                end
            end,
            disabled = function() return not self:GetSlotName(deleteSlot) end,
        },

        -- [Rest of your existing settings menu code]
        {
            type = "header",
            name = "UI Settings"
        },
        {
            type = "checkbox",
            name = "Keep UI Open",
            getFunc = function() return self.savedVars.keepUIOpen end,
            setFunc = function(value)
                self.savedVars.keepUIOpen = value
                -- Update the current visibility setting to match
                if self.buildSlotsDisplay and self.buildSlotsDisplay.window then
                    self.savedVars.windowVisible = value
                    self.buildSlotsDisplay.window:SetHidden(not value)
                end
            end,
            width = "full",
            default = false,
        },
        {
            type = "checkbox",
            name = "Vertical Layout",
            getFunc = function() return self.savedVars.layoutVertical end,
            setFunc = function(value)
                self.savedVars.layoutVertical = value
                -- Apply the layout change immediately if the panel is open
                if self.buildSlotsDisplay and self.buildSlotsDisplay.window and not self.buildSlotsDisplay.window:IsHidden() then
                    self:UpdatePanelLayout()
                end
            end,
            width = "full",
            default = false,
        },
        {
            type = "slider",
            name = "Scale",
            min = 0.5,
            max = 2.0,
            step = 0.1,
            decimals = 1,
            getFunc = function() return self.savedVars.uiScale or 1.0 end,
            setFunc = function(value)
                self.savedVars.uiScale = value
                if self.buildSlotsDisplay and self.buildSlotsDisplay.window then
                    self.buildSlotsDisplay.window:SetScale(value)
                end
            end,
            default = 1.0
        },
        {
            type = "slider",
            name = "X Position",
            min = -2000,
            max = 2000,
            step = 10,
            getFunc = function() return self.savedVars.windowX or 0 end,
            setFunc = function(value)
                self.savedVars.windowX = value
                if self.buildSlotsDisplay and self.buildSlotsDisplay.window then
                    self.buildSlotsDisplay.window:ClearAnchors()
                    self.buildSlotsDisplay.window:SetAnchor(CENTER, GuiRoot, CENTER, value, self.savedVars.windowY or 0)
                end
            end,
            default = 0
        },
        {
            type = "slider",
            name = "Y Position",
            min = -2000,
            max = 2000,
            step = 10,
            getFunc = function() return self.savedVars.windowY or 0 end,
            setFunc = function(value)
                self.savedVars.windowY = value
                if self.buildSlotsDisplay and self.buildSlotsDisplay.window then
                    self.buildSlotsDisplay.window:ClearAnchors()
                    self.buildSlotsDisplay.window:SetAnchor(CENTER, GuiRoot, CENTER, self.savedVars.windowX or 0, value)
                end
            end,
            default = 0
        },
        {
            type = "button",
            name = "Center UI",
            func = function()
                if self.buildSlotsDisplay and self.buildSlotsDisplay.window then
                    self.buildSlotsDisplay.window:ClearAnchors()
                    self.buildSlotsDisplay.window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
                    self.buildSlotsDisplay.window:SetScale(1.0)
                    self.savedVars.windowX = 0
                    self.savedVars.windowY = 0
                    self.savedVars.uiScale = 1.0
                end
            end,
            width = "full"
        },
        {
            type = "button",
            name = "Toggle UI",
            func = function()
                self:ToggleBuildSlots()
            end,
        },
        {
            type = "header",
            name = "Progress Bar"
        },
        {
            type = "checkbox",
            name = "Show Progress Bar",
            tooltip = "Show visual progress during gear swapping",
            getFunc = function() return self.savedVars.showProgressBar ~= false end, -- Default to true
            setFunc = function(value)
                self.savedVars.showProgressBar = value
                if not value then
                    self:HideProgressBar() -- Hide immediately if disabled
                end
            end,
            width = "full",
            default = true,
        },
        {
            type = "slider",
            name = "Progress Bar Y Position",
            tooltip = "Vertical position of the progress bar",
            min = -500,
            max = 500,
            step = 10,
            getFunc = function() return self.savedVars.progressBarY or -100 end,
            setFunc = function(value)
                self.savedVars.progressBarY = value
                if ArmoryM_ProgressBar then
                    ArmoryM_ProgressBar:ClearAnchors()
                    ArmoryM_ProgressBar:SetAnchor(CENTER, GuiRoot, CENTER, self.savedVars.progressBarX or 0, value)
                end
            end,
            default = -100
        },
        {
            type = "slider",
            name = "Progress Bar X Position",
            tooltip = "Horizontal position of the progress bar",
            min = -500,
            max = 500,
            step = 10,
            getFunc = function() return self.savedVars.progressBarX or 0 end,
            setFunc = function(value)
                self.savedVars.progressBarX = value
                if ArmoryM_ProgressBar then
                    ArmoryM_ProgressBar:ClearAnchors()
                    ArmoryM_ProgressBar:SetAnchor(CENTER, GuiRoot, CENTER, value, self.savedVars.progressBarY or -100)
                end
            end,
            default = 0
        },
        {
            type = "button",
            name = "Test Progress Bar",
            tooltip = "Show a demo of the progress bar",
            func = function()
                self:ShowProgressBar()
                self:SetPhaseActive(1)

                zo_callLater(function()
                    self:SetPhaseComplete(1)
                    self:SetPhaseActive(2)
                end, 800)

                zo_callLater(function()
                    self:SetPhaseComplete(2)
                    self:SetPhaseActive(3)
                end, 1600)

                zo_callLater(function()
                    self:SetPhaseComplete(3)
                    self:SetPhaseActive(4)
                end, 2400)

                zo_callLater(function()
                    self:SetPhaseComplete(4)
                end, 3200)

                zo_callLater(function()
                    self:HideProgressBar()
                end, 9000)
            end,
            width = "half"
        },
        {
            type = "header",
            name = "Edit Page Names"
        },
        {
            type = "editbox",
            name = "Page 1 Title",
            getFunc = function() return self.savedVars.pageTitle1 end,
            setFunc = function(value)
                self.savedVars.pageTitle1 = value or "Page 1"
                if (self.savedVars.currentPage or 1) == 1 then
                    self:UpdatePageTitle()
                end
            end,
            width = "full",
            default = "Page 1",
        },
        {
            type = "editbox",
            name = "Page 2 Title",
            getFunc = function() return self.savedVars.pageTitle2 end,
            setFunc = function(value)
                self.savedVars.pageTitle2 = value or "Page 2"
                if (self.savedVars.currentPage or 1) == 2 then
                    self:UpdatePageTitle()
                end
            end,
            width = "full",
            default = "Page 2",
        },
        {
            type = "editbox",
            name = "Page 3 Title",
            getFunc = function() return self.savedVars.pageTitle3 end,
            setFunc = function(value)
                self.savedVars.pageTitle3 = value or "Page 3"
                if (self.savedVars.currentPage or 1) == 3 then
                    self:UpdatePageTitle()
                end
            end,
            width = "full",
            default = "Page 3",
        },
        {
            type = "divider",
            width = "full"
        },
        {
            type = "divider",
            width = "full"
        },
        {
            type = "header",
            name = "Support"
        },
        {
            type = "description",
            text = "If you find this addon useful, consider supporting its development!",
            width = "full"
        },
        {
            type = "button",
            name = "Hi",
            tooltip = "paypal.me/yfnatey",
            func = function() RequestOpenUnsafeURL("https://paypal.me/yfnatey") end,
            width = "half"
        },
    }

    LAM:RegisterAddonPanel("ArmoryM", panelData)
    LAM:RegisterOptionControls("ArmoryM", optionsData)
end
