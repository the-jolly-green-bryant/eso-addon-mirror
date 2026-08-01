
function LeoTrainer.IsInUsableStation()
    local station = GetCraftingInteractionType()

    return station == CRAFTING_TYPE_BLACKSMITHING or
        station == CRAFTING_TYPE_WOODWORKING or
        station == CRAFTING_TYPE_CLOTHIER or
        station == CRAFTING_TYPE_JEWELRYCRAFTING or
        station == CRAFTING_TYPE_ENCHANTING
end

function LeoTrainer.LLC_Completed(event, station, result)
    if event == LLC_NO_FURTHER_CRAFT_POSSIBLE then
        LeoTrainer.debug("Nothing more to craft at this station.")
        if LeoTrainer.stage == LEOTRAINER_STAGE_CRAFT then
            LeoTrainer.nextStage()
        end
        return
    end

    if event ~= LLC_CRAFT_SUCCESS then return end

    if result.Requester ~= LeoTrainer.name then return end

    LeoTrainer.data.craftQueue[result.reference].crafted = true
    LeoTrainer.ui.queueScroll:RefreshData()

    LeoTrainer.craft.MarkItem(result.bag, result.slot)

    if LeoTrainer.craft.StillHaveCraftToDo(station) then return end

    LeoTrainer.debug("All crafts done at this station.")
    LeoTrainer.nextStage()
end

function LeoTrainer.OnCraftComplete(event, station)
    EVENT_MANAGER:UnregisterForUpdate(LeoTrainer.name .. ".ResearchItemTimeout")

    if LeoTrainer.research.isResearching then
        local myName = GetUnitName("player")
        local researching, total = LeoAltholic.GetResearchCounters(station)
        table.remove(LeoTrainer.research.queue, 1)
        LeoTrainer.research.isResearching = false
        if #LeoTrainer.research.queue > 0 then
            zo_callLater(function() LeoTrainer.ResearchNext(true) end, 400)
            return
        end
    end

    if LeoTrainer.isCrafting == 0 then return end

    local data = LeoTrainer.RemoveFromQueue(LeoTrainer.isCrafting)
    LeoTrainer.isCrafting = 0

    data.crafted = GetLastCraftingResultItemLink(1)
    table.insert(craftedItems, data)

    if GetCraftingInteractionType() ~= CRAFTING_TYPE_INVALID and LeoTrainer.continueCrating == true then
        zo_callLater(function() LeoTrainer.CraftNext() end, 200)
    end
end

function LeoTrainer.nextStage(moreDelay)
    LeoTrainer.stage = LeoTrainer.stage + 1
    if LeoTrainer.stage > LEOTRAINER_STAGE_DONE then
        LeoTrainer.stage = LEOTRAINER_STAGE_START
    end
    local craftSkill = GetCraftingInteractionType()
    if craftSkill > 0 then
        zo_callLater(function() LeoTrainer.continueAtStation(craftSkill) end, moreDelay and 200 or 10)
    end
end

function LeoTrainer.continueAtStation(craftSkill)
    if LeoTrainer.stage == LEOTRAINER_STAGE_RESEARCH then
        LeoTrainer.ui.OnStationEnter(craftSkill)
        zo_callLater(function() LeoTrainer.research.OnStationEnter(craftSkill) end, 10)
        return
    end

    if LeoTrainer.stage == LEOTRAINER_STAGE_DECONSTRUCT then
        zo_callLater(function() LeoTrainer.deconstruct.OnStationEnter(craftSkill) end, 10)
        return
    end

    if LeoTrainer.stage == LEOTRAINER_STAGE_CRAFT then
        zo_callLater(function() LeoTrainer.craft.OnStationEnter(craftSkill) end, 10)
        return
    end

    if LeoTrainer.stage == LEOTRAINER_STAGE_DONE then
        zo_callLater(function() LeoTrainer.craft.TryWritCreator(craftSkill) end, 10)
        return
    end
end

function LeoTrainer.stationEnter(craftSkill)
    if not LeoTrainer.IsInUsableStation() then
        LeoTrainer.craft.TryWritCreator(craftSkill)
        return
    end

    if WritCreater then
        EVENT_MANAGER:UnregisterForEvent(WritCreater.name, EVENT_CRAFT_COMPLETED)
    end

    LeoTrainer.ScanBags(craftSkill)

    LeoTrainer.stage = LEOTRAINER_STAGE_RESEARCH

    LeoTrainer.continueAtStation(craftSkill)
    -- LeoTrainerStation:SetHidden(false)
