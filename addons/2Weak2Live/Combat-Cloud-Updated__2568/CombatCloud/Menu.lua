local LAM2          = LibAddonMenu2
local LMP           = LibMediaProvider
local L             = CombatCloudLocalization
local D             = CombatCloudDefaults

---------------------------------------------------------------------------------------------------------------------------------------
    --//MAIN//--
---------------------------------------------------------------------------------------------------------------------------------------
local panelData = {
    type         = "panel",
    name         = "Combat Cloud",
    displayName  = ZO_HIGHLIGHT_TEXT:Colorize("Combat Cloud"),
    author       = "Sideshow & Garkin & TooWeak2Live",
    version      = "0.96",
    slashCommand = "/combatcloud",
    registerForRefresh = true,
    registerForDefaults = true,
    resetFunc = function() --RESET PANELS WHEN RESET TO DEFAULTS IS PRESSED
        CombatCloudSettings.unlocked = not CombatCloudSettings.unlocked
        for k, v in pairs (CombatCloudDefaults.panels) do
            local s = CombatCloudSettings.panels[k]
            s.point = v.point
            s.relativePoint = v.relativePoint
            s.offsetX = v.offsetX
            s.offsetY = v.offsetY
            s.dimensions = v.dimensions
            _G[k]:ClearAnchors()
            _G[k]:SetAnchor(s.point, CombatCloud, s.relativePoint, s.offsetX, s.offsetY)
            _G[k]:SetDimensions(unpack(s.dimensions))
            _G[k .. '_Backdrop']:SetHidden(not CombatCloudSettings.unlocked)
            _G[k .. '_Label']:SetHidden(not CombatCloudSettings.unlocked)
        end
    end,
}
local optionsData = {
    {
        type = "description",
        text = "Sideshow's Combat Cloud, modified by @Garkin and @TooWeak2Live",
    },
    {--UNLOCK PANELS
        type    = "checkbox",
        name    = L.unlock,
        tooltip = L.unlockTooltip,
        default = CombatCloudDefaults.unlocked,
        getFunc = function() return CombatCloudSettings.unlocked end,
        setFunc = function()
            CombatCloudSettings.unlocked = not CombatCloudSettings.unlocked
            for k, _ in pairs (CombatCloudSettings.panels) do
                _G[k]:SetMouseEnabled(CombatCloudSettings.unlocked)
                _G[k]:SetMovable(CombatCloudSettings.unlocked)
                _G[k .. '_Backdrop']:SetHidden(not CombatCloudSettings.unlocked)
                _G[k .. '_Label']:SetHidden(not CombatCloudSettings.unlocked)
            end
        end,
    },
---------------------------------------------------------------------------------------------------------------------------------------
    --//TOGGLE OPTIONS//--
---------------------------------------------------------------------------------------------------------------------------------------
    {
        type    = "checkbox",
        name    = L.inCombatOnly,
        tooltip = L.tooltipInCombatOnly,
        getFunc = function() return CombatCloudSettings.toggles.inCombatOnly end,
        setFunc = function(v) CombatCloudSettings.toggles.inCombatOnly = v end,
        default = D.toggles.inCombatOnly,
    },
    {
        type = "submenu",
        name = L.buttonToggleIncoming,
        controls = {
        --INCOMING DAMAGE & HEALING
            {
                type = "header",
                name = L.headerToggleIncomingDamageHealing,
            },
                {--DAMAGE
                    type    = "checkbox",
                    name    = L.damage,
                    tooltip = L.tooltipIncomingDamage,
                    getFunc = function() return CombatCloudSettings.toggles.incoming.showDamage end,
                    setFunc = function(v) CombatCloudSettings.toggles.incoming.showDamage = v end,
                    default = D.toggles.incoming.showDamage,
                },
                {--HEALING
                    type    = "checkbox",
                    name    = L.healing,
                    tooltip = L.tooltipIncomingHealing,
                    getFunc = function() return CombatCloudSettings.toggles.incoming.showHealing end,
                    setFunc = function(v) CombatCloudSettings.toggles.incoming.showHealing = v end,
                    default = D.toggles.incoming.showHealing,
                },
                {--ENERGIZE
                    type    = "checkbox",
                    name    = L.energize,
                    tooltip = L.tooltipIncomingEnergize,
                    getFunc = function() return CombatCloudSettings.toggles.incoming.showEnergize end,
                    setFunc = function(v) CombatCloudSettings.toggles.incoming.showEnergize = v end,
                    default = D.toggles.incoming.showEnergize,
                },
                {--ULTIMATE ENERGIZE
                    type    = "checkbox",
                    name    = L.ultimateEnergize,
                    tooltip = L.tooltipIncomingUltimateEnergize,
                    getFunc = function() return CombatCloudSettings.toggles.incoming.showUltimateEnergize end,
                    setFunc = function(v) CombatCloudSettings.toggles.incoming.showUltimateEnergize = v end,
                    default = D.toggles.incoming.showUltimateEnergize,
                },
                {--DRAIN
                    type    = "checkbox",
                    name    = L.drain,
                    tooltip = L.tooltipIncomingDrain,
                    getFunc = function() return CombatCloudSettings.toggles.incoming.showDrain end,
                    setFunc = function(v) CombatCloudSettings.toggles.incoming.showDrain = v end,
                    default = D.toggles.incoming.showDrain,
                },
                {--DOT
                    type    = "checkbox",
                    name    = L.dot,
                    tooltip = L.tooltipIncomingDot,
                    getFunc = function() return CombatCloudSettings.toggles.incoming.showDot end,
                    setFunc = function(v) CombatCloudSettings.toggles.incoming.showDot = v end,
                    default = D.toggles.incoming.showDot,
                },
                {--HOT
                    type    = "checkbox",
                    name    = L.hot,
                    tooltip = L.tooltipIncomingHot,
                    getFunc = function() return CombatCloudSettings.toggles.incoming.showHot end,
                    setFunc = function(v) CombatCloudSettings.toggles.incoming.showHot = v end,
                    default = D.toggles.incoming.showHot,
                },
        --INCOMING MITIGATION
            {
                type = "header",
                name = L.headerToggleIncomingMitigation,
            },
                {--MISS
                    type    = "checkbox",
                    name    = L.miss,
                    tooltip = L.tooltipIncomingMiss,
                    getFunc = function() return CombatCloudSettings.toggles.incoming.showMiss end,
                    setFunc = function(v) CombatCloudSettings.toggles.incoming.showMiss = v end,
                    default = D.toggles.incoming.showMiss
                },
                {--IMMUNE
                    type    = "checkbox",
                    name    = L.immune,
                    tooltip = L.tooltipIncomingImmune,
                    getFunc = function() return CombatCloudSettings.toggles.incoming.showImmune end,
                    setFunc = function(v) CombatCloudSettings.toggles.incoming.showImmune = v end,
                    default = D.toggles.incoming.showImmune,
                },
                {--PARRIED
                    type    = "checkbox",
                    name    = L.parried,
                    tooltip = L.tooltipIncomingParried,
                    getFunc = function() return CombatCloudSettings.toggles.incoming.showParried end,
                    setFunc = function(v) CombatCloudSettings.toggles.incoming.showParried = v end,
                    default = D.toggles.incoming.showParried,
                },
                {--REFLECT
                    type    = "checkbox",
                    name    = L.reflected,
                    tooltip = L.tooltipIncomingReflected,
                    getFunc = function() return CombatCloudSettings.toggles.incoming.showReflected end,
                    setFunc = function(v) CombatCloudSettings.toggles.incoming.showReflected = v end,
                    default = D.toggles.incoming.showReflected,
                },
                {--DAMAGESHIELD
                    type    = "checkbox",
                    name    = L.damageShield,
                    tooltip = L.tooltipIncomingDamageShield,
                    getFunc = function() return CombatCloudSettings.toggles.incoming.showDamageShield end,
                    setFunc = function(v) CombatCloudSettings.toggles.incoming.showDamageShield = v end,
                    default = D.toggles.incoming.showDamageShield,
                },
                {--DODGE
                    type    = "checkbox",
                    name    = L.dodged,
                    tooltip = L.tooltipIncomingDodge,
                    getFunc = function() return CombatCloudSettings.toggles.incoming.showDodged end,
                    setFunc = function(v) CombatCloudSettings.toggles.incoming.showDodged = v end,
                    default = D.toggles.incoming.showDodged,
                },
                {--BLOCK
                    type    = "checkbox",
                    name    = L.blocked,
                    tooltip = L.tooltipIncomingBlocked,
                    getFunc = function() return CombatCloudSettings.toggles.incoming.showBlocked end,
                    setFunc = function(v) CombatCloudSettings.toggles.incoming.showBlocked = v end,
                    default = D.toggles.incoming.showBlocked,
                },
                {--INTERRUPT
                    type    = "checkbox",
                    name    = L.interrupted,
                    tooltip = L.tooltipIncomingInterrupted,
                    getFunc = function() return CombatCloudSettings.toggles.incoming.showInterrupted end,
                    setFunc = function(v) CombatCloudSettings.toggles.incoming.showInterrupted = v end,
                    default = D.toggles.incoming.showInterrupted,
                },
        --INCOMING CROWD CONTROL
            {
                type = "header",
                name = L.headerToggleIncomingCrowdControl,
            },
                {--DISORIENTED
                    type    = "checkbox",
                    name    = L.disoriented,
                    tooltip = L.tooltipIncomingDisoriented,
                    getFunc = function() return CombatCloudSettings.toggles.incoming.showDisoriented end,
                    setFunc = function(v) CombatCloudSettings.toggles.incoming.showDisoriented = v end,
                    default = D.toggles.incoming.showDisoriented,
                },
                {--FEARED
                    type    = "checkbox",
                    name    = L.feared,
                    tooltip = L.tooltipIncomingFeared,
                    getFunc = function() return CombatCloudSettings.toggles.incoming.showFeared end,
                    setFunc = function(v) CombatCloudSettings.toggles.incoming.showFeared = v end,
                    default = D.toggles.incoming.showFeared,
                },
                {--OFF BALANCED
                    type    = "checkbox",
                    name    = L.offBalanced,
                    tooltip = L.tooltipIncomingOffBalanced,
                    getFunc = function() return CombatCloudSettings.toggles.incoming.showOffBalanced end,
                    setFunc = function(v) CombatCloudSettings.toggles.incoming.showOffBalanced = v end,
                    default = D.toggles.incoming.showOffBalanced,
                },
                {--SILENCED
                    type    = "checkbox",
                    name    = L.silenced,
                    tooltip = L.tooltipIncomingSilenced,
                    getFunc = function() return CombatCloudSettings.toggles.incoming.showSilenced end,
                    setFunc = function(v) CombatCloudSettings.toggles.incoming.showSilenced = v end,
                    default = D.toggles.incoming.showSilenced,
                },
                {--STUNNED
                    type    = "checkbox",
                    name    = L.stunned,
                    tooltip = L.tooltipIncomingStunned,
                    getFunc = function() return CombatCloudSettings.toggles.incoming.showStunned end,
                    setFunc = function(v) CombatCloudSettings.toggles.incoming.showStunned = v end,
                    default = D.toggles.incoming.showStunned,
                },
            },
        },
    {
        type = "submenu",
        name = L.buttonToggleOutgoing,
        controls = {
        --OUTGOING DAMAGE & HEALING
            {
                type = "header",
                name = L.headerToggleOutgoingDamageHealing,
            },
                {--DAMAGE
                    type    = "checkbox",
                    name    = L.damage,
                    tooltip = L.tooltipOutgoingDamage,
                    getFunc = function() return CombatCloudSettings.toggles.outgoing.showDamage end,
                    setFunc = function(v) CombatCloudSettings.toggles.outgoing.showDamage = v end,
                    default = D.toggles.outgoing.showDamage,
                },
                {--HEALING
                    type    = "checkbox",
                    name    = L.healing,
                    tooltip = L.tooltipOutgoingHealing,
                    getFunc = function() return CombatCloudSettings.toggles.outgoing.showHealing end,
                    setFunc = function(v) CombatCloudSettings.toggles.outgoing.showHealing = v end,
                    default = D.toggles.outgoing.showHealing,
                },
                {--ENERGIZE
                    type    = "checkbox",
                    name    = L.energize,
                    tooltip = L.tooltipOutgoingEnergize,
                    getFunc = function() return CombatCloudSettings.toggles.outgoing.showEnergize end,
                    setFunc = function(v) CombatCloudSettings.toggles.outgoing.showEnergize = v end,
                    default = D.toggles.outgoing.showEnergize,
                },
                {--ULTIMATE ENERGIZE
                    type    = "checkbox",
                    name    = L.ultimateEnergize,
                    tooltip = L.tooltipOutgoingUltimateEnergize,
                    getFunc = function() return CombatCloudSettings.toggles.outgoing.showUltimateEnergize end,
                    setFunc = function(v) CombatCloudSettings.toggles.outgoing.showUltimateEnergize = v end,
                    default = D.toggles.outgoing.showUltimateEnergize,
                },
                {--DRAIN
                    type    = "checkbox",
                    name    = L.drain,
                    tooltip = L.tooltipOutgoingDrain,
                    getFunc = function() return CombatCloudSettings.toggles.outgoing.showDrain end,
                    setFunc = function(v) CombatCloudSettings.toggles.outgoing.showDrain = v end,
                    default = D.toggles.outgoing.showDrain,
                },
                {--DOT
                    type    = "checkbox",
                    name    = L.dot,
                    tooltip = L.tooltipOutgoingDot,
                    getFunc = function() return CombatCloudSettings.toggles.outgoing.showDot end,
                    setFunc = function(v) CombatCloudSettings.toggles.outgoing.showDot = v end,
                    default = D.toggles.outgoing.showDot,
                },
                {--HOT
                    type    = "checkbox",
                    name    = L.hot,
                    tooltip = L.tooltipOutgoingHot,
                    getFunc = function() return CombatCloudSettings.toggles.outgoing.showHot end,
                    setFunc = function(v) CombatCloudSettings.toggles.outgoing.showHot = v end,
                    default = D.toggles.outgoing.showHot,
                },
        --OUTGOING MITIGATION
            {
                type = "header",
                name = L.headerToggleOutgoingMitigation,
            },
                {--MISS
                    type    = "checkbox",
                    name    = L.miss,
                    tooltip = L.tooltipOutgoingMiss,
                    getFunc = function() return CombatCloudSettings.toggles.outgoing.showMiss end,
                    setFunc = function(v) CombatCloudSettings.toggles.outgoing.showMiss = v end,
                    default = D.toggles.outgoing.showMiss,
                },
                {--IMMUNE
                    type    = "checkbox",
                    name    = L.immune,
                    tooltip = L.tooltipOutgoingImmune,
                    getFunc = function() return CombatCloudSettings.toggles.outgoing.showImmune end,
                    setFunc = function(v) CombatCloudSettings.toggles.outgoing.showImmune = v end,
                    default = D.toggles.outgoing.showImmune,
                },
                {--PARRIED
                    type    = "checkbox",
                    name    = L.parried,
                    tooltip = L.tooltipOutgoingParried,
                    getFunc = function() return CombatCloudSettings.toggles.outgoing.showParried end,
                    setFunc = function(v) CombatCloudSettings.toggles.outgoing.showParried = v end,
                    default = D.toggles.outgoing.showParried,
                },
                {--DAMAGESHIELD
                    type    = "checkbox",
                    name    = L.damageShield,
                    tooltip = L.tooltipOutgoingDamageShield,
                    getFunc = function() return CombatCloudSettings.toggles.outgoing.showDamageShield end,
                    setFunc = function(v) CombatCloudSettings.toggles.outgoing.showDamageShield = v end,
                    default = D.toggles.outgoing.showDamageShield,
                },
                {--DODGE
                    type    = "checkbox",
                    name    = L.dodged,
                    tooltip = L.tooltipOutgoingDodge,
                    getFunc = function() return CombatCloudSettings.toggles.outgoing.showDodged end,
                    setFunc = function(v) CombatCloudSettings.toggles.outgoing.showDodged = v end,
                    default = D.toggles.outgoing.showDodged,
                },
                {--BLOCK
                    type    = "checkbox",
                    name    = L.blocked,
                    tooltip = L.tooltipOutgoingBlocked,
                    getFunc = function() return CombatCloudSettings.toggles.outgoing.showBlocked end,
                    setFunc = function(v) CombatCloudSettings.toggles.outgoing.showBlocked = v end,
                    default = D.toggles.outgoing.showBlocked,
                },
                {--INTERRUPT
                    type    = "checkbox",
                    name    = L.interrupted,
                    tooltip = L.tooltipOutgoingInterrupted,
                    getFunc = function() return CombatCloudSettings.toggles.outgoing.showInterrupted end,
                    setFunc = function(v) CombatCloudSettings.toggles.outgoing.showInterrupted = v end,
                    default = D.toggles.outgoing.showInterrupted,
                },
        --OUTGOING CROWD CONTROL
            {
                type = "header",
                name = L.headerToggleOutgoingCrowdControl,
            },
                {--DISORIENTED
                    type    = "checkbox",
                    name    = L.disoriented,
                    tooltip = L.tooltipOutgoingDisoriented,
                    getFunc = function() return CombatCloudSettings.toggles.outgoing.showDisoriented end,
                    setFunc = function(v) CombatCloudSettings.toggles.outgoing.showDisoriented = v end,
                    default = D.toggles.outgoing.showDisoriented,
                },
                {--FEARED
                    type    = "checkbox",
                    name    = L.feared,
                    tooltip = L.tooltipOutgoingFeared,
                    getFunc = function() return CombatCloudSettings.toggles.outgoing.showFeared end,
                    setFunc = function(v) CombatCloudSettings.toggles.outgoing.showFeared = v end,
                    default = D.toggles.outgoing.showFeared,
                },
                {--OFF BALANCED
                    type    = "checkbox",
                    name    = L.offBalanced,
                    tooltip = L.tooltipOutgoingOffBalanced,
                    getFunc = function() return CombatCloudSettings.toggles.outgoing.showOffBalanced end,
                    setFunc = function(v) CombatCloudSettings.toggles.outgoing.showOffBalanced = v end,
                    default = D.toggles.outgoing.showOffBalanced,
                },
                {--SILENCED
                    type    = "checkbox",
                    name    = L.silenced,
                    tooltip = L.tooltipOutgoingSilenced,
                    getFunc = function() return CombatCloudSettings.toggles.outgoing.showSilenced end,
                    setFunc = function(v) CombatCloudSettings.toggles.outgoing.showSilenced = v end,
                    default = D.toggles.outgoing.showSilenced,
                },
                {--STUNNED
                    type    = "checkbox",
                    name    = L.stunned,
                    tooltip = L.tooltipOutgoingStunned,
                    getFunc = function() return CombatCloudSettings.toggles.outgoing.showStunned end,
                    setFunc = function(v) CombatCloudSettings.toggles.outgoing.showStunned = v end,
                    default = D.toggles.outgoing.showStunned,
                },
            },
        },
    {
        type = "submenu",
        name = L.buttonToggleNotification,
        controls = {
        --TOGGLE COMBAT STATE
            {
                type = "header",
                name = L.headerToggleCombatState,
            },
                {--IN COMBAT
                    type    = "checkbox",
                    name    = L.inCombat,
                    tooltip = L.tooltipInCombat,
                    getFunc = function() return CombatCloudSettings.toggles.showInCombat end,
                    setFunc = function(v) CombatCloudSettings.toggles.showInCombat = v end,
                    default = D.toggles.showInCombat,
                },
                {--OUT OF COMBAT
                    type    = "checkbox",
                    name    = L.outCombat,
                    tooltip = L.tooltipOutCombat,
                    getFunc = function() return CombatCloudSettings.toggles.showOutCombat end,
                    setFunc = function(v) CombatCloudSettings.toggles.showOutCombat = v end,
                    default = D.toggles.showOutCombat,
                },
        --TOGGLE ALERTS
            {
                type = "header",
                name = L.headerToggleAlert,
            },
                {
                    type = "description",
                    text = L.descriptionAlert,
                },
                {--CLEANSE
                    type    = "checkbox",
                    name    = L.alertCleanse,
                    tooltip = L.tooltipAlertsCleanse,
                    getFunc = function() return CombatCloudSettings.toggles.showAlertCleanse end,
                    setFunc = function(v) CombatCloudSettings.toggles.showAlertCleanse = v end,
                    default = D.toggles.showAlertCleanse,
                },
                {--BLOCK
                    type    = "checkbox",
                    name    = L.alertBlock,
                    tooltip = L.tooltipAlertsBlock,
                    getFunc = function() return CombatCloudSettings.toggles.showAlertBlock end,
                    setFunc = function(v) CombatCloudSettings.toggles.showAlertBlock = v end,
                    default = D.toggles.showAlertBlock,
                },
                {--EXPLOIT
                    type    = "checkbox",
                    name    = L.alertExploit,
                    tooltip = L.tooltipAlertsExploit,
                    getFunc = function() return CombatCloudSettings.toggles.showAlertExploit end,
                    setFunc = function(v) CombatCloudSettings.toggles.showAlertExploit = v end,
                    default = D.toggles.showAlertExploit,
                },
                {--INTERRUPT
                    type    = "checkbox",
                    name    = L.alertInterrupt,
                    tooltip = L.tooltipAlertsInterrupt,
                    getFunc = function() return CombatCloudSettings.toggles.showAlertInterrupt end,
                    setFunc = function(v) CombatCloudSettings.toggles.showAlertInterrupt = v end,
                    default = D.toggles.showAlertInterrupt,
                },
                {--DODGE
                    type    = "checkbox",
                    name    = L.alertDodge,
                    tooltip = L.tooltipAlertsDodge,
                    getFunc = function() return CombatCloudSettings.toggles.showAlertDodge end,
                    setFunc = function(v) CombatCloudSettings.toggles.showAlertDodge = v end,
                    default = D.toggles.showAlertDodge,
                },
                {--EXECUTE
                    type    = "checkbox",
                    name    = L.alertExecute,
                    tooltip = L.tooltipAlertsExecute,
                    getFunc = function() return CombatCloudSettings.toggles.showAlertExecute end,
                    setFunc = function(v) CombatCloudSettings.toggles.showAlertExecute = v end,
                    default = D.toggles.showAlertExecute,
                },
                {--EXECUTE THRESHOLD SLIDER
                    type    = "slider",
                    name    = L.executeThreshold,
                    tooltip = L.tooltipExecuteThreshold,
                    min     = 10,
                    max     = 50,
                    getFunc = function() return CombatCloudSettings.executeThreshold end,
                    setFunc = function(v) CombatCloudSettings.executeThreshold = v end,
                    disabled = function() return not CombatCloudSettings.toggles.showAlertExecute end,
                    default = D.executeThreshold,
                },
                {--EXECUTE FREQUENCY SLIDER
                    type    = "slider",
                    name    = L.executeFrequency,
                    tooltip = L.tooltipExecuteFrequency,
                    min     = 1,
                    max     = 20,
                    getFunc = function() return CombatCloudSettings.executeFrequency end,
                    setFunc = function(v) CombatCloudSettings.executeFrequency = v end,
                    disabled = function() return not CombatCloudSettings.toggles.showAlertExecute end,
                    default = D.executeFrequency,
                },
                {--HIDE INGAME TIPS
                    type    = "checkbox",
                    name    = L.ingameTips,
                    tooltip = L.tooltipIngameTips,
                    getFunc = function() return CombatCloudSettings.toggles.hideIngameTips end,
                    setFunc = function(v) CombatCloudSettings.toggles.hideIngameTips = v; ZO_ActiveCombatTips:SetHidden(v) end,
                    default = D.toggles.hideIngameTips,
                },
        --TOGGLE POINTS
            {
                type = "header",
                name = L.headerTogglePoint,
            },
                {--ALLIANCE POINTS
                    type    = "checkbox",
                    name    = L.pointsAlliance,
                    tooltip = L.tooltipPointsAlliance,
                    getFunc = function() return CombatCloudSettings.toggles.showPointsAlliance end,
                    setFunc = function(v) CombatCloudSettings.toggles.showPointsAlliance = v end,
                    default = D.toggles.showPointsAlliance,
                },
                {--EXPERIENCE POINTS
                    type    = "checkbox",
                    name    = L.pointsExperience,
                    tooltip = L.tooltipPointsExperience,
                    getFunc = function() return CombatCloudSettings.toggles.showPointsExperience end,
                    setFunc = function(v) CombatCloudSettings.toggles.showPointsExperience = v end,
                    default = D.toggles.showPointsExperience,
                },
                {--CHAMPION POINTS
                    type    = "checkbox",
                    name    = L.pointsChampion,
                    tooltip = L.tooltipPointsChampion,
                    getFunc = function() return CombatCloudSettings.toggles.showPointsChampion end,
                    setFunc = function(v) CombatCloudSettings.toggles.showPointsChampion = v end,
                    default = D.toggles.showPointsChampion,
                },
            {
                type = "header",
                name = L.headerToggleResource,
            },
                {--LOW HEALTH
                    type    = "checkbox",
                    name    = L.lowHealth,
                    tooltip = L.tooltipLowHealth,
                    getFunc = function() return CombatCloudSettings.toggles.showLowHealth end,
                    setFunc = function(v) CombatCloudSettings.toggles.showLowHealth = v end,
                    default = D.toggles.showLowHealth,
                },
                {--LOW MAGICKA
                    type    = "checkbox",
                    name    = L.lowMagicka,
                    tooltip = L.tooltipLowMagicka,
                    getFunc = function() return CombatCloudSettings.toggles.showLowMagicka end,
                    setFunc = function(v) CombatCloudSettings.toggles.showLowMagicka = v end,
                    default = D.toggles.showLowMagicka,
                },
                {--LOW STAMINA
                    type    = "checkbox",
                    name    = L.lowStamina,
                    tooltip = L.tooltipLowStamina,
                    getFunc = function() return CombatCloudSettings.toggles.showLowStamina end,
                    setFunc = function(v) CombatCloudSettings.toggles.showLowStamina = v end,
                    default = D.toggles.showLowStamina,
                },
                {--ULTIMATE READY
                    type    = "checkbox",
                    name    = L.ultimateReady,
                    tooltip = L.tooltipUltimateReady,
                    getFunc = function() return CombatCloudSettings.toggles.showUltimate end,
                    setFunc = function(v) CombatCloudSettings.toggles.showUltimate = v end,
                    default = D.toggles.showUltimate,
                },
                {--POTION READY
                    type    = "checkbox",
                    name    = L.potionReady,
                    tooltip = L.tooltipPotionReady,
                    getFunc = function() return CombatCloudSettings.toggles.showPotionReady end,
                    setFunc = function(v) CombatCloudSettings.toggles.showPotionReady = v end,
                    default = D.toggles.showPotionReady,
                },
                {--WARNING SOUND
                    type    = "checkbox",
                    name    = L.warningSound,
                    tooltip = L.tooltipWarningSound,
                    getFunc = function() return CombatCloudSettings.toggles.warningSound end,
                    setFunc = function(v) CombatCloudSettings.toggles.warningSound = v end,
                    default = D.toggles.warningSound,
                },
                {--LOW HEALTH WARNING THRESHOLD SLIDER
                    type    = "slider",
                    name    = L.warningThresholdHealth,
                    tooltip = L.tooltipWarningThresholdHealth,
                    min     = 15,
                    max     = 50,
                    step    = 1,
                    getFunc = function() return CombatCloudSettings.healthThreshold end,
                    setFunc = function(threshold) CombatCloudSettings.healthThreshold = threshold end,
                    default = D.healthThreshold,
                },
                {--LOW MAGICKA WARNING THRESHOLD SLIDER
                    type    = "slider",
                    name    = L.warningThresholdMagicka,
                    tooltip = L.tooltipWarningThresholdMagicka,
                    min     = 15,
                    max     = 50,
                    step    = 1,
                    getFunc = function() return CombatCloudSettings.magickaThreshold end,
                    setFunc = function(threshold) CombatCloudSettings.magickaThreshold = threshold end,
                    default = D.magickaThreshold,
                },
                {--LOW STAMINA WARNING THRESHOLD SLIDER
                    type    = "slider",
                    name    = L.warningThresholdStamina,
                    tooltip = L.tooltipWarningThresholdStamina,
                    min     = 15,
                    max     = 50,
                    step    = 1,
                    getFunc = function() return CombatCloudSettings.staminaThreshold end,
                    setFunc = function(threshold) CombatCloudSettings.staminaThreshold = threshold end,
                    default = D.staminaThreshold,
                },
            },
        },
---------------------------------------------------------------------------------------------------------------------------------------
    --//FONT OPTIONS//--
---------------------------------------------------------------------------------------------------------------------------------------
    {
        type = "submenu",
        name = L.buttonFont,
        controls = {
                {--FONT FACE DROPDOWN
                    type    = "dropdown",
                    name    = L.fontFace,
                    tooltip = L.tooltipFontFace,
                    choices = LMP:List(LMP.MediaType.FONT),
                    getFunc = function() return CombatCloudSettings.fontFace end,
                    setFunc = function(face)
                        CombatCloudSettings.fontFace = face
                        for k, _ in pairs (CombatCloudSettings.panels) do
                            _G[k .. "_Label"]:SetFont(LMP:Fetch(LMP.MediaType.FONT, CombatCloudSettings.fontFace) .. "|26|" .. CombatCloudSettings.fontOutline)
                        end
                    end,
                    default = D.fontFace
                },
                {--FONT OUTLINE DROPDOWN
                    type    = "dropdown",
                    name    = L.fontOutline,
                    tooltip = L.tooltipFontOutline,
                    choices = CombatCloudConstants.outlineType,
                    getFunc = function() return CombatCloudSettings.fontOutline end,
                    setFunc = function(outline)
                        CombatCloudSettings.fontOutline = outline
                        for k, _ in pairs (CombatCloudSettings.panels) do
                            _G[k .. "_Label"]:SetFont(LMP:Fetch(LMP.MediaType.FONT, CombatCloudSettings.fontFace) .. "|26|" .. CombatCloudSettings.fontOutline)
                        end
                    end,
                    default = D.fontOutline
                },
                {--TEST FONT BUTTON
                    type = "button",
                    name = L.fontTest,
                    tooltip = L.tooltipFontTest,
                    func = function()
                        CALLBACK_MANAGER:FireCallbacks(CombatCloudConstants.eventType.COMBAT, CombatCloudConstants.combatType.INCOMING, POWERTYPE_STAMINA, math.random(7, 777), L.fontTest, 41567, DAMAGE_TYPE_PHYSICAL, true, false, false, false, false, false, false, false, false, false, false, false, false, false)
                    end,
                },
            },
        },
---------------------------------------------------------------------------------------------------------------------------------------
    --//FONT SIZES//--
---------------------------------------------------------------------------------------------------------------------------------------
    {
        type = "submenu",
        name = L.buttonFontCombat,
        controls = {
                {--DAMAGE
                    type    = "slider",
                    name    = L.damage,
                    tooltip = L.tooltipFontDamage,
                    min     = 8,
                    max     = 72,
                    step    = 1,
                    getFunc = function() return CombatCloudSettings.fontSizes.damage end,
                    setFunc = function(size) CombatCloudSettings.fontSizes.damage = size end,
                    default = D.fontSizes.damage,
                },
                {--HEALING
                    type    = "slider",
                    name    = L.healing,
                    tooltip = L.tooltipFontHealing,
                    min     = 8,
                    max     = 72,
                    step    = 1,
                    getFunc = function() return CombatCloudSettings.fontSizes.healing end,
                    setFunc = function(size) CombatCloudSettings.fontSizes.healing = size end,
                    default = D.fontSizes.healing,
                },
                {--DOT & HOT TICKS
                    type    = "slider",
                    name    = L.tick,
                    tooltip = L.tooltipFontTick,
                    min     = 8,
                    max     = 72,
                    step    = 1,
                    getFunc = function() return CombatCloudSettings.fontSizes.tick end,
                    setFunc = function(size) CombatCloudSettings.fontSizes.tick = size end,
                    default = D.fontSizes.tick,
                },
                {--CRITICAL
                    type    = "slider",
                    name    = L.critical,
                    tooltip = L.tooltipFontCritical,
                    min     = 8,
                    max     = 72,
                    step    = 1,
                    getFunc = function() return CombatCloudSettings.fontSizes.critical end,
                    setFunc = function(size) CombatCloudSettings.fontSizes.critical = size end,
                    default = D.fontSizes.critical,
                },
                {--Gain Loss
                    type    = "slider",
                    name    = L.gainLoss,
                    tooltip = L.tooltipFontGainLoss,
                    min     = 8,
                    max     = 72,
                    step    = 1,
                    getFunc = function() return CombatCloudSettings.fontSizes.gainLoss end,
                    setFunc = function(size) CombatCloudSettings.fontSizes.gainLoss = size end,
                    default = D.fontSizes.gainLoss,
                },
                {--MITIGATION
                    type    = "slider",
                    name    = L.mitigation,
                    tooltip = L.tooltipFontMitigation,
                    min     = 8,
                    max     = 72,
                    step    = 1,
                    getFunc = function() return CombatCloudSettings.fontSizes.mitigation end,
                    setFunc = function(size) CombatCloudSettings.fontSizes.mitigation = size end,
                    default = D.fontSizes.mitigation,
                },
                {--CROWD CONTROL
                    type    = "slider",
                    name    = L.crowdControl,
                    tooltip = L.tooltipFontCrowdControl,
                    min     = 8,
                    max     = 72,
                    step    = 1,
                    getFunc = function() return CombatCloudSettings.fontSizes.crowdControl end,
                    setFunc = function(size) CombatCloudSettings.fontSizes.crowdControl = size end,
                    default = D.fontSizes.crowdControl,
                },
            },
        },
    {
        type = "submenu",
        name = L.buttonFontNotification,
        controls = {
                {--COMBAT STATE
                    type     = "slider",
                    name    = L.combatState,
                    tooltip = L.tooltipFontCombatState,
                    min     = 8,
                    max     = 72,
                    step    = 1,
                    getFunc = function() return CombatCloudSettings.fontSizes.combatState end,
                    setFunc = function(size) CombatCloudSettings.fontSizes.combatState = size end,
                    default = D.fontSizes.combatState,
                },
                {--ALERTS
                    type     = "slider",
                    name    = L.alert,
                    tooltip = L.tooltipFontAlert,
                    min     = 8,
                    max     = 72,
                    step    = 1,
                    getFunc = function() return CombatCloudSettings.fontSizes.alert end,
                    setFunc = function(size) CombatCloudSettings.fontSizes.alert = size end,
                    default = D.fontSizes.alert,
                },
                {--POINTS
                    type     = "slider",
                    name    = L.point,
                    tooltip = L.tooltipFontPoint,
                    min     = 8,
                    max     = 72,
                    step    = 1,
                    getFunc = function() return CombatCloudSettings.fontSizes.point end,
                    setFunc = function(size) CombatCloudSettings.fontSizes.point = size end,
                    default = D.fontSizes.point,
                },
                {--RESOURCES
                    type    = "slider",
                    name    = L.resource,
                    tooltip = L.tooltipFontResource,
                    min     = 8,
                    max     = 72,
                    step    = 1,
                    getFunc = function() return CombatCloudSettings.fontSizes.resource end,
                    setFunc = function(size) CombatCloudSettings.fontSizes.resource = size end,
                    default = D.fontSizes.resource,
                },
            },
        },
---------------------------------------------------------------------------------------------------------------------------------------
    --//COLOR OPTIONS//--
---------------------------------------------------------------------------------------------------------------------------------------
    {
        type = "submenu",
        name = L.buttonColorCombat,
        controls = {
        --COLOR DAMAGE & HEALING
            {
                type = "header",
                name = L.headerColorDamageHealing,
            },
                {--NONE
                    type    = "colorpicker",
                    name    = L.damageType[0],
                    tooltip = L.tooltipDamageType[0],
                    getFunc = function() return unpack(CombatCloudSettings.colors.damage[0]) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.damage[0] = { r, g, b, a } end,
                    default = {r=D.colors.damage[0][1], g=D.colors.damage[0][2], b=D.colors.damage[0][3]}
                },
                {--GENERIC
                    type    = "colorpicker",
                    name    = L.damageType[1],
                    tooltip = L.tooltipDamageType[1],
                    getFunc = function() return unpack(CombatCloudSettings.colors.damage[1]) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.damage[1] = { r, g, b, a } end,
                    default = {r=D.colors.damage[1][1], g=D.colors.damage[1][2], b=D.colors.damage[1][3]}
                },
                {--PHYSICAL
                    type    = "colorpicker",
                    name    = L.damageType[2],
                    tooltip = L.tooltipDamageType[2],
                    getFunc = function() return unpack(CombatCloudSettings.colors.damage[2]) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.damage[2] = { r, g, b, a } end,
                    default = {r=D.colors.damage[2][1], g=D.colors.damage[2][2], b=D.colors.damage[2][3]}
                },
                {--FIRE
                    type    = "colorpicker",
                    name    = L.damageType[3],
                    tooltip = L.tooltipDamageType[3],
                    getFunc = function() return unpack(CombatCloudSettings.colors.damage[3]) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.damage[3] = { r, g, b, a } end,
                    default = {r=D.colors.damage[3][1], g=D.colors.damage[3][2], b=D.colors.damage[3][3]}
                },
                {--SHOCK
                    type    = "colorpicker",
                    name    = L.damageType[4],
                    tooltip = L.tooltipDamageType[4],
                    getFunc = function() return unpack(CombatCloudSettings.colors.damage[4]) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.damage[4] = { r, g, b, a } end,
                    default = {r=D.colors.damage[4][1], g=D.colors.damage[4][2], b=D.colors.damage[4][3]}
                },
                {--OBLIVION
                    type    = "colorpicker",
                    name    = L.damageType[5],
                    tooltip = L.tooltipDamageType[5],
                    getFunc = function() return unpack(CombatCloudSettings.colors.damage[5]) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.damage[5] = { r, g, b, a } end,
                    default = {r=D.colors.damage[5][1], g=D.colors.damage[5][2], b=D.colors.damage[5][3]}
                },
                {--COLD
                    type    = "colorpicker",
                    name    = L.damageType[6],
                    tooltip = L.tooltipDamageType[6],
                    getFunc = function() return unpack(CombatCloudSettings.colors.damage[6]) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.damage[6] = { r, g, b, a } end,
                    default = {r=D.colors.damage[6][1], g=D.colors.damage[6][2], b=D.colors.damage[6][3]}
                },
                {--EARTH
                    type     = "colorpicker",
                    name    = L.damageType[7],
                    tooltip = L.tooltipDamageType[7],
                    getFunc = function() return unpack(CombatCloudSettings.colors.damage[7]) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.damage[7] = { r, g, b, a } end,
                    default = {r=D.colors.damage[7][1], g=D.colors.damage[7][2], b=D.colors.damage[7][3]}
                },
                {--MAGIC
                    type    = "colorpicker",
                    name    = L.damageType[8],
                    tooltip = L.tooltipDamageType[8],
                    getFunc = function() return unpack(CombatCloudSettings.colors.damage[8]) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.damage[8] = { r, g, b, a } end,
                    default = {r=D.colors.damage[8][1], g=D.colors.damage[8][2], b=D.colors.damage[8][3]}
                },
                {--DROWN
                    type    = "colorpicker",
                    name    = L.damageType[9],
                    tooltip = L.tooltipDamageType[9],
                    getFunc = function() return unpack(CombatCloudSettings.colors.damage[9]) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.damage[9] = { r, g, b, a } end,
                    default = {r=D.colors.damage[9][1], g=D.colors.damage[9][2], b=D.colors.damage[9][3]}
                },
                {--DISEASE
                    type    = "colorpicker",
                    name     = L.damageType[10],
                    tooltip = L.tooltipDamageType[10],
                    getFunc = function() return unpack(CombatCloudSettings.colors.damage[10]) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.damage[10] = { r, g, b, a } end,
                    default = {r=D.colors.damage[10][1], g=D.colors.damage[10][2], b=D.colors.damage[10][3]}
                },
                {--POISON
                    type    = "colorpicker",
                    name    = L.damageType[11],
                    tooltip = L.tooltipDamageType[11],
                    getFunc = function() return unpack(CombatCloudSettings.colors.damage[11]) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.damage[11] = { r, g, b, a } end,
                    default = {r=D.colors.damage[11][1], g=D.colors.damage[11][2], b=D.colors.damage[11][3]}
                },
                {--HEALING
                    type    = "colorpicker",
                    name    = L.healing,
                    tooltip = L.tooltipColorHealing,
                    getFunc = function() return unpack(CombatCloudSettings.colors.healing) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.healing = { r, g, b, a } end,
                    default = {r=D.colors.healing[1], g=D.colors.healing[2], b=D.colors.healing[3]}
                },
                {--ENERGIZE MAGICKA
                    type    = "colorpicker",
                    name    = L.energizeMagicka,
                    tooltip = L.tooltipColorEnergizeMagicka,
                    getFunc = function() return unpack(CombatCloudSettings.colors.energizeMagicka) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.energizeMagicka = { r, g, b, a } end,
                    default = {r=D.colors.energizeMagicka[1], g=D.colors.energizeMagicka[2], b=D.colors.energizeMagicka[3]}
                },
                {--ENERGIZE STAMINA
                    type    = "colorpicker",
                    name    = L.energizeStamina,
                    tooltip = L.tooltipColorEnergizeStamina,
                    getFunc = function() return unpack(CombatCloudSettings.colors.energizeStamina) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.energizeStamina = { r, g, b, a } end,
                    default = {r=D.colors.energizeStamina[1], g=D.colors.energizeStamina[2], b=D.colors.energizeStamina[3]}
                },
                {--ENERGIZE ULTIMATE
                    type    = "colorpicker",
                    name    = L.energizeUltimate,
                    tooltip = L.tooltipColorEnergizeUltimate,
                    getFunc = function() return unpack(CombatCloudSettings.colors.energizeUltimate) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.energizeUltimate = { r, g, b, a } end,
                    default = {r=D.colors.energizeUltimate[1], g=D.colors.energizeUltimate[2], b=D.colors.energizeUltimate[3]}
                },
                {--DRAIN MAGICKA
                    type    = "colorpicker",
                    name    = L.drainMagicka,
                    tooltip = L.tooltipColorDrainMagicka,
                    getFunc = function() return unpack(CombatCloudSettings.colors.drainMagicka) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.drainMagicka = { r, g, b, a } end,
                    default = {r=D.colors.drainMagicka[1], g=D.colors.drainMagicka[2], b=D.colors.drainMagicka[3]}
                },
                {--DRAIN STAMINA
                    type    = "colorpicker",
                    name    = L.drainStamina,
                    tooltip = L.tooltipColorDrainStamina,
                    getFunc = function() return unpack(CombatCloudSettings.colors.drainStamina) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.drainStamina = { r, g, b, a } end,
                    default = {r=D.colors.drainStamina[1], g=D.colors.drainStamina[2], b=D.colors.drainStamina[3]}
                },
                {--CHECKBOX CRITICAL DAMAGE OVERRIDE
                    type    = "checkbox",
                    name    = L.colorCriticalDamage,
                    tooltip = L.tooltipCriticalDamageOverride,
                    getFunc = function() return CombatCloudSettings.toggles.criticalDamageOverride end,
                    setFunc = function(v) CombatCloudSettings.toggles.criticalDamageOverride = v end,
                    default = D.toggles.criticalDamageOverride,
                },
                {--COLOR CRITICAL DAMAGE OVERRIDE
                    type    = "colorpicker",
                    name     = L.colorCriticalDamage,
                    tooltip = L.tooltipColorCriticalDamage,
                    getFunc = function() return unpack(CombatCloudSettings.colors.criticalDamageOverride) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.criticalDamageOverride = { r, g, b, a } end,
                    default = {r=D.colors.criticalDamageOverride[1], g=D.colors.criticalDamageOverride[2], b=D.colors.criticalDamageOverride[3]}
                },
                {--CHECKBOX CRITICAL HEALING OVERRIDE
                    type    = "checkbox",
                    name    = L.colorCriticalHealing,
                    tooltip = L.tooltipCriticalHealingOverride,
                    getFunc = function() return CombatCloudSettings.toggles.criticalHealingOverride end,
                    setFunc = function(v) CombatCloudSettings.toggles.criticalHealingOverride = v end,
                    default = D.toggles.criticalHealingOverride
                },
                {--COLOR CRITICAL HEALING OVERRIDE
                    type    = "colorpicker",
                    name    = L.colorCriticalHealing,
                    tooltip = L.tooltipColorCriticalHealing,
                    getFunc = function() return unpack(CombatCloudSettings.colors.criticalHealingOverride) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.criticalHealingOverride = { r, g, b, a } end,
                    default = {r=D.colors.criticalHealingOverride[1], g=D.colors.criticalHealingOverride[2], b=D.colors.criticalHealingOverride[3]}
                },
        --COLOR MITIGATION
            {
                type = "header",
                name = L.headerColorMitigation,
            },
                {--MISS
                    type     = "colorpicker",
                    name     = L.miss,
                    tooltip = L.tooltipColorMiss,
                    getFunc = function() return unpack(CombatCloudSettings.colors.miss) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.miss = { r, g, b, a } end,
                    default = {r=D.colors.miss[1], g=D.colors.miss[2], b=D.colors.miss[3]}
                },
                {--IMMUNE
                    type    = "colorpicker",
                    name    = L.immune,
                    tooltip = L.tooltipColorImmune,
                    getFunc = function() return unpack(CombatCloudSettings.colors.immune) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.immune = { r, g, b, a } end,
                    default = {r=D.colors.immune[1], g=D.colors.immune[2], b=D.colors.immune[3]}
                },
                {--PARRIED
                    type    = "colorpicker",
                    name     = L.parried,
                    tooltip = L.tooltipColorParried,
                    getFunc = function() return unpack(CombatCloudSettings.colors.parried) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.parried = { r, g, b, a } end,
                    default = {r=D.colors.parried[1], g=D.colors.parried[2], b=D.colors.parried[3]}
                },
                {--REFLECTED
                    type    = "colorpicker",
                    name    = L.reflected,
                    tooltip = L.tooltipColorReflected,
                    getFunc = function() return unpack(CombatCloudSettings.colors.reflected) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.reflected = { r, g, b, a } end,
                    default = {r=D.colors.reflected[1], g=D.colors.reflected[2], b=D.colors.reflected[3]}
                },
                {--DAMAGESHIELD
                    type    = "colorpicker",
                    name    = L.damageShield,
                    tooltip = L.tooltipColorDamageShield,
                    getFunc = function() return unpack(CombatCloudSettings.colors.damageShield) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.damageShield = { r, g, b, a } end,
                    default = {r=D.colors.damageShield[1], g=D.colors.damageShield[2], b=D.colors.damageShield[3]}
                },
                {--DODGE
                    type    = "colorpicker",
                    name    = L.dodged,
                    tooltip = L.tooltipColorDodge,
                    getFunc = function() return unpack(CombatCloudSettings.colors.dodged) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.dodged = { r, g, b, a } end,
                    default = {r=D.colors.dodged[1], g=D.colors.dodged[2], b=D.colors.dodged[3]}
                },
                {--BLOCKED
                    type    = "colorpicker",
                    name    = L.blocked,
                    tooltip = L.tooltipColorBlocked,
                    getFunc = function() return unpack(CombatCloudSettings.colors.blocked) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.blocked = { r, g, b, a } end,
                    default = {r=D.colors.blocked[1], g=D.colors.blocked[2], b=D.colors.blocked[3]}
                },
                {--INTERRUPTED
                    type    = "colorpicker",
                    name    = L.interrupted,
                    tooltip = L.tooltipColorInterrupted,
                    getFunc = function() return unpack(CombatCloudSettings.colors.interrupted) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.interrupted = { r, g, b, a } end,
                    default = {r=D.colors.interrupted[1], g=D.colors.interrupted[2], b=D.colors.interrupted[3]}
                },
        --COLOR CROWD CONTROL
            {
                type = "header",
                name = L.headerColorCrowdControl,
            },
                {--DISORIENTED
                    type    = "colorpicker",
                    name    = L.disoriented,
                    tooltip = L.tooltipColorDisoriented,
                    getFunc = function() return unpack(CombatCloudSettings.colors.disoriented) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.disoriented = { r, g, b, a } end,
                    default = {r=D.colors.disoriented[1], g=D.colors.disoriented[2], b=D.colors.disoriented[3]}
                },
                {--FEARED
                    type    = "colorpicker",
                    name    = L.feared,
                    tooltip = L.tooltipColorFeared,
                    getFunc = function() return unpack(CombatCloudSettings.colors.feared) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.feared = { r, g, b, a } end,
                    default = {r=D.colors.feared[1], g=D.colors.feared[2], b=D.colors.feared[3]}
                },
                {--OFFBALANCED
                    type    = "colorpicker",
                    name    = L.offBalanced,
                    tooltip = L.tooltipColorOffBalanced,
                    getFunc = function() return unpack(CombatCloudSettings.colors.offBalanced) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.offBalanced = { r, g, b, a } end,
                    default = {r=D.colors.offBalanced[1], g=D.colors.offBalanced[2], b=D.colors.offBalanced[3]}
                },
                {--SILENCED
                    type    = "colorpicker",
                    name    = L.silenced,
                    tooltip = L.tooltipColorSilenced,
                    getFunc = function() return unpack(CombatCloudSettings.colors.silenced) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.silenced = { r, g, b, a } end,
                    default = {r=D.colors.silenced[1], g=D.colors.silenced[2], b=D.colors.silenced[3]}
                },
                {--STUNNED
                    type    = "colorpicker",
                    name    = L.stunned,
                    tooltip = L.tooltipColorStunned,
                    getFunc = function() return unpack(CombatCloudSettings.colors.stunned) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.stunned = { r, g, b, a } end,
                    default = {r=D.colors.stunned[1], g=D.colors.stunned[2], b=D.colors.stunned[3]}
                },
            },
        },
        {
            type = "submenu",
            name = L.buttonColorNotification,
            controls = {
        --COMBAT STATE
            {
                type = "header",
                name = L.headerColorCombatState,
            },
                {--IN COMBAT
                    type    = "colorpicker",
                    name    = L.inCombat,
                    tooltip = L.tooltipColorInCombat,
                    getFunc = function() return unpack(CombatCloudSettings.colors.inCombat) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.inCombat = { r, g, b, a } end,
                    default = {r=D.colors.inCombat[1], g=D.colors.inCombat[2], b=D.colors.inCombat[3]}
                },
                {--OUT COMBAT
                    type    = "colorpicker",
                    name    = L.outCombat,
                    tooltip = L.tooltipColorOutCombat,
                    getFunc = function() return unpack(CombatCloudSettings.colors.outCombat) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.outCombat = { r, g, b, a } end,
                    default = {r=D.colors.outCombat[1], g=D.colors.outCombat[2], b=D.colors.outCombat[3]}
                },
        --COLOR ALERTS
            {
                type = "header",
                name = L.headerColorAlert,
            },
                {--CLEANSE
                    type    = "colorpicker",
                    name    = L.alertCleanse,
                    tooltip = L.tooltipColorAlertsCleanse,
                    getFunc = function() return unpack(CombatCloudSettings.colors.alertCleanse) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.alertCleanse = { r, g, b, a } end,
                    default = {r=D.colors.alertCleanse[1], g=D.colors.alertCleanse[2], b=D.colors.alertCleanse[3]}
                },
                {--BLOCK
                    type    = "colorpicker",
                    name    = L.alertBlock,
                    tooltip = L.tooltipColorAlertsBlock,
                    getFunc = function() return unpack(CombatCloudSettings.colors.alertBlock) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.alertBlock = { r, g, b, a } end,
                    default = {r=D.colors.alertBlock[1], g=D.colors.alertBlock[2], b=D.colors.alertBlock[3]}
                },
                {--EXPLOIT
                    type    = "colorpicker",
                    name    = L.alertExploit,
                    tooltip = L.tooltipColorAlertsExploit,
                    getFunc = function() return unpack(CombatCloudSettings.colors.alertExploit) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.alertExploit = { r, g, b, a } end,
                    default = {r=D.colors.alertExploit[1], g=D.colors.alertExploit[2], b=D.colors.alertExploit[3]}
                },
                {--INTERRUPT
                    type    = "colorpicker",
                    name    = L.alertInterrupt,
                    tooltip = L.tooltipColorAlertsInterrupt,
                    getFunc = function() return unpack(CombatCloudSettings.colors.alertInterrupt) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.alertInterrupt = { r, g, b, a } end,
                    default = {r=D.colors.alertInterrupt[1], g=D.colors.alertInterrupt[2], b=D.colors.alertInterrupt[3]}
                },
                {--DODGE
                    type    = "colorpicker",
                    name    = L.alertDodge,
                    tooltip = L.tooltipColorAlertsDodge,
                    getFunc = function() return unpack(CombatCloudSettings.colors.alertDodge) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.alertDodge = { r, g, b, a } end,
                    default = {r=D.colors.alertDodge[1], g=D.colors.alertDodge[2], b=D.colors.alertDodge[3]}
                },
                {--EXECUTE
                    type    = "colorpicker",
                    name    = L.alertExecute,
                    tooltip = L.tooltipColorAlertsExecute,
                    getFunc = function() return unpack(CombatCloudSettings.colors.alertExecute) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.alertExecute = { r, g, b, a } end,
                    default = {r=D.colors.alertExecute[1], g=D.colors.alertExecute[2], b=D.colors.alertExecute[3]}
                },
        --COLOR POINTS
            {
                type = "header",
                name = L.headerColorPoint,
            },
                {--ALLIANCE POINTS
                    type    = "colorpicker",
                    name    = L.pointsAlliance,
                    tooltip = L.tooltipColorPointsAlliance,
                    getFunc = function() return unpack(CombatCloudSettings.colors.pointsAlliance) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.pointsAlliance = { r, g, b, a } end,
                    default = {r=D.colors.pointsAlliance[1], g=D.colors.pointsAlliance[2], b=D.colors.pointsAlliance[3]}
                },
                {--EXPERIENCE POINTS
                    type    = "colorpicker",
                    name    = L.pointsExperience,
                    tooltip = L.tooltipColorPointsExperience,
                    getFunc = function() return unpack(CombatCloudSettings.colors.pointsExperience) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.pointsExperience = { r, g, b, a } end,
                    default = {r=D.colors.pointsExperience[1], g=D.colors.pointsExperience[2], b=D.colors.pointsExperience[3]}
                },
                {--CHAMPION POINTS
                    type    = "colorpicker",
                    name    = L.pointsChampion,
                    tooltip = L.tooltipColorPointsChampion,
                    getFunc = function() return unpack(CombatCloudSettings.colors.pointsChampion) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.pointsChampion = { r, g, b, a } end,
                    default = {r=D.colors.pointsChampion[1], g=D.colors.pointsChampion[2], b=D.colors.pointsChampion[3]}
                },
        --COLOR RESOURCES
            {
                type = "header",
                name = L.headerColorResource,
            },
                {--LOW HEALTH
                    type    = "colorpicker",
                    name    = L.lowHealth,
                    tooltip = L.tooltipColorLowHealth,
                    getFunc = function() return unpack(CombatCloudSettings.colors.lowHealth) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.lowHealth = { r, g, b, a } end,
                    default = {r=D.colors.lowHealth[1], g=D.colors.lowHealth[2], b=D.colors.lowHealth[3]}
                },
                {--LOW MAGICKA
                    type    = "colorpicker",
                    name    = L.lowMagicka,
                    tooltip = L.tooltipColorLowMagicka,
                    getFunc = function() return unpack(CombatCloudSettings.colors.lowMagicka) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.lowMagicka = { r, g, b, a } end,
                    default = {r=D.colors.lowMagicka[1], g=D.colors.lowMagicka[2], b=D.colors.lowMagicka[3]}
                },
                {--LOW STAMINA
                    type    = "colorpicker",
                    name    = L.lowStamina,
                    tooltip = L.tooltipColorLowStamina,
                    getFunc = function() return unpack(CombatCloudSettings.colors.lowStamina) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.lowStamina = { r, g, b, a } end,
                    default = {r=D.colors.lowStamina[1], g=D.colors.lowStamina[2], b=D.colors.lowStamina[3]}
                },
                {--ULTIMATE READY
                    type    = "colorpicker",
                    name    = L.ultimateReady,
                    tooltip = L.tooltipColorUltimateReady,
                    getFunc = function() return unpack(CombatCloudSettings.colors.ultimateReady) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.ultimateReady = { r, g, b, a } end,
                    default = {r=D.colors.ultimateReady[1], g=D.colors.ultimateReady[2], b=D.colors.ultimateReady[3]}
                },
                {--POTION READY
                    type    = "colorpicker",
                    name    = L.potionReady,
                    tooltip = L.tooltipColorPotionReady,
                    getFunc = function() return unpack(CombatCloudSettings.colors.potionReady) end,
                    setFunc = function(r, g, b, a) CombatCloudSettings.colors.potionReady = { r, g, b, a } end,
                    default = {r=D.colors.potionReady[1], g=D.colors.potionReady[2], b=D.colors.potionReady[3]}
                },
            },
        },
---------------------------------------------------------------------------------------------------------------------------------------
    --//FORMAT OPTIONS//--
---------------------------------------------------------------------------------------------------------------------------------------
        {
            type = "submenu",
            name = L.buttonFormatCombat,
            controls = {
            {
                type = "description",
                text = L.descriptionFormat,
            },
        --FORMATS DAMAGE & HEALING
            {
                type = "header",
                name = L.headerFormatDamageHealing,
            },
                {--DAMAGE
                    type    = "editbox",
                    name    = L.damage,
                    tooltip = L.tooltipFormatDamage,
                    getFunc = function() return CombatCloudSettings.formats.damage end,
                    setFunc = function(v) CombatCloudSettings.formats.damage = v end,
                    isMultiline = false,
                    default = D.formats.damage,
                },
                {--HEALING
                    type    = "editbox",
                    name    = L.healing,
                    tooltip = L.tooltipFormatHealing,
                    getFunc = function() return CombatCloudSettings.formats.healing end,
                    setFunc = function(v) CombatCloudSettings.formats.healing = v end,
                    isMultiline = false,
                    default = D.formats.healing,
                },
                {--ENERGIZE
                    type    = "editbox",
                    name    = L.energize,
                    tooltip = L.tooltipFormatEnergize,
                    getFunc = function() return CombatCloudSettings.formats.energize end,
                    setFunc = function(v) CombatCloudSettings.formats.energize = v end,
                    isMultiline = false,
                    default = D.formats.energize,
                },
                {-- ULTIMATE ENERGIZE
                    type    = "editbox",
                    name    = L.ultimateEnergize,
                    tooltip = L.tooltipFormatUltimateEnergize,
                    getFunc = function() return CombatCloudSettings.formats.ultimateEnergize end,
                    setFunc = function(v) CombatCloudSettings.formats.ultimateEnergize = v end,
                    isMultiline = false,
                    default = D.formats.ultimateEnergize,
                },
                {--DRAIN
                    type    = "editbox",
                    name    = L.drain,
                    tooltip = L.tooltipFormatDrain,
                    getFunc = function() return CombatCloudSettings.formats.drain end,
                    setFunc = function(v) CombatCloudSettings.formats.drain = v end,
                    isMultiline = false,
                    default = D.formats.drain,
                },
                {--DOT
                    type    = "editbox",
                    name    = L.dot,
                    tooltip = L.tooltipFormatDot,
                    getFunc = function() return CombatCloudSettings.formats.dot end,
                    setFunc = function(v) CombatCloudSettings.formats.dot = v end,
                    isMultiline = false,
                    default = D.formats.dot,
                },
                {--HOT
                    type    = "editbox",
                    name    = L.hot,
                    tooltip = L.tooltipFormatHot,
                    getFunc = function() return CombatCloudSettings.formats.hot end,
                    setFunc = function(v) CombatCloudSettings.formats.hot = v end,
                    isMultiline = false,
                    default = D.formats.hot,
                },
                {--CRITICAL
                    type    = "editbox",
                    name    = L.critical,
                    tooltip = L.tooltipFormatCritical,
                    getFunc = function() return CombatCloudSettings.formats.critical end,
                    setFunc = function(v) CombatCloudSettings.formats.critical = v end,
                    isMultiline = false,
                    default = D.formats.critical,
                },
        --FORMATS MITIGATION
            {
                type = "header",
                name = L.headerFormatMitigation,
            },
                {--MISS
                    type    = "editbox",
                    name    = L.miss,
                    tooltip = L.tooltipFormatMiss,
                    getFunc = function() return CombatCloudSettings.formats.miss end,
                    setFunc = function(v) CombatCloudSettings.formats.miss = v end,
                    isMultiline = false,
                    default = D.formats.miss,
                },
                {--IMMUNE
                    type    = "editbox",
                    name    = L.immune,
                    tooltip = L.tooltipFormatImmune,
                    getFunc = function() return CombatCloudSettings.formats.immune end,
                    setFunc = function(v) CombatCloudSettings.formats.immune = v end,
                    isMultiline = false,
                    default = D.formats.immune,
                },
                {--PARRIED
                    type    = "editbox",
                    name    = L.parried,
                    tooltip = L.tooltipFormatParried,
                    getFunc = function() return CombatCloudSettings.formats.parried end,
                    setFunc = function(v) CombatCloudSettings.formats.parried = v end,
                    isMultiline = false,
                    default = D.formats.parried,
                },
                {--REFLECTED
                    type    = "editbox",
                    name    = L.reflected,
                    tooltip = L.tooltipFormatReflected,
                    getFunc = function() return CombatCloudSettings.formats.reflected end,
                    setFunc = function(v) CombatCloudSettings.formats.reflected = v end,
                    isMultiline = false,
                    default = D.formats.reflected,
                },
                {--DAMAGE SHIELD
                    type    = "editbox",
                    name    = L.damageShield,
                    tooltip = L.tooltipFormatDamageShield,
                    getFunc = function() return CombatCloudSettings.formats.damageShield end,
                    setFunc = function(v) CombatCloudSettings.formats.damageShield = v end,
                    isMultiline = false,
                    default = D.formats.damageShield,
                },
                {--DODGED
                    type    = "editbox",
                    name    = L.dodged,
                    tooltip = L.tooltipFormatDodged,
                    getFunc = function() return CombatCloudSettings.formats.dodged end,
                    setFunc = function(v) CombatCloudSettings.formats.dodged = v end,
                    isMultiline = false,
                    default = D.formats.dodged,
                },
                {--BLOCKED
                    type    = "editbox",
                    name    = L.blocked,
                    tooltip = L.tooltipFormatBlocked,
                    getFunc = function() return CombatCloudSettings.formats.blocked end,
                    setFunc = function(v) CombatCloudSettings.formats.blocked = v end,
                    isMultiline = false,
                    default = D.formats.blocked,
                },
                {--INTERRUPTED
                    type    = "editbox",
                    name    = L.interrupted,
                    tooltip = L.tooltipFormatInterrupted,
                    getFunc = function() return CombatCloudSettings.formats.interrupted end,
                    setFunc = function(v) CombatCloudSettings.formats.interrupted = v end,
                    isMultiline = false,
                    default = D.formats.interrupted,
                },
        --FORMATS CROWD CONTROL
            {
                type = "header",
                name = L.headerFormatCrowdControl,
            },
                {--DISORIENTED
                    type    = "editbox",
                    name    = L.disoriented,
                    tooltip = L.tooltipFormatDisoriented,
                    getFunc = function() return CombatCloudSettings.formats.disoriented end,
                    setFunc = function(v) CombatCloudSettings.formats.disoriented = v end,
                    isMultiline = false,
                    default = D.formats.disoriented,
                },
                {--FEARED
                    type    = "editbox",
                    name    = L.feared,
                    tooltip = L.tooltipFormatFeared,
                    getFunc = function() return CombatCloudSettings.formats.feared end,
                    setFunc = function(v) CombatCloudSettings.formats.feared = v end,
                    isMultiline = false,
                    default = D.formats.feared,
                },
                {--OFFBALANCED
                    type    = "editbox",
                    name    = L.offBalanced,
                    tooltip = L.tooltipFormatOffBalanced,
                    getFunc = function() return CombatCloudSettings.formats.offBalanced end,
                    setFunc = function(v) CombatCloudSettings.formats.offBalanced = v end,
                    isMultiline = false,
                    default = D.formats.offBalanced,
                },
                {--SILENCED
                    type    = "editbox",
                    name    = L.silenced,
                    tooltip = L.tooltipFormatSilenced,
                    getFunc = function() return CombatCloudSettings.formats.silenced end,
                    setFunc = function(v) CombatCloudSettings.formats.silenced = v end,
                    isMultiline = false,
                    default = D.formats.silenced,
                },
                {--STUNNED
                    type    = "editbox",
                    name    = L.stunned,
                    tooltip = L.tooltipFormatStunned,
                    getFunc = function() return CombatCloudSettings.formats.stunned end,
                    setFunc = function(v) CombatCloudSettings.formats.stunned = v end,
                    isMultiline = false,
                    default = D.formats.stunned,
                },
            },
        },
        {
            type = "submenu",
            name = L.buttonFormatNotification,
            controls = {
            {
                type = "description",
                text = L.descriptionFormat,
            },
        --FORMATS COMBAT STATE
            {
                type = "header",
                name = L.headerFormatCombatState,
            },
                {--IN COMBAT
                    type    = "editbox",
                    name    = L.inCombat,
                    tooltip = L.tooltipFormatInCombat,
                    getFunc = function() return CombatCloudSettings.formats.inCombat end,
                    setFunc = function(v) CombatCloudSettings.formats.inCombat = v end,
                    isMultiline = false,
                    default = D.formats.inCombat,
                },
                {--OUT COMBAT
                    type    = "editbox",
                    name    = L.outCombat,
                    tooltip = L.tooltipFormatOutCombat,
                    getFunc = function() return CombatCloudSettings.formats.outCombat end,
                    setFunc = function(v) CombatCloudSettings.formats.outCombat = v end,
                    isMultiline = false,
                    default = D.formats.outCombat,
                },
        --FORMATS ALERTS
            {
                type = "header",
                name = L.headerFormatAlert,
            },
                {--CLEANSE
                    type    = "editbox",
                    name    = L.alertCleanse,
                    tooltip = L.tooltipFormatAlertsCleanse,
                    getFunc = function() return CombatCloudSettings.formats.alertCleanse end,
                    setFunc = function(v) CombatCloudSettings.formats.alertCleanse = v end,
                    isMultiline = false,
                    default = D.formats.alertCleanse,
                },
                {--BLOCK
                    type    = "editbox",
                    name    = L.alertBlock,
                    tooltip = L.tooltipFormatAlertsBlock,
                    getFunc = function() return CombatCloudSettings.formats.alertBlock end,
                    setFunc = function(v) CombatCloudSettings.formats.alertBlock = v end,
                    isMultiline = false,
                    default = D.formats.alertBlock,
                },
                {--EXPLOIT
                    type    = "editbox",
                    name    = L.alertExploit,
                    tooltip = L.tooltipFormatAlertsExploit,
                    getFunc = function() return CombatCloudSettings.formats.alertExploit end,
                    setFunc = function(v) CombatCloudSettings.formats.alertExploit = v end,
                    isMultiline = false,
                    default = D.formats.alertExploit,
                },
                {--INTERRUPT
                    type    = "editbox",
                    name    = L.alertInterrupt,
                    tooltip = L.tooltipFormatAlertsInterrupt,
                    getFunc = function() return CombatCloudSettings.formats.alertInterrupt end,
                    setFunc = function(v) CombatCloudSettings.formats.alertInterrupt = v end,
                    isMultiline = false,
                    default = D.formats.alertInterrupt,
                },
                {--DODGE
                    type    = "editbox",
                    name    = L.alertDodge,
                    tooltip = L.tooltipFormatAlertsDodge,
                    getFunc = function() return CombatCloudSettings.formats.alertDodge end,
                    setFunc = function(v) CombatCloudSettings.formats.alertDodge = v end,
                    isMultiline = false,
                    default = D.formats.alertDodge,
                },
                {--EXECUTE
                    type    = "editbox",
                    name    = L.alertExecute,
                    tooltip = L.tooltipFormatAlertsExecute,
                    getFunc = function() return CombatCloudSettings.formats.alertExecute end,
                    setFunc = function(v) CombatCloudSettings.formats.alertExecute = v end,
                    isMultiline = false,
                    default = D.formats.alertExecute,
                },
        --FORMATS POINTS
            {
                type = "header",
                name = L.headerFormatPoint,
            },
                {--ALLIANCE POINTS
                    type    = "editbox",
                    name    = L.pointsAlliance,
                    tooltip = L.tooltipFormatPointsAlliance,
                    getFunc = function() return CombatCloudSettings.formats.pointsAlliance end,
                    setFunc = function(v) CombatCloudSettings.formats.pointsAlliance = v end,
                    isMultiline = false,
                    default = D.formats.pointsAlliance,
                },
                {--EXPERIENCE POINTS
                    type    = "editbox",
                    name    = L.pointsExperience,
                    tooltip = L.tooltipFormatPointsExperience,
                    getFunc = function() return CombatCloudSettings.formats.pointsExperience end,
                    setFunc = function(v) CombatCloudSettings.formats.pointsExperience = v end,
                    isMultiline = false,
                    default = D.formats.pointsExperience,
                },
                {--CHAMPION POINTS
                    type    = "editbox",
                    name    = L.pointsChampion,
                    tooltip = L.tooltipFormatPointsChampion,
                    getFunc = function() return CombatCloudSettings.formats.pointsChampion end,
                    setFunc = function(v) CombatCloudSettings.formats.pointsChampion = v end,
                    isMultiline = false,
                    default = D.formats.pointsChampion,
                },
        --FORMATS RESOURCES
            {
                type = "header",
                name = L.headerFormatResource,
            },
                {--LOW HEALTH, MAGICKA, STAMINA
                    type    = "editbox",
                    name    = L.resource,
                    tooltip = L.tooltipFormatResource,
                    getFunc = function() return CombatCloudSettings.formats.resource end,
                    setFunc = function(v) CombatCloudSettings.formats.resource = v end,
                    isMultiline = false,
                    default = D.formats.resource,
                },
                {--ULTIMATE READY
                    type    = "editbox",
                    name    = L.ultimateReady,
                    tooltip = L.tooltipFormatUltimateReady,
                    getFunc = function() return CombatCloudSettings.formats.ultimateReady end,
                    setFunc = function(v) CombatCloudSettings.formats.ultimateReady = v end,
                    isMultiline = false,
                    default = D.formats.ultimateReady,
                },
                {--ULTIMATE READY
                    type    = "editbox",
                    name    = L.potionReady,
                    tooltip = L.tooltipFormatPotionReady,
                    getFunc = function() return CombatCloudSettings.formats.potionReady end,
                    setFunc = function(v) CombatCloudSettings.formats.potionReady = v end,
                    isMultiline = false,
                    default = D.formats.potionReady,
                },
            },
        },
---------------------------------------------------------------------------------------------------------------------------------------
    --//ANIMATION OPTIONS//--
---------------------------------------------------------------------------------------------------------------------------------------
        {
            type = "submenu",
            name = L.buttonAnimation,
            controls = {
                {--ANIMATION TYPE
                    type    = "dropdown",
                    name    = L.animationType,
                    tooltip = L.tooltipAnimationType,
                    choices = CombatCloudConstants.animationType,
                    getFunc = function() return CombatCloudSettings.animation.animationType end,
                    setFunc = function(v) CombatCloudSettings.animation.animationType = v end,
                    default = D.animation.animationType,
                },
                {--INCOMING DIRECTION
                    type    = "dropdown",
                    name    = L.incomingDirection,
                    tooltip = L.tooltipAnimationIncomingDirection,
                    choices = CombatCloudConstants.directionType,
                    getFunc = function() return CombatCloudSettings.animation.incoming.directionType end,
                    setFunc = function(v) CombatCloudSettings.animation.incoming.directionType = v end,
                    default = D.animation.incoming.directionType,
                },
                {--INCOMING ICON POSITION
                    type    = "dropdown",
                    name    = L.incomingIcon,
                    tooltip = L.tooltipAnimationIncomingIcon,
                    choices = CombatCloudConstants.iconSide,
                    getFunc = function() return CombatCloudSettings.animation.incomingIcon end,
                    setFunc = function(v) CombatCloudSettings.animation.incomingIcon = v end,
                    default = D.animation.incomingIcon,
                },
                {--OUTGOING DIRECTION
                    type    = "dropdown",
                    name    = L.outgoingDirection,
                    tooltip = L.tooltipAnimationOutgoingDirection,
                    choices = CombatCloudConstants.directionType,
                    getFunc = function() return CombatCloudSettings.animation.outgoing.directionType end,
                    setFunc = function(v) CombatCloudSettings.animation.outgoing.directionType = v end,
                    default = D.animation.outgoing.directionType,
                },
                {--OUTGOING ICON POSITION
                    type    = "dropdown",
                    name    = L.outgoingIcon,
                    tooltip = L.tooltipAnimationOutgoingIcon,
                    choices = CombatCloudConstants.iconSide,
                    getFunc = function() return CombatCloudSettings.animation.outgoingIcon end,
                    setFunc = function(v) CombatCloudSettings.animation.outgoingIcon = v end,
                    default = D.animation.outgoingIcon,
                },
                {--TEST BUTTON
                    type = "button",
                    name = L.animationTest,
                    tooltip = L.tooltipAnimationTest,
                    func = function()
                        CALLBACK_MANAGER:FireCallbacks(CombatCloudConstants.eventType.COMBAT, CombatCloudConstants.combatType.INCOMING, POWERTYPE_STAMINA, math.random(7, 777), L.animationTest, 41567, DAMAGE_TYPE_PHYSICAL, true, false, false, false, false, false, false, false, false, false, false, false, false, false)
                    end,
                },
            },
        },
---------------------------------------------------------------------------------------------------------------------------------------
    --//THROTTLE OPTIONS//--
---------------------------------------------------------------------------------------------------------------------------------------
        {
            type = "submenu",
            name = L.buttonThrottle,
            controls = {
                {
                    type = "description",
                    text = L.descriptionThrottle,
                },
                {--DAMAGE
                    type    = "slider",
                    name    = L.damage,
                    tooltip = L.tooltipThrottleDamage,
                    min     = 0,
                    max     = 500,
                    step    = 50,
                    getFunc = function() return CombatCloudSettings.throttles.damage end,
                    setFunc = function(v) CombatCloudSettings.throttles.damage = v end,
                    default = D.throttles.damage,
                },
                {--HEALING
                    type    = "slider",
                    name    = L.healing,
                    tooltip = L.tooltipThrottleHealing,
                    min     = 0,
                    max     = 500,
                    step    = 50,
                    getFunc = function() return CombatCloudSettings.throttles.healing end,
                    setFunc = function(v) CombatCloudSettings.throttles.healing = v end,
                    default = D.throttles.healing,
                },
                {--DOT
                    type    = "slider",
                    name    = L.dot,
                    tooltip = L.tooltipThrottleDot,
                    min     = 0,
                    max     = 500,
                    step    = 50,
                    getFunc = function() return CombatCloudSettings.throttles.dot end,
                    setFunc = function(v) CombatCloudSettings.throttles.dot = v end,
                    default = D.throttles.dot,
                },
                {--HOT
                    type    = "slider",
                    name    = L.hot,
                    tooltip = L.tooltipThrottleHot,
                    min     = 0,
                    max     = 500,
                    step    = 50,
                    getFunc = function() return CombatCloudSettings.throttles.hot end,
                    setFunc = function(v) CombatCloudSettings.throttles.hot = v end,
                    default = D.throttles.hot,
                },
                {--THROTTLE TRAILER
                    type    = "checkbox",
                    name    = L.showThrottleTrailer,
                    tooltip = L.tooltipThrottleTrailer,
                    getFunc = function() return CombatCloudSettings.toggles.showThrottleTrailer end,
                    setFunc = function(v) CombatCloudSettings.toggles.showThrottleTrailer = v end,
                    default = D.toggles.showThrottleTrailer,
                },
                {--CRITS
                    type    = "checkbox",
                    name    = L.critical,
                    tooltip = L.tooltipThrottleCritical,
                    getFunc = function() return CombatCloudSettings.toggles.showThrottleTrailer end,
                    setFunc = function(v) CombatCloudSettings.toggles.throttleCriticals = v end,
                    default = D.toggles.throttleCriticals,
                },
            },
        },
    }
---------------------------------------------------------------------------------------------------------------------------------------
    --//REGISTER LAM2//--
---------------------------------------------------------------------------------------------------------------------------------------
function CombatCloud.RegisterOptions()
    LAM2:RegisterAddonPanel("CombatCloudOptions", panelData)
    LAM2:RegisterOptionControls("CombatCloudOptions", optionsData)
end
