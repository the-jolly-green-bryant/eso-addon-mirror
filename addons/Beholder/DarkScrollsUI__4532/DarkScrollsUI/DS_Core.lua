-----------------------------------------------------------
-- DarkScrollsUI - DS_Core.lua
-- Global state, localization, default profile, and shared
-- utility functions used across all modules.
-----------------------------------------------------------

local addonName = "DarkScrollsUI"

DarkScrollsUI = DarkScrollsUI or {}
DarkScrollsUI.AddonNameIdentifier = addonName
DarkScrollsUI.isInterfaceLocked = true
DarkScrollsUI.isGlobalEditModeActive = false
DarkScrollsUI.isCustomBossBarActive = false
DarkScrollsUI.GlobalInterfaceEditFrame = nil
DarkScrollsUI.lastStoredPlayerHealth = 0
DarkScrollsUI.SavedVariables = nil   -- points to the active profile in MasterSV.profiles[n]
DarkScrollsUI.MasterSavedVariables = nil

DarkScrollsUI.CONSTANT_PI_QUARTER = 0.785398

-- Ultimate pulse constants
DarkScrollsUI.ULTIMATE_PULSE_MIN_ALPHA_VALUE = 0.5
DarkScrollsUI.ULTIMATE_PULSE_MAX_ALPHA_VALUE = 0.9
DarkScrollsUI.ULTIMATE_PULSE_DURATION      = 2.0

-----------------------------------------------------------
-- STRINGS
-----------------------------------------------------------
DarkScrollsUI.LocalizationStrings = {
    Locked          = "|cFF0000Locked|r",
    Unlocked        = "|c00FF00Individual Edit (Wheel=Width, Shift+W=Height, Alt+W=Alpha, Ctrl+W=Font)|r",
    GlobalOn        = "|c00FF00Global Edit Enabled (Drag to Move Group, Mouse Wheel to Scale)|r",
    GlobalOff       = "|cFF0000Global Edit Disabled and Saved|r",
    EditFinished    = "|cFF0000Edit mode closed and saved.|r",
    GraySkillsLabel   = "Skill Icon Saturation",
    GraySkillsTooltip = "Skills appear in black and white when inactive. They gain full color while their buff is active, then return to black and white.",
    GraySatLabel      = "Inactive Skill Saturation",
    GraySatTooltip    = "0 = fully black and white | 100 = fully colored (applies to inactive skills)",
    GrayUltSatLabel   = "Ultimate Ready Saturation",
    GrayUltSatTooltip = "Saturation level of the Ultimate icon when it is fully charged and ready to use.",
    QuestTrackerLabel   = "Addon Quest Tracker (EXPERIMENTAL)",
    QuestTrackerTooltip = "When enabled, replaces the default ESO quest tracker with DarkScrollsUI's custom tracker. When disabled, the original tracker is restored.",
    DamageFlashLabel              = "Damage Taken Effect (WORK IN PROGRESS)",
    EnabledLabel           = "Enabled",
    DamageFlashTooltip            = "When enabled, a blood-border overlay and a brief camera shake are triggered every time the player takes damage.",
    DamageFlashThresholdLabel     = "Heavy Hit Threshold (%)",
    DamageFlashThresholdTooltip   = "Hits that deal more than this percentage of your max HP in a single strike are treated as heavy hits and use the heavy settings below.",
    DamageFlashLightHeader        = "Light Hit Taken",
    DamageFlashHeavyHeader        = "Heavy Hit Taken",
    DamageFlashShakeLightLabel    = "Shake Intensity — Light",
    DamageFlashShakeLightTooltip  = "Camera shake magnitude for light hits. 0 = no shake.",
    DamageFlashAlphaLightLabel    = "Overlay Opacity — Light",
    DamageFlashAlphaLightTooltip  = "Peak blood-border opacity for light hits.",
    DamageFlashDurLightLabel      = "Duration (ms) — Light",
    DamageFlashDurLightTooltip    = "How long the shake and flash last for light hits.",
    DamageFlashShakeHeavyLabel    = "Shake Intensity — Heavy",
    DamageFlashShakeHeavyTooltip  = "Camera shake magnitude for heavy hits. Higher = more violent.",
    DamageFlashAlphaHeavyLabel    = "Overlay Opacity — Heavy",
    DamageFlashAlphaHeavyTooltip  = "Peak blood-border opacity for heavy hits.",
    DamageFlashDurHeavyLabel      = "Duration (ms) — Heavy",
    DamageFlashDurHeavyTooltip    = "How long the shake and flash last for heavy hits.",
    DamageFlashZoomDistLightLabel  = "Zoom Distance — Light",
    DamageFlashZoomDistLightTooltip = "How far the camera pulls back on a light hit. 0 = disabled.",
    DamageFlashZoomRetLightLabel   = "Zoom Return (ms) — Light",
    DamageFlashZoomRetLightTooltip = "Time in ms for the camera to ease back to its original distance after a light hit.",
    DamageFlashZoomDistHeavyLabel  = "Zoom Distance — Heavy",
    DamageFlashZoomDistHeavyTooltip = "How far the camera pulls back on a heavy hit. 0 = disabled.",
    DamageFlashZoomRetHeavyLabel   = "Zoom Return (ms) — Heavy",
    DamageFlashZoomRetHeavyTooltip = "Time in ms for the camera to ease back to its original distance after a heavy hit.",
}

