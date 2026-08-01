DoItAll = DoItAll or {}
local DoItAllSlots = DoItAll.Slots:New(DoItAll.ItemFilter:New(true))
local extractFunction, container, craftingTableCtrlVar, craftingTablePanel
local addedToCraftCounter = 0
local goOnLaterWithExtraction = false
local extractNextCalls = 0
local origAddToCraftSound = SOUNDS.SMITHING_ITEM_TO_EXTRACT_PLACED
--======================================================================================================================
--  Keybindings
--======================================================================================================================
local function getSmithingMode()
    local modeObject = ZO_Smithing_GetActiveObject() or SMITHING
    return modeObject:GetMode()
end
local function getEnchantingMode()
    return ENCHANTING:GetEnchantingMode()
end

local function GetKeyStripName()
    local useZOsVanillaUIForMulticraft = DoItAll.IsZOsVanillaUIMultiCraftEnabled() or false
    local suppressAskBeforeExtractAllDialog = (useZOsVanillaUIForMulticraft and DoItAll.Settings["GetSuppressAskBeforeExtractDialog"]()) or false
    local retVarStr = ""
    local currentScene = SCENE_MANAGER.currentScene.name
    if currentScene == "enchanting" or DoItAll.IsShowingExtraction() then
        local enchantMode = getEnchantingMode()
        if enchantMode == ENCHANTING_MODE_EXTRACTION then
            if useZOsVanillaUIForMulticraft then
                if suppressAskBeforeExtractAllDialog then
                    retVarStr = "Extract all (Multi - NO WARNING!)"
                else
                    retVarStr = "Extract all (Multi)"
                end
            else
                retVarStr = "Extract all (Indiv.)"
            end
            return retVarStr
        end
    elseif currentScene == "smithing" then
        local mode = getSmithingMode()
        if mode == SMITHING_MODE_REFINMENT then
            if useZOsVanillaUIForMulticraft then
                if suppressAskBeforeExtractAllDialog then
                    retVarStr = "Refine all (Multi - NO WARNING!)"
                else
                    retVarStr = "Refine all (Multi)"
                end
            else
                retVarStr = "Refine all (Indiv.)"
            end
            return retVarStr
        elseif mode == SMITHING_MODE_DECONSTRUCTION then
            if useZOsVanillaUIForMulticraft then
                if suppressAskBeforeExtractAllDialog then
                    retVarStr = "Deconstr. all (Multi - NO WARNING!)"
                else
                    retVarStr = "Deconstr. all (Multi)"
                end
            else
                retVarStr = "Deconstr. all (Indiv.)"
            end
            return retVarStr
        end
    elseif currentScene == "universalDeconstructionSceneKeyboard" then
        if not UNIVERSAL_DECONSTRUCTION then return end
        local mode = UNIVERSAL_DECONSTRUCTION.mode
        if mode == SMITHING_MODE_DECONSTRUCTION then
            if useZOsVanillaUIForMulticraft then
                if suppressAskBeforeExtractAllDialog then
                    retVarStr = "Decon/Extract all (Multi - NO WARNING!)"
                else
                    retVarStr = "Decon/Extract all (Multi)"
                end
            else
                retVarStr = "Decon/Extract all (Indiv.)"
            end
            return retVarStr
        end
    end
    return nil
end

local function ShouldShow()
    local retVar = false
    local currentScene = SCENE_MANAGER.currentScene.name
    if currentScene == "enchanting" or DoItAll.IsShowingExtraction() then
        local enchantMode = getEnchantingMode()
        if enchantMode == ENCHANTING_MODE_EXTRACTION then
            retVar = true
        end
    elseif currentScene == "smithing" then
        local mode = getSmithingMode()
        if mode == SMITHING_MODE_REFINMENT then
            retVar = true
        elseif mode == SMITHING_MODE_DECONSTRUCTION then
            retVar = true
        end
    elseif currentScene == "universalDeconstructionSceneKeyboard" then
        if not UNIVERSAL_DECONSTRUCTION then return end
        local mode = UNIVERSAL_DECONSTRUCTION.mode
        if mode == SMITHING_MODE_DECONSTRUCTION then
            retVar = true
        end
    end
    return retVar
end

local keystripDef = {
    name = function() return GetKeyStripName() end,
    keybind = "SC_BANK_ALL",
    callback = function() DoItAll.ExtractAll() end,
    alignment = KEYBIND_STRIP_ALIGN_LEFT,
    visible = function() return ShouldShow() end,
}

