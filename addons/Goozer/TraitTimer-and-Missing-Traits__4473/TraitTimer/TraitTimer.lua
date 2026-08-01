-- TraitTimer - Main Logic
-- Real-time trait research timer HUD for ESO

local ADDON_NAME = "TraitTimer"

TraitTimer = {}
TraitTimer.UI = {}

local TT = TraitTimer

TT.name = ADDON_NAME
TT.version = "1.4.1"

-- Widget dimension constraints
local MIN_WIDGET_WIDTH = 270
local MAX_WIDGET_WIDTH = 800
local MIN_WIDGET_HEIGHT = 28    -- collapsed/minimized minimum (header bar height, see UI.ApplyMinimizedState)
local MIN_EXPANDED_HEIGHT = 80  -- minimum height when expanded and manually resized
local MAX_WIDGET_HEIGHT = 2000

TT.MIN_WIDGET_WIDTH = MIN_WIDGET_WIDTH
TT.MAX_WIDGET_WIDTH = MAX_WIDGET_WIDTH
TT.MAX_WIDGET_HEIGHT = MAX_WIDGET_HEIGHT

-- Craft types that support trait research
TT.RESEARCH_CRAFTS = {
    { type = CRAFTING_TYPE_BLACKSMITHING,  stringId = TT_CRAFT_BLACKSMITHING,  icon = "/esoui/art/tradinghouse/tradinghouse_browse_header_icon_weapons.dds" },
    { type = CRAFTING_TYPE_CLOTHIER,       stringId = TT_CRAFT_CLOTHIER,       icon = "/esoui/art/tradinghouse/tradinghouse_browse_header_icon_apparel.dds" },
    { type = CRAFTING_TYPE_WOODWORKING,    stringId = TT_CRAFT_WOODWORKING,    icon = "/esoui/art/inventory/inventory_tabicon_craftbag_woodworking_up.dds" },
    { type = CRAFTING_TYPE_JEWELRYCRAFTING, stringId = TT_CRAFT_JEWELRY,       icon = "/esoui/art/inventory/inventory_tabicon_craftbag_jewelrycrafting_up.dds" },
}

-- Research data: [craftType] = { entries = {...}, maxSlots, activeCount }
TT.researchData = {}

-- Missing traits data: [craftType] = { entries = {...}, totalMissing, totalKnown, totalTraits }
TT.missingData = {}

-- View mode: "timers" or "missing"
TT.viewMode = "timers"

-- Timer tracking
TT.lastScanTime = 0
TT.FULL_SCAN_INTERVAL = 60

-- SavedVariables defaults
local DEFAULTS = {
    locked = false,
    offsetX = -20,
    offsetY = 80,
    anchorPoint = TOPRIGHT,
    relativePoint = TOPRIGHT,
    minimized = false,
    hideInCombat = true,
    hidden = false,
    viewMode = "timers",
    widgetWidth = 420,
    widgetHeight = nil,
    bgAlpha = 80,
}

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

function TT:GetCraftName(craftType)
    for _, info in ipairs(self.RESEARCH_CRAFTS) do
        if info.type == craftType then
            return GetString(info.stringId)
        end
    end
    return "?"
end