-----------------------------------------------------------
-- DEFAULT PROFILE
-----------------------------------------------------------
function DarkScrollsUI.GetDefaultProfileSettings()
    return {
        ["DarkScrollsUI_PlayerHealthBar"]        = { ["l"] = 109, ["r"] = 0, ["fs"] = 1, ["a"] = 1, ["w"] = 492.5983886719, ["h"] = 7.9011688232, ["t"] = 65.4013671875, ["color"] = { ["r"] = 0.5, ["g"] = 0.02, ["b"] = 0 } },
        ["DarkScrollsUI_PlayerMagickaBar"]     = { ["l"] = 109, ["r"] = 0, ["fs"] = 1, ["a"] = 1, ["w"] = 335.2464294434, ["h"] = 9.1571273804, ["t"] = 75.4013671875, ["color"] = { ["r"] = 0, ["g"] = 0.2431372553, ["b"] = 1 } },
        ["DarkScrollsUI_PlayerStaminaBar"]     = { ["l"] = 449, ["r"] = 0, ["fs"] = 1, ["a"] = 1, ["w"] = 151.7519531250, ["h"] = 9.0343551636, ["t"] = 75.4013671875, ["color"] = { ["r"] = 0.28, ["g"] = 0.77, ["b"] = 0.16 } },
        ["DarkScrollsUI_PlayerShieldBar"]      = { ["l"] = 109, ["r"] = 0, ["fs"] = 1, ["a"] = 1, ["w"] = 493.0375366211, ["h"] = 7.9014816284, ["t"] = 55.4013671875, ["color"] = { ["r"] = 0, ["g"] = 0.6588235497, ["b"] = 1 } },
        ["DarkScrollsUI_PlayerMountStaminaBar"] = { ["l"] = 449, ["r"] = 0, ["fs"] = 1, ["a"] = 1, ["w"] = 151.7519531250, ["h"] = 6.6451034546, ["t"] = 85.4013671875, ["color"] = { ["r"] = 0.7686274648, ["g"] = 0.6117647290, ["b"] = 0 } },
        ["DarkScrollsUI_PrimaryWeaponIndicator"]   = { ["l"] = 140, ["r"] = 0, ["fs"] = 0.8, ["a"] = 1, ["w"] = 87.4290161133, ["h"] = 87.4289550781, ["t"] = 902.4013671875 },
        ["DarkScrollsUI_SecondaryWeaponIndicator"] = { ["l"] = 100, ["r"] = 0, ["fs"] = 0.9, ["a"] = 1, ["w"] = 62.5986480713, ["h"] = 62.5986328125, ["t"] = 962.4013671875 },
        ["showWeaponIcons"] = true,

        ["DarkScrollsUI_ActionButtonSlotThree"]      = { ["l"] = 169, ["r"] = 0.785398, ["fs"] = 0.6, ["a"] = 0.96, ["w"] = 31.6055297852, ["h"] = 31.6053848267, ["t"] = 95.4013671875 },
        ["DarkScrollsUI_ActionButtonSlotFour"]      = { ["l"] = 219, ["r"] = 0.785398, ["fs"] = 0.6, ["a"] = 0.96, ["w"] = 31.6055297852, ["h"] = 31.6053085327, ["t"] = 95.4013671875 },
        ["DarkScrollsUI_ActionButtonSlotFive"]      = { ["l"] = 269, ["r"] = 0.785398, ["fs"] = 0.6, ["a"] = 0.96, ["w"] = 31.6055297852, ["h"] = 31.6053848267, ["t"] = 95.4013671875 },
        ["DarkScrollsUI_ActionButtonSlotSix"]      = { ["l"] = 319, ["r"] = 0.785398, ["fs"] = 0.6, ["a"] = 0.96, ["w"] = 31.6054992676, ["h"] = 31.6053161621, ["t"] = 95.4013671875 },
        ["DarkScrollsUI_ActionButtonSlotSeven"]      = { ["l"] = 369, ["r"] = 0.785398, ["fs"] = 0.6, ["a"] = 1,    ["w"] = 28.9414672852, ["h"] = 28.9414825439, ["t"] = 95.4013671875 },
        ["DarkScrollsUI_UltimateAbilitySlot"]      = { ["l"] = 29,  ["r"] = -2.356194, ["fs"] = 1, ["a"] = 0.91, ["w"] = 65.2602996826, ["h"] = 65.2602996826, ["t"] = 36.4013671875 },
        ["DarkScrollsUI_QuickslotItemSlot"]  = { ["l"] = 109, ["r"] = 0,             ["fs"] = 0.6, ["a"] = 1, ["w"] = 47.6668395996, ["h"] = 47.6668395996, ["t"] = 85.4013671875 },

        ["DarkScrollsUI_TargetBuffTracker"]   = { ["l"] = 110, ["r"] = 0, ["fs"] = 1.1, ["a"] = 0.5, ["w"] = 494.8934326172, ["h"] = 17.9548492432, ["t"] = 142.4013671875 },
        ["DarkScrollsUI_PlayerBuffTracker"]   = { ["l"] = 109, ["r"] = 0, ["fs"] = 1, ["a"] = 0.3, ["w"] = 491.9072265625, ["h"] = 25.5761337280, ["t"] = 25.4013671875 },

        ["DarkScrollsUI_QuestObjectiveTracker"] = { ["l"] = 1590, ["r"] = 0, ["fs"] = 1, ["a"] = 1, ["w"] = 300, ["h"] = 150, ["t"] = 20 },
        ["DarkScrollsUI_BossHealthBarDisplay"]      = { ["l"] = 590, ["r"] = 0, ["fs"] = 1, ["a"] = 1, ["w"] = 742, ["h"] = 10, ["t"] = 890 },
        ["DarkScrollsUI_BossHealthBarDisplayName"]  = { ["l"] = 760, ["r"] = 0, ["fs"] = 1.5, ["a"] = 1, ["w"] = 400, ["h"] = 36, ["t"] = 850 },
        ["DarkScrollsUI_BossHealthBarDisplayHP"]    = { ["l"] = 540, ["r"] = 0, ["fs"] = 1, ["a"] = 1, ["w"] = 46, ["h"] = 46, ["t"] = 870 },
        ["DarkScrollsUI_TargetHealthBar"]           = { ["l"] = 820, ["r"] = 0, ["fs"] = 1, ["a"] = 1, ["w"] = 268, ["h"] = 8, ["t"] = 150 },
        ["DarkScrollsUI_TargetNameLabel"]           = { ["l"] = 590, ["r"] = 0, ["fs"] = 1, ["a"] = 1, ["w"] = 400, ["h"] = 30, ["t"] = 920 },
        ["DarkScrollsUI_PlayerGroupStatusFrame"]   = { ["l"] = 30, ["r"] = 0, ["fs"] = 0.8, ["a"] = 1, ["w"] = 240, ["h"] = 180, ["t"] = 300 },

        ["DarkScrollsUI_CompassNavigationFrame"]     = { ["l"] = 680, ["r"] = -2.356194, ["fs"] = 1.1, ["a"] = 1, ["w"] = 566, ["h"] = 20, ["t"] = 52.4013671875 },

        ["graySaturation"]           = 0.15,
        ["grayUltSaturation"]        = 0.66,
        ["graySkillsEnabled"]        = true,
        ["hudFadeEnabled"]           = true,
        ["customQuestTrackerEnabled"] = true,
        ["damageFlashEnabled"]            = true,
        -- Percentage of max HP lost in a single hit that separates light from heavy.
        -- e.g. 0.10 = hits that take more than 10% HP are "heavy".
        ["damageFlashHeavyThreshold"]     = 0.2,
        -- Light hit settings
        ["damageFlashLightShakeIntensity"] = 0.06,
        ["damageFlashLightAlphaPeak"]      = 0.48,
        ["damageFlashLightDuration"]       = 300,
        ["damageFlashLightZoomDistance"]   = 0.4,
        ["damageFlashLightZoomReturn"]     = 600,
        -- Heavy hit settings
        ["damageFlashHeavyShakeIntensity"] = 0.094,
        ["damageFlashHeavyAlphaPeak"]      = 0.76,
        ["damageFlashHeavyDuration"]       = 500,
        ["damageFlashHeavyZoomDistance"]   = 1.0,
        ["damageFlashHeavyZoomReturn"]     = 1000,
        ["showUltOverlay"]           = false,
        ["ultOverlayRotation"]       = 180,
        ["default"]                  = {}
    }