table.insert(SMITHING.keybindStripDescriptor, keystripDef)
table.insert(ENCHANTING.keybindStripDescriptor, keystripDef)
if UNIVERSAL_DECONSTRUCTION ~= nil then
    table.insert(UNIVERSAL_DECONSTRUCTION.keybindStripDescriptor, keystripDef)
end


--======================================================================================================================
-- Other
--======================================================================================================================
local function extractionSoundHack(enable, play)
    if enable then
        SOUNDS.SMITHING_ITEM_TO_EXTRACT_PLACED = origAddToCraftSound
        if play then
            PlaySound(SOUNDS.SMITHING_ITEM_TO_EXTRACT_PLACED)
        end
    else
        SOUNDS.SMITHING_ITEM_TO_EXTRACT_PLACED = SOUNDS.NONE
    end
end

--======================================================================================================================
-- Extraction
--======================================================================================================================
function DoItAll.IsShowingExtraction()
	return not ZO_EnchantingTopLevelExtractionSlotContainer:IsHidden()
end

function DoItAll.IsShowingDeconstruction()
	return ZO_Smithing_IsSceneShowing() and not ZO_SmithingTopLevelDeconstructionPanelSlotContainer:IsHidden()
end

function DoItAll.IsShowingRefinement()
	return ZO_Smithing_IsSceneShowing() and not ZO_SmithingTopLevelRefinementPanelSlotContainer:IsHidden()
end

function DoItAll.IsShowingDeconNPC()
    return not UNIVERSAL_DECONSTRUCTION.control:IsHidden()
end

local function GetExtractionContainerFunctionCtrlAndPanel()
    if UNIVERSAL_DECONSTRUCTION ~= nil and DoItAll.IsShowingDeconNPC() then
        return ZO_UniversalDeconstructionTopLevel_KeyboardPanelInventoryBackpack, ExtractOrRefineSmithingItem, UNIVERSAL_DECONSTRUCTION, UNIVERSAL_DECONSTRUCTION.deconstructionPanel
    elseif DoItAll.IsShowingExtraction() then
        return ZO_EnchantingTopLevelInventoryBackpack, ExtractEnchantingItem, ENCHANTING, ENCHANTING
    elseif DoItAll.IsShowingDeconstruction() then
        return ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack, ExtractOrRefineSmithingItem, SMITHING, SMITHING.deconstructionPanel
    elseif DoItAll.IsShowingRefinement() then
        return ZO_SmithingTopLevelRefinementPanelInventoryBackpack, ExtractOrRefineSmithingItem, SMITHING, SMITHING.refinementPanel
    end
end

local function GetNextSlotToExtract()
  if not DoItAllSlots:Fill(container, 1) then
	DoItAllSlots:ClearNotAllowed()
  	return nil
  end
  return DoItAllSlots:Next()
end

local function ExtractionFinished(wasError)
    wasError = wasError or false
--d("[DoItAll]ExtractionFinished, wasError: " ..tostring(wasError))
    --No extraction was started? Then unregister old events which might have been get stuck due to lua errors!
    if wasError or not DoItAll.extractionActive or extractFunction == nil or container == nil
        or craftingTableCtrlVar == nil or craftingTablePanel == nil then
