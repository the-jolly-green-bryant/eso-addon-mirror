local WR = Wegesruhe

WR.questTypeDefinitions = {
    { key = "none",             constant = "QUEST_TYPE_NONE",              label = "QUEST_TYPE_NONE" },
    { key = "mainStory",        constant = "QUEST_TYPE_MAIN_STORY",        label = "QUEST_TYPE_MAIN_STORY" },
    { key = "guild",            constant = "QUEST_TYPE_GUILD",             label = "QUEST_TYPE_GUILD" },
    { key = "class",            constant = "QUEST_TYPE_CLASS",             label = "QUEST_TYPE_CLASS" },
    { key = "companion",        constant = "QUEST_TYPE_COMPANION",         label = "QUEST_TYPE_COMPANION" },
    { key = "crafting",         constant = "QUEST_TYPE_CRAFTING",          label = "QUEST_TYPE_CRAFTING" },
    { key = "dungeon",          constant = "QUEST_TYPE_DUNGEON",           label = "QUEST_TYPE_DUNGEON" },
    { key = "group",            constant = "QUEST_TYPE_GROUP",             label = "QUEST_TYPE_GROUP" },
    { key = "raid",             constant = "QUEST_TYPE_RAID",              label = "QUEST_TYPE_RAID" },
    { key = "undauntedPledge",  constant = "QUEST_TYPE_UNDAUNTED_PLEDGE",  label = "QUEST_TYPE_UNDAUNTED_PLEDGE" },
    { key = "prologue",         constant = "QUEST_TYPE_PROLOGUE",          label = "QUEST_TYPE_PROLOGUE" },
    { key = "holidayEvent",     constant = "QUEST_TYPE_HOLIDAY_EVENT",     label = "QUEST_TYPE_HOLIDAY_EVENT" },
    { key = "tribute",          constant = "QUEST_TYPE_TRIBUTE",           label = "QUEST_TYPE_TRIBUTE" },
    { key = "scribing",         constant = "QUEST_TYPE_SCRIBING",          label = "QUEST_TYPE_SCRIBING" },
    { key = "tamrielTale",      constant = "QUEST_TYPE_TAMRIEL_TALE",      label = "QUEST_TYPE_TAMRIEL_TALE" },
    { key = "favor",            constant = "QUEST_TYPE_FAVOR",             label = "QUEST_TYPE_FAVOR" },
    { key = "ava",              constant = "QUEST_TYPE_AVA",               label = "QUEST_TYPE_AVA" },
    { key = "avaGrand",         constant = "QUEST_TYPE_AVA_GRAND",         label = "QUEST_TYPE_AVA_GRAND" },
    { key = "avaGroup",         constant = "QUEST_TYPE_AVA_GROUP",         label = "QUEST_TYPE_AVA_GROUP" },
    { key = "battleground",     constant = "QUEST_TYPE_BATTLEGROUND",      label = "QUEST_TYPE_BATTLEGROUND" },
}

WR.repeatTypeDefinitions = {
    { key = "notRepeatable", constant = "QUEST_REPEAT_NOT_REPEATABLE",       label = "REPEAT_NOT_REPEATABLE" },
    { key = "daily",         constant = "QUEST_REPEAT_DAILY",                label = "REPEAT_DAILY" },
    { key = "weekly",        constant = "QUEST_REPEAT_WEEKLY",               label = "REPEAT_WEEKLY" },
    { key = "monthly",       constant = "QUEST_REPEAT_MONTHLY",              label = "REPEAT_MONTHLY" },
    { key = "repeatable",    constant = "QUEST_REPEAT_REPEATABLE",           label = "REPEAT_REPEATABLE" },
    { key = "eventReset",    constant = "QUEST_REPEAT_EVENT_RESET",          label = "REPEAT_EVENT_RESET" },
    { key = "perDuration",   constant = "QUEST_REPEAT_REPEATABLE_PER_DURATION", label = "REPEAT_PER_DURATION" },
}

function WR:BuildQuestFilterCatalog()
    self.questTypeKeyByValue = {}
    self.repeatTypeKeyByValue = {}

    for _, definition in ipairs(self.questTypeDefinitions) do
        local value = _G[definition.constant]
        if type(value) == "number" then
            self.questTypeKeyByValue[value] = definition.key
        end
    end

    for _, definition in ipairs(self.repeatTypeDefinitions) do
        local value = _G[definition.constant]
        if type(value) == "number" then
            self.repeatTypeKeyByValue[value] = definition.key
        end
    end
end

function WR:IsQuestIndexAllowed(journalIndex)
    if type(journalIndex) ~= "number" or journalIndex < 1 or not IsValidQuestIndex(journalIndex) then
        return true
    end

    local profile = self:GetActiveProfile()
    if not profile then
        return true
    end

    local questType = GetJournalQuestType(journalIndex)
    local questTypeKey = self.questTypeKeyByValue and self.questTypeKeyByValue[questType]
    if questTypeKey and profile.questTypes and profile.questTypes[questTypeKey] == false then
        return false
    end

    local repeatType = GetJournalQuestRepeatType(journalIndex)
    local repeatTypeKey = self.repeatTypeKeyByValue and self.repeatTypeKeyByValue[repeatType]
    if repeatTypeKey and profile.repeatTypes and profile.repeatTypes[repeatTypeKey] == false then
        return false
    end

    return true
end

function WR:ApplyQuestAreaFilters()
    if not COMPASS or not COMPASS.RemoveAreaPinsByQuest then
        return
    end

    for journalIndex = 1, MAX_JOURNAL_QUESTS do
        if IsValidQuestIndex(journalIndex) and not self:IsQuestIndexAllowed(journalIndex) then
            COMPASS:RemoveAreaPinsByQuest(journalIndex)
        end
    end
end

function WR:InitializeQuestFilters()
    self:BuildQuestFilterCatalog()

    -- Quest pins retain their journal quest index in the pin tag. This lets us
    -- distinguish the official QuestType/QuestRepeatableType values per pin on
    -- the world map and compass without changing the player's quest tracking.
    if ZO_MapPin and ZO_MapPin.GetQuestIcon and not self.questIconHooked then
        self.questIconHooked = true
        self.originalGetQuestIcon = ZO_MapPin.GetQuestIcon
        local original = self.originalGetQuestIcon

        function ZO_MapPin:GetQuestIcon()
            local journalIndex = self:GetQuestIndex()
            if journalIndex and journalIndex > 0 and not WR:IsQuestIndexAllowed(journalIndex) then
                return WR.blankTexture
            end
            return original(self)
        end
    end

    -- Quest-area animations on the compass are built through a separate path
    -- and do not ask ZO_MapPin:GetQuestIcon, so filter those explicitly too.
    if COMPASS and COMPASS.PlayQuestAreaPinOutAnimation and not self.questAreaHooked then
        self.questAreaHooked = true
        self.originalPlayQuestAreaPinOutAnimation = COMPASS.PlayQuestAreaPinOutAnimation
        local original = self.originalPlayQuestAreaPinOutAnimation

        function COMPASS:PlayQuestAreaPinOutAnimation(journalIndex, stepIndex, conditionIndex)
            if not WR:IsQuestIndexAllowed(journalIndex) then
                return
            end
            return original(self, journalIndex, stepIndex, conditionIndex)
        end
    end
end
