-----------------------------------------------------------
-- MasterThief v2.15 - Pure Stealing & Treasure Value Estimator
-----------------------------------------------------------
local MasterThief = MasterThief or {}
MasterThief.name = "MasterThief"

local GetTimeStamp = GetTimeStamp
local string_format = string.format
local table_insert = table.insert
local string_lower = string.lower
local string_find = string.find
local string_match = string.match
local tonumber = tonumber
local tostring = tostring

MasterThief.defaultSettings = {
    showHUD = true,
    showSessionStats = true,
    showTimer = true,
    announceInChat = true,
    playLootSound = true,
    fontSize = 11,
    posX = 60,
    posY = 100,
    bgColorR = 0.05,
    bgColorG = 0.05,
    bgColorB = 0.1,
    bgColorA = 0.75,
    debugMode = false,
    lastResetDay = 0,
    charStats = {},
}

-----------------------------------------------------------
-- HELPERS & SAFE API WRAPPERS
-----------------------------------------------------------
function MasterThief.DebugLog(msg)
    if MasterThief.savedVars and MasterThief.savedVars.debugMode then
        CHAT_ROUTER:AddSystemMessage(string_format("|cFFD700[MasterThief Debug]|r %s", tostring(msg)))
    end
end

function MasterThief.SafeGetDisplayQuality(link)
    if type(GetItemLinkDisplayQuality) == "function" then
        local ok, qual = pcall(GetItemLinkDisplayQuality, link)
        if ok and qual then return tonumber(qual) or 1 end
    end
    -- Fallback: parse color/quality or default to standard
    return 1
end

function MasterThief.SafeIsItemStolen(bagId, slotIndex)
    if type(IsItemStolen) == "function" then
        local ok, stolen = pcall(IsItemStolen, bagId, slotIndex)
        if ok and stolen then return true end
    end
    return false
end

function MasterThief.GetCustomFont(size)
    return string_format("$(CHAT_FONT)|%d|soft-shadow-thick", size or 11)
end

function MasterThief.GetFormattedSessionTime()
    if not MasterThief.sessionStartTime then
        return "00:00:00"
    end
    local elapsedSeconds = GetTimeStamp() - MasterThief.sessionStartTime
    local hours = math.floor(elapsedSeconds / 3600)
    local mins = math.floor((elapsedSeconds % 3600) / 60)
    local secs = elapsedSeconds % 60
    return string_format("%02d:%02d:%02d", hours, mins, secs)
end

function MasterThief.ResetSessionTimer()
    MasterThief.sessionStartTime = GetTimeStamp()
    local stats = MasterThief.GetActiveCharacterStats()
    if stats then
        stats.totalStolen = 0
        stats.whiteJunkDestroyed = 0
        stats.greenLoot = 0
        stats.blueLoot = 0
        stats.purpleLoot = 0
        stats.estimatedGold = 0
    end
    MasterThief.UpdateHUDContent()
end

function MasterThief.CheckDailyReset()
    if not MasterThief.savedVars then return end
    
    local currentTime = GetTimeStamp()
    local dailyResetOffset = 36000 
    local currentDayId = math.floor((currentTime - dailyResetOffset) / 86400)

    if MasterThief.savedVars.lastResetDay ~= currentDayId then
        MasterThief.savedVars.lastResetDay = currentDayId
        MasterThief.ResetSessionTimer()
        CHAT_ROUTER:AddSystemMessage("|c00FF00[MasterThief]|r NA Daily reset detected! Session stats refreshed.")
    end
end

function MasterThief.GetActiveCharacterStats()
    if not MasterThief.savedVars then return nil end
    MasterThief.savedVars.charStats = MasterThief.savedVars.charStats or {}
    
    local charName = GetUnitName("player")
    if not charName or charName == "" then charName = "Default" end
    
    if not MasterThief.savedVars.charStats[charName] then
        MasterThief.savedVars.charStats[charName] = {
            totalStolen = 0,
            whiteJunkDestroyed = 0,
            greenLoot = 0,
            blueLoot = 0,
            purpleLoot = 0,
            estimatedGold = 0,
        }
    end
    return MasterThief.savedVars.charStats[charName]