function TT:GetBagsList()
    local bags = { BAG_BACKPACK, BAG_BANK }
    if BAG_SUBSCRIBER_BANK then bags[#bags + 1] = BAG_SUBSCRIBER_BANK end
    return bags
end

---------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------

function TT:Initialize()
    local UI = self.UI

    self.sv = ZO_SavedVars:NewAccountWide("TraitTimerSavedVars", 2, GetWorldName(), DEFAULTS)
    self.viewMode = self.sv.viewMode or "timers"

    local hud = TraitTimerHUD
    hud:ClearAnchors()
    hud:SetAnchor(self.sv.anchorPoint, GuiRoot, self.sv.relativePoint, self.sv.offsetX, self.sv.offsetY)
    hud:SetMovable(not self.sv.locked)
    hud:SetResizeHandleSize(8)
    hud:SetDimensionConstraints(MIN_WIDGET_WIDTH, MIN_WIDGET_HEIGHT, MAX_WIDGET_WIDTH, MAX_WIDGET_HEIGHT)

    -- Tracks traits we've already announced as complete (key "craft:line:trait"),
    -- so the local countdown and the completion event never double-alert or miss one.
    self.notified = {}

    -- Apply background opacity
    local bg = TraitTimerHUDBG
    if bg then bg:SetAlpha((self.sv.bgAlpha or 80) / 100) end

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED,
        function(_, craftType, lineIndex, traitIndex)
            self:OnResearchCompleted(craftType, lineIndex, traitIndex)
        end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_SMITHING_TRAIT_RESEARCH_STARTED,
        function(_, craftType, lineIndex, traitIndex)
            self:OnResearchStarted(craftType, lineIndex, traitIndex)
        end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED,
        function(_, initial)
            self:OnPlayerActivated(initial)
        end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE,
        function(_, inCombat)
            self:OnCombatStateChanged(inCombat)
        end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        function(_, bagId, slotId, isNewItem, itemSoundCategory, updateReason, stackCountChange)
            self:OnInventoryChanged(bagId, updateReason)
        end)

    SLASH_COMMANDS["/traittimer"] = function(args) self:OnSlashCommand(args) end
    SLASH_COMMANDS["/tt"] = function(args) self:OnSlashCommand(args) end

    -- Register LibAddonMenu settings panel (if available)
    if self.InitSettings then self:InitSettings() end
end