end

function LeoTrainer.stationExit(_, craftSkill)
    EVENT_MANAGER:UnregisterForEvent(LeoTrainer.name, EVENT_CRAFT_COMPLETED)
    if WritCreater then
        EVENT_MANAGER:UnregisterForEvent(WritCreater.name, EVENT_CRAFTING_STATION_INTERACT)
        EVENT_MANAGER:UnregisterForEvent(WritCreater.name, EVENT_CRAFT_COMPLETED)
    end

    LeoTrainer.ui.OnStationExit(craftSkill)
    LeoTrainer.research.OnStationExit(craftSkill)
    LeoTrainer.deconstruct.OnStationExit(craftSkill)
    LeoTrainer.craft.OnStationExit(craftSkill)
end

local craftSkillsBySound = {
    [ITEM_SOUND_CATEGORY_BOW]             = CRAFTING_TYPE_WOODWORKING,
    [ITEM_SOUND_CATEGORY_DAGGER]          = CRAFTING_TYPE_BLACKSMITHING,
    [ITEM_SOUND_CATEGORY_HEAVY_ARMOR]     = CRAFTING_TYPE_BLACKSMITHING,
    [ITEM_SOUND_CATEGORY_LIGHT_ARMOR]     = CRAFTING_TYPE_CLOTHIER,
    [ITEM_SOUND_CATEGORY_MEDIUM_ARMOR]    = CRAFTING_TYPE_CLOTHIER,
    [ITEM_SOUND_CATEGORY_NECKLACE]        = CRAFTING_TYPE_JEWELRYCRAFTING,
    [ITEM_SOUND_CATEGORY_ONE_HAND_AX]     = CRAFTING_TYPE_BLACKSMITHING,
    [ITEM_SOUND_CATEGORY_ONE_HAND_HAMMER] = CRAFTING_TYPE_BLACKSMITHING,
    [ITEM_SOUND_CATEGORY_ONE_HAND_SWORD]  = CRAFTING_TYPE_BLACKSMITHING,
    [ITEM_SOUND_CATEGORY_RING]            = CRAFTING_TYPE_JEWELRYCRAFTING,
    [ITEM_SOUND_CATEGORY_SHIELD]          = CRAFTING_TYPE_WOODWORKING,
    [ITEM_SOUND_CATEGORY_STAFF]           = CRAFTING_TYPE_WOODWORKING,
    [ITEM_SOUND_CATEGORY_TWO_HAND_AX]     = CRAFTING_TYPE_BLACKSMITHING,
    [ITEM_SOUND_CATEGORY_TWO_HAND_HAMMER] = CRAFTING_TYPE_BLACKSMITHING,
    [ITEM_SOUND_CATEGORY_TWO_HAND_SWORD]  = CRAFTING_TYPE_BLACKSMITHING,
    [ITEM_SOUND_CATEGORY_ENCHANTMENT]     = CRAFTING_TYPE_ENCHANTING
}

function LeoTrainer.CraftToLineSkill(craftSkill)
    if craftSkill == CRAFTING_TYPE_BLACKSMITHING then return 2
    elseif craftSkill == CRAFTING_TYPE_CLOTHIER then return 3
    elseif craftSkill == CRAFTING_TYPE_WOODWORKING then return 7
    elseif craftSkill == CRAFTING_TYPE_JEWELRYCRAFTING then return 5
    elseif craftSkill == CRAFTING_TYPE_ENCHANTING then return 4 end

    return 0
end

function LeoTrainer.ItemLinkToCraftskill(itemLink)
    return craftSkillsBySound[GetItemSoundCategoryFromLink(itemLink)] or 0
end

local function isLineBeingResearched(research, craft, line)
    for _, researching in pairs(research.doing[craft]) do
        if researching.line == line then
            if researching.doneAt and researching.doneAt - GetTimeStamp() > 0 then
                return true
            end
        end
    end
    return false
end

local function get(tbl, k, ...)
    if tbl == nil or tbl[k] == nil then return nil end
    if select('#', ...) == 0 then return tbl[k] end
    return get(tbl[k], ...)
end

local function set(tbl, k, maybeValue, ...)
    if select('#', ...) == 0 then
      -- this will throw if the top-level tbl is nil, which is the desired behavior
      tbl[k] = maybeValue
      return
    end
    if tbl[k] == nil then tbl[k] = {} end
    set(tbl[k], maybeValue, ...)
