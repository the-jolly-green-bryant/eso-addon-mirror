--[[
	Addon: Taos Group Tools
	Author: TProg Taonnor
	Created by @Taonnor
]]--

--[[
	Default variables
]]--

TGT_DEFAULTS = 
{
    -- Global settings; effects multiple parts
    ["IsSendingDataActive"]                 = true,
    ["SoundOnReady"]                        = { 1, "No Sound" },
    ["SoundOnThrown"]                       = { 1, "No Sound" },
    ["Movable"]                             = true,
    ["AccountNames"]                        = false,
    ["OnlyAva"]                             = {
        ["TGT-GroupUltimate"]               = false,
        ["TGT-GroupStats"]                  = false,
        ["TGT-GroupDeto"]                   = false,
    },
    ["CombatActive"]                        = {
        ["TGT-GroupUltimate"]               = true,
        ["TGT-GroupFrames"]                 = true,
    },
    ["Style"]                               = {
        ["TGT-GroupUltimate"]               = 2,
        ["TGT-GroupStats"]                  = 2,
        ["TGT-GroupFrames"]                 = 2,
    },
    ["VisibleOffset"]                       = {
        ["TGT-GroupUltimate"]               = 2,
        ["TGT-GroupStats"]                  = 2,
    },
    ["Scale"]                               = {
        ["TGT-GroupUltimate"]               = 1.0,
        ["TGT-GroupFrames"]                 = 1.0,
    },
    ["Position"]                            = {
        ["TGT-GroupUltimate"]               = { ["PosX"] = 0, ["PosY"] = 0 },
        ["TGT-UltimateSelector"]            = { ["PosX"] = 0, ["PosY"] = 0 },
        ["TGT-GroupStats"]                  = {
            ["DpsList"]                     = { ["PosX"] = 0, ["PosY"] = 0 },
            ["HpsList"]                     = { ["PosX"] = 0, ["PosY"] = 0 },
            ["BarList"]                     = { ["PosX"] = 0, ["PosY"] = 0 },
        },
        ["TGT-GroupLeader"]                 = { ["PosX"] = 0, ["PosY"] = 0 },
        ["TGT-GroupDeto"]                   = { ["PosX"] = 0, ["PosY"] = 0 },
        ["TGT-GroupPurge"]                  = { ["PosX"] = 0, ["PosY"] = 0 },
        ["TGT-GroupSpeed"]                  = { ["PosX"] = 0, ["PosY"] = 0 },
        ["TGT-GroupEarthgore"]              = { ["PosX"] = 0, ["PosY"] = 0 },
    },
    ["ModuleColors"]                        = {
        ["TGT-GroupUltimate"]               = {
            ["UltimateProgrColor"]          = { R = 0.50, G = 0.50, B = 0.50, A = 0.50 },
            ["UltimateReadyColor"]          = { R = 0.60, G = 0.03, B = 1.00, A = 0.50 },
            ["StaminaProgrColor"]           = { R = 0.03, G = 0.70, B = 0.03, A = 0.50 },
            ["StaminaReadyColor"]           = { R = 0.03, G = 0.70, B = 0.03, A = 0.50 },
            ["MagickaProgrColor"]           = { R = 0.03, G = 0.03, B = 0.70, A = 0.50 },
            ["MagickaReadyColor"]           = { R = 0.03, G = 0.03, B = 0.70, A = 0.50 },
        },
        ["TGT-GroupFrames"]                 = {
            ["ShieldColor"]                 = { R = 0.51, G = 0.03, B = 0.90, A = 0.50 },
            ["HealthProgrColor"]            = { R = 0.70, G = 0.03, B = 0.03, A = 0.50 },
            ["HealthReadyColor"]            = { R = 0.70, G = 0.03, B = 0.03, A = 0.50 },
            ["UltimateProgrColor"]          = { R = 0.50, G = 0.50, B = 0.50, A = 0.50 },
            ["UltimateReadyColor"]          = { R = 0.60, G = 0.03, B = 1.00, A = 0.50 },
            ["StaminaProgrColor"]           = { R = 0.03, G = 0.70, B = 0.03, A = 0.50 },
            ["StaminaReadyColor"]           = { R = 0.03, G = 0.70, B = 0.03, A = 0.50 },
            ["MagickaProgrColor"]           = { R = 0.03, G = 0.03, B = 0.70, A = 0.50 },
            ["MagickaReadyColor"]           = { R = 0.03, G = 0.03, B = 0.70, A = 0.50 },
        },
        ["TGT-GroupLeader"]                 = {
            ["ArrowColor"]                  = { R = 0.03, G = 1.00, B = 0.03, A = 1.00 },
            ["CompassColor"]                = { R = 1.00, G = 1.00, B = 1.00, A = 0.80 },
        },
        ["TGT-GroupStats"]                  = {
            ["GroupHpsDpsBarColor"]         = { R = 0.03, G = 0.95, B = 0.95, A = 0.50 },
        },
        ["TGT-GroupDeto"]                   = { 
            ["GroupDetoColor"]              = { R = 0.03, G = 1.00, B = 0.03, A = 0.50 },
        },
        ["TGT-GroupPurge"]                  = {
            ["GroupPurgeColor"]             = { R = 0.03, G = 1.00, B = 0.03, A = 0.50 },
        },
        ["TGT-GroupSpeed"]                  = {
            ["GroupSpeedColor"]             = { R = 0.03, G = 1.00, B = 0.03, A = 0.50 },
        },
        ["TGT-GroupEarthgore"]              = {
            ["GroupEarthgoreColor"]         = { R = 0.03, G = 1.00, B = 0.03, A = 0.50 },
        },
    },
    ["TrackedBuffs"]                        = {
        ["TGT-GroupUltimate"]               = {
            ["TrackedBuff1AbilityId"]       = 97857,
            ["TrackedBuff2AbilityId"]       = 65706,
            ["TrackedBuff3AbilityId"]       = 66902,
            ["TrackedBuff4AbilityId"]       = 76936,
        },
        ["TGT-GroupFrames"]                 = {
            ["TrackedBuff1AbilityId"]       = 97857,
            ["TrackedBuff2AbilityId"]       = 65706,
            ["TrackedBuff3AbilityId"]       = 66902,
            ["TrackedBuff4AbilityId"]       = 76936,
        },
    },

    -- Ultimate Selector
    ["StaticUltimateID"]                    = {
        ["Default"]                         = 28341, 
    },
    
    -- Group Ultimate settings
    ["IsGroupUltimateEnabled"]              = true,
    ["IsSortingActive"]                     = true,
    ["Swimlanes"]                           = 6,
    ["SwimlaneUltimateGroupIds"]            = {
        [1]                                 = 28341,
        [2]                                 = 22223,
        [3]                                 = 86109,
        [4]                                 = 83619,
        [5]                                 = 35713,
        [6]                                 = 38563,
        [7]                                 = 28341,
        [8]                                 = 28341,
        [9]                                 = 28341,
        [10]                                = 28341,
        [11]                                = 28341,
        [12]                                = 28341,
    },
    --
    ["IsGroupResourcesEnabled"]             = true,
    --
    ["IsGroupBuffsEnabled"]                 = true,
    
    -- Group Leader settings
    ["IsLeaderIconActive"]                  = true,
    ["Icon"]                                = 1,
    ["IconSize"]                            = 32,
    --
    ["IsLeaderArrowActive"]                 = true,
    ["CircleDistance"]                      = 0,
    ["LeaderArrowDistance"]                 = true,
    ["MinDistance"]                         = 0,
    ["MaxDistance"]                         = 128,
    --
    ["IsCustomizedCompassActive"]           = true,
    ["HideStandardCompass"]                 = true,
    ["CompassRadius"]                       = 128,
    ["CompassFont"]                         = 1,
    ["CompassFontSize"]                     = 18,
    ["FlatCompass"]                         = false,
    
    -- Group Invite settings
    ["IsGroupInviteEnabled"]                = true,
    ["InviteString"]                        = "",
    ["MaxGroupSize"]                        = 24,
    ["AutoKick"]                            = true,
    ["AutoKickTimeout"]                     = 60,
    
    -- Group HPS/DPS settings
    ["IsGroupHpsDpsEnabled"]                = true,
    ["DpsHpsVisibleOption"]                 = 1,
    ["ShowBarGloss"]                        = false,

    -- Group Frame settings
    ["IsGroupFramesEnabled"]                = true,
    ["HideZosGroupFrames"]                  = true,
    ["ShowFoodBuff"]                        = true,
    ["ShowUltimateInsteadHaelth"]           = false,
    ["HealthBarFormat"]                     = 4,
    ["GroupFramesBarWidth"]                 = 140,
    ["GroupFrameGroups"]                    = { 
        ["MainGroup"]                       = { ["PosX"] = 0, ["PosY"] = 0, ["Name"] = "" },
        ["SubGroup1"]                       = { ["PosX"] = 0, ["PosY"] = 0, ["Name"] = "" },
        ["SubGroup2"]                       = { ["PosX"] = 0, ["PosY"] = 0, ["Name"] = "" },
        ["SubGroup3"]                       = { ["PosX"] = 0, ["PosY"] = 0, ["Name"] = "" },
        ["SubGroup4"]                       = { ["PosX"] = 0, ["PosY"] = 0, ["Name"] = "" },
        ["SubGroup5"]                       = { ["PosX"] = 0, ["PosY"] = 0, ["Name"] = "" },
    },
    ["PlayerFrameGroups"]                   = {},

    -- Group Deto settings
    ["IsGroupDetoEnabled"]                  = true,
    ["IsGroupDetoHeaderVisible"]            = true,
    ["GroupDetoSize"]                       = { ["Width"] = 200, ["Height"] = 20 },
    
    -- Group Purge settings
    ["IsGroupPurgeEnabled"]                 = true,
    ["IsGroupPurgeHeaderVisible"]           = true,
    ["GroupPurgeSize"]                      = { ["Width"] = 200, ["Height"] = 20 },

    -- Group Speed settings
    ["IsGroupSpeedEnabled"]                 = true,
    ["IsGroupSpeedHeaderVisible"]           = true,
    ["GroupSpeedSize"]                      = { ["Width"] = 200, ["Height"] = 20 },
    
    -- Group Earthgore settings
    ["IsGroupEarthgoreEnabled"]             = true,
    ["IsGroupEarthgoreHeaderVisible"]       = true,
    ["GroupEarthgoreSize"]                  = { ["Width"] = 200, ["Height"] = 20 },
}