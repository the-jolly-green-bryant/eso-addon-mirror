------------------------------------
-- SETTINGS, GLOBALS AND DEFAULTS --
------------------------------------
SanitysTracker = {
    name = "SanitysTracker",
    author = "@Duesentrieb",
    version = "20260515-0001",

    SanitysEdgeId = 1427,
    shouldHide = false,
    forceShow = false,
    isAddonActive = false,

    isCombat = false,

    isWarningTextLocked = false,

    -- COMBAT EVENT IDs
    YASEYLA_NEGATION = 183946,
    YASEYLA_CHAIN_PULL = 184545,
    YASEYLA_VANTONS_CLARITY = 184041, -- BUFF ON GROUP BUT DOES NOT WORK ATM

    ANSUUL_VANTON_HACK = 187082,
    ANSUUL_FRAGMENT_FLARE = 183784,
    ANSUUL_RITUAL = 183855,
    ANSUUL_INFERNO = 183778,
    ANSUUL_BOLT = 198003,
    ANSUUL_SUNBURST = 199344,
    ANSUUL_IGNITE_MAZE = 188190,

    ---------------------
    -- BOSS 1: YASEYLA --
    ---------------------
    counterNegation = 0,
    sequenceNegation = 1,

    timePortalStart = 0,
    timePortalEnd = 0,

    isPortal1Active = false,
    isPortal2Active = false,
    isPortal3Active = false,
    isPortal4Active = false,

    isPortal1Done = false,
    isPortal2Done = false,
    isPortal3Done = false,
    isPortal4Done = false,

    wasYaseylaHealthSoundPlayed = false,

    --------------------
    -- BOSS 3: ANSUUL --
    --------------------
    isAnsuul = false,
    isFireMazeDone = false,

    timeAtro1Spawn = 12000,
    timeAtro2Spawn = 12000,
    timeAtro3Spawn = 12000,
    timeAtro4Spawn = 12000,

    timeAtro1FirstCast = 5000,
    timeAtro2FirstCast = 5000,
    timeAtro3FirstCast = 5000,
    timeAtro4FirstCast = 5000,

    ritualOffset = 39000,

    isAtro1Casting = false,
    isAtro2Casting = false,
    isAtro3Casting = false,
    isAtro4Casting = false,

    hasAtro1Casted = false,
    hasAtro2Casted = false,
    hasAtro3Casted = false,
    hasAtro4Casted = false,

    wasInferno1Played = false,
    wasInferno2Played = false,
    wasInferno3Played = false,
    wasInferno4Played = false,

    timeAtro1Inferno = 0.0,
    timeAtro2Inferno = 0.0,
    timeAtro3Inferno = 0.0,
    timeAtro4Inferno = 0.0,

    counterInfernoSpawn = 1,

    counterBolt = 1,
    counterInferno = 1,

    wasHackCasted = false,
    wasRitualCasted = false,
    wasBoltCasted = false,

    isAtroSpawnTimerActive = false,

    timeAnsuulLastIgniteBlame = 0,
    cooldownAnsuulIgniteBlame = 7500,

    infernoData = {},
    boltData = {},
    unitNames = {},


    default = {
        enableAddon = true,
        enableMiscellaneous = true,
        fontSizeWarning = 128,
        offsetWarningX = 0,
        offsetWarningY = -480,
        enableDebug = false,

        ---------------------
        -- BOSS 1: YASEYLA --
        ---------------------
        enableYaselyaHealthWarningText = true,
        volumeYaselyaHealthWarningSound = 10,

        enableYaselyaPortalWarningText = true,
        enableYaselyaPortalChatText = true,

        enableYaselyaPortalPanel = true,
        volumeYaselyaPortalDoneSound = 10,
        thresholdYaselyaPortal = 1,
        fontSizeYaselyaPortal = 20,

        offsetYaselyaPortalX = 480,
        offsetYaselyaPortalY = 480,

        enableYaseylaChainWarningText = true,
        volumeYaseylaChainWarningSound = 0,

        ---------------------
        -- BOSS 2: CHIMERA --
        ---------------------


        --------------------
        -- BOSS 3: ANSUUL --
        --------------------
        enableAnsuulIgniteBlame = true,

        enableInfernoPanel = true,
        fontSizeTrackerInferno = 20,
        offsetInfernoX = 480,
        offsetInfernoY = 480,
        volumeAnsuulInfernoSpawningSound = 10,
        volumeAnsuulInfernoCastingSound = 10,

        enableBoltPanel = true,
        fontSizeTrackerBolt = 20,
        offsetBoltX = 480,
        offsetBoltY = 640,

        enableAnsuulSunburstWarningText = true,
        enableAnsuulSunburstScreenBorderColor = true,
        volumeAnsuulSunburstWarningSound = 10,
    },

    SV = {},
    SVVersion = 3,
    SVName = "SanitysTrackerVariables",
}

local ST = SanitysTracker

------------------
-- DEBUG OUTPUT --
------------------
function SanitysTracker.debug(message)
    if not message or message == "" then return end
    if not ST.SV.enableDebug then return end

    message = tostring(message)

    local colorName = "|c00BFFF"
    local name = ST.name
    local colorMessage = "|c7FBFFF"
    local formattedMessage = string.format("%s[%s]|r %s%s|r", colorName, name, colorMessage, message)
    d(formattedMessage)
end


--------------------------------------------
-- CHECK EVERY 1000MS - MAIN TRACKER LOOP --
--------------------------------------------
function SanitysTracker.TrackerLoop()
    local bossName = GetUnitName("boss1")

    ---------------------------------------------------
    -- ENABLE THE GENERAL WARNING PANEL WHEN IN RAID --
    ---------------------------------------------------
    if not ST.shouldHide then
        SanitysTrackerWarning:SetHidden(false)
    end

    ----------------------------------------
    -- CHECK IF WE ARE AT BOSS 1: YASEYLA --
    ----------------------------------------
    if (bossName == "Exarchanic Yaseyla")
    or (bossName == "Exarchanikerin Yaseyla") then
    --or (bossName == "Heiliger Olms der Gerechte") then
        ST.isYaselya = true
        ST.CheckYaseylaHealth()
    else
        ST.isYaselya = false
    end

    ----------------------------------------
    -- CHECK IF WE ARE AT BOSS 2: CHIMERA --
    ----------------------------------------
    -- TO BE DONE

    ---------------------------------------
    -- CHECK IF WE ARE AT BOSS 3: ANSUUL --
    ---------------------------------------
    if (bossName == "Ansuul the Tormentor")
    or (bossName == "Ansuul die Quälende") then
    --or (bossName == "Heiliger Olms der Gerechte") then
        ST.isAnsuul = true
        ST.CheckAnsuulHealth()
    else
        ST.isAnsuul = false
    end

    ----------------------------------------
    -- ENABLE YASELYA PANEL IF AT YASEYLA --
    ----------------------------------------
    if ST.isYaselya and not ST.shouldHide then
        SanitysTrackerPortal:SetHidden(not ST.SV.enableYaselyaPortalPanel)
    elseif not ST.forceShow then
        SanitysTrackerPortal:SetHidden(true)
    end

    --------------------------------------
    -- ENABLE ANSUUL PANEL IF AT ANSUUL --
    --------------------------------------
    if ST.isAnsuul and not ST.shouldHide then
        SanitysTrackerInferno:SetHidden(not ST.SV.enableInfernoPanel)
        SanitysTrackerBolt:SetHidden(not ST.SV.enableBoltPanel)
    elseif not ST.forceShow then
        SanitysTrackerInferno:SetHidden(true)
        SanitysTrackerBolt:SetHidden(true)
    end

    --------------------------------------------
    -- ATROS CASTING - CHECK AND UPDATE TIMER --
    --------------------------------------------
    if (ST.isAtro1Casting == true) then
        ST.timeAtro1Inferno = ST.timeAtro1Inferno + 1000
    end
    if (ST.isAtro2Casting == true) then
        ST.timeAtro2Inferno = ST.timeAtro2Inferno + 1000
    end
    if (ST.isAtro3Casting == true) then
        ST.timeAtro3Inferno = ST.timeAtro3Inferno + 1000
    end
    if (ST.isAtro4Casting == true) then
        ST.timeAtro4Inferno = ST.timeAtro4Inferno + 1000
    end

    -----------------------------------------------------------------
    -- KEEP UPDATING WITH EVENT MANGER WHILE isAddonActive IS TRUE --
    -----------------------------------------------------------------
    if ST.isAddonActive then
        EVENT_MANAGER:RegisterForUpdate(ST.name.."TrackerLoop", 1000, ST.TrackerLoop)
    else
        EVENT_MANAGER:UnregisterForUpdate(ST.name.."TrackerLoop")
    end
end


