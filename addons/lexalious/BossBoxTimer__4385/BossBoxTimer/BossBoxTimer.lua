-- Initialize the Global Namespace
BossBoxTimer = BossBoxTimer or {}
BossBoxTimer.name = "BossBoxTimer"

-- Default Settings
BossBoxTimer.defaultVars = {
    left = 100,
    top = 100,
    isHidden = false,
    timerDuration = 300, -- 5 minutes in seconds
    targetTime = 0,      -- The specific system timestamp when the timer ends
    keywords = {
        ["parcel"] = true 
    },
    blacklistedWords = {
        ["waxed"] = true
    },
    debugMode = false,
    isLocked = false,
    soundId = SOUNDS.LEVEL_UP,
    warnOnChest = false,
}

BossBoxTimer.savedVars = {}
local isTimerRunning = false
local COLOR_GREEN = "|c77DD77"
local COLOR_WHITE = "|cFFFFFF"

local wm = WINDOW_MANAGER
local em = EVENT_MANAGER
local GetTimeStamp = GetTimeStamp
local PlaySound = PlaySound
local strformat = string.format
local math_floor = math.floor

-- 1. Helper: Clean String
local function CleanString(text)
    if type(text) ~= "string" or text == "" then return "" end
    local name = GetItemLinkName(text)
    if name == "" then name = text end
    name = zo_strformat("<<t:1>>", name)
    name = zo_strlower(name)
    return zo_strtrim(name)
end

-- 2. Create UI
local function CreateTimerWindow()
    BossBoxTimer.Window = wm:CreateTopLevelWindow("BossBoxTimer_Frame")
    BossBoxTimer.Window:SetDimensions(160, 50)
    BossBoxTimer.Window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BossBoxTimer.savedVars.left, BossBoxTimer.savedVars.top)
    BossBoxTimer.Window:SetMovable(not BossBoxTimer.savedVars.isLocked)
    BossBoxTimer.Window:SetMouseEnabled(not BossBoxTimer.savedVars.isLocked)
    BossBoxTimer.Window:SetClampedToScreen(true)
    BossBoxTimer.Window:SetHidden(BossBoxTimer.savedVars.isHidden)

    local bg = wm:CreateControl("BossBoxTimer_Bg", BossBoxTimer.Window, CT_BACKDROP)
    bg:SetAnchorFill(BossBoxTimer.Window)
    bg:SetCenterColor(0, 0, 0, 0.5)
    bg:SetEdgeColor(0, 0, 0, 1)

    BossBoxTimer.Label = wm:CreateControl("BossBoxTimer_Label", BossBoxTimer.Window, CT_LABEL)
    BossBoxTimer.Label:SetFont("$(BOLD_FONT)|24|soft-shadow-thick")
    BossBoxTimer.Label:SetColor(1, 1, 1, 1)
    BossBoxTimer.Label:SetText("BossBox Ready")
    BossBoxTimer.Label:SetAnchor(CENTER, BossBoxTimer.Window, CENTER, 0, 0)

    BossBoxTimer.Window:SetHandler("OnMoveStop", function(control)
        BossBoxTimer.savedVars.left = control:GetLeft()
        BossBoxTimer.savedVars.top = control:GetTop()
    end)

    -- Warning Frame (TopLevel for Z-Index)
    BossBoxTimer.WarningFrame = wm:CreateTopLevelWindow("BossBoxTimer_WarningFrame")
    BossBoxTimer.WarningFrame:SetDimensions(600, 100)
    BossBoxTimer.WarningFrame:SetAnchor(CENTER, GuiRoot, CENTER, 0, -200)
    BossBoxTimer.WarningFrame:SetDrawTier(DT_MAX) -- Force on top of everything
    BossBoxTimer.WarningFrame:SetHidden(true)

    -- Warning Label
    BossBoxTimer.WarningLabel = wm:CreateControl("BossBoxTimer_WarningLabel", BossBoxTimer.WarningFrame, CT_LABEL)
    BossBoxTimer.WarningLabel:SetFont("$(BOLD_FONT)|45|soft-shadow-thick")
    BossBoxTimer.WarningLabel:SetColor(1, 0, 0, 1) -- RED
    BossBoxTimer.WarningLabel:SetText("TIMER ACTIVE! IGNORE CHEST!")
    BossBoxTimer.WarningLabel:SetAnchor(CENTER, BossBoxTimer.WarningFrame, CENTER, 0, 0)
end

-- 3. Timer Logic (Optimized: Auto-Unregister)
local function UpdateTimer()
    if BossBoxTimer.savedVars.targetTime > 0 then
        local currentTime = GetTimeStamp()
        local timeLeft = BossBoxTimer.savedVars.targetTime - currentTime

        if timeLeft > 0 then
            if not BossBoxTimer.savedVars.isHidden then
                local mins = math_floor(timeLeft / 60)
                local secs = timeLeft % 60
                BossBoxTimer.Label:SetText(strformat("%s%02d:%02d|r", COLOR_WHITE, mins, secs))
            end
        else
            isTimerRunning = false
            BossBoxTimer.savedVars.targetTime = 0
            
            -- Stop the loop to save resources
            em:UnregisterForUpdate(BossBoxTimer.name)
            
            -- Always play sound and reset text
            BossBoxTimer.Label:SetText(strformat("%s00:00|r", COLOR_GREEN))
            PlaySound(BossBoxTimer.savedVars.soundId) 
            if BossBoxTimer.savedVars.isHidden then
                d("|c00FF00[BossBox]|r Timer Finished!")
            end
        end
    else
        -- Manual Reset detected (targetTime is 0 but loop was running)
        isTimerRunning = false
        em:UnregisterForUpdate(BossBoxTimer.name)
        em:UnregisterForEvent("BossBoxTimer_Reticle", EVENT_RETICLE_TARGET_CHANGED)
        BossBoxTimer.Label:SetText("BossBox Ready")
        BossBoxTimer.WarningFrame:SetHidden(true)
    end
