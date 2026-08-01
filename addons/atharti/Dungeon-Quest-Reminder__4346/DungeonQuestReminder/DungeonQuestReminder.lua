DungeonQuestReminder = {}
DungeonQuestReminder.name = "DungeonQuestReminder"

-- =========================
-- DUNGEON DATA
-- =========================
local DUNGEON_ZONE_QUEST = {
    [11]    = 4822,  -- VoM
    [22]    = 4432,  -- VF
    [31]    = 4733,  -- SW
    [38]    = 4589,  -- BH
    [63]   = 4145,  -- DC I
    [64]   = 4469,  -- BC
    [126]   = 4336,  -- EH I
    [130]   = 4379,  -- CoH I
    [131]   = 4538,  -- TI
    [144]   = 4054,  -- SC I
    [146]   = 4246,  -- WS I
    [148]   = 4202,  -- AC
    [176]   = 4778,  -- CoA I
    [283]  = 3993,  -- FG I
    [380]  = 4107,  -- BC I
    [449]  = 4346,  -- DK
    [678]  = 5136,  -- ICP
    [681]  = 5120,  -- CoA II
    [688]  = 5342,  -- WGT
    [843]  = 5403,  -- RoM
    [848]  = 5702,  -- COS
    [930]  = 4641,  -- DC II
    [931]  = 4675,  -- EH II
    [932]  = 5113,  -- CoH II
    [933]  = 4813,  -- WS II
    [934]  = 4303,  -- FG II
    [935]  = 4597,  -- BC II
    [936]  = 4555,  -- SC II
    [973]  = 5889,  -- BF
    [974]  = 5891,  -- FH
    [1009]  = 6064,  -- FL
    [1010]  = 6065,  -- SCP
    [1052]  = 6186,  -- MHK
    [1055]  = 6188,  -- MoS
    [1080]  = 6249,  -- FV
    [1081]  = 6251,  -- DoM
    [1122]  = 6349,  -- MGF
    [1123]  = 6351,  -- LoM
    [1152]  = 6414,  -- IR
    [1153]  = 6416,  -- UG
    [1197]  = 6505,  -- SG
    [1201]  = 6507,  -- CT
    [1228]  = 6576,  -- BDV
    [1229]  = 6578,  -- CD
    [1267]  = 6683,  -- RPB
    [1268]  = 6685,  -- DC
    [1301]  = 6740,  -- CA
    [1302]  = 6742,  -- SR
    [1360]  = 6835,  -- ERE
    [1361]  = 6837,  -- GD
    [1389]  = 6896,  -- BS
    [1390]  = 7027,  -- SH
    [1470] = 7105,  -- OP
    [1471] = 7155,  -- BV
    [1496] = 7235,  -- ExR
    [1497] = 7237,  -- LS
    [1551] = 7320,  -- NC
    [1552] = 7323,  -- BGF
}

-- =========================
-- TRIAL DATA
-- =========================
local TRIALS_ZONE_QUEST = {
    [636]  = 5087, -- HRC
    [638]  = 5102, -- AA
    [639]  = 5171, -- SO
    [725]  = 5352, -- MoL
    [975]  = 5894, -- HoF
    [1000]  = 6090, -- AS
    [1051]  = 6192, -- CR
    [1121]  = 6353, -- SS
    [1196]  = 6503, -- KA
    [1263]  = 6654, -- RG
    [1344]  = 6783, -- DSR
    [1427]  = 7031, -- SE
    [1478] = 7212, -- LC
    [1548] = 7306, -- OC
}


-- =========================
-- HELPERS
-- =========================
local function PlayerHasQuest(questId)
    for journalIndex = 1, GetNumJournalQuests() do
        if GetJournalQuestId(journalIndex) == questId then
            return true
        end
    end
    return false
end

local function GetRelevantZoneQuest(zoneId)
    return DUNGEON_ZONE_QUEST[zoneId] or TRIALS_ZONE_QUEST[zoneId]
end


-- =========================
-- ALERT CONTROL
-- =========================
local DungeonQuestReminderAlert = nil