--d("<ABORT!")
        DoItAll.extractionActive = false
        goOnLaterWithExtraction = false
        EVENT_MANAGER:UnregisterForEvent("DoItAllExtractionCraftCompleted", EVENT_CRAFT_COMPLETED)
        --UNregister the crafting start event to check if an error happened later on
        --EVENT_MANAGER:UnregisterForEvent("DoItAllExtractionCraftStarted", EVENT_CRAFT_STARTED)
        --Unregister the crafting failed event to check if some variables need to be resetted
        EVENT_MANAGER:UnregisterForEvent("DoItAllExtractionCraftFailed", EVENT_CRAFT_FAILED)
        --ReEnable the sound
        extractionSoundHack(true, false)
        return
    end
    local nothingToExtract = true
    local useZOsVanillaUIForMulticraft = DoItAll.IsZOsVanillaUIMultiCraftEnabled() or false
    local suppressAskBeforeExtractAllDialog = (useZOsVanillaUIForMulticraft and DoItAll.Settings["GetSuppressAskBeforeExtractDialog"]()) or false
    if useZOsVanillaUIForMulticraft then
        --Extract the slotted items now
        if craftingTablePanel.extractionSlot then
            local extractionSlot = craftingTablePanel.extractionSlot
            if extractionSlot:HasItems() then
                --ReEnable the sound and play it once now
                extractionSoundHack(true, true)
                if DoItAll.IsShowingRefinement() then
                    if not suppressAskBeforeExtractAllDialog and craftingTablePanel.ConfirmRefine then
                        craftingTablePanel:ConfirmRefine()
                        nothingToExtract = false
                    elseif suppressAskBeforeExtractAllDialog and craftingTablePanel.ExtractAll then
                        craftingTablePanel:ExtractAll()
                        nothingToExtract = false
                    end
                else
                    if extractionSlot:HasOneItem() then
                        if craftingTablePanel.ExtractSingle then
                            craftingTablePanel:ExtractSingle()
                            nothingToExtract = false
                        else
                            nothingToExtract = true
                        end
                    elseif extractionSlot:HasMultipleItems() then
                        if not suppressAskBeforeExtractAllDialog and craftingTablePanel.ConfirmExtractAll then
                            craftingTablePanel:ConfirmExtractAll()
                            nothingToExtract = false
                        elseif suppressAskBeforeExtractAllDialog and craftingTablePanel.ExtractAll then
                            craftingTablePanel:ExtractAll()
                            nothingToExtract = false
                        else
                            nothingToExtract = true
                        end
                    end
                end
            else
                nothingToExtract = true
            end
        else
            nothingToExtract = true
        end
    else
        goOnLaterWithExtraction = false
    end
    --Security check toi prevent endless loop if the extraction functions did not work or exist anymore
    if nothingToExtract then
        goOnLaterWithExtraction = false
    end
    --Unregister the events for the extraction but only if we are not waiting for possible next slots to extract after the current ones
    --via ZOs vanilla UI Multicraft
    if not goOnLaterWithExtraction then
        EVENT_MANAGER:UnregisterForEvent("DoItAllExtractionCraftCompleted", EVENT_CRAFT_COMPLETED)
        --UNregister the crafting start event to check if an error happened later on
        --EVENT_MANAGER:UnregisterForEvent("DoItAllExtractionCraftStarted", EVENT_CRAFT_STARTED)
        --Unregister the crafting failed event to check if some variables need to be resetted
        EVENT_MANAGER:UnregisterForEvent("DoItAllExtractionCraftFailed", EVENT_CRAFT_FAILED)
    end
    --Set the global variable to false: Extraction was finished/Aborted
    DoItAll.extractionActive = false
end

--Event handler for EVENT_END_CRAFTING_STATION_INTERACT at extraction
local function OnCraftingEnd(eventCode, wasError)
--d("[DoItAll] OnCraftingEnd - Extraction")
	if DoItAll.extractionActive then
		local whatWasAbortedText = GetKeyStripName()
        d("[DoItAll] \'" .. tostring(whatWasAbortedText) .. "\' was aborted!")
		ExtractionFinished(wasError)
	end
    --ReEnable the sound add to craft again
    extractionSoundHack(true, false)
end

--Callback function for EVENT_CRAFT_STARTED
local function OnSingleCraftFailed(eventCode, tradeskillResult)
--d("[DoItAll] CraftFailed - Extraction. TradeskillResult: " ..tostring(tradeskillResult))
    if tradeskillResult == CRAFTING_RESULT_INTERRUPTED then
        OnCraftingEnd(eventCode, true)
    end
end

--Callback function for EVENT_CRAFT_STARTED
--local function OnSingleCraftStarted(eventCode, tradeskillType)
--    d("[DoItAll] CraftStarted - Extraction")
--end

local function ExtractNext(firstExtract)
    extractNextCalls = extractNextCalls +1
    firstExtract = firstExtract or false
--d("[DoItAll]ExtractNext, extraction active: " .. tostring(DoItAll.extractionActive) .. ", firstExtract: " ..tostring(firstExtract))
    --Prevent "hang up extractions" from last crafting station visit activating extraction all slots if something else was crafted!
    if not DoItAll.extractionActive then
        addedToCraftCounter = 999
        goOnLaterWithExtraction = false
        return
    end
    local delayMs = 0
--d(">addedToCraftCounter: " ..tostring(addedToCraftCounter))

