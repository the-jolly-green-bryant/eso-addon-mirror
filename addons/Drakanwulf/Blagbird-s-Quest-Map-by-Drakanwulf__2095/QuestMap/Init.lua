--[[

Quest Map Initialization
by Drakanwulf

This module creates, initializes, and updates the Quest Map addon data table and provides the QuestMap global for its cross-reference tables.

--]]


-- Addon info
QuestMap = {}
QuestMap.displayName	= "Quest Map"
QuestMap.idName			= "QuestMap"
QuestMap.versionId		= "2.0.1"	 

-- Quest State Pin Type Constants
local PIN_TYPE_QUEST_UNCOMPLETED = "Quest_uncompleted"
local PIN_TYPE_QUEST_COMPLETED   = "Quest_completed"
local PIN_TYPE_QUEST_HIDDEN      = "Quest_hidden"
local PIN_TYPE_QUEST_STARTED     = "Quest_started"
local PIN_TYPE_QUEST_CADWELL     = "Quest_cadwell"
local PIN_TYPE_QUEST_SKILL       = "Quest_skill"

-- Transfer pintype definitions to the Main table
QuestMap.pinTypes = {
    uncompleted = PIN_TYPE_QUEST_UNCOMPLETED,
    completed   = PIN_TYPE_QUEST_COMPLETED,
    hidden      = PIN_TYPE_QUEST_HIDDEN,
    started     = PIN_TYPE_QUEST_STARTED,
    cadwell     = PIN_TYPE_QUEST_CADWELL,
    skill       = PIN_TYPE_QUEST_SKILL
}

-- Define the Saved Variables tables and load their defaults
QuestMap.savedVarsDefault = {
    ["iconSet"] = "QuestMap",
    ["pinSize"] = 25,
    ["pinLevel"] = 40,
    ["hiddenQuests"] = {},
    ["pinFilters"] = {
        [PIN_TYPE_QUEST_UNCOMPLETED]         = true,
        [PIN_TYPE_QUEST_COMPLETED]           = false,
        [PIN_TYPE_QUEST_HIDDEN]              = false,
        [PIN_TYPE_QUEST_STARTED]             = false,
        [PIN_TYPE_QUEST_CADWELL]             = false,
        [PIN_TYPE_QUEST_SKILL]               = false,
    },
    ["displayClickMsg"] = true,
    ["lastListArg"] = "uncompleted",
}