end

function LeoTrainer.GetPriorityLineList(charName, craftSkillFilter)
    local charList
    if charName == nil then
        charList = LeoAltholic.ExportCharacters()
    else
        charList = {LeoAltholic.GetCharByName(charName)}
    end

    local craftSKillList = LeoAltholic.craftResearch
    if craftSkillFilter ~= nil then craftSKillList = {craftSkillFilter} end
    local knownCount = {}
    local unknownTraits = {}
    local lineList = {}
    for _, char in pairs(charList) do
        for _, craftSkill in pairs(craftSKillList) do
            set(lineList, char.bio.name, craftSkill, {})

            if LeoTrainer.isTrackingSkill(char.bio.name, craftSkill) and LeoTrainer.canFillSlotWithSkill(char.bio.name, craftSkill) then

                for line = 1, GetNumSmithingResearchLines(craftSkill) do
                    local lineName, _, numTraits = GetSmithingResearchLineInfo(craftSkill, line)

                    set(unknownTraits, char.bio.name, craftSkill, line, {})
                    set(knownCount, char.bio.name, craftSkill, line, 0)

                    for trait = 1, numTraits do
                        local isKnown, isResearching = LeoAltholic.ResearchStatus(craftSkill, line, trait, char.bio.name)
                        if isKnown or isResearching then
                            local numKnown = get(knownCount, char.bio.name, craftSkill, line)
                            numKnown = numKnown + 1
                            set(knownCount, char.bio.name, craftSkill, line, numKnown)
                        elseif not isKnown then
                            table.insert(unknownTraits[char.bio.name][craftSkill][line], trait)
                        end
                    end

                    table.insert(lineList[char.bio.name][craftSkill], {
                        line = line,
                        lineName = lineName,
                        count = knownCount[char.bio.name][craftSkill][line],
                        unknownTraits = unknownTraits[char.bio.name][craftSkill][line],
                        isResearching = isLineBeingResearched(char.research, craftSkill, line)
                    })
                end

                table.sort(lineList[char.bio.name][craftSkill], function(a, b)
                    return a.count < b.count
                end)

            end
        end
    end

    return lineList
end

function LeoTrainer.ScanBags(craftSkill)
    local shouldResearch = LeoTrainer.research.ShouldResearch(craftSkill)
    local shouldDeconstruct = LeoTrainer.deconstruct.ShouldDeconstruct(craftSkill)
    local list = {}
    local items = SHARED_INVENTORY:GenerateFullSlotData(nil, BAG_BACKPACK, BAG_BANK, BAG_SUBSCRIBER_BANK)
    for _, data in pairs(items) do
        local itemLink = GetItemLink(data.bagId, data.slotIndex, LINK_STYLE_BRACKETS)

        local itemCraftSkill = LeoTrainer.ItemLinkToCraftskill(itemLink)
        if itemCraftSkill ~= nil and itemCraftSkill > 0 and itemCraftSkill == craftSkill then
            local handled = false
            if shouldResearch then
                handled = LeoTrainer.research.HandleItem(data.bagId, data.slotIndex, itemLink, craftSkill)
            end
            if not handled and shouldDeconstruct then
                handled = LeoTrainer.deconstruct.HandleItem(data.bagId, data.slotIndex, itemLink, craftSkill)
            end
        end
    end

    return list
end

function LeoTrainer.isTrackingSkill(charName, craftId)
    return LeoTrainer.data.trackedTraits[charName][craftId]
end

function LeoTrainer.setTrackingSkill(charName, craftId, tracking)
    LeoTrainer.data.trackedTraits[charName][craftId] = tracking
end

function LeoTrainer.canFillSlotWithSkill(charName, craftId)
    return LeoTrainer.data.fillSlot[charName][craftId]
end

function LeoTrainer.setFillSlotWithSkill(charName, craftId, tracking)
    LeoTrainer.data.fillSlot[charName][craftId] = tracking
end

