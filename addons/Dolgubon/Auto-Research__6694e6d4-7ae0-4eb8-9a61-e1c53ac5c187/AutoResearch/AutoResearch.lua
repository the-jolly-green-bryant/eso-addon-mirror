-- Bag scan options
AUTORESEARCH_BAG_BACKPACK = 1
AUTORESEARCH_BAG_BANK = 2
AUTORESEARCH_BAG_BOTH = 3

-- All/None/Select
AUTORESEARCH_ENABLE_NONE = 0
AUTORESEARCH_ENABLE_ALL = 1
AUTORESEARCH_ENABLE_SELECTED = 2

AutoResearch = {
    name = "AutoResearch",
    title = "Auto Research",
    version = "3.0.6",
    author = "silvereyes",
    
    -- Global details about armor, weapon TraitType value ranges.
    traitConfig = {
        armor = {
            name = SI_ITEMTYPE45,
            types = {
                [1] = {
                    min = 11,
                    max = 18,
                  },
                [2] = {
                    min = 25,
                    max = 25,
                  }
            },
        },
        weapons = {
            name = SI_ITEMTYPE46,
            types = {
                [1] = {
                    min = 1,
                    max = 8,
                  },
                [2] = {
                    min = 26,
                    max = 26,
                  }
            },
        },
        jewelry = {
            name = SI_ITEMTYPE66,
            types = {
                [1] = {
                    min = 21,
                    max = 23,
                  },
                [2] = {
                    min = 28,
                    max = 33,
                  }
            },
        },
    },
    -- Option panel defaults
    defaults = {
        bags = AUTORESEARCH_BAG_BOTH,
        maxQuality = {
            [CRAFTING_TYPE_BLACKSMITHING]   = ITEM_FUNCTIONAL_QUALITY_ARCANE,
            [CRAFTING_TYPE_CLOTHIER]        = ITEM_FUNCTIONAL_QUALITY_ARCANE,
            [CRAFTING_TYPE_WOODWORKING]     = ITEM_FUNCTIONAL_QUALITY_ARCANE,
            [CRAFTING_TYPE_JEWELRYCRAFTING] = ITEM_FUNCTIONAL_QUALITY_ARCANE,
        },
        traitResearchOrder = {
            ["weapons"] = {
                ITEM_TRAIT_TYPE_WEAPON_INFUSED,
                ITEM_TRAIT_TYPE_WEAPON_SHARPENED,
                ITEM_TRAIT_TYPE_WEAPON_NIRNHONED,
                ITEM_TRAIT_TYPE_WEAPON_PRECISE,
                ITEM_TRAIT_TYPE_WEAPON_DECISIVE,
                ITEM_TRAIT_TYPE_WEAPON_CHARGED,
                ITEM_TRAIT_TYPE_WEAPON_DEFENDING,
                ITEM_TRAIT_TYPE_WEAPON_TRAINING,
                ITEM_TRAIT_TYPE_WEAPON_POWERED,
            },
            ["armor"] = {
                ITEM_TRAIT_TYPE_ARMOR_DIVINES,
                ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE,
                ITEM_TRAIT_TYPE_ARMOR_INFUSED,
                ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED,
                ITEM_TRAIT_TYPE_ARMOR_STURDY,
                ITEM_TRAIT_TYPE_ARMOR_NIRNHONED,
                ITEM_TRAIT_TYPE_ARMOR_REINFORCED,
                ITEM_TRAIT_TYPE_ARMOR_TRAINING,
                ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS,
            },
            ["jewelry"] = {
                ITEM_TRAIT_TYPE_JEWELRY_ARCANE,
                ITEM_TRAIT_TYPE_JEWELRY_ROBUST,
                ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY,
                ITEM_TRAIT_TYPE_JEWELRY_TRIUNE,
                ITEM_TRAIT_TYPE_JEWELRY_SWIFT,
                ITEM_TRAIT_TYPE_JEWELRY_INFUSED,
                ITEM_TRAIT_TYPE_JEWELRY_HEALTHY,
                ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE,
                ITEM_TRAIT_TYPE_JEWELRY_HARMONY,
            },
        },
        styles = {
          [1]   = true,
          [2]   = true,
          [3]   = true,
          [4]       = true,
          [5]     = true,
          [6]   = true,
          [7]    = true,
          [8]        = true,
          [9]   = true,
          [34]   = true, -- IMPERIAL
          [15]  = true, -- ANCIENT ELF
          [17]        = true, -- REACH
          [19]   = true, -- PRIMITIVE
        },
        stylesEnabled = AUTORESEARCH_ENABLE_SELECTED,
        sets = {},
        setsEnabled = {
            isMonster = AUTORESEARCH_ENABLE_SELECTED,
            isDungeon = AUTORESEARCH_ENABLE_SELECTED,
            isCrafted = AUTORESEARCH_ENABLE_SELECTED,
            isOverland = AUTORESEARCH_ENABLE_SELECTED,
        },
        chatColor = { 1, 1, 1, 1 },
        shortPrefix = true,
        chatUseSystemColor = true,
        chatContainerOpen = true,
        chatContentsSummary = true,
    },
    -- Class definition namespace
    classes = {},
    -- Information about supported craft stations
    craftSkills = {
        [CRAFTING_TYPE_BLACKSMITHING]   = { },
        [CRAFTING_TYPE_CLOTHIER]        = { },
        [CRAFTING_TYPE_WOODWORKING]     = { },
        [CRAFTING_TYPE_JEWELRYCRAFTING] = { },
    },
    styledCategories = {
        [ITEM_TRAIT_TYPE_CATEGORY_ARMOR]  = true,
        [ITEM_TRAIT_TYPE_CATEGORY_WEAPON] = true,
    },
    invalidStyles = {
        [0]      = true, -- No style
        [36] = true, -- Crown Mimic Stone / Universal style
    },
    noneAllSelectChoices = {
        GetString(SI_CRAFTING_INVALID_ITEM_STYLE), -- None
        GetString(SI_ITEMFILTERTYPE0), -- All
        GetString(SI_GAMEPAD_SELECT_OPTION), -- Select
    },
    noneAllSelectChoicesValues = {
        AUTORESEARCH_ENABLE_NONE,
        AUTORESEARCH_ENABLE_ALL,
        AUTORESEARCH_ENABLE_SELECTED
    },
    allSelectChoices = {
        GetString(SI_ITEMFILTERTYPE0), -- All
        GetString(SI_GAMEPAD_SELECT_OPTION), -- Select
    },
    allSelectChoicesValues = {
        AUTORESEARCH_ENABLE_ALL,
        AUTORESEARCH_ENABLE_SELECTED
    },
    -- debugMode = GetDisplayName() == "@Dolgubon",
    debugMode = false,
}
local addon = AutoResearch