end

-----------------------------------------------------------
-- SHARED UTILITIES
-----------------------------------------------------------
function DarkScrollsUI.DisplayProfileSystemMessage(text)
    d(text)
end

function DarkScrollsUI.GetListOfAllControlNames()
    local controls = {
        "DarkScrollsUI_PlayerHealthBar", "DarkScrollsUI_PlayerMagickaBar", "DarkScrollsUI_PlayerStaminaBar", 
        "DarkScrollsUI_PlayerShieldBar", "DarkScrollsUI_PlayerMountStaminaBar", "DarkScrollsUI_QuickslotItemSlot", 
        "DarkScrollsUI_QuestObjectiveTracker", "DarkScrollsUI_PlayerGroupStatusFrame",
        "DarkScrollsUI_ActionButtonSlotThree", "DarkScrollsUI_ActionButtonSlotFour", "DarkScrollsUI_ActionButtonSlotFive",
        "DarkScrollsUI_ActionButtonSlotSix", "DarkScrollsUI_ActionButtonSlotSeven", "DarkScrollsUI_UltimateAbilitySlot",
        "DarkScrollsUI_PlayerBuffTracker", "DarkScrollsUI_TargetBuffTracker", 
        "DarkScrollsUI_PrimaryWeaponIndicator", "DarkScrollsUI_SecondaryWeaponIndicator", "DarkScrollsUI_CompassNavigationFrame",
        "DarkScrollsUI_TargetHealthBar"
    }
    return controls