---------------------------------------------------------------------------
-- Trait Name (uses ESO's built-in localization)
---------------------------------------------------------------------------

function TT:GetTraitName(traitType)
    local name = GetString("SI_ITEMTRAITTYPE", traitType)
    return (name and name ~= "") and name or "?"
end

---------------------------------------------------------------------------
-- Research Scanning (active timers)
---------------------------------------------------------------------------

function TT:ScanAllResearch()
    self.researchData = {}
    local totalActive = 0

    for _, craftInfo in ipairs(self.RESEARCH_CRAFTS) do
        local craftType = craftInfo.type
        local entries = {}
        local maxSlots = GetMaxSimultaneousSmithingResearch(craftType)
        local activeCount = 0
        local numLines = GetNumSmithingResearchLines(craftType)

        for lineIndex = 1, numLines do
            local lineName, lineIcon, numTraits = GetSmithingResearchLineInfo(craftType, lineIndex)

            for traitIndex = 1, numTraits do
                local traitType, traitDesc, known = GetSmithingResearchLineTraitInfo(craftType, lineIndex, traitIndex)

                if not known then
                    local duration, timeRemaining = GetSmithingResearchLineTraitTimes(craftType, lineIndex, traitIndex)

                    if timeRemaining and timeRemaining > 0 then
                        activeCount = activeCount + 1
                        totalActive = totalActive + 1

                        entries[#entries + 1] = {
                            lineName = lineName,
                            traitName = self:GetTraitName(traitType),
                            traitType = traitType,
                            timeRemaining = timeRemaining,
                            endTime = GetTimeStamp() + timeRemaining,
                            duration = duration,
                            lineIndex = lineIndex,
                            traitIndex = traitIndex,
                        }
                    end
                end
            end
        end

        self.researchData[craftType] = {
            entries = entries,
            maxSlots = maxSlots,
            activeCount = activeCount,
        }
    end

    self.lastScanTime = GetTimeStamp()
    return totalActive
end

---------------------------------------------------------------------------
-- Missing Traits Scanning
---------------------------------------------------------------------------

function TT:ScanMissingTraits()
    self.missingData = {}

    for _, craftInfo in ipairs(self.RESEARCH_CRAFTS) do
        local craftType = craftInfo.type
        local entries = {}
        local totalMissing = 0
        local totalKnown = 0
        local totalTraits = 0
        local numLines = GetNumSmithingResearchLines(craftType)

        for lineIndex = 1, numLines do
            local lineName, lineIcon, numTraits = GetSmithingResearchLineInfo(craftType, lineIndex)
            local missingTraits = {}
            local knownCount = 0

            for traitIndex = 1, numTraits do
                local traitType, traitDesc, known = GetSmithingResearchLineTraitInfo(craftType, lineIndex, traitIndex)
                totalTraits = totalTraits + 1

                if known then
                    knownCount = knownCount + 1
                    totalKnown = totalKnown + 1
                else
                    local duration, timeRemaining = GetSmithingResearchLineTraitTimes(craftType, lineIndex, traitIndex)
                    if not (timeRemaining and timeRemaining > 0) then
                        totalMissing = totalMissing + 1
                        missingTraits[#missingTraits + 1] = {
                            name = self:GetTraitName(traitType),
                            traitType = traitType,
                            traitIndex = traitIndex,
                        }
                    end
                end
            end

            if #missingTraits > 0 then
                entries[#entries + 1] = {
                    lineName = lineName,
                    lineIndex = lineIndex,
                    missingTraits = missingTraits,
                    knownCount = knownCount,
                    totalTraits = numTraits,
                }
            end
        end

        self.missingData[craftType] = {
            entries = entries,
            totalMissing = totalMissing,
            totalKnown = totalKnown,
            totalTraits = totalTraits,
        }
    end

    self:ScanOwnedTraits()
end

---------------------------------------------------------------------------
-- Owned Traits Scanning (inventory + bank)
-- Uses GetItemTraitInformation (works outside crafting stations)
-- with CanItemBeSmithingTraitResearched for exact line matching
---------------------------------------------------------------------------

function TT:ScanOwnedTraits()
    self.ownedTraits = {}

    -- Exact line matching requires this API; without it we can't confirm an item
    -- researches a specific line, so we skip ownership rather than risk false positives.
    if not CanItemBeSmithingTraitResearched then return end

    -- Build lookup by traitType only (GetItemCraftingInfo returns 0 for gear)
    local needMap = {}
    for _, craftInfo in ipairs(self.RESEARCH_CRAFTS) do
        local craftType = craftInfo.type
        local data = self.missingData[craftType]
        if data then
            for _, entry in ipairs(data.entries) do
                for _, trait in ipairs(entry.missingTraits) do
                    if not needMap[trait.traitType] then needMap[trait.traitType] = {} end
                    table.insert(needMap[trait.traitType], {
                        craftType = craftType,
                        lineIndex = entry.lineIndex,
                        traitIndex = trait.traitIndex,
                    })
                end
            end
        end
    end

    for _, bagId in ipairs(self:GetBagsList()) do
        local bagSize = GetBagSize(bagId)
        for slotIndex = 0, bagSize - 1 do
            local link = GetItemLink(bagId, slotIndex)
            if link and link ~= "" then
                local traitInformation = GetItemTraitInformation(bagId, slotIndex)
                if traitInformation == ITEM_TRAIT_INFORMATION_CAN_BE_RESEARCHED then
                    local traitType = GetItemTrait(bagId, slotIndex)

                    if traitType and needMap[traitType] then
                        -- Only mark a line as owned when the game confirms this exact
                        -- item can research it (no fallback, to avoid false positives).
                        for _, lineInfo in ipairs(needMap[traitType]) do
                            if CanItemBeSmithingTraitResearched(bagId, slotIndex, lineInfo.craftType, lineInfo.lineIndex, lineInfo.traitIndex) then
                                self:MarkOwnedTrait(lineInfo.craftType, lineInfo.lineIndex, traitType)
                            end
                        end
                    end
                end
            end
        end
    end
end

function TT:MarkOwnedTrait(craftType, lineIndex, traitType)
    if not self.ownedTraits[craftType] then self.ownedTraits[craftType] = {} end
    if not self.ownedTraits[craftType][lineIndex] then self.ownedTraits[craftType][lineIndex] = {} end
    self.ownedTraits[craftType][lineIndex][traitType] = true
end

function TT:HasOwnedTrait(craftType, lineIndex, traitType)
    return self.ownedTraits
        and self.ownedTraits[craftType]
        and self.ownedTraits[craftType][lineIndex]
        and self.ownedTraits[craftType][lineIndex][traitType]
end

---------------------------------------------------------------------------
-- Time Formatting
---------------------------------------------------------------------------

function TT.FormatTime(seconds)
    if not seconds or seconds <= 0 then
        return GetString(TT_STATUS_DONE)
    end

    seconds = math.floor(seconds)
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60

    if days > 0 then
        return zo_strformat(GetString(TT_TIME_DAYS), days, hours, minutes)
    elseif hours > 0 then
        return zo_strformat(GetString(TT_TIME_HOURS), hours, minutes, secs)
    else
        return zo_strformat(GetString(TT_TIME_MINUTES), minutes, secs)
    end
end

---------------------------------------------------------------------------
-- Timer Update (called every second)
---------------------------------------------------------------------------

function TT:UpdateTimers()
    if self.viewMode ~= "timers" then return end

    local UI = self.UI
    local now = GetTimeStamp()
    local needsRescan = (now - self.lastScanTime) >= self.FULL_SCAN_INTERVAL

    if needsRescan then
        self:ScanAllResearch()
        UI:Rebuild()
        return
    end

    local needsRebuild = false
    for _, craftInfo in ipairs(self.RESEARCH_CRAFTS) do
        local craftType = craftInfo.type
        local data = self.researchData[craftType]

        if data then
            for i = #data.entries, 1, -1 do
                local research = data.entries[i]
                research.timeRemaining = research.endTime - now

                if research.timeRemaining <= 0 then
                    if self:ShouldNotify(craftType, research.lineIndex, research.traitIndex) then
                        self:NotifyResearchComplete(craftType, research)
                    end
                    table.remove(data.entries, i)
                    data.activeCount = data.activeCount - 1
                    needsRebuild = true
                end
            end
        end
    end

    if needsRebuild then
        UI:Rebuild()
    else
        UI:UpdateTimerLabels()
    end
end

---------------------------------------------------------------------------
-- View Mode Toggle
---------------------------------------------------------------------------

function TT:ToggleViewMode()
    if self.viewMode == "timers" then
        self.viewMode = "missing"
        self:ScanMissingTraits()
    else
        self.viewMode = "timers"
        self:ScanAllResearch()
    end
    self.sv.viewMode = self.viewMode
    self.UI:Rebuild()
end

---------------------------------------------------------------------------
-- Event Handlers
---------------------------------------------------------------------------

function TT:OnPlayerActivated(initial)
    local UI = self.UI

    self:ScanAllResearch()
    self:ScanMissingTraits()

    if not self.sv.hidden then
        TraitTimerHUD:SetHidden(false)
    end

    UI:Rebuild()

    EVENT_MANAGER:UnregisterForUpdate(self.name .. "_Update")
    EVENT_MANAGER:RegisterForUpdate(self.name .. "_Update", 1000, function()
        self:UpdateTimers()
    end)

    -- EVENT_PLAYER_ACTIVATED also fires on every loading screen (zone change,
    -- wayshrine, /reloadui). The login-only work below must not run each time.
    if not initial then return end

    -- Delayed re-scan: bag/trait data may not be fully ready at login
    zo_callLater(function()
        self:ScanMissingTraits()
        UI:Rebuild()
    end, 2000)

    -- Free-slot alert: only for crafts that still have traits left to research
    -- (a free slot with nothing left to research is normal, not worth alerting).
    for _, craftInfo in ipairs(self.RESEARCH_CRAFTS) do
        local craftType = craftInfo.type
        local data = self.researchData[craftType]
        local missing = self.missingData[craftType]
        if data and missing and missing.totalMissing > 0 then
            local freeSlots = data.maxSlots - data.activeCount
            if freeSlots > 0 then
                CHAT_SYSTEM:AddMessage(zo_strformat(GetString(TT_ALERT_FREE_SLOT), self:GetCraftName(craftType)))
            end
        end
    end
end

function TT:OnResearchCompleted(craftType, lineIndex, traitIndex)
    -- Authoritative completion signal from the game; notify here (deduped against
    -- the local countdown) so we alert even if the event beats the countdown to 0.
    if self:ShouldNotify(craftType, lineIndex, traitIndex) then
        local lineName = GetSmithingResearchLineInfo(craftType, lineIndex)
        local traitType = GetSmithingResearchLineTraitInfo(craftType, lineIndex, traitIndex)
        self:NotifyResearchComplete(craftType, {
            lineName = lineName,
            traitName = self:GetTraitName(traitType),
        })
    end

    self:ScanAllResearch()
    self:ScanMissingTraits()
    self.UI:Rebuild()
end

function TT:OnResearchStarted(craftType, lineIndex, traitIndex)
    self:ScanAllResearch()
    self:ScanMissingTraits()
    self.UI:Rebuild()
end

function TT:OnInventoryChanged(bagId, updateReason)
    if updateReason ~= INVENTORY_UPDATE_REASON_DEFAULT then return end

    if bagId ~= BAG_BACKPACK and bagId ~= BAG_BANK
        and (not BAG_SUBSCRIBER_BANK or bagId ~= BAG_SUBSCRIBER_BANK) then
        return
    end

    if self.inventoryUpdatePending then return end
    self.inventoryUpdatePending = true

    local UI = self.UI
    zo_callLater(function()
        self.inventoryUpdatePending = false
        self:ScanOwnedTraits()
        if self.viewMode == "missing" then
            UI:Rebuild()
        end
    end, 500)
end

function TT:OnCombatStateChanged(inCombat)
    if self.sv.hideInCombat and not self.sv.hidden then
        TraitTimerHUD:SetHidden(inCombat)
    end
end

---------------------------------------------------------------------------
-- Notifications
---------------------------------------------------------------------------

-- Returns true only the first time a given trait completion is seen, so the
-- countdown and the completion event can both call in without double-alerting.
function TT:ShouldNotify(craftType, lineIndex, traitIndex)
    local key = craftType .. ":" .. lineIndex .. ":" .. traitIndex
    if self.notified[key] then return false end
    self.notified[key] = true
    return true
end

function TT:NotifyResearchComplete(craftType, research)
    local craftName = self:GetCraftName(craftType)
    local itemName = research.lineName or "?"
    local traitName = research.traitName or "?"

    CHAT_SYSTEM:AddMessage(zo_strformat(GetString(TT_ALERT_CHAT), craftName, itemName, traitName))

    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.QUEST_COMPLETED,
        zo_strformat(GetString(TT_ALERT_COMPLETE), itemName, traitName))

    local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.QUEST_COMPLETED)
    params:SetText(zo_strformat(GetString(TT_ALERT_COMPLETE), itemName, traitName))
    params:SetLifespanMS(5000)
    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