--d("[DoItAll]ExtractNext("..tostring(firstExtract)..")")

    --get the next slot to extract
    local doitall_slot = GetNextSlotToExtract()
    if not doitall_slot then
--d("<<<NO SLOT LEFT-> FINISHED!")
        --No slot left -> Finish here
        goOnLaterWithExtraction = false
        ExtractionFinished()
    else
        local extractable = true
        if craftingTableCtrlVar.CanItemBeAddedToCraft then
            extractable = craftingTableCtrlVar:CanItemBeAddedToCraft(doitall_slot.bagId, doitall_slot.slotIndex)
        else
            --Are we inside refinement?
            --Is the current slot's stackCount < 10 (no refinement is possible then)?
            if DoItAll.IsShowingRefinement() and doitall_slot.stackCount ~= nil and doitall_slot.stackCount < 10 then
                extractable = false
            end
        end
        if extractable then
--d(">item is extractable: " .. GetItemLink(doitall_slot.bagId, doitall_slot.slotIndex))
            --Is the vanilla UI ZOs multicraft (added with Scalebreaker patch) the one to extarct all?
            --Or should DoItAll handle this like before on it's own?
            if DoItAll.IsZOsVanillaUIMultiCraftEnabled() then
                if craftingTableCtrlVar.AddItemToCraft then
                    --Code for max stack count and max deconstructable items taken from function ZO_SharedSmithingExtraction:AddItemToCraft(bagId, slotIndex)
                    -->esoui/ingame/crafting/smithingextraction_shared.lua
                    local extractionSlot = craftingTablePanel.extractionSlot
                    local isInRefineMode = craftingTableCtrlVar.mode == SMITHING_MODE_REFINMENT or false
                    local newStackCount = extractionSlot:GetStackCount() + zo_max(1, craftingTablePanel.inventory:GetStackCount(doitall_slot.bagId, doitall_slot.slotIndex)) -- non virtual items will have a stack count of 0, but still count as 1 item
                    local stackCountPerIteration = isInRefineMode and GetRequiredSmithingRefinementStackSize() or 1
                    local maxStackCount = MAX_ITERATIONS_PER_DECONSTRUCTION * stackCountPerIteration
                    local stackCountCanBeAdded = newStackCount <= maxStackCount or false
--d(">extractionSlot has items: " .. tostring(extractionSlot:HasItems()) .. ", numItems: " .. tostring(extractionSlot:GetNumItems()) ..", stackCountCanBeAdded: " .. tostring(stackCountCanBeAdded) .. " (newStackCount: " ..tostring(newStackCount) .. ", stackCountPerIteration: " ..tostring(stackCountPerIteration) ..")")

                    goOnLaterWithExtraction = false
                    -- Pevent slotting if it would take us above the MAX_ITEM_SLOTS_PER_DECONSTRUCTION or the stackCount iteration limit,
                    -- but allow it if nothing else has been slotted yet so we can support single stacks that are larger than the limit
                    if extractionSlot:GetNumItems() >= MAX_ITEM_SLOTS_PER_DECONSTRUCTION or (extractionSlot:HasItems() and not stackCountCanBeAdded) then
                        --Security check to prevent endless loops!
                        if addedToCraftCounter > 0 then
--d("<ExtractionFinished because no more items can be slotted/stackCount max reached!")
                            goOnLaterWithExtraction = true
                            --Extract the 100 items now and then goOn with the next up to 100 items
                            ExtractionFinished(false)
                        end
                    else
                        addedToCraftCounter = addedToCraftCounter + 1
--d(">Added item count: " ..tostring(addedToCraftCounter))
                        --Change the sound for "Add item to craft" to NONE so adding multiple items won't be THAT LOUD...

                        --Only add the item to the extraction slot
                        craftingTableCtrlVar:AddItemToCraft(doitall_slot.bagId, doitall_slot.slotIndex)
                        --Disallow this item to be tried to added for extraction again in next call to ExtractNext
                        DoItAllSlots:AddToNotAllowed(doitall_slot.bagId, doitall_slot.slotIndex)
                        --Go on with next slot as the event EVENT_CRAFT_COMPLETED won't be called
                        ExtractNext(false)
                    end
                end
