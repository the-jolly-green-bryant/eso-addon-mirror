local addonName = 'AutoResearchScrolls'

AutoResearchScrolls = {
	name = addonName,
	version = '1.2.0',
	build = 120
}

local ARS = AutoResearchScrolls
local DB = {}
local LCM = LibChatMessage
local chat = LCM("AutoRS", "AutoRS")

-- Took from "Detailed Research Scrolls" by @silvereyes
-- https://www.esoui.com/downloads/fileinfo.php?id=1761
-- ----------------------------------------------------
local CRAFT_SKILLS_ALL     = { CRAFTING_TYPE_BLACKSMITHING, CRAFTING_TYPE_CLOTHIER, CRAFTING_TYPE_WOODWORKING, CRAFTING_TYPE_JEWELRYCRAFTING }
local ONE_DAY              = 86400

-- Research scrolls manifest
-- -------------------------
local researchScrolls = {
    [125473] = {
        ["craftSkills"] = CRAFTING_TYPE_BLACKSMITHING,
        ["duration"] = ONE_DAY,
    },
    -- Research Scroll, Clothing, 1 Day
    [125474] = {
        ["craftSkills"] = CRAFTING_TYPE_CLOTHIER,
        ["duration"] = ONE_DAY,
    },
    -- Research Scroll, Woodworking, 1 Day
    [125475] = {
        ["craftSkills"] = CRAFTING_TYPE_WOODWORKING,
        ["duration"] = ONE_DAY,
    },
    -- Research Scroll, Jewelry Crafting, 1 Day
    [138814] = {
        ["craftSkills"] = CRAFTING_TYPE_JEWELRYCRAFTING,
        ["duration"] = ONE_DAY,
    }
}

local function LookupResearchScroll(itemLink)
    if not itemLink then return end
    local itemId
    if type(itemLink) == "number" then
        itemId = itemLink
    else
        itemId = GetItemLinkItemId(itemLink)
        if not itemId then return end
    end
    local researchScroll = researchScrolls[itemId]
    return researchScroll
end

local function IsResearchScroll(itemLink)
    local researchScroll = LookupResearchScroll(itemLink)
    if researchScroll then
        return true
    end
end

local function GetScrollCooldown(itemLink)
    return math.floor((select(9,GetItemLinkOnUseAbilityInfo(itemLink))/1000))
end

local async = LibAsync
local taskQueue = async:Create('ScrollQueue')
local operationsTask = async:Create('OperationsTask')
local isScrollQueueRunning = false
local activeResearchLines = {}
local scrollManifest = {}

local function UpdateActiveResearchLines()

    for _, craftSkill in ipairs(CRAFT_SKILLS_ALL) do

        activeResearchLines[craftSkill] = {
            total = GetMaxSimultaneousSmithingResearch(craftSkill),
            active = 0,
            remaining = {},
            completedCategories = 0,
            totalCategories = 0
        }

        local craftData = activeResearchLines[craftSkill]
        -- Total number of research lines for this craft skill
        local researchLineCount = GetNumSmithingResearchLines(craftSkill)
        
        -- Loop through each research line (e.g. axe, mace, etc.)
        for researchLineIndex = 1, researchLineCount do
            
            local knownTraitIndex = 0
            craftData.totalCategories = craftData.totalCategories + 1

            -- Get the total number of traits in the research line
            local numTraits = select(3, GetSmithingResearchLineInfo(craftSkill, researchLineIndex))
            
            for traitIndex = 1, numTraits do
                local secondsRemaining = select(2, GetSmithingResearchLineTraitTimes(craftSkill, researchLineIndex, traitIndex))
                local known = select(3, GetSmithingResearchLineTraitInfo(craftSkill, researchLineIndex, traitIndex))
                if known then
                    knownTraitIndex = knownTraitIndex + 1
                elseif secondsRemaining then
                    craftData.active = craftData.active + 1
                    table.insert(craftData.remaining, secondsRemaining)
                    break
                end
            end
            table.sort(craftData.remaining)

            if knownTraitIndex == numTraits then
                craftData.completedCategories = craftData.completedCategories + 1
            end
        end

        local categoryOffset = craftData.totalCategories - craftData.completedCategories

        if craftData.total >= categoryOffset then
            craftData.total = categoryOffset
        end
    end