end

-----------------------------------------------------------
-- VALIDATE TREASURE
-----------------------------------------------------------
local function IsValidTreasure(bagId, slotIndex, link)
    if not link or link == "" then return false end
    if not MasterThief.SafeIsItemStolen(bagId, slotIndex) then return false end

    local quality = MasterThief.SafeGetDisplayQuality(link)
    if quality >= 2 then
        return true
    end

    return false
end

-----------------------------------------------------------
-- SCAN EXISTING INVENTORY
-----------------------------------------------------------
function MasterThief.ScanExistingInventory()
    if not MasterThief.savedVars then return end
    local stats = MasterThief.GetActiveCharacterStats()
    
    stats.greenLoot = 0
    stats.blueLoot = 0
    stats.purpleLoot = 0
    stats.estimatedGold = 0

    local treasureValues = {
        [2] = 100,  -- Green = 100g
        [3] = 250,  -- Blue = 250g
        [4] = 500,  -- Purple = 500g
    }

    local bagSize = (type(GetBagSize) == "function" and GetBagSize(BAG_BACKPACK)) or 200
    for slotIndex = 1, bagSize do
        local link = (type(GetItemLink) == "function") and GetItemLink(BAG_BACKPACK, slotIndex) or ""
        
        if link and link ~= "" then
            if IsValidTreasure(BAG_BACKPACK, slotIndex, link) then
                local quality = MasterThief.SafeGetDisplayQuality(link)
                local stackCount = (type(GetItemStackCount) == "function" and GetItemStackCount(BAG_BACKPACK, slotIndex)) or 1

                if quality == 2 then
                    stats.greenLoot = stats.greenLoot + stackCount
                elseif quality == 3 then
                    stats.blueLoot = stats.blueLoot + stackCount
                elseif quality >= 4 then
                    stats.purpleLoot = stats.purpleLoot + stackCount
                end
                
                local treasureValue = treasureValues[quality] or 100
                stats.estimatedGold = stats.estimatedGold + (treasureValue * stackCount)
            end
        end
    end
    MasterThief.UpdateHUDContent()
end

