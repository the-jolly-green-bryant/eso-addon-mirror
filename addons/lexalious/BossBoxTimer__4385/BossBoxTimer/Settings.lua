function BossBoxTimer.BuildSettingsMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end 

    local panelData = {
        type = "panel",
        name = "BossBoxTimer", 
        displayName = "|c77DD77BossBox|r Timer",
        author = "Lexalious",
        version = "1.1",
        registerForRefresh = true,
        registerForDefaults = true
    }

    local optionsData = {
        {
            type = "header",
            name = "General Settings"
        },
        {
            type = "checkbox",
            name = "Hide Timer Window",
            tooltip = "Run the timer in the background without showing the UI on your screen.",
            getFunc = function() return BossBoxTimer.savedVars.isHidden end,
            setFunc = function(value) 
                BossBoxTimer.savedVars.isHidden = value
                if BossBoxTimer.Window then 
                    BossBoxTimer.Window:SetHidden(value) 
                end
            end,
            default = BossBoxTimer.defaultVars.isHidden,
        },
        {
            type = "slider",
            name = "Timer Duration (Minutes)",
            tooltip = "How long the timer should run when triggered.",
            min = 1,
            max = 60,
            step = 1,
            getFunc = function() return BossBoxTimer.savedVars.timerDuration / 60 end,
            setFunc = function(value) BossBoxTimer.savedVars.timerDuration = value * 60 end,
            default = BossBoxTimer.defaultVars.timerDuration / 60,
        },
        {
            type = "checkbox",
            name = "Debug Mode",
            tooltip = "Prints scanned items to chat. Useful for testing keywords.",
            getFunc = function() return BossBoxTimer.savedVars.debugMode end,
            setFunc = function(value) BossBoxTimer.savedVars.debugMode = value end,
    default = BossBoxTimer.defaultVars.debugMode,
        },
        {
            type = "checkbox",
            name = "Lock Position",
            tooltip = "Lock the timer window in place so it cannot be moved.",
            getFunc = function() return BossBoxTimer.savedVars.isLocked end,
            setFunc = function(value)
                BossBoxTimer.savedVars.isLocked = value
                if BossBoxTimer.Window then
                    BossBoxTimer.Window:SetMovable(not value)
                    BossBoxTimer.Window:SetMouseEnabled(not value)
                end
            end,
            default = BossBoxTimer.defaultVars.isLocked,
        },
        {
            type = "dropdown",
            name = "Notification Sound",
            tooltip = "Select the sound to play when the timer finishes.",
            choices = {
                "Level Up",
                "Champion Point Gained",
                "Book Acquired",
                "Quest Complete",
                "Ability Ultimate Ready",
            },
            choicesValues = {
                SOUNDS.LEVEL_UP,
                SOUNDS.CHAMPION_POINT_GAINED,
                SOUNDS.BOOK_ACQUIRED,
                SOUNDS.QUEST_OBJECTIVE_COMPLETE,
                SOUNDS.ABILITY_ULTIMATE_READY,
            },
            getFunc = function() return BossBoxTimer.savedVars.soundId end,
            setFunc = function(value) 
                BossBoxTimer.savedVars.soundId = value 
                PlaySound(value) -- Preview sound
            end,
            default = BossBoxTimer.defaultVars.soundId,
        },
        {
            type = "header",
            name = "Tracking Lists"
        },
        {
            type = "description",
            text = "Enter words separated by commas. Example: |cFFFFFFparcel, motif, wax|r"
        },
        {
            type = "editbox",
            name = "Trigger Words (Whitelist)",
            tooltip = "If you loot an item with these words, the timer starts.",
            isMultiline = true,
            isExtraWide = true,
            getFunc = function() 
                local list = {}
                for k, v in pairs(BossBoxTimer.savedVars.keywords) do
                    if v then table.insert(list, k) end
                end
                return table.concat(list, ", ")
            end,
            setFunc = function(value)
                BossBoxTimer.savedVars.keywords = {}
                for word in string.gmatch(value, '([^,]+)') do
                    local cleanWord = zo_strlower(zo_strtrim(word))
                    if cleanWord ~= "" then
                        BossBoxTimer.savedVars.keywords[cleanWord] = true
                    end
                end
            end,
            default = "parcel",
        },
        {
            type = "editbox",
            name = "Ignored Words (Blacklist)",
            tooltip = "If a trigger word is found, BUT one of these words is also present, the timer will NOT start.",
            isMultiline = true,
            isExtraWide = true,
            getFunc = function() 
                local list = {}
                for k, v in pairs(BossBoxTimer.savedVars.blacklistedWords) do
                    if v then table.insert(list, k) end
                end
                return table.concat(list, ", ")
            end,
            setFunc = function(value)
                BossBoxTimer.savedVars.blacklistedWords = {}
                for word in string.gmatch(value, '([^,]+)') do
                    local cleanWord = zo_strlower(zo_strtrim(word))
                    if cleanWord ~= "" then
                        BossBoxTimer.savedVars.blacklistedWords[cleanWord] = true
                    end
                end
            end,
            default = "",
        },
        {
            type = "button",
            name = "Reset Timer",
            func = function()
                BossBoxTimer.savedVars.targetTime = 0
                -- Update the UI immediately
                if BossBoxTimer.Label then
                    BossBoxTimer.Label:SetText("BossBox Ready")
                end
                if BossBoxTimer.WarningFrame then
                    BossBoxTimer.WarningFrame:SetHidden(true)
                end
                d("BossBox: Timer manually reset.")
            end,
        },
        {
            type = "header",
            name = "Experimental",
        },
        {
            type = "checkbox",
            name = "Chest Warning",
            tooltip = "Displays a large red warning if you look at a chest while the timer is running.",
            getFunc = function() return BossBoxTimer.savedVars.warnOnChest end,
            setFunc = function(value) 
                BossBoxTimer.savedVars.warnOnChest = value
                local isRunning = BossBoxTimer.savedVars.targetTime > GetTimeStamp()
                
                if value and isRunning then
                    -- Only register immediately if timer is actually running
                    EVENT_MANAGER:RegisterForEvent("BossBoxTimer_Reticle", EVENT_RETICLE_TARGET_CHANGED, BossBoxTimer.CheckReticle)
                else
                    -- Always unregister if turning off, or if turning on but timer is stopped (it will register when timer starts)
                    EVENT_MANAGER:UnregisterForEvent("BossBoxTimer_Reticle", EVENT_RETICLE_TARGET_CHANGED)
                    if BossBoxTimer.WarningFrame then BossBoxTimer.WarningFrame:SetHidden(true) end
                end
            end,
            default = BossBoxTimer.defaultVars.warnOnChest,
        }
    }

    LAM:RegisterAddonPanel("BossBoxTimer_Settings", panelData)
    LAM:RegisterOptionControls("BossBoxTimer_Settings", optionsData)
end