--[[ Outputs a colorized message to chat with the Auto Research prefix ]]--
function addon:Print(input)
    local output = self.prefix .. input .. self.suffix
    d(output)
end
function addon:Debug(input)
    if not self.debugMode then return end
    self:Print(input)
end

--[[ Stops supressing extraction errors ]]--
local function StopResearching()
    local self = addon
    self.researchState = "stopped"
    self:Debug("self.researchState = "..tostring(self.researchState))
end

--[[ Stops UI error thrown on third slot researched due to some extract animation ]]--
local origErrorFrame
local function OnUIError(errorFrame, errorString)
    if errorString and string.find(errorString, "CraftingSmithingExtractSlotAnimation") then
        return
    end
    return origErrorFrame(errorFrame, errorString)
end
local function UnregisterEvents()
    local self = addon
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_CRAFT_COMPLETED)
    if not self.bagIds then
        return
    end
    for _, bagId in ipairs(self.bagIds) do
        local eventScope = self.name .. "_Bag" .. tostring(bagId)
        EVENT_MANAGER:UnregisterForEvent(eventScope, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    end
    self.bagIds = nil
end

local function EndInteraction()
    local self = addon
    UnregisterEvents()
    self.researchState = nil
    self:Debug("self.researchState = "..tostring(self.researchState))
end

--[[ Ends the auto-research process and starts up Dolgubon's Lazy Writ Crafter, if enabled ]]--
local function TryWritCreator(craftSkill)
    local self = addon
    UnregisterEvents()
    -- Small delay to prevent last extraction failed message
    self.researchState = "stopping"
    self:Debug("self.researchState = "..tostring(self.researchState))
    zo_callLater(StopResearching, 500)
    
    if WritCreater then 
        if WritCreater.craftCompleteHandler then
            EVENT_MANAGER:RegisterForEvent(WritCreater.name, EVENT_CRAFT_COMPLETED, 
                                           WritCreater.craftCompleteHandler)
            
            self:Debug("Calling WritCreater.craftCheck(1, "..tostring(craftSkill)..")")
            WritCreater.craftCheck(1, craftSkill)
        else
            d("Old version of Dolgubon's Lazy Writ Crafter detected. Please update your addons.")
        end
	end
    if LibLazyCrafting and LibLazyCrafting.craftInteract then
        self:Debug("Calling LibLazyCrafting.craftInteract(1, "..tostring(craftSkill)..")")
        LibLazyCrafting.craftInteract(1, craftSkill)
    end
end

--[[ Workaround for the base game bug with the third research slot not starting research. ]]--
local function ResearchItemTimeout(craftSkill)
    return function()
        local self = addon
        self:Debug("ResearchItemTimeout("..tostring(craftSkill)..")")
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, SI_AUTORESEARCH_ERROR)
        TryWritCreator(craftSkill)
    end
end

--[[ Starts research on a specific slot ]]--
local function ResearchItem(craftSkill, bagId, slotIndex)

    local self = addon
    -- Print out auto-research message to chat
    local itemLink = GetItemLink(bagId, slotIndex)
    local traitType = GetItemLinkTraitInfo(itemLink)
    local traitName = GetString("SI_ITEMTRAITTYPE", traitType)
    local message = zo_strformat("<<1>> <<2>> (<<3>><<4>><<5>>)", 
        GetString(SI_GAMEPAD_SMITHING_CURRENT_RESEARCH_HEADER),
        itemLink, 
        self.suffix,
        traitName,
        self.startColor)
    self:Print(message)
    
    -- If research doesn't start in 1.5 seconds, then time out and end auto-research
    if not self.debugMode then
        EVENT_MANAGER:RegisterForUpdate(self.name .. ".ResearchItemTimeout", 1500, ResearchItemTimeout(craftSkill))
        -- Perform the research
        ResearchSmithingTrait( bagId, slotIndex )
    end
    self:Debug("--------")
    self:Debug("Researching "..GetItemLink(bagId, slotIndex))
end

--[[ Selects the highest priority researchable item from the items cache and starts research.
     If all research slots are full, or if there are no researchable items in the cache, then
     tries running Lazy Writ Crafter ]] --
local function ResearchNext(craftSkill)

    local self = addon

    -- Check for full research slots
    if self.queue:AreResearchSlotsFull() then
        self:Debug("Research slots are all full. Try Writ Creator next.")
		    TryWritCreator(craftSkill)
        return
    end
    
    -- Start research on the next item from the cache
    local nextItem = self.queue:GetNext()
    if nextItem then
        ResearchItem(craftSkill, nextItem.bagId, nextItem.slotIndex)
        return
    end
    
    -- No researchable items found in the cache.  Start up Lazy Writ Crafter.
    TryWritCreator(craftSkill)
end

--[[ Event handler for when research starts on an item ]]--
local function OnCraftCompleted(eventCode, craftSkill)
    
    local self = addon
    
    -- Stop waiting for timeout
    EVENT_MANAGER:UnregisterForUpdate(self.name .. ".ResearchItemTimeout")
    
    self:Debug("OnCraftCompleted("..tostring(eventCode)..", "..tostring(craftSkill)..")")
    
    -- Start researching the highest priority item from the cache
    ResearchNext(craftSkill)
end

--[[ Event handler for when an existing item in a research bag is changed ]]--
local function OnInventorySingleSlotUpdated(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
    local self = addon
    -- if the stack size decreases, assume a decon event and 
    if stackCountChange < 0 then
        self.queue:Remove(bagId, slotIndex)
    end
end

local OnSmithingTraitResearchCanceled

--[[ Runs whenever a research station is first opened ]]--
local function Start(eventCode, craftSkill, sameStation)
    local self = addon
    
    self:Debug("Start("..tostring(eventCode)..","..tostring(craftSkill)..","..tostring(sameStation)..")")
    if self.researchState then
        self:Debug("Exiting Start()...")
        return
    end

    -- Filter out any non-researchable craft skill lines
    local craftSkillInfo = self.craftSkills[craftSkill]
    if not craftSkillInfo or not self.settings.enabled[craftSkill] then
        TryWritCreator(craftSkill)
        return
    end
    
    
    -- Instantiate link parser
    if not craftSkillInfo.linkParser then
        craftSkillInfo.linkParser = self.classes.LinkParser:New(craftSkill)
    end
    
    -- Initialize the items cache to detect whether all research slots are full
    self.queue = self.classes.ResearchQueue:New(craftSkill)
    
    -- Workaround for ZOS bug that allowed a research timer on a known trait
    if self.queue.invalidResearchTrait then
        
        self:Debug("Invalid research trait found. Canceling...")
        EVENT_MANAGER:RegisterForEvent(self.name, EVENT_SMITHING_TRAIT_RESEARCH_CANCELED, 
                                       OnSmithingTraitResearchCanceled)
        CancelSmithingTraitResearch(craftSkill,
                                    self.queue.invalidResearchTrait.researchLineIndex,
                                    self.queue.invalidResearchTrait.traitIndex)
        return
    end
    if self.queue:AreResearchSlotsFull() then
        self:Debug("All research slots are full")
        TryWritCreator(craftSkill)
        return
    end
    
    self.researchState = "started"
    self:Debug("self.researchState = "..tostring(self.researchState))
    
    -- Select which bags will be scanned for researchable items based on user configuration
    local bagIds
    local settingsBags = self.settings.bags
    if settingsBags == AUTORESEARCH_BAG_BOTH then
        bagIds = { BAG_BACKPACK, BAG_BANK, BAG_SUBSCRIBER_BANK }
    elseif settingsBags == AUTORESEARCH_BAG_BACKPACK then
        bagIds = { BAG_BACKPACK }
    else
        bagIds = { BAG_BANK, BAG_SUBSCRIBER_BANK }
    end
    self.bagIds = bagIds
    
    -- Scan the bags for researchable items
    self.queue:Fill(bagIds)
    
    -- Cover Lazy Writ Crafter's ears and hum for a little bit
    if WritCreater then
        EVENT_MANAGER:UnregisterForEvent(WritCreater.name, EVENT_CRAFT_COMPLETED)
    end
    
    -- Listen for the research started event
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CRAFT_COMPLETED, 
                                   OnCraftCompleted)
    
    -- Listen for inventory updates to the researchable bags, so we can remove any deconned items from the queue
    for _, bagId in ipairs(bagIds) do
        local eventScope = self.name .. "_Bag" .. tostring(bagId)
        EVENT_MANAGER:RegisterForEvent(eventScope, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventorySingleSlotUpdated)
        EVENT_MANAGER:AddFilterForEvent(eventScope, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
        EVENT_MANAGER:AddFilterForEvent(eventScope, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_IS_NEW_ITEM, false)
        EVENT_MANAGER:AddFilterForEvent(eventScope, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, bagId)
    end
    
    -- Start researching the highest priority item from the cache
    ResearchNext(craftSkill)
end

-- Update 15+ only; if a known trait that has an active research counter was found and canceled,
-- then restart the research process.
OnSmithingTraitResearchCanceled = function(craftSkill, researchLineIndex, traitIndex)
    
    local self = addon
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_SMITHING_TRAIT_RESEARCH_CANCELED)
    if not self.queue or not self.queue.invalidResearchTrait then
        return
    end
    if self.queue 
       and self.queue.invalidResearchTrait
       and self.queue.invalidResearchTrait.researchLineIndex == researchLineIndex
       and self.queue.invalidResearchTrait.traitIndex == traitIndex
    then
        self:Debug("Research successfully canceled. Starting over...")
        Start(nil, craftSkill)
    end
end

--[[ Whenever self.researchState is set, suppresses extraction errors ]]--
local function OnAlertNoSuppression(category, soundId, message)
    local self = addon
    -- When auto-researching on the default craft station tab (extraction), extraction errors get
    -- raised by the game client.  Suppress them below.
    -- TODO: perhaps switch to the research tab automatically before starting auto research.
    if not self.researchState or self.researchState == "stopped" or category ~= UI_ALERT_CATEGORY_ALERT then
        return
    end
    if message == SI_SMITHING_EXTRACTION_FAILED
    then
        return true
    end
end

local function AddContextMenu(inventorySlot, slotActions)
    local self = addon
    local itemLink = inventorySlot.itemLink
    if not itemLink then
        local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
        if not bagId then
            return
        end
        itemLink = GetItemLink(bagId, slotIndex)
    end
    local itemType = GetItemLinkItemType(itemLink)
    if itemType ~= ITEMTYPE_ARMOR and itemType ~= ITEMTYPE_WEAPON then return end
    local subMenu = {}
    local equipType = GetItemLinkEquipType(itemLink)
    if equipType ~= EQUIP_TYPE_NECK and equipType ~= EQUIP_TYPE_RING and self.settings.stylesEnabled == AUTORESEARCH_ENABLE_SELECTED then
        local itemStyle = GetItemLinkItemStyle(itemLink)
        if self.invalidStyles[itemStyle] then return end
        local itemStyleName = GetItemStyleName(itemStyle)
        local toggleStyle = function() self.settings.styles[itemStyle] = not self.settings.styles[itemStyle] end
        table.insert(subMenu, {
            label = "  " .. zo_strformat(GetString(SI_INVENTORY_TRAIT_STATUS_TOOLTIP),
                                 GetString(SI_AUTORESEARCH_STYLES),
                                 tostring(itemStyleName)),
            callback = toggleStyle,
            checked = function() return self.settings.styles[itemStyle] end,
            itemType = MENU_ADD_OPTION_CHECKBOX,
        })
    end
    if LibSets and self.settings.sets then
        local hasSet, setName, _, _, _, setId = GetItemLinkSetInfo(itemLink)
        if hasSet then
            local libSetsType = LibSets.GetSetType(setId)
            local setType = self.setTypeMap[libSetsType]
            local setsEnabled = setType ~= nil and self.settings.setsEnabled[setType] or AUTORESEARCH_ENABLE_NONE
            if setsEnabled == AUTORESEARCH_ENABLE_SELECTED then
                local toggleSet = function() self.settings.sets[setId] = not self.settings.sets[setId] end
                table.insert(subMenu, {
                    label = "  " .. zo_strformat(GetString(SI_INVENTORY_TRAIT_STATUS_TOOLTIP),
                                         GetString(SI_AUTORESEARCH_SETS),
                                         tostring(setName)),
                    callback = toggleSet,
                    checked = function() return self.settings.sets[setId] end,
                    itemType = MENU_ADD_OPTION_CHECKBOX,
                })
            end
        end
    end
    if #subMenu > 0 then
        AddCustomSubMenuItem(self.title, subMenu)
    end
end

local function SetupContextMenu()
    if not IsConsoleUI() then
        local menu = LibCustomMenu or LibStub("LibCustomMenu")
        menu:RegisterContextMenu(AddContextMenu, menu.CATEGORY_LATE)
    end
end

--[[ Runs once upon login or /reloadui for every addon that is loaded ]]--
local function OnAddonLoaded(event, name)

    local self = addon
    
    -- Only run when this addon is loaded
    if name ~= self.name then return end
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
    
    -- Procrastinate our writ laziness until after done researching
    if WritCreater then
        EVENT_MANAGER:UnregisterForEvent(WritCreater.name, EVENT_CRAFTING_STATION_INTERACT)
    end
    if LibLazyCrafting then
        EVENT_MANAGER:UnregisterForEvent("LibLazyCrafting", EVENT_CRAFTING_STATION_INTERACT)
    end
    
    -- Wire up event handlers
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CRAFTING_STATION_INTERACT, Start)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_END_CRAFTING_STATION_INTERACT, EndInteraction)
    
    -- Wire up extraction error suppressions
    ZO_PreHook("ZO_AlertNoSuppression", OnAlertNoSuppression)
    origErrorFrame = ZO_ERROR_FRAME.OnUIError
    ZO_ERROR_FRAME.OnUIError = OnUIError
    
    -- Set up settings menu.  See Settings.lua.
    self:SetupOptions()
    
    SetupContextMenu()
end

-- Wire up addon loaded event
EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)