------------------------------------------------------------------
-- RESETS ALL YASELYA VARIABLES (NOT SAVED ONES) AFTER WIPE ETC --
------------------------------------------------------------------
function SanitysTracker.ResetYaselyaVariables()
    ST.counterNegation = 0
    ST.sequenceNegation = 0

    ST.isPortal1Active = false
    ST.isPortal2Active = false
    ST.isPortal3Active = false
    ST.isPortal4Active = false

    SanitysTrackerWarningLabel:SetText("")

    SanitysTrackerPortalTitle:SetText("|cff7f00Sanitys Tracker|r |cffffffPortal|r")
    SanitysTrackerPortalLabel1:SetText("-")
    SanitysTrackerPortalLabel2:SetText("-")
    SanitysTrackerPortalLabel3:SetText("-")
    SanitysTrackerPortalLabel4:SetText("-")
end


-----------------------------------------------------------------
-- RESETS ALL ANSUUL VARIABLES (NOT SAVED ONES) AFTER WIPE ETC --
-----------------------------------------------------------------
function SanitysTracker.ResetAnsuulVariables()
    ST.timeAtro1Spawn = 12000
    ST.timeAtro2Spawn = 12000
    ST.timeAtro3Spawn = 12000
    ST.timeAtro4Spawn = 12000

    ST.timeAtro1FirstCast = 5000
    ST.timeAtro2FirstCast = 5000
    ST.timeAtro3FirstCast = 5000
    ST.timeAtro4FirstCast = 5000

    ST.isAtro1Casting = false
    ST.isAtro2Casting = false
    ST.isAtro3Casting = false
    ST.isAtro4Casting = false

    ST.wasInferno1Played = false
    ST.wasInferno2Played = false
    ST.wasInferno3Played = false
    ST.wasInferno4Played = false

    ST.timeAtro1Inferno = 0.0
    ST.timeAtro2Inferno = 0.0
    ST.timeAtro3Inferno = 0.0
    ST.timeAtro4Inferno = 0.0

    ST.counterInfernoSpawn = 1

    ST.counterBolt = 1
    ST.counterInferno = 1

    ST.wasHackCasted = false
    ST.wasBoltCasted = false

    ST.isAtroSpawnTimerActive = false

    ST.infernoData = {}
    ST.boltData = {}

    SanitysTrackerWarningLabel:SetText("")

    SanitysTrackerInfernoTitle:SetText("|cff7f00Sanitys Tracker|r |cffffffInferno|r")
    SanitysTrackerInfernoLabel1:SetText("-")
    SanitysTrackerInfernoLabel2:SetText("-")
    SanitysTrackerInfernoLabel3:SetText("-")
    SanitysTrackerInfernoLabel4:SetText("-")

    SanitysTrackerBoltTitle:SetText("|cff7f00Sanitys Tracker|r |cffffffBolt / Imp|r")
    SanitysTrackerBoltLabel1:SetText("-")
    SanitysTrackerBoltLabel2:SetText("-")
    SanitysTrackerBoltLabel3:SetText("-")
    SanitysTrackerBoltLabel4:SetText("-")
end


------------------------------------------------
-- SCENE CHANGE (HIDE ADDON WHEN IN MENU ETC) --
------------------------------------------------
function SanitysTracker.SceneChange(_, scene)
    -----------------------
    -- NOT IN MENU: SHOW --
    -----------------------
    if scene == SCENE_SHOWN then
        ST.shouldHide = false

        -- GENERAL
        SanitysTrackerWarning:SetHidden(false)

        ---------------------
        -- BOSS 1: YASEYLA --
        ---------------------
        if ST.isYaselya then
            SanitysTrackerPortal:SetHidden(not ST.SV.enableYaselyaPortalPanel)
        end

        --------------------
        -- BOSS 3: ANSUUL --
        --------------------
        if ST.isAnsuul then
            SanitysTrackerInferno:SetHidden(not ST.SV.enableInfernoPanel)
            SanitysTrackerBolt:SetHidden(not ST.SV.enableBoltPanel)
        end
    -----------------------------------
    -- IN MENU: HIDE ALL UI ELEMENTS --
    -----------------------------------
    else
        ST.shouldHide = true

        if not ST.forceShow then
            SanitysTrackerWarning:SetHidden(true)
            SanitysTrackerPortal:SetHidden(true)
            SanitysTrackerInferno:SetHidden(true)
            SanitysTrackerBolt:SetHidden(true)
        end
    end
end


------------------
-- COMBAT STATE --
------------------
function SanitysTracker.OnCombatStateChange(eventCode, inCombat)
    if not inCombat then
        ST.unitNames = {}
        --/script d(SanitysTracker.unitNames)
    end
end


----------------------
-- ENABLE THE ADDON --
----------------------
function SanitysTracker.Enable()
    EVENT_MANAGER:RegisterForEvent(ST.name.."EVENT_COMBAT_EVENT", EVENT_COMBAT_EVENT, ST.CombatEvent)
    EVENT_MANAGER:RegisterForEvent(ST.name.."EVENT_COMBAT_STATE", EVENT_PLAYER_COMBAT_STATE, ST.OnCombatStateChange)

    SCENE_MANAGER:GetScene("hud"):RegisterCallback("StateChange", ST.SceneChange)
    SCENE_MANAGER:GetScene("hudui"):RegisterCallback("StateChange", ST.SceneChange)

    if not ST.isAddonActive then
        d("|cff7f00[SanitysTracker]|r |c00ff00Enabled|r")
        ST.isAddonActive = true
    end

    -- CALL TRACKER LOOP ONCE TO BEGIN - WILL KEEP RUNNING
    ST.TrackerLoop()
end