------------------------------------------------------------------------------------------------------------------------
            else
                --Use DoItALL to extract 1 item after another
                if not firstExtract then
                    --Get the MS for the delay between extractions
                    delayMs = DoItAll.Settings.GetExtractDelay()
                else
                    delayMs = 0
                end
                --d("[DoItAll]ExtractNext delay: " .. tostring(delayMs))
                if delayMs > 0 then
                    --Call the extraction function with a delay
                    zo_callLater(function() extractFunction(doitall_slot.bagId, doitall_slot.slotIndex) end, delayMs)
                else
                    extractFunction(doitall_slot.bagId, doitall_slot.slotIndex)
                end
            end
        else
            --Disallow this item to be tried to extracted again
            DoItAllSlots:AddToNotAllowed(doitall_slot.bagId, doitall_slot.slotIndex)
            --Go on with next slot as the event EVENT_CRAFT_COMPLETED won't be called
            ExtractNext(false)
        end
    end
end

local function StartExtraction()
--d("[DoItAll]StartExtraction")
    --Set global variable to see if DoItAll extraction is active
    DoItAll.extractionActive = true
    --Disable the "Add to slot sound" so it will not be EXTREMELY LOUD if multiple items get added in a loop
    extractionSoundHack(false, false)
    --Register the crafting start event to check if an error happened later on
    --EVENT_MANAGER:RegisterForEvent("DoItAllExtractionCraftStarted", EVENT_CRAFT_STARTED, OnSingleCraftStarted)
    --Register the crafting failed event to check if some variables need to be resetted
    EVENT_MANAGER:RegisterForEvent("DoItAllExtractionCraftFailed", EVENT_CRAFT_FAILED, OnSingleCraftFailed)
	--Register event to check if extraction has been aborted -> Avoid automatic extraction next time an item has been extracted
	EVENT_MANAGER:RegisterForEvent("DoItAllExtractionCraftCompleted", EVENT_CRAFT_COMPLETED,
            function()
                --Only go on with the next slot to extract if not the ZOs vanilla UI multicraft is used
                if not DoItAll.IsZOsVanillaUIMultiCraftEnabled() then
                    ExtractNext(false)
                else
                    --Shall we go on with the extraction with ZOs vanilla UI multicraft?
                    if goOnLaterWithExtraction == true then
                        DoItAll.ExtractAll()
                    end
                end
            end)
    --Start the extraction. Every next slot will be handled via ExtractNext function from EVENT_CRAFT_COMPLETED then
    ExtractNext(true)
end

function DoItAll.ExtractAll()
--d("[DoItAll]ExtractAll")
    --ZOs UI is handling the extraction
    container, extractFunction, craftingTableCtrlVar, craftingTablePanel = GetExtractionContainerFunctionCtrlAndPanel()
    if container == nil or craftingTableCtrlVar == nil then return end
    --Clear/Initialize the not allowed slot entries
    DoItAllSlots:ClearNotAllowed()
    addedToCraftCounter = 0
    goOnLaterWithExtraction = false
    extractNextCalls = 0
    --Start the extraction
    StartExtraction()
end

--Crafting Station interaction - BEGIN
EVENT_MANAGER:RegisterForEvent("DoItAllExtractionCraftingInteract", EVENT_CRAFTING_STATION_INTERACT, function(eventCode, TradeskillType , sameStation)
    --d("[DoItAll] CraftingStationInteract BEGIN - Extraction")
    --Extraction
    --Reset the extraction is active variable
    DoItAll.extractionActive = false
    --Supported crafting station?
    if TradeskillType ~= CRAFTING_TYPE_PROVISIONING and TradeskillType ~= CRAFTING_TYPE_ALCHEMY then
        --Keybinds
        --Remove the old keybind if there is still one activated
        if DoItAll.currentKeyStripDef ~= nil then
            KEYBIND_STRIP:RemoveKeybindButtonGroup(DoItAll.currentKeyStripDef)
        end
        --Add the keystrip def to the global vars so we can reach it from everywhere
        DoItAll.currentKeyStripDef = keystripDef
    end
end)
--Crafting Station interaction - END
EVENT_MANAGER:RegisterForEvent("DoItAllExtractionCraftingEndInteract", EVENT_END_CRAFTING_STATION_INTERACT, function(eventCode)
    --d("[DoItAll] CraftingStationInteract END - Extraction")
    --Extraction
    OnCraftingEnd(eventCode, false)

    --Keybinds
    --Remove the old keybind if there is still one activated
    if DoItAll.currentKeyStripDef ~= nil then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(DoItAll.currentKeyStripDef)
    end
    --Reset the last used one
    DoItAll.currentKeyStripDef = nil
end)