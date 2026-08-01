CombatCloudDefaults = {
    unlocked = false,
---------------------------------------------------------------------------------------------------------------------------------------
    --//PANEL DEFAULTS//--
---------------------------------------------------------------------------------------------------------------------------------------
    panels = {
    --Outgoing
        CombatCloud_Outgoing = {
            point                   = CENTER,
            relativePoint           = CENTER,
            offsetX                 = 0,
            offsetY                 = - GuiRoot:GetHeight() / 4,
            dimensions              = { 400, 200 },
        },
    --Incoming
        CombatCloud_Incoming = {
            point                   = CENTER,
            relativePoint           = CENTER,
            offsetX                 = 0,
            offsetY                 = GuiRoot:GetHeight() / 4,
            dimensions              = { 400, 100 },
        },
    --Alerts
        CombatCloud_Alert = {
            point                   = CENTER,
            relativePoint           = CENTER,
            offsetX                 = - GuiRoot:GetWidth() / 5,
            offsetY                 = 0,
            dimensions              = { 400, 100 },
        },
    --Points
        CombatCloud_Point = {
            point                   = CENTER,
            relativePoint           = CENTER,
            offsetX                 = GuiRoot:GetWidth() / 3.2,
            offsetY                 = - GuiRoot:GetHeight() / 2.65,
            dimensions              = { 400, 100 },
        },
    --Resources
        CombatCloud_Resource = {
            point                   = CENTER,
            relativePoint           = CENTER,
            offsetX                 = GuiRoot:GetWidth() / 5,
            offsetY                 = 0,
            dimensions              = { 400, 100 },
        }
    },
---------------------------------------------------------------------------------------------------------------------------------------
    --//TOGGLE DEFAULTS//--
---------------------------------------------------------------------------------------------------------------------------------------
    toggles     = {
    --General
        inCombatOnly                = false,
        showThrottleTrailer         = true,
        throttleCriticals           = false,
    ----------------------------------
        incoming    = {
    --Damage & Healing
            showDamage              = true,
            showHealing             = true,
            showEnergize            = false,
            showUltimateEnergize    = false,
            showDrain               = false,
            showDot                 = true,
            showHot                 = true,
    --Mitigation
            showMiss                = true,
            showImmune              = true,
            showParried             = true,
            showReflected           = true,
            showDamageShield        = true,
            showDodged              = true,
            showBlocked             = true,
            showInterrupted         = true,
    --Crowd Control
            showDisoriented         = true,
            showFeared              = true,
            showOffBalanced         = true,
            showSilenced            = true,
            showStunned             = true,
        },
    ----------------------------------
        outgoing    = {
    --Damage & Healing
            showDamage              = true,
            showHealing             = true,
            showEnergize            = false,
            showUltimateEnergize    = false,
            showDrain               = false,
            showDot                 = true,
            showHot                 = true,
    --Mitigation
            showMiss                = true,
            showImmune              = true,
            showParried             = true,
            showReflected           = true,
            showDamageShield        = true,
            showDodged              = true,
            showBlocked             = true,
            showInterrupted         = true,
    --Crowd Control
            showDisoriented         = true,
            showFeared              = true,
            showOffBalanced         = true,
            showSilenced            = true,
            showStunned             = true,
        },
    ----------------------------------
    --Combat State
        showInCombat                = true,
        showOutCombat               = true,
    ----------------------------------
    --Alerts
        showAlertCleanse            = true,
        showAlertBlock              = true,
        showAlertExploit            = true,
        showAlertInterrupt          = true,
        showAlertDodge              = true,
        showAlertExecute            = false,
        hideIngameTips              = true,
    ----------------------------------
    --Points
        showPointsAlliance          = true,
        showPointsExperience        = true,
        showPointsChampion           = true,
    ----------------------------------
    --Resources
        showLowHealth               = true,
        showLowStamina              = true,
        showLowMagicka              = true,
        showUltimate                = true,
        showPotionReady             = true,
        warningSound                = true,
    ----------------------------------
    --Colors
        criticalDamageOverride      = false,
        criticalHealingOverride     = false,
    },
---------------------------------------------------------------------------------------------------------------------------------------
    --//OTHER DEFAULTS//--
---------------------------------------------------------------------------------------------------------------------------------------
    healthThreshold                 = 35,
    magickaThreshold                = 35,
    staminaThreshold                = 35,
    executeThreshold                = 20,
    executeFrequency                = 8,
---------------------------------------------------------------------------------------------------------------------------------------
    --//FONT DEFAULTS//--
---------------------------------------------------------------------------------------------------------------------------------------
    fontFace                        = [[Roboto Bold]],
    fontOutline                     = [[soft-shadow-thick]],
    ----------------------------------
    fontSizes = {
    --Combat
        damage                      = 26,
        healing                     = 26,
        tick                        = 18,
        gainLoss                    = 18,
        critical                    = 36,
        mitigation                  = 30,
        crowdControl                = 36,
    ----------------------------------
    --Combat State, Points, Alerts & Resources
        combatState                 = 32,
        alert                       = 44,
        point                       = 32,
        resource                    = 44,
    },
---------------------------------------------------------------------------------------------------------------------------------------
    --//COLOR DEFAULTS//--
---------------------------------------------------------------------------------------------------------------------------------------
    colors = {
    --Damage & Healing
        damage = {
            [DAMAGE_TYPE_NONE]      = { 1, 1, 1, 1 },                       --RGB(255, 255, 255)
            [DAMAGE_TYPE_GENERIC]   = { 1, 1, 1, 1 },                       --RGB(255, 255, 255)
            [DAMAGE_TYPE_PHYSICAL]  = { 0.784314, 0.784314, 0.627451, 1 },  --RGB(200, 200, 160)
            [DAMAGE_TYPE_FIRE]      = { 0.901961, 0.392157, 0.078431, 1 },  --RGB(230, 100, 20)
            [DAMAGE_TYPE_SHOCK]     = { 0.588235, 0.392157, 0.784314, 1 },  --RGB(150, 100, 200)
            [DAMAGE_TYPE_OBLIVION]  = { 0.784314, 0.215686, 0.529412, 1 },  --RGB(200, 35, 135)
            [DAMAGE_TYPE_COLD]      = { 0.588235, 0.705882, 0.862745, 1 },  --RGB(150, 180, 220)
            [DAMAGE_TYPE_EARTH]     = { 0.588235, 0.490196, 0.274510, 1 },  --RGB(150, 125, 70)
            [DAMAGE_TYPE_MAGIC]     = { 0.137255, 0.588235, 0.784314, 1 },  --RGB(35, 150, 200)
            [DAMAGE_TYPE_DROWN]     = { 0.274510, 0.666667, 1, 1 },         --RGB(70, 170, 255)
            [DAMAGE_TYPE_DISEASE]   = { 0.392157, 0.784314, 0.588235, 1 },  --RGB(100, 200, 150)
            [DAMAGE_TYPE_POISON]    = { 0.392157, 0.784314, 0.392157, 1 }   --RGB(100, 200, 100)
            },
        healing                     = { 0.823529, 0.803922, 0.490196, 1 },  --RGB(210, 205, 125)
        energizeMagicka             = { 0.137255, 0.588235, 0.784314, 1 },  --RGB(35, 150, 200)
        energizeStamina             = { 0.235294, 0.784314, 0.313725, 1 },  --RGB(60, 200, 80)
        energizeUltimate            = { 0.862745, 1, 0.313725, 1 },         --RGB(220, 255, 80)
        drainMagicka                = { 0.137255, 0.588235, 0.784314, 1 },  --RGB(35, 150, 200)
        drainStamina                = { 0.235294, 0.784314, 0.313725, 1 },  --RGB(60, 200, 80)
        criticalDamageOverride      = { 1, 0, 0, 1 },
        criticalHealingOverride     = { 0, 1, 0, 1 },
    ----------------------------------
    --Mitigation
        miss                        = { 1, 1, 1, 1 },                       --RGB(255, 255, 255)
        immune                      = { 0.901961, 0.196078, 0.098039, 1 },  --RGB(230, 50, 25)
        parried                     = { 0.588235, 0.705882, 0.862745, 1 },  --RGB(150, 180, 220)
        reflected                   = { 0.901961, 0.392157, 0.078431, 1 },  --RGB(230, 100, 20)
        damageShield                = { 1, 0.549020, 0.078431, 1 },         --RGB(255, 140, 20)
        dodged                      = { 0.862745, 1, 0.313725, 1 },         --RGB(220, 255, 80)
        blocked                     = { 0.235294, 0.784314, 0.313725, 1 },  --RGB(60, 200, 80)
        interrupted                 = { 0.235294, 0.784314, 0.313725, 1 },  --RGB(60, 200, 80)
    ----------------------------------
    --Crowd Control
        disoriented                 = { 0.588235, 0.392157, 0.784314, 1 },  --RGB(150, 100, 200)
        feared                      = { 0.784314, 0.215686, 0.529412, 1 },  --RGB(200, 35, 135)
        offBalanced                 = { 0.784314, 0.784314, 0.627451, 1 },  --RGB(200, 200, 160)
        silenced                    = { 0.137255, 0.588235, 0.784314, 1 },  --RGB(35, 150, 200)
        stunned                     = { 0.901961, 0.196078, 0.098039, 1 },  --RGB(230, 50, 25)
    ----------------------------------
    --Combat State
        inCombat                    = { 1, 1, 1, 1 },                       --RGB(255, 255, 255)
        outCombat                   = { 1, 1, 1, 1 },                       --RGB(255, 255, 255)
    ----------------------------------
    --Alerts
        alertCleanse                = { 0.823529, 0.803922, 0.490196, 1 },  --RGB(210, 205, 125)
        alertBlock                  = { 0.235294, 0.784314, 0.313725, 1 },  --RGB(60, 200, 80)
        alertExploit                = { 0.784314, 0.784314, 0.627451, 1 },  --RGB(200, 200, 160)
        alertInterrupt              = { 0.901961, 0.196078, 0.098039, 1 },  --RGB(230, 50, 25)
        alertDodge                  = { 0.862745, 1, 0.313725, 1 },         --RGB(220, 255, 80)
        alertExecute                = { 0.894118, 0.133333, 0.090196, 1 },  --RGB(228, 34, 23)
    ----------------------------------
    --Points
        pointsAlliance              = { 0.235294, 0.784314, 0.313725, 1 },  --RGB(60, 200, 80)
        pointsExperience            = { 0.588235, 0.705882, 0.862745, 1 },  --RGB(150, 180, 220)
        pointsChampion               = { 0.784314, 0.784314, 0.627451, 1 },  --RGB(200, 200, 160)
    ----------------------------------
    --Resources
        lowHealth                   = { 0.901961, 0.196078, 0.098039, 1 },  --RGB(230, 50, 25)
        lowMagicka                  = { 0.137255, 0.588235, 0.784314, 1 },  --RGB(35, 150, 200)
        lowStamina                  = { 0.235294, 0.784314, 0.313725, 1 },  --RGB(60, 200, 80)
        ultimateReady               = { 0.862745, 1, 0.313725, 1 },         --RGB(220, 255, 80)
        potionReady                 = { 0.470588, 0.156863, 0.745098, 1 },  --RGB(120, 40, 190)
    },
---------------------------------------------------------------------------------------------------------------------------------------
    --//FORMAT DEFAULTS//--
---------------------------------------------------------------------------------------------------------------------------------------
    formats = {
    --Damage & Healing
        damage                      = "%a",
        healing                     = "Healed %a",
        energize                    = "Restored %a (%r)",
        ultimateEnergize            = "Gained %a (%r)",
        drain                       = "Drained %a (%r)",
        dot                         = "%a",
        hot                         = "%a",
        critical                    = "%a!",
    ----------------------------------
    --Mitigation
        miss                        = "Missed",
        immune                      = "Immune",
        parried                     = "Parried",
        reflected                   = "Reflected",
        damageShield                = "Absorbed %a",
        dodged                      = "Dodged",
        blocked                     = "Blocked %a",
        interrupted                 = "Interrupted",
    ----------------------------------
    --Crowd Control
        disoriented                 = "%t",
        feared                      = "%t",
        offBalanced                 = "%t",
        silenced                    = "%t",
        stunned                     = "%t",
    ----------------------------------
    --Combat State
        inCombat                    = "Entered Combat",
        outCombat                   = "Left Combat",
    ----------------------------------
    --Alerts
        alertCleanse                = "%t!",
        alertBlock                  = "%t!",
        alertExploit                = "%t!",
        alertInterrupt              = "%t!",
        alertDodge                  = "%t!",
        alertExecute                = "%t!",
    ----------------------------------
    --Points
        pointsAlliance              = "%a AP",
        pointsExperience            = "%a XP",
        pointsChampion               = "%a CP",
    ----------------------------------
    --Resources
        resource                    = "%t! (%a)",
        ultimateReady               = "%t!",
        potionReady                 = "%t!",
    },
---------------------------------------------------------------------------------------------------------------------------------------
    --//ANIMATION DEFAULTS//--
---------------------------------------------------------------------------------------------------------------------------------------
    animation = {
        animationType               = "hybrid",
        outgoingIcon                = "none",
        incomingIcon                = "none",
        outgoing = {
            directionType           = "up",
            speed                   = 2000,
        },
        incoming = {
            directionType           = "down",
            speed                   = 2000,
        }
    },
---------------------------------------------------------------------------------------------------------------------------------------
    --//THROTTLE DEFAULTS//--
---------------------------------------------------------------------------------------------------------------------------------------
    throttles   = {
        damage                      = 200,
        healing                     = 200,
        dot                         = 350,
        hot                         = 350,
    },
}