end

local function UseScroll(scrollObject)
    if not DB.settings.queue_enabled then return end

    CallSecureProtected('UseItem', scrollObject.bagId, scrollObject.slotIndex)

    taskQueue:Delay(1100, function()
        local qtyCheck = select(1,GetItemLinkStacks(scrollObject.itemLink))

        if qtyCheck == (scrollObject.qty - 1) or scrollObject.qty == 0 then

            scrollObject.qty = scrollObject.qty - 1
    
            local qtyFormat = tostring(scrollObject.qty)
    
            if scrollObject.qty == 2 then qtyFormat = '|cff6868'..tostring(scrollObject.qty) end
            if scrollObject.qty == 1 then qtyFormat = '|cff3737'..tostring(scrollObject.qty) end
            if scrollObject.qty == 0 then qtyFormat = '|cff0606'..tostring(scrollObject.qty) end
            if scrollObject.qty < 0 then qtyFormat = '|cff0606'..tostring(0) end
    
            chat:SetTagColor('58c5ed'):Printf('|t22:22:%s|t%s|cffffff (%s|cffffff left)', scrollObject.icon, scrollObject.itemLink, qtyFormat)
    
        end
    end)
end

local function AddScrollToManifest(itemLink, bagId, slotIndex)
    -- ZO_FormatTimeMilliseconds(remainingCooldown, TIME_FORMAT_STYLE_SHOW_LARGEST_TWO_UNITS, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)
    local remaining = GetScrollCooldown(itemLink)
    local scrollId = GetItemLinkItemId(itemLink)
    local currentScroll = researchScrolls[scrollId]
    local duration = currentScroll.duration
    local stackCount = select(2, GetItemInfo(bagId, slotIndex))
    local icon = GetItemLinkIcon(itemLink)

    scrollManifest[scrollId] = {
        id = scrollId,
        duration = duration,
        itemLink = itemLink,
        remaining = remaining,
        bagId = bagId,
        icon = icon,
        qty = stackCount,
        slotIndex = slotIndex,
        craftSkill = currentScroll.craftSkills
    }

    return scrollManifest[scrollId]
end

local function CheckBagForScrolls()

    local bagCache = SHARED_INVENTORY:GenerateFullSlotData(nil,BAG_BACKPACK)

    for key, item in ipairs(bagCache) do

        local itemLink = GetItemLink(item.bagId, item.slotIndex)

        if IsResearchScroll(itemLink) then
            AddScrollToManifest(itemLink, item.bagId, item.slotIndex)
        end
    end

end

local function CanScrollFire(scrollData)

    local condition = false
    local amountCheck = false
    local durationCheck = true
    local craftData = activeResearchLines[scrollData.craftSkill]

    if scrollData.remaining == 0 then

        -- Must use maximum research slots
        if DB.settings.max_slots then
            if craftData.active == craftData.total then
                amountCheck = true
            end
        -- Fire if at least one research slot
        elseif #craftData.remaining > 0 then
            amountCheck = true
        end

        if DB.settings.scroll_savings then
            -- There is a research item that is lower than the scroll duration
            if #craftData.remaining > 0 and scrollData.duration > craftData.remaining[1] then
                durationCheck = false
            end
        end

       if craftData.completedCategories == craftData.totalCategories then
        amountCheck = false
       end

        if amountCheck and durationCheck then
            condition = true
        end

    end

    return condition

end

local function AddScrollToQueue(scroll)

    if CanScrollFire(scroll) and scroll.bagId == BAG_BACKPACK then
        isScrollQueueRunning = true
        taskQueue:Then(function()
            UseScroll(scroll) 
        end)
    end

end

