local libScroll = LibStub:GetLibrary("LibScroll")

PledgeRunner = PledgeRunner or {}
local PR = PledgeRunner

-- set up some global vars
PR.debug = nil
PR.name = "PledgeRunner"
PR.dataBoundaryPattern = "::PR::"
PR.writeGuildNoteSemaphore = false
PR.writeGuildNoteDelay = 0
PR.writeGuildNoteDelayAdd = 5000
PR.DEFAULT_TEXT = ZO_ColorDef:New(0.4627, 0.737, 0.7647, 1)
PR.defaults = {
    selectedGuildId = 1,
    left = 100,
    top = 100,
    width = 700,
    height = 500,
    hidden = false,
    showInChat = false,
    guildEnabled = {false,false,false,false,false},
}
PR.scrollList = nil
PR.dataItems = { [1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {} }
PR.columnWidthUnit = 22
PR.columnUnits = { 0, 2.6, 2.6, 3.7, 0}
PR.currentZoneData = nil
PR.currentZoneBossKills = 0
PR.timerStart = nil
PR.filterQuestCategory = 1
PR.killed_boss_list = {}
PR.active_boss_list = {}

-- set up enums
PR.ACTION = {
    UNDEFINED = 99999999,
    PLEDGE_ZONE_ENTERED = 1,
    PLEDGE_ZONE_STARTED = 2,
    PLEDGE_FINAL_REACHED = 3,
    PLEDGE_ZONE_LEFT = 4,
    PLEDGE_ZONE_ENTERED_VET = 5,
    PLEDGE_ZONE_STARTED_VET = 6,
    PLEDGE_FINAL_REACHED_VET = 7,
    PLEDGE_ZONE_LEFT_VET = 8,
    BOSS_KILLED = 9,
    BOSS_KILLED_VET = 10,
}

function PR.ClearDataItems(guildId)
    if guildId == nil then
        PR.dataItems = { [1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {} }
    else
        PR.dataItems[guildId] = {}
    end
end

-- basic addon register functions
function PR.OnAddOnLoaded(event, addonName)
    if addonName == PR.name then
        EVENT_MANAGER:UnregisterForEvent(PR.name, EVENT_ADD_ON_LOADED)
        PR:Initialize()
    end
end
EVENT_MANAGER:RegisterForEvent(PR.name,EVENT_ADD_ON_LOADED,PR.OnAddOnLoaded)

-- init function
function PR:Initialize()
    self.locale = GetCVar('Language.2')
    if self.locale ~= 'en' and self.locale ~= 'de' then
        self.locale = 'en'
    end
    
    self.savedVariables = ZO_SavedVars:NewAccountWide("PledgeRunnerSavedVariables", 1, nil, self.defaults)
    PledgeRunnerDialog:SetHidden(PR.savedVariables.hidden)
    PR.ClearDataItems()

    -- Create the scrollList
    PR:CreateScrollList()

    if GetDisplayName() == "@flipswitchingmonkey" then
      SLASH_COMMANDS["/rr"] = function(cmd) ReloadUI() end
      PR.debug = true
      PR.savedVariables.history = PR.savedVariables.history or {}
    end 
    SLASH_COMMANDS["/pledgerunner"] = function(cmd) PR.ShowUI() end

    -- REGISTER EVENTS
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GUILD_MEMBER_NOTE_CHANGED, self.GuildMemberNoteChanged)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, self.OnPlayerActivated)
    -- moved to the Start/StopTimer functions to limit the amount of unnecessary event handling
    -- EVENT_MANAGER:RegisterForEvent(self.name, EVENT_COMBAT_EVENT, self.OnCombatEvent)
    -- EVENT_MANAGER:AddFilterForEvent(self.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DIED)
    -- EVENT_MANAGER:AddFilterForEvent(self.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DIED_XP)
    -- EVENT_MANAGER:RegisterForEvent(self.name, EVENT_EXPERIENCE_GAIN, self.OnExperienceGain)
    -- EVENT_MANAGER:RegisterForEvent(self.name, EVENT_QUEST_ADVANCED, self.OnQuestAdvanced)
    -- EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, self.OnCombatStateChange)

    -- INIT MAINWINDOWS CONTROLS
    PR:InitWindow()
end