end

---------------------------------------------------------------------------
-- Widget Position Save
---------------------------------------------------------------------------

function TT.OnHUDMoveStop()
    local sv = TT.sv
    local _, point, _, relPoint, offsetX, offsetY = TraitTimerHUD:GetAnchor(0)
    sv.anchorPoint = point
    sv.relativePoint = relPoint
    sv.offsetX = offsetX
    sv.offsetY = offsetY
end

---------------------------------------------------------------------------
-- Widget Resize Save
---------------------------------------------------------------------------

function TT.OnHUDResizeStop()
    local sv = TT.sv
    local UI = TT.UI
    local width = TraitTimerHUD:GetWidth()
    width = math.max(MIN_WIDGET_WIDTH, math.min(MAX_WIDGET_WIDTH, math.floor(width)))
    sv.widgetWidth = width

    -- Only save height if not minimized (minimized height is not meaningful)
    if not sv.minimized then
        local height = TraitTimerHUD:GetHeight()
        height = math.max(MIN_EXPANDED_HEIGHT, math.floor(height))
        sv.widgetHeight = height
    end

    UI:ApplyWidth(width)
    UI:Rebuild()
end

---------------------------------------------------------------------------
-- Minimize / Expand
---------------------------------------------------------------------------

function TT.ToggleMinimize()
    local sv = TT.sv
    local UI = TT.UI
    sv.minimized = not sv.minimized
    if sv.minimized then
        UI:ApplyMinimizedState()
    else
        UI:Rebuild()
    end