local function ShowPersistentRainbowAlert(text, forceShow)
    if DungeonQuestReminderAlert then
        DungeonQuestReminderAlert.label:SetText(text)
        DungeonQuestReminderAlert:SetHidden(false)
        
        local t = 0
        DungeonQuestReminderAlert:SetHandler("OnUpdate", function(_, frameTimeSeconds)
            t = t + frameTimeSeconds * 5
            local r = math.abs(math.sin(t))
            local g = math.abs(math.sin(t + 2))
            local b = math.abs(math.sin(t + 4))
            DungeonQuestReminderAlert.label:SetColor(r, g, b, 1)
            local xOffset = math.sin(t*4) * 4
            local yOffset = math.cos(t*4.5) * 4
            DungeonQuestReminderAlert.label:SetAnchor(CENTER, DungeonQuestReminderAlert, CENTER, xOffset, yOffset)

            if not forceShow then
                local zoneId = GetZoneId(GetUnitZoneIndex("player"))
                local questId = GetRelevantZoneQuest(zoneId)
                if not questId or not PlayerHasQuest(questId) then
                    DungeonQuestReminderAlert:SetHidden(true)
                end
            end
        end)

        return
    end

    DungeonQuestReminderAlert = WINDOW_MANAGER:CreateTopLevelWindow("DungeonQuestReminderAlert")
    DungeonQuestReminderAlert:SetDimensions(1000, 200)
    DungeonQuestReminderAlert:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    DungeonQuestReminderAlert:SetHidden(false)

    local label = DungeonQuestReminderAlert:CreateControl(nil, CT_LABEL)
    label:SetFont("ZoFontGameLargeBold|72")
    label:SetAnchor(CENTER, DungeonQuestReminderAlert, CENTER, 0, 0)
    label:SetText(text)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    DungeonQuestReminderAlert.label = label

    local t = 0
    DungeonQuestReminderAlert:SetHandler("OnUpdate", function(_, frameTimeSeconds)
        t = t + frameTimeSeconds * 5
        local r = math.abs(math.sin(t))
        local g = math.abs(math.sin(t + 2))
        local b = math.abs(math.sin(t + 4))
        label:SetColor(r, g, b, 1)
        local xOffset = math.sin(t*4) * 4
        local yOffset = math.cos(t*4.5) * 4
        label:SetAnchor(CENTER, DungeonQuestReminderAlert, CENTER, xOffset, yOffset)

        if not forceShow then
            local zoneId = GetZoneId(GetUnitZoneIndex("player"))
            local questId = GetRelevantZoneQuest(zoneId)
            if not questId or not PlayerHasQuest(questId) then
                DungeonQuestReminderAlert:SetHidden(true)
            end
        end
    end)
end



-- =========================
-- EVENT HANDLER
-- =========================
local function OnContentComplete(eventCode)
    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    local questId = GetRelevantZoneQuest(zoneId)

    if questId and PlayerHasQuest(questId) then
        ShowPersistentRainbowAlert("! quest !")
    end
end


-- =========================
-- TEST SLASH COMMAND
-- =========================
local testAlertActive = false
local function ToggleTestDungeonAlert()
    if not testAlertActive then
        testAlertActive = true
        ShowPersistentRainbowAlert("! quest !", true)
    else
        testAlertActive = false
        if DungeonQuestReminderAlert then
            DungeonQuestReminderAlert:SetHidden(true)
        end
    end
end

SLASH_COMMANDS["/dungeonquestdbg"] = ToggleTestDungeonAlert



-- =========================
-- ADDON LOAD
-- =========================
local function OnAddonLoaded(event, addonName)
    if addonName ~= DungeonQuestReminder.name then return end

    EVENT_MANAGER:RegisterForEvent(
        DungeonQuestReminder.name,
        EVENT_ACTIVITY_FINDER_ACTIVITY_COMPLETE,
        OnContentComplete
    )
	
	EVENT_MANAGER:RegisterForEvent(
        DungeonQuestReminder.name,
        EVENT_RAID_TRIAL_COMPLETE,
        OnContentComplete
    )

    EVENT_MANAGER:UnregisterForEvent(
        DungeonQuestReminder.name,
        EVENT_ADD_ON_LOADED
    )
end

EVENT_MANAGER:RegisterForEvent(
    DungeonQuestReminder.name,
    EVENT_ADD_ON_LOADED,
    OnAddonLoaded
)