-----------------------------------------------------------
-- INVENTORY EVENT TRACKER
-----------------------------------------------------------
function MasterThief.OnInventorySlotUpdate(eventCode, bagId, slotIndex, isNew, _, _, stackCountChange)
    if not MasterThief.savedVars then return end
    if bagId ~= BAG_BACKPACK then return end

    MasterThief.CheckDailyReset()

    if isNew then
        local link = (type(GetItemLink) == "function") and GetItemLink(bagId, slotIndex) or ""
        if link == "" then return end

        local itemName = (type(GetItemLinkName) == "function") and GetItemLinkName(link) or ""
        local isQuestItem = false
        if type(IsItemQuest) == "function" then
            pcall(function() isQuestItem = IsItemQuest(bagId, slotIndex) end)
        end
        
        local isStolen = MasterThief.SafeIsItemStolen(bagId, slotIndex)
        local quality = MasterThief.SafeGetDisplayQuality(link)
        
        local itemType = 0
        if type(GetItemLinkItemType) == "function" then
            pcall(function() itemType = GetItemLinkItemType(link) or 0 end)
        end

        local isLockpick = (itemType == ITEMTYPE_TOOL) or string_find(link, "item:44874") or string_match(string_lower(itemName), "lockpick")
        
        local isProtectedMaterial = (itemType == ITEMTYPE_CRAFTING_MAT_ADDITIVE or 
                                    itemType == ITEMTYPE_WEAPON_TRAIT_MAT or 
                                    itemType == ITEMTYPE_ARMOR_TRAIT_MAT or 
                                    itemType == ITEMTYPE_ENCHANTING_RUNE or 
                                    itemType == ITEMTYPE_BLACKSMITHING_BOOSTER or 
                                    itemType == ITEMTYPE_CLOTHIER_BOOSTER or 
                                    itemType == ITEMTYPE_WOODWORKING_BOOSTER or 
                                    itemType == ITEMTYPE_JEWELRYCRAFTING_BOOSTER or 
                                    itemType == ITEMTYPE_JEWELRYCRAFTING_MAT or 
                                    itemType == ITEMTYPE_INGREDIENT or 
                                    itemType == ITEMTYPE_POTION or 
                                    itemType == ITEMTYPE_POISON or
                                    itemType == ITEMTYPE_STYLE_MATERIAL or
                                    itemType == ITEMTYPE_TOOL or
                                    isLockpick)

        local delta = (type(stackCountChange) == "number" and stackCountChange > 0) and stackCountChange or 1

        if isStolen and MasterThief.savedVars.showTimer and not MasterThief.sessionStartTime then
            MasterThief.sessionStartTime = GetTimeStamp()
        end

        -- Auto-destroy white quality stolen trash
        if not isQuestItem and not isProtectedMaterial and isStolen and quality <= 1 then
            local stats = MasterThief.GetActiveCharacterStats()
            stats.whiteJunkDestroyed = (tonumber(stats.whiteJunkDestroyed) or 0) + delta
            
            if MasterThief.savedVars.announceInChat then
                CHAT_ROUTER:AddSystemMessage(string_format("|cFF6666[MasterThief] Destroyed Stolen Junk:|r %s", link))
            end
            
            if type(DestroyItem) == "function" then
                DestroyItem(bagId, slotIndex)
            end
            MasterThief.UpdateHUDContent()
            return
        end

        -- Track Treasures
        if IsValidTreasure(bagId, slotIndex, link) then
            quality = tonumber(quality) or 2

            local stats = MasterThief.GetActiveCharacterStats()
            stats.totalStolen = (tonumber(stats.totalStolen) or 0) + 1

            local treasureValues = {
                [2] = 100,
                [3] = 250,
                [4] = 500,
            }
            local treasureValue = treasureValues[quality] or 100
            stats.estimatedGold = (tonumber(stats.estimatedGold) or 0) + (treasureValue * delta)

            if quality == 2 then
                stats.greenLoot = (tonumber(stats.greenLoot) or 0) + delta
            elseif quality == 3 then
                stats.blueLoot = (tonumber(stats.blueLoot) or 0) + delta
            elseif quality >= 4 then
                stats.purpleLoot = (tonumber(stats.purpleLoot) or 0) + delta
            end

            if quality >= 2 and MasterThief.savedVars.playLootSound and type(PlaySound) == "function" then
                PlaySound(SOUNDS.TELVAR_GAINED)
            end

            MasterThief.UpdateHUDContent()
        end
    end
end

-----------------------------------------------------------
-- HUD DISPLAY & POSITIONS
-----------------------------------------------------------
function MasterThief.ApplyPosition()
    if not MasterThief.hudFrame then return end
    MasterThief.hudFrame:ClearAnchors()
    MasterThief.hudFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, MasterThief.savedVars.posX or 60, MasterThief.savedVars.posY or 100)
end

function MasterThief.ApplyBackgroundColor()
    if not MasterThief.hudBg then return end
    MasterThief.hudBg:SetColor(
        MasterThief.savedVars.bgColorR or 0.05,
        MasterThief.savedVars.bgColorG or 0.05,
        MasterThief.savedVars.bgColorB or 0.1,
        MasterThief.savedVars.bgColorA or 0.75
    )
end