end

-----------------------------------------------------------
-- QUEST TRACKER TOGGLE HELPERS
-- Called from DS_Menu.lua and DS_Init.lua to enable or
-- disable the custom tracker and restore the native one.
-----------------------------------------------------------
function DarkScrollsUI.ApplyQuestTrackerDisplaySetting()
    local enabled = DarkScrollsUI.SavedVariables and DarkScrollsUI.SavedVariables.customQuestTrackerEnabled

    if enabled then
        -- Hide native tracker and keep it hidden
        if ZO_FocusedQuestTrackerPanel then
            ZO_FocusedQuestTrackerPanel:SetHidden(true)
            ZO_FocusedQuestTrackerPanel:SetAlpha(0)
        end
        if FOCUSED_QUEST_TRACKER_FRAGMENT then
            if HUD_SCENE    then HUD_SCENE:RemoveFragment(FOCUSED_QUEST_TRACKER_FRAGMENT)    end
            if HUD_UI_SCENE then HUD_UI_SCENE:RemoveFragment(FOCUSED_QUEST_TRACKER_FRAGMENT) end
        end
        -- Show our custom tracker
        if DarkScrollsUI.QuestTrackerDisplay then
            DarkScrollsUI.QuestTrackerDisplay:SetHidden(false)
            if DarkScrollsUI.UpdateQuestTrackerInformation then DarkScrollsUI.UpdateQuestTrackerInformation() end
        end
    else
        -- Restore native tracker
        if FOCUSED_QUEST_TRACKER_FRAGMENT then
            if HUD_SCENE    then HUD_SCENE:AddFragment(FOCUSED_QUEST_TRACKER_FRAGMENT)    end
            if HUD_UI_SCENE then HUD_UI_SCENE:AddFragment(FOCUSED_QUEST_TRACKER_FRAGMENT) end
        end
        if ZO_FocusedQuestTrackerPanel then
            ZO_FocusedQuestTrackerPanel:SetAlpha(1)
            ZO_FocusedQuestTrackerPanel:SetHidden(false)
        end
        -- Hide our custom tracker
        if DarkScrollsUI.QuestTrackerDisplay then
            DarkScrollsUI.QuestTrackerDisplay:SetHidden(true)
        end
    end
