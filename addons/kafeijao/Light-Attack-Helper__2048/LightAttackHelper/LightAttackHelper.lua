-------------------------------------------------------------------------------------------------
--  Libraries --
-------------------------------------------------------------------------------------------------
local LAM2 = LibAddonMenu2
local chat = LibChatMessage("|ce0a22fL|right |ce0a22fA|rttack Helper", "|ce0a22fL|ce0a22fA|rH")

-------------------------------------
-- Addon data.
-------------------------------------
LightAttackHelper = LightAttackHelper or {}
LightAttackHelper.name = "LightAttackHelper"
LightAttackHelper.slashComandName = "/la"
LightAttackHelper.playerName = GetRawUnitName("player")
LightAttackHelper.isPlayerNightblade = GetUnitClassId("player") == 3
LightAttackHelper.abilitiesFrontbar = nil
LightAttackHelper.abilitiesBackbar = nil
LightAttackHelper.isOnFrontbar = nil
LightAttackHelper.isOnRanged = nil
LightAttackHelper.castingHeavyAttack = false
LightAttackHelper.usedAbilityDuringHeavyAttack = false
LightAttackHelper.shotFirstLightAttack = false
LightAttackHelper.combatStartedTimeMs = nil

LightAttackHelper.LightAttackCounter = 0
LightAttackHelper.msNumbers = {}
LightAttackHelper.lastCombatDuration = nil

LightAttackHelper.goodHAResults = {
    ACTION_RESULT_DAMAGE,
    ACTION_RESULT_BLOCKED,
    ACTION_RESULT_BLOCKED_DAMAGE,
    ACTION_RESULT_CRITICAL_DAMAGE,
    ACTION_RESULT_DAMAGE_SHIELDED,
    ACTION_RESULT_DEFENDED,
    ACTION_RESULT_DODGED,
}



LightAttackHelper.variableVersion = 13
LightAttackHelper.Default = {
    left = GuiRoot:GetWidth()/2,
    top  = GuiRoot:GetHeight()/2,
    hideCounter = false,
    hideRatio = false,
    hideCounterOnNightBlades = true,
    hideRatioOnNightBlades = false,
    resetOn = "Barswap",
    printRationAutomaticallyIn = "Player Houses",
    displayedUnderTheCounter = "LA/Second",
    countHeavyAttacks = false,
    showOnlyInCombat = true,
    isLocked = false,
    fontName = "EsoUI/Common/Fonts/Univers67.otf",
    fontSize = 72,
    msFontSize = 25,
    fontOutline = "thick-outline",
    fontColor = {r = 255, g = 255, b = 255, a = 255},
    debug = false
}


-------------------------------------
-- Initialize the addon.
-------------------------------------
function LightAttackHelper.OnAddOnLoaded(event, addonName)
    if addonName == LightAttackHelper.name then
        LightAttackHelper:Initialize()
        EVENT_MANAGER:UnregisterForEvent(LightAttackHelper.name, EVENT_ADD_ON_LOADED)
    end
end


