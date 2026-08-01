local internal = Medic.internal

local BaseModule = internal.class.BaseModule
local NewLifeQuestLocalizationFix = BaseModule:Subclass()

function NewLifeQuestLocalizationFix:New(...)
    return BaseModule.New(self, ...)
end

function NewLifeQuestLocalizationFix:Initialize()
    self.id = "NewLifeQuestLocalizationFix"
    self.optionLabel = "Fix New Life Festival Quest Localizations"
    self.optionTooltip = "Turn it on to fix the missing translations for the newly added New Life Festival quests."
    self.requiresReload = true
end

function NewLifeQuestLocalizationFix:ShouldLoad()
    return internal.newLifeQuestFixTranslations ~= nil
end

function NewLifeQuestLocalizationFix:Enable()
    local translations = internal.newLifeQuestFixTranslations
    for k, v in pairs(translations) do
        if v:find("<<player") then
            v = zo_strformat(v)
            translations[k] = v
        end

        local winK = k:gsub("\n", "\r\n")
        if winK ~= k then
            translations[winK] = v:gsub("\n", "\r\n")
        end
    end

    local functionsToPatch = {
        { name = "GenerateQuestEndingTooltipLine",           returns = { 1 } },
        { name = "GenerateQuestNameTooltipLine",             returns = { 1 } },
        { name = "GenerateQuestConditionTooltipLine",        returns = { 1 } },
        { name = "GenerateMapPingTooltipLine",               returns = { 1 } },
        { name = "GenerateAvAObjectiveConditionTooltipLine", returns = { 1 } },
        { name = "GetPOIInfo",                               returns = { 1, 3, 4 } },
        { name = "GetJournalQuestInfo",                      returns = { 1, 2, 3, 5 } },
        { name = "GetJournalQuestName",                      returns = { 1 } },
        { name = "GetJournalQuestConditionInfo",             returns = { 1 } },
        { name = "GetOfferedQuestInfo",                      returns = { 1, 2 } },
        { name = "GetOfferedQuestShareInfo",                 returns = { 1 } },
        { name = "GetChatterGreeting",                       returns = { 1 } },
        { name = "GetChatterData",                           returns = { 1 } },
        { name = "GetChatterOption",                         returns = { 1 } },
        { name = "GetChatterFarewell",                       returns = { 1, 2 } },
        { name = "GetJournalQuestEnding",                    returns = { 1, 2, 3, 4, 5, 6 } },
        { name = "GetCompletedQuestInfo",                    returns = { 1 } },
        { name = "GetCompletedQuestLocationInfo",            returns = { 1, 2 } },
        { name = "GetJournalQuestRewardInfo",                returns = { 2 } },
        { name = "GetQuestItemName",                         returns = { 1 } },
        { name = "GetQuestItemNameFromLink",                 returns = { 1 } },
        { name = "GetQuestItemTooltipText",                  returns = { 1 } },
        -- { obj = function() return ZO_Interaction end,        name = "ResetInteraction",                    args = { 2 } },
        -- { obj = function() return ZO_Interaction end,        name = "PopulateChatterOption",               args = { 4 } },
        { obj = ZO_CenterScreenAnnounce_GetEventHandlers,    name = EVENT_QUEST_ADDED,                     args = { 2 } },
        { obj = ZO_CenterScreenAnnounce_GetEventHandlers,    name = EVENT_QUEST_COMPLETE,                  args = { 1 } },
        { obj = ZO_CenterScreenAnnounce_GetEventHandlers,    name = EVENT_QUEST_CONDITION_COUNTER_CHANGED, args = { 3, 9 } },
        { obj = ZO_CenterScreenAnnounce_GetEventHandlers,    name = EVENT_QUEST_OPTIONAL_STEP_ADVANCED,    args = { 1 } },
    }
    -- if NTDial then
    --     -- NTakDialog replaces INTERACTION:PopulateChatterOption which breaks inheritance, so we need to patch the function directly on the instance
    --     functionsToPatch[#functionsToPatch + 1] = {
    --         obj = function() return INTERACTION end,
    --         name =
    --         "PopulateChatterOption",
    --         args = { 4 }
    --     }
    -- end

    local function PatchFunction(entry)
        local obj = _G
        if entry.obj then
            obj = entry.obj()
            if not obj then return end
        end

        local originalFunction = obj[entry.name]
        obj[entry.name] = function(...)
            local args = { ... }
            if entry.args then
                for _, index in ipairs(entry.args) do
                    args[index] = translations[args[index]] or args[index]
                end
            end
            local returns = { originalFunction(unpack(args)) }
            if entry.returns then
                for _, index in ipairs(entry.returns) do
                    returns[index] = translations[returns[index]] or returns[index]
                end
            end
            return unpack(returns)
        end
    end

    local originalGetJournalQuestName = GetJournalQuestName
    local originalGetQuestItemNameFromLink = GetQuestItemNameFromLink

    for _, entry in ipairs(functionsToPatch) do
        PatchFunction(entry)
    end

    InformationTooltip.AppendQuestCondition = function(tooltip, questIndex, stepIndex, conditionIndex)
        local text = GenerateQuestConditionTooltipLine(questIndex, stepIndex, conditionIndex)
        local r, g, b = ZO_NORMAL_TEXT:UnpackRGB()
        tooltip:AddLine(text, nil, r, g, b)
    end

    InformationTooltip.AppendQuestEnding = function(tooltip, questIndex)
        local text = GenerateQuestEndingTooltipLine(questIndex)
        local r, g, b = ZO_NORMAL_TEXT:UnpackRGB()
        tooltip:AddLine(text, nil, r, g, b)
    end

    InformationTooltip.AppendQuestName = function(tooltip, questIndex)
        local text = GenerateQuestNameTooltipLine(questIndex)
        tooltip:AddLine(text)
    end

    local function AppendTranslatedQuestItemTooltip(tooltip, questItemId, questIndex)
        local itemName = zo_strformat("<<1>>", GetQuestItemName(questItemId))
        local tooltipText = GetQuestItemTooltipText(questItemId)

        ZO_Tooltip_AddDivider(tooltip)
        tooltip:AddLine(itemName, "ZoFontWinH2", ZO_SELECTED_TEXT:UnpackRGB())
        ZO_Tooltip_AddDivider(tooltip)
        tooltip:AddLine(tooltipText, "ZoFontGameMedium", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
        if questIndex then
            tooltip:AddLine("Quest: |cffffff" .. GetJournalQuestName(questIndex), "ZoFontGameMedium",
                ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
        end
    end

    local function PatchTooltipFunction(tooltipObj, funcName, replacementFunc)
        local originalFunc = tooltipObj[funcName]
        tooltipObj[funcName] = function(tooltip, ...)
            return replacementFunc(originalFunc, tooltip, ...)
        end
    end

    local function SetQuestItem(originalFunc, tooltip, questIndex, stepIndex, conditionIndex)
        originalFunc(tooltip, questIndex, stepIndex, conditionIndex)
        local name = originalGetJournalQuestName(questIndex)
        if translations[name] then
            local questItemId = GetQuestConditionQuestItemId(questIndex, stepIndex, conditionIndex)
            AppendTranslatedQuestItemTooltip(tooltip, questItemId, questIndex)
        end
    end

    local function SetQuestTool(originalFunc, tooltip, questIndex, toolIndex)
        originalFunc(tooltip, questIndex, toolIndex)
        local name = originalGetJournalQuestName(questIndex)
        if translations[name] then
            local questItemId = GetQuestToolQuestItemId(questIndex, toolIndex)
            AppendTranslatedQuestItemTooltip(tooltip, questItemId, questIndex)
        end
    end

    local function SetQuestItemLink(originalFunc, tooltip, itemLink)
        originalFunc(tooltip, itemLink)
        local name = originalGetQuestItemNameFromLink(itemLink)
        if translations[name] then
            local _, _, _, questItemId = ZO_LinkHandler_ParseLink(itemLink)
            AppendTranslatedQuestItemTooltip(tooltip, questItemId)
        end
    end

    PatchTooltipFunction(ItemTooltip, "SetQuestItem", SetQuestItem)
    PatchTooltipFunction(ItemTooltip, "SetQuestTool", SetQuestTool)
    PatchTooltipFunction(PopupTooltip, "SetLink", SetQuestItemLink)

    local originalGetCenterOveredPinDescription = COMPASS.container.GetCenterOveredPinDescription
    COMPASS.container.GetCenterOveredPinDescription = function(self, pinIndex)
        local text = originalGetCenterOveredPinDescription(self, pinIndex)
        if text:sub(-2) == "|r" then
            local colorCodeStart = text:find(" |c%x%x%x%x%x%x")
            if colorCodeStart then
                local mainText = text:sub(1, colorCodeStart - 1)
                local suffix = text:sub(colorCodeStart)
                if translations[mainText] then
                    return translations[mainText] .. suffix
                end
                return text
            end
        end
        return translations[text] or text
    end

    QUEST_JOURNAL_MANAGER:BuildQuestListData()
    QUEST_JOURNAL_KEYBOARD:OnQuestsUpdated()
end

internal:AddModule(NewLifeQuestLocalizationFix:New())