function MasterThief.CreateHUD()
    if MasterThief.hudFrame then return end

    local wm = WINDOW_MANAGER
    local mainFrame = wm:CreateTopLevelWindow("MasterThiefHUD")
    mainFrame:SetMovable(true)
    mainFrame:SetMouseEnabled(true)
    mainFrame:SetClampedToScreen(true)
    MasterThief.hudFrame = mainFrame

    local bg = wm:CreateControl("$(parent)BG", mainFrame, CT_TEXTURE)
    bg:SetAnchorFill(mainFrame)
    MasterThief.hudBg = bg
    MasterThief.ApplyBackgroundColor()

    mainFrame:SetHandler("OnMoveStop", function(self)
        MasterThief.savedVars.posX = self:GetLeft()
        MasterThief.savedVars.posY = self:GetTop()
        if LibAddonMenu2 and MasterThief.optionsPanel then
            CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", MasterThief.optionsPanel)
        end
    end)

    local content = wm:CreateControl("$(parent)Content", mainFrame, CT_LABEL)
    content:SetAnchor(TOPLEFT, mainFrame, TOPLEFT, 12, 12)
    MasterThief.contentLabel = content

    MasterThief.ApplyPosition()
    MasterThief.UpdateHUDContent()
    MasterThief.hudFrame:SetHidden(not MasterThief.savedVars.showHUD)
end

function MasterThief.UpdateHUDContent()
    if not MasterThief.contentLabel or not MasterThief.hudFrame then return end

    MasterThief.contentLabel:SetFont(MasterThief.GetCustomFont(MasterThief.savedVars.fontSize or 11))
    local buffer = {}

    table_insert(buffer, "|cFFD700- MASTER THIEF : CRIME TRACKER -|r")
    
    if MasterThief.savedVars.showSessionStats ~= false then
        local stats = MasterThief.GetActiveCharacterStats()
        local timerText = ""
        if MasterThief.savedVars.showTimer ~= false then
            timerText = string_format("Time: |cFFD700%s|r   ", MasterThief.GetFormattedSessionTime())
        end

        table_insert(buffer, string_format("%sDestroyed: |cFF6666%d|r   Green: |c2DC800%d|r   Blue: |c3A92FF%d|r   Purple: |cA335EE%d|r", 
            timerText,
            stats.whiteJunkDestroyed or 0, 
            stats.greenLoot or 0, 
            stats.blueLoot or 0, 
            stats.purpleLoot or 0
        ))

        table_insert(buffer, string_format("Est. Value: |cFFD700%d g|r", stats.estimatedGold or 0))
    end

    MasterThief.contentLabel:SetText(table.concat(buffer, "\n"))
    MasterThief.hudFrame:SetDimensions(MasterThief.contentLabel:GetTextWidth() + 24, MasterThief.contentLabel:GetTextHeight() + 24)
end