-----------------------
-- DISABLE THE ADDON --
-----------------------
function SanitysTracker.Disable()
    EVENT_MANAGER:UnregisterForEvent(ST.name.."EVENT_COMBAT_EVENT", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(ST.name.."EVENT_COMBAT_STATE", EVENT_PLAYER_COMBAT_STATE)

    ST.ResetYaselyaVariables()
    ST.ResetAnsuulVariables()

    SanitysTrackerWarning:SetHidden(true)
    SanitysTrackerPortal:SetHidden(true)
    SanitysTrackerInferno:SetHidden(true)
    SanitysTrackerBolt:SetHidden(true)

    if ST.isAddonActive then
        d("|cff7f00[SanitysTracker]|r |cff0000Disabled|r")
    end
    ST.isAddonActive = false
end


------------------------------------
--- ZONE-CHECK FOR ENABLE/DISABLE --
------------------------------------
function SanitysTracker.CheckZone()
    local zone = GetZoneId(GetUnitZoneIndex("player"))

    if (zone == ST.SanitysEdgeId and ST.SV.enableAddon) then
        if not ST.isAddonActive then
            ST.Enable()
        end
    else
        ST.Disable()
    end
end


-------------------------------------
-- RESET IN CASE OF A WIPE / CLEAR --
-------------------------------------
function SanitysTracker.CheckAnsuulHealth()
    local current, max, effective = GetUnitPower("boss1", POWERTYPE_HEALTH)

    if max == nil or max == 0 then return end
    local percentageHealth = 100 / max * current

    if ((percentageHealth > 99) and (max > 140000000)) then
        ST.ResetAnsuulVariables()
        ST.infernoData = {}
        ST.isFireMazeDone = false
    end

    if ((percentageHealth <= 1) and (max > 140000000)) then
        zo_callLater(function() ST.ResetAnsuulVariables() end, 5000)
        ST.infernoData = {}
        ST.isFireMazeDone = false
    end
end


----------------------------------------------------
-- CHECK IF YASEYLA HEALTH IS CLOSE TO THRESHOLDS --
----------------------------------------------------
function SanitysTracker.CheckYaseylaHealth()
    local current, max, effective = GetUnitPower("boss1", POWERTYPE_HEALTH)

    if max == nil or max == 0 then return end
    local percentageHealth = 100 / max * current

    -- PORTAL AT 60.00% --> SLOW AT 64% (PORTAL)
    -- PORTAL AT 35.00% --> SLOW AT 39% (PORTAL)
    -- EXECUTE at 26.00% --> STOP AT 30% (FOCUS WAMASU)
    if (percentageHealth <= 64 and percentageHealth >= 59 or
        percentageHealth <= 39 and percentageHealth >= 34 or
        percentageHealth <= 30 and percentageHealth >= 25) then
        if (ST.wasYaseylaHealthSoundPlayed == false) then
            ST.PlayYaseylaHealthWarningSound()
            ST.wasYaseylaHealthSoundPlayed = true
        end

        local percentageHealthText = string.format("%.2f%%", percentageHealth)
        if not ST.isWarningTextLocked and ST.SV.enableYaselyaHealthWarningText then
            SanitysTrackerWarningLabel:SetText(percentageHealthText)
        end
    else
        if not ST.forceShow and not ST.isWarningTextLocked then
            SanitysTrackerWarningLabel:SetText("")
        end
        ST.wasYaseylaHealthSoundPlayed = false
    end

    -- WIPE
    if (percentageHealth > 99) then
        ST.ResetYaselyaVariables()
    end

    -- CLEAR
    if percentageHealth <= 1 then
        zo_callLater(function() ST.ResetYaselyaVariables() end, 5000)
    end
end


----------------------------------------------
-- FROM NOW ON ENRAGED FRAGMENTS WILL SPAWN --
----------------------------------------------
function SanitysTracker.ActivateAtroSpawnTimer()
    ST.isAtroSpawnTimerActive = true
    -- ST.debug("ActivateAtroSpawnTimer")
end


----------------------------------
-- HELPER FUNCTIONS (DEBUGGING) --
----------------------------------
function SanitysTracker.ActivateFireMaze()
    ST.isFireMazeDone = true
end
function SanitysTracker.RitualAfter()
    ST.wasRitualCasted = false
    -- ST.debug("RitualAfter")
end
function SanitysTracker.RitualResetDebug()
    -- ST.debug("RitualResetDebug")
end
function SanitysTracker.rgbToHex(r, g, b)
	r = math.floor(r * 255 + 0.5)
	g = math.floor(g * 255 + 0.5)
	b = math.floor(b * 255 + 0.5)
	return string.format("|c%02x%02x%02x", r, g, b)
end
function SanitysTracker.GetNameForId(unitId)
    if ST.unitNames[unitId] then
        return ST.unitNames[unitId]
    end
    return ""
end


------------------------------------------------------------------------
-- START: C O M B A T - E V E N T --
------------------------------------------------------------------------
function SanitysTracker.CombatEvent( eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId )

    -- COLLECT UNITIDS TO MATCH THEM LATER
    if sourceUnitId ~= 0 and sourceName ~= nil and sourceName ~= "" then
        ST.unitNames[sourceUnitId] = zo_strformat("<<1>>", sourceName)
    end

    if targetUnitId ~= 0 and targetName ~= nil and targetName ~= "" then
        ST.unitNames[targetUnitId] = zo_strformat("<<1>>", targetName)
    end

    -- SPAWN OF HORROR
    -- GROUP 1: 1-4
    -- GROUP 2: 5-8

    -- https://www.esologs.com/reports/ajPh8AKnYk6d2gFr?fight=52&type=auras&hostility=1&ability=183946
    if abilityId == ST.YASEYLA_NEGATION then -- USED FOR PORTAL COUNT
        if result == ACTION_RESULT_EFFECT_GAINED then
            ST.counterNegation = ST.counterNegation + 1
            if ST.counterNegation == ST.SV.thresholdYaselyaPortal then
                if ST.SV.enableYaselyaPortalChatText then
                    d("|cff7f00[SanitysTracker]|r |cffffffPortal|r |cffff00OPEN!|r")
                end

                if ST.SV.enableYaselyaPortalWarningText then
                    SanitysTrackerWarningLabel:SetText("|cffff00PORTAL OPEN!|r")
                    ST.isWarningTextLocked = true

                    zo_callLater(function()
                        ST.isWarningTextLocked = false
                    end, 2000)
                end
            end

            ST.sequenceNegation = ST.sequenceNegation + 1
            if ST.sequenceNegation == 1 then
                ST.timePortalStart = GetGameTimeMilliseconds()
            end

            if not ST.isPortal1Active and not ST.isPortal1Done then
                ST.isPortal1Active = true
                SanitysTrackerPortalLabel1:SetText("|cffff00ACTIVE!|r")

            elseif not ST.isPortal2Active and not ST.isPortal2Done then
                ST.isPortal2Active = true
                SanitysTrackerPortalLabel2:SetText("|cffff00ACTIVE!|r")

            elseif not ST.isPortal3Active and not ST.isPortal3Done then
                ST.isPortal3Active = true
                SanitysTrackerPortalLabel3:SetText("|cffff00ACTIVE!|r")

            elseif not ST.isPortal4Active and not ST.isPortal4Done then
                ST.isPortal4Active = true
                SanitysTrackerPortalLabel4:SetText("|cffff00ACTIVE!|r")
            end

        elseif result == ACTION_RESULT_EFFECT_FADED then
            if ST.isPortal1Active and not ST.isPortal1Done then
                ST.isPortal1Done = true
                SanitysTrackerPortalLabel1:SetText("|c00ff00Done!|r")

            elseif ST.isPortal2Active and not ST.isPortal2Done then
                ST.isPortal2Done = true
                SanitysTrackerPortalLabel2:SetText("|c00ff00Done!|r")

            elseif ST.isPortal3Active and not ST.isPortal3Done then
                ST.isPortal3Done = true
                SanitysTrackerPortalLabel3:SetText("|c00ff00Done!|r")

            elseif ST.isPortal4Active and not ST.isPortal4Done then
                ST.isPortal4Done = true
                SanitysTrackerPortalLabel4:SetText("|c00ff00Done!|r")
            end

            ST.counterNegation = ST.counterNegation - 1
            ST.counterNegation = math.max(0, ST.counterNegation)
            if ST.counterNegation == 0 then
                ST.sequenceNegation = 0

                ST.isPortal1Open = false
                ST.isPortal2Open = false
                ST.isPortal3Open = false
                ST.isPortal4Open = false

                ST.isPortal1Done = false
                ST.isPortal2Done = false
                ST.isPortal3Done = false
                ST.isPortal4Done = false

                ST.timePortalEnd = GetGameTimeMilliseconds()

                local durationSeconds = math.ceil((ST.timePortalEnd - ST.timePortalStart) / 1000)

                if ST.SV.enableYaselyaPortalChatText then
                    d(string.format("|cff7f00[SanitysTracker]|r |cffffffPortal|r |c00ff00DONE! (%i sec)|r", durationSeconds))
                end
                ST.PlayYaseylaPortalDoneSound()

                if ST.SV.enableYaselyaPortalWarningText then
                    SanitysTrackerWarningLabel:SetText(string.format("|c00ff00PORTAL DONE! (%i sec)|r", durationSeconds))
                    ST.isWarningTextLocked = true

                    zo_callLater(function()
                        ST.isWarningTextLocked = false
                    end, 2000)
                end

                -- local oldText = SanitysTrackerWarningLabel:GetText()
                -- local newText = string.format("|c00ff00PORTAL DONE! (%i sec)|r", durationSeconds)
                -- SanitysTrackerWarningLabel:SetText(newText)
                -- ST.isWarningTextLocked = true

                -- zo_callLater(function()
                --     ST.isWarningTextLocked = false
                --     local currentText = SanitysTrackerWarningLabel:GetText()
                --     if currentText == newText then
                --         SanitysTrackerWarningLabel:SetText(oldText)
                --     end
                -- end, 2000)

                zo_callLater(function()
                    SanitysTrackerPortalLabel1:SetText("-")
                    SanitysTrackerPortalLabel2:SetText("-")
                    SanitysTrackerPortalLabel3:SetText("-")
                    SanitysTrackerPortalLabel4:SetText("-")
                end, 5000)
            end
        end
    end

    -------------------------------------
    -- YASELYA: BREAK FREE FROM CHAINS --
    -------------------------------------
    if abilityId == ST.YASEYLA_CHAIN_PULL and targetType == COMBAT_UNIT_TYPE_PLAYER then
        if result == ACTION_RESULT_STUNNED and ST.SV.enableYaseylaChainWarningText then

            local oldText = SanitysTrackerWarningLabel:GetText()
            local newText = "|cff0000BREAK FREE!|r"
            SanitysTrackerWarningLabel:SetText(newText)

            zo_callLater(function()
                local currentText = SanitysTrackerWarningLabel:GetText()
                if currentText == newText then
                    SanitysTrackerWarningLabel:SetText(oldText)
                end
            end, 2000)
        end
    end

    ------------------------------
    -- SUNBURST ON PLAYER (YOU) --
    ------------------------------
    if (abilityId == ST.ANSUUL_SUNBURST) and (targetType == COMBAT_UNIT_TYPE_PLAYER) then

        if ST.SV.enableAnsuulSunburstWarningText then
            -- DEPENDS ON CCA FOR BORDER COLOR ATM.. NEED TO IMPLEMENT THAT LATER
            if CombatAlerts and ST.SV.enableAnsuulSunburstScreenBorderColor then
                local CCAName = ST.name.."Sunburst"
                CombatAlerts.ScreenBorderEnable(0xFF7F00FF, hitValue, CCAName)
            end

            local oldText = SanitysTrackerWarningLabel:GetText()
            local newText = "|cff7f00SUNBURST (YOU)|r"
            SanitysTrackerWarningLabel:SetText(newText)

            zo_callLater(function()
                local currentText = SanitysTrackerWarningLabel:GetText()
                if currentText == newText then
                    SanitysTrackerWarningLabel:SetText(oldText)
                end
            end, 2000)

            SanitysTracker.PlayAnsuulSunburstWarningSound()
        end
    end

    -------------------------------------------------------------------------------------------
    -- IGNITE IM MAZE: BLAME WHO WAS FIRST TO CATCH FIRE - Furious Rage ID: 188190 (esologs) --
    -------------------------------------------------------------------------------------------
    if (abilityId == ST.ANSUUL_IGNITE_MAZE and result == ACTION_RESULT_EFFECT_GAINED_DURATION) then
        local currentTime = GetGameTimeMilliseconds()
        local deltaIgniteBlame = currentTime - ST.timeAnsuulLastIgniteBlame

        if deltaIgniteBlame > ST.cooldownAnsuulIgniteBlame and ST.SV.enableAnsuulIgniteBlame then
            ST.timeAnsuulLastIgniteBlame = currentTime
            local playerName = ST.GetNameForId(targetUnitId) or zo_strformat("<<1>>", targetName)

            d(string.format("|cff7f00[SanitysTracker]|r |cffffff%s caught fire!|r", playerName))
        end
    end

    -----------------------------------------------------------------------
    -- INFERNAL VANTON CASTS HACK: INDICATOR FOR FIRE MAZE HAS BEEN DONE --
    -----------------------------------------------------------------------
    if (abilityId == ST.ANSUUL_VANTON_HACK) then
        ST.isFireMazeDone = true
        if (ST.wasHackCasted == false) then
            ST.ActivateAtroSpawnTimer()
            ST.StartSpawnTimers()
        end
        ST.wasHackCasted = true
    end

    ----------------------------------
    -- ENRAGED FRAGMENT CASTS FLARE --
    ----------------------------------
    if (abilityId == ST.ANSUUL_FRAGMENT_FLARE) then
        ST.isFireMazeDone = true
        if (ST.isAtroSpawnTimerActive == false) then
           -- ST.debug("Fire Maze DONE")
        end
    end

    -----------------------------------------------------------------------------
    -- ANSUUL CASTED RITUAL: 51 SECONDS LATER ATROS WILL SPAWN AFTER FIRE MAZE --
    -----------------------------------------------------------------------------
    if (abilityId == ST.ANSUUL_RITUAL) then
        if (ST.isFireMazeDone == true) then
            if (ST.wasRitualCasted == false) then
                zo_callLater(function() ST.ResetAnsuulVariables() end, 6000)

                ST.isAtroSpawnTimerActive = false
                zo_callLater(function() ST.ActivateAtroSpawnTimer() end, 7000)
                zo_callLater(function() ST.StartSpawnTimers() end, ST.ritualOffset)

                ST.wasRitualCasted = true
                zo_callLater(function() ST.RitualAfter() end, 60000)
            end
        else
            zo_callLater(function() ST.ResetAnsuulVariables() end, 6000)
        end
    end

    -----------------------------
    -- INFERNO HAS BEEN CASTED --
    -----------------------------
    if (abilityId == ST.ANSUUL_INFERNO) then
        -- TRY TO GET "REAL" NAMES FROM THE UnitId
        local unitName = ST.GetNameForId(targetUnitId) or tostring(targetUnitId)
        ST.CastingInfernoText(result, unitName)
    end

    --------------------------
    -- BOLT HAS BEEN CASTED --
    --------------------------
    if (abilityId == ST.ANSUUL_BOLT) then
        if (ST.wasBoltCasted == false) then
            ST.wasBoltCasted = true
            ST.ResetBoltArray()
        end
        -- TRY TO GET "REAL" NAMES FROM THE UnitId
        local unitName = ST.GetNameForId(targetUnitId) or tostring(targetUnitId)
        ST.CastingBoltText(unitName)
    end

end
------------------------------------------------------------------------
-- END: C O M B A T - E V E N T --
------------------------------------------------------------------------


--------------------------------------------------------------
-- RESET THE BOLT ARRAY (WITH A DELAY: 2490MS FROM ESOLOGS) --
--------------------------------------------------------------
function SanitysTracker.ResetBoltArray()
    ST.boltData = {}

    zo_callLater(function() 
        ST.wasBoltCasted = false
    end, 2490)
end


------------------------------------------
-- PLAY SOUNDS FOR DIFFERENT SITUATIONS --
------------------------------------------
function SanitysTracker.PlayYaseylaHealthWarningSound()
    local volume = ST.SV.volumeYaselyaHealthWarningSound or 10
    if volume == 0 then return end
    for i = 1, volume do
        PlaySound(SOUNDS.BATTLEGROUND_CAPTURE_FLAG_TAKEN_OWN_TEAM)
    end
end


function SanitysTracker.PlayYaseylaPortalDoneSound()
    local volume = ST.SV.volumeYaselyaPortalDoneSound or 10
    if volume == 0 then return end
    for i = 1, volume do
        PlaySound(SOUNDS.LEVEL_UP)
    end
end


function SanitysTracker.PlayAnsuulInfernoCastingSound()
    local volume = ST.SV.volumeAnsuulInfernoCastingSound or 10
    if volume == 0 then return end
    for i = 1, volume do
        PlaySound(SOUNDS.VOICE_CHAT_ALERT_CHANNEL_MADE_ACTIVE)
    end
end


function SanitysTracker.PlayAnsuulInfernoSpawnSound()
    local volume = ST.SV.volumeAnsuulInfernoSpawningSound or 10
    if volume == 0 then return end
    for i = 1, volume do
        PlaySound(SOUNDS.BATTLEGROUND_MURDERBALL_TAKEN_OWN_TEAM)
    end
end


function SanitysTracker.PlayAnsuulSunburstWarningSound()
    local volume = ST.SV.volumeAnsuulSunburstWarningSound or 10
    if volume == 0 then return end
    for i = 1, volume do
        PlaySound(SOUNDS.BATTLEGROUND_CAPTURE_FLAG_TAKEN_OWN_TEAM)
    end
end


-----------------------------------------------------------------------
-- SPAWN TIMERS FOR ATROS (START AFTER FIRE MAZE WITH 39000MS DELAY) --
-----------------------------------------------------------------------
function SanitysTracker.StartSpawnTimers()
    if (ST.isFireMazeDone == true) then
        if (ST.counterInfernoSpawn == 1) then

            local timer = string.format("%.0f", ST.timeAtro1Spawn / 1000)
            if ST.timeAtro1Spawn <= 0 then
                timer = "|cff7f00SOON|r"
                ST.PlayAnsuulInfernoSpawnSound()
            end

            SanitysTrackerInfernoLabel1:SetColor(1, 1, 1)
            SanitysTrackerInfernoLabel1:SetText("Spawning in: " .. timer)

            if (ST.timeAtro1Spawn <= 0) then
                ST.counterInfernoSpawn = ST.counterInfernoSpawn + 1
                ST.timeAtro1Spawn = 12000
                ST.timeAtro1FirstCast = 5000
                ST.InfernoCastTimer1()
            end

            ST.timeAtro1Spawn = ST.timeAtro1Spawn - 1000
        end

        if (ST.counterInfernoSpawn == 2) then

            local timer = string.format("%.0f", ST.timeAtro2Spawn / 1000)
            if ST.timeAtro2Spawn <= 0 then
                timer = "|cff7f00SOON|r"
                ST.PlayAnsuulInfernoSpawnSound()
            end

            SanitysTrackerInfernoLabel2:SetColor(1, 1, 1)
            SanitysTrackerInfernoLabel2:SetText("Spawning in: " .. timer)

            if (ST.timeAtro2Spawn <= 0) then
                ST.counterInfernoSpawn = ST.counterInfernoSpawn + 1
                ST.timeAtro2Spawn = 12000
                ST.timeAtro2FirstCast = 5000
                ST.InfernoCastTimer2()
            end

            ST.timeAtro2Spawn = ST.timeAtro2Spawn - 1000
        end

        if (ST.counterInfernoSpawn == 3) then

            local timer = string.format("%.0f", ST.timeAtro3Spawn / 1000)
            if ST.timeAtro3Spawn <= 0 then
                timer = "|cff7f00SOON|r"
                ST.PlayAnsuulInfernoSpawnSound()
            end

            SanitysTrackerInfernoLabel3:SetColor(1, 1, 1)
            SanitysTrackerInfernoLabel3:SetText("Spawning in: " .. timer)

            if (ST.timeAtro3Spawn <= 0) then
                ST.counterInfernoSpawn = ST.counterInfernoSpawn + 1
                ST.timeAtro3Spawn = 12000
                ST.timeAtro3FirstCast = 5000
                ST.InfernoCastTimer3()
            end

            ST.timeAtro3Spawn = ST.timeAtro3Spawn - 1000
        end

        if (ST.counterInfernoSpawn == 4) then

            local timer = string.format("%.0f", ST.timeAtro4Spawn / 1000)
            if ST.timeAtro4Spawn <= 0 then
                timer = "|cff7f00SOON|r"
                ST.PlayAnsuulInfernoSpawnSound()
            end

            SanitysTrackerInfernoLabel4:SetColor(1, 1, 1)
            SanitysTrackerInfernoLabel4:SetText("Spawning in: " .. timer)

            if (ST.timeAtro4Spawn <= 0) then
                ST.counterInfernoSpawn = 1
                ST.timeAtro4Spawn = 12000
                ST.timeAtro4FirstCast = 5000
                ST.InfernoCastTimer4()
            end

            ST.timeAtro4Spawn = ST.timeAtro4Spawn - 1000
        end

        if (ST.isAtroSpawnTimerActive == true) then
            EVENT_MANAGER:RegisterForUpdate(ST.name.."StartSpawnTimers", 1000, ST.StartSpawnTimers)
        else
            EVENT_MANAGER:UnregisterForUpdate(ST.name.."StartSpawnTimers")
        end
    end
end


---------------------------------
-- CAST TIMERS FOR ATROS 1 - 4 --
---------------------------------
function SanitysTracker.InfernoCastTimer1()
    local timer = string.format("%.0f", ST.timeAtro1FirstCast / 1000)
    if ST.timeAtro1FirstCast <= 0 then timer = "SOON" end

    SanitysTrackerInfernoLabel1:SetColor(1, 1, 0.25)
    SanitysTrackerInfernoLabel1:SetText("Start casting in: " .. timer)

    if (ST.timeAtro1FirstCast > 0) then
        EVENT_MANAGER:RegisterForUpdate(ST.name.."InfernoCastTimer1", 1000, ST.InfernoCastTimer1)
    else
        EVENT_MANAGER:UnregisterForUpdate(ST.name.."InfernoCastTimer1")
    end
    ST.timeAtro1FirstCast = ST.timeAtro1FirstCast - 1000
end


function SanitysTracker.InfernoCastTimer2()
    local timer = string.format("%.0f", ST.timeAtro2FirstCast / 1000)
    if ST.timeAtro2FirstCast <= 0 then timer = "SOON" end

    SanitysTrackerInfernoLabel2:SetColor(1, 1, 0.25)
    SanitysTrackerInfernoLabel2:SetText("Start casting in: " .. timer)

    if (ST.timeAtro2FirstCast > 0) then
        EVENT_MANAGER:RegisterForUpdate(ST.name.."InfernoCastTimer2", 1000, ST.InfernoCastTimer2)
    else
        EVENT_MANAGER:UnregisterForUpdate(ST.name.."InfernoCastTimer2")
    end
    ST.timeAtro2FirstCast = ST.timeAtro2FirstCast - 1000
end


function SanitysTracker.InfernoCastTimer3()
    local timer = string.format("%.0f", ST.timeAtro3FirstCast / 1000)
    if ST.timeAtro3FirstCast <= 0 then timer = "SOON" end

    SanitysTrackerInfernoLabel3:SetColor(1, 1, 0.25)
    SanitysTrackerInfernoLabel3:SetText("Start casting in: " .. timer)

    if (ST.timeAtro3FirstCast > 0) then
        EVENT_MANAGER:RegisterForUpdate(ST.name.."InfernoCastTimer3", 1000, ST.InfernoCastTimer3)
    else
        EVENT_MANAGER:UnregisterForUpdate(ST.name.."InfernoCastTimer3")
    end
    ST.timeAtro3FirstCast = ST.timeAtro3FirstCast - 1000
end


function SanitysTracker.InfernoCastTimer4()
    local timer = string.format("%.0f", ST.timeAtro4FirstCast / 1000)
    if ST.timeAtro4FirstCast <= 0 then timer = "SOON" end

    SanitysTrackerInfernoLabel4:SetColor(1, 1, 0.25)
    SanitysTrackerInfernoLabel4:SetText("Start casting in: " .. timer)

    if (ST.timeAtro4FirstCast > 0) then
        EVENT_MANAGER:RegisterForUpdate(ST.name.."InfernoCastTimer4", 1000, ST.InfernoCastTimer4)
    else
        EVENT_MANAGER:UnregisterForUpdate(ST.name.."InfernoCastTimer4")
    end
    ST.timeAtro4FirstCast = ST.timeAtro4FirstCast - 1000
end


-----------------------------------------
-- GARSTIGE FRAGMENTS: CAST INDICATORS --
-----------------------------------------
function SanitysTracker.CastingInfernoText(result, targetID)
    if (ST.DoesTableContain(ST.infernoData, targetID) == false) then
        table.insert(ST.infernoData, targetID)
    end

    local position = ST.GetSpawnGroupPosition(ST.infernoData, targetID)
    local x = position

    -- SPAWN GROUP 1
    if (position == 1 or position == 5 or position == 9 or position == 13 or position == 17 or position == 21 or position == 25) then
        local timer = string.format("%.0f", ST.timeAtro1Inferno / 1000)

        SanitysTrackerInfernoLabel1:SetColor(1, 0.25, 0.25)
        SanitysTrackerInfernoLabel1:SetText("Fragment " .. x .. " casting: " .. timer)
        ST.isAtro1Casting = true
        if (ST.wasInferno1Played == false) then
            ST.PlayAnsuulInfernoCastingSound()
            ST.wasInferno1Played = true
        end

        if (result == 2250) then
            ST.wasInferno1Played = false
            ST.isAtro1Casting = false
            ST.timeAtro1Inferno = 0.0
            SanitysTrackerInfernoLabel1:SetColor(0.25, 1, 0.25)
            SanitysTrackerInfernoLabel1:SetText("Fragment " .. x .. " INTERRUPTED")
        end
    else
        if (ST.isAtro1Casting == true) then
            ST.wasInferno1Played = false
            ST.timeAtro1Inferno = 0.0
            SanitysTrackerInfernoLabel1:SetColor(0.25, 1, 0.25)
            SanitysTrackerInfernoLabel1:SetText("Fragment INTERRUPTED")
            ST.isAtro1Casting = false
        end
    end

    -- SPAWN GROUP 2
    if (position == 2 or position == 6 or position == 10 or position == 14 or position == 18 or position == 22 or position == 26) then
        local timer = string.format("%.0f", ST.timeAtro2Inferno / 1000)

        SanitysTrackerInfernoLabel2:SetColor(1, 0.25, 0.25)
        SanitysTrackerInfernoLabel2:SetText("Fragment " .. x .. " casting: " .. timer)
        ST.isAtro2Casting = true

        if (ST.wasInferno2Played == false) then
            ST.PlayAnsuulInfernoCastingSound()
            ST.wasInferno2Played = true
        end

        if (result == 2250) then
            ST.isAtro2Casting = false
            ST.timeAtro2Inferno = 0.0
            ST.wasInferno2Played = false
            SanitysTrackerInfernoLabel2:SetColor(0.25, 1, 0.25)
            SanitysTrackerInfernoLabel2:SetText("Fragment " .. x .. " INTERRUPTED")
        end
    else
        if (ST.isAtro2Casting == true) then
            ST.wasInferno2Played = false
            ST.timeAtro2Inferno = 0.0
            SanitysTrackerInfernoLabel2:SetColor(0.25, 1, 0.25)
            SanitysTrackerInfernoLabel2:SetText("Fragment INTERRUPTED")
            ST.isAtro2Casting = false
        end
    end

    -- SPAWN GROUP 3
    if (position == 3 or position == 7 or position == 11 or position == 15 or position == 19 or position == 23 or position == 27) then
        local timer = string.format("%.0f", ST.timeAtro3Inferno / 1000)

        SanitysTrackerInfernoLabel3:SetColor(1, 0.25, 0.25)
        SanitysTrackerInfernoLabel3:SetText("Fragment " .. x .. " casting: " .. timer)
        ST.isAtro3Casting = true

        if (ST.wasInferno3Played == false) then
            ST.PlayAnsuulInfernoCastingSound()
            ST.wasInferno3Played = true
        end

        if (result == 2250) then
            ST.wasInferno3Played = false
            ST.isAtro3Casting = false
            ST.timeAtro3Inferno = 0.0
            SanitysTrackerInfernoLabel3:SetColor(0.25, 1, 0.25)
            SanitysTrackerInfernoLabel3:SetText("Fragment " .. x .. " INTERRUPTED")
        end
    else
        if (ST.isAtro3Casting == true) then
            ST.wasInferno3Played = false
            ST.timeAtro3Inferno = 0.0
            SanitysTrackerInfernoLabel3:SetColor(0.25, 1, 0.25)
            SanitysTrackerInfernoLabel3:SetText("Fragment INTERRUPTED")
            ST.isAtro3Casting = false
        end
    end

    -- SPAWN GROUP 4
    if (position == 0 or position == 4 or position == 8 or position == 12 or position == 16 or position == 20 or position == 24) then
        local timer = string.format("%.0f", ST.timeAtro4Inferno / 1000)

        SanitysTrackerInfernoLabel4:SetColor(1, 0.25, 0.25)
        SanitysTrackerInfernoLabel4:SetText("Fragment " .. x .. " casting: " .. timer)
        ST.isAtro4Casting = true

        if (ST.wasInferno4Played == false) then
            ST.PlayAnsuulInfernoCastingSound()
            ST.wasInferno4Played = true
        end

        if (result == 2250) then
            ST.wasInferno4Played = false
            ST.isAtro4Casting = false
            ST.timeAtro4Inferno = 0.0
            SanitysTrackerInfernoLabel4:SetColor(0.25, 1, 0.25)
            SanitysTrackerInfernoLabel4:SetText("Fragment " .. x .. " INTERRUPTED")
        end
    else
        if (ST.isAtro4Casting == true) then
            ST.wasInferno4Played = false
            ST.timeAtro4Inferno = 0.0
            SanitysTrackerInfernoLabel4:SetColor(0.25, 1, 0.25)
            SanitysTrackerInfernoLabel4:SetText("Fragment INTERRUPTED")
            ST.isAtro4Casting = false
        end
    end
end


-------------------------------------------------
-- "GARSTIGE IMPS" CASTING (SPAWN GROUP 1 - 4) --
-------------------------------------------------
function SanitysTracker.CastingBoltText(targetID)
    table.insert(ST.boltData, targetID)

    local pos = ST.GetSpawnGroupPosition(ST.boltData, targetID)

    -- GROUP 1
    if (pos == 1 or pos == 5 or pos == 9 or pos == 13 or pos == 17 or pos == 21 or pos == 25) then
        SanitysTrackerBoltLabel1:SetText("Casting Bolt at: " .. targetID)
        zo_callLater(function() SanitysTrackerBoltLabel1:SetText("-") end, 1800)
    end

    -- GROUP 2
    if (pos == 2 or pos == 6 or pos == 10 or pos == 14 or pos == 18 or pos == 22 or pos == 26) then
        SanitysTrackerBoltLabel2:SetText("Casting Bolt at: " .. targetID)
        zo_callLater(function() SanitysTrackerBoltLabel2:SetText("-") end, 1800)
    end

    -- GROUP 3
    if (pos == 3 or pos == 7 or pos == 11 or pos == 15 or pos == 19 or pos == 23 or pos == 27) then
        SanitysTrackerBoltLabel3:SetText("Casting Bolt at: " .. targetID)
        zo_callLater(function() SanitysTrackerBoltLabel3:SetText("-") end, 1800)
    end

    -- GROUP 4
    if (pos == 0 or pos == 4 or pos == 8 or pos == 12 or pos == 16 or pos == 20 or pos == 24) then
        SanitysTrackerBoltLabel4:SetText("Casting Bolt at: " .. targetID)
        zo_callLater(function() SanitysTrackerBoltLabel4:SetText("-") end, 1800)
    end
end


---------------------------------------
-- HELPER FUNCTION TO GET PAIRS DATA --
---------------------------------------
function SanitysTracker.DoesTableContain(array, target)
    for index, value in ipairs(array) do
        if value == target then
            return true
        end
    end
    return false -- ELSE
end


---------------------------------------------------
-- RETURNS POSITION WITHIN A SPAWN GROUP (1 - 4) --
---------------------------------------------------
function SanitysTracker.GetSpawnGroupPosition(array, target)
    for index, value in ipairs(array) do
        if value == target then
            return index
        end
    end
    return -1 -- RETURN -1 IF INT IS NOT FOUND IN ARRAY
end


-----------------------------------------------
-- SAFE POSITIONS FOR THE WARNING TRACKER UI --
-----------------------------------------------
function SanitysTracker.SavePositonWarning()
    ST.SV.offsetWarningX = SanitysTrackerWarning:GetLeft()
    ST.SV.offsetWarningY = SanitysTrackerWarning:GetTop()

    SanitysTrackerWarning:ClearAnchors()
    SanitysTrackerWarning:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)

    local centerX = SanitysTrackerWarning:GetLeft()
    local centerY = SanitysTrackerWarning:GetTop()

    local offsetX = ST.SV.offsetWarningX - centerX
    local offsetY = ST.SV.offsetWarningY - centerY

    if offsetX < 100 and offsetX > -100 then
        offsetX = 0
    end
    if offsetY < 50 and offsetY > -50 then
        offsetY = 0
    end

    SanitysTrackerWarning:ClearAnchors()
    SanitysTrackerWarning:SetAnchor(CENTER, GuiRoot, CENTER, offsetX, offsetY)

    ST.SV.offsetWarningX = SanitysTrackerWarning:GetLeft()
    ST.SV.offsetWarningY = SanitysTrackerWarning:GetTop()