function LeoTrainer.Initialize()

    LeoTrainer.settings = LibSavedVars
        :NewAccountWide( "LeoTrainer_Settings", "Account", LeoTrainer.settingsDefaults )
        :AddCharacterSettingsToggle( "LeoTrainer_Settings", "Characters" )
    LeoTrainer.settings.loaded = true

    LeoTrainer.data = LibSavedVars:NewAccountWide( "LeoTrainer_Data", LeoTrainer.dataDefaults )
    LeoTrainer.data.loaded = true

    if LeoTrainer.data.silent == nil then LeoTrainer.data.silent = false end

    if LeoTrainer.settings.deconstruct.maxQuality[CRAFTING_TYPE_ENCHANTING] == nil then LeoTrainer.settings.deconstruct.maxQuality[CRAFTING_TYPE_ENCHANTING] = ITEM_FUNCTIONAL_QUALITY_ARCANE end

    LeoTrainer.stage = LEOTRAINER_STAGE_START

    LeoTrainer.craft.Initialize()
    LeoTrainer.research.Initialize()
    LeoTrainer.bank.Initialize()
    LeoTrainer.ui.Initialize()

    SLASH_COMMANDS["/leotrainer"] = function(cmd)
        if cmd == nil or cmd == "" then
            LeoTrainer.ui:ToggleUI()
            return
        end

        if cmd == "debug" then
            if not LeoTrainer.isDebug then
                LeoTrainer.isDebug = true
                LeoTrainer.debug("Debug mode ON")
            else
                LeoTrainer.isDebug = false
                LeoTrainer.log("Debug mode OFF")
            end
            return
        end

        if cmd == "decon" and LeoTrainer.IsInUsableStation() then
            LeoTrainer.deconstruct.DoDeconstruct()
        end
    end

    if GetDisplayName() == "@LeandroSilva" then
        SLASH_COMMANDS["/rr"] = function(cmd)
            ReloadUI()
        end
    end
end

function LeoTrainer.log(message, force)
    if force == nil then force = false end
    if LeoTrainer.data.silent == true and not force then return end

    d(LeoTrainer.chatPrefix .. message)
end

function LeoTrainer.debug(message)
    if not LeoTrainer.isDebug then return end
    LeoTrainer.log('[D] ' .. message, true)
end

local function onNewMovementInUIMode(eventCode)
    if not LeoTrainerWindow:IsHidden() then LeoTrainer.ui:CloseUI() end
end

local function onChampionPerksSceneStateChange(oldState,newState)
    if newState == SCENE_SHOWING then
        if not LeoTrainerWindow:IsHidden() then LeoTrainer.ui:CloseUI() end
    end
end

local function onLeoAltholicInitialized()
    CALLBACK_MANAGER:UnregisterCallback("LeoAltholicInitialized", onLeoAltholicInitialized)
    SCENE_MANAGER:RegisterTopLevel(LeoTrainerWindow, false)

    LeoTrainer.Initialize()

    if WritCreater then
        EVENT_MANAGER:UnregisterForEvent(WritCreater.name, EVENT_CRAFTING_STATION_INTERACT)
        EVENT_MANAGER:UnregisterForEvent(WritCreater.name, EVENT_CRAFT_COMPLETED)
    end
    EVENT_MANAGER:UnregisterForEvent("LibLazyCrafting", EVENT_CRAFTING_STATION_INTERACT)

    EVENT_MANAGER:RegisterForEvent(LeoTrainer.name, EVENT_CRAFTING_STATION_INTERACT, function (_, ...) LeoTrainer.stationEnter(...) end)
    EVENT_MANAGER:RegisterForEvent(LeoTrainer.name, EVENT_END_CRAFTING_STATION_INTERACT, LeoTrainer.stationExit)
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", function(panel) LeoTrainer_SettingsMenu:OnSettingsControlsCreated(panel) end)
    EVENT_MANAGER:RegisterForEvent(LeoTrainer.name, EVENT_NEW_MOVEMENT_IN_UI_MODE, onNewMovementInUIMode)
    CHAMPION_PERKS_SCENE:RegisterCallback('StateChange', onChampionPerksSceneStateChange)

    LeoTrainer.LLC = LibLazyCrafting:AddRequestingAddon(LeoTrainer.name, true, LeoTrainer.LLC_Completed)

    LeoTrainer.log("started.", true)
end

function LeoTrainer.OnAddOnLoaded(event, addonName)
    if addonName == LeoTrainer.name then
        EVENT_MANAGER:UnregisterForEvent(LeoTrainer.name, EVENT_ADD_ON_LOADED)
        onLeoAltholicInitialized()
    end
end

CALLBACK_MANAGER:RegisterCallback("LeoAltholicInitialized", onLeoAltholicInitialized)