-----------------------------------------------------------
-- SETTINGS PANEL (LibAddonMenu2)
-----------------------------------------------------------
function MasterThief.CreateSettingsPanel()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelName = "MasterThief_OptionsPanel"
    local panelData = {
        type = "panel",
        name = "Master Thief",
        displayName = "|cFFD700Master |c00BFFFThief |cFF69B4Settings|r",
        author = "|c00FF00Thief|r",
        version = "2.15",
        slashCommand = "/thiefsettings",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    MasterThief.optionsPanel = LAM:RegisterAddonPanel(panelName, panelData)

    local optionsData = {
        {
            type = "description",
            text = "|cFFD700Track your stolen treasures, auto-destroy worthless white trash, and monitor your crime spree statistics!|r",
        },
        {
            type = "header",
            name = "|c00BFFFDisplay & Notifications|r",
        },
        {
            type = "checkbox",
            name = "|cFFFFFFShow Stealing HUD|r",
            tooltip = "Toggles the on-screen crime stats display.",
            getFunc = function() return MasterThief.savedVars.showHUD end,
            setFunc = function(value)
                MasterThief.savedVars.showHUD = value
                if MasterThief.hudFrame then MasterThief.hudFrame:SetHidden(not value) end
            end,
            default = MasterThief.defaultSettings.showHUD,
        },
        {
            type = "checkbox",
            name = "|cFF6666Announce Destroyed Junk in Chat|r",
            tooltip = "Prints a message in your chat window whenever a white stolen item is auto-destroyed.",
            getFunc = function() return MasterThief.savedVars.announceInChat end,
            setFunc = function(value) MasterThief.savedVars.announceInChat = value end,
            default = MasterThief.defaultSettings.announceInChat,
        },
        {
            type = "checkbox",
            name = "|cA335EEPlay Audio on Valuable Loot|r",
            tooltip = "Plays a subtle sound cue when you steal a Green, Blue, or Purple quality item.",
            getFunc = function() return MasterThief.savedVars.playLootSound end,
            setFunc = function(value) MasterThief.savedVars.playLootSound = value end,
            default = MasterThief.defaultSettings.playLootSound,
        },
        {
            type = "checkbox",
            name = "|cFFD700Show Session Timer|r",
            tooltip = "Tracks how long your current crime spree has lasted.",
            getFunc = function() return MasterThief.savedVars.showTimer end,
            setFunc = function(value)
                MasterThief.savedVars.showTimer = value
                if not value then MasterThief.ResetSessionTimer() else MasterThief.UpdateHUDContent() end
            end,
            default = MasterThief.defaultSettings.showTimer,
        },
        {
            type = "header",
            name = "|c00BFFFHUD Customization|r",
        },
        {
            type = "slider",
            name = "|cFFFFFFFont Size|r",
            min = 9, max = 50, step = 1,
            getFunc = function() return MasterThief.savedVars.fontSize end,
            setFunc = function(value) MasterThief.savedVars.fontSize = value; MasterThief.UpdateHUDContent() end,
            default = MasterThief.defaultSettings.fontSize,
        },
        {
            type = "slider",
            name = "|cFFFFFFX Position|r",
            min = 0, max = 2000, step = 5,
            getFunc = function() return MasterThief.savedVars.posX end,
            setFunc = function(value) MasterThief.savedVars.posX = value; MasterThief.ApplyPosition() end,
            default = MasterThief.defaultSettings.posX,
        },
        {
            type = "slider",
            name = "|cFFFFFFY Position|r",
            min = 0, max = 1200, step = 5,
            getFunc = function() return MasterThief.savedVars.posY end,
            setFunc = function(value) MasterThief.savedVars.posY = value; MasterThief.ApplyPosition() end,
            default = MasterThief.defaultSettings.posY,
        },
    }

    LAM:RegisterOptionControls(panelName, optionsData)
end

-----------------------------------------------------------
-- INITIALIZATION
-----------------------------------------------------------
function MasterThief.Initialize()
    MasterThief.savedVars = ZO_SavedVars:NewAccountWide("MasterThief_SavedVars", 1, nil, MasterThief.defaultSettings)
    
    MasterThief.CheckDailyReset()
    MasterThief.CreateHUD()
    MasterThief.CreateSettingsPanel()

    MasterThief.ScanExistingInventory()

    EVENT_MANAGER:RegisterForEvent(MasterThief.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, MasterThief.OnInventorySlotUpdate)

    EVENT_MANAGER:RegisterForUpdate(MasterThief.name .. "_TimerLoop", 1000, function()
        if MasterThief.savedVars and MasterThief.savedVars.showHUD and MasterThief.savedVars.showTimer then
            MasterThief.UpdateHUDContent()
        end
    end)

    SLASH_COMMANDS["/thief"] = function()
        if MasterThief.hudFrame then
            local newState = not MasterThief.savedVars.showHUD
            MasterThief.savedVars.showHUD = newState
            MasterThief.hudFrame:SetHidden(not newState)
        end
    end

    SLASH_COMMANDS["/thiefreset"] = function()
        MasterThief.ResetSessionTimer()
        CHAT_ROUTER:AddSystemMessage("|c00FF00[MasterThief]|r Manual session reset triggered!")
    end

    CHAT_ROUTER:AddSystemMessage("|c00FF00[MasterThief]|r Pure Stealing Mode v2.15 active!")
end

EVENT_MANAGER:RegisterForEvent(MasterThief.name, EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName ~= MasterThief.name then return end
    MasterThief.Initialize()
    EVENT_MANAGER:UnregisterForEvent(MasterThief.name, EVENT_ADD_ON_LOADED)
end)