end


--------------------------------------
-- SAFE POSITIONS FOR THE PORTAL UI --
--------------------------------------
function SanitysTracker.SavePositonPortal()
    ST.SV.offsetYaselyaPortalX = SanitysTrackerPortal:GetLeft()
    ST.SV.offsetYaselyaPortalY = SanitysTrackerPortal:GetTop()
end


-----------------------------------------------
-- SAFE POSITIONS FOR THE INFERNO TRACKER UI --
-----------------------------------------------
function SanitysTracker.SavePositonInferno()
    ST.SV.offsetInfernoX = SanitysTrackerInferno:GetLeft()
    ST.SV.offsetInfernoY = SanitysTrackerInferno:GetTop()
end


--------------------------------------------
-- SAFE POSITIONS FOR THE BOLT TRACKER UI --
--------------------------------------------
function SanitysTracker.SavePositonBolt()
    ST.SV.offsetBoltX = SanitysTrackerBolt:GetLeft()
    ST.SV.offsetBoltY = SanitysTrackerBolt:GetTop()
end


--------------------------------
-- SET POSITIONS AFTER RELOAD --
--------------------------------
function SanitysTracker.RestorePosition()
    if  ST.SV.offsetWarningX == ST.default.offsetWarningX or
        ST.SV.offsetWarningY == ST.default.offsetWarningY then
        SanitysTrackerWarning:ClearAnchors()
        SanitysTrackerWarning:SetAnchor(CENTER, GuiRoot, CENTER, ST.default.offsetWarningX, ST.default.offsetWarningY)
    else
        SanitysTrackerWarning:ClearAnchors()
        SanitysTrackerWarning:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ST.SV.offsetWarningX, ST.SV.offsetWarningY)
    end

    SanitysTrackerPortal:ClearAnchors()
    SanitysTrackerPortal:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ST.SV.offsetYaselyaPortalX, ST.SV.offsetYaselyaPortalY)

    SanitysTrackerInferno:ClearAnchors()
    SanitysTrackerInferno:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ST.SV.offsetInfernoX, ST.SV.offsetInfernoY)

    SanitysTrackerBolt:ClearAnchors()
    SanitysTrackerBolt:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ST.SV.offsetBoltX, ST.SV.offsetBoltY)