end

function BossBoxTimer.CheckReticle()
    if not isTimerRunning then 
        BossBoxTimer.WarningFrame:SetHidden(true)
        return 
    end

    local action, name, interactBlocked, isOwned, additionalInfo, categoryId, actionId, isCriminalInteract = GetGameCameraInteractableActionInfo()
    
    if not name or name == "" then 
        BossBoxTimer.WarningFrame:SetHidden(true)
        return 
    end

    -- Clean the name to handle formatting codes
    local cleanName = CleanString(name)

    if BossBoxTimer.savedVars.debugMode then
        d(string.format("[BossBox] Reticle: '%s' (Clean: '%s') Action: '%s'", name, cleanName, tostring(action)))
    end

    -- Keywords to trigger warning (experimental)
    local keywords = {"chest", "trove", "box", "sack", "coffer", "cache"}
    local isTarget = false

    for _, word in ipairs(keywords) do
        if string.find(cleanName, word, 1, true) then
            isTarget = true
            break
        end
    end

    BossBoxTimer.WarningFrame:SetHidden(not isTarget)
    
    if isTarget and BossBoxTimer.savedVars.debugMode then
        d("[BossBox] SHOWING WARNING FOR: " .. cleanName)
    end
end

-- 4. Loot Handler
local function OnLootReceived(eventCode, receivedBy, itemName, quantity, itemSound, lootType, isSelf)
    if not isSelf then return end
    
    local cleanName = CleanString(itemName)

    if BossBoxTimer.savedVars.debugMode then 
        d("[BossBox] Scanned: " .. cleanName) 
    end

    -- Skip if no keywords are set
    if next(BossBoxTimer.savedVars.keywords) == nil then return end

    local isMatch = false
    for keyword, isEnabled in pairs(BossBoxTimer.savedVars.keywords) do
        if isEnabled and string.find(cleanName, string.lower(keyword), 1, true) then
            isMatch = true
            break
        end
    end

    if not isMatch then return end

    -- Check Blacklist
    for blackword, isEnabled in pairs(BossBoxTimer.savedVars.blacklistedWords) do
        if isEnabled and string.find(cleanName, string.lower(blackword), 1, true) then
            if BossBoxTimer.savedVars.debugMode then 
                d("|cFFFF00[BossBox]|r Ignored due to blacklist: '" .. blackword .. "'") 
            end
            return
        end
    end

    -- Start Timer
    BossBoxTimer.savedVars.targetTime = GetTimeStamp() + BossBoxTimer.savedVars.timerDuration
    
    -- Only register the update loop if it's not already running
    if not isTimerRunning then
        isTimerRunning = true
        em:RegisterForUpdate(BossBoxTimer.name, 1000, UpdateTimer)
        
        -- Register Reticle Check if enabled
        if BossBoxTimer.savedVars.warnOnChest then
            em:RegisterForEvent("BossBoxTimer_Reticle", EVENT_RETICLE_TARGET_CHANGED, BossBoxTimer.CheckReticle)
        end
    end
    
    UpdateTimer() -- Force immediate visual update
    
    d(string.format("|c00FF00[BossBox]|r MATCH: '%s' triggered timer.", cleanName))
end

-- 5. Initialization
local function OnAddOnLoaded(event, addonName)
    if addonName ~= BossBoxTimer.name then return end
    em:UnregisterForEvent(BossBoxTimer.name, EVENT_ADD_ON_LOADED)

    -- Initialize Saved Variables
    BossBoxTimer.savedVars = ZO_SavedVars:NewAccountWide("BossBoxTimer_SavedVars", 1, nil, BossBoxTimer.defaultVars)

    -- Build UI
    CreateTimerWindow()

    if BossBoxTimer.savedVars.targetTime > GetTimeStamp() then
        isTimerRunning = true
        em:RegisterForUpdate(BossBoxTimer.name, 1000, UpdateTimer)
        
        if BossBoxTimer.savedVars.warnOnChest then
            em:RegisterForEvent("BossBoxTimer_Reticle", EVENT_RETICLE_TARGET_CHANGED, BossBoxTimer.CheckReticle)
        end

        UpdateTimer() 
    else
        BossBoxTimer.savedVars.targetTime = 0
        isTimerRunning = false
    end

    if BossBoxTimer.BuildSettingsMenu then
        BossBoxTimer.BuildSettingsMenu()
    end

    -- Events & Shortcut
    em:RegisterForEvent(BossBoxTimer.name, EVENT_LOOT_RECEIVED, OnLootReceived)
    
    SLASH_COMMANDS["/bossbox"] = function() LibAddonMenu2:OpenToPanel(BossBoxTimer_Settings) end
end

em:RegisterForEvent(BossBoxTimer.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)