Verdant = Verdant or {}
local Verdant = Verdant

Verdant.Constants = {
  ADDON_NAME    = "Verdant",
  VERSION       = "2.3.0",
  BUILD         = "2.3.0",
  SLASH_COMMAND = "/verdant",

  DEBUG         = false,

  SV_TABLE   = "VerdantSavedVars",
  SV_VERSION = 1,

  PROBE = {

    SRC_COMBAT_OUT      = "Verdant_CombatOut",
    SRC_COMBAT_IN       = "Verdant_CombatIn",
    SRC_SHIELD_RAW      = "Verdant_ShieldRaw",
    SRC_HEAL_ABSORBED   = "Verdant_HealAbsorbed",
    SRC_EFFECT          = "Verdant_Effect",
    SRC_EFFECT_ON_SELF  = "Verdant_EffectOnSelf",
    SRC_COMBAT_STATE    = "Verdant_CombatState",
    SRC_CAST            = "Verdant_Cast",
    SRC_GROUP_J         = "Verdant_GroupJoined",
    SRC_GROUP_L         = "Verdant_GroupLeft",
    SRC_GROUP_U         = "Verdant_GroupUpdate",
    SRC_PLAYER          = "Verdant_PlayerActivated",
    SRC_AUTOSAVE        = "Verdant_AutoSave",


    BUFFER_LIMIT = 200,


    CHAT_INTERVAL_MS = 250,


    DUMP_HISTORY_LIMIT = 5,


    AUTOSAVE_COOLDOWN_MS = 30000,
  },

  TEMPORAL = {
    UPDATE_NAME          = "VerdantTemporalSample",
    SAMPLE_RATE_DEFAULT  = 1000,
    TIME_WINDOW_DEFAULT  = 60,
  },

  POOL = {
    EVENT_CAPACITY = 4096,
  },

  GC = {
    PACING      = true,
    STEP_KB     = 2,
    INTERVAL_MS = 0,
  },

  ABILITY_KIND = {
    HEAL         = 1,
    OVERHEAL     = 2,
    SHIELD       = 3,
    DAMAGE_GROUP = 4,
  },

  PROFILER_BUDGETS_MS = {
    ["pipeline.combat_event"]            = 5.0,
    ["pipeline.effect"]                  = 2.0,
    ["pipeline.combat_event.acquisition"] = 2.0,
    ["pipeline.combat_event.filter"]     = 2.0,
    ["pipeline.combat_event.processing"] = 3.0,
    ["pipeline.render_tick"]             = 10.0,
    ["bar.refresh"]                      = 5.0,
    ["graph.sample_tick"]                = 15.0,
  },
}