local function CheckScrollQueue()
    if isScrollQueueRunning then return end
    if not DB.settings.queue_enabled then return end

    local function checkScrollManifest(key, value)
        local scroll = scrollManifest[key]

        if scroll.remaining > 0 then
            scroll.remaining = GetScrollCooldown(scroll.itemLink)
        else
            AddScrollToQueue(scroll)
        end
    end

    taskQueue:For(pairs(scrollManifest)):Do(checkScrollManifest)

    taskQueue:Finally(function()
        isScrollQueueRunning = false
    end)

end

local function DataUpdate()
    if not DB.settings.queue_enabled then return end
    operationsTask:Call(UpdateActiveResearchLines):Then(CheckScrollQueue)
end

local function Boot()
    if not DB.settings.queue_enabled then return end
    operationsTask:Call(CheckBagForScrolls):Then(DataUpdate)
end

local function OnPlayerActivated(eventCode)
    
    EVENT_MANAGER:UnregisterForEvent(addonName, eventCode)
    
    Boot()

    local function OnSceneChange(oldState, newState)
        if (newState == SCENE_SHOWN) then
            taskQueue:Suspend()
            taskQueue:StopTimer()
        elseif (newState == SCENE_HIDDEN) then
            taskQueue:Resume()
        end
    end
     
    local scene = SCENE_MANAGER:GetScene('smithing')
    scene:RegisterCallback("StateChange", OnSceneChange)


    
end

local function OnResearchStarted(eventCode, craftSkill, researchLineIndex, traitIndex)

    if isScrollQueueRunning then return end

    operationsTask:Call(UpdateActiveResearchLines):Then(function()

        if SCENE_MANAGER.currentScene.name == 'smithing' then

            local craftData = activeResearchLines[craftSkill]

            if craftData.active == craftData.total then

                local scroll = false

                for k,v in pairs(scrollManifest) do
                    if scrollManifest[k].craftSkill == craftSkill then
                        scroll = scrollManifest[k]
                        break
                    end
                end

                EVENT_MANAGER:RegisterForEvent(addonName, EVENT_END_CRAFTING_STATION_INTERACT, function(eventCode, craftingType, craftingMode)

                    EVENT_MANAGER:UnregisterForEvent(addonName, eventCode)
                    if scroll then
                        taskQueue:Cancel()
                        AddScrollToQueue(scroll)
                    end

                end)
            end
        end  
    end)

end


-- --------------------
-- Bank Transfer
-- --------------------
local bankQueueIndex = 0
local bankQueueTotal = 0
local bankManifest = {}

local function activeWritCreaterSession()
    if WritCreater then
        local _, hasAny = WritCreater.writSearch()
        return hasAny and WritCreater:GetSettings().shouldGrab
    end
    return false
end

local function MoveScrollFromBankToBag()

    if not DB.settings.queue_enabled then return end
    if not DB.settings.auto_bank then return end
    if activeWritCreaterSession() then return end

    bankQueueIndex = bankQueueIndex + 1
    if bankQueueIndex <= bankQueueTotal then

        local scroll = bankManifest[bankQueueIndex]
        local targetSlotIndex = FindFirstEmptySlotInBag(BAG_BACKPACK)

        if IsProtectedFunction('RequestMoveItem') then
            CallSecureProtected('RequestMoveItem', scroll.bagId, scroll.slotIndex, BAG_BACKPACK, targetSlotIndex, 1)
        else
            RequestMoveItem(scroll.bagId, scroll.slotIndex, BAG_BACKPACK, targetSlotIndex, 1)
        end

        AddScrollToManifest(scroll.itemLink, BAG_BACKPACK, targetSlotIndex)

    else
        EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
        if #bankManifest > 0 then
            SCENE_MANAGER:Show('hud')
        end
    end

end

local function OnItemSlotUpdate(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)

    if not DB.settings.queue_enabled then return end
    if not DB.settings.auto_bank then return end
    if activeWritCreaterSession() then return end
    -- WITHDRAWAL ONLY
    if bagId == BAG_BACKPACK and stackCountChange > 0 then

        local itemLink = GetItemLink(bagId, slotIndex)

        if IsResearchScroll(itemLink) then
            MoveScrollFromBankToBag()
        end
    end