function PR.OnUnitDeatStateChanged(event, unitTag, isDead)
    if PR.starts_with(unitTag, "boss") and isDead==true then 
        bossName = GetUnitName(unitTag)
        PR.AddBossKill(bossName)
        if PR.debug==true then d("DEAD:"..bossName) end
        if GetDisplayName() == "@flipswitchingmonkey" then
            table.insert(PR.savedVariables.history, {name=bossName, counter=#PR.killed_boss_list, zone=PR.currentZoneData["zone"], dungeon=PR.currentZoneData["en"]["zone"] })
        end 
    end
end

-- function PR.OnExperienceGain(event, reason, level, previousExperience, currentExperience, championPoints)
    -- if PR.debug==true then d("XP " .. reason .. " " .. currentExperience) end
    -- if reason==PROGRESS_REASON_ACHIEVEMENT then if PR.debug==true then d("XP Reason: * PROGRESS_REASON_ACHIEVEMENT") end end
    -- if reason==PROGRESS_REASON_ACTION then if PR.debug==true then d("XP Reason: * PROGRESS_REASON_ACTION") end end
    -- if reason==PROGRESS_REASON_ALLIANCE_POINTS then if PR.debug==true then d("XP Reason: * PROGRESS_REASON_ALLIANCE_POINTS") end end
    -- if reason==PROGRESS_REASON_AVA then if PR.debug==true then d("XP Reason: * PROGRESS_REASON_AVA") end end
    -- if reason==PROGRESS_REASON_BATTLEGROUND then if PR.debug==true then d("XP Reason: * PROGRESS_REASON_BATTLEGROUND") end end
    -- if reason==PROGRESS_REASON_BOOK_COLLECTION_COMPLETE then if PR.debug==true then d("XP Reason: * PROGRESS_REASON_BOOK_COLLECTION_COMPLETE") end end
    -- if reason==PROGRESS_REASON_BOSS_KILL then
        -- if PR.debug==true then d("XP Reason: * PROGRESS_REASON_BOSS_KILL") end
        -- local numBossesKilled = PR.CheckBossesAlive()
        -- if numBossesKilled > 0 then PR.AddBossKill() end
    -- end
    -- if reason==PROGRESS_REASON_COLLECT_BOOK then if PR.debug==true then d("XP Reason: * PROGRESS_REASON_COLLECT_BOOK") end end
    -- if reason==PROGRESS_REASON_COMMAND then if PR.debug==true then d("XP Reason: * PROGRESS_REASON_COMMAND") end end
    -- if reason==PROGRESS_REASON_COMPLETE_POI then if PR.debug==true then d("XP Reason: * PROGRESS_REASON_COMPLETE_POI") end end
    -- if reason==PROGRESS_REASON_DARK_ANCHOR_CLOSED then if PR.debug==true then d("XP Reason: * PROGRESS_REASON_DARK_ANCHOR_CLOSED") end end
    -- if reason==PROGRESS_REASON_DARK_FISSURE_CLOSED then if PR.debug==true then d("XP Reason: * PROGRESS_REASON_DARK_FISSURE_CLOSED") end end
    -- if reason==PROGRESS_REASON_DISCOVER_POI then if PR.debug==true then d("XP Reason: * PROGRESS_REASON_DISCOVER_POI") end end
    -- if reason==PROGRESS_REASON_DUNGEON_CHALLENGE then if PR.debug==true then d("XP Reason: * PROGRESS_REASON_DUNGEON_CHALLENGE") end end
    -- if reason==PROGRESS_REASON_EVENT then if PR.debug==true then d("XP Reason: * PROGRESS_REASON_EVENT") end end
    -- if reason==PROGRESS_REASON_FINESSE then if PR.debug==true then d("XP Reason: * PROGRESS_REASON_FINESSE") end end
    -- if reason==PROGRESS_REASON_GRANT_REPUTATION then if PR.debug==true then d("XP Reason: * PROGRESS_REASON_GRANT_REPUTATION") end end
    -- if reason==PROGRESS_REASON_GUILD_REP then if PR.debug==true then d("XP Reason: * PROGRESS_REASON_GUILD_REP") end end
    -- if reason==PROGRESS_REASON_JUSTICE_SKILL_EVENT then if PR.debug==true then d("XP Reason: * PROGRESS_REASON_JUSTICE_SKILL_EVENT") end end
    -- if reason==PROGRESS_REASON_KEEP_REWARD then if PR.debug==true then d("XP Reason: * PROGRESS_REASON_KEEP_REWARD") end end
    -- if reason==PROGRESS_REASON_KILL then if PR.debug==true then d("XP Reason: * PROGRESS_REASON_KILL") end end
    -- if reason==PROGRESS_REASON_LFG_REWARD then if PR.debug==true then d("XP Reason: * PROGRESS_REASON_LFG_REWARD") end end
    -- if reason==PROGRESS_REASON_LOCK_PICK then if PR.debug==true then d("XP Reason: * PROGRESS_REASON_LOCK_PICK") end end
    -- if reason==PROGRESS_REASON_MEDAL then if PR.debug==true then d("XP Reason: * PROGRESS_REASON_MEDAL") end end
    -- if reason==PROGRESS_REASON_NONE then if PR.debug==true then d("XP Reason: * PROGRESS_REASON_NONE") end end
    -- if reason==PROGRESS_REASON_OTHER then if PR.debug==true then d("XP Reason: * PROGRESS_REASON_OTHER") end end
    -- if reason==PROGRESS_REASON_OVERLAND_BOSS_KILL then if PR.debug==true then d("XP Reason: * PROGRESS_REASON_OVERLAND_BOSS_KILL") end end
    -- if reason==PROGRESS_REASON_PVP_EMPEROR then if PR.debug==true then d("XP Reason: * PROGRESS_REASON_PVP_EMPEROR") end end
    -- if reason==PROGRESS_REASON_QUEST then if PR.debug==true then d("XP Reason: * PROGRESS_REASON_QUEST") end end
    -- if reason==PROGRESS_REASON_REWARD then if PR.debug==true then d("XP Reason: * PROGRESS_REASON_REWARD") end end
    -- if reason==PROGRESS_REASON_SCRIPTED_EVENT then if PR.debug==true then d("XP Reason: * PROGRESS_REASON_SCRIPTED_EVENT") end end
    -- if reason==PROGRESS_REASON_SKILL_BOOK then if PR.debug==true then d("XP Reason: * PROGRESS_REASON_SKILL_BOOK") end end
    -- if reason==PROGRESS_REASON_TRADESKILL then if PR.debug==true then d("XP Reason: * PROGRESS_REASON_TRADESKILL") end end
    -- if reason==PROGRESS_REASON_TRADESKILL_ACHIEVEMENT then if PR.debug==true then d("XP Reason: * PROGRESS_REASON_TRADESKILL_ACHIEVEMENT") end end
    -- if reason==PROGRESS_REASON_TRADESKILL_CONSUME then if PR.debug==true then d("XP Reason: * PROGRESS_REASON_TRADESKILL_CONSUME") end end
    -- if reason==PROGRESS_REASON_TRADESKILL_HARVEST then if PR.debug==true then d("XP Reason: * PROGRESS_REASON_TRADESKILL_HARVEST") end end
    -- if reason==PROGRESS_REASON_TRADESKILL_QUEST then if PR.debug==true then d("XP Reason: * PROGRESS_REASON_TRADESKILL_QUEST") end end
    -- if reason==PROGRESS_REASON_TRADESKILL_RECIPE then if PR.debug==true then d("XP Reason: * PROGRESS_REASON_TRADESKILL_RECIPE") end end
    -- if reason==PROGRESS_REASON_TRADESKILL_TRAIT then if PR.debug==true then d("XP Reason: * PROGRESS_REASON_TRADESKILL_TRAIT") end end
--   end


function PR:InitWindow()
    PledgeRunnerDialog:SetHandler("OnMoveStop", function(control)
        -- save new position
        self.savedVariables.left = control:GetLeft()
        self.savedVariables.top = control:GetTop()
    end)
    PledgeRunnerDialog:SetHandler("OnResizeStop", function(control)
        local width, height = control:GetDimensions()
        -- save new size
        self.savedVariables.width = width
        self.savedVariables.height = height
        -- adjust scrollList column widths to new dialog widths
        self.scrollList:SetAnchor(BOTTOMRIGHT, PledgeRunnerDialog, BOTTOMRIGHT, -10, -40)
        self.columnWidthUnit = (width - 128) / 10.0
        PledgeRunnerDialogHeadersName:SetDimensions(self.columnWidthUnit * self.columnUnits[2], 25)
        PledgeRunnerDialogHeadersZone:SetDimensions(self.columnWidthUnit * self.columnUnits[3], 25)
        PledgeRunnerDialogHeadersMessage:SetDimensions(self.columnWidthUnit * self.columnUnits[4], 25)
        PledgeRunnerDialogHeadersDeleteRow:SetDimensions(20, 20)
        if self.dataItems[self.savedVariables.selectedGuildId] ~= nil then
            self.scrollList:Update(self.dataItems[self.savedVariables.selectedGuildId])
        end
    end)
    -- set button handlers
    -- PledgeRunnerDialogTestButton:SetHandler("OnClicked", self.TestButton_Clicked)
    PledgeRunnerDialogResetButton:SetHandler("OnClicked", self.ResetButton_Clicked)
    PledgeRunnerDialogResetButton:SetText(GetString(PLEDGERUNNER_BUTTON_CLEAR))
    PledgeRunnerDialogButtonCloseAddon:SetHandler("OnClicked", self.ToggleMainWindow)
    PledgeRunnerDialogTimerLabel:SetText(GetString(PLEDGERUNNER_TIMER)..":")
    PledgeRunnerDialogBossCompletionLabel:SetText(GetString(PLEDGERUNNER_BOSSES)..":")
    
    PledgeRunnerDialogBossCompletionLabel:SetMouseEnabled(true)
    PledgeRunnerDialogBossCompletionLabel:SetHandler('OnMouseEnter', function(thisControl)
        ZO_Tooltips_ShowTextTooltip(thisControl, BOTTOM, PR.KilledBossListAsString())
    end)
    PledgeRunnerDialogBossCompletionLabel:SetHandler('OnMouseExit', function(thisControl)
        ZO_Tooltips_HideTextTooltip()
    end)
  
    PledgeRunnerDialogCurrentZone:SetMouseEnabled(true)
    PledgeRunnerDialogCurrentZone:SetHandler('OnMouseEnter', function(thisControl)
        if thisControl:WasTruncated() then
            ZO_Tooltips_ShowTextTooltip(thisControl, TOP, thisControl:GetText())
        end
    end)
    PledgeRunnerDialogCurrentZone:SetHandler('OnMouseExit', function(thisControl)
        ZO_Tooltips_HideTextTooltip()
    end)

    self.OnGuildSelectedCallback = function(a, b, entry, c)
        self:OnGuildSelected(entry)
    end
    self.OnFilterQuestSelectedCallback = function(_, _, entry)
        self:OnFilterQuestSelected(entry)
    end
  
    self.questFilterComboBox = PR:GetFilterQuestComboBox()
    self.guildComboBox = PR:GetGuildComboBox()
    self.guildComboBox:SetSortsItems(false)
    
    PR:RefreshGuildList()
    PR:RefreshFilterQuestList()
    PR:OnGuildSelected(self.guildComboEntries[self.savedVariables.selectedGuildId])
    PR:OnFilterQuestSelected(self.filterQuestComboEntries[1])
    self.questFilterComboBox:SetSelectedItemText(self.filterQuestComboEntries[1].name)
    ZO_CheckButton_SetToggleFunction(PledgeRunnerDialogEnableGuildCheck, self.EnableGuildCheck_OnToggle)
    PledgeRunnerDialogShowInChat:SetText(GetString(PLEDGERUNNER_SHOW_IN_CHAT))
    ZO_CheckButton_SetToggleFunction(PledgeRunnerDialogShowInChat, self.ShowInChatCheck_OnToggle)
    ZO_CheckButton_SetCheckState(PledgeRunnerDialogShowInChat, PR.savedVariables["showInChat"] or false)
    self:RestorePosition()
end

-- Function that creates the scrollList 
function PR:CreateScrollList()
    -- setup scrollList parameters
    local categoriesTable = {1}
    for key, val in pairs(PR.ZONEDATA) do
        table.insert(categoriesTable, key)
    end
    local scrollData = {
    name            = "PledgeRunnerEvents",
    parent          = PledgeRunnerDialog,
    width           = 530,
    height          = 350,
    rowHeight       = 23,
    rowTemplate     = "PledgeRunnerEntryRow",
    setupCallback   = PR.SetupDataRow,
    sortFunction    = PR.SortScrollListByTime,
    -- selectTemplate  = "EmoteItSelectTemplate",
    -- selectCallback  = OnRowSelection,
    -- dataTypeSelectSound = SOUNDS.BOOK_CLOSE,
    -- hideCallback    = OnRowHide,
    -- resetCallback   = OnRowReset,
    categories  = categoriesTable,
    }
    
    self.scrollList = libScroll:CreateScrollList(scrollData)
    self.scrollList:SetAnchor(TOPLEFT, PledgeRunnerDialogHeaders, BOTTOMLEFT, 10, 10)
    self.scrollList:SetAnchor(BOTTOMRIGHT, PledgeRunnerDialog, BOTTOMRIGHT, -10, -40)

    -- Call Update to add the data items to the scrollList
    if PR.dataItems[1] ~= nil then
        self.scrollList:Update(PR.dataItems[1])
    end
end

function PR.SetupDataRow(rowControl, data, scrollList)
    -- Do whatever you want/need to setup the control
    rowControl.data = data
    rowControl.name = GetControl(rowControl, "Name")
    rowControl.time = GetControl(rowControl, "Time")
    rowControl.zone = GetControl(rowControl, "Zone")
    rowControl.message = GetControl(rowControl, "Message")
    rowControl.deleteRow = GetControl(rowControl, "DeleteRow")
    rowControl.deleteRow.fake_uuid = data.fake_uuid

    rowControl.name:SetText(data.name)
    rowControl.time:SetText(data.time)
    rowControl.zone:SetText(data.zone)
    rowControl.message:SetText(data.message)

    rowControl.name:SetMouseEnabled(true)
    rowControl.name:SetHandler('OnMouseEnter', function(thisControl)
        if thisControl:WasTruncated() then
            ZO_Tooltips_ShowTextTooltip(thisControl, TOP, thisControl:GetText())
        end
    end)
    rowControl.name:SetHandler('OnMouseExit', function(thisControl)
        ZO_Tooltips_HideTextTooltip()
    end)

    rowControl.zone:SetMouseEnabled(true)
    rowControl.zone:SetHandler('OnMouseEnter', function(thisControl)
        if thisControl:WasTruncated() then
            ZO_Tooltips_ShowTextTooltip(thisControl, TOP, thisControl:GetText())
        end
    end)
    rowControl.zone:SetHandler('OnMouseExit', function(thisControl)
        ZO_Tooltips_HideTextTooltip()
    end)

    rowControl.message:SetMouseEnabled(true)
    rowControl.message:SetHandler('OnMouseEnter', function(thisControl)
        if thisControl:WasTruncated() then
            ZO_Tooltips_ShowTextTooltip(thisControl, TOP, thisControl:GetText())
        end
    end)
    rowControl.message:SetHandler('OnMouseExit', function(thisControl)
        ZO_Tooltips_HideTextTooltip()
    end)

    rowControl.name.normalColor = PR.DEFAULT_TEXT
    rowControl.time.normalColor = PR.DEFAULT_TEXT
    rowControl.zone.normalColor = PR.DEFAULT_TEXT
    rowControl.message.normalColor = PR.DEFAULT_TEXT
    -- rowControl:SetText(data.name)

    rowControl.name:SetDimensions(PR.columnWidthUnit * PR.columnUnits[2], 32)
    rowControl.zone:SetDimensions(PR.columnWidthUnit * PR.columnUnits[3], 32)
    rowControl.message:SetDimensions(PR.columnWidthUnit * PR.columnUnits[4], 32)
    rowControl.deleteRow:SetDimensions(20, 20)

    rowControl:SetFont("ZoFontWinH4")
end

function PR.KilledBossListAsString()
    if PR.currentZoneData == nil then return "no data" end
    local s = GetString(PLEDGERUNNER_BOSSES_KILLED) .. "\n"
    if PR.currentZoneData[PR.locale]["bosses"] ~= nil then
        for key, boss in ipairs(PR.currentZoneData[PR.locale]["bosses"]) do
            local found = false
            for key2, boss2 in ipairs(PR.killed_boss_list) do
                if boss == boss2 then
                    s = s .. "- |c96C05F" .. boss .. "|r\n"
                    found = true
                end
            end
            if found == false then
                s = s .. "- |cD26868" .. boss .. "|r\n"
            end
        end
    else
        for key, boss in ipairs(PR.killed_boss_list) do
            if boss ~= nil and #boss > 0 then
                s = s .. "- " .. boss .. "\n"
            end
        end
    end
    local bossMaxZone = PR.currentZoneData["numBosses"] or 6
    s = s .. zo_strformat("<<1>>/<<2>>", #PR.killed_boss_list, bossMaxZone)
    return s
end

function PR:GetGuildComboBox()
    local sc = WINDOW_MANAGER:GetControlByName("PledgeRunnerDialog")
    local guildComboBoxControl = sc:GetNamedChild("Guild")
    return ZO_ComboBox_ObjectFromContainer(guildComboBoxControl)
end

function PR:GetFilterQuestComboBox()
    local sc = WINDOW_MANAGER:GetControlByName("PledgeRunnerDialog")
    local guildComboBoxControl = sc:GetNamedChild("FilterQuest")
    return ZO_ComboBox_ObjectFromContainer(guildComboBoxControl)
end

function PR:RestorePosition()
    local left = self.savedVariables.left
    local top = self.savedVariables.top
    PledgeRunnerDialog:ClearAnchors()
    PledgeRunnerDialog:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    local width = PR.savedVariables.width
    local height = PR.savedVariables.height
    PR.columnWidthUnit = (width - 128) / 10.0
    PledgeRunnerDialogHeadersName:SetDimensions(PR.columnWidthUnit * PR.columnUnits[2], 25)
    PledgeRunnerDialogHeadersZone:SetDimensions(PR.columnWidthUnit * PR.columnUnits[3], 25)
    PledgeRunnerDialogHeadersMessage:SetDimensions(PR.columnWidthUnit * PR.columnUnits[4], 25)
    PledgeRunnerDialogHeadersDeleteRow:SetDimensions(20, 20)
    if (width ~= nil and height ~= nil) and (width > 100 and height > 100) then
        PledgeRunnerDialog:SetDimensions(width, height)
    else 
        PledgeRunnerDialog:SetDimensions(500,500)
    end
end

function PR.SortScrollListByName(objA, objB) return objA.data.name < objB.data.name end
function PR.SortScrollListByNameRev(objA, objB) return objA.data.name > objB.data.name end
function PR.SortScrollListByTime(objA, objB) return objA.data.time < objB.data.time end
function PR.SortScrollListByTimeRev(objA, objB) return objA.data.time > objB.data.time end
function PR.SortScrollListByZone(objA, objB) return objA.data.zone < objB.data.zone end
function PR.SortScrollListByZoneRev(objA, objB) return objA.data.zone > objB.data.zone end
function PR.SortScrollListByMessage(objA, objB) return objA.data.message < objB.data.message end
function PR.SortScrollListByMessageRev(objA, objB) return objA.data.message > objB.data.message end

function PR:HeaderTimeClicked()
    if PR.scrollList.SortFunction == PR.SortScrollListByTime then
        PR.scrollList.SortFunction = PR.SortScrollListByTimeRev
    else
        PR.scrollList.SortFunction = PR.SortScrollListByTime
    end
    PR.scrollList:Update(PR.dataItems[PR.savedVariables.selectedGuildId])
    -- PR:ApplyFilterQuest()
end
  
function PR:HeaderNameClicked()
    if PR.scrollList.SortFunction == PR.SortScrollListByName then
        PR.scrollList.SortFunction = PR.SortScrollListByNameRev
    else
        PR.scrollList.SortFunction = PR.SortScrollListByName
    end
    PR.scrollList:Update(PR.dataItems[PR.savedVariables.selectedGuildId])
    -- PR:ApplyFilterQuest()
end
  
function PR:HeaderZoneClicked()
    if PR.scrollList.SortFunction == PR.SortScrollListByZone then
        PR.scrollList.SortFunction = PR.SortScrollListByZoneRev
    else
        PR.scrollList.SortFunction = PR.SortScrollListByZone
    end
    PR.scrollList:Update(PR.dataItems[PR.savedVariables.selectedGuildId])
    -- PR:ApplyFilterQuest()
end
  
function PR:HeaderMessageClicked()
    if PR.scrollList.SortFunction == PR.SortScrollListByMessage then
        PR.scrollList.SortFunction = PR.SortScrollListByMessageRev
    else
        PR.scrollList.SortFunction = PR.SortScrollListByMessage
    end
    PR.scrollList:Update(PR.dataItems[PR.savedVariables.selectedGuildId])
    -- PR:ApplyFilterQuest()
end

function PR:RefreshGuildList()
    self.guildComboEntries = {}
    if self.guildComboBox == nil then self.guildComboBox = PR:GetGuildComboBox() end
    self.guildComboBox:ClearItems()
    for i = 1, GetNumGuilds() do
        local guildId = GetGuildId(i)
        if(not self.filterFunction or self.filterFunction(guildId)) then
            local guildName = GetGuildName(guildId)
            local guildAlliance = GetGuildAlliance(guildId) 
            local guildText = zo_iconTextFormat(GetAllianceBannerIcon(guildAlliance), 24, 24, guildName)
            local entry = self.guildComboBox:CreateItemEntry(guildText, self.OnGuildSelectedCallback)
            entry.guildId = guildId
            entry.guildText = guildText
        self.guildComboEntries[guildId] = entry
        self.guildComboBox:AddItem(entry)
        end
    end
  
    if(next(self.guildComboEntries) == nil) then return false end

    return true
end

function PR:RefreshFilterQuestList()
    self.filterQuestComboEntries = {}
    if self.filterQuestComboBox == nil then self.filterQuestComboBox = PR:GetFilterQuestComboBox() end
    self.filterQuestComboBox:ClearItems()
    local nofilter = self.guildComboBox:CreateItemEntry("-- No filter", self.OnFilterQuestSelectedCallback)
    nofilter.categoryId = 1
    self.filterQuestComboEntries[1] = nofilter
    self.filterQuestComboBox:AddItem(nofilter)
    for zoneId, zoneData in pairs(PR.ZONEDATA) do
        local zoneText = zoneData[PR.locale]["zone"]
        local entry = self.guildComboBox:CreateItemEntry(zoneText, self.OnFilterQuestSelectedCallback)
        entry.categoryId = zoneId
        self.filterQuestComboEntries[zoneId] = entry
        self.filterQuestComboBox:AddItem(entry)
    end
  
    if(next(self.guildComboEntries) == nil) then return false end

    return true
end

function PR.RemoveListEntry(self, button)
    local deleteme = nil
    for key, val in pairs(PR.dataItems[PR.savedVariables.selectedGuildId]) do
        if val.fake_uuid == self.fake_uuid then deleteme = key end
    end
    if deleteme ~= nil then
        table.remove(PR.dataItems[PR.savedVariables.selectedGuildId], deleteme)
        PR.scrollList:Update(PR.dataItems[PR.savedVariables.selectedGuildId])
    end
end

function PR.EnableGuildCheck_OnToggle(checkButton, isChecked)
    PR.savedVariables["guildEnabled"][PR.savedVariables.selectedGuildId] = isChecked
end

function PR.ShowInChatCheck_OnToggle(checkButton, isChecked)
    PR.savedVariables["showInChat"] = isChecked
end
  
function PR.ToggleMainWindow()
    PR.savedVariables.hidden = not PR.savedVariables.hidden
    PledgeRunnerDialog:SetHidden(PR.savedVariables.hidden)
end
  
function PR.CloseUI()
    PR.savedVariables.hidden = true;
    SCENE_MANAGER:HideTopLevel(PledgeRunnerDialog)
end
  
function PR.ShowUI()
    PR.savedVariables.hidden = false;
    PledgeRunnerDialog:SetHidden(PR.savedVariables.hidden)
end
  
function PR.HideUI()
    PR.savedVariables.hidden = true;
    PledgeRunnerDialog:SetHidden(PR.savedVariables.hidden)
end
  
function PR:OnGuildSelected(entry)
    if entry == nil then return end
    ZO_CheckButton_SetCheckState(PledgeRunnerDialogEnableGuildCheck, self.savedVariables["guildEnabled"][entry.guildId])
    self.savedVariables.selectedGuildId = entry.guildId
    if self.dataItems[self.savedVariables.selectedGuildId] ~= nil then
        self.scrollList:Update(self.dataItems[self.savedVariables.selectedGuildId])
    end
    PR:ApplyFilterQuest()
    self.guildComboBox:SetSelectedItemText(entry.guildText)
    if(self.selectedCallback) then
        self.selectedCallback(entry.guildId)
    end
end

function PR:OnFilterQuestSelected(entry)
    self.filterQuestCategory = entry.categoryId
    PR:ApplyFilterQuest()
end

function PR:ApplyFilterQuest()
    if self.filterQuestCategory == 1 then
        PR.scrollList:ShowAllCategories()
    else
        PR.scrollList:ShowOnlyCategory(self.filterQuestCategory)
    end
end

function PR:SelectGuildComboBox(guildId)
    if self.guildComboBox == nil then self.guildComboBox = PR:GetGuildComboBox() end
    local entry = self.guildComboEntries[guildId]
    self.guildComboBox:SetSelectedItemText(entry.guildText)
end

-- this loop sets the time display once per second, stop by setting PR.timerStart to nil
function PR.SetTimerTimeLoop(runOnce)
    local time = PR.TimeStringFromTimeStamp(PR.GetTimeElapsed())
    PledgeRunnerDialogTimerTime:SetText(time)
    if runOnce == true then return end
    zo_callLater(function() 
        if PR.timerStart ~= nil then 
            PR.SetTimerTimeLoop() 
        end
    end, 1000)
end

function PR.StartTimer()
    PR.timerStart = GetTimeStamp()
    PR.SetTimerTimeLoop()
end

function PR.StopTimer()
    PR.timerStart = nil
    -- PledgeRunnerDialogTimerTime:SetText("|c77777700:00:00|r")
end

function PR.GetTimeElapsed()
    if PR.timerStart == nil then return 0 end
    return GetTimeStamp() - PR.timerStart
end

-- ESO_event functions
function PR.OnCombatStateChange(event, inCombat)
    if inCombat == true then
        -- if we are in a pledge zone and the timer has not yet started...
        if PR.currentZoneData ~= nil and PR.timerStart == nil then
            PR.StartTimer()
            PR.CenterAnnounce("The fight begins in <<1>>", PR.currentZoneData[PR.locale]["zone"])
            if GetCurrentZoneDungeonDifficulty() == DUNGEON_DIFFICULTY_VETERAN then
                PR.InjectAddonDataIntoGuildNote(PR.EncodeDataStringWithId(PR.currentZoneData["zone"], PR.ACTION.PLEDGE_ZONE_STARTED_VET, PR.GetTimeElapsed()))
            else
                PR.InjectAddonDataIntoGuildNote(PR.EncodeDataStringWithId(PR.currentZoneData["zone"], PR.ACTION.PLEDGE_ZONE_STARTED, PR.GetTimeElapsed()))
            end

        end
    end
end

-- GetCurrentZoneDungeonDifficulty()

-- EVENT_ZONE_CHANGED is not triggered at initial entry, but EVENT_PLAYER_ACTIVATED is
function PR.OnPlayerActivated(event)
    local zoneName = GetUnitZone('player')
    local zoneId, worldX, worldY, worldZ = GetUnitWorldPosition('player')
    local bossMaxZone

    -- check if the new zone is actually the same as the previous zone, in which case do nothing
    -- this happens in some dungeons that are split into multiple sub zones (Darkshade for example)
    if PR.currentZoneData ~= nil and zoneId == PR.currentZoneData.zone then
        return
    end
    -- CHECK OLD ZONE DATA
    -- before checking for the _new_ zone data, see if we left a zone that had zone data, so we can log that
    -- if PR.currentZoneData ~= nil then
    --     if GetCurrentZoneDungeonDifficulty() == DUNGEON_DIFFICULTY_VETERAN then
    --         PR.InjectAddonDataIntoGuildNote(PR.EncodeDataStringWithId(PR.currentZoneData["zone"], PR.ACTION.PLEDGE_ZONE_LEFT, PR.GetTimeElapsed()))
    --     else
    --         PR.InjectAddonDataIntoGuildNote(PR.EncodeDataStringWithId(PR.currentZoneData["zone"], PR.ACTION.PLEDGE_ZONE_LEFT_VET, PR.GetTimeElapsed()))
    --     end
    -- end
    
    -- RENEW ZONE DATA
    -- now renew the currentZoneData with the current zone - if it's not in our PledgeData, it's going to be nil
    PR.currentZoneData = PR.ZONEDATA[zoneId]
    PR.StopTimer()
    if PR.currentZoneData ~= nil then
        EVENT_MANAGER:RegisterForEvent(PR.name, EVENT_QUEST_ADVANCED, PR.OnQuestAdvanced)
        EVENT_MANAGER:RegisterForEvent(PR.name, EVENT_PLAYER_COMBAT_STATE, PR.OnCombatStateChange)
        EVENT_MANAGER:RegisterForEvent(PR.name, EVENT_UNIT_DEATH_STATE_CHANGED, PR.OnUnitDeatStateChanged)
        PR.CenterAnnounce(zo_strformat("<<1>> entered", zoneName))
        -- PR.currentZoneBossKills = 0
        PR.killed_boss_list = {}
        bossMaxZone = PR.currentZoneData["numBosses"] or 6
        if GetCurrentZoneDungeonDifficulty() == DUNGEON_DIFFICULTY_VETERAN then
            PR.InjectAddonDataIntoGuildNote(PR.EncodeDataStringWithId(zoneId, PR.ACTION.PLEDGE_ZONE_ENTERED_VET, 0))
        else
            PR.InjectAddonDataIntoGuildNote(PR.EncodeDataStringWithId(zoneId, PR.ACTION.PLEDGE_ZONE_ENTERED, 0))
        end
        PledgeRunnerDialogCurrentZone:SetText(zoneName)
        PledgeRunnerDialogBossCompletion:SetText(zo_strformat("<<1>>/<<2>>", 0, bossMaxZone))
    else
        EVENT_MANAGER:UnregisterForEvent(PR.name, EVENT_QUEST_ADVANCED)
        EVENT_MANAGER:UnregisterForEvent(PR.name, EVENT_PLAYER_COMBAT_STATE)
        EVENT_MANAGER:UnregisterForEvent(PR.name, EVENT_UNIT_DEATH_STATE_CHANGED, PR.OnUnitDeatStateChanged)
        bossMaxZone = GetNumZoneActivitiesForZoneCompletionType(zoneId, ZONE_COMPLETION_TYPE_GROUP_BOSSES)
        local bossDoneZone = GetNumCompletedZoneActivitiesForZoneCompletionType(zoneId, ZONE_COMPLETION_TYPE_GROUP_BOSSES)
        PledgeRunnerDialogCurrentZone:SetText("|c777777" .. zoneName .. "|r")
        PledgeRunnerDialogBossCompletion:SetText(zo_strformat("|c777777<<1>>/<<2>>|r", bossDoneZone, bossMaxZone))
    end
end

function PR.AddBossKill(bossName)
    if PR.currentZoneData ~= nil and bossName ~= nil then
        -- PR.currentZoneBossKills = PR.currentZoneBossKills + 1
        local bossMaxZone = PR.currentZoneData["numBosses"] or 6
        table.insert(PR.killed_boss_list, bossName)
        PledgeRunnerDialogBossCompletion:SetText(zo_strformat("<<1>>/<<2>>", #PR.killed_boss_list, bossMaxZone))
        if GetCurrentZoneDungeonDifficulty() == DUNGEON_DIFFICULTY_VETERAN then
            PR.InjectAddonDataIntoGuildNote(PR.EncodeDataStringWithId(PR.currentZoneData["zone"], PR.ACTION.BOSS_KILLED_VET, #PR.killed_boss_list))
        else
            PR.InjectAddonDataIntoGuildNote(PR.EncodeDataStringWithId(PR.currentZoneData["zone"], PR.ACTION.BOSS_KILLED, #PR.killed_boss_list))
        end
        if #PR.killed_boss_list == bossMaxZone then
            if GetCurrentZoneDungeonDifficulty() == DUNGEON_DIFFICULTY_VETERAN then
                PR.InjectAddonDataIntoGuildNote(PR.EncodeDataStringWithId(PR.currentZoneData["zone"], PR.ACTION.PLEDGE_FINAL_REACHED_VET, PR.GetTimeElapsed()))
            else
                PR.InjectAddonDataIntoGuildNote(PR.EncodeDataStringWithId(PR.currentZoneData["zone"], PR.ACTION.PLEDGE_FINAL_REACHED, PR.GetTimeElapsed()))
            end
            PR.StopTimer()
        end
    end
end

function PR.OnZoneChanged(event, _, subZoneName, _, _, subZoneId)
    -- using Event Parameters would be way too easy! (since they don't work...)
    local zoneName = GetUnitZone('player')
    local zoneId, worldX, worldY, worldZ = GetUnitWorldPosition('player')
    -- if PR.debug==true then d(zo_strformat("<<1>> entered, zoneId: <<2>>, subZoneName: <<3>>, subZoneId: <<4>>", zoneName, zoneId, subZoneName, subZoneId))
end

function PR.OnQuestAdvanced(event, journalIndex, questName, isPushed, isComplete, mainStepChanged)
    local questNameJournal, backgroundText, activeStepText, activeStepType, activeStepTrackerOverrideText, completed, tracked, questLevel, pushed, questType, instanceDisplayType = GetJournalQuestInfo(journalIndex)
    local conditionText, _, _, isFailCondition, isComplete, _, _, conditionType = GetJournalQuestConditionInfo(journalIndex)
    -- if PR.debug==true then d(zo_strformat("<<1>>,<<2>>,isPushed <<3>>,isComplete <<4>>,mainStepChanged <<5>>", journalIndex, questName, isPushed, isComplete, mainStepChanged))
    -- if PR.debug==true then d(questNameJournal, backgroundText, activeStepText, activeStepType, activeStepTrackerOverrideText, completed, tracked, questLevel, pushed, questType, instanceDisplayType)
    -- if PR.debug==true then d(zo_strformat("<<1>>,<<2>>", questName, activeStepTrackerOverrideText))
    -- if PR.debug==true then d(conditionText)
    if PR.currentZoneData ~= nil then
        if PR.debug==true then d(PR.currentZoneData[PR.locale]["pledge"]) end
        if questName == PR.currentZoneData[PR.locale]["pledge"] and conditionText == PR.currentZoneData[PR.locale]["final"] then
            if PR.debug==true then d("FINAL STEP REACHED") end
                if GetCurrentZoneDungeonDifficulty() == DUNGEON_DIFFICULTY_VETERAN then
                    PR.InjectAddonDataIntoGuildNote(PR.EncodeDataStringWithId(PR.currentZoneData["zone"], PR.ACTION.PLEDGE_FINAL_REACHED_VET, PR.GetTimeElapsed()))
                else
                    PR.InjectAddonDataIntoGuildNote(PR.EncodeDataStringWithId(PR.currentZoneData["zone"], PR.ACTION.PLEDGE_FINAL_REACHED, PR.GetTimeElapsed()))
                end
            PR.StopTimer()
        end
    end
  end

  function PR.OnCombatEvent(event, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    local rawSourceName = ZO_CachedStrFormat(SI_UNIT_NAME, sourceName)
    local rawTargetName = ZO_CachedStrFormat(SI_UNIT_NAME, targetName)
    
    if PR.debug==true then d(zo_strformat("Source: <<1>> ID: <<2>> Type: <<3>> // Target: <<4>> ID: <<5>> Type: <<6>>", rawSourceName, sourceUnitId, sourceType, rawTargetName, targUnitId, targetType)) end
    if PR.debug==true then d(zo_strformat("numBossesKilled: <<1>>", numBossesKilled)) end
  end

function PR.CenterAnnounce(text, category, sound, duration)
  if text == nil then return end
  if category == nil then category = CSA_CATEGORY_SMALL_TEXT end
  if sound == nil then sound = SOUNDS.QUEST_OBJECTIVE_INCREMENT end
  local message = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(category, sound)
  if duration ~= nil then message:SetLifespanMS(duration) end
  -- message:SetSound(SOUNDS.QUEST_OBJECTIVE_INCREMENT)
  message:SetText(zo_strformat("<<1>>: <<2>>", PR.name, text))
  message:MarkSuppressIconFrame()
  message:MarkShowImmediately()
  CENTER_SCREEN_ANNOUNCE:QueueMessage(message)
end

function PR.GuildMemberNoteChanged(event, guildId, displayName, note)
    if PR.savedVariables["guildEnabled"][guildId] == false then return end
    local guildMemberId = GetGuildMemberIndexFromDisplayName(guildId, displayName)
    local addonData, noteWithoutData = PR.ExtractAddonDataFromGuildNote(note)
    if addonData ~= nil then
      for k, val in pairs(addonData) do
        PR.AddRow(val, displayName)
      end
    end
  end
  
  function PR.AddRow(dataString, playerName)
    local data = PR.DecodeDataString(dataString, playerName)
    if data == nil then return end
    -- for now, skip zone left msg entirely
    if data.action == PR.ACTION.PLEDGE_ZONE_LEFT then return end
    local doInsert = true
    for k, v in pairs(PR.dataItems[PR.savedVariables.selectedGuildId]) do
        if v.name == data.name and v.zone == data.zone and v.message == data.message then 
            v.time = data.time
            doInsert = false
        elseif v.name == data.name and v.zone == data.zone then
            -- if  or  then
                -- doInsert = true 
            if v.action == PR.ACTION.PLEDGE_FINAL_REACHED or v.action == PR.ACTION.PLEDGE_ZONE_ENTERED or v.action == PR.ACTION.PLEDGE_ZONE_STARTED or v.action == PR.ACTION.BOSS_KILLED then
                v.time = data.time
                v.message = data.message
                v.action = data.action
                doInsert = false
            elseif v.action == PR.ACTION.PLEDGERUNNER_PLEDGE_FINAL_REACHED_VET or v.action == PR.ACTION.PLEDGE_ZONE_ENTERED_VET or v.action == PR.ACTION.PLEDGE_ZONE_STARTED_VET or v.action == PR.ACTION.BOSS_KILLED_VET then
                v.time = data.time
                v.message = data.message
                v.action = data.action
                doInsert = false
            end
        end
    end
    if doInsert == true then table.insert(PR.dataItems[PR.savedVariables.selectedGuildId], data) end
    PR.scrollList:Update(PR.dataItems[PR.savedVariables.selectedGuildId])
    PR:ApplyFilterQuest()
    if PR.savedVariables["guildEnabled"][PR.savedVariables.selectedGuildId] == true then
      local s = zo_strformat("PledgeRunner: <<1>> - <<2>> - <<3>> - <<4>>", data.time, data.name, data.zone, data.message)
      if PR.savedVariables["showInChat"] == true then
        CHAT_SYSTEM:AddMessage(s)
      end
    end
end
  
function PR.EncodeDataStringWithName(zoneName, action, parameter)
    local zoneData = PR.GetZoneDataByName(zoneName)
    if zoneData == nil then
      if PR.debug==true then d("No Zone Data found") end
      return nil
    end
    return zo_strformat("<<1>>##<<2>>##<<3>>", zoneData["zone"], action, parameter)
end
  
function PR.EncodeDataStringWithId(zoneId, action, parameter)
    return zo_strformat("<<1>>##<<2>>##<<3>>", zoneId, action, parameter)
end

-- This function decodes the data string on the RECEIVING side (namely from the guild note changed event)
-- thus it can only rely on the zonedata, action and optional parameter and the local ZONEDATA
function PR.DecodeDataString(dataString, playerName)
    if dataString == nil then return end
    local data = PR.strSplit("##", dataString)
    if data == nil or #data < 3 then return end
    -- if PR.debug==true then d("AddRow", dataString) end
    local zoneId = tonumber(data[1])
    local action = tonumber(data[2])
    local parameter = tonumber(data[3])
    if zoneId == nil or PR.ZONEDATA[zoneId] == nil then return end
    if action == nil then return end
    local zoneName = PR.ZONEDATA[zoneId][PR.locale]["zone"]
    if zoneName == nil then zoneName = data[1] end
    local msg = ""
    if action==PR.ACTION.PLEDGE_ZONE_ENTERED then 
        msg = GetString(PLEDGERUNNER_PLEDGE_ZONE_ENTERED)
    elseif action==PR.ACTION.PLEDGE_ZONE_ENTERED_VET then
        zoneName = zoneName .. " (Veteran)"
        msg = GetString(PLEDGERUNNER_PLEDGE_ZONE_ENTERED_VET)
    elseif action==PR.ACTION.PLEDGE_ZONE_STARTED then 
        msg = zo_strformat("|c96C05F<<1>>|r", GetString(PLEDGERUNNER_PLEDGE_ZONE_STARTED))
    elseif action==PR.ACTION.PLEDGE_ZONE_STARTED_VET then
        zoneName = zoneName .. " (Veteran)"
        msg = zo_strformat("|c96C05F<<1>>|r", GetString(PLEDGERUNNER_PLEDGE_ZONE_STARTED_VET))
    elseif action==PR.ACTION.PLEDGE_FINAL_REACHED then 
        msg = zo_strformat("|cD2B568<<1>> <<2>>|r", GetString(PLEDGERUNNER_PLEDGE_FINAL_REACHED), PR.TimeStringFromTimeStamp(parameter))
    elseif action==PR.ACTION.PLEDGE_FINAL_REACHED_VET then
        zoneName = zoneName .. " (Veteran)"
        msg = zo_strformat("|cD2B568<<1>> <<2>>|r", GetString(PLEDGERUNNER_PLEDGE_FINAL_REACHED_VET), PR.TimeStringFromTimeStamp(parameter))
    elseif action==PR.ACTION.PLEDGE_ZONE_LEFT then
        msg = zo_strformat("|cD26868<<1>>|r", GetString(PLEDGERUNNER_PLEDGE_ZONE_LEFT), PR.TimeStringFromTimeStamp(parameter))
    elseif action==PR.ACTION.BOSS_KILLED then
        local bossMaxZone = PR.ZONEDATA[zoneId]["numBosses"] or 6
        msg = zo_strformat("|cD26868<<1>> <<2>>|r", zo_strformat("<<1>> (<<2>>/<<3>>)", GetString(PLEDGERUNNER_BOSS_KILL), parameter, bossMaxZone))
    elseif action==PR.ACTION.BOSS_KILLED_VET then
        zoneName = zoneName .. " (Veteran)"
        local bossMaxZone = PR.ZONEDATA[zoneId]["numBosses"] or 6
        msg = zo_strformat("|cD26868<<1>> <<2>>|r", zo_strformat("<<1>> (<<2>>/<<3>>)", GetString(PLEDGERUNNER_BOSS_KILL), parameter, bossMaxZone))
    end
    local fake_uuid = zo_strformat("<<1>><<2>><<3>><<4>>", zoneId,playerName,action,msg)
    return {time=PR.GetDateAndTimeString(), zone=zoneName, message=msg, name=playerName, action=action, categoryId=zoneId, fake_uuid=fake_uuid}
end
  
-- Do not call this too often, as it is a rate-limited function - calling it too often per minute will kick the player
function PR.SetOwnMemberNote(guildId, note)
    local displayName = GetDisplayName()
    local guildMemberId = GetGuildMemberIndexFromDisplayName(guildId, displayName)
    if PR.writeGuildNoteDelay == 0 then
        SetGuildMemberNote(guildId, guildMemberId, note)
        PR.writeGuildNoteDelay = PR.writeGuildNoteDelay + PR.writeGuildNoteDelayAdd
        zo_callLater(function() 
                PR.writeGuildNoteDelay = PR.writeGuildNoteDelay - PR.writeGuildNoteDelayAdd
            end, PR.writeGuildNoteDelay)
    else
        PR.writeGuildNoteDelay = PR.writeGuildNoteDelay + PR.writeGuildNoteDelayAdd
        zo_callLater(function() 
                SetGuildMemberNote(guildId, guildMemberId, note)
                PR.writeGuildNoteDelay = PR.writeGuildNoteDelay - PR.writeGuildNoteDelayAdd
            end, PR.writeGuildNoteDelay)
    end
end
  
function PR.GetOwnMemberNote(guildId)
    local displayName = GetDisplayName()
    local guildMemberId = GetGuildMemberIndexFromDisplayName(guildId, displayName)
    local name, note, rankIndex, playerStatus, secsSinceLogoff = GetGuildMemberInfo(guildId, guildMemberId)
    return note
end
  
  function PR.ExtractAddonDataFromGuildNote(param)
    local note
    if type(param) == "number" then note = PR.GetOwnMemberNote(param)
    elseif type(param) == "string" then note = param
    else return nil, param
    end

    -- looking for first and last occurrence of the addon pattern
    local osFirst, _ = note:find(PR.dataBoundaryPattern)
    local osLast, _ = note:reverse():find(PR.dataBoundaryPattern:reverse())
    if (osFirst ~= nil) and (osLast ~= nil) then
      osLast = #note - osLast + 2
      -- cut out the entire addon string, then remove the patterns to get the "pure" data
      local addonData = note:sub(osFirst, osLast):gsub(PR.dataBoundaryPattern, "")
      -- if we have data, return the data string and the original note without the datastring
      if addonData ~= nil then
        local noteWithoutData = note:sub(1, osFirst-1) .. note:sub(osLast, #note)
        local datastrings = PR.strSplit(",",addonData)
        return datastrings, noteWithoutData
      end
    end
    return nil, note
  end
  
function PR.InjectAddonDataIntoGuildNote(dataString)
    for i=1,GetNumGuilds()+1,1 do
        if DoesPlayerHaveGuildPermission(i, GUILD_PERMISSION_NOTE_EDIT) == true then
            if PR.savedVariables["guildEnabled"][i] == true then
                local addonData, noteWithoutData = PR.ExtractAddonDataFromGuildNote(i)
                local newNote = noteWithoutData .. PR.dataBoundaryPattern .. dataString .. PR.dataBoundaryPattern
                PR.SetOwnMemberNote(i, newNote)
            end
        end
    end
end

-- function PR.TestButton_Clicked()
--     PR.StartTimer()
--     PR.InjectAddonDataIntoGuildNote(PR.EncodeDataStringWithId(1052, PR.ACTION.PLEDGE_FINAL_REACHED, GetTimeStamp()))
--     PR.InjectAddonDataIntoGuildNote(PR.EncodeDataStringWithId(1055, PR.ACTION.PLEDGE_ZONE_ENTERED, GetTimeStamp()))
--     PR.InjectAddonDataIntoGuildNote(PR.EncodeDataStringWithId(380, PR.ACTION.PLEDGE_ZONE_ENTERED, GetTimeStamp()))
-- end

function PR.ResetButton_Clicked()
    PR.ClearDataItems(PR.savedVariables.selectedGuildId)
    PR.scrollList:Update(PR.dataItems[PR.savedVariables.selectedGuildId])
end

-- A bunch of generic utility functions

function PR.strSplit(delim,str)
    local t = {}
    for substr in string.gmatch(str, "[^".. delim.. "]*") do
        if substr ~= nil and string.len(substr) > 0 then
            table.insert(t,substr)
        end
    end
    return t
end

function PR.starts_with(str, start)
    return str:sub(1, #start) == start
end

function PR.ends_with(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end

function PR.GetDateAndTimeString()
    return zo_strformat("<<1>> <<2>>", GetDateStringFromTimestamp(GetTimeStamp()), GetTimeString())
end

function PR.GetTimeFromTimeStamp(ts)
    if ts == nil then return 0,0,0 end
    local h = math.floor(ts / 3600 % 24)
    local m = math.floor(ts / 60 % 60) 
    local s = math.floor(ts % 60)
    return h, m, s
end

function PR.TimeStringFromTimeStamp(ts)
    local hours, minutes, seconds = PR.GetTimeFromTimeStamp(ts)
    return zo_strformat("<<1>>:<<2>>:<<3>>", string.format("%02d",hours), string.format("%02d",minutes), string.format("%02d",seconds))
end

function PR.GetDateAndTimeStringFromTimeStamp(ts)
    local hours, minutes, seconds = PR.GetTimeFromTimeStamp(ts)
    local dateString = GetDateStringFromTimestamp(ts)
    return zo_strformat("<<1>> <<2>>:<<3>>:<<4>>", dateString, string.format("%02d",hours), string.format("%02d",minutes), string.format("%02d",seconds))
end