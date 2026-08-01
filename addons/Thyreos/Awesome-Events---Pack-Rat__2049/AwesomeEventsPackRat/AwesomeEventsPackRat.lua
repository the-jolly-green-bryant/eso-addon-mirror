--[[
  This file is part of Awesome Events.

  Author: Thyreos
  Filename: AwesomeEventsPackRat.lua
  Last Modified: July 1, 2018

  License : CreativeCommons CC BY-NC-SA 4.0 Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

  Please read the README file for further information.
  ]]

local libAM = LibStub('LibAwesomeModule-1.0')
local MOD = libAM:New('packrat')

-- title: header in settings menu
MOD.title = GetString(SI_AWEMOD_PACKRAT)
-- hint: tootltip at module show/hide toggle in settings menu
MOD.hint = GetString(SI_AWEMOD_PACKRAT_HINT)
-- order: default in the middle order = 40, at bottom ORDER_AWESOME_MODULE_PUSH_NOTIFICATION = 75
MOD.order = ORDER_AWESOME_MODULE_PUSH_NOTIFICATION
-- enable debugging ingame via /aedebug packrat on
-- disable debugging ingame via /aedebug packrat off
-- show debugging state ingame via /aedebug packrat
MOD.debug = false

local LABEL_LOW = 1
local LABEL_MAPS = 2
local LABEL_INTRICATES = 3
local LABEL_GLYPHS = 4
local LABEL_RECIPES = 5
local LABEL_FURNISHINGS = 6
local LABEL_STOLEN = 7
local LABEL_FISH = 8
local LABEL_JUNK = 9
local LABEL_CONTAINERS = 10
local LABEL_FCO_DECON = 11
local LABEL_FCO_GUILDSTORE =12

MOD.label = {
    [LABEL_LOW] = {},
    [LABEL_JUNK] = {},
    [LABEL_STOLEN] = {},
    [LABEL_FISH] = {},
    [LABEL_CONTAINERS] = {},
    [LABEL_INTRICATES] = {},
    [LABEL_MAPS] = {},
    [LABEL_GLYPHS] = {},
    [LABEL_RECIPES] = {},
    [LABEL_FURNISHINGS] = {},
    [LABEL_FCO_DECON] = {},
    [LABEL_FCO_GUILDSTORE] = {},
}

-- USER SETTINGS