end


------------------------------
-- SET POSITIONS TO DEFAULT --
------------------------------
function SanitysTracker.SetDefaultPosition()
    SanitysTrackerWarning:ClearAnchors()
    SanitysTrackerWarning:SetAnchor(CENTER, GuiRoot, CENTER, ST.default.offsetWarningX, ST.default.offsetWarningY)


    SanitysTrackerPortal:ClearAnchors()
    SanitysTrackerPortal:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ST.default.offsetYaselyaPortalX, ST.default.offsetYaselyaPortalY)

    SanitysTrackerInferno:ClearAnchors()
    SanitysTrackerInferno:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ST.default.offsetInfernoX, ST.default.offsetInfernoY)

    SanitysTrackerBolt:ClearAnchors()
    SanitysTrackerBolt:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ST.default.offsetBoltX, ST.default.offsetBoltY)

    ST.SavePositonWarning()
    ST.SavePositonPortal()
    ST.SavePositonInferno()
    ST.SavePositonBolt()
end


---------------------------------
-- CREATE SETTINGS MENU (LAM2) --
---------------------------------
function SanitysTracker.AddonMenu()

    local panelName = "Sanitys Tracker"
    if GetUnitDisplayName("player") == ST.author then panelName = "[Dev] " .. panelName end

    local panelData = {
        type = "panel",
        name = panelName,
        displayName = "|cff7f00Sanitys|r |cffffffTracker|r",
        author = "|cff7f00" .. ST.author .. "|r |cffffff[EU]|r",
        version = "|cff7f00" .. ST.version .. "|r",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsData = {
        {
            type = "header",
            name = "|cff7f00General Options|r"
        },
        {
            type = "description",
            text = "This Addon Will Track Multiple Mechanics In Sanity's Edge. Under Construction!",
            width = "full"
        },
        {
            type = "checkbox",
            name = "MASTERSWITCH (Turns the entire addon ON/OFF)",
            tooltip = "Enables or disables all features of the addon.",
            getFunc = function() return ST.SV.enableAddon end,
            setFunc = function(value)
                ST.SV.enableAddon = value
                if value == true then
                    ST.CheckZone()
                else
                    ST.Disable()
                end
            end,
            width = "full",
            default = true,
        },
        {
            type = "button",
            name = "Show / Hide Tracker",
            tooltip = "Forces The UI ON/OFF",
            func = function(value)
                ST.forceShow = not ST.forceShow
                local warningText
                if ST.forceShow then
                    value:SetText("Hide Tracker")
                    warningText = "|cff7f00WARNING|r"
                    SanitysTrackerWarningLabel:SetText(warningText)
                    SanitysTrackerWarning:SetHidden(false)
                    SanitysTrackerPortal:SetHidden(false)
                    SanitysTrackerInferno:SetHidden(false)
                    SanitysTrackerBolt:SetHidden(false)
                else
                    value:SetText("Show Tracker")
                    warningText = ""
                    SanitysTrackerWarningLabel:SetText(warningText)
                    SanitysTrackerWarning:SetHidden(true)
                    SanitysTrackerPortal:SetHidden(true)
                    SanitysTrackerInferno:SetHidden(true)
                    SanitysTrackerBolt:SetHidden(true)
                end
            end,
            disabled = function() return not ST.SV.enableAddon end,
            width = "half",
        },
        {
            type = "button",
            name = "Default Position",
            tooltip = "Resets The UI Position To Default Values",
            func = function()
                ST.SetDefaultPosition()
            end,
            disabled = function() return not ST.SV.enableAddon end,
            width = "half",
        },

        {
            type = "slider",
            name = "Font Size Warning",
            tooltip = "Default: 128",
            getFunc = function() return ST.SV.fontSizeWarning end,
            setFunc = function(value)
                ST.SV.fontSizeWarning = value
                ST.SetFonts()
            end,
            min = 32,
            max = 256,
            step = 1,
            default = ST.default.fontSizeWarning,
            disabled = function() return not ST.SV.enableAddon end,
            width = "full",
        },

        ---------------------
        -- Boss 1: YASEYLA --
        ---------------------
        {
            type = "submenu",
            name = "|cff7f00Boss 1: Yaseyla|r",
            controls = {
                {
                    type    = "checkbox",
                    name    = "Enable Break Free Warning Text",
                    tooltip = "Warning When You Get Chained",
                    default = ST.default.enableYaseylaChainWarningText,
                    getFunc = function() return ST.SV.enableYaseylaChainWarningText end,
                    setFunc = function(value)
                        ST.SV.enableYaseylaChainWarningText = value
                    end,
                    disabled = function() return not ST.SV.enableAddon end,
                },
                {
                    type    = "checkbox",
                    name    = "Enable Health Warning Text",
                    tooltip = "Warning On Certain Thresholds For Yaselya Like Portal And Execute",
                    default = ST.default.enableYaselyaHealthWarningText,
                    getFunc = function() return ST.SV.enableYaselyaHealthWarningText end,
                    setFunc = function(value)
                        ST.SV.enableYaselyaHealthWarningText = value
                    end,
                    disabled = function() return not ST.SV.enableAddon end,
                },
                {
                    type = "slider",
                    name = "Volume Health Warning: |cff7f000 = OFF|r",
                    tooltip = "Set to 0 to turn this function OFF.",
                    min = 0,
                    max = 20,
                    default = ST.default.volumeYaselyaHealthWarningSound,
                    clampInput = true,
                    getFunc = function() return ST.SV.volumeYaselyaHealthWarningSound end,
                    setFunc = function(value)
                        ST.SV.volumeYaselyaHealthWarningSound = value
                    end,
                    disabled = function() return not ST.SV.enableAddon end,
                },
                {
                    type = "button",
                    name = "Play Warning Sound",
                    func = function()
                        ST.PlayYaseylaHealthWarningSound()
                    end,
                    disabled = function() return not ST.SV.enableAddon end,
                    width = "half"
                },
                {
                    type = "divider"
                },
                {
                    type    = "checkbox",
                    name    = "Enable Portal Tracker Panel",
                    default = ST.default.enableYaselyaPortalPanel,
                    getFunc = function() return ST.SV.enableYaselyaPortalPanel end,
                    setFunc = function(value)
                        ST.SV.enableYaselyaPortalPanel = value
                    end,
                    disabled = function() return not ST.SV.enableAddon end,
                },
                {
                    type = "slider",
                    name = "Font Size Portal Tracker",
                    tooltip = "Default: 20",
                    default = ST.default.fontSizeYaselyaPortal,
                    getFunc = function() return ST.SV.fontSizeYaselyaPortal end,
                    setFunc = function(value)
                        ST.SV.fontSizeYaselyaPortal = value
                        ST.SetFonts()
                    end,
                    min = 10,
                    max = 40,
                    step = 1,
                    disabled = function() return not ST.SV.enableAddon end,
                    width = "full"
                },
                {
                    type    = "checkbox",
                    name    = "Enable Portal Center Warning",
                    tooltip = "Shows 'PORTAL OPEN/DONE' in the center of your screen.",
                    default = ST.default.enableYaselyaPortalWarningText,
                    getFunc = function() return ST.SV.enableYaselyaPortalWarningText end,
                    setFunc = function(value) ST.SV.enableYaselyaPortalWarningText = value end,
                    disabled = function() return not ST.SV.enableAddon end,
                },
                {
                    type    = "checkbox",
                    name    = "Enable Portal Chat Message",
                    tooltip = "Prints 'PORTAL OPEN/DONE' into your chat window.",
                    default = ST.default.enableYaselyaPortalChatText,
                    getFunc = function() return ST.SV.enableYaselyaPortalChatText end,
                    setFunc = function(value) ST.SV.enableYaselyaPortalChatText = value end,
                    disabled = function() return not ST.SV.enableAddon end,
                },
                {
                    type = "slider",
                    name = "Volume Portal Done: |cff7f000 = OFF|r",
                    tooltip = "Default: 10",
                    default = ST.default.volumeYaselyaPortalDoneSound,
                    min = 0,
                    max = 30,
                    clampInput = true,
                    getFunc = function() return ST.SV.volumeYaselyaPortalDoneSound end,
                    setFunc = function(value)
                        ST.SV.volumeYaselyaPortalDoneSound = value
                    end,
                    disabled = function() return not ST.SV.enableAddon end,
                },
                {
                    type = "button",
                    name = "Play Portal Sound",
                    func = function()
                        ST.PlayYaseylaPortalDoneSound()
                    end,
                    disabled = function() return not ST.SV.enableAddon end,
                    width = "half"
                },
            },
        },

        --------------------
        -- Boss 3: ANSUUL --
        --------------------
        {
            type = "submenu",
            name = "|cff7f00Boss 3: Ansuul|r",
            controls = {
                {
                    type    = "checkbox",
                    name    = "Blame Fire Maze",
                    tooltip = "Prints In Chat Who Was First To Catch Fire",
                    default = ST.default.enableAnsuulIgniteBlame,
                    getFunc = function() return ST.SV.enableAnsuulIgniteBlame end,
                    setFunc = function(value)
                        ST.SV.enableAnsuulIgniteBlame = value
                    end,
                    disabled = function() return not ST.SV.enableAddon end,
                },
                {
                    type = "divider"
                },
                {
                    type    = "checkbox",
                    name    = "Enable Sunburst Warning Panel",
                    default = ST.default.enableAnsuulSunburstWarningText,
                    getFunc = function() return ST.SV.enableAnsuulSunburstWarningText end,
                    setFunc = function(value)
                        ST.SV.enableAnsuulSunburstWarningText = value
                    end,
                    disabled = function() return not ST.SV.enableAddon end,
                },
                {
                    type    = "checkbox",
                    name    = "Enable Sunburst Screen Border Color",
                    default = ST.default.enableAnsuulSunburstScreenBorderColor,
                    getFunc = function() return ST.SV.enableAnsuulSunburstScreenBorderColor end,
                    setFunc = function(value)
                        ST.SV.enableAnsuulSunburstScreenBorderColor = value
                        if value then
                            if CombatAlerts and ST.SV.enableAnsuulSunburstScreenBorderColor then
                                local CCAName = ST.name.."Sunburst"
                                CombatAlerts.ScreenBorderEnable(0xFF7F00FF, 1000, CCAName)
                            end
                        end
                    end,
                    disabled = function() return not ST.SV.enableAddon end,
                },
                {
                    type = "slider",
                    name = "Volume Sunburst Warning: |cff7f000 = OFF|r",
                    tooltip = "Default: 10",
                    min = 0,
                    max = 30,
                    default = ST.default.volumeAnsuulSunburstWarningSound,
                    clampInput = true,
                    getFunc = function() return ST.SV.volumeAnsuulSunburstWarningSound end,
                    setFunc = function(value)
                        ST.SV.volumeAnsuulSunburstWarningSound = value
                    end,
                    disabled = function() return not ST.SV.enableAddon end,
                },
                {
                    type = "button",
                    name = "Play Warning Sound",
                    func = function()
                        ST.PlayAnsuulSunburstWarningSound()
                    end,
                    disabled = function() return not ST.SV.enableAddon end,
                    width = "half"
                },
                {
                    type = "divider"
                },
                {
                    type    = "checkbox",
                    name    = "Enable Inferno Tracker Panel",
                    default = ST.default.enableInfernoPanel,
                    getFunc = function() return ST.SV.enableInfernoPanel end,
                    setFunc = function(value)
                        ST.SV.enableInfernoPanel = value
                    end,
                    disabled = function() return not ST.SV.enableAddon end,
                },
                {
                    type = "slider",
                    name = "Font Size Tracker Inferno",
                    tooltip = "Default: 20",
                    default = ST.default.fontSizeTrackerInferno,
                    getFunc = function() return ST.SV.fontSizeTrackerInferno end,
                    setFunc = function(value)
                        ST.SV.fontSizeTrackerInferno = value
                        ST.SetFonts()
                    end,
                    min = 10,
                    max = 40,
                    step = 1,
                    disabled = function() return not ST.SV.enableAddon end,
                    width = "full"
                },
                {
                    type = "slider",
                    name = "Volume Atro Spawn: |cff7f000 = OFF|r",
                    tooltip = "Default: 10",
                    default = ST.default.volumeAnsuulInfernoSpawningSound,
                    min = 0,
                    max = 30,
                    clampInput = true,
                    getFunc = function() return ST.SV.volumeAnsuulInfernoSpawningSound end,
                    setFunc = function(value)
                        ST.SV.volumeAnsuulInfernoSpawningSound = value
                    end,
                    disabled = function() return not ST.SV.enableAddon end,
                },
                {
                    type = "slider",
                    name = "Volume Atro Casting: |cff7f000 = OFF|r",
                    tooltip = "Default: 10",
                    default = ST.default.volumeAnsuulInfernoCastingSound,
                    min = 0,
                    max = 30,
                    clampInput = true,
                    getFunc = function() return ST.SV.volumeAnsuulInfernoCastingSound end,
                    setFunc = function(value)
                        ST.SV.volumeAnsuulInfernoCastingSound = value
                    end,
                    disabled = function() return not ST.SV.enableAddon end,
                },
                {
                    type = "button",
                    name = "Play Spawn Sound",
                    func = function()
                        ST.PlayAnsuulInfernoSpawnSound()
                    end,
                    disabled = function() return not ST.SV.enableAddon end,
                    width = "half"
                },
                {
                    type = "button",
                    name = "Play Cast Sound",
                    func = function()
                        ST.PlayAnsuulInfernoCastingSound()
                    end,
                    disabled = function() return not ST.SV.enableAddon end,
                    width = "half"
                },
                {
                    type = "divider"
                },
                {
                    type    = "checkbox",
                    name    = "Enable Bolt Tracker Panel",
                    default = ST.default.enableBoltPanel,
                    getFunc = function() return ST.SV.enableBoltPanel end,
                    setFunc = function(value)
                        ST.SV.enableBoltPanel = value
                    end,
                    disabled = function() return not ST.SV.enableAddon end,
                },
                {
                    type = "slider",
                    name = "Font Size Bolt Tracker",
                    tooltip = "Default: 20",
                    getFunc = function() return ST.SV.fontSizeTrackerBolt end,
                    setFunc = function(value)
                        ST.SV.fontSizeTrackerBolt = value
                        ST.SetFonts()
                    end,
                    min = 10,
                    max = 40,
                    step = 1,
                    default = ST.default.fontSizeTrackerBolt,
                    disabled = function() return not ST.SV.enableAddon end,
                    width = "full"
                },
            },
        },
        {
            type = "divider"
        },
        {
            type = "description",
            text = "If you enjoy |cff7f00Sanitys Tracker|r, consider sharing your feedback or supporting its development. Your input and contributions are greatly appreciated!",
            width = "full"
        },
        {
            type = "button",
            name = "Feedback / Donate",
            tooltip = "Opens a mail to send feedback or donate to the author. <3",
            func = function()
                SCENE_MANAGER:Show('mailSend')
                zo_callLater(function()
                    ZO_MailSendToField:SetText(ST.author)
                    ZO_MailSendSubjectField:SetText("Sanitys Tracker")
                    ZO_MailSendBodyField:TakeFocus()
                end, 250)
            end,
            width = "full"
        }
    }

    local LAM2 = LibAddonMenu2
    LAM2:RegisterAddonPanel(ST.name .. "Menu", panelData)
    LAM2:RegisterOptionControls(ST.name .. "Menu", optionsData)
end


--------------------------------------
-- SETS / CHANGES FONT AND FONTSIZE --
--------------------------------------
function SanitysTracker.SetFonts()
    SanitysTrackerWarningLabel:SetFont("$(BOLD_FONT)|" .. ST.SV.fontSizeWarning .. "|soft-shadow-thick")

    SanitysTrackerPortalTitle:SetFont("$(BOLD_FONT)|" .. (ST.SV.fontSizeYaselyaPortal + 4) .. "|soft-shadow-thick")
    SanitysTrackerPortalLabel1:SetFont("$(BOLD_FONT)|" .. ST.SV.fontSizeYaselyaPortal .. "|soft-shadow-thick")
    SanitysTrackerPortalLabel2:SetFont("$(BOLD_FONT)|" .. ST.SV.fontSizeYaselyaPortal .. "|soft-shadow-thick")
    SanitysTrackerPortalLabel3:SetFont("$(BOLD_FONT)|" .. ST.SV.fontSizeYaselyaPortal .. "|soft-shadow-thick")
    SanitysTrackerPortalLabel4:SetFont("$(BOLD_FONT)|" .. ST.SV.fontSizeYaselyaPortal .. "|soft-shadow-thick")

    SanitysTrackerInfernoTitle:SetFont("$(BOLD_FONT)|" .. (ST.SV.fontSizeTrackerInferno + 4) .. "|soft-shadow-thick")
    SanitysTrackerInfernoLabel1:SetFont("$(BOLD_FONT)|" .. ST.SV.fontSizeTrackerInferno .. "|soft-shadow-thick")
    SanitysTrackerInfernoLabel2:SetFont("$(BOLD_FONT)|" .. ST.SV.fontSizeTrackerInferno .. "|soft-shadow-thick")
    SanitysTrackerInfernoLabel3:SetFont("$(BOLD_FONT)|" .. ST.SV.fontSizeTrackerInferno .. "|soft-shadow-thick")
    SanitysTrackerInfernoLabel4:SetFont("$(BOLD_FONT)|" .. ST.SV.fontSizeTrackerInferno .. "|soft-shadow-thick")

    SanitysTrackerBoltTitle:SetFont("$(BOLD_FONT)|" .. (ST.SV.fontSizeTrackerBolt + 4) .. "|soft-shadow-thick")
    SanitysTrackerBoltLabel1:SetFont("$(BOLD_FONT)|" .. ST.SV.fontSizeTrackerBolt .. "|soft-shadow-thick")
    SanitysTrackerBoltLabel2:SetFont("$(BOLD_FONT)|" .. ST.SV.fontSizeTrackerBolt .. "|soft-shadow-thick")
    SanitysTrackerBoltLabel3:SetFont("$(BOLD_FONT)|" .. ST.SV.fontSizeTrackerBolt .. "|soft-shadow-thick")
    SanitysTrackerBoltLabel4:SetFont("$(BOLD_FONT)|" .. ST.SV.fontSizeTrackerBolt .. "|soft-shadow-thick")
end


----------------------------------
-- INITIALISIERUNG AFTER RELOAD --
----------------------------------
function SanitysTracker.Initialize()
    ST.SV = ZO_SavedVars:NewAccountWide(ST.SVName, ST.SVVersion, GetWorldName(), ST.default)

    if not ST.forceShow then
        SanitysTrackerPortal:SetHidden(true)
        SanitysTrackerInferno:SetHidden(true)
        SanitysTrackerBolt:SetHidden(true)
    end

    ST.SetFonts()
    ST.RestorePosition()
    ST.AddonMenu()

    EVENT_MANAGER:RegisterForEvent(ST.name, EVENT_PLAYER_ACTIVATED, ST.CheckZone)

    ST.CheckZone()
end


-------------------------
-- EVENT_ADD_ON_LOADED --
-------------------------
function SanitysTracker.OnAddOnLoaded(event, addonName)
    if addonName == ST.name then
        ST.Initialize()
        EVENT_MANAGER:UnregisterForEvent(ST.name, EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent(ST.name, EVENT_ADD_ON_LOADED, ST.OnAddOnLoaded)