end

---------------------------------------------------------------------------
-- Slash Commands
---------------------------------------------------------------------------

function TT:OnSlashCommand(args)
    local UI = self.UI
    local cmd = string.lower(args or "")

    if cmd == "lock" then
        self.sv.locked = not self.sv.locked
        TraitTimerHUD:SetMovable(not self.sv.locked)
        if self.sv.locked then
            CHAT_SYSTEM:AddMessage(GetString(TT_CMD_LOCKED))
        else
            CHAT_SYSTEM:AddMessage(GetString(TT_CMD_UNLOCKED))
        end

    elseif cmd == "missing" then
        self:ToggleViewMode()

    elseif cmd == "scan" then
        local total = self:ScanAllResearch()
        self:ScanMissingTraits()
        UI:Rebuild()
        CHAT_SYSTEM:AddMessage(GetString(TT_CMD_SCAN_HEADER))

        if total == 0 then
            CHAT_SYSTEM:AddMessage(GetString(TT_CMD_SCAN_NONE))
        else
            for _, craftInfo in ipairs(self.RESEARCH_CRAFTS) do
                local data = self.researchData[craftInfo.type]
                if data then
                    local craftName = self:GetCraftName(craftInfo.type)
                    for _, r in ipairs(data.entries) do
                        CHAT_SYSTEM:AddMessage(zo_strformat(GetString(TT_CMD_SCAN_LINE),
                            craftName, r.lineName, r.traitName, self.FormatTime(r.timeRemaining)))
                    end
                end
            end
        end

    elseif string.find(cmd, "^width") then
        local widthStr = string.match(cmd, "^width%s+(%d+)")
        if widthStr then
            local newWidth = tonumber(widthStr)
            if newWidth and newWidth >= MIN_WIDGET_WIDTH and newWidth <= MAX_WIDGET_WIDTH then
                self.sv.widgetWidth = newWidth
                UI:ApplyWidth(newWidth)
                UI:Rebuild()
                CHAT_SYSTEM:AddMessage(zo_strformat(GetString(TT_CMD_WIDTH_SET), newWidth))
            else
                CHAT_SYSTEM:AddMessage(zo_strformat(GetString(TT_CMD_WIDTH_RANGE), MIN_WIDGET_WIDTH, MAX_WIDGET_WIDTH))
            end
        else
            CHAT_SYSTEM:AddMessage(zo_strformat(GetString(TT_CMD_WIDTH_CURRENT), self.sv.widgetWidth or 420))
        end

    elseif cmd == "help" then
        CHAT_SYSTEM:AddMessage(GetString(TT_CMD_HELP))

    else
        self.sv.hidden = not self.sv.hidden
        TraitTimerHUD:SetHidden(self.sv.hidden)
        if self.sv.hidden then
            CHAT_SYSTEM:AddMessage(GetString(TT_CMD_HIDDEN))
        else
            CHAT_SYSTEM:AddMessage(GetString(TT_CMD_SHOWN))
        end
    end
end

---------------------------------------------------------------------------
-- Addon Loaded
---------------------------------------------------------------------------

local function OnAddonLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    TT:Initialize()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