MOD.options = {
    showLow = {
        type = 'checkbox',
        name = GetString(SI_AWEMOD_PACKRAT_LOW),
        tooltip = GetString(SI_AWEMOD_PACKRAT_LOW_HINT),
        default = true,
        order = 1,
    },
    valueLowInfo = {
        type = 'slider',
        name = GetString(SI_AWEMOD_PACKRAT_LOW_INFO),
        tooltip = GetString(SI_AWEMOD_PACKRAT_LOW_INFO_HINT),
        min  = 1,
        max = 60,
        default = 20,
        order = 2,
    },
    valueLowWarning = {
        type = 'slider',
        name = GetString(SI_AWEMOD_PACKRAT_LOW_WARNING),
        tooltip = GetString(SI_AWEMOD_PACKRAT_LOW_WARNING_HINT),
        min  = 1,
        max = 40,
        default = 10,
        order = 3,
    },
    showContainers = {
        type = 'checkbox',
        name = GetString(SI_AWEMOD_PACKRAT_CONTAINERS),
        tooltip = GetString(SI_AWEMOD_PACKRAT_CONTAINERS_HINT),
        default = true,
        order = 4,
    },
    showFish = {
        type = 'checkbox',
        name = GetString(SI_AWEMOD_PACKRAT_FISH),
        tooltip = GetString(SI_AWEMOD_PACKRAT_FISH_HINT),
        default = true,
        order = 5,
    },
    showGlyphs = {
        type = 'checkbox',
        name = GetString(SI_AWEMOD_PACKRAT_GLYPHS),
        tooltip = GetString(SI_AWEMOD_PACKRAT_GLYPHS_HINT),
        default = true,
        order = 6,
    },
    showFurnishings = {
        type = 'checkbox',
        name = GetString(SI_AWEMOD_PACKRAT_FURNISHINGS),
        tooltip = GetString(SI_AWEMOD_PACKRAT_FURNISHINGS_HINT),
        default = true,
        order = 7,
    },
    showIntricates = {
        type = 'checkbox',
        name = GetString(SI_AWEMOD_PACKRAT_INTRICATES),
        tooltip = GetString(SI_AWEMOD_PACKRAT_INTRICATES_HINT),
        default = true,
        order = 8,
    },
    showJunk = {
        type = 'checkbox',
        name = GetString(SI_AWEMOD_PACKRAT_JUNK),
        tooltip = GetString(SI_AWEMOD_PACKRAT_JUNK_HINT),
        default = true,
        order = 9,
    },
    showMaps = {
        type = 'checkbox',
        name = GetString(SI_AWEMOD_PACKRAT_MAPS),
        tooltip = GetString(SI_AWEMOD_PACKRAT_MAPS_HINT),
        default = true,
        order = 10,
    },
    showRecipes = {
        type = 'checkbox',
        name = GetString(SI_AWEMOD_PACKRAT_RECIPES),
        tooltip = GetString(SI_AWEMOD_PACKRAT_RECIPES_HINT),
        default = true,
        order = 11,
    },
    showStolen = {
        type = 'checkbox',
        name = GetString(SI_AWEMOD_PACKRAT_STOLEN),
        tooltip = GetString(SI_AWEMOD_PACKRAT_STOLEN_HINT),
        default = true,
        order = 12,
    },
    showFCODecon = {
        type = 'checkbox',
        name = GetString(SI_AWEMOD_PACKRAT_FCO_DECON),
        tooltip = GetString(SI_AWEMOD_PACKRAT_HINT_FCO_DECON),
        default = false,
        order = 13,
    },
    showFCODGuildstore = {
        type = 'checkbox',
        name = GetString(SI_AWEMOD_PACKRAT_FCO_GUILDSTORE),
        tooltip = GetString(SI_AWEMOD_PACKRAT_HINT_FCO_GUILDSTORE),
        default = false,
        order = 14,
    },
}

-- fontSize: default = 1, max = 5
MOD.fontSize = 1

-- OVERRIDES

function MOD:Enable(options)
    self:d('Enable')
    self.data = {
        suspendScanning = false,
        scanPending = false,
        lastScanTime = 0,
        numUsedSlots = 0,
        numFreeSlots = 0,
        numSlots = 0,
        numJunk = 0,
        numJunkStacks = 0,
        numStolen = 0,
        numStolenStacks = 0,
        numFish = 0,
        numFishStacks = 0,
        numContainers = 0,
        numIntricates = 0,
        numIntricatesBS = 0,
        numIntricatesCR = 0,
        numIntricatesJC = 0,
        numIntricatesWW = 0,
        numGlyphStacks = 0,
        numMaps = 0,
        mapName = '',
        numRecipes = 0,
        numRecipesUnknown = 0,
        numFurnishings = 0,
        numFCODecon = 0,
        numFCODeconBS = 0,
        numFCODeconCR = 0,
        numFCODeconJC = 0,
        numFCODeconWW = 0,
        numFCOGuildstoreStacks = 0,
    }

    self.FCOISReady = false
    if FCOIS then
        if FCOIS.addonVars.gPlayerActivated then
            self:d('Found FCO ItemSaver!')
            self.FCOISReady = true
        end
    end

    self:OnUpdateBag(BAG_BANK,0)
    self:ScanInventory()
    self.dataUpdated = true
end

