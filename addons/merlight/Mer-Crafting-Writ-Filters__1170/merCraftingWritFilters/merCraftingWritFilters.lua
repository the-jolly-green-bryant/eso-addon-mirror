local myNAME = "merCraftingWritFilters"
local Language = GetCVar("Language.2")
local PlayerInventory = PLAYER_INVENTORY

local g_playerName = nil
local g_craftingQuests = {}
local g_parsingTests = {}

local getItemNameFromCondition


-- NOTE: explicitly limit gsub replacements to 1 ('^' anchor is not enough)
--      to avoid this bug: http://www.esoui.com/forums/showthread.php?t=4989

local function stripVerb(conditionText, acceptedVerbs)
    local word = conditionText:match("^(%S+) ")
    if acceptedVerbs[word] then
        return conditionText:sub(#word + 2)
    end
end

if Language == "de" then
    local verbs = {["Beschafft"] = "", ["Besorgt"] = "", ["Stellt"] = ""}
    local articles = {["ein"] = "", ["eine"] = "", ["einen"] = "", ["einige"] = "", ["etwas"] = ""}
    local tails = {["Aspektrune"] = "", ["Essenzrune"] = "", ["Machtrune"] = "", ["her"] = ""}
    function getItemNameFromCondition(conditionText)
        local what = stripVerb(conditionText, verbs)
        return what and what
            :gsub("^(%l+) ", articles, 1)   -- strip article
            :gsub(": %d+/%d+$", "")         -- strip have/need counts
            :gsub("[- ](%a+)$", tails)      -- strip rune type / trailing "her"
            :lower()
    end
    ZO_CreateStringId("SI_MERCRAFTINGWRITFILTERS_TABTITLE", "Schrieb")
    -- alchemy examples
    g_parsingTests["Beschafft natürliches Wasser"] = "natürliches wasser"
    g_parsingTests["Besorgt etwas Drachendorn"] = "drachendorn"
    g_parsingTests["Stellt ein Schlückchen der Ausdauerverwüstung her"] = "schlückchen der ausdauerverwüstung"
    g_parsingTests["Stellt eine Lösung des Lebens her"] = "lösung des lebens"
    -- enchanting examples
    g_parsingTests["Beschafft eine Hade-Machtrune"] = "hade"
    g_parsingTests["Stellt eine starke Glyphe des Lebens her"] = "starke glyphe des lebens"
    -- provisioning examples
    g_parsingTests["Stellt etwas Karottensuppe her"] = "karottensuppe"

elseif Language == "fr" then
    local verbs = {["Acquérez"] = "", ["Fabriquez"] = "", ["Préparez"] = ""}
    local articles = {["de"] = "", ["des"] = "", ["un"] = "", ["une"] = ""}
    local runes = {["aspect"] = "", ["essence"] = "", ["puissance"] = ""}
    function getItemNameFromCondition(conditionText)
        local what = stripVerb(conditionText, verbs)
        return what and what
            :gsub("^(%u%S+) ", verbs, 1)        -- strip leading verb
            :gsub("^(%l+) ", articles, 1)       -- strip article
            :gsub("^l'", "", 1)                 -- strip pronoun
            :lower()
            :gsub("^rune de?[ '](%a+) ", runes) -- strip rune type
            :gsub("\194\160: %d+/%d+$", "")     -- strip have/need counts
    end
    ZO_CreateStringId("SI_MERCRAFTINGWRITFILTERS_TABTITLE", "Commande")
    -- alchemy examples
    g_parsingTests["Acquérez de l'eau Naturelle"] = "eau naturelle"
    g_parsingTests["Acquérez une Épine-de-Dragon"] = "épine-de-dragon"
    g_parsingTests["Préparez une Gorgée de Ravage de Vigueur"] = "gorgée de ravage de vigueur"
    g_parsingTests["Préparez une Solution de Santé"] = "solution de santé"
    -- enchanting examples
    g_parsingTests["Acquérez une Rune de Puissance Hade"] = "hade"
    g_parsingTests["Fabriquez un Glyphe Fort Vital"] = "glyphe fort vital"
    -- provisioning examples
    g_parsingTests["Préparez un Pain de Maïs Cyrodiiléen"] = "pain de maïs cyrodiiléen"
    g_parsingTests["Préparez une Soupe de Carottes"] = "soupe de carottes"

else
    local verbs = {["Acquire"] = "", ["Craft"] = ""}
    local runes = {["aspect"] = "", ["essence"] = "", ["potency"] = ""}
    function getItemNameFromCondition(conditionText)
        local what = stripVerb(conditionText, verbs)
        return what and what
            :gsub(":\194\160%d+\194\160/\194\160%d+$", "")  -- strip have/need counts
            :lower()
            :gsub(" (%a+) rune$", runes)                    -- strip rune type
    end
    ZO_CreateStringId("SI_MERCRAFTINGWRITFILTERS_TABTITLE", "Writ")
end


local g_itemTypeRequiresCrafter = {
    [ITEMTYPE_POISON] = "anyone",
    [ITEMTYPE_POTION] = "anyone",
    [ITEMTYPE_GLYPH_ARMOR] = "myself",
    [ITEMTYPE_GLYPH_JEWELRY] = "myself",
    [ITEMTYPE_GLYPH_WEAPON] = "myself",
    [ITEMTYPE_ARMOR] = "myself",
    [ITEMTYPE_WEAPON] = "myself",
}

local g_itemTypeRequiresQuality = {
    [ITEMTYPE_ALCHEMY_BASE] = ITEM_QUALITY_NORMAL,
    [ITEMTYPE_REAGENT] = ITEM_QUALITY_MAGIC,
    [ITEMTYPE_POISON] = false, -- meaning ignore, for compatibility with add-ons
    [ITEMTYPE_POTION] = false, -- overriding crafted potions' apparent quality
    [ITEMTYPE_FOOD] = ITEM_QUALITY_MAGIC,
    [ITEMTYPE_DRINK] = ITEM_QUALITY_MAGIC,
    [ITEMTYPE_ENCHANTING_RUNE_ASPECT] = ITEM_QUALITY_NORMAL,
    [ITEMTYPE_ENCHANTING_RUNE_ESSENCE] = ITEM_QUALITY_NORMAL,
    [ITEMTYPE_ENCHANTING_RUNE_POTENCY] = ITEM_QUALITY_NORMAL,
    [ITEMTYPE_GLYPH_ARMOR] = ITEM_QUALITY_NORMAL,
    [ITEMTYPE_GLYPH_JEWELRY] = ITEM_QUALITY_NORMAL,
    [ITEMTYPE_GLYPH_WEAPON] = ITEM_QUALITY_NORMAL,
    [ITEMTYPE_ARMOR] = ITEM_QUALITY_NORMAL,
    [ITEMTYPE_WEAPON] = ITEM_QUALITY_NORMAL,
}

local function isItemNeededForWrit(slot)
    -- filter on item quality first, should be the most efficient

    local requiredQuality = g_itemTypeRequiresQuality[slot.itemType]
    if requiredQuality ~= false and requiredQuality ~= slot.quality then
        return false
    end

    local requiredCrafter = g_itemTypeRequiresCrafter[slot.itemType]
    if requiredCrafter == "myself" then
        local creator = GetItemCreatorName(slot.bagId, slot.slotIndex)
        if creator ~= g_playerName then
            return false
        end
    elseif requiredCrafter == "anyone" then
        local itemLink = GetItemLink(slot.bagId, slot.slotIndex)
        local potionEffects = select(24, ZO_LinkHandler_ParseLink(itemLink))
        if potionEffects == "0" then
            return false
        end
    end

    local itemName = slot.name:lower()
    for questName, questConditions in next, g_craftingQuests do
        if questConditions[itemName] then
            return true
        end
    end

    return false
end


local function addInventoryFilter(inventoryType)
    local inventory = PlayerInventory.inventories[inventoryType]
    local filterString = GetString(SI_MERCRAFTINGWRITFILTERS_TABTITLE)
    local tabData =
    {
        -- Inventory manager data
        filterType = isItemNeededForWrit,
        inventoryType = inventoryType,
        hiddenColumns = {age = true, statValue = true},
        activeTabText = filterString,
        tooltipText = filterString,

        -- Menu bar data
        visible = function() return next(g_craftingQuests) ~= nil end,
        descriptor = isItemNeededForWrit,
        normal = "EsoUI/Art/Journal/journal_tabIcon_cadwell_up.dds",
        pressed = "EsoUI/Art/Journal/journal_tabIcon_cadwell_down.dds",
        highlight = "EsoUI/Art/Journal/journal_tabIcon_cadwell_over.dds",
        callback = function(tabData) PlayerInventory:ChangeFilter(tabData) end,
    }

    local menuBar = inventory.filterBar.m_object
    local button, key = menuBar.m_pool:AcquireObject()

    button.m_object:SetData(menuBar, tabData)
    tabData.control = button
    ZO_AlphaAnimation:New(button:GetNamedChild("Flash"))

    -- buttons are right-aligned, so the first is the right-most
    table.insert(menuBar.m_buttons, 1, {button, key, tabData.descriptor})
    menuBar:UpdateButtons()
end


local function updateBankFilters()
    ZO_MenuBar_UpdateButtons(PlayerInventory.inventories[INVENTORY_BANK].filterBar)
    ZO_MenuBar_UpdateButtons(PlayerInventory.inventories[INVENTORY_GUILD_BANK].filterBar)
end


local function updateCondition(questConditions, conditionText, curValue, maxValue, isFail)
    local itemName = getItemNameFromCondition(conditionText)
    if not itemName then return end

    --df("condition %q", conditionText:gsub("\194\160", "~"))
    --df("-> item %q", itemName:gsub("\194\160", "~"))

    if isFail or curValue >= maxValue then
        questConditions[itemName] = nil
    else
        questConditions[itemName] = maxValue - curValue
    end
end


local function getQuestConditions(questIndex)
    local questConditions = {}
    for j = 1, GetJournalQuestNumSteps(questIndex) do
        for k = 1, GetJournalQuestNumConditions(questIndex, j) do
            updateCondition(questConditions, GetJournalQuestConditionInfo(questIndex, j, k))
        end
    end
    return questConditions
end


local function onPlayerActivated(eventCode)
    -- run only once
    EVENT_MANAGER:UnregisterForEvent(myNAME, eventCode)

    for questIndex = 1, MAX_JOURNAL_QUESTS do
        if GetJournalQuestType(questIndex) == QUEST_TYPE_CRAFTING then
            local questName = GetJournalQuestInfo(questIndex)
            g_craftingQuests[questName] = getQuestConditions(questIndex)
        end
    end

    addInventoryFilter(INVENTORY_BANK)
    addInventoryFilter(INVENTORY_GUILD_BANK)
end


local function onQuestAdded(eventCode, questIndex, questName)
    if GetJournalQuestType(questIndex) == QUEST_TYPE_CRAFTING then
        g_craftingQuests[questName] = getQuestConditions(questIndex)
        updateBankFilters()
    end
end


local function onQuestChanged(eventCode, questIndex, questName, conditionText, conditionType,
                              oldValue, newValue, maxValue, isFail)
    local questConditions = g_craftingQuests[questName]
    if questConditions then
        updateCondition(questConditions, conditionText, newValue, maxValue, isFail)
    end
end


local function onQuestRemoved(eventCode, isCompleted, questIndex, questName)
    if g_craftingQuests[questName] then
        g_craftingQuests[questName] = nil
        updateBankFilters()
    end
end


local g_assistedTextureWasHidden = nil
local g_conditionMinWidth = 0
local g_headerMinWidth = 0
local g_questNameToCraftingType =
{
    -- English
    ["Alchemist Writ"] = CRAFTING_TYPE_ALCHEMY,
    ["Blacksmith Writ"] = CRAFTING_TYPE_BLACKSMITHING,
    ["Clothier Writ"] = CRAFTING_TYPE_CLOTHIER,
    ["Enchanter Writ"] = CRAFTING_TYPE_ENCHANTING,
    ["Provisioner Writ"] = CRAFTING_TYPE_PROVISIONING,
    ["Woodworker Writ"] = CRAFTING_TYPE_WOODWORKING,
    -- German
    ["Alchemistenschrieb"] = CRAFTING_TYPE_ALCHEMY,
    ["Schmiedeschrieb"] = CRAFTING_TYPE_BLACKSMITHING,
    ["Schneiderschrieb"] = CRAFTING_TYPE_CLOTHIER,
    ["Verzaubererschrieb"] = CRAFTING_TYPE_ENCHANTING,
    ["Versorgerschrieb"] = CRAFTING_TYPE_PROVISIONING,
    ["Schreinerschrieb"] = CRAFTING_TYPE_WOODWORKING,
    -- French
    ["Commande d'alchimie"] = CRAFTING_TYPE_ALCHEMY,
    ["Commande de forge"] = CRAFTING_TYPE_BLACKSMITHING,
    ["Commande de tailleur"] = CRAFTING_TYPE_CLOTHIER,
    ["Commandes d'enchantement"] = CRAFTING_TYPE_ENCHANTING,
    ["Commande de cuisine"] = CRAFTING_TYPE_PROVISIONING,
    ["Commande de travail du bois"] = CRAFTING_TYPE_WOODWORKING,
}


local function hookQuestTrackerPools(tracker)
    ZO_PreHook(tracker.headerPool, "customAcquireBehavior", function(control)
        control:SetDimensionConstraints(g_headerMinWidth, 0, 0, 0)
    end)
    ZO_PreHook(tracker.conditionPool, "customAcquireBehavior", function(control)
        control:SetDimensionConstraints(g_conditionMinWidth, 0, 0, 0)
    end)
end


local function setQuestTrackerEntriesMinWidth(tracker, headerWidth, conditionWidth)
    g_headerMinWidth = headerWidth
    g_conditionMinWidth = conditionWidth
    for _, header in next, tracker.headerPool:GetActiveObjects() do
        header:SetDimensionConstraints(headerWidth, 0, 0, 0)
    end
    for _, condition in next, tracker.conditionPool:GetActiveObjects() do
        condition:SetDimensionConstraints(conditionWidth, 0, 0, 0)
    end
end


local function onCraftingStationInteract(eventCode, craftSkill, sameStation)
    for questIndex = 1, MAX_JOURNAL_QUESTS do
        if GetJournalQuestType(questIndex) == QUEST_TYPE_CRAFTING then
            local questName = GetJournalQuestInfo(questIndex)
            if g_questNameToCraftingType[questName] == craftSkill then
                QUEST_TRACKER:ForceAssist(questIndex) -- focus this quest
                SCENE_MANAGER:AddFragment(FOCUSED_QUEST_TRACKER_FRAGMENT)
                FOCUSED_QUEST_TRACKER_FRAGMENT:SetHiddenForReason("DisabledBySetting", false)
                local tracker = FOCUSED_QUEST_TRACKER
                g_assistedTextureWasHidden = tracker.assistedTexture:IsHidden()
                tracker.assistedTexture:SetHidden(true)
                tracker.trackerControl:ClearAnchors()
                tracker.trackerControl:SetAnchor(BOTTOMLEFT, ZO_SharedRightPanelBackground, TOPLEFT, 35, -35)
                setQuestTrackerEntriesMinWidth(tracker, 522, 512)
                return
            end
        end
    end
end


local function onCraftingStationLeave(eventCode, craftSkill)
    if g_assistedTextureWasHidden ~= nil then
        local tracker = FOCUSED_QUEST_TRACKER
        tracker.assistedTexture:SetHidden(g_assistedTextureWasHidden)
        g_assistedTextureWasHidden = nil
        setQuestTrackerEntriesMinWidth(tracker, 0, 0)
        tracker:ApplyPlatformStyle() -- restore control anchors and widths
        tracker:UpdateVisibility() -- hide fragment if DisabledBySetting
    end
end


local function onAddOnLoaded(eventCode, addOnName)
    if addOnName ~= myNAME then return end
    EVENT_MANAGER:UnregisterForEvent(myNAME, eventCode)

    g_playerName = GetUnitName("player")
    hookQuestTrackerPools(FOCUSED_QUEST_TRACKER)

    EVENT_MANAGER:RegisterForEvent(myNAME, EVENT_PLAYER_ACTIVATED, onPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(myNAME, EVENT_QUEST_ADDED, onQuestAdded)
    EVENT_MANAGER:RegisterForEvent(myNAME, EVENT_QUEST_CONDITION_COUNTER_CHANGED, onQuestChanged)
    EVENT_MANAGER:RegisterForEvent(myNAME, EVENT_QUEST_REMOVED, onQuestRemoved)
    EVENT_MANAGER:RegisterForEvent(myNAME, EVENT_CRAFTING_STATION_INTERACT, onCraftingStationInteract)
    EVENT_MANAGER:RegisterForEvent(myNAME, EVENT_END_CRAFTING_STATION_INTERACT, onCraftingStationLeave)

    --[[
    SLASH_COMMANDS["/dbgwrit"] = function(args)
        df("----------  %s  ----------", myNAME)
        for conditionText, expectedItemName in next, g_parsingTests do
            local parsedItemName = getItemNameFromCondition(conditionText)
            local color = (parsedItemName == expectedItemName and "33ff33" or "ff3333")
            df("|c%stest %q|r", color, conditionText)
            df("|c%s-> %q|r", color, parsedItemName)
        end
        for questName, questConditions in next, g_craftingQuests do
            df("quest %q : %d", questName, NonContiguousCount(questConditions))
            for itemName, neededCount in next, questConditions do
                df("-> item %q : %d", itemName, neededCount)
            end
        end
    end
    --]]
end


EVENT_MANAGER:RegisterForEvent(myNAME, EVENT_ADD_ON_LOADED, onAddOnLoaded)