end

local function OnBankOpened(eventCode, bankBag)
    
    if not DB.settings.queue_enabled then return end
    if not DB.settings.auto_bank then return end
    if activeWritCreaterSession() then return end

    if IsHouseBankBag(bankBag) then return end
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnItemSlotUpdate)

    bankManifest = {}
    bankQueueIndex = 0
    bankQueueTotal = 0

    operationsTask:Call(function()
        
        local bagCache = SHARED_INVENTORY:GenerateFullSlotData(nil,BAG_BANK, BAG_SUBSCRIBER_BANK)

        for key, item in ipairs(bagCache) do
    
            local itemLink = GetItemLink(item.bagId, item.slotIndex)
    
            if IsResearchScroll(itemLink) then
                
                local scroll = AddScrollToManifest(itemLink, item.bagId, item.slotIndex)
                
                if CanScrollFire(scroll) then
                    table.insert(bankManifest, scroll)
                    bankQueueTotal = bankQueueTotal + 1
                end

            end
        end

    end):Then(function()

        table.sort(bankManifest, function(a,b) return a.slotIndex > b.slotIndex end)

        if #bankManifest > 0 then
            MoveScrollFromBankToBag()
        end

    end)
end

local function OnBankClosed()

    if not DB.settings.queue_enabled then return end
    if not DB.settings.auto_bank then return end
    if activeWritCreaterSession() then return end
    EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)

    if #bankManifest > 0 then
        bankManifest = {}
        bankQueueIndex = 0
        bankQueueTotal = 0
        
        operationsTask:Call(CheckScrollQueue):Then(CheckBagForScrolls)
    end

end

local function AddBankingEvents()

    if not DB.settings.queue_enabled then return end
    if not DB.settings.auto_bank then return end
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_OPEN_BANK, OnBankOpened)
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_CLOSE_BANK, OnBankClosed)

end

local function RemoveBankingEvents()

    if not DB.settings.queue_enabled then return end
    if not DB.settings.auto_bank then return end
    EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_OPEN_BANK)
    EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_CLOSE_BANK)

end

function ARS.test()
    Zgoo.CommandHandler(scrollManifest)
end

-- --------------------
-- Settings
-- --------------------
local db_defaults = {
    settings = {
        queue_enabled = false,
        scroll_savings = true,
        max_slots = true,
        auto_bank = true
    }
}
local defaultSetting = db_defaults.settings
local controls = {}