function MOD:Set(key,value)
    self:d('Set[' .. key .. '] ', value)

    local doScan = false

    if(key=='showLow')then
        if(value)then
            self:OnUpdateBag(BAG_BANK,0)
        else
            self.label[LABEL_LOW]:SetText('')
        end
    else
        self:OnUpdateBag(BAG_BANK,0)
    end

    if(key=='showJunk')then
        if(value)then
            --self:ScanInventory()
            doScan = true
        else
            self.label[LABEL_JUNK]:SetText('')
        end
    end

    if(key=='showStolen')then
        if(value)then
            --self:ScanInventory()
            doScan = true
        else
            self.label[LABEL_STOLEN]:SetText('')
        end
    end

    if(key=='showFish')then
        if(value)then
            --self:ScanInventory()
            doScan = true
        else
            self.label[LABEL_FISH]:SetText('')
        end
    end

    if(key=='showContainers')then
        if(value)then
            --self:ScanInventory()
            doScan = true
        else
            self.label[LABEL_CONTAINERS]:SetText('')
        end
    end

    if(key=='showIntricates')then
        if(value)then
            --self:ScanInventory()
            doScan = true
        else
            self.label[LABEL_INTRICATES]:SetText('')
        end
    end

    if(key=='showGlyphs')then
        if(value)then
            --self:ScanInventory()
            doScan = true
        else
            self.label[LABEL_GLYPHS]:SetText('')
        end
    end

    if(key=='showMaps')then
        if(value)then
            --self:ScanInventory()
            doScan = true
        else
            self.label[LABEL_MAPS]:SetText('')
        end
    end

    if(key=='showRecipes')then
        if(value)then
            --self:ScanInventory()
            doScan = true
        else
            self.label[LABEL_RECIPES]:SetText('')
        end
    end

    if(key=='showFurnishings')then
        if(value)then
            --self:ScanInventory()
            doScan = true
        else
            self.label[LABEL_FURNISHINGS]:SetText('')
        end
    end

    if(key=='showFCODecon')then
        if(value)then
            --self:ScanInventory()
            doScan = true
        else
            self.label[LABEL_FCO_DECON]:SetText('')
        end
    end

    if(key=='showFCODGuildstore')then
        if(value)then
            --self:ScanInventory()
            doScan = true
        else
            self.label[LABEL_FCO_GUILDSTORE]:SetText('')
        end
    end

    if doScan then
        self:ScanInventory()
    end
    self.dataUpdated = true
end