end

-----------------------------------------------------------
-- SKILL → BUFF MAPPING (used in DS_Bars.lua)
-----------------------------------------------------------
DarkScrollsUI.SkillToBuffMapping = {
    ["dragon blood"]         = {"major fortitude", "major endurance"},
    ["green dragon blood"]   = {"major fortitude", "major endurance"},
    ["coagulating blood"]    = {"major fortitude", "major endurance"},
    ["elder dragon blood"]   = {"major fortitude", "major endurance", "minor endurance"},
    ["spiked armor"]         = {"major resolve"},
    ["hardened armor"]       = {"major resolve"},
    ["volatile armor"]       = {"major resolve"},
    ["molten weapons"]       = {"major brutality", "major sorcery"},
    ["igneous weapons"]      = {"major brutality", "major sorcery"},
    ["obsidian shield"]      = {"major mending", "igneous shield"},
    ["inferno"]              = {"major prophecy", "major savagery"},
    ["bound armor"]          = {"minor resolve", "bound armaments"},
    ["lightning flood"]      = {"major expedition"},
    ["critical surge"]       = {"major brutality", "major sorcery"},
    ["hurricane"]            = {"major resolve", "minor expedition"},
    ["dark exchange"]        = {"minor prophecy", "minor Intellect"},
    ["grim focus"]           = {"assassin's focus"},
    ["relentless focus"]     = {"assassin's focus"},
    ["shadow cloak"]         = {"major prophecy", "major savagery"},
    ["blur"]                 = {"major evasion"},
    ["mark target"]          = {"major breach"},
    ["drain power"]          = {"major brutality", "major sorcery"},
    ["restoring focus"]      = {"major resolve", "minor fortitude", "minor endurance", "minor intellect"},
    ["channeled focus"]      = {"major resolve", "minor fortitude", "minor endurance", "minor intellect"},
    ["sun shield"]           = {"major mending"},
    ["spear shards"]         = {"minor prophecy", "minor savagery"},
    ["radial sweep"]         = {"major protection"},
    ["frost cloak"]          = {"major resolve"},
    ["ice fortress"]         = {"major resolve", "minor protection"},
    ["bull netch"]           = {"major brutality", "major sorcery"},
    ["blue betty"]           = {"major brutality", "major sorcery"},
    ["falcon's swiftness"]   = {"major expedition", "major endurance"},
    ["beckoning armor"]      = {"major resolve"},
    ["spirit guardian"]      = {"minor protection"},
    ["cruxweaver armor"]     = {"major resolve", "minor breach"},
    ["inspired scholarship"] = {"major prophecy", "major savagery"},
    ["vigor"]                = {"resolute", "echoing vigor"},
    ["momentum"]             = {"major brutality", "major sorcery", "forward momentum"},
    ["trap beast"]           = {"minor force"},
    ["accelerate"]           = {"minor force", "major expedition"},
    ["inner light"]          = {"major prophecy", "major savagery"},
    ["caltrops"]             = {"major breach"},
    ["weakness to elements"] = {"major breach"},
}