-------------------------------------
-- Load saved variables and register the event listeners.
-------------------------------------
function LightAttackHelper:Initialize()
    LightAttackHelper.savedVariables = ZO_SavedVars:NewAccountWide("LightAttackHelperVars", LightAttackHelper.variableVersion, nil, LightAttackHelper.Default)
    LightAttackHelper.CreateSettingsWindow()

    LightAttackHelper.isFrontbarRanged = LightAttackHelper.isRangedWeapon(EQUIP_SLOT_MAIN_HAND)
    LightAttackHelper.isBackbarRanged = LightAttackHelper.isRangedWeapon(EQUIP_SLOT_BACKUP_MAIN)

    LightAttackHelper.onActionSlotsFullUpdate(nil, true)
    LightAttackHelper.SetPosition()

    LightAttackHelper.onPlayerCombatState(nil, IsUnitInCombat("player")) -- Prevent errors if the player is already in combat when the addon loads

    EVENT_MANAGER:RegisterForEvent(LightAttackHelper.name, EVENT_COMBAT_EVENT, LightAttackHelper.onCombatEvent)
    EVENT_MANAGER:AddFilterForEvent(LightAttackHelper.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    EVENT_MANAGER:AddFilterForEvent(LightAttackHelper.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_IS_ERROR, false)


    EVENT_MANAGER:RegisterForEvent(LightAttackHelper.name, EVENT_PLAYER_COMBAT_STATE, LightAttackHelper.onPlayerCombatState)
    EVENT_MANAGER:RegisterForEvent(LightAttackHelper.name, EVENT_ACTION_SLOTS_FULL_UPDATE, LightAttackHelper.onActionSlotsFullUpdate)
    --EVENT_MANAGER:RegisterForEvent(LightAttackHelper.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, LightAttackHelper.onInventorySingleSlotUpdate)
    --EVENT_MANAGER:RegisterForEvent(LightAttackHelper.name, EVENT_ACTION_SLOT_ABILITY_USED, LightAttackHelper.onActionSlotAbilityUsed)


    local function stateChange(oldState, newState)
        if newState == SCENE_SHOWN then
            LightAttackHelper.updateShowingCounterOnCombatChange()
        end
    end
    LightAttackHelper.fragment = ZO_HUDFadeSceneFragment:New(LightAttackHelperWindow)
    HUD_SCENE:AddFragment(LightAttackHelper.fragment)
    HUD_SCENE:RegisterCallback("StateChange", stateChange)
    HUD_UI_SCENE:AddFragment(LightAttackHelper.fragment)
    --HUD_UI_SCENE:RegisterCallback("StateChange", stateChange)

    LightAttackHelper.updateFont()
    LightAttackHelperWindowLabel:SetColor(LightAttackHelper.savedVariables.fontColor.r,LightAttackHelper.savedVariables.fontColor.g,LightAttackHelper.savedVariables.fontColor.b,LightAttackHelper.savedVariables.fontColor.a)
    LightAttackHelperWindowInfo:SetColor(LightAttackHelper.savedVariables.fontColor.r,LightAttackHelper.savedVariables.fontColor.g,LightAttackHelper.savedVariables.fontColor.b,LightAttackHelper.savedVariables.fontColor.a)

    LightAttackHelper.setCounter(0)

    LightAttackHelper.updateVisibility()
    LightAttackHelper.updateShowingCounterOnCombatChange()
    LightAttackHelper.updateRatio(false)
    LightAttackHelperWindowLabelBG:SetMouseEnabled(not LightAttackHelper.savedVariables.isLocked)

    LightAttackHelper.initializeSlashCommands()
end


-------------------------------------------------------------------------------------------------
--  Settings menu creation.
-------------------------------------------------------------------------------------------------
function LightAttackHelper.CreateSettingsWindow()
    local panelData = {
        type = "panel",
        name = "Light Attack Helper",
        displayName = "Light Attack Helper",
        author = "Kafeijao",
        version = LightAttackHelper.version,
        slashCommand = LightAttackHelper.slashComandName .. "config",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsData = {
        [1] = {
            type = "header",
            name = "General"
        },
        [2] = {
            type = "checkbox",
            name = "Lock",
            tooltip = "Locks the current position of the Counter.",
            getFunc = function() return LightAttackHelper.savedVariables.isLocked end,
            setFunc = function(isLocked)
                LightAttackHelper.savedVariables.isLocked = isLocked
                LightAttackHelperWindowLabelBG:SetMouseEnabled(not isLocked)
                LightAttackHelper.onPlayerCombatState()
            end,
            default = LightAttackHelper.Default.isLocked,
            width = "full",
        },
        [3] = {
            type = "checkbox",
            name = "Show only Combat",
            tooltip = "Shows the counter only when in combat. (Only works if the counter is Locked)",
            getFunc = function() return LightAttackHelper.savedVariables.showOnlyInCombat end,
            setFunc = function(value)
                LightAttackHelper.savedVariables.showOnlyInCombat = value
                LightAttackHelper.onPlayerCombatState()
            end,
            default = LightAttackHelper.Default.showOnlyInCombat,
            width = "full",
            disabled = function() return not LightAttackHelper.savedVariables.isLocked end
        },
        [4] = {
            type = "checkbox",
            name = "Count Heavy Attacks",
            tooltip = "Should it register in the counter the heavy attacks aswell.",
            getFunc = function() return LightAttackHelper.savedVariables.countHeavyAttacks end,
            setFunc = function(value) LightAttackHelper.savedVariables.countHeavyAttacks = value end,
            default = LightAttackHelper.Default.countHeavyAttacks,
            width = "full",
        },


        [5] = {
            type = "header",
            name = "Light Attack Counter"
        },
        [6] = {
            type = "checkbox",
            name = "Disable",
            tooltip = "Hides the light attack counter on all classes.",
            getFunc = function() return LightAttackHelper.savedVariables.hideCounter end,
            setFunc = function(value)
                LightAttackHelper.savedVariables.hideCounter = value
                LightAttackHelper.updateVisibility()
            end,
            default = LightAttackHelper.Default.hideCounter,
            width = "full",
        },
        [7] = {
            type = "checkbox",
            name = "Disable just on Nightblades",
            tooltip = "Hides the light attack counter on nightblades.",
            getFunc = function() return LightAttackHelper.savedVariables.hideCounterOnNightBlades end,
            setFunc = function(value)
                LightAttackHelper.savedVariables.hideCounterOnNightBlades = value
                LightAttackHelper.updateVisibility()
            end,
            default = LightAttackHelper.Default.hideCounterOnNightBlades,
            width = "full"
        },
        [8] = {
            type = "dropdown",
            name = "Reset on",
            tooltip = "When should the light attack counter reset.",
            choices = {"Barswap", "Exit Combat", "Never"},
            getFunc = function() return LightAttackHelper.savedVariables.resetOn end,
            setFunc = function(newValue)
                LightAttackHelper.savedVariables.resetOn = newValue
            end,
            width = "full",
            default = LightAttackHelper.Default.resetOn,
            disabled = function() return LightAttackHelper.savedVariables.hideCounter or (LightAttackHelper.savedVariables.hideCounterOnNightBlades and LightAttackHelper.isPlayerNightblade) end
        },


        [9] = {
            type = "header",
            name = "Light Attacks / Second"
        },
        [10] = {
            type = "checkbox",
            name = "Disable",
            tooltip = "Disables the light attacks / second on all classes.",
            getFunc = function() return LightAttackHelper.savedVariables.hideRatio end,
            setFunc = function(value)
                LightAttackHelper.savedVariables.hideRatio = value
                LightAttackHelper.updateVisibility()
            end,
            default = LightAttackHelper.Default.hideRatio,
            width = "full",
        },
        [11] = {
            type = "checkbox",
            name = "Disable just on Nightblades",
            tooltip = "Disables the light attacks / second on nightblades.",
            getFunc = function() return LightAttackHelper.savedVariables.hideRatioOnNightBlades end,
            setFunc = function(value)
                LightAttackHelper.savedVariables.hideRatioOnNightBlades = value
                LightAttackHelper.updateVisibility()
            end,
            default = LightAttackHelper.Default.hideRatioOnNightBlades,
            width = "full"
        },
        [12] = {
            type = "dropdown",
            name = "To display below counter:",
            tooltip = "What should be displayed under the counter.",
            choices = {"LA/Second", "Time between LA"},
            getFunc = function() return LightAttackHelper.savedVariables.displayedUnderTheCounter end,
            setFunc = function(newValue)
                LightAttackHelper.savedVariables.displayedUnderTheCounter = newValue
                LightAttackHelper.updateRatio(false)
            end,
            width = "full",
            default = LightAttackHelper.Default.displayedUnderTheCounter,
            disabled = function() return LightAttackHelper.savedVariables.hideRatio or (LightAttackHelper.savedVariables.hideRatioOnNightBlades and LightAttackHelper.isPlayerNightblade) end
        },


        [13] = {
            type = "header",
            name = "Chat Stats"
        },
        [14] = {
            type = "dropdown",
            name = "Automatically print Light Attacks/second on:",
            tooltip = "Where to automatically print the light attack / second ratio.",
            choices = {"Player Houses", "Nowhere", "Everywhere"},
            getFunc = function() return LightAttackHelper.savedVariables.printRationAutomaticallyIn end,
            setFunc = function(newValue)
                LightAttackHelper.savedVariables.printRationAutomaticallyIn = newValue
            end,
            width = "full",
            default = LightAttackHelper.Default.printRationAutomaticallyIn,
        },


        [15] = {
            type = "header",
            name = "Font",
        },
        [16] = {
            type = "dropdown",
            name = "Name",
            tooltip = "Font Name to be used by the counter.",
            choices = {"Univers57", "Univers67", "Univers57", "FTN47", "FTN57", "FTN87", "ProseAntiquePSMT", "Handwritten_Bold", "TrajanPro-Regular"},
            getFunc = function() return string.match(LightAttackHelper.savedVariables.fontName, "([^\/.]+)\.[^.]*$") end,
            setFunc = function(newValue)
                LightAttackHelper.savedVariables.fontName = "EsoUI/Common/Fonts/" .. newValue .. ".otf"
                LightAttackHelper.updateFont()
            end,
            width = "full",
            default = string.match(LightAttackHelper.Default.fontName, "([^\/.]+)\.[^.]*$"),
        },
        [17] = {
            type = "slider",
            name = "Counter Size",
            tooltip = "Font Size to be used by the counter.",
            min = 20,
            max = 72,
            step = 1,
            getFunc = function() return LightAttackHelper.savedVariables.fontSize end,
            setFunc = function(newValue)
                LightAttackHelper.savedVariables.fontSize = newValue
                LightAttackHelper.updateFont()
            end,
            width = "full",
            default = LightAttackHelper.Default.fontSize,
        },
        [18] = {
            type = "slider",
            name = "Light Attacks / s Size",
            tooltip = "Font Size to be used by the milliscond info.",
            min = 10,
            max = 50,
            step = 1,
            getFunc = function() return LightAttackHelper.savedVariables.msFontSize end,
            setFunc = function(newValue)
                LightAttackHelper.savedVariables.msFontSize = newValue
                LightAttackHelper.updateFont()
            end,
            width = "full",
            default = LightAttackHelper.Default.msFontSize,
        },
        [19] = {
            type = "dropdown",
            name = "Outline",
            tooltip = "Font Outline to be used by the counter.",
            choices = {"thick-outline", "soft-shadow-thick", "soft-shadow-thin", "none" },
            getFunc = function() return LightAttackHelper.savedVariables.fontOutline or "none" end,
            setFunc = function(newValue)
                if newValue == "none" then newValue = nil end
                LightAttackHelper.savedVariables.fontOutline = newValue
                LightAttackHelper.updateFont()
            end,
            width = "full",
            default = LightAttackHelper.Default.fontOutline,
        },
        [20] = {
            type = "colorpicker",
            name = "Color",
            tooltip = "Font Color to be used by the counter.",
            getFunc = function() return LightAttackHelper.savedVariables.fontColor.r,LightAttackHelper.savedVariables.fontColor.g,LightAttackHelper.savedVariables.fontColor.b,LightAttackHelper.savedVariables.fontColor.a end,
            setFunc = function(r, g, b, a)
                LightAttackHelper.savedVariables.fontColor = {r=r, g=g, b=b, a=a }
                LightAttackHelperWindowLabel:SetColor(r, g, b, a)
                LightAttackHelperWindowInfo:SetColor(r, g, b, a)
            end,
            width = "full",
            default = LightAttackHelper.Default.fontColor,
        },
        [21] = {
            type = "header",
            name = "Commands",
        },
        [22] = {
            type = "description",
            text = "|ce0a22f/laprint|r - Prints the last combat's light attack / s ratio.\n" ..
                   "|ce0a22f/laprintfull|r - Prints the last combat's full statisctics.\n" ..
                   "|ce0a22f/lapost|r - Posts to the chat the last combat's light attack / s ratio (send to people).\n" ..
                   "|ce0a22f/lapostfull|r - Posts to the chat the last combat's full statisctics (send to people).\n" ..
                   "|ce0a22f/lareset|r - Resets the light attack counter to 0.\n",
        },
        [23] = {
            type = "header",
            name = "Debug",
        },
        [24] = {
            type = "checkbox",
            name = "Debug Mode",
            tooltip = "Enables ddebug mode.",
            getFunc = function() return LightAttackHelper.savedVariables.debug end,
            setFunc = function(value)
                LightAttackHelper.savedVariables.debug = value
                LightAttackHelper.updateVisibility()
            end,
            default = LightAttackHelper.Default.debug,
            width = "full"
        }
    }

    local panel = LAM2:RegisterAddonPanel("Light_Attack_Helper", panelData)
    LAM2:RegisterOptionControls("Light_Attack_Helper", optionsData)

    local function updateWindow()
        LightAttackHelper.updateShowingCounterOnCombatChange()
        LightAttackHelper.SetPosition()
    end

    local function showWindow(currentPanel)
        if currentPanel == panel then
            LightAttackHelperWindowLabelBG:ClearAnchors()
            LightAttackHelperWindowLabelBG:SetAnchor(LEFT, LAMAddonSettingsWindow, RIGHT, 50, 0)
            LightAttackHelperWindow:SetHidden(false)
        end
    end

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", showWindow)
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", updateWindow)
end

-------------------------------------
-- Slash commands listeners.
-------------------------------------
function LightAttackHelper.initializeSlashCommands()
    SLASH_COMMANDS[LightAttackHelper.slashComandName .. "reset"] = function() LightAttackHelper.setCounter(0) end
    SLASH_COMMANDS[LightAttackHelper.slashComandName .. "print"] = LightAttackHelper.printStatsToChat
    SLASH_COMMANDS[LightAttackHelper.slashComandName .. "printfull"] = LightAttackHelper.printFullStatsToChat
    SLASH_COMMANDS[LightAttackHelper.slashComandName .. "post"] = LightAttackHelper.postStatsToChat
    SLASH_COMMANDS[LightAttackHelper.slashComandName .. "postfull"] = LightAttackHelper.postFullStatsToChat
end

--------------------------------------
-- Check if hash table contains value.
--------------------------------------
function LightAttackHelper.tableHasValue(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

-------------------------------------
-- Save the position for the counter.
------------------------------------
function LightAttackHelper.SavePosition()
    LightAttackHelper.savedVariables.left = LightAttackHelperWindowLabelBG:GetLeft()
    LightAttackHelper.savedVariables.top = LightAttackHelperWindowLabelBG:GetTop()
end


-------------------------------------
-- Update visibility of the UI.
------------------------------------
function LightAttackHelper.updateVisibility()

    if LightAttackHelper.isPlayerNightblade then
        LightAttackHelperWindowLabel:SetHidden(LightAttackHelper.savedVariables.hideCounterOnNightBlades)
        LightAttackHelperWindowInfo:SetHidden(LightAttackHelper.savedVariables.hideRatioOnNightBlades)
        LightAttackHelperWindow:SetHidden(LightAttackHelper.savedVariables.hideCounterOnNightBlades and LightAttackHelper.savedVariables.hideRatioOnNightBlades)
    else

        LightAttackHelperWindowLabel:SetHidden(LightAttackHelper.savedVariables.hideCounter)
        LightAttackHelperWindowInfo:SetHidden(LightAttackHelper.savedVariables.hideRatio)
        LightAttackHelperWindow:SetHidden(LightAttackHelper.savedVariables.hideCounter and LightAttackHelper.savedVariables.hideRatio)
    end
end


-------------------------------------
-- Set the position for the counter.
------------------------------------
function LightAttackHelper.SetPosition(left, top)

    if left == nil or top == nil then
        left = LightAttackHelper.savedVariables.left
        top = LightAttackHelper.savedVariables.top
    end

    LightAttackHelperWindowLabelBG:ClearAnchors()
    LightAttackHelperWindowLabelBG:SetAnchor(TOPLEFT, LightAttackHelperWindow, CENTER, left, top)
end


-------------------------------------
-- Sets the counter to a certain number.
------------------------------------
function LightAttackHelper.setCounter(num)
    LightAttackHelper.LightAttackCounter = num
    LightAttackHelperWindowLabel:SetText(num)
end


-------------------------------------
-- Updates the Ratio info.
------------------------------------
do
    local lastLA = GetGameTimeMilliseconds()
    function LightAttackHelper.updateRatio(counts)

        local wasFirstLA = false
        local msValue

        if counts then
            if not LightAttackHelper.shotFirstLightAttack then
                wasFirstLA = true
                LightAttackHelper.shotFirstLightAttack = true
                lastLA = GetGameTimeMilliseconds()
                LightAttackHelper.msNumbers = {}

            else
                local thisLA = GetGameTimeMilliseconds()
                msValue = thisLA - lastLA
                table.insert(LightAttackHelper.msNumbers, msValue)
                lastLA = thisLA
            end
        end

        LightAttackHelperWindowInfo:SetText("")

        if LightAttackHelper.savedVariables.displayedUnderTheCounter == "LA/Second" then

            if LightAttackHelper.combatStartedTimeMs == nil then
                LightAttackHelperWindowInfo:SetText("∞ la/s")
            else

                local combatDuration = GetGameTimeMilliseconds() - LightAttackHelper.combatStartedTimeMs
                local laRatio = string.format("%.2f", 1000 * (#LightAttackHelper.msNumbers + 1) / combatDuration) .. " la/s"
                LightAttackHelperWindowInfo:SetText(laRatio)
            end

        elseif LightAttackHelper.savedVariables.displayedUnderTheCounter == "Time between LA" then
            if not wasFirstLA and msValue ~= nil then
                local msValueText
                if msValue > 10000 then
                    msValueText = "10+ s"
                else
                    msValueText = tostring(msValue) .. " ms"
                end
                LightAttackHelperWindowInfo:SetText(msValueText)
            else

                LightAttackHelperWindowInfo:SetText("0 ms")
            end
        end

    end
end


-------------------------------------
-- Post the full statistics to chat's text area.
-------------------------------------
function LightAttackHelper.postFullStatsToChat()
    if #LightAttackHelper.msNumbers == 0 or LightAttackHelper.lastCombatDuration == nil then chat:Print(" - Error, there is no data to print statistics or still in combat.") return end
    local src = LightAttackHelper.msNumbers
    local max, min = LightAttackHelper.statsFunction.maxmin(src)

    local outputString = "[Light Attack Helper] "

    outputString = outputString .. " || Average time between LA: " .. string.format("%.1f", LightAttackHelper.statsFunction.mean(src)) .. " ms" -- It's actually the Mean, but people understand better like this xD
    outputString = outputString .. " || Lowest/Highest: " .. min .. "/" .. max .. " ms"
    outputString = outputString .. " || Count: " .. #src + 1 .. " Light Attacks || Duration: " .. string.format("%.2f",LightAttackHelper.lastCombatDuration/1000) .. " seconds"
    outputString = outputString .. " || Ratio: " .. string.format("%.2f", 1000 * (#src + 1) / LightAttackHelper.lastCombatDuration) .. " Light Attacks / second ||"
    
    StartChatInput(outputString, IsUnitGrouped('player') and CHAT_CHANNEL_PARTY or CHAT_CHANNEL_SAY, nil)
    --local channel = IsUnitGrouped('player') and "/p " or "/say "
    --CHAT_SYSTEM.textEntry:SetText( channel .. outputString )
    --CHAT_SYSTEM:Maximize()
    --CHAT_SYSTEM.textEntry:Open()
end


-------------------------------------
-- Post the statistics to chat's text area.
-------------------------------------
function LightAttackHelper.postStatsToChat()
    if #LightAttackHelper.msNumbers == 0 or LightAttackHelper.lastCombatDuration == nil then chat:Print(" - Error, there is no data to print statistics or still in combat.") return end
    local src = LightAttackHelper.msNumbers

    local outputString = "[Light Attack Helper] " .. string.format("%.2f", 1000 * (#LightAttackHelper.msNumbers + 1) / LightAttackHelper.lastCombatDuration) .. " Light Attacks / second"
    outputString = outputString .. " (" .. string.format("%.2f",LightAttackHelper.lastCombatDuration/1000) .. " seconds)"

   -- local channel = IsUnitGrouped('player') and "/p " or "/say "
    --CHAT_SYSTEM.textEntry:SetText( channel .. outputString )
    --CHAT_SYSTEM:Maximize()
    StartChatInput(outputString, IsUnitGrouped('player') and CHAT_CHANNEL_PARTY or CHAT_CHANNEL_SAY, nil)
   -- CHAT_SYSTEM.textEntry:Open()
end


-------------------------------------
-- Prints the full statistics to chat's text area.
-------------------------------------
function LightAttackHelper.printFullStatsToChat()
    if #LightAttackHelper.msNumbers == 0 then chat:Print(" - Error, there is no data to print statistics.") return end
    local src = LightAttackHelper.msNumbers
    local max, min = LightAttackHelper.statsFunction.maxmin(src)

    chat:Print(" ----- |ce0a22fL|right |ce0a22fA|rttack Helper Stats ---------------------- ")
    chat:Print(" || Average time between LA:  |cffffff" .. string.format("%.1f", LightAttackHelper.statsFunction.mean(src)) .. "|r ms") -- It's actually the Mean, but people understand better like this xD
    chat:Print(" || Lowest/Highest: |cffffff" .. min .. "|r/|cffffff" .. max .. "|r ms")

    if LightAttackHelper.lastCombatDuration ~= nil then
        chat:Print(" || Count: |cffffff" .. #src + 1 .. "|r Light Attacks || Duration: |cffffff" .. string.format("%.2f",LightAttackHelper.lastCombatDuration/1000) .. "|r seconds")
        chat:Print(" || Ratio: |cffffff" .. string.format("%.2f", 1000 * (#src + 1) / LightAttackHelper.lastCombatDuration) .. "|r Light Attacks / second")
    else
        chat:Print(" || Ratio: Still in combat...")
        chat:Print(" || Count: |cffffff" .. #src + 1 .. "|r Light Attacks || Duration: Still in combat...")
    end
end


-------------------------------------
-- Prints the statistics to chat's text area.
-------------------------------------
function LightAttackHelper.printStatsToChat()
    if #LightAttackHelper.msNumbers == 0 or LightAttackHelper.lastCombatDuration == nil then chat:Print(" - Error, there is no data to print statistics. Report to the Addon creator.") return end
    chat:Print(" |cffffff" .. string.format("%.2f", 1000 * (#LightAttackHelper.msNumbers + 1) / LightAttackHelper.lastCombatDuration) .. "|r Light Attacks / second" .. " (" .. string.format("%.2f",LightAttackHelper.lastCombatDuration/1000) .. " seconds)")
end

-------------------------------------
-- Handler for combat state changes.
------------------------------------
function LightAttackHelper.onPlayerCombatState(_, inCombat)
    if inCombat == false then

        --if LightAttackHelper.combatStartedTimeMs == false then return end -- If addon is started when in combat already

        if LightAttackHelper.savedVariables.resetOn == "Exit Combat" or LightAttackHelper.savedVariables.resetOn == "Barswap" then
            LightAttackHelper.setCounter(0)
        end

        LightAttackHelper.updateRatio(false) -- Update the ratio display
        LightAttackHelper.shotFirstLightAttack = false
        LightAttackHelper.lastCombatDuration = GetGameTimeMilliseconds() - (LightAttackHelper.combatStartedTimeMs or GetGameTimeMilliseconds())
        LightAttackHelper.combatStartedTimeMs = nil

        if LightAttackHelper.savedVariables.printRationAutomaticallyIn ~= "Nowhere" and
          (GetCurrentZoneHouseId() ~= 0 or LightAttackHelper.savedVariables.printRationAutomaticallyIn == "Everywhere") and
           LightAttackHelper.lastCombatDuration ~= nil and #LightAttackHelper.msNumbers > 0
        then
            LightAttackHelper.printStatsToChat()
        end

    else
        LightAttackHelper.combatStartedTimeMs = GetGameTimeMilliseconds()
        LightAttackHelper.lastCombatDuration = nil
    end

    LightAttackHelper.updateShowingCounterOnCombatChange()
end


-------------------------------------
-- Update showing counter or not.
------------------------------------
function LightAttackHelper.updateShowingCounterOnCombatChange()

    if LightAttackHelper.savedVariables.showOnlyInCombat and LightAttackHelper.savedVariables.isLocked then
        local show = not IsUnitInCombat("player")
        if LightAttackHelperWindow:IsHidden() ~= show then
            LightAttackHelperWindow:SetHidden(show)
        end

    else
        if LightAttackHelperWindow:IsHidden() then
            LightAttackHelperWindow:SetHidden(false)
        end
    end
end


function LightAttackHelper.onActionSlotAbilityUsed(eventCode, slotNum)

    --if LightAttackHelper.castingHeavyAttack and LightAttackHelper.usedAbilityDuringHeavyAttack then d("Is casting heavy Attack") return end

    if slotNum >= 3 and slotNum <= 8 then

        if LightAttackHelper.castingHeavyAttack then LightAttackHelper.usedAbilityDuringHeavyAttack = true end

        local abilityName
        if LightAttackHelper.isOnFrontbar then
            abilityName = LightAttackHelper.abilitiesFrontbar[slotNum]
        else
            abilityName = LightAttackHelper.abilitiesBackbar[slotNum]
        end

        chat:Print("ABILITY USED! " .. abilityName)

        zo_callLater(function()
            chat:Print("Timeout! " .. abilityName)
        end, GetLatency()+250 )
    end

    if slotNum == 2 then
        LightAttackHelper.castingHeavyAttack = true
    end

end


function LightAttackHelper.onCombatEvent(_, result, _, abilityName, abilityGraphic, abilityActionSlotType, sourceName, _, _, _, hitValue)
--function LightAttackHelper.onCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    -- eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId
    --[[ debug messages templates
    d("result=" .. tostring(result) .. "; isError=" .. tostring(isError) .. "; abilityName=" .. tostring(abilityName)
            .. "; abilityGraphic=" .. tostring(abilityGraphic) .. "; abilityActionSlotType=" .. tostring(abilityActionSlotType)
            .. "; sourceName=" .. tostring(sourceName) .. "; sourceType=" .. tostring(sourceType) .. "; targetName=" .. tostring(targetName)
            .. "; targetType=" .. tostring(targetType) .. "; hitValue=" .. tostring(hitValue) .. "; powerType=" .. tostring(powerType)
            .. "; damageType=" .. tostring(damageType) .. "; log=" .. tostring(log) .. "; sourceUnitId=" .. tostring(sourceUnitId)
            .. "; targetUnitId=" .. tostring(targetUnitId) .. "; abilityId=" .. tostring(abilityId))
    d("------------")

    d("result=" .. tostring(result) .. "; abilityName=" .. tostring(abilityName)
                .. "; hitValue=" .. tostring(hitValue) .. "; powerType=" .. tostring(powerType)
                .. "; damageType=" .. tostring(damageType) .. "; abilityId=" .. tostring(abilityId))
    d("------------")

    d("result=" .. tostring(result) .. "; abilityName=" .. tostring(abilityName) .. "; hitValue=" .. tostring(hitValue) .. "; abilityGraphic=" .. tostring(abilityGraphic))
    d("------------")
]]

    if abilityActionSlotType == ACTION_SLOT_TYPE_LIGHT_ATTACK then
        if LightAttackHelper.savedVariables.debug then
            chat:Print("[|ce0a22fLDEBUG|r] Light Atttack: " .. "result=" .. tostring(result) .. "; abilityName=" .. tostring(abilityName) .. "; hitValue=" .. tostring(hitValue) .. "; abilityGraphic=" .. tostring(abilityGraphic))
        end

        if LightAttackHelper.playerName == sourceName and zo_plainstrfind(abilityName, GetString(LAH_LIGHT_ATTACK)) and LightAttackHelper.isTheActualAttackCast(hitValue) then

            LightAttackHelper.castingHeavyAttack = false
            LightAttackHelper.usedAbilityDuringHeavyAttack = false

            if LightAttackHelper.savedVariables.debug then chat:Print("[|ce0a22fLDEBUG|r] Light Attack: Triggered!") end

            LightAttackHelper.setCounter(LightAttackHelper.LightAttackCounter + 1)
            LightAttackHelper.updateRatio(true)
        end

        if LightAttackHelper.savedVariables.debug then chat:Print("[|ce0a22fLDEBUG|r] ------------") end

    elseif abilityActionSlotType == ACTION_SLOT_TYPE_HEAVY_ATTACK then

        if LightAttackHelper.savedVariables.debug then
            chat:Print("[|ce0a22fLDEBUG|r] Heavy Atttack: " .. "result=" .. tostring(result) .. "; abilityName=" .. tostring(abilityName) .. "; hitValue=" .. tostring(hitValue) .. "; abilityGraphic=" .. tostring(abilityGraphic))
        end

        if LightAttackHelper.tableHasValue(LightAttackHelper.goodHAResults, result) and LightAttackHelper.playerName == sourceName and zo_plainstrfind(abilityName, GetString(LAH_HEAVY_ATTACK)) and LightAttackHelper.isTheActualAttackCast(hitValue) then

            LightAttackHelper.castingHeavyAttack = false
            LightAttackHelper.usedAbilityDuringHeavyAttack = false

            if LightAttackHelper.savedVariables.countHeavyAttacks then
                LightAttackHelper.setCounter(LightAttackHelper.LightAttackCounter + 1)
                LightAttackHelper.updateRatio(true)
            end

            if LightAttackHelper.savedVariables.debug then chat:Print("[|ce0a22fLDEBUG|r] Heavy Attack: Triggered!") end
        end

        if LightAttackHelper.savedVariables.debug then chat:Print("[|ce0a22fLDEBUG|r] ------------") end
    end


    --[[ Todo: Attempt to check if a skill was used
    elseif abilityActionSlotType == ACTION_SLOT_TYPE_NORMAL_ABILITY then
        -- ACTION_RESULT_EFFECT_GAINED_DURATION 2245 (dots, ground targets, bol)
        -- ACTION_RESULT_KNOCKBACK 2475 ()
        -- ACTION_RESULT_BEGIN 2200 (channeled attacks)
        -- ACTION_RESULT_POWER_ENERGIZE 128 (channeled focus)
        for slotIndex=3,8 do
            if (LightAttackHelper.abilitiesFrontbar ~= nil and LightAttackHelper.abilitiesFrontbar[slotIndex] == abilityName) or
                    (LightAttackHelper.abilitiesBackbar ~= nil and LightAttackHelper.abilitiesBackbar[slotIndex] == abilityName) then
                if      result == ACTION_RESULT_EFFECT_GAINED_DURATION or
                        result == ACTION_RESULT_KNOCKBACK or
                        result == ACTION_RESULT_BEGIN or
                        result == ACTION_RESULT_POWER_ENERGIZE then

                    d("result=" .. tostring(result)
                            .. " | abilityName=" .. tostring(abilityName)
                            .." | powerType=" .. tostring(powerType)

                    )
                    d("------------")
                end
                break
            end
        end
    end
    ]]


    --[[ Todo: Check those action modifiers
    if (result == ACTION_RESULT_BLOCKED or
        result == ACTION_RESULT_DAMAGE_SHIELDED or
        result == ACTION_RESULT_PARRIED or
        result == ACTION_RESULT_REFLECTED or
        result == ACTION_RESULT_IMMUNE)
    then
       --("DMG Immune")
    end

    if (result == ACTION_RESULT_ABSORBED or
        result == ACTION_RESULT_BLOCKED_DAMAGE or
        result == ACTION_RESULT_FALL_DAMAGE or
        result == ACTION_RESULT_PARTIAL_RESIST or
        result == ACTION_RESULT_PRECISE_DAMAGE or
        result == ACTION_RESULT_WRECKING_DAMAGE)
    then
        --d("DMG Absorbed")
    end

    if ( result == ACTION_RESULT_DAMAGE) then
        --d("DMG Normal")
    end

    if ( result == ACTION_RESULT_CRITICAL_DAMAGE) then
        --d("DMG Critical")
    end]]

end


-------------------------------------
-- Register barswaps and initialize abilities if required.
------------------------------------
function LightAttackHelper.onActionSlotsFullUpdate(eventCode, isHotbarSwap)
    if isHotbarSwap then
        LightAttackHelper.castingHeavyAttack = false

        local activeWeaponPair, locked = GetActiveWeaponPairInfo()

        if LightAttackHelper.savedVariables.resetOn == "Barswap" then
            LightAttackHelper.setCounter(0)
        end

        if activeWeaponPair == ACTIVE_WEAPON_PAIR_MAIN then
            --d("BARSWAP to Frontbar")
            LightAttackHelper.isOnFrontbar = true;

            if LightAttackHelper.abilitiesFrontbar == nil then
                LightAttackHelper.initializeBarslots(true)
            end

        elseif activeWeaponPair == ACTIVE_WEAPON_PAIR_BACKUP then
            --d("BARSWAP to Backbar")
            LightAttackHelper.isOnFrontbar = false;

            if LightAttackHelper.abilitiesBackbar == nil then
                LightAttackHelper.initializeBarslots(false)
            end
        end
    end
end


-------------------------------------
-- If an ability is changed update our data on sloted skills.
------------------------------------
function LightAttackHelper.onActionSlotAbilitySlotted(eventCode, slotNum)
    if LightAttackHelper.isOnFrontbar then
        LightAttackHelper.initializeBarslots(true)
    else
        LightAttackHelper.initializeBarslots(false)
    end
end


-------------------------------------
-- If a weapon is swapped update the addon info about that weapon.
------------------------------------
function LightAttackHelper.onInventorySingleSlotUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
    if bagId == BAG_WORN then
        if slotId == EQUIP_SLOT_MAIN_HAND then
            LightAttackHelper.isFrontbarRanged = LightAttackHelper.isRangedWeapon(EQUIP_SLOT_MAIN_HAND)
        elseif slotId == EQUIP_SLOT_BACKUP_MAIN then
            LightAttackHelper.isBackbarRanged = LightAttackHelper.isRangedWeapon(EQUIP_SLOT_BACKUP_MAIN)
        end
    end
end


-------------------------------------
-- Update our data on sloted skills.
------------------------------------
function LightAttackHelper.initializeBarslots(isFrontbar)
    if isFrontbar then
        LightAttackHelper.abilitiesFrontbar = {}
        for slotIndex=3,8 do
            LightAttackHelper.abilitiesFrontbar[slotIndex] = GetSlotName(slotIndex)
        end
    else
        LightAttackHelper.abilitiesBackbar = {}
        for slotIndex=3,8 do
            LightAttackHelper.abilitiesBackbar[slotIndex] = GetSlotName(slotIndex)
        end
    end
end


-------------------------------------
-- Checks if the provided slot is a ranged weapon or not.
------------------------------------
function LightAttackHelper.isRangedWeapon(wornSlot)
    local type = GetItemWeaponType(BAG_WORN, wornSlot)
    if type == WEAPONTYPE_BOW or type == WEAPONTYPE_FIRE_STAFF or type == WEAPONTYPE_FROST_STAFF or type == WEAPONTYPE_HEALING_STAFF or type == WEAPONTYPE_LIGHTNING_STAFF then
        return true
    else
        return false
    end
end


-------------------------------------
-- Changes counter font.
------------------------------------
function LightAttackHelper.updateFont()
    if (LightAttackHelper.savedVariables.fontOutline == nil) then
        LightAttackHelperWindowLabel:SetFont(LightAttackHelper.savedVariables.fontName .. "|" .. LightAttackHelper.savedVariables.fontSize)
        LightAttackHelperWindowInfo:SetFont(LightAttackHelper.savedVariables.fontName .. "|" .. LightAttackHelper.savedVariables.msFontSize)
    else
        LightAttackHelperWindowLabel:SetFont(LightAttackHelper.savedVariables.fontName .. "|" .. LightAttackHelper.savedVariables.fontSize .. "|" ..  LightAttackHelper.savedVariables.fontOutline)
        LightAttackHelperWindowInfo:SetFont(LightAttackHelper.savedVariables.fontName .. "|" .. LightAttackHelper.savedVariables.msFontSize .. "|" ..  LightAttackHelper.savedVariables.fontOutline)
    end
end


-------------------------------------
-- Checks if the light/heavy attack event is the on cast one (to get instant casts and not when it actually hits the target).
-- The ranged LA hits 3 values, starts with hit of value 1, then another for some random low dmg hit, and then the real hit with real dmg (when the attack actually reaches)
-- For some reason it appears that if you animation cancel an LA with a skill, it will proc an extra combat event with 0 hit value, but not really usable because even counts with the bad (too long) animcation canceling
------------------------------------
do
    -- Fix for when player barswap animation cancel a light attack from ranged wep to melee wep
    local previousWas1 = false
    local beforePreviousWas1 = false
    local lastHit = GetGameTimeMilliseconds()

    function LightAttackHelper.isTheActualAttackCast(hitValue)
        --d("LA - ranged: " .. tostring(LightAttackHelper.isFrontbarRanged and LightAttackHelper.isOnFrontbar or LightAttackHelper.isBackbarRanged and not LightAttackHelper.isOnFrontbar) .. ", hit: " .. hitValue)

        if GetGameTimeMilliseconds() < lastHit + 300 then -- Add a buffer to not let HA DB count twice (2 HA/LA inless than 300 is impossible) Kinda hacky but heh
            return false
        end

        if hitValue == 0 then -- Ignore if the damage is zero
            return false

        elseif hitValue == 1 then -- This should only happen when casting a ranged LA
            previousWas1 = true
            return false

        elseif hitValue > 1 then

            if previousWas1 then  -- I will count the second hit from ranged attacks so it counts on ranged bar even if the actual hit hits on the other bar
                previousWas1 = false
                beforePreviousWas1 = true
                lastHit = GetGameTimeMilliseconds()
                return true

            elseif beforePreviousWas1 then -- Ignore the actual hit from a ranged attack, because we counted the previous one
                beforePreviousWas1 = false
                return false

            else -- The regular damage coming from a melee attack
                lastHit = GetGameTimeMilliseconds()
                return true

            end
        end
    end
end


-------------------------------------
-- Initialization Register.
------------------------------------
EVENT_MANAGER:RegisterForEvent(LightAttackHelper.name, EVENT_ADD_ON_LOADED, LightAttackHelper.OnAddOnLoaded)