-- EVENT LISTENER
function MOD:GetEventListeners()
    return {
        {
            eventCode = EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
            callback = function(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
                if(bagId == BAG_BANK) then
                    self:OnUpdateBag(bagId,stackCountChange)
                end
                if(bagId == BAG_BACKPACK) then
                    self:OnUpdateBackpack(bagId, slotId, isNewItem)
                end
            end
        },
        {
            eventCode = EVENT_RETICLE_HIDDEN_UPDATE, -- this should catch FCOIS marking and un-marking
            callback = function(eventCode, hidden)
                if (not hidden) then
                    self:ScanInventory()
                end
            end
        },
        {
            eventCode = EVENT_INVENTORY_BANK_CAPACITY_CHANGED,
            callback = function(eventCode, previousCapacity, currentCapacity, previousUpgrade, currentUpgrade)
                self:d("EVENT_INVENTORY_BANK_CAPACITY_CHANGED: ", previousCapacity .. '=>' .. currentCapacity, previousUpgrade .. '=>' .. currentUpgrade)
                self:OnUpdateBag(BAG_BANK,previousCapacity-currentCapacity)
            end
        },
    }
end

-- EVENT HANDLER

function MOD:OnUpdateBag(bagId,stackCountChange)
    local predicted = self.data.numFreeSlots - stackCountChange
    local numFreeSlots, numUsedSlots, numSlots = GetNumBagFreeSlots(bagId),GetNumBagUsedSlots(bagId),GetBagSize(bagId)
    -- eso+ bank fix
    if(bagId==BAG_BANK and IsESOPlusSubscriber())then
        numFreeSlots = numFreeSlots + GetNumBagFreeSlots(BAG_SUBSCRIBER_BANK)
        numUsedSlots = numUsedSlots + GetNumBagUsedSlots(BAG_SUBSCRIBER_BANK)
        numSlots = numSlots + GetBagSize(BAG_SUBSCRIBER_BANK)
    end

    if( numFreeSlots ~= self.data.numFreeSlots or numSlots ~= self.data.numSlots) then
        self.data.numSlots = numSlots
        self.data.numUsedSlots = numUsedSlots
        self.data.numFreeSlots = numFreeSlots
        self.dataUpdated = true
        if(predicted ~= self.data.numFreeSlots)then
            self:d(' => dataUpdated('..bagId..') Pred.: ' .. predicted .. ' / Act.:' .. self.data.numFreeSlots)
        else
            self:d(' => dataUpdated('..bagId..')')
        end
    end
end -- MOD:OnUpdateBag


function MOD:OnUpdateBackpack(bagId, slotId, isNewItem)
    self:ScanInventory()
end

-- LABEL HANDLER

function MOD:Update(options)
    self:d('Update')

    local labelText = ''   

    -- bank space 
    if(options.showLow)then
        if (self.data.numFreeSlots <= options.valueLowInfo) then
            if (self.data.numFreeSlots <= options.valueLowWarning) then
                labelText = MOD.Colorize(COLOR_AWEVS_WARNING, zo_strformat(SI_AWEMOD_PACKRAT_LOW_LABEL, self.data.numFreeSlots))
            else
                labelText = MOD.Colorize(COLOR_AWEVS_HINT, zo_strformat(SI_AWEMOD_PACKRAT_LOW_LABEL, self.data.numFreeSlots))
            end
        end
        self.label[LABEL_LOW]:SetText(labelText)
    end

--[[
MOD.Colorize(COLOR_AWEVS_AVAILABLE, 
MOD.Colorize(COLOR_AWEVS_HINT, 
MOD.Colorize(COLOR_AWEVS_WARNING, 
]]

    -- junk
    if(options.showJunk)then
        if (self.data.numJunk > 0) then
            labelText = MOD.Colorize(COLOR_AWEVS_HINT, zo_strformat(SI_AWEMOD_PACKRAT_JUNK_LABEL, self.data.numJunkStacks))
        else
            labelText = ''
        end
        self.label[LABEL_JUNK]:SetText(labelText)
    end

    -- stolen
    if(options.showStolen)then
        if (self.data.numStolen > 0) then
            labelText = zo_strformat(SI_AWEMOD_PACKRAT_STOLEN_LABEL, MOD.GetColorStr(COLOR_AWEVS_WARNING), self.data.numStolen, self.data.numStolenStacks)
        else
            labelText = ''
        end
        self.label[LABEL_STOLEN]:SetText(labelText)
    end

    -- fish
    if(options.showFish)then
        if (self.data.numFish > 0) then
            --labelText = MOD.Colorize(COLOR_AWEVS_HINT, zo_strformat(SI_AWEMOD_PACKRAT_FISH_LABEL, self.data.numFish, self.data.numFishStacks))
            labelText = zo_strformat(SI_AWEMOD_PACKRAT_FISH_LABEL, MOD.GetColorStr(COLOR_AWEVS_HINT),self.data.numFish, self.data.numFishStacks)
        else
            labelText = ''
        end
        self.label[LABEL_FISH]:SetText(labelText)
    end

    -- containers
    if(options.showContainers)then
        if (self.data.numContainers > 0) then
            labelText = MOD.Colorize(COLOR_AWEVS_HINT, zo_strformat(SI_AWEMOD_PACKRAT_CONTAINERS_LABEL, self.data.numContainers))
        else
            labelText = ''
        end
        self.label[LABEL_CONTAINERS]:SetText(labelText)
    end

    -- intricates
    if(options.showIntricates)then
        if (self.data.numIntricates > 0) then
            --labelText = MOD.Colorize(COLOR_AWEVS_AVAILABLE, zo_strformat(SI_AWEMOD_PACKRAT_INTRICATES_LABEL, self.data.numIntricates))
            --local iconSize = (MOD.fontSize-1)*3 + 24 -- 1:24, 5:36 -- but, doesn't seem to be updated dynamically
            local iconSize = 30
            local iconIntricate = zo_iconTextFormat("esoui/art/inventory/inventory_trait_intricate_icon.dds", iconSize, iconSize, " ")
            local totalTxt = zo_strformat("<<1>><<2>>", iconIntricate, self.data.numIntricates)
            local bsTxt, crTxt, jcTxt, wwTxt = ""
            if (self.data.numIntricatesBS > 0) then
                local iconBS = zo_iconTextFormat("esoui/art/inventory/inventory_tabicon_craftbag_blacksmithing_up.dds", iconSize, iconSize, " ")
                bsTxt = zo_strformat(" <<1>><<2>>", iconBS, self.data.numIntricatesBS)
            end
            if (self.data.numIntricatesCR > 0) then
                local iconCR = zo_iconTextFormat("esoui/art/inventory/inventory_tabicon_craftbag_clothing_up.dds", iconSize, iconSize, " ")
                crTxt = zo_strformat(" <<1>><<2>>", iconCR, self.data.numIntricatesCR)
            end
            if (self.data.numIntricatesJC > 0) then
                local iconJC = zo_iconTextFormat("esoui/art/inventory/inventory_tabicon_craftbag_jewelrycrafting_up.dds", iconSize, iconSize, " ")
                jcTxt = zo_strformat(" <<1>><<2>>", iconJC, self.data.numIntricatesJC)
            end
            if (self.data.numIntricatesWW > 0) then
                local iconWW = zo_iconTextFormat("esoui/art/inventory/inventory_tabicon_craftbag_woodworking_up.dds", iconSize, iconSize, " ")
                wwTxt = zo_strformat(" <<1>><<2>>", iconWW, self.data.numIntricatesWW)
            end
            --FCOIS.GetIconText(iconId)
            --local iconDeconstruct = zo_iconTextFormat("esoui/art/crafting/enchantment_tabicon_deconstruction_up.dds", iconSize, iconSize, " ")
            --labelText = MOD.Colorize({r=0.5,g=0.83,b=0.98}, zo_strformat(SI_AWEMOD_PACKRAT_INTRICATES_LABEL, self.data.numIntricates, bsTxt, crTxt, jcTxt, wwTxt))
            labelText = zo_strformat(SI_AWEMOD_PACKRAT_INTRICATES_LABEL, self.data.numIntricates, bsTxt, crTxt, jcTxt, wwTxt)
        else
            labelText = ''
        end
        self.label[LABEL_INTRICATES]:SetText(labelText)
    end

    -- glyphs
    if(options.showGlyphs)then
        if (self.data.numGlyphStacks > 0) then
            labelText = MOD.Colorize(COLOR_AWEVS_HINT, zo_strformat(SI_AWEMOD_PACKRAT_GLYPHS_LABEL, self.data.numGlyphStacks))
        else
            labelText = ''
        end
        self.label[LABEL_GLYPHS]:SetText(labelText)
    end

    -- maps
    if(options.showMaps)then
        if (self.data.numMaps > 0) then
            labelText = MOD.Colorize(COLOR_AWEVS_AVAILABLE, zo_strformat(SI_AWEMOD_PACKRAT_MAPS_LABEL, self.data.numMaps, self.data.mapName))
        else
            labelText = ''
        end
        self.label[LABEL_MAPS]:SetText(labelText)
    end

    -- recipes
    if(options.showRecipes)then
        if (self.data.numRecipes > 0) then
            --labelText = MOD.Colorize(COLOR_AWEVS_AVAILABLE, zo_strformat(SI_AWEMOD_PACKRAT_RECIPES_LABEL, self.data.numRecipes, self.data.numRecipesUnknown))
            labelText = zo_strformat(SI_AWEMOD_PACKRAT_RECIPES_LABEL, MOD.GetColorStr(COLOR_AWEVS_AVAILABLE), self.data.numRecipes, self.data.numRecipesUnknown)
        else
            labelText = ''
        end
        self.label[LABEL_RECIPES]:SetText(labelText)
    end

    -- furnishings
    if(options.showFurnishings)then
        if (self.data.numFurnishings > 0) then
            labelText = MOD.Colorize(COLOR_AWEVS_AVAILABLE, zo_strformat(SI_AWEMOD_PACKRAT_FURNISHINGS_LABEL, self.data.numFurnishings))
        else
            labelText = ''
        end
        self.label[LABEL_FURNISHINGS]:SetText(labelText)
    end

    -- FCOIS deconstruct
    if(options.showFCODecon)then
        -- give warning if enabled but not available
        if self.FCOISReady then
            if (self.data.numFCODecon > 0) then
                --labelText = MOD.Colorize(COLOR_AWEVS_AVAILABLE, zo_strformat(SI_AWEMOD_PACKRAT_LABEL_FCO_DECON, self.data.numFCODecon))
                --local iconSize = (MOD.fontSize-1)*3 + 24 -- 1:24, 5:36 -- but, doesn't seem to be updated dynamically
                local iconSize = 30
                local deconIconTxt = FCOIS.GetIconText(FCOIS_CON_ICON_DECONSTRUCTION)
                if deconIconTxt == nil then deconIconTxt = "esoui/art/crafting/enchantment_tabicon_deconstruction_up.dds" end
                local iconDecon = zo_iconTextFormat(deconIconTxt, iconSize, iconSize, " ")
                local totalTxt = zo_strformat("<<1>><<2>>", iconDecon, self.data.numFCODecon)
                local bsTxt, crTxt, jcTxt, wwTxt = ""
                if (self.data.numFCODeconBS > 0) then
                    local iconBS = zo_iconTextFormat("esoui/art/inventory/inventory_tabicon_craftbag_blacksmithing_up.dds", iconSize, iconSize, " ")
                    bsTxt = zo_strformat(" <<1>><<2>>", iconBS, self.data.numFCODeconBS)
                end
                if (self.data.numFCODeconCR > 0) then
                    local iconCR = zo_iconTextFormat("esoui/art/inventory/inventory_tabicon_craftbag_clothing_up.dds", iconSize, iconSize, " ")
                    crTxt = zo_strformat(" <<1>><<2>>", iconCR, self.data.numFCODeconCR)
                end
                if (self.data.numFCODeconJC > 0) then
                    local iconJC = zo_iconTextFormat("esoui/art/inventory/inventory_tabicon_craftbag_jewelrycrafting_up.dds", iconSize, iconSize, " ")
                    jcTxt = zo_strformat(" <<1>><<2>>", iconJC, self.data.numFCODeconJC)
                end
                if (self.data.numFCODeconWW > 0) then
                    local iconWW = zo_iconTextFormat("esoui/art/inventory/inventory_tabicon_craftbag_woodworking_up.dds", iconSize, iconSize, " ")
                    wwTxt = zo_strformat(" <<1>><<2>>", iconWW, self.data.numFCODeconWW)
                end
                --labelText = zo_strformat("<<1>><<2>><<3>><<4>><<5>>", totalTxt, bsTxt, crTxt, jcTxt, wwTxt)
                labelText = MOD.Colorize(COLOR_AWEVS_AVAILABLE, zo_strformat(SI_AWEMOD_PACKRAT_LABEL_FCO_DECON, self.data.numFCODecon, bsTxt, crTxt, jcTxt, wwTxt))
            else
                labelText = ''
            end
        else
            labelText = MOD.Colorize(COLOR_AWEVS_WARNING, zo_strformat(SI_AWEMOD_PACKRAT_FCO_MISSING))
        end
        self.label[LABEL_FCO_DECON]:SetText(labelText)
    end

    -- FCOIS guildstore
    if(options.showFCODGuildstore)then
        -- give warning if enabled but not available
        if self.FCOISReady then
            if (self.data.numFCOGuildstoreStacks > 0) then
                labelText = MOD.Colorize(COLOR_AWEVS_AVAILABLE, zo_strformat(SI_AWEMOD_PACKRAT_LABEL_FCO_GUILDSTORE, self.data.numFCOGuildstoreStacks))
            else
                labelText = ''
            end
        else
            labelText = MOD.Colorize(COLOR_AWEVS_WARNING, zo_strformat(SI_AWEMOD_PACKRAT_FCO_MISSING))
        end
        self.label[LABEL_FCO_GUILDSTORE]:SetText(labelText)

        --[[ would be great to show available listings, but trading house functions only seem to work at trading houses :P
        local guildIndex = 2
        local guildId, guildName = GetTradingHouseGuildDetails(guildIndex)
        self:d('TradingHouseDetails: id='..guildId..' name='..guildName)
        self:d('numguilds = '..GetNumTradingHouseGuilds())
        local selectedId = GetSelectedTradingHouseGuildId()
        if selectedId ~= nil then
            self:d('currentselectedid = '..GetSelectedTradingHouseGuildId())
        end
        guildId = 2
        SelectTradingHouseGuildId(guildId)
        local currentListings, maxListings = GetTradingHouseListingCounts()
        labelText = MOD.Colorize(COLOR_AWEVS_AVAILABLE, zo_strformat(SI_AWEMOD_PACKRAT_LABEL_FCO_GUILDSTORE, maxListings - currentListings))
        self.label[LABEL_FCO_GUILDSTORE]:SetText(labelText)
        ]]
    end

end -- MOD:Update

-- HELPER FUNCTIONS
local function DelayedScan()
    MOD.data.scanPending = false
    MOD:ScanInventory()
end

-- Count the types of items we have in our bag
function MOD:ScanInventory()
    if self.data.scanPending then 
        self:d("scan already pending")
        return 
    end
    local now = GetGameTimeMilliseconds()
    if now - self.data.lastScanTime < 1000 then
        -- wait and scan again
        self:d('scan scheduled')
        zo_callLater(DelayedScan, 3000)
        self.data.scanPending = true
        return
    end

    self:d('scanning inventory')
    self.data.lastScanTime = now

    self.data.numJunk = 0
    self.data.numJunkStacks = 0
    self.data.numStolen = 0
    self.data.numStolenStacks = 0
    self.data.numFish = 0
    self.data.numFishStacks = 0
    self.data.numContainers = 0
    self.data.numIntricates = 0
    self.data.numIntricatesBS = 0
    self.data.numIntricatesCR = 0
    self.data.numIntricatesJC = 0
    self.data.numIntricatesWW = 0
    self.data.numGlyphStacks = 0
    self.data.numMaps = 0
    self.data.mapName = ''
    self.data.numRecipes = 0
    self.data.numRecipesUnknown = 0
    self.data.numFurnishings = 0
    self.data.numFCODecon = 0
    self.data.numFCODeconBS = 0
    self.data.numFCODeconCR = 0
    self.data.numFCODeconJC = 0
    self.data.numFCODeconWW = 0
    self.data.numFCOGuildstoreStacks = 0

    if FCOIS then
        if FCOIS.addonVars.gPlayerActivated then
            --self:d('Found FCO ItemSaver!')
            self.FCOISReady = true
        end
    end

    local bagId = BAG_BACKPACK
    local bagSlots = GetBagSize(bagId)
    for index = 0, bagSlots do

        local itemType, itemSpecialType =  GetItemType(bagId, index)
        local itemTrait = GetItemTraitInformation(bagId, index)
        local itemLink = GetItemLink(bagId, index)
        local skillType = self:GetTradeskillType(itemLink)

        if self.FCOISReady and FCOIS.IsMarked(bagId, index, FCOIS_CON_ICON_DECONSTRUCTION, nil) then
            --self:d('found an FCO decon item!')
            self.data.numFCODecon = self.data.numFCODecon + 1
            if skillType == CRAFTING_TYPE_BLACKSMITHING then
                self.data.numFCODeconBS = self.data.numFCODeconBS + 1
            end
            if skillType == CRAFTING_TYPE_CLOTHIER then
                self.data.numFCODeconCR = self.data.numFCODeconCR + 1
            end
            if skillType == CRAFTING_TYPE_JEWELRYCRAFTING then
                self.data.numFCODeconJC = self.data.numFCODeconJC + 1
            end
            if skillType == CRAFTING_TYPE_WOODWORKING then
                self.data.numFCODeconWW = self.data.numFCODeconWW + 1
            end
        end

        if self.FCOISReady and FCOIS.IsMarked(bagId, index, FCOIS_CON_ICON_SELL_AT_GUILDSTORE, nil) then
            --self:d('found an FCO guildstore item!')
            self.data.numFCOGuildstoreStacks = self.data.numFCOGuildstoreStacks + 1
        end

        if (itemSpecialType == SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT or itemSpecialType == SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP) then
            self.data.numMaps = self.data.numMaps + 1
            self.data.mapName = GetItemName(bagId, index)
        end

        if (itemTrait == ITEM_TRAIT_INFORMATION_INTRICATE) then
            self.data.numIntricates = self.data.numIntricates + 1
            if skillType == CRAFTING_TYPE_BLACKSMITHING then
                self.data.numIntricatesBS = self.data.numIntricatesBS + 1
            end
            if skillType == CRAFTING_TYPE_CLOTHIER then
                self.data.numIntricatesCR = self.data.numIntricatesCR + 1
            end
            if skillType == CRAFTING_TYPE_JEWELRYCRAFTING then
                self.data.numIntricatesJC = self.data.numIntricatesJC + 1
            end
            if skillType == CRAFTING_TYPE_WOODWORKING then
                self.data.numIntricatesWW = self.data.numIntricatesWW + 1
            end
        end

        if (itemType == ITEMTYPE_FISH) then
            self.data.numFishStacks = self.data.numFishStacks + 1
            local _, stackCount = GetItemInfo(bagId, index)
            self.data.numFish = self.data.numFish + stackCount
        end

        if (itemType == ITEMTYPE_CONTAINER) then
            self.data.numContainers = self.data.numContainers + 1
        end

        if (itemType == ITEMTYPE_GLYPH_ARMOR or itemType == ITEMTYPE_GLYPH_JEWELRY or itemType == ITEMTYPE_GLYPH_WEAPON) then
            self.data.numGlyphStacks = self.data.numGlyphStacks + 1
        end

        if (itemType == ITEMTYPE_RECIPE) then
            self.data.numRecipes = self.data.numRecipes + 1
            if not IsItemLinkRecipeKnown(itemLink) then
                self.data.numRecipesUnknown = self.data.numRecipesUnknown + 1
            end
        end

        if (itemType == ITEMTYPE_FURNISHING) then
            self.data.numFurnishings = self.data.numFurnishings + 1
        end

        if( IsItemJunk(bagId,index) ) then
            self.data.numJunkStacks = self.data.numJunkStacks + 1
            local _, stackCount = GetItemInfo(bagId, index)
            self.data.numJunk = self.data.numJunk + stackCount
        end

        if( IsItemStolen(bagId,index) ) then
            self.data.numStolenStacks = self.data.numStolenStacks + 1
            local _, stackCount = GetItemInfo(bagId, index)
            self.data.numStolen = self.data.numStolen + stackCount
        end

    end
    self.dataUpdated = true    
end

--Returns: number TradeskillType tradeskillType
function MOD:GetTradeskillType(itemLink)
    -- doesn't appear to be a data driven way to find what tradeskill a piece of gear belongs to
    -- e.g. only raw materials and boosters return a crafting type
    -- or alkahest returns alchemy, etc. - but no way to find what something deconstructs as
    -- commence sleuthing

    -- currently:
    -- clothier = medium and light armor
    -- jewelrycrafting = necklaces and rings
    -- woodworking = staves, bows, and shields
    -- blacksmithing = (1) heavy armor and (2) every other weapon

    -- clothier is easy
    local armorType = GetItemLinkArmorType(itemLink)
    if armorType == ARMORTYPE_LIGHT or armorType == ARMORTYPE_MEDIUM then
        return CRAFTING_TYPE_CLOTHIER
    end
    -- and so is part 1 of blacksmithing
    if armorType == ARMORTYPE_HEAVY then
        return CRAFTING_TYPE_BLACKSMITHING
    end

    -- most ZOS globals break staffs into different groups...but sound catoregory doesn't so we can keep things simple:
    local soundCategory = GetItemSoundCategoryFromLink(itemLink)
    -- so woodworking isn't too bad:
    if soundCategory == ITEM_SOUND_CATEGORY_SHIELD or soundCategory == ITEM_SOUND_CATEGORY_STAFF or soundCategory == ITEM_SOUND_CATEGORY_BOW then
        return CRAFTING_TYPE_WOODWORKING
    end
    -- and neither is jewelrycrafting
    if soundCategory == ITEM_SOUND_CATEGORY_NECKLACE or soundCategory == ITEM_SOUND_CATEGORY_RING then
        return CRAFTING_TYPE_JEWELRYCRAFTING
    end

    -- and now all that should be left are metal weapons = blacksmithing part 2
    -- (until ZOS adds whips made by clothiers or something...)
    if  GetItemLinkWeaponType(itemLink) ~= WEAPONTYPE_NONE then 
        return CRAFTING_TYPE_BLACKSMITHING
    end

    -- ...amd if we made it this far, something's amiss
    return CRAFTING_TYPE_INVALID
end
