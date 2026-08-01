--=============================================================================
-- SLASH COMMANDS
--=============================================================================

-- Quick load commands (1-12)
for i = 1, 12 do
    SLASH_COMMANDS["/" .. i] = function()
        ArmoryM:LoadBuildSlashCommand(i)
    end
end

-- Main command handlers
SLASH_COMMANDS["/arm"] = function(args)
    ArmoryM:HandleArmoryCommand(args)
end

SLASH_COMMANDS["/armhelp"] = function()
    ArmoryM:ShowArmoryHelp()
end

-- UI control commands
SLASH_COMMANDS["/taskbar"] = function()
    ArmoryM:ToggleTaskbar()
end

SLASH_COMMANDS["/taskbarlayout"] = function()
    ArmoryM:ToggleTaskbarLayout()
end

-- Separate action commands
SLASH_COMMANDS["/armsavegear"] = function(slotNumber)
    local slot = tonumber(slotNumber)
    if not slot or slot < 1 or slot > 12 then
        d("Usage: /armsavegear <slot number 1-12>")
        return
    end

    local slotData = ArmoryM.savedVars.slots[slot]
    local buildName = slotData and slotData.name or ("Build " .. slot)

    if ArmoryM:SaveGearToSlot(buildName, slot) then
        d("Saved gear to slot " .. slot .. " ('" .. buildName .. "')")
    end
end

SLASH_COMMANDS["/armsaveskills"] = function(slotNumber)
    local slot = tonumber(slotNumber)
    if not slot or slot < 1 or slot > 12 then
        d("Usage: /armsaveskills <slot number 1-12>")
        return
    end

    local slotData = ArmoryM.savedVars.slots[slot]
    local buildName = slotData and slotData.name or ("Build " .. slot)

    if ArmoryM:SaveSkillsToSlot(buildName, slot) then
        local currentBar = GetActiveWeaponPairInfo()
        d(string.format("Saved bar %d skills to slot %d ('%s')", currentBar, slot, buildName))
        d("Switch bars to save the other bar's skills")
    end
end

SLASH_COMMANDS["/arm g"] = function(slotNumber)
    local slot = tonumber(slotNumber)
    if not slot or slot < 1 or slot > 12 then
        d("Usage: /arm g <slot number 1-12>")
        return
    end

    if ArmoryM:LoadGearFromSlot(slot) then
        local buildName = ArmoryM:GetSlotName(slot)
        d("Loaded gear from '" .. buildName .. "'")
    end
end

SLASH_COMMANDS["/arm s"] = function(slotNumber)
    local slot = tonumber(slotNumber)
    if not slot or slot < 1 or slot > 12 then
        d("Usage: /arm s <slot number 1-12>")
        return
    end

    if ArmoryM:LoadAllSkillsFromSlot(slot) then
        local buildName = ArmoryM:GetSlotName(slot)
        d("Loaded skills from '" .. buildName .. "'")
    end
end

-- Maintenance commands
SLASH_COMMANDS["/devarmcheck"] = function(slotNumber)
    local slot = tonumber(slotNumber) or 1
    local slotData = ArmoryM.savedVars.slots[slot]

    if not slotData or not slotData.gear then
        d("Slot " .. slot .. " is empty")
        return
    end

    d("=== CHECKING SLOT " .. slot .. " ===")
    local foundItems = 0
    local missingItems = 0

    for gearSlot, itemData in pairs(slotData.gear) do
        if itemData.uniqueId then
            local location = ArmoryM:FindItemAnywhere(itemData.uniqueId)
            local status = location and "FOUND" or "MISSING"
            d(string.format("Slot %d: %s - %s", gearSlot, GetItemLinkName(itemData.itemLink), status))

            if location then
                foundItems = foundItems + 1
            else
                missingItems = missingItems + 1
            end
        end
    end

    d(string.format("Summary: %d found, %d missing", foundItems, missingItems))

    if missingItems > 0 then
        d("|cFF0000Some items are missing! This slot has corrupted data.|r")
        d("|cFFFF00Fix: Load this build manually and run /armresave " .. slot .. "|r")
    end
end

SLASH_COMMANDS["/armresave"] = function(slotNumber)
    local slot = tonumber(slotNumber)
    if not slot or slot < 1 or slot > 12 then
        d("Usage: /armresave <slot number 1-12>")
        return
    end

    local slotData = ArmoryM.savedVars.slots[slot]
    if not slotData then
        d("Slot " .. slot .. " is empty!")
        return
    end

    -- Keep the name and skills, just update the gear
    local buildName = slotData.name
    local currentBar = GetActiveWeaponPairInfo()

    -- Save current gear over the old gear
    slotData.gear = ArmoryM:SaveCurrentGear()

    -- Update gear tracking
    if slotData.savedComponents then
        slotData.savedComponents.gear = true
    end

    -- Save current skills for this bar
    ArmoryM:SaveCurrentSkillsToSlot(slot, currentBar)

    d("Re-saved current state to slot " .. slot .. " ('" .. buildName .. "')")
    d("Switch bars to save the other bar's skills")