controls[#controls+1] = {
    type = "header",
    name = "Settings",
}	
controls[#controls+1] = {
    type = "description",
    title = "",
    text = [[
    ]]
}
controls[#controls+1] = {
    title = "Main Switch",
    type = "description",
    text = [[|c58c5edThe scroll task runner will not start consuming scrolls when conditions are met, unless it is enabled below. This addon |cfc0303only|c58c5ed consumes the 1-Day Research Scrolls provided by the Writ Voucher vendor.]]
}
controls[#controls+1] = {
    title = "",
    type = "description",
    text = [[|cfc0303The option below needs to be set to "On" for the addon to run]],
    reference = "ARS_QueueEnabledWarningLabel"
}
controls[#controls+1] = {
    type = 'checkbox',
    name = 'Enable Auto Research Scrolls',
    warning = 'This will start to consume research scrolls if conditions are met',
    getFunc = function()

        local value = DB.settings.queue_enabled
        ARS_QueueEnabledWarningLabel:SetHidden(value)

        return value
    end,
    setFunc = function(value)
        DB.settings.queue_enabled = value
        ARS_QueueEnabledWarningLabel:SetHidden(value)
        if value == true then
            Boot()
        end
    end,
    default = defaultSetting.queue_enabled
}
controls[#controls+1] = {
    type = "description",
    title = "",
    text = [[
    ]]
}
controls[#controls+1] = {
    type = "description",
    title = "",
    text = [[|c58c5edIf a research timer is under 24 hours, should the scroll wait until it expires?]]
}
controls[#controls+1] = {
    type = 'checkbox',
    name = "Don't use scroll if timers are shorter than 1 day",
    getFunc = function() return DB.settings.scroll_savings end,
    setFunc = function(value) DB.settings.scroll_savings = value end,
    default = defaultSetting.scroll_savings
}
controls[#controls+1] = {
    type = "description",
    title = "",
    text = [[
    ]]
}
controls[#controls+1] = {
    type = "description",
    title = "",
    text = [[|c58c5edDo you want the scroll to run whenever all the available research slots are filled for a crafting type?]]
}
controls[#controls+1] = {
    type = 'checkbox',
    name = "Wait until all research slots are filled",
    getFunc = function() return DB.settings.max_slots end,
    setFunc = function(value) DB.settings.max_slots = value end,
    default = defaultSetting.max_slots
}
controls[#controls+1] = {
    type = "description",
    title = "",
    text = [[

    ]]
}
controls[#controls+1] = {
    title = "Banking",
    type = "description",
    text = [[]]
}
controls[#controls+1] = {
    type = "description",
    title = "",
    text = [[|c03e3fc|t32:32:/esoui/art/miscellaneous/eso_icon_warning.dds|t With WritWorthy installed, this bank feature will not activate when you are auto-withdrawing writ quest items]],
    reference = "ARS_WritCreaterWarningLabel"
}
controls[#controls+1] = {
    type = 'checkbox',
    name = "Take scrolls needed from the bank and auto use?",
    getFunc = function()
        local auto_bank = DB.settings.auto_bank

        if WritCreater then
            ARS_WritCreaterWarningLabel:SetHidden(false)
        else
            ARS_WritCreaterWarningLabel:SetHidden(true)
        end

        return auto_bank
    end,
    setFunc = function(value)

        DB.settings.auto_bank = value

        if DB.settings.auto_bank then
            AddBankingEvents()
        else
            RemoveBankingEvents()
        end
    end,
    default = defaultSetting.auto_bank
}

local panelData = {
    type = 'panel',
    name = 'Auto Research Scrolls',
    author = '|c00a313Ghostbane',
    version = string.format('|c58c5ed|r', AutoResearchScrolls.version),
    website = 'https://www.esoui.com/downloads/info3659-AutoResearchScrolls.html'
}

-- --------------------
-- OnAddOnLoaded
-- --------------------
local function OnAddOnLoaded(eventCode, _addOnName)

	if _addOnName == addonName then

		DB = ZO_SavedVars:NewCharacterIdSettings('ARS_db', 1, GetWorldName(), db_defaults, nil)
		EVENT_MANAGER:UnregisterForEvent(addonName, eventCode)
		EVENT_MANAGER:RegisterForEvent(addonName, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

        -- Build settings
        local LAM2 = LibAddonMenu2
        LAM2:RegisterAddonPanel('AutoResearchScrollsOptions', panelData)
        LAM2:RegisterOptionControls('AutoResearchScrollsOptions', controls)

        if DB.settings.auto_bank then
            AddBankingEvents()
        end
	end

end

-- --------------------
-- Attach Listeners
-- --------------------
EVENT_MANAGER:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(addonName, EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED, UpdateActiveResearchLines)
EVENT_MANAGER:RegisterForEvent(addonName, EVENT_SMITHING_TRAIT_RESEARCH_STARTED, OnResearchStarted)
EVENT_MANAGER:RegisterForEvent(addonName, EVENT_SMITHING_TRAIT_RESEARCH_TIMES_UPDATED, UpdateActiveResearchLines)
EVENT_MANAGER:RegisterForEvent(addonName, EVENT_SKILLS_FULL_UPDATE, UpdateActiveResearchLines)
EVENT_MANAGER:RegisterForEvent(addonName, EVENT_END_FAST_TRAVEL_INTERACTION, Boot)