end

SLASH_COMMANDS["/devarmbackup"] = function()
    ArmoryM:CreateBackup()
    ArmoryM:DebugPrint("Manual backup created")
end

SLASH_COMMANDS["/devarmvalidate"] = function()
    local issues = ArmoryM:ValidateSavedVars()

    if #issues == 0 then
        d("SavedVars validation passed - no issues found")
    else
        ArmoryM:DebugPrint("Found " .. #issues .. " validation issues:")
        for i, issue in ipairs(issues) do
            d("  " .. i .. ". " .. issue)
        end
        ArmoryM:DebugPrint("|cFFFF00Run /armrepair to attempt automatic repair|r")
    end
end

SLASH_COMMANDS["/devarmrepair"] = function()
    ArmoryM:DebugPrint("Attempting to repair SavedVars...")
    local success = ArmoryM:RepairSavedVars()

    if success then
        ArmoryM:DebugPrint("Repair completed")
    else
        ArmoryM:DebugPrint("Repair failed")
    end
end

SLASH_COMMANDS["/devarmfix"] = function()
    d("Checking all slots for corruption...")

    local totalSlots = 0
    local corruptedSlots = 0

    for slotNum, slotData in pairs(ArmoryM.savedVars.slots or {}) do
        totalSlots = totalSlots + 1

        if slotData and slotData.gear then
            local needsFix = false

            -- Check if any gear items are missing
            for gearSlot, itemData in pairs(slotData.gear) do
                if itemData.uniqueId and not ArmoryM:FindItemAnywhere(itemData.uniqueId) then
                    needsFix = true
                    break
                end
            end

            if needsFix then
                corruptedSlots = corruptedSlots + 1
                ArmoryM:DebugPrint("Slot " .. slotNum .. " (" .. slotData.name .. ") has corrupted gear data")
                ArmoryM:DebugPrint("   |cFFFF00Fix: Load manually and run /armresave " .. slotNum .. "|r")
            else
                ArmoryM:DebugPrint("Slot " .. slotNum .. " (" .. slotData.name .. ") is OK")
            end
        end
    end

    ArmoryM:DebugPrint(string.format("=== SUMMARY: %d/%d slots have issues ===", corruptedSlots, totalSlots))

    if corruptedSlots > 0 then
        ArmoryM:DebugPrint("|cFF0000" .. corruptedSlots .. " slots need fixing!|r")
        ArmoryM:DebugPrint("|cFFFF00Use /armcheck <slot> for detailed info on specific slots|r")
    else
        ArmoryM:DebugPrint("|c00FF00All slots are healthy!|r")
    end
end

--=============================================================================
-- COMMAND HANDLING FUNCTIONS
--=============================================================================

-- Handle the slash command loading
function ArmoryM:LoadBuildSlashCommand(slotNumber)
    local buildName = self:GetSlotName(slotNumber)
    if self.UpdateSlotsDisplay then
        self:UpdateSlotsDisplay()
    end
    if buildName then
        self:LoadBuildFromSlot(slotNumber)
        self:ShowNotification("Equipped: " .. buildName, 2000)
        d(string.format("Equipping '%s'|r", buildName))
    else
        d(string.format("|cFF0000|Slot %d is empty - nothing to equip|r", slotNumber))
    end
end

-- Handle main armory command with arguments
function ArmoryM:HandleArmoryCommand(args)
    if not args or args == "" then
        self:ShowArmoryHelp()
        return
    end

    -- Split arguments - both formats: "arm save" and "armsave"
    local fullCommand = string.lower(args)
    local command, remaining

    -- Check for common commands with both formats
    if fullCommand:match("^save%s+") then
        command = "save"
        remaining = fullCommand:match("^save%s+(.*)")
    elseif fullCommand:match("^savegear%s*") then
        command = "savegear"
        remaining = fullCommand:match("^savegear%s*(.*)")
    elseif fullCommand:match("^saveskills%s*") then
        command = "saveskills"
        remaining = fullCommand:match("^saveskills%s*(.*)")
    elseif fullCommand:match("^loadgear%s*") then
        command = "loadgear"
        remaining = fullCommand:match("^loadgear%s*(.*)")
    elseif fullCommand:match("^loadskills%s*") then
        command = "loadskills"
        remaining = fullCommand:match("^loadskills%s*(.*)")
    elseif fullCommand:match("^list%s*") then
        command = "list"
        remaining = ""
    elseif fullCommand:match("^toggle%s*") or fullCommand:match("^window%s*") then
        command = "toggle"
        remaining = ""
    elseif fullCommand:match("^page%s*") then
        command = "page"
        remaining = fullCommand:match("^page%s*(.*)")
    elseif fullCommand:match("^help%s*") then
        command = "help"
        remaining = ""
    else
        -- Fall back to the old parsing for other commands
        command = string.lower(string.match(args, "^(%S+)"))
        remaining = string.match(args, "^%S+%s*(.*)")
    end

    -- Process the command
    if command == "help" then
        self:ShowArmoryHelp()
    elseif command == "list" then
        self:ListBuilds()
    elseif command == "toggle" or command == "window" then
        self:ToggleBuildSlots()
    elseif command == "save" then
        self:HandleSaveCommand(remaining)
    elseif command == "savegear" then
        self:HandleSaveGearCommand(remaining)
    elseif command == "saveskills" then
        self:HandleSaveSkillsCommand(remaining)
    elseif command == "arm g" then
        self:HandleLoadGearCommand(remaining)
    elseif command == "arm s" then
        self:HandleLoadSkillsCommand(remaining)
    elseif command == "page" then
        self:HandlePageCommand(remaining)
    else
        d("|cFF0000|Unknown command. Type '/arm help'|r")
    end
end

-- Helper functions for command handling
function ArmoryM:HandlePageCommand(args)
    if not args or args == "" then
        -- Show current page if no arguments
        local currentPage = self.savedVars.currentPage or 1
        local startSlot = ((currentPage - 1) * 4 + 1)
        local endSlot = (currentPage * 4)
        d(string.format("|c00FF8C|Currently viewing Page %d (Slots %d-%d)|r", currentPage, startSlot,
            endSlot))
        return
    end

    local pageNum = tonumber(args)

    if not pageNum or pageNum < 1 or pageNum > 3 then
        d("|cFF0000|Page number must be 1, 2, or 3|r")
        d("|cFFFF00|Usage: /arm page <1|2|3>|r")
        return
    end

    self.savedVars.currentPage = pageNum
    self:ChangePage(pageNum)

    local startSlot = ((pageNum - 1) * 4 + 1)
    local endSlot = (pageNum * 4)
    d(string.format("|c00FF8C|Page %d|r", pageNum))
end

-- Handle save command with build name and slot
function ArmoryM:HandleSaveCommand(args)
    local slotNum = tonumber(string.match(args, "^(%d+)"))
    local buildName = string.match(args, "^%d+%s+(.*)")

    if not slotNum or slotNum < 1 or slotNum > 12 then
        d("|cFF0000|Slot number must be 1-12|r")
        return
    end

    if not buildName or buildName == "" then
        d("|cFF0000|Build name cannot be empty|r")
        return
    end

    -- Check if slot is occupied
    local existingBuild = self:GetSlotName(slotNum)
    if existingBuild then
        d(string.format("|cFFFF00|Overwriting slot %d, '%s'.|r", slotNum, existingBuild))
        d(string.format("Swap bars to finish saving"))
    end

    self:SaveBuildToSlot(buildName, slotNum)
    self:ShowNotification("Saved: " .. buildName, 2000)
end

-- Helper function to handle the savegear command
function ArmoryM:HandleSaveGearCommand(args)
    local slotNum = tonumber(args)

    if not slotNum or slotNum < 1 or slotNum > 12 then
        d("|cFF0000|Slot number must be 1-12|r")
        return
    end

    local slotData = self.savedVars.slots[slotNum]
    local buildName = slotData and slotData.name or ("Build " .. slotNum)

    self:SaveGearToSlot(buildName, slotNum)
    self:ShowNotification("Saved gear to: " .. buildName, 2000)
end

-- Helper function to handle the saveskills command
function ArmoryM:HandleSaveSkillsCommand(args)
    local slotNum = tonumber(args)

    if not slotNum or slotNum < 1 or slotNum > 12 then
        d("|cFF0000|Slot number must be 1-12|r")
        return
    end

    local slotData = self.savedVars.slots[slotNum]
    local buildName = slotData and slotData.name or ("Build " .. slotNum)

    self:SaveSkillsToSlot(buildName, slotNum)
    self:ShowNotification("Saved skills to: " .. buildName, 2000)
end

-- Helper function to handle the loadgear command
function ArmoryM:HandleLoadGearCommand(args)
    local slotNum = tonumber(args)

    if not slotNum or slotNum < 1 or slotNum > 12 then
        d("|cFF0000|Slot number must be 1-12|r")
        return
    end

    local status = self:GetSlotSaveStatus(slotNum)
    if not status.name then
        d("|cFF0000|Slot " .. slotNum .. " is empty|r")
        return
    end

    if not status.hasGear then
        d("|cFF0000|No gear saved in slot " .. slotNum .. "|r")
        return
    end

    self:LoadGearFromSlot(slotNum)
    self:ShowNotification("Loaded gear from: " .. status.name, 2000)
end

-- Helper function to handle the loadskills command
function ArmoryM:HandleLoadSkillsCommand(args)
    local slotNum = tonumber(args)

    if not slotNum or slotNum < 1 or slotNum > 12 then
        d("|cFF0000|Slot number must be 1-12|r")
        return
    end

    local status = self:GetSlotSaveStatus(slotNum)
    if not status.name then
        d("|cFF0000|Slot " .. slotNum .. " is empty|r")
        return
    end

    if not status.hasSkills or (not status.hasSkills[1] and not status.hasSkills[2]) then
        d("|cFF0000|No skills saved in slot " .. slotNum .. "|r")
        return
    end

    self:LoadAllSkillsFromSlot(slotNum)
    self:ShowNotification("Loaded skills from: " .. status.name, 2000)
end

-- Show help information - updated to include new commands
function ArmoryM:ShowArmoryHelp()
    d("  |cFFFF00|/arm save <slot> <name>|r - Save complete build (gear + skills)")
    d("  |cFFFF00|/arm savegear <slot>|r - Save only gear to slot")
    d("  |cFFFF00|/arm saveskills <slot>|r - Save only skills to slot")
    d("  |cFFFF00|/arm list|r - List all saved builds")
    d("  |cFFFF00|/arm toggle|r - Toggle build window")
    d("  |cFFFF00|/arm page <1|2|3>|r - Switch panel page")
end

-- List builds to show what's saved in each slot
function ArmoryM:ListBuilds()
    d("|c00FF8C|Saved Builds|r")

    local hasBuilds = false
    local currentBuild = self.savedVars.currentBuild

    for i = 1, 12 do
        local status = self:GetSlotSaveStatus(i)
        if not status.isEmpty then
            hasBuilds = true
            local activeStatus = ""
            if status.name == currentBuild then
                activeStatus = " |c00FF00|(ACTIVE)|r"
            end

            -- Show saved components
            local components = ""
            if status.hasGear then
                components = components .. "Gear"
            else
                components = components .. "-"
            end

            if status.hasSkills[1] and status.hasSkills[2] then
                components = components .. "Skill"
            else
                components = components .. "-"
            end

            d(string.format("|cFFFF00|%d: %s [%s]%s|r", i, status.name, components, activeStatus))
        else
            d(string.format("|cFFFF00|%d: |c888888|Empty|r", i))
        end
    end

    if not hasBuilds then
        d("|c888888|No builds saved yet|r")
    end
end

--=============================================================================
-- VALIDATION FUNCTIONS
--=============================================================================

function ArmoryM:ValidateSavedVars()
    local issues = {}

    -- Check basic structure
    if not self.savedVars then
        table.insert(issues, "savedVars is nil")
        return issues
    end

    if not self.savedVars.slots or type(self.savedVars.slots) ~= "table" then
        table.insert(issues, "slots table is missing or invalid")
    end

    -- Check individual slots
    if self.savedVars.slots then
        for slotNum, slotData in pairs(self.savedVars.slots) do
            if type(slotData) ~= "table" then
                table.insert(issues, "Slot " .. slotNum .. " is not a table")
            elseif not slotData.name or slotData.name == "" then
                table.insert(issues, "Slot " .. slotNum .. " has invalid name")
            elseif not slotData.skills or type(slotData.skills) ~= "table" then
                table.insert(issues, "Slot " .. slotNum .. " has invalid skills")
            elseif not slotData.gear or type(slotData.gear) ~= "table" then
                table.insert(issues, "Slot " .. slotNum .. " has invalid gear")
            end
        end
    end

    return issues
end

function ArmoryM:RepairSavedVars()
    local issues = self:ValidateSavedVars()

    if #issues == 0 then
        d("SavedVars validation passed")
        return true
    end

    d("Found " .. #issues .. " issues, attempting repair...")

    -- Try to restore from backup first
    if self:RestoreFromBackup() then
        -- Re-validate after restore
        issues = self:ValidateSavedVars()
        if #issues == 0 then
            d("Repair successful via backup restore")
            return true
        end
    end

    -- Manual repair as last resort
    if not self.savedVars.slots or type(self.savedVars.slots) ~= "table" then
        self.savedVars.slots = {}
        d("Reset slots table")
    end

    -- Remove corrupted slots
    for slotNum, slotData in pairs(self.savedVars.slots) do
        if type(slotData) ~= "table" or not slotData.name or slotData.name == "" then
            self.savedVars.slots[slotNum] = nil
            d("Removed corrupted slot " .. slotNum)
        end
    end

    d("Basic repair completed")
    return true
end
